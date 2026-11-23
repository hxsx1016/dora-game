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
	child_idle = actor("child_idle"), -- 74
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}), -- 75
	child_crouch = actor({"child_crouch", "child_crouch_step"}), -- 76
	child_fear = actor("child_fear"), -- 77
	child_peek = actor("child_peek"), -- 78
	child_pull = actor({"child_pull", "child_pull_step"}), -- 79
	child_aim = actor("child_aim"), -- 80
	child_throw = actor("child_throw"), -- 81
	child_knock = actor("child_knock"), -- 82
	child_offer = actor("child_offer"), -- 83
	enemy_idle = actor("enemy_idle"), -- 84
	enemy_aim = actor("enemy_aim"), -- 85
	enemy_down = actor("enemy_down"), -- 86
	enemy_hit = actor("enemy_hit"), -- 87
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 88
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 89
	prop_cart = clip("cart"), -- 90
	prop_bottle = clip("bottle", 0.5, true), -- 91
	prop_tower_door = clip("door"), -- 92
	prop_lantern = clip("lantern", 0.5, true), -- 93
	prop_table = clip("table"), -- 94
	prop_compass = clip("compass", 0.5, true), -- 95
	prop_winch = clip("winch", 0.5, true), -- 96
	wall = clip("wall"), -- 97
	cover_wood = clip("cover_wood"), -- 98
	cover_stone = clip("cover_stone"), -- 99
	fence = clip("fence"), -- 100
	slab = clip("slab"), -- 101
	eaves = clip("eaves"), -- 102
	pine = clip("pine"), -- 103
	grass = clip("grass"), -- 104
	grass_low = clip("grass_low"), -- 105
	stone_chips = clip("stone_chips", 0.5, true), -- 106
	ui_corner = clip("ui_corner"), -- 107
	ui_corner_c = clip("ui_corner", 0.5, false), -- 108
	ui_paper = clip("paper", 0.5), -- 109
	ink_brush_wide = inkClip("ink_brush_wide"), -- 110
	ink_brush_sym = inkClip("ink_brush_sym"), -- 111
	ink_divider = inkClip("ink_divider"), -- 112
	ink_scroll_bar = inkClip("ink_scroll_bar"), -- 113
	ink_wash_panel = inkClip("ink_wash_panel"), -- 114
	ink_vbrush = inkClip("ink_vbrush"), -- 115
	ink_seal_solid = inkClip("ink_seal_solid"), -- 116
	ink_seal_hollow = inkClip("ink_seal_hollow"), -- 117
	ink_seal_oval = inkClip("ink_seal_oval"), -- 118
	ink_dot = inkClip("ink_dot"), -- 119
	ink_ring = inkClip("ink_ring"), -- 120
	ink_splatter = inkClip("ink_splatter"), -- 121
	ink_hp_bar = inkClip("ink_hp_bar"), -- 122
	ink_hp_slot = inkClip("ink_hp_slot"), -- 123
	ink_paper_grain = inkClip("ink_paper_grain") -- 124
} -- 124
local WHITE = Color(255, 255, 255, 255) -- 127
____exports.AssetSlotHost = __TS__Class() -- 129
local AssetSlotHost = ____exports.AssetSlotHost -- 129
AssetSlotHost.name = "AssetSlotHost" -- 129
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 136
	self.sprites = {} -- 131
	self.unavailable = {} -- 132
	self.visibleLastFrame = {} -- 133
	self.visibleThisFrame = {} -- 134
	self.container = Node() -- 137
	self.container.order = order -- 138
	self.container:addTo(parent) -- 139
end -- 136
function AssetSlotHost.prototype.beginFrame(self) -- 142
	self.visibleThisFrame = {} -- 143
end -- 142
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 146
	if options == nil then -- 146
		options = {} -- 150
	end -- 150
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 152
	if cfg == nil or targetW <= 0 or targetH <= 0 then -- 152
		return false -- 154
	end -- 154
	local frame = (options.frame or 0) % #cfg.paths -- 156
	local path = cfg.paths[frame + 1] -- 157
	local key = (instanceKey .. ":") .. path -- 158
	local sprite = self.sprites[key] -- 159
	if sprite == nil then -- 159
		if self.unavailable[path] then -- 159
			return false -- 162
		end -- 162
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 164
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 165
		local ____Content_exist_result_0 -- 166
		if Content:exist(file) then -- 166
			____Content_exist_result_0 = Sprite(path) -- 166
		else -- 166
			____Content_exist_result_0 = nil -- 166
		end -- 166
		local loaded = ____Content_exist_result_0 -- 166
		if loaded == nil then -- 166
			self.unavailable[path] = true -- 168
			return false -- 169
		end -- 169
		loaded.anchor = Vec2(0.5, cfg.anchorY) -- 171
		loaded.filter = cfg.smooth and "Anisotropic" or "Point" -- 172
		loaded:addTo(self.container) -- 173
		self.sprites[key] = loaded -- 174
		sprite = loaded -- 175
	end -- 175
	local scaleY = targetH / math.max(1, sprite.height) -- 178
	local scaleX = cfg.preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 179
	sprite.position = Vec2( -- 180
		math.floor(x + 0.5), -- 180
		math.floor(y + 0.5) -- 180
	) -- 180
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 181
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 182
	sprite.angle = options.angle or 0 -- 183
	sprite.order = options.layer or 0 -- 184
	local col = options.color or WHITE -- 185
	sprite.color = col -- 186
	local baseA = col.a / 255 -- 187
	local op = options.opacity or 1 -- 188
	sprite.opacity = math.max( -- 189
		0, -- 189
		math.min(1, baseA * op) -- 189
	) -- 189
	sprite.visible = true -- 190
	self.visibleThisFrame[key] = sprite -- 191
	return true -- 192
end -- 146
function AssetSlotHost.prototype.endFrame(self) -- 195
	for key in pairs(self.visibleLastFrame) do -- 196
		if self.visibleThisFrame[key] == nil then -- 196
			self.visibleLastFrame[key].visible = false -- 198
		end -- 198
	end -- 198
	self.visibleLastFrame = self.visibleThisFrame -- 201
end -- 195
return ____exports -- 195