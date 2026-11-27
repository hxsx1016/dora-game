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
--- 将特定明代场景道具（空筐墙/粮袋堆/木帘/窗板/石井栏）映射至专属 props_ming.clip 手绘精灵，避免退化为通用砖木块
local function dedicatedSolidProp(solid) -- 46
	if solid.art == "basket_wall" then -- 47
		return {clip = "basket_wall", natAR = 144 / 90, heightMul = 1.08, tileable = true} -- 48
	end -- 48
	if solid.art == "curtain" then -- 50
		return {clip = "curtain", natAR = 144 / 126, heightMul = 1.06, tileable = false} -- 51
	end -- 51
	if solid.art == "board" then -- 53
		return {clip = "window_board", natAR = 88 / 144, heightMul = 1.04, tileable = false} -- 54
	end -- 54
	if solid.id == "s1_well" or solid.art == "well" or (string.find(solid.label, "井背", nil, true) or 0) - 1 >= 0 then -- 56
		return {clip = "well_curb", natAR = 144 / 120, heightMul = 1.12, tileable = false} -- 57
	end -- 57
	if (string.find(solid.label, "粮台", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "粮袋", nil, true) or 0) - 1 >= 0 then -- 59
		return {clip = "grain_sack", natAR = 144 / 74, heightMul = 1.12, tileable = true} -- 60
	end -- 60
	return nil -- 62
end -- 46
local function coverArt(solid) -- 65
	if solid.art == "gate_post" or solid.art == "wall" or solid.art == "latch" then -- 66
		return "wall" -- 67
	end -- 67
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 69
		return "cover_wood" -- 70
	end -- 70
	if solid.art == "fence" then -- 72
		return "fence" -- 73
	end -- 73
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 75
end -- 65
____exports.StageRenderer = __TS__Class() -- 78
local StageRenderer = ____exports.StageRenderer -- 78
StageRenderer.name = "StageRenderer" -- 78
function StageRenderer.prototype.____constructor(self) -- 78
end -- 78
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 80
	local w = cam.viewW -- 88
	local h = cam.viewH -- 89
	local theme = themeOf(p.room.key) -- 90
	local seed = roomSeed(p.room.key) -- 91
	local span = math.max(1, p.room.maxX - p.room.minX) -- 93
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 94
	local backdropKey = theme.backdropKey or p.room.key -- 95
	local farSlot = "bgFar_" .. backdropKey -- 96
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 99
	local artH = artW * 9 / 16 -- 100
	local artY = math.min( -- 101
		0, -- 101
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 101
	) -- 101
	if assets:tryPlace( -- 102
		farSlot, -- 102
		"scene", -- 102
		w * (0.5 - progress * 0.08), -- 102
		artY, -- 102
		artW, -- 102
		artH -- 102
	) then -- 102
		self:drawDressing(assets, backdropKey, cam, progress) -- 103
		local y = cam.groundScreenY -- 104
		fillVGradRect( -- 105
			bgDraw, -- 105
			0, -- 105
			0, -- 105
			w, -- 105
			h, -- 105
			toColor(PALETTE.voidDark), -- 105
			toColor(theme.skyMid) -- 105
		) -- 105
		fillVGradRect( -- 106
			bgGlow, -- 106
			0, -- 106
			y - 1, -- 106
			w, -- 106
			h * 0.14, -- 106
			Color(43, 49, 63, 15), -- 106
			Color(43, 49, 63, 0) -- 106
		) -- 106
		return -- 107
	end -- 107
	local splitY = h * 0.46 -- 111
	fillVGradRect( -- 112
		bgDraw, -- 112
		0, -- 112
		splitY, -- 112
		w, -- 112
		h - splitY, -- 112
		toColor(theme.skyMid), -- 112
		toColor(theme.skyTop) -- 112
	) -- 112
	fillVGradRect( -- 113
		bgDraw, -- 113
		0, -- 113
		0, -- 113
		w, -- 113
		splitY, -- 113
		toColor(theme.skyHorizon), -- 113
		toColor(theme.skyMid) -- 113
	) -- 113
	if theme.showMoon then -- 116
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 117
		local my = h * theme.moonYFrac -- 118
		local mr = math.max(18, h * 0.044) -- 119
		fillRadialGlow( -- 120
			bgGlow, -- 120
			mx, -- 120
			my, -- 120
			mr * 5.2, -- 120
			mr * 5.2, -- 120
			Color(156, 186, 212, 26), -- 120
			Color(20, 32, 52, 0), -- 120
			20 -- 120
		) -- 120
		fillRadialGlow( -- 121
			bgGlow, -- 121
			mx, -- 121
			my, -- 121
			mr * 2.2, -- 121
			mr * 2.2, -- 121
			Color(210, 226, 238, 56), -- 121
			Color(64, 96, 134, 0), -- 121
			18 -- 121
		) -- 121
		bgDraw:drawCircle( -- 122
			Vec2(mx, my), -- 122
			mr, -- 122
			Color(224, 236, 244, 220) -- 122
		) -- 122
		bgDraw:drawCircle( -- 123
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 123
			mr * 0.84, -- 123
			toColor(theme.skyTop, 118) -- 123
		) -- 123
	end -- 123
	if p.room.key == "forest" then -- 126
		self:drawFarForest( -- 127
			bgDraw, -- 127
			w, -- 127
			h, -- 127
			cam, -- 127
			theme, -- 127
			seed -- 127
		) -- 127
		self:drawMidForest( -- 128
			bgDraw, -- 128
			bgGlow, -- 128
			w, -- 128
			h, -- 128
			cam, -- 128
			theme, -- 128
			time, -- 128
			seed -- 128
		) -- 128
	else -- 128
		self:drawFarMingTown( -- 130
			bgDraw, -- 130
			w, -- 130
			h, -- 130
			cam, -- 130
			theme, -- 130
			seed -- 130
		) -- 130
	end -- 130
	if theme.showTowerBeacon then -- 132
		self:drawDistantNorthTower( -- 133
			bgDraw, -- 133
			bgGlow, -- 133
			w, -- 133
			h, -- 133
			cam, -- 133
			p, -- 133
			time -- 133
		) -- 133
	end -- 133
	local fogH = h * 0.34 -- 137
	fillVGradRect( -- 138
		bgGlow, -- 139
		0, -- 140
		cam.groundScreenY - 10, -- 141
		w, -- 142
		fogH, -- 143
		toColor(theme.fogBottom), -- 144
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 145
	) -- 145
end -- 80
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 149
	local w = cam.viewW -- 150
	local ground = cam.groundScreenY -- 151
	local x = w * (0.76 - progress * 0.22) -- 152
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 154
		assets:tryPlace( -- 155
			"pine", -- 155
			"mid_pine", -- 155
			x, -- 155
			ground - cam:len(6), -- 155
			cam:len(122), -- 155
			cam:len(107), -- 155
			{layer = 1, opacity = 0.5} -- 156
		) -- 156
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 157
		assets:tryPlace( -- 158
			"eaves", -- 158
			"mid_eaves", -- 158
			x, -- 158
			ground - cam:len(4), -- 158
			cam:len(176), -- 158
			cam:len(96), -- 158
			{layer = 1, opacity = 0.44} -- 159
		) -- 159
	else -- 159
		assets:tryPlace( -- 161
			"cover_stone", -- 161
			"mid_ruin", -- 161
			x, -- 161
			ground - cam:len(4), -- 161
			cam:len(114), -- 161
			cam:len(50), -- 161
			{layer = 1, opacity = 0.44} -- 162
		) -- 162
	end -- 162
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 164
		assets:tryPlace( -- 165
			"prop_lantern", -- 165
			"mid_lantern", -- 165
			w * (0.27 - progress * 0.18), -- 165
			ground + cam:len(96), -- 166
			cam:len(20), -- 166
			cam:len(28), -- 166
			{layer = 2, opacity = 0.82} -- 166
		) -- 166
	end -- 166
end -- 149
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 171
	local theme = themeOf("checkpoint") -- 178
	local splitY = h * 0.44 -- 179
	fillVGradRect( -- 180
		bgDraw, -- 180
		0, -- 180
		splitY, -- 180
		w, -- 180
		h - splitY, -- 180
		toColor(theme.skyMid), -- 180
		toColor(theme.skyTop) -- 180
	) -- 180
	fillVGradRect( -- 181
		bgDraw, -- 181
		0, -- 181
		0, -- 181
		w, -- 181
		splitY, -- 181
		toColor(theme.skyHorizon), -- 181
		toColor(theme.skyMid) -- 181
	) -- 181
	local mx = w * 0.61 -- 184
	local my = h * 0.74 -- 185
	local mr = h * 0.072 -- 186
	fillRadialGlow( -- 187
		bgGlow, -- 187
		mx, -- 187
		my, -- 187
		mr * 4.4, -- 187
		mr * 4.4, -- 187
		Color(164, 184, 198, 28), -- 187
		Color(16, 22, 34, 0), -- 187
		22 -- 187
	) -- 187
	fillRadialGlow( -- 188
		bgGlow, -- 188
		mx, -- 188
		my, -- 188
		mr * 1.9, -- 188
		mr * 1.9, -- 188
		Color(214, 224, 232, 62), -- 188
		Color(36, 48, 64, 0), -- 188
		18 -- 188
	) -- 188
	bgDraw:drawCircle( -- 189
		Vec2(mx, my), -- 189
		mr, -- 189
		Color(234, 238, 236, 225) -- 189
	) -- 189
	bgDraw:drawCircle( -- 190
		Vec2(mx + mr * 0.24, my + mr * 0.14), -- 190
		mr * 0.85, -- 190
		Color(14, 18, 28, 118) -- 190
	) -- 190
	local groundY = h * 0.19 -- 193
	local i = 0 -- 194
	do -- 194
		i = 0 -- 195
		while i < 14 do -- 195
			local bx = i * (w / 12) - 24 + math.sin(time * 0.06) * 4 -- 196
			local bw = 58 + hash01(i * 13 + 3) * 82 -- 197
			local bh = h * (0.14 + hash01(i * 29 + 7) * 0.22) -- 198
			local ridgeH = 14 + hash01(i * 19) * 18 -- 199
			bgDraw:drawPolygon( -- 200
				{ -- 200
					Vec2(bx, groundY), -- 201
					Vec2(bx + bw, groundY), -- 202
					Vec2(bx + bw, groundY + bh), -- 203
					Vec2(bx + bw * 0.5, groundY + bh + ridgeH), -- 204
					Vec2(bx, groundY + bh) -- 205
				}, -- 205
				Color(14, 18, 26, 255) -- 206
			) -- 206
			i = i + 1 -- 195
		end -- 195
	end -- 195
	local tx = w * 0.83 -- 210
	local ty0 = groundY -- 211
	local ty1 = h * 0.58 -- 212
	bgDraw:drawPolygon( -- 213
		{ -- 213
			Vec2(tx - 24, ty0), -- 214
			Vec2(tx + 24, ty0), -- 215
			Vec2(tx + 15, ty1), -- 216
			Vec2(tx - 15, ty1) -- 217
		}, -- 217
		Color(18, 23, 34, 255), -- 218
		1.1, -- 218
		Color(72, 84, 98, 130) -- 218
	) -- 218
	bgDraw:drawPolygon( -- 219
		{ -- 219
			Vec2(tx - 32, ty1), -- 220
			Vec2(tx + 32, ty1), -- 221
			Vec2(tx, ty1 + 26) -- 222
		}, -- 222
		Color(24, 30, 42, 255) -- 223
	) -- 223
	local pulse = 0.82 + 0.18 * math.sin(time * 2.2) -- 224
	local lampY = ty1 - 14 -- 225
	fillRadialGlow( -- 226
		bgGlow, -- 226
		tx, -- 226
		lampY, -- 226
		64 * pulse, -- 226
		64 * pulse, -- 226
		Color(238, 198, 128, 118), -- 226
		Color(214, 162, 86, 0), -- 226
		18 -- 226
	) -- 226
	bgGlow:drawDot( -- 227
		Vec2(tx, lampY), -- 227
		4.2, -- 227
		Color(252, 240, 206, 245) -- 227
	) -- 227
	fillVGradRect( -- 230
		bgDraw, -- 230
		0, -- 230
		0, -- 230
		w, -- 230
		groundY, -- 230
		Color(9, 11, 17, 255), -- 230
		Color(20, 24, 34, 255) -- 230
	) -- 230
	bgDraw:drawSegment( -- 231
		Vec2(0, groundY), -- 231
		Vec2(w, groundY), -- 231
		1.4, -- 231
		toColor(PALETTE.silkDim, 145) -- 231
	) -- 231
	fillVGradRect( -- 232
		bgGlow, -- 232
		0, -- 232
		groundY, -- 232
		w, -- 232
		h * 0.18, -- 232
		Color(46, 56, 72, 42), -- 232
		Color(20, 26, 38, 0) -- 232
	) -- 232
	local sx = w * 0.64 -- 235
	bgDraw:drawPolygon( -- 236
		{ -- 236
			Vec2(sx - 24, groundY + 14), -- 237
			Vec2(sx + 14, groundY + 18), -- 238
			Vec2(sx + 16, groundY + 116), -- 239
			Vec2(sx - 16, groundY + 116) -- 240
		}, -- 240
		Color(14, 18, 26, 255), -- 241
		1.1, -- 241
		Color(118, 132, 144, 125) -- 241
	) -- 241
	bgDraw:drawSegment( -- 242
		Vec2(sx - 5, groundY + 46), -- 242
		Vec2(sx - 10, groundY + 2), -- 242
		5.5, -- 242
		Color(12, 16, 24, 255) -- 242
	) -- 242
	bgDraw:drawSegment( -- 243
		Vec2(sx + 6, groundY + 46), -- 243
		Vec2(sx + 12, groundY + 2), -- 243
		5.5, -- 243
		Color(16, 20, 30, 255) -- 243
	) -- 243
	bgDraw:drawCircle( -- 244
		Vec2(sx + 1, groundY + 132), -- 244
		11, -- 244
		Color(18, 22, 32, 255) -- 244
	) -- 244
	bgDraw:drawPolygon( -- 245
		{ -- 245
			Vec2(sx - 18, groundY + 135), -- 246
			Vec2(sx + 20, groundY + 135), -- 247
			Vec2(sx + 1, groundY + 148) -- 248
		}, -- 248
		Color(44, 50, 58, 250) -- 249
	) -- 249
	bgDraw:drawSegment( -- 250
		Vec2(sx + 4, groundY + 96), -- 250
		Vec2(sx + 46, groundY + 88), -- 250
		3, -- 250
		Color(78, 56, 40, 255) -- 250
	) -- 250
	local cx = w * 0.725 -- 252
	bgDraw:drawPolygon( -- 253
		{ -- 253
			Vec2(cx - 18, groundY + 14), -- 254
			Vec2(cx + 16, groundY + 14), -- 255
			Vec2(cx + 11, groundY + 78), -- 256
			Vec2(cx - 11, groundY + 78) -- 257
		}, -- 257
		Color(148, 108, 66, 236), -- 258
		1.2, -- 258
		Color(214, 186, 146, 195) -- 258
	) -- 258
	bgDraw:drawSegment( -- 259
		Vec2(cx - 4, groundY + 22), -- 259
		Vec2(cx - 5, groundY + 2), -- 259
		3.8, -- 259
		Color(24, 20, 24, 255) -- 259
	) -- 259
	bgDraw:drawSegment( -- 260
		Vec2(cx + 4, groundY + 22), -- 260
		Vec2(cx + 5, groundY + 2), -- 260
		3.8, -- 260
		Color(30, 26, 30, 255) -- 260
	) -- 260
	bgDraw:drawCircle( -- 261
		Vec2(cx + 1, groundY + 88), -- 261
		10, -- 261
		Color(212, 192, 168, 240) -- 261
	) -- 261
	fillRadialGlow( -- 262
		bgGlow, -- 262
		cx + 10, -- 262
		groundY + 52, -- 262
		26, -- 262
		26, -- 262
		Color(238, 198, 128, 96), -- 262
		Color(214, 162, 86, 0), -- 262
		14 -- 262
	) -- 262
	bgGlow:drawDot( -- 263
		Vec2(cx + 10, groundY + 52), -- 263
		2.8, -- 263
		Color(252, 238, 202, 240) -- 263
	) -- 263
end -- 171
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 267
	local theme = themeOf(p.room.key) -- 277
	self:drawFloors( -- 278
		fgDraw, -- 278
		assets, -- 278
		p, -- 278
		cam, -- 278
		theme -- 278
	) -- 278
	self:drawStairs( -- 279
		fgDraw, -- 279
		fgGlow, -- 279
		assets, -- 279
		p, -- 279
		cam, -- 279
		theme -- 279
	) -- 279
	self:drawSolids( -- 280
		fgDraw, -- 280
		fgGlow, -- 280
		assets, -- 280
		p, -- 280
		cam, -- 280
		theme, -- 280
		time, -- 280
		occlusion, -- 280
		fadeDt -- 280
	) -- 280
	if p.room.key == "gate" then -- 281
		self:drawGateShutter( -- 282
			fgDraw, -- 282
			fgGlow, -- 282
			assets, -- 282
			p, -- 282
			cam, -- 282
			time -- 282
		) -- 282
	end -- 282
	self:drawArch(fgDraw, p, cam) -- 284
end -- 267
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 288
	fillVGradRect( -- 296
		fgDraw, -- 296
		0, -- 296
		h - h * 0.15, -- 296
		w, -- 296
		h * 0.15, -- 296
		Color(4, 6, 12, 0), -- 296
		Color(4, 6, 12, 126) -- 296
	) -- 296
	fillVGradRect( -- 297
		fgDraw, -- 297
		0, -- 297
		0, -- 297
		w, -- 297
		h * 0.12, -- 297
		Color(4, 6, 12, 165), -- 297
		Color(4, 6, 12, 0) -- 297
	) -- 297
end -- 288
function StageRenderer.prototype.drawFarMingTown(self, bgDraw, w, h, cam, theme, seed) -- 301
	local baseY = cam.groundScreenY - 8 -- 309
	local shift = -cam.x * 0.2 * cam.ppu -- 310
	local colW = 112 -- 311
	local first = math.floor((-shift - colW) / colW) -- 312
	local count = math.ceil(w / colW) + 3 -- 313
	local i = 0 -- 314
	do -- 314
		i = 0 -- 315
		while i < count do -- 315
			local idx = first + i -- 316
			local r1 = hash01(seed + idx * 13.7) -- 317
			local r2 = hash01(seed + idx * 29.3) -- 318
			local x = idx * colW + shift -- 319
			local bw = colW * (0.72 + r1 * 0.42) -- 320
			local bh = h * (0.14 + r2 * 0.24) -- 321
			local ridgeH = 14 + r1 * 18 -- 322
			bgDraw:drawPolygon( -- 323
				{ -- 323
					Vec2(x, baseY), -- 324
					Vec2(x + bw, baseY), -- 325
					Vec2(x + bw, baseY + bh), -- 326
					Vec2(x + bw * 0.5, baseY + bh + ridgeH), -- 327
					Vec2(x, baseY + bh) -- 328
				}, -- 328
				toColor(theme.farBuilding) -- 329
			) -- 329
			i = i + 1 -- 315
		end -- 315
	end -- 315
end -- 301
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 333
	local baseY = cam.groundScreenY - 8 -- 341
	local shift = -cam.x * 0.22 * cam.ppu -- 342
	local step = 76 -- 343
	local first = math.floor((-shift - step) / step) -- 344
	local count = math.ceil(w / step) + 4 -- 345
	local i = 0 -- 346
	do -- 346
		i = 0 -- 347
		while i < count do -- 347
			local idx = first + i -- 348
			local r1 = hash01(seed + idx * 11.3) -- 349
			local r2 = hash01(seed + idx * 23.9) -- 350
			local cx = idx * step + shift -- 351
			local tw = 34 + r1 * 38 -- 352
			local th = h * (0.24 + r2 * 0.34) -- 353
			bgDraw:drawPolygon( -- 354
				{ -- 354
					Vec2(cx - tw, baseY), -- 355
					Vec2(cx + tw, baseY), -- 356
					Vec2(cx, baseY + th) -- 357
				}, -- 357
				toColor(theme.farBuilding) -- 358
			) -- 358
			bgDraw:drawPolygon( -- 359
				{ -- 359
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 360
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 361
					Vec2(cx, baseY + th * 1.12) -- 362
				}, -- 362
				toColor(theme.farBuilding) -- 363
			) -- 363
			i = i + 1 -- 347
		end -- 347
	end -- 347
end -- 333
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 367
	local baseY = cam.groundScreenY - 4 -- 377
	local shift = -cam.x * 0.52 * cam.ppu -- 378
	local span = 156 -- 379
	local first = math.floor((-shift - span) / span) -- 380
	local count = math.ceil(w / span) + 3 -- 381
	local col = toColor(theme.midBuilding) -- 382
	local i = 0 -- 384
	do -- 384
		i = 0 -- 385
		while i < count do -- 385
			local idx = first + i -- 386
			local r = hash01(seed + idx * 19.7) -- 387
			local x = idx * span + shift -- 388
			local trunkW = 14 + r * 14 -- 389
			local sway = math.sin(time * 0.9 + idx) * 4 -- 390
			bgDraw:drawPolygon( -- 391
				{ -- 391
					Vec2(x - trunkW * 0.5, baseY), -- 392
					Vec2(x + trunkW * 0.5, baseY), -- 393
					Vec2(x + trunkW * 0.25 + sway, h), -- 394
					Vec2(x - trunkW * 0.3 + sway, h) -- 395
				}, -- 395
				col -- 396
			) -- 396
			if idx % 3 == 0 then -- 398
				bgGlow:drawVertices({ -- 399
					{ -- 400
						Vec2(x + 40, h), -- 400
						Color(110, 232, 200, 26) -- 400
					}, -- 400
					{ -- 401
						Vec2(x + 115, h), -- 401
						Color(110, 232, 200, 0) -- 401
					}, -- 401
					{ -- 402
						Vec2(x - 60, baseY), -- 402
						Color(110, 232, 200, 0) -- 402
					} -- 402
				}) -- 402
			end -- 402
			i = i + 1 -- 385
		end -- 385
	end -- 385
end -- 367
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 408
	local scale = 0.55 -- 418
	if p.room.key == "village" then -- 419
		scale = 0.72 -- 420
	elseif p.room.key == "forest" then -- 421
		scale = 0.92 -- 422
	elseif p.room.key == "tower" then -- 423
		scale = 1.15 -- 424
	end -- 424
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 426
	local baseY = cam.groundScreenY - 8 -- 427
	local towerH = h * 0.42 * scale -- 428
	local bw = 20 * scale -- 429
	bgDraw:drawPolygon( -- 430
		{ -- 430
			Vec2(tx - bw, baseY), -- 431
			Vec2(tx + bw, baseY), -- 432
			Vec2(tx + bw * 0.45, baseY + towerH), -- 433
			Vec2(tx - bw * 0.45, baseY + towerH) -- 434
		}, -- 434
		Color(14, 24, 38, 240) -- 435
	) -- 435
	bgDraw:drawSegment( -- 436
		Vec2(tx, baseY + towerH), -- 436
		Vec2(tx, baseY + towerH + 28 * scale), -- 436
		1.8, -- 436
		Color(180, 210, 238, 200) -- 436
	) -- 436
	local topY = baseY + towerH + 24 * scale -- 438
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 439
	fillRadialGlow( -- 440
		bgGlow, -- 440
		tx, -- 440
		topY, -- 440
		56 * scale * pulse, -- 440
		56 * scale * pulse, -- 440
		Color(255, 224, 152, 118), -- 440
		Color(255, 190, 96, 0), -- 440
		18 -- 440
	) -- 440
	bgGlow:drawDot( -- 441
		Vec2(tx, topY), -- 441
		3.6 * scale, -- 441
		Color(255, 246, 220, 255) -- 441
	) -- 441
end -- 408
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 444
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 451
	do -- 451
		local i = 0 -- 452
		while i < #p.room.floors do -- 452
			local floor = p.room.floors[i + 1] -- 453
			local left = cam:sx(floor.x0) -- 454
			local right = cam:sx(floor.x1) -- 455
			local isMain = floor.y <= 0.1 -- 456
			local ____isMain_0 -- 457
			if isMain then -- 457
				____isMain_0 = p.room.depth -- 457
			else -- 457
				____isMain_0 = nil -- 457
			end -- 457
			local road = ____isMain_0 -- 457
			local top = cam:sy(floor.y, road and road.min or 0) -- 458
			if road ~= nil then -- 459
				self:drawRoad( -- 460
					fgDraw, -- 460
					assets, -- 460
					i, -- 460
					left, -- 460
					right, -- 460
					top, -- 460
					cam:sy(floor.y, road.max), -- 460
					cam, -- 460
					theme -- 460
				) -- 460
			end -- 460
			local height = cam:len(isMain and 22 or 12) -- 462
			local bottom = top - height -- 463
			if isMain and bottom > 0 then -- 464
				fillVGradRect( -- 465
					fgDraw, -- 465
					left, -- 465
					0, -- 465
					right - left, -- 465
					bottom + 1, -- 465
					toColor(PALETTE.voidDark), -- 466
					toColor(theme.groundBody) -- 466
				) -- 466
			end -- 466
			fgDraw:drawRect( -- 468
				Rect(left, bottom, right - left, height), -- 468
				toColor(PALETTE.steelDark) -- 468
			) -- 468
			local step = cam:len(96) -- 469
			local start = math.max( -- 470
				0, -- 470
				math.floor(-left / step) -- 470
			) -- 470
			do -- 470
				local j = start -- 471
				while left + j * step < math.min(right, cam.viewW) do -- 471
					local x = left + j * step -- 472
					local width = math.min(step, right - x) -- 473
					assets:tryPlace( -- 474
						"slab", -- 474
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 474
						x + width * 0.5, -- 474
						bottom, -- 474
						width, -- 474
						height -- 474
					) -- 474
					if grass and isMain and j % 3 == 1 then -- 475
						assets:tryPlace( -- 476
							"grass_low", -- 476
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 476
							x + width * 0.5, -- 476
							top - cam:len(3), -- 477
							width * 0.74, -- 477
							cam:len(13), -- 477
							{opacity = 0.83, layer = 1} -- 477
						) -- 477
					end -- 477
					j = j + 1 -- 471
				end -- 471
			end -- 471
			fgDraw:drawSegment( -- 480
				Vec2(left, top), -- 480
				Vec2(right, top), -- 480
				1, -- 480
				toColor(theme.groundRim, 140) -- 480
			) -- 480
			i = i + 1 -- 452
		end -- 452
	end -- 452
end -- 444
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 484
	local width = right - left -- 489
	local height = back - front -- 490
	if width <= 1 or height <= 1 then -- 491
		return -- 492
	end -- 492
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 495
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 496
	fillVGradRect( -- 497
		draw, -- 497
		left, -- 497
		front, -- 497
		width, -- 497
		height, -- 497
		toColor(nearCol), -- 497
		toColor(farCol) -- 497
	) -- 497
	local bands = { -- 499
		0, -- 499
		0.3, -- 499
		0.58, -- 499
		0.81, -- 499
		1 -- 499
	} -- 499
	local jointDark = Color(14, 17, 22, 115) -- 500
	local jointHi = toColor(theme.groundRim, 36) -- 501
	local visLeft = math.max(left, -40) -- 502
	local visRight = math.min(right, cam.viewW + 40) -- 503
	do -- 503
		local row = 0 -- 504
		while row < #bands - 1 do -- 504
			local y0 = front + bands[row + 1] * height -- 505
			local y1 = front + bands[row + 1 + 1] * height -- 506
			local rowH = y1 - y0 -- 507
			local slabWidth = math.max( -- 508
				24, -- 508
				cam:len(84 - row * 10) -- 508
			) -- 508
			local offset = left - row % 2 * slabWidth * 0.5 -- 509
			local start = math.max( -- 510
				0, -- 510
				math.floor((visLeft - offset) / slabWidth) -- 510
			) -- 510
			do -- 510
				local col = start -- 511
				while offset + col * slabWidth < visRight do -- 511
					do -- 511
						local sx0 = math.max(left, offset + col * slabWidth) -- 512
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 513
						local sw = sx1 - sx0 -- 514
						if sw <= 2 then -- 515
							goto __continue61 -- 516
						end -- 516
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 518
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 519
						draw:drawRect( -- 520
							Rect( -- 520
								sx0 + 0.5, -- 520
								y0 + 0.5, -- 520
								sw - 1, -- 520
								math.max(1, rowH - 1) -- 520
							), -- 520
							toColor(stoneCol, 195) -- 520
						) -- 520
						draw:drawSegment( -- 521
							Vec2(sx0, y0), -- 521
							Vec2(sx0, y1), -- 521
							0.8, -- 521
							jointDark -- 521
						) -- 521
					end -- 521
					::__continue61:: -- 521
					col = col + 1 -- 511
				end -- 511
			end -- 511
			draw:drawSegment( -- 523
				Vec2(left, y0), -- 523
				Vec2(right, y0), -- 523
				0.9, -- 523
				jointDark -- 523
			) -- 523
			draw:drawSegment( -- 524
				Vec2(left, y0 + 1), -- 524
				Vec2(right, y0 + 1), -- 524
				0.6, -- 524
				jointHi -- 524
			) -- 524
			row = row + 1 -- 504
		end -- 504
	end -- 504
	draw:drawSegment( -- 527
		Vec2(left, front), -- 527
		Vec2(right, front), -- 527
		1.4, -- 527
		toColor(theme.groundRim, 135) -- 527
	) -- 527
	draw:drawSegment( -- 528
		Vec2(left, back), -- 528
		Vec2(right, back), -- 528
		1.3, -- 528
		toColor(theme.groundRim, 92) -- 528
	) -- 528
	local texTileW = math.max( -- 531
		88, -- 531
		cam:len(128) -- 531
	) -- 531
	local texStart = math.max( -- 532
		0, -- 532
		math.floor((visLeft - left) / texTileW) -- 532
	) -- 532
	local stoneTint = toColor( -- 533
		lerpRGBA(theme.groundTop, PALETTE.rimSilver, 0.25), -- 533
		255 -- 533
	) -- 533
	do -- 533
		local tcol = texStart -- 534
		while left + tcol * texTileW < visRight do -- 534
			do -- 534
				local tx0 = left + tcol * texTileW -- 535
				local tw = math.min(texTileW, right - tx0) -- 536
				if tw <= 4 then -- 537
					goto __continue64 -- 538
				end -- 538
				_assets:tryPlacePath( -- 540
					"assets/art/tex_diorama_ming.clip|ming_stone", -- 541
					(("road_stone_" .. tostring(_floor)) .. "_") .. tostring(tcol), -- 542
					tx0 + tw * 0.5, -- 543
					front, -- 544
					tw + 0.5, -- 545
					height, -- 546
					{ -- 547
						anchorX = 0.5, -- 548
						anchorY = 0, -- 549
						opacity = 0.14, -- 550
						color = stoneTint, -- 551
						smooth = true, -- 552
						layer = -18 -- 553
					} -- 553
				) -- 553
			end -- 553
			::__continue64:: -- 553
			tcol = tcol + 1 -- 534
		end -- 534
	end -- 534
end -- 484
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 559
	local i = 0 -- 567
	do -- 567
		i = 0 -- 568
		while i < #p.room.stairs do -- 568
			local st = p.room.stairs[i + 1] -- 569
			local n = st.steps + 1 -- 570
			local stepW = (st.x1 - st.x0) / n -- 571
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 572
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 575
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 578
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 579
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 580
			local k = 0 -- 581
			do -- 581
				k = 0 -- 582
				while k < n do -- 582
					do -- 582
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 583
						local wx0 = st.x0 + stepW * k -- 584
						local wx1 = wx0 + stepW -- 585
						local x0 = cam:sx(wx0) -- 586
						local x1 = cam:sx(wx1) -- 587
						if x1 < 0 or x0 > cam.viewW then -- 588
							goto __continue70 -- 589
						end -- 589
						local y1 = cam:sy(wy, dMin) -- 591
						local y0 = cam:sy(baseWorldY, dMin) -- 592
						local yRear = cam:sy(wy, dMax) -- 593
						if yRear > y1 + 1 then -- 594
							fgDraw:drawRect( -- 595
								Rect(x0, y1, x1 - x0, yRear - y1), -- 595
								toColor( -- 595
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 595
									235 -- 595
								), -- 595
								0.7, -- 595
								toColor(theme.groundRim, 95) -- 595
							) -- 595
						end -- 595
						if y1 > y0 + 2 then -- 597
							fgDraw:drawRect( -- 598
								Rect(x0, y0, x1 - x0, y1 - y0), -- 598
								toColor(PALETTE.steelDark, 235) -- 598
							) -- 598
							fgDraw:drawRect( -- 599
								Rect(x0, y1 - 4, x1 - x0, 4), -- 599
								toColor(theme.groundTop) -- 599
							) -- 599
							assets:tryPlace( -- 600
								"wall", -- 600
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 600
								(x0 + x1) * 0.5, -- 600
								y0, -- 600
								x1 - x0, -- 601
								y1 - y0, -- 601
								{opacity = 0.76, layer = stairLayer} -- 601
							) -- 601
							assets:tryPlace( -- 602
								"slab", -- 602
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 602
								(x0 + x1) * 0.5, -- 602
								y1 - cam:len(4), -- 602
								x1 - x0, -- 603
								cam:len(4), -- 603
								{layer = stairLayer + 1} -- 603
							) -- 603
						end -- 603
						fgDraw:drawSegment( -- 605
							Vec2(x0, y1), -- 605
							Vec2(x1, y1), -- 605
							1.6, -- 605
							toColor(theme.groundRim) -- 605
						) -- 605
						fgGlow:drawSegment( -- 606
							Vec2(x0, y1 + 1), -- 606
							Vec2(x1, y1 + 1), -- 606
							0.9, -- 606
							toColor(theme.accent, 50) -- 606
						) -- 606
					end -- 606
					::__continue70:: -- 606
					k = k + 1 -- 582
				end -- 582
			end -- 582
			i = i + 1 -- 568
		end -- 568
	end -- 568
end -- 559
function StageRenderer.prototype.isSolidActive(self, p, s) -- 612
	local matched = false -- 613
	local anyVisible = false -- 614
	local i = 0 -- 615
	do -- 615
		i = 0 -- 616
		while i < #p.boxes do -- 616
			local b = p.boxes[i + 1] -- 617
			local sameId = s.id ~= nil and b.id == s.id -- 618
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 619
			if sameId or sameGeom then -- 622
				matched = true -- 623
				if b.broken ~= true and b.hidden ~= true then -- 624
					anyVisible = true -- 625
				end -- 625
			end -- 625
			i = i + 1 -- 616
		end -- 616
	end -- 616
	return not matched or anyVisible -- 629
end -- 612
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 632
	local i = 0 -- 643
	do -- 643
		i = 0 -- 644
		while i < #p.room.solids do -- 644
			do -- 644
				local s = p.room.solids[i + 1] -- 645
				if s.decorative == true then -- 647
					goto __continue81 -- 648
				end -- 648
				if not self:isSolidActive(p, s) then -- 651
					goto __continue81 -- 652
				end -- 652
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 655
					goto __continue81 -- 656
				end -- 656
				local x0 = cam:sx(s.x) -- 658
				local x1 = cam:sx(s.x + s.w) -- 659
				if p.room.depth ~= nil and s.depth ~= nil then -- 660
					local opacity = occlusion:update( -- 661
						"solid_" .. tostring(i), -- 661
						{ -- 661
							x0 = s.x, -- 662
							x1 = s.x + s.w, -- 662
							y0 = s.y, -- 662
							y1 = s.y + s.h, -- 662
							depth = s.depth, -- 663
							passThrough = s.passable == true or s.soft == true -- 663
						}, -- 663
						p, -- 664
						fadeDt -- 664
					) -- 664
					if x1 > 0 and x0 < cam.viewW then -- 665
						self:drawDepthSolid( -- 666
							fgDraw, -- 666
							assets, -- 666
							s, -- 666
							s.depth, -- 666
							x0, -- 666
							x1, -- 666
							cam, -- 666
							theme, -- 666
							opacity, -- 666
							p -- 666
						) -- 666
					end -- 666
					goto __continue81 -- 668
				end -- 668
				local y0 = cam:sy(s.y) -- 670
				local y1 = cam:sy(s.y + s.h) -- 671
				local sw = x1 - x0 -- 672
				local sh = y1 - y0 -- 673
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 674
					goto __continue81 -- 675
				end -- 675
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 679
					local groundY = cam:sy(0) -- 680
					local pierW = cam:len(16) -- 681
					fgDraw:drawRect( -- 682
						Rect(x0, groundY, pierW, y0 - groundY), -- 682
						Color(32, 37, 46, 215), -- 682
						0.9, -- 682
						Color(68, 76, 88, 140) -- 682
					) -- 682
					fgDraw:drawRect( -- 683
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 683
						Color(32, 37, 46, 215), -- 683
						0.9, -- 683
						Color(68, 76, 88, 140) -- 683
					) -- 683
				end -- 683
				if s.passable == true then -- 687
					if not assets:tryPlace( -- 688
						"grass", -- 688
						"hide_grass_" .. tostring(i), -- 688
						(x0 + x1) * 0.5, -- 688
						y0, -- 688
						sw, -- 688
						sh * 1.55, -- 688
						{opacity = 0.79, layer = 7} -- 689
					) then -- 689
						self:drawGrassCluster( -- 690
							fgDraw, -- 690
							fgGlow, -- 690
							x0, -- 690
							y0, -- 690
							sw, -- 690
							sh, -- 690
							p.player.x, -- 690
							s.x + s.w * 0.5, -- 690
							time -- 690
						) -- 690
					end -- 690
					goto __continue81 -- 692
				end -- 692
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 696
					self:drawWinch( -- 697
						fgDraw, -- 697
						assets, -- 697
						x0, -- 697
						y0, -- 697
						sw, -- 697
						sh, -- 697
						p, -- 697
						2 -- 697
					) -- 697
					goto __continue81 -- 698
				end -- 698
				if p.room.key == "tower" then -- 702
					self:drawTowerStructure( -- 703
						fgDraw, -- 703
						fgGlow, -- 703
						assets, -- 703
						x0, -- 703
						y0, -- 703
						sw, -- 703
						sh, -- 703
						s, -- 703
						p, -- 703
						cam, -- 703
						time -- 703
					) -- 703
					goto __continue81 -- 704
				end -- 704
				if s.art == "red_cart" then -- 708
					self:drawRedCartPixel( -- 709
						fgDraw, -- 709
						x0, -- 709
						y0, -- 709
						sw, -- 709
						sh, -- 709
						cam -- 709
					) -- 709
					goto __continue81 -- 710
				end -- 710
				if s.h <= 64 and s.y <= 2 then -- 714
					self:drawCoverBlock( -- 715
						fgDraw, -- 715
						fgGlow, -- 715
						assets, -- 715
						x0, -- 715
						y0, -- 715
						sw, -- 715
						sh, -- 715
						s, -- 715
						p, -- 715
						theme -- 715
					) -- 715
					goto __continue81 -- 716
				end -- 716
				fillVGradRect( -- 719
					fgDraw, -- 719
					x0, -- 719
					y0, -- 719
					sw, -- 719
					sh, -- 719
					toColor(PALETTE.steelDark), -- 719
					toColor(PALETTE.steelMid) -- 719
				) -- 719
				self:tileMasonry( -- 720
					assets, -- 720
					s, -- 720
					x0, -- 720
					y0, -- 720
					sw, -- 720
					sh -- 720
				) -- 720
			end -- 720
			::__continue81:: -- 720
			i = i + 1 -- 644
		end -- 644
	end -- 644
end -- 632
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 724
	local width = right - left -- 728
	local base = cam:sy(solid.y, depth.min) -- 729
	local rearBase = cam:sy(solid.y, depth.max) -- 730
	local top = cam:sy(solid.y + solid.h, depth.min) -- 731
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 732
	local frontH = top - base -- 733
	local slot = coverArt(solid) -- 734
	local layer = depthOrder(depth.min, 1) -- 735
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 736
	local capHeight = rear - top -- 737
	local center = (left + right) * 0.5 -- 738
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 741
		self:drawWinch( -- 742
			draw, -- 742
			assets, -- 742
			left, -- 742
			base, -- 742
			width, -- 742
			frontH, -- 742
			p, -- 742
			layer -- 742
		) -- 742
		return -- 743
	end -- 743
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 746
		assets:tryPlace( -- 747
			"slab", -- 747
			"gate_sill_" .. tostring(solid.x), -- 747
			center, -- 747
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 747
			width + cam:len(34), -- 748
			cam:len(12), -- 748
			{ -- 748
				layer = 1, -- 748
				color = Color(180, 169, 150, 255) -- 748
			} -- 748
		) -- 748
	end -- 748
	draw:drawEllipse( -- 750
		Vec2( -- 750
			center, -- 750
			base + cam:len(2) -- 750
		), -- 750
		width * 0.5, -- 750
		math.max( -- 751
			2, -- 751
			cam:len(2.5) -- 751
		), -- 751
		Color(10, 10, 14, 128 * opacity) -- 751
	) -- 751
	local propArt = dedicatedSolidProp(solid) -- 754
	if propArt ~= nil then -- 755
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 756
		local drawH = frontH * propArt.heightMul -- 757
		local cols = propArt.tileable and math.max( -- 758
			1, -- 759
			math.min( -- 759
				6, -- 759
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 759
			) -- 759
		) or 1 -- 760
		local colW = width / cols -- 761
		local tint = occlusionTint(opacity) -- 762
		local placedProp = false -- 763
		do -- 763
			local col = 0 -- 764
			while col < cols do -- 764
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 765
				if assets:tryPlacePath( -- 766
					propPath, -- 766
					tileKey, -- 766
					left + (col + 0.5) * colW, -- 766
					base, -- 766
					colW + 1, -- 766
					drawH, -- 766
					{ -- 766
						anchorX = 0.5, -- 767
						anchorY = 0, -- 768
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 769
						opacity = opacity, -- 770
						color = tint, -- 771
						layer = layer -- 772
					} -- 772
				) then -- 772
					placedProp = true -- 774
				end -- 774
				col = col + 1 -- 764
			end -- 764
		end -- 764
		if placedProp then -- 777
			return -- 778
		end -- 778
	end -- 778
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 782
	if slot ~= "fence" and capHeight > 1 then -- 785
		local capTop = top + capHeight -- 786
		if not assets:tryPlace( -- 787
			slot, -- 787
			"cap_" .. tostring(solid.x), -- 787
			center, -- 787
			top, -- 787
			width, -- 787
			capHeight, -- 787
			{ -- 788
				opacity = math.min(1, opacity), -- 788
				layer = layer -- 788
			} -- 788
		) then -- 788
			local capFill = occlusionTint( -- 789
				opacity, -- 789
				timber and Color( -- 789
					74, -- 790
					56, -- 790
					42, -- 790
					math.floor(232 * opacity + 0.5) -- 790
				) or Color( -- 791
					74, -- 791
					78, -- 791
					86, -- 791
					math.floor(232 * opacity + 0.5) -- 791
				) -- 791
			) -- 791
			fillVGradRect( -- 792
				draw, -- 792
				left, -- 792
				top, -- 792
				width, -- 792
				capHeight, -- 792
				capFill, -- 793
				occlusionTint( -- 793
					opacity, -- 793
					Color( -- 793
						44, -- 793
						46, -- 793
						52, -- 793
						math.floor(220 * opacity + 0.5) -- 793
					) -- 793
				) -- 793
			) -- 793
		end -- 793
		draw:drawSegment( -- 795
			Vec2(left + width * 0.04, capTop - 0.5), -- 795
			Vec2(right - width * 0.04, capTop - 0.5), -- 795
			0.9, -- 796
			occlusionTint( -- 796
				opacity, -- 796
				timber and Color( -- 796
					122, -- 797
					96, -- 797
					72, -- 797
					math.floor(150 * opacity + 0.5) -- 797
				) or Color( -- 798
					118, -- 798
					124, -- 798
					132, -- 798
					math.floor(140 * opacity + 0.5) -- 798
				) -- 798
			) -- 798
		) -- 798
	end -- 798
	if timber and solid.h > solid.w * 1.6 then -- 802
		local colFill = occlusionTint( -- 803
			opacity, -- 803
			Color( -- 803
				66, -- 803
				48, -- 803
				36, -- 803
				math.floor(248 * opacity + 0.5) -- 803
			) -- 803
		) -- 803
		local colHi = occlusionTint( -- 804
			opacity, -- 804
			Color( -- 804
				122, -- 804
				92, -- 804
				68, -- 804
				math.floor(200 * opacity + 0.5) -- 804
			) -- 804
		) -- 804
		local colSh = occlusionTint( -- 805
			opacity, -- 805
			Color( -- 805
				34, -- 805
				24, -- 805
				18, -- 805
				math.floor(220 * opacity + 0.5) -- 805
			) -- 805
		) -- 805
		draw:drawRect( -- 806
			Rect(left, base, width, frontH), -- 806
			colFill, -- 806
			1, -- 806
			colHi -- 806
		) -- 806
		draw:drawRect( -- 807
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 807
			colSh -- 807
		) -- 807
		draw:drawSegment( -- 808
			Vec2(left + width * 0.32, base + 2), -- 808
			Vec2(left + width * 0.32, top - 2), -- 808
			0.9, -- 808
			colHi -- 808
		) -- 808
		return -- 809
	end -- 809
	if solid.w > solid.h * 5 then -- 813
		local beamFill = occlusionTint( -- 814
			opacity, -- 814
			Color( -- 814
				78, -- 814
				58, -- 814
				42, -- 814
				math.floor(248 * opacity + 0.5) -- 814
			) -- 814
		) -- 814
		local beamEdge = occlusionTint( -- 815
			opacity, -- 815
			Color( -- 815
				142, -- 815
				110, -- 815
				82, -- 815
				math.floor(215 * opacity + 0.5) -- 815
			) -- 815
		) -- 815
		draw:drawRect( -- 816
			Rect( -- 816
				left, -- 816
				base, -- 816
				width, -- 816
				math.max(4, frontH) -- 816
			), -- 816
			beamFill, -- 816
			1, -- 816
			beamEdge -- 816
		) -- 816
		local posts = math.max( -- 817
			2, -- 817
			math.floor(solid.w / 140 + 0.5) -- 817
		) -- 817
		do -- 817
			local pi = 0 -- 818
			while pi <= posts do -- 818
				local px = left + width * pi / posts -- 819
				draw:drawSegment( -- 820
					Vec2(px, base), -- 820
					Vec2(px, top), -- 820
					1.4, -- 820
					Color( -- 820
						34, -- 820
						24, -- 820
						18, -- 820
						math.floor(210 * opacity + 0.5) -- 820
					) -- 820
				) -- 820
				pi = pi + 1 -- 818
			end -- 818
		end -- 818
		return -- 822
	end -- 822
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 826
	local cols = slot == "wall" and math.max( -- 827
		1, -- 828
		math.min( -- 828
			10, -- 828
			math.floor(solid.w / 72 + 0.5) -- 828
		) -- 828
	) or math.max( -- 829
		1, -- 829
		math.min( -- 829
			10, -- 829
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 829
		) -- 829
	) -- 829
	local colW = width / cols -- 830
	local rows = slot == "wall" and math.max( -- 831
		1, -- 832
		math.min( -- 832
			10, -- 832
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 832
		) -- 832
	) or math.max( -- 833
		1, -- 833
		math.min( -- 833
			6, -- 833
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 833
		) -- 833
	) -- 833
	local rowHeight = frontH / rows -- 834
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 835
	local color = occlusionTint(opacity, masonryColor) -- 836
	local placedAny = false -- 837
	do -- 837
		local row = 0 -- 838
		while row < rows do -- 838
			do -- 838
				local col = 0 -- 839
				while col < cols do -- 839
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 840
					if assets:tryPlace( -- 841
						slot, -- 841
						tileKey, -- 841
						left + (col + 0.5) * colW, -- 841
						base + row * rowHeight, -- 841
						colW + 0.5, -- 841
						rowHeight + 0.5, -- 841
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 841
					) then -- 841
						placedAny = true -- 844
					end -- 844
					col = col + 1 -- 839
				end -- 839
			end -- 839
			row = row + 1 -- 838
		end -- 838
	end -- 838
	if not placedAny then -- 848
		draw:drawRect( -- 849
			Rect(left, base, width, frontH), -- 849
			occlusionTint( -- 850
				opacity, -- 850
				toColor(PALETTE.steelMid, 255 * opacity) -- 850
			), -- 850
			1, -- 851
			toColor(theme.groundRim, 150 * opacity) -- 851
		) -- 851
	end -- 851
end -- 724
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 855
	local columns = math.max( -- 860
		1, -- 860
		math.min( -- 860
			10, -- 860
			math.floor(s.w / 58 + 0.5) -- 860
		) -- 860
	) -- 860
	local cellWorldW = s.w / columns -- 861
	local targetCellH = math.max( -- 862
		24, -- 862
		math.min(48, cellWorldW / 1.52) -- 862
	) -- 862
	local rows = math.max( -- 863
		1, -- 863
		math.min( -- 863
			12, -- 863
			math.floor(s.h / targetCellH + 0.5) -- 863
		) -- 863
	) -- 863
	local tileW = width / columns -- 864
	local tileH = height / rows -- 865
	do -- 865
		local row = 0 -- 866
		while row < rows do -- 866
			do -- 866
				local column = 0 -- 867
				while column < columns do -- 867
					assets:tryPlace( -- 868
						"wall", -- 868
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 868
						x + (column + 0.5) * tileW, -- 869
						y + row * tileH, -- 869
						tileW + 0.5, -- 869
						tileH + 0.5, -- 869
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 870
					) -- 870
					column = column + 1 -- 867
				end -- 867
			end -- 867
			row = row + 1 -- 866
		end -- 866
	end -- 866
end -- 855
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 875
	local slot = coverArt(s) -- 882
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 883
	local cols = math.max( -- 884
		1, -- 884
		math.min( -- 884
			8, -- 884
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 884
		) -- 884
	) -- 884
	local tileW = sw / cols -- 885
	local placed = false -- 886
	do -- 886
		local c = 0 -- 887
		while c < cols do -- 887
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 888
			if assets:tryPlace( -- 889
				slot, -- 889
				k, -- 889
				x0 + (c + 0.5) * tileW, -- 889
				y0, -- 889
				tileW + 0.5, -- 889
				sh, -- 889
				{layer = 1} -- 889
			) then -- 889
				placed = true -- 890
			end -- 890
			c = c + 1 -- 887
		end -- 887
	end -- 887
	if not placed then -- 893
		fillVGradRect( -- 894
			fgDraw, -- 894
			x0, -- 894
			y0, -- 894
			sw, -- 894
			sh, -- 894
			toColor(PALETTE.steelDark), -- 894
			toColor(PALETTE.steelMid) -- 894
		) -- 894
		fgDraw:drawSegment( -- 895
			Vec2(x0, y0 + sh), -- 895
			Vec2(x0 + sw, y0 + sh), -- 895
			1.4, -- 895
			toColor(theme.groundRim) -- 895
		) -- 895
	end -- 895
	if not p.childMode and (p.coverHug or p.coverNear) then -- 899
		local plx = p.player.x -- 900
		local nearLeft = math.abs(plx - s.x) < 42 -- 901
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 902
		if nearLeft or nearRight then -- 903
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 904
			local isWood = slot == "cover_wood" -- 905
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 906
			fgDraw:drawSegment( -- 907
				Vec2(edgeX, y0 + 4), -- 907
				Vec2(edgeX, y0 + sh + 2), -- 907
				p.coverHug and 2 or 1.2, -- 907
				toColor(col, p.coverHug and 205 or 120) -- 907
			) -- 907
		end -- 907
	end -- 907
end -- 875
function StageRenderer.prototype.drawRedCartPixel(self, draw, x0, y0, sw, sh, cam) -- 916
	local bodyH = math.max(6, sh * 0.62) -- 919
	local bodyY = y0 + sh - bodyH -- 920
	draw:drawRect( -- 921
		Rect(x0, bodyY, sw, bodyH), -- 921
		Color(92, 70, 52, 248), -- 921
		1, -- 921
		Color(150, 118, 86, 215) -- 921
	) -- 921
	draw:drawRect( -- 922
		Rect( -- 922
			x0 - cam:len(3), -- 922
			bodyY + cam:len(1), -- 922
			sw + cam:len(8), -- 922
			bodyH * 0.92 -- 922
		), -- 922
		toColor(PALETTE.clothRed), -- 923
		1, -- 923
		toColor(PALETTE.clothRedHighlight) -- 923
	) -- 923
	draw:drawRect( -- 924
		Rect(x0 + sw * 0.16, bodyY + bodyH * 0.36, sw * 0.24, bodyH * 0.32), -- 924
		Color(214, 206, 188, 215) -- 925
	) -- 925
	draw:drawRect( -- 926
		Rect(x0 + sw * 0.58, bodyY + bodyH * 0.52, sw * 0.18, bodyH * 0.22), -- 926
		Color(196, 188, 172, 200) -- 927
	) -- 927
	draw:drawSegment( -- 928
		Vec2( -- 928
			x0 + sw - cam:len(2), -- 928
			bodyY + bodyH * 0.72 -- 928
		), -- 928
		Vec2( -- 929
			x0 + sw + cam:len(26), -- 929
			bodyY + bodyH * 1.36 -- 929
		), -- 929
		math.max( -- 930
			2, -- 930
			cam:len(2.6) -- 930
		), -- 930
		Color(126, 98, 68, 240) -- 930
	) -- 930
	draw:drawEllipse( -- 931
		Vec2( -- 931
			x0 + sw * 0.26, -- 931
			y0 + sh - cam:len(1) -- 931
		), -- 931
		cam:len(5.2), -- 931
		cam:len(5.2), -- 931
		Color(40, 34, 30, 235) -- 932
	) -- 932
	draw:drawEllipse( -- 933
		Vec2( -- 933
			x0 + sw * 0.26, -- 933
			y0 + sh - cam:len(1) -- 933
		), -- 933
		cam:len(2.1), -- 933
		cam:len(2.1), -- 933
		Color(150, 126, 92, 220) -- 934
	) -- 934
end -- 916
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 937
	if layer == nil then -- 942
		layer = 2 -- 942
	end -- 942
	local cx = x0 + sw * 0.5 -- 944
	local cy = y0 + sh * 0.55 -- 945
	local ropeWidth = math.max(1, sw * 0.023) -- 946
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 947
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 948
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 949
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 950
	draw:drawEllipse( -- 951
		Vec2(cx, y0), -- 951
		sw * 0.53, -- 951
		sh * 0.07, -- 951
		Color(10, 8, 9, 150) -- 951
	) -- 951
	draw:drawSegment( -- 952
		drum, -- 952
		bend, -- 952
		ropeWidth, -- 952
		Color(111, 86, 57, 239) -- 952
	) -- 952
	draw:drawSegment( -- 953
		bend, -- 953
		ropeTop, -- 953
		ropeWidth, -- 953
		Color(111, 86, 57, 239) -- 953
	) -- 953
	if assets:tryPlace( -- 954
		"prop_winch", -- 954
		"gate_winch", -- 954
		cx, -- 954
		y0 + sh * 0.5, -- 954
		sw, -- 954
		sh, -- 954
		{layer = layer} -- 954
	) then -- 954
		return -- 955
	end -- 955
	local timber = Color(75, 51, 34, 255) -- 957
	draw:drawSegment( -- 958
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 958
		Vec2(cx, y0 + sh * 0.86), -- 958
		sw * 0.06, -- 958
		timber -- 958
	) -- 958
	draw:drawSegment( -- 959
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 959
		Vec2(cx, y0 + sh * 0.86), -- 959
		sw * 0.06, -- 959
		timber -- 959
	) -- 959
	draw:drawRect( -- 960
		Rect(x0, y0, sw, sh * 0.12), -- 960
		timber -- 960
	) -- 960
	local radius = math.min(sw, sh) * 0.21 -- 961
	draw:drawCircle( -- 962
		Vec2(cx, cy), -- 962
		radius, -- 962
		Color(48, 41, 37, 255) -- 962
	) -- 962
	do -- 962
		local i = -2 -- 963
		while i <= 2 do -- 963
			local x = cx + i * radius * 0.28 -- 964
			draw:drawSegment( -- 965
				Vec2(x, cy - radius * 0.62), -- 965
				Vec2(x, cy + radius * 0.62), -- 965
				ropeWidth, -- 965
				Color(135, 103, 68, 240) -- 966
			) -- 966
			i = i + 1 -- 963
		end -- 963
	end -- 963
end -- 937
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 970
	local ____temp_3 -- 978
	if p.room.story ~= nil then -- 978
		____temp_3 = p.room.story.gate -- 978
	else -- 978
		____temp_3 = nil -- 978
	end -- 978
	local g = ____temp_3 -- 978
	if g == nil then -- 979
		return -- 980
	end -- 980
	local closeFrac = 0.08 -- 983
	if p.phase == "gate-hold" then -- 984
		closeFrac = 0.08 + 0.36 * math.min( -- 985
			1, -- 985
			p.gateTick / math.max(1, g.holdTicks) -- 985
		) -- 985
	elseif p.phase == "gate-send" then -- 986
		closeFrac = 0.44 -- 987
	elseif p.phase == "gate-count" then -- 988
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 989
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 990
		closeFrac = 1 -- 991
	end -- 991
	local gx0 = cam:sx(848) -- 993
	local gx1 = cam:sx(1032) -- 994
	local topY = cam:sy(160) -- 995
	local botY = cam:sy(160 * (1 - closeFrac)) -- 996
	local shutterW = gx1 - gx0 -- 997
	local shutterH = topY - botY -- 998
	if shutterH > 2 then -- 999
		fillVGradRect( -- 1000
			fgDraw, -- 1000
			gx0, -- 1000
			botY, -- 1000
			shutterW, -- 1000
			shutterH, -- 1000
			toColor(PALETTE.steelDark), -- 1000
			toColor(PALETTE.steelMid) -- 1000
		) -- 1000
		local rows = math.max( -- 1002
			1, -- 1002
			math.min( -- 1002
				6, -- 1002
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1002
			) -- 1002
		) -- 1002
		local rowH = shutterH / rows -- 1003
		do -- 1003
			local r = 0 -- 1004
			while r < rows do -- 1004
				assets:tryPlace( -- 1005
					"cover_wood", -- 1005
					"gate_shutter_" .. tostring(r), -- 1005
					(gx0 + gx1) * 0.5, -- 1005
					botY + r * rowH, -- 1005
					shutterW, -- 1006
					rowH + 0.5, -- 1006
					{layer = 6} -- 1006
				) -- 1006
				r = r + 1 -- 1004
			end -- 1004
		end -- 1004
	end -- 1004
	if closeFrac < 0.98 then -- 1010
		local gapH = math.max( -- 1011
			8, -- 1011
			botY - cam:sy(0) -- 1011
		) -- 1011
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1012
		fillVGradRect( -- 1013
			fgGlow, -- 1013
			gx0, -- 1013
			cam:sy(0), -- 1013
			gx1 - gx0, -- 1013
			gapH, -- 1013
			Color( -- 1013
				140, -- 1013
				210, -- 1013
				255, -- 1013
				math.floor(52 * pulse + 0.5) -- 1013
			), -- 1013
			Color(80, 160, 230, 0) -- 1013
		) -- 1013
	end -- 1013
end -- 970
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1017
	fillVGradRect( -- 1024
		fgDraw, -- 1024
		x0, -- 1024
		y0, -- 1024
		sw, -- 1024
		sh, -- 1024
		Color(15, 21, 34, 255), -- 1024
		Color(32, 44, 66, 255) -- 1024
	) -- 1024
	fgDraw:drawRect( -- 1025
		Rect(x0, y0, sw, sh), -- 1025
		Color(0, 0, 0, 0), -- 1025
		1.4, -- 1025
		toColor(PALETTE.rimSilver, 165) -- 1025
	) -- 1025
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1027
		self:tileMasonry( -- 1028
			assets, -- 1028
			s, -- 1028
			x0, -- 1028
			y0, -- 1028
			sw, -- 1028
			sh -- 1028
		) -- 1028
		local ribs = 4 -- 1030
		local r = 1 -- 1031
		do -- 1031
			r = 1 -- 1032
			while r < ribs do -- 1032
				local rx = x0 + sw * r / ribs -- 1033
				fgDraw:drawSegment( -- 1034
					Vec2(rx, y0), -- 1034
					Vec2(rx, y0 + sh), -- 1034
					2, -- 1034
					Color(10, 15, 24, 210) -- 1034
				) -- 1034
				fgDraw:drawSegment( -- 1035
					Vec2(rx + 2, y0), -- 1035
					Vec2(rx + 2, y0 + sh), -- 1035
					1, -- 1035
					Color(68, 86, 114, 130) -- 1035
				) -- 1035
				r = r + 1 -- 1032
			end -- 1032
		end -- 1032
		local bands = 4 -- 1038
		local b = 1 -- 1039
		do -- 1039
			b = 1 -- 1040
			while b < bands do -- 1040
				local by = y0 + sh * b / bands -- 1041
				fgDraw:drawSegment( -- 1042
					Vec2(x0 + 4, by), -- 1042
					Vec2(x0 + sw - 4, by), -- 1042
					1.2, -- 1042
					Color(52, 68, 92, 135) -- 1042
				) -- 1042
				b = b + 1 -- 1040
			end -- 1040
		end -- 1040
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1045
		local slitY = y0 + sh * 0.56 -- 1046
		local slitH = sh * 0.22 -- 1047
		fgDraw:drawRect( -- 1048
			Rect(slitX - 5, slitY, 10, slitH), -- 1048
			Color(8, 12, 20, 245), -- 1048
			1.2, -- 1048
			toColor(PALETTE.amberDim, 190) -- 1048
		) -- 1048
		fgGlow:drawRect( -- 1049
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1049
			toColor(PALETTE.amber, 190) -- 1049
		) -- 1049
		fillRadialGlow( -- 1050
			fgGlow, -- 1050
			slitX, -- 1050
			slitY + slitH * 0.5, -- 1050
			44, -- 1050
			slitH * 0.7, -- 1050
			Color(255, 206, 128, 52), -- 1050
			Color(255, 180, 86, 0), -- 1050
			14 -- 1050
		) -- 1050
	end -- 1050
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1054
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1055
		local cx = x0 + sw * 0.5 -- 1060
		local lampY = y0 - 8 -- 1061
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1062
		if not opened then -- 1063
			assets:tryPlace( -- 1064
				"prop_tower_door", -- 1064
				"tower_door", -- 1064
				cx, -- 1064
				y0 - doorHeight, -- 1064
				sw, -- 1064
				doorHeight, -- 1064
				{layer = 2} -- 1064
			) -- 1064
		end -- 1064
		assets:tryPlace( -- 1066
			"prop_lantern", -- 1066
			"tower_lantern", -- 1066
			cx + sw * 0.43, -- 1066
			lampY - sh * 0.36, -- 1066
			sw * 0.17, -- 1067
			sh * 0.84, -- 1067
			{layer = 3} -- 1067
		) -- 1067
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1068
		local alpha = opened and 58 or 42 -- 1069
		fgDraw:drawSegment( -- 1071
			Vec2(x0 + 4, y0), -- 1071
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1071
			4, -- 1071
			Color(42, 52, 70, 255) -- 1071
		) -- 1071
		fgDraw:drawSegment( -- 1072
			Vec2(x0 + sw - 4, y0), -- 1072
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1072
			4, -- 1072
			Color(42, 52, 70, 255) -- 1072
		) -- 1072
		fgDraw:drawSegment( -- 1073
			Vec2(x0, y0), -- 1073
			Vec2(x0 + sw, y0), -- 1073
			2.5, -- 1073
			toColor(PALETTE.amber, 210) -- 1073
		) -- 1073
		fillVGradRect( -- 1075
			fgGlow, -- 1076
			x0 + 6, -- 1077
			y0 - sh * 3.8, -- 1078
			sw - 12, -- 1079
			sh * 3.8, -- 1080
			Color( -- 1081
				246, -- 1081
				196, -- 1081
				118, -- 1081
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1081
			), -- 1081
			Color(246, 206, 142, opened and 74 or 38) -- 1082
		) -- 1082
		fillRadialGlow( -- 1084
			fgGlow, -- 1084
			cx, -- 1084
			lampY, -- 1084
			opened and 78 or 54, -- 1084
			opened and 72 or 52, -- 1084
			Color( -- 1084
				252, -- 1084
				218, -- 1084
				152, -- 1084
				math.floor(92 * pulse + 0.5) -- 1084
			), -- 1084
			Color(255, 180, 86, 0), -- 1084
			18 -- 1084
		) -- 1084
		fgDraw:drawCircle( -- 1085
			Vec2(cx, lampY), -- 1085
			4.5, -- 1085
			toColor(PALETTE.amberCore) -- 1085
		) -- 1085
		if opened then -- 1088
			local deskCx = cam:sx(p.ox + 605) -- 1089
			local groundY = cam:sy(0) -- 1090
			local deskW = cam:len(84) -- 1091
			local deskH = cam:len(34) -- 1092
			local deskTop = groundY + deskH -- 1093
			local writing = p.deskHold >= 24 or p.towerHanded -- 1094
			fillRadialGlow( -- 1096
				fgGlow, -- 1096
				deskCx, -- 1096
				deskTop + cam:len(26), -- 1096
				cam:len(96), -- 1096
				cam:len(74), -- 1096
				Color( -- 1097
					255, -- 1097
					198, -- 1097
					114, -- 1097
					math.floor(52 * pulse + 0.5) -- 1097
				), -- 1097
				Color(255, 168, 72, 0), -- 1097
				16 -- 1097
			) -- 1097
			local guardX = deskCx + cam:len(26) -- 1099
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 1100
			if not assets:tryPlacePath( -- 1103
				guardClip, -- 1103
				"tower_guard_npc", -- 1103
				guardX, -- 1103
				groundY, -- 1103
				cam:len(54), -- 1103
				cam:len(84), -- 1103
				{ -- 1103
					anchorX = 0.44, -- 1104
					anchorY = 0, -- 1105
					preserveAspect = true, -- 1106
					facing = -1, -- 1107
					opacity = 0.96, -- 1108
					layer = 3 -- 1109
				} -- 1109
			) then -- 1109
				fgDraw:drawRect( -- 1111
					Rect( -- 1111
						guardX - cam:len(11), -- 1111
						groundY, -- 1111
						cam:len(22), -- 1111
						cam:len(68) -- 1111
					), -- 1111
					Color(34, 42, 54, 240) -- 1111
				) -- 1111
				fgDraw:drawCircle( -- 1112
					Vec2( -- 1112
						guardX, -- 1112
						groundY + cam:len(76) -- 1112
					), -- 1112
					cam:len(9.5), -- 1112
					Color(42, 50, 62, 245) -- 1112
				) -- 1112
			end -- 1112
			if not assets:tryPlace( -- 1115
				"prop_table", -- 1115
				"tower_guard_desk", -- 1115
				deskCx, -- 1115
				groundY, -- 1115
				deskW * 1.06, -- 1115
				deskH * 1.04, -- 1115
				{ -- 1115
					color = Color(214, 188, 158, 255), -- 1116
					opacity = 0.98, -- 1117
					layer = 4 -- 1118
				} -- 1118
			) then -- 1118
				fgDraw:drawRect( -- 1120
					Rect( -- 1120
						deskCx - deskW * 0.5, -- 1120
						groundY, -- 1120
						cam:len(6), -- 1120
						deskH -- 1120
					), -- 1120
					Color(78, 52, 34, 255) -- 1120
				) -- 1120
				fgDraw:drawRect( -- 1121
					Rect( -- 1121
						deskCx + deskW * 0.5 - cam:len(6), -- 1121
						groundY, -- 1121
						cam:len(6), -- 1121
						deskH -- 1121
					), -- 1121
					Color(78, 52, 34, 255) -- 1121
				) -- 1121
				fgDraw:drawRect( -- 1122
					Rect( -- 1122
						deskCx - deskW * 0.52, -- 1122
						deskTop - cam:len(6), -- 1122
						deskW * 1.04, -- 1122
						cam:len(8) -- 1122
					), -- 1122
					Color(108, 74, 46, 255), -- 1122
					1, -- 1122
					Color(148, 108, 68, 220) -- 1122
				) -- 1122
			end -- 1122
			fgDraw:drawRect( -- 1125
				Rect( -- 1125
					deskCx + cam:len(4), -- 1125
					deskTop + cam:len(1), -- 1125
					cam:len(22), -- 1125
					cam:len(4.5) -- 1125
				), -- 1125
				Color(232, 222, 198, 245) -- 1125
			) -- 1125
			if writing then -- 1126
				assets:tryPlace( -- 1127
					"prop_lantern", -- 1127
					"tower_desk_lamp", -- 1127
					deskCx + cam:len(34), -- 1127
					deskTop + cam:len(10), -- 1127
					cam:len(14), -- 1127
					cam:len(20), -- 1127
					{layer = 5} -- 1127
				) -- 1127
				fillRadialGlow( -- 1128
					fgGlow, -- 1128
					deskCx + cam:len(34), -- 1128
					deskTop + cam:len(12), -- 1128
					cam:len(24), -- 1128
					cam:len(22), -- 1128
					Color( -- 1128
						255, -- 1128
						214, -- 1128
						134, -- 1128
						math.floor(88 * pulse + 0.5) -- 1128
					), -- 1128
					Color(255, 180, 86, 0), -- 1128
					12 -- 1128
				) -- 1128
			else -- 1128
				fillRadialGlow( -- 1130
					fgGlow, -- 1130
					deskCx + cam:len(3), -- 1130
					deskTop + cam:len(18), -- 1130
					cam:len(30), -- 1130
					cam:len(28), -- 1130
					Color( -- 1130
						255, -- 1130
						214, -- 1130
						134, -- 1130
						math.floor(78 * pulse + 0.5) -- 1130
					), -- 1130
					Color(255, 180, 86, 0), -- 1130
					12 -- 1130
				) -- 1130
			end -- 1130
			if p.deskHold >= 12 or p.towerHanded then -- 1133
				if not assets:tryPlacePath( -- 1134
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1134
					"tower_desk_pouch", -- 1134
					deskCx - cam:len(22), -- 1134
					deskTop + cam:len(8), -- 1134
					cam:len(18), -- 1134
					cam:len(18), -- 1134
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1134
				) then -- 1134
					fgDraw:drawRect( -- 1140
						Rect( -- 1140
							deskCx - cam:len(28), -- 1140
							deskTop + cam:len(2), -- 1140
							cam:len(14), -- 1140
							cam:len(6) -- 1140
						), -- 1140
						Color(156, 62, 48, 245) -- 1140
					) -- 1140
				end -- 1140
			end -- 1140
			if writing then -- 1143
				fgDraw:drawRect( -- 1144
					Rect( -- 1144
						deskCx - cam:len(6), -- 1144
						deskTop + cam:len(2), -- 1144
						cam:len(10), -- 1144
						cam:len(3) -- 1144
					), -- 1144
					Color(236, 228, 206, 240) -- 1144
				) -- 1144
			end -- 1144
		end -- 1144
	end -- 1144
end -- 1017
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1150
	local blades = math.max( -- 1157
		12, -- 1157
		math.floor(sw / 8) -- 1157
	) -- 1157
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1158
	local k = 0 -- 1159
	do -- 1159
		k = 0 -- 1160
		while k < blades do -- 1160
			local t = (k + 0.5) / blades -- 1161
			local bx = x0 + sw * t -- 1162
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1163
			local bh = sh * hRatio * 1.95 -- 1164
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1165
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1166
			fgDraw:drawPolygon( -- 1167
				{ -- 1167
					Vec2(bx - 7, y0), -- 1168
					Vec2(bx + 7, y0), -- 1169
					Vec2(bx + sway, y0 + bh) -- 1170
				}, -- 1170
				col -- 1171
			) -- 1171
			k = k + 1 -- 1160
		end -- 1160
	end -- 1160
	if nearPlayer then -- 1173
		fgGlow:drawSegment( -- 1174
			Vec2(x0, y0 + 2), -- 1174
			Vec2(x0 + sw, y0 + 2), -- 1174
			2, -- 1174
			toColor(PALETTE.emerald, 145) -- 1174
		) -- 1174
	end -- 1174
end -- 1150
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1178
	local a = p.room.arch -- 1183
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1184
		return -- 1185
	end -- 1185
	local x0 = cam:sx(a.x0) -- 1187
	local x1 = cam:sx(a.x1) -- 1188
	local y0 = cam:sy(a.y) -- 1189
	local y1 = cam:sy(a.y + a.h) -- 1190
	local cx = (x0 + x1) * 0.5 -- 1191
	local rx = (x1 - x0) * 0.5 -- 1192
	local rise = cam:len(9) -- 1193
	local rim = cam:len(7) -- 1194
	local slices = 9 -- 1195
	local mortar = Color(31, 32, 35, 255) -- 1196
	local function point(i, edge) -- 1197
		local angle = math.pi * i / slices -- 1198
		return Vec2( -- 1199
			cx + math.cos(angle) * (rx + edge), -- 1199
			y1 + math.sin(angle) * (rise + edge) -- 1199
		) -- 1199
	end -- 1197
	local opening = { -- 1201
		Vec2(x0, y0), -- 1201
		Vec2(x1, y0) -- 1201
	} -- 1201
	do -- 1201
		local i = 0 -- 1202
		while i <= slices do -- 1202
			opening[#opening + 1] = point(i, 0) -- 1203
			i = i + 1 -- 1202
		end -- 1202
	end -- 1202
	draw:drawPolygon( -- 1205
		opening, -- 1205
		Color(13, 15, 20, 248) -- 1205
	) -- 1205
	draw:drawRect( -- 1206
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1206
		Color(62, 63, 67, 255), -- 1206
		1, -- 1206
		mortar -- 1206
	) -- 1206
	draw:drawRect( -- 1207
		Rect(x1, y0, rim, y1 - y0), -- 1207
		Color(72, 72, 74, 255), -- 1207
		1, -- 1207
		mortar -- 1207
	) -- 1207
	do -- 1207
		local i = 0 -- 1208
		while i < slices do -- 1208
			local shade = 77 + i % 3 * 8 -- 1209
			draw:drawPolygon( -- 1210
				{ -- 1210
					point(i, 0), -- 1210
					point(i, rim), -- 1210
					point(i + 1, rim), -- 1210
					point(i + 1, 0) -- 1210
				}, -- 1210
				Color(shade, shade, shade + 1, 255), -- 1211
				1, -- 1211
				mortar -- 1211
			) -- 1211
			i = i + 1 -- 1208
		end -- 1208
	end -- 1208
	if not p.cartDocked then -- 1214
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1215
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1216
		if bx1 > bx0 + 4 then -- 1217
			local deckY = cam:sy(p.room.cart.baseY) -- 1218
			draw:drawRect( -- 1219
				Rect(bx0, y0 + 2, bx1 - bx0, y1 - y0 - 2), -- 1219
				Color(72, 52, 36, 245), -- 1219
				1.1, -- 1219
				Color(138, 108, 78, 210) -- 1219
			) -- 1219
			draw:drawSegment( -- 1220
				Vec2((bx0 + bx1) * 0.5, y1), -- 1220
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1220
				2.4, -- 1220
				Color(96, 102, 110, 220) -- 1220
			) -- 1220
		end -- 1220
	end -- 1220
end -- 1178
return ____exports -- 1178
