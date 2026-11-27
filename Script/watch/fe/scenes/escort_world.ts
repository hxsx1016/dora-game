/**
 * 《向西守望》男主护送线后半段专属场景表现模块（EscortWorldRenderer）：
 *
 * 覆盖房间：gatepath（城外同行）→ escort1（城外残坊）→ escort2（军粮棚）
 *          → escort3（山腰工台）→ escort4（峭壁山道）→ escort5（塔下破晓）
 *
 * 美学理念「火线北行 · 渐近孤灯」：
 * 1. 五层纵深视差与一夜向晓色温递进（暗夜余烬 → 官仓寒月 → 工台暖琥珀 → 险崖铅青 → 塔下破晓微曦）；
 * 2. 贯穿六幕的视觉核心母题：右上天际远山上的「宁村北塔与西窗暖灯」从 1/5 星芒逐关放大至近在咫尺；
 * 3. 每段独有地标与实景构件：
 *    - gatepath：城门余烬战旗、牵手双影、高石阶背起微光；
 *    - escort1 ：民坊断壁剪影、残旗火盆、暗夜巷战火星；
 *    - escort2 ：高耸明代官仓木构桁架与三道破瓦冷月光柱、米糠浮尘；
 *    - escort3 ：避风山腰修铳工棚、轻晃六角羊角风灯安全光池、周戍青袍草席（小满落坐处）、铜锣与草靶试射场；
 *    - escort4 ：沿海峭壁松涛、苍苔指路石碑、暗雾伏击火绳微光；
 *    - escort5 ：战斗清场进度实时驱动天际破晓微曦抬升、塔前石坊与指路灯火；
 * 4. 严格遵守明朝写实红线：无现代光源/霓虹/任务箭头，全灰度下明暗剪影清晰可读。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { LANE_DEPTH } from "Script/watch/depth";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { depthOrder } from "Script/watch/fe/occlusion";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { ensureSecondHalfAssetsRegistered } from "Script/watch/fe/scenes/second_half_assets";
import {
    PALETTE,
    fillGradQuad,
    fillRadialGlow,
    fillVGradRect,
    toColor,
} from "Script/watch/fe/theme";

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

export function isEscortWorldRoom(key: string): boolean {
    return key === "gatepath"
        || key === "escort1"
        || key === "escort2"
        || key === "escort3"
        || key === "escort4"
        || key === "escort5";
}

interface TowerStageSpec {
    /** 北塔剪影缩放倍率（从远如星点逐步逼近） */
    scale: number;
    /** 屏幕相对横坐标（0..1） */
    screenXFrac: number;
    /** 屏幕相对纵坐标（0..1） */
    screenYFrac: number;
    /** 灯火光晕半径 */
    beaconR: number;
    /** 破晓暖色系数（0..1） */
    dawnWarmth: number;
}

const TOWER_PROGRESSION: Record<string, TowerStageSpec> = {
    gatepath: { scale: 0.24, screenXFrac: 0.85, screenYFrac: 0.72, beaconR: 18, dawnWarmth: 0.04 },
    escort1: { scale: 0.34, screenXFrac: 0.84, screenYFrac: 0.71, beaconR: 24, dawnWarmth: 0.08 },
    escort2: { scale: 0.44, screenXFrac: 0.82, screenYFrac: 0.74, beaconR: 28, dawnWarmth: 0.14 },
    escort3: { scale: 0.56, screenXFrac: 0.83, screenYFrac: 0.70, beaconR: 38, dawnWarmth: 0.24 },
    escort4: { scale: 0.72, screenXFrac: 0.84, screenYFrac: 0.68, beaconR: 48, dawnWarmth: 0.38 },
    escort5: { scale: 0.92, screenXFrac: 0.86, screenYFrac: 0.64, beaconR: 64, dawnWarmth: 0.62 },
};

export class EscortWorldRenderer {
    private carryBloomT = 0;
    private gongSway: Record<number, number> = {};
    private lastEnemyHitT: Record<number, number> = {};
    private lastRoomKey = "";

    constructor() {
        ensureSecondHalfAssetsRegistered();
    }

    reset(): void {
        this.carryBloomT = 0;
        this.gongSway = {};
        this.lastEnemyHitT = {};
    }

    update(dt: number, p: Play, carryStarted: boolean): void {
        if (this.lastRoomKey !== p.room.key) {
            this.lastRoomKey = p.room.key;
            this.reset();
        }
        if (carryStarted) {
            this.carryBloomT = 1.15;
        } else if (this.carryBloomT > 0) {
            this.carryBloomT = Math.max(0, this.carryBloomT - dt);
        }
        if (p.room.key === "escort3") {
            for (let i = 0; i < p.enemies.length; i++) {
                const en = p.enemies[i];
                const prevHit = this.lastEnemyHitT[i] ?? 0;
                if (en.hitT > prevHit + 0.05) {
                    this.gongSway[i] = 1.0;
                }
                this.lastEnemyHitT[i] = en.hitT;
                const cur = this.gongSway[i] ?? 0;
                if (cur > 0) {
                    this.gongSway[i] = Math.max(0, cur - dt * 1.4);
                }
            }
        }
    }

    /** L0.5 + L1：远景天色弧线、漂浮海雾、中景建筑/官仓桁架剪影与「渐近北塔灯」 */
    drawBackdropOverlay(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        towerDraw: DrawNode.Type = bgDraw,
    ): void {
        const key = p.room.key;
        if (!isEscortWorldRoom(key)) {
            return;
        }
        const w = cam.viewW;
        const h = cam.viewH;
        const spec = TOWER_PROGRESSION[key] ?? TOWER_PROGRESSION.escort1;

        // 1. 逐关一夜向晓天色渐变（escort5 随清场推进真实抬亮破晓微曦）
        let dynamicDawn = spec.dawnWarmth;
        if (key === "escort5" && p.enemies.length > 0) {
            let dead = 0;
            for (let i = 0; i < p.enemies.length; i++) {
                if (!p.enemies[i].alive) {
                    dead += 1;
                }
            }
            const progress = clamp01(dead / p.enemies.length);
            dynamicDawn = 0.34 + progress * 0.62;
        }

        if (key === "gatepath" || key === "escort1") {
            // 城外残火暗朱微辉（左侧远方失守城垣方向）
            const emberPulse = 0.84 + 0.16 * Math.sin(time * 2.4);
            fillRadialGlow(bgGlow, w * 0.14, h * 0.34, w * 0.34, h * 0.38,
                Color(168, 62, 34, Math.round(38 * emberPulse)), Color(168, 62, 34, 0), 16);
        }

        if (dynamicDawn > 0.10) {
            // 东北方破晓鱼肚微曦（克制的青金暖调，无过饱和）
            const dawnA = Math.round(62 * dynamicDawn);
            fillVGradRect(bgGlow, 0, h * 0.44, w, h * 0.32,
                Color(186, 152, 112, Math.round(dawnA * 0.85)),
                Color(74, 92, 124, 0));
            fillRadialGlow(bgGlow, w * spec.screenXFrac, h * (spec.screenYFrac - 0.04),
                w * 0.34, h * 0.24,
                Color(232, 186, 126, Math.round(52 * dynamicDawn)),
                Color(232, 186, 126, 0), 18);
        }

        // 2. 贯穿全线的远景「宁村北塔与西窗暖灯」（escort2 透窗见灯，其余五段直映山脊）
        this.drawDistantNorthTower(towerDraw, bgGlow, w, h, cam.x, time, spec, dynamicDawn, key === "escort2");

        // 3. 流动海雾/山岚水墨带（柔和低透明度，消除平板背景感）
        const mistShift = ((time * 12 + cam.x * 0.16) % (w + 460)) - 230;
        const mistCol = key === "escort3" ? PALETTE.amberDim : PALETTE.jadeMist;
        const mistOp = key === "escort4" ? 0.24 : 0.17;
        backdropArt.tryPlace("ink_mist_curve", "escort_mist_a", mistShift, h * 0.34, 620, 120, {
            color: toColor(mistCol), opacity: mistOp, layer: 5,
        });
        backdropArt.tryPlace("ink_mist_curve", "escort_mist_b", (mistShift + w * 0.55) % (w + 460) - 230, h * 0.46, 540, 100, {
            color: toColor(PALETTE.inkMist), opacity: mistOp * 0.85, layer: 5, facing: -1,
        });

        // 4. 分房间专属中景建筑剪影与体积光束（L1 视差 0.42x）
        if (key === "escort1") {
            this.drawEscort1AlleySilhouettes(bgDraw, w, h, cam.x);
        } else if (key === "escort2") {
            this.drawEscort2GranaryRafters(bgDraw, bgGlow, w, h, cam.x, time);
        } else if (key === "escort3") {
            this.drawEscort3MountainShelterBg(bgDraw, bgGlow, w, h, cam.x, time);
        } else if (key === "escort4") {
            this.drawEscort4CliffGorge(bgDraw, bgGlow, w, h, cam.x, time);
        } else if (key === "escort5") {
            this.drawEscort5TowerApproachBg(bgDraw, bgGlow, w, h, cam.x, time, dynamicDawn);
        }
    }

    /** L2 实景互动地标（粮棚柱梁、山腰工台暖窝与小满草席、铜锣靶、指路石碑与战旗） */
    drawWorldSetpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        view: DualRouteSnapshot,
        cam: CameraDirector,
        time: number,
    ): void {
        const key = p.room.key;
        if (!isEscortWorldRoom(key)) {
            return;
        }
        const ox = p.ox;

        if (key === "gatepath") {
            this.drawGatepathSetpieces(fgDraw, fgGlow, worldArt, p, view, cam, time, ox);
            return;
        }
        if (key === "escort1") {
            this.drawEscort1Setpieces(fgDraw, fgGlow, worldArt, p, cam, time, ox);
            return;
        }
        if (key === "escort2") {
            this.drawEscort2Setpieces(fgDraw, fgGlow, worldArt, p, cam, time, ox);
            return;
        }
        if (key === "escort3") {
            this.drawEscort3WorkbenchSanctuary(fgDraw, fgGlow, worldArt, p, view, cam, time, ox);
            return;
        }
        if (key === "escort4") {
            this.drawEscort4Setpieces(fgDraw, fgGlow, worldArt, p, cam, time, ox);
            return;
        }
        if (key === "escort5") {
            this.drawEscort5Setpieces(fgDraw, fgGlow, worldArt, p, cam, time, ox);
        }
    }

    /** L4 景深前景压边剪影（1.26x 视差，绝不遮挡战斗视线，大幅拉升电影纵深） */
    drawForegroundFraming(
        fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
    ): void {
        const key = p.room.key;
        if (!isEscortWorldRoom(key)) {
            return;
        }
        const w = cam.viewW;
        const h = cam.viewH;
        const parallaxX = cam.x * 1.26;
        const sway = Math.sin(time * 1.6) * 4;

        // 顶部极轻前景屋檐/官仓横梁框（避免悬空树桩穿帮）
        if (key === "escort2") {
            // 官仓前景顶梁与垂檐阴影
            fgDraw.drawRect(Rect(0, h - 34, w, 34), Color(10, 12, 16, 205));
            fgDraw.drawSegment(Vec2(0, h - 34), Vec2(w, h - 34), 1.6, Color(58, 46, 36, 155));
            for (let rx = -40; rx < w + 80; rx += 160) {
                const bx = rx - ((parallaxX * 0.18) % 160);
                fgDraw.drawRect(Rect(bx, h - 46, 14, 46), Color(14, 12, 11, 190));
            }
        } else if (key === "escort3" || key === "escort4" || key === "escort5") {
            // 山路前景两侧落地松冠剪影（锚在底部边缘外侧，形成自然画幅压边，不悬空裁切）
            worldArt.tryPlace("grass_low", "escort_fg_bush_l", 78 + sway * 0.4, -4, 190, 48, {
                color: Color(10, 14, 18, 255), opacity: 0.78, layer: 5200,
            });
            worldArt.tryPlace("grass_low", "escort_fg_bush_r", w - 82 - sway * 0.35, -4, 198, 52, {
                color: Color(10, 14, 18, 255), opacity: 0.78, layer: 5200, facing: -1,
            });
        }

        // 底部近景草叶/断石极薄剪影（仅压在屏幕最下 28px）
        const stride = 260;
        const startSlot = Math.floor((parallaxX - 200) / stride);
        for (let s = startSlot; s <= startSlot + 6; s++) {
            const sx = s * stride - parallaxX + w * 0.5;
            if (sx < -140 || sx > w + 140) {
                continue;
            }
            const hSeed = Math.abs(Math.sin(s * 12.9898) * 43758.5453) % 1;
            const rockH = 16 + hSeed * 18;
            const rockW = 46 + hSeed * 42;
            fgDraw.drawPolygon([
                Vec2(sx - rockW * 0.5, 0),
                Vec2(sx + rockW * 0.5, 0),
                Vec2(sx + rockW * 0.25 + sway * 0.2, rockH),
                Vec2(sx - rockW * 0.3 + sway * 0.2, rockH * 0.82),
            ], Color(8, 10, 14, 196));
        }
    }

    // ---------------------------------------------------------------- 远景北塔灯（贯穿六幕）

    private drawDistantNorthTower(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        camX: number,
        time: number,
        spec: TowerStageSpec,
        dawnWarmth: number,
        behindWindow: boolean,
    ): void {
        const s = spec.scale;
        const tx = w * spec.screenXFrac - camX * 0.045;
        const ty = h * spec.screenYFrac;
        const pulse = 0.86 + 0.14 * Math.sin(time * 2.5);
        const alphaMul = behindWindow ? 0.62 : 1.0;

        // 远山脊底座
        const ridgeW = 190 * s + 95;
        const ridgeH = 44 * s + 22;
        const ridgeCol = Color(
            Math.round(20 + dawnWarmth * 16),
            Math.round(26 + dawnWarmth * 14),
            Math.round(38 + dawnWarmth * 8),
            Math.round(188 * alphaMul),
        );
        bgDraw.drawPolygon([
            Vec2(tx - ridgeW, ty - ridgeH),
            Vec2(tx + ridgeW * 0.72, ty - ridgeH),
            Vec2(tx + ridgeW * 0.16, ty + 6 * s),
            Vec2(tx - ridgeW * 0.32, ty + 2 * s),
        ], ridgeCol);

        // 明代石砌塔身（微收分梯形）
        const baseW = 44 * s;
        const topW = 34 * s;
        const bodyH = 62 * s;
        const towerCol = Color(
            Math.round(24 + dawnWarmth * 14),
            Math.round(30 + dawnWarmth * 12),
            Math.round(42 + dawnWarmth * 8),
            Math.round(225 * alphaMul),
        );
        const rimCol = Color(138, 148, 166, Math.round(68 * alphaMul));
        bgDraw.drawPolygon([
            Vec2(tx - baseW * 0.5, ty - 4 * s),
            Vec2(tx + baseW * 0.5, ty - 4 * s),
            Vec2(tx + topW * 0.5, ty + bodyH),
            Vec2(tx - topW * 0.5, ty + bodyH),
        ], towerCol, 0.8, rimCol);

        // 塔顶歇山钟亭柱与飞檐
        const pavH = 18 * s;
        const eaveY = ty + bodyH + pavH;
        const eaveW = 54 * s;
        bgDraw.drawRect(Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), towerCol);
        bgDraw.drawRect(Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), towerCol);
        bgDraw.drawPolygon([
            Vec2(tx - eaveW * 0.54, eaveY - 2 * s),
            Vec2(tx + eaveW * 0.54, eaveY - 2 * s),
            Vec2(tx + eaveW * 0.24, eaveY + 13 * s),
            Vec2(tx - eaveW * 0.24, eaveY + 13 * s),
        ], Color(18, 22, 32, Math.round(238 * alphaMul)), 0.8, rimCol);

        // 西窗一点不灭暖琥珀灯火（视觉核心锚点！）
        const lampX = tx - topW * 0.14;
        const lampY = ty + bodyH * 0.64;
        const glowR = spec.beaconR * pulse;
        fillRadialGlow(bgGlow, lampX, lampY, glowR * 1.35, glowR,
            Color(255, 206, 122, Math.round(92 * pulse * alphaMul)),
            Color(255, 178, 86, 0), 16);
        fillRadialGlow(bgGlow, lampX, lampY, glowR * 0.48, glowR * 0.42,
            Color(255, 238, 184, Math.round(176 * pulse * alphaMul)),
            Color(255, 204, 118, 0), 12);
        bgGlow.drawDot(Vec2(lampX, lampY), Math.max(1.8, 3.6 * s), Color(255, 246, 212, Math.round(248 * alphaMul)));
    }

    // ---------------------------------------------------------------- 各关专属 L1 中景背景

    private drawEscort1AlleySilhouettes(bgDraw: DrawNode.Type, w: number, h: number, camX: number): void {
        const shift = camX * 0.38;
        const houses = [
            { x: 140, bw: 165, bh: 165, roof: 36 },
            { x: 430, bw: 190, bh: 195, roof: 42 },
            { x: 760, bw: 145, bh: 150, roof: 30 },
            { x: 1080, bw: 210, bh: 185, roof: 40 },
        ];
        for (const hs of houses) {
            const sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170;
            const base = h * 0.25;
            bgDraw.drawRect(Rect(sx, base, hs.bw, hs.bh), Color(16, 20, 29, 175));
            bgDraw.drawPolygon([
                Vec2(sx - 16, base + hs.bh),
                Vec2(sx + hs.bw + 16, base + hs.bh),
                Vec2(sx + hs.bw * 0.78, base + hs.bh + hs.roof),
                Vec2(sx + hs.bw * 0.22, base + hs.bh + hs.roof),
            ], Color(12, 15, 22, 195));
        }
    }

    private drawEscort2GranaryRafters(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        camX: number,
        time: number,
    ): void {
        const shift = camX * 0.42;
        // 官仓深暗高顶横梁与人字木桁架
        bgDraw.drawRect(Rect(0, h * 0.80, w, h * 0.20), Color(12, 14, 20, 192));
        const span = 290;
        const first = Math.floor((shift - 180) / span);
        for (let k = first; k <= first + 6; k++) {
            const bx = k * span - shift;
            // 纵柱
            bgDraw.drawRect(Rect(bx - 9, h * 0.20, 18, h * 0.62), Color(22, 19, 17, 165));
            // 斜撑人字梁
            bgDraw.drawSegment(Vec2(bx, h * 0.82), Vec2(bx + span * 0.5, h * 0.96), 7, Color(26, 21, 18, 185));
            bgDraw.drawSegment(Vec2(bx + span, h * 0.82), Vec2(bx + span * 0.5, h * 0.96), 7, Color(26, 21, 18, 185));
            // 破瓦斜射冷月光柱（自屏幕顶檐无缝贯下，上下双端渐隐，告别硬边平头梯形！）
            if (Math.abs(k) % 2 === 0) {
                const topX = bx + span * 0.44;
                const pulse = 0.86 + 0.14 * Math.sin(time * 1.1 + k);
                const midA = Math.round(30 * pulse);
                const topA = Math.round(14 * pulse);
                fillGradQuad(
                    bgGlow,
                    topX - 20, h + 10, Color(168, 194, 224, topA),
                    topX + 36, h + 10, Color(168, 194, 224, topA),
                    topX + 94, h * 0.48, Color(176, 202, 232, midA),
                    topX + 8, h * 0.48, Color(176, 202, 232, midA),
                );
                fillGradQuad(
                    bgGlow,
                    topX + 8, h * 0.48, Color(176, 202, 232, midA),
                    topX + 94, h * 0.48, Color(176, 202, 232, midA),
                    topX + 136, h * 0.14, Color(168, 194, 224, 0),
                    topX + 30, h * 0.14, Color(168, 194, 224, 0),
                );
                // 光柱内浮沉米糠微尘
                for (let d = 0; d < 4; d++) {
                    const phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1;
                    const dx = topX + 12 + phase * 76 + Math.sin(time * 1.4 + d) * 8;
                    const dy = h * (0.90 - phase * 0.68);
                    bgGlow.drawDot(Vec2(dx, dy), 1.6, Color(214, 222, 232, Math.round(62 * Math.sin(phase * Math.PI))));
                }
            }
        }
    }

    private drawEscort3MountainShelterBg(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        camX: number,
        time: number,
    ): void {
        // 山腰避风崖壁剪影（左侧护住工台）
        const cliffX = 120 - camX * 0.28;
        bgDraw.drawPolygon([
            Vec2(cliffX - 240, h * 0.18),
            Vec2(cliffX + 260, h * 0.18),
            Vec2(cliffX + 165, h * 0.68),
            Vec2(cliffX - 180, h * 0.86),
        ], Color(14, 18, 25, 165));
        // 中央工台方向在远景层晕开一层极淡暖雾
        const warmPulse = 0.90 + 0.10 * Math.sin(time * 2.1);
        fillRadialGlow(bgGlow, w * 0.50, h * 0.36, w * 0.26, h * 0.26,
            Color(224, 164, 88, Math.round(32 * warmPulse)), Color(224, 164, 88, 0), 16);
    }

    private drawEscort4CliffGorge(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        camX: number,
        time: number,
    ): void {
        // 深壑雾谷暗冷色调 + 倾斜崖峰剪影
        const shift = camX * 0.32;
        for (let i = 0; i < 4; i++) {
            const px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210;
            bgDraw.drawPolygon([
                Vec2(px - 120, h * 0.20),
                Vec2(px + 145, h * 0.20),
                Vec2(px + 48, h * (0.58 + (i % 2) * 0.12)),
                Vec2(px - 58, h * (0.50 + (i % 2) * 0.08)),
            ], Color(16, 22, 33, 152));
        }
        // 山风疾云轻光带
        const cloudX = ((time * 24) % (w + 400)) - 200;
        bgGlow.drawPolygon([
            Vec2(cloudX, h * 0.78),
            Vec2(cloudX + 240, h * 0.82),
            Vec2(cloudX + 210, h * 0.87),
            Vec2(cloudX - 20, h * 0.83),
        ], Color(142, 164, 192, 24));
    }

    private drawEscort5TowerApproachBg(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        w: number,
        h: number,
        camX: number,
        time: number,
        dawnWarmth: number,
    ): void {
        // 破晓山岭微光 + 山门远影
        const glowPulse = 0.88 + 0.12 * Math.sin(time * 1.8);
        fillRadialGlow(bgGlow, w * 0.78, h * 0.48, w * 0.42, h * 0.30,
            Color(228, 184, 132, Math.round(44 * dawnWarmth * glowPulse)),
            Color(228, 184, 132, 0), 18);
        // 远景山道古松与低墙剪影
        const shift = camX * 0.30;
        bgDraw.drawPolygon([
            Vec2(0, h * 0.20),
            Vec2(w, h * 0.20),
            Vec2(w, h * 0.34),
            Vec2(w * 0.55 - (shift % 120) * 0.2, h * 0.29),
            Vec2(0, h * 0.36),
        ], Color(18, 22, 32, 140));
    }

    // ---------------------------------------------------------------- 各关专属 L2 实景构件

    private drawGatepathSetpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        view: DualRouteSnapshot,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const groundY = cam.sy(0);
        // 1. 城门外残旗与指路石碑（x=96 与 x=520）
        worldArt.tryPlace("sh_stele_banner", "gp_banner_start", cam.sx(ox + 96), groundY, cam.len(68), cam.len(74), {
            layer: 1, opacity: 0.92,
        });
        worldArt.tryPlace("sh_stele_banner", "gp_stele_mid", cam.sx(ox + 520), groundY, cam.len(54), cam.len(60), {
            layer: 1, opacity: 0.86, facing: -1,
        });
        // 2. 高石阶顶（x=910）一盏引路孤灯，照向第一段护送口
        const stepTopY = cam.sy(48);
        const lampX = cam.sx(ox + 912);
        const poleH = cam.len(58);
        fgDraw.drawSegment(Vec2(lampX, stepTopY), Vec2(lampX, stepTopY + poleH), Math.max(1.8, cam.len(2.4)), Color(74, 54, 38, 240));
        fgDraw.drawSegment(Vec2(lampX, stepTopY + poleH), Vec2(lampX - cam.len(14), stepTopY + poleH), Math.max(1.5, cam.len(2)), Color(74, 54, 38, 240));
        worldArt.tryPlace("prop_lantern", "gp_top_lantern", lampX - cam.len(14), stepTopY + poleH - cam.len(14), cam.len(18), cam.len(22), { layer: 4 });
        const flame = 0.88 + 0.12 * Math.sin(time * 3.1);
        fillRadialGlow(fgGlow, lampX - cam.len(14), stepTopY + poleH - cam.len(14), cam.len(54), cam.len(48),
            Color(246, 192, 114, Math.round(72 * flame)), Color(246, 192, 114, 0), 16);

        // 3. 牵手同行段：青石地面一大一小两道斜月长影
        if (p.phase === "gatepath-start" && p.partner.alive) {
            const sx1 = cam.sx(p.player.x);
            const sx2 = cam.sx(p.partner.x);
            fgDraw.drawPolygon([
                Vec2(sx1 - cam.len(10), groundY + 1),
                Vec2(sx1 + cam.len(10), groundY + 1),
                Vec2(sx1 - cam.len(24), groundY - cam.len(10)),
                Vec2(sx1 - cam.len(40), groundY - cam.len(10)),
            ], Color(8, 10, 16, 86));
            fgDraw.drawPolygon([
                Vec2(sx2 - cam.len(7), groundY + 1),
                Vec2(sx2 + cam.len(7), groundY + 1),
                Vec2(sx2 - cam.len(15), groundY - cam.len(7)),
                Vec2(sx2 - cam.len(26), groundY - cam.len(7)),
            ], Color(8, 10, 16, 78));
        }

        // 4. 高石阶背起瞬间的电影柔光脉冲
        if (this.carryBloomT > 0 || view.backCarry.mounting) {
            const k = this.carryBloomT > 0 ? clamp01(this.carryBloomT / 1.15) : 0.72;
            const bx = cam.sx(p.player.x);
            const by = cam.sy(p.player.y + 42);
            fillRadialGlow(fgGlow, bx, by, cam.len(96), cam.len(72),
                Color(244, 206, 142, Math.round(62 * k)), Color(244, 206, 142, 0), 18);
        }
    }

    private drawEscort1Setpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        _p: Play,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const backDepth = LANE_DEPTH.upper + 16;
        const backY = cam.sy(0, backDepth);
        const backLayer = depthOrder(backDepth, -2);
        // 巷口残旗与路碑
        worldArt.tryPlace("sh_stele_banner", "e1_banner_a", cam.sx(ox + 150), backY, cam.len(68), cam.len(76), {
            layer: backLayer, opacity: 0.90,
        });
        worldArt.tryPlace("sh_stele_banner", "e1_banner_b", cam.sx(ox + 1245), backY, cam.len(64), cam.len(70), {
            layer: backLayer, opacity: 0.88, facing: -1,
        });
        // 巷道边缘余烬火盆（提供冷暗巷战中的明代火光锚点）
        const emberSpots = [285, 860];
        for (let i = 0; i < emberSpots.length; i++) {
            const bx = cam.sx(ox + emberSpots[i]);
            const pulse = 0.82 + 0.18 * Math.sin(time * 4.2 + i * 1.9);
            fgDraw.drawPolygon([
                Vec2(bx - cam.len(12), backY + cam.len(14)),
                Vec2(bx + cam.len(12), backY + cam.len(14)),
                Vec2(bx + cam.len(8), backY + cam.len(4)),
                Vec2(bx - cam.len(8), backY + cam.len(4)),
            ], Color(38, 34, 34, 240), 1.0, Color(88, 72, 62, 180));
            fgDraw.drawSegment(Vec2(bx - cam.len(9), backY), Vec2(bx - cam.len(6), backY + cam.len(6)), 2, Color(34, 30, 30, 235));
            fgDraw.drawSegment(Vec2(bx + cam.len(9), backY), Vec2(bx + cam.len(6), backY + cam.len(6)), 2, Color(34, 30, 30, 235));
            fgGlow.drawEllipse(Vec2(bx, backY + cam.len(14)), cam.len(9), cam.len(3.5), Color(236, 114, 48, Math.round(185 * pulse)));
            fillRadialGlow(fgGlow, bx, backY + cam.len(18), cam.len(48), cam.len(36),
                Color(226, 116, 52, Math.round(62 * pulse)), Color(226, 116, 52, 0), 14);
        }
    }

    private drawEscort2Setpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const backDepth = LANE_DEPTH.upper + 16;
        const backY = cam.sy(0, backDepth);
        const backLayer = depthOrder(backDepth, -2);
        // 粮棚后墙堆叠粗麻粮袋（丰富空间视觉，不干扰地面碰撞）
        const sackSpots = [195, 480, 1020, 1310];
        for (let i = 0; i < sackSpots.length; i++) {
            const sx = cam.sx(ox + sackSpots[i]);
            worldArt.tryPlace("sh_grain_sacks", "e2_bg_sack_" + i, sx, backY, cam.len(72), cam.len(44), {
                layer: backLayer,
                opacity: 0.78,
                facing: i % 2 === 0 ? 1 : -1,
                color: Color(172, 168, 162, 255),
            });
        }
        // 棚架上悬垂的旧军粮布幔剪影
        const beamY = cam.sy(64, -24);
        const drapeX = cam.sx(ox + 440);
        const sway = Math.sin(time * 1.9) * 3;
        fgDraw.drawPolygon([
            Vec2(drapeX - cam.len(22), beamY),
            Vec2(drapeX + cam.len(22), beamY),
            Vec2(drapeX + cam.len(18) + sway, beamY - cam.len(24)),
            Vec2(drapeX - cam.len(14) + sway * 0.7, beamY - cam.len(19)),
        ], Color(72, 58, 46, 160));

        // 地面拾取材料下方极克制环境微光（木纹筹暖松脂光 / 铃纹筹古铜清辉，方便灰度与暗夜辨认）
        for (const pk of p.pickups) {
            if (pk.id === "" || p.run.taken[pk.id]) {
                continue;
            }
            const px = cam.sx(pk.x);
            const py = cam.sy(pk.y + 10, pk.depth ?? 0);
            const pulse = 0.78 + 0.22 * Math.sin(time * 3.0 + pk.x * 0.02);
            const col = pk.kind === "bell" ? Color(238, 204, 136, Math.round(78 * pulse)) : Color(224, 168, 92, Math.round(72 * pulse));
            fillRadialGlow(fgGlow, px, py, cam.len(22), cam.len(18), col, Color(224, 168, 92, 0), 12);
        }
    }

    private drawEscort3WorkbenchSanctuary(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        view: DualRouteSnapshot,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const pulse = 0.88 + 0.12 * Math.sin(time * 2.6);
        const benchCx = cam.sx(ox + 620);
        const benchDepth = LANE_DEPTH.middle + 10;
        const benchBaseY = cam.sy(0, benchDepth);
        const benchLayer = depthOrder(benchDepth, 2);

        // 1. 温暖琥珀安全光池（暴风眼里的十分钟安宁）
        fillRadialGlow(fgGlow, benchCx, benchBaseY + cam.len(42), cam.len(168), cam.len(112),
            Color(246, 184, 96, Math.round(76 * pulse)), Color(246, 168, 74, 0), 20);
        fillRadialGlow(fgGlow, benchCx - cam.len(22), benchBaseY + cam.len(68), cam.len(58), cam.len(48),
            Color(255, 224, 152, Math.round(115 * pulse)), Color(255, 198, 108, 0), 14);

        // 2. 明代山腰木构修铳工棚与羊角风灯（精致像素实景覆盖在工台位置）
        worldArt.tryPlace("sh_craft_workbench", "e3_sanctuary_bench", benchCx, benchBaseY - cam.len(4), cam.len(142), cam.len(112), {
            layer: benchLayer,
        });

        // 3. 工台左侧：周戍铺下的青布披风与干草休息席（供小满安坐看哥哥修铳）
        const matX = cam.sx(ox + 516);
        const matDepth = LANE_DEPTH.middle + 4;
        const matY = cam.sy(0, matDepth);
        worldArt.tryPlace("sh_straw_mat", "e3_xiaoman_mat", matX, matY - cam.len(2), cam.len(66), cam.len(28), {
            layer: depthOrder(matDepth, 0),
        });
        // 当小满被放下在工台边时，给她加一层柔和灯晕
        if (view.backCarry.atBench || view.craftBench.active) {
            fillRadialGlow(fgGlow, matX, matY + cam.len(22), cam.len(42), cam.len(34),
                Color(252, 212, 138, Math.round(68 * pulse)), Color(252, 212, 138, 0), 14);
        }

        // 4. 山腰左侧指路碑与松风树影
        worldArt.tryPlace("sh_stele_banner", "e3_entry_stele", cam.sx(ox + 235), cam.sy(0, LANE_DEPTH.upper + 16), cam.len(58), cam.len(66), {
            layer: depthOrder(LANE_DEPTH.upper + 16, -1), opacity: 0.86,
        });

        // 靶身由 ActorsRenderer 绘制，这里仅叠加受击声波。
        for (let i = 0; i < p.enemies.length; i++) {
            const en = p.enemies[i];
            if (en.kind !== "target") {
                continue;
            }
            const tx = cam.sx(en.x);
            const ty = cam.sy(en.y, en.depth ?? 0);
            const swayK = this.gongSway[i] ?? 0;
            if (swayK > 0.05) {
                const ringR = cam.len(18 + (1 - swayK) * 44);
                fgGlow.drawRing(Vec2(tx, ty + cam.len(32)), Math.max(1, ringR - 1.5), ringR,
                    Color(0, 0, 0, 0), 1.4, toColor(PALETTE.amber, Math.round(190 * swayK)));
            }
        }
    }

    private drawEscort4Setpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const backDepth = LANE_DEPTH.upper + 16;
        const backY = cam.sy(0, backDepth);
        const backLayer = depthOrder(backDepth, -2);
        // 峭壁山道石碑与崖松
        worldArt.tryPlace("sh_stele_banner", "e4_stele_a", cam.sx(ox + 210), backY, cam.len(58), cam.len(66), {
            layer: backLayer, opacity: 0.90,
        });
        worldArt.tryPlace("sh_stele_banner", "e4_stele_b", cam.sx(ox + 990), backY, cam.len(56), cam.len(64), {
            layer: backLayer, opacity: 0.88, facing: -1,
        });
        // 断口与塌方前后的山道古松剪影
        const pineXs = [310, 740, 1210];
        for (let i = 0; i < pineXs.length; i++) {
            worldArt.tryPlace("pine", "e4_cliff_pine_" + i, cam.sx(ox + pineXs[i]), backY - cam.len(4), cam.len(112), cam.len(98), {
                layer: backLayer - 1, opacity: 0.72, facing: i % 2 === 0 ? 1 : -1, color: Color(138, 152, 168, 255),
            });
        }
        // 暗雾伏击明代鸟铳火绳微光（高辨识度环境提示，符合史实）
        for (let i = 0; i < p.enemies.length; i++) {
            const en = p.enemies[i];
            if (!en.alive || en.kind !== "gunner") {
                continue;
            }
            const gx = cam.sx(en.x - 10);
            const gy = cam.sy(en.y + en.h * 0.62, en.depth ?? 0);
            const ember = 0.72 + 0.28 * Math.sin(time * 7.5 + i * 2.1);
            fgGlow.drawDot(Vec2(gx, gy), 2.3, Color(255, 134, 62, Math.round(215 * ember)));
            fillRadialGlow(fgGlow, gx, gy, 14, 14, Color(242, 108, 46, Math.round(64 * ember)), Color(242, 108, 46, 0), 10);
        }
        // 山崖风尘细线
        fgDraw.drawSegment(Vec2(cam.sx(ox + 500), backY + cam.len(4)), Vec2(cam.sx(ox + 900), backY + cam.len(4)), 1.0, Color(110, 124, 142, 48));
    }

    private drawEscort5Setpieces(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        _p: Play,
        cam: CameraDirector,
        time: number,
        ox: number,
    ): void {
        const backDepth = LANE_DEPTH.upper + 16;
        const backY = cam.sy(0, backDepth);
        const backLayer = depthOrder(backDepth, -2);
        // 塔前山道古碑与指路孤松
        worldArt.tryPlace("sh_stele_banner", "e5_stele_a", cam.sx(ox + 215), backY, cam.len(62), cam.len(70), {
            layer: backLayer, opacity: 0.92,
        });
        worldArt.tryPlace("pine", "e5_pine_a", cam.sx(ox + 640), backY - cam.len(4), cam.len(118), cam.len(102), {
            layer: backLayer - 1, opacity: 0.78, color: Color(156, 168, 182, 255),
        });
        // 塔门入口处（x=1315）真实引路挂灯，呼应下一房北塔门廊
        const lx = cam.sx(ox + 1315);
        const poleTop = backY + cam.len(68);
        const flame = 0.88 + 0.12 * Math.sin(time * 2.9);
        fgDraw.drawSegment(Vec2(lx, backY), Vec2(lx, poleTop), Math.max(1.8, cam.len(2.4)), Color(76, 56, 40, 240));
        fgDraw.drawSegment(Vec2(lx, poleTop), Vec2(lx - cam.len(15), poleTop), Math.max(1.6, cam.len(2)), Color(76, 56, 40, 240));
        worldArt.tryPlace("prop_lantern", "e5_approach_lamp", lx - cam.len(15), poleTop - cam.len(14), cam.len(20), cam.len(24), {
            layer: backLayer + 2,
        });
        fillRadialGlow(fgGlow, lx - cam.len(15), poleTop - cam.len(14), cam.len(74), cam.len(62),
            Color(255, 206, 128, Math.round(92 * flame)), Color(255, 182, 88, 0), 16);
    }
}
