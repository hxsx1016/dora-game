-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local function backdrop(name) -- 37
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 38
end -- 37
local function clip(names, anchorY, preserveAspect) -- 41
	if anchorY == nil then -- 41
		anchorY = 0 -- 41
	end -- 41
	if preserveAspect == nil then -- 41
		preserveAspect = false -- 41
	end -- 41
	local frames = type(names) == "string" and ({names}) or names -- 42
	return { -- 43
		paths = __TS__ArrayMap( -- 43
			frames, -- 43
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 43
		), -- 43
		anchorY = anchorY, -- 43
		preserveAspect = preserveAspect -- 43
	} -- 43
end -- 41
local function inkClip(name, preserveAspect) -- 46
	if preserveAspect == nil then -- 46
		preserveAspect = false -- 46
	end -- 46
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 47
end -- 46
local function actor(names) -- 50
	return clip(names, 0, true) -- 51
end -- 50
____exports.ASSET_SLOTS = { -- 54
	bgFar_prologue = backdrop("prologue"), -- 55
	bgFar_street = backdrop("street"), -- 56
	bgFar_checkpoint = backdrop("checkpoint"), -- 57
	bgFar_gate = backdrop("gate"), -- 58
	bgFar_outside = backdrop("outside"), -- 59
	bgFar_village = backdrop("village"), -- 60
	bgFar_forest = backdrop("forest"), -- 61
	bgFar_tower = backdrop("tower"), -- 62
	title_backdrop = backdrop("title"), -- 63
	soldier_idle = actor("soldier_idle"), -- 64
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}), -- 65
	soldier_roll = actor("soldier_roll"), -- 66
	soldier_cover = actor("soldier_cover"), -- 67
	soldier_push = actor({"soldier_push", "soldier_push_step"}), -- 68
	soldier_hold = actor("soldier_hold"), -- 69
	soldier_offer = actor("soldier_offer"), -- 70
	soldier_knock = actor({"soldier_cover", "soldier_knock"}), -- 71
	soldier_hit = actor("soldier_hit"), -- 72
	soldier_fire = actor("soldier_fire"), -- 73
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 74
	child_idle = actor("child_idle"), -- 75
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}), -- 76
	child_crouch = actor({"child_crouch", "child_crouch_step"}), -- 77
	child_fear = actor("child_fear"), -- 78
	child_peek = actor("child_peek"), -- 79
	child_pull = actor({"child_pull", "child_pull_step"}), -- 80
	child_aim = actor("child_aim"), -- 81
	child_throw = actor("child_throw"), -- 82
	child_knock = actor("child_knock"), -- 83
	child_offer = actor("child_offer"), -- 84
	enemy_idle = actor("enemy_idle"), -- 85
	enemy_aim = actor("enemy_aim"), -- 86
	enemy_down = actor("enemy_down"), -- 87
	enemy_hit = actor("enemy_hit"), -- 88
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 89
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 90
	prop_cart = clip("cart"), -- 91
	prop_bottle = clip("bottle", 0.5, true), -- 92
	prop_tower_door = clip("door"), -- 93
	prop_lantern = clip("lantern", 0.5, true), -- 94
	prop_table = clip("table"), -- 95
	prop_compass = clip("compass", 0.5, true), -- 96
	prop_winch = clip("winch", 0.5, true), -- 97
	wall = clip("wall"), -- 98
	cover_wood = clip("cover_wood"), -- 99
	cover_stone = clip("cover_stone"), -- 100
	fence = clip("fence"), -- 101
	slab = clip("slab"), -- 102
	eaves = clip("eaves"), -- 103
	pine = clip("pine"), -- 104
	grass = clip("grass"), -- 105
	grass_low = clip("grass_low"), -- 106
	stone_chips = clip("stone_chips", 0.5, true), -- 107
	ui_corner = clip("ui_corner"), -- 108
	ui_corner_c = clip("ui_corner", 0.5, false), -- 109
	ui_paper = clip("paper", 0.5), -- 110
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 111
	ink_mist_curve = inkClip("ink_mist_curve"), -- 112
	ink_veil_strip = inkClip("ink_veil_strip"), -- 113
	ink_hairline = inkClip("ink_hairline"), -- 114
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 115
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 116
	ink_frame_mask = inkClip("ink_frame_mask"), -- 117
	ink_vstream = inkClip("ink_vstream"), -- 118
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 119
	ink_corner_fine = inkClip("ink_corner_fine"), -- 120
	ink_seal_slender = inkClip("ink_seal_slender"), -- 121
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 122
	ink_enso_fine = inkClip("ink_enso_fine"), -- 123
	ink_petal_mist = inkClip("ink_petal_mist"), -- 124
	ink_song_paper = inkClip("ink_song_paper") -- 125
} -- 125
local WHITE = Color(255, 255, 255, 255) -- 128
____exports.AssetSlotHost = __TS__Class() -- 130
local AssetSlotHost = ____exports.AssetSlotHost -- 130
AssetSlotHost.name = "AssetSlotHost" -- 130
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 137
	self.sprites = {} -- 132
	self.unavailable = {} -- 133
	self.visibleLastFrame = {} -- 134
	self.visibleThisFrame = {} -- 135
	self.container = Node() -- 138
	self.container.order = order -- 139
	self.container:addTo(parent) -- 140
end -- 137
function AssetSlotHost.prototype.beginFrame(self) -- 143
	self.visibleThisFrame = {} -- 144
end -- 143
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 147
	if options == nil then -- 147
		options = {} -- 151
	end -- 151
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 153
	if cfg == nil or targetW <= 0 or targetH <= 0 then -- 153
		return false -- 155
	end -- 155
	local frame = (options.frame or 0) % #cfg.paths -- 157
	local path = cfg.paths[frame + 1] -- 158
	local key = (instanceKey .. ":") .. path -- 159
	local sprite = self.sprites[key] -- 160
	if sprite == nil then -- 160
		if self.unavailable[path] then -- 160
			return false -- 163
		end -- 163
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 165
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 166
		local ____Content_exist_result_0 -- 167
		if Content:exist(file) then -- 167
			____Content_exist_result_0 = Sprite(path) -- 167
		else -- 167
			____Content_exist_result_0 = nil -- 167
		end -- 167
		local loaded = ____Content_exist_result_0 -- 167
		if loaded == nil then -- 167
			self.unavailable[path] = true -- 169
			return false -- 170
		end -- 170
		loaded.anchor = Vec2(0.5, cfg.anchorY) -- 172
		loaded.filter = cfg.smooth and "Anisotropic" or "Point" -- 173
		loaded:addTo(self.container) -- 174
		self.sprites[key] = loaded -- 175
		sprite = loaded -- 176
	end -- 176
	local scaleY = targetH / math.max(1, sprite.height) -- 179
	local scaleX = cfg.preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 180
	sprite.position = Vec2( -- 181
		math.floor(x + 0.5), -- 181
		math.floor(y + 0.5) -- 181
	) -- 181
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 182
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 183
	sprite.angle = options.angle or 0 -- 184
	sprite.order = options.layer or 0 -- 185
	local col = options.color or WHITE -- 186
	sprite.color = col -- 187
	local baseA = col.a / 255 -- 188
	local op = options.opacity or 1 -- 189
	sprite.opacity = math.max( -- 190
		0, -- 190
		math.min(1, baseA * op) -- 190
	) -- 190
	sprite.visible = true -- 191
	self.visibleThisFrame[key] = sprite -- 192
	return true -- 193
end -- 147
function AssetSlotHost.prototype.endFrame(self) -- 196
	for key in pairs(self.visibleLastFrame) do -- 197
		if self.visibleThisFrame[key] == nil then -- 197
			self.visibleLastFrame[key].visible = false -- 199
		end -- 199
	end -- 199
	self.visibleLastFrame = self.visibleThisFrame -- 202
end -- 196
return ____exports -- 196