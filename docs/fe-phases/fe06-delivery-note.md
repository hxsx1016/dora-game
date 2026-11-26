# Wave 2 · FE-06 交付与验收记录（`feature/fe-06-well-museum`）

> **任务范围**：双通关后院深井与现代抗日主题博物馆（`E01–E02`）+ 「时间穿梭器」移动轨迹残影彩蛋
> **切出基线**：`origin/feature/fe-dual-route@5a6966e`（合流检查点 M1）
> **上游锁定基线**：`origin/feature/watch-level-rework@648ff43`
> **分支策略**：独立并行分支 `feature/fe-06-well-museum`（`--no-track`），仅提交与推送本分支，不执行合回 `feature/fe-dual-route`
> **实测环境**：Linux x86_64（`ubuntu-dev`，Dora SSR 1.10.2.12，1280×720 虚拟帧缓冲；Windows x64 离线包真机冷启动待 M2 / `fe-07` 真机复测）

---

## 一、活跃远端分支核查与后端 C 单对齐结论

| 远端分支 | 最新提交 | 核查与对齐结论 |
| --- | --- | --- |
| `origin/feature/fe-dual-route` | `5a6966e` | M1 合流基线。已提供 `contract.ts` 7 态 `MuseumPhase`、`AudioDirector` 五轨接口与 `cuff_shots.ts` 的 `CUFF_PALETTE` / `drawPatchedCuff()` 单一真源，可直接复用。 |
| `origin/feature/story-b2-escort` | `80aea38` | B2 后端已落地 `RunState.archive` / `Play.archive`（字段与前端契约一致：`childCleared` / `soldierCleared` / `artifactOwned` / `museumPhase` / `museumSeen`）。**需后端 C 单对齐点**：B2 `Script/watch/play.ts:2179` 在单线结局时临时写入了 `artifactOwned = true`；前端 `fe-06` 已严格按 `childCleared && soldierCleared` 双真作水井门控，防止单通误开放。 |

---

## 二、本次交付物清单（严格限定 `fe-06` 独占文件，0 改动后端与前端热点文件）

1. **双通关水井与现代抗日主题博物馆插件**：[well_museum.ts](../../Script/watch/fe/scenes/well_museum.ts) / [well_museum.lua](../../Script/watch/fe/scenes/well_museum.lua)
   - **严格双通关门控**：仅在非试炼态、`prologue` 房间 `prologue-wait`（尚未靠柜触发 `P03`）窗口、`childCleared && soldierCleared` 双真且 `museumPhase !== "locked"` 时开放左侧侧灶井院入口（世界 `x ≈ 34`，与右侧倒柜寻人路线零冲突）；新档、单通关（含单通误带 `artifactOwned`）、试炼态、靠柜后均严格封闭；章节直达/排演结局/退出排演不污染正式档案。
   - **默认零引导**：井院仅靠距离衰减的 `water` 轨滴水声与暗处冷白水光/细涟漪引路，展厅西窗灯靠空间留白与旋轴微光引路；仅当玩家在暂停菜单开启「按键辅助」时显示轻量 `[E]` 提示。
   - **`E01` 井底反光匹配剪辑（`well_reflect`）**：深黑古井石壁映出明初不该亮的冷白灯，与黄铜指南针玻璃精确叠合于屏幕锚点 `(0.50, 0.54)`；拾取「时间穿梭器」后锁死同一反光坐标（像素偏移 `0.00 px`）无缝溶切至现代展柜玻璃同一点光。
   - **`E02` 现代抗日主题博物馆自由步行、西窗转灯与补线袖口回柜（`hall_walk` → `lamp_turn` → `return_cabinet` → `done`）**：
     - 虚构纪念展厅（庄重、克制、安静），入厅缓现现代时间与抗日纪念主题字幕且不锁步；
     - 恢复周戍自由步行（`A/D` 或方向键），行至玻璃展柜前自动收起随身器物，远方传来一次孩童轻脚步回响；
     - 末厅留足安静空间，亲手转动西窗灯 → 西窗玻璃浮现明初宁村所井庭 → 仅留定稿台词「小满，外头天亮了。」；
     - 现代展厅第一声轻叩 → 隔 `0.42s` 第二声实木叩响落回明初厨柜板 → 直接调用 `cuff_shots.ts` 的 `drawPatchedCuff()` 与 `CUFF_PALETTE` 接回同一截 6 针斜补线青布袖口，交还寻柜任务；
     - 离馆后二次走回井口仅呈平静暗夜水纹，神器数量恒为 `1`，绝不重复发奖或二次传馆；
     - 支持 `onBindPlay` 按 `museumPhase` 与续读位置恢复（含可选后端 `museumWalkX` / `museumHolstered` / `museumChildEchoPlayed`），暂停绝对冻结。
2. **「时间穿梭器」移动轨迹残影彩蛋插件**：[afterimage_artifact.ts](../../Script/watch/fe/renderer/afterimage_artifact.ts) / [afterimage_artifact.lua](../../Script/watch/fe/renderer/afterimage_artifact.lua)
   - 仅当 `artifactOwned === true`、重玩男主线像素态且装备穿梭器（兼容 `time_shuttler` / `time_shuttle` / `shuttler` / `time_artifact` / `artifact` / `时间穿梭器` 及后端 `artifactEquipped`）时激活；
   - 环形轨迹缓冲（上限 7 帧），以克制冷白明初守卒笠盔短袄剪影 + 微金斜襟余韵呈现，峰值透明度 `<= 0.34`，距本体 `< 16px` 自动跳过，不遮挡判定与视线；
   - 全程吃 `worldDt`（换弹 `0.25×` 慢时自动同步放慢，暂停绝对冻结，切房/卸下/女主线立即清零）。
3. **分轨离线音频与清册**：[MANIFEST.md](../../assets/audio/museum/MANIFEST.md) 及 `assets/audio/museum/*.wav`（11 份 22050Hz 单声道 16-bit PCM WAV，总计 590.9 KB；已由 M1 的 `make-windows-pack.sh` 自动覆盖打包）。
4. **专项验收脚本与视觉证据（排演态显式标注）**：
   - [verify-fe06.lua](../../tools/verify-fe06.lua)（30 项断言全覆盖门控、双顺序、E01 匹配剪辑、E02 全流程、二次进井幂等、中途续读、暂停冻结、穿梭器残影与 11 份 WAV）
   - 三态门控对照（单通关未开放 vs 双通关井口水光）：[fe06-gate-vs-well.png](../fe-showcase/fe06-gate-vs-well.png)
   - `E01–E02` 全流程四镜（匹配剪辑 / 展厅收械与童步回响 / 西窗转灯与定稿台词 / 两声轻敲回补线袖口）：[fe06-museum-flow.png](../fe-showcase/fe06-museum-flow.png)
   - 中途退出续读恢复 + 男主线「时间穿梭器」冷白/微金残影：[fe06-afterimage-resume.png](../fe-showcase/fe06-afterimage-resume.png)

---

## 三、全量验证与回归结果

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| `Dora cli build --lang ts` | **PASS** | `well_museum.ts` 与 `afterimage_artifact.ts` 零报错编译，已统一 `require("Script.watch.*")` 路径 |
| `python3 tools/check-repo.py` | **PASS** | 38 组源码与 Lua 成对完整，全部 Markdown 相对链接零断链 |
| 后端零侵入 & 并行零冲突核查 | **PASS** | 相对 `origin/feature/fe-dual-route` 仅含 `fe-06` 独占文件，0 改动后端核心与前端热点文件 |
| 字体 cmap 缺字扫描 | **PASS** | `well_museum.ts`（79 字符）与 `afterimage_artifact.ts`（5 字符）在 `lxgw-neo-zhisong.ttf` 命中率 100%（0 缺字） |
| `tools/verify-fe06.lua` | **PASS 30 / FAIL 0** | 门控 7 项、双顺序与 E01–E02 闭环 12 项、中途续读 2 项、二次进井幂等 2 项、残影 5 项、插件与 11 WAV 2 项全部通过 |
| `tools/verify-m1.lua` | **PASS 16 / FAIL 0** | M1 7 插件联合验收零回归 |
| `tools/verify-d6.lua` | **PASS 24 / FAIL 0** | 城门风台与投瓶核心逻辑零回归 |
| `tools/verify-integration.lua` | **PASS 22 / FAIL 0** | 菜单键鼠、高清映射、全资源槽与 8 房暂停渲染零回归 |
| `tools/verify-trial.lua` | **PASS** | `outer` 3451 拍 / `drygoods` 3360 拍五段试炼零回归 |

---

## 四、给 M2 合流方与后端 C 单的对接清单（本分支不执行合并）

### 1. M2 合流极简接线（`Script/watch/fe/frontend.ts`）
合并 `feature/fe-06-well-museum` 后，在 `Script/watch/fe/frontend.ts` 顶部导入并在构造函数末尾追加 2 行注册（同时在 `syncRuntimeHooks()` 补挂 2 个调试钩子）：

```ts
import { AfterimageArtifactPlugin } from "Script/watch/fe/renderer/afterimage_artifact";
import { WellMuseumPlugin } from "Script/watch/fe/scenes/well_museum";

// WatchFrontend constructor 中追加（置于 CuffShotsPlugin 之后）：
this.registerPlugin(new AfterimageArtifactPlugin());
this.registerPlugin(new WellMuseumPlugin(this.contract));

// syncRuntimeHooks() 中追加：
watchFe["afterimageArtifact"] = this.getPlugin("fe-06-afterimage-artifact");
watchFe["wellMuseum"] = this.getPlugin("fe-06-well-museum");
```

### 2. M2 / `fe-07` 建议顺手修复的既有共享底座小问题（非阻塞）
- **`Script/watch/fe/audio.ts` 的 `playLoop()`**：Dora Lua 运行时中 `AudioSource` 为可调用表/userdata，`typeof AudioSource === "function"` 在 Lua 中恒为 `false`。`playOnce()` 已具备 `Audio.play` 兜底所以实际后端发声正常，但 `playLoop()` 缺少该分支导致循环音轨（含 `gate` 风水轨与 `museum` 滴水/展厅底噪）目前仅记逻辑日志（`playedBackend=false`）。建议在 M2 或 `fe-07` 统一修正 `audio.ts` 的 `AudioSource` 判定或补充 `Audio.play(path, true)` 兜底。

### 3. 给后端 C 单的接口契约摘要
- **只读档案快照**：`archive: { childCleared, soldierCleared, artifactOwned, museumPhase, museumSeen }`（建议 C 单保证单线结局不提前写 `artifactOwned=true`，仅在双通关进井拾取穿梭器后置真）。
- **可选续读/装备字段**（已有自动兼容读取）：`museumWalkX?: number`、`museumHolstered?: boolean`、`museumChildEchoPlayed?: boolean`、`wellX?: number`、`artifactEquipped?: boolean`。
- **前端提交意图**：`submitFeIntent({ kind: "museumInteract", target })`，其中 `target` 依次为 `"well_pickup"`（`well_open → well_reflect`）、`"enter_hall"`（`well_reflect → hall_walk`）、`"lamp_turn"`（`hall_walk → lamp_turn`）、`"begin_return_cabinet"`（`lamp_turn → return_cabinet`）、`"return_cabinet"`（`return_cabinet → done`，置 `museumSeen = true`）。
