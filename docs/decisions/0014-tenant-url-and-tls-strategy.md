# ADR 0014 — Tenant URL and TLS strategy for the demo

## Status
Accepted

## Context
The demo exposes per-tenant app endpoints via subdomains under `demo.pathops.io`.
TLS must be simple, reliable, and not depend on per-tenant certificate issuance.

## Decision
Use a flat hostname convention:
`<env>-<app>-<tenant>.demo.pathops.io`

Issue a single wildcard certificate:
`*.demo.pathops.io`

Terminate TLS at the Edge Gateway.

## Consequences
- predictable TLS and DNS configuration
- no per-tenant cert management
- URLs remain readable and demo-friendly