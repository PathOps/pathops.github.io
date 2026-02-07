# Decision 0005 — App-first MVP and SCM responsibility boundary

## Status
Accepted

## Context

Early PathOps designs included multiple high-level entities:
- Project
- App
- Component
- Multi-repository Change Sets

However, most AI-assisted “vibe coding” tools (Cursor, Aider, Claude Code, etc.)
operate on a **single repository at a time** and assume:
- one working tree
- one CI pipeline
- one deployment unit

Additionally, automatically creating or managing GitHub organizations
or GitLab groups introduces responsibilities that are:
- social and organizational
- permission- and billing-sensitive
- outside PathOps’ core mission

Over-automation at this level risks forcing decisions that do not belong
to PathOps.

## Options considered

### Option A — Full project model from day one
PathOps manages:
- projects
- multiple apps
- repository creation
- SCM organizational structure

**Pros**
- matches long-term vision immediately

**Cons**
- high complexity
- poor alignment with current AI tooling
- slower MVP
- overreach into human organizational decisions

### Option B — App-first MVP with user-managed repositories
PathOps focuses on:
- a single App (one repo)
- Change Sets within that repo
- CI → PR → GitOps → Preflight → Evidence

Users:
- create repositories where they want
- choose SCM organization/group structure
- register existing repos into PathOps

**Pros**
- aligns with current vibe coding workflows
- reduces cognitive and technical load
- respects organizational boundaries
- faster, clearer MVP

**Cons**
- multi-app coordination deferred to later phase

## Decision

PathOps MVP will be **App-first**.

- An **App** is the primary and only governed entity in the MVP.
- One App maps to one source code repository.
- Change Sets initially span **one repository only**.
- Users are responsible for creating repositories and SCM structure.
- PathOps does NOT create or manage:
  - GitHub organizations
  - GitLab groups
  - repository ownership or billing domains

PathOps begins governance **after a repository exists**.

## Rationale

This decision aligns PathOps with:
- how AI-assisted coding tools actually work today
- the principle “Integrate, don’t replace”
- a clear boundary between automation and human intent

PathOps governs **change execution**, not **organizational topology**.

The long-term project/multi-app vision remains valid, but is explicitly
deferred until the single-app model is proven in practice.

## Consequences

### Enabled
- Faster MVP delivery
- Clear mental model
- CLI-first workflow
- Strong alignment with vibe coding tools

### Deferred
- Multi-app Change Sets
- Cross-repository deployment ordering
- Project-level aggregation and policies

These can be added later without breaking the App-first model.

## Notes

This decision intentionally limits scope to preserve correctness,
adoptability, and trust.