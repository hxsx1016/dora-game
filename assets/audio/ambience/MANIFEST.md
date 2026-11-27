# `assets/audio/ambience/` 新增场景长环境循环清册（`feature/audio-overhaul`）

本目录补齐原版 13 个缺少房间环境底噪的场景，以及城门绞盘、暗渠低拱等动态环境层。全部为 **48 kHz / Stereo / OGG Vorbis（`oggenc -q 8`）** 零接缝循环资产，由 `SoundscapeDirector`（`Script/watch/fe/bgm.ts`）通过独立于 `activeLoops` 的 `sceneAmbSlots` / `menuAmbSlot` 托管播放。

| 文件名 | 逻辑音轨 | 时长 | 目标响度 | 触发位置与声学设计 |
| --- | --- | --- | --- | --- |
| `title_coastal_night_loop.ogg` | `ambience` | 28.00s | -29.0 LUFS | 标题/选章/要诀界面；温州海防夜风、远海潮汐与极远宁村所两声更梆 |
| `street_fire_ember_loop.ogg` | `ambience` | 26.00s | -28.0 LUFS | 街巷三房（`street` / `s1` / `s2` / `s3`）；远火炭屑噼啪与青砖巷穿堂夜风 |
| `checkpoint_wind_chains_loop.ogg` | `ambience` | 26.00s | -28.5 LUFS | 哨卡与军粮棚（`checkpoint` / `c1` / `c2`）；高梁冷风与远梁铁链轻碰 |
| `gate_siege_ambience_loop.ogg` | `ambience` | 24.00s | -27.0 LUFS | 城门备战与 45 秒守点（`gate-idle` / `gate-hold` / `gate-send`）；门洞回风与城外火势 |
| `gate_winch_chain_loop.ogg` | `ambience` | 12.00s | -25.5 LUFS | `gate-hold` 城门吊门拉升全程；木棘轮咬合、粗铁链绷紧与木轴吱呀（随进度渐强） |
| `escort_mountain_night_loop.ogg` | `ambience` | 28.00s | -29.0 LUFS | `gatepath` 与山道护送（`escort1/2/4/5`）及护送试炼；乱石山道夜风与荒草瑟瑟 |
| `escort_bench_lantern_loop.ogg` | `ambience` | 24.00s | -30.0 LUFS | `escort3` 山腰工台；室内提灯油芯暖意与棚外低通远风 |
| `culvert_drip_echo_loop.ogg` | `water` | 20.00s | -29.0 LUFS | 涵洞/低拱/空村暗渠/密林溪前段；窄石腔潮湿回响与物理气泡水滴 |
