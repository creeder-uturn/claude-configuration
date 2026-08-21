#!/usr/bin/env bash
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
BEDROCK_MODEL="us.anthropic.claude-sonnet-5"
SUBSCRIPTION_MODEL="claude-sonnet-5"

usage() {
  cat >&2 <<EOF
Usage: claude-mode [bedrock|sub|status]

  bedrock   switch to AWS Bedrock (env.CLAUDE_CODE_USE_BEDROCK=1)
  sub       switch to Claude subscription (env.CLAUDE_CODE_USE_BEDROCK=0)
  status    show current mode
  (no arg)  interactive picker (arrow keys + enter)
EOF
  exit 1
}

current_mode() {
  local use_bedrock
  use_bedrock=$(jq -r '.env.CLAUDE_CODE_USE_BEDROCK // "0"' "$SETTINGS")
  if [ "$use_bedrock" = "1" ]; then echo bedrock; else echo sub; fi
}

set_mode() {
  local mode="$1" use_bedrock model tmp
  if [ "$mode" = bedrock ]; then
    use_bedrock=1
    model="$BEDROCK_MODEL"
  else
    use_bedrock=0
    model="$SUBSCRIPTION_MODEL"
  fi

  tmp=$(mktemp "${SETTINGS}.XXXXXX")
  jq --arg ub "$use_bedrock" --arg model "$model" \
    '.env.CLAUDE_CODE_USE_BEDROCK = $ub | .model = $model' \
    "$SETTINGS" > "$tmp"
  mv "$tmp" "$SETTINGS"

  echo "claude-mode: switched to $mode (model=$model)"
  echo "Start a new Claude Code session for this to take effect."
}

pick_mode() {
  command -v fzf >/dev/null 2>&1 || {
    echo "claude-mode: fzf not found; pass 'bedrock' or 'sub' directly" >&2
    exit 1
  }
  printf 'bedrock\nsub\n' | fzf --header="current: $(current_mode)" \
    --prompt="claude-mode> " --height=~5 --layout=reverse
}

case "${1:-}" in
  bedrock) set_mode bedrock ;;
  sub|subscription) set_mode sub ;;
  status) echo "claude-mode: currently $(current_mode)" ;;
  "")
    chosen=$(pick_mode)
    [ -n "$chosen" ] && set_mode "$chosen"
    ;;
  *) usage ;;
esac
