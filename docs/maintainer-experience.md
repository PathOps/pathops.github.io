# Maintainer Experience (Demo + Product)

## Goal

A maintainer must be able to:
- discover that PathOps proposed a fix (PR/MR)
- understand why (evidence)
- understand current workflow state (verification, retries)
- approve/merge or request changes

without requiring PathOps-specific tooling.

## UX contract

### PR/MR creation
PathOps MUST:
- create a PR/MR with a clear title
- include a structured description with evidence links and change intent
- assign and/or request review from maintainers

### Status visibility
PathOps MUST:
- create a "PathOps Status" comment
- update it in-place on workflow transitions
- include deep links to:
  - Change Set / Change Intent (PathOps)
  - Evidence (logs/metrics)
  - Pipeline run / verification output
  - Retry count if applicable

## PR/MR template (recommended)

### Title
`[pathops] Fix <symptom> in <app>/<env>`

### Body
- Summary (1–2 lines)
- Triggering alert (name + timestamp)
- Evidence (logs + minimal metrics)
- Proposed fix
- Rollback / risk notes
- Links (Change Set, verification run)

### "PathOps Status" comment (single, updated)
Example fields:
- Status: Verification failed (retry 2/3)
- Last update: 2026-02-15T...
- Current hypothesis: OOMKilled
- Next action: increase memory limit + redeploy
- Links: verification logs, Loki query, Prometheus query