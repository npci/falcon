Fabric-ops
===========

A Helm chart for performing various Fabric CA Server operations Kubernetes.

### Supports the following operations

- [x] [Identity registration](#Identity-registration-Configuration) [Supported types: ica, admin, client, peer, orderer]
- [x] [Genesis block creation](#Genesis-block-creation)
- [x] [Channel creation](#Channel-creation)
- [x] [Anchorpeer list update on channel](#AnchorPeer-update-on-channel)
- [x] [Adding Orgs to channel](#Adding-Orgs-to-channel)
- [x] [Chaincode installation](#Chaincode-installation)
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

## Identity registration

The following table lists the configurable parameters of the Fabric-ops chart for Identity registration.

| Parameter                        | Description             | Default        |
| -------------------------------- | ----------------------- | -------------- |
| `fabric_actions.identity` | `true` to specify the job is an identity registration job | `true` |
| `ca_endpoint` | FQDN of the CA server endpoint with port. `Eg; ica-org1.my-hlf-domain.com:30000` | `""` |
| `ca_secret` | The kubernetes secret contains the CA username and password at `user` and `password` keys. | `""` |
| `identities` | The array of identities with identity information. [Refer](#Identity-array-example) | `[]` |

#### Identity array example;

```bash
identities:
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

## Genesis block creation

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.cryptogen` | `true` to specify the job is a cryptogen job | `true` |
| `organizations` | The array to specify the Orderer organization and Initial peer org. [Refer](#Cryptogen-array-example)  | `[]` |
| `channel_artifact_dir` | Directory in which the channel artifacts will be generated inside the job pod | `"/scripts/channel-artifacts"` |
| `base_dir` | Base directory for all identity registration inside the job pod | `"/scripts/crypto-config"` |
| `orderer_system_channel` | Orderer system channel name | `"orderer-sys-channel"` |
| `hlf_channel` | Application channel name | `""` |
| `block_file` | Genesisblock file name to be generated | `"genesis.block"` |
| `config_transaction_filename` | Channel transaction file name to be generated | `"channel.tx"` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | FQDN of filestore server endpoint with port | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https. | `false` |


#### Cryptogen array example;

```bash
organizations:
  - org_type: orderer
    org_name: orderer
    ica_endpoint: ica-orderer.my-hlf-domain.com:30000
    cert_path: /root/orderer.pem
    admin_identity: admin
    admin_secret: ordererAdminpassword
    orderer_identities:
    - identity_name: orderer0-orderer
      identity_secret: orderer0ordererSamplePassword
      port: "30000"
    - identity_name: orderer1-orderer
      identity_secret: orderer1ordererSamplePassword
      port: "30000"
    - identity_name: orderer2-orderer
      identity_secret: orderer2ordererSamplePassword
      port: "30000"
  - org_type: peerorg
    org_name: initialpeerorg
    ica_endpoint: ica-initialpeerorg.my-hlf-domain.com:30000
    cert_path: /root/peerorg.pem
    admin_identity: admin
    admin_secret: initialpeerorgAdminSamplePassword
    anchor_peers:
    - host: peer0-initialpeerorg.my-hlf-domain.com
      port: "30000"
```

## Channel creation

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.create_channel` | `true` to specify the job is a channel creation job | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `""` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `config_transaction_filename` | Transaction filename in the filestore project dirctory | `"channel.tx"` |
| `channel_block_filename` | Initial channel block filename to be created and uploaded to filestore project dirctory | `""` |
| `hlf_channel` | Application channel name | `""` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |

#### Admin-identity;

```bash
admin_identity:
  - identity_name: admin
    identity_secret: initialpeerorgAdminSamplePassword
    require_msp_enrollment: true
    require_tls_enrollment: false
```

## AnchorPeer update on channel

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.update_anchor_peer` | `true` to specify the job is an anchor peer update job | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `""` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `hlf_channel` | The channel to update | `""` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |
| `anchor_peers` | Anchor peer lists. [Refer](#Anchorpeer-list-format) | `[]` |

#### Anchorpeer list format;

```bash
anchor_peers:
   - host: peer0-initialpeerorg.my-hlf-domain.com
     port: "30000"
   - host: peer1-initialpeerorg.my-hlf-domain.com
     port: "30000"
   - host: peer2-initialpeerorg.my-hlf-domain.com
     port: "30000"
```

## Adding Orgs to channel

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.configure_org_channel` | `true` to specify the job is to add new org | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `"ica-initialpeerorg.my-hlf-domain.com:30000"` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `hlf_channel` | The channel to update | `""` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |
| `organizatons` | List of organizations to add. [Refer](#Organization-list-format) | `[]` |

#### Organization list format;

```bash
organizatons:
 - name: org1
   ica_endpoint: ica-org1.my-hlf-domain.com:30000
   identity_name: admin
   identity_secret: org1AdminSamplePassword
   anchor_peer: peer0-org1.my-hlf-domain.com
   anchor_peer_port: 30000
 - name: org2
   ica_endpoint: ica-org2.my-hlf-domain.com:30000
   identity_name: admin
   identity_secret: org2AdminSamplePassword
   anchor_peer: peer0-org2.my-hlf-domain.com
   anchor_peer_port: 30000
```

## Chaincode installation

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.install_chaincode` | `true` to specify the job is to install chaincode | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `"ica-initialpeerorg.my-hlf-domain.com:30000"` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `channel_block_filename` | Initial application channel block file name in filestore under project directory | `"mychannel.block"` |
| `retry_seconds` | Retry period in seconds for any failed script activities. Eg; enrollment  | `10` |
| `cc_tar_file` | ChainCode file name in the filestore under project directory | `"basic-chaincode_go_1.0.tar.gz"` |
| `hlf_channel` | Application channel name the peer needs to join | `""` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |
| `peer_identities` | List of peer endpoints to install chaincode. [Refer](#Peer-list-example) | `[]` |

#### Peer list example;

```bash
peer_identities:
 - identity_name: peer0-initialpeerorg
   # peer_endpoint: peer0-initialpeerorg.my-hlf-domain.com:30000 # By default it will use identity_name:peer_internal_service_port
 - identity_name: peer1-initialpeerorg
 - identity_name: peer2-initialpeerorg
 ```

 