/**
 * 《向西守望》全场景音乐状态机、环境声景与角色物理拟音导演（SoundscapeDirector）。
 *
 * 职责划分：
 * 1. 全 15 首原创 BGM（assets/audio/bgm/*.ogg）状态机与平滑交叉淡化，
 *    同卷相邻房间（如 s1→s2→s3、c1→c2、escort1→escort2）无缝续播不断档；
 * 2. 全 8 条新增场景长环境循环（assets/audio/ambience/*.ogg）与城门绞盘、暗渠低拱、序章余烬补齐；
 * 3. 角色移动物理拟音（周戍/小满青石步幅、G06 牵手双步幅、密林苔藓/浅水步声、翻滚、跳落、蹲伏、
 *    拾瓶、敌兵举铳预警、本领卡浮现、城门绞盘启止与破棚布坠落、板车推轮）；
 * 4. 空间滤波联控（暗渠/低拱/入柜自动触发风噪低通）；
 * 5. 护送试炼肉鸽模式（mode 2）完整音频驱动。
 */

import { Play } from "Script/watch/play";
import { AudioDirector } from "Script/watch/fe/audio";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { ScreenKind } from "Script/watch/fe/ui/menus";

const BGM_ROOT = "assets/audio/bgm/";
const AMB_ROOT = "assets/audio/ambience/";
const FOL_ROOT = "assets/audio/foley/";
const CMB_ROOT = "assets/audio/combat/";
const UI_ROOT = "assets/audio/ui/";

interface BgmSpec {
    id: string;
    path: string;
    volume: number;
    looping: boolean;
    loopPoint: number;
    fadeIn: number;
}

const BGM_CATALOG: Record<string, BgmSpec> = {
    splash: { id: "splash", path: BGM_ROOT + "splash_brand.ogg", volume: 0.86, looping: false, loopPoint: 0, fadeIn: 0.05 },
    title: { id: "title", path: BGM_ROOT + "title_westward_watch.ogg", volume: 0.80, looping: true, loopPoint: 8.0, fadeIn: 1.4 },
    prologue: { id: "prologue", path: BGM_ROOT + "prologue_ember_night.ogg", volume: 0.72, looping: true, loopPoint: 0, fadeIn: 1.8 },
    street: { id: "street", path: BGM_ROOT + "street_alley_tension.ogg", volume: 0.76, looping: true, loopPoint: 0, fadeIn: 1.5 },
    checkpoint: { id: "checkpoint", path: BGM_ROOT + "checkpoint_granary.ogg", volume: 0.74, looping: true, loopPoint: 0, fadeIn: 1.6 },
    gate_siege: { id: "gate_siege", path: BGM_ROOT + "gate_siege_45s.ogg", volume: 0.84, looping: true, loopPoint: 48.0, fadeIn: 0.8 },
    gate_count: { id: "gate_count", path: BGM_ROOT + "gate_count_drone.ogg", volume: 0.48, looping: true, loopPoint: 0, fadeIn: 1.8 },
    reunion: { id: "reunion", path: BGM_ROOT + "reunion_hand_in_hand.ogg", volume: 0.78, looping: true, loopPoint: 0, fadeIn: 1.6 },
    escort_combat: { id: "escort_combat", path: BGM_ROOT + "escort_combat.ogg", volume: 0.80, looping: true, loopPoint: 4.0, fadeIn: 1.2 },
    escort_bench: { id: "escort_bench", path: BGM_ROOT + "escort_craft_bench.ogg", volume: 0.72, looping: true, loopPoint: 0, fadeIn: 1.8 },
    child_lone: { id: "child_lone", path: BGM_ROOT + "child_lone_journey.ogg", volume: 0.68, looping: true, loopPoint: 0, fadeIn: 2.0 },
    forest_stalk: { id: "forest_stalk", path: BGM_ROOT + "forest_stalk_and_creek.ogg", volume: 0.70, looping: true, loopPoint: 0, fadeIn: 1.8 },
    creek_dawn: { id: "creek_dawn", path: BGM_ROOT + "creek_dawn_reflection.ogg", volume: 0.76, looping: true, loopPoint: 0, fadeIn: 2.2 },
    ending_f03: { id: "ending_f03", path: BGM_ROOT + "ending_f03_lamp.ogg", volume: 0.84, looping: true, loopPoint: 32.0, fadeIn: 0.35 },
    ending_m03: { id: "ending_m03", path: BGM_ROOT + "ending_m03_reunion.ogg", volume: 0.84, looping: true, loopPoint: 32.0, fadeIn: 0.35 },
    museum: { id: "museum", path: BGM_ROOT + "museum_dawn_peace.ogg", volume: 0.80, looping: true, loopPoint: 6.0, fadeIn: 2.0 },
};

const SOLDIER_STONE_STEPS = [
    FOL_ROOT + "step_soldier_stone_1.wav",
    FOL_ROOT + "step_soldier_stone_2.wav",
    FOL_ROOT + "step_soldier_stone_3.wav",
];
const CHILD_STONE_STEPS = [
    FOL_ROOT + "step_child_stone_1.wav",
    FOL_ROOT + "step_child_stone_2.wav",
    FOL_ROOT + "step_child_stone_3.wav",
];
const CHILD_MOSS_STEPS = [
    FOL_ROOT + "step_child_moss_1.wav",
    FOL_ROOT + "step_child_moss_2.wav",
];
const CHILD_WATER_STEPS = [
    FOL_ROOT + "step_child_water_1.wav",
    FOL_ROOT + "step_child_water_2.wav",
];

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

export class SoundscapeDirector {
    private boundRoomKey = "";
    private stepAccum = 0;
    private partnerStepAccum = 0;
    private stepIdx = 0;
    private partnerStepIdx = 0;
    private prevOnGround = true;
    private prevVy = 0;
    private prevRollT = 0;
    private prevCrouch = false;
    private prevHasBottle = false;
    private prevCartAxle = 0;
    private prevPhase = "";
    private prevWeapon = "";
    private prevOfferCount = 0;
    private enemyWarnPrev: Record<number, boolean> = {};
    private gateTarpPlayed = false;
    private lastSplashActive = false;

    resetForRoom(p: Play): void {
        this.boundRoomKey = p.room.key;
        this.stepAccum = 0;
        this.partnerStepAccum = 0;
        this.prevOnGround = p.player.onGround;
        this.prevVy = p.player.vy;
        this.prevRollT = p.player.rollT;
        this.prevCrouch = p.player.crouch;
        this.prevHasBottle = p.hasBottle;
        this.prevCartAxle = p.cartAxle;
        this.prevPhase = p.phase;
        this.prevWeapon = p.equippedWeapon;
        this.prevOfferCount = p.getStoryTalentOffers().length;
        this.enemyWarnPrev = {};
        this.gateTarpPlayed = false;
    }

    /** 菜单态（开机序幕 / 标题 / 选章 / 要诀）声景与音乐控制 */
    updateMenu(screen: ScreenKind, audio: AudioDirector): void {
        if (screen === "splash") {
            const spec = BGM_CATALOG.splash;
            audio.stopMenuAmbience(0.2);
            audio.playBgm(spec.id, spec.path, {
                volume: spec.volume,
                looping: false,
                loopPoint: 0,
                fadeIn: spec.fadeIn,
                restart: !this.lastSplashActive,
            });
            this.lastSplashActive = true;
            return;
        }
        this.lastSplashActive = false;
        const titleSpec = BGM_CATALOG.title;
        audio.setBgmManualDuck(1.0);
        audio.playBgm(titleSpec.id, titleSpec.path, {
            volume: titleSpec.volume,
            looping: titleSpec.looping,
            loopPoint: titleSpec.loopPoint,
            fadeIn: titleSpec.fadeIn,
        });
        audio.setMenuAmbience(AMB_ROOT + "title_coastal_night_loop.ogg", 0.34);
    }

    /** 正式局内每帧驱动（BGM 状态机 + 房间环境声 + 物理拟音 + 空间滤波） */
    updatePlay(dt: number, p: Play, view: DualRouteSnapshot, audio: AudioDirector): void {
        audio.stopMenuAmbience(0.4);
        this.lastSplashActive = false;

        if (this.boundRoomKey !== p.room.key) {
            this.resetForRoom(p);
        }

        if (p.paused) {
            return;
        }

        // 1. 选定并平滑切曲 BGM
        this.syncPlayBgm(p, view, audio);

        // 2. 房间环境循环（补齐 13 个原无底噪房间与暗渠/绞盘）
        this.syncPlayAmbience(dt, p, view, audio);

        // 3. 空间低通滤波（暗渠 / 矮拱 / 序章入柜）
        const inArch = p.room.arch.h > 0
            && p.player.x >= p.room.arch.x0 - 8
            && p.player.x <= p.room.arch.x1 + 8
            && p.player.y <= p.room.arch.y + p.room.arch.h;
        const inCabinet = p.room.key === "prologue" && (p.phase === "prologue-wait" || p.phase === "prologue-hide");
        const inDitch = p.room.key === "village" && p.player.crouch && p.player.x >= p.ox + 540;
        audio.setSpaceMuffled(inArch || inCabinet || inDitch);

        // 4. 物理拟音（脚步、牵手双步幅、翻滚、跳落、蹲伏、拾瓶、敌兵举铳预警、本领卡浮现）
        this.syncFoley(dt, p, view, audio);
    }

    private syncPlayBgm(p: Play, view: DualRouteSnapshot, audio: AudioDirector): void {
        const key = p.room.key;
        const phase = p.phase;
        let desired: BgmSpec | undefined;
        let manualDuck = 1.0;

        if (view.visualMode === "museum" || key === "museum") {
            const mp = view.archive.museumPhase;
            if (mp === "well_reflect" || mp === "return_cabinet") {
                desired = undefined;
            } else {
                desired = BGM_CATALOG.museum;
            }
        } else if (key === "prologue") {
            if (phase === "prologue-wake" || phase === "prologue-shadow" || phase === "prologue-escape" || phase === "prologue-hide") {
                desired = undefined;
            } else {
                desired = BGM_CATALOG.prologue;
            }
        } else if (key === "street" || key === "s1-crossroad" || key === "s2-drygoods" || key === "s3-archway") {
            desired = BGM_CATALOG.street;
        } else if (key === "checkpoint" || key === "c1-yard" || key === "c2-granary") {
            desired = BGM_CATALOG.checkpoint;
        } else if (key === "gate") {
            if (phase === "gate-hold") {
                desired = BGM_CATALOG.gate_siege;
            } else if (phase === "gate-idle") {
                desired = BGM_CATALOG.checkpoint;
                manualDuck = 0.65;
            } else if (phase === "gate-send") {
                desired = undefined;
            } else if (phase === "gate-count") {
                desired = BGM_CATALOG.gate_count;
                if (view.countNumber >= 18) {
                    manualDuck = 0.0;
                } else if (view.countNumber >= 15) {
                    manualDuck = 0.35;
                }
            } else if (phase === "gate-hand" || (view.storyRoute === "soldier" && view.gateReunion.completed)) {
                desired = BGM_CATALOG.reunion;
            } else if (phase === "gate-walk") {
                desired = view.storyRoute === "soldier" ? BGM_CATALOG.reunion : BGM_CATALOG.child_lone;
            } else {
                desired = BGM_CATALOG.gate_count;
                manualDuck = 0.35;
            }
        } else if (key === "gatepath") {
            desired = BGM_CATALOG.reunion;
        } else if (key === "escort3") {
            desired = BGM_CATALOG.escort_bench;
        } else if (key === "escort1" || key === "escort2" || key === "escort4" || key === "escort5") {
            desired = BGM_CATALOG.escort_combat;
        } else if (key === "outside" || key === "village") {
            desired = BGM_CATALOG.child_lone;
        } else if (key === "forest") {
            desired = (p.player.x >= p.ox + 1140) ? BGM_CATALOG.creek_dawn : BGM_CATALOG.forest_stalk;
        } else if (key === "tower") {
            const endingActive = phase === "tower-knock" || phase === "tower-given" || phase === "tower-end";
            if (endingActive) {
                desired = view.storyRoute === "soldier" ? BGM_CATALOG.ending_m03 : BGM_CATALOG.ending_f03;
            } else {
                desired = BGM_CATALOG.creek_dawn;
                manualDuck = 0.72;
            }
        }

        audio.setBgmManualDuck(manualDuck);
        if (desired === undefined) {
            if (audio.getCurrentBgmId() !== "") {
                audio.stopBgm(1.2);
            }
            return;
        }
        const forceRestart = desired.id === "ending_f03" || desired.id === "ending_m03"
            ? (this.prevPhase !== "tower-knock" && this.prevPhase !== "tower-given" && this.prevPhase !== "tower-end")
            : (desired.id === "gate_siege" && this.prevPhase !== "gate-hold");

        audio.playBgm(desired.id, desired.path, {
            volume: desired.volume,
            looping: desired.looping,
            loopPoint: desired.loopPoint,
            fadeIn: desired.fadeIn,
            restart: forceRestart,
        });
    }

    private syncPlayAmbience(dt: number, p: Play, view: DualRouteSnapshot, audio: AudioDirector): void {
        const key = p.room.key;
        const phase = p.phase;

        // 1. 主场景底噪（仅补齐原插件未覆盖的房间，避免与 fe-01 / fe-04 / fe-05 / fe-06 既有循环重叠）
        if (key === "prologue" && phase !== "prologue-wake" && view.visualMode !== "museum") {
            audio.setSceneAmbience("scene_main_amb", "ambience", "assets/audio/prologue/night_distant_fire.wav", 0.24);
        } else if (key === "street" || key === "s1-crossroad" || key === "s2-drygoods" || key === "s3-archway") {
            audio.setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT + "street_fire_ember_loop.ogg", 0.34);
        } else if (key === "checkpoint" || key === "c1-yard" || key === "c2-granary") {
            audio.setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT + "checkpoint_wind_chains_loop.ogg", 0.36);
        } else if (key === "gate" && (phase === "gate-idle" || phase === "gate-hold" || phase === "gate-send")) {
            audio.setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT + "gate_siege_ambience_loop.ogg", phase === "gate-hold" ? 0.42 : 0.28);
        } else if (key === "gatepath" || key === "escort1" || key === "escort2" || key === "escort4" || key === "escort5") {
            audio.setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT + "escort_mountain_night_loop.ogg", 0.34);
        } else if (key === "escort3") {
            audio.setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT + "escort_bench_lantern_loop.ogg", 0.38);
        } else {
            audio.stopSceneAmbience("scene_main_amb", 0.3);
        }

        // 2. 城门 45 秒守点绞盘铁链拉升音 + 启止落锁 + 第 12s 破棚布坠落
        if (key === "gate" && phase === "gate-hold") {
            if (this.prevPhase !== "gate-hold") {
                audio.playFoley("gate:winch_start", CMB_ROOT + "gate_winch_start.wav", 0.80, -0.25, 250);
                this.gateTarpPlayed = false;
            }
            const progress = clamp01(p.gateTick / 2700);
            audio.setSceneAmbience("scene_winch_chain", "ambience", AMB_ROOT + "gate_winch_chain_loop.ogg", 0.26 + progress * 0.16);
            if (!this.gateTarpPlayed && p.gateTick >= 720) {
                this.gateTarpPlayed = true;
                audio.playFoley("gate:tarp_fall", CMB_ROOT + "gate_tarp_fall.wav", 0.72, 0.18, 500);
            }
        } else {
            if (key === "gate" && this.prevPhase === "gate-hold" && phase === "gate-send") {
                audio.playFoley("gate:winch_lock", CMB_ROOT + "gate_winch_lock.wav", 0.88, -0.1, 250);
            }
            audio.stopSceneAmbience("scene_winch_chain", 0.25);
        }

        // 3. 涵洞 / 水门低拱 / 暗渠潮湿滴水共鸣
        const nearCulvert = (p.room.arch.h > 0 && p.player.x >= p.room.arch.x0 - 40 && p.player.x <= p.room.arch.x1 + 40)
            || (key === "village" && p.player.x >= p.ox + 520)
            || (key === "forest" && p.player.x >= p.ox + 830 && p.player.x <= p.ox + 1230);
        if (nearCulvert && view.visualMode !== "museum") {
            audio.setSceneAmbience("scene_culvert_drip", "water", AMB_ROOT + "culvert_drip_echo_loop.ogg", 0.30);
        } else {
            audio.stopSceneAmbience("scene_culvert_drip", 0.35);
        }

        // 4. 非 outside 房间（checkpoint / c2-granary）板车推轮声
        if (key !== "outside" && p.room.cart.bodyW > 0 && dt > 0.0001) {
            const speed = Math.abs(p.cartAxle - this.prevCartAxle) / dt;
            if (speed > 4) {
                const vol = Math.min(0.46, 0.18 + (speed / 64) * 0.28);
                audio.setSceneAmbience("scene_cart_wheel", "ambience", "assets/audio/child/cart_wheel_loop.wav", vol);
            } else {
                audio.stopSceneAmbience("scene_cart_wheel", 0.12);
            }
        } else {
            audio.stopSceneAmbience("scene_cart_wheel", 0.12);
        }
        this.prevCartAxle = p.cartAxle;
    }

    private syncFoley(dt: number, p: Play, view: DualRouteSnapshot, audio: AudioDirector): void {
        const key = p.room.key;
        const inCutscene = view.visualMode === "museum"
            || (key === "prologue" && (p.phase === "prologue-wake" || p.phase === "prologue-shadow" || p.phase === "prologue-give"))
            || (key === "gate" && (p.phase === "gate-count" || p.phase === "gate-wait" || p.phase === "gate-hand"))
            || (key === "tower" && (p.phase === "tower-knock" || p.phase === "tower-given" || p.phase === "tower-end"));

        // 本领卡浮现音效
        const offerCount = p.getStoryTalentOffers().length;
        if (offerCount > 0 && this.prevOfferCount === 0) {
            audio.playUi("ui:talent_appear", UI_ROOT + "talent_appear.wav", 0.72, 0.2);
        }
        this.prevOfferCount = offerCount;

        // 快捷切换时间穿梭器（T / L3）非工台换装音
        if (!p.craftBench.active && this.prevWeapon !== "" && p.equippedWeapon !== this.prevWeapon) {
            audio.playFoley("weapon:switch", CMB_ROOT + "weapon_switch_artifact.wav", 0.78, 0, 140);
        }
        this.prevWeapon = p.equippedWeapon;

        // 空村拾瓶音效
        if (key === "village" && p.hasBottle && !this.prevHasBottle) {
            audio.playFoley("village:bottle_pickup", FOL_ROOT + "bottle_pickup.wav", 0.76, audio.panForWorldX(p.player.x), 180);
        }
        this.prevHasBottle = p.hasBottle;

        this.syncLocomotionAndCombatFoley(dt, p, audio, inCutscene);
        this.prevPhase = p.phase;
    }

    private syncLocomotionAndCombatFoley(dt: number, p: Play, audio: AudioDirector, suppressLocomotion: boolean): void {
        const a = p.player;
        const pan = audio.panForWorldX(a.x);

        if (!suppressLocomotion && dt > 0) {
            // 1. 翻滚 / 滑铲
            if (a.rollT > 0 && this.prevRollT <= 0) {
                audio.playFoley("foley:roll", FOL_ROOT + "soldier_roll.wav", 0.74, pan, 220);
            }

            // 2. 起跳 / 落地
            if (!a.onGround && this.prevOnGround && a.vy > 80) {
                const jPath = p.childMode ? (FOL_ROOT + "jump_child.wav") : (FOL_ROOT + "jump_soldier.wav");
                audio.playFoley("foley:jump", jPath, 0.56, pan, 160);
            } else if (a.onGround && !this.prevOnGround && this.prevVy < -60) {
                const lPath = p.childMode ? (FOL_ROOT + "land_child.wav") : (FOL_ROOT + "land_soldier.wav");
                const impactVol = clamp01(0.36 + Math.min(1, Math.abs(this.prevVy) / 420) * 0.42);
                audio.playFoley("foley:land", lPath, impactVol, pan, 120);
            }

            // 3. 蹲伏衣料轻响
            if (a.crouch && !this.prevCrouch && a.onGround) {
                audio.playFoley("foley:crouch", FOL_ROOT + "crouch_rustle.wav", 0.34, pan, 180);
            }

            // 4. 地面移动脚步（按材质区分：青石 / 森林厚苔 / 暗渠溪水；男主线 gatepath 双步幅！）
            const speedX = Math.abs(a.vx);
            if (a.onGround && a.rollT <= 0 && speedX > 12) {
                this.stepAccum += speedX * dt;
                const stride = p.childMode ? (a.crouch ? 26 : 34) : 48;
                if (this.stepAccum >= stride) {
                    this.stepAccum -= stride;
                    this.stepIdx += 1;
                    const stepInfo = this.pickPlayerFootstep(p, this.stepIdx);
                    audio.playFoley("foley:step", stepInfo.path, stepInfo.vol, pan, 140);
                }
            } else if (speedX <= 4) {
                this.stepAccum = Math.min(this.stepAccum, 16);
            }

            // 5. G06 牵手同行段（gatepath）小满同步轻步幅（「只听两种步幅」）
            if (p.room.key === "gatepath" && !p.childMode && p.partner.alive && Math.abs(p.partner.vx) > 8) {
                this.partnerStepAccum += Math.abs(p.partner.vx) * dt;
                if (this.partnerStepAccum >= 32) {
                    this.partnerStepAccum -= 32;
                    this.partnerStepIdx += 1;
                    const cPath = CHILD_STONE_STEPS[this.partnerStepIdx % CHILD_STONE_STEPS.length];
                    audio.playFoley("foley:partner_step", cPath, 0.44, audio.panForWorldX(p.partner.x), 140);
                }
            }
        }

        // 6. 敌兵举铳预警（warnT 由 0 跃升正值瞬间）
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const en = p.enemies[i];
            const warnNow = en.alive && en.warnT > 0;
            const warnWas = this.enemyWarnPrev[i] === true;
            if (warnNow && !warnWas) {
                audio.playFoley("combat:enemy_warn:" + i, CMB_ROOT + "enemy_warn.wav", 0.68, audio.panForWorldX(en.x), 300);
            }
            this.enemyWarnPrev[i] = warnNow;
        }

        this.prevOnGround = a.onGround;
        this.prevVy = a.vy;
        this.prevRollT = a.rollT;
        this.prevCrouch = a.crouch;
    }

    private pickPlayerFootstep(p: Play, idx: number): { path: string; vol: number } {
        if (!p.childMode) {
            return {
                path: SOLDIER_STONE_STEPS[idx % SOLDIER_STONE_STEPS.length],
                vol: p.player.crouch ? 0.34 : 0.54,
            };
        }
        const key = p.room.key;
        const slowFactor = p.player.crouch ? 0.52 : (Math.abs(p.player.vx) <= 95 ? 0.68 : 1.0);
        if (key === "forest") {
            if (p.player.x >= p.ox + 1310) {
                return { path: CHILD_WATER_STEPS[idx % CHILD_WATER_STEPS.length], vol: 0.46 * slowFactor };
            }
            return { path: CHILD_MOSS_STEPS[idx % CHILD_MOSS_STEPS.length], vol: 0.36 * slowFactor };
        }
        if (key === "village" && p.player.x >= p.ox + 540) {
            return { path: CHILD_WATER_STEPS[idx % CHILD_WATER_STEPS.length], vol: 0.42 * slowFactor };
        }
        return {
            path: CHILD_STONE_STEPS[idx % CHILD_STONE_STEPS.length],
            vol: 0.48 * slowFactor,
        };
    }
}
