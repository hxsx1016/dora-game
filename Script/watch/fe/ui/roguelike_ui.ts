/**
 * 《向西守望》肉鸽前端统一渲染插件：《行军筹签记》（fe-roguelike-ui）。
 *
 * 五大模块一体化落地：
 * - 模块 A：双态呼吸式「三筹木简」选卡系统（展卷态附 0.25x 表现层轻慢时聚焦，不阻塞 Play.update；
 *           移动/交火/开盘/开工台自动柔顺收束为顶部迷你筹签；触屏单击直接落印；朱砂落印「契印」+
 *           二阶贝塞尔墨芒归身动效）；
 * - 模块 B：战备与构筑常驻 HUD（左上本领微章带带实时触发脉冲 + 修复 escort1..5 随身战备盲区的
 *           统一战备行囊条 + 顶部纤细北行舆图里程丝线）；
 * - 模块 C：「行军札记」按需宣纸对折构筑总览页（点击本领带 / 按 V / 暂停菜单呼出，含 3×3 武器纹样
 *           预览、实时生效账目与动态派生「行军雅号」朱砂孤印）；
 * - 模块 D：2.5D 世界层肉鸽具象化（护身松烟青玉余势弧、火绳装填弧、巧手削楔木屑环、木楔加固掩体
 *           与焦墨裂纹、背负小满选筹微杏涟漪）；
 * - 模块 E：肉鸽轮回情绪闭环（「壹程告破」非阻塞行书流带 + 「折筹重整 · 残筹散墨」战死重置复盘幕）。
 */

import { Color, DrawNode, Keyboard, KeyName, Mouse, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { mmss } from "Script/watch/run";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { InputMode } from "Script/watch/controls_config";
import { SafeInsets, ZERO_SAFE_INSETS } from "Script/watch/platform";
import { AssetSlotHost } from "Script/watch/fe/assets";
import {
    DualRouteContract,
    DualRouteSnapshot,
    RoguelikeSnapshot,
    RoguelikeStageNode,
} from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { keyTagFor } from "Script/watch/fe/ui/control_prompts";
import { RELOAD_GRID, drawReloadPatternGlyph } from "Script/watch/fe/ui/reload_wheel";
import {
    PICKUP_ORDER,
    TalentAbsorbTarget,
    deriveMarchTitle,
    drawBrushArc,
    drawPickupGlyph,
    drawTalentGlyph,
    pickupMetaOf,
    rankChinese,
    resolveTalentVisual,
    weaponMetaOf,
} from "Script/watch/fe/ui/talent_catalog";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawDiamond,
    drawFiligreeCorners,
    drawHairline,
    drawLoneSeal,
    drawMistCurve,
    drawSilkKeycap,
    drawSilkRibbon,
    drawSilkVeil,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    themeOf,
    toChineseUpper,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export type TalentDrawerState = "hidden" | "expanded" | "compact" | "sealing" | "absorbing";

export interface RoguelikeUiDebugState {
    drawerState: TalentDrawerState;
    offers: string[];
    focusedSlot: number;
    focusTimeScale: number;
    ledgerOpen: boolean;
    sealingActive: boolean;
    absorbingActive: boolean;
    segmentBannerActive: boolean;
    deathRecapActive: boolean;
    deathRecapRoom: string;
    deathRecapCount: number;
    marchTitle: string;
    suppliesShown: string[];
    activeGuardArc: boolean;
    activeReloadArc: boolean;
    activeCraftRing: boolean;
    lastCardBoxes: Rect.Type[];
    ledgerButtonBox: Rect.Type;
    expandToggleBox: Rect.Type;
}

interface SealAnimState {
    talentId: string;
    pickedSlot: number;
    pickedBox: Rect.Type;
    allBoxes: Rect.Type[];
    allOffers: string[];
    elapsed: number;
    sealDuration: number;
    absorbDuration: number;
    targetKind: TalentAbsorbTarget;
    fromExpanded: boolean;
    arrivedPulsed: boolean;
}

interface DeathRecapSnapshot {
    roomKey: string;
    stageName: string;
    ranks: Record<string, number>;
    totalRanks: number;
    weaponId: string;
    seed: number;
}

interface FloatingPickupPop {
    kind: string;
    timer: number;
    maxTimer: number;
}

const SEAL_DURATION = 0.24;
const ABSORB_DURATION = 0.32;
const SEGMENT_BANNER_DURATION = 1.45;
const DEATH_RECAP_DURATION = 1.85;
const AUTO_REEXPAND_IDLE_SEC = 1.25;
const EXPANDED_FOCUS_SCALE = 0.25;
const TWO_PI = Math.PI * 2;

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

function easeOutCubic(t: number): number {
    const u = 1 - clamp(t, 0, 1);
    return 1 - u * u * u;
}

function easeInOutQuad(t: number): number {
    const x = clamp(t, 0, 1);
    return x < 0.5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) * 0.5;
}

/**
 * 计算三选一筹签卡的 UI 坐标矩形（展卷态与收束态单一布局真源，
 * 同时服务于渲染、鼠标点击、触屏直点热区与 verify-story-roguelike.lua 回归校验）。
 */
export function computeRoguelikeCardRects(
    uiW: number,
    uiH: number,
    count: number,
    expanded: boolean,
    touchMode: boolean = false,
    safeTop: number = 0,
): Rect.Type[] {
    const out: Rect.Type[] = [];
    if (count <= 0) {
        return out;
    }
    if (expanded) {
        const cardW = touchMode ? 220 : 210;
        const cardH = touchMode ? 248 : 244;
        const gap = Math.min(18, Math.max(10, (uiW - 80 - count * cardW) / Math.max(1, count - 1)));
        const actualW = Math.min(cardW, (uiW - 64 - gap * (count - 1)) / count);
        const totalW = count * actualW + (count - 1) * gap;
        const startX = (uiW - totalW) * 0.5;
        // 顶部留出北行舆图丝线与题带，底部留出完整 2.5D 舞台可见周戍与小满
        const y = Math.max(138, uiH - 122 - safeTop - cardH);
        let i = 0;
        for (i = 0; i < count; i++) {
            out.push(Rect(startX + i * (actualW + gap), y, actualW, cardH));
        }
        return out;
    }
    const cardW = touchMode ? 202 : 188;
    const cardH = touchMode ? 48 : 40;
    const gap = 12;
    const totalW = count * cardW + (count - 1) * gap;
    const startX = (uiW - totalW) * 0.5;
    const y = uiH - (touchMode ? 116 : 106) - safeTop;
    let i = 0;
    for (i = 0; i < count; i++) {
        out.push(Rect(startX + i * (cardW + gap), y, cardW, cardH));
    }
    return out;
}

function stageOrderNumeral(roomKey: string): string {
    if (roomKey === "escort1" || roomKey === "s1-crossroad") return "壹";
    if (roomKey === "escort2" || roomKey === "s2-drygoods") return "贰";
    if (roomKey === "escort3" || roomKey === "s3-archway") return "叁";
    if (roomKey === "escort4" || roomKey === "c1-yard") return "肆";
    if (roomKey === "escort5" || roomKey === "c2-granary") return "伍";
    return "壹";
}

function stageReadableName(roomKey: string): string {
    if (roomKey === "escort1") return "城外巷路 · 第一段";
    if (roomKey === "escort2") return "粮棚取材 · 第二段";
    if (roomKey === "escort3") return "山腰工台 · 第三段";
    if (roomKey === "escort4") return "夜山窄道 · 第四段";
    if (roomKey === "escort5") return "塔前山道 · 第五段";
    return themeOf(roomKey).titleZh;
}

export class RoguelikeUiPlugin implements FeRenderPlugin {
    readonly id = "fe-roguelike-ui";

    private contract: DualRouteContract | undefined;
    private getHudSelected: (() => number) | undefined;
    private setHudSelected: ((idx: number) => void) | undefined;

    // 选筹双态与动画状态
    private drawerState: TalentDrawerState = "hidden";
    private manualCompact = false;
    private expandAnimT = 0;
    private staggerTime = 0;
    private idleSinceMove = 0;
    private hoverSlot = -1;
    private focusedSlot = 0;
    private cardLiftT: number[] = [0, 0, 0];
    private focusScale = 1;
    private animTime = 0;

    // 缓存上一帧候选与布局（用于落印演出与热区一致）
    private lastOffers: string[] = [];
    private lastRanks: Record<string, number> = {};
    private lastCardBoxes: Rect.Type[] = [];
    private lastUiW = 1280;
    private lastUiH = 720;
    private lastTouchMode = false;
    private lastSafeTop = 0;
    private expandToggleBox: Rect.Type = Rect(0, 0, 0, 0);
    private ledgerButtonBox: Rect.Type = Rect(0, 0, 0, 0);
    private ledgerCloseBox: Rect.Type = Rect(0, 0, 0, 0);
    private ledgerPanelBox: Rect.Type = Rect(0, 0, 0, 0);

    // 落印与流墨归身
    private sealAnim: SealAnimState | undefined;
    private crestPulseMap: Record<string, number> = {};
    private hpBarPulseT = 0;
    private xiaomanRippleT = 0;

    // 行军札记按需抽屉
    private ledgerOpen = false;
    private ledgerAnimT = 0;
    private prevKeyV = false;
    private prevKeyEsc = false;
    private prevKeyBack = false;
    private prevLeftDown = false;

    // 随身战备拾取/满包动态反馈
    private pickupBounceMap: Record<string, number> = {};
    private pickupShakeMap: Record<string, number> = {};
    private pickupPops: FloatingPickupPop[] = [];
    private lastSuppliesShown: string[] = [];

    // 跨 bindPlay 存活的肉鸽轮回情绪演出
    private segmentBannerT = 0;
    private segmentBannerHeadline = "";
    private segmentBannerSub = "";
    private deathRecapT = 0;
    private deathRecapSnap: DeathRecapSnapshot | undefined;

    // 存活态构筑快照（确保 restartEscortFromDeath 清空前已留痕）
    private lastAliveRoomKey = "";
    private lastAliveRanks: Record<string, number> = {};
    private lastAliveTotalRanks = 0;
    private lastAliveWeapon = "standard_gun";
    private lastAliveSeed = 0;

    // 调试读数缓存
    private lastMarchTitle = "初启北行";
    private lastGuardArcActive = false;
    private lastReloadArcActive = false;
    private lastCraftRingActive = false;

    constructor(
        contract?: DualRouteContract,
        getHudSelected?: () => number,
        setHudSelected?: (idx: number) => void,
    ) {
        this.contract = contract;
        this.getHudSelected = getHudSelected;
        this.setHudSelected = setHudSelected;
    }

    isExpanded(): boolean {
        return this.drawerState === "expanded";
    }

    isLedgerOpen(): boolean {
        return this.ledgerOpen;
    }

    /** 是否处于宣纸札记或折筹重整全屏柔幕态（此时压隐底层 HUD 与入房章名，防 TextPool 透穿） */
    isModalOverlayActive(): boolean {
        return this.ledgerOpen || this.deathRecapT > 0.05;
    }

    /** 是否应暂避入房章名大字（展卷木简 / 落印 / 过段流带 / 札记 / 折筹重整期间零叠字） */
    isSuppressingRoomBanner(): boolean {
        return this.ledgerOpen
            || this.deathRecapT > 0.05
            || this.drawerState === "expanded"
            || this.drawerState === "sealing"
            || this.segmentBannerT > 0.05;
    }

    openLedger(): void {
        this.ledgerOpen = true;
        this.ledgerAnimT = 0;
    }

    closeLedger(): void {
        this.ledgerOpen = false;
    }

    toggleLedger(): void {
        if (this.ledgerOpen) {
            this.closeLedger();
        } else {
            this.openLedger();
        }
    }

    setCompact(compact: boolean): void {
        this.manualCompact = compact;
        if (this.lastOffers.length > 0 && this.sealAnim === undefined) {
            this.drawerState = compact ? "compact" : "expanded";
            if (!compact) {
                this.expandAnimT = 0;
                this.staggerTime = 0;
            }
        }
    }

    /** 供自动化验证脚本触发「折筹重整」演出 */
    triggerTestDeathRecap(roomKey: string, ranks: Record<string, number>, weapon: string = "standard_gun"): void {
        let total = 0;
        const copy: Record<string, number> = {};
        for (const k in ranks) {
            if (ranks[k] > 0) {
                copy[k] = ranks[k];
                total += ranks[k];
            }
        }
        this.deathRecapSnap = {
            roomKey,
            stageName: stageReadableName(roomKey),
            ranks: copy,
            totalRanks: total,
            weaponId: weapon,
            seed: this.lastAliveSeed,
        };
        this.deathRecapT = DEATH_RECAP_DURATION;
    }

    /** 供自动化验证脚本触发「险段告破」流带 */
    triggerTestSegmentBanner(roomKey: string, nextKey: string = ""): void {
        this.segmentBannerHeadline = stageOrderNumeral(roomKey) + "程告破";
        this.segmentBannerSub = nextKey !== "" ? ("渐近北塔 · 前往" + themeOf(nextKey).shortNameZh) : "渐近北塔 · 筹策犹在";
        this.segmentBannerT = SEGMENT_BANNER_DURATION;
    }

    /** 返回当前状态下三选一木简卡的 UI 坐标矩形（与 hud.talentCardRects / TouchControls 100% 同步）。 */
    getTalentCardRects(
        uiW: number,
        uiH: number,
        count: number,
        touchMode: boolean = false,
        safeTop: number = 0,
    ): Rect.Type[] {
        const useExpanded = this.drawerState !== "compact";
        return computeRoguelikeCardRects(uiW, uiH, count, useExpanded, touchMode, safeTop);
    }

    getLedgerButtonRect(): Rect.Type {
        return this.ledgerButtonBox;
    }

    getExpandToggleRect(): Rect.Type {
        return this.expandToggleBox;
    }

    getState(): RoguelikeUiDebugState {
        return {
            drawerState: this.drawerState,
            offers: this.lastOffers.slice(),
            focusedSlot: this.focusedSlot,
            focusTimeScale: this.focusScale,
            ledgerOpen: this.ledgerOpen,
            sealingActive: this.drawerState === "sealing",
            absorbingActive: this.drawerState === "absorbing",
            segmentBannerActive: this.segmentBannerT > 0.01,
            deathRecapActive: this.deathRecapT > 0.01,
            deathRecapRoom: this.deathRecapSnap !== undefined ? this.deathRecapSnap.roomKey : "",
            deathRecapCount: this.deathRecapSnap !== undefined ? this.deathRecapSnap.totalRanks : 0,
            marchTitle: this.lastMarchTitle,
            suppliesShown: this.lastSuppliesShown.slice(),
            activeGuardArc: this.lastGuardArcActive,
            activeReloadArc: this.lastReloadArcActive,
            activeCraftRing: this.lastCraftRingActive,
            lastCardBoxes: this.lastCardBoxes.slice(),
            ledgerButtonBox: this.ledgerButtonBox,
            expandToggleBox: this.expandToggleBox,
        };
    }

    onBindPlay(_p: Play, view: DualRouteSnapshot): void {
        const rg = view.roguelike;
        this.manualCompact = false;
        this.expandAnimT = 0;
        this.staggerTime = 0;
        this.idleSinceMove = 0;
        this.hoverSlot = -1;
        this.focusedSlot = 0;
        this.cardLiftT = [0, 0, 0];
        this.sealAnim = undefined;
        this.ledgerOpen = false;
        this.ledgerAnimT = 0;
        this.pickupBounceMap = {};
        this.pickupShakeMap = {};
        this.pickupPops = [];
        this.crestPulseMap = {};
        this.hpBarPulseT = 0;
        this.xiaomanRippleT = 0;
        this.lastOffers = rg.offers.slice();
        this.lastRanks = {};
        for (const k in rg.ranks) {
            this.lastRanks[k] = rg.ranks[k];
        }
        if (rg.active) {
            this.lastAliveRoomKey = rg.roomKey;
            this.lastAliveRanks = {};
            for (const k in rg.ranks) {
                if (rg.ranks[k] > 0) {
                    this.lastAliveRanks[k] = rg.ranks[k];
                }
            }
            this.lastAliveTotalRanks = rg.totalRanks;
            this.lastAliveWeapon = rg.equippedWeapon;
            this.lastAliveSeed = rg.seed;
        }
        this.drawerState = rg.offers.length > 0 ? "expanded" : "hidden";
        this.focusScale = 1;
        if (this.contract !== undefined) {
            this.contract.setFocusTimeScale(1);
        }
        this.resetInputEdges();
        // 注意：segmentBannerT 与 deathRecapT 刻意跨 bindPlay 保留，承载切房/战死重置的情绪转场！
    }

    private resetInputEdges(): void {
        if (typeof Keyboard !== "undefined") {
            this.prevKeyV = Keyboard.isKeyPressed(KeyName.V);
            this.prevKeyEsc = Keyboard.isKeyPressed(KeyName.Escape);
            this.prevKeyBack = Keyboard.isKeyPressed(KeyName.BackSpace);
        }
        this.prevLeftDown = typeof Mouse !== "undefined" ? Mouse.leftButtonPressed : false;
    }

    private startSealAnimation(talentId: string, ctx: FePluginContext): void {
        let pickedSlot = this.lastOffers.indexOf(talentId);
        if (pickedSlot < 0) {
            pickedSlot = clamp(this.focusedSlot, 0, Math.max(0, this.lastOffers.length - 1));
        }
        const boxes = this.lastCardBoxes.length > 0
            ? this.lastCardBoxes.slice()
            : computeRoguelikeCardRects(
                ctx.uiW,
                ctx.uiH,
                Math.max(1, this.lastOffers.length),
                this.drawerState !== "compact",
                ctx.input.isTouchMode(),
                (ctx.safeUi ?? ZERO_SAFE_INSETS).top,
            );
        const pickedBox = boxes[pickedSlot] ?? Rect(ctx.uiW * 0.5 - 100, ctx.uiH * 0.5 - 60, 200, 120);
        const meta = resolveTalentVisual(talentId, ctx.view.roguelike);
        this.sealAnim = {
            talentId,
            pickedSlot,
            pickedBox,
            allBoxes: boxes,
            allOffers: this.lastOffers.slice(),
            elapsed: 0,
            sealDuration: SEAL_DURATION,
            absorbDuration: ABSORB_DURATION,
            targetKind: meta.absorbTarget,
            fromExpanded: this.drawerState !== "compact",
            arrivedPulsed: false,
        };
        this.drawerState = "sealing";
        this.hoverSlot = -1;
        ctx.input.getTouch()?.vibrate(0.024);
        if (ctx.view.backCarry.active) {
            this.xiaomanRippleT = 0.78;
        }
    }

    private detectPickedTalentFromRankDiff(nowRanks: Record<string, number>): string {
        for (const k in nowRanks) {
            if ((nowRanks[k] ?? 0) > (this.lastRanks[k] ?? 0)) {
                return k;
            }
        }
        return this.lastOffers[clamp(this.focusedSlot, 0, Math.max(0, this.lastOffers.length - 1))] ?? "";
    }

    update(ctx: FePluginContext): void {
        const rg = ctx.view.roguelike;
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const touchMode = ctx.input.isTouchMode();
        this.lastUiW = ctx.uiW;
        this.lastUiH = ctx.uiH;
        this.lastTouchMode = touchMode;
        this.lastSafeTop = safe.top;
        this.lastMarchTitle = deriveMarchTitle(rg).title;

        // 暂停态严格冻结全部演出计时与边沿
        if (ctx.paused) {
            this.resetInputEdges();
            return;
        }

        const udt = Math.max(0, ctx.uiDt);
        this.animTime += udt;

        // 1. 先消费本帧肉鸽事件（必须在刷新 lastAlive* 之前消费 campaignFailedReset，
        //    因为 restartEscortFromDeath 已在 emit 前将 hp 复原并清空了 story.talents！）
        if (ctx.events.segmentDone && ctx.events.segmentKey !== "") {
            this.segmentBannerHeadline = stageOrderNumeral(ctx.events.segmentKey) + "程告破";
            this.segmentBannerSub = ctx.events.segmentNext !== ""
                ? ("渐近北塔 · 前往" + themeOf(ctx.events.segmentNext).shortNameZh)
                : "渐近北塔 · 筹策犹在";
            this.segmentBannerT = SEGMENT_BANNER_DURATION;
        }

        if (ctx.events.campaignFailedReset) {
            const fallenRoom = ctx.events.campaignFailedRoom !== "" ? ctx.events.campaignFailedRoom : this.lastAliveRoomKey;
            const copyRanks: Record<string, number> = {};
            for (const k in this.lastAliveRanks) {
                copyRanks[k] = this.lastAliveRanks[k];
            }
            this.deathRecapSnap = {
                roomKey: fallenRoom !== "" ? fallenRoom : "escort1",
                stageName: stageReadableName(fallenRoom !== "" ? fallenRoom : "escort1"),
                ranks: copyRanks,
                totalRanks: this.lastAliveTotalRanks,
                weaponId: this.lastAliveWeapon,
                seed: this.lastAliveSeed,
            };
            this.deathRecapT = DEATH_RECAP_DURATION;
            this.ledgerOpen = false;
        } else if (rg.active && ctx.p.player.alive && ctx.p.hp > 0) {
            // 2. 记录存活态最新构筑快照（确保战死重置清空 story.talents 前完整保留复盘数据）
            this.lastAliveRoomKey = rg.roomKey;
            this.lastAliveRanks = {};
            for (const k in rg.ranks) {
                if (rg.ranks[k] > 0) {
                    this.lastAliveRanks[k] = rg.ranks[k];
                }
            }
            this.lastAliveTotalRanks = rg.totalRanks;
            this.lastAliveWeapon = rg.equippedWeapon;
            this.lastAliveSeed = rg.seed;
        }

        if (ctx.events.pickupTaken && ctx.events.pickupKind !== "") {
            this.pickupBounceMap[ctx.events.pickupKind] = 0.52;
            this.pickupPops.push({ kind: ctx.events.pickupKind, timer: 0.72, maxTimer: 0.72 });
            if (this.pickupPops.length > 6) {
                this.pickupPops.shift();
            }
        }
        if (ctx.events.pickupRejected && ctx.events.pickupRejectedKind !== "") {
            this.pickupShakeMap[ctx.events.pickupRejectedKind] = 0.42;
        }

        // 3. 衰减各类轻量动效计时
        if (this.segmentBannerT > 0) {
            this.segmentBannerT = Math.max(0, this.segmentBannerT - udt);
        }
        if (this.hpBarPulseT > 0) {
            this.hpBarPulseT = Math.max(0, this.hpBarPulseT - udt);
        }
        if (this.xiaomanRippleT > 0) {
            this.xiaomanRippleT = Math.max(0, this.xiaomanRippleT - udt);
        }
        for (const k in this.crestPulseMap) {
            if (this.crestPulseMap[k] > 0) {
                this.crestPulseMap[k] = Math.max(0, this.crestPulseMap[k] - udt);
            }
        }
        for (const k in this.pickupBounceMap) {
            if (this.pickupBounceMap[k] > 0) {
                this.pickupBounceMap[k] = Math.max(0, this.pickupBounceMap[k] - udt);
            }
        }
        for (const k in this.pickupShakeMap) {
            if (this.pickupShakeMap[k] > 0) {
                this.pickupShakeMap[k] = Math.max(0, this.pickupShakeMap[k] - udt);
            }
        }
        let pi = 0;
        let pw = 0;
        for (pi = 0; pi < this.pickupPops.length; pi++) {
            const pop = this.pickupPops[pi];
            pop.timer -= udt;
            if (pop.timer > 0) {
                this.pickupPops[pw] = pop;
                pw += 1;
            }
        }
        this.pickupPops.length = pw;

        // 4. 折筹重整过场推进（0.25s 后任意移动/点击/确认可柔速跳过）
        if (this.deathRecapT > 0) {
            const elapsedRecap = DEATH_RECAP_DURATION - this.deathRecapT;
            const wantSkip = elapsedRecap > 0.25 && (
                Math.abs(ctx.input.moveX) > 0.2
                || ctx.input.uiPressed
                || ctx.input.fire.pressed
                || ctx.input.interact.pressed
                || ctx.input.navConfirm
            );
            this.deathRecapT = Math.max(0, this.deathRecapT - udt * (wantSkip ? 4.2 : 1.0));
        }

        // 5. 监测本领选定（无论通过 1/2/3、鼠标、触屏单击、手柄 L3 还是排演 submitIntent）
        const hadOffers = this.lastOffers.length > 0;
        const hasOffers = rg.offers.length > 0;
        if (ctx.events.talentPicked && ctx.events.talentPickedId !== "") {
            this.startSealAnimation(ctx.events.talentPickedId, ctx);
        } else if (hadOffers && !hasOffers && this.sealAnim === undefined) {
            const diffId = this.detectPickedTalentFromRankDiff(rg.ranks);
            if (diffId !== "") {
                this.startSealAnimation(diffId, ctx);
            }
        } else if (!hadOffers && hasOffers) {
            // 新一轮候选筹签浮现
            this.sealAnim = undefined;
            this.drawerState = "expanded";
            this.manualCompact = false;
            this.expandAnimT = 0;
            this.staggerTime = 0;
            this.idleSinceMove = 0;
            this.hoverSlot = -1;
            this.cardLiftT = [];
            let ci = 0;
            for (ci = 0; ci < rg.offers.length; ci++) {
                this.cardLiftT.push(0);
            }
            ctx.audio.playUi("ui:talent_appear", "assets/audio/ui/talent_appear.wav", 0.68, 0.25);
        }

        // 6. 推进落印 → 流墨归身状态机
        if (this.sealAnim !== undefined) {
            this.sealAnim.elapsed += udt;
            const totalDur = this.sealAnim.sealDuration + this.sealAnim.absorbDuration;
            if (this.sealAnim.elapsed < this.sealAnim.sealDuration) {
                this.drawerState = "sealing";
            } else if (this.sealAnim.elapsed < totalDur) {
                this.drawerState = "absorbing";
            } else {
                if (!this.sealAnim.arrivedPulsed) {
                    this.sealAnim.arrivedPulsed = true;
                    this.crestPulseMap[this.sealAnim.talentId] = 0.72;
                    if (this.sealAnim.targetKind === "hp") {
                        this.hpBarPulseT = 0.70;
                    }
                }
                this.sealAnim = undefined;
                this.drawerState = hasOffers ? (this.manualCompact ? "compact" : "expanded") : "hidden";
            }
        } else if (!hasOffers) {
            this.drawerState = "hidden";
        }

        // 7. 双态自适应（展卷 ↔ 收束）与键鼠/触屏/手柄交互
        const modalBlocking = ctx.view.reloadSession.active || ctx.view.craftBench.active;
        this.processLedgerAndCardInputs(ctx, rg, modalBlocking);

        if (this.sealAnim === undefined && hasOffers) {
            const movingOrActing = Math.abs(ctx.input.moveX) > 0.15
                || Math.abs(ctx.input.moveY) > 0.15
                || ctx.input.jump.pressed
                || (ctx.input.fire.pressed && this.hoverSlot < 0)
                || modalBlocking;
            if (this.drawerState === "expanded") {
                this.expandAnimT = Math.min(1, this.expandAnimT + udt / 0.22);
                this.staggerTime += udt;
                if (movingOrActing) {
                    this.drawerState = "compact";
                    this.idleSinceMove = 0;
                }
            } else if (this.drawerState === "compact") {
                if (movingOrActing || ctx.input.fire.held || this.ledgerOpen || this.deathRecapT > 0.05) {
                    this.idleSinceMove = 0;
                } else if (!this.manualCompact) {
                    this.idleSinceMove += udt;
                    if (this.idleSinceMove >= AUTO_REEXPAND_IDLE_SEC) {
                        this.drawerState = "expanded";
                        this.expandAnimT = 0;
                        this.staggerTime = 0;
                        this.idleSinceMove = 0;
                    }
                }
            }
        }

        // 更新卡面悬浮抬升缓动
        while (this.cardLiftT.length < rg.offers.length) {
            this.cardLiftT.push(0);
        }
        let li = 0;
        for (li = 0; li < rg.offers.length; li++) {
            const isHot = (ctx.input.inputMode === "gamepad" && li === this.focusedSlot)
                || (ctx.input.inputMode !== "gamepad" && li === this.hoverSlot);
            const target = isHot ? 1 : 0;
            this.cardLiftT[li] += (target - this.cardLiftT[li]) * Math.min(1, udt * 14);
        }

        // 8. 展卷态 / 行军札记 0.25x 表现层轻慢时聚焦（仅作用于前端 worldDt 与世界音速，绝不阻塞 Play.update）
        const wantSlowFocus = !modalBlocking
            && this.deathRecapT <= 0.05
            && (this.ledgerOpen || (this.drawerState === "expanded" && hasOffers));
        const targetScale = wantSlowFocus ? EXPANDED_FOCUS_SCALE : 1.0;
        const speed = wantSlowFocus ? 5.2 : 6.0;
        if (this.focusScale < targetScale) {
            this.focusScale = Math.min(targetScale, this.focusScale + udt * speed);
        } else if (this.focusScale > targetScale) {
            this.focusScale = Math.max(targetScale, this.focusScale - udt * speed);
        }
        if (this.contract !== undefined) {
            this.contract.setFocusTimeScale(this.focusScale);
        }
        if (!ctx.view.reloadSession.active) {
            ctx.audio.setWorldPlaySpeed(Math.max(0.25, Math.min(1, this.focusScale)));
        }

        if (this.ledgerOpen) {
            this.ledgerAnimT = Math.min(1, this.ledgerAnimT + udt / 0.20);
        }

        // 9. 写回当前快照供下一帧边沿比较
        this.lastOffers = rg.offers.slice();
        this.lastRanks = {};
        for (const k in rg.ranks) {
            this.lastRanks[k] = rg.ranks[k];
        }
        if (hasOffers) {
            this.lastCardBoxes = this.getTalentCardRects(ctx.uiW, ctx.uiH, rg.offers.length, touchMode, safe.top);
        } else {
            this.lastCardBoxes = [];
        }
    }

    private processLedgerAndCardInputs(
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        modalBlocking: boolean,
    ): void {
        const touchMode = ctx.input.isTouchMode();
        const useUiPtr = ctx.input.uiInside || ctx.input.uiPressed || ctx.input.uiHeld;
        const ptrX = (useUiPtr ? ctx.input.uiX : ctx.input.mx) / ctx.uiScale;
        const ptrY = (useUiPtr ? ctx.input.uiY : ctx.input.my) / ctx.uiScale;
        const inside = useUiPtr ? ctx.input.uiInside : ctx.input.inside;
        const ptr = Vec2(ptrX, ptrY);

        const mouseLeftDown = ctx.input.inputMode === "kbm" && typeof Mouse !== "undefined" && Mouse.leftButtonPressed;
        const leftClick = ctx.input.uiPressed || (mouseLeftDown && !this.prevLeftDown);
        this.prevLeftDown = mouseLeftDown;

        let vPressed = false;
        let escPressed = false;
        let backPressed = false;
        if (typeof Keyboard !== "undefined") {
            const vDown = Keyboard.isKeyPressed(KeyName.V);
            const escDown = Keyboard.isKeyPressed(KeyName.Escape);
            const backDown = Keyboard.isKeyPressed(KeyName.BackSpace);
            vPressed = vDown && !this.prevKeyV;
            escPressed = escDown && !this.prevKeyEsc;
            backPressed = backDown && !this.prevKeyBack;
            this.prevKeyV = vDown;
            this.prevKeyEsc = escDown;
            this.prevKeyBack = backDown;
        }

        // 触控热区点击打开/关闭「行军札记」
        if (ctx.input.touchZoneTap === "ledger:toggle" && rg.active && !modalBlocking) {
            ctx.input.touchZoneTap = "";
            this.toggleLedgerWithSound(ctx);
            return;
        }

        // V 键随时展阅或合上「行军札记」
        if (vPressed && rg.active && !modalBlocking) {
            this.toggleLedgerWithSound(ctx);
            return;
        }

        if (this.ledgerOpen) {
            if (modalBlocking || escPressed || backPressed || ctx.input.navBack) {
                this.ledgerOpen = false;
                ctx.audio.playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08);
                return;
            }
            if (leftClick && inside) {
                if (this.ledgerCloseBox.containsPoint(ptr) || !this.ledgerPanelBox.containsPoint(ptr)) {
                    this.ledgerOpen = false;
                    ctx.audio.playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08);
                }
            }
            return;
        }

        // 非札记态：点击左上本领带「札记」按钮展开构筑总览
        if (rg.active && !modalBlocking && leftClick && inside
            && this.ledgerButtonBox.width > 0 && this.ledgerButtonBox.containsPoint(ptr)) {
            this.toggleLedgerWithSound(ctx);
            return;
        }

        // 点击收束/展卷切换徽章
        if (rg.offers.length > 0 && !modalBlocking && leftClick && inside
            && this.expandToggleBox.width > 0 && this.expandToggleBox.containsPoint(ptr)) {
            const nextCompact = this.drawerState === "expanded";
            this.setCompact(nextCompact);
            ctx.audio.playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045);
            return;
        }

        // 同步手柄焦点与悬停提示音
        if (rg.offers.length > 0 && !modalBlocking && this.sealAnim === undefined) {
            if (ctx.input.inputMode === "gamepad") {
                const hudSel = this.getHudSelected !== undefined ? this.getHudSelected() : this.focusedSlot;
                const clamped = clamp(hudSel, 0, rg.offers.length - 1);
                if (clamped !== this.focusedSlot) {
                    this.focusedSlot = clamped;
                    ctx.audio.playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045);
                }
                this.hoverSlot = -1;
            } else if (!touchMode && inside) {
                const boxes = this.getTalentCardRects(ctx.uiW, ctx.uiH, rg.offers.length, false, (ctx.safeUi ?? ZERO_SAFE_INSETS).top);
                let hit = -1;
                let i = 0;
                for (i = 0; i < boxes.length; i++) {
                    if (boxes[i].containsPoint(ptr)) {
                        hit = i;
                        break;
                    }
                }
                if (hit !== this.hoverSlot) {
                    this.hoverSlot = hit;
                    if (hit >= 0) {
                        this.focusedSlot = hit;
                        if (this.setHudSelected !== undefined) {
                            this.setHudSelected(hit);
                        }
                        ctx.audio.playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045);
                    }
                }
            } else {
                this.hoverSlot = -1;
            }
        } else {
            this.hoverSlot = -1;
        }
    }

    private toggleLedgerWithSound(ctx: FePluginContext): void {
        if (this.ledgerOpen) {
            this.ledgerOpen = false;
            ctx.audio.playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08);
        } else {
            this.ledgerOpen = true;
            this.ledgerAnimT = 0;
            ctx.audio.playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08);
        }
    }

    // ==================== 模块 D：2.5D 世界层肉鸽具象化 ====================

    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const rg = ctx.view.roguelike;
        const cam = ctx.cam;

        this.lastGuardArcActive = false;
        this.lastReloadArcActive = false;
        this.lastCraftRingActive = false;

        if (ctx.view.visualMode === "museum") {
            return;
        }

        // 1. 木楔加固掩体标记与残破薄木挡裂纹（所有含木挡的房间生效，灰度下立即可辨）
        let bi = 0;
        for (bi = 0; bi < p.boxes.length; bi++) {
            const b = p.boxes[bi];
            if (b.broken === true || b.hidden === true || b.id === undefined) {
                continue;
            }
            const ps = p.run.props[b.id];
            if (ps === undefined) {
                continue;
            }
            const depth = b.depth !== undefined ? (b.depth.min + b.depth.max) * 0.5 : 0;
            const x0 = cam.sx(b.x0);
            const x1 = cam.sx(b.x1);
            const y0 = cam.sy(b.y0, depth);
            const y1 = cam.sy(b.y1, depth);
            const bw = x1 - x0;
            const bh = y1 - y0;
            if (bw <= 2 || bh <= 2) {
                continue;
            }
            if (ps.wedge === true) {
                // 两侧斜钉木楔（梯形实色 + 暖亮沿边）
                const ww = Math.max(6, cam.len(6.5));
                const wh = Math.max(7, cam.len(8));
                fgDraw.drawPolygon([
                    Vec2(x0 - ww * 0.7, y0),
                    Vec2(x0 + ww * 0.45, y0),
                    Vec2(x0 + ww * 0.2, y0 + wh),
                    Vec2(x0 - ww * 0.25, y0 + wh * 0.55),
                ], toColor(PALETTE.emerald, 220), 1.1, toColor(PALETTE.moonPale, 220));
                fgDraw.drawPolygon([
                    Vec2(x1 + ww * 0.7, y0),
                    Vec2(x1 - ww * 0.45, y0),
                    Vec2(x1 - ww * 0.2, y0 + wh),
                    Vec2(x1 + ww * 0.25, y0 + wh * 0.55),
                ], toColor(PALETTE.emerald, 220), 1.1, toColor(PALETTE.moonPale, 220));
                fgDraw.drawSegment(Vec2(x0 + 2, y1 - 1), Vec2(x1 - 2, y1 - 1), 1.6, toColor(PALETTE.emerald, 210));
            }
            if (ps.hp === 1 && !ps.broken) {
                // 仅剩 1 次承击的受损裂纹（焦墨折线）
                const mx = (x0 + x1) * 0.5;
                fgDraw.drawSegment(Vec2(mx - bw * 0.14, y1 - bh * 0.08), Vec2(mx + bw * 0.06, y0 + bh * 0.52), 1.4, Color(14, 12, 16, 220));
                fgDraw.drawSegment(Vec2(mx + bw * 0.06, y0 + bh * 0.52), Vec2(mx - bw * 0.08, y0 + bh * 0.14), 1.3, Color(14, 12, 16, 220));
                fgDraw.drawSegment(Vec2(mx + bw * 0.06, y0 + bh * 0.52), Vec2(mx + bw * 0.22, y0 + bh * 0.34), 1.0, Color(214, 186, 146, 150));
            }
        }

        if (p.childMode || !p.player.alive) {
            return;
        }

        const pl = p.player;
        const px = cam.sx(pl.x);
        const pyCenter = cam.sy(pl.y + pl.h * 0.56, pl.depth);
        const headY = cam.sy(pl.y + pl.h + 10, pl.depth);
        const facing = pl.facing >= 0 ? 1 : -1;

        // 2. 「护身」延长受击保护松烟青玉余势弧（非科幻护盾球，写实水墨半弧）
        const guardRank = rg.ranks["guard"] ?? 0;
        if (rg.activeInvulnTicks > 0 && guardRank > 0) {
            this.lastGuardArcActive = true;
            const frac = clamp(rg.activeInvulnTicks / Math.max(1, rg.invulnTicksNow), 0, 1);
            const arcR = Math.max(18, cam.len(20));
            const halfSpan = (0.35 + 0.85 * frac) * Math.PI * 0.55;
            const baseAngle = facing > 0 ? 0 : Math.PI;
            drawBrushArc(
                fgDraw,
                px + facing * cam.len(4),
                pyCenter,
                arcR,
                arcR * 1.18,
                baseAngle - halfSpan,
                baseAngle + halfSpan,
                2.4,
                toColor(PALETTE.emerald, Math.round(140 + 95 * frac)),
                14,
            );
            drawBrushArc(
                fgGlow,
                px + facing * cam.len(4),
                pyCenter,
                arcR * 1.12,
                arcR * 1.28,
                baseAngle - halfSpan * 0.82,
                baseAngle + halfSpan * 0.82,
                1.3,
                toColor(PALETTE.moonPale, Math.round(90 * frac)),
                12,
            );
        }

        // 3. 「熟铳」非盘面装填火绳弧（装填归零瞬间清脆收芒）
        if (rg.activeReloadTicks > 0 && !ctx.view.reloadSession.active) {
            this.lastReloadArcActive = true;
            const totalRel = Math.max(1, rg.reloadTicksNow);
            const prog = clamp(1 - rg.activeReloadTicks / totalRel, 0, 1);
            const rx = px + facing * cam.len(14);
            const ry = headY + cam.len(4);
            const rr = Math.max(9, cam.len(10));
            const hasReloadRank = (rg.ranks["reload"] ?? 0) > 0;
            const arcCol = hasReloadRank ? PALETTE.amberCore : PALETTE.silkLine;
            drawBrushArc(fgDraw, rx, ry, rr, rr, Math.PI * 0.15, Math.PI * 0.85, 1.4, toColor(PALETTE.inkWash, 160), 10);
            const endA = Math.PI * 0.85 - (Math.PI * 0.70) * prog;
            drawBrushArc(fgDraw, rx, ry, rr, rr, endA, Math.PI * 0.85, 2.1, toColor(arcCol, 230), 10);
            if (hasReloadRank) {
                const sparkX = rx + Math.cos(endA) * rr;
                const sparkY = ry + Math.sin(endA) * rr;
                fgGlow.drawDot(Vec2(sparkX, sparkY), 2.8, toColor(PALETTE.amberCore, 240));
                fillRadialGlow(fgGlow, sparkX, sparkY, 9, 9, toColor(PALETTE.amber, 70), Color(214, 186, 146, 0), 10);
            }
        }

        // 4. 「巧手」削楔木工竹节环 + 飞散木屑微粒
        if (rg.activeCraftTicks > 0) {
            this.lastCraftRingActive = true;
            const totalCraft = Math.max(1, rg.craftTicksNow);
            const prog = clamp(rg.activeCraftTicks / totalCraft, 0, 1);
            const cx = px + facing * cam.len(12);
            const cy = headY + cam.len(8);
            const cr = Math.max(11, cam.len(12));
            drawBrushArc(fgDraw, cx, cy, cr, cr, 0, TWO_PI, 1.5, Color(14, 17, 25, 160), 16);
            drawBrushArc(fgDraw, cx, cy, cr, cr, Math.PI * 0.5, Math.PI * 0.5 - TWO_PI * prog, 2.4, toColor(PALETTE.amberCore, 240), 16);
            let k = 0;
            for (k = 0; k < 4; k++) {
                const ph = (this.animTime * 4.6 + k * 0.25) % 1;
                const ang = (k * 1.57) + ph * 1.4;
                const sx = cx + Math.cos(ang) * (cr + ph * 10);
                const sy = cy + Math.sin(ang) * (cr + ph * 8) - ph * 6;
                fgDraw.drawSegment(Vec2(sx - 2, sy), Vec2(sx + 2, sy + 1.5), 1.3, toColor(PALETTE.amber, Math.round(215 * (1 - ph))));
            }
        }

        // 5. 选筹瞬间背负小满青布针套温和微杏涟漪
        if (this.xiaomanRippleT > 0.01 && ctx.view.backCarry.active) {
            const p01 = 1 - this.xiaomanRippleT / 0.78;
            const bx = px - facing * cam.len(8);
            const by = cam.sy(pl.y + pl.h * 0.68, pl.depth);
            const rr = cam.len(8) + easeOutCubic(p01) * cam.len(22);
            const alpha = (1 - p01) * 0.85;
            drawBrushArc(fgGlow, bx, by, rr, rr, 0, TWO_PI, 1.5, toColor(PALETTE.amberCore, Math.round(180 * alpha)), 18);
            fillRadialGlow(fgGlow, bx, by, rr * 0.8, rr * 0.8, toColor(PALETTE.amber, Math.round(48 * alpha)), Color(214, 186, 146, 0), 12);
        }
    }

    // ==================== 全速 UI 渲染层（模块 A / B / C / E） ====================

    drawFullSpeedUi(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const rg = ctx.view.roguelike;
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const modalBlocking = ctx.view.reloadSession.active || ctx.view.craftBench.active;

        // 1. 模块 B：常驻肉鸽 HUD（北行舆图丝线 + 本领微章带 + 随身战备行囊条；札记/折筹全幕态自动静隐）
        if (rg.active && !modalBlocking && !this.ledgerOpen && this.deathRecapT <= 0.15) {
            if (rg.showRouteTrack && rg.stages.length > 0) {
                this.drawNorthwardTrack(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg.stages, safe);
            }
            this.drawCrestAndSatchelHud(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe);
        } else {
            this.ledgerButtonBox = Rect(0, 0, 0, 0);
        }

        // 2. 模块 A：双态三筹木简选卡 + 朱砂落印 + 流墨归身
        if (!modalBlocking && !this.ledgerOpen && this.deathRecapT <= 0.15) {
            if (this.sealAnim !== undefined) {
                this.drawSealAndAbsorb(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, this.sealAnim);
            } else if (rg.offers.length > 0) {
                if (this.drawerState === "expanded") {
                    this.drawExpandedTalentCards(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe);
                } else if (this.drawerState === "compact") {
                    this.drawCompactTalentTallies(uiDraw, uiInkDraw, uiArt, ctx, rg, safe);
                }
            } else {
                this.expandToggleBox = Rect(0, 0, 0, 0);
            }
        } else {
            this.expandToggleBox = Rect(0, 0, 0, 0);
        }

        // 3. 模块 E1：「险段告破」非阻塞行书里程流带
        if (this.segmentBannerT > 0.01) {
            this.drawSegmentClearRibbon(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, safe);
        }

        // 4. 模块 E2：「折筹重整 · 残筹散墨」战死重置复盘幕
        if (this.deathRecapT > 0.01 && this.deathRecapSnap !== undefined) {
            this.drawDeathRecapOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, this.deathRecapSnap);
        }

        // 5. 模块 C：「行军札记」宣纸对折构筑总览页
        if (this.ledgerOpen && rg.active && !modalBlocking) {
            this.drawBuildLedger(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe);
            return true;
        }

        return this.drawerState === "expanded" && this.hoverSlot >= 0;
    }

    // ---------- 模块 B3：顶部纤细北行舆图里程丝线 ----------

    private drawNorthwardTrack(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        stages: readonly RoguelikeStageNode[],
        safe: SafeInsets,
    ): void {
        const cx = ctx.uiW * 0.5;
        const y = ctx.uiH - (ctx.view.isRehearsal ? 50 : 24) - safe.top;
        const spanW = Math.min(360, ctx.uiW * 0.34);
        const x0 = cx - spanW * 0.5;
        const step = stages.length > 1 ? spanW / (stages.length - 1) : 0;

        drawSilkVeil(uiDraw, uiArt, "rg_track_veil", cx, y, spanW + 108, 28, PALETTE.inkWash, 0.56, -1);
        uiInkDraw.drawSegment(Vec2(x0, y + 3), Vec2(x0 + spanW, y + 3), 0.9, toColor(PALETTE.silkDim, 130));

        // 涂亮已行进路段
        let curIdx = 0;
        let i = 0;
        for (i = 0; i < stages.length; i++) {
            if (stages[i].current) {
                curIdx = i;
                break;
            }
        }
        if (curIdx > 0) {
            uiInkDraw.drawSegment(Vec2(x0, y + 3), Vec2(x0 + step * curIdx, y + 3), 1.4, toColor(PALETTE.moonPale, 195));
        }

        for (i = 0; i < stages.length; i++) {
            const st = stages[i];
            const nx = x0 + step * i;
            const ny = y + 3;
            if (st.current) {
                const breathe = 0.82 + 0.18 * Math.sin(this.animTime * 4.2);
                fillRadialGlow(uiGlow, nx, ny, 14, 14, toColor(PALETTE.rouge, 46 * breathe), Color(182, 58, 56, 0), 10);
                drawBlossomDot(uiInkDraw, uiArt, "rg_st_cur_" + i, nx, ny, 13, PALETTE.rouge, 0.96, 4);
            } else if (st.cleared) {
                drawDiamond(uiInkDraw, nx, ny, 4.2, 4.2, toColor(PALETTE.moonPale, 225), 0.8, toColor(PALETTE.cyan, 180));
            } else if (st.isBench || st.isFinal) {
                fillRadialGlow(uiGlow, nx, ny, 10, 10, toColor(PALETTE.amber, 26), Color(214, 186, 146, 0), 8);
                drawDiamond(uiInkDraw, nx, ny, 4.0, 4.0, Color(20, 22, 30, 210), 1.1, toColor(PALETTE.amberCore, 215));
            } else {
                drawDiamond(uiInkDraw, nx, ny, 3.3, 3.3, Color(16, 19, 27, 210), 0.9, toColor(PALETTE.silkDim, 155));
            }
            const labelCol = st.current
                ? PALETTE.textBright
                : (st.isBench || st.isFinal ? PALETTE.amberCore : (st.cleared ? PALETTE.textMid : PALETTE.textDim));
            ctx.texts.put(
                "xs",
                st.label,
                nx,
                ny - 14,
                toColor(labelCol),
                0.5,
                0.5,
                TextAlign.Center,
                0.4,
                st.current ? 0.96 : 0.72,
                0.08,
            );
        }
    }

    // ---------- 模块 B1 + B2：左上本领微章带 + 统一随身战备行囊条 ----------

    private drawCrestAndSatchelHud(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        safe: SafeInsets,
    ): void {
        const bx = 28 + safe.left;
        const hpBaseY = ctx.uiH - 72 - safe.top;
        const p = ctx.p;

        // 厚甲习得归位脉冲：血条周围闪出一层霜月柔光
        if (this.hpBarPulseT > 0.01) {
            const pA = clamp(this.hpBarPulseT / 0.70, 0, 1);
            fillRadialGlow(uiGlow, bx + 130, hpBaseY + 16, 140, 28, toColor(PALETTE.moonPale, 44 * pA), Color(232, 236, 234, 0), 12);
        }

        // 若小满惊惧条同时出现（S1..C2 战役段惊惧 > 0），本领带自动下移一行避让
        const fearVisible = p.isCampaign
            && (p.room.campaign?.chapter === "S" || p.room.campaign?.chapter === "C")
            && (p.escort.fear > 0 || p.escort.state === "frozen" || p.escort.state === "calming");
        const row1Y = hpBaseY - (fearVisible ? 52 : 24);

        // 1. 收集所有已习得本领（保留固定次序 + 动态追加新天赋）
        const learnedIds: string[] = [];
        const baseOrder = ["vitality", "reload", "guard", "craft"];
        let i = 0;
        for (i = 0; i < baseOrder.length; i++) {
            if ((rg.ranks[baseOrder[i]] ?? 0) > 0) {
                learnedIds.push(baseOrder[i]);
            }
        }
        for (const k in rg.ranks) {
            if ((rg.ranks[k] ?? 0) > 0 && learnedIds.indexOf(k) < 0) {
                learnedIds.push(k);
            }
        }

        // 2. 绘制本领微章带 + 「札记」入口章
        let cursorX = bx;
        const badgeH = 26;
        const rowCenterY = row1Y + 6;
        for (i = 0; i < learnedIds.length; i++) {
            const tid = learnedIds[i];
            const rank = rg.ranks[tid] ?? 1;
            const meta = resolveTalentVisual(tid, rg);
            const badgeW = 62;
            const pulse = this.crestPulseMap[tid] ?? 0;
            const activeNow = (tid === "guard" && rg.activeInvulnTicks > 0)
                || (tid === "reload" && rg.activeReloadTicks > 0)
                || (tid === "craft" && rg.activeCraftTicks > 0);
            const glowBoost = Math.max(pulse, activeNow ? (0.55 + 0.35 * Math.sin(this.animTime * 8)) : 0);

            if (glowBoost > 0.02) {
                fillRadialGlow(uiGlow, cursorX + badgeW * 0.5, rowCenterY, badgeW * 0.72, 20, toColor(meta.accentCore, 46 * glowBoost), Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), 10);
            }
            uiDraw.drawRoundedRect(
                Rect(cursorX, rowCenterY - badgeH * 0.5, badgeW, badgeH),
                4,
                toColor(activeNow ? PALETTE.inkWarm : PALETTE.inkWash, activeNow ? 225 : 196),
                activeNow || pulse > 0.05 ? 1.3 : 0.85,
                toColor(activeNow || pulse > 0.05 ? meta.accentCore : meta.accent, activeNow ? 235 : 168),
            );
            drawTalentGlyph(uiInkDraw, cursorX + 15, rowCenterY, 8.2, tid, meta.accent, 0.96, meta.accentCore);
            ctx.texts.put(
                "xs",
                rankChinese(rank),
                cursorX + 41,
                rowCenterY,
                toColor(meta.accentCore),
                0.5,
                0.5,
                TextAlign.Center,
                0,
                0.96,
                0.08,
            );
            // 若护身余势生效，底部附一条实时衰减青玉细丝
            if (tid === "guard" && rg.activeInvulnTicks > 0) {
                const frac = clamp(rg.activeInvulnTicks / Math.max(1, rg.invulnTicksNow), 0, 1);
                uiInkDraw.drawSegment(
                    Vec2(cursorX + 4, rowCenterY - badgeH * 0.5 + 2),
                    Vec2(cursorX + 4 + (badgeW - 8) * frac, rowCenterY - badgeH * 0.5 + 2),
                    2.0,
                    toColor(PALETTE.emerald, 240),
                );
            }
            cursorX += badgeW + 6;
        }

        // 「札记」按钮（紧接本领微章带右侧；触屏与键鼠均可直接点开行军札记）
        const ledgerLabel = ctx.input.inputMode === "kbm" ? "札记 V" : "札记";
        const ledgerW = ctx.input.inputMode === "kbm" ? 64 : 48;
        const ledgerRect = Rect(cursorX, rowCenterY - badgeH * 0.5, ledgerW, badgeH);
        this.ledgerButtonBox = ledgerRect;
        const ptrX = (ctx.input.uiInside ? ctx.input.uiX : ctx.input.mx) / ctx.uiScale;
        const ptrY = (ctx.input.uiInside ? ctx.input.uiY : ctx.input.my) / ctx.uiScale;
        const ledgerHover = !ctx.input.isTouchMode() && (ctx.input.uiInside || ctx.input.inside) && ledgerRect.containsPoint(Vec2(ptrX, ptrY));
        uiDraw.drawRoundedRect(
            ledgerRect,
            4,
            toColor(ledgerHover ? PALETTE.rougeSoft : PALETTE.inkWash, ledgerHover ? 205 : 176),
            0.9,
            toColor(ledgerHover ? PALETTE.amberCore : PALETTE.silkDim, ledgerHover ? 225 : 155),
        );
        ctx.texts.put(
            "xs",
            ledgerLabel,
            ledgerRect.x + ledgerRect.width * 0.5,
            rowCenterY,
            toColor(ledgerHover ? PALETTE.textBright : PALETTE.amberCore),
            0.5,
            0.5,
            TextAlign.Center,
            0.6,
            0.92,
            0.08,
        );

        // 3. 模块 B2：统一随身战备行囊条（修复 escort1..5 物资不可见的真实缺陷！）
        // 键鼠/手柄/竖屏停靠左下清雅边栏（彻底避开中上部展卷木简卡与小满惊惧条）；
        // 横屏触屏为避让左下虚拟摇杆，停靠左上次行（并在展卷态外完整显示）。
        const touchLandscape = ctx.input.shouldShowTouchControls() && ctx.uiW > ctx.uiH;
        const row2Y = touchLandscape ? (rowCenterY - 30) : (28 + safe.bottom);
        const wMeta = weaponMetaOf(rg.equippedWeapon);
        const shownItems: { kind: string; count: number }[] = [];
        const shownKinds: string[] = [];
        for (i = 0; i < PICKUP_ORDER.length; i++) {
            const k = PICKUP_ORDER[i];
            const cnt = rg.supplies[k] ?? 0;
            if (cnt > 0) {
                shownItems.push({ kind: k, count: cnt });
                shownKinds.push(k);
            }
        }
        this.lastSuppliesShown = shownKinds;
        if (touchLandscape && this.drawerState === "expanded") {
            return;
        }

        const woodCnt = rg.supplies["wood"] ?? 0;
        const bellCnt = rg.supplies["bell"] ?? 0;
        const craftReady = (rg.roomKey === "escort2" || rg.roomKey === "escort3")
            && (woodCnt >= 2 || (woodCnt >= 1 && bellCnt >= 1))
            && rg.equippedWeapon === "standard_gun";

        // 武器铭牌 + 所有持有数量 > 0 的随身战备
        let sx = bx;
        const weaponW = 86;
        const pillH = 24;
        if (!touchLandscape) {
            const stripW = weaponW + 6 + shownItems.length * 59 + (craftReady ? 68 : 0) + 28;
            drawSilkVeil(uiDraw, uiArt, "rg_satchel_veil", bx + stripW * 0.45, row2Y, stripW + 32, 34, PALETTE.inkWash, 0.56, -1);
        }
        uiDraw.drawRoundedRect(
            Rect(sx, row2Y - pillH * 0.5, weaponW, pillH),
            4,
            toColor(PALETTE.inkWash, 185),
            0.85,
            toColor(wMeta.accent, 160),
        );
        drawReloadPatternGlyph(uiInkDraw, sx + 14, row2Y, 7.2, wMeta.effect, wMeta.accent, 0.94);
        ctx.texts.put("xs", wMeta.shortName, sx + 26, row2Y, toColor(wMeta.accent), 0, 0.5, TextAlign.Left, 0.5, 0.94, 0.08);
        sx += weaponW + 6;

        for (i = 0; i < shownItems.length; i++) {
            const it = shownItems[i];
            const pm = pickupMetaOf(it.kind);
            const bounce = this.pickupBounceMap[it.kind] ?? 0;
            const shake = this.pickupShakeMap[it.kind] ?? 0;
            const shakeX = shake > 0 ? Math.sin(this.animTime * 56) * 3.2 * (shake / 0.42) : 0;
            const liftY = bounce > 0 ? Math.sin((bounce / 0.52) * Math.PI) * 5.0 : 0;
            const itemW = 54;
            const rx = sx + shakeX;
            const ry = row2Y + liftY;
            const isHot = bounce > 0.02 || (craftReady && (it.kind === "wood" || it.kind === "bell"));
            const bdCol = shake > 0.02 ? PALETTE.rouge : (isHot ? PALETTE.amberCore : pm.accent);

            if (isHot) {
                const ga = bounce > 0.02 ? 48 * (bounce / 0.52) : (24 + 12 * Math.sin(this.animTime * 4.5));
                fillRadialGlow(uiGlow, rx + itemW * 0.5, ry, 34, 16, toColor(PALETTE.amberCore, ga), Color(214, 186, 146, 0), 10);
            }
            uiDraw.drawRoundedRect(
                Rect(rx, ry - pillH * 0.5, itemW, pillH),
                4,
                toColor(shake > 0.02 ? PALETTE.inkWarm : PALETTE.inkWash, 192),
                isHot || shake > 0.02 ? 1.2 : 0.8,
                toColor(bdCol, isHot || shake > 0.02 ? 225 : 148),
            );
            drawPickupGlyph(uiInkDraw, rx + 14, ry, 7.2, it.kind, 0.96);
            ctx.texts.put(
                "xs",
                "×" + it.count,
                rx + 37,
                ry,
                toColor(pm.accentCore),
                0.5,
                0.5,
                TextAlign.Center,
                0,
                0.96,
                0.08,
            );
            // 拾取上浮 +1 轻提示
            let popIdx = 0;
            for (popIdx = 0; popIdx < this.pickupPops.length; popIdx++) {
                const pop = this.pickupPops[popIdx];
                if (pop.kind === it.kind) {
                    const prog = 1 - pop.timer / pop.maxTimer;
                    ctx.texts.put(
                        "xs",
                        "+1",
                        rx + itemW * 0.5,
                        ry + 16 + prog * 14,
                        toColor(PALETTE.amberCore),
                        0.5,
                        0.5,
                        TextAlign.Center,
                        0,
                        1 - prog,
                        0.08,
                    );
                    break;
                }
            }
            sx += itemW + 5;
        }

        if (craftReady) {
            const breathe = 0.72 + 0.28 * Math.sin(this.animTime * 4.2);
            uiDraw.drawRoundedRect(Rect(sx, row2Y - pillH * 0.5, 62, pillH), 4, toColor(PALETTE.inkWarm, 185), 0.95, toColor(PALETTE.amberCore, 210 * breathe));
            ctx.texts.put("xs", "足改制", sx + 31, row2Y, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0.6, 0.94 * breathe, 0.08);
        }
    }

    // ---------- 模块 A1：展卷态「三筹木简」宣纸筹签 ----------

    private drawExpandedTalentCards(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        safe: SafeInsets,
    ): void {
        const offers = rg.offers;
        const touchMode = ctx.input.isTouchMode();
        const mode: InputMode = ctx.input.inputMode;
        const boxes = computeRoguelikeCardRects(ctx.uiW, ctx.uiH, offers.length, true, touchMode, safe.top);
        this.lastCardBoxes = boxes;
        const appear = easeOutCubic(this.expandAnimT);
        const slowFrac = clamp((1 - this.focusScale) / (1 - EXPANDED_FOCUS_SCALE), 0, 1);

        // 1. 顶部轻墨压暗与聚焦微暗角（下部完全通透，清晰可见周戍背负小满站立舞台）
        fillVGradRect(
            uiDraw,
            0,
            ctx.uiH * 0.36,
            ctx.uiW,
            ctx.uiH * 0.64,
            Color(9, 12, 19, 0),
            Color(9, 12, 19, Math.round((138 + 42 * slowFrac) * appear)),
        );

        // 2. 顶部题带与收束切换章
        const firstBox = boxes[0];
        const headY = firstBox.y + firstBox.height + 28;
        const cx = ctx.uiW * 0.5;
        drawSilkVeil(uiDraw, uiArt, "rg_exp_head_veil", cx, headY, 440, 30, PALETTE.inkWash, 0.78 * appear, -1);
        drawHairline(uiInkDraw, uiArt, "rg_exp_head_line", cx, headY + 15, 360, PALETTE.amber, 0.54 * appear, true, 2);
        const headText = mode === "gamepad"
            ? ("途中整备 · 择一军筹（LB/RB 择项 · " + keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout) + " / L3 落印）")
            : (touchMode
                ? "途中整备 · 择一军筹 · 轻触卡面直接落印"
                : "途中整备 · 择一军筹 · 按 1 / 2 / 3 或点击落印");
        ctx.texts.put("xs", headText, cx, headY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.0, 0.96 * appear, 0.08);

        // 右侧轻巧「收起」钮（允许手动折回顶部迷你筹签）
        const lastBox = boxes[boxes.length - 1];
        const togX = Math.min(ctx.uiW - 86 - safe.right, lastBox.x + lastBox.width - 52);
        const togRect = Rect(togX, headY - 12, 54, 24);
        this.expandToggleBox = togRect;
        uiDraw.drawRoundedRect(togRect, 4, toColor(PALETTE.inkWash, 185 * appear), 0.85, toColor(PALETTE.silkDim, 165 * appear));
        ctx.texts.put("xs", "收束", togRect.x + 27, headY, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.6, 0.88 * appear, 0.08);

        // 3. 逐张错落渲染宋明竖幅筹签卡
        let i = 0;
        for (i = 0; i < offers.length; i++) {
            const tid = offers[i];
            const baseBox = boxes[i];
            const cardStagger = easeOutCubic(clamp((this.staggerTime - i * 0.055) / 0.24, 0, 1));
            const alpha = cardStagger * appear;
            if (alpha <= 0.01) {
                continue;
            }
            const lift = (this.cardLiftT[i] ?? 0) * 10;
            const slideY = (1 - cardStagger) * -22;
            const x = baseBox.x;
            const y = baseBox.y + slideY + lift;
            const w = baseBox.width;
            const h = baseBox.height;
            const isHot = (mode === "gamepad" && i === this.focusedSlot)
                || (mode !== "gamepad" && i === this.hoverSlot);
            this.drawSingleTalentCard(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, tid, i, x, y, w, h, isHot, alpha, mode);
        }
    }

    private drawSingleTalentCard(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        tid: string,
        slotIdx: number,
        x: number,
        y: number,
        w: number,
        h: number,
        isHot: boolean,
        alpha: number,
        mode: InputMode,
    ): void {
        const meta = resolveTalentVisual(tid, rg);
        const curRank = rg.ranks[tid] ?? 0;
        const cx = x + w * 0.5;
        const cy = y + h * 0.5;
        const accent = isHot ? PALETTE.rouge : meta.accent;

        // 背后柔光与暗影
        uiArt.tryPlace("ink_frame_mask", "rg_card_sh_" + slotIdx, cx, cy - 4, w + 26, h + 24, {
            color: toColor(PALETTE.voidDark), opacity: 0.72 * alpha, layer: -1,
        });
        if (isHot) {
            const breathe = 0.86 + 0.14 * Math.sin(this.animTime * 4.0);
            fillRadialGlow(uiGlow, cx, cy, w * 0.74, h * 0.64, toColor(PALETTE.rouge, 34 * breathe * alpha), Color(182, 58, 56, 0), 14);
        }

        // 宋明暗宣纸木简底面
        const bgCol = isHot ? Color(28, 22, 27, Math.round(244 * alpha)) : Color(15, 18, 26, Math.round(234 * alpha));
        const bdCol = toColor(isHot ? PALETTE.rouge : meta.accent, (isHot ? 235 : 155) * alpha);
        uiDraw.drawRoundedRect(Rect(x, y, w, h), 5, bgCol, isHot ? 1.55 : 0.95, bdCol);
        // 内部微亮发丝宣纸边
        uiDraw.drawRect(Rect(x + 5, y + 5, w - 10, h - 10), Color(0, 0, 0, 0), 0.65, toColor(isHot ? PALETTE.amberCore : PALETTE.silkDim, (isHot ? 115 : 68) * alpha));
        // 四角宋明海棠纤细折角
        drawFiligreeCorners(uiInkDraw, uiArt, "rg_card_cn_" + slotIdx, x + 2, y + 2, w - 4, h - 4, accent, (isHot ? 0.94 : 0.62) * alpha, 22, false, 3);

        // 顶行：筹类标签（左）+ 竹节菱花阶位（右）
        const topY = y + h - 22;
        ctx.texts.put("xs", meta.category, x + 16, topY, toColor(meta.accentCore), 0, 0.5, TextAlign.Left, 1.2, 0.88 * alpha, 0.08);

        // 阶位进度菱花：已习得实心 ◆ + 即将晋升空心/朱砂菱 ◇ → ◆
        const maxPips = Math.max(curRank + 1, 3);
        const pipStartX = x + w - 16 - (maxPips - 1) * 12;
        let k = 0;
        for (k = 0; k < maxPips; k++) {
            const px = pipStartX + k * 12;
            if (k < curRank) {
                drawDiamond(uiInkDraw, px, topY, 4.0, 4.0, toColor(meta.accentCore, 230 * alpha));
            } else if (k === curRank) {
                drawDiamond(uiInkDraw, px, topY, 4.4, 4.4, toColor(isHot ? PALETTE.rouge : PALETTE.amber, 220 * alpha), 1.0, toColor(PALETTE.textBright, 220 * alpha));
            } else {
                drawDiamond(uiInkDraw, px, topY, 3.2, 3.2, Color(0, 0, 0, 0), 0.85, toColor(PALETTE.silkDim, 130 * alpha));
            }
        }

        drawHairline(uiInkDraw, uiArt, "rg_card_hl_" + slotIdx, cx, topY - 14, w - 28, accent, 0.45 * alpha, false, 2);

        // 中上部：明初工笔器物纹样 + 柔墨圆相底托
        const iconY = y + h - 76;
        uiArt.tryPlace("ink_enso_fine", "rg_card_enso_" + slotIdx, cx, iconY, 62, 62, {
            color: toColor(isHot ? PALETTE.amberCore : meta.accent), opacity: (isHot ? 0.64 : 0.36) * alpha, angle: this.animTime * (isHot ? 16 : 6), layer: 2,
        });
        fillRadialGlow(uiGlow, cx, iconY, 34, 34, toColor(meta.accent, (isHot ? 42 : 20) * alpha), Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), 12);
        drawTalentGlyph(uiInkDraw, cx, iconY, 22, tid, isHot ? meta.accentCore : meta.accent, alpha, isHot ? PALETTE.textBright : meta.accentCore);

        // 题名（宽字距宋明竖简气韵）
        const titleY = y + 114;
        ctx.texts.put(
            "md",
            meta.title,
            cx,
            titleY,
            toColor(isHot ? PALETTE.textBright : meta.accentCore),
            0.5,
            0.5,
            TextAlign.Center,
            5.0,
            0.98 * alpha,
            0.10,
        );

        // 实时动态数值变化 + 简明效用
        ctx.texts.put(
            "xs",
            meta.shortEffect(rg, curRank),
            cx,
            titleY - 26,
            toColor(isHot ? PALETTE.amberCore : PALETTE.textBright),
            0.5,
            0.5,
            TextAlign.Center,
            0.6,
            0.96 * alpha,
            0.08,
        );
        ctx.texts.put(
            "xs",
            meta.subEffect(rg, curRank),
            cx,
            titleY - 46,
            toColor(PALETTE.textMid),
            0.5,
            0.5,
            TextAlign.Center,
            0.4,
            0.86 * alpha,
            0.08,
        );

        // 兄妹心语注脚（聚焦态清亮显现；触屏下柔和常显便于单击前阅览）
        const whisperAlpha = (isHot ? 0.90 : (mode === "touch" ? 0.62 : 0.36)) * alpha;
        ctx.texts.put(
            "xs",
            meta.whisper,
            cx,
            y + 44,
            toColor(isHot ? PALETTE.amberCore : PALETTE.textDim),
            0.5,
            0.5,
            TextAlign.Center,
            0.2,
            whisperAlpha,
            0.06,
        );

        // 底部落印操控提示条
        const footY = y + 18;
        if (isHot) {
            drawSilkRibbon(uiDraw, uiArt, "rg_card_rib_" + slotIdx, cx, footY, w - 18, 24, PALETTE.rougeSoft, 0.56 * alpha, 1);
        }
        if (mode === "kbm") {
            drawSilkKeycap(uiInkDraw, ctx.texts, cx - 42, footY - 10, 22, 20, "" + (slotIdx + 1), accent, alpha, isHot);
            ctx.texts.put("xs", isHot ? "落印习得" : "习得", cx - 12, footY, toColor(isHot ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.0, 0.94 * alpha, 0.08);
        } else if (mode === "gamepad") {
            const label = isHot ? "◆ L3 落印 ◆" : ("第" + rankChinese(slotIdx + 1) + "筹");
            ctx.texts.put("xs", label, cx, footY, toColor(isHot ? PALETTE.amberCore : PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.0, 0.94 * alpha, 0.08);
        } else {
            ctx.texts.put("xs", "轻触落印", cx, footY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, 0.95 * alpha, 0.08);
        }
    }

    // ---------- 模块 A2：收束态顶部迷你筹签条 ----------

    private drawCompactTalentTallies(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        safe: SafeInsets,
    ): void {
        const offers = rg.offers;
        const touchMode = ctx.input.isTouchMode();
        const mode = ctx.input.inputMode;
        const boxes = computeRoguelikeCardRects(ctx.uiW, ctx.uiH, offers.length, false, touchMode, safe.top);
        this.lastCardBoxes = boxes;

        let i = 0;
        for (i = 0; i < offers.length; i++) {
            const tid = offers[i];
            const box = boxes[i];
            const meta = resolveTalentVisual(tid, rg);
            const isHot = (mode === "gamepad" && i === this.focusedSlot)
                || (mode !== "gamepad" && i === this.hoverSlot);
            const cy = box.y + box.height * 0.5;
            const bdCol = isHot ? PALETTE.rouge : meta.accent;

            uiDraw.drawRoundedRect(
                box,
                4,
                toColor(isHot ? PALETTE.inkWarm : PALETTE.panelBgDeep, isHot ? 236 : 210),
                isHot ? 1.4 : 0.9,
                toColor(bdCol, isHot ? 235 : 178),
            );
            drawTalentGlyph(uiInkDraw, box.x + 20, cy, 10.5, tid, meta.accent, 0.96, meta.accentCore);
            if (mode === "kbm") {
                drawSilkKeycap(uiInkDraw, ctx.texts, box.x + 36, cy - 10, 20, 20, "" + (i + 1), bdCol, 0.95, isHot);
                ctx.texts.put("xs", meta.title, box.x + 62, cy + 7, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.96, 0.08);
                ctx.texts.put("xs", meta.shortEffect(rg, rg.ranks[tid] ?? 0), box.x + 62, cy - 8, toColor(meta.accentCore), 0, 0.5, TextAlign.Left, 0.2, 0.82, 0.06);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "rg_cmp_dot_" + i, box.x + 38, cy, isHot ? 11 : 7, bdCol, 0.95, 4);
                ctx.texts.put("xs", meta.title + " · " + meta.category, box.x + 50, cy + 7, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.6, 0.96, 0.08);
                ctx.texts.put("xs", meta.shortEffect(rg, rg.ranks[tid] ?? 0), box.x + 50, cy - 8, toColor(meta.accentCore), 0, 0.5, TextAlign.Left, 0.2, 0.82, 0.06);
            }
        }

        // 右侧「展开」按钮（可随时重新展卷细阅）
        const last = boxes[boxes.length - 1];
        const togRect = Rect(last.x + last.width + 8, last.y + (last.height - 26) * 0.5, 50, 26);
        this.expandToggleBox = togRect;
        uiDraw.drawRoundedRect(togRect, 4, toColor(PALETTE.inkWash, 190), 0.9, toColor(PALETTE.amber, 175));
        ctx.texts.put("xs", "展开", togRect.x + 25, togRect.y + 13, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0.6, 0.92, 0.08);
    }

    // ---------- 模块 A3：朱砂落印「契印」与二阶贝塞尔墨芒归身 ----------

    private drawSealAndAbsorb(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        anim: SealAnimState,
    ): void {
        const meta = resolveTalentVisual(anim.talentId, rg);
        const pb = anim.pickedBox;
        const pcx = pb.x + pb.width * 0.5;
        const pcy = pb.y + pb.height * 0.5;

        if (anim.elapsed < anim.sealDuration) {
            const t = clamp(anim.elapsed / anim.sealDuration, 0, 1);
            // 其余两枚向两侧散墨淡出
            let i = 0;
            for (i = 0; i < anim.allBoxes.length; i++) {
                if (i === anim.pickedSlot) {
                    continue;
                }
                const ob = anim.allBoxes[i];
                const dir = i < anim.pickedSlot ? -1 : 1;
                const drift = dir * easeOutCubic(t) * 26;
                const oa = (1 - t) * 0.55;
                uiDraw.drawRoundedRect(Rect(ob.x + drift, ob.y - easeOutCubic(t) * 8, ob.width, ob.height), 5, Color(15, 18, 26, Math.round(180 * oa)), 0.8, toColor(PALETTE.silkDim, 110 * oa));
            }

            // 选中卡微弹 + 朱砂孤印「契印」砸落
            const pop = 1 + (1 - easeOutCubic(t)) * 0.04;
            const sw = pb.width * pop;
            const sh = pb.height * pop;
            const sx = pcx - sw * 0.5;
            const sy = pcy - sh * 0.5;
            fillRadialGlow(uiGlow, pcx, pcy, sw * 0.72, sh * 0.62, toColor(PALETTE.rouge, 56 * (1 - t * 0.4)), Color(182, 58, 56, 0), 14);
            uiDraw.drawRoundedRect(Rect(sx, sy, sw, sh), 5, Color(34, 22, 27, 245), 1.8, toColor(PALETTE.rouge, 245));
            drawTalentGlyph(uiInkDraw, pcx, pcy + (anim.fromExpanded ? 24 : 0), anim.fromExpanded ? 22 : 12, anim.talentId, meta.accentCore, 0.96, PALETTE.textBright);
            ctx.texts.put("md", meta.title, pcx, pcy - (anim.fromExpanded ? 22 : 0), toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 4.0, 0.98, 0.10);

            // 朱砂孤印由大砸落定格
            const slam = 1 + Math.pow(1 - t, 2) * 0.55;
            drawLoneSeal(
                uiInkDraw,
                uiArt,
                ctx.texts,
                "rg_pick_seal",
                pcx + (anim.fromExpanded ? pb.width * 0.26 : pb.width * 0.34),
                pcy - (anim.fromExpanded ? pb.height * 0.22 : 0),
                26 * slam,
                50 * slam,
                "契",
                "印",
                PALETTE.sealRedBright,
                PALETTE.sealText,
                0.96,
                6,
            );
            return;
        }

        // 流墨归身阶段（0.24–0.56s）
        const t = clamp((anim.elapsed - anim.sealDuration) / Math.max(0.01, anim.absorbDuration), 0, 1);
        const dest = this.computeAbsorbTargetUi(ctx, rg, anim.targetKind);
        const ctrlX = (pcx + dest.x) * 0.5;
        const ctrlY = Math.max(pcy, dest.y) + 76;

        // 贝塞尔轨迹尾焰与 7 粒墨芒星屑
        const headT = easeInOutQuad(t);
        const samples = 10;
        let s = 0;
        let prevPt: Vec2.Type | undefined;
        for (s = 0; s <= samples; s++) {
            const u = Math.max(0, headT - (samples - s) * 0.032);
            const inv = 1 - u;
            const bx = inv * inv * pcx + 2 * inv * u * ctrlX + u * u * dest.x;
            const by = inv * inv * pcy + 2 * inv * u * ctrlY + u * u * dest.y;
            const pt = Vec2(bx, by);
            if (prevPt !== undefined) {
                const segA = (s / samples) * (1 - t * 0.35);
                uiGlow.drawSegment(prevPt, pt, 1.6 + (s / samples) * 2.4, toColor(meta.accentCore, Math.round(210 * segA)));
            }
            if (s % 2 === 1) {
                uiGlow.drawDot(pt, 2.0 + (s / samples) * 2.2, toColor(PALETTE.amberCore, Math.round(180 * (s / samples) * (1 - t * 0.3))));
            }
            prevPt = pt;
        }
        const invH = 1 - headT;
        const hx = invH * invH * pcx + 2 * invH * headT * ctrlX + headT * headT * dest.x;
        const hy = invH * invH * pcy + 2 * invH * headT * ctrlY + headT * headT * dest.y;
        fillRadialGlow(uiGlow, hx, hy, 22, 22, toColor(meta.accentCore, 96 * (1 - t * 0.3)), Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), 12);
        drawDiamond(uiInkDraw, hx, hy, 5.5, 5.5, toColor(PALETTE.textBright, 240));
    }

    private computeAbsorbTargetUi(ctx: FePluginContext, rg: RoguelikeSnapshot, target: TalentAbsorbTarget): { x: number; y: number } {
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const bx = 28 + safe.left;
        const hpY = ctx.uiH - 56 - safe.top;
        if (target === "hp") {
            return { x: bx + 44 + Math.min(5, rg.maxHp) * 52, y: hpY };
        }
        if (target === "gun") {
            const p = ctx.p;
            return {
                x: clamp(ctx.cam.sx(p.player.x + p.player.facing * 14) / ctx.uiScale, 80, ctx.uiW - 80),
                y: clamp(ctx.cam.sy(p.player.y + p.player.h * 0.62, p.player.depth) / ctx.uiScale, 80, ctx.uiH - 80),
            };
        }
        if (target === "shoulder") {
            const p = ctx.p;
            return {
                x: clamp(ctx.cam.sx(p.player.x) / ctx.uiScale, 80, ctx.uiW - 80),
                y: clamp(ctx.cam.sy(p.player.y + p.player.h * 0.72, p.player.depth) / ctx.uiScale, 80, ctx.uiH - 80),
            };
        }
        if (target === "satchel") {
            return { x: bx + 86, y: hpY - 68 };
        }
        return { x: bx + 64, y: hpY - 36 };
    }

    // ---------- 模块 E1：「险段告破」非阻塞行书流带 ----------

    private drawSegmentClearRibbon(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        safe: SafeInsets,
    ): void {
        const elapsed = SEGMENT_BANNER_DURATION - this.segmentBannerT;
        const fadeIn = clamp(elapsed / 0.24, 0, 1);
        const fadeOut = clamp(this.segmentBannerT / 0.36, 0, 1);
        const alpha = easeOutCubic(fadeIn) * fadeOut;
        if (alpha <= 0.01) {
            return;
        }
        const cx = ctx.uiW * 0.5;
        const cy = ctx.uiH - 134 - safe.top;
        drawSilkVeil(uiDraw, uiArt, "rg_seg_veil", cx, cy, 460, 74, PALETTE.inkWash, 0.78 * alpha, 2);
        drawMistCurve(uiArt, "rg_seg_mist", cx, cy, 420, 66, PALETTE.amber, 0.24 * alpha, 2);
        drawHairline(uiInkDraw, uiArt, "rg_seg_top", cx, cy + 32, 320, PALETTE.amberCore, 0.58 * alpha, true, 4);
        drawHairline(uiInkDraw, uiArt, "rg_seg_bot", cx, cy - 32, 280, PALETTE.silkDim, 0.44 * alpha, false, 4);
        fillRadialGlow(uiGlow, cx, cy + 6, 130, 34, toColor(PALETTE.amber, 26 * alpha), Color(214, 186, 146, 0), 12);

        ctx.texts.put("banner", this.segmentBannerHeadline, cx, cy + 9, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 8.0, 0.96 * alpha, 0.12);
        ctx.texts.put("xs", this.segmentBannerSub, cx, cy - 18, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.6, 0.92 * alpha, 0.08);
    }

    // ---------- 模块 E2：「折筹重整 · 残筹散墨」败局轮回过场 ----------

    private drawDeathRecapOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        snap: DeathRecapSnapshot,
    ): void {
        const elapsed = DEATH_RECAP_DURATION - this.deathRecapT;
        const fadeIn = clamp(elapsed / 0.26, 0, 1);
        const fadeOut = clamp(this.deathRecapT / 0.44, 0, 1);
        const alpha = easeOutCubic(fadeIn) * fadeOut;
        if (alpha <= 0.01) {
            return;
        }
        const cx = ctx.uiW * 0.5;
        const cy = ctx.uiH * 0.52;

        // 鸦青烟幕柔暗
        uiDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(8, 10, 16, Math.round(168 * alpha)));
        drawMistCurve(uiArt, "rg_recap_mist", cx, cy, 640, 140, PALETTE.rougeSoft, 0.24 * alpha, 1);
        fillRadialGlow(uiGlow, cx, cy + 20, 220, 110, toColor(PALETTE.rouge, 26 * alpha), Color(182, 58, 56, 0), 14);

        // 行书「折筹重整」（全部字形经 longcang-brush.ttf 覆盖）
        ctx.texts.put("banner", "折筹重整", cx, cy + 88, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 10.0, 0.96 * alpha, 0.12);
        drawHairline(uiInkDraw, uiArt, "rg_recap_line", cx, cy + 48, 360, PALETTE.rouge, 0.62 * alpha, true, 3);

        // 上一轮已习木筹化作散墨缓缓漂离消融
        const scatterT = clamp((elapsed - 0.22) / 1.15, 0, 1);
        const ids: string[] = [];
        for (const k in snap.ranks) {
            if (snap.ranks[k] > 0) {
                ids.push(k);
            }
        }
        if (ids.length > 0) {
            const step = 76;
            const startX = cx - ((ids.length - 1) * step) * 0.5;
            let i = 0;
            for (i = 0; i < ids.length; i++) {
                const tid = ids[i];
                const meta = resolveTalentVisual(tid);
                const dir = ids.length === 1 ? 0 : (i - (ids.length - 1) * 0.5);
                const dx = dir * easeOutCubic(scatterT) * 28;
                const dy = easeOutCubic(scatterT) * 24;
                const chipA = alpha * (1 - scatterT * 0.85);
                const ix = startX + i * step + dx;
                const iy = cy + 6 + dy;
                uiDraw.drawRoundedRect(Rect(ix - 24, iy - 18, 48, 36), 4, toColor(PALETTE.inkWash, 180 * chipA), 0.9, toColor(meta.accent, 150 * chipA));
                drawTalentGlyph(uiInkDraw, ix, iy, 12, tid, meta.accent, chipA, meta.accentCore);
                // 细微散墨屑点
                if (scatterT > 0.08) {
                    uiGlow.drawDot(Vec2(ix + dir * 10, iy + 14 + scatterT * 14), 2.0, toColor(PALETTE.silkDim, 140 * chipA));
                    uiGlow.drawDot(Vec2(ix - dir * 8, iy + 8 + scatterT * 20), 1.6, toColor(PALETTE.rouge, 130 * chipA));
                }
            }
        }

        const countText = snap.totalRanks > 0 ? ("曾习" + toChineseUpper(snap.totalRanks) + "筹") : "尚未择筹";
        const summary = "止步于「" + snap.stageName + "」 · " + countText + " · 筹散人安，重整再护";
        ctx.texts.put("sm", summary, cx, cy - 48, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.0, 0.94 * alpha, 0.08);
        ctx.texts.put("xs", "新一轮护送将自城外巷路再启", cx, cy - 82, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.2, 0.78 * alpha, 0.06);
    }

    // ---------- 模块 C：「行军札记」宋明宣纸对折构筑总览页 ----------

    private drawBuildLedger(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        rg: RoguelikeSnapshot,
        safe: SafeInsets,
    ): void {
        const appear = easeOutCubic(this.ledgerAnimT);
        const cx = ctx.uiW * 0.5;
        const pageW = Math.min(ctx.uiW - 96 - safe.left - safe.right, 880);
        const pageH = Math.min(ctx.uiH - 116 - safe.top - safe.bottom, 504);
        const px = cx - pageW * 0.5;
        const py = (ctx.uiH - pageH) * 0.5 + (1 - appear) * -14;
        const midY = py + pageH * 0.5;
        this.ledgerPanelBox = Rect(px, py, pageW, pageH);

        // 背景轻暗幕 + 宣纸底页（复用北塔登记簿与史话同源宣纸原语）
        uiDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(7, 9, 15, Math.round(188 * appear)));
        uiArt.tryPlace("ink_frame_mask", "rg_led_sh", cx, midY - 6, pageW + 52, pageH + 46, {
            color: toColor(PALETTE.voidDark), opacity: 0.84 * appear, layer: -1,
        });
        if (!uiArt.tryPlace("ink_song_paper", "rg_led_paper", cx, midY, pageW, pageH, { opacity: 0.98 * appear, layer: 1 })) {
            uiDraw.drawRect(Rect(px, py, pageW, pageH), toColor(PALETTE.xuanPaper, 248 * appear), 1.0, toColor(PALETTE.silkDim, 180 * appear));
        }
        fillRadialGlow(uiGlow, cx, midY + 36, 260, 140, Color(236, 224, 202, Math.round(16 * appear)), Color(236, 224, 202, 0), 14);

        // 明版双框朱丝栏 + 中缝对折线
        const inX = px + 36;
        const inY = py + 28;
        const inW = pageW - 72;
        const inH = pageH - 56;
        const redSilk = toColor(PALETTE.rouge, 118 * appear);
        const redFaint = toColor(PALETTE.rouge, 56 * appear);
        uiInkDraw.drawRect(Rect(inX, inY, inW, inH), Color(0, 0, 0, 0), 0.95, redSilk);
        uiInkDraw.drawRect(Rect(inX + 4, inY + 4, inW - 8, inH - 8), Color(0, 0, 0, 0), 0.55, redFaint);

        // 顶部书头
        const headY = inY + inH - 26;
        const routeZh = rg.routeTag === "drygoods" ? " · 布行暗渡" : (rg.routeTag === "outer" ? " · 外檐强行" : "");
        ctx.texts.put("lg", "行军札记", inX + 18, headY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 3.0, 0.96 * appear, 0);
        const metaInfo = "筹号 " + rg.seed + "  ·  用时 " + mmss(rg.ticks) + routeZh;
        ctx.texts.put("xs", metaInfo, inX + 158, headY - 2, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 1.0, 0.88 * appear, 0);

        // 右上「合卷」钮
        const closeW = 76;
        const closeH = 26;
        const closeRect = Rect(inX + inW - closeW - 14, headY - closeH * 0.5, closeW, closeH);
        this.ledgerCloseBox = closeRect;
        uiInkDraw.drawRect(closeRect, Color(168, 46, 44, Math.round(28 * appear)), 0.9, toColor(PALETTE.rouge, 185 * appear));
        ctx.texts.put("xs", "合卷", closeRect.x + closeW * 0.5, headY, toColor(PALETTE.rouge), 0.5, 0.5, TextAlign.Center, 1.4, 0.95 * appear, 0);
        uiInkDraw.drawSegment(Vec2(inX + 12, headY - 20), Vec2(inX + inW - 12, headY - 20), 0.85, redSilk);

        // 中缝折页朱丝双线
        const foldX = inX + inW * 0.48;
        uiInkDraw.drawSegment(Vec2(foldX - 3, inY + 12), Vec2(foldX - 3, headY - 26), 0.65, redFaint);
        uiInkDraw.drawSegment(Vec2(foldX + 3, inY + 12), Vec2(foldX + 3, headY - 26), 0.65, redFaint);

        // ===== 左页：此行舆图与兵备 =====
        const leftX = inX + 18;
        const leftW = foldX - leftX - 18;
        const secTopY = headY - 40;
        ctx.texts.put("sm", "此行舆图与兵备", leftX, secTopY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.6, 0.92 * appear, 0);

        // 1) 五段进程条
        const stY = secTopY - 34;
        const stages = rg.stages;
        if (stages.length > 0) {
            const sx0 = leftX + 14;
            const sx1 = leftX + leftW - 14;
            const step = stages.length > 1 ? (sx1 - sx0) / (stages.length - 1) : 0;
            uiInkDraw.drawSegment(Vec2(sx0, stY), Vec2(sx1, stY), 0.9, toColor(PALETTE.xuanInkSub, 130 * appear));
            let si = 0;
            for (si = 0; si < stages.length; si++) {
                const st = stages[si];
                const nx = sx0 + si * step;
                if (st.current) {
                    drawDiamond(uiInkDraw, nx, stY, 5.5, 5.5, toColor(PALETTE.rouge, 235 * appear));
                } else if (st.cleared) {
                    drawDiamond(uiInkDraw, nx, stY, 4.5, 4.5, toColor(PALETTE.xuanInk, 210 * appear));
                } else {
                    drawDiamond(uiInkDraw, nx, stY, 4.0, 4.0, Color(232, 227, 216, 255), 0.9, toColor(PALETTE.xuanInkSub, 150 * appear));
                }
                ctx.texts.put("xs", st.label, nx, stY - 18, toColor(st.current ? PALETTE.rouge : PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 0.2, (st.current ? 0.98 : 0.78) * appear, 0);
            }
        }

        // 2) 所执火铳卡片 + 迷你 3×3 换弹纹样预览
        const gunBoxY = stY - 142;
        const gunBoxH = 104;
        const wMeta = weaponMetaOf(rg.equippedWeapon);
        uiInkDraw.drawRect(Rect(leftX, gunBoxY, leftW, gunBoxH), Color(32, 30, 32, Math.round(14 * appear)), 0.85, redFaint);
        ctx.texts.put("sm", wMeta.name, leftX + 12, gunBoxY + gunBoxH - 20, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.2, 0.96 * appear, 0);
        ctx.texts.put("xs", "装填 " + rg.reloadTicksNow + " 拍  ·  体力 " + rg.hp + "/" + rg.maxHp, leftX + 12, gunBoxY + gunBoxH - 44, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.4, 0.88 * appear, 0);
        ctx.texts.put("xs", wMeta.desc, leftX + 12, gunBoxY + 26, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.2, 0.82 * appear, 0);

        // 右侧内嵌迷你 3×3 九宫格预览（与 reload_wheel.ts / craft_bench.ts 100% 同源）
        const gridCx = leftX + leftW - 44;
        const gridCy = gunBoxY + gunBoxH * 0.5;
        const gStep = 22;
        let gi = 0;
        for (gi = 0; gi < RELOAD_GRID.length; gi++) {
            const node = RELOAD_GRID[gi];
            const gx = gridCx + (node.col - 1) * gStep;
            const gy = gridCy + (node.row - 1) * gStep;
            const isEnhanced = (wMeta.effect === "light" && node.kind === "lamp")
                || (wMeta.effect === "echo" && node.kind === "bell");
            if (node.kind === "lamp" || node.kind === "bell") {
                drawReloadPatternGlyph(
                    uiInkDraw,
                    gx,
                    gy,
                    isEnhanced ? 8.0 : 6.2,
                    node.kind === "lamp" ? "light" : "echo",
                    isEnhanced ? PALETTE.rouge : PALETTE.xuanInkSub,
                    (isEnhanced ? 0.96 : 0.55) * appear,
                );
            } else {
                uiInkDraw.drawDot(Vec2(gx, gy), node.kind === "start" || node.kind === "target" ? 3.0 : 2.0, toColor(PALETTE.xuanInkSub, 150 * appear));
            }
        }

        // 3) 随身战备清点
        const invTitleY = gunBoxY - 22;
        ctx.texts.put("xs", "随身战备清点", leftX, invTitleY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.2, 0.88 * appear, 0);
        let drawnInv = 0;
        let ii = 0;
        for (ii = 0; ii < PICKUP_ORDER.length; ii++) {
            const k = PICKUP_ORDER[ii];
            const cnt = rg.supplies[k] ?? 0;
            if (cnt <= 0) {
                continue;
            }
            const col = drawnInv % 2;
            const row = Math.floor(drawnInv / 2);
            if (row >= 3) {
                break;
            }
            const ix = leftX + col * (leftW * 0.5);
            const iy = invTitleY - 26 - row * 28;
            const pm = pickupMetaOf(k);
            drawPickupGlyph(uiInkDraw, ix + 10, iy, 7.2, k, 0.92 * appear, PALETTE.xuanInk);
            ctx.texts.put("xs", pm.name + " ×" + cnt, ix + 24, iy, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.4, 0.90 * appear, 0);
            drawnInv += 1;
        }
        if (drawnInv === 0) {
            ctx.texts.put("xs", "行囊尚空，沿途可拾筹材与战备。", leftX, invTitleY - 28, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.78 * appear, 0);
        }

        // ===== 右页：已习本领谱 + 动态「行军雅号」孤印 =====
        const rightX = foldX + 20;
        const rightW = inX + inW - rightX - 18;
        ctx.texts.put("sm", "已习本领谱", rightX, secTopY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.6, 0.92 * appear, 0);

        const learned: string[] = [];
        for (const k in rg.ranks) {
            if ((rg.ranks[k] ?? 0) > 0) {
                learned.push(k);
            }
        }
        if (learned.length === 0) {
            ctx.texts.put("sm", "尚未择筹 · 途中整备可习军筹", rightX, secTopY - 56, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.8, 0.82 * appear, 0);
        } else {
            let li = 0;
            for (li = 0; li < learned.length && li < 5; li++) {
                const tid = learned[li];
                const rank = rg.ranks[tid] ?? 1;
                const meta = resolveTalentVisual(tid, rg);
                const rowY = secTopY - 46 - li * 56;
                uiInkDraw.drawRect(Rect(rightX, rowY - 22, rightW, 46), Color(32, 30, 32, Math.round(12 * appear)), 0.75, redFaint);
                drawTalentGlyph(uiInkDraw, rightX + 24, rowY + 1, 13, tid, PALETTE.xuanInk, 0.92 * appear, PALETTE.rouge);
                ctx.texts.put("sm", meta.title + " · " + rankChinese(rank) + "阶", rightX + 48, rowY + 10, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.0, 0.96 * appear, 0);
                ctx.texts.put("xs", meta.ledgerLine(rg, rank), rightX + 48, rowY - 10, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.4, 0.88 * appear, 0);
            }
        }

        // 右下落款：动态派生「行军雅号」与朱砂孤印（两行排布，留白舒展绝不贴字）
        const march = deriveMarchTitle(rg);
        const footY = inY + 46;
        uiInkDraw.drawSegment(Vec2(rightX, footY + 36), Vec2(rightX + rightW, footY + 36), 0.7, redFaint);
        ctx.texts.put("xs", "此行雅号", rightX, footY + 20, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 1.4, 0.82 * appear, 0);
        ctx.texts.put("md", "「" + march.title + "」", rightX - 4, footY - 2, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 2.2, 0.96 * appear, 0);
        ctx.texts.put("xs", march.subtitle, rightX + 4, footY - 24, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.8, 0.86 * appear, 0);
        drawLoneSeal(
            uiInkDraw,
            uiArt,
            ctx.texts,
            "rg_ledger_seal",
            rightX + rightW - 22,
            footY + 2,
            24,
            46,
            march.sealTop,
            march.sealBot,
            PALETTE.sealRed,
            PALETTE.sealText,
            0.94 * appear,
            5,
        );
    }
}
