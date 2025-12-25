# Unified Repository Field Mapping

This document describes how fields from **GitHub** and **GitLab** unauthenticated repository API responses are mapped and normalized into the unified UnauthScout v0.3.0 intelligence schema.

It provides a clear reference for:
- Cross-provider repository field normalization
- Unified intelligence schema for asset enumeration
- Schema-driven repository analysis and summarization

## Normalization Philosophy

UnauthScout v0.3.0 introduces a unified repository schema that transforms provider-specific project data into a consistent format for cross-platform asset analysis. This enables intelligence operations like language analysis, activity tracking, and popularity metrics across both GitHub and GitLab.

The unified repository schema serves as:
1. **Asset Intelligence Foundation** for repository enumeration
2. **Cross-Platform Consistency** enabling unified analysis
3. **Summarization Input** for intelligence reporting

## Unified Schema Overview

The unified repository schema (`schemas/unified_repo.json`) defines the standard output contract for all repository enumeration operations, regardless of source platform.

### Core Design Principles
- **Observability**: Include only publicly available repository fields
- **OSINT Relevance**: Prioritize fields useful for reconnaissance analysis
- **Platform Constraints**: Acknowledge GitLab's language limitation
- **Array Consistency**: Standardize on array format for multiple repositories

## Field Mapping Table

| Platform | Raw Field | Unified Field | Type | Notes |
|----------|-----------|---------------|------|-------|
| GitHub | `name` | `name` | string | Repository short name |
| GitLab | `name` | `name` | string | Project short name |
| GitHub | `full_name` | `full_name` | string | `owner/name` format |
| GitLab | `path_with_namespace` | `full_name` | string | Equivalent path format |
| GitHub | `html_url` | `url` | URI | Repository web URL |
| GitLab | `web_url` | `url` | URI | Project web URL |
| GitHub | `description` | `description` | string | Project description (empty if null) |
| GitLab | `description` | `description` | string | Project description (empty if null) |
| GitHub | `stargazers_count` | `stars` | integer | Star count (≥ 0) |
| GitLab | `star_count` | `stars` | integer | Star count (≥ 0) |
| GitHub | `language` | `language` | string | Primary language (null → "N/A") |
| GitLab | — | `language` | string | Always "N/A" (GitLab API limitation) |
| GitHub | `updated_at` | `updated_at` | date-time | Last activity timestamp (ISO 8601) |
| GitLab | `last_activity_at` | `updated_at` | date-time | Last activity timestamp |
| GitHub | `topics` | `topics` | array[string] | Repository topics/tags |
| GitLab | `tag_list` | `topics` | array[string] | Project tags |

## Normalization Implementation

The current normalization is implemented in provider-specific modules:

### GitHub Normalization
```bash
normalize_github_repos() {
    jq ${JQ_OPTS} 'map({
        name: .name,
        full_name: .full_name,
        url: .html_url,
        description: (.description // ""),
        stars: .stargazers_count,
        language: (.language // "N/A"),
        updated_at: .updated_at,
        topics: (.topics // [])
    })'
}
```

### GitLab Normalization
```bash
normalize_gitlab_repos() {
    jq ${JQ_OPTS} 'map({
        name: .name,
        full_name: .path_with_namespace,
        url: .web_url,
        description: (.description // ""),
        stars: .star_count,
        language: "N/A",
        updated_at: .last_activity_at,
        topics: (.tag_list // [])
    })'
}
```

## Output Contract

The normalized output conforms to:

```
schemas/unified_repo.json
```

This schema defines the authoritative structure for all repository intelligence output in UnauthScout v0.3.0 and later.

## Platform-Specific Considerations

### GitHub Advantages
- Language detection available in unauthenticated API
- Rich topic/tag system with dedicated `topics` field
- Consistent `updated_at` field for activity tracking
- `forks_count` available (not currently mapped to unified schema)

### GitLab Limitations
- **Language Detection**: Not available in unauthenticated API - always returns "N/A"
- **Tag System**: Uses `tag_list` instead of `topics`
- **Activity Tracking**: Uses `last_activity_at` instead of `updated_at`
- **Popularity Metrics**: Limited to `star_count` (no fork count in standard response)

### Cross-Provider Strategy
- **Consistent Field Names**: Map similar concepts to same unified names
- **Default Values**: Use "N/A" for unavailable language data
- **Empty Placeholders**: Empty arrays/strings for null values
- **Intelligence Awareness**: Summarization handles platform differences

## Intelligence Applications

The unified repository schema enables several intelligence capabilities:

1. **Language Analysis**: Identify primary programming languages (GitHub only)
2. **Popularity Metrics**: Compare star counts across platforms
3. **Activity Tracking**: Determine recent project activity
4. **Topic Analysis**: Identify project focus areas and technologies
5. **Asset Enumeration**: Comprehensive list of public repositories/projects

## Rationale

The unified repository schema represents a strategic shift from provider-specific asset listing to intelligence-focused repository analysis:

1. **Cross-Platform Analysis**: Enables comparison of repositories across GitHub and GitLab
2. **Summarization Foundation**: Provides consistent data structure for intelligence reporting
3. **Tool Integration**: External tools can consume standardized repository data
4. **Future Extensibility**: New repository fields can be added to unified schema

## Summary

This mapping documents the transformation from raw provider repository data to unified intelligence format, enabling UnauthScout's asset enumeration capabilities. The unified repository schema serves as the foundation for v0.3.0 intelligence features including language analysis, activity tracking, and cross-platform repository summarization.
