# [Docs](./README.md)
# Golden Path Autopilot Flow
## Alert → evidence → fix proposal → PR (least privilege)

This document describes the Golden Path autopilot workflow for the demo.

Key constraints:
- Only Jenkins clones GitLab
- Only Jenkins modifies GitOps repositories
- Only Jenkins pushes images to Harbor
- Only Argo CD applies workloads to Kubernetes (GitOps boundary)
- Evidence and patch payloads live in MinIO
- Agents run in an app-specific agents namespace

---

## 0) Namespace conventions (demo)

App: `shop-frontend`

- Preflight namespace: `shop-frontend-preflight`
- Production namespace: `shop-frontend-production`
- Agents namespace: `shop-frontend-agents`

Agents always run in `shop-frontend-agents` and target the appropriate app namespace.

---

## 1) High-level sequence

1. Alertmanager notifies PathOps of an incident
2. PathOps triggers Jenkins to schedule Evidence Collector (via GitOps change)
3. Jenkins commits a gitops change to launch Evidence Collector job in `shop-frontend-agents`
4. Argo CD syncs and runs Evidence Collector (reads target namespace)
5. Evidence Collector stores snapshot in MinIO and notifies PathOps (`snapshot_id`)
6. PathOps triggers Jenkins to build a Fix Agent image that embeds the source code at the exact commit SHA
7. Jenkins pushes the Fix Agent image to Harbor
8. Jenkins commits a gitops change to launch Fix Agent job in `shop-frontend-agents`
9. Argo CD syncs and runs Fix Agent
10. Fix Agent produces a patch bundle in MinIO and notifies PathOps (`patch_id`)
11. PathOps requests Jenkins to create a MR from the patch bundle
12. Jenkins creates the MR in GitLab and notifies PathOps with MR link/status

---

## 2) Detailed step-by-step flow

### Step 1 — Incident signal arrives (Alertmanager → PathOps)
Alertmanager sends:
- `POST https://control-plane.pathops.io/webhooks/alertmanager`

PathOps records:
- incident event
- affected app/environment
- preliminary correlation info (namespace/workload/labels)

---

### Step 2 — PathOps requests evidence capture (PathOps → Jenkins)
PathOps triggers Jenkins job: `schedule-evidence-collector`

Parameters:
- `app = shop-frontend`
- `env = preflight|production`
- `incident_id`
- `target_namespace = shop-frontend-preflight|shop-frontend-production`
- `agents_namespace = shop-frontend-agents`
- `time_window`

---

### Step 3 — Jenkins modifies gitops to launch Evidence Collector
Jenkins clones:
- `shop/shop-frontend-gitops` (**only Jenkins may clone GitLab**)

Jenkins commits a change that declares an Evidence Collector Job in:
- `shop-frontend-agents`

Evidence Collector targets:
- `shop-frontend-preflight` or `shop-frontend-production`

Job config includes:
- image: `harbor.demo.pathops.io/pathops/evidence-collector:<tag>`
- env:
  - `INCIDENT_ID`
  - `APP_ID=shop-frontend`
  - `TARGET_NAMESPACE`
  - `TIME_WINDOW`
  - `MINIO_ENDPOINT=https://minio.demo.pathops.io`
  - `MINIO_BUCKET=pathops-evidence`
  - `CONTROL_PLANE_CALLBACK_URL=https://control-plane.pathops.io/api/evidence/callback`

Jenkins pushes to GitLab.

---

### Step 4 — Argo CD syncs and runs Evidence Collector
Argo CD reconciles the gitops repo and runs Evidence Collector in:
- `shop-frontend-agents`

Evidence Collector uses cross-namespace read-only access to:
- read logs/events/descriptions from `TARGET_NAMESPACE`

It uploads payload to MinIO and obtains `snapshot_id`.

Then it notifies PathOps:
- `POST https://control-plane.pathops.io/api/evidence/callback`
  - `{ incident_id, snapshot_id, summary, pointers }`

---

### Step 5 — PathOps triggers Fix Agent build pipeline (PathOps → Jenkins)
PathOps triggers Jenkins job: `build-fix-agent`

Parameters:
- `app = shop-frontend`
- `src_repo = shop/shop-frontend`
- `source_commit_sha = <sha from the affected workload>`
- `snapshot_id`
- `harbor_repo = harbor.demo.pathops.io/pathops/agents`

Jenkins clones src repo at the exact commit SHA and builds an image:
- Fix Agent runtime + embedded source code at that commit

Then Jenkins pushes to Harbor.

---

### Step 6 — Jenkins modifies gitops to launch Fix Agent
Jenkins clones:
- `shop/shop-frontend-gitops`

Jenkins commits a change that declares a Fix Agent job in:
- `shop-frontend-agents`

Job config includes:
- image:
  - `harbor.demo.pathops.io/pathops/agents/fix-shop-frontend:<tag>`
- env:
  - `SNAPSHOT_ID`
  - `MINIO_ENDPOINT=https://minio.demo.pathops.io`
  - `MINIO_BUCKET=pathops-evidence`
  - `CONTROL_PLANE_CALLBACK_URL=https://control-plane.pathops.io/api/fix/callback`

Pushes to GitLab.

---

### Step 7 — Argo CD runs Fix Agent job
Argo CD syncs and runs Fix Agent in:
- `shop-frontend-agents`

Fix Agent:
- downloads evidence snapshot from MinIO using `snapshot_id`
- analyzes and proposes a fix
- produces a patch bundle:
  - uploads to MinIO
  - obtains `patch_id`
- sends callback to PathOps:
  - `POST https://control-plane.pathops.io/api/fix/callback`
  - `{ incident_id, patch_id, summary, recommended_checks }`

---

### Step 8 — PathOps creates Change Set and requests MR creation (PathOps → Jenkins)
PathOps creates a Change Set and attaches:
- incident id
- snapshot id
- patch id
- commit SHA
- target repo

PathOps triggers Jenkins job: `create-mr-from-patch`

Parameters:
- `src_repo = shop/shop-frontend`
- `source_commit_sha`
- `patch_id`
- MR title/body template fields

---

### Step 9 — Jenkins creates MR in GitLab and notifies PathOps
Jenkins:
- clones src repo (allowed)
- checks out `source_commit_sha`
- downloads and applies patch bundle
- creates branch: `cs-<id>-fix-<slug>`
- pushes branch
- creates Merge Request via GitLab API
- posts MR link back to PathOps:
  - `POST https://control-plane.pathops.io/webhooks/jenkins`
  - `{ changeset_id, mr_url, status }`

PathOps updates the Change Set state and surfaces links in UI/chat.

---

## 3) Preflight validation flow (Verification Agent)

After a successful preflight deploy, PathOps requires post-deploy verification.

### Summary
1. Argo deploys app to `shop-frontend-preflight`
2. Jenkins commits a gitops change to run Verification Agent in `shop-frontend-agents`
3. Verification Agent runs probes/tests against preflight
4. Results are stored (optional) and posted back to PathOps

Verification Agent callback:
- `POST https://control-plane.pathops.io/api/verification/callback`

Payload (example):
- `{ app_id, env=preflight, verification_id, status, report_id? }`

---

## 4) Patch bundle transport (REST vs MinIO)

### Preferred (MVP-safe): Patch Bundle in MinIO
- Fix Agent uploads `patch.tar.gz` (or `patch.zip`) to MinIO
- Fix Agent sends `patch_id` to PathOps
- PathOps passes `patch_id` to Jenkins
- Jenkins downloads patch bundle and applies it

This avoids large payloads in the Control Plane and creates an auditable artifact.

### Optional optimization: REST patch for small fixes
For small diffs, Fix Agent may POST a patch inline to PathOps:
- `POST /api/fix/patch-inline`
But the system should always support the MinIO bundle path.