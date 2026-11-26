/**
 * 场景核心叙事与互动道具渲染器：
 * - 跨房间共用「红布板车」（木轮、旧红布与停车挡槽）
 * - 战场与村口地面（暴露地面、软土、砖地）
 * - 村口道具（瓶架、桌体、玻璃瓶、抛物线能量轨迹与砖地/软土落点声波预测）
 * - 北塔前的木架提灯
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { CartSpec } from "Script/watch/rooms";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { DepthOcclusion, depthOrder, occlusionTint } from "Script/watch/fe/occlusion";
import {
    PALETTE,
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
        occlusion: DepthOcclusion,
        fadeDt: number,
    ): void {
        this.drawZones(fgDraw, p, cam);
        this.drawMarks(fgDraw, fgGlow, assets, p, cam, time);
        this.drawCart(fgDraw, assets, p, cam, time, occlusion, fadeDt);
        this.drawCraftMaterials(assets, p, cam);
        if (p.phase === "prologue-give" && p.phaseTick >= 12 && p.phaseTick < 36) {
            const x = (p.player.x + p.partner.x) * 0.5;
            const y = p.partner.y + p.partner.h * 0.62;
            const depth = (p.player.depth + p.partner.depth) * 0.5;
            assets.tryPlace("prop_compass", "handover", cam.sx(x), cam.sy(y, depth), cam.len(12), cam.len(12),
                { layer: p.room.depth === undefined ? 6 : depthOrder(depth, 6) });
        }
        if (p.room.key === "village") {
            this.drawVillageProps(fgDraw, fgGlow, assets, p, cam, time);
        }
    }

    private drawCraftMaterials(assets: AssetSlotHost, p: Play, cam: CameraDirector): void {
        for (const pickup of p.pickups) {
            // 兼容包含 B2 工台材料的游戏分支。
            const kind: string = pickup.kind;
            if (pickup.id === "" || (kind !== "wood" && kind !== "bell")) {
                continue;
            }
            const depth = pickup.depth ?? 0;
            const isWood = kind === "wood";
            assets.tryPlace(
                isWood ? "ink_bamboo_slip" : "prop_compass",
                "pickup_" + pickup.id,
                cam.sx(pickup.x), cam.sy(pickup.y + 9, depth),
                cam.len(18), cam.len(isWood ? 7 : 16),
                {
                    angle: isWood ? 65 : 0,
                    color: isWood ? toColor(PALETTE.amber) : toColor(PALETTE.amberCore),
                    layer: p.room.depth === undefined ? 3 : depthOrder(depth, 1),
                },
            );
        }
    }

    private drawZones(
        fgDraw: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.zones.length; i++) {
            const z = p.room.zones[i];
            const x0 = cam.sx(z.x0);
            const x1 = cam.sx(z.x1);
            const y0 = cam.sy(z.y);
            const zw = x1 - x0;

            if (z.tint === 1) {
                const road = p.room.depth;
                const front = cam.sy(z.y, road?.min ?? -3);
                const back = cam.sy(z.y, road?.max ?? 1);
                fgDraw.drawRect(Rect(x0, front, zw, back - front), Color(50, 35, 29, 48));
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
                fgDraw.drawSegment(Vec2(x0, y0 + 4), Vec2(x1, y0 + 4), 1.1, Color(168, 151, 127, 130));
            }
        }
    }

    private drawMarks(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        for (const m of p.room.marks) {
            if (m.kind !== 6) {
                continue;
            }
            const mx = cam.sx(m.x);
            const my = cam.sy(m.y);
            const hookY = my + cam.len(52);
            const armX = mx + cam.len(13);
            const lampY = hookY - cam.len(12);
            const wood = Color(82, 58, 40, 245);
            const joint = Math.max(1, cam.len(2));
            fgDraw.drawSegment(Vec2(mx, my), Vec2(mx, hookY), joint, wood);
            fgDraw.drawSegment(Vec2(mx, hookY), Vec2(armX, hookY), joint, wood);
            fgDraw.drawSegment(Vec2(mx, hookY - cam.len(7)), Vec2(armX - joint, hookY), joint * 0.7, wood);
            if (!assets.tryPlace("prop_lantern", "path_lamp_" + m.x, armX, lampY, cam.len(16), cam.len(20), { layer: 1 })) {
                fgDraw.drawRect(Rect(armX - cam.len(4), lampY - cam.len(7), cam.len(8), cam.len(14)),
                    Color(192, 136, 64, 240), 1.4, wood);
            }
            const flame = 0.91 + Math.sin(time * 3.1) * 0.09;
            fillRadialGlow(fgGlow, armX, lampY, cam.len(23), cam.len(27), Color(239, 182, 106, 46 * flame),
                Color(231, 164, 91, 0), 16);
        }
    }

    private drawCart(
        fgDraw: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        occlusion: DepthOcclusion,
        fadeDt: number,
    ): void {
        const c: CartSpec = p.room.cart;
        if (c.bodyW <= 0) {
            return;
        }
        const depth = c.depth ?? 0;
        const raised = p.room.depth !== undefined;

        // 1. 车辙轨道与停靠窝（dock）
        const lo = Math.min(c.startX, c.endX);
        const hi = Math.max(c.startX, c.endX);
        if (hi - lo > 4) {
            const rx0 = cam.sx(lo);
            const rx1 = cam.sx(hi);
            const ry = cam.sy(c.baseY, depth);
            fgDraw.drawSegment(Vec2(rx0, ry + 1), Vec2(rx1, ry + 1), 1.2, Color(86, 65, 47, 150));
            const dockX = cam.sx(c.endX);
            const width = cam.len(24);
            const lip = cam.len(3);
            fgDraw.drawRect(Rect(dockX - width * 0.5, ry, width, lip), Color(51, 37, 26, 230));
            fgDraw.drawRect(Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), Color(107, 77, 51, 230));
        }

        const axleX = p.cartAxle;
        const cx = cam.sx(axleX);
        const baseY = cam.sy(c.baseY, depth);
        const bw = cam.len(c.bodyW);
        const bh = cam.len(c.bodyH);
        const wr = cam.len(c.wheelR);

        const x0 = cx - bw * 0.5;
        const x1 = cx + bw * 0.5;
        const bodyY0 = baseY + wr * 1.05;
        const bodyY1 = bodyY0 + bh;

        // 车底暗影
        const artWidth = c.bodyW * 1.36;
        const artHeight = (c.wheelR * 2 + c.bodyH) * 0.88;
        const opacity = raised ? occlusion.update("cart", {
            x0: axleX - artWidth * 0.5, x1: axleX + artWidth * 0.5,
            y0: c.baseY, y1: c.baseY + artHeight,
            depth: { min: depth, max: depth + 8 }, passThrough: true,
        }, p, fadeDt) : 1;
        fgDraw.drawEllipse(Vec2(cx, baseY + 2), bw * 0.62, 5, Color(4, 6, 10, 150 * opacity));

        const painted = assets.tryPlace("prop_cart", "cart", cx, baseY, cam.len(artWidth), cam.len(artHeight), {
            layer: raised ? depthOrder(depth, 2) : 2, opacity, color: occlusionTint(opacity),
        });
        if (!painted) {
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
        }

        // 外侧推拉手柄（有精灵贴图时仅从车身外沿引出短柄至握持位，不压过贴图车身）
        const hx = cam.sx(axleX + c.handleOffset);
        const hTop = bodyY1 + cam.len(7);
        const edge = painted
            ? (c.handleOffset < 0 ? cx - cam.len(artWidth * 0.42) : cx + cam.len(artWidth * 0.42))
            : (c.handleOffset < 0 ? x0 : x1);
        const handleSpan = Math.abs(hx - edge);
        if (!painted || handleSpan > cam.len(4)) {
            fgDraw.drawSegment(Vec2(edge, bodyY0 + bh * 0.52), Vec2(hx, hTop - cam.len(4)),
                Math.max(1.8, cam.len(2.4)), toColor(PALETTE.cartWood, 245 * opacity));
            fgDraw.drawSegment(Vec2(hx, hTop - cam.len(5.5)), Vec2(hx, hTop),
                Math.max(2.2, cam.len(3.2)), Color(126, 91, 61, 245 * opacity));
        }

        if (painted) {
            return;
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
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        // 1. 瓶架与架上玻璃瓶（与 rooms.ts h=52 严格对齐）
        const bottle = p.room.bottle;
        if (bottle !== undefined) {
            const bx0 = cam.sx(bottle.x - 16);
            const bx1 = cam.sx(bottle.x + 16);
            const by0 = cam.sy(0);
            const by1 = cam.sy(52);
            const beam = cam.len(3.2);
            const side = Color(78, 57, 41, 255);
            fgDraw.drawRect(Rect(bx0, by0, beam, by1 - by0), side);
            fgDraw.drawRect(Rect(bx1 - beam, by0, beam, by1 - by0), side);
            for (const shelfY of [by0 + (by1 - by0) * 0.46, by1 - beam]) {
                fgDraw.drawRect(Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam),
                    Color(106, 78, 56, 255), 1, Color(56, 42, 34, 240));
            }
            if (!p.hasBottle && p.bottleFly === undefined && p.bottleLandT <= 0) {
                this.drawBottleSprite(fgDraw, assets, "bottle_shelf", cam.sx(bottle.x), cam.sy(56), cam.ppu, 0);
            }
        }

        const arch = p.room.arch;
        const tx0 = cam.sx(arch.x0 - 4);
        const tx1 = cam.sx(arch.x1 + 4);
        const ty0 = cam.sy(arch.y);
        const tyBot = cam.sy(arch.y + arch.h);
        const tyTop = cam.sy(arch.y + arch.h + 6);
        fillVGradRect(fgDraw, tx0 + 6, ty0, tx1 - tx0 - 12, tyBot - ty0,
            Color(9, 10, 15, 165), Color(9, 10, 15, 100));
        if (!assets.tryPlace("prop_table", "village_table", (tx0 + tx1) * 0.5, ty0,
            tx1 - tx0, tyTop - ty0, { layer: 6 })) {
            fgDraw.drawRect(Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), toColor(PALETTE.cartWood));
            fgDraw.drawRect(Rect(tx0 + 2, ty0, 7, tyBot - ty0), toColor(PALETTE.cartWood));
            fgDraw.drawRect(Rect(tx1 - 9, ty0, 7, tyBot - ty0), toColor(PALETTE.cartWood));
        }

        // 3. 手上持瓶 / 飞行中瓶子（瞄准时 child_aim 精灵手里已有瓶子，避免一人双瓶）
        if (p.hasBottle && p.aimHold <= 0) {
            const pl = p.player;
            this.drawBottleSprite(fgDraw, assets, "bottle_held", cam.sx(pl.x + pl.facing * 10), cam.sy(pl.y + pl.h * 0.52), cam.ppu, pl.facing * 0.2);
        }
        if (p.bottleFly !== undefined) {
            this.drawBottleSprite(fgDraw, assets, "bottle_air", cam.sx(p.bottleFly.x), cam.sy(p.bottleFly.y), cam.ppu, time * 14);
        }

        // 4. 持瓶抛物线预览（与后端 bottleAimX/Y 100% 同参数，精准预测落点声响）
        if (p.hasBottle && p.aimHold > 0) {
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
        assets: AssetSlotHost,
        id: string,
        cx: number, cy: number, ppu: number,
        tilt: number,
    ): void {
        const height = Math.max(10, ppu * 10.5);
        if (!assets.tryPlace("prop_bottle", id, cx, cy, height, height, {
            angle: tilt * 180 / Math.PI, layer: 6,
        })) {
            const dx = Math.sin(tilt) * height * 0.4;
            const dy = Math.cos(tilt) * height * 0.5;
            fgDraw.drawSegment(Vec2(cx - dx, cy - dy), Vec2(cx + dx, cy + dy), height * 0.32,
                toColor(PALETTE.amber, 225));
        }
    }
}
