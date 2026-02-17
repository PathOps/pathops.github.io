# Tenant Routing & TLS (Demo)

## Goal

Provide per-tenant, per-app, per-environment URLs that are:
- easy to read and remember
- safe (no email/PII in URLs)
- operationally simple for TLS
- compatible with "shared tools + multi-tenant views"

## Naming convention

### Hostname format (single-label wildcard friendly)

We use a **single label** under `demo.pathops.io` by flattening components with dashes:

`<env>-<app>-<tenant>.demo.pathops.io`

Examples:
- `preflight-shop-frontend-tango-otter.demo.pathops.io`
- `production-shop-frontend-tango-otter.demo.pathops.io`
- `agents-shop-frontend-tango-otter.demo.pathops.io`

### Why not use multiple subdomain levels?

A wildcard certificate for `*.demo.pathops.io` only covers **one subdomain level**:
- ✅ `anything.demo.pathops.io`
- ❌ `a.b.c.demo.pathops.io`

Using a flat naming scheme allows us to use **a single wildcard certificate**
for the entire demo.

## Tenant identifier strategy

We separate:
- **tenantId** (internal, stable): UUID/KSUID used for correlation and partitioning
- **tenantSlug** (external, friendly): used in hostnames and UI

### tenantSlug
- generated on registration as a readable slug (e.g., `tango-otter`)
- must be unique
- can optionally be user-editable (with strict validation)

### Security/Privacy note
We do NOT use sanitized email addresses as hostname components to avoid exposing PII.

## TLS strategy

### Single wildcard certificate

We issue a single wildcard cert covering:

- `*.demo.pathops.io`

This certificate is used at the **Edge Gateway** (Nginx) for TLS termination.

### Termination model

- TLS terminates at the Edge Gateway (Nginx)
- From edge → internal services, we can use:
  - HTTP (demo simplicity), or
  - internal TLS (optional later)

## DNS strategy

### Production-like (recommended on a cloud provider)

Create a wildcard DNS record:

- `*.demo.pathops.io  -> <Edge Public IP>`

This ensures any tenant hostname resolves automatically.

### Local / VirtualBox

For local demos, use either:
- a local DNS (recommended), or
- `/etc/hosts` entries for the few hostnames you want to demo

## Routing strategy

### Edge routing (Nginx)

Edge routes traffic by the hostname convention:

`<env>-<app>-<tenant>.demo.pathops.io`

Edge then forwards to the appropriate backend:
- tenant runtime ingress (host cluster)
- or a tenant router component (optional)

### Mapping tenantSlug -> tenant runtime target

PathOps maintains (or can derive) a mapping:
- tenantSlug -> tenantId
- tenantId -> vcluster name / namespace scope
- env/app -> in-cluster service/ingress

The mapping can be stored as:
- a PathOps internal record
- or a Git-tracked registry for demo reproducibility

## Examples

### Example: one tenant, one app

Tenant:
- tenantSlug: `tango-otter`
App:
- `shop-frontend`
Environments:
- preflight / production / agents

URLs:
- `preflight-shop-frontend-tango-otter.demo.pathops.io`
- `production-shop-frontend-tango-otter.demo.pathops.io`
- `agents-shop-frontend-tango-otter.demo.pathops.io`

## Operational notes

### Certificate automation

- In cloud: prefer DNS-based validation to issue/renew wildcard certificates.
- In local: self-signed certs are acceptable for a demo.

### Rate limits / safety

Avoid generating certificates per-tenant or per-hostname.
Use a single wildcard certificate to keep TLS stable and predictable.

## Summary

- Use flat hostnames: `<env>-<app>-<tenant>.demo.pathops.io`
- Use one wildcard cert: `*.demo.pathops.io`
- Use tenantSlug for friendliness, tenantId for internal stability
- Terminate TLS at the edge and route by hostname