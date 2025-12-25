#!/usr/bin/env bash
# tests/test_github_api.sh

BASE_DIR=$(dirname "$(readlink -f "$0")")/..
source "${BASE_DIR}/lib/core.sh"
source "${BASE_DIR}/lib/github_api.sh"

# Alvo de teste (Linus Torvalds é uma excelente escolha para OSINT)
TEST_TARGET="torvalds"

# --- Testes de Perfil de Usuário (Unified Intel) ---

test_get_user() {
    log_info "Testing: get_github_user_raw"
    local raw
    raw=$(get_github_user_raw "$TEST_TARGET")
    assert_not_empty "$raw" "Raw GitHub user data should not be empty"
}

test_normalize_user() {
    log_info "Testing: normalize_github_user (Unified Schema)"
    local raw
    raw=$(get_github_user_raw "$TEST_TARGET")
    
    local parsed
    parsed=$(echo "$raw" | normalize_github_user)
    
    # 1. Valida Identidade e Plataforma
    local platform=$(echo "$parsed" | jq -r '.platform')
    local handle=$(echo "$parsed" | jq -r '.handle')
    [[ "$platform" == "github" ]] || die "Platform mismatch"
    [[ "$handle" == "$TEST_TARGET" ]] || die "Handle mismatch"
    
    # 2. Valida Mapeamento de Display Name (Clean Code: Fallback test)
    local display_name=$(echo "$parsed" | jq -r '.display_name')
    assert_not_empty "$display_name" "Display name should be present"

    # 3. Valida Estrutura de Métricas (Nested Objects)
    local followers=$(echo "$parsed" | jq -r '.metrics.followers')
    if [[ "$followers" =~ ^[0-9]+$ ]]; then
        log_success "Assertion Passed: metrics.followers is numeric ($followers)"
    else
        log_error "Assertion Failed: metrics.followers is missing or invalid"
        return 1
    fi

    log_success "Normalized user schema validated for GitHub"
}

# --- Testes de Repositórios ---

test_get_repos() {
    log_info "Testing: get_github_repos_raw"
    local raw
    raw=$(get_github_repos_raw "$TEST_TARGET")
    
    if echo "$raw" | jq -e 'type == "array"' > /dev/null; then
        assert_not_empty "$raw" "Should return a JSON array of repositories"
    else
        log_error "Assertion Failed: Output is not a JSON array"
        return 1
    fi
}


test_normalize_repos() {
    log_info "Testing: normalize_github_repos (Unified Schema)"
    
    # 1. Obtém e normaliza
    local raw=$(get_github_repos_raw "$TEST_TARGET")
    local parsed=$(echo "$raw" | normalize_github_repos)

    # 2. Valida se o resultado ainda é um array
    local is_array=$(echo "$parsed" | jq -e 'type == "array"')
    [[ "$is_array" == "true" ]] || die "Normalized output must be an array"

    # 3. Valida o primeiro item do array contra o Contrato v0.3.0
    local first_item=$(echo "$parsed" | jq '.[0]')
    
    # Teste de campos obrigatórios e tipos
    local name=$(echo "$first_item" | jq -r '.name')
    local stars=$(echo "$first_item" | jq -r '.stars')
    local updated=$(echo "$first_item" | jq -r '.updated_at')
    local topics_is_array=$(echo "$first_item" | jq -e '.topics | type == "array"')

    assert_not_empty "$name" "Repo name should be present"
    
    if [[ "$stars" =~ ^[0-9]+$ ]]; then
        log_success "Assertion Passed: repo.stars is numeric ($stars)"
    else
        die "Assertion Failed: repo.stars is not a number"
    fi

    if [[ "$updated" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        log_success "Assertion Passed: repo.updated_at follows ISO date ($updated)"
    else
        die "Assertion Failed: repo.updated_at format invalid"
    fi

    if [[ "$topics_is_array" == "true" ]]; then
        log_success "Assertion Passed: repo.topics is a JSON array"
    else
        die "Assertion Failed: repo.topics is missing or not an array"
    fi

    log_success "Normalized repositories schema validated for GitHub"
}


# --- Runner ---
run_all_github_tests() {
    echo -e "\n${CLR_INFO}>>> Starting GitHub Unified Intel Tests (v0.3.0)${CLR_RESET}"
    echo "------------------------------------------------------------"
    
    test_get_user
    test_normalize_user    
    test_get_repos
    test_normalize_repos

    echo "------------------------------------------------------------"
    log_success "All GitHub tests completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_github_tests
fi
