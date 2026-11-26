# 交接文档 · Dora SSR 游戏比赛项目

> 后续更正（2026-11-22）：用户已确认以「守望」为主题的双线枪战与解谜游戏。以下为初次勘察时的历史快照，最新项目口径见 `PROJECT_OVERVIEW.md` 页首。

> 交接时间：2026-11-22 13:35（Asia/Shanghai）
> 上一会话状态：**只做了仓库勘察，一行代码都没写，仓库工作区干净**。
> 下一手任务：先出**项目规划**（玩法/框架/里程碑），规划确认后再动手搭代码。

---

## 0. 用户指令与角色

- 用户是**程序**（负责程序实现），会自己写代码，需要的是架构与规划支撑。
- 用户明确说过：**不要看仓库 README**（原话「不要看readme」）。原因未解释，规划时别依赖 README 内容。
- 引擎是 **Dora SSR**（用户确认：「游戏引擎是dorassr」）。
- 项目名：**未定**。仓库历史里的「月下山谷」是一段已废弃的 demo，**不是本项目**；正式项目名与主题以规划文档为准，不要拿它当设计输入。

---

## 1. 仓库现状（重要）

- 仓库：`https://github.com/hxsx1016/dora-game`，默认分支 `main`，本地克隆在
  `/Users/tqym_16/Desktop/个人项目/游戏比赛/dora-game`。
- **当前 `main` 上只剩两个文件**：`AGENTS.md`、`README.md`。代码已被清空。
- 提交链（`git log --all --oneline`）：

  ```
  055bd1a Delete init.ts
  424ad12 Delete init.lua
  7ca46a0 Delete .gitignore
  6ceae37 Merge pull request #1 from hxsx1016/feature/add-agents-md
  3cc7c13 docs: 添加 Agent 协作规范与长任务分支同步规则
  cfa7ead 初始化月下山谷 Dora 游戏项目
  ```

- **初始代码还在 git 历史里，可随时取回**：

  ```bash
  cd /Users/tqym_16/Desktop/个人项目/游戏比赛/dora-game
  git show cfa7ead:init.ts      # 6617 字节，唯一源文件
  git show cfa7ead:init.lua     # 8046 字节，TSTL 生成的 Lua
  git show cfa7ead:.gitignore
  git show cfa7ead --stat
  ```

- 被删掉的 `.gitignore` 内容（重建时原样恢复）：

  ```gitignore
  .agent/
  .cache/
  .build/
  .download/
  .upload/

  .env
  .env.*
  !.env.example

  .DS_Store
  Thumbs.db
  ```

- 仓库根 `AGENTS.md` 是**必须遵守**的协作规范，要点：
  - 长任务（>30 分钟或多文件）从最新 `main` 开分支：`feature/<简短任务名>`。
  - 每 30–60 分钟或每个可验证小阶段：`git add` → `commit` → `push`。
  - 提交前跑 Dora 构建 + 运行验证；`init.ts` 与生成的 `init.lua` 一起提交。
  - 推送前 `git fetch --all --prune` 并检查活跃远端分支。
  - 禁止 force push、禁止提交 `.agent/`、`.cache/`、`.build/`、`.download/`、`.upload/`、密钥。
  - 不确定的相关分支/冲突必须停下来问用户。

---

## 2. 原始代码做了什么（`cfa7ead:init.ts` 摘要）

单文件纯 `DrawNode` 绘制 demo，无图片资源，主题就是项目名：

- 夜空底色 `Color(9,15,39)`；月亮用「实心圆 + 底色圆」挖出月牙。
- 两层山脉折线多边形（远山 `Color(28,43,76)`、近山 `Color(17,31,59)`）。
- 底部湖面 + 3 条半透明金色线段当月色倒影。
- 标题 `月下山谷`、副标题 `MOONLIT VALLEY · 静听夜色`（字体 `sarasa-mono-sc-regular`）。
- 5 只萤火，各自相位，`schedule` 里按 `elapsed` 用正弦漂移 + 呼吸透明度重绘（每帧 `lights.clear()`）。
- `Esc` 弹出「要离开月下山谷吗？」确认框（`Director.ui` 覆盖层，随窗口缩放的 `scale`，两个按钮「继续游戏 / 退出游戏」，`App.shutdown()` 退出）。
- 关键写法：`const scale = Math.min(1, w / 480, h / 320)` 做弹窗自适应；`// @preview-file on clear` 标记。
- 无场景切换、无状态机、无资源加载、无音频、无存档——**是要被替换掉的 demo，不是框架**。

---

## 3. 环境（已核实）

| 项 | 值 |
|---|---|
| 引擎 | Dora SSR **1.10.2.6** on macOS，原生引擎 |
| App 位置 | `/Users/tqym_16/Applications/Dora.app` |
| CLI | `/Users/tqym_16/Applications/Dora.app/Contents/MacOS/Dora cli …` |
| Web IDE | `http://127.0.0.1:8866`，已连接（1 个客户端） |
| 引擎当前在跑 | 另一个项目 `/Users/tqym_16/Desktop/个人项目/游戏制作/dora/init`（「港町夜话」），**不是本项目** |
| PATH 情况 | `Dora` / `dora` 都不在 PATH，也没有 alias，必须用绝对路径 |

CLI 子命令（`Dora cli --help` 实测）：

```
status [-p project]                     # 只读状态
doctor [-p project] [--fix]             # 诊断/修复服务
build [-p project] [-f file] [--lang all|ts|yue|tl|xml|wa|yarn]
run [-p project] [--entry init.lua]
buildrun [-p project] [-f file] [--lang ...] [--entry ...]
stop
log [-n lines]
ts install [-p project] [-l zh-Hans|en]   # 生成 API/*.d.ts
doc search <pattern> [-l zh-Hans|en] [--source api|tutorial] [--lang ts|tsx|lua...] [-n limit]
doc read <file> [-l zh-Hans|en] [--start line] [--end line]
rust build|run|upload ...
```

注意事项：
- **`--source tutorial` / `--source api` 会报 `Unsupported doc type`**（实测），只有默认参数能搜到东西。
- 本机 Clash 之类的代理可能干扰 localhost 调用，报 JSON 解析错时按 `dora-cli-game-development` skill 的做法 `env -u http_proxy … Dora cli status --timeout 3`。
- 同一 session 还注册了 **Dora MCP 工具**（`mcp__dora__dora_status` / `dora_build` / `dora_buildrun` / `dora_run` / `dora_preview` / `dora_stop` / `dora_log` / `dora_doc_search` / `dora_doc_read` / `dora_doctor`），与 CLI 等价，调用更省事。项目路径参数传 `dora-game` 目录。

---

## 4. 技术地基（这些是搭框架前必须吃的约束）

### 4.1 编译器是 TypeScriptToLua（TSTL），不是真 JS

来源：`Dora.app/Contents/Resources/Doc/zh-Hans/Tutorial/ts/caveats.md` 与 `try-tstl.md`。

- `null` / `undefined` 都编译成 Lua `nil`，**运行时别用 `null`**；容器里表示「空」用哨兵值（如 `-1`、自定义 `const Null = {}`）。
- **真值判断按 Lua 语义**：`0`、`""`、`NaN` 都是 **true**。条件必须写显式比较（`if (x !== 0)`），不能靠 `if (x)`。
- `==` 与 `===` 完全等价。
- 数组 `.length` 编译成 Lua `#`；不要往数组里塞 `undefined` 打洞。
- `for...in` 顺序不保证；需要顺序就用数组。
- `Array.sort` **不稳定**（Lua `table.sort`）。
- Lua **局部变量上限 200**，单文件变量过多会运行时报错 → 框架必须**拆模块**，别写超长单文件。
- TSTL 不支持 `Math.hypot`、`Math.imul`；用 `Math.sqrt(x*x+y*y)`。
- 已知不可用：`lastIndexOf`、`charAt`（前项目实测注释）。
- `Sprite.texture` 只读，换图要重建节点（做框架时记在资源层）。

### 4.2 模块与目录

来源：`Tutorial/ts/project-management.md`。

- 项目根 = **包含 `init.<ext>` 的目录**（`.ts/.tsx/.lua/.yue/.tl/.wasm`）。引擎从当前文件向上搜索到最近的项目根。
- 推荐目录（官方）：

  ```
  project/
  ├── Audio/  Data/  Font/  Image/  Script/  Spine/
  └── init.ts
  ```

- **模块搜索路径顺序**：
  1. `<项目根>/Script`
  2. `<项目根>`
  3. `<引擎资源根>/Script/Lib`
  4. `<引擎资源根>/Script/Lib/Dora/zh-Hans`
  5. `<引擎资源根>`
- 所以 `import { X } from "moduleA"` → `<项目根>/Script/moduleA.ts`；
  `import { X } from "core/App"` → `<项目根>/Script/core/App.ts`;
  `import { X } from "Script/core/App"` 同样有效。
- **相对路径 `./` `../` 不可靠，别用**。
- 多文件 TS 已被引擎自身验证：`Dora.app/Contents/Resources/Script/Tools/SelfUpdater/` 下就是 `Service.ts / View.ts / Manifest.ts / UpdateSync.ts` 多文件 + 同名 `.lua` 并存，写法是 `import ... from "Tools/SelfUpdater/Manifest"`。**结论：多文件模块这条路是通的**（但本项目尚未亲自 build 验证过）。

### 4.3 坐标与节点

来源：`Tutorial/ts/setup-scene.md`、`dora-engine-coding` skill。

- 左手系：+X 右、+Y 上。
- `Director.entry` / `Director.ui` 的直接子节点以**屏幕中心**为原点。
- **有 `width/height` 的父节点**：子节点坐标原点在父矩形**左下角**；`anchor` 只决定父节点自身哪一点对齐到 `position`。
- 居中子节点：`Vec2(parent.width / 2, parent.height / 2)`。
- 全屏绘制根节点**不要给 size**，否则坐标语义会变；需要点击区就另外挂一个带 size 的输入节点。
- `Node.schedule()` **每个节点只有一个槽位**，重复调用是替换不是叠加。主循环统一放一个 schedule，或分给不同子节点。
- 键盘：`Keyboard.isKeyPressed(KeyName.Left)` 持续按住；离散操作优先 `node.onKeyDown(cb)`；回车是 `KeyName.Return`（不是 Enter）。
- 触摸：`touch.location` 是**本节点局部坐标**；`touch.viewLocation` 是视图逻辑坐标。
- 字体必须用引擎自带名：`Label('sarasa-mono-sc-regular', size)`，且**返回值可能是 undefined，必须判空**。
- 弹窗/UI 覆盖层挂 `Director.ui`；`node.onCleanup` 里清引用。

### 4.4 其它可用能力（规划时可选）

引擎内置：ECS、Platformer 框架、Yarn Spinner 对话、TMX 瓦片地图、Spine、Effekseer 特效、ImGui 调试面板、SQLite、Excel 配置表、nvg 矢量图形、音频（BGM/音效/3D 音）、粒子、物理、动画编辑器、DoraX/TSX 声明式 UI。
详细清单见 `Doc/zh-Hans/welcome.md`；对应教程在 `Doc/zh-Hans/Tutorial/ts/`（43 篇）。

---

## 5. 已核实 vs 未核实

**已核实（可直接引用）**
- Dora SSR 1.10.2.6 在线，Web IDE 8866 可用，CLI 可用。
- `main` 只剩 AGENTS.md/README.md；初始代码可 `git show cfa7ead:init.ts` 取回。
- 目录/模块/坐标/TSTL 约束（上文 §4，均有文档出处或前项目实测注释）。
- 引擎内多文件 TS 项目存在（SelfUpdater），导入写法 `import ... from "Tools/..."`。

**未核实（规划前建议花 10 分钟打掉）**
1. 本项目 `init.ts` + `Script/core/*.ts` 多文件是否真的能 `Dora cli build` 通过、生成 `Script/core/*.lua`，并且运行时 `require` 找得到。
   - 最小验证：写 `init.ts` 引一个 `Script/core/Probe.ts`，`Dora cli build -p dora-game`，看产物与 `Dora cli run` 是否报 require 失败。
2. `init.lua` 是否仍然必须与 `init.ts` 一起提交（AGENTS.md 要求是，但要确认构建产物路径：根目录 `init.lua` vs `Script/` 下同名）。
3. 引擎当前跑的是别的项目，`Dora cli run -p dora-game` 会切换运行目标——**会打断用户正在用的「港町夜话」预览**，动之前确认。
4. 比赛规则/主题/截止时间/评审维度：**完全未知**，规划必须先问用户或向用户要比赛文档。

---

## 6. 待规划的问题（交给下一个模型）

1. **玩法**：完全未定。历史 demo「月下山谷」的视觉（夜色/山谷/湖/萤火/月牙）与本项目无关。玩法类型、核心循环、目标体验必须先定，框架依赖它。
2. **范围**：比赛周期内能交付的核心循环（vertical slice）是什么，明确砍掉什么。
3. **框架分层**：建议方向（未验证，供讨论）：
   - `init.ts` 只做 bootstrap；
   - `Script/core/`：App 外壳、Scene 基类、SceneManager（含转场）、EventBus、状态机；
   - `Script/services/`：输入、音频、存档、资源、计时/缓动；
   - `Script/game/`：场景、实体、系统；
   - `Script/ui/`：设计令牌（配色/字号）、对话框、HUD；
   - `Script/data/`：配置表；`Script/utils/`：数学/日志。
   - 每个模块一个文件，规避 Lua 200 局部变量上限。
4. **是否需要 TSX/DoraX**：声明式 UI 能省很多样板，但要额外验证构建链；纯 TS + Node 树更稳。二选一需决策。
5. **资源管线**：比赛用纯 `DrawNode` 程序化绘制（像原 demo，零美术依赖）还是导入图片/字体/音频？决定 `Image/Audio/Font` 目录与加载层设计。
6. **分支与提交策略**：按 AGENTS.md 开 `feature/<名>`，里程碑粒度提交。

---

## 7. 下一手可直接执行的命令

```bash
# 1) 状态
/Users/tqym_16/Applications/Dora.app/Contents/MacOS/Dora cli status \
  -p "/Users/tqym_16/Desktop/个人项目/游戏比赛/dora-game"

# 2) 取回原始代码参考（不覆盖工作区）
cd "/Users/tqym_16/Desktop/个人项目/游戏比赛/dora-game"
git show cfa7ead:init.ts > /tmp/valley_reference.ts

# 3) 需要时重建 TS 声明
/Users/tqym_16/Applications/Dora.app/Contents/MacOS/Dora cli ts install \
  -p "/Users/tqym_16/Desktop/个人项目/游戏比赛/dora-game" -l zh-Hans

# 4) 构建 / 运行（注意会抢占引擎当前运行的项目）
/Users/tqym_16/Applications/Dora.app/Contents/MacOS/Dora cli build -p "…/dora-game"
/Users/tqym_16/Applications/Dora.app/Contents/MacOS/Dora cli buildrun -p "…/dora-game"
```

参考 `tsconfig.json`（取自本机已验证的 Dora TS 项目）：

```json
{
  "compilerOptions": {
    "jsx": "react",
    "target": "ESNext",
    "module": "ESNext",
    "strict": true,
    "esModuleInterop": false,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "allowSyntheticDefaultImports": true,
    "rootDir": "./",
    "typeRoots": ["API"],
    "types": ["Dora"]
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "dist"]
}
```

（`API/` 目录由 `Dora cli ts install` 生成，内含 `Dora.d.ts`、`DoraX.d.ts`、`ImGui.d.ts`、`Platformer.d.ts`、`nvg.d.ts` 等。）

---

## 8. 相关技能（下一手应当加载）

- `dora-cli-game-development` — CLI 用法、构建/运行、故障排查。
- `dora-engine-coding` — Dora 运行时编码硬规则（禁止浏览器 API、禁止猜 API、坐标/调度基线）。
- `dora-ui-design` — 真要写 UI 时。
- `dora-plan-implementation-capabilities` — 若在 Plan 模式里做规划。
- `project-work-log` — 本仓库有 AGENTS.md 提交纪律，多步改动时按该 skill 记工作日志。

---

## 9. 一句话总结

**仓库是空的（代码在 `cfa7ead`），引擎在线（Dora SSR 1.10.2.6 / Web IDE :8866），约束已摸清，规划未定；下一手先要比赛规则 + 玩法定位，再定框架分层，最后用 10 分钟打掉「多文件 TS 构建」这一个地基验证，然后开 `feature/*` 分支落代码。**
