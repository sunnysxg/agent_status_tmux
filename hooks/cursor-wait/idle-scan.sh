#!/usr/bin/env bash
# Cursor-wait: ONLY detect the two fixed confirm dialogs, and ONLY after the
# pane bottom has been unchanged for a few seconds. No silence/think heuristics.
#
# Runs from tmux status-interval via #(this-script). Prints nothing.
# Hooks stay on the old simple path (⚡ / ✅ via tmux-agent-status.sh).

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
HOOKS_DIR="$(cd "${MODULE_DIR}/.." && pwd)"
STATUS="${HOOKS_DIR}/tmux-agent-status.sh"
RING="${HOOKS_DIR}/tmux-agent-ring-bell.sh"

# shellcheck source=markers.sh
source "${MODULE_DIR}/markers.sh"

# Pane must be visually idle this long before we trust a marker match.
STABLE_SECS="${CURSOR_WAIT_STABLE_SECS:-4}"
CAPTURE_LINES="${CURSOR_WAIT_CAPTURE_LINES:-16}"
BELL_COOLDOWN_SECS="${CURSOR_WAIT_BELL_COOLDOWN_SECS:-120}"

LOCK_DIR="${TMPDIR:-/tmp}/tmux-agent-cursor-wait-scan.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

command -v tmux >/dev/null 2>&1 || exit 0

pane_bottom() {
  tmux capture-pane -p -t "$1" -S "-${CAPTURE_LINES}" 2>/dev/null || true
}

content_hash() {
  # Portable-ish: md5sum on Linux
  printf '%s' "$1" | md5sum 2>/dev/null | awk '{print $1}'
}

has_wait_marker() {
  local text="$1"
  local m
  for m in "${CURSOR_WAIT_MARKERS[@]}"; do
    [[ -z "$m" ]] && continue
    if [[ "$text" == *"$m"* ]]; then
      return 0
    fi
  done
  return 1
}

maybe_ring() {
  local pane_id="$1"
  local now_ts="$2"
  local last_bell
  last_bell=$(tmux display-message -p -t "$pane_id" '#{@cursor_wait_bell_at}' 2>/dev/null || true)
  if [[ -n "$last_bell" && "$last_bell" =~ ^[0-9]+$ ]]; then
    if (( now_ts - last_bell < BELL_COOLDOWN_SECS )); then
      return 0
    fi
  fi
  "$RING" "$pane_id" </dev/null || true
  tmux set-window-option -t "$pane_id" "@cursor_wait_bell_at" "$now_ts" 2>/dev/null || true
}

now=$(date +%s)

while IFS=$'\t' read -r _win_id pane_id agent; do
  [[ "$agent" == "⚡" ]] || continue
  [[ -n "$pane_id" ]] || continue

  text=$(pane_bottom "$pane_id")
  [[ -z "$text" ]] && continue

  hash=$(content_hash "$text")
  [[ -z "$hash" ]] && continue

  prev_hash=$(tmux display-message -p -t "$pane_id" '#{@cursor_wait_hash}' 2>/dev/null || true)
  prev_at=$(tmux display-message -p -t "$pane_id" '#{@cursor_wait_hash_at}' 2>/dev/null || true)

  if [[ "$hash" != "$prev_hash" ]]; then
    # Screen still changing (agent streaming / tools) — reset stability clock.
    tmux set-window-option -t "$pane_id" "@cursor_wait_hash" "$hash" 2>/dev/null || true
    tmux set-window-option -t "$pane_id" "@cursor_wait_hash_at" "$now" 2>/dev/null || true
    continue
  fi

  if [[ -z "$prev_at" || ! "$prev_at" =~ ^[0-9]+$ ]]; then
    tmux set-window-option -t "$pane_id" "@cursor_wait_hash_at" "$now" 2>/dev/null || true
    continue
  fi

  stable=$((now - prev_at))
  if (( stable < STABLE_SECS )); then
    continue
  fi

  # Bottom unchanged for STABLE_SECS and shows a known wait option line.
  if has_wait_marker "$text"; then
    TMUX_PANE="$pane_id" "$STATUS" '⏸' </dev/null || true
    maybe_ring "$pane_id" "$now"
  fi
done < <(tmux list-windows -a -F $'#{window_id}\t#{pane_id}\t#{@agent}' 2>/dev/null || true)

exit 0
