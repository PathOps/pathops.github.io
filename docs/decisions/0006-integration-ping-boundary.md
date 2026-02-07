# Decision 0006 — Integration connectivity boundary (and SCM special case)

## Status
Accepted

## Context

PathOps integrates with multiple external tools such as:
- SCM providers
- GitOps controllers
- CI systems
- artifact registries

A naive approach would attempt to verify:
- network reachability between tools
- permission correctness across platforms
- full end-to-end pipeline wiring

This turns PathOps into a platform installer and oversteps its responsibility.

A clearer boundary is required.

Additionally, SCM providers (GitLab/GitHub) rely on event-driven webhooks,
which are not always "pingable" through a generic endpoint.

## Decision

PathOps validates **only**:
- PathOps ↔ Tool connectivity when a bidirectional ping is available
- SCM webhook delivery via SCM-provided webhook test endpoints

PathOps does NOT validate:
- tool-to-tool communication
- CI pipeline correctness
- registry permissions
- cluster networking between third-party tools

### SCM special case (GitLab)
For GitLab, PathOps validates webhook connectivity by triggering:
- `POST /projects/:id/hooks/:hook_id/test/:trigger` :contentReference[oaicite:7]{index=7}

and verifying the resulting delivery at PathOps’ webhook endpoint.

## Rationale

This approach:
- validates what PathOps actually depends on
- avoids implicit assumptions about infrastructure
- prevents PathOps from enforcing topology decisions
- keeps integrations simple and extensible

SCM providers already expose official mechanisms to test webhook delivery.
Using those mechanisms is more reliable than inventing synthetic pushes.

## Consequences

### Enabled
- Clear and enforceable responsibility boundary
- Deterministic doctor checks
- Scalable integration model for new tools
- SCM webhook validation without repo pollution

### Explicitly out of scope
- Tool-to-tool connectivity checks
- Network diagnostics beyond PathOps endpoints
- Automated remediation across platforms

These concerns may be addressed by other tools, but not by PathOps.