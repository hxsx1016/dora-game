-- [ts]: textpool.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Content = ____Dora.Content -- 8
local Label = ____Dora.Label -- 8
local Node = ____Dora.Node -- 8
local Vec2 = ____Dora.Vec2 -- 8
local FONT_FALLBACK = "sarasa-mono-sc-regular" -- 10
local FONT_BODY_PATH = "assets/font/lxgw-neo-zhisong.ttf" -- 11
local FONT_CALLI_PATH = "assets/font/longcang-brush.ttf" -- 12
local DEFAULT_OUTLINE = Color(8, 10, 15, 200) -- 14
local BUCKET_SIZES = { -- 18
	xs = 15, -- 19
	sm = 18, -- 20
	md = 21, -- 21
	lg = 28, -- 22
	xl = 44, -- 23
	seal = 15, -- 24
	sealLg = 19, -- 25
	banner = 42, -- 26
	title = 68 -- 27
} -- 27
local BUCKET_CAPS = { -- 30
	xs = 44, -- 31
	sm = 44, -- 32
	md = 28, -- 33
	lg = 14, -- 34
	xl = 6, -- 35
	seal = 16, -- 36
	sealLg = 8, -- 37
	banner = 8, -- 38
	title = 10 -- 39
} -- 39
local CALLI_BUCKETS = { -- 42
	xs = false, -- 43
	sm = false, -- 44
	md = false, -- 45
	lg = false, -- 46
	xl = false, -- 47
	seal = true, -- 48
	sealLg = true, -- 49
	banner = true, -- 50
	title = true -- 51
} -- 51
local function resolveFont(useCalli) -- 54
	if useCalli and Content:exist(FONT_CALLI_PATH) then -- 54
		return FONT_CALLI_PATH -- 56
	end -- 56
	if Content:exist(FONT_BODY_PATH) then -- 56
		return FONT_BODY_PATH -- 59
	end -- 59
	return FONT_FALLBACK -- 61
end -- 54
____exports.TextPool = __TS__Class() -- 64
local TextPool = ____exports.TextPool -- 64
TextPool.name = "TextPool" -- 64
function TextPool.prototype.____constructor(self, parent, order) -- 69
	self.container = Node() -- 70
	self.container.order = order -- 71
	self.container:addTo(parent) -- 72
	self.pools = { -- 73
		xs = {}, -- 74
		sm = {}, -- 74
		md = {}, -- 74
		lg = {}, -- 74
		xl = {}, -- 74
		seal = {}, -- 75
		sealLg = {}, -- 75
		banner = {}, -- 75
		title = {} -- 75
	} -- 75
	self.used = { -- 77
		xs = 0, -- 78
		sm = 0, -- 78
		md = 0, -- 78
		lg = 0, -- 78
		xl = 0, -- 78
		seal = 0, -- 79
		sealLg = 0, -- 79
		banner = 0, -- 79
		title = 0 -- 79
	} -- 79
	self:allocBucket("xs") -- 82
	self:allocBucket("sm") -- 83
	self:allocBucket("md") -- 84
	self:allocBucket("lg") -- 85
	self:allocBucket("xl") -- 86
	self:allocBucket("seal") -- 87
	self:allocBucket("sealLg") -- 88
	self:allocBucket("banner") -- 89
	self:allocBucket("title") -- 90
end -- 69
function TextPool.prototype.allocBucket(self, bucket) -- 93
	local size = BUCKET_SIZES[bucket] -- 94
	local cap = BUCKET_CAPS[bucket] -- 95
	local font = resolveFont(CALLI_BUCKETS[bucket]) -- 96
	local list = self.pools[bucket] -- 97
	local i = 0 -- 98
	do -- 98
		i = 0 -- 99
		while i < cap do -- 99
			local lb = Label(font, size, true) -- 100
			if lb == nil and font ~= FONT_FALLBACK then -- 100
				lb = Label(FONT_FALLBACK, size, true) -- 102
			end -- 102
			if lb ~= nil then -- 102
				lb.outlineColor = DEFAULT_OUTLINE -- 105
				lb.outlineWidth = 0.13 -- 106
				lb.visible = false -- 107
				lb:addTo(self.container) -- 108
				list[#list + 1] = lb -- 109
			end -- 109
			i = i + 1 -- 99
		end -- 99
	end -- 99
end -- 93
function TextPool.prototype.beginFrame(self) -- 114
	self.used.xs = 0 -- 115
	self.used.sm = 0 -- 116
	self.used.md = 0 -- 117
	self.used.lg = 0 -- 118
	self.used.xl = 0 -- 119
	self.used.seal = 0 -- 120
	self.used.sealLg = 0 -- 121
	self.used.banner = 0 -- 122
	self.used.title = 0 -- 123
end -- 114
function TextPool.prototype.put(self, bucket, text, x, y, color, ax, ay, align, spacing, opacity, outlineWidth, outlineColor) -- 126
	if ax == nil then -- 126
		ax = 0 -- 132
	end -- 132
	if ay == nil then -- 132
		ay = 0.5 -- 133
	end -- 133
	if align == nil then -- 133
		align = "Left" -- 134
	end -- 134
	if spacing == nil then -- 134
		spacing = 0 -- 135
	end -- 135
	if opacity == nil then -- 135
		opacity = 1 -- 136
	end -- 136
	if outlineWidth == nil then -- 136
		outlineWidth = 0.13 -- 137
	end -- 137
	if text == "" then -- 137
		return -- 141
	end -- 141
	local list = self.pools[bucket] -- 143
	local idx = self.used[bucket] -- 144
	if idx >= #list then -- 144
		return -- 146
	end -- 146
	self.used[bucket] = idx + 1 -- 148
	local lb = list[idx + 1] -- 149
	lb.text = text -- 150
	lb.color = color -- 151
	lb.outlineWidth = outlineWidth -- 152
	if outlineColor ~= nil then -- 152
		lb.outlineColor = outlineColor -- 154
	elseif outlineWidth <= 0 then -- 154
		lb.outlineColor = Color(0, 0, 0, 0) -- 156
	else -- 156
		lb.outlineColor = DEFAULT_OUTLINE -- 158
	end -- 158
	lb.position = Vec2( -- 160
		math.floor(x + 0.5), -- 160
		math.floor(y + 0.5) -- 160
	) -- 160
	lb.anchor = Vec2(ax, ay) -- 161
	lb.alignment = align -- 162
	lb.spacing = spacing -- 163
	lb.opacity = math.max( -- 164
		0, -- 164
		math.min(1, opacity) -- 164
	) -- 164
	lb.visible = true -- 165
end -- 126
function TextPool.prototype.endFrame(self) -- 168
	self:hideRest("xs") -- 169
	self:hideRest("sm") -- 170
	self:hideRest("md") -- 171
	self:hideRest("lg") -- 172
	self:hideRest("xl") -- 173
	self:hideRest("seal") -- 174
	self:hideRest("sealLg") -- 175
	self:hideRest("banner") -- 176
	self:hideRest("title") -- 177
end -- 168
function TextPool.prototype.hideAll(self) -- 180
	self:beginFrame() -- 181
	self:endFrame() -- 182
end -- 180
function TextPool.prototype.hideRest(self, bucket) -- 185
	local list = self.pools[bucket] -- 186
	local i = self.used[bucket] -- 187
	do -- 187
		while i < #list do -- 187
			list[i + 1].visible = false -- 189
			i = i + 1 -- 188
		end -- 188
	end -- 188
end -- 185
return ____exports -- 185