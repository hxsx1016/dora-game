-- [ts]: textpool.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Label = ____Dora.Label -- 8
local Node = ____Dora.Node -- 8
local Vec2 = ____Dora.Vec2 -- 8
local FONT = "sarasa-mono-sc-regular" -- 10
local BUCKET_SIZES = { -- 14
	xs = 14, -- 15
	sm = 17, -- 16
	md = 21, -- 17
	lg = 30, -- 18
	xl = 48 -- 19
} -- 19
local BUCKET_CAPS = { -- 22
	xs = 28, -- 23
	sm = 36, -- 24
	md = 24, -- 25
	lg = 12, -- 26
	xl = 4 -- 27
} -- 27
____exports.TextPool = __TS__Class() -- 30
local TextPool = ____exports.TextPool -- 30
TextPool.name = "TextPool" -- 30
function TextPool.prototype.____constructor(self, parent, order) -- 35
	self.container = Node() -- 36
	self.container.order = order -- 37
	self.container:addTo(parent) -- 38
	self.pools = { -- 39
		xs = {}, -- 39
		sm = {}, -- 39
		md = {}, -- 39
		lg = {}, -- 39
		xl = {} -- 39
	} -- 39
	self.used = { -- 40
		xs = 0, -- 40
		sm = 0, -- 40
		md = 0, -- 40
		lg = 0, -- 40
		xl = 0 -- 40
	} -- 40
	self:allocBucket("xs") -- 42
	self:allocBucket("sm") -- 43
	self:allocBucket("md") -- 44
	self:allocBucket("lg") -- 45
	self:allocBucket("xl") -- 46
end -- 35
function TextPool.prototype.allocBucket(self, bucket) -- 49
	local size = BUCKET_SIZES[bucket] -- 50
	local cap = BUCKET_CAPS[bucket] -- 51
	local list = self.pools[bucket] -- 52
	local i = 0 -- 53
	do -- 53
		i = 0 -- 54
		while i < cap do -- 54
			local lb = Label(FONT, size, true) -- 55
			if lb ~= nil then -- 55
				lb.outlineColor = Color(4, 7, 14, 210) -- 57
				lb.outlineWidth = 0.14 -- 58
				lb.visible = false -- 59
				lb:addTo(self.container) -- 60
				list[#list + 1] = lb -- 61
			end -- 61
			i = i + 1 -- 54
		end -- 54
	end -- 54
end -- 49
function TextPool.prototype.beginFrame(self) -- 66
	self.used.xs = 0 -- 67
	self.used.sm = 0 -- 68
	self.used.md = 0 -- 69
	self.used.lg = 0 -- 70
	self.used.xl = 0 -- 71
end -- 66
function TextPool.prototype.put(self, bucket, text, x, y, color, ax, ay, align, spacing, opacity) -- 74
	if ax == nil then -- 74
		ax = 0 -- 80
	end -- 80
	if ay == nil then -- 80
		ay = 0.5 -- 81
	end -- 81
	if align == nil then -- 81
		align = "Left" -- 82
	end -- 82
	if spacing == nil then -- 82
		spacing = 0 -- 83
	end -- 83
	if opacity == nil then -- 83
		opacity = 1 -- 84
	end -- 84
	if text == "" then -- 84
		return -- 87
	end -- 87
	local list = self.pools[bucket] -- 89
	local idx = self.used[bucket] -- 90
	if idx >= #list then -- 90
		return -- 92
	end -- 92
	self.used[bucket] = idx + 1 -- 94
	local lb = list[idx + 1] -- 95
	lb.text = text -- 96
	lb.color = color -- 97
	lb.position = Vec2( -- 98
		math.floor(x + 0.5), -- 98
		math.floor(y + 0.5) -- 98
	) -- 98
	lb.anchor = Vec2(ax, ay) -- 99
	lb.alignment = align -- 100
	lb.spacing = spacing -- 101
	lb.opacity = math.max( -- 102
		0, -- 102
		math.min(1, opacity) -- 102
	) -- 102
	lb.visible = true -- 103
end -- 74
function TextPool.prototype.endFrame(self) -- 106
	self:hideRest("xs") -- 107
	self:hideRest("sm") -- 108
	self:hideRest("md") -- 109
	self:hideRest("lg") -- 110
	self:hideRest("xl") -- 111
end -- 106
function TextPool.prototype.hideAll(self) -- 114
	self:beginFrame() -- 115
	self:endFrame() -- 116
end -- 114
function TextPool.prototype.hideRest(self, bucket) -- 119
	local list = self.pools[bucket] -- 120
	local i = self.used[bucket] -- 121
	do -- 121
		while i < #list do -- 121
			list[i + 1].visible = false -- 123
			i = i + 1 -- 122
		end -- 122
	end -- 122
end -- 119
return ____exports -- 119