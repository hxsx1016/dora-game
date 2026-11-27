#!/usr/bin/env bash
#
# 从 Dora SSR 官方 Windows 发行包组装《向西守望》离线试玩包。
#
# 前置：把 dora-ssr-v1.10.2-windows-x64.zip 解压到 .download/win/，
#       并在仓库根跑过一次 TS 构建（要拿到最新的 init.lua 与 Script/watch 下的各层 Lua）。
#
# 用法：tools/make-windows-pack.sh
# 产物：dist/watch-windows-x64/ 与 dist/watch-windows-x64.zip
#
# 为什么不用官方 xmake app-package：那条路要 Windows 构建机 + VS C++ 工具链。
# 这里走的是「官方发行引擎 + 精简资源目录」，在 macOS 上就能组装，
# 玩家拿到 ZIP 解压双击 Dora.exe 即play。

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/.download/win"
OUT="$ROOT/dist/watch-windows-x64"
ZIP="$ROOT/dist/watch-windows-x64.zip"
NAME="watch-windows-x64"

if [ ! -f "$SRC/Dora.exe" ]; then
    echo "缺少发行包：请把 dora-ssr-v1.10.2-windows-x64.zip 解压到 .download/win/" >&2
    exit 1
fi
if [ ! -f "$ROOT/init.lua" ] || [ ! -f "$ROOT/Script/watch/fe/frontend.lua" ]; then
    echo "缺少构建产物：先在仓库根执行一次 TS 构建。" >&2
    exit 1
fi

for asset in \
    art/sprites.clip art/title.png \
    art/actors-hd.clip art/actors-hd.png art/zhoushu-run.png art/xiaoman-run.png \
    font/lxgw-neo-zhisong.ttf font/longcang-brush.ttf \
    audio/gate/count_20.wav audio/combat/carry_start.wav audio/child/bottle_brick.wav \
    audio/tower/book_open.wav audio/museum/hall_ambience_loop.wav; do
    if [ ! -s "$ROOT/assets/$asset" ]; then
        echo "缺少离线资源 assets/$asset" >&2
        exit 1
    fi
done

echo "== 组装 $OUT"
rm -rf "$OUT"
mkdir -p "$OUT"
# 只留运行必需的引擎资源：去掉文档、Web IDE、Wa 运行时、开发工具与默认入口。
rsync -a \
    --exclude 'Doc' \
    --exclude 'www' \
    --exclude 'dora-wa' \
    --exclude 'Script/Dev' \
    --exclude 'Script/Tools' \
    --exclude 'Script/Lib/Dora' \
    --exclude 'Script/init.yue' \
    --exclude '.DS_Store' \
    "$SRC/" "$OUT/"

# 入口分两层：Script/init.lua 先把资源搜索路径定死，再交给 TSTL 生成的 Script/main.lua。
# 独立 exe 的 assetPath 是它自己所在目录，不像 Web IDE 自带项目路径，
# 而 TSTL 入口在文件顶部就 require 游戏模块，所以路径必须先设好。
cp "$ROOT/tools/windows-boot.lua" "$OUT/Script/init.lua"
cp "$ROOT/init.lua" "$OUT/Script/main.lua"
mkdir -p "$OUT/Script/watch"
rsync -a --include='*/' --include='*.lua' --exclude='*' "$ROOT/Script/watch/" "$OUT/Script/watch/"
# 递归复制运行时素材，保留新增的音轨、场景资源及字体许可。
mkdir -p "$OUT/assets"
rsync -a --exclude '.DS_Store' "$ROOT/assets/" "$OUT/assets/"
cp "$ROOT/tools/windows-pack-README.md" "$OUT/README.md"

cat > "$OUT/启动.cmd" <<'CMD'
@echo off
rem 向西守望 · Windows 试玩包
rem 双击本文件或 Dora.exe 启动游戏。
cd /d "%~dp0"
start "" "Dora.exe"
CMD

echo "== 打包 $ZIP"
cd "$ROOT/dist"
rm -f "$NAME.zip"
zip -qr -9 "$NAME.zip" "$NAME" -x "*.DS_Store"

echo "== 完成"
du -sh "$OUT" "$ZIP"
