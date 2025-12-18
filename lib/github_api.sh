#!/usr/bin/env bash
# lib/github_api.sh

GITHUB_BASE_URL="https://api.github.com"

get_github_user_raw() {
    local username=$1
    curl -sf "${GITHUB_BASE_URL}/users/${username}"
}

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
