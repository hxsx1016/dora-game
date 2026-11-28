#!/usr/bin/env bash
#
# 从 Dora SSR v1.10.2 官方 Windows 发行包组装《向西守望》Windows x64 便携游玩包（方案 B：根目录单 exe + saves/ + runtime/）。
#
# 目录布局（ZIP 解压即得干净顶层目录 WestwardWatch/）：
#   WestwardWatch/
#   ├── WestwardWatch.exe          ← 根目录原生 Win32 GUI 启动器（含图标、PE 元信息、未解压检测、窗口标题修正）
#   ├── saves/                     ← 默认便携存档目录（profile.sav / autosave.sav / slots/ / settings.ini / backups/ / logs/）
#   ├── README.md                  ← 玩家说明
#   ├── LICENSE                    ← Apache-2.0 开源许可
#   └── runtime/                   ← 引擎与游戏运行时全部收拢于此
#       ├── WestwardWatchRuntime.exe  ← 经 dora-windows-ux.patch 构建的 Dora.exe
#       ├── *.dll                     ← 最小运行库 DLL（排除 dora_godot.dll / wa.dll）
#       ├── dora-game-id              ← 固定 32 位 ID（锁定 assetPath = runtime/、单实例锁）
#       ├── VERSION.txt / LICENSES/ / Shader/
#       ├── Script/ (init.lua / main.lua / Lib/lualib_bundle.lua / watch/...)
#       └── assets/
#
# 用法：
#   bash tools/make-windows-pack.sh \
#     [--backend d3d12|opengl] \
#     [--engine-dir <解压后的 Dora 官方 Windows 包目录>] \
#     [--launcher <编译好的根目录启动器 WestwardWatch.exe>] \
#     [--runtime-exe <匹配后端的已打补丁 Dora.exe；默认检查引擎目录的 Dora.exe>] \
#     [--out-dir <输出目录，默认 dist>] \
#     [--version <版本标识，默认取 git tag/sha>] \
#     [--exe-name <根目录可执行文件名，默认 WestwardWatch>] \
#     [--runtime-name <runtime 内引擎可执行文件名，默认 WestwardWatchRuntime>]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="d3d12"
ENGINE_DIR=""
LAUNCHER_BIN=""
RUNTIME_EXE_OVERRIDE=""
OUT_ROOT="$ROOT/dist"
VERSION=""
EXE_NAME="WestwardWatch"
RUNTIME_NAME="WestwardWatchRuntime"

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
        --launcher)
            LAUNCHER_BIN="${2:?missing value for --launcher}"
            shift 2
            ;;
        --runtime-exe)
            RUNTIME_EXE_OVERRIDE="${2:?missing value for --runtime-exe}"
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
        --runtime-name)
            RUNTIME_NAME="${2:?missing value for --runtime-name}"
            shift 2
            ;;
        -h|--help)
            sed -n '3,33p' "$0" | sed 's/^# \{0,1\}//'
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

RUNTIME_SRC_EXE="${RUNTIME_EXE_OVERRIDE:-$SRC/Dora.exe}"
if [ ! -f "$RUNTIME_SRC_EXE" ]; then
    echo "缺少引擎发行包：请在 $SRC/ 放置含 Dora.exe 的 Dora SSR v1.10.2 Windows ($BACKEND_LABEL) 解压文件" >&2
    exit 1
fi
# WindowClose is the native AppEvent added by tools/patches/dora-windows-ux.patch.
# Stock engines have the same file name and can boot the game without providing this event.
python3 - "$RUNTIME_SRC_EXE" <<'PYTHON'
from pathlib import Path
import sys

runtime = Path(sys.argv[1])
if b"WindowClose\0" not in runtime.read_bytes():
    sys.exit(f"{runtime} 缺少原生 WindowClose 事件。请通过 --runtime-exe 指定对应后端的 #41 补丁运行时。")
PYTHON
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

# 若未显式传入 --launcher，尝试在本地检测 MinGW-w64 自动交叉编译原生 Win32 启动器
TEMP_LAUNCHER_DIR=""
cleanup_tmp() {
    if [ -n "$TEMP_LAUNCHER_DIR" ] && [ -d "$TEMP_LAUNCHER_DIR" ]; then
        rm -rf "$TEMP_LAUNCHER_DIR"
    fi
}
trap cleanup_tmp EXIT

if [ -z "$LAUNCHER_BIN" ]; then
    if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1 && command -v x86_64-w64-mingw32-windres >/dev/null 2>&1; then
        TEMP_LAUNCHER_DIR="$(mktemp -d)"
        echo "== 0/4 使用 MinGW-w64 编译根目录原生启动器 ${EXE_NAME}.exe"
        x86_64-w64-mingw32-windres \
            -I "$ROOT/tools/windows-launcher" \
            -DAPP_VER_STR="\"${VERSION}\"" \
            "$ROOT/tools/windows-launcher/launcher.rc" \
            -O coff -o "$TEMP_LAUNCHER_DIR/launcher.res"
        x86_64-w64-mingw32-gcc -O2 -Wall -Wextra -municode -mwindows \
            "$ROOT/tools/windows-launcher/launcher.c" \
            "$TEMP_LAUNCHER_DIR/launcher.res" \
            -o "$TEMP_LAUNCHER_DIR/${EXE_NAME}.exe" \
            -luser32 -lkernel32
        LAUNCHER_BIN="$TEMP_LAUNCHER_DIR/${EXE_NAME}.exe"
    else
        echo "缺少根目录启动器：请通过 --launcher <path/to/${EXE_NAME}.exe> 传入编译后的启动器（或安装 x86_64-w64-mingw32-gcc 自动交叉编译）。" >&2
        exit 1
    fi
fi

if [ ! -f "$LAUNCHER_BIN" ]; then
    echo "启动器文件不存在: $LAUNCHER_BIN" >&2
    exit 1
fi

echo "== 1/4 执行资产与字库审计"
python3 "$ROOT/tools/audit-assets.py"

mkdir -p "$OUT_ROOT"
OUT_ROOT="$(cd "$OUT_ROOT" && pwd)"
PACK_FOLDER="${EXE_NAME}"
STAGE_DIR="$OUT_ROOT/.stage-${BACKEND}"
OUT="$STAGE_DIR/$PACK_FOLDER"
RT="$OUT/runtime"
ZIP="$OUT_ROOT/${EXE_NAME}-${VERSION}-${SUFFIX}.zip"

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$@"
    else
        shasum -a 256 "$@"
    fi
}

echo "== 2/4 白名单组装 ${PACK_FOLDER}/ ($BACKEND_LABEL)"
rm -rf "$STAGE_DIR"
mkdir -p "$OUT/saves/slots" "$OUT/saves/backups" "$OUT/saves/logs" "$RT/Script/Lib" "$RT/assets"

# 1. 根目录仅放置干净的用户级入口与文档（无 .cmd、无散落 .ico、无内部哈希清单）
cp "$LAUNCHER_BIN" "$OUT/${EXE_NAME}.exe"
cp "$ROOT/tools/windows-pack-README.md" "$OUT/README.md"
if [ -f "$ROOT/LICENSE" ]; then
    cp "$ROOT/LICENSE" "$OUT/LICENSE"
fi

# 2. runtime/ 引擎主程序（优先使用已由 CI rcedit 注入图标与 PE 版本信息的版本）
cp "$RUNTIME_SRC_EXE" "$RT/${RUNTIME_NAME}.exe"
if [ -n "${RCEDIT_BIN:-}" ] && [ -x "${RCEDIT_BIN}" ] && [ -f "$ROOT/art-source/brand/icons/WestwardWatch.ico" ]; then
    "${RCEDIT_BIN}" "$RT/${RUNTIME_NAME}.exe" --set-icon "$ROOT/art-source/brand/icons/WestwardWatch.ico"
fi

# 3. 复制必要运行库 DLL（显式排除本项目未使用的 dora_godot.dll 与 wa.dll）
shopt -s nullglob
for dll in "$SRC"/*.dll; do
    base="$(basename "$dll")"
    if [ "$base" = "dora_godot.dll" ] || [ "$base" = "wa.dll" ]; then
        continue
    fi
    cp "$dll" "$RT/$base"
done
shopt -u nullglob

# 4. 极简白名单复制引擎运行依赖：
#    - 保留 Shader/ 与 LICENSES/；
#    - Script/Lib 仅复制游戏唯一依赖的 lualib_bundle.lua（剔除 744 个 Dora Agent/IDE 定义文件，省 ~7.2 MB）；
#    - 剔除引擎自带的 Font/（省 15.8 MB sarasa + 0.8 MB NotoEmoji，游戏全量使用自有中文字体）、
#      Image/（Dora 默认 logo/banner）、Audio/（删掉 GeneralUserGS.sf3 后为空目录）与 gamecontrollerdb.txt。
for item in Shader LICENSES; do
    if [ -d "$SRC/$item" ]; then
        mkdir -p "$RT/$item"
        rsync -a \
            --exclude '.DS_Store' \
            --exclude '._*' \
            "$SRC/$item/" "$RT/$item/"
    elif [ -f "$SRC/$item" ]; then
        cp "$SRC/$item" "$RT/$item"
    fi
done

if [ ! -f "$SRC/Script/Lib/lualib_bundle.lua" ]; then
    echo "缺少引擎运行库 $SRC/Script/Lib/lualib_bundle.lua" >&2
    exit 1
fi
cp "$SRC/Script/Lib/lualib_bundle.lua" "$RT/Script/Lib/lualib_bundle.lua"

# 5. 写入独立游戏标识与版本信息（放于 runtime/ 内部，锁定 assetPath = runtime/）
printf '%s' "$GAME_ID" > "$RT/dora-game-id"
{
    printf '%s\n' "$VERSION"
    printf 'target=windows\n'
    printf 'backend=%s\n' "$BACKEND"
    printf 'engine=Dora SSR v1.10.2\n'
    printf 'layout=launcher-runtime\n'
    printf 'commit=%s\n' "$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
} > "$RT/VERSION.txt"

# 6. 注入启动引导、Windows 纯键鼠裁剪后的游戏 Lua 模块与完整运行时素材
cp "$ROOT/tools/windows-boot.lua" "$RT/Script/init.lua"
cp "$ROOT/init.lua" "$RT/Script/main.lua"
mkdir -p "$RT/Script/watch"
rsync -a --prune-empty-dirs \
    --exclude='testdrive.lua' \
    --exclude='platform_mobile.lua' \
    --exclude='input/aim_assist.lua' \
    --exclude='input/touch_*.lua' \
    --exclude='input/gamepad_core.lua' \
    --exclude='targets/android/' \
    --exclude='targets/handheld/' \
    --exclude='targets/web/' \
    --include='*/' \
    --include='*.lua' \
    --exclude='*' \
    "$ROOT/Script/watch/" "$RT/Script/watch/"
cat > "$RT/Script/watch/target.lua" <<'LUA'
local ____exports = {}
local ____target = require("Script.watch.targets.windows.index").TARGET
function ____exports.resolveTargetId()
	return "windows"
end
function ____exports.resetActiveTarget()
end
function ____exports.getActiveTarget()
	return ____target
end
return ____exports
LUA
rsync -a --exclude '.DS_Store' --exclude '._*' --exclude '*.md' "$ROOT/assets/" "$RT/assets/"

echo "== 3/4 自校验包内结构与白名单裁剪"
for forbidden in \
    "启动-向西守望.cmd" "${EXE_NAME}.ico" "SHA256SUMS" "dora-game-id" "Script" "assets" \
    "runtime/www" "runtime/Doc" "runtime/dora-wa" "runtime/dora_godot.dll" "runtime/wa.dll" \
    "runtime/gamecontrollerdb.txt" "runtime/Audio" "runtime/Font" "runtime/Image" \
    "runtime/Script/Dev" "runtime/Script/Tools" "runtime/Script/Lib/Agent" "runtime/Script/Lib/Dora" \
    "runtime/Script/watch/testdrive.lua" \
    "runtime/Script/watch/platform_mobile.lua" \
    "runtime/Script/watch/input/aim_assist.lua" \
    "runtime/Script/watch/input/touch_core.lua" \
    "runtime/Script/watch/input/touch_interact_meta.lua" \
    "runtime/Script/watch/input/touch_hud_landscape.lua" \
    "runtime/Script/watch/input/touch_hud_portrait.lua" \
    "runtime/Script/watch/input/gamepad_core.lua" \
    "runtime/Script/watch/targets/android" \
    "runtime/Script/watch/targets/handheld" \
    "runtime/Script/watch/targets/web" \
    "runtime/assets/audio/gate/MANIFEST.md"; do
    if [ -e "$OUT/$forbidden" ]; then
        echo "打包自检失败：发现不应包含的冗余文件/目录 $forbidden" >&2
        exit 1
    fi
done

for required_dir in \
    "saves" \
    "saves/slots" \
    "saves/backups" \
    "saves/logs" \
    "runtime"; do
    if [ ! -d "$OUT/$required_dir" ]; then
        echo "打包自检失败：缺少必要目录 $required_dir" >&2
        exit 1
    fi
done

for required in \
    "${EXE_NAME}.exe" \
    "LICENSE" \
    "README.md" \
    "runtime/${RUNTIME_NAME}.exe" \
    "runtime/dora-game-id" \
    "runtime/VERSION.txt" \
    "runtime/Script/init.lua" \
    "runtime/Script/main.lua" \
    "runtime/Script/Lib/lualib_bundle.lua" \
    "runtime/Script/watch/app.lua" \
    "runtime/Script/watch/save.lua" \
    "runtime/Script/watch/controls_config.lua" \
    "runtime/Script/watch/target.lua" \
    "runtime/Script/watch/targets/windows/index.lua" \
    "runtime/Script/watch/input/kbm_core.lua" \
    "runtime/Script/watch/fe/frontend.lua" \
    "runtime/Script/watch/fe/renderer/anim_controller.lua" \
    "runtime/Script/watch/fe/renderer/scene_fx.lua" \
    "runtime/Script/watch/fe/scenes/dark_pixel_assets.lua" \
    "runtime/Script/watch/fe/scenes/xiaoman3d.lua" \
    "runtime/Script/watch/fe/scenes/xiaoman3d_actor.lua" \
    "runtime/Script/watch/fe/scenes/xiaoman3d_entities.lua" \
    "runtime/assets/xiaoman3d/outside.glb" \
    "runtime/assets/xiaoman3d/village.glb" \
    "runtime/assets/xiaoman3d/forest.glb" \
    "runtime/assets/xiaoman3d/tower.glb" \
    "runtime/assets/xiaoman3d/xiaoman.glb" \
    "runtime/assets/xiaoman3d/scavenger.glb" \
    "runtime/assets/xiaoman3d/dog.glb" \
    "runtime/assets/xiaoman3d/guard.glb" \
    "runtime/assets/xiaoman3d/cart.glb" \
    "runtime/assets/xiaoman3d/bottle.glb" \
    "runtime/assets/xiaoman3d/basin.glb" \
    "runtime/assets/xiaoman3d/door.glb" \
    "runtime/assets/xiaoman3d/lantern.glb" \
    "runtime/assets/xiaoman3d/ledger.glb" \
    "runtime/assets/xiaoman3d/pouch.glb" \
    "runtime/assets/xiaoman3d/latch.glb" \
    "runtime/assets/xiaoman3d/grass.glb" \
    "runtime/assets/xiaoman3d/twig.glb" \
    "runtime/assets/xiaoman3d/bough.glb" \
    "runtime/assets/xiaoman3d/sky_backdrop.glb" \
    "runtime/assets/art/title.png" \
    "runtime/assets/art/brand/game_logo_h.png" \
    "runtime/assets/art/brand/game_logo_v.png" \
    "runtime/assets/art/brand/team_logo_dark.png" \
    "runtime/assets/art/brand/team_badge.png" \
    "runtime/assets/art/brand/app_icon.png" \
    "runtime/assets/art/sprites.clip" \
    "runtime/assets/art/sprites_fe.clip" \
    "runtime/assets/art/sprites_fe.png" \
    "runtime/assets/art/slides/p01_01_curtain.png" \
    "runtime/assets/art/tex_diorama_ming.clip" \
    "runtime/assets/art/tex_diorama_ming.png" \
    "runtime/assets/art/diorama_cutouts.clip" \
    "runtime/assets/art/diorama_cutouts.png" \
    "runtime/assets/art/cutscene_cuff_rig.clip" \
    "runtime/assets/art/cutscene_cuff_rig.png" \
    "runtime/assets/art/props_ming.clip" \
    "runtime/assets/art/props_ming.png" \
    "runtime/assets/art/actors_extra.clip" \
    "runtime/assets/art/actors_extra.png" \
    "runtime/assets/art/vfx_craft_art.clip" \
    "runtime/assets/art/vfx_craft_art.png" \
    "runtime/assets/art/bg_escort_ridge.png" \
    "runtime/assets/art/props_second_half.clip" \
    "runtime/assets/art/props_second_half.png" \
    "runtime/assets/art/scene_dark_pixel.clip" \
    "runtime/assets/art/scene_dark_pixel.png" \
    "runtime/assets/art/actors-hd.clip" \
    "runtime/assets/art/actors-hd.png" \
    "runtime/assets/art/actors_zhoushu_anim.clip" \
    "runtime/assets/art/actors_zhoushu_anim.png" \
    "runtime/assets/art/actors_xiaoman_anim.clip" \
    "runtime/assets/art/actors_xiaoman_anim.png" \
    "runtime/assets/art/actors_duo_anim.clip" \
    "runtime/assets/art/actors_duo_anim.png" \
    "runtime/assets/art/actors_enemies_anim.clip" \
    "runtime/assets/art/actors_enemies_anim.png" \
    "runtime/assets/art/vfx_ming_fx.clip" \
    "runtime/assets/art/vfx_ming_fx.png" \
    "runtime/assets/art/zhoushu-run.png" \
    "runtime/assets/art/xiaoman-run.png" \
    "runtime/assets/art/zhoushu-run-transition.png" \
    "runtime/assets/art/xiaoman-run-transition.png" \
    "runtime/assets/art/zhoushu-slide.png" \
    "runtime/assets/font/lxgw-neo-zhisong.ttf" \
    "runtime/assets/font/longcang-brush.ttf" \
    "runtime/assets/audio/combat/shot.wav" \
    "runtime/assets/audio/sfx/knock.wav" \
    "runtime/assets/audio/prologue/night_distant_fire.wav"; do
    if [ ! -s "$OUT/$required" ]; then
        echo "打包自检失败：缺少必要产物 $required" >&2
        exit 1
    fi
done

echo "== 4/4 压缩 $ZIP"
rm -f "$ZIP" "${ZIP}.sha256"
(
    cd "$STAGE_DIR"
    zip -qr -9 "$ZIP" "$PACK_FOLDER" -x "*.DS_Store" "*__MACOSX*" "*/._*"
)
(
    cd "$OUT_ROOT"
    sha256_file "$(basename "$ZIP")" | tee "$(basename "${ZIP}.sha256")"
)

echo "== 完成"
du -sh "$OUT" "$ZIP"
rm -rf "$STAGE_DIR"
