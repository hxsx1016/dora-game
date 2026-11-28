# 《向西守望》2026 开源游戏开发大赛 · 发版与 AtomGit 同步指南

首个公开试玩计划使用 **`v0.1.0`**。GitHub Release 和 AtomGit Release 共用一个 tag、一个构建提交和同一批附件。

## 1. 玩家下载哪一个包

下表中的文件名都带有前缀 `WestwardWatch-v0.1.0-`。右栏是同一 Release 下可单独下载的 SHA-256 清单。

| 文件名后半段 | 内容与启动方法 | 校验清单 |
| --- | --- | --- |
| `windows-x64.zip` | Windows 10/11 x64，Direct3D 12。完整解压，双击 `WestwardWatch/WestwardWatch.exe`。 | `SHA256SUMS.txt` |
| `windows-x64-opengl.zip` | Windows OpenGL 兼容版，启动方式同上。 | `SHA256SUMS.txt` |
| `dora-source.zip` | Dora SSR v1.10.2 源码包，含 TS、预编译 Lua、素材及 `Dora平台运行说明.md`。解压后在 Dora 中运行 `init.lua`。 | `SHA256SUMS.txt` |
| `android-arm64.apk` | 64 位 ARM 手机或平板，触屏，支持横竖屏。 | `SHA256SUMS-android.txt` |
| `android-universal.apk` | 同一手机版，同时包含 arm64-v8a 和 armeabi-v7a。 | `SHA256SUMS-android.txt` |
| `handheld-arm64.apk` | 64 位 ARM 安卓掌机，触屏和手柄，横屏。三种 APK 共用包名，选一种安装。 | `SHA256SUMS-android.txt` |
| `web-html.zip` | 离线浏览器版。完整解压后双击根目录 `index.html`，保留同级 `html-loader.js`、`html-assets/`、引擎脚本、图标及其他随包文件。 | `SHA256SUMS-web.txt` |

Actions 的 `westward-watch-web-bundles` 保留 14 天，内含 **`WestwardWatch-<版本>-web-html.zip`、`WestwardWatch-<版本>-web-server.zip` 和 `SHA256SUMS-web.txt`**。清单仅覆盖离线 ZIP。`web-server.zip` 供 HTTP 静态托管，Pages 部署使用同一次导出的 `web-server/`。GitHub 自动生成的 Source code (zip/tar.gz) 与表内 Dora 源码包是不同的下载项。

项目代码许可、AI 使用与素材署名可在同 tag 仓库中查阅。Windows 便携包和 Dora 源码包包含根 LICENSE。[项目许可](../LICENSE) · [AI 使用与素材声明](AI使用与素材声明.md)

## 2. 从验收提交发出首个公开试玩

1. 将发行修正与游戏内容整合到要发布的提交。记录验收通过的 **40 位提交 SHA**，确认该提交含三个平台的 tag 工作流和 `.github/workflows/publish-assets.yml`。本轮核对基线为 `55826e793a38d4b27907c4d4204734c6fcb76091`，修正也必须随 tag 进入版本。
2. 需要候选包时，可在 Actions 手动运行 Windows、Android，保留 `publish_release=false`。Web 手动运行可关闭 `deploy_pages`。分支上留空版本会生成 `dev-<短SHA>`（Windows/Android）或 `web-<短SHA>`。Android 公开发布要求正式签名，仓库 Secrets 为 `ANDROID_KEYSTORE_B64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。
3. 用有推送权的账号执行以下 Bash 命令。让这次 tag push 触发三个工作流，Release 页由 CI 创建。直接用 Releases API 创建公开版本会绕过草稿组装；若从另一个 Actions 工作流推 tag，默认 `GITHUB_TOKEN` 的 push 通常不会触发下游工作流。

```bash
set -eu
repo=hxsx1016/dora-game
tag=v0.1.0
: "${RELEASE_SHA:?请先将 RELEASE_SHA 设为已验收的完整提交 SHA}"
test "$(git rev-parse "$RELEASE_SHA^{commit}")" = "$RELEASE_SHA"
git merge-base --is-ancestor 55826e793a38d4b27907c4d4204734c6fcb76091 "$RELEASE_SHA"
git tag -a "$tag" "$RELEASE_SHA" -m "《向西守望》首个公开试玩 $tag"
git push origin "refs/tags/$tag"
test "$(gh api "repos/$repo/commits/refs/tags/$tag" --jq .sha)" = "$RELEASE_SHA"
```

4. 在 Actions 查看该 tag 的 Windows、Android、Web 三次运行。Windows 校验三个 ZIP，在原生 runner 检查 OpenGL 包结构及 PE 元数据，对 D3D12 版做中文空格路径启动、便携存档及只读回退测试。Android 检查 APK 清单、签名、16 KB ZIP 对齐及分端裁剪。Web 校验白名单、资源预算、两种目录和离线加载脚本。
5. 三端独立构建，发布 job 按版本排队。各自核对远端 tag 解引用后的 commit 和本端清单，然后将附件上传到同一草稿。最后一个 job 用 GitHub 记录的资产摘要比对三份清单，七个包齐备后公开。`v0.1.0` 为普通 Release，含连字符的版本（如 `v0.1.0-rc1`）标记为预发行。构建、签名或上传失败时，到原 tag 对应的运行选择 **Re-run failed jobs**。Windows/Android 的手动补发须勾选 `publish_release`，指定已存在、指向本次构建提交的 tag。保持草稿首行的构建 SHA 以便重试。已公开版本的重跑只核对附件；内容修订使用新 tag。

**Pages 与离线试玩独立。** Web 的 `v*` tag 只构建并参与 Release。匹配路径的 PR 和两个监听分支（`main`、`exp/multi-device-adapt`）均可产出 Actions ZIP。仅 `main` push 或勾选 `deploy_pages` 的手动运行会查询仓库的 `has_pages`。为 false 时保留 ZIP 并跳过部署。要开放在线入口，由管理员在 Settings → Pages 配置 GitHub Actions 后再部署，以成功部署给出的地址为准。

## 3. 下载核验并同步 AtomGit

先从已公开的 GitHub Release 下载 **10 个附件** 到空目录。用上一步记录的 SHA 核对源 tag。以下示例适用 Bash 和 GNU coreutils，macOS 可将 `sha256sum -c` 换成 `shasum -a 256 -c`。

```bash
set -eu
repo=hxsx1016/dora-game
tag=v0.1.0
: "${RELEASE_SHA:?请使用已验收的完整提交 SHA}"
test "$(gh api "repos/$repo/commits/refs/tags/$tag" --jq .sha)" = "$RELEASE_SHA"
out=$(mktemp -d)
gh release download "$tag" --repo "$repo" --dir "$out"
(
  cd "$out"
  sha256sum -c SHA256SUMS.txt
  sha256sum -c SHA256SUMS-android.txt
  sha256sum -c SHA256SUMS-web.txt
)
echo "已校验的 AtomGit 附件目录：$out"
```

在 AtomGit 建立公开仓库，首次添加远端时将下例 URL 换成实际地址。将已验收提交推至 AtomGit 的 main，并推送同一个本地附注 tag。如目标 main 已前进且推送遭拒，先核对两端历史。以下命令不会强推。

```bash
git remote add atomgit 'https://atomgit.com/<命名空间>/<仓库名>.git'
test "$(git rev-parse "refs/tags/$tag^{commit}")" = "$RELEASE_SHA"
git push atomgit "$RELEASE_SHA:refs/heads/main" "refs/tags/$tag"
test "$(git ls-remote atomgit "refs/tags/$tag^{}" | cut -f1)" = "$RELEASE_SHA"
```

在 AtomGit 为该 tag 创建 Release，原样上传下载目录中的 7 个包和 3 份清单。从 AtomGit 下载附件复核三份清单后，将公开仓库、tag 和可运行发行页链接填入大赛个人中心。

## 4. 参赛提交核对

- [ ] 核对开源许可及 AI/素材声明，按最终包确认 26 份人声的实际来源；如替换真人录音，同步更新署名。
- [ ] 真机验收 Windows 标准版与兼容版、Android 手机与 KTR 掌机，并在浏览器离线打开 Web 包；按平台核对输入、音频、存档与退出。
- [ ] 至少 3 位首次试玩者用默认设置盲测，记录时长、反馈及调整。
- [ ] 准备 5 分钟以内的实机演示，覆盖双线、风台数到二十、慢时连线换弹与片尾，发布至 B 站并附赛事话题。
- [ ] 整理至少 3 篇不重复的开发者日志，可从 `docs/dev-log-2026-11-26` 分支的 `docs/dev-log/` 选稿。
- [ ] 大赛个人中心在 11 月 28 日 00:00 开放提交，集中开发截止 12 月 6 日 23:59。申报 Dora 开源社区奖还需将兼容版本上架原子派社区，按赛事要求在 12 月 27 日 23:59 前核对 ≥ 20 个点赞和审核状态。
