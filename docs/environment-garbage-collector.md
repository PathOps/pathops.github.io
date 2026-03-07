# Environment Garbage Collector

Ephemeral environments must be destroyed reliably.

Relying only on CI pipelines to clean up environments is unsafe because pipelines may fail.

The Garbage Collector periodically scans for orphan environments.

## Cleanup triggers

- PR merged
- PR closed
- TTL expired
- branch deleted
- pipeline failure

## Example lifecycle

PR opened
→ environment created

PR merged
→ GC detects merged PR
→ destroy environment

## Responsibilities

- detect orphan environments
- enforce TTL
- delete unused namespaces or clusters
- reclaim resources