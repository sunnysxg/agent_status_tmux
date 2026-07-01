# Agent 上手指南 — tmux agent status

面向将来接手的 agent / 人类。描述**当前在用**的完整方案（hooks + Oh my tmux!）。

---

## 架构一览

```
Claude Code / Cursor Agent
    │  stop → ✅ / preToolUse → ⚡
    ▼
~/.claude/hooks/tmux-agent-status.sh  （Cursor 从 ~/.cursor/hooks/ 链过来）
    │  写 @agent / @agent_done_at / @agent_seen
    │  done 时 → tmux-agent-ring-bell.sh
    ▼
~/.tmux.conf.local  （Oh my tmux 主题 + window format）
    │  Powerline 箭头 tab + 彩色时间 badge
    ▼
tmux status line
    │
切进窗口 → pane-focus-in → tmux-agent-mark-seen.sh → seen=1
```

**两套 hook 配置、一套脚本：**

| 组件 | 路径 |
|------|------|
| 脚本仓库 | `HzyProjects/tmux-agent-status/` |
| 脚本 symlink | `~/.claude/hooks/` |
| Cursor 入口 | `~/.cursor/hooks.json` + `~/.cursor/hooks/*.sh` |
| Claude 入口 | `~/.claude/settings.json` → hooks |
| Oh my tmux 本体 | `~/.local/share/tmux/oh-my-tmux/` |
| 主配置 | `~/.tmux.conf` → oh-my-tmux |
| 自定义 | `~/.tmux.conf.local` |

---

## 当前分支

- **`feature/tmux-beautify-integration`** — Oh my tmux + bell + 彩色 badge（当前样式）
- **`master` / tag `v1.0.0`** — 仅 DIY 绿底 status line，无 Oh my tmux

---

## Window 变量

| 变量 | 设置时机 | 含义 |
|------|----------|------|
| `@agent` | ⚡ / ⏸ | 运行中 / 等待 |
| `@agent_done_at` | stop(✅) | 完成 unix 时间 |
| `@agent_seen` | stop→0；切进 pane→1 | 未看 / 已看 |
| `window_bell_flag` | ring-bell | 完成提醒（tmux 内置） |

---

## 显示规则（当前）

| 状态 | tab 外观 | 时间 badge |
|------|----------|------------|
| ⚡ 运行中 | 普通 tab + `⚡` | 无 |
| done 未看（**不在该 tab**） | **bell 黄闪** + `!` + 箭头 bell 色 | 绿/灰/红底数字 |
| done 未看（**正在该 tab**） | 无 bell（选中即清） | 同上 |
| done 已看 | 普通 tab | 绿/黄/灰字数字 |
| >8h | | 红 `🗑` |

新鲜度阈值：30min / 2h / 8h（见 `tmux-agent-freshness.sh`）。

---

## 重要踩坑（必读）

### 1. Cursor 与 Claude 路径不同

- Claude：`~/.claude/hooks/tmux-agent-status.sh`（绝对路径）
- Cursor：`~/.cursor/hooks.json`，cwd 为 `~/.cursor/`

**子脚本必须用 `readlink -f "${BASH_SOURCE[0]}"` 找 HOOKS_DIR**，不能 `dirname $0` 拼相对路径。  
曾因此 **ring-bell 在 Cursor 下静默失败**（`~/.cursor/hooks/` 里缺 symlink）。

`install.sh` 会给 Cursor 链：`status` / `ring-bell` / `freshness` / `mark-seen`。

### 2. mark-seen 读 window 选项

❌ `tmux show-options -p @agent_done_at`（pane 选项，读不到）  
✅ `tmux display-message -p -t "$pane" '#{@agent_done_at}'`

### 3. bell 触发方式

❌ `tmux send-keys $'\a'`（送给应用，不置 bell flag）  
✅ `printf '\a' > "$(tmux display -p -t pane '#{pane_tty}')"`

### 4. bell 与「正在看的窗口」

tmux 规则：**选中 window 会清 bell**。agent 在当前 tab 跑完时看不到 bell，靠彩色 badge；**后台 tab 跑完**才有 bell。

### 5. activity 下划线

Oh my tmux 默认 `monitor-activity on` + activity 下划线。agent 窗口几乎永远有输出 → 全下划线。  
已关：`monitor-activity off` + `activity_attr=none`。

### 6. Oh my tmux 箭头 vs agent 配色

- **箭头颜色**由 tmux 五态控制：current / last / bell / activity / normal
- **不能**按 `@agent` 给每个 window 单独设箭头色（除非 fork `_apply_theme`）
- **bell 态**会连箭头一起变色 → 当前用 bell 强调「done 未看」
- tab **中间内容**可用 `#(/hooks/...)` 脚本上色

### 7. 必须在 tmux pane 里跑 agent

hook 子进程需继承 `$TMUX_PANE`，否则脚本 no-op。

---

## 从零恢复（当前样式）

```bash
# 1. hooks
cd ~/HzyProjects/tmux-agent-status
git checkout feature/tmux-beautify-integration
./install.sh

# 2. Oh my tmux（若未装）
git clone --single-branch https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
ln -sf ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.tmux.conf
cp ~/.local/share/tmux/oh-my-tmux/.tmux.conf.local ~/.tmux.conf.local

# 3. 合并 config/oh-my-tmux.local.snippet → ~/.tmux.conf.local
#    @HOOKS_DIR@ → ~/.claude/hooks，#!important 段取消注释

# 4. 合并 Claude / Cursor hooks（config/*.json）

# 5. 重载
tmux source-file ~/.tmux.conf
```

---

## 常用快捷键

| 键 | 作用 |
|----|------|
| `Ctrl+b w` | 全部窗口列表 |
| `Ctrl+b Ctrl+h/l` | 上/下一个窗口 |
| `Ctrl+b Tab` | 回到上一个活跃窗口 |
| `Ctrl+b r` | 重载 tmux 配置 |

---

## 脚本索引

| 脚本 | 用途 | 当前在用 |
|------|------|----------|
| `tmux-agent-status.sh` | hook 入口 | ✅ |
| `tmux-agent-freshness.sh` | 彩色时间 badge | ✅ |
| `tmux-agent-mark-seen.sh` | 切进标已看 | ✅ |
| `tmux-agent-ring-bell.sh` | done 响 bell | ✅ |
| `tmux-agent-demo.sh` | 演示窗口 | 按需 |
| `tmux-agent-tab-style.sh` 等 | 早期实验 | 未用 |
