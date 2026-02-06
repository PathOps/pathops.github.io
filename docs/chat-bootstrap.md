# PathOps — Chat Bootstrap

This document is used to resume work in a new chat
without relying on previous conversation history.

## Project summary

PathOps is an open source **control plane** for AI-assisted live coding in production.

Core idea:
- Live coding is the locomotive
- PathOps are the rails

Fundamental rule:
> No change reaches production without evidence.

PathOps governs **intent and promotion**, not code generation.

## Canonical documents (source of truth)

When reasoning about PathOps, these documents are authoritative:

- manifesto.md — why PathOps exists
- principles.md — non-negotiable rules
- architecture.md — conceptual + modular architecture
- change-sets.md — project-level change governance
- artifact-states.md — lifecycle of software artifacts
- decisions/* — accepted architectural/product decisions
- glossary.md — canonical terminology

Chats are not a source of truth.

## Core terminology (do not rename)

- Change Set (not Epic)
- Preflight (not staging)
- Meta repository (per project)
- PR-first change
- Evidence snapshot
- GitOps as source of truth

## Key design constraints

- One active Change Set per project (MVP)
- Pipelines do NOT access the cluster
- Only Argo CD reconciles cluster state
- Evidence payloads live outside Git; Git stores links
- Authoring may be opaque (Cursor, IDEs, humans)

## Mental model

- Control Plane decides
- Temporal guarantees
- Coordinator plans
- Agents execute
- GitOps deploys
- Evidence proves
- Humans approve

## How to use this document in a new chat

Start the chat with:

“PathOps project.
Use the documentation in `docs/` as source of truth,
especially manifesto, principles, architecture, change-sets,
and decisions.
We are continuing design, not starting from scratch.”

Then state what you want to work on.

## Cómo utilizar este documento en un nuevo chat

Proyecto PathOps.

Usá la documentación adjunta en `docs/` como fuente de verdad,
especialmente:
- manifesto.md
- principles.md
- architecture.md
- change-sets.md
- decisions/*

No estamos empezando desde cero.
Estamos continuando el diseño y la implementación del proyecto.

Quiero trabajar en: <X>