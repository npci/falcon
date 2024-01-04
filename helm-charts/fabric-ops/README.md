Fabric-ops
===========

A Helm chart for performing various operations in Hyperledger fabric network.

### Supports the following operations

- [x] [Identity registration](#How-to-register-new-identities-) [Supported types: ica, admin, client, peer, orderer]
- [x] [Genesis block creation](#how-to-create-genesis-block--channel-transaction-tx-)
- [x] [Channel creation](#how-to-create-new-channel-in-hyperpedger-fabric-)
- [x] [Anchorpeer list update on channel](#how-to-update-anchorpeer-on-channel-)
- [x] [Adding Orgs to channel](#how-to-add-a-new-org-to-channel-)
- [x] [Chaincode installation](#how-to-install-chaincode-on-peers-)
- [x] [Chaincode approval](#how-to-approve-chaincode-for-an-org-)
- [x] [Chaincode commit](#how-to-commmit-chaincode-from-an-org-)
- [x] [Order addition](#how-to-add-new-order-node-into-a-running-hyperpedger-fabric-network-)
- [x] [Order TLS cert renewal](#how-to-updaterenew-orderer-node-tls-certificates-in-a-running-hyperpedger-fabric-network-)

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
| `ica_tls_certfile` | Public key cert file path of the respective ICA/MSP endpoint | "`/tmp/ca-cert.pem"` |
| `tlsca_tls_certfile` | Public key cert file path of the respective TLSCA endpoint | "`/tmp/tlsca-cert.pem"` |
| `workdir` | The default work directory inside the job container | `"/opt/gopath/src/github.com/hyperledger/fabric"` |
| `peer_internal_service_port` | Port number of peer svc | `"30002"` |



## How to register new identities ?

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

## How to create Genesis block & channel transaction tx ?

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

## How to create new Channel in hyperpedger fabric ?

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

## How to update AnchorPeer on channel ?

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

## How to add a new Org to channel ?

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

## How to install Chaincode on peers ?

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.install_chaincode` | `true` to specify the job is to install chaincode | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `""` |
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

 ## How to approve Chaincode for an Org ?

 | Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.approve_chaincode` | `true` to specify the job is to approve chaincode | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port  | `""` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `hlf_channel` | Application channel name | `""` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `require_collection_config` | `true` if collection config is required | `"true"` |
| `collection_config_file` | Collection config filename in the filestore under the project directory  | `"collection-config.json"` |
| `collection_config_file_hash` | File hash of the above collection config | `""` |
| `core_peer_address` | Core peer address | `"peer0-initialpeerorg:30002"` |
| `cc_name` | Chaincode name  | `"basic-chaincode"` |
| `cc_version` | Chaincode version | `"1.0"` |
| `cc_package_id` | Chaincode package ID | `""` |
| `seq` | Seq number | `"1"` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |


## How to commmit Chaincode from an Org ?

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.commit_chaincode` | `true` to specify the job is to commit chaincode | `true` |
| `ica_endpoint` | FQDN of the MSPCA server endpoint with port | `""` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `hlf_channel` | Application channel name | `""` |
| `require_collection_config` | `true` if collection config is required  | `"true"` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `collection_config_file` | Collection config filename in the filestore under the project directory | `"collection-config.json"` |
| `collection_config_file_hash` | File hash of the above collection config | `""` |
| `core_peer_address` | Core peer address | `"peer0-initialpeerorg:30002"` |
| `cc_name` | Chaincode name | `"basic-chaincode"` |
| `cc_version` | Chaincode version | `"1.0"` |
| `seq` | Seq number | `"1"` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity) | `[]` |


## How to add new Order node into a running hyperpedger fabric network ?

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.add_orderer` | `true` to specify the job is to add new orderer | `true` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `seconds_to_wait_after_channel_update` | Seconds to pause the script/job activity after one channel update | `15` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity-for-order-operation) | `[]` |
| `additional_orderers` | List of additional oderers. Execute one at a time. [Refer](#New-orderer-for-order-addition) | `[]` |
| `MspIdOverride` | To override `nameOverride` with a different MSPID | `""` |

#### Admin identity for order operation;

```bash
admin_identity:
  - identity_name: admin
    identity_secret: ordererAdminpassword
    ica_endpoint: ica-orderer.my-hlf-domain.com:30000
    ica_tls_certfile: /tmp/orderer-ica.cert
    msp_base_dir: /opt/gopath/src/github.com/hyperledger/fabric/orderer/users
    require_msp_enrollment: true
    require_tls_enrollment: false
```

#### New orderer for order addition;

```bash
additional_orderers:
  - identity_name: orderer3-orderer
    identity_secret: orderer3ordererSamplePassword
    require_msp_enrollment: true
    require_tls_enrollment: true
    endpoint: orderer3-orderer.my-hlf-domain.com
    port: 30000
    msp_base_dir: /opt/gopath/src/github.com/hyperledger/fabric/orderer/users
    ica_endpoint: ica-orderer.my-hlf-domain.com:30000
    ica_tls_certfile: /tmp/orderer-ica.cert
    # hlf_domain: If you want to register this orderer with a different hlf domain other than .Values.hlf_domain. Useful when adding new orderers on a different DC and you want to assign a different sub domain for it.
    update_channels:
      - orderer-sys-channel # Orderer system channel
      - mychannel #Application channel
    upload_latest_channel_block_to_filestore:
      - orderer-sys-channel
```

##### Steps to do;
```bash
Example; adding a new orderer3 to the running network.

1. Register the new orderer identity in respective MSP CA.
2. Register the new orderer identity in respective TLSCA. Make sure to use the same identity name and identity secret in both places.
3. Prepare a fabric-ops values files with the new orderer information and orderer admin identity as described above.
4. Run helm install fabric-ops with the this values file and watch the job output and make sure that there is no failures. If all the tasks are success, then you will see the following log at the end;
============ [SUCCESS] Successfully uploaded artifacts of orderer3-orderer to filestore. ============
File hash = 4a9cb5f5fe2b935944813aaa4509d1b3d4f7db562f31b97899a7d8e0fd8e0a43 `orderer3-orderer-orderer-sys-channel_2024_01_04_150835.block`
File hash = 11682afaff1a8dd17970b048c799afedc343259aad16176aba1ac5d322d6a1f4 `orderer3-orderer-tls-certs_2024_01_04_150835.tar.gz`

5. Copy the block file name and orderer tls archive file name from the above job log. This job will upload these files to the filestore registry by default and print it in the output for our reference. 
6. Add the new orderer3 in your fabric-orderer deployment values file by specifing the genesis block file and tls archive file name explicitily since these are not the default one. 

Your fabric-orderer array should look like this for the new orderer.
.
.
.
  - name: orderer3
    identity_name: orderer3-orderer
    identity_secret: orderer3ordererSamplePassword
    block_file: orderer3-orderer-orderer-sys-channel_2024_01_04_150835.block
    tls_cert_archive: orderer3-orderer-tls-certs_2024_01_04_150835.tar.gz

7. Run helm upgrade on your fabric-orderer and check the new orderer logs. Make sure it is joning all the channels and syncing. 
```

## How to update/renew orderer node TLS certificates in a running hyperpedger fabric network ?

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `fabric_actions.renew_orderer_tls` | `true` to specify the job is to renew orderer tls cert | `true` |
| `orderer_endpoint` | FQDN of the Orderer node endpoint with port. Make sure that this orderer should not be the one you're trying to update. | `"orderer0-orderer.my-hlf-domain.com:30000"` |
| `filestore_endpoint` | The filestore endpoint | `"http://filestore.my-hlf-domain.com:30001"` |
| `filestore_ssl` | `true` if `filestore_endpoint` is over https | `false` |
| `seconds_to_wait_after_channel_update` | Seconds to pause the script/job activity after one channel update | `15` |
| `tlsca_endpoint` | FQDN of the TLSCA server endpoint with port | `"tls-ca.my-hlf-domain.com:30000"` |
| `admin_identity` | Any valid Admin user identity array in `ica_endpoint`. [Refer](#Admin-identity-for-order-operation) | `[]` |
| `orderers_to_renew_tls_cert` | List of oderers to renew the tls cert. Execute one at a time. [Refer](#Orderer-renew-order-format) | `[]` |
| `MspIdOverride` | To override `nameOverride` with a different MSPID | `""` |

#### Orderer renew order format;

```bash
## orderers_to_update_tls are the list of orderers you want to renew the certs.
orderers_to_renew_tls_cert:
  - identity_name: orderer1-orderer
    identity_secret: orderer1ordererSamplePassword
    upload_sys_channel_block: true
    endpoint: orderer1-orderer.my-hlf-domain-dc-1.com # This must match to the existing endpoint of the orderer in the channel. 
    msp_base_dir: /opt/gopath/src/github.com/hyperledger/fabric/orderer/users
    ica_endpoint: ica-orderer.my-hlf-domain.com:30000
    ica_tls_certfile: /tmp/orderer-cert.pem
    require_msp_enrollment: true
    require_tls_enrollment: true
    #hlf_domain: my-hlf-domain-dc-1.com # This hlf_domain must match with the existing orderer end-point in the channel. If the default .Values.hlf_domain is different, then it must be specified here. 
    update_channels:
      - orderer-sys-channel
      - mychannel
    upload_latest_channel_block_to_filestore:
      - orderer-sys-channel
```