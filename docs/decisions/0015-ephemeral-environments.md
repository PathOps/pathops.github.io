# ADR 0015: Ephemeral Environments

## Context

Pull request validation requires realistic runtime testing.

Static shared environments cause conflicts between teams.

## Decision

PathOps will support ephemeral environments automatically created per pull request.

Environments will be allocated by an Environment Scheduler and cleaned up by a Garbage Collector.

## Consequences

Benefits:

- safer PR validation
- realistic integration tests
- preview deployments

Tradeoffs:

- additional infrastructure complexity
- resource management required