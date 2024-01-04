Fabric-tools
===========

A Helm chart for deploying Fabric cli tools in Kubernetes.

## Note

No additional values file required for the fabric-tool. You can simply re-use any of the identity values file with its content.

```bash
$ helm install cli-tools -n initialpeerorg helm-charts/fabric-tools/ -f examples/fabric-ops/initialpeerorg/identities.yaml
```
Once deployed, exec into the pod and run `bash /scripts/enroll.sh` and watch the output. All identities will be enrolled and new certs will be available in the respective directory.

## Configuration

The following table lists the configurable parameters of the Fabric-tools chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `nameOverride` |  | `"initialpeerorg"` |
| `fullnameOverride` |  | `""` |
| `project` |  | `"yourproject"` |
| `imagePullSecrets` |  | `[]` |
| `image.repository` |  | `"npcioss/hlf-builder"` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `image.tag` |  | `"2.4"` |
| `csr_names_cn` |  | `"IN"` |
| `csr_names_st` |  | `"Maharashtra"` |
| `csr_names_l` |  | `"Mumbai"` |
| `csr_names_o` |  | `"Your Company Name"` |
| `hlf_domain` |  | `"my-hlf-domain.com"` |
| `ca_endpoint` | The CA endpoint; Eg; `ica-org.com:30000` | `""` |
| `tlsca_endpoint` | The TLSCA endpoint; Eg; `tlsca-org.com:30000` | `""` |
| `identities` | The identities arrary | `[]` |
| `tools.storageAccessMode` | PVC access mode | `"ReadWriteOnce"` |
| `tools.storageSize` | Storageclass size  | `"5Gi"` |
| `tools.storageClass` | Storageclass name  | `"standard"` |
| `serviceAccount.create` | `true` to create serviceAccount | `true` |
| `serviceAccount.annotations` | serviceAccount annotations | `{}` |
| `serviceAccount.name` | serviceAccount name if want to supply | `""` |
| `podAnnotations` |  | `{}` |
| `podSecurityContext` |  | `{}` |
| `securityContext` |  | `{}` |
| `resources` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |
