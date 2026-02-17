# ADR 0012 — Observability and Alerting Are External to PathOps

## Status
Accepted

## Context

PathOps reacts to operational signals in order to collect evidence,
create change intents, and coordinate remediation workflows.

Systems such as:
- Prometheus
- Alertmanager
- Loki
- Grafana
- Datadog
- New Relic

are **observability and alerting tools**, not responsibilities of PathOps.

Coupling PathOps to a specific observability stack would:
- reduce flexibility
- limit adoption
- create false ownership of incident detection

## Decision

PathOps does **not** perform:
- metric collection
- log aggregation
- alert evaluation
- alert routing

Instead, PathOps integrates with **external alerting systems**
via **webhooks**.

Alerting systems are responsible for:
- detecting failures
- evaluating rules
- deciding alert severity

PathOps is responsible for:
- reacting to alerts
- collecting evidence
- coordinating remediation

## Demo implementation

In the demo environment:
- Prometheus evaluates Kubernetes alerting rules
- Alertmanager sends alert webhooks to PathOps
- Loki stores pod logs to ensure they survive pod restarts
- PathOps connects to Prometheus and Loki **only to collect evidence**

These tools are used purely as **demo scaffolding**.

## Consequences

- PathOps remains observability-agnostic
- Users can integrate PathOps with any alerting solution
- Evidence collection is best-effort and tool-dependent
- Missing evidence is explicitly represented, not hidden