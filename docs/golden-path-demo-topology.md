# [Docs](./README.md)
# Golden Path Demo Topology
## Endpoints, roles, and least-privilege responsibilities

This document defines the **demo topology** for PathOps and the minimal set
of external tools required for the Golden Path demo.

It also defines the **least-privilege responsibility graph**:
who can talk to whom, and who can do what.

---

## 1) Public endpoints (demo)

### PathOps
- UI / Chat: `https://demo.pathops.io`
- Control Plane API + Webhooks: `https://control-plane.pathops.io`

### External tools
- GitLab (SCM): `https://gitlab.demo.pathops.io`
- Jenkins (CI): `https://jenkins.demo.pathops.io`
- Keycloak (SSO): `https://sso.demo.pathops.io`
- Harbor (registry): `https://harbor.demo.pathops.io`
- Argo CD (GitOps): `https://argocd.demo.pathops.io`
- Kubernetes API (informational): `https://k8s.demo.pathops.io`
- MinIO (evidence & bundles): `https://minio.demo.pathops.io`

---

## 2) Control Plane surface

### API
- Base: `https://control-plane.pathops.io/api/*`

### Webhooks (incoming)
- GitLab: `https://control-plane.pathops.io/webhooks/gitlab`
- Argo CD: `https://control-plane.pathops.io/webhooks/argocd`
- Alertmanager: `https://control-plane.pathops.io/webhooks/alertmanager`
- Jenkins callbacks: `https://control-plane.pathops.io/webhooks/jenkins`

### Auth callbacks (optional)
- OAuth callback (if needed): `https://control-plane.pathops.io/auth/callback`

---

## 3) Demo app naming (canonical)

For the demo we use:
- GitLab group: `shop`
- App name: `shop-frontend` (React)

Repositories:
- src repo: `shop/shop-frontend`
- gitops repo: `shop/shop-frontend-gitops`

---

## 4) Kubernetes namespace layout

### App namespaces
- preflight: `shop-frontend-preflight`
- production: `shop-frontend-production`

### Agents namespace (per app)
- agents: `shop-frontend-agents`

Rationale:
- operational isolation per app
- least-privilege RBAC per app
- avoid mixing agents from multiple apps in the same namespace

---

## 5) Agents (separate responsibilities)

Agents are executed inside Kubernetes in the app-specific agents namespace.

- Namespace: `shop-frontend-agents`

Agents are separate even if they reuse common code.

### Agent A — Evidence Collector Agent
Purpose:
- capture an Evidence Snapshot when an incident or deploy failure happens

Execution location:
- runs in `shop-frontend-agents`
- reads the target namespace (`shop-frontend-preflight` or `shop-frontend-production`)
  via cross-namespace read-only RBAC

Inputs:
- target app
- environment (preflight / production)
- correlation identifiers (Change Set, deploy ID, commit SHA)
- time window / affected resources

Outputs:
- evidence payload stored in MinIO
- callback to PathOps with `snapshot_id`

### Agent B — Verification Agent (Post-Deploy Checks)
Purpose:
- validate reality after a preflight deploy using checks and probes

Execution location:
- runs in `shop-frontend-agents`
- targets `shop-frontend-preflight` workloads/endpoints

Typical checks:
- smoke tests / HTTP probes
- basic regression checks
- contract checks (optional)
- readiness behavior verification (pragmatic)

Outputs:
- verification report (optional payload in MinIO)
- callback to PathOps with pass/fail + links

### Agent C — Fix Agent (Autopilot fix proposal)
Purpose:
- produce a proposed fix based on:
  - evidence snapshot
  - the exact source code state (commit SHA)

Execution location:
- runs in `shop-frontend-agents`

Inputs:
- `snapshot_id` (MinIO)
- `source_commit_sha`
- guardrails/policies (what is allowed)

Outputs:
- **Patch Bundle** stored in MinIO (`patch_id`)
- callback to PathOps with:
  - `patch_id`
  - summary / rationale
  - recommended checks/tests

> Important policy: Agents do not clone GitLab.
> “Only Jenkins clones GitLab” is enforced.

---

## 6) Least-privilege responsibility graph (canonical)

### GitLab
- Emits webhooks to PathOps (MR/push events)
- Does not call Jenkins, Harbor, Argo, or MinIO directly

### Alertmanager
- Emits alerts to PathOps only

### PathOps Control Plane
- Orchestrates workflows and decisions
- Stores state and audit trail
- Receives webhooks and signals
- Requests actions from Jenkins (via job triggers)
- Does NOT:
  - clone GitLab
  - push to Harbor
  - modify GitOps repos
  - apply to Kubernetes directly

### Jenkins (the “builder/operator”)
**The only tool allowed to:**
- clone repositories from GitLab (src and gitops)
- push images to Harbor
- create/update Merge Requests in GitLab
- commit changes to gitops repos

Jenkins does NOT apply to Kubernetes directly.

### Argo CD (the “only cluster actor”)
**The only tool allowed to:**
- reconcile declared GitOps state into Kubernetes
- deploy workloads, including agent jobs, via GitOps sync

### MinIO
- Stores:
  - Evidence Snapshots (payload)
  - Patch Bundles (payload)
  - Optional verification reports (payload)
- Receives uploads from in-cluster agents
- May be read by Jenkins (download patch bundles) and PathOps (metadata/links)

---

## 7) Credential ownership rules

### Credentials for PathOps → Tool
Provided by the user/operator at registration time:
- GitLab PAT
- Jenkins API token
- Argo CD token (or SSO-based token)
- Harbor robot account/token
- MinIO access/secret

PathOps stores these credentials in Vault.

### Credentials for Tool → PathOps
Generated by PathOps:
- webhook secrets (ex: GitLab `X-Gitlab-Token`)
- callback tokens for tools that support it (ex: Jenkins callback)

PathOps stores these in Vault and may generate bundles/instructions
to configure the tool.

---

## 8) Patch transport rule (important)

Fixes can be small or large.

- For **small patches**, PathOps may accept an inline patch via REST as an optimization.
- For **large patches**, the Fix Agent stores a **Patch Bundle** in MinIO and sends only `patch_id`.

Jenkins downloads the patch bundle using `patch_id`, then applies it to a clone of the repo at the exact commit SHA.