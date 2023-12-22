# Falcon fabric-ca by NPCI

Falcon fabric-ca is a helm chart to deploy Hyperledger Fabric-ca server into any kubernetes flavoured cluster. 

## Introduction

This chart can deploy the Hyperledger Fabric-ca server in various modes. Example; as a Parent CA or an Intermediate CA server.  

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10.1+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

Download the `falcon fabric-ca` charts repo locally:

To install the chart with the release name `root-ca`:

```bash
$ helm install root-ca -n orderer helm-charts/fabric-ca -f examples/fabric-ca/root-ca.yaml
```

This above command deploys one instance of Falcon fabric-ca on the Kubernetes cluster in the orderer namespace. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the release:

```bash
$ helm delete root-ca -n orderer 
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `imagePullSecrets` | Container image pull secret | `[]` |
| `nameOverride` | To partially override the release name | `""` |
| `fullnameOverride` | To completely override the release name | `""` |
| `project` | Any name for your project | `""` |
