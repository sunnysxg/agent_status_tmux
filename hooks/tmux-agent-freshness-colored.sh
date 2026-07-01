#!/usr/bin/env bash
# Colored done-agent badge for DIY tmux.snippet (no Powerline arrows).
# Usage: tmux-agent-freshness-colored.sh <unix_epoch> [seen: 0|1]

set -euo pipefail

done_at="${1:-}"
seen="${2:-0}"
[[ -z "$done_at" || ! "$done_at" =~ ^[0-9]+$ ]] && exit 0
[[ ! "$seen" =~ ^[01]$ ]] && seen=0

now=$(date +%s)
age=$((now - done_at))
(( age < 0 )) && age=0

if (( age < 1800 )); then
  label=$(( age / 60 ))
  (( label < 1 )) && label=1
  text="${label}m"
  if (( seen == 0 )); then
    printf '#[bg=colour82,fg=colour232,bold]%s#[default]' "$text"
  else
    printf '#[fg=colour82]%s#[default]' "$text"
  fi
elif (( age < 7200 )); then
  label=$(( age / 60 ))
  text="${label}m"
  if (( seen == 0 )); then
    printf '#[bg=colour248,fg=colour232,bold]%s#[default]' "$text"
  else
    printf '#[fg=colour226]%s#[default]' "$text"
  fi
elif (( age < 28800 )); then
  label=$(( age / 3600 ))
  (( label < 1 )) && label=1
  text="${label}h"
  if (( seen == 0 )); then
    printf '#[bg=colour250,fg=colour232,bold]%s#[default]' "$text"
  else
    printf '#[fg=colour243]%s#[default]' "$text"
  fi
else
  if (( seen == 0 )); then
    printf '#[bg=colour203,fg=colour232,bold]🗑#[default]'
  else
    printf '#[fg=colour203]🗑#[default]'
  fi
fi
