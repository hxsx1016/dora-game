-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local FALLBACK_DYNAMIC_SLOTS -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Node = ____Dora.Node -- 1
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
____exports.ASSET_SLOTS = { -- 60
	bgFar_prologue = backdrop("prologue"), -- 61
	bgFar_street = backdrop("street"), -- 62
	bgFar_checkpoint = backdrop("checkpoint"), -- 63
	bgFar_gate = backdrop("gate"), -- 64
	bgFar_outside = backdrop("outside"), -- 65
	bgFar_village = backdrop("village"), -- 66
	bgFar_forest = backdrop("forest"), -- 67
	bgFar_tower = backdrop("tower"), -- 68
	title_backdrop = backdrop("title"), -- 69
	soldier_idle = actor("soldier_idle"), -- 70
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}), -- 71
	soldier_roll = actor("soldier_roll"), -- 72
	soldier_cover = actor("soldier_cover"), -- 73
	soldier_push = actor({"soldier_push", "soldier_push_step"}), -- 74
	soldier_hold = actor("soldier_hold"), -- 75
	soldier_offer = actor("soldier_offer"), -- 76
	soldier_knock = actor({"soldier_cover", "soldier_knock"}), -- 77
	soldier_hit = actor("soldier_hit"), -- 78
	soldier_fire = actor("soldier_fire"), -- 79
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 80
	child_idle = actor("child_idle"), -- 81
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}), -- 82
	child_crouch = actor({"child_crouch", "child_crouch_step"}), -- 83
	child_fear = actor("child_fear"), -- 84
	child_peek = actor("child_peek"), -- 85
	child_pull = actor({"child_pull", "child_pull_step"}), -- 86
	child_aim = actor("child_aim"), -- 87
	child_throw = actor("child_throw"), -- 88
	child_knock = actor("child_knock"), -- 89
	child_offer = actor("child_offer"), -- 90
	enemy_idle = actor("enemy_idle"), -- 91
	enemy_aim = actor("enemy_aim"), -- 92
	enemy_down = actor("enemy_down"), -- 93
	enemy_hit = actor("enemy_hit"), -- 94
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 95
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 96
	prop_cart = clip("cart"), -- 97
	prop_bottle = clip("bottle", 0.5, true), -- 98
	prop_tower_door = clip("door"), -- 99
	prop_lantern = clip("lantern", 0.5, true), -- 100
	prop_table = clip("table"), -- 101
	prop_compass = clip("compass", 0.5, true), -- 102
	prop_winch = clip("winch", 0.5, true), -- 103
	wall = clip("wall"), -- 104
	cover_wood = clip("cover_wood"), -- 105
	cover_stone = clip("cover_stone"), -- 106
	fence = clip("fence"), -- 107
	slab = clip("slab"), -- 108
	eaves = clip("eaves"), -- 109
	pine = clip("pine"), -- 110
	grass = clip("grass"), -- 111
	grass_low = clip("grass_low"), -- 112
	stone_chips = clip("stone_chips", 0.5, true), -- 113
	ui_corner = clip("ui_corner"), -- 114
	ui_corner_c = clip("ui_corner", 0.5, false), -- 115
	ui_paper = clip("paper", 0.5), -- 116
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 117
	ink_mist_curve = inkClip("ink_mist_curve"), -- 118
	ink_veil_strip = inkClip("ink_veil_strip"), -- 119
	ink_hairline = inkClip("ink_hairline"), -- 120
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 121
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 122
	ink_frame_mask = inkClip("ink_frame_mask"), -- 123
	ink_vstream = inkClip("ink_vstream"), -- 124
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 125
	ink_corner_fine = inkClip("ink_corner_fine"), -- 126
	ink_seal_slender = inkClip("ink_seal_slender"), -- 127
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 128
	ink_enso_fine = inkClip("ink_enso_fine"), -- 129
	ink_petal_mist = inkClip("ink_petal_mist"), -- 130
	ink_song_paper = inkClip("ink_song_paper") -- 131
} -- 131
local WHITE = Color(255, 255, 255, 255) -- 134
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 140
	local g = _G -- 141
	local ____temp_0 -- 142
	if g.package ~= nil then -- 142
		____temp_0 = g.package.loaded -- 142
	else -- 142
		____temp_0 = nil -- 142
	end -- 142
	local loaded = ____temp_0 -- 142
	if loaded ~= nil then -- 142
		local existing = loaded["watch.fe.dynamic_slots"] -- 144
		if existing ~= nil and type(existing) == "table" then -- 144
			return existing -- 146
		end -- 146
		local created = {} -- 148
		loaded["watch.fe.dynamic_slots"] = created -- 149
		return created -- 150
	end -- 150
	return FALLBACK_DYNAMIC_SLOTS -- 152
end -- 140
FALLBACK_DYNAMIC_SLOTS = {} -- 155
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 158
	sharedDynamicSlots()[key] = cfg -- 159
end -- 158
function ____exports.unregisterDynamicSlot(key) -- 162
	__TS__Delete( -- 163
		sharedDynamicSlots(), -- 163
		key -- 163
	) -- 163
end -- 162
____exports.AssetSlotHost = __TS__Class() -- 166
local AssetSlotHost = ____exports.AssetSlotHost -- 166
AssetSlotHost.name = "AssetSlotHost" -- 166
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 174
	self.sprites = {} -- 168
	self.unavailable = {} -- 169
	self.visibleLastFrame = {} -- 170
	self.visibleThisFrame = {} -- 171
	self.localSlots = {} -- 172
	self.container = Node() -- 175
	self.container.order = order -- 176
	self.container:addTo(parent) -- 177
end -- 174
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 181
	self.localSlots[key] = cfg -- 182
end -- 181
function AssetSlotHost.prototype.beginFrame(self) -- 185
	self.visibleThisFrame = {} -- 186
end -- 185
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 189
	if options == nil then -- 189
		options = {} -- 193
	end -- 193
	local staticSlots = ____exports.ASSET_SLOTS -- 195
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 196
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 196
		return false -- 198
	end -- 198
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 200
	local path = cfg.paths[frame + 1] -- 201
	return self:placeResolvedPath( -- 202
		path, -- 202
		cfg.anchorY, -- 202
		cfg.preserveAspect, -- 202
		cfg.smooth == true, -- 202
		instanceKey, -- 202
		x, -- 202
		y, -- 202
		targetW, -- 202
		targetH, -- 202
		options -- 202
	) -- 202
end -- 189
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 206
	if options == nil then -- 206
		options = {} -- 210
	end -- 210
	if path == "" or targetW <= 0 or targetH <= 0 then -- 210
		return false -- 213
	end -- 213
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 215
	local ____path_2 = path -- 216
	local ____temp_3 = options.anchorY or 0.5 -- 217
	local ____options_preserveAspect_1 = options.preserveAspect -- 218
	if ____options_preserveAspect_1 == nil then -- 218
		____options_preserveAspect_1 = false -- 218
	end -- 218
	return ____self_placeResolvedPath_4( -- 215
		self, -- 215
		____path_2, -- 216
		____temp_3, -- 217
		____options_preserveAspect_1, -- 218
		options.smooth == true, -- 219
		instanceKey, -- 220
		x, -- 221
		y, -- 222
		targetW, -- 223
		targetH, -- 224
		options -- 225
	) -- 225
end -- 206
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options) -- 229
	local key = (instanceKey .. ":") .. path -- 238
	local sprite = self.sprites[key] -- 239
	if sprite == nil then -- 239
		if self.unavailable[path] then -- 239
			return false -- 242
		end -- 242
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 244
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 245
		local ____Content_exist_result_5 -- 246
		if Content:exist(file) then -- 246
			____Content_exist_result_5 = Sprite(path) -- 246
		else -- 246
			____Content_exist_result_5 = nil -- 246
		end -- 246
		local loaded = ____Content_exist_result_5 -- 246
		if loaded == nil then -- 246
			self.unavailable[path] = true -- 248
			return false -- 249
		end -- 249
		loaded.anchor = Vec2(0.5, anchorY) -- 251
		loaded.filter = smooth and "Anisotropic" or "Point" -- 252
		loaded:addTo(self.container) -- 253
		self.sprites[key] = loaded -- 254
		sprite = loaded -- 255
	end -- 255
	local scaleY = targetH / math.max(1, sprite.height) -- 258
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 259
	sprite.position = Vec2( -- 260
		math.floor(x + 0.5), -- 260
		math.floor(y + 0.5) -- 260
	) -- 260
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 261
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 262
	sprite.angle = options.angle or 0 -- 263
	sprite.order = options.layer or 0 -- 264
	local col = options.color or WHITE -- 265
	sprite.color = col -- 266
	local baseA = col.a / 255 -- 267
	local op = options.opacity or 1 -- 268
	sprite.opacity = math.max( -- 269
		0, -- 269
		math.min(1, baseA * op) -- 269
	) -- 269
	sprite.visible = true -- 270
	self.visibleThisFrame[key] = sprite -- 271
	return true -- 272
end -- 229
function AssetSlotHost.prototype.endFrame(self) -- 275
	for key in pairs(self.visibleLastFrame) do -- 276
		if self.visibleThisFrame[key] == nil then -- 276
			self.visibleLastFrame[key].visible = false -- 278
		end -- 278
	end -- 278
	self.visibleLastFrame = self.visibleThisFrame -- 281
end -- 275
return ____exports -- 275