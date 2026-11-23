/**
 * Dora SSR 项目 → 可双击打开的离线 HTML 包（等价于 Web IDE「导出 HTML」）。
 *
 * 为什么不用 Web IDE：`POST /zip` 需要 Web IDE 页面会话里的 authToken，
 * 命令行拿不到；Web IDE 的工程树又只覆盖它自己的工作空间。
 * 这里复用 Web IDE 自己的前端 bundle（Re 生成 index.html、Fe 打包 html 版），
 * 只把需要 token 的压缩步骤换成命令行 zip。
 *
 * 用法：
 *   node tools/export-html.mjs            # 导出并打包到 .download/
 *   node tools/export-html.mjs --no-zip   # 只组装目录，不打包
 *
 * 环境变量：DORA_APP 指定 Dora SSR.app 路径（默认 /Applications 与 ~/Applications 自动探测）。
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const PROJECT = process.cwd();
const OUT_DIR = path.join(PROJECT, '.download', 'web-html');
const WORK_DIR = path.join(PROJECT, '.cache', 'dora-export-assets');
const ZIP = path.join(PROJECT, '.download', `${path.basename(PROJECT)}-web-html.zip`);

function findApp() {
    const candidates = [
        process.env.DORA_APP,
        '/Applications/Dora.app',
        '/Applications/Dora SSR.app',
        path.join(process.env.HOME ?? '', 'Applications/Dora.app'),
    ].filter(Boolean);
    for (const c of candidates) {
        if (fs.existsSync(path.join(c, 'Contents/Resources/www/assets'))) return c;
    }
    throw new Error('找不到 Dora SSR.app，请用 DORA_APP 指定');
}

const APP = findApp();
const WWW = path.join(APP, 'Contents/Resources/www');
const ASSETS = path.join(WWW, 'assets');
const RUNTIME_DIR = path.join(WWW, 'web-player');
const enc = (s) => new TextEncoder().encode(s);

// ---------- 1. 准备 Web IDE 前端 bundle（可 import 的最小依赖集） ----------
function prepareBundle() {
    fs.mkdirSync(WORK_DIR, { recursive: true });
    fs.writeFileSync(path.join(WORK_DIR, 'package.json'), '{"type":"module"}\n');

    const entry = fs.readdirSync(ASSETS).find((n) => /^Service-[\w-]+\.js\.gz$/.test(n));
    if (!entry) throw new Error('Dora Web IDE 资源里找不到 Service-*.js.gz');
    const pending = [entry.replace(/\.gz$/, '')];
    const seen = new Set();
    while (pending.length > 0) {
        const name = pending.pop();
        if (seen.has(name)) continue;
        seen.add(name);
        const gz = path.join(ASSETS, name + '.gz');
        const out = path.join(WORK_DIR, name);
        if (fs.existsSync(gz)) {
            fs.writeFileSync(out, zlib.gunzipSync(fs.readFileSync(gz)));
        } else if (!fs.existsSync(out)) {
            throw new Error('缺少 Web IDE 依赖 chunk：' + name);
        }
        const text = fs.readFileSync(out, 'utf8');
        for (const m of text.matchAll(/["'](\.\/[\w\-.]+\.js)["']/g)) {
            const dep = m[1].slice(2);
            if (!seen.has(dep)) pending.push(dep);
        }
    }

    const service = seen.values().next().value;
    const servicePath = path.join(WORK_DIR, service);
    let text = fs.readFileSync(servicePath, 'utf8');
    if (!text.includes('export{Fe,Ke,Re};')) {
        fs.writeFileSync(servicePath, text + '\nexport{Fe,Ke,Re};\n');
    }
    return servicePath;
}

// node 里跑浏览器 bundle 需要的最小 DOM/宿主环境
globalThis.window = globalThis;
globalThis.self = globalThis;
globalThis.addEventListener = () => {};
globalThis.removeEventListener = () => {};
globalThis.dispatchEvent = () => true;
globalThis.requestAnimationFrame = (cb) => setTimeout(cb, 16);
globalThis.cancelAnimationFrame = (id) => clearTimeout(id);
globalThis.localStorage = { getItem: () => null, setItem() {}, removeItem() {} };
globalThis.sessionStorage = { getItem: () => null, setItem() {}, removeItem() {} };
globalThis.document = {
    baseURI: 'http://localhost:8866/',
    createElement: () => ({ style: {}, setAttribute() {}, appendChild() {}, remove() {}, click() {}, addEventListener() {} }),
    head: { appendChild() {} },
    body: { appendChild() {} },
    querySelector: () => null,
    getElementById: () => null,
    addEventListener() {},
    documentElement: { dataset: {} },
};
globalThis.location = new URL('http://localhost:8866/');
Object.defineProperty(globalThis, 'navigator', { value: { userAgent: 'node' }, configurable: true });
globalThis.matchMedia = () => ({ matches: false, addEventListener() {}, removeEventListener() {} });

const servicePath = prepareBundle();
const { Re, Fe, Ke } = await import(pathToFileURL(servicePath).href);

// ---------- 2. 读运行时文件并校验 sha256 ----------
function runtimeFile(name) {
    const plain = path.join(RUNTIME_DIR, name);
    const gz = plain + '.gz';
    if (fs.existsSync(plain)) return new Uint8Array(fs.readFileSync(plain));
    if (fs.existsSync(gz)) return new Uint8Array(zlib.gunzipSync(fs.readFileSync(gz)));
    throw new Error('缺少 Web 运行时文件：' + name);
}

const RUNTIME_NAMES = [
    'dora-player-runtime.js', 'dora-player-runtime.wasm', 'dora-player-runtime.data',
    'dora-web-features.json', 'audio-worklet.js', 'dora-audio-mixer.wasm', 'dora-logo.png',
    'runtime.json', 'LICENSE-Dora.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt',
];
const runtimeFiles = {};
for (const n of RUNTIME_NAMES) runtimeFiles[n] = runtimeFile(n);

const runtimeIndex = JSON.parse(new TextDecoder().decode(runtimeFiles['runtime.json']));
for (const [n, data] of Object.entries(runtimeFiles)) {
    const meta = runtimeIndex.files[n];
    if (!meta) continue; // LICENSE 等未登记文件
    if (data.length !== meta.size) throw new Error(`运行时文件大小不符 ${n}: ${data.length} != ${meta.size}`);
    if (Ke(data) !== meta.sha256) throw new Error('运行时文件 sha256 不符：' + n);
}

const features = JSON.parse(new TextDecoder().decode(runtimeFiles['dora-web-features.json']));
if (features.activeProfile !== 'dora-preset') throw new Error('Web 运行时 profile 不是 dora-preset：' + features.activeProfile);

// ---------- 3. 读项目文件 ----------
function walk(dir, rel, acc) {
    for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
        if (ent.name.startsWith('.')) continue;
        const r = rel ? rel + '/' + ent.name : ent.name;
        const abs = path.join(dir, ent.name);
        if (ent.isDirectory()) walk(abs, r, acc);
        else if (ent.isFile()) acc[r] = new Uint8Array(fs.readFileSync(abs));
    }
    return acc;
}
const project = walk(PROJECT, '', {});

const keep = (p) => !p.split('/').some((s) => s.startsWith('.') || s === 'node_modules' || s === '__MACOSX')
    && !/(?:^|\/)(?:credentials\.json|config\.db)$|\.log$/i.test(p);

// ---------- 4. 组装 web 包（与 Web IDE 的 qe 同构，format=html） ----------
const files = { ...runtimeFiles };
files['index.html'] = enc(Re('html', false));
files['runtime.json'] = enc(JSON.stringify({
    ...runtimeIndex,
    files: Object.fromEntries(Object.entries(files)
        .filter(([k]) => k !== 'runtime.json')
        .map(([k, v]) => [k, { size: v.length, sha256: Ke(v) }])),
}));

const manifestFiles = [];
let total = 0;
for (const p of Object.keys(project).sort()) {
    if (!keep(p)) continue;
    const data = project[p];
    total += data.length;
    const sha = Ke(data);
    const key = `assets/${sha}/${p}`;
    files[key] = data;
    manifestFiles.push({
        path: p,
        url: key.split('/').map(encodeURIComponent).join('/'),
        size: data.length,
        sha256: sha,
        startup: true,
    });
}
if (!manifestFiles.some((f) => f.path === 'init.lua')) {
    throw new Error('项目里没有 init.lua：请先在 Web IDE 或 CLI 里 build');
}
const manifest = {
    format: 'dora-web-game', version: 1, engineVersion: runtimeIndex.engineVersion,
    profile: 'dora-preset', entry: 'init.lua', files: manifestFiles,
};
files['dora-web-manifest.json'] = enc(JSON.stringify(manifest, null, 2));
files['README-Web.txt'] = enc('Web 游戏 / Web game\n\n将整个目录部署到静态网站，通过 HTTPS 或 localhost 打开 index.html。\n\nDeploy this entire directory to a static web host and open index.html over HTTPS or localhost.\n');

const out = Fe(files, Ke);

// ---------- 5. 落盘 + 打包 ----------
fs.rmSync(OUT_DIR, { recursive: true, force: true });
for (const [name, data] of Object.entries(out)) {
    const dest = path.join(OUT_DIR, name);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, Buffer.from(data));
}
console.log(`[export] ${Object.keys(out).length} 个文件 → ${path.relative(PROJECT, OUT_DIR)}（项目内容 ${total} 字节）`);

if (!process.argv.includes('--no-zip')) {
    fs.rmSync(ZIP, { force: true });
    execFileSync('zip', ['-r', '-q', '-X', ZIP, '.', '-x', '*.DS_Store'], { cwd: OUT_DIR });
    const mb = (fs.statSync(ZIP).size / 1024 / 1024).toFixed(1);
    console.log(`[zip] ${path.relative(PROJECT, ZIP)}（${mb} MB）`);
}
process.exit(0);
