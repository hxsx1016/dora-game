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
local fillChamferBox = ____theme.fillChamferBox -- 14
local fillRadialGlow = ____theme.fillRadialGlow -- 16
local fillVGradRect = ____theme.fillVGradRect -- 17
local lerpRGBA = ____theme.lerpRGBA -- 18
local themeOf = ____theme.themeOf -- 19
local toColor = ____theme.toColor -- 20
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 24
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 25
	return x - math.floor(x) -- 26
end -- 24
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 30
	local h = 17 -- 31
	local i = 0 -- 32
	do -- 32
		i = 0 -- 33
		while i < #key do -- 33
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 34
			i = i + 1 -- 33
		end -- 33
	end -- 33
	return h -- 36
end -- 30
local function coverArt(solid) -- 39
	if solid.art == "gate_post" then -- 39
		return "wall" -- 41
	end -- 41
	return solid.art or ((string.find(solid.label, "队栏", nil, true) or 0) - 1 >= 0 and "fence" or (((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone")) -- 43
end -- 39
____exports.StageRenderer = __TS__Class() -- 47
local StageRenderer = ____exports.StageRenderer -- 47
StageRenderer.name = "StageRenderer" -- 47
function StageRenderer.prototype.____constructor(self) -- 47
end -- 47
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 49
	local w = cam.viewW -- 57
	local h = cam.viewH -- 58
	local theme = themeOf(p.room.key) -- 59
	local seed = roomSeed(p.room.key) -- 60
	local span = math.max(1, p.room.maxX - p.room.minX) -- 62
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 63
	local farSlot = "bgFar_" .. p.room.key -- 64
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 65
	local artH = artW * 9 / 16 -- 66
	if assets:tryPlace( -- 66
		farSlot, -- 67
		"scene", -- 67
		w * (0.5 - progress * 0.09), -- 67
		(h - artH) * 0.5, -- 67
		artW, -- 67
		artH -- 67
	) then -- 67
		self:drawDressing(assets, p, cam, progress) -- 68
		local y = cam.groundScreenY -- 69
		fillVGradRect( -- 70
			bgDraw, -- 70
			0, -- 70
			0, -- 70
			w, -- 70
			h, -- 70
			toColor(PALETTE.voidDark), -- 70
			toColor(theme.skyMid) -- 70
		) -- 70
		fillVGradRect( -- 71
			bgGlow, -- 71
			0, -- 71
			y - 1, -- 71
			w, -- 71
			h * 0.14, -- 71
			Color(43, 49, 63, 15), -- 71
			Color(43, 49, 63, 0) -- 71
		) -- 71
		return -- 72
	end -- 72
	local splitY = h * 0.46 -- 76
	fillVGradRect( -- 77
		bgDraw, -- 77
		0, -- 77
		splitY, -- 77
		w, -- 77
		h - splitY, -- 77
		toColor(theme.skyMid), -- 77
		toColor(theme.skyTop) -- 77
	) -- 77
	fillVGradRect( -- 78
		bgDraw, -- 78
		0, -- 78
		0, -- 78
		w, -- 78
		splitY, -- 78
		toColor(theme.skyHorizon), -- 78
		toColor(theme.skyMid) -- 78
	) -- 78
	if theme.showMoon then -- 78
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 82
		local my = h * theme.moonYFrac -- 83
		local mr = math.max(18, h * 0.044) -- 84
		fillRadialGlow( -- 85
			bgGlow, -- 85
			mx, -- 85
			my, -- 85
			mr * 6.2, -- 85
			mr * 6.2, -- 85
			Color(140, 200, 255, 28), -- 85
			Color(20, 40, 80, 0), -- 85
			22 -- 85
		) -- 85
		fillRadialGlow( -- 86
			bgGlow, -- 86
			mx, -- 86
			my, -- 86
			mr * 2.4, -- 86
			mr * 2.4, -- 86
			Color(200, 232, 255, 64), -- 86
			Color(80, 140, 210, 0), -- 86
			18 -- 86
		) -- 86
		bgDraw:drawCircle( -- 87
			Vec2(mx, my), -- 87
			mr, -- 87
			Color(224, 238, 252, 230) -- 87
		) -- 87
		bgDraw:drawCircle( -- 89
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 89
			mr * 0.84, -- 89
			toColor(theme.skyTop, 110) -- 89
		) -- 89
	end -- 89
	if p.room.key == "forest" then -- 89
		self:drawFarForest( -- 93
			bgDraw, -- 93
			w, -- 93
			h, -- 93
			cam, -- 93
			theme, -- 93
			seed -- 93
		) -- 93
		self:drawMidForest( -- 94
			bgDraw, -- 94
			bgGlow, -- 94
			w, -- 94
			h, -- 94
			cam, -- 94
			theme, -- 94
			time, -- 94
			seed -- 94
		) -- 94
	else -- 94
		self:drawFarCity( -- 96
			bgDraw, -- 96
			bgGlow, -- 96
			w, -- 96
			h, -- 96
			cam, -- 96
			theme, -- 96
			seed -- 96
		) -- 96
		self:drawMidArchitecture( -- 97
			bgDraw, -- 97
			bgGlow, -- 97
			w, -- 97
			h, -- 97
			cam, -- 97
			theme, -- 97
			time, -- 97
			seed -- 97
		) -- 97
	end -- 97
	if theme.showSearchlights then -- 97
		self:drawSearchlights( -- 100
			bgGlow, -- 100
			w, -- 100
			h, -- 100
			cam, -- 100
			theme, -- 100
			time, -- 100
			seed -- 100
		) -- 100
	end -- 100
	if theme.showTowerBeacon then -- 100
		self:drawDistantNorthTower( -- 103
			bgDraw, -- 103
			bgGlow, -- 103
			w, -- 103
			h, -- 103
			cam, -- 103
			p, -- 103
			time -- 103
		) -- 103
	end -- 103
	local fogH = h * 0.38 -- 107
	fillVGradRect( -- 108
		bgGlow, -- 109
		0, -- 110
		cam.groundScreenY - 10, -- 111
		w, -- 112
		fogH, -- 113
		toColor(theme.fogBottom), -- 114
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 115
	) -- 115
end -- 49
function StageRenderer.prototype.drawDressing(self, assets, p, cam, progress) -- 119
	local w = cam.viewW -- 120
	local ground = cam.groundScreenY -- 121
	local x = w * (0.75 - progress * 0.29) -- 122
	if p.room.key == "forest" or p.room.key == "outside" or p.room.key == "tower" then -- 122
		assets:tryPlace( -- 124
			"pine", -- 124
			"mid_pine", -- 124
			x, -- 124
			ground - cam:len(12), -- 124
			cam:len(124), -- 124
			cam:len(138), -- 124
			{layer = 1, opacity = 0.52} -- 125
		) -- 125
	elseif p.room.key == "prologue" or p.room.key == "village" or p.room.key == "checkpoint" then -- 125
		assets:tryPlace( -- 127
			"eaves", -- 127
			"mid_eaves", -- 127
			x, -- 127
			ground - cam:len(8), -- 127
			cam:len(186), -- 127
			cam:len(104), -- 127
			{layer = 1, opacity = 0.46} -- 128
		) -- 128
	else -- 128
		assets:tryPlace( -- 130
			"cover_stone", -- 130
			"mid_ruin", -- 130
			x, -- 130
			ground - cam:len(8), -- 130
			cam:len(140), -- 130
			cam:len(48), -- 130
			{layer = 1, opacity = 0.46} -- 131
		) -- 131
	end -- 131
	if p.room.key == "street" or p.room.key == "checkpoint" or p.room.key == "prologue" then -- 131
		assets:tryPlace( -- 134
			"prop_lantern", -- 134
			"mid_lantern", -- 134
			w * (0.27 - progress * 0.21), -- 134
			ground + cam:len(92), -- 135
			cam:len(22), -- 135
			cam:len(30), -- 135
			{layer = 2, opacity = 0.82} -- 135
		) -- 135
	end -- 135
end -- 119
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 140
	local theme = themeOf("checkpoint") -- 147
	local splitY = h * 0.44 -- 148
	fillVGradRect( -- 149
		bgDraw, -- 149
		0, -- 149
		splitY, -- 149
		w, -- 149
		h - splitY, -- 149
		toColor(theme.skyMid), -- 149
		toColor(theme.skyTop) -- 149
	) -- 149
	fillVGradRect( -- 150
		bgDraw, -- 150
		0, -- 150
		0, -- 150
		w, -- 150
		splitY, -- 150
		toColor(theme.skyHorizon), -- 150
		toColor(theme.skyMid) -- 150
	) -- 150
	local mx = w * 0.61 -- 153
	local my = h * 0.74 -- 154
	local mr = h * 0.082 -- 155
	fillRadialGlow( -- 156
		bgGlow, -- 156
		mx, -- 156
		my, -- 156
		mr * 5.2, -- 156
		mr * 5.2, -- 156
		Color(86, 210, 255, 34), -- 156
		Color(10, 24, 52, 0), -- 156
		24 -- 156
	) -- 156
	fillRadialGlow( -- 157
		bgGlow, -- 157
		mx, -- 157
		my, -- 157
		mr * 2.1, -- 157
		mr * 2.1, -- 157
		Color(190, 240, 255, 76), -- 157
		Color(40, 120, 190, 0), -- 157
		20 -- 157
	) -- 157
	bgDraw:drawCircle( -- 158
		Vec2(mx, my), -- 158
		mr, -- 158
		Color(228, 242, 255, 235) -- 158
	) -- 158
	bgDraw:drawCircle( -- 159
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 159
		mr * 0.86, -- 159
		Color(10, 18, 34, 125) -- 159
	) -- 159
	local s = 0 -- 162
	do -- 162
		s = 0 -- 163
		while s < 3 do -- 163
			local bx = w * (0.36 + s * 0.24) -- 164
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 165
			local ang = math.pi * 0.5 + sway - 0.12 -- 166
			local len = h * 1.15 -- 167
			local spread = 0.085 + s * 0.015 -- 168
			local x1 = bx + math.cos(ang - spread) * len -- 169
			local y1 = math.sin(ang - spread) * len -- 170
			local x2 = bx + math.cos(ang + spread) * len -- 171
			local y2 = math.sin(ang + spread) * len -- 172
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 173
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 174
			bgGlow:drawVertices({ -- 175
				{ -- 176
					Vec2(bx, h * 0.15), -- 176
					baseCol -- 176
				}, -- 176
				{ -- 177
					Vec2(x1, y1), -- 177
					tipCol -- 177
				}, -- 177
				{ -- 178
					Vec2(x2, y2), -- 178
					tipCol -- 178
				} -- 178
			}) -- 178
			s = s + 1 -- 163
		end -- 163
	end -- 163
	local groundY = h * 0.19 -- 183
	local i = 0 -- 184
	do -- 184
		i = 0 -- 185
		while i < 16 do -- 185
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 186
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 187
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 188
			local cut = 12 + hash01(i * 19) * 20 -- 189
			bgDraw:drawPolygon( -- 190
				{ -- 190
					Vec2(bx, groundY), -- 191
					Vec2(bx + bw, groundY), -- 192
					Vec2(bx + bw, groundY + bh - cut), -- 193
					Vec2(bx + bw - cut, groundY + bh), -- 194
					Vec2(bx, groundY + bh) -- 195
				}, -- 195
				Color(10, 16, 28, 255) -- 196
			) -- 196
			if hash01(i * 41 + 5) > 0.45 then -- 196
				local wy = groundY + bh * 0.65 -- 199
				bgGlow:drawSegment( -- 200
					Vec2(bx + 10, wy), -- 200
					Vec2(bx + bw - 14, wy), -- 200
					1.2, -- 200
					Color(72, 224, 255, 95) -- 200
				) -- 200
			end -- 200
			i = i + 1 -- 185
		end -- 185
	end -- 185
	local tx = w * 0.83 -- 205
	local ty0 = groundY -- 206
	local ty1 = h * 0.62 -- 207
	bgDraw:drawPolygon( -- 208
		{ -- 208
			Vec2(tx - 26, ty0), -- 209
			Vec2(tx + 26, ty0), -- 210
			Vec2(tx + 11, ty1), -- 211
			Vec2(tx - 11, ty1) -- 212
		}, -- 212
		Color(15, 24, 40, 255), -- 213
		1.2, -- 213
		Color(58, 86, 118, 140) -- 213
	) -- 213
	bgDraw:drawSegment( -- 214
		Vec2(tx, ty0 + 24), -- 214
		Vec2(tx, ty1 - 12), -- 214
		1.4, -- 214
		Color(242, 188, 96, 85) -- 214
	) -- 214
	bgDraw:drawSegment( -- 215
		Vec2(tx, ty1), -- 215
		Vec2(tx, ty1 + 42), -- 215
		2.2, -- 215
		Color(165, 212, 248, 210) -- 215
	) -- 215
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 216
	fillRadialGlow( -- 217
		bgGlow, -- 217
		tx, -- 217
		ty1 + 42, -- 217
		74 * pulse, -- 217
		74 * pulse, -- 217
		Color(255, 222, 146, 130), -- 217
		Color(255, 180, 90, 0), -- 217
		20 -- 217
	) -- 217
	bgGlow:drawDot( -- 218
		Vec2(tx, ty1 + 42), -- 218
		5, -- 218
		Color(255, 248, 224, 255) -- 218
	) -- 218
	fillVGradRect( -- 221
		bgDraw, -- 221
		0, -- 221
		0, -- 221
		w, -- 221
		groundY, -- 221
		Color(6, 9, 16, 255), -- 221
		Color(16, 24, 38, 255) -- 221
	) -- 221
	bgDraw:drawSegment( -- 222
		Vec2(0, groundY), -- 222
		Vec2(w, groundY), -- 222
		2, -- 222
		Color(76, 220, 255, 180) -- 222
	) -- 222
	fillVGradRect( -- 223
		bgGlow, -- 223
		0, -- 223
		groundY, -- 223
		w, -- 223
		h * 0.24, -- 223
		Color(42, 130, 182, 52), -- 223
		Color(20, 60, 100, 0) -- 223
	) -- 223
	local sx = w * 0.64 -- 226
	fillRadialGlow( -- 227
		bgGlow, -- 227
		sx + 38, -- 227
		groundY + 75, -- 227
		128, -- 227
		92, -- 227
		Color(52, 178, 232, 42), -- 227
		Color(20, 60, 110, 0), -- 227
		18 -- 227
	) -- 227
	bgDraw:drawPolygon( -- 229
		{ -- 229
			Vec2(sx - 36, groundY + 12), -- 230
			Vec2(sx + 10, groundY + 18), -- 231
			Vec2(sx + 16, groundY + 124), -- 232
			Vec2(sx - 18, groundY + 124) -- 233
		}, -- 233
		Color(10, 16, 28, 255), -- 234
		1.3, -- 234
		Color(76, 210, 255, 145) -- 234
	) -- 234
	bgDraw:drawSegment( -- 235
		Vec2(sx - 6, groundY + 48), -- 235
		Vec2(sx - 12, groundY + 2), -- 235
		6, -- 235
		Color(10, 16, 28, 255) -- 235
	) -- 235
	bgDraw:drawSegment( -- 236
		Vec2(sx + 6, groundY + 48), -- 236
		Vec2(sx + 14, groundY + 2), -- 236
		6, -- 236
		Color(14, 22, 36, 255) -- 236
	) -- 236
	bgDraw:drawPolygon( -- 237
		{ -- 237
			Vec2(sx - 20, groundY + 120), -- 238
			Vec2(sx + 20, groundY + 122), -- 239
			Vec2(sx + 16, groundY + 132), -- 240
			Vec2(sx - 16, groundY + 130) -- 241
		}, -- 241
		Color(208, 236, 252, 240) -- 242
	) -- 242
	bgDraw:drawCircle( -- 243
		Vec2(sx + 2, groundY + 146), -- 243
		13, -- 243
		Color(14, 22, 36, 255) -- 243
	) -- 243
	bgDraw:drawArc( -- 244
		Vec2(sx + 2, groundY + 146), -- 244
		13.5, -- 244
		30, -- 244
		165, -- 244
		2, -- 244
		Color(216, 240, 255, 230) -- 244
	) -- 244
	bgGlow:drawSegment( -- 245
		Vec2(sx + 4, groundY + 148), -- 245
		Vec2(sx + 17, groundY + 150), -- 245
		2.6, -- 245
		Color(86, 240, 255, 255) -- 245
	) -- 245
	bgDraw:drawSegment( -- 246
		Vec2(sx + 4, groundY + 104), -- 246
		Vec2(sx + 46, groundY + 94), -- 246
		3.4, -- 246
		Color(34, 52, 74, 255) -- 246
	) -- 246
	bgGlow:drawSegment( -- 247
		Vec2(sx + 16, groundY + 102), -- 247
		Vec2(sx + 44, groundY + 95), -- 247
		1.2, -- 247
		Color(86, 236, 255, 200) -- 247
	) -- 247
	local cx = w * 0.725 -- 250
	bgDraw:drawPolygon( -- 251
		{ -- 251
			Vec2(cx - 20, groundY + 14), -- 252
			Vec2(cx + 18, groundY + 14), -- 253
			Vec2(cx + 12, groundY + 84), -- 254
			Vec2(cx - 12, groundY + 84) -- 255
		}, -- 255
		Color(188, 142, 78, 238), -- 256
		1.4, -- 256
		Color(252, 232, 192, 225) -- 256
	) -- 256
	bgDraw:drawSegment( -- 257
		Vec2(cx - 5, groundY + 24), -- 257
		Vec2(cx - 6, groundY + 2), -- 257
		4.2, -- 257
		Color(28, 24, 30, 255) -- 257
	) -- 257
	bgDraw:drawSegment( -- 258
		Vec2(cx + 5, groundY + 24), -- 258
		Vec2(cx + 6, groundY + 2), -- 258
		4.2, -- 258
		Color(38, 32, 38, 255) -- 258
	) -- 258
	bgDraw:drawCircle( -- 259
		Vec2(cx + 1, groundY + 95), -- 259
		11, -- 259
		Color(238, 220, 194, 250) -- 259
	) -- 259
	bgDraw:drawPolygon( -- 260
		{ -- 260
			Vec2(cx - 15, groundY + 84), -- 261
			Vec2(cx - 10, groundY + 108), -- 262
			Vec2(cx + 6, groundY + 107), -- 263
			Vec2(cx - 4, groundY + 84) -- 264
		}, -- 264
		Color(156, 114, 62, 245) -- 265
	) -- 265
	bgGlow:drawSegment( -- 266
		Vec2(cx - 8, groundY + 82), -- 266
		Vec2(cx - 30, groundY + 64), -- 266
		2.8, -- 266
		Color(252, 230, 178, 220) -- 266
	) -- 266
	fillRadialGlow( -- 267
		bgGlow, -- 267
		cx + 10, -- 267
		groundY + 56, -- 267
		30, -- 267
		30, -- 267
		Color(255, 214, 130, 115), -- 267
		Color(250, 180, 70, 0), -- 267
		16 -- 267
	) -- 267
	bgGlow:drawDot( -- 268
		Vec2(cx + 10, groundY + 56), -- 268
		3.2, -- 268
		Color(255, 246, 220, 255) -- 268
	) -- 268
end -- 140
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 272
	local theme = themeOf(p.room.key) -- 282
	self:drawFloors( -- 283
		fgDraw, -- 283
		assets, -- 283
		p, -- 283
		cam, -- 283
		theme -- 283
	) -- 283
	self:drawStairs( -- 284
		fgDraw, -- 284
		fgGlow, -- 284
		assets, -- 284
		p, -- 284
		cam, -- 284
		theme -- 284
	) -- 284
	self:drawSolids( -- 285
		fgDraw, -- 285
		fgGlow, -- 285
		assets, -- 285
		p, -- 285
		cam, -- 285
		theme, -- 285
		time, -- 285
		occlusion, -- 285
		fadeDt -- 285
	) -- 285
	if p.room.key == "gate" then -- 285
		self:drawGateShutter( -- 287
			fgDraw, -- 287
			fgGlow, -- 287
			assets, -- 287
			p, -- 287
			cam, -- 287
			time -- 287
		) -- 287
	end -- 287
	self:drawArch( -- 289
		fgDraw, -- 289
		fgGlow, -- 289
		p, -- 289
		cam, -- 289
		theme -- 289
	) -- 289
end -- 272
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 293
	local seed = roomSeed(p.room.key) -- 300
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 302
	local span = 520 -- 303
	local startIdx = math.floor((-parallax - 200) / span) -- 304
	local idx = startIdx -- 305
	do -- 305
		idx = startIdx -- 306
		while idx <= startIdx + 4 do -- 306
			local x = idx * span + parallax -- 307
			local r = hash01(seed + idx * 17) -- 308
			local bw = 70 + r * 90 -- 309
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 310
			fgDraw:drawPolygon( -- 311
				{ -- 311
					Vec2(x, 0), -- 312
					Vec2(x + bw, 0), -- 313
					Vec2(x + bw - 18, bh), -- 314
					Vec2(x + 12, bh * 0.72) -- 315
				}, -- 315
				Color(4, 6, 11, 225) -- 316
			) -- 316
			idx = idx + 1 -- 306
		end -- 306
	end -- 306
	fillVGradRect( -- 320
		fgDraw, -- 320
		0, -- 320
		h - h * 0.16, -- 320
		w, -- 320
		h * 0.16, -- 320
		Color(4, 6, 12, 0), -- 320
		Color(4, 6, 12, 138) -- 320
	) -- 320
	fillVGradRect( -- 321
		fgDraw, -- 321
		0, -- 321
		0, -- 321
		w, -- 321
		h * 0.13, -- 321
		Color(4, 6, 12, 185), -- 321
		Color(4, 6, 12, 0) -- 321
	) -- 321
end -- 293
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 324
	local count = 3 -- 333
	local i = 0 -- 334
	do -- 334
		i = 0 -- 335
		while i < count do -- 335
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 336
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 337
			local by = cam.groundScreenY * 0.85 -- 338
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 339
			local ang = math.pi * 0.5 + sway -- 340
			local len = h * 1.15 -- 341
			local halfSpread = 0.065 + i % 2 * 0.025 -- 342
			local x1 = bx + math.cos(ang - halfSpread) * len -- 343
			local y1 = by + math.sin(ang - halfSpread) * len -- 344
			local x2 = bx + math.cos(ang + halfSpread) * len -- 345
			local y2 = by + math.sin(ang + halfSpread) * len -- 346
			local c0 = toColor(theme.beamColor) -- 347
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 348
			bgGlow:drawVertices({ -- 349
				{ -- 350
					Vec2(bx, by), -- 350
					c0 -- 350
				}, -- 350
				{ -- 351
					Vec2(x1, y1), -- 351
					c1 -- 351
				}, -- 351
				{ -- 352
					Vec2(x2, y2), -- 352
					c1 -- 352
				} -- 352
			}) -- 352
			i = i + 1 -- 335
		end -- 335
	end -- 335
end -- 324
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 357
	local baseY = cam.groundScreenY - 8 -- 366
	local shift = -cam.x * 0.2 * cam.ppu -- 367
	local colW = 108 -- 368
	local first = math.floor((-shift - colW) / colW) -- 369
	local count = math.ceil(w / colW) + 3 -- 370
	local i = 0 -- 371
	do -- 371
		i = 0 -- 372
		while i < count do -- 372
			local idx = first + i -- 373
			local r1 = hash01(seed + idx * 13.7) -- 374
			local r2 = hash01(seed + idx * 29.3) -- 375
			local r3 = hash01(seed + idx * 47.1) -- 376
			local x = idx * colW + shift -- 377
			local bw = colW * (0.68 + r1 * 0.44) -- 378
			local bh = h * (0.18 + r2 * 0.38) -- 379
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 380
			bgDraw:drawPolygon( -- 382
				{ -- 382
					Vec2(x, baseY), -- 383
					Vec2(x + bw, baseY), -- 384
					Vec2(x + bw, baseY + bh - cut), -- 385
					Vec2(x + bw - cut, baseY + bh), -- 386
					Vec2(x, baseY + bh) -- 387
				}, -- 387
				toColor(theme.farBuilding) -- 388
			) -- 388
			if r3 > 0.62 then -- 388
				local ax = x + bw * 0.25 -- 392
				bgDraw:drawSegment( -- 393
					Vec2(ax, baseY + bh), -- 393
					Vec2(ax, baseY + bh + 32), -- 393
					1.2, -- 393
					toColor(theme.farBuilding) -- 393
				) -- 393
				if r1 > 0.6 then -- 393
					bgGlow:drawDot( -- 395
						Vec2(ax, baseY + bh + 32), -- 395
						2.2, -- 395
						toColor(theme.accent, 145) -- 395
					) -- 395
				end -- 395
			end -- 395
			if r2 > 0.55 then -- 395
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 400
				bgGlow:drawSegment( -- 401
					Vec2(x + 12, wy), -- 401
					Vec2(x + bw - 14, wy), -- 401
					1.1, -- 401
					toColor(theme.accent, 64) -- 401
				) -- 401
			end -- 401
			i = i + 1 -- 372
		end -- 372
	end -- 372
end -- 357
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 406
	local baseY = cam.groundScreenY - 8 -- 414
	local shift = -cam.x * 0.22 * cam.ppu -- 415
	local step = 76 -- 416
	local first = math.floor((-shift - step) / step) -- 417
	local count = math.ceil(w / step) + 4 -- 418
	local i = 0 -- 419
	do -- 419
		i = 0 -- 420
		while i < count do -- 420
			local idx = first + i -- 421
			local r1 = hash01(seed + idx * 11.3) -- 422
			local r2 = hash01(seed + idx * 23.9) -- 423
			local cx = idx * step + shift -- 424
			local tw = 34 + r1 * 38 -- 425
			local th = h * (0.24 + r2 * 0.34) -- 426
			bgDraw:drawPolygon( -- 428
				{ -- 428
					Vec2(cx - tw, baseY), -- 429
					Vec2(cx + tw, baseY), -- 430
					Vec2(cx, baseY + th) -- 431
				}, -- 431
				toColor(theme.farBuilding) -- 432
			) -- 432
			bgDraw:drawPolygon( -- 433
				{ -- 433
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 434
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 435
					Vec2(cx, baseY + th * 1.12) -- 436
				}, -- 436
				toColor(theme.farBuilding) -- 437
			) -- 437
			i = i + 1 -- 420
		end -- 420
	end -- 420
end -- 406
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 441
	local baseY = cam.groundScreenY - 4 -- 451
	local shift = -cam.x * 0.48 * cam.ppu -- 452
	local bay = 240 -- 453
	local first = math.floor((-shift - bay) / bay) -- 454
	local count = math.ceil(w / bay) + 3 -- 455
	local col = toColor(theme.midBuilding) -- 456
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 457
	local i = 0 -- 459
	do -- 459
		i = 0 -- 460
		while i < count do -- 460
			local idx = first + i -- 461
			local r = hash01(seed + idx * 37.3) -- 462
			local x = idx * bay + shift -- 463
			local colH = h * (0.34 + r * 0.24) -- 464
			local pw = 22 + r * 16 -- 465
			bgDraw:drawRect( -- 468
				Rect(x, baseY, pw, colH), -- 468
				col -- 468
			) -- 468
			bgDraw:drawSegment( -- 469
				Vec2(x + pw, baseY), -- 469
				Vec2(x + pw, baseY + colH), -- 469
				1, -- 469
				edge -- 469
			) -- 469
			if r > 0.35 then -- 469
				local beamY = baseY + colH * 0.76 -- 471
				bgDraw:drawSegment( -- 472
					Vec2(x + pw, beamY), -- 472
					Vec2(x + bay, beamY), -- 472
					4, -- 472
					col -- 472
				) -- 472
				bgDraw:drawSegment( -- 473
					Vec2(x + pw, beamY - 22), -- 473
					Vec2(x + bay * 0.5, beamY), -- 473
					1.4, -- 473
					edge -- 473
				) -- 473
				bgDraw:drawSegment( -- 474
					Vec2(x + bay * 0.5, beamY), -- 474
					Vec2(x + bay, beamY - 22), -- 474
					1.4, -- 474
					edge -- 474
				) -- 474
			end -- 474
			bgDraw:drawQuadraticBezier( -- 478
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 479
				Vec2( -- 480
					x + bay * 0.5, -- 480
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 480
				), -- 480
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 481
				1, -- 482
				Color(12, 18, 28, 180) -- 483
			) -- 483
			if idx & 1 == 0 then -- 483
				local lx = x + bay * 0.52 -- 488
				local ly = baseY + h * 0.31 -- 489
				bgDraw:drawSegment( -- 490
					Vec2(lx, baseY), -- 490
					Vec2(lx, ly), -- 490
					2.2, -- 490
					col -- 490
				) -- 490
				bgDraw:drawSegment( -- 491
					Vec2(lx, ly), -- 491
					Vec2(lx + 18, ly - 4), -- 491
					2, -- 491
					col -- 491
				) -- 491
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 492
				local lc = theme.accent -- 493
				bgGlow:drawDot( -- 494
					Vec2(lx + 18, ly - 5), -- 494
					3.2, -- 494
					toColor(lc, 210 * flicker) -- 494
				) -- 494
				fillRadialGlow( -- 495
					bgGlow, -- 495
					lx + 18, -- 495
					ly - 5, -- 495
					36, -- 495
					36, -- 495
					toColor(lc, 54 * flicker), -- 495
					Color(lc.r, lc.g, lc.b, 0), -- 495
					14 -- 495
				) -- 495
				bgGlow:drawVertices({ -- 496
					{ -- 497
						Vec2(lx + 18, ly - 6), -- 497
						toColor(lc, 38 * flicker) -- 497
					}, -- 497
					{ -- 498
						Vec2(lx - 42, baseY), -- 498
						Color(lc.r, lc.g, lc.b, 0) -- 498
					}, -- 498
					{ -- 499
						Vec2(lx + 78, baseY), -- 499
						Color(lc.r, lc.g, lc.b, 0) -- 499
					} -- 499
				}) -- 499
			end -- 499
			i = i + 1 -- 460
		end -- 460
	end -- 460
end -- 441
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 505
	local baseY = cam.groundScreenY - 4 -- 515
	local shift = -cam.x * 0.52 * cam.ppu -- 516
	local span = 156 -- 517
	local first = math.floor((-shift - span) / span) -- 518
	local count = math.ceil(w / span) + 3 -- 519
	local col = toColor(theme.midBuilding) -- 520
	local i = 0 -- 522
	do -- 522
		i = 0 -- 523
		while i < count do -- 523
			local idx = first + i -- 524
			local r = hash01(seed + idx * 19.7) -- 525
			local x = idx * span + shift -- 526
			local trunkW = 14 + r * 14 -- 527
			local sway = math.sin(time * 0.9 + idx) * 4 -- 528
			bgDraw:drawPolygon( -- 529
				{ -- 529
					Vec2(x - trunkW * 0.5, baseY), -- 530
					Vec2(x + trunkW * 0.5, baseY), -- 531
					Vec2(x + trunkW * 0.25 + sway, h), -- 532
					Vec2(x - trunkW * 0.3 + sway, h) -- 533
				}, -- 533
				col -- 534
			) -- 534
			if idx % 3 == 0 then -- 534
				bgGlow:drawVertices({ -- 537
					{ -- 538
						Vec2(x + 40, h), -- 538
						Color(110, 232, 200, 26) -- 538
					}, -- 538
					{ -- 539
						Vec2(x + 115, h), -- 539
						Color(110, 232, 200, 0) -- 539
					}, -- 539
					{ -- 540
						Vec2(x - 60, baseY), -- 540
						Color(110, 232, 200, 0) -- 540
					} -- 540
				}) -- 540
			end -- 540
			i = i + 1 -- 523
		end -- 523
	end -- 523
end -- 505
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 546
	local scale = 0.55 -- 556
	if p.room.key == "village" then -- 556
		scale = 0.72 -- 558
	elseif p.room.key == "forest" then -- 558
		scale = 0.92 -- 560
	elseif p.room.key == "tower" then -- 560
		scale = 1.15 -- 562
	end -- 562
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 564
	local baseY = cam.groundScreenY - 8 -- 565
	local towerH = h * 0.42 * scale -- 566
	local bw = 20 * scale -- 567
	bgDraw:drawPolygon( -- 568
		{ -- 568
			Vec2(tx - bw, baseY), -- 569
			Vec2(tx + bw, baseY), -- 570
			Vec2(tx + bw * 0.45, baseY + towerH), -- 571
			Vec2(tx - bw * 0.45, baseY + towerH) -- 572
		}, -- 572
		Color(14, 24, 38, 240) -- 573
	) -- 573
	bgDraw:drawSegment( -- 574
		Vec2(tx, baseY + towerH), -- 574
		Vec2(tx, baseY + towerH + 28 * scale), -- 574
		1.8, -- 574
		Color(180, 210, 238, 200) -- 574
	) -- 574
	local topY = baseY + towerH + 24 * scale -- 576
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 577
	fillRadialGlow( -- 578
		bgGlow, -- 578
		tx, -- 578
		topY, -- 578
		56 * scale * pulse, -- 578
		56 * scale * pulse, -- 578
		Color(255, 224, 152, 118), -- 578
		Color(255, 190, 96, 0), -- 578
		18 -- 578
	) -- 578
	bgGlow:drawDot( -- 579
		Vec2(tx, topY), -- 579
		3.6 * scale, -- 579
		Color(255, 246, 220, 255) -- 579
	) -- 579
end -- 546
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 582
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 589
	do -- 589
		local i = 0 -- 590
		while i < #p.room.floors do -- 590
			local floor = p.room.floors[i + 1] -- 591
			local left = cam:sx(floor.x0) -- 592
			local right = cam:sx(floor.x1) -- 593
			local isMain = floor.y <= 0.1 -- 594
			local ____isMain_0 -- 595
			if isMain then -- 595
				____isMain_0 = p.room.depth -- 595
			else -- 595
				____isMain_0 = nil -- 595
			end -- 595
			local road = ____isMain_0 -- 595
			local top = cam:sy(floor.y, road and road.min or 0) -- 596
			if road ~= nil then -- 596
				self:drawRoad( -- 598
					fgDraw, -- 598
					assets, -- 598
					i, -- 598
					left, -- 598
					right, -- 598
					top, -- 598
					cam:sy(floor.y, road.max), -- 598
					cam, -- 598
					theme -- 598
				) -- 598
			end -- 598
			local height = cam:len(isMain and 22 or 12) -- 600
			local bottom = top - height -- 601
			if isMain and bottom > 0 then -- 601
				fillVGradRect( -- 603
					fgDraw, -- 603
					left, -- 603
					0, -- 603
					right - left, -- 603
					bottom + 1, -- 603
					toColor(PALETTE.voidDark), -- 604
					toColor(theme.groundBody) -- 604
				) -- 604
			end -- 604
			fgDraw:drawRect( -- 606
				Rect(left, bottom, right - left, height), -- 606
				toColor(PALETTE.steelDark) -- 606
			) -- 606
			local step = cam:len(96) -- 607
			local start = math.max( -- 608
				0, -- 608
				math.floor(-left / step) -- 608
			) -- 608
			do -- 608
				local j = start -- 609
				while left + j * step < math.min(right, cam.viewW) do -- 609
					local x = left + j * step -- 610
					local width = math.min(step, right - x) -- 611
					assets:tryPlace( -- 612
						"slab", -- 612
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 612
						x + width * 0.5, -- 612
						bottom, -- 612
						width, -- 612
						height -- 612
					) -- 612
					if grass and isMain and j % 3 == 1 then -- 612
						assets:tryPlace( -- 614
							"grass_low", -- 614
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 614
							x + width * 0.5, -- 614
							top - cam:len(3), -- 615
							width * 0.74, -- 615
							cam:len(13), -- 615
							{opacity = 0.83, layer = 1} -- 615
						) -- 615
					end -- 615
					j = j + 1 -- 609
				end -- 609
			end -- 609
			fgDraw:drawSegment( -- 618
				Vec2(left, top), -- 618
				Vec2(right, top), -- 618
				1, -- 618
				toColor(theme.groundRim, 140) -- 618
			) -- 618
			i = i + 1 -- 590
		end -- 590
	end -- 590
end -- 582
function StageRenderer.prototype.drawRoad(self, draw, assets, floor, left, right, front, back, cam, theme) -- 622
	local width = right - left -- 627
	local height = back - front -- 628
	fillVGradRect( -- 629
		draw, -- 629
		left, -- 629
		front, -- 629
		width, -- 629
		height, -- 629
		toColor(lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.34)), -- 630
		toColor(lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.36)) -- 631
	) -- 631
	local bands = { -- 632
		0, -- 632
		0.31, -- 632
		0.59, -- 632
		0.82, -- 632
		1 -- 632
	} -- 632
	local edge = toColor(theme.groundRim, 34) -- 633
	do -- 633
		local row = 0 -- 634
		while row < #bands - 1 do -- 634
			local y = front + bands[row + 1] * height -- 635
			local rowHeight = (bands[row + 1 + 1] - bands[row + 1]) * height -- 636
			local slabWidth = cam:len(132 - row * 12) -- 637
			local offset = left - row % 2 * slabWidth * 0.5 -- 638
			local start = math.max( -- 639
				0, -- 639
				math.floor(-offset / slabWidth) -- 639
			) -- 639
			do -- 639
				local column = start -- 640
				while offset + column * slabWidth < math.min(right, cam.viewW) do -- 640
					local tileStart = offset + column * slabWidth -- 641
					local x = math.max(left, tileStart) -- 642
					local w = math.min(right, tileStart + slabWidth) - x -- 643
					if w > 1 then -- 643
						assets:tryPlace( -- 645
							"wall", -- 645
							(((("road_" .. tostring(floor)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 645
							x + w * 0.5, -- 646
							y, -- 646
							w, -- 646
							rowHeight, -- 646
							{ -- 646
								opacity = 0.88 - row * 0.09, -- 647
								facing = (column + row) % 2 == 0 and 1 or -1, -- 648
								color = Color(174 - row * 9, 167 - row * 7, 154 - row * 3, 255) -- 649
							} -- 649
						) -- 649
					end -- 649
					column = column + 1 -- 640
				end -- 640
			end -- 640
			draw:drawSegment( -- 653
				Vec2(left, y), -- 653
				Vec2(right, y), -- 653
				0.8, -- 653
				edge -- 653
			) -- 653
			row = row + 1 -- 634
		end -- 634
	end -- 634
	draw:drawSegment( -- 655
		Vec2(left, back), -- 655
		Vec2(right, back), -- 655
		1.1, -- 655
		toColor(theme.groundRim, 53) -- 655
	) -- 655
end -- 622
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 658
	local i = 0 -- 666
	do -- 666
		i = 0 -- 667
		while i < #p.room.stairs do -- 667
			local st = p.room.stairs[i + 1] -- 668
			local n = st.steps + 1 -- 669
			local stepW = (st.x1 - st.x0) / n -- 670
			local k = 0 -- 671
			do -- 671
				k = 0 -- 672
				while k < n do -- 672
					local wy = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 673
					local wx0 = st.x0 + stepW * k -- 674
					local wx1 = wx0 + stepW -- 675
					local x0 = cam:sx(wx0) -- 676
					local x1 = cam:sx(wx1) -- 677
					local y1 = cam:sy(wy) -- 678
					local y0 = cam:sy(math.max(0, st.y0)) -- 679
					if y1 > y0 + 2 then -- 679
						fgDraw:drawRect( -- 681
							Rect(x0, y0, x1 - x0, y1 - y0), -- 681
							toColor(PALETTE.steelDark, 230) -- 681
						) -- 681
						fgDraw:drawRect( -- 682
							Rect(x0, y1 - 5, x1 - x0, 5), -- 682
							toColor(theme.groundTop) -- 682
						) -- 682
						assets:tryPlace( -- 683
							"wall", -- 683
							(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 683
							(x0 + x1) * 0.5, -- 683
							y0, -- 683
							x1 - x0, -- 684
							y1 - y0, -- 684
							{opacity = 0.78} -- 684
						) -- 684
						assets:tryPlace( -- 685
							"slab", -- 685
							(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 685
							(x0 + x1) * 0.5, -- 685
							y1 - cam:len(5), -- 685
							x1 - x0, -- 686
							cam:len(5), -- 686
							{layer = 1} -- 686
						) -- 686
					end -- 686
					fgDraw:drawSegment( -- 688
						Vec2(x0, y1), -- 688
						Vec2(x1, y1), -- 688
						1.8, -- 688
						toColor(theme.groundRim) -- 688
					) -- 688
					fgGlow:drawSegment( -- 689
						Vec2(x0, y1 + 1), -- 689
						Vec2(x1, y1 + 1), -- 689
						1, -- 689
						toColor(theme.accent, 55) -- 689
					) -- 689
					k = k + 1 -- 672
				end -- 672
			end -- 672
			i = i + 1 -- 667
		end -- 667
	end -- 667
end -- 658
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 694
	local i = 0 -- 705
	do -- 705
		i = 0 -- 706
		while i < #p.room.solids do -- 706
			do -- 706
				local s = p.room.solids[i + 1] -- 707
				local x0 = cam:sx(s.x) -- 708
				local x1 = cam:sx(s.x + s.w) -- 709
				if p.room.depth ~= nil and s.depth ~= nil then -- 709
					local opacity = occlusion:update( -- 711
						"solid_" .. tostring(i), -- 711
						{ -- 711
							x0 = s.x, -- 712
							x1 = s.x + s.w, -- 712
							y0 = s.y, -- 712
							y1 = s.y + s.h, -- 712
							depth = s.depth, -- 713
							passThrough = s.decorative -- 713
						}, -- 713
						p, -- 714
						fadeDt -- 714
					) -- 714
					if x1 > 0 and x0 < cam.viewW then -- 714
						self:drawDepthSolid( -- 716
							fgDraw, -- 716
							assets, -- 716
							s, -- 716
							s.depth, -- 716
							x0, -- 716
							x1, -- 716
							cam, -- 716
							theme, -- 716
							opacity -- 716
						) -- 716
					end -- 716
					goto __continue79 -- 718
				end -- 718
				local y0 = cam:sy(s.y) -- 720
				local y1 = cam:sy(s.y + s.h) -- 721
				local sw = x1 - x0 -- 722
				local sh = y1 - y0 -- 723
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 723
					goto __continue79 -- 725
				end -- 725
				if s.passable == true then -- 725
					if not assets:tryPlace( -- 725
						"grass", -- 730
						"hide_grass_" .. tostring(i), -- 730
						(x0 + x1) * 0.5, -- 730
						y0, -- 730
						sw, -- 730
						sh * 1.55, -- 730
						{opacity = 0.79, layer = 7} -- 731
					) then -- 731
						self:drawGrassCluster( -- 732
							fgDraw, -- 732
							fgGlow, -- 732
							x0, -- 732
							y0, -- 732
							sw, -- 732
							sh, -- 732
							p.player.x, -- 732
							s.x + s.w * 0.5, -- 732
							time -- 732
						) -- 732
					end -- 732
					goto __continue79 -- 734
				end -- 734
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 734
					self:drawWinch( -- 739
						fgDraw, -- 739
						fgGlow, -- 739
						x0, -- 739
						y0, -- 739
						sw, -- 739
						sh, -- 739
						p, -- 739
						time -- 739
					) -- 739
					assets:tryPlace( -- 740
						"prop_winch", -- 740
						"gate_winch", -- 740
						(x0 + x1) * 0.5, -- 740
						y0 + sh * 0.55, -- 740
						sw, -- 740
						sh * 0.78, -- 740
						{layer = 2} -- 741
					) -- 741
					goto __continue79 -- 742
				end -- 742
				if p.room.key == "tower" then -- 742
					self:drawTowerStructure( -- 747
						fgDraw, -- 747
						fgGlow, -- 747
						assets, -- 747
						x0, -- 747
						y0, -- 747
						sw, -- 747
						sh, -- 747
						s, -- 747
						p, -- 747
						time -- 747
					) -- 747
					goto __continue79 -- 748
				end -- 748
				if s.h <= 64 and s.y <= 2 then -- 748
					self:drawCoverBlock( -- 753
						fgDraw, -- 753
						fgGlow, -- 753
						assets, -- 753
						x0, -- 753
						y0, -- 753
						sw, -- 753
						sh, -- 753
						s, -- 753
						p, -- 753
						theme -- 753
					) -- 753
					goto __continue79 -- 754
				end -- 754
				fillVGradRect( -- 757
					fgDraw, -- 757
					x0, -- 757
					y0, -- 757
					sw, -- 757
					sh, -- 757
					toColor(PALETTE.steelDark), -- 757
					toColor(PALETTE.steelMid) -- 757
				) -- 757
				self:tileMasonry( -- 758
					assets, -- 758
					s, -- 758
					x0, -- 758
					y0, -- 758
					sw, -- 758
					sh -- 758
				) -- 758
			end -- 758
			::__continue79:: -- 758
			i = i + 1 -- 706
		end -- 706
	end -- 706
end -- 694
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity) -- 762
	local width = right - left -- 766
	local base = cam:sy(solid.y, depth.min) -- 767
	local top = cam:sy(solid.y + solid.h, depth.min) -- 768
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 769
	local slot = coverArt(solid) -- 770
	local layer = depthOrder(depth.min, 1) -- 771
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 772
	local capHeight = rear - top -- 773
	local center = (left + right) * 0.5 -- 774
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 774
		assets:tryPlace( -- 776
			"slab", -- 776
			"gate_sill_" .. tostring(solid.x), -- 776
			center, -- 776
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 776
			width + cam:len(34), -- 777
			cam:len(12), -- 777
			{ -- 777
				layer = 1, -- 777
				color = Color(180, 169, 150, 255) -- 777
			} -- 777
		) -- 777
	end -- 777
	draw:drawEllipse( -- 779
		Vec2( -- 779
			center, -- 779
			base + cam:len(3) -- 779
		), -- 779
		width * 0.52, -- 779
		cam:len(3.5), -- 780
		Color(13, 12, 16, 123 * opacity) -- 780
	) -- 780
	if slot ~= "fence" and capHeight > 1 then -- 780
		local timber = slot == "cover_wood" -- 782
		draw:drawRect( -- 783
			Rect(left, top, width, capHeight), -- 783
			occlusionTint( -- 783
				opacity, -- 783
				timber and Color(79, 63, 50, 239 * opacity) or Color(76, 78, 85, 239 * opacity) -- 784
			) -- 784
		) -- 784
		assets:tryPlace( -- 785
			timber and "slab" or "wall", -- 785
			key .. "_top", -- 785
			center, -- 785
			top, -- 785
			width, -- 785
			capHeight, -- 785
			{ -- 785
				layer = layer - 1, -- 786
				opacity = opacity * 0.92, -- 787
				color = occlusionTint( -- 788
					opacity, -- 788
					timber and Color(162, 126, 96, 255) or Color(158, 157, 156, 255) -- 788
				) -- 788
			} -- 788
		) -- 788
	end -- 788
	local rows = slot == "wall" and math.max( -- 791
		1, -- 791
		math.ceil(solid.h * 1.25 / solid.w) -- 791
	) or 1 -- 791
	local rowHeight = (top - base) / rows -- 792
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 793
	local color = occlusionTint(opacity, masonryColor) -- 794
	do -- 794
		local row = 0 -- 795
		while row < rows do -- 795
			do -- 795
				local tileKey = row == 0 and key or (key .. "_row_") .. tostring(row) -- 796
				if assets:tryPlace( -- 796
					slot, -- 797
					tileKey, -- 797
					center, -- 797
					base + row * rowHeight, -- 797
					width, -- 797
					rowHeight, -- 797
					{layer = layer, opacity = opacity, color = color, facing = row % 2 == 0 and 1 or -1} -- 797
				) then -- 797
					goto __continue92 -- 800
				end -- 800
				draw:drawRect( -- 802
					Rect(left, base, width, top - base), -- 802
					occlusionTint( -- 803
						opacity, -- 803
						toColor(PALETTE.steelMid, 255 * opacity) -- 803
					), -- 803
					1, -- 804
					toColor(theme.groundRim, 150 * opacity) -- 804
				) -- 804
				break -- 805
			end -- 805
			::__continue92:: -- 805
			row = row + 1 -- 795
		end -- 795
	end -- 795
end -- 762
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 809
	local columns = math.max( -- 813
		1, -- 813
		math.ceil(s.w / 154) -- 813
	) -- 813
	local rows = math.max( -- 814
		1, -- 814
		math.ceil(s.h / 100) -- 814
	) -- 814
	local tileW = width / columns -- 815
	local tileH = height / rows -- 816
	do -- 816
		local row = 0 -- 817
		while row < rows do -- 817
			do -- 817
				local column = 0 -- 818
				while column < columns do -- 818
					assets:tryPlace( -- 819
						"wall", -- 819
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 819
						x + (column + 0.5) * tileW, -- 820
						y + row * tileH, -- 820
						tileW + 0.5, -- 820
						tileH + 0.5, -- 820
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 821
					) -- 821
					column = column + 1 -- 818
				end -- 818
			end -- 818
			row = row + 1 -- 817
		end -- 817
	end -- 817
end -- 809
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 826
	local slot = coverArt(s) -- 833
	if not assets:tryPlace( -- 833
		slot, -- 834
		"cover_" .. tostring(s.x), -- 834
		x0 + sw * 0.5, -- 834
		y0, -- 834
		sw, -- 834
		sh, -- 834
		{layer = 1} -- 834
	) then -- 834
		fillVGradRect( -- 835
			fgDraw, -- 835
			x0, -- 835
			y0, -- 835
			sw, -- 835
			sh, -- 835
			toColor(PALETTE.steelDark), -- 835
			toColor(PALETTE.steelMid) -- 835
		) -- 835
		fgDraw:drawSegment( -- 836
			Vec2(x0, y0 + sh), -- 836
			Vec2(x0 + sw, y0 + sh), -- 836
			1.4, -- 836
			toColor(theme.groundRim) -- 836
		) -- 836
	end -- 836
	if not p.childMode and (p.coverHug or p.coverNear) then -- 836
		local plx = p.player.x -- 841
		local nearLeft = math.abs(plx - s.x) < 42 -- 842
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 843
		if nearLeft or nearRight then -- 843
			local edgeX = nearLeft and x0 - 2 or x0 + sw + 2 -- 845
			local col = p.coverHug and PALETTE.cyan or PALETTE.amber -- 846
			fgGlow:drawSegment( -- 847
				Vec2(edgeX, y0 + 4), -- 847
				Vec2(edgeX, y0 + sh + 4), -- 847
				p.coverHug and 3.5 or 2, -- 847
				toColor(col, p.coverHug and 220 or 140) -- 847
			) -- 847
			if p.coverHug then -- 847
				fillRadialGlow( -- 849
					fgGlow, -- 849
					edgeX, -- 849
					y0 + sh * 0.55, -- 849
					22, -- 849
					sh * 0.7, -- 849
					toColor(PALETTE.cyan, 85), -- 849
					Color(72, 224, 255, 0), -- 849
					14 -- 849
				) -- 849
			end -- 849
		end -- 849
	end -- 849
end -- 826
function StageRenderer.prototype.drawWinch(self, fgDraw, fgGlow, x0, y0, sw, sh, p, time) -- 855
	fillChamferBox( -- 861
		fgDraw, -- 861
		x0, -- 861
		y0, -- 861
		sw, -- 861
		sh, -- 861
		8, -- 861
		toColor(PALETTE.steelMid), -- 861
		1.5, -- 861
		toColor(PALETTE.rimSilver, 180) -- 861
	) -- 861
	local cx = x0 + sw * 0.5 -- 863
	local cy = y0 + sh * 0.55 -- 864
	local r = math.min(sw, sh) * 0.34 -- 865
	local spin = p.phase == "gate-hold" and time * 1.4 or 0 -- 866
	fgDraw:drawRing( -- 867
		Vec2(cx, cy), -- 867
		r * 0.62, -- 867
		r, -- 867
		toColor(PALETTE.steelDark), -- 867
		1.5, -- 867
		toColor(PALETTE.rimSilver, 210) -- 867
	) -- 867
	local k = 0 -- 868
	do -- 868
		k = 0 -- 869
		while k < 6 do -- 869
			local a = spin + k * math.pi / 3 -- 870
			fgDraw:drawSegment( -- 871
				Vec2( -- 872
					cx + math.cos(a) * r * 0.25, -- 872
					cy + math.sin(a) * r * 0.25 -- 872
				), -- 872
				Vec2( -- 873
					cx + math.cos(a) * r * 1.05, -- 873
					cy + math.sin(a) * r * 1.05 -- 873
				), -- 873
				2, -- 874
				toColor(PALETTE.rimSilver, 210) -- 875
			) -- 875
			k = k + 1 -- 869
		end -- 869
	end -- 869
	fgDraw:drawSegment( -- 879
		Vec2(cx, cy + r), -- 879
		Vec2(cx, y0 + sh + 220), -- 879
		1.6, -- 879
		toColor(PALETTE.steelLight, 175) -- 879
	) -- 879
	local active = p.phase == "gate-hold" or p.phase == "gate-send" -- 881
	local lampCol = active and PALETTE.cyan or PALETTE.amber -- 882
	local pulse = 0.7 + 0.3 * math.sin(time * 5) -- 883
	fgGlow:drawDot( -- 884
		Vec2(x0 + sw - 10, y0 + sh - 10), -- 884
		4, -- 884
		toColor(lampCol, 240 * pulse) -- 884
	) -- 884
	fillRadialGlow( -- 885
		fgGlow, -- 885
		x0 + sw - 10, -- 885
		y0 + sh - 10, -- 885
		22, -- 885
		22, -- 885
		toColor(lampCol, 95 * pulse), -- 885
		Color(lampCol.r, lampCol.g, lampCol.b, 0), -- 885
		12 -- 885
	) -- 885
end -- 855
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 888
	local ____temp_3 -- 896
	if p.room.story ~= nil then -- 896
		____temp_3 = p.room.story.gate -- 896
	else -- 896
		____temp_3 = nil -- 896
	end -- 896
	local g = ____temp_3 -- 896
	if g == nil then -- 896
		return -- 898
	end -- 898
	local closeFrac = 0.08 -- 901
	if p.phase == "gate-hold" then -- 901
		closeFrac = 0.08 + 0.36 * math.min( -- 903
			1, -- 903
			p.gateTick / math.max(1, g.holdTicks) -- 903
		) -- 903
	elseif p.phase == "gate-send" then -- 903
		closeFrac = 0.44 -- 905
	elseif p.phase == "gate-count" then -- 905
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 907
	elseif p.phase == "gate-walk" then -- 907
		closeFrac = 1 -- 909
	end -- 909
	local gx0 = cam:sx(848) -- 911
	local gx1 = cam:sx(1032) -- 912
	local topY = cam:sy(160) -- 913
	local botY = cam:sy(160 * (1 - closeFrac)) -- 914
	if topY > botY + 2 then -- 914
		fillVGradRect( -- 916
			fgDraw, -- 916
			gx0, -- 916
			botY, -- 916
			gx1 - gx0, -- 916
			topY - botY, -- 916
			toColor(PALETTE.steelDark), -- 916
			toColor(PALETTE.steelMid) -- 916
		) -- 916
		assets:tryPlace( -- 917
			"cover_wood", -- 917
			"gate_shutter", -- 917
			(gx0 + gx1) * 0.5, -- 917
			botY, -- 917
			gx1 - gx0, -- 918
			topY - botY, -- 918
			{layer = 6} -- 918
		) -- 918
	end -- 918
	if closeFrac < 0.98 then -- 918
		local gapH = math.max( -- 922
			8, -- 922
			botY - cam:sy(0) -- 922
		) -- 922
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 923
		fillVGradRect( -- 924
			fgGlow, -- 924
			gx0, -- 924
			cam:sy(0), -- 924
			gx1 - gx0, -- 924
			gapH, -- 924
			Color( -- 924
				140, -- 924
				210, -- 924
				255, -- 924
				math.floor(52 * pulse + 0.5) -- 924
			), -- 924
			Color(80, 160, 230, 0) -- 924
		) -- 924
	end -- 924
end -- 888
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, time) -- 928
	fillVGradRect( -- 935
		fgDraw, -- 935
		x0, -- 935
		y0, -- 935
		sw, -- 935
		sh, -- 935
		Color(15, 21, 34, 255), -- 935
		Color(32, 44, 66, 255) -- 935
	) -- 935
	fgDraw:drawRect( -- 936
		Rect(x0, y0, sw, sh), -- 936
		Color(0, 0, 0, 0), -- 936
		1.4, -- 936
		toColor(PALETTE.rimSilver, 165) -- 936
	) -- 936
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 936
		self:tileMasonry( -- 939
			assets, -- 939
			s, -- 939
			x0, -- 939
			y0, -- 939
			sw, -- 939
			sh -- 939
		) -- 939
		local ribs = 4 -- 941
		local r = 1 -- 942
		do -- 942
			r = 1 -- 943
			while r < ribs do -- 943
				local rx = x0 + sw * r / ribs -- 944
				fgDraw:drawSegment( -- 945
					Vec2(rx, y0), -- 945
					Vec2(rx, y0 + sh), -- 945
					2, -- 945
					Color(10, 15, 24, 210) -- 945
				) -- 945
				fgDraw:drawSegment( -- 946
					Vec2(rx + 2, y0), -- 946
					Vec2(rx + 2, y0 + sh), -- 946
					1, -- 946
					Color(68, 86, 114, 130) -- 946
				) -- 946
				r = r + 1 -- 943
			end -- 943
		end -- 943
		local bands = 4 -- 949
		local b = 1 -- 950
		do -- 950
			b = 1 -- 951
			while b < bands do -- 951
				local by = y0 + sh * b / bands -- 952
				fgDraw:drawSegment( -- 953
					Vec2(x0 + 4, by), -- 953
					Vec2(x0 + sw - 4, by), -- 953
					1.2, -- 953
					Color(52, 68, 92, 135) -- 953
				) -- 953
				b = b + 1 -- 951
			end -- 951
		end -- 951
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 956
		local slitY = y0 + sh * 0.56 -- 957
		local slitH = sh * 0.22 -- 958
		fgDraw:drawRect( -- 959
			Rect(slitX - 5, slitY, 10, slitH), -- 959
			Color(8, 12, 20, 245), -- 959
			1.2, -- 959
			toColor(PALETTE.amberDim, 190) -- 959
		) -- 959
		fgGlow:drawRect( -- 960
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 960
			toColor(PALETTE.amber, 190) -- 960
		) -- 960
		fillRadialGlow( -- 961
			fgGlow, -- 961
			slitX, -- 961
			slitY + slitH * 0.5, -- 961
			44, -- 961
			slitH * 0.7, -- 961
			Color(255, 206, 128, 52), -- 961
			Color(255, 180, 86, 0), -- 961
			14 -- 961
		) -- 961
	end -- 961
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 961
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 966
		local cx = x0 + sw * 0.5 -- 967
		local lampY = y0 - 8 -- 968
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 969
		if not opened then -- 969
			assets:tryPlace( -- 971
				"prop_tower_door", -- 971
				"tower_door", -- 971
				cx, -- 971
				y0 - doorHeight, -- 971
				sw, -- 971
				doorHeight, -- 971
				{layer = 2} -- 971
			) -- 971
		end -- 971
		assets:tryPlace( -- 973
			"prop_lantern", -- 973
			"tower_lantern", -- 973
			cx + sw * 0.43, -- 973
			lampY - sh * 0.36, -- 973
			sw * 0.17, -- 974
			sh * 0.84, -- 974
			{layer = 3} -- 974
		) -- 974
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 975
		local alpha = opened and 155 or 88 -- 976
		fgDraw:drawSegment( -- 978
			Vec2(x0 + 4, y0), -- 978
			Vec2(x0 + 4, y0 - sh * 3.8), -- 978
			4, -- 978
			Color(42, 52, 70, 255) -- 978
		) -- 978
		fgDraw:drawSegment( -- 979
			Vec2(x0 + sw - 4, y0), -- 979
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 979
			4, -- 979
			Color(42, 52, 70, 255) -- 979
		) -- 979
		fgDraw:drawSegment( -- 980
			Vec2(x0, y0), -- 980
			Vec2(x0 + sw, y0), -- 980
			2.5, -- 980
			toColor(PALETTE.amber, 210) -- 980
		) -- 980
		fillVGradRect( -- 982
			fgGlow, -- 983
			x0 + 6, -- 984
			y0 - sh * 3.8, -- 985
			sw - 12, -- 986
			sh * 3.8, -- 987
			Color( -- 988
				255, -- 988
				206, -- 988
				128, -- 988
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 988
			), -- 988
			Color(255, 224, 168, opened and 180 or 62) -- 989
		) -- 989
		fillRadialGlow( -- 991
			fgGlow, -- 991
			cx, -- 991
			lampY, -- 991
			opened and 105 or 58, -- 991
			opened and 105 or 58, -- 991
			Color( -- 991
				255, -- 991
				232, -- 991
				178, -- 991
				math.floor(170 * pulse + 0.5) -- 991
			), -- 991
			Color(255, 180, 86, 0), -- 991
			18 -- 991
		) -- 991
		fgDraw:drawCircle( -- 992
			Vec2(cx, lampY), -- 992
			5.5, -- 992
			toColor(PALETTE.amberCore) -- 992
		) -- 992
	end -- 992
end -- 928
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 996
	local blades = math.max( -- 1003
		12, -- 1003
		math.floor(sw / 8) -- 1003
	) -- 1003
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1004
	local k = 0 -- 1005
	do -- 1005
		k = 0 -- 1006
		while k < blades do -- 1006
			local t = (k + 0.5) / blades -- 1007
			local bx = x0 + sw * t -- 1008
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1009
			local bh = sh * hRatio * 1.95 -- 1010
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1011
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1012
			fgDraw:drawPolygon( -- 1013
				{ -- 1013
					Vec2(bx - 7, y0), -- 1014
					Vec2(bx + 7, y0), -- 1015
					Vec2(bx + sway, y0 + bh) -- 1016
				}, -- 1016
				col -- 1017
			) -- 1017
			k = k + 1 -- 1006
		end -- 1006
	end -- 1006
	if nearPlayer then -- 1006
		fgGlow:drawSegment( -- 1020
			Vec2(x0, y0 + 2), -- 1020
			Vec2(x0 + sw, y0 + 2), -- 1020
			2, -- 1020
			toColor(PALETTE.emerald, 145) -- 1020
		) -- 1020
	end -- 1020
end -- 996
function StageRenderer.prototype.drawArch(self, fgDraw, fgGlow, p, cam, theme) -- 1024
	local a = p.room.arch -- 1031
	if a.h <= 0 or a.x1 <= a.x0 then -- 1031
		return -- 1033
	end -- 1033
	local x0 = cam:sx(a.x0) -- 1035
	local x1 = cam:sx(a.x1) -- 1036
	local y0 = cam:sy(a.y) -- 1037
	local y1 = cam:sy(a.y + a.h) -- 1038
	local aw = x1 - x0 -- 1039
	local ah = y1 - y0 -- 1040
	fgDraw:drawRect( -- 1043
		Rect(x0, y0, aw, ah), -- 1043
		Color(5, 7, 11, 245) -- 1043
	) -- 1043
	fgDraw:drawSegment( -- 1045
		Vec2(x0, y0), -- 1045
		Vec2(x0, y1), -- 1045
		3, -- 1045
		toColor(PALETTE.rimSilver, 215) -- 1045
	) -- 1045
	fgDraw:drawSegment( -- 1046
		Vec2(x1, y0), -- 1046
		Vec2(x1, y1), -- 1046
		3, -- 1046
		toColor(PALETTE.rimSilver, 215) -- 1046
	) -- 1046
	fgDraw:drawSegment( -- 1047
		Vec2(x0 - 4, y1), -- 1047
		Vec2(x1 + 4, y1), -- 1047
		3.2, -- 1047
		toColor(PALETTE.rimSilver, 235) -- 1047
	) -- 1047
	if p.room.key == "outside" then -- 1047
		local arcR = math.min(aw * 0.46, ah * 0.72) -- 1050
		fgDraw:drawArc( -- 1051
			Vec2((x0 + x1) * 0.5, y1 - arcR - 2), -- 1051
			arcR, -- 1051
			0, -- 1051
			180, -- 1051
			2.2, -- 1051
			toColor(theme.accent, 195) -- 1051
		) -- 1051
		fillVGradRect( -- 1052
			fgGlow, -- 1052
			x0 + 6, -- 1052
			y0, -- 1052
			aw - 12, -- 1052
			ah * 0.65, -- 1052
			Color(86, 186, 236, 52), -- 1052
			Color(86, 186, 236, 0) -- 1052
		) -- 1052
	end -- 1052
end -- 1024
return ____exports -- 1024