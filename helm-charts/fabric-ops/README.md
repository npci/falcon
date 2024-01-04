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

#### The following parameters are common across all fabric-ops job.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` | Replace with the Org name | `""` |
| `fullnameOverride` | Helm default to override the resournce name if needed | `""` |
| `project` | Your project name. | `"yourproject"` |
| `fabric_actions` | Unique for every job type | `` |
| `imagePullSecrets` | Image pull secret  | `[]` |
| `image.repository` | Image repository of the builder container | `"npcioss/hlf-builder"` |
| `image.pullPolicy` | Image pull policy | `"IfNotPresent"` |
| `image.tag` | Image tag | `"2.4"` |
| `csr_names_cn` | Country name abbreviation in TWO letter | `"IN"` |
| `csr_names_st` | State | `"Maharashtra"` |
| `csr_names_l` | Locality | `"Mumbai"` |
| `csr_names_o` | Organization name | `"Your Company Name"` |
| `hlf_domain` | The FQDN suffix will be used in CSR generation. Eg `peer0-prg1.my-hlf-domain.com` | `"my-hlf-domain.com"` |

## Identity registration Configuration

The following table lists the configurable parameters of the Fabric-ops chart for Identity registration.

| Parameter                        | Description             | Default        |
| -------------------------------- | ----------------------- | -------------- |
| `fabric_actions.identity` | `true` to specify the job is an identity registration job | `true` |
| `ca_endpoint` | FQDN of the CA server endpoint with port. `Eg; ica-org1.my-hlf-domain.com:30000` | `""` |
| `ca_secret` | The kubernetes secret contains the CA username and password at `user` and `password` keys. | `""` |
| `identities` | The array of identities with identity information. [Refer](#Identity-array-example) | `[]` |
| `identities.[].identity_name` | Identity name | `""` |
| `identities.[].identity_secret` | Identity password | `""` |
| `identities.[].identity_type` | Identity type `ica,peer,orderer etc` | `""` |

#### Identity array example;

```bash
$ identities:
  - identity_name: ica-orderer
    identity_secret: icaordererSamplePassword
    identity_type: ica
  - identity_name: admin
    identity_secret: ordererAdminpassword
    identity_type: admin
  - identity_name: orderer0-orderer
    identity_secret: orderer0ordererSamplePassword
    identity_type: orderer
  - identity_name: peer10-org
    identity_secret: peer10orgSamplePassword
    identity_type: peer
```