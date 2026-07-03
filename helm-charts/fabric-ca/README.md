Fabric-ca
===========

A Helm chart for deploying Fabric CA Server in Kubernetes.

## Introduction

This chart will deploy Hyperledger Fabric-CA node in kubernetes either in standlone mode or Intermediate CA mode. 

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure
- Ingress (Optional and required if name based endpoints are needed.)
- Additionally the following prerequisites must be done before deploying CA with CNI based routing. https://github.com/npci/falcon/tree/main/examples#prerequisite
## Installing the Chart

Download the `falcon fabric-ca` charts repo locally:

To install the chart with the release name `root-ca`:

```bash
$ kubectl create ns orderer
$ kubectl -n orderer create secret generic rca-secret --from-literal=user=rca-admin --from-literal=password=rcaComplexPassword
$ helm install root-ca -n orderer helm-charts/fabric-ca -f examples/fabric-ca/root-ca.yaml
```

This above command deploys the Hyperledger Fabric-CA.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete rootca -n root-ca
```

## Configuration

The following table lists the configurable parameters of the Fabric-ca chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `imagePullSecrets` | Default image pull registry secret | `[]` |
| `additionalLabels` | Additional labels if required | `{}` |
| `project` | Project name string. This will be added to every resource label as `project=yourproject` | `"yourproject"` |
| `replicaCount` | Number of CA pods. HA is not supported with this version | `1` |
| `restartPolicy` | Pod restart policy on failure | `"Always"` |
| `image.repository` | Fabric-ca container image repository | `"hyperledger/fabric-ca"` |
| `image.pullPolicy` | Fabric-ca container image pull policy  | `"IfNotPresent"` |
| `image.tag` | Fabric-ca container image tag | `"1.5.0"` |
| `init.image.repository` | The init container image repository  | `"npcioss/hlf-builder"` |
| `init.image.tag` | The init container image tag | `2.4` |
| `init.image.pullPolicy` | The init container image pull policy | `"IfNotPresent"` |
| `retry_seconds` | Retry period in seconds for any script activities. | `60` |
| `recreate_intermediate_cert` | `true` if parent public key cert needs to be re-created | `false` |
| `tls_domain` | Any resolvable DNS for you CA endpoint | `"my-hlf-domain.com"` |
| `ca_server.csr_names_c` | Country name abbreviation in TWO letter | `"IN"` |
| `ca_server.csr_names_st` | State | `"Maharashtra"` |
| `ca_server.csr_names_l` | Locality | `"Mumbai"` |
| `ca_server.csr_names_o` | Organization Name | `"Your Company Name"` |
| `ca_server.csr_names_ou` | Organization Unit | `"Your Organization Unit"` |
| `ca_server.container_port` | Fabric-ca container port | `7051` |
| `ca_server.debug` | `true` if debug log is required | `true` |
| `ca_server.tls_enabled` | `true` if TLS needs to be enabled | `true` |
| `ca_server.admin_secret` | Username and password required for CA server bootstrapping. | `"rca-secret"` |
| `ca_server.additional_sans` | Additional hostnames if required | `[]` |
| `ica.enabled` | `true` if need to be deployed as an ICA | `false` |
| `ica.parent_ca_endpoint` | If `ica.enabled` is `true`, then provide the parent CA endpoint without http/s and port. Eg; "parentca-endpoint:30000"  | `""` |
| `ica.intermediate_tls_cert_dir` | The directory where the parent CA's public key cert to be fetched and stored | `/tmp/hyperledger/fabric-ca/root-ca-cert` |
| `ica.intermediate_tls_cert_file` | The filename of the parents CA's public key | `cert.pem` |
| `service.type` | kubenetes service type of Fabric-ca | `"ClusterIP"` |
| `service.port` | kubenetes service port of Fabric-ca | `7051` |
| `ingress.enabled` | `true` if ingress is needed | `true` |
| `ingress.className` | Ingress class name | `"nginx"` |
| `ingress.annotations` | Ingress annotations. | `nginx.ingress.kubernetes.io/ssl-passthrough: "true"` |
| `ingress.path` | Default path | `"/"` |
| `ingress.pathType` | Default path type | `"Prefix"` |
| `storage.pvc_enabled` | `true` if PVC support is required for CA data/home directory | `true` |
| `storage.accessMode` | PVC accessmode | `"ReadWriteOnce"` |
| `storage.storageClass` | PVC storageclass | `"standard"` |
| `storage.size` | Storage size of the data/home pvc | `"1G"` |
| `storage.path` | The path on where the PVC should be mounted | `"/tmp/hyperledger/fabric-ca/crypto"` |
| `serviceAccount.create` | `true` if ServiceAccount is required | `true` |
| `serviceAccount.annotations` | Any ServiceAccount annotations | `{}` |
| `serviceAccount.name` | If want to specify specific ServiceAccount name | `""` |
| `resources` | Compute resources for fabric ca container | `[]` |
| `startupProbe` | Default startupProbe | `{}` |
| `livenessProbe` | Default livenessProbe | `{}` |
| `readinessProbe` | Default readinessProbe | `{}` |
| `podAnnotations` | Default podAnnotations | `{}` |
| `podSecurityContext` | Default podSecurityContext | `{}` |
| `securityContext` | Default securityContext | `{}` |
| `affinity` | Default affinity | `{}` |
| `nodeSelector` | Default nodeSelector  | `{}` |
| `tolerations` | Default tolerations | `[]` |
| `certManager.enabled` | Enable cert-manager integration for ingress TLS | `false` |
| `certManager.duration` | Certificate duration (e.g., `2160h` for 90 days) | `2160h` |
| `certManager.renewBefore` | How long before expiry to renew | `360h` |
| `certManager.issuerRef.name` | Name of the cert-manager Issuer or ClusterIssuer | `""` |
| `certManager.issuerRef.kind` | Kind of issuer (`Issuer` or `ClusterIssuer`) | `"Issuer"` |
| `certManager.issuerRef.group` | API group of the issuer | `"cert-manager.io"` |
| `certManager.trustCA.enabled` | Mount parent CA cert for verified ICA enrollment | `false` |
| `certManager.trustCA.secretName` | K8s Secret containing the trusted CA certificate | `""` |
| `certManager.trustCA.caCertPath` | Path where the CA cert is mounted in the pod | `"/etc/ssl/certs/ca-cert.crt"` |
| `certManager.private.enabled` | Use a private CA issuer (non-ACME) | `false` |

## cert-manager Integration

This chart supports [cert-manager](https://cert-manager.io/) for provisioning TLS certificates at the ingress layer. When enabled, cert-manager replaces the `ssl-passthrough` pattern with standard TLS termination.

### Architecture

When `certManager.enabled: true`, the chart creates a `Certificate` CRD that instructs cert-manager to provision a TLS certificate. The ingress terminates TLS using this certificate, and forwards traffic to the Fabric CA pod over HTTPS (the CA pod still uses its own self-signed Fabric TLS certificate internally).

```
External Clients
    |
    v
+----------------------------------+
|   NGINX Ingress Controller        |
|   (cert-manager TLS termination)  |
+----------------------------------+
    |  (backend-protocol: HTTPS)
    v
+----------------------------------+
|   Fabric CA Pod                    |
|   (Fabric CA self-signed TLS)     |
+----------------------------------+
```

**Important:** cert-manager only manages the ingress-facing TLS certificate. Fabric CA's internal TLS (`FABRIC_CA_SERVER_TLS_ENABLED`) and the Fabric PKI hierarchy (root CA, intermediate CA, enrollment certificates) remain unchanged.

### Prerequisites

1. Install cert-manager in your cluster: https://cert-manager.io/docs/installation/
2. Create an Issuer or ClusterIssuer. Examples:

**Let's Encrypt (ACME HTTP01):**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
```

**Self-signed (for testing):**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

**Private CA (e.g., Vault PKI, Smallstep):**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: private-ca-issuer
spec:
  ca:
    secretName: private-ca-key-pair
```

### Deploying with cert-manager (Root CA)

```bash
kubectl create ns orderer
kubectl -n orderer create secret generic rca-secret --from-literal=user=rca-admin --from-literal=password=rcaComplexPassword
helm install root-ca -n orderer helm-charts/fabric-ca -f examples/fabric-ca/root-ca-certmanager.yaml
```

### Deploying with cert-manager (Intermediate CA with trusted CA)

When deploying an ICA with `certManager.trustCA.enabled: true`, the init container verifies the parent CA's certificate instead of using `--insecure`:

1. First, extract the root CA's certificate and create a Secret:
```bash
kubectl -n orderer create secret generic root-ca-cert \
  --from-literal=ca.crt="$(kubectl -n orderer exec root-ca-0 -- cat /tmp/hyperledger/fabric-ca/crypto/ca-cert.pem)"
```

2. Then deploy the ICA:
```bash
helm install ica-orderer -n orderer helm-charts/fabric-ca -f examples/fabric-ca/ica-orderer-certmanager.yaml
```

### Migration from ssl-passthrough

To migrate an existing CA deployment from `ssl-passthrough` to cert-manager:

1. Install cert-manager and create an Issuer/ClusterIssuer
2. Update your values to set `certManager.enabled: true` and configure the issuer
3. Remove `ssl-passthrough` from ingress annotations (it's automatically removed when cert-manager is enabled)
4. Run `helm upgrade`

The chart automatically adds `nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"` when cert-manager is enabled, ensuring the ingress forwards traffic to the CA pod over HTTPS.

### Backward Compatibility

When `certManager.enabled: false` (the default), the chart behaves exactly as before:
- The ingress uses `ssl-passthrough` if specified in annotations
- The ICA init container uses `--insecure` to fetch parent CA certificates
- No Certificate CRD is created
