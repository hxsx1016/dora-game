# `assets/audio/interact/` 交互、拾取、机关与工台音效清册（`feature/audio-overhaul`）

本目录覆盖 `AudioDirector` 补齐接线的全部 `interactUsed`、`pickup`、`benchOpen/Close/Equip` 与 `P03` 指南针交付事件。全部为 **48 kHz / Stereo / 16-bit PCM WAV**。

| 文件名 | 逻辑音轨 | 时长 | 对应事件与声学质感 |
| --- | --- | --- | --- |
| `pickup_wood.wav` | `sfx` | 0.28s | `pickup`（木楔/木料/松木零件）：干松木轻叩两响 |
| `pickup_bell.wav` | `sfx` | 0.52s | `pickup`（铜铃/铜扣等铜件）：清越明代小铜铃轻颤 |
| `pickup_gear.wav` | `sfx` | 0.32s | `pickup`（军粮/药包/布带等常规补给）：粗麻包与木扣轻响 |
| `pickup_rejected.wav` | `sfx` | 0.20s | `pickup`（背包满/重复拒绝）：克制闷木轻叩提示 |
| `wedge_craft_loop.wav` | `sfx` | 0.72s | `interactUsed`（削制木楔）：木屑削切与木块轻敲 |
| `wedge_place.wav` | `sfx` | 0.56s | `interactUsed`（`wedge` 钉入木楔）：三记渐稳木楔落槽 |
| `shield_deploy.wav` | `sfx` | 0.52s | `interactUsed`（`shield` 架设木铁残盾）：敦实墩地与铁边轻震 |
| `ammo_quickload.wav` | `sfx` | 0.48s | `interactUsed`（`ammo` 弹药箱快装）：油纸撕开与金属落膛 |
| `pass_signal.wav` | `sfx` | 0.46s | `interactUsed`（`pass` 腰牌通行暗号）：竹木腰牌清越两叩 |
| `window_board_drop.wav` | `sfx` | 0.78s | `interactUsed`（`window` 布行降窗板）：厚木板滑落轰咚卡死 |
| `curtain_lower.wav` | `sfx` | 0.92s | `interactUsed`（`curtain` 军粮棚放木帘）：铁环抽脱、滑绳呼啦与重木帘落地 |
| `latch_raise.wav` | `sfx` | 0.66s | `interactUsed`（`latch` 抬起横闩）：厚木铁横闩脱槽抬起 |
| `bench_open.wav` | `sfx` | 0.52s | `benchOpen`：工台宣纸图谱摊开与木案轻触 |
| `bench_close.wav` | `sfx` | 0.32s | `benchClose`：收合图谱柔和纸响 |
| `bench_equip.wav` | `sfx` | 0.46s | `benchEquip`：披挂/装配新器物的皮带、木托与金属卡扣声 |
| `compass_handover.wav` | `sfx` | 0.64s | `P03` 柜边递交黄铜指南针布套：粗布轻递与微不可察的铜壳一颤 |
