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

import { Color, Content, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { FePluginContext } from "Script/watch/fe/plugins";
import {
    LowpolyProjection,
    clamp01,
    projectWorld3D,
    smoothstep,
} from "Script/watch/fe/renderer/lowpoly";
import { drawChildColdMoonGrade } from "Script/watch/fe/renderer/slideshow";
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
                        -1,
                        { pan: ctx.audio.panForWorldX(p.dogX) },
                    );
                } else if (p.dogState === "chase" && this.prevDogState !== "chase") {
                    this.dogAlertCount += 1;
                    const chasePath = Content.exist("assets/audio/foley/dog_chase_bark.wav")
                        ? "assets/audio/foley/dog_chase_bark.wav"
                        : (CHILD_AUDIO_ROOT + "dog_alert.wav");
                    ctx.audio.playOnce(
                        "fe04:forest:dog_chase:" + ctx.events.roomSessionId + ":" + this.dogAlertCount,
                        "sfx",
                        chasePath,
                        0.90,
                        "fe04:forest:dog_chase",
                        p.ticks,
                        -1,
                        { pan: ctx.audio.panForWorldX(p.dogX) },
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
                                -1,
                                { pan: ctx.audio.panForWorldX(p.dogX) },
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
            -1,
            { pan: ctx.audio.panForWorldX(worldX) },
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
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const w = cam.viewW;
        const h = cam.viewH;

        // 随走近溪湾（x: 1120 -> 1460），像素松林远景由深墨青微转为将晓浅蓝灰
        const dawn = smoothstep(ox + 1120, ox + 1460, p.player.x);
        const skyTop = lerpRGBA(rgba(8, 14, 18, 255), rgba(16, 26, 38, 255), dawn);
        const skyHor = lerpRGBA(rgba(22, 36, 40, 255), rgba(52, 68, 86, 255), dawn);
        fillVGradRect(bgDraw, 0, 0, w, h, toColor(skyHor), toColor(skyTop));

        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const artW = Math.max(w, (h * 16) / 9) * 1.24;
        const artH = (artW * 9) / 16;
        const artY = Math.min(0, Math.max(h - artH, cam.groundScreenY - artH * 0.24));
        const bgTint = toColor(lerpRGBA(rgba(138, 170, 180, 255), rgba(194, 210, 232, 255), dawn));
        backdropArt.tryPlace("bgFar_forest", "fe04_bg_forest", w * (0.5 - progress * 0.08), artY, artW, artH, {
            color: bgTint,
            layer: 0,
        });
        fillVGradRect(bgGlow, 0, cam.groundScreenY - 2, w, h * 0.16, Color(24, 40, 44, 26), Color(12, 20, 24, 0));

        // 远山北塔真灯（前期被前景像素松枝遮住，走上溪岸后拨枝显露！）
        const towerX = ox + 1525;
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
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const groundY = cam.sy(0);
        const deckH = cam.len(26);

        // 1. 密林厚苔土路（0..1190）+ 溪湾石岸与冷水湾（1180..1620）
        const xForest0 = cam.sx(ox - 40);
        const xCreek0 = cam.sx(ox + 1185);
        const xCreek1 = cam.sx(ox + 1640);
        if (groundY - deckH > 0) {
            fillVGradRect(fgDraw, xForest0, 0, xCreek0 - xForest0, groundY - deckH + 1, Color(8, 14, 14, 255), Color(18, 28, 26, 255));
            // 溪湾前岸清冷水池底色
            fillVGradRect(fgDraw, xCreek0, 0, xCreek1 - xCreek0, groundY - cam.len(6), Color(12, 22, 32, 255), Color(24, 42, 54, 255));
        }
        const tileSpan = Math.max(24, cam.len(74));
        let j = 0;
        for (j = 0; xForest0 + j * tileSpan < Math.min(xCreek0, cam.viewW + 40); j++) {
            const tx = xForest0 + j * tileSpan;
            const tw = Math.min(tileSpan, xCreek0 - tx);
            if (tx + tw < -40) {
                continue;
            }
            worldArt.tryPlace("fe_ground_soft", "fe04_for_moss_" + j, tx + tw * 0.5, groundY - deckH, tw + 2.0, deckH, {
                color: Color(118, 148, 134, 255),
                layer: 1,
            });
        }
        for (j = 0; xCreek0 + j * tileSpan < Math.min(xCreek1, cam.viewW + 40); j++) {
            const tx = xCreek0 + j * tileSpan;
            const tw = Math.min(tileSpan, xCreek1 - tx);
            if (tx + tw < -40) {
                continue;
            }
            worldArt.tryPlace("fe_road_stone", "fe04_for_bank_" + j, tx + tw * 0.5, groundY - cam.len(14), tw + 0.5, cam.len(14), {
                color: Color(162, 184, 204, 255),
                layer: 2,
            });
        }

        // 2. 中景像素古松剪影（摆脱低模黑方柱与三角块）
        const midTrunks = [150, 415, 650, 910, 1255];
        let i = 0;
        for (i = 0; i < midTrunks.length; i++) {
            const sx = cam.sx(ox + midTrunks[i]);
            if (sx < -160 || sx > cam.viewW + 160) {
                continue;
            }
            worldArt.tryPlace("pine", "fe04_for_pine_" + i, sx, groundY - cam.len(4), cam.len(122 + (i % 2) * 18), cam.len(196 + (i % 2) * 24), {
                color: Color(108, 136, 134, 255),
                opacity: 0.78,
                facing: i % 2 === 0 ? 1 : -1,
                layer: 0,
            });
        }

        // 3. 两处矮台（520..640 / 980..1100，h=22）
        for (i = 0; i < p.room.stairs.length; i++) {
            const st = p.room.stairs[i];
            const sx0 = cam.sx(st.x0);
            const sx1 = cam.sx(st.x1);
            const sy1 = cam.sy(st.y1);
            worldArt.tryPlace(i === 1 ? "cover_wood" : "cover_stone", "fe04_for_ledge_" + i, (sx0 + sx1) * 0.5, groundY, sx1 - sx0, sy1 - groundY, {
                color: Color(148, 168, 174, 255),
                layer: 2,
            });
            worldArt.tryPlace("slab", "fe04_for_ledge_top_" + i, (sx0 + sx1) * 0.5, sy1 - cam.len(4), sx1 - sx0, cam.len(4.5), {
                color: Color(172, 192, 202, 255),
                layer: 2,
            });
        }

        // 4. 双岔路像素自然地貌：
        //    4a. 盘结树根低拱（300..380 蹲行隐蔽段）
        worldArt.tryPlace("fe_root_arch", "fe04_for_root_arch", cam.sx(ox + 348), groundY, cam.len(134), cam.len(92), {
            color: Color(176, 194, 198, 255),
            layer: 3,
        });
        //    4b. 湿润青石旧渠（700..790 站跑快行段）
        worldArt.tryPlace("fe_ground_brick", "fe04_for_canal_a", cam.sx(ox + 720), groundY - cam.len(4), cam.len(62), cam.len(18), {
            color: Color(176, 198, 214, 255),
            layer: 2,
        });
        worldArt.tryPlace("fe_ground_brick", "fe04_for_canal_b", cam.sx(ox + 780), groundY - cam.len(4), cam.len(62), cam.len(18), {
            color: Color(176, 198, 214, 255),
            facing: -1,
            layer: 2,
        });

        // 5. 三处可穿透草丛后排像素草丛 + 林缘山岩
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            const sx0 = cam.sx(s.x);
            const sx1 = cam.sx(s.x + s.w);
            if (sx1 < -40 || sx0 > cam.viewW + 40) {
                continue;
            }
            if (s.passable === true) {
                worldArt.tryPlace("grass", "fe04_for_grass_bg_" + i, (sx0 + sx1) * 0.5, cam.sy(s.y), sx1 - sx0, cam.len(s.h * 1.15), {
                    color: Color(128, 162, 152, 255),
                    opacity: 0.88,
                    layer: 2,
                });
            } else if (s.x >= ox + 1500) {
                const bw = sx1 - sx0;
                const bh = cam.len(s.h);
                const rows = Math.max(1, Math.min(8, Math.round(s.h / 36)));
                const rowH = bh / rows;
                let r = 0;
                for (r = 0; r < rows; r++) {
                    worldArt.tryPlace("wall", "fe04_for_bound_" + i + "_" + r, (sx0 + sx1) * 0.5, cam.sy(s.y) + r * rowH, bw + 0.5, rowH + 0.5, {
                        color: Color(128, 146, 162, 255),
                        facing: r % 2 === 0 ? 1 : -1,
                        layer: 2,
                    });
                }
            }
        }

        // 6. 林径枯枝堆（像素碎枝与木片，静音可读）
        for (i = 0; i < TWIG_OFFSETS.length; i++) {
            const tx = cam.sx(ox + TWIG_OFFSETS[i]);
            worldArt.tryPlace("stone_chips", "fe04_for_twig_" + i, tx, groundY + cam.len(4), cam.len(22), cam.len(12), {
                color: Color(188, 154, 114, 255),
                layer: 3,
            });
        }

        // 7. 2D 角色脚底接触影
        fgDraw.drawEllipse(Vec2(cam.sx(p.player.x), cam.sy(p.player.y) + 1), cam.len(14), 3.4, Color(8, 12, 14, 155));
        if (p.room.story !== undefined && p.room.story.dog !== undefined) {
            fgDraw.drawEllipse(Vec2(cam.sx(p.dogX), groundY + 1), cam.len(18), 3.8, Color(8, 12, 14, 165));
        }

        // 8. 溪湾脚边水面像素涟漪与揉碎北塔灯影（停步持续流动，暂停冻结）
        this.drawCreekWaterReflection(fgDraw, fgGlow, worldArt, p, cam);

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

    private drawCreekWaterReflection(
        _fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const ox = p.ox;
        if (cam.sx(ox + 1230) > cam.viewW + 120) {
            return;
        }
        const lampPulse = 0.84 + 0.16 * Math.sin(this.animTime * 2.3);
        const reflCenterX = ox + 1438;
        const groundY = cam.sy(0);

        // 3 帧像素溪水涟漪与碎灯倒影（严格由 this.ripplePhase 驱动，停步流动、暂停冻结）
        const frameA = Math.floor(this.ripplePhase * 2.2) % 3;
        const frameB = (frameA + 1) % 3;
        const driftA = Math.sin(this.ripplePhase * 1.15) * cam.len(8);
        const driftB = Math.cos(this.ripplePhase * 1.45) * cam.len(6);
        const rx = cam.sx(reflCenterX);

        worldArt.tryPlace("fe_vfx_creek_reflect", "fe04_creek_refl_near", rx + driftA, groundY - cam.len(18), cam.len(96), cam.len(24), {
            frame: frameA,
            opacity: 0.88 * lampPulse,
            layer: 3,
        });
        worldArt.tryPlace("fe_vfx_creek_reflect", "fe04_creek_refl_far", rx + cam.len(22) + driftB, groundY - cam.len(34), cam.len(78), cam.len(18), {
            frame: frameB,
            opacity: 0.72 * lampPulse,
            facing: -1,
            layer: 3,
        });

        fillRadialGlow(
            fgGlow,
            rx + cam.len(8),
            groundY - cam.len(22),
            cam.len(62) * lampPulse,
            cam.len(22) * lampPulse,
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

    /** 在角色之上绘制极克制冷月边缘分离、听声细弧与犬警觉声波（去生硬几何三角耳补丁） */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;

        const px = cam.sx(p.player.x);
        const pTopY = cam.sy(p.player.y + p.player.h);

        // 1. 踩枯枝 / 听见动静时的小满微顿侧耳听声视觉反馈（克制听觉细弧，非阻塞）
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

        // 2. 林犬警觉微声弧（保留像素犬本体，不叠贴硬多边形三角耳）
        if (p.room.story !== undefined && p.room.story.dog !== undefined) {
            const alert = p.dogState === "ear" || p.dogState === "chase";
            if (alert) {
                const f = p.dogState === "chase" ? (p.player.x >= p.dogX ? 1 : -1) : p.dogDir;
                const headX = cam.sx(p.dogX + f * 11);
                const headY = cam.sy(29);
                const waveR = cam.len(8 + (this.animTime * 20) % 13);
                fgGlow.drawArc(Vec2(headX, headY), waveR, 42, 138, 1.2, Color(226, 208, 174, 155));
            }
        }

        // 暂停态前景枝叶兜底
        if (ctx.paused) {
            const pX = cam.viewW * (0.98 + this.creekReveal * 0.24);
            worldArt.tryPlace("fe_fg_pine_bough", "fe04_pause_creek_branch", pX, cam.viewH, cam.viewW * 0.56, cam.viewH * 0.48, {
                opacity: 0.90 * (1 - this.creekReveal * 0.65),
                layer: 5300,
            });
        }
    }

    /**
     * 像素前景低草 + 溪湾拨枝松叶 + 冷月电影调色：
     * 固定返回 false。
     */
    drawForegroundOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const inv = 1 / Math.max(0.25, ctx.uiScale);
        const dawn = smoothstep(ox + 1120, ox + 1460, p.player.x);

        // 1. 三处草丛前景低矮像素草丛（高度严格压在 17 单位，保证上方犬耳与小满肩线清晰分离）
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable !== true) {
                continue;
            }
            const sx0 = cam.sx(s.x) * inv;
            const sx1 = cam.sx(s.x + s.w) * inv;
            if (sx1 < -20 || sx0 > ctx.uiW + 20) {
                continue;
            }
            const sy = cam.sy(s.y - 2) * inv;
            uiArt.tryPlace("grass_low", "fe04_fg_grass_" + i, (sx0 + sx1) * 0.5, sy, sx1 - sx0 + 8, Math.max(10, cam.len(17) * inv), {
                color: Color(76, 108, 98, 255),
                opacity: 0.92,
                layer: 2,
            });
        }

        // 2. 溪湾前景像素松枝垂叶（初入自然遮挡远山真北塔，走上溪岸随 creekReveal 0 -> 1 平滑拨开！）
        const nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x);
        if (nearCreek > 0.02) {
            const uiW = ctx.uiW;
            const uiH = ctx.uiH;
            const partShift = this.creekReveal * uiW * 0.40;
            const liftShift = this.creekReveal * uiH * 0.16;
            const sway = Math.sin(this.animTime * 1.45) * 5;
            const canopyOp = nearCreek * (1 - this.creekReveal * 0.28);

            // 右上主松枝垂叶（anchorX=1, anchorY=1）
            uiArt.tryPlace("fe_fg_pine_bough", "fe04_fg_creek_r1", uiW + 18 + partShift + sway * 0.5, uiH + 14 + liftShift, uiW * 0.58, uiH * 0.44, {
                opacity: 0.96 * canopyOp,
                layer: 4,
            });
            uiArt.tryPlace("fe_fg_pine_bough", "fe04_fg_creek_r2", uiW * 0.86 + partShift + sway * 0.8, uiH + 18 + liftShift * 0.8, uiW * 0.44, uiH * 0.36, {
                color: Color(196, 212, 208, 255),
                opacity: 0.88 * canopyOp,
                layer: 3,
            });
            // 左上平衡松枝（镜像，随步行向左微让）
            const lShift = this.creekReveal * uiW * 0.24;
            uiArt.tryPlace("fe_fg_pine_bough", "fe04_fg_creek_l", -14 - lShift - sway * 0.4, uiH + 12 + liftShift * 0.5, uiW * 0.36, uiH * 0.32, {
                facing: -1,
                opacity: 0.90 * canopyOp,
                layer: 4,
            });
        }

        // 3. 冷月像素电影调色（走近溪湾拂晓微暖）
        drawChildColdMoonGrade(uiDraw, uiGlow, ctx.uiW, ctx.uiH, 0.78 * (1 - dawn * 0.24), dawn * 0.55);

        return false;
    }
}
