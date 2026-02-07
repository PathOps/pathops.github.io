# [Docs](./README.md)
# Integrations
## External tools registry and connectivity model

PathOps integrates with external tools to govern change,
but it does not replace them.

This document defines:
- what an Integration is
- what PathOps is responsible for validating
- what PathOps explicitly does NOT validate
- how PathOps validates tool connectivity
- special rules for SCM providers (GitLab/GitHub)

---

## 1) What is an Integration

An **Integration** is a registered external tool that interacts with PathOps.

Examples:
- SCM providers (GitLab, GitHub)
- GitOps controllers (Argo CD)
- CI systems (Jenkins, GitHub Actions)
- Artifact registries (Harbor)
- Object storage (MinIO) (for evidence payloads)

An Integration represents:
- an endpoint
- credentials
- declared capabilities
- connectivity state with PathOps

Integrations are **first-class entities** in PathOps.

---

## 2) Responsibility boundary

PathOps has a strict responsibility boundary.

### PathOps IS responsible for:
- validating that it can authenticate to a tool (when applicable)
- validating that the tool can authenticate back to PathOps (when applicable)
- tracking availability and last-seen status
- recording integration health as evidence

### PathOps is NOT responsible for:
- verifying tool-to-tool connectivity (ex: Jenkins → Harbor)
- validating network paths between third-party tools
- certifying CI pipeline correctness or registry permissions
- enforcing organizational SCM topology

> PathOps governs change execution, not platform wiring.

---

## 3) Connectivity checks: two patterns

PathOps supports two categories of integration checks:

### A) Direct ping (bidirectional challenge/response)

This pattern applies to tools that expose an endpoint PathOps can call,
and that can call back into PathOps.

Goal:
1. PathOps can reach the tool
2. The tool can reach PathOps
3. Auth works both ways

This is appropriate for tools where a "ping endpoint" can be implemented
(or reasonably exists).

---

### B) SCM webhook delivery test (special case)

SCM providers are different.

A project webhook is usually triggered by events like:
- push
- merge request
- pipeline

So the correct test is not a generic "ping endpoint", but a **webhook delivery test**
triggered via the SCM API.

For GitLab, PathOps uses GitLab’s API endpoint:
- **Trigger a test project webhook**
  - `POST /projects/:id/hooks/:hook_id/test/:trigger` :contentReference[oaicite:0]{index=0}

This causes GitLab to send a real webhook delivery to PathOps without requiring
a real push.

---

## 4) Security model

Integrations should use scoped credentials where possible.

For SCM webhooks:
- GitLab supports a secret token configured on the webhook.
- GitLab sends it as a header (`X-Gitlab-Token`) on deliveries. :contentReference[oaicite:1]{index=1}

PathOps must:
- validate the webhook token
- correlate deliveries to a test challenge when running `doctor`

---

## 5) GitLab integration details (demo)

### Demo endpoints
- GitLab base URL: `https://gitlab.demo.pathops.io`
- GitLab API base: `https://gitlab.demo.pathops.io/api/v4`

### Webhook configuration (project hook)
PathOps expects the webhook to point to:

- PathOps webhook endpoint (example):
  - `https://demo.pathops.io/webhooks/gitlab`

Webhook can be created through the GitLab API:
- `POST /projects/:id/hooks` :contentReference[oaicite:2]{index=2}
with:
- `url`: PathOps endpoint
- `token`: secret token for PathOps to validate (`X-Gitlab-Token`) :contentReference[oaicite:3]{index=3}
- trigger flags like `push_events` or `merge_requests_events` :contentReference[oaicite:4]{index=4}

---

## 6) Doctor behavior

The `pathops doctor` command:
- runs connectivity checks for registered integrations
- reports reachability and authentication status
- does NOT test tool-to-tool relations

For GitLab SCM:
- doctor triggers a webhook delivery test using:
  - `POST /projects/:id/hooks/:hook_id/test/:trigger` :contentReference[oaicite:5]{index=5}
- PathOps waits for the delivery at `/webhooks/gitlab`
- PathOps validates:
  - webhook secret token (`X-Gitlab-Token`) :contentReference[oaicite:6]{index=6}
  - correlation to the test (challenge ID)

Doctor never applies fixes automatically.
It may generate fix bundles or instructions.

---

## 7) Summary

- Integrations are explicit and registered
- PathOps validates connectivity to itself, not tool-to-tool wiring
- SCM is a special case: validate webhook delivery via SCM test endpoints
- GitLab supports API-triggered webhook tests
- Doctor provides evidence-driven setup validation

This keeps PathOps opinionated, focused, and trustworthy.