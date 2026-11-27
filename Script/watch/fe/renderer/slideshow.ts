/**
 * 《向西守望》「明月绘卷」像素幻灯片与电影氛围渲染内核。
 *
 * 职责：
 * - 为全篇叙事过场（P01-P05、G01-G05、F01 回忆、M02 试握、F03/M03 北塔双结局、E01/E02 古井展厅）
 *   提供统一的像素级幻灯片播放、玄漆画框装帧、像素微运镜、局部循环微动与暗场水墨转场；
 * - 全部使用 AssetSlotHost 渲染（TextureFilter.Point），彻底替代 DrawNode 硬矢量几何画；
 * - 严格由调用方传入 worldDt 驱动的时间参数，暂停态自动冻结。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { AssetSlotHost } from "Script/watch/fe/assets";
import {
    PALETTE,
    RGBA,
    drawFiligreeCorners,
    drawHairline,
    drawSilkVeil,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    toColor,
} from "Script/watch/fe/theme";
import { TextPool } from "Script/watch/fe/ui/textpool";

const WHITE = Color(255, 255, 255, 255);

export type SlideTransitionMode = "cut" | "dark_dip" | "crossfade";

export interface SlideKeyframe {
    /** 对应 ASSET_SLOTS 或动态槽位中的像素幻灯片键名 */
    slot: string;
    /** 帧起止时间（单位由调用方决定，可以是秒或 0..1 归一化进度） */
    start: number;
    end: number;
    /** 可选：该帧微运镜偏移（以画幅宽/高比例计，保持极克制，如 0.012） */
    panFromX?: number;
    panToX?: number;
    panFromY?: number;
    panToY?: number;
    /** 可选：微推拉缩放（1.0 ~ 1.045） */
    zoomFrom?: number;
    zoomTo?: number;
    /** 与上一帧衔接方式：默认暗场顿挫（避免廉价线性重影） */
    transition?: SlideTransitionMode;
    /** 过渡时长（与 start/end 同单位） */
    transitionDur?: number;
    /** 可选着色叠加 */
    tint?: RGBA;
}

export interface SlideRect {
    x: number;
    y: number;
    w: number;
    h: number;
}

export interface SlideFrameOptions {
    /** 玄漆镶边画框内阴影与细线强度（0 = 无边框全屏满铺，>0 = 绘卷画框模式） */
    frameOpacity?: number;
    /** 上下电影黑边高度（0 = 不画） */
    letterboxH?: number;
    /** 整体不透明度 */
    opacity?: number;
    /** 瞬时像素微震（像素单位） */
    shakeX?: number;
    shakeY?: number;
    /** 渲染层序基值 */
    layer?: number;
    /** 唯一实例前缀，防止同帧多处冲突 */
    instancePrefix: string;
}

function clamp01(v: number): number {
    if (v <= 0) {
        return 0;
    }
    if (v >= 1) {
        return 1;
    }
    return v;
}

function smooth(v: number): number {
    const t = clamp01(v);
    return t * t * (3 - 2 * t);
}

/** 计算居中的 16:9 像素特写画框区域（用于 P03/P05/G05/E02 回柜等绘卷特写） */
export function computeCenteredSlideRect(
    uiW: number,
    uiH: number,
    maxW: number = 880,
    maxH: number = 495,
    offsetY: number = 14,
): SlideRect {
    const availW = Math.min(maxW, uiW - 96);
    const availH = Math.min(maxH, uiH - 148);
    const aspect = 16 / 9;
    let w = availW;
    let h = w / aspect;
    if (h > availH) {
        h = availH;
        w = h * aspect;
    }
    return {
        x: Math.round((uiW - w) * 0.5),
        y: Math.round((uiH - h) * 0.5 + offsetY),
        w: Math.round(w),
        h: Math.round(h),
    };
}

/** 计算全屏覆盖 16:9 像素画幅区域（cover 适配，无黑边漏缝） */
export function computeFullscreenSlideRect(uiW: number, uiH: number): SlideRect {
    const aspect = 16 / 9;
    let w = uiW;
    let h = w / aspect;
    if (h < uiH) {
        h = uiH;
        w = h * aspect;
    }
    return {
        x: Math.round((uiW - w) * 0.5),
        y: Math.round((uiH - h) * 0.5),
        w: Math.round(w),
        h: Math.round(h),
    };
}

/** 绘制单张像素幻灯片（支持微运镜与安全回退底幕） */
export function drawPixelSlidePlate(
    uiDraw: DrawNode.Type,
    _uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    slotKey: string,
    instanceKey: string,
    rect: SlideRect,
    opacity: number = 1,
    layer: number = 2,
    panX: number = 0,
    panY: number = 0,
    zoom: number = 1,
    tint?: RGBA,
): boolean {
    const op = clamp01(opacity);
    if (op <= 0.004) {
        return false;
    }
    const cx = rect.x + rect.w * 0.5 + panX * rect.w;
    const cy = rect.y + rect.h * 0.5 + panY * rect.h;
    const tw = Math.round(rect.w * zoom);
    const th = Math.round(rect.h * zoom);
    const col = tint !== undefined ? toColor(tint, 255) : WHITE;
    const placed = uiArt.tryPlace(slotKey, instanceKey, Math.round(cx), Math.round(cy), tw, th, {
        opacity: op,
        color: col,
        layer,
    });
    if (!placed) {
        fillVGradRect(
            uiDraw,
            rect.x,
            rect.y,
            rect.w,
            rect.h,
            toColor(PALETTE.inkVoid, Math.round(235 * op)),
            toColor(PALETTE.inkMist, Math.round(235 * op)),
        );
    }
    return placed;
}

/** 绘制绘卷玄漆外框、宋明海棠折角与电影黑边遮幅 */
export function drawSlideFrameChrome(
    uiDraw: DrawNode.Type,
    uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    rect: SlideRect,
    uiW: number,
    uiH: number,
    opts: SlideFrameOptions,
): void {
    const op = clamp01(opts.opacity ?? 1);
    const frameOp = clamp01(opts.frameOpacity ?? 0);
    const baseLayer = opts.layer ?? 2;

    if (frameOp > 0.01) {
        // 暗幕压底，突出像素绘卷特写
        uiDraw.drawRect(Rect(0, 0, uiW, uiH), toColor(PALETTE.inkVoid, Math.round(182 * op * frameOp)));
        // 绘卷画框外沉影
        const pad = 8;
        uiDraw.drawRect(
            Rect(rect.x - pad, rect.y - pad - 3, rect.w + pad * 2, rect.h + pad * 2 + 3),
            Color(4, 6, 10, Math.round(215 * op * frameOp)),
        );
        // 细雅霜月海棠折角（叠在画框外沿）
        drawFiligreeCorners(
            uiInkDraw,
            uiArt,
            opts.instancePrefix + "_corners",
            rect.x - 1,
            rect.y - 1,
            rect.w + 2,
            rect.h + 2,
            PALETTE.silkLine,
            0.62 * op * frameOp,
            26,
            true,
            baseLayer + 6,
        );
    }

    const barH = opts.letterboxH ?? 0;
    if (barH > 0) {
        uiInkDraw.drawRect(Rect(0, uiH - barH, uiW, barH), toColor(PALETTE.inkVoid, Math.round(245 * op)));
        uiInkDraw.drawRect(Rect(0, 0, uiW, barH), toColor(PALETTE.inkVoid, Math.round(245 * op)));
        uiInkDraw.drawSegment(Vec2(0, uiH - barH), Vec2(uiW, uiH - barH), 0.8, toColor(PALETTE.silkDim, Math.round(74 * op)));
        uiInkDraw.drawSegment(Vec2(0, barH), Vec2(uiW, barH), 0.8, toColor(PALETTE.silkDim, Math.round(74 * op)));
    }
}

/**
 * 播放一组时间轴驱动的像素幻灯片（明月绘卷内核）。
 * - 自动按 t 选择当前关键帧；
 * - dark_dip 模式在帧界做短暂暗幕沉顿（零半透明重影，电影剪辑感强）；
 * - crossfade 模式用于同机位光影变化（如西窗亮灯、风台叠化、井底同心反光）。
 */
export function drawPixelSlideshow(
    uiDraw: DrawNode.Type,
    uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    keyframes: readonly SlideKeyframe[],
    t: number,
    rect: SlideRect,
    uiW: number,
    uiH: number,
    opts: SlideFrameOptions,
): number {
    if (keyframes.length === 0) {
        return -1;
    }
    const baseOp = clamp01(opts.opacity ?? 1);
    const baseLayer = opts.layer ?? 2;
    const shakeX = opts.shakeX ?? 0;
    const shakeY = opts.shakeY ?? 0;
    const shiftedRect: SlideRect = {
        x: Math.round(rect.x + shakeX),
        y: Math.round(rect.y + shakeY),
        w: rect.w,
        h: rect.h,
    };

    let activeIdx = keyframes.length - 1;
    let i = 0;
    for (i = 0; i < keyframes.length; i++) {
        if (t < keyframes[i].end || i === keyframes.length - 1) {
            activeIdx = i;
            break;
        }
    }

    const kf = keyframes[activeIdx];
    const span = Math.max(0.0001, kf.end - kf.start);
    const localU = clamp01((t - kf.start) / span);
    const easedU = smooth(localU);
    const panX = (kf.panFromX ?? 0) + ((kf.panToX ?? 0) - (kf.panFromX ?? 0)) * easedU;
    const panY = (kf.panFromY ?? 0) + ((kf.panToY ?? 0) - (kf.panFromY ?? 0)) * easedU;
    const zoom = (kf.zoomFrom ?? 1) + ((kf.zoomTo ?? 1) - (kf.zoomFrom ?? 1)) * easedU;

    const trans = kf.transition ?? "dark_dip";
    const transDur = Math.max(0.001, kf.transitionDur ?? 0.22);
    const sinceStart = t - kf.start;

    let dipShade = 0;
    if (activeIdx > 0 && sinceStart >= 0 && sinceStart < transDur) {
        const prev = keyframes[activeIdx - 1];
        const prevPanX = prev.panToX ?? 0;
        const prevPanY = prev.panToY ?? 0;
        const prevZoom = prev.zoomTo ?? 1;
        const k = smooth(sinceStart / transDur);

        if (trans === "crossfade") {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                prev.slot, opts.instancePrefix + "_prev_" + tostring(activeIdx - 1),
                shiftedRect, baseOp * (1 - k * 0.65), baseLayer,
                prevPanX, prevPanY, prevZoom, prev.tint,
            );
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
                shiftedRect, baseOp * k, baseLayer + 1,
                panX, panY, zoom, kf.tint,
            );
        } else if (trans === "dark_dip") {
            if (k < 0.45) {
                const prevOp = 1 - smooth(k / 0.45);
                drawPixelSlidePlate(
                    uiDraw, uiInkDraw, uiArt,
                    prev.slot, opts.instancePrefix + "_prev_" + tostring(activeIdx - 1),
                    shiftedRect, baseOp * prevOp, baseLayer,
                    prevPanX, prevPanY, prevZoom, prev.tint,
                );
                dipShade = 0.85 * smooth(k / 0.45);
            } else {
                const curOp = smooth((k - 0.45) / 0.55);
                drawPixelSlidePlate(
                    uiDraw, uiInkDraw, uiArt,
                    kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
                    shiftedRect, baseOp * curOp, baseLayer,
                    panX, panY, zoom, kf.tint,
                );
                dipShade = 0.85 * (1 - curOp);
            }
        } else {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
                shiftedRect, baseOp, baseLayer,
                panX, panY, zoom, kf.tint,
            );
        }
    } else {
        drawPixelSlidePlate(
            uiDraw, uiInkDraw, uiArt,
            kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
            shiftedRect, baseOp, baseLayer,
            panX, panY, zoom, kf.tint,
        );
    }

    if (dipShade > 0.01) {
        uiInkDraw.drawRect(
            Rect(shiftedRect.x, shiftedRect.y, shiftedRect.w, shiftedRect.h),
            toColor(PALETTE.inkVoid, Math.round(235 * dipShade * baseOp)),
        );
    }

    drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, shiftedRect, uiW, uiH, opts);
    return activeIdx;
}

/** 绘制统一宋明烟黛过场字幕条 */
export function drawSlideSubtitle(
    uiDraw: DrawNode.Type,
    uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    texts: TextPool,
    keyPrefix: string,
    text: string,
    cx: number,
    cy: number,
    alpha: number,
    color: RGBA = PALETTE.textBright,
    layer: number = 8,
): void {
    const a = clamp01(alpha);
    if (a <= 0.01 || text === "") {
        return;
    }
    const veilW = Math.max(320, Math.min(760, text.length * 15 + 140));
    drawSilkVeil(uiDraw, uiArt, keyPrefix + "_veil", cx, cy, veilW, 44, PALETTE.inkWash, 0.84 * a, layer);
    drawHairline(uiInkDraw, uiArt, keyPrefix + "_hair", cx, cy + 20, veilW * 0.62, PALETTE.silkDim, 0.48 * a, true, layer + 1);
    texts.put("sm", text, cx, cy, toColor(color), 0.5, 0.5, TextAlign.Center, 1.2, a, 0.08);
}

/**
 * 小满单人线「冷月像素电影剧场」氛围调色与四周压边暗角。
 * 绝不使用硬描边或多边形块，仅用克制冷靛月雾渐变与四角柔光暗晕衬托像素场景。
 */
export function drawChildColdMoonGrade(
    draw: DrawNode.Type,
    glow: DrawNode.Type,
    w: number,
    h: number,
    intensity: number = 1,
    warmShift: number = 0,
): void {
    const k = clamp01(intensity);
    if (k <= 0.01) {
        return;
    }
    const coldAmt = k * (1 - clamp01(warmShift) * 0.72);
    const zeroVoid = Color(10, 14, 22, 0);
    // 顶部冷月夜压顶 + 底部沉墨托底
    fillVGradRect(draw, 0, h * 0.64, w, h * 0.36, zeroVoid, Color(8, 12, 22, Math.round(96 * coldAmt)));
    fillVGradRect(draw, 0, 0, w, h * 0.14, Color(6, 9, 16, Math.round(115 * k)), zeroVoid);
    // 左右电影暗角（低视角孤寂纵深感）
    fillHGradRect(draw, 0, 0, w * 0.14, h, Color(7, 10, 18, Math.round(112 * coldAmt)), zeroVoid);
    fillHGradRect(draw, w * 0.86, 0, w * 0.14, h, zeroVoid, Color(7, 10, 18, Math.round(112 * coldAmt)));
    // 极克制冷青月雾散射
    if (coldAmt > 0.05) {
        fillRadialGlow(
            glow,
            w * 0.72,
            h * 0.78,
            w * 0.38,
            h * 0.34,
            Color(138, 174, 206, Math.round(24 * coldAmt)),
            Color(24, 42, 68, 0),
            14,
        );
    }
}
