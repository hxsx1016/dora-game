/** 远景、视差装饰和按碰撞尺寸绘制的场景贴图。 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { LANE_DEPTH } from "Script/watch/depth";
import { DepthRange, SolidSpec } from "Script/watch/rooms";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { DepthOcclusion, depthOrder, occlusionTint } from "Script/watch/fe/occlusion";
import {
    PALETTE,
    RoomTheme,
    drawHazardStripes,
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

interface DedicatedPropArt {
    clip: string;
    natAR: number;
    heightMul: number;
    tileable: boolean;
}

/** 将特定明代场景道具（空筐墙/粮袋堆/木帘/窗板/石井栏）映射至专属 props_ming.clip 手绘精灵，避免退化为通用砖木块 */
function dedicatedSolidProp(solid: SolidSpec): DedicatedPropArt | undefined {
    if (solid.art === "basket_wall") {
        return { clip: "basket_wall", natAR: 144 / 90, heightMul: 1.08, tileable: true };
    }
    if (solid.art === "curtain") {
        return { clip: "curtain", natAR: 144 / 126, heightMul: 1.06, tileable: false };
    }
    if (solid.art === "board") {
        return { clip: "window_board", natAR: 88 / 144, heightMul: 1.04, tileable: false };
    }
    if (solid.id === "s1_well" || solid.art === "well" || solid.label.indexOf("井背") >= 0) {
        return { clip: "well_curb", natAR: 144 / 120, heightMul: 1.12, tileable: false };
    }
    if (solid.art === "grain_sack" || solid.label.indexOf("粮台") >= 0 || solid.label.indexOf("粮袋") >= 0) {
        return { clip: "grain_sack", natAR: 144 / 74, heightMul: 1.12, tileable: true };
    }
    return undefined;
}

function coverArt(solid: SolidSpec): AssetSlotKey {
    if (solid.art === "gate_post" || solid.art === "wall" || solid.art === "latch") {
        return "wall";
    }
    if (solid.art === "thin_wood" || solid.art === "board" || solid.art === "cover_wood") {
        return "cover_wood";
    }
    if (solid.art === "fence") {
        return "fence";
    }
    return solid.label.indexOf("柜") >= 0 || solid.label.indexOf("货") >= 0 ? "cover_wood" : "cover_stone";
}

const GUARD_LANTERN_CLIPS = [
    "assets/art/actors_enemies_anim.clip|guard_lantern_0",
    "assets/art/actors_enemies_anim.clip|guard_lantern_1",
    "assets/art/actors_enemies_anim.clip|guard_lantern_2",
    "assets/art/actors_enemies_anim.clip|guard_lantern_3",
];
const GUARD_WRITE_CLIPS = [
    "assets/art/actors_enemies_anim.clip|guard_write_0",
    "assets/art/actors_enemies_anim.clip|guard_write_1",
    "assets/art/actors_enemies_anim.clip|guard_write_2",
    "assets/art/actors_enemies_anim.clip|guard_write_3",
];

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

        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const backdropKey = theme.backdropKey ?? p.room.key;
        const farSlot = ("bgFar_" + backdropKey) as AssetSlotKey;
        // 校准背景底图尺度与地平线：适当放大背景建筑比例（1.24×）并将底图地平线锚在 groundScreenY，
        // 避免背景门框与楼层比前景角色还矮。
        const artW = Math.max(w, h * 16 / 9) * 1.24;
        const artH = artW * 9 / 16;
        const artY = Math.min(0, Math.max(h - artH, cam.groundScreenY - artH * 0.24));
        if (assets.tryPlace(farSlot, "scene", w * (0.5 - progress * 0.08), artY, artW, artH)) {
            this.drawDressing(assets, backdropKey, cam, progress);
            const y = cam.groundScreenY;
            fillVGradRect(bgDraw, 0, 0, w, h, toColor(PALETTE.voidDark), toColor(theme.skyMid));
            fillVGradRect(bgGlow, 0, y - 1, w, h * 0.14, Color(43, 49, 63, 15), Color(43, 49, 63, 0));
            return;
        }

        // 1. 多段垂直渐变天穹
        const splitY = h * 0.46;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(theme.skyMid), toColor(theme.skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(theme.skyHorizon), toColor(theme.skyMid));

        // 2. 霜月微晕（仅无底图时兜底）
        if (theme.showMoon) {
            const mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015;
            const my = h * theme.moonYFrac;
            const mr = Math.max(18, h * 0.044);
            fillRadialGlow(bgGlow, mx, my, mr * 5.2, mr * 5.2, Color(156, 186, 212, 26), Color(20, 32, 52, 0), 20);
            fillRadialGlow(bgGlow, mx, my, mr * 2.2, mr * 2.2, Color(210, 226, 238, 56), Color(64, 96, 134, 0), 18);
            bgDraw.drawCircle(Vec2(mx, my), mr, Color(224, 236, 244, 220));
            bgDraw.drawCircle(Vec2(mx + mr * 0.28, my + mr * 0.16), mr * 0.84, toColor(theme.skyTop, 118));
        }

        if (p.room.key === "forest") {
            this.drawFarForest(bgDraw, w, h, cam, theme, seed);
            this.drawMidForest(bgDraw, bgGlow, w, h, cam, theme, time, seed);
        } else {
            this.drawFarMingTown(bgDraw, w, h, cam, theme, seed);
        }
        if (theme.showTowerBeacon) {
            this.drawDistantNorthTower(bgDraw, bgGlow, w, h, cam, p, time);
        }

        // 3. 底部夜雾渐变
        const fogH = h * 0.34;
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

    private drawDressing(assets: AssetSlotHost, backdropKey: string, cam: CameraDirector, progress: number): void {
        const w = cam.viewW;
        const ground = cam.groundScreenY;
        const x = w * (0.76 - progress * 0.22);
        // 严格按精灵固有宽高比放置中景装饰（pine 82×72, eaves 106×58, cover_stone 64×28），消除非等比变形
        if (backdropKey === "forest" || backdropKey === "outside" || backdropKey === "tower") {
            assets.tryPlace("pine", "mid_pine", x, ground - cam.len(6), cam.len(122), cam.len(107),
                { layer: 1, opacity: 0.50 });
        } else if (backdropKey === "prologue" || backdropKey === "village" || backdropKey === "checkpoint") {
            assets.tryPlace("eaves", "mid_eaves", x, ground - cam.len(4), cam.len(176), cam.len(96),
                { layer: 1, opacity: 0.44 });
        } else {
            assets.tryPlace("cover_stone", "mid_ruin", x, ground - cam.len(4), cam.len(114), cam.len(50),
                { layer: 1, opacity: 0.44 });
        }
        if (backdropKey === "street" || backdropKey === "checkpoint" || backdropKey === "prologue") {
            const lanternSway = Math.sin(progress * 6 + cam.x * 0.004) * 2.5;
            assets.tryPlace("prop_lantern", "mid_lantern", w * (0.27 - progress * 0.18),
                ground + cam.len(96), cam.len(20), cam.len(28), { layer: 2, opacity: 0.82, angle: lanternSway });
        }
    }

    /** 标题菜单专用动态背景（底图缺失时以宋明水墨冷月孤城与远山北塔兜底，零现代霓虹/探照灯） */
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

        // 霜月淡晕（与右侧北塔孤灯对角呼应）
        const mx = w * 0.61;
        const my = h * 0.74;
        const mr = h * 0.072;
        fillRadialGlow(bgGlow, mx, my, mr * 4.4, mr * 4.4, Color(164, 184, 198, 28), Color(16, 22, 34, 0), 22);
        fillRadialGlow(bgGlow, mx, my, mr * 1.9, mr * 1.9, Color(214, 224, 232, 62), Color(36, 48, 64, 0), 18);
        bgDraw.drawCircle(Vec2(mx, my), mr, Color(234, 238, 236, 225));
        bgDraw.drawCircle(Vec2(mx + mr * 0.24, my + mr * 0.14), mr * 0.85, Color(14, 18, 28, 118));

        // 远景明代海防青砖城垛与民居歇山屋脊剪影
        const groundY = h * 0.19;
        let i = 0;
        for (i = 0; i < 14; i++) {
            const bx = i * (w / 12) - 24 + Math.sin(time * 0.06) * 4;
            const bw = 58 + hash01(i * 13 + 3) * 82;
            const bh = h * (0.14 + hash01(i * 29 + 7) * 0.22);
            const ridgeH = 14 + hash01(i * 19) * 18;
            bgDraw.drawPolygon([
                Vec2(bx, groundY),
                Vec2(bx + bw, groundY),
                Vec2(bx + bw, groundY + bh),
                Vec2(bx + bw * 0.5, groundY + bh + ridgeH),
                Vec2(bx, groundY + bh),
            ], Color(14, 18, 26, 255));
        }

        // 远景北塔重檐望塔与西窗一豆暖灯
        const tx = w * 0.83;
        const ty0 = groundY;
        const ty1 = h * 0.58;
        bgDraw.drawPolygon([
            Vec2(tx - 24, ty0),
            Vec2(tx + 24, ty0),
            Vec2(tx + 15, ty1),
            Vec2(tx - 15, ty1),
        ], Color(18, 23, 34, 255), 1.1, Color(72, 84, 98, 130));
        bgDraw.drawPolygon([
            Vec2(tx - 32, ty1),
            Vec2(tx + 32, ty1),
            Vec2(tx, ty1 + 26),
        ], Color(24, 30, 42, 255));
        const pulse = 0.82 + 0.18 * Math.sin(time * 2.2);
        const lampY = ty1 - 14;
        fillRadialGlow(bgGlow, tx, lampY, 64 * pulse, 64 * pulse, Color(238, 198, 128, 118), Color(214, 162, 86, 0), 18);
        bgGlow.drawDot(Vec2(tx, lampY), 4.2, Color(252, 240, 206, 245));

        // 底部青石路与夜雾渐变
        fillVGradRect(bgDraw, 0, 0, w, groundY, Color(9, 11, 17, 255), Color(20, 24, 34, 255));
        bgDraw.drawSegment(Vec2(0, groundY), Vec2(w, groundY), 1.4, toColor(PALETTE.silkDim, 145));
        fillVGradRect(bgGlow, 0, groundY, w, h * 0.18, Color(46, 56, 72, 42), Color(20, 26, 38, 0));

        // 右下兄妹逆光剪影（周戍笠盔短袄鸟铳 + 小满旧布斗篷提灯微光）
        const sx = w * 0.64;
        bgDraw.drawPolygon([
            Vec2(sx - 24, groundY + 14),
            Vec2(sx + 14, groundY + 18),
            Vec2(sx + 16, groundY + 116),
            Vec2(sx - 16, groundY + 116),
        ], Color(14, 18, 26, 255), 1.1, Color(118, 132, 144, 125));
        bgDraw.drawSegment(Vec2(sx - 5, groundY + 46), Vec2(sx - 10, groundY + 2), 5.5, Color(12, 16, 24, 255));
        bgDraw.drawSegment(Vec2(sx + 6, groundY + 46), Vec2(sx + 12, groundY + 2), 5.5, Color(16, 20, 30, 255));
        bgDraw.drawCircle(Vec2(sx + 1, groundY + 132), 11, Color(18, 22, 32, 255));
        bgDraw.drawPolygon([
            Vec2(sx - 18, groundY + 135),
            Vec2(sx + 20, groundY + 135),
            Vec2(sx + 1, groundY + 148),
        ], Color(44, 50, 58, 250));
        bgDraw.drawSegment(Vec2(sx + 4, groundY + 96), Vec2(sx + 46, groundY + 88), 3.0, Color(78, 56, 40, 255));

        const cx = w * 0.725;
        bgDraw.drawPolygon([
            Vec2(cx - 18, groundY + 14),
            Vec2(cx + 16, groundY + 14),
            Vec2(cx + 11, groundY + 78),
            Vec2(cx - 11, groundY + 78),
        ], Color(148, 108, 66, 236), 1.2, Color(214, 186, 146, 195));
        bgDraw.drawSegment(Vec2(cx - 4, groundY + 22), Vec2(cx - 5, groundY + 2), 3.8, Color(24, 20, 24, 255));
        bgDraw.drawSegment(Vec2(cx + 4, groundY + 22), Vec2(cx + 5, groundY + 2), 3.8, Color(30, 26, 30, 255));
        bgDraw.drawCircle(Vec2(cx + 1, groundY + 88), 10, Color(212, 192, 168, 240));
        fillRadialGlow(bgGlow, cx + 10, groundY + 52, 26, 26, Color(238, 198, 128, 96), Color(214, 162, 86, 0), 14);
        bgGlow.drawDot(Vec2(cx + 10, groundY + 52), 2.8, Color(252, 238, 202, 240));
    }

    /** 绘制逻辑平面建筑（地板、悬空平台、建筑实体、拱洞、台阶、城门闸门） */
    drawPlayableWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        occlusion: DepthOcclusion,
        fadeDt: number,
    ): void {
        const theme = themeOf(p.room.key);
        this.drawFloors(fgDraw, assets, p, cam, theme);
        this.drawStairs(fgDraw, fgGlow, assets, p, cam, theme);
        this.drawSolids(fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt);
        if (p.room.key === "gate") {
            this.drawGateShutter(fgDraw, fgGlow, assets, p, cam, time);
        }
        this.drawArch(fgDraw, assets, p, cam);
    }

    /** 绘制柔和电影暗角（移除早期科幻钢梁/黑梯形压边，保持明代画面通透干净） */
    drawForegroundFraming(
        fgDraw: DrawNode.Type,
        w: number,
        h: number,
        _p: Play,
        _cam: CameraDirector,
    ): void {
        // 柔和电影暗角（顶部与底部微暗渐变，聚焦主体与字幕）
        fillVGradRect(fgDraw, 0, h - h * 0.15, w, h * 0.15, Color(4, 6, 12, 0), Color(4, 6, 12, 126));
        fillVGradRect(fgDraw, 0, 0, w, h * 0.12, Color(4, 6, 12, 165), Color(4, 6, 12, 0));
    }

    /** 兜底远景：明代海防青砖城垛与民居歇山屋脊剪影（肃清遗留探照灯/屋顶天线/钢桁架/电缆） */
    private drawFarMingTown(
        bgDraw: DrawNode.Type,
        w: number,
        h: number,
        cam: CameraDirector,
        theme: RoomTheme,
        seed: number,
    ): void {
        const baseY = cam.groundScreenY - 8;
        const shift = -cam.x * 0.20 * cam.ppu;
        const colW = 112;
        const first = Math.floor((-shift - colW) / colW);
        const count = Math.ceil(w / colW) + 3;
        let i = 0;
        for (i = 0; i < count; i++) {
            const idx = first + i;
            const r1 = hash01(seed + idx * 13.7);
            const r2 = hash01(seed + idx * 29.3);
            const x = idx * colW + shift;
            const bw = colW * (0.72 + r1 * 0.42);
            const bh = h * (0.14 + r2 * 0.24);
            const ridgeH = 14 + r1 * 18;
            bgDraw.drawPolygon([
                Vec2(x, baseY),
                Vec2(x + bw, baseY),
                Vec2(x + bw, baseY + bh),
                Vec2(x + bw * 0.5, baseY + bh + ridgeH),
                Vec2(x, baseY + bh),
            ], toColor(theme.farBuilding));
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
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        const grass = p.room.key === "forest" || p.room.key === "outside";
        for (let i = 0; i < p.room.floors.length; i++) {
            const floor = p.room.floors[i];
            const left = cam.sx(floor.x0);
            const right = cam.sx(floor.x1);
            const isMain = floor.y <= 0.1;
            const road = isMain ? p.room.depth : undefined;
            const top = cam.sy(floor.y, road?.min ?? 0);
            if (road !== undefined) {
                this.drawRoad(fgDraw, assets, i, left, right, top, cam.sy(floor.y, road.max), cam, theme);
            }
            const height = cam.len(isMain ? 22 : 12);
            const bottom = top - height;
            if (isMain && bottom > 0) {
                fillVGradRect(fgDraw, left, 0, right - left, bottom + 1,
                    toColor(PALETTE.voidDark), toColor(theme.groundBody));
            }
            fgDraw.drawRect(Rect(left, bottom, right - left, height), toColor(PALETTE.steelDark));
            const step = cam.len(96);
            const start = Math.max(0, Math.floor(-left / step));
            for (let j = start; left + j * step < Math.min(right, cam.viewW); j++) {
                const x = left + j * step;
                const width = Math.min(step, right - x);
                assets.tryPlace("slab", "deck_" + i + "_" + j, x + width * 0.5, bottom, width, height);
                if (grass && isMain && j % 3 === 1) {
                    assets.tryPlace("grass_low", "edge_" + i + "_" + j, x + width * 0.5,
                        top - cam.len(3), width * 0.74, cam.len(13), { opacity: 0.83, layer: 1 });
                }
            }
            fgDraw.drawSegment(Vec2(left, top), Vec2(right, top), 1, toColor(theme.groundRim, 140));
        }
    }

    private drawRoad(
        draw: DrawNode.Type, _assets: AssetSlotHost, _floor: number,
        left: number, right: number, front: number, back: number,
        cam: CameraDirector, theme: RoomTheme,
    ): void {
        const width = right - left;
        const height = back - front;
        if (width <= 1 || height <= 1) {
            return;
        }
        // 透视压扁后的青石板路面（不再误用竖墙贴图 wall 压扁铺地）
        const nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42);
        const farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42);
        fillVGradRect(draw, left, front, width, height, toColor(nearCol), toColor(farCol));

        const bands = [0, 0.30, 0.58, 0.81, 1];
        const jointDark = Color(14, 17, 22, 115);
        const jointHi = toColor(theme.groundRim, 36);
        const visLeft = Math.max(left, -40);
        const visRight = Math.min(right, cam.viewW + 40);
        for (let row = 0; row < bands.length - 1; row++) {
            const y0 = front + bands[row] * height;
            const y1 = front + bands[row + 1] * height;
            const rowH = y1 - y0;
            const slabWidth = Math.max(24, cam.len(84 - row * 10));
            const offset = left - (row % 2) * slabWidth * 0.5;
            const start = Math.max(0, Math.floor((visLeft - offset) / slabWidth));
            for (let col = start; offset + col * slabWidth < visRight; col++) {
                const sx0 = Math.max(left, offset + col * slabWidth);
                const sx1 = Math.min(right, offset + (col + 1) * slabWidth);
                const sw = sx1 - sx0;
                if (sw <= 2) {
                    continue;
                }
                const shade = ((col * 7 + row * 13) % 3) * 0.04;
                const stoneCol = lerpRGBA(nearCol, farCol, bands[row] * 0.85 + shade);
                draw.drawRect(Rect(sx0 + 0.5, y0 + 0.5, sw - 1, Math.max(1, rowH - 1)), toColor(stoneCol, 195));
                draw.drawSegment(Vec2(sx0, y0), Vec2(sx0, y1), 0.8, jointDark);
            }
            draw.drawSegment(Vec2(left, y0), Vec2(right, y0), 0.9, jointDark);
            draw.drawSegment(Vec2(left, y0 + 1), Vec2(right, y0 + 1), 0.6, jointHi);
        }
        // 前后路缘清晰边界线（明确提示 2.5D 可通行纵深边界）
        draw.drawSegment(Vec2(left, front), Vec2(right, front), 1.4, toColor(theme.groundRim, 135));
        draw.drawSegment(Vec2(left, back), Vec2(right, back), 1.3, toColor(theme.groundRim, 92));

        // 叠一层极轻的明代青石板纹理（位于全部 2.5D 角色与掩体之下，仅增质感不抢前景与影）
        const texTileW = Math.max(88, cam.len(128));
        const texStart = Math.max(0, Math.floor((visLeft - left) / texTileW));
        const stoneTint = toColor(lerpRGBA(theme.groundTop, PALETTE.rimSilver, 0.25), 255);
        for (let tcol = texStart; left + tcol * texTileW < visRight; tcol++) {
            const tx0 = left + tcol * texTileW;
            const tw = Math.min(texTileW, right - tx0);
            if (tw <= 4) {
                continue;
            }
            _assets.tryPlacePath(
                "assets/art/tex_diorama_ming.clip|ming_stone",
                "road_stone_" + _floor + "_" + tcol,
                tx0 + tw * 0.5,
                front,
                tw + 0.5,
                height,
                {
                    anchorX: 0.5,
                    anchorY: 0,
                    opacity: 0.14,
                    color: stoneTint,
                    smooth: true,
                    layer: -18,
                },
            );
        }
    }

    private drawStairs(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.stairs.length; i++) {
            const st = p.room.stairs[i];
            const n = st.steps + 1;
            const stepW = (st.x1 - st.x0) / n;
            const dMin = p.room.depth !== undefined
                ? (st.depth !== undefined ? st.depth.min : p.room.depth.min)
                : 0;
            const dMax = p.room.depth !== undefined
                ? (st.depth !== undefined ? st.depth.max : p.room.depth.max)
                : 0;
            const flatTop = Math.abs(st.y1 - st.y0) < 0.01;
            const baseWorldY = flatTop ? 0 : Math.max(0, st.y0);
            const stairLayer = p.room.depth !== undefined ? depthOrder(dMin, 0) : 0;
            let k = 0;
            for (k = 0; k < n; k++) {
                const wy = n <= 1 ? st.y1 : (st.y0 + (st.y1 - st.y0) * k / (n - 1));
                const wx0 = st.x0 + stepW * k;
                const wx1 = wx0 + stepW;
                const x0 = cam.sx(wx0);
                const x1 = cam.sx(wx1);
                if (x1 < 0 || x0 > cam.viewW) {
                    continue;
                }
                const y1 = cam.sy(wy, dMin);
                const y0 = cam.sy(baseWorldY, dMin);
                const yRear = cam.sy(wy, dMax);
                if (yRear > y1 + 1) {
                    fgDraw.drawRect(Rect(x0, y1, x1 - x0, yRear - y1), toColor(lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), 235), 0.7, toColor(theme.groundRim, 95));
                }
                if (y1 > y0 + 2) {
                    fgDraw.drawRect(Rect(x0, y0, x1 - x0, y1 - y0), toColor(PALETTE.steelDark, 235));
                    fgDraw.drawRect(Rect(x0, y1 - 4, x1 - x0, 4), toColor(theme.groundTop));
                    assets.tryPlace("wall", "stairs_" + i + "_" + k, (x0 + x1) * 0.5, y0,
                        x1 - x0, y1 - y0, { opacity: 0.76, layer: stairLayer });
                    assets.tryPlace("slab", "step_top_" + i + "_" + k, (x0 + x1) * 0.5, y1 - cam.len(4),
                        x1 - x0, cam.len(4), { layer: stairLayer + 1 });
                }
                fgDraw.drawSegment(Vec2(x0, y1), Vec2(x1, y1), 1.6, toColor(theme.groundRim));
                fgGlow.drawSegment(Vec2(x0, y1 + 1), Vec2(x1, y1 + 1), 0.9, toColor(theme.accent, 50));
            }
        }
    }

    /** 检查实体在运行时 p.boxes 中是否已打碎或仍处于隐藏状态，避免出现「破墙不消失 / 隐帘提前画」穿帮。 */
    private isSolidActive(p: Play, s: SolidSpec): boolean {
        let matched = false;
        let anyVisible = false;
        let i = 0;
        for (i = 0; i < p.boxes.length; i++) {
            const b = p.boxes[i];
            const sameId = s.id !== undefined && b.id === s.id;
            const sameGeom = Math.abs(b.x0 - s.x) < 0.5 && Math.abs(b.y0 - s.y) < 0.5
                && Math.abs((b.x1 - b.x0) - s.w) < 0.5 && Math.abs((b.y1 - b.y0) - s.h) < 0.5
                && (s.depth === undefined || (b.depth !== undefined && Math.abs(b.depth.min - s.depth.min) < 0.5));
            if (sameId || sameGeom) {
                matched = true;
                if (b.broken !== true && b.hidden !== true) {
                    anyVisible = true;
                }
            }
        }
        return !matched || anyVisible;
    }

    private drawSolids(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        theme: RoomTheme,
        time: number,
        occlusion: DepthOcclusion,
        fadeDt: number,
    ): void {
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            // 1) 装饰性实体（无碰撞）：不画成实心墙/掩体，避免出现能穿过去的假墙
            if (s.decorative === true || s.id === "e3_bench" || s.id === "tower_desk") {
                continue;
            }
            // 2) 同步运行时破碎/隐藏态（如薄木挡打碎、侧门抬闩、木帘未放落）
            if (!this.isSolidActive(p, s)) {
                continue;
            }
            // 3) 村口瓶架由 PropRenderer / VillageUndertablePlugin 专属镂空木架绘制，不叠画拉伸砖块
            if (p.room.key === "village" && s.label.indexOf("瓶架") >= 0) {
                continue;
            }
            const x0 = cam.sx(s.x);
            const x1 = cam.sx(s.x + s.w);
            if (p.room.depth !== undefined && s.depth !== undefined) {
                const opacity = occlusion.update("solid_" + i, {
                    x0: s.x, x1: s.x + s.w, y0: s.y, y1: s.y + s.h,
                    depth: s.depth, passThrough: s.passable === true || s.soft === true,
                }, p, fadeDt);
                if (x1 > 0 && x0 < cam.viewW) {
                    this.drawDepthSolid(fgDraw, assets, s, s.depth, x0, x1, cam, theme, opacity, p);
                }
                continue;
            }
            const y0 = cam.sy(s.y);
            const y1 = cam.sy(s.y + s.h);
            const sw = x1 - x0;
            const sh = y1 - y0;
            if (sw <= 1 || sh <= 1 || x1 < 0 || x0 > cam.viewW) {
                continue;
            }

            // 城外悬空城墙（y > 10）：补全背景支撑砖墩，消除空中悬浮灰块感（不给补丁红布车画砖墩）
            if (p.room.key === "outside" && s.y > 10 && s.id !== "outside_red_cart") {
                const groundY = cam.sy(0);
                const pierW = cam.len(16);
                fgDraw.drawRect(Rect(x0, groundY, pierW, y0 - groundY), Color(32, 37, 46, 215), 0.9, Color(68, 76, 88, 140));
                fgDraw.drawRect(Rect(x1 - pierW, groundY, pierW, y0 - groundY), Color(32, 37, 46, 215), 0.9, Color(68, 76, 88, 140));
            }

            // 1) 森林草丛（可穿过潜行植被）
            if (s.passable === true) {
                if (!assets.tryPlace("grass", "hide_grass_" + i, (x0 + x1) * 0.5, y0, sw, sh * 1.55,
                    { opacity: 0.79, layer: 7 })) {
                    this.drawGrassCluster(fgDraw, fgGlow, x0, y0, sw, sh, p.player.x, s.x + s.w * 0.5, time);
                }
                continue;
            }

            // 2) 城门绞盘
            if (s.label.indexOf("绞盘") >= 0) {
                this.drawWinch(fgDraw, assets, x0, y0, sw, sh, p, 2);
                continue;
            }

            // 3) 北塔塔身与门楣
            if (p.room.key === "tower") {
                this.drawTowerStructure(fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time);
                continue;
            }

            // 4) 补丁红布车（像素路线；低模路线由 lowpoly_world 插件画同一实体，不叠）
            if (s.art === "red_cart") {
                this.drawRedCartPixel(fgDraw, x0, y0, sw, sh, cam);
                continue;
            }

            // 4) 矮掩体（柜台 / 街垒 / 倒柜 / 矮墙 / 队栏）
            if (s.h <= 64 && s.y <= 2) {
                this.drawCoverBlock(fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme);
                continue;
            }

            fillVGradRect(fgDraw, x0, y0, sw, sh, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            this.tileMasonry(assets, s, x0, y0, sw, sh);
        }
    }

    private drawDepthSolid(
        draw: DrawNode.Type, assets: AssetSlotHost, solid: SolidSpec, depth: DepthRange,
        left: number, right: number, cam: CameraDirector, theme: RoomTheme, opacity: number, p: Play,
    ): void {
        const width = right - left;
        const base = cam.sy(solid.y, depth.min);
        const rearBase = cam.sy(solid.y, depth.max);
        const top = cam.sy(solid.y + solid.h, depth.min);
        const rear = cam.sy(solid.y + solid.h, depth.max);
        const frontH = top - base;
        const slot = coverArt(solid);
        const layer = depthOrder(depth.min, 1);
        const key = "depth_solid_" + solid.x + "_" + depth.min;
        const capHeight = rear - top;
        const center = (left + right) * 0.5;

        // 城门绞盘（带 middle 纵深）
        if (solid.label.indexOf("绞盘") >= 0) {
            this.drawWinch(draw, assets, left, base, width, frontH, p, layer);
            return;
        }

        if (solid.art === "gate_post" && depth.min > LANE_DEPTH.middle) {
            assets.tryPlace("slab", "gate_sill_" + solid.x, center, cam.sy(solid.y, LANE_DEPTH.middle - 6),
                width + cam.len(34), cam.len(12), { layer: 1, color: Color(180, 169, 150, 255) });
        }
        draw.drawEllipse(Vec2(center, base + cam.len(2)), width * 0.50,
            Math.max(2, cam.len(2.5)), Color(10, 10, 14, 128 * opacity));

        // Phase 3 专属明代场景道具（空筐墙 / 粮袋堆 / 木帘 / 窗板 / 石井栏）：采用独立手绘轮廓，保留 key 兼容遮挡与破碎巡检
        const propArt = dedicatedSolidProp(solid);
        if (propArt !== undefined) {
            const propPath = "assets/art/props_ming.clip|" + propArt.clip;
            const drawH = frontH * propArt.heightMul;
            const cols = propArt.tileable
                ? Math.max(1, Math.min(6, Math.round((solid.w / Math.max(1, solid.h)) / propArt.natAR)))
                : 1;
            const colW = width / cols;
            const tint = occlusionTint(opacity);
            let placedProp = false;
            for (let col = 0; col < cols; col++) {
                const tileKey = col === 0 ? key : key + "_c" + col;
                if (assets.tryPlacePath(propPath, tileKey, left + (col + 0.5) * colW, base, colW + 1, drawH, {
                    anchorX: 0.5,
                    anchorY: 0,
                    preserveAspect: !propArt.tileable && cols === 1 && solid.art === "board",
                    opacity,
                    color: tint,
                    layer,
                })) {
                    placedProp = true;
                }
            }
            if (placedProp) {
                return;
            }
        }

        const timber = slot === "cover_wood" || solid.art === "thin_wood" || solid.art === "board" || solid.art === "curtain";

        // 透视压扁后的顶面：沿用该实体自身材质贴图（柜沿/砖沿同纹），不再铺一整块带描边的纯色矩形
        if (slot !== "fence" && capHeight > 1) {
            const capTop = top + capHeight;
            if (!assets.tryPlace(slot, "cap_" + solid.x, center, top, width, capHeight,
                { opacity: Math.min(1, opacity), layer: layer })) {
                const capFill = occlusionTint(opacity, timber
                    ? Color(74, 56, 42, Math.round(232 * opacity))
                    : Color(74, 78, 86, Math.round(232 * opacity)));
                fillVGradRect(draw, left, top, width, capHeight,
                    capFill, occlusionTint(opacity, Color(44, 46, 52, Math.round(220 * opacity))));
            }
            draw.drawSegment(Vec2(left + width * 0.04, capTop - 0.5), Vec2(right - width * 0.04, capTop - 0.5),
                0.9, occlusionTint(opacity, timber
                    ? Color(122, 96, 72, Math.round(150 * opacity))
                    : Color(118, 124, 132, Math.round(140 * opacity))));
        }

        // 特例 1：细长竖木柱（檐柱/棚柱等 h > w*1.6 的木构）——使用像素竖木柱 fe_pillar_wood 分段平铺
        if (timber && solid.h > solid.w * 1.6) {
            const segs = Math.max(1, Math.min(6, Math.round(solid.h / Math.max(24, solid.w * 3.5))));
            const segH = frontH / segs;
            const colTint = occlusionTint(opacity);
            for (let pi = 0; pi < segs; pi++) {
                const tk = pi === 0 ? key : key + "_p" + pi;
                assets.tryPlace("fe_pillar_wood", tk, center, base + pi * segH, width + 0.5, segH + 0.5, {
                    layer, opacity, color: colTint,
                });
            }
            return;
        }

        // 特例 2：细长横向棚架木梁（w > h*5，如二段粮棚 600×8）——使用像素木梁 fe_beam_wood 分段平铺
        if (solid.w > solid.h * 5) {
            const segs = Math.max(2, Math.min(12, Math.round(solid.w / 64)));
            const segW = width / segs;
            const beamH = Math.max(5, frontH);
            const beamTint = occlusionTint(opacity);
            for (let bi = 0; bi < segs; bi++) {
                const tk = bi === 0 ? key : key + "_b" + bi;
                assets.tryPlace("fe_beam_wood", tk, left + (bi + 0.5) * segW, base, segW + 0.5, beamH, {
                    layer, opacity, color: beamTint,
                });
            }
            return;
        }

        // 通用等比平铺（按贴图固有长宽比拆分列与行，最大失真控制在 ~1.35× 内，同时保留 key 兼容 verify-depth.lua）
        const natAR = slot === "fence" ? 3.53 : (slot === "cover_wood" ? 2.52 : (slot === "cover_stone" ? 2.29 : 1.52));
        const cols = slot === "wall"
            ? Math.max(1, Math.min(10, Math.round(solid.w / 72)))
            : Math.max(1, Math.min(10, Math.round((solid.w / Math.max(1, solid.h)) / natAR)));
        const colW = width / cols;
        const rows = slot === "wall"
            ? Math.max(1, Math.min(10, Math.ceil((solid.h * 1.25) / Math.max(1, solid.w / cols))))
            : Math.max(1, Math.min(6, Math.round((solid.h / Math.max(1, solid.w / cols)) * natAR)));
        const rowHeight = frontH / rows;
        const masonryColor = slot === "wall" ? Color(181, 176, 167, 255) : undefined;
        const color = occlusionTint(opacity, masonryColor);
        let placedAny = false;
        for (let row = 0; row < rows; row++) {
            for (let col = 0; col < cols; col++) {
                const tileKey = (row === 0 && col === 0) ? key : key + "_r" + row + "_c" + col;
                if (assets.tryPlace(slot, tileKey, left + (col + 0.5) * colW, base + row * rowHeight, colW + 0.5, rowHeight + 0.5, {
                    layer, opacity, color, facing: (row + col) % 2 === 0 ? 1 : -1,
                })) {
                    placedAny = true;
                }
            }
        }
        if (!placedAny) {
            draw.drawRect(Rect(left, base, width, frontH),
                occlusionTint(opacity, toColor(PALETTE.steelMid, 255 * opacity)),
                1, toColor(theme.groundRim, 150 * opacity));
        }
    }

    private tileMasonry(
        assets: AssetSlotHost, s: SolidSpec,
        x: number, y: number, width: number, height: number,
    ): void {
        // 按 wall 贴图固有比例（82×54 ≈ 1.52）与合理单砖尺度（约 58×38 世界单位）等比切分，避免巨砖与竖拉畸变
        const columns = Math.max(1, Math.min(10, Math.round(s.w / 58)));
        const cellWorldW = s.w / columns;
        const targetCellH = Math.max(24, Math.min(48, cellWorldW / 1.52));
        const rows = Math.max(1, Math.min(12, Math.round(s.h / targetCellH)));
        const tileW = width / columns;
        const tileH = height / rows;
        for (let row = 0; row < rows; row++) {
            for (let column = 0; column < columns; column++) {
                assets.tryPlace("wall", "masonry_" + s.x + "_" + s.y + "_" + row + "_" + column,
                    x + (column + 0.5) * tileW, y + row * tileH, tileW + 0.5, tileH + 0.5,
                    { opacity: 0.86, facing: (row + column) % 2 === 0 ? 1 : -1 });
            }
        }
    }

    private drawCoverBlock(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        x0: number, y0: number, sw: number, sh: number,
        s: SolidSpec, p: Play, theme: RoomTheme,
    ): void {
        const slot = coverArt(s);
        const natAR = slot === "fence" ? 3.53 : (slot === "cover_wood" ? 2.52 : (slot === "cover_stone" ? 2.29 : 1.52));
        const cols = Math.max(1, Math.min(8, Math.round((s.w / Math.max(1, s.h)) / natAR)));
        const tileW = sw / cols;
        let placed = false;
        for (let c = 0; c < cols; c++) {
            const k = c === 0 ? ("cover_" + s.x) : ("cover_" + s.x + "_" + c);
            if (assets.tryPlace(slot, k, x0 + (c + 0.5) * tileW, y0, tileW + 0.5, sh, { layer: 1 })) {
                placed = true;
            }
        }
        if (!placed) {
            fillVGradRect(fgDraw, x0, y0, sw, sh, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            fgDraw.drawSegment(Vec2(x0, y0 + sh), Vec2(x0 + sw, y0 + sh), 1.4, toColor(theme.groundRim));
        }

        // 明初写实贴靠提示：克制木沿/砖沿微亮边线（M1 清理冰青全息护盾光晕，兼顾静音与灰度可读）
        if (!p.childMode && (p.coverHug || p.coverNear)) {
            const plx = p.player.x;
            const nearLeft = Math.abs(plx - s.x) < 42;
            const nearRight = Math.abs(plx - (s.x + s.w)) < 42;
            if (nearLeft || nearRight) {
                const edgeX = nearLeft ? x0 - 1.5 : x0 + sw + 1.5;
                const isWood = slot === "cover_wood";
                const col = p.coverHug ? (isWood ? PALETTE.amberCore : PALETTE.moonPale) : PALETTE.silkDim;
                fgDraw.drawSegment(Vec2(edgeX, y0 + 4), Vec2(edgeX, y0 + sh + 2), p.coverHug ? 2.0 : 1.2, toColor(col, p.coverHug ? 205 : 120));
            }
        }
    }




    /** 补丁红布车（像素路线）：木车板、红布补丁、车柄与木轮。 */
    private drawRedCartPixel(
        draw: DrawNode.Type, x0: number, y0: number, sw: number, sh: number, cam: CameraDirector,
    ): void {
        const bodyH = Math.max(6, sh * 0.62);
        const bodyY = y0 + sh - bodyH;
        draw.drawRect(Rect(x0, bodyY, sw, bodyH), Color(92, 70, 52, 248), 1.0, Color(150, 118, 86, 215));
        draw.drawRect(Rect(x0 - cam.len(3), bodyY + cam.len(1), sw + cam.len(8), bodyH * 0.92),
            toColor(PALETTE.clothRed), 1.0, toColor(PALETTE.clothRedHighlight));
        draw.drawRect(Rect(x0 + sw * 0.16, bodyY + bodyH * 0.36, sw * 0.24, bodyH * 0.32),
            Color(214, 206, 188, 215));
        draw.drawRect(Rect(x0 + sw * 0.58, bodyY + bodyH * 0.52, sw * 0.18, bodyH * 0.22),
            Color(196, 188, 172, 200));
        draw.drawSegment(Vec2(x0 + sw - cam.len(2), bodyY + bodyH * 0.72),
            Vec2(x0 + sw + cam.len(26), bodyY + bodyH * 1.36),
            Math.max(2, cam.len(2.6)), Color(126, 98, 68, 240));
        draw.drawEllipse(Vec2(x0 + sw * 0.26, y0 + sh - cam.len(1)), cam.len(5.2), cam.len(5.2),
            Color(40, 34, 30, 235));
        draw.drawEllipse(Vec2(x0 + sw * 0.26, y0 + sh - cam.len(1)), cam.len(2.1), cam.len(2.1),
            Color(150, 126, 92, 220));
    }

    private drawWinch(
        draw: DrawNode.Type,
        assets: AssetSlotHost,
        x0: number, y0: number, sw: number, sh: number,
        p: Play,
        layer: number = 2,
    ): void {
        const cx = x0 + sw * 0.5;
        const cy = y0 + sh * 0.55;
        const ropeWidth = Math.max(1, sw * 0.023);
        const ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45);
        const drum = Vec2(cx + sw * 0.12, cy + sh * 0.18);
        const slack = p.phase === "gate-idle" ? sw * 0.09 : 0;
        const bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5);
        draw.drawEllipse(Vec2(cx, y0), sw * 0.53, sh * 0.07, Color(10, 8, 9, 150));
        draw.drawSegment(drum, bend, ropeWidth, Color(111, 86, 57, 239));
        draw.drawSegment(bend, ropeTop, ropeWidth, Color(111, 86, 57, 239));
        if (assets.tryPlace("prop_winch", "gate_winch", cx, y0 + sh * 0.5, sw, sh, { layer })) {
            return;
        }
        const timber = Color(75, 51, 34, 255);
        draw.drawSegment(Vec2(x0 + sw * 0.15, y0 + sh * 0.07), Vec2(cx, y0 + sh * 0.86), sw * 0.06, timber);
        draw.drawSegment(Vec2(x0 + sw * 0.85, y0 + sh * 0.07), Vec2(cx, y0 + sh * 0.86), sw * 0.06, timber);
        draw.drawRect(Rect(x0, y0, sw, sh * 0.12), timber);
        const radius = Math.min(sw, sh) * 0.21;
        draw.drawCircle(Vec2(cx, cy), radius, Color(48, 41, 37, 255));
        for (let i = -2; i <= 2; i++) {
            const x = cx + i * radius * 0.28;
            draw.drawSegment(Vec2(x, cy - radius * 0.62), Vec2(x, cy + radius * 0.62), ropeWidth,
                Color(135, 103, 68, 240));
        }
    }

    private drawGateShutter(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
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
        } else if (p.phase === "gate-walk" || p.phase === "gate-wait" || p.phase === "gate-hand") {
            closeFrac = 1.0;
        }
        const gx0 = cam.sx(848);
        const gx1 = cam.sx(1032);
        const topY = cam.sy(160);
        const botY = cam.sy(160 * (1 - closeFrac));
        const shutterW = gx1 - gx0;
        const shutterH = topY - botY;
        if (shutterH > 2) {
            fillVGradRect(fgDraw, gx0, botY, shutterW, shutterH, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            // 分排木闸条平铺，避免将横向 cover_wood 暴力拉伸成竖门
            const rows = Math.max(1, Math.min(6, Math.ceil(shutterH / Math.max(18, shutterW / 2.6))));
            const rowH = shutterH / rows;
            for (let r = 0; r < rows; r++) {
                assets.tryPlace("cover_wood", "gate_shutter_" + r, (gx0 + gx1) * 0.5, botY + r * rowH,
                    shutterW, rowH + 0.5, { layer: 6 });
            }
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
        assets: AssetSlotHost,
        x0: number, y0: number, sw: number, sh: number,
        s: SolidSpec, p: Play, cam: CameraDirector, time: number,
    ): void {
        fillVGradRect(fgDraw, x0, y0, sw, sh, Color(15, 21, 34, 255), Color(32, 44, 66, 255));
        fgDraw.drawRect(Rect(x0, y0, sw, sh), Color(0, 0, 0, 0), 1.4, toColor(PALETTE.rimSilver, 165));

        if (s.label.indexOf("塔身") >= 0) {
            this.tileMasonry(assets, s, x0, y0, sw, sh);
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
            const opened = p.towerDoorOpen
                || p.phase === "tower-enter"
                || p.phase === "tower-desk"
                || p.phase === "tower-given"
                || p.phase === "tower-end";
            const cx = x0 + sw * 0.5;
            const lampY = y0 - 8;
            const doorHeight = y0 - Math.max(0, y0 - sh * 3.8);
            if (!opened) {
                assets.tryPlace("prop_tower_door", "tower_door", cx, y0 - doorHeight, sw, doorHeight, { layer: 2 });
            }
            assets.tryPlace("prop_lantern", "tower_lantern", cx + sw * 0.43, lampY - sh * 0.36,
                sw * 0.17, sh * 0.84, { layer: 3 });
            const pulse = 0.85 + 0.15 * Math.sin(time * 3);
            const alpha = opened ? 58 : 42;
            // 门框重型立柱与门板纹理
            fgDraw.drawSegment(Vec2(x0 + 4, y0), Vec2(x0 + 4, y0 - sh * 3.8), 4, Color(42, 52, 70, 255));
            fgDraw.drawSegment(Vec2(x0 + sw - 4, y0), Vec2(x0 + sw - 4, y0 - sh * 3.8), 4, Color(42, 52, 70, 255));
            fgDraw.drawSegment(Vec2(x0, y0), Vec2(x0 + sw, y0), 2.5, toColor(PALETTE.amber, 210));
            // 门洞暖光溢出（克制暖黄透雾，避免加法混合过曝惨白）
            fillVGradRect(
                fgGlow,
                x0 + 6,
                y0 - sh * 3.8,
                sw - 12,
                sh * 3.8,
                Color(246, 196, 118, Math.round((opened ? alpha : alpha * 0.35) * pulse)),
                Color(246, 206, 142, opened ? 74 : 38),
            );
            fillRadialGlow(fgGlow, cx, lampY, opened ? 78 : 54, opened ? 72 : 52, Color(252, 218, 152, Math.round(92 * pulse)), Color(255, 180, 86, 0), 18);
            fgDraw.drawCircle(Vec2(cx, lampY), 4.5, toColor(PALETTE.amberCore));

            // 门开后渲染值夜室木案、守卒剪影、油灯、登记簿与渐进交物（针套 / 指南针 / 纸条）
            if (opened) {
                const deskCx = cam.sx(p.ox + 605);
                const groundY = cam.sy(0);
                const deskW = cam.len(84);
                const deskH = cam.len(34);
                const deskTop = groundY + deskH;
                const writing = p.deskHold >= 24 || p.towerHanded;
                // 值夜室暖光背景
                fillRadialGlow(fgGlow, deskCx, deskTop + cam.len(26), cam.len(96), cam.len(74),
                    Color(255, 198, 114, Math.round(52 * pulse)), Color(255, 168, 72, 0), 16);
                // 值夜守卒高精像素 4 帧活态动画（提灯轻摆呼吸 / 伏案执笔书录）
                const guardX = deskCx + cam.len(26);
                const guardFrame = Math.floor(time * (writing ? 3.2 : 3.8)) % 4;
                const guardClip = writing
                    ? GUARD_WRITE_CLIPS[guardFrame]
                    : GUARD_LANTERN_CLIPS[guardFrame];
                if (!assets.tryPlacePath(guardClip, "tower_guard_npc", guardX, groundY, cam.len(54), cam.len(86), {
                    anchorX: 0.5,
                    anchorY: 0,
                    preserveAspect: true,
                    facing: -1,
                    opacity: 0.96,
                    layer: 3,
                })) {
                    fgDraw.drawRect(Rect(guardX - cam.len(11), groundY, cam.len(22), cam.len(68)), Color(34, 42, 54, 240));
                    fgDraw.drawCircle(Vec2(guardX, groundY + cam.len(76)), cam.len(9.5), Color(42, 50, 62, 245));
                }
                // 木案本体与案面（优先用透明镂空桌腿 prop_table，保证守卒鞋靴自然可见无暗板遮挡）
                if (!assets.tryPlace("prop_table", "tower_guard_desk", deskCx, groundY, deskW * 1.06, deskH * 1.04, {
                    color: Color(214, 188, 158, 255),
                    opacity: 0.98,
                    layer: 4,
                })) {
                    fgDraw.drawRect(Rect(deskCx - deskW * 0.5, groundY, cam.len(6), deskH), Color(78, 52, 34, 255));
                    fgDraw.drawRect(Rect(deskCx + deskW * 0.5 - cam.len(6), groundY, cam.len(6), deskH), Color(78, 52, 34, 255));
                    fgDraw.drawRect(Rect(deskCx - deskW * 0.52, deskTop - cam.len(6), deskW * 1.04, cam.len(8)), Color(108, 74, 46, 255), 1, Color(148, 108, 68, 220));
                }
                // 案头摊开的收籍薄册；仅伏案写簿时案角置油灯，提灯立守时直接以手中纸灯作光源防重灯
                fgDraw.drawRect(Rect(deskCx + cam.len(4), deskTop + cam.len(1), cam.len(22), cam.len(4.5)), Color(232, 222, 198, 245));
                if (writing) {
                    assets.tryPlace("prop_lantern", "tower_desk_lamp", deskCx + cam.len(34), deskTop + cam.len(10), cam.len(14), cam.len(20), { layer: 5 });
                    fillRadialGlow(fgGlow, deskCx + cam.len(34), deskTop + cam.len(12), cam.len(24), cam.len(22), Color(255, 214, 134, Math.round(88 * pulse)), Color(255, 180, 86, 0), 12);
                } else {
                    fillRadialGlow(fgGlow, deskCx + cam.len(3), deskTop + cam.len(18), cam.len(30), cam.len(28), Color(255, 214, 134, Math.round(78 * pulse)), Color(255, 180, 86, 0), 12);
                }
                // 渐进交物视觉（12 拍针套、24 拍指南针与纸条）
                if (p.deskHold >= 12 || p.towerHanded) {
                    if (!assets.tryPlacePath("assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", "tower_desk_pouch", deskCx - cam.len(22), deskTop + cam.len(8), cam.len(18), cam.len(18), {
                        anchorX: 0.5,
                        anchorY: 0.5,
                        smooth: true,
                        layer: 5,
                    })) {
                        fgDraw.drawRect(Rect(deskCx - cam.len(28), deskTop + cam.len(2), cam.len(14), cam.len(6)), Color(156, 62, 48, 245));
                    }
                }
                if (writing) {
                    fgDraw.drawRect(Rect(deskCx - cam.len(6), deskTop + cam.len(2), cam.len(10), cam.len(3)), Color(236, 228, 206, 240));
                }
            }
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
        draw: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const a = p.room.arch;
        if (p.room.key !== "outside" || a.h <= 0 || a.x1 <= a.x0) {
            return;
        }
        const x0 = cam.sx(a.x0);
        const x1 = cam.sx(a.x1);
        const y0 = cam.sy(a.y);
        const y1 = cam.sy(a.y + a.h);
        const cx = (x0 + x1) * 0.5;
        const aw = x1 - x0;
        const ah = y1 - y0;
        draw.drawRect(Rect(x0, y0, aw, ah + cam.len(8)), Color(13, 15, 20, 242));
        if (!assets.tryPlace("fe_outside_arch", "outside_arch_vault", cx, y0, aw + cam.len(24), ah + cam.len(22), { layer: 2 })) {
            draw.drawRect(Rect(x0 - cam.len(7), y0, cam.len(7), ah), Color(62, 63, 67, 255));
            draw.drawRect(Rect(x1, y0, cam.len(7), ah), Color(72, 72, 74, 255));
        }
        // 城外板车未入窝时，在拱口内绘制连至上层板车的像素阻挡木栓，入窝后自动收回
        if (!p.cartDocked) {
            const bx0 = cam.sx(Math.max(a.x0 + 4, p.cartAxle - 18));
            const bx1 = cam.sx(Math.min(a.x1 - 4, p.cartAxle + 18));
            if (bx1 > bx0 + 4) {
                const deckY = cam.sy(p.room.cart.baseY);
                assets.tryPlace("fe_pillar_wood", "outside_arch_bolt", (bx0 + bx1) * 0.5, y0 + 2, bx1 - bx0, ah - 2, { layer: 3 });
                draw.drawSegment(Vec2((bx0 + bx1) * 0.5, y1), Vec2((bx0 + bx1) * 0.5, deckY), 2.4, Color(96, 102, 110, 220));
            }
        }
    }
}
