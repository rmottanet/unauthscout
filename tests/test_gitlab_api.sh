#!/usr/bin/env bash
# tests/test_gitlab_api.sh
# Responsabilidade: Validar o Contrato Unificado (v0.3.0) para GitLab

BASE_DIR=$(dirname "$(readlink -f "$0")")/..
source "${BASE_DIR}/lib/core.sh"
source "${BASE_DIR}/lib/gitlab_api.sh"

# Alvo de teste: Dmitriy Zaporozhets (Co-fundador do GitLab)
TEST_TARGET="dzaporozhets"

# --- Testes de Perfil de Usuário (Unified Intel) ---

test_get_user() {
    log_info "Testing: get_gitlab_user_raw"
    local raw
    raw=$(get_gitlab_user_raw "$TEST_TARGET")
    assert_not_empty "$raw" "Raw GitLab user data should not be empty"
}

test_normalize_user() {
    log_info "Testing: normalize_gitlab_user (Unified Schema)"
    local raw
    raw=$(get_gitlab_user_raw "$TEST_TARGET")
    
    local parsed
    parsed=$(echo "$raw" | normalize_gitlab_user)
    
    # 1. Valida Identidade e Plataforma (Obrigatórios do Contrato)
    local platform=$(echo "$parsed" | jq -r '.platform')
    local handle=$(echo "$parsed" | jq -r '.handle')
    
    [[ "$platform" == "gitlab" ]] || die "Platform mismatch: expected gitlab"
    [[ "$handle" == "$TEST_TARGET" ]] || die "Handle mismatch: expected $TEST_TARGET"
    
    # 2. Valida Mapeamento de Display Name
    local display_name=$(echo "$parsed" | jq -r '.display_name')
    assert_not_empty "$display_name" "Display name should be present (found: $display_name)"

    # 3. Valida Estrutura de Métricas (Mesmo que sejam null no GL público)
    # O importante é a chave existir para não quebrar o motor de Report
    if echo "$parsed" | jq -e '.metrics | has("public_repos")' > /dev/null; then
        log_success "Assertion Passed: Unified metrics structure exists"
    else
        log_error "Assertion Failed: metrics structure is missing"
        return 1
    fi

    log_success "Normalized user schema validated for GitLab"
}

# --- Testes de Repositórios/Projetos ---

test_get_repos() {
    log_info "Testing: get_gitlab_repos_raw"
    local raw
    raw=$(get_gitlab_repos_raw "$TEST_TARGET")
    
    if echo "$raw" | jq -e 'type == "array"' > /dev/null; then
        assert_not_empty "$raw" "Should return a JSON array of projects"
    else
        log_error "Assertion Failed: Output is not a JSON array"
        return 1
    fi
}


test_normalize_gitlab_repos() {
    log_info "Testing: normalize_gitlab_repos (Unified Schema)"
    
    local raw=$(get_gitlab_repos_raw "$TEST_TARGET")
    local parsed=$(echo "$raw" | normalize_gitlab_repos)

    # 1. Valida se o output é um array
    [[ "$(echo "$parsed" | jq -e 'type == "array"')" == "true" ]] || die "Output must be an array"

    local first_item=$(echo "$parsed" | jq '.[0]')

    # 2. Valida Honestidade Técnica (Language deve ser N/A)
    local lang=$(echo "$first_item" | jq -r '.language')
    if [[ "$lang" == "N/A" ]]; then
        log_success "Assertion Passed: language is correctly set to 'N/A' (GitLab constraint)"
    else
        die "Assertion Failed: language should be 'N/A', but got '$lang'"
    fi

    # 3. Valida Mapeamento de Nome Completo (Path with Namespace)
    local full_name=$(echo "$first_item" | jq -r '.full_name')
    assert_not_empty "$full_name" "Full name (path_with_namespace) should be present"

    # 4. Valida Estrelas (Mapeado de star_count)
    local stars=$(echo "$first_item" | jq -r '.stars')
    if [[ "$stars" =~ ^[0-9]+$ ]]; then
        log_success "Assertion Passed: stars is numeric ($stars)"
    else
        die "Assertion Failed: stars is not a number"
    fi

    # 5. Valida Tags (Mapeamento de .topics ou .tag_list)
    local topics_is_array=$(echo "$first_item" | jq -e '.topics | type == "array"')
    if [[ "$topics_is_array" == "true" ]]; then
        log_success "Assertion Passed: topics is a valid JSON array"
    else
        die "Assertion Failed: topics is missing or not an array"
    fi

    log_success "Normalized repositories schema validated for GitLab"
}


# --- Runner ---
run_all_gitlab_tests() {
    echo -e "\n${CLR_INFO}>>> Starting GitLab Unified Intel Tests (v0.3.0)${CLR_RESET}"
    echo "------------------------------------------------------------"
    
    test_get_user
    test_normalize_user    
    test_get_repos
    test_normalize_gitlab_repos

    echo "------------------------------------------------------------"
    log_success "All GitLab tests completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_gitlab_tests
fi
