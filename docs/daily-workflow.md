# [Docs](./README.md)
# Daily Workflow
## Using ChatGPT without dependency

This document defines the **daily working model** for using ChatGPT
while designing and building PathOps.

The goal is simple:

> Use ChatGPT for reasoning and exploration  
> without turning it into the project’s memory.

---

## Core idea

**ChatGPT is a reasoning workspace, not a memory system.**

- The repository is the source of truth
- Git is the project’s memory
- ChatGPT helps think, question, and refine

If knowledge only exists in a chat, it is fragile.

---

## 🟢 Phase 1 — Exploration

Use ChatGPT freely to:

- brainstorm ideas
- explore alternatives
- challenge assumptions
- test mental models
- refine concepts through dialogue

At this stage:
- nothing is final
- nothing is binding
- speed and openness matter more than precision

Exploration is allowed to be messy.

---

## 🟡 Phase 2 — Recognition

Pay attention to internal signals.

If you find yourself saying:

- “this is important”
- “this defines the architecture”
- “we already decided this”
- “this would be costly to change later”
- “I don’t want to lose this idea”

That information **no longer belongs in the chat**.

This is the transition point.

---

## 🔴 Phase 3 — Decision closure ritual

Before ending a chat session:

1. Identify decisions that were made or finalized
2. Write them down as documents:
   - architecture updates
   - change-set rules
   - or `docs/decisions/000X-*.md`
3. Commit them to Git
4. Close the chat without guilt

Once something is committed, it is safe.

Chats are allowed to disappear.

---

## Mental checklist

Ask yourself regularly:

- Can I resume this project tomorrow without this chat?
- Is this decision written down in Git?
- Is ChatGPT reasoning, or remembering things for me?

If ChatGPT is remembering, ownership is leaking.

---

## Boundaries

ChatGPT should NOT be used as:

- the long-term memory of the project
- the place where decisions live
- the only record of architectural intent

ChatGPT SHOULD be used as:

- a thinking partner
- a design critic
- a tool to explore consequences
- a way to refine language and clarity

---

## The golden rule

> **If you would be afraid to lose it,  
> it does not belong in the chat.  
> It belongs in Git.**

---

## Outcome

Following this workflow ensures that:

- the project remains understandable over time
- decisions are not re-litigated endlessly
- chats stay lightweight and disposable
- you retain ownership of the project’s direction

ChatGPT stays a powerful tool.

Git stays the brain.

Humans stay in control.