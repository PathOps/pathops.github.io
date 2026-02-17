# Demo Observability Stack

## Scope

This document describes the observability stack used in the PathOps demo.

It does not define product requirements.

## Components

The demo uses:
- Prometheus: metric collection and alert evaluation
- Alertmanager: alert routing
- Loki: centralized pod logs
- Promtail: log shipping from Kubernetes

## Rationale

This stack allows:
- pod failure detection
- persistent logs across pod restarts
- realistic operational workflows
- minimal coupling to PathOps

## Alerting strategy

Prometheus alerting rules detect:
- crash loops
- OOM kills
- high restart rates
- failed pods

Alertmanager forwards alerts to PathOps.

## Evidence flow

1. Alert triggers PathOps
2. Evidence Collector queries Loki for logs
3. Evidence Collector queries Prometheus for metrics
4. Evidence is attached to the Change Set