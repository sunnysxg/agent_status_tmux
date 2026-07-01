#!/usr/bin/env bash
# Ring tmux visual bell on a pane's window (sets window_bell_flag until visited).
# Usage: tmux-agent-ring-bell.sh [pane_id]

set -euo pipefail

pane_id="${1:-${TMUX_PANE:-}}"
[[ -z "$pane_id" ]] && exit 0

tty=$(tmux display -p -t "$pane_id" '#{pane_tty}' 2>/dev/null || true)
[[ -z "$tty" || ! -e "$tty" ]] && exit 0

printf '\a' >"$tty" 2>/dev/null || true
