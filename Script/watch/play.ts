/**
 * 玩法层：一段能走、能跳、能蹲、能打，并能进入护送试炼与正式剧情。
 *
 * 世界坐标：x 左右，y 为离地高度，depth 为地面前后位置；角色位置是脚底中心。
 * 绘制坐标：Dora DrawNode 局部坐标，左下原点、y 向上；Rect(x, y, w, h) 以 (x, y)
 * 为左下角向右上扩展。相机把世界线性映射到这块画布上，zoom 固定。
 *
 * 每帧顺序按程序实现稿：输入 → 位移与碰撞 → 机关/命中/交互事件 → 提交快照 → 表现。
 * 本层只管前四步，表现由 draw() 一次画出。
 */

import { Rect } from "Dora";
import {
    BreakSpec, CartSpec, DepthRange, ESCORT_VARIANTS, InteractSpec, PickupSpec, RoomSpec, ScavSpec, SolidSpec,
    withOrigin, CHECKPOINT_ROOM, OUTSIDE_ROOM,
} from "Script/watch/rooms";
import {
    ALL_TALENTS, ArchiveState, CheckpointSnap, createRun, createStoryTalents, draftTalentOffers,
    Inventory, mmss, pickEscortVariant, RunState, StoryRoute, Talent, talentNames,
} from "Script/watch/run";
import { Input } from "Script/watch/input";
import { STEP } from "Script/watch/clock";
import { CALM_REACH, Escort, FEAR_MAX, safeAnchorX } from "Script/watch/escort";
import { ACTOR_DEPTH_HALF, DEPTH_Y_SCALE, INTERACT_DEPTH_REACH, inReachDepth, overlapsDepth } from "Script/watch/depth";
import {
    RELOAD_ANSWER_PER_WORLD, RELOAD_ANSWER_TICKS, RELOAD_START, RELOAD_TARGET, ReloadEffect,
    reloadAdjacent, reloadEffectName, reloadEffectOf, reloadPathValid,
} from "Script/watch/reload";
import {
    ARTIFACT_WEAPON_ID, CRAFT_RECIPES, RecipeSpec, findRecipe, missingMaterials, payMaterials, weaponEffectOf, weaponNameOf,
} from "Script/watch/craft";
import { SessionSave } from "Script/watch/save";

/** 60 拍 = 1 秒；固定步长见 clock.ts。 */
export { STEP };
export const GRAVITY = 1000;
export const GATE_COUNT_END = 1440;
/** 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。 */
export const GATE_HAND_TICKS = 36;
/** 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。 */
export const GATE_ROUTE_PERCENT = 80;
export const TOWER_CONFIRM_TICKS = 480;
const TOWER_REGISTER_TICKS = 180;
/** 值夜室桌前长按 E 的生效拍数（0.6 秒，与城门牵手同节奏）。 */
const TOWER_HANDOVER_TICKS = 36;
/** 跨过门槛的段内 x（门廊 400–490、值夜室 490–700）。 */
const TOWER_THRESHOLD_X = 500;

// —— 共同序章：P01 叫醒 → P02 墙影 → 限时逃柜 → 入柜 → P03 递针套 ——
/** P01 黑场听父亲唤「小满」到睁眼落稳：4 秒 = 240 拍。 */
export const PROLOGUE_WAKE_TICKS = 240;
/** P02 门槛内墙上人影与瓷碗滚到脚边：2 秒 = 120 拍。 */
export const PROLOGUE_SHADOW_TICKS = 120;
/** 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。 */
export const PROLOGUE_ESCAPE_TICKS = 450;
/** 入柜后红晕收尽、柜外脚步渐远：0.85 秒 = 51 拍。 */
export const PROLOGUE_HIDE_TICKS = 51;
/** 序章 P03 柜边递针套特写时长：3.0 秒 = 180 拍（对齐分镜稿与 D01 对白节拍）。 */
export const PROLOGUE_GIVE_TICKS = 180;
/** 城门 P05 送别嘱咐独立演出时长：约 3.67 秒 = 220 拍（演完再切入 24 秒数到二十，零叠字叠音）。 */
export const GATE_FAREWELL_TICKS = 220;
/** 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。 */
export const PROLOGUE_CABINET_X = 132;

export function gateCountAtTick(tick: number): number {
    if (tick >= GATE_COUNT_END) return 20;
    if (tick >= 1260) return 19;
    if (tick >= 1080) return 18;
    if (tick >= 480) return 11 + Math.floor((tick - 480) * 7 / 600);
    return 1 + Math.floor(Math.max(0, tick) / 48);
}
/** 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。 */
const BOTTLE_FLY_TIME = 0.62;

/**
 * 前端可消费的一次性事件。
 * 事件只在模拟步里产生，每个事件带唯一递增 seq 与所在拍 tick；
 * 一次渲染帧补跑多步时，前端按 seq 顺序消费整段，不要按帧去重。
 */
export type PlayEventName =
    | "shotResolved"
    | "coverBlocked"
    | "actorHit"
    | "bottleThrown"
    | "bottleLanded"
    | "knock"
    | "gateFailed"
    | "gateRestart"
    | "cartDocked"
    | "fearChanged"
    | "pickupRejected"
    | "craftStart"
    | "craftDone"
    | "roomChange"
    | "pickup"
    | "propBroken"
    | "interactUsed"
    | "campaignFailed"
    | "objectiveDone"
    | "storyRouteLocked"
    | "gateCountDone"
    | "handHeld"
    | "handRelease"
    | "storyLine"
    | "storyExit"
    | "gatePathEnd"
    | "carryStart"
    | "reloadOpen"
    | "reloadNode"
    | "reloadInvalid"
    | "reloadSolved"
    | "reloadTimeout"
    | "reloadApplied"
    | "segmentDone"
    | "benchOpen"
    | "benchCraft"
    | "benchEquip"
    | "benchClose"
    | "benchRejected"
    | "trialShot"
    | "endingReached"
    | "artifactFound"
    | "prologueBeat"
    | "storyBeat"
    | "museumStep"
    | "museumDone";

/** 工台视图：字段名与 fe/contract.ts 的 CraftBenchSnapshot 对齐。 */
export interface CraftBenchView {
    active: boolean;
    firstCraftDone: boolean;
    justCraftedTimer: number;
    inventory: Record<string, number>;
    recipes: { id: string; name: string; desc: string; enhancedEffect: string; cost: Record<string, number>; crafted: boolean }[];
    equippedWeapon: string;
}

export interface PlayEvent {
    /** 本局内递增；换房、R 重试、再玩都会新建 Play，序号从头开始。 */
    seq: number;
    /** 产生事件的模拟拍（Play.ticks）。 */
    tick: number;
    name: PlayEventName;
    data: Record<string, unknown>;
}

/** 小满：高 56、蹲 34、走 160、慢走 80、跳初速 320（顶点 51）。 */
const CHILD_W = 28;
const CHILD_H = 56;
const CHILD_CROUCH_H = 34;
const CHILD_SPEED = 160;
const CHILD_SLOW = 80;
const CHILD_JUMP = 320;

/** 周戍：高 88、速度 264、翻滚 0.35 秒约 97 单位。 */
const SOLDIER_W = 30;
const SOLDIER_H = 88;
const SOLDIER_SPEED = 264;
const ROLL_TIME = 0.35;
const ROLL_SPEED = 280;
/** 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。 */
const SOLDIER_JUMP = 340;
const LEDGE_RISE = 60;

/** 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。 */
export const LOGIC_W = 320;
export const LOGIC_H = 180;
export const UNITS_PER_PX = 2;
/** 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。 */
const GROUND_PX = 40;
const CAM_FOLLOW = 9;
const CAM_LOOK_UP = 46;

/** 拉车速度：规划初值 64 单位/秒。 */
const CART_SPEED = 64;
/** 握把触发半径。 */
export const CART_REACH = 70;
/** 车身半宽与下缘净高（城外下层阻挡）。 */
/** 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。 */
const WARN_TICKS = 36;
/** 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。 */
const TOOL_CAP = 1;
const CONSUMABLE_CAP = 1;
/** 废木料制木楔要按住 E 的有效拍数。 */
const CRAFT_TICKS = 45;
/** 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。 */
const INVULN_HIT_TICKS = 42;
/** 被击倒复活后的保护拍数（1.2 秒）。 */
const INVULN_RESPAWN_TICKS = 72;
const FIRE_COOLDOWN = 150;
/** 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。 */
const CAMPAIGN_FIRE_COOLDOWN = 240;
const ENEMY_RANGE = 760;
/** 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。 */
const WALL_ROAD_END = 1150;
/** 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。 */
const STEP_UP = 24;
const DEPTH_SPEED_RATIO = 0.55;
const DIAGONAL_SCALE = 1 / Math.sqrt(2);

/** 轴对齐盒（世界单位）。 */
export interface Box {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    depth?: DepthRange;
    /** 单向平台：只做落脚面，水平不挡人，从下方也不撞头。 */
    passable?: boolean;
    /** 房间数据里的名字；前端用它说明「贴的是街垒还是绞盘」。 */
    label?: string;
    /** 新版关卡：机关 id，跨房恢复用。 */
    id?: string;
    /** 布帘 / 窗纸：挡视线与子弹，不挡人和车。 */
    soft?: boolean;
    /** 机关未打开前隐藏，不参与碰撞、射击与绘制。 */
    hidden?: boolean;
    /** 已经碎了：同拍撤掉碰撞、遮挡与挡弹。 */
    broken?: boolean;
    breakable?: BreakSpec;
    interact?: InteractSpec;
    /** 帘 / 板放下后的绘制状态。 */
    revealed?: boolean;
}

export interface Actor {
    x: number;
    y: number;
    /** 地面的前后坐标。正值朝远景，与跳跃高度分开。 */
    depth: number;
    depthSpeed: number;
    vx: number;
    vy: number;
    w: number;
    h: number;
    onGround: boolean;
    facing: number;
    crouch: boolean;
    rollT: number;
    covered: boolean;
    alive: boolean;
}

export interface Enemy {
    x: number;
    y: number;
    depth?: number;
    w: number;
    h: number;
    alive: boolean;
    hitT: number;
    /** 举枪预警剩余拍数；>0 时画红色准线，归零即开火。 */
    warnT: number;
    /** 距下一次举枪的拍数。 */
    fireCd: number;
    /** 新版关卡：火器手 / 持盾手 / 破障手 / 侧线带队者。 */
    kind?: "gunner" | "shield" | "breaker" | "leader" | "target";
    /** 盾耐久；正面挡弹，碎盾后不掉残盾。 */
    shieldHp?: number;
    shieldHpMax?: number;
    /** 击倒掉落。 */
    drop?: "shield" | "wedge" | "ammo" | "pass" | "quickbelt" | "none";
    /** 出生点，破障手用它在触发前站桩。 */
    homeX?: number;
    /** 近战/破障的节拍。 */
    swingT?: number;
    /** 警戒是否已触发。 */
    awake?: boolean;
    /** 小队编号，留给侧线带队者。 */
    squad?: number;
}

export interface Camera {
    x: number;
    y: number;
}

/** 当前窗口下的像素视口：整数倍放大 + 居中（黑边留在两侧）。 */
export interface Viewport {
    zoom: number;
    ox: number;
    oy: number;
}

/** 取能容纳 320×180 画布的最大整数倍，并把画布居中。 */
export function computeViewport(w: number, h: number): Viewport {
    let zoom = Math.floor(Math.min(w / LOGIC_W, h / LOGIC_H));
    if (zoom < 1) {
        zoom = 1;
    }
    return {
        zoom: zoom,
        ox: Math.floor((w - LOGIC_W * zoom) / 2),
        oy: Math.floor((h - LOGIC_H * zoom) / 2),
    };
}

/** 一次命中判定的结果。y0 / y1 是包含纵深偏移的投影高度。 */
export interface Trace {
    x0: number;
    y0: number;
    x1: number;
    y1: number;
    hit: boolean;
}

interface Ray {
    x: number;
    y: number;
    dx: number;
    dy: number;
    depth?: number;
    dDepth?: number;
}

/** 每个房间进入时的剧情初态。 */
function phaseOf(key: string): string {
    if (key === "prologue") {
        // 默认仍是可玩的等待段；标题「开始游戏」由 app 把首帧切到 prologue-wake，
        // 让正式入口从 P01「叫醒」起播，而章节直达/调试/验收夹具保持旧行为。
        return "prologue-wait";
    }
    if (key === "street") {
        return "street-run";
    }
    if (key === "gate") {
        return "gate-idle";
    }
    if (key === "gatepath") {
        return "gatepath-start";
    }
    if (key === "forest") {
        return "forest-run";
    }
    if (key === "tower") {
        return "tower-wait";
    }
    if (key === "museum") {
        return "museum-cabinet";
    }
    return "run";
}

export class Play {
    room: RoomSpec;
    player: Actor;
    partner: Actor;
    cam: Camera;
    enemies: Enemy[] = [];
    boxes: Box[] = [];
    floors: Box[] = [];
    /** 已提交的检查点世界 x；-1 表示还没提交。 */
    checkpoint = -1;
    /** 帧内反馈，给 HUD 用。 */
    flash = "";
    flashT = 0;
    /** 最近一次弹道，画 0.12 秒。 */
    trace: Trace | undefined;
    traceT = 0;
    /** 城外拉车焦点是否亮起。 */
    focusCart = false;
    /** E 按下的次数与最近一次的时间，用来做「敲两下」。 */
    knocks = 0;
    knockT = 0;
    /** 护送状态、恐惧格与安抚进度。 */
    escort: Escort;
    /** 车轴当前世界 x：检查站 640→768，城外 304→432。 */
    cartAxle = 0;
    /** 车已推进到底（车轮落窝）。 */
    cartDocked = false;
    /** 周戍是否正握着车把。 */
    gripping = false;
    /** 双人出口是否同时满足「车到位 + 两人都进区」。 */
    gateOpen = false;
    /** 本步 E 是否已经给安抚用掉，避免同一步又敲木板。 */
    calmConsumed = false;
    /** 正在制作的已按拍数；0 表示没在制作。 */
    craftT = 0;
    /** 危险事件的递增 id，同一 id 只结算一次。 */
    nextDangerId = 1;
    /** 要切到哪个房间；app 读走后置空。 */
    wantRoom = "";
    /** 切场要带过去的车位。 */
    carryCartAxle = -1;
    carryCartDocked = false;
    /** 提交检查点时的车位，供复演记录。 */
    checkpointCartAxle = -1;

    // —— 村口 ——
    /** 手上是否有瓶。 */
    hasBottle = false;
    /** 投出的瓶子（飞行中）：解析轨迹，t 到 BOTTLE_FLY_TIME 才算触地。 */
    bottleFly: { x: number; y: number; x0: number; y0: number; vx: number; vy: number; t: number } | undefined;
    /** 最近一次落点与余音计时。 */
    bottleLandX = -1;
    bottleTargetX = -1;
    bottleTargetY = 0;
    bottleLandT = 0;
    /** 按住 F 的时长（只用于提示与动作反馈，不改变投掷参数）。 */
    aimHold = 0;
    /** 城外补丁红布车是否已拉开（石阶口露出）。 */
    private redCartPulled = false;
    /** F01 补丁红布车半秒家庭回忆计时（拍）。 */
    redCartMemoryT = 0;
    /** 桌下脚步提示的节流拍数。 */
    private footHintT = 0;
    /** 是否已提示过暗渠口。 */
    private ditchHinted = false;
    /** 入林先走了哪条路：树根窄洞 / 旧渠 / 还没选。 */
    private forestPath: "burrow" | "ditch" | "" = "";
    /** 溪湾水里灯是否已看见。 */
    private waterSeen = false;
    /** 铁盆命中给拾荒者叠加的额外驻留拍数（砖地=0，铁盆=90）。 */
    private scavStallBonus = 0;
    /** 前端结构化意图：风台长按牵手（兼容触屏/手柄与 contract.submitIntent）。 */
    private intentGateReunionHold = false;
    /** 前端结构化意图：博物馆一步交互请求。 */
    private pendingMuseumIntentTarget = "";
    /** 拾荒者位置与状态机。 */
    scavX = 0;
    scavDir = 1;
    scavState: "patrol" | "turn" | "walk" | "stall" | "back" | "chase" = "patrol";
    scavT = 0;
    scavTargetX = 0;
    /** 是否已过第一院通行线。 */
    passed = false;

    // —— 剧情段（D5）——
    /** 这一局控制谁：false 周戍，true 小满。城门送别后换人。 */
    childMode = false;
    /** 当前剧情阶段名，按房间前缀区分。 */
    phase = "";
    /** 剧情阶段计时（拍）。 */
    phaseTick = 0;
    /** 城门守点累计的可操作拍数；暂停不增。 */
    gateTick = 0;
    /** 数到二十的拍数（24 秒 = 1440）。 */
    countTick = 0;
    /** 数数阶段必须先松开方向键，新按才算迈步。 */
    countArmed = false;
    /** 上一拍的水平方向；用来认「新按下」而不是「一直按着」。 */
    countPrevMove = 0;
    /** 被抓后的复位余韵，>0 时锁输入。 */
    caughtT = 0;
    /** 城门守点里周戍的血量；打空就回绞盘重来。 */
    hp = 3;
    maxHp = 3;
    /**
     * 受击硬直保护：单位是「模拟拍」，不是秒。42 拍 = 0.7 秒。
     * 这里必须用整数拍减法：用浮点秒减 dt 会在 t+42 处留下 ±1e-16 的残差，
     * 同一发攻击在 t+41 / t+42 的判定就会随浮点符号漂移，回放不可复现。
     */
    invulnT = 0;
    /** 小满撞墙后累计的时间：超过 0.3 秒就换一档绕行，别在柱前原地跳。 */
    partnerStuck = 0;
    /** 小满当前尝试的绕行档位与保持时间。 */
    partnerLaneIdx = 0;
    partnerLaneHold = 0;
    /** 本拍被掩体或蹲伏挡下的提示，给 HUD 用。 */
    coveredFlash = 0;
    /** 本步是否「贴住掩体且按着 Shift」；HUD 与姿态都读它，别处不要再各算一遍。 */
    coverHug = false;
    /** 本步是否贴得住掩体（还没按 Shift 也算），用来提示「按住 Shift」。 */
    coverNear = false;
    /** 贴住的那件实体名字：街垒、绞盘、柜台……没有就空串。 */
    coverEntity = "";
    /** 贴住的实体是否正挡在最近敌兵的来向上；贴住但背向火力时为 false。 */
    coverBlocking = false;
    /** 倒地回绞盘后要玩家按 E 确认重新就位，避免「静默重开」把玩家又打一遍。 */
    gateNeedConfirm = false;
    /** 倒地当拍烧掉了 E：必须先看到松开，下一次按下才算「新按」。 */
    gateRestartArmed = true;
    /** 按住 F 期间每拍缓存的落点；预览与投掷共用它，避免松手那拍镜头移动造成偏差。 */
    bottleAimX = -1;
    bottleAimY = 0;
    /** 上一次投掷的落点表面高度；飞行只在这个高度上触地。 */
    bottleSurfaceY = -1;
    /** 最近一次落地的世界坐标，给前端画砸地扬尘。 */
    bottleLandY = 0;
    /** 一次性事件队列；前端每渲染帧 drainEvents() 一次。 */
    events: PlayEvent[] = [];
    /** 本局事件序号；换房/重试/再玩都是新实例，序号从 0 起。 */
    private eventSeq = 0;
    /** 森林里的狗。 */
    dogX = 0;
    dogDir = 1;
    dogState: "patrol" | "ear" | "chase" | "sniff" | "back" = "patrol";
    dogT = 0;
    dogTargetX = 0;
    /** 拾荒者的发现计数与追逐标志。 */
    scavSee = 0;
    scavChase = false;
    /** 城门守点已登场的敌兵批数。 */
    gateSpawned = 0;
    /** 守点被打倒的次数，给 HUD 与回放读。 */
    gateFailCount = 0;

    // —— 新版关卡 S1–C2 ——
    /** 本段走新版关卡数据。 */
    isCampaign = false;
    /** 跨房运行态；单房回放时自动建一份。 */
    run: RunState;
    /** 背包引用：前端契约可读 p.inventory，实际状态在 run.inventory。 */
    readonly inventory: Inventory;
    /** 双通关档案引用：C 单读取的结局结果。 */
    readonly archive: ArchiveState;
    /** 档案有变化、等 app 落盘；Play 本身不碰文件。 */
    archiveDirty = false;
    /** 局中进度有变化、等 app 写局中存档；只对正式剧情生效。 */
    sessionDirty = false;
    /** 片尾按 E 回序章：app 收到后新建局内状态，但共享同一份档案。 */
    restartStory = false;
    /** 序章旧井：双通关且尚未取到穿梭器时开放。 */
    wellOpen = false;
    /** 旧井的段内 x；前端按真实可见性画井光与声源。 */
    readonly wellX = 430;
    /** 本局已从井里取到穿梭器。 */
    wellTaken = false;
    /** 从博物馆回柜边：下一次序章刷新把人放回井沿，不跳过寻柜。 */
    museumReturn = false;
    /** 北塔登记簿两行：第一行一律小满，第二行团圆线周戍、单人线留白。 */
    endingLines: string[] = ["", ""];
    /** 北塔门廊：守卒回叩后门板让开；跨门槛 → 值夜室桌前长按 E 交物。 */
    towerDoorOpen = false;
    towerHanded = false;
    deskHold = 0;
    /** 片尾 8 秒定格前若持续按着交互/重开键，须先松开再新按。 */
    private towerEndMustRelease = false;

    /** 片尾登记簿是否已定格满 8 秒且允许新按确认收页。 */
    towerEndReady(): boolean {
        const waitTicks = Math.max(0, TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS);
        return this.room.key === "tower"
            && this.phase === "tower-end"
            && this.phaseTick >= waitTicks
            && !this.towerEndMustRelease;
    }

    // —— 第三段工台与武器 ——
    /** 已装备的武器 id；标准铳之外由工台改制。 */
    equippedWeapon = "standard_gun";
    /** 工台视图：前端契约读这个对象，字段名与 fe/contract 对齐。 */
    readonly craftBench: CraftBenchView = {
        active: false,
        firstCraftDone: false,
        justCraftedTimer: 0,
        inventory: {},
        recipes: [],
        equippedWeapon: "standard_gun",
    };
    /** 工台制作的请求幂等表：同一 requestId 只结算一次。 */
    private handledCraftRequests: Record<string, boolean> = {};
    /** 工台前按 E 的触发半径。 */
    readonly benchReach = 48;
    /** 检查点快照：制前 / 制后各自恢复库存、装备与背负。 */
    private checkpointSnap: CheckpointSnap | undefined;
    /** 本段地上的掉落物（房间自带 + 敌人掉落）。 */
    pickups: Readonly<PickupSpec>[] = [];
    /** 装填剩余拍；>0 时不能开火。 */
    reloadT = 0;
    /** 架在暴露轨段的残盾。 */
    bracedShield: { x: number; y: number; w: number; h: number; hp: number } | undefined;
    /** 本段目标已达成，等两人到出口。 */
    objectiveDone = false;
    /** 最近一次交互提示。 */
    hint = "";
    /** 进入本段的累计拍，HUD 用来算本段用时。 */
    roomStartTick = 0;
    /** 推车时的暴露伤害节拍。 */
    cartHitT = 0;
    cartExposed = false;

    // —— 正式剧情：跨房血量、过门锁线与风台演出 ——
    /** 已锁定的结局路线："child" / "soldier" / 空串=还没锁线。前端直接读。 */
    storyRoute: StoryRoute = "";
    /** 小满已安全过门、血量已锁存。锁线后重试与续读都不重算。 */
    storySettled = false;
    /** 殿后最后一拍伤害结算后的血量锁存；-1=未锁。 */
    hpAtGate = -1;
    maxHpAtGate = -1;
    /** 牵手长按已积累的有效拍；提前松手清零。 */
    handTicks = 0;
    /** 牵手需要的有效拍（只读，前端可用来画进度）。 */
    readonly handNeedTicks = GATE_HAND_TICKS;
    /** 数完那一刻已经按着 E 的不算「重新按住」，必须先松开。 */
    handArmed = false;
    /** 牵手已完成；台词只触发一次。 */
    handDone = false;
    lineSaid = false;
    /** 牵手演出完成，同行段全程牵手。 */
    tied = false;
    /** 同行段已走到高石阶前（下一段入口）。 */
    pathDone = false;
    /** 男主线：小满已背在背上。背负只有一套移动与受击碰撞，小满只更新背侧位置。 */
    carryOn = false;
    /** 第一段护送房已走到安全出口，交给下一段。 */
    escortDone = false;

    // —— 共同序章：P01/P02 与限时逃柜 ——
    /** 逃柜限时（秒）；前端按它算红晕与心跳。 */
    readonly escapeDuration = PROLOGUE_ESCAPE_TICKS / 60;
    /** 逃柜剩余时间（秒）；前端直接读，每拍由后端递减。 */
    escapeRemaining = 0;
    /** 逃柜失败次数；只影响演出重来，不写档案。 */
    escapeRetryCount = 0;
    /** 序章演出自己的拍计数器（wake/shadow/hide 各段）。 */
    introTick = 0;

    // —— 慢时连线换弹 ——
    /** 3×3 线盘开着：世界降到 1/4 速，只有每 4 个作答拍推进 1 个世界拍。 */
    reloadOpen = false;
    /** 已用掉的作答拍；240 拍 = 60 世界拍 = 4 秒。 */
    reloadAnswerTicks = 0;
    /** 盘开着期间实际推进的世界拍，给前端画外圈。 */
    reloadWorldTicks = 0;
    /** 当前路径（节点 id）；起点固定 0，画到 8 结算。 */
    reloadPath: number[] = [RELOAD_START];
    /** 已画好的枪机效果；下一次有效开火消费一次，之后回到普通。 */
    reloadPendingEffect: ReloadEffect = "";
    /** 这一房开盘次数，回放用来确认「重画不重新计时」。 */
    reloadTryCount = 0;

    // —— 男主线肉鸽折笺选卡与折戟小结（前端挂载时开启轻暂停，独立无头回放保持非阻塞） ——
    talentModalActive = false;
    useEscortDeathSummary = false;
    escortFailed = false;
    escortFailedTicks = 0;
    escortSummary: {
        roomKey: string;
        attempt: number;
        seed: number;
        equippedWeapon: string;
        segmentsCleared: number;
        ranks: Record<Talent, number>;
    } | undefined = undefined;
    private fieldWedgeSeq = 0;

    paused = false;
    /** 累计模拟步，用来做与帧率无关的计时。 */
    ticks = 0;
    /** 当前窗口的像素视口，绘制前算一次。 */
    view: Viewport = { zoom: 1, ox: 0, oy: 0 };
    /** 本段在世界地图里的偏移；room 数据还是段内坐标时用它换算。 */
    ox = 0;
    /** 准星在画布上的位置（局部、左下原点），由 app 每帧写入。 */
    aimX = 0;
    aimY = 0;
    /** 最近一次绘制的画布尺寸，供屏幕↔世界换算。 */
    viewW = 0;
    viewH = 0;
    /** 可选的高清前端屏幕→世界反算钩子；未挂接时回退到 320×180 像素画布反算，不破坏既有验收脚本。 */
    worldMapper: ((sx: number, sy: number) => { x: number; y: number }) | undefined;

    constructor(room: RoomSpec, resume?: { checkpoint: number }, run?: RunState) {
        // 段内坐标 → 世界坐标。房间数据里的锚点保持不变，Play 内部一律读世界坐标。
        this.ox = room.originX;
        this.room = withOrigin(room);
        const wr = this.room;
        this.run = run ?? createRun();
        this.inventory = this.run.inventory;
        this.archive = this.run.archive;
        const story = this.run.story;
        const savedEq = story.equippedWeapon;
        if (savedEq === ARTIFACT_WEAPON_ID && this.archive.artifactOwned) {
            this.equippedWeapon = ARTIFACT_WEAPON_ID;
        } else if (savedEq === "standard_gun" || (savedEq !== "" && savedEq === story.craftedWeapon)) {
            this.equippedWeapon = savedEq;
        } else {
            this.equippedWeapon = story.craftedWeapon === "" ? "standard_gun" : story.craftedWeapon;
        }
        this.isCampaign = wr.campaign !== undefined;
        this.cam = { x: (wr.minX + wr.maxX) / 2, y: wr.height / 2 };
        this.buildWorld();
        // 周戍段（序章/街道/检查站/城门）操控周戍；其余路段操控小满。
        // 男主线背着妹妹进城外时仍控周戍：出入口同一间房，操控权按已锁路线分。
        const lockedRoute = this.run.story === undefined ? "" : this.run.story.route;
        // 男主线背着妹妹进城外与北塔时仍控周戍；北塔团圆线小满作为 partner 站立身侧。
        const soldierRoom = (wr.key === "outside" || wr.key === "tower") && lockedRoute === "soldier";
        this.childMode = !soldierRoom
            && (wr.key === "outside" || wr.key === "village" || wr.key === "forest" || wr.key === "tower");
        const soloRoom = wr.key === "museum";
        const playerIdx = wr.key === "checkpoint" ? 1 : 0;
        const partnerIdx = soloRoom ? -1 : (wr.key === "checkpoint" ? 0 : (this.childMode ? -1 : 1));
        this.player = makeActor(wr, playerIdx);
        this.partner = makeActor(wr, partnerIdx);
        this.phase = phaseOf(wr.key);
        if (soloRoom) {
            // 馆内进度随档案走：退出应用后从同一步续读。
            const mp = this.archive.museumPhase;
            this.phase = mp === "hall_walk" ? "museum-hall"
                : mp === "lamp_turn" ? "museum-lamp"
                    : mp === "return_cabinet" ? "museum-return"
                        : mp === "done" ? "museum-done" : "museum-cabinet";
        }
        if (wr.story !== undefined) {
            this.dogX = wr.story.dog === undefined ? 0 : wr.story.dog.x0;
        }
        this.cam.x = this.player.x;
        this.cam.y = this.player.y + CAM_LOOK_UP;
        this.cartAxle = wr.cart.startX;
        this.escort = new Escort(safeAnchorX(wr.marks));
        this.scavX = wr.scavenger !== undefined ? wr.scavenger.x0 : 0;
        if (this.isCampaign) {
            this.setupCampaign();
        } else {
            this.buildEnemies();
        }
        // 重试/复演：洞后检查点已提交则车已在 432 落窝，小满回到洞后。
        if (resume !== undefined && resume.checkpoint > 0) {
            this.checkpoint = resume.checkpoint;
            if (this.room.key === "outside" && resume.checkpoint >= 380) {
                this.cartAxle = this.room.cart.endX;
                this.cartDocked = true;
                // 恢复到下层洞后安全点：脚踩地面 y=0、站 380（还没到 388 的切线）。
                // 车轴同步到 432，松键空转也不会自己进村，得自己走过 388。
                this.player.x = this.ox + 380;
                this.player.y = 0;
                this.player.vy = 0;
                this.player.onGround = true;
                this.cam.x = this.player.x;
                this.cam.y = this.player.y + CAM_LOOK_UP;
            }
        }
        this.restoreStory();
    }

    /**
     * 从跨房快照恢复正式剧情的血量、路线与演出阶段。
     *
     * 新房一律不得满血重算：run.story 里带着周戍的 hp/maxHp。
     * 门房若已锁线，则按快照回到数数 / 等牵手 / 已牵手的对应拍，
     * 让 R 重试与菜单续读都不必重打 45 秒守点。
     */
    // ==================== 第三段工台与武器 ====================

    /** 配方视图：后端是配方的唯一状态，前端只读这份派生视图。 */
    private recipeViews(): CraftBenchView["recipes"] {
        const out: CraftBenchView["recipes"] = [];
        let i = 0;
        for (i = 0; i < CRAFT_RECIPES.length; i++) {
            const r: RecipeSpec = CRAFT_RECIPES[i];
            const cost: Record<string, number> = {};
            if (r.cost.wood !== undefined) {
                cost["wood"] = r.cost.wood;
            }
            if (r.cost.bell !== undefined) {
                cost["bell"] = r.cost.bell;
            }
            out.push({
                id: r.id,
                name: r.name,
                desc: r.desc,
                enhancedEffect: r.enhancedEffect,
                cost: cost,
                crafted: this.run.story.craftedWeapon === r.id,
            });
        }
        // 双通关井底取得「时间穿梭器」后，工台额外开放装备入口（零耗料、已持有），驱动男主线轨迹残影。
        if (this.archive.artifactOwned) {
            out.push({
                id: ARTIFACT_WEAPON_ID,
                name: weaponNameOf(ARTIFACT_WEAPON_ID),
                desc: "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影",
                enhancedEffect: "light",
                cost: {},
                crafted: true,
            });
        }
        return out;
    }

    /** 工台视图每帧跟随运行态：材料、装备、配方已做标记。 */
    private syncCraftBench(): void {
        const view = this.craftBench;
        const inv = this.run.inventory;
        view.inventory = { wood: inv.wood, bell: inv.bell, scrap: inv.scrap, wedge: inv.wedge, ammo: inv.ammo };
        view.recipes = this.recipeViews();
        view.equippedWeapon = this.equippedWeapon;
        view.firstCraftDone = this.run.story.craftedWeapon !== "";
        if (view.justCraftedTimer > 0) {
            view.justCraftedTimer = Math.max(0, view.justCraftedTimer - STEP);
        }
    }

    /** 走到工台按 E：放下小满，开面板。安全区不刷敌兵。 */
    openCraftBench(): void {
        if (this.room.key !== "escort3" || this.craftBench.active) {
            return;
        }
        this.craftBench.active = true;
        this.carryOn = false;
        this.run.story.carry = false;
        this.player.vx = 0;
        this.player.vy = 0;
        this.craftBench.justCraftedTimer = 0;
        this.syncCraftBench();
        this.flashSet("放下小满 · 工台按 E 选一件改制", 1.6);
        this.log("开工台");
        this.emit("benchOpen", {
            recipes: this.craftBench.recipes.map((r) => r.id),
            inventory: this.craftBench.inventory,
            carry: this.carryOn,
        });
    }

    /** 关面板离站：重新背起小满，材料不足/未选也不拦路；第三段随即展开与刚改制武器联动的本领抽卡。 */
    closeCraftBench(): void {
        if (!this.craftBench.active) {
            return;
        }
        this.craftBench.active = false;
        this.craftBench.justCraftedTimer = 0;
        this.carryOn = true;
        this.run.story.carry = true;
        this.flashSet("重新背起小满 · 往山道", 1.4);
        this.log("离站背起");
        this.emit("benchClose", { equipped: this.equippedWeapon, crafted: this.run.story.craftedWeapon });
        if (this.room.key === "escort3" && this.storyRoute === "soldier") {
            this.triggerDeferredEscort3Draft();
        }
    }

    /** 第三段安全工台后置抽卡：确保玩家先选定引路灯铳/回声铳，再据此加权抽取 3 选 1 本领。 */
    triggerDeferredEscort3Draft(): boolean {
        if (this.room.key !== "escort3" || this.storyRoute !== "soldier" || this.run.finished) {
            return false;
        }
        if (this.run.story.talents === undefined) {
            this.run.story.talents = createStoryTalents(this.run.seed, 1);
        }
        const st = this.run.story.talents;
        if (!st.deferred && st.room === "escort3") {
            return false;
        }
        draftTalentOffers(st, "escort3", this.equippedWeapon);
        if (this.useEscortDeathSummary && st.offers.length > 0) {
            this.talentModalActive = true;
        }
        this.sessionDirty = true;
        return st.offers.length > 0;
    }

    /** 前端绑定房间时打开折笺选卡轻暂停（若本段仍有未选本领）。 */
    openTalentDraft(): void {
        if (this.getStoryTalentOffers().length > 0 && !this.craftBench.active && !this.escortFailed) {
            this.talentModalActive = true;
        }
    }

    /**
     * 制作一份配方：扣一份材料、产出一件、自动装备。
     * 同一 requestId 只结算一次；缺料、已做过或被顶替都只回拒绝。
     */
    craftAtBench(recipeId: string, requestId: string): boolean {
        if (!this.craftBench.active || this.handledCraftRequests[requestId] === true) {
            return false;
        }
        const recipe = findRecipe(recipeId);
        if (recipe === undefined || this.run.story.craftedWeapon !== "") {
            this.flashSet(this.run.story.craftedWeapon === "" ? "没有这件配方" : "这一件已经做了 · 只能二选一", 1.4);
            this.emit("benchRejected", { recipeId: recipeId, reason: this.run.story.craftedWeapon === "" ? "unknown" : "crafted" });
            return false;
        }
        const missing = missingMaterials(this.run.inventory, recipe);
        if (missing.length > 0) {
            this.flashSet("缺料 · " + missing.join(" / "), 1.6);
            this.emit("benchRejected", { recipeId: recipeId, reason: "materials", missing: missing });
            return false;
        }
        payMaterials(this.run.inventory, recipe);
        this.handledCraftRequests[requestId] = true;
        this.run.story.craftedWeapon = recipe.id;
        this.run.story.equippedWeapon = recipe.id;
        this.equippedWeapon = recipe.id;
        this.sessionDirty = true;
        this.craftBench.justCraftedTimer = this.craftBench.firstCraftDone ? 0.45 : 1.0;
        this.craftBench.firstCraftDone = true;
        this.syncCraftBench();
        this.flashSet("改制完成 · " + recipe.name + " · 已装备", 2.0);
        this.log("改制 " + recipe.id);
        this.emit("benchCraft", {
            recipeId: recipe.id,
            weapon: recipe.id,
            effect: recipe.enhancedEffect,
            wood: this.run.inventory.wood,
            bell: this.run.inventory.bell,
        });
        return true;
    }

    /** 换装：允许标准铳、工台已改制武器，以及双通关取得的时间穿梭器。 */
    equipWeapon(weaponId: string): boolean {
        const artifactOk = weaponId === ARTIFACT_WEAPON_ID && this.archive.artifactOwned;
        if (weaponId !== "standard_gun" && this.run.story.craftedWeapon !== weaponId && !artifactOk) {
            this.emit("benchRejected", { recipeId: weaponId, reason: "unknown" });
            return false;
        }
        this.equippedWeapon = weaponId;
        this.run.story.equippedWeapon = weaponId;
        this.sessionDirty = true;
        this.syncCraftBench();
        this.flashSet("已装备 " + weaponNameOf(weaponId), 1.0);
        this.emit("benchEquip", { weapon: weaponId });
        return true;
    }

    /** 男主线快捷切换「时间穿梭器」彩蛋装备（需已从井底拾取）。 */
    toggleArtifactWeapon(): boolean {
        if (!this.archive.artifactOwned || this.childMode) {
            return false;
        }
        if (this.equippedWeapon === ARTIFACT_WEAPON_ID) {
            const fallback = this.run.story.craftedWeapon !== "" ? this.run.story.craftedWeapon : "standard_gun";
            return this.equipWeapon(fallback);
        }
        return this.equipWeapon(ARTIFACT_WEAPON_ID);
    }

    /** 导出当前局中存档快照（供 app.ts 写入 watch-save/session.txt）。 */
    exportSession(): SessionSave {
        this.syncStory();
        const story = this.run.story;
        const inv = this.run.inventory;
        const taken: string[] = [];
        for (const k in this.run.taken) {
            if (this.run.taken[k] === true) {
                taken.push(k);
            }
        }
        const segments: string[] = [];
        for (const k in story.segments) {
            if (story.segments[k] === true) {
                segments.push(k);
            }
        }
        const props: string[] = [];
        for (const k in this.run.props) {
            const st = this.run.props[k];
            if (st !== undefined) {
                props.push(
                    k
                    + ":" + (st.broken ? "1" : "0")
                    + ":" + Math.round(st.hp)
                    + ":" + (st.wedge ? "1" : "0")
                    + ":" + (st.revealed === true ? "1" : "0"),
                );
            }
        }
        const talentRanks: string[] = [];
        if (story.talents !== undefined) {
            let ti = 0;
            for (ti = 0; ti < ALL_TALENTS.length; ti++) {
                const tid = ALL_TALENTS[ti];
                const rk = story.talents.ranks[tid] ?? 0;
                if (rk > 0) {
                    talentRanks.push(tid + ":" + rk);
                }
            }
        }
        return {
            // 小结停在倒地房间，续读从新一轮 escort1 的默认出生点开始。
            roomKey: this.escortFailed ? "escort1" : this.room.key,
            checkpoint: this.escortFailed ? 0 : this.checkpoint,
            seed: this.run.seed,
            route: story.route,
            hp: story.hp,
            maxHp: story.maxHp,
            hpAtGate: story.hpAtGate,
            maxHpAtGate: story.maxHpAtGate,
            settled: story.settled,
            phase: this.phase,
            countTick: story.countTick,
            phaseTick: story.phaseTick,
            handTicks: story.handTicks,
            handDone: story.handDone,
            lineSaid: story.lineSaid,
            tied: story.tied,
            carry: story.carry,
            escortDone: story.escortDone,
            craftedWeapon: story.craftedWeapon,
            equippedWeapon: this.equippedWeapon,
            wood: inv.wood,
            bell: inv.bell,
            scrap: inv.scrap,
            wedge: inv.wedge,
            ammo: inv.ammo,
            shield: inv.shield,
            pass: inv.pass,
            quickbelt: inv.quickbelt,
            taken,
            segments,
            cartAxle: this.cartAxle,
            cartDocked: this.cartDocked,
            campaignRoute: this.run.route,
            joined: this.run.joined,
            c1Latch: this.run.c1Latch,
            c2Latch: this.run.c2Latch,
            talentSeed: story.talents !== undefined ? story.talents.randomState : 0,
            talentRoom: story.talents !== undefined ? story.talents.room : "",
            talentOffers: story.talents !== undefined ? story.talents.offers.slice() : [],
            talentRanks,
            escortAttempt: story.talents !== undefined ? story.talents.attempt : 1,
            escortVariant: story.talents !== undefined ? story.talents.variant : 0,
            talentDeferred: story.talents !== undefined ? story.talents.deferred : false,
            talentVitality: story.talents !== undefined ? story.talents.ranks.vitality : 0,
            talentReload: story.talents !== undefined ? story.talents.ranks.focus : 0,
            talentGuard: story.talents !== undefined ? story.talents.ranks.guard : 0,
            talentCraft: story.talents !== undefined ? story.talents.ranks.salvage : 0,
            props,
            playerX: this.escortFailed ? undefined : this.player.x,
            playerY: this.escortFailed ? undefined : this.player.y,
            playerDepth: this.escortFailed ? undefined : this.player.depth,
            gateTick: this.gateTick,
            hasBottle: this.hasBottle,
            villagePassed: this.passed,
        };
    }

    /**
     * 前端结构化意图入口：换弹、工台制作/装备/关面板、风台牵手长按、水井与博物馆全步交互。
     * fe/contract.ts 的 forwardLiveIntent 优先调用它；为键鼠/触屏/网页/安卓提供统一入口。
     */
    submitFeIntent(intent: { kind: string; [key: string]: unknown }): boolean {
        const kind = intent === undefined ? "" : intent.kind;
        if (kind === "gateReunionHold") {
            if (this.room.key !== "gate" || (this.phase !== "gate-wait" && this.phase !== "gate-count")) {
                return false;
            }
            const holding = intent.holding === true;
            this.intentGateReunionHold = holding;
            if (!holding && this.phase === "gate-wait") {
                if (this.handTicks > 0) {
                    this.emit("handRelease", { handTicks: this.handTicks, handNeedTicks: GATE_HAND_TICKS });
                }
                this.handTicks = 0;
                this.handArmed = true;
            }
            return true;
        }
        if (kind === "reloadOpen") {
            const camp = this.room.campaign;
            if (camp === undefined || camp.reloadPuzzle !== true || this.reloadOpen) {
                return false;
            }
            this.beginReload();
            return this.reloadOpen;
        }
        if (kind === "reloadPathPreview") {
            const path = intent.path;
            return typeof path === "object" && path !== undefined && Array.isArray(path);
        }
        if (kind === "reloadTapNode") {
            const node = intent.node;
            if (typeof node === "number") {
                this.reloadTapNode(node);
                return true;
            }
            return false;
        }
        if (kind === "reloadPathCommit") {
            const path = intent.path;
            if (typeof path === "object" && path !== undefined && Array.isArray(path)) {
                const list = path as number[];
                let i = 0;
                for (i = 0; i < list.length; i++) {
                    if (i === 0 && list[i] === RELOAD_START) {
                        continue;
                    }
                    this.reloadTapNode(list[i]);
                }
                return true;
            }
            return false;
        }
        if (kind === "reloadCancel") {
            this.closeReloadPuzzle();
            return true;
        }
        if (kind === "craftSubmit") {
            const recipeId = intent.recipeId;
            const requestId = intent.requestId;
            if (typeof recipeId === "string" && typeof requestId === "string") {
                return this.craftAtBench(recipeId, requestId);
            }
            return false;
        }
        if (kind === "craftEquip") {
            const weaponId = intent.weaponId;
            if (typeof weaponId === "string") {
                return this.equipWeapon(weaponId);
            }
            return false;
        }
        if (kind === "craftClose") {
            this.closeCraftBench();
            return true;
        }
        if (kind === "chooseTalent") {
            const slot = intent.slot;
            if (typeof slot === "number") {
                return this.chooseTalent(slot);
            }
            return false;
        }
        if (kind === "wellPick") {
            return this.pickWell();
        }
        if (kind === "museumInteract") {
            const target = typeof intent.target === "string" ? intent.target : "";
            if (target === "well_pickup" || target === "well") {
                return this.pickWell();
            }
            if (this.room.key !== "museum") {
                return false;
            }
            return this.triggerMuseumIntent(target);
        }
        return false;
    }

    /** 结构化意图推进博物馆单步交互（与实体 E 键共享同一套校验与写档逻辑，并同时兼容前端 E01/E02 别名）。 */
    private triggerMuseumIntent(target: string): boolean {
        const mu = this.room.story === undefined || this.room.story.museum === undefined
            ? { cabinetX: 200, hallX: 900, lampX: 1250, exitX: 1360 }
            : this.room.story.museum;
        const atCase = this.player.x <= this.ox + mu.cabinetX + 60;
        const nearLamp = this.player.x >= this.ox + mu.lampX - 72;
        if (this.phase === "museum-cabinet") {
            if (target === "enter_hall" || ((target === "" || target === "cabinet" || target === "weapon_case") && atCase)) {
                this.pendingMuseumIntentTarget = "cabinet";
                return true;
            }
        }
        if (this.phase === "museum-hall") {
            if ((target === "lamp_turn" || target === "lamp" || target === "west_lamp") && nearLamp) {
                this.pendingMuseumIntentTarget = "lamp_direct";
                return true;
            }
            if ((target === "" || target === "hall" || target === "corridor") && this.player.x >= this.ox + mu.hallX) {
                this.pendingMuseumIntentTarget = "hall";
                return true;
            }
        }
        if (this.phase === "museum-lamp"
            && (target === "" || target === "lamp" || target === "west_lamp" || target === "lamp_turn")
            && nearLamp) {
            this.pendingMuseumIntentTarget = "lamp";
            return true;
        }
        if (this.phase === "museum-return") {
            if (target === "begin_return_cabinet"
                || ((target === "" || target === "return_cabinet" || target === "cabinet" || target === "return") && atCase)) {
                this.pendingMuseumIntentTarget = "return_cabinet";
                return true;
            }
        }
        if (this.phase === "museum-done" && (target === "" || target === "return_cabinet" || target === "return")) {
            this.pendingMuseumIntentTarget = "done";
            return true;
        }
        return false;
    }

    /** 检查点快照：踩到 kind 0 标记时把库存、装备、已改制与背负整份记下。 */
    private captureCheckpoint(id: number): void {
        const inv = this.run.inventory;
        this.checkpointSnap = {
            id: id,
            wood: inv.wood,
            bell: inv.bell,
            scrap: inv.scrap,
            wedge: inv.wedge,
            ammo: inv.ammo,
            shield: inv.shield,
            pass: inv.pass,
            quickbelt: inv.quickbelt,
            crafted: this.run.story.craftedWeapon,
            equipped: this.equippedWeapon,
            carry: this.carryOn,
        };
        this.run.story.cp = this.checkpointSnap;
    }

    /** 回到这份检查点：制前回到未改制，制后回到已装备。 */
    private applyCheckpointSnap(id: number): boolean {
        const snap = this.run.story.cp;
        if (snap === undefined || snap.id !== id) {
            return false;
        }
        this.checkpointSnap = snap;
        const inv = this.run.inventory;
        inv.wood = snap.wood;
        inv.bell = snap.bell;
        inv.scrap = snap.scrap;
        inv.wedge = snap.wedge;
        inv.ammo = snap.ammo;
        inv.shield = snap.shield;
        inv.pass = snap.pass;
        inv.quickbelt = snap.quickbelt;
        this.run.story.craftedWeapon = snap.crafted;
        this.equippedWeapon = snap.equipped;
        this.run.story.equippedWeapon = snap.equipped;
        this.carryOn = snap.carry;
        this.run.story.carry = snap.carry;
        this.craftBench.active = false;
        this.syncCraftBench();
        return true;
    }

    private restoreStory(): void {
        const story = this.run.story;
        if (story === undefined) {
            return;
        }
        if (story.maxHp > 0) {
            this.maxHp = story.maxHp;
            this.hp = Math.max(1, Math.min(story.hp, story.maxHp));
        }
        this.storyRoute = story.route;
        this.storySettled = story.settled;
        this.hpAtGate = story.hpAtGate;
        this.maxHpAtGate = story.maxHpAtGate;
        this.handDone = story.handDone;
        this.lineSaid = story.lineSaid;
        this.tied = story.handDone;
        this.carryOn = story.carry || (story.route === "soldier" && this.room.key.indexOf("escort") === 0);
        this.museumReturn = story.museumReturn;
        story.museumReturn = false;
        this.escortDone = story.escortDone;
        this.syncCraftBench();
        // 城外红布车一旦拉开，后续所有 outside 实例都保持石阶口与下层水路敞开。
        if (story.segments["outside_cart"] === true) {
            this.redCartPulled = true;
            const redBox = this.boxes.find((b) => b.id === "outside_red_cart");
            if (redBox !== undefined) {
                redBox.x0 = 430;
                redBox.x1 = 474;
            }
            if (this.room.key === "outside" && this.room.cart.bodyW > 0) {
                this.cartAxle = this.room.cart.endX;
                this.cartDocked = true;
            }
        }
        this.forestPath = story.segments["forest_burrow"] === true ? "burrow"
            : story.segments["forest_ditch"] === true ? "ditch" : "";
        this.waterSeen = story.segments["water_lantern"] === true;
        // 检查点恢复：制前 / 制后各自的库存、装备与背负整份回滚。
        if (this.checkpoint > 0 && story.cp !== undefined && story.cp.id === this.checkpoint) {
            this.applyCheckpointSnap(this.checkpoint);
        }
        // 北塔：男主背着妹妹到门前，放下小满并肩同行（player=周戍，partner=小满，均在左塔墙 180..400 外侧）。
        if (this.room.key === "tower" && story.route === "soldier") {
            this.carryOn = false;
            this.run.story.carry = false;
            this.player.w = SOLDIER_W;
            this.player.h = SOLDIER_H;
            this.player.x = Math.max(this.ox + 422, this.player.x);
            this.partner = {
                x: Math.max(this.ox + 408, this.player.x - 24),
                y: 0,
                depth: 0,
                depthSpeed: 0,
                vx: 0,
                vy: 0,
                w: CHILD_W,
                h: CHILD_H,
                onGround: true,
                facing: 1,
                crouch: false,
                rollT: 0,
                covered: false,
                alive: true,
            };
        }
        // 北塔门廊/值夜室：门开、交物与中途阶段可续读。
        if (this.room.key === "tower") {
            if (story.segments["tower_door"] === true) {
                this.openTowerDoor();
            }
            this.towerHanded = story.segments["tower_handover"] === true;
            this.deskHold = 0;
            if (story.phase === "tower-enter" || story.phase === "tower-desk" || story.phase === "tower-given") {
                this.phase = story.phase;
                this.phaseTick = 0;
                if (story.phase === "tower-desk" || story.phase === "tower-given") {
                    this.player.x = this.ox + 605;
                    this.player.y = 0;
                    if (story.route === "soldier" && this.partner.alive) {
                        this.partner.x = this.ox + 568;
                        this.partner.y = 0;
                        this.partner.facing = 1;
                    }
                }
            }
        }
        // 序章：从正式入口重开时重播 P01/P02；已递针套/已跟随的续读直接从对应段起。
        if (this.room.key === "prologue") {
            const ph = story.phase;
            if (ph === "prologue-wait" || ph === "prologue-give" || ph === "prologue-follow") {
                this.phase = ph;
                this.phaseTick = story.phaseTick;
                this.player.x = this.ox + (ph === "prologue-follow" ? 620 : 260);
                this.player.y = 0;
                this.player.depth = 0;
                this.player.vx = 0;
                this.partner.x = this.ox + 300;
                this.partner.y = 0;
                this.partner.depth = 0;
                this.partner.vx = 0;
                this.partner.alive = true;
                if (ph === "prologue-follow") {
                    this.partner.crouch = false;
                    this.partner.h = CHILD_H;
                } else {
                    this.partner.crouch = true;
                    this.partner.h = CHILD_CROUCH_H;
                }
                this.cam.x = this.player.x;
            }
            return;
        }
        if (this.room.key !== "gate") {
            return;
        }
        const g = this.room.story === undefined ? undefined : this.room.story.gate;
        if (g === undefined) {
            return;
        }
        // 守满、还没送别就按 R：回到待送别状态，不重打 45 秒守点，也不提前锁线。
        if (story.phase === "gate-send") {
            this.phase = "gate-send";
            this.gateTick = g.holdTicks;
            this.gateSpawned = 4;
            this.enemies = [];
            this.player.x = this.ox + g.doorX - 40;
            this.player.y = 0;
            this.player.depth = 0;
            this.player.vx = 0;
            this.player.vy = 0;
            this.player.onGround = true;
            this.partner.x = this.ox + g.waitX;
            this.partner.y = 0;
            this.partner.depth = 0;
            this.partner.alive = true;
            this.cam.x = this.player.x;
            this.handTicks = 0;
            this.handArmed = false;
            this.flashSet("守满了 · 到门边按 E 送她", 2.0);
            return;
        }
        if (!story.settled) {
            return;
        }
        // 锁线后重试/续读：只回到已经看过的演出拍，敌兵与守点不再重来。
        this.gateTick = g.holdTicks;
        this.gateSpawned = 4;
        this.enemies = [];
        if (story.phase === "gate-farewell" || story.phase === "gate-count" || story.phase === "gate-walk") {
            this.phase = story.phase === "gate-farewell" ? "gate-count" : story.phase;
            this.countTick = story.phase === "gate-farewell" ? 0 : Math.max(story.countTick, 0);
            this.swapToChild(g.doorX + 30);
            this.countPrevMove = 0;
            this.countArmed = false;
            return;
        }
        if (story.phase === "gate-wait" || story.phase === "gate-hand") {
            this.phase = story.phase;
            this.countTick = GATE_COUNT_END;
            this.phaseTick = story.phaseTick;
            this.swapToChild(g.doorX + 30);
            this.handTicks = story.handDone ? GATE_HAND_TICKS : Math.max(0, Math.min(GATE_HAND_TICKS, story.handTicks));
            this.handArmed = false;
        }
    }

    /** 把房间数据转成碰撞盒；stairs 按级拆成可站立的台阶。 */
    private buildWorld(): void {
        const room = this.room;
        this.boxes = [];
        this.floors = [];
        let i = 0;
        for (i = 0; i < room.floors.length; i++) {
            const f = room.floors[i];
            this.floors.push({ x0: f.x0, x1: f.x1, y0: f.y, y1: f.y });
        }
        for (i = 0; i < room.solids.length; i++) {
            const s: SolidSpec = room.solids[i];
            if (!s.decorative) {
                // lanes 把同一件实体拆成几块占地：分开的档位之间留出通行缝，
                // 相邻档位合成一块，碰撞、挡弹、寻路都按这几块算。
                // lanes 已在 withOrigin/placeSolids 拆成逐档的实体，这里只做一次入箱；
                // 没有 depth 的旧房间保持整条通路都挡。
                this.boxes.push({
                    x0: s.x, x1: s.x + s.w, y0: s.y, y1: s.y + s.h,
                    depth: room.depth === undefined ? undefined : s.depth,
                    passable: s.passable === true, label: s.label,
                    id: s.id, soft: s.soft === true, hidden: s.hidden === true,
                    breakable: s.breakable === undefined ? undefined : { ...s.breakable },
                    interact: s.interact,
                });
            }
        }
        for (i = 0; i < room.stairs.length; i++) {
            const st = room.stairs[i];
            const n = st.steps + 1;
            const stepW = (st.x1 - st.x0) / n;
            let k = 0;
            for (k = 0; k < n; k++) {
                const y = st.y0 + (st.y1 - st.y0) * k / (n - 1);
                const x0 = st.x0 + stepW * k;
                // 台阶做成单向平台：从台面下来能踩，从地面走过不会被挡住，也不会从下方撞头。
                // 2.5D 房间内台阶继承自身的纵深范围，避免其它空车道出现隐形悬空梯。
                this.boxes.push({
                    x0: x0, x1: x0 + stepW, y0: -8, y1: y,
                    depth: room.depth === undefined ? undefined : st.depth,
                    passable: true,
                });
            }
        }
    }

    /**
     * 新版关卡开局：玩家按路线站位、小满到等待点、敌兵从房间 spawns 生成、
     * 机关按运行态恢复（碎掉的薄木挡、放下的帘、已抬的闩）。
     */
    private setupCampaign(): void {
        const wr = this.room;
        const c = wr.campaign;
        if (c === undefined) {
            return;
        }
        this.roomStartTick = this.run.ticks;
        // S1 是共同起点：小满当拍就在队尾，A 线全程带着走。
        if (wr.key === "s1-crossroad" || wr.key === "escort1" || wr.key === "escort2" || wr.key === "escort3"
            || wr.key === "escort4" || wr.key === "escort5") {
            this.run.joined = true;
        } else if (wr.companion !== undefined && wr.companion.followAfter !== undefined) {
            // 布行线要在布行里等窗板放落；外檐线沿街一路同行。候检院则抬闩后保持同行（支持续读）。
            this.run.joined = wr.key === "s2-drygoods"
                ? (this.run.route !== "drygoods" || this.run.props["s2_board"]?.broken === true)
                : (wr.key === "c1-yard" && this.run.c1Latch);
        }
        let x = wr.minX + 60;
        let y = 0;
        let depth = 0;
        if (wr.key === "s2-drygoods" && this.run.route === "drygoods") {
            x = wr.minX + 210;
            depth = -32;
        } else if (wr.key === "s3-archway" && this.run.route === "drygoods") {
            x = wr.minX + 40;
            y = 32;
            depth = 32;
        }
        this.player = {
            x: x, y: y, depth: depth, depthSpeed: 0, vx: 0, vy: 0,
            w: SOLDIER_W, h: SOLDIER_H, onGround: y <= 0, facing: 1, crouch: false, rollT: 0, covered: false, alive: true,
        };
        this.partner = {
            x: x + 60, y: y, depth: depth, depthSpeed: 0, vx: 0, vy: 0,
            w: CHILD_W, h: CHILD_H, onGround: y <= 0, facing: 1, crouch: false, rollT: 0, covered: false, alive: true,
        };
        this.cam.x = x;
        this.cam.y = y + CAM_LOOK_UP;
        this.phase = "run";
        this.hp = this.maxHp;
        if (this.isEscortRoom() && this.run.story.route === "soldier") {
            if (this.run.story.talents === undefined) {
                this.run.story.talents = createStoryTalents(this.run.seed, 1);
            }
            const st = this.run.story.talents;
            const variants = ESCORT_VARIANTS[wr.key];
            if (this.run.source !== "debug" && variants !== undefined && variants.length > 0) {
                st.variant = pickEscortVariant(this.run.seed, st.attempt, wr.key, variants.length);
            } else {
                st.variant = 0;
            }
            // 第三段安全工台先让玩家改制装备，关闭工台（或越过工台区）后再按新武器加权抽本领；
            // 其余护送段进房即抽 3 选 1。
            if (wr.key === "escort3") {
                if (st.room !== "escort3") {
                    st.room = "escort3";
                    st.deferred = true;
                    st.offers = [];
                }
            } else {
                draftTalentOffers(st, wr.key, this.equippedWeapon);
            }
        }
        this.buildEnemies();
        this.pickups = wr.pickups === undefined ? [] : wr.pickups.slice();
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.id === undefined) {
                continue;
            }
            const st = this.run.props[b.id];
            if (st !== undefined) {
                b.broken = st.broken;
                b.breakable = b.breakable === undefined ? undefined : { ...b.breakable, hp: st.hp };
                b.hidden = b.hidden === true && st.revealed !== true;
                if (b.hidden) {
                    b.broken = true;
                }
            } else if (b.hidden === true) {
                // 卷起的帘 / 背后的窗板：机关没开就不在场。
                b.broken = true;
            }
        }
        if (wr.cart.bodyW > 0) {
            this.cartAxle = wr.cart.startX;
            if (this.run.props["c2_cart"] !== undefined && this.run.props["c2_cart"].broken) {
                this.cartAxle = wr.cart.endX;
                this.cartDocked = true;
            }
        }
        this.log("进入 " + wr.name + " · " + this.run.route);
    }

    private log(line: string): void {
        this.run.log.push("[" + this.run.ticks + "] " + line);
        if (this.run.log.length > 120) {
            this.run.log.shift();
        }
    }

    private buildEnemies(): void {
        this.enemies = [];
        if (this.isCampaign) {
            const variants = ESCORT_VARIANTS[this.room.key];
            const useVariant = this.isEscortRoom()
                && this.run.story.route === "soldier"
                && this.run.source !== "debug"
                && variants !== undefined
                && variants.length > 0;
            const vIdx = useVariant
                ? Math.max(0, Math.min(variants.length - 1, this.run.story.talents?.variant ?? 0))
                : 0;
            const spawnList = useVariant ? variants[vIdx] : this.room.spawns;
            let i = 0;
            for (i = 0; i < spawnList.length; i++) {
                const sp = spawnList[i];
                const kind = sp.kind ?? "gunner";
                const hp = sp.shieldHp ?? (kind === "shield" ? 2 : 0);
                const sx = useVariant ? this.ox + sp.x : sp.x;
                this.enemies.push({
                    x: sx, y: sp.y, depth: sp.depth, w: 26, h: sp.h, alive: true, hitT: 0, warnT: 0, fireCd: 40,
                    kind: kind, shieldHp: hp, shieldHpMax: hp, drop: sp.drop ?? "none",
                    homeX: sx, swingT: 0, awake: false, squad: i,
                });
            }
            return;
        }
        if (this.room.key === "checkpoint") {
            this.enemies.push({ x: this.ox + 430, y: 0, w: 26, h: 84, alive: true, hitT: 0, warnT: 0, fireCd: 0 });
            this.enemies.push({ x: this.ox + 505, y: 0, w: 26, h: 84, alive: true, hitT: 0, warnT: 0, fireCd: 0 });
            return;
        }
        if (this.room.key === "street") {
            // 街道第一次交火：柜台后一个、街心一个。
            this.enemies.push({ x: this.ox + 340, y: 0, w: 26, h: 84, alive: true, hitT: 0, warnT: 0, fireCd: 0 });
            this.enemies.push({ x: this.ox + 560, y: 0, w: 26, h: 84, alive: true, hitT: 0, warnT: 0, fireCd: 0 });
        }
        // 城门的四批敌兵由 stepGate 按守点拍数登场。
    }

    /** 记一条一次性事件。超过 256 条丢最旧的，防止前端还没接时队列无限长。 */
    private emit(name: PlayEventName, data: Record<string, unknown>): void {
        this.events.push({ seq: this.eventSeq, tick: this.ticks, name: name, data: data });
        this.eventSeq += 1;
        if (this.events.length > 256) {
            this.events.shift();
        }
    }

    /**
     * 前端每渲染帧调用一次：拿回自上次调用以来所有模拟步产生的事件，并清空队列。
     * 一次补跑 N 步时这里会按 seq 顺序给出 N 步的全部事件；0 步帧返回空数组。
     */
    drainEvents(): PlayEvent[] {
        const out = this.events;
        this.events = [];
        return out;
    }

    /**
     * 切房换实例时，把旧实例尚未消费的事件接到新实例队首。
     * app 在 ensurePlay 前先 drain 旧队列，再调用这里；seq 重新编号，tick 保留旧值。
     * 旧房间的 knock 不迁移：跨出口同拍按 E 时，旧房敲声不能在新房重播；
     * 新房自己的 knock 由新房 update 正常产生。
     */
    adoptEvents(events: PlayEvent[]): void {
        if (events.length === 0) {
            return;
        }
        const keep: PlayEvent[] = [];
        let i = 0;
        for (i = 0; i < events.length; i++) {
            const e = events[i];
            if (e.name === "knock" && e.data.room !== this.room.key) {
                continue;
            }
            keep.push(e);
        }
        if (keep.length === 0) {
            return;
        }
        this.events = keep.concat(this.events);
        for (i = 0; i < this.events.length; i++) {
            this.events[i].seq = i;
        }
        this.eventSeq = this.events.length;
    }

    private talentRank(talent: Talent): number {
        if (this.storyRoute === "soldier" && this.isEscortRoom() && this.run.story.talents !== undefined) {
            return this.run.story.talents.ranks[talent] ?? 0;
        }
        return 0;
    }

    /** 当前慢时连线换弹的作答预算拍数（默认 240 拍 = 4 秒；每重「凝神」+60 拍 = +1 秒）。 */
    reloadNeedTicks(): number {
        return RELOAD_ANSWER_TICKS + 60 * this.talentRank("focus");
    }

    /** 正式男主线护送段当前可三选一的本领列表（非男主线或已选完时为空）。 */
    getStoryTalentOffers(): Talent[] {
        if (this.storyRoute !== "soldier" || !this.isEscortRoom() || this.run.finished) {
            return [];
        }
        const st = this.run.story.talents;
        return st !== undefined && st.room === this.room.key ? st.offers : [];
    }

    /** 正式男主线护送段已习得的本领等级表。 */
    getStoryTalentRanks(): Record<Talent, number> | undefined {
        if (this.storyRoute !== "soldier" || !this.isEscortRoom()) {
            return undefined;
        }
        return this.run.story.talents !== undefined ? this.run.story.talents.ranks : undefined;
    }

    /** 当前男主线护送的轮回次序（1 起步）。 */
    getEscortAttempt(): number {
        return this.run.story.talents !== undefined ? Math.max(1, this.run.story.talents.attempt) : 1;
    }

    chooseTalent(slot: number): boolean {
        if (this.storyRoute !== "soldier" || !this.isEscortRoom() || this.run.finished) {
            return false;
        }
        const st = this.run.story.talents;
        const talent = st !== undefined ? st.offers[slot] : undefined;
        if (st === undefined || talent === undefined) {
            return false;
        }
        st.ranks[talent] = (st.ranks[talent] ?? 0) + 1;
        st.offers = [];
        this.talentModalActive = false;
        let extraMsg = "";
        if (talent === "vitality") {
            this.maxHp += 1;
            this.hp += 1;
            this.run.story.maxHp = this.maxHp;
            this.run.story.hp = this.hp;
        } else if (talent === "salvage") {
            const inv = this.run.inventory;
            if ((inv.wood < 2 && inv.wood <= inv.bell) || (inv.bell >= 1 && st.ranks.salvage % 2 === 1)) {
                inv.wood += 1;
                extraMsg = " · 得木纹筹×1";
            } else {
                inv.bell += 1;
                extraMsg = " · 得铃纹筹×1";
            }
            this.syncCraftBench();
        }
        this.sessionDirty = true;
        this.flashSet("本领 · " + talentNames[talent] + extraMsg, 1.5);
        this.emit("storyBeat", { beat: "talent_picked", talent: talent, rank: st.ranks[talent], room: this.room.key });
        return true;
    }

    /**
     * 进入一次换弹：设好装填拍。
     * 3×3 慢时线盘在男主线五段护送（reloadPuzzle === true）自动开启。
     */
    private beginReload(): void {
        this.reloadT = this.reloadTicks();
        const camp = this.room.campaign;
        if (camp !== undefined && camp.reloadPuzzle === true) {
            this.openReloadPuzzle();
        }
    }

    /** 开线盘：从枪膛起点 0 起笔，作答预算受「凝神」本领扩展；重开清空旧路径。 */
    private openReloadPuzzle(): void {
        this.reloadOpen = true;
        this.reloadAnswerTicks = 0;
        this.reloadWorldTicks = 0;
        this.reloadPath = [RELOAD_START];
        this.reloadPendingEffect = "";
        this.reloadTryCount += 1;
        this.emit("reloadOpen", { tryCount: this.reloadTryCount, needTicks: this.reloadNeedTicks() });
    }

    /** 补弹/被打倒/换房时收起盘子：世界恢复正常速，未结算的效果作废。 */
    private closeReloadPuzzle(): void {
        this.reloadOpen = false;
        this.reloadAnswerTicks = 0;
        this.reloadWorldTicks = 0;
        this.reloadPath = [RELOAD_START];
        this.reloadPendingEffect = "";
    }

    /**
     * 前端点 3×3 盘上的一个节点：只接受与当前末点相邻、未走过的点。
     * 不合法只清回起点重画，不重计时；画到枪机复位点 8 就结算一次效果。
     */
    reloadTapNode(node: number): void {
        if (!this.reloadOpen) {
            return;
        }
        const path = this.reloadPath;
        const last = path[path.length - 1];
        if (path.indexOf(node) >= 0 || !reloadAdjacent(last, node)) {
            this.reloadPath = [RELOAD_START];
            this.emit("reloadInvalid", { node: node, at: last });
            return;
        }
        path.push(node);
        if (node !== RELOAD_TARGET) {
            this.emit("reloadNode", { node: node, pathLength: path.length });
            return;
        }
        if (!reloadPathValid(path)) {
            this.reloadPath = [RELOAD_START];
            this.emit("reloadInvalid", { node: node, at: last });
            return;
        }
        this.reloadPendingEffect = reloadEffectOf(path);
        this.reloadOpen = false;
        this.reloadT = 0;
        this.emit("reloadSolved", {
            effect: this.reloadPendingEffect, answerTicks: this.reloadAnswerTicks, pathLength: path.length,
        });
        this.flashSet("枪机复位 · " + reloadEffectName(this.reloadPendingEffect), 1.4);
    }

    /** 取走已画好的效果：一枪只消费一次。 */
    private consumeReloadEffect(): ReloadEffect {
        const e = this.reloadPendingEffect;
        if (e !== "") {
            this.reloadPendingEffect = "";
        }
        return e;
    }

    /**
     * 回声：把这一枪的余响引到最近还在场的敌人身上。
     * 他被惊动、枪口先抬一下（下一次开火延后），给玩家一个换位窗口。
     */
    private echoToSource(from: Actor, count: number = 1, delayTicks: number = 60): void {
        let best = -1;
        let bestD = 1e9;
        let i = 0;
        const woken: Record<number, boolean> = {};
        let n = 0;
        while (n < count) {
            best = -1;
            bestD = 1e9;
            for (i = 0; i < this.enemies.length; i++) {
                if (woken[i] === true) {
                    continue;
                }
                const e = this.enemies[i];
                if (!e.alive) {
                    continue;
                }
                const d = Math.abs(e.x - from.x);
                if (d < bestD) {
                    bestD = d;
                    best = i;
                }
            }
            if (best < 0) {
                break;
            }
            woken[best] = true;
            const e = this.enemies[best];
            e.awake = true;
            e.warnT = 0;
            e.fireCd = Math.max(e.fireCd ?? 0, delayTicks);
            n += 1;
        }
        if (n === 0) {
            return;
        }
        this.flashSet(n > 1 ? "回声引到多处声源 · 敌群同时抬枪" : "回声引到声源 · 他先抬枪", 1.0);
    }

    private reloadTicks(): number {
        return Math.max(6, this.run.inventory.quickbelt > 0 ? 36 : 54);
    }

    update(dt: number, input: Input): void {
        this.syncCraftBench();
        if (!this.paused && this.craftBench.active && input.pause.pressed) {
            this.closeCraftBench();
            return;
        }
        if (input.pause.pressed) {
            this.paused = !this.paused;
        }
        if (this.flashT > 0) {
            this.flashT -= dt;
            if (this.flashT <= 0) {
                this.flash = "";
            }
        }
        if (this.traceT > 0) {
            this.traceT -= dt;
            if (this.traceT <= 0) {
                this.trace = undefined;
            }
        }
        if (this.paused) {
            this.updateCamera(dt);
            return;
        }
        // 男主线战斗折戟：前端展示轮回小结并停驻世界，等玩家确认再赴第一段或回标题。
        if (this.escortFailed) {
            this.escortFailedTicks += 1;
            this.updateCamera(dt);
            return;
        }
        // 工台面板打开：世界停在开面板那一拍，玩家不推进、敌兵不动；
        // 面板用 E 确认配方，制作和装备由前端提交。
        if (this.craftBench.active) {
            this.updateCamera(dt);
            return;
        }
        // 男主线折笺选卡轻暂停（仅在前端挂接后激活，独立无头回放保持非阻塞）。
        if (this.talentModalActive && this.getStoryTalentOffers().length > 0 && !this.reloadOpen) {
            this.updateCamera(dt);
            return;
        }

        // 慢时换弹：盘开着时世界 1/4 速。作答拍照走，只有每 4 拍推进 1 个世界拍；
        // 超时只关闭盘子并回到普通装填，不额外扣血或重开房间。
        if (this.reloadOpen) {
            const needTicks = this.reloadNeedTicks();
            this.reloadAnswerTicks += 1;
            if (this.reloadAnswerTicks > needTicks) {
                this.reloadOpen = false;
                this.reloadPendingEffect = "";
                this.emit("reloadTimeout", { answerTicks: this.reloadAnswerTicks, needTicks: needTicks });
                this.flashSet("换弹超时 · 普通装填", 1.2);
            } else if (this.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD !== 0) {
                this.updateCamera(dt);
                return;
            } else {
                this.reloadWorldTicks += 1;
            }
        }

        this.ticks += 1;
        // 保护按「可控模拟拍」走，暂停期间不递减：从暂停里回来时，
        // 剩余保护应当还是离开时那么多，而不是被墙钟吃掉。
        if (this.invulnT > 0) {
            this.invulnT -= 1;
        }
        if (this.isCampaign) {
            this.run.ticks += 1;
            this.run.roomTicks[this.room.key] = (this.run.roomTicks[this.room.key] ?? 0) + 1;
        }
        const p = this.player;
        this.stepPlayer(p, dt, input);
        // 移动结束后再定贴靠：本拍的身体边缘、垂直重叠、来向都按新位置算。
        this.refreshCover(p, input);
        if (this.carryOn) {
            this.carryPose();
        }
        if (this.isCampaign) {
            this.stepCampaign(dt, input);
            if (!this.carryOn) {
                this.stepCampaignPartner(dt);
            }
        }
        // 敌兵先于剧情结算：守点最后一拍的开火不能被「进入送别」吞掉。
        // campaign 房也走 stepEnemies：内部再分流到护送敌兵，城门/街道的旧敌兵不进这段。
        this.stepEnemies(dt, input);
        if (!this.isCampaign) {
            this.stepStory(dt, input);
            this.stepEscort(dt, input);
            this.stepVillage(dt, input);
            this.stepChase(dt, input);
            this.stepInteract(dt, input);
        }
        this.updateGate();
        this.updateCamera(dt);
        // 本拍结束把血量与演出拍写回跨房快照：切房、R 重试、菜单续读都读它。
        this.syncStory();
    }

    /**
     * 低拱下不能起身：站高会穿顶、蹲高能过。只对小满生效。
     * 用身体左右边缘判是否还在拱内，走出拱后下一拍才恢复站姿。
     */
    private underLowArch(a: Actor): boolean {
        const arch = this.room.arch;
        if (arch.h <= 0) {
            return false;
        }
        if (a.x + a.w / 2 <= arch.x0 || a.x - a.w / 2 >= arch.x1) {
            return false;
        }
        const top = arch.y + arch.h;
        return a.y + CHILD_H > top && a.y + CHILD_CROUCH_H <= top;
    }

    /**
     * 贴靠实体：按移动后的身体左右边缘量水平间隙，并要求垂直重叠。
     * 间隙 <24 算贴住；多个实体取间隙最小的那件，返回 undefined 表示没贴住。
     */
    private coverAt(a: Actor): Box | undefined {
        let best: Box | undefined = undefined;
        let bestGap = 24;
        const half = a.w / 2;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.passable === true || b.y1 - b.y0 < 44 || !overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF)) {
                continue;
            }
            if (a.y + a.h <= b.y0 + 0.001 || a.y >= b.y1 - 0.001) {
                continue;
            }
            const gap = Math.max(b.x0 - (a.x + half), (a.x - half) - b.x1, 0);
            if (gap < bestGap) {
                bestGap = gap;
                best = b;
            }
        }
        return best;
    }

    private nearCover(a: Actor): boolean {
        return this.coverAt(a) !== undefined;
    }

    /** 实体是否挡在 a 与来敌之间：敌人从右来，实体主体要在 a 右侧且不越过敌人。 */
    private coverGuardsFrom(b: Box, a: Actor, enemy: Enemy | undefined): boolean {
        if (enemy === undefined) {
            return false;
        }
        const fromRight = enemy.x >= a.x;
        const edge = fromRight ? b.x0 : b.x1;
        const between = fromRight ? edge >= a.x - 0.001 && edge <= enemy.x
            : edge <= a.x + 0.001 && edge >= enemy.x;
        const separation = enemy.x - a.x;
        const fraction = separation === 0 ? 0 : (edge - a.x) / separation;
        const depthAtEdge = a.depth + ((enemy.depth ?? 0) - a.depth) * fraction;
        return between && overlapsDepth(depthAtEdge, b.depth, 0);
    }

    private nearestEnemy(a: Actor): Enemy | undefined {
        let best: Enemy | undefined;
        let bestD = 1e9;
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            const d = Math.abs(e.x - a.x);
            if (d < bestD) {
                bestD = d;
                best = e;
            }
        }
        return best;
    }

    /** 移动后刷新贴靠状态：姿态、HUD、事件都读这里，别处不再各算一遍。 */
    private refreshCover(a: Actor, input: Input): void {
        if (this.childMode) {
            this.coverNear = false;
            this.coverHug = false;
            this.coverEntity = "";
            this.coverBlocking = false;
            a.covered = false;
            return;
        }
        const b = this.coverAt(a);
        this.coverNear = b !== undefined;
        a.covered = this.coverNear && input.cover.held;
        this.coverHug = a.covered;
        this.coverEntity = b === undefined ? "" : (b.label === undefined ? "一人高实体" : b.label);
        this.coverBlocking = b !== undefined && this.coverGuardsFrom(b, a, this.nearestEnemy(a));
    }

    /** 车把是否在有效握持范围内；用来让同拍 E 优先于射击/跳跃。 */
    cartHandleInReach(a: Actor = this.player): boolean {
        const c = this.room.cart;
        if (this.cartDocked || c.bodyW <= 0 || c.endX === c.startX) {
            return false;
        }
        const handleX = this.cartAxle + c.handleOffset;
        const depthOk = this.childMode
            ? Math.abs(a.depth - (c.depth ?? 0)) <= 48
            : inReachDepth(a.depth, c.depth ?? 0);
        return Math.abs(a.x - handleX) <= CART_REACH && Math.abs(a.y - c.baseY) <= 40
            && depthOk;
    }

    /** 面前是否有一人高的台面：是则空格改成翻上去，平地仍是翻滚。 */
    private nearLowLedge(a: Actor): boolean {
        const reach = 26;
        const x0 = a.facing > 0 ? a.x + a.w / 2 : a.x - a.w / 2 - reach;
        const x1 = x0 + reach;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.x1 <= x0 || b.x0 >= x1 || !overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF)) {
                continue;
            }
            const rise = b.y1 - a.y;
            if (rise > 0 && rise <= LEDGE_RISE) {
                return true;
            }
        }
        return false;
    }

    private stepPlayer(a: Actor, dt: number, input: Input): void {
        a.depthSpeed = 0;
        if (!a.alive) {
            return;
        }
        const isChild = this.childMode;
        // 低拱下（村口桌下、城外矮洞）站高会穿顶：松开蹲键也保持蹲，走出拱再恢复。
        const lowArch = isChild && this.underLowArch(a);
        // 演出段（递物、关门、数数、片尾）由剧情持有控制，先落体。
        if (this.storyLocked()) {
            a.vx = 0;
            a.crouch = isChild && lowArch;
            a.h = a.crouch ? CHILD_CROUCH_H : (isChild ? CHILD_H : SOLDIER_H);
            this.fallY(a, dt);
            return;
        }
        // 安抚的 60 拍里周戍蹲着不动，交火与移动都停。
        if (!isChild && this.escort.state === "calming") {
            a.crouch = false;
            a.h = SOLDIER_H;
            a.vx = 0;
            this.fallY(a, dt);
            return;
        }
        const downCrouch = this.room.depth === undefined && input.moveY > 0;
        a.crouch = isChild && (input.crouch.held || downCrouch || lowArch) && a.onGround;
        a.h = a.crouch ? CHILD_CROUCH_H : (isChild ? CHILD_H : SOLDIER_H);
        const nearCover = !isChild && this.nearCover(a);
        a.covered = nearCover && input.cover.held;
        // 同一拍先按 E 且车把在范围里：这只 E 归握车，不能先射击/起跳/翻滚。
        const gripIntent = !this.gripping && input.interact.pressed && this.cartHandleInReach(a);

        // 翻滚：周戍按下空格，0.35 秒内按固定速度冲出去，期间不能改向（「疾步」提升翻滚速度）
        if (a.rollT > 0) {
            a.rollT -= dt;
            const rollSpd = this.isEscortRoom() ? ROLL_SPEED * (1 + 0.08 * this.talentRank("stride")) : ROLL_SPEED;
            a.vx = a.facing * rollSpd;
            this.slideX(a, a.vx * dt);
            this.fallY(a, dt);
            if (a.rollT <= 0) {
                this.flashSet("翻滚结束", 0.5);
            }
            return;
        }

        const peacefulRoom = this.room.key === "museum" || this.room.key === "tower";
        if (!isChild && !peacefulRoom && !this.gripping && !gripIntent && input.jump.pressed && a.onGround) {
            if (input.moveX !== 0) {
                a.facing = input.moveX > 0 ? 1 : -1;
            }
            // 贴着一人高的柜台/台阶时改成跳上去；平地上仍是翻滚。
            if (this.nearLowLedge(a)) {
                a.vy = SOLDIER_JUMP;
                a.onGround = false;
                this.flashSet("翻上去", 0.3);
                return;
            }
            a.rollT = ROLL_TIME;
            this.flashSet("翻滚", 0.3);
            return;
        }

        let speed = isChild ? CHILD_SPEED : SOLDIER_SPEED;
        if (isChild) {
            if (input.cover.held) {
                speed = CHILD_SLOW;
            }
            if (a.crouch) {
                speed = CHILD_SLOW;
            } else if (this.room.key === "forest" && this.forestPath === "ditch"
                && a.x >= this.ox + 700 && a.x <= this.ox + 1140) {
                // 旧渠路线差异化：顺着干渠底站跑提速 22%，换取更高警戒风险
                speed = CHILD_SPEED * 1.22;
            }
        } else {
            if (this.isEscortRoom()) {
                speed *= 1 + 0.10 * this.talentRank("stride");
            }
            if (a.covered) {
                speed *= 0.45;
            }
        }

        // 握车把或打开慢时换弹盘时，方向键归车/换弹盘使用，避免 W/A/S/D 同时带走人物。
        const handsBusy = this.gripping || gripIntent || this.reloadOpen;
        const dir = (this.gripping || this.reloadOpen) ? 0 : input.moveX;
        // 凡定义了 depth 的房间均开放前后纵深四向行走（含小满 3D 单人线四房与序章逃柜）。
        const depthDir = this.room.depth !== undefined && !handsBusy ? -input.moveY : 0;
        const diagonal = dir !== 0 && depthDir !== 0 ? DIAGONAL_SCALE : 1;
        if (dir !== 0) {
            a.facing = dir > 0 ? 1 : -1;
        }
        a.vx = dir * speed * diagonal;

        // 小满跳跃：地面 + 未蹲
        if (isChild && !this.gripping && !gripIntent && input.jump.pressed && a.onGround && !a.crouch) {
            a.vy = CHILD_JUMP;
            a.onGround = false;
            this.flashSet("跳", 0.25);
        }

        // 两个地面方向各自结算碰撞，斜着走时可以贴着实体边缘绕行。
        const previousDepth = a.depth;
        this.slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt);
        a.depthSpeed = dt > 0 ? (a.depth - previousDepth) / dt : 0;
        this.slideX(a, a.vx * dt);
        this.fallY(a, dt);

        // 点射：周戍按住左键，朝准星打一条线；两手握车或在博物馆/北塔静默室内不能开枪。
        if (!isChild && !peacefulRoom && !this.gripping && !gripIntent && !this.reloadOpen && input.fire.pressed) {
            this.shoot(a);
        }
        // 手动起盘换弹（Q 键）：在支持慢时连线换弹的护送段允许随时主动调出 3×3 盘面。
        if (!isChild && !peacefulRoom && !this.gripping && !this.reloadOpen && this.reloadPendingEffect === ""
            && this.room.campaign?.reloadPuzzle === true && input.flare.pressed) {
            this.beginReload();
        }
    }

    /** 未操控的一方：站在出生点，跟着镜头外不动。D3 再接跟随与护送。 */
    private stepPartner(p: Actor, dt: number): void {
        const a = this.partner;
        if (!a.alive) {
            return;
        }
        a.crouch = false;
        a.h = a.w === CHILD_W ? CHILD_H : SOLDIER_H;
        a.vx = 0;
        a.depthSpeed = 0;
        this.fallY(a, dt);
    }

    /**
     * 小满的跟随与护送：目标点由 Escort 出，位移走统一的 slideX / fallY。
     * 检查站之外的房间没有护送数据，保持原地落体。
     */
    private stepEscort(dt: number, input: Input): void {
        const a = this.partner;
        a.depthSpeed = 0;
        if (!a.alive) {
            return;
        }
        if (this.room.key === "gatepath") {
            // 背起来之后只由 carryPose 更新背侧位置，不再走牵手位。
            if (this.carryOn) {
                return;
            }
            // 同行段：全程牵着手，她贴着周戍的侧手位同起同落，不会掉队。
            const p = this.player;
            a.depth = p.depth;
            a.facing = p.facing;
            a.crouch = false;
            a.h = CHILD_H;
            a.x = p.x - p.facing * (CHILD_W / 2 + 8);
            a.y = p.y;
            a.vy = 0;
            a.vx = p.vx;
            a.onGround = p.onGround;
            return;
        }
        if (!this.escortOn()) {
            a.vx = 0;
            this.fallY(a, dt);
            return;
        }
        const p = this.player;
        const dist = inReachDepth(p.depth, a.depth) ? Math.abs(p.x - a.x) : 1e9;
        const hadKnock1 = this.escort.knock1;
        const hadKnock2 = this.escort.knock2;
        this.calmConsumed = this.escort.update(input, p.x, p.facing, a.x, dist);
        // 安抚的第 12 / 36 拍是两次接触，各自只发一条 knock，供前端播手指与音效。
        if (!hadKnock1 && this.escort.knock1) {
            this.emit("knock", { count: 1, x: a.x, room: this.room.key });
        }
        if (!hadKnock2 && this.escort.knock2) {
            this.emit("knock", { count: 2, x: a.x, room: this.room.key });
        }
        a.crouch = this.escort.crouchPose;
        a.h = a.crouch ? CHILD_CROUCH_H : CHILD_H;
        if (!this.escort.stopped) {
            const targetDepth = this.escort.state === "follow" ? p.depth : 0;
            const previousDepth = a.depth;
            const travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt;
            const distance = Math.max(-travel, Math.min(travel, targetDepth - previousDepth));
            this.slideDepth(a, distance);
            a.depthSpeed = dt > 0 ? (a.depth - previousDepth) / dt : 0;
            if (Math.abs(distance) > 0.5 && a.depth === previousDepth && a.onGround) {
                a.vy = CHILD_JUMP;
                a.onGround = false;
            }
        }
        const dir = this.escort.moveDir(a.x);
        a.vx = dir * CHILD_SPEED;
        if (dir !== 0) {
            a.facing = dir;
            const before = a.x;
            this.slideX(a, dir * CHILD_SPEED * dt);
            // 跟随时撞到矮台（柜台、台阶）：自己跳上去，不卡在台前。
            if (a.onGround && Math.abs(a.x - before) < 0.4) {
                a.vy = CHILD_JUMP;
                a.onGround = false;
            }
        }
        this.fallY(a, dt);
    }

    /** 这些房间的小满由护送逻辑驱动；序章要等递完东西才开始跟。 */
    private escortOn(): boolean {
        if (this.room.key === "checkpoint") {
            return true;
        }
        if (this.room.key === "gatepath") {
            return true;
        }
        if (this.room.key === "prologue") {
            return this.phase === "prologue-follow";
        }
        if (this.room.key === "escort1" || this.room.key === "escort2" || this.room.key === "escort3"
            || this.room.key === "escort4" || this.room.key === "escort5") {
            return true;
        }
        return this.room.key === "street";
    }

    /** 演出持有控制权：递物、关门数数、片尾。 */
    private storyLocked(): boolean {
        if (this.caughtT > 0) {
            return true;
        }
        if (this.room.key === "prologue"
            && (this.phase === "prologue-wake" || this.phase === "prologue-shadow" || this.phase === "prologue-hide")) {
            return true;
        }
        if (this.room.key === "prologue" && this.phase === "prologue-give") {
            return true;
        }
        if (this.room.key === "gate" && (this.phase === "gate-farewell" || this.phase === "gate-count" || this.phase === "gate-wait" || this.phase === "gate-hand")) {
            return true;
        }
        if (this.room.key === "tower" && (this.phase === "tower-knock" || this.phase === "tower-given")) {
            return true;
        }
        if (this.room.key === "museum" && this.phase === "museum-knock") {
            return true;
        }
        // 工台面板打开时玩家站着选配方，世界不再推进（面板自己按 ui 拍走）。
        if (this.craftBench.active) {
            return true;
        }
        return false;
    }

    /** 城门送别：把控制权交给门外的小满，周戍留在门内。 */
    private swapToChild(x: number): void {
        const tmp = this.player;
        this.player = this.partner;
        this.partner = tmp;
        this.childMode = true;
        this.player.alive = true;
        this.player.x = this.ox + x;
        this.player.y = 0;
        this.player.depth = 0;
        this.player.depthSpeed = 0;
        this.player.vy = 0;
        this.player.vx = 0;
        this.player.onGround = true;
        this.player.crouch = false;
        this.player.h = CHILD_H;
        this.player.facing = 1;
        this.partner.alive = true;
        this.cam.x = this.player.x;
    }

    /** 序章逃柜收尾：把控制权交回周戍，小满留在倒柜边（蹲着等他递针套）。 */
    private swapToSoldier(x: number, childX: number): void {
        const tmp = this.player;
        this.player = this.partner;
        this.partner = tmp;
        this.childMode = false;
        this.player.alive = true;
        this.player.x = this.ox + x;
        this.player.y = 0;
        this.player.depth = 0;
        this.player.depthSpeed = 0;
        this.player.vy = 0;
        this.player.vx = 0;
        this.player.onGround = true;
        this.player.crouch = false;
        this.player.h = SOLDIER_H;
        this.player.facing = 1;
        this.partner.alive = true;
        this.partner.x = this.ox + childX;
        this.partner.y = 0;
        this.partner.depth = 0;
        this.partner.depthSpeed = 0;
        this.partner.vx = 0;
        this.partner.vy = 0;
        this.partner.onGround = true;
        this.partner.crouch = true;
        this.partner.h = CHILD_CROUCH_H;
        this.cam.x = this.player.x;
    }

    /** 剧情段分派。 */
    private stepStory(dt: number, input: Input): void {
        if (this.room.key === "prologue") {
            this.stepPrologue(dt, input);
        } else if (this.room.key === "street") {
            this.stepStreet(dt, input);
        } else if (this.room.key === "gate") {
            this.stepGate(dt, input);
        } else if (this.room.key === "gatepath") {
            this.stepGatePath();
        } else if (this.room.key === "tower") {
            this.stepTower(dt, input);
        } else if (this.room.key === "museum") {
            this.stepMuseum(dt, input);
        }
    }

    /** 序章：走近递针套，60 拍后她开始跟随，两人一起出门。 */
    /** 只有正式来源（标题「新的旅程」）才写跨局档案；章节直达/调试/试炼只预览。 */
    canPersistProgress(): boolean {
        return !this.isCampaign && this.run.source === "official";
    }

    /** 井口开放条件：正式局、两种结局都走过，且还没取到穿梭器。 */
    wellWindow(): boolean {
        return this.canPersistProgress()
            && !this.archive.artifactOwned && this.archive.childCleared && this.archive.soldierCleared;
    }

    /** 玩家是否站在井沿旁（段内 x=430，前后 44）。 */
    private nearWell(): boolean {
        return Math.abs(this.player.x - (this.ox + this.wellX)) <= 44
            && this.player.y < 20 && inReachDepth(this.player.depth, 0);
    }

    /**
     * 井口主动交互：只在等待段、双通关、未取过、站在井沿时成立。
     * 返回 true 表示进入拾取演出；重复调用与窗口前后一律拒绝，不重复发。
     */
    pickWell(): boolean {
        if (!this.wellWindow() || this.wellTaken || this.phase !== "prologue-wait" || !this.nearWell()) {
            return false;
        }
        this.phase = "prologue-well";
        this.phaseTick = 0;
        this.wellOpen = false;
        this.flashSet("井沿 · 伸手下去", 1.4);
        this.log("旧井拾取");
        return true;
    }

    private stepPrologue(dt: number, input: Input): void {
        const child = this.partner;
        if (this.museumReturn) {
            // 从馆里回柜边：站回井沿，仍要递针套、仍要跟到门口。
            this.museumReturn = false;
            this.phase = "prologue-wait";
            this.phaseTick = 0;
            this.player.x = this.ox + 260;
            this.player.y = 0;
            this.player.depth = 0;
            this.flashSet("回到柜边 · 小满还在柜后", 1.6);
        }
        // P01 叫醒：黑场听父亲唤「小满」，睁眼后门缝里的影子压过来。演出期间锁控。
        if (this.phase === "prologue-wake") {
            this.introTick += 1;
            if (this.introTick === 60) {
                this.flashSet("门外有人唤 · 小满", 1.2);
            }
            if (this.introTick >= PROLOGUE_WAKE_TICKS) {
                this.phase = "prologue-shadow";
                this.introTick = 0;
                this.flashSet("门缝里两道影子", 1.2);
                this.emit("prologueBeat", { beat: "wake", ticks: PROLOGUE_WAKE_TICKS });
            }
            return;
        }
        if (this.phase === "prologue-shadow") {
            this.introTick += 1;
            if (this.introTick >= PROLOGUE_SHADOW_TICKS) {
                // 瓷碗滚到脚边，同拍起表限时逃柜：控制权交给门口的小满。
                this.phase = "prologue-escape";
                this.introTick = 0;
                this.escapeRemaining = this.escapeDuration;
                this.escapeRetryCount = 0;
                this.swapToChild(100);
                this.flashSet("逃进倒柜 · 限时 " + this.escapeDuration.toFixed(1) + " 秒", 1.6);
                this.emit("prologueBeat", {
                    beat: "escape", ticks: PROLOGUE_SHADOW_TICKS, duration: this.escapeDuration,
                });
            }
            return;
        }
        if (this.phase === "prologue-escape") {
            this.escapeRemaining = Math.max(0, this.escapeRemaining - STEP);
            if (this.player.x >= this.ox + PROLOGUE_CABINET_X) {
                // 贴到柜边：拉门入柜，红晕收尽，柜外脚步渐远。
                this.phase = "prologue-hide";
                this.introTick = 0;
                this.player.vx = 0;
                this.player.crouch = true;
                this.player.h = CHILD_CROUCH_H;
                this.flashSet("柜门合上 · 屏住呼吸", 1.4);
                this.emit("prologueBeat", {
                    beat: "hide", x: this.player.x,
                    delay: this.escapeDuration - this.escapeRemaining,
                });
                return;
            }
            if (this.escapeRemaining <= 0) {
                // 超时退回门口重来：不扣血、不写档案。
                this.escapeRetryCount += 1;
                this.player.x = this.ox + 100;
                this.player.y = 0;
                this.player.depth = 0;
                this.player.vx = 0;
                this.player.vy = 0;
                this.escapeRemaining = this.escapeDuration;
                this.flashSet("再快一点 · 退回门口", 1.4);
                this.emit("prologueBeat", { beat: "escapeRetry", attempt: this.escapeRetryCount });
                return;
            }
            return;
        }
        if (this.phase === "prologue-hide") {
            this.introTick += 1;
            if (this.introTick >= PROLOGUE_HIDE_TICKS) {
                // 柜内留半拍静默，切回周戍视角：他蹲到柜边递针套。
                this.phase = "prologue-wait";
                this.phaseTick = 0;
                this.introTick = 0;
                this.swapToSoldier(260, 300);
                this.flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6);
                this.emit("prologueBeat", { beat: "wait", ticks: PROLOGUE_HIDE_TICKS });
            }
            return;
        }
        // 井口只在「进屋寻小满、尚未靠柜特写」的等待段可见；拿到穿梭器就消失。
        this.wellOpen = this.phase === "prologue-wait" && this.wellWindow() && !this.wellTaken;
        if (this.phase === "prologue-wait") {
            child.crouch = true;
            child.h = CHILD_CROUCH_H;
            if (this.wellOpen && input.interact.pressed && this.nearWell()) {
                this.pickWell();
                return;
            }
            // 拿到穿梭器后，仅正式进度在井沿再按一次进馆；章节/调试预览不泄漏进馆。
            if (!this.wellOpen && this.canPersistProgress() && this.archive.artifactOwned && !this.archive.museumSeen
                && this.nearWell() && input.interact.pressed) {
                this.archive.museumPhase = "well_reflect";
                this.archiveDirty = true;
                this.requestRoom("museum", "初次使用 · 时间穿梭器");
                return;
            }
            const reach = this.room.story === undefined || this.room.story.prologue === undefined
                ? 46 : this.room.story.prologue.giveReach;
            const near = Math.abs(this.player.x - child.x) <= reach && inReachDepth(this.player.depth, child.depth);
            if (near && input.interact.pressed) {
                this.phase = "prologue-give";
                this.phaseTick = 0;
                this.flashSet("递出针套", 1.0);
            }
            return;
        }
        if (this.phase === "prologue-well") {
            // 沿侧灶、后院走到旧井，伸手取「时间穿梭器」：只发一次、立刻记进档案。
            this.phaseTick += 1;
            if (this.phaseTick === 12) {
                this.flashSet("井底有光 · 一截铁柄", 1.2);
            } else if (this.phaseTick >= 30) {
                this.phase = "prologue-wait";
                this.phaseTick = 0;
                this.wellTaken = true;
                this.wellOpen = false;
                this.run.archive.artifactOwned = true;
                this.archiveDirty = true;
                this.emit("artifactFound", {
                    x: this.ox + this.wellX, y: 0, room: "prologue", once: true,
                    source: this.run.source,
                });
                this.flashSet("时间穿梭器 · 收进袖口", 2.0);
                this.log("井底取到时间穿梭器");
            }
            return;
        }
        if (this.phase === "prologue-give") {
            this.phaseTick += 1;
            if (this.phaseTick === 36) {
                this.flashSet("针套递过去", 0.9);
            } else if (this.phaseTick === 108) {
                this.flashSet("纸条塞进针套", 1.0);
            } else if (this.phaseTick >= PROLOGUE_GIVE_TICKS) {
                this.phase = "prologue-follow";
                this.phaseTick = 0;
                child.crouch = false;
                child.h = CHILD_H;
                this.flashSet("她跟上了", 1.2);
            }
            return;
        }
        // 跟随段：两人一起到门口（正式/选章直入 S1 十字街，消除双重街道；调试模式保留 street 兼容旧单房验证）。
        if (this.player.x >= this.ox + 660 && child.x >= this.ox + 620) {
            const next = this.run.source === "debug" ? "street" : "s1-crossroad";
            this.requestRoom(next, "序章跟到门口");
            this.flashSet(next === "s1-crossroad" ? "进十字街" : "进街道", 1.2);
        }
    }

    /** 街道：清完两个敌兵后两人走到街尾出口（正式/选章进 S1 十字街，调试单房保留回退 checkpoint）。 */
    private stepStreet(dt: number, input: Input): void {
        const p = this.player;
        const c = this.partner;
        if (p.x >= this.ox + 900 && c.x >= this.ox + 860) {
            const next = this.run.source === "debug" ? "checkpoint" : "s1-crossroad";
            this.requestRoom(next, "两人都到街尾");
            this.flashSet(next === "s1-crossroad" ? "进十字街" : "到检查站", 1.2);
        }
    }

    /** 城门：两人就位 → 45 秒守点 → 门边按 E 送别 → 关门数到二十 → 新按 D 迈步。 */
    private stepGate(dt: number, input: Input): void {
        const g = this.room.story === undefined ? undefined : this.room.story.gate;
        if (g === undefined) {
            return;
        }
        const p = this.player;
        if (this.phase === "gate-idle") {
            // 这一段小满自己走向门洞等待点，就位后站住；周戍自由回绞盘。
            const a = this.partner;
            const gap = g.waitX - a.x;
            if (Math.abs(gap) > 3) {
                a.facing = gap > 0 ? 1 : -1;
                a.vx = a.facing * CHILD_SPEED;
                const beforeX = a.x;
                this.slideX(a, a.facing * CHILD_SPEED * dt);
                if (Math.abs(a.x - beforeX) < 0.4 && a.onGround) {
                    a.vy = CHILD_JUMP;
                    a.onGround = false;
                }
                this.fallY(a, dt);
            } else {
                a.vx = 0;
                a.x = g.waitX;
            }
            // 要真的碰到绞盘才算就位：±24 是身体边缘贴住的距离。
            const atWinch = Math.abs(p.x - g.winchX) <= 24 && p.y < 20 && inReachDepth(p.depth);
            const atWait = this.partner.alive && Math.abs(this.partner.x - g.waitX) <= 60;
            if (this.gateNeedConfirm) {
                // 倒地之后不自动重开：站位到位也要玩家按一次 E，确认「我知道要重来」。
                // 倒地当拍烧掉的那次 E 不算新按：必须先看到松开，下一次按下才生效。
                if (!input.interact.held) {
                    this.gateRestartArmed = true;
                }
                if (this.gateRestartArmed && atWinch && atWait && input.interact.pressed) {
                    this.gateNeedConfirm = false;
                    this.gateRestartArmed = true;
                    this.phase = "gate-hold";
                    this.gateTick = 0;
                    this.gateSpawned = 0;
                    this.flashSet("重新就位 · 守点开始", 1.4);
                    this.emit("gateRestart", { failCount: this.gateFailCount });
                }
                return;
            }
            if (atWinch && atWait) {
                this.phase = "gate-hold";
                this.gateTick = 0;
                this.gateSpawned = 0;
                this.flashSet("两人就位 · 守点开始", 1.4);
            }
            return;
        }
        if (this.phase === "gate-hold") {
            this.gateTick += 1;
            // 四批敌兵：第 0 / 9 / 15 / 25 秒；出场 ID 各自独立，只登一次。
            const marks = [0, 540, 900, 1500];
            while (this.gateSpawned < marks.length && this.gateTick - 1 >= marks[this.gateSpawned]) {
                const idx = this.gateSpawned;
                this.enemies.push({
                    x: this.ox + 620 + idx * 62, y: 0, w: 26, h: 84,
                    alive: true, hitT: 0, warnT: 0, fireCd: 90 + idx * 45,
                });
                this.gateSpawned += 1;
                this.flashSet("敌兵出现 · 第 " + (idx + 1) + " 批", 0.9);
            }
            if (this.gateTick === 900) {
                this.flashSet("棚布落下", 1.0);
            } else if (this.gateTick === 2100) {
                this.flashSet("门底透进冷光了", 1.0);
            }
            if (this.gateTick >= g.holdTicks) {
                // 殿后最后一拍的伤害已由 stepEnemies 结算完，此刻只取血。
                // 路线要等她真正过门（门洞送别确认）才锁，演出中途不提交结局。
                this.captureGateBlood();
                this.phase = "gate-send";
                this.phaseTick = 0;
                // 撤预警：敌兵冻结，让玩家走到门边。
                this.enemies = [];
                this.flashSet("守满了 · 到门边按 E 送她", 2.0);
            }
            return;
        }
        if (this.phase === "gate-send") {
            const near = Math.abs(p.x - g.doorX) <= 60 && inReachDepth(p.depth);
            if (near && input.interact.pressed) {
                // 送别确认 = 小满安全过门：此刻才提交路线，且只提交一次；
                // 正式与选章先演独立 P05 送别再入 24s 数到二十（零叠字叠音），debug 单房回归保持直入 gate-count。
                this.commitRoute();
                this.swapToChild(g.doorX + 30);
                this.phase = this.run.source === "debug" ? "gate-count" : "gate-farewell";
                this.phaseTick = 0;
                this.countTick = 0;
                // 送别时已经按着 D 的不算「新按」，必须先松开。
                this.countArmed = false;
                this.countPrevMove = input.moveX;
                this.flashSet("门开了 · 送她出去", 1.8);
            }
            return;
        }
        if (this.phase === "gate-farewell") {
            this.phaseTick += 1;
            this.countPrevMove = input.moveX;
            if (this.phaseTick >= GATE_FAREWELL_TICKS) {
                this.phase = "gate-count";
                this.phaseTick = 0;
                this.countTick = 0;
                this.countArmed = false;
            }
            return;
        }
        if (this.phase === "gate-count") {
            this.countTick += 1;
            if (this.countTick === 360) {
                this.flashSet("门关上", 0.9);
            } else if (this.countTick === GATE_COUNT_END) {
                this.emit("gateCountDone", {
                    route: this.storyRoute, countTick: this.countTick,
                    hpAtGate: this.hpAtGate, maxHpAtGate: this.maxHpAtGate,
                });
                if (this.storyRoute === "soldier") {
                    // 男主线：数完听见侧墙两下轻叩，风台待机一直安全。
                    this.phase = "gate-wait";
                    this.phaseTick = 0;
                    this.knocks = 1;
                    this.emit("knock", { count: 1, x: this.ox + g.doorX + 70, room: "gate" });
                    // 数完还按着 E 或前端长按意图的不算「重新按住」，必须先松开再按。
                    this.handArmed = !input.interact.held && !this.intentGateReunionHold;
                    this.flashSet("两下轻叩 · 按住 E 牵起她", 2.4);
                } else {
                    this.flashSet("数到二十", 2.2);
                }
            }
            // 24 秒之后才认「新按下」：上一拍没按、这一拍按下。
            // 1439 拍就按住不放的，没有上升沿，必须松开再按。
            const prevMove = this.countPrevMove;
            this.countPrevMove = input.moveX;
            if (this.countTick >= GATE_COUNT_END && this.storyRoute !== "soldier") {
                if (prevMove <= 0 && input.moveX > 0) {
                    this.countArmed = true;
                }
                if (this.countArmed && input.moveX > 0) {
                    this.phase = "gate-walk";
                    this.phaseTick = 0;
                    this.flashSet("她迈出第一步", 1.4);
                    this.emit("storyExit", { route: "child", via: "walk", countTick: this.countTick, hp: this.hp, maxHp: this.maxHp });
                }
            }
            return;
        }
        if (this.phase === "gate-wait") {
            // 风台待机：没有敌兵、不再扣血，玩家可以想按多久就按多久。
            this.phaseTick += 1;
            if (this.phaseTick === 12) {
                this.knocks = 2;
                this.emit("knock", { count: 2, x: this.ox + g.doorX + 70, room: "gate" });
                this.flashSet("第二下 · 她抬手了", 1.6);
            }
            const held = input.interact.held || this.intentGateReunionHold;
            if (!held) {
                if (this.handTicks > 0) {
                    this.emit("handRelease", { handTicks: this.handTicks, handNeedTicks: GATE_HAND_TICKS });
                }
                this.handTicks = 0;
                this.handArmed = true;
                return;
            }
            if (this.handArmed) {
                this.handTicks += 1;
                if (this.handTicks >= GATE_HAND_TICKS) {
                    this.intentGateReunionHold = false;
                    this.phase = "gate-hand";
                    this.phaseTick = 0;
                    this.handDone = true;
                    this.tied = true;
                    this.emit("handHeld", { handTicks: this.handTicks, handNeedTicks: GATE_HAND_TICKS });
                    if (!this.lineSaid) {
                        this.lineSaid = true;
                        this.emit("storyLine", { who: "周戍", text: "我们走吧。" });
                    }
                    this.flashSet("我们走吧。", 3.0);
                }
            }
            return;
        }
        if (this.phase === "gate-hand") {
            // 牵手演出：袖口先入画，她抓住；演出结束后交回移动，进同行段。
            this.phaseTick += 1;
            if (this.phaseTick === 30) {
                this.flashSet("袖口先入画 · 她抓住了", 1.8);
            } else if (this.phaseTick >= 90 && this.wantRoom === "") {
                this.emit("storyExit", { route: "soldier", via: "hand", handTicks: this.handTicks, hp: this.hp, maxHp: this.maxHp });
                this.requestRoom("gatepath", "牵手同行");
            }
            return;
        }
        // gate-walk：她自己走，玩家可以控。
        if (this.phase === "gate-walk") {
            if (this.player.x >= g.exitX) {
                this.requestRoom("outside", "走出城门");
                this.flashSet("出城门 · 城外", 1.4);
            }
        }
    }

    /**
     * 守点末拍取血：只记下最后一拍伤害结算后的血量与上限。
     * 这里不判定路线，也不发锁线事件——小满还没过门。
     */
    private captureGateBlood(): void {
        this.hpAtGate = this.hp;
        this.maxHpAtGate = this.maxHp;
    }

    /**
     * 门洞送别确认后锁存路线：只做一次。
     * 重试与续读都从快照恢复，不再按新房满血或有损血量重算。
     */
    private commitRoute(): void {
        if (this.storySettled) {
            return;
        }
        const maxHp = this.maxHpAtGate > 0 ? this.maxHpAtGate : (this.maxHp > 0 ? this.maxHp : 1);
        const hp = this.hpAtGate >= 0 ? this.hpAtGate : this.hp;
        this.hpAtGate = hp;
        this.maxHpAtGate = this.maxHpAtGate > 0 ? this.maxHpAtGate : this.maxHp;
        this.storyRoute = 100 * hp >= GATE_ROUTE_PERCENT * maxHp ? "soldier" : "child";
        this.storySettled = true;
        this.sessionDirty = true;
        this.emit("storyRouteLocked", {
            route: this.storyRoute, hp: this.hp, maxHp: this.maxHp,
            hpAtGate: this.hpAtGate, maxHpAtGate: this.maxHpAtGate,
        });
        this.flashSet(this.storyRoute === "soldier" ? "她还够得着你 · 牵手" : "她替你数完 · 出门", 2.4);
    }

    /** 把本房的血量与演出拍写回跨房快照；R 重试与切房续读都靠它。 */
    private syncStory(): void {
        const s = this.run.story;
        if (s === undefined) {
            return;
        }
        s.hp = this.hp;
        s.maxHp = this.maxHp;
        s.route = this.storyRoute;
        s.settled = this.storySettled;
        s.hpAtGate = this.hpAtGate;
        s.maxHpAtGate = this.maxHpAtGate;
        s.handDone = this.handDone;
        s.lineSaid = this.lineSaid;
        s.tied = this.tied;
        s.carry = this.carryOn;
        s.museumReturn = this.museumReturn;
        s.escortDone = this.escortDone;
        s.craftedWeapon = this.run.story.craftedWeapon;
        s.equippedWeapon = this.equippedWeapon;
        s.ending = this.run.story.ending;
        if (this.room.key === "gate") {
            s.phase = this.phase;
            s.countTick = this.countTick;
            s.phaseTick = this.phaseTick;
            s.handTicks = this.handTicks;
        }
        if (this.room.key === "prologue") {
            // 序章只记可续读的段（递针套/跟随）；P01/P02 每次重开都重播。
            if (this.phase === "prologue-wait" || this.phase === "prologue-give" || this.phase === "prologue-follow") {
                s.phase = this.phase;
                s.phaseTick = this.phaseTick;
            }
        }
        if (this.room.key === "tower") {
            // 北塔：门廊/值夜室的中途阶段可续读；片尾不写，避免重进直接跳结局。
            if (this.phase === "tower-enter" || this.phase === "tower-desk" || this.phase === "tower-given") {
                s.phase = this.phase;
                s.phaseTick = this.phaseTick;
            }
        }
    }

    /** 同行段：牵手走到高石阶，蹲下把她背起来，再走进第一间护送房。 */
    private stepGatePath(): void {
        const gp = this.room.story === undefined ? undefined : this.room.story.gatepath;
        if (this.phase === "gatepath-start") {
            if (gp !== undefined && this.player.onGround && this.player.x >= gp.carryX && !this.carryOn) {
                this.carryOn = true;
                this.phase = "gatepath-carry";
                this.phaseTick = 0;
                this.pathDone = true;
                this.escortDone = false;
                this.emit("gatePathEnd", { x: this.player.x, tied: this.tied, ticks: this.ticks });
                this.emit("carryStart", { x: this.player.x, tied: this.tied, route: this.storyRoute, ticks: this.ticks });
                this.flashSet("蹲下 · 背起小满", 2.6);
            }
            return;
        }
        if (this.phase === "gatepath-carry") {
            this.phaseTick += 1;
            if (this.phaseTick === 20) {
                this.flashSet("她已经趴稳 · 走慢一点", 2.0);
            }
            if (gp !== undefined && this.player.x >= gp.exitX && this.player.onGround) {
                this.requestRoom(gp.next, "背负进首战");
                this.flashSet("背上她 · 巷口有脚步", 2.0);
            }
        }
    }

    /**
     * 背负姿态：只有周戍有位移与受击碰撞；小满贴着背，只更新背侧位置与朝向。
     * 转身时她换到另一侧肩上，不额外生成一套碰撞。
     */
    private carryPose(): void {
        const p = this.player;
        const a = this.partner;
        a.alive = true;
        a.x = p.x - p.facing * 12;
        a.y = p.y + 26;
        a.depth = p.depth;
        a.vx = p.vx;
        a.vy = 0;
        a.onGround = true;
        a.crouch = false;
        a.h = CHILD_CROUCH_H;
        a.facing = p.facing;
    }

    /** 塔门与尾声：按一次 E 敲两下，递针套，看空行，片尾再玩。 */
    /**
     * C2 博物馆：柜前收枪 → 走廊听见脚步 → 末厅转灯 → 回柜边两下轻叩。
     * 每步只吃一次交互边沿；进度写进档案，重启从同一步续读。
     */
    private stepMuseum(dt: number, input: Input): void {
        this.partner.alive = false;
        const mu = this.room.story === undefined || this.room.story.museum === undefined
            ? { cabinetX: 200, hallX: 900, lampX: 1250, exitX: 1360 }
            : this.room.story.museum;
        const atCase = this.player.x <= this.ox + mu.cabinetX + 60;
        const nearLamp = this.player.x >= this.ox + mu.lampX - 72;
        const intentTarget = this.pendingMuseumIntentTarget;
        this.pendingMuseumIntentTarget = "";
        const interactHit = input.interact.pressed || intentTarget !== "";
        if (this.phase === "museum-cabinet") {
            if ((atCase && interactHit) || intentTarget === "cabinet") {
                this.phase = "museum-hall";
                this.phaseTick = 0;
                if (this.canPersistProgress()) {
                    this.archive.museumPhase = "hall_walk";
                    this.archiveDirty = true;
                }
                this.emit("museumStep", { step: "cabinet", x: this.ox + mu.cabinetX, persisted: this.canPersistProgress() });
                this.flashSet("玻璃柜前 · 收枪入袖", 1.8);
            }
            return;
        }
        if (this.phase === "museum-hall") {
            if (intentTarget === "lamp_direct" && nearLamp) {
                this.emit("museumStep", { step: "hall", x: this.ox + mu.hallX, persisted: this.canPersistProgress() });
                this.phase = "museum-return";
                this.phaseTick = 0;
                if (this.canPersistProgress()) {
                    this.archive.museumPhase = "return_cabinet";
                    this.archiveDirty = true;
                }
                this.emit("museumStep", { step: "lamp", x: this.ox + mu.lampX, persisted: this.canPersistProgress() });
                this.flashSet("灯 · 转向西窗", 1.8);
                return;
            }
            if (this.player.x >= this.ox + mu.hallX && interactHit) {
                this.phase = "museum-lamp";
                this.phaseTick = 0;
                if (this.canPersistProgress()) {
                    this.archive.museumPhase = "lamp_turn";
                    this.archiveDirty = true;
                }
                this.emit("museumStep", { step: "hall", x: this.ox + mu.hallX, persisted: this.canPersistProgress() });
                this.flashSet("孩子的脚步 · 从西窗那头", 1.8);
            }
            return;
        }
        if (this.phase === "museum-lamp") {
            if (nearLamp && interactHit) {
                this.phase = "museum-return";
                this.phaseTick = 0;
                if (this.canPersistProgress()) {
                    this.archive.museumPhase = "return_cabinet";
                    this.archiveDirty = true;
                }
                this.emit("museumStep", { step: "lamp", x: this.ox + mu.lampX, persisted: this.canPersistProgress() });
                this.flashSet("灯 · 转向西窗", 1.8);
            }
            return;
        }
        if (this.phase === "museum-return") {
            if ((atCase && interactHit) || intentTarget === "return_cabinet") {
                this.phase = "museum-knock";
                this.phaseTick = 0;
                this.emit("museumStep", { step: "knock", count: 1, x: this.ox + mu.cabinetX, persisted: this.canPersistProgress() });
                this.flashSet("回柜边 · 第一下", 0.8);
            }
            return;
        }
        if (this.phase === "museum-knock") {
            this.phaseTick += 1;
            if (this.phaseTick === 8) {
                this.emit("museumStep", { step: "knock", count: 2, x: this.ox + mu.cabinetX, persisted: this.canPersistProgress() });
                this.flashSet("回柜边 · 第二下", 0.8);
            } else if (this.phaseTick >= 36) {
                this.phase = "museum-done";
                this.phaseTick = 0;
                if (this.canPersistProgress()) {
                    this.archive.museumSeen = true;
                    this.archive.museumPhase = "done";
                    this.archiveDirty = true;
                }
                this.emit("museumDone", { steps: 4, museumSeen: this.archive.museumSeen, persisted: this.canPersistProgress() });
                this.flashSet("回柜边 · 灯还亮着", 2.0);
                this.log("博物馆 · 回柜边");
            }
            return;
        }
        if (interactHit) {
            this.museumReturn = true;
            this.requestRoom("prologue", "回柜边");
        }
    }

    private openTowerDoor(): void {
        this.towerDoorOpen = true;
        for (let i = 0; i < this.boxes.length; i++) {
            if (this.boxes[i].id === "tower_door") {
                this.boxes[i].hidden = true;
            }
        }
        this.run.story.segments["tower_door"] = true;
    }

    private stepTower(dt: number, input: Input): void {
        const t = this.room.story === undefined ? undefined : this.room.story.tower;
        if (t === undefined) {
            return;
        }
        // 团圆线：周戍站在小满身侧随行跨过门槛、共立值夜室案前（避免穿入左塔墙 180..400）。
        if (this.storyRoute === "soldier" && this.partner.alive) {
            const targetX = Math.max(this.ox + 408, this.player.x - 28);
            const gap = targetX - this.partner.x;
            if (Math.abs(gap) > 2) {
                const dir = gap > 0 ? 1 : -1;
                const stepDist = Math.min(Math.abs(gap), SOLDIER_SPEED * dt);
                this.partner.facing = dir;
                this.partner.vx = dir * SOLDIER_SPEED;
                this.partner.x += dir * stepDist;
            } else {
                this.partner.vx = 0;
                this.partner.facing = 1;
            }
        }
        if (this.phase === "tower-wait") {
            const near = Math.abs(this.player.x - t.doorX) <= 50;
            if (near && input.interact.pressed) {
                this.phase = "tower-knock";
                this.phaseTick = 0;
                this.knocks = 1;
                this.emit("knock", { count: 1, x: this.player.x, room: "tower" });
                this.flashSet("叩两下 · 第一声", 0.6);
            }
            return;
        }
        if (this.phase === "tower-knock") {
            this.phaseTick += 1;
            if (this.phaseTick === 12) {
                this.knocks = 2;
                this.emit("knock", { count: 2, x: this.player.x, room: "tower" });
                this.flashSet("门里回叩两下 · 守卒应门", 1.2);
            } else if (this.phaseTick >= t.knockTicks) {
                this.openTowerDoor();
                this.phase = "tower-enter";
                this.phaseTick = 0;
                this.emit("storyBeat", { beat: "tower_door", x: this.player.x, item: "" });
                this.flashSet("门开了 · 跨过门槛", 1.4);
            }
            return;
        }
        if (this.phase === "tower-enter") {
            if (this.player.x >= this.ox + TOWER_THRESHOLD_X) {
                this.phase = "tower-desk";
                this.phaseTick = 0;
                this.emit("storyBeat", { beat: "tower_threshold", x: this.player.x, item: "" });
                this.flashSet("跨过门槛 · 值夜室", 1.2);
            }
            return;
        }
        if (this.phase === "tower-desk") {
            const deskX = this.ox + 605;
            const near = Math.abs(this.player.x - deskX) <= 80 && this.player.y < 20;
            if (!near || !input.interact.held) {
                this.deskHold = 0;
                return;
            }
            this.deskHold += 1;
            if (this.deskHold === 12) {
                this.flashSet("针套 · 放在桌上", 1.0);
            } else if (this.deskHold === 24) {
                this.flashSet("指南针 · 压住纸条", 1.0);
            } else if (this.deskHold >= TOWER_HANDOVER_TICKS) {
                this.towerHanded = true;
                this.deskHold = 0;
                this.run.story.segments["tower_handover"] = true;
                this.phase = "tower-given";
                this.phaseTick = 0;
                this.emit("storyBeat", {
                    beat: "tower_handover",
                    x: this.player.x,
                    item: "针套、指南针、纸条",
                });
                this.flashSet("三样都放在桌上 · 看登记簿", 1.6);
            }
            return;
        }
        if (this.phase === "tower-given") {
            // 两条路线共用同一座塔：男主线兄妹同行，登记簿两行姓名；
            // 女主线只有小满一个人，她把西窗的灯留下。
            const soldier = this.storyRoute === "soldier";
            this.phaseTick += 1;
            if (this.phaseTick === 60) {
                this.endingLines = soldier ? ["小满", "周戍"] : ["小满", ""];
                this.flashSet("登记簿 · 第一行 小满", 1.6);
            } else if (this.phaseTick === 120) {
                this.flashSet(soldier ? "第二行 · 周戍 · 兄妹同行" : "第二行留白 · 西窗一盏灯", 2.4);
            } else if (this.phaseTick >= TOWER_REGISTER_TICKS) {
                this.phase = "tower-end";
                this.phaseTick = 0;
                this.towerEndMustRelease = input.interact.held || input.retry.held;
                if (!this.run.finished) {
                    this.run.finished = true;
                    const ending = soldier ? "reunion" : "lamp";
                    this.run.story.ending = ending;
                    // 结局不发神器：井口拾取留给 C 单；已有档案里的真实拾取保持原值。
                    // 只有正式开局、已过门锁线、且本线玩法进度真实走完，才写通关档案。
                    const played = soldier
                        ? this.run.story.segments["escort5"] === true
                        : (this.countTick >= GATE_COUNT_END || this.run.story.countTick >= GATE_COUNT_END);
                    const official = this.run.source === "official"
                        && this.run.story.settled && this.storyRoute !== "" && played;
                    if (official) {
                        if (soldier) {
                            this.run.archive.soldierCleared = true;
                        } else {
                            this.run.archive.childCleared = true;
                        }
                        this.archiveDirty = true;
                    }
                    this.log("结局 " + ending + (official ? " · 正式" : " · 预览"));
                    this.emit("endingReached", {
                        route: soldier ? "soldier" : "child",
                        ending: ending,
                        official: official,
                        source: this.run.source,
                        lines: [this.endingLines[0], this.endingLines[1]],
                        childCleared: this.run.archive.childCleared,
                        soldierCleared: this.run.archive.soldierCleared,
                        artifactOwned: this.run.archive.artifactOwned,
                        equipped: this.equippedWeapon,
                    });
                    this.flashSet(soldier ? "北塔团圆 · 片尾" : "小满留灯 · 片尾", 3.0);
                }
            }
            return;
        }
        this.phaseTick += 1;
        const held = input.interact.held || input.retry.held;
        if (this.towerEndMustRelease) {
            if (!held) {
                this.towerEndMustRelease = false;
            }
            return;
        }
        const waitTicks = Math.max(0, TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS);
        if (this.phaseTick < waitTicks) {
            if (input.interact.pressed || input.retry.pressed) {
                this.towerEndMustRelease = held;
            }
            return;
        }
        if (input.interact.pressed || input.retry.pressed) {
            // 回序章要重开一份局内状态（清路线、材料、拾取、检查点），但档案仍共享同一份。
            this.restartStory = true;
            this.requestRoom("prologue", "片尾再玩");
            this.flashSet("回到序章", 1.4);
        }
    }

    /** 追逐与被抓：村口拾荒者、森林的狗。 */
    private stepChase(dt: number, input: Input): void {
        if (this.caughtT > 0) {
            this.caughtT -= dt;
            if (this.caughtT <= 0) {
                this.recoverFromCaught();
            }
            return;
        }
        if (this.room.key === "village") {
            this.stepScavChase();
        } else if (this.room.key === "forest") {
            this.stepForestRoute();
            this.stepDog(dt);
            // 走到林缘（1450）就进北塔门口。
            if (this.player.x >= this.ox + 1450) {
                this.requestRoom("tower", "到林缘北塔");
                this.flashSet("林缘 · 北塔", 1.4);
            }
        }
    }

    /** 村口：暴露的小满被看见 24 拍后，拾荒者转为追逐。 */
    private stepScavChase(): void {
        const s = this.room.scavenger;
        if (s === undefined) {
            return;
        }
        const p = this.player;
        // 过了第一院通行线 440 就算进了院子，他不再追——这是「钻桌成功」的落点。
        if (this.passed && p.x > this.ox + 440) {
            if (this.scavChase) {
                this.scavChase = false;
                this.scavState = "back";
                this.scavT = 0;
            }
            return;
        }
        const dx = p.x - this.scavX;
        const dist = Math.abs(dx);
        const hidden = p.crouch || (this.room.arch.h > 0 && p.x > this.room.arch.x0 && p.x < this.room.arch.x1);
        const visible = !hidden && dist < 240 && Math.abs(p.y - s.y) < 40;
        if (!this.scavChase) {
            if (visible) {
                this.scavSee += 1;
                if (this.scavSee >= 24) {
                    this.scavChase = true;
                    this.scavState = "chase";
                    this.scavTargetX = p.x;
                    this.flashSet("他看见你了", 1.2);
                }
            } else {
                this.scavSee = 0;
            }
            return;
        }
        // 蹲下或钻桌后立刻安全遮蔽（不可隔桌捕人），60 拍甩掉视线回到巡逻。
        if (hidden) {
            this.scavSee = 0;
            this.scavT = this.scavT > 0 ? this.scavT : 60;
            this.scavT -= 1;
            if (this.scavT <= 0) {
                this.scavChase = false;
                this.scavState = "patrol";
                this.flashSet("他失去了目标", 1.0);
            }
            return;
        }
        // 追逐：以 96 单位/秒靠近，接触即被抓。
        const dir = p.x > this.scavX ? 1 : -1;
        this.scavX += dir * 96 / 60;
        if (Math.abs(p.x - this.scavX) < 18 && Math.abs(p.y - s.y) < 40) {
            this.caught();
            return;
        }
    }

    /** 森林的狗：先转耳朵，再追；树根窄洞与草丛蹲伏提供隐蔽庇护，旧渠奔跑提速但警戒更快。 */
    private stepDog(dt: number): void {
        const dog = this.room.story === undefined ? undefined : this.room.story.dog;
        if (dog === undefined) {
            return;
        }
        const p = this.player;
        const ox = this.ox;
        const dist = Math.abs(p.x - this.dogX);
        const inBurrowCover = p.crouch && p.x >= ox + 300 && p.x <= ox + 460;
        const inBrushCover = p.crouch && (
            (p.x >= ox + 700 && p.x <= ox + 790)
            || (p.x >= ox + 1150 && p.x <= ox + 1240)
        );
        const sheltered = inBurrowCover || inBrushCover;
        const inDitchSprint = !p.crouch && this.forestPath === "ditch" && p.x >= ox + 700 && p.x <= ox + 1140;
        const effectiveRange = inDitchSprint ? dog.range * 1.25 : dog.range;
        const earNeedTicks = inDitchSprint ? 12 : 18;
        if (this.dogState === "patrol") {
            this.dogX += this.dogDir * dog.speed * dt;
            if (this.dogX < dog.x0) {
                this.dogX = dog.x0;
                this.dogDir = 1;
            } else if (this.dogX > dog.x1) {
                this.dogX = dog.x1;
                this.dogDir = -1;
            }
            const moving = Math.abs(p.vx) > 1 || !p.onGround;
            const twigOffsets = [235, 455, 865, 1115];
            let nearTwig = false;
            let ti = 0;
            for (ti = 0; ti < twigOffsets.length; ti++) {
                if (Math.abs(p.x - (ox + twigOffsets[ti])) <= 18 && p.y <= 8) {
                    nearTwig = true;
                    break;
                }
            }
            const twigRange = nearTwig ? Math.max(effectiveRange, 400) : effectiveRange;
            if (!sheltered && !p.crouch && moving && dist < twigRange) {
                this.dogState = "ear";
                this.dogT = nearTwig ? Math.min(earNeedTicks, 12) : earNeedTicks;
                this.dogTargetX = p.x;
                this.flashSet(inDitchSprint ? "旧渠枯枝响 · 狗立刻转耳" : (nearTwig ? "踩断枯枝 · 狗立刻转耳" : "狗转耳朵"), 0.8);
            }
            return;
        }
        if (this.dogState === "ear") {
            if (sheltered) {
                this.dogState = "sniff";
                this.dogT = 45;
                this.flashSet("钻进遮蔽 · 狗顿住了", 0.9);
                return;
            }
            this.dogT -= 1;
            if (this.dogT <= 0) {
                this.dogState = "chase";
                this.dogTargetX = p.x;
                this.flashSet("狗追来了", 1.4);
            }
            return;
        }
        if (this.dogState === "chase") {
            const dir = p.x > this.dogX ? 1 : -1;
            this.dogX += dir * dog.speed * 1.4 * dt;
            if (!sheltered && Math.abs(p.x - this.dogX) < 18 && Math.abs(p.y) < 40) {
                this.caught();
                this.dogState = "sniff";
                this.dogT = 60;
            } else if (dist > effectiveRange * 1.5 || sheltered) {
                this.dogState = "sniff";
                this.dogT = 60;
                this.flashSet(inBurrowCover ? "树根窄洞遮住身形 · 狗停下了" : "狗停下了", 0.9);
            }
            return;
        }
        if (this.dogState === "sniff") {
            this.dogT -= 1;
            if (this.dogT <= 0) {
                this.dogState = "back";
            }
            return;
        }
        // back：走回巡逻起点。
        const dir = dog.x0 > this.dogX ? 1 : -1;
        this.dogX += dir * dog.speed * dt;
        if (Math.abs(this.dogX - dog.x0) < 2) {
            this.dogX = dog.x0;
            this.dogState = "patrol";
        }
    }

    /** 入林两路：蹲着进树根窄洞，站着跑旧渠；第一次进入记一条路，之后沿林路走到溪湾。 */
    private stepForestRoute(): void {
        const p = this.player;
        const ox = this.ox;
        if (this.forestPath === "") {
            if (p.crouch && p.x >= ox + 300 && p.x <= ox + 380) {
                this.forestPath = "burrow";
                this.run.story.segments["forest_burrow"] = true;
                this.flashSet("树根窄洞 · 蹲着钻过去", 1.5);
                this.emit("storyBeat", { beat: "path_burrow", x: p.x, room: "forest" });
            } else if (!p.crouch && p.x >= ox + 700 && p.x <= ox + 790) {
                this.forestPath = "ditch";
                this.run.story.segments["forest_ditch"] = true;
                this.flashSet("旧渠 · 顺着渠底跑", 1.5);
                this.emit("storyBeat", { beat: "path_ditch", x: p.x, room: "forest" });
            }
        }
        if (!this.waterSeen && p.x >= ox + 1180 && p.x <= ox + 1260) {
            this.waterSeen = true;
            this.run.story.segments["water_lantern"] = true;
            this.flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8);
            this.emit("storyBeat", { beat: "water_lantern", x: p.x, room: "forest" });
        }
    }

    private caught(): void {
        this.caughtT = 1.0;
        this.flashSet("被抓 · 回到安全点", 1.6);
    }

    /** 被抓复位：回本房间起点，敌人回位，已拿的瓶子保留。 */
    private recoverFromCaught(): void {
        const p = this.player;
        p.x = this.ox + 140;
        p.y = 0;
        p.vy = 0;
        p.vx = 0;
        p.onGround = true;
        if (this.room.key === "village" && this.room.scavenger !== undefined) {
            this.scavX = this.room.scavenger.x0;
            this.scavState = "patrol";
            this.scavSee = 0;
            this.scavChase = false;
            this.scavT = 0;
        }
        if (this.room.key === "forest" && this.room.story !== undefined && this.room.story.dog !== undefined) {
            this.dogX = this.room.story.dog.x0;
            this.dogState = "patrol";
            this.dogT = 0;
        }
        this.cam.x = p.x;
        this.cam.y = p.y + CAM_LOOK_UP;
        this.flashSet("回到安全点", 1.2);
    }

    /** 出口：车落窝、两人都进 [792,928] 才开。 */
    private updateGate(): void {
        if (this.room.key !== "checkpoint") {
            this.gateOpen = false;
            return;
        }
        const inZone = (x: number): boolean => x >= this.ox + 792 && x <= this.ox + 928;
        this.gateOpen = this.cartDocked && inZone(this.player.x) && inZone(this.partner.x);
    }

    // ---------- 新版关卡 S1–C2 ----------

    /** 掉落与拾取都走同一张背包。 */
    private addItem(kind: string): boolean {
        const inv = this.run.inventory;
        if (kind === "shield") {
            if (inv.shield >= TOOL_CAP) {
                return false;
            }
            inv.shield += 1;
            return true;
        }
        if (kind === "wedge") {
            if (inv.wedge >= CONSUMABLE_CAP) {
                return false;
            }
            inv.wedge += 1;
            return true;
        }
        if (kind === "ammo") {
            if (inv.ammo >= CONSUMABLE_CAP) {
                return false;
            }
            inv.ammo += 1;
            return true;
        }
        if (kind === "scrap") {
            // 材料不占格，多捡几块不挤掉消耗品。
            inv.scrap += 1;
            return true;
        }
        if (kind === "wood") {
            inv.wood += 1;
            return true;
        }
        if (kind === "bell") {
            inv.bell += 1;
            return true;
        }
        if (kind === "pass") {
            inv.pass += 1;
            return true;
        }
        if (kind === "quickbelt") {
            inv.quickbelt += 1;
            return true;
        }
        return false;
    }

    private findBox(id: string): Box | undefined {
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            if (this.boxes[i].id === id) {
                return this.boxes[i];
            }
        }
        return undefined;
    }

    /** 最近的可加固木件。由数据决定（breakable 且没写 wedgeable:false），不按房间特判。 */
    private findWedgeTarget(): Box | undefined {
        let best: Box | undefined = undefined;
        let bestD = 0;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.breakable === undefined || b.broken === true || b.breakable.wedgeable === false) {
                continue;
            }
            if (!this.nearBox(b, 26)) {
                continue;
            }
            const d = Math.abs(b.x0 - this.player.x) + Math.abs(b.x1 - this.player.x);
            if (best === undefined || d < bestD) {
                best = b;
                bestD = d;
            }
        }
        return best;
    }

    /**
     * 废木料制木楔：按住 E 满 45 拍才成。松手、受伤、握车柄都会取消，
     * 完成后只结算一次，取消不退还也不复制原料。
     * @returns 本拍是否吃掉了 E。
     */
    private stepCraft(input: Input): boolean {
        const inv = this.run.inventory;
        const required = Math.max(6, CRAFT_TICKS - 6 * this.talentRank("salvage"));
        if (this.craftT > 0) {
            if (!input.interact.held || this.gripping || this.player.rollT > 0
                || this.escort.state === "calming" || this.paused) {
                this.craftT = 0;
                this.flashSet("制作中断", 0.8);
                return true;
            }
            this.craftT += 1;
            if (this.craftT >= required) {
                if (inv.scrap > 0 && inv.wedge < CONSUMABLE_CAP) {
                    inv.scrap -= 1;
                    inv.wedge += 1;
                    this.flashSet("制得木楔", 1.2);
                    this.log("制木楔");
                    this.emit("craftDone", { item: "wedge", ticks: required });
                }
                this.craftT = 0;
            }
            return true;
        }
        if (input.interact.pressed && inv.scrap > 0 && inv.wedge < CONSUMABLE_CAP && this.findInteract() === undefined) {
            this.craftT = 1;
            this.flashSet("握住废木料 · 按住 E 削木楔", 1.0);
            this.emit("craftStart", { item: "wedge", ticks: required });
            return true;
        }
        return false;
    }

    private nearBox(b: Box, reach: number): boolean {
        const p = this.player;
        return p.x + p.w / 2 >= b.x0 - reach && p.x - p.w / 2 <= b.x1 + reach
            && p.y <= b.y1 + 12 && p.y + p.h >= b.y0 - 12
            && overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH);
    }

    /** 本拍能按 E 的机关；没有就返回 undefined。 */
    private findInteract(): Box | undefined {
        const p = this.player;
        let best: Box | undefined = undefined;
        let bestD = 1e9;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.interact === undefined || b.broken === true) {
                continue;
            }
            if (!this.nearBox(b, b.interact.reach ?? 27)) {
                continue;
            }
            const d = Math.abs(p.x - (b.x0 + b.x1) / 2);
            if (d < bestD) {
                bestD = d;
                best = b;
            }
        }
        return best;
    }

    /** 关卡步：回运行态、路线判定、拾取、E 交互、推车与出口。 */
    private stepCampaign(dt: number, input: Input): void {
        const wr = this.room;
        const p = this.player;
        if (this.reloadT > 0) {
            this.reloadT -= 1;
        }
        // 残盾跟着人走：架起来后推车、退步都要护在身前，不能留在架设点。
        if (this.bracedShield !== undefined) {
            this.bracedShield.x = p.x + p.facing * 26;
            this.bracedShield.y = p.y;
            const shBox = this.boxes.find((b) => b.id === "braced_shield");
            if (shBox !== undefined) {
                shBox.x0 = this.bracedShield.x - 15;
                shBox.x1 = this.bracedShield.x + 15;
                shBox.y0 = this.bracedShield.y;
                shBox.y1 = this.bracedShield.y + this.bracedShield.h;
            }
        }
        // S2 从布行侧进入：转到窗板线，小满先去后仓等。
        if (wr.key === "s2-drygoods" && this.run.route !== "drygoods"
            && p.x < wr.minX + 330 && p.depth <= -16) {
            this.run.route = "drygoods";
            this.run.joined = false;
            this.flashSet("转布行线 · 小满到窗板后等", 1.3);
            this.log("转布行线");
        }
        // 第三段安全工台：靠近工台（含整张 560..680 台面与两侧接近日）按 E 开面板，不穿透到普通机关提示。
        // 若玩家未开工台即越过工台区（x >= 940），也兜底触发第三段本领抽卡。
        if (wr.key === "escort3") {
            const nearBench = p.x >= wr.minX + 472 && p.x <= wr.minX + 710 && p.y < 60;
            if (nearBench && input.interact.pressed) {
                this.openCraftBench();
                return;
            }
            if (this.storyRoute === "soldier" && this.run.story.talents?.deferred === true && p.x >= wr.minX + 940) {
                this.triggerDeferredEscort3Draft();
            }
        }
        // 拾取：走到掉落物上自动进包。
        let i = 0;
        for (i = 0; i < this.pickups.length; i++) {
            const pk = this.pickups[i];
            if (this.run.taken[pk.id] === true) {
                continue;
            }
            const sameDepth = overlapsDepth(p.depth, { min: (pk.depth ?? 0) - 10, max: (pk.depth ?? 0) + 10 }, 10);
            const dy = Math.abs((pk.y + (pk.depth ?? 0)) - (p.y + p.depth));
            if (Math.abs(pk.x - p.x) < 44 && dy < 60 && sameDepth) {
                if (!this.addItem(pk.kind)) {
                    // 满包时保留拾取机会，腾出格位后能再来捡。
                    this.flashSet("背包满了 · " + pk.label + " 留在原地", 1.0);
                    this.log("满包拒绝 " + pk.kind);
                    this.emit("pickupRejected", { kind: pk.kind, x: pk.x, y: pk.y });
                    continue;
                }
                this.run.taken[pk.id] = true;
                this.flashSet("拾取 " + pk.label, 1.0);
                this.log("拾取 " + pk.kind + " " + pk.label);
                this.emit("pickup", { kind: pk.kind, x: pk.x, y: pk.y, label: pk.label });
            }
        }
        // S1–C2 正式剧情中，若小满因近距交火受惊，允许周戍走近按 E 轻敲两下安抚。
        this.calmConsumed = false;
        if (this.partner.alive && this.run.joined
            && (this.room.campaign?.chapter === "S" || this.room.campaign?.chapter === "C")
            && (this.escort.fear > 0 || this.escort.state === "frozen" || this.escort.state === "calming")) {
            const dist = inReachDepth(p.depth, this.partner.depth) ? Math.abs(p.x - this.partner.x) : 1e9;
            const hadK1 = this.escort.knock1;
            const hadK2 = this.escort.knock2;
            this.calmConsumed = this.escort.update(input, p.x, p.facing, this.partner.x, dist);
            if (!hadK1 && this.escort.knock1) {
                this.emit("knock", { count: 1, x: this.partner.x, room: this.room.key });
            }
            if (!hadK2 && this.escort.knock2) {
                this.emit("knock", { count: 2, x: this.partner.x, room: this.room.key });
            }
            this.partner.crouch = this.escort.crouchPose;
            this.partner.h = this.partner.crouch ? CHILD_CROUCH_H : CHILD_H;
        }
        if (!this.calmConsumed && !this.stepCraft(input) && input.interact.pressed) {
            this.campaignInteract();
        }
        this.stepCampaignCart(dt, input);
        this.stepCampaignGoal();
        this.campaignCheckpoint();
    }

    /** 护送段检查点：踩到 kind 0 标记就记一份库存/装备/背负快照。 */
    private campaignCheckpoint(): void {
        let i = 0;
        for (i = 0; i < this.room.marks.length; i++) {
            const m = this.room.marks[i];
            if (m.kind !== 0) {
                continue;
            }
            const dx = this.player.x - m.x;
            const dy = this.player.y - m.y;
            if (dx * dx + dy * dy < 26 * 26 && this.checkpoint !== m.x) {
                this.checkpoint = m.x;
                this.captureCheckpoint(m.x);
                this.flashSet("检查点", 1.0);
            }
        }
    }

    /** E：机关优先，其次加固 / 架盾 / 号牌。 */
    private campaignInteract(): void {
        const b = this.findInteract();
        if (b !== undefined) {
            this.useInteract(b);
            return;
        }
        const inv = this.run.inventory;
        if (inv.wedge > 0) {
            const w = this.findWedgeTarget();
            if (w !== undefined) {
                const extraHp = (w.breakable?.wedgeHp ?? 1) + this.talentRank("salvage");
                if (w.breakable !== undefined) {
                    w.breakable.hp += extraHp;
                }
                inv.wedge -= 1;
                this.run.props[w.id === undefined ? "wedge" : w.id]
                    = { broken: w.broken === true, hp: w.breakable === undefined ? 0 : w.breakable.hp, wedge: true };
                this.flashSet(extraHp > 1 ? ("钉木楔 · 多承" + extraHp + "次") : "钉木楔 · 多承一次", 1.2);
                this.log("加固 " + (w.label === undefined ? "木件" : w.label));
                this.emit("interactUsed", { kind: "wedge", x: w.x0 });
                return;
            }
            if (this.isEscortRoom()) {
                const p = this.player;
                const wx = Math.max(this.room.minX + 64, Math.min(this.room.maxX - 64, p.x + p.facing * 32));
                const hp = 1 + this.talentRank("salvage");
                this.fieldWedgeSeq += 1;
                const wid = "field_wedge_" + this.fieldWedgeSeq;
                this.boxes.push({
                    x0: wx - 12,
                    x1: wx + 12,
                    y0: p.y,
                    y1: p.y + 48,
                    depth: { min: p.depth - 20, max: p.depth + 20 },
                    label: "立起的木楔掩体",
                    id: wid,
                    breakable: { hp: hp, kind: "thin_wood", wedgeable: true },
                });
                inv.wedge -= 1;
                this.flashSet("立木楔 · 临时挡弹" + (hp > 1 ? ("(" + hp + "击)") : ""), 1.2);
                this.log("立木楔掩体");
                this.emit("interactUsed", { kind: "wedge", x: wx });
                return;
            }
        }
        if (inv.ammo > 0 && this.reloadT > 0) {
            // 备用弹包：立刻补满当前这一发，不缩短后续装填；线盘同时收起。
            this.reloadT = 0;
            this.closeReloadPuzzle();
            inv.ammo -= 1;
            this.flashSet("备用弹包 · 膛内补满", 1.0);
            this.log("用备用弹包");
            this.emit("interactUsed", { kind: "ammo", x: this.player.x });
            return;
        }
        const canBraceHere = (this.room.key === "c2-granary"
            && this.player.x >= this.room.minX + 960 && this.player.x <= this.room.minX + 1320)
            || this.isEscortRoom();
        if (inv.shield > 0 && this.bracedShield === undefined && canBraceHere) {
            const p = this.player;
            const shHp = 1 + this.talentRank("salvage");
            this.bracedShield = { x: p.x + p.facing * 26, y: p.y, w: 30, h: 64, hp: shHp };
            this.boxes.push({
                x0: this.bracedShield.x - 15, x1: this.bracedShield.x + 15,
                y0: p.y, y1: p.y + 64, depth: { min: -46, max: 46 }, label: "架起的残盾", id: "braced_shield",
                soft: true, // 只挡弹，不参与走位碰撞；否则盾会把架盾的人自己推走。
            });
            inv.shield -= 1;
            this.flashSet(shHp > 1 ? ("架残盾 · 可挡" + shHp + "发") : "架残盾 · 挡一发", 1.2);
            this.log("架残盾");
            this.emit("interactUsed", { kind: "shield", x: p.x });
            return;
        }
        if (inv.pass > 0 && this.run.joined === false) {
            inv.pass -= 1;
            this.run.joined = true;
            this.flashSet("护送号牌 · 小满跟上", 1.2);
            this.emit("interactUsed", { kind: "pass", x: this.player.x });
            return;
        }
        this.flashSet(this.hint === "" ? "这里没有可用的机关" : this.hint, 0.8);
    }

    private useInteract(b: Box): void {
        const kind = b.interact === undefined ? "" : b.interact.kind;
        const wr = this.room;
        if (kind === "open_board") {
            b.broken = true;
            this.run.props["s2_board"] = { broken: true, hp: 0, wedge: false };
            for (const cover of this.boxes) {
                if (cover.id === "s2_board_cover") {
                    cover.broken = false;
                    cover.hidden = false;
                }
            }
            this.run.props["s2_board_cover"] = { broken: false, hp: 0, wedge: false, revealed: true };
            this.run.joined = true;
            this.flashSet("放下窗板 · 小满跟上", 1.4);
            this.log("放下窗板");
            this.emit("interactUsed", { kind: "open_board", x: b.x0 });
            return;
        }
        if (kind === "lower_curtain") {
            for (const curtain of this.boxes) {
                if (curtain.id === "c2_curtain") {
                    curtain.broken = false;
                    curtain.hidden = false;
                }
            }
            this.run.props["c2_curtain"] = { broken: false, hp: 0, wedge: false, revealed: true };
            this.flashSet("放下木帘 · 暴露轨段有遮挡", 1.4);
            this.log("放下木帘");
            this.emit("interactUsed", { kind: "lower_curtain", x: b.x0 });
            return;
        }
        if (kind === "raise_latch") {
            if (wr.key === "c2-granary" && !this.cartDocked) {
                this.flashSet("车轮还没入窝 · 先把车推到底", 1.0);
                return;
            }
            b.broken = true;
            this.objectiveDone = true;
            // 两道门闩分开记：C1 抬闩恢复同行，C2 连杆只在车轮入窝后成立。
            if (wr.key === "c1-yard") {
                this.run.c1Latch = true;
                this.run.joined = true;
                for (const door of this.boxes) {
                    if (door.id === "c1_door") {
                        door.broken = true;
                    }
                }
                this.run.props["c1_door"] = { broken: true, hp: 0, wedge: false };
            } else {
                this.run.c2Latch = true;
                this.run.joined = true;
            }
            this.run.props[b.id ?? "latch"] = { broken: true, hp: 0, wedge: false };
            this.emit("objectiveDone", { goal: "raise_latch", room: wr.key });
            this.log("抬闩");
            this.flashSet("抬闩 · 通路打开", 1.4);
            this.emit("interactUsed", { kind: "raise_latch", x: b.x0 });
        }
    }

    /** 推车：E 握柄，A/D 推，车轮入窝后松开；暴露轨段的射击照常结算。 */
    private stepCampaignCart(dt: number, input: Input): void {
        const wr = this.room;
        const c = wr.cart;
        if (c.bodyW <= 0) {
            return;
        }
        const p = this.player;
        const handleX = this.cartAxle + c.handleOffset;
        if (!this.gripping) {
            if (input.interact.pressed && !this.cartDocked && Math.abs(p.x - handleX) <= CART_REACH
                && Math.abs(p.y - c.baseY) <= 40 && inReachDepth(p.depth, c.depth ?? 0) && !this.objectiveDone) {
                this.gripping = true;
                this.flashSet("握住车柄 · A/D 推", 1.0);
            }
            return;
        }
        if (input.interact.pressed) {
            this.gripping = false;
            this.flashSet("松手", 0.5);
            return;
        }
        if (!this.cartDocked) {
            if (input.moveX !== 0 && !this.stuckCart()) {
                this.cartAxle = Math.max(c.startX, Math.min(c.endX, this.cartAxle + input.moveX * CART_SPEED * dt));
            }
            // 暴露轨段：车轮一进 1000–1200，棚尾火器手必打一枪。
            // 这一枪不看蓄势计时，专门用来检验「空手吃弹 / 残盾挡下 / 木帘截断」。
            if (!this.cartExposed && this.cartAxle >= wr.minX + 1240 && this.cartAxle <= wr.minX + 1360) {
                this.cartExposed = true;
                let gun: Enemy | undefined = undefined;
                let gi = 0;
                for (gi = 0; gi < this.enemies.length; gi++) {
                    const e = this.enemies[gi];
                    if (e.alive && e.kind === "gunner" && Math.abs((e.depth ?? 0) - p.depth) <= 44) {
                        gun = e;
                        break;
                    }
                }
                if (gun !== undefined) {
                    this.campaignEnemyFire(gun);
                }
            }
            p.x = this.cartAxle + c.handleOffset;
            p.y = c.baseY;
            p.depth = c.depth ?? 0;
            p.vx = 0;
            if (Math.abs(this.cartAxle - c.endX) < 0.5) {
                this.cartAxle = c.endX;
                this.cartDocked = true;
                this.gripping = false;
                this.run.props["c2_cart"] = { broken: true, hp: 0, wedge: false };
                this.emit("cartDocked", { axle: this.cartAxle, playerX: p.x, room: wr.key });
                this.flashSet("车轮入窝", 1.2);
                this.log("车轮入窝");
            }
        }
    }

    /** 车头前有未打散的围挡就推不动。 */
    private stuckCart(): boolean {
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.broken === true || b.breakable === undefined || b.soft === true) {
                continue;
            }
            const front = this.cartAxle + this.room.cart.bodyW / 2;
            if (b.y0 < 40 && b.x0 < front + 10 && b.x1 > front - 10) {
                return true;
            }
        }
        return false;
    }

    /** 目标与出口：两人到位才切下一段。 */
    private stepCampaignGoal(): void {
        const wr = this.room;
        const c = wr.campaign;
        if (c === undefined) {
            return;
        }
        if (wr.key === "c2-granary" && this.cartDocked && this.run.c2Latch === true) {
            this.objectiveDone = true;
        }
        if (c.goal === "reach_exit") {
            this.objectiveDone = true;
        }
        if (!this.objectiveDone) {
            return;
        }
        const p = this.player;
        const partnerOk = this.run.joined && this.partner.x >= c.exitX - 220;
        if (p.x < c.exitX || !partnerOk) {
            return;
        }
        // 段出口只结算一次：玩家真正走到出口、同伴跟上，记一段完成。
        if (this.run.story.segments[wr.key] !== true) {
            this.run.story.segments[wr.key] = true;
            this.emit("segmentDone", { room: wr.key, act: c.act, next: c.next ?? "", ticks: this.ticks });
        }
        // 第五段出口就是全程走完；塔门由房间数据接上。
        if (wr.key === "escort5") {
            this.escortDone = true;
            this.run.story.escortDone = true;
        }
        if (c.next !== undefined && c.next !== "") {
            this.requestRoom(c.next, "段出口 " + wr.key);
            this.flashSet("过关 · " + c.next, 1.2);
        } else if (wr.key === "c2-granary"
            && (this.run.source === "official" || this.run.source === "chapter")) {
            this.requestRoom("gate", "军粮棚出口");
            this.flashSet("出军粮棚 · 城门", 1.4);
        } else if (!this.run.finished) {
            this.run.finished = true;
            this.flashSet("军粮棚清完 · 回城门 · " + mmss(this.run.roomTicks[wr.key] ?? 0), 2.0);
            this.log("军粮棚清完 · 回城门");
            this.emit("objectiveDone", { goal: "dock_cart", room: wr.key });
        }
    }

    /** 小满在新版关卡里的跟随：等待点 → 跟上 → 跨台阶自己跳。 */
    private stepCampaignPartner(dt: number): void {
        const a = this.partner;
        const wr = this.room;
        const cp = wr.companion;
        if (!a.alive) {
            return;
        }
        const p = this.player;
        // 工台打开时小满站在台边等，不跟着人绕台面。
        if (this.craftBench.active) {
            a.vx = 0;
            return;
        }
        let wait = false;
        let targetX = cp === undefined ? p.x - 70 : p.x - (p.facing > 0 ? 70 : -70);
        let targetDepth = p.depth;
        if (this.run.joined === false) {
            wait = true;
            targetX = cp === undefined ? a.x : (cp.waitX ?? a.x);
            targetDepth = cp === undefined ? a.depth : (cp.waitDepth ?? 0);
        } else if (wr.key === "c1-yard" && !this.run.c1Latch) {
            wait = true;
            targetX = cp === undefined ? a.x : (cp.waitX ?? a.x);
            targetDepth = cp === undefined ? a.depth : (cp.waitDepth ?? 0);
        } else if (wr.key === "c2-granary" && !this.cartDocked) {
            wait = true;
            targetX = cp === undefined ? a.x : (cp.waitX ?? a.x);
            targetDepth = cp === undefined ? a.depth : (cp.waitDepth ?? 0);
        }
        if (this.partnerStuck > 0.3) {
            // 撞在柱列 / 台角上：退出障碍侧面，并直接换到 中 → 上 → 下 的下一条空档。
            a.x += a.facing * 44;
            this.partnerLaneIdx = (this.partnerLaneIdx + 1) % 3;
            a.depth = this.partnerLaneIdx === 0 ? 0 : (this.partnerLaneIdx === 1 ? 32 : -32);
            this.partnerLaneHold = 1.1;
            this.partnerStuck = 0;
        }
        if (this.partnerLaneHold > 0) {
            this.partnerLaneHold -= dt;
            targetDepth = this.partnerLaneIdx === 0 ? 0 : (this.partnerLaneIdx === 1 ? 32 : -32);
        }
        const dx = targetX - a.x;
        const stopTol = wait ? 18 : 74;
        if (Math.abs(dx) > stopTol) {
            const speed = Math.abs(dx) > 260 ? CHILD_SPEED * 1.4 : CHILD_SPEED;
            const before = a.x;
            a.vx = dx > 0 ? speed : -speed;
            a.facing = dx > 0 ? 1 : -1;
            this.slideX(a, a.vx * dt);
            // 跟随时撞到矮台（柜台、台阶）：自己跳上去，不卡在台前。
            if (a.onGround && Math.abs(a.x - before) < 0.5) {
                a.vy = CHILD_JUMP;
                a.onGround = false;
            }
            this.partnerStuck = Math.abs(a.x - before) < 0.5 ? this.partnerStuck + dt : 0;
        } else {
            a.vx = 0;
            this.partnerStuck = 0;
        }
        const dz = targetDepth - a.depth;
        if (Math.abs(dz) > 6) {
            const step = Math.max(-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, Math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz));
            a.depth += step;
        }
        a.depthSpeed = 0;
        a.h = CHILD_H;
        a.crouch = false;
        this.fallY(a, dt);
    }

    /** 新版关卡的敌人：火器手按深度与遮挡开火，持盾手推进，破障手砸挡或砸人。 */
    private stepCampaignEnemies(dt: number, input: Input): void {
        const p = this.player;
        let i = 0;
        for (i = 0; i < this.enemies.length && !this.escortFailed; i++) {
            const e = this.enemies[i];
            if (e.kind === "target") {
                // 试射靶只吃子弹：不移动、不开火，命中闪一下再立起来（必须在 !e.alive 之前检查，避免永久倒靶）。
                if (!e.alive) {
                    if (e.hitT > 0) {
                        e.hitT -= dt;
                    }
                    if (e.hitT <= 0) {
                        e.alive = true;
                        e.hitT = 0;
                    }
                }
                continue;
            }
            if (!e.alive) {
                continue;
            }
            if (e.kind === "breaker") {
                this.stepBreaker(e, dt);
                continue;
            }
            if (e.kind === "shield") {
                this.stepShield(e, dt, input);
                continue;
            }
            // 火器手 / 带队者：站桩举枪。先近身才觉醒，避免隔着半条街就开火。
            const dx = e.x - p.x;
            if (!e.awake) {
                if (Math.abs(dx) > 520) {
                    continue;
                }
                e.awake = true;
                e.fireCd = 48;
                continue;
            }
            if (Math.abs(dx) > ENEMY_RANGE) {
                continue;
            }
            // 军粮棚的棚尾火器手只封暴露轨段：玩家退到连杆前（1510 之后）已经贴到棚尾，
            // 不在它的射界里，抬闩与出门不再吃枪。
            if (this.room.key === "c2-granary" && p.x > this.room.minX + 1450) {
                continue;
            }
            if (Math.abs((e.depth ?? 0) - p.depth) > 44) {
                continue;
            }
            if (this.blockedShot(e, p)) {
                // 目标躲回掩体后：这次举枪作废，重新等一个装填周期。
                // 否则 warnT 会在遮挡期间冻结，玩家一探头就立刻挨枪，"看时机"没有意义。
                if (e.warnT > 0) {
                    e.warnT = 0;
                    e.fireCd = CAMPAIGN_FIRE_COOLDOWN;
                }
                continue;
            }
            if (e.warnT > 0) {
                e.warnT -= 1;
                if (e.warnT <= 0) {
                    this.campaignEnemyFire(e);
                }
            } else if (e.fireCd > 0) {
                e.fireCd -= 1;
                if (e.fireCd <= 0) {
                    e.warnT = WARN_TICKS;
                }
            } else {
                e.fireCd = 40;
            }
        }
    }

    /** 射线是否被实体或软遮挡挡在敌我之间。 */
    private blockedShot(e: Enemy, p: Actor): boolean {
        const eDepth = e.depth ?? 0;
        const ex = e.x;
        // 纯高度作 y 轴，纵深作独立轴：屏幕 y = 高度 + 纵深。
        const ey = e.y + e.h * 0.62;
        const px = p.x;
        const py = p.y + p.h * 0.55;
        const dx = px - ex;
        const dyScreen = (py + p.depth * DEPTH_Y_SCALE) - (ey + eDepth * DEPTH_Y_SCALE);
        const len = Math.sqrt(dx * dx + dyScreen * dyScreen);
        if (len < 0.01) {
            return false;
        }
        // 敌我一致：射线自带起点档位和纵深变化率，交给 hitBox 做完整三轴求交。
        // 只拿「敌人所在档」过滤掩体，会把射线末端真实挡住的远端挡物漏掉。
        const ray = {
            x: ex, y: ey,
            dx: dx / len, dy: (py - ey) / len,
            depth: eDepth, dDepth: (p.depth - eDepth) / len,
        };
        let best = -1;
        let j = 0;
        for (j = 0; j < this.boxes.length; j++) {
            const b = this.boxes[j];
            if (b.broken === true || b.passable === true || b.hidden === true) {
                continue;
            }
            // 残盾：留到 campaignEnemyFire 里判「挡下一发」，不在这里被当成普通掩体，
            // 否则敌人永远不会扣扳机，盾也就永远不碎。
            if (b.id === "braced_shield") {
                continue;
            }
            const t = hitBox(ray, b);
            // t 太靠近起点说明射线是从这件东西内部出发的（比如火器手站在抬闩里），
            // 那不是「挡在中间」，不该算遮挡。
            if (t > 2 && t < len - 2 && (best < 0 || t < best)) {
                best = t;
            }
        }
        return best >= 0;
    }

    private campaignEnemyFire(e: Enemy): void {
        const p = this.player;
        e.fireCd = CAMPAIGN_FIRE_COOLDOWN;
        if (this.bracedShield !== undefined && Math.abs(this.bracedShield.x - p.x) < 50) {
            this.bracedShield.hp -= 1;
            if (this.bracedShield.hp <= 0) {
                this.boxes = this.boxes.filter((b) => b.id !== "braced_shield");
                this.bracedShield = undefined;
                this.flashSet("残盾碎 · 挡下一发", 1.0);
            } else {
                this.flashSet("残盾挡下一发 · 余" + this.bracedShield.hp, 1.0);
            }
            this.emit("coverBlocked", { entity: "残盾", enemyX: e.x, hp: this.hp });
            return;
        }
        if (this.blockedShot(e, p)) {
            this.emit("coverBlocked", { entity: "实体遮挡", enemyX: e.x, hp: this.hp });
            return;
        }
        const cover = this.blockedByCover(e, p);
        if (cover !== undefined && this.coverHug) {
            this.coveredFlash = 0.5;
            this.flashSet("掩体挡下", 0.6);
            this.emit("coverBlocked", {
                entity: cover.label === undefined ? "一人高实体" : cover.label,
                enemyX: e.x,
                hp: this.hp,
            });
            return;
        }
        if (this.invulnT > 0) {
            return;
        }
        this.invulnT = INVULN_HIT_TICKS + 15 * this.talentRank("guard");
        this.craftT = 0;
        this.hp -= 1;
        this.emit("actorHit", { target: "player", amount: 1, hp: this.hp, maxHp: this.maxHp, enemyX: e.x });
        this.flashSet("中弹 " + Math.max(0, this.hp) + "/" + this.maxHp, 0.8);
        if (this.hp <= 0) {
            this.campaignFailed();
        }
    }

    /** 持盾手：缓慢压近，近身就砸；盾完整时正面挡弹。 */
    private stepShield(e: Enemy, dt: number, input: Input): void {
        const p = this.player;
        const dx = p.x - e.x;
        const adx = Math.abs(dx);
        // 军粮棚远侧的盾手守在上档：它只横向压过来，不跟玩家降档贴脸，
        // 否则玩家握车柄推车时没有还手窗口，三种过法都会被同一个近身打断。
        const guardLane = this.room.key === "c2-granary" && (e.depth ?? 0) >= 20;
        const sameLane = Math.abs((e.depth ?? 0) - p.depth) <= 20;
        if (adx > 44) {
            const before = e.x;
            const stepX = (dx > 0 ? 1 : -1) * 60 * dt;
            const nextX = Math.max(this.room.minX + 16, Math.min(this.room.maxX - 16, e.x + stepX));
            if (!this.enemyBlockedAtX(e, nextX)) {
                e.x = nextX;
            }
            if (!guardLane && Math.abs(e.x - before) < 0.3) {
                // 被挡：尝试换更深/更浅一档绕行。
                e.depth = Math.max(-32, Math.min(32, (e.depth ?? 0) + (p.depth >= (e.depth ?? 0) ? 16 : -16)));
            }
        } else if (adx <= 48 && sameLane && (e.swingT ?? 0) <= 0) {
            // 翻滚只抵消正面来击：盾手在背后挥过来时，往前滚等于把后背送上去。
            // 全向免疫会让翻滚变成无成本的万能键，也就没有"看时机再滚"可言。
            const fromFront = (e.x - p.x) * p.facing > 0;
            const rollDodges = p.rollT > 0 && (fromFront || this.talentRank("guard") > 0);
            if (!rollDodges && this.invulnT <= 0) {
                this.invulnT = INVULN_HIT_TICKS + 15 * this.talentRank("guard");
                this.craftT = 0;
                this.hp -= 1;
                this.emit("actorHit", { target: "player", amount: 1, hp: this.hp, maxHp: this.maxHp, enemyX: e.x });
                this.flashSet("盾手近身 · " + Math.max(0, this.hp) + "/" + this.maxHp, 0.8);
                if (this.hp <= 0) {
                    this.campaignFailed();
                    return;
                }
            }
            e.swingT = 70;
        }
        if ((e.swingT ?? 0) > 0) {
            e.swingT = (e.swingT ?? 0) - 1;
        }
        if (!guardLane && Math.abs((e.depth ?? 0) - p.depth) > 20) {
            const dd = p.depth - (e.depth ?? 0);
            e.depth = (e.depth ?? 0) + (dd > 0 ? 1 : -1) * 30 * dt;
        }
    }

    /** 破障手：先砸最近的可破坏挡，挡碎后追人。 */
    private stepBreaker(e: Enemy, dt: number): void {
        const p = this.player;
        if (e.awake !== true) {
            if (Math.abs(p.x - e.x) < 560) {
                e.awake = true;
            } else {
                return;
            }
        }
        let target: Box | undefined = undefined;
        let bestD = 1e9;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.breakable === undefined || b.broken === true) {
                continue;
            }
            const d = Math.abs((b.x0 + b.x1) / 2 - e.x);
            if (d < bestD) {
                bestD = d;
                target = b;
            }
        }
        const tx = target === undefined ? p.x : (target.x0 + target.x1) / 2;
        const dx = tx - e.x;
        const reach = target === undefined ? 46 : (target.x1 - target.x0) / 2 + 40;
        if (Math.abs(dx) > reach) {
            const before = e.x;
            const nextX = Math.max(this.room.minX + 16, Math.min(this.room.maxX - 16, e.x + (dx > 0 ? 1 : -1) * 48 * dt));
            if (!this.enemyBlockedAtX(e, nextX)) {
                e.x = nextX;
            }
            if (Math.abs(e.x - before) < 0.3) {
                e.depth = Math.max(-32, Math.min(32, (e.depth ?? 0) + (p.depth >= (e.depth ?? 0) ? 16 : -16)));
            }
        } else if ((e.swingT ?? 0) <= 0) {
            e.swingT = 64;
            if (target !== undefined) {
                this.damageProp(target, 2);
            } else if (Math.abs(p.x - e.x) < 60 && Math.abs((e.depth ?? 0) - p.depth) <= 26
                && !(p.rollT > 0 && this.talentRank("guard") > 0) && this.invulnT <= 0) {
                this.invulnT = INVULN_HIT_TICKS + 15 * this.talentRank("guard");
                this.craftT = 0;
                this.hp -= 1;
                this.emit("actorHit", { target: "player", amount: 1, hp: this.hp, maxHp: this.maxHp, enemyX: e.x });
                this.flashSet("破障手近身", 0.8);
                if (this.hp <= 0) {
                    this.campaignFailed();
                    return;
                }
            }
        }
        if ((e.swingT ?? 0) > 0) {
            e.swingT = (e.swingT ?? 0) - 1;
        }
    }

    /** 判定敌兵横向移动到 nextX 是否会撞上同层实体墙体（避免盾手/破障手穿墙）。 */
    private enemyBlockedAtX(e: Enemy, nextX: number): boolean {
        const half = e.w * 0.5;
        const d = e.depth ?? 0;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.broken === true || b.passable === true || b.soft === true || b.hidden === true || b.y0 >= e.y + e.h || b.y1 <= e.y + 4) {
                continue;
            }
            if (b.depth !== undefined && (d < b.depth.min - 8 || d > b.depth.max + 8)) {
                continue;
            }
            if (nextX + half > b.x0 && nextX - half < b.x1) {
                return true;
            }
        }
        return false;
    }

    private campaignFailed(): void {
        // 正式男主线五段护送：战斗死亡回男主入口（首场 escort1）并推进轮次派生新种子。
        // 挂载高清前端时先展示宋明水墨「折戟重整」小结页，再由玩家确认重开或回标题；
        // 独立无头测试（useEscortDeathSummary === false）立即执行重置并置 wantRoom = "escort1"。
        if (this.isCampaign && this.storyRoute === "soldier" && this.isEscortRoom()) {
            if (this.escortFailed) return;
            if (this.useEscortDeathSummary) {
                const story = this.run.story;
                const st = story.talents;
                const ranksCopy: Record<Talent, number> = {
                    vitality: st?.ranks.vitality ?? 0,
                    guard: st?.ranks.guard ?? 0,
                    stride: st?.ranks.stride ?? 0,
                    focus: st?.ranks.focus ?? 0,
                    push_force: st?.ranks.push_force ?? 0,
                    echo_wide: st?.ranks.echo_wide ?? 0,
                    lantern_pierce: st?.ranks.lantern_pierce ?? 0,
                    salvage: st?.ranks.salvage ?? 0,
                };
                let cleared = 0;
                const segKeys = ["escort1", "escort2", "escort3", "escort4", "escort5"];
                let si = 0;
                for (si = 0; si < segKeys.length; si++) {
                    if (story.segments[segKeys[si]] === true) {
                        cleared += 1;
                    }
                }
                this.escortFailed = true;
                this.escortFailedTicks = 0;
                this.talentModalActive = false;
                this.craftBench.active = false;
                this.reloadT = 0;
                this.closeReloadPuzzle();
                this.gripping = false;
                this.escortSummary = {
                    roomKey: this.room.key,
                    attempt: st !== undefined ? Math.max(1, st.attempt) : 1,
                    seed: st !== undefined ? st.randomState : this.run.seed,
                    equippedWeapon: this.equippedWeapon,
                    segmentsCleared: cleared,
                    ranks: ranksCopy,
                };
                this.resetEscortAttempt();
                this.flashSet("折返山道 · 重整再赴", 2.0);
                this.log("男主线折返 · 展示小结");
                this.emit("campaignFailed", {
                    room: this.room.key, hp: 0, maxHp: this.maxHp,
                    reset: true, to: "escort1", route: this.storyRoute, summary: true,
                });
                return;
            }
            this.restartEscortRun();
            return;
        }
        const p = this.player;
        this.hp = this.maxHp;
        this.invulnT = INVULN_RESPAWN_TICKS;
        this.reloadT = 0;
        this.closeReloadPuzzle();
        this.gripping = false;
        this.flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2.0);
        this.log("被击倒");
        p.x = this.room.minX + 90;
        p.y = 0;
        p.depth = 0;
        p.vx = 0;
        p.vy = 0;
        p.onGround = true;
        p.rollT = 0;
        this.partner.x = p.x - 50;
        this.partner.y = 0;
        this.partner.depth = 0;
        this.cam.x = p.x;
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            e.x = e.homeX === undefined ? e.x : e.homeX;
            e.warnT = 0;
            e.fireCd = 40;
            e.swingT = 0;
            e.awake = false;
        }
        this.emit("campaignFailed", { room: this.room.key, hp: 0, maxHp: this.maxHp });
    }

    /** 当前房是否是男主五段护送的一段。 */
    isEscortRoom(): boolean {
        return this.room.key.indexOf("escort") === 0;
    }

    /** 阵亡时已结算新轮次，小结确认后只切回第一段。 */
    confirmEscortRestart(): boolean {
        if (!this.escortFailed) {
            return false;
        }
        this.requestRoom("escort1", "男主线失败重开");
        return true;
    }

    /** 主动重开本轮男主线肉鸽护送（供正式男主线 R / 暂停重开调用，关闭单段 S/L 刷血漏洞）。 */
    restartEscortRun(): void {
        this.resetEscortAttempt();
        this.requestRoom("escort1", "男主线失败重开");
    }

    /**
     * 男主线战斗死亡 / 主动重开本轮：回 escort1 重开本轮护送。
     * 递增轮次并按基础种子派生新一轮随机种子；清材料、武器改制、已拾取物（含敌兵掉落）、
     * 护送破坏记录、分段完成标记与检查点快照；保留 soldier 路线、过门锁存与跨局通关档案。
     */
    private resetEscortAttempt(): void {
        const story = this.run.story;
        const inv = this.run.inventory;
        const prevAttempt = story.talents !== undefined ? Math.max(1, story.talents.attempt) : 1;
        const nextAttempt = prevAttempt + 1;
        const vitBonus = story.talents !== undefined ? (story.talents.ranks.vitality ?? 0) : 0;
        if (vitBonus > 0) {
            this.maxHp = Math.max(3, this.maxHp - vitBonus);
            story.maxHp = this.maxHp;
        }
        story.talents = createStoryTalents(this.run.seed, nextAttempt);
        this.hp = this.maxHp;
        story.hp = this.maxHp;
        story.cp = undefined;
        this.checkpointSnap = undefined;
        story.carry = false;
        this.carryOn = false;
        story.craftedWeapon = "";
        this.equippedWeapon = "standard_gun";
        story.equippedWeapon = "standard_gun";
        story.escortDone = false;
        this.escortDone = false;
        story.segments = {};
        inv.wood = 0;
        inv.bell = 0;
        inv.scrap = 0;
        inv.wedge = 0;
        inv.ammo = 0;
        inv.quickbelt = 0;
        inv.shield = 0;
        inv.pass = 0;
        const taken = this.run.taken;
        const keys = Object.keys(taken);
        let i = 0;
        for (i = 0; i < keys.length; i++) {
            const k = keys[i];
            if (k.indexOf("e2_") === 0 || k.indexOf("e3_") === 0 || k.indexOf("escort") === 0) {
                delete taken[k];
            }
        }
        const propKeys = Object.keys(this.run.props);
        for (i = 0; i < propKeys.length; i++) {
            const pk = propKeys[i];
            if (pk.indexOf("e1_") === 0 || pk.indexOf("e2_") === 0 || pk.indexOf("e3_") === 0
                || pk.indexOf("e4_") === 0 || pk.indexOf("e5_") === 0 || pk.indexOf("field_wedge_") === 0) {
                delete this.run.props[pk];
            }
        }
        this.bracedShield = undefined;
        this.talentModalActive = false;
        this.run.joined = true;
        this.reloadT = 0;
        this.closeReloadPuzzle();
        this.gripping = false;
        this.sessionDirty = true;
        this.flashSet("重整启程 · 第" + nextAttempt + "轮护送", 2.0);
        this.log("男主线重开 · 第" + nextAttempt + "轮回 escort1");
        if (!this.useEscortDeathSummary) {
            this.emit("campaignFailed", {
                room: this.room.key, hp: 0, maxHp: this.maxHp,
                reset: true, to: "escort1", route: this.storyRoute, attempt: nextAttempt,
            });
        }
    }

    /** 引路灯铳的光晕：把命中点附近第二人镇住，推远下一发。 */
    private blindNearby(center: Enemy, radius: number, skipIndex: number): void {
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            if (i === skipIndex) {
                continue;
            }
            const e = this.enemies[i];
            if (!e.alive || Math.abs(e.x - center.x) > radius) {
                continue;
            }
            e.awake = true;
            e.fireCd = Math.max(e.fireCd ?? 0, 150);
            e.warnT = 0;
        }
    }

    private stepEnemies(dt: number, input: Input): void {
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (e.hitT > 0) {
                e.hitT -= dt;
            }
        }
        if (this.coveredFlash > 0) {
            this.coveredFlash -= dt;
        }
        if (this.isCampaign) {
            this.stepCampaignEnemies(dt, input);
            return;
        }
        // 只有城门守点期间敌兵会打人；街道与检查站仍是纯靶子。
        if (this.room.key !== "gate" || this.phase !== "gate-hold") {
            return;
        }
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            if (e.warnT > 0) {
                e.warnT -= 1;
                if (e.warnT <= 0) {
                    this.enemyFire(e, input);
                }
                continue;
            }
            if (e.fireCd > 0) {
                e.fireCd -= 1;
                if (e.fireCd <= 0) {
                    e.warnT = WARN_TICKS;
                }
            } else {
                // 刚出场（fireCd = 0）也要举一次枪，否则第一枪永远等不到。
                e.warnT = WARN_TICKS;
            }
        }
    }

    /** 敌兵开火：掩体、蹲伏或不在射程都能挡下；否则扣一格血。 */
    private enemyFire(e: Enemy, input: Input): void {
        const p = this.player;
        if (Math.abs(e.x - p.x) > ENEMY_RANGE) {
            this.flashSet("枪声响在远处", 0.4);
            e.fireCd = FIRE_COOLDOWN;
            return;
        }
        if (this.blockedShot(e, p)) {
            this.emit("coverBlocked", { entity: "实体遮挡", enemyX: e.x, hp: this.hp });
            e.fireCd = FIRE_COOLDOWN;
            return;
        }
        // 贴靠实体 + 来向 + 主动按 Shift，三件事同时成立才挡；站绞盘空地按 Shift 照吃。
        const cover = this.blockedByCover(e, p);
        const hugging = cover !== undefined;
        this.coverBlocking = hugging;
        const covered = hugging && input.cover.held;
        if (covered) {
            this.coveredFlash = 0.5;
            this.flashSet("掩体挡下", 0.5);
            this.emit("coverBlocked", {
                entity: cover.label === undefined ? "一人高实体" : cover.label,
                enemyX: e.x,
                hp: this.hp,
            });
            e.fireCd = FIRE_COOLDOWN;
            return;
        }
        if (this.invulnT > 0) {
            e.fireCd = FIRE_COOLDOWN;
            return;
        }
        this.invulnT = INVULN_HIT_TICKS;
        this.hp -= 1;
        this.emit("actorHit", { target: "player", amount: 1, hp: this.hp, maxHp: this.maxHp, enemyX: e.x });
        this.flashSet("中弹 " + Math.max(0, this.hp) + "/" + this.maxHp, 0.7);
        e.fireCd = FIRE_COOLDOWN;
        if (this.hp <= 0) {
            this.gateFailed();
        }
    }

    /** 贴着街垒/柜台这类一人高实体、且实体挡在来向上，才算掩体。 */
    private blockedByCover(enemy: Enemy, p: Actor): Box | undefined {
        const b = this.coverAt(p);
        if (b === undefined) {
            return undefined;
        }
        return this.coverGuardsFrom(b, p, enemy) ? b : undefined;
    }

    /** 被击倒：回绞盘，计时、敌兵和角色状态全部重来。 */
    private gateFailed(): void {
        const g = this.room.story === undefined ? undefined : this.room.story.gate;
        this.flashSet("被击倒 · 回绞盘 118，重新就位再守", 2.0);
        this.hp = this.maxHp;
        this.gateTick = 0;
        this.gateSpawned = 0;
        this.enemies = [];
        this.gateFailCount += 1;
        // 回绞盘站位（118 是能贴住绞盘又站得下的点），并要求重新就位：不自动接着计时。
        this.player.x = this.ox + (g === undefined ? 118 : g.winchX);
        this.player.y = 0;
        this.player.vy = 0;
        this.player.depth = 0;
        this.player.depthSpeed = 0;
        this.player.onGround = true;
        this.player.crouch = false;
        this.player.h = SOLDIER_H;
        this.partner.x = this.ox + (g === undefined ? 900 : g.waitX);
        this.partner.y = 0;
        this.partner.vy = 0;
        this.partner.depth = 0;
        this.partner.depthSpeed = 0;
        this.partner.onGround = true;
        this.cam.x = this.player.x;
        this.phase = "gate-idle";
        this.phaseTick = 0;
        this.coverHug = false;
        this.coverBlocking = false;
        this.coverEntity = "";
        this.gateNeedConfirm = true;
        this.gateRestartArmed = false;
        this.emit("gateFailed", { failCount: this.gateFailCount, hp: 0, maxHp: this.maxHp });
    }

    /** 城外：补丁红布车斜停在石阶口，点一次 E 拉开并触发 F01 半秒缝布家庭回忆，台面到石阶的路才通。 */
    private stepRedCart(input: Input): void {
        if (this.redCartMemoryT > 0) {
            this.redCartMemoryT -= 1;
        }
        if (this.room.key !== "outside" || this.redCartPulled) {
            return;
        }
        const box = this.boxes.find((b) => b.id === "outside_red_cart");
        if (box === undefined) {
            this.redCartPulled = true;
            return;
        }
        const cx = (box.x0 + box.x1) * 0.5;
        const p = this.player;
        if (Math.abs(p.x - cx) > 70 || Math.abs(p.y - 96) > 26) {
            return;
        }
        if (!input.interact.pressed) {
            return;
        }
        box.x0 = 430;
        box.x1 = 474;
        // 这辆车原本也堵着台面下的墙根小路：拉开后整辆车挪到空窝，下层一起放开。
        this.cartAxle = this.room.cart.endX;
        this.cartDocked = true;
        this.redCartPulled = true;
        this.redCartMemoryT = 30;
        if (this.run.story !== undefined) {
            this.run.story.segments["outside_cart"] = true;
            this.run.story.segments["outside_memory"] = true;
        }
        this.sessionDirty = true;
        this.flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8);
        this.emit("storyBeat", { beat: "red_cart", x: p.x, room: "outside" });
        this.emit("storyBeat", { beat: "red_cart_memory", x: p.x, room: "outside", durationTicks: 30 });
    }

    private stepInteract(dt: number, input: Input): void {
        const p = this.player;
        this.stepRedCart(input);
        const calmUsed = this.calmConsumed;
        this.calmConsumed = false;
        // 安抚从进入到第 59 拍占用动作：期间 E/D 不抓车、不推车、不转通用敲击。
        const calming = this.escort.state === "calming";
        this.focusCart = false;
        if (this.room.key === "outside") {
            const c = this.room.cart;
            const dx = p.x - (this.cartAxle + c.handleOffset);
            const dy = p.y - c.baseY;
            this.focusCart = !calmUsed && !calming && dx * dx + dy * dy < CART_REACH * CART_REACH;
        }
        // 安抚优先消费当拍 E：同一只 E 不再抓车把。
        if (!calmUsed && !calming) {
            this.stepCart(dt, input);
        }

        // E 先给安抚；同一只 E 不再触发敲木板。
        if (calmUsed) {
            this.flashSet("安抚 · 敲两下", 0.8);
        } else if (!calming && input.interact.pressed && !this.gripping
            && this.room.key !== "village" && this.room.key !== "tower" && this.room.key !== "prologue" && this.room.key !== "gate" && this.room.key !== "museum") {
            if (this.knockT > 0) {
                this.knocks += 1;
            } else {
                this.knocks = 1;
            }
            this.emit("knock", { count: this.knocks, x: p.x, room: this.room.key });
            this.knockT = 1.2;
            if (this.knocks >= 2) {
                this.flashSet("敲两下", 0.8);
                this.knocks = 0;
            } else {
                this.flashSet("敲一下", 0.5);
            }
        } else if (this.knockT > 0) {
            this.knockT -= dt;
            if (this.knockT <= 0) {
                this.knocks = 0;
            }
        }

        // 本地检查点：小满或周戍踩到 kind 0 的标记就提交
        let i = 0;
        for (i = 0; i < this.room.marks.length; i++) {
            const m = this.room.marks[i];
            if (m.kind !== 0) {
                continue;
            }
            const subjects: Actor[] = [this.partner, this.player];
            let k = 0;
            for (k = 0; k < subjects.length; k++) {
                const s = subjects[k];
                if (!s.alive) {
                    continue;
                }
                const dx = s.x - m.x;
                const dy = s.y - m.y;
                if (dx * dx + dy * dy < 26 * 26 && this.checkpoint !== m.x) {
                    this.checkpoint = m.x;
                    this.checkpointCartAxle = this.cartAxle;
                    // 护送段：制前 / 制后各记一份库存、装备与背负，恢复时整份回滚。
                    if (this.isCampaign) {
                        this.captureCheckpoint(m.x);
                    }
                    if (this.room.cart.bodyW > 0) {
                        if (this.cartDocked) {
                            this.flashSet("检查点 · 车已落窝", 1.0);
                        } else {
                            this.flashSet("检查点 · 车还没到位", 1.0);
                        }
                    } else {
                        this.flashSet("检查点", 1.0);
                    }
                }
            }
        }

        this.checkCarryGate();
    }

    /** 村口：拾瓶、蓄力、投掷、拾荒者与通行线。 */
    private stepVillage(dt: number, input: Input): void {
        if (this.room.key !== "village") {
            return;
        }
        const p = this.player;
        const bottle = this.room.bottle;
        const scav = this.room.scavenger;

        // 点 E 拾瓶
        if (!this.hasBottle && bottle !== undefined) {
            const dx = p.x - bottle.x;
            const dy = p.y + p.h * 0.5 - bottle.y;
            if (dx * dx + dy * dy < 56 * 56 && input.interact.pressed) {
                this.hasBottle = true;
                this.flashSet("拾起瓶子", 0.8);
            }
        }

        // 按住 F 瞄，松手才投；右键/取消键清零放弃投掷
        if (this.hasBottle) {
            if (input.bottleCanceled) {
                this.aimHold = 0;
                this.bottleAimX = -1;
            } else if (input.aim.held) {
                this.aimHold += dt;
                if (this.aimHold > 1.2) {
                    this.aimHold = 1.2;
                }
                // 每拍刷新缓存：预览画的就是这个点，松手投的也是这个点。
                const cached = this.bottleEnd();
                this.bottleAimX = cached.x;
                this.bottleAimY = cached.y;
            } else if (input.aim.released) {
                if (this.aimHold < 0.12) {
                    // 原地误点一下不算投：先说清楚要按住瞄准。
                    this.flashSet("按住 F 瞄一下再松手", 0.9);
                    this.aimHold = 0;
                } else {
                    const end = this.bottleAimX >= 0 ? { x: this.bottleAimX, y: this.bottleAimY } : this.bottleEnd();
                    this.throwBottle(end.x, end.y);
                    this.aimHold = 0;
                }
            }
        } else {
            this.aimHold = 0;
            this.bottleAimX = -1;
        }

        // 瓶子飞行：位置按出手时定下的解析轨迹走；t 到固定飞行时长、且在下降，
        // 才算瓶子触及落点表面。落点就是预览缓存的 (targetX, surfaceY)。
        const fly = this.bottleFly;
        if (fly !== undefined) {
            fly.t += dt;
            fly.x = fly.x0 + fly.vx * fly.t;
            fly.y = fly.y0 + fly.vy * fly.t - 0.5 * GRAVITY * fly.t * fly.t;
            const falling = fly.vy - GRAVITY * fly.t <= 0;
            if (fly.t >= BOTTLE_FLY_TIME && falling) {
                this.landBottle(fly);
            }
        }
        if (this.bottleLandT > 0) {
            this.bottleLandT -= dt;
        }

        if (scav !== undefined) {
            this.stepScav(dt, scav);
        }

        const line = this.room.passLine;
        if (line !== undefined && !this.passed && p.x >= line) {
            this.passed = true;
            this.flashSet("过了第一院 · 通行线 440", 1.4);
        }
        // 桌下听脚步：蹲在桌板下时，拾荒者的脚步会随距离变近或变远。
        const underTable = p.crouch && p.x >= this.ox + 304 && p.x <= this.ox + 416;
        if (underTable) {
            this.footHintT -= 1;
            if (this.footHintT <= 0) {
                this.footHintT = 90;
                const scavX = this.scavX;
                const near = Math.abs(scavX - p.x) < 120;
                const walkingAway = this.scavState === "walk" && Math.abs(this.scavTargetX - p.x) >= 120;
                const heard = this.scavState === "chase" || (near && !walkingAway);
                this.flashSet(heard ? "桌下 · 脚步近了，别出声" : "桌下 · 脚步远了，趁现在钻", 1.2);
                this.emit("storyBeat", { beat: heard ? "footstep_near" : "footstep_far", x: p.x, room: "village" });
            }
        } else {
            this.footHintT = 0;
        }
        // 暗渠口：过了第一院、走到 560 就先给蹲下的提示，再钻出到林边。
        if (this.passed && !this.ditchHinted && p.x >= this.ox + 560) {
            this.ditchHinted = true;
            this.flashSet("暗渠口 · 蹲下钻过去", 1.4);
            this.emit("storyBeat", { beat: "ditch", x: p.x, room: "village" });
        }
        // 暗渠口 560–640：站着过不去（院墙前必须蹲下从渠口钻入），与 3D 渠口几何同源。
        const inCulvert = p.x >= this.ox + 560 && p.x <= this.ox + 640;
        if (this.passed && inCulvert && p.crouch && this.wantRoom === "") {
            this.requestRoom("forest", "蹲下钻过暗渠");
            this.flashSet("钻进暗渠 · 北塔森林", 1.4);
        }
    }

    /** 准星点的世界坐标换算成「实际落点」：横向钳位在房间内（防投出屏外负坐标），纵向取该处地面。 */
    private bottleEnd(): { x: number; y: number } {
        const aim = this.worldMapper !== undefined
            ? this.worldMapper(this.aimX, this.aimY)
            : screenToWorld(this.aimX, this.aimY, this.cam, this.view);
        const clampedX = Math.max(this.room.minX + 12, Math.min(this.room.maxX - 12, aim.x));
        const g = this.groundAt(clampedX, aim.y + 240, 3);
        return { x: clampedX, y: g };
    }

    /** 固定飞行时间反解初速；终点就是准星指定的落点，预览与触地用同一套参数。 */
    private throwBottle(tx: number, ty: number): void {
        const p = this.player;
        // 起点朝着目标出手：原地站着把瓶子扔到背后时，弧线不能从身体里穿过去。
        const dir = tx >= p.x ? 1 : -1;
        p.facing = dir;
        const x0 = p.x + dir * 10;
        const y0 = p.y + p.h * 0.7;
        this.bottleTargetX = tx;
        this.bottleTargetY = ty;
        this.bottleSurfaceY = ty;
        const vx = (tx - x0) / BOTTLE_FLY_TIME;
        const vy = (ty - y0 + 0.5 * GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME;
        this.bottleFly = { x: x0, y: y0, x0: x0, y0: y0, vx: vx, vy: vy, t: 0 };
        this.hasBottle = false;
        this.flashSet("投出", 0.4);
        this.emit("bottleThrown", {
            fromX: x0,
            fromY: y0,
            targetX: tx,
            targetY: ty,
            flightTicks: Math.round(BOTTLE_FLY_TIME * 60),
        });
    }

    /** 空村三材质落点判定：软土消音 / 铁盆双响加长驻留 / 砖地常规单响。 */
    private bottleSurfaceAt(x: number): "soft" | "iron" | "brick" {
        if (this.room.softX !== undefined && Math.abs(x - this.room.softX) <= 34) {
            return "soft";
        }
        if (this.room.basinX !== undefined && Math.abs(x - this.room.basinX) <= 24) {
            return "iron";
        }
        return "brick";
    }

    /** 触地：只在这里派发一次声音事件，落点固定用预览缓存，并显式携带材质供前端分轨渲染。 */
    private landBottle(fly: { x: number; y: number; x0: number; y0: number; vx: number; vy: number; t: number }): void {
        const x = this.bottleTargetX >= 0 ? this.bottleTargetX : fly.x;
        const y = this.bottleSurfaceY >= 0 ? this.bottleSurfaceY : fly.y;
        const s = this.room.scavenger;
        const surface = this.bottleSurfaceAt(x);
        const effRange = s === undefined ? 0 : (surface === "iron" ? s.range * 1.25 : s.range);
        const heard = surface !== "soft" && s !== undefined && Math.abs(x - this.scavX) <= effRange;
        const stallTicks = s === undefined ? 0 : (surface === "iron" ? s.stallTicks + 90 : s.stallTicks);
        this.bottleFly = undefined;
        this.bottleTargetX = -1;
        this.bottleTargetY = 0;
        this.bottleSurfaceY = -1;
        this.bottleLandX = x;
        this.bottleLandY = y;
        this.bottleLandT = 0.9;
        this.emit("bottleLanded", {
            x: x,
            y: y,
            surface: surface,
            heard: heard,
            resonance: surface === "iron",
            stallTicks: heard ? stallTicks : 0,
            scavState: this.scavState,
        });
        this.hearBottle(x, surface);
    }

    /** 落地才结算听觉：软土消音不惊动，砖面单响常规驻留，铁盆余振两响加长驻留。 */
    private hearBottle(x: number, surface: "soft" | "iron" | "brick" = "brick"): void {
        const s = this.room.scavenger;
        if (s === undefined) {
            return;
        }
        if (surface === "soft") {
            this.flashSet("落在软土 · 没出声", 0.8);
            return;
        }
        const effRange = surface === "iron" ? s.range * 1.25 : s.range;
        if (Math.abs(x - this.scavX) > effRange) {
            this.flashSet("落地 · 他没听见", 0.6);
            return;
        }
        this.scavState = "turn";
        this.scavT = s.hearTicks;
        this.scavTargetX = surface === "iron" && this.room.basinX !== undefined ? this.room.basinX : x;
        this.scavStallBonus = surface === "iron" ? 90 : 0;
        this.flashSet(surface === "iron" ? "铁盆余振两响 · 他停下来细听" : "砖地一响 · 他转头", 1.1);
    }

    /** 拾荒者：巡逻 → 转头 18 拍 → 赶到落点 → 停 120 拍（铁盆 210 拍） → 走回巡逻段。 */
    private stepScav(dt: number, s: ScavSpec): void {
        // 追逐由 stepScavChase 单独推进；这里只管巡查与「听见后过去看看」。
        if (this.scavState === "chase") {
            return;
        }
        if (this.scavState === "turn") {
            this.scavT -= 1;
            if (this.scavT <= 0) {
                this.scavState = "walk";
            }
            return;
        }
        if (this.scavState === "walk") {
            const d = this.scavTargetX - this.scavX;
            if (Math.abs(d) < 4) {
                this.scavState = "stall";
                this.scavT = s.stallTicks + this.scavStallBonus;
                this.scavStallBonus = 0;
                return;
            }
            this.scavX += (d > 0 ? 1 : -1) * s.approachSpeed * dt;
            return;
        }
        if (this.scavState === "stall") {
            this.scavT -= 1;
            if (this.scavT <= 0) {
                this.scavState = "back";
            }
            return;
        }
        if (this.scavState === "back") {
            const home = Math.max(s.x0, Math.min(s.x1, this.scavX));
            if (Math.abs(home - this.scavX) < 2) {
                this.scavState = "patrol";
                return;
            }
            this.scavX += (home > this.scavX ? 1 : -1) * s.approachSpeed * dt;
            return;
        }
        this.scavX += this.scavDir * s.patrolSpeed * dt;
        if (this.scavX >= s.x1) {
            this.scavX = s.x1;
            this.scavDir = -1;
        } else if (this.scavX <= s.x0) {
            this.scavX = s.x0;
            this.scavDir = 1;
        }
    }

    /**
     * 车把：E 抓住，A/D 推拉，松手立即停；到端位写 dock。
     * 人跟着车把一起走，走不动就脱手。
     */
    private stepCart(dt: number, input: Input): void {
        const p = this.player;
        const c = this.room.cart;

        if (this.gripping) {
            if (!input.interact.held) {
                this.gripping = false;
                this.flashSet("松开车把", 0.4);
                return;
            }
        } else {
            if (!input.interact.pressed) {
                return;
            }
            if (!this.cartHandleInReach(p)) {
                return;
            }
            const track = c.depth ?? 0;
            if (this.limitDepth(p, track) !== track) {
                return;
            }
            p.depth = track;
            p.depthSpeed = 0;
            this.gripping = true;
            this.flashSet("握住车把", 0.4);
            return;
        }

        if (this.cartDocked) {
            return;
        }
        const dir = input.moveX;
        if (dir === 0) {
            return;
        }
        const lo = Math.min(c.startX, c.endX);
        const hi = Math.max(c.startX, c.endX);
        let next = this.cartAxle + dir * CART_SPEED * dt;
        if (next < lo) {
            next = lo;
        }
        if (next > hi) {
            next = hi;
        }
        const delta = next - this.cartAxle;
        if (delta === 0) {
            return;
        }
        this.cartAxle = next;
        p.x += delta;
        p.facing = dir > 0 ? 1 : -1;
        this.slideX(p, 0);
        if (Math.abs(p.x - (this.cartAxle + c.handleOffset)) > CART_REACH) {
            this.gripping = false;
            this.flashSet("跟不上了，脱手", 0.6);
            return;
        }
        if (Math.abs(this.cartAxle - c.endX) < 0.01) {
            this.cartDocked = true;
            this.gripping = false;
            this.emit("cartDocked", { axle: this.cartAxle, playerX: p.x, room: this.room.key });
            this.flashSet("车轮落窝", 1.2);
        } else if (Math.abs(this.cartAxle - c.startX) < 0.01) {
            this.flashSet("车轮回到起点", 0.5);
        }
    }

    /**
     * 请求切房：模拟步只登记意图，真正的 ensurePlay 在 app 的步循环之后。
     * 事件让前端在切房前就能停掉旧房间的事件与音效。
     */
    private requestRoom(key: string, reason: string): void {
        // 一帧补跑多步时，出口条件会在每一步都成立。已有登记就不再发第二条，
        // 真正换实例由 app 的步循环后统一处理。
        if (this.wantRoom !== "") {
            return;
        }
        this.wantRoom = key;
        this.emit("roomChange", { from: this.room.key, to: key, reason: reason });
    }

    /**
     * 切场条件：检查站要车落窝且两人都在出口区；城外要洞后检查点已提交并再往右跨到 388。
     * D3 用明确的开发切场点，D4 再接墙根小路与地图加宽。
     */
    private checkCarryGate(): void {
        if (this.room.key === "checkpoint") {
            if (this.gateOpen && this.player.x >= this.ox + 900) {
                this.carryCartAxle = this.cartAxle;
                this.carryCartDocked = this.cartDocked;
                this.requestRoom("gate", "检查站出口");
                this.flashSet("出检查站 · 城门", 1.2);
            }
            return;
        }
        if (this.room.key === "outside") {
            // 周戍 88 高过不了 44 的拱，切场由被护送的小满触发。
            // D4 起 388 只是「进墙根小路」，要把 640 走完（石阶 700–820、塔灯 1120）才进村口。
            if (this.checkpoint >= 380 && this.player.x >= WALL_ROAD_END) {
                this.carryCartAxle = this.cartAxle;
                this.carryCartDocked = this.cartDocked;
                this.requestRoom("village", "墙根走完");
                this.flashSet("墙根走完 · 进村口", 1.2);
            }
        }
    }

    /** 点射：从枪口到准星拉一条线，命中最近的敌人；被实体挡住则打空。 */
    /** 把准星世界坐标换算成 aimX/aimY；只在回放与调试里用。 */
    aimAt(wx: number, wy: number): void {
        const s = worldToScreen(wx, wy, this.cam, this.view);
        this.aimX = s.x;
        this.aimY = s.y;
    }

    private shoot(a: Actor): void {
        if (this.isCampaign && this.reloadT > 0) {
            this.flashSet("装填中 · 等枪机复位", 0.35);
            return;
        }
        const ox = a.x + a.facing * 8;
        const muzzleY = a.y + a.h * 0.72;
        const oy = muzzleY + a.depth * DEPTH_Y_SCALE;
        // 先按准星可见的投影选择尝试命中的目标，再在场景中检测实体是否挡住这条线。
        const aim = this.worldMapper !== undefined
            ? this.worldMapper(this.aimX, this.aimY)
            : screenToWorld(this.aimX, this.aimY, this.cam, this.view);
        let dx = aim.x - ox;
        let dy = aim.y - oy;
        const len = Math.sqrt(dx * dx + dy * dy);
        if (len < 0.001) {
            dx = a.facing;
            dy = 0;
        } else {
            dx = dx / len;
            dy = dy / len;
        }
        if (dx !== 0) {
            a.facing = dx > 0 ? 1 : -1;
        }

        const ray = { x: ox, y: oy, dx, dy };
        const hitEnemy = this.raycastEnemies(ray);
        const tEnemy = hitEnemy.t;
        const targetDepth = tEnemy > 0.001 ? (this.enemies[hitEnemy.index].depth ?? 0) : a.depth;
        const dDepth = tEnemy > 0.001 ? (targetDepth - a.depth) / tEnemy : 0;
        const solid = this.raycastSolid({ ...ray, y: muzzleY, dy: dy - dDepth * DEPTH_Y_SCALE, depth: a.depth, dDepth });
        const tWall = solid.t;
        // 画盘效果 + 已装备武器：只有引路灯铳能把线照透，只有回声铳能惊起两处声源。
        const rawEffect = this.consumeReloadEffect();
        const weaponFx = weaponEffectOf(this.equippedWeapon);
        const reloadEffect: ReloadEffect = rawEffect;
        // 基础灯纹（任意枪）都能把线照透掩体；引路灯铳在此基础上多一圈光晕，镇住旁边的第二人。
        const hit = tEnemy >= 0 && (tWall < 0 || tEnemy <= tWall || reloadEffect === "light");
        const t = hit ? tEnemy : (tWall >= 0 ? tWall : 700);

        this.trace = { x0: ox, y0: oy, x1: ox + dx * t, y1: oy + dy * t, hit: hit };
        this.traceT = 0.12;
        this.applyFireDanger(ox);
        let killed = false;
        if (hit) {
            const i = hitEnemy.index;
            const e = this.enemies[i];
            const impactY = oy + dy * tEnemy;
            const fromFront = (a.x < e.x && dx > 0) || (a.x > e.x && dx < 0);
            const shieldTop = e.y + (e.depth ?? 0) * DEPTH_Y_SCALE + 64;
            if (e.kind === "shield" && (e.shieldHp ?? 0) > 0 && fromFront && impactY <= shieldTop) {
                const pushRank = this.talentRank("push_force");
                const dmg = reloadEffect === "push" ? (2 + pushRank) : 1;
                e.shieldHp = Math.max(0, (e.shieldHp ?? 0) - dmg);
                e.hitT = 0.3;
                if (reloadEffect === "push") {
                    const kb = 46 + 24 * pushRank;
                    e.x = Math.max(this.room.minX + 20, Math.min(this.room.maxX - 20, e.x + a.facing * kb));
                    if (pushRank > 0) {
                        this.staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i);
                    }
                    this.emit("reloadApplied", { effect: "push", weapon: this.equippedWeapon, enemyX: e.x });
                    this.flashSet(e.shieldHp <= 0 ? "推退破盾！" : "推退震退持盾手", 0.9);
                } else {
                    this.flashSet("盾面挡下 · 盾 " + e.shieldHp + "/" + (e.shieldHpMax ?? 2), 0.8);
                }
                this.emit("shotResolved", {
                    hit: true, enemyIndex: i, enemyX: e.x, aimX: aim.x, aimY: aim.y,
                    impactX: ox + dx * t, impactY: oy + dy * t, shield: true,
                });
                this.beginReload();
                return;
            }
            e.alive = false;
            e.hitT = 0.4;
            killed = true;
            this.flashSet("命中", 0.6);
            this.dropFor(e);
            const lpRank = this.talentRank("lantern_pierce");
            if (reloadEffect === "light" && (weaponFx === "light" || lpRank > 0)) {
                const blindRadius = (weaponFx === "light" ? 160 : 110) + 50 * lpRank;
                this.blindNearby(e, blindRadius, i);
            }
            if (reloadEffect === "push") {
                const pushRank = this.talentRank("push_force");
                e.x += a.facing * (46 + 24 * pushRank);
                if (pushRank > 0) {
                    this.staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i);
                }
                this.emit("reloadApplied", { effect: "push", weapon: this.equippedWeapon, enemyX: e.x });
            } else if (reloadEffect === "echo") {
                const echoRank = this.talentRank("echo_wide");
                this.echoToSource(a, (weaponFx === "echo" ? 2 : 1) + echoRank, 60 + 30 * echoRank);
                this.emit("reloadApplied", { effect: "echo", weapon: this.equippedWeapon, enemyX: e.x });
            } else if (reloadEffect === "light") {
                this.emit("reloadApplied", { effect: "light", weapon: this.equippedWeapon, enemyX: e.x });
            }
        } else if (solid.box !== undefined && solid.box.breakable !== undefined) {
            this.damageProp(solid.box, 1);
        } else {
            this.flashSet("打空", 0.35);
        }
        if (this.isCampaign) {
            this.beginReload();
        }
        this.emit("shotResolved", {
            hit: hit,
            enemyIndex: hit ? hitEnemy.index : -1,
            enemyX: hit ? this.enemies[hitEnemy.index].x : -1,
            aimX: aim.x,
            aimY: aim.y,
            impactX: ox + dx * t,
            impactY: oy + dy * t,
        });
    }

    /** 「劲推」震荡波：将命中点周边敌兵震退并压缓其下一次举铳。 */
    private staggerNearby(center: Enemy, radius: number, delayTicks: number, skipIndex: number): void {
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            if (i === skipIndex) {
                continue;
            }
            const e = this.enemies[i];
            if (!e.alive || Math.abs(e.x - center.x) > radius) {
                continue;
            }
            e.warnT = 0;
            e.fireCd = Math.max(e.fireCd ?? 0, delayTicks);
            const pushDir = e.x >= center.x ? 1 : -1;
            e.x = Math.max(this.room.minX + 20, Math.min(this.room.maxX - 20, e.x + pushDir * 22));
        }
    }

    /** 把一次开火派发成危险事件；是否真的吓到她由 childExposed 判。 */
    private applyFireDanger(shotX: number): void {
        const isStorySc = this.isCampaign && this.run.joined
            && (this.room.campaign?.chapter === "S" || this.room.campaign?.chapter === "C");
        if ((this.room.key !== "checkpoint" && !isStorySc) || !this.partner.alive) {
            return;
        }
        let dangerX = shotX;
        let best = -1;
        let bestD = 1e9;
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            const d = Math.abs(e.x - this.partner.x);
            if (d < bestD) {
                bestD = d;
                best = i;
            }
        }
        if (best >= 0) {
            dangerX = this.enemies[best].x;
        }
        // S1–C2 战役房仅在近距交火波及小满身侧（<260）时累积惊惧，避免远距对射频繁打断节奏。
        if (isStorySc && Math.abs(dangerX - this.partner.x) > 260) {
            return;
        }
        const exposed = this.childExposed(dangerX);
        const before = this.escort.fear;
        const dangerId = this.nextDangerId;
        const after = this.escort.applyDanger(dangerId, exposed, this.partner.x);
        this.nextDangerId += 1;
        this.emit("fearChanged", { fear: after, max: FEAR_MAX, exposed: exposed, dangerId: dangerId });
        if (after > before) {
            this.flashSet(`小满受惊 ${after}/${FEAR_MAX}`, 1.0);
        } else if (!exposed) {
            this.flashSet("枪声没够到她", 0.5);
        }
    }

    /** 有效危险：柜台后不算、危险段外不算、周戍挡在中间不算。 */
    private childExposed(dangerX: number): boolean {
        const c = this.partner;
        if (!c.alive) {
            return false;
        }
        if (c.x > this.ox + 240 && c.x < this.ox + 340 &&
            this.boxes.some(b => b.x0 === this.ox + 240 && overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF))) {
            return false;
        }
        if (c.x < this.ox + 380 || c.x > this.ox + 560) {
            return false;
        }
        const toDanger = dangerX - c.x;
        const toPlayer = this.player.x - c.x;
        if (toDanger * toPlayer > 0 && Math.abs(toPlayer) < Math.abs(toDanger) &&
            inReachDepth(this.player.depth, c.depth)) {
            return false;
        }
        return true;
    }

    /** 对准画面上的角色，包括站在不同纵深的目标。 */
    private raycastEnemies(ray: Ray): { t: number; index: number } {
        let best = -1;
        let bestI = -1;
        for (let i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            const y = e.y + (e.depth ?? 0) * DEPTH_Y_SCALE;
            const t = hitBox(ray, { x0: e.x - e.w / 2, x1: e.x + e.w / 2, y0: y, y1: y + e.h });
            if (t >= 0 && (best < 0 || t < best)) {
                best = t;
                bestI = i;
            }
        }
        return { t: best, index: bestI };
    }

    private raycastWorld(ray: Ray): number {
        return this.raycastSolid(ray).t;
    }

    /** 命中最近的实体，并把那件实体带回来，供破坏与挡弹归属。 */
    private raycastSolid(ray: Ray): { t: number; box?: Box } {
        let best = -1;
        let bestBox: Box | undefined = undefined;
        for (const box of this.boxes) {
            if (box.broken === true || box.hidden === true) {
                continue;
            }
            // 2.5D：挡弹判定交给 hitBox 做完整三轴求交（含纵深区间）。
            // 不能在这里只拿射线起点档位做前置过滤：射线从近侧档打向远侧档时，
            // 起点与挡物档位不重叠、但射线末端真实穿过挡物，提前 continue 会漏挡。
            const t = hitBox(ray, box);
            // 起点已经落在挡物内部（贴身开火）不算遮挡，否则会把自己站的那块板当墙。
            if (t > 2 && (best < 0 || t < best)) {
                best = t;
                bestBox = box;
            }
        }
        if (ray.dy < 0) {
            const t = -ray.y / ray.dy;
            if (t >= 0 && (best < 0 || t < best)) {
                best = t;
                bestBox = undefined;
            }
        }
        return { t: best, box: bestBox };
    }

    /** 命中敌人后的掉落：盾完整掉残盾，破障手掉木楔，火器手掉弹包。 */
    private dropFor(e: Enemy): void {
        if (!this.isCampaign || e.drop === undefined || e.drop === "none") {
            return;
        }
        if (e.drop === "shield" && (e.shieldHp ?? 0) <= 0) {
            return;
        }
        const label = e.drop === "shield" ? "残盾" : (e.drop === "wedge" ? "木楔" : (e.drop === "ammo" ? "备用弹包" : e.drop));
        this.pickups.push({
            id: this.room.key + "_drop_" + (e.squad ?? 0), kind: e.drop, x: e.x, y: e.y,
            depth: e.depth, label: label + " ×1",
        });
        this.log("掉落 " + label);
    }

    /** 破坏物掉血；归零就同拍撤掉碰撞、遮挡与挡弹。 */
    private damageProp(b: Box, amount: number): void {
        if (b.breakable === undefined || b.broken === true) {
            return;
        }
        b.breakable.hp -= amount;
        if (b.breakable.hp > 0) {
            this.flashSet(b.breakable.kind === "thin_wood" ? "薄木挡裂开 · 再一下" : "围挡松了 · 再一下", 0.9);
            this.emit("propBroken", { id: b.id ?? "", phase: "crack", hp: b.breakable.hp, x: b.x0 });
            return;
        }
        b.broken = true;
        for (const other of this.boxes) {
            if (other.id !== undefined && other.id === b.id) {
                other.broken = true;
            }
        }
        this.run.props[b.id ?? ""] = { broken: true, hp: 0, wedge: false };
        this.flashSet(b.breakable.kind === "thin_wood" ? "薄木挡碎了 · 通路打开" : "空筐散了 · 短口打开", 1.2);
        this.log("破坏 " + (b.id ?? "") + " " + b.breakable.kind);
        this.emit("propBroken", { id: b.id ?? "", phase: "broken", hp: 0, x: b.x0 });
    }

    /** 地面前后位移；有体积的道具拦住穿入，纯装饰和单向平台放行。 */
    private slideDepth(a: Actor, distance: number): void {
        a.depth = this.limitDepth(a, a.depth + distance);
    }

    private limitDepth(a: Actor, target: number): number {
        const road = this.room.depth;
        if (road === undefined || target === a.depth) {
            return a.depth;
        }
        let next = Math.max(road.min, Math.min(road.max, target));
        const half = a.w / 2;
        for (const b of this.boxes) {
            const footprint = b.depth;
            if (footprint === undefined || b.passable === true ||
                b.broken === true || b.hidden === true || b.soft === true ||
                a.x + half <= b.x0 || a.x - half >= b.x1 ||
                a.y + a.h <= b.y0 + 0.001 || a.y >= b.y1 - 0.001) {
                continue;
            }
            const front = footprint.min - ACTOR_DEPTH_HALF;
            const back = footprint.max + ACTOR_DEPTH_HALF;
            if (a.depth <= front && next > front) {
                next = front;
            } else if (a.depth >= back && next < back) {
                next = back;
            }
        }
        return next;
    }

    /** 城外低拱中仍被车底挡栓占据的世界矩形。车轮落窝后挡栓收起。 */
    cartLatchBounds(): Rect.Type | undefined {
        if (this.room.key !== "outside" || this.cartDocked) return undefined;
        const arch = this.room.arch;
        const halfWidth = this.room.cart.bodyW / 2;
        const left = Math.max(arch.x0, this.cartAxle - halfWidth);
        const right = Math.min(arch.x1, this.cartAxle + halfWidth);
        return right > left ? Rect(left, arch.y, right - left, arch.h) : undefined;
    }

    /** 水平位移 + 实体/拱洞阻挡。 */
    private slideX(a: Actor, dx: number): void {
        let nx = a.x + dx;
        const half = a.w / 2;
        const room = this.room;
        nx = Math.max(room.minX + half, Math.min(room.maxX - half, nx));
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.passable === true || b.broken === true || b.hidden === true || b.soft === true) {
                continue;
            }
            if (!overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF)) {
                continue;
            }
            if (a.y + a.h <= b.y0 + 0.001 || a.y >= b.y1 - 0.001) {
                continue;
            }
            if (nx + half > b.x0 && nx - half < b.x1) {
                if (a.x <= b.x0) {
                    nx = b.x0 - half;
                } else if (a.x >= b.x1) {
                    nx = b.x1 + half;
                } else {
                    nx = a.x;
                }
            }
        }
        const latch = this.cartLatchBounds();
        if (latch !== undefined && a.y < latch.y + latch.height - 0.001
            && nx + half > latch.x && nx - half < latch.x + latch.width) {
            if (a.x <= latch.x) {
                nx = latch.x - half;
            } else if (a.x >= latch.x + latch.width) {
                nx = latch.x + latch.width + half;
            } else {
                nx = a.x;
            }
        }
        // 拱洞（低洞）：身高超出净空就进不去。
        // 已经在洞里的人（例如蹲着进来后站起来）允许朝任一侧走出去，
        // 否则会被永久卡在洞内。
        // 只有脚底低于拱顶时才会被拱口挡；站在上层台面（y=96）时拱洞在脚下，不该拦人。
        const arch = room.arch;
        if (arch.h > 0 && a.y < arch.y + arch.h - 0.001 && a.y + a.h > arch.y + arch.h + 0.001) {
            const insideNow = a.x > arch.x0 && a.x < arch.x1;
            if (!insideNow && nx + half > arch.x0 && nx - half < arch.x1) {
                if (a.x <= arch.x0) {
                    nx = arch.x0 - half;
                } else if (a.x >= arch.x1) {
                    nx = arch.x1 + half;
                }
            }
        }
        a.x = nx;
    }

    /** 垂直位移：重力、落地、撞头。 */
    private fallY(a: Actor, dt: number): void {
        a.vy -= GRAVITY * dt;
        if (a.vy < -900) {
            a.vy = -900;
        }
        let ny = a.y + a.vy * dt;
        const half = a.w / 2;
        if (a.vy <= 0) {
            // 站在地上且未下蹲时多探 24 单位：矮台阶（每级 16–22）直接走上去，下蹲穿行不误爬单向梯，柜台 44/台面 96 仍要跳。
            const reach = a.onGround && !a.crouch ? STEP_UP : 0;
            const ground = this.groundAt(a.x, a.y + 0.5 + reach, half, a.depth);
            if (ny <= ground) {
                ny = ground;
                a.vy = 0;
                a.onGround = true;
            } else {
                a.onGround = false;
            }
        } else {
            a.onGround = false;
            let i = 0;
            for (i = 0; i < this.boxes.length; i++) {
                const b = this.boxes[i];
                if (b.passable === true || b.broken === true || b.hidden === true || b.soft === true) {
                    continue;
                }
                if (!overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF)) {
                    continue;
                }
                if (a.x + half <= b.x0 || a.x - half >= b.x1) {
                    continue;
                }
                if (b.y0 >= a.y + a.h - 0.5 && ny + a.h > b.y0) {
                    ny = b.y0 - a.h;
                    a.vy = 0;
                }
            }
        }
        a.y = ny;
    }

    /** 当前 x 处、不高于 ceiling 的最高落脚面。 */
    private groundAt(x: number, ceiling: number, half: number, depth: number = 0): number {
        let g = -9999;
        let i = 0;
        for (i = 0; i < this.floors.length; i++) {
            const f = this.floors[i];
            if (x + half > f.x0 && x - half < f.x1 && f.y1 <= ceiling && f.y1 > g) {
                g = f.y1;
            }
        }
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.broken === true || b.hidden === true || b.soft === true) {
                continue;
            }
            if (x + half > b.x0 && x - half < b.x1 && b.y1 <= ceiling && b.y1 > g &&
                overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF)) {
                g = b.y1;
            }
        }
        return g;
    }

    private updateCamera(dt: number): void {
        const p = this.player;
        const tx = p.x + p.facing * 30;
        const ty = p.y + CAM_LOOK_UP;
        const k = Math.min(1, CAM_FOLLOW * dt);
        this.cam.x = this.cam.x + (tx - this.cam.x) * k;
        this.cam.y = this.cam.y + (ty - this.cam.y) * k;
    }

    /** 相机按画布尺寸钳制，保证看不到房间外。由绘制前调用。 */
    clampCamera(w: number, h: number): void {
        const room = this.room;
        const halfW = (LOGIC_W * UNITS_PER_PX) / 2;
        const spanX = room.maxX - room.minX;
        if (spanX <= halfW * 2) {
            this.cam.x = (room.minX + room.maxX) / 2;
        } else {
            this.cam.x = Math.max(room.minX + halfW, Math.min(room.maxX - halfW, this.cam.x));
        }
        // 竖向：主地面固定在画布下部，房间更高时不再额外抬高相机。
        const camY = (LOGIC_H / 2 - GROUND_PX) * UNITS_PER_PX;
        const spanY = room.height;
        const halfH = (LOGIC_H * UNITS_PER_PX) / 2;
        if (spanY <= halfH * 2) {
            this.cam.y = camY;
        } else {
            this.cam.y = Math.max(camY, Math.min(camY + (spanY - halfH * 2), this.cam.y));
        }
    }

    private flashSet(text: string, t: number): void {
        this.flash = text;
        this.flashT = t;
    }

    /** 一行状态文字。 */
    statusText(): string {
        const p = this.player;
        const parts: string[] = [];
        const who = this.childMode ? "小满" : "周戍";
        parts.push(who + " x=" + Math.round(p.x) + " y=" + Math.round(p.y));

        if (this.room.key === "prologue") {
            parts.push("小满 " + Math.round(this.partner.x));
            if (this.phase === "prologue-wake") {
                parts.push("叫醒 " + this.introTick + "/" + PROLOGUE_WAKE_TICKS);
            } else if (this.phase === "prologue-shadow") {
                parts.push("墙影 " + this.introTick + "/" + PROLOGUE_SHADOW_TICKS);
            } else if (this.phase === "prologue-escape") {
                parts.push("逃柜 剩 " + this.escapeRemaining.toFixed(1) + "s");
            } else if (this.phase === "prologue-hide") {
                parts.push("入柜 " + this.introTick + "/" + PROLOGUE_HIDE_TICKS);
            } else if (this.phase === "prologue-wait") {
                parts.push("待递 " + Math.round(Math.abs(p.x - this.partner.x)));
            } else if (this.phase === "prologue-give") {
                parts.push("递物 " + this.phaseTick + "/" + PROLOGUE_GIVE_TICKS);
            } else {
                parts.push("跟随");
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }
        if (this.room.key === "street") {
            parts.push("敌 " + this.aliveEnemies() + "/" + this.enemies.length);
            parts.push("小满 " + Math.round(this.partner.x));
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }
        if (this.room.key === "gate") {
            const g = this.room.story === undefined ? undefined : this.room.story.gate;
            if (g !== undefined) {
                parts.push(this.gateLabel());
                parts.push("守点 " + this.gateTick + "/" + g.holdTicks
                    + " · 剩 " + Math.max(0, Math.ceil((g.holdTicks - this.gateTick) / 60)) + " 秒");
                parts.push("小满 " + Math.round(this.partner.x));
                parts.push("敌 " + this.aliveEnemies() + "/" + this.enemies.length);
                parts.push("血 " + Math.max(0, this.hp) + "/" + this.maxHp);
                parts.push(this.coverHug ? "掩体 已贴住" : (this.coverNear ? "掩体 可贴·按 Shift" : "掩体 无"));
                if (this.gateFailCount > 0) {
                    parts.push("倒 " + this.gateFailCount);
                }
                if (this.flash !== "") {
                    parts.push(this.flash);
                }
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }
        if (this.room.key === "forest") {
            parts.push(p.crouch ? "蹲" : "站");
            parts.push("狗 " + this.dogLabel() + " @" + Math.round(this.dogX));
            parts.push("距 " + Math.round(Math.abs(p.x - this.dogX)));
            if (this.caughtT > 0) {
                parts.push("复位中");
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }
        if (this.room.key === "tower") {
            if (this.phase === "tower-wait") {
                parts.push("门前 " + Math.round(Math.abs(p.x - this.doorXOf())));
            } else if (this.phase === "tower-knock") {
                parts.push("敲 " + this.phaseTick + " 拍");
            } else if (this.phase === "tower-enter") {
                parts.push("跨门槛 " + Math.round(p.x - (this.ox + TOWER_THRESHOLD_X)));
            } else if (this.phase === "tower-desk") {
                parts.push("交物 " + this.deskHold + "/" + TOWER_HANDOVER_TICKS);
            } else if (this.phase === "tower-given") {
                parts.push("递交 " + this.phaseTick);
            } else {
                parts.push("片尾");
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }
        if (this.room.key === "village") {
            parts.push(p.crouch ? "蹲" : "站");
            if (this.hasBottle) {
                parts.push("有瓶");
            } else if (this.bottleFly !== undefined) {
                parts.push("瓶在飞");
            } else {
                parts.push("空手");
            }
            parts.push("拾荒者 " + this.scavLabel() + " @" + Math.round(this.scavX));
            if (this.scavChase) {
                parts.push("追 " + this.scavSee);
            }
            if (this.passed) {
                parts.push("已过通行线");
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }

        const isChild = this.childMode;
        if (isChild) {
            parts.push(p.crouch ? "蹲" : "站");
            parts.push("高 " + Math.round(p.h));
            parts.push("车轴 " + Math.round(this.cartAxle));
        } else {
            parts.push(p.covered ? "贴掩体" : "无掩体");
            if (p.rollT > 0) {
                parts.push("翻滚中");
            }
            parts.push("敌 " + this.aliveEnemies() + "/" + this.enemies.length);
            parts.push("车轴 " + Math.round(this.cartAxle));
            parts.push(this.gateOpen ? "出口开" : "出口关");
            parts.push("恐惧 " + this.escort.fear + "/" + FEAR_MAX);
        }
        if (this.checkpoint >= 0) {
            parts.push("检查点 " + Math.round(this.checkpoint));
        }
        if (this.paused) {
            parts.push("已暂停");
        }
        return parts.join(" · ");
    }

    /** 还活着的敌兵数。 */
    private aliveEnemies(): number {
        let n = 0;
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            if (this.enemies[i].alive) {
                n += 1;
            }
        }
        return n;
    }

    /** 城门阶段的中文短标签。 */
    /** 有存活敌兵正在举枪（warnT 已走）就返回真。 */
    private threatened(): boolean {
        for (let i = 0; i < this.enemies.length; i += 1) {
            const e = this.enemies[i];
            if (e.alive && e.warnT > 0) {
                return true;
            }
        }
        return false;
    }

    private gateSecondsLeft(): number {
        const g = this.room.story === undefined ? undefined : this.room.story.gate;
        if (g === undefined) {
            return 0;
        }
        return Math.max(0, Math.ceil((g.holdTicks - this.gateTick) / 60));
    }

    gateLabel(): string {
        if (this.phase === "gate-idle") {
            return "待就位";
        }
        if (this.phase === "gate-hold") {
            return "守点中";
        }
        if (this.phase === "gate-send") {
            return "送别";
        }
        if (this.phase === "gate-farewell") {
            return "嘱咐 " + this.phaseTick;
        }
        if (this.phase === "gate-count") {
            return "数数 " + this.countTick;
        }
        return "她走";
    }

    /** 狗状态的中文短标签。 */
    dogLabel(): string {
        if (this.dogState === "ear") {
            return "转耳";
        }
        if (this.dogState === "chase") {
            return "追";
        }
        if (this.dogState === "sniff") {
            return "停";
        }
        if (this.dogState === "back") {
            return "回线";
        }
        return "巡逻";
    }

    private doorXOf(): number {
        const t = this.room.story === undefined ? undefined : this.room.story.tower;
        return t === undefined ? 0 : t.doorX;
    }

    /** 拾荒者状态的中文短标签。 */
    scavLabel(): string {
        if (this.scavState === "chase") {
            return "追";
        }
        if (this.scavState === "turn") {
            return "转头";
        }
        if (this.scavState === "walk") {
            return "赶来";
        }
        if (this.scavState === "stall") {
            return "停住";
        }
        if (this.scavState === "back") {
            return "回位";
        }
        return "巡逻";
    }

    /** 一行提示文字。 */
    hintText(): string {
        if (this.paused) {
            return "Esc 继续 · R 重置";
        }
        // 守点中的主提示不能被「第 n 批敌兵出现」「中弹」这类 flash 抢走：
        // 玩家此刻最需要知道的是挡枪与开火，短反馈改由状态行承担。
        if (this.room.key === "gate" && this.phase === "gate-hold" && !this.paused) {
            if (this.threatened()) {
                return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他";
            }
            if (this.coverHug) {
                return "掩体中 · F 射击 · 守点剩 " + this.gateSecondsLeft() + " 秒";
            }
            if (this.coverNear) {
                return "贴住了，按住 Shift 才挡枪 · F 射击";
            }
            return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒";
        }
        if (this.flash !== "") {
            return this.flash;
        }
        if (this.room.key === "prologue") {
            if (this.phase === "prologue-wake") {
                return "父亲在门外唤 · 小满睁眼";
            }
            if (this.phase === "prologue-shadow") {
                return "墙上两道人影 · 碗滚到脚边";
            }
            if (this.phase === "prologue-escape") {
                return "按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " + this.escapeRemaining.toFixed(1) + " 秒";
            }
            if (this.phase === "prologue-hide") {
                return "柜门合上 · 屏住呼吸";
            }
            if (this.phase === "prologue-wait") {
                const near = Math.abs(this.player.x - this.partner.x) <= 46;
                return near ? "点 E 递出针套 · 纸条一起塞进去" : "走到倒柜后的小满身边（x≈214）再点 E";
            }
            if (this.phase === "prologue-give") {
                return "递物 " + this.phaseTick + " / " + PROLOGUE_GIVE_TICKS + " 拍 · 站着别动";
            }
            return "她跟着你了 · 两人一起走到门口 680";
        }
        if (this.room.key === "street") {
            if (this.aliveEnemies() > 0) {
                return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去";
            }
            return "清完了 · 两人一起走到右边检查站入口 900";
        }
        if (this.room.key === "gate") {
            const g = this.room.story === undefined ? undefined : this.room.story.gate;
            if (g !== undefined) {
                if (this.phase === "gate-idle") {
                    if (this.gateNeedConfirm) {
                        return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算";
                    }
                    return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点";
                }
                if (this.phase === "gate-hold") {
                    if (this.coveredFlash > 0) {
                        return "掩体挡下了这一枪 · 别露头";
                    }
                    return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E";
                }
                if (this.phase === "gate-send") {
                    return "去门边 860 按 E 送别 · 她已经站在门口";
                }
                if (this.phase === "gate-farewell") {
                    return "城门送别 · 嘱咐她慢慢数到二十";
                }
                if (this.phase === "gate-count") {
                    if (this.countTick >= GATE_COUNT_END) {
                        return this.countPrevMove > 0 ? "先松开方向键，再按 D" : "按 D · 让她迈出第一步";
                    }
                    return "数到二十 " + this.countTick + " / 1440 拍 · 门正在关";
                }
                return "她自己走 · 跟着出城门 1120";
            }
        }
        if (this.room.key === "forest") {
            if (this.dogState === "chase") {
                return "狗在追 · 蹲下或拉开距离，等它停下";
            }
            if (this.dogState === "ear") {
                return "狗转耳朵了 · 停下或蹲下别出声";
            }
            return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下";
        }
        if (this.room.key === "tower") {
            if (this.phase === "tower-wait") {
                return "走到门前 445 点一次 E 敲两下";
            }
            if (this.phase === "tower-knock") {
                return "敲两下 · 等门开";
            }
            if (this.phase === "tower-given") {
                return "递交针套和纸条 · 看登记簿最后一行";
            }
            return "片尾 · 点 E 再玩一次，回到序章";
        }
        if (this.room.key === "village") {
            if (this.bottleFly !== undefined) {
                return "等瓶子落地 · 触地才发声";
            }
            if (this.hasBottle) {
                return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608";
            }
            if (this.passed) {
                return "已过第一院 · R 重置可再来一遍";
            }
            return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44";
        }
        if (this.room.key === "outside") {
            if (this.focusCart) {
                return "按住 E 抓住车把 · A / D 推拉 · 松手就停";
            }
            return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞";
        }
        if (this.escort.state === "frozen") {
            if (Math.abs(this.player.x - this.partner.x) <= CALM_REACH) {
                return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身";
            }
            return "小满吓住了 · 走过去，靠近再点 E";
        }
        if (this.escort.state === "calming") {
            return "安抚中 " + this.escort.calmTick + " / 60 拍 · 别动";
        }
        return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门";
    }
}

function makeActor(room: RoomSpec, index: number): Actor {
    const sp = room.spawns;
    if (index < 0 || index >= sp.length) {
        return { x: 0, y: 0, depth: 0, depthSpeed: 0, vx: 0, vy: 0, w: CHILD_W, h: CHILD_H, onGround: true, facing: 1, crouch: false, rollT: 0, covered: false, alive: false };
    }
    const s = sp[index];
    const child = s.h < SOLDIER_H;
    const ground = room.depth;
    const depth = ground === undefined ? 0 : Math.max(ground.min, Math.min(ground.max, s.depth ?? 0));
    return {
        x: s.x, y: s.y, depth, depthSpeed: 0, vx: 0, vy: 0,
        w: child ? CHILD_W : SOLDIER_W,
        h: child ? CHILD_H : SOLDIER_H,
        onGround: true, facing: 1, crouch: false, rollT: 0, covered: false, alive: true,
    };
}

/** 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。 */
export function screenToWorld(sx: number, sy: number, cam: Camera, view: Viewport): { x: number; y: number } {
    return {
        x: cam.x + ((sx - view.ox) / view.zoom - LOGIC_W / 2) * UNITS_PER_PX,
        y: cam.y + ((sy - view.oy) / view.zoom - LOGIC_H / 2) * UNITS_PER_PX,
    };
}

/** screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。 */
export function worldToScreen(wx: number, wy: number, cam: Camera, view: Viewport): { x: number; y: number } {
    return {
        x: ((wx - cam.x) / UNITS_PER_PX + LOGIC_W / 2) * view.zoom + view.ox,
        y: ((wy - cam.y) / UNITS_PER_PX + LOGIC_H / 2) * view.zoom + view.oy,
    };
}

/** 沿某轴穿过区间时，射线参数的起止范围。 */
function rayInterval(origin: number, direction: number, min: number, max: number): DepthRange {
    if (direction === 0) {
        return origin < min || origin > max ? { min: 1, max: 0 } : { min: -Infinity, max: Infinity };
    }
    const a = (min - origin) / direction;
    const b = (max - origin) / direction;
    return { min: Math.min(a, b), max: Math.max(a, b) };
}

/** 三轴区间都有交集时命中。没有纵深边界的墙横跨整条路。 */
function hitBox(ray: Ray, box: Box): number {
    const x = rayInterval(ray.x, ray.dx, box.x0, box.x1);
    const y = rayInterval(ray.y, ray.dy, box.y0, box.y1);
    let enter = Math.max(0, x.min, y.min);
    let leave = Math.min(99999, x.max, y.max);
    if (box.depth !== undefined) {
        const depth = rayInterval(ray.depth ?? 0, ray.dDepth ?? 0, box.depth.min, box.depth.max);
        enter = Math.max(enter, depth.min);
        leave = Math.min(leave, depth.max);
    }
    return leave >= enter ? enter : -1;
}
