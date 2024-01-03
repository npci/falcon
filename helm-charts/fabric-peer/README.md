Fabric-peer
===========

A Helm chart for deploying Fabric Peers in Kubernetes.

## Introduction

This chart can deploy Hyperledger Fabric-Peer nodes in kubernetes. 

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress

## Installing the Chart

Download the `falcon fabric-peer` charts repo locally:

To install the chart with the release name `peer`:

```bash
$ helm install peer -n peerorg helm-charts/fabric-peer/ -f values.yaml
```

This above command deploys the peer nodes based on your peer count at peer array. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete peer -n peerorg

## Configuration

The following table lists the configurable parameters of the Fabric-peer chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `"initialpeerorg"` |
| `fullnameOverride` |  | `""` |
| `project` |  | `"yourproject"` |
| `imagePullSecrets` |  | `[]` |
| `csr_names_cn` |  | `"IN"` |
| `csr_names_st` |  | `"Maharashtra"` |
| `csr_names_l` |  | `"Mumbai"` |
| `csr_names_o` |  | `"Your Company Name"` |
| `init.image.repository` |  | `"npcioss/hlf-builder"` |
| `init.image.tag` |  | `2.4` |
| `ica_tls_certfile` |  | `"/tmp/ca-cert.pem"` |
| `tlsca_tls_certfile` |  | `"/tmp/tlsca-cert.pem"` |
| `fabric_base_dir` |  | `"/etc/hyperledger/fabric"` |
| `retry_seconds` |  | `60` |
| `peers` |  | `[]` |
| `global.hlf_domain` |  | `"my-hlf-domain.com"` |
| `global.ica_endpoint` |  | `"ica-initialpeerorg.my-hlf-domain.com:30000"` |
| `global.tlsca_endpoint` |  | `"tls-ca.my-hlf-domain.com:30000"` |
| `global.storageClass` |  | `"standard"` |
| `global.ingressEnabled` |  | `true` |
| `global.ingressClass` |  | `"nginx"` |
| `global.ingressPort` |  | `30000` |
| `global.ingress.annotations.nginx.ingress.kubernetes.io/ssl-passthrough` |  | `"true"` |
| `global.imageRegistry` |  | `"hyperledger"` |
| `global.imagePullPolicy` |  | `"IfNotPresent"` |
| `global.serviceAccount.annotations` |  | `[]` |
| `global.operations.serviceName` |  | `"operations"` |
| `global.operations.serviceType` |  | `"ClusterIP"` |
| `global.operations.servicePort` |  | `9443` |
| `global.metrics.provider` |  | `"disabled"` |
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
| `global.useCouchDB` |  | `true` |
| `global.couchImageRegistry` |  | `"docker.io"` |
| `global.couchImageRepo` |  | `"couchdb"` |
| `global.couchImageTag` |  | `"3.1.1"` |
| `global.couchContainerPort` |  | `"5984"` |
| `global.couchServiceType` |  | `"ClusterIP"` |
| `global.couchServicePort` |  | `"5984"` |
| `global.couchDataDir` |  | `"/opt/couchdb/data"` |
| `global.couchDiskSize` |  | `"1G"` |
| `global.couchPvcAccessMode` |  | `"ReadWriteOnce"` |
| `global.couchDbUser` |  | `"couchDbSampleUser"` |
| `global.couchDbUserPass` |  | `"couchDbSampleUserPassword"` |
| `global.couchSecurityContext` |  | `{}` |
| `global.couchResources` |  | `{}` |
| `global.peerImageRegistry` |  | `"docker.io"` |
| `global.peerImageRepo` |  | `"hyperledger/fabric-peer"` |
| `global.peerImageTag` |  | `2.4` |
| `global.peerContainerPort` |  | `"7051"` |
| `global.peerDataDir` |  | `"/var/hyperledger/production"` |
| `global.peerServiceType` |  | `"ClusterIP"` |
| `global.peerServicePort` |  | `"30002"` |
| `global.peerDiskSize` |  | `"1G"` |
| `global.peerCertDiskSize` |  | `"50M"` |
| `global.peerPvcAccessMode` |  | `"ReadWriteOnce"` |
| `global.peerArgs` |  | `["peer", "node", "start"]` |
| `global.core_peer_gossip_bootstrap` |  | `"peer0-initialpeerorg.my-hlf-domain.com:30000"` |
| `global.core_ledger_state_couchdbconfig_requesttimeout` |  | `"180s"` |
| `global.core_ledger_state_couchdbconfig_maxretries` |  | `"5"` |
| `global.core_ledger_state_couchdbconfig_maxupdatebatchsize` |  | `"5000"` |
| `global.core_ledger_state_couchdbconfig_internalquerylimit` |  | `"5000"` |
| `global.core_ledger_state_couchdbconfig_totalquerylimit` |  | `"5000"` |
| `global.core_ledger_state_couchdbconfig_couchdbaddress` |  | `"localhost:5984"` |
| `global.peerSecurityContext` |  | `{}` |
| `global.peerResources` |  | `{}` |
| `global.dindImageRegistry` |  | `"docker.io"` |
| `global.dindImageRepo` |  | `"npcioss/dind"` |
| `global.dindImageTag` |  | `"dind-20-10-16"` |
| `global.dindDataDir` |  | `"/var/lib/docker"` |
| `global.dindDiskSize` |  | `"5G"` |
| `global.dindPvcAccessMode` |  | `"ReadWriteOnce"` |
| `global.dindDocker_tls_certdir` |  | `""` |
| `global.dindSecurityContext.privileged` |  | `true` |
| `global.dindResources` |  | `{}` |
| `additionalEnvironmentVars.peer` |  | `[]` |