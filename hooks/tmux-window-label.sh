#!/usr/bin/env bash
# Short display label for tmux window name (unicode-safe truncate).
# Usage: tmux-window-label.sh <name> [max_chars=8]

set -euo pipefail

name="${1:-}"
max_chars="${2:-8}"
[[ -z "$name" ]] && exit 0

python3 - "$name" "$max_chars" <<'PY'
import sys
name, max_chars = sys.argv[1], int(sys.argv[2])
print(name if len(name) <= max_chars else name[:max_chars])
PY
