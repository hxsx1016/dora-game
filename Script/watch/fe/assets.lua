-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
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
____exports.ASSET_SLOTS = { -- 114
	bgFar_prologue = backdrop("prologue"), -- 115
	bgFar_street = backdrop("street"), -- 116
	bgFar_checkpoint = backdrop("checkpoint"), -- 117
	bgFar_gate = backdrop("gate"), -- 118
	bgFar_outside = backdrop("outside"), -- 119
	bgFar_village = backdrop("village"), -- 120
	bgFar_forest = backdrop("forest"), -- 121
	bgFar_tower = backdrop("tower"), -- 122
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods", true), -- 123
	bgFar_archway_yard = backdrop("bg_archway_yard", true), -- 124
	bgFar_granary = backdrop("bg_granary", true), -- 125
	bgFar_escort_ridge = backdrop("bg_escort_ridge", true), -- 126
	bgFar_museum = backdrop("bg_museum_hall", true), -- 127
	title_backdrop = backdrop("title"), -- 128
	soldier_idle = actor("soldier_idle"), -- 129
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 130
	soldier_roll = actor("soldier_roll", 0.47), -- 131
	soldier_cover = actor("soldier_cover", 0.47), -- 132
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 133
	soldier_hold = actor("soldier_hold"), -- 134
	soldier_offer = actor("soldier_offer", 0.48), -- 135
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 136
	soldier_hit = actor("soldier_hit", 0.5), -- 137
	soldier_fire = actor("soldier_fire", 0.51), -- 138
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 139
	child_idle = actor("child_idle", 0.48), -- 140
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 141
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 142
	child_fear = actor("child_fear", 0.48), -- 143
	child_peek = actor("child_peek", 0.5), -- 144
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 145
	child_aim = actor("child_aim", 0.47), -- 146
	child_throw = actor("child_throw", 0.49), -- 147
	child_knock = actor("child_knock", 0.5), -- 148
	child_offer = actor("child_offer", 0.49), -- 149
	enemy_idle = actor("enemy_idle", 0.5), -- 150
	enemy_aim = actor("enemy_aim", 0.51), -- 151
	enemy_down = actor("enemy_down"), -- 152
	enemy_hit = actor("enemy_hit", 0.48), -- 153
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 154
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 155
	prop_cart = clip("cart", 0, false, 0.44), -- 156
	prop_bottle = clip("bottle", 0.5, true), -- 157
	prop_tower_door = clip("door"), -- 158
	prop_lantern = clip("lantern", 0.5, true), -- 159
	prop_table = clip("table"), -- 160
	prop_compass = clip("compass", 0.5, true), -- 161
	prop_winch = clip("winch", 0.5, true), -- 162
	wall = clip("wall"), -- 163
	cover_wood = clip("cover_wood"), -- 164
	cover_stone = clip("cover_stone"), -- 165
	fence = clip("fence"), -- 166
	slab = clip("slab"), -- 167
	eaves = clip("eaves"), -- 168
	pine = clip("pine"), -- 169
	grass = clip("grass"), -- 170
	grass_low = clip("grass_low"), -- 171
	stone_chips = clip("stone_chips", 0.5, true), -- 172
	ui_corner = clip("ui_corner"), -- 173
	ui_corner_c = clip("ui_corner", 0.5, false), -- 174
	ui_paper = clip("paper", 0.5), -- 175
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 176
	ink_mist_curve = inkClip("ink_mist_curve"), -- 177
	ink_veil_strip = inkClip("ink_veil_strip"), -- 178
	ink_hairline = inkClip("ink_hairline"), -- 179
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 180
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 181
	ink_frame_mask = inkClip("ink_frame_mask"), -- 182
	ink_vstream = inkClip("ink_vstream"), -- 183
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 184
	ink_corner_fine = inkClip("ink_corner_fine"), -- 185
	ink_seal_slender = inkClip("ink_seal_slender"), -- 186
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 187
	ink_enso_fine = inkClip("ink_enso_fine"), -- 188
	ink_petal_mist = inkClip("ink_petal_mist"), -- 189
	ink_song_paper = inkClip("ink_song_paper"), -- 190
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 191
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 192
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 193
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 194
	slide_p01_01 = slide("p01_01_curtain"), -- 196
	slide_p01_02 = slide("p01_02_hand"), -- 197
	slide_p01_03 = slide("p01_03_door"), -- 198
	slide_p02_01 = slide("p02_01_shadows"), -- 199
	slide_p02_02 = slide("p02_02_cut"), -- 200
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 201
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 202
	slide_p02_05 = slide("p02_05_cabinet"), -- 203
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 204
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 205
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 206
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 207
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 208
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 209
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 210
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 211
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 212
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 213
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 214
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 215
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 216
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 217
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 218
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 219
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 220
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 221
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 222
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 223
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 224
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 225
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 226
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 227
	slide_e01_well = slide("e01_01_well"), -- 228
	slide_e01_compass = slide("e01_02_compass"), -- 229
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 230
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 231
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 232
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 233
	slide_f01_sewing = slide("f01_sewing_memory"), -- 234
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 235
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 236
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 238
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 239
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 240
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 241
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 242
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 243
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 244
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 245
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 246
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 247
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 248
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 249
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 250
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 251
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 252
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 253
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 254
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 255
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 256
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 257
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 258
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 259
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 260
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 261
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 262
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 263
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 264
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 265
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 266
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 267
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 268
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 269
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 270
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 271
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 272
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 273
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 274
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 275
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 276
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 277
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 278
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 279
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 280
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 281
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 282
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 283
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 284
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 285
} -- 285
local WHITE = Color(255, 255, 255, 255) -- 288
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 294
	local g = _G -- 295
	local ____temp_0 -- 296
	if g.package ~= nil then -- 296
		____temp_0 = g.package.loaded -- 296
	else -- 296
		____temp_0 = nil -- 296
	end -- 296
	local loaded = ____temp_0 -- 296
	if loaded ~= nil then -- 296
		local existing = loaded["watch.fe.dynamic_slots"] -- 298
		if existing ~= nil and type(existing) == "table" then -- 298
			return existing -- 300
		end -- 300
		local created = {} -- 302
		loaded["watch.fe.dynamic_slots"] = created -- 303
		return created -- 304
	end -- 304
	return FALLBACK_DYNAMIC_SLOTS -- 306
end -- 294
FALLBACK_DYNAMIC_SLOTS = {} -- 309
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 312
	sharedDynamicSlots()[key] = cfg -- 313
end -- 312
function ____exports.unregisterDynamicSlot(key) -- 316
	__TS__Delete( -- 317
		sharedDynamicSlots(), -- 317
		key -- 317
	) -- 317
end -- 316
____exports.AssetSlotHost = __TS__Class() -- 320
local AssetSlotHost = ____exports.AssetSlotHost -- 320
AssetSlotHost.name = "AssetSlotHost" -- 320
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 329
	self.sprites = {} -- 322
	self.unavailable = {} -- 323
	self.lastPlacement = {} -- 324
	self.visibleLastFrame = {} -- 325
	self.visibleThisFrame = {} -- 326
	self.localSlots = {} -- 327
	self.container = Node() -- 330
	self.container.order = order -- 331
	self.container:addTo(parent) -- 332
end -- 329
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 336
	self.localSlots[key] = cfg -- 337
end -- 336
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 341
	local sprite = self.lastPlacement[instanceKey] -- 342
	if sprite ~= nil then -- 342
		sprite.visible = false -- 344
	end -- 344
end -- 341
function AssetSlotHost.prototype.beginFrame(self) -- 348
	self.visibleThisFrame = {} -- 349
end -- 348
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 352
	if options == nil then -- 352
		options = {} -- 356
	end -- 356
	local staticSlots = ____exports.ASSET_SLOTS -- 358
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 359
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 359
		return false -- 361
	end -- 361
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 363
	local path = cfg.paths[frame + 1] -- 364
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 365
	return self:placeResolvedPath( -- 368
		path, -- 368
		anchorX, -- 368
		cfg.anchorY, -- 368
		cfg.preserveAspect, -- 368
		cfg.smooth == true, -- 368
		instanceKey, -- 368
		x, -- 368
		y, -- 368
		targetW, -- 368
		targetH, -- 368
		options -- 368
	) -- 368
end -- 352
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 372
	if options == nil then -- 372
		options = {} -- 376
	end -- 376
	if path == "" or targetW <= 0 or targetH <= 0 then -- 376
		return false -- 379
	end -- 379
	local ____self_placeResolvedPath_3 = self.placeResolvedPath -- 381
	local ____array_2 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 381
	local ____options_preserveAspect_1 = options.preserveAspect -- 385
	if ____options_preserveAspect_1 == nil then -- 385
		____options_preserveAspect_1 = false -- 385
	end -- 385
	__TS__SparseArrayPush( -- 385
		____array_2, -- 385
		____options_preserveAspect_1, -- 385
		options.smooth == true, -- 386
		instanceKey, -- 387
		x, -- 388
		y, -- 389
		targetW, -- 390
		targetH, -- 391
		options -- 392
	) -- 392
	return ____self_placeResolvedPath_3( -- 381
		self, -- 381
		__TS__SparseArraySpread(____array_2) -- 381
	) -- 381
end -- 372
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 396
	local key = (instanceKey .. ":") .. path -- 406
	local sprite = self.sprites[key] -- 407
	if sprite == nil then -- 407
		if self.unavailable[path] then -- 407
			return false -- 410
		end -- 410
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 412
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 413
		local ____Content_exist_result_4 -- 414
		if Content:exist(file) then -- 414
			____Content_exist_result_4 = Sprite(path) -- 414
		else -- 414
			____Content_exist_result_4 = nil -- 414
		end -- 414
		local loaded = ____Content_exist_result_4 -- 414
		if loaded == nil then -- 414
			self.unavailable[path] = true -- 416
			return false -- 417
		end -- 417
		loaded.anchor = Vec2(anchorX, anchorY) -- 419
		loaded.filter = smooth and "Anisotropic" or "Point" -- 420
		loaded:addTo(self.container) -- 421
		self.sprites[key] = loaded -- 422
		sprite = loaded -- 423
	end -- 423
	local scaleY = targetH / math.max(1, sprite.height) -- 426
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 427
	sprite.position = Vec2( -- 428
		math.floor(x + 0.5), -- 428
		math.floor(y + 0.5) -- 428
	) -- 428
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 429
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 430
	sprite.angle = options.angle or 0 -- 431
	sprite.order = options.layer or 0 -- 432
	local col = options.color or WHITE -- 433
	sprite.color = col -- 434
	local baseA = col.a / 255 -- 435
	local op = options.opacity or 1 -- 436
	sprite.opacity = math.max( -- 437
		0, -- 437
		math.min(1, baseA * op) -- 437
	) -- 437
	sprite.visible = true -- 438
	self.visibleThisFrame[key] = sprite -- 439
	self.lastPlacement[instanceKey] = sprite -- 440
	return true -- 441
end -- 396
function AssetSlotHost.prototype.endFrame(self) -- 444
	for key in pairs(self.visibleLastFrame) do -- 445
		if self.visibleThisFrame[key] == nil then -- 445
			self.visibleLastFrame[key].visible = false -- 447
		end -- 447
	end -- 447
	self.visibleLastFrame = self.visibleThisFrame -- 450
end -- 444
return ____exports -- 444