# 《向西守望》开发与提交指南

## 检出与运行

共享仓库为 `hxsx1016/dora-game`，默认分支为 `main`。首个公开试玩版 `v0.1.0` 以 `feature/dev-20261127` 合入 [PR #39](https://github.com/hxsx1016/dora-game/pull/39) 后的提交 `55826e793a38d4b27907c4d4204734c6fcb76091` 为玩法基线。发行标签指向合入后的 `main` 提交。

接手任务时用 `git remote -v`、`git fetch origin --prune` 和 `git status -sb` 确认远端与当前检出，按任务指定的 SHA 创建工作树。用 `git branch -r --sort=-committerdate` 及打开的 PR 核对同模块工作与合入目标。长任务协作见 [AGENTS.md](AGENTS.md)。

仓库已含可运行的 Lua。在 Dora SSR 中打开含 `init.lua` 的项目根目录，即可从该文件启动。开发环境使用 Dora SSR 1.10.2.6；以下命令需先启动引擎并连接本机 Web IDE，将 `Dora` 换成本机可执行文件。首次编辑 TypeScript 时安装类型声明，修改后构建，再运行正式入口。

```sh
Dora cli ts install -p .
Dora cli build -p . --lang ts
Dora cli run -p . --entry init.lua
```

## 源码与资源

| 位置 | 职责 |
| --- | --- |
| `init.ts` / `init.lua` | 设置资源路径、创建根节点，以 `splash` 启动。片头结束后进入标题页。 |
| `Script/watch/` | `app.ts` 调度菜单、开局与续读，`save.ts` 管理进度；`rooms.ts` 配置房间，`play.ts` 处理移动、碰撞和交互，`run.ts` 维护本局状态。 |
| `Script/watch/input/`、`Script/watch/targets/` | 键鼠、触屏、手柄驱动，以及 Windows、Android 手机、掌机、Web 各端的输入组合。 |
| `Script/watch/fe/` | 菜单、HUD、镜头、演出与音频。小满独行线的 `outside`、`village`、`forest`、`tower` 四房由 `scenes/xiaoman3d.ts` 加载场景、角色与道具，玩法判定仍在 `play.ts`。 |
| `assets/`、`art-source/` | 运行时分别从 `assets/art/`、`assets/audio/`、`assets/font/`、`assets/xiaoman3d/` 读取贴图、声音、字体与 GLB。分层源稿、品牌母图与素材来源在 `art-source/`。 |
| `tools/`、`.github/workflows/` | 本地审计、引擎回归、平台引导与组包脚本，以及持续集成和发行工作流。 |
| `docs/` | 剧本、美术设定、阶段计划与历次验收记录。美术改动先读[明朝全局美术设定](docs/守望-明朝全局美术设定.md)。 |

## 存档与回归

标题页「继续游戏」读取正式局的自动档。「开始游戏」确认重开后替换自动档，保留手动槽与跨局档案。章节预览使用独立的 `chapter` 来源。测试存档时使用隔离文件，覆盖正式局保存、重启续读及预览后原档可读三种情况。

| 布局 | 跨局档案 | 自动档 | 三个手动槽 |
| --- | --- | --- | --- |
| Windows 便携包，默认在游戏根目录的 `saves/` | `profile.sav` | `autosave.sav` | `slots/slot_1.sav` 至 `slot_3.sav`（同目录） |
| 常规布局，在引擎可写目录的 `watch-save/` | `archive.txt` | `session.txt` | `slots/slot_1.sav` 至 `slot_3.sav`（同目录） |

Windows 引导会探测写权限。便携目录只读时，优先写入引擎用户目录下的 `saves/`，再回退到用户目录本身。旧版档案、自动档与设置的迁移规则见 [Windows 启动引导](tools/windows-boot.lua)。

1. 在仓库根目录运行 `python3 tools/check-repo.py` 与 `python3 tools/audit-assets.py`，检查 TS/Lua 配对、Markdown 相对链接、素材、图集与字库。
2. 改 TypeScript 后，核对并提交本次构建产生差异的同名 Lua。在干净检出中重建后，以 `git diff --exit-code -- init.lua Script/watch/` 检查产物一致性。
3. 按改动在引擎项目上下文用 `dofile("tools/verify-session-save.lua")` 等脚本回归。片头用 `verify-brand-splash.lua`，正式局续读用 `verify-session-save.lua`，Windows 存档布局用 `verify-windows-portable.lua`，红布车用 `verify-p1-gameplay.lua`，低模四房用 `verify-xiaoman3d.lua`，各端输入隔离用 `verify-target-isolation.lua`。
4. 改输入、渲染或打包时记录设备、系统、分辨率和实际启动结果。提交前执行 `git diff --cached --check` 和 `git diff --cached --stat`，提交信息沿用 `类型(范围): 变更摘要`。

## 公开试玩发行

发行负责人先将整理后的变更合入 `main`，核对该提交的仓库检查、包体和试玩结果，再打 `v0.1.0` 标签。各端从同一发行提交构建。

- **Windows 与 Dora 源码包**使用 [Windows 发行工作流](.github/workflows/release-windows.yml)。`v*` 标签触发标准版、OpenGL 兼容版与源码包组装，并在 Windows 上检查标准版便携启动及只读回退。本地组包入口为 `tools/make-windows-pack.sh` 和 `tools/make-dora-source-pack.sh`；Windows 包需要对应后端的 Dora SSR v1.10.2 引擎及 Win32 启动器。
- **Android** 由 [Android 发行工作流](.github/workflows/release-android.yml) 构建手机和掌机 APK。上传至公开发行页需要正式签名。
- **Web 离线包**由 [Web 工作流](.github/workflows/deploy-web.yml) 随版本标签构建并上传到同版 Release。完整解压 `web-html.zip` 结尾的文件后打开 `index.html`。部署 GitHub Pages 是单独的可选步骤。

发行记录注明标签对应的完整提交 SHA、附件的 SHA-256 和各端实际验证结果。玩家下载入口统一指向 [GitHub Releases](https://github.com/hxsx1016/dora-game/releases)。
