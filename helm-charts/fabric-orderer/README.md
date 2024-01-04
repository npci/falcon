Fabric-orderer
===========

A Helm chart for deploying Fabric Orderers in Kubernetes.

## Introduction

This chart can deploy and bootstrap the Hyperledger Fabric-Orderer nodes in kubernetes. 

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress
- Additionally the following prerequisites must be done before deploying CA with CNI based routing. https://github.com/npci/falcon/tree/main/examples#prerequisite

## Installing the Chart

> **NOTICE**: Before installing the orderer chart, please make sure that you have the following in place;-

1. Filestore is deployed and it is reachable at the filestore endpoint provided in `.Values.filestore_endpoint` 
2. You have Orderer, InitialPeer Org ICA's are deployed and respective Orderer, admin identities have been created.
3. You have executed the `crytpgen` job and verified the Orderer TLS Cert archive and Genesis block file has got created and it is available in your filestore under your project directory. Your project directory will be `.Values.project` by default.
4. Orderer deployment will not pass the init container if these conditions are not met.

Download the `falcon fabric-orderer` charts repo locally:

To install the chart with the release name `orderer`:

```bash
$ helm install orderer -n orderer helm-charts/fabric-orderer/ -f examples/fabric-orderer/orderer.yaml
```

This above command deploys the orderer nodes based on your oderer count at orderer array. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete orderer -n orderer
```

## Configuration

The following table lists the configurable parameters of the Fabric-orderer chart and their default values.

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `nameOverride` | This has to match with Orderer Org name. | `"orderer"` |
| `fullnameOverride` |  | `""` |
| `project` | This will appear in every resource label. This is required. | `"yourproject"` |
| `csr_names_cn` | Country name abbreviation in TWO letter | `"IN"` |
| `csr_names_st` | State | `"Maharashtra"` |
| `csr_names_l` | Locality | `"Mumbai"` |
| `csr_names_o` | Organization Name | `"Your Company Name"` |
| `filestore_endpoint` | Filestore endpoint with `http/s://fqdn:port ` format. | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https. | `false` |
| `ica_tls_cert_file` | Path for the init container to pull public key cert of `global.ica_endpoint` | `"/root/ica-cert.pem"` |
| `orderer_cert_base_dir` | Path to store the orderer enrollement certs | `"/var/hyperledger/orderer"` |
| `orderer_data_dir` | Path to store the orderer data | `"orderer_data_dir"` |
| `retry_seconds` | Seconds to retry after any init container HLF activitity failures; Eg; enrollement | `60` |
| `hlf_domain` | The FQDN for the orderers. It should match with the channel config entries | `"my-hlf-domain.com"` |
| `init.image.repository` | The init container image repository | `"npcioss/hlf-builder"` |
| `init.image.tag` | The init container image tag | `2.4` |
| `orderers` | The list of orderer identities to deploy | `[]` |
| `orderers.[].name` | The name of the orderer | `` |
| `orderers.[].identity_name` | The identity of orderer | `` |
| `orderers.[].identity_secret` | The identity password of orderer | `` |
| `orderers.[].identity_secret` | The identity password of orderer | `` |
| `orderers.[].tls_cert_archive` | The tls cert archive file name of orderer in the filestore | `` |
| `orderers.[].block_file` | The genesis block file name in the filestore if want to override `global.block_file` | `` |
| `orderers.[].renew_orderer_certs` | If `true`, on startup the init container will remove the existing enrolled certs and do fresh enrollment | `` |
| `orderers.[].use_existing_pvc_data` | If want to mount an existing orderer pvc instead of creating new pvc. | `` |
| `orderers.[].additionalEnvironmentVars` | If want to add additional env variables per orderer | `` |
| `global.containerPort` | Default Orderer container port | `7050` |
| `global.servicePort` | Default Orderer k8s service port | `7050` |
| `global.replicaCount` | Orderer replica count. Only 1 per orderer is supported as of now | `1` |
| `global.ica_endpoint` | MSPCA Server endpoint with port (without http/s) | `"ica-orderer.my-hlf-domain.com:30000"` |
| `global.tlsca_endpoint` | TLSCA server endpoint with port (without http/s) | `"tls-ca.my-hlf-domain.com:30000"` |
| `global.block_file` | Default genesis block file name in the filestore | `"genesis.block"` |
| `global.require_certs_dir_persistence` | Whether PVC support is required for enrolled certificate directory for all orderers. This can be set per orderer too. | `true` |
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
