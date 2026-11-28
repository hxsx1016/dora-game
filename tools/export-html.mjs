#!/usr/bin/env node
/**
 * 《向西守望》Dora SSR Web 导出与打包工具（零私有 bundle 依赖，跨 Linux / macOS / CI 通用）。
 *
 * 支持两种官方兼容模式（均基于单线程 WebGL2 + AudioWorklet + IDBFS 的 dora-preset，无需 COOP/COEP）：
 *   1. server（默认）：静态网站部署包（适用于 GitHub Pages / Cloudflare Pages / 任意 HTTPS 静态站点）；
 *   2. html：离线单目录包（完整解压后可双击 index.html，直接通过 html-loader.js 校验并加载）；
 *   3. both：同时导出 server 与 html 两个目录及对应 ZIP。
 *
 * 统一品牌图标：自动从 art-source/brand/icons/web/ 注入 favicon.ico、favicon-32x32.png、
 * apple-touch-icon.png、icon-192.png、icon-512.png 并生成 PWA site.webmanifest。
 *
 * 用法：
 *   node tools/export-html.mjs [选项]
 *     --mode server|html|both     导出模式（默认 server）
 *     --out-dir <dir>             输出根目录（默认 $BUILD_SCRATCH_ROOT/2026gamejam/web-dist）
 *     --runtime-dir <dir>         显式指定 Dora web-player 目录（亦可设 DORA_WEB_RUNTIME_DIR / DORA_APP）
 *     --version <ver>             版本标识（默认取 git describe 或 dev）
 *     --no-zip                    只组装目录，不生成 ZIP
 */

import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import zlib from "node:zlib";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const PROJECT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const RUNTIME_CORE_NAMES = [
    "dora-player-runtime.js",
    "dora-player-runtime.wasm",
    "dora-player-runtime.data",
    "dora-web-features.json",
    "audio-worklet.js",
    "dora-audio-mixer.wasm",
    "dora-logo.png",
    "runtime.json",
    "LICENSE-Dora.txt",
    "LICENSES.3rdparty.md",
    "NOTICE.txt",
];

const WEB_BRAND_ICON_NAMES = [
    "favicon.ico",
    "favicon-32x32.png",
    "apple-touch-icon.png",
    "icon-192.png",
    "icon-512.png",
];

const enc = (str) => new Uint8Array(Buffer.from(str, "utf8"));
const dec = (bytes) => Buffer.from(bytes).toString("utf8");
const sha256 = (bytes) => crypto.createHash("sha256").update(bytes).digest("hex");

function defaultOutDir() {
    const scratchRoot = process.env.BUILD_SCRATCH_ROOT || path.join(os.homedir(), ".build");
    return path.join(scratchRoot, "2026gamejam", "web-dist");
}

function parseArgs(argv) {
    const opts = {
        mode: "server",
        outDir: defaultOutDir(),
        runtimeDir: "",
        version: "",
        zip: true,
    };
    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === "--mode") {
            opts.mode = argv[++i] ?? "";
        } else if (arg === "--out-dir") {
            opts.outDir = path.resolve(argv[++i] ?? "");
        } else if (arg === "--runtime-dir") {
            opts.runtimeDir = path.resolve(argv[++i] ?? "");
        } else if (arg === "--version") {
            opts.version = argv[++i] ?? "";
        } else if (arg === "--no-zip") {
            opts.zip = false;
        } else if (arg === "-h" || arg === "--help") {
            console.log(
                "用法: node tools/export-html.mjs [--mode server|html|both] [--out-dir <dir>] [--runtime-dir <dir>] [--version <ver>] [--no-zip]",
            );
            process.exit(0);
        } else {
            throw new Error(`未知参数: ${arg}`);
        }
    }
    if (!["server", "html", "both"].includes(opts.mode)) {
        throw new Error(`不支持的 --mode: ${opts.mode}（可选 server | html | both）`);
    }
    if (!opts.version) {
        try {
            opts.version = execFileSync("git", ["-C", PROJECT, "describe", "--tags", "--always"], {
                encoding: "utf8",
                stdio: ["ignore", "pipe", "ignore"],
            }).trim();
        } catch {
            opts.version = "dev";
        }
    }
    return opts;
}

function hasRuntimeMarker(dir) {
    if (!dir || !fs.existsSync(dir)) return false;
    return (
        fs.existsSync(path.join(dir, "runtime.json")) ||
        fs.existsSync(path.join(dir, "runtime.json.gz"))
    );
}

function resolveRuntimeDir(explicitDir) {
    const home = process.env.HOME ?? "";
    const doraApp = process.env.DORA_APP ?? "";
    const candidates = [
        explicitDir,
        process.env.DORA_WEB_RUNTIME_DIR,
        doraApp ? path.join(doraApp, "Contents/Resources/www/web-player") : "",
        doraApp ? path.join(doraApp, "usr/share/dora-ssr/Assets/www/web-player") : "",
        doraApp ? path.join(doraApp, "www/web-player") : "",
        doraApp ? path.join(doraApp, "web-player") : "",
        doraApp,
        path.join(home, ".local/opt/dora-ssr/squashfs-root/usr/share/dora-ssr/Assets/www/web-player"),
        "/usr/share/dora-ssr/Assets/www/web-player",
        "/Applications/Dora.app/Contents/Resources/www/web-player",
        "/Applications/Dora SSR.app/Contents/Resources/www/web-player",
        path.join(home, "Applications/Dora.app/Contents/Resources/www/web-player"),
    ].filter(Boolean);

    for (const dir of candidates) {
        if (hasRuntimeMarker(dir)) {
            return dir;
        }
    }
    throw new Error(
        "找不到 Dora SSR web-player 运行时目录。请通过 --runtime-dir 或环境变量 DORA_WEB_RUNTIME_DIR / DORA_APP 指定。",
    );
}

function readRuntimeFile(runtimeDir, name) {
    const plain = path.join(runtimeDir, name);
    const gz = plain + ".gz";
    if (fs.existsSync(plain)) {
        return new Uint8Array(fs.readFileSync(plain));
    }
    if (fs.existsSync(gz)) {
        return new Uint8Array(zlib.gunzipSync(fs.readFileSync(gz)));
    }
    throw new Error(`缺少 Dora Web 运行时文件: ${name}（目录: ${runtimeDir}）`);
}

function loadAndVerifyRuntime(runtimeDir) {
    const files = {};
    for (const name of RUNTIME_CORE_NAMES) {
        files[name] = readRuntimeFile(runtimeDir, name);
    }
    const runtimeIndex = JSON.parse(dec(files["runtime.json"]));
    for (const [name, data] of Object.entries(files)) {
        const meta = runtimeIndex.files?.[name];
        if (!meta) continue;
        if (data.length !== meta.size) {
            throw new Error(`运行时文件大小不符 ${name}: ${data.length} != ${meta.size}`);
        }
        const actualSha = sha256(data);
        if (actualSha !== meta.sha256) {
            throw new Error(`运行时文件 SHA-256 校验失败 ${name}: ${actualSha} != ${meta.sha256}`);
        }
    }
    const features = JSON.parse(dec(files["dora-web-features.json"]));
    if (features.activeProfile !== "dora-preset") {
        throw new Error(`Web 运行时 profile 必须为 dora-preset，当前为: ${features.activeProfile}`);
    }
    return { files, runtimeIndex };
}

function loadWebBrandIcons() {
    const iconDir = path.join(PROJECT, "art-source", "brand", "icons", "web");
    const icons = {};
    for (const name of WEB_BRAND_ICON_NAMES) {
        const abs = path.join(iconDir, name);
        if (!fs.existsSync(abs)) {
            throw new Error(`缺少统一 Web 品牌图标: art-source/brand/icons/web/${name}`);
        }
        icons[name] = new Uint8Array(fs.readFileSync(abs));
    }
    icons["site.webmanifest"] = enc(
        JSON.stringify(
            {
                name: "向西守望",
                short_name: "向西守望",
                description: "明初温州宁村所双线叙事游戏 · 局外人出品",
                start_url: "./",
                display: "fullscreen",
                background_color: "#0a0c12",
                theme_color: "#0a0c12",
                icons: [
                    { src: "icon-192.png", sizes: "192x192", type: "image/png" },
                    { src: "icon-512.png", sizes: "512x512", type: "image/png" },
                ],
            },
            null,
            2,
        ) + "\n",
    );
    return icons;
}

/**
 * 严格白名单收集游戏运行时文件（与 tools/make-windows-pack.sh / tools/make-android-pack.sh 对齐）：
 * - init.lua
 * - Script/watch/**\/*.lua（排除调试用 testdrive.lua）
 * - assets/**（排除隐藏文件、macOS AppleDouble 与说明文档 *.md）
 */
function collectGameFiles() {
    const out = {};

    const initPath = path.join(PROJECT, "init.lua");
    if (!fs.existsSync(initPath)) {
        throw new Error("缺少 init.lua：请先执行 Dora TS 编译（Dora cli build --lang ts）。");
    }
    out["init.lua"] = new Uint8Array(fs.readFileSync(initPath));

    const excludedTargetDirs = new Set([
        "Script/watch/targets/windows",
        "Script/watch/targets/android",
        "Script/watch/targets/handheld",
    ]);

    function walkLua(dir, relPrefix) {
        for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
            if (ent.name.startsWith(".")) continue;
            const abs = path.join(dir, ent.name);
            const rel = `${relPrefix}/${ent.name}`;
            if (ent.isDirectory()) {
                if (excludedTargetDirs.has(rel)) continue;
                walkLua(abs, rel);
            } else if (ent.isFile() && ent.name.endsWith(".lua")) {
                if (rel === "Script/watch/testdrive.lua") continue;
                out[rel] = new Uint8Array(fs.readFileSync(abs));
            }
        }
    }

    function walkAssets(dir, relPrefix) {
        for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
            if (ent.name.startsWith(".") || ent.name === "Thumbs.db") continue;
            const abs = path.join(dir, ent.name);
            const rel = `${relPrefix}/${ent.name}`;
            if (ent.isDirectory()) {
                walkAssets(abs, rel);
            } else if (ent.isFile()) {
                if (ent.name.toLowerCase().endsWith(".md")) continue;
                out[rel] = new Uint8Array(fs.readFileSync(abs));
            }
        }
    }

    const watchDir = path.join(PROJECT, "Script", "watch");
    const assetsDir = path.join(PROJECT, "assets");
    if (!fs.existsSync(watchDir) || !fs.existsSync(assetsDir)) {
        throw new Error("项目结构不完整：缺少 Script/watch 或 assets 目录。");
    }
    walkLua(watchDir, "Script/watch");
    walkAssets(assetsDir, "assets");

    // 静态绑定 Web 全包含目标，避免运行时动态字符串拼接与无用端分支
    out["Script/watch/target.lua"] = enc(
        [
            "local ____exports = {}",
            'local ____target = require("Script.watch.targets.web.index").TARGET',
            "function ____exports.resolveTargetId()",
            '\treturn "web"',
            "end",
            "function ____exports.resetActiveTarget()",
            "end",
            "function ____exports.getActiveTarget()",
            "\treturn ____target",
            "end",
            "return ____exports",
            "",
        ].join("\n"),
    );

    for (const required of [
        "init.lua",
        "Script/watch/app.lua",
        "Script/watch/target.lua",
        "Script/watch/target_types.lua",
        "Script/watch/platform.lua",
        "Script/watch/platform_mobile.lua",
        "Script/watch/controls_config.lua",
        "Script/watch/input.lua",
        "Script/watch/input/kbm_core.lua",
        "Script/watch/input/aim_assist.lua",
        "Script/watch/input/gamepad_core.lua",
        "Script/watch/input/touch_core.lua",
        "Script/watch/input/touch_interact_meta.lua",
        "Script/watch/input/touch_hud_landscape.lua",
        "Script/watch/input/touch_hud_portrait.lua",
        "Script/watch/targets/web/index.lua",
        "Script/watch/fe/frontend.lua",
        "Script/watch/fe/renderer/anim_controller.lua",
        "Script/watch/fe/renderer/scene_fx.lua",
        "Script/watch/fe/scenes/dark_pixel_assets.lua",
        "Script/watch/fe/scenes/xiaoman3d.lua",
        "Script/watch/fe/scenes/xiaoman3d_actor.lua",
        "Script/watch/fe/scenes/xiaoman3d_entities.lua",
        "assets/xiaoman3d/outside.glb",
        "assets/xiaoman3d/village.glb",
        "assets/xiaoman3d/forest.glb",
        "assets/xiaoman3d/tower.glb",
        "assets/xiaoman3d/xiaoman.glb",
        "assets/xiaoman3d/scavenger.glb",
        "assets/xiaoman3d/dog.glb",
        "assets/xiaoman3d/guard.glb",
        "assets/xiaoman3d/cart.glb",
        "assets/xiaoman3d/bottle.glb",
        "assets/xiaoman3d/basin.glb",
        "assets/xiaoman3d/door.glb",
        "assets/xiaoman3d/lantern.glb",
        "assets/xiaoman3d/ledger.glb",
        "assets/xiaoman3d/pouch.glb",
        "assets/xiaoman3d/latch.glb",
        "assets/xiaoman3d/grass.glb",
        "assets/xiaoman3d/twig.glb",
        "assets/xiaoman3d/bough.glb",
        "assets/xiaoman3d/sky_backdrop.glb",
        "assets/art/title.png",
        "assets/art/tex_diorama_ming.clip",
        "assets/art/tex_diorama_ming.png",
        "assets/art/diorama_cutouts.clip",
        "assets/art/diorama_cutouts.png",
        "assets/art/cutscene_cuff_rig.clip",
        "assets/art/cutscene_cuff_rig.png",
        "assets/art/props_ming.clip",
        "assets/art/props_ming.png",
        "assets/art/actors_extra.clip",
        "assets/art/actors_extra.png",
        "assets/art/vfx_craft_art.clip",
        "assets/art/vfx_craft_art.png",
        "assets/art/bg_escort_ridge.png",
        "assets/art/props_second_half.clip",
        "assets/art/props_second_half.png",
        "assets/art/scene_dark_pixel.clip",
        "assets/art/scene_dark_pixel.png",
        "assets/art/actors_zhoushu_anim.clip",
        "assets/art/actors_zhoushu_anim.png",
        "assets/art/actors_xiaoman_anim.clip",
        "assets/art/actors_xiaoman_anim.png",
        "assets/art/actors_duo_anim.clip",
        "assets/art/actors_duo_anim.png",
        "assets/art/actors_enemies_anim.clip",
        "assets/art/actors_enemies_anim.png",
        "assets/art/vfx_ming_fx.clip",
        "assets/art/vfx_ming_fx.png",
        "assets/art/cutscenes/p01/p01_01_curtain_dark.png",
        "assets/art/cutscenes/p02/p02_01_shadows.png",
        "assets/art/cutscenes/p02/p02_07_bowl_smash.png",
        "assets/art/cutscenes/p03/p03_01_two_fingers.png",
        "assets/art/cutscenes/p05/p05_05_gate_slam_impact.png",
        "assets/art/cutscenes/g05/g05_07_zhoushu_reveal.png",
        "assets/art/cutscenes/gate/gate_04_terrace.png",
        "assets/art/cutscenes/f01/f01_03_thread_pull.png",
        "assets/art/cutscenes/m02/m02_lantern_03_heft.png",
        "assets/art/cutscenes/m02/m02_echo_03_heft.png",
        "assets/art/cutscenes/tower/f03_room_04_lit_bowl.png",
        "assets/art/cutscenes/tower/m03_room_04_bowl.png",
        "assets/art/cutscenes/museum/e01_04_vitrine_emerge.png",
        "assets/art/cutscenes/museum/e02_04_cabinet_cuff_return.png",
        "assets/art/brand/app_icon.png",
        "assets/art/brand/game_logo_h.png",
        "assets/art/brand/game_logo_v.png",
        "assets/art/brand/team_logo_dark.png",
        "assets/font/lxgw-neo-zhisong.ttf",
    ]) {
        if (!out[required]) {
            throw new Error(`白名单产物缺少关键运行文件: ${required}`);
        }
    }
    for (const key of Object.keys(out)) {
        if (
            key.startsWith("Script/watch/targets/windows/") ||
            key.startsWith("Script/watch/targets/android/") ||
            key.startsWith("Script/watch/targets/handheld/")
        ) {
            throw new Error(`Web 白名单意外包含非 Web 目标文件: ${key}`);
        }
    }
    return out;
}

/** 生成兼容 Dora SSR Web Player 契约的宋明水墨响屏壳页面（兼顾键鼠、手柄与多点触屏）。 */
function buildIndexHtml(format, version) {
    const loaderScript = format === "html" ? "html-loader.js" : "dora-player-runtime.js";
    const escapedVersion = String(version).replace(/[<>&"]/g, "");
    return `<!doctype html>
<html lang="zh-CN" data-dora-state="booting">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
	<meta name="theme-color" content="#0a0c12">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
	<link rel="icon" href="favicon.ico" sizes="any">
	<link rel="icon" type="image/png" sizes="32x32" href="favicon-32x32.png">
	<link rel="apple-touch-icon" href="apple-touch-icon.png">
	<link rel="manifest" href="site.webmanifest">
	<title>向西守望 · 网页版</title>
	<style>
		html, body {
			width: 100%;
			height: 100%;
			margin: 0;
			padding: 0;
			overflow: hidden;
			background: #0a0c12;
			overscroll-behavior: none;
			touch-action: none;
			user-select: none;
			-webkit-user-select: none;
			-webkit-touch-callout: none;
			-webkit-tap-highlight-color: transparent;
		}
		canvas {
			display: block;
			width: 100%;
			height: 100%;
			touch-action: none;
			outline: none;
		}
		canvas:focus {
			outline: none;
		}
		#status {
			position: fixed;
			inset: 0;
			display: grid;
			place-items: center;
			padding: env(safe-area-inset-top, 16px) env(safe-area-inset-right, 16px) env(safe-area-inset-bottom, 16px) env(safe-area-inset-left, 16px);
			color: #ece6d8;
			background: radial-gradient(circle at 50% 38%, #161b28 0%, #0b0d14 72%, #07080d 100%);
			font: 14px "LXGW WenKai", "Noto Serif SC", "Songti SC", "STSong", Georgia, serif;
		}
		#status-content {
			width: min(360px, calc(100% - 40px));
			text-align: center;
		}
		#engine-brand {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 10px;
			margin-bottom: 22px;
		}
		#engine-logo {
			display: block;
			width: 80px;
			height: 80px;
			object-fit: contain;
			border-radius: 16px;
			box-shadow: 0 8px 26px rgba(0, 0, 0, 0.45);
		}
		#game-title {
			margin: 0;
			font-size: 30px;
			font-weight: 500;
			letter-spacing: 0.36em;
			text-indent: 0.36em;
			color: #f3ede0;
		}
		#game-sub {
			margin: 0;
			font-size: 12px;
			letter-spacing: 0.14em;
			color: #9ba3b4;
		}
		#status-message {
			min-height: 1.5em;
			font-size: 12px;
			line-height: 1.6;
			color: #b7becb;
			overflow-wrap: anywhere;
		}
		[hidden] { display: none !important; }
		#storage-wait { margin-top: 16px; line-height: 1.6; font-size: 12px; color: #cbd1dc; }
		#storage-wait button {
			margin: 6px 4px 0;
			padding: 8px 14px;
			border: 1px solid rgba(216, 171, 92, 0.55);
			border-radius: 4px;
			background: rgba(20, 24, 34, 0.92);
			color: #f3ede0;
			cursor: pointer;
		}
		#progress-track {
			height: 4px;
			margin-top: 14px;
			overflow: hidden;
			border-radius: 2px;
			background: rgba(255, 255, 255, 0.12);
		}
		#progress-bar {
			width: 100%;
			height: 100%;
			border-radius: inherit;
			background: linear-gradient(90deg, #b83a38 0%, #d8ab5c 100%);
			transform: scaleX(0);
			transform-origin: left;
			transition: transform 120ms ease-out;
		}
		#game-meta {
			margin-top: 16px;
			font-size: 11px;
			color: rgba(164, 173, 190, 0.72);
			letter-spacing: 0.08em;
		}
		html[data-dora-progress="indeterminate"] #progress-bar {
			width: 38%;
			animation: dora-progress 1.15s ease-in-out infinite;
		}
		html[data-dora-state="faulted"] #progress-track { display: none; }
		html[data-dora-state="running"] #status,
		html[data-dora-state="stopped"] #status { display: none; }
		@keyframes dora-progress {
			from { transform: translateX(-105%); }
			to { transform: translateX(365%); }
		}
		@media (max-height: 420px) {
			#engine-brand { margin-bottom: 10px; gap: 6px; }
			#engine-logo { width: 52px; height: 52px; border-radius: 10px; }
			#game-title { font-size: 22px; }
		}
		@media (prefers-reduced-motion: reduce) {
			#progress-bar { transition: none; }
			html[data-dora-progress="indeterminate"] #progress-bar { animation-duration: 2.3s; }
		}
	</style>
</head>
<body>
	<canvas id="canvas" tabindex="0"></canvas>
	<div id="status" role="status">
		<div id="status-content">
			<div id="engine-brand">
				<img id="engine-logo" src="icon-192.png" alt="向西守望" width="80" height="80">
				<h1 id="game-title">向西守望</h1>
				<p id="game-sub">键鼠 · 触屏 · 手柄全支持 · 横竖屏自适应</p>
			</div>
			<div id="status-message">正在载入《向西守望》…</div>
			<div id="storage-wait" hidden>
				<p>本地存档正在同步，若另一标签页占用了存档请稍候或刷新页面。</p>
				<button id="storage-continue" type="button">继续等待</button>
				<button id="storage-reload" type="button">刷新页面</button>
			</div>
			<div id="progress-track"><div id="progress-bar" role="progressbar" aria-label="Loading game resources"></div></div>
			<div id="game-meta">Powered by Dora SSR · ${escapedVersion}</div>
		</div>
	</div>
	<script>
		performance.mark("dora-shell-ready");
		(function() {
			const canvas = document.getElementById("canvas");
			const focusCanvas = function() {
				try { canvas.focus({ preventScroll: true }); } catch (_) { canvas.focus(); }
			};
			canvas.addEventListener("contextmenu", function(e) { e.preventDefault(); });
			canvas.addEventListener("pointerdown", focusCanvas, { passive: true });
			canvas.addEventListener("touchstart", focusCanvas, { passive: true });
			window.addEventListener("keydown", function(e) {
				if (e.code === "Space" || e.code === "ArrowUp" || e.code === "ArrowDown" || e.code === "ArrowLeft" || e.code === "ArrowRight") {
					if (document.activeElement !== canvas) focusCanvas();
				}
			});
		})();
		window.doraSetProgress = function(value, detail) {
			const root = document.documentElement;
			const bar = document.getElementById("progress-bar");
			const message = document.getElementById("status-message");
			if (root.dataset.doraState === "faulted") return;
			if (detail) message.textContent = detail;
			if (!Number.isFinite(value)) {
				root.dataset.doraProgress = "indeterminate";
				bar.removeAttribute("aria-valuenow");
				return;
			}
			const progress = Math.max(0, Math.min(1, value));
			root.dataset.doraProgress = "determinate";
			bar.style.transform = "scaleX(" + progress + ")";
			bar.setAttribute("aria-valuemin", "0");
			bar.setAttribute("aria-valuemax", "100");
			bar.setAttribute("aria-valuenow", String(Math.round(progress * 100)));
		};
		window.doraSetState = function(state, detail) {
			performance.mark("dora-state-" + state);
			if (document.documentElement.dataset.doraState === "faulted") return;
			if (state === "faulted") {
				console.error("[DoraWeb] Runtime failed:", detail || "Dora SSR failed to start.");
				if (typeof Module !== "undefined") Module.doraStartupFailed = true;
			}
			if (state === "faulted" || state === "running" || state === "stopped") {
				document.getElementById("storage-wait").hidden = true;
			}
			document.documentElement.dataset.doraState = state;
			const message = document.getElementById("status-message");
			if (state === "faulted") message.textContent = detail || "引擎启动失败，请刷新或更换现代浏览器重试。";
			else if (state === "stopping") message.textContent = "正在停止引擎…";
			else if (state === "ready") window.doraSetProgress(1, "正在展开卷轴…");
			else if (state === "running") {
				try { document.getElementById("canvas").focus({ preventScroll: true }); } catch (_) {}
			}
			window.dispatchEvent(new CustomEvent("dora-statechange", { detail: { state, message: detail || "" } }));
			if (state === "running" && new URLSearchParams(location.search).has("dora-test-stop")) {
				setTimeout(function() { window.doraStop(); }, 0);
			}
		};
		window.addEventListener("dora-storage-wait", function(event) {
			const state = document.documentElement.dataset.doraState;
			document.getElementById("storage-wait").hidden = event.detail?.state !== "slow"
				|| (state !== "booting" && state !== "ready");
		});
		document.getElementById("storage-continue").addEventListener("click", function() {
			window.dispatchEvent(new Event("dora-storage-wait-continue"));
		});
		document.getElementById("storage-reload").addEventListener("click", function() {
			window.location.reload();
		});
		const startupError = function(event) {
			const state = document.documentElement.dataset.doraState;
			if (state !== "booting" && state !== "ready") return;
			if (event.filename !== new URL("dora-player-runtime.js", document.baseURI).href) return;
			const error = event.error;
			window.doraSetState("faulted", String(error?.message || error || event.message || "Dora SSR failed to start."));
		};
		window.addEventListener("error", startupError);
		var Module = {
			doraGodotEnabled: false,
			canvas: document.getElementById("canvas"),
			setStatus: function(status) {
				const match = /\\((\\d+)\\/(\\d+)\\)/.exec(status || "");
				if (match && Number(match[2]) > 0) window.doraSetProgress((Number(match[1]) / Number(match[2])) * 0.5, "正在载入引擎运行时…");
				else if (status && status !== "Running...") window.doraSetProgress(NaN, status);
			},
			doraReportProgress: function(loaded, total, detail) {
				window.doraSetProgress(total > 0 ? 0.5 + (loaded / total) * 0.48 : NaN, detail || "正在载入水墨资源…");
			},
			onRuntimeInitialized: function() { window.doraSetState("ready"); },
			onAbort: function(reason) { window.doraSetState("faulted", String(reason || "Runtime aborted")); },
			onExit: function(status) {
				if (status !== 0 && document.documentElement.dataset.doraState !== "faulted") {
					window.doraSetState("faulted", "Dora SSR exited with code " + status);
				}
			}
		};
		window.doraSetProgress(0, "正在载入引擎运行时…");
		window.doraStop = function() {
			if (document.documentElement.dataset.doraState !== "running") return false;
			window.doraSetState("stopping");
			window.DoraWebPlatform?.dispose();
			Module.ccall("dora_web_stop", null, [], []);
			return true;
		};
		window.addEventListener("dora-stop-request", window.doraStop);
	</script>
	<script src="${loaderScript}"></script>
</body>
</html>
`;
}

/** 适配离线 HTML 模式的 dora-player-runtime.js 音频路径定位钩子（与 Dora Web IDE 官方一致）。 */
function patchRuntimeForHtml(bytes) {
    let text = dec(bytes);
    for (const assetName of ["dora-audio-mixer.wasm", "audio-worklet.js"]) {
        const needle = `new URL("${assetName}",base)`;
        if (text.split(needle).length !== 2) {
            throw new Error(`dora-player-runtime.js 缺少预期定位片段: ${needle}`);
        }
        text = text.replace(needle, `Module.locateFile("${assetName}")`);
    }
    return enc(text);
}

/** 离线 HTML 引导器（与 Dora SSR v1.10.2 Web IDE 官方 html-loader.js 契约完全一致）。 */
const HTML_LOADER_FN = `async function(config) {
  'use strict';
  const root = new URL('.', document.baseURI);
  const blobs = [];
  const pending = new Map();
  const queue = [];
  const cancelLoads = new Set();
  const optionalAudio = new Set(['dora-audio-mixer.wasm', 'audio-worklet.js']);
  let failure = null;
  let clearResources = () => {};
  let active = 0, loaded = 0;
  const total = Object.values(config.records).reduce((sum, file) => sum + file.size, 0);
  const checksum = async bytes => Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', bytes)), byte => byte.toString(16).padStart(2, '0')).join('');
  const fail = error => {
    if (failure) return;
    failure = error;
    for (const job of queue.splice(0)) job.reject(error);
    for (const cancel of Array.from(cancelLoads)) cancel(error);
    clearResources();
    release();
    console.error(error);
    window.doraSetState('faulted', error.message || String(error));
  };
  const release = () => { for (const url of blobs) URL.revokeObjectURL(url); blobs.length = 0; };
  window.addEventListener('pagehide', event => { if (!event.persisted) { clearResources(); release(); } });
  function pump() {
    while (!failure && active < 4 && queue.length) {
      const {name, resolve, reject} = queue.shift();
      const record = config.records[name];
      const script = document.createElement('script');
      active++;
      let delivered = false, finished = false;
      const finish = () => {
        if (finished) return;
        finished = true;
        clearTimeout(timer);
        script.remove();
        pending.delete(name);
        cancelLoads.delete(cancel);
        active--;
        pump();
      };
      const cancel = error => { reject(error); finish(); };
      const timer = setTimeout(() => { reject(new Error('Timed out loading ' + record.script)); finish(); }, optionalAudio.has(name) ? 15000 : 120000);
      cancelLoads.add(cancel);
      pending.set(name, encoded => {
        if (delivered) return;
        delivered = true;
        (async () => {
          const raw = atob(encoded);
          if (raw.length !== record.size) throw new Error('HTML asset size mismatch: ' + name);
          const bytes = new Uint8Array(raw.length);
          for (let index = 0; index < raw.length; index++) bytes[index] = raw.charCodeAt(index);
          if (await checksum(bytes) !== record.sha256) throw new Error('HTML asset checksum mismatch: ' + name);
          if (failure) return;
          loaded += bytes.length;
          window.doraSetProgress(0.5 * loaded / total, '正在载入水墨资源…');
          resolve(bytes);
        })().catch(reject).finally(finish);
      });
      script.onload = () => { if (!delivered) { reject(new Error('Invalid HTML asset: ' + record.script)); finish(); } };
      script.onerror = () => { reject(new Error('Unable to load ' + record.script + '. Extract the entire ZIP before opening index.html.')); finish(); };
      script.src = new URL(record.script, root).href;
      document.body.appendChild(script);
    }
  }
  function read(name) {
    if (failure) return Promise.reject(failure);
    if (!Object.hasOwn(config.records, name)) return Promise.reject(new Error('Unknown HTML asset: ' + name));
    return new Promise((resolve, reject) => { queue.push({name, resolve, reject}); pump(); });
  }
  window.DoraHtmlPackage = Object.freeze({deliver: (name, encoded) => pending.get(name)?.(encoded)});
  try {
    if (!window.WebAssembly || !window.crypto?.subtle) throw new Error('Please use a modern browser with WebAssembly and Web Crypto support.');
    const names = Object.keys(config.records);
    const values = await Promise.all(names.map(name => read(name).catch(error => {
      if (!optionalAudio.has(name)) throw error;
      Module.doraAudioWorklet = false;
      console.warn('[DoraAudio] Optional worklet resource unavailable; trying legacy audio:', name, error);
      return null;
    })));
    const files = new Map(names.flatMap((name, index) => values[index] ? [[name, values[index]]] : []));
    window.DoraHtmlPackage = Object.freeze({deliver() {}});
    let preload = files.get('dora-player-runtime.data').buffer;
    clearResources = () => {
      preload = null;
      delete Module.doraSnapshot;
      delete Module.wasmBinary;
      delete Module.getPreloadedPackage;
      files.clear();
      values.length = 0;
    };
    Module.wasmBinary = files.get('dora-player-runtime.wasm');
    Module.getPreloadedPackage = () => { const bytes = preload; preload = null; return bytes; };
    Module.doraSnapshot = {manifest: config.manifest, files: config.manifest.files.map(file => ({path: file.path, bytes: files.get(decodeURIComponent(file.url))}))};
    Module.doraStorageId = 'html-' + await checksum(new TextEncoder().encode(root.href));
    const audio = new Map();
    for (const [name, type] of [['dora-audio-mixer.wasm', 'application/wasm'], ['audio-worklet.js', 'text/javascript']]) {
      if (!files.has(name)) continue;
      if (name === 'audio-worklet.js') {
        let source = '';
        for (const byte of files.get(name)) source += String.fromCharCode(byte);
        audio.set(name, 'data:text/javascript;base64,' + btoa(source));
        continue;
      }
      const url = URL.createObjectURL(new Blob([files.get(name)], {type}));
      audio.set(name, url);
      blobs.push(url);
    }
    Module.locateFile = (name, prefix = '') => audio.get(name) || new URL(name, prefix || root).href;
    const initialized = Module.onRuntimeInitialized;
    Module.onRuntimeInitialized = function() {
      clearResources();
      initialized?.();
    };
    const aborted = Module.onAbort;
    Module.onAbort = function(reason) {
      fail(new Error(String(reason || 'Runtime aborted')));
      aborted?.(reason);
    };
    const script = document.createElement('script');
    script.src = new URL('dora-player-runtime.js', root).href;
    script.onerror = () => fail(new Error('Unable to load the engine. Extract the entire ZIP before opening index.html.'));
    document.body.appendChild(script);
  } catch (error) { fail(error); }
}`;

function assembleServerPackage(runtimeFiles, runtimeIndex, brandIcons, gameFiles, version) {
    const files = { ...runtimeFiles, ...brandIcons };
    files["index.html"] = enc(buildIndexHtml("server", version));
    files[".nojekyll"] = enc("");
    files["runtime.json"] = enc(
        JSON.stringify({
            ...runtimeIndex,
            files: Object.fromEntries(
                Object.entries(files)
                    .filter(([k]) => k !== "runtime.json" && k !== ".nojekyll")
                    .map(([k, v]) => [k, { size: v.length, sha256: sha256(v) }]),
            ),
        }),
    );

    const manifestFiles = [];
    let gameBytes = 0;
    for (const rel of Object.keys(gameFiles).sort()) {
        const data = gameFiles[rel];
        gameBytes += data.length;
        const hash = sha256(data);
        const key = `assets/${hash}/${rel}`;
        files[key] = data;
        manifestFiles.push({
            path: rel,
            url: key.split("/").map(encodeURIComponent).join("/"),
            size: data.length,
            sha256: hash,
            startup: true,
        });
    }

    const manifest = {
        format: "dora-web-game",
        version: 1,
        engineVersion: runtimeIndex.engineVersion,
        profile: "dora-preset",
        entry: "init.lua",
        files: manifestFiles,
    };
    files["dora-web-manifest.json"] = enc(JSON.stringify(manifest, null, 2));
    files["README-Web.txt"] = enc(
        "《向西守望》Web 静态部署包（GitHub Pages / HTTPS）\n\n" +
            "将整个目录部署到 GitHub Pages 或任意静态网站，通过 HTTPS 或 localhost 打开 index.html 即可游玩（支持键鼠、触屏与手柄，横竖屏自适应）。\n",
    );
    return { files, gameBytes, manifest };
}

function convertToHtmlPackage(serverFiles, runtimeIndex, manifest, version) {
    const out = { ...serverFiles };
    delete out[".nojekyll"];
    out["index.html"] = enc(buildIndexHtml("html", version));
    out["dora-player-runtime.js"] = patchRuntimeForHtml(serverFiles["dora-player-runtime.js"]);

    const records = Object.create(null);
    const wrappedKeys = [
        "dora-player-runtime.wasm",
        "dora-player-runtime.data",
        "dora-audio-mixer.wasm",
        "audio-worklet.js",
        ...manifest.files.map((f) => decodeURIComponent(f.url)),
    ];

    for (let idx = 0; idx < wrappedKeys.length; idx++) {
        const key = wrappedKeys[idx];
        const data = out[key];
        if (!data) {
            throw new Error(`离线 HTML 封装缺少资源: ${key}`);
        }
        const scriptRel = `html-assets/${idx}.js`;
        records[key] = {
            script: scriptRel,
            size: data.length,
            sha256: sha256(data),
        };
        const b64 = Buffer.from(data).toString("base64");
        out[scriptRel] = enc(`DoraHtmlPackage.deliver(${JSON.stringify(key)},"${b64}");\n`);
        delete out[key];
    }

    out["html-loader.js"] = enc(`(${HTML_LOADER_FN})(${JSON.stringify({ manifest, records })});\n`);
    delete out["dora-web-manifest.json"];
    out["README-Web.txt"] = enc(
        "《向西守望》离线 HTML 包\n\n" +
            "完整解压 ZIP 后，双击根目录 index.html 即可在现代浏览器中启动，无需启动本地 HTTP 服务器（支持键鼠、触屏与手柄）。\n",
    );
    out["runtime.json"] = enc(
        JSON.stringify({
            ...runtimeIndex,
            format: "html",
            files: Object.fromEntries(
                Object.entries(out)
                    .filter(([k]) => k !== "runtime.json")
                    .map(([k, v]) => [k, { size: v.length, sha256: sha256(v) }]),
            ),
        }),
    );
    return out;
}

function writeTree(dir, files) {
    fs.rmSync(dir, { recursive: true, force: true });
    let totalBytes = 0;
    for (const [rel, data] of Object.entries(files)) {
        const dest = path.join(dir, rel);
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.writeFileSync(dest, data);
        totalBytes += data.length;
    }
    return totalBytes;
}

function makeZip(dir, zipPath) {
    fs.rmSync(zipPath, { force: true });
    execFileSync("zip", ["-q", "-r", zipPath, "."], { cwd: dir });
    return fs.statSync(zipPath).size;
}

function formatMB(bytes) {
    return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

function main() {
    const opts = parseArgs(process.argv.slice(2));
    const runtimeDir = resolveRuntimeDir(opts.runtimeDir);
    const { files: runtimeFiles, runtimeIndex } = loadAndVerifyRuntime(runtimeDir);
    const brandIcons = loadWebBrandIcons();
    const gameFiles = collectGameFiles();

    fs.mkdirSync(opts.outDir, { recursive: true });
    const { files: serverFiles, gameBytes, manifest } = assembleServerPackage(
        runtimeFiles,
        runtimeIndex,
        brandIcons,
        gameFiles,
        opts.version,
    );

    console.log(
        `[export-web] 运行时: ${runtimeDir} (Dora ${runtimeIndex.engineVersion}, profile=dora-preset)`,
    );
    console.log(
        `[export-web] 游戏白名单资源: ${manifest.files.length} 个文件，共 ${formatMB(gameBytes)}`,
    );

    if (opts.mode === "server" || opts.mode === "both") {
        const serverDir = path.join(opts.outDir, "web-server");
        const bytes = writeTree(serverDir, serverFiles);
        console.log(
            `[export-web] server 目录: ${serverDir}（${Object.keys(serverFiles).length} 个文件，共 ${formatMB(bytes)}）`,
        );
        if (opts.zip) {
            const zipPath = path.join(opts.outDir, `WestwardWatch-${opts.version}-web-server.zip`);
            const zSize = makeZip(serverDir, zipPath);
            console.log(`[export-web] server ZIP: ${zipPath}（${formatMB(zSize)}）`);
        }
    }

    if (opts.mode === "html" || opts.mode === "both") {
        const htmlFiles = convertToHtmlPackage(serverFiles, runtimeIndex, manifest, opts.version);
        const htmlDir = path.join(opts.outDir, "web-html");
        const bytes = writeTree(htmlDir, htmlFiles);
        console.log(
            `[export-web] html 目录: ${htmlDir}（${Object.keys(htmlFiles).length} 个文件，共 ${formatMB(bytes)}）`,
        );
        if (opts.zip) {
            const zipPath = path.join(opts.outDir, `WestwardWatch-${opts.version}-web-html.zip`);
            const zSize = makeZip(htmlDir, zipPath);
            console.log(`[export-web] html ZIP: ${zipPath}（${formatMB(zSize)}）`);
        }
    }
}

main();
