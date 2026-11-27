# `assets/audio/prologue/` 序章分轨音频清册（`audio-overhaul` 48 kHz 立体声重制）

本目录存放共同序章 `P01–P04`（`Script/watch/fe/cutscenes/prologue_intro.ts`）全部分轨音频。全部 11 份素材已升级为 **48 kHz / Stereo / 16-bit PCM WAV**，100% 保持原路径兼容。

## 1. 环境与拟音轨（10 份 · `PROCEDURAL_SFX`）

| 文件 | 逻辑音轨 | 时长 | 用途与触发点 |
| --- | --- | --- | --- |
| `night_distant_fire.wav` | `ambience` | 22.00s（零接缝） | 城破前夜远火噼啪、夜风与极远更梆底噪 |
| `bed_creak.wav` | `sfx` | 0.68s | `P01` 小满从木床惊醒时的旧木床板承重吱呀 |
| `door_commotion.wav` | `sfx` | 1.25s | `P01` 门外剧烈撞门与沉重骚动 |
| `shadow_strike.wav` | `sfx` | 0.62s | `P01` 墙影骤落时的低沉闷击 |
| `bowl_roll.wav` | `sfx` | 1.15s | `P01` 粗瓷碗滚过青砖地面的周期摇晃响 |
| `bowl_hit.wav` | `sfx` | 0.46s | `P01` 瓷碗磕碰厨柜底沿的实脆一响 |
| `heartbeat.wav` | `sfx` | 0.44s | `P02` 逃柜与隐蔽期间贴胸低沉双搏心跳 |
| `cabinet_shut.wav` | `sfx` | 0.48s | `P02` 厚木厨柜门合拢落栓声 |
| `footsteps_fade.wav` | `sfx` | 2.15s | `P02` 柜外沉重脚步由近及远并带声像横移淡去 |
| `distant_gunflash.wav` | `sfx` | 2.47s | `P04` 远街黑火药火铳闷响与砖巷漫反射长回声 |

## 2. 人声轨（1 份 · `NEURAL_VOICE_PLACEHOLDER` · 支持同名覆盖替换真人干声）

| 文件 | 逻辑音轨 | 时长 | 原文台词与替换说明 |
| --- | --- | --- | --- |
| `father_wake.wav` | `voice` | ~1.50s | 老卒父亲（低沉急促窄室混响）：「小满，快醒醒！」；录完真人干声按同名覆盖即可零代码生效 |
