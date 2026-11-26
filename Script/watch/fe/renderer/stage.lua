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
		self:drawDressing(assets, backdropKey, cam, progress) -- 73
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
end -- 53
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 124
	local w = cam.viewW -- 125
	local ground = cam.groundScreenY -- 126
	local x = w * (0.75 - progress * 0.29) -- 127
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 127
		assets:tryPlace( -- 129
			"pine", -- 129
			"mid_pine", -- 129
			x, -- 129
			ground - cam:len(12), -- 129
			cam:len(124), -- 129
			cam:len(138), -- 129
			{layer = 1, opacity = 0.52} -- 130
		) -- 130
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 130
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
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 136
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
	self:drawArch(fgDraw, p, cam) -- 294
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
						assets, -- 744
						x0, -- 744
						y0, -- 744
						sw, -- 744
						sh, -- 744
						p -- 744
					) -- 744
					goto __continue81 -- 745
				end -- 745
				if p.room.key == "tower" then -- 745
					self:drawTowerStructure( -- 750
						fgDraw, -- 750
						fgGlow, -- 750
						assets, -- 750
						x0, -- 750
						y0, -- 750
						sw, -- 750
						sh, -- 750
						s, -- 750
						p, -- 750
						time -- 750
					) -- 750
					goto __continue81 -- 751
				end -- 751
				if s.h <= 64 and s.y <= 2 then -- 751
					self:drawCoverBlock( -- 756
						fgDraw, -- 756
						fgGlow, -- 756
						assets, -- 756
						x0, -- 756
						y0, -- 756
						sw, -- 756
						sh, -- 756
						s, -- 756
						p, -- 756
						theme -- 756
					) -- 756
					goto __continue81 -- 757
				end -- 757
				fillVGradRect( -- 760
					fgDraw, -- 760
					x0, -- 760
					y0, -- 760
					sw, -- 760
					sh, -- 760
					toColor(PALETTE.steelDark), -- 760
					toColor(PALETTE.steelMid) -- 760
				) -- 760
				self:tileMasonry( -- 761
					assets, -- 761
					s, -- 761
					x0, -- 761
					y0, -- 761
					sw, -- 761
					sh -- 761
				) -- 761
			end -- 761
			::__continue81:: -- 761
			i = i + 1 -- 711
		end -- 711
	end -- 711
end -- 699
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity) -- 765
	local width = right - left -- 769
	local base = cam:sy(solid.y, depth.min) -- 770
	local top = cam:sy(solid.y + solid.h, depth.min) -- 771
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 772
	local slot = coverArt(solid) -- 773
	local layer = depthOrder(depth.min, 1) -- 774
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 775
	local capHeight = rear - top -- 776
	local center = (left + right) * 0.5 -- 777
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 777
		assets:tryPlace( -- 779
			"slab", -- 779
			"gate_sill_" .. tostring(solid.x), -- 779
			center, -- 779
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 779
			width + cam:len(34), -- 780
			cam:len(12), -- 780
			{ -- 780
				layer = 1, -- 780
				color = Color(180, 169, 150, 255) -- 780
			} -- 780
		) -- 780
	end -- 780
	draw:drawEllipse( -- 782
		Vec2( -- 782
			center, -- 782
			base + cam:len(3) -- 782
		), -- 782
		width * 0.52, -- 782
		cam:len(3.5), -- 783
		Color(13, 12, 16, 123 * opacity) -- 783
	) -- 783
	if slot ~= "fence" and capHeight > 1 then -- 783
		local timber = slot == "cover_wood" -- 785
		draw:drawRect( -- 786
			Rect(left, top, width, capHeight), -- 786
			occlusionTint( -- 786
				opacity, -- 786
				timber and Color(79, 63, 50, 239 * opacity) or Color(76, 78, 85, 239 * opacity) -- 787
			) -- 787
		) -- 787
		assets:tryPlace( -- 788
			timber and "slab" or "wall", -- 788
			key .. "_top", -- 788
			center, -- 788
			top, -- 788
			width, -- 788
			capHeight, -- 788
			{ -- 788
				layer = layer - 1, -- 789
				opacity = opacity * 0.92, -- 790
				color = occlusionTint( -- 791
					opacity, -- 791
					timber and Color(162, 126, 96, 255) or Color(158, 157, 156, 255) -- 791
				) -- 791
			} -- 791
		) -- 791
	end -- 791
	local rows = slot == "wall" and math.max( -- 794
		1, -- 794
		math.ceil(solid.h * 1.25 / solid.w) -- 794
	) or 1 -- 794
	local rowHeight = (top - base) / rows -- 795
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 796
	local color = occlusionTint(opacity, masonryColor) -- 797
	do -- 797
		local row = 0 -- 798
		while row < rows do -- 798
			do -- 798
				local tileKey = row == 0 and key or (key .. "_row_") .. tostring(row) -- 799
				if assets:tryPlace( -- 799
					slot, -- 800
					tileKey, -- 800
					center, -- 800
					base + row * rowHeight, -- 800
					width, -- 800
					rowHeight, -- 800
					{layer = layer, opacity = opacity, color = color, facing = row % 2 == 0 and 1 or -1} -- 800
				) then -- 800
					goto __continue94 -- 803
				end -- 803
				draw:drawRect( -- 805
					Rect(left, base, width, top - base), -- 805
					occlusionTint( -- 806
						opacity, -- 806
						toColor(PALETTE.steelMid, 255 * opacity) -- 806
					), -- 806
					1, -- 807
					toColor(theme.groundRim, 150 * opacity) -- 807
				) -- 807
				break -- 808
			end -- 808
			::__continue94:: -- 808
			row = row + 1 -- 798
		end -- 798
	end -- 798
end -- 765
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 812
	local columns = math.max( -- 816
		1, -- 816
		math.ceil(s.w / 154) -- 816
	) -- 816
	local rows = math.max( -- 817
		1, -- 817
		math.ceil(s.h / 100) -- 817
	) -- 817
	local tileW = width / columns -- 818
	local tileH = height / rows -- 819
	do -- 819
		local row = 0 -- 820
		while row < rows do -- 820
			do -- 820
				local column = 0 -- 821
				while column < columns do -- 821
					assets:tryPlace( -- 822
						"wall", -- 822
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 822
						x + (column + 0.5) * tileW, -- 823
						y + row * tileH, -- 823
						tileW + 0.5, -- 823
						tileH + 0.5, -- 823
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 824
					) -- 824
					column = column + 1 -- 821
				end -- 821
			end -- 821
			row = row + 1 -- 820
		end -- 820
	end -- 820
end -- 812
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 829
	local slot = coverArt(s) -- 836
	if not assets:tryPlace( -- 836
		slot, -- 837
		"cover_" .. tostring(s.x), -- 837
		x0 + sw * 0.5, -- 837
		y0, -- 837
		sw, -- 837
		sh, -- 837
		{layer = 1} -- 837
	) then -- 837
		fillVGradRect( -- 838
			fgDraw, -- 838
			x0, -- 838
			y0, -- 838
			sw, -- 838
			sh, -- 838
			toColor(PALETTE.steelDark), -- 838
			toColor(PALETTE.steelMid) -- 838
		) -- 838
		fgDraw:drawSegment( -- 839
			Vec2(x0, y0 + sh), -- 839
			Vec2(x0 + sw, y0 + sh), -- 839
			1.4, -- 839
			toColor(theme.groundRim) -- 839
		) -- 839
	end -- 839
	if not p.childMode and (p.coverHug or p.coverNear) then -- 839
		local plx = p.player.x -- 844
		local nearLeft = math.abs(plx - s.x) < 42 -- 845
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 846
		if nearLeft or nearRight then -- 846
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 848
			local isWood = slot == "cover_wood" -- 849
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 850
			fgDraw:drawSegment( -- 851
				Vec2(edgeX, y0 + 4), -- 851
				Vec2(edgeX, y0 + sh + 2), -- 851
				p.coverHug and 2 or 1.2, -- 851
				toColor(col, p.coverHug and 205 or 120) -- 851
			) -- 851
		end -- 851
	end -- 851
end -- 829
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p) -- 856
	local cx = x0 + sw * 0.5 -- 862
	local cy = y0 + sh * 0.55 -- 863
	local ropeWidth = math.max(1, sw * 0.023) -- 864
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 865
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 866
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 867
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 868
	draw:drawEllipse( -- 869
		Vec2(cx, y0), -- 869
		sw * 0.53, -- 869
		sh * 0.07, -- 869
		Color(10, 8, 9, 150) -- 869
	) -- 869
	draw:drawSegment( -- 870
		drum, -- 870
		bend, -- 870
		ropeWidth, -- 870
		Color(111, 86, 57, 239) -- 870
	) -- 870
	draw:drawSegment( -- 871
		bend, -- 871
		ropeTop, -- 871
		ropeWidth, -- 871
		Color(111, 86, 57, 239) -- 871
	) -- 871
	if assets:tryPlace( -- 871
		"prop_winch", -- 872
		"gate_winch", -- 872
		cx, -- 872
		y0 + sh * 0.5, -- 872
		sw, -- 872
		sh, -- 872
		{layer = 2} -- 872
	) then -- 872
		return -- 873
	end -- 873
	local timber = Color(75, 51, 34, 255) -- 875
	draw:drawSegment( -- 876
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 876
		Vec2(cx, y0 + sh * 0.86), -- 876
		sw * 0.06, -- 876
		timber -- 876
	) -- 876
	draw:drawSegment( -- 877
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 877
		Vec2(cx, y0 + sh * 0.86), -- 877
		sw * 0.06, -- 877
		timber -- 877
	) -- 877
	draw:drawRect( -- 878
		Rect(x0, y0, sw, sh * 0.12), -- 878
		timber -- 878
	) -- 878
	local radius = math.min(sw, sh) * 0.21 -- 879
	draw:drawCircle( -- 880
		Vec2(cx, cy), -- 880
		radius, -- 880
		Color(48, 41, 37, 255) -- 880
	) -- 880
	do -- 880
		local i = -2 -- 881
		while i <= 2 do -- 881
			local x = cx + i * radius * 0.28 -- 882
			draw:drawSegment( -- 883
				Vec2(x, cy - radius * 0.62), -- 883
				Vec2(x, cy + radius * 0.62), -- 883
				ropeWidth, -- 883
				Color(135, 103, 68, 240) -- 884
			) -- 884
			i = i + 1 -- 881
		end -- 881
	end -- 881
end -- 856
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
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1024
	local a = p.room.arch -- 1029
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1029
		return -- 1031
	end -- 1031
	local x0 = cam:sx(a.x0) -- 1033
	local x1 = cam:sx(a.x1) -- 1034
	local y0 = cam:sy(a.y) -- 1035
	local y1 = cam:sy(a.y + a.h) -- 1036
	local cx = (x0 + x1) * 0.5 -- 1037
	local rx = (x1 - x0) * 0.5 -- 1038
	local rise = cam:len(9) -- 1039
	local rim = cam:len(7) -- 1040
	local slices = 9 -- 1041
	local mortar = Color(31, 32, 35, 255) -- 1042
	local function point(i, edge) -- 1043
		local angle = math.pi * i / slices -- 1044
		return Vec2( -- 1045
			cx + math.cos(angle) * (rx + edge), -- 1045
			y1 + math.sin(angle) * (rise + edge) -- 1045
		) -- 1045
	end -- 1043
	local opening = { -- 1047
		Vec2(x0, y0), -- 1047
		Vec2(x1, y0) -- 1047
	} -- 1047
	do -- 1047
		local i = 0 -- 1048
		while i <= slices do -- 1048
			opening[#opening + 1] = point(i, 0) -- 1049
			i = i + 1 -- 1048
		end -- 1048
	end -- 1048
	draw:drawPolygon( -- 1051
		opening, -- 1051
		Color(13, 15, 20, 248) -- 1051
	) -- 1051
	draw:drawRect( -- 1052
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1052
		Color(62, 63, 67, 255), -- 1052
		1, -- 1052
		mortar -- 1052
	) -- 1052
	draw:drawRect( -- 1053
		Rect(x1, y0, rim, y1 - y0), -- 1053
		Color(72, 72, 74, 255), -- 1053
		1, -- 1053
		mortar -- 1053
	) -- 1053
	do -- 1053
		local i = 0 -- 1054
		while i < slices do -- 1054
			local shade = 77 + i % 3 * 8 -- 1055
			draw:drawPolygon( -- 1056
				{ -- 1056
					point(i, 0), -- 1056
					point(i, rim), -- 1056
					point(i + 1, rim), -- 1056
					point(i + 1, 0) -- 1056
				}, -- 1056
				Color(shade, shade, shade + 1, 255), -- 1057
				1, -- 1057
				mortar -- 1057
			) -- 1057
			i = i + 1 -- 1054
		end -- 1054
	end -- 1054
end -- 1024
return ____exports -- 1024