# ADR 0013 — PR-centric communication to maintainers (A + C)

## Status
Accepted

## Context

PathOps generates changes (fixes) as Pull Requests / Merge Requests (PR/MR).
This is the natural collaboration surface for maintainers.

However, relying only on "a PR exists" is not enough:
maintainers must be notified promptly and must be able to track workflow
progress (retries, verification, evidence updates) without requiring a PathOps UI.

## Decision

PathOps communicates with maintainers primarily through the SCM (GitHub/GitLab)
using two mechanisms:

### A) Assignment / Review Request notifications
When PathOps creates a PR/MR, it MUST:
- assign at least one maintainer (assignee), and/or
- request review from one or more maintainers (reviewers / team)

This leverages SCM-native notification channels (web/email) for awareness.

### C) Single "Status" comment (updated, not spammy)
PathOps MUST maintain a single "PathOps Status" comment in the PR/MR thread.
On every relevant workflow transition, PathOps edits this comment in-place:
- evidence collected
- fix proposal updated (v2/v3)
- verification started
- verification failed (retry i/n)
- verification passed
- workflow aborted / needs human input

This avoids notification spam while keeping the PR/MR as the live operational log.

## Non-goals

- PathOps does not require maintainers to keep a PathOps CLI open.
- PathOps does not replace SCM notifications.
- PathOps does not rely on a long-lived websocket connection for basic awareness.

## Consequences

- Maintainers receive actionable SCM notifications.
- The PR/MR becomes the single place to understand the current state.
- A PathOps UI/CLI "events tail" remains optional and additive.