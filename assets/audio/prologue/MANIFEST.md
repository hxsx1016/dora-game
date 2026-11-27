# `assets/audio/prologue/` 序章分轨音频清册与替换说明

本目录存放共同序章 `P01–P04`（`Script/watch/fe/cutscenes/prologue_intro.ts`）引用的全部分轨音频。全部素材均为离线程序化合成的 **22050 Hz / 16-bit PCM 单声道 WAV**，项目原创、无第三方版权限制。

## 1. 环境与拟音轨（`PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 用途与触发点 |
| --- | --- | --- | --- |
| `night_distant_fire.wav` | `ambience` | 4.00s（无缝循环） | 城破前夜远方火光劈啪与低沉夜风底噪 |
| `bed_creak.wav` | `sfx` | 0.55s | 小满从木床惊醒时的旧木床板轻响 |
| `door_commotion.wav` | `sfx` | 0.95s | 门外撞门声与急促骚动 |
| `shadow_strike.wav` | `sfx` | 0.48s | 墙影骤落时的低沉闷击 |
| `bowl_roll.wav` | `sfx` | 0.85s | 粗瓷碗滚过地面的摇晃轻响 |
| `bowl_hit.wav` | `sfx` | 0.35s | 瓷碗磕碰厨柜底沿的脆响 |
| `heartbeat.wav` | `sfx` | 0.42s | 逃柜与隐蔽期间紧促低沉的心跳脉动 |
| `cabinet_shut.wav` | `sfx` | 0.38s | 厚木厨柜门合拢落栓声 |
| `footsteps_fade.wav` | `sfx` | 1.60s | 柜外沉重脚步声由近及远淡去 |
| `distant_gunflash.wav` | `sfx` | 0.72s | `P04` 远街黑火药火铳闷响与回声 |

## 2. 人声占位轨（`PLACEHOLDER_VOICE` · 支持同名覆盖替换真人干声）

| 文件 | 逻辑音轨 | 时长 | 替换说明 |
| --- | --- | --- | --- |
| `father_wake.wav` | `voice` | 0.95s | `P01` 父亲压低声音叫醒小满的柔声节律占位；录完真人干声按同名覆盖即可零代码生效 |
