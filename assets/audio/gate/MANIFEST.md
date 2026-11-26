# `assets/audio/gate/` 分轨音频资产与占位清册（`fe-01`）

本目录存放 `feature/fe-01-gate-cuff-lowpoly` 的城门风台 24 秒转景、袖口三镜与双出口分轨音频。全部文件均为 16 kHz / 16-bit PCM 单声道 WAV，离线免外部依赖且符合 `AudioDirector` 五轨分类（`voice` / `wind` / `water` / `ambience` / `sfx`）。

> 打包提示：在 `fe-07-qa-audio-pack` 更新 `tools/make-windows-pack.sh` 时，需将 `assets/audio/` 一并复制到离线包中。

## 1. 环境与拟音轨（`PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `wind_loop.wav` | `wind` | `0.18 → 0.64`（数十八至二十的每声起点降至 `0.32×`，随后渐回） | `loop:gate_wind` | 宁村所外城海风无缝循环 |
| `water_moat_loop.wav` | `water` | `0.28 → 0.52`（同风轨降音与恢复） | `loop:gate_water` | 城外护城河水声无缝循环（落门后保留） |
| `cloth_wipe_wood.wav` | `sfx` | `0.86` | `cuff:p03:wipe:<sid>` | `P03` 补线袖口拂去柜沿碎瓷的布擦木声 |
| `gate_slam.wav` | `sfx` | `0.92` | `cuff:p05:slam:<sid>` | `P05` 厚木城门落闩合拢声 |
| `knock_wall.wav` | `sfx` | `0.88 / 0.92` | `gate:rehearsal:knock:1\|2:<sid>` | `G05` 侧墙两下轻叩（正式模式复用后端 `knock` 事件） |
| `reunion_hold.wav` | `sfx` | `0.88` | `cuff:g05:clasp:<sid>` / 后端 `handHeld` | `G05` 满 0.6s 握稳掌心反馈音 |
| `reunion_release.wav` | `sfx` | `0.72` | `cuff:g05:release:<sid>:<n>` / 后端 `handRelease` | `G05` 中途松手袖口退回画边轻响 |
| `breath_soft.wav` | `voice` / `ambience` | `0.48`（第 19 声后 0.78 秒）/ `0.24`（`G04` 循环） | `gate:breath19:<sid>` / `loop:gate_breath` | 第 19 声后轻呼吸与 `G04` 静候呼吸 |

## 2. 人声占位轨（`PLACEHOLDER_VOICE` · 待后期替换为真人干声）

当前为极克制的柔声节律占位 WAV，保证离线可听、音轨可验证与 `AudioDirector.getPlayLog()` 全链路闭环；后期录完真人女声/男声后，按同名覆盖即可零代码生效：

| 文件 | 逻辑音轨 | 默认增益 | 对应拍号 / 镜号 | 原文台词 / 替换要求 |
| --- | --- | --- | --- | --- |
| `count_01.wav` – `count_10.wav` | `voice` | `0.84` | `0–479` 拍（每 48 拍一声） | 女童轻声数「一」至「十」（前十稍快，每条 ≤ 0.65s） |
| `count_11.wav` – `count_17.wav` | `voice` | `0.84` | `480–1079` 拍（约 85 拍一声） | 女童稳步数「十一」至「十七」（每条 ≤ 1.1s） |
| `count_18.wav` | `voice` | `0.80` | `1080` 拍（18s） | 贴耳上门板轻数「十八」 |
| `count_19.wav` | `voice` | `0.68` | `1260` 拍（21s） | 放轻声音数「十九」，后留呼吸空拍 |
| `count_20.wav` | `voice` | `0.96` | `1440` 拍（24s） | 清晰稳落「二十」（风/水轨自动闪避让清） |
| `line_farewell.wav` | `voice` | `0.88` | `P05` 城门送别 | 周戍：「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」 |
| `line_reunion.wav` | `voice` | `0.94` | `G05` 风台重逢 | 周戍：「我们走吧。」（仅触发一次） |
