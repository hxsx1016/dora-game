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
local function backdrop(name) -- 43
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 44
end -- 43
local function clip(names, anchorY, preserveAspect) -- 47
	if anchorY == nil then -- 47
		anchorY = 0 -- 47
	end -- 47
	if preserveAspect == nil then -- 47
		preserveAspect = false -- 47
	end -- 47
	local frames = type(names) == "string" and ({names}) or names -- 48
	return { -- 49
		paths = __TS__ArrayMap( -- 49
			frames, -- 49
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 49
		), -- 49
		anchorY = anchorY, -- 49
		preserveAspect = preserveAspect -- 49
	} -- 49
end -- 47
local function inkClip(name, preserveAspect) -- 52
	if preserveAspect == nil then -- 52
		preserveAspect = false -- 52
	end -- 52
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 53
end -- 52
local function actor(names) -- 56
	return clip(names, 0, true) -- 57
end -- 56
local function character(names) -- 60
	local frames = type(names) == "string" and ({names}) or names -- 61
	return { -- 62
		paths = __TS__ArrayMap( -- 62
			frames, -- 62
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 62
		), -- 62
		anchorY = 0, -- 62
		preserveAspect = true -- 62
	} -- 62
end -- 60
____exports.RUN_FRAME_COUNT = 160 -- 65
____exports.RUN_TRANSITION_PHASES = 8 -- 66
____exports.RUN_TRANSITION_LEVELS = 12 -- 67
____exports.SLIDE_FRAME_COUNT = 64 -- 68
local ATLAS_GUTTER = 2 -- 69
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 78
local RUN_TRANSITIONS = { -- 82
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 83
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 84
} -- 84
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 86
____exports.ASSET_SLOTS = { -- 90
	bgFar_prologue = backdrop("prologue"), -- 91
	bgFar_street = backdrop("street"), -- 92
	bgFar_checkpoint = backdrop("checkpoint"), -- 93
	bgFar_gate = backdrop("gate"), -- 94
	bgFar_outside = backdrop("outside"), -- 95
	bgFar_village = backdrop("village"), -- 96
	bgFar_forest = backdrop("forest"), -- 97
	bgFar_tower = backdrop("tower"), -- 98
	title_backdrop = backdrop("title"), -- 99
	soldier_idle = character("soldier_idle"), -- 100
	soldier_run = character({"soldier_run", "soldier_step"}), -- 101
	soldier_roll = character("soldier_roll"), -- 102
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 103
	soldier_cover = character("soldier_cover"), -- 104
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 105
	soldier_hold = character("soldier_hold"), -- 106
	soldier_offer = character("soldier_offer"), -- 107
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 108
	soldier_hit = character("soldier_hit"), -- 109
	soldier_fire = character("soldier_fire"), -- 110
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 111
	child_idle = character("child_idle"), -- 112
	child_run = character({"child_run", "child_step"}), -- 113
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 114
	child_fear = character("child_fear"), -- 115
	child_peek = character("child_peek"), -- 116
	child_pull = character({"child_pull", "child_pull_step"}), -- 117
	child_aim = character("child_aim"), -- 118
	child_throw = character("child_throw"), -- 119
	child_knock = character("child_knock"), -- 120
	child_offer = character("child_offer"), -- 121
	enemy_idle = actor("enemy_idle"), -- 122
	enemy_aim = actor("enemy_aim"), -- 123
	enemy_down = actor("enemy_down"), -- 124
	enemy_hit = actor("enemy_hit"), -- 125
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 126
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 127
	prop_cart = clip("cart"), -- 128
	prop_bottle = clip("bottle", 0.5, true), -- 129
	prop_tower_door = clip("door"), -- 130
	prop_lantern = clip("lantern", 0.5, true), -- 131
	prop_table = clip("table"), -- 132
	prop_compass = clip("compass", 0.5, true), -- 133
	prop_winch = clip("winch", 0.5, true), -- 134
	wall = clip("wall"), -- 135
	cover_wood = clip("cover_wood"), -- 136
	cover_stone = clip("cover_stone"), -- 137
	fence = clip("fence"), -- 138
	slab = clip("slab"), -- 139
	eaves = clip("eaves"), -- 140
	pine = clip("pine"), -- 141
	grass = clip("grass"), -- 142
	grass_low = clip("grass_low"), -- 143
	stone_chips = clip("stone_chips", 0.5, true), -- 144
	ui_corner = clip("ui_corner"), -- 145
	ui_corner_c = clip("ui_corner", 0.5, false), -- 146
	ui_paper = clip("paper", 0.5), -- 147
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 148
	ink_mist_curve = inkClip("ink_mist_curve"), -- 149
	ink_veil_strip = inkClip("ink_veil_strip"), -- 150
	ink_hairline = inkClip("ink_hairline"), -- 151
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 152
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 153
	ink_frame_mask = inkClip("ink_frame_mask"), -- 154
	ink_vstream = inkClip("ink_vstream"), -- 155
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 156
	ink_corner_fine = inkClip("ink_corner_fine"), -- 157
	ink_seal_slender = inkClip("ink_seal_slender"), -- 158
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 159
	ink_enso_fine = inkClip("ink_enso_fine"), -- 160
	ink_petal_mist = inkClip("ink_petal_mist"), -- 161
	ink_song_paper = inkClip("ink_song_paper") -- 162
} -- 162
local WHITE = Color(255, 255, 255, 255) -- 165
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 171
	local g = _G -- 172
	local ____temp_0 -- 173
	if g.package ~= nil then -- 173
		____temp_0 = g.package.loaded -- 173
	else -- 173
		____temp_0 = nil -- 173
	end -- 173
	local loaded = ____temp_0 -- 173
	if loaded ~= nil then -- 173
		local existing = loaded["watch.fe.dynamic_slots"] -- 175
		if existing ~= nil and type(existing) == "table" then -- 175
			return existing -- 177
		end -- 177
		local created = {} -- 179
		loaded["watch.fe.dynamic_slots"] = created -- 180
		return created -- 181
	end -- 181
	return FALLBACK_DYNAMIC_SLOTS -- 183
end -- 171
FALLBACK_DYNAMIC_SLOTS = {} -- 186
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 189
	sharedDynamicSlots()[key] = cfg -- 190
end -- 189
function ____exports.unregisterDynamicSlot(key) -- 193
	__TS__Delete( -- 194
		sharedDynamicSlots(), -- 194
		key -- 194
	) -- 194
end -- 193
____exports.AssetSlotHost = __TS__Class() -- 197
local AssetSlotHost = ____exports.AssetSlotHost -- 197
AssetSlotHost.name = "AssetSlotHost" -- 197
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 205
	self.sprites = {} -- 199
	self.unavailable = {} -- 200
	self.visibleLastFrame = {} -- 201
	self.visibleThisFrame = {} -- 202
	self.localSlots = {} -- 203
	self.container = Node() -- 206
	self.container.order = order -- 207
	self.container:addTo(parent) -- 208
end -- 205
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 212
	self.localSlots[key] = cfg -- 213
end -- 212
function AssetSlotHost.prototype.beginFrame(self) -- 216
	self.visibleThisFrame = {} -- 217
end -- 216
function AssetSlotHost.prototype.hideInstance(self, instanceKey) -- 220
	local prefix = instanceKey .. ":" -- 221
	for key in pairs(self.visibleThisFrame) do -- 222
		if __TS__StringStartsWith(key, prefix) then -- 222
			self.visibleThisFrame[key].visible = false -- 224
			__TS__Delete(self.visibleThisFrame, key) -- 225
		end -- 225
	end -- 225
end -- 220
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
	return self:placeResolvedPath( -- 243
		path, -- 243
		cfg.anchorY, -- 243
		cfg.preserveAspect, -- 243
		cfg.smooth == true, -- 243
		instanceKey, -- 243
		x, -- 243
		y, -- 243
		targetW, -- 243
		targetH, -- 243
		options -- 243
	) -- 243
end -- 230
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 247
	if options == nil then -- 247
		options = {} -- 252
	end -- 252
	if effort == nil then -- 252
		effort = 1 -- 253
	end -- 253
	if effort < 1 and self:tryPlaceRunTransition( -- 253
		actor, -- 255
		instanceKey, -- 255
		x, -- 255
		y, -- 255
		targetW, -- 255
		targetH, -- 255
		cycles, -- 255
		effort, -- 255
		options -- 255
	) then -- 255
		return true -- 256
	end -- 256
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 258
	return self:tryPlaceMotionFrame( -- 259
		RUN_ATLASES[actor], -- 259
		frame, -- 259
		instanceKey, -- 259
		x, -- 259
		y, -- 259
		targetW, -- 259
		targetH, -- 259
		options -- 259
	) -- 259
end -- 247
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 263
	if options == nil then -- 263
		options = {} -- 268
	end -- 268
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 270
	local level = math.max( -- 271
		0, -- 271
		math.min( -- 271
			____exports.RUN_TRANSITION_LEVELS - 1, -- 271
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 271
		) -- 271
	) -- 271
	return self:tryPlaceMotionFrame( -- 272
		RUN_TRANSITIONS[actor], -- 272
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 272
		instanceKey, -- 273
		x, -- 273
		y, -- 273
		targetW, -- 273
		targetH, -- 273
		options -- 273
	) -- 273
end -- 263
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 276
	if options == nil then -- 276
		options = {} -- 280
	end -- 280
	local frame = math.max( -- 282
		0, -- 282
		math.min( -- 282
			____exports.SLIDE_FRAME_COUNT - 1, -- 282
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 282
		) -- 282
	) -- 282
	return self:tryPlaceMotionFrame( -- 283
		SLIDE_ATLAS, -- 283
		frame, -- 283
		instanceKey, -- 283
		x, -- 283
		y, -- 283
		targetW, -- 283
		targetH, -- 283
		options -- 283
	) -- 283
end -- 276
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 286
	if targetW <= 0 or targetH <= 0 then -- 286
		return false -- 294
	end -- 294
	local ____atlas_1 = atlas -- 296
	local path = ____atlas_1.path -- 296
	local width = ____atlas_1.width -- 296
	local height = ____atlas_1.height -- 296
	local columns = ____atlas_1.columns -- 296
	local col = frame % columns -- 297
	local row = math.floor(frame / columns) -- 298
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 299
	return self:placeResolvedPath( -- 301
		path, -- 301
		0, -- 301
		true, -- 301
		false, -- 301
		instanceKey, -- 301
		x, -- 301
		y, -- 301
		targetW, -- 301
		targetH, -- 301
		options, -- 301
		rect -- 301
	) -- 301
end -- 286
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 305
	if options == nil then -- 305
		options = {} -- 309
	end -- 309
	if path == "" or targetW <= 0 or targetH <= 0 then -- 309
		return false -- 312
	end -- 312
	local ____self_placeResolvedPath_5 = self.placeResolvedPath -- 314
	local ____path_3 = path -- 315
	local ____temp_4 = options.anchorY or 0.5 -- 316
	local ____options_preserveAspect_2 = options.preserveAspect -- 317
	if ____options_preserveAspect_2 == nil then -- 317
		____options_preserveAspect_2 = false -- 317
	end -- 317
	return ____self_placeResolvedPath_5( -- 314
		self, -- 314
		____path_3, -- 315
		____temp_4, -- 316
		____options_preserveAspect_2, -- 317
		options.smooth == true, -- 318
		instanceKey, -- 319
		x, -- 320
		y, -- 321
		targetW, -- 322
		targetH, -- 323
		options -- 324
	) -- 324
end -- 305
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 328
	local key = (instanceKey .. ":") .. path -- 338
	local sprite = self.sprites[key] -- 339
	if sprite == nil then -- 339
		if self.unavailable[path] then -- 339
			return false -- 342
		end -- 342
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 344
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 345
		local ____Content_exist_result_6 -- 346
		if Content:exist(file) then -- 346
			____Content_exist_result_6 = Sprite(path) -- 346
		else -- 346
			____Content_exist_result_6 = nil -- 346
		end -- 346
		local loaded = ____Content_exist_result_6 -- 346
		if loaded == nil then -- 346
			self.unavailable[path] = true -- 348
			return false -- 349
		end -- 349
		if textureRect ~= nil then -- 349
			loaded.size = Size(textureRect.width, textureRect.height) -- 353
		end -- 353
		loaded.anchor = Vec2(0.5, anchorY) -- 355
		loaded.filter = smooth and "Anisotropic" or "Point" -- 356
		loaded:addTo(self.container) -- 357
		self.sprites[key] = loaded -- 358
		sprite = loaded -- 359
	end -- 359
	if textureRect ~= nil then -- 359
		sprite.textureRect = textureRect -- 363
	end -- 363
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 365
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 366
	sprite.position = textureRect == nil and Vec2( -- 367
		math.floor(x + 0.5), -- 367
		math.floor(y + 0.5) -- 367
	) or Vec2(x, y) -- 367
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 368
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 369
	sprite.angle = options.angle or 0 -- 370
	sprite.order = options.layer or 0 -- 371
	local col = options.color or WHITE -- 372
	sprite.color = col -- 373
	local baseA = col.a / 255 -- 374
	local op = options.opacity or 1 -- 375
	sprite.opacity = math.max( -- 376
		0, -- 376
		math.min(1, baseA * op) -- 376
	) -- 376
	sprite.visible = true -- 377
	self.visibleThisFrame[key] = sprite -- 378
	return true -- 379
end -- 328
function AssetSlotHost.prototype.endFrame(self) -- 382
	for key in pairs(self.visibleLastFrame) do -- 383
		if self.visibleThisFrame[key] == nil then -- 383
			self.visibleLastFrame[key].visible = false -- 385
		end -- 385
	end -- 385
	self.visibleLastFrame = self.visibleThisFrame -- 388
end -- 382
return ____exports -- 382