#!/usr/bin/env bash
# Create demo windows showing all agent freshness / seen styles.
# Usage: tmux-agent-demo.sh [session_name]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRESHNESS="${SCRIPT_DIR}/tmux-agent-freshness.sh"

session="${1:-$(tmux display-message -p '#S' 2>/dev/null || echo '')}"
if [[ -z "$session" ]]; then
  echo "Not in tmux and no session given." >&2
  exit 1
fi

now=$(date +%s)

# name|agent|age_secs|seen|description
declare -a demos=(
  "demo-new|done|$((5 * 60))|0|unseen fresh → green bg + 5m"
  "demo-new45|done|$((45 * 60))|0|unseen warm → gray bg + 45m"
  "demo-seen12|done|$((12 * 60))|1|seen fresh → green 12m"
  "demo-seen45|done|$((45 * 60))|1|seen warm → yellow 45m"
  "demo-4h|done|$((4 * 3600))|1|seen old → dim 4h"
  "demo-del|done|$((10 * 3600))|0|unseen stale → red 🗑 bg"
  "demo-work|⚡|| |working → ⚡"
)

set_demo_window() {
  local name="$1" agent="$2" age_secs="$3" seen="$4"

  if tmux list-windows -t "${session}:" -F '#{window_name}' | grep -qx "$name"; then
    local win_target="${session}:=${name}"
  else
    tmux new-window -t "${session}:" -n "$name" -d "sleep infinity"
    local win_target="${session}:=${name}"
  fi

  if [[ "$agent" == "done" ]]; then
    tmux set-window-option -t "$win_target" -u "@agent" 2>/dev/null || true
    tmux set-window-option -t "$win_target" "@agent_done_at" "$((now - age_secs))"
    tmux set-window-option -t "$win_target" "@agent_seen" "$seen"
  else
    tmux set-window-option -t "$win_target" "@agent" "$agent"
    tmux set-window-option -t "$win_target" -u "@agent_done_at" 2>/dev/null || true
    tmux set-window-option -t "$win_target" -u "@agent_seen" 2>/dev/null || true
  fi
}

for entry in "${demos[@]}"; do
  IFS='|' read -r name agent age_secs seen _desc <<<"$entry"
  set_demo_window "$name" "$agent" "$age_secs" "$seen"
done

echo "Demo windows in session '$session':"
for entry in "${demos[@]}"; do
  IFS='|' read -r name agent age_secs seen desc <<<"$entry"
  if [[ "$agent" == "done" ]]; then
    ts=$((now - age_secs))
    badge=$("$FRESHNESS" "$ts" "$seen")
    printf '  %s  %s  (%s)\n' "$name" "$badge" "$desc"
  else
    printf '  %s  %s  (%s)\n' "$name" "$agent" "$desc"
  fi
done
