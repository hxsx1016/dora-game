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
	if solid.art == "gate_post" or solid.art == "wall" or solid.art == "latch" then -- 39
		return "wall" -- 41
	end -- 41
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 41
		return "cover_wood" -- 44
	end -- 44
	if solid.art == "fence" then -- 44
		return "fence" -- 47
	end -- 47
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 49
end -- 39
____exports.StageRenderer = __TS__Class() -- 52
local StageRenderer = ____exports.StageRenderer -- 52
StageRenderer.name = "StageRenderer" -- 52
function StageRenderer.prototype.____constructor(self) -- 52
end -- 52
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 54
	local w = cam.viewW -- 62
	local h = cam.viewH -- 63
	local theme = themeOf(p.room.key) -- 64
	local seed = roomSeed(p.room.key) -- 65
	local span = math.max(1, p.room.maxX - p.room.minX) -- 67
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 68
	local farSlot = "bgFar_" .. p.room.key -- 69
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 70
	local artH = artW * 9 / 16 -- 71
	if assets:tryPlace( -- 71
		farSlot, -- 72
		"scene", -- 72
		w * (0.5 - progress * 0.09), -- 72
		(h - artH) * 0.5, -- 72
		artW, -- 72
		artH -- 72
	) then -- 72
		self:drawDressing(assets, p, cam, progress) -- 73
		local y = cam.groundScreenY -- 74
		fillVGradRect( -- 75
			bgDraw, -- 75
			0, -- 75
			0, -- 75
			w, -- 75
			h, -- 75
			toColor(PALETTE.voidDark), -- 75
			toColor(theme.skyMid) -- 75
		) -- 75
		fillVGradRect( -- 76
			bgGlow, -- 76
			0, -- 76
			y - 1, -- 76
			w, -- 76
			h * 0.14, -- 76
			Color(43, 49, 63, 15), -- 76
			Color(43, 49, 63, 0) -- 76
		) -- 76
		return -- 77
	end -- 77
	local splitY = h * 0.46 -- 81
	fillVGradRect( -- 82
		bgDraw, -- 82
		0, -- 82
		splitY, -- 82
		w, -- 82
		h - splitY, -- 82
		toColor(theme.skyMid), -- 82
		toColor(theme.skyTop) -- 82
	) -- 82
	fillVGradRect( -- 83
		bgDraw, -- 83
		0, -- 83
		0, -- 83
		w, -- 83
		splitY, -- 83
		toColor(theme.skyHorizon), -- 83
		toColor(theme.skyMid) -- 83
	) -- 83
	if theme.showMoon then -- 83
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 87
		local my = h * theme.moonYFrac -- 88
		local mr = math.max(18, h * 0.044) -- 89
		fillRadialGlow( -- 90
			bgGlow, -- 90
			mx, -- 90
			my, -- 90
			mr * 6.2, -- 90
			mr * 6.2, -- 90
			Color(140, 200, 255, 28), -- 90
			Color(20, 40, 80, 0), -- 90
			22 -- 90
		) -- 90
		fillRadialGlow( -- 91
			bgGlow, -- 91
			mx, -- 91
			my, -- 91
			mr * 2.4, -- 91
			mr * 2.4, -- 91
			Color(200, 232, 255, 64), -- 91
			Color(80, 140, 210, 0), -- 91
			18 -- 91
		) -- 91
		bgDraw:drawCircle( -- 92
			Vec2(mx, my), -- 92
			mr, -- 92
			Color(224, 238, 252, 230) -- 92
		) -- 92
		bgDraw:drawCircle( -- 94
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 94
			mr * 0.84, -- 94
			toColor(theme.skyTop, 110) -- 94
		) -- 94
	end -- 94
	if p.room.key == "forest" then -- 94
		self:drawFarForest( -- 98
			bgDraw, -- 98
			w, -- 98
			h, -- 98
			cam, -- 98
			theme, -- 98
			seed -- 98
		) -- 98
		self:drawMidForest( -- 99
			bgDraw, -- 99
			bgGlow, -- 99
			w, -- 99
			h, -- 99
			cam, -- 99
			theme, -- 99
			time, -- 99
			seed -- 99
		) -- 99
	else -- 99
		self:drawFarCity( -- 101
			bgDraw, -- 101
			bgGlow, -- 101
			w, -- 101
			h, -- 101
			cam, -- 101
			theme, -- 101
			seed -- 101
		) -- 101
		self:drawMidArchitecture( -- 102
			bgDraw, -- 102
			bgGlow, -- 102
			w, -- 102
			h, -- 102
			cam, -- 102
			theme, -- 102
			time, -- 102
			seed -- 102
		) -- 102
	end -- 102
	if theme.showSearchlights then -- 102
		self:drawSearchlights( -- 105
			bgGlow, -- 105
			w, -- 105
			h, -- 105
			cam, -- 105
			theme, -- 105
			time, -- 105
			seed -- 105
		) -- 105
	end -- 105
	if theme.showTowerBeacon then -- 105
		self:drawDistantNorthTower( -- 108
			bgDraw, -- 108
			bgGlow, -- 108
			w, -- 108
			h, -- 108
			cam, -- 108
			p, -- 108
			time -- 108
		) -- 108
	end -- 108
	local fogH = h * 0.38 -- 112
	fillVGradRect( -- 113
		bgGlow, -- 114
		0, -- 115
		cam.groundScreenY - 10, -- 116
		w, -- 117
		fogH, -- 118
		toColor(theme.fogBottom), -- 119
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 120
	) -- 120
end -- 54
function StageRenderer.prototype.drawDressing(self, assets, p, cam, progress) -- 124
	local w = cam.viewW -- 125
	local ground = cam.groundScreenY -- 126
	local x = w * (0.75 - progress * 0.29) -- 127
	if p.room.key == "forest" or p.room.key == "outside" or p.room.key == "tower" then -- 127
		assets:tryPlace( -- 129
			"pine", -- 129
			"mid_pine", -- 129
			x, -- 129
			ground - cam:len(12), -- 129
			cam:len(124), -- 129
			cam:len(138), -- 129
			{layer = 1, opacity = 0.52} -- 130
		) -- 130
	elseif p.room.key == "prologue" or p.room.key == "village" or p.room.key == "checkpoint" then -- 130
		assets:tryPlace( -- 132
			"eaves", -- 132
			"mid_eaves", -- 132
			x, -- 132
			ground - cam:len(8), -- 132
			cam:len(186), -- 132
			cam:len(104), -- 132
			{layer = 1, opacity = 0.46} -- 133
		) -- 133
	else -- 133
		assets:tryPlace( -- 135
			"cover_stone", -- 135
			"mid_ruin", -- 135
			x, -- 135
			ground - cam:len(8), -- 135
			cam:len(140), -- 135
			cam:len(48), -- 135
			{layer = 1, opacity = 0.46} -- 136
		) -- 136
	end -- 136
	if p.room.key == "street" or p.room.key == "checkpoint" or p.room.key == "prologue" then -- 136
		assets:tryPlace( -- 139
			"prop_lantern", -- 139
			"mid_lantern", -- 139
			w * (0.27 - progress * 0.21), -- 139
			ground + cam:len(92), -- 140
			cam:len(22), -- 140
			cam:len(30), -- 140
			{layer = 2, opacity = 0.82} -- 140
		) -- 140
	end -- 140
end -- 124
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 145
	local theme = themeOf("checkpoint") -- 152
	local splitY = h * 0.44 -- 153
	fillVGradRect( -- 154
		bgDraw, -- 154
		0, -- 154
		splitY, -- 154
		w, -- 154
		h - splitY, -- 154
		toColor(theme.skyMid), -- 154
		toColor(theme.skyTop) -- 154
	) -- 154
	fillVGradRect( -- 155
		bgDraw, -- 155
		0, -- 155
		0, -- 155
		w, -- 155
		splitY, -- 155
		toColor(theme.skyHorizon), -- 155
		toColor(theme.skyMid) -- 155
	) -- 155
	local mx = w * 0.61 -- 158
	local my = h * 0.74 -- 159
	local mr = h * 0.082 -- 160
	fillRadialGlow( -- 161
		bgGlow, -- 161
		mx, -- 161
		my, -- 161
		mr * 5.2, -- 161
		mr * 5.2, -- 161
		Color(86, 210, 255, 34), -- 161
		Color(10, 24, 52, 0), -- 161
		24 -- 161
	) -- 161
	fillRadialGlow( -- 162
		bgGlow, -- 162
		mx, -- 162
		my, -- 162
		mr * 2.1, -- 162
		mr * 2.1, -- 162
		Color(190, 240, 255, 76), -- 162
		Color(40, 120, 190, 0), -- 162
		20 -- 162
	) -- 162
	bgDraw:drawCircle( -- 163
		Vec2(mx, my), -- 163
		mr, -- 163
		Color(228, 242, 255, 235) -- 163
	) -- 163
	bgDraw:drawCircle( -- 164
		Vec2(mx + mr * 0.25, my + mr * 0.14), -- 164
		mr * 0.86, -- 164
		Color(10, 18, 34, 125) -- 164
	) -- 164
	local s = 0 -- 167
	do -- 167
		s = 0 -- 168
		while s < 3 do -- 168
			local bx = w * (0.36 + s * 0.24) -- 169
			local sway = math.sin(time * (0.35 + s * 0.14) + s * 1.9) * 0.26 -- 170
			local ang = math.pi * 0.5 + sway - 0.12 -- 171
			local len = h * 1.15 -- 172
			local spread = 0.085 + s * 0.015 -- 173
			local x1 = bx + math.cos(ang - spread) * len -- 174
			local y1 = math.sin(ang - spread) * len -- 175
			local x2 = bx + math.cos(ang + spread) * len -- 176
			local y2 = math.sin(ang + spread) * len -- 177
			local baseCol = s == 1 and Color(255, 58, 92, 34) or Color(76, 214, 255, 36) -- 178
			local tipCol = Color(baseCol.r, baseCol.g, baseCol.b, 0) -- 179
			bgGlow:drawVertices({ -- 180
				{ -- 181
					Vec2(bx, h * 0.15), -- 181
					baseCol -- 181
				}, -- 181
				{ -- 182
					Vec2(x1, y1), -- 182
					tipCol -- 182
				}, -- 182
				{ -- 183
					Vec2(x2, y2), -- 183
					tipCol -- 183
				} -- 183
			}) -- 183
			s = s + 1 -- 168
		end -- 168
	end -- 168
	local groundY = h * 0.19 -- 188
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < 16 do -- 190
			local bx = i * (w / 14) - 20 + math.sin(time * 0.08) * 6 -- 191
			local bw = 54 + hash01(i * 13 + 3) * 86 -- 192
			local bh = h * (0.2 + hash01(i * 29 + 7) * 0.34) -- 193
			local cut = 12 + hash01(i * 19) * 20 -- 194
			bgDraw:drawPolygon( -- 195
				{ -- 195
					Vec2(bx, groundY), -- 196
					Vec2(bx + bw, groundY), -- 197
					Vec2(bx + bw, groundY + bh - cut), -- 198
					Vec2(bx + bw - cut, groundY + bh), -- 199
					Vec2(bx, groundY + bh) -- 200
				}, -- 200
				Color(10, 16, 28, 255) -- 201
			) -- 201
			if hash01(i * 41 + 5) > 0.45 then -- 201
				local wy = groundY + bh * 0.65 -- 204
				bgGlow:drawSegment( -- 205
					Vec2(bx + 10, wy), -- 205
					Vec2(bx + bw - 14, wy), -- 205
					1.2, -- 205
					Color(72, 224, 255, 95) -- 205
				) -- 205
			end -- 205
			i = i + 1 -- 190
		end -- 190
	end -- 190
	local tx = w * 0.83 -- 210
	local ty0 = groundY -- 211
	local ty1 = h * 0.62 -- 212
	bgDraw:drawPolygon( -- 213
		{ -- 213
			Vec2(tx - 26, ty0), -- 214
			Vec2(tx + 26, ty0), -- 215
			Vec2(tx + 11, ty1), -- 216
			Vec2(tx - 11, ty1) -- 217
		}, -- 217
		Color(15, 24, 40, 255), -- 218
		1.2, -- 218
		Color(58, 86, 118, 140) -- 218
	) -- 218
	bgDraw:drawSegment( -- 219
		Vec2(tx, ty0 + 24), -- 219
		Vec2(tx, ty1 - 12), -- 219
		1.4, -- 219
		Color(242, 188, 96, 85) -- 219
	) -- 219
	bgDraw:drawSegment( -- 220
		Vec2(tx, ty1), -- 220
		Vec2(tx, ty1 + 42), -- 220
		2.2, -- 220
		Color(165, 212, 248, 210) -- 220
	) -- 220
	local pulse = 0.78 + 0.22 * math.sin(time * 2.4) -- 221
	fillRadialGlow( -- 222
		bgGlow, -- 222
		tx, -- 222
		ty1 + 42, -- 222
		74 * pulse, -- 222
		74 * pulse, -- 222
		Color(255, 222, 146, 130), -- 222
		Color(255, 180, 90, 0), -- 222
		20 -- 222
	) -- 222
	bgGlow:drawDot( -- 223
		Vec2(tx, ty1 + 42), -- 223
		5, -- 223
		Color(255, 248, 224, 255) -- 223
	) -- 223
	fillVGradRect( -- 226
		bgDraw, -- 226
		0, -- 226
		0, -- 226
		w, -- 226
		groundY, -- 226
		Color(6, 9, 16, 255), -- 226
		Color(16, 24, 38, 255) -- 226
	) -- 226
	bgDraw:drawSegment( -- 227
		Vec2(0, groundY), -- 227
		Vec2(w, groundY), -- 227
		2, -- 227
		Color(76, 220, 255, 180) -- 227
	) -- 227
	fillVGradRect( -- 228
		bgGlow, -- 228
		0, -- 228
		groundY, -- 228
		w, -- 228
		h * 0.24, -- 228
		Color(42, 130, 182, 52), -- 228
		Color(20, 60, 100, 0) -- 228
	) -- 228
	local sx = w * 0.64 -- 231
	fillRadialGlow( -- 232
		bgGlow, -- 232
		sx + 38, -- 232
		groundY + 75, -- 232
		128, -- 232
		92, -- 232
		Color(52, 178, 232, 42), -- 232
		Color(20, 60, 110, 0), -- 232
		18 -- 232
	) -- 232
	bgDraw:drawPolygon( -- 234
		{ -- 234
			Vec2(sx - 36, groundY + 12), -- 235
			Vec2(sx + 10, groundY + 18), -- 236
			Vec2(sx + 16, groundY + 124), -- 237
			Vec2(sx - 18, groundY + 124) -- 238
		}, -- 238
		Color(10, 16, 28, 255), -- 239
		1.3, -- 239
		Color(76, 210, 255, 145) -- 239
	) -- 239
	bgDraw:drawSegment( -- 240
		Vec2(sx - 6, groundY + 48), -- 240
		Vec2(sx - 12, groundY + 2), -- 240
		6, -- 240
		Color(10, 16, 28, 255) -- 240
	) -- 240
	bgDraw:drawSegment( -- 241
		Vec2(sx + 6, groundY + 48), -- 241
		Vec2(sx + 14, groundY + 2), -- 241
		6, -- 241
		Color(14, 22, 36, 255) -- 241
	) -- 241
	bgDraw:drawPolygon( -- 242
		{ -- 242
			Vec2(sx - 20, groundY + 120), -- 243
			Vec2(sx + 20, groundY + 122), -- 244
			Vec2(sx + 16, groundY + 132), -- 245
			Vec2(sx - 16, groundY + 130) -- 246
		}, -- 246
		Color(208, 236, 252, 240) -- 247
	) -- 247
	bgDraw:drawCircle( -- 248
		Vec2(sx + 2, groundY + 146), -- 248
		13, -- 248
		Color(14, 22, 36, 255) -- 248
	) -- 248
	bgDraw:drawArc( -- 249
		Vec2(sx + 2, groundY + 146), -- 249
		13.5, -- 249
		30, -- 249
		165, -- 249
		2, -- 249
		Color(216, 240, 255, 230) -- 249
	) -- 249
	bgGlow:drawSegment( -- 250
		Vec2(sx + 4, groundY + 148), -- 250
		Vec2(sx + 17, groundY + 150), -- 250
		2.6, -- 250
		Color(86, 240, 255, 255) -- 250
	) -- 250
	bgDraw:drawSegment( -- 251
		Vec2(sx + 4, groundY + 104), -- 251
		Vec2(sx + 46, groundY + 94), -- 251
		3.4, -- 251
		Color(34, 52, 74, 255) -- 251
	) -- 251
	bgGlow:drawSegment( -- 252
		Vec2(sx + 16, groundY + 102), -- 252
		Vec2(sx + 44, groundY + 95), -- 252
		1.2, -- 252
		Color(86, 236, 255, 200) -- 252
	) -- 252
	local cx = w * 0.725 -- 255
	bgDraw:drawPolygon( -- 256
		{ -- 256
			Vec2(cx - 20, groundY + 14), -- 257
			Vec2(cx + 18, groundY + 14), -- 258
			Vec2(cx + 12, groundY + 84), -- 259
			Vec2(cx - 12, groundY + 84) -- 260
		}, -- 260
		Color(188, 142, 78, 238), -- 261
		1.4, -- 261
		Color(252, 232, 192, 225) -- 261
	) -- 261
	bgDraw:drawSegment( -- 262
		Vec2(cx - 5, groundY + 24), -- 262
		Vec2(cx - 6, groundY + 2), -- 262
		4.2, -- 262
		Color(28, 24, 30, 255) -- 262
	) -- 262
	bgDraw:drawSegment( -- 263
		Vec2(cx + 5, groundY + 24), -- 263
		Vec2(cx + 6, groundY + 2), -- 263
		4.2, -- 263
		Color(38, 32, 38, 255) -- 263
	) -- 263
	bgDraw:drawCircle( -- 264
		Vec2(cx + 1, groundY + 95), -- 264
		11, -- 264
		Color(238, 220, 194, 250) -- 264
	) -- 264
	bgDraw:drawPolygon( -- 265
		{ -- 265
			Vec2(cx - 15, groundY + 84), -- 266
			Vec2(cx - 10, groundY + 108), -- 267
			Vec2(cx + 6, groundY + 107), -- 268
			Vec2(cx - 4, groundY + 84) -- 269
		}, -- 269
		Color(156, 114, 62, 245) -- 270
	) -- 270
	bgGlow:drawSegment( -- 271
		Vec2(cx - 8, groundY + 82), -- 271
		Vec2(cx - 30, groundY + 64), -- 271
		2.8, -- 271
		Color(252, 230, 178, 220) -- 271
	) -- 271
	fillRadialGlow( -- 272
		bgGlow, -- 272
		cx + 10, -- 272
		groundY + 56, -- 272
		30, -- 272
		30, -- 272
		Color(255, 214, 130, 115), -- 272
		Color(250, 180, 70, 0), -- 272
		16 -- 272
	) -- 272
	bgGlow:drawDot( -- 273
		Vec2(cx + 10, groundY + 56), -- 273
		3.2, -- 273
		Color(255, 246, 220, 255) -- 273
	) -- 273
end -- 145
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 277
	local theme = themeOf(p.room.key) -- 287
	self:drawFloors( -- 288
		fgDraw, -- 288
		assets, -- 288
		p, -- 288
		cam, -- 288
		theme -- 288
	) -- 288
	self:drawStairs( -- 289
		fgDraw, -- 289
		fgGlow, -- 289
		assets, -- 289
		p, -- 289
		cam, -- 289
		theme -- 289
	) -- 289
	self:drawSolids( -- 290
		fgDraw, -- 290
		fgGlow, -- 290
		assets, -- 290
		p, -- 290
		cam, -- 290
		theme, -- 290
		time, -- 290
		occlusion, -- 290
		fadeDt -- 290
	) -- 290
	if p.room.key == "gate" then -- 290
		self:drawGateShutter( -- 292
			fgDraw, -- 292
			fgGlow, -- 292
			assets, -- 292
			p, -- 292
			cam, -- 292
			time -- 292
		) -- 292
	end -- 292
	self:drawArch( -- 294
		fgDraw, -- 294
		fgGlow, -- 294
		p, -- 294
		cam, -- 294
		theme -- 294
	) -- 294
end -- 277
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, p, cam) -- 298
	local seed = roomSeed(p.room.key) -- 305
	local parallax = -cam.x * 1.26 * (cam.ppu * 0.45) -- 307
	local span = 520 -- 308
	local startIdx = math.floor((-parallax - 200) / span) -- 309
	local idx = startIdx -- 310
	do -- 310
		idx = startIdx -- 311
		while idx <= startIdx + 4 do -- 311
			local x = idx * span + parallax -- 312
			local r = hash01(seed + idx * 17) -- 313
			local bw = 70 + r * 90 -- 314
			local bh = 28 + hash01(seed + idx * 31) * 34 -- 315
			fgDraw:drawPolygon( -- 316
				{ -- 316
					Vec2(x, 0), -- 317
					Vec2(x + bw, 0), -- 318
					Vec2(x + bw - 18, bh), -- 319
					Vec2(x + 12, bh * 0.72) -- 320
				}, -- 320
				Color(4, 6, 11, 225) -- 321
			) -- 321
			idx = idx + 1 -- 311
		end -- 311
	end -- 311
	fillVGradRect( -- 325
		fgDraw, -- 325
		0, -- 325
		h - h * 0.16, -- 325
		w, -- 325
		h * 0.16, -- 325
		Color(4, 6, 12, 0), -- 325
		Color(4, 6, 12, 138) -- 325
	) -- 325
	fillVGradRect( -- 326
		fgDraw, -- 326
		0, -- 326
		0, -- 326
		w, -- 326
		h * 0.13, -- 326
		Color(4, 6, 12, 185), -- 326
		Color(4, 6, 12, 0) -- 326
	) -- 326
end -- 298
function StageRenderer.prototype.drawSearchlights(self, bgGlow, w, h, cam, theme, time, seed) -- 329
	local count = 3 -- 338
	local i = 0 -- 339
	do -- 339
		i = 0 -- 340
		while i < count do -- 340
			local anchor = ((i * 0.34 + 0.18) * w - cam.x * 0.12) % (w + 260) -- 341
			local bx = anchor < -120 and anchor + w + 260 or anchor -- 342
			local by = cam.groundScreenY * 0.85 -- 343
			local sway = math.sin(time * (0.28 + i * 0.11) + seed + i * 2.1) * 0.32 -- 344
			local ang = math.pi * 0.5 + sway -- 345
			local len = h * 1.15 -- 346
			local halfSpread = 0.065 + i % 2 * 0.025 -- 347
			local x1 = bx + math.cos(ang - halfSpread) * len -- 348
			local y1 = by + math.sin(ang - halfSpread) * len -- 349
			local x2 = bx + math.cos(ang + halfSpread) * len -- 350
			local y2 = by + math.sin(ang + halfSpread) * len -- 351
			local c0 = toColor(theme.beamColor) -- 352
			local c1 = Color(theme.beamColor.r, theme.beamColor.g, theme.beamColor.b, 0) -- 353
			bgGlow:drawVertices({ -- 354
				{ -- 355
					Vec2(bx, by), -- 355
					c0 -- 355
				}, -- 355
				{ -- 356
					Vec2(x1, y1), -- 356
					c1 -- 356
				}, -- 356
				{ -- 357
					Vec2(x2, y2), -- 357
					c1 -- 357
				} -- 357
			}) -- 357
			i = i + 1 -- 340
		end -- 340
	end -- 340
end -- 329
function StageRenderer.prototype.drawFarCity(self, bgDraw, bgGlow, w, h, cam, theme, seed) -- 362
	local baseY = cam.groundScreenY - 8 -- 371
	local shift = -cam.x * 0.2 * cam.ppu -- 372
	local colW = 108 -- 373
	local first = math.floor((-shift - colW) / colW) -- 374
	local count = math.ceil(w / colW) + 3 -- 375
	local i = 0 -- 376
	do -- 376
		i = 0 -- 377
		while i < count do -- 377
			local idx = first + i -- 378
			local r1 = hash01(seed + idx * 13.7) -- 379
			local r2 = hash01(seed + idx * 29.3) -- 380
			local r3 = hash01(seed + idx * 47.1) -- 381
			local x = idx * colW + shift -- 382
			local bw = colW * (0.68 + r1 * 0.44) -- 383
			local bh = h * (0.18 + r2 * 0.38) -- 384
			local cut = r3 > 0.5 and 16 + r1 * 22 or 0 -- 385
			bgDraw:drawPolygon( -- 387
				{ -- 387
					Vec2(x, baseY), -- 388
					Vec2(x + bw, baseY), -- 389
					Vec2(x + bw, baseY + bh - cut), -- 390
					Vec2(x + bw - cut, baseY + bh), -- 391
					Vec2(x, baseY + bh) -- 392
				}, -- 392
				toColor(theme.farBuilding) -- 393
			) -- 393
			if r3 > 0.62 then -- 393
				local ax = x + bw * 0.25 -- 397
				bgDraw:drawSegment( -- 398
					Vec2(ax, baseY + bh), -- 398
					Vec2(ax, baseY + bh + 32), -- 398
					1.2, -- 398
					toColor(theme.farBuilding) -- 398
				) -- 398
				if r1 > 0.6 then -- 398
					bgGlow:drawDot( -- 400
						Vec2(ax, baseY + bh + 32), -- 400
						2.2, -- 400
						toColor(theme.accent, 145) -- 400
					) -- 400
				end -- 400
			end -- 400
			if r2 > 0.55 then -- 400
				local wy = baseY + bh * (0.52 + r1 * 0.25) -- 405
				bgGlow:drawSegment( -- 406
					Vec2(x + 12, wy), -- 406
					Vec2(x + bw - 14, wy), -- 406
					1.1, -- 406
					toColor(theme.accent, 64) -- 406
				) -- 406
			end -- 406
			i = i + 1 -- 377
		end -- 377
	end -- 377
end -- 362
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 411
	local baseY = cam.groundScreenY - 8 -- 419
	local shift = -cam.x * 0.22 * cam.ppu -- 420
	local step = 76 -- 421
	local first = math.floor((-shift - step) / step) -- 422
	local count = math.ceil(w / step) + 4 -- 423
	local i = 0 -- 424
	do -- 424
		i = 0 -- 425
		while i < count do -- 425
			local idx = first + i -- 426
			local r1 = hash01(seed + idx * 11.3) -- 427
			local r2 = hash01(seed + idx * 23.9) -- 428
			local cx = idx * step + shift -- 429
			local tw = 34 + r1 * 38 -- 430
			local th = h * (0.24 + r2 * 0.34) -- 431
			bgDraw:drawPolygon( -- 433
				{ -- 433
					Vec2(cx - tw, baseY), -- 434
					Vec2(cx + tw, baseY), -- 435
					Vec2(cx, baseY + th) -- 436
				}, -- 436
				toColor(theme.farBuilding) -- 437
			) -- 437
			bgDraw:drawPolygon( -- 438
				{ -- 438
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 439
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 440
					Vec2(cx, baseY + th * 1.12) -- 441
				}, -- 441
				toColor(theme.farBuilding) -- 442
			) -- 442
			i = i + 1 -- 425
		end -- 425
	end -- 425
end -- 411
function StageRenderer.prototype.drawMidArchitecture(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 446
	local baseY = cam.groundScreenY - 4 -- 456
	local shift = -cam.x * 0.48 * cam.ppu -- 457
	local bay = 240 -- 458
	local first = math.floor((-shift - bay) / bay) -- 459
	local count = math.ceil(w / bay) + 3 -- 460
	local col = toColor(theme.midBuilding) -- 461
	local edge = Color(theme.midBuilding.r + 22, theme.midBuilding.g + 28, theme.midBuilding.b + 38, 170) -- 462
	local i = 0 -- 464
	do -- 464
		i = 0 -- 465
		while i < count do -- 465
			local idx = first + i -- 466
			local r = hash01(seed + idx * 37.3) -- 467
			local x = idx * bay + shift -- 468
			local colH = h * (0.34 + r * 0.24) -- 469
			local pw = 22 + r * 16 -- 470
			bgDraw:drawRect( -- 473
				Rect(x, baseY, pw, colH), -- 473
				col -- 473
			) -- 473
			bgDraw:drawSegment( -- 474
				Vec2(x + pw, baseY), -- 474
				Vec2(x + pw, baseY + colH), -- 474
				1, -- 474
				edge -- 474
			) -- 474
			if r > 0.35 then -- 474
				local beamY = baseY + colH * 0.76 -- 476
				bgDraw:drawSegment( -- 477
					Vec2(x + pw, beamY), -- 477
					Vec2(x + bay, beamY), -- 477
					4, -- 477
					col -- 477
				) -- 477
				bgDraw:drawSegment( -- 478
					Vec2(x + pw, beamY - 22), -- 478
					Vec2(x + bay * 0.5, beamY), -- 478
					1.4, -- 478
					edge -- 478
				) -- 478
				bgDraw:drawSegment( -- 479
					Vec2(x + bay * 0.5, beamY), -- 479
					Vec2(x + bay, beamY - 22), -- 479
					1.4, -- 479
					edge -- 479
				) -- 479
			end -- 479
			bgDraw:drawQuadraticBezier( -- 483
				Vec2(x + pw * 0.5, baseY + colH * 0.88), -- 484
				Vec2( -- 485
					x + bay * 0.5, -- 485
					baseY + colH * 0.62 + math.sin(time * 1.4 + idx) * 3 -- 485
				), -- 485
				Vec2(x + bay + pw * 0.5, baseY + colH * 0.85), -- 486
				1, -- 487
				Color(12, 18, 28, 180) -- 488
			) -- 488
			if idx & 1 == 0 then -- 488
				local lx = x + bay * 0.52 -- 493
				local ly = baseY + h * 0.31 -- 494
				bgDraw:drawSegment( -- 495
					Vec2(lx, baseY), -- 495
					Vec2(lx, ly), -- 495
					2.2, -- 495
					col -- 495
				) -- 495
				bgDraw:drawSegment( -- 496
					Vec2(lx, ly), -- 496
					Vec2(lx + 18, ly - 4), -- 496
					2, -- 496
					col -- 496
				) -- 496
				local flicker = 0.84 + 0.16 * math.sin(time * 5.2 + idx * 3.1) -- 497
				local lc = theme.accent -- 498
				bgGlow:drawDot( -- 499
					Vec2(lx + 18, ly - 5), -- 499
					3.2, -- 499
					toColor(lc, 210 * flicker) -- 499
				) -- 499
				fillRadialGlow( -- 500
					bgGlow, -- 500
					lx + 18, -- 500
					ly - 5, -- 500
					36, -- 500
					36, -- 500
					toColor(lc, 54 * flicker), -- 500
					Color(lc.r, lc.g, lc.b, 0), -- 500
					14 -- 500
				) -- 500
				bgGlow:drawVertices({ -- 501
					{ -- 502
						Vec2(lx + 18, ly - 6), -- 502
						toColor(lc, 38 * flicker) -- 502
					}, -- 502
					{ -- 503
						Vec2(lx - 42, baseY), -- 503
						Color(lc.r, lc.g, lc.b, 0) -- 503
					}, -- 503
					{ -- 504
						Vec2(lx + 78, baseY), -- 504
						Color(lc.r, lc.g, lc.b, 0) -- 504
					} -- 504
				}) -- 504
			end -- 504
			i = i + 1 -- 465
		end -- 465
	end -- 465
end -- 446
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 510
	local baseY = cam.groundScreenY - 4 -- 520
	local shift = -cam.x * 0.52 * cam.ppu -- 521
	local span = 156 -- 522
	local first = math.floor((-shift - span) / span) -- 523
	local count = math.ceil(w / span) + 3 -- 524
	local col = toColor(theme.midBuilding) -- 525
	local i = 0 -- 527
	do -- 527
		i = 0 -- 528
		while i < count do -- 528
			local idx = first + i -- 529
			local r = hash01(seed + idx * 19.7) -- 530
			local x = idx * span + shift -- 531
			local trunkW = 14 + r * 14 -- 532
			local sway = math.sin(time * 0.9 + idx) * 4 -- 533
			bgDraw:drawPolygon( -- 534
				{ -- 534
					Vec2(x - trunkW * 0.5, baseY), -- 535
					Vec2(x + trunkW * 0.5, baseY), -- 536
					Vec2(x + trunkW * 0.25 + sway, h), -- 537
					Vec2(x - trunkW * 0.3 + sway, h) -- 538
				}, -- 538
				col -- 539
			) -- 539
			if idx % 3 == 0 then -- 539
				bgGlow:drawVertices({ -- 542
					{ -- 543
						Vec2(x + 40, h), -- 543
						Color(110, 232, 200, 26) -- 543
					}, -- 543
					{ -- 544
						Vec2(x + 115, h), -- 544
						Color(110, 232, 200, 0) -- 544
					}, -- 544
					{ -- 545
						Vec2(x - 60, baseY), -- 545
						Color(110, 232, 200, 0) -- 545
					} -- 545
				}) -- 545
			end -- 545
			i = i + 1 -- 528
		end -- 528
	end -- 528
end -- 510
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 551
	local scale = 0.55 -- 561
	if p.room.key == "village" then -- 561
		scale = 0.72 -- 563
	elseif p.room.key == "forest" then -- 563
		scale = 0.92 -- 565
	elseif p.room.key == "tower" then -- 565
		scale = 1.15 -- 567
	end -- 567
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 569
	local baseY = cam.groundScreenY - 8 -- 570
	local towerH = h * 0.42 * scale -- 571
	local bw = 20 * scale -- 572
	bgDraw:drawPolygon( -- 573
		{ -- 573
			Vec2(tx - bw, baseY), -- 574
			Vec2(tx + bw, baseY), -- 575
			Vec2(tx + bw * 0.45, baseY + towerH), -- 576
			Vec2(tx - bw * 0.45, baseY + towerH) -- 577
		}, -- 577
		Color(14, 24, 38, 240) -- 578
	) -- 578
	bgDraw:drawSegment( -- 579
		Vec2(tx, baseY + towerH), -- 579
		Vec2(tx, baseY + towerH + 28 * scale), -- 579
		1.8, -- 579
		Color(180, 210, 238, 200) -- 579
	) -- 579
	local topY = baseY + towerH + 24 * scale -- 581
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 582
	fillRadialGlow( -- 583
		bgGlow, -- 583
		tx, -- 583
		topY, -- 583
		56 * scale * pulse, -- 583
		56 * scale * pulse, -- 583
		Color(255, 224, 152, 118), -- 583
		Color(255, 190, 96, 0), -- 583
		18 -- 583
	) -- 583
	bgGlow:drawDot( -- 584
		Vec2(tx, topY), -- 584
		3.6 * scale, -- 584
		Color(255, 246, 220, 255) -- 584
	) -- 584
end -- 551
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 587
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 594
	do -- 594
		local i = 0 -- 595
		while i < #p.room.floors do -- 595
			local floor = p.room.floors[i + 1] -- 596
			local left = cam:sx(floor.x0) -- 597
			local right = cam:sx(floor.x1) -- 598
			local isMain = floor.y <= 0.1 -- 599
			local ____isMain_0 -- 600
			if isMain then -- 600
				____isMain_0 = p.room.depth -- 600
			else -- 600
				____isMain_0 = nil -- 600
			end -- 600
			local road = ____isMain_0 -- 600
			local top = cam:sy(floor.y, road and road.min or 0) -- 601
			if road ~= nil then -- 601
				self:drawRoad( -- 603
					fgDraw, -- 603
					assets, -- 603
					i, -- 603
					left, -- 603
					right, -- 603
					top, -- 603
					cam:sy(floor.y, road.max), -- 603
					cam, -- 603
					theme -- 603
				) -- 603
			end -- 603
			local height = cam:len(isMain and 22 or 12) -- 605
			local bottom = top - height -- 606
			if isMain and bottom > 0 then -- 606
				fillVGradRect( -- 608
					fgDraw, -- 608
					left, -- 608
					0, -- 608
					right - left, -- 608
					bottom + 1, -- 608
					toColor(PALETTE.voidDark), -- 609
					toColor(theme.groundBody) -- 609
				) -- 609
			end -- 609
			fgDraw:drawRect( -- 611
				Rect(left, bottom, right - left, height), -- 611
				toColor(PALETTE.steelDark) -- 611
			) -- 611
			local step = cam:len(96) -- 612
			local start = math.max( -- 613
				0, -- 613
				math.floor(-left / step) -- 613
			) -- 613
			do -- 613
				local j = start -- 614
				while left + j * step < math.min(right, cam.viewW) do -- 614
					local x = left + j * step -- 615
					local width = math.min(step, right - x) -- 616
					assets:tryPlace( -- 617
						"slab", -- 617
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 617
						x + width * 0.5, -- 617
						bottom, -- 617
						width, -- 617
						height -- 617
					) -- 617
					if grass and isMain and j % 3 == 1 then -- 617
						assets:tryPlace( -- 619
							"grass_low", -- 619
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 619
							x + width * 0.5, -- 619
							top - cam:len(3), -- 620
							width * 0.74, -- 620
							cam:len(13), -- 620
							{opacity = 0.83, layer = 1} -- 620
						) -- 620
					end -- 620
					j = j + 1 -- 614
				end -- 614
			end -- 614
			fgDraw:drawSegment( -- 623
				Vec2(left, top), -- 623
				Vec2(right, top), -- 623
				1, -- 623
				toColor(theme.groundRim, 140) -- 623
			) -- 623
			i = i + 1 -- 595
		end -- 595
	end -- 595
end -- 587
function StageRenderer.prototype.drawRoad(self, draw, assets, floor, left, right, front, back, cam, theme) -- 627
	local width = right - left -- 632
	local height = back - front -- 633
	fillVGradRect( -- 634
		draw, -- 634
		left, -- 634
		front, -- 634
		width, -- 634
		height, -- 634
		toColor(lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.34)), -- 635
		toColor(lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.36)) -- 636
	) -- 636
	local bands = { -- 637
		0, -- 637
		0.31, -- 637
		0.59, -- 637
		0.82, -- 637
		1 -- 637
	} -- 637
	local edge = toColor(theme.groundRim, 34) -- 638
	do -- 638
		local row = 0 -- 639
		while row < #bands - 1 do -- 639
			local y = front + bands[row + 1] * height -- 640
			local rowHeight = (bands[row + 1 + 1] - bands[row + 1]) * height -- 641
			local slabWidth = cam:len(132 - row * 12) -- 642
			local offset = left - row % 2 * slabWidth * 0.5 -- 643
			local start = math.max( -- 644
				0, -- 644
				math.floor(-offset / slabWidth) -- 644
			) -- 644
			do -- 644
				local column = start -- 645
				while offset + column * slabWidth < math.min(right, cam.viewW) do -- 645
					local tileStart = offset + column * slabWidth -- 646
					local x = math.max(left, tileStart) -- 647
					local w = math.min(right, tileStart + slabWidth) - x -- 648
					if w > 1 then -- 648
						assets:tryPlace( -- 650
							"wall", -- 650
							(((("road_" .. tostring(floor)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 650
							x + w * 0.5, -- 651
							y, -- 651
							w, -- 651
							rowHeight, -- 651
							{ -- 651
								opacity = 0.88 - row * 0.09, -- 652
								facing = (column + row) % 2 == 0 and 1 or -1, -- 653
								color = Color(174 - row * 9, 167 - row * 7, 154 - row * 3, 255) -- 654
							} -- 654
						) -- 654
					end -- 654
					column = column + 1 -- 645
				end -- 645
			end -- 645
			draw:drawSegment( -- 658
				Vec2(left, y), -- 658
				Vec2(right, y), -- 658
				0.8, -- 658
				edge -- 658
			) -- 658
			row = row + 1 -- 639
		end -- 639
	end -- 639
	draw:drawSegment( -- 660
		Vec2(left, back), -- 660
		Vec2(right, back), -- 660
		1.1, -- 660
		toColor(theme.groundRim, 53) -- 660
	) -- 660
end -- 627
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 663
	local i = 0 -- 671
	do -- 671
		i = 0 -- 672
		while i < #p.room.stairs do -- 672
			local st = p.room.stairs[i + 1] -- 673
			local n = st.steps + 1 -- 674
			local stepW = (st.x1 - st.x0) / n -- 675
			local k = 0 -- 676
			do -- 676
				k = 0 -- 677
				while k < n do -- 677
					local wy = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 678
					local wx0 = st.x0 + stepW * k -- 679
					local wx1 = wx0 + stepW -- 680
					local x0 = cam:sx(wx0) -- 681
					local x1 = cam:sx(wx1) -- 682
					local y1 = cam:sy(wy) -- 683
					local y0 = cam:sy(math.max(0, st.y0)) -- 684
					if y1 > y0 + 2 then -- 684
						fgDraw:drawRect( -- 686
							Rect(x0, y0, x1 - x0, y1 - y0), -- 686
							toColor(PALETTE.steelDark, 230) -- 686
						) -- 686
						fgDraw:drawRect( -- 687
							Rect(x0, y1 - 5, x1 - x0, 5), -- 687
							toColor(theme.groundTop) -- 687
						) -- 687
						assets:tryPlace( -- 688
							"wall", -- 688
							(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 688
							(x0 + x1) * 0.5, -- 688
							y0, -- 688
							x1 - x0, -- 689
							y1 - y0, -- 689
							{opacity = 0.78} -- 689
						) -- 689
						assets:tryPlace( -- 690
							"slab", -- 690
							(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 690
							(x0 + x1) * 0.5, -- 690
							y1 - cam:len(5), -- 690
							x1 - x0, -- 691
							cam:len(5), -- 691
							{layer = 1} -- 691
						) -- 691
					end -- 691
					fgDraw:drawSegment( -- 693
						Vec2(x0, y1), -- 693
						Vec2(x1, y1), -- 693
						1.8, -- 693
						toColor(theme.groundRim) -- 693
					) -- 693
					fgGlow:drawSegment( -- 694
						Vec2(x0, y1 + 1), -- 694
						Vec2(x1, y1 + 1), -- 694
						1, -- 694
						toColor(theme.accent, 55) -- 694
					) -- 694
					k = k + 1 -- 677
				end -- 677
			end -- 677
			i = i + 1 -- 672
		end -- 672
	end -- 672
end -- 663
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 699
	local i = 0 -- 710
	do -- 710
		i = 0 -- 711
		while i < #p.room.solids do -- 711
			do -- 711
				local s = p.room.solids[i + 1] -- 712
				local x0 = cam:sx(s.x) -- 713
				local x1 = cam:sx(s.x + s.w) -- 714
				if p.room.depth ~= nil and s.depth ~= nil then -- 714
					local opacity = occlusion:update( -- 716
						"solid_" .. tostring(i), -- 716
						{ -- 716
							x0 = s.x, -- 717
							x1 = s.x + s.w, -- 717
							y0 = s.y, -- 717
							y1 = s.y + s.h, -- 717
							depth = s.depth, -- 718
							passThrough = s.decorative -- 718
						}, -- 718
						p, -- 719
						fadeDt -- 719
					) -- 719
					if x1 > 0 and x0 < cam.viewW then -- 719
						self:drawDepthSolid( -- 721
							fgDraw, -- 721
							assets, -- 721
							s, -- 721
							s.depth, -- 721
							x0, -- 721
							x1, -- 721
							cam, -- 721
							theme, -- 721
							opacity -- 721
						) -- 721
					end -- 721
					goto __continue81 -- 723
				end -- 723
				local y0 = cam:sy(s.y) -- 725
				local y1 = cam:sy(s.y + s.h) -- 726
				local sw = x1 - x0 -- 727
				local sh = y1 - y0 -- 728
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 728
					goto __continue81 -- 730
				end -- 730
				if s.passable == true then -- 730
					if not assets:tryPlace( -- 730
						"grass", -- 735
						"hide_grass_" .. tostring(i), -- 735
						(x0 + x1) * 0.5, -- 735
						y0, -- 735
						sw, -- 735
						sh * 1.55, -- 735
						{opacity = 0.79, layer = 7} -- 736
					) then -- 736
						self:drawGrassCluster( -- 737
							fgDraw, -- 737
							fgGlow, -- 737
							x0, -- 737
							y0, -- 737
							sw, -- 737
							sh, -- 737
							p.player.x, -- 737
							s.x + s.w * 0.5, -- 737
							time -- 737
						) -- 737
					end -- 737
					goto __continue81 -- 739
				end -- 739
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 739
					self:drawWinch( -- 744
						fgDraw, -- 744
						fgGlow, -- 744
						x0, -- 744
						y0, -- 744
						sw, -- 744
						sh, -- 744
						p, -- 744
						time -- 744
					) -- 744
					assets:tryPlace( -- 745
						"prop_winch", -- 745
						"gate_winch", -- 745
						(x0 + x1) * 0.5, -- 745
						y0 + sh * 0.55, -- 745
						sw, -- 745
						sh * 0.78, -- 745
						{layer = 2} -- 746
					) -- 746
					goto __continue81 -- 747
				end -- 747
				if p.room.key == "tower" then -- 747
					self:drawTowerStructure( -- 752
						fgDraw, -- 752
						fgGlow, -- 752
						assets, -- 752
						x0, -- 752
						y0, -- 752
						sw, -- 752
						sh, -- 752
						s, -- 752
						p, -- 752
						time -- 752
					) -- 752
					goto __continue81 -- 753
				end -- 753
				if s.h <= 64 and s.y <= 2 then -- 753
					self:drawCoverBlock( -- 758
						fgDraw, -- 758
						fgGlow, -- 758
						assets, -- 758
						x0, -- 758
						y0, -- 758
						sw, -- 758
						sh, -- 758
						s, -- 758
						p, -- 758
						theme -- 758
					) -- 758
					goto __continue81 -- 759
				end -- 759
				fillVGradRect( -- 762
					fgDraw, -- 762
					x0, -- 762
					y0, -- 762
					sw, -- 762
					sh, -- 762
					toColor(PALETTE.steelDark), -- 762
					toColor(PALETTE.steelMid) -- 762
				) -- 762
				self:tileMasonry( -- 763
					assets, -- 763
					s, -- 763
					x0, -- 763
					y0, -- 763
					sw, -- 763
					sh -- 763
				) -- 763
			end -- 763
			::__continue81:: -- 763
			i = i + 1 -- 711
		end -- 711
	end -- 711
end -- 699
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity) -- 767
	local width = right - left -- 771
	local base = cam:sy(solid.y, depth.min) -- 772
	local top = cam:sy(solid.y + solid.h, depth.min) -- 773
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 774
	local slot = coverArt(solid) -- 775
	local layer = depthOrder(depth.min, 1) -- 776
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 777
	local capHeight = rear - top -- 778
	local center = (left + right) * 0.5 -- 779
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 779
		assets:tryPlace( -- 781
			"slab", -- 781
			"gate_sill_" .. tostring(solid.x), -- 781
			center, -- 781
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 781
			width + cam:len(34), -- 782
			cam:len(12), -- 782
			{ -- 782
				layer = 1, -- 782
				color = Color(180, 169, 150, 255) -- 782
			} -- 782
		) -- 782
	end -- 782
	draw:drawEllipse( -- 784
		Vec2( -- 784
			center, -- 784
			base + cam:len(3) -- 784
		), -- 784
		width * 0.52, -- 784
		cam:len(3.5), -- 785
		Color(13, 12, 16, 123 * opacity) -- 785
	) -- 785
	if slot ~= "fence" and capHeight > 1 then -- 785
		local timber = slot == "cover_wood" -- 787
		draw:drawRect( -- 788
			Rect(left, top, width, capHeight), -- 788
			occlusionTint( -- 788
				opacity, -- 788
				timber and Color(79, 63, 50, 239 * opacity) or Color(76, 78, 85, 239 * opacity) -- 789
			) -- 789
		) -- 789
		assets:tryPlace( -- 790
			timber and "slab" or "wall", -- 790
			key .. "_top", -- 790
			center, -- 790
			top, -- 790
			width, -- 790
			capHeight, -- 790
			{ -- 790
				layer = layer - 1, -- 791
				opacity = opacity * 0.92, -- 792
				color = occlusionTint( -- 793
					opacity, -- 793
					timber and Color(162, 126, 96, 255) or Color(158, 157, 156, 255) -- 793
				) -- 793
			} -- 793
		) -- 793
	end -- 793
	local rows = slot == "wall" and math.max( -- 796
		1, -- 796
		math.ceil(solid.h * 1.25 / solid.w) -- 796
	) or 1 -- 796
	local rowHeight = (top - base) / rows -- 797
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 798
	local color = occlusionTint(opacity, masonryColor) -- 799
	do -- 799
		local row = 0 -- 800
		while row < rows do -- 800
			do -- 800
				local tileKey = row == 0 and key or (key .. "_row_") .. tostring(row) -- 801
				if assets:tryPlace( -- 801
					slot, -- 802
					tileKey, -- 802
					center, -- 802
					base + row * rowHeight, -- 802
					width, -- 802
					rowHeight, -- 802
					{layer = layer, opacity = opacity, color = color, facing = row % 2 == 0 and 1 or -1} -- 802
				) then -- 802
					goto __continue94 -- 805
				end -- 805
				draw:drawRect( -- 807
					Rect(left, base, width, top - base), -- 807
					occlusionTint( -- 808
						opacity, -- 808
						toColor(PALETTE.steelMid, 255 * opacity) -- 808
					), -- 808
					1, -- 809
					toColor(theme.groundRim, 150 * opacity) -- 809
				) -- 809
				break -- 810
			end -- 810
			::__continue94:: -- 810
			row = row + 1 -- 800
		end -- 800
	end -- 800
end -- 767
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 814
	local columns = math.max( -- 818
		1, -- 818
		math.ceil(s.w / 154) -- 818
	) -- 818
	local rows = math.max( -- 819
		1, -- 819
		math.ceil(s.h / 100) -- 819
	) -- 819
	local tileW = width / columns -- 820
	local tileH = height / rows -- 821
	do -- 821
		local row = 0 -- 822
		while row < rows do -- 822
			do -- 822
				local column = 0 -- 823
				while column < columns do -- 823
					assets:tryPlace( -- 824
						"wall", -- 824
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 824
						x + (column + 0.5) * tileW, -- 825
						y + row * tileH, -- 825
						tileW + 0.5, -- 825
						tileH + 0.5, -- 825
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 826
					) -- 826
					column = column + 1 -- 823
				end -- 823
			end -- 823
			row = row + 1 -- 822
		end -- 822
	end -- 822
end -- 814
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 831
	local slot = coverArt(s) -- 838
	if not assets:tryPlace( -- 838
		slot, -- 839
		"cover_" .. tostring(s.x), -- 839
		x0 + sw * 0.5, -- 839
		y0, -- 839
		sw, -- 839
		sh, -- 839
		{layer = 1} -- 839
	) then -- 839
		fillVGradRect( -- 840
			fgDraw, -- 840
			x0, -- 840
			y0, -- 840
			sw, -- 840
			sh, -- 840
			toColor(PALETTE.steelDark), -- 840
			toColor(PALETTE.steelMid) -- 840
		) -- 840
		fgDraw:drawSegment( -- 841
			Vec2(x0, y0 + sh), -- 841
			Vec2(x0 + sw, y0 + sh), -- 841
			1.4, -- 841
			toColor(theme.groundRim) -- 841
		) -- 841
	end -- 841
	if not p.childMode and (p.coverHug or p.coverNear) then -- 841
		local plx = p.player.x -- 846
		local nearLeft = math.abs(plx - s.x) < 42 -- 847
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 848
		if nearLeft or nearRight then -- 848
			local edgeX = nearLeft and x0 - 2 or x0 + sw + 2 -- 850
			local col = p.coverHug and PALETTE.cyan or PALETTE.amber -- 851
			fgGlow:drawSegment( -- 852
				Vec2(edgeX, y0 + 4), -- 852
				Vec2(edgeX, y0 + sh + 4), -- 852
				p.coverHug and 3.5 or 2, -- 852
				toColor(col, p.coverHug and 220 or 140) -- 852
			) -- 852
			if p.coverHug then -- 852
				fillRadialGlow( -- 854
					fgGlow, -- 854
					edgeX, -- 854
					y0 + sh * 0.55, -- 854
					22, -- 854
					sh * 0.7, -- 854
					toColor(PALETTE.cyan, 85), -- 854
					Color(72, 224, 255, 0), -- 854
					14 -- 854
				) -- 854
			end -- 854
		end -- 854
	end -- 854
end -- 831
function StageRenderer.prototype.drawWinch(self, fgDraw, fgGlow, x0, y0, sw, sh, p, time) -- 860
	fillChamferBox( -- 866
		fgDraw, -- 866
		x0, -- 866
		y0, -- 866
		sw, -- 866
		sh, -- 866
		8, -- 866
		toColor(PALETTE.steelMid), -- 866
		1.5, -- 866
		toColor(PALETTE.rimSilver, 180) -- 866
	) -- 866
	local cx = x0 + sw * 0.5 -- 868
	local cy = y0 + sh * 0.55 -- 869
	local r = math.min(sw, sh) * 0.34 -- 870
	local spin = p.phase == "gate-hold" and time * 1.4 or 0 -- 871
	fgDraw:drawRing( -- 872
		Vec2(cx, cy), -- 872
		r * 0.62, -- 872
		r, -- 872
		toColor(PALETTE.steelDark), -- 872
		1.5, -- 872
		toColor(PALETTE.rimSilver, 210) -- 872
	) -- 872
	local k = 0 -- 873
	do -- 873
		k = 0 -- 874
		while k < 6 do -- 874
			local a = spin + k * math.pi / 3 -- 875
			fgDraw:drawSegment( -- 876
				Vec2( -- 877
					cx + math.cos(a) * r * 0.25, -- 877
					cy + math.sin(a) * r * 0.25 -- 877
				), -- 877
				Vec2( -- 878
					cx + math.cos(a) * r * 1.05, -- 878
					cy + math.sin(a) * r * 1.05 -- 878
				), -- 878
				2, -- 879
				toColor(PALETTE.rimSilver, 210) -- 880
			) -- 880
			k = k + 1 -- 874
		end -- 874
	end -- 874
	fgDraw:drawSegment( -- 884
		Vec2(cx, cy + r), -- 884
		Vec2(cx, y0 + sh + 220), -- 884
		1.6, -- 884
		toColor(PALETTE.steelLight, 175) -- 884
	) -- 884
	local active = p.phase == "gate-hold" or p.phase == "gate-send" -- 886
	local lampCol = active and PALETTE.cyan or PALETTE.amber -- 887
	local pulse = 0.7 + 0.3 * math.sin(time * 5) -- 888
	fgGlow:drawDot( -- 889
		Vec2(x0 + sw - 10, y0 + sh - 10), -- 889
		4, -- 889
		toColor(lampCol, 240 * pulse) -- 889
	) -- 889
	fillRadialGlow( -- 890
		fgGlow, -- 890
		x0 + sw - 10, -- 890
		y0 + sh - 10, -- 890
		22, -- 890
		22, -- 890
		toColor(lampCol, 95 * pulse), -- 890
		Color(lampCol.r, lampCol.g, lampCol.b, 0), -- 890
		12 -- 890
	) -- 890
end -- 860
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 893
	local ____temp_3 -- 901
	if p.room.story ~= nil then -- 901
		____temp_3 = p.room.story.gate -- 901
	else -- 901
		____temp_3 = nil -- 901
	end -- 901
	local g = ____temp_3 -- 901
	if g == nil then -- 901
		return -- 903
	end -- 903
	local closeFrac = 0.08 -- 906
	if p.phase == "gate-hold" then -- 906
		closeFrac = 0.08 + 0.36 * math.min( -- 908
			1, -- 908
			p.gateTick / math.max(1, g.holdTicks) -- 908
		) -- 908
	elseif p.phase == "gate-send" then -- 908
		closeFrac = 0.44 -- 910
	elseif p.phase == "gate-count" then -- 910
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 912
	elseif p.phase == "gate-walk" then -- 912
		closeFrac = 1 -- 914
	end -- 914
	local gx0 = cam:sx(848) -- 916
	local gx1 = cam:sx(1032) -- 917
	local topY = cam:sy(160) -- 918
	local botY = cam:sy(160 * (1 - closeFrac)) -- 919
	if topY > botY + 2 then -- 919
		fillVGradRect( -- 921
			fgDraw, -- 921
			gx0, -- 921
			botY, -- 921
			gx1 - gx0, -- 921
			topY - botY, -- 921
			toColor(PALETTE.steelDark), -- 921
			toColor(PALETTE.steelMid) -- 921
		) -- 921
		assets:tryPlace( -- 922
			"cover_wood", -- 922
			"gate_shutter", -- 922
			(gx0 + gx1) * 0.5, -- 922
			botY, -- 922
			gx1 - gx0, -- 923
			topY - botY, -- 923
			{layer = 6} -- 923
		) -- 923
	end -- 923
	if closeFrac < 0.98 then -- 923
		local gapH = math.max( -- 927
			8, -- 927
			botY - cam:sy(0) -- 927
		) -- 927
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 928
		fillVGradRect( -- 929
			fgGlow, -- 929
			gx0, -- 929
			cam:sy(0), -- 929
			gx1 - gx0, -- 929
			gapH, -- 929
			Color( -- 929
				140, -- 929
				210, -- 929
				255, -- 929
				math.floor(52 * pulse + 0.5) -- 929
			), -- 929
			Color(80, 160, 230, 0) -- 929
		) -- 929
	end -- 929
end -- 893
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, time) -- 933
	fillVGradRect( -- 940
		fgDraw, -- 940
		x0, -- 940
		y0, -- 940
		sw, -- 940
		sh, -- 940
		Color(15, 21, 34, 255), -- 940
		Color(32, 44, 66, 255) -- 940
	) -- 940
	fgDraw:drawRect( -- 941
		Rect(x0, y0, sw, sh), -- 941
		Color(0, 0, 0, 0), -- 941
		1.4, -- 941
		toColor(PALETTE.rimSilver, 165) -- 941
	) -- 941
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 941
		self:tileMasonry( -- 944
			assets, -- 944
			s, -- 944
			x0, -- 944
			y0, -- 944
			sw, -- 944
			sh -- 944
		) -- 944
		local ribs = 4 -- 946
		local r = 1 -- 947
		do -- 947
			r = 1 -- 948
			while r < ribs do -- 948
				local rx = x0 + sw * r / ribs -- 949
				fgDraw:drawSegment( -- 950
					Vec2(rx, y0), -- 950
					Vec2(rx, y0 + sh), -- 950
					2, -- 950
					Color(10, 15, 24, 210) -- 950
				) -- 950
				fgDraw:drawSegment( -- 951
					Vec2(rx + 2, y0), -- 951
					Vec2(rx + 2, y0 + sh), -- 951
					1, -- 951
					Color(68, 86, 114, 130) -- 951
				) -- 951
				r = r + 1 -- 948
			end -- 948
		end -- 948
		local bands = 4 -- 954
		local b = 1 -- 955
		do -- 955
			b = 1 -- 956
			while b < bands do -- 956
				local by = y0 + sh * b / bands -- 957
				fgDraw:drawSegment( -- 958
					Vec2(x0 + 4, by), -- 958
					Vec2(x0 + sw - 4, by), -- 958
					1.2, -- 958
					Color(52, 68, 92, 135) -- 958
				) -- 958
				b = b + 1 -- 956
			end -- 956
		end -- 956
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 961
		local slitY = y0 + sh * 0.56 -- 962
		local slitH = sh * 0.22 -- 963
		fgDraw:drawRect( -- 964
			Rect(slitX - 5, slitY, 10, slitH), -- 964
			Color(8, 12, 20, 245), -- 964
			1.2, -- 964
			toColor(PALETTE.amberDim, 190) -- 964
		) -- 964
		fgGlow:drawRect( -- 965
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 965
			toColor(PALETTE.amber, 190) -- 965
		) -- 965
		fillRadialGlow( -- 966
			fgGlow, -- 966
			slitX, -- 966
			slitY + slitH * 0.5, -- 966
			44, -- 966
			slitH * 0.7, -- 966
			Color(255, 206, 128, 52), -- 966
			Color(255, 180, 86, 0), -- 966
			14 -- 966
		) -- 966
	end -- 966
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 966
		local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 971
		local cx = x0 + sw * 0.5 -- 972
		local lampY = y0 - 8 -- 973
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 974
		if not opened then -- 974
			assets:tryPlace( -- 976
				"prop_tower_door", -- 976
				"tower_door", -- 976
				cx, -- 976
				y0 - doorHeight, -- 976
				sw, -- 976
				doorHeight, -- 976
				{layer = 2} -- 976
			) -- 976
		end -- 976
		assets:tryPlace( -- 978
			"prop_lantern", -- 978
			"tower_lantern", -- 978
			cx + sw * 0.43, -- 978
			lampY - sh * 0.36, -- 978
			sw * 0.17, -- 979
			sh * 0.84, -- 979
			{layer = 3} -- 979
		) -- 979
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 980
		local alpha = opened and 155 or 88 -- 981
		fgDraw:drawSegment( -- 983
			Vec2(x0 + 4, y0), -- 983
			Vec2(x0 + 4, y0 - sh * 3.8), -- 983
			4, -- 983
			Color(42, 52, 70, 255) -- 983
		) -- 983
		fgDraw:drawSegment( -- 984
			Vec2(x0 + sw - 4, y0), -- 984
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 984
			4, -- 984
			Color(42, 52, 70, 255) -- 984
		) -- 984
		fgDraw:drawSegment( -- 985
			Vec2(x0, y0), -- 985
			Vec2(x0 + sw, y0), -- 985
			2.5, -- 985
			toColor(PALETTE.amber, 210) -- 985
		) -- 985
		fillVGradRect( -- 987
			fgGlow, -- 988
			x0 + 6, -- 989
			y0 - sh * 3.8, -- 990
			sw - 12, -- 991
			sh * 3.8, -- 992
			Color( -- 993
				255, -- 993
				206, -- 993
				128, -- 993
				math.floor((opened and alpha or alpha * 0.25) * pulse + 0.5) -- 993
			), -- 993
			Color(255, 224, 168, opened and 180 or 62) -- 994
		) -- 994
		fillRadialGlow( -- 996
			fgGlow, -- 996
			cx, -- 996
			lampY, -- 996
			opened and 105 or 58, -- 996
			opened and 105 or 58, -- 996
			Color( -- 996
				255, -- 996
				232, -- 996
				178, -- 996
				math.floor(170 * pulse + 0.5) -- 996
			), -- 996
			Color(255, 180, 86, 0), -- 996
			18 -- 996
		) -- 996
		fgDraw:drawCircle( -- 997
			Vec2(cx, lampY), -- 997
			5.5, -- 997
			toColor(PALETTE.amberCore) -- 997
		) -- 997
	end -- 997
end -- 933
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1001
	local blades = math.max( -- 1008
		12, -- 1008
		math.floor(sw / 8) -- 1008
	) -- 1008
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1009
	local k = 0 -- 1010
	do -- 1010
		k = 0 -- 1011
		while k < blades do -- 1011
			local t = (k + 0.5) / blades -- 1012
			local bx = x0 + sw * t -- 1013
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1014
			local bh = sh * hRatio * 1.95 -- 1015
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1016
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1017
			fgDraw:drawPolygon( -- 1018
				{ -- 1018
					Vec2(bx - 7, y0), -- 1019
					Vec2(bx + 7, y0), -- 1020
					Vec2(bx + sway, y0 + bh) -- 1021
				}, -- 1021
				col -- 1022
			) -- 1022
			k = k + 1 -- 1011
		end -- 1011
	end -- 1011
	if nearPlayer then -- 1011
		fgGlow:drawSegment( -- 1025
			Vec2(x0, y0 + 2), -- 1025
			Vec2(x0 + sw, y0 + 2), -- 1025
			2, -- 1025
			toColor(PALETTE.emerald, 145) -- 1025
		) -- 1025
	end -- 1025
end -- 1001
function StageRenderer.prototype.drawArch(self, fgDraw, fgGlow, p, cam, theme) -- 1029
	local a = p.room.arch -- 1036
	if a.h <= 0 or a.x1 <= a.x0 then -- 1036
		return -- 1038
	end -- 1038
	local x0 = cam:sx(a.x0) -- 1040
	local x1 = cam:sx(a.x1) -- 1041
	local y0 = cam:sy(a.y) -- 1042
	local y1 = cam:sy(a.y + a.h) -- 1043
	local aw = x1 - x0 -- 1044
	local ah = y1 - y0 -- 1045
	fgDraw:drawRect( -- 1048
		Rect(x0, y0, aw, ah), -- 1048
		Color(5, 7, 11, 245) -- 1048
	) -- 1048
	fgDraw:drawSegment( -- 1050
		Vec2(x0, y0), -- 1050
		Vec2(x0, y1), -- 1050
		3, -- 1050
		toColor(PALETTE.rimSilver, 215) -- 1050
	) -- 1050
	fgDraw:drawSegment( -- 1051
		Vec2(x1, y0), -- 1051
		Vec2(x1, y1), -- 1051
		3, -- 1051
		toColor(PALETTE.rimSilver, 215) -- 1051
	) -- 1051
	fgDraw:drawSegment( -- 1052
		Vec2(x0 - 4, y1), -- 1052
		Vec2(x1 + 4, y1), -- 1052
		3.2, -- 1052
		toColor(PALETTE.rimSilver, 235) -- 1052
	) -- 1052
	if p.room.key == "outside" then -- 1052
		local arcR = math.min(aw * 0.46, ah * 0.72) -- 1055
		fgDraw:drawArc( -- 1056
			Vec2((x0 + x1) * 0.5, y1 - arcR - 2), -- 1056
			arcR, -- 1056
			0, -- 1056
			180, -- 1056
			2.2, -- 1056
			toColor(theme.accent, 195) -- 1056
		) -- 1056
		fillVGradRect( -- 1057
			fgGlow, -- 1057
			x0 + 6, -- 1057
			y0, -- 1057
			aw - 12, -- 1057
			ah * 0.65, -- 1057
			Color(86, 186, 236, 52), -- 1057
			Color(86, 186, 236, 0) -- 1057
		) -- 1057
	end -- 1057
end -- 1029
return ____exports -- 1029