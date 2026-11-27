# `assets/audio/foley/` 角色动作与物理材质拟音清册（`feature/audio-overhaul`）

本目录存放周戍、小满与场景生物的动作物理拟音，全部为 **48 kHz / Stereo / 16-bit PCM WAV**，由 `SoundscapeDirector`、`AudioDirector` 及场景插件通过冷却防抖与 2D 立体声像（`pan`）驱动。

| 文件名 | 逻辑音轨 | 时长 | 用途与触发点 |
| --- | --- | --- | --- |
| `step_soldier_stone_1.wav` – `_3.wav` | `sfx` | 0.22s | 周戍厚底战靴青石步幅 3 变体轮播 |
| `step_child_stone_1.wav` – `_3.wav` | `sfx` | 0.18s | 小满轻巧布鞋石板步幅 3 变体轮播（含 `gatepath` 牵手双步幅） |
| `step_child_moss_1.wav` – `_2.wav` | `sfx` | 0.18s | 小满密林厚苔藓步声 2 变体 |
| `step_child_water_1.wav` – `_2.wav` | `sfx` | 0.24s | 小满暗渠与溪湾浅水步声 2 变体 |
| `step_scavenger_1.wav` – `_2.wav` | `sfx` | 0.22s | 空村拾荒者沉重草鞋步声 2 变体 |
| `soldier_roll.wav` | `sfx` | 0.42s | 周戍翻滚/滑铲的棉甲衣料摩擦与落肩闷响 |
| `jump_soldier.wav` | `sfx` | 0.22s | 周戍起跳蹬石与衣摆声 |
| `jump_child.wav` | `sfx` | 0.18s | 小满轻盈起跳声 |
| `land_soldier.wav` | `sfx` | 0.26s | 周戍厚靴落地沉响 |
| `land_child.wav` | `sfx` | 0.18s | 小满轻落石板声 |
| `crouch_rustle.wav` | `sfx` | 0.24s | 蹲伏/贴地时布衣轻擦声 |
| `bottle_pickup.wav` | `sfx` | 0.22s | 小满拾起空陶瓶的粗陶微碰声 |
| `bottle_throw.wav` | `sfx` | 0.28s | 掷出陶瓶破空呼啸（`bottleThrown` 事件） |
| `dog_chase_bark.wav` | `sfx` | 0.78s | 密林恶犬进入追击态的低沉狂吠嘶吼（区别于 `dog_alert` 警觉低嗅） |
| `fear_gasp.wav` | `sfx` | 0.36s | 小满恐惧格上升时的轻促抽气（`fearChanged`） |
| `fear_freeze.wav` | `sfx` | 0.68s | 小满恐惧满格冻结时的低沉心跳与提示泛音（`fearChanged`） |
