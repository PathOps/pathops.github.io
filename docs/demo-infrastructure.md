# Demo Infrastructure (VirtualBox now, DigitalOcean later)

## Overview

The demo environment runs on 6 VMs.
The design separates:
- Edge routing
- SCM + CI
- Shared infrastructure (auth/secrets/registry/object storage/observability shared UIs)
- Kubernetes runtime hosting vclusters for tenant apps

## VM layout (6 machines)

> IP range suggestion: 192.168.1.0/24
> Each VM has a static IP and DNS is configured accordingly.

### VM1 — edge-gateway
**Role**
- Single entry point for HTTP(S)

**Software**
- Nginx (reverse proxy)
- TLS termination (Let’s Encrypt or self-signed for local)
- Routes subdomains to services (GitLab, Jenkins, Keycloak, Grafana, ArgoCD, PathOps APIs)

**Specs**
- vCPU: 1–2
- RAM: 1–2 GB
- Disk: 20–30 GB

---

### VM2 — scm-gitlab
**Role**
- Git repositories + PR/MR workflow
- Source of truth for demo GitOps repos

**Software**
- GitLab (CE/EE depending on availability)
- Container registry optional (can prefer Harbor instead)

**Specs**
- vCPU: 2–4
- RAM: 4–8 GB (GitLab likes RAM)
- Disk: 80–200 GB (repos + artifacts; more if you store a lot)

---

### VM3 — ci-jenkins
**Role**
- CI pipelines, build/test, artifact creation
- Container builds/pushes to Harbor

**Software**
- Jenkins
- Docker (or podman)
- Build cache volumes

**Specs**
- vCPU: 2–4
- RAM: 4–8 GB
- Disk: 60–200 GB (depends on build artifacts)

---

### VM4 — k8s-shared-infra
**Role**
- Shared infrastructure services (used by all tenants)
- Shared UIs integrated with Keycloak

**Runs on microk8s**
- Keycloak + Postgres (PV)
- Vault (PV)
- Harbor (PV)
- MinIO (PV)
- Loki (shared, multi-tenant)
- Grafana (shared, multi-tenant view)
- Argo CD (shared, multi-tenant view)
- Prometheus + Alertmanager + kube-state-metrics (shared)

**Specs**
- vCPU: 4–8
- RAM: 16–32 GB (depends on how much you log/retain)
- Disk: 200–500 GB (or attach volumes; Loki retention drives this)

---

### VM5 — k8s-pathops-control-plane
**Role**
- PathOps control plane services

**Runs on microk8s**
- PathOps API
- Event store (DB) + PV
- Workflow engine (e.g., Temporal) + PV (if used)
- Webhook ingress (alerts)
- Agent orchestration components

**Specs**
- vCPU: 2–4
- RAM: 4–8 GB
- Disk: 60–150 GB

---

### VM6 — k8s-tenant-runtime (apps host cluster)
**Role**
- Hosts vclusters (one per tenant) for app runtime and agents

**Runs on microk8s**
- vcluster platform controller
- Ingress controller (for tenant apps if needed)
- Promtail (DaemonSet) shipping node logs to Loki
- Tenant vclusters (k3s control planes)

**Specs**
- vCPU: 4–16 (depends on number of concurrent tenants)
- RAM: 16–64 GB (this is the primary tenant scaling lever)
- Disk: 100–300 GB

## DigitalOcean sizing (recommended baseline)

For an initial public demo:
- VM6 should be scaled up first.
- VM4 is second priority (logs/metrics retention).

Suggested starting point:
- VM6: 8 vCPU / 32 GB RAM
- VM4: 8 vCPU / 32 GB RAM
- Others: as above.

## Tenant capacity (rule of thumb)

With shared ArgoCD + shared Prometheus/AM/KSM + shared Loki/Grafana,
a tenant consumes mainly:
- vcluster overhead
- the tenant app + agents

Typical demo tenant footprint (light workload): ~0.5–1.0 GB RAM each.

Approx ranges (conservative):
- VM6 16 GB RAM: ~10–20 light tenants
- VM6 32 GB RAM: ~25–45 light tenants
- VM6 64 GB RAM: ~60–100 light tenants

These numbers assume strict resource limits for tenant workloads and a small number of pods per tenant.

## DNS & TLS (demo)

### Wildcard DNS
We use a wildcard record:
`*.demo.pathops.io -> Edge public IP`

### Wildcard TLS certificate
A single wildcard certificate is issued for:
`*.demo.pathops.io`

TLS terminates at the Edge Gateway (Nginx). All per-tenant URLs are flattened
into a single label, e.g.:
`preflight-shop-frontend-tango-otter.demo.pathops.io`