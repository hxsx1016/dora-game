# 《向西守望》2026 开源游戏开发大赛 · 发版与 AtomGit 同步指南

> 对应赛事：**2026 开源游戏开发大赛（OSGJ）**
> 关键节点：`2026-11-28 00:00` 开放作品提交 · `2026-12-06 23:59` 集中开发截止 · `2026-12-27 23:59` 原子派社区点赞公示截止

## 一、发行三件套策略（一次发版同时满足主赛道与 Dora 开源社区奖）

工作流 `.github/workflows/release-windows.yml` 每次发版自动生成并校验以下三份 ZIP + 统一校验文件 `SHA256SUMS.txt`：

1. **`WestwardWatch-<ver>-windows-x64.zip`**（**主赛道主推**）：Windows 10/11 Direct3D 12 绿色便携包，剔除无关引擎开发文件（`www/`、`Doc/`、`dora-wa/`、`dora_godot.dll`、`wa.dll`、`GeneralUserGS.sf3`），写入独立 `dora-game-id`，解压后双击 `WestwardWatch.exe` 或 `启动-向西守望.cmd` 即可游玩。
2. **`WestwardWatch-<ver>-windows-x64-opengl.zip`**（**主赛道兼容兜底**）：Windows 10/11 OpenGL 绿色便携包，供不支持 Direct3D 12 的老旧核显或虚拟机使用。
3. **`WestwardWatch-<ver>-dora-source.zip`**（**Dora 开源社区奖专供**）：含 `init.ts`、`init.lua`、`Script/`、`assets/` 与 `Dora平台运行说明.md`，可直接在 Dora SSR v1.10.2 跨平台打开运行。

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

- [ ] **AtomGit 仓库与版本标识**：公开仓库链接 + `v1.0.0` Tag / Release，仓库根目录已确认开源许可证（`LICENSE`）。
- [ ] **可运行发行版与启动说明**：AtomGit Release 已附 `WestwardWatch-v1.0.0-windows-x64.zip`（主包）、`WestwardWatch-v1.0.0-windows-x64-opengl.zip`（兼容包）与 `WestwardWatch-v1.0.0-dora-source.zip`（Dora 平台兼容版），并附启动说明。
- [ ] **Windows 10/11 真机验收**：在真实 Windows 10/11 机器完成 720p / 1080p / 1440p 与非 16:9 窗口的冷启动、键鼠操控、全屏切换、音频播放、双通关存档与正常退出复核。
- [ ] **5 分钟内演示视频**：实机录制核心双线玩法、风台数到二十、慢时连线换弹与博物馆彩蛋，同步发布至 B 站并附指定大赛话题。
- [ ] **≥ 3 篇不重复开发者日志**：可从 `origin/docs/dev-log-2026-11-26` 分支的 `docs/dev-log/` 挑选提炼（如：2.5D 纵深与灰盒原型、双线叙事与水墨/低模双画风、Windows 便携打包与自动化冷启动验收）。
- [ ] **《AI 使用与素材声明》**：核对定稿 [AI使用与素材声明.md](AI使用与素材声明.md)。
- [ ] **Dora 开源社区奖（可选必冲）**：将兼容 Dora SSR v1.10.2 的开源版本上架**原子派社区**（注意正式参赛仍须走大赛个人中心通道），于 `12-27 23:59` 前完成 ≥ 20 个点赞与审核。
- [ ] **3 人默认设置盲测与时长记录**：用 Windows 便携包完成至少 3 位首次试玩者盲测并记录体验反馈与调整项。
