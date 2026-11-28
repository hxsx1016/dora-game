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

    // 过场绘卷内活态浮尘微动（随过场时间轴轻盈漂游，消除纯静态幻灯片感）
    const moteAlpha = baseOp * (1 - dipShade) * 0.58;
    if (moteAlpha > 0.04) {
        for (let m = 0; m < 14; m++) {
            const seed = m * 37.3 + 11.7;
            const u = ((Math.sin(seed) * 43758.5453) % 1 + 1) % 1;
            const v = ((Math.sin(seed * 1.7) * 24634.6345) % 1 + 1) % 1;
            const mx = shiftedRect.x + (((u + t * (0.018 + (m % 3) * 0.007)) % 1) * shiftedRect.w);
            const my = shiftedRect.y + (((v + t * (0.012 + (m % 2) * 0.008)) % 1) * shiftedRect.h);
            const tw = 0.45 + 0.55 * Math.sin(t * 2.4 + m * 1.9);
            const col = (m % 3 === 0) ? PALETTE.amberCore : PALETTE.jadeMist;
            uiInkDraw.drawDot(Vec2(mx, my), 1.1 + (m % 2) * 0.65, toColor(col, 118 * tw * moteAlpha));
        }
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

// ============================================================================
// 墨帧动漫播放器（Stepped Motion-Comic Animatic Engine）
// 专为《向西守望》硬核明代木刻暗黑漫画过场设计：
// - 不等时原画拍表（X-Sheet）：缺省零重影硬切（cut），彻底杜绝 PPT 淡化感；
// - 单帧冲击帧（impactFlash）与定向阻尼震屏（shakeAmp），完全由 worldDt 时间轴确定性驱动；
// - 漫画斜切转场（slash_cut）与非阻塞斜切破格插格（drawComicInsertPanel），适配 F01/M02 等插入演出。
// ============================================================================

export type ComicTransitionMode = "cut" | "slash_cut" | "dark_dip" | "crossfade";

export interface ComicKeyframe {
    /** 对应 ASSET_SLOTS 或动态槽位中的高清漫画原画键名 */
    slot: string;
    /** 帧起止时间（秒或 0..1 归一化进度） */
    start: number;
    end: number;
    /** 极克制呼吸微缩放（如 1.00 -> 1.015），拒绝大幅度幻灯片平移 */
    zoomFrom?: number;
    zoomTo?: number;
    panFromX?: number;
    panToX?: number;
    panFromY?: number;
    panToY?: number;
    /** 入帧转场：默认 cut（干脆硬切，零重影） */
    transition?: ComicTransitionMode;
    transitionDur?: number;
    /** 冲击帧标识：开启后在入帧瞬间叠绘暗朱/骨白高反差漫画冲击边框 */
    impactFlash?: boolean;
    impactDur?: number;
    /** 入帧阻尼微震幅度（逻辑像素），随 elapsed 指数衰减，暂停即刻冻结 */
    shakeAmp?: number;
    /** 震屏角频率（rad/s，默认 58） */
    shakeFreq?: number;
    /** 可选色调叠乘 */
    tint?: RGBA;
}

export interface ComicSequenceOptions {
    /** 上下电影遮幅高度（默认按 7% 视口高度） */
    letterboxH?: number;
    /** 整体不透明度 */
    opacity?: number;
    /** 渲染层序基值 */
    layer?: number;
    /** 唯一实例前缀，避免同帧多组动画冲突 */
    instancePrefix: string;
    /** 电影遮幅内侧是否勾勒细雅霜月/朱砂界线 */
    accentBorder?: boolean;
}

/** 绘制全屏硬核木刻暗黑漫画逐帧序列（确定性时间轴，暂停即刻冻结） */
export function drawComicSequence(
    uiDraw: DrawNode.Type,
    uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    keyframes: readonly ComicKeyframe[],
    t: number,
    uiW: number,
    uiH: number,
    opts: ComicSequenceOptions,
): number {
    if (keyframes.length === 0) {
        return -1;
    }
    const baseOp = clamp01(opts.opacity ?? 1);
    if (baseOp <= 0.004) {
        return -1;
    }
    const baseLayer = opts.layer ?? 2;
    const barH = opts.letterboxH ?? Math.round(uiH * 0.068);

    // 鸦青死黑底幕，严防底层实机或宽屏边缘透穿
    uiDraw.drawRect(Rect(0, 0, uiW, uiH), Color(6, 7, 10, Math.round(255 * baseOp)));

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
    const localT = Math.max(0, t - kf.start);
    const localU = clamp01(localT / span);
    const easedU = smooth(localU);

    const panX = (kf.panFromX ?? 0) + ((kf.panToX ?? 0) - (kf.panFromX ?? 0)) * easedU;
    const panY = (kf.panFromY ?? 0) + ((kf.panToY ?? 0) - (kf.panFromY ?? 0)) * easedU;
    const zoom = (kf.zoomFrom ?? 1) + ((kf.zoomTo ?? 1) - (kf.zoomFrom ?? 1)) * easedU;

    // 确定性阻尼微震（仅由 localT 决定，暂停时严格静止）
    let shakeX = 0;
    let shakeY = 0;
    const amp = kf.shakeAmp ?? 0;
    if (amp > 0.05) {
        const decay = Math.exp(-localT * 13.5);
        if (decay > 0.02) {
            const freq = kf.shakeFreq ?? 58;
            // 量化为离散步进震感，贴合手绘漫画冲击韵律
            const steppedT = Math.floor(localT * 24) / 24;
            shakeX = Math.round(Math.sin(steppedT * freq + 0.6) * amp * decay);
            shakeY = Math.round(Math.cos(steppedT * freq * 1.17) * amp * 0.68 * decay);
        }
    }

    const coverRect = computeFullscreenSlideRect(uiW, uiH);
    const shiftedRect: SlideRect = {
        x: coverRect.x + shakeX,
        y: coverRect.y + shakeY,
        w: coverRect.w,
        h: coverRect.h,
    };

    const trans: ComicTransitionMode = kf.transition ?? "cut";
    const transDur = Math.max(0.001, kf.transitionDur ?? 0.10);

    if (activeIdx > 0 && localT < transDur && trans === "slash_cut") {
        // 漫画斜切刀锋硬切：黑底斜刀闪白/暗朱，干脆利落切入新机位
        const prev = keyframes[activeIdx - 1];
        const k = clamp01(localT / transDur);
        if (k < 0.42) {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                prev.slot, opts.instancePrefix + "_prev_" + tostring(activeIdx - 1),
                coverRect, baseOp, baseLayer,
                prev.panToX ?? 0, prev.panToY ?? 0, prev.zoomTo ?? 1, prev.tint,
            );
        } else {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
                shiftedRect, baseOp, baseLayer,
                panX, panY, zoom, kf.tint,
            );
        }
        // 斜向黑幕与骨白/暗朱刀锋斜线
        const slashAlpha = Math.sin(k * Math.PI);
        uiInkDraw.drawRect(Rect(0, 0, uiW, uiH), Color(6, 7, 10, Math.round(230 * slashAlpha * baseOp)));
        const sx0 = uiW * (0.86 - k * 0.14);
        const sx1 = uiW * (0.18 - k * 0.14);
        uiInkDraw.drawSegment(Vec2(sx0, uiH), Vec2(sx1, 0), 5.5, Color(242, 234, 218, Math.round(240 * slashAlpha * baseOp)));
        uiInkDraw.drawSegment(Vec2(sx0 + 7, uiH), Vec2(sx1 + 7, 0), 3.0, Color(196, 44, 44, Math.round(235 * slashAlpha * baseOp)));
    } else if (activeIdx > 0 && localT < transDur && trans === "crossfade") {
        const prev = keyframes[activeIdx - 1];
        const k = smooth(localT / transDur);
        drawPixelSlidePlate(
            uiDraw, uiInkDraw, uiArt,
            prev.slot, opts.instancePrefix + "_prev_" + tostring(activeIdx - 1),
            coverRect, baseOp * (1 - k * 0.65), baseLayer,
            prev.panToX ?? 0, prev.panToY ?? 0, prev.zoomTo ?? 1, prev.tint,
        );
        drawPixelSlidePlate(
            uiDraw, uiInkDraw, uiArt,
            kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
            shiftedRect, baseOp * k, baseLayer + 1,
            panX, panY, zoom, kf.tint,
        );
    } else if (activeIdx > 0 && localT < transDur && trans === "dark_dip") {
        const prev = keyframes[activeIdx - 1];
        const k = clamp01(localT / transDur);
        const dip = Math.sin(k * Math.PI);
        if (k < 0.5) {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                prev.slot, opts.instancePrefix + "_prev_" + tostring(activeIdx - 1),
                coverRect, baseOp * (1 - dip), baseLayer,
                prev.panToX ?? 0, prev.panToY ?? 0, prev.zoomTo ?? 1, prev.tint,
            );
        } else {
            drawPixelSlidePlate(
                uiDraw, uiInkDraw, uiArt,
                kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
                shiftedRect, baseOp * (1 - dip), baseLayer,
                panX, panY, zoom, kf.tint,
            );
        }
        uiInkDraw.drawRect(Rect(0, 0, uiW, uiH), Color(6, 7, 10, Math.round(245 * dip * baseOp)));
    } else {
        drawPixelSlidePlate(
            uiDraw, uiInkDraw, uiArt,
            kf.slot, opts.instancePrefix + "_cur_" + tostring(activeIdx),
            shiftedRect, baseOp, baseLayer,
            panX, panY, zoom, kf.tint,
        );
    }

    // 冲击帧高反差朱砂/骨白漫画震框
    if (kf.impactFlash === true) {
        const impDur = kf.impactDur ?? Math.min(0.22, span);
        if (localT <= impDur) {
            const impK = 1 - clamp01(localT / Math.max(0.01, impDur));
            const borderA = Math.round((165 + 85 * impK) * baseOp);
            const insetY = barH;
            const boxH = Math.max(40, uiH - insetY * 2);
            uiInkDraw.drawRect(
                Rect(2, insetY + 1, uiW - 4, boxH - 2),
                Color(0, 0, 0, 0),
                3.2,
                Color(204, 42, 42, borderA),
            );
            uiInkDraw.drawRect(
                Rect(6, insetY + 5, uiW - 12, boxH - 10),
                Color(0, 0, 0, 0),
                1.2,
                Color(246, 240, 226, Math.round(140 * impK * baseOp)),
            );
        }
    }

    // 上下硬核宽银幕遮幅（纯墨黑 + 克制内侧界线）
    if (barH > 0) {
        const barA = Math.round(252 * baseOp);
        uiInkDraw.drawRect(Rect(0, uiH - barH, uiW, barH), Color(6, 7, 10, barA));
        uiInkDraw.drawRect(Rect(0, 0, uiW, barH), Color(6, 7, 10, barA));
        if (opts.accentBorder !== false) {
            const lineCol = kf.impactFlash === true
                ? Color(204, 46, 46, Math.round(180 * baseOp))
                : toColor(PALETTE.silkDim, Math.round(84 * baseOp));
            uiInkDraw.drawSegment(Vec2(0, uiH - barH), Vec2(uiW, uiH - barH), 1.0, lineCol);
            uiInkDraw.drawSegment(Vec2(0, barH), Vec2(uiW, barH), 1.0, lineCol);
        }
    }

    return activeIdx;
}

/**
 * 绘制非阻塞漫画插格（供 F01 缝衣闪回、M02 工台试握等在实机画面上炸出的高张力漫画格）。
 * 具备硬黑底衬、骨白内框与暗朱角线，绝不阻断输入或遮盖主操作区。
 */
export function drawComicInsertPanel(
    uiDraw: DrawNode.Type,
    uiInkDraw: DrawNode.Type,
    uiArt: AssetSlotHost,
    keyframes: readonly ComicKeyframe[],
    t: number,
    rect: SlideRect,
    opacity: number,
    instancePrefix: string,
    layer: number = 4,
): number {
    const op = clamp01(opacity);
    if (keyframes.length === 0 || op <= 0.01) {
        return -1;
    }
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
    const zoom = (kf.zoomFrom ?? 1) + ((kf.zoomTo ?? 1) - (kf.zoomFrom ?? 1)) * smooth(localU);

    // 漫画硬投影外框（右下偏置硬黑影 + 骨白细边 + 暗朱破格折角）
    const pad = 6;
    uiDraw.drawRect(
        Rect(rect.x - pad + 5, rect.y - pad - 5, rect.w + pad * 2, rect.h + pad * 2),
        Color(5, 6, 9, Math.round(230 * op)),
    );
    uiDraw.drawRect(
        Rect(rect.x - pad, rect.y - pad, rect.w + pad * 2, rect.h + pad * 2),
        Color(8, 9, 13, Math.round(248 * op)),
    );
    drawPixelSlidePlate(
        uiDraw, uiInkDraw, uiArt,
        kf.slot, instancePrefix + "_ins_" + tostring(activeIdx),
        rect, op, layer,
        0, 0, zoom, kf.tint,
    );
    uiInkDraw.drawRect(
        Rect(rect.x - 1, rect.y - 1, rect.w + 2, rect.h + 2),
        Color(0, 0, 0, 0),
        2.0,
        Color(232, 224, 208, Math.round(220 * op)),
    );
    // 左上与右下暗朱漫画压角线
    const corner = 24;
    const red = Color(192, 48, 46, Math.round(235 * op));
    uiInkDraw.drawSegment(Vec2(rect.x - 4, rect.y + rect.h + 4), Vec2(rect.x + corner, rect.y + rect.h + 4), 2.4, red);
    uiInkDraw.drawSegment(Vec2(rect.x - 4, rect.y + rect.h + 4), Vec2(rect.x - 4, rect.y + rect.h - corner), 2.4, red);
    uiInkDraw.drawSegment(Vec2(rect.x + rect.w + 4, rect.y - 4), Vec2(rect.x + rect.w - corner, rect.y - 4), 2.4, red);
    uiInkDraw.drawSegment(Vec2(rect.x + rect.w + 4, rect.y - 4), Vec2(rect.x + rect.w + 4, rect.y + corner), 2.4, red);
    return activeIdx;
}
