# [Docs](./README.md)
# Apps & Capabilities
## PathOps application and operational capability model

This document describes:
- application modeling
- operational capabilities
- tool bindings
- repositories
- pipelines
- registry organization
- GitOps structure
- operational ownership boundaries

---

# 1) Core idea

PathOps applications are not tightly coupled
to specific vendors or tools.

Applications declare operational needs as
capabilities.

Concrete tools provide those capabilities.

This separation allows:
- portability
- provider replacement
- multi-tool support
- future extensibility

---

# 2) Tenant model

In the current model:

```text
Tenant = user
```

Examples:

```text
alice
bob
```

Tenants represent:

* ownership boundaries
* security boundaries
* operational boundaries

---

# 3) App model

An App represents an operational runtime unit.

Apps are:

* deployable
* observable
* governable
* traceable
* operationally isolated

An App owns:

* repositories
* pipelines
* registry projects
* deployments
* evidence
* operational events

Examples:

```text
api-demo
frontend
billing-service
```

---

# 4) ToolCapability

Applications depend on operational capabilities,
not vendor-specific implementations.

Example capabilities:

```text
SCM
CI_CD
REGISTRY
CD
OBSERVABILITY
SECRETS
AI_RUNTIME
```

---

# 5) Tool

A Tool is a concrete provider implementation.

Examples:

```text
GitLab
Jenkins
Harbor
ArgoCD
Loki
Vault
```

Tools are tenant-scoped resources registered
inside PathOps.

---

# 6) AppToolBinding

Applications bind capabilities to concrete tools.

Example:

```text
api-demo

SCM          -> GitLab Shared
CI_CD        -> Jenkins Shared
REGISTRY     -> Harbor Shared
OBSERVABILITY -> Loki Shared
```

This allows applications to remain provider-agnostic.

---

# 7) Repository model

Applications own repositories.

Repositories are modeled by purpose,
not naming conventions.

---

# 8) RepositoryPurpose

Examples:

```text
SOURCE
GITOPS
DOCS
LOADTESTS
EVIDENCE
```

---

# 9) Recommended GitLab structure

GitLab groups are hierarchical.

Recommended structure:

```text
alice/api-demo/api-demo-source
alice/api-demo/api-demo-gitops
```

Where:

```text
alice
```

represents the tenant boundary.

And:

```text
api-demo
```

represents the application boundary.

---

# 10) GitHub compatibility

GitHub repositories are flatter.

Equivalent naming may be:

```text
alice-api-demo-source
alice-api-demo-gitops
```

PathOps models repository purpose independently
from provider naming constraints.

---

# 11) Source repository

The SOURCE repository contains:

```text
application source code
tests
Dockerfiles
CI configuration
```

Example:

```text
api-demo-source
```

---

# 12) GitOps repository

The GITOPS repository contains:

```text
deployment manifests
helm charts
kustomize overlays
environment configuration
promotion state
```

Example:

```text
api-demo-gitops
```

GitOps repositories are intended to integrate
with systems such as ArgoCD.

---

# 13) Pipeline model

Applications own operational pipelines.

Pipelines are grouped by operational responsibility.

---

# 14) Recommended Jenkins structure

```text
tenants/alice/api-demo/build-pipeline
tenants/alice/api-demo/update-gitops-repo-pipeline
```

This hierarchy expresses:

```text
tenant
→ app
→ operational workflow
```

---

# 15) PipelinePurpose

Pipelines are modeled by purpose.

Examples:

```text
BUILD
DEPLOY
GITOPS_UPDATE
ROLLBACK
SECURITY_SCAN
EVIDENCE_COLLECTION
AI_REMEDIATION
```

PathOps should understand:

* what a pipeline does
* what operational role it serves

not only its URL.

---

# 16) Registry model

Applications own registry projects.

Registry projects are app-scoped.

Recommended Harbor project naming:

```text
alice-api-demo
alice-frontend
```

This avoids global naming collisions.

---


# 19) Registry robot accounts

Robot accounts should be app-scoped,
not tenant-scoped.

Example:

```text
robot$alice-api-demo
```

This improves:

* isolation
* revocation
* rotation
* auditing
* least privilege

---

# 21) PathOps as operational broker

External systems should communicate through PathOps.

Recommended event flow:

```text
GitLab
→ PathOps
→ Jenkins
→ PathOps
→ GitOps
→ ArgoCD
```

PathOps acts as:

* operational timeline
* governance layer
* evidence collector
* AI integration point
* workflow orchestrator

---

# 22) Templates and blueprints

Applications are generated from templates.

Recommended repository:

```text
pathops-templates
```

or:

```text
pathops-blueprints
```

---

# 23) Example template structure

```text
react-nginx/
├── template/
├── ci/
│   └── Jenkinsfile
├── docker/
│   └── Dockerfile
├── gitops/
│   └── deployment.yaml
├── pathops.yaml
```

---

# 24) pathops.yaml

Templates may declare operational requirements.

Example:

```yaml
name: react-nginx

capabilities:
  - SCM
  - CI_CD
  - REGISTRY
  - CD

repositories:
  - SOURCE
  - GITOPS

pipelines:
  - BUILD
  - GITOPS_UPDATE
```

---

# 25) Future direction

This model prepares PathOps for:

* GitOps orchestration
* evidence collection
* operational timelines
* inbox/work queues
* AI-assisted remediation
* autonomous operations
* multi-provider support

without tightly coupling the platform
to any specific vendor implementation.

---

# 26) Summary

PathOps models:

```text
Tenant
→ App
→ Capabilities
→ Tool bindings
→ Repositories
→ Pipelines
→ Registry
→ Deployments
→ Evidence
→ Operational events
```

This creates a portable operational model
that separates:

* operational intent
  from:
* infrastructure implementation.
