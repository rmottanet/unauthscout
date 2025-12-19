# Security Policy

This document describes the security posture, assumptions, and disclosure
process for the UnauthScout project.


## Project Scope and Security Model

UnauthScout is a **read-only, unauthenticated reconnaissance tool**.

Security assumptions:
- No authentication tokens are handled or stored
- No private or restricted data is accessed
- No state is persisted between executions
- No elevated privileges are required

As a result, the attack surface of the project is intentionally minimal.


## Data Handling

UnauthScout:
- Fetches **publicly available data** from third-party APIs
- Outputs data directly to stdout
- Does not store, cache, or transmit data elsewhere

The tool does not process:
- Credentials
- Secrets
- Personally identifiable information beyond what is publicly exposed
- User-provided files or untrusted input beyond CLI arguments


## Dependency Security

The project depends on:
- `bash`
- `curl`
- `jq`

Users are responsible for:
- Keeping system packages up to date
- Applying security updates provided by their OS distribution

UnauthScout does not bundle or vendor third-party libraries.


## Input Validation

User input is limited to:
- Provider selection
- Target identifiers (e.g. usernames)
- CLI flags

Inputs are treated as opaque strings and are not executed or interpolated into
shell commands beyond controlled API requests.


## Known Limitations

UnauthScout does not implement:
- Sandboxing
- Network request filtering
- Rate-limit protection
- Input sanitization beyond basic validation

These limitations are acceptable given the tool’s read-only and unauthenticated
nature.


## Responsible Disclosure

If you believe you have found a security vulnerability in UnauthScout, please
report it responsibly.


### How to report

- Open a **private security advisory** via the repository’s security tab  
  **or**
- Contact the maintainers directly if a private channel is available

Please include:
- A clear description of the issue
- Steps to reproduce
- Potential impact
- Suggested remediation (if known)


## Out of Scope

The following are explicitly **out of scope**:
- Vulnerabilities in third-party APIs (GitHub, GitLab)
- Abuse of public APIs
- Rate limiting or account bans imposed by providers
- OSINT ethics or legal considerations


## Security Updates

Security-related fixes will be:
- Documented clearly
- Released as soon as practical
- Backported when appropriate


## Summary

UnauthScout is designed to be:
- Simple
- Transparent
- Predictable

Its security posture relies on minimal functionality, explicit scope, and
clear operational boundaries.
