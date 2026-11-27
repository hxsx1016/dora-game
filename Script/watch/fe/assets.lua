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
local function backdrop(name) -- 45
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 46
end -- 45
local function clip(names, anchorY, preserveAspect, anchorX) -- 49
	if anchorY == nil then -- 49
		anchorY = 0 -- 51
	end -- 51
	if preserveAspect == nil then -- 51
		preserveAspect = false -- 52
	end -- 52
	local frames = type(names) == "string" and ({names}) or names -- 55
	return { -- 56
		paths = __TS__ArrayMap( -- 56
			frames, -- 56
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 56
		), -- 56
		anchorX = anchorX, -- 56
		anchorY = anchorY, -- 56
		preserveAspect = preserveAspect -- 56
	} -- 56
end -- 49
local function inkClip(name, preserveAspect) -- 59
	if preserveAspect == nil then -- 59
		preserveAspect = false -- 59
	end -- 59
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 60
end -- 59
local function actor(names, anchorX) -- 63
	return clip(names, 0, true, anchorX) -- 64
end -- 63
____exports.ASSET_SLOTS = { -- 67
	bgFar_prologue = backdrop("prologue"), -- 68
	bgFar_street = backdrop("street"), -- 69
	bgFar_checkpoint = backdrop("checkpoint"), -- 70
	bgFar_gate = backdrop("gate"), -- 71
	bgFar_outside = backdrop("outside"), -- 72
	bgFar_village = backdrop("village"), -- 73
	bgFar_forest = backdrop("forest"), -- 74
	bgFar_tower = backdrop("tower"), -- 75
	title_backdrop = backdrop("title"), -- 76
	soldier_idle = actor("soldier_idle"), -- 77
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 78
	soldier_roll = actor("soldier_roll", 0.47), -- 79
	soldier_cover = actor("soldier_cover", 0.47), -- 80
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 81
	soldier_hold = actor("soldier_hold"), -- 82
	soldier_offer = actor("soldier_offer", 0.48), -- 83
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 84
	soldier_hit = actor("soldier_hit", 0.5), -- 85
	soldier_fire = actor("soldier_fire", 0.51), -- 86
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 87
	child_idle = actor("child_idle", 0.48), -- 88
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 89
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 90
	child_fear = actor("child_fear", 0.48), -- 91
	child_peek = actor("child_peek", 0.5), -- 92
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 93
	child_aim = actor("child_aim", 0.47), -- 94
	child_throw = actor("child_throw", 0.49), -- 95
	child_knock = actor("child_knock", 0.5), -- 96
	child_offer = actor("child_offer", 0.49), -- 97
	enemy_idle = actor("enemy_idle", 0.5), -- 98
	enemy_aim = actor("enemy_aim", 0.51), -- 99
	enemy_down = actor("enemy_down"), -- 100
	enemy_hit = actor("enemy_hit", 0.48), -- 101
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 102
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 103
	prop_cart = clip("cart", 0, false, 0.44), -- 104
	prop_bottle = clip("bottle", 0.5, true), -- 105
	prop_tower_door = clip("door"), -- 106
	prop_lantern = clip("lantern", 0.5, true), -- 107
	prop_table = clip("table"), -- 108
	prop_compass = clip("compass", 0.5, true), -- 109
	prop_winch = clip("winch", 0.5, true), -- 110
	wall = clip("wall"), -- 111
	cover_wood = clip("cover_wood"), -- 112
	cover_stone = clip("cover_stone"), -- 113
	fence = clip("fence"), -- 114
	slab = clip("slab"), -- 115
	eaves = clip("eaves"), -- 116
	pine = clip("pine"), -- 117
	grass = clip("grass"), -- 118
	grass_low = clip("grass_low"), -- 119
	stone_chips = clip("stone_chips", 0.5, true), -- 120
	ui_corner = clip("ui_corner"), -- 121
	ui_corner_c = clip("ui_corner", 0.5, false), -- 122
	ui_paper = clip("paper", 0.5), -- 123
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 124
	ink_mist_curve = inkClip("ink_mist_curve"), -- 125
	ink_veil_strip = inkClip("ink_veil_strip"), -- 126
	ink_hairline = inkClip("ink_hairline"), -- 127
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 128
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 129
	ink_frame_mask = inkClip("ink_frame_mask"), -- 130
	ink_vstream = inkClip("ink_vstream"), -- 131
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 132
	ink_corner_fine = inkClip("ink_corner_fine"), -- 133
	ink_seal_slender = inkClip("ink_seal_slender"), -- 134
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 135
	ink_enso_fine = inkClip("ink_enso_fine"), -- 136
	ink_petal_mist = inkClip("ink_petal_mist"), -- 137
	ink_song_paper = inkClip("ink_song_paper") -- 138
} -- 138
local WHITE = Color(255, 255, 255, 255) -- 141
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 147
	local g = _G -- 148
	local ____temp_0 -- 149
	if g.package ~= nil then -- 149
		____temp_0 = g.package.loaded -- 149
	else -- 149
		____temp_0 = nil -- 149
	end -- 149
	local loaded = ____temp_0 -- 149
	if loaded ~= nil then -- 149
		local existing = loaded["watch.fe.dynamic_slots"] -- 151
		if existing ~= nil and type(existing) == "table" then -- 151
			return existing -- 153
		end -- 153
		local created = {} -- 155
		loaded["watch.fe.dynamic_slots"] = created -- 156
		return created -- 157
	end -- 157
	return FALLBACK_DYNAMIC_SLOTS -- 159
end -- 147
FALLBACK_DYNAMIC_SLOTS = {} -- 162
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 165
	sharedDynamicSlots()[key] = cfg -- 166
end -- 165
function ____exports.unregisterDynamicSlot(key) -- 169
	__TS__Delete( -- 170
		sharedDynamicSlots(), -- 170
		key -- 170
	) -- 170
end -- 169
____exports.AssetSlotHost = __TS__Class() -- 173
local AssetSlotHost = ____exports.AssetSlotHost -- 173
AssetSlotHost.name = "AssetSlotHost" -- 173
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 181
	self.sprites = {} -- 175
	self.unavailable = {} -- 176
	self.visibleLastFrame = {} -- 177
	self.visibleThisFrame = {} -- 178
	self.localSlots = {} -- 179
	self.container = Node() -- 182
	self.container.order = order -- 183
	self.container:addTo(parent) -- 184
end -- 181
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 188
	self.localSlots[key] = cfg -- 189
end -- 188
function AssetSlotHost.prototype.beginFrame(self) -- 192
	self.visibleThisFrame = {} -- 193
end -- 192
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 196
	if options == nil then -- 196
		options = {} -- 200
	end -- 200
	local staticSlots = ____exports.ASSET_SLOTS -- 202
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 203
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 203
		return false -- 205
	end -- 205
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 207
	local path = cfg.paths[frame + 1] -- 208
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 209
	return self:placeResolvedPath( -- 212
		path, -- 212
		anchorX, -- 212
		cfg.anchorY, -- 212
		cfg.preserveAspect, -- 212
		cfg.smooth == true, -- 212
		instanceKey, -- 212
		x, -- 212
		y, -- 212
		targetW, -- 212
		targetH, -- 212
		options -- 212
	) -- 212
end -- 196
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 216
	if options == nil then -- 216
		options = {} -- 220
	end -- 220
	if path == "" or targetW <= 0 or targetH <= 0 then -- 220
		return false -- 223
	end -- 223
	local ____self_placeResolvedPath_3 = self.placeResolvedPath -- 225
	local ____array_2 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 225
	local ____options_preserveAspect_1 = options.preserveAspect -- 229
	if ____options_preserveAspect_1 == nil then -- 229
		____options_preserveAspect_1 = false -- 229
	end -- 229
	__TS__SparseArrayPush( -- 229
		____array_2, -- 229
		____options_preserveAspect_1, -- 229
		options.smooth == true, -- 230
		instanceKey, -- 231
		x, -- 232
		y, -- 233
		targetW, -- 234
		targetH, -- 235
		options -- 236
	) -- 236
	return ____self_placeResolvedPath_3( -- 225
		self, -- 225
		__TS__SparseArraySpread(____array_2) -- 225
	) -- 225
end -- 216
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 240
	local key = (instanceKey .. ":") .. path -- 250
	local sprite = self.sprites[key] -- 251
	if sprite == nil then -- 251
		if self.unavailable[path] then -- 251
			return false -- 254
		end -- 254
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 256
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 257
		local ____Content_exist_result_4 -- 258
		if Content:exist(file) then -- 258
			____Content_exist_result_4 = Sprite(path) -- 258
		else -- 258
			____Content_exist_result_4 = nil -- 258
		end -- 258
		local loaded = ____Content_exist_result_4 -- 258
		if loaded == nil then -- 258
			self.unavailable[path] = true -- 260
			return false -- 261
		end -- 261
		loaded.anchor = Vec2(anchorX, anchorY) -- 263
		loaded.filter = smooth and "Anisotropic" or "Point" -- 264
		loaded:addTo(self.container) -- 265
		self.sprites[key] = loaded -- 266
		sprite = loaded -- 267
	end -- 267
	local scaleY = targetH / math.max(1, sprite.height) -- 270
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 271
	sprite.position = Vec2( -- 272
		math.floor(x + 0.5), -- 272
		math.floor(y + 0.5) -- 272
	) -- 272
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 273
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 274
	sprite.angle = options.angle or 0 -- 275
	sprite.order = options.layer or 0 -- 276
	local col = options.color or WHITE -- 277
	sprite.color = col -- 278
	local baseA = col.a / 255 -- 279
	local op = options.opacity or 1 -- 280
	sprite.opacity = math.max( -- 281
		0, -- 281
		math.min(1, baseA * op) -- 281
	) -- 281
	sprite.visible = true -- 282
	self.visibleThisFrame[key] = sprite -- 283
	return true -- 284
end -- 240
function AssetSlotHost.prototype.endFrame(self) -- 287
	for key in pairs(self.visibleLastFrame) do -- 288
		if self.visibleThisFrame[key] == nil then -- 288
			self.visibleLastFrame[key].visible = false -- 290
		end -- 290
	end -- 290
	self.visibleLastFrame = self.visibleThisFrame -- 293
end -- 287
return ____exports -- 287