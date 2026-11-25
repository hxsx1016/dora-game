#!/bin/bash
# 生成《向西守望》D 整合离线源码试玩包（不含版本库、个人档案、临时脚本）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/../d-playtest}"
NAME="xiwang-playtest-D"
STAGE="$OUT/$NAME"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cd "$ROOT"
copy() {
  local item="$1"
  [ -e "$item" ] || return 0
  rsync -a --exclude '*.tmp' --exclude '.DS_Store' "$item" "$STAGE/"
}
for item in init.ts init.lua tsconfig.json Script assets tools docs art-source README.md AGENTS.md CONTRIBUTING.md .gitattributes; do
  copy "$item"
done
# 试玩说明
cat > "$STAGE/试玩说明.md" <<'MD'
# 《向西守望》D 整合试玩包

- 形态：Dora SSR 源码工程（TypeScript + 已构建 Lua），**不是独立可执行程序**；运行需要同版本 Dora SSR。
- 引擎版本：Dora SSR 1.10.2.6（macOS 构建；Windows 冷启动未在本轮验证）。
- 启动：`Dora cli run -p . --entry init.lua`，或在 Dora Web IDE 打开本目录后运行。
- 存档：写入引擎可写目录（`Content.writablePath/watch-save/archive.txt`），**不随包分发**，首次启动为全新档案。
- 验收回放：`tools/verify-*.lua` 与 `tools/replay-d.lua` 需复制到仓库根再以 `--entry` 运行（引擎入口的 require 基准是入口文件目录）。
- 本轮实测：默认入口标题渲染、标题「开始游戏」进入序章、两条路线端到端回放；GUI 鼠标/键盘注入在本机 Dora 窗口（Web IDE 宿主）不可用，详见交付报告。
MD
# 清单与哈希
cd "$STAGE"
find . -type f -not -name 'SHA256SUMS' -print0 | sort -z | xargs -0 shasum -a 256 > SHA256SUMS
echo "files: $(find . -type f | wc -l | tr -d ' ')  size: $(du -sh . | cut -f1)"
cd "$OUT"
tar -czf "$NAME.tar.gz" "$NAME"
shasum -a 256 "$NAME.tar.gz" | tee "$NAME.tar.gz.sha256"
