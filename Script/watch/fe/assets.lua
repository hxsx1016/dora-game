-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
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
local function backdrop(name) -- 44
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 45
end -- 44
local function clip(names, anchorY, preserveAspect) -- 48
	if anchorY == nil then -- 48
		anchorY = 0 -- 48
	end -- 48
	if preserveAspect == nil then -- 48
		preserveAspect = false -- 48
	end -- 48
	local frames = type(names) == "string" and ({names}) or names -- 49
	return { -- 50
		paths = __TS__ArrayMap( -- 50
			frames, -- 50
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 50
		), -- 50
		anchorY = anchorY, -- 50
		preserveAspect = preserveAspect -- 50
	} -- 50
end -- 48
local function inkClip(name, preserveAspect) -- 53
	if preserveAspect == nil then -- 53
		preserveAspect = false -- 53
	end -- 53
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 54
end -- 53
local function actor(names) -- 57
	return clip(names, 0, true) -- 58
end -- 57
local function character(names) -- 61
	local frames = type(names) == "string" and ({names}) or names -- 62
	return { -- 63
		paths = __TS__ArrayMap( -- 63
			frames, -- 63
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 63
		), -- 63
		anchorY = 0, -- 63
		preserveAspect = true -- 63
	} -- 63
end -- 61
____exports.RUN_FRAME_COUNT = 160 -- 66
____exports.RUN_TRANSITION_PHASES = 8 -- 67
____exports.RUN_TRANSITION_LEVELS = 12 -- 68
____exports.SLIDE_FRAME_COUNT = 64 -- 69
local ATLAS_GUTTER = 2 -- 70
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 79
local RUN_TRANSITIONS = { -- 83
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 84
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 85
} -- 85
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 87
____exports.ASSET_SLOTS = { -- 91
	bgFar_prologue = backdrop("prologue"), -- 92
	bgFar_street = backdrop("street"), -- 93
	bgFar_checkpoint = backdrop("checkpoint"), -- 94
	bgFar_gate = backdrop("gate"), -- 95
	bgFar_outside = backdrop("outside"), -- 96
	bgFar_village = backdrop("village"), -- 97
	bgFar_forest = backdrop("forest"), -- 98
	bgFar_tower = backdrop("tower"), -- 99
	title_backdrop = backdrop("title"), -- 100
	soldier_idle = character("soldier_idle"), -- 101
	soldier_run = character({"soldier_run", "soldier_step"}), -- 102
	soldier_roll = character("soldier_roll"), -- 103
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 104
	soldier_cover = character("soldier_cover"), -- 105
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 106
	soldier_hold = character("soldier_hold"), -- 107
	soldier_offer = character("soldier_offer"), -- 108
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 109
	soldier_hit = character("soldier_hit"), -- 110
	soldier_fire = character("soldier_fire"), -- 111
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 112
	child_idle = character("child_idle"), -- 113
	child_run = character({"child_run", "child_step"}), -- 114
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 115
	child_fear = character("child_fear"), -- 116
	child_peek = character("child_peek"), -- 117
	child_pull = character({"child_pull", "child_pull_step"}), -- 118
	child_aim = character("child_aim"), -- 119
	child_throw = character("child_throw"), -- 120
	child_knock = character("child_knock"), -- 121
	child_offer = character("child_offer"), -- 122
	enemy_idle = actor("enemy_idle"), -- 123
	enemy_aim = actor("enemy_aim"), -- 124
	enemy_down = actor("enemy_down"), -- 125
	enemy_hit = actor("enemy_hit"), -- 126
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 127
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 128
	prop_cart = clip("cart"), -- 129
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
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 210
	self.sprites = {} -- 204
	self.unavailable = {} -- 205
	self.visibleLastFrame = {} -- 206
	self.visibleThisFrame = {} -- 207
	self.localSlots = {} -- 208
	self.container = Node() -- 211
	self.container.order = order -- 212
	self.container:addTo(parent) -- 213
end -- 210
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 217
	self.localSlots[key] = cfg -- 218
end -- 217
function AssetSlotHost.prototype.beginFrame(self) -- 221
	self.visibleThisFrame = {} -- 222
end -- 221
function AssetSlotHost.prototype.hideInstance(self, instanceKey) -- 225
	local prefix = instanceKey .. ":" -- 226
	for key in pairs(self.visibleThisFrame) do -- 227
		if __TS__StringStartsWith(key, prefix) then -- 227
			self.visibleThisFrame[key].visible = false -- 229
			__TS__Delete(self.visibleThisFrame, key) -- 230
		end -- 230
	end -- 230
end -- 225
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 235
	if options == nil then -- 235
		options = {} -- 239
	end -- 239
	local staticSlots = ____exports.ASSET_SLOTS -- 241
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 242
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 242
		return false -- 244
	end -- 244
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 246
	local path = cfg.paths[frame + 1] -- 247
	return self:placeResolvedPath( -- 248
		path, -- 248
		cfg.anchorY, -- 248
		cfg.preserveAspect, -- 248
		cfg.smooth == true, -- 248
		instanceKey, -- 248
		x, -- 248
		y, -- 248
		targetW, -- 248
		targetH, -- 248
		options -- 248
	) -- 248
end -- 235
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 252
	if options == nil then -- 252
		options = {} -- 257
	end -- 257
	if effort == nil then -- 257
		effort = 1 -- 258
	end -- 258
	if effort < 1 and self:tryPlaceRunTransition( -- 258
		actor, -- 260
		instanceKey, -- 260
		x, -- 260
		y, -- 260
		targetW, -- 260
		targetH, -- 260
		cycles, -- 260
		effort, -- 260
		options -- 260
	) then -- 260
		return true -- 261
	end -- 261
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 263
	return self:tryPlaceMotionFrame( -- 264
		RUN_ATLASES[actor], -- 264
		frame, -- 264
		instanceKey, -- 264
		x, -- 264
		y, -- 264
		targetW, -- 264
		targetH, -- 264
		options -- 264
	) -- 264
end -- 252
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 268
	if options == nil then -- 268
		options = {} -- 273
	end -- 273
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 275
	local level = math.max( -- 276
		0, -- 276
		math.min( -- 276
			____exports.RUN_TRANSITION_LEVELS - 1, -- 276
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 276
		) -- 276
	) -- 276
	return self:tryPlaceMotionFrame( -- 277
		RUN_TRANSITIONS[actor], -- 277
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 277
		instanceKey, -- 278
		x, -- 278
		y, -- 278
		targetW, -- 278
		targetH, -- 278
		options -- 278
	) -- 278
end -- 268
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 281
	if options == nil then -- 281
		options = {} -- 285
	end -- 285
	local frame = math.max( -- 287
		0, -- 287
		math.min( -- 287
			____exports.SLIDE_FRAME_COUNT - 1, -- 287
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 287
		) -- 287
	) -- 287
	return self:tryPlaceMotionFrame( -- 288
		SLIDE_ATLAS, -- 288
		frame, -- 288
		instanceKey, -- 288
		x, -- 288
		y, -- 288
		targetW, -- 288
		targetH, -- 288
		options -- 288
	) -- 288
end -- 281
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 291
	if targetW <= 0 or targetH <= 0 then -- 291
		return false -- 299
	end -- 299
	local ____atlas_1 = atlas -- 301
	local path = ____atlas_1.path -- 301
	local width = ____atlas_1.width -- 301
	local height = ____atlas_1.height -- 301
	local columns = ____atlas_1.columns -- 301
	local col = frame % columns -- 302
	local row = math.floor(frame / columns) -- 303
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 304
	return self:placeResolvedPath( -- 306
		path, -- 306
		0, -- 306
		true, -- 306
		false, -- 306
		instanceKey, -- 306
		x, -- 306
		y, -- 306
		targetW, -- 306
		targetH, -- 306
		options, -- 306
		rect -- 306
	) -- 306
end -- 291
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 310
	if options == nil then -- 310
		options = {} -- 314
	end -- 314
	if path == "" or targetW <= 0 or targetH <= 0 then -- 314
		return false -- 317
	end -- 317
	local ____self_placeResolvedPath_5 = self.placeResolvedPath -- 319
	local ____path_3 = path -- 320
	local ____temp_4 = options.anchorY or 0.5 -- 321
	local ____options_preserveAspect_2 = options.preserveAspect -- 322
	if ____options_preserveAspect_2 == nil then -- 322
		____options_preserveAspect_2 = false -- 322
	end -- 322
	return ____self_placeResolvedPath_5( -- 319
		self, -- 319
		____path_3, -- 320
		____temp_4, -- 321
		____options_preserveAspect_2, -- 322
		options.smooth == true, -- 323
		instanceKey, -- 324
		x, -- 325
		y, -- 326
		targetW, -- 327
		targetH, -- 328
		options -- 329
	) -- 329
end -- 310
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 333
	local key = (instanceKey .. ":") .. path -- 343
	local sprite = self.sprites[key] -- 344
	if sprite == nil then -- 344
		if self.unavailable[path] then -- 344
			return false -- 347
		end -- 347
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 349
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 350
		local ____Content_exist_result_6 -- 351
		if Content:exist(file) then -- 351
			____Content_exist_result_6 = Sprite(path) -- 351
		else -- 351
			____Content_exist_result_6 = nil -- 351
		end -- 351
		local loaded = ____Content_exist_result_6 -- 351
		if loaded == nil then -- 351
			self.unavailable[path] = true -- 353
			return false -- 354
		end -- 354
		if textureRect ~= nil then -- 354
			loaded.size = Size(textureRect.width, textureRect.height) -- 358
		end -- 358
		loaded.anchor = Vec2(0.5, anchorY) -- 360
		loaded.filter = smooth and "Anisotropic" or "Point" -- 361
		loaded:addTo(self.container) -- 362
		self.sprites[key] = loaded -- 363
		sprite = loaded -- 364
	end -- 364
	if textureRect ~= nil then -- 364
		sprite.textureRect = textureRect -- 368
	end -- 368
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 370
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 371
	sprite.position = textureRect == nil and Vec2( -- 372
		math.floor(x + 0.5), -- 372
		math.floor(y + 0.5) -- 372
	) or Vec2(x, y) -- 372
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 373
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 374
	sprite.angle = options.angle or 0 -- 375
	sprite.order = options.layer or 0 -- 376
	local col = options.color or WHITE -- 377
	sprite.color = col -- 378
	local baseA = col.a / 255 -- 379
	local op = options.opacity or 1 -- 380
	sprite.opacity = math.max( -- 381
		0, -- 381
		math.min(1, baseA * op) -- 381
	) -- 381
	sprite.visible = true -- 382
	self.visibleThisFrame[key] = sprite -- 383
	return true -- 384
end -- 333
function AssetSlotHost.prototype.endFrame(self) -- 387
	for key in pairs(self.visibleLastFrame) do -- 388
		if self.visibleThisFrame[key] == nil then -- 388
			self.visibleLastFrame[key].visible = false -- 390
		end -- 390
	end -- 390
	self.visibleLastFrame = self.visibleThisFrame -- 393
end -- 387
return ____exports -- 387