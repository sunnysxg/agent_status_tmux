#!/usr/bin/env bash
# Inner tab color prefix from agent state (Oh my tmux arrow wrapper stays theme default).
# Usage: tmux-agent-tab-style.sh <agent> <done_at> <seen>

set -euo pipefail

agent="${1:-}"
done_at="${2:-}"
seen="${3:-0}"

if [[ -n "$agent" ]]; then
  case "$agent" in
    ⚡) printf '#[fg=colour226,bold]' ;;
    ⏸) printf '#[fg=colour214,bold]' ;;
  esac
  exit 0
fi

[[ -z "$done_at" || ! "$done_at" =~ ^[0-9]+$ || "$seen" == "1" ]] && exit 0

now=$(date +%s)
age=$((now - done_at))
(( age < 0 )) && age=0

if (( age < 1800 )); then
  printf '#[fg=colour232,bg=colour82,bold]'
elif (( age < 7200 )); then
  printf '#[fg=colour232,bg=colour248,bold]'
elif (( age < 28800 )); then
  printf '#[fg=colour232,bg=colour250,bold]'
else
  printf '#[fg=colour232,bg=colour203,bold]'
fi
