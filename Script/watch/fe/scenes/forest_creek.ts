/**
 * 《向西守望》Wave 2 fe-04 密林与溪湾专章（分镜 F02）。
 *
 * 严格对表《第二波施工书》fe-04、《游戏分镜稿》F02、《动画插入与演出规划》与《明朝全局美术设定》：
 * 1. 密林《小小梦魇》低模暗林与枯枝听声：
 *    - 踩到林径枯枝或听见林犬警觉（dogState === "ear"）时，播放枯枝脆裂音与断裂木屑，
 *      并表现小满微顿侧耳的听声动作（视觉叠层反馈，绝不锁死后端移动）。
 * 2. 草丛前景与剪影分离：
 *    - 严格贴合 rooms.ts 三处草丛（300..380 / 700..790 / 1150..1240, h=24）与两处矮台（520..640 / 980..1100, h=22）；
 *    - 草丛前景给林犬竖耳与小满肩线留出清晰冷月剪影，静音与灰度下可一眼分辨；
 *    - 树根窄洞（高处盘根低拱，犬不可入）与旧渠（低处湿润石盖水渠）纯靠自然形体与月光分辨，不摆路牌或灯带。
 * 3. 溪湾初见北塔（x ≈ 1280..1560）：
 *    - 两路汇合后，北塔暖灯先在脚边水面被涟漪揉碎；
 *    - 随玩家步行走上溪岸（x: 1310 → 1435），前景垂枝自然让开，露出远山真正北塔灯火；
 *    - 停步时水面涟漪与碎灯倒影持续流动，暂停时立即冻结。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { FePluginContext } from "Script/watch/fe/plugins";
import {
    FOREST_CREEK_LIGHT,
    LP_BUCKET,
    LowpolyMaterial,
    LowpolyProjection,
    LowpolyScene,
    MING_MATERIALS,
    clamp01,
    projectWorld3D,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import {
    fillRadialGlow,
    fillVGradRect,
    lerpRGBA,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

const CHILD_AUDIO_ROOT = "assets/audio/child/";

/** 林径枯枝集群位置（段内 X） */
const TWIG_OFFSETS: readonly number[] = [235, 455, 865, 1115];

interface TwigSplinter {
    x: number;
    y: number;
    vx: number;
    vy: number;
    len: number;
    life: number;
    maxLife: number;
}

export interface ForestCreekDebugState {
    active: boolean;
    twigSnapCount: number;
    xiaomanListenTimer: number;
    dogAlertCount: number;
    dogStepCount: number;
    creekReveal: number;
    ripplePhase: number;
    trueLampVisible: boolean;
    reflectionVisible: boolean;
    creekWaterVol: number;
}

const MAT_MOSS_GROUND: LowpolyMaterial = {
    base: rgba(44, 58, 52, 255),
    edge: rgba(108, 134, 122, 145),
    minShade: 0.24,
    rimBoost: 0.20,
    bottomAo: 0.34,
};

const MAT_PINE_TRUNK: LowpolyMaterial = {
    base: rgba(46, 38, 34, 255),
    edge: rgba(98, 92, 86, 130),
    minShade: 0.20,
    rimBoost: 0.16,
    bottomAo: 0.40,
};

const MAT_PINE_NEEDLE: LowpolyMaterial = {
    base: rgba(24, 42, 38, 255),
    edge: rgba(78, 108, 98, 135),
    minShade: 0.22,
    rimBoost: 0.18,
    bottomAo: 0.36,
};

const MAT_ROOT_ARCH: LowpolyMaterial = {
    base: rgba(58, 46, 38, 255),
    edge: rgba(146, 134, 116, 170),
    minShade: 0.22,
    rimBoost: 0.24,
    bottomAo: 0.36,
};

const MAT_CANAL_STONE: LowpolyMaterial = {
    base: rgba(68, 78, 86, 255),
    edge: rgba(164, 186, 198, 190),
    minShade: 0.26,
    rimBoost: 0.28,
    bottomAo: 0.30,
};

const MAT_GRASS_BACK: LowpolyMaterial = {
    base: rgba(36, 56, 50, 255),
    edge: rgba(96, 128, 116, 135),
    minShade: 0.28,
    rimBoost: 0.16,
    bottomAo: 0.32,
};

const MAT_CREEK_WATER: LowpolyMaterial = {
    base: rgba(24, 38, 48, 255),
    edge: rgba(120, 152, 168, 110),
    minShade: 0.35,
    rimBoost: 0.22,
    bottomAo: 0.12,
};

const MAT_TWIG: LowpolyMaterial = {
    base: rgba(114, 92, 68, 255),
    edge: rgba(188, 166, 134, 190),
    minShade: 0.30,
    rimBoost: 0.26,
    bottomAo: 0.20,
};

function drawUiTri(
    uiDraw: DrawNode.Type,
    p0: { x: number; y: number },
    p1: { x: number; y: number },
    p2: { x: number; y: number },
    c0: Color.Type,
    c1: Color.Type,
    c2: Color.Type,
    invScale: number,
): void {
    uiDraw.drawVertices([
        [Vec2(p0.x * invScale, p0.y * invScale), c0],
        [Vec2(p1.x * invScale, p1.y * invScale), c1],
        [Vec2(p2.x * invScale, p2.y * invScale), c2],
    ]);
}

function drawUiQuad(
    uiDraw: DrawNode.Type,
    p0: { x: number; y: number },
    p1: { x: number; y: number },
    p2: { x: number; y: number },
    p3: { x: number; y: number },
    cBot: Color.Type,
    cTop: Color.Type,
    invScale: number,
): void {
    const v0 = Vec2(p0.x * invScale, p0.y * invScale);
    const v1 = Vec2(p1.x * invScale, p1.y * invScale);
    const v2 = Vec2(p2.x * invScale, p2.y * invScale);
    const v3 = Vec2(p3.x * invScale, p3.y * invScale);
    uiDraw.drawVertices([
        [v0, cBot],
        [v1, cBot],
        [v2, cTop],
    ]);
    uiDraw.drawVertices([
        [v0, cBot],
        [v2, cTop],
        [v3, cTop],
    ]);
}

export class ForestCreekScene {
    private animTime = 0;
    private active = false;
    private ripplePhase = 0;
    private creekReveal = 0;
    private creekWaterVol = 0;

    private twigSnapCount = 0;
    private twigTriggered: Record<number, number> = {};
    private xiaomanListenTimer = 0;
    private xiaomanListenDir = 1;

    private prevDogState = "patrol";
    private dogAlertCount = 0;
    private dogStepCount = 0;
    private dogStepAccum = 0;
    private prevDogX = 0;

    private splinters: TwigSplinter[] = [];
    private rng = 9417;

    private proj: LowpolyProjection = {
        morph: 1,
        focal: 405,
        vpFracX: 0.54,
        vpFracY: 0.50,
        vpOffsetX: 0,
        vpOffsetY: 0,
        baseDepth: 0,
    };

    reset(): void {
        this.animTime = 0;
        this.active = false;
        this.ripplePhase = 0;
        this.creekReveal = 0;
        this.creekWaterVol = 0;
        this.twigSnapCount = 0;
        this.twigTriggered = {};
        this.xiaomanListenTimer = 0;
        this.xiaomanListenDir = 1;
        this.prevDogState = "patrol";
        this.dogAlertCount = 0;
        this.dogStepCount = 0;
        this.dogStepAccum = 0;
        this.prevDogX = 0;
        this.splinters = [];
    }

    private rand(): number {
        this.rng = (this.rng * 1664525 + 1013904223) % 4294967296;
        return this.rng / 4294967296;
    }

    getProjection(): LowpolyProjection {
        return this.proj;
    }

    getDebugState(p?: Play): ForestCreekDebugState {
        const px = p !== undefined ? p.player.x : 0;
        const ox = p !== undefined ? p.ox : 0;
        const reflectionVisible = this.active && px >= ox + 1140;
        const trueLampVisible = this.active && this.creekReveal >= 0.35;
        return {
            active: this.active,
            twigSnapCount: this.twigSnapCount,
            xiaomanListenTimer: this.xiaomanListenTimer,
            dogAlertCount: this.dogAlertCount,
            dogStepCount: this.dogStepCount,
            creekReveal: this.creekReveal,
            ripplePhase: this.ripplePhase,
            trueLampVisible,
            reflectionVisible,
            creekWaterVol: this.creekWaterVol,
        };
    }

    update(ctx: FePluginContext): void {
        const p = ctx.p;
        this.active = true;
        const ox = p.ox;

        // 森林不锁死镜头，让正常跟随镜头带动溪湾行走揭示
        ctx.cam.setAnchorLock(undefined);

        // 溪湾揭示进度：随玩家走上溪岸（x: 1310 → 1435）自然拨开前景枝叶，不代玩家移动或转镜
        this.creekReveal = smoothstep(ox + 1310, ox + 1435, p.player.x);

        if (!ctx.paused && ctx.worldDt > 0) {
            const dt = ctx.worldDt;
            this.animTime += dt;
            // 无论小满是否站立停步，溪水水波与碎灯倒影持续自然流动
            this.ripplePhase += dt * 2.4;

            if (this.xiaomanListenTimer > 0) {
                this.xiaomanListenTimer = Math.max(0, this.xiaomanListenTimer - dt);
            }

            // 1. 枯枝踏响检测：小满非蹲伏走过枯枝堆时触发脆裂与微顿侧耳表现
            const movingFast = !p.player.crouch && (Math.abs(p.player.vx) > 10 || !p.player.onGround);
            let i = 0;
            for (i = 0; i < TWIG_OFFSETS.length; i++) {
                const tx = ox + TWIG_OFFSETS[i];
                const lastSnapAt = this.twigTriggered[i] ?? -99;
                if (movingFast && Math.abs(p.player.x - tx) <= 18 && p.player.y <= 8 && (this.animTime - lastSnapAt) > 2.4) {
                    this.twigTriggered[i] = this.animTime;
                    this.triggerTwigSnap(ctx, tx, p.dogX >= p.player.x ? 1 : -1);
                }
            }

            // 2. 林犬警觉（dogState -> "ear" / "chase"）与犬步声反馈
            if (p.room.story !== undefined && p.room.story.dog !== undefined) {
                if (p.dogState === "ear" && this.prevDogState !== "ear") {
                    this.dogAlertCount += 1;
                    this.triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x ? 1 : -1);
                    ctx.audio.playOnce(
                        "fe04:forest:dog_alert:" + ctx.events.roomSessionId + ":" + this.dogAlertCount,
                        "sfx",
                        CHILD_AUDIO_ROOT + "dog_alert.wav",
                        0.82,
                        "fe04:forest:dog_alert",
                        p.ticks,
                    );
                } else if (p.dogState === "chase" && this.prevDogState !== "chase") {
                    this.dogAlertCount += 1;
                    ctx.audio.playOnce(
                        "fe04:forest:dog_chase:" + ctx.events.roomSessionId + ":" + this.dogAlertCount,
                        "sfx",
                        CHILD_AUDIO_ROOT + "dog_alert.wav",
                        0.90,
                        "fe04:forest:dog_chase",
                        p.ticks,
                    );
                }

                const dogDx = Math.abs(p.dogX - this.prevDogX);
                if (dogDx > 0.01 && (p.dogState === "patrol" || p.dogState === "chase" || p.dogState === "back")) {
                    this.dogStepAccum += dogDx;
                    const stepStride = p.dogState === "chase" ? 28 : 42;
                    if (this.dogStepAccum >= stepStride) {
                        this.dogStepAccum = 0;
                        const dist = Math.abs(p.player.x - p.dogX);
                        if (dist < 420) {
                            this.dogStepCount += 1;
                            const vol = 0.24 + 0.48 * clamp01(1 - dist / 420);
                            ctx.audio.playOnce(
                                "fe04:forest:dog_step:" + ctx.events.roomSessionId + ":" + this.dogStepCount,
                                "sfx",
                                CHILD_AUDIO_ROOT + "dog_step.wav",
                                vol,
                                "fe04:forest:dog_step",
                                p.ticks,
                            );
                        }
                    }
                }
                this.prevDogX = p.dogX;
                this.prevDogState = p.dogState;
            }

            // 3. 更新断裂枯枝木屑
            let w = 0;
            for (i = 0; i < this.splinters.length; i++) {
                const sp = this.splinters[i];
                sp.life -= dt;
                if (sp.life > 0) {
                    sp.vy -= 320 * dt;
                    sp.x += sp.vx * dt;
                    sp.y += sp.vy * dt;
                    if (sp.y < 0) {
                        sp.y = 0;
                        sp.vy = 0;
                        sp.vx *= 0.4;
                    }
                    this.splinters[w] = sp;
                    w += 1;
                }
            }
            this.splinters.length = w;

            // 4. 分轨环境音：林风渐弱让位给溪湾清冽溪水声
            const creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x);
            const windVol = 0.34 * (1 - creekApproach * 0.42);
            this.creekWaterVol = 0.02 + 0.54 * creekApproach;
            ctx.audio.playLoop("fe04_forest_wind", "wind", CHILD_AUDIO_ROOT + "forest_wind_loop.wav", windVol, p.ticks);
            if (creekApproach > 0.02) {
                ctx.audio.playLoop("fe04_creek_water", "water", CHILD_AUDIO_ROOT + "creek_loop.wav", this.creekWaterVol, p.ticks);
            } else {
                ctx.audio.stopLoop("fe04_creek_water", 0.25);
            }
        }

        this.proj = {
            morph: 1,
            focal: 405,
            vpFracX: 0.54,
            vpFracY: 0.50,
            vpOffsetX: Math.sin(this.animTime * 0.55) * 1.8,
            vpOffsetY: Math.cos(this.animTime * 0.72) * 1.2,
            baseDepth: 0,
        };
    }

    private triggerTwigSnap(ctx: FePluginContext, worldX: number, listenDir: number): void {
        this.twigSnapCount += 1;
        this.xiaomanListenTimer = 0.52;
        this.xiaomanListenDir = listenDir >= 0 ? 1 : -1;
        ctx.audio.playOnce(
            "fe04:forest:twig:" + ctx.events.roomSessionId + ":" + this.twigSnapCount,
            "sfx",
            CHILD_AUDIO_ROOT + "twig_snap.wav",
            0.84,
            "fe04:forest:twig_snap",
            ctx.p.ticks,
        );
        let i = 0;
        for (i = 0; i < 6; i++) {
            const ang = (0.2 + this.rand() * 0.6) * Math.PI;
            const spd = 45 + this.rand() * 75;
            this.splinters.push({
                x: worldX + (this.rand() - 0.5) * 10,
                y: 2,
                vx: Math.cos(ang) * spd * (this.rand() > 0.5 ? 1 : -1),
                vy: Math.sin(ang) * spd,
                len: 3.5 + this.rand() * 3.5,
                life: 0.38 + this.rand() * 0.22,
                maxLife: 0.60,
            });
        }
    }

    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        _backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const w = cam.viewW;
        const h = cam.viewH;

        // 随走近溪湾（x: 1120 -> 1460），夜空由深松林冷墨青微转为将晓鱼肚浅灰蓝
        const dawn = smoothstep(ox + 1120, ox + 1460, p.player.x);
        const skyTop = lerpRGBA(rgba(8, 14, 18, 255), rgba(16, 26, 38, 255), dawn);
        const skyMid = lerpRGBA(rgba(16, 28, 32, 255), rgba(32, 46, 62, 255), dawn);
        const skyHor = lerpRGBA(rgba(28, 44, 48, 255), rgba(62, 78, 94, 255), dawn);
        const splitY = h * 0.46;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(skyMid), toColor(skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(skyHor), toColor(skyMid));

        const scene = new LowpolyScene(cam, this.proj, FOREST_CREEK_LIGHT);

        // 1. 远山脊线（z = 460）
        scene.addDistantRidge(
            [
                { x: ox - 180, y: 128 },
                { x: ox + 220, y: 186 },
                { x: ox + 620, y: 152 },
                { x: ox + 1040, y: 204 },
                { x: ox + 1420, y: 168 },
                { x: ox + 1780, y: 196 },
            ],
            -40,
            460,
            MING_MATERIALS.distantHill,
            { bucket: LP_BUCKET.BACKDROP },
        );

        // 2. 远景密林多层古松（三层交错低模松冠 + 渐细树干，杜绝单调单三角几何感）
        const treeXs = [80, 210, 360, 510, 670, 840, 1010, 1180, 1290];
        let i = 0;
        for (i = 0; i < treeXs.length; i++) {
            const tx = ox + treeXs[i];
            const tz = 185 + (i % 3) * 42;
            const tw = 12 + (i % 2) * 5;
            scene.addBox({
                x0: tx - tw * 0.5,
                x1: tx + tw * 0.5,
                y0: -20,
                y1: 185 + (i % 2) * 20,
                z0: tz,
                z1: tz + 16,
                material: MING_MATERIALS.distantWall,
                bucket: LP_BUCKET.BACKDROP,
                edgeWidth: 0,
            });
            // 三层错落低模松冠（下宽上收、略带风偏）
            const lean = ((i % 3) - 1) * 7;
            const baseH = 92 + (i % 2) * 14;
            let tier = 0;
            for (tier = 0; tier < 3; tier++) {
                const ty0 = baseH + tier * 32;
                const ty1 = ty0 + 52 - tier * 6;
                const half = 50 - tier * 11;
                const colShift = tier * 4;
                scene.addTri3D(
                    vec3(tx - half + lean * 0.4, ty0, tz - 4 - tier * 2),
                    vec3(tx + half + lean * 0.4, ty0 + 4, tz - 4 - tier * 2),
                    vec3(tx + lean, ty1, tz + 4),
                    { base: rgba(18 + colShift, 30 + colShift, 32 + colShift, 255) },
                    { bucket: LP_BUCKET.BACKDROP, sortBias: 0.04 + tier * 0.01 },
                );
            }
        }

        // 3. 远山北塔实景剪影（位于溪湾尽头右上方 x = 1525, z = 340；进入溪湾前被前景垂枝遮挡，步上溪岸才露真灯！）
        const towerX = ox + 1525;
        scene.addBox({
            x0: towerX - 24,
            x1: towerX + 24,
            y0: 44,
            y1: 174,
            z0: 332,
            z1: 356,
            material: MING_MATERIALS.distantWall,
            bucket: LP_BUCKET.BACKDROP,
            sortBias: 0.12,
            edgeWidth: 0,
        });
        // 明代望塔重檐屋顶
        scene.addTri3D(
            vec3(towerX - 34, 174, 330),
            vec3(towerX + 34, 174, 330),
            vec3(towerX, 200, 344),
            MING_MATERIALS.mingTile,
            { bucket: LP_BUCKET.BACKDROP, sortBias: 0.14 },
        );

        // 4. 山谷冷雾带
        scene.addFogBand(ox - 160, ox + 1780, -30, 148, 250, rgba(28, 42, 48, 255), 0.62, 0.06, {
            bucket: LP_BUCKET.BACKDROP,
        });

        scene.flush(bgDraw, bgGlow);

        // 5. 真北塔西窗暖灯（随与水面倒影完全同拍呼吸，前期被前景枝叶自然遮住）
        const lampPulse = 0.84 + 0.16 * Math.sin(this.animTime * 2.3);
        const lampPt = projectWorld3D(towerX - 4, 146, 330, cam, this.proj);
        fillRadialGlow(
            bgGlow,
            lampPt.x,
            lampPt.y,
            42 * lampPulse,
            42 * lampPulse,
            Color(246, 208, 134, Math.round(115 * lampPulse)),
            Color(232, 176, 86, 0),
            16,
        );
        bgDraw.drawRect(Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), Color(255, 232, 174, 240));
        bgGlow.drawDot(Vec2(lampPt.x, lampPt.y), 3.4, Color(255, 246, 218, 250));

        return true;
    }

    drawWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const scene = new LowpolyScene(cam, this.proj, FOREST_CREEK_LIGHT);

        // 1. 密林厚苔土路（x = 0..1310）+ 溪湾岸石与水面（x = 1280..1600）
        scene.addBox({
            x0: ox - 40,
            x1: ox + 1320,
            y0: -52,
            y1: 0,
            z0: -26,
            z1: 92,
            material: MAT_MOSS_GROUND,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
            edgeWidth: 0.7,
        });
        // 溪湾岸石走面（1320..1600，wz = 0 保持平实落脚，近侧与远侧展露清冷水湾）
        scene.addBox({
            x0: ox + 1320,
            x1: ox + 1620,
            y0: -14,
            y1: 0,
            z0: -10,
            z1: 24,
            material: MING_MATERIALS.mingStoneStep,
            bucket: LP_BUCKET.WALK_DECK,
            highlightTopEdge: true,
            edgeWidth: 0.9,
        });
        // 溪湾宽阔水面（近岸前水 z = -44..-10 与远岸主水湾 z = 24..185）
        scene.addQuad3D(
            vec3(ox + 1250, -6, -44),
            vec3(ox + 1640, -6, -44),
            vec3(ox + 1640, -2, -10),
            vec3(ox + 1250, -2, -10),
            MAT_CREEK_WATER,
            { bucket: LP_BUCKET.WALK_DECK, sortBias: 0.08, edgeWidth: 0 },
        );
        scene.addQuad3D(
            vec3(ox + 1250, -2, 24),
            vec3(ox + 1660, -2, 24),
            vec3(ox + 1660, 4, 196),
            vec3(ox + 1250, 4, 196),
            MAT_CREEK_WATER,
            { bucket: LP_BUCKET.MIDGROUND, sortBias: 0.04, edgeWidth: 0 },
        );

        // 2. 中景古松树干与分层松冠（z = 36..82，带自然锥形树干、斜枝与多层墨绿针叶冠，摆脱黑方柱观感）
        const midTrunks = [150, 415, 650, 910, 1255];
        let i = 0;
        for (i = 0; i < midTrunks.length; i++) {
            const tx = ox + midTrunks[i];
            const tz = 38 + (i % 2) * 18;
            const halfW = 10 + (i % 2) * 2;
            const topW = halfW * 0.62;
            // 微收分古松树干
            scene.addQuad3D(
                vec3(tx - halfW, -10, tz),
                vec3(tx + halfW, -10, tz),
                vec3(tx + topW, 205, tz),
                vec3(tx - topW, 205, tz),
                MAT_PINE_TRUNK,
                { bucket: LP_BUCKET.MIDGROUND, edgeWidth: 0.7 },
            );
            // 侧向低垂古松枝与两层冷绿松针冠
            const bDir = i % 2 === 0 ? 1 : -1;
            scene.addTri3D(
                vec3(tx - topW * 0.5, 118, tz - 2),
                vec3(tx + bDir * 56, 108, tz - 4),
                vec3(tx + bDir * 12, 142, tz - 2),
                MAT_PINE_NEEDLE,
                { bucket: LP_BUCKET.MIDGROUND, sortBias: 0.08, edgeWidth: 0.6 },
            );
            scene.addTri3D(
                vec3(tx - bDir * 44, 146, tz - 2),
                vec3(tx + bDir * 48, 152, tz - 3),
                vec3(tx, 198, tz - 2),
                MAT_PINE_NEEDLE,
                { bucket: LP_BUCKET.MIDGROUND, sortBias: 0.10, edgeWidth: 0.6 },
            );
        }

        // 3. 严格贴合 rooms.ts 两处矮台（520..640 / 980..1100，高 22）的盘结树根与青石坎
        for (i = 0; i < p.room.stairs.length; i++) {
            const st = p.room.stairs[i];
            scene.addBox({
                x0: st.x0,
                x1: st.x1,
                y0: 0,
                y1: st.y1,
                z0: -14,
                z1: 42,
                material: i === 1 ? MAT_ROOT_ARCH : MING_MATERIALS.mingStoneStep,
                bucket: LP_BUCKET.WALK_DECK,
                highlightTopEdge: true,
                edgeWidth: 0.9,
            });
        }

        // 4. 双岔路自然形体辨识（不摆路牌、不画灯带）：
        //    4a. 树根窄洞（包覆第二处矮台 968..1122 的盘结有机树根低拱，仅容小满快穿、犬挤不进）
        //        左粗树根柱 + 右斜根柱 + 拱形交叉盘根顶梁（去生硬方框感）
        scene.addTri3D(
            vec3(ox + 958, 0, 12),
            vec3(ox + 998, 22, 12),
            vec3(ox + 986, 104, 22),
            MAT_ROOT_ARCH,
            { bucket: LP_BUCKET.MIDGROUND, edgeWidth: 0.9 },
        );
        scene.addTri3D(
            vec3(ox + 1086, 22, 12),
            vec3(ox + 1134, 0, 12),
            vec3(ox + 1098, 106, 22),
            MAT_ROOT_ARCH,
            { bucket: LP_BUCKET.MIDGROUND, edgeWidth: 0.9 },
        );
        scene.addQuad3D(
            vec3(ox + 972, 74, 14),
            vec3(ox + 1110, 78, 14),
            vec3(ox + 1094, 116, 36),
            vec3(ox + 986, 112, 36),
            MAT_ROOT_ARCH,
            { bucket: LP_BUCKET.MIDGROUND, sortBias: 0.10, edgeWidth: 1.0 },
        );
        // 树根洞内暗影与冷月微光缝（纯自然形体提示可钻）
        scene.addQuad3D(
            vec3(ox + 992, 22, 34),
            vec3(ox + 1088, 22, 34),
            vec3(ox + 1080, 74, 34),
            vec3(ox + 1000, 74, 34),
            { base: rgba(10, 16, 18, 215), edge: rgba(164, 192, 188, 130) },
            { bucket: LP_BUCKET.MIDGROUND, unlit: true, sortBias: -0.05, edgeWidth: 1.0 },
        );
        //    4b. 旧渠（后排 z = 24..64 凹陷青石盖板与铁栅，以冷月湿石反光与石槽形体自然区分）
        scene.addBox({
            x0: ox + 830,
            x1: ox + 1230,
            y0: -10,
            y1: 5,
            z0: 26,
            z1: 60,
            material: MAT_CANAL_STONE,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
            edgeWidth: 0.9,
        });
        // 掀开一角的旧渠石盖板（靠自然斜角与阴影识别，无箭头/光柱）
        scene.addQuad3D(
            vec3(ox + 858, 5, 28),
            vec3(ox + 894, 5, 28),
            vec3(ox + 888, 20, 44),
            vec3(ox + 852, 18, 44),
            MAT_CANAL_STONE,
            { bucket: LP_BUCKET.MIDGROUND, sortBias: 0.22, edgeWidth: 1.0 },
        );

        // 5. 三处可穿透草丛的后排草叶（严格对应 rooms.ts solids 300..380 / 700..790 / 1150..1240, h=24）
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable === true) {
                this.buildGrassCluster(scene, s.x, s.x + s.w, s.y, s.h, 8);
            } else if (s.x >= ox + 1500) {
                // 林缘界石（1560..1600）塑为溪岸山岩
                scene.addBox({
                    x0: s.x,
                    x1: s.x + s.w,
                    y0: s.y,
                    y1: s.y + s.h,
                    z0: 10,
                    z1: 72,
                    material: MING_MATERIALS.mingBrickDark,
                    bucket: LP_BUCKET.MIDGROUND,
                    highlightTopEdge: true,
                });
            }
        }

        // 6. 林径枯枝堆（视觉可提前预判脚下脆枝，静音亦可读）
        for (i = 0; i < TWIG_OFFSETS.length; i++) {
            const tx = ox + TWIG_OFFSETS[i];
            scene.addTri3D(
                vec3(tx - 12, 0.8, -5),
                vec3(tx + 12, 0.8, -3),
                vec3(tx + 3, 6.2, 2),
                MAT_TWIG,
                { bucket: LP_BUCKET.PROP, sortBias: 0.15, edgeWidth: 1.0 },
            );
            scene.addTri3D(
                vec3(tx - 8, 0.8, 3),
                vec3(tx + 14, 0.8, 5),
                vec3(tx - 2, 5.2, -2),
                MAT_TWIG,
                { bucket: LP_BUCKET.PROP, sortBias: 0.16, edgeWidth: 0.9 },
            );
        }

        // 7. 2D 角色脚底接触影（小满与林犬，严格贴合 wz = 0）
        scene.addContactShadow(p.player.x, p.player.y, 14, 10, 0.80, { bucket: LP_BUCKET.PROP, sortBias: 0.45 });
        if (p.room.story !== undefined && p.room.story.dog !== undefined) {
            scene.addContactShadow(p.dogX, 0, 18, 11, 0.82, { bucket: LP_BUCKET.PROP, sortBias: 0.44 });
        }

        scene.flush(fgDraw, fgGlow);

        // 8. 溪湾脚边水面涟漪与揉碎的北塔灯影（停步持续流动，先见水里灯、上岸才见真灯！）
        this.drawCreekWaterReflection(fgDraw, fgGlow, p, cam);

        // 9. 枯枝断裂溅屑
        for (i = 0; i < this.splinters.length; i++) {
            const sp = this.splinters[i];
            const a = clamp01(sp.life / sp.maxLife);
            const sx = cam.sx(sp.x);
            const sy = cam.sy(sp.y);
            fgDraw.drawSegment(Vec2(sx - sp.len, sy - 1), Vec2(sx + sp.len, sy + 2), 1.3, Color(204, 182, 146, Math.round(235 * a)));
        }

        return true;
    }

    private buildGrassCluster(scene: LowpolyScene, x0: number, x1: number, y0: number, h: number, z: number): void {
        const count = Math.max(7, Math.floor((x1 - x0) / 10));
        const span = (x1 - x0) / count;
        let k = 0;
        for (k = 0; k < count; k++) {
            const bx = x0 + (k + 0.5) * span;
            const lean = (((k * 29) % 11) - 5) * 1.3;
            const sway = Math.sin(this.animTime * 1.9 + bx * 0.06) * 2.8 + lean;
            const tipH = h * (0.58 + ((k * 37) % 10) * 0.048);
            scene.addTri3D(
                vec3(bx - span * 0.42, y0, z),
                vec3(bx + span * 0.42, y0, z),
                vec3(bx + sway, y0 + tipH, z - 2),
                MAT_GRASS_BACK,
                { bucket: LP_BUCKET.PROP, sortBias: 0.10 + k * 0.005, edgeWidth: 0.45 },
            );
        }
    }

    private drawCreekWaterReflection(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
    ): void {
        const ox = p.ox;
        if (cam.sx(ox + 1230) > cam.viewW + 120) {
            return;
        }
        const lampPulse = 0.84 + 0.16 * Math.sin(this.animTime * 2.3);
        const reflCenterX = ox + 1438;

        // 1. 远近水面冷月水平波纹（停步持续向右下方荡漾）
        let r = 0;
        for (r = 0; r < 10; r++) {
            const z = r < 4 ? (-34 + r * 6) : (32 + (r - 4) * 24);
            const wx = ox + 1295 + r * 32 + Math.sin(this.ripplePhase * 0.75 + r * 1.4) * 14;
            const pL = projectWorld3D(wx - 26, -3, z, cam, this.proj);
            const pR = projectWorld3D(wx + 26, -3, z, cam, this.proj);
            fgGlow.drawSegment(Vec2(pL.x, pL.y), Vec2(pR.x, pR.y), 1.1, Color(146, 178, 198, 72));
        }

        // 2. 被涟漪揉碎的北塔暖灯倒影（先落在脚边前水与近湾水面，随 ripplePhase 持续错动明灭）
        const bands = 9;
        for (r = 0; r < bands; r++) {
            const frac = r / (bands - 1);
            const z = -34 + frac * 22;
            const drift = Math.sin(this.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9);
            const halfW = (18 - frac * 8) * (0.75 + 0.25 * Math.cos(this.ripplePhase * 1.7 + r));
            const wy = -4.5 + frac * 2.5;
            const pL = projectWorld3D(reflCenterX + drift - halfW, wy, z, cam, this.proj);
            const pR = projectWorld3D(reflCenterX + drift + halfW, wy, z, cam, this.proj);
            const a = (0.42 + 0.50 * (1 - frac)) * lampPulse;
            fgDraw.drawSegment(Vec2(pL.x, pL.y), Vec2(pR.x, pR.y), 2.1 - frac * 0.7, Color(242, 198, 118, Math.round(190 * a)));
            fgGlow.drawSegment(Vec2(pL.x, pL.y), Vec2(pR.x, pR.y), 3.6 - frac * 1.1, Color(248, 214, 140, Math.round(135 * a)));
        }
        // 主水面上的灯影晕
        const poolP = projectWorld3D(reflCenterX + 22, 0, 56, cam, this.proj);
        fillRadialGlow(
            fgGlow,
            poolP.x,
            poolP.y,
            58 * lampPulse,
            18 * lampPulse,
            Color(246, 206, 128, Math.round(92 * lampPulse)),
            Color(232, 174, 88, 0),
            16,
        );
    }

    /** 接管密林道具层（清除原有冰青通行带，保持纯粹自然环境引导） */
    drawPropsOverlay(
        _fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        _ctx: FePluginContext,
    ): boolean {
        return true;
    }

    /** 在角色之上绘制草后犬耳、小满肩线冷月轮廓分离及枯枝微顿侧耳听声动作 */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;

        // 1. 小满肩背极克制冷月边缘分离（贴合肩线而非头顶光环，草丛前景与暗林阴影里清晰分离）
        const px = cam.sx(p.player.x);
        const pTopY = cam.sy(p.player.y + p.player.h);
        const fDir = p.player.facing >= 0 ? 1 : -1;
        const shY = pTopY - cam.len(16.5);
        fgDraw.drawSegment(
            Vec2(px - fDir * cam.len(7.5), shY - cam.len(4)),
            Vec2(px - fDir * cam.len(5.5), shY + cam.len(3.5)),
            1.3,
            Color(196, 212, 220, 145),
        );
        fgDraw.drawSegment(
            Vec2(px - fDir * cam.len(5.5), shY + cam.len(3.5)),
            Vec2(px + fDir * cam.len(3.5), shY + cam.len(5.2)),
            1.2,
            Color(206, 220, 228, 135),
        );

        // 2. 踩枯枝 / 听见动静时的小满微顿侧耳听声视觉反馈（克制听觉细弧，非阻塞）
        if (this.xiaomanListenTimer > 0) {
            const k = smoothstep(0, 0.12, this.xiaomanListenTimer) * clamp01(this.xiaomanListenTimer / 0.52);
            const earX = px + this.xiaomanListenDir * cam.len(8);
            const earY = pTopY - cam.len(10);
            const r1 = cam.len(6.5 + (1 - k) * 8);
            const r2 = cam.len(11.5 + (1 - k) * 11);
            const startAng = this.xiaomanListenDir > 0 ? -34 : 146;
            const endAng = this.xiaomanListenDir > 0 ? 34 : 214;
            fgDraw.drawArc(Vec2(earX, earY), r1, startAng, endAng, 1.3, Color(224, 218, 198, Math.round(185 * k)));
            fgGlow.drawArc(Vec2(earX, earY), r2, startAng, endAng, 1.1, Color(204, 218, 224, Math.round(135 * k)));
        }

        // 3. 林犬竖耳与鼻尖冷月轮廓（暗耳体 + 细冷月描边，草后自然且灰度高可读）
        if (p.room.story !== undefined && p.room.story.dog !== undefined) {
            const alert = p.dogState === "ear" || p.dogState === "chase";
            const f = p.dogState === "chase" ? (p.player.x >= p.dogX ? 1 : -1) : p.dogDir;
            const headX = cam.sx(p.dogX + f * 11);
            const headY = cam.sy(23.5);
            const earH = cam.len(alert ? 7.6 : 4.8);
            const earCol = alert ? Color(224, 222, 212, 220) : Color(176, 194, 202, 170);
            fgDraw.drawPolygon([
                Vec2(headX - f * 3.4, headY),
                Vec2(headX - f * 0.8, headY + earH),
                Vec2(headX + f * 2.4, headY + 0.8),
            ], Color(38, 36, 34, 235), 1.1, earCol);
            if (alert) {
                const waveR = cam.len(8 + (this.animTime * 20) % 13);
                fgGlow.drawArc(Vec2(headX, headY + earH * 0.75), waveR, 42, 138, 1.2, Color(226, 208, 174, 145));
            }
        }

        // 暂停态前景枝叶兜底
        if (ctx.paused) {
            const pX = cam.viewW * (0.78 + this.creekReveal * 0.24);
            worldArt.tryPlace("pine", "fe04_pause_creek_branch", pX, cam.viewH * 0.42, cam.viewW * 0.48, cam.viewH * 0.62, {
                color: Color(14, 20, 22, 255),
                opacity: 0.90 * (1 - this.creekReveal * 0.7),
                layer: 5300,
            });
        }
    }

    /**
     * 在 uiDraw 前景层（严格在角色 sprites 之前、HUD 之后）绘制：
     * 1. 草丛前景低垂草叶（高度严格压在 y <= 20，留出上方犬耳与小满肩线清晰剪影）；
     * 2. 溪湾前景垂枝（随玩家步上溪岸 reveal 0→1 自然向左右让开，显露远山真北塔灯火）；
     * 固定返回 false。
     */
    drawForegroundOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        _uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const inv = 1 / Math.max(0.25, ctx.uiScale);

        // 1. 三处草丛前景自然倾倒草叶（z = -18，高度压在 y <= 18，保证上方犬耳与小满肩线清晰分离）
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable !== true) {
                continue;
            }
            const blades = Math.max(7, Math.floor(s.w / 10));
            const span = s.w / blades;
            let k = 0;
            for (k = 0; k < blades; k++) {
                const bx = s.x + (k + 0.5) * span;
                const lean = (((k * 23) % 9) - 4) * 1.6;
                const sway = Math.sin(this.animTime * 2.1 + bx * 0.06) * 2.6 + lean;
                const tipH = Math.min(18.0, s.h * (0.48 + ((k * 19) % 7) * 0.048));
                const pL = projectWorld3D(bx - span * 0.36, s.y - 2, -18, cam, this.proj);
                const pR = projectWorld3D(bx + span * 0.36, s.y - 2, -18, cam, this.proj);
                const pT = projectWorld3D(bx + sway, s.y + tipH, -20, cam, this.proj);
                drawUiTri(uiDraw, pL, pR, pT, Color(11, 18, 17, 232), Color(14, 22, 20, 232), Color(32, 50, 44, 218), inv);
            }
        }

        // 2. 溪湾前景垂枝（粗枝干 + 错落垂叶群，初入溪湾自然遮挡真塔灯、只见脚边水面碎影；
        //    随玩家走上溪岸 reveal 0 -> 1 自然向两侧拨开，露出真北塔灯火！）
        const nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x);
        if (nearCreek > 0.02) {
            const w = cam.viewW;
            const h = cam.viewH;
            const partShift = this.creekReveal * w * 0.38;
            const liftShift = this.creekReveal * h * 0.16;
            const canopyAlpha = Math.round(244 * nearCreek * (1 - this.creekReveal * 0.28));
            const cTrunk = Color(14, 18, 18, canopyAlpha);
            const cDark = Color(11, 20, 20, canopyAlpha);
            const cLeaf = Color(22, 36, 33, Math.round(canopyAlpha * 0.94));
            const sway = Math.sin(this.animTime * 1.45) * 5;

            // 斜探的粗松枝干（自右上角自然伸展至中右上方）
            drawUiQuad(
                uiDraw,
                { x: w * 0.56 + partShift + sway * 0.4, y: h * 0.67 + liftShift },
                { x: w * 1.06 + partShift, y: h * 0.84 + liftShift },
                { x: w * 1.06 + partShift, y: h * 0.96 + liftShift },
                { x: w * 0.54 + partShift + sway * 0.4, y: h * 0.74 + liftShift },
                cTrunk,
                cDark,
                inv,
            );
            // 错落有机垂叶簇（覆盖 0.50w..1.05w 上方，去规整方块与等腰三角）
            const clusters = [
                { fx: 0.56, fy: 0.66, rw: 118, rh: 92, drop: 112 },
                { fx: 0.68, fy: 0.62, rw: 138, rh: 108, drop: 134 },
                { fx: 0.81, fy: 0.64, rw: 146, rh: 112, drop: 124 },
                { fx: 0.94, fy: 0.70, rw: 142, rh: 118, drop: 116 },
                { fx: 0.74, fy: 0.78, rw: 165, rh: 110, drop: 92 },
            ];
            let ci = 0;
            for (ci = 0; ci < clusters.length; ci++) {
                const cl = clusters[ci];
                const bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12);
                const by = h * cl.fy + liftShift;
                drawUiTri(
                    uiDraw,
                    { x: bx - cl.rw * 0.65, y: by + cl.rh * 0.85 },
                    { x: bx + cl.rw * 0.72, y: by + cl.rh * 0.62 },
                    { x: bx - cl.rw * 0.12 + sway * 0.6, y: by - cl.drop * 0.68 },
                    cDark,
                    cDark,
                    cLeaf,
                    inv,
                );
                drawUiTri(
                    uiDraw,
                    { x: bx - cl.rw * 0.28, y: by + cl.rh * 0.92 },
                    { x: bx + cl.rw * 0.88, y: by + cl.rh * 0.82 },
                    { x: bx + cl.rw * 0.24 + sway * 0.8, y: by - cl.drop * 0.54 },
                    cDark,
                    cTrunk,
                    cLeaf,
                    inv,
                );
            }

            // 左侧平衡垂枝（随步行向左轻微让开）
            const lShift = this.creekReveal * w * 0.22;
            drawUiTri(
                uiDraw,
                { x: -30 - lShift, y: h + 16 },
                { x: w * 0.30 - lShift, y: h + 16 },
                { x: w * 0.12 - lShift - sway * 0.5, y: h * 0.68 + liftShift * 0.5 },
                cDark,
                cDark,
                cLeaf,
                inv,
            );
        }

        return false;
    }
}
