# `assets/audio/tower/` 北塔双结局分轨音频清册（`fe-05` · `audio-overhaul` 48 kHz 立体声重制）

本目录存放北塔双结局同机位配对演出（`F03` 西窗留灯 / `M03` 二行皆满）的全部 15 份分轨音频。全部已升级为 **48 kHz / Stereo / 16-bit PCM WAV**，100% 保持原路径兼容。

## 1. 环境与拟音轨（13 份 · `PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `door_knock_1.wav` | `sfx` | 0.28s | `tower:knock1:<sid>` | 门外主动轻叩第 1 声 |
| `door_knock_2.wav` | `sfx` | 0.28s | `tower:knock2:<sid>` | 门外主动轻叩第 2 声 |
| `door_reply_1.wav` | `sfx` | 0.30s | `tower:reply1:<sid>` | 门内隔厚木门回叩第 1 声（闷沉低通质感） |
| `door_reply_2.wav` | `sfx` | 0.30s | `tower:reply2:<sid>` | 门内隔厚木门回叩第 2 声 |
| `door_open.wav` | `sfx` | 1.08s | `tower:door_open:<sid>` | 抽闩与厚木塔门木枢吱呀敞开 |
| `book_open.wav` | `sfx` | 0.68s | `tower:book_open:<sid>` | 宋明冷素宣纸收籍簿摊开与纸页摩挲 |
| `brush_write_1.wav` | `sfx` | 0.84s | `tower:brush1:<sid>` | 守卒落笔书写第一行「肆拾壹 · 小满」 |
| `brush_write_2.wav` | `sfx` | 0.88s | `tower:brush2:<sid>` | `M03` 落笔写满第二行「肆拾贰 · 周戍」 |
| `lamp_move.wav` | `sfx` | 0.78s | `tower:lamp_move:<sid>` | `F03` 守卒端起提灯稳搁西窗台（铜柄轻响 + 木台落位） |
| `needle_case_place.wav` | `sfx` | 0.58s | `tower:needle_place:<sid>` | `M03` 小满解下黄铜指南针布套轻搁木案 |
| `bowl_set.wav` | `sfx` | 0.48s | `tower:bowl_set:<sid>` | 粗瓷热碗轻搁案沿温润瓷响 |
| `tower_wind_cold.wav` | `wind` | 22.00s（零接缝） | `loop:tower_wind_cold` | 北塔门廊拂晓山风无缝循环 |
| `tower_room_warm.wav` | `ambience` | 22.00s（零接缝） | `loop:tower_room_warm` | 值夜室油灯炭火暖意与窗外远风低通透入无缝循环 |

## 2. 人声轨（2 份 · `NEURAL_VOICE_PLACEHOLDER` · 支持同名覆盖替换真人干声）

| 文件 | 逻辑音轨 | 时长 | 对应镜号 | 原文台词 / 角色声学定位 |
| --- | --- | --- | --- | --- |
| `line_xiaoman_lamp.wav` | `voice` | 2.31s | `F03`（约 4.40s） | 小满（值夜室近场柔声）：「朝西那盏灯，能留着吗？」 |
| `line_zhoushu_name.wav` | `voice` | 0.76s | `M03`（约 4.30s） | 周戍（沉稳平和微带风霜）：「周戍。」 |
