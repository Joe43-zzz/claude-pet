# Claude Pet 🐾

Claude Code 桌面宠物通知插件 —— 当 Claude 完成任务或需要你的注意时，屏幕右下角会弹出一个可爱的 Claude 宠物气泡通知。

## 效果

- **任务完成时**：绿色气泡 + Claude 宠物头像，显示随机的可爱完成语
- **需要关注时**：橙色气泡 + Claude 宠物头像，显示随机的求助语
- 气泡带有淡入/淡出动画，5 秒后自动消失，点击可提前关闭

## 前置要求

- Windows 10 / 11
- PowerShell 5.1+（Windows 自带）
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 已安装

## 安装

```powershell
git clone https://github.com/your-username/claude-pet.git
cd claude-pet
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装脚本会自动：
1. 从源码生成运行时脚本 `notify.ps1`（UTF-16 LE 编码，兼容 PowerShell 5.1）
2. 将 hooks 配置写入 `~/.claude/settings.json`（保留你已有的设置）
3. 弹出一次测试通知确认安装成功

> 重复运行安装脚本是安全的（幂等），会自动替换旧配置。

## 卸载

```powershell
cd claude-pet
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

卸载脚本会：
1. 从 `~/.claude/settings.json` 移除 Claude Pet 的 hooks（保留其他设置）
2. 删除生成的 `notify.ps1`

## 自定义

编辑 `src/notify.source.ps1`，然后重新运行 `install.ps1` 即可生效。

### 修改文案

找到 `$stopMessages` 和 `$notificationMessages` 数组，修改或添加你喜欢的消息：

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

1. Claude Code 的 [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) 机制在特定事件（Stop、Notification）触发时执行 PowerShell 脚本
2. 脚本使用 WPF（Windows Presentation Foundation）创建一个透明无边框窗口
3. 窗口包含 Claude 头像 + 对话气泡，带有 XAML 动画效果
4. 5 秒后自动淡出关闭

## 文件结构

```
claude-pet/
├── README.md              # 本文档
├── install.ps1            # 一键安装脚本
├── uninstall.ps1          # 一键卸载脚本
├── .gitignore             # 忽略生成文件
├── src/
│   └── notify.source.ps1  # 通知脚本源码（UTF-8，可读可 diff）
└── assets/
    ├── claude.png         # Claude 头像
    └── claude.ico         # Claude 图标
```
