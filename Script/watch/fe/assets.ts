import { Color, Content, Node, Sprite, TextureFilter, Vec2 } from "Dora";

export type AssetSlotKey =
    | "bgFar_prologue" | "bgFar_street" | "bgFar_checkpoint" | "bgFar_gate"
    | "bgFar_outside" | "bgFar_village" | "bgFar_forest" | "bgFar_tower"
    | "soldier_idle" | "soldier_run" | "soldier_roll" | "soldier_cover"
    | "soldier_push" | "soldier_hold" | "soldier_offer" | "soldier_knock" | "soldier_hit" | "soldier_fire"
    | "child_idle" | "child_run" | "child_crouch" | "child_fear" | "child_peek"
    | "child_pull" | "child_aim" | "child_throw" | "child_knock" | "child_offer"
    | "enemy_idle" | "enemy_aim" | "enemy_down" | "enemy_hit" | "scavenger" | "dog"
    | "prop_cart" | "prop_bottle" | "prop_tower_door" | "prop_lantern" | "prop_table"
    | "prop_compass" | "prop_winch" | "wall" | "cover_wood" | "cover_stone" | "fence"
    | "slab" | "eaves" | "pine" | "grass" | "grass_low"
    | "stone_chips" | "ui_corner" | "ui_corner_c" | "ui_paper" | "title_backdrop"
    | "ink_brush_wide" | "ink_brush_sym" | "ink_divider" | "ink_scroll_bar"
    | "ink_wash_panel" | "ink_vbrush" | "ink_seal_solid" | "ink_seal_hollow"
    | "ink_seal_oval" | "ink_dot" | "ink_ring" | "ink_splatter"
    | "ink_hp_bar" | "ink_hp_slot" | "ink_paper_grain";

interface AssetSlotConfig {
    paths: string[];
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

function backdrop(name: string): AssetSlotConfig {
    return { paths: ["assets/art/" + name + ".png"], anchorY: 0, preserveAspect: false };
}

function clip(names: string | string[], anchorY: number = 0, preserveAspect: boolean = false): AssetSlotConfig {
    const frames = typeof names === "string" ? [names] : names;
    return { paths: frames.map(name => "assets/art/sprites.clip|" + name), anchorY, preserveAspect };
}

function inkClip(name: string, preserveAspect: boolean = false): AssetSlotConfig {
    return { paths: ["assets/art/ui_ink.clip|" + name], anchorY: 0.5, preserveAspect, smooth: true };
}

function actor(names: string | string[]): AssetSlotConfig {
    return clip(names, 0, true);
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
    soldier_run: actor(["soldier_run", "soldier_idle", "soldier_step", "soldier_idle"]),
    soldier_roll: actor("soldier_roll"),
    soldier_cover: actor("soldier_cover"),
    soldier_push: actor(["soldier_push", "soldier_push_step"]),
    soldier_hold: actor("soldier_hold"),
    soldier_offer: actor("soldier_offer"),
    soldier_knock: actor(["soldier_cover", "soldier_knock"]),
    soldier_hit: actor("soldier_hit"),
    soldier_fire: actor("soldier_fire"),
    child_idle: actor("child_idle"),
    child_run: actor(["child_run", "child_idle", "child_step", "child_idle"]),
    child_crouch: actor(["child_crouch", "child_crouch_step"]),
    child_fear: actor("child_fear"),
    child_peek: actor("child_peek"),
    child_pull: actor(["child_pull", "child_pull_step"]),
    child_aim: actor("child_aim"),
    child_throw: actor("child_throw"),
    child_knock: actor("child_knock"),
    child_offer: actor("child_offer"),
    enemy_idle: actor("enemy_idle"),
    enemy_aim: actor("enemy_aim"),
    enemy_down: actor("enemy_down"),
    enemy_hit: actor("enemy_hit"),
    scavenger: actor(["scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"]),
    dog: actor(["dog_idle", "dog_alert", "dog_run", "dog_sniff"]),
    prop_cart: clip("cart"),
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
    ink_brush_wide: inkClip("ink_brush_wide"),
    ink_brush_sym: inkClip("ink_brush_sym"),
    ink_divider: inkClip("ink_divider"),
    ink_scroll_bar: inkClip("ink_scroll_bar"),
    ink_wash_panel: inkClip("ink_wash_panel"),
    ink_vbrush: inkClip("ink_vbrush"),
    ink_seal_solid: inkClip("ink_seal_solid"),
    ink_seal_hollow: inkClip("ink_seal_hollow"),
    ink_seal_oval: inkClip("ink_seal_oval"),
    ink_dot: inkClip("ink_dot"),
    ink_ring: inkClip("ink_ring"),
    ink_splatter: inkClip("ink_splatter"),
    ink_hp_bar: inkClip("ink_hp_bar"),
    ink_hp_slot: inkClip("ink_hp_slot"),
    ink_paper_grain: inkClip("ink_paper_grain"),
};

const WHITE = Color(255, 255, 255, 255);

export class AssetSlotHost {
    private container: Node.Type;
    private sprites: Record<string, Sprite.Type> = {};
    private unavailable: Record<string, boolean> = {};
    private visibleLastFrame: Record<string, Sprite.Type> = {};
    private visibleThisFrame: Record<string, Sprite.Type> = {};

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
    }

    beginFrame(): void {
        this.visibleThisFrame = {};
    }

    tryPlace(
        slotKey: AssetSlotKey,
        instanceKey: string,
        x: number, y: number, targetW: number, targetH: number,
        options: SpritePlacement = {},
    ): boolean {
        const cfg = ASSET_SLOTS[slotKey];
        if (cfg === undefined || targetW <= 0 || targetH <= 0) {
            return false;
        }
        const frame = (options.frame ?? 0) % cfg.paths.length;
        const path = cfg.paths[frame];
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
            loaded.anchor = Vec2(0.5, cfg.anchorY);
            loaded.filter = cfg.smooth ? TextureFilter.Anisotropic : TextureFilter.Point;
            loaded.addTo(this.container);
            this.sprites[key] = loaded;
            sprite = loaded;
        }

        const scaleY = targetH / Math.max(1, sprite.height);
        const scaleX = cfg.preserveAspect ? scaleY : targetW / Math.max(1, sprite.width);
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
