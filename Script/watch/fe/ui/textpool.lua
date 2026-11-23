-- [ts]: textpool.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Content = ____Dora.Content -- 10
local Label = ____Dora.Label -- 10
local Node = ____Dora.Node -- 10
local Vec2 = ____Dora.Vec2 -- 10
local FONT_FALLBACK = "sarasa-mono-sc-regular" -- 12
local FONT_BODY_PATH = "assets/font/lxgw-wenkai-medium.ttf" -- 13
local FONT_CALLI_PATH = "assets/font/mashanzheng-calligraphy.ttf" -- 14
local DEFAULT_OUTLINE = Color(8, 9, 13, 220) -- 16
local BUCKET_SIZES = { -- 20
	xs = 15, -- 21
	sm = 18, -- 22
	md = 23, -- 23
	lg = 32, -- 24
	xl = 48, -- 25
	seal = 16, -- 26
	sealLg = 21, -- 27
	banner = 38, -- 28
	title = 60 -- 29
} -- 29
local BUCKET_CAPS = { -- 32
	xs = 36, -- 33
	sm = 40, -- 34
	md = 28, -- 35
	lg = 14, -- 36
	xl = 6, -- 37
	seal = 20, -- 38
	sealLg = 8, -- 39
	banner = 6, -- 40
	title = 8 -- 41
} -- 41
local CALLI_BUCKETS = { -- 44
	xs = false, -- 45
	sm = false, -- 46
	md = false, -- 47
	lg = false, -- 48
	xl = false, -- 49
	seal = true, -- 50
	sealLg = true, -- 51
	banner = true, -- 52
	title = true -- 53
} -- 53
local function resolveFont(useCalli) -- 56
	if useCalli and Content:exist(FONT_CALLI_PATH) then -- 56
		return FONT_CALLI_PATH -- 58
	end -- 58
	if Content:exist(FONT_BODY_PATH) then -- 58
		return FONT_BODY_PATH -- 61
	end -- 61
	return FONT_FALLBACK -- 63
end -- 56
____exports.TextPool = __TS__Class() -- 66
local TextPool = ____exports.TextPool -- 66
TextPool.name = "TextPool" -- 66
function TextPool.prototype.____constructor(self, parent, order) -- 71
	self.container = Node() -- 72
	self.container.order = order -- 73
	self.container:addTo(parent) -- 74
	self.pools = { -- 75
		xs = {}, -- 76
		sm = {}, -- 76
		md = {}, -- 76
		lg = {}, -- 76
		xl = {}, -- 76
		seal = {}, -- 77
		sealLg = {}, -- 77
		banner = {}, -- 77
		title = {} -- 77
	} -- 77
	self.used = { -- 79
		xs = 0, -- 80
		sm = 0, -- 80
		md = 0, -- 80
		lg = 0, -- 80
		xl = 0, -- 80
		seal = 0, -- 81
		sealLg = 0, -- 81
		banner = 0, -- 81
		title = 0 -- 81
	} -- 81
	self:allocBucket("xs") -- 84
	self:allocBucket("sm") -- 85
	self:allocBucket("md") -- 86
	self:allocBucket("lg") -- 87
	self:allocBucket("xl") -- 88
	self:allocBucket("seal") -- 89
	self:allocBucket("sealLg") -- 90
	self:allocBucket("banner") -- 91
	self:allocBucket("title") -- 92
end -- 71
function TextPool.prototype.allocBucket(self, bucket) -- 95
	local size = BUCKET_SIZES[bucket] -- 96
	local cap = BUCKET_CAPS[bucket] -- 97
	local font = resolveFont(CALLI_BUCKETS[bucket]) -- 98
	local list = self.pools[bucket] -- 99
	local i = 0 -- 100
	do -- 100
		i = 0 -- 101
		while i < cap do -- 101
			local lb = Label(font, size, true) -- 102
			if lb == nil and font ~= FONT_FALLBACK then -- 102
				lb = Label(FONT_FALLBACK, size, true) -- 104
			end -- 104
			if lb ~= nil then -- 104
				lb.outlineColor = DEFAULT_OUTLINE -- 107
				lb.outlineWidth = 0.13 -- 108
				lb.visible = false -- 109
				lb:addTo(self.container) -- 110
				list[#list + 1] = lb -- 111
			end -- 111
			i = i + 1 -- 101
		end -- 101
	end -- 101
end -- 95
function TextPool.prototype.beginFrame(self) -- 116
	self.used.xs = 0 -- 117
	self.used.sm = 0 -- 118
	self.used.md = 0 -- 119
	self.used.lg = 0 -- 120
	self.used.xl = 0 -- 121
	self.used.seal = 0 -- 122
	self.used.sealLg = 0 -- 123
	self.used.banner = 0 -- 124
	self.used.title = 0 -- 125
end -- 116
function TextPool.prototype.put(self, bucket, text, x, y, color, ax, ay, align, spacing, opacity, outlineWidth, outlineColor) -- 128
	if ax == nil then -- 128
		ax = 0 -- 134
	end -- 134
	if ay == nil then -- 134
		ay = 0.5 -- 135
	end -- 135
	if align == nil then -- 135
		align = "Left" -- 136
	end -- 136
	if spacing == nil then -- 136
		spacing = 0 -- 137
	end -- 137
	if opacity == nil then -- 137
		opacity = 1 -- 138
	end -- 138
	if outlineWidth == nil then -- 138
		outlineWidth = 0.13 -- 139
	end -- 139
	if text == "" then -- 139
		return -- 143
	end -- 143
	local list = self.pools[bucket] -- 145
	local idx = self.used[bucket] -- 146
	if idx >= #list then -- 146
		return -- 148
	end -- 148
	self.used[bucket] = idx + 1 -- 150
	local lb = list[idx + 1] -- 151
	lb.text = text -- 152
	lb.color = color -- 153
	lb.outlineWidth = outlineWidth -- 154
	if outlineColor ~= nil then -- 154
		lb.outlineColor = outlineColor -- 156
	elseif outlineWidth <= 0 then -- 156
		lb.outlineColor = Color(0, 0, 0, 0) -- 158
	else -- 158
		lb.outlineColor = DEFAULT_OUTLINE -- 160
	end -- 160
	lb.position = Vec2( -- 162
		math.floor(x + 0.5), -- 162
		math.floor(y + 0.5) -- 162
	) -- 162
	lb.anchor = Vec2(ax, ay) -- 163
	lb.alignment = align -- 164
	lb.spacing = spacing -- 165
	lb.opacity = math.max( -- 166
		0, -- 166
		math.min(1, opacity) -- 166
	) -- 166
	lb.visible = true -- 167
end -- 128
function TextPool.prototype.endFrame(self) -- 170
	self:hideRest("xs") -- 171
	self:hideRest("sm") -- 172
	self:hideRest("md") -- 173
	self:hideRest("lg") -- 174
	self:hideRest("xl") -- 175
	self:hideRest("seal") -- 176
	self:hideRest("sealLg") -- 177
	self:hideRest("banner") -- 178
	self:hideRest("title") -- 179
end -- 170
function TextPool.prototype.hideAll(self) -- 182
	self:beginFrame() -- 183
	self:endFrame() -- 184
end -- 182
function TextPool.prototype.hideRest(self, bucket) -- 187
	local list = self.pools[bucket] -- 188
	local i = self.used[bucket] -- 189
	do -- 189
		while i < #list do -- 189
			list[i + 1].visible = false -- 191
			i = i + 1 -- 190
		end -- 190
	end -- 190
end -- 187
return ____exports -- 187