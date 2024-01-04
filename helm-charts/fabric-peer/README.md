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

> **NOTICE**: You must register the peer identities with respective MSP and TLSCA using the fabric-ops `identity` job.

Download the `falcon fabric-peer` charts repo locally:

To install the chart with the release name `peer`:

```bash
$ helm install peer -n initialpeerorg helm-charts/fabric-peer/ -f examples/fabric-peer/initialpeerorg/values.yaml
```

This above command deploys the peer nodes based on your peer count at peer array. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete peer -n initialpeerorg
```

## Configuration

The following table lists the configurable parameters of the Fabric-peer chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` | This has to match with Peer Org name | `"initialpeerorg"` |
| `fullnameOverride` | Helm default | `""` |
| `project` | Project name string. This will be added to every resource label as `project=yourproject` | `"yourproject"` |
| `imagePullSecrets` | The container registry imagePullSecrets | `[]` |
| `csr_names_cn` | Country name abbreviation in TWO letter | `"IN"` |
| `csr_names_st` | State | `"Maharashtra"` |
| `csr_names_l` | Locality | `"Mumbai"` |
| `csr_names_o` | Organization Name | `"Your Company Name"` |
| `init.image.repository` | The init container image repository | `"npcioss/hlf-builder"` |
| `init.image.tag` | The init container image tag | `2.4` |
| `ica_tls_certfile` | Path for the init container to store the public key cert of `global.ica_endpoint` | `"/tmp/ca-cert.pem"` |
| `tlsca_tls_certfile` | Path for the init container to store the public key cert of `global.tlsca_endpoint` | `"/tmp/tlsca-cert.pem"` |
| `fabric_base_dir` | Path to store the `msp/tls` enrollment certificates | `"/etc/hyperledger/fabric"` |
| `retry_seconds` | Retry period in seconds for any script activities. Eg; enrollment | `60` |
| `peers` | The list of Peer identities to deploy | `[]` |
| `peers.[].name` | The name of the peer | `peer[n]` |
| `peers.[].identity_name` | The identity of peer | `""` |
| `peers.[].identity_secret` | The identity password of peer | `""` |
| `peers.[].additionalLabels` | The identity password of peer | `""` |
| `peers.[].useCouchDB` | `true` if couchdb container should be added to every peer | default `.Values.global.useCouchDB` |
| `peers.[].couchImageRegistry` | CouchDb image registry | default `.Values.global.couchImageRegistry` |
| `peers.[].couchImageRepo` | CouchDb image repo | default `.Values.global.couchImageRepo` |
| `peers.[].couchImageTag` | CouchDb image tag | default `.Values.global.couchImageTag` |
| `peers.[].couchDbUser` | CouchDb DB user | default `.Values.global.couchDbUser` |
| `peers.[].couchDbUserPass` | CouchDb DB user password | default `.Values.global.couchDbUserPass` |
| `peers.[].additionalEnvironmentVars.couchDb` | CouchDb DB additional env variable | default `{}` |
| `peers.[].couchStartupProbe` | CouchDb startuprobe | default `.Values.couchStartupProbe` |
| `peers.[].couchLivenessProbe` | CouchDb livenessprobe | default `.Values.couchLivenessProbe` |
| `peers.[].couchReadinessProbe` | CouchDb readinessprobe | default `.Values.couchReadinessProbe` |
| `peers.[].disableDefaultCouchStartupProbe` | `true` to disable default CouchDb StartupProbe | default `.Values.global.disableDefaultCouchStartupProbe` |
| `peers.[].disableDefaultCouchLivenessProbe` | `true` to disable default CouchDb LivenessProbe | default `.Values.global.disableDefaultCouchLivenessProbe` |
| `peers.[].disableDefaultCouchReadinessProbe` | `true` to disable default CouchDb ReadinessProbe | default `.Values.global.disableDefaultCouchReadinessProbe` |
| `peers.[].couchResources` | CouchDb resources | default `.Values.global.couchResources` |
| `peers.[].couchContainerPort` | CouchDb container port | default `.Values.global.couchContainerPort` |
| `peers.[].couchUseExistingPvcPrefix` | If you want to use an existing pvc for Couch. A pvc must exists with this prefix and its fullname must match with the redered pod name under this statefulset | `"data-couchdb"` |
| `peers.[].couchDataDir` | CouchDb data directory| default `.Values.global.couchDataDir` |
| `peers.[].dindImageRegistry` | Dind image registry | default `.Values.global.dindImageRegistry` |
| `peers.[].dindImageRepo` | Dind image repo | default `.Values.global.dindImageRepo` |
| `peers.[].dindImageTag` | Dind image tag | default `.Values.global.dindImageTag` |
| `peers.[].dindDocker_tls_certdir` | Dind docker tls directory | default `.Values.global.dindDocker_tls_certdir` |
| `peers.[].additionalEnvironmentVars.dind` | Dind DB additional env variable | default `{}` |
| `peers.[].dindStartupProbe` | Dind startuprobe | default `.Values.dindStartupProbe` |
| `peers.[].dindLivenessProbe` | Dind livenessprobe | default `.Values.dindLivenessProbe` |
| `peers.[].dindReadinessProbe` | Dind readinessprobe | default `.Values.dindReadinessProbe` |
| `peers.[].disableDefaultDindStartupProbe` | `true` to disable default Dind StartupProbe | default `.Values.global.disableDefaultDindStartupProbe` |
| `peers.[].disableDefaultDindLivenessProbe` | `true` to disable default Dind LivenessProbe | default `.Values.global.disableDefaultDindLivenessProbe` |
| `peers.[].disableDefaultDindReadinessProbe` | `true` to disable default Dind ReadinessProbe | default `.Values.global.disableDefaultDindReadinessProbe` |
| `peers.[].dindResources` | Dind resources | default `.Values.global.couchResources` |
| `peers.[].dindUseExistingPvcPrefix` | If you want to use an existing pvc for Dind. A pvc must exists with this prefix and its fullname must match with the redered pod name under this statefulset | `"data-dind"` |
| `peers.[].dindDataDir` | Dind data directory| default `.Values.global.dindDataDir` |
| `peers.[].peerImageRegistry` | Peer image registry | default `.Values.global.peerImageRegistry` |
| `peers.[].peerImageRepo` | Peer image repo | default `.Values.global.peerImageRepo` |
| `peers.[].peerImageTag` | Peer image tag | default `.Values.global.peerImageTag` |
| `peers.[].peerContainerPort` | Peer container port| default `.Values.global.peerContainerPort` |
| `peers.[].peerServicePort` | Peer service tag | default `.Values.global.peerServicePort` |
| `peers.[].peerImageTag` | Peer image tag | default `.Values.global.peerImageTag` |
| `peers.[].core_peer_gossip_bootstrap` | Core peer endpoint for bootstrapping | default `.Values.global.core_peer_gossip_bootstrap` |
| `peers.[].core_ledger_state_couchdbconfig_requesttimeout` | Couchdb requesttimeout | default `.Values.global.core_ledger_state_couchdbconfig_requesttimeout` |
| `peers.[].core_ledger_state_couchdbconfig_maxretries` | Couchdb maxretries | default `.Values.global.core_ledger_state_couchdbconfig_maxretries` |
| `peers.[].core_ledger_state_couchdbconfig_maxupdatebatchsize` | Couchdb maxupdatebatchsize | default `.Values.global.core_ledger_state_couchdbconfig_maxupdatebatchsize` |
| `peers.[].core_ledger_state_couchdbconfig_internalquerylimit` | Couchdb internal querylimit  | default `.Values.global.core_ledger_state_couchdbconfig_internalquerylimit` |
| `peers.[].core_ledger_state_couchdbconfig_totalquerylimit` | Couchdb total querylimit | default `.Values.global.core_ledger_state_couchdbconfig_totalquerylimit` |
| `peers.[].core_ledger_state_couchdbconfig_couchdbaddress` | Couchdb address | default `.Values.global.core_ledger_state_couchdbconfig_couchdbaddress` |
| `peers.[].additionalEnvironmentVars.peer` | Peer additional env variable | default `{}` |
| `peers.[].peerStartupProbe` | Peer startuprobe | default `.Values.peerStartupProbe` |
| `peers.[].peerLivenessProbe` | Peer livenessprobe | default `.Values.peerLivenessProbe` |
| `peers.[].peerReadinessProbe` | Peer readinessprobe | default `.Values.peerReadinessProbe` |
| `peers.[].disableDefaultPeerStartupProbe` | `true` to disable default Peer StartupProbe | default `.Values.global.disableDefaultPeerStartupProbe` |
| `peers.[].disableDefaultPeerLivenessProbe` | `true` to disable default Peer LivenessProbe | default `.Values.global.disableDefaultPeerLivenessProbe` |
| `peers.[].disableDefaultPeerReadinessProbe` | `true` to disable default Peer ReadinessProbe | default `.Values.global.disableDefaultPeerReadinessProbe` |
| `peers.[].peerResources` | Peer resources | default `.Values.global.peerResources` |
| `peers.[].peerDataDir` | Peer data directory| default `.Values.global.peerDataDir` |
| `peers.[].peerUseExistingPvcPrefix` | If you want to use an existing pvc for Peer. A pvc must exists with this prefix and its fullname must match with the redered pod name under this statefulset | `"data-peer"` |
| `global.hlf_domain` | The FQDN suffix for the peers. | `"my-hlf-domain.com"` |
| `global.ica_endpoint` | MSPCA Server endpoint with port (without http/s) | `"ica-initialpeerorg.my-hlf-domain.com:30000"` |
| `global.tlsca_endpoint` | TLSCA server endpoint with port (without http/s) | `"tls-ca.my-hlf-domain.com:30000"` |
| `global.storageClass` | Default Storageclass name | `"standard"` |
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