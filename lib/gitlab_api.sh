#!/usr/bin/env bash
# lib/gitlab_api.sh

GITLAB_BASE_URL="https://gitlab.com/api/v4"

get_gitlab_user_raw() {
    local username=$1
    curl -sf "${GITLAB_BASE_URL}/users?username=${username}"
}

parse_gitlab_user() {
    jq '.[0] | {
        id,
        username,
        name,
        state,
        web_url
    }'
}

# --- Repository/Project Functions ---
get_gitlab_repos_raw() {
    local username=$1
    curl -sf "${GITLAB_BASE_URL}/users/${username}/projects?visibility=public&per_page=100"
}

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
