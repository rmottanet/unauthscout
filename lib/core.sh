#!/usr/bin/env bash
# lib/core.sh
# Core utility functions for UnauthScout

# --- Colors for Output (UX/Clean Code) ---
readonly CLR_RESET='\033[0m'
readonly CLR_INFO='\033[36m'    # Ciano
readonly CLR_SUCCESS='\033[32m' # Verde
readonly CLR_WARN='\033[33m'    # Amarelo
readonly CLR_ERR='\033[31m'     # Vermelho

# --- Logging Functions (Responsibility: Standardize output) ---
log_info()    { echo -e "${CLR_INFO}[INFO]${CLR_RESET} $*"; }
log_success() { echo -e "${CLR_SUCCESS}[OK]${CLR_RESET} $*"; }
log_warn()    { echo -e "${CLR_WARN}[WARN]${CLR_RESET} $*"; }
log_error()   { echo -e "${CLR_ERR}[ERROR]${CLR_RESET} $*" >&2; }

# --- Environment Validation (KISS) ---
# Ensures that the basic dependencies exist before running the rest.
check_dependencies() {
    local deps=("curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "Dependência não encontrada: $dep. Por favor, instale-a para continuar."
            exit 1
        fi
    done
}

# --- Input Validation ---
is_empty() {
    [[ -z "$1" ]]
}

# --- Test Validation ---
assert_not_empty() {
    local data="$1"
    local msg="$2"
    if [[ -n "$data" && "$data" != "[]" && "$data" != "{}" ]]; then
        log_success "Assertion Passed: $msg"
        return 0
    else
        log_error "Assertion Failed: $msg"
        return 1
    fi
}

# --- Help Message ---
show_help() {
    cat << EOF
UnauthScout - OSINT reconnaissance for GitLab & GitHub (Unauthenticated)

Usage:
    $(basename "$0") [options] <username>

Arguments:
    <username>      The target git username to scout.

Platform Filters:
    -gh, --github   Search only on GitHub.
    -gl, --gitlab   Search only on GitLab.
    (If neither is specified, both platforms are searched)

Search Options:
    -r, --repos     List public repositories/projects for the user.
    --raw           Output raw JSON instead of formatted results.

General Options:
    -h, --help      Show this help message and exit.

Examples:
    ./bin/unauthscout rmottanet
    ./bin/unauthscout --gitlab -r dzaporozhets
    ./bin/unauthscout -gh --raw torvalds

Note: This tool uses public endpoints and does not require API tokens.
      Subject to rate limits (especially GitHub).
EOF
}
