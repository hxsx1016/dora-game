# FE-05 阶段交付与验证记录（`feature/fe-05-dual-endings`）

- **任务**：Wave 2 并行模块 FE-05（北塔双结局同机位配对演出 `F03` / `M03`）
- **分支**：`feature/fe-05-dual-endings`（切出基线 `origin/feature/fe-dual-route@5a6966e`，`--no-track`，**不负责合入 M2**）
- **远端**：`origin` = `hxsx1016/dora-game`
- **实测环境**：Linux x86_64（`ubuntu-dev`，Dora SSR 1.10.2.12，1280×720 渲染目标实拍；Windows 离线包冷启动待 `fe-07` 真机复测）
- **零侵入红线核查**：
  - 相对 `origin/feature/watch-level-rework` 对后端核心文件（`play.ts`、`run.ts`、`rooms.ts`、`depth.ts`、`escort.ts`、`input.ts`、`keys.ts`、`app.ts`、`init.ts` 及对应 `.lua`）**改动 0 处**；
  - 相对 `origin/feature/fe-dual-route`（M1）对共享前端热点文件（`frontend.ts`、`narrative.ts`、`audio.ts`、`contract.ts`、`plugins.ts`、`stage.ts`、`actors.ts`、`hud.ts`、`menus.ts`、`theme.ts`、`lowpoly.ts`）**改动 0 处**，与并行分支 `fe-04` / `fe-06` 严格零文件冲突。

---

## 一、交付物清单

1. **北塔双结局同机位配对演出插件**：[tower_endings.ts](../../Script/watch/fe/cutscenes/tower_endings.ts) / [tower_endings.lua](../../Script/watch/fe/cutscenes/tower_endings.lua)
   - **同机位像素级配对真源（`TOWER_SHOT_LAYOUT`）**：`F03` 与 `M03` 共享门扇、门槛、叩门手位、提灯、西窗、木案、宋明冷素宣纸收籍簿、第 1/2 行基线、悬停笔尖 `brushHoverTipPos` 与案沿热瓷碗 `bowlRimPos` 全部 14 项锚点，实测全 7 个关键拍点偏差恒为 `0.000000 px`。
   - **共用前段与 8.0 秒三幕编排（精确对齐 `tower-knock` / `tower-given` / `tower-end`）**：
     - 门外轻敲两下精确对齐后端第 0 拍 / 第 12 拍 `knock` 事件（`count=1/2`）→ 静默一息后门内回敲两声 → 守卒推门提灯先照见手与腕上针套 → 摊开宋明冷素宣纸收籍簿写下第一行 `肆拾壹 · 小满` → 3.40s–4.20s 毛笔悬停于第二行同一坐标支点。
   - **`F03` 女主单人线（低模材质 + 西窗暖灯 + 空行留白）**：
     - 复用 `lowpoly.ts` 的 `MING_MATERIALS` 与 `TOWER_WEST_LAMP_LIGHT` 切面着色；笔尖悬停后悄然收起，小满轻问「朝西那盏灯，能留着吗？」→ 守卒端灯搁上西窗台，全室由拂晓冷石青转为西窗倾洒的暖黄侧光；
     - `肆拾贰` 保持干净留白，**不盖完成章、不加任务完成标识**，以「空着的第二行 + 案沿碗沿」同框收尾。
   - **`M03` 男主同行线（序章像素风 + 周戍报姓名 + 双手端碗）**：
     - 延续序章像素风砖灰土褐与暖室气氛，周戍（复用 `cuff_shots.CUFF_PALETTE` 单一真源青布补线袖口）牵小满跨过门槛；从同一悬停笔尖切入，周戍亲口报出「周戍。」→ 守卒写满第二行 `肆拾贰 · 周戍 · 兄妹同行 · 已收` → 小满解下腕上针套轻放木案，双手端起热瓷碗；
     - 以「写满两行的簿页 + 桌上针套 + 小满双手端碗沿」同框落团圆结局。
   - **边界保护与零冲突挂载**：
     - 仅挂载 `update` 与 `drawCutsceneOverlay`，在 `tower-wait` 步行阶段完全不抢占 `fe-04` / 基础舞台层；过场接管时由 M1 `frontend.ts` 自动压隐常规 HUD 文本与战斗准星；
     - 全部动画与灯位插值吃 `worldDt`（暂停完全冻结、恢复同拍续播不重播）；
     - 结局台词与 8.0s 定格读完前消化旧按键并拦截误触；室内重试不重关塔门、不重播敲门/开门音，登记簿采用固定双槽结构永不重复追加行。
2. **分轨音频资产与清册**：[MANIFEST.md](../../assets/audio/tower/MANIFEST.md) 及 `assets/audio/tower/*.wav`（15 份离线 16 kHz / 16-bit PCM 单声道 WAV，总计 511.6 KB，含门外双敲、门内双回敲、推门、翻簿、双落笔、挪灯、放针套、端碗、冷暖环境循环及 2 份可同名替换的占位人声）。
3. **专项自动化验收脚本**：[verify-fe05.lua](../../tools/verify-fe05.lua)（22 项断言覆盖挂载、15 份 WAV 存在与真播放、Live 第 0/12 拍对齐、14 锚点 0px 对齐、`F03`/`M03` 全链路、防误触与暂停双冻、室内重试不变式与零残留）。
4. **同机位并排对比与灰度可读性实拍图（显式排演态标注）**：
   - [fe05-dual-endings-compare.png](../fe-showcase/fe05-dual-endings-compare.png)（`3.80s` 同坐标悬停笔尖支点 + `8.20s` 西窗空行 vs 满行双手端碗终帧并排对比）
   - [fe05-beats-and-grayscale.png](../fe-showcase/fe05-beats-and-grayscale.png)（`0.95s` 推门提灯同机位 + `5.15s–5.65s` 分歧瞬间 + `8.20s` 静音/灰度可读性复审）

---

## 二、验证与回归结果

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| `Dora cli build -p . -f Script/watch/fe/cutscenes/tower_endings.ts --lang ts` | **PASS** | 零编译错误，已将产物 `.lua` 对齐为 `require("Script.watch.*")` |
| `python3 tools/check-repo.py` | **PASS** | 37 组源码与 Lua 成对完整，全部 Markdown 相对链接零断链 |
| 字库 cmap 缺字扫描 | **PASS（0 缺字）** | 正文全部 139 个非 ASCII UI 字符在 `lxgw-neo-zhisong.ttf` 命中 139/139；片尾落款「向西守望」在 `longcang-brush.ttf` 命中 4/4 |
| `tools/verify-fe05.lua` | **PASS 22 / FAIL 0** | 覆盖零冲突挂载、15/15 WAV、Live 0/12 拍对齐、14 锚点 `0.000000 px` 误差、F03/M03 全态、防误触/暂停双冻、室内重试不变式 |
| `tools/verify-m1.lua` | **PASS 16 / FAIL 0** | M1 全部 7 枚插件联调零回归 |
| `tools/verify-d6.lua` | **PASS 24 / FAIL 0** | 风台 1439/1440、掩体、2700 拍与投瓶落点零回归 |
| `tools/verify-integration.lua` | **PASS 22 / FAIL 0** | 菜单键鼠、高清映射、资源槽与 8 房渲染暂停零回归 |
| `tools/verify-trial.lua` | **PASS** | 五段护送试炼零回归 |

---

## 三、给 M2 合流方的极简接线指引（本分支不执行合并）

合流方在 `feature/fe-dual-route` 合并 `feature/fe-05-dual-endings` 后，仅需在 `Script/watch/fe/frontend.ts` 追加导入与 1 行插件注册（建议置于 `CuffShotsPlugin` 之后），并在 `syncRuntimeHooks()` 可选补挂 `watchFe["towerEndings"]`：

```ts
import { TowerEndingsPlugin } from "Script/watch/fe/cutscenes/tower_endings";

// WatchFrontend constructor 中追加：
this.registerPlugin(new TowerEndingsPlugin());

// syncRuntimeHooks() 中可选追加：
watchFe["towerEndings"] = this.getPlugin("fe-05-tower-endings");
```

### 给后端 B2（`origin/feature/story-b2-escort`）的联调对齐备忘

1. **登记簿行序对齐**：`story-b2-escort` 的 `stepTower` 临时 `flashSet` 调试文案将男主线写成了“第一行 周戍 / 第二行 小满”；本插件按正稿《游戏分镜稿》《动画插入与演出规划》及 `wave2-04-06.md` 实现为**两线第一行均先写「小满」，同一悬停笔尖切入第二行（F03 留白 / M03 周戍亲口报姓名写满）**，且过场接管期间已压隐旧 `flash` 字幕，建议后端同步微调 `flashSet` 文案。
2. **结局定格读图窗对齐**：当前 `play.ts` 在 `tower-knock`(36 拍) + `tower-given`(180 拍) 共 3.6s 后即切入 `tower-end` 并响应 `E/R` 重开；本插件在前端已实现无缝跨阶段 8 秒连续编排与旧按键消化，建议后端后续在 `tower-end` 增设约 8 秒只读锁窗（`readLockTicks`），防止玩家在读完定格前轻点 `E` 过早跳回序章。
