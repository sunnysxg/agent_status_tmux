#!/usr/bin/env bash
# Install tmux-agent-status hooks and print merge instructions.
# Usage: ./install.sh [hooks_dir]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${1:-${HOME}/.claude/hooks}"
CURSOR_HOOKS_DIR="${HOME}/.cursor/hooks"

mkdir -p "$HOOKS_DIR" "$CURSOR_HOOKS_DIR"

for script in tmux-agent-status.sh tmux-agent-freshness.sh tmux-agent-mark-seen.sh tmux-agent-demo.sh; do
  ln -sfn "${REPO_DIR}/hooks/${script}" "${HOOKS_DIR}/${script}"
  chmod +x "${REPO_DIR}/hooks/${script}"
done

ln -sfn "${HOOKS_DIR}/tmux-agent-status.sh" "${CURSOR_HOOKS_DIR}/tmux-agent-status.sh"

echo "Installed hooks → ${HOOKS_DIR}"
echo "Cursor entry  → ${CURSOR_HOOKS_DIR}/tmux-agent-status.sh"
echo
echo "Next steps:"
echo "  1. Merge config/tmux.snippet into ~/.tmux.conf (@HOOKS_DIR@ → ${HOOKS_DIR})"
echo "  2. Merge config/cursor-hooks.json into ~/.cursor/hooks.json"
echo "  3. Merge config/claude-hooks.json hooks into ~/.claude/settings.json"
echo "  4. tmux source-file ~/.tmux.conf"
echo
echo "Generated snippet:"
sed "s|@HOOKS_DIR@|${HOOKS_DIR}|g" "${REPO_DIR}/config/tmux.snippet"
