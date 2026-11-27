#!/usr/bin/env bash
#
# 从 Dora SSR v1.10.2 官方 Android APK 模板组装《向西守望》独立 Android / 安卓掌机 APK。
#
# 特性：
#   1. 支持两类专属裁剪配置（--profile）：
#      - android（默认，手机/平板纯触屏）：物理剔除键鼠、手柄与 gamecontrollerdb.txt，默认 fullUser 横竖屏自适应；
#      - handheld（安卓掌机 KT-R1/KT-R2 触屏+手柄）：物理剔除键鼠与竖屏手机掌机台，默认锁定 sensorLandscape 横屏；
#   2. 自动执行仓库资产与字库审计（确保 0 缺字、0 缺失资产）；
#   3. 白名单剔除 Godot/Wa/Web IDE/Doc/Dev 冗余文件，注入统一品牌 512x512 图标；
#   4. 二进制修补 AndroidManifest.xml：独立包名、中文名、屏幕方向、剥离无关高危权限；
#   5. 自动执行 zipalign -P 16（16KB 页对齐，兼容 Android 15+）及可选 apksigner v2/v3 正式签名与验签。
#
# 用法：
#   bash tools/make-android-pack.sh \
#     --template-apk <dora-ssr-v1.10.2-android.apk> \
#     [--profile android | handheld] \
#     [--abis arm64-v8a | arm64-v8a,armeabi-v7a] \
#     [--orientation fullUser | sensorLandscape | unspecified] \
#     [--suffix android-arm64 | android-universal | handheld-arm64] \
#     [--out-dir <输出目录，默认 $BUILD_SCRATCH_ROOT/2026gamejam/android-out>] \
#     [--version <版本名，如 v0.1.0>] \
#     [--version-code <整数版本号，默认按提交数或 1>] \
#     [--package <包名，默认 com.hxsx1016.westwardwatch>] \
#     [--keystore <签名文件 .p12/.jks>] [--ks-pass <口令>] [--ks-alias <别名>] [--key-pass <密钥口令>]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_APK=""
PROFILE="android"
ABIS="arm64-v8a"
ORIENTATION=""
SUFFIX=""
OUT_ROOT="${BUILD_SCRATCH_ROOT:-$HOME/.build}/2026gamejam/android-out"
VERSION=""
VERSION_CODE=""
PACKAGE_NAME="com.hxsx1016.westwardwatch"
APP_TITLE="向西守望"
APK_PREFIX="WestwardWatch"
KEYSTORE=""
KS_PASS=""
KS_ALIAS=""
KEY_PASS=""
SKIP_AUDIT=0

while [ $# -gt 0 ]; do
    case "$1" in
        --template-apk) TEMPLATE_APK="${2:?}"; shift 2 ;;
        --profile) PROFILE="${2:?}"; shift 2 ;;
        --abis) ABIS="${2:?}"; shift 2 ;;
        --orientation) ORIENTATION="${2:?}"; shift 2 ;;
        --suffix) SUFFIX="${2:?}"; shift 2 ;;
        --out-dir) OUT_ROOT="${2:?}"; shift 2 ;;
        --version) VERSION="${2:?}"; shift 2 ;;
        --version-code) VERSION_CODE="${2:?}"; shift 2 ;;
        --package) PACKAGE_NAME="${2:?}"; shift 2 ;;
        --title) APP_TITLE="${2:?}"; shift 2 ;;
        --keystore) KEYSTORE="${2:?}"; shift 2 ;;
        --ks-pass) KS_PASS="${2:?}"; shift 2 ;;
        --ks-alias) KS_ALIAS="${2:?}"; shift 2 ;;
        --key-pass) KEY_PASS="${2:?}"; shift 2 ;;
        --skip-audit) SKIP_AUDIT=1; shift 1 ;;
        -h|--help)
            sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

case "$PROFILE" in
    android)
        BOOT_SCRIPT="$ROOT/tools/android-boot.lua"
        DEFAULT_ORIENTATION="fullUser"
        ;;
    handheld)
        BOOT_SCRIPT="$ROOT/tools/handheld-boot.lua"
        DEFAULT_ORIENTATION="sensorLandscape"
        ;;
    *)
        echo "不支持的 --profile: $PROFILE（仅支持 android 或 handheld）" >&2
        exit 1
        ;;
esac

if [ -z "$ORIENTATION" ]; then
    ORIENTATION="$DEFAULT_ORIENTATION"
fi

if [ -z "$TEMPLATE_APK" ] || [ ! -f "$TEMPLATE_APK" ]; then
    echo "缺少 Dora SSR 官方 Android APK 模板：请通过 --template-apk 指定 dora-ssr-v1.10.2-android.apk" >&2
    exit 1
fi

REQ_LUA=(
    init.lua
    Script/watch/app.lua
    Script/watch/target.lua
    Script/watch/target_types.lua
    Script/watch/platform.lua
    Script/watch/platform_mobile.lua
    Script/watch/controls_config.lua
    Script/watch/input.lua
    Script/watch/input/aim_assist.lua
    Script/watch/input/touch_core.lua
    Script/watch/input/touch_interact_meta.lua
    Script/watch/input/touch_hud_landscape.lua
    Script/watch/fe/renderer/anim_controller.lua
    Script/watch/fe/renderer/scene_fx.lua
    Script/watch/fe/scenes/dark_pixel_assets.lua
)
if [ "$PROFILE" = "android" ]; then
    REQ_LUA+=(
        Script/watch/input/touch_hud_portrait.lua
        Script/watch/targets/android/index.lua
    )
else
    REQ_LUA+=(
        Script/watch/input/gamepad_core.lua
        Script/watch/targets/handheld/index.lua
    )
fi

for req_lua in "${REQ_LUA[@]}"; do
    if [ ! -f "$ROOT/$req_lua" ]; then
        echo "缺少 Lua 编译产物 $req_lua：请先执行 Dora TS 构建。" >&2
        exit 1
    fi
done

if [ -z "$VERSION" ]; then
    VERSION="$(git -C "$ROOT" describe --tags --always --dirty 2>/dev/null || echo "dev")"
fi
VERSION_NAME="${VERSION#v}"

if [ -z "$VERSION_CODE" ]; then
    VERSION_CODE="$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null || echo 1)"
fi

if [ -z "$SUFFIX" ]; then
    if [ "$ABIS" = "arm64-v8a" ]; then
        SUFFIX="${PROFILE}-arm64"
    else
        SUFFIX="${PROFILE}-universal"
    fi
fi

if [ "$SKIP_AUDIT" -eq 0 ]; then
    echo "== 1/5 执行静态资产与中文字库审计"
    python3 "$ROOT/tools/audit-assets.py"
fi

mkdir -p "$OUT_ROOT"
OUT_ROOT="$(cd "$OUT_ROOT" && pwd)"
STAGE="$(mktemp -d "${OUT_ROOT}/.stage-${PROFILE}-XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

echo "== 2/5 组装游戏运行时资源（profile=${PROFILE}, orientation=${ORIENTATION}）"
mkdir -p "$STAGE/assets/Script/watch" "$STAGE/assets/assets"
cp "$BOOT_SCRIPT" "$STAGE/assets/Script/init.lua"
cp "$ROOT/init.lua" "$STAGE/assets/Script/main.lua"

if [ "$PROFILE" = "android" ]; then
    rsync -a --prune-empty-dirs \
        --exclude='testdrive.lua' \
        --exclude='input/kbm_core.lua' \
        --exclude='input/gamepad_core.lua' \
        --exclude='targets/windows/' \
        --exclude='targets/handheld/' \
        --exclude='targets/web/' \
        --include='*/' \
        --include='*.lua' \
        --exclude='*' \
        "$ROOT/Script/watch/" "$STAGE/assets/Script/watch/"
else
    rsync -a --prune-empty-dirs \
        --exclude='testdrive.lua' \
        --exclude='input/kbm_core.lua' \
        --exclude='input/touch_hud_portrait.lua' \
        --exclude='targets/windows/' \
        --exclude='targets/android/' \
        --exclude='targets/web/' \
        --include='*/' \
        --include='*.lua' \
        --exclude='*' \
        "$ROOT/Script/watch/" "$STAGE/assets/Script/watch/"
fi

cat > "$STAGE/assets/Script/watch/target.lua" <<LUA
local ____exports = {}
local ____target = require("Script.watch.targets.${PROFILE}.index").TARGET
function ____exports.resolveTargetId()
	return "${PROFILE}"
end
function ____exports.resetActiveTarget()
end
function ____exports.getActiveTarget()
	return ____target
end
return ____exports
LUA

# 阶段自检：确认当前 profile 仅包含预期模块，无跨端冗余残留
if [ "$PROFILE" = "android" ]; then
    FORBIDDEN_LUA=(
        Script/watch/testdrive.lua
        Script/watch/input/kbm_core.lua
        Script/watch/input/gamepad_core.lua
        Script/watch/targets/windows
        Script/watch/targets/handheld
        Script/watch/targets/web
    )
else
    FORBIDDEN_LUA=(
        Script/watch/testdrive.lua
        Script/watch/input/kbm_core.lua
        Script/watch/input/touch_hud_portrait.lua
        Script/watch/targets/windows
        Script/watch/targets/android
        Script/watch/targets/web
    )
fi
for bad in "${FORBIDDEN_LUA[@]}"; do
    if [ -e "$STAGE/assets/$bad" ]; then
        echo "打包自检失败（profile=${PROFILE}）：发现不应包含的冗余模块 $bad" >&2
        exit 1
    fi
done

rsync -a --exclude '.DS_Store' --exclude '._*' --exclude '*.md' "$ROOT/assets/" "$STAGE/assets/assets/"
{
    printf '%s\n' "$VERSION"
    printf 'platform=Android\n'
    printf 'target=%s\n' "$PROFILE"
    printf 'orientation=%s\n' "$ORIENTATION"
    printf 'abis=%s\n' "$ABIS"
    printf 'engine=Dora SSR v1.10.2\n'
    printf 'commit=%s\n' "$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
} > "$STAGE/assets/VERSION.txt"

UNSIGNED_APK="$STAGE/unsigned.apk"
ALIGNED_APK="$STAGE/aligned.apk"
FINAL_APK="$OUT_ROOT/${APK_PREFIX}-${VERSION}-${SUFFIX}.apk"

UNIFIED_ICON="$ROOT/art-source/brand/icons/android/ic_launcher_512.png"
PATCH_EXTRA_ARGS=()
if [ -f "$UNIFIED_ICON" ]; then
    PATCH_EXTRA_ARGS+=(--icon "$UNIFIED_ICON")
else
    echo "警告：未找到统一品牌 Android 图标 $UNIFIED_ICON，将回退模板默认图标。" >&2
fi
if [ "$PROFILE" = "android" ]; then
    PATCH_EXTRA_ARGS+=(--strip-controller-db)
fi

echo "== 3/5 裁剪模板 APK 并修补二进制清单（目标=${PROFILE} + 屏幕方向=${ORIENTATION} + 独立包名 + 统一品牌图标）"
python3 "$ROOT/tools/patch-android-apk.py" \
    --template-apk "$TEMPLATE_APK" \
    --assets-dir "$STAGE/assets" \
    --output "$UNSIGNED_APK" \
    --package "$PACKAGE_NAME" \
    --title "$APP_TITLE" \
    --version-code="$VERSION_CODE" \
    --version-name="$VERSION_NAME" \
    --abis "$ABIS" \
    --orientation "$ORIENTATION" \
    "${PATCH_EXTRA_ARGS[@]}"

find_build_tool() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        command -v "$tool"
        return 0
    fi
    if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME/build-tools" ]; then
        local found
        found="$(find "$ANDROID_HOME/build-tools" -maxdepth 2 -name "$tool" 2>/dev/null | sort -V | tail -n 1)"
        if [ -n "$found" ]; then
            printf '%s\n' "$found"
            return 0
        fi
    fi
    return 1
}

ZIPALIGN="$(find_build_tool zipalign || true)"
APKSIGNER="$(find_build_tool apksigner || true)"

echo "== 4/5 16KB 页对齐与签名"
if [ -n "$ZIPALIGN" ]; then
    "$ZIPALIGN" -P 16 -f 4 "$UNSIGNED_APK" "$ALIGNED_APK"
else
    echo "警告：未找到 zipalign，跳过对齐（仅限本地干跑验证；正式发版 CI 会强制对齐）" >&2
    cp "$UNSIGNED_APK" "$ALIGNED_APK"
fi

if [ -n "$KEYSTORE" ]; then
    if [ -z "$APKSIGNER" ]; then
        echo "错误：已指定 --keystore 但系统缺少 apksigner" >&2
        exit 1
    fi
    SIGN_ARGS=(
        sign
        --ks "$KEYSTORE"
        --ks-pass "pass:${KS_PASS}"
        --key-pass "pass:${KEY_PASS:-$KS_PASS}"
        --v1-signing-enabled false
        --v2-signing-enabled true
        --v3-signing-enabled true
        --out "$FINAL_APK"
    )
    if [ -n "$KS_ALIAS" ]; then
        SIGN_ARGS+=(--ks-key-alias "$KS_ALIAS")
    fi
    "$APKSIGNER" "${SIGN_ARGS[@]}" "$ALIGNED_APK"
    "$APKSIGNER" verify --verbose "$FINAL_APK"
    echo "签名与验签通过：$FINAL_APK"
else
    cp "$ALIGNED_APK" "$FINAL_APK"
    echo "未传入签名证书，已输出未签名 APK：$FINAL_APK"
fi

echo "== 5/5 生成校验清单"
(
    cd "$OUT_ROOT"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$(basename "$FINAL_APK")" | tee "$(basename "$FINAL_APK").sha256"
    else
        shasum -a 256 "$(basename "$FINAL_APK")" | tee "$(basename "$FINAL_APK").sha256"
    fi
)
ls -lh "$FINAL_APK"
