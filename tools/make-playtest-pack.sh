#!/bin/bash
# 生成《向西守望》M2 离线源码试玩包（不含版本库、个人档案、临时脚本）。
set -euo pipefail
# 禁止 macOS tar 将扩展属性写成额外的 AppleDouble 条目。
export COPYFILE_DISABLE=1
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/../d-playtest-m2}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
NAME="xiwang-playtest-M2"
STAGE="$OUT/$NAME"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cd "$ROOT"
rsync -a --exclude '._*' --exclude '.DS_Store' --exclude '__MACOSX' \
  --exclude '.git' --exclude '.agent' --exclude '.cache' --exclude '.build' \
  --exclude '.download' --exclude '.upload' --exclude 'watch-save' \
  --exclude 'tmp-*' --exclude '*.tmp' \
  init.ts init.lua tsconfig.json Script assets tools docs art-source \
  README.md AGENTS.md CONTRIBUTING.md .gitattributes "$STAGE/"
# 试玩说明
cat > "$STAGE/试玩说明.md" <<'MD'
# 《向西守望》M2 整合试玩包

- 形态：Dora SSR 源码工程（TypeScript + 已构建 Lua），**不是独立可执行程序**；运行需要同版本 Dora SSR。
- 引擎版本：Dora SSR 1.10.2.6（macOS 构建；Windows 冷启动未在本轮验证）。
- 内容：后端 A/B1/B2/C 全链 + 前端 M2（小满四房、北塔双结局、井口博物馆、换弹盘、工台、档案）。
- 启动：`Dora cli run -p . --entry init.lua`，或在 Dora Web IDE 打开本目录后运行。
- 存档：正式档案位于 `Content.writablePath/watch-save/archive.txt`（跨局通关、神器、博物馆进度）。包内不附档案；解压后仍会读取该可写目录已有档案。
- 验收回放：`tools/verify-*.lua` 与 `tools/replay-d.lua` 需复制到仓库根再以 `--entry` 运行（引擎入口的 require 基准是入口文件目录）。
- 本轮实测：默认入口标题渲染、`startStory()` 进入可控序章、男主/女主两条路线端到端回放、粮棚跨局拾取隔离。GUI 鼠标/键盘注入在本机 Dora 窗口（Web IDE 宿主）不可用，真人键鼠通关与 Windows 冷启动待测；详见 `docs/守望-D-M2整合交付-2026-11-26.md` 与 D 整合报告。
- 文件核验：在压缩包所在目录运行 `shasum -a 256 -c xiwang-playtest-M2.tar.gz.sha256`，在新解压的工程根目录运行 `shasum -a 256 -c SHA256SUMS`。
MD
# 清单与哈希
cd "$STAGE"
find . -type f ! -path './SHA256SUMS' -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256 > SHA256SUMS
shasum -a 256 -c SHA256SUMS > /dev/null
echo "files: $(find . -type f | wc -l | tr -d ' ')  size: $(du -sh . | cut -f1)"
cd "$OUT"
tar -czf "$NAME.tar.gz" "$NAME"
shasum -a 256 "$NAME.tar.gz" | tee "$NAME.tar.gz.sha256"
