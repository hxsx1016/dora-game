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
    SlideKeyframe,
    computeCenteredSlideRect,
    drawPixelSlidePlate,
    drawPixelSlideshow,
    drawSlideFrameChrome,
    drawSlideSubtitle,
} from "Script/watch/fe/renderer/slideshow";
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
     * P03 柜边相认（3s 完整节奏 / 60 拍自适应 · 4 帧 480×270 像素幻灯片）：
     * - 0.00..0.28：柜缝先伸出小满两指与柜沿碎瓷；
     * - 0.28..0.60：周戍补线青布袖口拂开碎瓷（配 cloth_wipe_wood 声）；
     * - 0.60..0.80：宽厚糙手掌心朝上伸入柜光；
     * - 0.80..1.00：小满戴红绳的小手搭上兄长掌心，暖光盈框。
     */
    private renderP03Shot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        prog: number,
    ): void {
        const fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1.0, prog));
        const rect = computeCenteredSlideRect(w, h, 860, 484, 16);
        const slides: SlideKeyframe[] = [
            { slot: "slide_cuff_p03_01", start: 0.0, end: 0.28, zoomFrom: 1.0, zoomTo: 1.02, transition: "cut" },
            { slot: "slide_cuff_p03_02", start: 0.28, end: 0.60, panFromX: -0.010, panToX: 0.010, transition: "dark_dip", transitionDur: 0.07 },
            { slot: "slide_cuff_p03_03", start: 0.60, end: 0.80, zoomFrom: 1.0, zoomTo: 1.02, transition: "dark_dip", transitionDur: 0.06 },
            { slot: "slide_cuff_p03_04", start: 0.80, end: 1.01, zoomFrom: 1.01, zoomTo: 1.03, transition: "crossfade", transitionDur: 0.08 },
        ];
        drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, slides, prog, rect, w, h, {
            frameOpacity: 1,
            opacity: fade,
            layer: 2,
            instancePrefix: "p03_cuff",
        });
        const subText = prog < 0.68
            ? "青布袖口掠过柜沿，轻轻拂开了碎瓷。"
            : "「是我，别怕。……这个沉，替我揣怀里。」";
        drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, ctx.texts, "p03_sub", subText, w * 0.5, 42, fade, PALETTE.textBright, 8);
    }

    /**
     * P05 城门送别（4s 完整排演版 · 4 帧 480×270 像素幻灯片）：
     * - 0.00..0.28：城门缝下小满紧攥补线袖口；
     * - 0.28..0.64：周戍隔布轻捏她的手 + 定稿台词；
     * - 0.64..0.84：袖口抽离，留小满张开手指姿态；
     * - 0.84..1.00：重门合拢，门底一线水光与最后半截青袖。
     */
    private renderP05FullShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        prog: number,
    ): void {
        const fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1.0, prog));
        const rect = computeCenteredSlideRect(w, h, 880, 495, 16);
        const dropShake = prog >= 0.84 && prog <= 0.92 ? Math.sin((prog - 0.84) * 260) * 3.2 : 0;
        const slides: SlideKeyframe[] = [
            { slot: "slide_cuff_p05_01", start: 0.0, end: 0.28, zoomFrom: 1.0, zoomTo: 1.02, transition: "cut" },
            { slot: "slide_cuff_p05_02", start: 0.28, end: 0.64, zoomFrom: 1.01, zoomTo: 1.03, transition: "dark_dip", transitionDur: 0.06 },
            { slot: "slide_cuff_p05_03", start: 0.64, end: 0.84, panFromX: 0.006, panToX: -0.010, transition: "dark_dip", transitionDur: 0.06 },
            { slot: "slide_cuff_p05_04", start: 0.84, end: 1.01, panFromY: 0.010, panToY: 0.0, transition: "cut" },
        ];
        drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, slides, prog, rect, w, h, {
            frameOpacity: 1,
            opacity: fade,
            shakeY: dropShake,
            layer: 2,
            instancePrefix: "p05_cuff",
        });

        const lineAlpha = fade * smoothstep(0.18, 0.30, prog) * (1 - smoothstep(0.86, 0.98, prog));
        drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, ctx.texts, "p05_sub", LINE_P05, w * 0.5, 42, lineAlpha, PALETTE.textBright, 8);
    }

    /** Live 模式 gate-send → gate-count 首 3.6s 送别衔接：浮框像素幻灯片接 G01 首帧 */
    private renderP05ExitBridge(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        t: number,
    ): void {
        const enter = smoothstep(0, 0.12, t);
        const out = smoothstep(0.70, 1.0, t);
        const alpha = enter * (1 - out);
        if (alpha <= 0.02) {
            return;
        }
        const rect = computeCenteredSlideRect(w, h, 540, 304, 56);
        const slides: SlideKeyframe[] = [
            { slot: "slide_cuff_p05_01", start: 0.0, end: 0.24, transition: "cut" },
            { slot: "slide_cuff_p05_02", start: 0.24, end: 0.58, transition: "dark_dip", transitionDur: 0.06 },
            { slot: "slide_cuff_p05_03", start: 0.58, end: 0.80, transition: "dark_dip", transitionDur: 0.06 },
            { slot: "slide_cuff_p05_04", start: 0.80, end: 1.01, transition: "cut" },
        ];
        drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, slides, t, rect, w, h, {
            frameOpacity: 0.72,
            opacity: alpha * 0.96,
            layer: 4,
            instancePrefix: "p05_live",
        });
        const lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t));
        drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, ctx.texts, "p05_live", LINE_P05, w * 0.5, 92, lineAlpha, PALETTE.textBright, 9);
    }

    /**
     * G05 男主线风台重逢（正式与排演互动共用 · 4 帧 480×270 像素幻灯片）：
     * - 未完成（!completed）：随按住进度展开像素特写（门隅袖角 → 探袖相迎），松手平滑退回；
     * - 满 0.6s（completed）：暖光抽袖握实掌心 → 高密像素周戍半身肖像特写 + 单次「我们走吧。」。
     */
    private renderG05LiveShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
    ): void {
        const view = ctx.view;
        const gr = view.gateReunion;
        const completed = ctx.p.phase === "gate-hand" || gr.completed;
        const ext = clamp01(this.g05SleeveExtend);

        if (!completed) {
            if (ext > 0.008) {
                const rect = computeCenteredSlideRect(w, h, 820, 461, 14);
                const openOp = clamp01(0.28 + ext * 0.72);
                const blend = smoothstep(0.18, 0.75, ext);
                if (blend < 0.98) {
                    drawPixelSlidePlate(
                        uiDraw, uiInkDraw, uiArt,
                        "slide_cuff_g05_01", "g05_live_peek",
                        rect, openOp * (1 - blend * 0.7), 2,
                    );
                }
                if (blend > 0.02) {
                    drawPixelSlidePlate(
                        uiDraw, uiInkDraw, uiArt,
                        "slide_cuff_g05_02", "g05_live_reach",
                        rect, openOp * blend, 3,
                        (1 - ext) * -0.018, 0, 1.0 + ext * 0.02,
                    );
                }
                drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, rect, w, h, {
                    frameOpacity: openOp * 0.92,
                    opacity: openOp,
                    layer: 2,
                    instancePrefix: "g05_hold",
                });

                // 极细霜月进度丝（贴近底部黑边）
                const barW = 240;
                const bx0 = w * 0.5 - barW * 0.5;
                const by0 = 32;
                uiInkDraw.drawSegment(Vec2(bx0, by0), Vec2(bx0 + barW, by0), 1.2, toColor(PALETTE.silkDim, 110));
                uiInkDraw.drawSegment(Vec2(bx0, by0), Vec2(bx0 + barW * ext, by0), 2.4, toColor(PALETTE.amberCore, 230));
            } else {
                // 未按时在左画缘微露一小方静谧像素袖角窗（呼吸微动，零文字强引导）
                const peekPulse = 0.5 + 0.5 * Math.sin(this.animTime * 2.4);
                const peekRect = { x: 26, y: Math.round(h * 0.34), w: 224, h: 126 };
                drawPixelSlidePlate(
                    uiDraw, uiInkDraw, uiArt,
                    "slide_cuff_g05_01", "g05_live_idle_peek",
                    peekRect, 0.58 + 0.24 * peekPulse, 2,
                    -0.01 + peekPulse * 0.01,
                );
                drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, peekRect, w, h, {
                    frameOpacity: 0,
                    opacity: 0.65 + 0.2 * peekPulse,
                    layer: 2,
                    instancePrefix: "g05_idle_peek",
                });
                uiInkDraw.drawRect(Rect(peekRect.x, peekRect.y, peekRect.w, peekRect.h), Color(0, 0, 0, 0), 1.0, toColor(PALETTE.silkDim, Math.round(115 + 65 * peekPulse)));
            }

            if (view.assistHintsEnabled) {
                drawSilkVeil(uiDraw, uiArt, "g05_assist_veil", w * 0.5, h - 26, 280, 28, PALETTE.inkWash, 0.72, 7);
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

        // 满 0.6s 重逢完成：抽袖握实掌心 → 抬镜周戍高密像素肖像特写 → 「我们走吧。」
        const t = this.g05ReunionElapsed;
        const rect = computeCenteredSlideRect(w, h, 880, 495, 16);
        const slides: SlideKeyframe[] = [
            {
                slot: "slide_cuff_g05_03",
                start: 0.0,
                end: 0.48,
                zoomFrom: 1.0,
                zoomTo: 1.03,
                transition: "cut",
            },
            {
                slot: "slide_cuff_g05_04",
                start: 0.48,
                end: 6.0,
                panFromY: -0.014,
                panToY: 0.004,
                zoomFrom: 1.01,
                zoomTo: 1.035,
                transition: "dark_dip",
                transitionDur: 0.26,
            },
        ];
        drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, slides, t, rect, w, h, {
            frameOpacity: 0.94,
            opacity: 1,
            layer: 2,
            instancePrefix: "g05_reunion",
        });

        const lineAlpha = smoothstep(0.75, 0.98, t);
        drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, ctx.texts, "g05_line", LINE_G05, w * 0.5, 42, lineAlpha, PALETTE.amberCore, 8);
    }

    /** G05 独立 4s 排演版（用于三镜对比截帧与自动示范录屏） */
    private renderG05RehearsalShot(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        t: number,
    ): void {
        const rect = computeCenteredSlideRect(w, h, 880, 495, 16);
        const slides: SlideKeyframe[] = [
            { slot: "slide_cuff_g05_01", start: 0.0, end: 0.72, zoomFrom: 1.0, zoomTo: 1.02, transition: "cut" },
            { slot: "slide_cuff_g05_02", start: 0.72, end: 1.48, panFromX: -0.010, panToX: 0.008, transition: "dark_dip", transitionDur: 0.18 },
            { slot: "slide_cuff_g05_03", start: 1.48, end: 2.20, zoomFrom: 1.0, zoomTo: 1.025, transition: "dark_dip", transitionDur: 0.18 },
            { slot: "slide_cuff_g05_04", start: 2.20, end: 4.10, panFromY: -0.012, panToY: 0.004, zoomFrom: 1.01, zoomTo: 1.03, transition: "dark_dip", transitionDur: 0.24 },
        ];
        drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, slides, t, rect, w, h, {
            frameOpacity: 1,
            opacity: 1,
            layer: 2,
            instancePrefix: "g05_reh",
        });

        const lineAlpha = smoothstep(2.35, 2.65, t);
        drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, ctx.texts, "g05_reh", LINE_G05, w * 0.5, 42, lineAlpha, PALETTE.amberCore, 8);
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
