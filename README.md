# 三国推演志

[下载 Windows 版](https://github.com/minkaiwang/sanguo-sandtable/releases/download/v0.1.0/sanguo-sandbox-v0.1.0-reviewed-windows-x64.zip) · [v0.1.0 发布说明与源码下载](https://github.com/minkaiwang/sanguo-sandtable/releases/tag/v0.1.0)

把人物卡摆到地图上，安排势力、行军路线和事件，记录自己的三国故事。这是一个离线单机沙盘，战事和剧情由玩家裁定。

基础版 v0.1.0 包含90个人物、6个开局、53个地点和66条地点关系。支持人物拖放、编组、纪事、撤销重做、命名快照和沙盘备份。

## 开始玩

Windows用户下载并完整解压Windows包，双击 `SanguoSandtable.exe`。请将 `SanguoSandtable.pck` 与程序放在同一个文件夹。

1. 点击“选择开局”，选“完全自定义”或一个历史开局。
2. 在背包搜索人物，取到手边后拖到地图；拖到城池可驻城，按住Alt可自由摆放。
3. 右键人物卡查看资料或调整分组。地图滚轮缩放，中键拖动视角。
4. 按 `Ctrl+Shift+S` 留下快照，按 `Ctrl+J` 打开纪事。沙盘菜单可导入、导出和返回标题。

## 保存与备份

操作会自动保存。Windows存档目录是 `%APPDATA%\Godot\app_userdata\天下沙盘`。关闭游戏后复制整个目录，可备份本机状态；游戏内“备份当前沙盘”可导出单个 `.tianxia` 文件。

当前存档格式v18、人物目录v6。读取支持的旧档时，程序会先备份再迁移。升级后的存档请继续使用新版程序打开。

## 从源码运行

使用Godot 4.7.x打开 `project.godot`，等待资源导入后按F5。项目使用GDScript，无需C# SDK或API密钥。

`src/` 是游戏代码，`scenes/` 是场景，`data/` 是人物与地图资料，`assets/` 是素材。

在Windows的PowerShell 7中运行测试：

```powershell
pwsh -File tools/test.ps1 -GodotPath 'C:\Tools\Godot\godot.exe'
```

测试覆盖人物搜索与拖放、开局切换、存档迁移、快照和备份、撤销重做、未保存编辑的离开保护。加 `-Capture` 可运行界面检查并将截图存入 `artifacts/release/`。

安装与编辑器版本对应的导出模板后，可生成Windows程序：

```powershell
New-Item -ItemType Directory -Force builds | Out-Null
& 'C:\Tools\Godot\godot.exe' --headless --path . --export-release 'Windows Desktop' builds/SanguoSandtable.exe
```

## 当前限制

人物库仍在补充，史实与演义尚未提供完整的分栏对照。地图采用全国尺度的代表位置，适合摆放和阅读局势。当前主要验证Windows；其他平台和长时间游玩仍需测试。

欢迎提交问题或修改。反馈故障时，请附复现步骤、操作系统和游戏版本；提供存档前可先去掉私人纪事。

## 许可

代码与项目自有SVG采用MIT许可。字体、图标及资料的具体来源和许可见 `THIRD_PARTY_NOTICES.md` 与 `LICENSES/`。
