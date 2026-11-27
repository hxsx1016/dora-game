# `assets/audio/child/` 小满单人线分轨音频资产清册（`fe-04` · `audio-overhaul` 48 kHz 立体声重制）

本目录存放小满单人线低模四房（`outside` / `village` / `forest`）的全部分轨音频。全部 14 份资产已于 `feature/audio-overhaul` 升级为 **48 kHz / Stereo / 16-bit PCM WAV**，并将 5 条环境/木轮循环加长至 **8–24s 真正零接缝**（彻底消除旧版 16 kHz 闷糊与 `cart_wheel_loop`/`forest_wind_loop` 接缝咔嗒声），100% 保持原路径兼容。

## 1. 城外栈台 `outside`（`F01` 上半）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `wind_outside_loop.wav` | `wind` | 22.00s（零接缝） | `loop:fe04_outside_wind` | 宁村所外城海防夜风多频立体声无缝循环 |
| `cart_wheel_loop.wav` | `ambience` | 8.00s（零接缝） | `loop:fe04_cart_wheel` / `scene_cart_wheel` | 红布检修车厚木轮压青石槽与木轴轻吱呀（同步复用于军粮棚推车） |
| `cart_dock.wav` | `sfx` | 0.68s | `cartDocked` | 木轮滑入挡槽空窝的沉稳一落 |
| `sewing_memory.wav` | `ambience` | 0.96s | `fe04:outside:sewing:<sid>` | 首次握住红布补丁时家人缝布拉紧最后一针的柔音 |

## 2. 空村桌下 `village`（`F01` 下半）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `village_night_loop.wav` | `ambience` | 24.00s（零接缝） | `loop:fe04_village_night` | 空村冷灶穿堂冷风与极远秋虫细颤寂夜底噪 |
| `bottle_brick.wav` | `sfx` | 0.64s | `bottleLanded`（`brick`） | 陶瓶砸中露天青砖的干脆单响与碎陶弹跳 |
| `bottle_iron.wav` | `sfx` | 1.55s | `bottleLanded`（`iron`） | 陶瓶砸中生铁盆撞击与清晰金属盆沿长余震 |
| `bottle_iron_ring.wav` | `sfx` | 1.38s | `fe04:village:iron_ring:...` | 命中铁盆区域补充叠加的纯净金属共鸣余振 |
| `bottle_soft.wav` | `sfx` | 0.38s | `bottleLanded`（`soft`） | 陶瓶落入软土的沉闷消音与细沙散落 |

## 3. 密林与溪湾 `forest`（`F02`）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `forest_wind_loop.wav` | `wind` | 24.00s（零接缝） | `loop:fe04_forest_wind` | 深夜松涛枝叶 3–9 kHz 细腻松针拂风无缝循环 |
| `twig_snap.wav` | `sfx` | 0.34s | `fe04:forest:twig:...` | 未蹲伏踩断林径枯枝的清脆木纤维断裂声 |
| `dog_step.wav` | `sfx` | 0.18s | `fe04:forest:dog_step:...` | 林犬巡逻/追逐爪垫踩踏落叶声（带距离衰减与 2D 声像） |
| `dog_alert.wav` | `sfx` | 0.62s | `fe04:forest:dog_alert:...` | 林犬竖耳嗅声与喉间低吼警觉（追击态另播 `foley/dog_chase_bark.wav`） |
| `creek_loop.wav` | `water` | 22.00s（零接缝） | `loop:fe04_creek_water` | 将晓溪湾清冽水流与物理气泡水花无缝循环 |
