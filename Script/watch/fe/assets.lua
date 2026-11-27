-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
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
local RUN_COLUMNS = 10 -- 66
local RUN_GUTTER = 2 -- 67
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164}} -- 68
____exports.ASSET_SLOTS = { -- 73
	bgFar_prologue = backdrop("prologue"), -- 74
	bgFar_street = backdrop("street"), -- 75
	bgFar_checkpoint = backdrop("checkpoint"), -- 76
	bgFar_gate = backdrop("gate"), -- 77
	bgFar_outside = backdrop("outside"), -- 78
	bgFar_village = backdrop("village"), -- 79
	bgFar_forest = backdrop("forest"), -- 80
	bgFar_tower = backdrop("tower"), -- 81
	title_backdrop = backdrop("title"), -- 82
	soldier_idle = character("soldier_idle"), -- 83
	soldier_run = character({"soldier_run", "soldier_step"}), -- 84
	soldier_roll = character("soldier_roll"), -- 85
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 86
	soldier_cover = character("soldier_cover"), -- 87
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 88
	soldier_hold = character("soldier_hold"), -- 89
	soldier_offer = character("soldier_offer"), -- 90
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 91
	soldier_hit = character("soldier_hit"), -- 92
	soldier_fire = character("soldier_fire"), -- 93
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 94
	child_idle = character("child_idle"), -- 95
	child_run = character({"child_run", "child_step"}), -- 96
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 97
	child_fear = character("child_fear"), -- 98
	child_peek = character("child_peek"), -- 99
	child_pull = character({"child_pull", "child_pull_step"}), -- 100
	child_aim = character("child_aim"), -- 101
	child_throw = character("child_throw"), -- 102
	child_knock = character("child_knock"), -- 103
	child_offer = character("child_offer"), -- 104
	enemy_idle = actor("enemy_idle"), -- 105
	enemy_aim = actor("enemy_aim"), -- 106
	enemy_down = actor("enemy_down"), -- 107
	enemy_hit = actor("enemy_hit"), -- 108
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 109
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 110
	prop_cart = clip("cart"), -- 111
	prop_bottle = clip("bottle", 0.5, true), -- 112
	prop_tower_door = clip("door"), -- 113
	prop_lantern = clip("lantern", 0.5, true), -- 114
	prop_table = clip("table"), -- 115
	prop_compass = clip("compass", 0.5, true), -- 116
	prop_winch = clip("winch", 0.5, true), -- 117
	wall = clip("wall"), -- 118
	cover_wood = clip("cover_wood"), -- 119
	cover_stone = clip("cover_stone"), -- 120
	fence = clip("fence"), -- 121
	slab = clip("slab"), -- 122
	eaves = clip("eaves"), -- 123
	pine = clip("pine"), -- 124
	grass = clip("grass"), -- 125
	grass_low = clip("grass_low"), -- 126
	stone_chips = clip("stone_chips", 0.5, true), -- 127
	ui_corner = clip("ui_corner"), -- 128
	ui_corner_c = clip("ui_corner", 0.5, false), -- 129
	ui_paper = clip("paper", 0.5), -- 130
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 131
	ink_mist_curve = inkClip("ink_mist_curve"), -- 132
	ink_veil_strip = inkClip("ink_veil_strip"), -- 133
	ink_hairline = inkClip("ink_hairline"), -- 134
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 135
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 136
	ink_frame_mask = inkClip("ink_frame_mask"), -- 137
	ink_vstream = inkClip("ink_vstream"), -- 138
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 139
	ink_corner_fine = inkClip("ink_corner_fine"), -- 140
	ink_seal_slender = inkClip("ink_seal_slender"), -- 141
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 142
	ink_enso_fine = inkClip("ink_enso_fine"), -- 143
	ink_petal_mist = inkClip("ink_petal_mist"), -- 144
	ink_song_paper = inkClip("ink_song_paper") -- 145
} -- 145
local WHITE = Color(255, 255, 255, 255) -- 148
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 154
	local g = _G -- 155
	local ____temp_0 -- 156
	if g.package ~= nil then -- 156
		____temp_0 = g.package.loaded -- 156
	else -- 156
		____temp_0 = nil -- 156
	end -- 156
	local loaded = ____temp_0 -- 156
	if loaded ~= nil then -- 156
		local existing = loaded["watch.fe.dynamic_slots"] -- 158
		if existing ~= nil and type(existing) == "table" then -- 158
			return existing -- 160
		end -- 160
		local created = {} -- 162
		loaded["watch.fe.dynamic_slots"] = created -- 163
		return created -- 164
	end -- 164
	return FALLBACK_DYNAMIC_SLOTS -- 166
end -- 154
FALLBACK_DYNAMIC_SLOTS = {} -- 169
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 172
	sharedDynamicSlots()[key] = cfg -- 173
end -- 172
function ____exports.unregisterDynamicSlot(key) -- 176
	__TS__Delete( -- 177
		sharedDynamicSlots(), -- 177
		key -- 177
	) -- 177
end -- 176
____exports.AssetSlotHost = __TS__Class() -- 180
local AssetSlotHost = ____exports.AssetSlotHost -- 180
AssetSlotHost.name = "AssetSlotHost" -- 180
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 188
	self.sprites = {} -- 182
	self.unavailable = {} -- 183
	self.visibleLastFrame = {} -- 184
	self.visibleThisFrame = {} -- 185
	self.localSlots = {} -- 186
	self.container = Node() -- 189
	self.container.order = order -- 190
	self.container:addTo(parent) -- 191
end -- 188
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 195
	self.localSlots[key] = cfg -- 196
end -- 195
function AssetSlotHost.prototype.beginFrame(self) -- 199
	self.visibleThisFrame = {} -- 200
end -- 199
function AssetSlotHost.prototype.hideInstance(self, instanceKey) -- 203
	local prefix = instanceKey .. ":" -- 204
	for key in pairs(self.visibleThisFrame) do -- 205
		if __TS__StringStartsWith(key, prefix) then -- 205
			self.visibleThisFrame[key].visible = false -- 207
			__TS__Delete(self.visibleThisFrame, key) -- 208
		end -- 208
	end -- 208
end -- 203
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 213
	if options == nil then -- 213
		options = {} -- 217
	end -- 217
	local staticSlots = ____exports.ASSET_SLOTS -- 219
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 220
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 220
		return false -- 222
	end -- 222
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 224
	local path = cfg.paths[frame + 1] -- 225
	return self:placeResolvedPath( -- 226
		path, -- 226
		cfg.anchorY, -- 226
		cfg.preserveAspect, -- 226
		cfg.smooth == true, -- 226
		instanceKey, -- 226
		x, -- 226
		y, -- 226
		targetW, -- 226
		targetH, -- 226
		options -- 226
	) -- 226
end -- 213
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options) -- 230
	if options == nil then -- 230
		options = {} -- 235
	end -- 235
	if targetW <= 0 or targetH <= 0 then -- 235
		return false -- 238
	end -- 238
	local ____RUN_ATLASES_actor_1 = RUN_ATLASES[actor] -- 240
	local path = ____RUN_ATLASES_actor_1.path -- 240
	local width = ____RUN_ATLASES_actor_1.width -- 240
	local height = ____RUN_ATLASES_actor_1.height -- 240
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 241
	local col = frame % RUN_COLUMNS -- 242
	local row = math.floor(frame / RUN_COLUMNS) -- 243
	local rect = Rect(col * (width + 2 * RUN_GUTTER) + RUN_GUTTER, row * (height + 2 * RUN_GUTTER) + RUN_GUTTER, width, height) -- 244
	return self:placeResolvedPath( -- 246
		path, -- 246
		0, -- 246
		true, -- 246
		false, -- 246
		instanceKey, -- 246
		x, -- 246
		y, -- 246
		targetW, -- 246
		targetH, -- 246
		options, -- 246
		rect -- 246
	) -- 246
end -- 230
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 250
	if options == nil then -- 250
		options = {} -- 254
	end -- 254
	if path == "" or targetW <= 0 or targetH <= 0 then -- 254
		return false -- 257
	end -- 257
	local ____self_placeResolvedPath_5 = self.placeResolvedPath -- 259
	local ____path_3 = path -- 260
	local ____temp_4 = options.anchorY or 0.5 -- 261
	local ____options_preserveAspect_2 = options.preserveAspect -- 262
	if ____options_preserveAspect_2 == nil then -- 262
		____options_preserveAspect_2 = false -- 262
	end -- 262
	return ____self_placeResolvedPath_5( -- 259
		self, -- 259
		____path_3, -- 260
		____temp_4, -- 261
		____options_preserveAspect_2, -- 262
		options.smooth == true, -- 263
		instanceKey, -- 264
		x, -- 265
		y, -- 266
		targetW, -- 267
		targetH, -- 268
		options -- 269
	) -- 269
end -- 250
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 273
	local key = (instanceKey .. ":") .. path -- 283
	local sprite = self.sprites[key] -- 284
	if sprite == nil then -- 284
		if self.unavailable[path] then -- 284
			return false -- 287
		end -- 287
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 289
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 290
		local ____Content_exist_result_6 -- 291
		if Content:exist(file) then -- 291
			____Content_exist_result_6 = Sprite(path) -- 291
		else -- 291
			____Content_exist_result_6 = nil -- 291
		end -- 291
		local loaded = ____Content_exist_result_6 -- 291
		if loaded == nil then -- 291
			self.unavailable[path] = true -- 293
			return false -- 294
		end -- 294
		if textureRect ~= nil then -- 294
			loaded.size = Size(textureRect.width, textureRect.height) -- 298
		end -- 298
		loaded.anchor = Vec2(0.5, anchorY) -- 300
		loaded.filter = smooth and "Anisotropic" or "Point" -- 301
		loaded:addTo(self.container) -- 302
		self.sprites[key] = loaded -- 303
		sprite = loaded -- 304
	end -- 304
	if textureRect ~= nil then -- 304
		sprite.textureRect = textureRect -- 308
	end -- 308
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 310
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 311
	sprite.position = textureRect == nil and Vec2( -- 312
		math.floor(x + 0.5), -- 312
		math.floor(y + 0.5) -- 312
	) or Vec2(x, y) -- 312
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 313
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 314
	sprite.angle = options.angle or 0 -- 315
	sprite.order = options.layer or 0 -- 316
	local col = options.color or WHITE -- 317
	sprite.color = col -- 318
	local baseA = col.a / 255 -- 319
	local op = options.opacity or 1 -- 320
	sprite.opacity = math.max( -- 321
		0, -- 321
		math.min(1, baseA * op) -- 321
	) -- 321
	sprite.visible = true -- 322
	self.visibleThisFrame[key] = sprite -- 323
	return true -- 324
end -- 273
function AssetSlotHost.prototype.endFrame(self) -- 327
	for key in pairs(self.visibleLastFrame) do -- 328
		if self.visibleThisFrame[key] == nil then -- 328
			self.visibleLastFrame[key].visible = false -- 330
		end -- 330
	end -- 330
	self.visibleLastFrame = self.visibleThisFrame -- 333
end -- 327
return ____exports -- 327