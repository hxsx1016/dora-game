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
	self:drawArch(fgDraw, assets, p, cam) -- 262
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
function StageRenderer.prototype.drawRoad(self, draw, assets, floorIdx, left, right, front, back, cam, theme) -- 595
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
	local bands = {0, 0.34, 0.68, 1} -- 610
	local visLeft = math.max(left, -40) -- 611
	local visRight = math.min(right, cam.viewW + 40) -- 612
	do -- 612
		local row = 0 -- 613
		while row < #bands - 1 do -- 613
			local y0 = front + bands[row + 1] * height -- 614
			local y1 = front + bands[row + 1 + 1] * height -- 615
			local rowH = y1 - y0 -- 616
			local slabWidth = math.max( -- 617
				36, -- 617
				cam:len(86 - row * 12) -- 617
			) -- 617
			local offset = left - row % 2 * slabWidth * 0.5 -- 618
			local start = math.max( -- 619
				0, -- 619
				math.floor((visLeft - offset) / slabWidth) -- 619
			) -- 619
			local shade = 224 - row * 34 -- 620
			local tint = Color( -- 621
				shade, -- 621
				shade + 4, -- 621
				math.min(255, shade + 12), -- 621
				255 -- 621
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
						assets:tryPlace( -- 629
							"fe_road_stone", -- 629
							(((("road_" .. tostring(floorIdx)) .. "_") .. tostring(row)) .. "_") .. tostring(col), -- 629
							sx0 + sw * 0.5, -- 629
							y0, -- 629
							sw + 0.5, -- 629
							rowH + 0.5, -- 629
							{color = tint, opacity = 0.92, facing = (row + col) % 2 == 0 and 1 or -1, layer = -2} -- 629
						) -- 629
					end -- 629
					::__continue69:: -- 629
					col = col + 1 -- 622
				end -- 622
			end -- 622
			row = row + 1 -- 613
		end -- 613
	end -- 613
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
				if s.h <= 64 and s.y <= 2 then -- 787
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
	if solid.y <= 2 and rearBase > base + 1 then -- 815
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
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 823
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
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 830
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
	if slot ~= "fence" and capHeight > 1 then -- 840
		local capFill = occlusionTint( -- 844
			opacity, -- 844
			timber and Color( -- 844
				88, -- 845
				68, -- 845
				52, -- 845
				math.floor(240 * opacity + 0.5) -- 845
			) or Color( -- 845
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
			) or Color( -- 848
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
		if capHeight > 8 then -- 851
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
	if timber and solid.h > solid.w * 1.6 then -- 854
		local segs = math.max( -- 860
			1, -- 860
			math.min( -- 860
				6, -- 860
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 860
			) -- 860
		) -- 860
		local segH = frontH / segs -- 861
		local colTint = occlusionTint(opacity) -- 862
		do -- 862
			local pi = 0 -- 863
			while pi < segs do -- 863
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 864
				assets:tryPlace( -- 865
					"fe_pillar_wood", -- 865
					tk, -- 865
					center, -- 865
					base + pi * segH, -- 865
					width + 0.5, -- 865
					segH + 0.5, -- 865
					{layer = layer, opacity = opacity, color = colTint} -- 865
				) -- 865
				pi = pi + 1 -- 863
			end -- 863
		end -- 863
		return -- 869
	end -- 869
	if solid.w > solid.h * 5 then -- 869
		local segs = math.max( -- 874
			2, -- 874
			math.min( -- 874
				12, -- 874
				math.floor(solid.w / 64 + 0.5) -- 874
			) -- 874
		) -- 874
		local segW = width / segs -- 875
		local beamH = math.max(5, frontH) -- 876
		local beamTint = occlusionTint(opacity) -- 877
		do -- 877
			local bi = 0 -- 878
			while bi < segs do -- 878
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 879
				assets:tryPlace( -- 880
					"fe_beam_wood", -- 880
					tk, -- 880
					left + (bi + 0.5) * segW, -- 880
					base, -- 880
					segW + 0.5, -- 880
					beamH, -- 880
					{layer = layer, opacity = opacity, color = beamTint} -- 880
				) -- 880
				bi = bi + 1 -- 878
			end -- 878
		end -- 878
		return -- 884
	end -- 884
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 888
	local cols = slot == "wall" and math.max( -- 889
		1, -- 890
		math.min( -- 890
			10, -- 890
			math.floor(solid.w / 72 + 0.5) -- 890
		) -- 890
	) or math.max( -- 890
		1, -- 891
		math.min( -- 891
			10, -- 891
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 891
		) -- 891
	) -- 891
	local colW = width / cols -- 892
	local rows = slot == "wall" and math.max( -- 893
		1, -- 894
		math.min( -- 894
			10, -- 894
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 894
		) -- 894
	) or math.max( -- 894
		1, -- 895
		math.min( -- 895
			6, -- 895
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 895
		) -- 895
	) -- 895
	local rowHeight = frontH / rows -- 896
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 897
	local color = occlusionTint(opacity, masonryColor) -- 898
	local placedAny = false -- 899
	do -- 899
		local row = 0 -- 900
		while row < rows do -- 900
			do -- 900
				local col = 0 -- 901
				while col < cols do -- 901
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 902
					if assets:tryPlace( -- 902
						slot, -- 903
						tileKey, -- 903
						left + (col + 0.5) * colW, -- 903
						base + row * rowHeight, -- 903
						colW + 0.5, -- 903
						rowHeight + 0.5, -- 903
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 903
					) then -- 903
						placedAny = true -- 906
					end -- 906
					col = col + 1 -- 901
				end -- 901
			end -- 901
			row = row + 1 -- 900
		end -- 900
	end -- 900
	if not placedAny then -- 900
		draw:drawRect( -- 911
			Rect(left, base, width, frontH), -- 911
			occlusionTint( -- 912
				opacity, -- 912
				toColor(PALETTE.steelMid, 255 * opacity) -- 912
			), -- 912
			1, -- 913
			toColor(theme.groundRim, 150 * opacity) -- 913
		) -- 913
	end -- 913
end -- 801
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 917
	local columns = math.max( -- 922
		1, -- 922
		math.min( -- 922
			10, -- 922
			math.floor(s.w / 58 + 0.5) -- 922
		) -- 922
	) -- 922
	local cellWorldW = s.w / columns -- 923
	local targetCellH = math.max( -- 924
		24, -- 924
		math.min(48, cellWorldW / 1.52) -- 924
	) -- 924
	local rows = math.max( -- 925
		1, -- 925
		math.min( -- 925
			12, -- 925
			math.floor(s.h / targetCellH + 0.5) -- 925
		) -- 925
	) -- 925
	local tileW = width / columns -- 926
	local tileH = height / rows -- 927
	do -- 927
		local row = 0 -- 928
		while row < rows do -- 928
			do -- 928
				local column = 0 -- 929
				while column < columns do -- 929
					assets:tryPlace( -- 930
						"wall", -- 930
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 930
						x + (column + 0.5) * tileW, -- 931
						y + row * tileH, -- 931
						tileW + 0.5, -- 931
						tileH + 0.5, -- 931
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 932
					) -- 932
					column = column + 1 -- 929
				end -- 929
			end -- 929
			row = row + 1 -- 928
		end -- 928
	end -- 928
end -- 917
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 937
	local slot = coverArt(s) -- 944
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 945
	local cols = math.max( -- 946
		1, -- 946
		math.min( -- 946
			8, -- 946
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 946
		) -- 946
	) -- 946
	local tileW = sw / cols -- 947
	local placed = false -- 948
	do -- 948
		local c = 0 -- 949
		while c < cols do -- 949
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 950
			if assets:tryPlace( -- 950
				slot, -- 951
				k, -- 951
				x0 + (c + 0.5) * tileW, -- 951
				y0, -- 951
				tileW + 0.5, -- 951
				sh, -- 951
				{layer = 1} -- 951
			) then -- 951
				placed = true -- 952
			end -- 952
			c = c + 1 -- 949
		end -- 949
	end -- 949
	if not placed then -- 949
		fillVGradRect( -- 956
			fgDraw, -- 956
			x0, -- 956
			y0, -- 956
			sw, -- 956
			sh, -- 956
			toColor(PALETTE.steelDark), -- 956
			toColor(PALETTE.steelMid) -- 956
		) -- 956
		fgDraw:drawSegment( -- 957
			Vec2(x0, y0 + sh), -- 957
			Vec2(x0 + sw, y0 + sh), -- 957
			1.4, -- 957
			toColor(theme.groundRim) -- 957
		) -- 957
	end -- 957
	if not p.childMode and (p.coverHug or p.coverNear) then -- 957
		local plx = p.player.x -- 962
		local nearLeft = math.abs(plx - s.x) < 42 -- 963
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 964
		if nearLeft or nearRight then -- 964
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 966
			local isWood = slot == "cover_wood" -- 967
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 968
			fgDraw:drawSegment( -- 969
				Vec2(edgeX, y0 + 4), -- 969
				Vec2(edgeX, y0 + sh + 2), -- 969
				p.coverHug and 2 or 1.2, -- 969
				toColor(col, p.coverHug and 205 or 120) -- 969
			) -- 969
		end -- 969
	end -- 969
end -- 937
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 974
	if layer == nil then -- 974
		layer = 2 -- 979
	end -- 979
	local cx = x0 + sw * 0.5 -- 981
	local cy = y0 + sh * 0.55 -- 982
	local ropeWidth = math.max(1, sw * 0.023) -- 983
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 984
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 985
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 986
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 987
	draw:drawEllipse( -- 988
		Vec2(cx, y0), -- 988
		sw * 0.53, -- 988
		sh * 0.07, -- 988
		Color(10, 8, 9, 150) -- 988
	) -- 988
	draw:drawSegment( -- 989
		drum, -- 989
		bend, -- 989
		ropeWidth, -- 989
		Color(111, 86, 57, 239) -- 989
	) -- 989
	draw:drawSegment( -- 990
		bend, -- 990
		ropeTop, -- 990
		ropeWidth, -- 990
		Color(111, 86, 57, 239) -- 990
	) -- 990
	if assets:tryPlace( -- 990
		"prop_winch", -- 991
		"gate_winch", -- 991
		cx, -- 991
		y0 + sh * 0.5, -- 991
		sw, -- 991
		sh, -- 991
		{layer = layer} -- 991
	) then -- 991
		return -- 992
	end -- 992
	local timber = Color(75, 51, 34, 255) -- 994
	draw:drawSegment( -- 995
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 995
		Vec2(cx, y0 + sh * 0.86), -- 995
		sw * 0.06, -- 995
		timber -- 995
	) -- 995
	draw:drawSegment( -- 996
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 996
		Vec2(cx, y0 + sh * 0.86), -- 996
		sw * 0.06, -- 996
		timber -- 996
	) -- 996
	draw:drawRect( -- 997
		Rect(x0, y0, sw, sh * 0.12), -- 997
		timber -- 997
	) -- 997
	local radius = math.min(sw, sh) * 0.21 -- 998
	draw:drawCircle( -- 999
		Vec2(cx, cy), -- 999
		radius, -- 999
		Color(48, 41, 37, 255) -- 999
	) -- 999
	do -- 999
		local i = -2 -- 1000
		while i <= 2 do -- 1000
			local x = cx + i * radius * 0.28 -- 1001
			draw:drawSegment( -- 1002
				Vec2(x, cy - radius * 0.62), -- 1002
				Vec2(x, cy + radius * 0.62), -- 1002
				ropeWidth, -- 1002
				Color(135, 103, 68, 240) -- 1003
			) -- 1003
			i = i + 1 -- 1000
		end -- 1000
	end -- 1000
end -- 974
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 1007
	local ____temp_3 -- 1015
	if p.room.story ~= nil then -- 1015
		____temp_3 = p.room.story.gate -- 1015
	else -- 1015
		____temp_3 = nil -- 1015
	end -- 1015
	local g = ____temp_3 -- 1015
	if g == nil then -- 1015
		return -- 1017
	end -- 1017
	local closeFrac = 0.08 -- 1020
	if p.phase == "gate-hold" then -- 1020
		closeFrac = 0.08 + 0.36 * math.min( -- 1022
			1, -- 1022
			p.gateTick / math.max(1, g.holdTicks) -- 1022
		) -- 1022
	elseif p.phase == "gate-send" then -- 1022
		closeFrac = 0.44 -- 1024
	elseif p.phase == "gate-count" then -- 1024
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 1026
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 1026
		closeFrac = 1 -- 1028
	end -- 1028
	local gx0 = cam:sx(848) -- 1030
	local gx1 = cam:sx(1032) -- 1031
	local topY = cam:sy(160) -- 1032
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1033
	local shutterW = gx1 - gx0 -- 1034
	local shutterH = topY - botY -- 1035
	if shutterH > 2 then -- 1035
		fillVGradRect( -- 1037
			fgDraw, -- 1037
			gx0, -- 1037
			botY, -- 1037
			shutterW, -- 1037
			shutterH, -- 1037
			toColor(PALETTE.steelDark), -- 1037
			toColor(PALETTE.steelMid) -- 1037
		) -- 1037
		local rows = math.max( -- 1039
			1, -- 1039
			math.min( -- 1039
				6, -- 1039
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1039
			) -- 1039
		) -- 1039
		local rowH = shutterH / rows -- 1040
		do -- 1040
			local r = 0 -- 1041
			while r < rows do -- 1041
				assets:tryPlace( -- 1042
					"cover_wood", -- 1042
					"gate_shutter_" .. tostring(r), -- 1042
					(gx0 + gx1) * 0.5, -- 1042
					botY + r * rowH, -- 1042
					shutterW, -- 1043
					rowH + 0.5, -- 1043
					{layer = 6} -- 1043
				) -- 1043
				r = r + 1 -- 1041
			end -- 1041
		end -- 1041
	end -- 1041
	if closeFrac < 0.98 then -- 1041
		local gapH = math.max( -- 1048
			8, -- 1048
			botY - cam:sy(0) -- 1048
		) -- 1048
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1049
		fillVGradRect( -- 1050
			fgGlow, -- 1050
			gx0, -- 1050
			cam:sy(0), -- 1050
			gx1 - gx0, -- 1050
			gapH, -- 1050
			Color( -- 1050
				140, -- 1050
				210, -- 1050
				255, -- 1050
				math.floor(52 * pulse + 0.5) -- 1050
			), -- 1050
			Color(80, 160, 230, 0) -- 1050
		) -- 1050
	end -- 1050
end -- 1007
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1054
	fillVGradRect( -- 1061
		fgDraw, -- 1061
		x0, -- 1061
		y0, -- 1061
		sw, -- 1061
		sh, -- 1061
		Color(15, 21, 34, 255), -- 1061
		Color(32, 44, 66, 255) -- 1061
	) -- 1061
	fgDraw:drawRect( -- 1062
		Rect(x0, y0, sw, sh), -- 1062
		Color(0, 0, 0, 0), -- 1062
		1.4, -- 1062
		toColor(PALETTE.rimSilver, 165) -- 1062
	) -- 1062
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1062
		self:tileMasonry( -- 1065
			assets, -- 1065
			s, -- 1065
			x0, -- 1065
			y0, -- 1065
			sw, -- 1065
			sh -- 1065
		) -- 1065
		local ribs = 4 -- 1067
		local r = 1 -- 1068
		do -- 1068
			r = 1 -- 1069
			while r < ribs do -- 1069
				local rx = x0 + sw * r / ribs -- 1070
				fgDraw:drawSegment( -- 1071
					Vec2(rx, y0), -- 1071
					Vec2(rx, y0 + sh), -- 1071
					2, -- 1071
					Color(10, 15, 24, 210) -- 1071
				) -- 1071
				fgDraw:drawSegment( -- 1072
					Vec2(rx + 2, y0), -- 1072
					Vec2(rx + 2, y0 + sh), -- 1072
					1, -- 1072
					Color(68, 86, 114, 130) -- 1072
				) -- 1072
				r = r + 1 -- 1069
			end -- 1069
		end -- 1069
		local bands = 4 -- 1075
		local b = 1 -- 1076
		do -- 1076
			b = 1 -- 1077
			while b < bands do -- 1077
				local by = y0 + sh * b / bands -- 1078
				fgDraw:drawSegment( -- 1079
					Vec2(x0 + 4, by), -- 1079
					Vec2(x0 + sw - 4, by), -- 1079
					1.2, -- 1079
					Color(52, 68, 92, 135) -- 1079
				) -- 1079
				b = b + 1 -- 1077
			end -- 1077
		end -- 1077
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1082
		local slitY = y0 + sh * 0.56 -- 1083
		local slitH = sh * 0.22 -- 1084
		fgDraw:drawRect( -- 1085
			Rect(slitX - 5, slitY, 10, slitH), -- 1085
			Color(8, 12, 20, 245), -- 1085
			1.2, -- 1085
			toColor(PALETTE.amberDim, 190) -- 1085
		) -- 1085
		fgGlow:drawRect( -- 1086
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1086
			toColor(PALETTE.amber, 190) -- 1086
		) -- 1086
		fillRadialGlow( -- 1087
			fgGlow, -- 1087
			slitX, -- 1087
			slitY + slitH * 0.5, -- 1087
			44, -- 1087
			slitH * 0.7, -- 1087
			Color(255, 206, 128, 52), -- 1087
			Color(255, 180, 86, 0), -- 1087
			14 -- 1087
		) -- 1087
	end -- 1087
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1087
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1092
		local cx = x0 + sw * 0.5 -- 1097
		local lampY = y0 - 8 -- 1098
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1099
		if not opened then -- 1099
			assets:tryPlace( -- 1101
				"prop_tower_door", -- 1101
				"tower_door", -- 1101
				cx, -- 1101
				y0 - doorHeight, -- 1101
				sw, -- 1101
				doorHeight, -- 1101
				{layer = 2} -- 1101
			) -- 1101
		end -- 1101
		assets:tryPlace( -- 1103
			"prop_lantern", -- 1103
			"tower_lantern", -- 1103
			cx + sw * 0.43, -- 1103
			lampY - sh * 0.36, -- 1103
			sw * 0.17, -- 1104
			sh * 0.84, -- 1104
			{layer = 3} -- 1104
		) -- 1104
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1105
		local alpha = opened and 155 or 88 -- 1106
		fgDraw:drawSegment( -- 1108
			Vec2(x0 + 4, y0), -- 1108
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1108
			4, -- 1108
			Color(42, 52, 70, 255) -- 1108
		) -- 1108
		fgDraw:drawSegment( -- 1109
			Vec2(x0 + sw - 4, y0), -- 1109
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1109
			4, -- 1109
			Color(42, 52, 70, 255) -- 1109
		) -- 1109
		fgDraw:drawSegment( -- 1110
			Vec2(x0, y0), -- 1110
			Vec2(x0 + sw, y0), -- 1110
			2.5, -- 1110
			toColor(PALETTE.amber, 210) -- 1110
		) -- 1110
		fillVGradRect( -- 1112
			fgGlow, -- 1113
			x0 + 6, -- 1114
			y0 - sh * 3.8, -- 1115
			sw - 12, -- 1116
			sh * 3.8, -- 1117
			Color( -- 1118
				255, -- 1118
				206, -- 1118
				128, -- 1118
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 1118
			), -- 1118
			Color(255, 224, 168, opened and 180 or 62) -- 1119
		) -- 1119
		fillRadialGlow( -- 1121
			fgGlow, -- 1121
			cx, -- 1121
			lampY, -- 1121
			opened and 105 or 58, -- 1121
			opened and 105 or 58, -- 1121
			Color( -- 1121
				255, -- 1121
				232, -- 1121
				178, -- 1121
				math.floor(170 * pulse + 0.5) -- 1121
			), -- 1121
			Color(255, 180, 86, 0), -- 1121
			18 -- 1121
		) -- 1121
		fgDraw:drawCircle( -- 1122
			Vec2(cx, lampY), -- 1122
			5.5, -- 1122
			toColor(PALETTE.amberCore) -- 1122
		) -- 1122
		if opened then -- 1122
			local deskCx = cam:sx(p.ox + 605) -- 1126
			local groundY = cam:sy(0) -- 1127
			local deskW = cam:len(88) -- 1128
			local deskH = cam:len(38) -- 1129
			local deskTop = groundY + deskH -- 1130
			local roomX0 = cam:sx(p.ox + 492) -- 1131
			local roomX1 = cam:sx(p.ox + 724) -- 1132
			assets:tryPlace( -- 1133
				"slide_tower_interior_live", -- 1133
				"tower_room_live", -- 1133
				(roomX0 + roomX1) * 0.5, -- 1133
				groundY, -- 1133
				roomX1 - roomX0, -- 1133
				cam:len(172), -- 1133
				{layer = 1} -- 1133
			) -- 1133
			fillRadialGlow( -- 1136
				fgGlow, -- 1136
				deskCx, -- 1136
				deskTop + cam:len(32), -- 1136
				cam:len(118), -- 1136
				cam:len(90), -- 1136
				Color( -- 1137
					255, -- 1137
					198, -- 1137
					114, -- 1137
					math.floor(68 * pulse + 0.5) -- 1137
				), -- 1137
				Color(255, 168, 72, 0), -- 1137
				16 -- 1137
			) -- 1137
			assets:tryPlace( -- 1138
				"fe_tower_guard_lantern", -- 1138
				"tower_guard_live", -- 1138
				deskCx + cam:len(32), -- 1138
				groundY, -- 1138
				cam:len(54), -- 1138
				cam:len(82), -- 1138
				{layer = 3} -- 1138
			) -- 1138
			assets:tryPlace( -- 1141
				"fe_workbench", -- 1141
				"tower_desk_live", -- 1141
				deskCx, -- 1141
				groundY, -- 1141
				deskW, -- 1141
				deskH, -- 1141
				{ -- 1141
					color = Color(238, 218, 196, 255), -- 1142
					layer = 4 -- 1143
				} -- 1143
			) -- 1143
			assets:tryPlace( -- 1145
				"fe_tower_lantern_detail", -- 1145
				"tower_desk_lamp_live", -- 1145
				deskCx + cam:len(30), -- 1145
				deskTop - cam:len(2), -- 1145
				cam:len(18), -- 1145
				cam:len(24), -- 1145
				{layer = 5} -- 1145
			) -- 1145
			if p.deskHold >= 12 or p.towerHanded then -- 1145
				assets:tryPlace( -- 1149
					"fe_tower_pouch_note", -- 1149
					"tower_desk_handover", -- 1149
					deskCx - cam:len(14), -- 1149
					deskTop + cam:len(6), -- 1149
					cam:len(30), -- 1149
					cam:len(18), -- 1149
					{layer = 5} -- 1149
				) -- 1149
			end -- 1149
		end -- 1149
	end -- 1149
end -- 1054
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1157
	local blades = math.max( -- 1164
		12, -- 1164
		math.floor(sw / 8) -- 1164
	) -- 1164
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1165
	local k = 0 -- 1166
	do -- 1166
		k = 0 -- 1167
		while k < blades do -- 1167
			local t = (k + 0.5) / blades -- 1168
			local bx = x0 + sw * t -- 1169
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1170
			local bh = sh * hRatio * 1.95 -- 1171
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1172
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1173
			fgDraw:drawPolygon( -- 1174
				{ -- 1174
					Vec2(bx - 7, y0), -- 1175
					Vec2(bx + 7, y0), -- 1176
					Vec2(bx + sway, y0 + bh) -- 1177
				}, -- 1177
				col -- 1178
			) -- 1178
			k = k + 1 -- 1167
		end -- 1167
	end -- 1167
	if nearPlayer then -- 1167
		fgGlow:drawSegment( -- 1181
			Vec2(x0, y0 + 2), -- 1181
			Vec2(x0 + sw, y0 + 2), -- 1181
			2, -- 1181
			toColor(PALETTE.emerald, 145) -- 1181
		) -- 1181
	end -- 1181
end -- 1157
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1185
	local a = p.room.arch -- 1191
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1191
		return -- 1193
	end -- 1193
	local x0 = cam:sx(a.x0) -- 1195
	local x1 = cam:sx(a.x1) -- 1196
	local y0 = cam:sy(a.y) -- 1197
	local y1 = cam:sy(a.y + a.h) -- 1198
	local cx = (x0 + x1) * 0.5 -- 1199
	local aw = x1 - x0 -- 1200
	local ah = y1 - y0 -- 1201
	draw:drawRect( -- 1202
		Rect( -- 1202
			x0, -- 1202
			y0, -- 1202
			aw, -- 1202
			ah + cam:len(8) -- 1202
		), -- 1202
		Color(13, 15, 20, 242) -- 1202
	) -- 1202
	if not assets:tryPlace( -- 1202
		"fe_outside_arch", -- 1203
		"outside_arch_vault", -- 1203
		cx, -- 1203
		y0, -- 1203
		aw + cam:len(24), -- 1203
		ah + cam:len(22), -- 1203
		{layer = 2} -- 1203
	) then -- 1203
		draw:drawRect( -- 1204
			Rect( -- 1204
				x0 - cam:len(7), -- 1204
				y0, -- 1204
				cam:len(7), -- 1204
				ah -- 1204
			), -- 1204
			Color(62, 63, 67, 255) -- 1204
		) -- 1204
		draw:drawRect( -- 1205
			Rect( -- 1205
				x1, -- 1205
				y0, -- 1205
				cam:len(7), -- 1205
				ah -- 1205
			), -- 1205
			Color(72, 72, 74, 255) -- 1205
		) -- 1205
	end -- 1205
	if not p.cartDocked then -- 1205
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1209
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1210
		if bx1 > bx0 + 4 then -- 1210
			local deckY = cam:sy(p.room.cart.baseY) -- 1212
			assets:tryPlace( -- 1213
				"fe_pillar_wood", -- 1213
				"outside_arch_bolt", -- 1213
				(bx0 + bx1) * 0.5, -- 1213
				y0 + 2, -- 1213
				bx1 - bx0, -- 1213
				ah - 2, -- 1213
				{layer = 3} -- 1213
			) -- 1213
			draw:drawSegment( -- 1214
				Vec2((bx0 + bx1) * 0.5, y1), -- 1214
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1214
				2.4, -- 1214
				Color(96, 102, 110, 220) -- 1214
			) -- 1214
		end -- 1214
	end -- 1214
end -- 1185
return ____exports -- 1185