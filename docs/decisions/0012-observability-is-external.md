## Demo UX note

In the demo, shared tooling (ArgoCD, Grafana, Loki) is exposed to users through
tenant-scoped RBAC/views integrated with Keycloak.
This provides a per-tenant experience without duplicating stacks per tenant.