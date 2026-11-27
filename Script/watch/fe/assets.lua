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
____exports.ASSET_SLOTS = { -- 68
	bgFar_prologue = backdrop("prologue"), -- 69
	bgFar_street = backdrop("street"), -- 70
	bgFar_checkpoint = backdrop("checkpoint"), -- 71
	bgFar_gate = backdrop("gate"), -- 72
	bgFar_outside = backdrop("outside"), -- 73
	bgFar_village = backdrop("village"), -- 74
	bgFar_forest = backdrop("forest"), -- 75
	bgFar_tower = backdrop("tower"), -- 76
	title_backdrop = backdrop("title"), -- 77
	soldier_idle = actor("soldier_idle"), -- 78
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 79
	soldier_roll = actor("soldier_roll", 0.47), -- 80
	soldier_cover = actor("soldier_cover", 0.47), -- 81
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 82
	soldier_hold = actor("soldier_hold"), -- 83
	soldier_offer = actor("soldier_offer", 0.48), -- 84
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 85
	soldier_hit = actor("soldier_hit", 0.5), -- 86
	soldier_fire = actor("soldier_fire", 0.51), -- 87
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 88
	child_idle = actor("child_idle", 0.48), -- 89
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 90
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 91
	child_fear = actor("child_fear", 0.48), -- 92
	child_peek = actor("child_peek", 0.5), -- 93
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 94
	child_aim = actor("child_aim", 0.47), -- 95
	child_throw = actor("child_throw", 0.49), -- 96
	child_knock = actor("child_knock", 0.5), -- 97
	child_offer = actor("child_offer", 0.49), -- 98
	enemy_idle = actor("enemy_idle", 0.5), -- 99
	enemy_aim = actor("enemy_aim", 0.51), -- 100
	enemy_down = actor("enemy_down"), -- 101
	enemy_hit = actor("enemy_hit", 0.48), -- 102
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 103
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 104
	prop_cart = clip("cart", 0, false, 0.44), -- 105
	prop_bottle = clip("bottle", 0.5, true), -- 106
	prop_tower_door = clip("door"), -- 107
	prop_lantern = clip("lantern", 0.5, true), -- 108
	prop_table = clip("table"), -- 109
	prop_compass = clip("compass", 0.5, true), -- 110
	prop_winch = clip("winch", 0.5, true), -- 111
	wall = clip("wall"), -- 112
	cover_wood = clip("cover_wood"), -- 113
	cover_stone = clip("cover_stone"), -- 114
	fence = clip("fence"), -- 115
	slab = clip("slab"), -- 116
	eaves = clip("eaves"), -- 117
	pine = clip("pine"), -- 118
	grass = clip("grass"), -- 119
	grass_low = clip("grass_low"), -- 120
	stone_chips = clip("stone_chips", 0.5, true), -- 121
	ui_corner = clip("ui_corner"), -- 122
	ui_corner_c = clip("ui_corner", 0.5, false), -- 123
	ui_paper = clip("paper", 0.5), -- 124
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 125
	ink_mist_curve = inkClip("ink_mist_curve"), -- 126
	ink_veil_strip = inkClip("ink_veil_strip"), -- 127
	ink_hairline = inkClip("ink_hairline"), -- 128
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 129
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 130
	ink_frame_mask = inkClip("ink_frame_mask"), -- 131
	ink_vstream = inkClip("ink_vstream"), -- 132
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 133
	ink_corner_fine = inkClip("ink_corner_fine"), -- 134
	ink_seal_slender = inkClip("ink_seal_slender"), -- 135
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 136
	ink_enso_fine = inkClip("ink_enso_fine"), -- 137
	ink_petal_mist = inkClip("ink_petal_mist"), -- 138
	ink_song_paper = inkClip("ink_song_paper"), -- 139
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 140
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 141
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 142
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true} -- 143
} -- 143
local WHITE = Color(255, 255, 255, 255) -- 146
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 152
	local g = _G -- 153
	local ____temp_0 -- 154
	if g.package ~= nil then -- 154
		____temp_0 = g.package.loaded -- 154
	else -- 154
		____temp_0 = nil -- 154
	end -- 154
	local loaded = ____temp_0 -- 154
	if loaded ~= nil then -- 154
		local existing = loaded["watch.fe.dynamic_slots"] -- 156
		if existing ~= nil and type(existing) == "table" then -- 156
			return existing -- 158
		end -- 158
		local created = {} -- 160
		loaded["watch.fe.dynamic_slots"] = created -- 161
		return created -- 162
	end -- 162
	return FALLBACK_DYNAMIC_SLOTS -- 164
end -- 152
FALLBACK_DYNAMIC_SLOTS = {} -- 167
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 170
	sharedDynamicSlots()[key] = cfg -- 171
end -- 170
function ____exports.unregisterDynamicSlot(key) -- 174
	__TS__Delete( -- 175
		sharedDynamicSlots(), -- 175
		key -- 175
	) -- 175
end -- 174
____exports.AssetSlotHost = __TS__Class() -- 178
local AssetSlotHost = ____exports.AssetSlotHost -- 178
AssetSlotHost.name = "AssetSlotHost" -- 178
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 186
	self.sprites = {} -- 180
	self.unavailable = {} -- 181
	self.visibleLastFrame = {} -- 182
	self.visibleThisFrame = {} -- 183
	self.localSlots = {} -- 184
	self.container = Node() -- 187
	self.container.order = order -- 188
	self.container:addTo(parent) -- 189
end -- 186
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 193
	self.localSlots[key] = cfg -- 194
end -- 193
function AssetSlotHost.prototype.beginFrame(self) -- 197
	self.visibleThisFrame = {} -- 198
end -- 197
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 201
	if options == nil then -- 201
		options = {} -- 205
	end -- 205
	local staticSlots = ____exports.ASSET_SLOTS -- 207
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 208
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 208
		return false -- 210
	end -- 210
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 212
	local path = cfg.paths[frame + 1] -- 213
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 214
	return self:placeResolvedPath( -- 217
		path, -- 217
		anchorX, -- 217
		cfg.anchorY, -- 217
		cfg.preserveAspect, -- 217
		cfg.smooth == true, -- 217
		instanceKey, -- 217
		x, -- 217
		y, -- 217
		targetW, -- 217
		targetH, -- 217
		options -- 217
	) -- 217
end -- 201
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 221
	if options == nil then -- 221
		options = {} -- 225
	end -- 225
	if path == "" or targetW <= 0 or targetH <= 0 then -- 225
		return false -- 228
	end -- 228
	local ____self_placeResolvedPath_3 = self.placeResolvedPath -- 230
	local ____array_2 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 230
	local ____options_preserveAspect_1 = options.preserveAspect -- 234
	if ____options_preserveAspect_1 == nil then -- 234
		____options_preserveAspect_1 = false -- 234
	end -- 234
	__TS__SparseArrayPush( -- 234
		____array_2, -- 234
		____options_preserveAspect_1, -- 234
		options.smooth == true, -- 235
		instanceKey, -- 236
		x, -- 237
		y, -- 238
		targetW, -- 239
		targetH, -- 240
		options -- 241
	) -- 241
	return ____self_placeResolvedPath_3( -- 230
		self, -- 230
		__TS__SparseArraySpread(____array_2) -- 230
	) -- 230
end -- 221
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 245
	local key = (instanceKey .. ":") .. path -- 255
	local sprite = self.sprites[key] -- 256
	if sprite == nil then -- 256
		if self.unavailable[path] then -- 256
			return false -- 259
		end -- 259
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 261
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 262
		local ____Content_exist_result_4 -- 263
		if Content:exist(file) then -- 263
			____Content_exist_result_4 = Sprite(path) -- 263
		else -- 263
			____Content_exist_result_4 = nil -- 263
		end -- 263
		local loaded = ____Content_exist_result_4 -- 263
		if loaded == nil then -- 263
			self.unavailable[path] = true -- 265
			return false -- 266
		end -- 266
		loaded.anchor = Vec2(anchorX, anchorY) -- 268
		loaded.filter = smooth and "Anisotropic" or "Point" -- 269
		loaded:addTo(self.container) -- 270
		self.sprites[key] = loaded -- 271
		sprite = loaded -- 272
	end -- 272
	local scaleY = targetH / math.max(1, sprite.height) -- 275
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 276
	sprite.position = Vec2( -- 277
		math.floor(x + 0.5), -- 277
		math.floor(y + 0.5) -- 277
	) -- 277
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 278
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 279
	sprite.angle = options.angle or 0 -- 280
	sprite.order = options.layer or 0 -- 281
	local col = options.color or WHITE -- 282
	sprite.color = col -- 283
	local baseA = col.a / 255 -- 284
	local op = options.opacity or 1 -- 285
	sprite.opacity = math.max( -- 286
		0, -- 286
		math.min(1, baseA * op) -- 286
	) -- 286
	sprite.visible = true -- 287
	self.visibleThisFrame[key] = sprite -- 288
	return true -- 289
end -- 245
function AssetSlotHost.prototype.endFrame(self) -- 292
	for key in pairs(self.visibleLastFrame) do -- 293
		if self.visibleThisFrame[key] == nil then -- 293
			self.visibleLastFrame[key].visible = false -- 295
		end -- 295
	end -- 295
	self.visibleLastFrame = self.visibleThisFrame -- 298
end -- 292
return ____exports -- 292