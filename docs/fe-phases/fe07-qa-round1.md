# 《向西守望》前端第一轮验收

2026 年 11 月 26 日。前端收口基于 `feature/fe-dual-route` 的 `e674126`，相对关卡重制基线 `648ff43`，`init`、玩法、输入与关卡核心文件均无差异。正式入口联调在本地临时目录组合 `feature/story-d-integration@dafed63`。组合版可供首轮试玩。

## 交付单核对

| 项目 | 本轮结果 |
| --- | --- |
| 共同序章与 2.5D 行走 | 原生回归验证连续前后移动、斜走绕过实体障碍、柱后遮挡变暗及离开后恢复。实拍复核倒柜、绞盘和矮拱。P01 叫醒与 P02 墙影、躲柜可排演，正式入口仍从周戍在倒柜旁开始。 |
| 风台与两线分流 | 正式后端复核 79/100 进小满线、80/100 进周戍线、1439 拍已按住的方向键要松开重按，以及牵手 35/36 拍边界。前端验证 24 秒的脚底与门槛对齐、数声单次触发、暂停同拍恢复。第十八至二十声期间降低风水声，第十九声后延约 0.78 秒播呼吸。 |
| 小满线与北塔留灯 | 低模桌下实拍能区分鞋底、铁盆和砖块形状。引擎回归核对砖响、铁盆声与软土消音、窄洞、溪湾，以及北塔空行和西窗灯。北塔同机位截帧为排演。 |
| 周戍线、换弹与工台 | 联调复核背负、三种换弹路径、超时、暂停、配方扣料与装备。第二段地面添加可在灰度区分的木纹筹和铃纹筹。护送分段使用对应场景和标题。北塔团圆样片能看到名簿第二行和双手端碗。 |
| 水井与现代展厅 | 测试覆盖新档与单通关门控、双通关进入、展厅中途续读、转灯叩响与返回厨柜。修复排演读取正式井口坐标导致 E 失效、贴墙踏步及返回标题残留循环音。选章页隐藏展厅，公开关卡超八项时分两行。 |
| 字库与离线包 | 新加的关卡大字使用新致宋，补齐书法字体缺少的字。扫描前端正文、章名、用印与数词候选字符，字库覆盖检查无缺字。引擎自动化涵盖 720p、1080p、1440p 和 1680×720 的投影。Windows x64 ZIP 通过完整性与资源逐文件核对。 |

前端原生回归 17 组。组合版正式入口和回放另核对两条路线、城门 61 条边界断言、背负换弹 53 条、博物馆 32 条和存档修复 105 条。原 C1 脚本仍断言早期的固定坏档备份名。在临时副本改为查返回的备份路径并验证原文字节后，42 条通过。

已复现的后端问题是同一引擎进程第二次跑粮棚段时材料消失。相同原生走位脚本第一轮 23/23，第二轮 20/23，恰好三个材料读取失败。房间模板的材料对象被运行中的拾取操作清除，重新进入时仍共用这些对象。需要后端在生成房间状态时复制每项拾取数据。

待验收项包括正式序章 P01/P02 接线、正式人声替换及听感复审、两线全程录屏、三位首次玩家的盲测与双线计时、Windows 真机冷启动和显示缩放。当前人声文件为合成占位样音，播放时序和轨道验证以现有文件为准。

## 接口联调

字段类型以 [contract.ts](../../Script/watch/fe/contract.ts) 为准。正式模式由玩法提交状态，前端输入意图交玩法消费，演出从事件与快照恢复。

| 字段 | 类型及样例 | 触发与恢复 |
| --- | --- | --- |
| `storyRoute` | `StoryRoute`，`"undecided"`、`"child"`、`"soldier"` | 送小满过城门时 `storyRouteLocked` 锁存血量与路线，重试和切房使用锁存值。 |
| `countElapsedTicks` | `number`，`720` / `1440` | 过门后按玩法节拍推进，`gateCountDone` 确认收束。暂停冻结，续读按同拍恢复且避免补播旧数声。 |
| `gateReunion` | `GateReunionSnapshot`，`{active: true, knockHeard: true, holdProgress: 0.5, holding: true, completed: false, releasedAbortCount: 0}` | 交互持续按住，玩法用 `knock`、`handRelease` 与 `handHeld` 推进，暂停冻结，松手回退后可重按。 |
| `backCarry` | `BackCarrySnapshot`，`{active: true, handInHand: false, mounting: false, atBench: false}` | 高石阶 `carryStart` 进入背负，工台快照切换放下姿势，重绑按当前状态重算姿势。 |
| `timeScale` | `number`，`1`、`0.25` | 玩法在换弹请求和结束时变更倍率，世界时间受倍率控制，光标按界面时间更新。暂停时冻结两侧的会话进度。 |
| `reloadSession` | `ReloadSessionSnapshot`，例如 `active: true`、`path: [0, 1, 2]`、`duration: 4` | 前端发点选和提交，玩法以 `reloadNode`、`reloadSolved`、`reloadTimeout` 结算，并通过 `reloadApplied` 确认实际效果。恢复时以快照路径和计时为准。 |
| `craftBench` | `CraftBenchSnapshot`，例如 `active: true`、`inventory: {wood: 2, bell: 1}`、`equippedWeapon: "guide_lantern_gun"` | 前端提交配方或装备请求，玩法用 `benchCraft`、`benchRejected` 或 `benchEquip` 确认，读档用库存、配方及装备快照恢复。 |
| `archive` | `ArchiveSnapshot`，例如 `{childCleared: true, soldierCleared: true, artifactOwned: true, museumPhase: "hall_walk", museumSeen: false}` | 双通关开放井口，玩法处理 `museumInteract` 并以 `artifactFound`、`museumStep`、`museumDone` 同步，存档续读直接还原馆内进度。 |

需求及原有样片见[双线交付单](../向西守望-双线前端交付单.md)、[最终施工书](07-qa-pack.md)、[M2 联合画面](../fe-showcase/m2-joint-showcase.png)和[风台同机位样片](../fe-showcase/m1-gate-5frames.png)。
