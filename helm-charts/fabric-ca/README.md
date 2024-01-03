Fabric-ca
===========

A Helm chart for deploying Fabric CA Server in Kubernetes.

## Introduction

This chart can deploy Hyperledger Fabric-CA node in kubernetes. 

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress

## Installing the Chart

Download the `falcon fabric-ca` charts repo locally:

To install the chart with the release name `rootca`:

```bash
$ helm install rootca -n rootca helm-charts/fabric-ca/ -f values.yaml
```

This above command deploys the peer nodes based on your peer count at peer array. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete rootca -n rootca
```

## Configuration

The following table lists the configurable parameters of the Fabric-ca chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `additionalLabels` |  | `{}` |
| `replicaCount` |  | `1` |
| `restartPolicy` |  | `"Always"` |
| `image.repository` |  | `"hyperledger/fabric-ca"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `"1.5.0"` |
| `retry_seconds` |  | `60` |
| `recreate_intermediate_cert` |  | `false` |
| `tls_domain` |  | `"my-hlf-domain.com"` |
| `ca_server.csr_names_c` |  | `"IN"` |
| `ca_server.csr_names_st` |  | `"Maharashtra"` |
| `ca_server.csr_names_l` |  | `"Mumbai"` |
| `ca_server.csr_names_o` |  | `"Your Company Name"` |
| `ca_server.csr_names_ou` |  | `"Your Organization Unit"` |
| `ca_server.container_port` |  | `7051` |
| `ca_server.debug` |  | `true` |
| `ca_server.tls_enabled` |  | `true` |
| `ca_server.admin_secret` |  | `"rca-secret"` |
| `ca_server.additional_sans` |  | `[]` |
| `ica.enabled` |  | `false` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` |  | `7051` |
| `ingress.enabled` |  | `true` |
| `ingress.className` |  | `"nginx"` |
| `ingress.annotations.nginx.ingress.kubernetes.io/ssl-passthrough` |  | `"true"` |
| `ingress.path` |  | `"/"` |
| `ingress.pathType` |  | `"Prefix"` |
| `storage.pvc_enabled` |  | `true` |
| `storage.accessMode` |  | `"ReadWriteOnce"` |
| `storage.storageClass` |  | `"standard"` |
| `storage.size` |  | `"1G"` |
| `storage.path` |  | `"/tmp/hyperledger/fabric-ca/crypto"` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `resources.limits.cpu` |  | `"100m"` |
| `resources.limits.memory` |  | `"256Mi"` |
| `resources.requests.cpu` |  | `"100m"` |
| `resources.requests.memory` |  | `"128Mi"` |
| `startupProbe.httpGet.path` |  | `"/cainfo"` |
| `startupProbe.httpGet.port` |  | `"http"` |
| `startupProbe.httpGet.scheme` |  | `"HTTPS"` |
| `startupProbe.initialDelaySeconds` |  | `10` |
| `livenessProbe.httpGet.path` |  | `"/cainfo"` |
| `livenessProbe.httpGet.port` |  | `"http"` |
| `livenessProbe.httpGet.scheme` |  | `"HTTPS"` |
| `readinessProbe.httpGet.path` |  | `"/cainfo"` |
| `readinessProbe.httpGet.port` |  | `"http"` |
| `readinessProbe.httpGet.scheme` |  | `"HTTPS"` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext` |  | `{}` |
| `securityContext` |  | `{}` |
| `affinity` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
