#!/usr/bin/env bash
# tests/test_gitlab_api.sh
# Responsabilidade: Validar as funções de integração com a API do GitLab

BASE_DIR=$(dirname "$(readlink -f "$0")")/..
source "${BASE_DIR}/lib/core.sh"
source "${BASE_DIR}/lib/gitlab_api.sh"

# Alvo de teste (usuário real para validação de integração)
TEST_TARGET="dzaporozhets"

# --- Testes de Perfil de Usuário ---

test_get_user() {
    log_info "Testing: get_gitlab_user_raw"
    local raw
    raw=$(get_gitlab_user_raw "$TEST_TARGET")
    assert_not_empty "$raw" "Raw user data should not be empty"
}

test_parse_user() {
    log_info "Testing: parse_gitlab_user"
    local raw
    raw=$(get_gitlab_user_raw "$TEST_TARGET")
    
    local parsed
    parsed=$(echo "$raw" | parse_gitlab_user)
    
    local username
    username=$(echo "$parsed" | jq -r '.username')
    
    # Valida se o parser extraiu o username correto
    [[ "$username" == "$TEST_TARGET" ]]
    assert_not_empty "$username" "Parsed username should match $TEST_TARGET"
}

# --- Testes de Repositórios/Projetos ---

test_get_repos() {
    log_info "Testing: get_gitlab_repos_raw"
    local raw
    raw=$(get_gitlab_repos_raw "$TEST_TARGET")
    
    # Validação estrutural: O endpoint de projetos DEVE retornar um array
    if echo "$raw" | jq -e 'type == "array"' > /dev/null; then
        assert_not_empty "$raw" "Should return a JSON array of projects"
    else
        log_error "Assertion Failed: Output is not a JSON array"
        return 1
    fi
}

test_parse_repos() {
    log_info "Testing: parse_gitlab_repos"
    local raw
    raw=$(get_gitlab_repos_raw "$TEST_TARGET")
    
    local parsed
    parsed=$(echo "$raw" | parse_gitlab_repos)
    
    # Verifica presença de campos mapeados no primeiro item da lista
    local first_item_name
    first_item_name=$(echo "$parsed" | jq -r -s '.[0].name')
    assert_not_empty "$first_item_name" "Parsed output should contain project names (found: $first_item_name)"
    
    # Verifica se o mapeamento 'path_with_namespace' -> 'path' funcionou
    local first_item_path
    first_item_path=$(echo "$parsed" | jq -r -s '.[0].path')
    assert_not_empty "$first_item_path" "Parsed output should have path_with_namespace mapped to 'path'"
}

# --- Runner ---
# Orquestra a execução de todos os testes deste módulo
run_all_gitlab_tests() {
    echo -e "\n${CLR_INFO}>>> Starting GitLab API Integration Tests${CLR_RESET}"
    echo "------------------------------------------------------------"
    
    test_get_user
    test_parse_user    
    test_get_repos
    test_parse_repos

    echo "------------------------------------------------------------"
    log_success "All GitLab tests completed."
}

# Execução condicional: só roda se o script for chamado diretamente
# Isso permite que as funções sejam importadas por outros scripts sem rodar o runner
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_gitlab_tests
fi
