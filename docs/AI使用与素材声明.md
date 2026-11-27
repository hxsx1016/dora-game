# 《向西守望》AI 使用与素材来源声明（2026 开源游戏开发大赛）

> 本文档用于 2026 开源游戏开发大赛（OSGJ）作品提交合规申报。提交前请团队负责人对照最终定稿版本核对真人配音替换状态、许可证选择及视频/宣传物料归属。

## 一、AI 辅助创作声明

本项目在 16 天线上集中开发期内（2026-11-21 至 2026-12-06）遵循「人类主导创意、架构与验收，AI 辅助编码与工程提效」的原则：

| 类别 | 使用的工具 / 模型 | 使用范围与人工介入说明 |
| --- | --- | --- |
| 世界观、剧情、双线结构与关卡策划 | 人类团队原创 + AI 对话润色与文档整理 | 故事背景（明初温州宁村所 / 抗倭守城历史脉络）、双线对称叙事、80% 血量分流、慢时连线换弹、双通关水井与现代纪念展厅的核心设计均由团队主导定稿 |
| TypeScript / Lua 游戏代码与前端渲染 | Codex / Claude / Gemini 编码智能体辅助生成与重构 | 架构拆单、接口契约（`Script/watch/fe/contract.ts`）、跨分支合流、冲突裁决与 18+ 组引擎自动化回归验收均由人类审核与把关 |
| 自动化测试、CI 与打包流水线 | 编码智能体辅助编写 | `tools/verify-*.lua`（含 `verify-remediation.lua` / `verify-audio.lua`）、`tools/audit-assets.py`、`tools/audit-audio.py`、`tools/make-windows-pack.sh`、`tools/make-android-pack.sh`、`tools/patch-android-apk.py`、`tools/export-html.mjs`、`tools/make-dora-source-pack.sh` 及 `.github/workflows/{repository,release-windows,release-android,deploy-web}.yml` 等工程脚本经本地与 CI 实测通过 |
| 美术素材与品牌标识 | Codex / Antigravity 图像生成辅助绘制像素底稿 + 离线像素化降采样/限色/透明抠底 + 人工修图/分层重构/水墨 UI 绘制 | 场景背景图、41 张像素幻灯片分镜（`assets/art/slides/`）、62 帧扩展像素精灵图集（`assets/art/sprites_fe.{png,clip}`）与明代像素角色基础图均经像素网格对齐、限色重采样与逐帧质检（完整记录见 [art-source/SOURCES.md](../art-source/SOURCES.md)）；水墨 UI 图集为项目内设计绘制；团队「局外人」主导定稿 G2 水墨题签主标、I2 北塔图标、T2 团队标与 16:9 封面 |
| 原创配乐、音效与人声轨 | 开源采样音源（FluidSynth + MuseScore General MIT）+ Python 物理建模 DSP 离线合成 + 神经语音（Edge-TTS）角色声学精修 | 全部 196 份 48 kHz 立体声音频资产均离线生成并入库，经 `tools/audit-audio.py` 与 `tools/verify-audio.lua` 全量声学与引擎验收；26 份人声轨保持同名路径，支持随时零代码替换为真人录音 |

## 二、开源引擎与第三方依赖

| 名称 | 版本 | 许可证 | 用途 | 来源 |
| --- | --- | --- | --- | --- |
| Dora SSR（桌面 / Android / Web 运行时） | v1.10.2 | MIT License | 跨平台开源游戏引擎，提供 Windows x64（D3D12/OpenGL）、Android APK 模板（`dora-ssr-v1.10.2-android.zip`）与 Web Player WASM（`web-ide-files.zip`）独立运行时 | `https://github.com/IppClub/Dora-SSR` |
| TypeScriptToLua（内置于 Dora SSR Web IDE） | 随 Dora SSR v1.10.2 | MIT License | 将 `init.ts` 与 `Script/watch/**/*.ts` 编译为 Lua | 随引擎提供 |
| 引擎内置 `sarasa-mono-sc-regular` | 随 Dora SSR v1.10.2 | SIL OFL 1.1 | 灰盒调试与护送试炼等宽字体 | 随引擎提供（详见包内 `LICENSES`） |
| MuseScore General SoundFont (`MuseScore_General.sf3`) | v0.2 | MIT License | 离线渲染原创配乐分轨（弦乐、洞箫、大管、竖琴、钢琴），不随游戏包分发 | `https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/` |
| FluidSynth（离线渲染工具） | v2.4.8 | LGPL-2.1 | 仅用于开发期离线将原创 MIDI 乐谱渲染为音频，不随游戏包分发 | `https://github.com/FluidSynth/fluidsynth` |
| Xiph.org `vorbis-tools` (`oggenc`) | v1.4.3 | BSD / GPL | 仅用于开发期离线编码 48 kHz OGG Vorbis 音频文件 | `https://xiph.org/vorbis/` |

## 三、字体、美术与音频素材清单

### 1. 第三方开源字体（保留原许可证文件随包分发）
| 文件路径 | 字体名称 | 许可证 | 许可证文件 |
| --- | --- | --- | --- |
| `assets/font/lxgw-neo-zhisong.ttf` | 霞鹜新致宋（LXGW Neo ZhiSong） | SIL OFL 1.1 | [OFL-LXGW-NeoZhiSong.txt](../assets/font/OFL-LXGW-NeoZhiSong.txt) |
| `assets/font/longcang-brush.ttf` | 龙藏体（Long Cang） | SIL OFL 1.1 | [OFL-LongCang.txt](../assets/font/OFL-LongCang.txt) |

### 2. 美术资源（`assets/art/` 与 `art-source/`）
- 灰盒全面重制美术包（Phase 1–3）：含明代微缩场景 8 材质图集（`tex_diorama_ming`）、五大微缩场景立牌与三大过场全幅 CG（`diorama_cutouts`、`cutscene_cuff_rig`、`cutscene_story_parts`、`cutscene_well_museum`、`cg_g05_reunion.png`、`cg_tower_desk_cold.png`、`cg_tower_desk_warm.png`、`bg_museum_hall.png`），以及 2.5D 明代道具/拾取/精英敌人/双人合体/火药特效图集（`props_ming`、`actors_extra`、`vfx_craft_art`）与四幅新增战役底图（`bg_crossroad_drygoods.png`、`bg_archway_yard.png`、`bg_granary.png`、`bg_escort_ridge.png`），均为项目内 AI 辅助生图后经离线去底、连通域质检、脚底基线校准与 `.clip` 图集打包，无第三方商业版权限制。
- 场景背景图（`prologue.png`、`street.png`、`checkpoint.png`、`gate.png`、`outside.png`、`village.png`、`forest.png`、`tower.png`、`title.png`）与角色精灵表（`sprites.png`/`sprites.clip`）在开发期内采用 Codex 内置 ImageGen 辅助生成并经团队手工二次像素整理、坐标裁切与风格统一；像素幻灯片分镜集（`assets/art/slides/*.png`，41 张）与扩展像素精灵图集（`assets/art/sprites_fe.png`/`sprites_fe.clip`，62 帧）经 AI 底稿生成、像素限色降采样、透明抠底与手工像素特效补绘制成；水墨 UI 图集（`ui_ink.png`/`ui_ink.clip`）为项目内程序/手工创作整理，均无未授权商业素材，详情见 [art-source/SOURCES.md](../art-source/SOURCES.md)。
- 品牌与多端图标资产（`assets/art/brand/` 与 `art-source/brand/`）：包含《向西守望》G2 横版/竖版水墨题签主标、I2 暗夜北塔西窗 1:1 应用图标（及 Windows `.ico` / Android `ic_launcher_512.png` / Web `favicon` 派生集）、「局外人（OUTSIDER）」T2 六边暖灯团队标（暗底/紧凑角标）及 16:9 宣传封面，均为团队设计定稿并由 AI 辅助生成后经程序透明抠底与人工质检产出，无第三方版权限制。

### 3. 音频资源（`assets/audio/`，共 196 份 48 kHz 立体声离线资产：24 份 OGG Vorbis + 172 份 WAV）
全部配乐与拟音均为本项目原创编曲与物理建模离线合成，无第三方商业版权限制；26 份人声轨采用 Microsoft Edge-TTS 中文神经语音离线生成并经角色声学与空间混响精修，保留原路径随时可零代码替换为真人录配音。分目录清册如下：

| 目录 | 数量 | 格式 | 类型 | 清册文件 |
| --- | --- | --- | --- | --- |
| `assets/audio/bgm/` | 16 份 | 48 kHz Stereo OGG (`-q 8`) | 全套 15 首原创配乐（含北塔双结局 F03/M03 分岔版） | [MANIFEST.md](../assets/audio/bgm/MANIFEST.md) |
| `assets/audio/ambience/` | 8 份 | 48 kHz Stereo OGG (`-q 8`) | 新增全场景零接缝长环境循环（含城门绞盘与暗渠滴水） | [MANIFEST.md](../assets/audio/ambience/MANIFEST.md) |
| `assets/audio/gate/` | 30 份 | 48 kHz Stereo WAV | 城门风台环境拟音 + 22 份数数/送别/重逢人声轨 | [MANIFEST.md](../assets/audio/gate/MANIFEST.md) |
| `assets/audio/combat/` | 40 份 | 48 kHz Stereo WAV | 火铳/奇器差异化、三材质掩体挡弹、五声换弹、工台与守门拟音 | [SOURCES.md](../assets/audio/combat/SOURCES.md) |
| `assets/audio/foley/` | 23 份 | 48 kHz Stereo WAV | 周戍/小满/拾荒者步声、翻滚跳落、投瓶、恶犬追击与恐惧拟音 | [MANIFEST.md](../assets/audio/foley/MANIFEST.md) |
| `assets/audio/interact/` | 16 份 | 48 kHz Stereo WAV | 拾取分类、木楔/残盾/快装/窗板/木帘/横闩/工台与指南针交付 | [MANIFEST.md](../assets/audio/interact/MANIFEST.md) |
| `assets/audio/ui/` | 11 份 | 48 kHz Stereo WAV | 宋明水墨宣纸/竹简/算珠/古琴泛音/更梆/铜磬 UI 交互音 | [MANIFEST.md](../assets/audio/ui/MANIFEST.md) |
| `assets/audio/child/` | 14 份 | 48 kHz Stereo WAV | 小满单人线四房零接缝环境循环、木轮车与三材质投瓶拟音 | [MANIFEST.md](../assets/audio/child/MANIFEST.md) |
| `assets/audio/tower/` | 15 份 | 48 kHz Stereo WAV | 北塔双结局环境、叩门、写簿、放灯与 2 份结局人声轨 | [MANIFEST.md](../assets/audio/tower/MANIFEST.md) |
| `assets/audio/museum/` | 11 份 | 48 kHz Stereo WAV | 双通关石井滴水、现代纪念展厅高顶回响与 1 份终幕人声轨 | [MANIFEST.md](../assets/audio/museum/MANIFEST.md) |
| `assets/audio/prologue/` | 11 份 | 48 kHz Stereo WAV | 共同序章 P01–P04 远火、床板、撞门、滚碗、心跳与 1 份父亲人声轨 | [MANIFEST.md](../assets/audio/prologue/MANIFEST.md) |
| `assets/audio/sfx/` | 1 份 | 48 kHz Stereo WAV | 通用厚木门板/侧墙轻叩声 | [MANIFEST.md](../assets/audio/sfx/MANIFEST.md) |

> 注：以上合计 `16 + 8 + 30 + 40 + 23 + 16 + 11 + 14 + 15 + 11 + 11 + 1 = 196` 份音频文件（含新增 3 条奇器/残影战斗扩展音轨），均经 `python3 tools/audit-audio.py` 全量采样率/削波/零接缝审计与 `tools/verify-audio.lua` 引擎实机回放验证通过。

## 四、合规核对提醒（最终提交前勾选）

- [x] 已在仓库根目录添加开源许可证文件 [LICENSE](../LICENSE)（**Apache License 2.0**），并纳入 Windows 便携包、Android APK、Web 包与 Dora 源码包随包分发。
- [ ] 如最终版本决定将 26 份神经语音（Edge-TTS）人声轨替换为真人录配音，请按同名路径覆盖 WAV 并更新上表配音成员署名。
- [ ] 如演示视频（B 站）使用额外背景音乐，请在视频简介与本声明中补充来源与授权。
