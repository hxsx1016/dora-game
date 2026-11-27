#!/usr/bin/env bash
#
# 从 Dora SSR v1.10.2 官方 Windows 发行包组装《向西守望》Windows x64 便携游玩包。
#
# 特性（对齐 Dora SSR NativeGameExport.yue 与 WindowsGame.h）：
#   1. 白名单组装运行时：剔除 Doc/www/dora-wa/Script/Dev/Script/Tools/dora_godot.dll/GeneralUserGS.sf3；
#   2. 写入固定 dora-game-id：锁定 assetPath、隔离单实例锁与 %APPDATA% 存档目录；
#   3. 支持 D3D12（标准版）与 OpenGL（兼容版）双轨打包；
#   4. 自动执行静态资产与字库审计，并生成包内 SHA256SUMS 与外层 ZIP 校验文件。
#
# 用法：
#   bash tools/make-windows-pack.sh \
#     [--backend d3d12|opengl] \
#     [--engine-dir <解压后的 Dora 官方 Windows 包目录>] \
#     [--out-dir <输出目录，默认 dist>] \
#     [--version <版本标识，默认取 git tag/sha>] \
#     [--exe-name <可执行文件名，默认 WestwardWatch>]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="d3d12"
ENGINE_DIR=""
OUT_ROOT="$ROOT/dist"
VERSION=""
EXE_NAME="WestwardWatch"

while [ $# -gt 0 ]; do
    case "$1" in
        --backend)
            BACKEND="${2:?missing value for --backend}"
            shift 2
            ;;
        --engine-dir)
            ENGINE_DIR="${2:?missing value for --engine-dir}"
            shift 2
            ;;
        --out-dir)
            OUT_ROOT="${2:?missing value for --out-dir}"
            shift 2
            ;;
        --version)
            VERSION="${2:?missing value for --version}"
            shift 2
            ;;
        --exe-name)
            EXE_NAME="${2:?missing value for --exe-name}"
            shift 2
            ;;
        -h|--help)
            sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

case "$BACKEND" in
    d3d12)
        DEFAULT_ENGINE_DIR="$ROOT/.download/win"
        SUFFIX="windows-x64"
        BACKEND_LABEL="Direct3D 12"
        ;;
    opengl)
        DEFAULT_ENGINE_DIR="$ROOT/.download/win-opengl"
        SUFFIX="windows-x64-opengl"
        BACKEND_LABEL="OpenGL (兼容版)"
        ;;
    *)
        echo "不支持的 --backend: $BACKEND（仅支持 d3d12 或 opengl）" >&2
        exit 1
        ;;
esac

SRC="${ENGINE_DIR:-$DEFAULT_ENGINE_DIR}"
if [ -z "$VERSION" ]; then
    VERSION="$(git -C "$ROOT" describe --tags --always --dirty 2>/dev/null || echo "dev")"
fi

if [ ! -f "$SRC/Dora.exe" ]; then
    echo "缺少引擎发行包：请在 $SRC/ 放置含 Dora.exe 的 Dora SSR v1.10.2 Windows ($BACKEND_LABEL) 解压文件" >&2
    exit 1
fi
if [ ! -f "$ROOT/init.lua" ] || [ ! -f "$ROOT/Script/watch/fe/frontend.lua" ] || [ ! -f "$ROOT/Script/watch/app.lua" ]; then
    echo "缺少 Lua 构建产物：先在仓库根执行 Dora TS 构建。" >&2
    exit 1
fi
if [ ! -f "$ROOT/tools/windows-game-id" ]; then
    echo "缺少 tools/windows-game-id" >&2
    exit 1
fi

GAME_ID="$(tr -d '\r\n ' < "$ROOT/tools/windows-game-id")"
if ! printf '%s' "$GAME_ID" | grep -Eq '^[0-9a-f]{32}$'; then
    echo "tools/windows-game-id 格式非法（需为 32 位小写十六进制）: $GAME_ID" >&2
    exit 1
fi

echo "== 1/4 执行资产与字库审计"
python3 "$ROOT/tools/audit-assets.py"

mkdir -p "$OUT_ROOT"
OUT_ROOT="$(cd "$OUT_ROOT" && pwd)"
PACK_NAME="${EXE_NAME}-${VERSION}-${SUFFIX}"
OUT="$OUT_ROOT/$PACK_NAME"
ZIP="$OUT_ROOT/${PACK_NAME}.zip"

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$@"
    else
        shasum -a 256 "$@"
    fi
}

echo "== 2/4 白名单组装 $OUT ($BACKEND_LABEL)"
rm -rf "$OUT"
mkdir -p "$OUT/Script" "$OUT/assets"

# 1. 可执行文件改名（原生支持，配合 dora-game-id 独立运行）
cp "$SRC/Dora.exe" "$OUT/${EXE_NAME}.exe"

# 2. 复制根目录必要运行库 DLL（显式排除本项目未使用的 dora_godot.dll 与 wa.dll；
#    已核验 Dora.exe 仅静态链接 Windows 系统 DLL，无需这两个动态加载运行库）
shopt -s nullglob
for dll in "$SRC"/*.dll; do
    base="$(basename "$dll")"
    if [ "$base" = "dora_godot.dll" ] || [ "$base" = "wa.dll" ]; then
        continue
    fi
    cp "$dll" "$OUT/$base"
done
shopt -u nullglob

# 3. 按 Dora SSR NativeGameExport.yue 白名单复制最小引擎资源
for item in Audio Font Image Shader Script/Lib LICENSES gamecontrollerdb.txt; do
    if [ -d "$SRC/$item" ]; then
        mkdir -p "$OUT/$item"
        rsync -a \
            --exclude 'GeneralUserGS.sf3' \
            --exclude 'Mobile/dora-remix-states.png' \
            --exclude '.DS_Store' \
            --exclude '._*' \
            "$SRC/$item/" "$OUT/$item/"
    elif [ -f "$SRC/$item" ]; then
        mkdir -p "$OUT/$(dirname "$item")"
        cp "$SRC/$item" "$OUT/$item"
    fi
done

# 4. 写入独立游戏标识与版本信息
printf '%s' "$GAME_ID" > "$OUT/dora-game-id"
{
    printf '%s\n' "$VERSION"
    printf 'backend=%s\n' "$BACKEND"
    printf 'engine=Dora SSR v1.10.2\n'
    printf 'commit=%s\n' "$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
} > "$OUT/VERSION.txt"

# 5. 注入启动引导、游戏 Lua 模块与完整运行时素材
cp "$ROOT/tools/windows-boot.lua" "$OUT/Script/init.lua"
cp "$ROOT/init.lua" "$OUT/Script/main.lua"
mkdir -p "$OUT/Script/watch"
rsync -a --include='*/' --include='*.lua' --exclude='*' "$ROOT/Script/watch/" "$OUT/Script/watch/"
rsync -a --exclude '.DS_Store' --exclude '._*' "$ROOT/assets/" "$OUT/assets/"
cp "$ROOT/tools/windows-pack-README.md" "$OUT/README.md"

# 6. 中文友好启动脚本（UTF-8 代码页 + 支持中文与空格路径）
cat > "$OUT/启动-向西守望.cmd" <<CMD
@echo off
chcp 65001 >nul
rem 《向西守望》Windows x64 便携包（${BACKEND_LABEL}）
rem 请先完整解压 ZIP，再双击本文件或 ${EXE_NAME}.exe 启动游戏。
cd /d "%~dp0"
start "" "${EXE_NAME}.exe"
CMD

echo "== 3/4 自校验包内结构与生成 SHA256SUMS"
for forbidden in www Doc dora-wa dora_godot.dll wa.dll Script/Dev Script/Tools; do
    if [ -e "$OUT/$forbidden" ]; then
        echo "打包自检失败：发现不应包含的冗余文件/目录 $forbidden" >&2
        exit 1
    fi
done
for required in \
    "${EXE_NAME}.exe" \
    "dora-game-id" \
    "VERSION.txt" \
    "Script/init.lua" \
    "Script/main.lua" \
    "Script/Lib/lualib_bundle.lua" \
    "Script/watch/app.lua" \
    "Script/watch/fe/frontend.lua" \
    "assets/art/title.png" \
    "assets/art/sprites.clip" \
    "assets/font/lxgw-neo-zhisong.ttf" \
    "assets/font/longcang-brush.ttf" \
    "assets/audio/combat/shot.wav" \
    "assets/audio/sfx/knock.wav" \
    "assets/audio/prologue/night_distant_fire.wav"; do
    if [ ! -s "$OUT/$required" ]; then
        echo "打包自检失败：缺少必要产物 $required" >&2
        exit 1
    fi
done

(
    cd "$OUT"
    find . -type f ! -path './SHA256SUMS' -print0 | LC_ALL=C sort -z | xargs -0 -r bash -c '
        if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi
    ' _ > SHA256SUMS
)

echo "== 4/4 压缩 $ZIP"
rm -f "$ZIP" "${ZIP}.sha256"
(
    cd "$OUT_ROOT"
    zip -qr -9 "$ZIP" "$PACK_NAME" -x "*.DS_Store" "*__MACOSX*" "*/._*"
    sha256_file "$(basename "$ZIP")" | tee "$(basename "${ZIP}.sha256")"
)

echo "== 完成"
du -sh "$OUT" "$ZIP"
