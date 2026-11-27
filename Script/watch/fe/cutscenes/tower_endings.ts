/**
 * 《向西守望》北塔双结局同机位配对演出插件（Wave 2 · feature/fe-05-dual-endings）。
 *
 * 设计红线（严格对表《wave2-04-06.md》《游戏分镜稿》《动画插入与演出规划》《剧情与剧本》《明朝全局美术设定》）：
 * 1. 同机位像素级配对（F03 女主单人线 vs M03 男主同行线）：
 *    - 全部门廊、门槛、提灯、西窗、木案、宣纸收籍簿、第 1/2 行基线、执笔悬停笔尖、热瓷碗沿锚点
 *      统一由 TOWER_SHOT_LAYOUT 单一真源派生，两版并排对照误差恒为 0.00 px；
 * 2. 共用前段节拍（总约 8.0 秒，精确对齐后端 tower-knock / tower-given / tower-end）：
 *    - 0.00s（第 0 拍 / knock=1）与 0.20s（第 12 拍 / knock=2）门外主动轻叩两下 →
 *      静默一息 → 0.42s / 0.54s 门内回叩两声 → 0.60s 守卒推门提灯先照见手与腕上针套 →
 *      1.40s–3.40s 摊开宋明冷素宣纸收籍簿，落笔写下第一行「肆拾壹 · 小满」→
 *      3.40s–4.20s 毛笔悬停于第二行同一坐标支点（brushHoverTipPos）；
 * 3. 双线分歧与收尾构图：
 *    - F03（女主单人线 · 低模材质与镜头 + 西窗暖灯）：沿用 lowpoly.ts 切面着色（MING_MATERIALS + TOWER_WEST_LAMP_LIGHT），
 *      悬停笔尖不落，小满轻问「朝西那盏灯，能留着吗？」→ 守卒端灯搁上西窗台改变全室冷暖气氛 →
 *      留白的第二行不盖完成章、不加任务完成标识，以「空着的第二行 + 碗沿」同框收尾；
 *    - M03（男主同行线 · 序章像素风 + 团圆暖室）：周戍牵小满跨过门槛，从同一悬停笔尖切入，
 *      周戍亲口报出「周戍。」→ 守卒写满第二行「肆拾贰 · 周戍」→ 小满解下腕上针套轻放木案，双手端起热碗 →
 *      以「写满两行的簿页 + 桌上针套 + 双手端碗沿」同框落团圆结局；
 * 4. 协作零冲突与边界保护：
 *    - 仅挂载 update 与 drawCutsceneOverlay，不触碰 drawBackdrop/drawWorld（与 fe-04 零冲突），
 *      不改动 frontend.ts / narrative.ts / audio.ts / contract.ts / 任何后端文件；
 *    - 全部动画吃 worldDt（暂停完全冻结、恢复无漂移防重播）；
 *    - 结局台词与定格读完前消化旧按键输入；室内重试不重关塔门、登记簿采用固定双槽永不重复追加行；
 *    - 全部正文使用 xs/sm/md（霞鹜新致宋），片尾落款仅用已验字「向西守望」（龙藏体），0 缺字。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play, TOWER_CONFIRM_TICKS } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { AudioDirector } from "Script/watch/fe/audio";
import { DualRouteContract, DualRouteSnapshot } from "Script/watch/fe/contract";
import { CUFF_PALETTE, drawPatchedCuff } from "Script/watch/fe/cutscenes/cuff_shots";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { NEEDLE_NOTE_LINES } from "Script/watch/dialogues";
import { getActiveTarget } from "Script/watch/target";
import type { WatchFrontend } from "Script/watch/fe/frontend";
import {
    LightRig,
    MING_MATERIALS,
    TOWER_WEST_LAMP_LIGHT,
    clamp01,
    normalize3,
    shadeSurface,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import { ComicKeyframe, drawComicSequence } from "Script/watch/fe/renderer/slideshow";
import {
    PALETTE,
    RGBA,
    drawHairline,
    drawSilkVeil,
    fillGradQuad,
    fillRadialGlow,
    fillVGradRect,
    lerpRGBA,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

export type TowerEndingRoute = "child" | "soldier";
export type TowerEndingVisualStyle = "lowpoly" | "pixel";
export type TowerEndingStage =
    | "idle"
    | "porch_knock"
    | "door_open"
    | "book_row1"
    | "pivot_hover"
    | "diverge_action"
    | "ending_hold";

export interface TowerEndingTimings {
    readonly knock1Sec: number;
    readonly knock2Sec: number;
    readonly reply1Sec: number;
    readonly reply2Sec: number;
    readonly doorOpenSec: number;
    readonly indoorCutSec: number;
    readonly row1StartSec: number;
    readonly row1EndSec: number;
    readonly pivotStartSec: number;
    readonly pivotEndSec: number;
    readonly divergeEndSec: number;
    readonly holdReadySec: number;
}

/** 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍 */
export const TOWER_ENDING_TIMINGS: TowerEndingTimings = {
    knock1Sec: 0.00,
    knock2Sec: 0.20,
    reply1Sec: 0.42,
    reply2Sec: 0.54,
    doorOpenSec: 0.60,
    indoorCutSec: 1.40,
    row1StartSec: 2.20,
    row1EndSec: 3.40,
    pivotStartSec: 3.40,
    pivotEndSec: 4.20,
    divergeEndSec: 6.80,
    holdReadySec: TOWER_CONFIRM_TICKS / 60,
};

const TOWER_AUDIO_ROOT = "assets/audio/tower/";

export const TOWER_AUDIO_FILES = {
    knock1: TOWER_AUDIO_ROOT + "door_knock_1.wav",
    knock2: TOWER_AUDIO_ROOT + "door_knock_2.wav",
    reply1: TOWER_AUDIO_ROOT + "door_reply_1.wav",
    reply2: TOWER_AUDIO_ROOT + "door_reply_2.wav",
    doorOpen: TOWER_AUDIO_ROOT + "door_open.wav",
    bookOpen: TOWER_AUDIO_ROOT + "book_open.wav",
    brush1: TOWER_AUDIO_ROOT + "brush_write_1.wav",
    brush2: TOWER_AUDIO_ROOT + "brush_write_2.wav",
    lampMove: TOWER_AUDIO_ROOT + "lamp_move.wav",
    needlePlace: TOWER_AUDIO_ROOT + "needle_case_place.wav",
    bowlSet: TOWER_AUDIO_ROOT + "bowl_set.wav",
    windCold: TOWER_AUDIO_ROOT + "tower_wind_cold.wav",
    roomWarm: TOWER_AUDIO_ROOT + "tower_room_warm.wav",
    lineXiaomanLamp: TOWER_AUDIO_ROOT + "line_xiaoman_lamp.wav",
    lineZhoushuName: TOWER_AUDIO_ROOT + "line_zhoushu_name.wav",
};

/**
 * 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
 * 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
 */
export const TOWER_SHOT_LAYOUT = {
    refW: 1280,
    refH: 720,
    letterboxH: 60,
    // 第一幕：门廊与塔门
    doorCenterX: 640,
    thresholdY: 168,
    doorW: 248,
    doorH: 374,
    knockHandX: 574,
    knockHandY: 312,
    doorLanternX: 710,
    doorLanternY: 344,
    // 第二、三幕：值夜室西窗、木案、宣纸收籍簿、悬停笔尖与同框碗沿
    westWindowX: 88,
    westWindowY: 382,
    westWindowW: 236,
    westWindowH: 224,
    deskTopY: 260,
    lampDeskX: 356,
    lampDeskY: 332,
    lampWindowX: 206,
    lampWindowY: 422,
    bookX: 416,
    bookY: 196,
    bookW: 588,
    bookH: 386,
    row1Y: 454,
    row1SubY: 424,
    row2Y: 354,
    row2SubY: 324,
    brushHoverTipX: 556,
    brushHoverTipY: 358,
    needleCaseDeskX: 294,
    needleCaseDeskY: 204,
    bowlRimX: 954,
    bowlRimY: 184,
    inkstoneX: 1112,
    inkstoneY: 256,
};

export interface TowerAnchorSnapshot {
    doorCenterX: number;
    thresholdY: number;
    knockHandX: number;
    knockHandY: number;
    bookX: number;
    bookY: number;
    bookW: number;
    bookH: number;
    row1Y: number;
    row2Y: number;
    brushHoverTipX: number;
    brushHoverTipY: number;
    bowlRimX: number;
    bowlRimY: number;
    lampCurX: number;
    lampCurY: number;
}

export interface TowerEndingDebugState {
    active: boolean;
    isRehearsal: boolean;
    route: TowerEndingRoute;
    visualStyle: TowerEndingVisualStyle;
    stage: TowerEndingStage;
    seqElapsed: number;
    holdElapsed: number;
    doorOpened: boolean;
    knockCount: number;
    replyKnockCount: number;
    row1Written: boolean;
    row1Name: string;
    row2Written: boolean;
    row2Name: string;
    row2Blank: boolean;
    /** 严守红线：空行不盖完成章、不加任务完成标识 */
    hasCompletionStamp: boolean;
    registryRowCapacity: number;
    registryAppendCount: number;
    lampProgress: number;
    lampAtWestWindow: boolean;
    needleCaseOnDesk: boolean;
    twoHandsHoldingBowl: boolean;
    staleInputMustRelease: boolean;
    confirmReady: boolean;
    earlyInputBlockedCount: number;
    rehearsalAcknowledged: boolean;
    indoorRetryCount: number;
    doorClosedAfterRetry: boolean;
    subtitleText: string;
    anchors: TowerAnchorSnapshot;
}

export interface TowerRehearsalOptions {
    seekTime?: number;
    indoorRetry?: boolean;
    tag?: string;
}

const F03_DIALOGUE = "「朝西那盏灯，能留着吗？」";
const M03_DIALOGUE = "「周戍。」";

/** F03 / M03 北塔门廊同机位配对硬核漫画拍表（0.00..0.60s 门外两叩 → 0.60..1.40s 推门提灯） */
const F03_PORCH_COMIC_SEQ: readonly ComicKeyframe[] = [
    { slot: "comic_tower_f03_porch_01_knock", start: 0.00, end: 0.60, zoomFrom: 1.00, zoomTo: 1.012, transition: "cut" },
    { slot: "comic_tower_f03_porch_02_open", start: 0.60, end: 1.50, zoomFrom: 1.008, zoomTo: 1.02, transition: "cut" },
];
const M03_PORCH_COMIC_SEQ: readonly ComicKeyframe[] = [
    { slot: "comic_tower_m03_porch_01_knock", start: 0.00, end: 0.60, zoomFrom: 1.00, zoomTo: 1.012, transition: "cut" },
    { slot: "comic_tower_m03_porch_02_open", start: 0.60, end: 1.50, zoomFrom: 1.008, zoomTo: 1.02, transition: "cut" },
];

/** F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值 */
const TOWER_COLD_DAWN_LIGHT: LightRig = {
    keyDir: normalize3(vec3(-0.34, 0.72, -0.60)),
    keyColor: rgba(146, 174, 206, 255),
    keyStrength: 0.74,
    rimDir: normalize3(vec3(0.68, 0.44, -0.58)),
    rimColor: rgba(182, 166, 140, 255),
    rimStrength: 0.24,
    ambientColor: rgba(18, 24, 38, 255),
    fogColor: rgba(16, 22, 34, 255),
    fogStartZ: 50,
    fogEndZ: 460,
    fogMaxAlpha: 0.78,
    shadowContrast: 0.78,
};

function lerp(a: number, b: number, t: number): number {
    return a + (b - a) * t;
}

function lerpLightRig(a: LightRig, b: LightRig, t: number): LightRig {
    const k = clamp01(t);
    return {
        keyDir: normalize3(vec3(
            lerp(a.keyDir.x, b.keyDir.x, k),
            lerp(a.keyDir.y, b.keyDir.y, k),
            lerp(a.keyDir.z, b.keyDir.z, k),
        )),
        keyColor: lerpRGBA(a.keyColor, b.keyColor, k),
        keyStrength: lerp(a.keyStrength, b.keyStrength, k),
        rimDir: normalize3(vec3(
            lerp(a.rimDir.x, b.rimDir.x, k),
            lerp(a.rimDir.y, b.rimDir.y, k),
            lerp(a.rimDir.z, b.rimDir.z, k),
        )),
        rimColor: lerpRGBA(a.rimColor, b.rimColor, k),
        rimStrength: lerp(a.rimStrength, b.rimStrength, k),
        ambientColor: lerpRGBA(a.ambientColor, b.ambientColor, k),
        fogColor: lerpRGBA(a.fogColor, b.fogColor, k),
        fogStartZ: lerp(a.fogStartZ, b.fogStartZ, k),
        fogEndZ: lerp(a.fogEndZ, b.fogEndZ, k),
        fogMaxAlpha: lerp(a.fogMaxAlpha, b.fogMaxAlpha, k),
        shadowContrast: lerp(a.shadowContrast, b.shadowContrast, k),
    };
}

function computeScaledAnchors(uiW: number, uiH: number, lampProg: number): {
    s: number;
    ox: number;
    oy: number;
    anchors: TowerAnchorSnapshot;
} {
    const s = Math.min(uiW / TOWER_SHOT_LAYOUT.refW, uiH / TOWER_SHOT_LAYOUT.refH);
    const ox = (uiW - TOWER_SHOT_LAYOUT.refW * s) * 0.5;
    const oy = (uiH - TOWER_SHOT_LAYOUT.refH * s) * 0.5;
    const lx = lerp(TOWER_SHOT_LAYOUT.lampDeskX, TOWER_SHOT_LAYOUT.lampWindowX, lampProg);
    const ly = lerp(TOWER_SHOT_LAYOUT.lampDeskY, TOWER_SHOT_LAYOUT.lampWindowY, lampProg)
        + Math.sin(Math.PI * lampProg) * 34;
    return {
        s,
        ox,
        oy,
        anchors: {
            doorCenterX: ox + TOWER_SHOT_LAYOUT.doorCenterX * s,
            thresholdY: oy + TOWER_SHOT_LAYOUT.thresholdY * s,
            knockHandX: ox + TOWER_SHOT_LAYOUT.knockHandX * s,
            knockHandY: oy + TOWER_SHOT_LAYOUT.knockHandY * s,
            bookX: ox + TOWER_SHOT_LAYOUT.bookX * s,
            bookY: oy + TOWER_SHOT_LAYOUT.bookY * s,
            bookW: TOWER_SHOT_LAYOUT.bookW * s,
            bookH: TOWER_SHOT_LAYOUT.bookH * s,
            row1Y: oy + TOWER_SHOT_LAYOUT.row1Y * s,
            row2Y: oy + TOWER_SHOT_LAYOUT.row2Y * s,
            brushHoverTipX: ox + TOWER_SHOT_LAYOUT.brushHoverTipX * s,
            brushHoverTipY: oy + TOWER_SHOT_LAYOUT.brushHoverTipY * s,
            bowlRimX: ox + TOWER_SHOT_LAYOUT.bowlRimX * s,
            bowlRimY: oy + TOWER_SHOT_LAYOUT.bowlRimY * s,
            lampCurX: ox + lx * s,
            lampCurY: oy + ly * s,
        },
    };
}

function deriveStage(seqElapsed: number, active: boolean): TowerEndingStage {
    if (!active) {
        return "idle";
    }
    if (seqElapsed < TOWER_ENDING_TIMINGS.doorOpenSec) {
        return "porch_knock";
    }
    if (seqElapsed < TOWER_ENDING_TIMINGS.indoorCutSec) {
        return "door_open";
    }
    if (seqElapsed < TOWER_ENDING_TIMINGS.pivotStartSec) {
        return "book_row1";
    }
    if (seqElapsed < TOWER_ENDING_TIMINGS.pivotEndSec) {
        return "pivot_hover";
    }
    if (seqElapsed < TOWER_ENDING_TIMINGS.divergeEndSec) {
        return "diverge_action";
    }
    return "ending_hold";
}

/** 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字） */
function joinPrefixTokens(tokens: readonly string[], progress: number): string {
    if (progress <= 0 || tokens.length === 0) {
        return "";
    }
    const count = Math.max(1, Math.min(tokens.length, Math.ceil(progress * tokens.length)));
    let out = "";
    let i = 0;
    for (i = 0; i < count; i++) {
        out = out + tokens[i];
    }
    return out;
}

const ROW1_TOKENS = ["小", "满", "  ", "·", "  ", "已", "收"];
const ROW2_SOLDIER_TOKENS = ["周", "戍", "  ", "·", "  ", "兄", "妹", "同", "行", "  ", "·", "  ", "已", "收"];

function asRecord(v: unknown): Record<string, unknown> | undefined {
    if (v !== undefined && typeof v === "object") {
        return v as Record<string, unknown>;
    }
    return undefined;
}

/** 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰） */
function strokeEllipse(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    width: number,
    color: Color.Type,
    segments: number = 24,
): void {
    if (rx <= 0.5 || ry <= 0.5 || width <= 0.05) {
        return;
    }
    const step = (Math.PI * 2) / segments;
    let prevX = cx + rx;
    let prevY = cy;
    let i = 1;
    for (i = 1; i <= segments; i++) {
        const ang = i * step;
        const nx = cx + Math.cos(ang) * rx;
        const ny = cy + Math.sin(ang) * ry;
        draw.drawSegment(Vec2(prevX, prevY), Vec2(nx, ny), width, color);
        prevX = nx;
        prevY = ny;
    }
}

const STONE_EDGE_FALLBACK: RGBA = MING_MATERIALS.mingStoneStep.edge ?? PALETTE.silkDim;

export class TowerEndingsPlugin implements FeRenderPlugin {
    readonly id = "fe-05-tower-endings";

    private active = false;
    private rehearsalActive = false;
    private rehearsalRoute: TowerEndingRoute = "child";
    private activeRoute: TowerEndingRoute = "child";

    private seqElapsed = 0;
    private holdElapsed = 0;
    private animTime = 0;

    // 门与固定双槽登记簿（永不追加第三行）
    private doorOpened = false;
    private knockCount = 0;
    private replyKnockCount = 0;
    private row1Written = false;
    private row2Written = false;
    private registryAppendCount = 0;

    // 防误触与旧按键消化
    private staleInputMustRelease = false;
    private confirmReady = false;
    private earlyInputBlockedCount = 0;
    private rehearsalAcknowledged = false;

    // 室内重试边界追踪
    private lastRoomKey = "";
    private lastRunRef: unknown;
    private indoorRetryCount = 0;
    private doorClosedAfterRetry = false;
    private sessionId = 0;

    // 当前画面与锚点快照
    private lastUiW = 1280;
    private lastUiH = 720;
    private lastSubtitle = "";
    private prevPhase = "";
    private loopsActive = false;
    /** 敲门结束进入 tower-enter 时承接 0.90s 非阻塞推门提灯淡出过渡，既完整呈现开门演出又不锁控/不遮挡跨门槛 */
    private doorOpenOverlayElapsed = -1;

    /** 按严格双线红线推导北塔结局路线：只读锁存 storyRoute（兼容 B2 ending，绝不碰即时 HP 或 run.route） */
    private resolveRoute(p: Play, view: DualRouteSnapshot): TowerEndingRoute {
        if (this.rehearsalActive) {
            return this.rehearsalRoute;
        }
        if (view.storyRoute === "soldier") {
            return "soldier";
        }
        if (view.storyRoute === "child") {
            return "child";
        }
        // 兼容 B2 已写出的 run.story.ending 字段（只读辅助校验）
        const runRec = asRecord(p.run);
        const storyRec = asRecord(runRec !== undefined ? runRec["story"] : undefined);
        if (storyRec !== undefined && storyRec["ending"] === "reunion") {
            return "soldier";
        }
        // 正式单人降级（尚未接入 B2 锁存字段时，按当前角色模式安全回退）
        return p.childMode ? "child" : "soldier";
    }

    private clearSequenceState(keepIndoorDoorOpen: boolean): void {
        this.active = keepIndoorDoorOpen;
        this.seqElapsed = keepIndoorDoorOpen ? TOWER_ENDING_TIMINGS.indoorCutSec : 0;
        this.holdElapsed = 0;
        this.doorOpened = keepIndoorDoorOpen;
        this.knockCount = keepIndoorDoorOpen ? 2 : 0;
        this.replyKnockCount = keepIndoorDoorOpen ? 2 : 0;
        if (!keepIndoorDoorOpen) {
            this.row1Written = false;
            this.row2Written = false;
            this.registryAppendCount = 0;
        }
        this.staleInputMustRelease = true;
        this.confirmReady = false;
        this.earlyInputBlockedCount = 0;
        this.rehearsalAcknowledged = false;
        this.lastSubtitle = "";
        this.doorOpenOverlayElapsed = -1;
    }

    // ==================== 排演与自动化验证钩子 ====================

    /** 显式启动北塔双结局排演（独立于正式存档，支持直接定位到任意拍点或室内重试态） */
    startRehearsal(
        route: TowerEndingRoute,
        contract?: DualRouteContract,
        opts?: TowerRehearsalOptions,
    ): void {
        this.rehearsalActive = true;
        this.rehearsalRoute = route;
        this.activeRoute = route;
        const tag = opts?.tag ?? (route === "child" ? "fe05-F03" : "fe05-M03");
        if (contract !== undefined) {
            contract.enterRehearsal(tag);
            contract.setMockRoute(route);
        }
        const isIndoor = opts?.indoorRetry === true;
        this.sessionId += 1;
        this.clearSequenceState(isIndoor);
        this.active = true;
        this.doorClosedAfterRetry = false;
        if (isIndoor) {
            this.indoorRetryCount += 1;
        }
        if (opts?.seekTime !== undefined) {
            this.seekRehearsal(opts.seekTime);
        }
    }

    /** 精准定格排演时间点（如 0.0 / 0.2 / 0.42 / 1.4 / 3.8 支点 / 6.0 / 8.0 定格） */
    seekRehearsal(seconds: number): void {
        if (!this.rehearsalActive) {
            return;
        }
        const t = Math.max(0, seconds);
        this.seqElapsed = t;
        this.holdElapsed = Math.max(0, t - TOWER_ENDING_TIMINGS.divergeEndSec);
        this.active = true;
        this.syncDerivedMilestones(t, this.activeRoute);
        this.confirmReady = !this.staleInputMustRelease && t >= TOWER_ENDING_TIMINGS.holdReadySec;
    }

    /** 显式模拟「室内重试」（不关塔门、不重播敲门、不重复追加登记行） */
    triggerIndoorRetry(): void {
        if (!this.doorOpened && this.seqElapsed < TOWER_ENDING_TIMINGS.doorOpenSec) {
            this.doorOpened = true;
        }
        this.indoorRetryCount += 1;
        this.doorClosedAfterRetry = false;
        this.doorOpened = true;
        this.active = true;
        this.seqElapsed = Math.max(TOWER_ENDING_TIMINGS.indoorCutSec, Math.min(this.seqElapsed, TOWER_ENDING_TIMINGS.row1StartSec));
        this.holdElapsed = 0;
        this.knockCount = Math.max(2, this.knockCount);
        this.replyKnockCount = Math.max(2, this.replyKnockCount);
        // 绝不重置或叠加登记簿行，旧按键须重新释放后才允许确认
        this.staleInputMustRelease = true;
        this.confirmReady = false;
    }

    /** 退出排演模式，彻底清空临时状态 */
    stopRehearsal(contract?: DualRouteContract): void {
        this.rehearsalActive = false;
        this.clearSequenceState(false);
        this.indoorRetryCount = 0;
        this.doorClosedAfterRetry = false;
        if (contract !== undefined) {
            contract.exitRehearsal();
        }
    }

    getDebugState(): TowerEndingDebugState {
        const route = this.activeRoute;
        const lampProg = route === "child"
            ? smoothstep(5.20, 6.75, this.seqElapsed)
            : 0;
        const scaled = computeScaledAnchors(this.lastUiW, this.lastUiH, lampProg);
        const visualStyle: TowerEndingVisualStyle = route === "child" ? "lowpoly" : "pixel";
        const needleOnDesk = route === "soldier" && this.seqElapsed >= 5.55;
        const twoHandsBowl = route === "soldier" && this.seqElapsed >= 5.95;

        return {
            active: this.active,
            isRehearsal: this.rehearsalActive,
            route,
            visualStyle,
            stage: deriveStage(this.seqElapsed, this.active),
            seqElapsed: this.seqElapsed,
            holdElapsed: this.holdElapsed,
            doorOpened: this.doorOpened,
            knockCount: this.knockCount,
            replyKnockCount: this.replyKnockCount,
            row1Written: this.row1Written,
            row1Name: this.row1Written ? "小满" : "",
            row2Written: this.row2Written,
            row2Name: this.row2Written ? "周戍" : "",
            row2Blank: !this.row2Written,
            hasCompletionStamp: false,
            registryRowCapacity: 2,
            registryAppendCount: this.registryAppendCount,
            lampProgress: lampProg,
            lampAtWestWindow: route === "child" && lampProg >= 0.99,
            needleCaseOnDesk: needleOnDesk,
            twoHandsHoldingBowl: twoHandsBowl,
            staleInputMustRelease: this.staleInputMustRelease,
            confirmReady: this.confirmReady,
            earlyInputBlockedCount: this.earlyInputBlockedCount,
            rehearsalAcknowledged: this.rehearsalAcknowledged,
            indoorRetryCount: this.indoorRetryCount,
            doorClosedAfterRetry: this.doorClosedAfterRetry,
            subtitleText: this.lastSubtitle,
            anchors: scaled.anchors,
        };
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
            if (watchFe["towerEndings"] !== this) {
                watchFe["towerEndings"] = this;
            }
        }
    }

    // ==================== FeRenderPlugin 生命周期 ====================

    onBindPlay(p: Play, view: DualRouteSnapshot): void {
        this.syncRuntimeHook();
        this.sessionId += 1;
        this.loopsActive = false;
        this.prevPhase = p.phase;

        if (this.rehearsalActive) {
            return;
        }

        const route = this.resolveRoute(p, view);
        const isTower = p.room.key === "tower";
        const alreadyCutscenePhase = isTower && (p.phase === "tower-given" || p.phase === "tower-end");
        const alreadyIndoorPhase = isTower && (
            p.phase === "tower-enter"
            || p.phase === "tower-desk"
            || alreadyCutscenePhase
        );
        const sameRunIndoorRetry = isTower
            && this.lastRoomKey === "tower"
            && this.doorOpened
            && p.run === this.lastRunRef
            && route === this.activeRoute
            && (p.checkpoint > 0 || alreadyIndoorPhase);

        this.activeRoute = route;
        this.lastRoomKey = p.room.key;
        this.lastRunRef = p.run;

        if (!isTower) {
            this.clearSequenceState(false);
            this.indoorRetryCount = 0;
            this.doorClosedAfterRetry = false;
            return;
        }

        if (sameRunIndoorRetry || alreadyCutscenePhase) {
            // 室内重试边界：塔门保持已开，不重关门，不重播敲门，不重复追加登记行
            this.indoorRetryCount += 1;
            this.doorClosedAfterRetry = false;
            this.clearSequenceState(true);
            if (p.phase === "tower-end") {
                this.seqElapsed = TOWER_ENDING_TIMINGS.divergeEndSec;
                this.syncDerivedMilestones(this.seqElapsed, route);
            }
            return;
        }

        if (p.phase === "tower-enter" || p.phase === "tower-desk") {
            // 读档恢复到门廊/值夜室交互段：保持门开但让出画面给真实走位，不误增 indoorRetryCount
            this.clearSequenceState(false);
            this.doorOpened = true;
            this.replyKnockCount = 2;
            this.active = false;
            return;
        }

        // 全新抵达北塔门廊：清零等待玩家主动叩门
        this.clearSequenceState(false);
        this.indoorRetryCount = 0;
        this.doorClosedAfterRetry = false;
    }

    update(ctx: FePluginContext): void {
        this.syncRuntimeHook();
        this.lastUiW = ctx.uiW;
        this.lastUiH = ctx.uiH;
        const p = ctx.p;

        if (!this.rehearsalActive && p.room.key !== "tower") {
            if (this.loopsActive) {
                ctx.audio.stopLoop("tower_wind_cold", 0.15);
                ctx.audio.stopLoop("tower_room_warm", 0.15);
                this.loopsActive = false;
            }
            this.active = false;
            return;
        }

        const route = this.resolveRoute(p, ctx.view);
        this.activeRoute = route;

        if (!this.rehearsalActive) {
            this.stepLiveSync(ctx, route);
        } else {
            this.stepRehearsal(ctx, route);
        }

        if (!this.active) {
            const inInteractiveHall = !this.rehearsalActive && p.room.key === "tower"
                && (p.phase === "tower-enter" || p.phase === "tower-desk");
            if (this.loopsActive && !inInteractiveHall) {
                ctx.audio.stopLoop("tower_wind_cold", 0.15);
                ctx.audio.stopLoop("tower_room_warm", 0.15);
                this.loopsActive = false;
            }
            return;
        }

        // 暂停时 worldDt === 0，动画与音效完全冻结，绝不推进或重播
        if (!ctx.paused && ctx.worldDt > 0) {
            this.animTime += ctx.worldDt;
            this.syncDerivedMilestones(this.seqElapsed, route);
            this.syncAudioCues(ctx.audio, ctx, route);
            this.stepInputGuard(ctx.input);
        } else if (!ctx.paused) {
            // 0 dt 渲染帧仍刷新派生里程碑（例如 seekRehearsal 后立即截帧），绝不触发重复音频
            this.syncDerivedMilestones(this.seqElapsed, route);
            this.stepInputGuard(ctx.input);
        }

        this.lastSubtitle = this.composeSubtitle(route);
    }

    private stepLiveSync(ctx: FePluginContext, route: TowerEndingRoute): void {
        const p = ctx.p;
        const phase = p.phase;
        const cameFromKnock = this.prevPhase === "tower-knock";
        const justEnteredKnock = this.prevPhase !== "tower-knock" && phase === "tower-knock";
        const justEnteredEnter = this.prevPhase !== "tower-enter" && phase === "tower-enter";
        const justEnteredGiven = this.prevPhase !== "tower-given" && phase === "tower-given";
        const justEnteredEnd = this.prevPhase !== "tower-end" && phase === "tower-end";
        this.prevPhase = phase;

        if (phase === "tower-wait") {
            // 门廊自由步行阶段交由基础/低模世界层处理（与 fe-04 零冲突），若曾室内重试则不关门
            this.doorOpenOverlayElapsed = -1;
            this.active = false;
            return;
        }

        if (phase === "tower-enter") {
            // 门开后立即让回画面控制权（active = false），并用 0.90s 非阻塞提灯开门淡出衔接值夜室实景
            this.doorOpened = true;
            this.replyKnockCount = Math.max(2, this.replyKnockCount);
            if (justEnteredEnter && this.indoorRetryCount === 0 && !ctx.paused) {
                const tick = p.ticks;
                this.playTowerOnce(ctx.audio, "reply1", "sfx", TOWER_AUDIO_FILES.reply1, 0.78, "tower:reply:1", tick);
                this.playTowerOnce(ctx.audio, "reply2", "sfx", TOWER_AUDIO_FILES.reply2, 0.80, "tower:reply:2", tick);
                this.playTowerOnce(ctx.audio, "door_open", "sfx", TOWER_AUDIO_FILES.doorOpen, 0.84, "tower:door_open", tick);
                ctx.audio.playLoop("tower_room_warm", "ambience", TOWER_AUDIO_FILES.roomWarm, 0.28, tick);
                this.loopsActive = true;
                if (cameFromKnock) {
                    this.doorOpenOverlayElapsed = 0;
                }
            }
            if (this.doorOpenOverlayElapsed >= 0) {
                if (p.player.x >= p.ox + 520) {
                    this.doorOpenOverlayElapsed = -1;
                } else if (!ctx.paused && ctx.worldDt > 0) {
                    this.doorOpenOverlayElapsed += ctx.worldDt;
                    if (this.doorOpenOverlayElapsed >= 0.90) {
                        this.doorOpenOverlayElapsed = -1;
                    }
                }
            }
            this.seqElapsed = Math.max(this.seqElapsed, TOWER_ENDING_TIMINGS.doorOpenSec);
            this.active = false;
            this.syncDerivedMilestones(this.seqElapsed, route);
            return;
        }

        if (phase === "tower-desk") {
            // 门开并跨过门槛后交回实景控制权，玩家在值夜桌长按交物，不让全屏过场遮挡操作。
            this.doorOpenOverlayElapsed = -1;
            this.doorOpened = true;
            this.replyKnockCount = Math.max(2, this.replyKnockCount);
            this.seqElapsed = Math.max(this.seqElapsed, TOWER_ENDING_TIMINGS.indoorCutSec);
            this.active = false;
            this.syncDerivedMilestones(this.seqElapsed, route);
            return;
        }

        if (!this.active) {
            this.active = true;
            this.staleInputMustRelease = ctx.input.interact.held || ctx.input.retry.held || ctx.input.interact.pressed;
            this.confirmReady = false;
        }

        if (justEnteredKnock) {
            this.seqElapsed = p.phaseTick / 60;
            this.holdElapsed = 0;
            this.staleInputMustRelease = true;
            this.confirmReady = false;
        } else if (justEnteredGiven) {
            this.doorOpened = true;
            this.seqElapsed = Math.max(this.seqElapsed, TOWER_ENDING_TIMINGS.indoorCutSec);
        } else if (justEnteredEnd) {
            this.doorOpened = true;
            // 无缝延续 8 秒演出，并与后端 phaseTick 下限对齐，防止尾声字幕与 D55 错拍叠字
            this.seqElapsed = Math.max(this.seqElapsed, 3.60 + p.phaseTick / 60);
        }

        // 消费后端当帧真实 knock 事件，保证第 0 拍 / 第 12 拍精确对齐
        if (!ctx.paused && ctx.events.rawEvents.length > 0) {
            let i = 0;
            for (i = 0; i < ctx.events.rawEvents.length; i++) {
                const ev = ctx.events.rawEvents[i];
                if (ev.name === "knock") {
                    const cnt = typeof ev.data.count === "number" ? ev.data.count : (this.knockCount + 1);
                    if (cnt >= 1 && this.knockCount < 1) {
                        this.knockCount = 1;
                        this.playTowerOnce(ctx.audio, "knock1", "sfx", TOWER_AUDIO_FILES.knock1, 0.88, "tower:knock:1", ev.tick, ev.seq);
                    }
                    if (cnt >= 2 && this.knockCount < 2) {
                        this.knockCount = 2;
                        this.playTowerOnce(ctx.audio, "knock2", "sfx", TOWER_AUDIO_FILES.knock2, 0.90, "tower:knock:2", ev.tick, ev.seq);
                    }
                }
            }
        }

        if (!ctx.paused && ctx.worldDt > 0) {
            if (phase === "tower-knock") {
                // 严格跟随后端 tower-knock 节拍（0..36 拍 = 0..0.60s）
                const backendSec = Math.min(TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60);
                this.seqElapsed = Math.max(this.seqElapsed + ctx.worldDt, backendSec);
                if (this.seqElapsed > TOWER_ENDING_TIMINGS.doorOpenSec - 0.001) {
                    this.seqElapsed = TOWER_ENDING_TIMINGS.doorOpenSec - 0.001;
                }
            } else {
                this.seqElapsed += ctx.worldDt;
                if (this.seqElapsed >= TOWER_ENDING_TIMINGS.divergeEndSec) {
                    this.holdElapsed += ctx.worldDt;
                }
            }
        }

        if (this.indoorRetryCount > 0 && !this.doorOpened) {
            this.doorClosedAfterRetry = true;
        }
        this.syncDerivedMilestones(this.seqElapsed, route);
    }

    private stepRehearsal(ctx: FePluginContext, route: TowerEndingRoute): void {
        this.active = true;
        if (!ctx.paused && ctx.worldDt > 0) {
            this.seqElapsed += ctx.worldDt;
            if (this.seqElapsed >= TOWER_ENDING_TIMINGS.divergeEndSec) {
                this.holdElapsed += ctx.worldDt;
            }
        }
        if (this.indoorRetryCount > 0 && !this.doorOpened) {
            this.doorClosedAfterRetry = true;
        }
        this.syncDerivedMilestones(this.seqElapsed, route);
    }

    private syncDerivedMilestones(t: number, route: TowerEndingRoute): void {
        if (t >= TOWER_ENDING_TIMINGS.knock1Sec && this.knockCount < 1) {
            this.knockCount = 1;
        }
        if (t >= TOWER_ENDING_TIMINGS.knock2Sec && this.knockCount < 2) {
            this.knockCount = 2;
        }
        if (t >= TOWER_ENDING_TIMINGS.reply1Sec && this.replyKnockCount < 1) {
            this.replyKnockCount = 1;
        }
        if (t >= TOWER_ENDING_TIMINGS.reply2Sec && this.replyKnockCount < 2) {
            this.replyKnockCount = 2;
        }
        if (t >= TOWER_ENDING_TIMINGS.doorOpenSec) {
            this.doorOpened = true;
        }
        // 固定双槽幂等写入：无论重试或快进多少次，registryAppendCount 对 F03 恒 <= 1，对 M03 恒 <= 2
        if (t >= TOWER_ENDING_TIMINGS.row1StartSec && !this.row1Written) {
            this.row1Written = true;
            this.registryAppendCount += 1;
        }
        if (route === "soldier" && t >= 4.60 && !this.row2Written) {
            this.row2Written = true;
            this.registryAppendCount += 1;
        }
        if (route === "child" && this.row2Written) {
            // 排演从 M03 切回 F03 时确保第二行保持洁净留白
            this.row2Written = false;
            this.registryAppendCount = this.row1Written ? 1 : 0;
        }
    }

    private stepInputGuard(input: Input): void {
        const keyHeld = input.interact.held || input.retry.held;
        const keyPressed = input.interact.pressed || input.retry.pressed;
        const readyTime = this.seqElapsed >= TOWER_ENDING_TIMINGS.holdReadySec;

        if (this.staleInputMustRelease) {
            if (!keyHeld) {
                this.staleInputMustRelease = false;
            } else if (keyPressed) {
                this.earlyInputBlockedCount += 1;
            }
            this.confirmReady = false;
            return;
        }

        if (!readyTime) {
            if (keyPressed) {
                this.earlyInputBlockedCount += 1;
                this.staleInputMustRelease = keyHeld;
            }
            this.confirmReady = false;
            return;
        }

        this.confirmReady = true;
        if (this.rehearsalActive && keyPressed) {
            this.rehearsalAcknowledged = true;
        }
    }

    private playTowerOnce(
        audio: AudioDirector,
        tag: string,
        track: "sfx" | "voice",
        path: string,
        volume: number,
        cueId: string,
        tick: number,
        seq: number = -1,
    ): void {
        const dedupeKey = "tower:s" + this.sessionId + ":" + tag;
        audio.playOnce(dedupeKey, track, path, volume, cueId, tick, seq);
    }

    private syncAudioCues(audio: AudioDirector, ctx: FePluginContext, route: TowerEndingRoute): void {
        const t = this.seqElapsed;
        const tick = ctx.p.ticks;
        const indoorK = smoothstep(TOWER_ENDING_TIMINGS.doorOpenSec, TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t);

        // 循环氛围音轨：拂晓山风压低、值夜室暖火渐入
        this.loopsActive = true;
        audio.playLoop("tower_wind_cold", "wind", TOWER_AUDIO_FILES.windCold, lerp(0.36, 0.14, indoorK), tick);
        if (indoorK > 0.05) {
            audio.playLoop("tower_room_warm", "ambience", TOWER_AUDIO_FILES.roomWarm, lerp(0.06, 0.34, indoorK), tick);
        }

        // 室内重试已越过门廊阶段时，不补播旧敲门与开门声
        if (this.indoorRetryCount === 0) {
            if (t >= TOWER_ENDING_TIMINGS.knock1Sec) {
                this.playTowerOnce(audio, "knock1", "sfx", TOWER_AUDIO_FILES.knock1, 0.88, "tower:knock:1", tick);
            }
            if (t >= TOWER_ENDING_TIMINGS.knock2Sec) {
                this.playTowerOnce(audio, "knock2", "sfx", TOWER_AUDIO_FILES.knock2, 0.90, "tower:knock:2", tick);
            }
            if (t >= TOWER_ENDING_TIMINGS.reply1Sec) {
                this.playTowerOnce(audio, "reply1", "sfx", TOWER_AUDIO_FILES.reply1, 0.78, "tower:reply:1", tick);
            }
            if (t >= TOWER_ENDING_TIMINGS.reply2Sec) {
                this.playTowerOnce(audio, "reply2", "sfx", TOWER_AUDIO_FILES.reply2, 0.80, "tower:reply:2", tick);
            }
            if (t >= TOWER_ENDING_TIMINGS.doorOpenSec) {
                this.playTowerOnce(audio, "door_open", "sfx", TOWER_AUDIO_FILES.doorOpen, 0.84, "tower:door_open", tick);
            }
        }

        if (t >= 1.50) {
            this.playTowerOnce(audio, "book_open", "sfx", TOWER_AUDIO_FILES.bookOpen, 0.82, "tower:book_open", tick);
        }
        if (t >= TOWER_ENDING_TIMINGS.row1StartSec) {
            this.playTowerOnce(audio, "brush1", "sfx", TOWER_AUDIO_FILES.brush1, 0.80, "tower:brush:row1", tick);
        }

        if (route === "child") {
            if (t >= 4.35) {
                this.playTowerOnce(audio, "f03_line", "voice", TOWER_AUDIO_FILES.lineXiaomanLamp, 0.86, "tower:f03:line_lamp", tick);
            }
            if (t >= 4.45) {
                this.playTowerOnce(audio, "f03_bowl", "sfx", TOWER_AUDIO_FILES.bowlSet, 0.80, "tower:bowl_set", tick);
            }
            if (t >= 5.20) {
                this.playTowerOnce(audio, "f03_lamp", "sfx", TOWER_AUDIO_FILES.lampMove, 0.82, "tower:f03:lamp_move", tick);
            }
        } else {
            if (t >= 4.28) {
                this.playTowerOnce(audio, "m03_line", "voice", TOWER_AUDIO_FILES.lineZhoushuName, 0.90, "tower:m03:line_name", tick);
            }
            if (t >= 4.62) {
                this.playTowerOnce(audio, "brush2", "sfx", TOWER_AUDIO_FILES.brush2, 0.82, "tower:brush:row2", tick);
            }
            if (t >= 5.55) {
                this.playTowerOnce(audio, "m03_needle", "sfx", TOWER_AUDIO_FILES.needlePlace, 0.80, "tower:m03:needle_place", tick);
            }
            if (t >= 6.02) {
                this.playTowerOnce(audio, "m03_bowl", "sfx", TOWER_AUDIO_FILES.bowlSet, 0.82, "tower:bowl_set", tick);
            }
        }
    }

    private composeSubtitle(route: TowerEndingRoute): string {
        const t = this.seqElapsed;
        if (t < TOWER_ENDING_TIMINGS.reply1Sec) {
            return "[两下轻敲]  门外厚木上传来两声轻敲。";
        }
        if (t < TOWER_ENDING_TIMINGS.doorOpenSec) {
            return "[门内回敲]  静默一息，门后轻轻回敲两声。";
        }
        if (t < TOWER_ENDING_TIMINGS.indoorCutSec) {
            return route === "child"
                ? "守卒推门提灯，暖光先照见她腕上的针套。"
                : "守卒推门提灯，周戍牵小满一同跨过门槛。";
        }
        if (t < TOWER_ENDING_TIMINGS.row1StartSec) {
            return route === "child"
                ? "她把针套与纸条摊在案前，守卒展开收籍末页。"
                : "两人站在值夜室内，守卒摊开收籍末页。";
        }
        if (t < TOWER_ENDING_TIMINGS.pivotStartSec) {
            return "守卒蘸墨提笔，在第一行写下「小满」。";
        }
        if (t < TOWER_ENDING_TIMINGS.pivotEndSec) {
            return "笔尖停在第二行上方。";
        }
        if (route === "child") {
            if (t < 6.70) {
                return F03_DIALOGUE;
            }
            return "";
        }
        if (t < 5.45) {
            return M03_DIALOGUE;
        }
        if (t < 6.85) {
            return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。";
        }
        return "";
    }

    // ==================== 过场覆盖层主绘制 ====================

    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            if (!this.rehearsalActive && ctx.p.room.key === "tower" && ctx.p.phase === "tower-enter" && this.doorOpenOverlayElapsed >= 0) {
                // 非阻塞推门提灯衔接：0.00..0.90s 内由暖灯开门光晕自然溶入可交互值夜室（返回 false 不遮挡操作与对白）
                const u = clamp01(this.doorOpenOverlayElapsed / 0.90);
                const fade = 1 - smoothstep(0.28, 1.0, u);
                if (fade > 0.02) {
                    const route = this.activeRoute;
                    const openK = smoothstep(0.0, 0.55, u);
                    const cx = ctx.uiW * 0.5;
                    const cy = ctx.uiH * 0.46;
                    uiDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(8, 10, 16, Math.round(145 * fade)));
                    fillRadialGlow(
                        uiGlow,
                        cx + 42 * (1 - openK),
                        cy + 16,
                        ctx.uiW * (0.26 + 0.18 * openK),
                        ctx.uiH * (0.34 + 0.16 * openK),
                        Color(248, 212, 144, Math.round(128 * fade)),
                        Color(220, 154, 72, 0),
                        18,
                    );
                    this.drawMingLantern(uiInkDraw, uiGlow, cx + 66 - openK * 24, cy + 28, 1.05, fade * (0.45 + 0.55 * openK), 1.0);
                    const cap = route === "child"
                        ? "守卒推门提灯，暖光先照见她腕上的针套。"
                        : "守卒推门提灯，周戍牵小满一同跨过门槛。";
                    drawSilkVeil(uiDraw, uiArt, "tower_door_open_veil", cx, ctx.uiH - 86, 560, 38, PALETTE.inkWarm, 0.78 * fade, 2);
                    ctx.texts.put("sm", cap, cx, ctx.uiH - 86, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.0, fade, 0.08);
                }
            }
            return false;
        }

        const route = this.activeRoute;
        const t = this.seqElapsed;
        const lampProg = route === "child" ? smoothstep(5.20, 6.75, t) : 0;
        const scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg);
        const s = scaled.s;
        const ox = scaled.ox;
        const oy = scaled.oy;

        // 1. 全屏鸦青底幕（完全接管画面，零旧世界/HUD 透穿）
        uiDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(8, 10, 16, 255));

        if (t < TOWER_ENDING_TIMINGS.indoorCutSec) {
            // 第一幕：门廊双叩、门内回叩、守卒推门提灯先照手与针套
            this.drawAct1PorchAndDoor(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy);
            // 1.22s–1.40s 柔和淡入暗渡，丝滑切入值夜室案前
            const fadeOut = smoothstep(1.22, TOWER_ENDING_TIMINGS.indoorCutSec, t);
            if (fadeOut > 0.01) {
                uiInkDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(8, 10, 16, Math.round(230 * fadeOut)));
            }
        } else {
            // 第二、三幕：值夜室案前、西窗暖灯、冷素宣纸收籍簿、同笔尖分歧与热碗同框收尾
            this.drawAct2And3Guardroom(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy);
            const fadeIn = 1 - smoothstep(TOWER_ENDING_TIMINGS.indoorCutSec, TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t);
            if (fadeIn > 0.01) {
                uiInkDraw.drawRect(Rect(0, 0, ctx.uiW, ctx.uiH), Color(8, 10, 16, Math.round(220 * fadeIn)));
            }
        }

        // 2. 统一电影上下遮幅（置顶于 uiInkDraw，边缘轻描霜月游丝）
        const barH = Math.round(TOWER_SHOT_LAYOUT.letterboxH * s);
        uiInkDraw.drawRect(Rect(0, ctx.uiH - barH, ctx.uiW, barH), Color(7, 9, 14, 248));
        uiInkDraw.drawRect(Rect(0, 0, ctx.uiW, barH), Color(7, 9, 14, 248));
        uiInkDraw.drawSegment(Vec2(0, ctx.uiH - barH), Vec2(ctx.uiW, ctx.uiH - barH), 0.9, toColor(PALETTE.silkDim, 82));
        uiInkDraw.drawSegment(Vec2(0, barH), Vec2(ctx.uiW, barH), 0.9, toColor(PALETTE.silkDim, 82));

        // 3. 克制宋明字幕幕（6.8s 后淡出让给静默定格构图；低引导关闭按键催促）
        this.drawDialogueSubtitle(uiDraw, uiInkDraw, uiArt, ctx, route, s, barH);

        return true;
    }

    // ==================== 第一幕：北塔门廊双叩与推门提灯 ====================

    private drawAct1PorchAndDoor(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        route: TowerEndingRoute,
        s: number,
        ox: number,
        oy: number,
    ): void {
        const t = this.seqElapsed;
        const openK = smoothstep(TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t);
        const doorCx = ox + TOWER_SHOT_LAYOUT.doorCenterX * s;
        const threshY = oy + TOWER_SHOT_LAYOUT.thresholdY * s;

        // 敲门声波脉冲（两线节奏完全同步，与 0px 配对硬核木刻门廊原画叠合）
        const k1Pulse = Math.exp(-Math.pow((t - TOWER_ENDING_TIMINGS.knock1Sec) / 0.055, 2));
        const k2Pulse = Math.exp(-Math.pow((t - TOWER_ENDING_TIMINGS.knock2Sec) / 0.055, 2));
        const r1Pulse = Math.exp(-Math.pow((t - TOWER_ENDING_TIMINGS.reply1Sec) / 0.06, 2));
        const r2Pulse = Math.exp(-Math.pow((t - TOWER_ENDING_TIMINGS.reply2Sec) / 0.06, 2));

        drawComicSequence(
            uiDraw,
            uiInkDraw,
            uiArt,
            route === "child" ? F03_PORCH_COMIC_SEQ : M03_PORCH_COMIC_SEQ,
            t,
            ctx.uiW,
            ctx.uiH,
            {
                letterboxH: 0,
                opacity: 1,
                layer: 1,
                instancePrefix: route === "child" ? "fe05_f03_porch" : "fe05_m03_porch",
                accentBorder: false,
            },
        );

        // 门缝暖灯柔晕与敲门声波微环（静音下也可一眼读出两次叩门与门内回叩）
        if (openK > 0.05) {
            fillRadialGlow(
                uiGlow,
                doorCx + 18 * s,
                threshY + 148 * s,
                (140 + openK * 140) * s,
                (160 + openK * 110) * s,
                Color(246, 204, 134, Math.round(92 * openK)),
                Color(220, 156, 72, 0),
                18,
            );
        }
        const kx = ox + TOWER_SHOT_LAYOUT.knockHandX * s;
        const ky = oy + TOWER_SHOT_LAYOUT.knockHandY * s;
        if (k1Pulse > 0.08 || k2Pulse > 0.08) {
            const amp = Math.max(k1Pulse, k2Pulse);
            const r = (18 + (1 - amp) * 34) * s;
            strokeEllipse(uiInkDraw, kx + 24 * s, ky, r, r * 0.85, 1.8 * s, toColor(PALETTE.amberCore, Math.round(215 * amp)), 24);
        }
        if (r1Pulse > 0.08 || r2Pulse > 0.08) {
            const amp = Math.max(r1Pulse, r2Pulse);
            const r = (24 + (1 - amp) * 42) * s;
            strokeEllipse(uiInkDraw, doorCx + 30 * s, ky + 16 * s, r, r * 0.9, 1.6 * s, toColor(PALETTE.amber, Math.round(190 * amp)), 24);
        }
    }

    // ==================== 第二、三幕：值夜室西窗、宣纸收籍簿与碗沿同框 ====================

    private drawAct2And3Guardroom(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        route: TowerEndingRoute,
        lampProg: number,
        s: number,
        ox: number,
        oy: number,
    ): void {
        const t = this.seqElapsed;
        const isLowpoly = route === "child";
        const deskY = oy + TOWER_SHOT_LAYOUT.deskTopY * s;

        // 1. 房间墙壁、西窗与木案底座（F03 全幅手绘冷室→挪灯转暖 CG；M03 同机位团圆暖晨 CG）
        const paintedRoomOk = isLowpoly
            ? this.drawF03LowpolyRoomAndWindow(uiDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy)
            : this.drawM03PixelRoomAndWindow(uiDraw, uiArt, uiGlow, ctx, s, ox, oy);

        // 2. 案前厚重明式木桌兜底（仅当手绘 CG 缺失时启用几何桌面，避免覆盖精绘木案纹理）
        if (!paintedRoomOk) {
            const deskTopCol = isLowpoly
                ? toColor(shadeSurface(
                    MING_MATERIALS.mingTimber.base,
                    vec3(-0.25, 0.90, -0.35),
                    0,
                    1,
                    lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg),
                    MING_MATERIALS.mingTimber,
                ))
                : Color(86, 60, 42, 255);
            const deskFrontCol = isLowpoly
                ? toColor(shadeSurface(
                    MING_MATERIALS.mingTimberDark.base,
                    vec3(0, 0.1, -0.99),
                    -4,
                    1,
                    lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg),
                    MING_MATERIALS.mingTimberDark,
                ))
                : Color(52, 36, 26, 255);
            uiDraw.drawPolygon([
                Vec2(0, deskY - 120 * s),
                Vec2(ctx.uiW, deskY - 120 * s),
                Vec2(ctx.uiW, deskY + 42 * s),
                Vec2(0, deskY + 42 * s),
            ], deskTopCol);
            uiDraw.drawRect(Rect(0, 0, ctx.uiW, deskY - 118 * s), deskFrontCol);
            const inkX = ox + TOWER_SHOT_LAYOUT.inkstoneX * s;
            const inkY = oy + TOWER_SHOT_LAYOUT.inkstoneY * s;
            uiDraw.drawPolygon([
                Vec2(inkX - 38 * s, inkY - 18 * s),
                Vec2(inkX + 38 * s, inkY - 18 * s),
                Vec2(inkX + 32 * s, inkY + 18 * s),
                Vec2(inkX - 32 * s, inkY + 18 * s),
            ], Color(38, 44, 52, 255), 1.2, Color(96, 106, 118, 185));
        }

        // 3. 提灯位置（F03 端灯上西窗的过程可见动态提灯并自然并入窗台暖灯；M03 由暖室 CG 提灯与动态摇曳火晕承载）
        const lx = isLowpoly
            ? ox + lerp(TOWER_SHOT_LAYOUT.lampDeskX, TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s
            : ox + TOWER_SHOT_LAYOUT.lampDeskX * s;
        const ly = isLowpoly
            ? oy + (lerp(TOWER_SHOT_LAYOUT.lampDeskY, TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + Math.sin(Math.PI * lampProg) * 34) * s
            : oy + TOWER_SHOT_LAYOUT.lampDeskY * s;
        const lampWarmth = isLowpoly ? (0.45 + 0.55 * lampProg) : 0.92;
        if (!paintedRoomOk) {
            this.drawMingLantern(uiInkDraw, uiGlow, lx, ly, 1.02 * s, 1.0, lampWarmth);
        } else if (isLowpoly) {
            // 硬核漫画原画自带明代粗陶油灯盏移灯三阶过程，仅叠呼吸暖晕
            const flicker = 0.92 + 0.08 * Math.sin(this.animTime * 7.2);
            fillRadialGlow(
                uiGlow,
                lx,
                ly + 4 * s,
                118 * s * flicker * (0.65 + 0.45 * lampProg),
                118 * s * flicker * (0.65 + 0.45 * lampProg),
                Color(250, 208, 132, Math.round((78 + 56 * lampProg) * flicker)),
                Color(228, 162, 74, 0),
                16,
            );
        } else {
            // M03 暖室西窗油灯呼吸柔光
            const flicker = 0.92 + 0.08 * Math.sin(this.animTime * 6.8);
            fillRadialGlow(
                uiGlow,
                ox + 266 * s,
                oy + 272 * s,
                148 * s * flicker,
                138 * s * flicker,
                Color(252, 212, 138, Math.round(88 * flicker)),
                Color(232, 168, 76, 0),
                16,
            );
        }

        // F03 西窗暖灯斜光照亮摊开的宣纸第二行留白区（灰度/亮处高可读）
        if (isLowpoly && lampProg > 0.04) {
            const beamA = Math.round(62 * lampProg);
            fillGradQuad(
                uiGlow,
                lx + 10 * s, ly + 30 * s, Color(248, 206, 134, beamA),
                lx + 10 * s, ly - 32 * s, Color(248, 206, 134, Math.round(beamA * 0.72)),
                ox + (TOWER_SHOT_LAYOUT.bookX + TOWER_SHOT_LAYOUT.bookW * 0.92) * s, oy + (TOWER_SHOT_LAYOUT.row2Y - 58) * s, Color(242, 198, 124, 0),
                ox + (TOWER_SHOT_LAYOUT.bookX + TOWER_SHOT_LAYOUT.bookW * 0.85) * s, oy + (TOWER_SHOT_LAYOUT.row1Y + 48) * s, Color(242, 198, 124, 0),
            );
        }

        // 4. 宋明冷素宣纸收籍簿末页（两线严格同机位、同尺寸、同第一行与同悬停笔尖！）
        const bookReveal = smoothstep(TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t);
        if (bookReveal > 0.02) {
            this.drawRegisterBook(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, bookReveal, lampProg, s, ox, oy);
        }

        // 5. 桌上物件与同框热瓷碗沿（硬核漫画原画已内置针套/碗/双袖时仅叠克制纸条与动态热气，零重复贴片）
        this.drawDeskPropsAndBowl(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, paintedRoomOk, s, ox, oy);
    }

    private drawF03LowpolyRoomAndWindow(
        uiDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        lampProg: number,
        s: number,
        ox: number,
        oy: number,
    ): boolean {
        const scaleCover = Math.max(ctx.uiW / 960, ctx.uiH / 540);
        const imgW = 960 * scaleCover;
        const imgH = 540 * scaleCover;
        const t = this.seqElapsed;
        const f03Slot = t < 3.40
            ? "comic_tower_f03_room_01_cold"
            : (t < 5.20
                ? "comic_tower_f03_room_02_hover"
                : (t < 6.20 ? "comic_tower_f03_room_03_move_lamp" : "comic_tower_f03_room_04_lit_bowl"));
        const placedComic = uiArt.tryPlace(
            f03Slot,
            "fe05_f03_comic_bg",
            ctx.uiW * 0.5,
            ctx.uiH * 0.5,
            imgW,
            imgH,
            {
                opacity: 1,
                layer: -8,
            },
        );
        if (placedComic) {
            if (lampProg > 0.02) {
                const wx = ox + TOWER_SHOT_LAYOUT.westWindowX * s;
                const wy = oy + TOWER_SHOT_LAYOUT.westWindowY * s;
                const ww = TOWER_SHOT_LAYOUT.westWindowW * s;
                fillRadialGlow(
                    uiGlow, wx + ww * 0.58, wy + 22 * s,
                    580 * s, 420 * s,
                    Color(248, 198, 122, Math.round(92 * lampProg)),
                    Color(216, 152, 68, 0),
                    20,
                );
            }
            return true;
        }

        // 兜底：无图时保持低模切面房间绘制
        const light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg);
        const wallTop = lerpRGBA(rgba(18, 24, 38, 255), rgba(46, 36, 28, 255), lampProg);
        const wallBot = lerpRGBA(rgba(12, 16, 26, 255), rgba(28, 22, 20, 255), lampProg);
        fillVGradRect(uiDraw, 0, 0, ctx.uiW, ctx.uiH, toColor(wallBot), toColor(wallTop));
        const wx = ox + TOWER_SHOT_LAYOUT.westWindowX * s;
        const wy = oy + TOWER_SHOT_LAYOUT.westWindowY * s;
        const ww = TOWER_SHOT_LAYOUT.westWindowW * s;
        const wh = TOWER_SHOT_LAYOUT.westWindowH * s;
        fillVGradRect(uiDraw, wx, wy, ww, wh, Color(34, 44, 62, 255), Color(16, 24, 40, 255));
        const sillCol = shadeSurface(MING_MATERIALS.mingStoneStep.base, vec3(0, 0.94, -0.34), 6, 1, light, MING_MATERIALS.mingStoneStep);
        uiDraw.drawRect(Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), toColor(sillCol));
        return false;
    }

    private drawM03PixelRoomAndWindow(
        uiDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        s: number,
        ox: number,
        oy: number,
    ): boolean {
        const scaleCover = Math.max(ctx.uiW / 960, ctx.uiH / 540);
        const imgW = 960 * scaleCover;
        const imgH = 540 * scaleCover;
        const t = this.seqElapsed;
        const m03Slot = t < 4.20
            ? "comic_tower_m03_room_01_warm"
            : (t < 5.45
                ? "comic_tower_m03_room_02_speak"
                : (t < 6.08 ? "comic_tower_m03_room_03_pouch" : "comic_tower_m03_room_04_bowl"));
        const placedWarm = uiArt.tryPlace(
            m03Slot,
            "fe05_m03_comic_bg",
            ctx.uiW * 0.5,
            ctx.uiH * 0.5,
            imgW,
            imgH,
            {
                opacity: 1,
                layer: -8,
            },
        );
        if (placedWarm) {
            fillRadialGlow(
                uiGlow, ox + 260 * s, oy + 416 * s,
                520 * s, 360 * s,
                Color(246, 202, 134, 62),
                Color(220, 158, 76, 0),
                20,
            );
            return true;
        }

        fillVGradRect(
            uiDraw, 0, 0, ctx.uiW, ctx.uiH,
            Color(26, 21, 20, 255),
            Color(46, 36, 30, 255),
        );
        const groupX = ox + 210 * s;
        const groupY = oy + 300 * s;
        uiArt.tryPlace("soldier_idle", "fe05_m03_room_soldier", groupX - 38 * s, groupY, 118 * s, 166 * s, {
            facing: 1, opacity: 0.90, layer: 1,
        });
        uiArt.tryPlace("child_idle", "fe05_m03_room_child", groupX + 42 * s, groupY, 86 * s, 116 * s, {
            facing: 1, opacity: 0.92, layer: 1,
        });
        return false;
    }

    private drawRegisterBook(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        route: TowerEndingRoute,
        reveal: number,
        lampProg: number,
        s: number,
        ox: number,
        oy: number,
    ): void {
        const t = this.seqElapsed;
        const bx = ox + TOWER_SHOT_LAYOUT.bookX * s;
        const by = oy + TOWER_SHOT_LAYOUT.bookY * s;
        const bw = TOWER_SHOT_LAYOUT.bookW * s;
        const bh = TOWER_SHOT_LAYOUT.bookH * s;
        const midX = bx + bw * 0.5;
        const midY = by + bh * 0.5;

        // 簿册案面柔影 + 装订青布书脊（紧贴毛边宣纸外廓，不显生硬黑方框）
        uiDraw.drawRect(Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), Color(10, 11, 16, Math.round(108 * reveal)));
        uiDraw.drawRect(Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), Color(32, 46, 62, Math.round(235 * reveal)), 1.0, Color(86, 104, 124, Math.round(165 * reveal)));

        // 冷素宣纸页（复用 ink_song_paper，无图时回退冷素宣纸底）
        if (!uiArt.tryPlace("ink_song_paper", "fe05_registry_paper", midX, midY, bw, bh, { opacity: 0.98 * reveal, layer: 1 })) {
            uiDraw.drawRect(
                Rect(bx, by, bw, bh),
                toColor(PALETTE.xuanPaper, Math.round(248 * reveal)),
                1.0,
                toColor(PALETTE.silkDim, Math.round(180 * reveal)),
            );
        }

        // 西窗暖灯照在宣纸上的柔暖受光区（F03 挪灯后格外明晰，M03 暖室恒亮）
        const paperWarm = route === "child" ? (0.18 + 0.82 * lampProg) : 0.72;
        fillRadialGlow(
            uiGlow, bx + bw * 0.34, by + bh * 0.48,
            bw * 0.58, bh * 0.52,
            Color(246, 214, 156, Math.round(44 * paperWarm * reveal)),
            Color(238, 198, 128, 0),
            16,
        );

        // 明版朱丝栏（画在 uiInkDraw 上，确保叠于宣纸之上清透锐利）
        const padX = 44 * s;
        const padY = 32 * s;
        const inX = bx + padX;
        const inY = by + padY;
        const inW = bw - padX * 2;
        const inH = bh - padY * 2;
        const redSilk = toColor(PALETTE.rouge, Math.round(132 * reveal));
        const redFaint = toColor(PALETTE.rouge, Math.round(70 * reveal));
        uiInkDraw.drawRect(Rect(inX, inY, inW, inH), Color(0, 0, 0, 0), 1.0, redSilk);
        uiInkDraw.drawRect(Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), Color(0, 0, 0, 0), 0.6, redFaint);

        // 天头：北塔值夜收籍 · 末页
        const headY = inY + inH - 28 * s;
        ctx.texts.put("md", "北塔值夜收籍 · 末页", inX + 18 * s, headY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 2.2, 0.96 * reveal, 0);
        ctx.texts.put("xs", "宁村北塔", inX + inW - 18 * s, headY, toColor(PALETTE.xuanInkSub), 1, 0.5, TextAlign.Right, 1.8, 0.80 * reveal, 0);
        uiInkDraw.drawSegment(Vec2(inX + 14 * s, headY - 22 * s), Vec2(inX + inW - 14 * s, headY - 22 * s), 0.9, redSilk);

        // 第一行：肆拾壹 · 小满（两线严格同基线、同节奏落墨）
        const row1Y = oy + TOWER_SHOT_LAYOUT.row1Y * s;
        const row1SubY = oy + TOWER_SHOT_LAYOUT.row1SubY * s;
        const r1Prog = smoothstep(TOWER_ENDING_TIMINGS.row1StartSec, TOWER_ENDING_TIMINGS.row1EndSec, t);
        ctx.texts.put("sm", "肆拾壹", inX + 18 * s, row1Y, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.0, 0.94 * reveal, 0);
        if (r1Prog > 0.02) {
            ctx.texts.put("md", joinPrefixTokens(ROW1_TOKENS, r1Prog), inX + 96 * s, row1Y, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.6, 0.96 * Math.min(1, r1Prog * 1.4), 0);
        }
        if (r1Prog > 0.65) {
            const subA = smoothstep(0.65, 1.0, r1Prog) * reveal;
            const subText = route === "child"
                ? "怀黄铜指南针、手书一纸；守城戍卒周戍所托。"
                : "与守城戍卒同行抵塔，安然入室。";
            ctx.texts.put("xs", subText, inX + 96 * s, row1SubY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.88 * subA, 0);
        }
        uiInkDraw.drawSegment(Vec2(inX + 16 * s, row1SubY - 24 * s), Vec2(inX + inW - 16 * s, row1SubY - 24 * s), 0.7, redFaint);

        // 第二行：肆拾贰（核心配对分歧——F03 彻底干净留白，M03 周戍亲口报姓名写满）
        const row2Y = oy + TOWER_SHOT_LAYOUT.row2Y * s;
        const row2SubY = oy + TOWER_SHOT_LAYOUT.row2SubY * s;
        ctx.texts.put("sm", "肆拾贰", inX + 18 * s, row2Y, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.0, 0.94 * reveal, 0);

        if (route === "child") {
            // F03：干净空行，仅留极清淡的宣纸墨格基线；绝不盖完成章、绝不加问号/锁/已完成标识
            const lineA = Math.round((105 + 55 * lampProg) * reveal);
            uiInkDraw.drawSegment(
                Vec2(inX + 96 * s, row2Y - 9 * s),
                Vec2(inX + inW - 26 * s, row2Y - 9 * s),
                1.0,
                toColor(PALETTE.xuanInkSub, lineA),
            );
        } else {
            // M03：4.60s–5.55s 从同一悬停笔尖落笔写满「周戍」
            const r2Prog = smoothstep(4.60, 5.55, t);
            if (r2Prog <= 0.02) {
                uiInkDraw.drawSegment(
                    Vec2(inX + 96 * s, row2Y - 9 * s),
                    Vec2(inX + inW - 26 * s, row2Y - 9 * s),
                    0.9,
                    toColor(PALETTE.xuanInkSub, Math.round(105 * reveal)),
                );
            } else {
                ctx.texts.put("md", joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), inX + 96 * s, row2Y, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.6, 0.96 * Math.min(1, r2Prog * 1.4), 0);
                if (r2Prog > 0.65) {
                    const subA = smoothstep(0.65, 1.0, r2Prog) * reveal;
                    ctx.texts.put("xs", "守城戍卒亲口报出姓名，两人俱安。", inX + 96 * s, row2SubY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.88 * subA, 0);
                }
            }
        }
        uiInkDraw.drawSegment(Vec2(inX + 16 * s, row2SubY - 24 * s), Vec2(inX + inW - 16 * s, row2SubY - 24 * s), 0.7, redFaint);

        // 末页落款：静默定格后在底栏浮现龙藏体「向西守望」（零完成章，严禁在空行落印）
        const colophonA = smoothstep(6.70, 7.60, t) * reveal;
        if (colophonA > 0.02) {
            const signY = inY + 34 * s;
            ctx.texts.put("banner", "向西守望", midX - 24 * s, signY, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 6.0, 0.88 * colophonA, 0);
        }

        // 守卒执短毫毛笔（在 2.10s–4.55s 或 M03 写第二行 4.55s–5.75s 出画；3.40s–4.20s 两线笔尖 0 px 锁定 brushHoverTipPos！）
        this.drawGuardBrushHand(uiInkDraw, uiArt, route, s, ox, oy);
    }

    private drawGuardBrushHand(
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        route: TowerEndingRoute,
        s: number,
        ox: number,
        oy: number,
    ): void {
        const t = this.seqElapsed;
        const hoverX = ox + TOWER_SHOT_LAYOUT.brushHoverTipX * s;
        const hoverY = oy + TOWER_SHOT_LAYOUT.brushHoverTipY * s;
        const row1X0 = hoverX;
        const row1X1 = hoverX + 142 * s;
        const row1Y = oy + TOWER_SHOT_LAYOUT.row1Y * s;

        let tipX = hoverX;
        let tipY = hoverY;
        let alpha = 0;
        let lifted = 0;

        if (t >= 2.00 && t < TOWER_ENDING_TIMINGS.row1EndSec) {
            // 落笔写第一行「小满」
            const k = smoothstep(TOWER_ENDING_TIMINGS.row1StartSec, TOWER_ENDING_TIMINGS.row1EndSec, t);
            tipX = lerp(row1X0, row1X1, k);
            tipY = row1Y + Math.sin(k * Math.PI * 6) * 3.5 * s;
            alpha = smoothstep(2.00, 2.20, t);
            lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s;
        } else if (t >= TOWER_ENDING_TIMINGS.row1EndSec && t < TOWER_ENDING_TIMINGS.pivotEndSec) {
            // 核心配对支点：两线同时滑至 brushHoverTipPos 并微停悬笔（3.60s–4.20s 坐标完全锁定）
            const moveK = smoothstep(TOWER_ENDING_TIMINGS.row1EndSec, 3.60, t);
            tipX = lerp(row1X1, hoverX, moveK);
            tipY = lerp(row1Y, hoverY, moveK);
            alpha = 1;
            lifted = 9 * s + Math.sin(this.animTime * 2.4) * 1.2 * s;
        } else if (route === "child" && t >= TOWER_ENDING_TIMINGS.pivotEndSec && t < 4.95) {
            // F03：悬笔终未落下，轻抬收出画外，留下干干净净的第二行
            const outK = smoothstep(TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t);
            tipX = hoverX + outK * 140 * s;
            tipY = hoverY + outK * 46 * s;
            lifted = (9 + outK * 28) * s;
            alpha = 1 - outK;
        } else if (route === "soldier" && t >= TOWER_ENDING_TIMINGS.pivotEndSec && t < 6.05) {
            // M03：从同一个悬停笔尖稳稳落笔写满第二行「周戍」，再从容收笔
            if (t < 4.60) {
                const dipK = smoothstep(TOWER_ENDING_TIMINGS.pivotEndSec, 4.60, t);
                tipX = hoverX;
                tipY = hoverY;
                lifted = lerp(9 * s, 0, dipK);
                alpha = 1;
            } else if (t < 5.55) {
                const wK = smoothstep(4.60, 5.55, t);
                tipX = lerp(hoverX, hoverX + 216 * s, wK);
                tipY = hoverY - 2 * s + Math.sin(wK * Math.PI * 8) * 3.2 * s;
                lifted = 0;
                alpha = 1;
            } else {
                const outK = smoothstep(5.55, 6.05, t);
                tipX = hoverX + 216 * s + outK * 115 * s;
                tipY = hoverY + outK * 52 * s;
                lifted = outK * 24 * s;
                alpha = 1 - outK;
            }
        }

        if (alpha <= 0.02) {
            return;
        }

        const a = Math.round(255 * clamp01(alpha));
        const bx = tipX;
        const by = tipY + lifted;
        // 纸面笔尖投影（反映悬停高度，悬停时与纸面有明显空隙）
        uiInkDraw.drawEllipse(Vec2(tipX + 4 * s, tipY - 3 * s), (5 + lifted * 0.22) * s, 2.8 * s, Color(20, 18, 16, Math.round(78 * alpha)));
        // 优先使用手绘守卒执笔手（笔锋左下角精确锚定在 brushHoverTipPos，0.00px 误差）
        if (uiArt.tryPlacePath(
            "assets/art/cutscene_story_parts.clip|guard_brush_hand",
            "fe05_guard_brush_hand",
            bx,
            by,
            344 * s,
            268 * s,
            {
                anchorX: 0.03,
                anchorY: 0.03,
                opacity: clamp01(alpha),
                smooth: true,
                layer: 6,
            },
        )) {
            return;
        }
        // 兜底绘制
        uiInkDraw.drawPolygon([
            Vec2(bx, by),
            Vec2(bx + 15 * s, by - 4 * s),
            Vec2(bx + 10 * s, by + 8 * s),
        ], Color(22, 22, 26, a));
        uiInkDraw.drawSegment(Vec2(bx + 12 * s, by + 2 * s), Vec2(bx + 122 * s, by + 34 * s), 6.8 * s, Color(142, 110, 74, a));
    }

    private drawDeskPropsAndBowl(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        route: TowerEndingRoute,
        paintedRoomOk: boolean,
        s: number,
        ox: number,
        oy: number,
    ): void {
        const t = this.seqElapsed;
        const ncX = ox + TOWER_SHOT_LAYOUT.needleCaseDeskX * s;
        const ncY = oy + TOWER_SHOT_LAYOUT.needleCaseDeskY * s;
        const bowlX = ox + TOWER_SHOT_LAYOUT.bowlRimX * s;
        const bowlY = oy + TOWER_SHOT_LAYOUT.bowlRimY * s;

        if (paintedRoomOk) {
            if (route === "child") {
                // F03 仅保留清晰可读的纸条引文卡（1.65..4.15s）与末镜热碗升腾微汽，彻底避免与漫画原画粗陶碗重复叠画
                const noteReadA = smoothstep(1.65, 2.10, t) * (1 - smoothstep(3.65, 4.15, t));
                if (noteReadA > 0.02) {
                    const cardX = ncX + 52 * s;
                    const cardY = ncY + 72 * s;
                    uiInkDraw.drawRect(
                        Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s),
                        toColor(PALETTE.xuanPaper, Math.round(238 * noteReadA)),
                        1.0,
                        toColor(PALETTE.rouge, Math.round(110 * noteReadA)),
                    );
                    ctx.texts.put("xs", NEEDLE_NOTE_LINES[0], cardX, cardY + 10 * s, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 0.6, 0.94 * noteReadA, 0);
                    ctx.texts.put("xs", "—— " + NEEDLE_NOTE_LINES[1], cardX + 74 * s, cardY - 12 * s, toColor(PALETTE.xuanInkSub), 1, 0.5, TextAlign.Right, 0.8, 0.88 * noteReadA, 0);
                }
            }
            const steamStart = route === "child" ? 6.20 : 6.08;
            const steamOp = smoothstep(steamStart, steamStart + 0.45, t);
            if (steamOp > 0.02) {
                const steamCx = route === "child" ? (ox + 1110 * s) : (ox + 1050 * s);
                const steamCy = oy + 196 * s;
                let wi = 0;
                for (wi = 0; wi < 4; wi++) {
                    const cyc = (this.animTime * 0.34 + wi * 0.25) % 1;
                    const sx = steamCx + (wi - 1.5) * 16 * s + Math.sin(this.animTime * 1.4 + wi * 2.1) * (6 + cyc * 8) * s;
                    const sy = steamCy + (18 + cyc * 54) * s;
                    const sr = (15 + cyc * 20) * s;
                    const wa = Math.round(Math.sin(cyc * Math.PI) * 28 * steamOp);
                    if (wa > 2) {
                        fillRadialGlow(uiGlow, sx, sy, sr, sr * 1.35, Color(246, 238, 224, wa), Color(246, 238, 224, 0), 12);
                    }
                }
            }
            return;
        }

        if (route === "child") {
            const propA = smoothstep(1.55, 2.05, t);
            if (propA > 0.02) {
                this.drawNeedleCaseOnDesk(uiDraw, uiInkDraw, uiArt, ncX + 42 * s, ncY - 22 * s, s, propA, true);
            }
            const noteReadA = smoothstep(1.65, 2.10, t) * (1 - smoothstep(3.65, 4.15, t));
            if (noteReadA > 0.02) {
                const cardX = ncX + 52 * s;
                const cardY = ncY + 72 * s;
                uiInkDraw.drawRect(
                    Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s),
                    toColor(PALETTE.xuanPaper, Math.round(238 * noteReadA)),
                    1.0,
                    toColor(PALETTE.rouge, Math.round(110 * noteReadA)),
                );
                ctx.texts.put("xs", NEEDLE_NOTE_LINES[0], cardX, cardY + 10 * s, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 0.6, 0.94 * noteReadA, 0);
                ctx.texts.put("xs", "—— " + NEEDLE_NOTE_LINES[1], cardX + 74 * s, cardY - 12 * s, toColor(PALETTE.xuanInkSub), 1, 0.5, TextAlign.Right, 0.8, 0.88 * noteReadA, 0);
            }
            const bowlK = smoothstep(4.35, 5.15, t);
            if (bowlK > 0.02) {
                const bx = lerp(bowlX + 135 * s, bowlX, bowlK);
                this.drawWarmPorcelainBowl(uiDraw, uiInkDraw, uiArt, uiGlow, bx, bowlY, s, bowlK, false, 0);
            }
        } else {
            const needleK = smoothstep(5.45, 6.15, t);
            if (needleK > 0.02) {
                const ny = lerp(ncY + 26 * s, ncY - 22 * s, needleK);
                this.drawNeedleCaseOnDesk(uiDraw, uiInkDraw, uiArt, ncX + 64 * s, ny, s, needleK, false);
            }
            const bowlK = smoothstep(5.80, 6.65, t);
            if (bowlK > 0.02) {
                const by = lerp(bowlY - 54 * s, bowlY, bowlK);
                const handsK = smoothstep(5.95, 6.75, t);
                this.drawWarmPorcelainBowl(uiDraw, uiInkDraw, uiArt, uiGlow, bowlX, by, s, bowlK, true, handsK);
            }
            // M03：画面左侧案沿保留周戍轻按桌边的手绘补线袖口（与 fe-01 同源，强化团圆实感）
            const cuffK = smoothstep(4.25, 4.85, t);
            if (cuffK > 0.02) {
                drawPatchedCuff(uiInkDraw, uiGlow, {
                    wristX: ox + 116 * s,
                    wristY: oy + 168 * s,
                    angleRad: 0.06,
                    scale: 0.74 * s,
                    pose: "open",
                    opacity: 0.94 * cuffK,
                    stitchHighlight: 0.34,
                    warmth: 0.72,
                    uiArt,
                    instanceKey: "fe05_m03_desk_cuff",
                    layer: 5,
                });
            }
        }
    }

    /** 绘制明初黄铜指南针布套（手绘 cutscene_cuff_rig.clip|needle_pouch_compass，阴影落在底画布不压画） */
    private drawNeedleCaseOnDesk(
        bgDraw: DrawNode.Type,
        inkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        cx: number,
        cy: number,
        s: number,
        alpha: number,
        withNote: boolean,
    ): void {
        const a = Math.round(255 * clamp01(alpha));
        bgDraw.drawEllipse(Vec2(cx + 4 * s, cy - 32 * s), 44 * s, 12 * s, Color(10, 10, 14, Math.round(130 * alpha)));
        if (!uiArt.tryPlacePath(
            "assets/art/cutscene_cuff_rig.clip|needle_pouch_compass",
            "fe05_desk_needle_pouch",
            cx,
            cy + 4 * s,
            100 * s,
            102 * s,
            {
                anchorX: 0.5,
                anchorY: 0.5,
                angle: -10,
                opacity: clamp01(alpha),
                smooth: true,
                layer: 5,
            },
        )) {
            inkDraw.drawPolygon([
                Vec2(cx - 32 * s, cy - 12 * s),
                Vec2(cx + 26 * s, cy - 15 * s),
                Vec2(cx + 30 * s, cy + 16 * s),
                Vec2(cx - 28 * s, cy + 18 * s),
            ], Color(148, 124, 92, a), 1.3, Color(88, 70, 50, a));
        }

        if (withNote) {
            inkDraw.drawPolygon([
                Vec2(cx + 42 * s, cy - 18 * s),
                Vec2(cx + 100 * s, cy - 12 * s),
                Vec2(cx + 94 * s, cy + 24 * s),
                Vec2(cx + 38 * s, cy + 18 * s),
            ], toColor(PALETTE.xuanPaper, a), 1.0, toColor(PALETTE.xuanInkSub, Math.round(160 * alpha)));
            inkDraw.drawSegment(Vec2(cx + 50 * s, cy + 8 * s), Vec2(cx + 84 * s, cy + 11 * s), 1.2 * s, toColor(PALETTE.xuanInk, Math.round(170 * alpha)));
            inkDraw.drawSegment(Vec2(cx + 50 * s, cy - 2 * s), Vec2(cx + 80 * s, cy + 1 * s), 1.2 * s, toColor(PALETTE.xuanInk, Math.round(160 * alpha)));
        }
    }

    /** 绘制案沿粗瓷热粥碗（手绘 porridge_bowl + 柔和蒸腾热气 + M03 小满双手对称稳捧 xiaoman_cup_hands） */
    private drawWarmPorcelainBowl(
        bgDraw: DrawNode.Type,
        inkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        glow: DrawNode.Type,
        cx: number,
        cy: number,
        s: number,
        alpha: number,
        heldByTwoHands: boolean,
        handsK: number,
    ): void {
        const op = clamp01(alpha);
        bgDraw.drawEllipse(Vec2(cx, cy - 46 * s), 64 * s, 14 * s, Color(8, 9, 14, Math.round(138 * op)));
        if (!uiArt.tryPlacePath(
            "assets/art/cutscene_story_parts.clip|porridge_bowl",
            "fe05_desk_porridge_bowl",
            cx,
            cy - 4 * s,
            162 * s,
            124 * s,
            {
                anchorX: 0.5,
                anchorY: 0.5,
                opacity: op,
                smooth: true,
                layer: 5,
            },
        )) {
            const a = Math.round(255 * op);
            inkDraw.drawEllipse(Vec2(cx, cy + 8 * s), 64 * s, 21 * s, Color(224, 218, 206, a));
        }

        // 缓慢升腾的柔和热气云团（多层柔晕替代生硬锯齿细线，随 animTime 漂浮，暂停冻结）
        let wi = 0;
        for (wi = 0; wi < 4; wi++) {
            const cyc = (this.animTime * 0.36 + wi * 0.25) % 1;
            const sx = cx + (wi - 1.5) * 20 * s + Math.sin(this.animTime * 1.4 + wi * 2.1) * (8 + cyc * 10) * s;
            const sy = cy + (24 + cyc * 58) * s;
            const sr = (18 + cyc * 24) * s;
            const wa = Math.round(Math.sin(cyc * Math.PI) * 34 * op);
            if (wa > 2) {
                fillRadialGlow(glow, sx, sy, sr, sr * 1.35, Color(246, 238, 224, wa), Color(246, 238, 224, 0), 12);
            }
        }

        // M03：小满两只手对称稳捧热碗（手绘 xiaoman_cup_hands，已解去红绳！）
        if (heldByTwoHands && handsK > 0.02) {
            const liftY = (1 - handsK) * 36 * s;
            const handOp = clamp01(handsK * op);
            uiArt.tryPlacePath(
                "assets/art/cutscene_story_parts.clip|xiaoman_cup_hands",
                "fe05_m03_xiaoman_cup_hands",
                cx,
                cy - 34 * s - liftY,
                258 * s,
                186 * s,
                {
                    anchorX: 0.5,
                    anchorY: 0.5,
                    opacity: handOp,
                    smooth: true,
                    layer: 6,
                },
            );
        }
    }

    /** 明初素色木骨纱罩油灯（绝非现代电灯/探照灯） */
    private drawMingLantern(
        draw: DrawNode.Type,
        glow: DrawNode.Type,
        cx: number,
        cy: number,
        scale: number,
        alpha: number,
        warmth: number,
    ): void {
        const a = Math.round(255 * clamp01(alpha));
        const flicker = 0.92 + 0.08 * Math.sin(this.animTime * 7.2);
        // 铁提梁
        draw.drawSegment(Vec2(cx - 10 * scale, cy + 28 * scale), Vec2(cx, cy + 40 * scale), 1.8 * scale, Color(88, 86, 82, a));
        draw.drawSegment(Vec2(cx + 10 * scale, cy + 28 * scale), Vec2(cx, cy + 40 * scale), 1.8 * scale, Color(88, 86, 82, a));
        // 木灯顶与木底座
        draw.drawRect(Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), Color(62, 46, 34, a), 1.0, Color(118, 92, 66, a));
        draw.drawRect(Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), Color(62, 46, 34, a), 1.0, Color(118, 92, 66, a));
        // 素纸灯罩与摇曳油灯焰
        draw.drawRect(
            Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale),
            Color(238, 198, 132, Math.round(230 * alpha * (0.75 + 0.25 * warmth))),
            1.4 * scale,
            Color(94, 70, 48, a),
        );
        draw.drawSegment(Vec2(cx, cy - 18 * scale), Vec2(cx, cy + 22 * scale), 1.1 * scale, Color(94, 70, 48, Math.round(150 * alpha)));
        draw.drawEllipse(Vec2(cx, cy + 2 * scale), 4.6 * scale * flicker, 8.5 * scale * flicker, Color(255, 244, 212, a));

        fillRadialGlow(
            glow, cx, cy + 2 * scale,
            94 * scale * flicker * (0.75 + 0.35 * warmth),
            94 * scale * flicker * (0.75 + 0.35 * warmth),
            Color(250, 208, 132, Math.round(128 * alpha * warmth)),
            Color(228, 162, 74, 0),
            16,
        );
    }

    private drawDialogueSubtitle(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        ctx: FePluginContext,
        route: TowerEndingRoute,
        s: number,
        barH: number,
    ): void {
        const line = this.lastSubtitle;
        if (line !== "") {
            const cy = barH + 34 * s;
            const stripW = Math.min(ctx.uiW - 120 * s, 720 * s);
            drawSilkVeil(uiDraw, uiArt, "fe05_sub_veil", ctx.uiW * 0.5, cy, stripW, 48 * s, PALETTE.inkWash, 0.82, 3);
            drawHairline(uiInkDraw, uiArt, "fe05_sub_hair", ctx.uiW * 0.5, cy + 21 * s, stripW * 0.68, PALETTE.silkDim, 0.54, true, 4);
            const isSpoken = line === F03_DIALOGUE || line === M03_DIALOGUE;
            ctx.texts.put(
                isSpoken ? "md" : "sm",
                line,
                ctx.uiW * 0.5,
                cy - 1 * s,
                toColor(isSpoken ? PALETTE.amberCore : PALETTE.textBright),
                0.5,
                0.5,
                TextAlign.Center,
                isSpoken ? 1.8 : 1.0,
                0.98,
                0.08,
            );
        }

        // 低引导规范：仅当玩家在暂停菜单主动打开「按键辅助」且定格读完解锁后，才在底遮幅极淡提示重开
        if (ctx.view.assistHintsEnabled && this.confirmReady) {
            const rawHint = route === "child"
                ? "按 E 收页 · 尾声与史话   ·   Esc 暂歇"
                : "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇";
            const hint = getActiveTarget().adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout);
            ctx.texts.put("xs", hint, ctx.uiW * 0.5, barH * 0.5, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.4, 0.88, 0.08);
        }
    }
}

export function createTowerEndingsPlugin(): TowerEndingsPlugin {
    return new TowerEndingsPlugin();
}

/** 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖） */
export function attachTowerEndingsPlugin(fe: WatchFrontend): TowerEndingsPlugin {
    const plugin = new TowerEndingsPlugin();
    fe.registerPlugin(plugin);
    return plugin;
}
