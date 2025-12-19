# GitHub API Field Mapping

This document describes how fields from the **unauthenticated GitHub Users API**
response are mapped and normalized by UnauthScout.

It serves as a reference for:
- Understanding which raw fields are used
- Validating schema alignment
- Auditing normalization decisions

## Endpoint

```

GET [https://api.github.com/users/{username}](https://api.github.com/users/{username})

````

- Authentication: ❌ Not required
- Scope: Public user data only

## Raw Response Overview

The GitHub API returns a large JSON object containing metadata, internal URLs,
and public profile information.

UnauthScout intentionally selects a **minimal subset** of stable, OSINT-relevant
fields for normalization.

## Field Mapping

| Raw Field        | Normalized Field | Included | Notes |
|------------------|------------------|----------|-------|
| `id`             | `id`             | ✅       | Stable unique identifier |
| `login`          | `login`          | ✅       | Username / handle |
| `name`           | `name`           | ✅       | Display name (nullable) |
| `type`           | `type`           | ✅       | User or Organization |
| `html_url`       | `html_url`       | ✅       | Public profile URL |
| `public_repos`   | `public_repos`   | ✅       | Public repository count |
| `followers`      | `followers`      | ✅       | Follower count |
| `following`      | `following`      | ✅       | Following count |
| `avatar_url`     | —                | ❌       | Cosmetic, excluded |
| `company`        | —                | ❌       | Often empty or noisy |
| `blog`           | —                | ❌       | User-controlled, unstable |
| `location`       | —                | ❌       | Free-form, inconsistent |
| `email`          | —                | ❌       | Null in unauth context |
| `bio`            | —                | ❌       | High variance |
| `twitter_username` | —             | ❌       | External enrichment |
| `created_at`     | —                | ❌       | Not required for MVP |
| `updated_at`     | —                | ❌       | Volatile |
| `repos_url`      | —                | ❌       | Internal API URL |
| `followers_url`  | —                | ❌       | Internal API URL |
| `events_url`     | —                | ❌       | Internal API URL |

## Normalization Logic

The current normalization is implemented as:

```bash
parse_github_user() {
    jq '{
        id,
        login,
        name,
        type,
        html_url,
        public_repos,
        followers,
        following
    }'
}
````

Only fields listed in the corresponding schema are emitted.

## Output Contract

The normalized output conforms to:

```
schemas/github_user.json
```

This schema is the **authoritative definition** of the GitHub user output.

## Rationale

Field inclusion follows these principles:

* Fields must be consistently present
* Fields must be OSINT-relevant
* Fields must be stable over time
* Fields must not require authentication

All other fields are intentionally excluded to preserve signal quality and
output predictability.

## Notes on Evolution

* Additional fields may be added in future versions via schema updates
* Authenticated fields will require a separate contract
* Breaking changes will be documented explicitly

## Summary

This mapping ensures that UnauthScout emits a **clean, minimal, and reliable**
representation of public GitHub user data suitable for automation and analysis.
