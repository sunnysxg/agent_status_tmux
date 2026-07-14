# tmux-agent-status

在 tmux 窗口列表里显示 **Claude Code** 和 **Cursor Agent** 的运行状态。

**仓库：** `git@github.com:sunnysxg/agent_status_tmux.git`  
**当前版本：** `v1.1.0` + unreleased `cursor-wait`（2026-07-13；见 CHANGELOG）

**接手必读：** [docs/AGENT-GUIDE.md](docs/AGENT-GUIDE.md)

## 支持的 Agent

| Agent | Hook 配置 | 事件 |
|-------|-----------|------|
| Claude Code | `~/.claude/settings.json` | ⚡ `PreToolUse` · ✅ `Stop` · ⏸ `Notification` |
| Cursor Agent | `~/.cursor/hooks.json` | ⚡/✅ 同前（直接调 `tmux-agent-status.sh`）；另可选 `cursor-wait/idle-scan` 只抓两种确认框 |

**脚本共用**（`~/.claude/hooks/`）；Claude / Cursor 各有一份 hook **注册配置**。  
Cursor 确认框扫描在 `hooks/cursor-wait/`（只装到 `~/.cursor/hooks/`），**不改** hook 主路径。

## 两套 tmux 外观（二选一）

| 配置片段 | 适用 | 特点 |
|----------|------|------|
| `config/oh-my-tmux.local.snippet` | Oh my tmux! | Powerline 箭头 + bell 黄闪 + `!` + 纯文字时间 |
| `config/tmux.snippet` | 纯 DIY | 绿底 status line + 彩色时间 badge（tag `v1.0.0` 风格） |

共用同一套 hooks；**只有 tmux 显示层**选不同片段。

## 安装

```bash
git clone git@github.com:sunnysxg/agent_status_tmux.git tmux-agent-status
cd tmux-agent-status
./install.sh
```

然后（按你用的外观选 **一条** tmux 路径）：

**Oh my tmux（推荐，当前在用）：**

1. 安装 [Oh my tmux!](https://github.com/gpakosz/.tmux) → `~/.local/share/tmux/oh-my-tmux/`，`~/.tmux.conf` 链过去
2. 合并 `config/oh-my-tmux.local.snippet` → `~/.tmux.conf.local`（`@HOOKS_DIR@` → `~/.claude/hooks`，`#!important` 段取消注释）

**DIY：**

1. 合并 `config/tmux.snippet` → `~/.tmux.conf`

**两者都要：**

- 合并 `config/cursor-hooks.json` / `config/claude-hooks.json`
- `tmux source-file ~/.tmux.conf`

## 脚本

| 脚本 | 作用 |
|------|------|
| `tmux-agent-status.sh` | 核心：只写 emoji（Claude / Cursor hooks） |
| `cursor-wait/idle-scan.sh` | Cursor：底部静止 + 固定选项文案 → ⏸ |
| `cursor-wait/markers.sh` | 等待选项白名单 |
| `tmux-agent-freshness.sh` | 年龄字色时间（Oh my tmux，fg-only） |
| `tmux-agent-freshness-colored.sh` | 彩色时间（DIY） |
| `tmux-agent-ring-bell.sh` | done / wait 触发 bell |
| `tmux-agent-mark-seen.sh` | 切进标已看 |
| `tmux-agent-demo.sh` | 演示窗口 |

## 快捷键

- `Ctrl+b w` — 窗口列表
- `Ctrl+b Ctrl+h/l` — 上/下一个窗口
- `Ctrl+b Tab` — 上一个活跃窗口
