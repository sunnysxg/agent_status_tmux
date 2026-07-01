#!/usr/bin/env bash
# Plain freshness suffix (no colors); pairs with tmux-agent-tab-style.sh.
# Usage: tmux-agent-freshness-text.sh <unix_epoch>

set -euo pipefail

done_at="${1:-}"
[[ -z "$done_at" || ! "$done_at" =~ ^[0-9]+$ ]] && exit 0

now=$(date +%s)
age=$((now - done_at))
(( age < 0 )) && age=0

if (( age < 1800 )); then
  label=$(( age / 60 ))
  (( label < 1 )) && label=1
  printf '%dm' "$label"
elif (( age < 7200 )); then
  printf '%dm' "$((age / 60))"
elif (( age < 28800 )); then
  printf '%dh' "$((age / 3600))"
else
  printf '🗑'
fi
