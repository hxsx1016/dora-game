# 《向西守望》开发与提交指南

## 接入项目

在含 `init.ts`、`LICENSE`（Apache-2.0）与 `tsconfig.json` 的仓库根目录执行以下命令，确认检出包含 `Script/watch/`。Git 默认分支为 `main`，多端适配与全阶段整合基线为 `exp/multi-device-adapt`（音频并行线为 `feature/audio-overhaul`，角色动作并行线为 `codex/character-motion`）。

```sh
git fetch --all --prune
git status -sb
git remote -v
```

以下构建命令要求启动 Dora SSR 并连接本机 Web IDE。将 `Dora` 换成本机引擎可执行文件的路径。开发基线为 Dora SSR 1.10.2.6，组包脚本使用 Windows x64 发行包 v1.10.2。首次检出运行 `ts install` 生成 `API/` 类型声明。

```sh
Dora cli ts install -p .
Dora cli build -p . --lang ts
Dora cli run -p . --entry init.lua
```

## 文件归属

| 改动 | 应提交的文件 |
| --- | --- |
| 玩法、输入或画面 | `init.ts`、`Script/watch/*.ts` 中本次涉及的文件，以及重新构建后内容有变化的同名 Lua。引擎启动依赖这些 Lua。 |
| 构建与打包 | `tools/` 中的脚本。Windows 启动引导 `tools/windows-boot.lua` 是手写文件。 |
| 需求与验证 | `docs/` 中的需求、记录及文档引用的图片。原始截帧先放本地 `shots/`。 |
| 运行时资源 | 提交游戏实际使用的素材及授权记录。新增资源时同步更新打包脚本的复制清单。 |

前端同事负责角色显示、HUD、镜头和声音。玩法侧负责模拟状态和一次性事件。双方接口见[前端需求](docs/守望-前端需求.md)。

## 提交前验证

1. 在仓库根目录运行 `python3 tools/check-repo.py` 与 `python3 tools/audit-assets.py`（Windows 也可用 `py -3`），检查正式入口与模块配对、静/动态资产与 `.clip` 图集帧、全仓字库 0 缺字、Lua `require` 规范以及 Markdown 相对文件链接。推送和 PR 在 GitHub Actions 执行同类检查。
2. 改动 TypeScript 后执行上面的 Dora 构建。核对实际生成的 Lua 差异。纯类型或注释的修改可能只改变 TS。核验已提交产物时，在干净检出中构建，再运行 `git diff --exit-code -- init.lua Script/watch/`。
3. 改玩法、前端或剧本对白时，在引擎的项目上下文执行核心回归脚本（含综合回归 `verify-remediation.lua`）：

```lua
dofile("tools/verify-remediation.lua")
dofile("tools/verify-story-gate.lua")
dofile("tools/verify-b1.lua")
dofile("tools/verify-b2.lua")
dofile("tools/verify-c1.lua")
dofile("tools/verify-c-fix.lua")
dofile("tools/verify-m2.lua")
dofile("tools/verify-fe01.lua")
dofile("tools/verify-fe05.lua")
dofile("tools/verify-touch-input.lua")
```

4. 改输入、渲染或打包时，另记真实设备、系统、分辨率和测试结果。提交说明写明已跑的命令及结果，Windows 冷启动以实际解压运行记录为准。
5. 用 `git diff --cached --check` 和 `git diff --cached --stat` 复核暂存内容。提交信息沿用 `类型(范围): 变更摘要`，例如 `fix(watch): 修正城门重试计时`。远端协调按 [AGENTS.md](AGENTS.md) 执行。

## Windows 交付与自动发版

仓库支持基于 Dora SSR v1.10.2 官方 Windows 运行时的免安装便携打包（Direct3D 12 标准版 + OpenGL 兼容版）与 Dora 源码包组装：

1. 本地打包：将官方 `dora-ssr-v1.10.2-windows-x64.zip`（及可选 `-opengl.zip`）分别解压到 `.download/win/`（和 `.download/win-opengl/`），重新构建 TypeScript 后执行：
   ```sh
   python3 tools/audit-assets.py
   bash tools/make-windows-pack.sh --backend d3d12 --version v0.1.0-rc1
   bash tools/make-windows-pack.sh --backend opengl --version v0.1.0-rc1
   bash tools/make-dora-source-pack.sh --version v0.1.0-rc1
   ```
   脚本采用白名单裁剪并组装为「根目录原生 Win32 启动器 `WestwardWatch.exe` + `saves/` 默认便携存档目录 + `runtime/` 收拢运行时」结构（排除 `Doc/`、`www/`、`dora-wa/`、`dora_godot.dll`、`wa.dll`、`GeneralUserGS.sf3`、引擎 `Font/`、`Image/` 及 `Script/Lib` 除 `lualib_bundle.lua` 外的全部开发文件），写入固定 `tools/windows-game-id` 至 `runtime/dora-game-id`，将 `tools/windows-boot.lua` 复制为 `runtime/Script/init.lua`（注入发行标志、启用默认 `<游戏目录>/saves/` 多槽位存档与只读自动降级，并支持旧档平滑迁移），将 `init.lua` 复制为 `runtime/Script/main.lua`。
2. 自动 CI 与冷启动冒烟：推送 `v*` Tag 或手动触发 `.github/workflows/release-windows.yml` 会在 `windows-latest` 原生编译根目录启动器 `WestwardWatch.exe` 并通过 `rcedit` 为运行时注入游戏图标与 PE 版本信息，随后组装三件套并在中文路径下完成双击直启、默认 `saves/` 便携读写与只读目录降级双轮冷启动冒烟验收。详见 [2026 开源游戏开发大赛发版与 AtomGit 同步指南](docs/2026开源游戏开发大赛-发版与AtomGit同步指南.md)。

发行记录写入构建所用 Git 提交号、ZIP 的 SHA-256、断言结果及 Windows 真机状态。压缩包、引擎下载目录、类型声明与开发缓存留在本地。
