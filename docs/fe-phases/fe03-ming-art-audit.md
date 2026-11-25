# Wave 1 · `fe-03-prologue-ming-art` 明朝全局美术红线体检与序章交付记录

> **分支**：`feature/fe-03-prologue-ming-art`（基于 `origin/feature/fe-dual-route@cf260d9`，M0 后独立切出，零侵入后端文件，零改动热点公共渲染文件）
> **上游对照**：[明朝全局美术设定](../守望-明朝全局美术设定.md) · [游戏分镜稿](../向西守望-游戏分镜稿.md) · [动画插入与演出规划](../向西守望-动画插入与演出规划.md) · [Wave 1 施工书](wave1-01-03.md)

---

## 一、本分支独占交付模块

| 文件 | 职责 | 冲突与兼容策略 |
| --- | --- | --- |
| [prologue_intro.ts](../../Script/watch/fe/cutscenes/prologue_intro.ts)（+ `.lua`） | `PrologueIntroPlugin`：共同序章 `P01`（4s 睁眼叫醒）、`P02`（2s 墙影滚碗 + 限时逃柜红晕/加速心跳 + 入柜收净与半拍渐远脚步 + 重试从门口起步零残留）、`P04`（1s 井庭墙根枪火双影/侧肩挡光/窗板下沿与石槽磨痕，不锁移动与镜头） | 独立 `FeRenderPlugin`，不改 `frontend.ts`；支持正式态自动监听与显式排演态隔离 |
| [ming_audit.ts](../../Script/watch/fe/renderer/ming_audit.ts)（+ `.lua`） | `MingArtAuditPlugin`：拦截非八房退化探照灯/工业废土、木屑/砖灰挡下区分、鸟铳灰白硝烟与焦痕、村口硬砖/软土灰度纹样、森林草后犬耳与小满肩线轮廓分离、红布左端不变式与 `runAudit()` | 独立 `FeRenderPlugin`，保留 [sprites.clip](../../assets/art/sprites.clip) 全部 58 帧键与 [ui_ink.clip](../../assets/art/ui_ink.clip) 全部 15 帧键 |
| [verify-fe03.lua](../../tools/verify-fe03.lua) | 自动化引擎回归脚本：覆盖 `P01`/`P02`/`P04` 状态机、暂停冻结、重试清零、音频去重、明朝底图拦截、木/砖材质反馈、58+15 帧键与红布左端断言 | 独立测试脚本，不改既有 `verify-d6` / `verify-integration` / `verify-trial` |

---

## 二、全仓明朝美术红线体检清单

### 1. 八房背景与非八房战役底图核查

| 房间 / 段落 | 贴图文件 | 明朝考据结论 | 处置与说明 |
| --- | --- | --- | --- |
| 序章 `prologue` | [prologue.png](../../assets/art/prologue.png) | **通过** · 残破木构铺面/砖墙/冷月/粗布帘 | 符合明初宁村所残破临街木铺口径，无现代元素 |
| 街道 `street` | [street.png](../../assets/art/street.png) | **通过** · 灰瓦木铺、布招幌、远处砖城门楼 | 无电灯/霓虹/清代招牌 |
| 检查站 `checkpoint` | [checkpoint.png](../../assets/art/checkpoint.png) | **通过** · 木栅、角楼、提灯、砖墙 | 非公路岗亭，合明代城门前盘查处 |
| 城门 `gate` | [gate.png](../../assets/art/gate.png) | **通过** · 砖券门洞、城垛、火盆与破口月光 | 无探照灯与电动闸灯 |
| 城外 `outside` | [outside.png](../../assets/art/outside.png) | **通过** · 城墙砖拱、外壕峭壁、远山月牙 | 低拱净空清晰，无遮挡垂布 |
| 村口 `village` | [village.png](../../assets/art/village.png) | **通过** · 白灰青石民居、木门、草帘窗 | `ming_audit.ts` 补强地面硬砖拼缝亮边 vs 软土散点浅足印 |
| 森林 `forest` | [forest.png](../../assets/art/forest.png) | **通过** · 山谷松林与青雾 | `ming_audit.ts` 补强草丛后犬耳与小满肩线冷月轮廓分离 |
| 北塔 `tower` | [tower.png](../../assets/art/tower.png) | **通过** · 砖石烽望钟塔、木门与暖提灯 | 非现代基地、非宫殿 |
| 非八房段落（`s1`/`s2`/`s3`/`c1`/`c2`/`gatepath`/`escort1`） | 动态映射 | **已拦截修复** · 原 `stage.ts` 无 `bgFar_<key>` 时会退化画出探照灯、高压线、屋顶天线与破损电灯 | 已由 `MingArtAuditPlugin.drawBackdrop` 拦截并映射至同源明朝像素底图（`bgFar_street` / `bgFar_checkpoint` / `bgFar_outside`） |

### 2. 角色、敌人与关键道具核查（[sprites.png](../../assets/art/sprites.png) + [sprites.clip](../../assets/art/sprites.clip)）

| 对象 | 现有帧键与规格 | 明朝红线核查结论 |
| --- | --- | --- |
| 周戍 | `soldier_*` 共 13 帧，站高 66 px | **通过** · 素铁盔 + 短朱缨、暗靛交领短袄、束带、护臂裹布、木托暗铁明式鸟铳；无现代步枪/弹匣/战术背心 |
| 小满 | `child_*` 共 12 帧，站高 48 px | **通过** · 双髻、暗红交领短袄、布裤草鞋、斜挎布袋与铜针套；无发光任务饰品 |
| 敌方火器手 | `enemy_idle/aim/down/hit` 共 4 帧，站高 63 px | **通过** · 斗笠、粗布斜襟长摆、木托鸟铳；无现代迷彩/弹壳/战术背心 |
| 拾荒者 | `scavenger_idle/walk/turn/run` 共 4 帧，站高 60 px | **通过** · 补丁麻袍、包头布、长布袋平民造型，无匪帮制服与武器 |
| 林犬 | `dog_idle/alert/run/sniff` 共 4 帧 | **通过** · 瘦削土褐猎犬，无战术挽具；草后警觉竖耳由 `ming_audit.ts` 强化轮廓可读 |
| 红布板车 | `cart`（80×27） | **通过** · 木辐双轮，旧红布固定在车身左端（`CHECKPOINT_ROOM` 与 `OUTSIDE_ROOM` 均 `clothSide = -1`，绘制不随小满转向镜像） |
| 标题封面 | [title.png](../../assets/art/title.png)（960×540） | **通过** · 明代守卒与双髻女童背影、左端红布木车、北山石塔暖门灯，左侧大面积留暗承接书名 |

### 3. 三张关键成品尺度图（关 HUD + 静音 + 灰度可读核对）

1. **街道举器与柜边**（参考 [05-street-combat.png](../fe-showcase/05-street-combat.png)）：
   - 轮廓分离：周戍（铁盔、青灰短袄）与敌兵（宽斗笠、棕褐长摆）、小满（矮身双髻）在灰度下凭剪影与高度即可一眼分辨；
   - 材质打击反馈：`ming_audit.ts` 按掩体类型区分木柜飞溅暗木屑 vs 砖沿扬起冷灰砖粉，鸟铳开火配短促灰白火药烟，不出现抛壳与激光十字；受击仍由 `soldier_hit` 缩肩表现。
2. **城门内外同一辆左端系红布板车**（参考 [06-checkpoint-dash.png](../fe-showcase/06-checkpoint-dash.png) 与 [08-outside-profile.png](../fe-showcase/08-outside-profile.png)）：
   - `CHECKPOINT_ROOM`（`handleOffset = -40` 左柄推车）与 `OUTSIDE_ROOM`（`handleOffset = +40` 右柄拉车）均保持 `clothSide = -1`；
   - `MingArtAuditPlugin` 实时断言红布锚在车身左端，且在像素线叠加左端暗朱布条风动尾缘，小满抓右柄来回转向时红布绝不翻面。
3. **塔门交针与空行**（参考 [11-tower-epilogue.png](../fe-showcase/11-tower-epilogue.png)）：
   - 宋明冷素宣纸 + 朱丝栏 + 焦墨「肆拾壹 小满」与留白「肆拾贰」第二行在关 HUD + 静音 + 灰度下明暗层次清晰；空行不盖完成章、不加任务光柱。

### 4. 与 `fe-01` 共享的补线袖口视觉口径

为保证 `P04` 挡光动作与 `fe-01` 的 `P03`/`P05`/`G05`（及 `fe-06` 的 `E02`）使用同一件青布补线袖口，[prologue_intro.ts](../../Script/watch/fe/cutscenes/prologue_intro.ts) 已导出 `CUFF_SHARED_SPEC`：

- 暗靛青布袖底：`rgba(43, 62, 76, 255)`
- 旧布袖缘磨白：`rgba(74, 98, 112, 255)`
- 浅麻补线针脚：`rgba(214, 203, 184, 240)`（5 针斜缝）
- 护臂旧布带：`rgba(110, 99, 84, 255)`

---

## 三、既有热点渲染文件赛博/全息遗留项（供 M1 / `fe-07` 统一清理）

本分支严格遵循 Wave 1 防冲突矩阵（方案 A），**未修改**以下公共热点文件；已将全部 6 处既有旧代码遗留沉淀在 `MING_LEGACY_FINDINGS` 与下表，便于在 M1 合流后或 `fe-07` 收口阶段一次性清理：

| 编号 | 文件与行号 | 现状问题 | `fe-03` 缓解措施 | 建议清理节点 |
| --- | --- | --- | --- | --- |
| `MING-01` | [theme.ts](../../Script/watch/fe/theme.ts) `L160,189,218,247`；[stage.ts](../../Script/watch/fe/renderer/stage.ts) `L166-274,329-508` | `showSearchlights: true`；无 `bgFar_*` 时退化画出扫射探照灯、屋顶天线、工业钢桁架、垂落电缆与破损电灯；`drawMenuBackdrop` 退化画赛博目镜剪影 | `MingArtAuditPlugin.drawBackdrop` 已在运行期拦截全部非八房房间，0 触发探照灯 | M1 / `fe-07` 彻底删去探照灯与工业退化代码 |
| `MING-02` | [stage.ts](../../Script/watch/fe/renderer/stage.ts) `L844-857` | 贴靠掩体时在 `fgGlow` 绘制冰青全息护盾竖条与强蓝光晕（见 [07-gate-siege.png](../fe-showcase/07-gate-siege.png)） | 保持零改动；待改为极克制的木沿/砖沿亮边 | M1 / `fe-07` |
| `MING-03` | [stage.ts](../../Script/watch/fe/renderer/stage.ts) `L860-891` | `drawWinch` 在 `prop_winch` 底层仍绘倒角钢箱与闪烁冰青/琥珀电子状态灯 | 保持零改动；待改为木铁绞盘与绳链张力表现 | M1 / `fe-07` |
| `MING-04` | [stage.ts](../../Script/watch/fe/renderer/stage.ts) `L1047-1059` | 城外矮拱绘制纯黑亮银方框 + 冰蓝竖光渐变（见 [08-outside-profile.png](../fe-showcase/08-outside-profile.png)） | `fe-04` 低模城外将接管城外舞台；像素线待改为石券砖拱 | `fe-04` / `fe-07` |
| `MING-05` | [props.ts](../../Script/watch/fe/renderer/props.ts) `L78-83,100-153,242-245,307` | 危险区红激光扫描线、全息检查点菱柱、车柄发光黄球、钢杆灯柱；村口瓶架纵拉 `cover_wood` | `ming_audit.ts` 已补强砖缝/软土灰度纹样；全息标与黄球待统一替换 | `fe-07` |
| `MING-06` | [actors.ts](../../Script/watch/fe/renderer/actors.ts) `L66-83,145-171` | 周戍翻滚仍绘 ICEY 冰青残影，与明代守卒写实感冲突且与 `fe-06` 穿梭器残影语义重叠 | 保持零改动；待改为短促脚底扬尘 | M2 / `fe-07` |

---

## 四、M1 合流接线说明（仅 2 行，供合流者操作）

本分支未修改 [frontend.ts](../../Script/watch/fe/frontend.ts)。在合流点 **M1** 合并 `fe-01` + `fe-02` + `fe-03` 后，于 `WatchFrontend` 构造函数末尾注册即可生效：

```ts
import { PrologueIntroPlugin } from "Script/watch/fe/cutscenes/prologue_intro";
import { MingArtAuditPlugin } from "Script/watch/fe/renderer/ming_audit";

// WatchFrontend constructor 末尾（M1 统一接线）
this.registerPlugin(new MingArtAuditPlugin());
this.registerPlugin(new PrologueIntroPlugin());
```

### 待接后端接口（若后续补充序章前段独立房间）

- 正式入口目前在 `prologue` 仅含 `prologue-wait` / `prologue-give` / `prologue-follow`。若后端后续拆分小满卧室叫醒与逃柜房间，只需下发相位 `prologue-wake` / `prologue-shadow` / `prologue-escape` / `prologue-hide` 及可选字段 `escapeDuration` / `escapeRemaining`（或事件 `p04WallFlash`），`PrologueIntroPlugin` 即可零改动自动消费。
- 当前阶段 `P04` 在 `prologue-follow` 末段、`street` 起始段及 `s1-crossroad` 井背已可自然触发；完整 `P01 → P02 → 入柜` 可通过排演钩子 `package.loaded["watch.fe"].prologue:startRehearsal("sequence")` 独立回放并自带「排演」标注。
