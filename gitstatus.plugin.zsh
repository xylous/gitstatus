#!/usr/bin/zsh

###
# Unset global variables
# Globals:      all
# Arguments:    none
###
function sanitize() {
    unset GIT_CURRENT_BRANCH GIT_STATUS
    unset GIT_STAGED GIT_MODIFIED GIT_UNTRACKED GIT_DELETED
    unset GIT_COMMITS_BEHIND GIT_COMMITS_AHEAD GIT_COMMITS_STATUS
    git rev-parse --git-dir &>/dev/null || return 1
}

###
# Get necessary information from git, like current branch, amount of modified
# files etc. to then put them all into a global variable, GIT_STATUS
# Globals:      none
# Arguments:    none
###
function parse_git_status() {
    local modified_files=0 staged_files=0 untracked_files=0 deleted_files=0
    local git_has_changes=0
    GIT_CURRENT_BRANCH="$(git branch --show-current)"

    git status --porcelain=v1 | while IFS= read -r status_line; do
        git_has_changes=1
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
        local ahead_behind_status=$(git rev-list --left-right --count \
                                ${GIT_CURRENT_BRANCH}...${GIT_REMOTE_BRANCH})
        local commits_ahead=$(echo -n "$ahead_behind_status" | awk '{print $1}')
        local commits_behind=$(echo -n "$ahead_behind_status" | awk '{print $2}')
        
        (( ${commits_behind} > 0 )) \
            && GIT_COMMITS_BEHIND="↓${commits_behind} " \
            && git_has_changes=1
        (( ${commits_ahead} > 0 )) \
            && GIT_COMMITS_AHEAD="↑${commits_ahead} " \
            && git_has_changes=1
    fi
    GIT_COMMITS_STATUS="${GIT_COMMITS_AHEAD}${GIT_COMMITS_BEHIND}"

    if (( $git_has_changes )); then
        (( ${staged_files} > 0 )) \
            && GIT_STAGED="+${staged_files} "
        (( ${modified_files} > 0 )) \
            && GIT_MODIFIED="!${modified_files} "
        (( ${deleted_files} > 0 )) \
            && GIT_DELETED="-${deleted_files} "
        (( ${untracked_files} > 0 )) \
            && GIT_UNTRACKED="?${untracked_files}"
        local fg_special='%F{yellow}'
    else
        local fg_special='%F{34}'
    fi
    
    GIT_STATUS="${fg_special}"
    GIT_STATUS+=" ${GIT_CURRENT_BRANCH} "
    GIT_STATUS+="${GIT_COMMITS_STATUS}"
    GIT_STATUS+="${GIT_MODIFIED}${GIT_STAGED}"
    GIT_STATUS+="${GIT_DELETED}${GIT_UNTRACKED}"
    GIT_STATUS+="${FG_CLR}"

    # Remove trailing whitespace
    GIT_STATUS="$(sed 's/[ ]+$//' <<<"$GIT_STATUS")"
}

###
# Control script from here
# Globals:
#   none
# Arguments:
#   none
###
function main() {
    sanitize || return 1

    parse_git_status
}

main
