# Evidence Collection

## Purpose

The Evidence Collector Agent gathers objective data related to an alert
in order to support diagnosis and remediation.

It does not evaluate alerts or decide causality.

## Trigger

The Evidence Collector is triggered by an **Alert Event**
received via webhook from an external alerting system.

## Data sources (demo)

In the demo environment, evidence is collected from:
- Prometheus (metrics)
- Loki (pod logs)

These integrations are optional and replaceable.

## Log collection

Logs are the primary source of diagnostic evidence.

For a given alert, the Evidence Collector:
1. Identifies the affected pod and namespace
2. Queries the log backend for logs related to that pod
3. Collects logs within a defined time window

### Time window

- Start: `alert.startsAt - 5 minutes`
- End: `alert.startsAt + 1 minute` or `now`

This window provides pre-failure context and the failure itself.

### Log limits

- Logs are truncated to a reasonable size (e.g. last 500 lines)
- Absence of logs is recorded explicitly

## Metrics collection

Metrics provide contextual signals that complement logs.

Typical metrics include:
- container restarts
- pod phase
- memory usage (if available)
- CPU usage (if available)

Metrics are summarized rather than stored as raw time series.

## Best-effort principle

Evidence collection is best-effort:
- missing logs or metrics are allowed
- limitations are recorded explicitly
- downstream agents reason with partial evidence