-- [ts]: textpool.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Content = ____Dora.Content -- 9
local Label = ____Dora.Label -- 9
local Node = ____Dora.Node -- 9
local Vec2 = ____Dora.Vec2 -- 9
local FONT_FALLBACK = "sarasa-mono-sc-regular" -- 11
local FONT_BODY_PATH = "assets/font/lxgw-neo-zhisong.ttf" -- 12
local FONT_CALLI_PATH = "assets/font/longcang-brush.ttf" -- 13
local DEFAULT_OUTLINE = Color(8, 10, 15, 200) -- 15
local ALL_BUCKETS = { -- 19
	"xs", -- 19
	"sm", -- 19
	"md", -- 19
	"lg", -- 19
	"xl", -- 19
	"seal", -- 19
	"sealLg", -- 19
	"banner", -- 19
	"title" -- 19
} -- 19
local BUCKET_SIZES = { -- 21
	xs = 15, -- 22
	sm = 18, -- 23
	md = 21, -- 24
	lg = 28, -- 25
	xl = 44, -- 26
	seal = 15, -- 27
	sealLg = 19, -- 28
	banner = 42, -- 29
	title = 68 -- 30
} -- 30
local BUCKET_CAPS = { -- 33
	xs = 44, -- 34
	sm = 44, -- 35
	md = 28, -- 36
	lg = 14, -- 37
	xl = 6, -- 38
	seal = 16, -- 39
	sealLg = 8, -- 40
	banner = 8, -- 41
	title = 10 -- 42
} -- 42
local CALLI_BUCKETS = { -- 45
	xs = false, -- 46
	sm = false, -- 47
	md = false, -- 48
	lg = false, -- 49
	xl = false, -- 50
	seal = true, -- 51
	sealLg = true, -- 52
	banner = true, -- 53
	title = true -- 54
} -- 54
local function resolveFont(useCalli) -- 57
	if useCalli and Content:exist(FONT_CALLI_PATH) then -- 57
		return FONT_CALLI_PATH -- 59
	end -- 59
	if Content:exist(FONT_BODY_PATH) then -- 59
		return FONT_BODY_PATH -- 62
	end -- 62
	return FONT_FALLBACK -- 64
end -- 57
____exports.TextPool = __TS__Class() -- 67
local TextPool = ____exports.TextPool -- 67
TextPool.name = "TextPool" -- 67
function TextPool.prototype.____constructor(self, parent, order, customCaps) -- 74
	self.activeBuckets = {} -- 70
	self.container = Node() -- 75
	self.container.order = order -- 76
	self.container:addTo(parent) -- 77
	self.pools = { -- 78
		xs = {}, -- 79
		sm = {}, -- 79
		md = {}, -- 79
		lg = {}, -- 79
		xl = {}, -- 79
		seal = {}, -- 80
		sealLg = {}, -- 80
		banner = {}, -- 80
		title = {} -- 80
	} -- 80
	self.used = { -- 82
		xs = 0, -- 83
		sm = 0, -- 83
		md = 0, -- 83
		lg = 0, -- 83
		xl = 0, -- 83
		seal = 0, -- 84
		sealLg = 0, -- 84
		banner = 0, -- 84
		title = 0 -- 84
	} -- 84
	local total = 0 -- 87
	local i = 0 -- 88
	do -- 88
		i = 0 -- 89
		while i < #ALL_BUCKETS do -- 89
			local bucket = ALL_BUCKETS[i + 1] -- 90
			local cap = customCaps ~= nil and (customCaps[bucket] or 0) or BUCKET_CAPS[bucket] -- 91
			if cap > 0 then -- 91
				local ____self_activeBuckets_0 = self.activeBuckets -- 91
				____self_activeBuckets_0[#____self_activeBuckets_0 + 1] = bucket -- 93
				total = total + self:allocBucket(bucket, cap) -- 94
			end -- 94
			i = i + 1 -- 89
		end -- 89
	end -- 89
	self.totalAllocated = total -- 97
end -- 74
function TextPool.prototype.allocBucket(self, bucket, cap) -- 100
	local size = BUCKET_SIZES[bucket] -- 101
	local font = resolveFont(CALLI_BUCKETS[bucket]) -- 102
	local list = self.pools[bucket] -- 103
	local created = 0 -- 104
	local i = 0 -- 105
	do -- 105
		i = 0 -- 106
		while i < cap do -- 106
			local lb = Label(font, size, true) -- 107
			if lb == nil and font ~= FONT_FALLBACK then -- 107
				lb = Label(FONT_FALLBACK, size, true) -- 109
			end -- 109
			if lb ~= nil then -- 109
				lb.outlineColor = DEFAULT_OUTLINE -- 112
				lb.outlineWidth = 0.13 -- 113
				lb.visible = false -- 114
				lb:addTo(self.container) -- 115
				list[#list + 1] = lb -- 116
				created = created + 1 -- 117
			end -- 117
			i = i + 1 -- 106
		end -- 106
	end -- 106
	return created -- 120
end -- 100
function TextPool.prototype.beginFrame(self) -- 123
	local i = 0 -- 124
	do -- 124
		i = 0 -- 125
		while i < #self.activeBuckets do -- 125
			self.used[self.activeBuckets[i + 1]] = 0 -- 126
			i = i + 1 -- 125
		end -- 125
	end -- 125
end -- 123
function TextPool.prototype.put(self, bucket, text, x, y, color, ax, ay, align, spacing, opacity, outlineWidth, outlineColor) -- 130
	if ax == nil then -- 130
		ax = 0 -- 136
	end -- 136
	if ay == nil then -- 136
		ay = 0.5 -- 137
	end -- 137
	if align == nil then -- 137
		align = "Left" -- 138
	end -- 138
	if spacing == nil then -- 138
		spacing = 0 -- 139
	end -- 139
	if opacity == nil then -- 139
		opacity = 1 -- 140
	end -- 140
	if outlineWidth == nil then -- 140
		outlineWidth = 0.13 -- 141
	end -- 141
	if text == "" then -- 141
		return -- 145
	end -- 145
	local list = self.pools[bucket] -- 147
	local idx = self.used[bucket] -- 148
	if idx >= #list then -- 148
		return -- 150
	end -- 150
	self.used[bucket] = idx + 1 -- 152
	local lb = list[idx + 1] -- 153
	lb.text = text -- 154
	lb.color = color -- 155
	lb.outlineWidth = outlineWidth -- 156
	if outlineColor ~= nil then -- 156
		lb.outlineColor = outlineColor -- 158
	elseif outlineWidth <= 0 then -- 158
		lb.outlineColor = Color(0, 0, 0, 0) -- 160
	else -- 160
		lb.outlineColor = DEFAULT_OUTLINE -- 162
	end -- 162
	lb.position = Vec2( -- 164
		math.floor(x + 0.5), -- 164
		math.floor(y + 0.5) -- 164
	) -- 164
	lb.anchor = Vec2(ax, ay) -- 165
	lb.alignment = align -- 166
	lb.spacing = spacing -- 167
	lb.opacity = math.max( -- 168
		0, -- 168
		math.min(1, opacity) -- 168
	) -- 168
	lb.visible = true -- 169
end -- 130
function TextPool.prototype.endFrame(self) -- 172
	local i = 0 -- 173
	do -- 173
		i = 0 -- 174
		while i < #self.activeBuckets do -- 174
			self:hideRest(self.activeBuckets[i + 1]) -- 175
			i = i + 1 -- 174
		end -- 174
	end -- 174
end -- 172
function TextPool.prototype.hideAll(self) -- 179
	self:beginFrame() -- 180
	self:endFrame() -- 181
end -- 179
function TextPool.prototype.hideRest(self, bucket) -- 184
	local list = self.pools[bucket] -- 185
	local i = self.used[bucket] -- 186
	do -- 186
		while i < #list do -- 186
			list[i + 1].visible = false -- 188
			i = i + 1 -- 187
		end -- 187
	end -- 187
end -- 184
return ____exports -- 184