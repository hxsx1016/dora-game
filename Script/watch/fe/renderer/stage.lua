-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____theme = require("Script.watch.fe.theme") -- 14
local PALETTE = ____theme.PALETTE -- 15
local drawHazardStripes = ____theme.drawHazardStripes -- 17
local fillChamferBox = ____theme.fillChamferBox -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 20
local fillVGradRect = ____theme.fillVGradRect -- 21
local themeOf = ____theme.themeOf -- 23
local toColor = ____theme.toColor -- 24
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 28
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 29
	return x - math.floor(x) -- 30
end -- 28
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 34
	local h = 17 -- 35
	local i = 0 -- 36
	do -- 36
		i = 0 -- 37
		while i < #key do -- 37
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 38
			i = i + 1 -- 37
		end -- 37
	end -- 37
	return h -- 40
end -- 34
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
	local splitY = h * 0.46 -- 59
	fillVGradRect( -- 60
		bgDraw, -- 60
		0, -- 60
		splitY, -- 60
		w, -- 60
		h - splitY, -- 60
		toColor(theme.skyMid), -- 60
		toColor(theme.skyTop) -- 60
	) -- 60
	fillVGradRect( -- 61
		bgDraw, -- 61
		0, -- 61
		0, -- 61
		w, -- 61
		splitY, -- 61
		toColor(theme.skyHorizon), -- 61
		toColor(theme.skyMid) -- 61
	) -- 61
	if theme.showMoon then -- 61
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 65
		local my = h * theme.moonYFrac -- 66
		local mr = math.max(18, h * 0.044) -- 67
		fillRadialGlow( -- 68
			bgGlow, -- 68
			mx, -- 68
			my, -- 68
			mr * 6.2, -- 68
			mr * 6.2, -- 68
			Color(140, 200, 255, 28), -- 68
			Color(20, 40, 80, 0), -- 68
			22 -- 68
		) -- 68
		fillRadialGlow( -- 69
			bgGlow, -- 69
			mx, -- 69
			my, -- 69
			mr * 2.4, -- 69
			mr * 2.4, -- 69
			Color(200, 232, 255, 64), -- 69
			Color(80, 140, 210, 0), -- 69
			18 -- 69
		) -- 69
		bgDraw:drawCircle( -- 70
			Vec2(mx, my), -- 70
			mr, -- 70
			Color(224, 238, 252, 230) -- 70
		) -- 70
		bgDraw:drawCircle( -- 72
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 72
			mr * 0.84, -- 72
			toColor(theme.skyTop, 110) -- 72
		) -- 72
	end -- 72
	local farSlot = "bgFar_" .. p.room.key -- 76
	local hasFarArt = assets:tryPlace( -- 77
		farSlot, -- 77
		"stage_far_" .. p.room.key, -- 77
		w * 0.5, -- 77
		0, -- 77
		w, -- 77
		h, -- 77
		1, -- 77
		1 -- 77
	) -- 77
	if not hasFarArt then -- 77
		if theme.showSearchlights then -- 77
			self:drawSearchlights( -- 82
				bgGlow, -- 82
				w, -- 82
				h, -- 82
				cam, -- 82
				theme, -- 82
				time, -- 82
				seed -- 82
			) -- 82
		end -- 82
		if p.room.key == "forest" then -- 82
			self:drawFarForest( -- 87
				bgDraw, -- 87
				w, -- 87
				h, -- 87
				cam, -- 87
				theme, -- 87
				seed -- 87
			) -- 87
		else -- 87
			self:drawFarCity( -- 89
				bgDraw, -- 89
				bgGlow, -- 89
				w, -- 89
				h, -- 89
				cam, -- 89
				theme, -- 89
				seed -- 89
			) -- 89
		end -- 89
		if theme.showTowerBeacon then -- 89
			self:drawDistantNorthTower( -- 94
				bgDraw, -- 94
				bgGlow, -- 94
				w, -- 94
				h, -- 94
				cam, -- 94
				p, -- 94
				time -- 94
			) -- 94
		end -- 94
	end -- 94
	local midSlot = "bgMid_" .. p.room.key -- 99
	local hasMidArt = assets:tryPlace( -- 100
		midSlot, -- 100
		"stage_mid_" .. p.room.key, -- 100
		w * 0.5, -- 100
		0, -- 100
		w, -- 100
		h, -- 100
		1, -- 100
		1 -- 100
	) -- 100
	if not hasMidArt then -- 100
		if p.room.key == "forest" then -- 100
			self:drawMidForest( -- 103
				bgDraw, -- 103
				bgGlow, -- 103
				w, -- 103
				h, -- 103
				cam, -- 103
				theme, -- 103
				time, -- 103
				seed -- 103
			) -- 103
		else -- 103
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
	end -- 105
	local fogH = h * 0.38 -- 110
	fillVGradRect( -- 111
		bgGlow, -- 112
		0, -- 113
		cam.groundScreenY - 10, -- 114
		w, -- 115
		fogH, -- 116
		toColor(theme.fogBottom), -- 117
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 118
	) -- 118
end -- 45
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 123
	local theme = themeOf("checkpoint") -- 130
	local splitY = h * 0.44 -- 131
	fillVGradRect( -- 132
		bgDraw, -- 132
		0, -- 132
		splitY, -- 132
		w, -- 132
		h - splitY, -- 132
		toColor(theme.skyMid), -- 132
		toColor(theme.skyTop) -- 132
	) -- 132
	fillVGradRect( -- 133
		bgDraw, -- 133
		0, -- 133
		0, -- 133
		w, -- 133
		splitY, -- 133
		toColor(theme.skyHorizon), -- 133
		toColor(theme.skyMid) -- 133
	) -- 133
	local mx = w * 0.61 -- 136
	local my = h * 0.74 -- 137
	local mr = h * 0.082 -- 138
	fillRadialGlow( -- 139
		bgGlow, -- 139
		mx, -- 139
		my, -- 139
		mr * 5.2, -- 139
		mr * 5.2, -- 139
		Color(86, 210, 255, 34), -- 139
		Color(10, 24, 52, 0), -- 139
		24 -- 139
	) -- 139
	fillRadialGlow( -- 140
		bgGlow, -- 140
		mx, -- 140
		my, -- 140
		mr * 2.1, -- 140
		mr * 2.1, -- 140
		Color(190, 240, 255, 76), -- 140
		Color(40, 120, 190, 0), -- 140
		20 -- 140
	) -- 140
	bgDraw:drawCircle( -- 141
		Vec2(mx, my), -- 141
		mr, -- 141
		Color(228, 242, 255, 235) -- 141
	) -- 141
	bgDraw:drawCircle( -- 142
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 142
		mr * 0.86, -- 142
		Color(10, 18, 34, 125) -- 142
	) -- 142
	local s = 0 -- 145
	do -- 145
		s = 0 -- 146
		while s < 3 do -- 146
			local bx = w * (0.36 + s * 0.24) -- 147
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 148
			local ang = math.pi * 0.5 + sway - 0.12 -- 149
			local len = h * 1.15 -- 150
			local spread = 0.085 + s * 0.015 -- 151
			local x1 = bx + math.cos(ang - spread) * len -- 152
			local y1 = math.sin(ang - spread) * len -- 153
			local x2 = bx + math.cos(ang + spread) * len -- 154
			local y2 = math.sin(ang + spread) * len -- 155
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 156
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 157
			bgGlow:drawVertices({ -- 158
				{ -- 159
					Vec2(bx, h * 0.15), -- 159
					baseCol -- 159
				}, -- 159
				{ -- 160
					Vec2(x1, y1), -- 160
					tipCol -- 160
				}, -- 160
				{ -- 161
					Vec2(x2, y2), -- 161
					tipCol -- 161
				} -- 161
			}) -- 161
			s = s + 1 -- 146
		end -- 146
	end -- 146
	local groundY = h * 0.19 -- 166
	local i = 0 -- 167
	do -- 167
		i = 0 -- 168
		while i < 16 do -- 168
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 169
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 170
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 171
			local cut = 12 + hash01(i * 19) * 20 -- 172
			bgDraw:drawPolygon( -- 173
				{ -- 173
					Vec2(bx, groundY), -- 174
					Vec2(bx + bw, groundY), -- 175
					Vec2(bx + bw, groundY + bh - cut), -- 176
					Vec2(bx + bw - cut, groundY + bh), -- 177
					Vec2(bx, groundY + bh) -- 178
				}, -- 178
				Color(10, 16, 28, 255) -- 179
			) -- 179
			if hash01(i * 41 + 5) > 0.45 then -- 179
				local wy = groundY + bh * 0.65 -- 182
				bgGlow:drawSegment( -- 183
					Vec2(bx + 10, wy), -- 183
					Vec2(bx + bw - 14, wy), -- 183
					1.2, -- 183
					Color(72, 224, 255, 95) -- 183
				) -- 183
			end -- 183
			i = i + 1 -- 168
		end -- 168
	end -- 168
	local tx = w * 0.83 -- 188
	local ty0 = groundY -- 189
	local ty1 = h * 0.62 -- 190
	bgDraw:drawPolygon( -- 191
		{ -- 191
			Vec2(tx - 26, ty0), -- 192
			Vec2(tx + 26, ty0), -- 193
			Vec2(tx + 11, ty1), -- 194
			Vec2(tx - 11, ty1) -- 195
		}, -- 195
		Color(15, 24, 40, 255), -- 196
		1.2, -- 196
		Color(58, 86, 118, 140) -- 196
	) -- 196
	bgDraw:drawSegment( -- 197
		Vec2(tx, ty0 + 24), -- 197
		Vec2(tx, ty1 - 12), -- 197
		1.4, -- 197
		Color(242, 188, 96, 85) -- 197
	) -- 197
	bgDraw:drawSegment( -- 198
		Vec2(tx, ty1), -- 198
		Vec2(tx, ty1 + 42), -- 198
		2.2, -- 198
		Color(165, 212, 248, 210) -- 198
	) -- 198
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 199
	fillRadialGlow( -- 200
		bgGlow, -- 200
		tx, -- 200
		ty1 + 42, -- 200
		74 * pulse, -- 200
		74 * pulse, -- 200
		Color(255, 222, 146, 130), -- 200
		Color(255, 180, 90, 0), -- 200
		20 -- 200
	) -- 200
	bgGlow:drawDot( -- 201
		Vec2(tx, ty1 + 42), -- 201
		5, -- 201
		Color(255, 248, 224, 255) -- 201
	) -- 201
	fillVGradRect( -- 204
		bgDraw, -- 204
		0, -- 204
		0, -- 204
		w, -- 204
		groundY, -- 204
		Color(6, 9, 16, 255), -- 204
		Color(16, 24, 38, 255) -- 204
	) -- 204
	bgDraw:drawSegment( -- 205
		Vec2(0, groundY), -- 205
		Vec2(w, groundY), -- 205
		2, -- 205
		Color(76, 220, 255, 180) -- 205
	) -- 205
	fillVGradRect( -- 206
		bgGlow, -- 206
		0, -- 206
		groundY, -- 206
		w, -- 206
		h * 0.24, -- 206
		Color(42, 130, 182, 52), -- 206
		Color(20, 60, 100, 0) -- 206
	) -- 206
	local sx = w * 0.64 -- 209
	fillRadialGlow( -- 210
		bgGlow, -- 210
		sx + 38, -- 210
		groundY + 75, -- 210
		128, -- 210
		92, -- 210
		Color(52, 178, 232, 42), -- 210
		Color(20, 60, 110, 0), -- 210
		18 -- 210
	) -- 210
	bgDraw:drawPolygon( -- 212
		{ -- 212
			Vec2(sx - 36, groundY + 12), -- 213
			Vec2(sx + 10, groundY + 18), -- 214
			Vec2(sx + 16, groundY + 124), -- 215
			Vec2(sx - 18, groundY + 124) -- 216
		}, -- 216
		Color(10, 16, 28, 255), -- 217
		1.3, -- 217
		Color(76, 210, 255, 145) -- 217
	) -- 217
	bgDraw:drawSegment( -- 218
		Vec2(sx - 6, groundY + 48), -- 218
		Vec2(sx - 12, groundY + 2), -- 218
		6, -- 218
		Color(10, 16, 28, 255) -- 218
	) -- 218
	bgDraw:drawSegment( -- 219
		Vec2(sx + 6, groundY + 48), -- 219
		Vec2(sx + 14, groundY + 2), -- 219
		6, -- 219
		Color(14, 22, 36, 255) -- 219
	) -- 219
	bgDraw:drawPolygon( -- 220
		{ -- 220
			Vec2(sx - 20, groundY + 120), -- 221
			Vec2(sx + 20, groundY + 122), -- 222
			Vec2(sx + 16, groundY + 132), -- 223
			Vec2(sx - 16, groundY + 130) -- 224
		}, -- 224
		Color(208, 236, 252, 240) -- 225
	) -- 225
	bgDraw:drawCircle( -- 226
		Vec2(sx + 2, groundY + 146), -- 226
		13, -- 226
		Color(14, 22, 36, 255) -- 226
	) -- 226
	bgDraw:drawArc( -- 227
		Vec2(sx + 2, groundY + 146), -- 227
		13.5, -- 227
		30, -- 227
		165, -- 227
		2, -- 227
		Color(216, 240, 255, 230) -- 227
	) -- 227
	bgGlow:drawSegment( -- 228
		Vec2(sx + 4, groundY + 148), -- 228
		Vec2(sx + 17, groundY + 150), -- 228
		2.6, -- 228
		Color(86, 240, 255, 255) -- 228
	) -- 228
	bgDraw:drawSegment( -- 229
		Vec2(sx + 4, groundY + 104), -- 229
		Vec2(sx + 46, groundY + 94), -- 229
		3.4, -- 229
		Color(34, 52, 74, 255) -- 229
	) -- 229
	bgGlow:drawSegment( -- 230
		Vec2(sx + 16, groundY + 102), -- 230
		Vec2(sx + 44, groundY + 95), -- 230
		1.2, -- 230
		Color(86, 236, 255, 200) -- 230
	) -- 230
	local cx = w * 0.725 -- 233
	bgDraw:drawPolygon( -- 234
		{ -- 234
			Vec2(cx - 20, groundY + 14), -- 235
			Vec2(cx + 18, groundY + 14), -- 236
			Vec2(cx + 12, groundY + 84), -- 237
			Vec2(cx - 12, groundY + 84) -- 238
		}, -- 238
		Color(188, 142, 78, 238), -- 239
		1.4, -- 239
		Color(252, 232, 192, 225) -- 239
	) -- 239
	bgDraw:drawSegment( -- 240
		Vec2(cx - 5, groundY + 24), -- 240
		Vec2(cx - 6, groundY + 2), -- 240
		4.2, -- 240
		Color(28, 24, 30, 255) -- 240
	) -- 240
	bgDraw:drawSegment( -- 241
		Vec2(cx + 5, groundY + 24), -- 241
		Vec2(cx + 6, groundY + 2), -- 241
		4.2, -- 241
		Color(38, 32, 38, 255) -- 241
	) -- 241
	bgDraw:drawCircle( -- 242
		Vec2(cx + 1, groundY + 95), -- 242
		11, -- 242
		Color(238, 220, 194, 250) -- 242
	) -- 242
	bgDraw:drawPolygon( -- 243
		{ -- 243
			Vec2(cx - 15, groundY + 84), -- 244
			Vec2(cx - 10, groundY + 108), -- 245
			Vec2(cx + 6, groundY + 107), -- 246
			Vec2(cx - 4, groundY + 84) -- 247
		}, -- 247
		Color(156, 114, 62, 245) -- 248
	) -- 248
	bgGlow:drawSegment( -- 249
		Vec2(cx - 8, groundY + 82), -- 249
		Vec2(cx - 30, groundY + 64), -- 249
		2.8, -- 249
		Color(252, 230, 178, 220) -- 249
	) -- 249
	fillRadialGlow( -- 250
		bgGlow, -- 250
		cx + 10, -- 250
		groundY + 56, -- 250
		30, -- 250
		30, -- 250
		Color(255, 214, 130, 115), -- 250
		Color(250, 180, 70, 0), -- 250
		16 -- 250
	) -- 250
	bgGlow:drawDot( -- 251
		Vec2(cx + 10, groundY + 56), -- 251
		3.2, -- 251
		Color(255, 246, 220, 255) -- 251
	) -- 251
end -- 123
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, p, cam, time) -- 255
	local theme = themeOf(p.room.key) -- 262
	self:drawFloors( -- 265
		fgDraw, -- 265
		fgGlow, -- 265
		p, -- 265
		cam, -- 265
		theme -- 265
	) -- 265
	self:drawStairs( -- 268
		fgDraw, -- 268
		fgGlow, -- 268
		p, -- 268
		cam, -- 268
		theme -- 268
	) -- 268
	self:drawSolids( -- 271
		fgDraw, -- 271
		fgGlow, -- 271
		p, -- 271
		cam, -- 271
		theme, -- 271
		time -- 271
	) -- 271
	if p.room.key == "gate" then -- 271
		self:drawGateShutter( -- 275
			fgDraw, -- 275
			fgGlow, -- 275
			p, -- 275
			cam, -- 275
			time -- 275
		) -- 275
	end -- 275
	self:drawArch( -- 279
		fgDraw, -- 279
		fgGlow, -- 279
		p, -- 279
		cam, -- 279
		theme -- 279
	) -- 279
end -- 255
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 283
	local seed = roomSeed(p.room.key) -- 290
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 292
	local span = 520 -- 293
	local startIdx = math.floor((-parallax - 200) / span) -- 294
	local idx = startIdx -- 295
	do -- 295
		idx = startIdx -- 296
		while idx <= startIdx + 4 do -- 296
			local x = idx * span + parallax -- 297
			local r = hash01(seed + idx * 17) -- 298
			local bw = 70 + r * 90 -- 299
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 300
			fgDraw:drawPolygon( -- 301
				{ -- 301
					Vec2(x, 0), -- 302
					Vec2(x + bw, 0), -- 303
					Vec2(x + bw - 18, bh), -- 304
					Vec2(x + 12, bh * 0.72) -- 305
				}, -- 305
				Color(4, 6, 11, 225) -- 306
			) -- 306
			idx = idx + 1 -- 296
		end -- 296
	end -- 296
	fillVGradRect( -- 310
		fgDraw, -- 310
		0, -- 310
		h - h * 0.16, -- 310
		w, -- 310
		h * 0.16, -- 310
		Color(4, 6, 12, 0), -- 310
		Color(4, 6, 12, 138) -- 310
	) -- 310
	fillVGradRect( -- 311
		fgDraw, -- 311
		0, -- 311
		0, -- 311
		w, -- 311
		h * 0.13, -- 311
		Color(4, 6, 12, 185), -- 311
		Color(4, 6, 12, 0) -- 311
	) -- 311
end -- 283
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 314
	local count = 3 -- 323
	local i = 0 -- 324
	do -- 324
		i = 0 -- 325
		while i < count do -- 325
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 326
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 327
			local by = cam.groundScreenY * 0.85 -- 328
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 329
			local ang = math.pi * 0.5 + sway -- 330
			local len = h * 1.15 -- 331
			local halfSpread = 0.065 + i % 2 * 0.025 -- 332
			local x1 = bx + math.cos(ang - halfSpread) * len -- 333
			local y1 = by + math.sin(ang - halfSpread) * len -- 334
			local x2 = bx + math.cos(ang + halfSpread) * len -- 335
			local y2 = by + math.sin(ang + halfSpread) * len -- 336
			local c0 = toColor(theme.beamColor) -- 337
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 338
			bgGlow:drawVertices({ -- 339
				{ -- 340
					Vec2(bx, by), -- 340
					c0 -- 340
				}, -- 340
				{ -- 341
					Vec2(x1, y1), -- 341
					c1 -- 341
				}, -- 341
				{ -- 342
					Vec2(x2, y2), -- 342
					c1 -- 342
				} -- 342
			}) -- 342
			i = i + 1 -- 325
		end -- 325
	end -- 325
end -- 314
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 347
	local baseY = cam.groundScreenY - 8 -- 356
	local shift = -cam.x * 0.2 * cam.ppu -- 357
	local colW = 108 -- 358
	local first = math.floor((-shift - colW) / colW) -- 359
	local count = math.ceil(w / colW) + 3 -- 360
	local i = 0 -- 361
	do -- 361
		i = 0 -- 362
		while i < count do -- 362
			local idx = first + i -- 363
			local r1 = hash01(seed + idx * 13.7) -- 364
			local r2 = hash01(seed + idx * 29.3) -- 365
			local r3 = hash01(seed + idx * 47.1) -- 366
			local x = idx * colW + shift -- 367
			local bw = colW * (0.68 + r1 * 0.44) -- 368
			local bh = h * (0.18 + r2 * 0.38) -- 369
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 370
			bgDraw:drawPolygon( -- 372
				{ -- 372
					Vec2(x, baseY), -- 373
					Vec2(x + bw, baseY), -- 374
					Vec2(x + bw, baseY + bh - cut), -- 375
					Vec2(x + bw - cut, baseY + bh), -- 376
					Vec2(x, baseY + bh) -- 377
				}, -- 377
				toColor(theme.farBuilding) -- 378
			) -- 378
			if r3 > 0.62 then -- 378
				local ax = x + bw * 0.25 -- 382
				bgDraw:drawSegment( -- 383
					Vec2(ax, baseY + bh), -- 383
					Vec2(ax, baseY + bh + 32), -- 383
					1.2, -- 383
					toColor(theme.farBuilding) -- 383
				) -- 383
				if r1 > 0.6 then -- 383
					bgGlow:drawDot( -- 385
						Vec2(ax, baseY + bh + 32), -- 385
						2.2, -- 385
						toColor(theme.accent, 145) -- 385
					) -- 385
				end -- 385
			end -- 385
			if r2 > 0.55 then -- 385
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 390
				bgGlow:drawSegment( -- 391
					Vec2(x + 12, wy), -- 391
					Vec2(x + bw - 14, wy), -- 391
					1.1, -- 391
					toColor(theme.accent, 64) -- 391
				) -- 391
			end -- 391
			i = i + 1 -- 362
		end -- 362
	end -- 362
end -- 347
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 396
	local baseY = cam.groundScreenY - 8 -- 404
	local shift = -cam.x * 0.22 * cam.ppu -- 405
	local step = 76 -- 406
	local first = math.floor((-shift - step) / step) -- 407
	local count = math.ceil(w / step) + 4 -- 408
	local i = 0 -- 409
	do -- 409
		i = 0 -- 410
		while i < count do -- 410
			local idx = first + i -- 411
			local r1 = hash01(seed + idx * 11.3) -- 412
			local r2 = hash01(seed + idx * 23.9) -- 413
			local cx = idx * step + shift -- 414
			local tw = 34 + r1 * 38 -- 415
			local th = h * (0.24 + r2 * 0.34) -- 416
			bgDraw:drawPolygon( -- 418
				{ -- 418
					Vec2(cx - tw, baseY), -- 419
					Vec2(cx + tw, baseY), -- 420
					Vec2(cx, baseY + th) -- 421
				}, -- 421
				toColor(theme.farBuilding) -- 422
			) -- 422
			bgDraw:drawPolygon( -- 423
				{ -- 423
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 424
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 425
					Vec2(cx, baseY + th * 1.12) -- 426
				}, -- 426
				toColor(theme.farBuilding) -- 427
			) -- 427
			i = i + 1 -- 410
		end -- 410
	end -- 410
end -- 396
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 431
	local baseY = cam.groundScreenY - 4 -- 441
	local shift = -cam.x * 0.48 * cam.ppu -- 442
	local bay = 240 -- 443
	local first = math.floor((-shift - bay) / bay) -- 444
	local count = math.ceil(w / bay) + 3 -- 445
	local col = toColor(theme.midBuilding) -- 446
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 447
	local i = 0 -- 449
	do -- 449
		i = 0 -- 450
		while i < count do -- 450
			local idx = first + i -- 451
			local r = hash01(seed + idx * 37.3) -- 452
			local x = idx * bay + shift -- 453
			local colH = h * (0.34 + r * 0.24) -- 454
			local pw = 22 + r * 16 -- 455
			bgDraw:drawRect( -- 458
				Rect(x, baseY, pw, colH), -- 458
				col -- 458
			) -- 458
			bgDraw:drawSegment( -- 459
				Vec2(x + pw, baseY), -- 459
				Vec2(x + pw, baseY + colH), -- 459
				1, -- 459
				edge -- 459
			) -- 459
			if r > 0.35 then -- 459
				local beamY = baseY + colH * 0.76 -- 461
				bgDraw:drawSegment( -- 462
					Vec2(x + pw, beamY), -- 462
					Vec2(x + bay, beamY), -- 462
					4, -- 462
					col -- 462
				) -- 462
				bgDraw:drawSegment( -- 463
					Vec2(x + pw, beamY - 22), -- 463
					Vec2(x + bay * 0.5, beamY), -- 463
					1.4, -- 463
					edge -- 463
				) -- 463
				bgDraw:drawSegment( -- 464
					Vec2(x + bay * 0.5, beamY), -- 464
					Vec2(x + bay, beamY - 22), -- 464
					1.4, -- 464
					edge -- 464
				) -- 464
			end -- 464
			bgDraw:drawQuadraticBezier( -- 468
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 469
				Vec2( -- 470
					x + bay * 0.5, -- 470
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 470
				), -- 470
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 471
				1, -- 472
				Color(12, 18, 28, 180) -- 473
			) -- 473
			if idx & 1 == 0 then -- 473
				local lx = x + bay * 0.52 -- 478
				local ly = baseY + h * 0.31 -- 479
				bgDraw:drawSegment( -- 480
					Vec2(lx, baseY), -- 480
					Vec2(lx, ly), -- 480
					2.2, -- 480
					col -- 480
				) -- 480
				bgDraw:drawSegment( -- 481
					Vec2(lx, ly), -- 481
					Vec2(lx + 18, ly - 4), -- 481
					2, -- 481
					col -- 481
				) -- 481
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 482
				local lc = theme.accent -- 483
				bgGlow:drawDot( -- 484
					Vec2(lx + 18, ly - 5), -- 484
					3.2, -- 484
					toColor(lc, 210 * flicker) -- 484
				) -- 484
				fillRadialGlow( -- 485
					bgGlow, -- 485
					lx + 18, -- 485
					ly - 5, -- 485
					36, -- 485
					36, -- 485
					toColor(lc, 54 * flicker), -- 485
					Color(lc.r, lc.g, lc.b, 0), -- 485
					14 -- 485
				) -- 485
				bgGlow:drawVertices({ -- 486
					{ -- 487
						Vec2(lx + 18, ly - 6), -- 487
						toColor(lc, 38 * flicker) -- 487
					}, -- 487
					{ -- 488
						Vec2(lx - 42, baseY), -- 488
						Color(lc.r, lc.g, lc.b, 0) -- 488
					}, -- 488
					{ -- 489
						Vec2(lx + 78, baseY), -- 489
						Color(lc.r, lc.g, lc.b, 0) -- 489
					} -- 489
				}) -- 489
			end -- 489
			i = i + 1 -- 450
		end -- 450
	end -- 450
end -- 431
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 495
	local baseY = cam.groundScreenY - 4 -- 505
	local shift = -cam.x * 0.52 * cam.ppu -- 506
	local span = 156 -- 507
	local first = math.floor((-shift - span) / span) -- 508
	local count = math.ceil(w / span) + 3 -- 509
	local col = toColor(theme.midBuilding) -- 510
	local i = 0 -- 512
	do -- 512
		i = 0 -- 513
		while i < count do -- 513
			local idx = first + i -- 514
			local r = hash01(seed + idx * 19.7) -- 515
			local x = idx * span + shift -- 516
			local trunkW = 14 + r * 14 -- 517
			local sway = math.sin(time * 0.9 + idx) * 4 -- 518
			bgDraw:drawPolygon( -- 519
				{ -- 519
					Vec2(x - trunkW * 0.5, baseY), -- 520
					Vec2(x + trunkW * 0.5, baseY), -- 521
					Vec2(x + trunkW * 0.25 + sway, h), -- 522
					Vec2(x - trunkW * 0.3 + sway, h) -- 523
				}, -- 523
				col -- 524
			) -- 524
			if idx % 3 == 0 then -- 524
				bgGlow:drawVertices({ -- 527
					{ -- 528
						Vec2(x + 40, h), -- 528
						Color(110, 232, 200, 26) -- 528
					}, -- 528
					{ -- 529
						Vec2(x + 115, h), -- 529
						Color(110, 232, 200, 0) -- 529
					}, -- 529
					{ -- 530
						Vec2(x - 60, baseY), -- 530
						Color(110, 232, 200, 0) -- 530
					} -- 530
				}) -- 530
			end -- 530
			i = i + 1 -- 513
		end -- 513
	end -- 513
end -- 495
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 536
	local scale = 0.55 -- 546
	if p.room.key == "village" then -- 546
		scale = 0.72 -- 548
	elseif p.room.key == "forest" then -- 548
		scale = 0.92 -- 550
	elseif p.room.key == "tower" then -- 550
		scale = 1.15 -- 552
	end -- 552
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 554
	local baseY = cam.groundScreenY - 8 -- 555
	local towerH = h * 0.42 * scale -- 556
	local bw = 20 * scale -- 557
	bgDraw:drawPolygon( -- 558
		{ -- 558
			Vec2(tx - bw, baseY), -- 559
			Vec2(tx + bw, baseY), -- 560
			Vec2(tx + bw * 0.45, baseY + towerH), -- 561
			Vec2(tx - bw * 0.45, baseY + towerH) -- 562
		}, -- 562
		Color(14, 24, 38, 240) -- 563
	) -- 563
	bgDraw:drawSegment( -- 564
		Vec2(tx, baseY + towerH), -- 564
		Vec2(tx, baseY + towerH + 28 * scale), -- 564
		1.8, -- 564
		Color(180, 210, 238, 200) -- 564
	) -- 564
	local topY = baseY + towerH + 24 * scale -- 566
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 567
	fillRadialGlow( -- 568
		bgGlow, -- 568
		tx, -- 568
		topY, -- 568
		56 * scale * pulse, -- 568
		56 * scale * pulse, -- 568
		Color(255, 224, 152, 118), -- 568
		Color(255, 190, 96, 0), -- 568
		18 -- 568
	) -- 568
	bgGlow:drawDot( -- 569
		Vec2(tx, topY), -- 569
		3.6 * scale, -- 569
		Color(255, 246, 220, 255) -- 569
	) -- 569
end -- 536
function StageRenderer.prototype.drawFloors(self, fgDraw, fgGlow, p, cam, theme) -- 572
	local i = 0 -- 579
	do -- 579
		i = 0 -- 580
		while i < #p.room.floors do -- 580
			local f = p.room.floors[i + 1] -- 581
			local x0 = cam:sx(f.x0) -- 582
			local x1 = cam:sx(f.x1) -- 583
			local y = cam:sy(f.y) -- 584
			local isMain = f.y <= 0.1 -- 585
			if isMain then -- 585
				fillVGradRect( -- 589
					fgDraw, -- 589
					x0, -- 589
					0, -- 589
					x1 - x0, -- 589
					y, -- 589
					toColor(PALETTE.voidDark), -- 589
					toColor(theme.groundBody) -- 589
				) -- 589
				fgDraw:drawRect( -- 590
					Rect(x0, y - 10, x1 - x0, 10), -- 590
					toColor(theme.groundTop) -- 590
				) -- 590
				fgDraw:drawSegment( -- 591
					Vec2(x0, y), -- 591
					Vec2(x1, y), -- 591
					1.8, -- 591
					toColor(theme.groundRim) -- 591
				) -- 591
				fgGlow:drawSegment( -- 592
					Vec2(x0, y + 1), -- 592
					Vec2(x1, y + 1), -- 592
					1.2, -- 592
					toColor(theme.accent, 65) -- 592
				) -- 592
				local jointStep = cam:len(64) -- 595
				if jointStep > 16 then -- 595
					local gx = x0 -- 597
					while gx < x1 do -- 597
						fgDraw:drawSegment( -- 599
							Vec2(gx, y - 2), -- 599
							Vec2(gx - 14, y - 28), -- 599
							1, -- 599
							Color(42, 56, 76, 120) -- 599
						) -- 599
						gx = gx + jointStep -- 600
					end -- 600
				end -- 600
			else -- 600
				local deckH = math.max( -- 605
					14, -- 605
					cam:len(9) -- 605
				) -- 605
				fillVGradRect( -- 607
					fgDraw, -- 607
					x0, -- 607
					y - deckH - 26, -- 607
					x1 - x0, -- 607
					26, -- 607
					Color(4, 6, 10, 0), -- 607
					Color(4, 6, 10, 155) -- 607
				) -- 607
				fgDraw:drawRect( -- 608
					Rect(x0, y - deckH, x1 - x0, deckH), -- 608
					toColor(PALETTE.steelDark) -- 608
				) -- 608
				fgDraw:drawRect( -- 609
					Rect(x0, y - 4, x1 - x0, 4), -- 609
					toColor(theme.groundTop) -- 609
				) -- 609
				fgDraw:drawSegment( -- 610
					Vec2(x0, y), -- 610
					Vec2(x1, y), -- 610
					1.8, -- 610
					toColor(theme.groundRim) -- 610
				) -- 610
				fgDraw:drawSegment( -- 611
					Vec2(x0, y - deckH), -- 611
					Vec2(x1, y - deckH), -- 611
					1.2, -- 611
					toColor(PALETTE.steelLight, 150) -- 611
				) -- 611
				local trussStep = math.max( -- 614
					24, -- 614
					cam:len(26) -- 614
				) -- 614
				local tx = x0 + 6 -- 615
				while tx + trussStep < x1 do -- 615
					fgDraw:drawSegment( -- 617
						Vec2(tx, y - deckH + 2), -- 617
						Vec2(tx + trussStep * 0.5, y - 4), -- 617
						1.1, -- 617
						toColor(PALETTE.steelLight, 120) -- 617
					) -- 617
					fgDraw:drawSegment( -- 618
						Vec2(tx + trussStep * 0.5, y - 4), -- 618
						Vec2(tx + trussStep, y - deckH + 2), -- 618
						1.1, -- 618
						toColor(PALETTE.steelLight, 120) -- 618
					) -- 618
					tx = tx + trussStep -- 619
				end -- 619
				drawHazardStripes( -- 622
					fgDraw, -- 622
					x0 + 2, -- 622
					y - deckH + 2, -- 622
					math.min(48, (x1 - x0) * 0.15), -- 622
					deckH - 5, -- 622
					10, -- 622
					toColor(PALETTE.amber, 120) -- 622
				) -- 622
			end -- 622
			i = i + 1 -- 580
		end -- 580
	end -- 580
end -- 572
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, p, cam, theme) -- 627
	local i = 0 -- 634
	do -- 634
		i = 0 -- 635
		while i < #p.room.stairs do -- 635
			local st = p.room.stairs[i + 1] -- 636
			local n = st.steps + 1 -- 637
			local stepW = (st.x1 - st.x0) / n -- 638
			local k = 0 -- 639
			do -- 639
				k = 0 -- 640
				while k < n do -- 640
					local wy = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 641
					local wx0 = st.x0 + stepW * k -- 642
					local wx1 = wx0 + stepW -- 643
					local x0 = cam:sx(wx0) -- 644
					local x1 = cam:sx(wx1) -- 645
					local y1 = cam:sy(wy) -- 646
					local y0 = cam:sy(math.max(0, st.y0)) -- 647
					if y1 > y0 + 2 then -- 647
						fgDraw:drawRect( -- 649
							Rect(x0, y0, x1 - x0, y1 - y0), -- 649
							toColor(PALETTE.steelDark, 230) -- 649
						) -- 649
						fgDraw:drawRect( -- 650
							Rect(x0, y1 - 5, x1 - x0, 5), -- 650
							toColor(theme.groundTop) -- 650
						) -- 650
					end -- 650
					fgDraw:drawSegment( -- 652
						Vec2(x0, y1), -- 652
						Vec2(x1, y1), -- 652
						1.8, -- 652
						toColor(theme.groundRim) -- 652
					) -- 652
					fgGlow:drawSegment( -- 653
						Vec2(x0, y1 + 1), -- 653
						Vec2(x1, y1 + 1), -- 653
						1, -- 653
						toColor(theme.accent, 55) -- 653
					) -- 653
					k = k + 1 -- 640
				end -- 640
			end -- 640
			i = i + 1 -- 635
		end -- 635
	end -- 635
end -- 627
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, p, cam, theme, time) -- 658
	local i = 0 -- 666
	do -- 666
		i = 0 -- 667
		while i < #p.room.solids do -- 667
			do -- 667
				local s = p.room.solids[i + 1] -- 668
				local x0 = cam:sx(s.x) -- 669
				local x1 = cam:sx(s.x + s.w) -- 670
				local y0 = cam:sy(s.y) -- 671
				local y1 = cam:sy(s.y + s.h) -- 672
				local sw = x1 - x0 -- 673
				local sh = y1 - y0 -- 674
				if sw <= 1 or sh <= 1 then -- 674
					goto __continue69 -- 676
				end -- 676
				if s.passable == true then -- 676
					self:drawGrassCluster( -- 681
						fgDraw, -- 681
						fgGlow, -- 681
						x0, -- 681
						y0, -- 681
						sw, -- 681
						sh, -- 681
						p.player.x, -- 681
						s.x + s.w * 0.5, -- 681
						time -- 681
					) -- 681
					goto __continue69 -- 682
				end -- 682
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 682
					self:drawWinch( -- 687
						fgDraw, -- 687
						fgGlow, -- 687
						x0, -- 687
						y0, -- 687
						sw, -- 687
						sh, -- 687
						p, -- 687
						time -- 687
					) -- 687
					goto __continue69 -- 688
				end -- 688
				if p.room.key == "tower" then -- 688
					self:drawTowerStructure( -- 693
						fgDraw, -- 693
						fgGlow, -- 693
						x0, -- 693
						y0, -- 693
						sw, -- 693
						sh, -- 693
						s, -- 693
						p, -- 693
						time -- 693
					) -- 693
					goto __continue69 -- 694
				end -- 694
				if s.h <= 64 and s.y <= 2 then -- 694
					self:drawCoverBlock( -- 699
						fgDraw, -- 699
						fgGlow, -- 699
						x0, -- 699
						y0, -- 699
						sw, -- 699
						sh, -- 699
						s, -- 699
						p, -- 699
						theme -- 699
					) -- 699
					goto __continue69 -- 700
				end -- 700
				fillVGradRect( -- 704
					fgDraw, -- 704
					x0, -- 704
					y0, -- 704
					sw, -- 704
					sh, -- 704
					toColor(PALETTE.steelDark), -- 704
					toColor(PALETTE.steelMid) -- 704
				) -- 704
				fgDraw:drawRect( -- 705
					Rect(x0, y0, sw, sh), -- 705
					Color(0, 0, 0, 0), -- 705
					1.2, -- 705
					toColor(PALETTE.steelLight, 180) -- 705
				) -- 705
				local inset = math.min(10, sw * 0.14) -- 707
				fgDraw:drawSegment( -- 708
					Vec2(x0 + inset, y0 + 10), -- 708
					Vec2(x0 + inset, y1 - 10), -- 708
					1, -- 708
					toColor(PALETTE.voidDark, 150) -- 708
				) -- 708
				fgDraw:drawSegment( -- 709
					Vec2(x1 - inset, y0 + 10), -- 709
					Vec2(x1 - inset, y1 - 10), -- 709
					1, -- 709
					toColor(PALETTE.voidDark, 150) -- 709
				) -- 709
				fgDraw:drawSegment( -- 711
					Vec2(x0, y1), -- 711
					Vec2(x1, y1), -- 711
					2, -- 711
					toColor(theme.groundRim) -- 711
				) -- 711
				if (string.find(s.label, "城门", nil, true) or 0) - 1 >= 0 or (string.find(s.label, "门洞", nil, true) or 0) - 1 >= 0 or (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 711
					drawHazardStripes( -- 713
						fgDraw, -- 713
						x0 + 2, -- 713
						y0 + 4, -- 713
						sw - 4, -- 713
						math.min(14, sh * 0.2), -- 713
						14, -- 713
						toColor(PALETTE.crimson, 130) -- 713
					) -- 713
				end -- 713
			end -- 713
			::__continue69:: -- 713
			i = i + 1 -- 667
		end -- 667
	end -- 667
end -- 658
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, x0, y0, sw, sh, s, p, theme) -- 718
	local isRail = (string.find(s.label, "队栏", nil, true) or 0) - 1 >= 0 -- 724
	if isRail then -- 724
		local posts = 4 -- 727
		local k = 0 -- 728
		do -- 728
			k = 0 -- 729
			while k <= posts do -- 729
				local px = x0 + sw * k / posts -- 730
				fgDraw:drawSegment( -- 731
					Vec2(px, y0), -- 731
					Vec2(px, y0 + sh), -- 731
					3, -- 731
					toColor(PALETTE.steelLight) -- 731
				) -- 731
				k = k + 1 -- 729
			end -- 729
		end -- 729
		fgDraw:drawRect( -- 733
			Rect(x0, y0 + sh - 8, sw, 8), -- 733
			toColor(PALETTE.steelMid) -- 733
		) -- 733
		fgDraw:drawSegment( -- 734
			Vec2(x0, y0 + sh), -- 734
			Vec2(x0 + sw, y0 + sh), -- 734
			2, -- 734
			toColor(theme.accent, 210) -- 734
		) -- 734
		fgDraw:drawSegment( -- 735
			Vec2(x0, y0 + sh * 0.48), -- 735
			Vec2(x0 + sw, y0 + sh * 0.48), -- 735
			2, -- 735
			toColor(PALETTE.steelLight, 180) -- 735
		) -- 735
		return -- 736
	end -- 736
	fillChamferBox( -- 740
		fgDraw, -- 740
		x0, -- 740
		y0, -- 740
		sw, -- 740
		sh, -- 740
		10, -- 740
		toColor(PALETTE.steelMid), -- 740
		1.4, -- 740
		toColor(PALETTE.rimSilver, 180) -- 740
	) -- 740
	fillVGradRect( -- 741
		fgDraw, -- 741
		x0 + 4, -- 741
		y0 + 4, -- 741
		sw - 8, -- 741
		sh - 12, -- 741
		toColor(PALETTE.steelDark), -- 741
		toColor(PALETTE.steelMid) -- 741
	) -- 741
	fgDraw:drawSegment( -- 743
		Vec2(x0 + 8, y0 + sh), -- 743
		Vec2(x0 + sw - 2, y0 + sh), -- 743
		2.2, -- 743
		toColor(PALETTE.rimSilver, 235) -- 743
	) -- 743
	drawHazardStripes( -- 745
		fgDraw, -- 745
		x0 + 6, -- 745
		y0 + 4, -- 745
		sw - 12, -- 745
		math.min(11, sh * 0.22), -- 745
		14, -- 745
		toColor(theme.accent, 110) -- 745
	) -- 745
	if not p.childMode and (p.coverHug or p.coverNear) then -- 745
		local plx = p.player.x -- 749
		local nearLeft = math.abs(plx - s.x) < 42 -- 750
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 751
		if nearLeft or nearRight then -- 751
			local edgeX = nearLeft and x0 - 2 or x0 + sw + 2 -- 753
			local col = p.coverHug and PALETTE.cyan or PALETTE.amber -- 754
			fgGlow:drawSegment( -- 755
				Vec2(edgeX, y0 + 4), -- 755
				Vec2(edgeX, y0 + sh + 4), -- 755
				p.coverHug and 3.5 or 2, -- 755
				toColor(col, p.coverHug and 220 or 140) -- 755
			) -- 755
			if p.coverHug then -- 755
				fillRadialGlow( -- 757
					fgGlow, -- 757
					edgeX, -- 757
					y0 + sh * 0.55, -- 757
					22, -- 757
					sh * 0.7, -- 757
					toColor(PALETTE.cyan, 85), -- 757
					Color(72, 224, 255, 0), -- 757
					14 -- 757
				) -- 757
			end -- 757
		end -- 757
	end -- 757
end -- 718
function StageRenderer.prototype.drawWinch(self, fgDraw, fgGlow, x0, y0, sw, sh, p, time) -- 763
	fillChamferBox( -- 769
		fgDraw, -- 769
		x0, -- 769
		y0, -- 769
		sw, -- 769
		sh, -- 769
		8, -- 769
		toColor(PALETTE.steelMid), -- 769
		1.5, -- 769
		toColor(PALETTE.rimSilver, 180) -- 769
	) -- 769
	local cx = x0 + sw * 0.5 -- 771
	local cy = y0 + sh * 0.55 -- 772
	local r = math.min(sw, sh) * 0.34 -- 773
	local spin = p.phase == "gate-hold" and time * 1.4 or 0 -- 774
	fgDraw:drawRing( -- 775
		Vec2(cx, cy), -- 775
		r * 0.62, -- 775
		r, -- 775
		toColor(PALETTE.steelDark), -- 775
		1.5, -- 775
		toColor(PALETTE.rimSilver, 210) -- 775
	) -- 775
	local k = 0 -- 776
	do -- 776
		k = 0 -- 777
		while k < 6 do -- 777
			local a = spin + k * math.pi / 3 -- 778
			fgDraw:drawSegment( -- 779
				Vec2( -- 780
					cx + math.cos(a) * r * 0.25, -- 780
					cy + math.sin(a) * r * 0.25 -- 780
				), -- 780
				Vec2( -- 781
					cx + math.cos(a) * r * 1.05, -- 781
					cy + math.sin(a) * r * 1.05 -- 781
				), -- 781
				2, -- 782
				toColor(PALETTE.rimSilver, 210) -- 783
			) -- 783
			k = k + 1 -- 777
		end -- 777
	end -- 777
	fgDraw:drawSegment( -- 787
		Vec2(cx, cy + r), -- 787
		Vec2(cx, y0 + sh + 220), -- 787
		1.6, -- 787
		toColor(PALETTE.steelLight, 175) -- 787
	) -- 787
	local active = p.phase == "gate-hold" or p.phase == "gate-send" -- 789
	local lampCol = active and PALETTE.cyan or PALETTE.amber -- 790
	local pulse = 0.7 + 0.3 * math.sin(time * 5) -- 791
	fgGlow:drawDot( -- 792
		Vec2(x0 + sw - 10, y0 + sh - 10), -- 792
		4, -- 792
		toColor(lampCol, 240 * pulse) -- 792
	) -- 792
	fillRadialGlow( -- 793
		fgGlow, -- 793
		x0 + sw - 10, -- 793
		y0 + sh - 10, -- 793
		22, -- 793
		22, -- 793
		toColor(lampCol, 95 * pulse), -- 793
		Color(lampCol.r, lampCol.g, lampCol.b, 0), -- 793
		12 -- 793
	) -- 793
end -- 763
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, p, cam, time) -- 796
	local ____temp_0 -- 803
	if p.room.story ~= nil then -- 803
		____temp_0 = p.room.story.gate -- 803
	else -- 803
		____temp_0 = nil -- 803
	end -- 803
	local g = ____temp_0 -- 803
	if g == nil then -- 803
		return -- 805
	end -- 805
	local closeFrac = 0.08 -- 808
	if p.phase == "gate-hold" then -- 808
		closeFrac = 0.08 + 0.36 * math.min( -- 810
			1, -- 810
			p.gateTick / math.max(1, g.holdTicks) -- 810
		) -- 810
	elseif p.phase == "gate-send" then -- 810
		closeFrac = 0.44 -- 812
	elseif p.phase == "gate-count" then -- 812
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 814
	elseif p.phase == "gate-walk" then -- 814
		closeFrac = 1 -- 816
	end -- 816
	local gx0 = cam:sx(848) -- 818
	local gx1 = cam:sx(1032) -- 819
	local topY = cam:sy(160) -- 820
	local botY = cam:sy(160 * (1 - closeFrac)) -- 821
	if topY > botY + 2 then -- 821
		fillVGradRect( -- 823
			fgDraw, -- 823
			gx0, -- 823
			botY, -- 823
			gx1 - gx0, -- 823
			topY - botY, -- 823
			toColor(PALETTE.steelDark), -- 823
			toColor(PALETTE.steelMid) -- 823
		) -- 823
		fgDraw:drawSegment( -- 824
			Vec2(gx0, botY), -- 824
			Vec2(gx1, botY), -- 824
			3, -- 824
			toColor(PALETTE.crimson, 220) -- 824
		) -- 824
		drawHazardStripes( -- 825
			fgDraw, -- 825
			gx0 + 4, -- 825
			botY + 3, -- 825
			gx1 - gx0 - 8, -- 825
			math.min(14, topY - botY - 4), -- 825
			18, -- 825
			toColor(PALETTE.amber, 140) -- 825
		) -- 825
	end -- 825
	if closeFrac < 0.98 then -- 825
		local gapH = math.max( -- 829
			8, -- 829
			botY - cam:sy(0) -- 829
		) -- 829
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 830
		fillVGradRect( -- 831
			fgGlow, -- 831
			gx0, -- 831
			cam:sy(0), -- 831
			gx1 - gx0, -- 831
			gapH, -- 831
			Color( -- 831
				140, -- 831
				210, -- 831
				255, -- 831
				math.floor(52 * pulse + 0.5) -- 831
			), -- 831
			Color(80, 160, 230, 0) -- 831
		) -- 831
	end -- 831
end -- 796
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, x0, y0, sw, sh, s, p, time) -- 835
	fillVGradRect( -- 841
		fgDraw, -- 841
		x0, -- 841
		y0, -- 841
		sw, -- 841
		sh, -- 841
		Color(15, 21, 34, 255), -- 841
		Color(32, 44, 66, 255) -- 841
	) -- 841
	fgDraw:drawRect( -- 842
		Rect(x0, y0, sw, sh), -- 842
		Color(0, 0, 0, 0), -- 842
		1.4, -- 842
		toColor(PALETTE.rimSilver, 165) -- 842
	) -- 842
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 842
		local ribs = 4 -- 846
		local r = 1 -- 847
		do -- 847
			r = 1 -- 848
			while r < ribs do -- 848
				local rx = x0 + sw * r / ribs -- 849
				fgDraw:drawSegment( -- 850
					Vec2(rx, y0), -- 850
					Vec2(rx, y0 + sh), -- 850
					2, -- 850
					Color(10, 15, 24, 210) -- 850
				) -- 850
				fgDraw:drawSegment( -- 851
					Vec2(rx + 2, y0), -- 851
					Vec2(rx + 2, y0 + sh), -- 851
					1, -- 851
					Color(68, 86, 114, 130) -- 851
				) -- 851
				r = r + 1 -- 848
			end -- 848
		end -- 848
		local bands = 4 -- 854
		local b = 1 -- 855
		do -- 855
			b = 1 -- 856
			while b < bands do -- 856
				local by = y0 + sh * b / bands -- 857
				fgDraw:drawSegment( -- 858
					Vec2(x0 + 4, by), -- 858
					Vec2(x0 + sw - 4, by), -- 858
					1.2, -- 858
					Color(52, 68, 92, 135) -- 858
				) -- 858
				b = b + 1 -- 856
			end -- 856
		end -- 856
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 861
		local slitY = y0 + sh * 0.56 -- 862
		local slitH = sh * 0.22 -- 863
		fgDraw:drawRect( -- 864
			Rect(slitX - 5, slitY, 10, slitH), -- 864
			Color(8, 12, 20, 245), -- 864
			1.2, -- 864
			toColor(PALETTE.amberDim, 190) -- 864
		) -- 864
		fgGlow:drawRect( -- 865
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 865
			toColor(PALETTE.amber, 190) -- 865
		) -- 865
		fillRadialGlow( -- 866
			fgGlow, -- 866
			slitX, -- 866
			slitY + slitH * 0.5, -- 866
			44, -- 866
			slitH * 0.7, -- 866
			Color(255, 206, 128, 52), -- 866
			Color(255, 180, 86, 0), -- 866
			14 -- 866
		) -- 866
	end -- 866
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 866
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 871
		local cx = x0 + sw * 0.5 -- 872
		local lampY = y0 - 8 -- 873
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 874
		local alpha = opened and 155 or 88 -- 875
		fgDraw:drawSegment( -- 877
			Vec2(x0 + 4, y0), -- 877
			Vec2(x0 + 4, y0 - sh * 3.8), -- 877
			4, -- 877
			Color(42, 52, 70, 255) -- 877
		) -- 877
		fgDraw:drawSegment( -- 878
			Vec2(x0 + sw - 4, y0), -- 878
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 878
			4, -- 878
			Color(42, 52, 70, 255) -- 878
		) -- 878
		fgDraw:drawSegment( -- 879
			Vec2(x0, y0), -- 879
			Vec2(x0 + sw, y0), -- 879
			2.5, -- 879
			toColor(PALETTE.amber, 210) -- 879
		) -- 879
		fillVGradRect( -- 881
			fgGlow, -- 882
			x0 + 6, -- 883
			y0 - sh * 3.8, -- 884
			sw - 12, -- 885
			sh * 3.8, -- 886
			Color( -- 887
				255, -- 887
				206, -- 887
				128, -- 887
				math.floor(alpha * pulse + 0.5) -- 887
			), -- 887
			Color(255, 224, 168, opened and 180 or 62) -- 888
		) -- 888
		fillRadialGlow( -- 890
			fgGlow, -- 890
			cx, -- 890
			lampY, -- 890
			opened and 105 or 58, -- 890
			opened and 105 or 58, -- 890
			Color( -- 890
				255, -- 890
				232, -- 890
				178, -- 890
				math.floor(170 * pulse + 0.5) -- 890
			), -- 890
			Color(255, 180, 86, 0), -- 890
			18 -- 890
		) -- 890
		fgDraw:drawCircle( -- 891
			Vec2(cx, lampY), -- 891
			5.5, -- 891
			toColor(PALETTE.amberCore) -- 891
		) -- 891
	end -- 891
end -- 835
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 895
	local blades = math.max( -- 902
		12, -- 902
		math.floor(sw / 8) -- 902
	) -- 902
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 903
	local k = 0 -- 904
	do -- 904
		k = 0 -- 905
		while k < blades do -- 905
			local t = (k + 0.5) / blades -- 906
			local bx = x0 + sw * t -- 907
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 908
			local bh = sh * hRatio * 1.95 -- 909
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 910
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 911
			fgDraw:drawPolygon( -- 912
				{ -- 912
					Vec2(bx - 7, y0), -- 913
					Vec2(bx + 7, y0), -- 914
					Vec2(bx + sway, y0 + bh) -- 915
				}, -- 915
				col -- 916
			) -- 916
			k = k + 1 -- 905
		end -- 905
	end -- 905
	if nearPlayer then -- 905
		fgGlow:drawSegment( -- 919
			Vec2(x0, y0 + 2), -- 919
			Vec2(x0 + sw, y0 + 2), -- 919
			2, -- 919
			toColor(PALETTE.emerald, 145) -- 919
		) -- 919
	end -- 919
end -- 895
function StageRenderer.prototype.drawArch(self, fgDraw, fgGlow, p, cam, theme) -- 923
	local a = p.room.arch -- 930
	if a.h <= 0 or a.x1 <= a.x0 then -- 930
		return -- 932
	end -- 932
	local x0 = cam:sx(a.x0) -- 934
	local x1 = cam:sx(a.x1) -- 935
	local y0 = cam:sy(a.y) -- 936
	local y1 = cam:sy(a.y + a.h) -- 937
	local aw = x1 - x0 -- 938
	local ah = y1 - y0 -- 939
	fgDraw:drawRect( -- 942
		Rect(x0, y0, aw, ah), -- 942
		Color(5, 7, 11, 245) -- 942
	) -- 942
	fgDraw:drawSegment( -- 944
		Vec2(x0, y0), -- 944
		Vec2(x0, y1), -- 944
		3, -- 944
		toColor(PALETTE.rimSilver, 215) -- 944
	) -- 944
	fgDraw:drawSegment( -- 945
		Vec2(x1, y0), -- 945
		Vec2(x1, y1), -- 945
		3, -- 945
		toColor(PALETTE.rimSilver, 215) -- 945
	) -- 945
	fgDraw:drawSegment( -- 946
		Vec2(x0 - 4, y1), -- 946
		Vec2(x1 + 4, y1), -- 946
		3.2, -- 946
		toColor(PALETTE.rimSilver, 235) -- 946
	) -- 946
	if p.room.key == "outside" then -- 946
		local arcR = math.min(aw * 0.46, ah * 0.72) -- 949
		fgDraw:drawArc( -- 950
			Vec2((x0 + x1) * 0.5, y1 - arcR - 2), -- 950
			arcR, -- 950
			0, -- 950
			180, -- 950
			2.2, -- 950
			toColor(theme.accent, 195) -- 950
		) -- 950
		fillVGradRect( -- 951
			fgGlow, -- 951
			x0 + 6, -- 951
			y0, -- 951
			aw - 12, -- 951
			ah * 0.65, -- 951
			Color(86, 186, 236, 52), -- 951
			Color(86, 186, 236, 0) -- 951
		) -- 951
	end -- 951
end -- 923
return ____exports -- 923