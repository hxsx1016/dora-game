# 第零阶段施工书：`feature/fe-00-foundation`（前端底座与契约解耦）

> **触发口令**：`开工前端第零阶段` / `开工 fe-00`
> **执行属性**：**串行必先完成**（合并为 **合流点 M0** 后，Wave 1 三条分支才并行启动）
> **推荐分工**：huihui（GPT）主攻架构、状态机、双时钟与音频防重播；Gemini 支援菜单文案、排演交互与资源槽命名
> **上级总控**：先读 [前端双线开发总控与阶段任务书](../前端双线开发总控与阶段任务书.md) 与 [前端开发手册](../前端开发手册.md)

---

## 一、开工前环境检查（Agent 第一步）

1. **绝不在 `_anchor` 主目录改动代码**。执行：
   ```sh
   git fetch origin --prune
   git worktree add ~/dev/.wt/2026gamejam/fe-00-foundation -b feature/fe-00-foundation --no-track origin/feature/fe-dual-route
   ```
2. 确认起点为 `origin/feature/fe-dual-route` 最新提交，工作区干净。
3. **红线自检**：本阶段**不得修改** `play.ts`、`run.ts`、`rooms.ts`、`depth.ts`、`escort.ts`、`input.ts`、`keys.ts`、`app.ts`、`init.ts` 及对应 `.lua`。

---

## 二、本阶段要交付的 5 项核心改造

### 1. 新建 `Script/watch/fe/contract.ts`（前后端双模式契约 + 内置排演 Mock）
为下游 6 条并行分支提供统一的只读视图 `DualRouteSnapshot`，显式选用正式数据源或排演数据源。正式入口在接口缺失时保留已有玩法，排演状态只存在于独立内存中：

- **必须导出的类型与接口**：
  - `StoryRoute = "undecided" | "child" | "soldier"`
  - `VisualStyleMode = "pixel" | "transition" | "lowpoly" | "museum"`
  - `ReloadEffectKind = "normal" | "knockback" | "echo" | "light"`
  - `MuseumPhase = "locked" | "well_open" | "well_reflect" | "hall_walk" | "lamp_turn" | "return_cabinet" | "done"`
  - `CraftRecipeView`: `{ id: string; name: string; desc: string; enhancedEffect: ReloadEffectKind; cost: Record<string, number>; crafted: boolean }`
  - `DualRouteSnapshot`（覆盖 [双线前端交付单](../向西守望-双线前端交付单.md) 约定的全部 8 类字段）：
    1. `storyRoute: StoryRoute`（只读后端在小满安全过门、殿后最后一拍结算后锁存的路线。字段缺失时返回 `undecided`。切房后即时 HP 与房内岔路 `run.route` 都不能代表分线结果）
    2. `countElapsedTicks: number` / `countDurationTicks: number` / `countNumber: number` / `countProgress: number`（自动兼容未来 `p.countElapsedTicks` 与当前 `p.countTick`、`GATE_COUNT_END`、`gateCountAtTick`）
    3. `gateReunion: { active: boolean; knockHeard: boolean; holdProgress: number; holding: boolean; completed: boolean; releasedAbortCount: number }`（0.6 秒长按重逢状态，支持中途松手归零重试、完成后只触发一次）
    4. `backCarry: { active: boolean; handInHand: boolean; mounting: boolean; atBench: boolean }`
    5. `timeScale: number`（正常 `1`，换弹慢时默认 `0.25`）
    6. `reloadSession: { active: boolean; firstTime: boolean; elapsed: number; duration: number; path: number[]; previewEffect: ReloadEffectKind; nextEffect: ReloadEffectKind; invalidFlash: number }`
    7. `craftBench: { active: boolean; firstCraftDone: boolean; justCraftedTimer: number; inventory: Record<string, number>; recipes: CraftRecipeView[]; equippedWeapon: string }`（内置两份默认排演方案：两枚木纹筹 →「引路灯铳」增强 `light`；一枚木纹筹+一枚铃纹筹 →「回声铳」增强 `echo`）
    8. `archive: { childCleared: boolean; soldierCleared: boolean; artifactOwned: boolean; museumPhase: MuseumPhase; museumSeen: boolean }`
  - `assistHintsEnabled: boolean`（**默认 `false`**，由暂停菜单切换）
  - `visualMode: VisualStyleMode`（由当前房间、`storyRoute`、`museumPhase` 与风台 `countProgress` 统一推导）
- **排演控制器 `DualRouteContract` 类**：
  - `resetForRoom(p: Play)`：切房/重试时清空瞬时态（如 `gateReunion`、`reloadSession`、`justCraftedTimer`），并从后端档案重读双结局与神器归属。按键辅助取用户设置，排演档案只在该次排演内跨房保留；
  - `sample(p: Play, rawDt: number, input: Input): DualRouteSnapshot`：正式模式读取玩法快照，缺字段按能力降级。排演入口使用专属快照并标记录屏，离开排演后恢复正式数据源；
  - **排演与自动化钩子**：挂在 `WatchFrontend.contract`（即 `package.loaded["watch.fe"].contract`），暴露简洁方法供后续分支自测与录屏脚本调用，例如：
    - `setMockRoute(route: StoryRoute)`
    - `setMockCountTick(tick: number)`（定格 0 / 360 / 720 / 1080 / 1440 拍截五张关键帧，另在 1260 拍核对第十九声）
    - `triggerMockReload(active: boolean)`、`triggerMockBench(active: boolean)`、`setMockArchive(childCleared: boolean, soldierCleared: boolean)`、`enterMockMuseum(phase: MuseumPhase)`
  - 并在文件顶部注释清楚：**待后端字段就绪时，仅需把本文件内的真实字段读取分支对齐即可，零改动下游所有渲染模块**。

### 2. 新建 `Script/watch/fe/audio.ts`（分轨音频与事件去重控制器）
对照 [动画插入与演出规划](../向西守望-动画插入与演出规划.md) 与 [前端开发手册](../前端开发手册.md)：

- 支持逻辑音轨分类：`voice`（女声数数/台词）、`wind`（风声）、`water`（水声/滴水）、`ambience`（环境底噪）、`sfx`（布擦木、两下轻叩、砖面/铁盆回声、换弹纹样、工台试握）。
- **核心约束**：
  1. **缺失容错**：底层用 `Content.exist(path)` 检查，音频文件尚未放入 `assets/audio/` 时静默记录逻辑播放日志而不抛异常（方便 headless/缺素材回归测试 100% 通过）；
  2. **按事件序号 / 节拍去重**：提供 `playOnce(dedupeKey: string, track: AudioTrack, path: string, volume?: number)`，保证 0 步帧、暂停重绘、重复采样绝不重复触发同一声数数或敲门；
  3. **暂停冻结与恢复续播**：`setPaused(paused: boolean)` 在暂停时冻结音轨播放/逻辑位置，恢复时从同一拍/同一声音位置继续；
  4. **切房与重试清理**：`stopRoomTransient()` 停止房间瞬时音效并清空本房去重表；
  正式事件由既有 `PlayAdapter.sample` 唯一调用 `drainEvents()`。在适配器将同帧事件按 `seq` 顺序分发给音效与插件，保留 `tick`、事件序号和检查点代号。验证一帧补跑跨过两次事件时各响一次，暂停重绘和读档重建不补播旧事件。

  5. **供验证脚本读取的播放记录**：记录最近触发的 `(tick, track, cueId)`，便于自动化脚本核对「声音、字幕和手势各出现一次」。

### 3. 新建 `Script/watch/fe/plugins.ts`（前端渲染插件接口，零冲突隔离核心）
让 Wave 1 / Wave 2 的 6 条并行分支各自实现独立插件并挂载到 `WatchFrontend`，**互不编辑热点大文件**：

- 定义 `FePluginContext`（包含 `p: Play`、`view: DualRouteSnapshot`、`events: FrameEvents`、`input: Input`、`cam: CameraDirector`、`audio: AudioDirector`、`assets: AssetSlotHost`、`texts: TextPool`、`worldDt: number`、`uiDt: number`、`w: number`、`h: number`、`uiScale: number`、`paused: boolean`）。
- 定义 `FeRenderPlugin` 接口（全部方法可选）：
  - `readonly id: string`
  - `onBindPlay?(p: Play, view: DualRouteSnapshot): void`
  - `update?(ctx: FePluginContext): void`
  - `drawBackdrop?(bgDraw: DrawNode.Type, bgGlow: DrawNode.Type, backdropArt: AssetSlotHost, ctx: FePluginContext): boolean`（返回 `true` 时接管默认 `StageRenderer.drawBackdrop`）
  - `drawWorld?(fgDraw: DrawNode.Type, fgGlow: DrawNode.Type, worldArt: AssetSlotHost, ctx: FePluginContext): boolean`（返回 `true` 时接管默认世界绘制）
  - `drawActorsOverlay?(fgDraw: DrawNode.Type, fgGlow: DrawNode.Type, worldArt: AssetSlotHost, ctx: FePluginContext): void`（叠加背负/手部接触影/穿梭器残影等）
  - `drawCutsceneOverlay?(uiDraw: DrawNode.Type, uiInkDraw: DrawNode.Type, uiArt: AssetSlotHost, uiGlow: DrawNode.Type, ctx: FePluginContext): boolean`（用于袖口特写、序章开场、双结局登记簿等，返回 `true` 时可压暗或替换默认叙事卡）
  - `drawFullSpeedUi?(uiDraw: DrawNode.Type, uiInkDraw: DrawNode.Type, uiArt: AssetSlotHost, uiGlow: DrawNode.Type, ctx: FePluginContext): boolean`（用于 3×3 全速换弹线盘、工台界面等，不受 `timeScale` 拖慢，返回 `true` 时隐藏常规准星）

### 4. 改造低引导机制（零侵入 `app.ts`！）
对照 [双线前端交付单](../向西守望-双线前端交付单.md#分线画风与默认引导验收) 与现有 [menus.ts](../../Script/watch/fe/ui/menus.ts) / [hud.ts](../../Script/watch/fe/ui/hud.ts)：

- **`Script/watch/fe/ui/menus.ts`**：
  - 在 `PAUSE_ITEMS` 中新增两项（保持键鼠上下切换与点击不串键）：
    1. `{ id: "controls", zh: "操作说明" }` —— **注意**：因 `app.ts` 暂停态不处理 `openControls` 返回值，必须在 `MenuRenderer` 内部维护 `private pauseShowControls = false`，选中后直接原地渲染现有双栏素笺操作说明，按 `Esc` / 确认 / 点击返回按钮切回暂停菜单列表（**零改动 `app.ts`**！）；
    2. `{ id: "assist", zh: "按键辅助：关" }`（动态显示 `关` / `开`，默认 `关`，选中直接原地切换并回写状态，不关闭暂停菜单）。
  - 离开暂停或重新 `openPause()` 时重置 `pauseShowControls = false`。
- **`Script/watch/fe/ui/hud.ts`**：
  - `draw(...)` 接收 `assistHintsEnabled: boolean`（默认 `false`）及 `suppressReticle?: boolean`：
    - 当 `assistHintsEnabled === false`（默认）：
      - **关闭** `deriveWorldPrompt(p)` 就近按键浮签（`drawWorldPrompts` 不画）；
      - **关闭** 检查站/城外顶部文字目标清单（`drawContextualObjective` 中第 2 段“红布板车入窝 / 蹲伏穿拱赴塔”隐藏，仅保留城门 45 秒守点进度/时间等核心战斗读数）；
      - **关闭** 小满惊惧旁边的闪烁 `[E]` 键帽（保留菱花惊惧点状态反馈，不提示按键）以及 `drawChildStatus` 里“按住 [F] 瞄投”的按键教学文字（改为纯状态描写，如「手持陶瓶」）；
      - **关闭** 城门 `gate-idle` 文案中的“按 [E] 重新守门”（改为纯状态「绞盘待命」）；
      - **保留** 体力墨格、惊惧菱花状态、掩体受击/挡下即时反馈、右上角极淡 `Esc 暂歇`（让玩家知道能打开暂停看操作表）与战斗准星。
    - 当玩家在暂停菜单主动打开 `assistHintsEnabled === true` 时，恢复上述按键浮签与清单提示。

### 5. 改造 `frontend.ts`、`camera.ts`、`assets.ts`、`adapter.ts` 的底座扩展点
- **`Script/watch/fe/frontend.ts`**：
  - 持有 `readonly contract = new DualRouteContract()`、`readonly audio = new AudioDirector()`、`private plugins: FeRenderPlugin[] = []`，并提供 `registerPlugin(plugin: FeRenderPlugin)`；
  - `bindPlay` 时重置 `contract.resetForRoom(p)`、`audio.stopRoomTransient()` 并通知各插件 `onBindPlay`；
  - `renderPlay` 实现**双时钟分离**：
    - `uiDt = p.paused ? 0 : safeDt`（菜单自身暂停时传 `safeDt`）；
    - `worldDt = p.paused ? 0 : safeDt * view.timeScale`（换弹慢时期间，相机/角色动画/粒子自动按 `worldDt` 减速，而全速 UI 线盘按 `uiDt` 保持全速！）；
    - 同步调用 `audio.setPaused(p.paused)`；
  - 按「Backdrop → World → Props → Actors + ActorsOverlay → VFX → Foreground → HUD/Narrative/CutsceneOverlay → FullSpeedUi」顺序调用插件挂点，任何插件未注册时 100% 退回既有像素水墨前端（零回归）。
- **`Script/watch/fe/camera.ts`**：
  - 新增**双对齐点锚定接口**（供风台 24s 转景和镜头特写用）：
    - `setAnchorLock(lock?: { footWorldX: number; footWorldY: number; thresholdWorldX: number; screenFootFracX: number; screenFootFracY: number; zoomOverride?: number })`；
    - 切房/重试 `snap()` 时自动清空 `anchorLock`，保证不污染后续房间；
    - 确认 `screenToWorld` 与 `worldToScreen` 在 `anchorLock` 开启与关闭时始终严格互逆。
- **`Script/watch/fe/assets.ts`**：
  - 新增动态注册方法 `registerDynamicSlot(key: string, cfg: AssetSlotConfig)`（或扩展 `tryPlacePath(...)`），使 Wave 1/2 并行分支无需反复修改 `assets.ts` 的 `AssetSlotKey` 大联合类型就能挂载新图片/图集！
- **`Script/watch/fe/adapter.ts`**：
  - 给 `FrameEvents` 补齐事件序号 `eventSeq`（单调递增）和已消费事件列表摘要，便于 `audio.ts` 按序号防重播；保留 `deriveWorldPrompt` 函数供 `assistHintsEnabled === true` 时使用。

---

## 三、验收与收尾（达到合流点 M0）

完成编码后按顺序执行全部检查，**缺一不可**：

1. **Dora 编译 TS → Lua**：
   ```sh
   Dora cli build -p . --lang ts
   ```
   确认新增的 `contract.lua`、`audio.lua`、`plugins.lua` 及改动模块的 `.lua` 全部生成且零编译错误。
2. **静态与红线检查**：
   ```sh
   python3 tools/check-repo.py
   git diff --cached --check
   git diff --name-only origin/feature/watch-level-rework
   ```
   确认：零断链、零缺失 `.lua`、**零后端核心文件改动**。
3. **引擎回归验证**：
   - 在 Dora 中运行 `verify-d6`、`verify-integration`、`verify-trial`，必须全部 PASS；
   - 启动默认入口 `init.lua` 人工抽查：
     - 默认进入局内时，就近 `[E]` / `[Shift]` / `[F]` 浮签和检查站任务清单**不显示**；
     - 按 `Esc` 进暂停菜单 → 点「操作说明」能看到双栏素笺且返回暂停不串键 → 点「按键辅助：关」切换为「开」后返回局内，浮签恢复显示；
     - 显式进入排演后，通过 `package.loaded["watch.fe"].contract` 切换 `timeScale = 0.25` 时角色/粒子减速、暂停时立即冻结、恢复时继续。
4. **提交并合入总分支（形成 M0）**：
   - 推送本分支：`git push -u origin feature/fe-00-foundation`；
   - 在 `feature/fe-dual-route` 工作区合并 `feature/fe-00-foundation`（`git merge --no-ff feature/fe-00-foundation`），复跑 `python3 tools/check-repo.py` 后推送 `git push -u origin feature/fe-dual-route`。
   - 至此 **M0 达成**，通知双方可立即并行开启 `fe-01`、`fe-02`、`fe-03`！
