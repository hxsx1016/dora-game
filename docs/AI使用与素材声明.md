# 《向西守望》AI 使用与素材来源声明（2026 开源游戏开发大赛）

> 本文档用于 2026 开源游戏开发大赛（OSGJ）作品提交合规申报。提交前请团队负责人对照最终定稿版本核对真人配音替换状态、许可证选择及视频/宣传物料归属。

## 一、AI 辅助创作声明

本项目在 16 天线上集中开发期内（2026-11-21 至 2026-12-06）遵循「人类主导创意、架构与验收，AI 辅助编码与工程提效」的原则：

| 类别 | 使用的工具 / 模型 | 使用范围与人工介入说明 |
| --- | --- | --- |
| 世界观、剧情、双线结构与关卡策划 | 人类团队原创 + AI 对话润色与文档整理 | 故事背景（明初温州宁村所 / 抗倭守城历史脉络）、双线对称叙事、80% 血量分流、慢时连线换弹、双通关水井与现代纪念展厅的核心设计均由团队主导定稿 |
| TypeScript / Lua 游戏代码与前端渲染 | Codex / Claude / Gemini 编码智能体辅助生成与重构 | 架构拆单、接口契约（`Script/watch/fe/contract.ts`）、跨分支合流、冲突裁决与 18+ 组引擎自动化回归验收均由人类审核与把关 |
| 自动化测试、CI 与打包流水线 | 编码智能体辅助编写 | `tools/verify-*.lua`、`tools/audit-assets.py`、`tools/make-windows-pack.sh`、`.github/workflows/release-windows.yml` 等工程脚本经本地与 CI 实测通过 |
| 美术与音频素材 | 原创像素与水墨美术绘制 + Python 离线程序化合成音频 | 见下方第二、三节逐项清单；人声占位轨如替换为真人干声请在终稿中更新状态 |
| 游戏与团队品牌标识 | AI 图像生成辅助 + 人类视觉把关、字形质检与透明通道/多端图标后期处理 | 团队「局外人」主导方向与终稿选型（G2 水墨题签主标、I2 北塔斜光图标、T2 六边暖灯团队标及 16:9 宣传封面），经人工逐字质检与透明通道精修后入库 `assets/art/brand/` 与 `art-source/brand/` |

## 二、开源引擎与第三方依赖

| 名称 | 版本 | 许可证 | 用途 | 来源 |
| --- | --- | --- | --- | --- |
| Dora SSR | v1.10.2 | MIT License | 跨平台开源游戏引擎与 Windows x64 独立运行时 | `https://github.com/IppClub/Dora-SSR` |
| TypeScriptToLua（内置于 Dora SSR Web IDE） | 随 Dora SSR v1.10.2 | MIT License | 将 `init.ts` 与 `Script/watch/**/*.ts` 编译为 Lua | 随引擎提供 |
| 引擎内置 `sarasa-mono-sc-regular` | 随 Dora SSR v1.10.2 | SIL OFL 1.1 | 灰盒调试与护送试炼等宽字体 | 随引擎提供（详见包内 `LICENSES`） |

## 三、字体、美术与音频素材清单

### 1. 第三方开源字体（保留原许可证文件随包分发）
| 文件路径 | 字体名称 | 许可证 | 许可证文件 |
| --- | --- | --- | --- |
| `assets/font/lxgw-neo-zhisong.ttf` | 霞鹜新致宋（LXGW Neo ZhiSong） | SIL OFL 1.1 | [OFL-LXGW-NeoZhiSong.txt](../assets/font/OFL-LXGW-NeoZhiSong.txt) |
| `assets/font/longcang-brush.ttf` | 龙藏体（Long Cang） | SIL OFL 1.1 | [OFL-LongCang.txt](../assets/font/OFL-LongCang.txt) |

### 2. 美术资源（`assets/art/` 与 `art-source/`）
- 场景背景图（`prologue.png`、`street.png`、`checkpoint.png`、`gate.png`、`outside.png`、`village.png`、`forest.png`、`tower.png`、`title.png`）与角色/道具/水墨 UI 图集（`sprites.png`/`sprites.clip`、`ui_ink.png`/`ui_ink.clip`）均为本项目在开发期内创作整理，无未授权商业素材。
- 品牌与多端图标资产（`assets/art/brand/` 与 `art-source/brand/`）：包含《向西守望》G2 横版/竖版水墨题签主标、I2 暗夜北塔西窗 1:1 应用图标（及 Windows `.ico` / Android `mipmap-*` / Web `favicon` 派生集）、「局外人（OUTSIDER）」T2 六边暖灯团队标（暗底/宣纸浅底/紧凑角标）及 16:9 宣传封面，均为团队设计定稿并由 AI 辅助生成后经程序透明抠底与人工质检产出，无第三方版权限制。

### 3. 音频资源（`assets/audio/`，共 96 份离线 WAV）
所有音频均为项目内程序化离线合成的原创 16-bit PCM WAV 素材，无第三方版权限制，分目录清册如下：

| 目录 | 数量 | 类型 | 清册文件 |
| --- | --- | --- | --- |
| `assets/audio/gate/` | 30 份 | 环境拟音 + 城门数数/送别/重逢人声占位轨 | [MANIFEST.md](../assets/audio/gate/MANIFEST.md) |
| `assets/audio/combat/` | 14 份 | 火铳、掩体挡弹、受击、背负、3×3 换弹与工台拟音 | [SOURCES.md](../assets/audio/combat/SOURCES.md) |
| `assets/audio/child/` | 14 份 | 小满单人线四房环境循环、木轮车与三材质投瓶拟音 | [MANIFEST.md](../assets/audio/child/MANIFEST.md) |
| `assets/audio/tower/` | 15 份 | 北塔双结局环境、写簿、放灯与人声占位轨 | [MANIFEST.md](../assets/audio/tower/MANIFEST.md) |
| `assets/audio/museum/` | 11 份 | 双通关井口滴水、现代展厅环境与叩响、人声占位轨 | [MANIFEST.md](../assets/audio/museum/MANIFEST.md) |
| `assets/audio/prologue/` | 11 份 | 共同序章 P01–P04 夜间远火、床板、撞门、滚碗、心跳与人声占位轨 | [MANIFEST.md](../assets/audio/prologue/MANIFEST.md) |
| `assets/audio/sfx/` | 1 份 | 通用厚木门板/侧墙轻叩声 | [MANIFEST.md](../assets/audio/sfx/MANIFEST.md) |

## 四、合规核对提醒（最终提交前勾选）

- [ ] 如拟参与 **Dora 开源社区奖**，确认仓库根目录已添加团队选定的开源许可证文件（如 `LICENSE` / MIT 或 Apache-2.0），并在 AtomGit 设为公开仓库。
- [ ] 如最终版本已将 `PLACEHOLDER_VOICE` 占位轨替换为真人录配音，请更新上表对应条目并注明配音成员。
- [ ] 如演示视频（B 站）使用额外背景音乐，请在视频简介与本声明中补充来源与授权。
