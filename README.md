# Claude Pet

> You kick off a long refactor, switch to a browser, and 20 minutes later realize Claude finished ages ago. Or worse — it's been waiting for your approval the whole time.

**Claude Pet is a "quiet" notification plugin for Claude Code.** It stays completely invisible while you work — no tray icon, no always-on desktop widget, no resource usage. The moment Claude finishes a task or needs your input, a small speech-bubble pops up in the corner and fades away on its own.

Not another desktop pet. Just a timely nudge when it matters.

> **[中文说明](#中文说明)**

---

## How is this different from desktop-pet projects?

| | Claude Pet | Desktop pet apps |
|---|---|---|
| Runs | Only on Claude Code events | Continuously |
| UI | Temporary popup, auto-dismiss | Persistent on-screen character |
| Resources | Zero when idle | Always consuming CPU/memory |
| Purpose | Notification | Entertainment |

## What it looks like

- **Task complete** — green bubble + Claude avatar with a random cheerful message
- **Needs attention** — orange bubble + Claude avatar with a random nudge
- Fade-in/fade-out animation, auto-dismiss after 5s, click to close early

## Requirements

- Windows 10 / 11
- PowerShell 5.1+ (ships with Windows)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed

## Install

```powershell
git clone https://github.com/user/claude-pet.git
cd claude-pet
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer will:
1. Generate `notify.ps1` from source (UTF-16 LE for PowerShell 5.1 compatibility)
2. Write hook config into `~/.claude/settings.json` (preserves your existing settings)
3. Show a test popup to confirm it works

> Safe to re-run (idempotent) — it replaces old config automatically.

## Smoke test

After installing, run the test script to verify both notification types:

```powershell
powershell -ExecutionPolicy Bypass -File test.ps1
```

You should see two popups (green + orange) appear one after the other.

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

This will:
1. Remove Claude Pet hooks from `~/.claude/settings.json` (other settings preserved)
2. Delete generated `notify.ps1`
3. Clean up temp files (`claude-pet.lock`, `claude-pet.log`)

## Customization

Edit `src/notify.source.ps1`, then re-run `install.ps1` to apply.

### Messages

Modify the `$stopMessages` and `$notificationMessages` arrays:

```powershell
$stopMessages = @(
    'Your custom completion message~'
    # ...
)
```

### Colors

Change the color values in the `if ($Type -eq "stop")` block:

```powershell
$bubbleBg = "#E8F5E9"       # bubble background
$bubbleBorder = "#66BB6A"   # bubble border
$titleColor = "#2E7D32"     # title text
$petBg = "#C8E6C9"          # avatar background
```

### Display duration

Change the number in `[TimeSpan]::FromSeconds(5)`.

## How it works

1. Claude Code [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) fire on Stop / Notification events
2. The hook runs a PowerShell script that creates a transparent WPF window
3. The window shows a Claude avatar + speech bubble with XAML animations
4. Built-in throttle (10s cooldown) prevents bubble stacking on rapid events
5. Full try/catch error handling — crashes write to `%TEMP%\claude-pet.log` and never break Claude Code

## File structure

```
claude-pet/
├── README.md
├── install.ps1            # one-click installer
├── uninstall.ps1          # one-click uninstaller
├── test.ps1               # smoke test script
├── src/
│   └── notify.source.ps1  # notification source (UTF-8, readable, diffable)
└── assets/
    ├── claude.png         # Claude avatar
    └── claude.ico         # Claude icon
```

---

<a id="中文说明"></a>

# 中文说明

> 你让 Claude Code 跑一个大重构，切去做别的事，半小时后回来发现它其实 3 分钟就停下来等你确认了——

**Claude Pet 是一个"安静的" Claude Code 通知插件。** 平时完全隐形：没有托盘图标，没有常驻桌面小部件，零资源占用。只有当 Claude 完成任务或需要你操作时，屏幕角落才弹出一个小气泡，然后自动消失。

不是又一个桌面宠物，只是在该提醒你的时候提醒你。

### 和桌面宠物项目有什么区别？

| | Claude Pet | 桌面宠物应用 |
|---|---|---|
| 运行方式 | 仅在 Claude Code 事件时触发 | 持续运行 |
| 界面 | 临时弹窗，自动消失 | 屏幕常驻角色 |
| 资源占用 | 空闲时为零 | 持续消耗 CPU/内存 |
| 目的 | 通知提醒 | 娱乐陪伴 |

## 效果

- **任务完成** — 绿色气泡 + Claude 头像，显示随机的可爱完成语
- **需要关注** — 橙色气泡 + Claude 头像，显示随机的求助语
- 淡入/淡出动画，5 秒后自动消失，点击可提前关闭

## 前置要求

- Windows 10 / 11
- PowerShell 5.1+（Windows 自带）
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 已安装

## 安装

```powershell
git clone https://github.com/user/claude-pet.git
cd claude-pet
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装脚本会自动：
1. 从源码生成 `notify.ps1`（UTF-16 LE 编码，兼容 PowerShell 5.1）
2. 将 hooks 配置写入 `~/.claude/settings.json`（保留你已有的设置）
3. 弹出一次测试通知确认安装成功

> 重复运行是安全的（幂等），会自动替换旧配置。

## 冒烟测试

安装后运行测试脚本，验证两种通知都能正常弹出：

```powershell
powershell -ExecutionPolicy Bypass -File test.ps1
```

应该会依次看到两个弹窗（绿色 + 橙色）。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

卸载脚本会：
1. 从 `~/.claude/settings.json` 移除 Claude Pet 的 hooks（保留其他设置）
2. 删除生成的 `notify.ps1`
3. 清理临时文件（`claude-pet.lock`、`claude-pet.log`）

## 自定义

编辑 `src/notify.source.ps1`，然后重新运行 `install.ps1` 即可生效。

### 修改文案

修改 `$stopMessages` 和 `$notificationMessages` 数组：

```powershell
$stopMessages = @(
    '😺 你的自定义完成消息~'
    # ...
)
```

### 修改颜色

修改 `if ($Type -eq "stop")` 代码块中的颜色值：

```powershell
$bubbleBg = "#E8F5E9"       # 气泡背景色
$bubbleBorder = "#66BB6A"   # 气泡边框色
$titleColor = "#2E7D32"     # 标题颜色
$petBg = "#C8E6C9"          # 宠物头像背景色
```

### 修改显示时间

修改 `[TimeSpan]::FromSeconds(5)` 中的数字（单位：秒）。

## 工作原理

1. Claude Code 的 [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) 机制在 Stop / Notification 事件时触发脚本
2. 脚本用 WPF 创建透明无边框窗口
3. 窗口展示 Claude 头像 + 对话气泡，带 XAML 动画
4. 内置节流机制（10 秒冷却），防止快速连续触发时气泡叠加
5. 完整的 try/catch 错误处理——崩溃只写日志到 `%TEMP%\claude-pet.log`，绝不影响 Claude Code

## 文件结构

```
claude-pet/
├── README.md
├── install.ps1            # 一键安装脚本
├── uninstall.ps1          # 一键卸载脚本
├── test.ps1               # 冒烟测试脚本
├── src/
│   └── notify.source.ps1  # 通知脚本源码（UTF-8，可读可 diff）
└── assets/
    ├── claude.png         # Claude 头像
    └── claude.ico         # Claude 图标
```
