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
local function backdrop(name, smooth) -- 79
	if smooth == nil then -- 79
		smooth = false -- 79
	end -- 79
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 80
end -- 79
local function clip(names, anchorY, preserveAspect, anchorX) -- 85
	if anchorY == nil then -- 85
		anchorY = 0 -- 87
	end -- 87
	if preserveAspect == nil then -- 87
		preserveAspect = false -- 88
	end -- 88
	local frames = type(names) == "string" and ({names}) or names -- 91
	return { -- 92
		paths = __TS__ArrayMap( -- 92
			frames, -- 92
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 92
		), -- 92
		anchorX = anchorX, -- 92
		anchorY = anchorY, -- 92
		preserveAspect = preserveAspect -- 92
	} -- 92
end -- 85
local function inkClip(name, preserveAspect) -- 95
	if preserveAspect == nil then -- 95
		preserveAspect = false -- 95
	end -- 95
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 96
end -- 95
local function actor(names, anchorX) -- 99
	return clip(names, 0, true, anchorX) -- 100
end -- 99
local function slide(name) -- 103
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 104
end -- 103
local function feClip(names, anchorY, preserveAspect, anchorX) -- 107
	if anchorY == nil then -- 107
		anchorY = 0.5 -- 109
	end -- 109
	if preserveAspect == nil then -- 109
		preserveAspect = true -- 110
	end -- 110
	local frames = type(names) == "string" and ({names}) or names -- 113
	return { -- 114
		paths = __TS__ArrayMap( -- 114
			frames, -- 114
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 114
		), -- 114
		anchorX = anchorX, -- 114
		anchorY = anchorY, -- 114
		preserveAspect = preserveAspect -- 114
	} -- 114
end -- 107
local function character(names) -- 117
	local frames = type(names) == "string" and ({names}) or names -- 118
	return { -- 119
		paths = __TS__ArrayMap( -- 119
			frames, -- 119
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 119
		), -- 119
		anchorY = 0, -- 119
		preserveAspect = true -- 119
	} -- 119
end -- 117
____exports.RUN_FRAME_COUNT = 160 -- 122
____exports.RUN_TRANSITION_PHASES = 8 -- 123
____exports.RUN_TRANSITION_LEVELS = 12 -- 124
____exports.SLIDE_FRAME_COUNT = 64 -- 125
local ATLAS_GUTTER = 2 -- 126
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 135
local RUN_TRANSITIONS = { -- 139
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 140
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 141
} -- 141
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 143
____exports.ASSET_SLOTS = { -- 147
	bgFar_prologue = backdrop("prologue"), -- 148
	bgFar_street = backdrop("street"), -- 149
	bgFar_checkpoint = backdrop("checkpoint"), -- 150
	bgFar_gate = backdrop("gate"), -- 151
	bgFar_outside = backdrop("outside"), -- 152
	bgFar_village = backdrop("village"), -- 153
	bgFar_forest = backdrop("forest"), -- 154
	bgFar_tower = backdrop("tower"), -- 155
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods", true), -- 156
	bgFar_archway_yard = backdrop("bg_archway_yard", true), -- 157
	bgFar_granary = backdrop("bg_granary", true), -- 158
	bgFar_escort_ridge = backdrop("bg_escort_ridge", true), -- 159
	bgFar_museum = backdrop("bg_museum_hall", true), -- 160
	title_backdrop = backdrop("title"), -- 161
	soldier_idle = character("soldier_idle"), -- 162
	soldier_run = character({"soldier_run", "soldier_step"}), -- 163
	soldier_roll = character("soldier_roll"), -- 164
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 165
	soldier_cover = character("soldier_cover"), -- 166
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 167
	soldier_hold = character("soldier_hold"), -- 168
	soldier_offer = character("soldier_offer"), -- 169
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 170
	soldier_hit = character("soldier_hit"), -- 171
	soldier_fire = character("soldier_fire"), -- 172
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 173
	child_idle = character("child_idle"), -- 174
	child_run = character({"child_run", "child_step"}), -- 175
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 176
	child_fear = character("child_fear"), -- 177
	child_peek = character("child_peek"), -- 178
	child_pull = character({"child_pull", "child_pull_step"}), -- 179
	child_aim = character("child_aim"), -- 180
	child_throw = character("child_throw"), -- 181
	child_knock = character("child_knock"), -- 182
	child_offer = character("child_offer"), -- 183
	enemy_idle = actor("enemy_idle", 0.5), -- 184
	enemy_aim = actor("enemy_aim", 0.51), -- 185
	enemy_down = actor("enemy_down"), -- 186
	enemy_hit = actor("enemy_hit", 0.48), -- 187
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 188
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 189
	prop_cart = clip("cart", 0, false, 0.44), -- 190
	prop_bottle = clip("bottle", 0.5, true), -- 191
	prop_tower_door = clip("door"), -- 192
	prop_lantern = clip("lantern", 0.5, true), -- 193
	prop_table = clip("table"), -- 194
	prop_compass = clip("compass", 0.5, true), -- 195
	prop_winch = clip("winch", 0.5, true), -- 196
	wall = clip("wall"), -- 197
	cover_wood = clip("cover_wood"), -- 198
	cover_stone = clip("cover_stone"), -- 199
	fence = clip("fence"), -- 200
	slab = clip("slab"), -- 201
	eaves = clip("eaves"), -- 202
	pine = clip("pine"), -- 203
	grass = clip("grass"), -- 204
	grass_low = clip("grass_low"), -- 205
	stone_chips = clip("stone_chips", 0.5, true), -- 206
	ui_corner = clip("ui_corner"), -- 207
	ui_corner_c = clip("ui_corner", 0.5, false), -- 208
	ui_paper = clip("paper", 0.5), -- 209
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 210
	ink_mist_curve = inkClip("ink_mist_curve"), -- 211
	ink_veil_strip = inkClip("ink_veil_strip"), -- 212
	ink_hairline = inkClip("ink_hairline"), -- 213
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 214
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 215
	ink_frame_mask = inkClip("ink_frame_mask"), -- 216
	ink_vstream = inkClip("ink_vstream"), -- 217
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 218
	ink_corner_fine = inkClip("ink_corner_fine"), -- 219
	ink_seal_slender = inkClip("ink_seal_slender"), -- 220
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 221
	ink_enso_fine = inkClip("ink_enso_fine"), -- 222
	ink_petal_mist = inkClip("ink_petal_mist"), -- 223
	ink_song_paper = inkClip("ink_song_paper"), -- 224
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 225
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 226
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 227
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 228
	slide_p01_01 = slide("p01_01_curtain"), -- 230
	slide_p01_02 = slide("p01_02_hand"), -- 231
	slide_p01_03 = slide("p01_03_door"), -- 232
	slide_p02_01 = slide("p02_01_shadows"), -- 233
	slide_p02_02 = slide("p02_02_cut"), -- 234
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 235
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 236
	slide_p02_05 = slide("p02_05_cabinet"), -- 237
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 238
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 239
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 240
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 241
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 242
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 243
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 244
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 245
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 246
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 247
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 248
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 249
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 250
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 251
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 252
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 253
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 254
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 255
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 256
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 257
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 258
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 259
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 260
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 261
	slide_e01_well = slide("e01_01_well"), -- 262
	slide_e01_compass = slide("e01_02_compass"), -- 263
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 264
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 265
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 266
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 267
	slide_f01_sewing = slide("f01_sewing_memory"), -- 268
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 269
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 270
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 272
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 273
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 274
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 275
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 276
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 277
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 278
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 279
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 280
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 281
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 282
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 283
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 284
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 285
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 286
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 287
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 288
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 289
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 290
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 291
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 292
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 293
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 294
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 295
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 296
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 297
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 298
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 299
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 300
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 301
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 302
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 303
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 304
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 305
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 306
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 307
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 308
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 309
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 310
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 311
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 312
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 313
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 314
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 315
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 316
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 317
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 318
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 319
} -- 319
local WHITE = Color(255, 255, 255, 255) -- 322
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 328
	local g = _G -- 329
	local ____temp_0 -- 330
	if g.package ~= nil then -- 330
		____temp_0 = g.package.loaded -- 330
	else -- 330
		____temp_0 = nil -- 330
	end -- 330
	local loaded = ____temp_0 -- 330
	if loaded ~= nil then -- 330
		local existing = loaded["watch.fe.dynamic_slots"] -- 332
		if existing ~= nil and type(existing) == "table" then -- 332
			return existing -- 334
		end -- 334
		local created = {} -- 336
		loaded["watch.fe.dynamic_slots"] = created -- 337
		return created -- 338
	end -- 338
	return FALLBACK_DYNAMIC_SLOTS -- 340
end -- 328
FALLBACK_DYNAMIC_SLOTS = {} -- 343
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 346
	sharedDynamicSlots()[key] = cfg -- 347
end -- 346
function ____exports.unregisterDynamicSlot(key) -- 350
	__TS__Delete( -- 351
		sharedDynamicSlots(), -- 351
		key -- 351
	) -- 351
end -- 350
____exports.AssetSlotHost = __TS__Class() -- 354
local AssetSlotHost = ____exports.AssetSlotHost -- 354
AssetSlotHost.name = "AssetSlotHost" -- 354
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 363
	self.sprites = {} -- 356
	self.unavailable = {} -- 357
	self.lastPlacement = {} -- 358
	self.visibleLastFrame = {} -- 359
	self.visibleThisFrame = {} -- 360
	self.localSlots = {} -- 361
	self.container = Node() -- 364
	self.container.order = order -- 365
	self.container:addTo(parent) -- 366
end -- 363
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 370
	self.localSlots[key] = cfg -- 371
end -- 370
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 375
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 376
end -- 375
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 380
	local sprite = self.lastPlacement[instanceKey] -- 381
	if sprite ~= nil then -- 381
		sprite.visible = false -- 383
	end -- 383
end -- 380
function AssetSlotHost.prototype.beginFrame(self) -- 387
	self.visibleThisFrame = {} -- 388
end -- 387
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 391
	if options == nil then -- 391
		options = {} -- 395
	end -- 395
	local staticSlots = ____exports.ASSET_SLOTS -- 397
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 398
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 398
		return false -- 400
	end -- 400
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 402
	local path = cfg.paths[frame + 1] -- 403
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 404
	return self:placeResolvedPath( -- 407
		path, -- 407
		anchorX, -- 407
		cfg.anchorY, -- 407
		cfg.preserveAspect, -- 407
		cfg.smooth == true, -- 407
		instanceKey, -- 407
		x, -- 407
		y, -- 407
		targetW, -- 407
		targetH, -- 407
		options -- 407
	) -- 407
end -- 391
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 412
	if options == nil then -- 412
		options = {} -- 417
	end -- 417
	if effort == nil then -- 417
		effort = 1 -- 418
	end -- 418
	if effort < 1 and self:tryPlaceRunTransition( -- 418
		actor, -- 420
		instanceKey, -- 420
		x, -- 420
		y, -- 420
		targetW, -- 420
		targetH, -- 420
		cycles, -- 420
		effort, -- 420
		options -- 420
	) then -- 420
		return true -- 421
	end -- 421
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 423
	return self:tryPlaceMotionFrame( -- 424
		RUN_ATLASES[actor], -- 424
		frame, -- 424
		instanceKey, -- 424
		x, -- 424
		y, -- 424
		targetW, -- 424
		targetH, -- 424
		options -- 424
	) -- 424
end -- 412
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 428
	if options == nil then -- 428
		options = {} -- 433
	end -- 433
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 435
	local level = math.max( -- 436
		0, -- 436
		math.min( -- 436
			____exports.RUN_TRANSITION_LEVELS - 1, -- 436
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 436
		) -- 436
	) -- 436
	return self:tryPlaceMotionFrame( -- 437
		RUN_TRANSITIONS[actor], -- 437
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 437
		instanceKey, -- 438
		x, -- 438
		y, -- 438
		targetW, -- 438
		targetH, -- 438
		options -- 438
	) -- 438
end -- 428
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 441
	if options == nil then -- 441
		options = {} -- 445
	end -- 445
	local frame = math.max( -- 447
		0, -- 447
		math.min( -- 447
			____exports.SLIDE_FRAME_COUNT - 1, -- 447
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 447
		) -- 447
	) -- 447
	return self:tryPlaceMotionFrame( -- 448
		SLIDE_ATLAS, -- 448
		frame, -- 448
		instanceKey, -- 448
		x, -- 448
		y, -- 448
		targetW, -- 448
		targetH, -- 448
		options -- 448
	) -- 448
end -- 441
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 451
	if targetW <= 0 or targetH <= 0 then -- 451
		return false -- 459
	end -- 459
	local ____atlas_1 = atlas -- 461
	local path = ____atlas_1.path -- 461
	local width = ____atlas_1.width -- 461
	local height = ____atlas_1.height -- 461
	local columns = ____atlas_1.columns -- 461
	local col = frame % columns -- 462
	local row = math.floor(frame / columns) -- 463
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 464
	return self:placeResolvedPath( -- 466
		path, -- 466
		0.5, -- 466
		0, -- 466
		true, -- 466
		false, -- 466
		instanceKey, -- 466
		x, -- 466
		y, -- 466
		targetW, -- 466
		targetH, -- 466
		options, -- 466
		rect -- 466
	) -- 466
end -- 451
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 470
	if options == nil then -- 470
		options = {} -- 474
	end -- 474
	if path == "" or targetW <= 0 or targetH <= 0 then -- 474
		return false -- 477
	end -- 477
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 479
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 479
	local ____options_preserveAspect_2 = options.preserveAspect -- 483
	if ____options_preserveAspect_2 == nil then -- 483
		____options_preserveAspect_2 = false -- 483
	end -- 483
	__TS__SparseArrayPush( -- 483
		____array_3, -- 483
		____options_preserveAspect_2, -- 483
		options.smooth == true, -- 484
		instanceKey, -- 485
		x, -- 486
		y, -- 487
		targetW, -- 488
		targetH, -- 489
		options -- 490
	) -- 490
	return ____self_placeResolvedPath_4( -- 479
		self, -- 479
		__TS__SparseArraySpread(____array_3) -- 479
	) -- 479
end -- 470
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 494
	local key = (instanceKey .. ":") .. path -- 505
	local sprite = self.sprites[key] -- 506
	if sprite == nil then -- 506
		if self.unavailable[path] then -- 506
			return false -- 509
		end -- 509
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 511
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 512
		local ____Content_exist_result_5 -- 513
		if Content:exist(file) then -- 513
			____Content_exist_result_5 = Sprite(path) -- 513
		else -- 513
			____Content_exist_result_5 = nil -- 513
		end -- 513
		local loaded = ____Content_exist_result_5 -- 513
		if loaded == nil then -- 513
			self.unavailable[path] = true -- 515
			return false -- 516
		end -- 516
		if textureRect ~= nil then -- 516
			loaded.size = Size(textureRect.width, textureRect.height) -- 520
		end -- 520
		loaded.filter = smooth and "Anisotropic" or "Point" -- 523
		loaded:addTo(self.container) -- 524
		self.sprites[key] = loaded -- 525
		sprite = loaded -- 526
	end -- 526
	if textureRect ~= nil then -- 526
		sprite.textureRect = textureRect -- 530
	end -- 530
	local baseScaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 532
	local baseScaleX = preserveAspect and baseScaleY or targetW / math.max(1, sprite.width) -- 533
	local scaleX = baseScaleX * (options.scaleXMul or 1) -- 534
	local scaleY = baseScaleY * (options.scaleYMul or 1) -- 535
	sprite.anchor = Vec2(anchorX, anchorY) -- 536
	sprite.position = textureRect == nil and Vec2( -- 537
		math.floor(x + 0.5), -- 537
		math.floor(y + 0.5) -- 537
	) or Vec2(x, y) -- 537
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 538
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 539
	sprite.angle = options.angle or 0 -- 540
	sprite.order = options.layer or 0 -- 541
	local col = options.color or WHITE -- 542
	sprite.color = col -- 543
	local baseA = col.a / 255 -- 544
	local op = options.opacity or 1 -- 545
	sprite.opacity = math.max( -- 546
		0, -- 546
		math.min(1, baseA * op) -- 546
	) -- 546
	sprite.visible = true -- 547
	self.visibleThisFrame[key] = sprite -- 548
	self.lastPlacement[instanceKey] = sprite -- 549
	return true -- 550
end -- 494
function AssetSlotHost.prototype.endFrame(self) -- 553
	for key in pairs(self.visibleLastFrame) do -- 554
		if self.visibleThisFrame[key] == nil then -- 554
			self.visibleLastFrame[key].visible = false -- 556
		end -- 556
	end -- 556
	self.visibleLastFrame = self.visibleThisFrame -- 559
end -- 553
return ____exports -- 553