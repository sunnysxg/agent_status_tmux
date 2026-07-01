# Changelog

## Unreleased — feature/tmux-beautify-integration

Oh my tmux! 集成 + bell 完成提醒。

- Oh my tmux Powerline 箭头 tab
- `tmux-agent-ring-bell.sh`：done 时置 `window_bell_flag`
- 修复 Cursor hook 下 ring-bell 路径（`readlink -f` + cursor hooks symlink）
- 关 `monitor-activity` / activity 下划线
- `config/oh-my-tmux.local.snippet` + `docs/AGENT-GUIDE.md`
- 保留彩色 freshness badge；全名 `#W`（不截断）

## v1.0.0 — 2026-07-01

第一个可用版本（`master`）。

- Claude Code + Cursor Agent 共享 hook 脚本
- DIY tmux status line：⚡、时间 badge、未看/已看、>8h 🗑
- `pane-focus-in` 自动标记已看
- demo 脚本
