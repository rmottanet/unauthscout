#!/usr/bin/env bash
# tests/test_github_api.sh
# Responsabilidade: Validar as funções de integração com a API do GitHub (OSINT)

BASE_DIR=$(dirname "$(readlink -f "$0")")/..
source "${BASE_DIR}/lib/core.sh"
source "${BASE_DIR}/lib/github_api.sh"

# Alvo de teste (usando 'google' ou 'github' como alvos públicos estáveis)
TEST_TARGET="torvalds"

# --- Testes de Perfil de Usuário ---

test_get_user() {
    log_info "Testing: get_github_user_raw"
    local raw
    raw=$(get_github_user_raw "$TEST_TARGET")
    assert_not_empty "$raw" "Raw GitHub user data should not be empty"
}

test_parse_user() {
    log_info "Testing: parse_github_user"
    local raw
    raw=$(get_github_user_raw "$TEST_TARGET")
    
    local parsed
    parsed=$(echo "$raw" | parse_github_user)
    
    # No GitHub, o campo é 'login' (conforme seu github_api.sh)
    local login
    login=$(echo "$parsed" | jq -r '.login')
    
    [[ "$login" == "$TEST_TARGET" ]]
    assert_not_empty "$login" "Parsed login should match $TEST_TARGET"
}

# --- Testes de Repositórios ---

test_get_repos() {
    log_info "Testing: get_github_repos_raw"
    local raw
    raw=$(get_github_repos_raw "$TEST_TARGET")
    
    # O GitHub retorna um array para a lista de repositórios
    if echo "$raw" | jq -e 'type == "array"' > /dev/null; then
        assert_not_empty "$raw" "Should return a JSON array of repositories"
    else
        log_error "Assertion Failed: Output is not a JSON array"
        return 1
    fi
}

test_parse_repos() {
    log_info "Testing: parse_github_repos"
    local raw
    raw=$(get_github_repos_raw "$TEST_TARGET")
    local parsed
    parsed=$(echo "$raw" | parse_github_repos)
    
    # Valida o mapeamento de campos (GitHub original 'stargazers_count' -> nosso 'stars')
    local first_item_stars
    first_item_stars=$(echo "$parsed" | jq -r -s '.[0].stars')
    
    # Verifica se o campo 'stars' existe no objeto parseado (mesmo que seja 0)
    if [[ "$first_item_stars" =~ ^[0-9]+$ ]]; then
        log_success "Assertion Passed: Field 'stars' is present and numeric"
    else
        log_error "Assertion Failed: Field 'stars' missing or not numeric"
        return 1
    fi
    
    # Valida o mapeamento de URL
    local first_url
    first_url=$(echo "$parsed" | jq -r -s '.[0].url')
    assert_not_empty "$first_url" "Parsed output should have html_url mapped to 'url'"
}

# --- Runner ---
run_all_github_tests() {
    echo -e "\n${CLR_INFO}>>> Starting GitHub API Integration Tests${CLR_RESET}"
    echo "------------------------------------------------------------"
    
    # Nota: Cuidado com o Rate Limit do GitHub (60 req/hora para IP não autenticado)
    test_get_user
    test_parse_user    
    test_get_repos
    test_parse_repos

    echo "------------------------------------------------------------"
    log_success "All GitHub tests completed."
}

# Execução condicional
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_github_tests
fi
