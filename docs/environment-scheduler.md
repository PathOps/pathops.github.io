# Environment Scheduler

The Environment Scheduler allocates ephemeral environments for pull requests and test workflows.

## Problem

Large platforms may have dozens or hundreds of pull requests open simultaneously.

Creating environments for every change can exhaust cluster resources.

The scheduler decides:

- when an environment should be created
- what type of environment is needed
- how long it should live
- resource limits

## Responsibilities

- enforce tenant quotas
- enforce maximum concurrent environments
- choose environment type
- assign cluster or sandbox
- track lifecycle
- trigger cleanup

## Example policy

- docs-only PR → no environment
- application change → namespace preview
- infrastructure change → isolated sandbox
- max 10 environments per tenant
- automatic TTL cleanup (e.g. 8 hours)

## Architecture

Example diagram:

PR event
   |
   v
PathOps Control Plane
   |
   |-- Environment Scheduler
         |
         |-- allocate namespace
         |-- allocate vcluster
         |-- queue if capacity exceeded