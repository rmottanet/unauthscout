# GitLab Project API Field Mapping

This document describes how fields from the **unauthenticated GitLab Projects API**
response are mapped and normalized by UnauthScout.

It serves as a reference for:
- Understanding which raw fields are used
- Validating schema alignment
- Auditing normalization decisions

## Endpoint

```

GET [https://gitlab.com/api/v4/users/{username}/projects](https://gitlab.com/api/v4/users/{username}/projects)

```

- Authentication: ❌ Not required
- Scope: Public projects only
- Filters: `visibility=public`
- Pagination: `per_page=100`

## Raw Response Overview

The GitLab Projects API returns an **array of project objects**, each containing
metadata, internal URLs, permissions, and platform-specific configuration fields.

UnauthScout intentionally selects a **minimal subset** of stable, OSINT-relevant
project metadata suitable for cross-provider normalization.

## Field Mapping

| Raw Field                | Normalized Field | Included | Notes |
|--------------------------|------------------|----------|-------|
| `id`                     | `id`             | ✅       | Stable unique project identifier |
| `name`                   | `name`           | ✅       | Project name |
| `path_with_namespace`    | `path`           | ✅       | Fully qualified project path |
| `description`            | `description`    | ✅       | Nullable, contextual |
| `web_url`                | `url`            | ✅       | Public project URL |
| `star_count`             | `stars`          | ✅       | Popularity signal |
| `forks_count`            | `forks`          | ✅       | Reuse and activity signal |
| `visibility`             | —                | ❌       | Filtered at request time |
| `namespace`              | —                | ❌       | Redundant with path |
| `owner`                  | —                | ❌       | Not always present |
| `default_branch`         | —                | ❌       | Operational detail |
| `created_at`             | —                | ❌       | Not required for MVP |
| `last_activity_at`       | —                | ❌       | Volatile |
| `archived`               | —                | ❌       | Edge-case, low signal |
| `topics`                 | —                | ❌       | Not consistently populated |
| `readme_url`             | —                | ❌       | Secondary resource |
| `http_url_to_repo`       | —                | ❌       | Non-OSINT |
| `ssh_url_to_repo`        | —                | ❌       | Non-OSINT |
| `permissions`            | —                | ❌       | Auth-dependent |
| `_links`                 | —                | ❌       | Internal API URLs |

## Normalization Logic

The current normalization is implemented as:

```bash
parse_gitlab_repos() {
    jq '.[] | {
        id,
        name: .name,
        path: .path_with_namespace,
        description,
        url: .web_url,
        stars: .star_count,
        forks: .forks_count
    }'
}
````

Each project is emitted as a **single normalized object**.

## Output Contract

The normalized output conforms to:

```
schemas/gitlab_user_repos.json
```

This schema is the **authoritative definition** of GitLab project output
within UnauthScout.

## Rationale

Field inclusion follows these principles:

* Fields must be consistently present
* Fields must be OSINT-relevant
* Fields must support cross-provider parity
* Fields must not require authentication
* Fields must be stable across GitLab versions

All other fields are intentionally excluded to reduce noise, avoid platform
specific coupling, and preserve long-term contract stability.

## Notes on Evolution

* Additional metadata (e.g. topics, license) may be added in future versions
* Group-owned projects may receive extended handling in future releases
* Authenticated-only fields will require a separate contract and schema
* Breaking changes will be documented explicitly

## Summary

This mapping ensures that UnauthScout emits a **clean, minimal, and predictable**
representation of public GitLab projects, suitable for OSINT workflows,
automation pipelines, and provider-agnostic analysis.
