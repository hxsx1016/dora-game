-- [ts]: theme.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Rect = ____Dora.Rect -- 8
local Vec2 = ____Dora.Vec2 -- 8
function ____exports.drawDiamond(draw, cx, cy, rx, ry, fill, borderW, borderCol) -- 716
	if borderW == nil then -- 716
		borderW = 0 -- 719
	end -- 719
	local pts = { -- 721
		Vec2(cx, cy + ry), -- 722
		Vec2(cx + rx, cy), -- 723
		Vec2(cx, cy - ry), -- 724
		Vec2(cx - rx, cy) -- 725
	} -- 725
	if borderW > 0 and borderCol ~= nil then -- 725
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 728
	else -- 728
		draw:drawPolygon(pts, fill) -- 730
	end -- 730
end -- 716
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
____exports.ROOM_THEMES = { -- 139
	prologue = { -- 140
		key = "prologue", -- 141
		numeralZh = "壹", -- 142
		actCode = "第壹章", -- 143
		titleZh = "序章 · 倒柜后", -- 144
		shortNameZh = "倒柜后", -- 145
		titleEn = "孤城护童", -- 146
		lineTag = "周戍", -- 147
		volumeTagZh = "上卷 · 孤城护童", -- 148
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 149
		skyMid = ____exports.rgba(16, 22, 34, 255), -- 150
		skyHorizon = ____exports.rgba(28, 38, 54, 255), -- 151
		farBuilding = ____exports.rgba(14, 18, 28, 255), -- 152
		midBuilding = ____exports.rgba(22, 26, 38, 255), -- 153
		fogBottom = ____exports.rgba(44, 58, 78, 62), -- 154
		groundTop = ____exports.rgba(46, 52, 62, 255), -- 155
		groundBody = ____exports.rgba(17, 20, 28, 255), -- 156
		groundRim = ____exports.rgba(154, 178, 188, 195), -- 157
		accent = ____exports.PALETTE.cyan, -- 158
		beamColor = ____exports.rgba(140, 168, 184, 34), -- 159
		ambient = "ash", -- 160
		showSearchlights = false, -- 161
		showTowerBeacon = false, -- 162
		showMoon = true, -- 163
		moonXFrac = 0.78, -- 164
		moonYFrac = 0.78, -- 165
		defaultZoom = 1.12, -- 166
		introWhisper = "城破前夜，月光斜漏旧仓。她在倒塌的柜子后面。" -- 167
	}, -- 167
	street = { -- 169
		key = "street", -- 170
		numeralZh = "贰", -- 171
		actCode = "第贰章", -- 172
		titleZh = "街道 · 封锁线", -- 173
		shortNameZh = "封锁线", -- 174
		titleEn = "孤城护童", -- 175
		lineTag = "周戍", -- 176
		volumeTagZh = "上卷 · 孤城护童", -- 177
		skyTop = ____exports.rgba(10, 12, 20, 255), -- 178
		skyMid = ____exports.rgba(20, 24, 36, 255), -- 179
		skyHorizon = ____exports.rgba(38, 36, 48, 255), -- 180
		farBuilding = ____exports.rgba(16, 19, 28, 255), -- 181
		midBuilding = ____exports.rgba(24, 27, 38, 255), -- 182
		fogBottom = ____exports.rgba(66, 54, 68, 64), -- 183
		groundTop = ____exports.rgba(48, 52, 60, 255), -- 184
		groundBody = ____exports.rgba(18, 20, 28, 255), -- 185
		groundRim = ____exports.rgba(154, 178, 188, 190), -- 186
		accent = ____exports.PALETTE.cyan, -- 187
		beamColor = ____exports.rgba(148, 170, 184, 34), -- 188
		ambient = "ash", -- 189
		showSearchlights = false, -- 190
		showTowerBeacon = false, -- 191
		showMoon = true, -- 192
		moonXFrac = 0.82, -- 193
		moonYFrac = 0.8, -- 194
		defaultZoom = 1, -- 195
		introWhisper = "夜雾漫过长街，带她穿过火线，莫让枪声压住她的步子。" -- 196
	}, -- 196
	checkpoint = { -- 198
		key = "checkpoint", -- 199
		numeralZh = "叁", -- 200
		actCode = "第叁章", -- 201
		titleZh = "检查站 · 装卸台", -- 202
		shortNameZh = "装卸台", -- 203
		titleEn = "孤城护童", -- 204
		lineTag = "周戍", -- 205
		volumeTagZh = "上卷 · 孤城护童", -- 206
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 207
		skyMid = ____exports.rgba(18, 25, 38, 255), -- 208
		skyHorizon = ____exports.rgba(32, 44, 60, 255), -- 209
		farBuilding = ____exports.rgba(15, 21, 32, 255), -- 210
		midBuilding = ____exports.rgba(22, 30, 42, 255), -- 211
		fogBottom = ____exports.rgba(48, 68, 86, 58), -- 212
		groundTop = ____exports.rgba(46, 54, 64, 255), -- 213
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 214
		groundRim = ____exports.rgba(154, 178, 188, 200), -- 215
		accent = ____exports.PALETTE.cyan, -- 216
		beamColor = ____exports.rgba(140, 172, 188, 36), -- 217
		ambient = "ash", -- 218
		showSearchlights = false, -- 219
		showTowerBeacon = false, -- 220
		showMoon = true, -- 221
		moonXFrac = 0.74, -- 222
		moonYFrac = 0.82, -- 223
		defaultZoom = 1, -- 224
		introWhisper = "红布在夜风里轻晃，把板车推进装卸窝，城门才会放行。" -- 225
	}, -- 225
	gate = { -- 227
		key = "gate", -- 228
		numeralZh = "肆", -- 229
		actCode = "第肆章", -- 230
		titleZh = "城门 · 四十五秒", -- 231
		shortNameZh = "四十五秒", -- 232
		titleEn = "死守断后", -- 233
		lineTag = "周戍", -- 234
		volumeTagZh = "上卷 · 孤城护童", -- 235
		skyTop = ____exports.rgba(14, 10, 14, 255), -- 236
		skyMid = ____exports.rgba(28, 17, 22, 255), -- 237
		skyHorizon = ____exports.rgba(56, 28, 30, 255), -- 238
		farBuilding = ____exports.rgba(20, 15, 20, 255), -- 239
		midBuilding = ____exports.rgba(30, 21, 26, 255), -- 240
		fogBottom = ____exports.rgba(118, 42, 42, 62), -- 241
		groundTop = ____exports.rgba(54, 48, 52, 255), -- 242
		groundBody = ____exports.rgba(18, 16, 21, 255), -- 243
		groundRim = ____exports.rgba(188, 68, 64, 195), -- 244
		accent = ____exports.PALETTE.rouge, -- 245
		beamColor = ____exports.rgba(196, 76, 62, 38), -- 246
		ambient = "ash", -- 247
		showSearchlights = false, -- 248
		showTowerBeacon = false, -- 249
		showMoon = true, -- 250
		moonXFrac = 0.22, -- 251
		moonYFrac = 0.8, -- 252
		defaultZoom = 0.92, -- 253
		introWhisper = "把她送到门洞，自己留下来，守住绞盘最后的四十五秒。" -- 254
	}, -- 254
	outside = { -- 256
		key = "outside", -- 257
		numeralZh = "伍", -- 258
		actCode = "第伍章", -- 259
		titleZh = "城墙外 · 拱与红布", -- 260
		shortNameZh = "拱与红布", -- 261
		titleEn = "独赴北塔", -- 262
		lineTag = "小满", -- 263
		volumeTagZh = "下卷 · 独赴北塔", -- 264
		skyTop = ____exports.rgba(9, 12, 20, 255), -- 265
		skyMid = ____exports.rgba(16, 24, 38, 255), -- 266
		skyHorizon = ____exports.rgba(30, 42, 60, 255), -- 267
		farBuilding = ____exports.rgba(14, 19, 30, 255), -- 268
		midBuilding = ____exports.rgba(20, 28, 42, 255), -- 269
		fogBottom = ____exports.rgba(48, 64, 88, 58), -- 270
		groundTop = ____exports.rgba(48, 54, 64, 255), -- 271
		groundBody = ____exports.rgba(16, 20, 28, 255), -- 272
		groundRim = ____exports.rgba(184, 176, 162, 185), -- 273
		accent = ____exports.PALETTE.amber, -- 274
		beamColor = ____exports.rgba(176, 166, 146, 28), -- 275
		ambient = "drizzle", -- 276
		showSearchlights = false, -- 277
		showTowerBeacon = true, -- 278
		showMoon = true, -- 279
		moonXFrac = 0.68, -- 280
		moonYFrac = 0.82, -- 281
		defaultZoom = 0.96, -- 282
		introWhisper = "数到二十，门后再无应声。拉开车辙，伏身穿过石拱。" -- 283
	}, -- 283
	village = { -- 285
		key = "village", -- 286
		numeralZh = "陆", -- 287
		actCode = "第陆章", -- 288
		titleZh = "废弃村庄 · 砖地一响", -- 289
		shortNameZh = "砖地一响", -- 290
		titleEn = "独赴北塔", -- 291
		lineTag = "小满", -- 292
		volumeTagZh = "下卷 · 独赴北塔", -- 293
		skyTop = ____exports.rgba(10, 12, 18, 255), -- 294
		skyMid = ____exports.rgba(18, 23, 33, 255), -- 295
		skyHorizon = ____exports.rgba(36, 40, 50, 255), -- 296
		farBuilding = ____exports.rgba(15, 19, 26, 255), -- 297
		midBuilding = ____exports.rgba(24, 28, 36, 255), -- 298
		fogBottom = ____exports.rgba(74, 68, 60, 54), -- 299
		groundTop = ____exports.rgba(54, 54, 58, 255), -- 300
		groundBody = ____exports.rgba(18, 20, 25, 255), -- 301
		groundRim = ____exports.rgba(202, 184, 152, 185), -- 302
		accent = ____exports.PALETTE.amber, -- 303
		beamColor = ____exports.rgba(212, 174, 118, 24), -- 304
		ambient = "drizzle", -- 305
		showSearchlights = false, -- 306
		showTowerBeacon = true, -- 307
		showMoon = true, -- 308
		moonXFrac = 0.78, -- 309
		moonYFrac = 0.82, -- 310
		defaultZoom = 1, -- 311
		introWhisper = "残垣旧院里有拾荒者游荡。掷瓶引响，趁隙潜过案底。" -- 312
	}, -- 312
	forest = { -- 314
		key = "forest", -- 315
		numeralZh = "柒", -- 316
		actCode = "第柒章", -- 317
		titleZh = "北塔森林 · 听风辨步", -- 318
		shortNameZh = "听风辨步", -- 319
		titleEn = "独赴北塔", -- 320
		lineTag = "小满", -- 321
		volumeTagZh = "下卷 · 独赴北塔", -- 322
		skyTop = ____exports.rgba(8, 12, 16, 255), -- 323
		skyMid = ____exports.rgba(14, 24, 28, 255), -- 324
		skyHorizon = ____exports.rgba(26, 44, 46, 255), -- 325
		farBuilding = ____exports.rgba(12, 20, 24, 255), -- 326
		midBuilding = ____exports.rgba(18, 30, 32, 255), -- 327
		fogBottom = ____exports.rgba(52, 86, 82, 56), -- 328
		groundTop = ____exports.rgba(36, 52, 48, 255), -- 329
		groundBody = ____exports.rgba(14, 22, 22, 255), -- 330
		groundRim = ____exports.rgba(152, 178, 152, 190), -- 331
		accent = ____exports.PALETTE.emerald, -- 332
		beamColor = ____exports.rgba(148, 178, 146, 24), -- 333
		ambient = "spores", -- 334
		showSearchlights = false, -- 335
		showTowerBeacon = true, -- 336
		showMoon = true, -- 337
		moonXFrac = 0.72, -- 338
		moonYFrac = 0.84, -- 339
		defaultZoom = 1, -- 340
		introWhisper = "松涛起落，猎犬先人闻步。屏息伏于草影，向北塔行去。" -- 341
	}, -- 341
	tower = { -- 343
		key = "tower", -- 344
		numeralZh = "捌", -- 345
		actCode = "终章", -- 346
		titleZh = "北塔 · 最后一行", -- 347
		shortNameZh = "最后一行", -- 348
		titleEn = "归途尾声", -- 349
		lineTag = "尾声", -- 350
		volumeTagZh = "终章 · 北塔守望", -- 351
		skyTop = ____exports.rgba(10, 13, 21, 255), -- 352
		skyMid = ____exports.rgba(20, 28, 44, 255), -- 353
		skyHorizon = ____exports.rgba(48, 52, 66, 255), -- 354
		farBuilding = ____exports.rgba(16, 21, 32, 255), -- 355
		midBuilding = ____exports.rgba(24, 30, 44, 255), -- 356
		fogBottom = ____exports.rgba(214, 186, 146, 44), -- 357
		groundTop = ____exports.rgba(60, 60, 66, 255), -- 358
		groundBody = ____exports.rgba(19, 21, 28, 255), -- 359
		groundRim = ____exports.rgba(232, 214, 182, 210), -- 360
		accent = ____exports.PALETTE.amber, -- 361
		beamColor = ____exports.rgba(236, 198, 132, 40), -- 362
		ambient = "motes", -- 363
		showSearchlights = false, -- 364
		showTowerBeacon = true, -- 365
		showMoon = true, -- 366
		moonXFrac = 0.24, -- 367
		moonYFrac = 0.8, -- 368
		defaultZoom = 1.12, -- 369
		introWhisper = "孤灯犹明。走到北塔门前，照他教过的节奏，轻敲两下。" -- 370
	} -- 370
} -- 370
local ROOM_VARIANTS = { -- 374
	["s1-crossroad"] = { -- 375
		"street", -- 375
		"街道 · 十字街", -- 375
		"十字街", -- 375
		"井背可退，转角火器压近。从街口选外街或布行继续北上。", -- 375
		"贰", -- 375
		"第贰章" -- 375
	}, -- 375
	["s2-drygoods"] = { -- 376
		"street", -- 376
		"街道 · 布行", -- 376
		"布行", -- 376
		"外街短跨或入布行放窗板，两路穿过敌阵同通牌楼。", -- 376
		"贰", -- 376
		"第贰章" -- 376
	}, -- 376
	["s3-archway"] = { -- 377
		"street", -- 377
		"街道 · 牌楼后巷", -- 377
		"牌楼后巷", -- 377
		"登装卸坡探清火线，或沿墙脚绕行，候检门前再汇合。", -- 377
		"贰", -- 377
		"第贰章" -- 377
	}, -- 377
	["c1-yard"] = { -- 378
		"checkpoint", -- 378
		"检查站 · 候检院", -- 378
		"候检院", -- 378
		"队栏与查验台层层挡路，转到门背抬起横锁方能带她过院。", -- 378
		"叁", -- 378
		"第叁章" -- 378
	}, -- 378
	["c2-granary"] = { -- 379
		"checkpoint", -- 379
		"检查站 · 军粮棚", -- 379
		"军粮棚", -- 379
		"先落木帘或架残盾，将红布车推入轮窝并抬起连杆锁。", -- 379
		"叁", -- 379
		"第叁章" -- 379
	}, -- 379
	gatepath = { -- 380
		"outside", -- 380
		"城外 · 兄妹同行", -- 380
		"兄妹同行", -- 380
		"城门未隔断二人。牵起她的手，沿平路往高石阶走去。", -- 380
		"伍", -- 380
		"第伍章" -- 380
	}, -- 380
	escort1 = { -- 381
		"outside", -- 381
		"城外巷路 · 第一段护送", -- 381
		"护送巷路", -- 381
		"背起受伤的小满穿过巷口火线，借慢时换弹突出重围。", -- 381
		"伍", -- 381
		"第伍章" -- 381
	}, -- 381
	escort2 = { -- 382
		"checkpoint", -- 382
		"粮棚 · 第二段取材", -- 382
		"粮棚取材", -- 382
		"高低两路暗藏木纹筹与铃纹筹，沿途收齐好在工台改制。", -- 382
		"陆", -- 382
		"第陆章" -- 382
	}, -- 382
	escort3 = { -- 383
		"forest", -- 383
		"山腰工台 · 第三段改制", -- 383
		"山腰工台", -- 383
		"暂放小满，择引路灯铳或回声铳改制试射，再背起前行。", -- 383
		"陆", -- 383
		"第陆章" -- 383
	}, -- 383
	escort4 = { -- 384
		"forest", -- 384
		"山道 · 第四段脱身", -- 384
		"山道脱身", -- 384
		"窄道追兵紧逼，在慢时连线与伏身翻滚间夺出一条生路。", -- 384
		"柒", -- 384
		"第柒章" -- 384
	}, -- 384
	escort5 = { -- 385
		"tower", -- 385
		"塔前山道 · 第五段", -- 385
		"塔前山道", -- 385
		"北塔孤灯已在前方。带着改制火铳护她走完最后一段山路。", -- 385
		"柒", -- 385
		"第柒章" -- 385
	}, -- 385
	museum = { -- 386
		"prologue", -- 386
		"博物馆 · 西厅", -- 386
		"西厅", -- 386
		"玻璃柜静立晨光之中，那枚青布针套仍在等待回响。", -- 386
		"番", -- 386
		"番外" -- 386
	} -- 386
} -- 386
for key in pairs(ROOM_VARIANTS) do -- 389
	local backdropKey, titleZh, shortNameZh, introWhisper, numZh, actZh = table.unpack(ROOM_VARIANTS[key], 1, 6) -- 390
	local base = ____exports.ROOM_THEMES[backdropKey] -- 391
	local soldierPath = key == "gatepath" or __TS__StringStartsWith(key, "escort") -- 392
	____exports.ROOM_THEMES[key] = __TS__ObjectAssign({}, base, { -- 393
		key = key, -- 394
		backdropKey = backdropKey, -- 394
		titleZh = titleZh, -- 394
		shortNameZh = shortNameZh, -- 394
		introWhisper = introWhisper, -- 394
		numeralZh = numZh or (soldierPath and ____exports.ROOM_THEMES.outside.numeralZh or base.numeralZh), -- 395
		actCode = actZh or (soldierPath and ____exports.ROOM_THEMES.outside.actCode or base.actCode), -- 396
		lineTag = soldierPath and "周戍" or base.lineTag, -- 397
		volumeTagZh = soldierPath and "周戍线 · 护送" or base.volumeTagZh -- 398
	}) -- 398
end -- 398
function ____exports.themeOf(key) -- 402
	local t = ____exports.ROOM_THEMES[key] -- 403
	return t ~= nil and t or ____exports.ROOM_THEMES.prologue -- 404
end -- 402
local UPPER_DIGITS = { -- 407
	"零", -- 407
	"壹", -- 407
	"贰", -- 407
	"叁", -- 407
	"肆", -- 407
	"伍", -- 407
	"陆", -- 407
	"柒", -- 407
	"捌", -- 407
	"玖" -- 407
} -- 407
--- 将 0..100 整数转为传统中文大写数字（零、壹..拾、拾壹..玖拾玖、壹佰）
function ____exports.toChineseUpper(n) -- 410
	local v = math.max( -- 411
		0, -- 411
		math.min( -- 411
			100, -- 411
			math.floor(n) -- 411
		) -- 411
	) -- 411
	if v == 100 then -- 411
		return "壹佰" -- 413
	end -- 413
	if v < 10 then -- 413
		return UPPER_DIGITS[v + 1] -- 416
	end -- 416
	local tens = math.floor(v / 10) -- 418
	local ones = v % 10 -- 419
	local prefix = tens == 1 and "拾" or UPPER_DIGITS[tens + 1] .. "拾" -- 420
	return ones == 0 and prefix or prefix .. UPPER_DIGITS[ones + 1] -- 421
end -- 410
--- 顶点渐变四边形
function ____exports.fillGradQuad(draw, x0, y0, c00, x1, y1, c10, x2, y2, c11, x3, y3, c01) -- 425
	local p0 = Vec2(x0, y0) -- 432
	local p1 = Vec2(x1, y1) -- 433
	local p2 = Vec2(x2, y2) -- 434
	local p3 = Vec2(x3, y3) -- 435
	draw:drawVertices({ -- 436
		{p0, c00}, -- 437
		{p1, c10}, -- 437
		{p2, c11}, -- 437
		{p0, c00}, -- 438
		{p2, c11}, -- 438
		{p3, c01} -- 438
	}) -- 438
end -- 425
--- 竖直方向线性渐变矩形
function ____exports.fillVGradRect(draw, x, y, w, h, bottomCol, topCol) -- 443
	____exports.fillGradQuad( -- 448
		draw, -- 449
		x, -- 450
		y, -- 450
		bottomCol, -- 450
		x + w, -- 451
		y, -- 451
		bottomCol, -- 451
		x + w, -- 452
		y + h, -- 452
		topCol, -- 452
		x, -- 453
		y + h, -- 453
		topCol -- 453
	) -- 453
end -- 443
--- 水平方向线性渐变矩形
function ____exports.fillHGradRect(draw, x, y, w, h, leftCol, rightCol) -- 458
	____exports.fillGradQuad( -- 463
		draw, -- 464
		x, -- 465
		y, -- 465
		leftCol, -- 465
		x + w, -- 466
		y, -- 466
		rightCol, -- 466
		x + w, -- 467
		y + h, -- 467
		rightCol, -- 467
		x, -- 468
		y + h, -- 468
		leftCol -- 468
	) -- 468
end -- 458
--- 径向柔和光晕
function ____exports.fillRadialGlow(draw, cx, cy, rx, ry, innerCol, outerCol, segments) -- 473
	if segments == nil then -- 473
		segments = 18 -- 477
	end -- 477
	if rx <= 0.5 or ry <= 0.5 then -- 477
		return -- 480
	end -- 480
	local center = Vec2(cx, cy) -- 482
	local verts = {} -- 483
	local step = math.pi * 2 / segments -- 484
	local i = 0 -- 485
	do -- 485
		i = 0 -- 486
		while i < segments do -- 486
			local a0 = i * step -- 487
			local a1 = (i + 1) * step -- 488
			verts[#verts + 1] = {center, innerCol} -- 489
			verts[#verts + 1] = { -- 490
				Vec2( -- 490
					cx + math.cos(a0) * rx, -- 490
					cy + math.sin(a0) * ry -- 490
				), -- 490
				outerCol -- 490
			} -- 490
			verts[#verts + 1] = { -- 491
				Vec2( -- 491
					cx + math.cos(a1) * rx, -- 491
					cy + math.sin(a1) * ry -- 491
				), -- 491
				outerCol -- 491
			} -- 491
			i = i + 1 -- 486
		end -- 486
	end -- 486
	draw:drawVertices(verts) -- 493
end -- 473
--- 烟黛渐变轻幕（《饿殍》柔边字幕幕 / 顶部轻带，四周自然消融无硬框）
function ____exports.drawSilkVeil(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 499
	if opacity == nil then -- 499
		opacity = 0.84 -- 504
	end -- 504
	if layer == nil then -- 504
		layer = -1 -- 505
	end -- 505
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 505
		return -- 508
	end -- 508
	if art:tryPlace( -- 508
		"ink_veil_strip", -- 510
		id, -- 510
		cx, -- 510
		cy, -- 510
		w, -- 510
		h, -- 510
		{ -- 510
			color = ____exports.toColor(tint, 255), -- 510
			opacity = opacity, -- 510
			layer = layer -- 510
		} -- 510
	) then -- 510
		return -- 511
	end -- 511
	local x = cx - w * 0.5 -- 513
	local y = cy - h * 0.5 -- 514
	local fadeW = w * 0.22 -- 515
	local midCol = ____exports.toColor( -- 516
		tint, -- 516
		math.floor(225 * opacity + 0.5) -- 516
	) -- 516
	local zeroCol = Color(tint.r, tint.g, tint.b, 0) -- 517
	____exports.fillHGradRect( -- 518
		fallbackDraw, -- 518
		x, -- 518
		y, -- 518
		fadeW, -- 518
		h, -- 518
		zeroCol, -- 518
		midCol -- 518
	) -- 518
	fallbackDraw:drawRect( -- 519
		Rect( -- 519
			x + fadeW, -- 519
			y, -- 519
			math.max(0, w - fadeW * 2), -- 519
			h -- 519
		), -- 519
		midCol -- 519
	) -- 519
	____exports.fillHGradRect( -- 520
		fallbackDraw, -- 520
		x + w - fadeW, -- 520
		y, -- 520
		fadeW, -- 520
		h, -- 520
		midCol, -- 520
		zeroCol -- 520
	) -- 520
end -- 499
--- 水袖游丝飞白飘带（用于菜单选中态轻拂高光，柔美弧线非粗重墨块）
function ____exports.drawSilkRibbon(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 526
	if opacity == nil then -- 526
		opacity = 0.65 -- 531
	end -- 531
	if layer == nil then -- 531
		layer = 0 -- 532
	end -- 532
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 532
		return -- 535
	end -- 535
	if art:tryPlace( -- 535
		"ink_ribbon_sweep", -- 537
		id, -- 537
		cx, -- 537
		cy, -- 537
		w, -- 537
		h, -- 537
		{ -- 537
			color = ____exports.toColor(tint, 255), -- 537
			opacity = opacity, -- 537
			layer = layer -- 537
		} -- 537
	) then -- 537
		return -- 538
	end -- 538
	local x = cx - w * 0.5 -- 540
	local y = cy - h * 0.5 -- 541
	____exports.fillHGradRect( -- 542
		fallbackDraw, -- 542
		x, -- 542
		y, -- 542
		w * 0.65, -- 542
		h, -- 542
		____exports.toColor( -- 542
			tint, -- 542
			math.floor(160 * opacity + 0.5) -- 542
		), -- 542
		Color(tint.r, tint.g, tint.b, 0) -- 542
	) -- 542
end -- 526
--- 婉转烟岚流云曲线（赋予标题、驿道长卷、章名以轻盈流动感）
function ____exports.drawMistCurve(art, id, cx, cy, w, h, tint, opacity, layer, facing) -- 548
	if opacity == nil then -- 548
		opacity = 0.36 -- 552
	end -- 552
	if layer == nil then -- 552
		layer = -1 -- 553
	end -- 553
	if facing == nil then -- 553
		facing = 1 -- 554
	end -- 554
	if w <= 4 or h <= 4 or opacity <= 0.01 then -- 554
		return -- 557
	end -- 557
	art:tryPlace( -- 559
		"ink_mist_curve", -- 559
		id, -- 559
		cx, -- 559
		cy, -- 559
		w, -- 559
		h, -- 559
		{ -- 559
			color = ____exports.toColor(tint, 255), -- 559
			opacity = opacity, -- 559
			layer = layer, -- 559
			facing = facing -- 559
		} -- 559
	) -- 559
end -- 548
--- 霜月游丝细线（可选在中点缀一枚极精巧的宋明海棠菱花微结）
function ____exports.drawHairline(overlayDraw, art, id, cx, cy, w, col, alpha, withKnot, layer) -- 565
	if alpha == nil then -- 565
		alpha = 0.72 -- 570
	end -- 570
	if withKnot == nil then -- 570
		withKnot = false -- 571
	end -- 571
	if layer == nil then -- 571
		layer = 2 -- 572
	end -- 572
	if w <= 4 or alpha <= 0.01 then -- 572
		return -- 575
	end -- 575
	if not art:tryPlace( -- 575
		"ink_hairline", -- 577
		id, -- 577
		cx, -- 577
		cy, -- 577
		w, -- 577
		10, -- 577
		{ -- 577
			color = ____exports.toColor(col, 255), -- 577
			opacity = alpha, -- 577
			layer = layer -- 577
		} -- 577
	) then -- 577
		local half = w * 0.5 -- 578
		____exports.fillHGradRect( -- 579
			overlayDraw, -- 579
			cx - half, -- 579
			cy - 0.5, -- 579
			half, -- 579
			1, -- 579
			Color(col.r, col.g, col.b, 0), -- 579
			____exports.toColor(col, 190 * alpha) -- 579
		) -- 579
		____exports.fillHGradRect( -- 580
			overlayDraw, -- 580
			cx, -- 580
			cy - 0.5, -- 580
			half, -- 580
			1, -- 580
			____exports.toColor(col, 190 * alpha), -- 580
			Color(col.r, col.g, col.b, 0) -- 580
		) -- 580
	end -- 580
	if withKnot then -- 580
		art:tryPlace( -- 583
			"ink_knot_ornament", -- 583
			id .. "_knot", -- 583
			cx, -- 583
			cy, -- 583
			88, -- 583
			24, -- 583
			{ -- 583
				color = ____exports.toColor(col, 255), -- 583
				opacity = math.min(1, alpha * 1.15), -- 583
				layer = layer + 1 -- 583
			} -- 583
		) -- 583
	end -- 583
end -- 565
--- 宋明纤细海棠折角（取代笨重双线铁框与像素铜角，带留白呼吸感）
function ____exports.drawFiligreeCorners(overlayDraw, art, id, x, y, w, h, col, alpha, cornerSize, withHairBorder, layer) -- 590
	if alpha == nil then -- 590
		alpha = 0.78 -- 595
	end -- 595
	if cornerSize == nil then -- 595
		cornerSize = 34 -- 596
	end -- 596
	if withHairBorder == nil then -- 596
		withHairBorder = true -- 597
	end -- 597
	if layer == nil then -- 597
		layer = 2 -- 598
	end -- 598
	if alpha <= 0.01 then -- 598
		return -- 601
	end -- 601
	if withHairBorder then -- 601
		overlayDraw:drawRect( -- 604
			Rect(x, y, w, h), -- 604
			Color(0, 0, 0, 0), -- 604
			0.75, -- 604
			____exports.toColor(col, 78 * alpha) -- 604
		) -- 604
	end -- 604
	local half = cornerSize * 0.5 -- 606
	local c = ____exports.toColor(col, 255) -- 607
	local op = alpha -- 608
	art:tryPlace( -- 609
		"ink_corner_fine", -- 609
		id .. "_tl", -- 609
		x + half - 2, -- 609
		y + h - half + 2, -- 609
		cornerSize, -- 609
		cornerSize, -- 609
		{color = c, opacity = op, layer = layer} -- 609
	) -- 609
	art:tryPlace( -- 610
		"ink_corner_fine", -- 610
		id .. "_tr", -- 610
		x + w - half + 2, -- 610
		y + h - half + 2, -- 610
		cornerSize, -- 610
		cornerSize, -- 610
		{facing = -1, color = c, opacity = op, layer = layer} -- 610
	) -- 610
	art:tryPlace( -- 611
		"ink_corner_fine", -- 611
		id .. "_bl", -- 611
		x + half - 2, -- 611
		y + half - 2, -- 611
		cornerSize, -- 611
		cornerSize, -- 611
		{flipY = true, color = c, opacity = op, layer = layer} -- 611
	) -- 611
	art:tryPlace( -- 612
		"ink_corner_fine", -- 612
		id .. "_br", -- 612
		x + w - half + 2, -- 612
		y + half - 2, -- 612
		cornerSize, -- 612
		cornerSize, -- 612
		{ -- 612
			facing = -1, -- 612
			flipY = true, -- 612
			color = c, -- 612
			opacity = op, -- 612
			layer = layer -- 612
		} -- 612
	) -- 612
end -- 590
--- 文人孤印（全屏仅用于主标题落款与北塔登记簿落款，清瘦精致不泛滥）
function ____exports.drawLoneSeal(overlayDraw, art, texts, id, cx, cy, w, h, topChar, botChar, stampCol, textCol, alpha, layer) -- 618
	if alpha == nil then -- 618
		alpha = 0.94 -- 626
	end -- 626
	if layer == nil then -- 626
		layer = 4 -- 627
	end -- 627
	if alpha <= 0.01 then -- 627
		return -- 630
	end -- 630
	if not art:tryPlace( -- 630
		"ink_seal_slender", -- 632
		id, -- 632
		cx, -- 632
		cy, -- 632
		w, -- 632
		h, -- 632
		{ -- 632
			color = ____exports.toColor(stampCol, 255), -- 632
			opacity = alpha, -- 632
			layer = layer -- 632
		} -- 632
	) then -- 632
		overlayDraw:drawRect( -- 633
			Rect(cx - w * 0.42, cy - h * 0.44, w * 0.84, h * 0.88), -- 633
			____exports.toColor(stampCol, 225 * alpha) -- 633
		) -- 633
	end -- 633
	texts:put( -- 635
		"seal", -- 635
		topChar, -- 635
		cx, -- 635
		cy + h * 0.17, -- 635
		____exports.toColor(textCol), -- 635
		0.5, -- 635
		0.5, -- 635
		"Center", -- 635
		0, -- 635
		alpha, -- 635
		0 -- 635
	) -- 635
	texts:put( -- 636
		"seal", -- 636
		botChar, -- 636
		cx, -- 636
		cy - h * 0.18, -- 636
		____exports.toColor(textCol), -- 636
		0.5, -- 636
		0.5, -- 636
		"Center", -- 636
		0, -- 636
		alpha, -- 636
		0 -- 636
	) -- 636
end -- 618
--- 纤巧菱花花蕊点（替换笨重圆点与方印焦点）
function ____exports.drawBlossomDot(overlayDraw, art, id, cx, cy, size, col, alpha, layer) -- 640
	if alpha == nil then -- 640
		alpha = 0.92 -- 645
	end -- 645
	if layer == nil then -- 645
		layer = 4 -- 646
	end -- 646
	if alpha <= 0.01 then -- 646
		return -- 649
	end -- 649
	if not art:tryPlace( -- 649
		"ink_blossom_dot", -- 651
		id, -- 651
		cx, -- 651
		cy, -- 651
		size, -- 651
		size, -- 651
		{ -- 651
			color = ____exports.toColor(col, 255), -- 651
			opacity = alpha, -- 651
			layer = layer -- 651
		} -- 651
	) then -- 651
		____exports.drawDiamond( -- 652
			overlayDraw, -- 652
			cx, -- 652
			cy, -- 652
			size * 0.35, -- 652
			size * 0.35, -- 652
			____exports.toColor(col, 230 * alpha) -- 652
		) -- 652
	end -- 652
end -- 640
--- 清雅霜银发丝微框键位（去土黄、去厚底）
function ____exports.drawSilkKeycap(overlayDraw, texts, x, y, w, h, keyText, accent, alpha, urgent) -- 657
	if alpha == nil then -- 657
		alpha = 1 -- 663
	end -- 663
	if urgent == nil then -- 663
		urgent = false -- 664
	end -- 664
	local bg = urgent and ____exports.toColor(____exports.PALETTE.rougeSoft, 200 * alpha) or Color( -- 666
		14, -- 666
		17, -- 666
		25, -- 666
		math.floor(186 * alpha + 0.5) -- 666
	) -- 666
	local bd = ____exports.toColor(urgent and ____exports.PALETTE.crimsonCore or accent, (urgent and 225 or 165) * alpha) -- 667
	overlayDraw:drawRect( -- 668
		Rect(x, y, w, h), -- 668
		bg, -- 668
		0.85, -- 668
		bd -- 668
	) -- 668
	local tc = urgent and ____exports.toColor(____exports.PALETTE.sealText) or ____exports.toColor(____exports.PALETTE.textBright) -- 669
	texts:put( -- 670
		"xs", -- 670
		keyText, -- 670
		x + w * 0.5, -- 670
		y + h * 0.5, -- 670
		tc, -- 670
		0.5, -- 670
		0.5, -- 670
		"Center", -- 670
		0.5, -- 670
		alpha, -- 670
		urgent and 0 or 0.08 -- 670
	) -- 670
end -- 657
--- 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述清雅水墨原语
function ____exports.fillSkewRect(draw, x, y, w, h, skew, fill, borderW, borderCol) -- 674
	if borderW == nil then -- 674
		borderW = 0 -- 677
	end -- 677
	if w <= 0 or h <= 0 then -- 677
		return -- 680
	end -- 680
	local pts = { -- 682
		Vec2(x, y), -- 683
		Vec2(x + w, y), -- 684
		Vec2(x + w + skew, y + h), -- 685
		Vec2(x + skew, y + h) -- 686
	} -- 686
	if borderW > 0 and borderCol ~= nil then -- 686
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 689
	else -- 689
		draw:drawPolygon(pts, fill) -- 691
	end -- 691
end -- 674
function ____exports.fillChamferBox(draw, x, y, w, h, cut, fill, borderW, borderCol) -- 695
	if borderW == nil then -- 695
		borderW = 0 -- 698
	end -- 698
	local c = math.min(cut, w * 0.3, h * 0.3) -- 700
	local pts = { -- 701
		Vec2(x, y), -- 702
		Vec2(x + w - c, y), -- 703
		Vec2(x + w, y + c), -- 704
		Vec2(x + w, y + h), -- 705
		Vec2(x + c, y + h), -- 706
		Vec2(x, y + h - c) -- 707
	} -- 707
	if borderW > 0 and borderCol ~= nil then -- 707
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 710
	else -- 710
		draw:drawPolygon(pts, fill) -- 712
	end -- 712
end -- 695
function ____exports.visualTextWidth(text, fontSize) -- 734
	local units = 0 -- 735
	local i = 0 -- 736
	do -- 736
		i = 0 -- 737
		while i < #text do -- 737
			local b = __TS__StringCharCodeAt(text, i) -- 738
			if b < 128 then -- 738
				units = units + 0.56 -- 740
			elseif b >= 192 then -- 740
				units = units + 1.02 -- 742
			end -- 742
			i = i + 1 -- 737
		end -- 737
	end -- 737
	return units * fontSize -- 745
end -- 734
function ____exports.drawHazardStripes(draw, x, y, w, h, pitch, col) -- 748
	local sw = pitch * 0.45 -- 753
	local cur = x - h -- 754
	while cur < x + w do -- 754
		local x0 = math.max(x, cur) -- 756
		local x1 = math.min(x + w, cur + sw) -- 757
		local tx0 = math.max(x, cur + h) -- 758
		local tx1 = math.min(x + w, cur + h + sw) -- 759
		if x1 > x0 and tx1 > tx0 then -- 759
			draw:drawPolygon( -- 761
				{ -- 761
					Vec2(x0, y), -- 762
					Vec2(x1, y), -- 763
					Vec2(tx1, y + h), -- 764
					Vec2(tx0, y + h) -- 765
				}, -- 765
				col -- 766
			) -- 766
		end -- 766
		cur = cur + pitch -- 768
	end -- 768
end -- 748
return ____exports -- 748