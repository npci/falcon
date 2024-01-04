Fabric-ca
===========

A Helm chart for deploying Fabric CA Server in Kubernetes.

## Introduction

This chart will deploy Hyperledger Fabric-CA node in kubernetes either in standlone mode or Intermediate CA mode. 

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress (Optional and required if name based endpoints are needed.)
- Additionally the following prerequisites must be done before deploying CA with CNI based routing. https://github.com/npci/falcon/tree/main/examples#prerequisite
## Installing the Chart

Download the `falcon fabric-ca` charts repo locally:

To install the chart with the release name `root-ca`:

```bash
$ kubectl create ns orderer
$ kubectl -n orderer create secret generic rca-secret --from-literal=user=rca-admin --from-literal=password=rcaComplexPassword
$ helm install root-ca -n orderer helm-charts/fabric-ca -f examples/fabric-ca/root-ca.yaml
```

This above command deploys the Hyperledger Fabric-CA.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete rootca -n root-ca
```

## Configuration

The following table lists the configurable parameters of the Fabric-ca chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `imagePullSecrets` |  | `[]` |
| `additionalLabels` | Additional labels if required | `{}` |
| `project` | Project name tag of your choice | `"yourproject"` |
| `replicaCount` | Number of CA pods. HA is not supported with this version | `1` |
| `restartPolicy` | Pod restart policy on failure | `"Always"` |
| `image.repository` | Fabric-ca container image repository | `"hyperledger/fabric-ca"` |
| `image.pullPolicy` | Fabric-ca container image pull policy  | `"IfNotPresent"` |
| `image.tag` | Fabric-ca container image tag | `"1.5.0"` |
| `retry_seconds` | Retry period in seconds for any script activities. | `60` |
| `recreate_intermediate_cert` | `true` if parent public key cert needs to be re-created | `false` |
| `tls_domain` | Any resolvable DNS for you CA endpoint | `"my-hlf-domain.com"` |
| `ca_server.csr_names_c` | Country name abbreviation in TWO letter | `"IN"` |
| `ca_server.csr_names_st` | State | `"Maharashtra"` |
| `ca_server.csr_names_l` | Locality | `"Mumbai"` |
| `ca_server.csr_names_o` | Organization Name | `"Your Company Name"` |
| `ca_server.csr_names_ou` | Organization Unit | `"Your Organization Unit"` |
| `ca_server.container_port` | Fabric-ca container port | `7051` |
| `ca_server.debug` | `true` if debug log is required | `true` |
| `ca_server.tls_enabled` | `true` if TLS needs to be enabled | `true` |
| `ca_server.admin_secret` | Username and password required for CA server bootstrapping. | `"rca-secret"` |
| `ca_server.additional_sans` | Additional hostnames if required | `[]` |
| `ica.enabled` | `true` if need to be deployed as an ICA | `false` |
| `ica.parent_ca_endpoint` | If `ica.enabled` is `true`, then provide the parent CA endpoint without http/s and port. Eg; "parentca-endpoint:30000"  | `""` |
| `ica.intermediate_tls_cert_dir` | The directory where the parent CA's public key cert to be fetched and stored | `/tmp/hyperledger/fabric-ca/root-ca-cert` |
| `ica.intermediate_tls_cert_file` | The filename of the parents CA's public key | `cert.pem` |
| `service.type` | kubenetes service type of Fabric-ca | `"ClusterIP"` |
| `service.port` | kubenetes service port of Fabric-ca | `7051` |
| `ingress.enabled` | `true` if ingress is needed | `true` |
| `ingress.className` | Ingress class name | `"nginx"` |
| `ingress.annotations` | Ingress annotations. | `nginx.ingress.kubernetes.io/ssl-passthrough: "true"` |
| `ingress.path` | Default path | `"/"` |
| `ingress.pathType` | Default path type | `"Prefix"` |
| `storage.pvc_enabled` | `true` if PVC support is required for CA data/home directory | `true` |
| `storage.accessMode` | PVC accessmode | `"ReadWriteOnce"` |
| `storage.storageClass` | PVC storageclass | `"standard"` |
| `storage.size` | Storage size of the data/home pvc | `"1G"` |
| `storage.path` | The path on where the PVC should be mounted | `"/tmp/hyperledger/fabric-ca/crypto"` |
| `serviceAccount.create` | `true` if ServiceAccount is required | `true` |
| `serviceAccount.annotations` | Any ServiceAccount annotations | `{}` |
| `serviceAccount.name` | If want to specify specific ServiceAccount name | `""` |
| `resources` | Compute resources for fabric ca container | `[]` |
| `startupProbe` | Default startupProbe | `{}` |
| `livenessProbe` | Default livenessProbe | `{}` |
| `readinessProbe` | Default readinessProbe | `{}` |
| `podAnnotations` | Default podAnnotations | `{}` |
| `podSecurityContext` | Default podSecurityContext | `{}` |
| `securityContext` | Default securityContext | `{}` |
| `affinity` | Default affinity | `{}` |
| `nodeSelector` | Default nodeSelector  | `{}` |
| `tolerations` | Default tolerations | `[]` |
