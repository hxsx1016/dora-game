-- [ts]: init.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local scene = Node() -- 5
scene:addTo(Director.entry) -- 6
local art = DrawNode() -- 7
art:addTo(scene) -- 8
local width = View.size.width -- 10
local height = View.size.height -- 11
local halfW = width / 2 -- 12
local halfH = height / 2 -- 13
art:drawPolygon( -- 16
	{ -- 16
		Vec2(-halfW, -halfH), -- 16
		Vec2(halfW, -halfH), -- 16
		Vec2(halfW, halfH), -- 16
		Vec2(-halfW, halfH) -- 16
	}, -- 16
	Color(9, 15, 39, 255) -- 16
) -- 16
art:drawCircle( -- 17
	Vec2(halfW * 0.52, halfH * 0.48), -- 17
	43, -- 17
	Color(255, 236, 184, 255) -- 17
) -- 17
art:drawCircle( -- 18
	Vec2(halfW * 0.52 - 12, halfH * 0.48 + 10), -- 18
	43, -- 18
	Color(9, 15, 39, 255) -- 18
) -- 18
art:drawPolygon( -- 21
	{ -- 21
		Vec2(-halfW, -halfH * 0.12), -- 22
		Vec2(-halfW * 0.72, halfH * 0.3), -- 22
		Vec2(-halfW * 0.48, halfH * 0.02), -- 23
		Vec2(-halfW * 0.18, halfH * 0.42), -- 23
		Vec2(halfW * 0.08, halfH * 0.04), -- 24
		Vec2(halfW * 0.38, halfH * 0.34), -- 24
		Vec2(halfW * 0.68, -halfH * 0.01), -- 25
		Vec2(halfW, halfH * 0.22), -- 25
		Vec2(halfW, -halfH), -- 26
		Vec2(-halfW, -halfH) -- 26
	}, -- 26
	Color(28, 43, 76, 255) -- 27
) -- 27
art:drawPolygon( -- 28
	{ -- 28
		Vec2(-halfW, -halfH * 0.3), -- 29
		Vec2(-halfW * 0.66, halfH * 0.04), -- 29
		Vec2(-halfW * 0.36, -halfH * 0.2), -- 30
		Vec2(-halfW * 0.08, halfH * 0.12), -- 30
		Vec2(halfW * 0.2, -halfH * 0.18), -- 31
		Vec2(halfW * 0.55, halfH * 0.08), -- 31
		Vec2(halfW, -halfH * 0.24), -- 32
		Vec2(halfW, -halfH), -- 32
		Vec2(-halfW, -halfH) -- 32
	}, -- 32
	Color(17, 31, 59, 255) -- 33
) -- 33
art:drawPolygon( -- 36
	{ -- 36
		Vec2(-halfW, -halfH), -- 36
		Vec2(halfW, -halfH), -- 36
		Vec2(halfW, -halfH * 0.3), -- 36
		Vec2(-halfW, -halfH * 0.3) -- 36
	}, -- 36
	Color(12, 31, 55, 255) -- 36
) -- 36
art:drawSegment( -- 37
	Vec2(halfW * 0.3, -halfH * 0.42), -- 37
	Vec2(halfW * 0.76, -halfH * 0.42), -- 37
	1.5, -- 37
	Color(223, 194, 135, 120) -- 37
) -- 37
art:drawSegment( -- 38
	Vec2(halfW * 0.38, -halfH * 0.5), -- 38
	Vec2(halfW * 0.68, -halfH * 0.5), -- 38
	1, -- 38
	Color(223, 194, 135, 90) -- 38
) -- 38
art:drawSegment( -- 39
	Vec2(halfW * 0.25, -halfH * 0.58), -- 39
	Vec2(halfW * 0.79, -halfH * 0.58), -- 39
	1, -- 39
	Color(223, 194, 135, 65) -- 39
) -- 39
local title = Label("sarasa-mono-sc-regular", 26) -- 41
if title then -- 41
	title.text = "月下山谷" -- 43
	title.position = Vec2(-halfW + 34, halfH - 48) -- 44
	title.anchor = Vec2(0, 0.5) -- 45
	title.color = Color(244, 226, 190, 255) -- 46
	title:addTo(scene) -- 47
end -- 47
local caption = Label("sarasa-mono-sc-regular", 14) -- 49
if caption then -- 49
	caption.text = "MOONLIT VALLEY  ·  静听夜色" -- 51
	caption.position = Vec2(-halfW + 36, halfH - 73) -- 52
	caption.anchor = Vec2(0, 0.5) -- 53
	caption.color = Color(160, 180, 204, 255) -- 54
	caption:addTo(scene) -- 55
end -- 55
local fireflies = { -- 59
	{x = -0.72, y = -0.16, phase = 0.2}, -- 60
	{x = -0.3, y = -0.35, phase = 1.7}, -- 61
	{x = 0.04, y = -0.22, phase = 3.1}, -- 62
	{x = 0.7, y = -0.34, phase = 4.4}, -- 63
	{x = -0.84, y = 0.02, phase = 5.2} -- 64
} -- 64
local lights = DrawNode() -- 66
lights:addTo(scene) -- 67
local elapsed = 0 -- 68
local dialog -- 69
local hint = Label("sarasa-mono-sc-regular", 14) -- 71
if hint then -- 71
	hint.text = "Esc · 退出菜单" -- 73
	hint.position = Vec2(halfW - 28, -halfH + 28) -- 74
	hint.anchor = Vec2(1, 0.5) -- 75
	hint.color = Color(190, 204, 220, 255) -- 76
	hint:addTo(scene) -- 77
end -- 77
local function closeDialog() -- 80
	if dialog then -- 80
		dialog:removeFromParent() -- 82
		dialog = nil -- 83
	end -- 83
end -- 80
local function openDialog() -- 87
	if dialog then -- 87
		return -- 88
	end -- 88
	local overlay = Node() -- 89
	overlay:addTo(Director.ui) -- 90
	dialog = overlay -- 91
	local w = View.size.width -- 92
	local h = View.size.height -- 93
	local scale = math.min(1, w / 480, h / 320) -- 95
	local shade = DrawNode() -- 96
	shade:drawPolygon( -- 97
		{ -- 97
			Vec2(-w / 2, -h / 2), -- 98
			Vec2(w / 2, -h / 2), -- 98
			Vec2(w / 2, h / 2), -- 99
			Vec2(-w / 2, h / 2) -- 99
		}, -- 99
		Color(3, 8, 20, 200) -- 100
	) -- 100
	shade:addTo(overlay) -- 101
	local panel = Node() -- 102
	panel.scaleX = scale -- 103
	panel.scaleY = scale -- 104
	panel:addTo(overlay) -- 105
	local frame = DrawNode() -- 106
	frame:drawPolygon( -- 107
		{ -- 107
			Vec2(-216, -116), -- 108
			Vec2(216, -116), -- 108
			Vec2(216, 116), -- 108
			Vec2(-216, 116) -- 108
		}, -- 108
		Color(22, 36, 62, 255), -- 109
		1, -- 109
		Color(113, 132, 160, 255) -- 109
	) -- 109
	frame:drawSegment( -- 110
		Vec2(-184, 82), -- 110
		Vec2(-148, 82), -- 110
		2, -- 110
		Color(244, 218, 161, 255) -- 110
	) -- 110
	frame:addTo(panel) -- 111
	local function text(value, size, y, color) -- 112
		local label = Label("sarasa-mono-sc-regular", size) -- 113
		if not label then -- 113
			return -- 114
		end -- 114
		label.text = value -- 115
		label.y = y -- 116
		label.color = color -- 117
		label:addTo(panel) -- 118
	end -- 112
	text( -- 120
		"要离开月下山谷吗？", -- 120
		24, -- 120
		44, -- 120
		Color(248, 233, 204, 255) -- 120
	) -- 120
	text( -- 121
		"选择退出将结束当前游戏。", -- 121
		16, -- 121
		8, -- 121
		Color(179, 196, 216, 255) -- 121
	) -- 121
	local function button(value, x, primary, action) -- 122
		local hit = Node() -- 123
		hit.width = 168 -- 124
		hit.height = 44 -- 125
		hit.position = Vec2(x, -60) -- 126
		hit.swallowTouches = true -- 127
		hit:addTo(panel) -- 128
		local face = DrawNode() -- 129
		face:addTo(hit) -- 130
		local function paint(pressed) -- 131
			face:clear() -- 132
			local fill = primary and (pressed and Color(203, 177, 121, 255) or Color(244, 218, 161, 255)) or (pressed and Color(54, 75, 104, 255) or Color(35, 52, 79, 255)) -- 133
			face:drawPolygon( -- 136
				{ -- 136
					Vec2(0, 0), -- 136
					Vec2(168, 0), -- 136
					Vec2(168, 44), -- 136
					Vec2(0, 44) -- 136
				}, -- 136
				fill -- 136
			) -- 136
		end -- 131
		paint(false) -- 138
		local label = Label("sarasa-mono-sc-regular", 17) -- 139
		if label then -- 139
			label.text = value -- 141
			label.position = Vec2(84, 22) -- 142
			label.color = primary and Color(22, 36, 62, 255) or Color(227, 235, 246, 255) -- 143
			label:addTo(hit) -- 144
		end -- 144
		hit:onTapBegan(function() return paint(true) end) -- 146
		hit:onTapEnded(function() return paint(false) end) -- 147
		hit:onTapped(function() return action() end) -- 148
	end -- 122
	button("继续游戏", -92, false, closeDialog) -- 150
	button( -- 151
		"退出游戏", -- 151
		92, -- 151
		true, -- 151
		function() return App:shutdown() end -- 151
	) -- 151
end -- 87
scene:onKeyDown(function(key) -- 154
	if key == "Escape" then -- 154
		if dialog then -- 154
			closeDialog() -- 156
		else -- 156
			openDialog() -- 157
		end -- 157
	end -- 157
end) -- 154
scene:onCleanup(closeDialog) -- 160
scene:schedule(function(dt) -- 162
	if dialog then -- 162
		return false -- 163
	end -- 163
	elapsed = elapsed + dt -- 164
	lights:clear() -- 165
	for ____, fly in ipairs(fireflies) do -- 166
		local x = fly.x * halfW + math.sin(elapsed * 0.7 + fly.phase) * 12 -- 167
		local y = fly.y * halfH + math.sin(elapsed * 1.1 + fly.phase) * 8 -- 168
		local pulse = 0.55 + 0.45 * math.sin(elapsed * 2 + fly.phase) -- 169
		lights:drawCircle( -- 170
			Vec2(x, y), -- 170
			3 + pulse * 2, -- 170
			Color( -- 170
				255, -- 170
				218, -- 170
				112, -- 170
				math.floor(100 + pulse * 130) -- 170
			) -- 170
		) -- 170
		lights:drawCircle( -- 171
			Vec2(x, y), -- 171
			1.5, -- 171
			Color(255, 244, 180, 255) -- 171
		) -- 171
	end -- 171
	return false -- 173
end) -- 162
return ____exports -- 162