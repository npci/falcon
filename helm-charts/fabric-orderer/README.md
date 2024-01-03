Fabric-orderer
===========

A Helm chart for deploying Fabric Orderers in Kubernetes.


## Configuration

The following table lists the configurable parameters of the Fabric-orderer chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `"orderer"` |
| `fullnameOverride` |  | `""` |
| `project` |  | `"yourproject"` |
| `orderers` |  | `[{"name": "orderer0", "identity_name": "orderer0-orderer", "identity_secret": "orderer0ordererSamplePassword"}, {"name": "orderer1", "identity_name": "orderer1-orderer", "identity_secret": "orderer1ordererSamplePassword"}, {"name": "orderer2", "identity_name": "orderer2-orderer", "identity_secret": "orderer2ordererSamplePassword"}]` |
| `csr_names_cn` |  | `"IN"` |
| `csr_names_st` |  | `"Maharashtra"` |
| `csr_names_l` |  | `"Mumbai"` |
| `csr_names_o` |  | `"Your Company Name"` |
| `filestore_endpoint` |  | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | Make it `true` if `filestore_endpoint` is over https. | `false` |
| `ica_tls_cert_file` |  | `"/root/ica-cert.pem"` |
| `retry_seconds` |  | `60` |
| `hlf_domain` |  | `"my-hlf-domain.com"` |
| `init.image.repository` |  | `"npcioss/hlf-builder"` |
| `init.image.tag` |  | `2.4` |
| `global.containerPort` |  | `7050` |
| `global.servicePort` |  | `7050` |
| `global.replicaCount` |  | `1` |
| `global.ica_endpoint` |  | `"ica-orderer.my-hlf-domain.com:30000"` |
| `global.tlsca_endpoint` |  | `"tls-ca.my-hlf-domain.com:30000"` |
| `global.block_file` |  | `"genesis.block"` |
| `global.require_certs_dir_persistence` |  | `true` |
| `global.image.repository` |  | `"hyperledger/fabric-orderer"` |
| `global.image.pullPolicy` |  | `"IfNotPresent"` |
| `global.image.imagePullSecrets` |  | `[]` |
| `global.image.tag` |  | `"2.4"` |
| `global.serviceAccount.annotations` |  | `[]` |
| `global.ingressEnabled` |  | `true` |
| `global.ingress.className` |  | `"nginx"` |
| `global.ingress.annotations.nginx.ingress.kubernetes.io/ssl-passthrough` |  | `"true"` |
| `global.storageAccessMode` |  | `"ReadWriteOnce"` |
| `global.dataStorageSize` |  | `"10Gi"` |
| `global.certStorageSize` |  | `"50M"` |
| `global.storageClass` |  | `"standard"` |
| `global.operations.serviceName` |  | `"operations"` |
| `global.operations.serviceType` |  | `"ClusterIP"` |
| `global.operations.servicePort` |  | `8443` |
| `global.metrics.provider` |  | `"prometheus"` |
| `global.metrics.serviceMonitor.enabled` |  | `false` |
| `global.metrics.serviceMonitor.additionalLabels` |  | `{}` |
| `global.metrics.serviceMonitor.namespace` |  | `""` |
| `global.metrics.serviceMonitor.portName` |  | `"operations"` |
| `global.metrics.serviceMonitor.scrapeInterval` |  | `"30s"` |
| `global.metrics.serviceMonitor.honorLabels` |  | `true` |
| `global.metrics.serviceMonitor.relabelings` |  | `[]` |
| `global.metrics.serviceMonitor.metricRelabelings` |  | `[]` |
| `global.metrics.serviceMonitor.namespaceSelector.any` |  | `true` |
| `global.metrics.serviceMonitor.targetLabels` |  | `[]` |
| `global.metrics.statsd.network` |  | `"udp"` |
| `global.metrics.statsd.address` |  | `"127.0.0.1:8125"` |
| `global.metrics.statsd.writeInterval` |  | `"10s"` |
| `global.env` |  | `[{"name": "FABRIC_LOGGING_SPEC", "value": "INFO"}, {"name": "ORDERER_GENERAL_GENESISMETHOD", "value": "file"}, {"name": "ORDERER_GENERAL_LISTENADDRESS", "value": "0.0.0.0"}, {"name": "ORDERER_GENERAL_TLS_ENABLED", "value": "true"}, {"name": "ORDERER_GENERAL_LOCALMSPDIR", "value": "{{ .Values.orderer_cert_base_dir }}/msp"}, {"name": "ORDERER_GENERAL_TLS_CERTIFICATE", "value": "{{ .Values.orderer_cert_base_dir }}/tls/server.crt"}, {"name": "ORDERER_GENERAL_TLS_PRIVATEKEY", "value": "{{ .Values.orderer_cert_base_dir }}/tls/server.key"}, {"name": "ORDERER_GENERAL_TLS_ROOTCAS", "value": "[{{ .Values.orderer_cert_base_dir }}/tls/ca.crt]"}, {"name": "ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE", "value": "{{ .Values.orderer_cert_base_dir }}/tls/server.crt"}, {"name": "ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY", "value": "{{ .Values.orderer_cert_base_dir }}/tls/server.key"}, {"name": "ORDERER_GENERAL_CLUSTER_ROOTCAS", "value": "[{{ .Values.orderer_cert_base_dir }}/tls/ca.crt]"}]` |
| `global.resources` |  | `{}` |
| `global.nodeSelector` |  | `{}` |
| `global.tolerations` |  | `[]` |
| `global.affinity` |  | `{}` |
| `startupProbe` |  | `{}` |
| `livenessProbe` |  | `{}` |
| `readinessProbe` |  | `{}` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext` |  | `{}` |
| `securityContext` |  | `{}` |
