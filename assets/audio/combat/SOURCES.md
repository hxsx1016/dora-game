# `assets/audio/combat/` 战斗、换弹、奇器与守门音效清册（`feature/audio-overhaul`）

本目录全部 **40 份**（原 14 份 48 kHz 立体声重制 + 新增 26 份）WAV 音效均为离线物理建模/程序化合成的 **48 kHz / Stereo / 16-bit PCM** 原创素材，无第三方版权限制。

## 1. 既有核心战斗与换弹音轨（14 份 · 48 kHz 立体声重制）

| 文件 | 时长 | 用途与触发点 |
| --- | --- | --- |
| `shot.wav` | 0.68s | 周戍标准明式火铳黑火药膛爆、铅丸破空与砖巷回响（`shotResolved`） |
| `cover_block.wav` | 0.34s | 通用掩体挡弹回退音（`coverBlocked`） |
| `actor_hit.wav` | 0.42s | 人物/敌兵受击低频撞击与衣甲受创声（`actorHit` / `gateFailed`） |
| `carry_start.wav` | 0.52s | 高石阶蹲背背起小满（`carryStart`） |
| `reload_open.wav` | 0.36s | 小满触盘进入 3×3 慢时换弹（`reloadOpen`） |
| `reload_node.wav` | 0.26s | 换弹节点连线兜底回退音（实际优先按步数轮播 `reload_node_1..6.wav`） |
| `reload_invalid.wav` | 0.28s | 跳格、重复点或松手清回重画（`reloadInvalid`） |
| `reload_solved.wav` | 0.44s | 通用枪机复位咔嗒（`reloadSolved`） |
| `reload_solved_knockback.wav` | 0.48s | 推退（`knockback`）路径结算气冲复位 |
| `reload_solved_echo.wav` | 0.76s | 铃纹（`echo`）路径结算明式小铜铃余振 |
| `reload_solved_light.wav` | 0.58s | 灯纹（`light`）路径结算火石引燃 |
| `reload_timeout.wav` | 0.34s | 4 秒作答超时收为普通装填（`reloadTimeout`） |
| `craft_done.wav` | 0.74s | 工台制成奇器落案与试握清响（`craftDone`） |
| `craft_insufficient.wav` | 0.20s | 工台库存不足空木轻叩（`craftInsufficient`） |

## 2. 新增武器差异化、材质挡弹、五声换弹与守门音轨（26 份）

| 文件 | 时长 | 用途与触发点 |
| --- | --- | --- |
| `shot_enemy.wav` | 0.56s | 敌兵鸟铳击发（较尖锐偏远，与周戍主铳清晰区分） |
| `shot_lantern_gun.wav` | 0.84s | 奇器「灯纹铳」：火药爆鸣叠加灯油炙燃呼啸 |
| `shot_echo_gun.wav` | 0.92s | 奇器「铃纹铳」：击发伴随空灵高频铜铃回振 |
| `shot_time_shuttler.wav` | 0.88s | 奇器「时间穿梭器」：冷澈金属振片与空灵时隙泛音 |
| `enemy_warn.wav` | 0.36s | 敌兵抬铳拉机预警清脆金属声（`SoundscapeDirector`） |
| `enemy_down.wav` | 0.56s | 敌兵倒地衣甲与兵器坠石声（`actorDown`） |
| `cover_block_wood.wav` | 0.28s | 铅丸击中木柜/木板掩体的木屑脆裂声 |
| `cover_block_stone.wav` | 0.26s | 铅丸击中青砖/石垒的碎石跳弹清响 |
| `cover_block_shield.wav` | 0.38s | 铅丸击中木铁残盾的厚铁钝响 |
| `prop_crack.wav` | 0.34s | 可破坏掩体受创开裂（`propDamaged`） |
| `prop_break.wav` | 0.68s | 可破坏掩体彻底碎裂坍塌（`propBroken`） |
| `reload_fx_push.wav` | 0.46s | 推退特效生效气浪冲击（`reloadApplied`） |
| `reload_fx_echo.wav` | 0.76s | 铃纹牵引特效生效铜铃余波（`reloadApplied`） |
| `reload_fx_light.wav` | 0.60s | 灯纹照亮特效生效暖焰燃起（`reloadApplied`） |
| `reload_node_1.wav` – `_6.wav` | 0.28s | 3×3 换弹连线 1–6 步 D 羽五声阶梯上行玉罄/古琴泛音（`reload_wheel.ts`） |
| `gate_winch_start.wav` | 0.58s | 城门 45s 守点绞盘拉升启动沉重棘轮啮合 |
| `gate_winch_lock.wav` | 0.88s | 45s 守门满格吊门铁锁卡死落定 |
| `gate_tarp_fall.wav` | 0.76s | 守门第 12s 破棚布撕裂坠落 |
| `campaign_failed.wav` | 1.25s | 战役重伤/倒下沉重远鼓一记与余息（`campaignFailed`） |
| `weapon_switch_artifact.wav` | 0.46s | 切换奇器时的布帛与黄铜构件轻鸣 |
| `afterimage_whoosh.wav` | 0.34s | 时间穿梭器/奇器冷白残影掠过风声（`afterimage_artifact.ts`） |
