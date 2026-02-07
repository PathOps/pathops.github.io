# Decision 0007 — Least-privilege tool graph for Golden Path demo

## Status
Accepted

## Context

PathOps integrates multiple tools (SCM, CI, GitOps, registry, storage, alerts).
A naive implementation tends to share powerful credentials across components
or allow the control plane to directly operate clusters and repositories.

This increases blast radius and breaks PathOps principles:
- PR-first change
- GitOps boundary
- minimal surface area
- auditability

The demo requires a clear, enforceable permissions model.

## Decision

Adopt a strict **least-privilege tool graph** for the Golden Path demo:

- **Only Jenkins may clone GitLab repositories** (src and gitops).
- **Only Jenkins may modify GitOps repositories**.
- **Only Jenkins may push images to Harbor**.
- **Only Argo CD may apply changes to Kubernetes** (GitOps reconciliation boundary).
- **Agents run in-cluster**, in a dedicated namespace, and do not hold SCM write credentials.
- Evidence and patch payloads are stored in MinIO; Control Plane passes references (IDs), not large payloads.

PathOps Control Plane:
- orchestrates decisions and state
- triggers Jenkins jobs
- receives webhooks and callbacks
- does not directly operate Git repositories or the Kubernetes API for deploy actions.

## Rationale

This model:
- minimizes credential exposure
- preserves clear responsibility boundaries
- makes the demo architecture easy to explain
- aligns with “Integrate, don’t replace”
- keeps PathOps focused on governance and evidence

Enforcing “only Jenkins clones GitLab” prevents accidental distribution of SCM access
to in-cluster agents and reduces the risk of credential leakage.

Storing evidence and patches in MinIO avoids oversized payloads and preserves
portable, auditable artifacts.

## Consequences

### Enabled
- Smaller blast radius
- Clear ownership boundaries between tools
- Deterministic “who did what” audit trail
- Scalable addition of new agents without expanding SCM privileges

### Trade-offs
- Additional Jenkins steps (clone/build/push) for agent execution
- Slightly higher workflow complexity, offset by strong security posture

## Notes

This decision is scoped to the Golden Path demo, but it is intended to remain
the default model unless a strong reason exists to relax boundaries.