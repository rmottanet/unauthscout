#!/usr/bin/env bash
# lib/gitlab_api.sh

GITLAB_BASE_URL="https://gitlab.com/api/v4"

get_gitlab_user_raw() {
    local username=$1
    curl -sf "${GITLAB_BASE_URL}/users?username=${username}"
}

# Responsibility: Normalize to the Unified Schema
# Even with less data, we maintain the structure to avoid breaking the Intel/Report engine.
normalize_gitlab_user() {
    jq ${JQ_OPTS} '.[0] | {
        platform: "gitlab",
        handle: .username,
        display_name: (.name // .username),
        email: (.public_email // null),
        profile_url: .web_url,
        metrics: {
            public_repos: null,
            followers: null,
            following: null
        },
        social: {
            twitter: null
        },
        location: null,
        bio: null,
        created_at: null
    }'
}


# --- Repository/Project Functions ---
get_gitlab_repos_raw() {
    local username=$1
    # GitLab calls repositories "projects"
    # visibility=public ensures focus on OSINT without authentication.
    curl -sf "${GITLAB_BASE_URL}/users/${username}/projects?visibility=public&per_page=100"
}

normalize_gitlab_repos() {
    jq ${JQ_OPTS} 'map({
        name: .name,
        full_name: .path_with_namespace,
        url: .web_url,
        description: (.description // ""),
        stars: .star_count,
        language: "N/A",
        updated_at: .last_activity_at,
        topics: (.topics // .tag_list // [])
    })'
}
