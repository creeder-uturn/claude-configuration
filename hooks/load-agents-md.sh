#!/bin/bash
# SessionStart hook: injects AGENTS.md / AGENTS.local.md from the launch
# directory into context, alongside the natively-loaded CLAUDE.md/CLAUDE.local.md.
# Missing or empty files are silently skipped.

context=$(
  for f in AGENTS.md AGENTS.local.md; do
    if [ -s "$f" ]; then
      case "$f" in
        AGENTS.md) desc="general agent instructions, team-shared, checked into version control" ;;
        AGENTS.local.md) desc="general agent instructions, personal/machine-specific, not checked into version control" ;;
      esac
      printf 'Contents of %s/%s (%s):\n\n%s\n\n' "$(pwd)" "$f" "$desc" "$(cat "$f")"
    fi
  done
)

if [ -n "$context" ]; then
  jq -Rs '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:.}}' <<< "$context"
fi
exit 0
