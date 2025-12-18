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
