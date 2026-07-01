# tmux-agent-status

在 tmux 窗口列表里显示 **Claude Code** 和 **Cursor Agent** 的运行状态。

**仓库：** `git@github.com:sunnysxg/agent_status_tmux.git`

## 分支

| 分支 | 说明 |
|------|------|
| **`feature/tmux-beautify-integration`** | **当前样式**：Oh my tmux! Powerline 箭头 + bell 完成提醒 + 彩色 badge |
| `master`（tag `v1.0.0`） | 基础版：DIY 绿底 status line，无 Oh my tmux |

**接手必读：** [docs/AGENT-GUIDE.md](docs/AGENT-GUIDE.md)

## 支持的 Agent

| Agent | Hook 配置 | 事件 |
|-------|-----------|------|
| Claude Code | `~/.claude/settings.json` | ⚡ `PreToolUse` · ✅ `Stop` · ⏸ `Notification` |
| Cursor Agent | `~/.cursor/hooks.json` | ⚡ `beforeSubmitPrompt`/`preToolUse` · ✅ `stop` |

共享脚本在 `~/.claude/hooks/`；Cursor 通过 `~/.cursor/hooks/` symlink 调用。

## 当前样式要点

- **Oh my tmux!** 箭头 window tab（`config/oh-my-tmux.local.snippet`）
- agent **跑完** → bell（后台 tab 黄闪 + `!`）+ 彩色时间 badge
- **切进窗口** → 标已看，bell 清除
- `monitor-activity off`（避免 agent 输出导致全 tab 下划线）

## 安装（当前分支）

```bash
git checkout feature/tmux-beautify-integration
./install.sh
```

然后：

1. 安装 [Oh my tmux!](https://github.com/gpakosz/.tmux) → `~/.local/share/tmux/oh-my-tmux/`，`~/.tmux.conf` 链过去
2. 合并 `config/oh-my-tmux.local.snippet` → `~/.tmux.conf.local`（`@HOOKS_DIR@` → `~/.claude/hooks`）
3. 合并 `config/cursor-hooks.json` / `config/claude-hooks.json`
4. `tmux source-file ~/.tmux.conf`

`master` 仅用 `config/tmux.snippet`（无 Oh my tmux）。

## 脚本

| 脚本 | 作用 |
|------|------|
| `tmux-agent-status.sh` | hook 入口 |
| `tmux-agent-freshness.sh` | 彩色时间 / 🗑 |
| `tmux-agent-ring-bell.sh` | done 触发 bell |
| `tmux-agent-mark-seen.sh` | 切进标已看 |
| `tmux-agent-demo.sh` | 演示窗口 |

## 快捷键

- `Ctrl+b w` — 窗口列表（窗口多时用）
- `Ctrl+b Ctrl+h/l` — 上/下一个窗口
- `Ctrl+b Tab` — 上一个活跃窗口
