# `assets/audio/bgm/` 原创配乐清册（`feature/audio-overhaul`）

本目录存放《向西守望》全套 **15 首原创原声配乐（共 16 条音轨，含北塔双结局 F03 / M03 分岔版）**。全部为 **48 kHz / Stereo / OGG Vorbis（Xiph.org `oggenc -q 8`，≈ 256–320 kbps VBR）**，由混合管线离线渲染：

- **真实采样分轨**：`FluidSynth 2.4.8` 离线渲染开源 MIT 授权 `MuseScore_General.sf3`（含 Bank 17 表现力弦乐、洞箫 `Shakuhachi Expr.`、低音提琴、大管与毡锤柔化钢琴）；
- **物理建模古乐器**：Python 64-bit 浮点物理建模古琴（散音/徽位泛音/走手滑弦）、明代海防更梆、铜铃/铜磬与守城战鼓；
- **母带标准**：统一经 FFT 立体声卷积混响与 ITU-R BS.1770-4 响度校准（`-19.5 ~ -30.0 LUFS`，True Peak `<= -1.4 dBFS`），带前奏曲目精确对齐 `AudioSource.setLoopPoint()` 零断层循环点。

| # | 文件名 | 对应场景 / 阶段 | 时长 | `loopPoint` | 目标响度 | 调式与配器亮点 |
| --- | --- | --- | --- | --- | --- | --- |
| 01 | `splash_brand.ogg` | 开机序幕「局外人 · 向西守望」 | 4.80s（单次） | — | -20.5 LUFS | 远更木梆 → 古琴 D2 散音 → 2.20s 主标核心四音泛音（A-G-E-D）+ 暖铜磬 |
| 02 | `title_westward_watch.ogg` | 主标题 / 选章 / 要诀 | 72.00s | 8.0s | -21.5 LUFS | D 羽调；古琴「两下轻敲」散音前奏 + 洞箫陈述完整主题 + 弱音大提琴铺底 |
| 03 | `prologue_ember_night.ogg` | 共同序章 P03 柜边相认 | 48.00s | 0.0s | -23.5 LUFS | D 商调；近场古琴单音、拨弦与极轻大提琴暖意托底，为针线与低语留空 |
| 04 | `street_alley_tension.ogg` | 街巷段（`s1` / `s2` / `s3` 无缝续播） | 48.00s | 0.0s | -21.5 LUFS | D 羽调 90 BPM；低音拨弦脉冲、更梆切分、古琴走手滑弦与弦乐震音张力 |
| 05 | `checkpoint_granary.ogg` | 哨卡 / 军粮棚（`c1` / `c2` 无缝续播） | 48.00s | 0.0s | -22.5 LUFS | D 羽调 75 BPM；压迫感大管低吟、低音战鼓缓脉与洞箫远眺碎片 |
| 06 | `gate_siege_45s.ogg` | 城门 45 秒守点战（`gate-hold`） | 64.00s | 48.0s | -19.5 LUFS | 48s 三阶段推进前奏（0–16s / 16–32s / 32–48s 冲刺）+ 16s 高燃守门循环段 |
| 07 | `gate_count_drone.ogg` | 城门 24 秒数数转景（`gate-count`） | 32.00s | 0.0s | -30.0 LUFS | 极克制空五度大提琴低鸣与高八度单枚古琴泛音，第 18–20 声由引擎自动闪避至静默 |
| 08 | `reunion_hand_in_hand.ogg` | 男主线 G05 重逢牵手与 `gatepath` | 48.00s | 0.0s | -22.0 LUFS | F 宫转暖调；拨弦轻步律动 + 温润古琴与小提琴二重奏 |
| 09 | `escort_combat.ogg` | 护送战（`escort1/2/4/5`）与护送试炼 | 68.00s | 4.0s | -20.0 LUFS | 96 BPM；双拍战鼓推进、弦乐切分脉冲与洞箫昂扬主旋律 |
| 10 | `escort_craft_bench.ogg` | `escort3` 山腰工台喘息 | 40.00s | 0.0s | -23.0 LUFS | 温暖 D 宫五声；室内近场古琴与柔和竖琴/弦乐安抚，象征短暂休整 |
| 11 | `child_lone_journey.ogg` | 女主线城外栈台与空村（`outside` / `village`） | 60.00s | 0.0s | -24.5 LUFS | E 羽调疏离低模声景；空灵孤箫、高音古琴泛音与远海低弦呼吸 |
| 12 | `forest_stalk_and_creek.ogg` | 女主线密林潜行前半段（`forest` x < 1140） | 48.00s | 0.0s | -23.5 LUFS | 极克制低音提琴暗涌、木梆微叩与疏离大管，绝不掩盖枯枝与林犬步声提示 |
| 13 | `creek_dawn_reflection.ogg` | 密林将晓溪湾（`forest` x ≥ 1140）与北塔门廊 | 48.00s | 0.0s | -22.5 LUFS | G 宫清澈曙光；竖琴水光琶音、澄净泛音与暖色弦乐渐亮 |
| 14 | `ending_f03_lamp.ogg` | 北塔女主线结局 F03「西窗留灯」 | 48.00s | 32.0s | -22.5 LUFS | 与 M03 共享前 4.20s 笔尖悬停和声；4.20s 处悬于开放五度孤箫与古琴泛音留白 |
| 15 | `ending_m03_reunion.ogg` | 北塔男主线结局 M03「二行皆满」 | 48.00s | 32.0s | -21.5 LUFS | 与 F03 共享前 4.20s；4.20s 处顺势解决至温暖 D Major (add9) 弦乐与完整四音母题 |
| 16 | `museum_dawn_peace.ogg` | 双通关现代抗日纪念展厅（`museum` E02） | 66.00s | 6.0s | -22.5 LUFS | 毡锤柔化钢琴（Felt Piano）+ 古琴泛音跨时空应答 + 展厅大混响暖弦，叩响母题收束 |
