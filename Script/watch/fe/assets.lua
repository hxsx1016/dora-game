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
	soldier_fire_move = actor({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 63
	child_idle = actor("child_idle"), -- 64
	child_run = actor({"child_run", "child_idle", "child_step", "child_idle"}), -- 65
	child_crouch = actor({"child_crouch", "child_crouch_step"}), -- 66
	child_fear = actor("child_fear"), -- 67
	child_peek = actor("child_peek"), -- 68
	child_pull = actor({"child_pull", "child_pull_step"}), -- 69
	child_aim = actor("child_aim"), -- 70
	child_throw = actor("child_throw"), -- 71
	child_knock = actor("child_knock"), -- 72
	child_offer = actor("child_offer"), -- 73
	enemy_idle = actor("enemy_idle"), -- 74
	enemy_aim = actor("enemy_aim"), -- 75
	enemy_down = actor("enemy_down"), -- 76
	enemy_hit = actor("enemy_hit"), -- 77
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}), -- 78
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}), -- 79
	prop_cart = clip("cart"), -- 80
	prop_bottle = clip("bottle", 0.5, true), -- 81
	prop_tower_door = clip("door"), -- 82
	prop_lantern = clip("lantern", 0.5, true), -- 83
	prop_table = clip("table"), -- 84
	prop_compass = clip("compass", 0.5, true), -- 85
	prop_winch = clip("winch", 0.5, true), -- 86
	wall = clip("wall"), -- 87
	cover_wood = clip("cover_wood"), -- 88
	cover_stone = clip("cover_stone"), -- 89
	fence = clip("fence"), -- 90
	slab = clip("slab"), -- 91
	eaves = clip("eaves"), -- 92
	pine = clip("pine"), -- 93
	grass = clip("grass"), -- 94
	grass_low = clip("grass_low"), -- 95
	stone_chips = clip("stone_chips", 0.5, true), -- 96
	ui_corner = clip("ui_corner"), -- 97
	ui_paper = clip("paper", 0.5) -- 98
} -- 98
____exports.AssetSlotHost = __TS__Class() -- 101
local AssetSlotHost = ____exports.AssetSlotHost -- 101
AssetSlotHost.name = "AssetSlotHost" -- 101
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 108
	self.sprites = {} -- 103
	self.unavailable = {} -- 104
	self.visibleLastFrame = {} -- 105
	self.visibleThisFrame = {} -- 106
	self.container = Node() -- 109
	self.container.order = order -- 110
	self.container:addTo(parent) -- 111
end -- 108
function AssetSlotHost.prototype.beginFrame(self) -- 114
	self.visibleThisFrame = {} -- 115
end -- 114
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 118
	if options == nil then -- 118
		options = {} -- 122
	end -- 122
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 124
	if cfg == nil or targetW <= 0 or targetH <= 0 then -- 124
		return false -- 126
	end -- 126
	local frame = (options.frame or 0) % #cfg.paths -- 128
	local path = cfg.paths[frame + 1] -- 129
	local key = (instanceKey .. ":") .. path -- 130
	local sprite = self.sprites[key] -- 131
	if sprite == nil then -- 131
		if self.unavailable[path] then -- 131
			return false -- 134
		end -- 134
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 136
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 137
		local ____Content_exist_result_0 -- 138
		if Content:exist(file) then -- 138
			____Content_exist_result_0 = Sprite(path) -- 138
		else -- 138
			____Content_exist_result_0 = nil -- 138
		end -- 138
		local loaded = ____Content_exist_result_0 -- 138
		if loaded == nil then -- 138
			self.unavailable[path] = true -- 140
			return false -- 141
		end -- 141
		loaded.anchor = Vec2(0.5, cfg.anchorY) -- 143
		loaded.filter = "Point" -- 144
		loaded:addTo(self.container) -- 145
		self.sprites[key] = loaded -- 146
		sprite = loaded -- 147
	end -- 147
	local scaleY = targetH / math.max(1, sprite.height) -- 150
	local scaleX = cfg.preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 151
	sprite.position = Vec2( -- 152
		math.floor(x + 0.5), -- 152
		math.floor(y + 0.5) -- 152
	) -- 152
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 153
	sprite.scaleY = scaleY -- 154
	sprite.angle = options.angle or 0 -- 155
	sprite.order = options.layer or 0 -- 156
	sprite.opacity = options.opacity or 1 -- 157
	sprite.visible = true -- 158
	self.visibleThisFrame[key] = sprite -- 159
	return true -- 160
end -- 118
function AssetSlotHost.prototype.endFrame(self) -- 163
	for key in pairs(self.visibleLastFrame) do -- 164
		if self.visibleThisFrame[key] == nil then -- 164
			self.visibleLastFrame[key].visible = false -- 166
		end -- 166
	end -- 166
	self.visibleLastFrame = self.visibleThisFrame -- 169
end -- 163
return ____exports -- 163