# GitHub Repository API Field Mapping

This document describes how fields from the **unauthenticated GitHub Repositories API**
response are mapped and normalized by UnauthScout.

It serves as a reference for:
- Understanding which raw fields are used
- Validating schema alignment
- Auditing normalization decisions

## Endpoint

```

GET [https://api.github.com/users/{username}/repos](https://api.github.com/users/{username}/repos)

```

- Authentication: ❌ Not required
- Scope: Public repositories only
- Pagination: `per_page=100` (maximum allowed)

## Raw Response Overview

The GitHub Repositories API returns an **array of repository objects**, each containing
extensive metadata, internal API URLs, feature flags, and configuration details.

UnauthScout intentionally selects a **minimal subset** of stable, OSINT-relevant
repository metadata suitable for cross-provider normalization.

## Field Mapping

| Raw Field              | Normalized Field | Included | Notes |
|------------------------|------------------|----------|-------|
| `id`                   | `id`             | ✅       | Stable unique repository identifier |
| `name`                 | `name`           | ✅       | Repository name |
| `full_name`            | `full_name`      | ✅       | Owner/repository (globally unique) |
| `description`          | `description`    | ✅       | Nullable, useful for context |
| `html_url`             | `url`            | ✅       | Public repository URL |
| `stargazers_count`     | `stars`          | ✅       | Popularity signal |
| `forks_count`          | `forks`          | ✅       | Activity and reuse signal |
| `language`             | `language`       | ✅       | Primary language (nullable) |
| `private`              | —                | ❌       | Always false for public enumeration |
| `owner`                | —                | ❌       | Redundant (implicit via username) |
| `topics`               | —                | ❌       | Requires preview headers |
| `license`              | —                | ❌       | Often null / inconsistent |
| `created_at`           | —                | ❌       | Not required for MVP |
| `updated_at`           | —                | ❌       | Highly volatile |
| `pushed_at`            | —                | ❌       | Activity noise |
| `size`                 | —                | ❌       | Low OSINT value |
| `default_branch`       | —                | ❌       | Operational detail |
| `clone_url`            | —                | ❌       | Non-OSINT |
| `ssh_url`              | —                | ❌       | Non-OSINT |
| `fork`                 | —                | ❌       | Context-specific, excluded for MVP |
| `archived`             | —                | ❌       | Edge-case, low signal |
| `disabled`             | —                | ❌       | Rare, non-actionable |
| `permissions`          | —                | ❌       | Auth-dependent |
| `hooks_url`            | —                | ❌       | Internal API URL |
| `issues_url`           | —                | ❌       | Internal API URL |

## Normalization Logic

The current normalization is implemented as:

```bash
parse_github_repos() {
    jq '.[] | {
        id,
        name: .name,
        full_name: .full_name,
        description,
        url: .html_url,
        stars: .stargazers_count,
        forks: .forks_count,
        language
    }'
}
````

Each repository is emitted as a **single normalized object**.

## Output Contract

The normalized output conforms to:

```
schemas/github_user_repos.json
```

This schema is the **authoritative definition** of GitHub repository output
within UnauthScout.

## Rationale

Field inclusion follows these principles:

* Fields must be consistently present
* Fields must be OSINT-relevant
* Fields must support cross-provider parity
* Fields must not require authentication
* Fields must be automatable and stable

All other fields are intentionally excluded to reduce noise, avoid API drift,
and preserve long-term contract stability.

## Notes on Evolution

* Additional metadata (e.g. license, topics) may be added in future versions
* Repository activity timelines are intentionally excluded from MVP scope
* Authenticated-only fields will require a separate contract and schema
* Breaking changes will be documented explicitly

## Summary

This mapping ensures that UnauthScout emits a **clean, minimal, and predictable**
representation of public GitHub repositories, suitable for OSINT workflows,
automation pipelines, and future provider expansion.
