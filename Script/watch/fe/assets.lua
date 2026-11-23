-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local function backdrop(name) -- 30
	return {paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false} -- 31
end -- 30
local function clip(names, anchorY, preserveAspect) -- 34
	if anchorY == nil then -- 34
		anchorY = 0 -- 34
	end -- 34
	if preserveAspect == nil then -- 34
		preserveAspect = false -- 34
	end -- 34
	local frames = type(names) == "string" and ({names}) or names -- 35
	return { -- 36
		paths = __TS__ArrayMap( -- 36
			frames, -- 36
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 36
		), -- 36
		anchorY = anchorY, -- 36
		preserveAspect = preserveAspect -- 36
	} -- 36
end -- 34
local function actor(names) -- 39
	return clip(names, 0, true) -- 40
end -- 39
____exports.ASSET_SLOTS = { -- 43
	bgFar_prologue = backdrop("prologue"), -- 44
	bgFar_street = backdrop("street"), -- 45
	bgFar_checkpoint = backdrop("checkpoint"), -- 46
	bgFar_gate = backdrop("gate"), -- 47
	bgFar_outside = backdrop("outside"), -- 48
	bgFar_village = backdrop("village"), -- 49
	bgFar_forest = backdrop("forest"), -- 50
	bgFar_tower = backdrop("tower"), -- 51
	title_backdrop = backdrop("title"), -- 52
	soldier_idle = actor("soldier_idle"), -- 53
	soldier_run = actor({"soldier_run", "soldier_idle", "soldier_step", "soldier_idle"}), -- 54
	soldier_roll = actor("soldier_roll"), -- 55
	soldier_cover = actor("soldier_cover"), -- 56
	soldier_push = actor({"soldier_push", "soldier_push_step"}), -- 57
	soldier_hold = actor("soldier_hold"), -- 58
	soldier_offer = actor("soldier_offer"), -- 59
	soldier_knock = actor({"soldier_cover", "soldier_knock"}), -- 60
	soldier_hit = actor("soldier_hit"), -- 61
	soldier_fire = actor("soldier_fire"), -- 62
	child_idle = actor("child_idle"), -- 63
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}), -- 64
	child_crouch = actor({"child_crouch", "child_crouch_step"}), -- 65
	child_fear = actor("child_fear"), -- 66
	child_peek = actor("child_peek"), -- 67
	child_pull = actor({"child_pull", "child_pull_step"}), -- 68
	child_aim = actor("child_aim"), -- 69
	child_throw = actor("child_throw"), -- 70
	child_knock = actor("child_knock"), -- 71
	child_offer = actor("child_offer"), -- 72
	enemy_idle = actor("enemy_idle"), -- 73
	enemy_aim = actor("enemy_aim"), -- 74
	enemy_down = actor("enemy_down"), -- 75
	enemy_hit = actor("enemy_hit"), -- 76
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 77
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 78
	prop_cart = clip("cart"), -- 79
	prop_bottle = clip("bottle", 0.5, true), -- 80
	prop_tower_door = clip("door"), -- 81
	prop_lantern = clip("lantern", 0.5, true), -- 82
	prop_table = clip("table"), -- 83
	prop_compass = clip("compass", 0.5, true), -- 84
	prop_winch = clip("winch", 0.5, true), -- 85
	wall = clip("wall"), -- 86
	cover_wood = clip("cover_wood"), -- 87
	cover_stone = clip("cover_stone"), -- 88
	fence = clip("fence"), -- 89
	slab = clip("slab"), -- 90
	eaves = clip("eaves"), -- 91
	pine = clip("pine"), -- 92
	grass = clip("grass"), -- 93
	grass_low = clip("grass_low"), -- 94
	stone_chips = clip("stone_chips", 0.5, true), -- 95
	ui_corner = clip("ui_corner"), -- 96
	ui_paper = clip("paper", 0.5) -- 97
} -- 97
____exports.AssetSlotHost = __TS__Class() -- 100
local AssetSlotHost = ____exports.AssetSlotHost -- 100
AssetSlotHost.name = "AssetSlotHost" -- 100
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 107
	self.sprites = {} -- 102
	self.unavailable = {} -- 103
	self.visibleLastFrame = {} -- 104
	self.visibleThisFrame = {} -- 105
	self.container = Node() -- 108
	self.container.order = order -- 109
	self.container:addTo(parent) -- 110
end -- 107
function AssetSlotHost.prototype.beginFrame(self) -- 113
	self.visibleThisFrame = {} -- 114
end -- 113
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 117
	if options == nil then -- 117
		options = {} -- 121
	end -- 121
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 123
	if cfg == nil or targetW <= 0 or targetH <= 0 then -- 123
		return false -- 125
	end -- 125
	local frame = (options.frame or 0) % #cfg.paths -- 127
	local path = cfg.paths[frame + 1] -- 128
	local key = (instanceKey .. ":") .. path -- 129
	local sprite = self.sprites[key] -- 130
	if sprite == nil then -- 130
		if self.unavailable[path] then -- 130
			return false -- 133
		end -- 133
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 135
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 136
		local ____Content_exist_result_0 -- 137
		if Content:exist(file) then -- 137
			____Content_exist_result_0 = Sprite(path) -- 137
		else -- 137
			____Content_exist_result_0 = nil -- 137
		end -- 137
		local loaded = ____Content_exist_result_0 -- 137
		if loaded == nil then -- 137
			self.unavailable[path] = true -- 139
			return false -- 140
		end -- 140
		loaded.anchor = Vec2(0.5, cfg.anchorY) -- 142
		loaded.filter = "Point" -- 143
		loaded:addTo(self.container) -- 144
		self.sprites[key] = loaded -- 145
		sprite = loaded -- 146
	end -- 146
	local scaleY = targetH / math.max(1, sprite.height) -- 149
	local scaleX = cfg.preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 150
	sprite.position = Vec2( -- 151
		math.floor(x + 0.5), -- 151
		math.floor(y + 0.5) -- 151
	) -- 151
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 152
	sprite.scaleY = scaleY -- 153
	sprite.angle = options.angle or 0 -- 154
	sprite.order = options.layer or 0 -- 155
	sprite.opacity = options.opacity or 1 -- 156
	sprite.visible = true -- 157
	self.visibleThisFrame[key] = sprite -- 158
	return true -- 159
end -- 117
function AssetSlotHost.prototype.endFrame(self) -- 162
	for key in pairs(self.visibleLastFrame) do -- 163
		if self.visibleThisFrame[key] == nil then -- 163
			self.visibleLastFrame[key].visible = false -- 165
		end -- 165
	end -- 165
	self.visibleLastFrame = self.visibleThisFrame -- 168
end -- 162
return ____exports -- 162