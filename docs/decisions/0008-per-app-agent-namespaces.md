# Decision 0008 — Per-app agent namespaces and cross-namespace evidence collection

## Status
Accepted

## Context

PathOps runs operational agents in Kubernetes:
- Evidence Collector Agent
- Verification Agent (post-deploy checks)
- Fix Agent (autopilot fix proposal)

A key design question is:
- should agents run in a shared global namespace (ex: `pathops-agents`)?
- or should agents run in an app-specific namespace (ex: `shop-frontend-agents`)?

Another question:
- should Evidence Collector run inside the target incident namespace?
- or run elsewhere while reading the target namespace?

The demo prioritizes:
- least privilege
- clarity of ownership boundaries
- operational reliability

## Decision

1) Agents run in an **app-specific agents namespace**:
- `<app>-agents`
Example: `shop-frontend-agents`

2) Application environments run in dedicated namespaces:
- `<app>-preflight`
- `<app>-production`

3) Evidence Collector runs in `<app>-agents` and reads the target namespace
(`preflight` or `production`) using **cross-namespace read-only RBAC**.

Agents do not run inside the incident namespace by default.

## Rationale

Per-app agent namespaces provide:
- strong isolation between apps
- simpler least-privilege RBAC scoping
- easier quota and policy enforcement
- clearer operational ownership

Running Evidence Collector in `<app>-agents` (instead of the incident namespace):
- avoids failures caused by broken namespace conditions (quotas, policies, network rules)
- centralizes operational configuration (images, tolerations, service accounts)
- keeps app namespaces free of operational jobs

Cross-namespace read-only RBAC satisfies evidence needs while limiting risk.

## Consequences

### Enabled
- clearer security model per app
- reduced blast radius
- predictable operational behavior

### Trade-offs
- more namespaces to bootstrap and manage
- requires consistent naming conventions and bootstrap bundles

## Notes

This decision is intended for the Golden Path demo and may remain the default
unless a strong operational reason exists to centralize agents.