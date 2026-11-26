# 《向西守望》Windows x64 离线便携包

完整解压 ZIP，保留目录结构，从 `Dora.exe` 或 `启动.cmd` 启动。标题页可开始游戏、选择章节或查看操作说明。引擎、Lua 脚本、中文字体、场景、角色、水墨 UI 贴图及分轨声音均随包提供。

## 从工程打包

1. 将 Dora SSR v1.10.2 的 Windows x64 官方发行 ZIP 解压到仓库的 `.download/win/`，确认其中直接包含 `Dora.exe`。
2. 在 Dora SSR 中构建工程，生成 `init.lua` 和 `Script/watch/` 下各层的 Lua。
3. 从仓库根运行 `bash tools/make-windows-pack.sh`，生成 `dist/watch-windows-x64/` 和 `dist/watch-windows-x64.zip`。

打包脚本递归复制运行时 Lua 模块及整个 `assets/` 目录。编辑用 PSD 和素材来源保存在源工程的 `art-source/`。

## 包内文件

| 路径 | 用途 |
| --- | --- |
| `Dora.exe` 与同目录 DLL | Dora SSR v1.10.2 Windows x64 运行时 |
| `Script/init.lua` | 设置资源搜索路径，加载游戏入口 |
| `Script/main.lua`、`Script/watch/` | 游戏入口、玩法、前端与房间模块 |
| `Script/Lib/` | Lua 运行库 |
| `assets/art/`、`assets/font/` | 场景、角色、UI、字体及字体许可 |
| `assets/audio/` | 风、水、环境、音效和占位人声 |
| `LICENSES`、`GodotRuntimeNotices` | 随引擎发行的许可和声明 |

Windows 真机验收需从解压后的目录双击启动，检查中文、分辨率、暂停与恢复、切场和资源显示。发行记录写明提交号、ZIP 校验值和实测结果。

反馈问题时，请附 Windows 版本、分辨率、ZIP 校验值、所在房间和复现步骤。
