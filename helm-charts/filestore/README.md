Filestore
===========

A Helm chart for deploying an Nginx file sharing web server in Kubernetes.


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
