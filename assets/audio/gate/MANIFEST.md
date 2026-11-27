# `assets/audio/gate/` 分轨音频资产清册（`fe-01` · `audio-overhaul` 48 kHz 立体声重制）

本目录存放城门风台 24 秒转景、袖口三镜与双出口分轨音频。全部 30 份资产已于 `feature/audio-overhaul` 升级为 **48 kHz / Stereo / 16-bit PCM WAV**（零接缝循环 + 物理空间卷积混响 + ITU-R BS.1770-4 响度母带），100% 保持原路径零代码兼容。

## 1. 环境与拟音轨（8 份 · `PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `wind_loop.wav` | `wind` | 20.00s（零接缝） | `0.18 → 0.64`（数 18–20 自动降音） | `loop:gate_wind` | 宁村所外城海风多段风压无缝循环 |
| `water_moat_loop.wav` | `water` | 20.00s（零接缝） | `0.28 → 0.52` | `loop:gate_water` | 城外护城河冷暗流水拍石无缝循环 |
| `cloth_wipe_wood.wav` | `sfx` | 0.68s | `0.86` | `cuff:p03:wipe:<sid>` | `P03` 补线袖口拂去柜沿碎瓷的粗布擦木声 |
| `gate_slam.wav` | `sfx` | 1.45s | `0.92` | `cuff:p05:slam:<sid>` | `P05` 厚木铁包城门落闩合拢与门洞震颤 |
| `knock_wall.wav` | `sfx` | 0.28s | `0.88 / 0.92` | `gate:rehearsal:knock:1\|2:<sid>` | `G05` 侧墙两下轻叩 |
| `reunion_hold.wav` | `sfx` | 0.88s | `0.88` | `cuff:g05:clasp:<sid>` / `handHeld` | `G05` 满 0.6s 握稳掌心反馈音 |
| `reunion_release.wav` | `sfx` | 0.32s | `0.72` | `cuff:g05:release:<sid>:<n>` / `handRelease` | `G05` 中途松手袖口退回轻响 |
| `breath_soft.wav` | `voice` / `ambience` | 3.40s | `0.48`（19 后 0.78s）/ `0.24`（`G04`） | `gate:breath19:<sid>` / `loop:gate_breath` | 第 19 声后轻呼吸与 `G04` 静候呼吸 |

## 2. 人声轨（22 份 · `NEURAL_VOICE_PLACEHOLDER` · 支持同名覆盖替换为真人干声）

已由旧版单调合成占位升级为 **中文神经语音（Edge-TTS）+ 角色声学精修 + 物理空间混响**（48 kHz Stereo WAV），并精准匹配 24 秒数数节律（`count_19.wav` = 0.70s 留出 0.78s 呼吸空拍）；后期录完真人女声/男声后按同名覆盖即可零代码生效：

| 文件 | 逻辑音轨 | 默认增益 | 对应拍号 / 镜号 | 原文台词 / 角色声学定位 |
| --- | --- | --- | --- | --- |
| `count_01.wav` – `count_10.wav` | `voice` | `0.84` | `0–479` 拍（前十稍快） | 小满（8 岁女童）轻声数「一」至「十」（开阔海风混响） |
| `count_11.wav` – `count_17.wav` | `voice` | `0.84` | `480–1079` 拍（渐慢稳步） | 小满数「十一」至「十七」 |
| `count_18.wav` | `voice` | `0.80` | `1080` 拍（18s） | 贴耳上门板近场柔化轻数「十八」 |
| `count_19.wav` | `voice` | `0.68` | `1260` 拍（21s，≤ 0.70s） | 压低放轻「十九」，后留呼吸空拍接 `breath_soft.wav` |
| `count_20.wav` | `voice` | `0.96` | `1440` 拍（24s） | 清晰稳落「二十」（风/水/BGM 同步让白） |
| `line_farewell.wav` | `voice` | `0.88` | `P05` 城门送别 | 周戍：「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」 |
| `line_reunion.wav` | `voice` | `0.94` | `G05` 风台重逢 | 周戍：「我们走吧。」（仅触发一次） |
