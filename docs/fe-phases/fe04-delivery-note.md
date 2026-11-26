# Wave 2 · `fe-04-child-lowpoly` 小满单人线《小小梦魇》风低模四房交付记录

> **分支**：`feature/fe-04-child-lowpoly`（基于前端 M1 基线 `origin/feature/fe-dual-route@5a6966e` 独立切出，**不负责合流**，零侵入后端核心文件与前端热点公共文件）
> **上游对照**：[第二波并行施工书](wave2-04-06.md) · [前端双线开发总控](../前端双线开发总控与阶段任务书.md) · [双线前端交付单](../向西守望-双线前端交付单.md) · [游戏分镜稿](../向西守望-游戏分镜稿.md) · [动画插入与演出规划](../向西守望-动画插入与演出规划.md) · [明朝全局美术设定](../守望-明朝全局美术设定.md)
> **实测环境**：Linux x86_64（`ubuntu-dev`，Dora SSR `1.10.2.12`，1280×720 / 1920×1080 离屏渲染实拍）

---

## 一、本分支独占交付范围（零文件冲突）

严格遵循《防冲突文件所有权矩阵》，本分支仅新增以下独占文件，对后端文件（`init`/`play`/`run`/`rooms`/`depth`/`escort`/`input`/`keys`/`app`）及共享热点前端文件（`frontend`/`contract`/`audio`/`camera`/`assets`/`lowpoly`/`stage`/`props`/`actors`/`hud`/`narrative`）改动 **0 处**，与同波 `fe-05`、`fe-06` 零合并冲突：

| 文件 | 职责说明 |
| --- | --- |
| [lowpoly_world.ts](../../Script/watch/fe/scenes/lowpoly_world.ts)（+ `.lua`） | `LowpolyWorldPlugin`（`id = "fe-04-child-lowpoly"`）：严格在 `view.visualMode === "lowpoly"` 且房间为 `outside` / `village` / `forest` / `tower` 时接管非角色渲染；实现城外栈台低模增强（复用 `lowpoly.ts` 的 `buildOutsideJettyLowpoly`）、左端固定旧红布不变式、首次握车柄 0.54s 家人缝布回忆（不中断拉车输入）及北塔低模外景壳体（`drawCutsceneOverlay` 固定返回 `false` 礼让 `fe-05`）；导出 `registerFe04Plugins(fe)` |
| [village_undertable.ts](../../Script/watch/fe/scenes/village_undertable.ts)（+ `.lua`） | 空村桌下专章（分镜 `F01` 下半）：桌下压迫厚木桌沿与遮住半边院门的前景粗木桌腿（`uiDraw` 前景层真压在 2D 角色之前，暂停态自动切换 `worldArt` 高层兜底）、桌下低机位 `anchorLock`、暗处与灰度可读四要素（拾荒者整双鞋底朝向、暗渠入口 `440`、铁盆 `548`、硬砖 `608`、软土 `272`）、以及砸硬砖（脆响+鞋尖微顿再转向）vs 砸铁盆（盆沿高频阻尼颤动+金属三环余振+鞋底随音转向）双反馈 |
| [forest_creek.ts](../../Script/watch/fe/scenes/forest_creek.ts)（+ `.lua`） | 密林与溪湾专章（分镜 `F02`）：多层低模古松与山谷雾幕、林径枯枝踩响与小满微顿侧耳听声反馈（不锁移动）、三处可穿透草丛前后分层与犬耳/小满肩线冷月轮廓分离、树根窄洞与旧渠纯自然形体区分（零路牌/灯带）、溪湾脚边水面碎灯倒影（停步持续流动、暂停冻结）与步行上岸拨开前景垂枝显露真北塔灯火 |
| [assets/audio/child/MANIFEST.md](../../assets/audio/child/MANIFEST.md) + 14 份 `.wav` | 16 kHz / 16-bit PCM 单声道离线分轨音频（车轮木声、落窝、缝布回忆、砖面脆响、铁盆撞击与余振、软土消音、枯枝折裂、犬步与警觉、溪水、三房夜风底噪） |
| [verify-fe04.lua](../../tools/verify-fe04.lua) | 7 组 18 项自动化引擎验收脚本 |

---

## 二、视觉与录屏验收证据

1. **空村桌下 1280×720 实机主图（彩色）**：[fe04-village-undertable.png](../fe-showcase/fe04-village-undertable.png)
   - 实证厚重木桌沿与桌顶粗瓷碗压在画面上部、前景粗木桌腿遮住半边院门、冷月斜光无缝倾泻擦过铁盆沿与硬砖拼缝、小满伏于桌下瞄投弧线精准落向铁盆、阴影里清晰可读拾荒者整双鞋底与暗渠入口。
2. **空村桌下四联体检图（彩色 + Rec.709 灰度 + 硬砖落点 + 铁盆落点）**：[fe04-village-readability-and-dual-hits.png](../fe-showcase/fe04-village-readability-and-dual-hits.png)
   - 上左：彩色实机瞄准态；上右：Rec.709 真灰度校验（暗处鞋底朝向、暗渠石沿、铁盆弧形高光沿、硬砖拼缝亮边、软土暗哑散点五者清晰区分）；下左：砸硬砖（`608`）干脆单环与鞋尖微顿转向；下右：砸铁盆（`548`）盆沿颤动高光与扩散余振。
3. **空村桌下双落点投瓶完整实机录屏（65 帧，640×360）**：[fe04-village-bottle-throw.gif](../fe-showcase/fe04-village-bottle-throw.gif)
   - 完整录制真实玩家操作轨迹：走近瓶架（`112`）按 `E` 拾瓶 → 蹲伏钻进桌下（`340`） → 瞄投硬砖（`608`）引开拾荒者 → 再次瞄投铁盆（`548`）触发盆沿颤动与鞋底随音转向 → 蹲伏自由钻出桌下越过暗渠通行线（`440`）。
4. **城外缝布回忆 + 密林草后剪影 + 溪湾碎灯倒影与拨枝见真灯四联图**：[fe04-outside-forest-creek.png](../fe-showcase/fe04-outside-forest-creek.png)
   - 上左：`outside` 低模栈台、明代砖墙灰缝、无垂布低拱、左端固定红布与首次握柄 0.54s 缝布回忆叠画（拉车持续不断档）；上右：`forest` 草后犬耳/小满肩线冷月轮廓分离与枯枝听声弧；下左：`forest` 初入溪湾（`x=1295`），前景垂枝遮挡真塔、脚边水面先显揉碎塔灯倒影；下右：`forest` 步上溪岸（`x=1438`），前景垂枝自然让开显露远山真北塔灯火。

---

## 三、活跃远端核查与前后端接口对齐结论

| 活跃远端分支 | 最新提交 | 核查与适配结论 |
| --- | --- | --- |
| `origin/feature/fe-dual-route` | `5a6966e` | 本分支固定切出基线（M1 合流完成） |
| `origin/feature/story-b2-escort` | `7b941cc` | 已核查至最新提交：`OUTSIDE_ROOM` / `VILLAGE_ROOM` / `FOREST_ROOM` / `TOWER_ROOM` 坐标及 `stepVillage`/`stepDog`/`stepCart` 零变动 |

### 待后端可选增补字段（已做零侵入前向兼容）
- 当前 `VILLAGE_ROOM` 尚未定义独立铁盆坐标，`bottleLanded` 事件未带 `surface` 字段。本分支已将铁盆锚定在 **`basinX = 548`**（`532..564`，与 `brickX = 608 ± 34` 无重叠、全在拾荒者听觉半径 `480` 内），并按「优先读 `e.data.surface` → 缺省按实际落点 `x` 分类」双层适配；
- 当后端尚未发 `surface="iron"` 时，命中 `basinX = 548` 会自动叠加 `assets/audio/child/bottle_iron_ring.wav` 金属余振；未来后端在 `bottleLanded` 补上 `surface: "brick" | "iron" | "soft"` 后将自动直通 `audio.ts` 的 `bottle_iron.wav` / `bottle_soft.wav` 且零重播。

---

## 四、M2 合流接线说明（仅 2 行，供合流者操作）

本分支未修改 `Script/watch/fe/frontend.ts`。在合流检查点 **M2** 合并 `fe-04` + `fe-05` + `fe-06` 后，于 `WatchFrontend` 构造函数内注册插件（置于 `GateTransitionPlugin` 之后、`fe-05` `TowerEndingsPlugin` 之前）：

```ts
import { LowpolyWorldPlugin } from "Script/watch/fe/scenes/lowpoly_world";

// WatchFrontend constructor（M2 统一接线）
this.registerPlugin(new LowpolyWorldPlugin());
```

同时可在 `WatchFrontend.syncRuntimeHooks()` 补挂一行 `watchFe["lowpolyWorld"] = this.getPlugin("fe-04-child-lowpoly");`（本插件在 `onBindPlay`/`update` 中也已自同步该钩子）。

---

## 五、全量验证结果

| 验证项 | 结果 | 详情 |
| --- | --- | --- |
| Dora SSR 1.10.2.12 TS → Lua 构建 | **PASS** | `village_undertable.ts` / `forest_creek.ts` / `lowpoly_world.ts` 零报错编译，Lua `require` 全部对齐 `Script.watch.*` |
| `python3 tools/check-repo.py` | **PASS** | 39 组源码与 Lua 成对完整，全部 Markdown 相对链接零断链 |
| 后端与热点文件零侵入检查 | **PASS** | 相对 `origin/feature/fe-dual-route` 仅含 `fe-04` 独占新增文件，0 处既有文件修改 |
| 字库 cmap 缺字扫描 | **PASS** | `fe-04` 三个 `.ts` 模块 UI 字符串在 `lxgw-neo-zhisong.ttf` 0 缺字 |
| `tools/verify-fe04.lua` | **PASS 18 / FAIL 0** | 14 份 WAV、`visualMode` 隔离、四房跨分辨率 `wz=0` 零误差（`0.000000 px`）、红布左端、0.54s 回忆不打断拉车、硬砖/铁盆/软土三反馈、自由钻出、枯枝听声、溪湾连续涟漪与拨枝见真灯、北塔壳体与切房清零 |
| 全套回归（`verify-m1` / `fe01` / `fe02` / `fe03` / `d6` / `integration` / `trial`） | **PASS（7/7 全绿）** | `m1` 16/0、`fe01` 25/0、`fe02` 70/0、`fe03` 32/0、`d6` 24/0、`integration` 22/0、`trial`（outer 3451 / drygoods 3360）全绿 |
