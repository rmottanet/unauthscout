#!/usr/bin/env bash
# lib/core.sh
# Core utility functions for UnauthScout

VERSION="v0.3.0"

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

# --- Error Handling (Responsibility: Critical failure management) ---
# Imprime um erro formatado e encerra o script imediatamente.
die() {
    log_error "$*"
    exit 1
}

# --- Input Validation ---
is_empty() {
    [[ -z "$1" ]]
}

# --- Standard for integration (Compact Mode)  ---
JQ_OPTS="-c" 

set_pretty_mode() {
    # No modo pretty, remove o -c. 
    # Deixar vazio para o jq usar o padrão identado.
    JQ_OPTS="" 
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
UnauthScout v0.3.0 - Unified OSINT Reconnaissance for GitLab & GitHub

Usage:
    $(basename "$0") [options] <username>

Arguments:
    <username>      The target git username to scout.

Platform Filters:
    -gh, --github   Search only on GitHub.
    -gl, --gitlab   Search only on GitLab.
    (If neither is specified, both platforms are searched)

Recon & Intelligence:
    -r, --repos     Fetch and list public repositories/projects.
    -s, --summarize Generate an intelligence summary (Total stars, Top langs, 
                    Activity insights). Requires -r.

Output Formatting:
    --raw           Output unified JSON. Optimized for machine integration.
                    (Default: Compact mode for piping).
    --pretty        Indents JSON output for human readability. 
                    (Only effective when used with --raw).

General Options:
    -h, --help      Show this help message and exit.
    -v, --version   Show version information and exit.

Examples:
    ./bin/unauthscout rmottanet -r -s           # Full human-readable report
    ./bin/unauthscout rmottanet --raw           # Compact JSON for scripts
    ./bin/unauthscout rmottanet --raw --pretty  # Formatted JSON for analysis
    ./bin/unauthscout torvalds -gh -r -s        # GitHub specific scout

Note: This tool uses public unauthenticated endpoints.
      - GitLab: 'Language' field is limited to 'N/A' due to API architecture.
      - Rate limits: Subject to platform-specific IP quotas (GH is stricter).
EOF
}

show_version() {
    echo "UnauthScout $VERSION"
}
