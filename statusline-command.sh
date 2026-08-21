#!/bin/bash
# Claude Code status line - mirrors bash PS1 from ~/bin/set-prompt.sh

input=$(cat)

# Extract fields from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
is_agent=$(echo "$input" | jq -r '.agent // false')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Colors (matching ~/bin/set-prompt.sh)
RESET=$'\033[0m'
YELLOW=$'\033[00;33m'
CYAN=$'\033[00;36m'
LCYAN=$'\033[01;36m'
LPURPLE=$'\033[01;35m'
WHITE=$'\033[01;37m'
LIGHTGRAY=$'\033[00;37m'
GREEN=$'\033[00;32m'
LRED=$'\033[01;31m'

# Time
time_part="[$(date +"%I:%M:%S %p")]"

# Model
model_part=""
if [ -n "$model" ]; then
    model_part="$model"
fi

# Directory (shorten $HOME to ~)
if [ -n "$cwd" ]; then
    dir_part="${cwd/#$HOME/\~}"
else
    dir_part="$(pwd | sed "s|^$HOME|~|")"
fi

# Git info (run in cwd)
git_part=""
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=""
        if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null; then
            dirty="*"
        fi
        untracked=""
        if [ -n "$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
            untracked="%"
        fi
        git_part="${CYAN} ${LCYAN}${branch}${dirty}${untracked}${RESET}"
    fi
fi

# Context usage + progress bar
ctx_part=""
ctx_bar=""
if [ -n "$used_pct" ]; then
    pct=$(printf '%.0f' "$used_pct")
    ctx_part="${pct}%"

    # Build 10-char progress bar
    filled=$(( pct / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done

    # Color: green < 70%, yellow < 90%, red >= 90%
    if   [ "$pct" -ge 90 ]; then bar_color="$LRED"
    elif [ "$pct" -ge 70 ]; then bar_color="$YELLOW"
    else                          bar_color="$GREEN"
    fi
    ctx_bar="${bar_color}${bar}${RESET}"
fi

# Cost (e.g. "$0.042")
cost_part=""
if [ -n "$total_cost" ] && [ "$total_cost" != "0" ]; then
    cost_part="$(printf '$%.4f' "$total_cost")"
fi

# Assemble: Time | Model | Directory | bar ctx% | tokens | cost
printf "${LIGHTGRAY}%s${RESET}" "${time_part}"
[ -n "$model_part" ]  && printf " ${LIGHTGRAY}|${RESET} ${LPURPLE}%s${RESET}" "${model_part}"
[ "$is_agent" = "true" ] && printf " %s[agent]%s" "${LRED}" "${RESET}"
printf " ${LIGHTGRAY}|${RESET} ${YELLOW}%s${RESET}" "${dir_part}"
[ -n "$git_part" ]    && printf " ${LIGHTGRAY}|${RESET} %s" "${git_part}"
[ -n "$ctx_part" ]    && printf " ${LIGHTGRAY}|${RESET} ${ctx_bar} ${WHITE}%s${RESET}" "${ctx_part}"
[ -n "$cost_part" ]   && printf " ${LIGHTGRAY}|${RESET} ${GREEN}%s${RESET}" "${cost_part}"
printf "\n"
