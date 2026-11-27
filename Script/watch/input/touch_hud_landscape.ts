/**
 * 《向西守望》宋明水墨触控叠加层（仅安卓、安卓掌机与 Web 目标引入）。
 *
 * 性能优化：
 * 1. 专用轻量化 TextPool（{ xs: 24, sm: 12 } = 36 个 Label，较旧版 178 个削减 80% 节点数）；
 * 2. 隐藏态脏清标记（hasDrawn）：手柄态/键鼠态隐藏时仅首帧清空一次，后续帧零 clear/零遍历；
 * 3. 可选竖屏委托（portraitDelegate）：掌机端传 undefined，物理不引入竖屏代码；
 * 4. 复用外部单次采集的 enemyTargets，消除触屏+手柄重复投影。
 *
 * 注意：Windows 发行包不引入、不打包本模块。
 */

import { BlendFunc, BlendOp, Color, DrawNode, Node, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { RunState } from "Script/watch/run";
import { AimTargetCandidate, collectAimTargets, projectMuzzle } from "Script/watch/input/aim_assist";
import {
    TouchAccent,
    TouchButtonSpec,
    TouchFrameContext,
    TouchRectZone,
    TouchRouter,
} from "Script/watch/input/touch_core";
import { deriveInteractActionMeta } from "Script/watch/input/touch_interact_meta";
import type { PortraitTouchDelegate } from "Script/watch/input/touch_hud_portrait";
import { WorldPrompt, deriveWorldPrompt } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { ScreenKind } from "Script/watch/fe/ui/menus";
import { isCutsceneBlockingPlay } from "Script/watch/fe/ui/play_prompts";
import { StageViewport } from "Script/watch/target_types";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawDiamond,
    drawHairline,
    drawSilkVeil,
    fillRadialGlow,
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
    router: TouchRouter;
    overlayActive: boolean;
    allowAutoGameplayTouch: boolean;
    allowMouseOnOverlay: boolean;
    showWebTopPills: boolean;
    canToggleFullscreen: boolean;
    assistHintsEnabled: boolean;
    isMuted: boolean;
    isFullscreen: boolean;
    storyTalentBoxes: Rect.Type[];
    enemyTargets?: AimTargetCandidate[];
    escortDeathBoxes?: { retry: Rect.Type; title: Rect.Type };
    ledgerButtonBox?: Rect.Type;
    dt: number;
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
    private deckDraw: DrawNode.Type | undefined;
    private padDraw: DrawNode.Type;
    private padArt: AssetSlotHost;
    private padInkDraw: DrawNode.Type;
    private padGlow: DrawNode.Type;
    private texts: TextPool;
    private portraitDelegate: PortraitTouchDelegate | undefined;

    private lastContext: TouchFrameContext | undefined;
    private lastMode = 1;
    private lastScreen: ScreenKind = "title";
    private lastPlay: Play | undefined;
    private lastRun: RunState | undefined;
    private time = 0;
    private hasDrawn = false;

    constructor(parent: Node.Type, portraitDelegate?: PortraitTouchDelegate) {
        this.portraitDelegate = portraitDelegate;

        this.overlayRoot = Node();
        this.overlayRoot.order = 60;
        this.overlayRoot.addTo(parent);

        if (portraitDelegate !== undefined) {
            const deck = DrawNode();
            deck.order = 0;
            deck.addTo(this.overlayRoot);
            this.deckDraw = deck;
        }

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

        // 触控层仅用 xs / sm 两桶，由 178 个 SDF Label 精简至 36 个（省 142 个 C++ 节点）
        this.texts = new TextPool(this.overlayRoot, 10, { xs: 24, sm: 12 });
    }

    getAllocatedLabelCount(): number {
        return this.texts.totalAllocated;
    }

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

    syncContext(params: TouchOverlaySyncParams): TouchFrameContext {
        this.time += Math.min(0.05, Math.max(0, params.dt));
        this.lastMode = params.mode;
        this.lastScreen = params.screen;
        this.lastPlay = params.play;
        this.lastRun = params.run;

        const vp = params.viewport;
        const p = params.play;
        const router = params.router;
        const pDel = this.portraitDelegate;
        const isPortrait = pDel !== undefined && vp.isPortrait;
        const overlayScale = isPortrait ? 1 : vp.uiScale;
        const ovW = vp.fullW / Math.max(0.25, overlayScale);
        const ovH = vp.fullH / Math.max(0.25, overlayScale);
        const safeL = vp.safe.left / Math.max(0.25, overlayScale);
        const safeR = vp.safe.right / Math.max(0.25, overlayScale);
        const safeT = vp.safe.top / Math.max(0.25, overlayScale);
        const safeB = vp.safe.bottom / Math.max(0.25, overlayScale);

        const overlayActive = params.overlayActive;
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

        const pGeom = isPortrait && pDel !== undefined
            ? pDel.computeStickGeom(vp, ovW, safeL, safeB, sc)
            : undefined;
        const stickMaxR = pGeom !== undefined ? pGeom.stickMaxR : STICK_BASE_R_LANDSCAPE * sc;
        const stickDefaultX = pGeom !== undefined ? pGeom.stickDefaultX : safeL + 126 * sc;
        const stickDefaultY = pGeom !== undefined ? pGeom.stickDefaultY : safeB + 126 * sc;
        const stickZoneMaxX = pGeom !== undefined ? pGeom.stickZoneMaxX : ovW * 0.46;
        const stickZoneMaxY = pGeom !== undefined ? pGeom.stickZoneMaxY : ovH - 110;

        let bottleCancelCenter = { x: ovW - safeR - 106 * sc, y: safeB + 124 * sc, r: 44 * sc };

        // A. 顶部快捷条
        if (overlayActive) {
            if (isPortrait && pDel !== undefined) {
                pDel.pushTopButtons(
                    buttons, vp, ovW, ovH, safeR, gameplayActive, p,
                    params.isMuted, params.isFullscreen, params.canToggleFullscreen,
                );
            } else if (isPlayMode && !modal) {
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
                if (params.showWebTopPills) {
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
                    if (params.canToggleFullscreen) {
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

        // B. 竖屏菜单掌机导航键（菜单、暂停、折笺与折戟小结均支持）
        if (isPortrait && pDel !== undefined && overlayActive && params.screen !== "splash"
            && (!gameplayActive || (isPlayMode && p !== undefined && (p.paused || talentModalOpen || escortSummaryOpen)))) {
            pDel.pushMenuNavButtons(buttons, vp, ovW, safeL, safeR, safeB);
        }

        // C. 局内直点矩形热区（折笺本领卡、折戟小结按钮、札记章、世界交互气泡）
        let prompt: WorldPrompt | undefined;
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
        if (isPlayMode && p !== undefined && !p.paused && !p.craftBench.active && !p.reloadOpen && !cutsceneBlocking) {
            if (p.escortFailed && params.escortDeathBoxes !== undefined) {
                pushStageRect("escort:retry", params.escortDeathBoxes.retry);
                pushStageRect("escort:title", params.escortDeathBoxes.title);
            } else {
                if (params.ledgerButtonBox !== undefined && params.ledgerButtonBox.width > 0) {
                    pushStageRect("ledger:toggle", params.ledgerButtonBox);
                }
                if (params.storyTalentBoxes.length > 0) {
                    // 男主线护送三选一本领卡（从舞台 UI 空间换算到叠加层空间，手柄混用触屏时同样可直点）
                    let ti = 0;
                    for (ti = 0; ti < params.storyTalentBoxes.length; ti++) {
                        pushStageRect("talent:" + ti, params.storyTalentBoxes[ti]);
                    }
                    // 竖屏下掌机台顶部生成大拇指直点筹键（物理隔离：仅在竖屏委托存在时触发）
                    if (isPortrait && pDel !== undefined && overlayActive && vp.deckH >= 150) {
                        const cnt = Math.min(3, params.storyTalentBoxes.length);
                        const padX = Math.max(10, safeL + 10);
                        const gap = 8;
                        const bw = Math.floor((ovW - padX * 2 - gap * (cnt - 1)) / cnt);
                        const bh = 32;
                        const by = vp.deckH - bh - 10;
                        let di = 0;
                        for (di = 0; di < cnt; di++) {
                            const bx = padX + di * (bw + gap);
                            rectZones.push({
                                id: "talent:" + di,
                                rect: Rect(bx, by, bw, bh),
                            });
                        }
                    }
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

        // D. 局内双线动作按钮（横屏右下扇形 / 竖屏下掌机右区）
        if (overlayActive && gameplayActive && p !== undefined && !modal && !cutsceneBlocking) {
            const interactMeta = deriveInteractActionMeta(p, prompt ?? deriveWorldPrompt(p), cartNearby, router.cartGripLatched);
            const nearLedge = isNearLowLedgeForButton(p);

            if (isPortrait && pDel !== undefined && pGeom !== undefined) {
                bottleCancelCenter = pDel.pushActionButtons(
                    buttons, vp, ovW, safeR, safeB, pGeom, sc,
                    p, isPlayMode, canBottleAim, nearLedge, interactMeta, router,
                );
            } else {
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

        // E. 优先复用调用方单次采集的敌兵目标，避免双算；仅在开启磁吸且可射击时采集
        let enemyTargets: AimTargetCandidate[];
        if (params.enemyTargets !== undefined) {
            enemyTargets = params.enemyTargets;
        } else if (canShoot && router.settings.aimAssist && p !== undefined) {
            enemyTargets = collectAimTargets(p, params.cam, vp.stageW, vp.stageH);
        } else {
            enemyTargets = [];
        }

        const muzzle = p !== undefined ? projectMuzzle(p, params.cam) : undefined;
        const playerScreenX = muzzle?.x ?? vp.stageW * 0.5;
        const playerScreenY = muzzle?.y ?? vp.stageH * 0.38;

        const ctx: TouchFrameContext = {
            viewport: vp,
            overlayScale,
            overlayActive,
            allowAutoGameplayTouch: params.allowAutoGameplayTouch,
            allowMouseOnOverlay: params.allowMouseOnOverlay,
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

    render(router: TouchRouter): void {
        const ctx = this.lastContext;
        const pDel = this.portraitDelegate;
        const portraitVisible = pDel !== undefined && ctx !== undefined && ctx.viewport.isPortrait;
        const visible = ctx !== undefined && (ctx.overlayActive || portraitVisible);

        if (!visible) {
            if (!this.hasDrawn) {
                return;
            }
            this.deckDraw?.clear();
            this.padDraw.clear();
            this.padInkDraw.clear();
            this.padGlow.clear();
            this.padArt.beginFrame();
            this.padArt.endFrame();
            this.texts.hideAll();
            this.hasDrawn = false;
            return;
        }

        this.hasDrawn = true;
        this.deckDraw?.clear();
        this.padDraw.clear();
        this.padInkDraw.clear();
        this.padGlow.clear();
        this.padArt.beginFrame();
        this.texts.beginFrame();

        const vp = ctx.viewport;
        const sc = Math.max(0.25, ctx.overlayScale);
        this.overlayRoot.scaleX = sc;
        this.overlayRoot.scaleY = sc;

        const ovW = vp.fullW / sc;
        const ovH = vp.fullH / sc;
        const baseAlpha = router.settings.touchOpacity;

        if (portraitVisible && pDel !== undefined && this.deckDraw !== undefined) {
            pDel.drawFrame(this.deckDraw, this.padInkDraw, this.texts, ctx, this.lastPlay, ovW, ovH);
        }

        if (!ctx.overlayActive) {
            this.padArt.endFrame();
            this.texts.endFrame();
            return;
        }

        if (ctx.cutsceneBlocking && ctx.inTowerEnd && !ctx.modal) {
            const rx = ovW * 0.5;
            const ry = portraitVisible ? Math.max(vp.safe.bottom + 54, vp.deckH * 0.5) : (vp.safe.bottom / sc + 54);
            drawSilkVeil(this.padDraw, this.padArt, "touch_restart_veil", rx, ry, 230, 36, PALETTE.inkWash, 0.78 * baseAlpha, 1);
            drawHairline(this.padInkDraw, this.padArt, "touch_restart_line", rx, ry + 16, 180, PALETTE.amber, 0.52 * baseAlpha, true, 2);
            this.texts.put("xs", "轻触屏幕再次启程", rx, ry, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.6, 0.94, 0.08);
        }

        // 3. 左手虚拟摇杆（非模态、非过场局内绘制）
        if (ctx.gameplayActive && !ctx.modal && !ctx.cutsceneBlocking) {
            this.drawStick(router, ctx, baseAlpha);
        }

        this.drawButtons(router, ctx, baseAlpha);

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
