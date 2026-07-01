#!/usr/bin/env bash
# Plain done-agent time badge (Oh my tmux bell styles the tab; no inline #[...] here).
# Usage: tmux-agent-freshness.sh <unix_epoch> [seen: ignored]

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
  label=$(( age / 3600 ))
  (( label < 1 )) && label=1
  printf '%dh' "$label"
else
  printf '🗑'
fi
