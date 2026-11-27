import { Color, Content, Node, Rect, Size, Sprite, TextureFilter, Vec2 } from "Dora";

export type AssetSlotKey =
    | "bgFar_prologue" | "bgFar_street" | "bgFar_checkpoint" | "bgFar_gate"
    | "bgFar_outside" | "bgFar_village" | "bgFar_forest" | "bgFar_tower"
    | "soldier_idle" | "soldier_run" | "soldier_roll" | "soldier_cover"
    | "soldier_push" | "soldier_hold" | "soldier_offer" | "soldier_knock" | "soldier_hit" | "soldier_fire" | "soldier_fire_move"
    | "child_idle" | "child_run" | "child_crouch" | "child_fear" | "child_peek"
    | "child_pull" | "child_aim" | "child_throw" | "child_knock" | "child_offer"
    | "enemy_idle" | "enemy_aim" | "enemy_down" | "enemy_hit" | "scavenger" | "dog"
    | "prop_cart" | "prop_bottle" | "prop_tower_door" | "prop_lantern" | "prop_table"
    | "prop_compass" | "prop_winch" | "wall" | "cover_wood" | "cover_stone" | "fence"
    | "slab" | "eaves" | "pine" | "grass" | "grass_low"
    | "stone_chips" | "ui_corner" | "ui_corner_c" | "ui_paper" | "title_backdrop"
    | "ink_ribbon_sweep" | "ink_mist_curve" | "ink_veil_strip" | "ink_hairline"
    | "ink_bamboo_slip" | "ink_bamboo_slot" | "ink_frame_mask" | "ink_vstream"
    | "ink_knot_ornament" | "ink_corner_fine" | "ink_seal_slender" | "ink_blossom_dot"
    | "ink_enso_fine" | "ink_petal_mist" | "ink_song_paper"
    | "brand_game_logo_h" | "brand_game_logo_v" | "brand_team_logo" | "brand_team_badge";

export interface AssetSlotConfig {
    paths: string[];
    anchorX?: number | number[];
    anchorY: number;
    preserveAspect: boolean;
    smooth?: boolean;
}

export interface SpritePlacement {
    facing?: number;
    flipY?: boolean;
    opacity?: number;
    color?: Color.Type;
    frame?: number;
    angle?: number;
    layer?: number;
}

export interface PathPlacementOptions extends SpritePlacement {
    anchorX?: number;
    anchorY?: number;
    preserveAspect?: boolean;
    smooth?: boolean;
}

function backdrop(name: string): AssetSlotConfig {
    return { paths: ["assets/art/" + name + ".png"], anchorY: 0, preserveAspect: false };
}

function clip(
    names: string | string[],
    anchorY: number = 0,
    preserveAspect: boolean = false,
    anchorX?: number | number[],
): AssetSlotConfig {
    const frames = typeof names === "string" ? [names] : names;
    return { paths: frames.map(name => "assets/art/sprites.clip|" + name), anchorX, anchorY, preserveAspect };
}

function inkClip(name: string, preserveAspect: boolean = false): AssetSlotConfig {
    return { paths: ["assets/art/ui_ink.clip|" + name], anchorY: 0.5, preserveAspect, smooth: true };
}

function actor(names: string | string[], anchorX?: number | number[]): AssetSlotConfig {
    return clip(names, 0, true, anchorX);
}

export const RUN_FRAME_COUNT = 160;
export const RUN_TRANSITION_PHASES = 8;
export const RUN_TRANSITION_LEVELS = 12;
const ATLAS_GUTTER = 2;

interface MotionAtlas {
    path: string;
    width: number;
    height: number;
    columns: number;
}

const RUN_ATLASES = {
    soldier: { path: "assets/art/zhoushu-run.png", width: 180, height: 200, columns: 10 },
    child: { path: "assets/art/xiaoman-run.png", width: 144, height: 164, columns: 10 },
};
const RUN_TRANSITIONS = {
    soldier: { ...RUN_ATLASES.soldier, path: "assets/art/zhoushu-run-transition.png", columns: RUN_TRANSITION_PHASES },
    child: { ...RUN_ATLASES.child, path: "assets/art/xiaoman-run-transition.png", columns: RUN_TRANSITION_PHASES },
};

const HD_ACTOR_CLIP = "assets/art/actors-hd.clip|";
const BASE_ACTOR_CLIP = "assets/art/sprites.clip|";

export const ASSET_SLOTS: Record<AssetSlotKey, AssetSlotConfig> = {
    bgFar_prologue: backdrop("prologue"),
    bgFar_street: backdrop("street"),
    bgFar_checkpoint: backdrop("checkpoint"),
    bgFar_gate: backdrop("gate"),
    bgFar_outside: backdrop("outside"),
    bgFar_village: backdrop("village"),
    bgFar_forest: backdrop("forest"),
    bgFar_tower: backdrop("tower"),
    title_backdrop: backdrop("title"),
    soldier_idle: actor("soldier_idle"),
    soldier_run: actor(["soldier_run", "soldier_idle", "soldier_step", "soldier_idle"], [0.54, 0.50, 0.45, 0.50]),
    soldier_roll: actor("soldier_roll", 0.47),
    soldier_cover: actor("soldier_cover", 0.47),
    soldier_push: actor(["soldier_push", "soldier_push_step"], [0.43, 0.46]),
    soldier_hold: actor("soldier_hold"),
    soldier_offer: actor("soldier_offer", 0.48),
    soldier_knock: actor(["soldier_cover", "soldier_knock"], [0.47, 0.39]),
    soldier_hit: actor("soldier_hit", 0.50),
    soldier_fire: actor("soldier_fire", 0.51),
    soldier_fire_move: actor(["soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"], [0.53, 0.51, 0.55, 0.51]),
    child_idle: actor("child_idle", 0.48),
    child_run: actor(["child_run", "child_idle", "child_step", "child_idle"], [0.54, 0.48, 0.51, 0.48]),
    child_crouch: actor(["child_crouch", "child_crouch_step"], [0.44, 0.43]),
    child_fear: actor("child_fear", 0.48),
    child_peek: actor("child_peek", 0.50),
    child_pull: actor(["child_pull", "child_pull_step"], [0.40, 0.44]),
    child_aim: actor("child_aim", 0.47),
    child_throw: actor("child_throw", 0.49),
    child_knock: actor("child_knock", 0.50),
    child_offer: actor("child_offer", 0.49),
    enemy_idle: actor("enemy_idle", 0.50),
    enemy_aim: actor("enemy_aim", 0.51),
    enemy_down: actor("enemy_down"),
    enemy_hit: actor("enemy_hit", 0.48),
    scavenger: actor(["scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"], [0.52, 0.52, 0.48, 0.52]),
    dog: actor(["dog_idle", "dog_alert", "dog_run", "dog_sniff"], [0.50, 0.50, 0.54, 0.58]),
    prop_cart: clip("cart", 0, false, 0.44),
    prop_bottle: clip("bottle", 0.5, true),
    prop_tower_door: clip("door"),
    prop_lantern: clip("lantern", 0.5, true),
    prop_table: clip("table"),
    prop_compass: clip("compass", 0.5, true),
    prop_winch: clip("winch", 0.5, true),
    wall: clip("wall"),
    cover_wood: clip("cover_wood"),
    cover_stone: clip("cover_stone"),
    fence: clip("fence"),
    slab: clip("slab"),
    eaves: clip("eaves"),
    pine: clip("pine"),
    grass: clip("grass"),
    grass_low: clip("grass_low"),
    stone_chips: clip("stone_chips", 0.5, true),
    ui_corner: clip("ui_corner"),
    ui_corner_c: clip("ui_corner", 0.5, false),
    ui_paper: clip("paper", 0.5),
    ink_ribbon_sweep: inkClip("ink_ribbon_sweep"),
    ink_mist_curve: inkClip("ink_mist_curve"),
    ink_veil_strip: inkClip("ink_veil_strip"),
    ink_hairline: inkClip("ink_hairline"),
    ink_bamboo_slip: inkClip("ink_bamboo_slip"),
    ink_bamboo_slot: inkClip("ink_bamboo_slot"),
    ink_frame_mask: inkClip("ink_frame_mask"),
    ink_vstream: inkClip("ink_vstream"),
    ink_knot_ornament: inkClip("ink_knot_ornament"),
    ink_corner_fine: inkClip("ink_corner_fine"),
    ink_seal_slender: inkClip("ink_seal_slender"),
    ink_blossom_dot: inkClip("ink_blossom_dot"),
    ink_enso_fine: inkClip("ink_enso_fine"),
    ink_petal_mist: inkClip("ink_petal_mist"),
    ink_song_paper: inkClip("ink_song_paper"),
    brand_game_logo_h: { paths: ["assets/art/brand/game_logo_h.png"], anchorY: 0.5, preserveAspect: true, smooth: true },
    brand_game_logo_v: { paths: ["assets/art/brand/game_logo_v.png"], anchorY: 0.5, preserveAspect: true, smooth: true },
    brand_team_logo: { paths: ["assets/art/brand/team_logo_dark.png"], anchorY: 0.5, preserveAspect: true, smooth: true },
    brand_team_badge: { paths: ["assets/art/brand/team_badge.png"], anchorY: 0.5, preserveAspect: true, smooth: true },
};

const WHITE = Color(255, 255, 255, 255);

/**
 * 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
 * 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
 */
function sharedDynamicSlots(): Record<string, AssetSlotConfig> {
    const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
    const loaded = g.package !== undefined ? g.package.loaded : undefined;
    if (loaded !== undefined) {
        const existing = loaded["watch.fe.dynamic_slots"];
        if (existing !== undefined && typeof existing === "object") {
            return existing as Record<string, AssetSlotConfig>;
        }
        const created: Record<string, AssetSlotConfig> = {};
        loaded["watch.fe.dynamic_slots"] = created;
        return created;
    }
    return FALLBACK_DYNAMIC_SLOTS;
}

const FALLBACK_DYNAMIC_SLOTS: Record<string, AssetSlotConfig> = {};

/** 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源 */
export function registerDynamicSlot(key: string, cfg: AssetSlotConfig): void {
    sharedDynamicSlots()[key] = cfg;
}

export function unregisterDynamicSlot(key: string): void {
    delete sharedDynamicSlots()[key];
}

export class AssetSlotHost {
    private hdCast = false;
    private container: Node.Type;
    private sprites: Record<string, Sprite.Type> = {};
    private unavailable: Record<string, boolean> = {};
    private visibleLastFrame: Record<string, Sprite.Type> = {};
    private visibleThisFrame: Record<string, Sprite.Type> = {};
    private localSlots: Record<string, AssetSlotConfig> = {};

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
    }

    /** 在当前宿主实例上注册动态资源槽（也可使用顶层 registerDynamicSlot 全局注册） */
    registerDynamicSlot(key: string, cfg: AssetSlotConfig): void {
        this.localSlots[key] = cfg;
    }

    setHdCast(enabled: boolean): void {
        this.hdCast = enabled;
    }

    beginFrame(): void {
        this.visibleThisFrame = {};
    }

    tryPlace(
        slotKey: AssetSlotKey | string,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        options: SpritePlacement = {},
    ): boolean {
        const staticSlots = ASSET_SLOTS as Record<string, AssetSlotConfig | undefined>;
        const cfg = staticSlots[slotKey] ?? this.localSlots[slotKey] ?? sharedDynamicSlots()[slotKey];
        if (cfg === undefined || cfg.paths.length === 0 || targetW <= 0 || targetH <= 0) {
            return false;
        }
        const frame = Math.abs(Math.floor(options.frame ?? 0)) % cfg.paths.length;
        const path = cfg.paths[frame];
        const anchorX = typeof cfg.anchorX === "number"
            ? cfg.anchorX
            : (cfg.anchorX !== undefined ? (cfg.anchorX[frame] ?? 0.5) : 0.5);
        if (this.hdCast && path.startsWith(BASE_ACTOR_CLIP)
            && (slotKey.startsWith("child_") || slotKey.startsWith("soldier_"))) {
            const hdPath = HD_ACTOR_CLIP + path.slice(BASE_ACTOR_CLIP.length);
            if (this.placeResolvedPath(hdPath, 0.5, cfg.anchorY, true, false, instanceKey, x, y, targetW, targetH, options)) {
                return true;
            }
        }
        return this.placeResolvedPath(path, anchorX, cfg.anchorY, cfg.preserveAspect, cfg.smooth === true, instanceKey, x, y, targetW, targetH, options);
    }

    /** 循环进度为圈数。每个人物只复用一个精灵节点，逐帧改同一张贴图的采样范围。 */
    tryPlaceRun(
        actor: keyof typeof RUN_ATLASES,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        cycles: number,
        options: SpritePlacement = {},
        effort: number = 1,
    ): boolean {
        if (!this.hdCast) {
            return false;
        }
        if (effort < 1 && this.tryPlaceRunTransition(actor, instanceKey, x, y, targetW, targetH, cycles, effort, options)) {
            return true;
        }
        const frame = Math.floor((cycles - Math.floor(cycles)) * RUN_FRAME_COUNT);
        return this.tryPlaceMotionFrame(RUN_ATLASES[actor], frame, instanceKey, x, y, targetW, targetH, options);
    }

    /** 部分步幅沿用当前步相，急停后可收回同一只脚。 */
    private tryPlaceRunTransition(
        actor: keyof typeof RUN_TRANSITIONS,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        cycles: number, effort: number,
        options: SpritePlacement = {},
    ): boolean {
        const phase = Math.floor((cycles - Math.floor(cycles)) * RUN_TRANSITION_PHASES + 0.5) % RUN_TRANSITION_PHASES;
        const level = Math.max(0, Math.min(RUN_TRANSITION_LEVELS - 1, Math.round(effort * (RUN_TRANSITION_LEVELS + 1)) - 1));
        return this.tryPlaceMotionFrame(RUN_TRANSITIONS[actor], level * RUN_TRANSITION_PHASES + phase,
            instanceKey, x, y, targetW, targetH, options);
    }

    private tryPlaceMotionFrame(
        atlas: MotionAtlas,
        frame: number,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        options: SpritePlacement,
    ): boolean {
        if (targetW <= 0 || targetH <= 0) {
            return false;
        }
        const { path, width, height, columns } = atlas;
        const col = frame % columns;
        const row = Math.floor(frame / columns);
        const rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER,
            row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height);
        return this.placeResolvedPath(path, 0.5, 0, true, false, instanceKey, x, y, targetW, targetH, options, rect);
    }

    /** 按具体资源路径或 clip 帧路径直接放置精灵，缺失时静默返回 false */
    tryPlacePath(
        path: string,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        options: PathPlacementOptions = {},
    ): boolean {
        if (path === "" || targetW <= 0 || targetH <= 0) {
            return false;
        }
        return this.placeResolvedPath(
            path,
            options.anchorX ?? 0.5,
            options.anchorY ?? 0.5,
            options.preserveAspect ?? false,
            options.smooth === true,
            instanceKey,
            x,
            y,
            targetW,
            targetH,
            options,
        );
    }

    private placeResolvedPath(
        path: string,
        anchorX: number,
        anchorY: number,
        preserveAspect: boolean,
        smooth: boolean,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        options: SpritePlacement,
        textureRect?: Rect.Type,
    ): boolean {
        const key = instanceKey + ":" + path;
        let sprite = this.sprites[key];
        if (sprite === undefined) {
            if (this.unavailable[path]) {
                return false;
            }
            const divider = path.indexOf("|");
            const file = divider < 0 ? path : path.slice(0, divider);
            const loaded = Content.exist(file) ? Sprite(path) : undefined;
            if (loaded === undefined) {
                this.unavailable[path] = true;
                return false;
            }
            if (textureRect !== undefined) {
                loaded.size = Size(textureRect.width, textureRect.height);
            }
            loaded.anchor = Vec2(anchorX, anchorY);
            loaded.filter = smooth ? TextureFilter.Anisotropic : TextureFilter.Point;
            loaded.addTo(this.container);
            this.sprites[key] = loaded;
            sprite = loaded;
        }

        if (textureRect !== undefined) {
            sprite.textureRect = textureRect;
        }
        const scaleY = targetH / Math.max(1, textureRect?.height ?? sprite.height);
        const scaleX = preserveAspect ? scaleY : targetW / Math.max(1, sprite.width);
        sprite.position = textureRect === undefined ? Vec2(Math.round(x), Math.round(y)) : Vec2(x, y);
        sprite.scaleX = (options.facing ?? 1) < 0 ? -scaleX : scaleX;
        sprite.scaleY = options.flipY ? -scaleY : scaleY;
        sprite.angle = options.angle ?? 0;
        sprite.order = options.layer ?? 0;
        const col = options.color ?? WHITE;
        sprite.color = col;
        const baseA = col.a / 255;
        const op = options.opacity ?? 1;
        sprite.opacity = Math.max(0, Math.min(1, baseA * op));
        sprite.visible = true;
        this.visibleThisFrame[key] = sprite;
        return true;
    }

    endFrame(): void {
        for (const key in this.visibleLastFrame) {
            if (this.visibleThisFrame[key] === undefined) {
                this.visibleLastFrame[key].visible = false;
            }
        }
        this.visibleLastFrame = this.visibleThisFrame;
    }
}
