# Demo Observability & UX (Keycloak + multi-tenant views)

## Scope

This document defines how demo users "experience" shared tooling
as if it were dedicated per-tenant.

## Keycloak integration targets
- Grafana: OIDC (native)
- Argo CD: SSO (OIDC via Dex or direct, plus RBAC)
- Loki: behind an Auth Proxy that performs OIDC and injects tenant identity

## Multi-tenant UX model

### Argo CD (shared)
- One AppProject per tenant (e.g., `tenant-123`)
- RBAC restricts visibility and actions to that project
- Tenant user sees only their Applications and destinations

### Grafana (shared)
- One folder (or org) per tenant
- Dashboards are scoped by tenant labels (namespace/vcluster/tenant label)
- Tenant user cannot edit datasources or query arbitrary namespaces

### Loki (shared)
- Auth Proxy authenticates user via Keycloak
- Proxy injects `X-Scope-OrgID=<tenant-id>` for Loki queries
- Tenant user can only query logs within their tenant scope

## Evidence collection sources (demo)
- Logs: Loki (primary for diagnosis)
- Metrics: Prometheus (minimal context: restarts, phase, OOMKilled, cpu/mem if available)

## Alert ingress
- Alertmanager sends webhook to PathOps
- PathOps does not own alert evaluation

## Routing
Tenant application URLs follow the flat hostname convention:
`<env>-<app>-<tenant>.demo.pathops.io` and are covered by a single wildcard TLS certificate.