#!/usr/bin/env bash
# Mark agent result as seen when user focuses a pane in that window.
# Usage: tmux-agent-mark-seen.sh <pane_id>   (from pane-focus-in hook)

set -euo pipefail

pane_id="${1:-}"
[[ -z "$pane_id" ]] && exit 0

done_at=$(tmux display-message -p -t "$pane_id" '#{@agent_done_at}' 2>/dev/null || true)
[[ -z "$done_at" ]] && exit 0

tmux set-window-option -t "$pane_id" "@agent_seen" "1" 2>/dev/null || true
