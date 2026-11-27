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
local function backdrop(name, smooth) -- 47
	if smooth == nil then -- 47
		smooth = false -- 47
	end -- 47
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 48
end -- 47
local function clip(names, anchorY, preserveAspect, anchorX) -- 53
	if anchorY == nil then -- 53
		anchorY = 0 -- 55
	end -- 55
	if preserveAspect == nil then -- 55
		preserveAspect = false -- 56
	end -- 56
	local frames = type(names) == "string" and ({names}) or names -- 59
	return { -- 60
		paths = __TS__ArrayMap( -- 60
			frames, -- 60
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 60
		), -- 60
		anchorX = anchorX, -- 60
		anchorY = anchorY, -- 60
		preserveAspect = preserveAspect -- 60
	} -- 60
end -- 53
local function inkClip(name, preserveAspect) -- 63
	if preserveAspect == nil then -- 63
		preserveAspect = false -- 63
	end -- 63
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 64
end -- 63
local function actor(names, anchorX) -- 67
	return clip(names, 0, true, anchorX) -- 68
end -- 67
____exports.ASSET_SLOTS = { -- 71
	bgFar_prologue = backdrop("prologue"), -- 72
	bgFar_street = backdrop("street"), -- 73
	bgFar_checkpoint = backdrop("checkpoint"), -- 74
	bgFar_gate = backdrop("gate"), -- 75
	bgFar_outside = backdrop("outside"), -- 76
	bgFar_village = backdrop("village"), -- 77
	bgFar_forest = backdrop("forest"), -- 78
	bgFar_tower = backdrop("tower"), -- 79
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods", true), -- 80
	bgFar_archway_yard = backdrop("bg_archway_yard", true), -- 81
	bgFar_granary = backdrop("bg_granary", true), -- 82
	bgFar_escort_ridge = backdrop("bg_escort_ridge", true), -- 83
	bgFar_museum = backdrop("bg_museum_hall", true), -- 84
	title_backdrop = backdrop("title"), -- 85
	soldier_idle = actor("soldier_idle"), -- 86
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}, {0.54, 0.5, 0.45, 0.5}), -- 87
	soldier_roll = actor("soldier_roll", 0.47), -- 88
	soldier_cover = actor("soldier_cover", 0.47), -- 89
	soldier_push = actor({"soldier_push", "soldier_push_step"}, {0.43, 0.46}), -- 90
	soldier_hold = actor("soldier_hold"), -- 91
	soldier_offer = actor("soldier_offer", 0.48), -- 92
	soldier_knock = actor({"soldier_cover", "soldier_knock"}, {0.47, 0.39}), -- 93
	soldier_hit = actor("soldier_hit", 0.5), -- 94
	soldier_fire = actor("soldier_fire", 0.51), -- 95
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}, {0.53, 0.51, 0.55, 0.51}), -- 96
	child_idle = actor("child_idle", 0.48), -- 97
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}, {0.54, 0.48, 0.51, 0.48}), -- 98
	child_crouch = actor({"child_crouch", "child_crouch_step"}, {0.44, 0.43}), -- 99
	child_fear = actor("child_fear", 0.48), -- 100
	child_peek = actor("child_peek", 0.5), -- 101
	child_pull = actor({"child_pull", "child_pull_step"}, {0.4, 0.44}), -- 102
	child_aim = actor("child_aim", 0.47), -- 103
	child_throw = actor("child_throw", 0.49), -- 104
	child_knock = actor("child_knock", 0.5), -- 105
	child_offer = actor("child_offer", 0.49), -- 106
	enemy_idle = actor("enemy_idle", 0.5), -- 107
	enemy_aim = actor("enemy_aim", 0.51), -- 108
	enemy_down = actor("enemy_down"), -- 109
	enemy_hit = actor("enemy_hit", 0.48), -- 110
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 111
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 112
	prop_cart = clip("cart", 0, false, 0.44), -- 113
	prop_bottle = clip("bottle", 0.5, true), -- 114
	prop_tower_door = clip("door"), -- 115
	prop_lantern = clip("lantern", 0.5, true), -- 116
	prop_table = clip("table"), -- 117
	prop_compass = clip("compass", 0.5, true), -- 118
	prop_winch = clip("winch", 0.5, true), -- 119
	wall = clip("wall"), -- 120
	cover_wood = clip("cover_wood"), -- 121
	cover_stone = clip("cover_stone"), -- 122
	fence = clip("fence"), -- 123
	slab = clip("slab"), -- 124
	eaves = clip("eaves"), -- 125
	pine = clip("pine"), -- 126
	grass = clip("grass"), -- 127
	grass_low = clip("grass_low"), -- 128
	stone_chips = clip("stone_chips", 0.5, true), -- 129
	ui_corner = clip("ui_corner"), -- 130
	ui_corner_c = clip("ui_corner", 0.5, false), -- 131
	ui_paper = clip("paper", 0.5), -- 132
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 133
	ink_mist_curve = inkClip("ink_mist_curve"), -- 134
	ink_veil_strip = inkClip("ink_veil_strip"), -- 135
	ink_hairline = inkClip("ink_hairline"), -- 136
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 137
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 138
	ink_frame_mask = inkClip("ink_frame_mask"), -- 139
	ink_vstream = inkClip("ink_vstream"), -- 140
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 141
	ink_corner_fine = inkClip("ink_corner_fine"), -- 142
	ink_seal_slender = inkClip("ink_seal_slender"), -- 143
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 144
	ink_enso_fine = inkClip("ink_enso_fine"), -- 145
	ink_petal_mist = inkClip("ink_petal_mist"), -- 146
	ink_song_paper = inkClip("ink_song_paper"), -- 147
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 148
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 149
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 150
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true} -- 151
} -- 151
local WHITE = Color(255, 255, 255, 255) -- 154
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 160
	local g = _G -- 161
	local ____temp_0 -- 162
	if g.package ~= nil then -- 162
		____temp_0 = g.package.loaded -- 162
	else -- 162
		____temp_0 = nil -- 162
	end -- 162
	local loaded = ____temp_0 -- 162
	if loaded ~= nil then -- 162
		local existing = loaded["watch.fe.dynamic_slots"] -- 164
		if existing ~= nil and type(existing) == "table" then -- 164
			return existing -- 166
		end -- 166
		local created = {} -- 168
		loaded["watch.fe.dynamic_slots"] = created -- 169
		return created -- 170
	end -- 170
	return FALLBACK_DYNAMIC_SLOTS -- 172
end -- 160
FALLBACK_DYNAMIC_SLOTS = {} -- 175
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 178
	sharedDynamicSlots()[key] = cfg -- 179
end -- 178
function ____exports.unregisterDynamicSlot(key) -- 182
	__TS__Delete( -- 183
		sharedDynamicSlots(), -- 183
		key -- 183
	) -- 183
end -- 182
____exports.AssetSlotHost = __TS__Class() -- 186
local AssetSlotHost = ____exports.AssetSlotHost -- 186
AssetSlotHost.name = "AssetSlotHost" -- 186
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 194
	self.sprites = {} -- 188
	self.unavailable = {} -- 189
	self.visibleLastFrame = {} -- 190
	self.visibleThisFrame = {} -- 191
	self.localSlots = {} -- 192
	self.container = Node() -- 195
	self.container.order = order -- 196
	self.container:addTo(parent) -- 197
end -- 194
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 201
	self.localSlots[key] = cfg -- 202
end -- 201
function AssetSlotHost.prototype.beginFrame(self) -- 205
	self.visibleThisFrame = {} -- 206
end -- 205
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 209
	if options == nil then -- 209
		options = {} -- 213
	end -- 213
	local staticSlots = ____exports.ASSET_SLOTS -- 215
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 216
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 216
		return false -- 218
	end -- 218
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 220
	local path = cfg.paths[frame + 1] -- 221
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 222
	return self:placeResolvedPath( -- 225
		path, -- 225
		anchorX, -- 225
		cfg.anchorY, -- 225
		cfg.preserveAspect, -- 225
		cfg.smooth == true, -- 225
		instanceKey, -- 225
		x, -- 225
		y, -- 225
		targetW, -- 225
		targetH, -- 225
		options -- 225
	) -- 225
end -- 209
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 229
	if options == nil then -- 229
		options = {} -- 233
	end -- 233
	if path == "" or targetW <= 0 or targetH <= 0 then -- 233
		return false -- 236
	end -- 236
	local ____self_placeResolvedPath_3 = self.placeResolvedPath -- 238
	local ____array_2 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 238
	local ____options_preserveAspect_1 = options.preserveAspect -- 242
	if ____options_preserveAspect_1 == nil then -- 242
		____options_preserveAspect_1 = false -- 242
	end -- 242
	__TS__SparseArrayPush( -- 242
		____array_2, -- 242
		____options_preserveAspect_1, -- 242
		options.smooth == true, -- 243
		instanceKey, -- 244
		x, -- 245
		y, -- 246
		targetW, -- 247
		targetH, -- 248
		options -- 249
	) -- 249
	return ____self_placeResolvedPath_3( -- 238
		self, -- 238
		__TS__SparseArraySpread(____array_2) -- 238
	) -- 238
end -- 229
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 253
	local key = (instanceKey .. ":") .. path -- 263
	local sprite = self.sprites[key] -- 264
	if sprite == nil then -- 264
		if self.unavailable[path] then -- 264
			return false -- 267
		end -- 267
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 269
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 270
		local ____Content_exist_result_4 -- 271
		if Content:exist(file) then -- 271
			____Content_exist_result_4 = Sprite(path) -- 271
		else -- 271
			____Content_exist_result_4 = nil -- 271
		end -- 271
		local loaded = ____Content_exist_result_4 -- 271
		if loaded == nil then -- 271
			self.unavailable[path] = true -- 273
			return false -- 274
		end -- 274
		loaded.anchor = Vec2(anchorX, anchorY) -- 276
		loaded.filter = smooth and "Anisotropic" or "Point" -- 277
		loaded:addTo(self.container) -- 278
		self.sprites[key] = loaded -- 279
		sprite = loaded -- 280
	end -- 280
	local scaleY = targetH / math.max(1, sprite.height) -- 283
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 284
	sprite.position = Vec2( -- 285
		math.floor(x + 0.5), -- 285
		math.floor(y + 0.5) -- 285
	) -- 285
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 286
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 287
	sprite.angle = options.angle or 0 -- 288
	sprite.order = options.layer or 0 -- 289
	local col = options.color or WHITE -- 290
	sprite.color = col -- 291
	local baseA = col.a / 255 -- 292
	local op = options.opacity or 1 -- 293
	sprite.opacity = math.max( -- 294
		0, -- 294
		math.min(1, baseA * op) -- 294
	) -- 294
	sprite.visible = true -- 295
	self.visibleThisFrame[key] = sprite -- 296
	return true -- 297
end -- 253
function AssetSlotHost.prototype.endFrame(self) -- 300
	for key in pairs(self.visibleLastFrame) do -- 301
		if self.visibleThisFrame[key] == nil then -- 301
			self.visibleLastFrame[key].visible = false -- 303
		end -- 303
	end -- 303
	self.visibleLastFrame = self.visibleThisFrame -- 306
end -- 300
return ____exports -- 300