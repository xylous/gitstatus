#!/usr/bin/zsh

function main() {
    is_in_git_repository || return 1

    parse_git_status
    local modified="${STATUS[1]}"
    local staged="${STATUS[2]}"
    local deleted="${STATUS[3]}"
    local untracked="${STATUS[4]}"
    unset STATUS

    git_grab_current_branch
    local branch="$REPLY"

    git_grab_remote_branch
    local remote="$REPLY"

    [[ ! -z "$remote" ]] \
        && get_differences_between_remote_and_local "$branch" "$remote" \
        && local commit_diffs="$REPLY"

    git_determine_color $modified $staged $deleted $untracked
    local color="$REPLY"

    (( modified > 0 )) \
        && modified="!$modified "
    (( staged > 0 )) \
        && staged="+$staged "
    (( deleted > 0 )) \
        && deleted="-$deleted "
    (( untracked > 0 )) \
        && untracked="?$untracked"

    local output="${color}"
            output+=" $branch"
            output+="$commit_diffs"
            output+="$modified"
            output+="$staged"
            output+="$deleted"
            output+="$untracked"
            output+=$'\e[0m'

    sed 's/[ ]+$//' <<<"$output" # remove trailing whitespace
}

###
# Check if we're in a git repository
# Globals:      none
# Arguments:    none
###
function is_in_git_repository()
{
    git rev-parse --git-dir &>/dev/null || return 1
}

function git_grab_current_branch()
{
    typeset -g REPLY="$(git branch --show-current)"
}

function git_grab_remote_branch()
{
    local symbolic_ref="$(git symbolic-ref -q HEAD)"
    typeset -g REPLY="$(git for-each-ref --format='%(upstream:short)' $symbolic_ref)"
}

###
# Find how many things have changed since last commit
# Globals:      none
# Arguments:    none
###
function parse_git_status()
{
    git status --porcelain=v1 | while IFS= read -r status_line; do
        case "$status_line" in
            ' M '*) 
                ((modified++))
                ;;
            'A  '*|'M '*)
                ((staged++))
                ;;
            ' D '*)
                ((deleted++))
                ;;
            '?? '*)
                ((untracked++))
                ;;
            'MM '*)
                ((staged++))
                ((modified++))
                ;;
        esac
    done

    typeset -g STATUS=("$modified" "$staged" "$deleted" "$untracked")
    return 0
}

function get_differences_between_remote_and_local()
{
    local local_branch="$1"
    local remote_branch="$2"

    local differences="$(git rev-list --left-right --count $local_branch...$remote_branch)"
    local commits_ahead=$(echo -n "$differences" | awk '{print $1}')
    local commits_behind=$(echo -n "$differences" | awk '{print $2}')
    local ahead="" behind=""

    (( $commits_ahead > 0 )) \
        && ahead=" ↑$commits_ahead"
    (( $commits_behind > 0 )) \
        && behind=" ↓$commits_behind "

    typeset -g REPLY="$ahead $behind"
    return 0
}

function git_determine_color()
{
    for i in "$@"; do
        if (( $i > 0 )); then
            typeset -g REPLY=$'\e[93m'
            return 0
        fi
    done
    typeset -g REPLY=$'\e[92m'
    return 0
}

main
