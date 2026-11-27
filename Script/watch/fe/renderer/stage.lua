-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____depth = require("Script.watch.depth") -- 5
local LANE_DEPTH = ____depth.LANE_DEPTH -- 5
local ____occlusion = require("Script.watch.fe.occlusion") -- 9
local depthOrder = ____occlusion.depthOrder -- 9
local occlusionTint = ____occlusion.occlusionTint -- 9
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 11
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
	if solid.art == "gate_post" or solid.art == "wall" or solid.art == "latch" then -- 39
		return "wall" -- 40
	end -- 40
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 42
		return "cover_wood" -- 43
	end -- 43
	if solid.art == "fence" then -- 45
		return "fence" -- 46
	end -- 46
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 48
end -- 38
____exports.StageRenderer = __TS__Class() -- 51
local StageRenderer = ____exports.StageRenderer -- 51
StageRenderer.name = "StageRenderer" -- 51
function StageRenderer.prototype.____constructor(self) -- 51
end -- 51
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 53
	local w = cam.viewW -- 61
	local h = cam.viewH -- 62
	local theme = themeOf(p.room.key) -- 63
	local seed = roomSeed(p.room.key) -- 64
	local span = math.max(1, p.room.maxX - p.room.minX) -- 66
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 67
	local backdropKey = theme.backdropKey or p.room.key -- 68
	local farSlot = "bgFar_" .. backdropKey -- 69
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 72
	local artH = artW * 9 / 16 -- 73
	local artY = math.min( -- 74
		0, -- 74
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 74
	) -- 74
	if assets:tryPlace( -- 75
		farSlot, -- 75
		"scene", -- 75
		w * (0.5 - progress * 0.08), -- 75
		artY, -- 75
		artW, -- 75
		artH -- 75
	) then -- 75
		self:drawDressing(assets, backdropKey, cam, progress) -- 76
		local y = cam.groundScreenY -- 77
		fillVGradRect( -- 78
			bgDraw, -- 78
			0, -- 78
			0, -- 78
			w, -- 78
			h, -- 78
			toColor(PALETTE.voidDark), -- 78
			toColor(theme.skyMid) -- 78
		) -- 78
		fillVGradRect( -- 79
			bgGlow, -- 79
			0, -- 79
			y - 1, -- 79
			w, -- 79
			h * 0.14, -- 79
			Color(43, 49, 63, 15), -- 79
			Color(43, 49, 63, 0) -- 79
		) -- 79
		return -- 80
	end -- 80
	local splitY = h * 0.46 -- 84
	fillVGradRect( -- 85
		bgDraw, -- 85
		0, -- 85
		splitY, -- 85
		w, -- 85
		h - splitY, -- 85
		toColor(theme.skyMid), -- 85
		toColor(theme.skyTop) -- 85
	) -- 85
	fillVGradRect( -- 86
		bgDraw, -- 86
		0, -- 86
		0, -- 86
		w, -- 86
		splitY, -- 86
		toColor(theme.skyHorizon), -- 86
		toColor(theme.skyMid) -- 86
	) -- 86
	if theme.showMoon then -- 89
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 90
		local my = h * theme.moonYFrac -- 91
		local mr = math.max(18, h * 0.044) -- 92
		fillRadialGlow( -- 93
			bgGlow, -- 93
			mx, -- 93
			my, -- 93
			mr * 6.2, -- 93
			mr * 6.2, -- 93
			Color(140, 200, 255, 28), -- 93
			Color(20, 40, 80, 0), -- 93
			22 -- 93
		) -- 93
		fillRadialGlow( -- 94
			bgGlow, -- 94
			mx, -- 94
			my, -- 94
			mr * 2.4, -- 94
			mr * 2.4, -- 94
			Color(200, 232, 255, 64), -- 94
			Color(80, 140, 210, 0), -- 94
			18 -- 94
		) -- 94
		bgDraw:drawCircle( -- 95
			Vec2(mx, my), -- 95
			mr, -- 95
			Color(224, 238, 252, 230) -- 95
		) -- 95
		bgDraw:drawCircle( -- 97
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 97
			mr * 0.84, -- 97
			toColor(theme.skyTop, 110) -- 97
		) -- 97
	end -- 97
	if p.room.key == "forest" then -- 100
		self:drawFarForest( -- 101
			bgDraw, -- 101
			w, -- 101
			h, -- 101
			cam, -- 101
			theme, -- 101
			seed -- 101
		) -- 101
		self:drawMidForest( -- 102
			bgDraw, -- 102
			bgGlow, -- 102
			w, -- 102
			h, -- 102
			cam, -- 102
			theme, -- 102
			time, -- 102
			seed -- 102
		) -- 102
	else -- 102
		self:drawFarCity( -- 104
			bgDraw, -- 104
			bgGlow, -- 104
			w, -- 104
			h, -- 104
			cam, -- 104
			theme, -- 104
			seed -- 104
		) -- 104
		self:drawMidArchitecture( -- 105
			bgDraw, -- 105
			bgGlow, -- 105
			w, -- 105
			h, -- 105
			cam, -- 105
			theme, -- 105
			time, -- 105
			seed -- 105
		) -- 105
	end -- 105
	if theme.showSearchlights then -- 107
		self:drawSearchlights( -- 108
			bgGlow, -- 108
			w, -- 108
			h, -- 108
			cam, -- 108
			theme, -- 108
			time, -- 108
			seed -- 108
		) -- 108
	end -- 108
	if theme.showTowerBeacon then -- 110
		self:drawDistantNorthTower( -- 111
			bgDraw, -- 111
			bgGlow, -- 111
			w, -- 111
			h, -- 111
			cam, -- 111
			p, -- 111
			time -- 111
		) -- 111
	end -- 111
	local fogH = h * 0.38 -- 115
	fillVGradRect( -- 116
		bgGlow, -- 117
		0, -- 118
		cam.groundScreenY - 10, -- 119
		w, -- 120
		fogH, -- 121
		toColor(theme.fogBottom), -- 122
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 123
	) -- 123
end -- 53
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 127
	local w = cam.viewW -- 128
	local ground = cam.groundScreenY -- 129
	local x = w * (0.76 - progress * 0.22) -- 130
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 132
		assets:tryPlace( -- 133
			"pine", -- 133
			"mid_pine", -- 133
			x, -- 133
			ground - cam:len(6), -- 133
			cam:len(122), -- 133
			cam:len(107), -- 133
			{layer = 1, opacity = 0.5} -- 134
		) -- 134
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 135
		assets:tryPlace( -- 136
			"eaves", -- 136
			"mid_eaves", -- 136
			x, -- 136
			ground - cam:len(4), -- 136
			cam:len(176), -- 136
			cam:len(96), -- 136
			{layer = 1, opacity = 0.44} -- 137
		) -- 137
	else -- 137
		assets:tryPlace( -- 139
			"cover_stone", -- 139
			"mid_ruin", -- 139
			x, -- 139
			ground - cam:len(4), -- 139
			cam:len(114), -- 139
			cam:len(50), -- 139
			{layer = 1, opacity = 0.44} -- 140
		) -- 140
	end -- 140
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 142
		assets:tryPlace( -- 143
			"prop_lantern", -- 143
			"mid_lantern", -- 143
			w * (0.27 - progress * 0.18), -- 143
			ground + cam:len(96), -- 144
			cam:len(20), -- 144
			cam:len(28), -- 144
			{layer = 2, opacity = 0.82} -- 144
		) -- 144
	end -- 144
end -- 127
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 149
	local theme = themeOf("checkpoint") -- 156
	local splitY = h * 0.44 -- 157
	fillVGradRect( -- 158
		bgDraw, -- 158
		0, -- 158
		splitY, -- 158
		w, -- 158
		h - splitY, -- 158
		toColor(theme.skyMid), -- 158
		toColor(theme.skyTop) -- 158
	) -- 158
	fillVGradRect( -- 159
		bgDraw, -- 159
		0, -- 159
		0, -- 159
		w, -- 159
		splitY, -- 159
		toColor(theme.skyHorizon), -- 159
		toColor(theme.skyMid) -- 159
	) -- 159
	local mx = w * 0.61 -- 162
	local my = h * 0.74 -- 163
	local mr = h * 0.072 -- 164
	fillRadialGlow( -- 165
		bgGlow, -- 165
		mx, -- 165
		my, -- 165
		mr * 4.4, -- 165
		mr * 4.4, -- 165
		Color(164, 184, 198, 28), -- 165
		Color(16, 22, 34, 0), -- 165
		22 -- 165
	) -- 165
	fillRadialGlow( -- 166
		bgGlow, -- 166
		mx, -- 166
		my, -- 166
		mr * 1.9, -- 166
		mr * 1.9, -- 166
		Color(214, 224, 232, 62), -- 166
		Color(36, 48, 64, 0), -- 166
		18 -- 166
	) -- 166
	bgDraw:drawCircle( -- 167
		Vec2(mx, my), -- 167
		mr, -- 167
		Color(234, 238, 236, 225) -- 167
	) -- 167
	bgDraw:drawCircle( -- 168
		Vec2(mx + mr * 0.24, my + mr * 0.14), -- 168
		mr * 0.85, -- 168
		Color(14, 18, 28, 118) -- 168
	) -- 168
	local groundY = h * 0.19 -- 171
	local i = 0 -- 172
	do -- 172
		i = 0 -- 173
		while i < 14 do -- 173
			local bx = i * (w / 12) - 24 + math.sin(time * 0.06) * 4 -- 174
			local bw = 58 + hash01(i * 13 + 3) * 82 -- 175
			local bh = h * (0.14 + hash01(i * 29 + 7) * 0.22) -- 176
			local ridgeH = 14 + hash01(i * 19) * 18 -- 177
			bgDraw:drawPolygon( -- 178
				{ -- 178
					Vec2(bx, groundY), -- 179
					Vec2(bx + bw, groundY), -- 180
					Vec2(bx + bw, groundY + bh), -- 181
					Vec2(bx + bw * 0.5, groundY + bh + ridgeH), -- 182
					Vec2(bx, groundY + bh) -- 183
				}, -- 183
				Color(14, 18, 26, 255) -- 184
			) -- 184
			i = i + 1 -- 173
		end -- 173
	end -- 173
	local tx = w * 0.83 -- 188
	local ty0 = groundY -- 189
	local ty1 = h * 0.58 -- 190
	bgDraw:drawPolygon( -- 191
		{ -- 191
			Vec2(tx - 24, ty0), -- 192
			Vec2(tx + 24, ty0), -- 193
			Vec2(tx + 15, ty1), -- 194
			Vec2(tx - 15, ty1) -- 195
		}, -- 195
		Color(18, 23, 34, 255), -- 196
		1.1, -- 196
		Color(72, 84, 98, 130) -- 196
	) -- 196
	bgDraw:drawPolygon( -- 197
		{ -- 197
			Vec2(tx - 32, ty1), -- 198
			Vec2(tx + 32, ty1), -- 199
			Vec2(tx, ty1 + 26) -- 200
		}, -- 200
		Color(24, 30, 42, 255) -- 201
	) -- 201
	local pulse = 0.82 + 0.18 * math.sin(time * 2.2) -- 202
	local lampY = ty1 - 14 -- 203
	fillRadialGlow( -- 204
		bgGlow, -- 204
		tx, -- 204
		lampY, -- 204
		64 * pulse, -- 204
		64 * pulse, -- 204
		Color(238, 198, 128, 118), -- 204
		Color(214, 162, 86, 0), -- 204
		18 -- 204
	) -- 204
	bgGlow:drawDot( -- 205
		Vec2(tx, lampY), -- 205
		4.2, -- 205
		Color(252, 240, 206, 245) -- 205
	) -- 205
	fillVGradRect( -- 208
		bgDraw, -- 208
		0, -- 208
		0, -- 208
		w, -- 208
		groundY, -- 208
		Color(9, 11, 17, 255), -- 208
		Color(20, 24, 34, 255) -- 208
	) -- 208
	bgDraw:drawSegment( -- 209
		Vec2(0, groundY), -- 209
		Vec2(w, groundY), -- 209
		1.4, -- 209
		toColor(PALETTE.silkDim, 145) -- 209
	) -- 209
	fillVGradRect( -- 210
		bgGlow, -- 210
		0, -- 210
		groundY, -- 210
		w, -- 210
		h * 0.18, -- 210
		Color(46, 56, 72, 42), -- 210
		Color(20, 26, 38, 0) -- 210
	) -- 210
	local sx = w * 0.64 -- 213
	bgDraw:drawPolygon( -- 214
		{ -- 214
			Vec2(sx - 24, groundY + 14), -- 215
			Vec2(sx + 14, groundY + 18), -- 216
			Vec2(sx + 16, groundY + 116), -- 217
			Vec2(sx - 16, groundY + 116) -- 218
		}, -- 218
		Color(14, 18, 26, 255), -- 219
		1.1, -- 219
		Color(118, 132, 144, 125) -- 219
	) -- 219
	bgDraw:drawSegment( -- 220
		Vec2(sx - 5, groundY + 46), -- 220
		Vec2(sx - 10, groundY + 2), -- 220
		5.5, -- 220
		Color(12, 16, 24, 255) -- 220
	) -- 220
	bgDraw:drawSegment( -- 221
		Vec2(sx + 6, groundY + 46), -- 221
		Vec2(sx + 12, groundY + 2), -- 221
		5.5, -- 221
		Color(16, 20, 30, 255) -- 221
	) -- 221
	bgDraw:drawCircle( -- 222
		Vec2(sx + 1, groundY + 132), -- 222
		11, -- 222
		Color(18, 22, 32, 255) -- 222
	) -- 222
	bgDraw:drawPolygon( -- 223
		{ -- 223
			Vec2(sx - 18, groundY + 135), -- 224
			Vec2(sx + 20, groundY + 135), -- 225
			Vec2(sx + 1, groundY + 148) -- 226
		}, -- 226
		Color(44, 50, 58, 250) -- 227
	) -- 227
	bgDraw:drawSegment( -- 228
		Vec2(sx + 4, groundY + 96), -- 228
		Vec2(sx + 46, groundY + 88), -- 228
		3, -- 228
		Color(78, 56, 40, 255) -- 228
	) -- 228
	local cx = w * 0.725 -- 230
	bgDraw:drawPolygon( -- 231
		{ -- 231
			Vec2(cx - 18, groundY + 14), -- 232
			Vec2(cx + 16, groundY + 14), -- 233
			Vec2(cx + 11, groundY + 78), -- 234
			Vec2(cx - 11, groundY + 78) -- 235
		}, -- 235
		Color(148, 108, 66, 236), -- 236
		1.2, -- 236
		Color(214, 186, 146, 195) -- 236
	) -- 236
	bgDraw:drawSegment( -- 237
		Vec2(cx - 4, groundY + 22), -- 237
		Vec2(cx - 5, groundY + 2), -- 237
		3.8, -- 237
		Color(24, 20, 24, 255) -- 237
	) -- 237
	bgDraw:drawSegment( -- 238
		Vec2(cx + 4, groundY + 22), -- 238
		Vec2(cx + 5, groundY + 2), -- 238
		3.8, -- 238
		Color(30, 26, 30, 255) -- 238
	) -- 238
	bgDraw:drawCircle( -- 239
		Vec2(cx + 1, groundY + 88), -- 239
		10, -- 239
		Color(212, 192, 168, 240) -- 239
	) -- 239
	fillRadialGlow( -- 240
		bgGlow, -- 240
		cx + 10, -- 240
		groundY + 52, -- 240
		26, -- 240
		26, -- 240
		Color(238, 198, 128, 96), -- 240
		Color(214, 162, 86, 0), -- 240
		14 -- 240
	) -- 240
	bgGlow:drawDot( -- 241
		Vec2(cx + 10, groundY + 52), -- 241
		2.8, -- 241
		Color(252, 238, 202, 240) -- 241
	) -- 241
end -- 149
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 245
	local theme = themeOf(p.room.key) -- 255
	self:drawFloors( -- 256
		fgDraw, -- 256
		assets, -- 256
		p, -- 256
		cam, -- 256
		theme -- 256
	) -- 256
	self:drawStairs( -- 257
		fgDraw, -- 257
		fgGlow, -- 257
		assets, -- 257
		p, -- 257
		cam, -- 257
		theme -- 257
	) -- 257
	self:drawSolids( -- 258
		fgDraw, -- 258
		fgGlow, -- 258
		assets, -- 258
		p, -- 258
		cam, -- 258
		theme, -- 258
		time, -- 258
		occlusion, -- 258
		fadeDt -- 258
	) -- 258
	if p.room.key == "gate" then -- 259
		self:drawGateShutter( -- 260
			fgDraw, -- 260
			fgGlow, -- 260
			assets, -- 260
			p, -- 260
			cam, -- 260
			time -- 260
		) -- 260
	end -- 260
	self:drawArch(fgDraw, p, cam) -- 262
end -- 245
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 266
	local seed = roomSeed(p.room.key) -- 273
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 275
	local span = 520 -- 276
	local startIdx = math.floor((-parallax - 200) / span) -- 277
	local idx = startIdx -- 278
	do -- 278
		idx = startIdx -- 279
		while idx <= startIdx + 4 do -- 279
			local x = idx * span + parallax -- 280
			local r = hash01(seed + idx * 17) -- 281
			local bw = 70 + r * 90 -- 282
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 283
			fgDraw:drawPolygon( -- 284
				{ -- 284
					Vec2(x, 0), -- 285
					Vec2(x + bw, 0), -- 286
					Vec2(x + bw - 18, bh), -- 287
					Vec2(x + 12, bh * 0.72) -- 288
				}, -- 288
				Color(4, 6, 11, 225) -- 289
			) -- 289
			idx = idx + 1 -- 279
		end -- 279
	end -- 279
	fillVGradRect( -- 293
		fgDraw, -- 293
		0, -- 293
		h - h * 0.16, -- 293
		w, -- 293
		h * 0.16, -- 293
		Color(4, 6, 12, 0), -- 293
		Color(4, 6, 12, 138) -- 293
	) -- 293
	fillVGradRect( -- 294
		fgDraw, -- 294
		0, -- 294
		0, -- 294
		w, -- 294
		h * 0.13, -- 294
		Color(4, 6, 12, 185), -- 294
		Color(4, 6, 12, 0) -- 294
	) -- 294
end -- 266
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 297
	local count = 3 -- 306
	local i = 0 -- 307
	do -- 307
		i = 0 -- 308
		while i < count do -- 308
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 309
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 310
			local by = cam.groundScreenY * 0.85 -- 311
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 312
			local ang = math.pi * 0.5 + sway -- 313
			local len = h * 1.15 -- 314
			local halfSpread = 0.065 + i % 2 * 0.025 -- 315
			local x1 = bx + math.cos(ang - halfSpread) * len -- 316
			local y1 = by + math.sin(ang - halfSpread) * len -- 317
			local x2 = bx + math.cos(ang + halfSpread) * len -- 318
			local y2 = by + math.sin(ang + halfSpread) * len -- 319
			local c0 = toColor(theme.beamColor) -- 320
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 321
			bgGlow:drawVertices({ -- 322
				{ -- 323
					Vec2(bx, by), -- 323
					c0 -- 323
				}, -- 323
				{ -- 324
					Vec2(x1, y1), -- 324
					c1 -- 324
				}, -- 324
				{ -- 325
					Vec2(x2, y2), -- 325
					c1 -- 325
				} -- 325
			}) -- 325
			i = i + 1 -- 308
		end -- 308
	end -- 308
end -- 297
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 330
	local baseY = cam.groundScreenY - 8 -- 339
	local shift = -cam.x * 0.2 * cam.ppu -- 340
	local colW = 108 -- 341
	local first = math.floor((-shift - colW) / colW) -- 342
	local count = math.ceil(w / colW) + 3 -- 343
	local i = 0 -- 344
	do -- 344
		i = 0 -- 345
		while i < count do -- 345
			local idx = first + i -- 346
			local r1 = hash01(seed + idx * 13.7) -- 347
			local r2 = hash01(seed + idx * 29.3) -- 348
			local r3 = hash01(seed + idx * 47.1) -- 349
			local x = idx * colW + shift -- 350
			local bw = colW * (0.68 + r1 * 0.44) -- 351
			local bh = h * (0.18 + r2 * 0.38) -- 352
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 353
			bgDraw:drawPolygon( -- 355
				{ -- 355
					Vec2(x, baseY), -- 356
					Vec2(x + bw, baseY), -- 357
					Vec2(x + bw, baseY + bh - cut), -- 358
					Vec2(x + bw - cut, baseY + bh), -- 359
					Vec2(x, baseY + bh) -- 360
				}, -- 360
				toColor(theme.farBuilding) -- 361
			) -- 361
			if r3 > 0.62 then -- 364
				local ax = x + bw * 0.25 -- 365
				bgDraw:drawSegment( -- 366
					Vec2(ax, baseY + bh), -- 366
					Vec2(ax, baseY + bh + 32), -- 366
					1.2, -- 366
					toColor(theme.farBuilding) -- 366
				) -- 366
				if r1 > 0.6 then -- 367
					bgGlow:drawDot( -- 368
						Vec2(ax, baseY + bh + 32), -- 368
						2.2, -- 368
						toColor(theme.accent, 145) -- 368
					) -- 368
				end -- 368
			end -- 368
			if r2 > 0.55 then -- 372
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 373
				bgGlow:drawSegment( -- 374
					Vec2(x + 12, wy), -- 374
					Vec2(x + bw - 14, wy), -- 374
					1.1, -- 374
					toColor(theme.accent, 64) -- 374
				) -- 374
			end -- 374
			i = i + 1 -- 345
		end -- 345
	end -- 345
end -- 330
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 379
	local baseY = cam.groundScreenY - 8 -- 387
	local shift = -cam.x * 0.22 * cam.ppu -- 388
	local step = 76 -- 389
	local first = math.floor((-shift - step) / step) -- 390
	local count = math.ceil(w / step) + 4 -- 391
	local i = 0 -- 392
	do -- 392
		i = 0 -- 393
		while i < count do -- 393
			local idx = first + i -- 394
			local r1 = hash01(seed + idx * 11.3) -- 395
			local r2 = hash01(seed + idx * 23.9) -- 396
			local cx = idx * step + shift -- 397
			local tw = 34 + r1 * 38 -- 398
			local th = h * (0.24 + r2 * 0.34) -- 399
			bgDraw:drawPolygon( -- 401
				{ -- 401
					Vec2(cx - tw, baseY), -- 402
					Vec2(cx + tw, baseY), -- 403
					Vec2(cx, baseY + th) -- 404
				}, -- 404
				toColor(theme.farBuilding) -- 405
			) -- 405
			bgDraw:drawPolygon( -- 406
				{ -- 406
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 407
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 408
					Vec2(cx, baseY + th * 1.12) -- 409
				}, -- 409
				toColor(theme.farBuilding) -- 410
			) -- 410
			i = i + 1 -- 393
		end -- 393
	end -- 393
end -- 379
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 414
	local baseY = cam.groundScreenY - 4 -- 424
	local shift = -cam.x * 0.48 * cam.ppu -- 425
	local bay = 240 -- 426
	local first = math.floor((-shift - bay) / bay) -- 427
	local count = math.ceil(w / bay) + 3 -- 428
	local col = toColor(theme.midBuilding) -- 429
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 430
	local i = 0 -- 432
	do -- 432
		i = 0 -- 433
		while i < count do -- 433
			local idx = first + i -- 434
			local r = hash01(seed + idx * 37.3) -- 435
			local x = idx * bay + shift -- 436
			local colH = h * (0.34 + r * 0.24) -- 437
			local pw = 22 + r * 16 -- 438
			bgDraw:drawRect( -- 441
				Rect(x, baseY, pw, colH), -- 441
				col -- 441
			) -- 441
			bgDraw:drawSegment( -- 442
				Vec2(x + pw, baseY), -- 442
				Vec2(x + pw, baseY + colH), -- 442
				1, -- 442
				edge -- 442
			) -- 442
			if r > 0.35 then -- 443
				local beamY = baseY + colH * 0.76 -- 444
				bgDraw:drawSegment( -- 445
					Vec2(x + pw, beamY), -- 445
					Vec2(x + bay, beamY), -- 445
					4, -- 445
					col -- 445
				) -- 445
				bgDraw:drawSegment( -- 446
					Vec2(x + pw, beamY - 22), -- 446
					Vec2(x + bay * 0.5, beamY), -- 446
					1.4, -- 446
					edge -- 446
				) -- 446
				bgDraw:drawSegment( -- 447
					Vec2(x + bay * 0.5, beamY), -- 447
					Vec2(x + bay, beamY - 22), -- 447
					1.4, -- 447
					edge -- 447
				) -- 447
			end -- 447
			bgDraw:drawQuadraticBezier( -- 451
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 452
				Vec2( -- 453
					x + bay * 0.5, -- 453
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 453
				), -- 453
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 454
				1, -- 455
				Color(12, 18, 28, 180) -- 456
			) -- 456
			if idx & 1 == 0 then -- 460
				local lx = x + bay * 0.52 -- 461
				local ly = baseY + h * 0.31 -- 462
				bgDraw:drawSegment( -- 463
					Vec2(lx, baseY), -- 463
					Vec2(lx, ly), -- 463
					2.2, -- 463
					col -- 463
				) -- 463
				bgDraw:drawSegment( -- 464
					Vec2(lx, ly), -- 464
					Vec2(lx + 18, ly - 4), -- 464
					2, -- 464
					col -- 464
				) -- 464
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 465
				local lc = theme.accent -- 466
				bgGlow:drawDot( -- 467
					Vec2(lx + 18, ly - 5), -- 467
					3.2, -- 467
					toColor(lc, 210 * flicker) -- 467
				) -- 467
				fillRadialGlow( -- 468
					bgGlow, -- 468
					lx + 18, -- 468
					ly - 5, -- 468
					36, -- 468
					36, -- 468
					toColor(lc, 54 * flicker), -- 468
					Color(lc.r, lc.g, lc.b, 0), -- 468
					14 -- 468
				) -- 468
				bgGlow:drawVertices({ -- 469
					{ -- 470
						Vec2(lx + 18, ly - 6), -- 470
						toColor(lc, 38 * flicker) -- 470
					}, -- 470
					{ -- 471
						Vec2(lx - 42, baseY), -- 471
						Color(lc.r, lc.g, lc.b, 0) -- 471
					}, -- 471
					{ -- 472
						Vec2(lx + 78, baseY), -- 472
						Color(lc.r, lc.g, lc.b, 0) -- 472
					} -- 472
				}) -- 472
			end -- 472
			i = i + 1 -- 433
		end -- 433
	end -- 433
end -- 414
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 478
	local baseY = cam.groundScreenY - 4 -- 488
	local shift = -cam.x * 0.52 * cam.ppu -- 489
	local span = 156 -- 490
	local first = math.floor((-shift - span) / span) -- 491
	local count = math.ceil(w / span) + 3 -- 492
	local col = toColor(theme.midBuilding) -- 493
	local i = 0 -- 495
	do -- 495
		i = 0 -- 496
		while i < count do -- 496
			local idx = first + i -- 497
			local r = hash01(seed + idx * 19.7) -- 498
			local x = idx * span + shift -- 499
			local trunkW = 14 + r * 14 -- 500
			local sway = math.sin(time * 0.9 + idx) * 4 -- 501
			bgDraw:drawPolygon( -- 502
				{ -- 502
					Vec2(x - trunkW * 0.5, baseY), -- 503
					Vec2(x + trunkW * 0.5, baseY), -- 504
					Vec2(x + trunkW * 0.25 + sway, h), -- 505
					Vec2(x - trunkW * 0.3 + sway, h) -- 506
				}, -- 506
				col -- 507
			) -- 507
			if idx % 3 == 0 then -- 509
				bgGlow:drawVertices({ -- 510
					{ -- 511
						Vec2(x + 40, h), -- 511
						Color(110, 232, 200, 26) -- 511
					}, -- 511
					{ -- 512
						Vec2(x + 115, h), -- 512
						Color(110, 232, 200, 0) -- 512
					}, -- 512
					{ -- 513
						Vec2(x - 60, baseY), -- 513
						Color(110, 232, 200, 0) -- 513
					} -- 513
				}) -- 513
			end -- 513
			i = i + 1 -- 496
		end -- 496
	end -- 496
end -- 478
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 519
	local scale = 0.55 -- 529
	if p.room.key == "village" then -- 530
		scale = 0.72 -- 531
	elseif p.room.key == "forest" then -- 532
		scale = 0.92 -- 533
	elseif p.room.key == "tower" then -- 534
		scale = 1.15 -- 535
	end -- 535
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 537
	local baseY = cam.groundScreenY - 8 -- 538
	local towerH = h * 0.42 * scale -- 539
	local bw = 20 * scale -- 540
	bgDraw:drawPolygon( -- 541
		{ -- 541
			Vec2(tx - bw, baseY), -- 542
			Vec2(tx + bw, baseY), -- 543
			Vec2(tx + bw * 0.45, baseY + towerH), -- 544
			Vec2(tx - bw * 0.45, baseY + towerH) -- 545
		}, -- 545
		Color(14, 24, 38, 240) -- 546
	) -- 546
	bgDraw:drawSegment( -- 547
		Vec2(tx, baseY + towerH), -- 547
		Vec2(tx, baseY + towerH + 28 * scale), -- 547
		1.8, -- 547
		Color(180, 210, 238, 200) -- 547
	) -- 547
	local topY = baseY + towerH + 24 * scale -- 549
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 550
	fillRadialGlow( -- 551
		bgGlow, -- 551
		tx, -- 551
		topY, -- 551
		56 * scale * pulse, -- 551
		56 * scale * pulse, -- 551
		Color(255, 224, 152, 118), -- 551
		Color(255, 190, 96, 0), -- 551
		18 -- 551
	) -- 551
	bgGlow:drawDot( -- 552
		Vec2(tx, topY), -- 552
		3.6 * scale, -- 552
		Color(255, 246, 220, 255) -- 552
	) -- 552
end -- 519
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 555
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 562
	do -- 562
		local i = 0 -- 563
		while i < #p.room.floors do -- 563
			local floor = p.room.floors[i + 1] -- 564
			local left = cam:sx(floor.x0) -- 565
			local right = cam:sx(floor.x1) -- 566
			local isMain = floor.y <= 0.1 -- 567
			local ____isMain_0 -- 568
			if isMain then -- 568
				____isMain_0 = p.room.depth -- 568
			else -- 568
				____isMain_0 = nil -- 568
			end -- 568
			local road = ____isMain_0 -- 568
			local top = cam:sy(floor.y, road and road.min or 0) -- 569
			if road ~= nil then -- 570
				self:drawRoad( -- 571
					fgDraw, -- 571
					assets, -- 571
					i, -- 571
					left, -- 571
					right, -- 571
					top, -- 571
					cam:sy(floor.y, road.max), -- 571
					cam, -- 571
					theme -- 571
				) -- 571
			end -- 571
			local height = cam:len(isMain and 22 or 12) -- 573
			local bottom = top - height -- 574
			if isMain and bottom > 0 then -- 575
				fillVGradRect( -- 576
					fgDraw, -- 576
					left, -- 576
					0, -- 576
					right - left, -- 576
					bottom + 1, -- 576
					toColor(PALETTE.voidDark), -- 577
					toColor(theme.groundBody) -- 577
				) -- 577
			end -- 577
			fgDraw:drawRect( -- 579
				Rect(left, bottom, right - left, height), -- 579
				toColor(PALETTE.steelDark) -- 579
			) -- 579
			local step = cam:len(96) -- 580
			local start = math.max( -- 581
				0, -- 581
				math.floor(-left / step) -- 581
			) -- 581
			do -- 581
				local j = start -- 582
				while left + j * step < math.min(right, cam.viewW) do -- 582
					local x = left + j * step -- 583
					local width = math.min(step, right - x) -- 584
					assets:tryPlace( -- 585
						"slab", -- 585
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 585
						x + width * 0.5, -- 585
						bottom, -- 585
						width, -- 585
						height -- 585
					) -- 585
					if grass and isMain and j % 3 == 1 then -- 586
						assets:tryPlace( -- 587
							"grass_low", -- 587
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 587
							x + width * 0.5, -- 587
							top - cam:len(3), -- 588
							width * 0.74, -- 588
							cam:len(13), -- 588
							{opacity = 0.83, layer = 1} -- 588
						) -- 588
					end -- 588
					j = j + 1 -- 582
				end -- 582
			end -- 582
			fgDraw:drawSegment( -- 591
				Vec2(left, top), -- 591
				Vec2(right, top), -- 591
				1, -- 591
				toColor(theme.groundRim, 140) -- 591
			) -- 591
			i = i + 1 -- 563
		end -- 563
	end -- 563
end -- 555
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 595
	local width = right - left -- 600
	local height = back - front -- 601
	if width <= 1 or height <= 1 then -- 602
		return -- 603
	end -- 603
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 606
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 607
	fillVGradRect( -- 608
		draw, -- 608
		left, -- 608
		front, -- 608
		width, -- 608
		height, -- 608
		toColor(nearCol), -- 608
		toColor(farCol) -- 608
	) -- 608
	local bands = { -- 610
		0, -- 610
		0.3, -- 610
		0.58, -- 610
		0.81, -- 610
		1 -- 610
	} -- 610
	local jointDark = Color(14, 17, 22, 115) -- 611
	local jointHi = toColor(theme.groundRim, 36) -- 612
	local visLeft = math.max(left, -40) -- 613
	local visRight = math.min(right, cam.viewW + 40) -- 614
	do -- 614
		local row = 0 -- 615
		while row < #bands - 1 do -- 615
			local y0 = front + bands[row + 1] * height -- 616
			local y1 = front + bands[row + 1 + 1] * height -- 617
			local rowH = y1 - y0 -- 618
			local slabWidth = math.max( -- 619
				24, -- 619
				cam:len(84 - row * 10) -- 619
			) -- 619
			local offset = left - row % 2 * slabWidth * 0.5 -- 620
			local start = math.max( -- 621
				0, -- 621
				math.floor((visLeft - offset) / slabWidth) -- 621
			) -- 621
			do -- 621
				local col = start -- 622
				while offset + col * slabWidth < visRight do -- 622
					do -- 622
						local sx0 = math.max(left, offset + col * slabWidth) -- 623
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 624
						local sw = sx1 - sx0 -- 625
						if sw <= 2 then -- 626
							goto __continue69 -- 627
						end -- 627
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 629
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 630
						draw:drawRect( -- 631
							Rect( -- 631
								sx0 + 0.5, -- 631
								y0 + 0.5, -- 631
								sw - 1, -- 631
								math.max(1, rowH - 1) -- 631
							), -- 631
							toColor(stoneCol, 195) -- 631
						) -- 631
						draw:drawSegment( -- 632
							Vec2(sx0, y0), -- 632
							Vec2(sx0, y1), -- 632
							0.8, -- 632
							jointDark -- 632
						) -- 632
					end -- 632
					::__continue69:: -- 632
					col = col + 1 -- 622
				end -- 622
			end -- 622
			draw:drawSegment( -- 634
				Vec2(left, y0), -- 634
				Vec2(right, y0), -- 634
				0.9, -- 634
				jointDark -- 634
			) -- 634
			draw:drawSegment( -- 635
				Vec2(left, y0 + 1), -- 635
				Vec2(right, y0 + 1), -- 635
				0.6, -- 635
				jointHi -- 635
			) -- 635
			row = row + 1 -- 615
		end -- 615
	end -- 615
	draw:drawSegment( -- 638
		Vec2(left, front), -- 638
		Vec2(right, front), -- 638
		1.4, -- 638
		toColor(theme.groundRim, 135) -- 638
	) -- 638
	draw:drawSegment( -- 639
		Vec2(left, back), -- 639
		Vec2(right, back), -- 639
		1.3, -- 639
		toColor(theme.groundRim, 92) -- 639
	) -- 639
end -- 595
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 642
	local i = 0 -- 650
	do -- 650
		i = 0 -- 651
		while i < #p.room.stairs do -- 651
			local st = p.room.stairs[i + 1] -- 652
			local n = st.steps + 1 -- 653
			local stepW = (st.x1 - st.x0) / n -- 654
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 655
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 658
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 661
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 662
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 663
			local k = 0 -- 664
			do -- 664
				k = 0 -- 665
				while k < n do -- 665
					do -- 665
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 666
						local wx0 = st.x0 + stepW * k -- 667
						local wx1 = wx0 + stepW -- 668
						local x0 = cam:sx(wx0) -- 669
						local x1 = cam:sx(wx1) -- 670
						if x1 < 0 or x0 > cam.viewW then -- 671
							goto __continue75 -- 672
						end -- 672
						local y1 = cam:sy(wy, dMin) -- 674
						local y0 = cam:sy(baseWorldY, dMin) -- 675
						local yRear = cam:sy(wy, dMax) -- 676
						if yRear > y1 + 1 then -- 677
							fgDraw:drawRect( -- 678
								Rect(x0, y1, x1 - x0, yRear - y1), -- 678
								toColor( -- 678
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 678
									235 -- 678
								), -- 678
								0.7, -- 678
								toColor(theme.groundRim, 95) -- 678
							) -- 678
						end -- 678
						if y1 > y0 + 2 then -- 680
							fgDraw:drawRect( -- 681
								Rect(x0, y0, x1 - x0, y1 - y0), -- 681
								toColor(PALETTE.steelDark, 235) -- 681
							) -- 681
							fgDraw:drawRect( -- 682
								Rect(x0, y1 - 4, x1 - x0, 4), -- 682
								toColor(theme.groundTop) -- 682
							) -- 682
							assets:tryPlace( -- 683
								"wall", -- 683
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 683
								(x0 + x1) * 0.5, -- 683
								y0, -- 683
								x1 - x0, -- 684
								y1 - y0, -- 684
								{opacity = 0.76, layer = stairLayer} -- 684
							) -- 684
							assets:tryPlace( -- 685
								"slab", -- 685
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 685
								(x0 + x1) * 0.5, -- 685
								y1 - cam:len(4), -- 685
								x1 - x0, -- 686
								cam:len(4), -- 686
								{layer = stairLayer + 1} -- 686
							) -- 686
						end -- 686
						fgDraw:drawSegment( -- 688
							Vec2(x0, y1), -- 688
							Vec2(x1, y1), -- 688
							1.6, -- 688
							toColor(theme.groundRim) -- 688
						) -- 688
						fgGlow:drawSegment( -- 689
							Vec2(x0, y1 + 1), -- 689
							Vec2(x1, y1 + 1), -- 689
							0.9, -- 689
							toColor(theme.accent, 50) -- 689
						) -- 689
					end -- 689
					::__continue75:: -- 689
					k = k + 1 -- 665
				end -- 665
			end -- 665
			i = i + 1 -- 651
		end -- 651
	end -- 651
end -- 642
function StageRenderer.prototype.isSolidActive(self, p, s) -- 695
	local matched = false -- 696
	local anyVisible = false -- 697
	local i = 0 -- 698
	do -- 698
		i = 0 -- 699
		while i < #p.boxes do -- 699
			local b = p.boxes[i + 1] -- 700
			local sameId = s.id ~= nil and b.id == s.id -- 701
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 702
			if sameId or sameGeom then -- 705
				matched = true -- 706
				if b.broken ~= true and b.hidden ~= true then -- 707
					anyVisible = true -- 708
				end -- 708
			end -- 708
			i = i + 1 -- 699
		end -- 699
	end -- 699
	return not matched or anyVisible -- 712
end -- 695
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 715
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #p.room.solids do -- 727
			do -- 727
				local s = p.room.solids[i + 1] -- 728
				if s.decorative == true then -- 730
					goto __continue86 -- 731
				end -- 731
				if not self:isSolidActive(p, s) then -- 734
					goto __continue86 -- 735
				end -- 735
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 738
					goto __continue86 -- 739
				end -- 739
				local x0 = cam:sx(s.x) -- 741
				local x1 = cam:sx(s.x + s.w) -- 742
				if p.room.depth ~= nil and s.depth ~= nil then -- 743
					local opacity = occlusion:update( -- 744
						"solid_" .. tostring(i), -- 744
						{ -- 744
							x0 = s.x, -- 745
							x1 = s.x + s.w, -- 745
							y0 = s.y, -- 745
							y1 = s.y + s.h, -- 745
							depth = s.depth, -- 746
							passThrough = s.passable == true or s.soft == true -- 746
						}, -- 746
						p, -- 747
						fadeDt -- 747
					) -- 747
					if x1 > 0 and x0 < cam.viewW then -- 748
						self:drawDepthSolid( -- 749
							fgDraw, -- 749
							assets, -- 749
							s, -- 749
							s.depth, -- 749
							x0, -- 749
							x1, -- 749
							cam, -- 749
							theme, -- 749
							opacity, -- 749
							p -- 749
						) -- 749
					end -- 749
					goto __continue86 -- 751
				end -- 751
				local y0 = cam:sy(s.y) -- 753
				local y1 = cam:sy(s.y + s.h) -- 754
				local sw = x1 - x0 -- 755
				local sh = y1 - y0 -- 756
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 757
					goto __continue86 -- 758
				end -- 758
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 762
					local groundY = cam:sy(0) -- 763
					local pierW = cam:len(16) -- 764
					fgDraw:drawRect( -- 765
						Rect(x0, groundY, pierW, y0 - groundY), -- 765
						Color(32, 37, 46, 215), -- 765
						0.9, -- 765
						Color(68, 76, 88, 140) -- 765
					) -- 765
					fgDraw:drawRect( -- 766
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 766
						Color(32, 37, 46, 215), -- 766
						0.9, -- 766
						Color(68, 76, 88, 140) -- 766
					) -- 766
				end -- 766
				if s.passable == true then -- 770
					if not assets:tryPlace( -- 771
						"grass", -- 771
						"hide_grass_" .. tostring(i), -- 771
						(x0 + x1) * 0.5, -- 771
						y0, -- 771
						sw, -- 771
						sh * 1.55, -- 771
						{opacity = 0.79, layer = 7} -- 772
					) then -- 772
						self:drawGrassCluster( -- 773
							fgDraw, -- 773
							fgGlow, -- 773
							x0, -- 773
							y0, -- 773
							sw, -- 773
							sh, -- 773
							p.player.x, -- 773
							s.x + s.w * 0.5, -- 773
							time -- 773
						) -- 773
					end -- 773
					goto __continue86 -- 775
				end -- 775
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 779
					self:drawWinch( -- 780
						fgDraw, -- 780
						assets, -- 780
						x0, -- 780
						y0, -- 780
						sw, -- 780
						sh, -- 780
						p, -- 780
						2 -- 780
					) -- 780
					goto __continue86 -- 781
				end -- 781
				if p.room.key == "tower" then -- 785
					self:drawTowerStructure( -- 786
						fgDraw, -- 786
						fgGlow, -- 786
						assets, -- 786
						x0, -- 786
						y0, -- 786
						sw, -- 786
						sh, -- 786
						s, -- 786
						p, -- 786
						cam, -- 786
						time -- 786
					) -- 786
					goto __continue86 -- 787
				end -- 787
				if s.h <= 64 and s.y <= 2 then -- 791
					self:drawCoverBlock( -- 792
						fgDraw, -- 792
						fgGlow, -- 792
						assets, -- 792
						x0, -- 792
						y0, -- 792
						sw, -- 792
						sh, -- 792
						s, -- 792
						p, -- 792
						theme -- 792
					) -- 792
					goto __continue86 -- 793
				end -- 793
				fillVGradRect( -- 796
					fgDraw, -- 796
					x0, -- 796
					y0, -- 796
					sw, -- 796
					sh, -- 796
					toColor(PALETTE.steelDark), -- 796
					toColor(PALETTE.steelMid) -- 796
				) -- 796
				self:tileMasonry( -- 797
					assets, -- 797
					s, -- 797
					x0, -- 797
					y0, -- 797
					sw, -- 797
					sh -- 797
				) -- 797
			end -- 797
			::__continue86:: -- 797
			i = i + 1 -- 727
		end -- 727
	end -- 727
end -- 715
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 801
	local width = right - left -- 805
	local base = cam:sy(solid.y, depth.min) -- 806
	local rearBase = cam:sy(solid.y, depth.max) -- 807
	local top = cam:sy(solid.y + solid.h, depth.min) -- 808
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 809
	local frontH = top - base -- 810
	local slot = coverArt(solid) -- 811
	local layer = depthOrder(depth.min, 1) -- 812
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 813
	local capHeight = rear - top -- 814
	local center = (left + right) * 0.5 -- 815
	if solid.y <= 2 and rearBase > base + 1 then -- 818
		draw:drawRect( -- 819
			Rect(left, base, width, rearBase - base), -- 820
			Color( -- 821
				9, -- 821
				10, -- 821
				14, -- 821
				math.floor(86 * opacity + 0.5) -- 821
			), -- 821
			0.8, -- 822
			toColor( -- 823
				theme.groundRim, -- 823
				math.floor(58 * opacity + 0.5) -- 823
			) -- 823
		) -- 823
	end -- 823
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 828
		self:drawWinch( -- 829
			draw, -- 829
			assets, -- 829
			left, -- 829
			base, -- 829
			width, -- 829
			frontH, -- 829
			p, -- 829
			layer -- 829
		) -- 829
		return -- 830
	end -- 830
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 833
		assets:tryPlace( -- 834
			"slab", -- 834
			"gate_sill_" .. tostring(solid.x), -- 834
			center, -- 834
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 834
			width + cam:len(34), -- 835
			cam:len(12), -- 835
			{ -- 835
				layer = 1, -- 835
				color = Color(180, 169, 150, 255) -- 835
			} -- 835
		) -- 835
	end -- 835
	draw:drawEllipse( -- 837
		Vec2( -- 837
			center, -- 837
			base + cam:len(2) -- 837
		), -- 837
		width * 0.5, -- 837
		math.max( -- 838
			2, -- 838
			cam:len(2.5) -- 838
		), -- 838
		Color(10, 10, 14, 128 * opacity) -- 838
	) -- 838
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 840
	if slot ~= "fence" and capHeight > 1 then -- 843
		local capFill = occlusionTint( -- 844
			opacity, -- 844
			timber and Color( -- 844
				88, -- 845
				68, -- 845
				52, -- 845
				math.floor(240 * opacity + 0.5) -- 845
			) or Color( -- 846
				86, -- 846
				90, -- 846
				98, -- 846
				math.floor(240 * opacity + 0.5) -- 846
			) -- 846
		) -- 846
		local capEdge = occlusionTint( -- 847
			opacity, -- 847
			timber and Color( -- 847
				148, -- 848
				118, -- 848
				90, -- 848
				math.floor(185 * opacity + 0.5) -- 848
			) or Color( -- 849
				146, -- 849
				152, -- 849
				160, -- 849
				math.floor(175 * opacity + 0.5) -- 849
			) -- 849
		) -- 849
		draw:drawRect( -- 850
			Rect(left, top, width, capHeight), -- 850
			capFill, -- 850
			0.9, -- 850
			capEdge -- 850
		) -- 850
		draw:drawSegment( -- 851
			Vec2(left + 1, top + 0.5), -- 851
			Vec2(right - 1, top + 0.5), -- 851
			1.1, -- 851
			capEdge -- 851
		) -- 851
		if capHeight > 8 then -- 852
			local midY = top + capHeight * 0.5 -- 853
			draw:drawSegment( -- 854
				Vec2(left + 2, midY), -- 854
				Vec2(right - 2, midY), -- 854
				0.7, -- 854
				Color( -- 854
					24, -- 854
					22, -- 854
					22, -- 854
					math.floor(90 * opacity + 0.5) -- 854
				) -- 854
			) -- 854
		end -- 854
	end -- 854
	if timber and solid.h > solid.w * 1.6 then -- 859
		local colFill = occlusionTint( -- 860
			opacity, -- 860
			Color( -- 860
				66, -- 860
				48, -- 860
				36, -- 860
				math.floor(248 * opacity + 0.5) -- 860
			) -- 860
		) -- 860
		local colHi = occlusionTint( -- 861
			opacity, -- 861
			Color( -- 861
				122, -- 861
				92, -- 861
				68, -- 861
				math.floor(200 * opacity + 0.5) -- 861
			) -- 861
		) -- 861
		local colSh = occlusionTint( -- 862
			opacity, -- 862
			Color( -- 862
				34, -- 862
				24, -- 862
				18, -- 862
				math.floor(220 * opacity + 0.5) -- 862
			) -- 862
		) -- 862
		draw:drawRect( -- 863
			Rect(left, base, width, frontH), -- 863
			colFill, -- 863
			1, -- 863
			colHi -- 863
		) -- 863
		draw:drawRect( -- 864
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 864
			colSh -- 864
		) -- 864
		draw:drawSegment( -- 865
			Vec2(left + width * 0.32, base + 2), -- 865
			Vec2(left + width * 0.32, top - 2), -- 865
			0.9, -- 865
			colHi -- 865
		) -- 865
		return -- 866
	end -- 866
	if solid.w > solid.h * 5 then -- 870
		local beamFill = occlusionTint( -- 871
			opacity, -- 871
			Color( -- 871
				78, -- 871
				58, -- 871
				42, -- 871
				math.floor(248 * opacity + 0.5) -- 871
			) -- 871
		) -- 871
		local beamEdge = occlusionTint( -- 872
			opacity, -- 872
			Color( -- 872
				142, -- 872
				110, -- 872
				82, -- 872
				math.floor(215 * opacity + 0.5) -- 872
			) -- 872
		) -- 872
		draw:drawRect( -- 873
			Rect( -- 873
				left, -- 873
				base, -- 873
				width, -- 873
				math.max(4, frontH) -- 873
			), -- 873
			beamFill, -- 873
			1, -- 873
			beamEdge -- 873
		) -- 873
		local posts = math.max( -- 874
			2, -- 874
			math.floor(solid.w / 140 + 0.5) -- 874
		) -- 874
		do -- 874
			local pi = 0 -- 875
			while pi <= posts do -- 875
				local px = left + width * pi / posts -- 876
				draw:drawSegment( -- 877
					Vec2(px, base), -- 877
					Vec2(px, top), -- 877
					1.4, -- 877
					Color( -- 877
						34, -- 877
						24, -- 877
						18, -- 877
						math.floor(210 * opacity + 0.5) -- 877
					) -- 877
				) -- 877
				pi = pi + 1 -- 875
			end -- 875
		end -- 875
		return -- 879
	end -- 879
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 883
	local cols = slot == "wall" and math.max( -- 884
		1, -- 885
		math.min( -- 885
			10, -- 885
			math.floor(solid.w / 72 + 0.5) -- 885
		) -- 885
	) or math.max( -- 886
		1, -- 886
		math.min( -- 886
			10, -- 886
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 886
		) -- 886
	) -- 886
	local colW = width / cols -- 887
	local rows = slot == "wall" and math.max( -- 888
		1, -- 889
		math.min( -- 889
			10, -- 889
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 889
		) -- 889
	) or math.max( -- 890
		1, -- 890
		math.min( -- 890
			6, -- 890
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 890
		) -- 890
	) -- 890
	local rowHeight = frontH / rows -- 891
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 892
	local color = occlusionTint(opacity, masonryColor) -- 893
	local placedAny = false -- 894
	do -- 894
		local row = 0 -- 895
		while row < rows do -- 895
			do -- 895
				local col = 0 -- 896
				while col < cols do -- 896
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 897
					if assets:tryPlace( -- 898
						slot, -- 898
						tileKey, -- 898
						left + (col + 0.5) * colW, -- 898
						base + row * rowHeight, -- 898
						colW + 0.5, -- 898
						rowHeight + 0.5, -- 898
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 898
					) then -- 898
						placedAny = true -- 901
					end -- 901
					col = col + 1 -- 896
				end -- 896
			end -- 896
			row = row + 1 -- 895
		end -- 895
	end -- 895
	if not placedAny then -- 905
		draw:drawRect( -- 906
			Rect(left, base, width, frontH), -- 906
			occlusionTint( -- 907
				opacity, -- 907
				toColor(PALETTE.steelMid, 255 * opacity) -- 907
			), -- 907
			1, -- 908
			toColor(theme.groundRim, 150 * opacity) -- 908
		) -- 908
	end -- 908
end -- 801
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 912
	local columns = math.max( -- 917
		1, -- 917
		math.min( -- 917
			10, -- 917
			math.floor(s.w / 58 + 0.5) -- 917
		) -- 917
	) -- 917
	local cellWorldW = s.w / columns -- 918
	local targetCellH = math.max( -- 919
		24, -- 919
		math.min(48, cellWorldW / 1.52) -- 919
	) -- 919
	local rows = math.max( -- 920
		1, -- 920
		math.min( -- 920
			12, -- 920
			math.floor(s.h / targetCellH + 0.5) -- 920
		) -- 920
	) -- 920
	local tileW = width / columns -- 921
	local tileH = height / rows -- 922
	do -- 922
		local row = 0 -- 923
		while row < rows do -- 923
			do -- 923
				local column = 0 -- 924
				while column < columns do -- 924
					assets:tryPlace( -- 925
						"wall", -- 925
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 925
						x + (column + 0.5) * tileW, -- 926
						y + row * tileH, -- 926
						tileW + 0.5, -- 926
						tileH + 0.5, -- 926
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 927
					) -- 927
					column = column + 1 -- 924
				end -- 924
			end -- 924
			row = row + 1 -- 923
		end -- 923
	end -- 923
end -- 912
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 932
	local slot = coverArt(s) -- 939
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 940
	local cols = math.max( -- 941
		1, -- 941
		math.min( -- 941
			8, -- 941
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 941
		) -- 941
	) -- 941
	local tileW = sw / cols -- 942
	local placed = false -- 943
	do -- 943
		local c = 0 -- 944
		while c < cols do -- 944
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 945
			if assets:tryPlace( -- 946
				slot, -- 946
				k, -- 946
				x0 + (c + 0.5) * tileW, -- 946
				y0, -- 946
				tileW + 0.5, -- 946
				sh, -- 946
				{layer = 1} -- 946
			) then -- 946
				placed = true -- 947
			end -- 947
			c = c + 1 -- 944
		end -- 944
	end -- 944
	if not placed then -- 950
		fillVGradRect( -- 951
			fgDraw, -- 951
			x0, -- 951
			y0, -- 951
			sw, -- 951
			sh, -- 951
			toColor(PALETTE.steelDark), -- 951
			toColor(PALETTE.steelMid) -- 951
		) -- 951
		fgDraw:drawSegment( -- 952
			Vec2(x0, y0 + sh), -- 952
			Vec2(x0 + sw, y0 + sh), -- 952
			1.4, -- 952
			toColor(theme.groundRim) -- 952
		) -- 952
	end -- 952
	if not p.childMode and (p.coverHug or p.coverNear) then -- 956
		local plx = p.player.x -- 957
		local nearLeft = math.abs(plx - s.x) < 42 -- 958
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 959
		if nearLeft or nearRight then -- 960
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 961
			local isWood = slot == "cover_wood" -- 962
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 963
			fgDraw:drawSegment( -- 964
				Vec2(edgeX, y0 + 4), -- 964
				Vec2(edgeX, y0 + sh + 2), -- 964
				p.coverHug and 2 or 1.2, -- 964
				toColor(col, p.coverHug and 205 or 120) -- 964
			) -- 964
		end -- 964
	end -- 964
end -- 932
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 969
	if layer == nil then -- 974
		layer = 2 -- 974
	end -- 974
	local cx = x0 + sw * 0.5 -- 976
	local cy = y0 + sh * 0.55 -- 977
	local ropeWidth = math.max(1, sw * 0.023) -- 978
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 979
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 980
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 981
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 982
	draw:drawEllipse( -- 983
		Vec2(cx, y0), -- 983
		sw * 0.53, -- 983
		sh * 0.07, -- 983
		Color(10, 8, 9, 150) -- 983
	) -- 983
	draw:drawSegment( -- 984
		drum, -- 984
		bend, -- 984
		ropeWidth, -- 984
		Color(111, 86, 57, 239) -- 984
	) -- 984
	draw:drawSegment( -- 985
		bend, -- 985
		ropeTop, -- 985
		ropeWidth, -- 985
		Color(111, 86, 57, 239) -- 985
	) -- 985
	if assets:tryPlace( -- 986
		"prop_winch", -- 986
		"gate_winch", -- 986
		cx, -- 986
		y0 + sh * 0.5, -- 986
		sw, -- 986
		sh, -- 986
		{layer = layer} -- 986
	) then -- 986
		return -- 987
	end -- 987
	local timber = Color(75, 51, 34, 255) -- 989
	draw:drawSegment( -- 990
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 990
		Vec2(cx, y0 + sh * 0.86), -- 990
		sw * 0.06, -- 990
		timber -- 990
	) -- 990
	draw:drawSegment( -- 991
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 991
		Vec2(cx, y0 + sh * 0.86), -- 991
		sw * 0.06, -- 991
		timber -- 991
	) -- 991
	draw:drawRect( -- 992
		Rect(x0, y0, sw, sh * 0.12), -- 992
		timber -- 992
	) -- 992
	local radius = math.min(sw, sh) * 0.21 -- 993
	draw:drawCircle( -- 994
		Vec2(cx, cy), -- 994
		radius, -- 994
		Color(48, 41, 37, 255) -- 994
	) -- 994
	do -- 994
		local i = -2 -- 995
		while i <= 2 do -- 995
			local x = cx + i * radius * 0.28 -- 996
			draw:drawSegment( -- 997
				Vec2(x, cy - radius * 0.62), -- 997
				Vec2(x, cy + radius * 0.62), -- 997
				ropeWidth, -- 997
				Color(135, 103, 68, 240) -- 998
			) -- 998
			i = i + 1 -- 995
		end -- 995
	end -- 995
end -- 969
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 1002
	local ____temp_3 -- 1010
	if p.room.story ~= nil then -- 1010
		____temp_3 = p.room.story.gate -- 1010
	else -- 1010
		____temp_3 = nil -- 1010
	end -- 1010
	local g = ____temp_3 -- 1010
	if g == nil then -- 1011
		return -- 1012
	end -- 1012
	local closeFrac = 0.08 -- 1015
	if p.phase == "gate-hold" then -- 1016
		closeFrac = 0.08 + 0.36 * math.min( -- 1017
			1, -- 1017
			p.gateTick / math.max(1, g.holdTicks) -- 1017
		) -- 1017
	elseif p.phase == "gate-send" then -- 1018
		closeFrac = 0.44 -- 1019
	elseif p.phase == "gate-count" then -- 1020
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 1021
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 1022
		closeFrac = 1 -- 1023
	end -- 1023
	local gx0 = cam:sx(848) -- 1025
	local gx1 = cam:sx(1032) -- 1026
	local topY = cam:sy(160) -- 1027
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1028
	local shutterW = gx1 - gx0 -- 1029
	local shutterH = topY - botY -- 1030
	if shutterH > 2 then -- 1031
		fillVGradRect( -- 1032
			fgDraw, -- 1032
			gx0, -- 1032
			botY, -- 1032
			shutterW, -- 1032
			shutterH, -- 1032
			toColor(PALETTE.steelDark), -- 1032
			toColor(PALETTE.steelMid) -- 1032
		) -- 1032
		local rows = math.max( -- 1034
			1, -- 1034
			math.min( -- 1034
				6, -- 1034
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1034
			) -- 1034
		) -- 1034
		local rowH = shutterH / rows -- 1035
		do -- 1035
			local r = 0 -- 1036
			while r < rows do -- 1036
				assets:tryPlace( -- 1037
					"cover_wood", -- 1037
					"gate_shutter_" .. tostring(r), -- 1037
					(gx0 + gx1) * 0.5, -- 1037
					botY + r * rowH, -- 1037
					shutterW, -- 1038
					rowH + 0.5, -- 1038
					{layer = 6} -- 1038
				) -- 1038
				r = r + 1 -- 1036
			end -- 1036
		end -- 1036
	end -- 1036
	if closeFrac < 0.98 then -- 1042
		local gapH = math.max( -- 1043
			8, -- 1043
			botY - cam:sy(0) -- 1043
		) -- 1043
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1044
		fillVGradRect( -- 1045
			fgGlow, -- 1045
			gx0, -- 1045
			cam:sy(0), -- 1045
			gx1 - gx0, -- 1045
			gapH, -- 1045
			Color( -- 1045
				140, -- 1045
				210, -- 1045
				255, -- 1045
				math.floor(52 * pulse + 0.5) -- 1045
			), -- 1045
			Color(80, 160, 230, 0) -- 1045
		) -- 1045
	end -- 1045
end -- 1002
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1049
	fillVGradRect( -- 1056
		fgDraw, -- 1056
		x0, -- 1056
		y0, -- 1056
		sw, -- 1056
		sh, -- 1056
		Color(15, 21, 34, 255), -- 1056
		Color(32, 44, 66, 255) -- 1056
	) -- 1056
	fgDraw:drawRect( -- 1057
		Rect(x0, y0, sw, sh), -- 1057
		Color(0, 0, 0, 0), -- 1057
		1.4, -- 1057
		toColor(PALETTE.rimSilver, 165) -- 1057
	) -- 1057
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1059
		self:tileMasonry( -- 1060
			assets, -- 1060
			s, -- 1060
			x0, -- 1060
			y0, -- 1060
			sw, -- 1060
			sh -- 1060
		) -- 1060
		local ribs = 4 -- 1062
		local r = 1 -- 1063
		do -- 1063
			r = 1 -- 1064
			while r < ribs do -- 1064
				local rx = x0 + sw * r / ribs -- 1065
				fgDraw:drawSegment( -- 1066
					Vec2(rx, y0), -- 1066
					Vec2(rx, y0 + sh), -- 1066
					2, -- 1066
					Color(10, 15, 24, 210) -- 1066
				) -- 1066
				fgDraw:drawSegment( -- 1067
					Vec2(rx + 2, y0), -- 1067
					Vec2(rx + 2, y0 + sh), -- 1067
					1, -- 1067
					Color(68, 86, 114, 130) -- 1067
				) -- 1067
				r = r + 1 -- 1064
			end -- 1064
		end -- 1064
		local bands = 4 -- 1070
		local b = 1 -- 1071
		do -- 1071
			b = 1 -- 1072
			while b < bands do -- 1072
				local by = y0 + sh * b / bands -- 1073
				fgDraw:drawSegment( -- 1074
					Vec2(x0 + 4, by), -- 1074
					Vec2(x0 + sw - 4, by), -- 1074
					1.2, -- 1074
					Color(52, 68, 92, 135) -- 1074
				) -- 1074
				b = b + 1 -- 1072
			end -- 1072
		end -- 1072
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1077
		local slitY = y0 + sh * 0.56 -- 1078
		local slitH = sh * 0.22 -- 1079
		fgDraw:drawRect( -- 1080
			Rect(slitX - 5, slitY, 10, slitH), -- 1080
			Color(8, 12, 20, 245), -- 1080
			1.2, -- 1080
			toColor(PALETTE.amberDim, 190) -- 1080
		) -- 1080
		fgGlow:drawRect( -- 1081
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1081
			toColor(PALETTE.amber, 190) -- 1081
		) -- 1081
		fillRadialGlow( -- 1082
			fgGlow, -- 1082
			slitX, -- 1082
			slitY + slitH * 0.5, -- 1082
			44, -- 1082
			slitH * 0.7, -- 1082
			Color(255, 206, 128, 52), -- 1082
			Color(255, 180, 86, 0), -- 1082
			14 -- 1082
		) -- 1082
	end -- 1082
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1086
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1087
		local cx = x0 + sw * 0.5 -- 1092
		local lampY = y0 - 8 -- 1093
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1094
		if not opened then -- 1095
			assets:tryPlace( -- 1096
				"prop_tower_door", -- 1096
				"tower_door", -- 1096
				cx, -- 1096
				y0 - doorHeight, -- 1096
				sw, -- 1096
				doorHeight, -- 1096
				{layer = 2} -- 1096
			) -- 1096
		end -- 1096
		assets:tryPlace( -- 1098
			"prop_lantern", -- 1098
			"tower_lantern", -- 1098
			cx + sw * 0.43, -- 1098
			lampY - sh * 0.36, -- 1098
			sw * 0.17, -- 1099
			sh * 0.84, -- 1099
			{layer = 3} -- 1099
		) -- 1099
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1100
		local alpha = opened and 155 or 88 -- 1101
		fgDraw:drawSegment( -- 1103
			Vec2(x0 + 4, y0), -- 1103
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1103
			4, -- 1103
			Color(42, 52, 70, 255) -- 1103
		) -- 1103
		fgDraw:drawSegment( -- 1104
			Vec2(x0 + sw - 4, y0), -- 1104
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1104
			4, -- 1104
			Color(42, 52, 70, 255) -- 1104
		) -- 1104
		fgDraw:drawSegment( -- 1105
			Vec2(x0, y0), -- 1105
			Vec2(x0 + sw, y0), -- 1105
			2.5, -- 1105
			toColor(PALETTE.amber, 210) -- 1105
		) -- 1105
		fillVGradRect( -- 1107
			fgGlow, -- 1108
			x0 + 6, -- 1109
			y0 - sh * 3.8, -- 1110
			sw - 12, -- 1111
			sh * 3.8, -- 1112
			Color( -- 1113
				255, -- 1113
				206, -- 1113
				128, -- 1113
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 1113
			), -- 1113
			Color(255, 224, 168, opened and 180 or 62) -- 1114
		) -- 1114
		fillRadialGlow( -- 1116
			fgGlow, -- 1116
			cx, -- 1116
			lampY, -- 1116
			opened and 105 or 58, -- 1116
			opened and 105 or 58, -- 1116
			Color( -- 1116
				255, -- 1116
				232, -- 1116
				178, -- 1116
				math.floor(170 * pulse + 0.5) -- 1116
			), -- 1116
			Color(255, 180, 86, 0), -- 1116
			18 -- 1116
		) -- 1116
		fgDraw:drawCircle( -- 1117
			Vec2(cx, lampY), -- 1117
			5.5, -- 1117
			toColor(PALETTE.amberCore) -- 1117
		) -- 1117
		if opened then -- 1120
			local deskCx = cam:sx(p.ox + 605) -- 1121
			local groundY = cam:sy(0) -- 1122
			local deskW = cam:len(84) -- 1123
			local deskH = cam:len(34) -- 1124
			local deskTop = groundY + deskH -- 1125
			fillRadialGlow( -- 1127
				fgGlow, -- 1127
				deskCx, -- 1127
				deskTop + cam:len(32), -- 1127
				cam:len(115), -- 1127
				cam:len(90), -- 1127
				Color( -- 1128
					255, -- 1128
					198, -- 1128
					114, -- 1128
					math.floor(68 * pulse + 0.5) -- 1128
				), -- 1128
				Color(255, 168, 72, 0), -- 1128
				16 -- 1128
			) -- 1128
			local guardX = deskCx + cam:len(26) -- 1130
			fgDraw:drawRect( -- 1131
				Rect( -- 1131
					guardX - cam:len(11), -- 1131
					groundY, -- 1131
					cam:len(22), -- 1131
					cam:len(68) -- 1131
				), -- 1131
				Color(34, 42, 54, 240) -- 1131
			) -- 1131
			fgDraw:drawCircle( -- 1132
				Vec2( -- 1132
					guardX, -- 1132
					groundY + cam:len(76) -- 1132
				), -- 1132
				cam:len(9.5), -- 1132
				Color(42, 50, 62, 245) -- 1132
			) -- 1132
			fgDraw:drawRect( -- 1134
				Rect( -- 1134
					deskCx - deskW * 0.5, -- 1134
					groundY, -- 1134
					cam:len(6), -- 1134
					deskH -- 1134
				), -- 1134
				Color(78, 52, 34, 255) -- 1134
			) -- 1134
			fgDraw:drawRect( -- 1135
				Rect( -- 1135
					deskCx + deskW * 0.5 - cam:len(6), -- 1135
					groundY, -- 1135
					cam:len(6), -- 1135
					deskH -- 1135
				), -- 1135
				Color(78, 52, 34, 255) -- 1135
			) -- 1135
			fgDraw:drawRect( -- 1136
				Rect( -- 1136
					deskCx - deskW * 0.52, -- 1136
					deskTop - cam:len(6), -- 1136
					deskW * 1.04, -- 1136
					cam:len(8) -- 1136
				), -- 1136
				Color(108, 74, 46, 255), -- 1136
				1, -- 1136
				Color(148, 108, 68, 220) -- 1136
			) -- 1136
			fgDraw:drawRect( -- 1138
				Rect( -- 1138
					deskCx + cam:len(4), -- 1138
					deskTop + cam:len(2), -- 1138
					cam:len(24), -- 1138
					cam:len(5) -- 1138
				), -- 1138
				Color(232, 222, 198, 245) -- 1138
			) -- 1138
			fgDraw:drawRect( -- 1139
				Rect( -- 1139
					deskCx + cam:len(32), -- 1139
					deskTop + cam:len(2), -- 1139
					cam:len(8), -- 1139
					cam:len(12) -- 1139
				), -- 1139
				Color(168, 128, 64, 245) -- 1139
			) -- 1139
			fgGlow:drawCircle( -- 1140
				Vec2( -- 1140
					deskCx + cam:len(36), -- 1140
					deskTop + cam:len(16) -- 1140
				), -- 1140
				cam:len(5.5), -- 1140
				Color( -- 1140
					255, -- 1140
					224, -- 1140
					152, -- 1140
					math.floor(220 * pulse + 0.5) -- 1140
				) -- 1140
			) -- 1140
			if p.deskHold >= 12 or p.towerHanded then -- 1142
				fgDraw:drawRect( -- 1143
					Rect( -- 1143
						deskCx - cam:len(28), -- 1143
						deskTop + cam:len(2), -- 1143
						cam:len(14), -- 1143
						cam:len(6) -- 1143
					), -- 1143
					Color(156, 62, 48, 245) -- 1143
				) -- 1143
			end -- 1143
			if p.deskHold >= 24 or p.towerHanded then -- 1145
				fgDraw:drawCircle( -- 1146
					Vec2( -- 1146
						deskCx - cam:len(8), -- 1146
						deskTop + cam:len(5) -- 1146
					), -- 1146
					cam:len(4.5), -- 1146
					Color(224, 186, 98, 255) -- 1146
				) -- 1146
				fgDraw:drawRect( -- 1147
					Rect( -- 1147
						deskCx - cam:len(16), -- 1147
						deskTop + cam:len(2), -- 1147
						cam:len(10), -- 1147
						cam:len(3) -- 1147
					), -- 1147
					Color(236, 228, 206, 240) -- 1147
				) -- 1147
			end -- 1147
		end -- 1147
	end -- 1147
end -- 1049
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1153
	local blades = math.max( -- 1160
		12, -- 1160
		math.floor(sw / 8) -- 1160
	) -- 1160
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1161
	local k = 0 -- 1162
	do -- 1162
		k = 0 -- 1163
		while k < blades do -- 1163
			local t = (k + 0.5) / blades -- 1164
			local bx = x0 + sw * t -- 1165
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1166
			local bh = sh * hRatio * 1.95 -- 1167
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1168
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1169
			fgDraw:drawPolygon( -- 1170
				{ -- 1170
					Vec2(bx - 7, y0), -- 1171
					Vec2(bx + 7, y0), -- 1172
					Vec2(bx + sway, y0 + bh) -- 1173
				}, -- 1173
				col -- 1174
			) -- 1174
			k = k + 1 -- 1163
		end -- 1163
	end -- 1163
	if nearPlayer then -- 1176
		fgGlow:drawSegment( -- 1177
			Vec2(x0, y0 + 2), -- 1177
			Vec2(x0 + sw, y0 + 2), -- 1177
			2, -- 1177
			toColor(PALETTE.emerald, 145) -- 1177
		) -- 1177
	end -- 1177
end -- 1153
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1181
	local a = p.room.arch -- 1186
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1187
		return -- 1188
	end -- 1188
	local x0 = cam:sx(a.x0) -- 1190
	local x1 = cam:sx(a.x1) -- 1191
	local y0 = cam:sy(a.y) -- 1192
	local y1 = cam:sy(a.y + a.h) -- 1193
	local cx = (x0 + x1) * 0.5 -- 1194
	local rx = (x1 - x0) * 0.5 -- 1195
	local rise = cam:len(9) -- 1196
	local rim = cam:len(7) -- 1197
	local slices = 9 -- 1198
	local mortar = Color(31, 32, 35, 255) -- 1199
	local function point(i, edge) -- 1200
		local angle = math.pi * i / slices -- 1201
		return Vec2( -- 1202
			cx + math.cos(angle) * (rx + edge), -- 1202
			y1 + math.sin(angle) * (rise + edge) -- 1202
		) -- 1202
	end -- 1200
	local opening = { -- 1204
		Vec2(x0, y0), -- 1204
		Vec2(x1, y0) -- 1204
	} -- 1204
	do -- 1204
		local i = 0 -- 1205
		while i <= slices do -- 1205
			opening[#opening + 1] = point(i, 0) -- 1206
			i = i + 1 -- 1205
		end -- 1205
	end -- 1205
	draw:drawPolygon( -- 1208
		opening, -- 1208
		Color(13, 15, 20, 248) -- 1208
	) -- 1208
	draw:drawRect( -- 1209
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1209
		Color(62, 63, 67, 255), -- 1209
		1, -- 1209
		mortar -- 1209
	) -- 1209
	draw:drawRect( -- 1210
		Rect(x1, y0, rim, y1 - y0), -- 1210
		Color(72, 72, 74, 255), -- 1210
		1, -- 1210
		mortar -- 1210
	) -- 1210
	do -- 1210
		local i = 0 -- 1211
		while i < slices do -- 1211
			local shade = 77 + i % 3 * 8 -- 1212
			draw:drawPolygon( -- 1213
				{ -- 1213
					point(i, 0), -- 1213
					point(i, rim), -- 1213
					point(i + 1, rim), -- 1213
					point(i + 1, 0) -- 1213
				}, -- 1213
				Color(shade, shade, shade + 1, 255), -- 1214
				1, -- 1214
				mortar -- 1214
			) -- 1214
			i = i + 1 -- 1211
		end -- 1211
	end -- 1211
	if not p.cartDocked then -- 1217
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1218
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1219
		if bx1 > bx0 + 4 then -- 1220
			local deckY = cam:sy(p.room.cart.baseY) -- 1221
			draw:drawRect( -- 1222
				Rect(bx0, y0 + 2, bx1 - bx0, y1 - y0 - 2), -- 1222
				Color(72, 52, 36, 245), -- 1222
				1.1, -- 1222
				Color(138, 108, 78, 210) -- 1222
			) -- 1222
			draw:drawSegment( -- 1223
				Vec2((bx0 + bx1) * 0.5, y1), -- 1223
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1223
				2.4, -- 1223
				Color(96, 102, 110, 220) -- 1223
			) -- 1223
		end -- 1223
	end -- 1223
end -- 1181
return ____exports -- 1181
