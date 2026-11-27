# `assets/audio/museum/` 双通关深井与现代纪念展厅分轨音频清册（`fe-06` · `audio-overhaul` 48 kHz 立体声重制）

本目录存放双通关后院深井与现代抗日纪念展厅（`E01–E02`）的全部 11 份分轨音频。全部已升级为 **48 kHz / Stereo / 16-bit PCM WAV**，其中石井滴水采用圆柱共振腔卷积混响（`E_WELL`）、现代展厅采用 2.3s 高顶石材大厅混响（`D_HALL`），精确塑造明初与现代的时空声学反差。

## 1. 环境与拟音轨（10 份 · `PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- |
| `well_drip_loop.wav` | `water` | 18.00s（零接缝） | `fe06_well_drip` | 古深石井非等距物理气泡滴水与强圆柱腔共鸣 |
| `artifact_pickup.wav` | `sfx` | 0.92s | `fe06:e01:pickup:<sid>` | `E01` 井水涟漪 + 黄铜指南针/时间穿梭器清脆铜鸣 |
| `match_cut_transition.wav` | `ambience` | 1.55s | `fe06:e01:matchcut:<sid>` | `E01` 井水反光匹配剪辑：古井共振淡收、冷寂展厅空间展开 |
| `hall_ambience_loop.wav` | `ambience` | 24.00s（零接缝） | `fe06_hall_ambience` | `E02` 现代抗日纪念展厅克制冷寂高顶空气底噪 |
| `hall_footstep.wav` | `sfx` | 3.34s | `fe06:e02:step:<sid>:<n>` | `E02` 大理石展厅克制轻步与自然 2.3s 建筑混响尾 |
| `weapon_holster.wav` | `sfx` | 0.48s | `fe06:e02:holster:<sid>` | `E02` 玻璃展柜前自动收起随身器物的布帛轻响 |
| `child_steps_echo.wav` | `sfx` | 1.85s | `fe06:e02:child_echo:<sid>` | `E02` 玻璃柜后远方传来的四步孩童轻脚步高顶回响 |
| `lamp_turn.wav` | `sfx` | 0.60s | `fe06:e02:lamp_turn:<sid>` | `E02` 末厅亲手转动西窗展灯的金属旋轴与阻尼落位 |
| `knock_hall_first.wav` | `sfx` | 3.40s | `fe06:e02:knock1:<sid>` | `E02` 现代展厅内第一声轻叩（含完整 2.3s 高顶大理石回响） |
| `knock_cabinet_second.wav` | `sfx` | 0.28s | `fe06:e02:knock2:<sid>` | `E02` 隔 0.42s 切回明初厚木厨柜板的干涩近场实木叩响（极致时空反差） |

## 2. 人声轨（1 份 · `NEURAL_VOICE_PLACEHOLDER` · 支持同名覆盖替换真人干声）

| 文件 | 逻辑音轨 | 时长 | 触发位置 / 去重键 | 原文台词 / 角色声学定位 |
| --- | --- | --- | --- | --- |
| `line_dawn.wav` | `voice` | ~2.05s | `fe06:e02:line_dawn:<sid>` | 周戍（展厅 2.3s 柔光混响温和低语）：「小满，外头天亮了。」 |
