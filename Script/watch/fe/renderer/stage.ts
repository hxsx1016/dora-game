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
    if (solid.art === "thin_wood") {
        return { clip: "window_board", natAR: 88 / 144, heightMul: 1, tileable: true };
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
    if (solid.art === "gate_post" || solid.art === "wall") {
        return "wall";
    }
    if (solid.art === "thin_wood" || solid.art === "board" || solid.art === "cover_wood") {
        return "cover_wood";
    }
    if (solid.art === "cover_stone") {
        return "cover_stone";
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

function tintByShade(base: Color.Type, shade: number): Color.Type {
    return Color(
        Math.max(0, Math.min(255, Math.round(base.r * shade))),
        Math.max(0, Math.min(255, Math.round(base.g * shade))),
        Math.max(0, Math.min(255, Math.round(base.b * shade))),
        base.a,
    );
}

export class StageRenderer {
    /** 绘制背景三层（暗黑像素远景底图 + 锁定地平线的中景视差 + 底部冷月薄雾） */
    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        _time: number,
    ): void {
        const w = cam.viewW;
        const h = cam.viewH;
        const theme = themeOf(p.room.key);

        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const backdropKey = theme.backdropKey ?? p.room.key;
        const farSlot = ("bgFar_" + backdropKey) as AssetSlotKey;
        // 严格将 640×360 暗黑像素底图的底部石基顶线（约 25% 高度）锚死在 2.5D 路面后缘，
        // 消除背景漂浮与人物在画布上打滑的错位感。
        const backRoadY = cam.sy(0, p.room.depth !== undefined ? p.room.depth.max : 0);
        const artW = Math.max(w, h * 16 / 9) * 1.10;
        const artH = artW * 9 / 16;
        const artY = Math.min(0, Math.max(h - artH, backRoadY - artH * 0.25));
        if (assets.tryPlace(farSlot, "scene", w * (0.5 - progress * 0.08), artY, artW, artH)) {
            this.drawDressing(assets, backdropKey, cam, progress, backRoadY);
            fillVGradRect(bgDraw, 0, 0, w, h, toColor(PALETTE.voidDark), toColor(theme.skyMid));
            fillVGradRect(bgGlow, 0, backRoadY - 2, w, h * 0.14, Color(43, 54, 72, 20), Color(43, 54, 72, 0));
            return;
        }

        // 底图缺失时的极简冷月暗夜渐变兜底（已彻底清除旧程序化几何剪影灰模）
        const splitY = h * 0.46;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(theme.skyMid), toColor(theme.skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(theme.skyHorizon), toColor(theme.skyMid));
        if (theme.showMoon) {
            const mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015;
            const my = h * theme.moonYFrac;
            const mr = Math.max(18, h * 0.044);
            fillRadialGlow(bgGlow, mx, my, mr * 4.6, mr * 4.6, Color(148, 178, 206, 28), Color(20, 32, 52, 0), 18);
            bgDraw.drawCircle(Vec2(mx, my), mr, Color(218, 232, 242, 215));
        }
        fillVGradRect(
            bgGlow,
            0,
            backRoadY - 10,
            w,
            h * 0.30,
            toColor(theme.fogBottom),
            Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0),
        );
    }

    private drawDressing(
        assets: AssetSlotHost,
        backdropKey: string,
        cam: CameraDirector,
        progress: number,
        backRoadY: number,
    ): void {
        const w = cam.viewW;
        const x = w * (0.76 - progress * 0.24);
        // 所有中景装饰统一落脚在 backRoadY 路面后缘，杜绝悬空浮游；
        // prologue / village / checkpoint 已由高精暗黑像素底图自带完整建筑群，不再叠放半透明旧 eaves 矩形块。
        if (backdropKey === "forest" || backdropKey === "outside" || backdropKey === "tower") {
            assets.tryPlace("pine", "mid_pine", x, backRoadY - cam.len(4), cam.len(118), cam.len(104),
                { layer: 1, opacity: 0.48 });
        } else if (backdropKey === "street") {
            assets.tryPlace("dp_ruin_house_a", "mid_ruin", x, backRoadY - cam.len(4), cam.len(132), cam.len(118),
                { layer: 1, opacity: 0.42 });
        }
        if (backdropKey === "street" || backdropKey === "checkpoint" || backdropKey === "prologue") {
            const lanternSway = Math.sin(progress * 6 + cam.x * 0.004) * 2.5;
            assets.tryPlace("prop_lantern", "mid_lantern", w * (0.27 - progress * 0.20),
                backRoadY + cam.len(86), cam.len(20), cam.len(28), { layer: 2, opacity: 0.86, angle: lanternSway });
        }
    }

    /** 标题菜单兜底背景（底图缺失时以深暗冷月渐变兜底，零程序化几何剪影灰模） */
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
        const mx = w * 0.61;
        const my = h * 0.74;
        const mr = h * 0.068;
        const pulse = 0.86 + 0.14 * Math.sin(time * 2.0);
        fillRadialGlow(bgGlow, mx, my, mr * 4.4 * pulse, mr * 4.4 * pulse, Color(156, 180, 198, 28), Color(16, 22, 34, 0), 20);
        bgDraw.drawCircle(Vec2(mx, my), mr, Color(224, 232, 236, 218));
        const groundY = h * 0.19;
        fillVGradRect(bgDraw, 0, 0, w, groundY, Color(9, 11, 17, 255), Color(18, 23, 33, 255));
        bgDraw.drawSegment(Vec2(0, groundY), Vec2(w, groundY), 1.4, toColor(PALETTE.silkDim, 145));
    }

    /** 绘制逻辑平面建筑（暗黑像素三车道透视路面、石阶、3D 体积掩体、边界封口、城门闸门） */
    drawPlayableWorld(
        groundDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        occlusion: DepthOcclusion,
        fadeDt: number,
        groundArt?: AssetSlotHost,
        roadLineDraw?: DrawNode.Type,
        overlayDraw?: DrawNode.Type,
    ): void {
        const theme = themeOf(p.room.key);
        const gArt = groundArt ?? assets;
        const rLine = roadLineDraw ?? groundDraw;
        const oDraw = overlayDraw ?? rLine;
        this.drawFloors(groundDraw, rLine, gArt, p, cam, theme);
        this.drawStairs(rLine, fgGlow, assets, p, cam, theme);
        this.drawBoundaryClosures(assets, p, cam);
        this.drawSolids(rLine, oDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt);
        if (p.room.key === "gate") {
            this.drawGateShutter(rLine, fgGlow, assets, p, cam, time);
        }
        this.drawArch(rLine, assets, p, cam);
    }

    /** 绘制柔和电影暗角（在 worldOverlayDraw 层，不压暗清晰路面） */
    drawForegroundFraming(
        fgDraw: DrawNode.Type,
        w: number,
        h: number,
        _p: Play,
        _cam: CameraDirector,
    ): void {
        fillVGradRect(fgDraw, 0, h - h * 0.14, w, h * 0.14, Color(4, 6, 12, 0), Color(4, 6, 12, 118));
        fillVGradRect(fgDraw, 0, 0, w, h * 0.11, Color(4, 6, 12, 152), Color(4, 6, 12, 0));
    }

    /** 为缺少实体封口墙的 2.5D 房间两端补充实景拒马/断墙封口，消除“前方仍是空路却撞空气墙”错位。 */
    private drawBoundaryClosures(assets: AssetSlotHost, p: Play, cam: CameraDirector): void {
        const road = p.room.depth;
        if (road === undefined) {
            return;
        }
        if (p.room.key === "outside" || p.room.key === "village" || p.room.key === "forest" || p.room.key === "tower" || p.room.key === "museum") {
            return;
        }
        const hasWallNear = (targetX: number): boolean => {
            for (let i = 0; i < p.room.solids.length; i++) {
                const s = p.room.solids[i];
                if (s.decorative === true) continue;
                if (s.h >= 100 && (Math.abs(s.x - targetX) <= 85 || Math.abs((s.x + s.w) - targetX) <= 85)) {
                    return true;
                }
            }
            return false;
        };
        const minX = p.room.minX;
        const maxX = p.room.maxX;
        const backY = cam.sy(0, road.max);
        const frontY = cam.sy(0, road.min);
        const barW = cam.len(46);
        const barH = cam.len(84);
        if (!hasWallNear(minX)) {
            const lx = cam.sx(minX + 6);
            if (lx + barW > -20 && lx - barW < cam.viewW + 20) {
                assets.tryPlace("dp_boundary_barricade", "bound_left_back", lx, backY - cam.len(4), barW * 0.92, barH * 0.92, {
                    layer: depthOrder(road.max, 0), opacity: 0.88,
                });
                assets.tryPlace("dp_boundary_barricade", "bound_left_front", lx - cam.len(6), frontY - cam.len(2), barW, barH * 0.72, {
                    layer: depthOrder(road.min, 0), opacity: 0.94,
                });
            }
        }
        if (!hasWallNear(maxX)) {
            const rx = cam.sx(maxX - 6);
            if (rx + barW > -20 && rx - barW < cam.viewW + 20) {
                assets.tryPlace("dp_boundary_barricade", "bound_right_back", rx, backY - cam.len(4), barW * 0.92, barH * 0.92, {
                    layer: depthOrder(road.max, 0), opacity: 0.88, facing: -1,
                });
                assets.tryPlace("dp_boundary_barricade", "bound_right_front", rx + cam.len(6), frontY - cam.len(2), barW, barH * 0.72, {
                    layer: depthOrder(road.min, 0), opacity: 0.94, facing: -1,
                });
            }
        }
    }

    private drawFloors(
        groundDraw: DrawNode.Type,
        roadLineDraw: DrawNode.Type,
        groundArt: AssetSlotHost,
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
                this.drawRoad(groundDraw, roadLineDraw, groundArt, i, left, right, top, cam.sy(floor.y, road.max), road, cam, theme);
            }
            const height = cam.len(isMain ? 22 : 12);
            const bottom = top - height;
            if (isMain && bottom > 0) {
                fillVGradRect(groundDraw, left, 0, right - left, bottom + 1,
                    toColor(PALETTE.voidDark), toColor(theme.groundBody));
            }
            const step = cam.len(96);
            const start = Math.max(0, Math.floor(-left / step));
            for (let j = start; left + j * step < Math.min(right, cam.viewW); j++) {
                const x = left + j * step;
                const width = Math.min(step, right - x);
                groundArt.tryPlace("slab", "deck_" + i + "_" + j, x + width * 0.5, bottom, width + 0.5, height, { layer: 3 });
                if (grass && isMain && j % 3 === 1) {
                    groundArt.tryPlace("grass_low", "edge_" + i + "_" + j, x + width * 0.5,
                        top - cam.len(3), width * 0.74, cam.len(13), { opacity: 0.85, layer: 5 });
                }
            }
            roadLineDraw.drawSegment(Vec2(left, top), Vec2(right, top), 1.2, toColor(theme.groundRim, 160));
        }
    }

    /**
     * 2.5D 暗黑像素三车道透视青石路面：
     * - 下/中/上三条车道使用专属无接缝暗黑青石贴图（dp_road_lower / dp_road_mid / dp_road_upper），按明度与肌理自然区分；
     * - 石板纵缝向屏幕中心地平线灭点轻微斜向收束，形成真实横版 2.5D 透视进深；
     * - 前后边界铺设石雕路缘石（dp_road_curb）与墙根排水暗沟，直观标示 LANE_ROAD 物理边界。
     */
    private drawRoad(
        groundDraw: DrawNode.Type,
        roadLineDraw: DrawNode.Type,
        groundArt: AssetSlotHost,
        floorIdx: number,
        left: number,
        right: number,
        front: number,
        back: number,
        road: DepthRange,
        cam: CameraDirector,
        theme: RoomTheme,
    ): void {
        const width = right - left;
        const height = back - front;
        if (width <= 1 || height <= 1) {
            return;
        }
        const nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.36);
        const farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.52);
        fillVGradRect(groundDraw, left, front, width, height, toColor(nearCol), toColor(farCol));

        const visLeft = Math.max(left, -96);
        const visRight = Math.min(right, cam.viewW + 96);

        // 1. 三车道暗黑青石贴图平铺（渲染在 groundArt order=22，严格位于 worldArt 阴影与角色之下）
        const lanes: { slot: string; f0: number; f1: number; tileW: number }[] = [
            { slot: "dp_road_lower", f0: 0.00, f1: 0.34, tileW: cam.len(104) },
            { slot: "dp_road_mid", f0: 0.34, f1: 0.68, tileW: cam.len(96) },
            { slot: "dp_road_upper", f0: 0.68, f1: 1.00, tileW: cam.len(86) },
        ];
        for (let li = 0; li < lanes.length; li++) {
            const ln = lanes[li];
            const y0 = front + ln.f0 * height;
            const y1 = front + ln.f1 * height;
            const lh = y1 - y0;
            const twBase = Math.max(48, ln.tileW);
            const tStart = Math.max(0, Math.floor((visLeft - left) / twBase));
            for (let col = tStart; left + col * twBase < visRight; col++) {
                const tx0 = left + col * twBase;
                const tw = Math.min(twBase, right - tx0);
                if (tw <= 2) continue;
                groundArt.tryPlace(ln.slot, "road_lane_" + floorIdx + "_" + li + "_" + col, tx0 + tw * 0.5, y0, tw + 0.8, lh + 0.8, {
                    layer: 2,
                    opacity: 0.96,
                });
            }
        }

        // 2. 前缘石雕路缘石（清楚界定 depth.min 边界）
        const curbW = Math.max(48, cam.len(96));
        const curbH = Math.max(5, cam.len(7));
        const cStart = Math.max(0, Math.floor((visLeft - left) / curbW));
        for (let col = cStart; left + col * curbW < visRight; col++) {
            const tx0 = left + col * curbW;
            const tw = Math.min(curbW, right - tx0);
            if (tw <= 2) continue;
            groundArt.tryPlace("dp_road_curb", "road_curb_" + floorIdx + "_" + col, tx0 + tw * 0.5, front - curbH * 0.35, tw + 0.8, curbH, {
                layer: 4,
            });
        }

        // 3. 单点透视收束石板接缝 + 柔和车道分界线（绘制在 fgDraw order=30，位于青石贴图之上、角色阴影之下！）
        const jointDark = Color(8, 11, 18, 138);
        const laneHint = Color(138, 166, 188, 44);
        const vpX = cam.viewW * 0.5;
        const stepWorld = 64;
        const firstJoint = Math.floor((cam.x - (cam.viewW * 0.65) / cam.ppu) / stepWorld);
        const lastJoint = Math.ceil((cam.x + (cam.viewW * 0.65) / cam.ppu) / stepWorld);
        for (let j = firstJoint; j <= lastJoint; j++) {
            const xFront = cam.sx(j * stepWorld);
            if (xFront < left - 60 || xFront > right + 60) continue;
            // 后缘向视口中心轻微透视收束，建立清晰 2.5D 景深指向
            const xBack = vpX + (xFront - vpX) * cam.depthScale(road.max, true);
            const cFront = Math.max(left, Math.min(right, xFront));
            const cBack = Math.max(left, Math.min(right, xBack));
            roadLineDraw.drawSegment(Vec2(cFront, front), Vec2(cBack, back), 1.0, jointDark);
        }

        // 下/中/上三车道之间的极克制磨损石缝线（帮助玩家直觉判断车道归属，无网游网格感）
        for (const frac of [0.34, 0.68]) {
            const ly = front + frac * height;
            roadLineDraw.drawSegment(Vec2(left, ly), Vec2(right, ly), 1.0, jointDark);
            roadLineDraw.drawSegment(Vec2(left, ly + 1.1), Vec2(right, ly + 1.1), 0.7, laneHint);
        }
        // 后墙脚排水暗影带 + 冷月路缘亮边
        fillVGradRect(roadLineDraw, left, back - Math.max(4, height * 0.14), width, Math.max(4, height * 0.14),
            Color(6, 8, 14, 0), Color(6, 8, 14, 155));
        roadLineDraw.drawSegment(Vec2(left, front), Vec2(right, front), 1.5, toColor(theme.groundRim, 168));
        roadLineDraw.drawSegment(Vec2(left, back), Vec2(right, back), 1.3, Color(118, 144, 166, 95));
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
            const depthEnabled = p.room.depth !== undefined;
            const dMin = depthEnabled
                ? (st.depth !== undefined ? st.depth.min : p.room.depth!.min)
                : 0;
            const dMax = depthEnabled
                ? (st.depth !== undefined ? st.depth.max : p.room.depth!.max)
                : 0;
            const flatTop = Math.abs(st.y1 - st.y0) < 0.01;
            const baseWorldY = flatTop ? 0 : Math.max(0, st.y0);
            const stairLayer = depthEnabled ? depthOrder(dMin, 0) : 0;
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
                const sw = x1 - x0;
                const cx = (x0 + x1) * 0.5;
                // 2.5D 石阶顶面踏板用暗黑石板顶贴图，立面按阶高平铺砌石块（杜绝拉长竖条灰面）
                if (yRear > y1 + 1) {
                    assets.tryPlace("dp_stone_top", "stairs_cap_" + i + "_" + k, cx, y1, sw + 0.8, yRear - y1 + 0.5, {
                        layer: stairLayer,
                        opacity: 0.96,
                    });
                }
                const riserH = y1 - y0;
                if (riserH > 2) {
                    const courseH = Math.max(12, cam.len(14));
                    const courses = Math.max(1, Math.min(8, Math.ceil(riserH / courseH)));
                    const ch = riserH / courses;
                    for (let ci = 0; ci < courses; ci++) {
                        const slotName = ci === courses - 1 ? "dp_stair_step" : "wall";
                        assets.tryPlace(slotName, "stairs_" + i + "_" + k + "_" + ci, cx, y0 + ci * ch, sw + 0.8, ch + 0.6, {
                            layer: stairLayer + 1,
                            color: ci === courses - 1 ? Color(246, 250, 255, 255) : Color(196, 206, 218, 255),
                        });
                    }
                }
                fgDraw.drawSegment(Vec2(x0, y1), Vec2(x1, y1), 1.4, toColor(theme.groundRim, 165));
                fgGlow.drawSegment(Vec2(x0, y1 + 1), Vec2(x1, y1 + 1), 0.8, toColor(theme.accent, 42));
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
        overlayDraw: DrawNode.Type,
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
            // 1) 装饰性实景地标（如序章侧灶/井沿）：锚定在后墙路缘作为无碰撞背景道具绘制，避免隐身也绝不误当实墙
            if (s.decorative === true) {
                if (p.room.depth !== undefined && (s.art === "stove_hearth" || s.art === "well")) {
                    const bx = cam.sx(s.x + s.w * 0.5);
                    if (bx > -80 && bx < cam.viewW + 80) {
                        const backDepth = p.room.depth.max;
                        const by = cam.sy(0, backDepth);
                        const dLayer = depthOrder(backDepth, -2);
                        const dScale = cam.depthScale(backDepth, true);
                        assets.tryPlace("dp_shadow_contact", "decor_sh_" + i, bx, by, cam.len(s.w * 1.15) * dScale, cam.len(7) * dScale, {
                            layer: dLayer - 1, opacity: 0.72,
                        });
                        if (s.art === "stove_hearth") {
                            assets.tryPlace("dp_stove_hearth", "decor_stove_" + i, bx, by, cam.len(s.w * 1.1) * dScale, cam.len(28) * dScale, {
                                layer: dLayer,
                            });
                        } else {
                            assets.tryPlacePath("assets/art/props_ming.clip|well_curb", "decor_well_" + i, bx, by, cam.len(s.w * 1.25) * dScale, cam.len(34) * dScale, {
                                anchorX: 0.5, anchorY: 0, preserveAspect: true, layer: dLayer,
                            });
                        }
                    }
                }
                continue;
            }
            if (s.id === "e3_bench" || s.id === "tower_desk") {
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
                    this.drawDepthSolid(fgDraw, overlayDraw, fgGlow, assets, s, s.depth, x0, x1, cam, theme, opacity, p);
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

            // 城外悬空城墙（y > 10）：使用暗黑石砖立柱贴图支撑，消除灰矩形砖墩
            if (p.room.key === "outside" && s.y > 10) {
                const groundY = cam.sy(0);
                const pierW = cam.len(16);
                assets.tryPlace("dp_wall_side", "outside_pier_l_" + i, x0 + pierW * 0.5, groundY, pierW, y0 - groundY, { layer: 0 });
                assets.tryPlace("dp_wall_side", "outside_pier_r_" + i, x1 - pierW * 0.5, groundY, pierW, y0 - groundY, { layer: 0 });
            }

            // 1) 森林草丛（可穿过潜行植被）
            if (s.passable === true) {
                if (!assets.tryPlace("grass", "hide_grass_" + i, (x0 + x1) * 0.5, y0, sw, sh * 1.55,
                    { opacity: 0.85, layer: 7 })) {
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

            // 4) 补丁红布车（接入暗黑像素精灵 dp_red_cart，清除纯几何灰盒车）
            if (s.art === "red_cart") {
                assets.tryPlace("dp_shadow_contact", "red_cart_sh", (x0 + x1) * 0.5, y0 + 1, sw * 1.25, cam.len(8), { layer: 1, opacity: 0.82 });
                assets.tryPlace("dp_red_cart", "red_cart_sprite", (x0 + x1) * 0.5, y0, sw * 1.38, sh * 1.15, { layer: 2 });
                continue;
            }

            // 5) 矮掩体（柜台 / 街垒 / 倒柜 / 矮墙 / 队栏）
            if (s.h <= 64 && s.y <= 2) {
                this.drawCoverBlock(overlayDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme);
                continue;
            }

            this.tileMasonry(assets, s, x0, y0, sw, sh);
        }
    }

    private drawDepthSolid(
        draw: DrawNode.Type,
        overlayDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        solid: SolidSpec,
        depth: DepthRange,
        left: number,
        right: number,
        cam: CameraDirector,
        theme: RoomTheme,
        opacity: number,
        p: Play,
    ): void {
        const width = right - left;
        const base = cam.sy(solid.y, depth.min);
        const top = cam.sy(solid.y + solid.h, depth.min);
        const rear = cam.sy(solid.y + solid.h, depth.max);
        const frontH = top - base;
        const slot = coverArt(solid);
        const layer = depthOrder(depth.min, 1);
        const key = "depth_solid_" + solid.x + "_" + depth.min;
        const capHeight = rear - top;
        const center = (left + right) * 0.5;
        const dShade = cam.depthShade(depth.min, true);

        // 城门绞盘（带 middle 纵深）
        if (solid.label.indexOf("绞盘") >= 0) {
            assets.tryPlace("dp_shadow_contact", "winch_sh_" + solid.x, center, base + 1, width * 1.18, cam.len(10), {
                layer: layer - 1, opacity: 0.82 * opacity,
            });
            this.drawWinch(draw, assets, left, base, width, frontH, p, layer);
            return;
        }

        // 专属门闩机关（c1_latch / c2_latch）：暗木门柱立至地面 + 铁环木闩，告别“悬空青砖块”！
        if (solid.art === "latch") {
            const groundY = cam.sy(0, depth.min);
            const postH = Math.max(frontH, top - groundY);
            assets.tryPlace("dp_shadow_contact", "latch_sh_" + solid.x, center, groundY + 1, width * 1.1, cam.len(8), {
                layer: layer - 1, opacity: 0.78 * opacity,
            });
            assets.tryPlace("fe_pillar_wood", "latch_post_" + solid.x, right - cam.len(6), groundY, cam.len(12), postH + cam.len(10), {
                layer, opacity, color: occlusionTint(opacity),
            });
            assets.tryPlace("dp_latch", key, center, base - cam.len(4), Math.max(width * 1.3, cam.len(36)), Math.max(frontH * 1.3, cam.len(32)), {
                layer: layer + 1, opacity, color: occlusionTint(opacity),
            });
            fillRadialGlow(fgGlow, center - cam.len(6), base + frontH * 0.5, cam.len(18), cam.len(14),
                Color(238, 168, 72, Math.round(58 * opacity)), Color(238, 168, 72, 0), 10);
            return;
        }

        if (solid.art === "gate_post" && depth.min > LANE_DEPTH.middle) {
            assets.tryPlace("slab", "gate_sill_" + solid.x, center, cam.sy(solid.y, LANE_DEPTH.middle - 6),
                width + cam.len(34), cam.len(12), { layer: 1, color: Color(180, 169, 150, 255) });
            // 非城门房的出口门柱顶部架设明代牌坊飞檐横梁，将孤立门柱连成可辨识的门坊
            if (p.room.key !== "gate") {
                const beamY = cam.sy(solid.y + solid.h - 10, LANE_DEPTH.lower);
                const beamW = Math.max(width * 2.8, cam.len(92));
                const beamH = cam.len(26);
                assets.tryPlace("dp_gate_arch_beam", "gate_beam_" + solid.x, center, beamY, beamW, beamH, {
                    layer: depthOrder(LANE_DEPTH.lower, 3),
                    opacity: Math.min(1, opacity + 0.12),
                });
            }
        }

        // 实体脚底接触影（放入 worldArt 同容器 layer-1，严密贴合占地范围且绝不被青石路面吞没）
        const shadowH = Math.max(cam.len(6), (cam.sy(solid.y, depth.max) - base) + cam.len(5));
        assets.tryPlace("dp_shadow_contact", "solid_sh_" + solid.x + "_" + depth.min, center, base + shadowH * 0.32,
            width * 1.14, shadowH * 1.15, {
                layer: layer - 1,
                opacity: 0.78 * opacity,
            });

        // 专属明代场景道具（空筐墙 / 粮袋堆 / 木帘 / 窗板 / 石井栏）
        const propArt = dedicatedSolidProp(solid);
        if (propArt !== undefined) {
            const propPath = "assets/art/props_ming.clip|" + propArt.clip;
            const drawH = frontH * propArt.heightMul;
            const cols = propArt.tileable
                ? Math.max(1, Math.min(6, Math.round((solid.w / Math.max(1, solid.h)) / propArt.natAR)))
                : 1;
            const colW = width / cols;
            const tint = occlusionTint(opacity, tintByShade(Color(238, 240, 246, 255), dShade));
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
        const isStoneCover = slot === "cover_stone";
        const isSoftCloth = solid.soft === true || solid.art === "curtain";
        const visCapH = solid.y >= 100 ? Math.min(capHeight, cam.len(10)) : capHeight;

        // 1. 2.5D 透视侧斜面（实体位于视口左侧时露出右阴影侧面，位于右侧时露出左阴影侧面，强化立体体积感；软布帘不画厚箱体侧壁）
        if (slot !== "fence" && !isSoftCloth && visCapH > 2 && frontH > 8) {
            const viewShift = (cam.viewW * 0.5 - center) / Math.max(240, cam.viewW * 0.5);
            const sidePx = Math.min(cam.len(14), Math.abs(viewShift) * visCapH * 0.65);
            if (sidePx >= 2.2) {
                const sideSlot = timber ? "dp_wood_side" : (isStoneCover ? "dp_stone_side" : "dp_wall_side");
                const sideX = viewShift > 0 ? (right + sidePx * 0.5) : (left - sidePx * 0.5);
                assets.tryPlace(sideSlot, "side_" + solid.x + "_" + depth.min, sideX, base + visCapH * 0.35, sidePx + 0.6, frontH, {
                    layer: layer - 1,
                    opacity: Math.min(1, opacity * 0.92),
                    color: occlusionTint(opacity, tintByShade(Color(210, 218, 228, 255), dShade)),
                });
            }
        }

        // 2. 专属水平顶面材质（dp_wood_top / dp_stone_top / dp_wall_top；软布帘仅绘细木挂杆，消除悬空灰条）
        if (isSoftCloth) {
            assets.tryPlace("fe_beam_wood", "cap_" + solid.x + "_" + depth.min, center, top - 1, width + 4, Math.max(3, cam.len(4)), {
                opacity: Math.min(1, opacity),
                color: occlusionTint(opacity, Color(148, 122, 96, 255)),
                layer: layer + 1,
            });
        } else if (slot !== "fence" && visCapH > 1) {
            const capSlot = timber ? "dp_wood_top" : (isStoneCover ? "dp_stone_top" : "dp_wall_top");
            const capTint = occlusionTint(opacity, tintByShade(Color(246, 248, 252, 255), dShade));
            assets.tryPlace(capSlot, "cap_" + solid.x + "_" + depth.min, center, top - 0.5, width + 0.6, visCapH + 1.0, {
                opacity: Math.min(1, opacity),
                color: capTint,
                layer: layer,
            });
        }

        // 特例 1：细长竖木柱（檐柱/棚柱等 h > w*1.6 的木构）
        if (timber && solid.h > solid.w * 1.6) {
            const segs = Math.max(1, Math.min(6, Math.round(solid.h / Math.max(24, solid.w * 3.5))));
            const segH = frontH / segs;
            const colTint = occlusionTint(opacity, tintByShade(Color(255, 255, 255, 255), dShade));
            for (let pi = 0; pi < segs; pi++) {
                const tk = pi === 0 ? key : key + "_p" + pi;
                assets.tryPlace("fe_pillar_wood", tk, center, base + pi * segH, width + 0.5, segH + 0.5, {
                    layer, opacity, color: colTint,
                });
            }
            return;
        }

        // 特例 2：细长横向棚架木梁（w > h*5，如二段粮棚 600×8）
        if (timber && solid.w > solid.h * 5) {
            const segs = Math.max(2, Math.min(12, Math.round(solid.w / 64)));
            const segW = width / segs;
            const beamH = Math.max(5, frontH);
            const beamTint = occlusionTint(opacity, tintByShade(Color(255, 255, 255, 255), dShade));
            for (let bi = 0; bi < segs; bi++) {
                const tk = bi === 0 ? key : key + "_b" + bi;
                assets.tryPlace("fe_beam_wood", tk, left + (bi + 0.5) * segW, base, segW + 0.5, beamH, {
                    layer, opacity, color: beamTint,
                });
            }
            return;
        }

        // 3. 暗黑像素正面平铺（保留精确 key 与 sprites.clip 槽位兼容 verify-depth.lua 断言）
        const natAR = slot === "fence" ? 3.53 : (slot === "cover_wood" ? 2.52 : (slot === "cover_stone" ? 2.29 : 1.52));
        const cols = slot === "wall"
            ? Math.max(1, Math.min(10, Math.round(solid.w / 72)))
            : Math.max(1, Math.min(10, Math.round((solid.w / Math.max(1, solid.h)) / natAR)));
        const colW = width / cols;
        const rows = slot === "wall"
            ? Math.max(1, Math.min(10, Math.ceil((solid.h * 1.25) / Math.max(1, solid.w / cols))))
            : Math.max(1, Math.min(6, Math.round((solid.h / Math.max(1, solid.w / cols)) * natAR)));
        const rowHeight = frontH / rows;
        const baseColor = slot === "wall" ? Color(216, 224, 234, 255) : Color(255, 255, 255, 255);
        const color = occlusionTint(opacity, tintByShade(baseColor, dShade));
        for (let row = 0; row < rows; row++) {
            for (let col = 0; col < cols; col++) {
                const tileKey = (row === 0 && col === 0) ? key : key + "_r" + row + "_c" + col;
                assets.tryPlace(slot, tileKey, left + (col + 0.5) * colW, base + row * rowHeight, colW + 0.5, rowHeight + 0.5, {
                    layer, opacity, color, facing: (row + col) % 2 === 0 ? 1 : -1,
                });
            }
        }

        // 4. 2.5D 矮掩体贴靠冷月/暖木微亮边线（绘制在 worldOverlayDraw order=33，位于掩体精灵之上清晰可见）
        if (!p.childMode && solid.h <= 64 && solid.y <= 2 && (p.coverHug || p.coverNear)) {
            const plx = p.player.x;
            const nearLeft = Math.abs(plx - solid.x) < 42;
            const nearRight = Math.abs(plx - (solid.x + solid.w)) < 42;
            if ((nearLeft || nearRight) && Math.abs(p.player.depth - (depth.min + depth.max) * 0.5) <= 28) {
                const edgeX = nearLeft ? left - 1.5 : right + 1.5;
                const col = p.coverHug ? (timber ? PALETTE.amberCore : PALETTE.moonPale) : PALETTE.silkDim;
                overlayDraw.drawSegment(Vec2(edgeX, base + 3), Vec2(edgeX, top + 2), p.coverHug ? 2.2 : 1.3, toColor(col, p.coverHug ? 220 : 125));
            }
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
        draw.drawSegment(drum, bend, ropeWidth, Color(111, 86, 57, 239));
        draw.drawSegment(bend, ropeTop, ropeWidth, Color(111, 86, 57, 239));
        assets.tryPlace("prop_winch", "gate_winch", cx, y0 + sh * 0.5, sw, sh, { layer });
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
        // 门洞位置 840..1040（左右门柱 840..864 与 1016..1040），闸门在净空 864..1016 内垂直起降
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
        const gx0 = cam.sx(864);
        const gx1 = cam.sx(1016);
        const topY = cam.sy(160);
        const botY = cam.sy(160 * (1 - closeFrac));
        const shutterW = gx1 - gx0;
        const shutterH = topY - botY;
        if (shutterH > 2) {
            fillVGradRect(fgDraw, gx0, botY, shutterW, shutterH, toColor(PALETTE.steelDark), toColor(PALETTE.steelMid));
            // 分排暗黑重木闸条平铺，避免将横向 cover_wood 暴力拉伸成竖门
            const rows = Math.max(1, Math.min(6, Math.ceil(shutterH / Math.max(18, shutterW / 2.6))));
            const rowH = shutterH / rows;
            for (let r = 0; r < rows; r++) {
                assets.tryPlace("cover_wood", "gate_shutter_" + r, (gx0 + gx1) * 0.5, botY + r * rowH,
                    shutterW, rowH + 0.5, { layer: depthOrder(0, 2) });
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
        // 塔门实体由下方「门楣」统一根据开合态放置 prop_tower_door；绝不叠绘裸露灰盒矩形框
        if (s.id === "tower_door") {
            return;
        }
        fillVGradRect(fgDraw, x0, y0, sw, sh, Color(14, 19, 30, 255), Color(26, 36, 54, 255));
        fgDraw.drawRect(Rect(x0, y0, sw, sh), Color(0, 0, 0, 0), 1.0, Color(42, 54, 72, 145));

        if (s.label.indexOf("塔身") >= 0) {
            this.tileMasonry(assets, s, x0, y0, sw, sh);
            if (s.w >= 60) {
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
        }

        // 门楣下方温暖圣殿灯火（开门时灯光骤然敞开铺满门廊！）
        if (s.label.indexOf("门楣") >= 0) {
            this.tileMasonry(assets, s, x0, y0, sw, sh);
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
        const latch = p.cartLatchBounds();
        if (latch !== undefined) {
            const bx0 = cam.sx(latch.x);
            const bx1 = cam.sx(latch.x + latch.width);
            const deckY = cam.sy(p.room.cart.baseY);
            assets.tryPlace("fe_pillar_wood", "outside_arch_bolt", (bx0 + bx1) * 0.5, y0 + 2, bx1 - bx0, ah - 2, { layer: 3 });
            draw.drawSegment(Vec2((bx0 + bx1) * 0.5, y1), Vec2((bx0 + bx1) * 0.5, deckY), 2.4, Color(96, 102, 110, 220));
        }
    }
}
