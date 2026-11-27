/**
 * 《向西守望》竖屏宋明水墨掌机操控台布局与外框绘制（仅安卓手机/平板与 Web 引入）。
 *
 * 注意：Windows 与 Android 掌机（锁定横屏）发行包不引入、不打包本模块。
 */

import { DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { TouchButtonSpec, TouchFrameContext, TouchRouter } from "Script/watch/input/touch_core";
import { InteractActionMeta, StageViewport } from "Script/watch/target_types";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { PALETTE, drawDiamond, fillVGradRect, toColor } from "Script/watch/fe/theme";

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

export interface PortraitStickGeom {
    unitPortrait: number;
    stickMaxR: number;
    stickDefaultX: number;
    stickDefaultY: number;
    stickZoneMaxX: number;
    stickZoneMaxY: number;
}

export interface PortraitTouchDelegate {
    computeStickGeom(vp: StageViewport, ovW: number, safeL: number, safeB: number, sc: number): PortraitStickGeom;
    pushTopButtons(
        buttons: TouchButtonSpec[],
        vp: StageViewport,
        ovW: number,
        ovH: number,
        safeR: number,
        gameplayActive: boolean,
        p: Play | undefined,
        isMuted: boolean,
        isFullscreen: boolean,
        allowFullscreen: boolean,
    ): void;
    pushMenuNavButtons(
        buttons: TouchButtonSpec[],
        vp: StageViewport,
        ovW: number,
        safeL: number,
        safeR: number,
        safeB: number,
    ): void;
    pushActionButtons(
        buttons: TouchButtonSpec[],
        vp: StageViewport,
        ovW: number,
        safeR: number,
        safeB: number,
        geom: PortraitStickGeom,
        sc: number,
        p: Play,
        isPlayMode: boolean,
        canBottleAim: boolean,
        nearLedge: boolean,
        interactMeta: InteractActionMeta,
        router: TouchRouter,
    ): { x: number; y: number; r: number };
    drawFrame(
        deckDraw: DrawNode.Type,
        padInkDraw: DrawNode.Type,
        texts: TextPool,
        ctx: TouchFrameContext,
        lastPlay: Play | undefined,
        w: number,
        h: number,
    ): void;
}

export const PORTRAIT_TOUCH_DELEGATE: PortraitTouchDelegate = {
    computeStickGeom(vp, ovW, safeL, safeB, sc) {
        const unitPortrait = clamp(Math.min(vp.fullW / 420, Math.max(180, vp.deckH) / 340), 0.72, 1.15);
        const stickMaxR = Math.round(52 * unitPortrait * sc);
        return {
            unitPortrait,
            stickMaxR,
            stickDefaultX: safeL + Math.max(stickMaxR + 26, Math.round(ovW * 0.24)),
            stickDefaultY: Math.max(safeB + stickMaxR + 24, vp.deckH * 0.44),
            stickZoneMaxX: ovW * 0.50,
            stickZoneMaxY: Math.max(40, vp.deckH - 8),
        };
    },

    pushTopButtons(buttons, vp, ovW, ovH, safeR, gameplayActive, p, isMuted, isFullscreen, allowFullscreen) {
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
            label: isMuted ? "静音" : "有声",
            accent: isMuted ? "rouge" : "cyan",
            active: isMuted,
            highlighted: false,
            progress: 0,
            dimmed: false,
        });
        rx -= 8;

        if (allowFullscreen) {
            const fw = 54;
            rx -= fw;
            buttons.push({
                id: "fullscreen",
                x: rx + fw * 0.5,
                y: topY,
                r: 20,
                shape: "pill",
                rect: Rect(rx, topY - pillH * 0.5, fw, pillH),
                label: isFullscreen ? "窗口" : "全屏",
                accent: "silk",
                active: isFullscreen,
                highlighted: false,
                progress: 0,
                dimmed: false,
            });
        }
    },

    pushMenuNavButtons(buttons, vp, ovW, safeL, safeR, safeB) {
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
    },

    pushActionButtons(buttons, vp, ovW, safeR, safeB, geom, sc, p, isPlayMode, canBottleAim, nearLedge, interactMeta, router) {
        const u = geom.unitPortrait * sc;
        const rightX = ovW - safeR - Math.round(68 * u);
        const bottomY = Math.max(safeB + Math.round(70 * u), vp.deckH * 0.40);
        const postY = Math.min(vp.deckH - 26, geom.stickDefaultY + geom.stickMaxR + Math.round(42 * u));
        const bottleCancelCenter = { x: rightX - Math.round(14 * u), y: bottomY + Math.round(10 * u), r: Math.round(34 * u) };

        if (!p.childMode) {
            const cw = Math.round(86 * u);
            const ch = Math.round(32 * u);
            buttons.push({
                id: "cover",
                x: geom.stickDefaultX,
                y: postY,
                r: 24 * u,
                shape: "pill",
                toggle: true,
                rect: Rect(geom.stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch),
                label: router.coverToggled ? "离掩体" : "贴掩体",
                accent: "cyan",
                active: router.coverToggled || p.coverHug,
                highlighted: p.coverNear && !router.coverToggled,
                progress: 0,
                dimmed: !p.coverNear && !router.coverToggled,
            });
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
            const pw = Math.round(68 * u);
            const ph = Math.round(32 * u);
            buttons.push({
                id: "crouch",
                x: geom.stickDefaultX - Math.round(38 * u),
                y: postY,
                r: 22 * u,
                shape: "pill",
                toggle: true,
                rect: Rect(geom.stickDefaultX - Math.round(38 * u) - pw * 0.5, postY - ph * 0.5, pw, ph),
                label: router.crouchToggled ? "起身" : "蹲伏",
                accent: "emerald",
                active: router.crouchToggled || p.player.crouch,
                highlighted: p.scavChase && !p.player.crouch,
                progress: 0,
                dimmed: false,
            });
            buttons.push({
                id: "cover",
                x: geom.stickDefaultX + Math.round(38 * u),
                y: postY,
                r: 22 * u,
                shape: "pill",
                toggle: true,
                rect: Rect(geom.stickDefaultX + Math.round(38 * u) - pw * 0.5, postY - ph * 0.5, pw, ph),
                label: router.slowToggled ? "常步" : "轻步",
                accent: "silk",
                active: router.slowToggled,
                highlighted: false,
                progress: 0,
                dimmed: false,
            });
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
        return bottleCancelCenter;
    },

    drawFrame(deckDraw, padInkDraw, texts, ctx, lastPlay, w, h) {
        const vp = ctx.viewport;
        const topY = vp.stageY + vp.stageH;

        if (topY < h) {
            deckDraw.drawRect(Rect(0, topY, w, h - topY), toColor(PALETTE.inkVoid, 252));
            deckDraw.drawSegment(Vec2(0, topY), Vec2(w, topY), 1.0, toColor(PALETTE.silkDim, 140));
            const labelY = topY + (h - topY) * 0.5;
            texts.put("xs", "向西守望 · 掌机竖屏", vp.safe.left + 12, labelY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.8, 0.88, 0.08);
        }

        if (vp.stageX > 0) {
            deckDraw.drawRect(Rect(0, vp.stageY, vp.stageX, vp.stageH), toColor(PALETTE.inkVoid, 255));
            deckDraw.drawRect(Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), toColor(PALETTE.inkVoid, 255));
        }

        if (vp.deckH > 0) {
            fillVGradRect(deckDraw, 0, 0, w, vp.deckH, toColor(PALETTE.voidDark, 255), toColor(PALETTE.inkWash, 255));
            deckDraw.drawSegment(Vec2(0, vp.deckH), Vec2(w, vp.deckH), 1.2, toColor(PALETTE.silkLine, 165));
            deckDraw.drawSegment(Vec2(18, vp.deckH - 4), Vec2(w - 18, vp.deckH - 4), 0.6, toColor(PALETTE.silkDim, 85));
            drawDiamond(padInkDraw, w * 0.5, vp.deckH, 5, 5, toColor(PALETTE.rouge, 220), 0.9, toColor(PALETTE.silkLine, 180));

            const footY = Math.max(vp.safe.bottom + 14, 16);
            const inOverlayModal = lastPlay !== undefined && (lastPlay.reloadOpen || lastPlay.craftBench.active);
            const hint = inOverlayModal
                ? "直接在上屏点按或一笔划连"
                : (!ctx.gameplayActive || (lastPlay !== undefined && lastPlay.paused)
                    ? "可点上屏菜单或用下方导航键"
                    : (ctx.childMode
                        ? "左摇杆内圈轻步 · 蹲伏/轻步点按切换"
                        : "左摇杆走位 · 点上屏或拖「开火」瞄射"));
            texts.put("xs", hint, w * 0.5, footY, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 0.8, 0.78, 0.06);
        }
    },
};
