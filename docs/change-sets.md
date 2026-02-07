# [Docs](./README.md)
# Change Sets
## Governing human-authored and opaque changes

PathOps governs **change**, not conversations.

In modern workflows, changes may be authored:
- by humans using local IDEs (Cursor, VS Code, Vim)
- by AI-assisted tools
- by agents operating inside PathOps
- or by any combination of the above

PathOps does **not** attempt to observe or capture private authoring interactions.
Instead, it governs the **observable outcomes**:
branches, pull requests, checks, deployments, and evidence.

This document defines how **Change Sets** work when authoring is partially or fully opaque.

## 1) What a Change Set represents

A **Change Set** is the core unit of change in PathOps.

A Change Set is:
- a **project-level change transaction**
- spanning one or more repositories
- validated and deployed as a single unit
- completed only when all required evidence is produced

A Change Set has:
- a lifecycle
- explicit state
- evidence
- reversibility expectations

PathOps treats Change Sets as first-class objects, regardless of how the code was written.

## 2) The problem of opaque authoring

When a user clicks a deep-link and opens:
- Cursor
- VS Code
- a local terminal
- any external editor

PathOps **cannot and should not** know:
- what was typed
- what prompts were used
- what internal reasoning occurred

This is not a limitation.
It is a **boundary**.

> PathOps governs outcomes, not private drafting.

The system must remain correct and auditable even when authoring is opaque.

## 3) Creating a Change Set before code exists

A Change Set is created **as soon as the user declares intent**, not when code appears.

Example:
- user clicks **“New change”**
- user provides a short intent description
- PathOps immediately creates a Change Set

At this point:
- no code may exist
- no commits may exist
- no PR may exist

This Change Set is still valid.

It represents **intent + ownership**, not implementation.

## 4) Externally authored (opaque) Change Sets

PathOps explicitly models authoring mode and observability.

### Recommended attributes

- `authoring_mode`:  
  `human | agent | mixed`

- `observability`:  
  `opaque | observed`

An externally authored Change Set is typically:

- `authoring_mode: human`
- `observability: opaque`

This means:
- PathOps does not know how the change was produced
- PathOps will rely **entirely on evidence** to evaluate promotion

Opaque does **not** mean ungoverned.

## 5) Branch and PR creation strategy

### Core rule
**Every Change Set must anchor to observable Git artifacts.**

### Recommended flow

1. User clicks **New change**
2. PathOps:
   - creates Change Set `CS-0042`
   - creates a branch: `cs-0042/<slug>`
   - creates a PR/MR immediately
3. UI presents:
   - link to the PR
   - deep-link to open the branch in the user’s editor

This ensures:
- traceability from the first moment
- a stable anchor for all future evidence

## 6) Initial commit as a Change Context anchor

To ensure branches and PRs can always be created, PathOps may create
a **minimal initial commit**.

Example:

```

.pathops/changeset.yaml

```

With content like:

```yaml
id: CS-0042
intent: "Add rate limiting to checkout API"
created_by: user
authoring_mode: human
observability: opaque
created_at: 2026-02-05T12:34:00Z
```

This commit:

* does not contain business logic
* does not change system behavior
* exists only to anchor traceability

Keeping this file in the repo is recommended.

## 7) Detecting progress without observing authoring

PathOps updates Change Set state using **SCM events**, not IDE telemetry.

Signals include:

* push to branch
* new commits
* PR updated
* checks started / completed
* merge events

Typical state transitions:

```
draft/opened
  → in_progress        (first push / commit)
  → validating         (CI running, PR ready)
  → deploying_preflight
  → completed | failed | rolled_back
```

No direct knowledge of authoring steps is required.

## 8) Evidence expectations for opaque Change Sets

When authoring is opaque, PathOps compensates by requiring **stronger evidence**.

Examples:

* mandatory CI success
* mandatory contract tests
* mandatory preflight validation
* stricter policy gates

This preserves trust without violating privacy or boundaries.

## 9) Change Sets in the project meta repository

Even if PathOps stores full state in a database, the **project meta repository**
acts as an auditable, portable record.

Recommended structure:

```
shop-meta/change-sets/CS-0042/
├─ status.yaml
├─ pr-links.md
└─ evidence-links.md
```

The meta repo contains:

* what a human would review
* summaries and links
* final outcomes

The database contains:

* live state
* internal events
* correlation IDs
* detailed metrics

## 10) What PathOps does NOT attempt to capture

PathOps does not capture:

* IDE conversations
* prompts
* reasoning traces
* local experimentation
* discarded drafts

This is intentional.

Governance begins at the boundary where changes become observable.

## 11) Why this model works

This design:

* respects developer autonomy
* supports any editor or tool
* avoids invasive telemetry
* preserves auditability
* aligns with PR-first and GitOps principles

It unifies:

* human-authored change
* AI-authored change
* mixed workflows

Under a single, deterministic model.

## 12) Summary

* Change Sets exist **before code**
* Authoring can be opaque without breaking governance
* Branches and PRs anchor observability
* Evidence replaces visibility into drafting
* PathOps governs outcomes, not conversations

> Change is inevitable.
> Observability starts at the rails.