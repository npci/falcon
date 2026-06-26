#!/usr/bin/python
# Copyright (c) YugaByte, Inc.

# This script would generate a kubeconfig for the given servie account
# by fetching the cluster information and also add the service account
# token for the authentication purpose.

import argparse
from subprocess import check_output
from sys import exit
import json
import base64
import tempfile
import time
import os.path


def run_command(command_args, namespace=None, as_json=True, log_command=True):
    command = ["kubectl"]
    if namespace:
        command.extend(["--namespace", namespace])
    command.extend(command_args)
    if as_json:
        command.extend(["-o", "json"])
    if log_command:
        print("Running command: {}".format(" ".join(command)))
    output = check_output(command)
    if as_json:
        return json.loads(output)
    else:
        return output.decode("utf8")


def create_sa_token_secret(directory, sa_name, namespace):
    """Creates a service account token secret for sa_name in
    namespace. Returns the name of the secret created.

    Ref:
    https://k8s.io/docs/concepts/configuration/secret/#service-account-token-secrets

    """
    token_secret = {
        "apiVersion": "v1",
        "data": {
            "do-not-delete-used-for-yugabyte-anywhere": "MQ==",
        },
        "kind": "Secret",
        "metadata": {
            "annotations": {
                "kubernetes.io/service-account.name": sa_name,
            },
            "name": sa_name,
        },
        "type": "kubernetes.io/service-account-token",
    }
    token_secret_file_name = os.path.join(directory, "token_secret.yaml")
    with open(token_secret_file_name, "w") as token_secret_file:
        json.dump(token_secret, token_secret_file)
    run_command(["apply", "-f", token_secret_file_name], namespace)
    return sa_name


def get_secret_data(secret, namespace):
    """Returns the secret in JSON format if it has ca.crt and token in
    it, else returns None. It retries 3 times with 1 second timeout
    for the secret to be populated with this data.

    """
    secret_data = None
    num_retries = 5
    timeout = 2
    while True:
        secret_json = run_command(["get", "secret", secret], namespace)
        if "ca.crt" in secret_json["data"] and "token" in secret_json["data"]:
            secret_data = secret_json
            break

        num_retries -= 1
        if num_retries == 0:
            break
        print(
            "Secret '{}' is not populated. Sleep {}s, ({} retries left)".format(
                secret, timeout, num_retries
            )
        )
        time.sleep(timeout)
    return secret_data


def get_secrets_for_sa(sa_name, namespace):
    """Returns a list of all service account token secrets associated
    with the given sa_name in the namespace.

    """
    secrets = run_command(
        [
            "get",
            "secret",
            "--field-selector",
            "type=kubernetes.io/service-account-token",
            "-o",
            'jsonpath="{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name == "'
            + sa_name
            + '")].metadata.name}"',
        ],
        namespace,
        as_json=False,
    )
    return secrets.strip('"').split()


parser = argparse.ArgumentParser(description="Generate KubeConfig with Token")
parser.add_argument("-s", "--service_account", help="Service Account name", required=True)
parser.add_argument("-n", "--namespace", help="Kubernetes namespace", default="kube-system")
parser.add_argument("-c", "--context", help="kubectl context")
parser.add_argument("-o", "--output_file", help="output file path")
args = vars(parser.parse_args())

# if the context is not provided we use the current-context
context = args["context"]
if context is None:
    context = run_command(["config", "current-context"], args["namespace"], as_json=False)

cluster_attrs = run_command(
    ["config", "get-contexts", context.strip(), "--no-headers"], args["namespace"], as_json=False
)

cluster_name = cluster_attrs.strip().split()[2]
endpoint = run_command(
    [
        "config",
        "view",
        "-o",
        'jsonpath="{.clusters[?(@.name =="' + cluster_name + '")].cluster.server}"',
    ],
    args["namespace"],
    as_json=False,
)
service_account_info = run_command(["get", "sa", args["service_account"]], args["namespace"])

tmpdir = tempfile.TemporaryDirectory()

# Get the token and ca.crt from service account secret.
sa_secrets = list()

# Get secrets specified in the service account, there can be multiple
# of them, and not all are service account token secrets.
if "secrets" in service_account_info:
    sa_secrets = [secret["name"] for secret in service_account_info["secrets"]]

# Find the existing additional service account token secrets
sa_secrets.extend(get_secrets_for_sa(args["service_account"], args["namespace"]))

secret_data = None
for secret in sa_secrets:
    secret_data = get_secret_data(secret, args["namespace"])
    if secret_data is not None:
        break

# Kubernetes 1.22+ doesn't create the service account token secret by
# default, we have to create one.
if secret_data is None:
    print("No usable secret found for '{}', creating one.".format(args["service_account"]))
    token_secret = create_sa_token_secret(tmpdir.name, args["service_account"], args["namespace"])
    secret_data = get_secret_data(token_secret, args["namespace"])
    if secret_data is None:
        exit(
            "Failed to generate kubeconfig: No usable credentials found for '{}'.".format(
                args["service_account"]
            )
        )


context_name = "{}-{}".format(args["service_account"], cluster_name)
kube_config = args["output_file"]
if not kube_config:
    kube_config = "/tmp/{}.conf".format(args["service_account"])


ca_crt_file_name = os.path.join(tmpdir.name, "ca.crt")
ca_crt_file = open(ca_crt_file_name, "wb")
ca_crt_file.write(base64.b64decode(secret_data["data"]["ca.crt"]))
ca_crt_file.close()

# create kubeconfig entry
set_cluster_cmd = [
    "config",
    "set-cluster",
    cluster_name,
    "--kubeconfig={}".format(kube_config),
    "--server={}".format(endpoint.strip('"')),
    "--embed-certs=true",
    "--certificate-authority={}".format(ca_crt_file_name),
]
run_command(set_cluster_cmd, as_json=False)

user_token = base64.b64decode(secret_data["data"]["token"]).decode("utf-8")
set_credentials_cmd = [
    "config",
    "set-credentials",
    context_name,
    "--token={}".format(user_token),
    "--kubeconfig={}".format(kube_config),
]
run_command(set_credentials_cmd, as_json=False, log_command=False)

set_context_cmd = [
    "config",
    "set-context",
    context_name,
    "--cluster={}".format(cluster_name),
    "--user={}".format(context_name),
    "--kubeconfig={}".format(kube_config),
]
run_command(set_context_cmd, as_json=False)

use_context_cmd = ["config", "use-context", context_name, "--kubeconfig={}".format(kube_config)]
run_command(use_context_cmd, as_json=False)

print("Generated the kubeconfig file: {}".format(kube_config))
