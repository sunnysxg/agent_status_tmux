#!/usr/bin/env bash
# Set tmux window agent status for the pane running Claude/Cursor agent.
# Usage: tmux-agent-status.sh <emoji>
# Requires: tmux, TMUX_PANE in environment (inherited from hook subprocess).

set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

emoji="${1:-}"
if [[ -z "$emoji" ]]; then
  echo "usage: tmux-agent-status.sh <emoji>" >&2
  exit 0
fi

if [[ -n "${TMUX_PANE:-}" ]]; then
  case "$emoji" in
    ✅)
      tmux set-window-option -t "$TMUX_PANE" -u "@agent" 2>/dev/null || true
      tmux set-window-option -t "$TMUX_PANE" "@agent_done_at" "$(date +%s)" 2>/dev/null || true
      tmux set-window-option -t "$TMUX_PANE" "@agent_seen" "0" 2>/dev/null || true
      "$HOOKS_DIR/tmux-agent-ring-bell.sh" "$TMUX_PANE"
      ;;
    ⚡|⏸)
      tmux set-window-option -t "$TMUX_PANE" "@agent" "$emoji" 2>/dev/null || true
      tmux set-window-option -t "$TMUX_PANE" -u "@agent_done_at" 2>/dev/null || true
      tmux set-window-option -t "$TMUX_PANE" -u "@agent_seen" 2>/dev/null || true
      ;;
    *)
      tmux set-window-option -t "$TMUX_PANE" "@agent" "$emoji" 2>/dev/null || true
      ;;
  esac
fi

# Cursor hooks send JSON on stdin; consume so pipe doesn't block.
if [[ ! -t 0 ]]; then
  cat >/dev/null
fi

exit 0
