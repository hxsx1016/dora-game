# 《向西守望》Windows x64 离线包

玩家解压完整 ZIP 后双击 `Dora.exe`。标题页可开始游戏、直达八个章节或查看操作说明。离线包把游戏 Lua 脚本、中文字体、场景、角色和界面贴图一起放在本地。

## 从工程打包

1. 准备 Dora SSR v1.10.2 的 Windows x64 官方发行 ZIP，解压到仓库的 `.download/win/`，确认里面直接包含 `Dora.exe`。
2. 在 Dora SSR 中构建本工程，生成 `init.lua` 和 `Script/watch/` 下各层的 Lua。
3. 从仓库根运行 `bash tools/make-windows-pack.sh`。脚本生成 `dist/watch-windows-x64/` 和 `dist/watch-windows-x64.zip`。

引导脚本先配置资源路径，再加载 `Script/main.lua`。打包脚本递归收集前端 Lua 模块，并复制 `assets/art/` 的 PNG 和图集坐标。编辑用 PSD 位于源工程的 `art-source/`。

正式联调在 Windows 真机从解压后的目录双击启动，检查中文、分辨率、暂停与恢复、切场和资源是否显示。Dora SSR 引擎许可随发行包的 `LICENSES/` 提供。
