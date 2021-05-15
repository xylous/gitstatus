#!/usr/bin/zsh

###
# Do some cleaning if not in a git repository
# Globals:
#   all
# Arguments:
#   none
###
function sanitize() {
    if ! git rev-parse --git-dir &>/dev/null; then
        GIT_HAS_CHANGES=false
        GIT_BRANCH=""
        GIT_STAGED=""
        GIT_MODIFIED=""
        GIT_UNTRACKED=""
        GIT_STATUS=""
        return 1
    fi

    return 0
}

###
# Get necessary information from git, like current branch, amount of modified
# files etc. to then put them all into a global variable, GIT_STATUS
# Globals:
#   none
# Arguments:
#   none
###
function parse_git_status() {
    local modified_files=0 staged_files=0 untracked_files=0 deleted_files=0
    GIT_HAS_CHANGES=0
    GIT_BRANCH="$(git branch --show-current)"

    git status --porcelain=v1 | while IFS= read -r status_line; do
        GIT_HAS_CHANGES=1
        case "$status_line" in
            ' M '*) 
                ((modified_files++))
                ;;
            'A  '*|'M '*)
                ((staged_files++))
                ;;
            ' D '*)
                ((deleted_files++))
                ;;
            '?? '*)
                ((untracked_files++))
                ;;
            'MM '*)
                ((staged_files++))
                ((modified_files++))
                ;;
        esac
    done

    GIT_REMOTE_BRANCH=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)")
    local ahead_behind_status commits_behind commits_ahead
    if [[ ! -z ${GIT_REMOTE_BRANCH} ]]; then
        ahead_behind_status=$(git rev-list --left-right --count ${GIT_BRANCH}...${GIT_REMOTE_BRANCH})
        commits_ahead=$(echo -n "$ahead_behind_status" | awk '{print $1}')
        commits_behind=$(echo -n "$ahead_behind_status" | awk '{print $2}')
        
        (( ${commits_behind} > 0))  \
            && GIT_COMMITS_BEHIND="↓${commits_behind} " \
            || GIT_COMMITS_BEHIND=""
        (( ${commits_ahead} > 0))  \
            && GIT_COMMITS_AHEAD="↑${commits_ahead} " \
            || GIT_COMMITS_AHEAD=""
    fi

    (( ${staged_files} > 0 )) \
        && GIT_STAGED="${staged_files}+ " \
        || GIT_STAGED=""
    (( ${modified_files} > 0 )) \
        && GIT_MODIFIED="!${modified_files} " \
        || GIT_MODIFIED=""
    (( ${deleted_files} > 0 )) \
        && GIT_DELETED="${deleted_files}- " \
        || GIT_DELETED=""
    (( ${untracked_files} > 0 )) \
        && GIT_UNTRACKED="?${untracked_files}" \
        || GIT_UNTRACKED=""
    
    if (( GIT_HAS_CHANGES == 1 )); then
        FG_SPECIAL_COLOR="${FG_YELLOW}"
    else
        FG_SPECIAL_COLOR="${FG_GREEN}"
    fi

    GIT_COMMITS_STATUS="${GIT_COMMITS_AHEAD}${GIT_COMMITS_BEHIND}"
    
    GIT_STATUS="| ${FG_SPECIAL_COLOR}"
    GIT_STATUS+=" ${GIT_BRANCH} "
    GIT_STATUS+="${GIT_COMMITS_STATUS}"
    GIT_STATUS+="${GIT_MODIFIED}${GIT_STAGED}"
    GIT_STATUS+="${GIT_DELETED}${GIT_UNTRACKED}"
    GIT_STATUS+="${FG_CLR}"
}

###
# Control script from here
# Globals:
#   none
# Arguments:
#   none
###
function main() {
    if ! sanitize; then
        return 0
    fi

    parse_git_status
}

main
