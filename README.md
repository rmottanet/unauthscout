[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=bugs)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=rmottanet_unauthscout&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=rmottanet_unauthscout)

# UnauthScout

UnauthScout is a CLI tool for **unauthenticated OSINT reconnaissance** on public
developer platforms such as **GitHub** and **GitLab**.

It standardizes the collection of publicly available user data using a
consistent interface and **normalized JSON output contracts**.


## Problem Statement

Public developer platforms expose valuable reconnaissance data without requiring
authentication. However, this data is often inconsistent across providers and
hard to consume programmatically.

UnauthScout addresses this by:
- Querying public APIs without authentication
- Normalizing responses via explicit schemas
- Providing a simple, script-friendly CLI


## Features

- Unauthenticated user reconnaissance on GitHub
- Unauthenticated user reconnaissance on GitLab
- Normalized JSON output defined by explicit schemas
- Raw output mode for debugging and field discovery
- Modular, provider-based architecture


## Non-goals

- Authentication or token-based access
- Rate-limit bypassing
- Collection of private or restricted data
- Automated correlation or enrichment across platforms


## Requirements

- Bash (POSIX-compatible)
- `curl`
- `jq`


## Installation

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
chmod +x bin/unauthscout
````


## Usage

### Basic usage

```bash
unauthscout <username>
```

### Raw output (unprocessed API response)

```bash
unauthscout <username> --raw
```

By default, UnauthScout outputs **normalized JSON** that conforms to the
corresponding schema under `schemas/`.


## Output Contracts

Normalized outputs are defined via JSON Schema:

* `schemas/github_user.json`
* `schemas/gitlab_user.json`

These schemas are the **source of truth** for all processed output and ensure
stable, predictable data structures.


## Project Structure

```
bin/        # CLI entry point and orchestration
lib/        # Provider integrations and parsing logic
schemas/    # Normalized data contracts (JSON Schema)
docs/       # Documentation as code
tests/      # Automated tests (optional)
```


## Design Principles

* Unauthenticated by default
* Explicit data contracts over implicit assumptions
* Clear separation between orchestration and data retrieval
* Minimal surface area, extensible by design

---

<br />
<br />
<div align="center">
  <a href="https://github.com/rmottanet/unauthscout"><img alt="Static Badge" src="https://img.shields.io/badge/-github?style=social&logo=github&logoSize=auto&label=GitHub&link=https%3A%2F%2Fgithub.com%2Frmottanet%2Funauthscout"></a>
  <a href="https://gitlab.com/rmottanet/unauthscout"><img alt="Static Badge" src="https://img.shields.io/badge/-gitlab?style=social&logo=gitlab&logoSize=auto&label=GitLab&link=https%3A%2F%2Fgitlab.com%2Frmottanet%2Funauthscout%23"></a>
</div>
