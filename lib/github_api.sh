#!/usr/bin/env bash
# lib/github_api.sh

GITHUB_BASE_URL="https://api.github.com"

get_github_user_raw() {
    local username=$1
    curl -sf -A "UnauthScout-Scanner" "${GITHUB_BASE_URL}/users/${username}"
}

# Responsibility: Normalize JSON to the UnauthScout Schema (Unified Intel)
normalize_github_user() {
    jq ${JQ_OPTS} '{
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


# --- Repository Functions ---
get_github_repos_raw() {
    local username=$1
    # The default endpoint for listing a user's repositories.
    # per_page=1000 This is the maximum allowed per page on GitHub.
    curl -sf -A "UnauthScout-Scanner" "${GITHUB_BASE_URL}/users/${username}/repos?type=public&per_page=100&sort=updated"
}

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
