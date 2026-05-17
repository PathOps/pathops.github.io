# [Docs](./README.md)
# Events & Inbox
## Operational awareness model for PathOps

PathOps is not only responsible for governing change.

It is also responsible for making operational activity
visible, explainable, and actionable.

This document defines:
- the PathOps event model
- the Inbox model
- operational awareness principles
- CLI interaction patterns

---

# 1) Core idea

PathOps coordinates:
- changes
- deploys
- evidence
- incidents
- AI activity
- approvals
- remediation workflows

Users must be able to understand:
- what is happening
- what happened
- what requires human attention

without manually inspecting every integrated tool.

PathOps provides a centralized operational awareness layer.

---

# 2) Events

An Event represents something that happened.

Events are immutable operational records.

Examples:
- pipeline started
- deploy completed
- verification failed
- AI generated a PR
- rollback triggered
- evidence snapshot created

Events may originate from:
- PathOps workflows
- Jenkins
- Argo CD
- SCM systems
- observability systems
- AI agents

---

# 3) Event goals

Events exist to provide:
- operational visibility
- auditability
- timeline reconstruction
- user awareness
- correlation across tools

Events are not tasks.

Events do not necessarily require action.

---

# 4) Recommended event model

Example structure:

```yaml
id:
tenantId:
type:
category:
severity:
title:
message:
metadata:
correlationId:
createdAt:
```

---

# 5) Event categories

## INFO

Informational operational activity.

Examples:

* pipeline started
* deployment completed
* verification succeeded

---

## WARNING

Potential issues or degraded conditions.

Examples:

* pod restarting repeatedly
* deployment retrying
* elevated latency

---

## INCIDENT

Production-impacting failures.

Examples:

* CrashLoopBackOff
* service unavailable
* failed production deploy

---

## AI_ACTIVITY

Actions performed by AI systems.

Examples:

* AI generated PR
* AI proposed remediation
* AI updated fix proposal

AI actions must remain transparent and auditable.

---

## DECISION

Automatic governance decisions made by PathOps.

Examples:

* rollback triggered
* promotion blocked
* canary promoted
* deploy rejected by policy

---

## ACTION_REQUIRED

Events that require human attention.

These events typically produce Inbox items.

Examples:

* approve PR
* review rollback
* validate risky deployment

---

# 6) Inbox

The Inbox is a queue of pending human actions.

Unlike Events:

* Inbox items are actionable
* Inbox items have lifecycle state
* Inbox items may be resolved

Examples:

* approve autopilot PR
* review failed verification
* accept rollback proposal

---

# 7) Inbox item model

Example structure:

```yaml
id:
tenantId:
type:
status:
title:
description:
priority:
actionUrl:
relatedEventId:
createdAt:
resolvedAt:
```

---

# 8) Inbox item lifecycle

Typical states:

```text
OPEN
IN_PROGRESS
RESOLVED
DISMISSED
EXPIRED
```

Inbox items are intentionally explicit.

PathOps does not silently resolve human decisions.

---

# 9) Operational timeline

PathOps models operational activity as a timeline.

The goal is reconstructability.

Example:

User created app
→ Pipeline started
→ Deploy failed
→ Evidence snapshot created
→ AI analyzed logs
→ AI generated PR
→ Human approved
→ Redeployed
→ Production healthy

This timeline may span:

* multiple tools
* multiple workflows
* multiple environments

---

# 10) Correlation identifiers

Events should support correlation identifiers.

Examples:

* changeId
* deploymentId
* incidentId
* workflowId
* verificationId
* snapshotId
* patchId

This allows PathOps to reconstruct operational narratives.

---

# 11) Event collapsing and grouping

PathOps should avoid notification spam.

Repeated operational events may be grouped.

Example:

Instead of:

* pod restarted
* pod restarted
* pod restarted

PathOps may emit:

```text
deployment/api restarted 4 times in 2 minutes
```

Grouping improves operational clarity.

---

# 12) CLI interaction model

The PathOps CLI is operationally aware.

After executing commands, the CLI may notify the user
about pending Inbox items.

Example:

```bash
$ pathops app create api-demo

✔ App created
✔ Pipeline started

⚠ You have 2 pending inbox items.
Run: pathops inbox
```

---

# 13) pathops inbox

Displays pending human actions.

Example:

```text
[1] Review PR #82
    AI-generated fix for memory leak

[2] Approve rollback
    Production error rate exceeded threshold
```

---

# 14) pathops watch

Streams live operational events.

Example:

```text
[INFO] Pipeline started
[INFO] Preflight deployment running
[WARNING] Pod restarted twice
[AI_ACTIVITY] AI generated remediation proposal
```

The watch command is optional and ephemeral.

Operational state must remain reconstructable without it.

---

# 15) SCM remains the source of actionable change

PathOps may surface events and Inbox items,
but Pull Requests / Merge Requests remain the canonical
review and approval surface.

PathOps complements SCM workflows.
It does not replace them.

---

# 16) Design principles

## Transparency over automation

If the system acts:

* users must know
* actions must be explainable
* actions must be reviewable

---

## Operational awareness without noise

PathOps should minimize:

* spam
* duplicated alerts
* meaningless updates

Signal quality matters more than volume.

---

## Humans stay in control

Automation may propose actions.

Humans approve production-impacting decisions.

---

# 17) Summary

PathOps provides:

* operational events
* centralized awareness
* actionable inboxes
* operational timelines
* AI transparency
* workflow correlation

This allows users to understand:

* what changed
* why it changed
* what failed
* what requires attention

without manually correlating every external tool.