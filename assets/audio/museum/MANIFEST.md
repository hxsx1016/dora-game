# `assets/audio/museum/` 分轨音频清册与替换说明（`fe-06`）

本目录存放 `feature/fe-06-well-museum`（双通关后院深井与现代抗日主题博物馆 `E01–E02`）的全部分轨音频。所有素材均为离线程序化合成的 **22050 Hz / 16-bit PCM 单声道 WAV**，无外部版权限制，符合 `AudioDirector` 逻辑音轨分类（`water` / `ambience` / `sfx` / `voice`），并已自动覆盖于 `tools/make-windows-pack.sh` 的 `assets/audio/` 打包目录中。

## 1. 环境与拟音轨（`PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 默认增益 | 触发位置 / 去重键 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `well_drip_loop.wav` | `water` | 3.20s（无缝循环） | `0.08–0.46`（随距离衰减） | `fe06_well_drip` | `well_open` 双通关后院深井低频石壁滴水回响，零浮签吸引玩家走近 |
| `artifact_pickup.wav` | `sfx` | 0.62s | `0.86` | `fe06:e01:pickup:<sid>` | `E01` 井水微涟 + 黄铜指南针/时间穿梭器清脆轻鸣 |
| `match_cut_transition.wav` | `ambience` | 1.35s | `0.78` | `fe06:e01:matchcut:<sid>` | `E01` 同点反光匹配剪辑：井水混响淡收并转入现代展厅冷寂空气感 |
| `hall_ambience_loop.wav` | `ambience` | 4.00s（无缝循环） | `0.34` | `fe06_hall_ambience` | `E02` 现代抗日纪念展厅极克制的静谧空间底噪 |
| `hall_footstep.wav` | `sfx` | 0.18s | `0.46` | `fe06:e02:step:<sid>:<n>` | `E02` 展厅石材地面克制轻步声 |
| `weapon_holster.wav` | `sfx` | 0.34s | `0.76` | `fe06:e02:holster:<sid>` | `E02` 行至玻璃展柜前自动收起随身器物的布帛轻响 |
| `child_steps_echo.wav` | `sfx` | 1.35s | `0.72` | `fe06:e02:child_echo:<sid>` | `E02` 玻璃柜后远方传来的四步孩童轻脚步回响（单次去重） |
| `lamp_turn.wav` | `sfx` | 0.48s | `0.82` | `fe06:e02:lamp_turn:<sid>` | `E02` 末厅亲手转动西窗展灯时的金属旋轴轻转与落位声 |
| `knock_hall_first.wav` | `sfx` | 0.36s | `0.88` | `fe06:e02:knock1:<sid>` | `E02` 现代展厅内第一声轻叩（带柔和室内反射余韵） |
| `knock_cabinet_second.wav` | `sfx` | 0.28s | `0.92` | `fe06:e02:knock2:<sid>` | `E02` 隔约 0.42s 落在明初厚木厨柜板上的第二声实木叩响 |

## 2. 人声占位轨（`PLACEHOLDER_VOICE` · 支持同名覆盖替换真人干声）

| 文件 | 逻辑音轨 | 时长 | 默认增益 | 触发位置 / 去重键 | 原文台词 / 替换要求 |
| --- | --- | --- | --- | --- | --- |
| `line_dawn.wav` | `voice` | 1.55s | `0.92` | `fe06:e02:line_dawn:<sid>` | 周戍：「小满，外头天亮了。」（克制温和低语，后期录完真人配音按同名覆盖即可零代码生效） |
