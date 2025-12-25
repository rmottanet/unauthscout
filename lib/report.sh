#!/usr/bin/env bash
# lib/report.sh

render_user_card() {
    local json="$1"
    
    # JQ extraction
    local handle=$(echo "$json" | jq -r '.handle')
    local twitter=$(echo "$json" | jq -r '.social.twitter // empty')
    local followers=$(echo "$json" | jq -r '.metrics.followers // empty')

    # Smart Display
    echo -e "Target: @${handle}"
    
    # If the Twitter handle is not null/empty, print the line.
    [[ -n "$twitter" ]] && echo -e "Twitter: https://twitter.com/${twitter}"
    
    # If followers exist (GH), print it. In GL it will be hidden.
    [[ -n "$followers" ]] && echo -e "Followers: ${followers}"
}


render_user_report() {
    local json="$1"
    [[ -z "$json" || "$json" == "null" ]] && return 1

    local platform=$(echo "$json" | jq -r '.platform')
    local handle=$(echo "$json" | jq -r '.handle')
    local name=$(echo "$json" | jq -r '.display_name')
    local profile_url=$(echo "$json" | jq -r '.profile_url')
    local bio=$(echo "$json" | jq -r '.bio // empty')

    local color="${CLR_INFO}"
    [[ "$platform" == "github" ]] && color="${CLR_SUCCESS}"

    echo -e "\n${color}[ ${platform^^} PROFILE: @${handle} ]${CLR_RESET}"
    echo -e "${CLR_BOLD}Name:${CLR_RESET}    $name"
    echo -e "${CLR_BOLD}Link:${CLR_RESET}    $profile_url"
    [[ -n "$bio" && "$bio" != "null" ]] && echo -e "${CLR_BOLD}Bio:${CLR_RESET}     $bio"
}


render_repos_list() {
    local json=$(cat)
    [[ -z "$json" || "$json" == "null" || "$json" == "[]" ]] && return 0

    echo -e "\n${CLR_INFO}Top Public Repositories (Unified Intel):${CLR_RESET}"
    
    # Format: Last Activity | Name | Language | Stars
    # Extracting only the first 10 characters of the date (YYYY-MM-DD)
    echo "$json" | jq -r '.[] | "\(.updated_at[0:10]) | \(.full_name) | \(.language) | \(.stars)★"' \
        | column -t -s "|" | sed 's/^/  /'

}


render_intel_summary() {
    local json=$(cat)
    [[ -z "$json" || "$json" == "null" || "$json" == "[]" ]] && return 0

    # Intelligence Calculations via JQ
    local total_stars=$(echo "$json" | jq '[.[].stars] | add')
    local top_repo=$(echo "$json" | jq -r 'sort_by(.stars) | last | "\(.full_name) (\(.stars)★)"')
    
    # Extraction of Top Languages ​​(Ignores GitLab's N/A to avoid bias)
    local top_langs=$(echo "$json" | jq -r '
        [.[].language | select(. != "N/A" and . != null)] 
        | group_by(.) 
        | map({lang: .[0], count: length}) 
        | sort_by(-.count) 
        | [.[0:3][].lang] 
        | join(", ")
    ')

    # Intel Panel Display
    echo -e "\n${CLR_WARN}[ 🧠 RECON INTELLIGENCE SUMMARY ]${CLR_RESET}"
    echo -e "${CLR_BOLD}Total Stars:${CLR_RESET}    $total_stars ★"
    echo -e "${CLR_BOLD}Top Languages:${CLR_RESET}  ${top_langs:-N/A (GitLab constraint)}"
    echo -e "${CLR_BOLD}Most Starred:${CLR_RESET}   $top_repo"
    
    # Activity Insights
    local last_act=$(echo "$json" | jq -r 'map(.updated_at) | sort | last | .[0:10]')
    echo -e "${CLR_BOLD}Latest Activity:${CLR_RESET} $last_act"
}
