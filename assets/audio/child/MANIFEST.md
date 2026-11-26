# `assets/audio/child/` 分轨音频资产清册（`fe-04`）

本目录存放 `feature/fe-04-child-lowpoly`（小满单人线《小小梦魇》风低模四房）的分轨音频资产。全部文件均为 **16 kHz / 16-bit PCM 单声道 WAV**，离线免外部依赖，严格对齐 `AudioDirector` 五条逻辑音轨（`voice` / `wind` / `water` / `ambience` / `sfx`），并已随 M1 更新的 `tools/make-windows-pack.sh`（全量复制 `assets/audio/`）自动打入 Windows 离线包。

## 1. 城外栈台 `outside`（`F01` 上半）

| 文件 | 逻辑音轨 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `wind_outside_loop.wav` | `wind` | `0.36` | `loop:fe04_outside_wind` | 宁村所外城海防夜风无缝循环 |
| `cart_wheel_loop.wav` | `ambience` | `0.00 → 0.54`（随板车实际位移速度调制） | `loop:fe04_cart_wheel` | 红布检修车木轮在栈台木板上的滚动与木轴轻响 |
| `cart_dock.wav` | `sfx` | `0.88` | `audio.ts` 消费 `cartDocked`（`cart:docked`） | 木轮滑入栈台挡槽空窝的沉稳一落 |
| `sewing_memory.wav` | `ambience` | `0.66` | `fe04:outside:sewing:<sid>` | 首次握住右柄红布补丁时约 0.52 秒家人缝布拉紧最后一针的柔音 |

## 2. 空村桌下 `village`（`F01` 下半）

| 文件 | 逻辑音轨 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `village_night_loop.wav` | `ambience` | `0.24` | `loop:fe04_village_night` | 空村冷灶与桌下阴影的低沉寂夜底噪 |
| `bottle_brick.wav` | `sfx` | `0.90` | `audio.ts` 消费 `bottleLanded`（`surface="brick"`） | 陶瓶砸中露天青砖的干脆单响与短促碎陶声 |
| `bottle_iron.wav` | `sfx` | `0.90` | `audio.ts` 消费 `bottleLanded`（`surface="iron"`） | 陶瓶砸中铁盆的撞击 + 金属盆沿颤动余响（待后端携带 `surface="iron"` 直通） |
| `bottle_iron_ring.wav` | `sfx` | `0.82` | `fe04:village:iron_ring:<sid>:<tick>:<seq>` | 当前后端 `bottleLanded` 尚未携带 `surface` 字段时，落点命中铁盆区域（`basinX=548`）自动叠加的金属余振尾音；后端补齐 `surface="iron"` 后自动避让防重音 |
| `bottle_soft.wav` | `sfx` | `0.78` | `audio.ts` 消费 `bottleLanded`（`surface="soft"`） | 陶瓶落入软土的沉闷消音与细沙散落声 |

## 3. 密林与溪湾 `forest`（`F02`）

| 文件 | 逻辑音轨 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `forest_wind_loop.wav` | `wind` | `0.34`（靠近溪湾自然衰减让位溪声） | `loop:fe04_forest_wind` | 深夜松林枝叶沙沙夜风无缝循环 |
| `twig_snap.wav` | `sfx` | `0.84` | `fe04:forest:twig:<sid>:<idx>` | 小满未蹲伏踩中林径枯枝或林犬转耳警觉时的干脆枯枝折裂声 |
| `dog_step.wav` | `sfx` | `0.28 → 0.72`（按与小满距离衰减） | `fe04:forest:dog_step:<sid>:<stepIdx>` | 林犬巡逻与追逐脚步声 |
| `dog_alert.wav` | `sfx` | `0.84` | `fe04:forest:dog_alert:<sid>:<alertIdx>` | 林犬竖耳嗅声与低吼警觉 |
| `creek_loop.wav` | `water` | `0.00 → 0.56`（随进入溪湾渐强，停步持续流动） | `loop:fe04_creek_water` | 将晓溪湾清冽水流无缝循环，与水面碎灯倒影同步 |
