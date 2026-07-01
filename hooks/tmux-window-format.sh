#!/usr/bin/env bash
# Shared Oh-my-tmux inner window format (status + current).
# Keeps logic in one place for .tmux.conf.local.

set -euo pipefail

HOOKS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

printf '#I #(%s/tmux-agent-tab-style.sh #{@agent} #{@agent_done_at} #{?@agent_seen,#{@agent_seen},0})#(%s/tmux-window-label.sh #{window_name} 8)#{?@agent, #{@agent},}#{?@agent_done_at, #(%s/tmux-agent-freshness-text.sh #{@agent_done_at}),}#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}' \
  "$HOOKS" "$HOOKS" "$HOOKS"
