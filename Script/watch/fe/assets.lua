-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local FALLBACK_DYNAMIC_SLOTS -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Node = ____Dora.Node -- 1
local Rect = ____Dora.Rect -- 1
local Size = ____Dora.Size -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local function backdrop(name, smooth) -- 80
	if smooth == nil then -- 80
		smooth = false -- 80
	end -- 80
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 81
end -- 80
local function clip(names, anchorY, preserveAspect, anchorX) -- 86
	if anchorY == nil then -- 86
		anchorY = 0 -- 88
	end -- 88
	if preserveAspect == nil then -- 88
		preserveAspect = false -- 89
	end -- 89
	local frames = type(names) == "string" and ({names}) or names -- 92
	return { -- 93
		paths = __TS__ArrayMap( -- 93
			frames, -- 93
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 93
		), -- 93
		anchorX = anchorX, -- 93
		anchorY = anchorY, -- 93
		preserveAspect = preserveAspect -- 93
	} -- 93
end -- 86
local function inkClip(name, preserveAspect) -- 96
	if preserveAspect == nil then -- 96
		preserveAspect = false -- 96
	end -- 96
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 97
end -- 96
local function actor(names, anchorX) -- 100
	return clip(names, 0, true, anchorX) -- 101
end -- 100
local function slide(name) -- 104
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 105
end -- 104
local function comicCutscene(rel) -- 108
	return {paths = {("assets/art/cutscenes/" .. rel) .. ".png"}, anchorY = 0.5, preserveAspect = false, smooth = true} -- 109
end -- 108
local function feClip(names, anchorY, preserveAspect, anchorX) -- 112
	if anchorY == nil then -- 112
		anchorY = 0.5 -- 114
	end -- 114
	if preserveAspect == nil then -- 114
		preserveAspect = true -- 115
	end -- 115
	local frames = type(names) == "string" and ({names}) or names -- 118
	return { -- 119
		paths = __TS__ArrayMap( -- 119
			frames, -- 119
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 119
		), -- 119
		anchorX = anchorX, -- 119
		anchorY = anchorY, -- 119
		preserveAspect = preserveAspect -- 119
	} -- 119
end -- 112
local function character(names) -- 122
	local frames = type(names) == "string" and ({names}) or names -- 123
	return { -- 124
		paths = __TS__ArrayMap( -- 124
			frames, -- 124
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 124
		), -- 124
		anchorY = 0, -- 124
		preserveAspect = true -- 124
	} -- 124
end -- 122
____exports.RUN_FRAME_COUNT = 160 -- 127
____exports.RUN_TRANSITION_PHASES = 8 -- 128
____exports.RUN_TRANSITION_LEVELS = 12 -- 129
____exports.SLIDE_FRAME_COUNT = 64 -- 130
local ATLAS_GUTTER = 2 -- 131
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 140
local RUN_TRANSITIONS = { -- 144
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 145
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 146
} -- 146
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 148
____exports.ASSET_SLOTS = { -- 152
	bgFar_prologue = backdrop("prologue"), -- 153
	bgFar_street = backdrop("street"), -- 154
	bgFar_checkpoint = backdrop("checkpoint"), -- 155
	bgFar_gate = backdrop("gate"), -- 156
	bgFar_outside = backdrop("outside"), -- 157
	bgFar_village = backdrop("village"), -- 158
	bgFar_forest = backdrop("forest"), -- 159
	bgFar_tower = backdrop("tower"), -- 160
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods"), -- 161
	bgFar_archway_yard = backdrop("bg_archway_yard"), -- 162
	bgFar_granary = backdrop("bg_granary"), -- 163
	bgFar_escort_ridge = backdrop("bg_escort_ridge"), -- 164
	bgFar_museum = backdrop("bg_museum_hall", true), -- 165
	title_backdrop = backdrop("title"), -- 166
	soldier_idle = character("soldier_idle"), -- 167
	soldier_run = character({"soldier_run", "soldier_step"}), -- 168
	soldier_roll = character("soldier_roll"), -- 169
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 170
	soldier_cover = character("soldier_cover"), -- 171
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 172
	soldier_hold = character("soldier_hold"), -- 173
	soldier_offer = character("soldier_offer"), -- 174
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 175
	soldier_hit = character("soldier_hit"), -- 176
	soldier_fire = character("soldier_fire"), -- 177
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 178
	child_idle = character("child_idle"), -- 179
	child_run = character({"child_run", "child_step"}), -- 180
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 181
	child_fear = character("child_fear"), -- 182
	child_peek = character("child_peek"), -- 183
	child_pull = character({"child_pull", "child_pull_step"}), -- 184
	child_aim = character("child_aim"), -- 185
	child_throw = character("child_throw"), -- 186
	child_knock = character("child_knock"), -- 187
	child_offer = character("child_offer"), -- 188
	enemy_idle = actor("enemy_idle", 0.5), -- 189
	enemy_aim = actor("enemy_aim", 0.51), -- 190
	enemy_down = actor("enemy_down"), -- 191
	enemy_hit = actor("enemy_hit", 0.48), -- 192
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 193
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 194
	prop_cart = clip("cart", 0, false, 0.44), -- 195
	prop_bottle = clip("bottle", 0.5, true), -- 196
	prop_tower_door = clip("door"), -- 197
	prop_lantern = clip("lantern", 0.5, true), -- 198
	prop_table = clip("table"), -- 199
	prop_compass = clip("compass", 0.5, true), -- 200
	prop_winch = clip("winch", 0.5, true), -- 201
	wall = clip("wall"), -- 202
	cover_wood = clip("cover_wood"), -- 203
	cover_stone = clip("cover_stone"), -- 204
	fence = clip("fence"), -- 205
	slab = clip("slab"), -- 206
	eaves = clip("eaves"), -- 207
	pine = clip("pine"), -- 208
	grass = clip("grass"), -- 209
	grass_low = clip("grass_low"), -- 210
	stone_chips = clip("stone_chips", 0.5, true), -- 211
	ui_corner = clip("ui_corner"), -- 212
	ui_corner_c = clip("ui_corner", 0.5, false), -- 213
	ui_paper = clip("paper", 0.5), -- 214
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 215
	ink_mist_curve = inkClip("ink_mist_curve"), -- 216
	ink_veil_strip = inkClip("ink_veil_strip"), -- 217
	ink_hairline = inkClip("ink_hairline"), -- 218
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 219
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 220
	ink_frame_mask = inkClip("ink_frame_mask"), -- 221
	ink_vstream = inkClip("ink_vstream"), -- 222
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 223
	ink_corner_fine = inkClip("ink_corner_fine"), -- 224
	ink_seal_slender = inkClip("ink_seal_slender"), -- 225
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 226
	ink_enso_fine = inkClip("ink_enso_fine"), -- 227
	ink_petal_mist = inkClip("ink_petal_mist"), -- 228
	ink_song_paper = inkClip("ink_song_paper"), -- 229
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 230
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 231
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 232
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 233
	slide_p01_01 = slide("p01_01_curtain"), -- 235
	slide_p01_02 = slide("p01_02_hand"), -- 236
	slide_p01_03 = slide("p01_03_door"), -- 237
	slide_p02_01 = slide("p02_01_shadows"), -- 238
	slide_p02_02 = slide("p02_02_cut"), -- 239
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 240
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 241
	slide_p02_05 = slide("p02_05_cabinet"), -- 242
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 243
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 244
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 245
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 246
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 247
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 248
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 249
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 250
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 251
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 252
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 253
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 254
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 255
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 256
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 257
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 258
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 259
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 260
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 261
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 262
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 263
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 264
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 265
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 266
	slide_e01_well = slide("e01_01_well"), -- 267
	slide_e01_compass = slide("e01_02_compass"), -- 268
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 269
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 270
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 271
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 272
	slide_f01_sewing = slide("f01_sewing_memory"), -- 273
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 274
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 275
	comic_p02_01_shadows = comicCutscene("p02/p02_01_shadows"), -- 277
	comic_p02_02a_door_intrude = comicCutscene("p02/p02_02a_door_intrude"), -- 278
	comic_p02_03_impact_cut = comicCutscene("p02/p02_03_impact_cut"), -- 279
	comic_p02_04_shadows_fall = comicCutscene("p02/p02_04_shadows_fall"), -- 280
	comic_p02_05_bowl_roll1 = comicCutscene("p02/p02_05_bowl_roll1"), -- 281
	comic_p02_06_bowl_roll2 = comicCutscene("p02/p02_06_bowl_roll2"), -- 282
	comic_p02_07_bowl_smash = comicCutscene("p02/p02_07_bowl_smash"), -- 283
	comic_p02_08a_cabinet_slit = comicCutscene("p02/p02_08a_cabinet_slit"), -- 284
	comic_p02_08m_cabinet_narrowing = comicCutscene("p02/p02_08m_cabinet_narrowing"), -- 285
	comic_p02_08b_cabinet_shut = comicCutscene("p02/p02_08b_cabinet_shut"), -- 286
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 288
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 289
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 290
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 291
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 292
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 293
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 294
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 295
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 296
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 297
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 298
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 299
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 300
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 301
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 302
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 303
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 304
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 305
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 306
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 307
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 308
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 309
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 310
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 311
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 312
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 313
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 314
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 315
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 316
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 317
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 318
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 319
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 320
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 321
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 322
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 323
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 324
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 325
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 326
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 327
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 328
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 329
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 330
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 331
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 332
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 333
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 334
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 335
} -- 335
local WHITE = Color(255, 255, 255, 255) -- 338
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 344
	local g = _G -- 345
	local ____temp_0 -- 346
	if g.package ~= nil then -- 346
		____temp_0 = g.package.loaded -- 346
	else -- 346
		____temp_0 = nil -- 346
	end -- 346
	local loaded = ____temp_0 -- 346
	if loaded ~= nil then -- 346
		local existing = loaded["watch.fe.dynamic_slots"] -- 348
		if existing ~= nil and type(existing) == "table" then -- 348
			return existing -- 350
		end -- 350
		local created = {} -- 352
		loaded["watch.fe.dynamic_slots"] = created -- 353
		return created -- 354
	end -- 354
	return FALLBACK_DYNAMIC_SLOTS -- 356
end -- 344
FALLBACK_DYNAMIC_SLOTS = {} -- 359
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 362
	sharedDynamicSlots()[key] = cfg -- 363
end -- 362
function ____exports.unregisterDynamicSlot(key) -- 366
	__TS__Delete( -- 367
		sharedDynamicSlots(), -- 367
		key -- 367
	) -- 367
end -- 366
____exports.AssetSlotHost = __TS__Class() -- 370
local AssetSlotHost = ____exports.AssetSlotHost -- 370
AssetSlotHost.name = "AssetSlotHost" -- 370
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 379
	self.sprites = {} -- 372
	self.unavailable = {} -- 373
	self.lastPlacement = {} -- 374
	self.visibleLastFrame = {} -- 375
	self.visibleThisFrame = {} -- 376
	self.localSlots = {} -- 377
	self.container = Node() -- 380
	self.container.order = order -- 381
	self.container:addTo(parent) -- 382
end -- 379
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 386
	self.localSlots[key] = cfg -- 387
end -- 386
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 391
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 392
end -- 391
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 396
	local sprite = self.lastPlacement[instanceKey] -- 397
	if sprite ~= nil then -- 397
		sprite.visible = false -- 399
	end -- 399
end -- 396
function AssetSlotHost.prototype.beginFrame(self) -- 403
	self.visibleThisFrame = {} -- 404
end -- 403
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 407
	if options == nil then -- 407
		options = {} -- 411
	end -- 411
	local staticSlots = ____exports.ASSET_SLOTS -- 413
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 414
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 414
		return false -- 416
	end -- 416
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 418
	local path = cfg.paths[frame + 1] -- 419
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 420
	return self:placeResolvedPath( -- 423
		path, -- 423
		anchorX, -- 423
		cfg.anchorY, -- 423
		cfg.preserveAspect, -- 423
		cfg.smooth == true, -- 423
		instanceKey, -- 423
		x, -- 423
		y, -- 423
		targetW, -- 423
		targetH, -- 423
		options -- 423
	) -- 423
end -- 407
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 428
	if options == nil then -- 428
		options = {} -- 433
	end -- 433
	if effort == nil then -- 433
		effort = 1 -- 434
	end -- 434
	if effort < 1 and self:tryPlaceRunTransition( -- 434
		actor, -- 436
		instanceKey, -- 436
		x, -- 436
		y, -- 436
		targetW, -- 436
		targetH, -- 436
		cycles, -- 436
		effort, -- 436
		options -- 436
	) then -- 436
		return true -- 437
	end -- 437
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 439
	return self:tryPlaceMotionFrame( -- 440
		RUN_ATLASES[actor], -- 440
		frame, -- 440
		instanceKey, -- 440
		x, -- 440
		y, -- 440
		targetW, -- 440
		targetH, -- 440
		options -- 440
	) -- 440
end -- 428
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 444
	if options == nil then -- 444
		options = {} -- 449
	end -- 449
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 451
	local level = math.max( -- 452
		0, -- 452
		math.min( -- 452
			____exports.RUN_TRANSITION_LEVELS - 1, -- 452
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 452
		) -- 452
	) -- 452
	return self:tryPlaceMotionFrame( -- 453
		RUN_TRANSITIONS[actor], -- 453
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 453
		instanceKey, -- 454
		x, -- 454
		y, -- 454
		targetW, -- 454
		targetH, -- 454
		options -- 454
	) -- 454
end -- 444
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 457
	if options == nil then -- 457
		options = {} -- 461
	end -- 461
	local frame = math.max( -- 463
		0, -- 463
		math.min( -- 463
			____exports.SLIDE_FRAME_COUNT - 1, -- 463
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 463
		) -- 463
	) -- 463
	return self:tryPlaceMotionFrame( -- 464
		SLIDE_ATLAS, -- 464
		frame, -- 464
		instanceKey, -- 464
		x, -- 464
		y, -- 464
		targetW, -- 464
		targetH, -- 464
		options -- 464
	) -- 464
end -- 457
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 467
	if targetW <= 0 or targetH <= 0 then -- 467
		return false -- 475
	end -- 475
	local ____atlas_1 = atlas -- 477
	local path = ____atlas_1.path -- 477
	local width = ____atlas_1.width -- 477
	local height = ____atlas_1.height -- 477
	local columns = ____atlas_1.columns -- 477
	local col = frame % columns -- 478
	local row = math.floor(frame / columns) -- 479
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 480
	return self:placeResolvedPath( -- 482
		path, -- 482
		0.5, -- 482
		0, -- 482
		true, -- 482
		false, -- 482
		instanceKey, -- 482
		x, -- 482
		y, -- 482
		targetW, -- 482
		targetH, -- 482
		options, -- 482
		rect -- 482
	) -- 482
end -- 467
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 486
	if options == nil then -- 486
		options = {} -- 490
	end -- 490
	if path == "" or targetW <= 0 or targetH <= 0 then -- 490
		return false -- 493
	end -- 493
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 495
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 495
	local ____options_preserveAspect_2 = options.preserveAspect -- 499
	if ____options_preserveAspect_2 == nil then -- 499
		____options_preserveAspect_2 = false -- 499
	end -- 499
	__TS__SparseArrayPush( -- 499
		____array_3, -- 499
		____options_preserveAspect_2, -- 499
		options.smooth == true, -- 500
		instanceKey, -- 501
		x, -- 502
		y, -- 503
		targetW, -- 504
		targetH, -- 505
		options -- 506
	) -- 506
	return ____self_placeResolvedPath_4( -- 495
		self, -- 495
		__TS__SparseArraySpread(____array_3) -- 495
	) -- 495
end -- 486
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 510
	local key = (instanceKey .. ":") .. path -- 521
	local sprite = self.sprites[key] -- 522
	if sprite == nil then -- 522
		if self.unavailable[path] then -- 522
			return false -- 525
		end -- 525
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 527
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 528
		local ____Content_exist_result_5 -- 529
		if Content:exist(file) then -- 529
			____Content_exist_result_5 = Sprite(path) -- 529
		else -- 529
			____Content_exist_result_5 = nil -- 529
		end -- 529
		local loaded = ____Content_exist_result_5 -- 529
		if loaded == nil then -- 529
			self.unavailable[path] = true -- 531
			return false -- 532
		end -- 532
		if textureRect ~= nil then -- 532
			loaded.size = Size(textureRect.width, textureRect.height) -- 536
		end -- 536
		loaded.filter = smooth and "Anisotropic" or "Point" -- 539
		loaded:addTo(self.container) -- 540
		self.sprites[key] = loaded -- 541
		sprite = loaded -- 542
	end -- 542
	if textureRect ~= nil then -- 542
		sprite.textureRect = textureRect -- 546
	end -- 546
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 548
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 549
	sprite.anchor = Vec2(anchorX, anchorY) -- 550
	sprite.position = textureRect == nil and Vec2( -- 551
		math.floor(x + 0.5), -- 551
		math.floor(y + 0.5) -- 551
	) or Vec2(x, y) -- 551
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 552
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 553
	sprite.angle = options.angle or 0 -- 554
	sprite.order = options.layer or 0 -- 555
	local col = options.color or WHITE -- 556
	sprite.color = col -- 557
	local baseA = col.a / 255 -- 558
	local op = options.opacity or 1 -- 559
	sprite.opacity = math.max( -- 560
		0, -- 560
		math.min(1, baseA * op) -- 560
	) -- 560
	sprite.visible = true -- 561
	self.visibleThisFrame[key] = sprite -- 562
	self.lastPlacement[instanceKey] = sprite -- 563
	return true -- 564
end -- 510
function AssetSlotHost.prototype.endFrame(self) -- 567
	for key in pairs(self.visibleLastFrame) do -- 568
		if self.visibleThisFrame[key] == nil then -- 568
			self.visibleLastFrame[key].visible = false -- 570
		end -- 570
	end -- 570
	self.visibleLastFrame = self.visibleThisFrame -- 573
end -- 567
return ____exports -- 567