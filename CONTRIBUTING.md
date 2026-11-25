# 《向西守望》开发与提交指南

## 接入项目

在含 `init.ts` 与 `tsconfig.json` 的仓库根目录执行以下命令，确认检出包含 `Script/watch/`。Git 默认分支为 `main`。关卡重制、全局机制与护送试炼的集成分支为 `feature/watch-level-rework`。

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

1. 在仓库根目录运行 `python3 tools/check-repo.py`（Windows 也可用 `py -3`）。工具需要 Git 和 Python 3.8+，检查正式入口与模块配对、Markdown 相对文件链接，以及已被 Git 跟踪的忽略文件。推送和 PR 在 GitHub Actions 执行同一命令。
2. 改动 TypeScript 后执行上面的 Dora 构建。核对实际生成的 Lua 差异。纯类型或注释的修改可能只改变 TS。核验已提交产物时，在干净检出中构建，再运行 `git diff --exit-code -- init.lua Script/watch/`。
3. 改玩法时，在引擎的项目上下文执行相关回放。`verify-d6.lua` 有断言，失败时抛错。另两份脚本打印逐拍结果，按需求中的期望读数核对。

```lua
dofile("tools/verify-d6.lua")
dofile("tools/verify-d7.lua")
dofile("tools/verify-d8.lua")
dofile("tools/verify-d9.lua")
dofile("tools/verify-integration.lua")
dofile("tools/verify-trial.lua")
dofile("tools/replay-gate.lua")
dofile("tools/replay-d5.lua")
```

4. 改输入、渲染或打包时，另记真实设备、系统、分辨率和测试结果。提交说明写明已跑的命令及结果，Windows 冷启动以实际解压运行记录为准。
5. 用 `git diff --cached --check` 和 `git diff --cached --stat` 复核暂存内容。提交信息沿用 `类型(范围): 变更摘要`，例如 `fix(watch): 修正城门重试计时`。远端协调按 [AGENTS.md](AGENTS.md) 执行。

## Windows 交付

把官方引擎包解压到 `.download/win/`，确认其中直接包含 `Dora.exe`。重新构建 TypeScript 后，在有 Bash、rsync 和 zip 的环境执行 `bash tools/make-windows-pack.sh`。成品为 `dist/watch-windows-x64.zip`。脚本将 `tools/windows-boot.lua` 复制成包内 `Script/init.lua`，将仓库 `init.lua` 复制成包内 `Script/main.lua`。

发行记录写入构建所用 Git 提交号、ZIP 的 SHA-256、断言结果及 Windows 真机状态。压缩包、引擎下载目录、类型声明与开发缓存留在本地。
