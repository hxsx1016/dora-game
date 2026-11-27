/**
 * 《向西守望》统一宋明水墨触控叠加层与竖屏掌机操控台（纯布局 + 渲染层，零底层 Touch 监听）。
 *
 * 深度解耦职责：
 * - 所有底层手指采集与状态机均在 Script/watch/touch.ts（TouchRouter），本模块仅负责：
 *   1. 根据当前 StageViewport / Play / Screen / RunState 计算按钮与热区，喂给 TouchRouter（布局与命中单一真源）；
 *   2. 在独立 overlayRoot（order = 60，位于前端与试炼层之上）渲染水墨触控控件：
 *      - 横屏模式：宋明水墨动态浮动左摇杆（2.5D 四向刻度 + 小满内圈轻步环）+ 右侧扇形动作圆钮
 *        （周戍双模开火/拖瞄摇杆、动态「翻越/翻滚」、掩体开关、情境交互带长按环、神器穿梭钮；
 *          小满跳跃、蹲伏/轻步开关、情境交互、空村投瓶拖瞄与取消圈）+ 顶栏快捷章；
 *      - 竖屏模式：上半屏 16:9 完整无裁切舞台 + 顶部鸦青状态条 + 下半屏宋明水墨掌机操控台
 *        （菜单导航键、局内摇杆与动作键、试炼选卡/结算钮），零手指遮挡画面；
 *      - 护送试炼（mode === 2）完整支持摇杆、战斗钮、天赋三选一与暂停/结算直点。
 */

import { BlendFunc, BlendOp, Color, DrawNode, Node, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { RunState } from "Script/watch/run";
import { collectPlayAimTargets } from "Script/watch/aim_assist";
import { StageViewport, canToggleFullscreen, isWebPlatform } from "Script/watch/platform";
import {
    TouchAccent,
    TouchButtonSpec,
    TouchFrameContext,
    TouchRectZone,
    TouchRouter,
} from "Script/watch/touch";
import { WorldPrompt, deriveWorldPrompt } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { ScreenKind } from "Script/watch/fe/ui/menus";
import {
    deriveInteractActionMeta,
    isCutsceneBlockingPlay,
} from "Script/watch/fe/ui/control_prompts";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawDiamond,
    drawHairline,
    drawSilkVeil,
    fillRadialGlow,
    fillVGradRect,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

const TWO_PI = Math.PI * 2;
const HALF_PI = Math.PI * 0.5;
const STICK_BASE_R_LANDSCAPE = 64;

export interface TouchOverlaySyncParams {
    viewport: StageViewport;
    mode: number;
    screen: ScreenKind;
    play: Play | undefined;
    run: RunState | undefined;
    cam: CameraDirector | undefined;
    input: Input;
    router: TouchRouter;
    assistHintsEnabled: boolean;
    isMuted: boolean;
    isFullscreen: boolean;
    storyTalentBoxes: Rect.Type[];
    escortDeathBoxes?: { retry: Rect.Type; title: Rect.Type };
    dt: number;
}

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

function accentPalette(accent: TouchAccent): RGBA {
    if (accent === "cyan") return PALETTE.cyan;
    if (accent === "amber") return PALETTE.amber;
    if (accent === "rouge") return PALETTE.rouge;
    if (accent === "emerald") return PALETTE.emerald;
    return PALETTE.silkLine;
}

function accentCore(accent: TouchAccent): RGBA {
    if (accent === "cyan") return PALETTE.cyanCore;
    if (accent === "amber") return PALETTE.amberCore;
    if (accent === "rouge") return PALETTE.crimsonCore;
    if (accent === "emerald") return PALETTE.emerald;
    return PALETTE.textBright;
}

function drawRingArc(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    r: number,
    startRad: number,
    sweepRad: number,
    thickness: number,
    color: Color.Type,
    segments: number = 28,
): void {
    if (r <= 1 || Math.abs(sweepRad) <= 0.001) return;
    const n = Math.max(4, Math.ceil(segments * Math.min(1, Math.abs(sweepRad) / TWO_PI)));
    let prevX = cx + Math.cos(startRad) * r;
    let prevY = cy + Math.sin(startRad) * r;
    let i = 1;
    for (i = 1; i <= n; i++) {
        const a = startRad + (sweepRad * i) / n;
        const nx = cx + Math.cos(a) * r;
        const ny = cy + Math.sin(a) * r;
        draw.drawSegment(Vec2(prevX, prevY), Vec2(nx, ny), thickness, color);
        prevX = nx;
        prevY = ny;
    }
}

function fillCirclePoly(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    r: number,
    fill: Color.Type,
    borderWidth: number = 0,
    borderColor?: Color.Type,
    segments: number = 26,
): void {
    const pts: Vec2.Type[] = [];
    let i = 0;
    for (i = 0; i < segments; i++) {
        const a = (TWO_PI * i) / segments;
        pts.push(Vec2(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
    }
    if (borderWidth > 0 && borderColor !== undefined) {
        draw.drawPolygon(pts, fill, borderWidth, borderColor);
    } else {
        draw.drawPolygon(pts, fill);
    }
}

function isNearLowLedgeForButton(p: Play): boolean {
    if (p.childMode) return false;
    const a = p.player;
    const probeX = a.x + a.facing * 26;
    let i = 0;
    for (i = 0; i < p.boxes.length; i++) {
        const b = p.boxes[i];
        if (b.broken === true || b.hidden === true) continue;
        const h = b.y1 - b.y0;
        if (h >= 24 && h <= 62 && probeX >= b.x0 - 16 && probeX <= b.x1 + 16
            && Math.abs(a.y - b.y0) <= 14) {
            return true;
        }
    }
    return false;
}

function isInLowArch(p: Play): boolean {
    const arch = p.room.arch;
    if (arch.h <= 0) return false;
    return p.player.x >= arch.x0 - 10 && p.player.x <= arch.x1 + 10 && p.player.y <= arch.y + arch.h;
}

export class TouchControls {
    private overlayRoot: Node.Type;
    private deckDraw: DrawNode.Type;
    private padDraw: DrawNode.Type;
    private padArt: AssetSlotHost;
    private padInkDraw: DrawNode.Type;
    private padGlow: DrawNode.Type;
    private texts: TextPool;

    private lastContext: TouchFrameContext | undefined;
    private lastMode = 1;
    private lastScreen: ScreenKind = "title";
    private lastPlay: Play | undefined;
    private lastRun: RunState | undefined;
    private time = 0;

    constructor(parent: Node.Type) {
        this.overlayRoot = Node();
        this.overlayRoot.order = 60;
        this.overlayRoot.addTo(parent);

        this.deckDraw = DrawNode();
        this.deckDraw.order = 0;
        this.deckDraw.addTo(this.overlayRoot);

        this.padDraw = DrawNode();
        this.padDraw.order = 2;
        this.padDraw.addTo(this.overlayRoot);

        this.padArt = new AssetSlotHost(this.overlayRoot, 3);

        this.padInkDraw = DrawNode();
        this.padInkDraw.order = 5;
        this.padInkDraw.addTo(this.overlayRoot);

        const additive = BlendFunc(BlendOp.SrcAlpha, BlendOp.One);
        this.padGlow = DrawNode();
        this.padGlow.order = 7;
        this.padGlow.blendFunc = additive;
        this.padGlow.addTo(this.overlayRoot);

        this.texts = new TextPool(this.overlayRoot, 10);
    }

    /** 供自动化验证脚本查询当前布局按钮表与状态。 */
    getLayoutSummary(router?: TouchRouter): {
        buttonIds: string[];
        zoneIds: string[];
        isPortrait: boolean;
        overlayActive: boolean;
        crouchToggled: boolean;
        slowToggled: boolean;
        coverToggled: boolean;
        cartGripLatch: boolean;
    } {
        const buttonIds: string[] = [];
        const zoneIds: string[] = [];
        if (this.lastContext !== undefined) {
            let i = 0;
            for (i = 0; i < this.lastContext.buttons.length; i++) {
                buttonIds.push(this.lastContext.buttons[i].id);
            }
            for (i = 0; i < this.lastContext.rectZones.length; i++) {
                zoneIds.push(this.lastContext.rectZones[i].id);
            }
        }
        return {
            buttonIds,
            zoneIds,
            isPortrait: this.lastContext !== undefined ? this.lastContext.viewport.isPortrait : false,
            overlayActive: this.lastContext !== undefined ? this.lastContext.overlayActive : false,
            crouchToggled: router !== undefined ? router.crouchToggled : false,
            slowToggled: router !== undefined ? router.slowToggled : false,
            coverToggled: router !== undefined ? router.coverToggled : false,
            cartGripLatch: router !== undefined ? router.cartGripLatched : false,
        };
    }

    /** 每帧在 Input.update() 之前计算全屏/竖屏触控热区并喂给 TouchRouter。 */
    syncContext(params: TouchOverlaySyncParams): TouchFrameContext {
        this.time += Math.min(0.05, Math.max(0, params.dt));
        this.lastMode = params.mode;
        this.lastScreen = params.screen;
        this.lastPlay = params.play;
        this.lastRun = params.run;

        const vp = params.viewport;
        const p = params.play;
        const router = params.router;
        const input = params.input;
        const isPortrait = vp.isPortrait;
        const overlayScale = isPortrait ? 1 : vp.uiScale;
        const ovW = vp.fullW / Math.max(0.25, overlayScale);
        const ovH = vp.fullH / Math.max(0.25, overlayScale);
        const safeL = vp.safe.left / Math.max(0.25, overlayScale);
        const safeR = vp.safe.right / Math.max(0.25, overlayScale);
        const safeT = vp.safe.top / Math.max(0.25, overlayScale);
        const safeB = vp.safe.bottom / Math.max(0.25, overlayScale);

        const overlayActive = input.shouldShowTouchControls();
        const allowMouseOnOverlay = isPortrait || input.settings.modePref === "touch";
        const allowAutoGameplayTouch = input.settings.modePref === "auto" || input.settings.modePref === "touch";
        const sc = router.settings.touchScale;

        const isPlayMode = params.mode === 1 && params.screen === "play" && p !== undefined;
        const gameplayActive = isPlayMode;
        const talentModalOpen = isPlayMode && p !== undefined && !p.paused && !p.craftBench.active
            && !p.reloadOpen && !p.escortFailed && p.talentModalActive && p.getStoryTalentOffers().length > 0;
        const escortSummaryOpen = isPlayMode && p !== undefined && !p.paused && p.escortFailed;

        const modal = !gameplayActive
            || (isPlayMode && p !== undefined && (p.paused || p.reloadOpen || p.craftBench.active || talentModalOpen || escortSummaryOpen));
        const cutsceneBlocking = isPlayMode && p !== undefined
            ? isCutsceneBlockingPlay(p)
            : false;

        const allowDepth = p !== undefined && p.room.depth !== undefined
            && (!p.childMode || p.phase === "prologue-escape");
        const cart = p !== undefined ? p.room.cart : undefined;
        const cartNearby = p !== undefined && cart !== undefined && !p.cartDocked && cart.bodyW > 0
            && (p.gripping || p.cartHandleInReach());
        const canBottleAim = isPlayMode && p !== undefined && p.childMode && p.room.key === "village" && p.hasBottle && !p.passed;
        const peacefulRoom = p !== undefined && (p.room.key === "museum" || p.room.key === "tower");
        const canShoot = gameplayActive && p !== undefined && !p.childMode && !peacefulRoom && !p.gripping
            && !cutsceneBlocking && !modal && p.escort.state !== "calming";

        const buttons: TouchButtonSpec[] = [];
        const rectZones: TouchRectZone[] = [];

        // 默认摇杆几何（竖屏下掌机左半区固定底座；横屏左半屏动态浮现）
        const unitPortrait = clamp(Math.min(vp.fullW / 420, Math.max(180, vp.deckH) / 340), 0.72, 1.15);
        const stickMaxR = isPortrait
            ? Math.round(52 * unitPortrait * sc)
            : STICK_BASE_R_LANDSCAPE * sc;
        const stickDefaultX = isPortrait
            ? safeL + Math.max(stickMaxR + 26, Math.round(ovW * 0.24))
            : safeL + 126 * sc;
        const stickDefaultY = isPortrait
            ? Math.max(safeB + stickMaxR + 24, vp.deckH * 0.44)
            : safeB + 126 * sc;
        const stickZoneMaxX = isPortrait ? ovW * 0.50 : ovW * 0.46;
        const stickZoneMaxY = isPortrait ? Math.max(40, vp.deckH - 8) : ovH - 110;

        let bottleCancelCenter = { x: ovW - safeR - 106 * sc, y: safeB + 124 * sc, r: 44 * sc };

        // -------- A. 顶部快捷条（暂歇 / 重试 / 静音 / 全屏）--------
        if (overlayActive) {
            if (isPortrait) {
                // 竖屏顶部状态带快捷胶囊钮
                const topY = ovH - vp.topBarH * 0.5;
                const pillH = 26;
                let rx = ovW - safeR - 10;

                if (gameplayActive && p !== undefined && !p.paused) {
                    const pw = 58;
                    rx -= pw;
                    buttons.push({
                        id: "pause",
                        x: rx + pw * 0.5,
                        y: topY,
                        r: 22,
                        shape: "pill",
                        rect: Rect(rx, topY - pillH * 0.5, pw, pillH),
                        label: "暂歇",
                        accent: "silk",
                        active: false,
                        highlighted: false,
                        progress: 0,
                        dimmed: false,
                    });
                    rx -= 8;

                    const inTowerEnd = p.room.key === "tower" && p.phase !== "tower-wait";
                    if (!inTowerEnd) {
                        const rw = 58;
                        rx -= rw;
                        buttons.push({
                            id: "retry",
                            x: rx + rw * 0.5,
                            y: topY,
                            r: 22,
                            shape: "pill",
                            rect: Rect(rx, topY - pillH * 0.5, rw, pillH),
                            label: "重试",
                            accent: "amber",
                            active: false,
                            highlighted: false,
                            progress: 0,
                            dimmed: false,
                        });
                        rx -= 8;
                    }
                }

                const mw = 54;
                rx -= mw;
                buttons.push({
                    id: "mute",
                    x: rx + mw * 0.5,
                    y: topY,
                    r: 20,
                    shape: "pill",
                    rect: Rect(rx, topY - pillH * 0.5, mw, pillH),
                    label: params.isMuted ? "静音" : "有声",
                    accent: params.isMuted ? "rouge" : "cyan",
                    active: params.isMuted,
                    highlighted: false,
                    progress: 0,
                    dimmed: false,
                });
                rx -= 8;

                if (canToggleFullscreen()) {
                    const fw = 54;
                    rx -= fw;
                    buttons.push({
                        id: "fullscreen",
                        x: rx + fw * 0.5,
                        y: topY,
                        r: 20,
                        shape: "pill",
                        rect: Rect(rx, topY - pillH * 0.5, fw, pillH),
                        label: params.isFullscreen ? "窗口" : "全屏",
                        accent: "silk",
                        active: params.isFullscreen,
                        highlighted: false,
                        progress: 0,
                        dimmed: false,
                    });
                }
            } else {
                // 横屏右上角「暂歇」章（非模态局内常驻，过场也可点按暂停）
                if (isPlayMode && !modal) {
                    const px = ovW - safeR - 112;
                    const py = ovH - safeT - 66;
                    buttons.push({
                        id: "pause",
                        x: px + 46,
                        y: py + 21,
                        r: 28,
                        shape: "pill",
                        rect: Rect(px, py, 94, 42),
                        label: "暂歇",
                        accent: "silk",
                        active: false,
                        highlighted: false,
                        progress: 0,
                        dimmed: false,
                    });
                    // Web 端触控模式补充小巧「静音 / 全屏」胶囊于暂歇左侧
                    if (isWebPlatform()) {
                        const mw = 58;
                        const mx = px - mw - 10;
                        buttons.push({
                            id: "mute",
                            x: mx + mw * 0.5,
                            y: py + 21,
                            r: 22,
                            shape: "pill",
                            rect: Rect(mx, py + 4, mw, 34),
                            label: params.isMuted ? "静音" : "有声",
                            accent: params.isMuted ? "rouge" : "cyan",
                            active: params.isMuted,
                            highlighted: false,
                            progress: 0,
                            dimmed: false,
                        });
                        if (canToggleFullscreen()) {
                            const fw = 58;
                            const fx = mx - fw - 8;
                            buttons.push({
                                id: "fullscreen",
                                x: fx + fw * 0.5,
                                y: py + 21,
                                r: 22,
                                shape: "pill",
                                rect: Rect(fx, py + 4, fw, 34),
                                label: params.isFullscreen ? "窗口" : "全屏",
                                accent: "silk",
                                active: params.isFullscreen,
                                highlighted: false,
                                progress: 0,
                                dimmed: false,
                            });
                        }
                    }
                }
            }
        }

        // -------- B. 竖屏菜单掌机导航键（开机品牌序幕不展示导航键，菜单、暂停、折笺与折戟小结同时支持直点上方 16:9 画面）--------
        if (isPortrait && overlayActive && params.screen !== "splash"
            && (!gameplayActive || (isPlayMode && p !== undefined && (p.paused || talentModalOpen || escortSummaryOpen)))) {
            const cy = Math.max(safeB + 84, vp.deckH * 0.50);
            const leftX = safeL + Math.max(82, ovW * 0.25);
            const step = Math.min(54, Math.max(42, ovW * 0.12));
            const nr = Math.min(26, Math.max(21, ovW * 0.06));
            buttons.push({ id: "nav_up", x: leftX, y: cy + step, r: nr, label: "上", accent: "silk", active: false, highlighted: false, progress: 0, dimmed: false });
            buttons.push({ id: "nav_down", x: leftX, y: cy - step, r: nr, label: "下", accent: "silk", active: false, highlighted: false, progress: 0, dimmed: false });
            buttons.push({ id: "nav_left", x: leftX - step, y: cy, r: nr, label: "左", accent: "silk", active: false, highlighted: false, progress: 0, dimmed: false });
            buttons.push({ id: "nav_right", x: leftX + step, y: cy, r: nr, label: "右", accent: "silk", active: false, highlighted: false, progress: 0, dimmed: false });

            const rightX = ovW - safeR - Math.max(76, ovW * 0.23);
            buttons.push({
                id: "nav_confirm",
                x: rightX,
                y: cy + 28,
                r: 28,
                shape: "pill",
                rect: Rect(rightX - 48, cy + 6, 96, 44),
                label: "确认",
                accent: "rouge",
                active: false,
                highlighted: true,
                progress: 0,
                dimmed: false,
            });
            buttons.push({
                id: "nav_back",
                x: rightX,
                y: cy - 30,
                r: 26,
                shape: "pill",
                rect: Rect(rightX - 48, cy - 50, 96, 40),
                label: "返回",
                accent: "silk",
                active: false,
                highlighted: false,
                progress: 0,
                dimmed: false,
            });
        }

        // -------- C. 局内直点矩形热区（折笺本领卡、折戟小结按钮、世界交互气泡）--------
        let prompt: WorldPrompt | undefined;
        if (isPlayMode && p !== undefined && !p.paused && !p.craftBench.active && !p.reloadOpen && !cutsceneBlocking) {
            if (p.escortFailed && params.escortDeathBoxes !== undefined) {
                const pushStageRect = (zoneId: string, b: Rect.Type): void => {
                    const vx = vp.stageX + b.x * vp.uiScale;
                    const vy = vp.stageY + b.y * vp.uiScale;
                    const vw = b.width * vp.uiScale;
                    const vh = b.height * vp.uiScale;
                    rectZones.push({
                        id: zoneId,
                        rect: Rect(
                            (vx - 4) / overlayScale,
                            (vy - 6) / overlayScale,
                            (vw + 8) / overlayScale,
                            (vh + 12) / overlayScale,
                        ),
                    });
                };
                pushStageRect("escort:retry", params.escortDeathBoxes.retry);
                pushStageRect("escort:title", params.escortDeathBoxes.title);
            } else if (params.storyTalentBoxes.length > 0) {
                // 男主线护送折笺三选一本领卡（从舞台 UI 空间换算到叠加层空间，手柄混用触屏时同样可直点）
                let ti = 0;
                for (ti = 0; ti < params.storyTalentBoxes.length; ti++) {
                    const b = params.storyTalentBoxes[ti];
                    const vx = vp.stageX + b.x * vp.uiScale;
                    const vy = vp.stageY + b.y * vp.uiScale;
                    const vw = b.width * vp.uiScale;
                    const vh = b.height * vp.uiScale;
                    rectZones.push({
                        id: "talent:" + ti,
                        rect: Rect(
                            (vx - 4) / overlayScale,
                            (vy - 6) / overlayScale,
                            (vw + 8) / overlayScale,
                            (vh + 12) / overlayScale,
                        ),
                    });
                }
            }
        }
        if (isPlayMode && p !== undefined && !modal && !cutsceneBlocking) {
            prompt = deriveWorldPrompt(p);
            if (prompt !== undefined && prompt.keyTag.indexOf("E") >= 0 && params.cam !== undefined
                && params.assistHintsEnabled) {
                const keyW = Math.max(24, visualTextWidth(prompt.keyTag, 15) + 16);
                const labelW = visualTextWidth(prompt.label, 15);
                const pillW = keyW + labelW + 24;
                const padX = Math.max(115, pillW * 0.5 + 24);
                const sxUi = Math.max(padX + vp.safeUi.left, Math.min(vp.uiW - padX - vp.safeUi.right, params.cam.sx(prompt.x) / vp.uiScale));
                const syUi = Math.max(96 + vp.safeUi.bottom, Math.min(vp.uiH - 110 - vp.safeUi.top, params.cam.sy(prompt.y) / vp.uiScale));
                const vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale;
                const vy = vp.stageY + (syUi - 22) * vp.uiScale;
                rectZones.push({
                    id: "worldPrompt",
                    rect: Rect(
                        vx / overlayScale,
                        vy / overlayScale,
                        ((pillW + 24) * vp.uiScale) / overlayScale,
                        (44 * vp.uiScale) / overlayScale,
                    ),
                });
            }
        }

        // 片尾定格满 8 秒后：横屏触屏提供底部居中「确认 / 再走一遍」胶囊钮，杜绝横屏触屏死锁
        if (isPlayMode && p !== undefined && !p.paused && overlayActive && !isPortrait
            && p.room.key === "tower" && p.phase === "tower-end" && p.towerEndReady()) {
            const cx = ovW * 0.5;
            const cy = safeB + 46;
            buttons.push({
                id: "nav_confirm",
                x: cx,
                y: cy,
                r: 26,
                shape: "pill",
                rect: Rect(cx - 88, cy - 22, 176, 44),
                label: "继续 · 归程",
                accent: "amber",
                active: false,
                highlighted: true,
                progress: 0,
                dimmed: false,
            });
        }

        // -------- D. 局内双线动作按钮（横屏右下扇形 / 竖屏下掌机右区）--------
        if (overlayActive && gameplayActive && p !== undefined && !modal && !cutsceneBlocking) {
            const interactMeta = deriveInteractActionMeta(p, prompt ?? deriveWorldPrompt(p), cartNearby, router.cartGripLatched);

            if (isPortrait) {
                const u = unitPortrait * sc;
                const rightX = ovW - safeR - Math.round(68 * u);
                const bottomY = Math.max(safeB + Math.round(70 * u), vp.deckH * 0.40);
                const postY = Math.min(vp.deckH - 26, stickDefaultY + stickMaxR + Math.round(42 * u));
                bottleCancelCenter = { x: rightX - Math.round(14 * u), y: bottomY + Math.round(10 * u), r: Math.round(34 * u) };

                if (!p.childMode) {
                    // 左侧上方掩体切换胶囊
                    const cw = Math.round(86 * u);
                    const ch = Math.round(32 * u);
                    buttons.push({
                        id: "cover",
                        x: stickDefaultX,
                        y: postY,
                        r: 24 * u,
                        shape: "pill",
                        toggle: true,
                        rect: Rect(stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch),
                        label: router.coverToggled ? "离掩体" : "贴掩体",
                        accent: "cyan",
                        active: router.coverToggled || p.coverHug,
                        highlighted: p.coverNear && !router.coverToggled,
                        progress: 0,
                        dimmed: !p.coverNear && !router.coverToggled,
                    });

                    // 右侧主控区
                    buttons.push({
                        id: "fire",
                        x: rightX,
                        y: bottomY + Math.round(8 * u),
                        r: Math.round(36 * u),
                        label: router.getFireStickVisual().dragging ? "松手射" : "开火",
                        subLabel: "拖瞄",
                        accent: "rouge",
                        active: router.isButtonHeld("fire"),
                        highlighted: p.reloadPendingEffect !== "",
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    const nearLedge = isNearLowLedgeForButton(p);
                    buttons.push({
                        id: "jump",
                        x: rightX - Math.round(84 * u),
                        y: bottomY - Math.round(16 * u),
                        r: Math.round(28 * u),
                        label: nearLedge ? "翻越" : "翻滚",
                        accent: "cyan",
                        active: router.isButtonHeld("jump"),
                        highlighted: nearLedge,
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    buttons.push({
                        id: "interact",
                        x: rightX - Math.round(10 * u),
                        y: bottomY + Math.round(88 * u),
                        r: Math.round(30 * u),
                        label: interactMeta.label,
                        subLabel: interactMeta.subLabel,
                        accent: interactMeta.urgent ? "rouge" : "amber",
                        active: router.isButtonHeld("interact"),
                        highlighted: interactMeta.available,
                        progress: interactMeta.progress,
                        dimmed: !interactMeta.available,
                    });
                    if (isPlayMode && p.archive.artifactOwned) {
                        const eq = p.equippedWeapon === "time_shuttler";
                        buttons.push({
                            id: "artifact",
                            x: rightX - Math.round(90 * u),
                            y: bottomY + Math.round(68 * u),
                            r: Math.round(24 * u),
                            label: eq ? "收器" : "穿梭",
                            accent: "amber",
                            active: eq,
                            highlighted: eq,
                            progress: 0,
                            dimmed: false,
                        });
                    }
                } else {
                    // 小满竖屏左侧上方：蹲伏 + 轻步切换胶囊
                    const pw = Math.round(68 * u);
                    const ph = Math.round(32 * u);
                    buttons.push({
                        id: "crouch",
                        x: stickDefaultX - Math.round(38 * u),
                        y: postY,
                        r: 22 * u,
                        shape: "pill",
                        toggle: true,
                        rect: Rect(stickDefaultX - Math.round(38 * u) - pw * 0.5, postY - ph * 0.5, pw, ph),
                        label: router.crouchToggled ? "起身" : "蹲伏",
                        accent: "emerald",
                        active: router.crouchToggled || p.player.crouch,
                        highlighted: p.scavChase && !p.player.crouch,
                        progress: 0,
                        dimmed: false,
                    });
                    buttons.push({
                        id: "cover",
                        x: stickDefaultX + Math.round(38 * u),
                        y: postY,
                        r: 22 * u,
                        shape: "pill",
                        toggle: true,
                        rect: Rect(stickDefaultX + Math.round(38 * u) - pw * 0.5, postY - ph * 0.5, pw, ph),
                        label: router.slowToggled ? "常步" : "轻步",
                        accent: "silk",
                        active: router.slowToggled,
                        highlighted: false,
                        progress: 0,
                        dimmed: false,
                    });

                    // 小满竖屏右侧：大交互 + 跳跃 +（持瓶时）投瓶
                    buttons.push({
                        id: "jump",
                        x: rightX,
                        y: bottomY + Math.round(8 * u),
                        r: Math.round(32 * u),
                        label: "跳跃",
                        accent: "amber",
                        active: router.isButtonHeld("jump"),
                        highlighted: false,
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    buttons.push({
                        id: "interact",
                        x: rightX - Math.round(8 * u),
                        y: bottomY + Math.round(86 * u),
                        r: Math.round(31 * u),
                        label: interactMeta.label,
                        subLabel: interactMeta.subLabel,
                        accent: interactMeta.urgent ? "rouge" : "amber",
                        active: router.isButtonHeld("interact"),
                        highlighted: interactMeta.available,
                        progress: interactMeta.progress,
                        dimmed: !interactMeta.available,
                    });
                    if (canBottleAim) {
                        buttons.push({
                            id: "bottle",
                            x: rightX - Math.round(86 * u),
                            y: bottomY + Math.round(46 * u),
                            r: Math.round(32 * u),
                            label: "投瓶",
                            subLabel: "拖瞄",
                            accent: "amber",
                            active: router.isButtonHeld("bottle"),
                            highlighted: true,
                            progress: Math.min(1, p.aimHold / 0.12),
                            dimmed: false,
                        });
                    }
                }
            } else {
                // 横屏右手宋明扇形圆钮布局（1280×720 基准逻辑像素）
                const rightX = ovW - safeR - 92 * sc;
                const bottomY = safeB + 110 * sc;
                bottleCancelCenter = { x: rightX - 186 * sc, y: bottomY + 126 * sc, r: 42 * sc };

                if (!p.childMode) {
                    buttons.push({
                        id: "fire",
                        x: rightX,
                        y: bottomY + 12 * sc,
                        r: 45 * sc,
                        label: router.getFireStickVisual().dragging ? "松手射" : "开火",
                        subLabel: "拖瞄",
                        accent: "rouge",
                        active: router.isButtonHeld("fire"),
                        highlighted: p.reloadPendingEffect !== "",
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    const nearLedge = isNearLowLedgeForButton(p);
                    buttons.push({
                        id: "jump",
                        x: rightX - 116 * sc,
                        y: bottomY - 8 * sc,
                        r: 34 * sc,
                        label: nearLedge ? "翻越" : "翻滚",
                        accent: "cyan",
                        active: router.isButtonHeld("jump"),
                        highlighted: nearLedge,
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    buttons.push({
                        id: "cover",
                        x: rightX - 120 * sc,
                        y: bottomY + 94 * sc,
                        r: 32 * sc,
                        label: router.coverToggled ? "离掩" : "掩体",
                        accent: "cyan",
                        active: router.coverToggled,
                        highlighted: p.coverNear && !router.coverToggled,
                        progress: 0,
                        dimmed: !p.coverNear && !router.coverToggled,
                    });
                    buttons.push({
                        id: "interact",
                        x: rightX - 10 * sc,
                        y: bottomY + 122 * sc,
                        r: 36 * sc,
                        label: interactMeta.label,
                        subLabel: interactMeta.subLabel,
                        accent: interactMeta.urgent ? "rouge" : "amber",
                        active: router.isButtonHeld("interact"),
                        highlighted: interactMeta.available,
                        progress: interactMeta.progress,
                        dimmed: !interactMeta.available,
                    });
                    if (isPlayMode && p.archive.artifactOwned) {
                        const eq = p.equippedWeapon === "time_shuttler";
                        buttons.push({
                            id: "artifact",
                            x: rightX - 112 * sc,
                            y: bottomY + 184 * sc,
                            r: 27 * sc,
                            label: eq ? "收器" : "穿梭",
                            accent: "amber",
                            active: eq,
                            highlighted: eq,
                            progress: 0,
                            dimmed: false,
                        });
                    }
                } else {
                    buttons.push({
                        id: "jump",
                        x: rightX,
                        y: bottomY + 12 * sc,
                        r: 38 * sc,
                        label: "跳跃",
                        accent: "amber",
                        active: router.isButtonHeld("jump"),
                        highlighted: false,
                        progress: 0,
                        dimmed: p.gripping,
                    });
                    buttons.push({
                        id: "crouch",
                        x: rightX - 106 * sc,
                        y: bottomY - 6 * sc,
                        r: 34 * sc,
                        label: router.crouchToggled ? "起身" : "蹲伏",
                        accent: "emerald",
                        active: router.crouchToggled || p.player.crouch,
                        highlighted: p.scavChase && !p.player.crouch,
                        progress: 0,
                        dimmed: false,
                    });
                    buttons.push({
                        id: "cover",
                        x: rightX - 196 * sc,
                        y: bottomY - 16 * sc,
                        r: 29 * sc,
                        label: router.slowToggled ? "常步" : "轻步",
                        accent: "silk",
                        active: router.slowToggled,
                        highlighted: false,
                        progress: 0,
                        dimmed: false,
                    });
                    buttons.push({
                        id: "interact",
                        x: rightX - 12 * sc,
                        y: bottomY + 114 * sc,
                        r: 36 * sc,
                        label: interactMeta.label,
                        subLabel: interactMeta.subLabel,
                        accent: interactMeta.urgent ? "rouge" : "amber",
                        active: router.isButtonHeld("interact"),
                        highlighted: interactMeta.available,
                        progress: interactMeta.progress,
                        dimmed: !interactMeta.available,
                    });
                    if (canBottleAim) {
                        buttons.push({
                            id: "bottle",
                            x: rightX - 114 * sc,
                            y: bottomY + 98 * sc,
                            r: 38 * sc,
                            label: "投瓶",
                            subLabel: "拖瞄",
                            accent: "amber",
                            active: router.isButtonHeld("bottle"),
                            highlighted: true,
                            progress: Math.min(1, p.aimHold / 0.12),
                            dimmed: false,
                        });
                    }
                }
            }
        }

        // -------- E. 采集活体敌兵与主角枪口锚点（主舞台局部坐标，触屏与手柄共享同一工具）--------
        const enemyTargets = canShoot && p !== undefined && isPlayMode && params.cam !== undefined
            ? collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH)
            : [];

        let playerScreenX = vp.stageW * 0.5;
        let playerScreenY = vp.stageH * 0.38;
        if (p !== undefined) {
            if (isPlayMode && params.cam !== undefined) {
                playerScreenX = params.cam.sx(p.player.x + p.player.facing * 8);
                playerScreenY = params.cam.sy(p.player.y + p.player.h * 0.72, p.player.depth);
            } else {
                playerScreenX = vp.stageW * 0.45;
                playerScreenY = vp.stageH * 0.36;
            }
        }

        const ctx: TouchFrameContext = {
            viewport: vp,
            overlayScale,
            overlayActive,
            allowAutoGameplayTouch,
            allowMouseOnOverlay,
            modal,
            gameplayActive,
            cutsceneBlocking,
            childMode: p !== undefined && p.childMode,
            allowDepth,
            canShoot,
            canBottleAim,
            cartNearby,
            cartGripping: p !== undefined && p.gripping,
            cartUsesToggle: p !== undefined && p.room.key === "c2-granary",
            coverNear: p !== undefined && p.coverNear,
            playerRolling: p !== undefined && p.player.rollT > 0,
            inLowArch: p !== undefined && isInLowArch(p),
            inTowerEnd: isPlayMode && p !== undefined && p.room.key === "tower" && p.phase === "tower-end",
            playerFacing: p !== undefined ? p.player.facing : 1,
            playerScreenX,
            playerScreenY,
            enemyTargets,
            stickZoneMaxX,
            stickZoneMaxY,
            stickDefaultX,
            stickDefaultY,
            stickMaxR,
            stickFixedOrigin: isPortrait,
            buttons,
            rectZones,
            bottleCancelCenter,
        };

        this.lastContext = ctx;
        router.setFrameContext(ctx, params.dt);
        return ctx;
    }

    /** 每帧渲染水墨触控叠加层与竖屏掌机外框（在主前端与试炼层之后调用）。 */
    render(router: TouchRouter): void {
        this.deckDraw.clear();
        this.padDraw.clear();
        this.padInkDraw.clear();
        this.padGlow.clear();
        this.padArt.beginFrame();
        this.texts.beginFrame();

        const ctx = this.lastContext;
        if (ctx === undefined || (!ctx.overlayActive && !ctx.viewport.isPortrait)) {
            this.padArt.endFrame();
            this.texts.endFrame();
            return;
        }

        const vp = ctx.viewport;
        const sc = Math.max(0.25, ctx.overlayScale);
        this.overlayRoot.scaleX = sc;
        this.overlayRoot.scaleY = sc;

        const ovW = vp.fullW / sc;
        const ovH = vp.fullH / sc;
        const baseAlpha = router.settings.touchOpacity;

        // 1. 竖屏掌机外壳（鸦青顶条 + 左右遮边 + 下半屏宋明水墨掌机底座）
        if (vp.isPortrait) {
            this.drawPortraitFrame(ctx, ovW, ovH);
        }

        if (!ctx.overlayActive) {
            this.padArt.endFrame();
            this.texts.endFrame();
            return;
        }

        // 2. 北塔尾声可轻触再启程浮签
        if (ctx.cutsceneBlocking && ctx.inTowerEnd && !ctx.modal) {
            const rx = ovW * 0.5;
            const ry = vp.isPortrait ? Math.max(vp.safe.bottom + 54, vp.deckH * 0.5) : (vp.safe.bottom / sc + 54);
            drawSilkVeil(this.padDraw, this.padArt, "touch_restart_veil", rx, ry, 230, 36, PALETTE.inkWash, 0.78 * baseAlpha, 1);
            drawHairline(this.padInkDraw, this.padArt, "touch_restart_line", rx, ry + 16, 180, PALETTE.amber, 0.52 * baseAlpha, true, 2);
            this.texts.put("xs", "轻触屏幕再次启程", rx, ry, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.6, 0.94, 0.08);
        }

        // 3. 左手虚拟摇杆（非模态、非过场局内绘制）
        if (ctx.gameplayActive && !ctx.modal && !ctx.cutsceneBlocking) {
            this.drawStick(router, ctx, baseAlpha);
        }

        // 5. 全部按钮（顶栏快捷钮、竖屏导航键、局内动作圆钮/胶囊）
        this.drawButtons(router, ctx, baseAlpha);

        // 6. 空村投瓶拖拽取消圈
        const bottleDrag = router.getBottleDragVisual();
        if (bottleDrag.active) {
            const cx = bottleDrag.cancelX;
            const cy = bottleDrag.cancelY;
            const cr = bottleDrag.cancelR;
            const hot = bottleDrag.cancelHover;
            fillCirclePoly(
                this.padDraw,
                cx,
                cy,
                cr,
                toColor(hot ? PALETTE.crimsonDeep : PALETTE.inkWash, hot ? 225 : 175),
                0,
                undefined,
                22,
            );
            drawRingArc(this.padInkDraw, cx, cy, cr, 0, TWO_PI, hot ? 2.2 : 1.3, toColor(hot ? PALETTE.crimsonCore : PALETTE.rouge, hot ? 245 : 185), 22);
            this.texts.put("xs", hot ? "松手取消" : "拖此取消", cx, cy, toColor(hot ? PALETTE.crimsonCore : PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.8, 0.96, 0.08);
        }

        this.padArt.endFrame();
        this.texts.endFrame();
    }

    private drawPortraitFrame(ctx: TouchFrameContext, w: number, h: number): void {
        const vp = ctx.viewport;
        const topY = vp.stageY + vp.stageH;

        if (topY < h) {
            this.deckDraw.drawRect(Rect(0, topY, w, h - topY), toColor(PALETTE.inkVoid, 252));
            this.deckDraw.drawSegment(Vec2(0, topY), Vec2(w, topY), 1.0, toColor(PALETTE.silkDim, 140));
            const labelY = topY + (h - topY) * 0.5;
            this.texts.put("xs", "向西守望 · 掌机竖屏", vp.safe.left + 12, labelY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.8, 0.88, 0.08);
        }

        if (vp.stageX > 0) {
            this.deckDraw.drawRect(Rect(0, vp.stageY, vp.stageX, vp.stageH), toColor(PALETTE.inkVoid, 255));
            this.deckDraw.drawRect(Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), toColor(PALETTE.inkVoid, 255));
        }

        if (vp.deckH > 0) {
            fillVGradRect(this.deckDraw, 0, 0, w, vp.deckH, toColor(PALETTE.voidDark, 255), toColor(PALETTE.inkWash, 255));
            this.deckDraw.drawSegment(Vec2(0, vp.deckH), Vec2(w, vp.deckH), 1.2, toColor(PALETTE.silkLine, 165));
            this.deckDraw.drawSegment(Vec2(18, vp.deckH - 4), Vec2(w - 18, vp.deckH - 4), 0.6, toColor(PALETTE.silkDim, 85));
            drawDiamond(this.padInkDraw, w * 0.5, vp.deckH, 5, 5, toColor(PALETTE.rouge, 220), 0.9, toColor(PALETTE.silkLine, 180));

            const footY = Math.max(vp.safe.bottom + 14, 16);
            const p = this.lastPlay;
            const inOverlayModal = p !== undefined && (p.reloadOpen || p.craftBench.active);
            const inChoiceModal = p !== undefined && (p.escortFailed || (p.talentModalActive && p.getStoryTalentOffers().length > 0));
            const hint = inOverlayModal
                ? "直接在上屏点按或一笔划连"
                : ((!ctx.gameplayActive || (p !== undefined && p.paused) || inChoiceModal)
                    ? "可点上屏菜单或用下方导航键"
                    : (ctx.childMode
                        ? "左摇杆内圈轻步 · 蹲伏/轻步点按切换"
                        : "左摇杆走位 · 点上屏或拖「开火」瞄射"));
            this.texts.put("xs", hint, w * 0.5, footY, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 0.8, 0.78, 0.06);
        }
    }

    private drawStick(router: TouchRouter, ctx: TouchFrameContext, baseAlpha: number): void {
        const stick = router.getStickVisual();
        const stickAlpha = stick.active
            ? Math.min(1, baseAlpha + 0.16)
            : (ctx.viewport.isPortrait ? Math.min(0.95, baseAlpha * 0.92) : baseAlpha * 0.72);
        const ringCol = stick.active ? PALETTE.textBright : PALETTE.silkDim;

        fillCirclePoly(
            this.padDraw,
            stick.originX,
            stick.originY,
            stick.radius,
            toColor(PALETTE.inkWash, (stick.active ? 118 : 78) * stickAlpha),
            0,
            undefined,
            28,
        );
        drawRingArc(this.padInkDraw, stick.originX, stick.originY, stick.radius, 0, TWO_PI, stick.active ? 1.5 : 1.0, toColor(ringCol, 168 * stickAlpha), 28);

        if (stick.allowDepth) {
            const dOff = stick.radius - 10;
            this.padInkDraw.drawDot(Vec2(stick.originX, stick.originY + dOff), 2.1, toColor(PALETTE.cyan, 155 * stickAlpha));
            this.padInkDraw.drawDot(Vec2(stick.originX, stick.originY - dOff), 2.1, toColor(PALETTE.cyan, 155 * stickAlpha));
            this.padInkDraw.drawDot(Vec2(stick.originX - dOff, stick.originY), 2.1, toColor(PALETTE.silkLine, 145 * stickAlpha));
            this.padInkDraw.drawDot(Vec2(stick.originX + dOff, stick.originY), 2.1, toColor(PALETTE.silkLine, 145 * stickAlpha));
        } else if (ctx.childMode) {
            drawRingArc(
                this.padInkDraw,
                stick.originX,
                stick.originY,
                stick.radius * 0.56,
                0,
                TWO_PI,
                0.9,
                toColor(stick.slowZone ? PALETTE.emerald : PALETTE.silkDim, (stick.slowZone ? 210 : 95) * stickAlpha),
                20,
            );
        }

        const knobR = Math.max(16, stick.radius * 0.36);
        const knobAccent = stick.slowZone ? PALETTE.emerald : (ctx.childMode ? PALETTE.amber : PALETTE.cyan);
        if (stick.active) {
            fillRadialGlow(this.padGlow, stick.knobX, stick.knobY, knobR * 1.45, knobR * 1.45, toColor(knobAccent, 48 * stickAlpha), Color(0, 0, 0, 0), 12);
        }
        fillCirclePoly(
            this.padDraw,
            stick.knobX,
            stick.knobY,
            knobR,
            toColor(PALETTE.panelBgDeep, (stick.active ? 215 : 155) * stickAlpha),
            1.3,
            toColor(stick.active ? knobAccent : PALETTE.silkLine, 210 * stickAlpha),
            22,
        );
        drawBlossomDot(this.padInkDraw, this.padArt, "touch_stick_dot", stick.knobX, stick.knobY, stick.active ? 11 : 7, knobAccent, 0.85 * stickAlpha, 4);
        if (stick.slowZone) {
            this.texts.put("xs", "轻步", stick.originX, stick.originY + stick.radius + 14, toColor(PALETTE.emerald), 0.5, 0.5, TextAlign.Center, 1.0, 0.90, 0.08);
        }
    }

    private drawButtons(router: TouchRouter, ctx: TouchFrameContext, baseAlpha: number): void {
        const bottleDrag = router.getBottleDragVisual();
        const fireStick = router.getFireStickVisual();
        const fontKind = ctx.viewport.isPortrait ? "xs" : "sm";

        let i = 0;
        for (i = 0; i < ctx.buttons.length; i++) {
            const b = ctx.buttons[i];
            let bAlpha = baseAlpha * (b.dimmed ? 0.42 : (b.active || b.highlighted ? 1.0 : 0.84));
            if (bottleDrag.active && b.id !== "bottle" && b.shape !== "pill") {
                bAlpha *= 0.25;
            }
            const col = accentPalette(b.accent);
            const core = accentCore(b.accent);
            const breathe = b.highlighted ? (0.86 + 0.14 * Math.sin(this.time * 4.2)) : 1;

            if (b.shape === "pill" && b.rect !== undefined) {
                const r = b.rect;
                const fillCol = b.active
                    ? toColor(col, 110 * bAlpha)
                    : toColor(PALETTE.inkWash, 175 * bAlpha);
                this.padDraw.drawRoundedRect(
                    r,
                    6,
                    fillCol,
                    b.active ? 1.4 : 1.0,
                    toColor(b.active || b.highlighted ? col : PALETTE.silkLine, 200 * bAlpha),
                );
                if (b.id === "pause" && !ctx.viewport.isPortrait) {
                    const icX = r.x + 22;
                    const icY = r.y + r.height * 0.5;
                    drawRingArc(this.padInkDraw, icX, icY, 9, 0, TWO_PI, 1.0, toColor(PALETTE.silkLine, 175 * bAlpha), 16);
                    this.padInkDraw.drawSegment(Vec2(icX - 2.6, icY - 3.6), Vec2(icX - 2.6, icY + 3.6), 1.5, toColor(PALETTE.textBright, 225 * bAlpha));
                    this.padInkDraw.drawSegment(Vec2(icX + 2.6, icY - 3.6), Vec2(icX + 2.6, icY + 3.6), 1.5, toColor(PALETTE.textBright, 225 * bAlpha));
                    this.texts.put("xs", b.label, r.x + r.width * 0.5 + 10, icY, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.0, 0.94 * bAlpha, 0.08);
                } else {
                    if (b.toggle && b.active) {
                        drawDiamond(this.padInkDraw, r.x + 11, r.y + r.height * 0.5, 3.8, 3.8, toColor(col, 235));
                    }
                    this.texts.put(
                        "xs",
                        b.label,
                        r.x + r.width * 0.5 + (b.toggle && b.active ? 4 : 0),
                        r.y + r.height * 0.5,
                        toColor(b.active ? core : PALETTE.textBright),
                        0.5,
                        0.5,
                        TextAlign.Center,
                        0.6,
                        Math.min(1, bAlpha + 0.08),
                        0.08,
                    );
                }
                continue;
            }

            if (b.active || b.highlighted) {
                fillRadialGlow(
                    this.padGlow,
                    b.x,
                    b.y,
                    b.r * 1.38,
                    b.r * 1.38,
                    toColor(col, (b.active ? 64 : 36) * bAlpha * breathe),
                    Color(col.r, col.g, col.b, 0),
                    12,
                );
            }

            fillCirclePoly(
                this.padDraw,
                b.x,
                b.y,
                b.r,
                toColor(b.active ? PALETTE.inkWarm : PALETTE.inkWash, (b.active ? 195 : 142) * bAlpha),
                0,
                undefined,
                24,
            );
            drawRingArc(
                this.padInkDraw,
                b.x,
                b.y,
                b.r,
                0,
                TWO_PI,
                b.active ? 2.0 : (b.highlighted ? 1.5 : 1.05),
                toColor(b.active || b.highlighted ? col : PALETTE.silkDim, (b.active ? 235 : 185) * bAlpha),
                24,
            );
            drawRingArc(
                this.padInkDraw,
                b.x,
                b.y,
                b.r - 4.2,
                0,
                TWO_PI,
                0.7,
                toColor(PALETTE.silkLine, (b.active ? 110 : 52) * bAlpha),
                20,
            );

            if (b.progress > 0.02) {
                drawRingArc(
                    this.padInkDraw,
                    b.x,
                    b.y,
                    b.r + 4,
                    HALF_PI,
                    -TWO_PI * Math.min(1, b.progress),
                    2.6,
                    toColor(PALETTE.amberCore, 240),
                    28,
                );
            }

            const hasSub = b.subLabel !== undefined && b.subLabel !== "";
            this.texts.put(
                fontKind,
                b.label,
                b.x,
                hasSub ? b.y + 6 : b.y,
                toColor(b.active ? core : (b.dimmed ? PALETTE.textDim : PALETTE.textBright)),
                0.5,
                0.5,
                TextAlign.Center,
                0.6,
                bAlpha,
                0.08,
            );
            if (hasSub && b.subLabel !== undefined) {
                this.texts.put(
                    "xs",
                    b.subLabel,
                    b.x,
                    b.y - (ctx.viewport.isPortrait ? 11 : 14),
                    toColor(b.active ? core : PALETTE.textDim),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.4,
                    bAlpha * 0.85,
                    0.06,
                );
            }

            if (b.id === "fire" && fireStick.active && fireStick.dragging) {
                this.padInkDraw.drawSegment(Vec2(fireStick.originX, fireStick.originY), Vec2(fireStick.knobX, fireStick.knobY), 1.4, toColor(PALETTE.rouge, 190));
                fillCirclePoly(this.padDraw, fireStick.knobX, fireStick.knobY, 12, toColor(PALETTE.rouge, 210), 1.2, toColor(PALETTE.crimsonCore, 240), 16);
            }
        }
    }
}
