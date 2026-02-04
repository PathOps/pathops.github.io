# [Docs](./README.md) 
# PathOps Principles

These principles are non-negotiable.  
They guide product design, architecture, and user experience.

---

## 1) PR-first change
All meaningful changes are expressed as pull requests:
- code changes
- pipeline changes
- GitOps changes
- policy changes

If it can’t be reviewed, it can’t ship.

---

## 2) Evidence before promotion
Promotion decisions must be backed by evidence:
- test results
- deploy outcome
- health checks / smoke checks
- policy gates
- runtime signals (when relevant)

No evidence, no promotion.

---

## 3) GitOps is the source of truth for deploy state
The cluster follows declared state.
Humans and automation modify Git state.
Controllers apply it.

---

## 4) Reversible by design
Every workflow must define:
- how to roll back
- how to mark artifacts “not promotable”
- how to restore a known-good state

---

## 5) Minimal surface area
Prefer a small number of reliable workflows over many configurable workflows.

PathOps is a system of defaults.
Customizations are explicit and visible.

---

## 6) Humans stay in control
PathOps can propose and automate.
Humans approve and merge — especially for production changes.

---

## 7) Security is a gate, not a suggestion
Security checks are first-class:
- SCA/SBOM policies
- image scanning policies
- secret scanning
- basic hardening rules

Findings produce evidence and remediation PRs.

---

## 8) Failures produce artifacts
Every important failure should result in an evidence bundle:
- what happened
- what changed
- what signals were observed
- what the system recommends next

---

## 9) Integrate, don’t replace
PathOps should integrate with existing tools first.
Replacing tools is optional and should not be required to adopt PathOps.

