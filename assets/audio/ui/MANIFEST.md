# `assets/audio/ui/` 宋明水墨界面交互音效清册（`feature/audio-overhaul`）

本目录遵循《向西守望》宋明水墨美学，全部界面反馈均以**宣纸轻掠、竹简落案、算珠微拨、古琴徽位泛音、明代更梆与清雅铜磬**构建，绝不使用现代电子蜂鸣音。全部为 **48 kHz / Stereo / 16-bit PCM WAV**，经 `AudioDirector.playUi()` 播放（独立于局内 `playLog`，暂停态安全不污染局内音频记录）。

| 文件名 | 时长 | 目标响度 | 触发点与声学设计 |
| --- | --- | --- | --- |
| `menu_hover.wav` | 0.12s | -23.0 LUFS | 菜单光标切换/悬停：极轻宣纸指尖掠过与细微古琴高泛音 |
| `menu_confirm.wav` | 0.36s | -19.5 LUFS | 菜单项确认：温润竹简落案与单枚古琴泛音 |
| `menu_back.wav` | 0.28s | -20.5 LUFS | 返回/取消：低沉柔和纸页合拢轻拂 |
| `game_start.wav` | 1.05s | -17.0 LUFS | 开始新征程/续读存档：沉稳远更木梆一响 + 古琴深沉散音与泛音 |
| `pause_open.wav` | 0.36s | -20.5 LUFS | 打开暂停页：烟黛丝纱轻垂 |
| `pause_close.wav` | 0.30s | -20.5 LUFS | 关闭暂停继续游玩：丝纱轻扬复明 |
| `chapter_banner.wav` | 0.95s | -19.5 LUFS | 跨房卷轴横幅出现：远风拂卷与古琴单拨 |
| `talent_appear.wav` | 0.46s | -18.5 LUFS | 本领卡（三选一）浮现：三枚竹木牌由左至右轻摊 |
| `talent_pick.wav` | 0.58s | -17.0 LUFS | 选定本领（取代原借用的 `reload_solved.wav`）：朱砂印落简确认 + 双泛音 |
| `segment_clear.wav` | 0.92s | -18.5 LUFS | 关卡/波次清段达成：克制清越单枚铜磬微响 |
| `setting_toggle.wav` | 0.12s | -20.5 LUFS | 操控设置与四通道音量档位拨动：清脆算珠/竹节微拨 |
