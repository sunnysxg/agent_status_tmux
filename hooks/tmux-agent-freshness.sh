#!/usr/bin/env bash
# Done-agent time badge for Oh my tmux: fg-only age colors (no bg / no #[default]).
# Unseen whole-tab highlight stays with window-status-bell.
# Scheme 1b — green fresh + muted warm fade:
#   <30m  colour82 bold · 30m–2h colour180 · 2–8h colour138 · >8h colour244
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
  printf '#[fg=colour82,bold]%dm#[none]' "$label"
elif (( age < 7200 )); then
  # colour180 ≈ #d7af87 — dusty peach, greyer than bright orange 214
  printf '#[fg=colour180]%dm#[none]' "$((age / 60))"
elif (( age < 28800 )); then
  label=$(( age / 3600 ))
  (( label < 1 )) && label=1
  # colour138 ≈ #af8787 — muted rose-grey
  printf '#[fg=colour138]%dh#[none]' "$label"
else
  printf '#[fg=colour244]🗑#[none]'
fi
