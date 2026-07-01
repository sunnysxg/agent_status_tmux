# tmux-agent-status

在 tmux 窗口列表里显示 Claude Code / Cursor Agent 的运行状态：运行中 `⚡`、等待授权 `⏸`、跑完后用时间 badge 代替 `✅`，并区分未看 / 已看。

## 机制

```
Agent hook → tmux-agent-status.sh → tmux window 变量 (@agent / @agent_done_at / @agent_seen)
                                              ↓
                              ~/.tmux.conf status line 渲染 badge
切进窗口   → pane-focus-in → tmux-agent-mark-seen.sh → @agent_seen=1
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
./install.sh          # 默认链接到 ~/.claude/hooks
./install.sh ~/my/hooks # 自定义目录
```

把 `install.sh` 输出的 tmux snippet 合并进 `~/.tmux.conf`，再合并 Cursor / Claude 的 hooks 配置。  
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
