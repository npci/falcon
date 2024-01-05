Filestore
===========

A Helm chart for deploying an Nginx file sharing web server in Kubernetes.

## Introduction

This chart will deploy an nginx web server with custom configurations that allows remote file upload over curl.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress
- Additionally the following prerequisites must be done before deploying peers. https://github.com/npci/falcon/tree/main/examples#prerequisite

## Installing the Chart

Download the `falcon filestore` charts repo locally:

To install the chart with the release name `filestore`:

```bash
$ helm install filestore -n filestore helm-charts/filestore/ -f examples/filestore/values.yaml --create-namespace
```

This above command deploys the nginx pod with custom configurations.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete filestore -n filestore
```

## Configuration

The following table lists the configurable parameters of the Filestore chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` | Helm default | `""` |
| `fullnameOverride` | Helm default  | `""` |
| `replicaCount` | Nginx web server replicacount | `1` |
| `image.repository` | Nginx web server container image repository | `"nginx"` |
| `image.pullPolicy` | Image pull policy | `"IfNotPresent"` |
| `image.tag` | Image tag | `"latest"` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `serviceAccount.create` | `true` to create serviceaccount | `true` |
| `serviceAccount.annotations` | Additional serviceaccount annotations | `{}` |
| `serviceAccount.name` | If want to specify the serviceaccount name | `""` |
| `podAnnotations` | Simple podAnnotations | `{}` |
| `securityContext` | Simple securityContext | `{}` |
| `service.type` | Kubernetes service type | `"ClusterIP"` |
| `service.port` | Kubernetes service port | `80` |
| `hostOverride` | Override the default `filestore.my-hlf-domain.com` end point at ingress resource | `""` |
| `global.hlf_domain` | Eg; `domain.com`, then the ingress will be created `"filestore.domain.com"` | `"my-hlf-domain.com"` |
| `ingress.enabled` | `true` to enable ingress resource | `true` |
| `ingress.className` | Ingress classname | `"nginx"` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Host array. By default the ingress will be created for the filestore.hlf_domain at / | `[]` |
| `ingress.tls.secretName` | The kubernetes tls secret name if you need TLS for the filestore end point | `""` |
| `resources` | Pod resources | `{}` |
| `storage.size` | PVC Size | `"1G"` |
| `storage.accessMode` | PVC access mode | `"ReadWriteOnce"` |
| `storage.storageClass` | PVC storage class | `"standard"` |
| `nodeSelector` | Node selectors | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Node/Pod affinities | `{}` |
