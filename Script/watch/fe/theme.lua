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
function ____exports.drawDiamond(draw, cx, cy, rx, ry, fill, borderW, borderCol) -- 732
	if borderW == nil then -- 732
		borderW = 0 -- 735
	end -- 735
	local pts = { -- 737
		Vec2(cx, cy + ry), -- 738
		Vec2(cx + rx, cy), -- 739
		Vec2(cx, cy - ry), -- 740
		Vec2(cx - rx, cy) -- 741
	} -- 741
	if borderW > 0 and borderCol ~= nil then -- 741
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 744
	else -- 744
		draw:drawPolygon(pts, fill) -- 746
	end -- 746
end -- 732
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
local VARIANT_BACKDROPS = { -- 389
	["s1-crossroad"] = "crossroad_drygoods", -- 390
	["s2-drygoods"] = "crossroad_drygoods", -- 391
	["s3-archway"] = "archway_yard", -- 392
	["c1-yard"] = "archway_yard", -- 393
	["c2-granary"] = "granary", -- 394
	gatepath = "escort_ridge", -- 395
	escort1 = "escort_ridge", -- 396
	escort2 = "granary", -- 397
	escort3 = "forest", -- 398
	escort4 = "escort_ridge", -- 399
	escort5 = "tower", -- 400
	museum = "museum" -- 401
} -- 401
for key in pairs(ROOM_VARIANTS) do -- 404
	local baseKey, titleZh, shortNameZh, introWhisper, numZh, actZh = table.unpack(ROOM_VARIANTS[key], 1, 6) -- 405
	local base = ____exports.ROOM_THEMES[baseKey] -- 406
	local backdropKey = VARIANT_BACKDROPS[key] or baseKey -- 407
	local soldierPath = key == "gatepath" or __TS__StringStartsWith(key, "escort") -- 408
	____exports.ROOM_THEMES[key] = __TS__ObjectAssign({}, base, { -- 409
		key = key, -- 410
		backdropKey = backdropKey, -- 410
		titleZh = titleZh, -- 410
		shortNameZh = shortNameZh, -- 410
		introWhisper = introWhisper, -- 410
		numeralZh = numZh or (soldierPath and ____exports.ROOM_THEMES.outside.numeralZh or base.numeralZh), -- 411
		actCode = actZh or (soldierPath and ____exports.ROOM_THEMES.outside.actCode or base.actCode), -- 412
		lineTag = soldierPath and "周戍" or base.lineTag, -- 413
		volumeTagZh = soldierPath and "周戍线 · 护送" or base.volumeTagZh -- 414
	}) -- 414
end -- 414
function ____exports.themeOf(key) -- 418
	local t = ____exports.ROOM_THEMES[key] -- 419
	return t ~= nil and t or ____exports.ROOM_THEMES.prologue -- 420
end -- 418
local UPPER_DIGITS = { -- 423
	"零", -- 423
	"壹", -- 423
	"贰", -- 423
	"叁", -- 423
	"肆", -- 423
	"伍", -- 423
	"陆", -- 423
	"柒", -- 423
	"捌", -- 423
	"玖" -- 423
} -- 423
--- 将 0..100 整数转为传统中文大写数字（零、壹..拾、拾壹..玖拾玖、壹佰）
function ____exports.toChineseUpper(n) -- 426
	local v = math.max( -- 427
		0, -- 427
		math.min( -- 427
			100, -- 427
			math.floor(n) -- 427
		) -- 427
	) -- 427
	if v == 100 then -- 427
		return "壹佰" -- 429
	end -- 429
	if v < 10 then -- 429
		return UPPER_DIGITS[v + 1] -- 432
	end -- 432
	local tens = math.floor(v / 10) -- 434
	local ones = v % 10 -- 435
	local prefix = tens == 1 and "拾" or UPPER_DIGITS[tens + 1] .. "拾" -- 436
	return ones == 0 and prefix or prefix .. UPPER_DIGITS[ones + 1] -- 437
end -- 426
--- 顶点渐变四边形
function ____exports.fillGradQuad(draw, x0, y0, c00, x1, y1, c10, x2, y2, c11, x3, y3, c01) -- 441
	local p0 = Vec2(x0, y0) -- 448
	local p1 = Vec2(x1, y1) -- 449
	local p2 = Vec2(x2, y2) -- 450
	local p3 = Vec2(x3, y3) -- 451
	draw:drawVertices({ -- 452
		{p0, c00}, -- 453
		{p1, c10}, -- 453
		{p2, c11}, -- 453
		{p0, c00}, -- 454
		{p2, c11}, -- 454
		{p3, c01} -- 454
	}) -- 454
end -- 441
--- 竖直方向线性渐变矩形
function ____exports.fillVGradRect(draw, x, y, w, h, bottomCol, topCol) -- 459
	____exports.fillGradQuad( -- 464
		draw, -- 465
		x, -- 466
		y, -- 466
		bottomCol, -- 466
		x + w, -- 467
		y, -- 467
		bottomCol, -- 467
		x + w, -- 468
		y + h, -- 468
		topCol, -- 468
		x, -- 469
		y + h, -- 469
		topCol -- 469
	) -- 469
end -- 459
--- 水平方向线性渐变矩形
function ____exports.fillHGradRect(draw, x, y, w, h, leftCol, rightCol) -- 474
	____exports.fillGradQuad( -- 479
		draw, -- 480
		x, -- 481
		y, -- 481
		leftCol, -- 481
		x + w, -- 482
		y, -- 482
		rightCol, -- 482
		x + w, -- 483
		y + h, -- 483
		rightCol, -- 483
		x, -- 484
		y + h, -- 484
		leftCol -- 484
	) -- 484
end -- 474
--- 径向柔和光晕
function ____exports.fillRadialGlow(draw, cx, cy, rx, ry, innerCol, outerCol, segments) -- 489
	if segments == nil then -- 489
		segments = 18 -- 493
	end -- 493
	if rx <= 0.5 or ry <= 0.5 then -- 493
		return -- 496
	end -- 496
	local center = Vec2(cx, cy) -- 498
	local verts = {} -- 499
	local step = math.pi * 2 / segments -- 500
	local i = 0 -- 501
	do -- 501
		i = 0 -- 502
		while i < segments do -- 502
			local a0 = i * step -- 503
			local a1 = (i + 1) * step -- 504
			verts[#verts + 1] = {center, innerCol} -- 505
			verts[#verts + 1] = { -- 506
				Vec2( -- 506
					cx + math.cos(a0) * rx, -- 506
					cy + math.sin(a0) * ry -- 506
				), -- 506
				outerCol -- 506
			} -- 506
			verts[#verts + 1] = { -- 507
				Vec2( -- 507
					cx + math.cos(a1) * rx, -- 507
					cy + math.sin(a1) * ry -- 507
				), -- 507
				outerCol -- 507
			} -- 507
			i = i + 1 -- 502
		end -- 502
	end -- 502
	draw:drawVertices(verts) -- 509
end -- 489
--- 烟黛渐变轻幕（《饿殍》柔边字幕幕 / 顶部轻带，四周自然消融无硬框）
function ____exports.drawSilkVeil(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 515
	if opacity == nil then -- 515
		opacity = 0.84 -- 520
	end -- 520
	if layer == nil then -- 520
		layer = -1 -- 521
	end -- 521
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 521
		return -- 524
	end -- 524
	if art:tryPlace( -- 524
		"ink_veil_strip", -- 526
		id, -- 526
		cx, -- 526
		cy, -- 526
		w, -- 526
		h, -- 526
		{ -- 526
			color = ____exports.toColor(tint, 255), -- 526
			opacity = opacity, -- 526
			layer = layer -- 526
		} -- 526
	) then -- 526
		return -- 527
	end -- 527
	local x = cx - w * 0.5 -- 529
	local y = cy - h * 0.5 -- 530
	local fadeW = w * 0.22 -- 531
	local midCol = ____exports.toColor( -- 532
		tint, -- 532
		math.floor(225 * opacity + 0.5) -- 532
	) -- 532
	local zeroCol = Color(tint.r, tint.g, tint.b, 0) -- 533
	____exports.fillHGradRect( -- 534
		fallbackDraw, -- 534
		x, -- 534
		y, -- 534
		fadeW, -- 534
		h, -- 534
		zeroCol, -- 534
		midCol -- 534
	) -- 534
	fallbackDraw:drawRect( -- 535
		Rect( -- 535
			x + fadeW, -- 535
			y, -- 535
			math.max(0, w - fadeW * 2), -- 535
			h -- 535
		), -- 535
		midCol -- 535
	) -- 535
	____exports.fillHGradRect( -- 536
		fallbackDraw, -- 536
		x + w - fadeW, -- 536
		y, -- 536
		fadeW, -- 536
		h, -- 536
		midCol, -- 536
		zeroCol -- 536
	) -- 536
end -- 515
--- 水袖游丝飞白飘带（用于菜单选中态轻拂高光，柔美弧线非粗重墨块）
function ____exports.drawSilkRibbon(fallbackDraw, art, id, cx, cy, w, h, tint, opacity, layer) -- 542
	if opacity == nil then -- 542
		opacity = 0.65 -- 547
	end -- 547
	if layer == nil then -- 547
		layer = 0 -- 548
	end -- 548
	if w <= 2 or h <= 2 or opacity <= 0.01 then -- 548
		return -- 551
	end -- 551
	if art:tryPlace( -- 551
		"ink_ribbon_sweep", -- 553
		id, -- 553
		cx, -- 553
		cy, -- 553
		w, -- 553
		h, -- 553
		{ -- 553
			color = ____exports.toColor(tint, 255), -- 553
			opacity = opacity, -- 553
			layer = layer -- 553
		} -- 553
	) then -- 553
		return -- 554
	end -- 554
	local x = cx - w * 0.5 -- 556
	local y = cy - h * 0.5 -- 557
	____exports.fillHGradRect( -- 558
		fallbackDraw, -- 558
		x, -- 558
		y, -- 558
		w * 0.65, -- 558
		h, -- 558
		____exports.toColor( -- 558
			tint, -- 558
			math.floor(160 * opacity + 0.5) -- 558
		), -- 558
		Color(tint.r, tint.g, tint.b, 0) -- 558
	) -- 558
end -- 542
--- 婉转烟岚流云曲线（赋予标题、驿道长卷、章名以轻盈流动感）
function ____exports.drawMistCurve(art, id, cx, cy, w, h, tint, opacity, layer, facing) -- 564
	if opacity == nil then -- 564
		opacity = 0.36 -- 568
	end -- 568
	if layer == nil then -- 568
		layer = -1 -- 569
	end -- 569
	if facing == nil then -- 569
		facing = 1 -- 570
	end -- 570
	if w <= 4 or h <= 4 or opacity <= 0.01 then -- 570
		return -- 573
	end -- 573
	art:tryPlace( -- 575
		"ink_mist_curve", -- 575
		id, -- 575
		cx, -- 575
		cy, -- 575
		w, -- 575
		h, -- 575
		{ -- 575
			color = ____exports.toColor(tint, 255), -- 575
			opacity = opacity, -- 575
			layer = layer, -- 575
			facing = facing -- 575
		} -- 575
	) -- 575
end -- 564
--- 霜月游丝细线（可选在中点缀一枚极精巧的宋明海棠菱花微结）
function ____exports.drawHairline(overlayDraw, art, id, cx, cy, w, col, alpha, withKnot, layer) -- 581
	if alpha == nil then -- 581
		alpha = 0.72 -- 586
	end -- 586
	if withKnot == nil then -- 586
		withKnot = false -- 587
	end -- 587
	if layer == nil then -- 587
		layer = 2 -- 588
	end -- 588
	if w <= 4 or alpha <= 0.01 then -- 588
		return -- 591
	end -- 591
	if not art:tryPlace( -- 591
		"ink_hairline", -- 593
		id, -- 593
		cx, -- 593
		cy, -- 593
		w, -- 593
		10, -- 593
		{ -- 593
			color = ____exports.toColor(col, 255), -- 593
			opacity = alpha, -- 593
			layer = layer -- 593
		} -- 593
	) then -- 593
		local half = w * 0.5 -- 594
		____exports.fillHGradRect( -- 595
			overlayDraw, -- 595
			cx - half, -- 595
			cy - 0.5, -- 595
			half, -- 595
			1, -- 595
			Color(col.r, col.g, col.b, 0), -- 595
			____exports.toColor(col, 190 * alpha) -- 595
		) -- 595
		____exports.fillHGradRect( -- 596
			overlayDraw, -- 596
			cx, -- 596
			cy - 0.5, -- 596
			half, -- 596
			1, -- 596
			____exports.toColor(col, 190 * alpha), -- 596
			Color(col.r, col.g, col.b, 0) -- 596
		) -- 596
	end -- 596
	if withKnot then -- 596
		art:tryPlace( -- 599
			"ink_knot_ornament", -- 599
			id .. "_knot", -- 599
			cx, -- 599
			cy, -- 599
			88, -- 599
			24, -- 599
			{ -- 599
				color = ____exports.toColor(col, 255), -- 599
				opacity = math.min(1, alpha * 1.15), -- 599
				layer = layer + 1 -- 599
			} -- 599
		) -- 599
	end -- 599
end -- 581
--- 宋明纤细海棠折角（取代笨重双线铁框与像素铜角，带留白呼吸感）
function ____exports.drawFiligreeCorners(overlayDraw, art, id, x, y, w, h, col, alpha, cornerSize, withHairBorder, layer) -- 606
	if alpha == nil then -- 606
		alpha = 0.78 -- 611
	end -- 611
	if cornerSize == nil then -- 611
		cornerSize = 34 -- 612
	end -- 612
	if withHairBorder == nil then -- 612
		withHairBorder = true -- 613
	end -- 613
	if layer == nil then -- 613
		layer = 2 -- 614
	end -- 614
	if alpha <= 0.01 then -- 614
		return -- 617
	end -- 617
	if withHairBorder then -- 617
		overlayDraw:drawRect( -- 620
			Rect(x, y, w, h), -- 620
			Color(0, 0, 0, 0), -- 620
			0.75, -- 620
			____exports.toColor(col, 78 * alpha) -- 620
		) -- 620
	end -- 620
	local half = cornerSize * 0.5 -- 622
	local c = ____exports.toColor(col, 255) -- 623
	local op = alpha -- 624
	art:tryPlace( -- 625
		"ink_corner_fine", -- 625
		id .. "_tl", -- 625
		x + half - 2, -- 625
		y + h - half + 2, -- 625
		cornerSize, -- 625
		cornerSize, -- 625
		{color = c, opacity = op, layer = layer} -- 625
	) -- 625
	art:tryPlace( -- 626
		"ink_corner_fine", -- 626
		id .. "_tr", -- 626
		x + w - half + 2, -- 626
		y + h - half + 2, -- 626
		cornerSize, -- 626
		cornerSize, -- 626
		{facing = -1, color = c, opacity = op, layer = layer} -- 626
	) -- 626
	art:tryPlace( -- 627
		"ink_corner_fine", -- 627
		id .. "_bl", -- 627
		x + half - 2, -- 627
		y + half - 2, -- 627
		cornerSize, -- 627
		cornerSize, -- 627
		{flipY = true, color = c, opacity = op, layer = layer} -- 627
	) -- 627
	art:tryPlace( -- 628
		"ink_corner_fine", -- 628
		id .. "_br", -- 628
		x + w - half + 2, -- 628
		y + half - 2, -- 628
		cornerSize, -- 628
		cornerSize, -- 628
		{ -- 628
			facing = -1, -- 628
			flipY = true, -- 628
			color = c, -- 628
			opacity = op, -- 628
			layer = layer -- 628
		} -- 628
	) -- 628
end -- 606
--- 文人孤印（全屏仅用于主标题落款与北塔登记簿落款，清瘦精致不泛滥）
function ____exports.drawLoneSeal(overlayDraw, art, texts, id, cx, cy, w, h, topChar, botChar, stampCol, textCol, alpha, layer) -- 634
	if alpha == nil then -- 634
		alpha = 0.94 -- 642
	end -- 642
	if layer == nil then -- 642
		layer = 4 -- 643
	end -- 643
	if alpha <= 0.01 then -- 643
		return -- 646
	end -- 646
	if not art:tryPlace( -- 646
		"ink_seal_slender", -- 648
		id, -- 648
		cx, -- 648
		cy, -- 648
		w, -- 648
		h, -- 648
		{ -- 648
			color = ____exports.toColor(stampCol, 255), -- 648
			opacity = alpha, -- 648
			layer = layer -- 648
		} -- 648
	) then -- 648
		overlayDraw:drawRect( -- 649
			Rect(cx - w * 0.42, cy - h * 0.44, w * 0.84, h * 0.88), -- 649
			____exports.toColor(stampCol, 225 * alpha) -- 649
		) -- 649
	end -- 649
	texts:put( -- 651
		"seal", -- 651
		topChar, -- 651
		cx, -- 651
		cy + h * 0.17, -- 651
		____exports.toColor(textCol), -- 651
		0.5, -- 651
		0.5, -- 651
		"Center", -- 651
		0, -- 651
		alpha, -- 651
		0 -- 651
	) -- 651
	texts:put( -- 652
		"seal", -- 652
		botChar, -- 652
		cx, -- 652
		cy - h * 0.18, -- 652
		____exports.toColor(textCol), -- 652
		0.5, -- 652
		0.5, -- 652
		"Center", -- 652
		0, -- 652
		alpha, -- 652
		0 -- 652
	) -- 652
end -- 634
--- 纤巧菱花花蕊点（替换笨重圆点与方印焦点）
function ____exports.drawBlossomDot(overlayDraw, art, id, cx, cy, size, col, alpha, layer) -- 656
	if alpha == nil then -- 656
		alpha = 0.92 -- 661
	end -- 661
	if layer == nil then -- 661
		layer = 4 -- 662
	end -- 662
	if alpha <= 0.01 then -- 662
		return -- 665
	end -- 665
	if not art:tryPlace( -- 665
		"ink_blossom_dot", -- 667
		id, -- 667
		cx, -- 667
		cy, -- 667
		size, -- 667
		size, -- 667
		{ -- 667
			color = ____exports.toColor(col, 255), -- 667
			opacity = alpha, -- 667
			layer = layer -- 667
		} -- 667
	) then -- 667
		____exports.drawDiamond( -- 668
			overlayDraw, -- 668
			cx, -- 668
			cy, -- 668
			size * 0.35, -- 668
			size * 0.35, -- 668
			____exports.toColor(col, 230 * alpha) -- 668
		) -- 668
	end -- 668
end -- 656
--- 清雅霜银发丝微框键位（去土黄、去厚底）
function ____exports.drawSilkKeycap(overlayDraw, texts, x, y, w, h, keyText, accent, alpha, urgent) -- 673
	if alpha == nil then -- 673
		alpha = 1 -- 679
	end -- 679
	if urgent == nil then -- 679
		urgent = false -- 680
	end -- 680
	local bg = urgent and ____exports.toColor(____exports.PALETTE.rougeSoft, 200 * alpha) or Color( -- 682
		14, -- 682
		17, -- 682
		25, -- 682
		math.floor(186 * alpha + 0.5) -- 682
	) -- 682
	local bd = ____exports.toColor(urgent and ____exports.PALETTE.crimsonCore or accent, (urgent and 225 or 165) * alpha) -- 683
	overlayDraw:drawRect( -- 684
		Rect(x, y, w, h), -- 684
		bg, -- 684
		0.85, -- 684
		bd -- 684
	) -- 684
	local tc = urgent and ____exports.toColor(____exports.PALETTE.sealText) or ____exports.toColor(____exports.PALETTE.textBright) -- 685
	texts:put( -- 686
		"xs", -- 686
		keyText, -- 686
		x + w * 0.5, -- 686
		y + h * 0.5, -- 686
		tc, -- 686
		0.5, -- 686
		0.5, -- 686
		"Center", -- 686
		0.5, -- 686
		alpha, -- 686
		urgent and 0 or 0.08 -- 686
	) -- 686
end -- 673
--- 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述清雅水墨原语
function ____exports.fillSkewRect(draw, x, y, w, h, skew, fill, borderW, borderCol) -- 690
	if borderW == nil then -- 690
		borderW = 0 -- 693
	end -- 693
	if w <= 0 or h <= 0 then -- 693
		return -- 696
	end -- 696
	local pts = { -- 698
		Vec2(x, y), -- 699
		Vec2(x + w, y), -- 700
		Vec2(x + w + skew, y + h), -- 701
		Vec2(x + skew, y + h) -- 702
	} -- 702
	if borderW > 0 and borderCol ~= nil then -- 702
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 705
	else -- 705
		draw:drawPolygon(pts, fill) -- 707
	end -- 707
end -- 690
function ____exports.fillChamferBox(draw, x, y, w, h, cut, fill, borderW, borderCol) -- 711
	if borderW == nil then -- 711
		borderW = 0 -- 714
	end -- 714
	local c = math.min(cut, w * 0.3, h * 0.3) -- 716
	local pts = { -- 717
		Vec2(x, y), -- 718
		Vec2(x + w - c, y), -- 719
		Vec2(x + w, y + c), -- 720
		Vec2(x + w, y + h), -- 721
		Vec2(x + c, y + h), -- 722
		Vec2(x, y + h - c) -- 723
	} -- 723
	if borderW > 0 and borderCol ~= nil then -- 723
		draw:drawPolygon(pts, fill, borderW, borderCol) -- 726
	else -- 726
		draw:drawPolygon(pts, fill) -- 728
	end -- 728
end -- 711
function ____exports.visualTextWidth(text, fontSize) -- 750
	local units = 0 -- 751
	local i = 0 -- 752
	do -- 752
		i = 0 -- 753
		while i < #text do -- 753
			local b = __TS__StringCharCodeAt(text, i) -- 754
			if b < 128 then -- 754
				units = units + 0.56 -- 756
			elseif b >= 192 then -- 756
				units = units + 1.02 -- 758
			end -- 758
			i = i + 1 -- 753
		end -- 753
	end -- 753
	return units * fontSize -- 761
end -- 750
function ____exports.drawHazardStripes(draw, x, y, w, h, pitch, col) -- 764
	local sw = pitch * 0.45 -- 769
	local cur = x - h -- 770
	while cur < x + w do -- 770
		local x0 = math.max(x, cur) -- 772
		local x1 = math.min(x + w, cur + sw) -- 773
		local tx0 = math.max(x, cur + h) -- 774
		local tx1 = math.min(x + w, cur + h + sw) -- 775
		if x1 > x0 and tx1 > tx0 then -- 775
			draw:drawPolygon( -- 777
				{ -- 777
					Vec2(x0, y), -- 778
					Vec2(x1, y), -- 779
					Vec2(tx1, y + h), -- 780
					Vec2(tx0, y + h) -- 781
				}, -- 781
				col -- 782
			) -- 782
		end -- 782
		cur = cur + pitch -- 784
	end -- 784
end -- 764
return ____exports -- 764