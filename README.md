# tmux-agent-status

在 tmux 窗口列表里显示 **Claude Code** 和 **Cursor Agent** 的运行状态：运行中 `⚡`、等待授权 `⏸`（Claude）、跑完后用时间 badge 代替 `✅`，并区分未看 / 已看。

**当前版本：** [v1.0.0](CHANGELOG.md) — 第一个可用版本

## 支持的 Agent

| Agent | Hook 配置位置 | 触发事件 | 备注 |
|-------|---------------|----------|------|
| **Claude Code** | `~/.claude/settings.json` | `PreToolUse` ⚡ · `Stop` ✅ · `Notification` ⏸ | 完整三态 |
| **Cursor Agent** | `~/.cursor/hooks.json` | `beforeSubmitPrompt` / `preToolUse` ⚡ · `stop` ✅ | 无 ⏸ 等价 hook |

**共享部分：** 四个 shell 脚本 + `~/.tmux.conf` 里的 status line 渲染。  
两套 Agent **各读各自的 hook 配置文件**，但都调用同一套脚本。

## 机制

```
Claude / Cursor hook → tmux-agent-status.sh → tmux window 变量
                                              ↓
                              ~/.tmux.conf status line 渲染 badge
切进窗口 → pane-focus-in → tmux-agent-mark-seen.sh → @agent_seen=1
```

## 文件

| 文件 | 作用 |
|------|------|
| `hooks/tmux-agent-status.sh` | Agent 生命周期写状态 |
| `hooks/tmux-agent-freshness.sh` | 渲染 done badge（时间 / 🗑） |
| `hooks/tmux-agent-mark-seen.sh` | 切进窗口标已看 |
| `hooks/tmux-agent-demo.sh` | 创建演示窗口 |
| `config/tmux.snippet` | tmux 配置片段 |
| `config/cursor-hooks.json` | Cursor user hooks 模板 |
| `config/claude-hooks.json` | Claude Code hooks 模板 |

## 安装

```bash
cd tmux-agent-status
./install.sh              # 脚本默认链到 ~/.claude/hooks
./install.sh ~/my/hooks   # 自定义脚本目录
```

`install.sh` 只做**脚本 symlink**（+ Cursor 入口链）。还需手动合并三处配置：

| 配置 | 模板 |
|------|------|
| tmux status line | `config/tmux.snippet` → `~/.tmux.conf` |
| Cursor hooks | `config/cursor-hooks.json` → `~/.cursor/hooks.json` |
| Claude hooks | `config/claude-hooks.json` → `~/.claude/settings.json` |

默认脚本目录用 `~/.claude/hooks` 只是历史习惯（Claude 侧最早放这里），**不是只支持 Claude**——Cursor 通过 `~/.cursor/hooks/tmux-agent-status.sh` 链到同一脚本。

**必须在 tmux pane 里启动 agent**，hook 子进程才能继承 `$TMUX_PANE`。

## Badge 规则

| 距跑完 | 未看 | 已看 |
|--------|------|------|
| < 30 min | 绿底 `Nm` | 亮绿字 `Nm` |
| 30 min – 2 h | 灰底 `Nm` | 黄字 `Nm` |
| 2 h – 8 h | 浅灰底 `Nh` | 灰字 `Nh` |
| > 8 h | 红底 `🗑` | 红字 `🗑` |

## 演示

```bash
~/.claude/hooks/tmux-agent-demo.sh
```

## tmux 快捷键

- `Ctrl+b l` — 切回上一个选中的窗口
- `Ctrl+b w` — 窗口列表
