# 合流检查点 M1 验收与交付记录（`feature/fe-dual-route`）

> **合流节点**：**M1**（Wave 1 三路并行 `fe-01` + `fe-02` + `fe-03` 汇流至前端总集成分支 `feature/fe-dual-route`）
> **上游锁定基线**：`origin/feature/watch-level-rework@648ff43`
> **前序合流点**：M0（`origin/feature/fe-dual-route@cf260d9`）
> **实测环境**：Linux x86_64（`ubuntu-dev`，Dora SSR 1.10.2.12，1280×720 虚拟帧缓冲；Windows 离线包冷启动待真机复测）

---

## 一、合流分支与活跃远端核查

### 1. 本次合流的 Wave 1 三条分支

| 分支 | 合并前提交 | 交付内容 | 与前端基线文件冲突 |
| --- | --- | --- | --- |
| `origin/feature/fe-01-gate-cuff-lowpoly` | `60d2e01` | 程序化 2.5D 低模内核 `lowpoly.ts`、风台 24s 转景 `gate_transition.ts`、补线袖口三镜与双出口 `cuff_shots.ts`、30 份 `assets/audio/gate/*.wav`、`verify-fe01.lua` | 0 文件冲突 |
| `origin/feature/fe-02-reload-carry-craft` | `fbbcf4d` | 背负姿态 `carry_pose.ts`、3×3 慢时连线换弹 `reload_wheel.ts`、第三段安全工台 `craft_bench.ts`、11 份 `assets/audio/combat/*.wav`、对照图与 `verify-fe02.lua` | 0 文件冲突 |
| `origin/feature/fe-03-prologue-ming-art` | `aaa641e` | 共同序章 `P01-P04` 演出 `prologue_intro.ts`、明朝美术运行态校准与体检 `ming_audit.ts`、`fe03-ming-art-audit.md`、`verify-fe03.lua` | 0 文件冲突 |

### 2. 活跃后端远端核查与适配结论

| 远端分支 | 最新提交 | 核查与 M1 适配结论 |
| --- | --- | --- |
| `origin/feature/story-b1-carry` | `4b294db` | B1 城门 `gate-wait`/`gate-hand`、`carryOn`、`reload.ts` 3×3 九宫格（0 起点 / 2 灯纹 / 4 铃纹 / 8 终点、240:60 双时钟）与 M0/M1 前端契约完全同构 |
| `origin/feature/story-b2-escort` | `80aea38` | B2 五段护送（`escort2`–`escort5`）与 `craft.ts`（`wood`/`bell`、`benchCraft`/`benchRejected` 事件、`craftBench.active`）；M1 已同步补齐 `audio.ts` 事件映射、`contract.ts` `atBench` 推导及 `ming_audit.ts` `escort2`–`escort5` 明朝底图映射 |

---

## 二、M1 跨分支逻辑冲突排查与解决方案

Wave 1 三条分支严格遵守防冲突所有权矩阵，因此 Git 层零文件冲突；但在汇流联调时排查并解决了以下 **9 项跨分支逻辑与表现冲突**：

1. **7 枚插件分层注册优先级与运行时钩子统一**（[frontend.ts](../../Script/watch/fe/frontend.ts)）：
   - 在 `WatchFrontend` 构造函数按严格渲染优先级统一注册 7 枚插件：`MingArtAuditPlugin` → `GateTransitionPlugin` → `CarryPosePlugin` → `PrologueIntroPlugin` → `CuffShotsPlugin` → `ReloadWheelPlugin` → `CraftBenchPlugin`；
   - 确保 `GateTransitionPlugin` 先于 `CuffShotsPlugin` 绘制风台电影遮幅，使 `P05` 退袖桥接与 `G05` 重逢袖口/周戍近景叠在遮幅之上而不被黑边吞没；
   - 新增 `getPlugin(id)` 并在 `syncRuntimeHooks()` 动态同步 `package.loaded["watch.fe"]` 的全部 7 枚插件引用，测试脚本替换单插件时钩子自动保鲜。
2. **过场接管时 HUD 文本与准星透穿修复**（[frontend.ts](../../Script/watch/fe/frontend.ts)）：
   - 原管线先执行 `hud.draw`（向 `order=10` 的 `TextPool` 写入体力/章名文本）再执行 `drawCutsceneOverlay`，导致 `P01` 睁眼黑场、`P02` 墙影滚碗、`P03`/`P05`/`G05` 等过场上出现 HUD 文字与战斗准星透穿；
   - 改为先判定 `drawCutsceneOverlay`，当过场接管（`cutsceneHandled === true`）时同帧跳过常规 HUD 与战斗准星绘制；普通实景态与正式 `P02` 逃柜红晕态保持原序不受影响。
3. **背负 / 攀爬 / 工台放下态消除原生同伴孤儿脚影**（[actors.ts](../../Script/watch/fe/renderer/actors.ts)、[frontend.ts](../../Script/watch/fe/frontend.ts)）：
   - `CarryPosePlugin` 压隐 `actor_child` 精灵时，`actors.ts` 此前已在 `fgDraw` 先绘出远端小满椭圆阴影；为 `ActorsRenderer.drawAll` 增设可选参数 `suppressPartner = false`，在背负/攀爬/工台/远距排演牵手时一并跳过原生同伴精灵与脚影（真实近距牵手保持原生小满绘制）。
4. **补线青布袖口色板单一真源统一**（[prologue_intro.ts](../../Script/watch/fe/cutscenes/prologue_intro.ts)、[carry_pose.ts](../../Script/watch/fe/renderer/carry_pose.ts)、[craft_bench.ts](../../Script/watch/fe/ui/craft_bench.ts)）：
   - 统一以 `fe-01` 的 `cuff_shots.CUFF_PALETTE` 为唯一真源（`indigoBase`、`stitchThread`、6 针斜补线口径），消除 `fe-01` / `fe-02` / `fe-03` 各自硬编码袖口 RGB 与针数微小漂移，为 Wave 2 `fe-06` 的 `E02` 博物馆回柜奠定同源基础。
5. **B2 后端工台事件与 `atBench` 契约补齐**（[audio.ts](../../Script/watch/fe/audio.ts)、[contract.ts](../../Script/watch/fe/contract.ts)）：
   - `audio.ts` 新增监听 `benchCraft`（`craft_done.wav`）与 `benchRejected`（`craft_insufficient.wav`），修复 `craft_bench.ts` 依赖后端音频事件导致实机联调静默的风险；
   - `contract.ts` 的 `backCarry.atBench` 在无独立字段时自动回退至 `craftBench.active`，并在 `deriveVisualMode` 显式列出 `escort2`–`escort5`。
6. **B2 护送段明朝底图映射补齐**（[ming_audit.ts](../../Script/watch/fe/renderer/ming_audit.ts)）：
   - 在 `FALLBACK_MING_BACKDROPS` 补充 `escort2`/`escort3` → `bgFar_checkpoint`、`escort4` → `bgFar_forest`、`escort5` → `bgFar_tower`，避免 B2 新房落回街道底图或退化渲染。
7. **明朝红线高危赛博遗留 M1 清理（`MING-01` / `MING-02`）**（[theme.ts](../../Script/watch/fe/theme.ts)、[stage.ts](../../Script/watch/fe/renderer/stage.ts)）：
   - 全 8 房关闭 `showSearchlights`（彻底杜绝现代探照灯）；
   - 将 `stage.ts` `drawCoverBlock` 的冰青全息护盾竖条与强蓝光晕改为克制的木沿/砖沿微亮边线。
8. **编译产物 Lua `require` 路径全仓对齐**：
   - 将 Dora 单文件构建产出的 `require("watch.*")` 统一规范为 `require("Script.watch.*")`，确保与 `init.lua`、`app.lua`、`windows-boot.lua` 及所有验证脚本共享同一 `package.loaded` 实例，杜绝模块双加载。
9. **测试断言与离线打包清单同步**（[verify-fe02.lua](../../tools/verify-fe02.lua)、[make-windows-pack.sh](../../tools/make-windows-pack.sh)）：
   - 适配 `verify-fe02.lua` 断言以兼容 M1 默认预注册的 7 枚插件；
   - `make-windows-pack.sh` 增补 `assets/audio/` 复制清单，保证 41 份新增分轨 WAV 随 Windows 离线包完整交付。

---

## 三、全量验证与回归结果

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| Dora SSR 1.10.2.12 TS → Lua 编译 | **PASS** | 全部 10 份改动 `.ts` 零报错编译，全仓 `Script/watch/fe/**/*.lua` 均对齐 `Script.watch.*` |
| `python3 tools/check-repo.py` | **PASS** | 36 组源码与 Lua 成对完整，全部 Markdown 相对链接零断链 |
| 后端零侵入红线核查 | **PASS** | 相对 `origin/feature/watch-level-rework` 对 `init`/`play`/`run`/`rooms`/`depth`/`escort`/`input`/`keys`/`app` 改动 **0 处** |
| 字库 cmap 缺字扫描 | **PASS** | `Script/watch/fe/**` 全量 628 个非 ASCII UI 字符在 `lxgw-neo-zhisong.ttf` 命中 628/628（0 缺字）；风台数数汉字在 `longcang-brush.ttf` 0 缺字 |
| `tools/verify-m1.lua`（新增 M1 联合验收） | **PASS 16 / FAIL 0** | 验证默认 7 插件顺序、`watch.fe` 钩子、袖口同源、过场零 HUD 透穿、P01→P04 衔接、风台 6 拍 0.000000 漂移、G05/fe-02 交接、B2 音频与 `atBench` |
| `tools/verify-fe01.lua` | **PASS 25 / FAIL 0** | 低模投影不变量、城外栈台侧移遮挡与车柄反算、风台 24s、G04/G05 双出口、袖口三镜与 30 份 WAV |
| `tools/verify-fe02.lua` | **PASS 70 / FAIL 0** | 背负全态、3×3 双输入三路径、无效重画、240:60 双时钟与暂停双冻、工台全态与 11 份 WAV |
| `tools/verify-fe03.lua` | **PASS 32 / FAIL 0** | P01/P02/P04 状态机与重试清零、明朝底图拦截、木屑/砖灰、58+15 帧键与红布左端不变式 |
| `tools/verify-d6.lua` | **PASS 24 / FAIL 0** | 风台 1439/1440 交权、掩体、2700 拍边界与投瓶落点零回归 |
| `tools/verify-integration.lua` | **PASS 22 / FAIL 0** | 菜单键鼠、高清反算、全资源槽与 8 房渲染暂停零回归 |
| `tools/verify-trial.lua` | **PASS** | `outer` 3451 拍 / `drygoods` 3360 拍五段试炼零回归 |
| 扩展回归（`verify-d7`/`d8`/`d9`/`depth`） | **PASS（4/4 全绿）** | `d7` 32/0、`d8` 13/0、`d9` 27/0、`depth` 通过 |

---

## 四、M1 首批视觉交付证据索引

1. **风台 24s 五节点同机位转景 + G05 重逢切回像素风（排演实拍）**：[m1-gate-5frames.png](../fe-showcase/m1-gate-5frames.png)
   - 覆盖 `0s (0 拍)` / `6s (360 拍)` / `12s (720 拍)` / `18s (1080 拍)` / `24s (1440 拍)` 与 `G05` 男主 0.6s 满握抬镜回切像素风；小满脚底与门槛像素偏移实测 `0.000000 px`。
2. **同一道补线袖口三镜（`P03`/`P05`/`G05`）+ 共同序章（`P01`/`P02`/`P04`）实拍**：[m1-cuff-3shots-and-prologue.png](../fe-showcase/m1-cuff-3shots-and-prologue.png)
   - 实证三镜袖口色板与 6 针补线完全同源，`P01`/`P02` 过场零 HUD 文本/准星透穿，`P04` 不锁控且窗板与石槽磨痕清晰可辨。
3. **序章军粮棚 vs 第三段安全工台同尺度对照（排演实拍）**：[fe02-granary-vs-bench.png](../fe-showcase/fe02-granary-vs-bench.png)
4. **背负姿态 + 3×3 慢时连线换弹 + 工台首次试握与灰度可读总览（排演实拍）**：[fe02-reload-carry-overview.png](../fe-showcase/fe02-reload-carry-overview.png)

> 注：以上截帧均在 Dora SSR 1.10.2.12 默认 7 插件管线下实拍产出；正式带声录屏与 Windows x64 离线包真机冷启动将在接入后端 B1/B2 后与 Wave 2 / `fe-07` 一并完成。

---

## 五、Wave 2 开启就绪清单

至此 **合流检查点 M1 正式达成**，已满足开启 Wave 2 三路并行（[Wave 2 施工书](wave2-04-06.md)）的全部前置条件：

- `feature/fe-04-child-lowpoly`：可直接从 `origin/feature/fe-dual-route` 切出并复用 `Script/watch/fe/renderer/lowpoly.ts`（含 `projectWorld3D`、`verifyWalkPlaneAlignment`、`LowpolyScene`、`MING_MATERIALS`、`buildOutsideJettyLowpoly`）；
- `feature/fe-05-dual-endings`：可直接基于 `drawCutsceneOverlay` 与统一过场 HUD 压隐机制挂载 `tower_endings.ts`；
- `feature/fe-06-well-museum`：可直接复用 `cuff_shots.ts` 导出的 `drawPatchedCuff()` 与 `CUFF_PALETTE` 实现 `E02` 博物馆回柜同袖衔接。
