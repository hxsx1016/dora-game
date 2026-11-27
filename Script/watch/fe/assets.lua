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
local function backdrop(name, smooth) -- 76
	if smooth == nil then -- 76
		smooth = false -- 76
	end -- 76
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 77
end -- 76
local function clip(names, anchorY, preserveAspect, anchorX) -- 82
	if anchorY == nil then -- 82
		anchorY = 0 -- 84
	end -- 84
	if preserveAspect == nil then -- 84
		preserveAspect = false -- 85
	end -- 85
	local frames = type(names) == "string" and ({names}) or names -- 88
	return { -- 89
		paths = __TS__ArrayMap( -- 89
			frames, -- 89
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 89
		), -- 89
		anchorX = anchorX, -- 89
		anchorY = anchorY, -- 89
		preserveAspect = preserveAspect -- 89
	} -- 89
end -- 82
local function inkClip(name, preserveAspect) -- 92
	if preserveAspect == nil then -- 92
		preserveAspect = false -- 92
	end -- 92
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 93
end -- 92
local function actor(names, anchorX) -- 96
	return clip(names, 0, true, anchorX) -- 97
end -- 96
local function slide(name) -- 100
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 101
end -- 100
local function feClip(names, anchorY, preserveAspect, anchorX) -- 104
	if anchorY == nil then -- 104
		anchorY = 0.5 -- 106
	end -- 106
	if preserveAspect == nil then -- 106
		preserveAspect = true -- 107
	end -- 107
	local frames = type(names) == "string" and ({names}) or names -- 110
	return { -- 111
		paths = __TS__ArrayMap( -- 111
			frames, -- 111
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 111
		), -- 111
		anchorX = anchorX, -- 111
		anchorY = anchorY, -- 111
		preserveAspect = preserveAspect -- 111
	} -- 111
end -- 104
local function character(names) -- 114
	local frames = type(names) == "string" and ({names}) or names -- 115
	return { -- 116
		paths = __TS__ArrayMap( -- 116
			frames, -- 116
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 116
		), -- 116
		anchorY = 0, -- 116
		preserveAspect = true -- 116
	} -- 116
end -- 114
____exports.RUN_FRAME_COUNT = 160 -- 119
____exports.RUN_TRANSITION_PHASES = 8 -- 120
____exports.RUN_TRANSITION_LEVELS = 12 -- 121
____exports.SLIDE_FRAME_COUNT = 64 -- 122
local ATLAS_GUTTER = 2 -- 123
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 132
local RUN_TRANSITIONS = { -- 136
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 137
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 138
} -- 138
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 140
____exports.ASSET_SLOTS = { -- 144
	bgFar_prologue = backdrop("prologue"), -- 145
	bgFar_street = backdrop("street"), -- 146
	bgFar_checkpoint = backdrop("checkpoint"), -- 147
	bgFar_gate = backdrop("gate"), -- 148
	bgFar_outside = backdrop("outside"), -- 149
	bgFar_village = backdrop("village"), -- 150
	bgFar_forest = backdrop("forest"), -- 151
	bgFar_tower = backdrop("tower"), -- 152
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods", true), -- 153
	bgFar_archway_yard = backdrop("bg_archway_yard", true), -- 154
	bgFar_granary = backdrop("bg_granary", true), -- 155
	bgFar_escort_ridge = backdrop("bg_escort_ridge", true), -- 156
	bgFar_museum = backdrop("bg_museum_hall", true), -- 157
	title_backdrop = backdrop("title"), -- 158
	soldier_idle = character("soldier_idle"), -- 159
	soldier_run = character({"soldier_run", "soldier_step"}), -- 160
	soldier_roll = character("soldier_roll"), -- 161
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 162
	soldier_cover = character("soldier_cover"), -- 163
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 164
	soldier_hold = character("soldier_hold"), -- 165
	soldier_offer = character("soldier_offer"), -- 166
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 167
	soldier_hit = character("soldier_hit"), -- 168
	soldier_fire = character("soldier_fire"), -- 169
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 170
	child_idle = character("child_idle"), -- 171
	child_run = character({"child_run", "child_step"}), -- 172
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 173
	child_fear = character("child_fear"), -- 174
	child_peek = character("child_peek"), -- 175
	child_pull = character({"child_pull", "child_pull_step"}), -- 176
	child_aim = character("child_aim"), -- 177
	child_throw = character("child_throw"), -- 178
	child_knock = character("child_knock"), -- 179
	child_offer = character("child_offer"), -- 180
	enemy_idle = actor("enemy_idle", 0.5), -- 181
	enemy_aim = actor("enemy_aim", 0.51), -- 182
	enemy_down = actor("enemy_down"), -- 183
	enemy_hit = actor("enemy_hit", 0.48), -- 184
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 185
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 186
	prop_cart = clip("cart", 0, false, 0.44), -- 187
	prop_bottle = clip("bottle", 0.5, true), -- 188
	prop_tower_door = clip("door"), -- 189
	prop_lantern = clip("lantern", 0.5, true), -- 190
	prop_table = clip("table"), -- 191
	prop_compass = clip("compass", 0.5, true), -- 192
	prop_winch = clip("winch", 0.5, true), -- 193
	wall = clip("wall"), -- 194
	cover_wood = clip("cover_wood"), -- 195
	cover_stone = clip("cover_stone"), -- 196
	fence = clip("fence"), -- 197
	slab = clip("slab"), -- 198
	eaves = clip("eaves"), -- 199
	pine = clip("pine"), -- 200
	grass = clip("grass"), -- 201
	grass_low = clip("grass_low"), -- 202
	stone_chips = clip("stone_chips", 0.5, true), -- 203
	ui_corner = clip("ui_corner"), -- 204
	ui_corner_c = clip("ui_corner", 0.5, false), -- 205
	ui_paper = clip("paper", 0.5), -- 206
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 207
	ink_mist_curve = inkClip("ink_mist_curve"), -- 208
	ink_veil_strip = inkClip("ink_veil_strip"), -- 209
	ink_hairline = inkClip("ink_hairline"), -- 210
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 211
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 212
	ink_frame_mask = inkClip("ink_frame_mask"), -- 213
	ink_vstream = inkClip("ink_vstream"), -- 214
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 215
	ink_corner_fine = inkClip("ink_corner_fine"), -- 216
	ink_seal_slender = inkClip("ink_seal_slender"), -- 217
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 218
	ink_enso_fine = inkClip("ink_enso_fine"), -- 219
	ink_petal_mist = inkClip("ink_petal_mist"), -- 220
	ink_song_paper = inkClip("ink_song_paper"), -- 221
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 222
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 223
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 224
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 225
	slide_p01_01 = slide("p01_01_curtain"), -- 227
	slide_p01_02 = slide("p01_02_hand"), -- 228
	slide_p01_03 = slide("p01_03_door"), -- 229
	slide_p02_01 = slide("p02_01_shadows"), -- 230
	slide_p02_02 = slide("p02_02_cut"), -- 231
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 232
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 233
	slide_p02_05 = slide("p02_05_cabinet"), -- 234
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 235
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 236
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 237
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 238
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 239
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 240
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 241
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 242
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 243
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 244
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 245
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 246
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 247
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 248
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 249
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 250
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 251
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 252
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 253
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 254
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 255
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 256
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 257
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 258
	slide_e01_well = slide("e01_01_well"), -- 259
	slide_e01_compass = slide("e01_02_compass"), -- 260
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 261
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 262
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 263
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 264
	slide_f01_sewing = slide("f01_sewing_memory"), -- 265
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 266
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 267
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 269
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 270
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 271
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 272
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 273
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 274
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 275
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 276
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 277
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 278
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 279
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 280
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 281
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 282
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 283
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 284
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 285
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 286
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 287
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 288
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 289
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 290
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 291
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 292
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 293
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 294
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 295
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 296
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 297
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 298
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 299
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 300
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 301
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 302
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 303
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 304
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 305
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 306
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 307
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 308
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 309
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 310
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 311
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 312
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 313
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 314
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 315
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 316
} -- 316
local WHITE = Color(255, 255, 255, 255) -- 319
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 325
	local g = _G -- 326
	local ____temp_0 -- 327
	if g.package ~= nil then -- 327
		____temp_0 = g.package.loaded -- 327
	else -- 327
		____temp_0 = nil -- 327
	end -- 327
	local loaded = ____temp_0 -- 327
	if loaded ~= nil then -- 327
		local existing = loaded["watch.fe.dynamic_slots"] -- 329
		if existing ~= nil and type(existing) == "table" then -- 329
			return existing -- 331
		end -- 331
		local created = {} -- 333
		loaded["watch.fe.dynamic_slots"] = created -- 334
		return created -- 335
	end -- 335
	return FALLBACK_DYNAMIC_SLOTS -- 337
end -- 325
FALLBACK_DYNAMIC_SLOTS = {} -- 340
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 343
	sharedDynamicSlots()[key] = cfg -- 344
end -- 343
function ____exports.unregisterDynamicSlot(key) -- 347
	__TS__Delete( -- 348
		sharedDynamicSlots(), -- 348
		key -- 348
	) -- 348
end -- 347
____exports.AssetSlotHost = __TS__Class() -- 351
local AssetSlotHost = ____exports.AssetSlotHost -- 351
AssetSlotHost.name = "AssetSlotHost" -- 351
function AssetSlotHost.prototype.____constructor(self, parent, order, placeInScene) -- 360
	self.placeInScene = placeInScene -- 360
	self.sprites = {} -- 353
	self.unavailable = {} -- 354
	self.lastPlacement = {} -- 355
	self.visibleLastFrame = {} -- 356
	self.visibleThisFrame = {} -- 357
	self.localSlots = {} -- 358
	self.container = Node() -- 361
	self.container.order = order -- 362
	self.container:addTo(parent) -- 363
end -- 360
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 367
	self.localSlots[key] = cfg -- 368
end -- 367
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 372
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 373
end -- 372
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 377
	local sprite = self.lastPlacement[instanceKey] -- 378
	if sprite ~= nil then -- 378
		sprite.visible = false -- 380
	end -- 380
end -- 377
function AssetSlotHost.prototype.beginFrame(self) -- 384
	self.visibleThisFrame = {} -- 385
end -- 384
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 388
	if options == nil then -- 388
		options = {} -- 392
	end -- 392
	local staticSlots = ____exports.ASSET_SLOTS -- 394
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 395
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 395
		return false -- 397
	end -- 397
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 399
	local path = cfg.paths[frame + 1] -- 400
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 401
	return self:placeResolvedPath( -- 404
		path, -- 404
		anchorX, -- 404
		cfg.anchorY, -- 404
		cfg.preserveAspect, -- 404
		cfg.smooth == true, -- 404
		instanceKey, -- 404
		x, -- 404
		y, -- 404
		targetW, -- 404
		targetH, -- 404
		options -- 404
	) -- 404
end -- 388
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 409
	if options == nil then -- 409
		options = {} -- 414
	end -- 414
	if effort == nil then -- 414
		effort = 1 -- 415
	end -- 415
	if effort < 1 and self:tryPlaceRunTransition( -- 415
		actor, -- 417
		instanceKey, -- 417
		x, -- 417
		y, -- 417
		targetW, -- 417
		targetH, -- 417
		cycles, -- 417
		effort, -- 417
		options -- 417
	) then -- 417
		return true -- 418
	end -- 418
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 420
	return self:tryPlaceMotionFrame( -- 421
		RUN_ATLASES[actor], -- 421
		frame, -- 421
		instanceKey, -- 421
		x, -- 421
		y, -- 421
		targetW, -- 421
		targetH, -- 421
		options -- 421
	) -- 421
end -- 409
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 425
	if options == nil then -- 425
		options = {} -- 430
	end -- 430
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 432
	local level = math.max( -- 433
		0, -- 433
		math.min( -- 433
			____exports.RUN_TRANSITION_LEVELS - 1, -- 433
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 433
		) -- 433
	) -- 433
	return self:tryPlaceMotionFrame( -- 434
		RUN_TRANSITIONS[actor], -- 434
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 434
		instanceKey, -- 435
		x, -- 435
		y, -- 435
		targetW, -- 435
		targetH, -- 435
		options -- 435
	) -- 435
end -- 425
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 438
	if options == nil then -- 438
		options = {} -- 442
	end -- 442
	local frame = math.max( -- 444
		0, -- 444
		math.min( -- 444
			____exports.SLIDE_FRAME_COUNT - 1, -- 444
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 444
		) -- 444
	) -- 444
	return self:tryPlaceMotionFrame( -- 445
		SLIDE_ATLAS, -- 445
		frame, -- 445
		instanceKey, -- 445
		x, -- 445
		y, -- 445
		targetW, -- 445
		targetH, -- 445
		options -- 445
	) -- 445
end -- 438
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 448
	if targetW <= 0 or targetH <= 0 then -- 448
		return false -- 456
	end -- 456
	local ____atlas_1 = atlas -- 458
	local path = ____atlas_1.path -- 458
	local width = ____atlas_1.width -- 458
	local height = ____atlas_1.height -- 458
	local columns = ____atlas_1.columns -- 458
	local col = frame % columns -- 459
	local row = math.floor(frame / columns) -- 460
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 461
	return self:placeResolvedPath( -- 463
		path, -- 463
		0.5, -- 463
		0, -- 463
		true, -- 463
		false, -- 463
		instanceKey, -- 463
		x, -- 463
		y, -- 463
		targetW, -- 463
		targetH, -- 463
		options, -- 463
		rect -- 463
	) -- 463
end -- 448
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 467
	if options == nil then -- 467
		options = {} -- 471
	end -- 471
	if path == "" or targetW <= 0 or targetH <= 0 then -- 471
		return false -- 474
	end -- 474
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 476
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 476
	local ____options_preserveAspect_2 = options.preserveAspect -- 480
	if ____options_preserveAspect_2 == nil then -- 480
		____options_preserveAspect_2 = false -- 480
	end -- 480
	__TS__SparseArrayPush( -- 480
		____array_3, -- 480
		____options_preserveAspect_2, -- 480
		options.smooth == true, -- 481
		instanceKey, -- 482
		x, -- 483
		y, -- 484
		targetW, -- 485
		targetH, -- 486
		options -- 487
	) -- 487
	return ____self_placeResolvedPath_4( -- 476
		self, -- 476
		__TS__SparseArraySpread(____array_3) -- 476
	) -- 476
end -- 467
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 491
	local key = (instanceKey .. ":") .. path -- 502
	local sprite = self.sprites[key] -- 503
	if sprite == nil then -- 503
		if self.unavailable[path] then -- 503
			return false -- 506
		end -- 506
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 508
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 509
		local ____Content_exist_result_5 -- 510
		if Content:exist(file) then -- 510
			____Content_exist_result_5 = Sprite(path) -- 510
		else -- 510
			____Content_exist_result_5 = nil -- 510
		end -- 510
		local loaded = ____Content_exist_result_5 -- 510
		if loaded == nil then -- 510
			self.unavailable[path] = true -- 512
			return false -- 513
		end -- 513
		if textureRect ~= nil then -- 513
			loaded.size = Size(textureRect.width, textureRect.height) -- 517
		end -- 517
		loaded.filter = smooth and "Anisotropic" or "Point" -- 520
		loaded:addTo(self.container) -- 521
		self.sprites[key] = loaded -- 522
		sprite = loaded -- 523
	end -- 523
	if textureRect ~= nil then -- 523
		sprite.textureRect = textureRect -- 527
	end -- 527
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 529
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 530
	sprite.anchor = Vec2(anchorX, anchorY) -- 531
	sprite.position = textureRect == nil and Vec2( -- 532
		math.floor(x + 0.5), -- 532
		math.floor(y + 0.5) -- 532
	) or Vec2(x, y) -- 532
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 533
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 534
	sprite.angle = options.angle or 0 -- 535
	sprite.order = options.layer or 0 -- 536
	local col = options.color or WHITE -- 537
	sprite.color = col -- 538
	local baseA = col.a / 255 -- 539
	local op = options.opacity or 1 -- 540
	sprite.opacity = math.max( -- 541
		0, -- 541
		math.min(1, baseA * op) -- 541
	) -- 541
	sprite.visible = true -- 542
	self.visibleThisFrame[key] = sprite -- 543
	self.lastPlacement[instanceKey] = sprite -- 544
	if self.placeInScene ~= nil then -- 544
		self.placeInScene( -- 546
			sprite, -- 546
			key, -- 546
			instanceKey, -- 546
			x, -- 546
			y -- 546
		) -- 546
	end -- 546
	return true -- 548
end -- 491
function AssetSlotHost.prototype.endFrame(self) -- 551
	for key in pairs(self.visibleLastFrame) do -- 552
		if self.visibleThisFrame[key] == nil then -- 552
			self.visibleLastFrame[key].visible = false -- 554
		end -- 554
	end -- 554
	self.visibleLastFrame = self.visibleThisFrame -- 557
end -- 551
return ____exports -- 551