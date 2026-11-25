-- [ts]: theme.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Rect = ____Dora.Rect -- 8
local Vec2 = ____Dora.Vec2 -- 8
function ____exports.drawDiamond(draw, cx, cy, rx, ry, fill, borderW, borderCol) -- 687
	if borderW == nil then -- 687
		borderW = 0 -- 690
	end -- 690
	local pts = { -- 692
		Vec2(cx, cy + ry), -- 693
		Vec2(cx + rx, cy), -- 694
		Vec2(cx, cy - ry), -- 695
		Vec2(cx - rx, cy) -- 696
	} -- 696
	if borderW > 0 and borderCol ~= nil then -- 696
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 699
	else -- 699
		draw:drawPolygon(pts, fill) -- 701
	end -- 701
end -- 687
function ____exports.rgba(r, g, b, a) -- 19
	if a == nil then -- 19
		a = 255 -- 19
	end -- 19
	return {r = r, g = g, b = b, a = a} -- 20
end -- 19
function ____exports.toColor(c, alphaOverride) -- 23
	local a = alphaOverride ~= nil and math.max( -- 24
		0, -- 24
		math.min( -- 24
			255, -- 24
			math.floor(alphaOverride + 0.5) -- 24
		) -- 24
	) or c.a -- 24
	return Color(c.r, c.g, c.b, a) -- 25
end -- 23
function ____exports.lerpRGBA(a, b, t) -- 28
	local k = math.max( -- 29
		0, -- 29
		math.min(1, t) -- 29
	) -- 29
	return { -- 30
		r = math.floor(a.r + (b.r - a.r) * k + 0.5), -- 31
		g = math.floor(a.g + (b.g - a.g) * k + 0.5), -- 32
		b = math.floor(a.b + (b.b - a.b) * k + 0.5), -- 33
		a = math.floor(a.a + (b.a - a.a) * k + 0.5) -- 34
	} -- 34
end -- 28
--- 宋明清雅色板（彻底剔除浊土黄，保持鸦青冷月与清丽胭脂的高级克制对比）
____exports.PALETTE = { -- 39
	voidDark = ____exports.rgba(11, 13, 19, 255), -- 41
	panelBg = ____exports.rgba(16, 19, 27, 218), -- 42
	panelBgDeep = ____exports.rgba(12, 14, 21, 236), -- 43
	steelDark = ____exports.rgba(26, 30, 39, 255), -- 44
	steelMid = ____exports.rgba(44, 50, 62, 255), -- 45
	steelLight = ____exports.rgba(102, 112, 124, 255), -- 46
	rimSilver = ____exports.rgba(176, 184, 192, 255), -- 47
	cyanCore = ____exports.rgba(235, 238, 236, 255), -- 50
	cyan = ____exports.rgba(154, 178, 188, 255), -- 51
	cyanDim = ____exports.rgba(94, 112, 124, 255), -- 52
	cyanGlow = ____exports.rgba(154, 178, 188, 64), -- 53
	amberCore = ____exports.rgba(244, 234, 214, 255), -- 56
	amber = ____exports.rgba(214, 186, 146, 255), -- 57
	amberDim = ____exports.rgba(132, 118, 102, 255), -- 58
	amberGlow = ____exports.rgba(214, 186, 146, 60), -- 59
	crimsonCore = ____exports.rgba(246, 208, 200, 255), -- 62
	crimson = ____exports.rgba(188, 68, 64, 255), -- 63
	crimsonDeep = ____exports.rgba(124, 38, 42, 255), -- 64
	crimsonGlow = ____exports.rgba(188, 68, 64, 62), -- 65
	emerald = ____exports.rgba(152, 178, 152, 255), -- 68
	emeraldDim = ____exports.rgba(92, 118, 102, 255), -- 69
	textBright = ____exports.rgba(244, 242, 236, 255), -- 72
	textMid = ____exports.rgba(208, 210, 212, 255), -- 73
	textDim = ____exports.rgba(164, 170, 178, 255), -- 74
	inkVoid = ____exports.rgba(10, 12, 18, 255), -- 77
	inkWash = ____exports.rgba(14, 17, 25, 255), -- 78
	inkMist = ____exports.rgba(28, 34, 46, 255), -- 79
	inkWarm = ____exports.rgba(34, 22, 27, 255), -- 80
	silkLine = ____exports.rgba(196, 202, 208, 255), -- 81
	silkDim = ____exports.rgba(118, 126, 138, 255), -- 82
	jadeMist = ____exports.rgba(164, 184, 190, 255), -- 83
	rouge = ____exports.rgba(182, 58, 56, 255), -- 84
	rougeSoft = ____exports.rgba(148, 46, 48, 255), -- 85
	xuanWarm = ____exports.rgba(232, 226, 214, 255), -- 86
	xuanInk = ____exports.rgba(32, 30, 32, 255), -- 87
	xuanInkSub = ____exports.rgba(92, 86, 82, 255), -- 88
	xuanPaper = ____exports.rgba(232, 227, 216, 255), -- 89
	sealRed = ____exports.rgba(168, 46, 44, 255), -- 90
	sealRedBright = ____exports.rgba(198, 64, 60, 255), -- 91
	sealText = ____exports.rgba(248, 244, 236, 255), -- 92
	cinnabar = ____exports.rgba(182, 58, 56, 255), -- 93
	cinnabarDeep = ____exports.rgba(116, 36, 40, 255), -- 94
	bronzeLine = ____exports.rgba(178, 184, 192, 255), -- 95
	bronzeDim = ____exports.rgba(114, 122, 134, 255), -- 96
	moonPale = ____exports.rgba(232, 236, 234, 255), -- 97
	cartWood = ____exports.rgba(104, 73, 55, 255), -- 100
	cartMetal = ____exports.rgba(125, 110, 97, 255), -- 101
	clothRed = ____exports.rgba(168, 52, 48, 255), -- 102
	clothRedHighlight = ____exports.rgba(210, 90, 78, 255) -- 103
} -- 103
____exports.ROOM_THEMES = { -- 138
	prologue = { -- 139
		key = "prologue", -- 140
		numeralZh = "壹", -- 141
		actCode = "第壹章", -- 142
		titleZh = "序章 · 倒柜后", -- 143
		shortNameZh = "倒柜后", -- 144
		titleEn = "孤城护童", -- 145
		lineTag = "周戍", -- 146
		volumeTagZh = "上卷 · 孤城护童", -- 147
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 148
		skyMid = ____exports.rgba(16, 22, 34, 255), -- 149
		skyHorizon = ____exports.rgba(28, 38, 54, 255), -- 150
		farBuilding = ____exports.rgba(14, 18, 28, 255), -- 151
		midBuilding = ____exports.rgba(22, 26, 38, 255), -- 152
		fogBottom = ____exports.rgba(44, 58, 78, 62), -- 153
		groundTop = ____exports.rgba(46, 52, 62, 255), -- 154
		groundBody = ____exports.rgba(17, 20, 28, 255), -- 155
		groundRim = ____exports.rgba(154, 178, 188, 195), -- 156
		accent = ____exports.PALETTE.cyan, -- 157
		beamColor = ____exports.rgba(140, 168, 184, 34), -- 158
		ambient = "ash", -- 159
		showSearchlights = true, -- 160
		showTowerBeacon = false, -- 161
		showMoon = true, -- 162
		moonXFrac = 0.78, -- 163
		moonYFrac = 0.78, -- 164
		defaultZoom = 1.12, -- 165
		introWhisper = "城破前夜，月光斜漏旧仓。她在倒塌的柜子后面。" -- 166
	}, -- 166
	street = { -- 168
		key = "street", -- 169
		numeralZh = "贰", -- 170
		actCode = "第贰章", -- 171
		titleZh = "街道 · 封锁线", -- 172
		shortNameZh = "封锁线", -- 173
		titleEn = "孤城护童", -- 174
		lineTag = "周戍", -- 175
		volumeTagZh = "上卷 · 孤城护童", -- 176
		skyTop = ____exports.rgba(10, 12, 20, 255), -- 177
		skyMid = ____exports.rgba(20, 24, 36, 255), -- 178
		skyHorizon = ____exports.rgba(38, 36, 48, 255), -- 179
		farBuilding = ____exports.rgba(16, 19, 28, 255), -- 180
		midBuilding = ____exports.rgba(24, 27, 38, 255), -- 181
		fogBottom = ____exports.rgba(66, 54, 68, 64), -- 182
		groundTop = ____exports.rgba(48, 52, 60, 255), -- 183
		groundBody = ____exports.rgba(18, 20, 28, 255), -- 184
		groundRim = ____exports.rgba(154, 178, 188, 190), -- 185
		accent = ____exports.PALETTE.cyan, -- 186
		beamColor = ____exports.rgba(148, 170, 184, 34), -- 187
		ambient = "ash", -- 188
		showSearchlights = true, -- 189
		showTowerBeacon = false, -- 190
		showMoon = true, -- 191
		moonXFrac = 0.82, -- 192
		moonYFrac = 0.8, -- 193
		defaultZoom = 1, -- 194
		introWhisper = "夜雾漫过长街，带她穿过火线，莫让枪声压住她的步子。" -- 195
	}, -- 195
	checkpoint = { -- 197
		key = "checkpoint", -- 198
		numeralZh = "叁", -- 199
		actCode = "第叁章", -- 200
		titleZh = "检查站 · 装卸台", -- 201
		shortNameZh = "装卸台", -- 202
		titleEn = "孤城护童", -- 203
		lineTag = "周戍", -- 204
		volumeTagZh = "上卷 · 孤城护童", -- 205
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 206
		skyMid = ____exports.rgba(18, 25, 38, 255), -- 207
		skyHorizon = ____exports.rgba(32, 44, 60, 255), -- 208
		farBuilding = ____exports.rgba(15, 21, 32, 255), -- 209
		midBuilding = ____exports.rgba(22, 30, 42, 255), -- 210
		fogBottom = ____exports.rgba(48, 68, 86, 58), -- 211
		groundTop = ____exports.rgba(46, 54, 64, 255), -- 212
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 213
		groundRim = ____exports.rgba(154, 178, 188, 200), -- 214
		accent = ____exports.PALETTE.cyan, -- 215
		beamColor = ____exports.rgba(140, 172, 188, 36), -- 216
		ambient = "ash", -- 217
		showSearchlights = true, -- 218
		showTowerBeacon = false, -- 219
		showMoon = true, -- 220
		moonXFrac = 0.74, -- 221
		moonYFrac = 0.82, -- 222
		defaultZoom = 1, -- 223
		introWhisper = "红布在夜风里轻晃，把板车推进装卸窝，城门才会放行。" -- 224
	}, -- 224
	gate = { -- 226
		key = "gate", -- 227
		numeralZh = "肆", -- 228
		actCode = "第肆章", -- 229
		titleZh = "城门 · 四十五秒", -- 230
		shortNameZh = "四十五秒", -- 231
		titleEn = "死守断后", -- 232
		lineTag = "周戍", -- 233
		volumeTagZh = "上卷 · 孤城护童", -- 234
		skyTop = ____exports.rgba(14, 10, 14, 255), -- 235
		skyMid = ____exports.rgba(28, 17, 22, 255), -- 236
		skyHorizon = ____exports.rgba(56, 28, 30, 255), -- 237
		farBuilding = ____exports.rgba(20, 15, 20, 255), -- 238
		midBuilding = ____exports.rgba(30, 21, 26, 255), -- 239
		fogBottom = ____exports.rgba(118, 42, 42, 62), -- 240
		groundTop = ____exports.rgba(54, 48, 52, 255), -- 241
		groundBody = ____exports.rgba(18, 16, 21, 255), -- 242
		groundRim = ____exports.rgba(188, 68, 64, 195), -- 243
		accent = ____exports.PALETTE.rouge, -- 244
		beamColor = ____exports.rgba(196, 76, 62, 38), -- 245
		ambient = "ash", -- 246
		showSearchlights = true, -- 247
		showTowerBeacon = false, -- 248
		showMoon = true, -- 249
		moonXFrac = 0.22, -- 250
		moonYFrac = 0.8, -- 251
		defaultZoom = 0.92, -- 252
		introWhisper = "把她送到门洞，自己留下来，守住绞盘最后的四十五秒。" -- 253
	}, -- 253
	outside = { -- 255
		key = "outside", -- 256
		numeralZh = "伍", -- 257
		actCode = "第伍章", -- 258
		titleZh = "城墙外 · 拱与红布", -- 259
		shortNameZh = "拱与红布", -- 260
		titleEn = "独赴北塔", -- 261
		lineTag = "小满", -- 262
		volumeTagZh = "下卷 · 独赴北塔", -- 263
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 264
		skyMid = ____exports.rgba(16, 24, 38, 255), -- 265
		skyHorizon = ____exports.rgba(30, 42, 60, 255), -- 266
		farBuilding = ____exports.rgba(14, 19, 30, 255), -- 267
		midBuilding = ____exports.rgba(20, 28, 42, 255), -- 268
		fogBottom = ____exports.rgba(48, 64, 88, 58), -- 269
		groundTop = ____exports.rgba(48, 54, 64, 255), -- 270
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 271
		groundRim = ____exports.rgba(184, 176, 162, 185), -- 272
		accent = ____exports.PALETTE.amber, -- 273
		beamColor = ____exports.rgba(176, 166, 146, 28), -- 274
		ambient = "drizzle", -- 275
		showSearchlights = false, -- 276
		showTowerBeacon = true, -- 277
		showMoon = true, -- 278
		moonXFrac = 0.68, -- 279
		moonYFrac = 0.82, -- 280
		defaultZoom = 0.96, -- 281
		introWhisper = "数到二十，门后再无应声。拉开车辙，伏身穿过石拱。" -- 282
	}, -- 282
	village = { -- 284
		key = "village", -- 285
		numeralZh = "陆", -- 286
		actCode = "第陆章", -- 287
		titleZh = "废弃村庄 · 砖地一响", -- 288
		shortNameZh = "砖地一响", -- 289
		titleEn = "独赴北塔", -- 290
		lineTag = "小满", -- 291
		volumeTagZh = "下卷 · 独赴北塔", -- 292
		skyTop = ____exports.rgba(10, 12, 18, 255), -- 293
		skyMid = ____exports.rgba(18, 23, 33, 255), -- 294
		skyHorizon = ____exports.rgba(36, 40, 50, 255), -- 295
		farBuilding = ____exports.rgba(15, 19, 26, 255), -- 296
		midBuilding = ____exports.rgba(24, 28, 36, 255), -- 297
		fogBottom = ____exports.rgba(74, 68, 60, 54), -- 298
		groundTop = ____exports.rgba(54, 54, 58, 255), -- 299
		groundBody = ____exports.rgba(18, 20, 25, 255), -- 300
		groundRim = ____exports.rgba(202, 184, 152, 185), -- 301
		accent = ____exports.PALETTE.amber, -- 302
		beamColor = ____exports.rgba(212, 174, 118, 24), -- 303
		ambient = "drizzle", -- 304
		showSearchlights = false, -- 305
		showTowerBeacon = true, -- 306
		showMoon = true, -- 307
		moonXFrac = 0.78, -- 308
		moonYFrac = 0.82, -- 309
		defaultZoom = 1, -- 310
		introWhisper = "残垣旧院里有拾荒者游荡。掷瓶引响，趁隙潜过案底。" -- 311
	}, -- 311
	forest = { -- 313
		key = "forest", -- 314
		numeralZh = "柒", -- 315
		actCode = "第柒章", -- 316
		titleZh = "北塔森林 · 听风辨步", -- 317
		shortNameZh = "听风辨步", -- 318
		titleEn = "独赴北塔", -- 319
		lineTag = "小满", -- 320
		volumeTagZh = "下卷 · 独赴北塔", -- 321
		skyTop = ____exports.rgba(8, 12, 16, 255), -- 322
		skyMid = ____exports.rgba(14, 24, 28, 255), -- 323
		skyHorizon = ____exports.rgba(26, 44, 46, 255), -- 324
		farBuilding = ____exports.rgba(12, 20, 24, 255), -- 325
		midBuilding = ____exports.rgba(18, 30, 32, 255), -- 326
		fogBottom = ____exports.rgba(52, 86, 82, 56), -- 327
		groundTop = ____exports.rgba(36, 52, 48, 255), -- 328
		groundBody = ____exports.rgba(14, 22, 22, 255), -- 329
		groundRim = ____exports.rgba(152, 178, 152, 190), -- 330
		accent = ____exports.PALETTE.emerald, -- 331
		beamColor = ____exports.rgba(148, 178, 146, 24), -- 332
		ambient = "spores", -- 333
		showSearchlights = false, -- 334
		showTowerBeacon = true, -- 335
		showMoon = true, -- 336
		moonXFrac = 0.72, -- 337
		moonYFrac = 0.84, -- 338
		defaultZoom = 1, -- 339
		introWhisper = "松涛起落，猎犬先人闻步。屏息伏于草影，向北塔行去。" -- 340
	}, -- 340
	tower = { -- 342
		key = "tower", -- 343
		numeralZh = "捌", -- 344
		actCode = "终章", -- 345
		titleZh = "北塔 · 最后一行", -- 346
		shortNameZh = "最后一行", -- 347
		titleEn = "归途尾声", -- 348
		lineTag = "尾声", -- 349
		volumeTagZh = "终章 · 北塔守望", -- 350
		skyTop = ____exports.rgba(10, 13, 21, 255), -- 351
		skyMid = ____exports.rgba(20, 28, 44, 255), -- 352
		skyHorizon = ____exports.rgba(48, 52, 66, 255), -- 353
		farBuilding = ____exports.rgba(16, 21, 32, 255), -- 354
		midBuilding = ____exports.rgba(24, 30, 44, 255), -- 355
		fogBottom = ____exports.rgba(214, 186, 146, 44), -- 356
		groundTop = ____exports.rgba(60, 60, 66, 255), -- 357
		groundBody = ____exports.rgba(19, 21, 28, 255), -- 358
		groundRim = ____exports.rgba(232, 214, 182, 210), -- 359
		accent = ____exports.PALETTE.amber, -- 360
		beamColor = ____exports.rgba(236, 198, 132, 40), -- 361
		ambient = "motes", -- 362
		showSearchlights = false, -- 363
		showTowerBeacon = true, -- 364
		showMoon = true, -- 365
		moonXFrac = 0.24, -- 366
		moonYFrac = 0.8, -- 367
		defaultZoom = 1.12, -- 368
		introWhisper = "孤灯犹明。走到北塔门前，照他教过的节奏，轻敲两下。" -- 369
	} -- 369
} -- 369
function ____exports.themeOf(key) -- 373
	local t = ____exports.ROOM_THEMES[key] -- 374
	return t ~= nil and t or ____exports.ROOM_THEMES.prologue -- 375
end -- 373
local UPPER_DIGITS = { -- 378
	"零", -- 378
	"壹", -- 378
	"贰", -- 378
	"叁", -- 378
	"肆", -- 378
	"伍", -- 378
	"陆", -- 378
	"柒", -- 378
	"捌", -- 378
	"玖" -- 378
} -- 378
--- 将 0..100 整数转为传统中文大写数字（零、壹..拾、拾壹..玖拾玖、壹佰）
function ____exports.toChineseUpper(n) -- 381
	local v = math.max( -- 382
		0, -- 382
		math.min( -- 382
			100, -- 382
			math.floor(n) -- 382
		) -- 382
	) -- 382
	if v == 100 then -- 382
		return "壹佰" -- 384
	end -- 384
	if v < 10 then -- 384
		return UPPER_DIGITS[v + 1] -- 387
	end -- 387
	local tens = math.floor(v / 10) -- 389
	local ones = v % 10 -- 390
	local prefix = tens == 1 and "拾" or UPPER_DIGITS[tens + 1] .. "拾" -- 391
	return ones == 0 and prefix or prefix .. UPPER_DIGITS[ones + 1] -- 392
end -- 381
--- 顶点渐变四边形
function ____exports.fillGradQuad(draw, x0, y0, c00, x1, y1, c10, x2, y2, c11, x3, y3, c01) -- 396
	local p0 = Vec2(x0, y0) -- 403
	local p1 = Vec2(x1, y1) -- 404
	local p2 = Vec2(x2, y2) -- 405
	local p3 = Vec2(x3, y3) -- 406
	draw:drawVertices({ -- 407
		{p0, c00}, -- 408
		{p1, c10}, -- 408
		{p2, c11}, -- 408
		{p0, c00}, -- 409
		{p2, c11}, -- 409
		{p3, c01} -- 409
	}) -- 409
end -- 396
--- 竖直方向线性渐变矩形
function ____exports.fillVGradRect(draw, x, y, w, h, bottomCol, topCol) -- 414
	____exports.fillGradQuad( -- 419
		draw, -- 420
		x, -- 421
		y, -- 421
		bottomCol, -- 421
		x + w, -- 422
		y, -- 422
		bottomCol, -- 422
		x + w, -- 423
		y + h, -- 423
		topCol, -- 423
		x, -- 424
		y + h, -- 424
		topCol -- 424
	) -- 424
end -- 414
--- 水平方向线性渐变矩形
function ____exports.fillHGradRect(draw, x, y, w, h, leftCol, rightCol) -- 429
	____exports.fillGradQuad( -- 434
		draw, -- 435
		x, -- 436
		y, -- 436
		leftCol, -- 436
		x + w, -- 437
		y, -- 437
		rightCol, -- 437
		x + w, -- 438
		y + h, -- 438
		rightCol, -- 438
		x, -- 439
		y + h, -- 439
		leftCol -- 439
	) -- 439
end -- 429
--- 径向柔和光晕
function ____exports.fillRadialGlow(draw, cx, cy, rx, ry, innerCol, outerCol, segments) -- 444
	if segments == nil then -- 444
		segments = 18 -- 448
	end -- 448
	if rx <= 0.5 or ry <= 0.5 then -- 448
		return -- 451
	end -- 451
	local center = Vec2(cx, cy) -- 453
	local verts = {} -- 454
	local step = math.pi * 2 / segments -- 455
	local i = 0 -- 456
	do -- 456
		i = 0 -- 457
		while i < segments do -- 457
			local a0 = i * step -- 458
			local a1 = (i + 1) * step -- 459
			verts[#verts + 1] = {center, innerCol} -- 460
			verts[#verts + 1] = { -- 461
				Vec2( -- 461
					cx + math.cos(a0) * rx, -- 461
					cy + math.sin(a0) * ry -- 461
				), -- 461
				outerCol -- 461
			} -- 461
			verts[#verts + 1] = { -- 462
				Vec2( -- 462
					cx + math.cos(a1) * rx, -- 462
					cy + math.sin(a1) * ry -- 462
				), -- 462
				outerCol -- 462
			} -- 462
			i = i + 1 -- 457
		end -- 457
	end -- 457
	draw:drawVertices(verts) -- 464
end -- 444
--- 烟黛渐变轻幕（《饿殍》柔边字幕幕 / 顶部轻带，四周自然消融无硬框）
function ____exports.drawSilkVeil(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 470
	if opacity == nil then -- 470
		opacity = 0.84 -- 475
	end -- 475
	if layer == nil then -- 475
		layer = -1 -- 476
	end -- 476
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 476
		return -- 479
	end -- 479
	if art:tryPlace( -- 479
		"ink_veil_strip", -- 481
		id, -- 481
		cx, -- 481
		cy, -- 481
		w, -- 481
		h, -- 481
		{ -- 481
			color = ____exports.toColor(tint, 255), -- 481
			opacity = opacity, -- 481
			layer = layer -- 481
		} -- 481
	) then -- 481
		return -- 482
	end -- 482
	local x = cx - w * 0.5 -- 484
	local y = cy - h * 0.5 -- 485
	local fadeW = w * 0.22 -- 486
	local midCol = ____exports.toColor( -- 487
		tint, -- 487
		math.floor(225 * opacity + 0.5) -- 487
	) -- 487
	local zeroCol = Color(tint.r, tint.g, tint.b, 0) -- 488
	____exports.fillHGradRect( -- 489
		fallbackDraw, -- 489
		x, -- 489
		y, -- 489
		fadeW, -- 489
		h, -- 489
		zeroCol, -- 489
		midCol -- 489
	) -- 489
	fallbackDraw:drawRect( -- 490
		Rect( -- 490
			x + fadeW, -- 490
			y, -- 490
			math.max(0, w - fadeW * 2), -- 490
			h -- 490
		), -- 490
		midCol -- 490
	) -- 490
	____exports.fillHGradRect( -- 491
		fallbackDraw, -- 491
		x + w - fadeW, -- 491
		y, -- 491
		fadeW, -- 491
		h, -- 491
		midCol, -- 491
		zeroCol -- 491
	) -- 491
end -- 470
--- 水袖游丝飞白飘带（用于菜单选中态轻拂高光，柔美弧线非粗重墨块）
function ____exports.drawSilkRibbon(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 497
	if opacity == nil then -- 497
		opacity = 0.65 -- 502
	end -- 502
	if layer == nil then -- 502
		layer = 0 -- 503
	end -- 503
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 503
		return -- 506
	end -- 506
	if art:tryPlace( -- 506
		"ink_ribbon_sweep", -- 508
		id, -- 508
		cx, -- 508
		cy, -- 508
		w, -- 508
		h, -- 508
		{ -- 508
			color = ____exports.toColor(tint, 255), -- 508
			opacity = opacity, -- 508
			layer = layer -- 508
		} -- 508
	) then -- 508
		return -- 509
	end -- 509
	local x = cx - w * 0.5 -- 511
	local y = cy - h * 0.5 -- 512
	____exports.fillHGradRect( -- 513
		fallbackDraw, -- 513
		x, -- 513
		y, -- 513
		w * 0.65, -- 513
		h, -- 513
		____exports.toColor( -- 513
			tint, -- 513
			math.floor(160 * opacity + 0.5) -- 513
		), -- 513
		Color(tint.r, tint.g, tint.b, 0) -- 513
	) -- 513
end -- 497
--- 婉转烟岚流云曲线（赋予标题、驿道长卷、章名以轻盈流动感）
function ____exports.drawMistCurve(art, id, cx, cy, w, h, tint, opacity, layer, facing) -- 519
	if opacity == nil then -- 519
		opacity = 0.36 -- 523
	end -- 523
	if layer == nil then -- 523
		layer = -1 -- 524
	end -- 524
	if facing == nil then -- 524
		facing = 1 -- 525
	end -- 525
	if w <= 4 or h <= 4 or opacity <= 0.01 then -- 525
		return -- 528
	end -- 528
	art:tryPlace( -- 530
		"ink_mist_curve", -- 530
		id, -- 530
		cx, -- 530
		cy, -- 530
		w, -- 530
		h, -- 530
		{ -- 530
			color = ____exports.toColor(tint, 255), -- 530
			opacity = opacity, -- 530
			layer = layer, -- 530
			facing = facing -- 530
		} -- 530
	) -- 530
end -- 519
--- 霜月游丝细线（可选在中点缀一枚极精巧的宋明海棠菱花微结）
function ____exports.drawHairline(overlayDraw, art, id, cx, cy, w, col, alpha, withKnot, layer) -- 536
	if alpha == nil then -- 536
		alpha = 0.72 -- 541
	end -- 541
	if withKnot == nil then -- 541
		withKnot = false -- 542
	end -- 542
	if layer == nil then -- 542
		layer = 2 -- 543
	end -- 543
	if w <= 4 or alpha <= 0.01 then -- 543
		return -- 546
	end -- 546
	if not art:tryPlace( -- 546
		"ink_hairline", -- 548
		id, -- 548
		cx, -- 548
		cy, -- 548
		w, -- 548
		10, -- 548
		{ -- 548
			color = ____exports.toColor(col, 255), -- 548
			opacity = alpha, -- 548
			layer = layer -- 548
		} -- 548
	) then -- 548
		local half = w * 0.5 -- 549
		____exports.fillHGradRect( -- 550
			overlayDraw, -- 550
			cx - half, -- 550
			cy - 0.5, -- 550
			half, -- 550
			1, -- 550
			Color(col.r, col.g, col.b, 0), -- 550
			____exports.toColor(col, 190 * alpha) -- 550
		) -- 550
		____exports.fillHGradRect( -- 551
			overlayDraw, -- 551
			cx, -- 551
			cy - 0.5, -- 551
			half, -- 551
			1, -- 551
			____exports.toColor(col, 190 * alpha), -- 551
			Color(col.r, col.g, col.b, 0) -- 551
		) -- 551
	end -- 551
	if withKnot then -- 551
		art:tryPlace( -- 554
			"ink_knot_ornament", -- 554
			id .. "_knot", -- 554
			cx, -- 554
			cy, -- 554
			88, -- 554
			24, -- 554
			{ -- 554
				color = ____exports.toColor(col, 255), -- 554
				opacity = math.min(1, alpha * 1.15), -- 554
				layer = layer + 1 -- 554
			} -- 554
		) -- 554
	end -- 554
end -- 536
--- 宋明纤细海棠折角（取代笨重双线铁框与像素铜角，带留白呼吸感）
function ____exports.drawFiligreeCorners(overlayDraw, art, id, x, y, w, h, col, alpha, cornerSize, withHairBorder, layer) -- 561
	if alpha == nil then -- 561
		alpha = 0.78 -- 566
	end -- 566
	if cornerSize == nil then -- 566
		cornerSize = 34 -- 567
	end -- 567
	if withHairBorder == nil then -- 567
		withHairBorder = true -- 568
	end -- 568
	if layer == nil then -- 568
		layer = 2 -- 569
	end -- 569
	if alpha <= 0.01 then -- 569
		return -- 572
	end -- 572
	if withHairBorder then -- 572
		overlayDraw:drawRect( -- 575
			Rect(x, y, w, h), -- 575
			Color(0, 0, 0, 0), -- 575
			0.75, -- 575
			____exports.toColor(col, 78 * alpha) -- 575
		) -- 575
	end -- 575
	local half = cornerSize * 0.5 -- 577
	local c = ____exports.toColor(col, 255) -- 578
	local op = alpha -- 579
	art:tryPlace( -- 580
		"ink_corner_fine", -- 580
		id .. "_tl", -- 580
		x + half - 2, -- 580
		y + h - half + 2, -- 580
		cornerSize, -- 580
		cornerSize, -- 580
		{color = c, opacity = op, layer = layer} -- 580
	) -- 580
	art:tryPlace( -- 581
		"ink_corner_fine", -- 581
		id .. "_tr", -- 581
		x + w - half + 2, -- 581
		y + h - half + 2, -- 581
		cornerSize, -- 581
		cornerSize, -- 581
		{facing = -1, color = c, opacity = op, layer = layer} -- 581
	) -- 581
	art:tryPlace( -- 582
		"ink_corner_fine", -- 582
		id .. "_bl", -- 582
		x + half - 2, -- 582
		y + half - 2, -- 582
		cornerSize, -- 582
		cornerSize, -- 582
		{flipY = true, color = c, opacity = op, layer = layer} -- 582
	) -- 582
	art:tryPlace( -- 583
		"ink_corner_fine", -- 583
		id .. "_br", -- 583
		x + w - half + 2, -- 583
		y + half - 2, -- 583
		cornerSize, -- 583
		cornerSize, -- 583
		{ -- 583
			facing = -1, -- 583
			flipY = true, -- 583
			color = c, -- 583
			opacity = op, -- 583
			layer = layer -- 583
		} -- 583
	) -- 583
end -- 561
--- 文人孤印（全屏仅用于主标题落款与北塔登记簿落款，清瘦精致不泛滥）
function ____exports.drawLoneSeal(overlayDraw, art, texts, id, cx, cy, w, h, topChar, botChar, stampCol, textCol, alpha, layer) -- 589
	if alpha == nil then -- 589
		alpha = 0.94 -- 597
	end -- 597
	if layer == nil then -- 597
		layer = 4 -- 598
	end -- 598
	if alpha <= 0.01 then -- 598
		return -- 601
	end -- 601
	if not art:tryPlace( -- 601
		"ink_seal_slender", -- 603
		id, -- 603
		cx, -- 603
		cy, -- 603
		w, -- 603
		h, -- 603
		{ -- 603
			color = ____exports.toColor(stampCol, 255), -- 603
			opacity = alpha, -- 603
			layer = layer -- 603
		} -- 603
	) then -- 603
		overlayDraw:drawRect( -- 604
			Rect(cx - w * 0.42, cy - h * 0.44, w * 0.84, h * 0.88), -- 604
			____exports.toColor(stampCol, 225 * alpha) -- 604
		) -- 604
	end -- 604
	texts:put( -- 606
		"seal", -- 606
		topChar, -- 606
		cx, -- 606
		cy + h * 0.17, -- 606
		____exports.toColor(textCol), -- 606
		0.5, -- 606
		0.5, -- 606
		"Center", -- 606
		0, -- 606
		alpha, -- 606
		0 -- 606
	) -- 606
	texts:put( -- 607
		"seal", -- 607
		botChar, -- 607
		cx, -- 607
		cy - h * 0.18, -- 607
		____exports.toColor(textCol), -- 607
		0.5, -- 607
		0.5, -- 607
		"Center", -- 607
		0, -- 607
		alpha, -- 607
		0 -- 607
	) -- 607
end -- 589
--- 纤巧菱花花蕊点（替换笨重圆点与方印焦点）
function ____exports.drawBlossomDot(overlayDraw, art, id, cx, cy, size, col, alpha, layer) -- 611
	if alpha == nil then -- 611
		alpha = 0.92 -- 616
	end -- 616
	if layer == nil then -- 616
		layer = 4 -- 617
	end -- 617
	if alpha <= 0.01 then -- 617
		return -- 620
	end -- 620
	if not art:tryPlace( -- 620
		"ink_blossom_dot", -- 622
		id, -- 622
		cx, -- 622
		cy, -- 622
		size, -- 622
		size, -- 622
		{ -- 622
			color = ____exports.toColor(col, 255), -- 622
			opacity = alpha, -- 622
			layer = layer -- 622
		} -- 622
	) then -- 622
		____exports.drawDiamond( -- 623
			overlayDraw, -- 623
			cx, -- 623
			cy, -- 623
			size * 0.35, -- 623
			size * 0.35, -- 623
			____exports.toColor(col, 230 * alpha) -- 623
		) -- 623
	end -- 623
end -- 611
--- 清雅霜银发丝微框键位（去土黄、去厚底）
function ____exports.drawSilkKeycap(overlayDraw, texts, x, y, w, h, keyText, accent, alpha, urgent) -- 628
	if alpha == nil then -- 628
		alpha = 1 -- 634
	end -- 634
	if urgent == nil then -- 634
		urgent = false -- 635
	end -- 635
	local bg = urgent and ____exports.toColor(____exports.PALETTE.rougeSoft, 200 * alpha) or Color( -- 637
		14, -- 637
		17, -- 637
		25, -- 637
		math.floor(186 * alpha + 0.5) -- 637
	) -- 637
	local bd = ____exports.toColor(urgent and ____exports.PALETTE.crimsonCore or accent, (urgent and 225 or 165) * alpha) -- 638
	overlayDraw:drawRect( -- 639
		Rect(x, y, w, h), -- 639
		bg, -- 639
		0.85, -- 639
		bd -- 639
	) -- 639
	local tc = urgent and ____exports.toColor(____exports.PALETTE.sealText) or ____exports.toColor(____exports.PALETTE.textBright) -- 640
	texts:put( -- 641
		"xs", -- 641
		keyText, -- 641
		x + w * 0.5, -- 641
		y + h * 0.5, -- 641
		tc, -- 641
		0.5, -- 641
		0.5, -- 641
		"Center", -- 641
		0.5, -- 641
		alpha, -- 641
		urgent and 0 or 0.08 -- 641
	) -- 641
end -- 628
--- 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述清雅水墨原语
function ____exports.fillSkewRect(draw, x, y, w, h, skew, fill, borderW, borderCol) -- 645
	if borderW == nil then -- 645
		borderW = 0 -- 648
	end -- 648
	if w <= 0 or h <= 0 then -- 648
		return -- 651
	end -- 651
	local pts = { -- 653
		Vec2(x, y), -- 654
		Vec2(x + w, y), -- 655
		Vec2(x + w + skew, y + h), -- 656
		Vec2(x + skew, y + h) -- 657
	} -- 657
	if borderW > 0 and borderCol ~= nil then -- 657
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 660
	else -- 660
		draw:drawPolygon(pts, fill) -- 662
	end -- 662
end -- 645
function ____exports.fillChamferBox(draw, x, y, w, h, cut, fill, borderW, borderCol) -- 666
	if borderW == nil then -- 666
		borderW = 0 -- 669
	end -- 669
	local c = math.min(cut, w * 0.3, h * 0.3) -- 671
	local pts = { -- 672
		Vec2(x, y), -- 673
		Vec2(x + w - c, y), -- 674
		Vec2(x + w, y + c), -- 675
		Vec2(x + w, y + h), -- 676
		Vec2(x + c, y + h), -- 677
		Vec2(x, y + h - c) -- 678
	} -- 678
	if borderW > 0 and borderCol ~= nil then -- 678
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 681
	else -- 681
		draw:drawPolygon(pts, fill) -- 683
	end -- 683
end -- 666
function ____exports.visualTextWidth(text, fontSize) -- 705
	local units = 0 -- 706
	local i = 0 -- 707
	do -- 707
		i = 0 -- 708
		while i < #text do -- 708
			local b = __TS__StringCharCodeAt(text, i) -- 709
			if b < 128 then -- 709
				units = units + 0.56 -- 711
			elseif b >= 192 then -- 711
				units = units + 1.02 -- 713
			end -- 713
			i = i + 1 -- 708
		end -- 708
	end -- 708
	return units * fontSize -- 716
end -- 705
function ____exports.drawHazardStripes(draw, x, y, w, h, pitch, col) -- 719
	local sw = pitch * 0.45 -- 724
	local cur = x - h -- 725
	while cur < x + w do -- 725
		local x0 = math.max(x, cur) -- 727
		local x1 = math.min(x + w, cur + sw) -- 728
		local tx0 = math.max(x, cur + h) -- 729
		local tx1 = math.min(x + w, cur + h + sw) -- 730
		if x1 > x0 and tx1 > tx0 then -- 730
			draw:drawPolygon( -- 732
				{ -- 732
					Vec2(x0, y), -- 733
					Vec2(x1, y), -- 734
					Vec2(tx1, y + h), -- 735
					Vec2(tx0, y + h) -- 736
				}, -- 736
				col -- 737
			) -- 737
		end -- 737
		cur = cur + pitch -- 739
	end -- 739
end -- 719
return ____exports -- 719