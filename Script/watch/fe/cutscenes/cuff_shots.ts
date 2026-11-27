/**
 * 《向西守望》同一道补线袖口三镜与双出口交权演出插件（Wave 1 · feature/fe-01-gate-cuff-lowpoly）。
 *
 * 设计红线（严格对表《游戏分镜稿》《动画插入与演出规划》《明朝全局美术设定》）：
 * 1. 同一道补线袖口贯通四镜：
 *    - 导出统一无状态绘制组件 drawPatchedCuff()，固定明初守卒暗靛青粗布袖 + 护臂旧麻布 + 浅麻线六针斜补缝；
 *    - 灰度亮度差 > 60%，确保静音、灰度、周戍未露脸前观众仅凭这道浅补线就能立刻认出他；
 *    - 本分支落地 P03（柜边相认）、P05（城门送别）、G05（男主线风台重逢），并预留导出供 Wave 2 fe-06 的 E02 博物馆回柜直接复用。
 * 2. 三镜精确节拍：
 *    - P03（约 3s / 兼容 live 60 拍 prologue-give）：柜缝先伸两指 → 补线袖口揩走柜沿碎瓷（配 cloth_wipe_wood 声）→ 掌心递手入柜；
 *    - P05（约 4s / 兼容 live gate-send→gate-count 衔接）：小满扯紧补袖 → 周戍隔布轻捏手 + 定稿台词
 *      「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」→ 落门声盖兵声留外壕水声 → 定格张开手指姿态衔接 G01 首帧；
 *    - G05（男主线数满二十，约 4s / 兼容 story-b1-carry 90 拍 gate-hand）：风台安全待机 → 两下轻叩 → 小满抬手 →
 *      按住交互键（0.6s / 36 拍）袖口随 holdProgress 伸进画面，中途松手袖口平滑退回画边可重试 →
 *      满 0.6s 握稳掌心，沿相握手臂抬镜至周戍脸部并切回序章像素风，单次说「我们走吧。」。
 * 3. 零引导与暂停纪律：
 *    - 默认关闭按键提示（仅 assistHintsEnabled === true 时显示轻量按住 E 提示）；
 *    - 全部动画与退回计时吃 worldDt，暂停立即冻结、恢复无缝续播、切房/重试彻底清空。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { adaptHintSentence } from "Script/watch/fe/ui/control_prompts";
import type { WatchFrontend } from "Script/watch/fe/frontend";
import {
    G05_PIXEL_RETURN_END,
    G05_PIXEL_RETURN_START,
    GateTransitionPlugin,
    createGateTransitionPlugin,
} from "Script/watch/fe/scenes/gate_transition";
import { clamp01, smoothstep } from "Script/watch/fe/renderer/lowpoly";
import {
    PALETTE,
    RGBA,
    drawHairline,
    drawSilkVeil,
    fillRadialGlow,
    fillVGradRect,
    lerpRGBA,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

export type CuffShotKind = "P03" | "P05" | "G05";
export type CuffHandPose = "open" | "wipe" | "pinch" | "reach" | "clasp";

export interface PatchedCuffOptions {
    /** 袖口腕部中心坐标（UI 逻辑坐标系） */
    wristX: number;
    wristY: number;
    /** 手臂伸入角度（弧度，0 表示从左向右水平伸出） */
    angleRad: number;
    /** 整体缩放（1.0 约 1280×720 近景标准尺寸） */
    scale: number;
    /** 手势姿态 */
    pose: CuffHandPose;
    /** 不透明度 0..1 */
    opacity?: number;
    /** 可选补线微弱提亮（例如长按握紧时或冷月照到袖口时，0..1） */
    stitchHighlight?: number;
    /** 袖口回抽露出掌心比例（G05 握稳时略向后抽一点露掌心，0..1） */
    cuffPullBack?: number;
    /** 整体光色偏置（0 = 冷月夜，1 = 暖室灯火） */
    warmth?: number;
}

export interface CuffShotDebugState {
    activeShot: CuffShotKind | "";
    rehearsalShot: CuffShotKind | "";
    rehearsalTime: number;
    rehearsalDuration: number;
    p03Progress: number;
    p05ExitTimer: number;
    g05SleeveExtend: number;
    g05ReunionElapsed: number;
    g05LineTriggered: boolean;
    g05AbortVisualCount: number;
}

const GATE_AUDIO_ROOT = "assets/audio/gate/";
const REUNION_ART = "assets/art/gate/reunion.png";
const LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」";
const LINE_G05 = "「我们走吧。」";

/** 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%） */
export const CUFF_PALETTE = {
    indigoBase: rgba(34, 52, 74, 255),
    indigoShadow: rgba(18, 28, 42, 255),
    indigoFold: rgba(54, 78, 104, 255),
    patchDark: rgba(24, 38, 56, 255),
    hemEdge: rgba(68, 92, 118, 255),
    armWrapLinen: rgba(154, 142, 120, 255),
    armWrapShadow: rgba(102, 92, 78, 255),
    /** 标志性浅麻补线（高灰度辨识度核心记号） */
    stitchThread: rgba(232, 224, 204, 255),
    stitchPinhole: rgba(14, 19, 28, 255),
    skinBase: rgba(188, 146, 116, 255),
    skinShadow: rgba(138, 102, 78, 255),
    skinLight: rgba(216, 178, 148, 255),
    childSkin: rgba(226, 196, 170, 255),
    childSkinShadow: rgba(176, 144, 120, 255),
    childSleeve: rgba(164, 142, 114, 255),
    childCord: rgba(168, 56, 52, 255),
};

function rotPt(ox: number, oy: number, lx: number, ly: number, cosA: number, sinA: number, scale: number): Vec2.Type {
    const sx = lx * scale;
    const sy = ly * scale;
    return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA);
}

function tinted(base: RGBA, warmth: number, opacity: number): Color.Type {
    const warmTarget = rgba(
        Math.min(255, base.r + 22),
        Math.min(255, base.g + 12),
        Math.max(0, base.b - 10),
        base.a,
    );
    const mixed = lerpRGBA(base, warmTarget, clamp01(warmth));
    return toColor(mixed, Math.round(mixed.a * clamp01(opacity)));
}

/**
 * 统一「补过一道浅线的青布袖口」视觉组件：
 * P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
 */
export function drawPatchedCuff(
    draw: DrawNode.Type,
    glow: DrawNode.Type,
    opts: PatchedCuffOptions,
): void {
    const op = clamp01(opts.opacity ?? 1);
    if (op <= 0.01) {
        return;
    }
    const ox = opts.wristX;
    const oy = opts.wristY;
    const s = Math.max(0.2, opts.scale);
    const cosA = Math.cos(opts.angleRad);
    const sinA = Math.sin(opts.angleRad);
    const w = clamp01(opts.warmth ?? 0);
    const pull = clamp01(opts.cuffPullBack ?? 0) * 28;
    const pt = (lx: number, ly: number): Vec2.Type => rotPt(ox, oy, lx, ly, cosA, sinA, s);

    // 1. 前臂暗靛青粗布衣袖主体（从左 -240 延至腕边 -pull）
    const cuffFront = 6 - pull;
    draw.drawPolygon([
        pt(-250, -48),
        pt(cuffFront, -36),
        pt(cuffFront, 38),
        pt(-250, 52),
    ], tinted(CUFF_PALETTE.indigoBase, w, op), 1.4, tinted(CUFF_PALETTE.indigoShadow, w, op));

    // 衣袖下半阴影褶皱（形成粗布立体筒感）
    draw.drawPolygon([
        pt(-250, -48),
        pt(cuffFront, -36),
        pt(cuffFront, -8),
        pt(-250, -14),
    ], tinted(CUFF_PALETTE.indigoShadow, w, op * 0.88));

    // 衣袖受光上褶与粗布经纬线
    draw.drawPolygon([
        pt(-230, 14),
        pt(cuffFront - 6, 10),
        pt(cuffFront - 4, 32),
        pt(-230, 40),
    ], tinted(CUFF_PALETTE.indigoFold, w, op * 0.52));
    draw.drawSegment(pt(-185, 16), pt(cuffFront - 18, 12), 1.2 * s, tinted(CUFF_PALETTE.hemEdge, w, op * 0.55));
    draw.drawSegment(pt(-160, -10), pt(cuffFront - 26, -6), 1.1 * s, tinted(CUFF_PALETTE.indigoShadow, w, op * 0.75));

    // 2. 腕内护臂旧麻布（明初普通守卒标志，绝非金属护腕）
    draw.drawPolygon([
        pt(cuffFront - 8, -28),
        pt(cuffFront + 16, -24),
        pt(cuffFront + 16, 26),
        pt(cuffFront - 8, 28),
    ], tinted(CUFF_PALETTE.armWrapLinen, w, op), 1.0, tinted(CUFF_PALETTE.armWrapShadow, w, op));
    draw.drawSegment(pt(cuffFront + 3, -25), pt(cuffFront + 7, 25), 1.3 * s, tinted(CUFF_PALETTE.armWrapShadow, w, op * 0.72));

    // 3. 卷边袖口厚布边
    draw.drawPolygon([
        pt(cuffFront - 16, -37),
        pt(cuffFront + 2, -36),
        pt(cuffFront + 2, 38),
        pt(cuffFront - 16, 39),
    ], tinted(CUFF_PALETTE.indigoBase, w, op), 1.3, tinted(CUFF_PALETTE.hemEdge, w, op * 0.85));

    // 4. 核心辨识记号：外腕深青小补丁 + 一道斜向浅麻补线（6 针整齐细缝，四镜完全同构）
    const pX0 = cuffFront - 72;
    const pX1 = cuffFront - 18;
    const pY0 = -16;
    const pY1 = 22;
    draw.drawPolygon([
        pt(pX0, pY0),
        pt(pX1, pY0 + 3),
        pt(pX1 - 2, pY1),
        pt(pX0 + 3, pY1 - 2),
    ], tinted(CUFF_PALETTE.patchDark, w, op), 1.1, tinted(CUFF_PALETTE.indigoShadow, w, op));

    // 标志性斜补缝主裂纹与 6 针浅麻交叉缝线
    const seamStartX = pX0 + 6;
    const seamStartY = pY0 + 5;
    const seamEndX = pX1 - 7;
    const seamEndY = pY1 - 5;
    draw.drawSegment(
        pt(seamStartX, seamStartY),
        pt(seamEndX, seamEndY),
        1.5 * s,
        tinted(CUFF_PALETTE.stitchPinhole, w, op * 0.92),
    );

    const hl = clamp01(opts.stitchHighlight ?? 0.25);
    const stitchCol = tinted(CUFF_PALETTE.stitchThread, w * 0.4, op);
    const pinCol = tinted(CUFF_PALETTE.stitchPinhole, w, op * 0.92);
    const stitches = 6;
    let k = 0;
    for (k = 0; k < stitches; k++) {
        const t = (k + 0.5) / stitches;
        const mx = seamStartX + (seamEndX - seamStartX) * t;
        const my = seamStartY + (seamEndY - seamStartY) * t;
        const nx = -4.8;
        const ny = 6.2;
        const a = pt(mx - nx, my - ny);
        const b = pt(mx + nx, my + ny);
        draw.drawDot(a, 1.3 * s, pinCol);
        draw.drawDot(b, 1.3 * s, pinCol);
        draw.drawSegment(a, b, 2.0 * s, stitchCol);
        if (hl > 0.05) {
            glow.drawSegment(a, b, 2.4 * s, toColor(CUFF_PALETTE.stitchThread, Math.round(74 * hl * op)));
        }
    }

    // 5. 周戍手掌与手指（按姿态变化）
    const handBase = cuffFront + 14;
    const skinCol = tinted(CUFF_PALETTE.skinBase, w, op);
    const skinSh = tinted(CUFF_PALETTE.skinShadow, w, op);
    const skinHi = tinted(CUFF_PALETTE.skinLight, w, op * 0.85);

    if (opts.pose === "wipe") {
        // 揩去碎瓷：微微弓腕、袖侧外沿带动手背平扫
        draw.drawPolygon([
            pt(handBase - 4, -20),
            pt(handBase + 46, -24),
            pt(handBase + 54, 4),
            pt(handBase + 38, 22),
            pt(handBase - 4, 20),
        ], skinCol, 1.1, skinSh);
        draw.drawSegment(pt(handBase + 16, -2), pt(handBase + 52, -6), 1.4 * s, skinSh);
        draw.drawSegment(pt(handBase + 14, 10), pt(handBase + 46, 8), 1.4 * s, skinSh);
    } else if (opts.pose === "pinch") {
        // 隔布轻捏小满的手：拇指与食指温和收拢
        draw.drawPolygon([
            pt(handBase - 4, -22),
            pt(handBase + 44, -18),
            pt(handBase + 54, 6),
            pt(handBase + 28, 26),
            pt(handBase - 4, 22),
        ], skinCol, 1.1, skinSh);
        draw.drawSegment(pt(handBase + 24, 16), pt(handBase + 52, 4), 6.2 * s, skinHi);
        draw.drawSegment(pt(handBase + 30, -14), pt(handBase + 54, -4), 5.6 * s, skinCol);
    } else if (opts.pose === "clasp") {
        // 握稳掌心：五指舒展略扣，掌心温暖迎合
        draw.drawPolygon([
            pt(handBase - 2, -22),
            pt(handBase + 52, -20),
            pt(handBase + 66, 2),
            pt(handBase + 44, 26),
            pt(handBase - 2, 22),
        ], skinCol, 1.2, skinSh);
        draw.drawSegment(pt(handBase + 26, 20), pt(handBase + 58, 12), 6.5 * s, skinHi);
        draw.drawSegment(pt(handBase + 46, -14), pt(handBase + 72, -10), 5.2 * s, skinCol);
        draw.drawSegment(pt(handBase + 48, -2), pt(handBase + 76, 1), 5.4 * s, skinCol);
    } else {
        // open / reach：掌心微摊，温和递向小满
        const reachExt = opts.pose === "reach" ? 10 : 0;
        draw.drawPolygon([
            pt(handBase - 4, -20),
            pt(handBase + 44 + reachExt, -18),
            pt(handBase + 56 + reachExt, 4),
            pt(handBase + 34 + reachExt * 0.5, 24),
            pt(handBase - 4, 20),
        ], skinCol, 1.1, skinSh);
        // 舒展四指与微张拇指
        draw.drawSegment(pt(handBase + 42 + reachExt, -14), pt(handBase + 74 + reachExt, -16), 4.6 * s, skinCol);
        draw.drawSegment(pt(handBase + 46 + reachExt, -4), pt(handBase + 80 + reachExt, -3), 4.8 * s, skinCol);
        draw.drawSegment(pt(handBase + 44 + reachExt, 6), pt(handBase + 76 + reachExt, 9), 4.6 * s, skinCol);
        draw.drawSegment(pt(handBase + 26 + reachExt * 0.5, 18), pt(handBase + 56 + reachExt * 0.6, 28), 5.2 * s, skinHi);
    }
}

/** 绘制小满伸出的小手（含腕上暗红指南针布套短绳） */
function drawChildHand(
    draw: DrawNode.Type,
    ox: number,
    oy: number,
    angleRad: number,
    scale: number,
    pose: "two_fingers" | "open_fingers" | "clutch" | "reach_up" | "clasp",
    opacity: number,
    withCompassCord: boolean = true,
): void {
    const op = clamp01(opacity);
    if (op <= 0.01) {
        return;
    }
    const cosA = Math.cos(angleRad);
    const sinA = Math.sin(angleRad);
    const s = Math.max(0.2, scale);
    const pt = (lx: number, ly: number): Vec2.Type => rotPt(ox, oy, lx, ly, cosA, sinA, s);
    const skin = toColor(CUFF_PALETTE.childSkin, Math.round(255 * op));
    const sh = toColor(CUFF_PALETTE.childSkinShadow, Math.round(255 * op));
    const sleeve = toColor(CUFF_PALETTE.childSleeve, Math.round(255 * op));

    if (pose === "two_fingers") {
        // P03 柜缝先试探伸出的两根细小手指
        draw.drawSegment(pt(-18, -4), pt(18, -5), 5.0 * s, skin);
        draw.drawSegment(pt(-16, 6), pt(22, 7), 5.0 * s, skin);
        draw.drawDot(pt(18, -5), 2.5 * s, sh);
        draw.drawDot(pt(22, 7), 2.5 * s, sh);
        return;
    }

    // 小满细手腕与粗布短袄袖口
    draw.drawPolygon([
        pt(-135, -24),
        pt(-6, -18),
        pt(-6, 18),
        pt(-135, 26),
    ], sleeve, 1.1, sh);

    if (withCompassCord) {
        // 绕腕短红绳（指南针布套系绳）
        draw.drawSegment(pt(-10, -18), pt(-4, 18), 2.6 * s, toColor(CUFF_PALETTE.childCord, Math.round(235 * op)));
        draw.drawSegment(pt(-4, -18), pt(2, 18), 2.2 * s, toColor(CUFF_PALETTE.childCord, Math.round(200 * op)));
    }

    // 幼童小手掌
    draw.drawPolygon([
        pt(-4, -15),
        pt(28, -14),
        pt(34, 2),
        pt(22, 17),
        pt(-4, 15),
    ], skin, 1.0, sh);

    if (pose === "clutch" || pose === "clasp") {
        // 攥紧布料 / 握稳哥哥手掌
        draw.drawSegment(pt(24, -11), pt(44, -6), 4.0 * s, skin);
        draw.drawSegment(pt(26, -2), pt(47, 2), 4.2 * s, skin);
        draw.drawSegment(pt(24, 6), pt(43, 9), 4.0 * s, skin);
        draw.drawSegment(pt(16, 14), pt(34, 16), 4.2 * s, skin);
    } else {
        // open_fingers / reach_up：张开手指姿态（P05 结尾无缝衔接 G01 首帧 / G05 抬手迎袖）
        draw.drawSegment(pt(26, -12), pt(52, -16), 3.6 * s, skin);
        draw.drawSegment(pt(29, -4), pt(57, -5), 3.8 * s, skin);
        draw.drawSegment(pt(28, 4), pt(54, 7), 3.6 * s, skin);
        draw.drawSegment(pt(24, 11), pt(46, 17), 3.4 * s, skin);
        draw.drawSegment(pt(14, 15), pt(34, 26), 4.0 * s, skin);
    }
}

/** 仅在 G05 重逢抬镜后绘制序章像素风风格的蹲姿周戍近景（复用真实像素立绘，与本体画风 100% 统一） */
function drawZhouShuReunionPortrait(
    draw: DrawNode.Type,
    inkDraw: DrawNode.Type,
    art: AssetSlotHost,
    glow: DrawNode.Type,
    cx: number,
    cy: number,
    scale: number,
    alpha: number,
): void {
    const a = clamp01(alpha);
    if (a <= 0.01) {
        return;
    }
    const s = scale;
    const cardW = 212 * s;
    const cardH = 248 * s;
    const x0 = cx - cardW * 0.5;
    const y0 = cy - cardH * 0.5;

    // 柔和烟黛夜色底框（与序章像素城门冷月夜景统一）
    fillVGradRect(
        draw,
        x0,
        y0,
        cardW,
        cardH,
        Color(10, 15, 24, Math.round(224 * a)),
        Color(22, 34, 52, Math.round(234 * a)),
    );
    // 真实像素周戍伸手相迎姿态（明初铁盔、青布衣、无现代装备，与场景精灵完全一致）
    const placed = art.tryPlace(
        "soldier_offer",
        "g05_zhoushu_closeup",
        cx + 4 * s,
        y0 + 18 * s,
        156 * s,
        214 * s,
        { opacity: a, layer: 4 },
    );
    if (!placed) {
        art.tryPlace(
            "soldier_idle",
            "g05_zhoushu_closeup",
            cx,
            y0 + 18 * s,
            156 * s,
            214 * s,
            { opacity: a, layer: 4 },
        );
    }
    // 素雅细银丝边与克制冷月轮廓晕
    inkDraw.drawRect(Rect(x0, y0, cardW, cardH), Color(0, 0, 0, 0), 1.1, toColor(PALETTE.silkDim, Math.round(165 * a)));
    inkDraw.drawRect(Rect(x0 + 4, y0 + 4, cardW - 8, cardH - 8), Color(0, 0, 0, 0), 0.7, toColor(PALETTE.amber, Math.round(78 * a)));
    fillRadialGlow(glow, cx + 12 * s, cy + 22 * s, 96 * s, 96 * s, Color(214, 224, 236, Math.round(38 * a)), Color(120, 148, 178, 0), 16);
}

function drawReunionArt(
    draw: DrawNode.Type, art: AssetSlotHost,
    w: number, h: number, tilt: number, alpha: number,
): boolean {
    if (alpha <= 0.01) {
        return false;
    }
    // 构图以握住的手为中心。抬镜时手向画面下方滑，眼神渐成为焦点。
    const height = h * (0.92 - 0.19 * tilt);
    const handY = h * (0.437 - 0.095 * tilt);
    const placed = art.tryPlacePath(
        REUNION_ART, "g05_reunion_two_shot", w * 0.505, handY, height * 1.16, height,
        { anchorX: 0.66, anchorY: 0.51, opacity: alpha, layer: 3, smooth: true },
    );
    if (placed) {
        fillVGradRect(draw, 0, 0, w, h,
            Color(7, 11, 18, Math.round(218 * alpha)),
            Color(9, 16, 27, Math.round(142 * alpha)),
        );
    }
    return placed;
}

export class CuffShotsPlugin implements FeRenderPlugin {
    readonly id = "fe-01-cuff-shots";

    private animTime = 0;
    private prevPhase = "";
    private activeShot: CuffShotKind | "" = "";

    // 显式排演播放态（可单独播放 3s P03 / 4s P05 / 4s G05 供三镜对比图与样片录制）
    private rehearsalShot: CuffShotKind | "" = "";
    private rehearsalTime = 0;
    private rehearsalDuration = 3.0;
    private rehearsalAutoAdvance = true;

    // Live 过渡态
    private p03Progress = 0;
    private p05ExitTimer = -1;
    private g05SleeveExtend = 0;
    private g05ReunionElapsed = 0;
    private g05LineTriggered = false;
    private g05AbortVisualCount = 0;
    private lastReleasedAbortCount = 0;

    onBindPlay(p: Play, _view: DualRouteSnapshot): void {
        this.animTime = 0;
        this.prevPhase = p.phase;
        this.activeShot = "";
        this.p03Progress = 0;
        this.p05ExitTimer = -1;
        this.g05SleeveExtend = 0;
        this.g05ReunionElapsed = 0;
        this.g05LineTriggered = false;
        this.g05AbortVisualCount = 0;
        this.lastReleasedAbortCount = 0;
    }

    /**
     * 显式启动/定格单镜排演（用于产出 P03 / P05 / G05 三镜同袖对比图与独立带声样片）：
     * - 传入 fixedTime 时定格在该秒，不自动推进；
     * - 不传 fixedTime 时从 0s 随 worldDt 正常播放（暂停自动冻结）。
     */
    rehearseShot(shot: CuffShotKind | "", fixedTime?: number): void {
        this.rehearsalShot = shot;
        if (shot === "") {
            this.rehearsalTime = 0;
            this.rehearsalAutoAdvance = true;
            return;
        }
        this.rehearsalDuration = shot === "P03" ? 3.0 : 4.0;
        if (fixedTime !== undefined) {
            this.rehearsalTime = Math.max(0, Math.min(this.rehearsalDuration, fixedTime));
            this.rehearsalAutoAdvance = false;
        } else {
            this.rehearsalTime = 0;
            this.rehearsalAutoAdvance = true;
        }
    }

    stopRehearsalShot(): void {
        this.rehearseShot("");
    }

    getDebugState(): CuffShotDebugState {
        return {
            activeShot: this.activeShot,
            rehearsalShot: this.rehearsalShot,
            rehearsalTime: this.rehearsalTime,
            rehearsalDuration: this.rehearsalDuration,
            p03Progress: this.p03Progress,
            p05ExitTimer: this.p05ExitTimer,
            g05SleeveExtend: this.g05SleeveExtend,
            g05ReunionElapsed: this.g05ReunionElapsed,
            g05LineTriggered: this.g05LineTriggered,
            g05AbortVisualCount: this.g05AbortVisualCount,
        };
    }

    update(ctx: FePluginContext): void {
        const p = ctx.p;
        const view = ctx.view;
        const dt = ctx.paused ? 0 : ctx.worldDt;
        this.animTime += dt;

        // 1. 若处于显式单镜排演，推进排演时钟并触发对应一次性音效
        if (this.rehearsalShot !== "") {
            this.activeShot = this.rehearsalShot;
            if (this.rehearsalAutoAdvance && dt > 0) {
                this.rehearsalTime = Math.min(this.rehearsalDuration, this.rehearsalTime + dt);
            }
            if (!ctx.paused) {
                this.triggerRehearsalAudio(ctx);
            }
            this.prevPhase = p.phase;
            return;
        }

        this.activeShot = "";

        // 2. P03 柜边相认（正式模式：prologue-give 60 拍或未来独立长拍均自适应归一化）
        if (p.room.key === "prologue" && p.phase === "prologue-give") {
            this.activeShot = "P03";
            this.p03Progress = clamp01(p.phaseTick / 60);
            if (!ctx.paused && this.p03Progress >= 0.25) {
                ctx.audio.playOnce(
                    "cuff:p03:wipe:" + ctx.events.roomSessionId,
                    "sfx",
                    GATE_AUDIO_ROOT + "cloth_wipe_wood.wav",
                    0.86,
                    "cuff:p03:cloth_wipe_wood",
                    p.ticks,
                );
            }
            if (!ctx.paused && this.p03Progress >= 0.62) {
                ctx.audio.playOnce(
                    "cuff:p03:compass:" + ctx.events.roomSessionId,
                    "sfx",
                    "assets/audio/interact/compass_handover.wav",
                    0.82,
                    "cuff:p03:compass_handover",
                    p.ticks,
                );
            }
            this.prevPhase = p.phase;
            return;
        } else {
            this.p03Progress = 0;
        }

        // 3. P05 城门送别：gate-send 近门预期 → gate-send 切换至 gate-count 瞬间触发 0.8s 袖口退出衔接 G01
        if (p.room.key === "gate") {
            if (this.prevPhase === "gate-send" && p.phase === "gate-count" && view.countElapsedTicks <= 8) {
                this.p05ExitTimer = 0;
                if (!ctx.paused) {
                    ctx.audio.playOnce(
                        "cuff:p05:slam:" + ctx.events.roomSessionId,
                        "sfx",
                        GATE_AUDIO_ROOT + "gate_slam.wav",
                        0.92,
                        "cuff:p05:gate_slam",
                        p.ticks,
                    );
                    ctx.audio.playOnce(
                        "cuff:p05:line:" + ctx.events.roomSessionId,
                        "voice",
                        GATE_AUDIO_ROOT + "line_farewell.wav",
                        0.88,
                        "cuff:p05:line_farewell",
                        p.ticks,
                    );
                }
            }
            if (this.p05ExitTimer >= 0) {
                if (p.phase !== "gate-count" || view.countElapsedTicks > 240) {
                    this.p05ExitTimer = -1;
                } else {
                    if (dt > 0) {
                        this.p05ExitTimer += dt;
                    }
                    if (this.p05ExitTimer >= 3.6) {
                        this.p05ExitTimer = -1;
                    } else {
                        this.activeShot = "P05";
                    }
                }
            }
        } else {
            this.p05ExitTimer = -1;
        }

        // 4. G05 男主线风台重逢（同时兼容 story-b1-carry 的 gate-wait/gate-hand 与 contract.ts 排演态）
        const inGateReunion = p.room.key === "gate"
            && (p.phase === "gate-wait"
                || p.phase === "gate-hand"
                || (p.phase === "gate-count"
                    && view.storyRoute === "soldier"
                    && (view.gateReunion.active || view.gateReunion.completed)));

        if (inGateReunion) {
            this.activeShot = "G05";
            const gr = view.gateReunion;
            const completed = p.phase === "gate-hand" || gr.completed;

            if (gr.releasedAbortCount > this.lastReleasedAbortCount) {
                this.g05AbortVisualCount += (gr.releasedAbortCount - this.lastReleasedAbortCount);
                this.lastReleasedAbortCount = gr.releasedAbortCount;
                if (!ctx.paused && view.isRehearsal) {
                    ctx.audio.playOnce(
                        "cuff:g05:release:" + ctx.events.roomSessionId + ":" + gr.releasedAbortCount,
                        "sfx",
                        GATE_AUDIO_ROOT + "reunion_release.wav",
                        0.72,
                        "cuff:g05:reunion_release",
                        p.ticks,
                    );
                }
            }

            if (completed) {
                this.g05SleeveExtend = 1;
                if (dt > 0) {
                    this.g05ReunionElapsed += dt;
                }
                if (!ctx.paused && !this.g05LineTriggered) {
                    if (view.isRehearsal) {
                        ctx.audio.playOnce(
                            "cuff:g05:clasp:" + ctx.events.roomSessionId,
                            "sfx",
                            GATE_AUDIO_ROOT + "reunion_hold.wav",
                            0.88,
                            "cuff:g05:hand_held",
                            p.ticks,
                        );
                    }
                    if (this.g05ReunionElapsed >= 0.80 || (p.phase === "gate-hand" && p.phaseTick >= 42)) {
                        this.g05LineTriggered = true;
                        ctx.audio.playOnce(
                            "cuff:g05:line:" + ctx.events.roomSessionId,
                            "voice",
                            GATE_AUDIO_ROOT + "line_reunion.wav",
                            0.94,
                            "cuff:g05:line_reunion",
                            p.ticks,
                        );
                    }
                }
            } else {
                this.g05ReunionElapsed = 0;
                this.g05LineTriggered = false;
                if (gr.holding || gr.holdProgress > 0.001) {
                    // 长按时袖口紧跟 holdProgress 伸入画面（若上次松手退回尚未归零，顺滑贴齐不突跳）
                    if (gr.holdProgress >= this.g05SleeveExtend) {
                        this.g05SleeveExtend = gr.holdProgress;
                    } else if (dt > 0) {
                        this.g05SleeveExtend = Math.max(gr.holdProgress, this.g05SleeveExtend - dt * 4.0);
                    }
                } else if (dt > 0 && this.g05SleeveExtend > 0) {
                    // 中途松手：袖口平滑退回画边（暂停冻结），随时可再按重试
                    this.g05SleeveExtend = Math.max(0, this.g05SleeveExtend - dt * 2.8);
                }
            }
        } else {
            this.g05SleeveExtend = 0;
            this.g05ReunionElapsed = 0;
            this.g05LineTriggered = false;
            this.lastReleasedAbortCount = view.gateReunion.releasedAbortCount;
        }

        this.prevPhase = p.phase;
    }

    private triggerRehearsalAudio(ctx: FePluginContext): void {
        const sid = ctx.events.roomSessionId;
        const t = this.rehearsalTime;
        if (this.rehearsalShot === "P03" && t >= 0.85) {
            ctx.audio.playOnce("reh:p03:wipe:" + sid, "sfx", GATE_AUDIO_ROOT + "cloth_wipe_wood.wav", 0.88, "cuff:p03:cloth_wipe_wood", ctx.p.ticks);
        } else if (this.rehearsalShot === "P05") {
            if (t >= 0.9) {
                ctx.audio.playOnce("reh:p05:line:" + sid, "voice", GATE_AUDIO_ROOT + "line_farewell.wav", 0.90, "cuff:p05:line_farewell", ctx.p.ticks);
            }
            if (t >= 2.75) {
                ctx.audio.playOnce("reh:p05:slam:" + sid, "sfx", GATE_AUDIO_ROOT + "gate_slam.wav", 0.94, "cuff:p05:gate_slam", ctx.p.ticks);
                ctx.audio.playLoop("reh_p05_water", "water", GATE_AUDIO_ROOT + "water_moat_loop.wav", 0.42, ctx.p.ticks);
            }
        } else if (this.rehearsalShot === "G05") {
            if (t >= 0.05) {
                ctx.audio.playOnce("reh:g05:knock1:" + sid, "sfx", GATE_AUDIO_ROOT + "knock_wall.wav", 0.88, "knock:gate:1", ctx.p.ticks);
            }
            if (t >= 0.25) {
                ctx.audio.playOnce("reh:g05:knock2:" + sid, "sfx", GATE_AUDIO_ROOT + "knock_wall.wav", 0.92, "knock:gate:2", ctx.p.ticks);
            }
            if (t >= 1.55) {
                ctx.audio.playOnce("reh:g05:clasp:" + sid, "sfx", GATE_AUDIO_ROOT + "reunion_hold.wav", 0.88, "cuff:g05:hand_held", ctx.p.ticks);
            }
            if (t >= 2.35) {
                ctx.audio.playOnce("reh:g05:line:" + sid, "voice", GATE_AUDIO_ROOT + "line_reunion.wav", 0.94, "cuff:g05:line_reunion", ctx.p.ticks);
            }
        }
    }

    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (this.activeShot === "") {
            return false;
        }
        const w = ctx.uiW;
        const h = ctx.uiH;

        if (this.activeShot === "P03") {
            const prog = this.rehearsalShot === "P03"
                ? clamp01(this.rehearsalTime / this.rehearsalDuration)
                : this.p03Progress;
            this.renderP03Shot(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog);
            return true;
        }

        if (this.activeShot === "P05") {
            if (this.rehearsalShot === "P05") {
                const prog = clamp01(this.rehearsalTime / this.rehearsalDuration);
                this.renderP05FullShot(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog);
                return true;
            }
            // Live gate-send→gate-count 首 3.6s 送别衔接：补线袖口隔布轻捏 + 定稿嘱咐台词 + 随落门抽离接 G01
            this.renderP05ExitBridge(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, clamp01(this.p05ExitTimer / 3.6));
            return false;
        }

        if (this.activeShot === "G05") {
            if (this.rehearsalShot === "G05") {
                this.renderG05RehearsalShot(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, this.rehearsalTime);
                return true;
            }
            this.renderG05LiveShot(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h);
            return true;
        }

        return false;
    }

    /**
     * P03 柜边相认（3s 完整节奏 / 60 拍自适应）：
     * - 0.00..0.28：柜缝先伸出小满两指；
     * - 0.28..0.68：周戍补线青布袖口扫过柜沿、揩走碎瓷片（配 cloth_wipe_wood 声）；
     * - 0.68..1.00：袖口舒展递手入柜，小满伸手相迎。
     */
    private renderP03Shot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        prog: number,
    ): void {
        const fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1.0, prog));
        // 特写横幅卡片（留出底部与顶部电影黑边，清晰聚焦柜沿与袖口）
        const boxW = Math.min(w - 140, 820);
        const boxH = Math.min(h - 190, 390);
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5 + 14;

        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 14, Math.round(135 * fade)));
        // 厨柜深暗内景与厚木柜沿
        fillVGradRect(uiDraw, bx, by, boxW, boxH, Color(14, 13, 16, Math.round(248 * fade)), Color(24, 24, 30, Math.round(248 * fade)));
        // 柜板木沿（左侧深缝，右侧倒柜木沿）
        const rimY = by + boxH * 0.34;
        uiDraw.drawRect(Rect(bx, by, boxW, rimY - by), Color(54, 40, 30, Math.round(252 * fade)));
        uiDraw.drawSegment(Vec2(bx, rimY), Vec2(bx + boxW, rimY), 2.2, Color(128, 100, 76, Math.round(220 * fade)));
        // 右侧竖向厨柜门缝阴影（小满藏身处）
        const crackX = bx + boxW * 0.72;
        uiDraw.drawRect(Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), Color(8, 9, 13, Math.round(245 * fade)));
        uiDraw.drawRect(Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), Color(46, 35, 26, Math.round(250 * fade)));

        // 1. 柜沿碎瓷片（在 0.32..0.66 被补线袖口拂落移出柜沿）
        const wipeT = smoothstep(0.30, 0.66, prog);
        const shardOffsets = [
            { x: -72, y: 8, dx: 46, dy: -38, r: 9 },
            { x: -34, y: 12, dx: 64, dy: -46, r: 7 },
            { x: 4, y: 6, dx: 82, dy: -52, r: 10 },
            { x: 32, y: 10, dx: 74, dy: -34, r: 6 },
        ];
        const shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog));
        if (shardAlpha > 0.02) {
            let si = 0;
            for (si = 0; si < shardOffsets.length; si++) {
                const sh = shardOffsets[si];
                const sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT;
                const sy = rimY + sh.y + sh.dy * wipeT * wipeT;
                uiDraw.drawPolygon([
                    Vec2(sx - sh.r, sy - sh.r * 0.4),
                    Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6),
                    Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8),
                ], Color(212, 218, 224, Math.round(235 * shardAlpha)), 0.9, Color(92, 108, 126, Math.round(200 * shardAlpha)));
            }
        }

        // 2. 柜缝露出的小满两指 → 最终递出整只小手
        const fingerEnter = smoothstep(0.04, 0.24, prog);
        const handOut = smoothstep(0.70, 0.90, prog);
        if (handOut > 0.05) {
            drawChildHand(
                uiDraw,
                crackX + 18 - handOut * 66,
                rimY + 52,
                Math.PI,
                1.05,
                "open_fingers",
                fade * handOut,
                false,
            );
        } else if (fingerEnter > 0.02) {
            drawChildHand(
                uiDraw,
                crackX + 12 - fingerEnter * 24,
                rimY + 46,
                Math.PI,
                1.08,
                "two_fingers",
                fade * fingerEnter,
                false,
            );
        }

        // 3. 周戍补线青布袖口（先平扫揩去碎瓷，再舒展递手入柜）
        const sleeveEnter = smoothstep(0.22, 0.36, prog);
        if (sleeveEnter > 0.01) {
            const reachT = smoothstep(0.66, 0.88, prog);
            const wx = bx + 110 + sleeveEnter * 195 + Math.sin(wipeT * Math.PI) * 78 + reachT * 82;
            const wy = rimY + 46 - Math.sin(wipeT * Math.PI) * 26 + reachT * 12;
            const ang = -0.14 * Math.sin(wipeT * Math.PI) + 0.04 * reachT;
            const pose: CuffHandPose = reachT > 0.2 ? "reach" : "wipe";
            drawPatchedCuff(uiDraw, uiGlow, {
                wristX: wx,
                wristY: wy,
                angleRad: ang,
                scale: 1.06,
                pose,
                opacity: fade * sleeveEnter,
                stitchHighlight: 0.35 + 0.35 * Math.sin(wipeT * Math.PI),
                warmth: 0.18,
            });
        }

        // 素雅边框与轻字幕
        uiInkDraw.drawRect(Rect(bx, by, boxW, boxH), Color(0, 0, 0, 0), 1.0, toColor(PALETTE.silkDim, Math.round(145 * fade)));
        drawSilkVeil(uiDraw, uiArt, "p03_sub_veil", w * 0.5, 42, 520, 42, PALETTE.inkWash, 0.82 * fade, -1);
        const subText = prog < 0.68
            ? "青布袖口掠过柜沿，轻轻拂开了碎瓷。"
            : "「是我，别怕。……这个沉，替我揣怀里。」";
        ctx.texts.put("sm", subText, w * 0.5, 42, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.0, fade, 0.08);
    }

    /**
     * P05 城门送别（4s 完整排演版）：
     * - 0.00..0.28：小满双手扯紧补线袖口；
     * - 0.28..0.70：周戍隔布轻捏她的手 + 定稿台词；
     * - 0.70..1.00：重门合拢，补线袖口从左退出画面，留小满张开手指姿态无缝接 G01 首帧。
     */
    private renderP05FullShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        prog: number,
    ): void {
        const fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1.0, prog));
        const boxW = Math.min(w - 120, 860);
        const boxH = Math.min(h - 180, 400);
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5 + 14;

        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 14, Math.round(145 * fade)));
        // 门柱后方望出去的护城河冷月水光
        fillVGradRect(uiDraw, bx, by, boxW, boxH, Color(14, 22, 34, Math.round(248 * fade)), Color(28, 42, 58, Math.round(248 * fade)));
        // 门底护城河水面冷光
        fillRadialGlow(uiGlow, bx + boxW * 0.66, by + boxH * 0.32, 220, 68, Color(152, 194, 224, Math.round(74 * fade)), Color(40, 70, 108, 0), 16);

        const releaseT = smoothstep(0.68, 0.94, prog);
        const pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT);

        // 周戍补线袖口（位于门内左侧，最后随落门抽离画边）
        const cuffX = bx + boxW * 0.42 - releaseT * 260;
        const cuffY = by + boxH * 0.52;
        drawPatchedCuff(uiDraw, uiGlow, {
            wristX: cuffX,
            wristY: cuffY,
            angleRad: -0.06,
            scale: 1.12,
            pose: pinchT > 0.25 ? "pinch" : "open",
            opacity: fade * (1 - releaseT * 0.88),
            stitchHighlight: 0.45 + 0.30 * pinchT,
            warmth: 0.12,
        });

        // 小满小手（先攥紧补袖，落门抽袖后停在张开手指姿态，无缝衔接 G01 首帧）
        const childHandX = bx + boxW * 0.54 + releaseT * 36;
        const childHandY = by + boxH * 0.46 - releaseT * 12;
        drawChildHand(
            uiDraw,
            childHandX,
            childHandY,
            Math.PI + 0.12,
            1.12,
            releaseT > 0.35 ? "open_fingers" : "clutch",
            fade,
            true,
        );

        // 重门自上而下缓缓合拢（0.68..0.95 落门声盖过兵声）
        if (releaseT > 0.01) {
            const dropH = boxH * releaseT * 0.88;
            uiDraw.drawRect(Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), Color(26, 22, 20, Math.round(238 * fade)));
            uiDraw.drawSegment(Vec2(bx, by + boxH - dropH), Vec2(bx + boxW * 0.46, by + boxH - dropH), 2.4, Color(118, 104, 88, Math.round(220 * fade)));
        }

        uiInkDraw.drawRect(Rect(bx, by, boxW, boxH), Color(0, 0, 0, 0), 1.0, toColor(PALETTE.silkDim, Math.round(150 * fade)));

        // 定稿台词
        const lineAlpha = fade * smoothstep(0.18, 0.30, prog) * (1 - smoothstep(0.86, 0.98, prog));
        if (lineAlpha > 0.02) {
            drawSilkVeil(uiDraw, uiArt, "p05_sub_veil", w * 0.5, 42, 740, 44, PALETTE.inkWash, 0.86 * lineAlpha, -1);
            drawHairline(uiInkDraw, uiArt, "p05_sub_line", w * 0.5, 62, 520, PALETTE.silkDim, 0.52 * lineAlpha, true, 2);
            ctx.texts.put("sm", LINE_P05, w * 0.5, 42, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.8, lineAlpha, 0.08);
        }
    }

    /** Live 模式 gate-send → gate-count 首 3.6s 送别衔接：补线袖口轻捏、定稿嘱咐台词与落门抽袖接 G01 */
    private renderP05ExitBridge(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        t: number,
    ): void {
        const enter = smoothstep(0, 0.12, t);
        const out = smoothstep(0.66, 1.0, t);
        const alpha = enter * (1 - out);
        if (alpha <= 0.02) {
            return;
        }
        const pinchT = smoothstep(0.14, 0.34, t) * (1 - out);
        drawPatchedCuff(uiDraw, uiGlow, {
            wristX: w * 0.25 - out * 240,
            wristY: h * 0.40,
            angleRad: -0.05,
            scale: 0.94,
            pose: pinchT > 0.25 ? "pinch" : "open",
            opacity: alpha * 0.94,
            stitchHighlight: 0.45 + 0.28 * pinchT,
        });
        drawChildHand(
            uiDraw,
            w * 0.35 + out * 26,
            h * 0.37 - out * 10,
            Math.PI + 0.10,
            0.94,
            out > 0.32 ? "open_fingers" : "clutch",
            alpha * 0.92,
            true,
        );
        const lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t));
        if (lineAlpha > 0.02) {
            const subY = 92;
            drawSilkVeil(uiDraw, uiArt, "p05_live_veil", w * 0.5, subY, 760, 44, PALETTE.inkWash, 0.86 * lineAlpha, -1);
            drawHairline(uiInkDraw, uiArt, "p05_live_line", w * 0.5, subY + 20, 520, PALETTE.silkDim, 0.52 * lineAlpha, true, 2);
            ctx.texts.put("sm", LINE_P05, w * 0.5, subY, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.8, lineAlpha, 0.08);
        }
    }

    /**
     * G05 男主线风台重逢（正式与排演互动共用）：
     * - 未完成（!completed）：袖口严格随 g05SleeveExtend 从左侧伸入画面，松手平滑退回画边可重试；
     * - 满 0.6s（completed）：握稳掌心 → 顺相握手臂抬镜 → 背景由 gate_transition.ts 同步切回序章像素风 →
     *   露蹲姿周戍，单次浮现「我们走吧。」（核心流程在 1.5s 内完整收口，兼容 story-b1-carry 90 拍切房）。
     */
    private renderG05LiveShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
    ): void {
        const view = ctx.view;
        const gr = view.gateReunion;
        const completed = ctx.p.phase === "gate-hand" || gr.completed;
        const ext = smoothstep(0, 1, this.g05SleeveExtend);

        if (!completed) {
            // 等待 / 长按阶段：风台安静安全；随按住交互，补线袖口从左画边探出迎向小满抬起的手
            if (ext > 0.008) {
                // 柔和暗色烟黛托带，将前景双手与背景风台清晰剥离
                const veilA = Math.round(138 * clamp01(ext * 1.15));
                fillVGradRect(uiDraw, 0, h * 0.28, w, h * 0.16, Color(8, 11, 18, 0), Color(8, 11, 18, veilA));
                fillVGradRect(uiDraw, 0, h * 0.44, w, h * 0.16, Color(8, 11, 18, veilA), Color(8, 11, 18, 0));

                const cuffX = -46 + ext * (w * 0.42 + 46);
                const cuffY = h * 0.44 + Math.sin(this.animTime * 2.2) * 2;
                drawPatchedCuff(uiDraw, uiGlow, {
                    wristX: cuffX,
                    wristY: cuffY,
                    angleRad: -0.05,
                    scale: 1.08,
                    pose: ext > 0.82 ? "clasp" : "reach",
                    opacity: clamp01(0.32 + ext * 0.68),
                    stitchHighlight: 0.35 + 0.60 * ext,
                });

                // 小满从右下迎上来的小手（距离随 ext 贴近）
                const childX = w * 0.64 - ext * (w * 0.13);
                const childY = h * 0.41 + ext * 14;
                drawChildHand(
                    uiDraw,
                    childX,
                    childY,
                    Math.PI + 0.08,
                    1.06,
                    ext > 0.88 ? "clasp" : "reach_up",
                    clamp01(0.25 + ext * 0.75),
                    true,
                );

            } else {
                // 尚未按下或已退回画边：仅在左缘露出一截极淡的补线衣角呼吸微动（零文字强引导）
                const peekPulse = 0.5 + 0.5 * Math.sin(this.animTime * 2.4);
                drawPatchedCuff(uiDraw, uiGlow, {
                    wristX: -120 + peekPulse * 14,
                    wristY: h * 0.44,
                    angleRad: -0.04,
                    scale: 1.04,
                    pose: "open",
                    opacity: 0.36 + 0.22 * peekPulse,
                    stitchHighlight: 0.35 * peekPulse,
                });
            }

            // 仅当玩家在暂停菜单主动打开「按键辅助」时显示轻量提示，默认完全关闭
            if (view.assistHintsEnabled) {
                drawSilkVeil(uiDraw, uiArt, "g05_assist_veil", w * 0.5, h - 26, 280, 28, PALETTE.inkWash, 0.72, -1);
                ctx.texts.put(
                    "xs",
                    adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout),
                    w * 0.5,
                    h - 26,
                    toColor(PALETTE.amberCore),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.2,
                    0.90,
                    0.08,
                );
            }
            return;
        }

        // 满 0.6s 重逢完成：握稳掌心 → 顺相握手臂抬镜 → 露出蹲在身边的周戍 → 单次「我们走吧。」
        const t = this.g05ReunionElapsed;
        const claspPull = smoothstep(0.0, 0.35, t);
        const tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t);
        const armDropY = tilt * (h * 0.095);
        const artAlpha = smoothstep(0.10, 0.48, t) * (1 - smoothstep(1.19, 1.50, t) * 0.82);
        const placed = drawReunionArt(uiDraw, uiArt, w, h, tilt, artAlpha);
        const claspFade = (placed ? 1 - artAlpha : 1) * (1 - smoothstep(0.95, 1.48, t));
        drawPatchedCuff(uiDraw, uiGlow, {
            wristX: w * 0.43,
            wristY: h * 0.44 - armDropY,
            angleRad: -0.05 + tilt * 0.18,
            scale: 1.08,
            pose: "clasp",
            opacity: claspFade,
            stitchHighlight: 0.72 * (1 - tilt * 0.5),
            cuffPullBack: claspPull * 0.85,
            warmth: tilt * 0.32,
        });
        if (claspFade > 0.01) {
            drawChildHand(
                uiDraw, w * 0.53, h * 0.43 - armDropY,
                Math.PI + 0.05 - tilt * 0.14, 1.08, "clasp", claspFade, true,
            );
        }

        if (!placed && tilt > 0.02) {
            drawZhouShuReunionPortrait(uiDraw, uiInkDraw, uiArt, uiGlow, w * 0.72, h * 0.56, 1.0, tilt);
        }

        // 3. 单次定稿台词「我们走吧。」（0.78s 浮现，兼容 live 1.5s 切房与排演 4s 定格）
        const lineAlpha = smoothstep(0.75, 0.98, t);
        if (lineAlpha > 0.02) {
            drawSilkVeil(uiDraw, uiArt, "g05_line_veil", w * 0.5, 42, 420, 44, PALETTE.inkWash, 0.86 * lineAlpha, -1);
            drawHairline(uiInkDraw, uiArt, "g05_line_bar", w * 0.5, 62, 260, PALETTE.amber, 0.58 * lineAlpha, true, 2);
            ctx.texts.put("sm", LINE_G05, w * 0.5, 42, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.2, lineAlpha, 0.08);
        }
    }

    /** G05 独立 4s 排演版（用于三镜对比截帧与自动示范录屏） */
    private renderG05RehearsalShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        t: number,
    ): void {
        // 0.0..0.6s 两下轻叩 → 0.6..1.5s 袖口伸入与握住 → 1.5..2.6s 抬镜切回像素风露周戍 → 2.6..4.0s 「我们走吧。」
        const holdExt = smoothstep(0.55, 1.45, t);
        const tilt = smoothstep(1.55, 2.55, t);
        const claspPull = smoothstep(1.40, 1.75, t);
        const armDropY = tilt * (h * 0.24);

        const boxW = Math.min(w - 120, 860);
        const boxH = Math.min(h - 180, 400);
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5 + 14;
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 14, 150));
        const bgTop = lerpRGBA(rgba(16, 24, 36, 250), rgba(20, 26, 36, 250), tilt);
        const bgBot = lerpRGBA(rgba(10, 15, 24, 250), rgba(14, 18, 26, 250), tilt);
        fillVGradRect(uiDraw, bx, by, boxW, boxH, toColor(bgBot), toColor(bgTop));

        const artAlpha = smoothstep(1.55, 2.1, t);
        const placed = drawReunionArt(uiDraw, uiArt, w, h, tilt, artAlpha);
        const handAlpha = placed ? 1 - artAlpha : 1;
        if (!placed && tilt > 0.05) {
            drawZhouShuReunionPortrait(uiDraw, uiInkDraw, uiArt, uiGlow, bx + boxW * 0.72, by + boxH * 0.54 + (1 - tilt) * 24, 0.92, tilt);
        }

        drawPatchedCuff(uiDraw, uiGlow, {
            wristX: bx + 20 + holdExt * (boxW * 0.40),
            wristY: by + boxH * 0.52 - armDropY,
            angleRad: -0.05 + tilt * 0.20,
            scale: 1.06,
            pose: t >= 1.40 ? "clasp" : "reach",
            opacity: handAlpha * clamp01(0.25 + holdExt * 0.75),
            stitchHighlight: 0.45 + 0.45 * holdExt * (1 - tilt * 0.4),
            cuffPullBack: claspPull * 0.85,
            warmth: tilt * 0.32,
        });
        drawChildHand(
            uiDraw,
            bx + boxW * 0.64 - holdExt * (boxW * 0.12),
            by + boxH * 0.48 - armDropY,
            Math.PI + 0.06,
            1.06,
            t >= 1.40 ? "clasp" : "reach_up",
            handAlpha * clamp01(0.35 + holdExt * 0.65),
            true,
        );

        if (handAlpha > 0.01) {
            uiInkDraw.drawRect(Rect(bx, by, boxW, boxH), Color(0, 0, 0, 0), 1.0, toColor(PALETTE.silkDim, Math.round(145 * handAlpha)));
        }

        const lineAlpha = smoothstep(2.35, 2.65, t);
        if (lineAlpha > 0.02) {
            drawSilkVeil(uiDraw, uiArt, "g05_reh_veil", w * 0.5, 42, 420, 44, PALETTE.inkWash, 0.86 * lineAlpha, -1);
            drawHairline(uiInkDraw, uiArt, "g05_reh_bar", w * 0.5, 62, 260, PALETTE.amber, 0.58 * lineAlpha, true, 2);
            ctx.texts.put("sm", LINE_G05, w * 0.5, 42, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.2, lineAlpha, 0.08);
        }
    }
}

export function createCuffShotsPlugin(): CuffShotsPlugin {
    return new CuffShotsPlugin();
}

/**
 * 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
 * M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
 */
export function registerFe01Plugins(fe: WatchFrontend): {
    gateTransition: GateTransitionPlugin;
    cuffShots: CuffShotsPlugin;
} {
    const gateTransition = createGateTransitionPlugin();
    const cuffShots = createCuffShotsPlugin();
    fe.registerPlugin(gateTransition);
    fe.registerPlugin(cuffShots);
    return { gateTransition, cuffShots };
}
