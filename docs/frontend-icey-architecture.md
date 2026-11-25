# 守望 · 艾希（ICEY）风格前端实现与下游提取指南

> 分支：`feature/frontend-icey`（基于 `origin/feature/watch-d1-graybox` 后端 D1–D6 主线，独立开发、不直接合并）
> 目标：交付一套完整、可运行、与现有 8 房间后端契约 100% 匹配、且零外部生图依赖的高清 16:9 艾希风前端；同时确保下游「完整前端分支」可按目录整包提取，并直接通过资源槽位挂载生图资产。

## 1. 下游提取清单（供「完整前端分支」对话直接复用）

### 核心新增目录（零侵入，整包提取）

```text
Script/watch/fe/
├── theme.ts              # 艾希冷暗科工色板、8 房间氛围光照预设、顶点渐变/斜切几何原语、UTF-8 视觉字宽
├── assets.ts             # 可插拔外部生图资产槽位注册表（ASSET_SLOTS + AssetSlotHost）
├── adapter.ts            # 后端 Play 状态适配器（边沿事件提取 + 世界空间悬浮交互提示推导）
├── camera.ts             # 动态镜头导演（高清 16:9 投影、前瞻、剧情/战斗推拉镜、阻尼震屏、互逆坐标反算）
├── frontend.ts           # 前端总控（Dora 节点分层管理、Additive 发光层、验收钩子 watch.fe）
├── renderer/
│   ├── stage.ts          # 4 层视差 2.5D 舞台（渐变天穹/冷月/探照灯/远方北塔/中景骨架/建筑实体/近景暗角）
│   ├── props.ts          # 红布板车（旋转辐条轮+飘动红布）、村口瓶架/桌子/抛物线声波预测、区域与信标
│   ├── actors.ts         # 艾希风关节剪影角色（周戍/小满/敌兵/拾荒者/猎犬）+ 翻滚 5 层冰青残影
│   └── vfx.ts            # 粒子与光效池（霓虹曳光弹道、枪口焰、格挡盾闪、声波双环、4 类房间环境粒子、表现层顿帧）
└── ui/
    ├── textpool.ts       # 按字号分桶的零分配 SDF Label 对象池
    ├── hud.ts            # 极简斜切 HUD（周戍 3 格装甲血条+滞后白条、小满 3 晶格恐惧、城门守点同步条、战术准星）
    ├── narrative.ts      # 电影遮幅、底部旁白/系统指令条、切场区域卡、「数到二十」演出与北塔登记簿空行卡片
    └── menus.ts          # 终端接入风主菜单、8 章节直达矩阵、双线键位对照图鉴、暂停覆层
```

### 最小后端/入口适配（仅 2 个既有文件）

1. `Script/watch/play.ts`：
   - 仅导出 `Box` / `Actor` / `Enemy` / `Camera` / `Trace` 类型接口，并新增可选属性 `worldMapper?: (sx: number, sy: number) => { x: number; y: number }`；
   - `shoot()` 与 `bottleEnd()` 优先走 `worldMapper`，未注入时 100% 回退原 `320×180` 像素视口反算。
   - **不修改任何物理、AI、时序或剧情状态机**，`tools/verify-d6.lua`、`tools/replay-d5.lua`、`tools/replay-gate.lua` 全部零回归通过。
2. `Script/watch/app.ts`：
   - 默认启动 `WatchFrontend`（`title` 终端主菜单 → 8 章节全链试玩），同时完整保留 `G` / `F2` 切回 D1 灰盒调试视图、`1`–`8` / `Tab` / `F1` 快跳与 `package.loaded["watch.play" | "watch.input" | "watch.room" | "watch.fe"]` 运行态钩子；
   - 补充 `onKeyDown` 边沿锁存，防止低帧率下短按 `E` / `Space` / `Esc` / 菜单键被轮询漏掉。

## 2. 完整前端分支挂载生图资产方式

在 `Script/watch/fe/assets.ts` 的 `ASSET_SLOTS` 登记图片路径即可自动以 Dora `Sprite` 接管对应渲染，未配置的槽位继续由程序化矢量绘制兜底：

```ts
export const ASSET_SLOTS: Partial<Record<AssetSlotKey, AssetSlotConfig>> = {
    bgFar_checkpoint: { path: "assets/art/bg_checkpoint_far.png", anchorX: 0.5, anchorY: 0 },
    soldier_idle: { path: "assets/art/zhoushu_idle.png", anchorX: 0.5, anchorY: 0 },
    child_idle: { path: "assets/art/xiaoman_idle.png", anchorX: 0.5, anchorY: 0 },
    prop_cart: { path: "assets/art/cart_red_cloth.png", anchorX: 0.5, anchorY: 0 },
};
```

## 3. 验收记录

- **TS → Lua 编译**：全部 26 个 `.ts` 经 Dora SSR 原生编译器零错误编译，对应 `.lua` 已同步提交。
- **后端回归验证（Dora SSR 原生引擎实跑）**：
  - `tools/verify-d6.lua`：`PASS 21 / FAIL 0`
  - `tools/replay-gate.lua`：失败局、成功局、贴街垒掩体挡枪、2700 拍结算与送别交权全部通过
  - `tools/replay-d5.lua`：序章 → 街道 → 检查站 → 城门 → 城外 → 村口 → 森林 → 北塔 → 序章 8 房全链闭环通过
- **前端实机渲染截帧（Dora SSR v1.10.2 WebGL 运行时 1280×720）**：见 `docs/fe-showcase/`。
