Fabric-orderer
===========

A Helm chart for deploying Fabric Orderers in Kubernetes.


## Configuration

The following table lists the configurable parameters of the Fabric-orderer chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` | This has to match with Orderer Org name. | `"orderer"` |
| `fullnameOverride` |  | `""` |
| `project` | This will appear in every resource label. This is required. | `"yourproject"` |
| `orderers` | The list of orderer identities to deploy | `[]` |
| `csr_names_cn` | Country name abbreviation in TWO letter | `"IN"` |
| `csr_names_st` | State | `"Maharashtra"` |
| `csr_names_l` | Locality | `"Mumbai"` |
| `csr_names_o` | Organization Name | `"Your Company Name"` |
| `filestore_endpoint` | Filestore endpoint with `http/s://fqdn:port ` format. | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https. | `false` |
| `ica_tls_cert_file` | Path for the init container to pull public key cert of `global.ica_endpoint` | `"/root/ica-cert.pem"` |
| `retry_seconds` | Seconds to retry after any init container HLF activitity failures; Eg; enrollement | `60` |
| `hlf_domain` | The FQDN for the orderers. It should match with the channel config entries | `"my-hlf-domain.com"` |
| `init.image.repository` | The init container image repository | `"npcioss/hlf-builder"` |
| `init.image.tag` | The init container image tag | `2.4` |
| `global.containerPort` | Default Orderer container port | `7050` |
| `global.servicePort` | Default Orderer k8s service port | `7050` |
| `global.replicaCount` | Orderer replica count. Only 1 per orderer is supported as of now | `1` |
| `global.ica_endpoint` | MSPCA Server endpoint with port (without http/s) | `"ica-orderer.my-hlf-domain.com:30000"` |
| `global.tlsca_endpoint` | TLSCA server endpoint with port (without http/s) | `"tls-ca.my-hlf-domain.com:30000"` |
| `global.block_file` | Default genesis block file name in the filestore | `"genesis.block"` |
| `global.require_certs_dir_persistence` | Whether PVC support is required for enrolled certificate directory | `true` |
| `global.image.repository` | The Orderer container image repository | `"hyperledger/fabric-orderer"` |
| `global.image.pullPolicy` | The Orderer container image pullpolicy | `"IfNotPresent"` |
| `global.image.imagePullSecrets` | The Orderer container registry imagePullSecrets | `[]` |
| `global.image.tag` | The Orderer container image tag | `"2.4"` |
| `global.serviceAccount.annotations` | Service account annontations | `[]` |
| `global.additionalLabels` | To add additional labels. Can be global or per Orderer | `{}` |
| `global.ingressEnabled` | Determine whether ingress should be created or not. This can be set globally or per Orderer | `true` |
| `global.ingress.className` | Ingress class name | `"nginx"` |
| `global.ingress.annotations` | Ingress annotations to bypass ssl to pod  | `nginx.ingress.kubernetes.io/ssl-passthrough: "true"` |
| `global.storageAccessMode` | Storageclass access mode | `"ReadWriteOnce"` |
| `global.dataStorageSize` | PVC size of orderer data directory | `"10Gi"` |
| `global.certStorageSize` | PVC size of orderer cert directory | `"50M"` |
| `global.storageClass` | Storageclass name | `"standard"` |
| `global.operations.serviceName` | K8s service name for the operations | `"operations"` |
| `global.operations.serviceType` | K8s service type for the operations | `"ClusterIP"` |
| `global.operations.servicePort` | K8s service port for the operations | `8443` |
| `global.metrics.provider` | Select metrics provider. Possible values are "prometheus", "statsd" or "disabled"  | `"disabled"` |
| `global.metrics.serviceMonitor.enabled` | A serviceMonitor will be created for each orderer | `false` |
| `global.metrics.serviceMonitor.additionalLabels` | Additional labels for the serviceMonitor | `{}` |
| `global.metrics.serviceMonitor.namespace` | ServiceMonitor namespace | `""` |
| `global.metrics.serviceMonitor.portName` | ServiceMonitor target portname | `"operations"` |
| `global.metrics.serviceMonitor.scrapeInterval` | ServiceMonitor scrapeInterval | `"30s"` |
| `global.metrics.serviceMonitor.honorLabels` | ServiceMonitor honorLabels | `true` |
| `global.metrics.serviceMonitor.relabelings` | ServiceMonitor relabeling if required | `[]` |
| `global.metrics.serviceMonitor.metricRelabelings` | ServiceMonitor metricRelabelings if required  | `[]` |
| `global.metrics.serviceMonitor.namespaceSelector.any` | ServiceMonitor to choose the service from all ns | `true` |
| `global.metrics.serviceMonitor.targetLabels` | ServiceMonitor target label | `[]` |
| `global.metrics.statsd.network` |  | `"udp"` |
| `global.metrics.statsd.address` |  | `"127.0.0.1:8125"` |
| `global.metrics.statsd.writeInterval` |  | `"10s"` |
| `global.env` | Additional ENV variables for all Orderers | `[]` |
| `global.resources` | To set compute resources for all Orderers | `{}` |
| `global.nodeSelector` | To set nodeSelector for all Orderers | `{}` |
| `global.tolerations` | To set tolerations for all Orderers | `[]` |
| `global.affinity` | To set affinity for all Orderers | `{}` |
| `startupProbe` | Default Orderer startupProbe | `{}` |
| `livenessProbe` | Default Orderer livenessProbe | `{}` |
| `readinessProbe` | Default Orderer readinessProbe  | `{}` |
| `podAnnotations` | Default Orderer podAnnotations | `{}` |
| `podSecurityContext` | Default Orderer podSecurityContext | `{}` |
| `securityContext` | Default Orderer container securityContext | `{}` |
