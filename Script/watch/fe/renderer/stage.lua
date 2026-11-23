-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____theme = require("Script.watch.fe.theme") -- 8
local PALETTE = ____theme.PALETTE -- 9
local fillChamferBox = ____theme.fillChamferBox -- 12
local fillRadialGlow = ____theme.fillRadialGlow -- 14
local fillVGradRect = ____theme.fillVGradRect -- 15
local themeOf = ____theme.themeOf -- 17
local toColor = ____theme.toColor -- 18
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 22
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 23
	return x - math.floor(x) -- 24
end -- 22
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 28
	local h = 17 -- 29
	local i = 0 -- 30
	do -- 30
		i = 0 -- 31
		while i < #key do -- 31
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 32
			i = i + 1 -- 31
		end -- 31
	end -- 31
	return h -- 34
end -- 28
____exports.StageRenderer = __TS__Class() -- 37
local StageRenderer = ____exports.StageRenderer -- 37
StageRenderer.name = "StageRenderer" -- 37
function StageRenderer.prototype.____constructor(self) -- 37
end -- 37
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 39
	local w = cam.viewW -- 47
	local h = cam.viewH -- 48
	local theme = themeOf(p.room.key) -- 49
	local seed = roomSeed(p.room.key) -- 50
	local span = math.max(1, p.room.maxX - p.room.minX) -- 52
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 53
	local farSlot = "bgFar_" .. p.room.key -- 54
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 55
	local artH = artW * 9 / 16 -- 56
	if assets:tryPlace( -- 56
		farSlot, -- 57
		"scene", -- 57
		w * (0.5 - progress * 0.09), -- 57
		(h - artH) * 0.5, -- 57
		artW, -- 57
		artH -- 57
	) then -- 57
		self:drawDressing(assets, p, cam, progress) -- 58
		local y = cam.groundScreenY -- 59
		fillVGradRect( -- 60
			bgDraw, -- 60
			0, -- 60
			0, -- 60
			w, -- 60
			h, -- 60
			toColor(PALETTE.voidDark), -- 60
			toColor(theme.skyMid) -- 60
		) -- 60
		fillVGradRect( -- 61
			bgGlow, -- 61
			0, -- 61
			y - 1, -- 61
			w, -- 61
			h * 0.14, -- 61
			Color(43, 49, 63, 15), -- 61
			Color(43, 49, 63, 0) -- 61
		) -- 61
		return -- 62
	end -- 62
	local splitY = h * 0.46 -- 66
	fillVGradRect( -- 67
		bgDraw, -- 67
		0, -- 67
		splitY, -- 67
		w, -- 67
		h - splitY, -- 67
		toColor(theme.skyMid), -- 67
		toColor(theme.skyTop) -- 67
	) -- 67
	fillVGradRect( -- 68
		bgDraw, -- 68
		0, -- 68
		0, -- 68
		w, -- 68
		splitY, -- 68
		toColor(theme.skyHorizon), -- 68
		toColor(theme.skyMid) -- 68
	) -- 68
	if theme.showMoon then -- 68
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 72
		local my = h * theme.moonYFrac -- 73
		local mr = math.max(18, h * 0.044) -- 74
		fillRadialGlow( -- 75
			bgGlow, -- 75
			mx, -- 75
			my, -- 75
			mr * 6.2, -- 75
			mr * 6.2, -- 75
			Color(140, 200, 255, 28), -- 75
			Color(20, 40, 80, 0), -- 75
			22 -- 75
		) -- 75
		fillRadialGlow( -- 76
			bgGlow, -- 76
			mx, -- 76
			my, -- 76
			mr * 2.4, -- 76
			mr * 2.4, -- 76
			Color(200, 232, 255, 64), -- 76
			Color(80, 140, 210, 0), -- 76
			18 -- 76
		) -- 76
		bgDraw:drawCircle( -- 77
			Vec2(mx, my), -- 77
			mr, -- 77
			Color(224, 238, 252, 230) -- 77
		) -- 77
		bgDraw:drawCircle( -- 79
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 79
			mr * 0.84, -- 79
			toColor(theme.skyTop, 110) -- 79
		) -- 79
	end -- 79
	if p.room.key == "forest" then -- 79
		self:drawFarForest( -- 83
			bgDraw, -- 83
			w, -- 83
			h, -- 83
			cam, -- 83
			theme, -- 83
			seed -- 83
		) -- 83
		self:drawMidForest( -- 84
			bgDraw, -- 84
			bgGlow, -- 84
			w, -- 84
			h, -- 84
			cam, -- 84
			theme, -- 84
			time, -- 84
			seed -- 84
		) -- 84
	else -- 84
		self:drawFarCity( -- 86
			bgDraw, -- 86
			bgGlow, -- 86
			w, -- 86
			h, -- 86
			cam, -- 86
			theme, -- 86
			seed -- 86
		) -- 86
		self:drawMidArchitecture( -- 87
			bgDraw, -- 87
			bgGlow, -- 87
			w, -- 87
			h, -- 87
			cam, -- 87
			theme, -- 87
			time, -- 87
			seed -- 87
		) -- 87
	end -- 87
	if theme.showSearchlights then -- 87
		self:drawSearchlights( -- 90
			bgGlow, -- 90
			w, -- 90
			h, -- 90
			cam, -- 90
			theme, -- 90
			time, -- 90
			seed -- 90
		) -- 90
	end -- 90
	if theme.showTowerBeacon then -- 90
		self:drawDistantNorthTower( -- 93
			bgDraw, -- 93
			bgGlow, -- 93
			w, -- 93
			h, -- 93
			cam, -- 93
			p, -- 93
			time -- 93
		) -- 93
	end -- 93
	local fogH = h * 0.38 -- 97
	fillVGradRect( -- 98
		bgGlow, -- 99
		0, -- 100
		cam.groundScreenY - 10, -- 101
		w, -- 102
		fogH, -- 103
		toColor(theme.fogBottom), -- 104
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 105
	) -- 105
end -- 39
function StageRenderer.prototype.drawDressing(self, assets, p, cam, progress) -- 109
	local w = cam.viewW -- 110
	local ground = cam.groundScreenY -- 111
	local x = w * (0.75 - progress * 0.29) -- 112
	if p.room.key == "forest" or p.room.key == "outside" or p.room.key == "tower" then -- 112
		assets:tryPlace( -- 114
			"pine", -- 114
			"mid_pine", -- 114
			x, -- 114
			ground - cam:len(12), -- 114
			cam:len(124), -- 114
			cam:len(138), -- 114
			{layer = 1, opacity = 0.52} -- 115
		) -- 115
	elseif p.room.key == "prologue" or p.room.key == "village" or p.room.key == "checkpoint" then -- 115
		assets:tryPlace( -- 117
			"eaves", -- 117
			"mid_eaves", -- 117
			x, -- 117
			ground - cam:len(8), -- 117
			cam:len(186), -- 117
			cam:len(104), -- 117
			{layer = 1, opacity = 0.46} -- 118
		) -- 118
	else -- 118
		assets:tryPlace( -- 120
			"cover_stone", -- 120
			"mid_ruin", -- 120
			x, -- 120
			ground - cam:len(8), -- 120
			cam:len(140), -- 120
			cam:len(48), -- 120
			{layer = 1, opacity = 0.46} -- 121
		) -- 121
	end -- 121
	if p.room.key == "street" or p.room.key == "checkpoint" or p.room.key == "prologue" then -- 121
		assets:tryPlace( -- 124
			"prop_lantern", -- 124
			"mid_lantern", -- 124
			w * (0.27 - progress * 0.21), -- 124
			ground + cam:len(92), -- 125
			cam:len(22), -- 125
			cam:len(30), -- 125
			{layer = 2, opacity = 0.82} -- 125
		) -- 125
	end -- 125
end -- 109
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 130
	local theme = themeOf("checkpoint") -- 137
	local splitY = h * 0.44 -- 138
	fillVGradRect( -- 139
		bgDraw, -- 139
		0, -- 139
		splitY, -- 139
		w, -- 139
		h - splitY, -- 139
		toColor(theme.skyMid), -- 139
		toColor(theme.skyTop) -- 139
	) -- 139
	fillVGradRect( -- 140
		bgDraw, -- 140
		0, -- 140
		0, -- 140
		w, -- 140
		splitY, -- 140
		toColor(theme.skyHorizon), -- 140
		toColor(theme.skyMid) -- 140
	) -- 140
	local mx = w * 0.61 -- 143
	local my = h * 0.74 -- 144
	local mr = h * 0.082 -- 145
	fillRadialGlow( -- 146
		bgGlow, -- 146
		mx, -- 146
		my, -- 146
		mr * 5.2, -- 146
		mr * 5.2, -- 146
		Color(86, 210, 255, 34), -- 146
		Color(10, 24, 52, 0), -- 146
		24 -- 146
	) -- 146
	fillRadialGlow( -- 147
		bgGlow, -- 147
		mx, -- 147
		my, -- 147
		mr * 2.1, -- 147
		mr * 2.1, -- 147
		Color(190, 240, 255, 76), -- 147
		Color(40, 120, 190, 0), -- 147
		20 -- 147
	) -- 147
	bgDraw:drawCircle( -- 148
		Vec2(mx, my), -- 148
		mr, -- 148
		Color(228, 242, 255, 235) -- 148
	) -- 148
	bgDraw:drawCircle( -- 149
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 149
		mr * 0.86, -- 149
		Color(10, 18, 34, 125) -- 149
	) -- 149
	local s = 0 -- 152
	do -- 152
		s = 0 -- 153
		while s < 3 do -- 153
			local bx = w * (0.36 + s * 0.24) -- 154
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 155
			local ang = math.pi * 0.5 + sway - 0.12 -- 156
			local len = h * 1.15 -- 157
			local spread = 0.085 + s * 0.015 -- 158
			local x1 = bx + math.cos(ang - spread) * len -- 159
			local y1 = math.sin(ang - spread) * len -- 160
			local x2 = bx + math.cos(ang + spread) * len -- 161
			local y2 = math.sin(ang + spread) * len -- 162
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 163
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 164
			bgGlow:drawVertices({ -- 165
				{ -- 166
					Vec2(bx, h * 0.15), -- 166
					baseCol -- 166
				}, -- 166
				{ -- 167
					Vec2(x1, y1), -- 167
					tipCol -- 167
				}, -- 167
				{ -- 168
					Vec2(x2, y2), -- 168
					tipCol -- 168
				} -- 168
			}) -- 168
			s = s + 1 -- 153
		end -- 153
	end -- 153
	local groundY = h * 0.19 -- 173
	local i = 0 -- 174
	do -- 174
		i = 0 -- 175
		while i < 16 do -- 175
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 176
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 177
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 178
			local cut = 12 + hash01(i * 19) * 20 -- 179
			bgDraw:drawPolygon( -- 180
				{ -- 180
					Vec2(bx, groundY), -- 181
					Vec2(bx + bw, groundY), -- 182
					Vec2(bx + bw, groundY + bh - cut), -- 183
					Vec2(bx + bw - cut, groundY + bh), -- 184
					Vec2(bx, groundY + bh) -- 185
				}, -- 185
				Color(10, 16, 28, 255) -- 186
			) -- 186
			if hash01(i * 41 + 5) > 0.45 then -- 186
				local wy = groundY + bh * 0.65 -- 189
				bgGlow:drawSegment( -- 190
					Vec2(bx + 10, wy), -- 190
					Vec2(bx + bw - 14, wy), -- 190
					1.2, -- 190
					Color(72, 224, 255, 95) -- 190
				) -- 190
			end -- 190
			i = i + 1 -- 175
		end -- 175
	end -- 175
	local tx = w * 0.83 -- 195
	local ty0 = groundY -- 196
	local ty1 = h * 0.62 -- 197
	bgDraw:drawPolygon( -- 198
		{ -- 198
			Vec2(tx - 26, ty0), -- 199
			Vec2(tx + 26, ty0), -- 200
			Vec2(tx + 11, ty1), -- 201
			Vec2(tx - 11, ty1) -- 202
		}, -- 202
		Color(15, 24, 40, 255), -- 203
		1.2, -- 203
		Color(58, 86, 118, 140) -- 203
	) -- 203
	bgDraw:drawSegment( -- 204
		Vec2(tx, ty0 + 24), -- 204
		Vec2(tx, ty1 - 12), -- 204
		1.4, -- 204
		Color(242, 188, 96, 85) -- 204
	) -- 204
	bgDraw:drawSegment( -- 205
		Vec2(tx, ty1), -- 205
		Vec2(tx, ty1 + 42), -- 205
		2.2, -- 205
		Color(165, 212, 248, 210) -- 205
	) -- 205
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 206
	fillRadialGlow( -- 207
		bgGlow, -- 207
		tx, -- 207
		ty1 + 42, -- 207
		74 * pulse, -- 207
		74 * pulse, -- 207
		Color(255, 222, 146, 130), -- 207
		Color(255, 180, 90, 0), -- 207
		20 -- 207
	) -- 207
	bgGlow:drawDot( -- 208
		Vec2(tx, ty1 + 42), -- 208
		5, -- 208
		Color(255, 248, 224, 255) -- 208
	) -- 208
	fillVGradRect( -- 211
		bgDraw, -- 211
		0, -- 211
		0, -- 211
		w, -- 211
		groundY, -- 211
		Color(6, 9, 16, 255), -- 211
		Color(16, 24, 38, 255) -- 211
	) -- 211
	bgDraw:drawSegment( -- 212
		Vec2(0, groundY), -- 212
		Vec2(w, groundY), -- 212
		2, -- 212
		Color(76, 220, 255, 180) -- 212
	) -- 212
	fillVGradRect( -- 213
		bgGlow, -- 213
		0, -- 213
		groundY, -- 213
		w, -- 213
		h * 0.24, -- 213
		Color(42, 130, 182, 52), -- 213
		Color(20, 60, 100, 0) -- 213
	) -- 213
	local sx = w * 0.64 -- 216
	fillRadialGlow( -- 217
		bgGlow, -- 217
		sx + 38, -- 217
		groundY + 75, -- 217
		128, -- 217
		92, -- 217
		Color(52, 178, 232, 42), -- 217
		Color(20, 60, 110, 0), -- 217
		18 -- 217
	) -- 217
	bgDraw:drawPolygon( -- 219
		{ -- 219
			Vec2(sx - 36, groundY + 12), -- 220
			Vec2(sx + 10, groundY + 18), -- 221
			Vec2(sx + 16, groundY + 124), -- 222
			Vec2(sx - 18, groundY + 124) -- 223
		}, -- 223
		Color(10, 16, 28, 255), -- 224
		1.3, -- 224
		Color(76, 210, 255, 145) -- 224
	) -- 224
	bgDraw:drawSegment( -- 225
		Vec2(sx - 6, groundY + 48), -- 225
		Vec2(sx - 12, groundY + 2), -- 225
		6, -- 225
		Color(10, 16, 28, 255) -- 225
	) -- 225
	bgDraw:drawSegment( -- 226
		Vec2(sx + 6, groundY + 48), -- 226
		Vec2(sx + 14, groundY + 2), -- 226
		6, -- 226
		Color(14, 22, 36, 255) -- 226
	) -- 226
	bgDraw:drawPolygon( -- 227
		{ -- 227
			Vec2(sx - 20, groundY + 120), -- 228
			Vec2(sx + 20, groundY + 122), -- 229
			Vec2(sx + 16, groundY + 132), -- 230
			Vec2(sx - 16, groundY + 130) -- 231
		}, -- 231
		Color(208, 236, 252, 240) -- 232
	) -- 232
	bgDraw:drawCircle( -- 233
		Vec2(sx + 2, groundY + 146), -- 233
		13, -- 233
		Color(14, 22, 36, 255) -- 233
	) -- 233
	bgDraw:drawArc( -- 234
		Vec2(sx + 2, groundY + 146), -- 234
		13.5, -- 234
		30, -- 234
		165, -- 234
		2, -- 234
		Color(216, 240, 255, 230) -- 234
	) -- 234
	bgGlow:drawSegment( -- 235
		Vec2(sx + 4, groundY + 148), -- 235
		Vec2(sx + 17, groundY + 150), -- 235
		2.6, -- 235
		Color(86, 240, 255, 255) -- 235
	) -- 235
	bgDraw:drawSegment( -- 236
		Vec2(sx + 4, groundY + 104), -- 236
		Vec2(sx + 46, groundY + 94), -- 236
		3.4, -- 236
		Color(34, 52, 74, 255) -- 236
	) -- 236
	bgGlow:drawSegment( -- 237
		Vec2(sx + 16, groundY + 102), -- 237
		Vec2(sx + 44, groundY + 95), -- 237
		1.2, -- 237
		Color(86, 236, 255, 200) -- 237
	) -- 237
	local cx = w * 0.725 -- 240
	bgDraw:drawPolygon( -- 241
		{ -- 241
			Vec2(cx - 20, groundY + 14), -- 242
			Vec2(cx + 18, groundY + 14), -- 243
			Vec2(cx + 12, groundY + 84), -- 244
			Vec2(cx - 12, groundY + 84) -- 245
		}, -- 245
		Color(188, 142, 78, 238), -- 246
		1.4, -- 246
		Color(252, 232, 192, 225) -- 246
	) -- 246
	bgDraw:drawSegment( -- 247
		Vec2(cx - 5, groundY + 24), -- 247
		Vec2(cx - 6, groundY + 2), -- 247
		4.2, -- 247
		Color(28, 24, 30, 255) -- 247
	) -- 247
	bgDraw:drawSegment( -- 248
		Vec2(cx + 5, groundY + 24), -- 248
		Vec2(cx + 6, groundY + 2), -- 248
		4.2, -- 248
		Color(38, 32, 38, 255) -- 248
	) -- 248
	bgDraw:drawCircle( -- 249
		Vec2(cx + 1, groundY + 95), -- 249
		11, -- 249
		Color(238, 220, 194, 250) -- 249
	) -- 249
	bgDraw:drawPolygon( -- 250
		{ -- 250
			Vec2(cx - 15, groundY + 84), -- 251
			Vec2(cx - 10, groundY + 108), -- 252
			Vec2(cx + 6, groundY + 107), -- 253
			Vec2(cx - 4, groundY + 84) -- 254
		}, -- 254
		Color(156, 114, 62, 245) -- 255
	) -- 255
	bgGlow:drawSegment( -- 256
		Vec2(cx - 8, groundY + 82), -- 256
		Vec2(cx - 30, groundY + 64), -- 256
		2.8, -- 256
		Color(252, 230, 178, 220) -- 256
	) -- 256
	fillRadialGlow( -- 257
		bgGlow, -- 257
		cx + 10, -- 257
		groundY + 56, -- 257
		30, -- 257
		30, -- 257
		Color(255, 214, 130, 115), -- 257
		Color(250, 180, 70, 0), -- 257
		16 -- 257
	) -- 257
	bgGlow:drawDot( -- 258
		Vec2(cx + 10, groundY + 56), -- 258
		3.2, -- 258
		Color(255, 246, 220, 255) -- 258
	) -- 258
end -- 130
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time) -- 262
	local theme = themeOf(p.room.key) -- 270
	self:drawFloors( -- 271
		fgDraw, -- 271
		assets, -- 271
		p, -- 271
		cam, -- 271
		theme -- 271
	) -- 271
	self:drawStairs( -- 272
		fgDraw, -- 272
		fgGlow, -- 272
		assets, -- 272
		p, -- 272
		cam, -- 272
		theme -- 272
	) -- 272
	self:drawSolids( -- 273
		fgDraw, -- 273
		fgGlow, -- 273
		assets, -- 273
		p, -- 273
		cam, -- 273
		theme, -- 273
		time -- 273
	) -- 273
	if p.room.key == "gate" then -- 273
		self:drawGateShutter( -- 275
			fgDraw, -- 275
			fgGlow, -- 275
			assets, -- 275
			p, -- 275
			cam, -- 275
			time -- 275
		) -- 275
	end -- 275
	self:drawArch( -- 277
		fgDraw, -- 277
		fgGlow, -- 277
		p, -- 277
		cam, -- 277
		theme -- 277
	) -- 277
end -- 262
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 281
	local seed = roomSeed(p.room.key) -- 288
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 290
	local span = 520 -- 291
	local startIdx = math.floor((-parallax - 200) / span) -- 292
	local idx = startIdx -- 293
	do -- 293
		idx = startIdx -- 294
		while idx <= startIdx + 4 do -- 294
			local x = idx * span + parallax -- 295
			local r = hash01(seed + idx * 17) -- 296
			local bw = 70 + r * 90 -- 297
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 298
			fgDraw:drawPolygon( -- 299
				{ -- 299
					Vec2(x, 0), -- 300
					Vec2(x + bw, 0), -- 301
					Vec2(x + bw - 18, bh), -- 302
					Vec2(x + 12, bh * 0.72) -- 303
				}, -- 303
				Color(4, 6, 11, 225) -- 304
			) -- 304
			idx = idx + 1 -- 294
		end -- 294
	end -- 294
	fillVGradRect( -- 308
		fgDraw, -- 308
		0, -- 308
		h - h * 0.16, -- 308
		w, -- 308
		h * 0.16, -- 308
		Color(4, 6, 12, 0), -- 308
		Color(4, 6, 12, 138) -- 308
	) -- 308
	fillVGradRect( -- 309
		fgDraw, -- 309
		0, -- 309
		0, -- 309
		w, -- 309
		h * 0.13, -- 309
		Color(4, 6, 12, 185), -- 309
		Color(4, 6, 12, 0) -- 309
	) -- 309
end -- 281
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 312
	local count = 3 -- 321
	local i = 0 -- 322
	do -- 322
		i = 0 -- 323
		while i < count do -- 323
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 324
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 325
			local by = cam.groundScreenY * 0.85 -- 326
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 327
			local ang = math.pi * 0.5 + sway -- 328
			local len = h * 1.15 -- 329
			local halfSpread = 0.065 + i % 2 * 0.025 -- 330
			local x1 = bx + math.cos(ang - halfSpread) * len -- 331
			local y1 = by + math.sin(ang - halfSpread) * len -- 332
			local x2 = bx + math.cos(ang + halfSpread) * len -- 333
			local y2 = by + math.sin(ang + halfSpread) * len -- 334
			local c0 = toColor(theme.beamColor) -- 335
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 336
			bgGlow:drawVertices({ -- 337
				{ -- 338
					Vec2(bx, by), -- 338
					c0 -- 338
				}, -- 338
				{ -- 339
					Vec2(x1, y1), -- 339
					c1 -- 339
				}, -- 339
				{ -- 340
					Vec2(x2, y2), -- 340
					c1 -- 340
				} -- 340
			}) -- 340
			i = i + 1 -- 323
		end -- 323
	end -- 323
end -- 312
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 345
	local baseY = cam.groundScreenY - 8 -- 354
	local shift = -cam.x * 0.2 * cam.ppu -- 355
	local colW = 108 -- 356
	local first = math.floor((-shift - colW) / colW) -- 357
	local count = math.ceil(w / colW) + 3 -- 358
	local i = 0 -- 359
	do -- 359
		i = 0 -- 360
		while i < count do -- 360
			local idx = first + i -- 361
			local r1 = hash01(seed + idx * 13.7) -- 362
			local r2 = hash01(seed + idx * 29.3) -- 363
			local r3 = hash01(seed + idx * 47.1) -- 364
			local x = idx * colW + shift -- 365
			local bw = colW * (0.68 + r1 * 0.44) -- 366
			local bh = h * (0.18 + r2 * 0.38) -- 367
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 368
			bgDraw:drawPolygon( -- 370
				{ -- 370
					Vec2(x, baseY), -- 371
					Vec2(x + bw, baseY), -- 372
					Vec2(x + bw, baseY + bh - cut), -- 373
					Vec2(x + bw - cut, baseY + bh), -- 374
					Vec2(x, baseY + bh) -- 375
				}, -- 375
				toColor(theme.farBuilding) -- 376
			) -- 376
			if r3 > 0.62 then -- 376
				local ax = x + bw * 0.25 -- 380
				bgDraw:drawSegment( -- 381
					Vec2(ax, baseY + bh), -- 381
					Vec2(ax, baseY + bh + 32), -- 381
					1.2, -- 381
					toColor(theme.farBuilding) -- 381
				) -- 381
				if r1 > 0.6 then -- 381
					bgGlow:drawDot( -- 383
						Vec2(ax, baseY + bh + 32), -- 383
						2.2, -- 383
						toColor(theme.accent, 145) -- 383
					) -- 383
				end -- 383
			end -- 383
			if r2 > 0.55 then -- 383
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 388
				bgGlow:drawSegment( -- 389
					Vec2(x + 12, wy), -- 389
					Vec2(x + bw - 14, wy), -- 389
					1.1, -- 389
					toColor(theme.accent, 64) -- 389
				) -- 389
			end -- 389
			i = i + 1 -- 360
		end -- 360
	end -- 360
end -- 345
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 394
	local baseY = cam.groundScreenY - 8 -- 402
	local shift = -cam.x * 0.22 * cam.ppu -- 403
	local step = 76 -- 404
	local first = math.floor((-shift - step) / step) -- 405
	local count = math.ceil(w / step) + 4 -- 406
	local i = 0 -- 407
	do -- 407
		i = 0 -- 408
		while i < count do -- 408
			local idx = first + i -- 409
			local r1 = hash01(seed + idx * 11.3) -- 410
			local r2 = hash01(seed + idx * 23.9) -- 411
			local cx = idx * step + shift -- 412
			local tw = 34 + r1 * 38 -- 413
			local th = h * (0.24 + r2 * 0.34) -- 414
			bgDraw:drawPolygon( -- 416
				{ -- 416
					Vec2(cx - tw, baseY), -- 417
					Vec2(cx + tw, baseY), -- 418
					Vec2(cx, baseY + th) -- 419
				}, -- 419
				toColor(theme.farBuilding) -- 420
			) -- 420
			bgDraw:drawPolygon( -- 421
				{ -- 421
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 422
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 423
					Vec2(cx, baseY + th * 1.12) -- 424
				}, -- 424
				toColor(theme.farBuilding) -- 425
			) -- 425
			i = i + 1 -- 408
		end -- 408
	end -- 408
end -- 394
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 429
	local baseY = cam.groundScreenY - 4 -- 439
	local shift = -cam.x * 0.48 * cam.ppu -- 440
	local bay = 240 -- 441
	local first = math.floor((-shift - bay) / bay) -- 442
	local count = math.ceil(w / bay) + 3 -- 443
	local col = toColor(theme.midBuilding) -- 444
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 445
	local i = 0 -- 447
	do -- 447
		i = 0 -- 448
		while i < count do -- 448
			local idx = first + i -- 449
			local r = hash01(seed + idx * 37.3) -- 450
			local x = idx * bay + shift -- 451
			local colH = h * (0.34 + r * 0.24) -- 452
			local pw = 22 + r * 16 -- 453
			bgDraw:drawRect( -- 456
				Rect(x, baseY, pw, colH), -- 456
				col -- 456
			) -- 456
			bgDraw:drawSegment( -- 457
				Vec2(x + pw, baseY), -- 457
				Vec2(x + pw, baseY + colH), -- 457
				1, -- 457
				edge -- 457
			) -- 457
			if r > 0.35 then -- 457
				local beamY = baseY + colH * 0.76 -- 459
				bgDraw:drawSegment( -- 460
					Vec2(x + pw, beamY), -- 460
					Vec2(x + bay, beamY), -- 460
					4, -- 460
					col -- 460
				) -- 460
				bgDraw:drawSegment( -- 461
					Vec2(x + pw, beamY - 22), -- 461
					Vec2(x + bay * 0.5, beamY), -- 461
					1.4, -- 461
					edge -- 461
				) -- 461
				bgDraw:drawSegment( -- 462
					Vec2(x + bay * 0.5, beamY), -- 462
					Vec2(x + bay, beamY - 22), -- 462
					1.4, -- 462
					edge -- 462
				) -- 462
			end -- 462
			bgDraw:drawQuadraticBezier( -- 466
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 467
				Vec2( -- 468
					x + bay * 0.5, -- 468
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 468
				), -- 468
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 469
				1, -- 470
				Color(12, 18, 28, 180) -- 471
			) -- 471
			if idx & 1 == 0 then -- 471
				local lx = x + bay * 0.52 -- 476
				local ly = baseY + h * 0.31 -- 477
				bgDraw:drawSegment( -- 478
					Vec2(lx, baseY), -- 478
					Vec2(lx, ly), -- 478
					2.2, -- 478
					col -- 478
				) -- 478
				bgDraw:drawSegment( -- 479
					Vec2(lx, ly), -- 479
					Vec2(lx + 18, ly - 4), -- 479
					2, -- 479
					col -- 479
				) -- 479
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 480
				local lc = theme.accent -- 481
				bgGlow:drawDot( -- 482
					Vec2(lx + 18, ly - 5), -- 482
					3.2, -- 482
					toColor(lc, 210 * flicker) -- 482
				) -- 482
				fillRadialGlow( -- 483
					bgGlow, -- 483
					lx + 18, -- 483
					ly - 5, -- 483
					36, -- 483
					36, -- 483
					toColor(lc, 54 * flicker), -- 483
					Color(lc.r, lc.g, lc.b, 0), -- 483
					14 -- 483
				) -- 483
				bgGlow:drawVertices({ -- 484
					{ -- 485
						Vec2(lx + 18, ly - 6), -- 485
						toColor(lc, 38 * flicker) -- 485
					}, -- 485
					{ -- 486
						Vec2(lx - 42, baseY), -- 486
						Color(lc.r, lc.g, lc.b, 0) -- 486
					}, -- 486
					{ -- 487
						Vec2(lx + 78, baseY), -- 487
						Color(lc.r, lc.g, lc.b, 0) -- 487
					} -- 487
				}) -- 487
			end -- 487
			i = i + 1 -- 448
		end -- 448
	end -- 448
end -- 429
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 493
	local baseY = cam.groundScreenY - 4 -- 503
	local shift = -cam.x * 0.52 * cam.ppu -- 504
	local span = 156 -- 505
	local first = math.floor((-shift - span) / span) -- 506
	local count = math.ceil(w / span) + 3 -- 507
	local col = toColor(theme.midBuilding) -- 508
	local i = 0 -- 510
	do -- 510
		i = 0 -- 511
		while i < count do -- 511
			local idx = first + i -- 512
			local r = hash01(seed + idx * 19.7) -- 513
			local x = idx * span + shift -- 514
			local trunkW = 14 + r * 14 -- 515
			local sway = math.sin(time * 0.9 + idx) * 4 -- 516
			bgDraw:drawPolygon( -- 517
				{ -- 517
					Vec2(x - trunkW * 0.5, baseY), -- 518
					Vec2(x + trunkW * 0.5, baseY), -- 519
					Vec2(x + trunkW * 0.25 + sway, h), -- 520
					Vec2(x - trunkW * 0.3 + sway, h) -- 521
				}, -- 521
				col -- 522
			) -- 522
			if idx % 3 == 0 then -- 522
				bgGlow:drawVertices({ -- 525
					{ -- 526
						Vec2(x + 40, h), -- 526
						Color(110, 232, 200, 26) -- 526
					}, -- 526
					{ -- 527
						Vec2(x + 115, h), -- 527
						Color(110, 232, 200, 0) -- 527
					}, -- 527
					{ -- 528
						Vec2(x - 60, baseY), -- 528
						Color(110, 232, 200, 0) -- 528
					} -- 528
				}) -- 528
			end -- 528
			i = i + 1 -- 511
		end -- 511
	end -- 511
end -- 493
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 534
	local scale = 0.55 -- 544
	if p.room.key == "village" then -- 544
		scale = 0.72 -- 546
	elseif p.room.key == "forest" then -- 546
		scale = 0.92 -- 548
	elseif p.room.key == "tower" then -- 548
		scale = 1.15 -- 550
	end -- 550
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 552
	local baseY = cam.groundScreenY - 8 -- 553
	local towerH = h * 0.42 * scale -- 554
	local bw = 20 * scale -- 555
	bgDraw:drawPolygon( -- 556
		{ -- 556
			Vec2(tx - bw, baseY), -- 557
			Vec2(tx + bw, baseY), -- 558
			Vec2(tx + bw * 0.45, baseY + towerH), -- 559
			Vec2(tx - bw * 0.45, baseY + towerH) -- 560
		}, -- 560
		Color(14, 24, 38, 240) -- 561
	) -- 561
	bgDraw:drawSegment( -- 562
		Vec2(tx, baseY + towerH), -- 562
		Vec2(tx, baseY + towerH + 28 * scale), -- 562
		1.8, -- 562
		Color(180, 210, 238, 200) -- 562
	) -- 562
	local topY = baseY + towerH + 24 * scale -- 564
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 565
	fillRadialGlow( -- 566
		bgGlow, -- 566
		tx, -- 566
		topY, -- 566
		56 * scale * pulse, -- 566
		56 * scale * pulse, -- 566
		Color(255, 224, 152, 118), -- 566
		Color(255, 190, 96, 0), -- 566
		18 -- 566
	) -- 566
	bgGlow:drawDot( -- 567
		Vec2(tx, topY), -- 567
		3.6 * scale, -- 567
		Color(255, 246, 220, 255) -- 567
	) -- 567
end -- 534
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 570
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 577
	do -- 577
		local i = 0 -- 578
		while i < #p.room.floors do -- 578
			local floor = p.room.floors[i + 1] -- 579
			local left = cam:sx(floor.x0) -- 580
			local right = cam:sx(floor.x1) -- 581
			local top = cam:sy(floor.y) -- 582
			local isMain = floor.y <= 0.1 -- 583
			local height = cam:len(isMain and 22 or 12) -- 584
			local bottom = top - height -- 585
			if isMain and bottom > 0 then -- 585
				fillVGradRect( -- 587
					fgDraw, -- 587
					left, -- 587
					0, -- 587
					right - left, -- 587
					bottom + 1, -- 587
					toColor(PALETTE.voidDark), -- 588
					toColor(theme.groundBody) -- 588
				) -- 588
			end -- 588
			fgDraw:drawRect( -- 590
				Rect(left, bottom, right - left, height), -- 590
				toColor(PALETTE.steelDark) -- 590
			) -- 590
			local step = cam:len(96) -- 591
			local start = math.max( -- 592
				0, -- 592
				math.floor(-left / step) -- 592
			) -- 592
			do -- 592
				local j = start -- 593
				while left + j * step < math.min(right, cam.viewW) do -- 593
					local x = left + j * step -- 594
					local width = math.min(step, right - x) -- 595
					assets:tryPlace( -- 596
						"slab", -- 596
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 596
						x + width * 0.5, -- 596
						bottom, -- 596
						width, -- 596
						height -- 596
					) -- 596
					if grass and isMain and j % 3 == 1 then -- 596
						assets:tryPlace( -- 598
							"grass_low", -- 598
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 598
							x + width * 0.5, -- 598
							top - cam:len(3), -- 599
							width * 0.74, -- 599
							cam:len(13), -- 599
							{opacity = 0.83, layer = 1} -- 599
						) -- 599
					end -- 599
					j = j + 1 -- 593
				end -- 593
			end -- 593
			fgDraw:drawSegment( -- 602
				Vec2(left, top), -- 602
				Vec2(right, top), -- 602
				1, -- 602
				toColor(theme.groundRim, 140) -- 602
			) -- 602
			i = i + 1 -- 578
		end -- 578
	end -- 578
end -- 570
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 606
	local i = 0 -- 614
	do -- 614
		i = 0 -- 615
		while i < #p.room.stairs do -- 615
			local st = p.room.stairs[i + 1] -- 616
			local n = st.steps + 1 -- 617
			local stepW = (st.x1 - st.x0) / n -- 618
			local k = 0 -- 619
			do -- 619
				k = 0 -- 620
				while k < n do -- 620
					local wy = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 621
					local wx0 = st.x0 + stepW * k -- 622
					local wx1 = wx0 + stepW -- 623
					local x0 = cam:sx(wx0) -- 624
					local x1 = cam:sx(wx1) -- 625
					local y1 = cam:sy(wy) -- 626
					local y0 = cam:sy(math.max(0, st.y0)) -- 627
					if y1 > y0 + 2 then -- 627
						fgDraw:drawRect( -- 629
							Rect(x0, y0, x1 - x0, y1 - y0), -- 629
							toColor(PALETTE.steelDark, 230) -- 629
						) -- 629
						fgDraw:drawRect( -- 630
							Rect(x0, y1 - 5, x1 - x0, 5), -- 630
							toColor(theme.groundTop) -- 630
						) -- 630
						assets:tryPlace( -- 631
							"wall", -- 631
							(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 631
							(x0 + x1) * 0.5, -- 631
							y0, -- 631
							x1 - x0, -- 632
							y1 - y0, -- 632
							{opacity = 0.78} -- 632
						) -- 632
						assets:tryPlace( -- 633
							"slab", -- 633
							(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 633
							(x0 + x1) * 0.5, -- 633
							y1 - cam:len(5), -- 633
							x1 - x0, -- 634
							cam:len(5), -- 634
							{layer = 1} -- 634
						) -- 634
					end -- 634
					fgDraw:drawSegment( -- 636
						Vec2(x0, y1), -- 636
						Vec2(x1, y1), -- 636
						1.8, -- 636
						toColor(theme.groundRim) -- 636
					) -- 636
					fgGlow:drawSegment( -- 637
						Vec2(x0, y1 + 1), -- 637
						Vec2(x1, y1 + 1), -- 637
						1, -- 637
						toColor(theme.accent, 55) -- 637
					) -- 637
					k = k + 1 -- 620
				end -- 620
			end -- 620
			i = i + 1 -- 615
		end -- 615
	end -- 615
end -- 606
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time) -- 642
	local i = 0 -- 651
	do -- 651
		i = 0 -- 652
		while i < #p.room.solids do -- 652
			do -- 652
				local s = p.room.solids[i + 1] -- 653
				local x0 = cam:sx(s.x) -- 654
				local x1 = cam:sx(s.x + s.w) -- 655
				local y0 = cam:sy(s.y) -- 656
				local y1 = cam:sy(s.y + s.h) -- 657
				local sw = x1 - x0 -- 658
				local sh = y1 - y0 -- 659
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 659
					goto __continue70 -- 661
				end -- 661
				if s.passable == true then -- 661
					if not assets:tryPlace( -- 661
						"grass", -- 666
						"hide_grass_" .. tostring(i), -- 666
						(x0 + x1) * 0.5, -- 666
						y0, -- 666
						sw, -- 666
						sh * 1.55, -- 666
						{opacity = 0.79, layer = 7} -- 667
					) then -- 667
						self:drawGrassCluster( -- 668
							fgDraw, -- 668
							fgGlow, -- 668
							x0, -- 668
							y0, -- 668
							sw, -- 668
							sh, -- 668
							p.player.x, -- 668
							s.x + s.w * 0.5, -- 668
							time -- 668
						) -- 668
					end -- 668
					goto __continue70 -- 670
				end -- 670
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 670
					self:drawWinch( -- 675
						fgDraw, -- 675
						fgGlow, -- 675
						x0, -- 675
						y0, -- 675
						sw, -- 675
						sh, -- 675
						p, -- 675
						time -- 675
					) -- 675
					assets:tryPlace( -- 676
						"prop_winch", -- 676
						"gate_winch", -- 676
						(x0 + x1) * 0.5, -- 676
						y0 + sh * 0.55, -- 676
						sw, -- 676
						sh * 0.78, -- 676
						{layer = 2} -- 677
					) -- 677
					goto __continue70 -- 678
				end -- 678
				if p.room.key == "tower" then -- 678
					self:drawTowerStructure( -- 683
						fgDraw, -- 683
						fgGlow, -- 683
						assets, -- 683
						x0, -- 683
						y0, -- 683
						sw, -- 683
						sh, -- 683
						s, -- 683
						p, -- 683
						time -- 683
					) -- 683
					goto __continue70 -- 684
				end -- 684
				if s.h <= 64 and s.y <= 2 then -- 684
					self:drawCoverBlock( -- 689
						fgDraw, -- 689
						fgGlow, -- 689
						assets, -- 689
						x0, -- 689
						y0, -- 689
						sw, -- 689
						sh, -- 689
						s, -- 689
						p, -- 689
						theme -- 689
					) -- 689
					goto __continue70 -- 690
				end -- 690
				fillVGradRect( -- 693
					fgDraw, -- 693
					x0, -- 693
					y0, -- 693
					sw, -- 693
					sh, -- 693
					toColor(PALETTE.steelDark), -- 693
					toColor(PALETTE.steelMid) -- 693
				) -- 693
				self:tileMasonry( -- 694
					assets, -- 694
					s, -- 694
					x0, -- 694
					y0, -- 694
					sw, -- 694
					sh -- 694
				) -- 694
			end -- 694
			::__continue70:: -- 694
			i = i + 1 -- 652
		end -- 652
	end -- 652
end -- 642
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 698
	local columns = math.max( -- 702
		1, -- 702
		math.ceil(s.w / 154) -- 702
	) -- 702
	local rows = math.max( -- 703
		1, -- 703
		math.ceil(s.h / 100) -- 703
	) -- 703
	local tileW = width / columns -- 704
	local tileH = height / rows -- 705
	do -- 705
		local row = 0 -- 706
		while row < rows do -- 706
			do -- 706
				local column = 0 -- 707
				while column < columns do -- 707
					assets:tryPlace( -- 708
						"wall", -- 708
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 708
						x + (column + 0.5) * tileW, -- 709
						y + row * tileH, -- 709
						tileW + 0.5, -- 709
						tileH + 0.5, -- 709
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 710
					) -- 710
					column = column + 1 -- 707
				end -- 707
			end -- 707
			row = row + 1 -- 706
		end -- 706
	end -- 706
end -- 698
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 715
	local slot = (string.find(s.label, "队栏", nil, true) or 0) - 1 >= 0 and "fence" or (((string.find(s.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(s.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone") -- 722
	if not assets:tryPlace( -- 722
		slot, -- 724
		"cover_" .. tostring(s.x), -- 724
		x0 + sw * 0.5, -- 724
		y0, -- 724
		sw, -- 724
		sh, -- 724
		{layer = 1} -- 724
	) then -- 724
		fillVGradRect( -- 725
			fgDraw, -- 725
			x0, -- 725
			y0, -- 725
			sw, -- 725
			sh, -- 725
			toColor(PALETTE.steelDark), -- 725
			toColor(PALETTE.steelMid) -- 725
		) -- 725
		fgDraw:drawSegment( -- 726
			Vec2(x0, y0 + sh), -- 726
			Vec2(x0 + sw, y0 + sh), -- 726
			1.4, -- 726
			toColor(theme.groundRim) -- 726
		) -- 726
	end -- 726
	if not p.childMode and (p.coverHug or p.coverNear) then -- 726
		local plx = p.player.x -- 731
		local nearLeft = math.abs(plx - s.x) < 42 -- 732
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 733
		if nearLeft or nearRight then -- 733
			local edgeX = nearLeft and x0 - 2 or x0 + sw + 2 -- 735
			local col = p.coverHug and PALETTE.cyan or PALETTE.amber -- 736
			fgGlow:drawSegment( -- 737
				Vec2(edgeX, y0 + 4), -- 737
				Vec2(edgeX, y0 + sh + 4), -- 737
				p.coverHug and 3.5 or 2, -- 737
				toColor(col, p.coverHug and 220 or 140) -- 737
			) -- 737
			if p.coverHug then -- 737
				fillRadialGlow( -- 739
					fgGlow, -- 739
					edgeX, -- 739
					y0 + sh * 0.55, -- 739
					22, -- 739
					sh * 0.7, -- 739
					toColor(PALETTE.cyan, 85), -- 739
					Color(72, 224, 255, 0), -- 739
					14 -- 739
				) -- 739
			end -- 739
		end -- 739
	end -- 739
end -- 715
function StageRenderer.prototype.drawWinch(self, fgDraw, fgGlow, x0, y0, sw, sh, p, time) -- 745
	fillChamferBox( -- 751
		fgDraw, -- 751
		x0, -- 751
		y0, -- 751
		sw, -- 751
		sh, -- 751
		8, -- 751
		toColor(PALETTE.steelMid), -- 751
		1.5, -- 751
		toColor(PALETTE.rimSilver, 180) -- 751
	) -- 751
	local cx = x0 + sw * 0.5 -- 753
	local cy = y0 + sh * 0.55 -- 754
	local r = math.min(sw, sh) * 0.34 -- 755
	local spin = p.phase == "gate-hold" and time * 1.4 or 0 -- 756
	fgDraw:drawRing( -- 757
		Vec2(cx, cy), -- 757
		r * 0.62, -- 757
		r, -- 757
		toColor(PALETTE.steelDark), -- 757
		1.5, -- 757
		toColor(PALETTE.rimSilver, 210) -- 757
	) -- 757
	local k = 0 -- 758
	do -- 758
		k = 0 -- 759
		while k < 6 do -- 759
			local a = spin + k * math.pi / 3 -- 760
			fgDraw:drawSegment( -- 761
				Vec2( -- 762
					cx + math.cos(a) * r * 0.25, -- 762
					cy + math.sin(a) * r * 0.25 -- 762
				), -- 762
				Vec2( -- 763
					cx + math.cos(a) * r * 1.05, -- 763
					cy + math.sin(a) * r * 1.05 -- 763
				), -- 763
				2, -- 764
				toColor(PALETTE.rimSilver, 210) -- 765
			) -- 765
			k = k + 1 -- 759
		end -- 759
	end -- 759
	fgDraw:drawSegment( -- 769
		Vec2(cx, cy + r), -- 769
		Vec2(cx, y0 + sh + 220), -- 769
		1.6, -- 769
		toColor(PALETTE.steelLight, 175) -- 769
	) -- 769
	local active = p.phase == "gate-hold" or p.phase == "gate-send" -- 771
	local lampCol = active and PALETTE.cyan or PALETTE.amber -- 772
	local pulse = 0.7 + 0.3 * math.sin(time * 5) -- 773
	fgGlow:drawDot( -- 774
		Vec2(x0 + sw - 10, y0 + sh - 10), -- 774
		4, -- 774
		toColor(lampCol, 240 * pulse) -- 774
	) -- 774
	fillRadialGlow( -- 775
		fgGlow, -- 775
		x0 + sw - 10, -- 775
		y0 + sh - 10, -- 775
		22, -- 775
		22, -- 775
		toColor(lampCol, 95 * pulse), -- 775
		Color(lampCol.r, lampCol.g, lampCol.b, 0), -- 775
		12 -- 775
	) -- 775
end -- 745
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 778
	local ____temp_0 -- 786
	if p.room.story ~= nil then -- 786
		____temp_0 = p.room.story.gate -- 786
	else -- 786
		____temp_0 = nil -- 786
	end -- 786
	local g = ____temp_0 -- 786
	if g == nil then -- 786
		return -- 788
	end -- 788
	local closeFrac = 0.08 -- 791
	if p.phase == "gate-hold" then -- 791
		closeFrac = 0.08 + 0.36 * math.min( -- 793
			1, -- 793
			p.gateTick / math.max(1, g.holdTicks) -- 793
		) -- 793
	elseif p.phase == "gate-send" then -- 793
		closeFrac = 0.44 -- 795
	elseif p.phase == "gate-count" then -- 795
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 797
	elseif p.phase == "gate-walk" then -- 797
		closeFrac = 1 -- 799
	end -- 799
	local gx0 = cam:sx(848) -- 801
	local gx1 = cam:sx(1032) -- 802
	local topY = cam:sy(160) -- 803
	local botY = cam:sy(160 * (1 - closeFrac)) -- 804
	if topY > botY + 2 then -- 804
		fillVGradRect( -- 806
			fgDraw, -- 806
			gx0, -- 806
			botY, -- 806
			gx1 - gx0, -- 806
			topY - botY, -- 806
			toColor(PALETTE.steelDark), -- 806
			toColor(PALETTE.steelMid) -- 806
		) -- 806
		assets:tryPlace( -- 807
			"cover_wood", -- 807
			"gate_shutter", -- 807
			(gx0 + gx1) * 0.5, -- 807
			botY, -- 807
			gx1 - gx0, -- 808
			topY - botY, -- 808
			{layer = 6} -- 808
		) -- 808
	end -- 808
	if closeFrac < 0.98 then -- 808
		local gapH = math.max( -- 812
			8, -- 812
			botY - cam:sy(0) -- 812
		) -- 812
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 813
		fillVGradRect( -- 814
			fgGlow, -- 814
			gx0, -- 814
			cam:sy(0), -- 814
			gx1 - gx0, -- 814
			gapH, -- 814
			Color( -- 814
				140, -- 814
				210, -- 814
				255, -- 814
				math.floor(52 * pulse + 0.5) -- 814
			), -- 814
			Color(80, 160, 230, 0) -- 814
		) -- 814
	end -- 814
end -- 778
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, time) -- 818
	fillVGradRect( -- 825
		fgDraw, -- 825
		x0, -- 825
		y0, -- 825
		sw, -- 825
		sh, -- 825
		Color(15, 21, 34, 255), -- 825
		Color(32, 44, 66, 255) -- 825
	) -- 825
	fgDraw:drawRect( -- 826
		Rect(x0, y0, sw, sh), -- 826
		Color(0, 0, 0, 0), -- 826
		1.4, -- 826
		toColor(PALETTE.rimSilver, 165) -- 826
	) -- 826
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 826
		self:tileMasonry( -- 829
			assets, -- 829
			s, -- 829
			x0, -- 829
			y0, -- 829
			sw, -- 829
			sh -- 829
		) -- 829
		local ribs = 4 -- 831
		local r = 1 -- 832
		do -- 832
			r = 1 -- 833
			while r < ribs do -- 833
				local rx = x0 + sw * r / ribs -- 834
				fgDraw:drawSegment( -- 835
					Vec2(rx, y0), -- 835
					Vec2(rx, y0 + sh), -- 835
					2, -- 835
					Color(10, 15, 24, 210) -- 835
				) -- 835
				fgDraw:drawSegment( -- 836
					Vec2(rx + 2, y0), -- 836
					Vec2(rx + 2, y0 + sh), -- 836
					1, -- 836
					Color(68, 86, 114, 130) -- 836
				) -- 836
				r = r + 1 -- 833
			end -- 833
		end -- 833
		local bands = 4 -- 839
		local b = 1 -- 840
		do -- 840
			b = 1 -- 841
			while b < bands do -- 841
				local by = y0 + sh * b / bands -- 842
				fgDraw:drawSegment( -- 843
					Vec2(x0 + 4, by), -- 843
					Vec2(x0 + sw - 4, by), -- 843
					1.2, -- 843
					Color(52, 68, 92, 135) -- 843
				) -- 843
				b = b + 1 -- 841
			end -- 841
		end -- 841
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 846
		local slitY = y0 + sh * 0.56 -- 847
		local slitH = sh * 0.22 -- 848
		fgDraw:drawRect( -- 849
			Rect(slitX - 5, slitY, 10, slitH), -- 849
			Color(8, 12, 20, 245), -- 849
			1.2, -- 849
			toColor(PALETTE.amberDim, 190) -- 849
		) -- 849
		fgGlow:drawRect( -- 850
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 850
			toColor(PALETTE.amber, 190) -- 850
		) -- 850
		fillRadialGlow( -- 851
			fgGlow, -- 851
			slitX, -- 851
			slitY + slitH * 0.5, -- 851
			44, -- 851
			slitH * 0.7, -- 851
			Color(255, 206, 128, 52), -- 851
			Color(255, 180, 86, 0), -- 851
			14 -- 851
		) -- 851
	end -- 851
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 851
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 856
		local cx = x0 + sw * 0.5 -- 857
		local lampY = y0 - 8 -- 858
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 859
		if not opened then -- 859
			assets:tryPlace( -- 861
				"prop_tower_door", -- 861
				"tower_door", -- 861
				cx, -- 861
				y0 - doorHeight, -- 861
				sw, -- 861
				doorHeight, -- 861
				{layer = 2} -- 861
			) -- 861
		end -- 861
		assets:tryPlace( -- 863
			"prop_lantern", -- 863
			"tower_lantern", -- 863
			cx + sw * 0.43, -- 863
			lampY - sh * 0.36, -- 863
			sw * 0.17, -- 864
			sh * 0.84, -- 864
			{layer = 3} -- 864
		) -- 864
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 865
		local alpha = opened and 155 or 88 -- 866
		fgDraw:drawSegment( -- 868
			Vec2(x0 + 4, y0), -- 868
			Vec2(x0 + 4, y0 - sh * 3.8), -- 868
			4, -- 868
			Color(42, 52, 70, 255) -- 868
		) -- 868
		fgDraw:drawSegment( -- 869
			Vec2(x0 + sw - 4, y0), -- 869
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 869
			4, -- 869
			Color(42, 52, 70, 255) -- 869
		) -- 869
		fgDraw:drawSegment( -- 870
			Vec2(x0, y0), -- 870
			Vec2(x0 + sw, y0), -- 870
			2.5, -- 870
			toColor(PALETTE.amber, 210) -- 870
		) -- 870
		fillVGradRect( -- 872
			fgGlow, -- 873
			x0 + 6, -- 874
			y0 - sh * 3.8, -- 875
			sw - 12, -- 876
			sh * 3.8, -- 877
			Color( -- 878
				255, -- 878
				206, -- 878
				128, -- 878
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 878
			), -- 878
			Color(255, 224, 168, opened and 180 or 62) -- 879
		) -- 879
		fillRadialGlow( -- 881
			fgGlow, -- 881
			cx, -- 881
			lampY, -- 881
			opened and 105 or 58, -- 881
			opened and 105 or 58, -- 881
			Color( -- 881
				255, -- 881
				232, -- 881
				178, -- 881
				math.floor(170 * pulse + 0.5) -- 881
			), -- 881
			Color(255, 180, 86, 0), -- 881
			18 -- 881
		) -- 881
		fgDraw:drawCircle( -- 882
			Vec2(cx, lampY), -- 882
			5.5, -- 882
			toColor(PALETTE.amberCore) -- 882
		) -- 882
	end -- 882
end -- 818
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 886
	local blades = math.max( -- 893
		12, -- 893
		math.floor(sw / 8) -- 893
	) -- 893
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 894
	local k = 0 -- 895
	do -- 895
		k = 0 -- 896
		while k < blades do -- 896
			local t = (k + 0.5) / blades -- 897
			local bx = x0 + sw * t -- 898
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 899
			local bh = sh * hRatio * 1.95 -- 900
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 901
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 902
			fgDraw:drawPolygon( -- 903
				{ -- 903
					Vec2(bx - 7, y0), -- 904
					Vec2(bx + 7, y0), -- 905
					Vec2(bx + sway, y0 + bh) -- 906
				}, -- 906
				col -- 907
			) -- 907
			k = k + 1 -- 896
		end -- 896
	end -- 896
	if nearPlayer then -- 896
		fgGlow:drawSegment( -- 910
			Vec2(x0, y0 + 2), -- 910
			Vec2(x0 + sw, y0 + 2), -- 910
			2, -- 910
			toColor(PALETTE.emerald, 145) -- 910
		) -- 910
	end -- 910
end -- 886
function StageRenderer.prototype.drawArch(self, fgDraw, fgGlow, p, cam, theme) -- 914
	local a = p.room.arch -- 921
	if a.h <= 0 or a.x1 <= a.x0 then -- 921
		return -- 923
	end -- 923
	local x0 = cam:sx(a.x0) -- 925
	local x1 = cam:sx(a.x1) -- 926
	local y0 = cam:sy(a.y) -- 927
	local y1 = cam:sy(a.y + a.h) -- 928
	local aw = x1 - x0 -- 929
	local ah = y1 - y0 -- 930
	fgDraw:drawRect( -- 933
		Rect(x0, y0, aw, ah), -- 933
		Color(5, 7, 11, 245) -- 933
	) -- 933
	fgDraw:drawSegment( -- 935
		Vec2(x0, y0), -- 935
		Vec2(x0, y1), -- 935
		3, -- 935
		toColor(PALETTE.rimSilver, 215) -- 935
	) -- 935
	fgDraw:drawSegment( -- 936
		Vec2(x1, y0), -- 936
		Vec2(x1, y1), -- 936
		3, -- 936
		toColor(PALETTE.rimSilver, 215) -- 936
	) -- 936
	fgDraw:drawSegment( -- 937
		Vec2(x0 - 4, y1), -- 937
		Vec2(x1 + 4, y1), -- 937
		3.2, -- 937
		toColor(PALETTE.rimSilver, 235) -- 937
	) -- 937
	if p.room.key == "outside" then -- 937
		local arcR = math.min(aw * 0.46, ah * 0.72) -- 940
		fgDraw:drawArc( -- 941
			Vec2((x0 + x1) * 0.5, y1 - arcR - 2), -- 941
			arcR, -- 941
			0, -- 941
			180, -- 941
			2.2, -- 941
			toColor(theme.accent, 195) -- 941
		) -- 941
		fillVGradRect( -- 942
			fgGlow, -- 942
			x0 + 6, -- 942
			y0, -- 942
			aw - 12, -- 942
			ah * 0.65, -- 942
			Color(86, 186, 236, 52), -- 942
			Color(86, 186, 236, 0) -- 942
		) -- 942
	end -- 942
end -- 914
return ____exports -- 914