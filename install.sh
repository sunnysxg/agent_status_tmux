#!/usr/bin/env bash
# Install tmux-agent-status (Claude Code + Cursor Agent).
# Usage: ./install.sh [hooks_dir]
#
# Scripts land in one shared hooks_dir (default ~/.claude/hooks).
# Cursor and Claude each have their own hook config file elsewhere;
# this script links scripts + prints what to merge for both.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${1:-${HOME}/.claude/hooks}"
CURSOR_HOOKS_DIR="${HOME}/.cursor/hooks"

mkdir -p "$HOOKS_DIR" "$CURSOR_HOOKS_DIR"

for script in tmux-agent-status.sh tmux-agent-freshness.sh tmux-agent-freshness-text.sh tmux-agent-mark-seen.sh tmux-agent-demo.sh tmux-agent-tab-style.sh tmux-agent-ring-bell.sh tmux-window-label.sh tmux-window-format.sh; do
  ln -sfn "${REPO_DIR}/hooks/${script}" "${HOOKS_DIR}/${script}"
  chmod +x "${REPO_DIR}/hooks/${script}"
done

ln -sfn "${HOOKS_DIR}/tmux-agent-status.sh" "${CURSOR_HOOKS_DIR}/tmux-agent-status.sh"
for script in tmux-agent-ring-bell.sh tmux-agent-freshness.sh tmux-agent-mark-seen.sh; do
  ln -sfn "${HOOKS_DIR}/${script}" "${CURSOR_HOOKS_DIR}/${script}"
done

echo "tmux-agent-status — supports Claude Code + Cursor Agent"
echo
echo "Shared scripts → ${HOOKS_DIR}"
echo "  (tmux freshness / mark-seen also read from here via ~/.tmux.conf)"
echo "Cursor hook entry → ${CURSOR_HOOKS_DIR}/tmux-agent-status.sh"
echo "Claude hook config → merge config/claude-hooks.json into ~/.claude/settings.json"
echo
echo "Manual merge (one-time):"
echo "  1. ~/.tmux.conf        ← config/tmux.snippet"
echo "  2. ~/.cursor/hooks.json ← config/cursor-hooks.json"
echo "  3. ~/.claude/settings.json ← config/claude-hooks.json (hooks section)"
echo "  4. tmux source-file ~/.tmux.conf"
echo
echo "Generated tmux snippet (HOOKS_DIR=${HOOKS_DIR}):"
sed "s|@HOOKS_DIR@|${HOOKS_DIR}|g" "${REPO_DIR}/config/tmux.snippet"
