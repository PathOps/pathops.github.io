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