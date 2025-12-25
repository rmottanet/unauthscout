# Unified User Field Mapping

This document describes how fields from **GitHub** and **GitLab** unauthenticated API responses are mapped and normalized into the unified UnauthScout v0.3.0 intelligence schema.

It provides a clear reference for:
- Cross-provider field normalization decisions
- Unified intelligence schema compliance
- Schema-driven OSINT reconnaissance

## Normalization Philosophy

UnauthScout v0.3.0 introduces a unified intelligence layer that transforms provider-specific data into a consistent format for cross-platform analysis and reporting.

The unified schema serves as:
1. **Single Source of Truth** for all downstream processing
2. **Provider Abstraction Layer** enabling consistent analysis
3. **Intelligence Foundation** for summarization and reporting

## Unified Schema Overview

The unified user schema (`schemas/unified_user.json`) defines the standard output contract for all user reconnaissance operations, regardless of source platform.

### Core Design Principles
- **Observability**: Include only publicly available fields
- **Stability**: Prioritize consistently available data
- **Intelligence Value**: Select fields relevant to OSINT analysis
- **Cross-Provider Consistency**: Map similar concepts to unified names

## Field Mapping Table

| Platform | Raw Field | Unified Field | Type | Notes |
|----------|-----------|---------------|------|-------|
| Both | — | `platform` | string | Source identifier: "github" or "gitlab" |
| GitHub | `login` | `handle` | string | Username/login identifier |
| GitLab | `username` | `handle` | string | Username identifier |
| GitHub | `name` | `display_name` | string | Display name (fallback: login) |
| GitLab | `name` | `display_name` | string | Display name (nullable) |
| GitHub | `html_url` | `profile_url` | URI | Full profile URL |
| GitLab | `web_url` | `profile_url` | URI | Full profile URL |
| GitHub | `email` | `email` | email/null | Public email (often null) |
| GitHub | `bio` | `bio` | string/null | User biography |
| GitHub | `location` | `location` | string/null | Geographic location |
| GitHub | `created_at` | `created_at` | date-time | Account creation |
| GitHub | `public_repos` | `metrics.public_repos` | integer/null | Public repository count |
| GitLab | — | `metrics.public_repos` | null | Not exposed in unauth API |
| GitHub | `followers` | `metrics.followers` | integer/null | Follower count |
| GitHub | `following` | `metrics.following` | integer/null | Following count |
| GitHub | `twitter_username` | `social.twitter` | string/null | Twitter handle |

## Normalization Implementation

The current normalization is implemented in provider-specific modules:

### GitHub Normalization
```bash
normalize_github_user() {
    jq '{
        platform: "github",
        handle: .login,
        display_name: (.name // .login),
        email: .email,
        profile_url: .html_url,
        metrics: {
            public_repos: .public_repos,
            followers: .followers,
            following: .following
        },
        social: {
            twitter: .twitter_username
        },
        location: .location,
        bio: .bio,
        created_at: .created_at
    }'
}
```

### GitLab Normalization
```bash
normalize_gitlab_user() {
    jq '.[0] | {
        platform: "gitlab",
        handle: .username,
        display_name: .name,
        profile_url: .web_url,
        metrics: {
            public_repos: null,
            followers: null,
            following: null
        },
        social: {
            twitter: null
        },
        bio: null,
        location: null,
        created_at: null
    }'
}
```

## Output Contract

The normalized output conforms to:

```
schemas/unified_user.json
```

This schema defines the authoritative structure for all user intelligence output in UnauthScout v0.3.0 and later.

## Field Availability Notes

### GitHub Advantages
- Richer unauthenticated API with 15+ public fields
- Social metadata (Twitter, location, bio)
- Metrics data (followers, following, public repos)
- Account creation timestamp

### GitLab Limitations
- Unauthenticated search endpoint returns limited data (5 core fields)
- No metrics, social, or temporal data in unauthenticated context
- Requires authentication for extended profile information

### Cross-Provider Strategy
- **Inclusive Mapping**: Include fields available from any provider
- **Null Placeholders**: Use null for unavailable data (ensures consistent schema)
- **Intelligence Awareness**: Summarization functions handle null values gracefully

## Rationale

The unified schema represents a strategic shift from provider-specific outputs to intelligence-focused data structures:

1. **Analysis Enablement**: Consistent structure enables cross-platform comparison
2. **Future Extensibility**: New providers map to existing unified fields
3. **Tool Integration**: External tools can consume a single format
4. **User Experience**: Report layer presents consistent information regardless of source

## Summary

This mapping documents the transformation from raw provider data to unified intelligence format, enabling UnauthScout's evolution from a data fetcher to a reconnaissance intelligence platform. The unified schema serves as the foundation for all v0.3.0 intelligence capabilities including summarization, cross-platform analysis, and enhanced reporting.
