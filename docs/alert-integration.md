# Alert Integration

## Overview

PathOps integrates with external alerting systems through webhooks.

PathOps does not define how alerts are detected.

## Supported alert sources

Examples include:
- Prometheus Alertmanager
- Datadog
- Grafana OnCall
- PagerDuty
- Custom systems

## Alert requirements

An alert event must provide:
- alert name
- severity
- start time
- affected resource identifiers (namespace, pod, app)
- optional contextual annotations

## Alert lifecycle

1. External system detects an issue
2. Alert is sent to PathOps via webhook
3. PathOps creates a Change Intent
4. Evidence is collected
5. Remediation workflows are evaluated

## Alert resolution

Resolution events may optionally be sent to PathOps
but are not required for remediation workflows.