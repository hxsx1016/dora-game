#!/usr/bin/env bash
#
# 生成《向西守望》Dora SSR 开源源码包（专供 Dora 开源社区奖审核及 Dora SSR 跨平台直接运行）。
#
# 用法：
#   bash tools/make-dora-source-pack.sh [--out-dir <输出目录，默认 dist>] [--version <版本标识>]

set -euo pipefail
export COPYFILE_DISABLE=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_ROOT="$ROOT/dist"
VERSION=""
BASE_NAME="WestwardWatch"

while [ $# -gt 0 ]; do
    case "$1" in
        --out-dir)
            OUT_ROOT="${2:?missing value for --out-dir}"
            shift 2
            ;;
        --version)
            VERSION="${2:?missing value for --version}"
            shift 2
            ;;
        -h|--help)
            sed -n '3,7p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$VERSION" ]; then
    VERSION="$(git -C "$ROOT" describe --tags --always --dirty 2>/dev/null || echo "dev")"
fi

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$@"
    else
        shasum -a 256 "$@"
    fi
}

mkdir -p "$OUT_ROOT"
OUT_ROOT="$(cd "$OUT_ROOT" && pwd)"
PACK_NAME="${BASE_NAME}-${VERSION}-dora-source"
STAGE="$OUT_ROOT/$PACK_NAME"
ZIP="$OUT_ROOT/${PACK_NAME}.zip"

rm -rf "$STAGE"
mkdir -p "$STAGE"

echo "== 组装 Dora SSR 源码包 $STAGE"
cd "$ROOT"
rsync -a \
    --exclude '._*' --exclude '.DS_Store' --exclude '__MACOSX' \
    --exclude '.git' --exclude '.agent' --exclude '.cache' --exclude '.build' \
    --exclude '.download' --exclude '.upload' --exclude 'dist' --exclude 'API' \
    --exclude 'watch-save' --exclude 'tmp-*' --exclude '*.tmp' \
    init.ts init.lua tsconfig.json Script assets tools README.md AGENTS.md CONTRIBUTING.md .gitattributes \
    "$STAGE/"

cat > "$STAGE/Dora平台运行说明.md" <<MD
# 《向西守望》Dora SSR 兼容源码包（${VERSION}）

- 适用引擎：**Dora SSR v1.10.2**（支持 Windows / macOS / Linux / Android 等 Dora 平台）
- 入口文件：\`init.lua\`（源码 \`init.ts\`，已附完整预编译 Lua，无需二次编译即可直接运行）
- 运行方式：
  1. 在 Dora SSR 客户端 / Web IDE 中导入本目录，直接运行 \`init.lua\`；
  2. 或命令行执行：\`Dora cli run -p . --entry init.lua\`。
- 若希望在 Windows 10/11 免装引擎双击即玩，请下载同版本 Release 中的 \`${BASE_NAME}-${VERSION}-windows-x64.zip\`（或 \`-opengl.zip\`）。
MD

(
    cd "$STAGE"
    find . -type f ! -path './SHA256SUMS' -print0 | LC_ALL=C sort -z | xargs -0 -r bash -c '
        if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi
    ' _ > SHA256SUMS
)

rm -f "$ZIP" "${ZIP}.sha256"
(
    cd "$OUT_ROOT"
    zip -qr -9 "$ZIP" "$PACK_NAME" -x "*.DS_Store" "*__MACOSX*" "*/._*"
    sha256_file "$(basename "$ZIP")" | tee "$(basename "${ZIP}.sha256")"
)

du -sh "$STAGE" "$ZIP"
