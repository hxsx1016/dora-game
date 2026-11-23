/**
 * 场景核心叙事与互动道具渲染器：
 * - 跨房间共用「红布板车」（旋转辐条轮、金属车架、迎风摆动红布、发光停靠窝）
 * - 战术区域（危险扫描区、软土、砖地、通行线、双人出口区）
 * - 村口道具（瓶架、桌体、玻璃瓶、抛物线能量轨迹与砖地/软土落点声波预测）
 * - 检查点信标、安全锚地标、北塔灯柱
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { CartSpec } from "Script/watch/rooms";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost } from "Script/watch/fe/assets";
import {
    PALETTE,
    drawDiamond,
    fillGradQuad,
    fillRadialGlow,
    fillVGradRect,
    toColor,
} from "Script/watch/fe/theme";

const GRAVITY = 1000;

export class PropsRenderer {
    drawAll(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        this.drawZones(fgDraw, fgGlow, p, cam, time);
        this.drawMarks(fgDraw, fgGlow, p, cam, time);
        this.drawCart(fgDraw, fgGlow, assets, p, cam, time);
        if (p.room.key === "village") {
            this.drawVillageProps(fgDraw, fgGlow, p, cam, time);
        }
    }

    private drawZones(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.zones.length; i++) {
            const z = p.room.zones[i];
            const x0 = cam.sx(z.x0);
            const x1 = cam.sx(z.x1);
            const y0 = cam.sy(z.y);
            const y1 = cam.sy(z.y + z.h);
            const zw = x1 - x0;
            const zh = Math.max(6, y1 - y0);

            if (z.tint === 1) {
                // 危险火力封锁区：艾希风赤红低透明扫描栅格 + 扫描线
                fillVGradRect(fgGlow, x0, y0, zw, zh, Color(255, 36, 70, 42), Color(255, 36, 70, 6));
                fgGlow.drawSegment(Vec2(x0, y0), Vec2(x0, y1), 1.4, toColor(PALETTE.crimson, 145));
                fgGlow.drawSegment(Vec2(x1, y0), Vec2(x1, y1), 1.4, toColor(PALETTE.crimson, 145));
                const scanY = y0 + ((time * 48) % zh);
                fgGlow.drawSegment(Vec2(x0, scanY), Vec2(x1, scanY), 1.2, toColor(PALETTE.crimson, 95));
            } else if (z.tint === 2) {
                // 软土（消音落点）：深褐暗纹，无高光
                fgDraw.drawRect(Rect(x0, y0 - 4, zw, 8), Color(74, 58, 44, 220));
                fgDraw.drawSegment(Vec2(x0, y0 + 2), Vec2(x1, y0 + 2), 1.4, Color(128, 98, 72, 190));
            } else if (z.tint === 3) {
                // 砖地（清脆发声落点）：清晰冷灰砖缝 + 微弱琥珀反光提示可引敌
                fgDraw.drawRect(Rect(x0, y0 - 4, zw, 9), Color(118, 122, 130, 235));
                const bricks = 4;
                let b = 1;
                for (b = 1; b < bricks; b++) {
                    const bx = x0 + (zw * b) / bricks;
                    fgDraw.drawSegment(Vec2(bx, y0 - 4), Vec2(bx, y0 + 5), 1, Color(42, 46, 56, 220));
                }
                const pulse = 0.65 + 0.35 * Math.sin(time * 3.2);
                fgGlow.drawSegment(Vec2(x0, y0 + 5), Vec2(x1, y0 + 5), 1.8, toColor(PALETTE.amber, 165 * pulse));
            } else if (z.tint === 4) {
                // 通行线 / 门洞等待区 / 林边安全区：翡翠冰青光带
                fillVGradRect(fgGlow, x0, y0, zw, Math.min(85, Math.max(24, zh)), Color(84, 232, 168, 48), Color(84, 232, 168, 0));
                fgGlow.drawSegment(Vec2(x0, y0 + 1), Vec2(x1, y0 + 1), 2, toColor(PALETTE.emerald, 190));
            }
        }

        // 检查站双人出口区域地面全息门标（792..928）
        if (p.room.key === "checkpoint") {
            const ex0 = cam.sx(p.ox + 792);
            const ex1 = cam.sx(p.ox + 928);
            const ey = cam.sy(0);
            const col = p.gateOpen ? PALETTE.emerald : PALETTE.cyanDim;
            fillVGradRect(fgGlow, ex0, ey, ex1 - ex0, 74, toColor(col, p.gateOpen ? 68 : 26), Color(col.r, col.g, col.b, 0));
            fgGlow.drawSegment(Vec2(ex0, ey + 2), Vec2(ex1, ey + 2), 2.4, toColor(col, p.gateOpen ? 235 : 130));
        }
    }

    private drawMarks(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.marks.length; i++) {
            const m = p.room.marks[i];
            const mx = cam.sx(m.x);
            const my = cam.sy(m.y);
            const pulse = 0.72 + 0.28 * Math.sin(time * 3.4 + i);

            if (m.kind === 0) {
                // 检查点：纤细全息柱 + 菱形悬浮节点
                const on = p.checkpoint === m.x;
                const col = on ? PALETTE.emerald : PALETTE.cyanDim;
                fgDraw.drawSegment(Vec2(mx, my), Vec2(mx, my + 48), 1.4, toColor(col, on ? 220 : 120));
                drawDiamond(fgGlow, mx, my + 54, 7, 10, toColor(col, on ? 220 : 120), 1.2, toColor(PALETTE.cyanCore, on ? 220 : 90));
                if (on) {
                    fillRadialGlow(fgGlow, mx, my + 54, 30, 30, toColor(PALETTE.emerald, 95), Color(84, 232, 168, 0), 14);
                }
            } else if (m.kind === 1) {
                // 安全锚 / 停靠点 / 关键站位：贴地全息三角信标（不干扰画面主体）
                const col = PALETTE.amber;
                fgGlow.drawSegment(Vec2(mx - 14, my + 2), Vec2(mx + 14, my + 2), 1.8, toColor(col, 165 * pulse));
                drawDiamond(fgGlow, mx, my + 12, 4.5, 4.5, toColor(col, 185 * pulse));
            } else if (m.kind === 6) {
                // 城外墙根尽头：北塔指路灯柱
                const topY = my + cam.len(42);
                fgDraw.drawSegment(Vec2(mx, my), Vec2(mx, topY), 2.5, toColor(PALETTE.steelLight));
                fgDraw.drawRect(Rect(mx - 7, topY, 14, 16), toColor(PALETTE.steelDark), 1.4, toColor(PALETTE.amber, 220));
                fgGlow.drawDot(Vec2(mx, topY + 8), 4.2, toColor(PALETTE.amberCore));
                fillRadialGlow(fgGlow, mx, topY + 8, 54 * pulse, 54 * pulse, Color(255, 222, 142, 115), Color(255, 180, 82, 0), 18);
                fillRadialGlow(fgGlow, mx, my + 4, 48, 12, Color(255, 210, 128, 65), Color(255, 180, 82, 0), 14);
            }
        }
    }

    private drawCart(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        const c: CartSpec = p.room.cart;
        if (c.bodyW <= 0) {
            return;
        }

        // 1. 车辙轨道与停靠窝（dock）
        const lo = Math.min(c.startX, c.endX);
        const hi = Math.max(c.startX, c.endX);
        if (hi - lo > 4) {
            const rx0 = cam.sx(lo);
            const rx1 = cam.sx(hi);
            const ry = cam.sy(c.baseY);
            fgDraw.drawSegment(Vec2(rx0, ry + 2), Vec2(rx1, ry + 2), 1.2, toColor(PALETTE.steelLight, 140));
            const dockX = cam.sx(c.endX);
            const dockCol = p.cartDocked ? PALETTE.emerald : PALETTE.amber;
            fgDraw.drawRect(Rect(dockX - cam.len(12), ry - 4, cam.len(24), 5), toColor(PALETTE.voidDark));
            fgGlow.drawSegment(Vec2(dockX - cam.len(14), ry + 1), Vec2(dockX + cam.len(14), ry + 1), 2.4, toColor(dockCol, 220));
            drawDiamond(fgGlow, dockX, ry + 12, 5, 5, toColor(dockCol, p.cartDocked ? 235 : 140));
        }

        const axleX = p.cartAxle;
        const cx = cam.sx(axleX);
        const baseY = cam.sy(c.baseY);
        const bw = cam.len(c.bodyW);
        const bh = cam.len(c.bodyH);
        const wr = cam.len(c.wheelR);

        // 若完整前端分支挂接了板车 PNG，则用外部贴图替换
        if (assets.tryPlace("prop_cart", "cart_" + p.room.key, cx, baseY, bw * 1.4, (c.wheelR + c.bodyH + 18) * cam.ppu, 1, 1)) {
            return;
        }

        const x0 = cx - bw * 0.5;
        const x1 = cx + bw * 0.5;
        const bodyY0 = baseY + wr * 1.05;
        const bodyY1 = bodyY0 + bh;

        // 车底暗影
        fgDraw.drawEllipse(Vec2(cx, baseY + 2), bw * 0.62, 5, Color(4, 6, 10, 150));

        // 车身木钢复合车斗
        fillVGradRect(fgDraw, x0, bodyY0, bw, bh, Color(48, 32, 28, 255), toColor(PALETTE.cartWood));
        fgDraw.drawRect(Rect(x0, bodyY0, bw, bh), Color(0, 0, 0, 0), 1.6, toColor(PALETTE.cartMetal, 220));
        // 车斗加固铁条
        fgDraw.drawSegment(Vec2(x0 + bw * 0.33, bodyY0), Vec2(x0 + bw * 0.33, bodyY1), 1.4, toColor(PALETTE.cartMetal, 180));
        fgDraw.drawSegment(Vec2(x0 + bw * 0.67, bodyY0), Vec2(x0 + bw * 0.67, bodyY1), 1.4, toColor(PALETTE.cartMetal, 180));
        fgDraw.drawSegment(Vec2(x0 - 2, bodyY1), Vec2(x1 + 2, bodyY1), 2.2, toColor(PALETTE.rimSilver, 220));

        // 旋转双轮（按位移真实滚动）
        const wheelSpin = -(axleX - c.startX) / Math.max(1, c.wheelR);
        const wxA = x0 + bw * 0.24;
        const wxB = x1 - bw * 0.24;
        const wy = baseY + wr;
        this.drawWheel(fgDraw, wxA, wy, wr, wheelSpin);
        this.drawWheel(fgDraw, wxB, wy, wr, wheelSpin);

        // 外侧推拉手柄
        const hx = cam.sx(axleX + c.handleOffset);
        const hTop = bodyY1 + cam.len(18);
        const gripReady = p.gripping || p.focusCart || Math.abs(p.player.x - (axleX + c.handleOffset)) < 70;
        const handleCol = p.gripping ? PALETTE.cyan : (gripReady ? PALETTE.amber : PALETTE.cartMetal);
        fgDraw.drawSegment(Vec2(hx, bodyY0 + 4), Vec2(hx, hTop), 2.6, toColor(handleCol));
        fgDraw.drawSegment(Vec2(c.handleOffset < 0 ? x0 : x1, bodyY0 + bh * 0.5), Vec2(hx, bodyY0 + bh * 0.55), 2.2, toColor(PALETTE.cartMetal));
        fgGlow.drawDot(Vec2(hx, hTop), gripReady ? 4.8 : 3.2, toColor(handleCol, gripReady ? 245 : 160));
        if (gripReady && !p.cartDocked) {
            fillRadialGlow(fgGlow, hx, hTop, 22, 22, toColor(handleCol, 95), Color(handleCol.r, handleCol.g, handleCol.b, 0), 12);
        }

        // 标志性猩红布条（系在左侧，绝不镜像，随风微摆）
        const clothAnchorX = c.clothSide < 0 ? x0 + 3 : x1 - 3;
        const wave = Math.sin(time * 3.4) * 5 + (p.gripping ? -p.player.facing * 6 : 0);
        const wave2 = Math.cos(time * 2.8) * 3.5;
        const clothH = cam.len(26);
        const clothW = cam.len(14);
        fgDraw.drawPolygon([
            Vec2(clothAnchorX - 3, bodyY1 + 2),
            Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2),
            Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55),
            Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH),
            Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62),
        ], toColor(PALETTE.clothRed));
        // 红布受光亮边（城外一眼锁定红布）
        fgDraw.drawSegment(
            Vec2(clothAnchorX - 2, bodyY1 + 1),
            Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH),
            1.6,
            toColor(PALETTE.clothRedHighlight, 220),
        );
        fillRadialGlow(fgGlow, clothAnchorX, bodyY1 - clothH * 0.35, 32, 32, Color(235, 42, 62, 54), Color(235, 42, 62, 0), 14);
    }

    private drawWheel(draw: DrawNode.Type, cx: number, cy: number, r: number, spin: number): void {
        draw.drawCircle(Vec2(cx, cy), r, Color(24, 28, 36, 255));
        draw.drawRing(Vec2(cx, cy), r * 0.72, r, Color(0, 0, 0, 0), 1.6, toColor(PALETTE.cartMetal));
        let k = 0;
        for (k = 0; k < 4; k++) {
            const a = spin + (k * Math.PI) / 4;
            draw.drawSegment(
                Vec2(cx - Math.cos(a) * r * 0.72, cy - Math.sin(a) * r * 0.72),
                Vec2(cx + Math.cos(a) * r * 0.72, cy + Math.sin(a) * r * 0.72),
                1.2,
                toColor(PALETTE.steelLight, 190),
            );
        }
        draw.drawDot(Vec2(cx, cy), Math.max(2.2, r * 0.18), toColor(PALETTE.rimSilver));
    }

    private drawVillageProps(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        // 1. 瓶架与架上玻璃瓶
        const bottle = p.room.bottle;
        if (bottle !== undefined) {
            const bx0 = cam.sx(bottle.x - 16);
            const bx1 = cam.sx(bottle.x + 16);
            const by0 = cam.sy(0);
            const by1 = cam.sy(64);
            fgDraw.drawRect(Rect(bx0, by0, bx1 - bx0, by1 - by0), Color(32, 36, 46, 235), 1.2, toColor(PALETTE.steelLight, 180));
            // 两层木板隔层
            fgDraw.drawSegment(Vec2(bx0 + 2, by0 + (by1 - by0) * 0.48), Vec2(bx1 - 2, by0 + (by1 - by0) * 0.48), 2, toColor(PALETTE.cartWood));
            fgDraw.drawSegment(Vec2(bx0, by1), Vec2(bx1, by1), 2.2, toColor(PALETTE.rimSilver, 210));
            if (!p.hasBottle && p.bottleFly === undefined && p.bottleLandT <= 0) {
                this.drawBottleSprite(fgDraw, fgGlow, cam.sx(bottle.x), cam.sy(65), cam.ppu, 0, true, time);
            }
        }

        // 2. 村口木桌（桌下净高 44，304..416）
        const tx0 = cam.sx(300);
        const tx1 = cam.sx(420);
        const ty0 = cam.sy(0);
        const tyBot = cam.sy(44);
        const tyTop = cam.sy(51);
        // 桌下隐蔽暗影
        fillVGradRect(fgDraw, tx0 + 6, ty0, tx1 - tx0 - 12, tyBot - ty0, Color(5, 7, 12, 185), Color(5, 7, 12, 110));
        // 桌面与桌腿
        fgDraw.drawRect(Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), Color(68, 52, 42, 255), 1.3, toColor(PALETTE.rimSilver, 185));
        fgDraw.drawRect(Rect(tx0 + 2, ty0, 7, tyBot - ty0), Color(48, 38, 32, 255));
        fgDraw.drawRect(Rect(tx1 - 9, ty0, 7, tyBot - ty0), Color(48, 38, 32, 255));
        fgDraw.drawSegment(Vec2(tx0, tyTop), Vec2(tx1, tyTop), 1.8, toColor(PALETTE.amber, 165));

        // 3. 手上持瓶 / 飞行中瓶子
        if (p.hasBottle) {
            const pl = p.player;
            this.drawBottleSprite(fgDraw, fgGlow, cam.sx(pl.x + pl.facing * 12), cam.sy(pl.y + pl.h * 0.56), cam.ppu, pl.facing * 0.2, false, time);
        }
        if (p.bottleFly !== undefined) {
            this.drawBottleSprite(fgDraw, fgGlow, cam.sx(p.bottleFly.x), cam.sy(p.bottleFly.y), cam.ppu, time * 14, true, time);
        }

        // 4. 持瓶抛物线预览（与后端 bottleAimX/Y 100% 同参数，精准预测落点声响）
        if (p.hasBottle) {
            const pl = p.player;
            let endX = p.bottleAimX;
            let endY = p.bottleAimY;
            if (endX < 0) {
                const wAim = cam.screenToWorld(p.aimX, p.aimY);
                endX = wAim.x;
                endY = 0;
            }
            const dir = endX >= pl.x ? 1 : -1;
            const x0 = pl.x + dir * 10;
            const y0 = pl.y + pl.h * 0.7;
            const T = 0.62;
            const vx = (endX - x0) / T;
            const vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T;

            const isBrick = p.room.brickX !== undefined && Math.abs(endX - p.room.brickX) <= 34;
            const isSoft = p.room.softX !== undefined && Math.abs(endX - p.room.softX) <= 34;
            const arcCol = isBrick ? PALETTE.amber : (isSoft ? PALETTE.textDim : PALETTE.emerald);
            const activeAim = p.aimHold > 0.01;

            const steps = 18;
            let k = 1;
            for (k = 1; k <= steps; k++) {
                const tt = (k / steps) * T;
                const wx = x0 + vx * tt;
                const wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt;
                const sx = cam.sx(wx);
                const sy = cam.sy(wy);
                const alpha = (activeAim ? 225 : 135) * (0.45 + 0.55 * (k / steps));
                fgGlow.drawDot(Vec2(sx, sy), activeAim ? 3.2 : 2.2, toColor(arcCol, alpha));
            }
            // 落点声波影响圈
            const lx = cam.sx(endX);
            const ly = cam.sy(endY + 2);
            const pulse = 0.85 + 0.15 * Math.sin(time * 6);
            fgGlow.drawRing(Vec2(lx, ly), 8, 11, Color(0, 0, 0, 0), 1.6, toColor(arcCol, activeAim ? 245 : 165));
            if (isBrick) {
                fgGlow.drawRing(Vec2(lx, ly), 28 * pulse, 30 * pulse, Color(0, 0, 0, 0), 1.2, toColor(PALETTE.amber, activeAim ? 175 : 95));
                fillRadialGlow(fgGlow, lx, ly, 36, 14, Color(242, 188, 96, activeAim ? 95 : 48), Color(242, 188, 96, 0), 14);
            }
        }
    }

    private drawBottleSprite(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        cx: number, cy: number, ppu: number,
        tilt: number, highlight: boolean, time: number,
    ): void {
        const bw = Math.max(5, ppu * 3.2);
        const bh = Math.max(12, ppu * 8.5);
        const dx = Math.sin(tilt) * bh * 0.4;
        const dy = Math.cos(tilt) * bh * 0.5;
        fgDraw.drawSegment(Vec2(cx - dx, cy - dy), Vec2(cx + dx, cy + dy), bw * 0.52, toColor(PALETTE.emerald, 225));
        fgDraw.drawSegment(Vec2(cx + dx * 0.7, cy + dy * 0.7), Vec2(cx + dx * 1.25, cy + dy * 1.25), bw * 0.28, toColor(PALETTE.cyanCore, 230));
        if (highlight) {
            const p = 0.7 + 0.3 * Math.sin(time * 4.5);
            fillRadialGlow(fgGlow, cx, cy, 18 * p, 18 * p, toColor(PALETTE.emerald, 85 * p), Color(84, 232, 168, 0), 12);
        }
    }
}
