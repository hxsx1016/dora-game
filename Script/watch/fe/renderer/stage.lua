-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____occlusion = require("Script.watch.fe.occlusion") -- 8
local depthOrder = ____occlusion.depthOrder -- 8
local ____theme = require("Script.watch.fe.theme") -- 9
local PALETTE = ____theme.PALETTE -- 10
local fillChamferBox = ____theme.fillChamferBox -- 13
local fillRadialGlow = ____theme.fillRadialGlow -- 15
local fillVGradRect = ____theme.fillVGradRect -- 16
local lerpRGBA = ____theme.lerpRGBA -- 17
local themeOf = ____theme.themeOf -- 18
local toColor = ____theme.toColor -- 19
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 23
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 24
	return x - math.floor(x) -- 25
end -- 23
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 29
	local h = 17 -- 30
	local i = 0 -- 31
	do -- 31
		i = 0 -- 32
		while i < #key do -- 32
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 33
			i = i + 1 -- 32
		end -- 32
	end -- 32
	return h -- 35
end -- 29
local function coverArt(solid) -- 38
	return solid.art or ((string.find(solid.label, "队栏", nil, true) or 0) - 1 >= 0 and "fence" or (((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone")) -- 39
end -- 38
____exports.StageRenderer = __TS__Class() -- 43
local StageRenderer = ____exports.StageRenderer -- 43
StageRenderer.name = "StageRenderer" -- 43
function StageRenderer.prototype.____constructor(self) -- 43
end -- 43
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 45
	local w = cam.viewW -- 53
	local h = cam.viewH -- 54
	local theme = themeOf(p.room.key) -- 55
	local seed = roomSeed(p.room.key) -- 56
	local span = math.max(1, p.room.maxX - p.room.minX) -- 58
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 59
	local farSlot = "bgFar_" .. p.room.key -- 60
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 61
	local artH = artW * 9 / 16 -- 62
	if assets:tryPlace( -- 62
		farSlot, -- 63
		"scene", -- 63
		w * (0.5 - progress * 0.09), -- 63
		(h - artH) * 0.5, -- 63
		artW, -- 63
		artH -- 63
	) then -- 63
		self:drawDressing(assets, p, cam, progress) -- 64
		local y = cam.groundScreenY -- 65
		fillVGradRect( -- 66
			bgDraw, -- 66
			0, -- 66
			0, -- 66
			w, -- 66
			h, -- 66
			toColor(PALETTE.voidDark), -- 66
			toColor(theme.skyMid) -- 66
		) -- 66
		fillVGradRect( -- 67
			bgGlow, -- 67
			0, -- 67
			y - 1, -- 67
			w, -- 67
			h * 0.14, -- 67
			Color(43, 49, 63, 15), -- 67
			Color(43, 49, 63, 0) -- 67
		) -- 67
		return -- 68
	end -- 68
	local splitY = h * 0.46 -- 72
	fillVGradRect( -- 73
		bgDraw, -- 73
		0, -- 73
		splitY, -- 73
		w, -- 73
		h - splitY, -- 73
		toColor(theme.skyMid), -- 73
		toColor(theme.skyTop) -- 73
	) -- 73
	fillVGradRect( -- 74
		bgDraw, -- 74
		0, -- 74
		0, -- 74
		w, -- 74
		splitY, -- 74
		toColor(theme.skyHorizon), -- 74
		toColor(theme.skyMid) -- 74
	) -- 74
	if theme.showMoon then -- 74
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 78
		local my = h * theme.moonYFrac -- 79
		local mr = math.max(18, h * 0.044) -- 80
		fillRadialGlow( -- 81
			bgGlow, -- 81
			mx, -- 81
			my, -- 81
			mr * 6.2, -- 81
			mr * 6.2, -- 81
			Color(140, 200, 255, 28), -- 81
			Color(20, 40, 80, 0), -- 81
			22 -- 81
		) -- 81
		fillRadialGlow( -- 82
			bgGlow, -- 82
			mx, -- 82
			my, -- 82
			mr * 2.4, -- 82
			mr * 2.4, -- 82
			Color(200, 232, 255, 64), -- 82
			Color(80, 140, 210, 0), -- 82
			18 -- 82
		) -- 82
		bgDraw:drawCircle( -- 83
			Vec2(mx, my), -- 83
			mr, -- 83
			Color(224, 238, 252, 230) -- 83
		) -- 83
		bgDraw:drawCircle( -- 85
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 85
			mr * 0.84, -- 85
			toColor(theme.skyTop, 110) -- 85
		) -- 85
	end -- 85
	if p.room.key == "forest" then -- 85
		self:drawFarForest( -- 89
			bgDraw, -- 89
			w, -- 89
			h, -- 89
			cam, -- 89
			theme, -- 89
			seed -- 89
		) -- 89
		self:drawMidForest( -- 90
			bgDraw, -- 90
			bgGlow, -- 90
			w, -- 90
			h, -- 90
			cam, -- 90
			theme, -- 90
			time, -- 90
			seed -- 90
		) -- 90
	else -- 90
		self:drawFarCity( -- 92
			bgDraw, -- 92
			bgGlow, -- 92
			w, -- 92
			h, -- 92
			cam, -- 92
			theme, -- 92
			seed -- 92
		) -- 92
		self:drawMidArchitecture( -- 93
			bgDraw, -- 93
			bgGlow, -- 93
			w, -- 93
			h, -- 93
			cam, -- 93
			theme, -- 93
			time, -- 93
			seed -- 93
		) -- 93
	end -- 93
	if theme.showSearchlights then -- 93
		self:drawSearchlights( -- 96
			bgGlow, -- 96
			w, -- 96
			h, -- 96
			cam, -- 96
			theme, -- 96
			time, -- 96
			seed -- 96
		) -- 96
	end -- 96
	if theme.showTowerBeacon then -- 96
		self:drawDistantNorthTower( -- 99
			bgDraw, -- 99
			bgGlow, -- 99
			w, -- 99
			h, -- 99
			cam, -- 99
			p, -- 99
			time -- 99
		) -- 99
	end -- 99
	local fogH = h * 0.38 -- 103
	fillVGradRect( -- 104
		bgGlow, -- 105
		0, -- 106
		cam.groundScreenY - 10, -- 107
		w, -- 108
		fogH, -- 109
		toColor(theme.fogBottom), -- 110
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 111
	) -- 111
end -- 45
function StageRenderer.prototype.drawDressing(self, assets, p, cam, progress) -- 115
	local w = cam.viewW -- 116
	local ground = cam.groundScreenY -- 117
	local x = w * (0.75 - progress * 0.29) -- 118
	if p.room.key == "forest" or p.room.key == "outside" or p.room.key == "tower" then -- 118
		assets:tryPlace( -- 120
			"pine", -- 120
			"mid_pine", -- 120
			x, -- 120
			ground - cam:len(12), -- 120
			cam:len(124), -- 120
			cam:len(138), -- 120
			{layer = 1, opacity = 0.52} -- 121
		) -- 121
	elseif p.room.key == "prologue" or p.room.key == "village" or p.room.key == "checkpoint" then -- 121
		assets:tryPlace( -- 123
			"eaves", -- 123
			"mid_eaves", -- 123
			x, -- 123
			ground - cam:len(8), -- 123
			cam:len(186), -- 123
			cam:len(104), -- 123
			{layer = 1, opacity = 0.46} -- 124
		) -- 124
	else -- 124
		assets:tryPlace( -- 126
			"cover_stone", -- 126
			"mid_ruin", -- 126
			x, -- 126
			ground - cam:len(8), -- 126
			cam:len(140), -- 126
			cam:len(48), -- 126
			{layer = 1, opacity = 0.46} -- 127
		) -- 127
	end -- 127
	if p.room.key == "street" or p.room.key == "checkpoint" or p.room.key == "prologue" then -- 127
		assets:tryPlace( -- 130
			"prop_lantern", -- 130
			"mid_lantern", -- 130
			w * (0.27 - progress * 0.21), -- 130
			ground + cam:len(92), -- 131
			cam:len(22), -- 131
			cam:len(30), -- 131
			{layer = 2, opacity = 0.82} -- 131
		) -- 131
	end -- 131
end -- 115
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 136
	local theme = themeOf("checkpoint") -- 143
	local splitY = h * 0.44 -- 144
	fillVGradRect( -- 145
		bgDraw, -- 145
		0, -- 145
		splitY, -- 145
		w, -- 145
		h - splitY, -- 145
		toColor(theme.skyMid), -- 145
		toColor(theme.skyTop) -- 145
	) -- 145
	fillVGradRect( -- 146
		bgDraw, -- 146
		0, -- 146
		0, -- 146
		w, -- 146
		splitY, -- 146
		toColor(theme.skyHorizon), -- 146
		toColor(theme.skyMid) -- 146
	) -- 146
	local mx = w * 0.61 -- 149
	local my = h * 0.74 -- 150
	local mr = h * 0.082 -- 151
	fillRadialGlow( -- 152
		bgGlow, -- 152
		mx, -- 152
		my, -- 152
		mr * 5.2, -- 152
		mr * 5.2, -- 152
		Color(86, 210, 255, 34), -- 152
		Color(10, 24, 52, 0), -- 152
		24 -- 152
	) -- 152
	fillRadialGlow( -- 153
		bgGlow, -- 153
		mx, -- 153
		my, -- 153
		mr * 2.1, -- 153
		mr * 2.1, -- 153
		Color(190, 240, 255, 76), -- 153
		Color(40, 120, 190, 0), -- 153
		20 -- 153
	) -- 153
	bgDraw:drawCircle( -- 154
		Vec2(mx, my), -- 154
		mr, -- 154
		Color(228, 242, 255, 235) -- 154
	) -- 154
	bgDraw:drawCircle( -- 155
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 155
		mr * 0.86, -- 155
		Color(10, 18, 34, 125) -- 155
	) -- 155
	local s = 0 -- 158
	do -- 158
		s = 0 -- 159
		while s < 3 do -- 159
			local bx = w * (0.36 + s * 0.24) -- 160
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 161
			local ang = math.pi * 0.5 + sway - 0.12 -- 162
			local len = h * 1.15 -- 163
			local spread = 0.085 + s * 0.015 -- 164
			local x1 = bx + math.cos(ang - spread) * len -- 165
			local y1 = math.sin(ang - spread) * len -- 166
			local x2 = bx + math.cos(ang + spread) * len -- 167
			local y2 = math.sin(ang + spread) * len -- 168
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 169
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 170
			bgGlow:drawVertices({ -- 171
				{ -- 172
					Vec2(bx, h * 0.15), -- 172
					baseCol -- 172
				}, -- 172
				{ -- 173
					Vec2(x1, y1), -- 173
					tipCol -- 173
				}, -- 173
				{ -- 174
					Vec2(x2, y2), -- 174
					tipCol -- 174
				} -- 174
			}) -- 174
			s = s + 1 -- 159
		end -- 159
	end -- 159
	local groundY = h * 0.19 -- 179
	local i = 0 -- 180
	do -- 180
		i = 0 -- 181
		while i < 16 do -- 181
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 182
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 183
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 184
			local cut = 12 + hash01(i * 19) * 20 -- 185
			bgDraw:drawPolygon( -- 186
				{ -- 186
					Vec2(bx, groundY), -- 187
					Vec2(bx + bw, groundY), -- 188
					Vec2(bx + bw, groundY + bh - cut), -- 189
					Vec2(bx + bw - cut, groundY + bh), -- 190
					Vec2(bx, groundY + bh) -- 191
				}, -- 191
				Color(10, 16, 28, 255) -- 192
			) -- 192
			if hash01(i * 41 + 5) > 0.45 then -- 192
				local wy = groundY + bh * 0.65 -- 195
				bgGlow:drawSegment( -- 196
					Vec2(bx + 10, wy), -- 196
					Vec2(bx + bw - 14, wy), -- 196
					1.2, -- 196
					Color(72, 224, 255, 95) -- 196
				) -- 196
			end -- 196
			i = i + 1 -- 181
		end -- 181
	end -- 181
	local tx = w * 0.83 -- 201
	local ty0 = groundY -- 202
	local ty1 = h * 0.62 -- 203
	bgDraw:drawPolygon( -- 204
		{ -- 204
			Vec2(tx - 26, ty0), -- 205
			Vec2(tx + 26, ty0), -- 206
			Vec2(tx + 11, ty1), -- 207
			Vec2(tx - 11, ty1) -- 208
		}, -- 208
		Color(15, 24, 40, 255), -- 209
		1.2, -- 209
		Color(58, 86, 118, 140) -- 209
	) -- 209
	bgDraw:drawSegment( -- 210
		Vec2(tx, ty0 + 24), -- 210
		Vec2(tx, ty1 - 12), -- 210
		1.4, -- 210
		Color(242, 188, 96, 85) -- 210
	) -- 210
	bgDraw:drawSegment( -- 211
		Vec2(tx, ty1), -- 211
		Vec2(tx, ty1 + 42), -- 211
		2.2, -- 211
		Color(165, 212, 248, 210) -- 211
	) -- 211
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 212
	fillRadialGlow( -- 213
		bgGlow, -- 213
		tx, -- 213
		ty1 + 42, -- 213
		74 * pulse, -- 213
		74 * pulse, -- 213
		Color(255, 222, 146, 130), -- 213
		Color(255, 180, 90, 0), -- 213
		20 -- 213
	) -- 213
	bgGlow:drawDot( -- 214
		Vec2(tx, ty1 + 42), -- 214
		5, -- 214
		Color(255, 248, 224, 255) -- 214
	) -- 214
	fillVGradRect( -- 217
		bgDraw, -- 217
		0, -- 217
		0, -- 217
		w, -- 217
		groundY, -- 217
		Color(6, 9, 16, 255), -- 217
		Color(16, 24, 38, 255) -- 217
	) -- 217
	bgDraw:drawSegment( -- 218
		Vec2(0, groundY), -- 218
		Vec2(w, groundY), -- 218
		2, -- 218
		Color(76, 220, 255, 180) -- 218
	) -- 218
	fillVGradRect( -- 219
		bgGlow, -- 219
		0, -- 219
		groundY, -- 219
		w, -- 219
		h * 0.24, -- 219
		Color(42, 130, 182, 52), -- 219
		Color(20, 60, 100, 0) -- 219
	) -- 219
	local sx = w * 0.64 -- 222
	fillRadialGlow( -- 223
		bgGlow, -- 223
		sx + 38, -- 223
		groundY + 75, -- 223
		128, -- 223
		92, -- 223
		Color(52, 178, 232, 42), -- 223
		Color(20, 60, 110, 0), -- 223
		18 -- 223
	) -- 223
	bgDraw:drawPolygon( -- 225
		{ -- 225
			Vec2(sx - 36, groundY + 12), -- 226
			Vec2(sx + 10, groundY + 18), -- 227
			Vec2(sx + 16, groundY + 124), -- 228
			Vec2(sx - 18, groundY + 124) -- 229
		}, -- 229
		Color(10, 16, 28, 255), -- 230
		1.3, -- 230
		Color(76, 210, 255, 145) -- 230
	) -- 230
	bgDraw:drawSegment( -- 231
		Vec2(sx - 6, groundY + 48), -- 231
		Vec2(sx - 12, groundY + 2), -- 231
		6, -- 231
		Color(10, 16, 28, 255) -- 231
	) -- 231
	bgDraw:drawSegment( -- 232
		Vec2(sx + 6, groundY + 48), -- 232
		Vec2(sx + 14, groundY + 2), -- 232
		6, -- 232
		Color(14, 22, 36, 255) -- 232
	) -- 232
	bgDraw:drawPolygon( -- 233
		{ -- 233
			Vec2(sx - 20, groundY + 120), -- 234
			Vec2(sx + 20, groundY + 122), -- 235
			Vec2(sx + 16, groundY + 132), -- 236
			Vec2(sx - 16, groundY + 130) -- 237
		}, -- 237
		Color(208, 236, 252, 240) -- 238
	) -- 238
	bgDraw:drawCircle( -- 239
		Vec2(sx + 2, groundY + 146), -- 239
		13, -- 239
		Color(14, 22, 36, 255) -- 239
	) -- 239
	bgDraw:drawArc( -- 240
		Vec2(sx + 2, groundY + 146), -- 240
		13.5, -- 240
		30, -- 240
		165, -- 240
		2, -- 240
		Color(216, 240, 255, 230) -- 240
	) -- 240
	bgGlow:drawSegment( -- 241
		Vec2(sx + 4, groundY + 148), -- 241
		Vec2(sx + 17, groundY + 150), -- 241
		2.6, -- 241
		Color(86, 240, 255, 255) -- 241
	) -- 241
	bgDraw:drawSegment( -- 242
		Vec2(sx + 4, groundY + 104), -- 242
		Vec2(sx + 46, groundY + 94), -- 242
		3.4, -- 242
		Color(34, 52, 74, 255) -- 242
	) -- 242
	bgGlow:drawSegment( -- 243
		Vec2(sx + 16, groundY + 102), -- 243
		Vec2(sx + 44, groundY + 95), -- 243
		1.2, -- 243
		Color(86, 236, 255, 200) -- 243
	) -- 243
	local cx = w * 0.725 -- 246
	bgDraw:drawPolygon( -- 247
		{ -- 247
			Vec2(cx - 20, groundY + 14), -- 248
			Vec2(cx + 18, groundY + 14), -- 249
			Vec2(cx + 12, groundY + 84), -- 250
			Vec2(cx - 12, groundY + 84) -- 251
		}, -- 251
		Color(188, 142, 78, 238), -- 252
		1.4, -- 252
		Color(252, 232, 192, 225) -- 252
	) -- 252
	bgDraw:drawSegment( -- 253
		Vec2(cx - 5, groundY + 24), -- 253
		Vec2(cx - 6, groundY + 2), -- 253
		4.2, -- 253
		Color(28, 24, 30, 255) -- 253
	) -- 253
	bgDraw:drawSegment( -- 254
		Vec2(cx + 5, groundY + 24), -- 254
		Vec2(cx + 6, groundY + 2), -- 254
		4.2, -- 254
		Color(38, 32, 38, 255) -- 254
	) -- 254
	bgDraw:drawCircle( -- 255
		Vec2(cx + 1, groundY + 95), -- 255
		11, -- 255
		Color(238, 220, 194, 250) -- 255
	) -- 255
	bgDraw:drawPolygon( -- 256
		{ -- 256
			Vec2(cx - 15, groundY + 84), -- 257
			Vec2(cx - 10, groundY + 108), -- 258
			Vec2(cx + 6, groundY + 107), -- 259
			Vec2(cx - 4, groundY + 84) -- 260
		}, -- 260
		Color(156, 114, 62, 245) -- 261
	) -- 261
	bgGlow:drawSegment( -- 262
		Vec2(cx - 8, groundY + 82), -- 262
		Vec2(cx - 30, groundY + 64), -- 262
		2.8, -- 262
		Color(252, 230, 178, 220) -- 262
	) -- 262
	fillRadialGlow( -- 263
		bgGlow, -- 263
		cx + 10, -- 263
		groundY + 56, -- 263
		30, -- 263
		30, -- 263
		Color(255, 214, 130, 115), -- 263
		Color(250, 180, 70, 0), -- 263
		16 -- 263
	) -- 263
	bgGlow:drawDot( -- 264
		Vec2(cx + 10, groundY + 56), -- 264
		3.2, -- 264
		Color(255, 246, 220, 255) -- 264
	) -- 264
end -- 136
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 268
	local theme = themeOf(p.room.key) -- 278
	self:drawFloors( -- 279
		fgDraw, -- 279
		assets, -- 279
		p, -- 279
		cam, -- 279
		theme -- 279
	) -- 279
	self:drawStairs( -- 280
		fgDraw, -- 280
		fgGlow, -- 280
		assets, -- 280
		p, -- 280
		cam, -- 280
		theme -- 280
	) -- 280
	self:drawSolids( -- 281
		fgDraw, -- 281
		fgGlow, -- 281
		assets, -- 281
		p, -- 281
		cam, -- 281
		theme, -- 281
		time, -- 281
		occlusion, -- 281
		fadeDt -- 281
	) -- 281
	if p.room.key == "gate" then -- 281
		self:drawGateShutter( -- 283
			fgDraw, -- 283
			fgGlow, -- 283
			assets, -- 283
			p, -- 283
			cam, -- 283
			time -- 283
		) -- 283
	end -- 283
	self:drawArch( -- 285
		fgDraw, -- 285
		fgGlow, -- 285
		p, -- 285
		cam, -- 285
		theme -- 285
	) -- 285
end -- 268
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 289
	local seed = roomSeed(p.room.key) -- 296
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 298
	local span = 520 -- 299
	local startIdx = math.floor((-parallax - 200) / span) -- 300
	local idx = startIdx -- 301
	do -- 301
		idx = startIdx -- 302
		while idx <= startIdx + 4 do -- 302
			local x = idx * span + parallax -- 303
			local r = hash01(seed + idx * 17) -- 304
			local bw = 70 + r * 90 -- 305
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 306
			fgDraw:drawPolygon( -- 307
				{ -- 307
					Vec2(x, 0), -- 308
					Vec2(x + bw, 0), -- 309
					Vec2(x + bw - 18, bh), -- 310
					Vec2(x + 12, bh * 0.72) -- 311
				}, -- 311
				Color(4, 6, 11, 225) -- 312
			) -- 312
			idx = idx + 1 -- 302
		end -- 302
	end -- 302
	fillVGradRect( -- 316
		fgDraw, -- 316
		0, -- 316
		h - h * 0.16, -- 316
		w, -- 316
		h * 0.16, -- 316
		Color(4, 6, 12, 0), -- 316
		Color(4, 6, 12, 138) -- 316
	) -- 316
	fillVGradRect( -- 317
		fgDraw, -- 317
		0, -- 317
		0, -- 317
		w, -- 317
		h * 0.13, -- 317
		Color(4, 6, 12, 185), -- 317
		Color(4, 6, 12, 0) -- 317
	) -- 317
end -- 289
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 320
	local count = 3 -- 329
	local i = 0 -- 330
	do -- 330
		i = 0 -- 331
		while i < count do -- 331
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 332
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 333
			local by = cam.groundScreenY * 0.85 -- 334
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 335
			local ang = math.pi * 0.5 + sway -- 336
			local len = h * 1.15 -- 337
			local halfSpread = 0.065 + i % 2 * 0.025 -- 338
			local x1 = bx + math.cos(ang - halfSpread) * len -- 339
			local y1 = by + math.sin(ang - halfSpread) * len -- 340
			local x2 = bx + math.cos(ang + halfSpread) * len -- 341
			local y2 = by + math.sin(ang + halfSpread) * len -- 342
			local c0 = toColor(theme.beamColor) -- 343
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 344
			bgGlow:drawVertices({ -- 345
				{ -- 346
					Vec2(bx, by), -- 346
					c0 -- 346
				}, -- 346
				{ -- 347
					Vec2(x1, y1), -- 347
					c1 -- 347
				}, -- 347
				{ -- 348
					Vec2(x2, y2), -- 348
					c1 -- 348
				} -- 348
			}) -- 348
			i = i + 1 -- 331
		end -- 331
	end -- 331
end -- 320
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 353
	local baseY = cam.groundScreenY - 8 -- 362
	local shift = -cam.x * 0.2 * cam.ppu -- 363
	local colW = 108 -- 364
	local first = math.floor((-shift - colW) / colW) -- 365
	local count = math.ceil(w / colW) + 3 -- 366
	local i = 0 -- 367
	do -- 367
		i = 0 -- 368
		while i < count do -- 368
			local idx = first + i -- 369
			local r1 = hash01(seed + idx * 13.7) -- 370
			local r2 = hash01(seed + idx * 29.3) -- 371
			local r3 = hash01(seed + idx * 47.1) -- 372
			local x = idx * colW + shift -- 373
			local bw = colW * (0.68 + r1 * 0.44) -- 374
			local bh = h * (0.18 + r2 * 0.38) -- 375
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 376
			bgDraw:drawPolygon( -- 378
				{ -- 378
					Vec2(x, baseY), -- 379
					Vec2(x + bw, baseY), -- 380
					Vec2(x + bw, baseY + bh - cut), -- 381
					Vec2(x + bw - cut, baseY + bh), -- 382
					Vec2(x, baseY + bh) -- 383
				}, -- 383
				toColor(theme.farBuilding) -- 384
			) -- 384
			if r3 > 0.62 then -- 384
				local ax = x + bw * 0.25 -- 388
				bgDraw:drawSegment( -- 389
					Vec2(ax, baseY + bh), -- 389
					Vec2(ax, baseY + bh + 32), -- 389
					1.2, -- 389
					toColor(theme.farBuilding) -- 389
				) -- 389
				if r1 > 0.6 then -- 389
					bgGlow:drawDot( -- 391
						Vec2(ax, baseY + bh + 32), -- 391
						2.2, -- 391
						toColor(theme.accent, 145) -- 391
					) -- 391
				end -- 391
			end -- 391
			if r2 > 0.55 then -- 391
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 396
				bgGlow:drawSegment( -- 397
					Vec2(x + 12, wy), -- 397
					Vec2(x + bw - 14, wy), -- 397
					1.1, -- 397
					toColor(theme.accent, 64) -- 397
				) -- 397
			end -- 397
			i = i + 1 -- 368
		end -- 368
	end -- 368
end -- 353
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 402
	local baseY = cam.groundScreenY - 8 -- 410
	local shift = -cam.x * 0.22 * cam.ppu -- 411
	local step = 76 -- 412
	local first = math.floor((-shift - step) / step) -- 413
	local count = math.ceil(w / step) + 4 -- 414
	local i = 0 -- 415
	do -- 415
		i = 0 -- 416
		while i < count do -- 416
			local idx = first + i -- 417
			local r1 = hash01(seed + idx * 11.3) -- 418
			local r2 = hash01(seed + idx * 23.9) -- 419
			local cx = idx * step + shift -- 420
			local tw = 34 + r1 * 38 -- 421
			local th = h * (0.24 + r2 * 0.34) -- 422
			bgDraw:drawPolygon( -- 424
				{ -- 424
					Vec2(cx - tw, baseY), -- 425
					Vec2(cx + tw, baseY), -- 426
					Vec2(cx, baseY + th) -- 427
				}, -- 427
				toColor(theme.farBuilding) -- 428
			) -- 428
			bgDraw:drawPolygon( -- 429
				{ -- 429
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 430
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 431
					Vec2(cx, baseY + th * 1.12) -- 432
				}, -- 432
				toColor(theme.farBuilding) -- 433
			) -- 433
			i = i + 1 -- 416
		end -- 416
	end -- 416
end -- 402
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 437
	local baseY = cam.groundScreenY - 4 -- 447
	local shift = -cam.x * 0.48 * cam.ppu -- 448
	local bay = 240 -- 449
	local first = math.floor((-shift - bay) / bay) -- 450
	local count = math.ceil(w / bay) + 3 -- 451
	local col = toColor(theme.midBuilding) -- 452
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 453
	local i = 0 -- 455
	do -- 455
		i = 0 -- 456
		while i < count do -- 456
			local idx = first + i -- 457
			local r = hash01(seed + idx * 37.3) -- 458
			local x = idx * bay + shift -- 459
			local colH = h * (0.34 + r * 0.24) -- 460
			local pw = 22 + r * 16 -- 461
			bgDraw:drawRect( -- 464
				Rect(x, baseY, pw, colH), -- 464
				col -- 464
			) -- 464
			bgDraw:drawSegment( -- 465
				Vec2(x + pw, baseY), -- 465
				Vec2(x + pw, baseY + colH), -- 465
				1, -- 465
				edge -- 465
			) -- 465
			if r > 0.35 then -- 465
				local beamY = baseY + colH * 0.76 -- 467
				bgDraw:drawSegment( -- 468
					Vec2(x + pw, beamY), -- 468
					Vec2(x + bay, beamY), -- 468
					4, -- 468
					col -- 468
				) -- 468
				bgDraw:drawSegment( -- 469
					Vec2(x + pw, beamY - 22), -- 469
					Vec2(x + bay * 0.5, beamY), -- 469
					1.4, -- 469
					edge -- 469
				) -- 469
				bgDraw:drawSegment( -- 470
					Vec2(x + bay * 0.5, beamY), -- 470
					Vec2(x + bay, beamY - 22), -- 470
					1.4, -- 470
					edge -- 470
				) -- 470
			end -- 470
			bgDraw:drawQuadraticBezier( -- 474
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 475
				Vec2( -- 476
					x + bay * 0.5, -- 476
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 476
				), -- 476
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 477
				1, -- 478
				Color(12, 18, 28, 180) -- 479
			) -- 479
			if idx & 1 == 0 then -- 479
				local lx = x + bay * 0.52 -- 484
				local ly = baseY + h * 0.31 -- 485
				bgDraw:drawSegment( -- 486
					Vec2(lx, baseY), -- 486
					Vec2(lx, ly), -- 486
					2.2, -- 486
					col -- 486
				) -- 486
				bgDraw:drawSegment( -- 487
					Vec2(lx, ly), -- 487
					Vec2(lx + 18, ly - 4), -- 487
					2, -- 487
					col -- 487
				) -- 487
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 488
				local lc = theme.accent -- 489
				bgGlow:drawDot( -- 490
					Vec2(lx + 18, ly - 5), -- 490
					3.2, -- 490
					toColor(lc, 210 * flicker) -- 490
				) -- 490
				fillRadialGlow( -- 491
					bgGlow, -- 491
					lx + 18, -- 491
					ly - 5, -- 491
					36, -- 491
					36, -- 491
					toColor(lc, 54 * flicker), -- 491
					Color(lc.r, lc.g, lc.b, 0), -- 491
					14 -- 491
				) -- 491
				bgGlow:drawVertices({ -- 492
					{ -- 493
						Vec2(lx + 18, ly - 6), -- 493
						toColor(lc, 38 * flicker) -- 493
					}, -- 493
					{ -- 494
						Vec2(lx - 42, baseY), -- 494
						Color(lc.r, lc.g, lc.b, 0) -- 494
					}, -- 494
					{ -- 495
						Vec2(lx + 78, baseY), -- 495
						Color(lc.r, lc.g, lc.b, 0) -- 495
					} -- 495
				}) -- 495
			end -- 495
			i = i + 1 -- 456
		end -- 456
	end -- 456
end -- 437
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 501
	local baseY = cam.groundScreenY - 4 -- 511
	local shift = -cam.x * 0.52 * cam.ppu -- 512
	local span = 156 -- 513
	local first = math.floor((-shift - span) / span) -- 514
	local count = math.ceil(w / span) + 3 -- 515
	local col = toColor(theme.midBuilding) -- 516
	local i = 0 -- 518
	do -- 518
		i = 0 -- 519
		while i < count do -- 519
			local idx = first + i -- 520
			local r = hash01(seed + idx * 19.7) -- 521
			local x = idx * span + shift -- 522
			local trunkW = 14 + r * 14 -- 523
			local sway = math.sin(time * 0.9 + idx) * 4 -- 524
			bgDraw:drawPolygon( -- 525
				{ -- 525
					Vec2(x - trunkW * 0.5, baseY), -- 526
					Vec2(x + trunkW * 0.5, baseY), -- 527
					Vec2(x + trunkW * 0.25 + sway, h), -- 528
					Vec2(x - trunkW * 0.3 + sway, h) -- 529
				}, -- 529
				col -- 530
			) -- 530
			if idx % 3 == 0 then -- 530
				bgGlow:drawVertices({ -- 533
					{ -- 534
						Vec2(x + 40, h), -- 534
						Color(110, 232, 200, 26) -- 534
					}, -- 534
					{ -- 535
						Vec2(x + 115, h), -- 535
						Color(110, 232, 200, 0) -- 535
					}, -- 535
					{ -- 536
						Vec2(x - 60, baseY), -- 536
						Color(110, 232, 200, 0) -- 536
					} -- 536
				}) -- 536
			end -- 536
			i = i + 1 -- 519
		end -- 519
	end -- 519
end -- 501
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 542
	local scale = 0.55 -- 552
	if p.room.key == "village" then -- 552
		scale = 0.72 -- 554
	elseif p.room.key == "forest" then -- 554
		scale = 0.92 -- 556
	elseif p.room.key == "tower" then -- 556
		scale = 1.15 -- 558
	end -- 558
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 560
	local baseY = cam.groundScreenY - 8 -- 561
	local towerH = h * 0.42 * scale -- 562
	local bw = 20 * scale -- 563
	bgDraw:drawPolygon( -- 564
		{ -- 564
			Vec2(tx - bw, baseY), -- 565
			Vec2(tx + bw, baseY), -- 566
			Vec2(tx + bw * 0.45, baseY + towerH), -- 567
			Vec2(tx - bw * 0.45, baseY + towerH) -- 568
		}, -- 568
		Color(14, 24, 38, 240) -- 569
	) -- 569
	bgDraw:drawSegment( -- 570
		Vec2(tx, baseY + towerH), -- 570
		Vec2(tx, baseY + towerH + 28 * scale), -- 570
		1.8, -- 570
		Color(180, 210, 238, 200) -- 570
	) -- 570
	local topY = baseY + towerH + 24 * scale -- 572
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 573
	fillRadialGlow( -- 574
		bgGlow, -- 574
		tx, -- 574
		topY, -- 574
		56 * scale * pulse, -- 574
		56 * scale * pulse, -- 574
		Color(255, 224, 152, 118), -- 574
		Color(255, 190, 96, 0), -- 574
		18 -- 574
	) -- 574
	bgGlow:drawDot( -- 575
		Vec2(tx, topY), -- 575
		3.6 * scale, -- 575
		Color(255, 246, 220, 255) -- 575
	) -- 575
end -- 542
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 578
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 585
	do -- 585
		local i = 0 -- 586
		while i < #p.room.floors do -- 586
			local floor = p.room.floors[i + 1] -- 587
			local left = cam:sx(floor.x0) -- 588
			local right = cam:sx(floor.x1) -- 589
			local isMain = floor.y <= 0.1 -- 590
			local ____isMain_0 -- 591
			if isMain then -- 591
				____isMain_0 = p.room.depth -- 591
			else -- 591
				____isMain_0 = nil -- 591
			end -- 591
			local road = ____isMain_0 -- 591
			local top = cam:sy(floor.y, road and road.min or 0) -- 592
			if road ~= nil then -- 592
				self:drawRoad( -- 594
					fgDraw, -- 594
					assets, -- 594
					i, -- 594
					left, -- 594
					right, -- 594
					top, -- 594
					cam:sy(floor.y, road.max), -- 594
					cam, -- 594
					theme -- 594
				) -- 594
			end -- 594
			local height = cam:len(isMain and 22 or 12) -- 596
			local bottom = top - height -- 597
			if isMain and bottom > 0 then -- 597
				fillVGradRect( -- 599
					fgDraw, -- 599
					left, -- 599
					0, -- 599
					right - left, -- 599
					bottom + 1, -- 599
					toColor(PALETTE.voidDark), -- 600
					toColor(theme.groundBody) -- 600
				) -- 600
			end -- 600
			fgDraw:drawRect( -- 602
				Rect(left, bottom, right - left, height), -- 602
				toColor(PALETTE.steelDark) -- 602
			) -- 602
			local step = cam:len(96) -- 603
			local start = math.max( -- 604
				0, -- 604
				math.floor(-left / step) -- 604
			) -- 604
			do -- 604
				local j = start -- 605
				while left + j * step < math.min(right, cam.viewW) do -- 605
					local x = left + j * step -- 606
					local width = math.min(step, right - x) -- 607
					assets:tryPlace( -- 608
						"slab", -- 608
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 608
						x + width * 0.5, -- 608
						bottom, -- 608
						width, -- 608
						height -- 608
					) -- 608
					if grass and isMain and j % 3 == 1 then -- 608
						assets:tryPlace( -- 610
							"grass_low", -- 610
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 610
							x + width * 0.5, -- 610
							top - cam:len(3), -- 611
							width * 0.74, -- 611
							cam:len(13), -- 611
							{opacity = 0.83, layer = 1} -- 611
						) -- 611
					end -- 611
					j = j + 1 -- 605
				end -- 605
			end -- 605
			fgDraw:drawSegment( -- 614
				Vec2(left, top), -- 614
				Vec2(right, top), -- 614
				1, -- 614
				toColor(theme.groundRim, 140) -- 614
			) -- 614
			i = i + 1 -- 586
		end -- 586
	end -- 586
end -- 578
function StageRenderer.prototype.drawRoad(self, draw, assets, floor, left, right, front, back, cam, theme) -- 618
	local width = right - left -- 623
	local height = back - front -- 624
	fillVGradRect( -- 625
		draw, -- 625
		left, -- 625
		front, -- 625
		width, -- 625
		height, -- 625
		toColor(lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.34)), -- 626
		toColor(lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.36)) -- 627
	) -- 627
	local bands = { -- 628
		0, -- 628
		0.31, -- 628
		0.59, -- 628
		0.82, -- 628
		1 -- 628
	} -- 628
	local edge = toColor(theme.groundRim, 34) -- 629
	do -- 629
		local row = 0 -- 630
		while row < #bands - 1 do -- 630
			local y = front + bands[row + 1] * height -- 631
			local rowHeight = (bands[row + 1 + 1] - bands[row + 1]) * height -- 632
			local slabWidth = cam:len(132 - row * 12) -- 633
			local offset = left - row % 2 * slabWidth * 0.5 -- 634
			local start = math.max( -- 635
				0, -- 635
				math.floor(-offset / slabWidth) -- 635
			) -- 635
			do -- 635
				local column = start -- 636
				while offset + column * slabWidth < math.min(right, cam.viewW) do -- 636
					local tileStart = offset + column * slabWidth -- 637
					local x = math.max(left, tileStart) -- 638
					local w = math.min(right, tileStart + slabWidth) - x -- 639
					if w > 1 then -- 639
						assets:tryPlace( -- 641
							"wall", -- 641
							(((("road_" .. tostring(floor)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 641
							x + w * 0.5, -- 642
							y, -- 642
							w, -- 642
							rowHeight, -- 642
							{ -- 642
								opacity = 0.88 - row * 0.09, -- 643
								facing = (column + row) % 2 == 0 and 1 or -1, -- 644
								color = Color(174 - row * 9, 167 - row * 7, 154 - row * 3, 255) -- 645
							} -- 645
						) -- 645
					end -- 645
					column = column + 1 -- 636
				end -- 636
			end -- 636
			draw:drawSegment( -- 649
				Vec2(left, y), -- 649
				Vec2(right, y), -- 649
				0.8, -- 649
				edge -- 649
			) -- 649
			row = row + 1 -- 630
		end -- 630
	end -- 630
	draw:drawSegment( -- 651
		Vec2(left, back), -- 651
		Vec2(right, back), -- 651
		1.1, -- 651
		toColor(theme.groundRim, 53) -- 651
	) -- 651
end -- 618
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 654
	local i = 0 -- 662
	do -- 662
		i = 0 -- 663
		while i < #p.room.stairs do -- 663
			local st = p.room.stairs[i + 1] -- 664
			local n = st.steps + 1 -- 665
			local stepW = (st.x1 - st.x0) / n -- 666
			local k = 0 -- 667
			do -- 667
				k = 0 -- 668
				while k < n do -- 668
					local wy = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 669
					local wx0 = st.x0 + stepW * k -- 670
					local wx1 = wx0 + stepW -- 671
					local x0 = cam:sx(wx0) -- 672
					local x1 = cam:sx(wx1) -- 673
					local y1 = cam:sy(wy) -- 674
					local y0 = cam:sy(math.max(0, st.y0)) -- 675
					if y1 > y0 + 2 then -- 675
						fgDraw:drawRect( -- 677
							Rect(x0, y0, x1 - x0, y1 - y0), -- 677
							toColor(PALETTE.steelDark, 230) -- 677
						) -- 677
						fgDraw:drawRect( -- 678
							Rect(x0, y1 - 5, x1 - x0, 5), -- 678
							toColor(theme.groundTop) -- 678
						) -- 678
						assets:tryPlace( -- 679
							"wall", -- 679
							(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 679
							(x0 + x1) * 0.5, -- 679
							y0, -- 679
							x1 - x0, -- 680
							y1 - y0, -- 680
							{opacity = 0.78} -- 680
						) -- 680
						assets:tryPlace( -- 681
							"slab", -- 681
							(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 681
							(x0 + x1) * 0.5, -- 681
							y1 - cam:len(5), -- 681
							x1 - x0, -- 682
							cam:len(5), -- 682
							{layer = 1} -- 682
						) -- 682
					end -- 682
					fgDraw:drawSegment( -- 684
						Vec2(x0, y1), -- 684
						Vec2(x1, y1), -- 684
						1.8, -- 684
						toColor(theme.groundRim) -- 684
					) -- 684
					fgGlow:drawSegment( -- 685
						Vec2(x0, y1 + 1), -- 685
						Vec2(x1, y1 + 1), -- 685
						1, -- 685
						toColor(theme.accent, 55) -- 685
					) -- 685
					k = k + 1 -- 668
				end -- 668
			end -- 668
			i = i + 1 -- 663
		end -- 663
	end -- 663
end -- 654
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 690
	local i = 0 -- 701
	do -- 701
		i = 0 -- 702
		while i < #p.room.solids do -- 702
			do -- 702
				local s = p.room.solids[i + 1] -- 703
				local x0 = cam:sx(s.x) -- 704
				local x1 = cam:sx(s.x + s.w) -- 705
				if p.room.depth ~= nil and s.depth ~= nil then -- 705
					local opacity = occlusion:update( -- 707
						"solid_" .. tostring(i), -- 707
						{ -- 707
							x0 = s.x, -- 708
							x1 = s.x + s.w, -- 708
							y0 = s.y, -- 708
							y1 = s.y + s.h, -- 708
							depth = s.depth, -- 709
							passThrough = s.decorative -- 709
						}, -- 709
						p, -- 710
						fadeDt -- 710
					) -- 710
					if x1 > 0 and x0 < cam.viewW then -- 710
						self:drawDepthSolid( -- 712
							fgDraw, -- 712
							assets, -- 712
							s, -- 712
							s.depth, -- 712
							x0, -- 712
							x1, -- 712
							cam, -- 712
							theme, -- 712
							opacity -- 712
						) -- 712
					end -- 712
					goto __continue78 -- 714
				end -- 714
				local y0 = cam:sy(s.y) -- 716
				local y1 = cam:sy(s.y + s.h) -- 717
				local sw = x1 - x0 -- 718
				local sh = y1 - y0 -- 719
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 719
					goto __continue78 -- 721
				end -- 721
				if s.passable == true then -- 721
					if not assets:tryPlace( -- 721
						"grass", -- 726
						"hide_grass_" .. tostring(i), -- 726
						(x0 + x1) * 0.5, -- 726
						y0, -- 726
						sw, -- 726
						sh * 1.55, -- 726
						{opacity = 0.79, layer = 7} -- 727
					) then -- 727
						self:drawGrassCluster( -- 728
							fgDraw, -- 728
							fgGlow, -- 728
							x0, -- 728
							y0, -- 728
							sw, -- 728
							sh, -- 728
							p.player.x, -- 728
							s.x + s.w * 0.5, -- 728
							time -- 728
						) -- 728
					end -- 728
					goto __continue78 -- 730
				end -- 730
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 730
					self:drawWinch( -- 735
						fgDraw, -- 735
						fgGlow, -- 735
						x0, -- 735
						y0, -- 735
						sw, -- 735
						sh, -- 735
						p, -- 735
						time -- 735
					) -- 735
					assets:tryPlace( -- 736
						"prop_winch", -- 736
						"gate_winch", -- 736
						(x0 + x1) * 0.5, -- 736
						y0 + sh * 0.55, -- 736
						sw, -- 736
						sh * 0.78, -- 736
						{layer = 2} -- 737
					) -- 737
					goto __continue78 -- 738
				end -- 738
				if p.room.key == "tower" then -- 738
					self:drawTowerStructure( -- 743
						fgDraw, -- 743
						fgGlow, -- 743
						assets, -- 743
						x0, -- 743
						y0, -- 743
						sw, -- 743
						sh, -- 743
						s, -- 743
						p, -- 743
						time -- 743
					) -- 743
					goto __continue78 -- 744
				end -- 744
				if s.h <= 64 and s.y <= 2 then -- 744
					self:drawCoverBlock( -- 749
						fgDraw, -- 749
						fgGlow, -- 749
						assets, -- 749
						x0, -- 749
						y0, -- 749
						sw, -- 749
						sh, -- 749
						s, -- 749
						p, -- 749
						theme -- 749
					) -- 749
					goto __continue78 -- 750
				end -- 750
				fillVGradRect( -- 753
					fgDraw, -- 753
					x0, -- 753
					y0, -- 753
					sw, -- 753
					sh, -- 753
					toColor(PALETTE.steelDark), -- 753
					toColor(PALETTE.steelMid) -- 753
				) -- 753
				self:tileMasonry( -- 754
					assets, -- 754
					s, -- 754
					x0, -- 754
					y0, -- 754
					sw, -- 754
					sh -- 754
				) -- 754
			end -- 754
			::__continue78:: -- 754
			i = i + 1 -- 702
		end -- 702
	end -- 702
end -- 690
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity) -- 758
	local width = right - left -- 762
	local base = cam:sy(solid.y, depth.min) -- 763
	local top = cam:sy(solid.y + solid.h, depth.min) -- 764
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 765
	local slot = coverArt(solid) -- 766
	local layer = depthOrder(depth.min, 1) -- 767
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 768
	local capHeight = rear - top -- 769
	draw:drawEllipse( -- 770
		Vec2( -- 770
			(left + right) * 0.5, -- 770
			base + cam:len(3) -- 770
		), -- 770
		width * 0.52, -- 770
		cam:len(3.5), -- 771
		Color(13, 12, 16, 123 * opacity) -- 771
	) -- 771
	if slot ~= "fence" and capHeight > 1 then -- 771
		local timber = slot == "cover_wood" -- 773
		draw:drawRect( -- 774
			Rect(left, top, width, capHeight), -- 774
			timber and Color(79, 63, 50, 239 * opacity) or Color(76, 78, 85, 239 * opacity) -- 775
		) -- 775
		assets:tryPlace( -- 776
			timber and "slab" or "wall", -- 776
			key .. "_top", -- 776
			(left + right) * 0.5, -- 776
			top, -- 776
			width, -- 776
			capHeight, -- 776
			{ -- 776
				layer = layer - 1, -- 777
				opacity = opacity * 0.92, -- 778
				color = timber and Color(162, 126, 96, 255) or Color(158, 157, 156, 255) -- 779
			} -- 779
		) -- 779
	end -- 779
	if not assets:tryPlace( -- 779
		slot, -- 782
		key, -- 782
		(left + right) * 0.5, -- 782
		base, -- 783
		width, -- 783
		top - base, -- 783
		{layer = layer, opacity = opacity} -- 783
	) then -- 783
		draw:drawRect( -- 784
			Rect(left, base, width, top - base), -- 784
			toColor(PALETTE.steelMid, 255 * opacity), -- 785
			1, -- 785
			toColor(theme.groundRim, 150 * opacity) -- 785
		) -- 785
	end -- 785
end -- 758
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 789
	local columns = math.max( -- 793
		1, -- 793
		math.ceil(s.w / 154) -- 793
	) -- 793
	local rows = math.max( -- 794
		1, -- 794
		math.ceil(s.h / 100) -- 794
	) -- 794
	local tileW = width / columns -- 795
	local tileH = height / rows -- 796
	do -- 796
		local row = 0 -- 797
		while row < rows do -- 797
			do -- 797
				local column = 0 -- 798
				while column < columns do -- 798
					assets:tryPlace( -- 799
						"wall", -- 799
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 799
						x + (column + 0.5) * tileW, -- 800
						y + row * tileH, -- 800
						tileW + 0.5, -- 800
						tileH + 0.5, -- 800
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 801
					) -- 801
					column = column + 1 -- 798
				end -- 798
			end -- 798
			row = row + 1 -- 797
		end -- 797
	end -- 797
end -- 789
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 806
	local slot = coverArt(s) -- 813
	if not assets:tryPlace( -- 813
		slot, -- 814
		"cover_" .. tostring(s.x), -- 814
		x0 + sw * 0.5, -- 814
		y0, -- 814
		sw, -- 814
		sh, -- 814
		{layer = 1} -- 814
	) then -- 814
		fillVGradRect( -- 815
			fgDraw, -- 815
			x0, -- 815
			y0, -- 815
			sw, -- 815
			sh, -- 815
			toColor(PALETTE.steelDark), -- 815
			toColor(PALETTE.steelMid) -- 815
		) -- 815
		fgDraw:drawSegment( -- 816
			Vec2(x0, y0 + sh), -- 816
			Vec2(x0 + sw, y0 + sh), -- 816
			1.4, -- 816
			toColor(theme.groundRim) -- 816
		) -- 816
	end -- 816
	if not p.childMode and (p.coverHug or p.coverNear) then -- 816
		local plx = p.player.x -- 821
		local nearLeft = math.abs(plx - s.x) < 42 -- 822
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 823
		if nearLeft or nearRight then -- 823
			local edgeX = nearLeft and x0 - 2 or x0 + sw + 2 -- 825
			local col = p.coverHug and PALETTE.cyan or PALETTE.amber -- 826
			fgGlow:drawSegment( -- 827
				Vec2(edgeX, y0 + 4), -- 827
				Vec2(edgeX, y0 + sh + 4), -- 827
				p.coverHug and 3.5 or 2, -- 827
				toColor(col, p.coverHug and 220 or 140) -- 827
			) -- 827
			if p.coverHug then -- 827
				fillRadialGlow( -- 829
					fgGlow, -- 829
					edgeX, -- 829
					y0 + sh * 0.55, -- 829
					22, -- 829
					sh * 0.7, -- 829
					toColor(PALETTE.cyan, 85), -- 829
					Color(72, 224, 255, 0), -- 829
					14 -- 829
				) -- 829
			end -- 829
		end -- 829
	end -- 829
end -- 806
function StageRenderer.prototype.drawWinch(self, fgDraw, fgGlow, x0, y0, sw, sh, p, time) -- 835
	fillChamferBox( -- 841
		fgDraw, -- 841
		x0, -- 841
		y0, -- 841
		sw, -- 841
		sh, -- 841
		8, -- 841
		toColor(PALETTE.steelMid), -- 841
		1.5, -- 841
		toColor(PALETTE.rimSilver, 180) -- 841
	) -- 841
	local cx = x0 + sw * 0.5 -- 843
	local cy = y0 + sh * 0.55 -- 844
	local r = math.min(sw, sh) * 0.34 -- 845
	local spin = p.phase == "gate-hold" and time * 1.4 or 0 -- 846
	fgDraw:drawRing( -- 847
		Vec2(cx, cy), -- 847
		r * 0.62, -- 847
		r, -- 847
		toColor(PALETTE.steelDark), -- 847
		1.5, -- 847
		toColor(PALETTE.rimSilver, 210) -- 847
	) -- 847
	local k = 0 -- 848
	do -- 848
		k = 0 -- 849
		while k < 6 do -- 849
			local a = spin + k * math.pi / 3 -- 850
			fgDraw:drawSegment( -- 851
				Vec2( -- 852
					cx + math.cos(a) * r * 0.25, -- 852
					cy + math.sin(a) * r * 0.25 -- 852
				), -- 852
				Vec2( -- 853
					cx + math.cos(a) * r * 1.05, -- 853
					cy + math.sin(a) * r * 1.05 -- 853
				), -- 853
				2, -- 854
				toColor(PALETTE.rimSilver, 210) -- 855
			) -- 855
			k = k + 1 -- 849
		end -- 849
	end -- 849
	fgDraw:drawSegment( -- 859
		Vec2(cx, cy + r), -- 859
		Vec2(cx, y0 + sh + 220), -- 859
		1.6, -- 859
		toColor(PALETTE.steelLight, 175) -- 859
	) -- 859
	local active = p.phase == "gate-hold" or p.phase == "gate-send" -- 861
	local lampCol = active and PALETTE.cyan or PALETTE.amber -- 862
	local pulse = 0.7 + 0.3 * math.sin(time * 5) -- 863
	fgGlow:drawDot( -- 864
		Vec2(x0 + sw - 10, y0 + sh - 10), -- 864
		4, -- 864
		toColor(lampCol, 240 * pulse) -- 864
	) -- 864
	fillRadialGlow( -- 865
		fgGlow, -- 865
		x0 + sw - 10, -- 865
		y0 + sh - 10, -- 865
		22, -- 865
		22, -- 865
		toColor(lampCol, 95 * pulse), -- 865
		Color(lampCol.r, lampCol.g, lampCol.b, 0), -- 865
		12 -- 865
	) -- 865
end -- 835
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 868
	local ____temp_3 -- 876
	if p.room.story ~= nil then -- 876
		____temp_3 = p.room.story.gate -- 876
	else -- 876
		____temp_3 = nil -- 876
	end -- 876
	local g = ____temp_3 -- 876
	if g == nil then -- 876
		return -- 878
	end -- 878
	local closeFrac = 0.08 -- 881
	if p.phase == "gate-hold" then -- 881
		closeFrac = 0.08 + 0.36 * math.min( -- 883
			1, -- 883
			p.gateTick / math.max(1, g.holdTicks) -- 883
		) -- 883
	elseif p.phase == "gate-send" then -- 883
		closeFrac = 0.44 -- 885
	elseif p.phase == "gate-count" then -- 885
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 887
	elseif p.phase == "gate-walk" then -- 887
		closeFrac = 1 -- 889
	end -- 889
	local gx0 = cam:sx(848) -- 891
	local gx1 = cam:sx(1032) -- 892
	local topY = cam:sy(160) -- 893
	local botY = cam:sy(160 * (1 - closeFrac)) -- 894
	if topY > botY + 2 then -- 894
		fillVGradRect( -- 896
			fgDraw, -- 896
			gx0, -- 896
			botY, -- 896
			gx1 - gx0, -- 896
			topY - botY, -- 896
			toColor(PALETTE.steelDark), -- 896
			toColor(PALETTE.steelMid) -- 896
		) -- 896
		assets:tryPlace( -- 897
			"cover_wood", -- 897
			"gate_shutter", -- 897
			(gx0 + gx1) * 0.5, -- 897
			botY, -- 897
			gx1 - gx0, -- 898
			topY - botY, -- 898
			{layer = 6} -- 898
		) -- 898
	end -- 898
	if closeFrac < 0.98 then -- 898
		local gapH = math.max( -- 902
			8, -- 902
			botY - cam:sy(0) -- 902
		) -- 902
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 903
		fillVGradRect( -- 904
			fgGlow, -- 904
			gx0, -- 904
			cam:sy(0), -- 904
			gx1 - gx0, -- 904
			gapH, -- 904
			Color( -- 904
				140, -- 904
				210, -- 904
				255, -- 904
				math.floor(52 * pulse + 0.5) -- 904
			), -- 904
			Color(80, 160, 230, 0) -- 904
		) -- 904
	end -- 904
end -- 868
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, time) -- 908
	fillVGradRect( -- 915
		fgDraw, -- 915
		x0, -- 915
		y0, -- 915
		sw, -- 915
		sh, -- 915
		Color(15, 21, 34, 255), -- 915
		Color(32, 44, 66, 255) -- 915
	) -- 915
	fgDraw:drawRect( -- 916
		Rect(x0, y0, sw, sh), -- 916
		Color(0, 0, 0, 0), -- 916
		1.4, -- 916
		toColor(PALETTE.rimSilver, 165) -- 916
	) -- 916
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 916
		self:tileMasonry( -- 919
			assets, -- 919
			s, -- 919
			x0, -- 919
			y0, -- 919
			sw, -- 919
			sh -- 919
		) -- 919
		local ribs = 4 -- 921
		local r = 1 -- 922
		do -- 922
			r = 1 -- 923
			while r < ribs do -- 923
				local rx = x0 + sw * r / ribs -- 924
				fgDraw:drawSegment( -- 925
					Vec2(rx, y0), -- 925
					Vec2(rx, y0 + sh), -- 925
					2, -- 925
					Color(10, 15, 24, 210) -- 925
				) -- 925
				fgDraw:drawSegment( -- 926
					Vec2(rx + 2, y0), -- 926
					Vec2(rx + 2, y0 + sh), -- 926
					1, -- 926
					Color(68, 86, 114, 130) -- 926
				) -- 926
				r = r + 1 -- 923
			end -- 923
		end -- 923
		local bands = 4 -- 929
		local b = 1 -- 930
		do -- 930
			b = 1 -- 931
			while b < bands do -- 931
				local by = y0 + sh * b / bands -- 932
				fgDraw:drawSegment( -- 933
					Vec2(x0 + 4, by), -- 933
					Vec2(x0 + sw - 4, by), -- 933
					1.2, -- 933
					Color(52, 68, 92, 135) -- 933
				) -- 933
				b = b + 1 -- 931
			end -- 931
		end -- 931
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 936
		local slitY = y0 + sh * 0.56 -- 937
		local slitH = sh * 0.22 -- 938
		fgDraw:drawRect( -- 939
			Rect(slitX - 5, slitY, 10, slitH), -- 939
			Color(8, 12, 20, 245), -- 939
			1.2, -- 939
			toColor(PALETTE.amberDim, 190) -- 939
		) -- 939
		fgGlow:drawRect( -- 940
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 940
			toColor(PALETTE.amber, 190) -- 940
		) -- 940
		fillRadialGlow( -- 941
			fgGlow, -- 941
			slitX, -- 941
			slitY + slitH * 0.5, -- 941
			44, -- 941
			slitH * 0.7, -- 941
			Color(255, 206, 128, 52), -- 941
			Color(255, 180, 86, 0), -- 941
			14 -- 941
		) -- 941
	end -- 941
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 941
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 946
		local cx = x0 + sw * 0.5 -- 947
		local lampY = y0 - 8 -- 948
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 949
		if not opened then -- 949
			assets:tryPlace( -- 951
				"prop_tower_door", -- 951
				"tower_door", -- 951
				cx, -- 951
				y0 - doorHeight, -- 951
				sw, -- 951
				doorHeight, -- 951
				{layer = 2} -- 951
			) -- 951
		end -- 951
		assets:tryPlace( -- 953
			"prop_lantern", -- 953
			"tower_lantern", -- 953
			cx + sw * 0.43, -- 953
			lampY - sh * 0.36, -- 953
			sw * 0.17, -- 954
			sh * 0.84, -- 954
			{layer = 3} -- 954
		) -- 954
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 955
		local alpha = opened and 155 or 88 -- 956
		fgDraw:drawSegment( -- 958
			Vec2(x0 + 4, y0), -- 958
			Vec2(x0 + 4, y0 - sh * 3.8), -- 958
			4, -- 958
			Color(42, 52, 70, 255) -- 958
		) -- 958
		fgDraw:drawSegment( -- 959
			Vec2(x0 + sw - 4, y0), -- 959
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 959
			4, -- 959
			Color(42, 52, 70, 255) -- 959
		) -- 959
		fgDraw:drawSegment( -- 960
			Vec2(x0, y0), -- 960
			Vec2(x0 + sw, y0), -- 960
			2.5, -- 960
			toColor(PALETTE.amber, 210) -- 960
		) -- 960
		fillVGradRect( -- 962
			fgGlow, -- 963
			x0 + 6, -- 964
			y0 - sh * 3.8, -- 965
			sw - 12, -- 966
			sh * 3.8, -- 967
			Color( -- 968
				255, -- 968
				206, -- 968
				128, -- 968
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 968
			), -- 968
			Color(255, 224, 168, opened and 180 or 62) -- 969
		) -- 969
		fillRadialGlow( -- 971
			fgGlow, -- 971
			cx, -- 971
			lampY, -- 971
			opened and 105 or 58, -- 971
			opened and 105 or 58, -- 971
			Color( -- 971
				255, -- 971
				232, -- 971
				178, -- 971
				math.floor(170 * pulse + 0.5) -- 971
			), -- 971
			Color(255, 180, 86, 0), -- 971
			18 -- 971
		) -- 971
		fgDraw:drawCircle( -- 972
			Vec2(cx, lampY), -- 972
			5.5, -- 972
			toColor(PALETTE.amberCore) -- 972
		) -- 972
	end -- 972
end -- 908
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 976
	local blades = math.max( -- 983
		12, -- 983
		math.floor(sw / 8) -- 983
	) -- 983
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 984
	local k = 0 -- 985
	do -- 985
		k = 0 -- 986
		while k < blades do -- 986
			local t = (k + 0.5) / blades -- 987
			local bx = x0 + sw * t -- 988
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 989
			local bh = sh * hRatio * 1.95 -- 990
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 991
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 992
			fgDraw:drawPolygon( -- 993
				{ -- 993
					Vec2(bx - 7, y0), -- 994
					Vec2(bx + 7, y0), -- 995
					Vec2(bx + sway, y0 + bh) -- 996
				}, -- 996
				col -- 997
			) -- 997
			k = k + 1 -- 986
		end -- 986
	end -- 986
	if nearPlayer then -- 986
		fgGlow:drawSegment( -- 1000
			Vec2(x0, y0 + 2), -- 1000
			Vec2(x0 + sw, y0 + 2), -- 1000
			2, -- 1000
			toColor(PALETTE.emerald, 145) -- 1000
		) -- 1000
	end -- 1000
end -- 976
function StageRenderer.prototype.drawArch(self, fgDraw, fgGlow, p, cam, theme) -- 1004
	local a = p.room.arch -- 1011
	if a.h <= 0 or a.x1 <= a.x0 then -- 1011
		return -- 1013
	end -- 1013
	local x0 = cam:sx(a.x0) -- 1015
	local x1 = cam:sx(a.x1) -- 1016
	local y0 = cam:sy(a.y) -- 1017
	local y1 = cam:sy(a.y + a.h) -- 1018
	local aw = x1 - x0 -- 1019
	local ah = y1 - y0 -- 1020
	fgDraw:drawRect( -- 1023
		Rect(x0, y0, aw, ah), -- 1023
		Color(5, 7, 11, 245) -- 1023
	) -- 1023
	fgDraw:drawSegment( -- 1025
		Vec2(x0, y0), -- 1025
		Vec2(x0, y1), -- 1025
		3, -- 1025
		toColor(PALETTE.rimSilver, 215) -- 1025
	) -- 1025
	fgDraw:drawSegment( -- 1026
		Vec2(x1, y0), -- 1026
		Vec2(x1, y1), -- 1026
		3, -- 1026
		toColor(PALETTE.rimSilver, 215) -- 1026
	) -- 1026
	fgDraw:drawSegment( -- 1027
		Vec2(x0 - 4, y1), -- 1027
		Vec2(x1 + 4, y1), -- 1027
		3.2, -- 1027
		toColor(PALETTE.rimSilver, 235) -- 1027
	) -- 1027
	if p.room.key == "outside" then -- 1027
		local arcR = math.min(aw * 0.46, ah * 0.72) -- 1030
		fgDraw:drawArc( -- 1031
			Vec2((x0 + x1) * 0.5, y1 - arcR - 2), -- 1031
			arcR, -- 1031
			0, -- 1031
			180, -- 1031
			2.2, -- 1031
			toColor(theme.accent, 195) -- 1031
		) -- 1031
		fillVGradRect( -- 1032
			fgGlow, -- 1032
			x0 + 6, -- 1032
			y0, -- 1032
			aw - 12, -- 1032
			ah * 0.65, -- 1032
			Color(86, 186, 236, 52), -- 1032
			Color(86, 186, 236, 0) -- 1032
		) -- 1032
	end -- 1032
end -- 1004
return ____exports -- 1004