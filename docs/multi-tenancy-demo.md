# Multi-Tenancy in the PathOps Demo

## Tenant ownership

Tenants are owned by the PathOps control plane.

Keycloak provides identity,
but tenant lifecycle is managed by PathOps.

In the demo, a tenant may be created automatically when a user logs in for the first time.

## Important scope note

This document describes **demo-only implementation details**.
They do **not** represent requirements or constraints of the PathOps product.

---

## Demo approach

For the demo environment, PathOps uses **virtual clusters (vcluster)** running on top of
a shared Kubernetes host cluster (microk8s).

This approach is used to:

- simulate multi-tenant isolation
- allow self-service user onboarding
- avoid requiring real user-owned clusters during the demo

---

## Demo topology

- One **host Kubernetes cluster** (microk8s)
- One **vcluster per tenent owner**
- Each vcluster contains:
  - `<app>-agents`
  - `<app>-preflight`
  - `<app>-production`

PathOps agents operate **inside the vcluster**, exactly as they would
inside a real user-provided cluster.

---

## Product behavior (non-demo)

In the actual PathOps product:

- PathOps does **not** host Kubernetes clusters
- Users **register their own clusters**
- PathOps connects to and operates on those clusters
- No vcluster technology is required or assumed

vcluster is strictly a **demo scaffolding technique**.

## ArgoCD in the demo

In the demo environment, each tenant vcluster includes its own ArgoCD instance.
This is done to keep the tenant experience self-contained and easy to reason about.

This does not imply that the PathOps product requires or mandates per-tenant ArgoCD.