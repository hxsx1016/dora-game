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
local FONT_BODY_PATH = "assets/font/lxgw-neo-zhisong.ttf" -- 11
local FONT_CALLI_PATH = "assets/font/longcang-brush.ttf" -- 12
local FONT_FALLBACK = FONT_BODY_PATH -- 13
local FONT_ENGINE_FALLBACK = "sarasa-mono-sc-regular" -- 14
local DEFAULT_OUTLINE = Color(8, 10, 15, 200) -- 16
local ALL_BUCKETS = { -- 20
	"xs", -- 20
	"sm", -- 20
	"md", -- 20
	"lg", -- 20
	"xl", -- 20
	"seal", -- 20
	"sealLg", -- 20
	"banner", -- 20
	"title" -- 20
} -- 20
local BUCKET_SIZES = { -- 22
	xs = 15, -- 23
	sm = 18, -- 24
	md = 21, -- 25
	lg = 28, -- 26
	xl = 44, -- 27
	seal = 15, -- 28
	sealLg = 19, -- 29
	banner = 42, -- 30
	title = 68 -- 31
} -- 31
local BUCKET_CAPS = { -- 34
	xs = 44, -- 35
	sm = 44, -- 36
	md = 28, -- 37
	lg = 14, -- 38
	xl = 6, -- 39
	seal = 16, -- 40
	sealLg = 8, -- 41
	banner = 8, -- 42
	title = 10 -- 43
} -- 43
local CALLI_BUCKETS = { -- 46
	xs = false, -- 47
	sm = false, -- 48
	md = false, -- 49
	lg = false, -- 50
	xl = false, -- 51
	seal = true, -- 52
	sealLg = true, -- 53
	banner = true, -- 54
	title = true -- 55
} -- 55
local function resolveFont(useCalli) -- 58
	if useCalli and Content:exist(FONT_CALLI_PATH) then -- 58
		return FONT_CALLI_PATH -- 60
	end -- 60
	if Content:exist(FONT_BODY_PATH) then -- 60
		return FONT_BODY_PATH -- 63
	end -- 63
	return FONT_ENGINE_FALLBACK -- 65
end -- 58
____exports.TextPool = __TS__Class() -- 68
local TextPool = ____exports.TextPool -- 68
TextPool.name = "TextPool" -- 68
function TextPool.prototype.____constructor(self, parent, order, customCaps) -- 75
	self.activeBuckets = {} -- 71
	self.container = Node() -- 76
	self.container.order = order -- 77
	self.container:addTo(parent) -- 78
	self.pools = { -- 79
		xs = {}, -- 80
		sm = {}, -- 80
		md = {}, -- 80
		lg = {}, -- 80
		xl = {}, -- 80
		seal = {}, -- 81
		sealLg = {}, -- 81
		banner = {}, -- 81
		title = {} -- 81
	} -- 81
	self.used = { -- 83
		xs = 0, -- 84
		sm = 0, -- 84
		md = 0, -- 84
		lg = 0, -- 84
		xl = 0, -- 84
		seal = 0, -- 85
		sealLg = 0, -- 85
		banner = 0, -- 85
		title = 0 -- 85
	} -- 85
	local total = 0 -- 88
	local i = 0 -- 89
	do -- 89
		i = 0 -- 90
		while i < #ALL_BUCKETS do -- 90
			local bucket = ALL_BUCKETS[i + 1] -- 91
			local cap = customCaps ~= nil and (customCaps[bucket] or 0) or BUCKET_CAPS[bucket] -- 92
			if cap > 0 then -- 92
				local ____self_activeBuckets_0 = self.activeBuckets -- 92
				____self_activeBuckets_0[#____self_activeBuckets_0 + 1] = bucket -- 94
				total = total + self:allocBucket(bucket, cap) -- 95
			end -- 95
			i = i + 1 -- 90
		end -- 90
	end -- 90
	self.totalAllocated = total -- 98
end -- 75
function TextPool.prototype.allocBucket(self, bucket, cap) -- 101
	local size = BUCKET_SIZES[bucket] -- 102
	local font = resolveFont(CALLI_BUCKETS[bucket]) -- 103
	local list = self.pools[bucket] -- 104
	local created = 0 -- 105
	local i = 0 -- 106
	do -- 106
		i = 0 -- 107
		while i < cap do -- 107
			local lb = Label(font, size, true) -- 108
			if lb == nil and font ~= FONT_FALLBACK then -- 108
				lb = Label(FONT_FALLBACK, size, true) -- 110
			end -- 110
			if lb ~= nil then -- 110
				lb.outlineColor = DEFAULT_OUTLINE -- 113
				lb.outlineWidth = 0.13 -- 114
				lb.visible = false -- 115
				lb:addTo(self.container) -- 116
				list[#list + 1] = lb -- 117
				created = created + 1 -- 118
			end -- 118
			i = i + 1 -- 107
		end -- 107
	end -- 107
	return created -- 121
end -- 101
function TextPool.prototype.beginFrame(self) -- 124
	local i = 0 -- 125
	do -- 125
		i = 0 -- 126
		while i < #self.activeBuckets do -- 126
			self.used[self.activeBuckets[i + 1]] = 0 -- 127
			i = i + 1 -- 126
		end -- 126
	end -- 126
end -- 124
function TextPool.prototype.put(self, bucket, text, x, y, color, ax, ay, align, spacing, opacity, outlineWidth, outlineColor) -- 131
	if ax == nil then -- 131
		ax = 0 -- 137
	end -- 137
	if ay == nil then -- 137
		ay = 0.5 -- 138
	end -- 138
	if align == nil then -- 138
		align = "Left" -- 139
	end -- 139
	if spacing == nil then -- 139
		spacing = 0 -- 140
	end -- 140
	if opacity == nil then -- 140
		opacity = 1 -- 141
	end -- 141
	if outlineWidth == nil then -- 141
		outlineWidth = 0.13 -- 142
	end -- 142
	if text == "" then -- 142
		return -- 146
	end -- 146
	local list = self.pools[bucket] -- 148
	local idx = self.used[bucket] -- 149
	if idx >= #list then -- 149
		return -- 151
	end -- 151
	self.used[bucket] = idx + 1 -- 153
	local lb = list[idx + 1] -- 154
	lb.text = text -- 155
	lb.color = color -- 156
	lb.outlineWidth = outlineWidth -- 157
	if outlineColor ~= nil then -- 157
		lb.outlineColor = outlineColor -- 159
	elseif outlineWidth <= 0 then -- 159
		lb.outlineColor = Color(0, 0, 0, 0) -- 161
	else -- 161
		lb.outlineColor = DEFAULT_OUTLINE -- 163
	end -- 163
	lb.position = Vec2( -- 165
		math.floor(x + 0.5), -- 165
		math.floor(y + 0.5) -- 165
	) -- 165
	lb.anchor = Vec2(ax, ay) -- 166
	lb.alignment = align -- 167
	lb.spacing = spacing -- 168
	lb.opacity = math.max( -- 169
		0, -- 169
		math.min(1, opacity) -- 169
	) -- 169
	lb.visible = true -- 170
end -- 131
function TextPool.prototype.endFrame(self) -- 173
	local i = 0 -- 174
	do -- 174
		i = 0 -- 175
		while i < #self.activeBuckets do -- 175
			self:hideRest(self.activeBuckets[i + 1]) -- 176
			i = i + 1 -- 175
		end -- 175
	end -- 175
end -- 173
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