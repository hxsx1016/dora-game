import { Color, Content, Node, Sprite, TextureFilter, Vec2 } from "Dora";

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
    | "brand_game_logo_h" | "brand_game_logo_v" | "brand_team_logo" | "brand_team_badge"
    // ── 明月绘卷 · 像素幻灯片（assets/art/slides/*.png，TextureFilter.Point） ──
    | "slide_p01_01" | "slide_p01_02" | "slide_p01_03"
    | "slide_p02_01" | "slide_p02_02" | "slide_p02_03" | "slide_p02_04" | "slide_p02_05"
    | "slide_cuff_p03_01" | "slide_cuff_p03_02" | "slide_cuff_p03_03" | "slide_cuff_p03_04"
    | "slide_cuff_p05_01" | "slide_cuff_p05_02" | "slide_cuff_p05_03" | "slide_cuff_p05_04"
    | "slide_cuff_g05_01" | "slide_cuff_g05_02" | "slide_cuff_g05_03" | "slide_cuff_g05_04"
    | "slide_gate_01" | "slide_gate_02" | "slide_gate_03" | "slide_gate_04"
    | "slide_tower_porch_f03_closed" | "slide_tower_porch_f03_open"
    | "slide_tower_porch_m03_closed" | "slide_tower_porch_m03_open"
    | "slide_tower_room_f03_cold" | "slide_tower_room_f03_lit" | "slide_tower_room_m03_warm"
    | "slide_tower_interior_live"
    | "slide_e01_well" | "slide_e01_compass" | "slide_e01_vitrine"
    | "slide_e02_museum_hall" | "slide_e02_window_dawn" | "slide_e02_return_cabinet"
    | "slide_f01_sewing" | "slide_m02_lantern_gun" | "slide_m02_echo_gun"
    // ── 扩展像素精灵图集（assets/art/sprites_fe.clip，零改动旧图集） ──
    | "fe_carry_idle" | "fe_carry_walk" | "fe_carry_reload"
    | "fe_soldier_kneel_mount" | "fe_child_listen_door" | "fe_soldier_hand_hold" | "fe_tower_guard_lantern"
    | "fe_tower_brush_hand" | "fe_reload_hand_tap" | "fe_reload_hand_trace" | "fe_tower_cuff_rest"
    | "fe_tower_bowl_solo" | "fe_tower_bowl_hands" | "fe_tower_pouch_note" | "fe_tower_lantern_detail"
    | "fe_basin_flat" | "fe_basin_tilt" | "fe_well_rim" | "fe_outside_arch"
    | "fe_straw_target" | "fe_workbench" | "fe_bottle_rack" | "fe_braced_shield"
    | "fe_weapon_lantern_gun" | "fe_weapon_echo_gun" | "fe_lamp_bracket"
    | "fe_icon_wood_tally" | "fe_icon_bell_tally" | "fe_gear_rattan_shield"
    | "fe_root_arch" | "fe_culvert_grate"
    | "fe_red_cloth" | "fe_vfx_muzzle" | "fe_vfx_hit_spark" | "fe_vfx_smoke"
    | "fe_vfx_steam" | "fe_vfx_creek_reflect"
    | "fe_glyph_bell" | "fe_glyph_lamp" | "fe_glyph_push"
    | "fe_ground_brick" | "fe_ground_soft" | "fe_pillar_wood" | "fe_beam_wood" | "fe_road_stone"
    | "fe_fg_table_top" | "fe_fg_table_leg" | "fe_fg_pine_bough";

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

function slide(name: string): AssetSlotConfig {
    return { paths: ["assets/art/slides/" + name + ".png"], anchorY: 0.5, preserveAspect: false };
}

function feClip(
    names: string | string[],
    anchorY: number = 0.5,
    preserveAspect: boolean = true,
    anchorX?: number | number[],
): AssetSlotConfig {
    const frames = typeof names === "string" ? [names] : names;
    return { paths: frames.map(name => "assets/art/sprites_fe.clip|" + name), anchorX, anchorY, preserveAspect };
}

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
    // ── 明月绘卷 · 像素幻灯片 ──
    slide_p01_01: slide("p01_01_curtain"),
    slide_p01_02: slide("p01_02_hand"),
    slide_p01_03: slide("p01_03_door"),
    slide_p02_01: slide("p02_01_shadows"),
    slide_p02_02: slide("p02_02_cut"),
    slide_p02_03: slide("p02_03_bowl_roll"),
    slide_p02_04: slide("p02_04_bowl_stop"),
    slide_p02_05: slide("p02_05_cabinet"),
    slide_cuff_p03_01: slide("cuff_p03_01"),
    slide_cuff_p03_02: slide("cuff_p03_02"),
    slide_cuff_p03_03: slide("cuff_p03_03"),
    slide_cuff_p03_04: slide("cuff_p03_04"),
    slide_cuff_p05_01: slide("cuff_p05_01"),
    slide_cuff_p05_02: slide("cuff_p05_02"),
    slide_cuff_p05_03: slide("cuff_p05_03"),
    slide_cuff_p05_04: slide("cuff_p05_04"),
    slide_cuff_g05_01: slide("cuff_g05_01"),
    slide_cuff_g05_02: slide("cuff_g05_02"),
    slide_cuff_g05_03: slide("cuff_g05_03"),
    slide_cuff_g05_04: slide("cuff_g05_04"),
    slide_gate_01: { paths: ["assets/art/slides/gate_stage_01.png"], anchorY: 0, preserveAspect: false },
    slide_gate_02: { paths: ["assets/art/slides/gate_stage_02.png"], anchorY: 0, preserveAspect: false },
    slide_gate_03: { paths: ["assets/art/slides/gate_stage_03.png"], anchorY: 0, preserveAspect: false },
    slide_gate_04: { paths: ["assets/art/slides/gate_stage_04.png"], anchorY: 0, preserveAspect: false },
    slide_tower_porch_f03_closed: slide("tower_porch_f03_closed"),
    slide_tower_porch_f03_open: slide("tower_porch_f03_open"),
    slide_tower_porch_m03_closed: slide("tower_porch_m03_closed"),
    slide_tower_porch_m03_open: slide("tower_porch_m03_open"),
    slide_tower_room_f03_cold: slide("tower_room_f03_cold"),
    slide_tower_room_f03_lit: slide("tower_room_f03_lit"),
    slide_tower_room_m03_warm: slide("tower_room_m03_warm"),
    slide_tower_interior_live: { paths: ["assets/art/slides/tower_interior_live.png"], anchorY: 0, preserveAspect: false },
    slide_e01_well: slide("e01_01_well"),
    slide_e01_compass: slide("e01_02_compass"),
    slide_e01_vitrine: slide("e01_03_vitrine"),
    slide_e02_museum_hall: { paths: ["assets/art/slides/e02_museum_hall.png"], anchorY: 0, preserveAspect: false },
    slide_e02_window_dawn: slide("e02_window_dawn"),
    slide_e02_return_cabinet: slide("e02_return_cabinet"),
    slide_f01_sewing: slide("f01_sewing_memory"),
    slide_m02_lantern_gun: slide("m02_handover_lantern"),
    slide_m02_echo_gun: slide("m02_handover_echo"),
    // ── 扩展像素精灵图集（sprites_fe.clip） ──
    fe_carry_idle: feClip("carry_idle", 0, true, 0.50),
    fe_carry_walk: feClip(["carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"], 0, true, [0.50, 0.50, 0.50, 0.50]),
    fe_carry_reload: feClip("carry_reload", 0, true, 0.48),
    fe_soldier_kneel_mount: feClip("soldier_kneel_mount", 0, true, 0.50),
    fe_child_listen_door: feClip("child_listen_door", 0, true, 0.50),
    fe_soldier_hand_hold: feClip("soldier_hand_hold", 0, true, 0.50),
    fe_tower_guard_lantern: feClip("tower_guard_lantern", 0, true, 0.50),
    fe_tower_brush_hand: feClip("tower_brush_hand", 0.08, true, 0.06),
    fe_reload_hand_tap: feClip("reload_hand_tap", 0.90, true, 0.14),
    fe_reload_hand_trace: feClip("reload_hand_trace", 0.58, true, 0.92),
    fe_tower_cuff_rest: feClip("tower_cuff_rest", 0.50, true, 0.05),
    fe_tower_bowl_solo: feClip("tower_bowl_solo", 0.25, true, 0.50),
    fe_tower_bowl_hands: feClip("tower_bowl_hands", 0.40, true, 0.50),
    fe_tower_pouch_note: feClip("tower_pouch_note", 0.42, true, 0.50),
    fe_tower_lantern_detail: feClip("tower_lantern_detail", 0.14, true, 0.50),
    fe_basin_flat: feClip("prop_basin_flat", 0, true, 0.50),
    fe_basin_tilt: feClip("prop_basin_tilt", 0, true, 0.50),
    fe_well_rim: feClip("prop_well_rim", 0, true, 0.50),
    fe_outside_arch: feClip("prop_outside_arch", 0, false, 0.50),
    fe_straw_target: feClip("prop_straw_target", 0, true, 0.50),
    fe_workbench: feClip("prop_workbench", 0, false, 0.50),
    fe_bottle_rack: feClip("prop_bottle_rack", 0, true, 0.50),
    fe_braced_shield: feClip("prop_braced_shield", 0, true, 0.50),
    fe_weapon_lantern_gun: feClip("weapon_lantern_gun", 0.5, true, 0.50),
    fe_weapon_echo_gun: feClip("weapon_echo_gun", 0.5, true, 0.50),
    fe_lamp_bracket: feClip("prop_lamp_bracket", 0, true, 0.50),
    fe_icon_wood_tally: feClip("icon_wood_tally", 0.5, true, 0.50),
    fe_icon_bell_tally: feClip("icon_bell_tally", 0.5, true, 0.50),
    fe_gear_rattan_shield: feClip("gear_rattan_shield", 0.5, true, 0.50),
    fe_root_arch: feClip("prop_root_arch", 0, false, 0.50),
    fe_culvert_grate: feClip("prop_culvert_grate", 0, false, 0.50),
    fe_red_cloth: feClip(["prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"], 0.5, true, 0.90),
    fe_vfx_muzzle: feClip(["vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"], 0.5, true, 0.12),
    fe_vfx_hit_spark: feClip(["vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"], 0.5, true, 0.50),
    fe_vfx_smoke: feClip(["vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"], 0.5, true, 0.50),
    fe_vfx_steam: feClip(["vfx_steam_01", "vfx_steam_02", "vfx_steam_03"], 0.0, true, 0.50),
    fe_vfx_creek_reflect: feClip(["vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"], 0.5, false, 0.50),
    fe_glyph_bell: feClip("glyph_bell", 0.5, true, 0.50),
    fe_glyph_lamp: feClip("glyph_lamp", 0.5, true, 0.50),
    fe_glyph_push: feClip("glyph_push", 0.5, true, 0.50),
    fe_ground_brick: feClip("ground_brick_patch", 0, false, 0.50),
    fe_ground_soft: feClip("ground_soft_patch", 0, false, 0.50),
    fe_pillar_wood: feClip("pillar_wood", 0, false, 0.50),
    fe_beam_wood: feClip("beam_wood", 0, false, 0.50),
    fe_road_stone: feClip("road_stone", 0, false, 0.50),
    fe_fg_table_top: feClip("fg_table_top", 1.0, false, 0.50),
    fe_fg_table_leg: feClip("fg_table_leg", 1.0, false, 0.50),
    fe_fg_pine_bough: feClip("fg_pine_bough", 1.0, false, 1.0),
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
        return this.placeResolvedPath(path, anchorX, cfg.anchorY, cfg.preserveAspect, cfg.smooth === true, instanceKey, x, y, targetW, targetH, options);
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
            loaded.anchor = Vec2(anchorX, anchorY);
            loaded.filter = smooth ? TextureFilter.Anisotropic : TextureFilter.Point;
            loaded.addTo(this.container);
            this.sprites[key] = loaded;
            sprite = loaded;
        }

        const scaleY = targetH / Math.max(1, sprite.height);
        const scaleX = preserveAspect ? scaleY : targetW / Math.max(1, sprite.width);
        sprite.position = Vec2(Math.round(x), Math.round(y));
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
