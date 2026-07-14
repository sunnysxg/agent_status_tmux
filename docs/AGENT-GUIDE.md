# Agent 上手指南 — tmux agent status

面向将来接手的 agent / 人类。描述**当前在用**的完整方案（hooks + Oh my tmux!）。

实现仓库：`HzyProjects/tmux-agent-status`（`git@github.com:sunnysxg/agent_status_tmux.git`）。  
本机 permanent 总览另见 `~/.claude/docs/tmux-multi-agent-status.md`（须与本文一致）。

---

## 架构一览

```
Claude Code / Cursor Agent
    │  Claude: PreToolUse→⚡  Notification→⏸  Stop→✅
    │  Cursor hooks: beforeSubmitPrompt/preToolUse→⚡  stop→✅
    ▼
~/.claude/hooks/tmux-agent-status.sh   （只写 emoji；Cursor symlink 到此）
    │  写 @agent / @agent_done_at / @agent_seen
    │  ✅ 时 → tmux-agent-ring-bell.sh
    ▼
~/.tmux.conf.local（Oh my tmux）
    │  window tab 显示 ⚡/⏸/时间 badge + bell
    │  status-right #(…/cursor-wait/idle-scan.sh)  ← Cursor 确认框补 ⏸（可删）
    ▼
tmux status line

切进窗口 → pane-focus-in → tmux-agent-mark-seen.sh → seen=1
```

| 组件 | 路径 |
|------|------|
| 脚本仓库 | `HzyProjects/tmux-agent-status/` |
| 共享脚本 symlink | `~/.claude/hooks/` |
| Cursor hooks + wait 模块 | `~/.cursor/hooks.json`、`~/.cursor/hooks/`（含 `cursor-wait/`） |
| Claude hooks | `~/.claude/settings.json` |
| Oh my tmux | `~/.local/share/tmux/oh-my-tmux/` ← `~/.tmux.conf` |
| 自定义 | `~/.tmux.conf.local` |

---

## 版本与配置

- **`master` / tag `v1.1.0`** — Oh my tmux + bell + 纯文字 badge
- **Unreleased（2026-07-13）** — `hooks/cursor-wait/`：仅两种 Cursor CLI 确认框 → ⏸
- DIY：`config/tmux.snippet` + `tmux-agent-freshness-colored.sh`

---

## Window 变量

| 变量 | 谁写 | 含义 |
|------|------|------|
| `@agent` | status.sh / idle-scan | ⚡ 运行 / ⏸ 等待 |
| `@agent_done_at` | status.sh（✅） | 完成 unix 时间 |
| `@agent_seen` | status / mark-seen | 未看 0 / 已看 1 |
| `@cursor_wait_hash` / `_hash_at` / `_bell_at` | idle-scan 专用 | 底部稳定性与响铃冷却；可随模块删掉 |

---

## Cursor wait（`hooks/cursor-wait/`）

**独立模块，不进 Claude hooks，也不改 Cursor hooks 主路径。**

| 条件（须同时满足） | 动作 |
|--------------------|------|
| `@agent` 为 ⚡ | 只扫工作中窗口 |
| 底部约 16 行内容哈希 **不变 ≥4s** | 屏幕已停住 |
| 出现 `Approve mode switch (y)` 或 `Yes, build locally (b)` | 固定选项行 |

→ 标 ⏸；响铃有约 120s 冷却。

**不要做的事（已踩坑）：** 不要用「hook 静默超时」当等待；不要扫太深 scrollback；不要在 hooks 里塞 from-hook 判态——会导致 ⚡⇄⏸ 狂切和 bell 轰炸。

**退役：** 从 `tmux_conf_theme_status_right` 去掉 idle-scan 的 `#()`；可删 `~/.cursor/hooks/cursor-wait` symlink。hooks.json 保持简单 ⚡/✅ 即可。

本机：`status-interval 5`（配合 ≥4s 稳定判定）。

---

## 显示规则（当前）

| 状态 | tab | 时间 badge |
|------|-----|------------|
| ⚡ / ⏸ | 普通 tab + emoji | 无 |
| done 未看（不在该 tab） | bell 黄闪 + `!` | 年龄字色（见下） |
| done 未看（正在该 tab） | 无 bell | 年龄字色 |
| done 已看 | 普通 | 年龄字色 |

新鲜度分档（`tmux-agent-freshness.sh`，**仅字色**、无底色，避免断 Powerline）：  
`<30m` 亮绿粗 · `30m–2h` 灰橙 · `2–8h` 玫瑰灰 · `>8h` 中灰 🗑（方案 1b）。

---

## 重要踩坑

1. **Cursor cwd 是 `~/.cursor/`**，hooks 用 `./hooks/...`；子脚本用 `readlink -f` 找目录。`install.sh` 链 status / ring-bell / freshness / mark-seen，以及 `cursor-wait/`。
2. mark-seen 读 **window** 选项：`tmux display-message -p -t "$pane" '#{@agent_done_at}'`
3. bell：`printf '\a' > pane_tty`，不要 `send-keys $'\a'`
4. 选中 window 会清 bell；当前 tab 跑完看不到 bell，靠时间文字
5. 已关 `monitor-activity`（agent 刷 log 会全下划线）
6. tab 中间不要 `#[...]` 上色（会拆 Powerline 箭头）
7. **必须在 tmux pane 里启动** agent，否则无 `$TMUX_PANE`

---

## 从零恢复

```bash
cd /cpfs01/nfshome/xgsun/HzyProjects/tmux-agent-status   # 或 clone 后路径
./install.sh
# 合并 config/oh-my-tmux.local.snippet → ~/.tmux.conf.local
#   - status-interval 5
#   - status_right 前加 #( $HOME/.cursor/hooks/cursor-wait/idle-scan.sh )
# 合并 config/claude-hooks.json / config/cursor-hooks.json
tmux source-file ~/.tmux.conf
```

---

## 快捷键

| 键 | 作用 |
|----|------|
| `Ctrl+b w` | 窗口列表 |
| `Ctrl+b Ctrl+h/l` | 上/下一个窗口 |
| `Ctrl+b Tab` | 上一活跃窗口 |
| `Ctrl+b r` | 重载配置 |

---

## 脚本索引

| 脚本 | 用途 | 在用 |
|------|------|------|
| `tmux-agent-status.sh` | 只写 emoji | ✅ |
| `cursor-wait/idle-scan.sh` | Cursor 确认框 → ⏸ | ✅（status #()） |
| `cursor-wait/markers.sh` | 选项白名单 | ✅ |
| `tmux-agent-freshness.sh` | 纯文字时间 | ✅ Oh my tmux |
| `tmux-agent-freshness-colored.sh` | 彩色时间 | DIY |
| `tmux-agent-mark-seen.sh` | 切进标已看 | ✅ |
| `tmux-agent-ring-bell.sh` | ✅ / 等待响铃 | ✅ |
| `tmux-agent-demo.sh` | 演示 | 按需 |
