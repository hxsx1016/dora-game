import { Color, Content, Node, Rect, Size, Sprite, TextureFilter, Vec2 } from "Dora";

export type AssetSlotKey =
    | "bgFar_prologue" | "bgFar_street" | "bgFar_checkpoint" | "bgFar_gate"
    | "bgFar_outside" | "bgFar_village" | "bgFar_forest" | "bgFar_tower"
    | "bgFar_crossroad_drygoods" | "bgFar_archway_yard" | "bgFar_granary" | "bgFar_escort_ridge" | "bgFar_museum"
    | "soldier_idle" | "soldier_run" | "soldier_roll" | "soldier_slide" | "soldier_cover"
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
    // ── 硬核明代木刻暗黑漫画过场原画（assets/art/cutscenes/**/*.png，6–12 FPS 全 10 段 237 帧 + 兼容旧锚点） ──
    | "comic_p01_01_curtain_dark" | "comic_p01_02_curtain_glow" | "comic_p01_03_hand_bedrail" | "comic_p01_04_look_door"
    | "comic_p01_f01" | "comic_p01_f02" | "comic_p01_f03" | "comic_p01_f04"
    | "comic_p01_f05" | "comic_p01_f06" | "comic_p01_f07" | "comic_p01_f08"
    | "comic_p01_f09" | "comic_p01_f10" | "comic_p01_f11" | "comic_p01_f12"
    | "comic_p01_f13" | "comic_p01_f14" | "comic_p01_f15" | "comic_p01_f16"
    | "comic_p01_f17" | "comic_p01_f18" | "comic_p01_f19" | "comic_p01_f20"
    | "comic_p01_f21" | "comic_p01_f22"
    | "comic_p02_01_shadows" | "comic_p02_02a_door_intrude" | "comic_p02_03_impact_cut" | "comic_p02_04_shadows_fall"
    | "comic_p02_05_bowl_roll1" | "comic_p02_06_bowl_roll2" | "comic_p02_07_bowl_smash"
    | "comic_p02_08a_cabinet_slit" | "comic_p02_08m_cabinet_narrowing" | "comic_p02_08b_cabinet_shut"
    | "comic_p02_f01" | "comic_p02_f02" | "comic_p02_f03" | "comic_p02_f04"
    | "comic_p02_f05" | "comic_p02_f06" | "comic_p02_f07" | "comic_p02_f08"
    | "comic_p02_f09" | "comic_p02_f10" | "comic_p02_f11" | "comic_p02_f12"
    | "comic_p02_f13" | "comic_p02_f14" | "comic_p02_f15" | "comic_p02_f16"
    | "comic_p02_f17" | "comic_p02_f18" | "comic_p02_f19" | "comic_p02_f20"
    | "comic_p02_f21" | "comic_p02_f22" | "comic_p02_f23" | "comic_p02_f24"
    | "comic_p02_f25" | "comic_p02_f26" | "comic_p02_f27" | "comic_p02_f28"
    | "comic_p02_f29" | "comic_p02_f30" | "comic_p02_f31" | "comic_p02_f32" | "comic_p02_f33"
    | "comic_p03_01_two_fingers" | "comic_p03_02_cuff_enter" | "comic_p03_03_cuff_wipe" | "comic_p03_04_hand_meet"
    | "comic_p03_f01" | "comic_p03_f02" | "comic_p03_f03" | "comic_p03_f04"
    | "comic_p03_f05" | "comic_p03_f06" | "comic_p03_f07" | "comic_p03_f08"
    | "comic_p03_f09" | "comic_p03_f10" | "comic_p03_f11" | "comic_p03_f12"
    | "comic_p03_f13" | "comic_p03_f14" | "comic_p03_f15" | "comic_p03_f16"
    | "comic_p03_f17" | "comic_p03_f18" | "comic_p03_f19" | "comic_p03_f20"
    | "comic_p03_f21" | "comic_p03_f22" | "comic_p03_f23" | "comic_p03_f24"
    | "comic_p05_01_clutch_cuff" | "comic_p05_02_brother_pinch" | "comic_p05_03_sleeve_pull"
    | "comic_p05_04_gate_drop" | "comic_p05_05_gate_slam_impact" | "comic_p05_06_open_fingers"
    | "comic_p05_f01" | "comic_p05_f02" | "comic_p05_f03" | "comic_p05_f04"
    | "comic_p05_f05" | "comic_p05_f06" | "comic_p05_f07" | "comic_p05_f08"
    | "comic_p05_f09" | "comic_p05_f10" | "comic_p05_f11" | "comic_p05_f12"
    | "comic_p05_f13" | "comic_p05_f14" | "comic_p05_f15" | "comic_p05_f16" | "comic_p05_f17"
    | "comic_g05_01_cuff_peek" | "comic_g05_02_cuff_extend" | "comic_g05_03_hands_meet" | "comic_g05_04_hands_clasp"
    | "comic_g05_05_tilt_arm" | "comic_g05_06_tilt_shoulder" | "comic_g05_07_zhoushu_reveal" | "comic_g05_08_zhoushu_warm"
    | "comic_g05_f01" | "comic_g05_f02" | "comic_g05_f03" | "comic_g05_f04"
    | "comic_g05_f05" | "comic_g05_f06" | "comic_g05_f07" | "comic_g05_f08"
    | "comic_g05_f09" | "comic_g05_f10" | "comic_g05_f11" | "comic_g05_f12"
    | "comic_g05_f13" | "comic_g05_f14" | "comic_g05_f15" | "comic_g05_f16"
    | "comic_g05_f17" | "comic_g05_f18" | "comic_g05_f19" | "comic_g05_f20"
    | "comic_gate_01_beam" | "comic_gate_02_dock" | "comic_gate_03_fog" | "comic_gate_04_terrace"
    | "comic_gate_f01" | "comic_gate_f02" | "comic_gate_f03" | "comic_gate_f04" | "comic_gate_f05"
    | "comic_gate_f06" | "comic_gate_f07" | "comic_gate_f08" | "comic_gate_f09" | "comic_gate_f10"
    | "comic_f01_01_thumb_cloth" | "comic_f01_02_needle_pierce" | "comic_f01_03_thread_pull" | "comic_f01_04_stitch_smooth"
    | "comic_f01_f01" | "comic_f01_f02" | "comic_f01_f03" | "comic_f01_f04"
    | "comic_f01_f05" | "comic_f01_f06" | "comic_f01_f07" | "comic_f01_f08"
    | "comic_f01_f09" | "comic_f01_f10" | "comic_f01_f11" | "comic_f01_f12"
    | "comic_m02_lantern_01_offer" | "comic_m02_lantern_02_grip" | "comic_m02_lantern_03_heft" | "comic_m02_lantern_04_ready"
    | "comic_m02_lantern_f01" | "comic_m02_lantern_f02" | "comic_m02_lantern_f03" | "comic_m02_lantern_f04"
    | "comic_m02_lantern_f05" | "comic_m02_lantern_f06" | "comic_m02_lantern_f07" | "comic_m02_lantern_f08"
    | "comic_m02_lantern_f09" | "comic_m02_lantern_f10" | "comic_m02_lantern_f11" | "comic_m02_lantern_f12"
    | "comic_m02_echo_01_offer" | "comic_m02_echo_02_grip" | "comic_m02_echo_03_heft" | "comic_m02_echo_04_ready"
    | "comic_m02_echo_f01" | "comic_m02_echo_f02" | "comic_m02_echo_f03" | "comic_m02_echo_f04"
    | "comic_m02_echo_f05" | "comic_m02_echo_f06" | "comic_m02_echo_f07" | "comic_m02_echo_f08"
    | "comic_m02_echo_f09" | "comic_m02_echo_f10" | "comic_m02_echo_f11"
    | "comic_tower_f03_porch_01_knock" | "comic_tower_f03_porch_02_open"
    | "comic_tower_m03_porch_01_knock" | "comic_tower_m03_porch_02_open"
    | "comic_tower_f03_room_01_cold" | "comic_tower_f03_room_02_hover" | "comic_tower_f03_room_03_move_lamp" | "comic_tower_f03_room_04_lit_bowl"
    | "comic_tower_m03_room_01_warm" | "comic_tower_m03_room_02_speak" | "comic_tower_m03_room_03_pouch" | "comic_tower_m03_room_04_bowl"
    | "comic_f03_f01" | "comic_f03_f02" | "comic_f03_f03" | "comic_f03_f04"
    | "comic_f03_f05" | "comic_f03_f06" | "comic_f03_f07" | "comic_f03_f08"
    | "comic_f03_f09" | "comic_f03_f10" | "comic_f03_f11" | "comic_f03_f12"
    | "comic_f03_f13" | "comic_f03_f14" | "comic_f03_f15" | "comic_f03_f16"
    | "comic_f03_f17" | "comic_f03_f18" | "comic_f03_f19" | "comic_f03_f20"
    | "comic_m03_f01" | "comic_m03_f02" | "comic_m03_f03" | "comic_m03_f04"
    | "comic_m03_f05" | "comic_m03_f06" | "comic_m03_f07" | "comic_m03_f08"
    | "comic_m03_f09" | "comic_m03_f10" | "comic_m03_f11" | "comic_m03_f12"
    | "comic_m03_f13" | "comic_m03_f14" | "comic_m03_f15" | "comic_m03_f16"
    | "comic_m03_f17" | "comic_m03_f18" | "comic_m03_f19" | "comic_m03_f20"
    | "comic_museum_e01_01_well_water" | "comic_museum_e01_02_compass_align" | "comic_museum_e01_03_match_flash" | "comic_museum_e01_04_vitrine_emerge"
    | "comic_e01_f01" | "comic_e01_f02" | "comic_e01_f03" | "comic_e01_f04"
    | "comic_e01_f05" | "comic_e01_f06" | "comic_e01_f07" | "comic_e01_f08"
    | "comic_e01_f09" | "comic_e01_f10" | "comic_e01_f11" | "comic_e01_f12"
    | "comic_e01_f13" | "comic_e01_f14" | "comic_e01_f15" | "comic_e01_f16"
    | "comic_museum_e02_01_west_window" | "comic_museum_e02_02_lamp_turn" | "comic_museum_e02_03_dawn_well_reflect" | "comic_museum_e02_04_cabinet_cuff_return"
    | "comic_e02_f01" | "comic_e02_f02" | "comic_e02_f03" | "comic_e02_f04"
    | "comic_e02_f05" | "comic_e02_f06" | "comic_e02_f07" | "comic_e02_f08"
    | "comic_e02_f09" | "comic_e02_f10" | "comic_e02_f11" | "comic_e02_f12"
    | "comic_e02_f13" | "comic_e02_f14" | "comic_e02_f15" | "comic_e02_f16"
    | "comic_e02_f17" | "comic_e02_f18" | "comic_e02_f19" | "comic_e02_f20"
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
    /** 次级物理挤压拉伸倍率（转向弹性、起跳拉伸、落地缓冲） */
    scaleXMul?: number;
    scaleYMul?: number;
}

export interface PathPlacementOptions extends SpritePlacement {
    anchorX?: number;
    anchorY?: number;
    preserveAspect?: boolean;
    smooth?: boolean;
}

function backdrop(name: string, smooth: boolean = false): AssetSlotConfig {
    return smooth
        ? { paths: ["assets/art/" + name + ".png"], anchorY: 0, preserveAspect: false, smooth: true }
        : { paths: ["assets/art/" + name + ".png"], anchorY: 0, preserveAspect: false };
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

function comicCutscene(rel: string): AssetSlotConfig {
    return { paths: ["assets/art/cutscenes/" + rel + ".png"], anchorY: 0.5, preserveAspect: false, smooth: true };
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

function character(names: string | string[]): AssetSlotConfig {
    const frames = typeof names === "string" ? [names] : names;
    return { paths: frames.map(name => "assets/art/actors-hd.clip|" + name), anchorY: 0, preserveAspect: true };
}

export const RUN_FRAME_COUNT = 160;
export const RUN_TRANSITION_PHASES = 8;
export const RUN_TRANSITION_LEVELS = 12;
export const SLIDE_FRAME_COUNT = 64;
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
const SLIDE_ATLAS: MotionAtlas = {
    path: "assets/art/zhoushu-slide.png", width: 300, height: 198, columns: 8,
};

export const ASSET_SLOTS: Record<AssetSlotKey, AssetSlotConfig> = {
    bgFar_prologue: backdrop("prologue"),
    bgFar_street: backdrop("street"),
    bgFar_checkpoint: backdrop("checkpoint"),
    bgFar_gate: backdrop("gate"),
    bgFar_outside: backdrop("outside"),
    bgFar_village: backdrop("village"),
    bgFar_forest: backdrop("forest"),
    bgFar_tower: backdrop("tower"),
    bgFar_crossroad_drygoods: backdrop("bg_crossroad_drygoods"),
    bgFar_archway_yard: backdrop("bg_archway_yard"),
    bgFar_granary: backdrop("bg_granary"),
    bgFar_escort_ridge: backdrop("bg_escort_ridge"),
    bgFar_museum: backdrop("bg_museum_hall", true),
    title_backdrop: backdrop("title"),
    soldier_idle: character("soldier_idle"),
    soldier_run: character(["soldier_run", "soldier_step"]),
    soldier_roll: character("soldier_roll"),
    soldier_slide: character(["soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"]),
    soldier_cover: character("soldier_cover"),
    soldier_push: character(["soldier_push", "soldier_push_step"]),
    soldier_hold: character("soldier_hold"),
    soldier_offer: character("soldier_offer"),
    soldier_knock: character(["soldier_cover", "soldier_knock"]),
    soldier_hit: character("soldier_hit"),
    soldier_fire: character("soldier_fire"),
    soldier_fire_move: character(["soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"]),
    child_idle: character("child_idle"),
    child_run: character(["child_run", "child_step"]),
    child_crouch: character(["child_crouch", "child_crouch_step"]),
    child_fear: character("child_fear"),
    child_peek: character("child_peek"),
    child_pull: character(["child_pull", "child_pull_step"]),
    child_aim: character("child_aim"),
    child_throw: character("child_throw"),
    child_knock: character("child_knock"),
    child_offer: character("child_offer"),
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
    // ── 硬核明代木刻暗黑漫画过场原画 ──
    comic_p01_01_curtain_dark: comicCutscene("p01/p01_01_curtain_dark"),
    comic_p01_02_curtain_glow: comicCutscene("p01/p01_02_curtain_glow"),
    comic_p01_03_hand_bedrail: comicCutscene("p01/p01_03_hand_bedrail"),
    comic_p01_04_look_door: comicCutscene("p01/p01_04_look_door"),
    comic_p01_f01: comicCutscene("p01/p01_f01"),
    comic_p01_f02: comicCutscene("p01/p01_f02"),
    comic_p01_f03: comicCutscene("p01/p01_f03"),
    comic_p01_f04: comicCutscene("p01/p01_f04"),
    comic_p01_f05: comicCutscene("p01/p01_f05"),
    comic_p01_f06: comicCutscene("p01/p01_f06"),
    comic_p01_f07: comicCutscene("p01/p01_f07"),
    comic_p01_f08: comicCutscene("p01/p01_f08"),
    comic_p01_f09: comicCutscene("p01/p01_f09"),
    comic_p01_f10: comicCutscene("p01/p01_f10"),
    comic_p01_f11: comicCutscene("p01/p01_f11"),
    comic_p01_f12: comicCutscene("p01/p01_f12"),
    comic_p01_f13: comicCutscene("p01/p01_f13"),
    comic_p01_f14: comicCutscene("p01/p01_f14"),
    comic_p01_f15: comicCutscene("p01/p01_f15"),
    comic_p01_f16: comicCutscene("p01/p01_f16"),
    comic_p01_f17: comicCutscene("p01/p01_f17"),
    comic_p01_f18: comicCutscene("p01/p01_f18"),
    comic_p01_f19: comicCutscene("p01/p01_f19"),
    comic_p01_f20: comicCutscene("p01/p01_f20"),
    comic_p01_f21: comicCutscene("p01/p01_f21"),
    comic_p01_f22: comicCutscene("p01/p01_f22"),
    comic_p02_01_shadows: comicCutscene("p02/p02_01_shadows"),
    comic_p02_02a_door_intrude: comicCutscene("p02/p02_02a_door_intrude"),
    comic_p02_03_impact_cut: comicCutscene("p02/p02_03_impact_cut"),
    comic_p02_04_shadows_fall: comicCutscene("p02/p02_04_shadows_fall"),
    comic_p02_05_bowl_roll1: comicCutscene("p02/p02_05_bowl_roll1"),
    comic_p02_06_bowl_roll2: comicCutscene("p02/p02_06_bowl_roll2"),
    comic_p02_07_bowl_smash: comicCutscene("p02/p02_07_bowl_smash"),
    comic_p02_08a_cabinet_slit: comicCutscene("p02/p02_08a_cabinet_slit"),
    comic_p02_08m_cabinet_narrowing: comicCutscene("p02/p02_08m_cabinet_narrowing"),
    comic_p02_08b_cabinet_shut: comicCutscene("p02/p02_08b_cabinet_shut"),
    comic_p02_f01: comicCutscene("p02/p02_f01"),
    comic_p02_f02: comicCutscene("p02/p02_f02"),
    comic_p02_f03: comicCutscene("p02/p02_f03"),
    comic_p02_f04: comicCutscene("p02/p02_f04"),
    comic_p02_f05: comicCutscene("p02/p02_f05"),
    comic_p02_f06: comicCutscene("p02/p02_f06"),
    comic_p02_f07: comicCutscene("p02/p02_f07"),
    comic_p02_f08: comicCutscene("p02/p02_f08"),
    comic_p02_f09: comicCutscene("p02/p02_f09"),
    comic_p02_f10: comicCutscene("p02/p02_f10"),
    comic_p02_f11: comicCutscene("p02/p02_f11"),
    comic_p02_f12: comicCutscene("p02/p02_f12"),
    comic_p02_f13: comicCutscene("p02/p02_f13"),
    comic_p02_f14: comicCutscene("p02/p02_f14"),
    comic_p02_f15: comicCutscene("p02/p02_f15"),
    comic_p02_f16: comicCutscene("p02/p02_f16"),
    comic_p02_f17: comicCutscene("p02/p02_f17"),
    comic_p02_f18: comicCutscene("p02/p02_f18"),
    comic_p02_f19: comicCutscene("p02/p02_f19"),
    comic_p02_f20: comicCutscene("p02/p02_f20"),
    comic_p02_f21: comicCutscene("p02/p02_f21"),
    comic_p02_f22: comicCutscene("p02/p02_f22"),
    comic_p02_f23: comicCutscene("p02/p02_f23"),
    comic_p02_f24: comicCutscene("p02/p02_f24"),
    comic_p02_f25: comicCutscene("p02/p02_f25"),
    comic_p02_f26: comicCutscene("p02/p02_f26"),
    comic_p02_f27: comicCutscene("p02/p02_f27"),
    comic_p02_f28: comicCutscene("p02/p02_f28"),
    comic_p02_f29: comicCutscene("p02/p02_f29"),
    comic_p02_f30: comicCutscene("p02/p02_f30"),
    comic_p02_f31: comicCutscene("p02/p02_f31"),
    comic_p02_f32: comicCutscene("p02/p02_f32"),
    comic_p02_f33: comicCutscene("p02/p02_f33"),
    comic_p03_01_two_fingers: comicCutscene("p03/p03_01_two_fingers"),
    comic_p03_02_cuff_enter: comicCutscene("p03/p03_02_cuff_enter"),
    comic_p03_03_cuff_wipe: comicCutscene("p03/p03_03_cuff_wipe"),
    comic_p03_04_hand_meet: comicCutscene("p03/p03_04_hand_meet"),
    comic_p03_f01: comicCutscene("p03/p03_f01"),
    comic_p03_f02: comicCutscene("p03/p03_f02"),
    comic_p03_f03: comicCutscene("p03/p03_f03"),
    comic_p03_f04: comicCutscene("p03/p03_f04"),
    comic_p03_f05: comicCutscene("p03/p03_f05"),
    comic_p03_f06: comicCutscene("p03/p03_f06"),
    comic_p03_f07: comicCutscene("p03/p03_f07"),
    comic_p03_f08: comicCutscene("p03/p03_f08"),
    comic_p03_f09: comicCutscene("p03/p03_f09"),
    comic_p03_f10: comicCutscene("p03/p03_f10"),
    comic_p03_f11: comicCutscene("p03/p03_f11"),
    comic_p03_f12: comicCutscene("p03/p03_f12"),
    comic_p03_f13: comicCutscene("p03/p03_f13"),
    comic_p03_f14: comicCutscene("p03/p03_f14"),
    comic_p03_f15: comicCutscene("p03/p03_f15"),
    comic_p03_f16: comicCutscene("p03/p03_f16"),
    comic_p03_f17: comicCutscene("p03/p03_f17"),
    comic_p03_f18: comicCutscene("p03/p03_f18"),
    comic_p03_f19: comicCutscene("p03/p03_f19"),
    comic_p03_f20: comicCutscene("p03/p03_f20"),
    comic_p03_f21: comicCutscene("p03/p03_f21"),
    comic_p03_f22: comicCutscene("p03/p03_f22"),
    comic_p03_f23: comicCutscene("p03/p03_f23"),
    comic_p03_f24: comicCutscene("p03/p03_f24"),
    comic_p05_01_clutch_cuff: comicCutscene("p05/p05_01_clutch_cuff"),
    comic_p05_02_brother_pinch: comicCutscene("p05/p05_02_brother_pinch"),
    comic_p05_03_sleeve_pull: comicCutscene("p05/p05_03_sleeve_pull"),
    comic_p05_04_gate_drop: comicCutscene("p05/p05_04_gate_drop"),
    comic_p05_05_gate_slam_impact: comicCutscene("p05/p05_05_gate_slam_impact"),
    comic_p05_06_open_fingers: comicCutscene("p05/p05_06_open_fingers"),
    comic_p05_f01: comicCutscene("p05/p05_f01"),
    comic_p05_f02: comicCutscene("p05/p05_f02"),
    comic_p05_f03: comicCutscene("p05/p05_f03"),
    comic_p05_f04: comicCutscene("p05/p05_f04"),
    comic_p05_f05: comicCutscene("p05/p05_f05"),
    comic_p05_f06: comicCutscene("p05/p05_f06"),
    comic_p05_f07: comicCutscene("p05/p05_f07"),
    comic_p05_f08: comicCutscene("p05/p05_f08"),
    comic_p05_f09: comicCutscene("p05/p05_f09"),
    comic_p05_f10: comicCutscene("p05/p05_f10"),
    comic_p05_f11: comicCutscene("p05/p05_f11"),
    comic_p05_f12: comicCutscene("p05/p05_f12"),
    comic_p05_f13: comicCutscene("p05/p05_f13"),
    comic_p05_f14: comicCutscene("p05/p05_f14"),
    comic_p05_f15: comicCutscene("p05/p05_f15"),
    comic_p05_f16: comicCutscene("p05/p05_f16"),
    comic_p05_f17: comicCutscene("p05/p05_f17"),
    comic_g05_01_cuff_peek: comicCutscene("g05/g05_01_cuff_peek"),
    comic_g05_02_cuff_extend: comicCutscene("g05/g05_02_cuff_extend"),
    comic_g05_03_hands_meet: comicCutscene("g05/g05_03_hands_meet"),
    comic_g05_04_hands_clasp: comicCutscene("g05/g05_04_hands_clasp"),
    comic_g05_05_tilt_arm: comicCutscene("g05/g05_05_tilt_arm"),
    comic_g05_06_tilt_shoulder: comicCutscene("g05/g05_06_tilt_shoulder"),
    comic_g05_07_zhoushu_reveal: comicCutscene("g05/g05_07_zhoushu_reveal"),
    comic_g05_08_zhoushu_warm: comicCutscene("g05/g05_08_zhoushu_warm"),
    comic_g05_f01: comicCutscene("g05/g05_f01"),
    comic_g05_f02: comicCutscene("g05/g05_f02"),
    comic_g05_f03: comicCutscene("g05/g05_f03"),
    comic_g05_f04: comicCutscene("g05/g05_f04"),
    comic_g05_f05: comicCutscene("g05/g05_f05"),
    comic_g05_f06: comicCutscene("g05/g05_f06"),
    comic_g05_f07: comicCutscene("g05/g05_f07"),
    comic_g05_f08: comicCutscene("g05/g05_f08"),
    comic_g05_f09: comicCutscene("g05/g05_f09"),
    comic_g05_f10: comicCutscene("g05/g05_f10"),
    comic_g05_f11: comicCutscene("g05/g05_f11"),
    comic_g05_f12: comicCutscene("g05/g05_f12"),
    comic_g05_f13: comicCutscene("g05/g05_f13"),
    comic_g05_f14: comicCutscene("g05/g05_f14"),
    comic_g05_f15: comicCutscene("g05/g05_f15"),
    comic_g05_f16: comicCutscene("g05/g05_f16"),
    comic_g05_f17: comicCutscene("g05/g05_f17"),
    comic_g05_f18: comicCutscene("g05/g05_f18"),
    comic_g05_f19: comicCutscene("g05/g05_f19"),
    comic_g05_f20: comicCutscene("g05/g05_f20"),
    comic_gate_01_beam: { paths: ["assets/art/cutscenes/gate/gate_01_beam.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_02_dock: { paths: ["assets/art/cutscenes/gate/gate_02_dock.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_03_fog: { paths: ["assets/art/cutscenes/gate/gate_03_fog.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_04_terrace: { paths: ["assets/art/cutscenes/gate/gate_04_terrace.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f01: { paths: ["assets/art/cutscenes/gate/gate_f01.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f02: { paths: ["assets/art/cutscenes/gate/gate_f02.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f03: { paths: ["assets/art/cutscenes/gate/gate_f03.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f04: { paths: ["assets/art/cutscenes/gate/gate_f04.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f05: { paths: ["assets/art/cutscenes/gate/gate_f05.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f06: { paths: ["assets/art/cutscenes/gate/gate_f06.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f07: { paths: ["assets/art/cutscenes/gate/gate_f07.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f08: { paths: ["assets/art/cutscenes/gate/gate_f08.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f09: { paths: ["assets/art/cutscenes/gate/gate_f09.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_gate_f10: { paths: ["assets/art/cutscenes/gate/gate_f10.png"], anchorY: 0, preserveAspect: false, smooth: true },
    comic_f01_01_thumb_cloth: comicCutscene("f01/f01_01_thumb_cloth"),
    comic_f01_02_needle_pierce: comicCutscene("f01/f01_02_needle_pierce"),
    comic_f01_03_thread_pull: comicCutscene("f01/f01_03_thread_pull"),
    comic_f01_04_stitch_smooth: comicCutscene("f01/f01_04_stitch_smooth"),
    comic_f01_f01: comicCutscene("f01/f01_f01"),
    comic_f01_f02: comicCutscene("f01/f01_f02"),
    comic_f01_f03: comicCutscene("f01/f01_f03"),
    comic_f01_f04: comicCutscene("f01/f01_f04"),
    comic_f01_f05: comicCutscene("f01/f01_f05"),
    comic_f01_f06: comicCutscene("f01/f01_f06"),
    comic_f01_f07: comicCutscene("f01/f01_f07"),
    comic_f01_f08: comicCutscene("f01/f01_f08"),
    comic_f01_f09: comicCutscene("f01/f01_f09"),
    comic_f01_f10: comicCutscene("f01/f01_f10"),
    comic_f01_f11: comicCutscene("f01/f01_f11"),
    comic_f01_f12: comicCutscene("f01/f01_f12"),
    comic_m02_lantern_01_offer: comicCutscene("m02/m02_lantern_01_offer"),
    comic_m02_lantern_02_grip: comicCutscene("m02/m02_lantern_02_grip"),
    comic_m02_lantern_03_heft: comicCutscene("m02/m02_lantern_03_heft"),
    comic_m02_lantern_04_ready: comicCutscene("m02/m02_lantern_04_ready"),
    comic_m02_lantern_f01: comicCutscene("m02/m02_lantern_f01"),
    comic_m02_lantern_f02: comicCutscene("m02/m02_lantern_f02"),
    comic_m02_lantern_f03: comicCutscene("m02/m02_lantern_f03"),
    comic_m02_lantern_f04: comicCutscene("m02/m02_lantern_f04"),
    comic_m02_lantern_f05: comicCutscene("m02/m02_lantern_f05"),
    comic_m02_lantern_f06: comicCutscene("m02/m02_lantern_f06"),
    comic_m02_lantern_f07: comicCutscene("m02/m02_lantern_f07"),
    comic_m02_lantern_f08: comicCutscene("m02/m02_lantern_f08"),
    comic_m02_lantern_f09: comicCutscene("m02/m02_lantern_f09"),
    comic_m02_lantern_f10: comicCutscene("m02/m02_lantern_f10"),
    comic_m02_lantern_f11: comicCutscene("m02/m02_lantern_f11"),
    comic_m02_lantern_f12: comicCutscene("m02/m02_lantern_f12"),
    comic_m02_echo_01_offer: comicCutscene("m02/m02_echo_01_offer"),
    comic_m02_echo_02_grip: comicCutscene("m02/m02_echo_02_grip"),
    comic_m02_echo_03_heft: comicCutscene("m02/m02_echo_03_heft"),
    comic_m02_echo_04_ready: comicCutscene("m02/m02_echo_04_ready"),
    comic_m02_echo_f01: comicCutscene("m02/m02_echo_f01"),
    comic_m02_echo_f02: comicCutscene("m02/m02_echo_f02"),
    comic_m02_echo_f03: comicCutscene("m02/m02_echo_f03"),
    comic_m02_echo_f04: comicCutscene("m02/m02_echo_f04"),
    comic_m02_echo_f05: comicCutscene("m02/m02_echo_f05"),
    comic_m02_echo_f06: comicCutscene("m02/m02_echo_f06"),
    comic_m02_echo_f07: comicCutscene("m02/m02_echo_f07"),
    comic_m02_echo_f08: comicCutscene("m02/m02_echo_f08"),
    comic_m02_echo_f09: comicCutscene("m02/m02_echo_f09"),
    comic_m02_echo_f10: comicCutscene("m02/m02_echo_f10"),
    comic_m02_echo_f11: comicCutscene("m02/m02_echo_f11"),
    comic_tower_f03_porch_01_knock: comicCutscene("tower/f03_porch_01_knock"),
    comic_tower_f03_porch_02_open: comicCutscene("tower/f03_porch_02_open"),
    comic_tower_m03_porch_01_knock: comicCutscene("tower/m03_porch_01_knock"),
    comic_tower_m03_porch_02_open: comicCutscene("tower/m03_porch_02_open"),
    comic_tower_f03_room_01_cold: comicCutscene("tower/f03_room_01_cold"),
    comic_tower_f03_room_02_hover: comicCutscene("tower/f03_room_02_hover"),
    comic_tower_f03_room_03_move_lamp: comicCutscene("tower/f03_room_03_move_lamp"),
    comic_tower_f03_room_04_lit_bowl: comicCutscene("tower/f03_room_04_lit_bowl"),
    comic_tower_m03_room_01_warm: comicCutscene("tower/m03_room_01_warm"),
    comic_tower_m03_room_02_speak: comicCutscene("tower/m03_room_02_speak"),
    comic_tower_m03_room_03_pouch: comicCutscene("tower/m03_room_03_pouch"),
    comic_tower_m03_room_04_bowl: comicCutscene("tower/m03_room_04_bowl"),
    comic_f03_f01: comicCutscene("tower/f03_f01"),
    comic_f03_f02: comicCutscene("tower/f03_f02"),
    comic_f03_f03: comicCutscene("tower/f03_f03"),
    comic_f03_f04: comicCutscene("tower/f03_f04"),
    comic_f03_f05: comicCutscene("tower/f03_f05"),
    comic_f03_f06: comicCutscene("tower/f03_f06"),
    comic_f03_f07: comicCutscene("tower/f03_f07"),
    comic_f03_f08: comicCutscene("tower/f03_f08"),
    comic_f03_f09: comicCutscene("tower/f03_f09"),
    comic_f03_f10: comicCutscene("tower/f03_f10"),
    comic_f03_f11: comicCutscene("tower/f03_f11"),
    comic_f03_f12: comicCutscene("tower/f03_f12"),
    comic_f03_f13: comicCutscene("tower/f03_f13"),
    comic_f03_f14: comicCutscene("tower/f03_f14"),
    comic_f03_f15: comicCutscene("tower/f03_f15"),
    comic_f03_f16: comicCutscene("tower/f03_f16"),
    comic_f03_f17: comicCutscene("tower/f03_f17"),
    comic_f03_f18: comicCutscene("tower/f03_f18"),
    comic_f03_f19: comicCutscene("tower/f03_f19"),
    comic_f03_f20: comicCutscene("tower/f03_f20"),
    comic_m03_f01: comicCutscene("tower/m03_f01"),
    comic_m03_f02: comicCutscene("tower/m03_f02"),
    comic_m03_f03: comicCutscene("tower/m03_f03"),
    comic_m03_f04: comicCutscene("tower/m03_f04"),
    comic_m03_f05: comicCutscene("tower/m03_f05"),
    comic_m03_f06: comicCutscene("tower/m03_f06"),
    comic_m03_f07: comicCutscene("tower/m03_f07"),
    comic_m03_f08: comicCutscene("tower/m03_f08"),
    comic_m03_f09: comicCutscene("tower/m03_f09"),
    comic_m03_f10: comicCutscene("tower/m03_f10"),
    comic_m03_f11: comicCutscene("tower/m03_f11"),
    comic_m03_f12: comicCutscene("tower/m03_f12"),
    comic_m03_f13: comicCutscene("tower/m03_f13"),
    comic_m03_f14: comicCutscene("tower/m03_f14"),
    comic_m03_f15: comicCutscene("tower/m03_f15"),
    comic_m03_f16: comicCutscene("tower/m03_f16"),
    comic_m03_f17: comicCutscene("tower/m03_f17"),
    comic_m03_f18: comicCutscene("tower/m03_f18"),
    comic_m03_f19: comicCutscene("tower/m03_f19"),
    comic_m03_f20: comicCutscene("tower/m03_f20"),
    comic_museum_e01_01_well_water: comicCutscene("museum/e01_01_well_water"),
    comic_museum_e01_02_compass_align: comicCutscene("museum/e01_02_compass_align"),
    comic_museum_e01_03_match_flash: comicCutscene("museum/e01_03_match_flash"),
    comic_museum_e01_04_vitrine_emerge: comicCutscene("museum/e01_04_vitrine_emerge"),
    comic_e01_f01: comicCutscene("museum/e01_f01"),
    comic_e01_f02: comicCutscene("museum/e01_f02"),
    comic_e01_f03: comicCutscene("museum/e01_f03"),
    comic_e01_f04: comicCutscene("museum/e01_f04"),
    comic_e01_f05: comicCutscene("museum/e01_f05"),
    comic_e01_f06: comicCutscene("museum/e01_f06"),
    comic_e01_f07: comicCutscene("museum/e01_f07"),
    comic_e01_f08: comicCutscene("museum/e01_f08"),
    comic_e01_f09: comicCutscene("museum/e01_f09"),
    comic_e01_f10: comicCutscene("museum/e01_f10"),
    comic_e01_f11: comicCutscene("museum/e01_f11"),
    comic_e01_f12: comicCutscene("museum/e01_f12"),
    comic_e01_f13: comicCutscene("museum/e01_f13"),
    comic_e01_f14: comicCutscene("museum/e01_f14"),
    comic_e01_f15: comicCutscene("museum/e01_f15"),
    comic_e01_f16: comicCutscene("museum/e01_f16"),
    comic_museum_e02_01_west_window: comicCutscene("museum/e02_01_west_window"),
    comic_museum_e02_02_lamp_turn: comicCutscene("museum/e02_02_lamp_turn"),
    comic_museum_e02_03_dawn_well_reflect: comicCutscene("museum/e02_03_dawn_well_reflect"),
    comic_museum_e02_04_cabinet_cuff_return: comicCutscene("museum/e02_04_cabinet_cuff_return"),
    comic_e02_f01: comicCutscene("museum/e02_f01"),
    comic_e02_f02: comicCutscene("museum/e02_f02"),
    comic_e02_f03: comicCutscene("museum/e02_f03"),
    comic_e02_f04: comicCutscene("museum/e02_f04"),
    comic_e02_f05: comicCutscene("museum/e02_f05"),
    comic_e02_f06: comicCutscene("museum/e02_f06"),
    comic_e02_f07: comicCutscene("museum/e02_f07"),
    comic_e02_f08: comicCutscene("museum/e02_f08"),
    comic_e02_f09: comicCutscene("museum/e02_f09"),
    comic_e02_f10: comicCutscene("museum/e02_f10"),
    comic_e02_f11: comicCutscene("museum/e02_f11"),
    comic_e02_f12: comicCutscene("museum/e02_f12"),
    comic_e02_f13: comicCutscene("museum/e02_f13"),
    comic_e02_f14: comicCutscene("museum/e02_f14"),
    comic_e02_f15: comicCutscene("museum/e02_f15"),
    comic_e02_f16: comicCutscene("museum/e02_f16"),
    comic_e02_f17: comicCutscene("museum/e02_f17"),
    comic_e02_f18: comicCutscene("museum/e02_f18"),
    comic_e02_f19: comicCutscene("museum/e02_f19"),
    comic_e02_f20: comicCutscene("museum/e02_f20"),
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
    private lastPlacement: Record<string, Sprite.Type> = {};
    private visibleLastFrame: Record<string, Sprite.Type> = {};
    private visibleThisFrame: Record<string, Sprite.Type> = {};
    private localSlots: Record<string, AssetSlotConfig> = {};

    constructor(parent: Node.Type, order: number, private placeInScene?: (sprite: Sprite.Type, key: string, instance: string, x: number, y: number) => void) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
    }

    /** 在当前宿主实例上注册动态资源槽（也可使用顶层 registerDynamicSlot 全局注册） */
    registerDynamicSlot(key: string, cfg: AssetSlotConfig): void {
        this.localSlots[key] = cfg;
    }

    /** 仅返回本帧通过对应路径放置的精灵。 */
    currentSprite(instanceKey: string, path: string): Sprite.Type | undefined {
        return this.visibleThisFrame[instanceKey + ":" + path];
    }

    /** 隐藏此实例最近放置的帧；下一次正常放置会重新显示。 */
    hideLastPlacement(instanceKey: string): void {
        const sprite = this.lastPlacement[instanceKey];
        if (sprite !== undefined) {
            sprite.visible = false;
        }
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
    /** 循环进度为圈数。每个人物只复用一个精灵节点，逐帧改同一张贴图的采样范围。 */
    tryPlaceRun(
        actor: keyof typeof RUN_ATLASES,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        cycles: number,
        options: SpritePlacement = {},
        effort: number = 1,
    ): boolean {
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

    tryPlaceSlide(
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        progress: number,
        options: SpritePlacement = {},
    ): boolean {
        const frame = Math.max(0, Math.min(SLIDE_FRAME_COUNT - 1, Math.floor(progress * SLIDE_FRAME_COUNT)));
        return this.tryPlaceMotionFrame(SLIDE_ATLAS, frame, instanceKey, x, y, targetW, targetH, options);
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
                // The texture crop sets UVs. Dora keeps the original node size until it is resized.
                loaded.size = Size(textureRect.width, textureRect.height);
            }

            loaded.filter = smooth ? TextureFilter.Anisotropic : TextureFilter.Point;
            loaded.addTo(this.container);
            this.sprites[key] = loaded;
            sprite = loaded;
        }

        if (textureRect !== undefined) {
            sprite.textureRect = textureRect;
        }
        const baseScaleY = targetH / Math.max(1, textureRect?.height ?? sprite.height);
        const baseScaleX = preserveAspect ? baseScaleY : targetW / Math.max(1, sprite.width);
        const scaleX = baseScaleX * (options.scaleXMul ?? 1);
        const scaleY = baseScaleY * (options.scaleYMul ?? 1);
        sprite.anchor = Vec2(anchorX, anchorY);
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
        this.lastPlacement[instanceKey] = sprite;
        if (this.placeInScene !== undefined) {
            this.placeInScene(sprite, key, instanceKey, x, y);
        }
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
