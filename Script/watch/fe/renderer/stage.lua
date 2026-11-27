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
	if solid.art == "gate_post" or solid.art == "wall" or solid.art == "latch" then -- 38
		return "wall" -- 40
	end -- 40
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 40
		return "cover_wood" -- 43
	end -- 43
	if solid.art == "fence" then -- 43
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
	if assets:tryPlace( -- 74
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
	if theme.showMoon then -- 86
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
	if p.room.key == "forest" then -- 97
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
	if theme.showSearchlights then -- 105
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
	if theme.showTowerBeacon then -- 108
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
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 130
		assets:tryPlace( -- 133
			"pine", -- 133
			"mid_pine", -- 133
			x, -- 133
			ground - cam:len(6), -- 133
			cam:len(122), -- 133
			cam:len(107), -- 133
			{layer = 1, opacity = 0.5} -- 134
		) -- 134
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 134
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
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 140
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
	if p.room.key == "gate" then -- 258
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
			if r3 > 0.62 then -- 361
				local ax = x + bw * 0.25 -- 365
				bgDraw:drawSegment( -- 366
					Vec2(ax, baseY + bh), -- 366
					Vec2(ax, baseY + bh + 32), -- 366
					1.2, -- 366
					toColor(theme.farBuilding) -- 366
				) -- 366
				if r1 > 0.6 then -- 366
					bgGlow:drawDot( -- 368
						Vec2(ax, baseY + bh + 32), -- 368
						2.2, -- 368
						toColor(theme.accent, 145) -- 368
					) -- 368
				end -- 368
			end -- 368
			if r2 > 0.55 then -- 368
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
			if r > 0.35 then -- 442
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
			if idx & 1 == 0 then -- 456
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
			if idx % 3 == 0 then -- 507
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
	if p.room.key == "village" then -- 529
		scale = 0.72 -- 531
	elseif p.room.key == "forest" then -- 531
		scale = 0.92 -- 533
	elseif p.room.key == "tower" then -- 533
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
			if road ~= nil then -- 569
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
			if isMain and bottom > 0 then -- 574
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
					if grass and isMain and j % 3 == 1 then -- 585
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
	if width <= 1 or height <= 1 then -- 601
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
						if sw <= 2 then -- 625
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
						if x1 < 0 or x0 > cam.viewW then -- 670
							goto __continue75 -- 672
						end -- 672
						local y1 = cam:sy(wy, dMin) -- 674
						local y0 = cam:sy(baseWorldY, dMin) -- 675
						local yRear = cam:sy(wy, dMax) -- 676
						if yRear > y1 + 1 then -- 676
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
						if y1 > y0 + 2 then -- 678
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
			if sameId or sameGeom then -- 702
				matched = true -- 706
				if b.broken ~= true and b.hidden ~= true then -- 706
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
				if s.decorative == true then -- 728
					goto __continue86 -- 731
				end -- 731
				if not self:isSolidActive(p, s) then -- 731
					goto __continue86 -- 735
				end -- 735
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 735
					goto __continue86 -- 739
				end -- 739
				local x0 = cam:sx(s.x) -- 741
				local x1 = cam:sx(s.x + s.w) -- 742
				if p.room.depth ~= nil and s.depth ~= nil then -- 742
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
					if x1 > 0 and x0 < cam.viewW then -- 747
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
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 756
					goto __continue86 -- 758
				end -- 758
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 758
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
				if s.passable == true then -- 766
					if not assets:tryPlace( -- 766
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
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 775
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
				if p.room.key == "tower" then -- 781
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
				if s.art == "red_cart" then -- 787
					self:drawRedCartPixel( -- 792
						fgDraw, -- 792
						x0, -- 792
						y0, -- 792
						sw, -- 792
						sh, -- 792
						cam -- 792
					) -- 792
					goto __continue86 -- 793
				end -- 793
				if s.h <= 64 and s.y <= 2 then -- 793
					self:drawCoverBlock( -- 798
						fgDraw, -- 798
						fgGlow, -- 798
						assets, -- 798
						x0, -- 798
						y0, -- 798
						sw, -- 798
						sh, -- 798
						s, -- 798
						p, -- 798
						theme -- 798
					) -- 798
					goto __continue86 -- 799
				end -- 799
				fillVGradRect( -- 802
					fgDraw, -- 802
					x0, -- 802
					y0, -- 802
					sw, -- 802
					sh, -- 802
					toColor(PALETTE.steelDark), -- 802
					toColor(PALETTE.steelMid) -- 802
				) -- 802
				self:tileMasonry( -- 803
					assets, -- 803
					s, -- 803
					x0, -- 803
					y0, -- 803
					sw, -- 803
					sh -- 803
				) -- 803
			end -- 803
			::__continue86:: -- 803
			i = i + 1 -- 727
		end -- 727
	end -- 727
end -- 715
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 807
	local width = right - left -- 811
	local base = cam:sy(solid.y, depth.min) -- 812
	local rearBase = cam:sy(solid.y, depth.max) -- 813
	local top = cam:sy(solid.y + solid.h, depth.min) -- 814
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 815
	local frontH = top - base -- 816
	local slot = coverArt(solid) -- 817
	local layer = depthOrder(depth.min, 1) -- 818
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 819
	local capHeight = rear - top -- 820
	local center = (left + right) * 0.5 -- 821
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 821
		self:drawWinch( -- 825
			draw, -- 825
			assets, -- 825
			left, -- 825
			base, -- 825
			width, -- 825
			frontH, -- 825
			p, -- 825
			layer -- 825
		) -- 825
		return -- 826
	end -- 826
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 826
		assets:tryPlace( -- 830
			"slab", -- 830
			"gate_sill_" .. tostring(solid.x), -- 830
			center, -- 830
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 830
			width + cam:len(34), -- 831
			cam:len(12), -- 831
			{ -- 831
				layer = 1, -- 831
				color = Color(180, 169, 150, 255) -- 831
			} -- 831
		) -- 831
	end -- 831
	draw:drawEllipse( -- 833
		Vec2( -- 833
			center, -- 833
			base + cam:len(2) -- 833
		), -- 833
		width * 0.5, -- 833
		math.max( -- 834
			2, -- 834
			cam:len(2.5) -- 834
		), -- 834
		Color(10, 10, 14, 128 * opacity) -- 834
	) -- 834
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 836
	if slot ~= "fence" and capHeight > 1 then -- 836
		local capTop = top + capHeight -- 840
		if not assets:tryPlace( -- 840
			slot, -- 841
			"cap_" .. tostring(solid.x), -- 841
			center, -- 841
			top, -- 841
			width, -- 841
			capHeight, -- 841
			{ -- 842
				opacity = math.min(1, opacity), -- 842
				layer = layer -- 842
			} -- 842
		) then -- 842
			local capFill = occlusionTint( -- 843
				opacity, -- 843
				timber and Color( -- 843
					74, -- 844
					56, -- 844
					42, -- 844
					math.floor(232 * opacity + 0.5) -- 844
				) or Color( -- 844
					74, -- 845
					78, -- 845
					86, -- 845
					math.floor(232 * opacity + 0.5) -- 845
				) -- 845
			) -- 845
			fillVGradRect( -- 846
				draw, -- 846
				left, -- 846
				top, -- 846
				width, -- 846
				capHeight, -- 846
				capFill, -- 847
				occlusionTint( -- 847
					opacity, -- 847
					Color( -- 847
						44, -- 847
						46, -- 847
						52, -- 847
						math.floor(220 * opacity + 0.5) -- 847
					) -- 847
				) -- 847
			) -- 847
		end -- 847
		draw:drawSegment( -- 849
			Vec2(left + width * 0.04, capTop - 0.5), -- 849
			Vec2(right - width * 0.04, capTop - 0.5), -- 849
			0.9, -- 850
			occlusionTint( -- 850
				opacity, -- 850
				timber and Color( -- 850
					122, -- 851
					96, -- 851
					72, -- 851
					math.floor(150 * opacity + 0.5) -- 851
				) or Color( -- 851
					118, -- 852
					124, -- 852
					132, -- 852
					math.floor(140 * opacity + 0.5) -- 852
				) -- 852
			) -- 852
		) -- 852
	end -- 852
	if timber and solid.h > solid.w * 1.6 then -- 852
		local colFill = occlusionTint( -- 857
			opacity, -- 857
			Color( -- 857
				66, -- 857
				48, -- 857
				36, -- 857
				math.floor(248 * opacity + 0.5) -- 857
			) -- 857
		) -- 857
		local colHi = occlusionTint( -- 858
			opacity, -- 858
			Color( -- 858
				122, -- 858
				92, -- 858
				68, -- 858
				math.floor(200 * opacity + 0.5) -- 858
			) -- 858
		) -- 858
		local colSh = occlusionTint( -- 859
			opacity, -- 859
			Color( -- 859
				34, -- 859
				24, -- 859
				18, -- 859
				math.floor(220 * opacity + 0.5) -- 859
			) -- 859
		) -- 859
		draw:drawRect( -- 860
			Rect(left, base, width, frontH), -- 860
			colFill, -- 860
			1, -- 860
			colHi -- 860
		) -- 860
		draw:drawRect( -- 861
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 861
			colSh -- 861
		) -- 861
		draw:drawSegment( -- 862
			Vec2(left + width * 0.32, base + 2), -- 862
			Vec2(left + width * 0.32, top - 2), -- 862
			0.9, -- 862
			colHi -- 862
		) -- 862
		return -- 863
	end -- 863
	if solid.w > solid.h * 5 then -- 863
		local beamFill = occlusionTint( -- 868
			opacity, -- 868
			Color( -- 868
				78, -- 868
				58, -- 868
				42, -- 868
				math.floor(248 * opacity + 0.5) -- 868
			) -- 868
		) -- 868
		local beamEdge = occlusionTint( -- 869
			opacity, -- 869
			Color( -- 869
				142, -- 869
				110, -- 869
				82, -- 869
				math.floor(215 * opacity + 0.5) -- 869
			) -- 869
		) -- 869
		draw:drawRect( -- 870
			Rect( -- 870
				left, -- 870
				base, -- 870
				width, -- 870
				math.max(4, frontH) -- 870
			), -- 870
			beamFill, -- 870
			1, -- 870
			beamEdge -- 870
		) -- 870
		local posts = math.max( -- 871
			2, -- 871
			math.floor(solid.w / 140 + 0.5) -- 871
		) -- 871
		do -- 871
			local pi = 0 -- 872
			while pi <= posts do -- 872
				local px = left + width * pi / posts -- 873
				draw:drawSegment( -- 874
					Vec2(px, base), -- 874
					Vec2(px, top), -- 874
					1.4, -- 874
					Color( -- 874
						34, -- 874
						24, -- 874
						18, -- 874
						math.floor(210 * opacity + 0.5) -- 874
					) -- 874
				) -- 874
				pi = pi + 1 -- 872
			end -- 872
		end -- 872
		return -- 876
	end -- 876
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 880
	local cols = slot == "wall" and math.max( -- 881
		1, -- 882
		math.min( -- 882
			10, -- 882
			math.floor(solid.w / 72 + 0.5) -- 882
		) -- 882
	) or math.max( -- 882
		1, -- 883
		math.min( -- 883
			10, -- 883
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 883
		) -- 883
	) -- 883
	local colW = width / cols -- 884
	local rows = slot == "wall" and math.max( -- 885
		1, -- 886
		math.min( -- 886
			10, -- 886
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 886
		) -- 886
	) or math.max( -- 886
		1, -- 887
		math.min( -- 887
			6, -- 887
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 887
		) -- 887
	) -- 887
	local rowHeight = frontH / rows -- 888
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 889
	local color = occlusionTint(opacity, masonryColor) -- 890
	local placedAny = false -- 891
	do -- 891
		local row = 0 -- 892
		while row < rows do -- 892
			do -- 892
				local col = 0 -- 893
				while col < cols do -- 893
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 894
					if assets:tryPlace( -- 894
						slot, -- 895
						tileKey, -- 895
						left + (col + 0.5) * colW, -- 895
						base + row * rowHeight, -- 895
						colW + 0.5, -- 895
						rowHeight + 0.5, -- 895
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 895
					) then -- 895
						placedAny = true -- 898
					end -- 898
					col = col + 1 -- 893
				end -- 893
			end -- 893
			row = row + 1 -- 892
		end -- 892
	end -- 892
	if not placedAny then -- 892
		draw:drawRect( -- 903
			Rect(left, base, width, frontH), -- 903
			occlusionTint( -- 904
				opacity, -- 904
				toColor(PALETTE.steelMid, 255 * opacity) -- 904
			), -- 904
			1, -- 905
			toColor(theme.groundRim, 150 * opacity) -- 905
		) -- 905
	end -- 905
end -- 807
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 909
	local columns = math.max( -- 914
		1, -- 914
		math.min( -- 914
			10, -- 914
			math.floor(s.w / 58 + 0.5) -- 914
		) -- 914
	) -- 914
	local cellWorldW = s.w / columns -- 915
	local targetCellH = math.max( -- 916
		24, -- 916
		math.min(48, cellWorldW / 1.52) -- 916
	) -- 916
	local rows = math.max( -- 917
		1, -- 917
		math.min( -- 917
			12, -- 917
			math.floor(s.h / targetCellH + 0.5) -- 917
		) -- 917
	) -- 917
	local tileW = width / columns -- 918
	local tileH = height / rows -- 919
	do -- 919
		local row = 0 -- 920
		while row < rows do -- 920
			do -- 920
				local column = 0 -- 921
				while column < columns do -- 921
					assets:tryPlace( -- 922
						"wall", -- 922
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 922
						x + (column + 0.5) * tileW, -- 923
						y + row * tileH, -- 923
						tileW + 0.5, -- 923
						tileH + 0.5, -- 923
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 924
					) -- 924
					column = column + 1 -- 921
				end -- 921
			end -- 921
			row = row + 1 -- 920
		end -- 920
	end -- 920
end -- 909
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 929
	local slot = coverArt(s) -- 936
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 937
	local cols = math.max( -- 938
		1, -- 938
		math.min( -- 938
			8, -- 938
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 938
		) -- 938
	) -- 938
	local tileW = sw / cols -- 939
	local placed = false -- 940
	do -- 940
		local c = 0 -- 941
		while c < cols do -- 941
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 942
			if assets:tryPlace( -- 942
				slot, -- 943
				k, -- 943
				x0 + (c + 0.5) * tileW, -- 943
				y0, -- 943
				tileW + 0.5, -- 943
				sh, -- 943
				{layer = 1} -- 943
			) then -- 943
				placed = true -- 944
			end -- 944
			c = c + 1 -- 941
		end -- 941
	end -- 941
	if not placed then -- 941
		fillVGradRect( -- 948
			fgDraw, -- 948
			x0, -- 948
			y0, -- 948
			sw, -- 948
			sh, -- 948
			toColor(PALETTE.steelDark), -- 948
			toColor(PALETTE.steelMid) -- 948
		) -- 948
		fgDraw:drawSegment( -- 949
			Vec2(x0, y0 + sh), -- 949
			Vec2(x0 + sw, y0 + sh), -- 949
			1.4, -- 949
			toColor(theme.groundRim) -- 949
		) -- 949
	end -- 949
	if not p.childMode and (p.coverHug or p.coverNear) then -- 949
		local plx = p.player.x -- 954
		local nearLeft = math.abs(plx - s.x) < 42 -- 955
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 956
		if nearLeft or nearRight then -- 956
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 958
			local isWood = slot == "cover_wood" -- 959
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 960
			fgDraw:drawSegment( -- 961
				Vec2(edgeX, y0 + 4), -- 961
				Vec2(edgeX, y0 + sh + 2), -- 961
				p.coverHug and 2 or 1.2, -- 961
				toColor(col, p.coverHug and 205 or 120) -- 961
			) -- 961
		end -- 961
	end -- 961
end -- 929
function StageRenderer.prototype.drawRedCartPixel(self, draw, x0, y0, sw, sh, cam) -- 970
	local bodyH = math.max(6, sh * 0.62) -- 973
	local bodyY = y0 + sh - bodyH -- 974
	draw:drawRect( -- 975
		Rect(x0, bodyY, sw, bodyH), -- 975
		Color(92, 70, 52, 248), -- 975
		1, -- 975
		Color(150, 118, 86, 215) -- 975
	) -- 975
	draw:drawRect( -- 976
		Rect( -- 976
			x0 - cam:len(3), -- 976
			bodyY + cam:len(1), -- 976
			sw + cam:len(8), -- 976
			bodyH * 0.92 -- 976
		), -- 976
		toColor(PALETTE.clothRed), -- 977
		1, -- 977
		toColor(PALETTE.clothRedHighlight) -- 977
	) -- 977
	draw:drawRect( -- 978
		Rect(x0 + sw * 0.16, bodyY + bodyH * 0.36, sw * 0.24, bodyH * 0.32), -- 978
		Color(214, 206, 188, 215) -- 979
	) -- 979
	draw:drawRect( -- 980
		Rect(x0 + sw * 0.58, bodyY + bodyH * 0.52, sw * 0.18, bodyH * 0.22), -- 980
		Color(196, 188, 172, 200) -- 981
	) -- 981
	draw:drawSegment( -- 982
		Vec2( -- 982
			x0 + sw - cam:len(2), -- 982
			bodyY + bodyH * 0.72 -- 982
		), -- 982
		Vec2( -- 983
			x0 + sw + cam:len(26), -- 983
			bodyY + bodyH * 1.36 -- 983
		), -- 983
		math.max( -- 984
			2, -- 984
			cam:len(2.6) -- 984
		), -- 984
		Color(126, 98, 68, 240) -- 984
	) -- 984
	draw:drawEllipse( -- 985
		Vec2( -- 985
			x0 + sw * 0.26, -- 985
			y0 + sh - cam:len(1) -- 985
		), -- 985
		cam:len(5.2), -- 985
		cam:len(5.2), -- 985
		Color(40, 34, 30, 235) -- 986
	) -- 986
	draw:drawEllipse( -- 987
		Vec2( -- 987
			x0 + sw * 0.26, -- 987
			y0 + sh - cam:len(1) -- 987
		), -- 987
		cam:len(2.1), -- 987
		cam:len(2.1), -- 987
		Color(150, 126, 92, 220) -- 988
	) -- 988
end -- 970
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 991
	if layer == nil then -- 991
		layer = 2 -- 996
	end -- 996
	local cx = x0 + sw * 0.5 -- 998
	local cy = y0 + sh * 0.55 -- 999
	local ropeWidth = math.max(1, sw * 0.023) -- 1000
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 1001
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 1002
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 1003
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 1004
	draw:drawEllipse( -- 1005
		Vec2(cx, y0), -- 1005
		sw * 0.53, -- 1005
		sh * 0.07, -- 1005
		Color(10, 8, 9, 150) -- 1005
	) -- 1005
	draw:drawSegment( -- 1006
		drum, -- 1006
		bend, -- 1006
		ropeWidth, -- 1006
		Color(111, 86, 57, 239) -- 1006
	) -- 1006
	draw:drawSegment( -- 1007
		bend, -- 1007
		ropeTop, -- 1007
		ropeWidth, -- 1007
		Color(111, 86, 57, 239) -- 1007
	) -- 1007
	if assets:tryPlace( -- 1007
		"prop_winch", -- 1008
		"gate_winch", -- 1008
		cx, -- 1008
		y0 + sh * 0.5, -- 1008
		sw, -- 1008
		sh, -- 1008
		{layer = layer} -- 1008
	) then -- 1008
		return -- 1009
	end -- 1009
	local timber = Color(75, 51, 34, 255) -- 1011
	draw:drawSegment( -- 1012
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 1012
		Vec2(cx, y0 + sh * 0.86), -- 1012
		sw * 0.06, -- 1012
		timber -- 1012
	) -- 1012
	draw:drawSegment( -- 1013
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 1013
		Vec2(cx, y0 + sh * 0.86), -- 1013
		sw * 0.06, -- 1013
		timber -- 1013
	) -- 1013
	draw:drawRect( -- 1014
		Rect(x0, y0, sw, sh * 0.12), -- 1014
		timber -- 1014
	) -- 1014
	local radius = math.min(sw, sh) * 0.21 -- 1015
	draw:drawCircle( -- 1016
		Vec2(cx, cy), -- 1016
		radius, -- 1016
		Color(48, 41, 37, 255) -- 1016
	) -- 1016
	do -- 1016
		local i = -2 -- 1017
		while i <= 2 do -- 1017
			local x = cx + i * radius * 0.28 -- 1018
			draw:drawSegment( -- 1019
				Vec2(x, cy - radius * 0.62), -- 1019
				Vec2(x, cy + radius * 0.62), -- 1019
				ropeWidth, -- 1019
				Color(135, 103, 68, 240) -- 1020
			) -- 1020
			i = i + 1 -- 1017
		end -- 1017
	end -- 1017
end -- 991
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 1024
	local ____temp_3 -- 1032
	if p.room.story ~= nil then -- 1032
		____temp_3 = p.room.story.gate -- 1032
	else -- 1032
		____temp_3 = nil -- 1032
	end -- 1032
	local g = ____temp_3 -- 1032
	if g == nil then -- 1032
		return -- 1034
	end -- 1034
	local closeFrac = 0.08 -- 1037
	if p.phase == "gate-hold" then -- 1037
		closeFrac = 0.08 + 0.36 * math.min( -- 1039
			1, -- 1039
			p.gateTick / math.max(1, g.holdTicks) -- 1039
		) -- 1039
	elseif p.phase == "gate-send" then -- 1039
		closeFrac = 0.44 -- 1041
	elseif p.phase == "gate-count" then -- 1041
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 1043
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 1043
		closeFrac = 1 -- 1045
	end -- 1045
	local gx0 = cam:sx(848) -- 1047
	local gx1 = cam:sx(1032) -- 1048
	local topY = cam:sy(160) -- 1049
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1050
	local shutterW = gx1 - gx0 -- 1051
	local shutterH = topY - botY -- 1052
	if shutterH > 2 then -- 1052
		fillVGradRect( -- 1054
			fgDraw, -- 1054
			gx0, -- 1054
			botY, -- 1054
			shutterW, -- 1054
			shutterH, -- 1054
			toColor(PALETTE.steelDark), -- 1054
			toColor(PALETTE.steelMid) -- 1054
		) -- 1054
		local rows = math.max( -- 1056
			1, -- 1056
			math.min( -- 1056
				6, -- 1056
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1056
			) -- 1056
		) -- 1056
		local rowH = shutterH / rows -- 1057
		do -- 1057
			local r = 0 -- 1058
			while r < rows do -- 1058
				assets:tryPlace( -- 1059
					"cover_wood", -- 1059
					"gate_shutter_" .. tostring(r), -- 1059
					(gx0 + gx1) * 0.5, -- 1059
					botY + r * rowH, -- 1059
					shutterW, -- 1060
					rowH + 0.5, -- 1060
					{layer = 6} -- 1060
				) -- 1060
				r = r + 1 -- 1058
			end -- 1058
		end -- 1058
	end -- 1058
	if closeFrac < 0.98 then -- 1058
		local gapH = math.max( -- 1065
			8, -- 1065
			botY - cam:sy(0) -- 1065
		) -- 1065
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1066
		fillVGradRect( -- 1067
			fgGlow, -- 1067
			gx0, -- 1067
			cam:sy(0), -- 1067
			gx1 - gx0, -- 1067
			gapH, -- 1067
			Color( -- 1067
				140, -- 1067
				210, -- 1067
				255, -- 1067
				math.floor(52 * pulse + 0.5) -- 1067
			), -- 1067
			Color(80, 160, 230, 0) -- 1067
		) -- 1067
	end -- 1067
end -- 1024
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1071
	fillVGradRect( -- 1078
		fgDraw, -- 1078
		x0, -- 1078
		y0, -- 1078
		sw, -- 1078
		sh, -- 1078
		Color(15, 21, 34, 255), -- 1078
		Color(32, 44, 66, 255) -- 1078
	) -- 1078
	fgDraw:drawRect( -- 1079
		Rect(x0, y0, sw, sh), -- 1079
		Color(0, 0, 0, 0), -- 1079
		1.4, -- 1079
		toColor(PALETTE.rimSilver, 165) -- 1079
	) -- 1079
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1079
		self:tileMasonry( -- 1082
			assets, -- 1082
			s, -- 1082
			x0, -- 1082
			y0, -- 1082
			sw, -- 1082
			sh -- 1082
		) -- 1082
		local ribs = 4 -- 1084
		local r = 1 -- 1085
		do -- 1085
			r = 1 -- 1086
			while r < ribs do -- 1086
				local rx = x0 + sw * r / ribs -- 1087
				fgDraw:drawSegment( -- 1088
					Vec2(rx, y0), -- 1088
					Vec2(rx, y0 + sh), -- 1088
					2, -- 1088
					Color(10, 15, 24, 210) -- 1088
				) -- 1088
				fgDraw:drawSegment( -- 1089
					Vec2(rx + 2, y0), -- 1089
					Vec2(rx + 2, y0 + sh), -- 1089
					1, -- 1089
					Color(68, 86, 114, 130) -- 1089
				) -- 1089
				r = r + 1 -- 1086
			end -- 1086
		end -- 1086
		local bands = 4 -- 1092
		local b = 1 -- 1093
		do -- 1093
			b = 1 -- 1094
			while b < bands do -- 1094
				local by = y0 + sh * b / bands -- 1095
				fgDraw:drawSegment( -- 1096
					Vec2(x0 + 4, by), -- 1096
					Vec2(x0 + sw - 4, by), -- 1096
					1.2, -- 1096
					Color(52, 68, 92, 135) -- 1096
				) -- 1096
				b = b + 1 -- 1094
			end -- 1094
		end -- 1094
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1099
		local slitY = y0 + sh * 0.56 -- 1100
		local slitH = sh * 0.22 -- 1101
		fgDraw:drawRect( -- 1102
			Rect(slitX - 5, slitY, 10, slitH), -- 1102
			Color(8, 12, 20, 245), -- 1102
			1.2, -- 1102
			toColor(PALETTE.amberDim, 190) -- 1102
		) -- 1102
		fgGlow:drawRect( -- 1103
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1103
			toColor(PALETTE.amber, 190) -- 1103
		) -- 1103
		fillRadialGlow( -- 1104
			fgGlow, -- 1104
			slitX, -- 1104
			slitY + slitH * 0.5, -- 1104
			44, -- 1104
			slitH * 0.7, -- 1104
			Color(255, 206, 128, 52), -- 1104
			Color(255, 180, 86, 0), -- 1104
			14 -- 1104
		) -- 1104
	end -- 1104
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1104
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1109
		local cx = x0 + sw * 0.5 -- 1114
		local lampY = y0 - 8 -- 1115
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1116
		if not opened then -- 1116
			assets:tryPlace( -- 1118
				"prop_tower_door", -- 1118
				"tower_door", -- 1118
				cx, -- 1118
				y0 - doorHeight, -- 1118
				sw, -- 1118
				doorHeight, -- 1118
				{layer = 2} -- 1118
			) -- 1118
		end -- 1118
		assets:tryPlace( -- 1120
			"prop_lantern", -- 1120
			"tower_lantern", -- 1120
			cx + sw * 0.43, -- 1120
			lampY - sh * 0.36, -- 1120
			sw * 0.17, -- 1121
			sh * 0.84, -- 1121
			{layer = 3} -- 1121
		) -- 1121
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1122
		local alpha = opened and 155 or 88 -- 1123
		fgDraw:drawSegment( -- 1125
			Vec2(x0 + 4, y0), -- 1125
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1125
			4, -- 1125
			Color(42, 52, 70, 255) -- 1125
		) -- 1125
		fgDraw:drawSegment( -- 1126
			Vec2(x0 + sw - 4, y0), -- 1126
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1126
			4, -- 1126
			Color(42, 52, 70, 255) -- 1126
		) -- 1126
		fgDraw:drawSegment( -- 1127
			Vec2(x0, y0), -- 1127
			Vec2(x0 + sw, y0), -- 1127
			2.5, -- 1127
			toColor(PALETTE.amber, 210) -- 1127
		) -- 1127
		fillVGradRect( -- 1129
			fgGlow, -- 1130
			x0 + 6, -- 1131
			y0 - sh * 3.8, -- 1132
			sw - 12, -- 1133
			sh * 3.8, -- 1134
			Color( -- 1135
				255, -- 1135
				206, -- 1135
				128, -- 1135
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 1135
			), -- 1135
			Color(255, 224, 168, opened and 180 or 62) -- 1136
		) -- 1136
		fillRadialGlow( -- 1138
			fgGlow, -- 1138
			cx, -- 1138
			lampY, -- 1138
			opened and 105 or 58, -- 1138
			opened and 105 or 58, -- 1138
			Color( -- 1138
				255, -- 1138
				232, -- 1138
				178, -- 1138
				math.floor(170 * pulse + 0.5) -- 1138
			), -- 1138
			Color(255, 180, 86, 0), -- 1138
			18 -- 1138
		) -- 1138
		fgDraw:drawCircle( -- 1139
			Vec2(cx, lampY), -- 1139
			5.5, -- 1139
			toColor(PALETTE.amberCore) -- 1139
		) -- 1139
		if opened then -- 1139
			local deskCx = cam:sx(p.ox + 605) -- 1143
			local groundY = cam:sy(0) -- 1144
			local deskW = cam:len(84) -- 1145
			local deskH = cam:len(34) -- 1146
			local deskTop = groundY + deskH -- 1147
			fillRadialGlow( -- 1149
				fgGlow, -- 1149
				deskCx, -- 1149
				deskTop + cam:len(32), -- 1149
				cam:len(115), -- 1149
				cam:len(90), -- 1149
				Color( -- 1150
					255, -- 1150
					198, -- 1150
					114, -- 1150
					math.floor(68 * pulse + 0.5) -- 1150
				), -- 1150
				Color(255, 168, 72, 0), -- 1150
				16 -- 1150
			) -- 1150
			local guardX = deskCx + cam:len(26) -- 1152
			fgDraw:drawRect( -- 1153
				Rect( -- 1153
					guardX - cam:len(11), -- 1153
					groundY, -- 1153
					cam:len(22), -- 1153
					cam:len(68) -- 1153
				), -- 1153
				Color(34, 42, 54, 240) -- 1153
			) -- 1153
			fgDraw:drawCircle( -- 1154
				Vec2( -- 1154
					guardX, -- 1154
					groundY + cam:len(76) -- 1154
				), -- 1154
				cam:len(9.5), -- 1154
				Color(42, 50, 62, 245) -- 1154
			) -- 1154
			fgDraw:drawRect( -- 1156
				Rect( -- 1156
					deskCx - deskW * 0.5, -- 1156
					groundY, -- 1156
					cam:len(6), -- 1156
					deskH -- 1156
				), -- 1156
				Color(78, 52, 34, 255) -- 1156
			) -- 1156
			fgDraw:drawRect( -- 1157
				Rect( -- 1157
					deskCx + deskW * 0.5 - cam:len(6), -- 1157
					groundY, -- 1157
					cam:len(6), -- 1157
					deskH -- 1157
				), -- 1157
				Color(78, 52, 34, 255) -- 1157
			) -- 1157
			fgDraw:drawRect( -- 1158
				Rect( -- 1158
					deskCx - deskW * 0.52, -- 1158
					deskTop - cam:len(6), -- 1158
					deskW * 1.04, -- 1158
					cam:len(8) -- 1158
				), -- 1158
				Color(108, 74, 46, 255), -- 1158
				1, -- 1158
				Color(148, 108, 68, 220) -- 1158
			) -- 1158
			fgDraw:drawRect( -- 1160
				Rect( -- 1160
					deskCx + cam:len(4), -- 1160
					deskTop + cam:len(2), -- 1160
					cam:len(24), -- 1160
					cam:len(5) -- 1160
				), -- 1160
				Color(232, 222, 198, 245) -- 1160
			) -- 1160
			fgDraw:drawRect( -- 1161
				Rect( -- 1161
					deskCx + cam:len(32), -- 1161
					deskTop + cam:len(2), -- 1161
					cam:len(8), -- 1161
					cam:len(12) -- 1161
				), -- 1161
				Color(168, 128, 64, 245) -- 1161
			) -- 1161
			fgGlow:drawCircle( -- 1162
				Vec2( -- 1162
					deskCx + cam:len(36), -- 1162
					deskTop + cam:len(16) -- 1162
				), -- 1162
				cam:len(5.5), -- 1162
				Color( -- 1162
					255, -- 1162
					224, -- 1162
					152, -- 1162
					math.floor(220 * pulse + 0.5) -- 1162
				) -- 1162
			) -- 1162
			if p.deskHold >= 12 or p.towerHanded then -- 1162
				fgDraw:drawRect( -- 1165
					Rect( -- 1165
						deskCx - cam:len(28), -- 1165
						deskTop + cam:len(2), -- 1165
						cam:len(14), -- 1165
						cam:len(6) -- 1165
					), -- 1165
					Color(156, 62, 48, 245) -- 1165
				) -- 1165
			end -- 1165
			if p.deskHold >= 24 or p.towerHanded then -- 1165
				fgDraw:drawCircle( -- 1168
					Vec2( -- 1168
						deskCx - cam:len(8), -- 1168
						deskTop + cam:len(5) -- 1168
					), -- 1168
					cam:len(4.5), -- 1168
					Color(224, 186, 98, 255) -- 1168
				) -- 1168
				fgDraw:drawRect( -- 1169
					Rect( -- 1169
						deskCx - cam:len(16), -- 1169
						deskTop + cam:len(2), -- 1169
						cam:len(10), -- 1169
						cam:len(3) -- 1169
					), -- 1169
					Color(236, 228, 206, 240) -- 1169
				) -- 1169
			end -- 1169
		end -- 1169
	end -- 1169
end -- 1071
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1175
	local blades = math.max( -- 1182
		12, -- 1182
		math.floor(sw / 8) -- 1182
	) -- 1182
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1183
	local k = 0 -- 1184
	do -- 1184
		k = 0 -- 1185
		while k < blades do -- 1185
			local t = (k + 0.5) / blades -- 1186
			local bx = x0 + sw * t -- 1187
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1188
			local bh = sh * hRatio * 1.95 -- 1189
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1190
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1191
			fgDraw:drawPolygon( -- 1192
				{ -- 1192
					Vec2(bx - 7, y0), -- 1193
					Vec2(bx + 7, y0), -- 1194
					Vec2(bx + sway, y0 + bh) -- 1195
				}, -- 1195
				col -- 1196
			) -- 1196
			k = k + 1 -- 1185
		end -- 1185
	end -- 1185
	if nearPlayer then -- 1185
		fgGlow:drawSegment( -- 1199
			Vec2(x0, y0 + 2), -- 1199
			Vec2(x0 + sw, y0 + 2), -- 1199
			2, -- 1199
			toColor(PALETTE.emerald, 145) -- 1199
		) -- 1199
	end -- 1199
end -- 1175
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1203
	local a = p.room.arch -- 1208
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1208
		return -- 1210
	end -- 1210
	local x0 = cam:sx(a.x0) -- 1212
	local x1 = cam:sx(a.x1) -- 1213
	local y0 = cam:sy(a.y) -- 1214
	local y1 = cam:sy(a.y + a.h) -- 1215
	local cx = (x0 + x1) * 0.5 -- 1216
	local rx = (x1 - x0) * 0.5 -- 1217
	local rise = cam:len(9) -- 1218
	local rim = cam:len(7) -- 1219
	local slices = 9 -- 1220
	local mortar = Color(31, 32, 35, 255) -- 1221
	local function point(i, edge) -- 1222
		local angle = math.pi * i / slices -- 1223
		return Vec2( -- 1224
			cx + math.cos(angle) * (rx + edge), -- 1224
			y1 + math.sin(angle) * (rise + edge) -- 1224
		) -- 1224
	end -- 1222
	local opening = { -- 1226
		Vec2(x0, y0), -- 1226
		Vec2(x1, y0) -- 1226
	} -- 1226
	do -- 1226
		local i = 0 -- 1227
		while i <= slices do -- 1227
			opening[#opening + 1] = point(i, 0) -- 1228
			i = i + 1 -- 1227
		end -- 1227
	end -- 1227
	draw:drawPolygon( -- 1230
		opening, -- 1230
		Color(13, 15, 20, 248) -- 1230
	) -- 1230
	draw:drawRect( -- 1231
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1231
		Color(62, 63, 67, 255), -- 1231
		1, -- 1231
		mortar -- 1231
	) -- 1231
	draw:drawRect( -- 1232
		Rect(x1, y0, rim, y1 - y0), -- 1232
		Color(72, 72, 74, 255), -- 1232
		1, -- 1232
		mortar -- 1232
	) -- 1232
	do -- 1232
		local i = 0 -- 1233
		while i < slices do -- 1233
			local shade = 77 + i % 3 * 8 -- 1234
			draw:drawPolygon( -- 1235
				{ -- 1235
					point(i, 0), -- 1235
					point(i, rim), -- 1235
					point(i + 1, rim), -- 1235
					point(i + 1, 0) -- 1235
				}, -- 1235
				Color(shade, shade, shade + 1, 255), -- 1236
				1, -- 1236
				mortar -- 1236
			) -- 1236
			i = i + 1 -- 1233
		end -- 1233
	end -- 1233
	if not p.cartDocked then -- 1233
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1240
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1241
		if bx1 > bx0 + 4 then -- 1241
			local deckY = cam:sy(p.room.cart.baseY) -- 1243
			draw:drawRect( -- 1244
				Rect(bx0, y0 + 2, bx1 - bx0, y1 - y0 - 2), -- 1244
				Color(72, 52, 36, 245), -- 1244
				1.1, -- 1244
				Color(138, 108, 78, 210) -- 1244
			) -- 1244
			draw:drawSegment( -- 1245
				Vec2((bx0 + bx1) * 0.5, y1), -- 1245
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1245
				2.4, -- 1245
				Color(96, 102, 110, 220) -- 1245
			) -- 1245
		end -- 1245
	end -- 1245
end -- 1203
return ____exports -- 1203