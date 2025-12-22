# GitLab API Field Mapping

This document describes how fields from the **unauthenticated GitLab Users API**
response are mapped and normalized by UnauthScout.

It provides a clear reference for:
- Raw field visibility in unauthenticated requests
- Normalization decisions
- Schema alignment and auditability

## Endpoint

```

GET [https://gitlab.com/api/v4/users?username={username}](https://gitlab.com/api/v4/users?username={username})

```

- Authentication: ❌ Not required
- Scope: Public user search results

> Note: This endpoint returns an **array**. UnauthScout operates on the first
> matching entry.

## Raw Response Overview

The unauthenticated GitLab user search endpoint returns a limited set of public
fields. Several attributes available in authenticated contexts are intentionally
absent.

UnauthScout normalizes only fields that are **observable and stable** in the
unauthenticated response.

## Field Mapping

| Raw Field        | Normalized Field | Included | Notes |
|------------------|------------------|----------|-------|
| `id`             | `id`             | ✅       | Stable unique identifier |
| `username`       | `username`       | ✅       | User handle |
| `name`           | `name`           | ✅       | Display name (nullable) |
| `state`          | `state`          | ✅       | Account state |
| `web_url`        | `web_url`        | ✅       | Public profile URL |
| `avatar_url`     | —                | ❌       | Cosmetic |
| `public_email`   | —                | ❌       | Empty in unauth context |
| `locked`         | —                | ❌       | Internal account state |
| `created_at`     | —                | ❌       | Not exposed without auth |
| `bio`            | —                | ❌       | Not available |
| `location`       | —                | ❌       | Not available |

## Normalization Logic

The current normalization is implemented as:

```bash
parse_gitlab_user() {
    jq '.[0] | {
        id,
        username,
        name,
        state,
        web_url
    }'
}
```

The parser explicitly selects the first matching user from the search result
array.

## Output Contract

The normalized output conforms to:

```
schemas/gitlab_user.json
```

This schema defines the authoritative structure of unauthenticated GitLab user
output.

## Rationale

Field selection follows these constraints:

* Fields must be returned by the unauthenticated endpoint
* Fields must be consistently present across users
* Fields must be OSINT-relevant
* Fields must avoid internal or cosmetic noise

Normalization intentionally excludes fields that:

* Require authentication
* Are unstable or sparsely populated
* Represent internal platform mechanics

## Notes on Endpoint Limitations

* The `/users?username=` endpoint is a **search**, not a direct lookup
* Ambiguous usernames may return multiple results
* UnauthScout currently selects the first result only

These limitations are documented by design and may be addressed in future
iterations.

## Summary

This mapping documents the exact transformation from raw unauthenticated GitLab
API data to a minimal, normalized representation suitable for OSINT workflows
and automation.
