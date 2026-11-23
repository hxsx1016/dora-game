/**
 * 4 层视差 2.5D 艾希风格舞台渲染器（远景天际 / 中景工业骨架 / 逻辑实体平面 / 近景压边与暗角）。
 *
 * 所有建筑实体严格读取 RoomSpec 世界坐标，确保碰撞盒与视觉 1:1 吻合；
 * 同时通过多层切面、金属高光顶边、体积探照灯、远方北塔灯标与底部雾气，
 * 在零外部贴图前提下实现冷峻高对比度的《艾希》式工业废土氛围。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { SolidSpec } from "Script/watch/rooms";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import {
    PALETTE,
    RoomTheme,
    drawHazardStripes,
    fillChamferBox,
    fillGradQuad,
    fillRadialGlow,
    fillVGradRect,
    lerpRGBA,
    themeOf,
    toColor,
} from "Script/watch/fe/theme";

/** 确定性伪随机（避免跨帧闪烁） */
function hash01(seed: number): number {
    const x = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
    return x - Math.floor(x);
}

/** 根据房间名取一个稳定数值种子 */
function roomSeed(key: string): number {
    let h = 17;
    let i = 0;
    for (i = 0; i < key.length; i++) {
        h = (h * 31 + key.charCodeAt(i)) % 9973;
    }
    return h;
}

export class StageRenderer {
    /** 绘制背景三层（天穹 + 月亮/探照灯/北塔灯标 + 远景 + 中景 + 底部雾气） */
    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        const w = cam.viewW;
        const h = cam.viewH;
        const theme = themeOf(p.room.key);
        const seed = roomSeed(p.room.key);

        // 1. 多段垂直渐变天穹
        const splitY = h * 0.46;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(theme.skyMid), toColor(theme.skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(theme.skyHorizon), toColor(theme.skyMid));

        // 2. 冷月与大气晕染
        if (theme.showMoon) {
            const mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015;
            const my = h * theme.moonYFrac;
            const mr = Math.max(18, h * 0.044);
            fillRadialGlow(bgGlow, mx, my, mr * 6.2, mr * 6.2, Color(140, 200, 255, 28), Color(20, 40, 80, 0), 22);
            fillRadialGlow(bgGlow, mx, my, mr * 2.4, mr * 2.4, Color(200, 232, 255, 64), Color(80, 140, 210, 0), 18);
            bgDraw.drawCircle(Vec2(mx, my), mr, Color(224, 238, 252, 230));
            // 轻微月面斜切暗弧，增加冷峻图形感
            bgDraw.drawCircle(Vec2(mx + mr * 0.28, my + mr * 0.16), mr * 0.84, toColor(theme.skyTop, 110));
        }

        // 3. 远景外挂生图槽位（完整前端分支若挂载 PNG 将自动启用）
        const farSlot = ("bgFar_" + p.room.key) as AssetSlotKey;
        const hasFarArt = assets.tryPlace(farSlot, "stage_far_" + p.room.key, w * 0.5, 0, w, h, 1, 1);

        if (!hasFarArt) {
            // 扫掠体积探照灯（城市/城门段，强化 ICEY 反乌托邦监视压迫感）
            if (theme.showSearchlights) {
                this.drawSearchlights(bgGlow, w, h, cam, theme, time, seed);
            }

            // 远景建筑剪影 / 森林山脊（0.20x 视差）
            if (p.room.key === "forest") {
                this.drawFarForest(bgDraw, w, h, cam, theme, seed);
            } else {
                this.drawFarCity(bgDraw, bgGlow, w, h, cam, theme, seed);
            }

            // 孩子线远方北塔灯塔（地平线右端永恒的视觉信标）
            if (theme.showTowerBeacon) {
                this.drawDistantNorthTower(bgDraw, bgGlow, w, h, cam, p, time);
            }
        }

        // 4. 中景工业骨架 / 破损街灯 / 垂落电缆（0.48x 视差）
        const midSlot = ("bgMid_" + p.room.key) as AssetSlotKey;
        const hasMidArt = assets.tryPlace(midSlot, "stage_mid_" + p.room.key, w * 0.5, 0, w, h, 1, 1);
        if (!hasMidArt) {
            if (p.room.key === "forest") {
                this.drawMidForest(bgDraw, bgGlow, w, h, cam, theme, time, seed);
            } else {
                this.drawMidArchitecture(bgDraw, bgGlow, w, h, cam, theme, time, seed);
            }
        }

        // 5. 底部大气深度雾气（把背景与逻辑前景锐利切开，艾希经典景深手法）
        const fogH = h * 0.38;
        fillVGradRect(
            bgGlow,
            0,
            cam.groundScreenY - 10,
            w,
            fogH,
            toColor(theme.fogBottom),
            Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0),
        );
    }

    /** 标题菜单专用动态背景（无需 Play 实例即可直接绘制高氛围冷月废墟舞台） */
    drawMenuBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        time: number,
    ): void {
        const theme = themeOf("checkpoint");
        const splitY = h * 0.44;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(theme.skyMid), toColor(theme.skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(theme.skyHorizon), toColor(theme.skyMid));

        // 巨大冷月与光晕（左移与右侧北塔形成对角构图，绝不重叠）
        const mx = w * 0.61;
        const my = h * 0.74;
        const mr = h * 0.082;
        fillRadialGlow(bgGlow, mx, my, mr * 5.2, mr * 5.2, Color(86, 210, 255, 34), Color(10, 24, 52, 0), 24);
        fillRadialGlow(bgGlow, mx, my, mr * 2.1, mr * 2.1, Color(190, 240, 255, 76), Color(40, 120, 190, 0), 20);
        bgDraw.drawCircle(Vec2(mx, my), mr, Color(228, 242, 255, 235));
        bgDraw.drawCircle(Vec2(mx + mr * 0.25, my + mr * 0.14), mr * 0.86, Color(10, 18, 34, 125));

        // 探照灯光锥
        let s = 0;
        for (s = 0; s < 3; s++) {
            const bx = w * (0.36 + s * 0.24);
            const sway = Math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26;
            const ang = Math.PI * 0.5 + sway - 0.12;
            const len = h * 1.15;
            const spread = 0.085 + s * 0.015;
            const x1 = bx + Math.cos(ang - spread) * len;
            const y1 = Math.sin(ang - spread) * len;
            const x2 = bx + Math.cos(ang + spread) * len;
            const y2 = Math.sin(ang + spread) * len;
            const baseCol = s === 1 ? Color(255, 58, 92, 34) : Color(76, 214, 255, 36);
            const tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0);
            bgGlow.drawVertices([
                [Vec2(bx, h * 0.15), baseCol],
                [Vec2(x1, y1), tipCol],
                [Vec2(x2, y2), tipCol],
            ]);
        }

        // 远景巨构废墟剪影
        const groundY = h * 0.19;
        let i = 0;
        for (i = 0; i < 16; i++) {
            const bx = i * (w / 14) - 20 + Math.sin(time * 0.08) * 6;
            const bw = 54 + hash01(i * 13 + 3) * 86;
            const bh = h * (0.20 + hash01(i * 29 + 7) * 0.34);
            const cut = 12 + hash01(i * 19) * 20;
            bgDraw.drawPolygon([
                Vec2(bx, groundY),
                Vec2(bx + bw, groundY),
                Vec2(bx + bw, groundY + bh - cut),
                Vec2(bx + bw - cut, groundY + bh),
                Vec2(bx, groundY + bh),
            ], Color(10, 16, 28, 255));
            // 冷光窗口缝
            if (hash01(i * 41 + 5) > 0.45) {
                const wy = groundY + bh * 0.65;
                bgGlow.drawSegment(Vec2(bx + 10, wy), Vec2(bx + bw - 14, wy), 1.2, Color(72, 224, 255, 95));
            }
        }

        // 远景北塔尖碑（右侧标志性视觉，与左上方冷月遥相呼应）
        const tx = w * 0.83;
        const ty0 = groundY;
        const ty1 = h * 0.62;
        bgDraw.drawPolygon([
            Vec2(tx - 26, ty0),
            Vec2(tx + 26, ty0),
            Vec2(tx + 11, ty1),
            Vec2(tx - 11, ty1),
        ], Color(15, 24, 40, 255), 1.2, Color(58, 86, 118, 140));
        bgDraw.drawSegment(Vec2(tx, ty0 + 24), Vec2(tx, ty1 - 12), 1.4, Color(242, 188, 96, 85));
        bgDraw.drawSegment(Vec2(tx, ty1), Vec2(tx, ty1 + 42), 2.2, Color(165, 212, 248, 210));
        const pulse = 0.78 + 0.22 * Math.sin(time * 2.4);
        fillRadialGlow(bgGlow, tx, ty1 + 42, 74 * pulse, 74 * pulse, Color(255, 222, 146, 130), Color(255, 180, 90, 0), 20);
        bgGlow.drawDot(Vec2(tx, ty1 + 42), 5.0, Color(255, 248, 224, 255));

        // 底部冰青地面与透视线
        fillVGradRect(bgDraw, 0, 0, w, groundY, Color(6, 9, 16, 255), Color(16, 24, 38, 255));
        bgDraw.drawSegment(Vec2(0, groundY), Vec2(w, groundY), 2, Color(76, 220, 255, 180));
        fillVGradRect(bgGlow, 0, groundY, w, h * 0.24, Color(42, 130, 182, 52), Color(20, 60, 100, 0));

        // 右下双人英雄逆光剪影（周戍冰青轮廓 + 小满暖金斗篷）
        const sx = w * 0.64;
        fillRadialGlow(bgGlow, sx + 38, groundY + 75, 128, 92, Color(52, 178, 232, 42), Color(20, 60, 110, 0), 18);
        // 周戍：风衣下摆 + V 形装甲肩 + 步枪 + 冰青目镜光带
        bgDraw.drawPolygon([
            Vec2(sx - 36, groundY + 12),
            Vec2(sx + 10, groundY + 18),
            Vec2(sx + 16, groundY + 124),
            Vec2(sx - 18, groundY + 124),
        ], Color(10, 16, 28, 255), 1.3, Color(76, 210, 255, 145));
        bgDraw.drawSegment(Vec2(sx - 6, groundY + 48), Vec2(sx - 12, groundY + 2), 6, Color(10, 16, 28, 255));
        bgDraw.drawSegment(Vec2(sx + 6, groundY + 48), Vec2(sx + 14, groundY + 2), 6, Color(14, 22, 36, 255));
        bgDraw.drawPolygon([
            Vec2(sx - 20, groundY + 120),
            Vec2(sx + 20, groundY + 122),
            Vec2(sx + 16, groundY + 132),
            Vec2(sx - 16, groundY + 130),
        ], Color(208, 236, 252, 240));
        bgDraw.drawCircle(Vec2(sx + 2, groundY + 146), 13, Color(14, 22, 36, 255));
        bgDraw.drawArc(Vec2(sx + 2, groundY + 146), 13.5, 30, 165, 2.0, Color(216, 240, 255, 230));
        bgGlow.drawSegment(Vec2(sx + 4, groundY + 148), Vec2(sx + 17, groundY + 150), 2.6, Color(86, 240, 255, 255));
        bgDraw.drawSegment(Vec2(sx + 4, groundY + 104), Vec2(sx + 46, groundY + 94), 3.4, Color(34, 52, 74, 255));
        bgGlow.drawSegment(Vec2(sx + 16, groundY + 102), Vec2(sx + 44, groundY + 95), 1.2, Color(86, 236, 255, 200));

        // 小满：暖琥珀尖兜帽斗篷 + 飘带围巾 + 指南针微光
        const cx = w * 0.725;
        bgDraw.drawPolygon([
            Vec2(cx - 20, groundY + 14),
            Vec2(cx + 18, groundY + 14),
            Vec2(cx + 12, groundY + 84),
            Vec2(cx - 12, groundY + 84),
        ], Color(188, 142, 78, 238), 1.4, Color(252, 232, 192, 225));
        bgDraw.drawSegment(Vec2(cx - 5, groundY + 24), Vec2(cx - 6, groundY + 2), 4.2, Color(28, 24, 30, 255));
        bgDraw.drawSegment(Vec2(cx + 5, groundY + 24), Vec2(cx + 6, groundY + 2), 4.2, Color(38, 32, 38, 255));
        bgDraw.drawCircle(Vec2(cx + 1, groundY + 95), 11, Color(238, 220, 194, 250));
        bgDraw.drawPolygon([
            Vec2(cx - 15, groundY + 84),
            Vec2(cx - 10, groundY + 108),
            Vec2(cx + 6, groundY + 107),
            Vec2(cx - 4, groundY + 84),
        ], Color(156, 114, 62, 245));
        bgGlow.drawSegment(Vec2(cx - 8, groundY + 82), Vec2(cx - 30, groundY + 64), 2.8, Color(252, 230, 178, 220));
        fillRadialGlow(bgGlow, cx + 10, groundY + 56, 30, 30, Color(255, 214, 130, 115), Color(250, 180, 70, 0), 16);
        bgGlow.drawDot(Vec2(cx + 10, groundY + 56), 3.2, Color(255, 246, 220, 255));
    }

    /** 绘制逻辑平面建筑（地板、悬空平台、建筑实体、拱洞、台阶、城门闸门） */
    drawPlayableWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        const theme = themeOf(p.room.key);

        // 1. 地面与悬空台面
        this.drawFloors(fgDraw, fgGlow, p, cam, theme);

        // 2. 台阶（建筑石阶 / 森林矮台）
        this.drawStairs(fgDraw, fgGlow, p, cam, theme);

        // 3. 实体（按标签类型走专属 ICEY 工业/叙事外观）
        this.drawSolids(fgDraw, fgGlow, p, cam, theme, time);

        // 4. 城门动态降落重型闸门（随 45 秒守点与关门阶段真实下压）
        if (p.room.key === "gate") {
            this.drawGateShutter(fgDraw, fgGlow, p, cam, time);
        }

        // 5. 低拱洞 / 村口桌下净空
        this.drawArch(fgDraw, fgGlow, p, cam, theme);
    }

    /** 绘制近景压边与电影暗角（绘制在角色和特效之后、HUD 之前） */
    drawForegroundFraming(
        fgDraw: DrawNode.Type,
        w: number,
        h: number,
        p: Play,
        cam: CameraDirector,
    ): void {
        const seed = roomSeed(p.room.key);
        // 极低矮前景碎块/钢梁压边（1.26x 视差，不遮挡地面角色脚底，拉出舞台纵深）
        const parallax = -cam.x * 1.26 * (cam.ppu * 0.45);
        const span = 520;
        const startIdx = Math.floor((-parallax - 200) / span);
        let idx = startIdx;
        for (idx = startIdx; idx <= startIdx + 4; idx++) {
            const x = idx * span + parallax;
            const r = hash01(seed + idx * 17);
            const bw = 70 + r * 90;
            const bh = 28 + hash01(seed + idx * 31) * 34;
            fgDraw.drawPolygon([
                Vec2(x, 0),
                Vec2(x + bw, 0),
                Vec2(x + bw - 18, bh),
                Vec2(x + 12, bh * 0.72),
            ], Color(4, 6, 11, 225));
        }

        // 柔和电影暗角（顶部与底部微暗渐变，聚焦主体与字幕）
        fillVGradRect(fgDraw, 0, h - h * 0.16, w, h * 0.16, Color(4, 6, 12, 0), Color(4, 6, 12, 138));
        fillVGradRect(fgDraw, 0, 0, w, h * 0.13, Color(4, 6, 12, 185), Color(4, 6, 12, 0));
    }

    private drawSearchlights(
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        time: number,
        seed: number,
    ): void {
        const count = 3;
        let i = 0;
        for (i = 0; i < count; i++) {
            const anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260);
            const bx = anchor < -120 ? anchor + w + 260 : anchor;
            const by = cam.groundScreenY * 0.85;
            const sway = Math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32;
            const ang = Math.PI * 0.5 + sway;
            const len = h * 1.15;
            const halfSpread = 0.065 + (i % 2) * 0.025;
            const x1 = bx + Math.cos(ang - halfSpread) * len;
            const y1 = by + Math.sin(ang - halfSpread) * len;
            const x2 = bx + Math.cos(ang + halfSpread) * len;
            const y2 = by + Math.sin(ang + halfSpread) * len;
            const c0 = toColor(theme.beamColor);
            const c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0);
            bgGlow.drawVertices([
                [Vec2(bx, by), c0],
                [Vec2(x1, y1), c1],
                [Vec2(x2, y2), c1],
            ]);
        }
    }

    private drawFarCity(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        seed: number,
    ): void {
        const baseY = cam.groundScreenY - 8;
        const shift = -cam.x * 0.20 * cam.ppu;
        const colW = 108;
        const first = Math.floor((-shift - colW) / colW);
        const count = Math.ceil(w / colW) + 3;
        let i = 0;
        for (i = 0; i < count; i++) {
            const idx = first + i;
            const r1 = hash01(seed + idx * 13.7);
            const r2 = hash01(seed + idx * 29.3);
            const r3 = hash01(seed + idx * 47.1);
            const x = idx * colW + shift;
            const bw = colW * (0.68 + r1 * 0.44);
            const bh = h * (0.18 + r2 * 0.38);
            const cut = r3 > 0.5 ? 16 + r1 * 22 : 0;

            bgDraw.drawPolygon([
                Vec2(x, baseY),
                Vec2(x + bw, baseY),
                Vec2(x + bw, baseY + bh - cut),
                Vec2(x + bw - cut, baseY + bh),
                Vec2(x, baseY + bh),
            ], toColor(theme.farBuilding));

            // 屋顶天线 / 破损钢架
            if (r3 > 0.62) {
                const ax = x + bw * 0.25;
                bgDraw.drawSegment(Vec2(ax, baseY + bh), Vec2(ax, baseY + bh + 32), 1.2, toColor(theme.farBuilding));
                if (r1 > 0.6) {
                    bgGlow.drawDot(Vec2(ax, baseY + bh + 32), 2.2, toColor(theme.accent, 145));
                }
            }
            // 极稀疏冷光灯缝
            if (r2 > 0.55) {
                const wy = baseY + bh * (0.52 + r1 * 0.25);
                bgGlow.drawSegment(Vec2(x + 12, wy), Vec2(x + bw - 14, wy), 1.1, toColor(theme.accent, 64));
            }
        }
    }

    private drawFarForest(
        bgDraw: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        seed: number,
    ): void {
        const baseY = cam.groundScreenY - 8;
        const shift = -cam.x * 0.22 * cam.ppu;
        const step = 76;
        const first = Math.floor((-shift - step) / step);
        const count = Math.ceil(w / step) + 4;
        let i = 0;
        for (i = 0; i < count; i++) {
            const idx = first + i;
            const r1 = hash01(seed + idx * 11.3);
            const r2 = hash01(seed + idx * 23.9);
            const cx = idx * step + shift;
            const tw = 34 + r1 * 38;
            const th = h * (0.24 + r2 * 0.34);
            // 尖锐针叶树剪影（三层叠加）
            bgDraw.drawPolygon([
                Vec2(cx - tw, baseY),
                Vec2(cx + tw, baseY),
                Vec2(cx, baseY + th),
            ], toColor(theme.farBuilding));
            bgDraw.drawPolygon([
                Vec2(cx - tw * 0.72, baseY + th * 0.32),
                Vec2(cx + tw * 0.72, baseY + th * 0.32),
                Vec2(cx, baseY + th * 1.12),
            ], toColor(theme.farBuilding));
        }
    }

    private drawMidArchitecture(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        time: number,
        seed: number,
    ): void {
        const baseY = cam.groundScreenY - 4;
        const shift = -cam.x * 0.48 * cam.ppu;
        const bay = 240;
        const first = Math.floor((-shift - bay) / bay);
        const count = Math.ceil(w / bay) + 3;
        const col = toColor(theme.midBuilding);
        const edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170);

        let i = 0;
        for (i = 0; i < count; i++) {
            const idx = first + i;
            const r = hash01(seed + idx * 37.3);
            const x = idx * bay + shift;
            const colH = h * (0.34 + r * 0.24);
            const pw = 22 + r * 16;

            // 中景工业立柱 + X 钢桁架
            bgDraw.drawRect(Rect(x, baseY, pw, colH), col);
            bgDraw.drawSegment(Vec2(x + pw, baseY), Vec2(x + pw, baseY + colH), 1, edge);
            if (r > 0.35) {
                const beamY = baseY + colH * 0.76;
                bgDraw.drawSegment(Vec2(x + pw, beamY), Vec2(x + bay, beamY), 4, col);
                bgDraw.drawSegment(Vec2(x + pw, beamY - 22), Vec2(x + bay * 0.5, beamY), 1.4, edge);
                bgDraw.drawSegment(Vec2(x + bay * 0.5, beamY), Vec2(x + bay, beamY - 22), 1.4, edge);
            }

            // 垂落电缆弧线
            bgDraw.drawQuadraticBezier(
                Vec2(x + pw * 0.5, baseY + colH * 0.88),
                Vec2(x + bay * 0.5, baseY + colH * 0.62 + Math.sin(time * 1.4 + idx) * 3),
                Vec2(x + bay + pw * 0.5, baseY + colH * 0.85),
                1.0,
                Color(12, 18, 28, 180),
            );

            // 破损街灯与微弱光锥（间隔出现，避免过亮）
            if ((idx & 1) === 0) {
                const lx = x + bay * 0.52;
                const ly = baseY + h * 0.31;
                bgDraw.drawSegment(Vec2(lx, baseY), Vec2(lx, ly), 2.2, col);
                bgDraw.drawSegment(Vec2(lx, ly), Vec2(lx + 18, ly - 4), 2, col);
                const flicker = 0.84 + 0.16 * Math.sin(time * 5.2 + idx * 3.1);
                const lc = theme.accent;
                bgGlow.drawDot(Vec2(lx + 18, ly - 5), 3.2, toColor(lc, 210 * flicker));
                fillRadialGlow(bgGlow, lx + 18, ly - 5, 36, 36, toColor(lc, 54 * flicker), Color(lc.r, lc.g, lc.b, 0), 14);
                bgGlow.drawVertices([
                    [Vec2(lx + 18, ly - 6), toColor(lc, 38 * flicker)],
                    [Vec2(lx - 42, baseY), Color(lc.r, lc.g, lc.b, 0)],
                    [Vec2(lx + 78, baseY), Color(lc.r, lc.g, lc.b, 0)],
                ]);
            }
        }
    }

    private drawMidForest(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        time: number,
        seed: number,
    ): void {
        const baseY = cam.groundScreenY - 4;
        const shift = -cam.x * 0.52 * cam.ppu;
        const span = 156;
        const first = Math.floor((-shift - span) / span);
        const count = Math.ceil(w / span) + 3;
        const col = toColor(theme.midBuilding);

        let i = 0;
        for (i = 0; i < count; i++) {
            const idx = first + i;
            const r = hash01(seed + idx * 19.7);
            const x = idx * span + shift;
            const trunkW = 14 + r * 14;
            const sway = Math.sin(time * 0.9 + idx) * 4;
            bgDraw.drawPolygon([
                Vec2(x - trunkW * 0.5, baseY),
                Vec2(x + trunkW * 0.5, baseY),
                Vec2(x + trunkW * 0.25 + sway, h),
                Vec2(x - trunkW * 0.3 + sway, h),
            ], col);
            // 月光斜切林隙
            if ((idx % 3) === 0) {
                bgGlow.drawVertices([
                    [Vec2(x + 40, h), Color(110, 232, 200, 26)],
                    [Vec2(x + 115, h), Color(110, 232, 200, 0)],
                    [Vec2(x - 60, baseY), Color(110, 232, 200, 0)],
                ]);
            }
        }
    }

    private drawDistantNorthTower(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        p: Play,
        time: number,
    ): void {
        // 越靠近北塔（outside → village → forest → tower），远方塔影越高越明晰
        let scale = 0.55;
        if (p.room.key === "village") {
            scale = 0.72;
        } else if (p.room.key === "forest") {
            scale = 0.92;
        } else if (p.room.key === "tower") {
            scale = 1.15;
        }
        const tx = w * 0.84 - (cam.x - p.room.minX) * 0.04;
        const baseY = cam.groundScreenY - 8;
        const towerH = h * 0.42 * scale;
        const bw = 20 * scale;
        bgDraw.drawPolygon([
            Vec2(tx - bw, baseY),
            Vec2(tx + bw, baseY),
            Vec2(tx + bw * 0.45, baseY + towerH),
            Vec2(tx - bw * 0.45, baseY + towerH),
        ], Color(14, 24, 38, 240));
        bgDraw.drawSegment(Vec2(tx, baseY + towerH), Vec2(tx, baseY + towerH + 28 * scale), 1.8, Color(180, 210, 238, 200));

        const topY = baseY + towerH + 24 * scale;
        const pulse = 0.78 + 0.22 * Math.sin(time * 2.2);
        fillRadialGlow(bgGlow, tx, topY, 56 * scale * pulse, 56 * scale * pulse, Color(255, 224, 152, 118), Color(255, 190, 96, 0), 18);
        bgGlow.drawDot(Vec2(tx, topY), 3.6 * scale, Color(255, 246, 220, 255));
    }

    private drawFloors(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.floors.length; i++) {
            const f = p.room.floors[i];
            const x0 = cam.sx(f.x0);
            const x1 = cam.sx(f.x1);
            const y = cam.sy(f.y);
            const isMain = f.y <= 0.1;

            if (isMain) {
                // 主地面：深沉基底 + 工业地砖分缝 + 顶部冷光高光沿
                fillVGradRect(fgDraw, x0, 0, x1 - x0, y, toColor(PALETTE.voidDark), toColor(theme.groundBody));
                fgDraw.drawRect(Rect(x0, y - 10, x1 - x0, 10), toColor(theme.groundTop));
                fgDraw.drawSegment(Vec2(x0, y), Vec2(x1, y), 1.8, toColor(theme.groundRim));
                fgGlow.drawSegment(Vec2(x0, y + 1), Vec2(x1, y + 1), 1.2, toColor(theme.accent, 65));

                // 地面伸缩缝与透视短线
                const jointStep = cam.len(64);
                if (jointStep > 16) {
                    let gx = x0;
                    while (gx < x1) {
                        fgDraw.drawSegment(Vec2(gx, y - 2), Vec2(gx - 14, y - 28), 1, Color(42, 56, 76, 120));
                        gx += jointStep;
                    }
                }
            } else {
                // 悬空装卸台面（如城外 y=96、墙根石台 y=64）：厚重钢结构桁架 + 下方投影
                const deckH = Math.max(14, cam.len(9));
                // 下方阴影带
                fillVGradRect(fgDraw, x0, y - deckH - 26, x1 - x0, 26, Color(4, 6, 10, 0), Color(4, 6, 10, 155));
                fgDraw.drawRect(Rect(x0, y - deckH, x1 - x0, deckH), toColor(PALETTE.steelDark));
                fgDraw.drawRect(Rect(x0, y - 4, x1 - x0, 4), toColor(theme.groundTop));
                fgDraw.drawSegment(Vec2(x0, y), Vec2(x1, y), 1.8, toColor(theme.groundRim));
                fgDraw.drawSegment(Vec2(x0, y - deckH), Vec2(x1, y - deckH), 1.2, toColor(PALETTE.steelLight, 150));

                // 钢桁架斜撑
                const trussStep = Math.max(24, cam.len(26));
                let tx = x0 + 6;
                while (tx + trussStep < x1) {
                    fgDraw.drawSegment(Vec2(tx, y - deckH + 2), Vec2(tx + trussStep * 0.5, y - 4), 1.1, toColor(PALETTE.steelLight, 120));
                    fgDraw.drawSegment(Vec2(tx + trussStep * 0.5, y - 4), Vec2(tx + trussStep, y - deckH + 2), 1.1, toColor(PALETTE.steelLight, 120));
                    tx += trussStep;
                }
                // 台面边缘警示斜纹
                drawHazardStripes(fgDraw, x0 + 2, y - deckH + 2, Math.min(48, (x1 - x0) * 0.15), deckH - 5, 10, toColor(PALETTE.amber, 120));
            }
        }
    }

    private drawStairs(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.stairs.length; i++) {
            const st = p.room.stairs[i];
            const n = st.steps + 1;
            const stepW = (st.x1 - st.x0) / n;
            let k = 0;
            for (k = 0; k < n; k++) {
                const wy = st.y0 + (st.y1 - st.y0) * k / (n - 1);
                const wx0 = st.x0 + stepW * k;
                const wx1 = wx0 + stepW;
                const x0 = cam.sx(wx0);
                const x1 = cam.sx(wx1);
                const y1 = cam.sy(wy);
                const y0 = cam.sy(Math.max(0, st.y0));
                if (y1 > y0 + 2) {
                    fgDraw.drawRect(Rect(x0, y0, x1 - x0, y1 - y0), toColor(PALETTE.steelDark, 230));
                    fgDraw.drawRect(Rect(x0, y1 - 5, x1 - x0, 5), toColor(theme.groundTop));
                }
                fgDraw.drawSegment(Vec2(x0, y1), Vec2(x1, y1), 1.8, toColor(theme.groundRim));
                fgGlow.drawSegment(Vec2(x0, y1 + 1), Vec2(x1, y1 + 1), 1, toColor(theme.accent, 55));
            }
        }
    }

    private drawSolids(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
        time: number,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            const x0 = cam.sx(s.x);
            const x1 = cam.sx(s.x + s.w);
            const y0 = cam.sy(s.y);
            const y1 = cam.sy(s.y + s.h);
            const sw = x1 - x0;
            const sh = y1 - y0;
            if (sw <= 1 || sh <= 1) {
                continue;
            }

            // 1) 森林草丛（可穿过潜行植被）
            if (s.passable === true) {
                this.drawGrassCluster(fgDraw, fgGlow, x0, y0, sw, sh, p.player.x, s.x + s.w * 0.5, time);
                continue;
            }

            // 2) 城门绞盘
            if (s.label.indexOf("绞盘") >= 0) {
                this.drawWinch(fgDraw, fgGlow, x0, y0, sw, sh, p, time);
                continue;
            }

            // 3) 北塔塔身与门楣
            if (p.room.key === "tower") {
                this.drawTowerStructure(fgDraw, fgGlow, x0, y0, sw, sh, s, p, time);
                continue;
            }

            // 4) 矮掩体（柜台 / 街垒 / 倒柜 / 矮墙 / 队栏）
            if (s.h <= 64 && s.y <= 2) {
                this.drawCoverBlock(fgDraw, fgGlow, x0, y0, sw, sh, s, p, theme);
                continue;
            }

            // 5) 重型墙体 / 门框 / 城墙基座 / 院墙
            fillVGradRect(fgDraw, x0, y0, sw, sh, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            fgDraw.drawRect(Rect(x0, y0, sw, sh), Color(0, 0, 0, 0), 1.2, toColor(PALETTE.steelLight, 180));
            // 内嵌装甲线与铆钉节奏
            const inset = Math.min(10, sw * 0.14);
            fgDraw.drawSegment(Vec2(x0 + inset, y0 + 10), Vec2(x0 + inset, y1 - 10), 1, toColor(PALETTE.voidDark, 150));
            fgDraw.drawSegment(Vec2(x1 - inset, y0 + 10), Vec2(x1 - inset, y1 - 10), 1, toColor(PALETTE.voidDark, 150));
            // 顶部高光切边
            fgDraw.drawSegment(Vec2(x0, y1), Vec2(x1, y1), 2.0, toColor(theme.groundRim));
            if (s.label.indexOf("城门") >= 0 || s.label.indexOf("门洞") >= 0 || s.label.indexOf("门楣") >= 0) {
                drawHazardStripes(fgDraw, x0 + 2, y0 + 4, sw - 4, Math.min(14, sh * 0.2), 14, toColor(PALETTE.crimson, 130));
            }
        }
    }

    private drawCoverBlock(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        x0: number, y0: number, sw: number, sh: number,
        s: SolidSpec, p: Play, theme: RoomTheme,
    ): void {
        const isRail = s.label.indexOf("队栏") >= 0;
        if (isRail) {
            // 候检队栏：金属栏杆柱 + 顶部冰青警示横杠
            const posts = 4;
            let k = 0;
            for (k = 0; k <= posts; k++) {
                const px = x0 + (sw * k) / posts;
                fgDraw.drawSegment(Vec2(px, y0), Vec2(px, y0 + sh), 3, toColor(PALETTE.steelLight));
            }
            fgDraw.drawRect(Rect(x0, y0 + sh - 8, sw, 8), toColor(PALETTE.steelMid));
            fgDraw.drawSegment(Vec2(x0, y0 + sh), Vec2(x0 + sw, y0 + sh), 2, toColor(theme.accent, 210));
            fgDraw.drawSegment(Vec2(x0, y0 + sh * 0.48), Vec2(x0 + sw, y0 + sh * 0.48), 2, toColor(PALETTE.steelLight, 180));
            return;
        }

        // 艾希风格倒角装甲掩体（柜台 / 街垒 / 倒柜）
        fillChamferBox(fgDraw, x0, y0, sw, sh, 10, toColor(PALETTE.steelMid), 1.4, toColor(PALETTE.rimSilver, 180));
        fillVGradRect(fgDraw, x0 + 4, y0 + 4, sw - 8, sh - 12, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
        // 顶边锐利冷光
        fgDraw.drawSegment(Vec2(x0 + 8, y0 + sh), Vec2(x0 + sw - 2, y0 + sh), 2.2, toColor(PALETTE.rimSilver, 235));
        // 底部警示斜纹
        drawHazardStripes(fgDraw, x0 + 6, y0 + 4, sw - 12, Math.min(11, sh * 0.22), 14, toColor(theme.accent, 110));

        // 战术后方贴掩体时，掩体侧沿亮起冰青全息护盾线
        if (!p.childMode && (p.coverHug || p.coverNear)) {
            const plx = p.player.x;
            const nearLeft = Math.abs(plx - s.x) < 42;
            const nearRight = Math.abs(plx - (s.x + s.w)) < 42;
            if (nearLeft || nearRight) {
                const edgeX = nearLeft ? x0 - 2 : x0 + sw + 2;
                const col = p.coverHug ? PALETTE.cyan : PALETTE.amber;
                fgGlow.drawSegment(Vec2(edgeX, y0 + 4), Vec2(edgeX, y0 + sh + 4), p.coverHug ? 3.5 : 2, toColor(col, p.coverHug ? 220 : 140));
                if (p.coverHug) {
                    fillRadialGlow(fgGlow, edgeX, y0 + sh * 0.55, 22, sh * 0.7, toColor(PALETTE.cyan, 85), Color(72, 224, 255, 0), 14);
                }
            }
        }
    }

    private drawWinch(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        x0: number, y0: number, sw: number, sh: number,
        p: Play, time: number,
    ): void {
        fillChamferBox(fgDraw, x0, y0, sw, sh, 8, toColor(PALETTE.steelMid), 1.5, toColor(PALETTE.rimSilver, 180));
        // 旋转绞盘齿轮
        const cx = x0 + sw * 0.5;
        const cy = y0 + sh * 0.55;
        const r = Math.min(sw, sh) * 0.34;
        const spin = p.phase === "gate-hold" ? time * 1.4 : 0;
        fgDraw.drawRing(Vec2(cx, cy), r * 0.62, r, toColor(PALETTE.steelDark), 1.5, toColor(PALETTE.rimSilver, 210));
        let k = 0;
        for (k = 0; k < 6; k++) {
            const a = spin + (k * Math.PI) / 3;
            fgDraw.drawSegment(
                Vec2(cx + Math.cos(a) * r * 0.25, cy + Math.sin(a) * r * 0.25),
                Vec2(cx + Math.cos(a) * r * 1.05, cy + Math.sin(a) * r * 1.05),
                2,
                toColor(PALETTE.rimSilver, 210),
            );
        }
        // 拉向门楣的张力钢缆
        fgDraw.drawSegment(Vec2(cx, cy + r), Vec2(cx, y0 + sh + 220), 1.6, toColor(PALETTE.steelLight, 175));
        // 绞盘状态灯
        const active = p.phase === "gate-hold" || p.phase === "gate-send";
        const lampCol = active ? PALETTE.cyan : PALETTE.amber;
        const pulse = 0.7 + 0.3 * Math.sin(time * 5);
        fgGlow.drawDot(Vec2(x0 + sw - 10, y0 + sh - 10), 4, toColor(lampCol, 240 * pulse));
        fillRadialGlow(fgGlow, x0 + sw - 10, y0 + sh - 10, 22, 22, toColor(lampCol, 95 * pulse), Color(lampCol.r, lampCol.g, lampCol.b, 0), 12);
    }

    private drawGateShutter(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        const g = p.room.story !== undefined ? p.room.story.gate : undefined;
        if (g === undefined) {
            return;
        }
        // 门洞位置 840..1040，门楣底 y=160；守点越接近结束、或关门数数时重型闸门缓缓降下
        let closeFrac = 0.08;
        if (p.phase === "gate-hold") {
            closeFrac = 0.08 + 0.36 * Math.min(1, p.gateTick / Math.max(1, g.holdTicks));
        } else if (p.phase === "gate-send") {
            closeFrac = 0.44;
        } else if (p.phase === "gate-count") {
            closeFrac = 0.44 + 0.56 * Math.min(1, p.countTick / 360);
        } else if (p.phase === "gate-walk") {
            closeFrac = 1.0;
        }
        const gx0 = cam.sx(848);
        const gx1 = cam.sx(1032);
        const topY = cam.sy(160);
        const botY = cam.sy(160 * (1 - closeFrac));
        if (topY > botY + 2) {
            fillVGradRect(fgDraw, gx0, botY, gx1 - gx0, topY - botY, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            fgDraw.drawSegment(Vec2(gx0, botY), Vec2(gx1, botY), 3, toColor(PALETTE.crimson, 220));
            drawHazardStripes(fgDraw, gx0 + 4, botY + 3, gx1 - gx0 - 8, Math.min(14, topY - botY - 4), 18, toColor(PALETTE.amber, 140));
        }
        // 门洞外溢的冷月光缝（送别与未关门前，象征城外的生路）
        if (closeFrac < 0.98) {
            const gapH = Math.max(8, botY - cam.sy(0));
            const pulse = 0.8 + 0.2 * Math.sin(time * 2.5);
            fillVGradRect(fgGlow, gx0, cam.sy(0), gx1 - gx0, gapH, Color(140, 210, 255, Math.round(52 * pulse)), Color(80, 160, 230, 0));
        }
    }

    private drawTowerStructure(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        x0: number, y0: number, sw: number, sh: number,
        s: SolidSpec, p: Play, time: number,
    ): void {
        fillVGradRect(fgDraw, x0, y0, sw, sh, Color(15, 21, 34, 255), Color(32, 44, 66, 255));
        fgDraw.drawRect(Rect(x0, y0, sw, sh), Color(0, 0, 0, 0), 1.4, toColor(PALETTE.rimSilver, 165));

        if (s.label.indexOf("塔身") >= 0) {
            // 纪念碑式北塔墙面：竖向石肋、横梁与狭长暖光观察窗缝
            const ribs = 4;
            let r = 1;
            for (r = 1; r < ribs; r++) {
                const rx = x0 + (sw * r) / ribs;
                fgDraw.drawSegment(Vec2(rx, y0), Vec2(rx, y0 + sh), 2, Color(10, 15, 24, 210));
                fgDraw.drawSegment(Vec2(rx + 2, y0), Vec2(rx + 2, y0 + sh), 1, Color(68, 86, 114, 130));
            }
            // 横向石砌分层线
            const bands = 4;
            let b = 1;
            for (b = 1; b < bands; b++) {
                const by = y0 + (sh * b) / bands;
                fgDraw.drawSegment(Vec2(x0 + 4, by), Vec2(x0 + sw - 4, by), 1.2, Color(52, 68, 92, 135));
            }
            // 塔壁狭长暖灯观察窗
            const slitX = s.x < 400 ? x0 + sw * 0.62 : x0 + sw * 0.34;
            const slitY = y0 + sh * 0.56;
            const slitH = sh * 0.22;
            fgDraw.drawRect(Rect(slitX - 5, slitY, 10, slitH), Color(8, 12, 20, 245), 1.2, toColor(PALETTE.amberDim, 190));
            fgGlow.drawRect(Rect(slitX - 2, slitY + 4, 4, slitH - 8), toColor(PALETTE.amber, 190));
            fillRadialGlow(fgGlow, slitX, slitY + slitH * 0.5, 44, slitH * 0.7, Color(255, 206, 128, 52), Color(255, 180, 86, 0), 14);
        }

        // 门楣下方温暖圣殿灯火（开门时灯光骤然敞开铺满门廊！）
        if (s.label.indexOf("门楣") >= 0) {
            const opened = p.phase === "tower-given" || p.phase === "tower-end";
            const cx = x0 + sw * 0.5;
            const lampY = y0 - 8;
            const pulse = 0.85 + 0.15 * Math.sin(time * 3);
            const alpha = opened ? 155 : 88;
            // 门框重型立柱与门板纹理
            fgDraw.drawSegment(Vec2(x0 + 4, y0), Vec2(x0 + 4, y0 - sh * 3.8), 4, Color(42, 52, 70, 255));
            fgDraw.drawSegment(Vec2(x0 + sw - 4, y0), Vec2(x0 + sw - 4, y0 - sh * 3.8), 4, Color(42, 52, 70, 255));
            fgDraw.drawSegment(Vec2(x0, y0), Vec2(x0 + sw, y0), 2.5, toColor(PALETTE.amber, 210));
            // 门洞暖光溢出
            fillVGradRect(
                fgGlow,
                x0 + 6,
                y0 - sh * 3.8,
                sw - 12,
                sh * 3.8,
                Color(255, 206, 128, Math.round(alpha * pulse)),
                Color(255, 224, 168, opened ? 180 : 62),
            );
            fillRadialGlow(fgGlow, cx, lampY, opened ? 105 : 58, opened ? 105 : 58, Color(255, 232, 178, Math.round(170 * pulse)), Color(255, 180, 86, 0), 18);
            fgDraw.drawCircle(Vec2(cx, lampY), 5.5, toColor(PALETTE.amberCore));
        }
    }

    private drawGrassCluster(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        x0: number, y0: number, sw: number, sh: number,
        playerX: number, centerWorldX: number, time: number,
    ): void {
        // 丰茂及腰深青芦苇草丛（同时自然包裹踩在草丛上方的角色脚踝，消除悬空感）
        const blades = Math.max(12, Math.floor(sw / 8));
        const nearPlayer = Math.abs(playerX - centerWorldX) < 62;
        let k = 0;
        for (k = 0; k < blades; k++) {
            const t = (k + 0.5) / blades;
            const bx = x0 + sw * t;
            const hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01);
            const bh = sh * hRatio * 1.95;
            const sway = Math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer ? (t < 0.5 ? -9 : 9) : 0);
            const col = (k & 1) === 0 ? Color(20, 58, 54, 235) : Color(34, 88, 76, 240);
            fgDraw.drawPolygon([
                Vec2(bx - 7, y0),
                Vec2(bx + 7, y0),
                Vec2(bx + sway, y0 + bh),
            ], col);
        }
        if (nearPlayer) {
            fgGlow.drawSegment(Vec2(x0, y0 + 2), Vec2(x0 + sw, y0 + 2), 2.0, toColor(PALETTE.emerald, 145));
        }
    }

    private drawArch(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        const a = p.room.arch;
        if (a.h <= 0 || a.x1 <= a.x0) {
            return;
        }
        const x0 = cam.sx(a.x0);
        const x1 = cam.sx(a.x1);
        const y0 = cam.sy(a.y);
        const y1 = cam.sy(a.y + a.h);
        const aw = x1 - x0;
        const ah = y1 - y0;

        // 拱洞内部深黑通道
        fgDraw.drawRect(Rect(x0, y0, aw, ah), Color(5, 7, 11, 245));
        // 拱券顶边框 + 左右厚石框
        fgDraw.drawSegment(Vec2(x0, y0), Vec2(x0, y1), 3, toColor(PALETTE.rimSilver, 215));
        fgDraw.drawSegment(Vec2(x1, y0), Vec2(x1, y1), 3, toColor(PALETTE.rimSilver, 215));
        fgDraw.drawSegment(Vec2(x0 - 4, y1), Vec2(x1 + 4, y1), 3.2, toColor(PALETTE.rimSilver, 235));
        // 城外拱洞内嵌石拱肋（严格约束在洞框内部，绝不顶穿上沿）
        if (p.room.key === "outside") {
            const arcR = Math.min(aw * 0.46, ah * 0.72);
            fgDraw.drawArc(Vec2((x0 + x1) * 0.5, y1 - arcR - 2), arcR, 0, 180, 2.2, toColor(theme.accent, 195));
            fillVGradRect(fgGlow, x0 + 6, y0, aw - 12, ah * 0.65, Color(86, 186, 236, 52), Color(86, 186, 236, 0));
        }
    }
}
