# [Docs](./README.md)
# Changes

## Change model

In PathOps, Change is the primary lifecycle object.

A Change represents the evolution of an Evolvable Unit.

A Change may produce patch bundles, pull requests,
deployments, and evidence records.

Older versions of the documentation used the term
Change. The current term is Change.

## 1) What a Change represents

A **Change** is the core unit of change in PathOps.

A Change is:
- a **project-level change transaction**
- spanning one or more repositories
- validated and deployed as a single unit
- completed only when all required evidence is produced

A Change has:
- a lifecycle
- explicit state
- evidence
- reversibility expectations

PathOps treats Changes as first-class objects, regardless of how the code was written.

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

## 3) Creating a Change before code exists

A Change is created **as soon as the user declares intent**, not when code appears.

Example:
- user clicks **“New change”**
- user provides a short intent description
- PathOps immediately creates a Change

At this point:
- no code may exist
- no commits may exist
- no PR may exist

This Change is still valid.

It represents **intent + ownership**, not implementation.

## 4) Externally authored (opaque) Changes

PathOps explicitly models authoring mode and observability.

### Recommended attributes

- `authoring_mode`:  
  `human | agent | mixed`

- `observability`:  
  `opaque | observed`

An externally authored Change is typically:

- `authoring_mode: human`
- `observability: opaque`

This means:
- PathOps does not know how the change was produced
- PathOps will rely **entirely on evidence** to evaluate promotion

Opaque does **not** mean ungoverned.

## 5) Branch and PR creation strategy

### Core rule
**Every Change must anchor to observable Git artifacts.**

### Recommended flow

1. User clicks **New change**
2. PathOps:
   - creates Change `CS-0042`
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

PathOps updates Change state using **SCM events**, not IDE telemetry.

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

## 8) Evidence expectations for opaque Changes

When authoring is opaque, PathOps compensates by requiring **stronger evidence**.

Examples:

* mandatory CI success
* mandatory contract tests
* mandatory preflight validation
* stricter policy gates

This preserves trust without violating privacy or boundaries.

## 9) Changes in the project meta repository

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

## Signals

Evidence attached to a Change may originate from
external observability systems and is collected on a best-effort basis.

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

* Changes exist **before code**
* Authoring can be opaque without breaking governance
* Branches and PRs anchor observability
* Evidence replaces visibility into drafting
* PathOps governs outcomes, not conversations

> Change is inevitable.
> Observability starts at the rails.