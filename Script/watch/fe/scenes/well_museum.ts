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
     * 在 `prologue-wait` 实景世界左侧渲染「侧灶通往后院深井」的明初石井与水光引导（零按键浮签）
     */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
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

        // 1. 左侧灶间通往后院的低矮青砖门洞（与明朝序章砖灰/土褐基调融合）
        const archW = cam.len(68);
        const archH = cam.len(96);
        const archX = wellCx - archW * 0.54;
        fillVGradRect(
            fgDraw,
            archX,
            groundY,
            archW,
            archH,
            Color(12, 16, 22, 232),
            Color(18, 24, 34, 212),
        );
        // 砖拱外框与门楣灰石
        fgDraw.drawRect(Rect(archX - 4, groundY, 6, archH), Color(48, 54, 62, 240));
        fgDraw.drawRect(Rect(archX + archW - 2, groundY, 6, archH), Color(48, 54, 62, 240));
        fgDraw.drawRect(Rect(archX - 6, groundY + archH - 8, archW + 12, 10), Color(62, 68, 76, 245));

        // 2. 后院青石古井栏（矮实青石井圈，无现代装饰）
        const rimW = cam.len(38);
        const rimH = cam.len(22);
        const rimX = wellCx - rimW * 0.5;
        fgDraw.drawRect(
            Rect(rimX, groundY, rimW, rimH),
            Color(46, 52, 60, 250),
            1.2,
            Color(102, 110, 120, 215),
        );
        // 井沿顶面与深暗井口
        fgDraw.drawEllipse(Vec2(wellCx, groundY + rimH), rimW * 0.52, cam.len(5.5), Color(74, 82, 92, 250));
        fgDraw.drawEllipse(Vec2(wellCx, groundY + rimH), rimW * 0.38, cam.len(3.8), Color(8, 12, 18, 255));

        // 3. 井口水光微闪与周期滴水细涟漪（仅在未访馆的 well_open 阶段亮起冷白异光）
        const dripCycle = (this.animTime * 0.58) % 1;
        const rippleR = cam.len(3 + dripCycle * 11);
        const rippleAlpha = Math.round((1 - dripCycle) * (activeLure ? 155 : 42));
        if (activeLure) {
            const shimmer = 0.65 + 0.35 * Math.sin(this.animTime * 2.9);
            // 水底极克制的冷白一点光（与明朝暖火光形成时代反差，灰度下可见高亮中心点）
            fgDraw.drawCircle(Vec2(wellCx, groundY + rimH), cam.len(2.8), Color(236, 244, 252, Math.round(215 * shimmer)));
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
            // 周期落下的一小滴水珠
            if (dripCycle < 0.24) {
                const dropK = dripCycle / 0.24;
                const dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH);
                fgDraw.drawSegment(
                    Vec2(wellCx, dropY),
                    Vec2(wellCx, dropY + cam.len(4.5)),
                    1.4,
                    Color(214, 228, 244, 185),
                );
            }
        } else if (this.revisitCalmTimer > 0) {
            // 离馆后二次走近复查：仅呈寻常暗夜水纹，不再亮现代白灯
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
     * E01：井底白灯倒影 + 指南针玻璃叠合 + 拾取时间穿梭器 + 同屏幕坐标 `(0.50, 0.54)` 匹配剪辑进入现代展柜
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
        const matchK = smoothstep(MUSEUM_TIMINGS.wellMatchCutStart, MUSEUM_TIMINGS.wellReflectDuration, t);
        const wellAlpha = 1 - matchK;

        // 底层黑石与过渡底色（随 matchK 溶入现代展厅深青石色）
        fillVGradRect(
            uiDraw,
            0,
            0,
            w,
            h,
            Color(
                Math.round(8 + 14 * matchK),
                Math.round(10 + 16 * matchK),
                Math.round(15 + 20 * matchK),
                255,
            ),
            Color(
                Math.round(14 + 22 * matchK),
                Math.round(18 + 26 * matchK),
                Math.round(26 + 30 * matchK),
                255,
            ),
        );

        // 1. 前半段：深黑古井石壁与水面（wellAlpha 从 1 平滑淡至 0）
        if (wellAlpha > 0.01) {
            const wellR = Math.min(w, h) * (0.31 + matchK * 0.24);
            // 石砌井壁外圈
            uiDraw.drawCircle(Vec2(ax, ay), wellR + 36, Color(30, 35, 42, Math.round(240 * wellAlpha)));
            uiDraw.drawCircle(Vec2(ax, ay), wellR + 14, Color(20, 24, 30, Math.round(250 * wellAlpha)));
            // 深水井面
            uiDraw.drawCircle(Vec2(ax, ay), wellR, Color(7, 11, 17, Math.round(255 * wellAlpha)));

            // 同心缓慢水纹（以反光点为中心扩散）
            let ri = 0;
            for (ri = 0; ri < 3; ri++) {
                const cyc = ((t * 0.42 + ri * 0.33) % 1);
                const r = 20 + cyc * (wellR * 0.85);
                const ra = Math.round((1 - cyc) * 90 * wellAlpha);
                drawCircleRing(uiInkDraw, ax, ay, r, Color(0, 0, 0, 0), 1.1, Color(176, 198, 222, ra), 32);
            }

            // 黄铜指南针表蒙滑入，与井底白灯倒影精确叠合在同一锚点 (ax, ay)
            const compassSlide = smoothstep(0.15, 0.95, t);
            const compX = ax + (1 - compassSlide) * 140;
            const compY = ay - (1 - compassSlide) * 90;
            const compR = 62;
            // 黄铜表壳
            drawCircleRing(
                uiInkDraw,
                compX,
                compY,
                compR + 8,
                Color(98, 78, 48, Math.round(218 * wellAlpha)),
                2.0,
                Color(186, 154, 102, Math.round(235 * wellAlpha)),
                32,
            );
            // 玻璃镜面与微透刻度线
            drawCircleRing(
                uiInkDraw,
                compX,
                compY,
                compR,
                Color(16, 24, 36, Math.round(145 * wellAlpha)),
                1.2,
                Color(218, 226, 236, Math.round(180 * wellAlpha)),
                32,
            );
            // 四向刻度与磁针
            uiInkDraw.drawSegment(Vec2(compX, compY + compR - 6), Vec2(compX, compY + compR - 18), 1.6, Color(224, 206, 168, Math.round(190 * wellAlpha)));
            uiInkDraw.drawSegment(Vec2(compX, compY - compR + 6), Vec2(compX, compY - compR + 18), 1.4, Color(168, 174, 182, Math.round(165 * wellAlpha)));
            uiInkDraw.drawSegment(Vec2(compX - compR + 6, compY), Vec2(compX - compR + 18, compY), 1.4, Color(168, 174, 182, Math.round(165 * wellAlpha)));
            uiInkDraw.drawSegment(Vec2(compX + compR - 6, compY), Vec2(compX + compR - 18, compY), 1.4, Color(168, 174, 182, Math.round(165 * wellAlpha)));
            // 细指针（微微指向西与北）
            const needleAng = -0.35 + Math.sin(t * 2.2) * 0.08 * (1 - matchK);
            const nx = Math.cos(needleAng) * 34;
            const ny = Math.sin(needleAng) * 34;
            uiInkDraw.drawSegment(Vec2(compX, compY), Vec2(compX + nx, compY + ny), 2.2, Color(208, 92, 82, Math.round(215 * wellAlpha)));
            uiInkDraw.drawSegment(Vec2(compX, compY), Vec2(compX - nx * 0.85, compY - ny * 0.85), 1.8, Color(214, 222, 232, Math.round(185 * wellAlpha)));

            // 1.1s–1.9s 拾取「时间穿梭器」：冷白与黄铜双环轻合
            if (t >= MUSEUM_TIMINGS.wellPickupAt) {
                const pickK = smoothstep(MUSEUM_TIMINGS.wellPickupAt, MUSEUM_TIMINGS.wellMatchCutStart, t);
                const liftY = ay + pickK * 14;
                drawCircleRing(
                    uiInkDraw,
                    ax,
                    liftY,
                    24 + pickK * 12,
                    Color(0, 0, 0, 0),
                    1.6,
                    Color(226, 204, 152, Math.round(215 * (1 - matchK * 0.65))),
                    28,
                );
                // 底部克制物件铭记（不弹大任务卡）
                const capA = smoothstep(MUSEUM_TIMINGS.wellPickupAt, MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK);
                if (capA > 0.03) {
                    drawSilkVeil(uiDraw, uiArt, "fe06_pickup_veil", w * 0.5, 96, 300, 34, PALETTE.inkVoid, 0.78 * capA, 1);
                    ctx.texts.put(
                        "sm",
                        "拾起「时间穿梭器」",
                        w * 0.5,
                        96,
                        toColor(PALETTE.amberCore),
                        0.5,
                        0.5,
                        TextAlign.Center,
                        1.4,
                        capA,
                    );
                }
            }
        }

        // 2. 后半段匹配剪辑（matchK > 0）：现代博物馆玻璃展柜以同一反光锚点 (glassAnchorX, glassAnchorY) 浮现
        if (matchK > 0.01) {
            const caseW = 300;
            const caseH = 276;
            const caseX = this.glassAnchorX - caseW * 0.5;
            const caseY = this.glassAnchorY - caseH * 0.54;
            // 现代展厅冷灰石壁与展柜底台
            uiDraw.drawRect(Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), Color(24, 29, 36, Math.round(190 * matchK)));
            uiDraw.drawRect(
                Rect(caseX, caseY, caseW, caseH),
                Color(18, 23, 30, Math.round(220 * matchK)),
                1.6,
                Color(164, 178, 194, Math.round(185 * matchK)),
            );
            // 展柜玻璃斜向清冷高光带（严格穿过 glassAnchorX, glassAnchorY）
            fillGradQuad(
                uiInkDraw,
                this.glassAnchorX - 42, caseY + caseH - 6, Color(224, 236, 248, Math.round(44 * matchK)),
                this.glassAnchorX + 24, caseY + caseH - 6, Color(238, 246, 255, Math.round(78 * matchK)),
                this.glassAnchorX - 18, caseY + 6, Color(224, 236, 248, Math.round(24 * matchK)),
                this.glassAnchorX - 82, caseY + 6, Color(224, 236, 248, 0),
            );
            // 展柜内部陈列铜指南针剪影
            uiArt.tryPlace("prop_compass", "fe06_match_compass", this.glassAnchorX, caseY + 72, 46, 46, {
                opacity: matchK * 0.85,
                layer: 3,
            });
        }

        // 3. 贯通整段匹配剪辑的「同一点冷白反光」核心锚点（wellAnchor === glassAnchor）
        const flashPeak = Math.sin(matchK * Math.PI);
        const coreR = 8 + flashPeak * 18;
        uiInkDraw.drawCircle(Vec2(ax, ay), coreR * 0.55, Color(248, 252, 255, 248));
        fillRadialGlow(
            uiGlow,
            ax,
            ay,
            52 + flashPeak * 145,
            46 + flashPeak * 115,
            Color(238, 246, 255, Math.round(145 + flashPeak * 95)),
            Color(174, 204, 238, 0),
            20,
        );
        // 细腻水平折射光丝（匹配剪辑瞬间轻扫）
        if (flashPeak > 0.05) {
            const rayW = 70 + flashPeak * 260;
            fillHGradRect(uiGlow, ax - rayW, ay - 2, rayW, 4, Color(224, 238, 252, 0), Color(242, 248, 255, Math.round(160 * flashPeak)));
            fillHGradRect(uiGlow, ax, ay - 2, rayW, 4, Color(242, 248, 255, Math.round(160 * flashPeak)), Color(224, 238, 252, 0));
        }

        this.drawLetterbox(uiInkDraw, w, h, 42, 0.92);
    }

    /**
     * E02：现代抗日主题博物馆自由步行展厅 + 西窗转灯演出
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
        const wallTopY = h - 86;
        const halfW = w * 0.5;
        const camMin = Math.min(MUSEUM_HALL_WIDTH * 0.5, halfW - 40);
        const camMax = Math.max(MUSEUM_HALL_WIDTH * 0.5, MUSEUM_HALL_WIDTH - halfW + 40);
        const camX = clamp(this.hallCamX, camMin, camMax);
        const toScreenX = (hx: number): number => halfW + (hx - camX);

        // 1. 展厅背景墙与天顶（庄重冷青灰石材、克制建筑比例）
        fillVGradRect(uiDraw, 0, floorY, w, h - floorY, Color(26, 31, 38, 255), Color(16, 20, 26, 255));
        // 顶部暗槽天顶
        uiDraw.drawRect(Rect(0, wallTopY, w, h - wallTopY), Color(11, 14, 19, 255));
        // 建筑石板竖向接缝（增强行走视差与现代馆舍空间感）
        let px = 0;
        for (px = 40; px <= MUSEUM_HALL_WIDTH; px += 140) {
            const sx = toScreenX(px);
            if (sx >= -20 && sx <= w + 20) {
                uiDraw.drawSegment(Vec2(sx, floorY), Vec2(sx, wallTopY), 1.0, Color(38, 45, 54, 130));
            }
        }
        // 踢脚线与浅磨石地面
        fillVGradRect(uiDraw, 0, 0, w, floorY, Color(14, 17, 22, 255), Color(32, 37, 45, 255));
        uiDraw.drawSegment(Vec2(0, floorY), Vec2(w, floorY), 2.0, Color(76, 86, 98, 220));
        uiDraw.drawRect(Rect(0, floorY, w, 12), Color(20, 24, 31, 240));

        // 2. 入口序厅纪念铭墙（避开独立展厅 x = 200 玻璃展柜）
        const plaqueWorldX = this.caseX <= 260 ? 108 : 180;
        const plaqueX = toScreenX(plaqueWorldX);
        if (plaqueX > -240 && plaqueX < w + 240) {
            const pw = 290;
            const ph = 132;
            const py = floorY + 135;
            uiDraw.drawRect(
                Rect(plaqueX - pw * 0.5, py, pw, ph),
                Color(18, 22, 28, 238),
                1.2,
                Color(118, 128, 140, 170),
            );
            fillRadialGlow(uiGlow, plaqueX, wallTopY - 8, 150, 120, Color(224, 232, 240, 42), Color(180, 196, 214, 0), 14);
            ctx.texts.put(
                "sm",
                "海防抗战纪念展厅",
                plaqueX,
                py + 82,
                toColor(PALETTE.textBright),
                0.5,
                0.5,
                TextAlign.Center,
                2.0,
                0.88,
            );
            ctx.texts.put(
                "xs",
                "温州宁村 · 守望史迹陈列",
                plaqueX,
                py + 46,
                toColor(PALETTE.textDim),
                0.5,
                0.5,
                TextAlign.Center,
                1.0,
                0.78,
            );
        }

        // 3. 中厅抗战史料挂板与玻璃展柜（x = 600）
        const caseSx = toScreenX(this.caseX);
        if (caseSx > -260 && caseSx < w + 260) {
            // 两侧素雅历史展板（当 caseX 贴近左缘时不越出房间左边界）
            const boardOffsets = this.caseX <= 260 ? [180, 390] : [-210, 210];
            let bi = 0;
            for (bi = 0; bi < boardOffsets.length; bi++) {
                const bx = caseSx + boardOffsets[bi];
                uiDraw.drawRect(Rect(bx - 56, floorY + 112, 112, 154), Color(20, 24, 30, 235), 1.0, Color(88, 98, 110, 155));
                uiDraw.drawRect(Rect(bx - 42, floorY + 168, 84, 78), Color(34, 40, 48, 220));
                uiDraw.drawSegment(Vec2(bx - 36, floorY + 146), Vec2(bx + 36, floorY + 146), 1.6, Color(138, 146, 156, 140));
                uiDraw.drawSegment(Vec2(bx - 28, floorY + 132), Vec2(bx + 24, floorY + 132), 1.2, Color(108, 116, 126, 115));
            }

            // 中央独立玻璃展柜（内放明初旧铜指南针与素笺说明牌，与全尺寸周戍 192px 保持真实博物馆尺度）
            const pedW = 148;
            const pedH = 92;
            const glassH = 128;
            // 深灰底座
            uiDraw.drawRect(
                Rect(caseSx - pedW * 0.5, floorY, pedW, pedH),
                Color(22, 26, 33, 252),
                1.2,
                Color(96, 106, 118, 185),
            );
            // 玻璃柜体背衬
            uiDraw.drawRect(
                Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH),
                Color(16, 22, 30, 165),
                1.4,
                Color(180, 196, 214, 195),
            );
            // 陈列品：黄铜指南针与小展签
            uiArt.tryPlace("prop_compass", "fe06_hall_compass", caseSx, floorY + pedH + 34, 34, 34, {
                opacity: 0.94,
                layer: 3,
            });
            uiDraw.drawRect(Rect(caseSx - 30, floorY + pedH + 6, 60, 12), Color(214, 212, 204, 190));
            // 展柜玻璃高光与顶部清冷射灯
            fillGradQuad(
                uiInkDraw,
                caseSx - 28, floorY + pedH + glassH - 4, Color(230, 240, 252, 42),
                caseSx + 12, floorY + pedH + glassH - 4, Color(242, 248, 255, 72),
                caseSx - 12, floorY + pedH + 4, Color(230, 240, 252, 18),
                caseSx - 48, floorY + pedH + 4, Color(230, 240, 252, 0),
            );
            fillRadialGlow(uiGlow, caseSx, floorY + pedH + glassH - 12, 86, 128, Color(224, 236, 250, 56), Color(168, 192, 220, 0), 16);
            // 地面微弱倒影
            fillVGradRect(uiDraw, caseSx - pedW * 0.45, floorY - 36, pedW * 0.9, 36, Color(168, 186, 206, 0), Color(168, 186, 206, 28));
        }

        // 4. 末厅西窗与可转动展灯（x = 1140..1280）
        const lampSx = toScreenX(this.lampX);
        const winSx = toScreenX(this.lampX + 108);
        const reflectK = inLampTurn
            ? smoothstep(MUSEUM_TIMINGS.lampReflectStart, 2.35, this.lampElapsed)
            : 0;

        if (winSx > -260 && winSx < w + 260) {
            const winW = 204;
            const winH = 312;
            const winX = winSx - winW * 0.5;
            const winY = floorY + 38;
            // 西窗破晓天色（微蓝天光，转灯后染入柔和暖光）
            fillVGradRect(
                uiDraw,
                winX,
                winY,
                winW,
                winH,
                Color(
                    Math.round(54 + 46 * reflectK),
                    Math.round(68 + 42 * reflectK),
                    Math.round(92 + 24 * reflectK),
                    255,
                ),
                Color(
                    Math.round(30 + 28 * reflectK),
                    Math.round(44 + 34 * reflectK),
                    Math.round(70 + 30 * reflectK),
                    255,
                ),
            );

            // 转灯后：西窗玻璃缓缓浮现明初宁村所井庭与青砖墙影
            if (reflectK > 0.02) {
                uiArt.tryPlace("bgFar_prologue", "fe06_window_courtyard", winSx, winY + 26, winW - 8, winH - 52, {
                    opacity: reflectK * 0.48,
                    color: Color(238, 218, 186, 255),
                    layer: 1,
                });
                // 叠绘宁村所古井栏与砖院剪影，确保像素与灰度下清晰可辨
                const cy = winY + 34;
                const silA = Math.round(188 * reflectK);
                uiInkDraw.drawRect(Rect(winX + 12, cy, 42, 118), Color(24, 28, 36, silA));
                uiInkDraw.drawRect(Rect(winX + winW - 56, cy, 44, 134), Color(24, 28, 36, silA));
                // 井庭砖井
                uiInkDraw.drawRect(Rect(winSx - 24, cy + 4, 48, 28), Color(46, 44, 42, Math.round(215 * reflectK)), 1.0, Color(214, 186, 138, Math.round(170 * reflectK)));
                uiInkDraw.drawEllipse(Vec2(winSx, cy + 32), 26, 7, Color(218, 194, 148, Math.round(175 * reflectK)));
                // 朝西破晓暖辉
                fillRadialGlow(uiGlow, winSx, winY + winH * 0.48, 116, 128, Color(246, 218, 168, Math.round(92 * reflectK)), Color(214, 174, 112, 0), 18);
            }

            // 现代落地西窗窗格边框（在反射之上）
            uiInkDraw.drawRect(Rect(winX, winY, winW, winH), Color(0, 0, 0, 0), 3.0, Color(68, 76, 88, 245));
            uiInkDraw.drawSegment(Vec2(winSx, winY), Vec2(winSx, winY + winH), 2.0, Color(68, 76, 88, 235));
            uiInkDraw.drawSegment(Vec2(winX, winY + winH * 0.56), Vec2(winX + winW, winY + winH * 0.56), 2.0, Color(68, 76, 88, 235));

            // 窗前石质底座与可转动西窗展灯（lampSx，高度齐周戍胸肩便于抬手转灯）
            const standW = 34;
            const standH = 96;
            uiDraw.drawRect(Rect(lampSx - standW * 0.5, floorY, standW, standH), Color(34, 39, 48, 250), 1.1, Color(108, 118, 130, 190));
            // 金属灯柱与旋轴
            const pivotY = floorY + standH + 44;
            uiInkDraw.drawSegment(Vec2(lampSx, floorY + standH), Vec2(lampSx, pivotY), 3.2, Color(136, 144, 154, 240));
            uiInkDraw.drawCircle(Vec2(lampSx, pivotY), 5.5, Color(196, 178, 142, 245));
            // 灯头随 lampTurnProg 从略朝内侧（左偏）平缓转向西窗（右指）
            const aimDir = -0.65 + lampTurnProg * 1.48;
            const headX = lampSx + Math.sin(aimDir) * 20;
            const headY = pivotY + Math.cos(aimDir) * 14;
            uiInkDraw.drawSegment(Vec2(lampSx, pivotY), Vec2(headX, headY), 6.2, Color(188, 166, 126, 245));
            uiInkDraw.drawCircle(Vec2(headX, headY), 5.2, Color(248, 234, 198, 248));

            // 灯束锥光（转向西窗时铺亮窗面）
            const beamLen = 132 + lampTurnProg * 76;
            const bxEnd = headX + Math.sin(aimDir) * beamLen;
            const byEnd = headY + Math.cos(aimDir) * 28;
            const perpX = -Math.cos(aimDir) * 18;
            const perpY = Math.sin(aimDir) * 34;
            fillGradQuad(
                uiGlow,
                headX, headY - 4, Color(246, 224, 178, Math.round(68 + 44 * lampTurnProg)),
                headX, headY + 4, Color(246, 224, 178, Math.round(68 + 44 * lampTurnProg)),
                bxEnd + perpX, byEnd + perpY + 34, Color(238, 206, 148, 0),
                bxEnd - perpX, byEnd - perpY - 22, Color(238, 206, 148, 0),
            );
            fillRadialGlow(uiGlow, headX, headY, 34, 34, Color(246, 228, 186, 78), Color(224, 194, 140, 0), 14);
        }

        // 5. 自由步行的周戍（沿用真实明初像素立绘，与常规世界场景同尺度 ~192px，不再腰斩缩水）
        const playerSx = toScreenX(this.hallWalkX);
        const moving = !inLampTurn && this.hallMoving;
        const slot = moving ? "soldier_run" : "soldier_idle";
        const frame = moving ? Math.floor(this.hallWalkAnim) : 0;
        const charH = Math.round(192 * Math.max(0.75, Math.min(1.25, h / 720)));
        const charW = Math.round(charH * 0.45);
        // 脚底接地微影与磨石反光影
        uiDraw.drawEllipse(Vec2(playerSx, floorY + 2), 34, 6.5, Color(6, 8, 12, 178));
        uiDraw.drawEllipse(Vec2(playerSx, floorY - 14), 24, 4.5, Color(16, 20, 28, 62));
        const pose = {
            facing: this.hallFacing,
            frame,
            layer: 3,
        };
        const running = moving && uiArt.tryPlaceRun("soldier", "fe06_museum_zhoushu", playerSx, floorY + 2,
            charW, charH, this.hallWalkAnim / 4, pose);
        if (!running && !uiArt.tryPlace(slot, "fe06_museum_zhoushu", playerSx, floorY + 2, charW, charH, pose)) {
            // 无贴图兜底剪影
            uiDraw.drawRect(Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), toColor(CUFF_PALETTE.indigoBase));
            uiDraw.drawCircle(Vec2(playerSx, floorY + charH * 0.92), 16, Color(66, 73, 76, 255));
        }

        // 玻璃柜前收械后的克制状态轻反馈（无大弹窗，短促微印）
        if (this.holstered && !inLampTurn && Math.abs(this.hallWalkX - this.caseX) <= 130) {
            const subA = clamp01(1 - Math.abs(this.hallWalkX - this.caseX) / 145) * 0.86;
            ctx.texts.put(
                "xs",
                "已收起随身器物",
                caseSx,
                floorY + 252,
                toColor(PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                0.9,
                subA,
            );
        }

        // 远方童声脚步回响（静音/灰度可读的细微远景声纹，位于右侧末厅方向）
        if (this.childEchoVisualT > 0) {
            const echoK = 1 - clamp01(this.childEchoVisualT / 2.1);
            const ex = Math.min(w - 110, toScreenX(this.caseX + 310));
            const ey = floorY + 32;
            const ea = Math.round(Math.sin(echoK * Math.PI) * 165);
            drawCircleRing(uiInkDraw, ex, ey, 14 + echoK * 46, Color(0, 0, 0, 0), 1.1, Color(224, 214, 194, ea), 28);
            drawCircleRing(uiInkDraw, ex, ey, 8 + echoK * 28, Color(0, 0, 0, 0), 0.9, Color(224, 214, 194, Math.round(ea * 0.7)), 24);
            ctx.texts.put(
                "xs",
                "（远方传来轻快的孩童脚步声）",
                w * 0.5,
                84,
                toColor(PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                1.0,
                Math.sin(echoK * Math.PI) * 0.85,
            );
        }

        // 6. 入厅现代抗日主题字幕（仅入厅前数秒缓现，不锁移动）
        if (!inLampTurn) {
            const fadeIn = smoothstep(0, MUSEUM_TIMINGS.hallIntroFadeIn, this.hallIntroElapsed);
            const fadeOut = 1 - smoothstep(
                MUSEUM_TIMINGS.hallIntroFadeIn + MUSEUM_TIMINGS.hallIntroHold,
                MUSEUM_TIMINGS.hallIntroFadeIn + MUSEUM_TIMINGS.hallIntroHold + MUSEUM_TIMINGS.hallIntroFadeOut,
                this.hallIntroElapsed,
            );
            const introA = fadeIn * fadeOut;
            if (introA > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "fe06_hall_intro_veil", w * 0.5, h - 104, 480, 74, PALETTE.inkVoid, 0.78 * introA, 1);
                drawHairline(uiInkDraw, uiArt, "fe06_hall_intro_line", w * 0.5, h - 106, 260, PALETTE.silkLine, 0.45 * introA, false, 4);
                ctx.texts.put("md", MUSEUM_HALL_TITLE, w * 0.5, h - 88, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, introA);
                ctx.texts.put("xs", MUSEUM_HALL_SUBTITLE, w * 0.5, h - 122, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, introA * 0.88);
            }

            // 默认零浮签；仅当开启「按键辅助」且走近西窗灯时才出现轻量提示
            if (this.nearLamp && ctx.view.assistHintsEnabled) {
                drawSilkVeil(uiDraw, uiArt, "fe06_lamp_hint_veil", lampSx, floorY + 158, 146, 28, PALETTE.panelBg, 0.84, 1);
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

        // 7. 转灯阶段：定稿唯一台词「小满，外头天亮了。」与展厅第一声轻叩波纹
        if (inLampTurn && this.lampElapsed >= MUSEUM_TIMINGS.lampLineAt) {
            const lineA = smoothstep(MUSEUM_TIMINGS.lampLineAt, MUSEUM_TIMINGS.lampLineAt + 0.45, this.lampElapsed)
                * (1 - smoothstep(MUSEUM_TIMINGS.lampTurnDuration - 0.35, MUSEUM_TIMINGS.lampTurnDuration, this.lampElapsed));
            if (lineA > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "fe06_dawn_line_veil", w * 0.5, 86, 440, 50, PALETTE.inkVoid, 0.84 * lineA, 1);
                ctx.texts.put(
                    "md",
                    MUSEUM_LINE_DAWN,
                    w * 0.5,
                    86,
                    toColor(PALETTE.amberCore),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.6,
                    lineA,
                );
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
     * E02 尾声：第二声轻叩落在明初厨柜板 → 直接复用 `cuff_shots.ts` 的 `drawPatchedCuff()` 接回同一截补线袖口 → 交还寻柜
     */
    private renderE02ReturnCabinet(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        w: number,
        h: number,
    ): void {
        const t = this.returnElapsed;
        const fadeOut = 1 - smoothstep(MUSEUM_TIMINGS.returnFadeOutAt, MUSEUM_TIMINGS.returnCabinetDuration, t);

        // 0.00..0.42s：承接展厅第一声轻叩的暗幕停顿
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 13, Math.round(252 * fadeOut)));

        if (t < MUSEUM_TIMINGS.returnKnock2At) {
            this.drawLetterbox(uiInkDraw, w, h, 42, 0.95 * fadeOut);
            return;
        }

        // 0.42s 起：第二声木板叩响落回明初倒柜边
        const revealK = smoothstep(MUSEUM_TIMINGS.returnKnock2At, MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut;
        const boxW = Math.min(w - 140, 820);
        const boxH = Math.min(h - 190, 390);
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5 + 10;

        // 明初暗木柜内与柜沿背景（与 P03 同一构图语汇）
        fillVGradRect(
            uiDraw,
            bx,
            by,
            boxW,
            boxH,
            Color(13, 12, 16, Math.round(248 * revealK)),
            Color(24, 24, 30, Math.round(248 * revealK)),
        );
        // 左侧厨柜暗缝与厚重明初旧木柜板
        const cabEdgeX = bx + boxW * 0.58;
        uiDraw.drawRect(Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), Color(42, 31, 24, Math.round(246 * revealK)));
        uiDraw.drawSegment(Vec2(cabEdgeX, by), Vec2(cabEdgeX, by + boxH), 2.4, Color(116, 92, 68, Math.round(220 * revealK)));
        // 柜板木纹细线
        let gi = 0;
        for (gi = 0; gi < 5; gi++) {
            const gx = cabEdgeX + 26 + gi * 44;
            if (gx < bx + boxW - 10) {
                uiDraw.drawSegment(Vec2(gx, by + 12), Vec2(gx, by + boxH - 12), 1.0, Color(28, 20, 15, Math.round(140 * revealK)));
            }
        }
        // 柜缝冷月微光
        fillHGradRect(
            uiGlow,
            cabEdgeX - 58,
            by + 24,
            58,
            boxH - 48,
            Color(168, 188, 210, 0),
            Color(186, 206, 226, Math.round(42 * revealK)),
        );

        // 第二声实木叩响的柜板细波纹（无声可读）
        if (this.knock2VisualT > 0) {
            const k2 = 1 - clamp01(this.knock2VisualT / 0.9);
            const k2A = Math.round((1 - k2) * 215 * fadeOut);
            drawCircleRing(uiInkDraw, cabEdgeX + 8, by + boxH * 0.50, 10 + k2 * 56, Color(0, 0, 0, 0), 1.6, Color(232, 220, 196, k2A), 28);
        }

        // 四镜同源补线青布袖口（直接调用 cuff_shots.drawPatchedCuff，共享 CUFF_PALETTE 6 针斜补线）
        const extendK = smoothstep(MUSEUM_TIMINGS.returnKnock2At + 0.08, MUSEUM_TIMINGS.returnKnock2At + 1.05, t);
        const wristX = bx + 115 + extendK * (cabEdgeX - bx - 168);
        const wristY = by + boxH * 0.50;
        drawPatchedCuff(uiInkDraw, uiGlow, {
            wristX,
            wristY,
            angleRad: -0.04 * (1 - extendK),
            scale: 1.02,
            pose: "reach",
            opacity: revealK,
            stitchHighlight: 0.48 + 0.22 * extendK,
            cuffPullBack: 0.06,
            warmth: 0.16,
        });

        // 素雅细框与微弱回柜提示
        uiInkDraw.drawRect(Rect(bx, by, boxW, boxH), Color(0, 0, 0, 0), 1.2, toColor(PALETTE.silkDim, Math.round(160 * revealK)));
        const tipA = smoothstep(MUSEUM_TIMINGS.returnKnock2At + 0.45, MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut;
        if (tipA > 0.03) {
            drawSilkVeil(uiDraw, uiArt, "fe06_return_veil", w * 0.5, by - 30, 320, 32, PALETTE.inkVoid, 0.72 * tipA, 1);
            ctx.texts.put(
                "xs",
                "两声轻敲落回柜板 · 寻回小满",
                w * 0.5,
                by - 30,
                toColor(PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                1.2,
                tipA * 0.9,
            );
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
