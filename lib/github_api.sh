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


# --- Repository Functions ---
# SRP: Responsabilidade única de buscar os repositórios brutos
get_github_repos_raw() {
    local username=$1
    # O endpoint padrão para listar repositórios de um usuário
    # per_page=100 é o máximo permitido por página no GitHub
    curl -sf -A "UnauthScout-Scanner" \
        "${GITHUB_BASE_URL}/users/${username}/repos?type=public&per_page=100&sort=updated"
}

# SRP: Responsabilidade única de filtrar e formatar a saída para o Scout
parse_github_repos() {
    # Mapeamos os campos do GitHub para manter um padrão próximo ao do GitLab
    jq '.[] | {
        id,
        name: .name,
        full_name: .full_name,
        description,
        url: .html_url,
        stars: .stargazers_count,
        forks: .forks_count,
        language
    }'
}
