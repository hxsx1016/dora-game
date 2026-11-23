-- [ts]: theme.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Rect = ____Dora.Rect -- 8
local Vec2 = ____Dora.Vec2 -- 8
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
--- 中国水墨矿石色板（兼容原有 Token 命名，确保舞台/角色/道具无破坏接入）
____exports.PALETTE = { -- 39
	voidDark = ____exports.rgba(13, 14, 19, 255), -- 41
	panelBg = ____exports.rgba(19, 20, 26, 224), -- 42
	panelBgDeep = ____exports.rgba(14, 15, 20, 240), -- 43
	steelDark = ____exports.rgba(32, 30, 34, 255), -- 44
	steelMid = ____exports.rgba(54, 49, 52, 255), -- 45
	steelLight = ____exports.rgba(112, 97, 82, 255), -- 46
	rimSilver = ____exports.rgba(154, 138, 118, 255), -- 47
	cyanCore = ____exports.rgba(232, 230, 218, 255), -- 50
	cyan = ____exports.rgba(146, 170, 178, 255), -- 51
	cyanDim = ____exports.rgba(94, 110, 118, 255), -- 52
	cyanGlow = ____exports.rgba(146, 170, 178, 72), -- 53
	amberCore = ____exports.rgba(246, 228, 188, 255), -- 56
	amber = ____exports.rgba(212, 164, 102, 255), -- 57
	amberDim = ____exports.rgba(134, 100, 64, 255), -- 58
	amberGlow = ____exports.rgba(212, 164, 102, 74), -- 59
	crimsonCore = ____exports.rgba(245, 204, 182, 255), -- 62
	crimson = ____exports.rgba(186, 66, 54, 255), -- 63
	crimsonDeep = ____exports.rgba(124, 38, 34, 255), -- 64
	crimsonGlow = ____exports.rgba(186, 66, 54, 72), -- 65
	emerald = ____exports.rgba(148, 172, 130, 255), -- 68
	emeraldDim = ____exports.rgba(92, 118, 90, 255), -- 69
	textBright = ____exports.rgba(243, 233, 212, 255), -- 72
	textMid = ____exports.rgba(202, 191, 172, 255), -- 73
	textDim = ____exports.rgba(146, 139, 130, 255), -- 74
	inkVoid = ____exports.rgba(12, 13, 18, 255), -- 77
	inkWash = ____exports.rgba(15, 16, 22, 255), -- 78
	inkMist = ____exports.rgba(28, 30, 38, 255), -- 79
	inkWarm = ____exports.rgba(42, 31, 28, 255), -- 80
	xuanWarm = ____exports.rgba(226, 211, 182, 255), -- 81
	xuanInk = ____exports.rgba(34, 26, 21, 255), -- 82
	xuanInkSub = ____exports.rgba(88, 70, 54, 255), -- 83
	xuanPaper = ____exports.rgba(226, 212, 184, 255), -- 84
	sealRed = ____exports.rgba(168, 46, 40, 255), -- 85
	sealRedBright = ____exports.rgba(202, 68, 56, 255), -- 86
	sealText = ____exports.rgba(248, 239, 222, 255), -- 87
	cinnabar = ____exports.rgba(182, 62, 52, 255), -- 88
	cinnabarDeep = ____exports.rgba(122, 38, 34, 255), -- 89
	bronzeLine = ____exports.rgba(168, 132, 84, 255), -- 90
	bronzeDim = ____exports.rgba(118, 90, 58, 255), -- 91
	moonPale = ____exports.rgba(228, 229, 218, 255), -- 92
	cartWood = ____exports.rgba(104, 73, 55, 255), -- 95
	cartMetal = ____exports.rgba(125, 110, 97, 255), -- 96
	clothRed = ____exports.rgba(162, 56, 46, 255), -- 97
	clothRedHighlight = ____exports.rgba(208, 96, 76, 255) -- 98
} -- 98
____exports.ROOM_THEMES = { -- 132
	prologue = { -- 133
		key = "prologue", -- 134
		numeralZh = "壹", -- 135
		actCode = "第壹章", -- 136
		titleZh = "序章 · 倒柜后", -- 137
		titleEn = "孤城护童", -- 138
		lineTag = "周戍", -- 139
		volumeTagZh = "上卷 · 孤城护童", -- 140
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 141
		skyMid = ____exports.rgba(16, 22, 34, 255), -- 142
		skyHorizon = ____exports.rgba(28, 38, 54, 255), -- 143
		farBuilding = ____exports.rgba(14, 18, 28, 255), -- 144
		midBuilding = ____exports.rgba(22, 26, 38, 255), -- 145
		fogBottom = ____exports.rgba(44, 58, 78, 62), -- 146
		groundTop = ____exports.rgba(46, 52, 62, 255), -- 147
		groundBody = ____exports.rgba(17, 20, 28, 255), -- 148
		groundRim = ____exports.rgba(146, 170, 178, 195), -- 149
		accent = ____exports.PALETTE.cyan, -- 150
		beamColor = ____exports.rgba(140, 168, 184, 34), -- 151
		ambient = "ash", -- 152
		showSearchlights = true, -- 153
		showTowerBeacon = false, -- 154
		showMoon = true, -- 155
		moonXFrac = 0.78, -- 156
		moonYFrac = 0.78, -- 157
		defaultZoom = 1.12, -- 158
		introWhisper = "城破前夜。她在倒塌的柜子后面。" -- 159
	}, -- 159
	street = { -- 161
		key = "street", -- 162
		numeralZh = "贰", -- 163
		actCode = "第贰章", -- 164
		titleZh = "街道 · 封锁线", -- 165
		titleEn = "孤城护童", -- 166
		lineTag = "周戍", -- 167
		volumeTagZh = "上卷 · 孤城护童", -- 168
		skyTop = ____exports.rgba(10, 12, 20, 255), -- 169
		skyMid = ____exports.rgba(20, 24, 36, 255), -- 170
		skyHorizon = ____exports.rgba(38, 36, 48, 255), -- 171
		farBuilding = ____exports.rgba(16, 19, 28, 255), -- 172
		midBuilding = ____exports.rgba(24, 27, 38, 255), -- 173
		fogBottom = ____exports.rgba(66, 54, 68, 64), -- 174
		groundTop = ____exports.rgba(48, 52, 60, 255), -- 175
		groundBody = ____exports.rgba(18, 20, 28, 255), -- 176
		groundRim = ____exports.rgba(146, 170, 178, 190), -- 177
		accent = ____exports.PALETTE.cyan, -- 178
		beamColor = ____exports.rgba(148, 170, 184, 34), -- 179
		ambient = "ash", -- 180
		showSearchlights = true, -- 181
		showTowerBeacon = false, -- 182
		showMoon = true, -- 183
		moonXFrac = 0.82, -- 184
		moonYFrac = 0.8, -- 185
		defaultZoom = 1, -- 186
		introWhisper = "带她穿过街心。别让火力压住她的步子。" -- 187
	}, -- 187
	checkpoint = { -- 189
		key = "checkpoint", -- 190
		numeralZh = "叁", -- 191
		actCode = "第叁章", -- 192
		titleZh = "检查站 · 装卸台", -- 193
		titleEn = "孤城护童", -- 194
		lineTag = "周戍", -- 195
		volumeTagZh = "上卷 · 孤城护童", -- 196
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 197
		skyMid = ____exports.rgba(18, 25, 38, 255), -- 198
		skyHorizon = ____exports.rgba(32, 44, 60, 255), -- 199
		farBuilding = ____exports.rgba(15, 21, 32, 255), -- 200
		midBuilding = ____exports.rgba(22, 30, 42, 255), -- 201
		fogBottom = ____exports.rgba(48, 68, 86, 58), -- 202
		groundTop = ____exports.rgba(46, 54, 64, 255), -- 203
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 204
		groundRim = ____exports.rgba(146, 170, 178, 200), -- 205
		accent = ____exports.PALETTE.cyan, -- 206
		beamColor = ____exports.rgba(140, 172, 188, 36), -- 207
		ambient = "ash", -- 208
		showSearchlights = true, -- 209
		showTowerBeacon = false, -- 210
		showMoon = true, -- 211
		moonXFrac = 0.74, -- 212
		moonYFrac = 0.82, -- 213
		defaultZoom = 1, -- 214
		introWhisper = "把那辆系着红布的板车推进装卸窝，城门才会放行。" -- 215
	}, -- 215
	gate = { -- 217
		key = "gate", -- 218
		numeralZh = "肆", -- 219
		actCode = "第肆章", -- 220
		titleZh = "城门 · 四十五秒", -- 221
		titleEn = "死守断后", -- 222
		lineTag = "周戍", -- 223
		volumeTagZh = "上卷 · 孤城护童", -- 224
		skyTop = ____exports.rgba(14, 10, 14, 255), -- 225
		skyMid = ____exports.rgba(28, 17, 22, 255), -- 226
		skyHorizon = ____exports.rgba(56, 28, 30, 255), -- 227
		farBuilding = ____exports.rgba(20, 15, 20, 255), -- 228
		midBuilding = ____exports.rgba(30, 21, 26, 255), -- 229
		fogBottom = ____exports.rgba(118, 42, 42, 62), -- 230
		groundTop = ____exports.rgba(54, 48, 52, 255), -- 231
		groundBody = ____exports.rgba(18, 16, 21, 255), -- 232
		groundRim = ____exports.rgba(186, 66, 54, 195), -- 233
		accent = ____exports.PALETTE.crimson, -- 234
		beamColor = ____exports.rgba(196, 76, 62, 38), -- 235
		ambient = "ash", -- 236
		showSearchlights = true, -- 237
		showTowerBeacon = false, -- 238
		showMoon = true, -- 239
		moonXFrac = 0.22, -- 240
		moonYFrac = 0.8, -- 241
		defaultZoom = 0.92, -- 242
		introWhisper = "把她送到门洞，守住绞盘四十五秒。" -- 243
	}, -- 243
	outside = { -- 245
		key = "outside", -- 246
		numeralZh = "伍", -- 247
		actCode = "第伍章", -- 248
		titleZh = "城墙外 · 拱与红布", -- 249
		titleEn = "独赴北塔", -- 250
		lineTag = "小满", -- 251
		volumeTagZh = "下卷 · 独赴北塔", -- 252
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 253
		skyMid = ____exports.rgba(16, 24, 38, 255), -- 254
		skyHorizon = ____exports.rgba(30, 42, 60, 255), -- 255
		farBuilding = ____exports.rgba(14, 19, 30, 255), -- 256
		midBuilding = ____exports.rgba(20, 28, 42, 255), -- 257
		fogBottom = ____exports.rgba(48, 64, 88, 58), -- 258
		groundTop = ____exports.rgba(48, 54, 64, 255), -- 259
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 260
		groundRim = ____exports.rgba(168, 152, 126, 185), -- 261
		accent = ____exports.PALETTE.amber, -- 262
		beamColor = ____exports.rgba(176, 166, 146, 28), -- 263
		ambient = "drizzle", -- 264
		showSearchlights = false, -- 265
		showTowerBeacon = true, -- 266
		showMoon = true, -- 267
		moonXFrac = 0.68, -- 268
		moonYFrac = 0.82, -- 269
		defaultZoom = 0.96, -- 270
		introWhisper = "门后再没有人应声。把板车拉进空窝，蹲着穿过低拱。" -- 271
	}, -- 271
	village = { -- 273
		key = "village", -- 274
		numeralZh = "陆", -- 275
		actCode = "第陆章", -- 276
		titleZh = "废弃村庄 · 砖地一响", -- 277
		titleEn = "独赴北塔", -- 278
		lineTag = "小满", -- 279
		volumeTagZh = "下卷 · 独赴北塔", -- 280
		skyTop = ____exports.rgba(10, 12, 18, 255), -- 281
		skyMid = ____exports.rgba(18, 23, 33, 255), -- 282
		skyHorizon = ____exports.rgba(36, 40, 50, 255), -- 283
		farBuilding = ____exports.rgba(15, 19, 26, 255), -- 284
		midBuilding = ____exports.rgba(24, 28, 36, 255), -- 285
		fogBottom = ____exports.rgba(74, 68, 60, 54), -- 286
		groundTop = ____exports.rgba(54, 54, 58, 255), -- 287
		groundBody = ____exports.rgba(18, 20, 25, 255), -- 288
		groundRim = ____exports.rgba(206, 174, 122, 185), -- 289
		accent = ____exports.PALETTE.amber, -- 290
		beamColor = ____exports.rgba(212, 174, 118, 24), -- 291
		ambient = "drizzle", -- 292
		showSearchlights = false, -- 293
		showTowerBeacon = true, -- 294
		showMoon = true, -- 295
		moonXFrac = 0.78, -- 296
		moonYFrac = 0.82, -- 297
		defaultZoom = 1, -- 298
		introWhisper = "别被拾荒者看见。拾起瓶子扔向砖地，趁他转身钻过桌底。" -- 299
	}, -- 299
	forest = { -- 301
		key = "forest", -- 302
		numeralZh = "柒", -- 303
		actCode = "第柒章", -- 304
		titleZh = "北塔森林 · 听风辨步", -- 305
		titleEn = "独赴北塔", -- 306
		lineTag = "小满", -- 307
		volumeTagZh = "下卷 · 独赴北塔", -- 308
		skyTop = ____exports.rgba(8, 12, 16, 255), -- 309
		skyMid = ____exports.rgba(14, 24, 28, 255), -- 310
		skyHorizon = ____exports.rgba(26, 44, 46, 255), -- 311
		farBuilding = ____exports.rgba(12, 20, 24, 255), -- 312
		midBuilding = ____exports.rgba(18, 30, 32, 255), -- 313
		fogBottom = ____exports.rgba(52, 86, 82, 56), -- 314
		groundTop = ____exports.rgba(36, 52, 48, 255), -- 315
		groundBody = ____exports.rgba(14, 22, 22, 255), -- 316
		groundRim = ____exports.rgba(148, 172, 130, 190), -- 317
		accent = ____exports.PALETTE.emerald, -- 318
		beamColor = ____exports.rgba(148, 178, 146, 24), -- 319
		ambient = "spores", -- 320
		showSearchlights = false, -- 321
		showTowerBeacon = true, -- 322
		showMoon = true, -- 323
		moonXFrac = 0.72, -- 324
		moonYFrac = 0.84, -- 325
		defaultZoom = 1, -- 326
		introWhisper = "猎犬比人先听见脚步。伏在草影里，向北塔灯火走去。" -- 327
	}, -- 327
	tower = { -- 329
		key = "tower", -- 330
		numeralZh = "捌", -- 331
		actCode = "终章", -- 332
		titleZh = "北塔 · 最后一行", -- 333
		titleEn = "归途尾声", -- 334
		lineTag = "尾声", -- 335
		volumeTagZh = "终章 · 北塔守望", -- 336
		skyTop = ____exports.rgba(10, 13, 21, 255), -- 337
		skyMid = ____exports.rgba(20, 28, 44, 255), -- 338
		skyHorizon = ____exports.rgba(48, 52, 66, 255), -- 339
		farBuilding = ____exports.rgba(16, 21, 32, 255), -- 340
		midBuilding = ____exports.rgba(24, 30, 44, 255), -- 341
		fogBottom = ____exports.rgba(212, 168, 104, 48), -- 342
		groundTop = ____exports.rgba(60, 60, 66, 255), -- 343
		groundBody = ____exports.rgba(19, 21, 28, 255), -- 344
		groundRim = ____exports.rgba(232, 194, 128, 210), -- 345
		accent = ____exports.PALETTE.amber, -- 346
		beamColor = ____exports.rgba(236, 198, 132, 40), -- 347
		ambient = "motes", -- 348
		showSearchlights = false, -- 349
		showTowerBeacon = true, -- 350
		showMoon = true, -- 351
		moonXFrac = 0.24, -- 352
		moonYFrac = 0.8, -- 353
		defaultZoom = 1.12, -- 354
		introWhisper = "灯亮着。走到门前，像他教你的那样，敲两下。" -- 355
	} -- 355
} -- 355
function ____exports.themeOf(key) -- 359
	local t = ____exports.ROOM_THEMES[key] -- 360
	return t ~= nil and t or ____exports.ROOM_THEMES.prologue -- 361
end -- 359
local UPPER_DIGITS = { -- 364
	"零", -- 364
	"壹", -- 364
	"贰", -- 364
	"叁", -- 364
	"肆", -- 364
	"伍", -- 364
	"陆", -- 364
	"柒", -- 364
	"捌", -- 364
	"玖" -- 364
} -- 364
--- 将 0..100 整数转为传统中文大写数字（零、壹..拾、拾壹..玖拾玖、壹佰）
function ____exports.toChineseUpper(n) -- 367
	local v = math.max( -- 368
		0, -- 368
		math.min( -- 368
			100, -- 368
			math.floor(n) -- 368
		) -- 368
	) -- 368
	if v == 100 then -- 368
		return "壹佰" -- 370
	end -- 370
	if v < 10 then -- 370
		return UPPER_DIGITS[v + 1] -- 373
	end -- 373
	local tens = math.floor(v / 10) -- 375
	local ones = v % 10 -- 376
	local prefix = tens == 1 and "拾" or UPPER_DIGITS[tens + 1] .. "拾" -- 377
	return ones == 0 and prefix or prefix .. UPPER_DIGITS[ones + 1] -- 378
end -- 367
--- 顶点渐变四边形（按顺时针/逆时针拆成两个三角形）
function ____exports.fillGradQuad(draw, x0, y0, c00, x1, y1, c10, x2, y2, c11, x3, y3, c01) -- 382
	local p0 = Vec2(x0, y0) -- 389
	local p1 = Vec2(x1, y1) -- 390
	local p2 = Vec2(x2, y2) -- 391
	local p3 = Vec2(x3, y3) -- 392
	draw:drawVertices({ -- 393
		{p0, c00}, -- 394
		{p1, c10}, -- 394
		{p2, c11}, -- 394
		{p0, c00}, -- 395
		{p2, c11}, -- 395
		{p3, c01} -- 395
	}) -- 395
end -- 382
--- 竖直方向线性渐变矩形
function ____exports.fillVGradRect(draw, x, y, w, h, bottomCol, topCol) -- 400
	____exports.fillGradQuad( -- 405
		draw, -- 406
		x, -- 407
		y, -- 407
		bottomCol, -- 407
		x + w, -- 408
		y, -- 408
		bottomCol, -- 408
		x + w, -- 409
		y + h, -- 409
		topCol, -- 409
		x, -- 410
		y + h, -- 410
		topCol -- 410
	) -- 410
end -- 400
--- 水平方向线性渐变矩形
function ____exports.fillHGradRect(draw, x, y, w, h, leftCol, rightCol) -- 415
	____exports.fillGradQuad( -- 420
		draw, -- 421
		x, -- 422
		y, -- 422
		leftCol, -- 422
		x + w, -- 423
		y, -- 423
		rightCol, -- 423
		x + w, -- 424
		y + h, -- 424
		rightCol, -- 424
		x, -- 425
		y + h, -- 425
		leftCol -- 425
	) -- 425
end -- 415
--- 径向柔和光晕（扇形顶点渐变）
function ____exports.fillRadialGlow(draw, cx, cy, rx, ry, innerCol, outerCol, segments) -- 430
	if segments == nil then -- 430
		segments = 18 -- 434
	end -- 434
	if rx <= 0.5 or ry <= 0.5 then -- 434
		return -- 437
	end -- 437
	local center = Vec2(cx, cy) -- 439
	local verts = {} -- 440
	local step = math.pi * 2 / segments -- 441
	local i = 0 -- 442
	do -- 442
		i = 0 -- 443
		while i < segments do -- 443
			local a0 = i * step -- 444
			local a1 = (i + 1) * step -- 445
			verts[#verts + 1] = {center, innerCol} -- 446
			verts[#verts + 1] = { -- 447
				Vec2( -- 447
					cx + math.cos(a0) * rx, -- 447
					cy + math.sin(a0) * ry -- 447
				), -- 447
				outerCol -- 447
			} -- 447
			verts[#verts + 1] = { -- 448
				Vec2( -- 448
					cx + math.cos(a1) * rx, -- 448
					cy + math.sin(a1) * ry -- 448
				), -- 448
				outerCol -- 448
			} -- 448
			i = i + 1 -- 443
		end -- 443
	end -- 443
	draw:drawVertices(verts) -- 450
end -- 430
--- 水墨飞白横刷长带（优先使用 ui_ink.clip 的毛笔笔触贴图，缺图自动回退两端渐隐墨晕）
function ____exports.drawInkWashStrip(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, symmetric, layer) -- 456
	if opacity == nil then -- 456
		opacity = 0.88 -- 461
	end -- 461
	if symmetric == nil then -- 461
		symmetric = true -- 462
	end -- 462
	if layer == nil then -- 462
		layer = 0 -- 463
	end -- 463
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 463
		return -- 466
	end -- 466
	local slot = symmetric and "ink_brush_sym" or "ink_brush_wide" -- 468
	if art:tryPlace( -- 468
		slot, -- 469
		id, -- 469
		cx, -- 469
		cy, -- 469
		w, -- 469
		h, -- 469
		{ -- 469
			color = ____exports.toColor(tint, 255), -- 469
			opacity = opacity, -- 469
			layer = layer -- 469
		} -- 469
	) then -- 469
		return -- 470
	end -- 470
	local x = cx - w * 0.5 -- 473
	local y = cy - h * 0.5 -- 474
	local fadeW = symmetric and w * 0.18 or w * 0.34 -- 475
	local midCol = ____exports.toColor( -- 476
		tint, -- 476
		math.floor(235 * opacity + 0.5) -- 476
	) -- 476
	local zeroCol = Color(tint.r, tint.g, tint.b, 0) -- 477
	if symmetric then -- 477
		____exports.fillHGradRect( -- 479
			fallbackDraw, -- 479
			x, -- 479
			y, -- 479
			fadeW, -- 479
			h, -- 479
			zeroCol, -- 479
			midCol -- 479
		) -- 479
		fallbackDraw:drawRect( -- 480
			Rect( -- 480
				x + fadeW, -- 480
				y, -- 480
				math.max(0, w - fadeW * 2), -- 480
				h -- 480
			), -- 480
			midCol -- 480
		) -- 480
		____exports.fillHGradRect( -- 481
			fallbackDraw, -- 481
			x + w - fadeW, -- 481
			y, -- 481
			fadeW, -- 481
			h, -- 481
			midCol, -- 481
			zeroCol -- 481
		) -- 481
	else -- 481
		local leftFade = math.min(20, w * 0.08) -- 483
		____exports.fillHGradRect( -- 484
			fallbackDraw, -- 484
			x, -- 484
			y, -- 484
			leftFade, -- 484
			h, -- 484
			zeroCol, -- 484
			midCol -- 484
		) -- 484
		fallbackDraw:drawRect( -- 485
			Rect( -- 485
				x + leftFade, -- 485
				y, -- 485
				math.max(0, w - leftFade - fadeW), -- 485
				h -- 485
			), -- 485
			midCol -- 485
		) -- 485
		____exports.fillHGradRect( -- 486
			fallbackDraw, -- 486
			x + w - fadeW, -- 486
			y, -- 486
			fadeW, -- 486
			h, -- 486
			midCol, -- 486
			zeroCol -- 486
		) -- 486
	end -- 486
end -- 456
--- 宣纸墨云面板（四周柔化渐隐的暗墨托底，可选叠加微弱宣纸纤维肌理）
function ____exports.drawInkPanel(fallbackDraw, art, id, x, y, w, h, tint, opacity, withPaperGrain, layer) -- 493
	if opacity == nil then -- 493
		opacity = 0.9 -- 498
	end -- 498
	if withPaperGrain == nil then -- 498
		withPaperGrain = false -- 499
	end -- 499
	if layer == nil then -- 499
		layer = -1 -- 500
	end -- 500
	local cx = x + w * 0.5 -- 502
	local cy = y + h * 0.5 -- 503
	if not art:tryPlace( -- 503
		"ink_wash_panel", -- 504
		id, -- 504
		cx, -- 504
		cy, -- 504
		w + 18, -- 504
		h + 16, -- 504
		{ -- 504
			color = ____exports.toColor(tint, 255), -- 504
			opacity = opacity, -- 504
			layer = layer -- 504
		} -- 504
	) then -- 504
		fallbackDraw:drawRect( -- 505
			Rect(x, y, w, h), -- 505
			____exports.toColor( -- 505
				tint, -- 505
				math.floor(230 * opacity + 0.5) -- 505
			) -- 505
		) -- 505
	end -- 505
	if withPaperGrain then -- 505
		art:tryPlace( -- 508
			"ink_paper_grain", -- 508
			id .. "_grain", -- 508
			cx, -- 508
			cy, -- 508
			w - 6, -- 508
			h - 6, -- 508
			{opacity = 0.11 * opacity, layer = layer + 1} -- 508
		) -- 508
	end -- 508
end -- 493
--- 典籍双线卷轴框（外古铜枯线 + 内缩极细线 + 四角镜像铜雕花 + 可选卷轴木杆）
function ____exports.drawScrollFrame(overlayDraw, art, id, x, y, w, h, borderCol, alpha, showCorners, showRollers, cornerSize, layer) -- 515
	if alpha == nil then -- 515
		alpha = 1 -- 520
	end -- 520
	if showCorners == nil then -- 520
		showCorners = true -- 521
	end -- 521
	if showRollers == nil then -- 521
		showRollers = false -- 522
	end -- 522
	if cornerSize == nil then -- 522
		cornerSize = 22 -- 523
	end -- 523
	if layer == nil then -- 523
		layer = 2 -- 524
	end -- 524
	if alpha <= 0.01 then -- 524
		return -- 527
	end -- 527
	overlayDraw:drawRect( -- 530
		Rect(x, y, w, h), -- 530
		Color(0, 0, 0, 0), -- 530
		1.15, -- 530
		____exports.toColor(borderCol, 175 * alpha) -- 530
	) -- 530
	overlayDraw:drawRect( -- 531
		Rect( -- 531
			x + 4, -- 531
			y + 4, -- 531
			math.max(0, w - 8), -- 531
			math.max(0, h - 8) -- 531
		), -- 531
		Color(0, 0, 0, 0), -- 531
		0.7, -- 531
		____exports.toColor(borderCol, 72 * alpha) -- 531
	) -- 531
	if showCorners then -- 531
		local half = cornerSize * 0.5 -- 534
		local insetX = showRollers and -6 or 2 -- 535
		local insetY = showRollers and -8 or 2 -- 536
		local cCol = ____exports.toColor(borderCol, 255) -- 537
		local op = (showRollers and 0.72 or 0.85) * alpha -- 538
		art:tryPlace( -- 540
			"ui_corner_c", -- 540
			id .. "_tl", -- 540
			x + half - insetX, -- 540
			y + h - half + insetY, -- 540
			cornerSize, -- 540
			cornerSize, -- 540
			{color = cCol, opacity = op, layer = layer} -- 540
		) -- 540
		art:tryPlace( -- 541
			"ui_corner_c", -- 541
			id .. "_tr", -- 541
			x + w - half + insetX, -- 541
			y + h - half + insetY, -- 541
			cornerSize, -- 541
			cornerSize, -- 541
			{facing = -1, color = cCol, opacity = op, layer = layer} -- 541
		) -- 541
		art:tryPlace( -- 542
			"ui_corner_c", -- 542
			id .. "_bl", -- 542
			x + half - insetX, -- 542
			y + half - insetY, -- 542
			cornerSize, -- 542
			cornerSize, -- 542
			{flipY = true, color = cCol, opacity = op, layer = layer} -- 542
		) -- 542
		art:tryPlace( -- 543
			"ui_corner_c", -- 543
			id .. "_br", -- 543
			x + w - half + insetX, -- 543
			y + half - insetY, -- 543
			cornerSize, -- 543
			cornerSize, -- 543
			{ -- 543
				facing = -1, -- 543
				flipY = true, -- 543
				color = cCol, -- 543
				opacity = op, -- 543
				layer = layer -- 543
			} -- 543
		) -- 543
	end -- 543
	if showRollers then -- 543
		local rodW = w + 36 -- 547
		local rodH = 18 -- 548
		art:tryPlace( -- 549
			"ink_scroll_bar", -- 549
			id .. "_rod_top", -- 549
			x + w * 0.5, -- 549
			y + h + 2, -- 549
			rodW, -- 549
			rodH, -- 549
			{opacity = 0.94 * alpha, layer = layer + 1} -- 549
		) -- 549
		art:tryPlace( -- 550
			"ink_scroll_bar", -- 550
			id .. "_rod_bot", -- 550
			x + w * 0.5, -- 550
			y - 2, -- 550
			rodW, -- 550
			rodH, -- 550
			{opacity = 0.94 * alpha, layer = layer + 1} -- 550
		) -- 550
	end -- 550
end -- 515
--- 枯笔一字墨线分隔符（中段实、两端尖细透明收锋）
function ____exports.drawBrushDivider(overlayDraw, art, id, cx, cy, w, h, col, alpha, layer) -- 557
	if alpha == nil then -- 557
		alpha = 0.82 -- 562
	end -- 562
	if layer == nil then -- 562
		layer = 2 -- 563
	end -- 563
	if w <= 4 or alpha <= 0.01 then -- 563
		return -- 566
	end -- 566
	if art:tryPlace( -- 566
		"ink_divider", -- 568
		id, -- 568
		cx, -- 568
		cy, -- 568
		w, -- 568
		h, -- 568
		{ -- 568
			color = ____exports.toColor(col, 255), -- 568
			opacity = alpha, -- 568
			layer = layer -- 568
		} -- 568
	) then -- 568
		return -- 569
	end -- 569
	local half = w * 0.5 -- 571
	____exports.fillHGradRect( -- 572
		overlayDraw, -- 572
		cx - half, -- 572
		cy - 0.7, -- 572
		half, -- 572
		1.4, -- 572
		Color(col.r, col.g, col.b, 0), -- 572
		____exports.toColor(col, 200 * alpha) -- 572
	) -- 572
	____exports.fillHGradRect( -- 573
		overlayDraw, -- 573
		cx, -- 573
		cy - 0.7, -- 573
		half, -- 573
		1.4, -- 573
		____exports.toColor(col, 200 * alpha), -- 573
		Color(col.r, col.g, col.b, 0) -- 573
	) -- 573
end -- 557
--- 中国传统方形残边篆印（阳刻空心框 / 阴刻实底印泥 + 毛笔字）
function ____exports.drawSealStamp(overlayDraw, art, texts, id, cx, cy, size, text, stampCol, textCol, alpha, solid, layer) -- 579
	if alpha == nil then -- 579
		alpha = 1 -- 587
	end -- 587
	if solid == nil then -- 587
		solid = true -- 588
	end -- 588
	if layer == nil then -- 588
		layer = 4 -- 589
	end -- 589
	if alpha <= 0.01 then -- 589
		return -- 592
	end -- 592
	local slot = solid and "ink_seal_solid" or "ink_seal_hollow" -- 594
	local placed = art:tryPlace( -- 595
		slot, -- 595
		id, -- 595
		cx, -- 595
		cy, -- 595
		size, -- 595
		size, -- 595
		{ -- 595
			color = ____exports.toColor(stampCol, 255), -- 595
			opacity = 0.94 * alpha, -- 595
			layer = layer -- 595
		} -- 595
	) -- 595
	if not placed then -- 595
		local half = size * 0.45 -- 597
		if solid then -- 597
			overlayDraw:drawRect( -- 599
				Rect(cx - half, cy - half, half * 2, half * 2), -- 599
				____exports.toColor(stampCol, 230 * alpha), -- 599
				1, -- 599
				____exports.toColor(textCol, 85 * alpha) -- 599
			) -- 599
		else -- 599
			overlayDraw:drawRect( -- 601
				Rect(cx - half, cy - half, half * 2, half * 2), -- 601
				Color( -- 601
					16, -- 601
					17, -- 601
					22, -- 601
					math.floor(165 * alpha + 0.5) -- 601
				), -- 601
				1.3, -- 601
				____exports.toColor(stampCol, 225 * alpha) -- 601
			) -- 601
		end -- 601
	end -- 601
	if text ~= "" then -- 601
		local bucket = size >= 36 and "sealLg" or "seal" -- 605
		local outW = solid and 0 or 0.1 -- 607
		texts:put( -- 608
			bucket, -- 608
			text, -- 608
			cx, -- 608
			cy, -- 608
			____exports.toColor(textCol), -- 608
			0.5, -- 608
			0.5, -- 608
			"Center", -- 608
			0, -- 608
			alpha, -- 608
			outW -- 608
		) -- 608
	end -- 608
end -- 579
--- 竖向腰圆引首章（常用于古典竖排主标题旁，如「守」「望」）
function ____exports.drawOvalSeal(overlayDraw, art, texts, id, cx, cy, w, h, topChar, botChar, stampCol, textCol, alpha, layer) -- 615
	if alpha == nil then -- 615
		alpha = 1 -- 623
	end -- 623
	if layer == nil then -- 623
		layer = 4 -- 624
	end -- 624
	if alpha <= 0.01 then -- 624
		return -- 627
	end -- 627
	local placed = art:tryPlace( -- 629
		"ink_seal_oval", -- 629
		id, -- 629
		cx, -- 629
		cy, -- 629
		w, -- 629
		h, -- 629
		{ -- 629
			color = ____exports.toColor(stampCol, 255), -- 629
			opacity = 0.94 * alpha, -- 629
			layer = layer -- 629
		} -- 629
	) -- 629
	if not placed then -- 629
		overlayDraw:drawRect( -- 631
			Rect(cx - w * 0.44, cy - h * 0.44, w * 0.88, h * 0.88), -- 631
			____exports.toColor(stampCol, 225 * alpha) -- 631
		) -- 631
	end -- 631
	texts:put( -- 633
		"seal", -- 633
		topChar, -- 633
		cx, -- 633
		cy + h * 0.17, -- 633
		____exports.toColor(textCol), -- 633
		0.5, -- 633
		0.5, -- 633
		"Center", -- 633
		0, -- 633
		alpha, -- 633
		0 -- 633
	) -- 633
	texts:put( -- 634
		"seal", -- 634
		botChar, -- 634
		cx, -- 634
		cy - h * 0.18, -- 634
		____exports.toColor(textCol), -- 634
		0.5, -- 634
		0.5, -- 634
		"Center", -- 634
		0, -- 634
		alpha, -- 634
		0 -- 634
	) -- 634
end -- 615
--- 方正古铜细边键位印格（替换科幻斜切键帽）
function ____exports.drawInkKeycap(overlayDraw, texts, x, y, w, h, keyText, accent, alpha, filled) -- 640
	if alpha == nil then -- 640
		alpha = 1 -- 646
	end -- 646
	if filled == nil then -- 646
		filled = false -- 647
	end -- 647
	local bg = filled and ____exports.toColor(accent, 220 * alpha) or Color( -- 649
		18, -- 649
		17, -- 649
		21, -- 649
		math.floor(218 * alpha + 0.5) -- 649
	) -- 649
	local bd = ____exports.toColor(accent, (filled and 245 or 195) * alpha) -- 650
	overlayDraw:drawRect( -- 651
		Rect(x, y, w, h), -- 651
		bg, -- 651
		1.15, -- 651
		bd -- 651
	) -- 651
	if not filled then -- 651
		overlayDraw:drawRect( -- 654
			Rect( -- 654
				x + 2.5, -- 654
				y + 2.5, -- 654
				math.max(0, w - 5), -- 654
				math.max(0, h - 5) -- 654
			), -- 654
			Color(0, 0, 0, 0), -- 654
			0.6, -- 654
			____exports.toColor(accent, 75 * alpha) -- 654
		) -- 654
	end -- 654
	local tc = filled and ____exports.toColor(____exports.PALETTE.sealText) or ____exports.toColor(____exports.PALETTE.amberCore) -- 656
	texts:put( -- 657
		"xs", -- 657
		keyText, -- 657
		x + w * 0.5, -- 657
		y + h * 0.5, -- 657
		tc, -- 657
		0.5, -- 657
		0.5, -- 657
		"Center", -- 657
		0.3, -- 657
		alpha, -- 657
		filled and 0 or 0.1 -- 657
	) -- 657
end -- 640
--- 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述水墨原语
function ____exports.fillSkewRect(draw, x, y, w, h, skew, fill, borderW, borderCol) -- 661
	if borderW == nil then -- 661
		borderW = 0 -- 664
	end -- 664
	if w <= 0 or h <= 0 then -- 664
		return -- 667
	end -- 667
	local pts = { -- 669
		Vec2(x, y), -- 670
		Vec2(x + w, y), -- 671
		Vec2(x + w + skew, y + h), -- 672
		Vec2(x + skew, y + h) -- 673
	} -- 673
	if borderW > 0 and borderCol ~= nil then -- 673
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 676
	else -- 676
		draw:drawPolygon(pts, fill) -- 678
	end -- 678
end -- 661
function ____exports.fillChamferBox(draw, x, y, w, h, cut, fill, borderW, borderCol) -- 682
	if borderW == nil then -- 682
		borderW = 0 -- 685
	end -- 685
	local c = math.min(cut, w * 0.3, h * 0.3) -- 687
	local pts = { -- 688
		Vec2(x, y), -- 689
		Vec2(x + w - c, y), -- 690
		Vec2(x + w, y + c), -- 691
		Vec2(x + w, y + h), -- 692
		Vec2(x + c, y + h), -- 693
		Vec2(x, y + h - c) -- 694
	} -- 694
	if borderW > 0 and borderCol ~= nil then -- 694
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 697
	else -- 697
		draw:drawPolygon(pts, fill) -- 699
	end -- 699
end -- 682
function ____exports.drawDiamond(draw, cx, cy, rx, ry, fill, borderW, borderCol) -- 703
	if borderW == nil then -- 703
		borderW = 0 -- 706
	end -- 706
	local pts = { -- 708
		Vec2(cx, cy + ry), -- 709
		Vec2(cx + rx, cy), -- 710
		Vec2(cx, cy - ry), -- 711
		Vec2(cx - rx, cy) -- 712
	} -- 712
	if borderW > 0 and borderCol ~= nil then -- 712
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 715
	else -- 715
		draw:drawPolygon(pts, fill) -- 717
	end -- 717
end -- 703
--- 估算 UTF-8 中英文混排字符串的视觉像素宽度（Lua 的 string.length 返回字节数，1 个汉字占 3 字节）。
function ____exports.visualTextWidth(text, fontSize) -- 724
	local units = 0 -- 725
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #text do -- 727
			local b = __TS__StringCharCodeAt(text, i) -- 728
			if b < 128 then -- 728
				units = units + 0.56 -- 730
			elseif b >= 192 then -- 730
				units = units + 1.02 -- 732
			end -- 732
			i = i + 1 -- 727
		end -- 727
	end -- 727
	return units * fontSize -- 735
end -- 724
function ____exports.drawHazardStripes(draw, x, y, w, h, pitch, col) -- 738
	local sw = pitch * 0.45 -- 743
	local cur = x - h -- 744
	while cur < x + w do -- 744
		local x0 = math.max(x, cur) -- 746
		local x1 = math.min(x + w, cur + sw) -- 747
		local tx0 = math.max(x, cur + h) -- 748
		local tx1 = math.min(x + w, cur + h + sw) -- 749
		if x1 > x0 and tx1 > tx0 then -- 749
			draw:drawPolygon( -- 751
				{ -- 751
					Vec2(x0, y), -- 752
					Vec2(x1, y), -- 753
					Vec2(tx1, y + h), -- 754
					Vec2(tx0, y + h) -- 755
				}, -- 755
				col -- 756
			) -- 756
		end -- 756
		cur = cur + pitch -- 758
	end -- 758
end -- 738
return ____exports -- 738