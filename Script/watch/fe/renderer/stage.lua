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
	local mr = h * 0.082 -- 164
	fillRadialGlow( -- 165
		bgGlow, -- 165
		mx, -- 165
		my, -- 165
		mr * 5.2, -- 165
		mr * 5.2, -- 165
		Color(86, 210, 255, 34), -- 165
		Color(10, 24, 52, 0), -- 165
		24 -- 165
	) -- 165
	fillRadialGlow( -- 166
		bgGlow, -- 166
		mx, -- 166
		my, -- 166
		mr * 2.1, -- 166
		mr * 2.1, -- 166
		Color(190, 240, 255, 76), -- 166
		Color(40, 120, 190, 0), -- 166
		20 -- 166
	) -- 166
	bgDraw:drawCircle( -- 167
		Vec2(mx, my), -- 167
		mr, -- 167
		Color(228, 242, 255, 235) -- 167
	) -- 167
	bgDraw:drawCircle( -- 168
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 168
		mr * 0.86, -- 168
		Color(10, 18, 34, 125) -- 168
	) -- 168
	local s = 0 -- 171
	do -- 171
		s = 0 -- 172
		while s < 3 do -- 172
			local bx = w * (0.36 + s * 0.24) -- 173
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 174
			local ang = math.pi * 0.5 + sway - 0.12 -- 175
			local len = h * 1.15 -- 176
			local spread = 0.085 + s * 0.015 -- 177
			local x1 = bx + math.cos(ang - spread) * len -- 178
			local y1 = math.sin(ang - spread) * len -- 179
			local x2 = bx + math.cos(ang + spread) * len -- 180
			local y2 = math.sin(ang + spread) * len -- 181
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 182
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 183
			bgGlow:drawVertices({ -- 184
				{ -- 185
					Vec2(bx, h * 0.15), -- 185
					baseCol -- 185
				}, -- 185
				{ -- 186
					Vec2(x1, y1), -- 186
					tipCol -- 186
				}, -- 186
				{ -- 187
					Vec2(x2, y2), -- 187
					tipCol -- 187
				} -- 187
			}) -- 187
			s = s + 1 -- 172
		end -- 172
	end -- 172
	local groundY = h * 0.19 -- 192
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < 16 do -- 194
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 195
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 196
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 197
			local cut = 12 + hash01(i * 19) * 20 -- 198
			bgDraw:drawPolygon( -- 199
				{ -- 199
					Vec2(bx, groundY), -- 200
					Vec2(bx + bw, groundY), -- 201
					Vec2(bx + bw, groundY + bh - cut), -- 202
					Vec2(bx + bw - cut, groundY + bh), -- 203
					Vec2(bx, groundY + bh) -- 204
				}, -- 204
				Color(10, 16, 28, 255) -- 205
			) -- 205
			if hash01(i * 41 + 5) > 0.45 then -- 205
				local wy = groundY + bh * 0.65 -- 208
				bgGlow:drawSegment( -- 209
					Vec2(bx + 10, wy), -- 209
					Vec2(bx + bw - 14, wy), -- 209
					1.2, -- 209
					Color(72, 224, 255, 95) -- 209
				) -- 209
			end -- 209
			i = i + 1 -- 194
		end -- 194
	end -- 194
	local tx = w * 0.83 -- 214
	local ty0 = groundY -- 215
	local ty1 = h * 0.62 -- 216
	bgDraw:drawPolygon( -- 217
		{ -- 217
			Vec2(tx - 26, ty0), -- 218
			Vec2(tx + 26, ty0), -- 219
			Vec2(tx + 11, ty1), -- 220
			Vec2(tx - 11, ty1) -- 221
		}, -- 221
		Color(15, 24, 40, 255), -- 222
		1.2, -- 222
		Color(58, 86, 118, 140) -- 222
	) -- 222
	bgDraw:drawSegment( -- 223
		Vec2(tx, ty0 + 24), -- 223
		Vec2(tx, ty1 - 12), -- 223
		1.4, -- 223
		Color(242, 188, 96, 85) -- 223
	) -- 223
	bgDraw:drawSegment( -- 224
		Vec2(tx, ty1), -- 224
		Vec2(tx, ty1 + 42), -- 224
		2.2, -- 224
		Color(165, 212, 248, 210) -- 224
	) -- 224
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 225
	fillRadialGlow( -- 226
		bgGlow, -- 226
		tx, -- 226
		ty1 + 42, -- 226
		74 * pulse, -- 226
		74 * pulse, -- 226
		Color(255, 222, 146, 130), -- 226
		Color(255, 180, 90, 0), -- 226
		20 -- 226
	) -- 226
	bgGlow:drawDot( -- 227
		Vec2(tx, ty1 + 42), -- 227
		5, -- 227
		Color(255, 248, 224, 255) -- 227
	) -- 227
	fillVGradRect( -- 230
		bgDraw, -- 230
		0, -- 230
		0, -- 230
		w, -- 230
		groundY, -- 230
		Color(6, 9, 16, 255), -- 230
		Color(16, 24, 38, 255) -- 230
	) -- 230
	bgDraw:drawSegment( -- 231
		Vec2(0, groundY), -- 231
		Vec2(w, groundY), -- 231
		2, -- 231
		Color(76, 220, 255, 180) -- 231
	) -- 231
	fillVGradRect( -- 232
		bgGlow, -- 232
		0, -- 232
		groundY, -- 232
		w, -- 232
		h * 0.24, -- 232
		Color(42, 130, 182, 52), -- 232
		Color(20, 60, 100, 0) -- 232
	) -- 232
	local sx = w * 0.64 -- 235
	fillRadialGlow( -- 236
		bgGlow, -- 236
		sx + 38, -- 236
		groundY + 75, -- 236
		128, -- 236
		92, -- 236
		Color(52, 178, 232, 42), -- 236
		Color(20, 60, 110, 0), -- 236
		18 -- 236
	) -- 236
	bgDraw:drawPolygon( -- 238
		{ -- 238
			Vec2(sx - 36, groundY + 12), -- 239
			Vec2(sx + 10, groundY + 18), -- 240
			Vec2(sx + 16, groundY + 124), -- 241
			Vec2(sx - 18, groundY + 124) -- 242
		}, -- 242
		Color(10, 16, 28, 255), -- 243
		1.3, -- 243
		Color(76, 210, 255, 145) -- 243
	) -- 243
	bgDraw:drawSegment( -- 244
		Vec2(sx - 6, groundY + 48), -- 244
		Vec2(sx - 12, groundY + 2), -- 244
		6, -- 244
		Color(10, 16, 28, 255) -- 244
	) -- 244
	bgDraw:drawSegment( -- 245
		Vec2(sx + 6, groundY + 48), -- 245
		Vec2(sx + 14, groundY + 2), -- 245
		6, -- 245
		Color(14, 22, 36, 255) -- 245
	) -- 245
	bgDraw:drawPolygon( -- 246
		{ -- 246
			Vec2(sx - 20, groundY + 120), -- 247
			Vec2(sx + 20, groundY + 122), -- 248
			Vec2(sx + 16, groundY + 132), -- 249
			Vec2(sx - 16, groundY + 130) -- 250
		}, -- 250
		Color(208, 236, 252, 240) -- 251
	) -- 251
	bgDraw:drawCircle( -- 252
		Vec2(sx + 2, groundY + 146), -- 252
		13, -- 252
		Color(14, 22, 36, 255) -- 252
	) -- 252
	bgDraw:drawArc( -- 253
		Vec2(sx + 2, groundY + 146), -- 253
		13.5, -- 253
		30, -- 253
		165, -- 253
		2, -- 253
		Color(216, 240, 255, 230) -- 253
	) -- 253
	bgGlow:drawSegment( -- 254
		Vec2(sx + 4, groundY + 148), -- 254
		Vec2(sx + 17, groundY + 150), -- 254
		2.6, -- 254
		Color(86, 240, 255, 255) -- 254
	) -- 254
	bgDraw:drawSegment( -- 255
		Vec2(sx + 4, groundY + 104), -- 255
		Vec2(sx + 46, groundY + 94), -- 255
		3.4, -- 255
		Color(34, 52, 74, 255) -- 255
	) -- 255
	bgGlow:drawSegment( -- 256
		Vec2(sx + 16, groundY + 102), -- 256
		Vec2(sx + 44, groundY + 95), -- 256
		1.2, -- 256
		Color(86, 236, 255, 200) -- 256
	) -- 256
	local cx = w * 0.725 -- 259
	bgDraw:drawPolygon( -- 260
		{ -- 260
			Vec2(cx - 20, groundY + 14), -- 261
			Vec2(cx + 18, groundY + 14), -- 262
			Vec2(cx + 12, groundY + 84), -- 263
			Vec2(cx - 12, groundY + 84) -- 264
		}, -- 264
		Color(188, 142, 78, 238), -- 265
		1.4, -- 265
		Color(252, 232, 192, 225) -- 265
	) -- 265
	bgDraw:drawSegment( -- 266
		Vec2(cx - 5, groundY + 24), -- 266
		Vec2(cx - 6, groundY + 2), -- 266
		4.2, -- 266
		Color(28, 24, 30, 255) -- 266
	) -- 266
	bgDraw:drawSegment( -- 267
		Vec2(cx + 5, groundY + 24), -- 267
		Vec2(cx + 6, groundY + 2), -- 267
		4.2, -- 267
		Color(38, 32, 38, 255) -- 267
	) -- 267
	bgDraw:drawCircle( -- 268
		Vec2(cx + 1, groundY + 95), -- 268
		11, -- 268
		Color(238, 220, 194, 250) -- 268
	) -- 268
	bgDraw:drawPolygon( -- 269
		{ -- 269
			Vec2(cx - 15, groundY + 84), -- 270
			Vec2(cx - 10, groundY + 108), -- 271
			Vec2(cx + 6, groundY + 107), -- 272
			Vec2(cx - 4, groundY + 84) -- 273
		}, -- 273
		Color(156, 114, 62, 245) -- 274
	) -- 274
	bgGlow:drawSegment( -- 275
		Vec2(cx - 8, groundY + 82), -- 275
		Vec2(cx - 30, groundY + 64), -- 275
		2.8, -- 275
		Color(252, 230, 178, 220) -- 275
	) -- 275
	fillRadialGlow( -- 276
		bgGlow, -- 276
		cx + 10, -- 276
		groundY + 56, -- 276
		30, -- 276
		30, -- 276
		Color(255, 214, 130, 115), -- 276
		Color(250, 180, 70, 0), -- 276
		16 -- 276
	) -- 276
	bgGlow:drawDot( -- 277
		Vec2(cx + 10, groundY + 56), -- 277
		3.2, -- 277
		Color(255, 246, 220, 255) -- 277
	) -- 277
end -- 149
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 281
	local theme = themeOf(p.room.key) -- 291
	self:drawFloors( -- 292
		fgDraw, -- 292
		assets, -- 292
		p, -- 292
		cam, -- 292
		theme -- 292
	) -- 292
	self:drawStairs( -- 293
		fgDraw, -- 293
		fgGlow, -- 293
		assets, -- 293
		p, -- 293
		cam, -- 293
		theme -- 293
	) -- 293
	self:drawSolids( -- 294
		fgDraw, -- 294
		fgGlow, -- 294
		assets, -- 294
		p, -- 294
		cam, -- 294
		theme, -- 294
		time, -- 294
		occlusion, -- 294
		fadeDt -- 294
	) -- 294
	if p.room.key == "gate" then -- 294
		self:drawGateShutter( -- 296
			fgDraw, -- 296
			fgGlow, -- 296
			assets, -- 296
			p, -- 296
			cam, -- 296
			time -- 296
		) -- 296
	end -- 296
	self:drawArch(fgDraw, p, cam) -- 298
end -- 281
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 302
	local seed = roomSeed(p.room.key) -- 309
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 311
	local span = 520 -- 312
	local startIdx = math.floor((-parallax - 200) / span) -- 313
	local idx = startIdx -- 314
	do -- 314
		idx = startIdx -- 315
		while idx <= startIdx + 4 do -- 315
			local x = idx * span + parallax -- 316
			local r = hash01(seed + idx * 17) -- 317
			local bw = 70 + r * 90 -- 318
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 319
			fgDraw:drawPolygon( -- 320
				{ -- 320
					Vec2(x, 0), -- 321
					Vec2(x + bw, 0), -- 322
					Vec2(x + bw - 18, bh), -- 323
					Vec2(x + 12, bh * 0.72) -- 324
				}, -- 324
				Color(4, 6, 11, 225) -- 325
			) -- 325
			idx = idx + 1 -- 315
		end -- 315
	end -- 315
	fillVGradRect( -- 329
		fgDraw, -- 329
		0, -- 329
		h - h * 0.16, -- 329
		w, -- 329
		h * 0.16, -- 329
		Color(4, 6, 12, 0), -- 329
		Color(4, 6, 12, 138) -- 329
	) -- 329
	fillVGradRect( -- 330
		fgDraw, -- 330
		0, -- 330
		0, -- 330
		w, -- 330
		h * 0.13, -- 330
		Color(4, 6, 12, 185), -- 330
		Color(4, 6, 12, 0) -- 330
	) -- 330
end -- 302
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 333
	local count = 3 -- 342
	local i = 0 -- 343
	do -- 343
		i = 0 -- 344
		while i < count do -- 344
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 345
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 346
			local by = cam.groundScreenY * 0.85 -- 347
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 348
			local ang = math.pi * 0.5 + sway -- 349
			local len = h * 1.15 -- 350
			local halfSpread = 0.065 + i % 2 * 0.025 -- 351
			local x1 = bx + math.cos(ang - halfSpread) * len -- 352
			local y1 = by + math.sin(ang - halfSpread) * len -- 353
			local x2 = bx + math.cos(ang + halfSpread) * len -- 354
			local y2 = by + math.sin(ang + halfSpread) * len -- 355
			local c0 = toColor(theme.beamColor) -- 356
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 357
			bgGlow:drawVertices({ -- 358
				{ -- 359
					Vec2(bx, by), -- 359
					c0 -- 359
				}, -- 359
				{ -- 360
					Vec2(x1, y1), -- 360
					c1 -- 360
				}, -- 360
				{ -- 361
					Vec2(x2, y2), -- 361
					c1 -- 361
				} -- 361
			}) -- 361
			i = i + 1 -- 344
		end -- 344
	end -- 344
end -- 333
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 366
	local baseY = cam.groundScreenY - 8 -- 375
	local shift = -cam.x * 0.2 * cam.ppu -- 376
	local colW = 108 -- 377
	local first = math.floor((-shift - colW) / colW) -- 378
	local count = math.ceil(w / colW) + 3 -- 379
	local i = 0 -- 380
	do -- 380
		i = 0 -- 381
		while i < count do -- 381
			local idx = first + i -- 382
			local r1 = hash01(seed + idx * 13.7) -- 383
			local r2 = hash01(seed + idx * 29.3) -- 384
			local r3 = hash01(seed + idx * 47.1) -- 385
			local x = idx * colW + shift -- 386
			local bw = colW * (0.68 + r1 * 0.44) -- 387
			local bh = h * (0.18 + r2 * 0.38) -- 388
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 389
			bgDraw:drawPolygon( -- 391
				{ -- 391
					Vec2(x, baseY), -- 392
					Vec2(x + bw, baseY), -- 393
					Vec2(x + bw, baseY + bh - cut), -- 394
					Vec2(x + bw - cut, baseY + bh), -- 395
					Vec2(x, baseY + bh) -- 396
				}, -- 396
				toColor(theme.farBuilding) -- 397
			) -- 397
			if r3 > 0.62 then -- 397
				local ax = x + bw * 0.25 -- 401
				bgDraw:drawSegment( -- 402
					Vec2(ax, baseY + bh), -- 402
					Vec2(ax, baseY + bh + 32), -- 402
					1.2, -- 402
					toColor(theme.farBuilding) -- 402
				) -- 402
				if r1 > 0.6 then -- 402
					bgGlow:drawDot( -- 404
						Vec2(ax, baseY + bh + 32), -- 404
						2.2, -- 404
						toColor(theme.accent, 145) -- 404
					) -- 404
				end -- 404
			end -- 404
			if r2 > 0.55 then -- 404
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 409
				bgGlow:drawSegment( -- 410
					Vec2(x + 12, wy), -- 410
					Vec2(x + bw - 14, wy), -- 410
					1.1, -- 410
					toColor(theme.accent, 64) -- 410
				) -- 410
			end -- 410
			i = i + 1 -- 381
		end -- 381
	end -- 381
end -- 366
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 415
	local baseY = cam.groundScreenY - 8 -- 423
	local shift = -cam.x * 0.22 * cam.ppu -- 424
	local step = 76 -- 425
	local first = math.floor((-shift - step) / step) -- 426
	local count = math.ceil(w / step) + 4 -- 427
	local i = 0 -- 428
	do -- 428
		i = 0 -- 429
		while i < count do -- 429
			local idx = first + i -- 430
			local r1 = hash01(seed + idx * 11.3) -- 431
			local r2 = hash01(seed + idx * 23.9) -- 432
			local cx = idx * step + shift -- 433
			local tw = 34 + r1 * 38 -- 434
			local th = h * (0.24 + r2 * 0.34) -- 435
			bgDraw:drawPolygon( -- 437
				{ -- 437
					Vec2(cx - tw, baseY), -- 438
					Vec2(cx + tw, baseY), -- 439
					Vec2(cx, baseY + th) -- 440
				}, -- 440
				toColor(theme.farBuilding) -- 441
			) -- 441
			bgDraw:drawPolygon( -- 442
				{ -- 442
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 443
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 444
					Vec2(cx, baseY + th * 1.12) -- 445
				}, -- 445
				toColor(theme.farBuilding) -- 446
			) -- 446
			i = i + 1 -- 429
		end -- 429
	end -- 429
end -- 415
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 450
	local baseY = cam.groundScreenY - 4 -- 460
	local shift = -cam.x * 0.48 * cam.ppu -- 461
	local bay = 240 -- 462
	local first = math.floor((-shift - bay) / bay) -- 463
	local count = math.ceil(w / bay) + 3 -- 464
	local col = toColor(theme.midBuilding) -- 465
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 466
	local i = 0 -- 468
	do -- 468
		i = 0 -- 469
		while i < count do -- 469
			local idx = first + i -- 470
			local r = hash01(seed + idx * 37.3) -- 471
			local x = idx * bay + shift -- 472
			local colH = h * (0.34 + r * 0.24) -- 473
			local pw = 22 + r * 16 -- 474
			bgDraw:drawRect( -- 477
				Rect(x, baseY, pw, colH), -- 477
				col -- 477
			) -- 477
			bgDraw:drawSegment( -- 478
				Vec2(x + pw, baseY), -- 478
				Vec2(x + pw, baseY + colH), -- 478
				1, -- 478
				edge -- 478
			) -- 478
			if r > 0.35 then -- 478
				local beamY = baseY + colH * 0.76 -- 480
				bgDraw:drawSegment( -- 481
					Vec2(x + pw, beamY), -- 481
					Vec2(x + bay, beamY), -- 481
					4, -- 481
					col -- 481
				) -- 481
				bgDraw:drawSegment( -- 482
					Vec2(x + pw, beamY - 22), -- 482
					Vec2(x + bay * 0.5, beamY), -- 482
					1.4, -- 482
					edge -- 482
				) -- 482
				bgDraw:drawSegment( -- 483
					Vec2(x + bay * 0.5, beamY), -- 483
					Vec2(x + bay, beamY - 22), -- 483
					1.4, -- 483
					edge -- 483
				) -- 483
			end -- 483
			bgDraw:drawQuadraticBezier( -- 487
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 488
				Vec2( -- 489
					x + bay * 0.5, -- 489
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 489
				), -- 489
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 490
				1, -- 491
				Color(12, 18, 28, 180) -- 492
			) -- 492
			if idx & 1 == 0 then -- 492
				local lx = x + bay * 0.52 -- 497
				local ly = baseY + h * 0.31 -- 498
				bgDraw:drawSegment( -- 499
					Vec2(lx, baseY), -- 499
					Vec2(lx, ly), -- 499
					2.2, -- 499
					col -- 499
				) -- 499
				bgDraw:drawSegment( -- 500
					Vec2(lx, ly), -- 500
					Vec2(lx + 18, ly - 4), -- 500
					2, -- 500
					col -- 500
				) -- 500
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 501
				local lc = theme.accent -- 502
				bgGlow:drawDot( -- 503
					Vec2(lx + 18, ly - 5), -- 503
					3.2, -- 503
					toColor(lc, 210 * flicker) -- 503
				) -- 503
				fillRadialGlow( -- 504
					bgGlow, -- 504
					lx + 18, -- 504
					ly - 5, -- 504
					36, -- 504
					36, -- 504
					toColor(lc, 54 * flicker), -- 504
					Color(lc.r, lc.g, lc.b, 0), -- 504
					14 -- 504
				) -- 504
				bgGlow:drawVertices({ -- 505
					{ -- 506
						Vec2(lx + 18, ly - 6), -- 506
						toColor(lc, 38 * flicker) -- 506
					}, -- 506
					{ -- 507
						Vec2(lx - 42, baseY), -- 507
						Color(lc.r, lc.g, lc.b, 0) -- 507
					}, -- 507
					{ -- 508
						Vec2(lx + 78, baseY), -- 508
						Color(lc.r, lc.g, lc.b, 0) -- 508
					} -- 508
				}) -- 508
			end -- 508
			i = i + 1 -- 469
		end -- 469
	end -- 469
end -- 450
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 514
	local baseY = cam.groundScreenY - 4 -- 524
	local shift = -cam.x * 0.52 * cam.ppu -- 525
	local span = 156 -- 526
	local first = math.floor((-shift - span) / span) -- 527
	local count = math.ceil(w / span) + 3 -- 528
	local col = toColor(theme.midBuilding) -- 529
	local i = 0 -- 531
	do -- 531
		i = 0 -- 532
		while i < count do -- 532
			local idx = first + i -- 533
			local r = hash01(seed + idx * 19.7) -- 534
			local x = idx * span + shift -- 535
			local trunkW = 14 + r * 14 -- 536
			local sway = math.sin(time * 0.9 + idx) * 4 -- 537
			bgDraw:drawPolygon( -- 538
				{ -- 538
					Vec2(x - trunkW * 0.5, baseY), -- 539
					Vec2(x + trunkW * 0.5, baseY), -- 540
					Vec2(x + trunkW * 0.25 + sway, h), -- 541
					Vec2(x - trunkW * 0.3 + sway, h) -- 542
				}, -- 542
				col -- 543
			) -- 543
			if idx % 3 == 0 then -- 543
				bgGlow:drawVertices({ -- 546
					{ -- 547
						Vec2(x + 40, h), -- 547
						Color(110, 232, 200, 26) -- 547
					}, -- 547
					{ -- 548
						Vec2(x + 115, h), -- 548
						Color(110, 232, 200, 0) -- 548
					}, -- 548
					{ -- 549
						Vec2(x - 60, baseY), -- 549
						Color(110, 232, 200, 0) -- 549
					} -- 549
				}) -- 549
			end -- 549
			i = i + 1 -- 532
		end -- 532
	end -- 532
end -- 514
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 555
	local scale = 0.55 -- 565
	if p.room.key == "village" then -- 565
		scale = 0.72 -- 567
	elseif p.room.key == "forest" then -- 567
		scale = 0.92 -- 569
	elseif p.room.key == "tower" then -- 569
		scale = 1.15 -- 571
	end -- 571
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 573
	local baseY = cam.groundScreenY - 8 -- 574
	local towerH = h * 0.42 * scale -- 575
	local bw = 20 * scale -- 576
	bgDraw:drawPolygon( -- 577
		{ -- 577
			Vec2(tx - bw, baseY), -- 578
			Vec2(tx + bw, baseY), -- 579
			Vec2(tx + bw * 0.45, baseY + towerH), -- 580
			Vec2(tx - bw * 0.45, baseY + towerH) -- 581
		}, -- 581
		Color(14, 24, 38, 240) -- 582
	) -- 582
	bgDraw:drawSegment( -- 583
		Vec2(tx, baseY + towerH), -- 583
		Vec2(tx, baseY + towerH + 28 * scale), -- 583
		1.8, -- 583
		Color(180, 210, 238, 200) -- 583
	) -- 583
	local topY = baseY + towerH + 24 * scale -- 585
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 586
	fillRadialGlow( -- 587
		bgGlow, -- 587
		tx, -- 587
		topY, -- 587
		56 * scale * pulse, -- 587
		56 * scale * pulse, -- 587
		Color(255, 224, 152, 118), -- 587
		Color(255, 190, 96, 0), -- 587
		18 -- 587
	) -- 587
	bgGlow:drawDot( -- 588
		Vec2(tx, topY), -- 588
		3.6 * scale, -- 588
		Color(255, 246, 220, 255) -- 588
	) -- 588
end -- 555
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 591
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 598
	do -- 598
		local i = 0 -- 599
		while i < #p.room.floors do -- 599
			local floor = p.room.floors[i + 1] -- 600
			local left = cam:sx(floor.x0) -- 601
			local right = cam:sx(floor.x1) -- 602
			local isMain = floor.y <= 0.1 -- 603
			local ____isMain_0 -- 604
			if isMain then -- 604
				____isMain_0 = p.room.depth -- 604
			else -- 604
				____isMain_0 = nil -- 604
			end -- 604
			local road = ____isMain_0 -- 604
			local top = cam:sy(floor.y, road and road.min or 0) -- 605
			if road ~= nil then -- 605
				self:drawRoad( -- 607
					fgDraw, -- 607
					assets, -- 607
					i, -- 607
					left, -- 607
					right, -- 607
					top, -- 607
					cam:sy(floor.y, road.max), -- 607
					cam, -- 607
					theme -- 607
				) -- 607
			end -- 607
			local height = cam:len(isMain and 22 or 12) -- 609
			local bottom = top - height -- 610
			if isMain and bottom > 0 then -- 610
				fillVGradRect( -- 612
					fgDraw, -- 612
					left, -- 612
					0, -- 612
					right - left, -- 612
					bottom + 1, -- 612
					toColor(PALETTE.voidDark), -- 613
					toColor(theme.groundBody) -- 613
				) -- 613
			end -- 613
			fgDraw:drawRect( -- 615
				Rect(left, bottom, right - left, height), -- 615
				toColor(PALETTE.steelDark) -- 615
			) -- 615
			local step = cam:len(96) -- 616
			local start = math.max( -- 617
				0, -- 617
				math.floor(-left / step) -- 617
			) -- 617
			do -- 617
				local j = start -- 618
				while left + j * step < math.min(right, cam.viewW) do -- 618
					local x = left + j * step -- 619
					local width = math.min(step, right - x) -- 620
					assets:tryPlace( -- 621
						"slab", -- 621
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 621
						x + width * 0.5, -- 621
						bottom, -- 621
						width, -- 621
						height -- 621
					) -- 621
					if grass and isMain and j % 3 == 1 then -- 621
						assets:tryPlace( -- 623
							"grass_low", -- 623
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 623
							x + width * 0.5, -- 623
							top - cam:len(3), -- 624
							width * 0.74, -- 624
							cam:len(13), -- 624
							{opacity = 0.83, layer = 1} -- 624
						) -- 624
					end -- 624
					j = j + 1 -- 618
				end -- 618
			end -- 618
			fgDraw:drawSegment( -- 627
				Vec2(left, top), -- 627
				Vec2(right, top), -- 627
				1, -- 627
				toColor(theme.groundRim, 140) -- 627
			) -- 627
			i = i + 1 -- 599
		end -- 599
	end -- 599
end -- 591
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 631
	local width = right - left -- 636
	local height = back - front -- 637
	if width <= 1 or height <= 1 then -- 637
		return -- 639
	end -- 639
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 642
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 643
	fillVGradRect( -- 644
		draw, -- 644
		left, -- 644
		front, -- 644
		width, -- 644
		height, -- 644
		toColor(nearCol), -- 644
		toColor(farCol) -- 644
	) -- 644
	local bands = { -- 646
		0, -- 646
		0.3, -- 646
		0.58, -- 646
		0.81, -- 646
		1 -- 646
	} -- 646
	local jointDark = Color(14, 17, 22, 115) -- 647
	local jointHi = toColor(theme.groundRim, 36) -- 648
	local visLeft = math.max(left, -40) -- 649
	local visRight = math.min(right, cam.viewW + 40) -- 650
	do -- 650
		local row = 0 -- 651
		while row < #bands - 1 do -- 651
			local y0 = front + bands[row + 1] * height -- 652
			local y1 = front + bands[row + 1 + 1] * height -- 653
			local rowH = y1 - y0 -- 654
			local slabWidth = math.max( -- 655
				24, -- 655
				cam:len(84 - row * 10) -- 655
			) -- 655
			local offset = left - row % 2 * slabWidth * 0.5 -- 656
			local start = math.max( -- 657
				0, -- 657
				math.floor((visLeft - offset) / slabWidth) -- 657
			) -- 657
			do -- 657
				local col = start -- 658
				while offset + col * slabWidth < visRight do -- 658
					do -- 658
						local sx0 = math.max(left, offset + col * slabWidth) -- 659
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 660
						local sw = sx1 - sx0 -- 661
						if sw <= 2 then -- 661
							goto __continue72 -- 663
						end -- 663
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 665
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 666
						draw:drawRect( -- 667
							Rect( -- 667
								sx0 + 0.5, -- 667
								y0 + 0.5, -- 667
								sw - 1, -- 667
								math.max(1, rowH - 1) -- 667
							), -- 667
							toColor(stoneCol, 195) -- 667
						) -- 667
						draw:drawSegment( -- 668
							Vec2(sx0, y0), -- 668
							Vec2(sx0, y1), -- 668
							0.8, -- 668
							jointDark -- 668
						) -- 668
					end -- 668
					::__continue72:: -- 668
					col = col + 1 -- 658
				end -- 658
			end -- 658
			draw:drawSegment( -- 670
				Vec2(left, y0), -- 670
				Vec2(right, y0), -- 670
				0.9, -- 670
				jointDark -- 670
			) -- 670
			draw:drawSegment( -- 671
				Vec2(left, y0 + 1), -- 671
				Vec2(right, y0 + 1), -- 671
				0.6, -- 671
				jointHi -- 671
			) -- 671
			row = row + 1 -- 651
		end -- 651
	end -- 651
	draw:drawSegment( -- 674
		Vec2(left, front), -- 674
		Vec2(right, front), -- 674
		1.4, -- 674
		toColor(theme.groundRim, 135) -- 674
	) -- 674
	draw:drawSegment( -- 675
		Vec2(left, back), -- 675
		Vec2(right, back), -- 675
		1.3, -- 675
		toColor(theme.groundRim, 92) -- 675
	) -- 675
end -- 631
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 678
	local i = 0 -- 686
	do -- 686
		i = 0 -- 687
		while i < #p.room.stairs do -- 687
			local st = p.room.stairs[i + 1] -- 688
			local n = st.steps + 1 -- 689
			local stepW = (st.x1 - st.x0) / n -- 690
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 691
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 694
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 697
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 698
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 699
			local k = 0 -- 700
			do -- 700
				k = 0 -- 701
				while k < n do -- 701
					do -- 701
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 702
						local wx0 = st.x0 + stepW * k -- 703
						local wx1 = wx0 + stepW -- 704
						local x0 = cam:sx(wx0) -- 705
						local x1 = cam:sx(wx1) -- 706
						if x1 < 0 or x0 > cam.viewW then -- 706
							goto __continue78 -- 708
						end -- 708
						local y1 = cam:sy(wy, dMin) -- 710
						local y0 = cam:sy(baseWorldY, dMin) -- 711
						local yRear = cam:sy(wy, dMax) -- 712
						if yRear > y1 + 1 then -- 712
							fgDraw:drawRect( -- 714
								Rect(x0, y1, x1 - x0, yRear - y1), -- 714
								toColor( -- 714
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 714
									235 -- 714
								), -- 714
								0.7, -- 714
								toColor(theme.groundRim, 95) -- 714
							) -- 714
						end -- 714
						if y1 > y0 + 2 then -- 714
							fgDraw:drawRect( -- 717
								Rect(x0, y0, x1 - x0, y1 - y0), -- 717
								toColor(PALETTE.steelDark, 235) -- 717
							) -- 717
							fgDraw:drawRect( -- 718
								Rect(x0, y1 - 4, x1 - x0, 4), -- 718
								toColor(theme.groundTop) -- 718
							) -- 718
							assets:tryPlace( -- 719
								"wall", -- 719
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 719
								(x0 + x1) * 0.5, -- 719
								y0, -- 719
								x1 - x0, -- 720
								y1 - y0, -- 720
								{opacity = 0.76, layer = stairLayer} -- 720
							) -- 720
							assets:tryPlace( -- 721
								"slab", -- 721
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 721
								(x0 + x1) * 0.5, -- 721
								y1 - cam:len(4), -- 721
								x1 - x0, -- 722
								cam:len(4), -- 722
								{layer = stairLayer + 1} -- 722
							) -- 722
						end -- 722
						fgDraw:drawSegment( -- 724
							Vec2(x0, y1), -- 724
							Vec2(x1, y1), -- 724
							1.6, -- 724
							toColor(theme.groundRim) -- 724
						) -- 724
						fgGlow:drawSegment( -- 725
							Vec2(x0, y1 + 1), -- 725
							Vec2(x1, y1 + 1), -- 725
							0.9, -- 725
							toColor(theme.accent, 50) -- 725
						) -- 725
					end -- 725
					::__continue78:: -- 725
					k = k + 1 -- 701
				end -- 701
			end -- 701
			i = i + 1 -- 687
		end -- 687
	end -- 687
end -- 678
function StageRenderer.prototype.isSolidActive(self, p, s) -- 731
	local matched = false -- 732
	local anyVisible = false -- 733
	local i = 0 -- 734
	do -- 734
		i = 0 -- 735
		while i < #p.boxes do -- 735
			local b = p.boxes[i + 1] -- 736
			local sameId = s.id ~= nil and b.id == s.id -- 737
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 738
			if sameId or sameGeom then -- 738
				matched = true -- 742
				if b.broken ~= true and b.hidden ~= true then -- 742
					anyVisible = true -- 744
				end -- 744
			end -- 744
			i = i + 1 -- 735
		end -- 735
	end -- 735
	return not matched or anyVisible -- 748
end -- 731
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 751
	local i = 0 -- 762
	do -- 762
		i = 0 -- 763
		while i < #p.room.solids do -- 763
			do -- 763
				local s = p.room.solids[i + 1] -- 764
				if s.decorative == true then -- 764
					goto __continue89 -- 767
				end -- 767
				if not self:isSolidActive(p, s) then -- 767
					goto __continue89 -- 771
				end -- 771
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 771
					goto __continue89 -- 775
				end -- 775
				local x0 = cam:sx(s.x) -- 777
				local x1 = cam:sx(s.x + s.w) -- 778
				if p.room.depth ~= nil and s.depth ~= nil then -- 778
					local opacity = occlusion:update( -- 780
						"solid_" .. tostring(i), -- 780
						{ -- 780
							x0 = s.x, -- 781
							x1 = s.x + s.w, -- 781
							y0 = s.y, -- 781
							y1 = s.y + s.h, -- 781
							depth = s.depth, -- 782
							passThrough = s.passable == true or s.soft == true -- 782
						}, -- 782
						p, -- 783
						fadeDt -- 783
					) -- 783
					if x1 > 0 and x0 < cam.viewW then -- 783
						self:drawDepthSolid( -- 785
							fgDraw, -- 785
							assets, -- 785
							s, -- 785
							s.depth, -- 785
							x0, -- 785
							x1, -- 785
							cam, -- 785
							theme, -- 785
							opacity, -- 785
							p -- 785
						) -- 785
					end -- 785
					goto __continue89 -- 787
				end -- 787
				local y0 = cam:sy(s.y) -- 789
				local y1 = cam:sy(s.y + s.h) -- 790
				local sw = x1 - x0 -- 791
				local sh = y1 - y0 -- 792
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 792
					goto __continue89 -- 794
				end -- 794
				if p.room.key == "outside" and s.y > 10 then -- 794
					local groundY = cam:sy(0) -- 799
					local pierW = cam:len(16) -- 800
					fgDraw:drawRect( -- 801
						Rect(x0, groundY, pierW, y0 - groundY), -- 801
						Color(32, 37, 46, 215), -- 801
						0.9, -- 801
						Color(68, 76, 88, 140) -- 801
					) -- 801
					fgDraw:drawRect( -- 802
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 802
						Color(32, 37, 46, 215), -- 802
						0.9, -- 802
						Color(68, 76, 88, 140) -- 802
					) -- 802
				end -- 802
				if s.passable == true then -- 802
					if not assets:tryPlace( -- 802
						"grass", -- 807
						"hide_grass_" .. tostring(i), -- 807
						(x0 + x1) * 0.5, -- 807
						y0, -- 807
						sw, -- 807
						sh * 1.55, -- 807
						{opacity = 0.79, layer = 7} -- 808
					) then -- 808
						self:drawGrassCluster( -- 809
							fgDraw, -- 809
							fgGlow, -- 809
							x0, -- 809
							y0, -- 809
							sw, -- 809
							sh, -- 809
							p.player.x, -- 809
							s.x + s.w * 0.5, -- 809
							time -- 809
						) -- 809
					end -- 809
					goto __continue89 -- 811
				end -- 811
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 811
					self:drawWinch( -- 816
						fgDraw, -- 816
						assets, -- 816
						x0, -- 816
						y0, -- 816
						sw, -- 816
						sh, -- 816
						p, -- 816
						2 -- 816
					) -- 816
					goto __continue89 -- 817
				end -- 817
				if p.room.key == "tower" then -- 817
					self:drawTowerStructure( -- 822
						fgDraw, -- 822
						fgGlow, -- 822
						assets, -- 822
						x0, -- 822
						y0, -- 822
						sw, -- 822
						sh, -- 822
						s, -- 822
						p, -- 822
						time -- 822
					) -- 822
					goto __continue89 -- 823
				end -- 823
				if s.h <= 64 and s.y <= 2 then -- 823
					self:drawCoverBlock( -- 828
						fgDraw, -- 828
						fgGlow, -- 828
						assets, -- 828
						x0, -- 828
						y0, -- 828
						sw, -- 828
						sh, -- 828
						s, -- 828
						p, -- 828
						theme -- 828
					) -- 828
					goto __continue89 -- 829
				end -- 829
				fillVGradRect( -- 832
					fgDraw, -- 832
					x0, -- 832
					y0, -- 832
					sw, -- 832
					sh, -- 832
					toColor(PALETTE.steelDark), -- 832
					toColor(PALETTE.steelMid) -- 832
				) -- 832
				self:tileMasonry( -- 833
					assets, -- 833
					s, -- 833
					x0, -- 833
					y0, -- 833
					sw, -- 833
					sh -- 833
				) -- 833
			end -- 833
			::__continue89:: -- 833
			i = i + 1 -- 763
		end -- 763
	end -- 763
end -- 751
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 837
	local width = right - left -- 841
	local base = cam:sy(solid.y, depth.min) -- 842
	local rearBase = cam:sy(solid.y, depth.max) -- 843
	local top = cam:sy(solid.y + solid.h, depth.min) -- 844
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 845
	local frontH = top - base -- 846
	local slot = coverArt(solid) -- 847
	local layer = depthOrder(depth.min, 1) -- 848
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 849
	local capHeight = rear - top -- 850
	local center = (left + right) * 0.5 -- 851
	if solid.y <= 2 and rearBase > base + 1 then -- 851
		draw:drawRect( -- 855
			Rect(left, base, width, rearBase - base), -- 856
			Color( -- 857
				9, -- 857
				10, -- 857
				14, -- 857
				math.floor(86 * opacity + 0.5) -- 857
			), -- 857
			0.8, -- 858
			toColor( -- 859
				theme.groundRim, -- 859
				math.floor(58 * opacity + 0.5) -- 859
			) -- 859
		) -- 859
	end -- 859
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 859
		self:drawWinch( -- 865
			draw, -- 865
			assets, -- 865
			left, -- 865
			base, -- 865
			width, -- 865
			frontH, -- 865
			p, -- 865
			layer -- 865
		) -- 865
		return -- 866
	end -- 866
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 866
		assets:tryPlace( -- 870
			"slab", -- 870
			"gate_sill_" .. tostring(solid.x), -- 870
			center, -- 870
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 870
			width + cam:len(34), -- 871
			cam:len(12), -- 871
			{ -- 871
				layer = 1, -- 871
				color = Color(180, 169, 150, 255) -- 871
			} -- 871
		) -- 871
	end -- 871
	draw:drawEllipse( -- 873
		Vec2( -- 873
			center, -- 873
			base + cam:len(2) -- 873
		), -- 873
		width * 0.5, -- 873
		math.max( -- 874
			2, -- 874
			cam:len(2.5) -- 874
		), -- 874
		Color(10, 10, 14, 128 * opacity) -- 874
	) -- 874
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 876
	if slot ~= "fence" and capHeight > 1 then -- 876
		local capFill = occlusionTint( -- 880
			opacity, -- 880
			timber and Color( -- 880
				88, -- 881
				68, -- 881
				52, -- 881
				math.floor(240 * opacity + 0.5) -- 881
			) or Color( -- 881
				86, -- 882
				90, -- 882
				98, -- 882
				math.floor(240 * opacity + 0.5) -- 882
			) -- 882
		) -- 882
		local capEdge = occlusionTint( -- 883
			opacity, -- 883
			timber and Color( -- 883
				148, -- 884
				118, -- 884
				90, -- 884
				math.floor(185 * opacity + 0.5) -- 884
			) or Color( -- 884
				146, -- 885
				152, -- 885
				160, -- 885
				math.floor(175 * opacity + 0.5) -- 885
			) -- 885
		) -- 885
		draw:drawRect( -- 886
			Rect(left, top, width, capHeight), -- 886
			capFill, -- 886
			0.9, -- 886
			capEdge -- 886
		) -- 886
		draw:drawSegment( -- 887
			Vec2(left + 1, top + 0.5), -- 887
			Vec2(right - 1, top + 0.5), -- 887
			1.1, -- 887
			capEdge -- 887
		) -- 887
		if capHeight > 8 then -- 887
			local midY = top + capHeight * 0.5 -- 889
			draw:drawSegment( -- 890
				Vec2(left + 2, midY), -- 890
				Vec2(right - 2, midY), -- 890
				0.7, -- 890
				Color( -- 890
					24, -- 890
					22, -- 890
					22, -- 890
					math.floor(90 * opacity + 0.5) -- 890
				) -- 890
			) -- 890
		end -- 890
	end -- 890
	if timber and solid.h > solid.w * 1.6 then -- 890
		local colFill = occlusionTint( -- 896
			opacity, -- 896
			Color( -- 896
				66, -- 896
				48, -- 896
				36, -- 896
				math.floor(248 * opacity + 0.5) -- 896
			) -- 896
		) -- 896
		local colHi = occlusionTint( -- 897
			opacity, -- 897
			Color( -- 897
				122, -- 897
				92, -- 897
				68, -- 897
				math.floor(200 * opacity + 0.5) -- 897
			) -- 897
		) -- 897
		local colSh = occlusionTint( -- 898
			opacity, -- 898
			Color( -- 898
				34, -- 898
				24, -- 898
				18, -- 898
				math.floor(220 * opacity + 0.5) -- 898
			) -- 898
		) -- 898
		draw:drawRect( -- 899
			Rect(left, base, width, frontH), -- 899
			colFill, -- 899
			1, -- 899
			colHi -- 899
		) -- 899
		draw:drawRect( -- 900
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 900
			colSh -- 900
		) -- 900
		draw:drawSegment( -- 901
			Vec2(left + width * 0.32, base + 2), -- 901
			Vec2(left + width * 0.32, top - 2), -- 901
			0.9, -- 901
			colHi -- 901
		) -- 901
		return -- 902
	end -- 902
	if solid.w > solid.h * 5 then -- 902
		local beamFill = occlusionTint( -- 907
			opacity, -- 907
			Color( -- 907
				78, -- 907
				58, -- 907
				42, -- 907
				math.floor(248 * opacity + 0.5) -- 907
			) -- 907
		) -- 907
		local beamEdge = occlusionTint( -- 908
			opacity, -- 908
			Color( -- 908
				142, -- 908
				110, -- 908
				82, -- 908
				math.floor(215 * opacity + 0.5) -- 908
			) -- 908
		) -- 908
		draw:drawRect( -- 909
			Rect( -- 909
				left, -- 909
				base, -- 909
				width, -- 909
				math.max(4, frontH) -- 909
			), -- 909
			beamFill, -- 909
			1, -- 909
			beamEdge -- 909
		) -- 909
		local posts = math.max( -- 910
			2, -- 910
			math.floor(solid.w / 140 + 0.5) -- 910
		) -- 910
		do -- 910
			local pi = 0 -- 911
			while pi <= posts do -- 911
				local px = left + width * pi / posts -- 912
				draw:drawSegment( -- 913
					Vec2(px, base), -- 913
					Vec2(px, top), -- 913
					1.4, -- 913
					Color( -- 913
						34, -- 913
						24, -- 913
						18, -- 913
						math.floor(210 * opacity + 0.5) -- 913
					) -- 913
				) -- 913
				pi = pi + 1 -- 911
			end -- 911
		end -- 911
		return -- 915
	end -- 915
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 919
	local cols = slot == "wall" and math.max( -- 920
		1, -- 921
		math.min( -- 921
			10, -- 921
			math.floor(solid.w / 72 + 0.5) -- 921
		) -- 921
	) or math.max( -- 921
		1, -- 922
		math.min( -- 922
			10, -- 922
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 922
		) -- 922
	) -- 922
	local colW = width / cols -- 923
	local rows = slot == "wall" and math.max( -- 924
		1, -- 925
		math.min( -- 925
			10, -- 925
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 925
		) -- 925
	) or math.max( -- 925
		1, -- 926
		math.min( -- 926
			6, -- 926
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 926
		) -- 926
	) -- 926
	local rowHeight = frontH / rows -- 927
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 928
	local color = occlusionTint(opacity, masonryColor) -- 929
	local placedAny = false -- 930
	do -- 930
		local row = 0 -- 931
		while row < rows do -- 931
			do -- 931
				local col = 0 -- 932
				while col < cols do -- 932
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 933
					if assets:tryPlace( -- 933
						slot, -- 934
						tileKey, -- 934
						left + (col + 0.5) * colW, -- 934
						base + row * rowHeight, -- 934
						colW + 0.5, -- 934
						rowHeight + 0.5, -- 934
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 934
					) then -- 934
						placedAny = true -- 937
					end -- 937
					col = col + 1 -- 932
				end -- 932
			end -- 932
			row = row + 1 -- 931
		end -- 931
	end -- 931
	if not placedAny then -- 931
		draw:drawRect( -- 942
			Rect(left, base, width, frontH), -- 942
			occlusionTint( -- 943
				opacity, -- 943
				toColor(PALETTE.steelMid, 255 * opacity) -- 943
			), -- 943
			1, -- 944
			toColor(theme.groundRim, 150 * opacity) -- 944
		) -- 944
	end -- 944
end -- 837
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 948
	local columns = math.max( -- 953
		1, -- 953
		math.min( -- 953
			10, -- 953
			math.floor(s.w / 58 + 0.5) -- 953
		) -- 953
	) -- 953
	local cellWorldW = s.w / columns -- 954
	local targetCellH = math.max( -- 955
		24, -- 955
		math.min(48, cellWorldW / 1.52) -- 955
	) -- 955
	local rows = math.max( -- 956
		1, -- 956
		math.min( -- 956
			12, -- 956
			math.floor(s.h / targetCellH + 0.5) -- 956
		) -- 956
	) -- 956
	local tileW = width / columns -- 957
	local tileH = height / rows -- 958
	do -- 958
		local row = 0 -- 959
		while row < rows do -- 959
			do -- 959
				local column = 0 -- 960
				while column < columns do -- 960
					assets:tryPlace( -- 961
						"wall", -- 961
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 961
						x + (column + 0.5) * tileW, -- 962
						y + row * tileH, -- 962
						tileW + 0.5, -- 962
						tileH + 0.5, -- 962
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 963
					) -- 963
					column = column + 1 -- 960
				end -- 960
			end -- 960
			row = row + 1 -- 959
		end -- 959
	end -- 959
end -- 948
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 968
	local slot = coverArt(s) -- 975
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 976
	local cols = math.max( -- 977
		1, -- 977
		math.min( -- 977
			8, -- 977
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 977
		) -- 977
	) -- 977
	local tileW = sw / cols -- 978
	local placed = false -- 979
	do -- 979
		local c = 0 -- 980
		while c < cols do -- 980
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 981
			if assets:tryPlace( -- 981
				slot, -- 982
				k, -- 982
				x0 + (c + 0.5) * tileW, -- 982
				y0, -- 982
				tileW + 0.5, -- 982
				sh, -- 982
				{layer = 1} -- 982
			) then -- 982
				placed = true -- 983
			end -- 983
			c = c + 1 -- 980
		end -- 980
	end -- 980
	if not placed then -- 980
		fillVGradRect( -- 987
			fgDraw, -- 987
			x0, -- 987
			y0, -- 987
			sw, -- 987
			sh, -- 987
			toColor(PALETTE.steelDark), -- 987
			toColor(PALETTE.steelMid) -- 987
		) -- 987
		fgDraw:drawSegment( -- 988
			Vec2(x0, y0 + sh), -- 988
			Vec2(x0 + sw, y0 + sh), -- 988
			1.4, -- 988
			toColor(theme.groundRim) -- 988
		) -- 988
	end -- 988
	if not p.childMode and (p.coverHug or p.coverNear) then -- 988
		local plx = p.player.x -- 993
		local nearLeft = math.abs(plx - s.x) < 42 -- 994
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 995
		if nearLeft or nearRight then -- 995
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 997
			local isWood = slot == "cover_wood" -- 998
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 999
			fgDraw:drawSegment( -- 1000
				Vec2(edgeX, y0 + 4), -- 1000
				Vec2(edgeX, y0 + sh + 2), -- 1000
				p.coverHug and 2 or 1.2, -- 1000
				toColor(col, p.coverHug and 205 or 120) -- 1000
			) -- 1000
		end -- 1000
	end -- 1000
end -- 968
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 1005
	if layer == nil then -- 1005
		layer = 2 -- 1010
	end -- 1010
	local cx = x0 + sw * 0.5 -- 1012
	local cy = y0 + sh * 0.55 -- 1013
	local ropeWidth = math.max(1, sw * 0.023) -- 1014
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 1015
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 1016
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 1017
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 1018
	draw:drawEllipse( -- 1019
		Vec2(cx, y0), -- 1019
		sw * 0.53, -- 1019
		sh * 0.07, -- 1019
		Color(10, 8, 9, 150) -- 1019
	) -- 1019
	draw:drawSegment( -- 1020
		drum, -- 1020
		bend, -- 1020
		ropeWidth, -- 1020
		Color(111, 86, 57, 239) -- 1020
	) -- 1020
	draw:drawSegment( -- 1021
		bend, -- 1021
		ropeTop, -- 1021
		ropeWidth, -- 1021
		Color(111, 86, 57, 239) -- 1021
	) -- 1021
	if assets:tryPlace( -- 1021
		"prop_winch", -- 1022
		"gate_winch", -- 1022
		cx, -- 1022
		y0 + sh * 0.5, -- 1022
		sw, -- 1022
		sh, -- 1022
		{layer = layer} -- 1022
	) then -- 1022
		return -- 1023
	end -- 1023
	local timber = Color(75, 51, 34, 255) -- 1025
	draw:drawSegment( -- 1026
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 1026
		Vec2(cx, y0 + sh * 0.86), -- 1026
		sw * 0.06, -- 1026
		timber -- 1026
	) -- 1026
	draw:drawSegment( -- 1027
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 1027
		Vec2(cx, y0 + sh * 0.86), -- 1027
		sw * 0.06, -- 1027
		timber -- 1027
	) -- 1027
	draw:drawRect( -- 1028
		Rect(x0, y0, sw, sh * 0.12), -- 1028
		timber -- 1028
	) -- 1028
	local radius = math.min(sw, sh) * 0.21 -- 1029
	draw:drawCircle( -- 1030
		Vec2(cx, cy), -- 1030
		radius, -- 1030
		Color(48, 41, 37, 255) -- 1030
	) -- 1030
	do -- 1030
		local i = -2 -- 1031
		while i <= 2 do -- 1031
			local x = cx + i * radius * 0.28 -- 1032
			draw:drawSegment( -- 1033
				Vec2(x, cy - radius * 0.62), -- 1033
				Vec2(x, cy + radius * 0.62), -- 1033
				ropeWidth, -- 1033
				Color(135, 103, 68, 240) -- 1034
			) -- 1034
			i = i + 1 -- 1031
		end -- 1031
	end -- 1031
end -- 1005
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 1038
	local ____temp_3 -- 1046
	if p.room.story ~= nil then -- 1046
		____temp_3 = p.room.story.gate -- 1046
	else -- 1046
		____temp_3 = nil -- 1046
	end -- 1046
	local g = ____temp_3 -- 1046
	if g == nil then -- 1046
		return -- 1048
	end -- 1048
	local closeFrac = 0.08 -- 1051
	if p.phase == "gate-hold" then -- 1051
		closeFrac = 0.08 + 0.36 * math.min( -- 1053
			1, -- 1053
			p.gateTick / math.max(1, g.holdTicks) -- 1053
		) -- 1053
	elseif p.phase == "gate-send" then -- 1053
		closeFrac = 0.44 -- 1055
	elseif p.phase == "gate-count" then -- 1055
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 1057
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 1057
		closeFrac = 1 -- 1059
	end -- 1059
	local gx0 = cam:sx(848) -- 1061
	local gx1 = cam:sx(1032) -- 1062
	local topY = cam:sy(160) -- 1063
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1064
	local shutterW = gx1 - gx0 -- 1065
	local shutterH = topY - botY -- 1066
	if shutterH > 2 then -- 1066
		fillVGradRect( -- 1068
			fgDraw, -- 1068
			gx0, -- 1068
			botY, -- 1068
			shutterW, -- 1068
			shutterH, -- 1068
			toColor(PALETTE.steelDark), -- 1068
			toColor(PALETTE.steelMid) -- 1068
		) -- 1068
		local rows = math.max( -- 1070
			1, -- 1070
			math.min( -- 1070
				6, -- 1070
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1070
			) -- 1070
		) -- 1070
		local rowH = shutterH / rows -- 1071
		do -- 1071
			local r = 0 -- 1072
			while r < rows do -- 1072
				assets:tryPlace( -- 1073
					"cover_wood", -- 1073
					"gate_shutter_" .. tostring(r), -- 1073
					(gx0 + gx1) * 0.5, -- 1073
					botY + r * rowH, -- 1073
					shutterW, -- 1074
					rowH + 0.5, -- 1074
					{layer = 6} -- 1074
				) -- 1074
				r = r + 1 -- 1072
			end -- 1072
		end -- 1072
	end -- 1072
	if closeFrac < 0.98 then -- 1072
		local gapH = math.max( -- 1079
			8, -- 1079
			botY - cam:sy(0) -- 1079
		) -- 1079
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1080
		fillVGradRect( -- 1081
			fgGlow, -- 1081
			gx0, -- 1081
			cam:sy(0), -- 1081
			gx1 - gx0, -- 1081
			gapH, -- 1081
			Color( -- 1081
				140, -- 1081
				210, -- 1081
				255, -- 1081
				math.floor(52 * pulse + 0.5) -- 1081
			), -- 1081
			Color(80, 160, 230, 0) -- 1081
		) -- 1081
	end -- 1081
end -- 1038
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, time) -- 1085
	fillVGradRect( -- 1092
		fgDraw, -- 1092
		x0, -- 1092
		y0, -- 1092
		sw, -- 1092
		sh, -- 1092
		Color(15, 21, 34, 255), -- 1092
		Color(32, 44, 66, 255) -- 1092
	) -- 1092
	fgDraw:drawRect( -- 1093
		Rect(x0, y0, sw, sh), -- 1093
		Color(0, 0, 0, 0), -- 1093
		1.4, -- 1093
		toColor(PALETTE.rimSilver, 165) -- 1093
	) -- 1093
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1093
		self:tileMasonry( -- 1096
			assets, -- 1096
			s, -- 1096
			x0, -- 1096
			y0, -- 1096
			sw, -- 1096
			sh -- 1096
		) -- 1096
		local ribs = 4 -- 1098
		local r = 1 -- 1099
		do -- 1099
			r = 1 -- 1100
			while r < ribs do -- 1100
				local rx = x0 + sw * r / ribs -- 1101
				fgDraw:drawSegment( -- 1102
					Vec2(rx, y0), -- 1102
					Vec2(rx, y0 + sh), -- 1102
					2, -- 1102
					Color(10, 15, 24, 210) -- 1102
				) -- 1102
				fgDraw:drawSegment( -- 1103
					Vec2(rx + 2, y0), -- 1103
					Vec2(rx + 2, y0 + sh), -- 1103
					1, -- 1103
					Color(68, 86, 114, 130) -- 1103
				) -- 1103
				r = r + 1 -- 1100
			end -- 1100
		end -- 1100
		local bands = 4 -- 1106
		local b = 1 -- 1107
		do -- 1107
			b = 1 -- 1108
			while b < bands do -- 1108
				local by = y0 + sh * b / bands -- 1109
				fgDraw:drawSegment( -- 1110
					Vec2(x0 + 4, by), -- 1110
					Vec2(x0 + sw - 4, by), -- 1110
					1.2, -- 1110
					Color(52, 68, 92, 135) -- 1110
				) -- 1110
				b = b + 1 -- 1108
			end -- 1108
		end -- 1108
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1113
		local slitY = y0 + sh * 0.56 -- 1114
		local slitH = sh * 0.22 -- 1115
		fgDraw:drawRect( -- 1116
			Rect(slitX - 5, slitY, 10, slitH), -- 1116
			Color(8, 12, 20, 245), -- 1116
			1.2, -- 1116
			toColor(PALETTE.amberDim, 190) -- 1116
		) -- 1116
		fgGlow:drawRect( -- 1117
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1117
			toColor(PALETTE.amber, 190) -- 1117
		) -- 1117
		fillRadialGlow( -- 1118
			fgGlow, -- 1118
			slitX, -- 1118
			slitY + slitH * 0.5, -- 1118
			44, -- 1118
			slitH * 0.7, -- 1118
			Color(255, 206, 128, 52), -- 1118
			Color(255, 180, 86, 0), -- 1118
			14 -- 1118
		) -- 1118
	end -- 1118
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1118
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 1123
		local cx = x0 + sw * 0.5 -- 1124
		local lampY = y0 - 8 -- 1125
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1126
		if not opened then -- 1126
			assets:tryPlace( -- 1128
				"prop_tower_door", -- 1128
				"tower_door", -- 1128
				cx, -- 1128
				y0 - doorHeight, -- 1128
				sw, -- 1128
				doorHeight, -- 1128
				{layer = 2} -- 1128
			) -- 1128
		end -- 1128
		assets:tryPlace( -- 1130
			"prop_lantern", -- 1130
			"tower_lantern", -- 1130
			cx + sw * 0.43, -- 1130
			lampY - sh * 0.36, -- 1130
			sw * 0.17, -- 1131
			sh * 0.84, -- 1131
			{layer = 3} -- 1131
		) -- 1131
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1132
		local alpha = opened and 155 or 88 -- 1133
		fgDraw:drawSegment( -- 1135
			Vec2(x0 + 4, y0), -- 1135
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1135
			4, -- 1135
			Color(42, 52, 70, 255) -- 1135
		) -- 1135
		fgDraw:drawSegment( -- 1136
			Vec2(x0 + sw - 4, y0), -- 1136
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1136
			4, -- 1136
			Color(42, 52, 70, 255) -- 1136
		) -- 1136
		fgDraw:drawSegment( -- 1137
			Vec2(x0, y0), -- 1137
			Vec2(x0 + sw, y0), -- 1137
			2.5, -- 1137
			toColor(PALETTE.amber, 210) -- 1137
		) -- 1137
		fillVGradRect( -- 1139
			fgGlow, -- 1140
			x0 + 6, -- 1141
			y0 - sh * 3.8, -- 1142
			sw - 12, -- 1143
			sh * 3.8, -- 1144
			Color( -- 1145
				255, -- 1145
				206, -- 1145
				128, -- 1145
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 1145
			), -- 1145
			Color(255, 224, 168, opened and 180 or 62) -- 1146
		) -- 1146
		fillRadialGlow( -- 1148
			fgGlow, -- 1148
			cx, -- 1148
			lampY, -- 1148
			opened and 105 or 58, -- 1148
			opened and 105 or 58, -- 1148
			Color( -- 1148
				255, -- 1148
				232, -- 1148
				178, -- 1148
				math.floor(170 * pulse + 0.5) -- 1148
			), -- 1148
			Color(255, 180, 86, 0), -- 1148
			18 -- 1148
		) -- 1148
		fgDraw:drawCircle( -- 1149
			Vec2(cx, lampY), -- 1149
			5.5, -- 1149
			toColor(PALETTE.amberCore) -- 1149
		) -- 1149
	end -- 1149
end -- 1085
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
	if nearPlayer then -- 1163
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
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1186
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
	if not p.cartDocked then -- 1211
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1218
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1219
		if bx1 > bx0 + 4 then -- 1219
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