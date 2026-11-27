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
local function backdrop(name) -- 75
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 76
end -- 75
local function clip(names, anchorY, preserveAspect, anchorX) -- 79
	if anchorY == nil then -- 79
		anchorY = 0 -- 81
	end -- 81
	if preserveAspect == nil then -- 81
		preserveAspect = false -- 82
	end -- 82
	local frames = type(names) == "string" and ({names}) or names -- 85
	return { -- 86
		paths = __TS__ArrayMap( -- 86
			frames, -- 86
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 86
		), -- 86
		anchorX = anchorX, -- 86
		anchorY = anchorY, -- 86
		preserveAspect = preserveAspect -- 86
	} -- 86
end -- 79
local function inkClip(name, preserveAspect) -- 89
	if preserveAspect == nil then -- 89
		preserveAspect = false -- 89
	end -- 89
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 90
end -- 89
local function actor(names, anchorX) -- 93
	return clip(names, 0, true, anchorX) -- 94
end -- 93
local function slide(name) -- 97
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 98
end -- 97
local function feClip(names, anchorY, preserveAspect, anchorX) -- 101
	if anchorY == nil then -- 101
		anchorY = 0.5 -- 103
	end -- 103
	if preserveAspect == nil then -- 103
		preserveAspect = true -- 104
	end -- 104
	local frames = type(names) == "string" and ({names}) or names -- 107
	return { -- 108
		paths = __TS__ArrayMap( -- 108
			frames, -- 108
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 108
		), -- 108
		anchorX = anchorX, -- 108
		anchorY = anchorY, -- 108
		preserveAspect = preserveAspect -- 108
	} -- 108
end -- 101
____exports.ASSET_SLOTS = { -- 111
	bgFar_prologue = backdrop("prologue"), -- 112
	bgFar_street = backdrop("street"), -- 113
	bgFar_checkpoint = backdrop("checkpoint"), -- 114
	bgFar_gate = backdrop("gate"), -- 115
	bgFar_outside = backdrop("outside"), -- 116
	bgFar_village = backdrop("village"), -- 117
	bgFar_forest = backdrop("forest"), -- 118
	bgFar_tower = backdrop("tower"), -- 119
	title_backdrop = backdrop("title"), -- 120
	soldier_idle = actor("soldier_idle"), -- 121
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 122
	soldier_roll = actor("soldier_roll", 0.47), -- 123
	soldier_cover = actor("soldier_cover", 0.47), -- 124
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 125
	soldier_hold = actor("soldier_hold"), -- 126
	soldier_offer = actor("soldier_offer", 0.48), -- 127
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 128
	soldier_hit = actor("soldier_hit", 0.5), -- 129
	soldier_fire = actor("soldier_fire", 0.51), -- 130
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 131
	child_idle = actor("child_idle", 0.48), -- 132
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 133
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 134
	child_fear = actor("child_fear", 0.48), -- 135
	child_peek = actor("child_peek", 0.5), -- 136
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 137
	child_aim = actor("child_aim", 0.47), -- 138
	child_throw = actor("child_throw", 0.49), -- 139
	child_knock = actor("child_knock", 0.5), -- 140
	child_offer = actor("child_offer", 0.49), -- 141
	enemy_idle = actor("enemy_idle", 0.5), -- 142
	enemy_aim = actor("enemy_aim", 0.51), -- 143
	enemy_down = actor("enemy_down"), -- 144
	enemy_hit = actor("enemy_hit", 0.48), -- 145
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 146
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 147
	prop_cart = clip("cart", 0, false, 0.44), -- 148
	prop_bottle = clip("bottle", 0.5, true), -- 149
	prop_tower_door = clip("door"), -- 150
	prop_lantern = clip("lantern", 0.5, true), -- 151
	prop_table = clip("table"), -- 152
	prop_compass = clip("compass", 0.5, true), -- 153
	prop_winch = clip("winch", 0.5, true), -- 154
	wall = clip("wall"), -- 155
	cover_wood = clip("cover_wood"), -- 156
	cover_stone = clip("cover_stone"), -- 157
	fence = clip("fence"), -- 158
	slab = clip("slab"), -- 159
	eaves = clip("eaves"), -- 160
	pine = clip("pine"), -- 161
	grass = clip("grass"), -- 162
	grass_low = clip("grass_low"), -- 163
	stone_chips = clip("stone_chips", 0.5, true), -- 164
	ui_corner = clip("ui_corner"), -- 165
	ui_corner_c = clip("ui_corner", 0.5, false), -- 166
	ui_paper = clip("paper", 0.5), -- 167
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 168
	ink_mist_curve = inkClip("ink_mist_curve"), -- 169
	ink_veil_strip = inkClip("ink_veil_strip"), -- 170
	ink_hairline = inkClip("ink_hairline"), -- 171
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 172
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 173
	ink_frame_mask = inkClip("ink_frame_mask"), -- 174
	ink_vstream = inkClip("ink_vstream"), -- 175
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 176
	ink_corner_fine = inkClip("ink_corner_fine"), -- 177
	ink_seal_slender = inkClip("ink_seal_slender"), -- 178
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 179
	ink_enso_fine = inkClip("ink_enso_fine"), -- 180
	ink_petal_mist = inkClip("ink_petal_mist"), -- 181
	ink_song_paper = inkClip("ink_song_paper"), -- 182
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 183
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 184
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 185
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 186
	slide_p01_01 = slide("p01_01_curtain"), -- 188
	slide_p01_02 = slide("p01_02_hand"), -- 189
	slide_p01_03 = slide("p01_03_door"), -- 190
	slide_p02_01 = slide("p02_01_shadows"), -- 191
	slide_p02_02 = slide("p02_02_cut"), -- 192
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 193
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 194
	slide_p02_05 = slide("p02_05_cabinet"), -- 195
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 196
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 197
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 198
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 199
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 200
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 201
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 202
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 203
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 204
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 205
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 206
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 207
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 208
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 209
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 210
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 211
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 212
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 213
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 214
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 215
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 216
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 217
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 218
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 219
	slide_e01_well = slide("e01_01_well"), -- 220
	slide_e01_compass = slide("e01_02_compass"), -- 221
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 222
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 223
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 224
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 225
	slide_f01_sewing = slide("f01_sewing_memory"), -- 226
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 227
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 228
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 230
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 231
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 232
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 233
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 234
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 235
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 236
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 237
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 238
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 239
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 240
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 241
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 242
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 243
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 244
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 245
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 246
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 247
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 248
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 249
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 250
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 251
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 252
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 253
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 254
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 255
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 256
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 257
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 258
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 259
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 260
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 261
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 262
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 263
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 264
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 265
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 266
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 267
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 268
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 269
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 270
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 271
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 272
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 273
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 274
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 275
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 276
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 277
} -- 277
local WHITE = Color(255, 255, 255, 255) -- 280
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 286
	local g = _G -- 287
	local ____temp_0 -- 288
	if g.package ~= nil then -- 288
		____temp_0 = g.package.loaded -- 288
	else -- 288
		____temp_0 = nil -- 288
	end -- 288
	local loaded = ____temp_0 -- 288
	if loaded ~= nil then -- 288
		local existing = loaded["watch.fe.dynamic_slots"] -- 290
		if existing ~= nil and type(existing) == "table" then -- 290
			return existing -- 292
		end -- 292
		local created = {} -- 294
		loaded["watch.fe.dynamic_slots"] = created -- 295
		return created -- 296
	end -- 296
	return FALLBACK_DYNAMIC_SLOTS -- 298
end -- 286
FALLBACK_DYNAMIC_SLOTS = {} -- 301
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 304
	sharedDynamicSlots()[key] = cfg -- 305
end -- 304
function ____exports.unregisterDynamicSlot(key) -- 308
	__TS__Delete( -- 309
		sharedDynamicSlots(), -- 309
		key -- 309
	) -- 309
end -- 308
____exports.AssetSlotHost = __TS__Class() -- 312
local AssetSlotHost = ____exports.AssetSlotHost -- 312
AssetSlotHost.name = "AssetSlotHost" -- 312
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 320
	self.sprites = {} -- 314
	self.unavailable = {} -- 315
	self.visibleLastFrame = {} -- 316
	self.visibleThisFrame = {} -- 317
	self.localSlots = {} -- 318
	self.container = Node() -- 321
	self.container.order = order -- 322
	self.container:addTo(parent) -- 323
end -- 320
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 327
	self.localSlots[key] = cfg -- 328
end -- 327
function AssetSlotHost.prototype.beginFrame(self) -- 331
	self.visibleThisFrame = {} -- 332
end -- 331
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 335
	if options == nil then -- 335
		options = {} -- 339
	end -- 339
	local staticSlots = ____exports.ASSET_SLOTS -- 341
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 342
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 342
		return false -- 344
	end -- 344
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 346
	local path = cfg.paths[frame + 1] -- 347
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 348
	return self:placeResolvedPath( -- 351
		path, -- 351
		anchorX, -- 351
		cfg.anchorY, -- 351
		cfg.preserveAspect, -- 351
		cfg.smooth == true, -- 351
		instanceKey, -- 351
		x, -- 351
		y, -- 351
		targetW, -- 351
		targetH, -- 351
		options -- 351
	) -- 351
end -- 335
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 355
	if options == nil then -- 355
		options = {} -- 359
	end -- 359
	if path == "" or targetW <= 0 or targetH <= 0 then -- 359
		return false -- 362
	end -- 362
	local ____self_placeResolvedPath_3 = self.placeResolvedPath -- 364
	local ____array_2 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 364
	local ____options_preserveAspect_1 = options.preserveAspect -- 368
	if ____options_preserveAspect_1 == nil then -- 368
		____options_preserveAspect_1 = false -- 368
	end -- 368
	__TS__SparseArrayPush( -- 368
		____array_2, -- 368
		____options_preserveAspect_1, -- 368
		options.smooth == true, -- 369
		instanceKey, -- 370
		x, -- 371
		y, -- 372
		targetW, -- 373
		targetH, -- 374
		options -- 375
	) -- 375
	return ____self_placeResolvedPath_3( -- 364
		self, -- 364
		__TS__SparseArraySpread(____array_2) -- 364
	) -- 364
end -- 355
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 379
	local key = (instanceKey .. ":") .. path -- 389
	local sprite = self.sprites[key] -- 390
	if sprite == nil then -- 390
		if self.unavailable[path] then -- 390
			return false -- 393
		end -- 393
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 395
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 396
		local ____Content_exist_result_4 -- 397
		if Content:exist(file) then -- 397
			____Content_exist_result_4 = Sprite(path) -- 397
		else -- 397
			____Content_exist_result_4 = nil -- 397
		end -- 397
		local loaded = ____Content_exist_result_4 -- 397
		if loaded == nil then -- 397
			self.unavailable[path] = true -- 399
			return false -- 400
		end -- 400
		loaded.anchor = Vec2(anchorX, anchorY) -- 402
		loaded.filter = smooth and "Anisotropic" or "Point" -- 403
		loaded:addTo(self.container) -- 404
		self.sprites[key] = loaded -- 405
		sprite = loaded -- 406
	end -- 406
	local scaleY = targetH / math.max(1, sprite.height) -- 409
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 410
	sprite.position = Vec2( -- 411
		math.floor(x + 0.5), -- 411
		math.floor(y + 0.5) -- 411
	) -- 411
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 412
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 413
	sprite.angle = options.angle or 0 -- 414
	sprite.order = options.layer or 0 -- 415
	local col = options.color or WHITE -- 416
	sprite.color = col -- 417
	local baseA = col.a / 255 -- 418
	local op = options.opacity or 1 -- 419
	sprite.opacity = math.max( -- 420
		0, -- 420
		math.min(1, baseA * op) -- 420
	) -- 420
	sprite.visible = true -- 421
	self.visibleThisFrame[key] = sprite -- 422
	return true -- 423
end -- 379
function AssetSlotHost.prototype.endFrame(self) -- 426
	for key in pairs(self.visibleLastFrame) do -- 427
		if self.visibleThisFrame[key] == nil then -- 427
			self.visibleLastFrame[key].visible = false -- 429
		end -- 429
	end -- 429
	self.visibleLastFrame = self.visibleThisFrame -- 432
end -- 426
return ____exports -- 426