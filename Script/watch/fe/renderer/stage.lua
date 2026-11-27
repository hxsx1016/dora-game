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
			mr * 5.2, -- 93
			mr * 5.2, -- 93
			Color(156, 186, 212, 26), -- 93
			Color(20, 32, 52, 0), -- 93
			20 -- 93
		) -- 93
		fillRadialGlow( -- 94
			bgGlow, -- 94
			mx, -- 94
			my, -- 94
			mr * 2.2, -- 94
			mr * 2.2, -- 94
			Color(210, 226, 238, 56), -- 94
			Color(64, 96, 134, 0), -- 94
			18 -- 94
		) -- 94
		bgDraw:drawCircle( -- 95
			Vec2(mx, my), -- 95
			mr, -- 95
			Color(224, 236, 244, 220) -- 95
		) -- 95
		bgDraw:drawCircle( -- 96
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 96
			mr * 0.84, -- 96
			toColor(theme.skyTop, 118) -- 96
		) -- 96
	end -- 96
	if p.room.key == "forest" then -- 96
		self:drawFarForest( -- 100
			bgDraw, -- 100
			w, -- 100
			h, -- 100
			cam, -- 100
			theme, -- 100
			seed -- 100
		) -- 100
		self:drawMidForest( -- 101
			bgDraw, -- 101
			bgGlow, -- 101
			w, -- 101
			h, -- 101
			cam, -- 101
			theme, -- 101
			time, -- 101
			seed -- 101
		) -- 101
	else -- 101
		self:drawFarMingTown( -- 103
			bgDraw, -- 103
			w, -- 103
			h, -- 103
			cam, -- 103
			theme, -- 103
			seed -- 103
		) -- 103
	end -- 103
	if theme.showTowerBeacon then -- 103
		self:drawDistantNorthTower( -- 106
			bgDraw, -- 106
			bgGlow, -- 106
			w, -- 106
			h, -- 106
			cam, -- 106
			p, -- 106
			time -- 106
		) -- 106
	end -- 106
	local fogH = h * 0.34 -- 110
	fillVGradRect( -- 111
		bgGlow, -- 112
		0, -- 113
		cam.groundScreenY - 10, -- 114
		w, -- 115
		fogH, -- 116
		toColor(theme.fogBottom), -- 117
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 118
	) -- 118
end -- 53
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 122
	local w = cam.viewW -- 123
	local ground = cam.groundScreenY -- 124
	local x = w * (0.76 - progress * 0.22) -- 125
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 125
		assets:tryPlace( -- 128
			"pine", -- 128
			"mid_pine", -- 128
			x, -- 128
			ground - cam:len(6), -- 128
			cam:len(122), -- 128
			cam:len(107), -- 128
			{layer = 1, opacity = 0.5} -- 129
		) -- 129
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 129
		assets:tryPlace( -- 131
			"eaves", -- 131
			"mid_eaves", -- 131
			x, -- 131
			ground - cam:len(4), -- 131
			cam:len(176), -- 131
			cam:len(96), -- 131
			{layer = 1, opacity = 0.44} -- 132
		) -- 132
	else -- 132
		assets:tryPlace( -- 134
			"cover_stone", -- 134
			"mid_ruin", -- 134
			x, -- 134
			ground - cam:len(4), -- 134
			cam:len(114), -- 134
			cam:len(50), -- 134
			{layer = 1, opacity = 0.44} -- 135
		) -- 135
	end -- 135
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 135
		assets:tryPlace( -- 138
			"prop_lantern", -- 138
			"mid_lantern", -- 138
			w * (0.27 - progress * 0.18), -- 138
			ground + cam:len(96), -- 139
			cam:len(20), -- 139
			cam:len(28), -- 139
			{layer = 2, opacity = 0.82} -- 139
		) -- 139
	end -- 139
end -- 122
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 144
	local theme = themeOf("checkpoint") -- 151
	local splitY = h * 0.44 -- 152
	fillVGradRect( -- 153
		bgDraw, -- 153
		0, -- 153
		splitY, -- 153
		w, -- 153
		h - splitY, -- 153
		toColor(theme.skyMid), -- 153
		toColor(theme.skyTop) -- 153
	) -- 153
	fillVGradRect( -- 154
		bgDraw, -- 154
		0, -- 154
		0, -- 154
		w, -- 154
		splitY, -- 154
		toColor(theme.skyHorizon), -- 154
		toColor(theme.skyMid) -- 154
	) -- 154
	local mx = w * 0.61 -- 157
	local my = h * 0.74 -- 158
	local mr = h * 0.072 -- 159
	fillRadialGlow( -- 160
		bgGlow, -- 160
		mx, -- 160
		my, -- 160
		mr * 4.4, -- 160
		mr * 4.4, -- 160
		Color(164, 184, 198, 28), -- 160
		Color(16, 22, 34, 0), -- 160
		22 -- 160
	) -- 160
	fillRadialGlow( -- 161
		bgGlow, -- 161
		mx, -- 161
		my, -- 161
		mr * 1.9, -- 161
		mr * 1.9, -- 161
		Color(214, 224, 232, 62), -- 161
		Color(36, 48, 64, 0), -- 161
		18 -- 161
	) -- 161
	bgDraw:drawCircle( -- 162
		Vec2(mx, my), -- 162
		mr, -- 162
		Color(234, 238, 236, 225) -- 162
	) -- 162
	bgDraw:drawCircle( -- 163
		Vec2(mx + mr * 0.24, my + mr * 0.14), -- 163
		mr * 0.85, -- 163
		Color(14, 18, 28, 118) -- 163
	) -- 163
	local groundY = h * 0.19 -- 166
	local i = 0 -- 167
	do -- 167
		i = 0 -- 168
		while i < 14 do -- 168
			local bx = i * (w / 12) - 24 + math.sin(time * 0.06) * 4 -- 169
			local bw = 58 + hash01(i * 13 + 3) * 82 -- 170
			local bh = h * (0.14 + hash01(i * 29 + 7) * 0.22) -- 171
			local ridgeH = 14 + hash01(i * 19) * 18 -- 172
			bgDraw:drawPolygon( -- 173
				{ -- 173
					Vec2(bx, groundY), -- 174
					Vec2(bx + bw, groundY), -- 175
					Vec2(bx + bw, groundY + bh), -- 176
					Vec2(bx + bw * 0.5, groundY + bh + ridgeH), -- 177
					Vec2(bx, groundY + bh) -- 178
				}, -- 178
				Color(14, 18, 26, 255) -- 179
			) -- 179
			i = i + 1 -- 168
		end -- 168
	end -- 168
	local tx = w * 0.83 -- 183
	local ty0 = groundY -- 184
	local ty1 = h * 0.58 -- 185
	bgDraw:drawPolygon( -- 186
		{ -- 186
			Vec2(tx - 24, ty0), -- 187
			Vec2(tx + 24, ty0), -- 188
			Vec2(tx + 15, ty1), -- 189
			Vec2(tx - 15, ty1) -- 190
		}, -- 190
		Color(18, 23, 34, 255), -- 191
		1.1, -- 191
		Color(72, 84, 98, 130) -- 191
	) -- 191
	bgDraw:drawPolygon( -- 192
		{ -- 192
			Vec2(tx - 32, ty1), -- 193
			Vec2(tx + 32, ty1), -- 194
			Vec2(tx, ty1 + 26) -- 195
		}, -- 195
		Color(24, 30, 42, 255) -- 196
	) -- 196
	local pulse = 0.82 + 0.18 * math.sin(time * 2.2) -- 197
	local lampY = ty1 - 14 -- 198
	fillRadialGlow( -- 199
		bgGlow, -- 199
		tx, -- 199
		lampY, -- 199
		64 * pulse, -- 199
		64 * pulse, -- 199
		Color(238, 198, 128, 118), -- 199
		Color(214, 162, 86, 0), -- 199
		18 -- 199
	) -- 199
	bgGlow:drawDot( -- 200
		Vec2(tx, lampY), -- 200
		4.2, -- 200
		Color(252, 240, 206, 245) -- 200
	) -- 200
	fillVGradRect( -- 203
		bgDraw, -- 203
		0, -- 203
		0, -- 203
		w, -- 203
		groundY, -- 203
		Color(9, 11, 17, 255), -- 203
		Color(20, 24, 34, 255) -- 203
	) -- 203
	bgDraw:drawSegment( -- 204
		Vec2(0, groundY), -- 204
		Vec2(w, groundY), -- 204
		1.4, -- 204
		toColor(PALETTE.silkDim, 145) -- 204
	) -- 204
	fillVGradRect( -- 205
		bgGlow, -- 205
		0, -- 205
		groundY, -- 205
		w, -- 205
		h * 0.18, -- 205
		Color(46, 56, 72, 42), -- 205
		Color(20, 26, 38, 0) -- 205
	) -- 205
	local sx = w * 0.64 -- 208
	bgDraw:drawPolygon( -- 209
		{ -- 209
			Vec2(sx - 24, groundY + 14), -- 210
			Vec2(sx + 14, groundY + 18), -- 211
			Vec2(sx + 16, groundY + 116), -- 212
			Vec2(sx - 16, groundY + 116) -- 213
		}, -- 213
		Color(14, 18, 26, 255), -- 214
		1.1, -- 214
		Color(118, 132, 144, 125) -- 214
	) -- 214
	bgDraw:drawSegment( -- 215
		Vec2(sx - 5, groundY + 46), -- 215
		Vec2(sx - 10, groundY + 2), -- 215
		5.5, -- 215
		Color(12, 16, 24, 255) -- 215
	) -- 215
	bgDraw:drawSegment( -- 216
		Vec2(sx + 6, groundY + 46), -- 216
		Vec2(sx + 12, groundY + 2), -- 216
		5.5, -- 216
		Color(16, 20, 30, 255) -- 216
	) -- 216
	bgDraw:drawCircle( -- 217
		Vec2(sx + 1, groundY + 132), -- 217
		11, -- 217
		Color(18, 22, 32, 255) -- 217
	) -- 217
	bgDraw:drawPolygon( -- 218
		{ -- 218
			Vec2(sx - 18, groundY + 135), -- 219
			Vec2(sx + 20, groundY + 135), -- 220
			Vec2(sx + 1, groundY + 148) -- 221
		}, -- 221
		Color(44, 50, 58, 250) -- 222
	) -- 222
	bgDraw:drawSegment( -- 223
		Vec2(sx + 4, groundY + 96), -- 223
		Vec2(sx + 46, groundY + 88), -- 223
		3, -- 223
		Color(78, 56, 40, 255) -- 223
	) -- 223
	local cx = w * 0.725 -- 225
	bgDraw:drawPolygon( -- 226
		{ -- 226
			Vec2(cx - 18, groundY + 14), -- 227
			Vec2(cx + 16, groundY + 14), -- 228
			Vec2(cx + 11, groundY + 78), -- 229
			Vec2(cx - 11, groundY + 78) -- 230
		}, -- 230
		Color(148, 108, 66, 236), -- 231
		1.2, -- 231
		Color(214, 186, 146, 195) -- 231
	) -- 231
	bgDraw:drawSegment( -- 232
		Vec2(cx - 4, groundY + 22), -- 232
		Vec2(cx - 5, groundY + 2), -- 232
		3.8, -- 232
		Color(24, 20, 24, 255) -- 232
	) -- 232
	bgDraw:drawSegment( -- 233
		Vec2(cx + 4, groundY + 22), -- 233
		Vec2(cx + 5, groundY + 2), -- 233
		3.8, -- 233
		Color(30, 26, 30, 255) -- 233
	) -- 233
	bgDraw:drawCircle( -- 234
		Vec2(cx + 1, groundY + 88), -- 234
		10, -- 234
		Color(212, 192, 168, 240) -- 234
	) -- 234
	fillRadialGlow( -- 235
		bgGlow, -- 235
		cx + 10, -- 235
		groundY + 52, -- 235
		26, -- 235
		26, -- 235
		Color(238, 198, 128, 96), -- 235
		Color(214, 162, 86, 0), -- 235
		14 -- 235
	) -- 235
	bgGlow:drawDot( -- 236
		Vec2(cx + 10, groundY + 52), -- 236
		2.8, -- 236
		Color(252, 238, 202, 240) -- 236
	) -- 236
end -- 144
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 240
	local theme = themeOf(p.room.key) -- 250
	self:drawFloors( -- 251
		fgDraw, -- 251
		assets, -- 251
		p, -- 251
		cam, -- 251
		theme -- 251
	) -- 251
	self:drawStairs( -- 252
		fgDraw, -- 252
		fgGlow, -- 252
		assets, -- 252
		p, -- 252
		cam, -- 252
		theme -- 252
	) -- 252
	self:drawSolids( -- 253
		fgDraw, -- 253
		fgGlow, -- 253
		assets, -- 253
		p, -- 253
		cam, -- 253
		theme, -- 253
		time, -- 253
		occlusion, -- 253
		fadeDt -- 253
	) -- 253
	if p.room.key == "gate" then -- 253
		self:drawGateShutter( -- 255
			fgDraw, -- 255
			fgGlow, -- 255
			assets, -- 255
			p, -- 255
			cam, -- 255
			time -- 255
		) -- 255
	end -- 255
	self:drawArch(fgDraw, p, cam) -- 257
end -- 240
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 261
	fillVGradRect( -- 269
		fgDraw, -- 269
		0, -- 269
		h - h * 0.15, -- 269
		w, -- 269
		h * 0.15, -- 269
		Color(4, 6, 12, 0), -- 269
		Color(4, 6, 12, 126) -- 269
	) -- 269
	fillVGradRect( -- 270
		fgDraw, -- 270
		0, -- 270
		0, -- 270
		w, -- 270
		h * 0.12, -- 270
		Color(4, 6, 12, 165), -- 270
		Color(4, 6, 12, 0) -- 270
	) -- 270
end -- 261
function StageRenderer.prototype.drawFarMingTown(self, bgDraw, w, h, cam, theme, seed) -- 274
	local baseY = cam.groundScreenY - 8 -- 282
	local shift = -cam.x * 0.2 * cam.ppu -- 283
	local colW = 112 -- 284
	local first = math.floor((-shift - colW) / colW) -- 285
	local count = math.ceil(w / colW) + 3 -- 286
	local i = 0 -- 287
	do -- 287
		i = 0 -- 288
		while i < count do -- 288
			local idx = first + i -- 289
			local r1 = hash01(seed + idx * 13.7) -- 290
			local r2 = hash01(seed + idx * 29.3) -- 291
			local x = idx * colW + shift -- 292
			local bw = colW * (0.72 + r1 * 0.42) -- 293
			local bh = h * (0.14 + r2 * 0.24) -- 294
			local ridgeH = 14 + r1 * 18 -- 295
			bgDraw:drawPolygon( -- 296
				{ -- 296
					Vec2(x, baseY), -- 297
					Vec2(x + bw, baseY), -- 298
					Vec2(x + bw, baseY + bh), -- 299
					Vec2(x + bw * 0.5, baseY + bh + ridgeH), -- 300
					Vec2(x, baseY + bh) -- 301
				}, -- 301
				toColor(theme.farBuilding) -- 302
			) -- 302
			i = i + 1 -- 288
		end -- 288
	end -- 288
end -- 274
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 306
	local baseY = cam.groundScreenY - 8 -- 314
	local shift = -cam.x * 0.22 * cam.ppu -- 315
	local step = 76 -- 316
	local first = math.floor((-shift - step) / step) -- 317
	local count = math.ceil(w / step) + 4 -- 318
	local i = 0 -- 319
	do -- 319
		i = 0 -- 320
		while i < count do -- 320
			local idx = first + i -- 321
			local r1 = hash01(seed + idx * 11.3) -- 322
			local r2 = hash01(seed + idx * 23.9) -- 323
			local cx = idx * step + shift -- 324
			local tw = 34 + r1 * 38 -- 325
			local th = h * (0.24 + r2 * 0.34) -- 326
			bgDraw:drawPolygon( -- 327
				{ -- 327
					Vec2(cx - tw, baseY), -- 328
					Vec2(cx + tw, baseY), -- 329
					Vec2(cx, baseY + th) -- 330
				}, -- 330
				toColor(theme.farBuilding) -- 331
			) -- 331
			bgDraw:drawPolygon( -- 332
				{ -- 332
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 333
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 334
					Vec2(cx, baseY + th * 1.12) -- 335
				}, -- 335
				toColor(theme.farBuilding) -- 336
			) -- 336
			i = i + 1 -- 320
		end -- 320
	end -- 320
end -- 306
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 340
	local baseY = cam.groundScreenY - 4 -- 350
	local shift = -cam.x * 0.52 * cam.ppu -- 351
	local span = 156 -- 352
	local first = math.floor((-shift - span) / span) -- 353
	local count = math.ceil(w / span) + 3 -- 354
	local col = toColor(theme.midBuilding) -- 355
	local i = 0 -- 357
	do -- 357
		i = 0 -- 358
		while i < count do -- 358
			local idx = first + i -- 359
			local r = hash01(seed + idx * 19.7) -- 360
			local x = idx * span + shift -- 361
			local trunkW = 14 + r * 14 -- 362
			local sway = math.sin(time * 0.9 + idx) * 4 -- 363
			bgDraw:drawPolygon( -- 364
				{ -- 364
					Vec2(x - trunkW * 0.5, baseY), -- 365
					Vec2(x + trunkW * 0.5, baseY), -- 366
					Vec2(x + trunkW * 0.25 + sway, h), -- 367
					Vec2(x - trunkW * 0.3 + sway, h) -- 368
				}, -- 368
				col -- 369
			) -- 369
			if idx % 3 == 0 then -- 369
				bgGlow:drawVertices({ -- 372
					{ -- 373
						Vec2(x + 40, h), -- 373
						Color(110, 232, 200, 26) -- 373
					}, -- 373
					{ -- 374
						Vec2(x + 115, h), -- 374
						Color(110, 232, 200, 0) -- 374
					}, -- 374
					{ -- 375
						Vec2(x - 60, baseY), -- 375
						Color(110, 232, 200, 0) -- 375
					} -- 375
				}) -- 375
			end -- 375
			i = i + 1 -- 358
		end -- 358
	end -- 358
end -- 340
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 381
	local scale = 0.55 -- 391
	if p.room.key == "village" then -- 391
		scale = 0.72 -- 393
	elseif p.room.key == "forest" then -- 393
		scale = 0.92 -- 395
	elseif p.room.key == "tower" then -- 395
		scale = 1.15 -- 397
	end -- 397
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 399
	local baseY = cam.groundScreenY - 8 -- 400
	local towerH = h * 0.42 * scale -- 401
	local bw = 20 * scale -- 402
	bgDraw:drawPolygon( -- 403
		{ -- 403
			Vec2(tx - bw, baseY), -- 404
			Vec2(tx + bw, baseY), -- 405
			Vec2(tx + bw * 0.45, baseY + towerH), -- 406
			Vec2(tx - bw * 0.45, baseY + towerH) -- 407
		}, -- 407
		Color(14, 24, 38, 240) -- 408
	) -- 408
	bgDraw:drawSegment( -- 409
		Vec2(tx, baseY + towerH), -- 409
		Vec2(tx, baseY + towerH + 28 * scale), -- 409
		1.8, -- 409
		Color(180, 210, 238, 200) -- 409
	) -- 409
	local topY = baseY + towerH + 24 * scale -- 411
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 412
	fillRadialGlow( -- 413
		bgGlow, -- 413
		tx, -- 413
		topY, -- 413
		56 * scale * pulse, -- 413
		56 * scale * pulse, -- 413
		Color(255, 224, 152, 118), -- 413
		Color(255, 190, 96, 0), -- 413
		18 -- 413
	) -- 413
	bgGlow:drawDot( -- 414
		Vec2(tx, topY), -- 414
		3.6 * scale, -- 414
		Color(255, 246, 220, 255) -- 414
	) -- 414
end -- 381
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 417
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 424
	do -- 424
		local i = 0 -- 425
		while i < #p.room.floors do -- 425
			local floor = p.room.floors[i + 1] -- 426
			local left = cam:sx(floor.x0) -- 427
			local right = cam:sx(floor.x1) -- 428
			local isMain = floor.y <= 0.1 -- 429
			local ____isMain_0 -- 430
			if isMain then -- 430
				____isMain_0 = p.room.depth -- 430
			else -- 430
				____isMain_0 = nil -- 430
			end -- 430
			local road = ____isMain_0 -- 430
			local top = cam:sy(floor.y, road and road.min or 0) -- 431
			if road ~= nil then -- 431
				self:drawRoad( -- 433
					fgDraw, -- 433
					assets, -- 433
					i, -- 433
					left, -- 433
					right, -- 433
					top, -- 433
					cam:sy(floor.y, road.max), -- 433
					cam, -- 433
					theme -- 433
				) -- 433
			end -- 433
			local height = cam:len(isMain and 22 or 12) -- 435
			local bottom = top - height -- 436
			if isMain and bottom > 0 then -- 436
				fillVGradRect( -- 438
					fgDraw, -- 438
					left, -- 438
					0, -- 438
					right - left, -- 438
					bottom + 1, -- 438
					toColor(PALETTE.voidDark), -- 439
					toColor(theme.groundBody) -- 439
				) -- 439
			end -- 439
			fgDraw:drawRect( -- 441
				Rect(left, bottom, right - left, height), -- 441
				toColor(PALETTE.steelDark) -- 441
			) -- 441
			local step = cam:len(96) -- 442
			local start = math.max( -- 443
				0, -- 443
				math.floor(-left / step) -- 443
			) -- 443
			do -- 443
				local j = start -- 444
				while left + j * step < math.min(right, cam.viewW) do -- 444
					local x = left + j * step -- 445
					local width = math.min(step, right - x) -- 446
					assets:tryPlace( -- 447
						"slab", -- 447
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 447
						x + width * 0.5, -- 447
						bottom, -- 447
						width, -- 447
						height -- 447
					) -- 447
					if grass and isMain and j % 3 == 1 then -- 447
						assets:tryPlace( -- 449
							"grass_low", -- 449
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 449
							x + width * 0.5, -- 449
							top - cam:len(3), -- 450
							width * 0.74, -- 450
							cam:len(13), -- 450
							{opacity = 0.83, layer = 1} -- 450
						) -- 450
					end -- 450
					j = j + 1 -- 444
				end -- 444
			end -- 444
			fgDraw:drawSegment( -- 453
				Vec2(left, top), -- 453
				Vec2(right, top), -- 453
				1, -- 453
				toColor(theme.groundRim, 140) -- 453
			) -- 453
			i = i + 1 -- 425
		end -- 425
	end -- 425
end -- 417
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 457
	local width = right - left -- 462
	local height = back - front -- 463
	if width <= 1 or height <= 1 then -- 463
		return -- 465
	end -- 465
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 468
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 469
	fillVGradRect( -- 470
		draw, -- 470
		left, -- 470
		front, -- 470
		width, -- 470
		height, -- 470
		toColor(nearCol), -- 470
		toColor(farCol) -- 470
	) -- 470
	local bands = { -- 472
		0, -- 472
		0.3, -- 472
		0.58, -- 472
		0.81, -- 472
		1 -- 472
	} -- 472
	local jointDark = Color(14, 17, 22, 115) -- 473
	local jointHi = toColor(theme.groundRim, 36) -- 474
	local visLeft = math.max(left, -40) -- 475
	local visRight = math.min(right, cam.viewW + 40) -- 476
	do -- 476
		local row = 0 -- 477
		while row < #bands - 1 do -- 477
			local y0 = front + bands[row + 1] * height -- 478
			local y1 = front + bands[row + 1 + 1] * height -- 479
			local rowH = y1 - y0 -- 480
			local slabWidth = math.max( -- 481
				24, -- 481
				cam:len(84 - row * 10) -- 481
			) -- 481
			local offset = left - row % 2 * slabWidth * 0.5 -- 482
			local start = math.max( -- 483
				0, -- 483
				math.floor((visLeft - offset) / slabWidth) -- 483
			) -- 483
			do -- 483
				local col = start -- 484
				while offset + col * slabWidth < visRight do -- 484
					do -- 484
						local sx0 = math.max(left, offset + col * slabWidth) -- 485
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 486
						local sw = sx1 - sx0 -- 487
						if sw <= 2 then -- 487
							goto __continue55 -- 489
						end -- 489
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 491
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 492
						draw:drawRect( -- 493
							Rect( -- 493
								sx0 + 0.5, -- 493
								y0 + 0.5, -- 493
								sw - 1, -- 493
								math.max(1, rowH - 1) -- 493
							), -- 493
							toColor(stoneCol, 195) -- 493
						) -- 493
						draw:drawSegment( -- 494
							Vec2(sx0, y0), -- 494
							Vec2(sx0, y1), -- 494
							0.8, -- 494
							jointDark -- 494
						) -- 494
					end -- 494
					::__continue55:: -- 494
					col = col + 1 -- 484
				end -- 484
			end -- 484
			draw:drawSegment( -- 496
				Vec2(left, y0), -- 496
				Vec2(right, y0), -- 496
				0.9, -- 496
				jointDark -- 496
			) -- 496
			draw:drawSegment( -- 497
				Vec2(left, y0 + 1), -- 497
				Vec2(right, y0 + 1), -- 497
				0.6, -- 497
				jointHi -- 497
			) -- 497
			row = row + 1 -- 477
		end -- 477
	end -- 477
	draw:drawSegment( -- 500
		Vec2(left, front), -- 500
		Vec2(right, front), -- 500
		1.4, -- 500
		toColor(theme.groundRim, 135) -- 500
	) -- 500
	draw:drawSegment( -- 501
		Vec2(left, back), -- 501
		Vec2(right, back), -- 501
		1.3, -- 501
		toColor(theme.groundRim, 92) -- 501
	) -- 501
end -- 457
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 504
	local i = 0 -- 512
	do -- 512
		i = 0 -- 513
		while i < #p.room.stairs do -- 513
			local st = p.room.stairs[i + 1] -- 514
			local n = st.steps + 1 -- 515
			local stepW = (st.x1 - st.x0) / n -- 516
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 517
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 520
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 523
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 524
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 525
			local k = 0 -- 526
			do -- 526
				k = 0 -- 527
				while k < n do -- 527
					do -- 527
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 528
						local wx0 = st.x0 + stepW * k -- 529
						local wx1 = wx0 + stepW -- 530
						local x0 = cam:sx(wx0) -- 531
						local x1 = cam:sx(wx1) -- 532
						if x1 < 0 or x0 > cam.viewW then -- 532
							goto __continue61 -- 534
						end -- 534
						local y1 = cam:sy(wy, dMin) -- 536
						local y0 = cam:sy(baseWorldY, dMin) -- 537
						local yRear = cam:sy(wy, dMax) -- 538
						if yRear > y1 + 1 then -- 538
							fgDraw:drawRect( -- 540
								Rect(x0, y1, x1 - x0, yRear - y1), -- 540
								toColor( -- 540
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 540
									235 -- 540
								), -- 540
								0.7, -- 540
								toColor(theme.groundRim, 95) -- 540
							) -- 540
						end -- 540
						if y1 > y0 + 2 then -- 540
							fgDraw:drawRect( -- 543
								Rect(x0, y0, x1 - x0, y1 - y0), -- 543
								toColor(PALETTE.steelDark, 235) -- 543
							) -- 543
							fgDraw:drawRect( -- 544
								Rect(x0, y1 - 4, x1 - x0, 4), -- 544
								toColor(theme.groundTop) -- 544
							) -- 544
							assets:tryPlace( -- 545
								"wall", -- 545
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 545
								(x0 + x1) * 0.5, -- 545
								y0, -- 545
								x1 - x0, -- 546
								y1 - y0, -- 546
								{opacity = 0.76, layer = stairLayer} -- 546
							) -- 546
							assets:tryPlace( -- 547
								"slab", -- 547
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 547
								(x0 + x1) * 0.5, -- 547
								y1 - cam:len(4), -- 547
								x1 - x0, -- 548
								cam:len(4), -- 548
								{layer = stairLayer + 1} -- 548
							) -- 548
						end -- 548
						fgDraw:drawSegment( -- 550
							Vec2(x0, y1), -- 550
							Vec2(x1, y1), -- 550
							1.6, -- 550
							toColor(theme.groundRim) -- 550
						) -- 550
						fgGlow:drawSegment( -- 551
							Vec2(x0, y1 + 1), -- 551
							Vec2(x1, y1 + 1), -- 551
							0.9, -- 551
							toColor(theme.accent, 50) -- 551
						) -- 551
					end -- 551
					::__continue61:: -- 551
					k = k + 1 -- 527
				end -- 527
			end -- 527
			i = i + 1 -- 513
		end -- 513
	end -- 513
end -- 504
function StageRenderer.prototype.isSolidActive(self, p, s) -- 557
	local matched = false -- 558
	local anyVisible = false -- 559
	local i = 0 -- 560
	do -- 560
		i = 0 -- 561
		while i < #p.boxes do -- 561
			local b = p.boxes[i + 1] -- 562
			local sameId = s.id ~= nil and b.id == s.id -- 563
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 564
			if sameId or sameGeom then -- 564
				matched = true -- 568
				if b.broken ~= true and b.hidden ~= true then -- 568
					anyVisible = true -- 570
				end -- 570
			end -- 570
			i = i + 1 -- 561
		end -- 561
	end -- 561
	return not matched or anyVisible -- 574
end -- 557
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 577
	local i = 0 -- 588
	do -- 588
		i = 0 -- 589
		while i < #p.room.solids do -- 589
			do -- 589
				local s = p.room.solids[i + 1] -- 590
				if s.decorative == true then -- 590
					goto __continue72 -- 593
				end -- 593
				if not self:isSolidActive(p, s) then -- 593
					goto __continue72 -- 597
				end -- 597
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 597
					goto __continue72 -- 601
				end -- 601
				local x0 = cam:sx(s.x) -- 603
				local x1 = cam:sx(s.x + s.w) -- 604
				if p.room.depth ~= nil and s.depth ~= nil then -- 604
					local opacity = occlusion:update( -- 606
						"solid_" .. tostring(i), -- 606
						{ -- 606
							x0 = s.x, -- 607
							x1 = s.x + s.w, -- 607
							y0 = s.y, -- 607
							y1 = s.y + s.h, -- 607
							depth = s.depth, -- 608
							passThrough = s.passable == true or s.soft == true -- 608
						}, -- 608
						p, -- 609
						fadeDt -- 609
					) -- 609
					if x1 > 0 and x0 < cam.viewW then -- 609
						self:drawDepthSolid( -- 611
							fgDraw, -- 611
							assets, -- 611
							s, -- 611
							s.depth, -- 611
							x0, -- 611
							x1, -- 611
							cam, -- 611
							theme, -- 611
							opacity, -- 611
							p -- 611
						) -- 611
					end -- 611
					goto __continue72 -- 613
				end -- 613
				local y0 = cam:sy(s.y) -- 615
				local y1 = cam:sy(s.y + s.h) -- 616
				local sw = x1 - x0 -- 617
				local sh = y1 - y0 -- 618
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 618
					goto __continue72 -- 620
				end -- 620
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 620
					local groundY = cam:sy(0) -- 625
					local pierW = cam:len(16) -- 626
					fgDraw:drawRect( -- 627
						Rect(x0, groundY, pierW, y0 - groundY), -- 627
						Color(32, 37, 46, 215), -- 627
						0.9, -- 627
						Color(68, 76, 88, 140) -- 627
					) -- 627
					fgDraw:drawRect( -- 628
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 628
						Color(32, 37, 46, 215), -- 628
						0.9, -- 628
						Color(68, 76, 88, 140) -- 628
					) -- 628
				end -- 628
				if s.passable == true then -- 628
					if not assets:tryPlace( -- 628
						"grass", -- 633
						"hide_grass_" .. tostring(i), -- 633
						(x0 + x1) * 0.5, -- 633
						y0, -- 633
						sw, -- 633
						sh * 1.55, -- 633
						{opacity = 0.79, layer = 7} -- 634
					) then -- 634
						self:drawGrassCluster( -- 635
							fgDraw, -- 635
							fgGlow, -- 635
							x0, -- 635
							y0, -- 635
							sw, -- 635
							sh, -- 635
							p.player.x, -- 635
							s.x + s.w * 0.5, -- 635
							time -- 635
						) -- 635
					end -- 635
					goto __continue72 -- 637
				end -- 637
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 637
					self:drawWinch( -- 642
						fgDraw, -- 642
						assets, -- 642
						x0, -- 642
						y0, -- 642
						sw, -- 642
						sh, -- 642
						p, -- 642
						2 -- 642
					) -- 642
					goto __continue72 -- 643
				end -- 643
				if p.room.key == "tower" then -- 643
					self:drawTowerStructure( -- 648
						fgDraw, -- 648
						fgGlow, -- 648
						assets, -- 648
						x0, -- 648
						y0, -- 648
						sw, -- 648
						sh, -- 648
						s, -- 648
						p, -- 648
						cam, -- 648
						time -- 648
					) -- 648
					goto __continue72 -- 649
				end -- 649
				if s.h <= 64 and s.y <= 2 then -- 649
					self:drawCoverBlock( -- 654
						fgDraw, -- 654
						fgGlow, -- 654
						assets, -- 654
						x0, -- 654
						y0, -- 654
						sw, -- 654
						sh, -- 654
						s, -- 654
						p, -- 654
						theme -- 654
					) -- 654
					goto __continue72 -- 655
				end -- 655
				fillVGradRect( -- 658
					fgDraw, -- 658
					x0, -- 658
					y0, -- 658
					sw, -- 658
					sh, -- 658
					toColor(PALETTE.steelDark), -- 658
					toColor(PALETTE.steelMid) -- 658
				) -- 658
				self:tileMasonry( -- 659
					assets, -- 659
					s, -- 659
					x0, -- 659
					y0, -- 659
					sw, -- 659
					sh -- 659
				) -- 659
			end -- 659
			::__continue72:: -- 659
			i = i + 1 -- 589
		end -- 589
	end -- 589
end -- 577
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 663
	local width = right - left -- 667
	local base = cam:sy(solid.y, depth.min) -- 668
	local rearBase = cam:sy(solid.y, depth.max) -- 669
	local top = cam:sy(solid.y + solid.h, depth.min) -- 670
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 671
	local frontH = top - base -- 672
	local slot = coverArt(solid) -- 673
	local layer = depthOrder(depth.min, 1) -- 674
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 675
	local capHeight = rear - top -- 676
	local center = (left + right) * 0.5 -- 677
	if solid.y <= 2 and rearBase > base + 1 then -- 677
		draw:drawRect( -- 681
			Rect(left, base, width, rearBase - base), -- 682
			Color( -- 683
				9, -- 683
				10, -- 683
				14, -- 683
				math.floor(86 * opacity + 0.5) -- 683
			), -- 683
			0.8, -- 684
			toColor( -- 685
				theme.groundRim, -- 685
				math.floor(58 * opacity + 0.5) -- 685
			) -- 685
		) -- 685
	end -- 685
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 685
		self:drawWinch( -- 691
			draw, -- 691
			assets, -- 691
			left, -- 691
			base, -- 691
			width, -- 691
			frontH, -- 691
			p, -- 691
			layer -- 691
		) -- 691
		return -- 692
	end -- 692
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 692
		assets:tryPlace( -- 696
			"slab", -- 696
			"gate_sill_" .. tostring(solid.x), -- 696
			center, -- 696
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 696
			width + cam:len(34), -- 697
			cam:len(12), -- 697
			{ -- 697
				layer = 1, -- 697
				color = Color(180, 169, 150, 255) -- 697
			} -- 697
		) -- 697
	end -- 697
	draw:drawEllipse( -- 699
		Vec2( -- 699
			center, -- 699
			base + cam:len(2) -- 699
		), -- 699
		width * 0.5, -- 699
		math.max( -- 700
			2, -- 700
			cam:len(2.5) -- 700
		), -- 700
		Color(10, 10, 14, 128 * opacity) -- 700
	) -- 700
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 702
	if slot ~= "fence" and capHeight > 1 then -- 702
		local capFill = occlusionTint( -- 706
			opacity, -- 706
			timber and Color( -- 706
				88, -- 707
				68, -- 707
				52, -- 707
				math.floor(240 * opacity + 0.5) -- 707
			) or Color( -- 707
				86, -- 708
				90, -- 708
				98, -- 708
				math.floor(240 * opacity + 0.5) -- 708
			) -- 708
		) -- 708
		local capEdge = occlusionTint( -- 709
			opacity, -- 709
			timber and Color( -- 709
				148, -- 710
				118, -- 710
				90, -- 710
				math.floor(185 * opacity + 0.5) -- 710
			) or Color( -- 710
				146, -- 711
				152, -- 711
				160, -- 711
				math.floor(175 * opacity + 0.5) -- 711
			) -- 711
		) -- 711
		draw:drawRect( -- 712
			Rect(left, top, width, capHeight), -- 712
			capFill, -- 712
			0.9, -- 712
			capEdge -- 712
		) -- 712
		draw:drawSegment( -- 713
			Vec2(left + 1, top + 0.5), -- 713
			Vec2(right - 1, top + 0.5), -- 713
			1.1, -- 713
			capEdge -- 713
		) -- 713
		if capHeight > 8 then -- 713
			local midY = top + capHeight * 0.5 -- 715
			draw:drawSegment( -- 716
				Vec2(left + 2, midY), -- 716
				Vec2(right - 2, midY), -- 716
				0.7, -- 716
				Color( -- 716
					24, -- 716
					22, -- 716
					22, -- 716
					math.floor(90 * opacity + 0.5) -- 716
				) -- 716
			) -- 716
		end -- 716
	end -- 716
	if timber and solid.h > solid.w * 1.6 then -- 716
		local colFill = occlusionTint( -- 722
			opacity, -- 722
			Color( -- 722
				66, -- 722
				48, -- 722
				36, -- 722
				math.floor(248 * opacity + 0.5) -- 722
			) -- 722
		) -- 722
		local colHi = occlusionTint( -- 723
			opacity, -- 723
			Color( -- 723
				122, -- 723
				92, -- 723
				68, -- 723
				math.floor(200 * opacity + 0.5) -- 723
			) -- 723
		) -- 723
		local colSh = occlusionTint( -- 724
			opacity, -- 724
			Color( -- 724
				34, -- 724
				24, -- 724
				18, -- 724
				math.floor(220 * opacity + 0.5) -- 724
			) -- 724
		) -- 724
		draw:drawRect( -- 725
			Rect(left, base, width, frontH), -- 725
			colFill, -- 725
			1, -- 725
			colHi -- 725
		) -- 725
		draw:drawRect( -- 726
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 726
			colSh -- 726
		) -- 726
		draw:drawSegment( -- 727
			Vec2(left + width * 0.32, base + 2), -- 727
			Vec2(left + width * 0.32, top - 2), -- 727
			0.9, -- 727
			colHi -- 727
		) -- 727
		return -- 728
	end -- 728
	if solid.w > solid.h * 5 then -- 728
		local beamFill = occlusionTint( -- 733
			opacity, -- 733
			Color( -- 733
				78, -- 733
				58, -- 733
				42, -- 733
				math.floor(248 * opacity + 0.5) -- 733
			) -- 733
		) -- 733
		local beamEdge = occlusionTint( -- 734
			opacity, -- 734
			Color( -- 734
				142, -- 734
				110, -- 734
				82, -- 734
				math.floor(215 * opacity + 0.5) -- 734
			) -- 734
		) -- 734
		draw:drawRect( -- 735
			Rect( -- 735
				left, -- 735
				base, -- 735
				width, -- 735
				math.max(4, frontH) -- 735
			), -- 735
			beamFill, -- 735
			1, -- 735
			beamEdge -- 735
		) -- 735
		local posts = math.max( -- 736
			2, -- 736
			math.floor(solid.w / 140 + 0.5) -- 736
		) -- 736
		do -- 736
			local pi = 0 -- 737
			while pi <= posts do -- 737
				local px = left + width * pi / posts -- 738
				draw:drawSegment( -- 739
					Vec2(px, base), -- 739
					Vec2(px, top), -- 739
					1.4, -- 739
					Color( -- 739
						34, -- 739
						24, -- 739
						18, -- 739
						math.floor(210 * opacity + 0.5) -- 739
					) -- 739
				) -- 739
				pi = pi + 1 -- 737
			end -- 737
		end -- 737
		return -- 741
	end -- 741
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 745
	local cols = slot == "wall" and math.max( -- 746
		1, -- 747
		math.min( -- 747
			10, -- 747
			math.floor(solid.w / 72 + 0.5) -- 747
		) -- 747
	) or math.max( -- 747
		1, -- 748
		math.min( -- 748
			10, -- 748
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 748
		) -- 748
	) -- 748
	local colW = width / cols -- 749
	local rows = slot == "wall" and math.max( -- 750
		1, -- 751
		math.min( -- 751
			10, -- 751
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 751
		) -- 751
	) or math.max( -- 751
		1, -- 752
		math.min( -- 752
			6, -- 752
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 752
		) -- 752
	) -- 752
	local rowHeight = frontH / rows -- 753
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 754
	local color = occlusionTint(opacity, masonryColor) -- 755
	local placedAny = false -- 756
	do -- 756
		local row = 0 -- 757
		while row < rows do -- 757
			do -- 757
				local col = 0 -- 758
				while col < cols do -- 758
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 759
					if assets:tryPlace( -- 759
						slot, -- 760
						tileKey, -- 760
						left + (col + 0.5) * colW, -- 760
						base + row * rowHeight, -- 760
						colW + 0.5, -- 760
						rowHeight + 0.5, -- 760
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 760
					) then -- 760
						placedAny = true -- 763
					end -- 763
					col = col + 1 -- 758
				end -- 758
			end -- 758
			row = row + 1 -- 757
		end -- 757
	end -- 757
	if not placedAny then -- 757
		draw:drawRect( -- 768
			Rect(left, base, width, frontH), -- 768
			occlusionTint( -- 769
				opacity, -- 769
				toColor(PALETTE.steelMid, 255 * opacity) -- 769
			), -- 769
			1, -- 770
			toColor(theme.groundRim, 150 * opacity) -- 770
		) -- 770
	end -- 770
end -- 663
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 774
	local columns = math.max( -- 779
		1, -- 779
		math.min( -- 779
			10, -- 779
			math.floor(s.w / 58 + 0.5) -- 779
		) -- 779
	) -- 779
	local cellWorldW = s.w / columns -- 780
	local targetCellH = math.max( -- 781
		24, -- 781
		math.min(48, cellWorldW / 1.52) -- 781
	) -- 781
	local rows = math.max( -- 782
		1, -- 782
		math.min( -- 782
			12, -- 782
			math.floor(s.h / targetCellH + 0.5) -- 782
		) -- 782
	) -- 782
	local tileW = width / columns -- 783
	local tileH = height / rows -- 784
	do -- 784
		local row = 0 -- 785
		while row < rows do -- 785
			do -- 785
				local column = 0 -- 786
				while column < columns do -- 786
					assets:tryPlace( -- 787
						"wall", -- 787
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 787
						x + (column + 0.5) * tileW, -- 788
						y + row * tileH, -- 788
						tileW + 0.5, -- 788
						tileH + 0.5, -- 788
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 789
					) -- 789
					column = column + 1 -- 786
				end -- 786
			end -- 786
			row = row + 1 -- 785
		end -- 785
	end -- 785
end -- 774
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 794
	local slot = coverArt(s) -- 801
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 802
	local cols = math.max( -- 803
		1, -- 803
		math.min( -- 803
			8, -- 803
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 803
		) -- 803
	) -- 803
	local tileW = sw / cols -- 804
	local placed = false -- 805
	do -- 805
		local c = 0 -- 806
		while c < cols do -- 806
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 807
			if assets:tryPlace( -- 807
				slot, -- 808
				k, -- 808
				x0 + (c + 0.5) * tileW, -- 808
				y0, -- 808
				tileW + 0.5, -- 808
				sh, -- 808
				{layer = 1} -- 808
			) then -- 808
				placed = true -- 809
			end -- 809
			c = c + 1 -- 806
		end -- 806
	end -- 806
	if not placed then -- 806
		fillVGradRect( -- 813
			fgDraw, -- 813
			x0, -- 813
			y0, -- 813
			sw, -- 813
			sh, -- 813
			toColor(PALETTE.steelDark), -- 813
			toColor(PALETTE.steelMid) -- 813
		) -- 813
		fgDraw:drawSegment( -- 814
			Vec2(x0, y0 + sh), -- 814
			Vec2(x0 + sw, y0 + sh), -- 814
			1.4, -- 814
			toColor(theme.groundRim) -- 814
		) -- 814
	end -- 814
	if not p.childMode and (p.coverHug or p.coverNear) then -- 814
		local plx = p.player.x -- 819
		local nearLeft = math.abs(plx - s.x) < 42 -- 820
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 821
		if nearLeft or nearRight then -- 821
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 823
			local isWood = slot == "cover_wood" -- 824
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 825
			fgDraw:drawSegment( -- 826
				Vec2(edgeX, y0 + 4), -- 826
				Vec2(edgeX, y0 + sh + 2), -- 826
				p.coverHug and 2 or 1.2, -- 826
				toColor(col, p.coverHug and 205 or 120) -- 826
			) -- 826
		end -- 826
	end -- 826
end -- 794
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 831
	if layer == nil then -- 831
		layer = 2 -- 836
	end -- 836
	local cx = x0 + sw * 0.5 -- 838
	local cy = y0 + sh * 0.55 -- 839
	local ropeWidth = math.max(1, sw * 0.023) -- 840
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 841
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 842
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 843
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 844
	draw:drawEllipse( -- 845
		Vec2(cx, y0), -- 845
		sw * 0.53, -- 845
		sh * 0.07, -- 845
		Color(10, 8, 9, 150) -- 845
	) -- 845
	draw:drawSegment( -- 846
		drum, -- 846
		bend, -- 846
		ropeWidth, -- 846
		Color(111, 86, 57, 239) -- 846
	) -- 846
	draw:drawSegment( -- 847
		bend, -- 847
		ropeTop, -- 847
		ropeWidth, -- 847
		Color(111, 86, 57, 239) -- 847
	) -- 847
	if assets:tryPlace( -- 847
		"prop_winch", -- 848
		"gate_winch", -- 848
		cx, -- 848
		y0 + sh * 0.5, -- 848
		sw, -- 848
		sh, -- 848
		{layer = layer} -- 848
	) then -- 848
		return -- 849
	end -- 849
	local timber = Color(75, 51, 34, 255) -- 851
	draw:drawSegment( -- 852
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 852
		Vec2(cx, y0 + sh * 0.86), -- 852
		sw * 0.06, -- 852
		timber -- 852
	) -- 852
	draw:drawSegment( -- 853
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 853
		Vec2(cx, y0 + sh * 0.86), -- 853
		sw * 0.06, -- 853
		timber -- 853
	) -- 853
	draw:drawRect( -- 854
		Rect(x0, y0, sw, sh * 0.12), -- 854
		timber -- 854
	) -- 854
	local radius = math.min(sw, sh) * 0.21 -- 855
	draw:drawCircle( -- 856
		Vec2(cx, cy), -- 856
		radius, -- 856
		Color(48, 41, 37, 255) -- 856
	) -- 856
	do -- 856
		local i = -2 -- 857
		while i <= 2 do -- 857
			local x = cx + i * radius * 0.28 -- 858
			draw:drawSegment( -- 859
				Vec2(x, cy - radius * 0.62), -- 859
				Vec2(x, cy + radius * 0.62), -- 859
				ropeWidth, -- 859
				Color(135, 103, 68, 240) -- 860
			) -- 860
			i = i + 1 -- 857
		end -- 857
	end -- 857
end -- 831
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 864
	local ____temp_3 -- 872
	if p.room.story ~= nil then -- 872
		____temp_3 = p.room.story.gate -- 872
	else -- 872
		____temp_3 = nil -- 872
	end -- 872
	local g = ____temp_3 -- 872
	if g == nil then -- 872
		return -- 874
	end -- 874
	local closeFrac = 0.08 -- 877
	if p.phase == "gate-hold" then -- 877
		closeFrac = 0.08 + 0.36 * math.min( -- 879
			1, -- 879
			p.gateTick / math.max(1, g.holdTicks) -- 879
		) -- 879
	elseif p.phase == "gate-send" then -- 879
		closeFrac = 0.44 -- 881
	elseif p.phase == "gate-count" then -- 881
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 883
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 883
		closeFrac = 1 -- 885
	end -- 885
	local gx0 = cam:sx(848) -- 887
	local gx1 = cam:sx(1032) -- 888
	local topY = cam:sy(160) -- 889
	local botY = cam:sy(160 * (1 - closeFrac)) -- 890
	local shutterW = gx1 - gx0 -- 891
	local shutterH = topY - botY -- 892
	if shutterH > 2 then -- 892
		fillVGradRect( -- 894
			fgDraw, -- 894
			gx0, -- 894
			botY, -- 894
			shutterW, -- 894
			shutterH, -- 894
			toColor(PALETTE.steelDark), -- 894
			toColor(PALETTE.steelMid) -- 894
		) -- 894
		local rows = math.max( -- 896
			1, -- 896
			math.min( -- 896
				6, -- 896
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 896
			) -- 896
		) -- 896
		local rowH = shutterH / rows -- 897
		do -- 897
			local r = 0 -- 898
			while r < rows do -- 898
				assets:tryPlace( -- 899
					"cover_wood", -- 899
					"gate_shutter_" .. tostring(r), -- 899
					(gx0 + gx1) * 0.5, -- 899
					botY + r * rowH, -- 899
					shutterW, -- 900
					rowH + 0.5, -- 900
					{layer = 6} -- 900
				) -- 900
				r = r + 1 -- 898
			end -- 898
		end -- 898
	end -- 898
	if closeFrac < 0.98 then -- 898
		local gapH = math.max( -- 905
			8, -- 905
			botY - cam:sy(0) -- 905
		) -- 905
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 906
		fillVGradRect( -- 907
			fgGlow, -- 907
			gx0, -- 907
			cam:sy(0), -- 907
			gx1 - gx0, -- 907
			gapH, -- 907
			Color( -- 907
				140, -- 907
				210, -- 907
				255, -- 907
				math.floor(52 * pulse + 0.5) -- 907
			), -- 907
			Color(80, 160, 230, 0) -- 907
		) -- 907
	end -- 907
end -- 864
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 911
	fillVGradRect( -- 918
		fgDraw, -- 918
		x0, -- 918
		y0, -- 918
		sw, -- 918
		sh, -- 918
		Color(15, 21, 34, 255), -- 918
		Color(32, 44, 66, 255) -- 918
	) -- 918
	fgDraw:drawRect( -- 919
		Rect(x0, y0, sw, sh), -- 919
		Color(0, 0, 0, 0), -- 919
		1.4, -- 919
		toColor(PALETTE.rimSilver, 165) -- 919
	) -- 919
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 919
		self:tileMasonry( -- 922
			assets, -- 922
			s, -- 922
			x0, -- 922
			y0, -- 922
			sw, -- 922
			sh -- 922
		) -- 922
		local ribs = 4 -- 924
		local r = 1 -- 925
		do -- 925
			r = 1 -- 926
			while r < ribs do -- 926
				local rx = x0 + sw * r / ribs -- 927
				fgDraw:drawSegment( -- 928
					Vec2(rx, y0), -- 928
					Vec2(rx, y0 + sh), -- 928
					2, -- 928
					Color(10, 15, 24, 210) -- 928
				) -- 928
				fgDraw:drawSegment( -- 929
					Vec2(rx + 2, y0), -- 929
					Vec2(rx + 2, y0 + sh), -- 929
					1, -- 929
					Color(68, 86, 114, 130) -- 929
				) -- 929
				r = r + 1 -- 926
			end -- 926
		end -- 926
		local bands = 4 -- 932
		local b = 1 -- 933
		do -- 933
			b = 1 -- 934
			while b < bands do -- 934
				local by = y0 + sh * b / bands -- 935
				fgDraw:drawSegment( -- 936
					Vec2(x0 + 4, by), -- 936
					Vec2(x0 + sw - 4, by), -- 936
					1.2, -- 936
					Color(52, 68, 92, 135) -- 936
				) -- 936
				b = b + 1 -- 934
			end -- 934
		end -- 934
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 939
		local slitY = y0 + sh * 0.56 -- 940
		local slitH = sh * 0.22 -- 941
		fgDraw:drawRect( -- 942
			Rect(slitX - 5, slitY, 10, slitH), -- 942
			Color(8, 12, 20, 245), -- 942
			1.2, -- 942
			toColor(PALETTE.amberDim, 190) -- 942
		) -- 942
		fgGlow:drawRect( -- 943
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 943
			toColor(PALETTE.amber, 190) -- 943
		) -- 943
		fillRadialGlow( -- 944
			fgGlow, -- 944
			slitX, -- 944
			slitY + slitH * 0.5, -- 944
			44, -- 944
			slitH * 0.7, -- 944
			Color(255, 206, 128, 52), -- 944
			Color(255, 180, 86, 0), -- 944
			14 -- 944
		) -- 944
	end -- 944
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 944
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 949
		local cx = x0 + sw * 0.5 -- 954
		local lampY = y0 - 8 -- 955
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 956
		if not opened then -- 956
			assets:tryPlace( -- 958
				"prop_tower_door", -- 958
				"tower_door", -- 958
				cx, -- 958
				y0 - doorHeight, -- 958
				sw, -- 958
				doorHeight, -- 958
				{layer = 2} -- 958
			) -- 958
		end -- 958
		assets:tryPlace( -- 960
			"prop_lantern", -- 960
			"tower_lantern", -- 960
			cx + sw * 0.43, -- 960
			lampY - sh * 0.36, -- 960
			sw * 0.17, -- 961
			sh * 0.84, -- 961
			{layer = 3} -- 961
		) -- 961
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 962
		local alpha = opened and 155 or 88 -- 963
		fgDraw:drawSegment( -- 965
			Vec2(x0 + 4, y0), -- 965
			Vec2(x0 + 4, y0 - sh * 3.8), -- 965
			4, -- 965
			Color(42, 52, 70, 255) -- 965
		) -- 965
		fgDraw:drawSegment( -- 966
			Vec2(x0 + sw - 4, y0), -- 966
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 966
			4, -- 966
			Color(42, 52, 70, 255) -- 966
		) -- 966
		fgDraw:drawSegment( -- 967
			Vec2(x0, y0), -- 967
			Vec2(x0 + sw, y0), -- 967
			2.5, -- 967
			toColor(PALETTE.amber, 210) -- 967
		) -- 967
		fillVGradRect( -- 969
			fgGlow, -- 970
			x0 + 6, -- 971
			y0 - sh * 3.8, -- 972
			sw - 12, -- 973
			sh * 3.8, -- 974
			Color( -- 975
				255, -- 975
				206, -- 975
				128, -- 975
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 975
			), -- 975
			Color(255, 224, 168, opened and 180 or 62) -- 976
		) -- 976
		fillRadialGlow( -- 978
			fgGlow, -- 978
			cx, -- 978
			lampY, -- 978
			opened and 105 or 58, -- 978
			opened and 105 or 58, -- 978
			Color( -- 978
				255, -- 978
				232, -- 978
				178, -- 978
				math.floor(170 * pulse + 0.5) -- 978
			), -- 978
			Color(255, 180, 86, 0), -- 978
			18 -- 978
		) -- 978
		fgDraw:drawCircle( -- 979
			Vec2(cx, lampY), -- 979
			5.5, -- 979
			toColor(PALETTE.amberCore) -- 979
		) -- 979
		if opened then -- 979
			local deskCx = cam:sx(p.ox + 605) -- 983
			local groundY = cam:sy(0) -- 984
			local deskW = cam:len(84) -- 985
			local deskH = cam:len(34) -- 986
			local deskTop = groundY + deskH -- 987
			fillRadialGlow( -- 989
				fgGlow, -- 989
				deskCx, -- 989
				deskTop + cam:len(32), -- 989
				cam:len(115), -- 989
				cam:len(90), -- 989
				Color( -- 990
					255, -- 990
					198, -- 990
					114, -- 990
					math.floor(68 * pulse + 0.5) -- 990
				), -- 990
				Color(255, 168, 72, 0), -- 990
				16 -- 990
			) -- 990
			local guardX = deskCx + cam:len(26) -- 992
			fgDraw:drawRect( -- 993
				Rect( -- 993
					guardX - cam:len(11), -- 993
					groundY, -- 993
					cam:len(22), -- 993
					cam:len(68) -- 993
				), -- 993
				Color(34, 42, 54, 240) -- 993
			) -- 993
			fgDraw:drawCircle( -- 994
				Vec2( -- 994
					guardX, -- 994
					groundY + cam:len(76) -- 994
				), -- 994
				cam:len(9.5), -- 994
				Color(42, 50, 62, 245) -- 994
			) -- 994
			fgDraw:drawRect( -- 996
				Rect( -- 996
					deskCx - deskW * 0.5, -- 996
					groundY, -- 996
					cam:len(6), -- 996
					deskH -- 996
				), -- 996
				Color(78, 52, 34, 255) -- 996
			) -- 996
			fgDraw:drawRect( -- 997
				Rect( -- 997
					deskCx + deskW * 0.5 - cam:len(6), -- 997
					groundY, -- 997
					cam:len(6), -- 997
					deskH -- 997
				), -- 997
				Color(78, 52, 34, 255) -- 997
			) -- 997
			fgDraw:drawRect( -- 998
				Rect( -- 998
					deskCx - deskW * 0.52, -- 998
					deskTop - cam:len(6), -- 998
					deskW * 1.04, -- 998
					cam:len(8) -- 998
				), -- 998
				Color(108, 74, 46, 255), -- 998
				1, -- 998
				Color(148, 108, 68, 220) -- 998
			) -- 998
			fgDraw:drawRect( -- 1000
				Rect( -- 1000
					deskCx + cam:len(4), -- 1000
					deskTop + cam:len(2), -- 1000
					cam:len(24), -- 1000
					cam:len(5) -- 1000
				), -- 1000
				Color(232, 222, 198, 245) -- 1000
			) -- 1000
			fgDraw:drawRect( -- 1001
				Rect( -- 1001
					deskCx + cam:len(32), -- 1001
					deskTop + cam:len(2), -- 1001
					cam:len(8), -- 1001
					cam:len(12) -- 1001
				), -- 1001
				Color(168, 128, 64, 245) -- 1001
			) -- 1001
			fgGlow:drawCircle( -- 1002
				Vec2( -- 1002
					deskCx + cam:len(36), -- 1002
					deskTop + cam:len(16) -- 1002
				), -- 1002
				cam:len(5.5), -- 1002
				Color( -- 1002
					255, -- 1002
					224, -- 1002
					152, -- 1002
					math.floor(220 * pulse + 0.5) -- 1002
				) -- 1002
			) -- 1002
			if p.deskHold >= 12 or p.towerHanded then -- 1002
				fgDraw:drawRect( -- 1005
					Rect( -- 1005
						deskCx - cam:len(28), -- 1005
						deskTop + cam:len(2), -- 1005
						cam:len(14), -- 1005
						cam:len(6) -- 1005
					), -- 1005
					Color(156, 62, 48, 245) -- 1005
				) -- 1005
			end -- 1005
			if p.deskHold >= 24 or p.towerHanded then -- 1005
				fgDraw:drawCircle( -- 1008
					Vec2( -- 1008
						deskCx - cam:len(8), -- 1008
						deskTop + cam:len(5) -- 1008
					), -- 1008
					cam:len(4.5), -- 1008
					Color(224, 186, 98, 255) -- 1008
				) -- 1008
				fgDraw:drawRect( -- 1009
					Rect( -- 1009
						deskCx - cam:len(16), -- 1009
						deskTop + cam:len(2), -- 1009
						cam:len(10), -- 1009
						cam:len(3) -- 1009
					), -- 1009
					Color(236, 228, 206, 240) -- 1009
				) -- 1009
			end -- 1009
		end -- 1009
	end -- 1009
end -- 911
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1015
	local blades = math.max( -- 1022
		12, -- 1022
		math.floor(sw / 8) -- 1022
	) -- 1022
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1023
	local k = 0 -- 1024
	do -- 1024
		k = 0 -- 1025
		while k < blades do -- 1025
			local t = (k + 0.5) / blades -- 1026
			local bx = x0 + sw * t -- 1027
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1028
			local bh = sh * hRatio * 1.95 -- 1029
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1030
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1031
			fgDraw:drawPolygon( -- 1032
				{ -- 1032
					Vec2(bx - 7, y0), -- 1033
					Vec2(bx + 7, y0), -- 1034
					Vec2(bx + sway, y0 + bh) -- 1035
				}, -- 1035
				col -- 1036
			) -- 1036
			k = k + 1 -- 1025
		end -- 1025
	end -- 1025
	if nearPlayer then -- 1025
		fgGlow:drawSegment( -- 1039
			Vec2(x0, y0 + 2), -- 1039
			Vec2(x0 + sw, y0 + 2), -- 1039
			2, -- 1039
			toColor(PALETTE.emerald, 145) -- 1039
		) -- 1039
	end -- 1039
end -- 1015
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1043
	local a = p.room.arch -- 1048
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1048
		return -- 1050
	end -- 1050
	local x0 = cam:sx(a.x0) -- 1052
	local x1 = cam:sx(a.x1) -- 1053
	local y0 = cam:sy(a.y) -- 1054
	local y1 = cam:sy(a.y + a.h) -- 1055
	local cx = (x0 + x1) * 0.5 -- 1056
	local rx = (x1 - x0) * 0.5 -- 1057
	local rise = cam:len(9) -- 1058
	local rim = cam:len(7) -- 1059
	local slices = 9 -- 1060
	local mortar = Color(31, 32, 35, 255) -- 1061
	local function point(i, edge) -- 1062
		local angle = math.pi * i / slices -- 1063
		return Vec2( -- 1064
			cx + math.cos(angle) * (rx + edge), -- 1064
			y1 + math.sin(angle) * (rise + edge) -- 1064
		) -- 1064
	end -- 1062
	local opening = { -- 1066
		Vec2(x0, y0), -- 1066
		Vec2(x1, y0) -- 1066
	} -- 1066
	do -- 1066
		local i = 0 -- 1067
		while i <= slices do -- 1067
			opening[#opening + 1] = point(i, 0) -- 1068
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	draw:drawPolygon( -- 1070
		opening, -- 1070
		Color(13, 15, 20, 248) -- 1070
	) -- 1070
	draw:drawRect( -- 1071
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1071
		Color(62, 63, 67, 255), -- 1071
		1, -- 1071
		mortar -- 1071
	) -- 1071
	draw:drawRect( -- 1072
		Rect(x1, y0, rim, y1 - y0), -- 1072
		Color(72, 72, 74, 255), -- 1072
		1, -- 1072
		mortar -- 1072
	) -- 1072
	do -- 1072
		local i = 0 -- 1073
		while i < slices do -- 1073
			local shade = 77 + i % 3 * 8 -- 1074
			draw:drawPolygon( -- 1075
				{ -- 1075
					point(i, 0), -- 1075
					point(i, rim), -- 1075
					point(i + 1, rim), -- 1075
					point(i + 1, 0) -- 1075
				}, -- 1075
				Color(shade, shade, shade + 1, 255), -- 1076
				1, -- 1076
				mortar -- 1076
			) -- 1076
			i = i + 1 -- 1073
		end -- 1073
	end -- 1073
	if not p.cartDocked then -- 1073
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1080
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1081
		if bx1 > bx0 + 4 then -- 1081
			local deckY = cam:sy(p.room.cart.baseY) -- 1083
			draw:drawRect( -- 1084
				Rect(bx0, y0 + 2, bx1 - bx0, y1 - y0 - 2), -- 1084
				Color(72, 52, 36, 245), -- 1084
				1.1, -- 1084
				Color(138, 108, 78, 210) -- 1084
			) -- 1084
			draw:drawSegment( -- 1085
				Vec2((bx0 + bx1) * 0.5, y1), -- 1085
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1085
				2.4, -- 1085
				Color(96, 102, 110, 220) -- 1085
			) -- 1085
		end -- 1085
	end -- 1085
end -- 1043
return ____exports -- 1043