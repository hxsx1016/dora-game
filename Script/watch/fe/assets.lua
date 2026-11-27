-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
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
local function backdrop(name) -- 46
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 47
end -- 46
local function clip(names, anchorY, preserveAspect, anchorX) -- 50
	if anchorY == nil then -- 50
		anchorY = 0 -- 52
	end -- 52
	if preserveAspect == nil then -- 52
		preserveAspect = false -- 53
	end -- 53
	local frames = type(names) == "string" and ({names}) or names -- 56
	return { -- 57
		paths = __TS__ArrayMap( -- 57
			frames, -- 57
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 57
		), -- 57
		anchorX = anchorX, -- 57
		anchorY = anchorY, -- 57
		preserveAspect = preserveAspect -- 57
	} -- 57
end -- 50
local function inkClip(name, preserveAspect) -- 60
	if preserveAspect == nil then -- 60
		preserveAspect = false -- 60
	end -- 60
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 61
end -- 60
local function actor(names, anchorX) -- 64
	return clip(names, 0, true, anchorX) -- 65
end -- 64
____exports.RUN_FRAME_COUNT = 160 -- 68
____exports.RUN_TRANSITION_PHASES = 8 -- 69
____exports.RUN_TRANSITION_LEVELS = 12 -- 70
local ATLAS_GUTTER = 2 -- 71
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 80
local RUN_TRANSITIONS = { -- 84
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 85
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 86
} -- 86
local HD_ACTOR_CLIP = "assets/art/actors-hd.clip|" -- 89
local BASE_ACTOR_CLIP = "assets/art/sprites.clip|" -- 90
____exports.ASSET_SLOTS = { -- 92
	bgFar_prologue = backdrop("prologue"), -- 93
	bgFar_street = backdrop("street"), -- 94
	bgFar_checkpoint = backdrop("checkpoint"), -- 95
	bgFar_gate = backdrop("gate"), -- 96
	bgFar_outside = backdrop("outside"), -- 97
	bgFar_village = backdrop("village"), -- 98
	bgFar_forest = backdrop("forest"), -- 99
	bgFar_tower = backdrop("tower"), -- 100
	title_backdrop = backdrop("title"), -- 101
	soldier_idle = actor("soldier_idle"), -- 102
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 103
	soldier_roll = actor("soldier_roll", 0.47), -- 104
	soldier_cover = actor("soldier_cover", 0.47), -- 105
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 106
	soldier_hold = actor("soldier_hold"), -- 107
	soldier_offer = actor("soldier_offer", 0.48), -- 108
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 109
	soldier_hit = actor("soldier_hit", 0.5), -- 110
	soldier_fire = actor("soldier_fire", 0.51), -- 111
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 112
	child_idle = actor("child_idle", 0.48), -- 113
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 114
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 115
	child_fear = actor("child_fear", 0.48), -- 116
	child_peek = actor("child_peek", 0.5), -- 117
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 118
	child_aim = actor("child_aim", 0.47), -- 119
	child_throw = actor("child_throw", 0.49), -- 120
	child_knock = actor("child_knock", 0.5), -- 121
	child_offer = actor("child_offer", 0.49), -- 122
	enemy_idle = actor("enemy_idle", 0.5), -- 123
	enemy_aim = actor("enemy_aim", 0.51), -- 124
	enemy_down = actor("enemy_down"), -- 125
	enemy_hit = actor("enemy_hit", 0.48), -- 126
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 127
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 128
	prop_cart = clip("cart", 0, false, 0.44), -- 129
	prop_bottle = clip("bottle", 0.5, true), -- 130
	prop_tower_door = clip("door"), -- 131
	prop_lantern = clip("lantern", 0.5, true), -- 132
	prop_table = clip("table"), -- 133
	prop_compass = clip("compass", 0.5, true), -- 134
	prop_winch = clip("winch", 0.5, true), -- 135
	wall = clip("wall"), -- 136
	cover_wood = clip("cover_wood"), -- 137
	cover_stone = clip("cover_stone"), -- 138
	fence = clip("fence"), -- 139
	slab = clip("slab"), -- 140
	eaves = clip("eaves"), -- 141
	pine = clip("pine"), -- 142
	grass = clip("grass"), -- 143
	grass_low = clip("grass_low"), -- 144
	stone_chips = clip("stone_chips", 0.5, true), -- 145
	ui_corner = clip("ui_corner"), -- 146
	ui_corner_c = clip("ui_corner", 0.5, false), -- 147
	ui_paper = clip("paper", 0.5), -- 148
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 149
	ink_mist_curve = inkClip("ink_mist_curve"), -- 150
	ink_veil_strip = inkClip("ink_veil_strip"), -- 151
	ink_hairline = inkClip("ink_hairline"), -- 152
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 153
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 154
	ink_frame_mask = inkClip("ink_frame_mask"), -- 155
	ink_vstream = inkClip("ink_vstream"), -- 156
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 157
	ink_corner_fine = inkClip("ink_corner_fine"), -- 158
	ink_seal_slender = inkClip("ink_seal_slender"), -- 159
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 160
	ink_enso_fine = inkClip("ink_enso_fine"), -- 161
	ink_petal_mist = inkClip("ink_petal_mist"), -- 162
	ink_song_paper = inkClip("ink_song_paper"), -- 163
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 164
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 165
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 166
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true} -- 167
} -- 167
local WHITE = Color(255, 255, 255, 255) -- 170
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 176
	local g = _G -- 177
	local ____temp_0 -- 178
	if g.package ~= nil then -- 178
		____temp_0 = g.package.loaded -- 178
	else -- 178
		____temp_0 = nil -- 178
	end -- 178
	local loaded = ____temp_0 -- 178
	if loaded ~= nil then -- 178
		local existing = loaded["watch.fe.dynamic_slots"] -- 180
		if existing ~= nil and type(existing) == "table" then -- 180
			return existing -- 182
		end -- 182
		local created = {} -- 184
		loaded["watch.fe.dynamic_slots"] = created -- 185
		return created -- 186
	end -- 186
	return FALLBACK_DYNAMIC_SLOTS -- 188
end -- 176
FALLBACK_DYNAMIC_SLOTS = {} -- 191
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 194
	sharedDynamicSlots()[key] = cfg -- 195
end -- 194
function ____exports.unregisterDynamicSlot(key) -- 198
	__TS__Delete( -- 199
		sharedDynamicSlots(), -- 199
		key -- 199
	) -- 199
end -- 198
____exports.AssetSlotHost = __TS__Class() -- 202
local AssetSlotHost = ____exports.AssetSlotHost -- 202
AssetSlotHost.name = "AssetSlotHost" -- 202
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 211
	self.hdCast = false -- 203
	self.sprites = {} -- 205
	self.unavailable = {} -- 206
	self.visibleLastFrame = {} -- 207
	self.visibleThisFrame = {} -- 208
	self.localSlots = {} -- 209
	self.container = Node() -- 212
	self.container.order = order -- 213
	self.container:addTo(parent) -- 214
end -- 211
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 218
	self.localSlots[key] = cfg -- 219
end -- 218
function AssetSlotHost.prototype.setHdCast(self, enabled) -- 222
	self.hdCast = enabled -- 223
end -- 222
function AssetSlotHost.prototype.beginFrame(self) -- 226
	self.visibleThisFrame = {} -- 227
end -- 226
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 230
	if options == nil then -- 230
		options = {} -- 234
	end -- 234
	local staticSlots = ____exports.ASSET_SLOTS -- 236
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 237
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 237
		return false -- 239
	end -- 239
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 241
	local path = cfg.paths[frame + 1] -- 242
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 243
	if self.hdCast and __TS__StringStartsWith(path, BASE_ACTOR_CLIP) and (__TS__StringStartsWith(slotKey, "child_") or __TS__StringStartsWith(slotKey, "soldier_")) then -- 243
		local hdPath = HD_ACTOR_CLIP .. __TS__StringSlice(path, #BASE_ACTOR_CLIP) -- 248
		if self:placeResolvedPath( -- 248
			hdPath, -- 249
			0.5, -- 249
			cfg.anchorY, -- 249
			true, -- 249
			false, -- 249
			instanceKey, -- 249
			x, -- 249
			y, -- 249
			targetW, -- 249
			targetH, -- 249
			options -- 249
		) then -- 249
			return true -- 250
		end -- 250
	end -- 250
	return self:placeResolvedPath( -- 253
		path, -- 253
		anchorX, -- 253
		cfg.anchorY, -- 253
		cfg.preserveAspect, -- 253
		cfg.smooth == true, -- 253
		instanceKey, -- 253
		x, -- 253
		y, -- 253
		targetW, -- 253
		targetH, -- 253
		options -- 253
	) -- 253
end -- 230
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 257
	if options == nil then -- 257
		options = {} -- 262
	end -- 262
	if effort == nil then -- 262
		effort = 1 -- 263
	end -- 263
	if not self.hdCast then -- 263
		return false -- 266
	end -- 266
	if effort < 1 and self:tryPlaceRunTransition( -- 266
		actor, -- 268
		instanceKey, -- 268
		x, -- 268
		y, -- 268
		targetW, -- 268
		targetH, -- 268
		cycles, -- 268
		effort, -- 268
		options -- 268
	) then -- 268
		return true -- 269
	end -- 269
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 271
	return self:tryPlaceMotionFrame( -- 272
		RUN_ATLASES[actor], -- 272
		frame, -- 272
		instanceKey, -- 272
		x, -- 272
		y, -- 272
		targetW, -- 272
		targetH, -- 272
		options -- 272
	) -- 272
end -- 257
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 276
	if options == nil then -- 276
		options = {} -- 281
	end -- 281
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 283
	local level = math.max( -- 284
		0, -- 284
		math.min( -- 284
			____exports.RUN_TRANSITION_LEVELS - 1, -- 284
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 284
		) -- 284
	) -- 284
	return self:tryPlaceMotionFrame( -- 285
		RUN_TRANSITIONS[actor], -- 285
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 285
		instanceKey, -- 286
		x, -- 286
		y, -- 286
		targetW, -- 286
		targetH, -- 286
		options -- 286
	) -- 286
end -- 276
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 289
	if targetW <= 0 or targetH <= 0 then -- 289
		return false -- 297
	end -- 297
	local ____atlas_1 = atlas -- 299
	local path = ____atlas_1.path -- 299
	local width = ____atlas_1.width -- 299
	local height = ____atlas_1.height -- 299
	local columns = ____atlas_1.columns -- 299
	local col = frame % columns -- 300
	local row = math.floor(frame / columns) -- 301
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 302
	return self:placeResolvedPath( -- 304
		path, -- 304
		0.5, -- 304
		0, -- 304
		true, -- 304
		false, -- 304
		instanceKey, -- 304
		x, -- 304
		y, -- 304
		targetW, -- 304
		targetH, -- 304
		options, -- 304
		rect -- 304
	) -- 304
end -- 289
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 308
	if options == nil then -- 308
		options = {} -- 312
	end -- 312
	if path == "" or targetW <= 0 or targetH <= 0 then -- 312
		return false -- 315
	end -- 315
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 317
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 317
	local ____options_preserveAspect_2 = options.preserveAspect -- 321
	if ____options_preserveAspect_2 == nil then -- 321
		____options_preserveAspect_2 = false -- 321
	end -- 321
	__TS__SparseArrayPush( -- 321
		____array_3, -- 321
		____options_preserveAspect_2, -- 321
		options.smooth == true, -- 322
		instanceKey, -- 323
		x, -- 324
		y, -- 325
		targetW, -- 326
		targetH, -- 327
		options -- 328
	) -- 328
	return ____self_placeResolvedPath_4( -- 317
		self, -- 317
		__TS__SparseArraySpread(____array_3) -- 317
	) -- 317
end -- 308
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 332
	local key = (instanceKey .. ":") .. path -- 343
	local sprite = self.sprites[key] -- 344
	if sprite == nil then -- 344
		if self.unavailable[path] then -- 344
			return false -- 347
		end -- 347
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 349
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 350
		local ____Content_exist_result_5 -- 351
		if Content:exist(file) then -- 351
			____Content_exist_result_5 = Sprite(path) -- 351
		else -- 351
			____Content_exist_result_5 = nil -- 351
		end -- 351
		local loaded = ____Content_exist_result_5 -- 351
		if loaded == nil then -- 351
			self.unavailable[path] = true -- 353
			return false -- 354
		end -- 354
		if textureRect ~= nil then -- 354
			loaded.size = Size(textureRect.width, textureRect.height) -- 357
		end -- 357
		loaded.anchor = Vec2(anchorX, anchorY) -- 359
		loaded.filter = smooth and "Anisotropic" or "Point" -- 360
		loaded:addTo(self.container) -- 361
		self.sprites[key] = loaded -- 362
		sprite = loaded -- 363
	end -- 363
	if textureRect ~= nil then -- 363
		sprite.textureRect = textureRect -- 367
	end -- 367
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 369
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 370
	sprite.position = textureRect == nil and Vec2( -- 371
		math.floor(x + 0.5), -- 371
		math.floor(y + 0.5) -- 371
	) or Vec2(x, y) -- 371
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 372
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 373
	sprite.angle = options.angle or 0 -- 374
	sprite.order = options.layer or 0 -- 375
	local col = options.color or WHITE -- 376
	sprite.color = col -- 377
	local baseA = col.a / 255 -- 378
	local op = options.opacity or 1 -- 379
	sprite.opacity = math.max( -- 380
		0, -- 380
		math.min(1, baseA * op) -- 380
	) -- 380
	sprite.visible = true -- 381
	self.visibleThisFrame[key] = sprite -- 382
	return true -- 383
end -- 332
function AssetSlotHost.prototype.endFrame(self) -- 386
	for key in pairs(self.visibleLastFrame) do -- 387
		if self.visibleThisFrame[key] == nil then -- 387
			self.visibleLastFrame[key].visible = false -- 389
		end -- 389
	end -- 389
	self.visibleLastFrame = self.visibleThisFrame -- 392
end -- 386
return ____exports -- 386