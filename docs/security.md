# Security

PathOps is designed to operate in sensitive environments (CI/CD, clusters, credentials).
Security is not optional.

## Core posture
- Prefer least privilege
- Prefer short-lived credentials when possible
- Avoid storing long-lived secrets unless unavoidable
- Use audit logs for actions that affect deploy or policy

## Transparency
Security-related automation must be visible:
- evidence produced
- checks executed
- changes proposed via PR

## Sensitive data
Snapshots must avoid leaking secrets:
- redact tokens/credentials
- minimize payload to what’s needed
- store snapshots with access controls
- expire snapshots where appropriate

## Responsible disclosure
If you discover a security vulnerability:
- open a private report channel (to be defined in the main project)
- do not disclose publicly until a fix is available

## Supply chain
PathOps should encourage:
- SBOM generation
- dependency policy checks
- image scanning policies
- signed artifacts (optional, future)

