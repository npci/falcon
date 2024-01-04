Fabric-ops
===========

A Helm chart for performing various Fabric CA Server operations Kubernetes.

### Supports the following operations

- [x] [Identity registration](#Identity-registration-Configuration) [Supported types: ica, admin, client, peer, orderer]
- [x] Genesis block creation
- [x] Channel creation
- [x] Anchorpeer list update on channel
- [x] Adding Orgs to channel
- [x] Chaincode installation
- [x] Chaincode approval
- [x] Chaincode commit
- [x] Order addition
- [x] Order TLS cert renewal

## Identity registration Configuration

The following table lists the configurable parameters of the Fabric-ops chart for Identity registration.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `"initialpeerorg"` |
| `fullnameOverride` |  | `""` |
| `project` |  | `"yourproject"` |
| `fabric_actions.identity` |  | `true` |
| `imagePullSecrets` |  | `[]` |
| `image.repository` |  | `"npcioss/hlf-builder"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `"2.4"` |
| `csr_names_cn` |  | `"IN"` |
| `csr_names_st` |  | `"Maharashtra"` |
| `csr_names_l` |  | `"Mumbai"` |
| `csr_names_o` |  | `"Your Company Name"` |
| `hlf_domain` |  | `"my-hlf-domain.com"` |
| `ca_endpoint` |  | `"ica-initialpeerorg.my-hlf-domain.com:30000"` |
| `ca_secret` |  | `"initialpeerorg-secret"` |
| `tlsca_endpoint` |  | `"tls-ca.my-hlf-domain.com:30000"` |
| `identities` |  | `[]` |
| `tools.storageAccessMode` |  | `"ReadWriteOnce"` |
| `tools.storageSize` |  | `"5Gi"` |
| `tools.storageClass` |  | `"standard"` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext` |  | `{}` |
| `securityContext` |  | `{}` |
| `resources` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |