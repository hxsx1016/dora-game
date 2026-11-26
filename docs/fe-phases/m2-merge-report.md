# 合流检查点 M2 验收与交付记录（`feature/fe-dual-route`）

> **合流节点**：**M2（全功能贯通节点）**——Wave 2 三路并行 `fe-04` + `fe-05` + `fe-06` 汇流至前端总集成分支 `feature/fe-dual-route`
> **上游锁定基线**：`origin/feature/watch-level-rework@648ff43`
> **前序合流点**：M1（`origin/feature/fe-dual-route@5a6966e`）
> **实测环境**：Linux x86_64（`ubuntu-dev`，Dora SSR `1.10.2.12`，1280×720 离屏渲染实拍；Windows 离线包真机冷启动待 `fe-07` 收口复测）

---

## 一、合流分支与活跃远端核查

### 1. 本次合流的 Wave 2 三条分支

| 分支 | 合并前提交 | 交付内容 | 与前端基线文件冲突 |
| --- | --- | --- | --- |
| `origin/feature/fe-04-child-lowpoly` | `edf353e` | 小满单人线《小小梦魇》风低模四房 `lowpoly_world.ts` / `village_undertable.ts` / `forest_creek.ts`、14 份 `assets/audio/child/*.wav`、实拍图与 GIF、`verify-fe04.lua` | 0 文件冲突 |
| `origin/feature/fe-05-dual-endings` | `1d20a83` | 北塔双结局同机位配对演出 `tower_endings.ts`（F03 / M03 14 锚点 0.000 px 对齐）、15 份 `assets/audio/tower/*.wav`、对比图与 `verify-fe05.lua` | 0 文件冲突 |
| `origin/feature/fe-06-well-museum` | `67f9f3a` | 双通关水井与现代抗日主题博物馆 `well_museum.ts`（E01–E02）、「时间穿梭器」移动轨迹残影 `afterimage_artifact.ts`、11 份 `assets/audio/museum/*.wav`、实拍图与 `verify-fe06.lua` | 0 文件冲突 |

### 2. 活跃后端远端核查与 M2 前向适配结论

| 远端分支 | 最新提交 | 核查与 M2 适配结论 |
| --- | --- | --- |
| `origin/feature/story-b2-escort` | `8869a35` | `OUTSIDE/VILLAGE/FOREST/TOWER` 坐标与 `stepTower`（两线第一行小满、第二行留白/周戍）与 M2 完全一致 |
| `origin/feature/story-c-archive` | `64cb23f` | 后端 C 已落地 `Play.wellOpen`、`Play.wellX = 430`、`phase = "prologue-well"`、独立 `MUSEUM_ROOM`（`room.key = "museum"`，含 `museum-cabinet`/`museum-hall`/`museum-lamp`/`museum-return`/`museum-knock`/`museum-done`）、`submitFeIntent({ kind: "wellPick" })` 与 `artifactFound`/`museumStep`/`museumDone` 事件；M2 已在 `contract.ts`、`audio.ts` 与 `well_museum.ts` 完整实现零侵入前向对齐 |
| `origin/feature/story-d-integration` | `dafed63` | 已核对 D 分支合并 M1（`2967201`）的接口清单；本次 M2 严守后端零侵入红线，确保 D 侧后续合入 M2 零核心冲突 |

---

## 二、M2 跨分支逻辑冲突排查与已落地修复（共 9 项）

Wave 2 三条分支严格遵守防冲突所有权矩阵，因此 Git 层零文件冲突；但在 11 插件全量合流与活跃后端对照分析中，排查并一次性解决了以下 **9 项跨分支冲突、既有底座缺陷与前向接口缺口**：

1. **默认 11 枚前端插件分层注册与运行时钩子全量同步**（[frontend.ts](../../Script/watch/fe/frontend.ts)、[tower_endings.ts](../../Script/watch/fe/cutscenes/tower_endings.ts)）：
   - 按严格渲染分层顺序注册全部 11 枚插件：`MingArtAuditPlugin` → `GateTransitionPlugin` → `LowpolyWorldPlugin` → `AfterimageArtifactPlugin` → `CarryPosePlugin` → `PrologueIntroPlugin` → `CuffShotsPlugin` → `TowerEndingsPlugin` → `WellMuseumPlugin` → `ReloadWheelPlugin` → `CraftBenchPlugin`；
   - 保证 `LowpolyWorldPlugin` 位于 `TowerEndingsPlugin` 之前（`tower-wait` 渲染低模塔外景，叩门后平滑让位 `F03` 过场）、`AfterimageArtifactPlugin` 位于 `CarryPosePlugin` 之前（轨迹残影不压背负角色）；
   - `syncRuntimeHooks()` 补全 `lowpolyWorld` / `towerEndings` / `afterimageArtifact` / `wellMuseum` 全部 11 枚插件钩子，`TowerEndingsPlugin` 同步补充 `syncRuntimeHook()`；
   - `view.visualMode === "museum"` 时跳过原生 `actors.drawAll`，防止现代展厅暂停垂纱下透出明初序章精灵。
2. **修复 `AudioDirector` 的 Dora Lua 可调用表判定缺陷，恢复全游戏 5 轨 `AudioBus` 与循环音轨真实发声**（[audio.ts](../../Script/watch/fe/audio.ts)）：
   - 实测 Dora SSR 1.10.2.12 Lua 运行时中 `type(AudioBus) == "table"`、`type(AudioSource) == "table"`，原 `typeof === "function"` 恒假，导致 5 条 `AudioBus` 退化为 `nil`（`setWorldPlaySpeed` / 分轨静音未作用于真实声源）且 `playLoop()` 所有循环环境音均 `playedBackend = false`；
   - 引入 `isCallableCtor()` 统一识别函数与带 `__call` 元表的 Dora 构造器，修复 `AudioBus` 建总线（消除总线与声源双重音量乘方）与 `AudioSource` 循环/单次播放，并补齐 `Audio.play(path, true)` 兜底与 `stopLoop` 句柄回收；实测 `gate`/`child`/`tower`/`museum` 全部循环音轨 `playedBackend = true`。
3. **修复空村投瓶三材质音频串音缺陷**（[audio.ts](../../Script/watch/fe/audio.ts)、[village_undertable.ts](../../Script/watch/fe/scenes/village_undertable.ts)）：
   - 原 `audio.ts` 在后端 `bottleLanded` 缺少 `surface` 字段时一律按 `"brick"` 播放 `bottle_brick.wav`，导致砸中软土（`272`）或铁盆（`548`）时同时响起清脆碎砖声与软土/余振声；
   - M2 在 `audio.ts` 缺省按落点世界坐标区分 `iron`（`ox + 548 ± 24`）→ `bottle_iron.wav`、`soft`（`softX ± 34`）→ `bottle_soft.wav`、`brick` → `bottle_brick.wav`；`village_undertable.ts` 对铁盆叠加金属余振 `bottle_iron_ring.wav`，对软土检查 `ctx.audio.hasPlayed` 避免重复播放，彻底根除三材质串音。
4. **落地 `MING-06` 清理：替换周戍翻滚冰青科幻残影为明代扬尘步烟**（[actors.ts](../../Script/watch/fe/renderer/actors.ts)）：
   - 清除 `ActorsRenderer.drawAfterimages` 遗留的 `PALETTE.cyan` 冰青冲刺残影，改为克制的贴地暖灰扬尘步烟，既符合明朝写实基调，又将人物轮廓残影视觉 100% 专属留给 `fe-06`「时间穿梭器」彩蛋。
5. **序章 `P02` 逃柜窗口与双通关井院严格隔离**（[well_museum.ts](../../Script/watch/fe/scenes/well_museum.ts)）：
   - 扩展 `isPrologueIntroBlocking()` 检查 `stage === "p02_escape" || stage === "p02_hidden"`，避免双通关档位在序章小满独自逃柜段提前露出周戍侧灶深井。
6. **补齐博物馆排演全链路意图闭环**（[contract.ts](../../Script/watch/fe/contract.ts)）：
   - `applyRehearsalIntent` 补齐 `enter_hall`（`well_reflect → hall_walk`）与 `begin_return_cabinet`（`lamp_turn → return_cabinet`），使 E01–E02 全 5 步 `museumInteract` 意图在 `intentLog` 均记 `accepted = true`。
7. **前向对齐后端 C 单（`story-c-archive`）水井与独立 `MUSEUM_ROOM` 契约**（[contract.ts](../../Script/watch/fe/contract.ts)、[well_museum.ts](../../Script/watch/fe/scenes/well_museum.ts)、[audio.ts](../../Script/watch/fe/audio.ts)）：
   - `deriveVisualMode` 显式识别 `roomKey === "museum"` 返回 `"museum"`；
   - `readLiveArchive` 自动适配后端 C `p.wellOpen=true` / `phase="prologue-well"`（双通关且未见馆时自动开放 `well_open`）及 `MUSEUM_ROOM` 四步相位映射；
   - `forwardLiveIntent` 在 `museumInteract(well_pickup)` 未被后端直接接受时自动转译调用 `submitFeIntent({ kind: "wellPick" })`；
   - `well_museum.ts` 支持 `p.ox + backendWellX`（兼容 `wellX = 430`）、允许 `prologue-well` 拾取期保持井口渲染、并在 `room.key === "museum"` 同步真实 `p.player.x` 步态与转灯后回柜行走；
   - `audio.ts` 补全 `artifactFound`、`museumStep`（`cabinet`/`hall`/`lamp`/`knock:1`/`knock:2`）与 `museumDone` 音频事件映射。
8. **全仓生成 Lua `require` 路径统一规范化**：
   - 将本次重编的 6 份 Lua 文件 `require("watch.*")` 全部对齐为 `require("Script.watch.*")`，杜绝模块双加载。
9. **既有测试脚本适配默认 11 插件与新增 M2 全链路联合验收**（[verify-m1.lua](../../tools/verify-m1.lua)、[verify-fe04.lua](../../tools/verify-fe04.lua)、[verify-fe05.lua](../../tools/verify-fe05.lua)、[verify-m2.lua](../../tools/verify-m2.lua)）：
   - `verify-m1.lua` 与 `verify-fe05.lua` 解除固定 7 / 8 插件总数硬编码，改为分层相对顺序与幂等覆盖校验；`verify-fe04.lua` 强化软土落点不误播砖响断言；新增 `tools/verify-m2.lua`（14 项跨分支全链路断言）。

---

## 三、全量验证与回归结果

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| Dora SSR 1.10.2.12 TS → Lua 编译 | **PASS** | 全部 7 份改动 `.ts` 零报错编译，全仓 `Script/watch/fe/**/*.lua` 零裸 `require("watch.*")` |
| `python3 tools/check-repo.py` | **PASS** | 42 组源码与 Lua 成对完整，全部 37 份 Markdown 相对链接零断链，0 忽略项跟踪 |
| 后端零侵入红线核查 | **PASS** | 相对 `origin/feature/watch-level-rework` 对 `init`/`play`/`run`/`rooms`/`depth`/`escort`/`input`/`keys`/`app` 改动 **0 处** |
| 字库 cmap 缺字扫描 | **PASS** | 全仓 `Script/watch/fe/**` 正文 686/686 字符命中 `lxgw-neo-zhisong.ttf`（0 缺字）；大字/落款 24/24 字符命中 `longcang-brush.ttf`（0 缺字） |
| 离线音频资产核查 | **PASS** | `assets/audio/` 共 81 份 WAV（`gate` 30 + `combat` 11 + `child` 14 + `tower` 15 + `museum` 11），均已被 `make-windows-pack.sh` 递归打包覆盖 |
| `tools/verify-m2.lua`（新增 M2 联合验收） | **PASS 14 / FAIL 0** | 默认 11 插件优先级、`watch.fe` 11 钩子、AudioBus/AudioSource 循环音真发声、砖/铁/软零串音、F03/M03 与 fe-04 协同、四镜同袖、P02 隔离与 E01–E02→P03 交接、后端 C live 契约与独立 `MUSEUM_ROOM` |
| `tools/verify-m1.lua` | **PASS 16 / FAIL 0** | M1 7 枚插件分层顺序与全链路联调零回归 |
| `tools/verify-fe01.lua` | **PASS 25 / FAIL 0** | 低模内核、风台 24s、G04/G05 与袖口三镜零回归 |
| `tools/verify-fe02.lua` | **PASS 70 / FAIL 0** | 背负、3×3 慢时连线换弹与第三段工台零回归 |
| `tools/verify-fe03.lua` | **PASS 32 / FAIL 0** | 序章 P01–P04 与明朝美术审计零回归 |
| `tools/verify-fe04.lua` | **PASS 18 / FAIL 0** | 小满低模四房、0px 对齐、红布左端、砖/铁/软三材质不串音与溪湾拨枝零回归 |
| `tools/verify-fe05.lua` | **PASS 22 / FAIL 0** | 北塔双结局 14 锚点 0.000px 配对、F03/M03 全链路、防误触与室内重试零回归 |
| `tools/verify-fe06.lua` | **PASS 30 / FAIL 0** | 双通关门控、0px 匹配剪辑、中途续读、二次进井幂等与穿梭器残影零回归 |
| 基础与扩展回归（`d6`/`d7`/`d8`/`d9`/`depth`/`integration`/`trial`） | **PASS（7/7 全绿）** | `d6` 24/0、`d7` 32/0、`d8` 13/0、`d9` 27/0、`depth` 55/0、`integration` 22/0、`trial`（outer 3451 / drygoods 3360）全绿 |

---

## 四、M2 联合实拍视觉证据索引

1. **M2 默认 11 插件四联联合实拍（显式排演标注）**：[m2-joint-showcase.png](../fe-showcase/m2-joint-showcase.png)
   - 上左：`fe-04` 空村桌下低模压迫前景、冷月斜光、拾荒者鞋底与铁盆三环余振；
   - 上右：`fe-05` 女主单人线 `F03` 西窗暖灯、空行留白（零完成章）与碗沿同框，零 HUD 透穿；
   - 下左：`fe-05` 男主同行线 `M03` 同机位写满两行、解下针套、周戍补线青布袖口与小满双手端碗；
   - 下右：`fe-06` 现代抗日主题纪念展厅西窗转灯映出明初井庭与唯一台词「小满，外头天亮了。」。
2. 各分模块专项视觉与录屏证据完整保留于 `docs/fe-showcase/`：
   - `fe-04`：[fe04-village-undertable.png](../fe-showcase/fe04-village-undertable.png)、[fe04-village-readability-and-dual-hits.png](../fe-showcase/fe04-village-readability-and-dual-hits.png)、[fe04-village-bottle-throw.gif](../fe-showcase/fe04-village-bottle-throw.gif)、[fe04-outside-forest-creek.png](../fe-showcase/fe04-outside-forest-creek.png)
   - `fe-05`：[fe05-dual-endings-compare.png](../fe-showcase/fe05-dual-endings-compare.png)、[fe05-beats-and-grayscale.png](../fe-showcase/fe05-beats-and-grayscale.png)
   - `fe-06`：[fe06-gate-vs-well.png](../fe-showcase/fe06-gate-vs-well.png)、[fe06-museum-flow.png](../fe-showcase/fe06-museum-flow.png)、[fe06-afterimage-resume.png](../fe-showcase/fe06-afterimage-resume.png)

---

## 五、下一阶段（`fe-07-qa-audio-pack`）就绪说明

至此 **合流检查点 M2 正式达成**，Wave 1 + Wave 2 全部 11 枚前端插件已全功能贯通并合入 `origin/feature/fe-dual-route`，可直接开启最终串行收口分支 `feature/fe-07-qa-audio-pack`（[07-qa-pack.md](07-qa-pack.md)）：

- 全局 5 轨音频平衡混音与静音/灰度终审；
- 剩余历史遗留视觉项收口（`MING-03`/`04`/`05`）；
- 与后端 `story-d-integration` 最终合流、组装 Windows x64 离线便携包并完成真机冷启动与交付单收尾。
