# 《向西守望》2026 开源游戏开发大赛 · 发版与 AtomGit 同步指南

> 对应赛事：**2026 开源游戏开发大赛（OSGJ）**
> 关键节点：`2026-11-28 00:00` 开放作品提交 · `2026-12-06 23:59` 集中开发截止 · `2026-12-27 23:59` 原子派社区点赞公示截止

## 一、全平台发行矩阵（一次发版同时满足主赛道、KTR 掌机赛道与 Dora 开源社区奖）

工作流自动生成并校验四端产物（均随包附带根 [Apache-2.0 LICENSE](../LICENSE) 与 [AI 使用与素材声明](AI使用与素材声明.md)）：

1. **`WestwardWatch-<ver>-windows-x64.zip`**（**主赛道主推**，`.github/workflows/release-windows.yml`）：Windows 10/11 Direct3D 12 绿色便携包，禁用 Web IDE，写入独立 `dora-game-id`，解压后双击 `WestwardWatch.exe` 或 `启动-向西守望.cmd` 即可游玩。
2. **`WestwardWatch-<ver>-windows-x64-opengl.zip`**（**主赛道兼容兜底**）：Windows 10/11 OpenGL 绿色便携包，供不支持 Direct3D 12 的老旧核显或虚拟机使用。
3. **`WestwardWatch-<ver>-dora-source.zip`**（**Dora 开源社区奖 / KTR 掌机专供**）：含 `init.ts`、`init.lua`、`LICENSE`、`Script/`、`assets/` 与 `Dora平台运行说明.md`，可直接在 Dora SSR v1.10.2 / Dora Go 跨平台打开运行。
4. **`WestwardWatch-<ver>-android-arm64.apk`**（**Android 独立签名 APK**，`.github/workflows/release-android.yml`）：支持横竖屏自由切换与 16KB 页对齐，含统一北塔图标与开机品牌序幕。
5. **Web 在线版 & 离线 HTML 包**（`.github/workflows/deploy-web.yml` / `node tools/export-html.mjs --mode both`）：GitHub Pages 在线试玩与本地离线启动包。

## 二、触发自动构建与 GitHub Release

### 方式 1：手动触发试玩候选版（RC）
在 GitHub 仓库 `Actions -> Release Windows Portable Packages -> Run workflow`：
- `version`：填写如 `v0.1.0-rc1`（留空自动生成 `dev-<sha>`）；
- `publish_release`：勾选 `true` 即可在通过 Windows 冷启动冒烟测试后自动发布预发行版（Prerelease）。

### 方式 2：打正式 Tag 发版
```bash
git fetch origin --prune
git tag -a v1.0.0 origin/main -m "release: 《向西守望》v1.0.0 参赛正式版"
git push origin v1.0.0
```
推送 `v*` Tag 后，CI 将自动执行：
1. `check-repo.py` + `audit-assets.py`（全资产存在与中文字库 0 缺字校验）；
2. 下载并校验官方 Dora SSR `v1.10.2` 运行时哈希，组装三件套；
3. 在 `windows-latest` Runner 解压至**含中文与空格的路径**，实测默认隔离存档模式与纯绿色 `save/` 便携存档模式双轮冷启动与正常退出；
4. 全部通过后自动创建 GitHub Release 并上传三件套与 `SHA256SUMS.txt`。

## 三、同步至 AtomGit（大赛硬性要求）

大赛规定所有参赛项目必须在 **AtomGit** 建立仓库并提交对应的版本标识与可运行发行版：

```bash
# 1. 在 AtomGit 创建公开仓库（申请 Dora 开源社区奖必须开源）后添加远端
git remote add atomgit https://atomgit.com/<你的命名空间>/<仓库名>.git

# 2. 同步主干分支与版本 Tag
git fetch origin --prune
git push atomgit origin/main:refs/heads/main
git push atomgit refs/tags/v1.0.0

# 3. 从 GitHub Release 下载三件套与 SHA256SUMS.txt，上传至 AtomGit 对应 Tag 的 Release 页面
gh release download v1.0.0 --dir /tmp/osgj-release
```

## 四、大赛最终提交核对清单（个人中心 → 作品提交）

- [x] **开源许可证与 AI 声明**：仓库根目录已提交 `LICENSE`（Apache-2.0）并纳入四端打包白名单，已核对定稿 [AI使用与素材声明.md](AI使用与素材声明.md)。
- [ ] **26 条真人配音替换占位人声**：按 `assets/audio/README.md` 与 `docs/向西守望-剧情与剧本.md` 录制替换 `PLACEHOLDER_VOICE` WAV（待配音完成，音频总线由 `feature/audio-overhaul` 统一接入）。
- [ ] **AtomGit 仓库与版本标识**：公开仓库链接 + `v1.0.0` Tag / Release，上传 Windows 双后端 ZIP、Dora 源码包、Android APK 与 `SHA256SUMS.txt`。
- [ ] **多端真机验收**：在真实 Windows 10/11、Android 手机/平板与 KTR 掌机完成冷启动、三模操控、全屏/横竖屏切换、音频播放、双通关存档与正常退出复核。
- [ ] **5 分钟内演示视频**：实机录制核心双线玩法、风台数到二十、慢时连线换弹、片尾史话与博物馆彩蛋，同步发布至 B 站并附指定大赛话题。
- [ ] **≥ 3 篇不重复开发者日志**：从 `origin/docs/dev-log-2026-11-26` 分支的 `docs/dev-log/` 挑选提炼。
- [ ] **Dora 开源社区奖（可选必冲）**：将兼容 Dora SSR v1.10.2 的开源版本上架**原子派社区**（注意正式参赛仍须走大赛个人中心通道），于 `12-27 23:59` 前完成 ≥ 20 个点赞与审核。
- [ ] **3 人默认设置盲测与时长记录**：用 Windows 便携包完成至少 3 位首次试玩者盲测并记录体验反馈与调整项。
