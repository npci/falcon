# Proposal: Drunix Deployment Support in Falcon

## Background

Falcon currently provides deployment automation and lifecycle management for Hyperledger Fabric (HLF) based blockchain networks.

Drunix introduces an enhanced blockchain architecture with components such as Validation Service, Committer Service, Endorser Service and supporting infrastructure components including YugabyteDB. Existing Falcon deployment capabilities are focused on traditional Hyperledger Fabric topology and do not currently support deployment and lifecycle management of Drunix based networks.

## Objective

Extend Falcon to support deployment and lifecycle management of Drunix networks while maintaining full compatibility with existing Hyperledger Fabric deployments.

## Problem Statement

Currently there is no standardized deployment mechanism within Falcon for Drunix components.

Users intending to deploy Drunix networks must manually create Kubernetes manifests and deployment configurations, leading to:

* Increased deployment effort
* Configuration inconsistencies
* Longer onboarding time
* Higher operational complexity
* Lack of standardized upgrade and deployment workflows

Additionally, there is currently no mechanism to onboard Drunix components into an existing HLF-based network through Falcon.

## Design Principles

The proposed implementation will follow the following principles:

* Reuse existing Falcon deployment charts and templates wherever possible.
* Extend deployment capabilities through configurable values and conditional templates instead of duplicating charts.
* Maintain backward compatibility with all existing HLF deployment workflows.
* Support both standalone Drunix deployments and hybrid HLF-Drunix deployments.
* Ensure deployment dependencies are provisioned as part of the automation workflow.

## Proposed Solution

Extend Falcon deployment capabilities to support Drunix network deployment.

The implementation will introduce deployment automation for Drunix components by leveraging and extending existing Falcon Helm charts.

Initial scope includes:

* Validation Service deployment
* Endorser Service deployment
* Committer Service deployment
* Gateway deployment
* Configuration management
* Secrets management
* Service discovery
* Health monitoring configuration
* YugabyteDB deployment and configuration
* Version compatibility management

## Supported Deployment Scenarios

### Scenario 1: Existing HLF Deployment

Current Falcon deployment workflow remains unchanged.

### Scenario 2: New Drunix Deployment

Falcon provisions all required Drunix components and supporting infrastructure.

### Scenario 3: Hybrid Deployment

Falcon enables onboarding of Drunix peers and services into an existing HLF based network while maintaining interoperability and operational consistency.

## Deployment Architecture

Falcon will manage deployment of Drunix components through reusable Helm charts and deployment templates.

Deployment artifacts include:

* Reusable Helm Charts
* values.yaml driven configurations
* Kubernetes Deployments
* StatefulSets (where required)
* Services
* ConfigMaps
* Secrets
* PVC definitions
* YugabyteDB deployment components

The implementation will maximize reuse of existing Falcon deployment assets and introduce Drunix specific behavior through configuration driven extensions.

## Deliverables

### Phase 1

* Architecture assessment
* Reusable chart identification
* Base deployment framework
* Validation Service deployment
* Endorser deployment
* Committer deployment

### Phase 2

* Gateway deployment
* Hybrid HLF-Drunix deployment support
* Configuration automation
* Resource management

### Phase 3

* YugabyteDB integration and deployment automation
* Version compatibility validation
* Upgrade strategy implementation
* Documentation

### Phase 4

* Production hardening
* End-to-end deployment validation
* Upgrade and rollback validation

## Version Compatibility

As part of the implementation, existing component versions will be reviewed and upgraded where necessary to ensure compatibility between:

* Falcon
* Hyperledger Fabric
* Drunix components
* YugabyteDB
* Helm chart dependencies

## Benefits

* Standardized Drunix deployment workflow
* Reuse of existing Falcon deployment capabilities
* Support for both HLF and Drunix ecosystems
* Hybrid deployment support
* Reduced operational effort
* Consistent deployment and upgrade process
* Faster onboarding for organizations adopting Drunix

## Risks

* Drunix architecture may evolve during implementation.
* Additional deployment dependencies may be identified during development.
* Hybrid deployment scenarios may introduce integration complexities.

## Testing Plan

* Local validation using Kind cluster
* Multi-node Kubernetes deployment testing
* HLF deployment regression testing
* Drunix deployment validation
* Hybrid deployment validation
* Component health verification
* Upgrade testing
* Rollback testing

## Approval Requested

Approval is requested to proceed with design and implementation of Drunix deployment support within Falcon, including support for standalone Drunix deployments, hybrid HLF-Drunix deployments, deployment dependency automation and version compatibility enhancements.
