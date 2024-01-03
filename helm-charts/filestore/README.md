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

## Installing the Chart

Download the `falcon filestore` charts repo locally:

To install the chart with the release name `filestore`:

```bash
$ helm install filestore -n filestore helm-charts/filestore -f values.yaml
```

This above command deploys the nginx pod with custom configurations.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete rootca -n rootca
```

## Configuration

The following table lists the configurable parameters of the Filestore chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `replicaCount` |  | `1` |
| `image.repository` |  | `"nginx"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `"latest"` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `podAnnotations` |  | `{}` |
| `securityContext` |  | `{}` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` |  | `80` |
| `global.hlf_domain` |  | `"my-hlf-domain.com"` |
| `ingress.enabled` |  | `true` |
| `ingress.className` |  | `"nginx"` |
| `ingress.annotations` |  | `{}` |
| `ingress.hosts` |  | `[]` |
| `resources` |  | `{}` |
| `storage.size` |  | `"1G"` |
| `storage.accessMode` |  | `"ReadWriteOnce"` |
| `storage.storageClass` |  | `"standard"` |
| `autoscaling.enabled` |  | `false` |
| `autoscaling.minReplicas` |  | `1` |
| `autoscaling.maxReplicas` |  | `100` |
| `autoscaling.targetCPUUtilizationPercentage` |  | `80` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |
