# FE-02 阶段交付与验证记录（`feature/fe-02-reload-carry-craft`）

- **任务**：Wave 1 并行模块 FE-02（背负姿态 + 3×3 慢时连线换弹 + 第三段安全工台与首次试握）
- **分支**：`feature/fe-02-reload-carry-craft`（切出基线 `origin/feature/fe-dual-route@cf260d9`，`--no-track`，不执行 M1 合并）
- **远端**：`origin` = `hxsx1016/dora-game`
- **实测环境**：Linux x86_64（ubuntu-dev，Dora SSR 1.10.2.12 + 1280×720 虚拟帧缓冲）
- **后端零侵入确认**：`git diff --name-only origin/feature/watch-level-rework` 中对 `play.ts`、`run.ts`、`rooms.ts`、`depth.ts`、`escort.ts`、`input.ts`、`keys.ts`、`app.ts`、`init.ts` 及对应 `.lua` **改动 0 处**；前端热点文件（`frontend.ts`、`contract.ts`、`plugins.ts`、`actors.ts`、`hud.ts`、`menus.ts`、`narrative.ts`）**改动 0 处**。

## 一、活跃远端分支核查结论

| 远端分支 | 最新提交 | 与 FE-02 关系及适配结论 |
| --- | --- | --- |
| `origin/feature/story-b2-escort` | `80aea38` | tqym 后端 B2 五段护送与第三段工台实现：`Script/watch/craft.ts` 确认配方 ID（`guide_lantern_gun`/`echo_gun`）、`submitFeIntent`（`craftSubmit`/`craftEquip`/`craftClose`）、材料键 `wood`/`bell` 与事件 `benchCraft`/`benchRejected`；`craft_bench.ts` 已同时兼容 `wood`/`bell` 与排演态 `wood_tally`/`bell_tally` 并监听 `benchCraft`/`benchRejected` |
| `origin/feature/fe-03-prologue-ming-art` | `aaa641e` | Wave 1 并行分支（仅含 `prologue_intro.ts`、`ming_audit.ts`、`fe03-ming-art-audit.md`、`verify-fe03.lua`），与 FE-02 零文件重叠 |
| `origin/feature/fe-dual-route` | `cf260d9` | 前端总集成分支（已达成 M0 合流），作为本分支切出基线 |
| `origin/feature/fe-00-foundation` | `e6d9779` | 已合入 `fe-dual-route`，已提前对齐 `story-b1-carry` 的 `A单/B1` 字段与 `reloadTapNode` 映射 |
| `origin/feature/story-b1-carry` | `4b294db` | tqym 后端 B1 背负与换弹实现：`Script/watch/reload.ts` 已确定 3×3 布局（0 起点 / 2 灯纹 / 4 铃纹 / 8 终点、8 邻域含斜角、240 作答拍 = 60 世界拍）；FE-02 与之 100% 同构对齐，并补齐鼠标拖线/键盘选点双输入及照明/回声/推退水墨视觉反馈 |
| `origin/feature/watch-level-rework` | `648ff43` | 上游锁定原点，无冲突变动 |

## 二、本分支独占交付物

1. **背负姿态插件**：[carry_pose.ts](../../Script/watch/fe/renderer/carry_pose.ts) / [carry_pose.lua](../../Script/watch/fe/renderer/carry_pose.lua)
   - 保持序章像素风，完整区分牵手过平路（两种步幅 + 青布补线袖口交握）、高石阶蹲背攀爬（`0.45s` 上背过渡）、常规背负战斗移动（贴合周戍单碰撞体、平滑阻尼转身、压隐原生 `actor_child` 消除半空蹬腿穿帮）、换弹肩后探手联动以及第三段工台放下与重新背起。
2. **3×3 慢时连线换弹全速 UI 插件**：[reload_wheel.ts](../../Script/watch/fe/ui/reload_wheel.ts) / [reload_wheel.lua](../../Script/watch/fe/ui/reload_wheel.lua)
   - 延续序章像素风冷素宣纸与墨线视觉，侧向智能避让停靠保证周戍、探手小满与远处敌人同框；
   - 鼠标拖线/点选与键盘方向选点（`WASD`/方向键 + `Enter`/`Space`/`E`，避开 `app.ts` 占用的 `Num1..8`）共用同一 `submitIntent` 入口；
   - 起点 0 绘小满手指落位提示（默认低引导零文字教程），按轮廓形状与线型区分推退 / 铃纹回声 / 灯纹照明（静音/灰度可辨）；非法跳点或中途松手清回 `[0]` 不重计 4 秒；超时收为 `normal`；暂停冻结双钟与路径；同步驱动 `AudioDirector.setWorldPlaySpeed`；并在世界空间补齐 `reloadApplied` 推退/回声/照明轻量化水墨反馈。
3. **第三段安全武器工台插件**：[craft_bench.ts](../../Script/watch/fe/ui/craft_bench.ts) / [craft_bench.lua](../../Script/watch/fe/ui/craft_bench.lua)
   - 明朝木案与序章军粮棚同尺度、同提灯暖光，侧向展开保留周戍与落地小满同框；
   - 案左实物排布持有筹码（木纹筹/铃纹筹），案右并列「引路灯铳」与「回声铳」及同源迷你 3×3 强化纹样预览；
   - 缺料高亮不发请求、取消保留全部材料、确认带唯一 `requestId` 幂等提交（仅凭后端快照确认更新库存与状态）、首次制成播 1.0s 试握动画（二次制作 0.45s 短递交）、支持立即可装备与读档快照还原。
4. **分轨音频资源**：[SOURCES.md](../../assets/audio/combat/SOURCES.md) 及 `assets/audio/combat/*.wav`（11 份离线轻量 WAV，总计 164KB）。
5. **专项验收脚本与视觉对照证据**：
   - [verify-fe02.lua](../../tools/verify-fe02.lua)（70 项断言覆盖全路径、双输入、240:60 双时钟、暂停、缺料、幂等与读档）
   - 同尺度对照图（排演模式）：[fe02-granary-vs-bench.png](../fe-showcase/fe02-granary-vs-bench.png)
   - 背负换弹（回声 / 照明 / 首次试握 / 灰度可读性四格总览，排演模式）：[fe02-reload-carry-overview.png](../fe-showcase/fe02-reload-carry-overview.png)

## 三、验证与回归结果

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| `Dora cli build --lang ts` | PASS | `carry_pose.lua` / `reload_wheel.lua` / `craft_bench.lua` 零编译错误，已对齐 `Script.watch.*` require 路径 |
| `tools/verify-fe02.lua` | **FE02 PASS 70 / FAIL 0** | 覆盖背负全态、三类路径、双输入、无效重画、超时、暂停双冻、**240 作答拍 = 60 世界拍**、工台缺料/取消/首制1s/幂等/二制0.45s/读档 |
| `tools/verify-d6.lua` | **PASS 24 / FAIL 0** | 既有风台与投瓶回归零破坏 |
| `tools/verify-integration.lua` | **INTEGRATION PASS 22 / FAIL 0** | 既有前端菜单、映射与资源槽零回归 |
| `tools/verify-trial.lua` | **PASS**（outer 3451 拍 / drygoods 3360 拍） | 五段护送试炼零回归 |
| `python3 tools/check-repo.py` | **PASS** | 31 组源码与 Lua，27+ 份 Markdown 零断链 |
| 字体 cmap 缺字扫描 | **0 缺字** | 全部 78 个非 ASCII 文案字符在 `lxgw-neo-zhisong.ttf` 100% 命中 |

> **说明**：本次视觉对照图与 `verify-fe02.lua` 使用显式排演态（`enterRehearsal`，画面顶部带 `排演 · fe02-*` 标注）验证；正式后端联调待 M1 合流并与 `story-b1-carry` 对接后在真机键鼠与 Windows 离线包上复测（Windows 冷启动待测）。

## 四、给 M1 合流方的极简接线清单（本分支不执行合并）

合流方在 `feature/fe-dual-route` 合并 `feature/fe-02-reload-carry-craft` 后，仅需在 `Script/watch/fe/frontend.ts` 导入并在构造函数注册 3 个插件即可全局启用：

```ts
import { CarryPosePlugin } from "Script/watch/fe/renderer/carry_pose";
import { ReloadWheelPlugin } from "Script/watch/fe/ui/reload_wheel";
import { CraftBenchPlugin } from "Script/watch/fe/ui/craft_bench";

// WatchFrontend constructor 中追加：
this.registerPlugin(new CarryPosePlugin());
this.registerPlugin(new ReloadWheelPlugin(this.contract));
this.registerPlugin(new CraftBenchPlugin(this.contract));
```

**可选 M1 联调优化建议（非阻塞）**：
1. 合并后端 `story-b1-carry` 时，若 `hud.ts` 合入了后端临时换弹进度带，建议在 `reload_wheel` 插件激活时由 `hud.ts` 退让，避免与宣纸 `3×3` 盘重叠双绘；
2. 如需连同排演态远端原始小满脚底椭圆影一并收净，可在 M1 接线时为 `actors.ts` 增加 2 行可选 `suppressPartner` 标志。
