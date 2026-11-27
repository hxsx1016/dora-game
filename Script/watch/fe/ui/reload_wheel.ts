/**
 * 《向西守望》Wave 1 · FE-02：3×3 慢时连线换弹全速 UI 插件（M01）。
 *
 * 核心设计约束：
 * 1. 与后端 Script/watch/reload.ts 及 contract.ts 严格同源：
 *    - 3×3 布局（左下原点 y 向上）：底行 0(起点)/1/2(灯纹)，中行 3/4(铃纹)/5，顶行 6/7/8(枪机复位终点)；
 *    - 8 邻域相连（含斜角，不可跳格、不可重复）；过 4 为回声(echo，优先)，过 2 为照明(light)，其余合法路径为推退(knockback)；
 * 2. 双时钟与慢时联动：
 *    - 面板动画、倒计时与键鼠输入吃全速 ctx.uiDt；暂停时 uiDt=0 与 worldDt=0 双钟同冻，恢复延续当前路径；
 *    - 同步驱动 ctx.audio.setWorldPlaySpeed(timeScale)，结算/超时恢复 1x 常速；
 * 3. 双输入同入口（鼠标拖线/点选 + 键盘方向相邻选点）：
 *    - 规避 app.ts 渲染前 clearEdges()，自维护键鼠物理边沿，避开 Num1..8 / R / G / Tab / F1 / F2；
 *    - 无效跳点或未连到 8 中途松手统一提交 reloadTapNode(0)，清回 [0] 重画且不重计 4 秒倒计时；
 * 4. 宣纸墨线美学与静音/灰度可读：
 *    - 零文字教程（仅在起点绘制小满手指落位提示），按轮廓形状与线型区分推退/铃纹/灯纹三种效果；
 *    - 盘面智能停靠侧方，画内同时可见周戍、背上探手的小满与远处敌人。
 */

import { Color, Content, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { Play } from "Script/watch/play";
import { ZERO_SAFE_INSETS } from "Script/watch/platform";
import { getActiveTarget } from "Script/watch/target";
import { AssetSlotHost } from "Script/watch/fe/assets";
import {
    DualRouteContract,
    DualRouteSnapshot,
    FrontendIntent,
    ReloadEffectKind,
} from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawDiamond,
    drawFiligreeCorners,
    drawHairline,
    drawSilkVeil,
    fillRadialGlow,
    toColor,
} from "Script/watch/fe/theme";

export type ReloadNodeKind = "start" | "plain" | "lamp" | "bell" | "target";

export interface ReloadNodeSpec {
    readonly id: number;
    /** 列 0..2（左到右） */
    readonly col: number;
    /** 行 0..2（下到上，与 Dora 坐标系一致） */
    readonly row: number;
    readonly kind: ReloadNodeKind;
}

export const RELOAD_START_NODE = 0;
export const RELOAD_TARGET_NODE = 8;

/** 3×3 九宫格节点真源表（对齐后端 Script/watch/reload.ts 与 contract.ts） */
export const RELOAD_GRID: readonly ReloadNodeSpec[] = [
    { id: 0, col: 0, row: 0, kind: "start" },
    { id: 1, col: 1, row: 0, kind: "plain" },
    { id: 2, col: 2, row: 0, kind: "lamp" },
    { id: 3, col: 0, row: 1, kind: "plain" },
    { id: 4, col: 1, row: 1, kind: "bell" },
    { id: 5, col: 2, row: 1, kind: "plain" },
    { id: 6, col: 0, row: 2, kind: "plain" },
    { id: 7, col: 1, row: 2, kind: "plain" },
    { id: 8, col: 2, row: 2, kind: "target" },
];

/** 8 邻域校验（含斜角，不含自身） */
export function isAdjacentNode(a: number, b: number): boolean {
    if (a === b) {
        return false;
    }
    const na = RELOAD_GRID[a];
    const nb = RELOAD_GRID[b];
    if (na === undefined || nb === undefined) {
        return false;
    }
    return Math.abs(na.col - nb.col) <= 1 && Math.abs(na.row - nb.row) <= 1;
}

/** 完整路径合法性校验：起点 0、每步相邻、不重复、终点 8 */
export function validateReloadPath(path: readonly number[]): boolean {
    if (path.length < 2) {
        return false;
    }
    if (path[0] !== RELOAD_START_NODE || path[path.length - 1] !== RELOAD_TARGET_NODE) {
        return false;
    }
    const seen: Record<number, boolean> = {};
    let i = 0;
    for (i = 0; i < path.length; i++) {
        const n = path[i];
        if (n < 0 || n >= RELOAD_GRID.length || seen[n] === true) {
            return false;
        }
        seen[n] = true;
        if (i > 0 && !isAdjacentNode(path[i - 1], n)) {
            return false;
        }
    }
    return true;
}

/** 按路径经过纹样推导效果（铃纹 4 优先于灯纹 2，其余合法连接为推退 knockback） */
export function deriveEffectFromGrid(path: readonly number[]): ReloadEffectKind {
    if (path.length < 2) {
        return "normal";
    }
    let hasBell = false;
    let hasLamp = false;
    let i = 0;
    for (i = 0; i < path.length; i++) {
        if (path[i] === 4) {
            hasBell = true;
        } else if (path[i] === 2) {
            hasLamp = true;
        }
    }
    if (hasBell) {
        return "echo";
    }
    if (hasLamp) {
        return "light";
    }
    return "knockback";
}

export function reloadEffectShortLabel(effect: ReloadEffectKind): string {
    if (effect === "knockback") {
        return "推退";
    }
    if (effect === "echo") {
        return "回声诱导";
    }
    if (effect === "light") {
        return "照亮遮蔽";
    }
    return "待起笔";
}

/**
 * 绘制静音/灰度可辨的效果几何纹样（供 reload_wheel 与 craft_bench 共享同一符号体系）：
 * - knockback：双尖横冲箭矢（实线）
 * - echo：铜铃轮廓 + 两侧声波弧（虚/双弧）
 * - light：六角提灯轮廓 + 四向破障短芒
 * - normal：素墨空圆
 */
export function drawReloadPatternGlyph(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    radius: number,
    effect: ReloadEffectKind,
    col: RGBA,
    alpha: number = 1,
    uiArt?: AssetSlotHost,
    instanceKey?: string,
    layer: number = 4,
): void {
    const r = Math.max(5, radius);
    if (uiArt !== undefined && instanceKey !== undefined && effect !== "normal") {
        const slot = effect === "echo"
            ? "fe_glyph_bell"
            : (effect === "light" ? "fe_glyph_lamp" : "fe_glyph_push");
        const sz = Math.round(r * 2.2);
        if (uiArt.tryPlace(slot, instanceKey, Math.round(cx), Math.round(cy), sz, sz, {
            color: toColor(col, 255),
            opacity: alpha,
            layer,
        })) {
            return;
        }
    }
    const stroke = toColor(col, 235 * alpha);
    const faint = toColor(col, 130 * alpha);

    if (effect === "echo") {
        // 铜铃外形：圆顶 + 下撇铃口 + 铃舌 + 左右声波短弧
        draw.drawPolygon([
            Vec2(cx - r * 0.56, cy - r * 0.36),
            Vec2(cx + r * 0.56, cy - r * 0.36),
            Vec2(cx + r * 0.34, cy + r * 0.42),
            Vec2(cx, cy + r * 0.62),
            Vec2(cx - r * 0.34, cy + r * 0.42),
        ], Color(0, 0, 0, 0), 1.35, stroke);
        draw.drawDot(Vec2(cx, cy - r * 0.54), Math.max(1.6, r * 0.16), stroke);
        draw.drawArc(Vec2(cx, cy + r * 0.04), r * 0.92, -32, 32, 1.0, faint);
        draw.drawArc(Vec2(cx, cy + r * 0.04), r * 0.92, 148, 212, 1.0, faint);
        return;
    }

    if (effect === "light") {
        // 六角明式提灯 + 芯火菱点 + 四向短芒
        draw.drawPolygon([
            Vec2(cx, cy + r * 0.72),
            Vec2(cx + r * 0.48, cy + r * 0.28),
            Vec2(cx + r * 0.42, cy - r * 0.44),
            Vec2(cx, cy - r * 0.64),
            Vec2(cx - r * 0.42, cy - r * 0.44),
            Vec2(cx - r * 0.48, cy + r * 0.28),
        ], Color(0, 0, 0, 0), 1.35, stroke);
        drawDiamond(draw, cx, cy, r * 0.22, r * 0.30, stroke);
        // 四向破障短芒（灰度下立即可辨）
        draw.drawSegment(Vec2(cx - r * 0.98, cy), Vec2(cx - r * 0.68, cy), 1.1, faint);
        draw.drawSegment(Vec2(cx + r * 0.68, cy), Vec2(cx + r * 0.98, cy), 1.1, faint);
        draw.drawSegment(Vec2(cx, cy + r * 0.80), Vec2(cx, cy + r * 1.04), 1.1, faint);
        draw.drawSegment(Vec2(cx, cy - r * 0.74), Vec2(cx, cy - r * 1.0), 1.1, faint);
        return;
    }

    if (effect === "knockback") {
        // 推退：横冲笔锋箭矢 + 双重破风折翼
        draw.drawSegment(Vec2(cx - r * 0.85, cy), Vec2(cx + r * 0.85, cy), 1.6, stroke);
        draw.drawSegment(Vec2(cx + r * 0.24, cy + r * 0.54), Vec2(cx + r * 0.85, cy), 1.5, stroke);
        draw.drawSegment(Vec2(cx + r * 0.24, cy - r * 0.54), Vec2(cx + r * 0.85, cy), 1.5, stroke);
        draw.drawSegment(Vec2(cx - r * 0.34, cy + r * 0.36), Vec2(cx + r * 0.14, cy), 1.1, faint);
        draw.drawSegment(Vec2(cx - r * 0.34, cy - r * 0.36), Vec2(cx + r * 0.14, cy), 1.1, faint);
        return;
    }

    // normal：素墨空圆
    draw.drawRing(Vec2(cx, cy), r * 0.52, r * 0.68, Color(0, 0, 0, 0), 1.1, faint);
}

interface AppliedEffectVfx {
    effect: ReloadEffectKind;
    originX: number;
    originY: number;
    targetX: number;
    targetY: number;
    facing: number;
    life: number;
    maxLife: number;
}

export interface ReloadClockReadings {
    answerTicks: number;
    worldTicks: number;
    ratio: number;
    active: boolean;
}

export interface ReloadWheelDebugState {
    active: boolean;
    kbCursor: number;
    dragging: boolean;
    path: number[];
    previewEffect: ReloadEffectKind;
    nextEffect: ReloadEffectKind;
    retracting: boolean;
    invalidFlash: number;
    clock: ReloadClockReadings;
    panelCenterX: number;
    panelCenterY: number;
    cellStep: number;
}

interface SimulatedWheelInput {
    pointerX?: number;
    pointerY?: number;
    leftHeld?: boolean;
    rightHeld?: boolean;
    moveCol?: number;
    moveRow?: number;
    confirm?: boolean;
    reset?: boolean;
}

function resolveRuntimeContract(injected?: DualRouteContract): DualRouteContract | undefined {
    if (injected !== undefined) {
        return injected;
    }
    const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
    const loaded = g.package !== undefined ? g.package.loaded : undefined;
    if (loaded === undefined) {
        return undefined;
    }
    const feHook = loaded["watch.fe"];
    if (feHook !== undefined && typeof feHook === "object") {
        const c = (feHook as Record<string, unknown>)["contract"];
        if (c !== undefined && typeof c === "object") {
            return c as DualRouteContract;
        }
    }
    return undefined;
}

function dispatchIntentFallback(p: Play, intent: FrontendIntent): boolean {
    const rec = p as unknown as Record<string, unknown>;
    const handler = rec["submitFeIntent"];
    if (typeof handler === "function") {
        return (handler as (self: Play, req: FrontendIntent) => unknown)(p, intent) !== false;
    }
    const tap = rec["reloadTapNode"];
    if (typeof tap === "function" && intent.kind === "reloadTapNode") {
        (tap as (self: Play, node: number) => void)(p, intent.node);
        return true;
    }
    return false;
}

function readOptionalNum(obj: unknown, key: string): number | undefined {
    if (obj !== undefined && typeof obj === "object") {
        const v = (obj as Record<string, unknown>)[key];
        if (typeof v === "number") {
            return v;
        }
    }
    return undefined;
}

export class ReloadWheelPlugin implements FeRenderPlugin {
    readonly id = "fe-02-reload-wheel";

    private injectedContract: DualRouteContract | undefined;

    private wasActive = false;
    private openAnimT = 0;
    private openDuration = 0.24;
    private retractAnimT = 0;
    private retractDuration = 0.28;
    private settledPath: number[] = [];
    private settledEffect: ReloadEffectKind = "normal";
    private settledTimedOut = false;
    private lastKnownPath: number[] = [RELOAD_START_NODE];
    private lastKnownNextEffect: ReloadEffectKind = "normal";

    // 双输入物理边沿状态（防 app.ts clearEdges 丢边沿）
    private kbCursor = RELOAD_START_NODE;
    private dragging = false;
    private dragAdvanced = false;
    private pointerActive = false;
    private prevLeft = false;
    private prevRight = false;
    private localInvalidFlash = 0;
    private animTime = 0;
    private nodePulseSeq = 0;

    // 面板布局缓存（UI 逻辑坐标）
    private panelCx = 940;
    private panelCy = 374;
    private readonly panelW = 286;
    private readonly panelH = 316;
    private readonly cellStep = 66;
    private readonly hitRadius = 25;
    private resetBox: Rect.Type = Rect(0, 0, 0, 0);
    private lastUiPtrX = 0;
    private lastUiPtrY = 0;

    // 双时钟读数（世界 60 拍 = 作答 240 拍验收）
    private answerTicksAccum = 0;
    private worldTicksAccum = 0;
    private lastClock: ReloadClockReadings = { answerTicks: 0, worldTicks: 0, ratio: 0, active: false };

    // 射击命中后的三种换弹效果轻量水墨反馈
    private appliedVfx: AppliedEffectVfx[] = [];
    private pendingSimInput: SimulatedWheelInput | undefined;

    constructor(contract?: DualRouteContract) {
        this.injectedContract = contract;
    }

    /** 供自动化验证脚本按帧注入键鼠动作（与真实键鼠走同一处理函数） */
    injectInputForTest(sim: SimulatedWheelInput): void {
        this.pendingSimInput = sim;
    }

    getNodeUiPos(nodeId: number): { x: number; y: number } {
        const spec = RELOAD_GRID[nodeId] ?? RELOAD_GRID[0];
        return {
            x: this.panelCx + (spec.col - 1) * this.cellStep,
            y: (this.panelCy - 6) + (spec.row - 1) * this.cellStep,
        };
    }

    getClockReadings(): ReloadClockReadings {
        return {
            answerTicks: this.lastClock.answerTicks,
            worldTicks: this.lastClock.worldTicks,
            ratio: this.lastClock.ratio,
            active: this.lastClock.active,
        };
    }

    getState(): ReloadWheelDebugState {
        return {
            active: this.wasActive,
            kbCursor: this.kbCursor,
            dragging: this.dragging,
            path: this.lastKnownPath.slice(),
            previewEffect: deriveEffectFromGrid(this.lastKnownPath),
            nextEffect: this.lastKnownNextEffect,
            retracting: this.retractAnimT > 0,
            invalidFlash: this.localInvalidFlash,
            clock: this.getClockReadings(),
            panelCenterX: this.panelCx,
            panelCenterY: this.panelCy,
            cellStep: this.cellStep,
        };
    }

    onBindPlay(_p: Play, _view: DualRouteSnapshot): void {
        this.wasActive = false;
        this.openAnimT = 0;
        this.retractAnimT = 0;
        this.settledPath = [];
        this.settledEffect = "normal";
        this.settledTimedOut = false;
        this.lastKnownPath = [RELOAD_START_NODE];
        this.lastKnownNextEffect = "normal";
        this.kbCursor = RELOAD_START_NODE;
        this.dragging = false;
        this.pointerActive = false;
        this.localInvalidFlash = 0;
        this.animTime = 0;
        this.answerTicksAccum = 0;
        this.worldTicksAccum = 0;
        this.lastClock = { answerTicks: 0, worldTicks: 0, ratio: 0, active: false };
        this.appliedVfx = [];
        this.pendingSimInput = undefined;
        this.resetInputEdges();
    }

    private resetInputEdges(_touchMode: boolean = false): void {
        this.prevLeft = false;
        this.prevRight = false;
    }

    private submitIntent(p: Play, intent: FrontendIntent): boolean {
        const contract = resolveRuntimeContract(this.injectedContract);
        if (contract !== undefined) {
            return contract.submitIntent(p, intent);
        }
        return dispatchIntentFallback(p, intent);
    }

    private computePanelPlacement(ctx: FePluginContext): void {
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const soldierUiX = ctx.cam.sx(ctx.p.player.x) / ctx.uiScale;
        const marginX = this.panelW * 0.5 + 34;
        const minCx = marginX + safe.left;
        const maxCx = Math.max(minCx, ctx.uiW - marginX - safe.right);
        if (soldierUiX < ctx.uiW * 0.56) {
            this.panelCx = Math.min(maxCx, Math.max(minCx, Math.max(ctx.uiW * 0.70, soldierUiX + 230)));
        } else {
            this.panelCx = Math.max(minCx, Math.min(maxCx, Math.min(ctx.uiW * 0.30, soldierUiX - 230)));
        }
        const minCy = this.panelH * 0.5 + 78 + safe.bottom;
        const maxCy = Math.max(minCy, ctx.uiH - this.panelH * 0.5 - 66 - safe.top);
        this.panelCy = Math.max(minCy, Math.min(maxCy, ctx.uiH * 0.52));
        this.resetBox = Rect(this.panelCx + 56, this.panelCy + this.panelH * 0.5 - 45, 72, 26);
    }

    update(ctx: FePluginContext): void {
        const rs = ctx.view.reloadSession;
        const p = ctx.p;

        // 无论是否暂停都先刷新面板布局，保证暂停帧屏幕坐标稳定
        this.computePanelPlacement(ctx);

        // 慢时音速同步：开盘按 timeScale 降速，收盘/切房立即恢复 1x
        ctx.audio.setWorldPlaySpeed(rs.active ? Math.max(0.25, Math.min(1, ctx.view.timeScale)) : 1);

        // 暂停态严格冻结全部倒计时、收尾动画、VFX 与输入状态，不丢路径
        if (ctx.paused) {
            this.resetInputEdges(ctx.input.isTouchMode());
            return;
        }

        const udt = Math.max(0, ctx.uiDt);
        const wdt = Math.max(0, ctx.worldDt);
        this.animTime += udt;

        if (this.localInvalidFlash > 0) {
            this.localInvalidFlash = Math.max(0, this.localInvalidFlash - udt);
        }
        if (rs.invalidFlash > this.localInvalidFlash) {
            this.localInvalidFlash = rs.invalidFlash;
        }

        // 追踪后端 reloadApplied 事件（或排演态射击消费 nextEffect）生成轻量化水墨反馈
        this.ingestAppliedEffects(ctx);
        this.updateAppliedVfx(wdt);

        // 监测换弹会话开启/结束边沿
        if (rs.active && !this.wasActive) {
            this.onSessionOpened(ctx);
        } else if (!rs.active && this.wasActive) {
            this.onSessionClosed(ctx);
        }
        this.wasActive = rs.active;

        if (!rs.active) {
            this.lastKnownNextEffect = rs.nextEffect;
            this.lastClock.active = false;
            if (this.retractAnimT > 0) {
                this.retractAnimT = Math.max(0, this.retractAnimT - udt);
            }
            this.pendingSimInput = undefined;
            return;
        }

        // 开盘展开动画（首次 0.24s，二次起 0.10s 短起手）
        this.openAnimT = Math.min(1, this.openAnimT + udt / Math.max(0.01, this.openDuration));

        // 记录双时钟读数（优先读后端真实拍数，排演态按全速 uiDt 与慢速 worldDt 精确累计）
        const liveAns = readOptionalNum(p, "reloadAnswerTicks");
        const liveWorld = readOptionalNum(p, "reloadWorldTicks");
        if (liveAns !== undefined && liveWorld !== undefined && !ctx.view.isRehearsal) {
            this.answerTicksAccum = liveAns;
            this.worldTicksAccum = liveWorld;
        } else {
            this.answerTicksAccum += udt * 60;
            this.worldTicksAccum += wdt * 60;
        }
        this.lastClock = {
            answerTicks: Math.round(this.answerTicksAccum),
            worldTicks: Math.round(this.worldTicksAccum),
            ratio: this.worldTicksAccum > 0.01 ? this.answerTicksAccum / this.worldTicksAccum : 0,
            active: true,
        };

        // 规范化当前有效路径（排演态空数组 [] 视作已落起点 0）
        const activePath = rs.path.length > 0 ? rs.path.slice() : [RELOAD_START_NODE];
        this.lastKnownPath = activePath;
        this.lastKnownNextEffect = rs.nextEffect;

        // 处理全速双输入（鼠标拖线/点选 + 键盘方向相邻选点）
        this.processInputs(ctx, activePath);
    }

    private onSessionOpened(ctx: FePluginContext): void {
        const rs = ctx.view.reloadSession;
        this.openDuration = rs.firstTime ? 0.24 : 0.10;
        this.openAnimT = 0;
        this.retractAnimT = 0;
        this.kbCursor = RELOAD_START_NODE;
        this.dragging = false;
        this.pointerActive = false;
        this.lastKnownPath = rs.path.length > 0 ? rs.path.slice() : [RELOAD_START_NODE];
        this.answerTicksAccum = 0;
        this.worldTicksAccum = 0;
        this.resetInputEdges(ctx.input.isTouchMode());

        let hasBackendOpen = false;
        let i = 0;
        for (i = 0; i < ctx.events.rawEvents.length; i++) {
            if ((ctx.events.rawEvents[i].name as string) === "reloadOpen") {
                hasBackendOpen = true;
                break;
            }
        }
        if (!hasBackendOpen) {
            ctx.audio.playOnce(
                "fe02:reload_open:r" + ctx.events.roomSessionId + ":t" + ctx.p.ticks,
                "sfx",
                "assets/audio/combat/reload_open.wav",
                0.80,
                "reload:open",
                ctx.p.ticks,
            );
        }
    }

    private onSessionClosed(ctx: FePluginContext): void {
        const rs = ctx.view.reloadSession;
        this.dragging = false;
        this.settledPath = this.lastKnownPath.slice();
        if (this.settledPath.length > 0 && this.settledPath[this.settledPath.length - 1] !== RELOAD_TARGET_NODE
            && rs.nextEffect !== "normal") {
            this.settledPath.push(RELOAD_TARGET_NODE);
        }
        this.settledEffect = rs.nextEffect;
        this.settledTimedOut = rs.nextEffect === "normal";
        this.retractAnimT = this.retractDuration;

        // 按结算结果播放对应分轨音（若后端未发对应事件则补播，防重播）
        let hasBackendClose = false;
        let i = 0;
        for (i = 0; i < ctx.events.rawEvents.length; i++) {
            const n = ctx.events.rawEvents[i].name as string;
            if (n === "reloadSolved" || n === "reloadTimeout") {
                hasBackendClose = true;
                break;
            }
        }

        if (this.settledTimedOut) {
            if (!hasBackendClose) {
                ctx.audio.playOnce(
                    "fe02:reload_timeout:r" + ctx.events.roomSessionId + ":t" + ctx.p.ticks,
                    "sfx",
                    "assets/audio/combat/reload_timeout.wav",
                    0.78,
                    "reload:timeout",
                    ctx.p.ticks,
                );
            }
        } else {
            const effectWav = this.settledEffect === "echo"
                ? "assets/audio/combat/reload_solved_echo.wav"
                : (this.settledEffect === "light"
                    ? "assets/audio/combat/reload_solved_light.wav"
                    : "assets/audio/combat/reload_solved_knockback.wav");
            ctx.audio.playOnce(
                "fe02:reload_solved_fx:r" + ctx.events.roomSessionId + ":t" + ctx.p.ticks + ":" + this.settledEffect,
                "sfx",
                effectWav,
                0.88,
                "reload:solved:" + this.settledEffect,
                ctx.p.ticks,
            );
        }
    }

    private processInputs(ctx: FePluginContext, activePath: number[]): void {
        const sim = this.pendingSimInput;
        this.pendingSimInput = undefined;

        const touchMode = ctx.input.isTouchMode();
        const useUiPtr = sim?.pointerX === undefined
            && (ctx.input.uiHeld || ctx.input.uiPressed || ctx.input.uiReleased || (touchMode && ctx.input.uiInside));
        const ptrX = sim?.pointerX !== undefined
            ? sim.pointerX
            : ((useUiPtr ? ctx.input.uiX : ctx.input.mx) / ctx.uiScale);
        const ptrY = sim?.pointerY !== undefined
            ? sim.pointerY
            : ((useUiPtr ? ctx.input.uiY : ctx.input.my) / ctx.uiScale);
        const inside = sim?.pointerX !== undefined
            ? true
            : (useUiPtr ? ctx.input.uiInside : ctx.input.inside);
        const leftHeld = sim?.leftHeld !== undefined
            ? sim.leftHeld
            : (ctx.input.uiHeld || ctx.input.fire.held);
        const rightHeld = sim?.rightHeld !== undefined
            ? sim.rightHeld
            : ctx.input.uiRightPressed;

        const leftPressed = sim?.leftHeld !== undefined
            ? (leftHeld && !this.prevLeft)
            : (ctx.input.uiPressed || (leftHeld && !this.prevLeft));
        const leftReleased = sim?.leftHeld !== undefined
            ? (!leftHeld && this.prevLeft)
            : (ctx.input.uiReleased || (!leftHeld && this.prevLeft));
        const rightPressed = sim?.rightHeld !== undefined
            ? (rightHeld && !this.prevRight)
            : (ctx.input.uiRightPressed || (rightHeld && !this.prevRight));
        this.prevLeft = leftHeld;
        this.prevRight = rightHeld;
        this.lastUiPtrX = ptrX;
        this.lastUiPtrY = ptrY;

        const rawDx = useUiPtr ? ctx.input.uiDx : ctx.input.mdx;
        const rawDy = useUiPtr ? ctx.input.uiDy : ctx.input.mdy;
        const pointerMoved = sim?.pointerX !== undefined
            || (inside && Math.abs(rawDx) + Math.abs(rawDy) >= ctx.uiScale);
        if (pointerMoved || leftPressed) {
            this.pointerActive = true;
        }

        const lastNode = activePath[activePath.length - 1];
        const useTouchHit = touchMode || ctx.input.uiHeld || ctx.input.uiPressed;
        const activeHitR = useTouchHit ? 38 : this.hitRadius;
        const hitNode = inside ? this.hitTestNode(ptrX, ptrY, activeHitR) : -1;

        // 1. 右键或点击「重画」按钮主动清空重画（不重计倒计时）
        const hitResetBtn = inside && (touchMode || activePath.length > 1) && this.resetBox.containsPoint(Vec2(ptrX, ptrY));
        if ((rightPressed || (leftPressed && hitResetBtn)) && activePath.length > 1) {
            this.dragging = false;
            this.dragAdvanced = false;
            this.triggerInvalidReset(ctx, activePath, false);
            return;
        }

        // 2. 鼠标 / 触屏一笔拖线或逐格点选（逐格点选松手不清盘；拖线半途松手清回 [0]）
        if (leftPressed) {
            if (hitNode === RELOAD_START_NODE || hitNode === lastNode) {
                this.dragging = true;
                this.dragAdvanced = false;
                this.kbCursor = lastNode;
            } else if (hitNode >= 0) {
                if (activePath.indexOf(hitNode) < 0 && isAdjacentNode(lastNode, hitNode)) {
                    this.dragging = true;
                    this.dragAdvanced = false;
                    this.commitNodeStep(ctx, hitNode, activePath);
                } else {
                    this.dragging = false;
                    this.dragAdvanced = false;
                    this.triggerInvalidReset(ctx, activePath, true);
                }
                return;
            }
        } else if (this.dragging && leftHeld) {
            if (hitNode >= 0 && hitNode !== lastNode) {
                if (activePath.indexOf(hitNode) < 0 && isAdjacentNode(lastNode, hitNode)) {
                    this.dragAdvanced = true;
                    this.commitNodeStep(ctx, hitNode, activePath);
                } else {
                    // 仅当拖入已访问旧节点（且不是刚离开的当前末点）或非法跳格点时判无效重画
                    this.dragging = false;
                    this.dragAdvanced = false;
                    this.triggerInvalidReset(ctx, activePath, true);
                }
                return;
            }
        } else if (leftReleased && this.dragging) {
            const wasDragStroke = this.dragAdvanced;
            this.dragging = false;
            this.dragAdvanced = false;
            // 仅一笔拖线中途未到终点 8 即松手时清回起点重画；逐格单击相邻点保留路径
            if (wasDragStroke && lastNode !== RELOAD_TARGET_NODE && activePath.length > 1) {
                this.triggerInvalidReset(ctx, activePath, true);
                return;
            }
        }

        // 3. 键盘与手柄 8 向选点（与鼠标/触屏走同一 commitNodeStep / triggerInvalidReset 入口）
        let dCol = 0;
        let dRow = 0;
        let confirmPressed = false;
        let resetPressed = false;
        let gpAutoCommit = false;

        if (sim !== undefined && (sim.moveCol !== undefined || sim.moveRow !== undefined || sim.confirm !== undefined || sim.reset !== undefined)) {
            dCol = sim.moveCol ?? 0;
            dRow = sim.moveRow ?? 0;
            confirmPressed = sim.confirm === true;
            resetPressed = sim.reset === true;
        } else {
            if (ctx.input.reloadReset) {
                resetPressed = true;
            }
            if (ctx.input.reloadConfirm) {
                confirmPressed = true;
            }
            if (ctx.input.reloadStepEdge) {
                dCol = ctx.input.reloadDirCol;
                dRow = ctx.input.reloadDirRow;
                gpAutoCommit = ctx.input.reloadAutoStep;
            }
        }

        if (resetPressed && activePath.length > 1) {
            this.triggerInvalidReset(ctx, activePath, false);
            return;
        }

        if (dCol !== 0 || dRow !== 0) {
            this.pointerActive = false;
            const baseIdx = gpAutoCommit ? lastNode : this.kbCursor;
            const cur = RELOAD_GRID[baseIdx] ?? RELOAD_GRID[0];
            const nextCol = Math.max(0, Math.min(2, cur.col + dCol));
            const nextRow = Math.max(0, Math.min(2, cur.row + dRow));
            const nextIdx = nextRow * 3 + nextCol;
            this.kbCursor = nextIdx;
            if (gpAutoCommit && nextIdx !== lastNode && activePath.indexOf(nextIdx) < 0 && isAdjacentNode(lastNode, nextIdx)) {
                this.commitNodeStep(ctx, nextIdx, activePath);
                return;
            }
        }

        if (confirmPressed) {
            this.pointerActive = false;
            if (this.kbCursor === lastNode) {
                return;
            }
            if (activePath.indexOf(this.kbCursor) < 0 && isAdjacentNode(lastNode, this.kbCursor)) {
                this.commitNodeStep(ctx, this.kbCursor, activePath);
            } else {
                this.triggerInvalidReset(ctx, activePath, true);
            }
        }
    }

    private commitNodeStep(ctx: FePluginContext, node: number, activePath: number[]): void {
        this.kbCursor = node;
        this.submitIntent(ctx.p, { kind: "reloadTapNode", node });
        this.lastKnownPath = activePath.concat([node]);
        if (node === RELOAD_TARGET_NODE) {
            this.dragging = false;
            return;
        }
        // 仅在实际连入节点时亮起并按步数发声（排演或非 live 补播）
        this.nodePulseSeq += 1;
        const stepIdx = Math.max(1, Math.min(6, this.lastKnownPath.length));
        const pitched = "assets/audio/combat/reload_node_" + stepIdx + ".wav";
        const nodePath = Content.exist(pitched) ? pitched : "assets/audio/combat/reload_node.wav";
        ctx.audio.playOnce(
            "fe02:reload_node:r" + ctx.events.roomSessionId + ":n" + this.nodePulseSeq + ":" + node,
            "sfx",
            nodePath,
            0.78,
            "reload:node:" + node,
            ctx.p.ticks,
        );
    }

    private triggerInvalidReset(ctx: FePluginContext, activePath: number[], flashError: boolean): void {
        if (flashError) {
            this.localInvalidFlash = 0.36;
        }
        this.kbCursor = RELOAD_START_NODE;
        this.lastKnownPath = [RELOAD_START_NODE];
        // Live 与 Rehearsal 均将重复起点 0 视作清回 [0] 且不重计 4 秒倒计时
        if (activePath.length > 1) {
            this.submitIntent(ctx.p, { kind: "reloadTapNode", node: RELOAD_START_NODE });
        }
        if (flashError) {
            this.nodePulseSeq += 1;
            ctx.audio.playOnce(
                "fe02:reload_invalid:r" + ctx.events.roomSessionId + ":e" + this.nodePulseSeq,
                "sfx",
                "assets/audio/combat/reload_invalid.wav",
                0.72,
                "reload:invalid",
                ctx.p.ticks,
            );
        }
    }

    private hitTestNode(uiX: number, uiY: number, hitR: number = this.hitRadius): number {
        const r2 = hitR * hitR;
        let i = 0;
        for (i = 0; i < RELOAD_GRID.length; i++) {
            const pos = this.getNodeUiPos(i);
            const dx = uiX - pos.x;
            const dy = uiY - pos.y;
            if (dx * dx + dy * dy <= r2) {
                return i;
            }
        }
        return -1;
    }

    private ingestAppliedEffects(ctx: FePluginContext): void {
        const p = ctx.p;
        let triggered = false;
        let i = 0;
        for (i = 0; i < ctx.events.rawEvents.length; i++) {
            const e = ctx.events.rawEvents[i];
            if ((e.name as string) === "reloadApplied") {
                const rawEff = e.data["effect"];
                const eff: ReloadEffectKind = rawEff === "echo"
                    ? "echo"
                    : (rawEff === "light" ? "light" : "knockback");
                const ex = typeof e.data["enemyX"] === "number" ? (e.data["enemyX"] as number) : (p.player.x + p.player.facing * 200);
                this.spawnAppliedVfx(eff, p, ex);
                triggered = true;
            }
        }
        // 排演态或未派发 reloadApplied 时，监测到有效开火且之前持有特殊效果则同步渲染视觉反馈
        if (!triggered && ctx.events.shotFired && this.lastKnownNextEffect !== "normal" && ctx.view.reloadSession.nextEffect === "normal") {
            const tx = ctx.events.shotTrace !== undefined ? ctx.events.shotTrace.x1 : (p.player.x + p.player.facing * 220);
            this.spawnAppliedVfx(this.lastKnownNextEffect, p, tx);
        }
    }

    private spawnAppliedVfx(effect: ReloadEffectKind, p: Play, targetX: number): void {
        const originX = p.player.x + p.player.facing * 18;
        const originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62;
        const targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46;
        const maxLife = effect === "light" ? 0.42 : (effect === "echo" ? 0.56 : 0.34);
        this.appliedVfx.push({
            effect,
            originX,
            originY,
            targetX,
            targetY,
            facing: p.player.facing >= 0 ? 1 : -1,
            life: maxLife,
            maxLife,
        });
    }

    private updateAppliedVfx(wdt: number): void {
        if (wdt <= 0 || this.appliedVfx.length === 0) {
            return;
        }
        let w = 0;
        let i = 0;
        for (i = 0; i < this.appliedVfx.length; i++) {
            const fx = this.appliedVfx[i];
            fx.life -= wdt;
            if (fx.life > 0) {
                this.appliedVfx[w] = fx;
                w += 1;
            }
        }
        this.appliedVfx.length = w;
    }

    /** 在世界空间补充三种换弹效果的明朝水墨与像素火药战斗反馈 */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (this.appliedVfx.length === 0) {
            return;
        }
        const cam = ctx.cam;
        let i = 0;
        for (i = 0; i < this.appliedVfx.length; i++) {
            const fx = this.appliedVfx[i];
            const k = Math.max(0, Math.min(1, fx.life / fx.maxLife));
            const prog = 1 - k;
            const ox = cam.sx(fx.originX);
            const oy = cam.sy(fx.originY);
            const tx = cam.sx(fx.targetX);
            const ty = cam.sy(fx.targetY);

            if (fx.effect === "knockback") {
                // 推退气浪弧 + 像素火药退步尘烟
                const r = cam.len(12 + prog * 34);
                const startA = fx.facing >= 0 ? -48 : 132;
                const endA = fx.facing >= 0 ? 48 : 228;
                fgGlow.drawArc(Vec2(tx, ty), r, startA, endA, 2.4 * k, toColor(PALETTE.moonPale, 210 * k));
                fgDraw.drawArc(Vec2(tx - fx.facing * cam.len(6), ty), r * 0.72, startA, endA, 1.5 * k, toColor(PALETTE.silkLine, 165 * k));
                const smokeSz = cam.len(22 + prog * 18);
                worldArt.tryPlace("fe_vfx_smoke", "rw_kb_smoke_" + i, tx - fx.facing * cam.len(4 + prog * 10), ty, smokeSz, smokeSz, {
                    frame: Math.min(3, Math.floor(prog * 4)),
                    opacity: 0.78 * k,
                    layer: 8,
                });
            } else if (fx.effect === "echo") {
                // 回声铜铃枯笔水墨圆环
                const r1 = cam.len(10 + prog * 64);
                const r2 = cam.len(6 + prog * 40);
                if (!worldArt.tryPlace("ink_enso_fine", "rw_echo_ring_" + i, tx, ty, r1 * 2.2, r1 * 2.2, {
                    color: toColor(PALETTE.amber),
                    opacity: 0.85 * k,
                    angle: prog * 28,
                    layer: 8,
                })) {
                    fgGlow.drawRing(Vec2(tx, ty), Math.max(1, r1 - 1.6), r1, Color(0, 0, 0, 0), 1.3, toColor(PALETTE.amber, 210 * k));
                }
                fgGlow.drawRing(Vec2(tx, ty), Math.max(1, r2 - 1.2), r2, Color(0, 0, 0, 0), 1.0, toColor(PALETTE.amberCore, 175 * k));
            } else if (fx.effect === "light") {
                // 照明破障暖白微光束 + 枪口像素暖焰
                fgGlow.drawSegment(Vec2(ox, oy), Vec2(tx, ty), 5.0 * k, toColor(PALETTE.amber, 68 * k));
                fgGlow.drawSegment(Vec2(ox, oy), Vec2(tx, ty), 1.8 * k, toColor(PALETTE.amberCore, 185 * k));
                const flashSz = cam.len(26 + prog * 10);
                worldArt.tryPlace("fe_vfx_muzzle", "rw_light_flare_" + i, ox, oy, flashSz, flashSz * 0.75, {
                    frame: Math.min(2, Math.floor(prog * 3)),
                    facing: fx.facing,
                    opacity: 0.90 * k,
                    layer: 9,
                });
                fillRadialGlow(fgGlow, tx, ty, cam.len(42 * (0.6 + prog * 0.4)), cam.len(34), toColor(PALETTE.amberCore, 118 * k), Color(244, 234, 214, 0), 16);
            }
        }
    }

    /** 全速绘制 3×3 宣纸墨线盘（返回 true 同帧隐藏常规战斗准星） */
    drawFullSpeedUi(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const rs = ctx.view.reloadSession;
        const active = rs.active;
        const retracting = !active && this.retractAnimT > 0.01;
        if (!active && !retracting) {
            // 常规战斗态若已备好下次射击效果，在左下轻点一枚克制微章（静音/灰度可辨，零教程）
            if (rs.nextEffect !== "normal" && !ctx.view.craftBench.active) {
                this.drawArmedEffectBadge(uiDraw, uiInkDraw, uiArt, ctx, rs.nextEffect);
            }
            return false;
        }

        const cx = this.panelCx;
        const cy = this.panelCy;
        const pw = this.panelW;
        const ph = this.panelH;
        const x0 = cx - pw * 0.5;
        const y0 = cy - ph * 0.5;

        const appear = active
            ? Math.min(1, this.openAnimT)
            : Math.max(0, this.retractAnimT / Math.max(0.01, this.retractDuration));
        const shakeX = this.localInvalidFlash > 0
            ? Math.sin(this.animTime * 62) * 5.5 * (this.localInvalidFlash / 0.36)
            : 0;
        const px = cx + shakeX;

        // 1. 轻压边微晕（极克制，保留左侧/远处敌人清晰视野）
        if (active) {
            uiDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(10, 13, 20, Math.round(54 * appear)));
        }

        // 2. 宣纸墨线盘底（复用宋明冷素宣纸 + 海棠折角，彻底告别科幻 HUD）
        drawSilkVeil(uiDraw, uiArt, "rw_outer_veil", px, cy, pw + 34, ph + 28, PALETTE.inkWash, 0.72 * appear, -2);
        if (!uiArt.tryPlace("ink_song_paper", "rw_paper", px, cy, pw, ph, { opacity: 0.94 * appear, layer: 1 })) {
            uiDraw.drawRoundedRect(
                Rect(x0 + shakeX, y0, pw, ph),
                6,
                toColor(PALETTE.xuanPaper, 240 * appear),
                1.2,
                toColor(PALETTE.xuanInkSub, 180 * appear),
            );
        }
        const frameCol = this.localInvalidFlash > 0.05 ? PALETTE.rouge : PALETTE.xuanInkSub;
        drawFiligreeCorners(uiInkDraw, uiArt, "rw_frame", x0 + shakeX + 8, y0 + 8, pw - 16, ph - 16, frameCol, 0.72 * appear, 22, true, 2);

        // 3. 顶栏：实时效果几何纹样预览（静音/灰度可辨）
        const activePath = active
            ? (rs.path.length > 0 ? rs.path : [RELOAD_START_NODE])
            : this.settledPath;
        const previewEffect = active
            ? (rs.path.length >= 2 ? deriveEffectFromGrid(activePath) : rs.previewEffect)
            : this.settledEffect;
        const effAccent = this.effectInkColor(previewEffect);

        const headY = y0 + ph - 32;
        drawReloadPatternGlyph(uiInkDraw, px - 52, headY, 11, previewEffect, effAccent, appear);
        const titleText = active
            ? reloadEffectShortLabel(previewEffect)
            : (this.settledTimedOut ? "普通装填" : reloadEffectShortLabel(this.settledEffect));
        ctx.texts.put(
            "sm",
            titleText,
            px - 32,
            headY,
            toColor(this.localInvalidFlash > 0.05 ? PALETTE.rouge : PALETTE.xuanInk),
            0,
            0.5,
            TextAlign.Left,
            1.6,
            0.96 * appear,
            0,
        );
        if (active && (ctx.input.isTouchMode() || activePath.length > 1)) {
            const canReset = activePath.length > 1;
            const rb = Rect(this.resetBox.x + shakeX, this.resetBox.y, this.resetBox.width, this.resetBox.height);
            uiInkDraw.drawRect(
                rb,
                Color(32, 30, 32, Math.round((canReset ? 32 : 12) * appear)),
                0.85,
                toColor(canReset ? PALETTE.rouge : PALETTE.xuanInkSub, (canReset ? 185 : 95) * appear),
            );
            ctx.texts.put(
                "xs",
                "重画",
                rb.x + rb.width * 0.5,
                rb.y + rb.height * 0.5,
                toColor(canReset ? PALETTE.rouge : PALETTE.xuanInkSub),
                0.5,
                0.5,
                TextAlign.Center,
                1.0,
                (canReset ? 0.94 : 0.52) * appear,
                0,
            );
        }
        drawHairline(uiInkDraw, uiArt, "rw_head_line", px, headY - 18, pw - 42, PALETTE.xuanInkSub, 0.45 * appear, false, 2);

        // 4. 3×3 九宫格淡墨经纬底线
        let idx = 0;
        for (idx = 0; idx < 3; idx++) {
            const hA = this.getNodeUiPos(idx * 3);
            const hB = this.getNodeUiPos(idx * 3 + 2);
            uiInkDraw.drawSegment(Vec2(hA.x + shakeX, hA.y), Vec2(hB.x + shakeX, hB.y), 0.75, toColor(PALETTE.xuanInkSub, 78 * appear));
            const vA = this.getNodeUiPos(idx);
            const vB = this.getNodeUiPos(6 + idx);
            uiInkDraw.drawSegment(Vec2(vA.x + shakeX, vA.y), Vec2(vB.x + shakeX, vB.y), 0.75, toColor(PALETTE.xuanInkSub, 78 * appear));
        }

        // 5. 已连路径墨笔轨迹（按不同效果采用不同线型，灰度同样可辨）
        if (activePath.length >= 2) {
            this.drawPathStrokes(uiInkDraw, uiGlow, activePath, previewEffect, effAccent, shakeX, appear);
        }

        // 鼠标 / 触屏拖线动态墨丝（从末点拉向当前全速光标）
        if (active && this.dragging && activePath.length >= 1) {
            const tail = this.getNodeUiPos(activePath[activePath.length - 1]);
            const mx = ctx.input.uiHeld ? (ctx.input.uiX / ctx.uiScale) : this.lastUiPtrX;
            const my = ctx.input.uiHeld ? (ctx.input.uiY / ctx.uiScale) : this.lastUiPtrY;
            uiInkDraw.drawSegment(Vec2(tail.x + shakeX, tail.y), Vec2(mx, my), 1.4, toColor(effAccent, 150 * appear));
            uiInkDraw.drawDot(Vec2(mx, my), 3.0, toColor(effAccent, 210 * appear));
        }

        // 6. 绘制 9 颗节点（仅在已连入时亮起，铃纹 4 / 灯纹 2 / 终点 8 各自独立像素纹章轮廓）
        const lastNode = activePath.length > 0 ? activePath[activePath.length - 1] : RELOAD_START_NODE;
        for (idx = 0; idx < RELOAD_GRID.length; idx++) {
            const spec = RELOAD_GRID[idx];
            const pos = this.getNodeUiPos(idx);
            const nx = pos.x + shakeX;
            const ny = pos.y;
            const inPath = activePath.indexOf(idx) >= 0;
            const isValidNext = active && !inPath && isAdjacentNode(lastNode, idx);
            const isKbFocus = active && !this.pointerActive && this.kbCursor === idx;
            this.drawGridNode(uiInkDraw, uiArt, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear);
        }

        // 7. 小满手指落位 / 走线 / 沿已选纹样收回表现（像素手势精灵，零文字教程）
        this.drawChildFinger(uiInkDraw, uiArt, uiGlow, active, activePath, shakeX, appear);

        // 8. 底缘 4 秒全速作答进度条（世界 60 拍 = 作答 240 拍）
        const barW = pw - 52;
        const barX = px - barW * 0.5;
        const barY = y0 + 28;
        const remainFrac = active
            ? Math.max(0, Math.min(1, 1 - rs.elapsed / Math.max(0.01, rs.duration)))
            : (this.settledTimedOut ? 0 : 1);
        const urgent = active && remainFrac < 0.25;
        const barCol = urgent ? PALETTE.rouge : PALETTE.xuanInk;
        uiInkDraw.drawSegment(Vec2(barX, barY), Vec2(barX + barW, barY), 1.4, toColor(PALETTE.xuanInkSub, 85 * appear));
        if (remainFrac > 0.005) {
            uiInkDraw.drawSegment(Vec2(barX, barY), Vec2(barX + barW * remainFrac, barY), 3.0, toColor(barCol, 225 * appear));
        }
        // 四等分刻度（对应 4 秒 / 每秒 60 作答拍 = 15 世界拍）
        let tTick = 1;
        for (tTick = 1; tTick <= 3; tTick++) {
            const tx = barX + barW * (tTick / 4);
            uiInkDraw.drawSegment(Vec2(tx, barY - 3.5), Vec2(tx, barY + 3.5), 0.9, toColor(PALETTE.xuanInkSub, 125 * appear));
        }

        // 默认低引导不显示按键教学；仅玩家主动打开「按键辅助」时在盘底给一行极淡说明
        if (active && ctx.view.assistHintsEnabled) {
            const mode = ctx.input.inputMode;
            const hint = mode === "gamepad"
                ? ("左摇杆八向直连至右上 · " + getActiveTarget().keyTagFor("back", "gamepad", ctx.input.gamepadLayout) + " 重画")
                : (mode === "touch"
                    ? "单指一笔滑连至右上 · 点重画清空"
                    : "拖线或方向+回车连至右上");
            ctx.texts.put(
                "xs",
                hint,
                px,
                y0 + 13,
                toColor(PALETTE.xuanInkSub),
                0.5,
                0.5,
                TextAlign.Center,
                0.6,
                0.82 * appear,
                0,
            );
        }

        return active;
    }

    private effectInkColor(effect: ReloadEffectKind): RGBA {
        if (effect === "echo") {
            return PALETTE.rouge;
        }
        if (effect === "light") {
            return PALETTE.amberDim;
        }
        if (effect === "knockback") {
            return PALETTE.xuanInk;
        }
        return PALETTE.xuanInkSub;
    }

    private drawPathStrokes(
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        path: readonly number[],
        effect: ReloadEffectKind,
        col: RGBA,
        shakeX: number,
        appear: number,
    ): void {
        let i = 0;
        for (i = 0; i < path.length - 1; i++) {
            const p0 = this.getNodeUiPos(path[i]);
            const p1 = this.getNodeUiPos(path[i + 1]);
            const ax = p0.x + shakeX;
            const ay = p0.y;
            const bx = p1.x + shakeX;
            const by = p1.y;

            if (effect === "echo") {
                // 回声双平行韵线
                const dx = bx - ax;
                const dy = by - ay;
                const len = Math.max(1, Math.sqrt(dx * dx + dy * dy));
                const nx = -dy / len * 2.2;
                const ny = dx / len * 2.2;
                uiInkDraw.drawSegment(Vec2(ax + nx, ay + ny), Vec2(bx + nx, by + ny), 1.35, toColor(col, 220 * appear));
                uiInkDraw.drawSegment(Vec2(ax - nx, ay - ny), Vec2(bx - nx, by - ny), 1.35, toColor(col, 220 * appear));
            } else if (effect === "light") {
                // 照明：深墨边 + 暖金灯芯
                uiInkDraw.drawSegment(Vec2(ax, ay), Vec2(bx, by), 3.1, toColor(PALETTE.xuanInk, 195 * appear));
                uiInkDraw.drawSegment(Vec2(ax, ay), Vec2(bx, by), 1.3, toColor(PALETTE.amberCore, 235 * appear));
                uiGlow.drawSegment(Vec2(ax, ay), Vec2(bx, by), 3.2, toColor(PALETTE.amber, 55 * appear));
            } else {
                // 推退：沉实浓墨毛笔单锋
                uiInkDraw.drawSegment(Vec2(ax, ay), Vec2(bx, by), 2.8, toColor(col, 230 * appear));
            }
        }
    }

    private drawGridNode(
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        spec: ReloadNodeSpec,
        nx: number,
        ny: number,
        inPath: boolean,
        isValidNext: boolean,
        isKbFocus: boolean,
        effAccent: RGBA,
        appear: number,
    ): void {
        const baseR = spec.kind === "plain" ? 11 : 15;
        const strokeCol = inPath ? effAccent : (isValidNext ? PALETTE.xuanInk : PALETTE.xuanInkSub);
        const strokeAlpha = inPath ? 245 : (isValidNext ? 185 : 115);

        // 键盘焦点外虚框（仅键盘操作时显示，鼠标静止不抢焦）
        if (isKbFocus) {
            const focusCol = isValidNext || inPath ? PALETTE.rouge : PALETTE.xuanInkSub;
            uiInkDraw.drawRing(Vec2(nx, ny), baseR + 4.5, baseR + 6.2, Color(0, 0, 0, 0), 1.1, toColor(focusCol, 215 * appear));
        }

        if (spec.kind === "bell") {
            // 中心 4：铃纹节点
            if (inPath) {
                uiInkDraw.drawCircle(Vec2(nx, ny), baseR + 1, toColor(PALETTE.rouge, 36 * appear));
                uiGlow.drawRing(Vec2(nx, ny), baseR + 2, baseR + 5, Color(0, 0, 0, 0), 1.2, toColor(PALETTE.rouge, 110 * appear));
            }
            uiInkDraw.drawRing(Vec2(nx, ny), baseR - 1.2, baseR, Color(0, 0, 0, 0), 1.1, toColor(strokeCol, strokeAlpha * appear));
            drawReloadPatternGlyph(uiInkDraw, nx, ny, 9.5, "echo", inPath ? PALETTE.rouge : strokeCol, appear, uiArt, "rw_glyph_bell", 4);
            return;
        }

        if (spec.kind === "lamp") {
            // 右下 2：灯纹节点
            if (inPath) {
                uiInkDraw.drawCircle(Vec2(nx, ny), baseR + 1, toColor(PALETTE.amber, 56 * appear));
                fillRadialGlow(uiGlow, nx, ny, 22, 22, toColor(PALETTE.amberCore, 72 * appear), Color(244, 234, 214, 0), 12);
            }
            uiInkDraw.drawRing(Vec2(nx, ny), baseR - 1.2, baseR, Color(0, 0, 0, 0), 1.1, toColor(strokeCol, strokeAlpha * appear));
            drawReloadPatternGlyph(uiInkDraw, nx, ny, 9.5, "light", inPath ? PALETTE.xuanInk : strokeCol, appear, uiArt, "rw_glyph_lamp", 4);
            return;
        }

        if (spec.kind === "target") {
            // 右上 8：枪机复位终点（双层玄铁菱框，常亮可辨）
            drawDiamond(
                uiInkDraw,
                nx,
                ny,
                baseR,
                baseR,
                inPath ? toColor(PALETTE.xuanInk, 220 * appear) : Color(0, 0, 0, 0),
                1.4,
                toColor(inPath ? PALETTE.rouge : PALETTE.xuanInk, 230 * appear),
            );
            drawDiamond(
                uiInkDraw,
                nx,
                ny,
                baseR * 0.56,
                baseR * 0.56,
                toColor(inPath ? PALETTE.amberCore : PALETTE.xuanInk, 210 * appear),
            );
            return;
        }

        if (spec.kind === "start") {
            // 左下 0：起笔墨环
            uiInkDraw.drawRing(Vec2(nx, ny), baseR - 2.2, baseR, Color(0, 0, 0, 0), 1.2, toColor(PALETTE.rouge, 220 * appear));
            uiInkDraw.drawCircle(Vec2(nx, ny), 4.8, toColor(PALETTE.xuanInk, 235 * appear));
            return;
        }

        // 普通点：未连入为空心素圈，连入后填实墨点
        if (inPath) {
            uiInkDraw.drawCircle(Vec2(nx, ny), 6.2, toColor(effAccent, 235 * appear));
            uiInkDraw.drawRing(Vec2(nx, ny), 9.5, 10.8, Color(0, 0, 0, 0), 1.0, toColor(effAccent, 165 * appear));
        } else {
            uiInkDraw.drawRing(Vec2(nx, ny), 5.6, 7.0, Color(0, 0, 0, 0), 1.0, toColor(strokeCol, strokeAlpha * appear));
        }
    }

    /** 小满像素手指落位提示（起点 0 微叩指引；拖线中随笔尖；结算后沿已选纹样收回） */
    private drawChildFinger(
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        active: boolean,
        path: readonly number[],
        shakeX: number,
        appear: number,
    ): void {
        let fx = 0;
        let fy = 0;

        if (active) {
            const tipNode = path.length > 0 ? path[path.length - 1] : RELOAD_START_NODE;
            const pos = this.getNodeUiPos(tipNode);
            const tapPulse = path.length <= 1 ? Math.sin(this.animTime * 4.8) * 3.5 : 0;
            fx = pos.x + shakeX + 4 + tapPulse * 0.35;
            fy = pos.y - 4 - tapPulse;
            if (path.length <= 1) {
                // 仅起点处加一圈极淡呼吸墨环表示“可从此落笔”，完全不用文字
                const ringR = 17 + Math.sin(this.animTime * 4.2) * 2.5;
                uiInkDraw.drawRing(Vec2(pos.x + shakeX, pos.y), ringR - 1, ringR, Color(0, 0, 0, 0), 1.0, toColor(PALETTE.rouge, 130 * appear));
            }
        } else if (this.retractAnimT > 0 && path.length > 0) {
            // 结算后沿已选纹样逆向收回至起点之外
            const prog = Math.max(0, Math.min(1, 1 - this.retractAnimT / Math.max(0.01, this.retractDuration)));
            const revFloat = (1 - prog) * (path.length - 1);
            const idxA = Math.max(0, Math.min(path.length - 1, Math.floor(revFloat)));
            const idxB = Math.max(0, Math.min(path.length - 1, idxA + 1));
            const frac = revFloat - idxA;
            const pA = this.getNodeUiPos(path[idxA]);
            const pB = this.getNodeUiPos(path[idxB]);
            fx = pA.x + (pB.x - pA.x) * frac + shakeX + prog * 28;
            fy = pA.y + (pB.y - pA.y) * frac - prog * 22;
        } else {
            return;
        }

        uiGlow.drawDot(Vec2(fx, fy), 3.6, toColor(PALETTE.amberCore, 88 * appear));
        if (uiArt.tryPlacePath("assets/art/vfx_craft_art.clip|reload_child_finger", "rw_child_finger", fx, fy, 64, 56, {
            anchorX: 0.04,
            anchorY: 0.96,
            preserveAspect: true,
            smooth: true,
            opacity: 0.96 * appear,
            layer: 6,
        })) {
            return;
        }

        // 无图集时的极简兜底
        const a255 = Math.round(240 * appear);
        const inkCol = toColor(PALETTE.xuanInk, 180 * appear);
        uiInkDraw.drawPolygon([
            Vec2(fx - 30, fy - 20),
            Vec2(fx - 22, fy - 28),
            Vec2(fx - 11, fy - 14),
            Vec2(fx - 17, fy - 9),
        ], Color(164, 78, 54, a255), 1.0, inkCol);
        uiInkDraw.drawSegment(Vec2(fx - 16, fy - 10), Vec2(fx - 11, fy - 15), 2.0, Color(204, 174, 122, a255));
        uiInkDraw.drawCircle(Vec2(fx - 9, fy - 8), 4.8, Color(238, 212, 182, a255));
        uiInkDraw.drawSegment(Vec2(fx - 7, fy - 6), Vec2(fx, fy), 2.5, Color(244, 222, 196, a255));
        uiInkDraw.drawRing(Vec2(fx, fy), 2.0, 3.0, Color(0, 0, 0, 0), 0.9, inkCol);
    }

    /** 下次射击已上势时的极简左下角纹样微章（不占视野、灰度可辨） */
    private drawArmedEffectBadge(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        ctx: FePluginContext,
        effect: ReloadEffectKind,
    ): void {
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const bx = 46 + safe.left;
        const by = ctx.uiH - 134 - safe.top;
        const col = effect === "echo" ? PALETTE.rouge : (effect === "light" ? PALETTE.amberCore : PALETTE.cyanCore);
        drawSilkVeil(uiDraw, uiArt, "rw_armed_veil", bx + 54, by, 142, 30, PALETTE.inkWash, 0.72, -1);
        drawReloadPatternGlyph(uiInkDraw, bx + 12, by, 9, effect, col, 0.96, uiArt, "rw_armed_glyph", 4);
        drawBlossomDot(uiInkDraw, uiArt, "rw_armed_dot", bx + 28, by, 6, col, 0.85, 3);
        ctx.texts.put("xs", reloadEffectShortLabel(effect), bx + 38, by, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 1.0, 0.94, 0.08);
    }
}

export function createReloadWheelPlugin(contract?: DualRouteContract): ReloadWheelPlugin {
    return new ReloadWheelPlugin(contract);
}
