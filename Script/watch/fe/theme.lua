-- [ts]: theme.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Vec2 = ____Dora.Vec2 -- 12
function ____exports.rgba(r, g, b, a) -- 21
	if a == nil then -- 21
		a = 255 -- 21
	end -- 21
	return {r = r, g = g, b = b, a = a} -- 22
end -- 21
function ____exports.toColor(c, alphaOverride) -- 25
	local a = alphaOverride ~= nil and math.max( -- 26
		0, -- 26
		math.min( -- 26
			255, -- 26
			math.floor(alphaOverride + 0.5) -- 26
		) -- 26
	) or c.a -- 26
	return Color(c.r, c.g, c.b, a) -- 27
end -- 25
function ____exports.lerpRGBA(a, b, t) -- 30
	local k = math.max( -- 31
		0, -- 31
		math.min(1, t) -- 31
	) -- 31
	return { -- 32
		r = math.floor(a.r + (b.r - a.r) * k + 0.5), -- 33
		g = math.floor(a.g + (b.g - a.g) * k + 0.5), -- 34
		b = math.floor(a.b + (b.b - a.b) * k + 0.5), -- 35
		a = math.floor(a.a + (b.a - a.a) * k + 0.5) -- 36
	} -- 36
end -- 30
--- 通用 ICEY 功能色 Token
____exports.PALETTE = { -- 41
	voidDark = ____exports.rgba(5, 8, 14, 255), -- 42
	panelBg = ____exports.rgba(9, 14, 24, 218), -- 43
	panelBgDeep = ____exports.rgba(6, 10, 18, 238), -- 44
	steelDark = ____exports.rgba(20, 28, 42, 255), -- 45
	steelMid = ____exports.rgba(34, 46, 66, 255), -- 46
	steelLight = ____exports.rgba(68, 86, 114, 255), -- 47
	rimSilver = ____exports.rgba(148, 178, 210, 255), -- 48
	cyanCore = ____exports.rgba(215, 250, 255, 255), -- 51
	cyan = ____exports.rgba(72, 224, 255, 255), -- 52
	cyanDim = ____exports.rgba(32, 128, 168, 255), -- 53
	cyanGlow = ____exports.rgba(56, 210, 255, 110), -- 54
	amberCore = ____exports.rgba(255, 242, 212, 255), -- 57
	amber = ____exports.rgba(242, 188, 96, 255), -- 58
	amberDim = ____exports.rgba(154, 112, 54, 255), -- 59
	amberGlow = ____exports.rgba(246, 196, 108, 100), -- 60
	crimsonCore = ____exports.rgba(255, 206, 214, 255), -- 63
	crimson = ____exports.rgba(255, 48, 82, 255), -- 64
	crimsonDeep = ____exports.rgba(176, 28, 48, 255), -- 65
	crimsonGlow = ____exports.rgba(255, 42, 78, 110), -- 66
	emerald = ____exports.rgba(84, 232, 168, 255), -- 69
	emeraldDim = ____exports.rgba(38, 118, 88, 255), -- 70
	textBright = ____exports.rgba(238, 244, 252, 255), -- 73
	textMid = ____exports.rgba(164, 182, 206, 255), -- 74
	textDim = ____exports.rgba(102, 120, 146, 255), -- 75
	cartWood = ____exports.rgba(82, 54, 44, 255), -- 78
	cartMetal = ____exports.rgba(114, 126, 142, 255), -- 79
	clothRed = ____exports.rgba(216, 40, 56, 255), -- 80
	clothRedHighlight = ____exports.rgba(252, 92, 104, 255) -- 81
} -- 81
____exports.ROOM_THEMES = { -- 113
	prologue = { -- 114
		key = "prologue", -- 115
		actCode = "ACT 01", -- 116
		titleZh = "序章 · 倒柜后", -- 117
		titleEn = "PROLOGUE // BROKEN WARD", -- 118
		lineTag = "SOLDIER LINE", -- 119
		skyTop = ____exports.rgba(5, 8, 16, 255), -- 120
		skyMid = ____exports.rgba(11, 20, 36, 255), -- 121
		skyHorizon = ____exports.rgba(22, 38, 62, 255), -- 122
		farBuilding = ____exports.rgba(11, 18, 30, 255), -- 123
		midBuilding = ____exports.rgba(17, 26, 42, 255), -- 124
		fogBottom = ____exports.rgba(34, 68, 102, 72), -- 125
		groundTop = ____exports.rgba(42, 54, 72, 255), -- 126
		groundBody = ____exports.rgba(15, 21, 32, 255), -- 127
		groundRim = ____exports.rgba(96, 198, 236, 220), -- 128
		accent = ____exports.PALETTE.cyan, -- 129
		beamColor = ____exports.rgba(88, 206, 255, 42), -- 130
		ambient = "ash", -- 131
		showSearchlights = true, -- 132
		showTowerBeacon = false, -- 133
		showMoon = true, -- 134
		moonXFrac = 0.78, -- 135
		moonYFrac = 0.78, -- 136
		defaultZoom = 1.12, -- 137
		introWhisper = "城破前夜。她在倒塌的柜子后面。" -- 138
	}, -- 138
	street = { -- 140
		key = "street", -- 141
		actCode = "ACT 02", -- 142
		titleZh = "街道 · 封锁线", -- 143
		titleEn = "SECTOR 02 // BURNING AVENUE", -- 144
		lineTag = "SOLDIER LINE", -- 145
		skyTop = ____exports.rgba(7, 9, 18, 255), -- 146
		skyMid = ____exports.rgba(16, 22, 38, 255), -- 147
		skyHorizon = ____exports.rgba(36, 34, 54, 255), -- 148
		farBuilding = ____exports.rgba(13, 18, 30, 255), -- 149
		midBuilding = ____exports.rgba(21, 27, 42, 255), -- 150
		fogBottom = ____exports.rgba(68, 56, 84, 74), -- 151
		groundTop = ____exports.rgba(46, 54, 68, 255), -- 152
		groundBody = ____exports.rgba(16, 20, 30, 255), -- 153
		groundRim = ____exports.rgba(102, 194, 232, 215), -- 154
		accent = ____exports.PALETTE.cyan, -- 155
		beamColor = ____exports.rgba(108, 196, 255, 44), -- 156
		ambient = "ash", -- 157
		showSearchlights = true, -- 158
		showTowerBeacon = false, -- 159
		showMoon = true, -- 160
		moonXFrac = 0.82, -- 161
		moonYFrac = 0.8, -- 162
		defaultZoom = 1, -- 163
		introWhisper = "带她穿过街心。别让火力压住她的步子。" -- 164
	}, -- 164
	checkpoint = { -- 166
		key = "checkpoint", -- 167
		actCode = "ACT 03", -- 168
		titleZh = "检查站 · 装卸台", -- 169
		titleEn = "SECTOR 03 // CHECKPOINT DOCK", -- 170
		lineTag = "SOLDIER LINE", -- 171
		skyTop = ____exports.rgba(6, 10, 19, 255), -- 172
		skyMid = ____exports.rgba(13, 23, 40, 255), -- 173
		skyHorizon = ____exports.rgba(26, 44, 68, 255), -- 174
		farBuilding = ____exports.rgba(12, 20, 34, 255), -- 175
		midBuilding = ____exports.rgba(19, 30, 48, 255), -- 176
		fogBottom = ____exports.rgba(40, 86, 122, 68), -- 177
		groundTop = ____exports.rgba(44, 58, 76, 255), -- 178
		groundBody = ____exports.rgba(14, 20, 31, 255), -- 179
		groundRim = ____exports.rgba(86, 218, 252, 230), -- 180
		accent = ____exports.PALETTE.cyan, -- 181
		beamColor = ____exports.rgba(74, 214, 255, 46), -- 182
		ambient = "ash", -- 183
		showSearchlights = true, -- 184
		showTowerBeacon = false, -- 185
		showMoon = true, -- 186
		moonXFrac = 0.74, -- 187
		moonYFrac = 0.82, -- 188
		defaultZoom = 1, -- 189
		introWhisper = "把那辆系着红布的板车推进装卸窝，城门才会放行。" -- 190
	}, -- 190
	gate = { -- 192
		key = "gate", -- 193
		actCode = "ACT 04", -- 194
		titleZh = "城门 · 四十五秒", -- 195
		titleEn = "SECTOR 04 // LAST STAND GATE", -- 196
		lineTag = "SOLDIER LINE", -- 197
		skyTop = ____exports.rgba(11, 7, 14, 255), -- 198
		skyMid = ____exports.rgba(26, 15, 26, 255), -- 199
		skyHorizon = ____exports.rgba(58, 24, 34, 255), -- 200
		farBuilding = ____exports.rgba(18, 13, 22, 255), -- 201
		midBuilding = ____exports.rgba(28, 20, 32, 255), -- 202
		fogBottom = ____exports.rgba(128, 36, 48, 68), -- 203
		groundTop = ____exports.rgba(54, 48, 58, 255), -- 204
		groundBody = ____exports.rgba(18, 15, 24, 255), -- 205
		groundRim = ____exports.rgba(255, 86, 108, 210), -- 206
		accent = ____exports.PALETTE.crimson, -- 207
		beamColor = ____exports.rgba(255, 72, 96, 46), -- 208
		ambient = "ash", -- 209
		showSearchlights = true, -- 210
		showTowerBeacon = false, -- 211
		showMoon = true, -- 212
		moonXFrac = 0.22, -- 213
		moonYFrac = 0.8, -- 214
		defaultZoom = 0.92, -- 215
		introWhisper = "把她送到门洞，守住绞盘四十五秒。" -- 216
	}, -- 216
	outside = { -- 218
		key = "outside", -- 219
		actCode = "ACT 05", -- 220
		titleZh = "城墙外 · 拱与红布", -- 221
		titleEn = "OUTSKIRTS 05 // WALL & ARCHWAY", -- 222
		lineTag = "CHILD LINE", -- 223
		skyTop = ____exports.rgba(5, 9, 18, 255), -- 224
		skyMid = ____exports.rgba(11, 20, 38, 255), -- 225
		skyHorizon = ____exports.rgba(24, 40, 66, 255), -- 226
		farBuilding = ____exports.rgba(10, 17, 30, 255), -- 227
		midBuilding = ____exports.rgba(16, 26, 44, 255), -- 228
		fogBottom = ____exports.rgba(44, 68, 106, 68), -- 229
		groundTop = ____exports.rgba(46, 56, 72, 255), -- 230
		groundBody = ____exports.rgba(14, 19, 30, 255), -- 231
		groundRim = ____exports.rgba(154, 196, 232, 200), -- 232
		accent = ____exports.PALETTE.amber, -- 233
		beamColor = ____exports.rgba(142, 194, 255, 32), -- 234
		ambient = "drizzle", -- 235
		showSearchlights = false, -- 236
		showTowerBeacon = true, -- 237
		showMoon = true, -- 238
		moonXFrac = 0.68, -- 239
		moonYFrac = 0.82, -- 240
		defaultZoom = 0.96, -- 241
		introWhisper = "门后再没有人应声。把板车拉进空窝，蹲着穿过低拱。" -- 242
	}, -- 242
	village = { -- 244
		key = "village", -- 245
		actCode = "ACT 06", -- 246
		titleZh = "废弃村庄 · 砖地一响", -- 247
		titleEn = "OUTSKIRTS 06 // RUINED COURTYARD", -- 248
		lineTag = "CHILD LINE", -- 249
		skyTop = ____exports.rgba(7, 10, 17, 255), -- 250
		skyMid = ____exports.rgba(15, 22, 34, 255), -- 251
		skyHorizon = ____exports.rgba(34, 42, 56, 255), -- 252
		farBuilding = ____exports.rgba(13, 18, 28, 255), -- 253
		midBuilding = ____exports.rgba(22, 28, 40, 255), -- 254
		fogBottom = ____exports.rgba(76, 74, 68, 60), -- 255
		groundTop = ____exports.rgba(54, 56, 62, 255), -- 256
		groundBody = ____exports.rgba(17, 20, 26, 255), -- 257
		groundRim = ____exports.rgba(214, 186, 134, 195), -- 258
		accent = ____exports.PALETTE.amber, -- 259
		beamColor = ____exports.rgba(232, 192, 128, 26), -- 260
		ambient = "drizzle", -- 261
		showSearchlights = false, -- 262
		showTowerBeacon = true, -- 263
		showMoon = true, -- 264
		moonXFrac = 0.78, -- 265
		moonYFrac = 0.82, -- 266
		defaultZoom = 1, -- 267
		introWhisper = "别被拾荒者看见。拾起瓶子扔向砖地，趁他转身钻过桌底。" -- 268
	}, -- 268
	forest = { -- 270
		key = "forest", -- 271
		actCode = "ACT 07", -- 272
		titleZh = "北塔森林 · 听风辨步", -- 273
		titleEn = "OUTSKIRTS 07 // NORTHWOOD", -- 274
		lineTag = "CHILD LINE", -- 275
		skyTop = ____exports.rgba(4, 10, 14, 255), -- 276
		skyMid = ____exports.rgba(9, 24, 30, 255), -- 277
		skyHorizon = ____exports.rgba(20, 48, 54, 255), -- 278
		farBuilding = ____exports.rgba(8, 20, 24, 255), -- 279
		midBuilding = ____exports.rgba(13, 32, 36, 255), -- 280
		fogBottom = ____exports.rgba(42, 112, 118, 68), -- 281
		groundTop = ____exports.rgba(32, 58, 56, 255), -- 282
		groundBody = ____exports.rgba(11, 22, 24, 255), -- 283
		groundRim = ____exports.rgba(112, 214, 186, 205), -- 284
		accent = ____exports.PALETTE.emerald, -- 285
		beamColor = ____exports.rgba(108, 232, 198, 28), -- 286
		ambient = "spores", -- 287
		showSearchlights = false, -- 288
		showTowerBeacon = true, -- 289
		showMoon = true, -- 290
		moonXFrac = 0.72, -- 291
		moonYFrac = 0.84, -- 292
		defaultZoom = 1, -- 293
		introWhisper = "猎犬比人先听见脚步。伏在草影里，向北塔灯火走去。" -- 294
	}, -- 294
	tower = { -- 296
		key = "tower", -- 297
		actCode = "ACT 08", -- 298
		titleZh = "北塔 · 最后一行", -- 299
		titleEn = "EPILOGUE // THE NORTH TOWER", -- 300
		lineTag = "EPILOGUE", -- 301
		skyTop = ____exports.rgba(6, 10, 20, 255), -- 302
		skyMid = ____exports.rgba(16, 26, 46, 255), -- 303
		skyHorizon = ____exports.rgba(46, 54, 72, 255), -- 304
		farBuilding = ____exports.rgba(13, 20, 34, 255), -- 305
		midBuilding = ____exports.rgba(20, 30, 48, 255), -- 306
		fogBottom = ____exports.rgba(232, 184, 110, 56), -- 307
		groundTop = ____exports.rgba(62, 64, 72, 255), -- 308
		groundBody = ____exports.rgba(18, 22, 30, 255), -- 309
		groundRim = ____exports.rgba(246, 206, 134, 230), -- 310
		accent = ____exports.PALETTE.amber, -- 311
		beamColor = ____exports.rgba(255, 216, 146, 46), -- 312
		ambient = "motes", -- 313
		showSearchlights = false, -- 314
		showTowerBeacon = true, -- 315
		showMoon = true, -- 316
		moonXFrac = 0.24, -- 317
		moonYFrac = 0.8, -- 318
		defaultZoom = 1.12, -- 319
		introWhisper = "灯亮着。走到门前，像他教你的那样，敲两下。" -- 320
	} -- 320
} -- 320
function ____exports.themeOf(key) -- 324
	local t = ____exports.ROOM_THEMES[key] -- 325
	return t ~= nil and t or ____exports.ROOM_THEMES.prologue -- 326
end -- 324
--- 顶点渐变四边形（按顺时针/逆时针拆成两个三角形）
function ____exports.fillGradQuad(draw, x0, y0, c00, x1, y1, c10, x2, y2, c11, x3, y3, c01) -- 330
	local p0 = Vec2(x0, y0) -- 337
	local p1 = Vec2(x1, y1) -- 338
	local p2 = Vec2(x2, y2) -- 339
	local p3 = Vec2(x3, y3) -- 340
	draw:drawVertices({ -- 341
		{p0, c00}, -- 342
		{p1, c10}, -- 342
		{p2, c11}, -- 342
		{p0, c00}, -- 343
		{p2, c11}, -- 343
		{p3, c01} -- 343
	}) -- 343
end -- 330
--- 竖直方向线性渐变矩形
function ____exports.fillVGradRect(draw, x, y, w, h, bottomCol, topCol) -- 348
	____exports.fillGradQuad( -- 353
		draw, -- 354
		x, -- 355
		y, -- 355
		bottomCol, -- 355
		x + w, -- 356
		y, -- 356
		bottomCol, -- 356
		x + w, -- 357
		y + h, -- 357
		topCol, -- 357
		x, -- 358
		y + h, -- 358
		topCol -- 358
	) -- 358
end -- 348
--- 水平方向线性渐变矩形
function ____exports.fillHGradRect(draw, x, y, w, h, leftCol, rightCol) -- 363
	____exports.fillGradQuad( -- 368
		draw, -- 369
		x, -- 370
		y, -- 370
		leftCol, -- 370
		x + w, -- 371
		y, -- 371
		rightCol, -- 371
		x + w, -- 372
		y + h, -- 372
		rightCol, -- 372
		x, -- 373
		y + h, -- 373
		leftCol -- 373
	) -- 373
end -- 363
--- 径向柔和光晕（扇形顶点渐变，配合 Additive DrawNode 效果极佳）
function ____exports.fillRadialGlow(draw, cx, cy, rx, ry, innerCol, outerCol, segments) -- 378
	if segments == nil then -- 378
		segments = 18 -- 382
	end -- 382
	if rx <= 0.5 or ry <= 0.5 then -- 382
		return -- 385
	end -- 385
	local center = Vec2(cx, cy) -- 387
	local verts = {} -- 388
	local step = math.pi * 2 / segments -- 389
	local i = 0 -- 390
	do -- 390
		i = 0 -- 391
		while i < segments do -- 391
			local a0 = i * step -- 392
			local a1 = (i + 1) * step -- 393
			verts[#verts + 1] = {center, innerCol} -- 394
			verts[#verts + 1] = { -- 395
				Vec2( -- 395
					cx + math.cos(a0) * rx, -- 395
					cy + math.sin(a0) * ry -- 395
				), -- 395
				outerCol -- 395
			} -- 395
			verts[#verts + 1] = { -- 396
				Vec2( -- 396
					cx + math.cos(a1) * rx, -- 396
					cy + math.sin(a1) * ry -- 396
				), -- 396
				outerCol -- 396
			} -- 396
			i = i + 1 -- 391
		end -- 391
	end -- 391
	draw:drawVertices(verts) -- 398
end -- 378
--- 艾希风格斜切平行四边形填充
function ____exports.fillSkewRect(draw, x, y, w, h, skew, fill, borderW, borderCol) -- 402
	if borderW == nil then -- 402
		borderW = 0 -- 405
	end -- 405
	if w <= 0 or h <= 0 then -- 405
		return -- 408
	end -- 408
	local pts = { -- 410
		Vec2(x, y), -- 411
		Vec2(x + w, y), -- 412
		Vec2(x + w + skew, y + h), -- 413
		Vec2(x + skew, y + h) -- 414
	} -- 414
	if borderW > 0 and borderCol ~= nil then -- 414
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 417
	else -- 417
		draw:drawPolygon(pts, fill) -- 419
	end -- 419
end -- 402
--- 艾希风格倒角切边矩形（左上、右下 45° 切角）
function ____exports.fillChamferBox(draw, x, y, w, h, cut, fill, borderW, borderCol) -- 424
	if borderW == nil then -- 424
		borderW = 0 -- 427
	end -- 427
	local c = math.min(cut, w * 0.3, h * 0.3) -- 429
	local pts = { -- 430
		Vec2(x, y), -- 431
		Vec2(x + w - c, y), -- 432
		Vec2(x + w, y + c), -- 433
		Vec2(x + w, y + h), -- 434
		Vec2(x + c, y + h), -- 435
		Vec2(x, y + h - c) -- 436
	} -- 436
	if borderW > 0 and borderCol ~= nil then -- 436
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 439
	else -- 439
		draw:drawPolygon(pts, fill) -- 441
	end -- 441
end -- 424
--- 菱形标（用于锁定点、节点、恐惧晶格、按键标）
function ____exports.drawDiamond(draw, cx, cy, rx, ry, fill, borderW, borderCol) -- 446
	if borderW == nil then -- 446
		borderW = 0 -- 449
	end -- 449
	local pts = { -- 451
		Vec2(cx, cy + ry), -- 452
		Vec2(cx + rx, cy), -- 453
		Vec2(cx, cy - ry), -- 454
		Vec2(cx - rx, cy) -- 455
	} -- 455
	if borderW > 0 and borderCol ~= nil then -- 455
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 458
	else -- 458
		draw:drawPolygon(pts, fill) -- 460
	end -- 460
end -- 446
--- 估算 UTF-8 中英文混排字符串的视觉像素宽度（Lua 的 string.length 返回字节数，1 个汉字占 3 字节）。
function ____exports.visualTextWidth(text, fontSize) -- 467
	local units = 0 -- 468
	local i = 0 -- 469
	do -- 469
		i = 0 -- 470
		while i < #text do -- 470
			local b = __TS__StringCharCodeAt(text, i) -- 471
			if b < 128 then -- 471
				units = units + 0.56 -- 473
			elseif b >= 192 then -- 473
				units = units + 1.02 -- 475
			end -- 475
			i = i + 1 -- 470
		end -- 470
	end -- 470
	return units * fontSize -- 478
end -- 467
--- 工业警示斜纹条（用于掩体、城门、装卸台）
function ____exports.drawHazardStripes(draw, x, y, w, h, pitch, col) -- 482
	local sw = pitch * 0.45 -- 487
	local cur = x - h -- 488
	while cur < x + w do -- 488
		local x0 = math.max(x, cur) -- 490
		local x1 = math.min(x + w, cur + sw) -- 491
		local tx0 = math.max(x, cur + h) -- 492
		local tx1 = math.min(x + w, cur + h + sw) -- 493
		if x1 > x0 and tx1 > tx0 then -- 493
			draw:drawPolygon( -- 495
				{ -- 495
					Vec2(x0, y), -- 496
					Vec2(x1, y), -- 497
					Vec2(tx1, y + h), -- 498
					Vec2(tx0, y + h) -- 499
				}, -- 499
				col -- 500
			) -- 500
		end -- 500
		cur = cur + pitch -- 502
	end -- 502
end -- 482
return ____exports -- 482