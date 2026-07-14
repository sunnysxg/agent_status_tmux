# Changelog

## Unreleased — 2026-07-13

- **Cursor wait（极简）**：`hooks/cursor-wait/` 仅在 pane **底部文案静止 ≥4s** 且命中固定选项行时标 ⏸
  - markers：`Approve mode switch (y)` · `Yes, build locally (b)`
  - Cursor hooks **仍用** 原来的 `tmux-agent-status.sh` ⚡/✅（无 from-hook / 无静默超时）
  - 退役：去掉 status-right 里 idle-scan 的 `#()` 即可

## v1.1.0 — 2026-07-01

Oh my tmux! 集成合并进 `master`；DIY 与 Oh my tmux 配置并存。

- Oh my tmux Powerline 箭头 tab + bell 完成提醒 + `!`
- `tmux-agent-ring-bell.sh`；修复 Cursor hook 路径（`readlink -f`）
- 关 `monitor-activity` / activity 下划线
- Oh my tmux 用纯文字 `tmux-agent-freshness.sh`（避免 Powerline 箭头断裂）
- DIY 保留彩色 `tmux-agent-freshness-colored.sh` + `config/tmux.snippet`
- `config/oh-my-tmux.local.snippet` + `docs/AGENT-GUIDE.md`

## v1.0.0 — 2026-07-01

第一个可用版本。

- Claude Code + Cursor Agent 共享 hook 脚本
- DIY tmux status line：⚡、彩色时间 badge、未看/已看、>8h 🗑
- `pane-focus-in` 自动标记已看
- demo 脚本
