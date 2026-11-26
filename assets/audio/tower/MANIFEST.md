# `assets/audio/tower/` 分轨音频资产与占位清册（`fe-05`）

本目录存放 `feature/fe-05-dual-endings`（北塔双结局同机位配对演出 `F03` / `M03`）的全部离线分轨音频。全部 WAV 均为 16 kHz / 16-bit PCM 单声道原创程序化合成，无第三方版权限制，完整适配 `AudioDirector` 五轨分类（`voice` / `wind` / `water` / `ambience` / `sfx`）及离线打包清单（`tools/make-windows-pack.sh` 已包含 `assets/audio/`）。

## 1. 环境与拟音轨（`PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `door_knock_1.wav` | `sfx` | `0.88` | `tower:knock1:<sid>` | 门外主动轻叩第 1 声（对齐后端 `tower-knock` 第 0 拍 / `knock count=1`） |
| `door_knock_2.wav` | `sfx` | `0.90` | `tower:knock2:<sid>` | 门外主动轻叩第 2 声（对齐后端 `tower-knock` 第 12 拍 / `knock count=2`） |
| `door_reply_1.wav` | `sfx` | `0.78` | `tower:reply1:<sid>` | 门内隔一息回叩第 1 声（较厚木门闷沉质感，约 0.42s） |
| `door_reply_2.wav` | `sfx` | `0.80` | `tower:reply2:<sid>` | 门内隔一息回叩第 2 声（约 0.54s，紧接推门） |
| `door_open.wav` | `sfx` | `0.84` | `tower:door_open:<sid>` | 抽闩与厚木塔门吱呀敞开（对齐 `tower-given` 起点 0.60s） |
| `book_open.wav` | `sfx` | `0.82` | `tower:book_open:<sid>` | 值夜室案头宋明冷素宣纸收籍簿摊开与翻纸声（约 1.55s） |
| `brush_write_1.wav` | `sfx` | `0.80` | `tower:brush1:<sid>` | 守卒落笔书写第一行「肆拾壹 · 小满」（约 2.30s） |
| `brush_write_2.wav` | `sfx` | `0.82` | `tower:brush2:<sid>` | `M03` 男主线从同一悬停笔尖落笔写满第二行「肆拾贰 · 周戍」（约 4.65s） |
| `lamp_move.wav` | `sfx` | `0.82` | `tower:lamp_move:<sid>` | `F03` 女主线守卒端起案头提灯稳稳搁至西窗台（约 5.25s） |
| `needle_case_place.wav` | `sfx` | `0.80` | `tower:needle_place:<sid>` | `M03` 男主线小满解下腕上黄铜指南针布套轻搁木案（约 5.55s） |
| `bowl_set.wav` | `sfx` | `0.82` | `tower:bowl_set:<sid>` | 粗瓷热碗轻搁案沿 / 小满双手端碗轻响（`F03` 约 4.45s / `M03` 约 6.05s） |
| `tower_wind_cold.wav` | `wind` | `0.36 → 0.14` | `loop:tower_wind_cold` | 北塔门廊拂晓山风无缝循环（入室后压低至背景，西窗外仍留微风） |
| `tower_room_warm.wav` | `ambience` | `0.00 → 0.34` | `loop:tower_room_warm` | 值夜室灯火与炉火静谧暖意无缝循环（开门入室后渐入） |

## 2. 人声占位轨（`PLACEHOLDER_VOICE` · 待后期替换为真人干声）

当前为极克制的柔声节律占位 WAV，保证离线可听与 `AudioDirector.getPlayLog()` 全链路断言闭环；后期录完真人干声后按同名覆盖即可零代码生效：

| 文件 | 逻辑音轨 | 默认增益 | 对应镜号 / 时间 | 原文台词 / 替换要求 |
| --- | --- | --- | --- | --- |
| `line_xiaoman_lamp.wav` | `voice` | `0.86` | `F03`（约 4.40s） | 小满：「朝西那盏灯，能留着吗？」（轻声、克制、微带期盼，时长约 2.0s） |
| `line_zhoushu_name.wav` | `voice` | `0.90` | `M03`（约 4.30s） | 周戍：「周戍。」（沉稳平和、略带沙哑的亲口报姓名，时长约 0.9s） |
