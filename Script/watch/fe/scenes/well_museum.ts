/**
 * 《向西守望》Wave 2 · FE-06：双通关水井与现代抗日主题博物馆演出插件（E01–E02）。
 *
 * 设计红线（严格对表《wave2-04-06.md》《向西守望-游戏分镜稿》《向西守望-动画插入与演出规划》《向西守望-双线后端开发规划》）：
 * 1. 严格双通关门控（零误开放、零重复发奖）：
 *    - 仅当非试炼态、位于序章 `prologue` 且处于 `prologue-wait`（周戍进屋寻小满、尚未靠柜触发 P03 特写）的窗口，
 *      且同一正式档案满足 `childCleared && soldierCleared`（双结局均已正式通关）且 `museumPhase !== "locked"` 时，
 *      开放左侧侧灶通往后院深井的入口（世界坐标左侧 x≈34，位于寻柜镜头的另一侧，完全不干扰原寻柜路线）。
 *    - 新档、单通关（仅女/仅男，即使后端临时字段误置 artifactOwned）或已过靠柜窗口，均完全不渲染水光、不播滴水声。
 *    - 离馆（`museumPhase === "done"` 或 `museumSeen === true`）后再次回井仅作平静复查，绝不再发 `well_pickup`、不重复增发神器。
 * 2. 默认零引导（仅靠环境声光吸引）：
 *    - 井院入口仅靠后院滴水声（water 轨距离衰减）与暗处微弱冷白水光/涟漪引路；
 *    - 现代展厅西窗灯靠构图留白、破晓微光与可动旋轴剪影引路；
 *    - 仅当玩家在暂停菜单主动打开「按键辅助（assistHintsEnabled === true）」时显示轻量 `[E]` 提示。
 * 3. E01 井底反光匹配剪辑（Match Cut）：
 *    - 俯身井口，深黑井水中映出一盏明初不该亮的冷白灯，倒影精确叠合在指南针玻璃同一屏幕坐标 `(0.50, 0.54)`；
 *    - 拾取彩蛋武器「时间穿梭器」后，锁死同一屏幕反光坐标（偏差 0.00 px）无缝溶切至现代博物馆展柜玻璃上的同一点光。
 * 4. E02 现代抗日主题博物馆自由步行、西窗转灯与四镜同源补线袖口回柜：
 *    - 虚构纪念展厅克制、庄重、安静；入厅淡现现代时间与抗日纪念主题字幕，绝不锁步；
 *    - 恢复周戍自由步行（A/D 或方向键），行至玻璃柜前自动收起武器，远方响起一次孩子轻脚步回响；
 *    - 末厅留足安静步行余白，亲手转动西窗之灯 → 窗上映出明初宁村所井庭 → 仅留一句定稿台词「小满，外头天亮了。」；
 *    - 第一声轻叩响在现代展厅，隔约 0.42 秒第二声实木叩响落在明初厨柜板上，画面直接复用 `cuff_shots.ts` 导出的
 *      `drawPatchedCuff()` 与 `CUFF_PALETTE` 接回同一截补线青布袖口，交还寻柜任务。
 * 5. 中途退出续读与暂停冻结：
 *    - `onBindPlay` 按 `view.archive.museumPhase` 及续读快照精准恢复展厅坐标与收械状态；
 *    - 暂停态绝对冻结计时、步行、字幕与音频；切房/重试清空瞬时状态与循环音轨。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import {
    DualRouteContract,
    DualRouteSnapshot,
    FrontendIntent,
    MuseumPhase,
} from "Script/watch/fe/contract";
import {
    CUFF_PALETTE,
    drawPatchedCuff,
} from "Script/watch/fe/cutscenes/cuff_shots";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { adaptHintSentence } from "Script/watch/fe/ui/control_prompts";
import {
    PALETTE,
    drawHairline,
    drawSilkVeil,
    fillGradQuad,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    rgba,
    toColor,
} from "Script/watch/fe/theme";
import {
    computeCenteredSlideRect,
    computeFullscreenSlideRect,
    drawPixelSlidePlate,
    drawSlideFrameChrome,
} from "Script/watch/fe/renderer/slideshow";

export const WELL_WORLD_X = 430;
export const WELL_INTERACT_REACH = 46;
export const MATCH_CUT_ANCHOR_NX = 0.50;
export const MATCH_CUT_ANCHOR_NY = 0.54;
export const MUSEUM_HALL_WIDTH = 1360;
export const MUSEUM_ENTRY_X = 180;
export const MUSEUM_CASE_X = 600;
export const MUSEUM_LAMP_X = 1140;
export const MUSEUM_WALK_SPEED = 156;
export const MUSEUM_LINE_DAWN = "「小满，外头天亮了。」";
export const MUSEUM_HALL_TITLE = "现代 · 宁村海防抗战纪念展厅";
export const MUSEUM_HALL_SUBTITLE = "山河安然，守望未绝";

export const MUSEUM_TIMINGS = {
    wellReflectDuration: 3.2,
    wellPickupAt: 1.1,
    wellMatchCutStart: 1.9,
    hallIntroFadeIn: 0.55,
    hallIntroHold: 3.4,
    hallIntroFadeOut: 0.85,
    childEchoDelay: 0.52,
    lampTurnDuration: 3.8,
    lampReflectStart: 0.65,
    lampLineAt: 1.45,
    lampKnock1At: 3.15,
    returnCabinetDuration: 2.6,
    returnKnock2At: 0.42,
    returnFadeOutAt: 2.2,
};

const MUSEUM_AUDIO_ROOT = "assets/audio/museum/";
export const MUSEUM_AUDIO = {
    wellDripLoop: MUSEUM_AUDIO_ROOT + "well_drip_loop.wav",
    artifactPickup: MUSEUM_AUDIO_ROOT + "artifact_pickup.wav",
    matchCutTransition: MUSEUM_AUDIO_ROOT + "match_cut_transition.wav",
    hallAmbienceLoop: MUSEUM_AUDIO_ROOT + "hall_ambience_loop.wav",
    hallFootstep: MUSEUM_AUDIO_ROOT + "hall_footstep.wav",
    weaponHolster: MUSEUM_AUDIO_ROOT + "weapon_holster.wav",
    childStepsEcho: MUSEUM_AUDIO_ROOT + "child_steps_echo.wav",
    lampTurn: MUSEUM_AUDIO_ROOT + "lamp_turn.wav",
    knockHallFirst: MUSEUM_AUDIO_ROOT + "knock_hall_first.wav",
    knockCabinetSecond: MUSEUM_AUDIO_ROOT + "knock_cabinet_second.wav",
    lineDawn: MUSEUM_AUDIO_ROOT + "line_dawn.wav",
};

const LOOP_WELL_DRIP = "fe06_well_drip";
const LOOP_HALL_AMBIENCE = "fe06_hall_ambience";

export interface WellMuseumResumeState {
    phase: MuseumPhase;
    hallWalkX: number;
    hallCamX: number;
    hallFacing: number;
    holstered: boolean;
    childEchoPlayed: boolean;
    reflectElapsed: number;
    lampElapsed: number;
    returnElapsed: number;
    artifactGrantCount: number;
}

export interface WellMuseumDebugState {
    gateOpen: boolean;
    gateBlockedReason: string;
    wellWorldX: number;
    nearWell: boolean;
    museumPhase: MuseumPhase;
    visualMode: string;
    reflectElapsed: number;
    reflectProgress: number;
    matchCutProgress: number;
    wellAnchorX: number;
    wellAnchorY: number;
    glassAnchorX: number;
    glassAnchorY: number;
    matchCutAnchorDeltaPx: number;
    hallWalkX: number;
    hallCamX: number;
    holstered: boolean;
    childEchoPlayed: boolean;
    nearLamp: boolean;
    lampElapsed: number;
    lampTurnProgress: number;
    lineDawnShown: boolean;
    knock1Played: boolean;
    knock2Played: boolean;
    returnElapsed: number;
    cuffReusedFromSharedPalette: boolean;
    cuffProgress: number;
    artifactGrantCount: number;
    revisitCalmCount: number;
    resumeRestoreCount: number;
    lastResumePhase: MuseumPhase;
    lastResumeWalkX: number;
    pausedFrozen: boolean;
}

interface SimulatedMuseumInput {
    moveX?: number;
    interact?: boolean;
}

function clamp(v: number, lo: number, hi: number): number {
    return Math.max(lo, Math.min(hi, v));
}

function clamp01(v: number): number {
    return clamp(v, 0, 1);
}

function smoothstep(edge0: number, edge1: number, x: number): number {
    if (edge1 <= edge0) {
        return x >= edge1 ? 1 : 0;
    }
    const t = clamp01((x - edge0) / (edge1 - edge0));
    return t * t * (3 - 2 * t);
}

function drawEllipseRing(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    fillCol: Color.Type,
    borderWidth: number,
    borderCol: Color.Type,
    segments: number = 28,
): void {
    if (rx <= 0.5 || ry <= 0.5) {
        return;
    }
    const pts: Vec2.Type[] = [];
    const step = (Math.PI * 2) / segments;
    let i = 0;
    for (i = 0; i < segments; i++) {
        const a = i * step;
        pts.push(Vec2(cx + Math.cos(a) * rx, cy + Math.sin(a) * ry));
    }
    draw.drawPolygon(pts, fillCol, borderWidth, borderCol);
}

function drawCircleRing(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    r: number,
    fillCol: Color.Type,
    borderWidth: number,
    borderCol: Color.Type,
    segments: number = 28,
): void {
    drawEllipseRing(draw, cx, cy, r, r, fillCol, borderWidth, borderCol, segments);
}

function asRecord(v: unknown): Record<string, unknown> | undefined {
    if (v !== undefined && typeof v === "object") {
        return v as Record<string, unknown>;
    }
    return undefined;
}

function readNum(rec: Record<string, unknown> | undefined, key: string): number | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const val = rec[key];
    return typeof val === "number" ? val : undefined;
}

function readBool(rec: Record<string, unknown> | undefined, key: string): boolean | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const val = rec[key];
    return typeof val === "boolean" ? val : undefined;
}

function resolveRuntimeContract(injected?: DualRouteContract): DualRouteContract | undefined {
    if (injected !== undefined) {
        return injected;
    }
    const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
    const loaded = g.package !== undefined ? g.package.loaded : undefined;
    if (loaded === undefined) {
        return undefined;
    }
    const rawFe = loaded["watch.fe"];
    if (rawFe !== undefined && typeof rawFe === "object") {
        const c = (rawFe as Record<string, unknown>)["contract"];
        if (c !== undefined && typeof c === "object") {
            return c as DualRouteContract;
        }
    }
    return undefined;
}

function isPrologueIntroBlocking(): boolean {
    const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
    const loaded = g.package !== undefined ? g.package.loaded : undefined;
    if (loaded === undefined) {
        return false;
    }
    const rawFe = loaded["watch.fe"];
    if (rawFe === undefined || typeof rawFe !== "object") {
        return false;
    }
    const prologue = (rawFe as Record<string, unknown>)["prologue"];
    if (prologue === undefined || typeof prologue !== "object") {
        return false;
    }
    const fn = (prologue as Record<string, unknown>)["getSnapshot"];
    if (typeof fn !== "function") {
        return false;
    }
    const snap = asRecord((fn as (self: unknown) => unknown)(prologue));
    if (readBool(snap, "blocksPlayerControl") === true) {
        return true;
    }
    // P02 逃柜与入柜阶段同样属于小满独自避难窗口，绝不提前露出周戍井院入口
    const stage = snap !== undefined && typeof snap["stage"] === "string" ? (snap["stage"] as string) : "idle";
    return stage === "p02_escape" || stage === "p02_hidden";
}

function isActiveMuseumPhase(phase: MuseumPhase): boolean {
    return phase === "well_reflect"
        || phase === "hall_walk"
        || phase === "lamp_turn"
        || phase === "return_cabinet";
}

export class WellMuseumPlugin implements FeRenderPlugin {
    readonly id = "fe-06-well-museum";

    private injectedContract: DualRouteContract | undefined;
    private animTime = 0;
    private prevPhase: MuseumPhase = "locked";
    private roomSessionId = 0;
    private rehearsal = false;

    // 门控与井口世界引导
    private gateOpen = false;
    private gateBlockedReason = "locked";
    private wellWorldX = WELL_WORLD_X;
    private caseX = MUSEUM_CASE_X;
    private lampX = MUSEUM_LAMP_X;
    private nearWell = false;
    private revisitCalmTimer = 0;
    private revisitCalmCount = 0;

    // E01 井底反光匹配剪辑
    private reflectElapsed = 0;
    private wellAnchorX = 640;
    private wellAnchorY = 388.8;
    private glassAnchorX = 640;
    private glassAnchorY = 388.8;
    private enterHallSubmitted = false;

    // E02 现代纪念展厅步行与转灯
    private hallWalkX = MUSEUM_ENTRY_X;
    private hallCamX = MUSEUM_ENTRY_X;
    private hallFacing = 1;
    private hallWalkAnim = 0;
    private hallMoving = false;
    private hallFootstepTimer = 0;
    private hallIntroElapsed = 0;
    private holstered = false;
    private childEchoCountdown = -1;
    private childEchoPlayed = false;
    private childEchoVisualT = 0;
    private nearLamp = false;

    private lampElapsed = 0;
    private lineDawnShown = false;
    private knock1Played = false;
    private knock1VisualT = 0;
    private beginReturnSubmitted = false;

    // E02 声画回切至明初补线袖口
    private returnElapsed = 0;
    private knock2Played = false;
    private knock2VisualT = 0;
    private returnCompleteSubmitted = false;

    // 跨切房续读与发奖幂等计数
    private artifactGrantCount = 0;
    private savedResume: WellMuseumResumeState | undefined;
    private resumeRestoreCount = 0;
    private lastResumePhase: MuseumPhase = "locked";
    private lastResumeWalkX = MUSEUM_ENTRY_X;
    private lastVisualMode = "pixel";
    private lastPaused = false;
    private wellDripPlaying = false;
    private hallAmbiencePlaying = false;
    private liveReflectDoneInMuseumRoom = false;
    private simInput: SimulatedMuseumInput | undefined;

    constructor(contract?: DualRouteContract) {
        this.injectedContract = contract;
    }

    private syncRuntimeHook(): void {
        const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
        const loaded = g.package !== undefined ? g.package.loaded : undefined;
        if (loaded === undefined) {
            return;
        }
        const rawFe = loaded["watch.fe"];
        if (rawFe !== undefined && typeof rawFe === "object") {
            const watchFe = rawFe as Record<string, unknown>;
            if (watchFe["wellMuseum"] !== this) {
                watchFe["wellMuseum"] = this;
            }
        }
    }

    /** 供自动化验证脚本注入单帧模拟输入（移动 / 交互），消费后自动清零 */
    queueSimulatedInput(sim: SimulatedMuseumInput): void {
        this.simInput = {
            moveX: sim.moveX,
            interact: sim.interact,
        };
    }

    /** 导出当前馆内续读位置（用于演示/验证中途退出续读恢复） */
    exportResumeState(): WellMuseumResumeState {
        return {
            phase: this.prevPhase,
            hallWalkX: this.hallWalkX,
            hallCamX: this.hallCamX,
            hallFacing: this.hallFacing,
            holstered: this.holstered,
            childEchoPlayed: this.childEchoPlayed,
            reflectElapsed: this.reflectElapsed,
            lampElapsed: this.lampElapsed,
            returnElapsed: this.returnElapsed,
            artifactGrantCount: this.artifactGrantCount,
        };
    }

    /** 显式载入中途退出续读位置（正式模式也可由后端快照字段自动恢复） */
    restoreResumeState(snap: Partial<WellMuseumResumeState>): void {
        if (snap.phase !== undefined) {
            this.prevPhase = snap.phase;
            this.lastResumePhase = snap.phase;
        }
        if (snap.hallWalkX !== undefined) {
            this.hallWalkX = clamp(snap.hallWalkX, 90, MUSEUM_HALL_WIDTH - 90);
            this.lastResumeWalkX = this.hallWalkX;
        }
        if (snap.hallCamX !== undefined) {
            this.hallCamX = snap.hallCamX;
        } else {
            this.hallCamX = this.hallWalkX;
        }
        if (snap.hallFacing !== undefined) {
            this.hallFacing = snap.hallFacing >= 0 ? 1 : -1;
        }
        if (snap.holstered !== undefined) {
            this.holstered = snap.holstered;
        }
        if (snap.childEchoPlayed !== undefined) {
            this.childEchoPlayed = snap.childEchoPlayed;
        }
        if (snap.reflectElapsed !== undefined) {
            this.reflectElapsed = Math.max(0, snap.reflectElapsed);
        }
        if (snap.lampElapsed !== undefined) {
            this.lampElapsed = Math.max(0, snap.lampElapsed);
        }
        if (snap.returnElapsed !== undefined) {
            this.returnElapsed = Math.max(0, snap.returnElapsed);
        }
        if (snap.artifactGrantCount !== undefined) {
            this.artifactGrantCount = Math.max(0, snap.artifactGrantCount);
        }
        this.savedResume = this.exportResumeState();
        this.resumeRestoreCount += 1;
    }

    /** 重置本地续读与计数器（供多场景自动化测试隔离） */
    resetSessionCounters(): void {
        this.artifactGrantCount = 0;
        this.revisitCalmCount = 0;
        this.revisitCalmTimer = 0;
        this.savedResume = undefined;
        this.resumeRestoreCount = 0;
        this.lastResumePhase = "locked";
        this.lastResumeWalkX = MUSEUM_ENTRY_X;
    }

    /** 供排演与截帧直接定位到展厅中任意坐标（不改正式档案） */
    setHallWalkPosition(x: number, holstered?: boolean): void {
        this.hallWalkX = clamp(x, 90, MUSEUM_HALL_WIDTH - 90);
        this.hallCamX = this.hallWalkX;
        if (holstered !== undefined) {
            this.holstered = holstered;
        } else if (this.hallWalkX >= this.caseX - 85) {
            this.holstered = true;
        }
        this.savedResume = this.exportResumeState();
    }

    /** 供排演截帧定格到 E01/E02 指定秒数 */
    seekStageTime(stage: "well_reflect" | "lamp_turn" | "return_cabinet", seconds: number): void {
        const s = Math.max(0, seconds);
        if (stage === "well_reflect") {
            this.reflectElapsed = Math.min(MUSEUM_TIMINGS.wellReflectDuration, s);
        } else if (stage === "lamp_turn") {
            this.lampElapsed = Math.min(MUSEUM_TIMINGS.lampTurnDuration, s);
            this.lineDawnShown = this.lampElapsed >= MUSEUM_TIMINGS.lampLineAt;
        } else if (stage === "return_cabinet") {
            this.returnElapsed = Math.min(MUSEUM_TIMINGS.returnCabinetDuration, s);
        }
    }

    getDebugState(): WellMuseumDebugState {
        const reflectProg = clamp01(this.reflectElapsed / MUSEUM_TIMINGS.wellReflectDuration);
        const matchStart = MUSEUM_TIMINGS.wellMatchCutStart;
        const matchSpan = Math.max(0.01, MUSEUM_TIMINGS.wellReflectDuration - matchStart);
        const matchProg = this.reflectElapsed <= matchStart
            ? 0
            : clamp01((this.reflectElapsed - matchStart) / matchSpan);
        const lampTurnProg = clamp01(this.lampElapsed / 1.15);
        const cuffStart = MUSEUM_TIMINGS.returnKnock2At;
        const cuffSpan = Math.max(0.01, MUSEUM_TIMINGS.returnFadeOutAt - cuffStart);
        const cuffProg = this.returnElapsed <= cuffStart
            ? 0
            : clamp01((this.returnElapsed - cuffStart) / cuffSpan);
        const dx = this.glassAnchorX - this.wellAnchorX;
        const dy = this.glassAnchorY - this.wellAnchorY;
        return {
            gateOpen: this.gateOpen,
            gateBlockedReason: this.gateBlockedReason,
            wellWorldX: this.wellWorldX,
            nearWell: this.nearWell,
            museumPhase: this.prevPhase,
            visualMode: this.lastVisualMode,
            reflectElapsed: this.reflectElapsed,
            reflectProgress: reflectProg,
            matchCutProgress: matchProg,
            wellAnchorX: this.wellAnchorX,
            wellAnchorY: this.wellAnchorY,
            glassAnchorX: this.glassAnchorX,
            glassAnchorY: this.glassAnchorY,
            matchCutAnchorDeltaPx: Math.sqrt(dx * dx + dy * dy),
            hallWalkX: this.hallWalkX,
            hallCamX: this.hallCamX,
            holstered: this.holstered,
            childEchoPlayed: this.childEchoPlayed,
            nearLamp: this.nearLamp,
            lampElapsed: this.lampElapsed,
            lampTurnProgress: lampTurnProg,
            lineDawnShown: this.lineDawnShown,
            knock1Played: this.knock1Played,
            knock2Played: this.knock2Played,
            returnElapsed: this.returnElapsed,
            cuffReusedFromSharedPalette: true,
            cuffProgress: cuffProg,
            artifactGrantCount: this.artifactGrantCount,
            revisitCalmCount: this.revisitCalmCount,
            resumeRestoreCount: this.resumeRestoreCount,
            lastResumePhase: this.lastResumePhase,
            lastResumeWalkX: this.lastResumeWalkX,
            pausedFrozen: this.lastPaused,
        };
    }

    onBindPlay(p: Play, view: DualRouteSnapshot): void {
        this.syncRuntimeHook();
        if (view.isRehearsal !== this.rehearsal) {
            this.savedResume = undefined;
        }
        this.rehearsal = view.isRehearsal;
        const museum = view.isRehearsal ? undefined : p.room.story?.museum;
        this.caseX = museum === undefined ? MUSEUM_CASE_X : museum.cabinetX - p.ox;
        this.lampX = museum === undefined ? MUSEUM_LAMP_X : museum.lampX - p.ox;
        this.animTime = 0;
        this.revisitCalmTimer = 0;
        this.childEchoVisualT = 0;
        this.knock1VisualT = 0;
        this.knock2VisualT = 0;
        this.wellDripPlaying = false;
        this.hallAmbiencePlaying = false;
        this.enterHallSubmitted = false;
        this.beginReturnSubmitted = false;
        this.returnCompleteSubmitted = false;
        this.liveReflectDoneInMuseumRoom = false;
        this.simInput = undefined;

        const phase = view.archive.museumPhase;
        this.prevPhase = phase;
        this.lastVisualMode = view.visualMode;

        // 读取可选后端井口坐标（兼容 C 单 segment-relative Play.wellX = 430）
        // 排练态也可能绑定真实 Play（fe06 演示档），此时仍以 Play.wellX 为准；仅在无 Play 数据时回落 WELL_WORLD_X。
        const pRec = asRecord(p);
        const backendWellX = readNum(pRec, "wellX");
        this.wellWorldX = backendWellX !== undefined ? (p.ox + backendWellX) : (p.ox + WELL_WORLD_X);
        this.hallMoving = false;

        // 根据双通关档案校准神器计数（双通关且已持有神器时至少为 1；未持则归 0）
        if (view.archive.childCleared && view.archive.soldierCleared && view.archive.artifactOwned) {
            if (this.artifactGrantCount < 1) {
                this.artifactGrantCount = 1;
            }
        } else if (!view.archive.artifactOwned) {
            this.artifactGrantCount = 0;
        }

        // 中途退出续读恢复：当读档/重绑定后仍处于馆内任一活跃阶段时，恢复精确展厅位置与阶段进度
        if (isActiveMuseumPhase(phase)) {
            const runRec = view.isRehearsal ? undefined : asRecord(p.run);
            const archRec = asRecord(pRec !== undefined ? pRec["archive"] : undefined)
                ?? asRecord(runRec !== undefined ? runRec["archive"] : undefined);
            const backendWalkX = readNum(archRec, "museumWalkX") ?? readNum(pRec, "museumWalkX");
            const backendHolstered = readBool(archRec, "museumHolstered") ?? readBool(pRec, "museumHolstered");
            const backendChildEcho = readBool(archRec, "museumChildEchoPlayed") ?? readBool(pRec, "museumChildEchoPlayed");

            if (this.savedResume !== undefined && this.savedResume.phase === phase) {
                this.hallWalkX = backendWalkX !== undefined ? clamp(backendWalkX, 90, MUSEUM_HALL_WIDTH - 90) : this.savedResume.hallWalkX;
                this.hallCamX = this.hallWalkX;
                this.hallFacing = this.savedResume.hallFacing;
                this.holstered = backendHolstered ?? this.savedResume.holstered;
                this.childEchoPlayed = backendChildEcho ?? this.savedResume.childEchoPlayed;
                this.reflectElapsed = this.savedResume.reflectElapsed;
                this.lampElapsed = this.savedResume.lampElapsed;
                this.returnElapsed = this.savedResume.returnElapsed;
            } else {
                this.resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho);
            }
            this.resumeRestoreCount += 1;
            this.lastResumePhase = phase;
            this.lastResumeWalkX = this.hallWalkX;
        } else {
            // 非馆内阶段：彻底清理旧瞬时展厅态，确保切房/新档/离馆无残留
            this.reflectElapsed = 0;
            this.lampElapsed = 0;
            this.returnElapsed = 0;
            this.hallIntroElapsed = 0;
            this.hallWalkX = MUSEUM_ENTRY_X;
            this.hallCamX = MUSEUM_ENTRY_X;
            this.hallFacing = 1;
            this.holstered = false;
            this.childEchoCountdown = -1;
            this.childEchoPlayed = false;
            this.lineDawnShown = false;
            this.knock1Played = false;
            this.knock2Played = false;
            if (phase === "locked" || phase === "well_open") {
                this.savedResume = undefined;
            }
        }
    }

    private resetPhaseTimersForEntry(
        phase: MuseumPhase,
        backendWalkX?: number,
        backendHolstered?: boolean,
        backendChildEcho?: boolean,
    ): void {
        if (phase === "well_reflect") {
            this.reflectElapsed = 0;
            this.enterHallSubmitted = false;
            return;
        }
        if (phase === "hall_walk") {
            this.hallWalkX = backendWalkX !== undefined ? clamp(backendWalkX, 90, MUSEUM_HALL_WIDTH - 90) : MUSEUM_ENTRY_X;
            this.hallCamX = this.hallWalkX;
            this.hallFacing = 1;
            this.hallIntroElapsed = backendWalkX !== undefined && backendWalkX > 260 ? 5.0 : 0;
            this.holstered = backendHolstered ?? (this.hallWalkX >= this.caseX - 85);
            this.childEchoPlayed = backendChildEcho ?? (this.hallWalkX >= this.caseX + 120);
            this.childEchoCountdown = -1;
            return;
        }
        if (phase === "lamp_turn") {
            this.hallWalkX = backendWalkX !== undefined ? clamp(backendWalkX, 90, MUSEUM_HALL_WIDTH - 90) : this.lampX - 36;
            this.hallCamX = this.hallWalkX;
            this.hallFacing = 1;
            this.holstered = true;
            this.childEchoPlayed = true;
            this.lampElapsed = 0;
            this.lineDawnShown = false;
            this.knock1Played = false;
            this.beginReturnSubmitted = false;
            return;
        }
        if (phase === "return_cabinet") {
            this.returnElapsed = 0;
            this.knock2Played = false;
            this.returnCompleteSubmitted = false;
        }
    }

    private evaluateGate(p: Play, view: DualRouteSnapshot): { open: boolean; reason: string } {
        if (p.run.trial !== undefined) {
            return { open: false, reason: "trial_mode" };
        }
        if (p.room.key !== "prologue") {
            return { open: false, reason: "not_prologue" };
        }
        if (p.phase !== "prologue-wait" && (p.phase as string) !== "prologue-well") {
            return { open: false, reason: "after_cabinet_window" };
        }
        if (isPrologueIntroBlocking()) {
            return { open: false, reason: "prologue_intro_active" };
        }
        // 严格双通关门控：必须同一档案同时完成留灯与团圆（严禁单凭 artifactOwned 放开）
        if (!view.archive.childCleared || !view.archive.soldierCleared) {
            return { open: false, reason: "requires_both_clear" };
        }
        if (view.archive.museumPhase === "locked") {
            return { open: false, reason: "phase_locked" };
        }
        return { open: true, reason: "ok" };
    }

    private submitMuseumIntent(p: Play, target: string): boolean {
        const contract = resolveRuntimeContract(this.injectedContract);
        if (contract === undefined) {
            return false;
        }
        const intent: FrontendIntent = { kind: "museumInteract", target };
        return contract.submitIntent(p, intent);
    }

    private syncLoops(ctx: FePluginContext, wantWellDrip: boolean, dripVolume: number, wantHallAmbience: boolean): void {
        if (wantWellDrip) {
            ctx.audio.playLoop(LOOP_WELL_DRIP, "water", MUSEUM_AUDIO.wellDripLoop, dripVolume, ctx.p.ticks);
            this.wellDripPlaying = true;
        } else if (this.wellDripPlaying) {
            ctx.audio.stopLoop(LOOP_WELL_DRIP);
            this.wellDripPlaying = false;
        }

        if (wantHallAmbience) {
            ctx.audio.playLoop(LOOP_HALL_AMBIENCE, "ambience", MUSEUM_AUDIO.hallAmbienceLoop, 0.34, ctx.p.ticks);
            this.hallAmbiencePlaying = true;
        } else if (this.hallAmbiencePlaying) {
            ctx.audio.stopLoop(LOOP_HALL_AMBIENCE);
            this.hallAmbiencePlaying = false;
        }
    }

    update(ctx: FePluginContext): void {
        this.syncRuntimeHook();
        const p = ctx.p;
        const view = ctx.view;
        const phase = view.archive.museumPhase;
        if (view.isRehearsal !== this.rehearsal) {
            this.syncLoops(ctx, false, 0, false);
            this.onBindPlay(p, view);
        }
        this.roomSessionId = ctx.events.roomSessionId;
        this.lastVisualMode = view.visualMode;
        this.lastPaused = ctx.paused;

        // 反光匹配剪辑双锚点始终锁死于同一 UI 逻辑坐标（0.00 px 偏移）
        this.wellAnchorX = ctx.uiW * MATCH_CUT_ANCHOR_NX;
        this.wellAnchorY = ctx.uiH * MATCH_CUT_ANCHOR_NY;
        this.glassAnchorX = ctx.uiW * MATCH_CUT_ANCHOR_NX;
        this.glassAnchorY = ctx.uiH * MATCH_CUT_ANCHOR_NY;

        // 消费一次性模拟输入（同时读取 input.frameInteractPressed，避免模拟步 endStep() 提前清掉边沿）
        const sim = this.simInput;
        this.simInput = undefined;
        const interactPressed = ctx.input.interact.pressed
            || ctx.input.frameInteractPressed
            || (sim !== undefined && sim.interact === true);
        const moveX = sim !== undefined && sim.moveX !== undefined ? sim.moveX : ctx.input.moveX;

        // 阶段变更时初始化对应子阶段
        if (phase !== this.prevPhase) {
            const wasActive = isActiveMuseumPhase(this.prevPhase);
            this.prevPhase = phase;
            if (isActiveMuseumPhase(phase)) {
                if (phase === "well_reflect") {
                    this.resetPhaseTimersForEntry("well_reflect");
                    if (view.archive.artifactOwned && this.artifactGrantCount < 1) {
                        this.artifactGrantCount = 1;
                    }
                } else if (phase === "hall_walk" && !wasActive) {
                    this.resetPhaseTimersForEntry("hall_walk");
                } else if (phase === "hall_walk" && wasActive) {
                    this.hallWalkX = MUSEUM_ENTRY_X;
                    this.hallCamX = MUSEUM_ENTRY_X;
                    this.hallFacing = 1;
                    this.hallIntroElapsed = 0;
                    this.holstered = false;
                    this.childEchoPlayed = false;
                    this.childEchoCountdown = -1;
                } else if (phase === "lamp_turn") {
                    this.resetPhaseTimersForEntry("lamp_turn", this.hallWalkX, true, this.childEchoPlayed);
                } else if (phase === "return_cabinet") {
                    this.resetPhaseTimersForEntry("return_cabinet");
                }
            } else if (phase === "done") {
                this.savedResume = undefined;
            }
        }

        const gate = this.evaluateGate(p, view);
        this.gateOpen = gate.open;
        this.gateBlockedReason = gate.reason;
        this.nearWell = gate.open && Math.abs(p.player.x - this.wellWorldX) <= WELL_INTERACT_REACH;

        // 暂停态严格冻结全部演出计时、步行坐标与声效推进
        if (ctx.paused) {
            return;
        }

        const wdt = Math.max(0, ctx.worldDt);
        const udt = Math.max(0, ctx.uiDt);
        this.animTime += wdt;

        if (this.revisitCalmTimer > 0) {
            this.revisitCalmTimer = Math.max(0, this.revisitCalmTimer - wdt);
        }
        if (this.childEchoVisualT > 0) {
            this.childEchoVisualT = Math.max(0, this.childEchoVisualT - udt);
        }
        if (this.knock1VisualT > 0) {
            this.knock1VisualT = Math.max(0, this.knock1VisualT - wdt);
        }
        if (this.knock2VisualT > 0) {
            this.knock2VisualT = Math.max(0, this.knock2VisualT - wdt);
        }

        // 1. 井院未进馆阶段（well_open / done 复查）
        if (view.visualMode !== "museum") {
            const wantDrip = gate.open && phase === "well_open" && !view.archive.museumSeen;
            const dist = Math.abs(p.player.x - this.wellWorldX);
            const dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46);
            this.syncLoops(ctx, wantDrip, dripVol, false);

            if (gate.open && this.nearWell && interactPressed) {
                const liveNeedsSecondEnter = !view.isRehearsal
                    && p.room.key === "prologue"
                    && view.archive.artifactOwned
                    && !view.archive.museumSeen;
                const alreadyAwarded = !liveNeedsSecondEnter
                    && (view.archive.museumSeen
                        || phase === "done"
                        || (view.archive.artifactOwned && this.artifactGrantCount >= 1));
                if ((phase === "well_open" || liveNeedsSecondEnter) && !alreadyAwarded) {
                    this.submitMuseumIntent(p, "well_pickup");
                } else {
                    // 离馆后回井复查：仅呈平静水纹，不重复发奖也不强制再次传送
                    this.revisitCalmTimer = 1.4;
                    this.revisitCalmCount += 1;
                }
            }
            return;
        }

        // 2. E01：井底俯身 + 拾取「时间穿梭器」 + 同坐标反光匹配剪辑（well_reflect）
        const effectivePhase: MuseumPhase = (p.room.key === "museum" && phase === "well_reflect" && this.liveReflectDoneInMuseumRoom)
            ? "hall_walk"
            : phase;

        if (effectivePhase === "well_reflect") {
            const dripVol = clamp(0.44 * (1 - smoothstep(MUSEUM_TIMINGS.wellMatchCutStart, MUSEUM_TIMINGS.wellReflectDuration, this.reflectElapsed)), 0, 0.44);
            this.syncLoops(ctx, dripVol > 0.03, dripVol, false);

            if (wdt > 0) {
                this.reflectElapsed += wdt;
            }
            if (this.reflectElapsed >= MUSEUM_TIMINGS.wellPickupAt) {
                if (this.artifactGrantCount < 1) {
                    this.artifactGrantCount = 1;
                }
                ctx.audio.playOnce(
                    "fe06:e01:pickup:" + this.roomSessionId,
                    "sfx",
                    MUSEUM_AUDIO.artifactPickup,
                    0.86,
                    "museum:e01:artifact_pickup",
                    p.ticks,
                );
            }
            if (this.reflectElapsed >= MUSEUM_TIMINGS.wellMatchCutStart) {
                ctx.audio.playOnce(
                    "fe06:e01:matchcut:" + this.roomSessionId,
                    "ambience",
                    MUSEUM_AUDIO.matchCutTransition,
                    0.78,
                    "museum:e01:match_cut",
                    p.ticks,
                );
            }
            this.savedResume = this.exportResumeState();
            if (this.reflectElapsed >= MUSEUM_TIMINGS.wellReflectDuration && !this.enterHallSubmitted) {
                this.enterHallSubmitted = true;
                if (p.room.key === "museum") {
                    this.liveReflectDoneInMuseumRoom = true;
                }
                this.submitMuseumIntent(p, "enter_hall");
                const contract = resolveRuntimeContract(this.injectedContract);
                if (contract !== undefined && contract.isRehearsal()) {
                    contract.enterMockMuseum("hall_walk");
                }
            }
            return;
        }

        // 3. E02：现代抗日主题博物馆自由步行展厅（hall_walk）
        if (effectivePhase === "hall_walk") {
            this.syncLoops(ctx, false, 0, true);
            this.hallIntroElapsed += udt;

            // 若后端在正式模式下驱动 museumWalkX 或独立 MUSEUM_ROOM（room.key === "museum"）的 player.x，优先同步；
            // 否则由自由步行输入平滑推进
            const pRec = view.isRehearsal ? undefined : asRecord(p);
            const backendWalkX = readNum(pRec, "museumWalkX")
                ?? (!view.isRehearsal && p.room.key === "museum" ? (p.player.x - p.ox) : undefined);
            this.hallMoving = false;
            const previousX = this.hallWalkX;
            if (backendWalkX !== undefined) {
                this.hallWalkX = clamp(backendWalkX, 90, MUSEUM_HALL_WIDTH - 90);
            } else if (udt > 0 && Math.abs(moveX) > 0.05) {
                this.hallWalkX = clamp(this.hallWalkX + moveX * MUSEUM_WALK_SPEED * udt, 90, MUSEUM_HALL_WIDTH - 90);
            }
            const delta = this.hallWalkX - previousX;
            if (Math.abs(delta) > 0.01) {
                this.hallFacing = delta >= 0 ? 1 : -1;
                this.hallWalkAnim += udt * 8.5;
                this.hallMoving = true;
                this.hallFootstepTimer += udt;
                if (this.hallFootstepTimer >= 0.46) {
                    this.hallFootstepTimer = 0;
                    ctx.audio.playOnce(
                        "fe06:e02:step:" + this.roomSessionId + ":" + Math.floor(this.hallWalkAnim * 2),
                        "sfx",
                        MUSEUM_AUDIO.hallFootstep,
                        0.46,
                        "museum:e02:footstep",
                        p.ticks,
                    );
                }
            } else {
                this.hallFootstepTimer = Math.min(this.hallFootstepTimer, 0.22);
            }

            // 平滑相机跟随展厅步行
            const camFollow = Math.min(1, udt * 5.2);
            this.hallCamX += (this.hallWalkX - this.hallCamX) * camFollow;

            // 走到玻璃展柜前：自动收起武器 + 稍后远方传来孩子轻脚步回响
            const holsterThreshold = p.room.key === "museum" ? this.caseX + 12 : this.caseX - 85;
            if (!this.holstered && this.hallWalkX >= holsterThreshold) {
                this.holstered = true;
                ctx.audio.playOnce(
                    "fe06:e02:holster:" + this.roomSessionId,
                    "sfx",
                    MUSEUM_AUDIO.weaponHolster,
                    0.76,
                    "museum:e02:weapon_holster",
                    p.ticks,
                );
                if (!this.childEchoPlayed) {
                    this.childEchoCountdown = MUSEUM_TIMINGS.childEchoDelay;
                }
            }

            if (this.childEchoCountdown >= 0 && !this.childEchoPlayed) {
                this.childEchoCountdown -= udt;
                if (this.childEchoCountdown <= 0) {
                    this.childEchoCountdown = -1;
                    this.childEchoPlayed = true;
                    this.childEchoVisualT = 2.1;
                    ctx.audio.playOnce(
                        "fe06:e02:child_echo:" + this.roomSessionId,
                        "sfx",
                        MUSEUM_AUDIO.childStepsEcho,
                        0.72,
                        "museum:e02:child_steps_echo",
                        p.ticks,
                    );
                }
            }

            this.nearLamp = view.isRehearsal
                ? Math.abs(this.hallWalkX - this.lampX) <= 72
                : ((p.phase === "museum-hall" || p.phase === "museum-lamp")
                    && Math.abs(p.player.x - (this.lampX + p.ox)) <= 72);
            this.savedResume = this.exportResumeState();

            if (this.nearLamp && interactPressed) {
                this.submitMuseumIntent(p, "lamp_turn");
            }
            return;
        }

        // 4. E02：亲手转动西窗之灯 → 窗映宁村所井庭 → 「小满，外头天亮了。」→ 展厅第一声轻叩（lamp_turn）
        if (effectivePhase === "lamp_turn") {
            this.syncLoops(ctx, false, 0, true);
            if (wdt > 0) {
                this.lampElapsed += wdt;
            }
            // 后端 C 独立 MUSEUM_ROOM 的 museum-return 阶段允许玩家在转灯后自由步行回玻璃柜
            if (p.room.key === "museum") {
                const targetX = clamp(p.player.x - p.ox, 90, MUSEUM_HALL_WIDTH - 90);
                const delta = targetX - this.hallWalkX;
                this.hallMoving = Math.abs(delta) > 0.25;
                if (this.hallMoving) {
                    this.hallFacing = delta >= 0 ? 1 : -1;
                    this.hallWalkAnim += udt * 8.5;
                }
                this.hallWalkX = targetX;
                this.hallCamX += (this.hallWalkX - this.hallCamX) * Math.min(1, udt * 5.2);
            }
            ctx.audio.playOnce(
                "fe06:e02:lamp_turn:" + this.roomSessionId,
                "sfx",
                MUSEUM_AUDIO.lampTurn,
                0.82,
                "museum:e02:lamp_turn",
                p.ticks,
            );
            if (this.lampElapsed >= MUSEUM_TIMINGS.lampLineAt) {
                this.lineDawnShown = true;
                ctx.audio.playOnce(
                    "fe06:e02:line_dawn:" + this.roomSessionId,
                    "voice",
                    MUSEUM_AUDIO.lineDawn,
                    0.92,
                    "museum:e02:line_dawn",
                    p.ticks,
                );
            }
            if (this.lampElapsed >= MUSEUM_TIMINGS.lampKnock1At && !this.knock1Played) {
                this.knock1Played = true;
                this.knock1VisualT = 0.85;
                ctx.audio.playOnce(
                    "fe06:e02:knock1:" + this.roomSessionId,
                    "sfx",
                    MUSEUM_AUDIO.knockHallFirst,
                    0.88,
                    "museum:knock:1",
                    p.ticks,
                );
            }
            this.savedResume = this.exportResumeState();

            if (this.lampElapsed >= MUSEUM_TIMINGS.lampTurnDuration && !this.beginReturnSubmitted) {
                this.beginReturnSubmitted = true;
                this.submitMuseumIntent(p, "begin_return_cabinet");
                const contract = resolveRuntimeContract(this.injectedContract);
                if (contract !== undefined && contract.isRehearsal()) {
                    contract.enterMockMuseum("return_cabinet");
                }
            }
            return;
        }

        // 5. E02：第二声实木叩响落在明初厨柜板 → 同源补线袖口接回寻柜（return_cabinet）
        if (phase === "return_cabinet") {
            this.syncLoops(ctx, false, 0, false);
            if (wdt > 0) {
                this.returnElapsed += wdt;
            }
            if (this.returnElapsed >= MUSEUM_TIMINGS.returnKnock2At && !this.knock2Played) {
                this.knock2Played = true;
                this.knock2VisualT = 0.9;
                ctx.audio.playOnce(
                    "fe06:e02:knock2:" + this.roomSessionId,
                    "sfx",
                    MUSEUM_AUDIO.knockCabinetSecond,
                    0.92,
                    "museum:knock:2",
                    p.ticks,
                );
            }
            this.savedResume = this.exportResumeState();

            if (this.returnElapsed >= MUSEUM_TIMINGS.returnCabinetDuration && !this.returnCompleteSubmitted) {
                this.returnCompleteSubmitted = true;
                this.submitMuseumIntent(p, "return_cabinet");
            }
        }
    }

    drawBackdrop(
        bgDraw: DrawNode.Type,
        _bgGlow: DrawNode.Type,
        _backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        if (ctx.view.visualMode !== "museum") {
            return false;
        }
        // 博物馆/匹配剪辑态下停绘明初序章远景
        bgDraw.drawRect(Rect(0, 0, ctx.w, ctx.h), Color(11, 13, 18, 255));
        return true;
    }

    drawWorld(
        _fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        return ctx.view.visualMode === "museum";
    }

    drawPropsOverlay(
        _fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        return ctx.view.visualMode === "museum";
    }

    /**
     * 在 `prologue-wait` 实景世界左侧渲染「侧灶通往后院深井」的精绘像素青石古井与水光引导（零按键浮签）
     */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (!this.gateOpen || ctx.view.visualMode === "museum") {
            return;
        }
        const cam = ctx.cam;
        const wellCx = cam.sx(this.wellWorldX);
        const groundY = cam.sy(0, 0);
        const phase = ctx.view.archive.museumPhase;
        const activeLure = phase === "well_open" && !ctx.view.archive.museumSeen;

        const rimH = cam.len(26);
        // 精绘像素明代青石古井与砖拱门基（替代硬矩形灰框）
        worldArt.tryPlace("fe_well_rim", "fe06_world_well_px", wellCx, groundY - 2, cam.len(68), cam.len(38), {
            opacity: 0.98,
            layer: 36,
        });

        const dripCycle = (this.animTime * 0.58) % 1;
        const rippleR = cam.len(3 + dripCycle * 11);
        const rippleAlpha = Math.round((1 - dripCycle) * (activeLure ? 155 : 42));
        if (activeLure) {
            const shimmer = 0.65 + 0.35 * Math.sin(this.animTime * 2.9);
            fgDraw.drawCircle(Vec2(wellCx, groundY + rimH), cam.len(2.6), Color(236, 244, 252, Math.round(215 * shimmer)));
            drawEllipseRing(fgDraw, wellCx, groundY + rimH, rippleR, rippleR * 0.36, Color(0, 0, 0, 0), 1.1, Color(210, 226, 242, rippleAlpha), 24);
            fillRadialGlow(
                fgGlow,
                wellCx,
                groundY + rimH + cam.len(8),
                cam.len(30),
                cam.len(38),
                Color(206, 224, 244, Math.round(52 * shimmer)),
                Color(148, 178, 212, 0),
                16,
            );
            if (dripCycle < 0.24) {
                const dropK = dripCycle / 0.24;
                const dropY = groundY + cam.len(64) - dropK * cam.len(38);
                fgDraw.drawSegment(
                    Vec2(wellCx, dropY),
                    Vec2(wellCx, dropY + cam.len(4.5)),
                    1.4,
                    Color(214, 228, 244, 185),
                );
            }
        } else if (this.revisitCalmTimer > 0) {
            const calmK = 1 - clamp01(this.revisitCalmTimer / 1.4);
            const calmR = cam.len(3 + calmK * 10);
            drawEllipseRing(
                fgDraw,
                wellCx,
                groundY + rimH,
                calmR,
                calmR * 0.35,
                Color(0, 0, 0, 0),
                1.0,
                Color(148, 160, 172, Math.round((1 - calmK) * 120)),
                24,
            );
        }
    }

    /**
     * 绘制 E01/E02 全屏演出与可玩现代展厅；
     * - 在 `well_open` 且玩家主动开启「按键辅助」时提供轻量 `[E]` 提示（不接管 HUD，返回 false）；
     * - 在 `visualMode === "museum"` 四阶段返回 `true`，彻底遮蔽序章底层并自动压隐明朝战斗 HUD 与准星。
     */
    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const view = ctx.view;
        const phase = view.archive.museumPhase;

        if (view.visualMode !== "museum") {
            // 默认零浮签；仅当玩家在暂停菜单主动打开「按键辅助」且走近井口时显示轻量提示
            if (this.gateOpen && this.nearWell && view.assistHintsEnabled && phase === "well_open" && !view.archive.museumSeen) {
                const sx = ctx.cam.sx(this.wellWorldX) / ctx.uiScale;
                const sy = (ctx.cam.sy(0, 0) + ctx.cam.len(54)) / ctx.uiScale;
                drawSilkVeil(uiDraw, uiArt, "fe06_well_hint_veil", sx, sy, 132, 26, PALETTE.panelBg, 0.82, 1);
                ctx.texts.put(
                    "xs",
                    adaptHintSentence("[E] 俯身看井", ctx.input.inputMode, ctx.input.gamepadLayout),
                    sx,
                    sy,
                    toColor(PALETTE.textBright),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.6,
                    0.92,
                );
            }
            return false;
        }

        const w = ctx.uiW;
        const h = ctx.uiH;

        const effectivePhase: MuseumPhase = (ctx.p.room.key === "museum" && phase === "well_reflect" && this.liveReflectDoneInMuseumRoom)
            ? "hall_walk"
            : phase;

        if (effectivePhase === "well_reflect") {
            this.renderE01WellReflectMatchCut(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h);
            return true;
        }
        if (effectivePhase === "hall_walk") {
            this.renderE02MuseumHall(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, 0, false);
            return true;
        }
        if (effectivePhase === "lamp_turn") {
            const turnProg = smoothstep(0, 1.15, this.lampElapsed);
            this.renderE02MuseumHall(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, turnProg, true);
            return true;
        }
        if (effectivePhase === "return_cabinet") {
            this.renderE02ReturnCabinet(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h);
            return true;
        }
        return false;
    }

    /**
     * E01：井底白灯倒影 + 指南针玻璃叠合 + 拾取时间穿梭器 + 同屏幕坐标 `(0.50, 0.54)` 像素幻灯片匹配剪辑
     */
    private renderE01WellReflectMatchCut(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
    ): void {
        const t = this.reflectElapsed;
        const ax = this.wellAnchorX;
        const ay = this.wellAnchorY;
        const compK = smoothstep(0.45, 1.15, t);
        const matchK = smoothstep(MUSEUM_TIMINGS.wellMatchCutStart, MUSEUM_TIMINGS.wellReflectDuration, t);
        const rect = computeFullscreenSlideRect(w, h);

        uiDraw.drawRect(Rect(0, 0, w, h), Color(8, 10, 15, 255));

        // 1. 三镜同心像素幻灯片（井底水灯 → 指南针同心叠光 → 现代展厅玻璃展柜同心反光）
        const wellOp = 1 - compK * 0.85;
        const compOp = compK * (1 - matchK * 0.85);
        if (wellOp > 0.02) {
            drawPixelSlidePlate(uiDraw, uiInkDraw, uiArt, "slide_e01_well", "fe06_e01_well", rect, wellOp, 0, 0, 0, 1.0 + compK * 0.03);
        }
        if (compOp > 0.02) {
            drawPixelSlidePlate(uiDraw, uiInkDraw, uiArt, "slide_e01_compass", "fe06_e01_comp", rect, compOp, 1, 0, 0, 1.0 + matchK * 0.03);
        }
        if (matchK > 0.02) {
            drawPixelSlidePlate(uiDraw, uiInkDraw, uiArt, "slide_e01_vitrine", "fe06_e01_vitrine", rect, matchK, 2, 0, 0, 1.03 - matchK * 0.03);
        }

        // 同心缓慢水纹（前半段以 (ax, ay) 为圆心扩散）
        const wellAlpha = 1 - matchK;
        if (wellAlpha > 0.02) {
            let ri = 0;
            for (ri = 0; ri < 3; ri++) {
                const cyc = ((t * 0.42 + ri * 0.33) % 1);
                const r = 18 + cyc * 140;
                const ra = Math.round((1 - cyc) * 76 * wellAlpha);
                drawCircleRing(uiInkDraw, ax, ay, r, Color(0, 0, 0, 0), 1.0, Color(176, 198, 222, ra), 32);
            }
            if (t >= MUSEUM_TIMINGS.wellPickupAt) {
                const capA = smoothstep(MUSEUM_TIMINGS.wellPickupAt, MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK);
                if (capA > 0.03) {
                    drawSilkVeil(uiDraw, uiArt, "fe06_pickup_veil", w * 0.5, 96, 300, 34, PALETTE.inkVoid, 0.78 * capA, 6);
                    ctx.texts.put("sm", "拾起「时间穿梭器」", w * 0.5, 96, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, capA);
                }
            }
        }

        // 贯通整段匹配剪辑的「同一点冷白反光」核心锚点（wellAnchor === glassAnchor）
        const flashPeak = Math.sin(matchK * Math.PI);
        const coreR = 7 + flashPeak * 16;
        uiInkDraw.drawCircle(Vec2(ax, ay), coreR * 0.52, Color(248, 252, 255, 245));
        fillRadialGlow(
            uiGlow, ax, ay,
            48 + flashPeak * 140, 42 + flashPeak * 110,
            Color(238, 246, 255, Math.round(135 + flashPeak * 95)),
            Color(174, 204, 238, 0),
            20,
        );
        if (flashPeak > 0.05) {
            const rayW = 68 + flashPeak * 240;
            fillHGradRect(uiGlow, ax - rayW, ay - 2, rayW, 4, Color(224, 238, 252, 0), Color(242, 248, 255, Math.round(150 * flashPeak)));
            fillHGradRect(uiGlow, ax, ay - 2, rayW, 4, Color(242, 248, 255, Math.round(150 * flashPeak)), Color(224, 238, 252, 0));
        }

        this.drawLetterbox(uiInkDraw, w, h, 42, 0.92);
    }

    /**
     * E02：现代抗日主题博物馆自由步行展厅（640×360 精绘像素长卷 + 西窗晓光映照明初井庭）
     */
    private renderE02MuseumHall(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
        lampTurnProg: number,
        inLampTurn: boolean,
    ): void {
        const floorY = 148;
        const halfW = w * 0.5;
        const camMin = Math.min(MUSEUM_HALL_WIDTH * 0.5, halfW - 40);
        const camMax = Math.max(MUSEUM_HALL_WIDTH * 0.5, MUSEUM_HALL_WIDTH - halfW + 40);
        const camX = clamp(this.hallCamX, camMin, camMax);
        const toScreenX = (hx: number): number => halfW + (hx - camX);

        // 1. 深青灰底幕 + 随 camX 平滑横向卷动的 640×360 精绘像素现代纪念展厅全景
        uiDraw.drawRect(Rect(0, 0, w, h), Color(13, 17, 23, 255));
        const hallScreenW = Math.max(w * 1.15, MUSEUM_HALL_WIDTH + 120);
        const hallScreenH = Math.max(h, Math.round(hallScreenW * 9 / 16));
        const hallCenterSx = toScreenX(MUSEUM_HALL_WIDTH * 0.5);
        uiArt.tryPlace("slide_e02_museum_hall", "fe06_hall_panorama", Math.round(hallCenterSx), Math.round((h - hallScreenH) * 0.5 + 18), Math.round(hallScreenW), hallScreenH, {
            opacity: 1,
            layer: 0,
        });

        // 2. 入口序厅铭文叠加（精准贴在展厅左段青铜纪念铭壁位置）
        const plaqueWorldX = this.caseX <= 260 ? 108 : 180;
        const plaqueX = toScreenX(plaqueWorldX);
        if (plaqueX > -240 && plaqueX < w + 240) {
            const py = floorY + 180;
            ctx.texts.put("sm", "海防抗战纪念展厅", plaqueX, py + 34, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.0, 0.90);
            ctx.texts.put("xs", "温州宁村 · 守望史迹陈列", plaqueX, py - 2, toColor(PALETTE.amber), 0.5, 0.5, TextAlign.Center, 1.0, 0.80);
        }

        // 3. 中厅聚光微晕
        const caseSx = toScreenX(this.caseX);
        if (caseSx > -240 && caseSx < w + 240) {
            fillRadialGlow(uiGlow, caseSx, floorY + 190, 96, 138, Color(224, 236, 250, 48), Color(168, 192, 220, 0), 16);
        }

        // 4. 末厅落地西窗与转灯后映出的「和平晨光 · 明初宁村所井庭」像素画板
        const lampSx = toScreenX(this.lampX);
        const winSx = toScreenX(this.lampX + 108);
        const reflectK = inLampTurn
            ? smoothstep(MUSEUM_TIMINGS.lampReflectStart, 2.35, this.lampElapsed)
            : 0;

        if (winSx > -260 && winSx < w + 260) {
            const winW = 248;
            const winH = 310;
            const winY = floorY + 34;

            if (reflectK > 0.02) {
                uiArt.tryPlace("slide_e02_window_dawn", "fe06_window_dawn_px", Math.round(winSx), Math.round(winY + winH * 0.5), winW, winH, {
                    opacity: reflectK * 0.86,
                    layer: 1,
                });
                fillRadialGlow(uiGlow, winSx, winY + winH * 0.48, 136, 148, Color(246, 218, 168, Math.round(86 * reflectK)), Color(214, 174, 112, 0), 18);
            }

            // 柔和灯束锥光（转向西窗时铺亮窗面，与像素黄铜落地灯自然融合）
            const aimDir = -0.58 + lampTurnProg * 1.40;
            const headX = lampSx + Math.sin(aimDir) * 14;
            const headY = floorY + 146 + Math.cos(aimDir) * 10;
            const beamLen = 132 + lampTurnProg * 84;
            const bxEnd = headX + Math.sin(aimDir) * beamLen;
            const byEnd = headY + Math.cos(aimDir) * 28;
            const perpX = -Math.cos(aimDir) * 18;
            const perpY = Math.sin(aimDir) * 34;
            fillGradQuad(
                uiGlow,
                headX, headY - 4, Color(246, 224, 178, Math.round(58 + 44 * lampTurnProg)),
                headX, headY + 4, Color(246, 224, 178, Math.round(58 + 44 * lampTurnProg)),
                bxEnd + perpX, byEnd + perpY + 34, Color(238, 206, 148, 0),
                bxEnd - perpX, byEnd - perpY - 22, Color(238, 206, 148, 0),
            );
            fillRadialGlow(uiGlow, headX, headY, 34, 34, Color(246, 228, 186, 72), Color(224, 194, 140, 0), 14);
        }

        // 5. 自由步行的周戍像素立绘
        const playerSx = toScreenX(this.hallWalkX);
        const moving = !inLampTurn && (this.hallMoving || Math.abs(ctx.input.moveX) > 0.05);
        const slot = moving ? "soldier_run" : "soldier_idle";
        const frame = moving ? Math.floor(this.hallWalkAnim) : 0;
        const charH = Math.round(192 * Math.max(0.75, Math.min(1.25, h / 720)));
        const charW = Math.round(charH * 0.45);
        uiDraw.drawEllipse(Vec2(playerSx, floorY + 2), 34, 6.5, Color(6, 8, 12, 178));
        uiArt.tryPlace(slot, "fe06_museum_zhoushu", playerSx, floorY + 2, charW, charH, {
            facing: this.hallFacing,
            frame,
            layer: 3,
        });

        // 玻璃柜前收械轻反馈
        if (this.holstered && !inLampTurn && Math.abs(this.hallWalkX - this.caseX) <= 130) {
            const subA = clamp01(1 - Math.abs(this.hallWalkX - this.caseX) / 145) * 0.86;
            ctx.texts.put("xs", "已收起随身器物", caseSx, floorY + 252, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.9, subA);
        }

        // 远方童声脚步回响
        if (this.childEchoVisualT > 0) {
            const echoK = 1 - clamp01(this.childEchoVisualT / 2.1);
            const ex = Math.min(w - 110, toScreenX(this.caseX + 310));
            const ey = floorY + 32;
            const ea = Math.round(Math.sin(echoK * Math.PI) * 165);
            drawCircleRing(uiInkDraw, ex, ey, 14 + echoK * 46, Color(0, 0, 0, 0), 1.1, Color(224, 214, 194, ea), 28);
            drawCircleRing(uiInkDraw, ex, ey, 8 + echoK * 28, Color(0, 0, 0, 0), 0.9, Color(224, 214, 194, Math.round(ea * 0.7)), 24);
            ctx.texts.put("xs", "（远方传来轻快的孩童脚步声）", w * 0.5, 84, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.0, Math.sin(echoK * Math.PI) * 0.85);
        }

        // 6. 入厅现代主题字幕（不锁移动）
        if (!inLampTurn) {
            const fadeIn = smoothstep(0, MUSEUM_TIMINGS.hallIntroFadeIn, this.hallIntroElapsed);
            const fadeOut = 1 - smoothstep(
                MUSEUM_TIMINGS.hallIntroFadeIn + MUSEUM_TIMINGS.hallIntroHold,
                MUSEUM_TIMINGS.hallIntroFadeIn + MUSEUM_TIMINGS.hallIntroHold + MUSEUM_TIMINGS.hallIntroFadeOut,
                this.hallIntroElapsed,
            );
            const introA = fadeIn * fadeOut;
            if (introA > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "fe06_hall_intro_veil", w * 0.5, h - 104, 480, 74, PALETTE.inkVoid, 0.78 * introA, 5);
                drawHairline(uiInkDraw, uiArt, "fe06_hall_intro_line", w * 0.5, h - 106, 260, PALETTE.silkLine, 0.45 * introA, false, 6);
                ctx.texts.put("md", MUSEUM_HALL_TITLE, w * 0.5, h - 88, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, introA);
                ctx.texts.put("xs", MUSEUM_HALL_SUBTITLE, w * 0.5, h - 122, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, introA * 0.88);
            }

            if (this.nearLamp && ctx.view.assistHintsEnabled) {
                drawSilkVeil(uiDraw, uiArt, "fe06_lamp_hint_veil", lampSx, floorY + 158, 146, 28, PALETTE.panelBg, 0.84, 5);
                ctx.texts.put(
                    "xs",
                    adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout),
                    lampSx,
                    floorY + 158,
                    toColor(PALETTE.textBright),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.6,
                    0.94,
                );
            }
        }

        // 7. 转灯阶段台词与第一声轻叩波纹
        if (inLampTurn && this.lampElapsed >= MUSEUM_TIMINGS.lampLineAt) {
            const lineA = smoothstep(MUSEUM_TIMINGS.lampLineAt, MUSEUM_TIMINGS.lampLineAt + 0.45, this.lampElapsed)
                * (1 - smoothstep(MUSEUM_TIMINGS.lampTurnDuration - 0.35, MUSEUM_TIMINGS.lampTurnDuration, this.lampElapsed));
            if (lineA > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "fe06_dawn_line_veil", w * 0.5, 86, 440, 50, PALETTE.inkVoid, 0.84 * lineA, 5);
                ctx.texts.put("md", MUSEUM_LINE_DAWN, w * 0.5, 86, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.6, lineA);
            }
        }

        if (this.knock1VisualT > 0) {
            const k1 = 1 - clamp01(this.knock1VisualT / 0.85);
            const k1A = Math.round((1 - k1) * 205);
            drawCircleRing(uiInkDraw, winSx, floorY + 148, 12 + k1 * 64, Color(0, 0, 0, 0), 1.6, Color(242, 232, 206, k1A), 28);
            drawCircleRing(uiInkDraw, winSx, floorY + 148, 6 + k1 * 34, Color(0, 0, 0, 0), 1.1, Color(242, 232, 206, Math.round(k1A * 0.72)), 24);
        }

        this.drawLetterbox(uiInkDraw, w, h, 38, 0.90);
    }

    /**
     * E02 尾声：第二声轻叩落在明初厨柜板 → 480×270 精绘像素补线袖口叩柜幻灯片 → 交还寻柜
     */
    private renderE02ReturnCabinet(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
    ): void {
        const t = this.returnElapsed;
        const fadeOut = 1 - smoothstep(MUSEUM_TIMINGS.returnFadeOutAt, MUSEUM_TIMINGS.returnCabinetDuration, t);

        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 13, Math.round(252 * fadeOut)));

        if (t < MUSEUM_TIMINGS.returnKnock2At) {
            this.drawLetterbox(uiInkDraw, w, h, 42, 0.95 * fadeOut);
            return;
        }

        const revealK = smoothstep(MUSEUM_TIMINGS.returnKnock2At, MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut;
        const rect = computeCenteredSlideRect(w, h, 860, 484, 12);
        const knockShake = this.knock2VisualT > 0.65 ? Math.sin(t * 120) * 2.4 : 0;
        const shiftedRect = { x: Math.round(rect.x + knockShake), y: rect.y, w: rect.w, h: rect.h };

        drawPixelSlidePlate(
            uiDraw,
            uiInkDraw,
            uiArt,
            "slide_e02_return_cabinet",
            "fe06_return_cab_px",
            shiftedRect,
            revealK,
            2,
            0,
            0,
            1.0 + (1 - revealK) * 0.02,
        );
        drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, shiftedRect, w, h, {
            frameOpacity: 0.92,
            opacity: revealK,
            layer: 2,
            instancePrefix: "fe06_return_cab",
        });

        // 第二声实木叩响的柜板细波纹
        if (this.knock2VisualT > 0) {
            const k2 = 1 - clamp01(this.knock2VisualT / 0.9);
            const k2A = Math.round((1 - k2) * 215 * fadeOut);
            drawCircleRing(uiInkDraw, rect.x + rect.w * 0.78, rect.y + rect.h * 0.50, 10 + k2 * 56, Color(0, 0, 0, 0), 1.6, Color(232, 220, 196, k2A), 28);
        }

        const tipA = smoothstep(MUSEUM_TIMINGS.returnKnock2At + 0.45, MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut;
        if (tipA > 0.03) {
            drawSilkVeil(uiDraw, uiArt, "fe06_return_veil", w * 0.5, rect.y - 26, 320, 32, PALETTE.inkVoid, 0.72 * tipA, 7);
            ctx.texts.put("xs", "两声轻敲落回柜板 · 寻回小满", w * 0.5, rect.y - 26, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.2, tipA * 0.9);
        }

        this.drawLetterbox(uiInkDraw, w, h, 42, 0.95 * fadeOut);
    }

    private drawLetterbox(draw: DrawNode.Type, w: number, h: number, barH: number, opacity: number): void {
        const a = Math.round(244 * clamp01(opacity));
        if (a <= 2) {
            return;
        }
        draw.drawRect(Rect(0, 0, w, barH), Color(6, 8, 12, a));
        draw.drawRect(Rect(0, h - barH, w, barH), Color(6, 8, 12, a));
    }
}

export function createWellMuseumPlugin(contract?: DualRouteContract): WellMuseumPlugin {
    return new WellMuseumPlugin(contract);
}
