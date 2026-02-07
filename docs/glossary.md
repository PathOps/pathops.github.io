# [Docs](./README.md) 
# PathOps Glossary

## App
A deployable unit tracked by PathOps (API, SPA frontend, worker, websocket server, etc.).
Typically maps to one source repository and one GitOps repository.

## Preflight
A deployment environment used to validate reality before production promotion.
Not a long-lived staging environment for manual testing.
Preflight exists to catch deployment/runtime failures early.

## Golden Path
A proven workflow with clear defaults.
Designed to work reliably with AI-assisted coding and production constraints.

## Evidence Snapshot (Snapshot)
A portable bundle that captures “what happened”:
- deploy outcome
- logs/events
- test reports
- relevant metrics
Used for debugging, auditing, and autopilot PR context.

## Autopilot PR
A pull request created by an agent in response to failures or alerts.
It must include evidence and rationale, and it must be reviewable.

## Control Plane
The PathOps service that coordinates workflows, policies, and state machines.

## Bundle
A scriptable set of steps to bootstrap or connect infrastructure:
- installing Argo CD
- wiring webhooks
- creating namespaces
- verifying prerequisites

## Guardrails
Constraints and policies that keep automation safe:
- gates
- quotas
- role boundaries
- required checks
- rollout rules

## Vibe Coding
Exploratory development focused on discovery, not delivery.

## Path-Ready System
An artifact that has entered a governed path and can evolve safely.

## Change Intent
A declared intention to modify a system, evaluated by PathOps.

## Change Context

A structured set of identifiers and metadata that describes what change is being executed, for which artifact, under which path, and in which environment.

Change Context is propagated across pipelines, deploys, and runtime signals to allow PathOps to correlate actions, evidence, and outcomes.

## Change Set
A coordinated set of changes spanning one or more repositories
that must be validated and deployed as a single unit.

A Change Set represents a project-level change transaction.
It has a lifecycle, produces evidence, and completes only
when all affected applications and components are successfully deployed.

More at: [change-sets.md](./change-sets.md) 

---

## Agent
A specialized, single-responsibility workload executed by PathOps
to perform a concrete operational task.

Agents do not orchestrate workflows and do not make promotion decisions.
They execute assigned work and report results back to the Control Plane.

Agents always operate under explicit guardrails and least-privilege credentials.

---

## Evidence Collector Agent
An agent responsible for capturing an **Evidence Snapshot**
when a deploy failure, incident, or alert occurs.

The Evidence Collector:
- runs in the app-specific agents namespace (`<app>-agents`)
- reads the target environment namespace (`<app>-preflight` or `<app>-production`)
  using cross-namespace read-only access
- collects logs, events, and relevant runtime signals
- stores the snapshot payload in object storage (MinIO)
- reports a `snapshot_id` back to the PathOps Control Plane

The Evidence Collector never modifies application state.

---

## Verification Agent
An agent responsible for **post-deploy validation** in the preflight environment.

The Verification Agent runs after a preflight deploy and validates reality using:
- smoke tests
- basic regression checks
- contract checks (optional)
- runtime probes (health, readiness behavior)

The Verification Agent:
- runs in the app-specific agents namespace
- targets the preflight environment
- reports pass/fail results and optional artifacts to PathOps

Verification is required before promotion to production.

---

## Fix Agent
An agent responsible for producing a **proposed fix** in response to
failures, incidents, or alerts.

The Fix Agent:
- runs in the app-specific agents namespace
- consumes an Evidence Snapshot (`snapshot_id`)
- operates on the exact source code state (commit SHA)
- proposes changes within defined guardrails
- produces a Patch Bundle stored in object storage
- reports a `patch_id` and rationale back to PathOps

The Fix Agent does not:
- clone source repositories
- create pull requests
- deploy changes

It proposes fixes; promotion is governed by PathOps.

---

## Patch Bundle
A portable artifact containing a proposed code change produced by a Fix Agent.

A Patch Bundle:
- is typically a compressed diff (e.g. `patch.tar.gz`)
- is stored in object storage (MinIO)
- is referenced by a `patch_id`
- can be downloaded and applied by CI tooling (e.g. Jenkins)

Patch Bundles allow large or complex fixes to be handled without
passing large payloads through the Control Plane API.

---

## snapshot_id
A stable identifier referencing an Evidence Snapshot stored in object storage.

The `snapshot_id` is used to:
- correlate incidents, deploys, and fixes
- provide context to Fix Agents
- attach evidence to Change Sets and pull requests

---

## patch_id
A stable identifier referencing a Patch Bundle stored in object storage.

The `patch_id` is passed between:
- Fix Agents
- PathOps Control Plane
- CI systems (e.g. Jenkins)

It allows fixes to be applied deterministically and auditable.

---

## App Agents Namespace
A Kubernetes namespace dedicated to running PathOps agents for a single app.

Naming convention:
- `<app>-agents`

Examples:
- `shop-frontend-agents`
- `billing-api-agents`

This namespace hosts:
- Evidence Collector jobs
- Verification Agent jobs
- Fix Agent jobs

App agent namespaces provide isolation, clear ownership, and least-privilege RBAC.

---

## Preflight Environment
A deployment environment used to validate reality before production promotion.

Preflight is:
- automatically deployed via GitOps
- validated via Verification Agents
- not intended for manual testing or long-lived staging

Failures in preflight produce evidence and block promotion.

---

## Change Set
A coordinated set of changes spanning one or more repositories
that must be validated and deployed as a single unit.

A Change Set represents a **project-level change transaction**.

It:
- originates from a feature, fix, or incident
- tracks related pull requests
- references evidence (`snapshot_id`)
- references fixes (`patch_id`)
- completes only when all affected components are successfully deployed

Change Sets provide determinism, auditability, and controlled evolution.

### Virtual Cluster (vcluster)

A Kubernetes abstraction used in the PathOps demo to simulate
per-user clusters on top of a shared host cluster.

Not required or assumed by the PathOps product.