# [Docs](./README.md)
# PathOps Architecture
## Conceptual Model & Modular Implementation

PathOps is an open source **control plane** for AI-assisted live coding in production.

It is built on a simple mental model:

- **Live coding** is the locomotive: fast, powerful, risky.
- **PathOps** are the rails: guardrails that keep change safe, reviewable, and reversible.

PathOps enforces one fundamental rule:

> **No change reaches production without evidence.**

Evidence can include test results, deployment outcomes, runtime signals, security gates, and snapshots.

This document explains:
- the **conceptual architecture** (entities and boundaries)
- the **modular implementation** (components, responsibilities, suggested technologies)
- the **runtime flow** (feature → chage set → PRs → GitOps → preflight → evidence)

## 1) Conceptual architecture

### 1.1 What PathOps governs
PathOps governs **intent and promotion**, not code generation.

- Humans (and AI tools) can generate changes.
- PathOps decides whether those changes can move forward.
- Production does not apply changes directly.

PathOps integrates with existing tools (CI, Git providers, GitOps controllers, scanners, observability).
It does not replace them.

### 1.2 Core principle boundaries

#### PR-first change
All meaningful change is expressed as pull requests:
- code changes
- pipeline changes
- GitOps desired state changes
- policy changes

If it can’t be reviewed, it can’t ship.

#### GitOps as source of truth
Clusters follow declared state.
Humans and automation modify Git state.
Controllers reconcile it.

#### Evidence before promotion
Promotion decisions must be backed by evidence.
No evidence, no promotion.

#### Humans stay in control
PathOps can propose and automate.
Humans approve and merge—especially for production changes.

## 2) Domain model (nomenclature)

PathOps uses explicit entities to avoid ambiguity.

### User
Interacts via UI/chat.
Defines features and approves/rejects PRs.

### Project
A logical product (e.g., `shop`).
Contains multiple apps and components.
Has exactly one **meta repository**.

### App
A deployable unit (API, frontend, websocket, worker).
Treated as a black box by the coordinator.

### Component
First-class infrastructure (Postgres, Redis, Keycloak, etc.).
Typically Helm charts/manifests.
No business code repository.

### Environment
- **preflight**: automated validation after deploy (not manual staging)
- **production**

### Target Environments

PathOps operates on **logical environments** such as:

- agents
- preflight
- production

How these environments are mapped to Kubernetes constructs
(namespaces, clusters, or virtual clusters)
is considered an **infrastructure concern**.

In the demo environment, these environments are implemented as
namespaces inside a per-user virtual cluster (vcluster).

In the product, these environments live in user-provided clusters.

## 3) Repository model (key decision)

### 3.1 Per app: two repositories

Each app has:

1) **`app-src`**
- application code only  
- `ci/` folder (pipelines, scripts, tests)

2) **`app-gitops`**
- desired state (Kubernetes/Helm/Kustomize)
- reconciled by Argo CD

**Rule:** no human documentation or project meta in these repos.

### 3.2 Per project: one meta repository

One repo per project, e.g. `shop-meta`.

This repo is the single place where humans and PathOps coordinate at the project level.


## 4) Runtime flow (GitOps + evidence)

### 4.1 Build pipeline (in `app-src`)

Typical steps:

* build
* unit tests
* integration tests (mocked edges)
* build & push image

Artifacts are initially marked as **not promotable**.

### 4.2 Deploy pipeline (via GitOps)

* PathOps modifies `app-gitops`
* Argo CD reconciles to the cluster
* Argo CD runs post-deploy jobs in **preflight**

  * health checks
  * smoke tests
  * contract tests

**Decision boundary:**

> Pipelines do not access the cluster.
> Only Argo CD accesses the cluster.

Argo CD reports results back to PathOps via webhooks/events.

## 5) Evidence & snapshots

Every deploy, failure, or incident produces an **Evidence Snapshot**:

* logs
* Kubernetes events
* test results
* basic runtime signals (CPU/mem, etc.)
* links to PRs and commits

Large payloads go to **S3/MinIO**.
The meta repository stores **metadata + links** only.

This is how PathOps turns “automation” into **auditable trust**.

## 6) Agents and responsibilities

Agents are specialized workers that operate only on branches and PRs.

### Agent types

* **Dev Agent** — implements app changes
* **Testing Agent** — creates/adjusts tests
* **Security Agent** — SCA, image scanning, SBOM/policy checks
* **Ops Agent** — runtime signals, rollback, recovery proposals
* **Docs Agent** — contracts, runbooks, documentation updates

**Important constraint:**

> Agents do not orchestrate and do not decide.
> They execute tasks assigned by workflows.

## 7) Coordinator (the project-level planner)

The Coordinator is the high-level planner.

Responsibilities:

* receives a project-level feature request
* analyzes impact using the project meta repo
* treats apps as black boxes
* uses contracts (OpenAPI/AsyncAPI) and declared dependencies
* produces:

  * execution plan
  * tasks per app/component
  * deploy order (dependency graph)

## 8) Modular implementation map (software components)

This section maps the conceptual model into implementation modules.

### 8.1 PathOps Control Plane (the brain)

**Responsibility**

* global system state
* APIs and webhooks
* policy enforcement
* orchestration entry point

**Suggested technologies**

* Spring Boot (REST + webhook endpoints)
* PostgreSQL (persistent state)
* OIDC/Keycloak (auth)
* Vault (minimal secrets: webhook secrets, short-lived tokens)

### 8.2 PathOps Orchestrator (workflow engine)

**Responsibility**

* long-running reliable workflows:

  * feature → change set → PRs → deploy → evidence → close
  * incident → snapshot → recovery PR
* retries, timeouts, compensation paths

**Suggested technology**

* Temporal (core component)

Model:

* Workflows = durable processes
* Activities = concrete steps (create PR, wait Argo, record evidence)

> Temporal is core, not an implementation detail.

### 8.3 Feature Coordinator

**Responsibility**

* converts project-level features into executable plans
* produces tasks per app/component
* computes deploy order (graph)

**Implementation**

* logical service inside the Control Plane (MVP)
* reads:

  * contracts (OpenAPI/AsyncAPI)
  * project status
  * declared dependencies

### 8.4 Agent Runtime (workers)

**Responsibility**

* run tasks against repos and PRs
* never act directly on production

**Suggested technologies**

* Kubernetes workers
* pluggable backends (future):

  * Claude Code
  * OpenAI
  * Aider / Cursor CLI integration

### 8.5 LLM Integration Layer (glue, not magic)

**Responsibility**

* abstracts LLM providers
* controls context selection (files/logs/meta/evidence)
* versions prompts and tool behavior

**Suggested approach**

* thin adapter layer (avoid heavy frameworks in MVP)
* lightweight RAG: meta repo + evidence links + repo content

### 8.6 Event Gateway (ingestion layer)

**Responsibility**

* receives external events:

  * Git provider webhooks
  * Argo CD sync events
  * CI outcomes
  * scanners
  * monitoring alerts

**Suggested technologies**

* Spring Boot webhook service
* optional broker later (RabbitMQ/Kafka)

### 8.7 Incident Manager

**Responsibility**

* classifies alerts (build/deploy/runtime/security)
* opens incidents
* triggers snapshot + Ops Agent + recovery PR workflow

**Integrations**

* Prometheus/Alertmanager
* Sentry
* Dependency Track

### 8.8 Evidence Store (snapshot service)

**Responsibility**

* builds objective “what happened”
* stores large bundles in S3/MinIO
* stores metadata in Postgres
* writes links into meta repo

This component is central to:

* auditability
* debugging
* safe automation

### 8.9 SCM Integration Service

**Responsibility**

* branch creation
* PR creation and comments
* reads checks/statuses

**Suggested technologies**

* GitHub API / GitLab API
* scoped tool tokens

### 8.10 GitOps Bridge (Argo integration)

**Responsibility**

* modifies GitOps repos
* waits for Argo reconciliation
* receives callbacks/webhooks with results

**Suggested technologies**

* Argo CD webhooks + API where needed
* git operations by controlled workers

### 8.11 Identity & Access

**Responsibility**

* user login
* roles (owner, reviewer)
* SSO

**Suggested technologies**

* Keycloak + OIDC providers

### 8.12 PathOps UI (chat-first)

**Responsibility**

* guided chat + navigation (`cd /project/app/env`)
* free text limited to:

  * features
  * bugs
  * read-only queries
* visualization of:

  * Change Sets
  * PRs
  * deploy status
  * evidence

**Suggested technologies**

* Web app (React/Vue/Svelte)
* terminal-like

### 8.13 CLI (optional)

**Responsibility**

* bootstrap projects
* inspect state
* scriptable workflows

**Suggested technologies**

* Go or Node
* talks to Control Plane API

### 8.14 Bootstrap Bundles

**Responsibility**

* install/connect prerequisites:

  * Argo CD
  * namespaces
  * webhooks
  * validations

**Suggested technologies**

* YAML + scripts
* executed via CLI/workers

## 9) The system in one sentence

* **Control Plane decides**
* **Temporal guarantees**
* **Coordinator plans**
* **Agents execute**
* **GitOps deploys**
* **Evidence proves**
* **PRs connect everything**

## 10) What this enables

* AI-assisted change at high speed without losing control
* auditable promotion to production
* preflight validation as a default path
* failures that produce durable artifacts (snapshots)
* recovery via PRs, not hidden patches

## 11) Related docs

* Manifesto: why PathOps exists (`manifesto.md`)
* Principles: non-negotiables (`principles.md`)
* Artifact States: lifecycle model (`artifact-states.md`)
* Glossary: shared terms (`glossary.md`)
* Security: posture (`security.md`)
* Boundaries: what PathOps is not (`what-pathops-is-not.md`)
