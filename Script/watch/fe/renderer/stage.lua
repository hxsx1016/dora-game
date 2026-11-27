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
	if solid.id == "e3_bench" then -- 746
		return -- 747
	end -- 747
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 750
		assets:tryPlace( -- 751
			"slab", -- 751
			"gate_sill_" .. tostring(solid.x), -- 751
			center, -- 751
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 751
			width + cam:len(34), -- 752
			cam:len(12), -- 752
			{ -- 752
				layer = 1, -- 752
				color = Color(180, 169, 150, 255) -- 752
			} -- 752
		) -- 752
	end -- 752
	draw:drawEllipse( -- 754
		Vec2( -- 754
			center, -- 754
			base + cam:len(2) -- 754
		), -- 754
		width * 0.5, -- 754
		math.max( -- 755
			2, -- 755
			cam:len(2.5) -- 755
		), -- 755
		Color(10, 10, 14, 128 * opacity) -- 755
	) -- 755
	local propArt = dedicatedSolidProp(solid) -- 758
	if propArt ~= nil then -- 759
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 760
		local drawH = frontH * propArt.heightMul -- 761
		local cols = propArt.tileable and math.max( -- 762
			1, -- 763
			math.min( -- 763
				6, -- 763
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 763
			) -- 763
		) or 1 -- 764
		local colW = width / cols -- 765
		local tint = occlusionTint(opacity) -- 766
		local placedProp = false -- 767
		do -- 767
			local col = 0 -- 768
			while col < cols do -- 768
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 769
				if assets:tryPlacePath( -- 770
					propPath, -- 770
					tileKey, -- 770
					left + (col + 0.5) * colW, -- 770
					base, -- 770
					colW + 1, -- 770
					drawH, -- 770
					{ -- 770
						anchorX = 0.5, -- 771
						anchorY = 0, -- 772
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 773
						opacity = opacity, -- 774
						color = tint, -- 775
						layer = layer -- 776
					} -- 776
				) then -- 776
					placedProp = true -- 778
				end -- 778
				col = col + 1 -- 768
			end -- 768
		end -- 768
		if placedProp then -- 781
			return -- 782
		end -- 782
	end -- 782
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 786
	if slot ~= "fence" and capHeight > 1 then -- 789
		local capTop = top + capHeight -- 790
		if not assets:tryPlace( -- 791
			slot, -- 791
			"cap_" .. tostring(solid.x), -- 791
			center, -- 791
			top, -- 791
			width, -- 791
			capHeight, -- 791
			{ -- 792
				opacity = math.min(1, opacity), -- 792
				layer = layer -- 792
			} -- 792
		) then -- 792
			local capFill = occlusionTint( -- 793
				opacity, -- 793
				timber and Color( -- 793
					74, -- 794
					56, -- 794
					42, -- 794
					math.floor(232 * opacity + 0.5) -- 794
				) or Color( -- 795
					74, -- 795
					78, -- 795
					86, -- 795
					math.floor(232 * opacity + 0.5) -- 795
				) -- 795
			) -- 795
			fillVGradRect( -- 796
				draw, -- 796
				left, -- 796
				top, -- 796
				width, -- 796
				capHeight, -- 796
				capFill, -- 797
				occlusionTint( -- 797
					opacity, -- 797
					Color( -- 797
						44, -- 797
						46, -- 797
						52, -- 797
						math.floor(220 * opacity + 0.5) -- 797
					) -- 797
				) -- 797
			) -- 797
		end -- 797
		draw:drawSegment( -- 799
			Vec2(left + width * 0.04, capTop - 0.5), -- 799
			Vec2(right - width * 0.04, capTop - 0.5), -- 799
			0.9, -- 800
			occlusionTint( -- 800
				opacity, -- 800
				timber and Color( -- 800
					122, -- 801
					96, -- 801
					72, -- 801
					math.floor(150 * opacity + 0.5) -- 801
				) or Color( -- 802
					118, -- 802
					124, -- 802
					132, -- 802
					math.floor(140 * opacity + 0.5) -- 802
				) -- 802
			) -- 802
		) -- 802
	end -- 802
	if timber and solid.h > solid.w * 1.6 then -- 806
		local colFill = occlusionTint( -- 807
			opacity, -- 807
			Color( -- 807
				66, -- 807
				48, -- 807
				36, -- 807
				math.floor(248 * opacity + 0.5) -- 807
			) -- 807
		) -- 807
		local colHi = occlusionTint( -- 808
			opacity, -- 808
			Color( -- 808
				122, -- 808
				92, -- 808
				68, -- 808
				math.floor(200 * opacity + 0.5) -- 808
			) -- 808
		) -- 808
		local colSh = occlusionTint( -- 809
			opacity, -- 809
			Color( -- 809
				34, -- 809
				24, -- 809
				18, -- 809
				math.floor(220 * opacity + 0.5) -- 809
			) -- 809
		) -- 809
		draw:drawRect( -- 810
			Rect(left, base, width, frontH), -- 810
			colFill, -- 810
			1, -- 810
			colHi -- 810
		) -- 810
		draw:drawRect( -- 811
			Rect(left + width * 0.65, base, width * 0.35, frontH), -- 811
			colSh -- 811
		) -- 811
		draw:drawSegment( -- 812
			Vec2(left + width * 0.32, base + 2), -- 812
			Vec2(left + width * 0.32, top - 2), -- 812
			0.9, -- 812
			colHi -- 812
		) -- 812
		return -- 813
	end -- 813
	if solid.w > solid.h * 5 then -- 817
		local beamFill = occlusionTint( -- 818
			opacity, -- 818
			Color( -- 818
				78, -- 818
				58, -- 818
				42, -- 818
				math.floor(248 * opacity + 0.5) -- 818
			) -- 818
		) -- 818
		local beamEdge = occlusionTint( -- 819
			opacity, -- 819
			Color( -- 819
				142, -- 819
				110, -- 819
				82, -- 819
				math.floor(215 * opacity + 0.5) -- 819
			) -- 819
		) -- 819
		draw:drawRect( -- 820
			Rect( -- 820
				left, -- 820
				base, -- 820
				width, -- 820
				math.max(4, frontH) -- 820
			), -- 820
			beamFill, -- 820
			1, -- 820
			beamEdge -- 820
		) -- 820
		local posts = math.max( -- 821
			2, -- 821
			math.floor(solid.w / 140 + 0.5) -- 821
		) -- 821
		do -- 821
			local pi = 0 -- 822
			while pi <= posts do -- 822
				local px = left + width * pi / posts -- 823
				draw:drawSegment( -- 824
					Vec2(px, base), -- 824
					Vec2(px, top), -- 824
					1.4, -- 824
					Color( -- 824
						34, -- 824
						24, -- 824
						18, -- 824
						math.floor(210 * opacity + 0.5) -- 824
					) -- 824
				) -- 824
				pi = pi + 1 -- 822
			end -- 822
		end -- 822
		return -- 826
	end -- 826
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 830
	local cols = slot == "wall" and math.max( -- 831
		1, -- 832
		math.min( -- 832
			10, -- 832
			math.floor(solid.w / 72 + 0.5) -- 832
		) -- 832
	) or math.max( -- 833
		1, -- 833
		math.min( -- 833
			10, -- 833
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 833
		) -- 833
	) -- 833
	local colW = width / cols -- 834
	local rows = slot == "wall" and math.max( -- 835
		1, -- 836
		math.min( -- 836
			10, -- 836
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 836
		) -- 836
	) or math.max( -- 837
		1, -- 837
		math.min( -- 837
			6, -- 837
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 837
		) -- 837
	) -- 837
	local rowHeight = frontH / rows -- 838
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 839
	local color = occlusionTint(opacity, masonryColor) -- 840
	local placedAny = false -- 841
	do -- 841
		local row = 0 -- 842
		while row < rows do -- 842
			do -- 842
				local col = 0 -- 843
				while col < cols do -- 843
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 844
					if assets:tryPlace( -- 845
						slot, -- 845
						tileKey, -- 845
						left + (col + 0.5) * colW, -- 845
						base + row * rowHeight, -- 845
						colW + 0.5, -- 845
						rowHeight + 0.5, -- 845
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 845
					) then -- 845
						placedAny = true -- 848
					end -- 848
					col = col + 1 -- 843
				end -- 843
			end -- 843
			row = row + 1 -- 842
		end -- 842
	end -- 842
	if not placedAny then -- 852
		draw:drawRect( -- 853
			Rect(left, base, width, frontH), -- 853
			occlusionTint( -- 854
				opacity, -- 854
				toColor(PALETTE.steelMid, 255 * opacity) -- 854
			), -- 854
			1, -- 855
			toColor(theme.groundRim, 150 * opacity) -- 855
		) -- 855
	end -- 855
end -- 724
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 859
	local columns = math.max( -- 864
		1, -- 864
		math.min( -- 864
			10, -- 864
			math.floor(s.w / 58 + 0.5) -- 864
		) -- 864
	) -- 864
	local cellWorldW = s.w / columns -- 865
	local targetCellH = math.max( -- 866
		24, -- 866
		math.min(48, cellWorldW / 1.52) -- 866
	) -- 866
	local rows = math.max( -- 867
		1, -- 867
		math.min( -- 867
			12, -- 867
			math.floor(s.h / targetCellH + 0.5) -- 867
		) -- 867
	) -- 867
	local tileW = width / columns -- 868
	local tileH = height / rows -- 869
	do -- 869
		local row = 0 -- 870
		while row < rows do -- 870
			do -- 870
				local column = 0 -- 871
				while column < columns do -- 871
					assets:tryPlace( -- 872
						"wall", -- 872
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 872
						x + (column + 0.5) * tileW, -- 873
						y + row * tileH, -- 873
						tileW + 0.5, -- 873
						tileH + 0.5, -- 873
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 874
					) -- 874
					column = column + 1 -- 871
				end -- 871
			end -- 871
			row = row + 1 -- 870
		end -- 870
	end -- 870
end -- 859
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 879
	local slot = coverArt(s) -- 886
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 887
	local cols = math.max( -- 888
		1, -- 888
		math.min( -- 888
			8, -- 888
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 888
		) -- 888
	) -- 888
	local tileW = sw / cols -- 889
	local placed = false -- 890
	do -- 890
		local c = 0 -- 891
		while c < cols do -- 891
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 892
			if assets:tryPlace( -- 893
				slot, -- 893
				k, -- 893
				x0 + (c + 0.5) * tileW, -- 893
				y0, -- 893
				tileW + 0.5, -- 893
				sh, -- 893
				{layer = 1} -- 893
			) then -- 893
				placed = true -- 894
			end -- 894
			c = c + 1 -- 891
		end -- 891
	end -- 891
	if not placed then -- 897
		fillVGradRect( -- 898
			fgDraw, -- 898
			x0, -- 898
			y0, -- 898
			sw, -- 898
			sh, -- 898
			toColor(PALETTE.steelDark), -- 898
			toColor(PALETTE.steelMid) -- 898
		) -- 898
		fgDraw:drawSegment( -- 899
			Vec2(x0, y0 + sh), -- 899
			Vec2(x0 + sw, y0 + sh), -- 899
			1.4, -- 899
			toColor(theme.groundRim) -- 899
		) -- 899
	end -- 899
	if not p.childMode and (p.coverHug or p.coverNear) then -- 903
		local plx = p.player.x -- 904
		local nearLeft = math.abs(plx - s.x) < 42 -- 905
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 906
		if nearLeft or nearRight then -- 907
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 908
			local isWood = slot == "cover_wood" -- 909
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 910
			fgDraw:drawSegment( -- 911
				Vec2(edgeX, y0 + 4), -- 911
				Vec2(edgeX, y0 + sh + 2), -- 911
				p.coverHug and 2 or 1.2, -- 911
				toColor(col, p.coverHug and 205 or 120) -- 911
			) -- 911
		end -- 911
	end -- 911
end -- 879
function StageRenderer.prototype.drawRedCartPixel(self, draw, x0, y0, sw, sh, cam) -- 920
	local bodyH = math.max(6, sh * 0.62) -- 923
	local bodyY = y0 + sh - bodyH -- 924
	draw:drawRect( -- 925
		Rect(x0, bodyY, sw, bodyH), -- 925
		Color(92, 70, 52, 248), -- 925
		1, -- 925
		Color(150, 118, 86, 215) -- 925
	) -- 925
	draw:drawRect( -- 926
		Rect( -- 926
			x0 - cam:len(3), -- 926
			bodyY + cam:len(1), -- 926
			sw + cam:len(8), -- 926
			bodyH * 0.92 -- 926
		), -- 926
		toColor(PALETTE.clothRed), -- 927
		1, -- 927
		toColor(PALETTE.clothRedHighlight) -- 927
	) -- 927
	draw:drawRect( -- 928
		Rect(x0 + sw * 0.16, bodyY + bodyH * 0.36, sw * 0.24, bodyH * 0.32), -- 928
		Color(214, 206, 188, 215) -- 929
	) -- 929
	draw:drawRect( -- 930
		Rect(x0 + sw * 0.58, bodyY + bodyH * 0.52, sw * 0.18, bodyH * 0.22), -- 930
		Color(196, 188, 172, 200) -- 931
	) -- 931
	draw:drawSegment( -- 932
		Vec2( -- 932
			x0 + sw - cam:len(2), -- 932
			bodyY + bodyH * 0.72 -- 932
		), -- 932
		Vec2( -- 933
			x0 + sw + cam:len(26), -- 933
			bodyY + bodyH * 1.36 -- 933
		), -- 933
		math.max( -- 934
			2, -- 934
			cam:len(2.6) -- 934
		), -- 934
		Color(126, 98, 68, 240) -- 934
	) -- 934
	draw:drawEllipse( -- 935
		Vec2( -- 935
			x0 + sw * 0.26, -- 935
			y0 + sh - cam:len(1) -- 935
		), -- 935
		cam:len(5.2), -- 935
		cam:len(5.2), -- 935
		Color(40, 34, 30, 235) -- 936
	) -- 936
	draw:drawEllipse( -- 937
		Vec2( -- 937
			x0 + sw * 0.26, -- 937
			y0 + sh - cam:len(1) -- 937
		), -- 937
		cam:len(2.1), -- 937
		cam:len(2.1), -- 937
		Color(150, 126, 92, 220) -- 938
	) -- 938
end -- 920
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 941
	if layer == nil then -- 946
		layer = 2 -- 946
	end -- 946
	local cx = x0 + sw * 0.5 -- 948
	local cy = y0 + sh * 0.55 -- 949
	local ropeWidth = math.max(1, sw * 0.023) -- 950
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 951
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 952
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 953
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 954
	draw:drawEllipse( -- 955
		Vec2(cx, y0), -- 955
		sw * 0.53, -- 955
		sh * 0.07, -- 955
		Color(10, 8, 9, 150) -- 955
	) -- 955
	draw:drawSegment( -- 956
		drum, -- 956
		bend, -- 956
		ropeWidth, -- 956
		Color(111, 86, 57, 239) -- 956
	) -- 956
	draw:drawSegment( -- 957
		bend, -- 957
		ropeTop, -- 957
		ropeWidth, -- 957
		Color(111, 86, 57, 239) -- 957
	) -- 957
	if assets:tryPlace( -- 958
		"prop_winch", -- 958
		"gate_winch", -- 958
		cx, -- 958
		y0 + sh * 0.5, -- 958
		sw, -- 958
		sh, -- 958
		{layer = layer} -- 958
	) then -- 958
		return -- 959
	end -- 959
	local timber = Color(75, 51, 34, 255) -- 961
	draw:drawSegment( -- 962
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 962
		Vec2(cx, y0 + sh * 0.86), -- 962
		sw * 0.06, -- 962
		timber -- 962
	) -- 962
	draw:drawSegment( -- 963
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 963
		Vec2(cx, y0 + sh * 0.86), -- 963
		sw * 0.06, -- 963
		timber -- 963
	) -- 963
	draw:drawRect( -- 964
		Rect(x0, y0, sw, sh * 0.12), -- 964
		timber -- 964
	) -- 964
	local radius = math.min(sw, sh) * 0.21 -- 965
	draw:drawCircle( -- 966
		Vec2(cx, cy), -- 966
		radius, -- 966
		Color(48, 41, 37, 255) -- 966
	) -- 966
	do -- 966
		local i = -2 -- 967
		while i <= 2 do -- 967
			local x = cx + i * radius * 0.28 -- 968
			draw:drawSegment( -- 969
				Vec2(x, cy - radius * 0.62), -- 969
				Vec2(x, cy + radius * 0.62), -- 969
				ropeWidth, -- 969
				Color(135, 103, 68, 240) -- 970
			) -- 970
			i = i + 1 -- 967
		end -- 967
	end -- 967
end -- 941
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 974
	local ____temp_3 -- 982
	if p.room.story ~= nil then -- 982
		____temp_3 = p.room.story.gate -- 982
	else -- 982
		____temp_3 = nil -- 982
	end -- 982
	local g = ____temp_3 -- 982
	if g == nil then -- 983
		return -- 984
	end -- 984
	local closeFrac = 0.08 -- 987
	if p.phase == "gate-hold" then -- 988
		closeFrac = 0.08 + 0.36 * math.min( -- 989
			1, -- 989
			p.gateTick / math.max(1, g.holdTicks) -- 989
		) -- 989
	elseif p.phase == "gate-send" then -- 990
		closeFrac = 0.44 -- 991
	elseif p.phase == "gate-count" then -- 992
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 993
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 994
		closeFrac = 1 -- 995
	end -- 995
	local gx0 = cam:sx(848) -- 997
	local gx1 = cam:sx(1032) -- 998
	local topY = cam:sy(160) -- 999
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1000
	local shutterW = gx1 - gx0 -- 1001
	local shutterH = topY - botY -- 1002
	if shutterH > 2 then -- 1003
		fillVGradRect( -- 1004
			fgDraw, -- 1004
			gx0, -- 1004
			botY, -- 1004
			shutterW, -- 1004
			shutterH, -- 1004
			toColor(PALETTE.steelDark), -- 1004
			toColor(PALETTE.steelMid) -- 1004
		) -- 1004
		local rows = math.max( -- 1006
			1, -- 1006
			math.min( -- 1006
				6, -- 1006
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1006
			) -- 1006
		) -- 1006
		local rowH = shutterH / rows -- 1007
		do -- 1007
			local r = 0 -- 1008
			while r < rows do -- 1008
				assets:tryPlace( -- 1009
					"cover_wood", -- 1009
					"gate_shutter_" .. tostring(r), -- 1009
					(gx0 + gx1) * 0.5, -- 1009
					botY + r * rowH, -- 1009
					shutterW, -- 1010
					rowH + 0.5, -- 1010
					{layer = 6} -- 1010
				) -- 1010
				r = r + 1 -- 1008
			end -- 1008
		end -- 1008
	end -- 1008
	if closeFrac < 0.98 then -- 1014
		local gapH = math.max( -- 1015
			8, -- 1015
			botY - cam:sy(0) -- 1015
		) -- 1015
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1016
		fillVGradRect( -- 1017
			fgGlow, -- 1017
			gx0, -- 1017
			cam:sy(0), -- 1017
			gx1 - gx0, -- 1017
			gapH, -- 1017
			Color( -- 1017
				140, -- 1017
				210, -- 1017
				255, -- 1017
				math.floor(52 * pulse + 0.5) -- 1017
			), -- 1017
			Color(80, 160, 230, 0) -- 1017
		) -- 1017
	end -- 1017
end -- 974
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1021
	fillVGradRect( -- 1028
		fgDraw, -- 1028
		x0, -- 1028
		y0, -- 1028
		sw, -- 1028
		sh, -- 1028
		Color(15, 21, 34, 255), -- 1028
		Color(32, 44, 66, 255) -- 1028
	) -- 1028
	fgDraw:drawRect( -- 1029
		Rect(x0, y0, sw, sh), -- 1029
		Color(0, 0, 0, 0), -- 1029
		1.4, -- 1029
		toColor(PALETTE.rimSilver, 165) -- 1029
	) -- 1029
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1031
		self:tileMasonry( -- 1032
			assets, -- 1032
			s, -- 1032
			x0, -- 1032
			y0, -- 1032
			sw, -- 1032
			sh -- 1032
		) -- 1032
		local ribs = 4 -- 1034
		local r = 1 -- 1035
		do -- 1035
			r = 1 -- 1036
			while r < ribs do -- 1036
				local rx = x0 + sw * r / ribs -- 1037
				fgDraw:drawSegment( -- 1038
					Vec2(rx, y0), -- 1038
					Vec2(rx, y0 + sh), -- 1038
					2, -- 1038
					Color(10, 15, 24, 210) -- 1038
				) -- 1038
				fgDraw:drawSegment( -- 1039
					Vec2(rx + 2, y0), -- 1039
					Vec2(rx + 2, y0 + sh), -- 1039
					1, -- 1039
					Color(68, 86, 114, 130) -- 1039
				) -- 1039
				r = r + 1 -- 1036
			end -- 1036
		end -- 1036
		local bands = 4 -- 1042
		local b = 1 -- 1043
		do -- 1043
			b = 1 -- 1044
			while b < bands do -- 1044
				local by = y0 + sh * b / bands -- 1045
				fgDraw:drawSegment( -- 1046
					Vec2(x0 + 4, by), -- 1046
					Vec2(x0 + sw - 4, by), -- 1046
					1.2, -- 1046
					Color(52, 68, 92, 135) -- 1046
				) -- 1046
				b = b + 1 -- 1044
			end -- 1044
		end -- 1044
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1049
		local slitY = y0 + sh * 0.56 -- 1050
		local slitH = sh * 0.22 -- 1051
		fgDraw:drawRect( -- 1052
			Rect(slitX - 5, slitY, 10, slitH), -- 1052
			Color(8, 12, 20, 245), -- 1052
			1.2, -- 1052
			toColor(PALETTE.amberDim, 190) -- 1052
		) -- 1052
		fgGlow:drawRect( -- 1053
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1053
			toColor(PALETTE.amber, 190) -- 1053
		) -- 1053
		fillRadialGlow( -- 1054
			fgGlow, -- 1054
			slitX, -- 1054
			slitY + slitH * 0.5, -- 1054
			44, -- 1054
			slitH * 0.7, -- 1054
			Color(255, 206, 128, 52), -- 1054
			Color(255, 180, 86, 0), -- 1054
			14 -- 1054
		) -- 1054
	end -- 1054
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1058
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1059
		local cx = x0 + sw * 0.5 -- 1064
		local lampY = y0 - 8 -- 1065
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1066
		if not opened then -- 1067
			assets:tryPlace( -- 1068
				"prop_tower_door", -- 1068
				"tower_door", -- 1068
				cx, -- 1068
				y0 - doorHeight, -- 1068
				sw, -- 1068
				doorHeight, -- 1068
				{layer = 2} -- 1068
			) -- 1068
		end -- 1068
		assets:tryPlace( -- 1070
			"prop_lantern", -- 1070
			"tower_lantern", -- 1070
			cx + sw * 0.43, -- 1070
			lampY - sh * 0.36, -- 1070
			sw * 0.17, -- 1071
			sh * 0.84, -- 1071
			{layer = 3} -- 1071
		) -- 1071
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1072
		local alpha = opened and 58 or 42 -- 1073
		fgDraw:drawSegment( -- 1075
			Vec2(x0 + 4, y0), -- 1075
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1075
			4, -- 1075
			Color(42, 52, 70, 255) -- 1075
		) -- 1075
		fgDraw:drawSegment( -- 1076
			Vec2(x0 + sw - 4, y0), -- 1076
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1076
			4, -- 1076
			Color(42, 52, 70, 255) -- 1076
		) -- 1076
		fgDraw:drawSegment( -- 1077
			Vec2(x0, y0), -- 1077
			Vec2(x0 + sw, y0), -- 1077
			2.5, -- 1077
			toColor(PALETTE.amber, 210) -- 1077
		) -- 1077
		fillVGradRect( -- 1079
			fgGlow, -- 1080
			x0 + 6, -- 1081
			y0 - sh * 3.8, -- 1082
			sw - 12, -- 1083
			sh * 3.8, -- 1084
			Color( -- 1085
				246, -- 1085
				196, -- 1085
				118, -- 1085
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1085
			), -- 1085
			Color(246, 206, 142, opened and 74 or 38) -- 1086
		) -- 1086
		fillRadialGlow( -- 1088
			fgGlow, -- 1088
			cx, -- 1088
			lampY, -- 1088
			opened and 78 or 54, -- 1088
			opened and 72 or 52, -- 1088
			Color( -- 1088
				252, -- 1088
				218, -- 1088
				152, -- 1088
				math.floor(92 * pulse + 0.5) -- 1088
			), -- 1088
			Color(255, 180, 86, 0), -- 1088
			18 -- 1088
		) -- 1088
		fgDraw:drawCircle( -- 1089
			Vec2(cx, lampY), -- 1089
			4.5, -- 1089
			toColor(PALETTE.amberCore) -- 1089
		) -- 1089
		if opened then -- 1092
			local deskCx = cam:sx(p.ox + 605) -- 1093
			local groundY = cam:sy(0) -- 1094
			local deskW = cam:len(84) -- 1095
			local deskH = cam:len(34) -- 1096
			local deskTop = groundY + deskH -- 1097
			local writing = p.deskHold >= 24 or p.towerHanded -- 1098
			fillRadialGlow( -- 1100
				fgGlow, -- 1100
				deskCx, -- 1100
				deskTop + cam:len(26), -- 1100
				cam:len(96), -- 1100
				cam:len(74), -- 1100
				Color( -- 1101
					255, -- 1101
					198, -- 1101
					114, -- 1101
					math.floor(52 * pulse + 0.5) -- 1101
				), -- 1101
				Color(255, 168, 72, 0), -- 1101
				16 -- 1101
			) -- 1101
			local guardX = deskCx + cam:len(26) -- 1103
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 1104
			if not assets:tryPlacePath( -- 1107
				guardClip, -- 1107
				"tower_guard_npc", -- 1107
				guardX, -- 1107
				groundY, -- 1107
				cam:len(54), -- 1107
				cam:len(84), -- 1107
				{ -- 1107
					anchorX = 0.44, -- 1108
					anchorY = 0, -- 1109
					preserveAspect = true, -- 1110
					facing = -1, -- 1111
					opacity = 0.96, -- 1112
					layer = 3 -- 1113
				} -- 1113
			) then -- 1113
				fgDraw:drawRect( -- 1115
					Rect( -- 1115
						guardX - cam:len(11), -- 1115
						groundY, -- 1115
						cam:len(22), -- 1115
						cam:len(68) -- 1115
					), -- 1115
					Color(34, 42, 54, 240) -- 1115
				) -- 1115
				fgDraw:drawCircle( -- 1116
					Vec2( -- 1116
						guardX, -- 1116
						groundY + cam:len(76) -- 1116
					), -- 1116
					cam:len(9.5), -- 1116
					Color(42, 50, 62, 245) -- 1116
				) -- 1116
			end -- 1116
			if not assets:tryPlace( -- 1119
				"prop_table", -- 1119
				"tower_guard_desk", -- 1119
				deskCx, -- 1119
				groundY, -- 1119
				deskW * 1.06, -- 1119
				deskH * 1.04, -- 1119
				{ -- 1119
					color = Color(214, 188, 158, 255), -- 1120
					opacity = 0.98, -- 1121
					layer = 4 -- 1122
				} -- 1122
			) then -- 1122
				fgDraw:drawRect( -- 1124
					Rect( -- 1124
						deskCx - deskW * 0.5, -- 1124
						groundY, -- 1124
						cam:len(6), -- 1124
						deskH -- 1124
					), -- 1124
					Color(78, 52, 34, 255) -- 1124
				) -- 1124
				fgDraw:drawRect( -- 1125
					Rect( -- 1125
						deskCx + deskW * 0.5 - cam:len(6), -- 1125
						groundY, -- 1125
						cam:len(6), -- 1125
						deskH -- 1125
					), -- 1125
					Color(78, 52, 34, 255) -- 1125
				) -- 1125
				fgDraw:drawRect( -- 1126
					Rect( -- 1126
						deskCx - deskW * 0.52, -- 1126
						deskTop - cam:len(6), -- 1126
						deskW * 1.04, -- 1126
						cam:len(8) -- 1126
					), -- 1126
					Color(108, 74, 46, 255), -- 1126
					1, -- 1126
					Color(148, 108, 68, 220) -- 1126
				) -- 1126
			end -- 1126
			fgDraw:drawRect( -- 1129
				Rect( -- 1129
					deskCx + cam:len(4), -- 1129
					deskTop + cam:len(1), -- 1129
					cam:len(22), -- 1129
					cam:len(4.5) -- 1129
				), -- 1129
				Color(232, 222, 198, 245) -- 1129
			) -- 1129
			if writing then -- 1130
				assets:tryPlace( -- 1131
					"prop_lantern", -- 1131
					"tower_desk_lamp", -- 1131
					deskCx + cam:len(34), -- 1131
					deskTop + cam:len(10), -- 1131
					cam:len(14), -- 1131
					cam:len(20), -- 1131
					{layer = 5} -- 1131
				) -- 1131
				fillRadialGlow( -- 1132
					fgGlow, -- 1132
					deskCx + cam:len(34), -- 1132
					deskTop + cam:len(12), -- 1132
					cam:len(24), -- 1132
					cam:len(22), -- 1132
					Color( -- 1132
						255, -- 1132
						214, -- 1132
						134, -- 1132
						math.floor(88 * pulse + 0.5) -- 1132
					), -- 1132
					Color(255, 180, 86, 0), -- 1132
					12 -- 1132
				) -- 1132
			else -- 1132
				fillRadialGlow( -- 1134
					fgGlow, -- 1134
					deskCx + cam:len(3), -- 1134
					deskTop + cam:len(18), -- 1134
					cam:len(30), -- 1134
					cam:len(28), -- 1134
					Color( -- 1134
						255, -- 1134
						214, -- 1134
						134, -- 1134
						math.floor(78 * pulse + 0.5) -- 1134
					), -- 1134
					Color(255, 180, 86, 0), -- 1134
					12 -- 1134
				) -- 1134
			end -- 1134
			if p.deskHold >= 12 or p.towerHanded then -- 1137
				if not assets:tryPlacePath( -- 1138
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1138
					"tower_desk_pouch", -- 1138
					deskCx - cam:len(22), -- 1138
					deskTop + cam:len(8), -- 1138
					cam:len(18), -- 1138
					cam:len(18), -- 1138
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1138
				) then -- 1138
					fgDraw:drawRect( -- 1144
						Rect( -- 1144
							deskCx - cam:len(28), -- 1144
							deskTop + cam:len(2), -- 1144
							cam:len(14), -- 1144
							cam:len(6) -- 1144
						), -- 1144
						Color(156, 62, 48, 245) -- 1144
					) -- 1144
				end -- 1144
			end -- 1144
			if writing then -- 1147
				fgDraw:drawRect( -- 1148
					Rect( -- 1148
						deskCx - cam:len(6), -- 1148
						deskTop + cam:len(2), -- 1148
						cam:len(10), -- 1148
						cam:len(3) -- 1148
					), -- 1148
					Color(236, 228, 206, 240) -- 1148
				) -- 1148
			end -- 1148
		end -- 1148
	end -- 1148
end -- 1021
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1154
	local blades = math.max( -- 1161
		12, -- 1161
		math.floor(sw / 8) -- 1161
	) -- 1161
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1162
	local k = 0 -- 1163
	do -- 1163
		k = 0 -- 1164
		while k < blades do -- 1164
			local t = (k + 0.5) / blades -- 1165
			local bx = x0 + sw * t -- 1166
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1167
			local bh = sh * hRatio * 1.95 -- 1168
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1169
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1170
			fgDraw:drawPolygon( -- 1171
				{ -- 1171
					Vec2(bx - 7, y0), -- 1172
					Vec2(bx + 7, y0), -- 1173
					Vec2(bx + sway, y0 + bh) -- 1174
				}, -- 1174
				col -- 1175
			) -- 1175
			k = k + 1 -- 1164
		end -- 1164
	end -- 1164
	if nearPlayer then -- 1177
		fgGlow:drawSegment( -- 1178
			Vec2(x0, y0 + 2), -- 1178
			Vec2(x0 + sw, y0 + 2), -- 1178
			2, -- 1178
			toColor(PALETTE.emerald, 145) -- 1178
		) -- 1178
	end -- 1178
end -- 1154
function StageRenderer.prototype.drawArch(self, draw, p, cam) -- 1182
	local a = p.room.arch -- 1187
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1188
		return -- 1189
	end -- 1189
	local x0 = cam:sx(a.x0) -- 1191
	local x1 = cam:sx(a.x1) -- 1192
	local y0 = cam:sy(a.y) -- 1193
	local y1 = cam:sy(a.y + a.h) -- 1194
	local cx = (x0 + x1) * 0.5 -- 1195
	local rx = (x1 - x0) * 0.5 -- 1196
	local rise = cam:len(9) -- 1197
	local rim = cam:len(7) -- 1198
	local slices = 9 -- 1199
	local mortar = Color(31, 32, 35, 255) -- 1200
	local function point(i, edge) -- 1201
		local angle = math.pi * i / slices -- 1202
		return Vec2( -- 1203
			cx + math.cos(angle) * (rx + edge), -- 1203
			y1 + math.sin(angle) * (rise + edge) -- 1203
		) -- 1203
	end -- 1201
	local opening = { -- 1205
		Vec2(x0, y0), -- 1205
		Vec2(x1, y0) -- 1205
	} -- 1205
	do -- 1205
		local i = 0 -- 1206
		while i <= slices do -- 1206
			opening[#opening + 1] = point(i, 0) -- 1207
			i = i + 1 -- 1206
		end -- 1206
	end -- 1206
	draw:drawPolygon( -- 1209
		opening, -- 1209
		Color(13, 15, 20, 248) -- 1209
	) -- 1209
	draw:drawRect( -- 1210
		Rect(x0 - rim, y0, rim, y1 - y0), -- 1210
		Color(62, 63, 67, 255), -- 1210
		1, -- 1210
		mortar -- 1210
	) -- 1210
	draw:drawRect( -- 1211
		Rect(x1, y0, rim, y1 - y0), -- 1211
		Color(72, 72, 74, 255), -- 1211
		1, -- 1211
		mortar -- 1211
	) -- 1211
	do -- 1211
		local i = 0 -- 1212
		while i < slices do -- 1212
			local shade = 77 + i % 3 * 8 -- 1213
			draw:drawPolygon( -- 1214
				{ -- 1214
					point(i, 0), -- 1214
					point(i, rim), -- 1214
					point(i + 1, rim), -- 1214
					point(i + 1, 0) -- 1214
				}, -- 1214
				Color(shade, shade, shade + 1, 255), -- 1215
				1, -- 1215
				mortar -- 1215
			) -- 1215
			i = i + 1 -- 1212
		end -- 1212
	end -- 1212
	if not p.cartDocked then -- 1218
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1219
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1220
		if bx1 > bx0 + 4 then -- 1221
			local deckY = cam:sy(p.room.cart.baseY) -- 1222
			draw:drawRect( -- 1223
				Rect(bx0, y0 + 2, bx1 - bx0, y1 - y0 - 2), -- 1223
				Color(72, 52, 36, 245), -- 1223
				1.1, -- 1223
				Color(138, 108, 78, 210) -- 1223
			) -- 1223
			draw:drawSegment( -- 1224
				Vec2((bx0 + bx1) * 0.5, y1), -- 1224
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1224
				2.4, -- 1224
				Color(96, 102, 110, 220) -- 1224
			) -- 1224
		end -- 1224
	end -- 1224
end -- 1182
return ____exports -- 1182
