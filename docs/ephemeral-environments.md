# Ephemeral Environments

Ephemeral environments are temporary deployment environments created automatically for pull requests.

They allow testing a change in a realistic runtime environment before merging.

## Lifecycle

PR opened
→ CI validation
→ environment created
→ application deployed
→ integration tests executed
→ evidence collected
→ environment destroyed

## Implementation strategies

### Namespace per PR

cluster
  ├─ pr-101
  ├─ pr-102

Advantages:
- simple
- fast provisioning

### Virtual cluster per tenant

cluster
  ├─ vcluster-teamA
  ├─ vcluster-teamB

Each PR deploys inside the tenant cluster.

### Sandbox environment

A sandbox may include:

- application services
- database
- message queues
- test runners

## Preview URLs

Each ephemeral environment may expose a temporary URL:

pr-101.demo.example.com