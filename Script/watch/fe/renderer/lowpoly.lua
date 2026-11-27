-- [ts]: lowpoly.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 22
local Color = ____Dora.Color -- 22
local Vec2 = ____Dora.Vec2 -- 22
local ____depth = require("Script.watch.depth") -- 23
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 23
local ____theme = require("Script.watch.fe.theme") -- 28
local lerpRGBA = ____theme.lerpRGBA -- 28
local rgba = ____theme.rgba -- 28
local toColor = ____theme.toColor -- 28
____exports.DIORAMA_TEX_CLIP = "assets/art/tex_diorama_ming.clip|" -- 30
____exports.LP_BUCKET = { -- 117
	BACKDROP = 0, -- 118
	MIDGROUND = 1, -- 119
	WALK_DECK = 2, -- 120
	PROP = 3, -- 121
	FOREGROUND = 4 -- 122
} -- 122
function ____exports.clamp01(v) -- 204
	return math.max( -- 205
		0, -- 205
		math.min(1, v) -- 205
	) -- 205
end -- 204
function ____exports.smoothstep(edge0, edge1, x) -- 208
	if edge1 <= edge0 then -- 208
		return x >= edge1 and 1 or 0 -- 210
	end -- 210
	local t = ____exports.clamp01((x - edge0) / (edge1 - edge0)) -- 212
	return t * t * (3 - 2 * t) -- 213
end -- 208
function ____exports.vec3(x, y, z) -- 216
	return {x = x, y = y, z = z} -- 217
end -- 216
function ____exports.normalize3(v) -- 220
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) -- 221
	if len < 0.00001 then -- 221
		return {x = 0, y = 1, z = 0} -- 223
	end -- 223
	return {x = v.x / len, y = v.y / len, z = v.z / len} -- 225
end -- 220
local function dot3(a, b) -- 228
	return a.x * b.x + a.y * b.y + a.z * b.z -- 229
end -- 228
local function cross3(a, b) -- 232
	return {x = a.y * b.z - a.z * b.y, y = a.z * b.x - a.x * b.z, z = a.x * b.y - a.y * b.x} -- 233
end -- 232
local function sub3(a, b) -- 240
	return {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z} -- 241
end -- 240
local function clampByte(v) -- 244
	return math.max( -- 245
		0, -- 245
		math.min( -- 245
			255, -- 245
			math.floor(v + 0.5) -- 245
		) -- 245
	) -- 245
end -- 244
local function scaleRGBA(c, k, alphaMul) -- 248
	if alphaMul == nil then -- 248
		alphaMul = 1 -- 248
	end -- 248
	return { -- 249
		r = clampByte(c.r * k), -- 250
		g = clampByte(c.g * k), -- 251
		b = clampByte(c.b * k), -- 252
		a = clampByte(c.a * alphaMul) -- 253
	} -- 253
end -- 248
--- 明初温州宁村所海防卫城 2.5D 微缩剧场材质预设（全量接入 tex_diorama_ming 纹理 + 高灰度区分度）
____exports.MING_MATERIALS = { -- 258
	mingBrick = { -- 259
		base = rgba(96, 102, 112, 255), -- 260
		edge = rgba(154, 162, 174, 120), -- 261
		minShade = 0.34, -- 262
		rimBoost = 0.24, -- 263
		bottomAo = 0.26, -- 264
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 265
		textureTint = rgba(212, 218, 228, 255), -- 266
		subdivX = 3, -- 267
		subdivY = 2 -- 268
	}, -- 268
	mingBrickDark = { -- 270
		base = rgba(54, 60, 72, 255), -- 271
		edge = rgba(108, 118, 134, 100), -- 272
		minShade = 0.28, -- 273
		rimBoost = 0.18, -- 274
		bottomAo = 0.32, -- 275
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 276
		textureTint = rgba(146, 154, 168, 255), -- 277
		subdivX = 3, -- 278
		subdivY = 2 -- 279
	}, -- 279
	mingTimber = { -- 281
		base = rgba(114, 84, 62, 255), -- 282
		edge = rgba(168, 134, 104, 120), -- 283
		minShade = 0.3, -- 284
		rimBoost = 0.22, -- 285
		bottomAo = 0.26, -- 286
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 287
		textureTint = rgba(224, 206, 186, 255), -- 288
		subdivX = 3, -- 289
		subdivY = 2 -- 290
	}, -- 290
	mingTimberDark = { -- 292
		base = rgba(68, 50, 38, 255), -- 293
		edge = rgba(122, 96, 76, 105), -- 294
		minShade = 0.24, -- 295
		rimBoost = 0.16, -- 296
		bottomAo = 0.34, -- 297
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 298
		textureTint = rgba(148, 132, 118, 255), -- 299
		subdivX = 2, -- 300
		subdivY = 2 -- 301
	}, -- 301
	mingStoneStep = { -- 303
		base = rgba(118, 122, 128, 255), -- 304
		edge = rgba(188, 194, 200, 140), -- 305
		minShade = 0.32, -- 306
		rimBoost = 0.26, -- 307
		bottomAo = 0.24, -- 308
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_stone", -- 309
		textureTint = rgba(210, 216, 224, 255), -- 310
		subdivX = 2, -- 311
		subdivY = 2 -- 312
	}, -- 312
	mingPlaster = { -- 314
		base = rgba(116, 110, 100, 255), -- 315
		edge = rgba(164, 156, 144, 100), -- 316
		minShade = 0.28, -- 317
		rimBoost = 0.18, -- 318
		bottomAo = 0.32, -- 319
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_plaster", -- 320
		textureTint = rgba(196, 192, 182, 255), -- 321
		subdivX = 3, -- 322
		subdivY = 2 -- 323
	}, -- 323
	mingIron = { -- 325
		base = rgba(46, 52, 62, 255), -- 326
		edge = rgba(136, 146, 158, 130), -- 327
		minShade = 0.28, -- 328
		rimBoost = 0.3, -- 329
		bottomAo = 0.24, -- 330
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_iron", -- 331
		textureTint = rgba(178, 186, 198, 255), -- 332
		subdivX = 2, -- 333
		subdivY = 2 -- 334
	}, -- 334
	mingTile = { -- 336
		base = rgba(44, 52, 66, 255), -- 337
		edge = rgba(102, 116, 136, 110), -- 338
		minShade = 0.28, -- 339
		rimBoost = 0.2, -- 340
		bottomAo = 0.22, -- 341
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_tile", -- 342
		textureTint = rgba(176, 188, 206, 255), -- 343
		subdivX = 3, -- 344
		subdivY = 2 -- 345
	}, -- 345
	mingRedCloth = { -- 347
		base = rgba(176, 52, 48, 255), -- 348
		edge = rgba(224, 116, 102, 140), -- 349
		minShade = 0.42, -- 350
		rimBoost = 0.24, -- 351
		bottomAo = 0.16, -- 352
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 353
		textureTint = rgba(218, 68, 60, 255), -- 354
		subdivX = 3, -- 355
		subdivY = 3 -- 356
	}, -- 356
	mingHempCloth = { -- 358
		base = rgba(136, 128, 114, 255), -- 359
		edge = rgba(182, 174, 158, 110), -- 360
		minShade = 0.26, -- 361
		rimBoost = 0.18, -- 362
		bottomAo = 0.28, -- 363
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 364
		textureTint = rgba(172, 166, 152, 255), -- 365
		subdivX = 3, -- 366
		subdivY = 3 -- 367
	}, -- 367
	mingWater = { -- 369
		base = rgba(28, 44, 56, 255), -- 370
		edge = rgba(124, 156, 174, 90), -- 371
		minShade = 0.42, -- 372
		rimBoost = 0.22, -- 373
		bottomAo = 0.1, -- 374
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_water", -- 375
		textureTint = rgba(182, 208, 220, 255), -- 376
		subdivX = 6, -- 377
		subdivY = 3 -- 378
	}, -- 378
	distantWall = { -- 380
		base = rgba(42, 52, 68, 255), -- 381
		edge = rgba(98, 114, 136, 85), -- 382
		minShade = 0.38, -- 383
		rimBoost = 0.14, -- 384
		bottomAo = 0.2, -- 385
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 386
		textureTint = rgba(126, 140, 162, 255), -- 387
		subdivX = 2, -- 388
		subdivY = 1 -- 389
	}, -- 389
	distantHill = { -- 391
		base = rgba(28, 38, 54, 255), -- 392
		edge = rgba(74, 92, 116, 70), -- 393
		minShade = 0.38, -- 394
		rimBoost = 0.12, -- 395
		bottomAo = 0.2 -- 396
	} -- 396
} -- 396
--- 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光）
____exports.GATE_NIGHTMARE_LIGHT = { -- 401
	keyDir = ____exports.normalize3(____exports.vec3(-0.62, 0.64, -0.45)), -- 402
	keyColor = rgba(206, 224, 240, 255), -- 403
	keyStrength = 0.88, -- 404
	rimDir = ____exports.normalize3(____exports.vec3(0.76, 0.36, -0.54)), -- 405
	rimColor = rgba(224, 196, 150, 255), -- 406
	rimStrength = 0.34, -- 407
	ambientColor = rgba(26, 34, 48, 255), -- 408
	fogColor = rgba(26, 36, 52, 255), -- 409
	fogStartZ = 36, -- 410
	fogEndZ = 560, -- 411
	fogMaxAlpha = 0.84, -- 412
	shadowContrast = 0.72 -- 413
} -- 413
____exports.OUTSIDE_JETTY_LIGHT = { -- 416
	keyDir = ____exports.normalize3(____exports.vec3(-0.56, 0.68, -0.48)), -- 417
	keyColor = rgba(196, 214, 232, 255), -- 418
	keyStrength = 0.86, -- 419
	rimDir = ____exports.normalize3(____exports.vec3(0.78, 0.32, -0.54)), -- 420
	rimColor = rgba(226, 188, 136, 255), -- 421
	rimStrength = 0.32, -- 422
	ambientColor = rgba(24, 32, 46, 255), -- 423
	fogColor = rgba(24, 34, 50, 255), -- 424
	fogStartZ = 42, -- 425
	fogEndZ = 520, -- 426
	fogMaxAlpha = 0.8, -- 427
	shadowContrast = 0.74 -- 428
} -- 428
____exports.VILLAGE_UNDERTABLE_LIGHT = { -- 431
	keyDir = ____exports.normalize3(____exports.vec3(0.72, 0.44, -0.54)), -- 432
	keyColor = rgba(214, 208, 194, 255), -- 433
	keyStrength = 0.92, -- 434
	rimDir = ____exports.normalize3(____exports.vec3(-0.64, 0.52, -0.56)), -- 435
	rimColor = rgba(146, 166, 186, 255), -- 436
	rimStrength = 0.28, -- 437
	ambientColor = rgba(18, 22, 30, 255), -- 438
	fogColor = rgba(22, 26, 34, 255), -- 439
	fogStartZ = 55, -- 440
	fogEndZ = 460, -- 441
	fogMaxAlpha = 0.78, -- 442
	shadowContrast = 0.82 -- 443
} -- 443
____exports.FOREST_CREEK_LIGHT = { -- 446
	keyDir = ____exports.normalize3(____exports.vec3(-0.48, 0.74, -0.47)), -- 447
	keyColor = rgba(178, 206, 202, 255), -- 448
	keyStrength = 0.8, -- 449
	rimDir = ____exports.normalize3(____exports.vec3(0.82, 0.28, -0.5)), -- 450
	rimColor = rgba(232, 196, 132, 255), -- 451
	rimStrength = 0.36, -- 452
	ambientColor = rgba(18, 30, 34, 255), -- 453
	fogColor = rgba(20, 34, 38, 255), -- 454
	fogStartZ = 34, -- 455
	fogEndZ = 480, -- 456
	fogMaxAlpha = 0.86, -- 457
	shadowContrast = 0.76 -- 458
} -- 458
____exports.TOWER_WEST_LAMP_LIGHT = { -- 461
	keyDir = ____exports.normalize3(____exports.vec3(-0.74, 0.48, -0.47)), -- 462
	keyColor = rgba(242, 202, 138, 255), -- 463
	keyStrength = 0.94, -- 464
	rimDir = ____exports.normalize3(____exports.vec3(0.62, 0.54, -0.57)), -- 465
	rimColor = rgba(142, 168, 198, 255), -- 466
	rimStrength = 0.26, -- 467
	ambientColor = rgba(24, 26, 36, 255), -- 468
	fogColor = rgba(24, 28, 40, 255), -- 469
	fogStartZ = 60, -- 470
	fogEndZ = 480, -- 471
	fogMaxAlpha = 0.72, -- 472
	shadowContrast = 0.7 -- 473
} -- 473
--- 核心 2.5D 低模投影：
-- 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
function ____exports.projectWorld3D(wx, wy, wz, cam, proj) -- 480
	local bx = cam:sx(wx) -- 487
	local by = cam:sy(wy, proj.baseDepth or 0) -- 488
	local m = ____exports.clamp01(proj.morph) -- 489
	if m <= 0.00001 or math.abs(wz) <= 0.00001 then -- 489
		return {x = bx, y = by, scale = 1, zEff = 0} -- 491
	end -- 491
	local focal = math.max(60, proj.focal) -- 493
	local zEff = wz * m -- 494
	local denom = math.max(focal * 0.22, focal + zEff) -- 495
	local s = focal / denom -- 496
	local vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX or 0) -- 497
	local vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY or 0) -- 498
	return {x = vpX + (bx - vpX) * s, y = vpY + (by - vpY) * s, scale = s, zEff = zEff} -- 499
end -- 480
--- 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
-- 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
function ____exports.verifyWalkPlaneAlignment(cam, proj, wx, wy) -- 511
	local p3 = ____exports.projectWorld3D( -- 517
		wx, -- 517
		wy, -- 517
		0, -- 517
		cam, -- 517
		proj -- 517
	) -- 517
	local p2 = cam:worldToScreen(wx, wy, proj.baseDepth or 0) -- 518
	local fwdDx = p3.x - p2.x -- 519
	local fwdDy = p3.y - p2.y -- 520
	local forwardErrPx = math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy) -- 521
	local inv = cam:screenToWorld(p3.x, p3.y) -- 523
	local invDx = inv.x - wx -- 524
	local invDy = inv.y - (wy + (proj.baseDepth or 0) * DEPTH_Y_SCALE) -- 525
	local inverseErrWorld = math.sqrt(invDx * invDx + invDy * invDy) -- 526
	return {forwardErrPx = forwardErrPx, inverseErrWorld = inverseErrWorld, screenX = p3.x, screenY = p3.y} -- 527
end -- 511
--- 计算给定法线与深度的低模平面受光+雾效颜色
function ____exports.shadeSurface(base, normal, avgZ, morph, light, mat, opacityMul) -- 536
	if opacityMul == nil then -- 536
		opacityMul = 1 -- 543
	end -- 543
	local m = ____exports.clamp01(morph) -- 545
	local n = ____exports.normalize3(normal) -- 546
	local ndl = math.max( -- 547
		0, -- 547
		dot3(n, light.keyDir) -- 547
	) -- 547
	local ndr = math.max( -- 548
		0, -- 548
		dot3(n, light.rimDir) -- 548
	) -- 548
	local minShade = mat and mat.minShade or 0.28 -- 549
	local rimBoost = mat and mat.rimBoost or 0.2 -- 550
	local contrast = light.shadowContrast * (0.45 + 0.55 * m) -- 551
	local keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25) -- 553
	local rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost) -- 554
	local rLit = base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255) + light.ambientColor.r * (0.28 * (1 - ndl * 0.5)) + light.rimColor.r * rimFactor * 0.45 -- 556
	local gLit = base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255) + light.ambientColor.g * (0.28 * (1 - ndl * 0.5)) + light.rimColor.g * rimFactor * 0.45 -- 559
	local bLit = base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255) + light.ambientColor.b * (0.28 * (1 - ndl * 0.5)) + light.rimColor.b * rimFactor * 0.45 -- 562
	local lit = { -- 566
		r = clampByte(rLit), -- 567
		g = clampByte(gLit), -- 568
		b = clampByte(bLit), -- 569
		a = clampByte(base.a * ____exports.clamp01(opacityMul)) -- 570
	} -- 570
	if avgZ > light.fogStartZ and m > 0.01 then -- 570
		local span = math.max(1, light.fogEndZ - light.fogStartZ) -- 574
		local fogT = ____exports.clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m -- 575
		local mixed = lerpRGBA(lit, light.fogColor, fogT) -- 576
		mixed.a = lit.a -- 577
		return mixed -- 578
	end -- 578
	return lit -- 580
end -- 536
--- 画家算法低模场景批处理器：
-- 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
____exports.LowpolyScene = __TS__Class() -- 587
local LowpolyScene = ____exports.LowpolyScene -- 587
LowpolyScene.name = "LowpolyScene" -- 587
function LowpolyScene.prototype.____constructor(self, cam, proj, light) -- 594
	if light == nil then -- 594
		light = ____exports.GATE_NIGHTMARE_LIGHT -- 594
	end -- 594
	self.faces = {} -- 591
	self.glows = {} -- 592
	self.cam = cam -- 595
	self.proj = proj -- 596
	self.light = light -- 597
end -- 594
function LowpolyScene.prototype.getFaceCount(self) -- 600
	return #self.faces -- 601
end -- 600
function LowpolyScene.prototype.project(self, wx, wy, wz) -- 604
	return ____exports.projectWorld3D( -- 605
		wx, -- 605
		wy, -- 605
		wz, -- 605
		self.cam, -- 605
		self.proj -- 605
	) -- 605
end -- 604
function LowpolyScene.prototype.vanishingPointScreen(self) -- 608
	return {x = self.cam.viewW * self.proj.vpFracX + (self.proj.vpOffsetX or 0), y = self.cam.viewH * self.proj.vpFracY + (self.proj.vpOffsetY or 0)} -- 609
end -- 608
function LowpolyScene.prototype.addQuad3D(self, v0, v1, v2, v3, mat, opts) -- 616
	if opts == nil then -- 616
		opts = {} -- 622
	end -- 622
	local opacity = opts.opacity or 1 -- 624
	if opacity <= 0.01 then -- 624
		return -- 626
	end -- 626
	local p0 = self:project(v0.x, v0.y, v0.z) -- 628
	local p1 = self:project(v1.x, v1.y, v1.z) -- 629
	local p2 = self:project(v2.x, v2.y, v2.z) -- 630
	local p3 = self:project(v3.x, v3.y, v3.z) -- 631
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y)) -- 634
	if area2 < 0.25 then -- 634
		return -- 639
	end -- 639
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z + v3.z) * 0.25 -- 642
	local topRgba -- 643
	local texTint -- 644
	local hasTex = mat.texture ~= nil and mat.texture ~= "" -- 645
	if opts.unlit == true then -- 645
		topRgba = scaleRGBA(mat.base, 1, opacity) -- 647
		if hasTex then -- 647
			local tb = mat.textureTint or rgba(235, 238, 244, 255) -- 649
			texTint = toColor(tb, 255) -- 650
		end -- 650
	else -- 650
		local n = cross3( -- 653
			sub3(v1, v0), -- 653
			sub3(v3, v0) -- 653
		) -- 653
		topRgba = ____exports.shadeSurface( -- 654
			mat.base, -- 654
			n, -- 654
			avgZ, -- 654
			self.proj.morph, -- 654
			self.light, -- 654
			mat, -- 654
			opacity -- 654
		) -- 654
		if hasTex then -- 654
			local tb = mat.textureTint or rgba(224, 228, 236, 255) -- 657
			local litTex = ____exports.shadeSurface( -- 658
				tb, -- 658
				n, -- 658
				avgZ, -- 658
				self.proj.morph, -- 658
				self.light, -- 658
				mat, -- 658
				1 -- 658
			) -- 658
			texTint = toColor(litTex, 255) -- 659
		end -- 659
	end -- 659
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.22) -- 663
	local bottomShade = ao > 0.005 and math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)) or 1 -- 664
	local botRgba = scaleRGBA(topRgba, bottomShade) -- 665
	local cBot = toColor(botRgba) -- 666
	local cTop = toColor(topRgba) -- 667
	local edgeRgba = opts.edgeColor or mat.edge -- 670
	local edgeW = hasTex and 0 or (opts.edgeWidth or 0) -- 671
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 672
		edgeRgba, -- 673
		math.floor(edgeRgba.a * opacity + 0.5) -- 673
	) or nil -- 673
	local ____self_faces_11 = self.faces -- 676
	local ____temp_5 = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 677
	local ____temp_6 = opts.sortBias or 0 -- 679
	local ____temp_7 = {p0, p1, p2, p3} -- 680
	local ____temp_8 = {cBot, cBot, cTop, cTop} -- 681
	local ____edgeCol_9 = edgeCol -- 682
	local ____temp_10 = hasTex and ({v0, v1, v2, v3}) or nil -- 685
	local ____hasTex_4 -- 686
	if hasTex then -- 686
		____hasTex_4 = mat.texture -- 686
	else -- 686
		____hasTex_4 = nil -- 686
	end -- 686
	____self_faces_11[#____self_faces_11 + 1] = { -- 676
		bucket = ____temp_5, -- 677
		sortZ = avgZ, -- 678
		sortBias = ____temp_6, -- 679
		pts = ____temp_7, -- 680
		cols = ____temp_8, -- 681
		edgeCol = ____edgeCol_9, -- 682
		edgeWidth = edgeW, -- 683
		topHighlight = nil, -- 684
		worldQuad = ____temp_10, -- 685
		texture = ____hasTex_4, -- 686
		texTint = texTint, -- 687
		texBottomShade = bottomShade, -- 688
		texOpacity = opacity, -- 689
		subdivX = opts.subdivX or mat.subdivX or 2, -- 690
		subdivY = opts.subdivY or mat.subdivY or 2, -- 691
		wave = opts.wave, -- 692
		additive = opts.additive -- 693
	} -- 693
end -- 616
function LowpolyScene.prototype.addWavingQuad3D(self, v0, v1, v2, v3, mat, wave, opts) -- 698
	if opts == nil then -- 698
		opts = {} -- 705
	end -- 705
	self:addQuad3D( -- 707
		v0, -- 707
		v1, -- 707
		v2, -- 707
		v3, -- 707
		mat, -- 707
		__TS__ObjectAssign({}, opts, {wave = wave, subdivX = opts.subdivX or mat.subdivX or 4, subdivY = opts.subdivY or mat.subdivY or 3}) -- 707
	) -- 707
end -- 698
function LowpolyScene.prototype.addCutout3D(self, clipStr, wx, wy, wz, worldW, worldH, opts) -- 719
	if opts == nil then -- 719
		opts = {} -- 726
	end -- 726
	local opacity = opts.opacity or 1 -- 728
	if opacity <= 0.01 or worldW <= 0.5 or worldH <= 0.5 then -- 728
		return -- 730
	end -- 730
	local pt = self:project(wx, wy, wz) -- 732
	local screenW = self.cam:len(worldW) * pt.scale -- 733
	local screenH = self.cam:len(worldH) * pt.scale -- 734
	if screenW < 1 or screenH < 1 then -- 734
		return -- 736
	end -- 736
	local baseTint = opts.tint or opts.color or rgba(240, 244, 248, 255) -- 738
	local finalRgba = baseTint -- 739
	if opts.unlit ~= true then -- 739
		local m = ____exports.clamp01(self.proj.morph) -- 741
		if wz > self.light.fogStartZ and m > 0.01 then -- 741
			local span = math.max(1, self.light.fogEndZ - self.light.fogStartZ) -- 743
			local fogT = ____exports.clamp01((wz - self.light.fogStartZ) / span) * self.light.fogMaxAlpha * 0.72 * m -- 744
			finalRgba = lerpRGBA(baseTint, self.light.fogColor, fogT) -- 745
		end -- 745
	end -- 745
	local ____self_faces_12 = self.faces -- 745
	____self_faces_12[#____self_faces_12 + 1] = { -- 748
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 749
		sortZ = wz, -- 750
		sortBias = opts.sortBias or 0, -- 751
		pts = {}, -- 752
		cols = {}, -- 753
		edgeCol = nil, -- 754
		edgeWidth = 0, -- 755
		topHighlight = nil, -- 756
		cutout = { -- 757
			clipStr = clipStr, -- 758
			x = pt.x, -- 759
			y = pt.y, -- 760
			w = screenW, -- 761
			h = screenH, -- 762
			anchorX = opts.anchorX or 0.5, -- 763
			anchorY = opts.anchorY or 0, -- 764
			facing = opts.facing or 1, -- 765
			flipY = opts.flipY == true, -- 766
			angle = opts.angle or 0, -- 767
			color = toColor(finalRgba, 255), -- 768
			opacity = opacity, -- 769
			smooth = opts.smooth ~= false, -- 770
			additive = opts.additive == true -- 771
		} -- 771
	} -- 771
end -- 719
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 777
	if opts == nil then -- 777
		opts = {} -- 782
	end -- 782
	local opacity = opts.opacity or 1 -- 784
	if opacity <= 0.01 then -- 784
		return -- 786
	end -- 786
	local p0 = self:project(v0.x, v0.y, v0.z) -- 788
	local p1 = self:project(v1.x, v1.y, v1.z) -- 789
	local p2 = self:project(v2.x, v2.y, v2.z) -- 790
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 792
	if area2 < 0.25 then -- 792
		return -- 794
	end -- 794
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 797
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 798
		mat.base, -- 800
		cross3( -- 800
			sub3(v1, v0), -- 800
			sub3(v2, v0) -- 800
		), -- 800
		avgZ, -- 800
		self.proj.morph, -- 800
		self.light, -- 800
		mat, -- 800
		opacity -- 800
	) -- 800
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 801
	local botRgba = ao > 0.005 and scaleRGBA( -- 802
		colRgba, -- 802
		math.max(0.4, 1 - ao), -- 802
		1 -- 802
	) or colRgba -- 802
	local edgeRgba = opts.edgeColor or mat.edge -- 804
	local edgeW = opts.edgeWidth or 0 -- 805
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 806
		edgeRgba, -- 807
		math.floor(edgeRgba.a * opacity + 0.5) -- 807
	) or nil -- 807
	local ____self_faces_13 = self.faces -- 807
	____self_faces_13[#____self_faces_13 + 1] = { -- 810
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 811
		sortZ = avgZ, -- 812
		sortBias = opts.sortBias or 0, -- 813
		pts = {p0, p1, p2}, -- 814
		cols = { -- 815
			toColor(botRgba), -- 815
			toColor(botRgba), -- 815
			toColor(colRgba) -- 815
		}, -- 815
		edgeCol = edgeCol, -- 816
		edgeWidth = edgeW, -- 817
		topHighlight = nil -- 818
	} -- 818
end -- 777
function LowpolyScene.prototype.addBox(self, spec) -- 826
	local opacity = spec.opacity or 1 -- 827
	if opacity <= 0.01 then -- 827
		return -- 829
	end -- 829
	local x0 = math.min(spec.x0, spec.x1) -- 831
	local x1 = math.max(spec.x0, spec.x1) -- 832
	local y0 = math.min(spec.y0, spec.y1) -- 833
	local y1 = math.max(spec.y0, spec.y1) -- 834
	local z0 = math.min(spec.z0, spec.z1) -- 835
	local z1 = math.max(spec.z0, spec.z1) -- 836
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 838
	local bias = spec.sortBias or 0 -- 839
	local hasTex = spec.material.texture ~= nil and spec.material.texture ~= "" -- 840
	local edgeW = hasTex and 0 or (spec.edgeWidth or 0) -- 841
	local midZ = (z0 + z1) * 0.5 -- 842
	local vp = self:vanishingPointScreen() -- 843
	local m = ____exports.clamp01(self.proj.morph) -- 844
	local sx0 = self.cam:sx(x0) -- 846
	local sx1 = self.cam:sx(x1) -- 847
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 848
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 849
	if m > 0.002 and z1 - z0 > 0.05 then -- 849
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 849
			self:addQuad3D( -- 854
				____exports.vec3(x0, y0, z1), -- 855
				____exports.vec3(x0, y0, z0), -- 856
				____exports.vec3(x0, y1, z0), -- 857
				____exports.vec3(x0, y1, z1), -- 858
				spec.material, -- 859
				{ -- 860
					bucket = bucket, -- 860
					sortZOverride = midZ + 0.4, -- 860
					sortBias = bias - 0.1, -- 860
					opacity = opacity, -- 860
					edgeWidth = edgeW -- 860
				} -- 860
			) -- 860
		end -- 860
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 860
			self:addQuad3D( -- 865
				____exports.vec3(x1, y0, z0), -- 866
				____exports.vec3(x1, y0, z1), -- 867
				____exports.vec3(x1, y1, z1), -- 868
				____exports.vec3(x1, y1, z0), -- 869
				spec.material, -- 870
				{ -- 871
					bucket = bucket, -- 871
					sortZOverride = midZ + 0.4, -- 871
					sortBias = bias - 0.1, -- 871
					opacity = opacity, -- 871
					edgeWidth = edgeW -- 871
				} -- 871
			) -- 871
		end -- 871
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 871
			self:addQuad3D( -- 876
				____exports.vec3(x0, y1, z0), -- 877
				____exports.vec3(x1, y1, z0), -- 878
				____exports.vec3(x1, y1, z1), -- 879
				____exports.vec3(x0, y1, z1), -- 880
				spec.material, -- 881
				{ -- 882
					bucket = bucket, -- 882
					sortZOverride = midZ + 0.2, -- 882
					sortBias = bias - 0.05, -- 882
					opacity = opacity, -- 882
					edgeWidth = edgeW, -- 882
					bottomAo = 0.08 -- 882
				} -- 882
			) -- 882
		end -- 882
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 882
			self:addQuad3D( -- 887
				____exports.vec3(x0, y0, z1), -- 888
				____exports.vec3(x1, y0, z1), -- 889
				____exports.vec3(x1, y0, z0), -- 890
				____exports.vec3(x0, y0, z0), -- 891
				spec.material, -- 892
				{ -- 893
					bucket = bucket, -- 893
					sortZOverride = midZ + 0.2, -- 893
					sortBias = bias - 0.05, -- 893
					opacity = opacity, -- 893
					edgeWidth = edgeW, -- 893
					bottomAo = 0.34 -- 893
				} -- 893
			) -- 893
		end -- 893
	end -- 893
	if spec.skipFront ~= true then -- 893
		local beforeLen = #self.faces -- 900
		self:addQuad3D( -- 901
			____exports.vec3(x0, y0, z0), -- 902
			____exports.vec3(x1, y0, z0), -- 903
			____exports.vec3(x1, y1, z0), -- 904
			____exports.vec3(x0, y1, z0), -- 905
			spec.material, -- 906
			{ -- 907
				bucket = bucket, -- 907
				sortZOverride = z0, -- 907
				sortBias = bias, -- 907
				opacity = opacity, -- 907
				edgeWidth = edgeW -- 907
			} -- 907
		) -- 907
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 907
			local face = self.faces[#self.faces] -- 910
			local rimCol = spec.material.edge or rgba(198, 206, 214, 110) -- 911
			local rimAlpha = math.floor(math.min(hasTex and 96 or 165, rimCol.a * (hasTex and 0.62 or 0.95)) * opacity + 0.5) -- 913
			face.topHighlight = { -- 914
				face.pts[4], -- 915
				face.pts[3], -- 916
				toColor(rimCol, rimAlpha) -- 917
			} -- 917
		end -- 917
	end -- 917
end -- 826
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 927
	if opts == nil then -- 927
		opts = {} -- 937
	end -- 937
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 945
	local opacity = opts.opacity or 1 -- 946
	local bias = opts.sortBias or 0 -- 947
	self:addBox({ -- 950
		x0 = openX0 - pillarW, -- 951
		x1 = openX0, -- 952
		y0 = y0, -- 953
		y1 = openY1 + lintelH, -- 954
		z0 = z0, -- 955
		z1 = z1, -- 956
		material = mat, -- 957
		bucket = bucket, -- 958
		sortBias = bias, -- 959
		opacity = opacity, -- 960
		highlightTopEdge = true -- 961
	}) -- 961
	self:addBox({ -- 964
		x0 = openX1, -- 965
		x1 = openX1 + pillarW, -- 966
		y0 = y0, -- 967
		y1 = openY1 + lintelH, -- 968
		z0 = z0, -- 969
		z1 = z1, -- 970
		material = mat, -- 971
		bucket = bucket, -- 972
		sortBias = bias, -- 973
		opacity = opacity, -- 974
		highlightTopEdge = true -- 975
	}) -- 975
	self:addBox({ -- 978
		x0 = openX0 - pillarW * 0.2, -- 979
		x1 = openX1 + pillarW * 0.2, -- 980
		y0 = openY1, -- 981
		y1 = openY1 + lintelH, -- 982
		z0 = z0, -- 983
		z1 = z1, -- 984
		material = mat, -- 985
		bucket = bucket, -- 986
		sortBias = bias + 0.05, -- 987
		opacity = opacity, -- 988
		highlightTopEdge = true -- 989
	}) -- 989
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 993
	if rimAlpha > 0.02 then -- 993
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 995
		local p0 = self:project(openX0, y0 + 2, z0) -- 996
		local p1 = self:project(openX0, y0 + 2, z1) -- 997
		local p2 = self:project(openX0, openY1 - 2, z1) -- 998
		local p3 = self:project(openX0, openY1 - 2, z0) -- 999
		local cNear = toColor( -- 1000
			rimCol, -- 1000
			math.floor(135 * rimAlpha + 0.5) -- 1000
		) -- 1000
		local cFar = toColor( -- 1001
			rimCol, -- 1001
			math.floor(28 * rimAlpha + 0.5) -- 1001
		) -- 1001
		local ____self_glows_14 = self.glows -- 1001
		____self_glows_14[#____self_glows_14 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 1002
	end -- 1002
end -- 927
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 1010
	if mat == nil then -- 1010
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 1014
	end -- 1014
	if opts == nil then -- 1014
		opts = {} -- 1015
	end -- 1015
	local n = math.max(1, stair.steps + 1) -- 1017
	local stepW = (stair.x1 - stair.x0) / n -- 1018
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 1019
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1020
	local opacity = opts.opacity or 1 -- 1021
	local bias = opts.sortBias or 0 -- 1022
	local k = 0 -- 1024
	do -- 1024
		k = 0 -- 1025
		while k < n do -- 1025
			do -- 1025
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 1026
				local wx0 = stair.x0 + stepW * k -- 1027
				local wx1 = wx0 + stepW -- 1028
				if wy <= floorY + 1 then -- 1028
					goto __continue51 -- 1030
				end -- 1030
				self:addBox({ -- 1032
					x0 = wx0, -- 1033
					x1 = wx1, -- 1034
					y0 = floorY, -- 1035
					y1 = wy, -- 1036
					z0 = z0, -- 1037
					z1 = z1, -- 1038
					material = mat, -- 1039
					bucket = bucket, -- 1040
					sortBias = bias + k * 0.01, -- 1041
					opacity = opacity, -- 1042
					highlightTopEdge = true, -- 1043
					edgeWidth = 0.9 -- 1044
				}) -- 1044
			end -- 1044
			::__continue51:: -- 1044
			k = k + 1 -- 1025
		end -- 1025
	end -- 1025
end -- 1010
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 1053
	if mat == nil then -- 1053
		mat = ____exports.MING_MATERIALS.mingTimber -- 1061
	end -- 1061
	if opts == nil then -- 1061
		opts = {} -- 1062
	end -- 1062
	local count = math.max( -- 1070
		1, -- 1070
		math.floor(plankCount) -- 1070
	) -- 1070
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1071
	local opacity = opts.opacity or 1 -- 1072
	local bias = opts.sortBias or 0 -- 1073
	local spanZ = math.max(1, z1 - z0) -- 1074
	local gap = math.min(2.6, spanZ / (count * 6)) -- 1075
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 1076
	if opts.withPosts == true then -- 1076
		local postBot = opts.postBottomY or topY - 92 -- 1080
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 1081
		local postCount = math.max( -- 1082
			2, -- 1082
			math.min( -- 1082
				5, -- 1082
				math.floor((x1 - x0) / 110) + 1 -- 1082
			) -- 1082
		) -- 1082
		local pi = 0 -- 1083
		do -- 1083
			pi = 0 -- 1084
			while pi < postCount do -- 1084
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 1085
				self:addBox({ -- 1086
					x0 = px - 6, -- 1087
					x1 = px + 6, -- 1088
					y0 = postBot, -- 1089
					y1 = topY - thickness, -- 1090
					z0 = z0 + 4, -- 1091
					z1 = z0 + 18, -- 1092
					material = postMat, -- 1093
					bucket = bucket, -- 1094
					sortBias = bias - 0.3, -- 1095
					opacity = opacity, -- 1096
					edgeWidth = 0.7 -- 1097
				}) -- 1097
				pi = pi + 1 -- 1084
			end -- 1084
		end -- 1084
	end -- 1084
	local i = 0 -- 1103
	do -- 1103
		i = 0 -- 1104
		while i < count do -- 1104
			local pz0 = z0 + i * (plankDepth + gap) -- 1105
			local pz1 = pz0 + plankDepth -- 1106
			local plankMat = i & 1 == 0 and mat or ({ -- 1107
				base = scaleRGBA(mat.base, 0.88), -- 1110
				edge = mat.edge, -- 1111
				minShade = mat.minShade, -- 1112
				rimBoost = mat.rimBoost, -- 1113
				bottomAo = mat.bottomAo, -- 1114
				texture = mat.texture, -- 1115
				textureTint = mat.textureTint ~= nil and scaleRGBA(mat.textureTint, 0.9) or nil, -- 1116
				subdivX = mat.subdivX, -- 1117
				subdivY = mat.subdivY -- 1118
			}) -- 1118
			self:addBox({ -- 1120
				x0 = x0, -- 1121
				x1 = x1, -- 1122
				y0 = topY - thickness, -- 1123
				y1 = topY, -- 1124
				z0 = pz0, -- 1125
				z1 = pz1, -- 1126
				material = plankMat, -- 1127
				bucket = bucket, -- 1128
				sortBias = bias + (count - i) * 0.01, -- 1129
				opacity = opacity, -- 1130
				highlightTopEdge = i == 0, -- 1131
				edgeWidth = 0.8 -- 1132
			}) -- 1132
			i = i + 1 -- 1104
		end -- 1104
	end -- 1104
end -- 1053
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 1138
	if mat == nil then -- 1138
		mat = ____exports.MING_MATERIALS.distantHill -- 1142
	end -- 1142
	if opts == nil then -- 1142
		opts = {} -- 1143
	end -- 1143
	if #peaks < 2 then -- 1143
		return -- 1146
	end -- 1146
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 1148
	local opacity = opts.opacity or 1 -- 1149
	local bias = opts.sortBias or 0 -- 1150
	local i = 0 -- 1152
	do -- 1152
		i = 0 -- 1153
		while i < #peaks - 1 do -- 1153
			local a = peaks[i + 1] -- 1154
			local b = peaks[i + 1 + 1] -- 1155
			local midX = (a.x + b.x) * 0.5 -- 1156
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 1157
			local ridgeMat = b.y >= a.y and mat or ({ -- 1158
				base = scaleRGBA(mat.base, 0.84), -- 1161
				edge = mat.edge, -- 1162
				minShade = mat.minShade, -- 1163
				rimBoost = mat.rimBoost, -- 1164
				bottomAo = mat.bottomAo -- 1165
			}) -- 1165
			self:addTri3D( -- 1167
				____exports.vec3(a.x, baseY, z), -- 1168
				____exports.vec3(b.x, baseY, z), -- 1169
				____exports.vec3(a.x, a.y, z), -- 1170
				ridgeMat, -- 1171
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 1172
			) -- 1172
			self:addTri3D( -- 1174
				____exports.vec3(b.x, baseY, z), -- 1175
				____exports.vec3(b.x, b.y, z), -- 1176
				____exports.vec3(a.x, a.y, z), -- 1177
				ridgeMat, -- 1178
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 1179
			) -- 1179
			self:addTri3D( -- 1182
				____exports.vec3( -- 1183
					midX, -- 1183
					math.max(baseY, midY), -- 1183
					z - 8 -- 1183
				), -- 1183
				____exports.vec3(b.x, baseY, z), -- 1184
				____exports.vec3(b.x, b.y, z), -- 1185
				{ -- 1186
					base = scaleRGBA(mat.base, 0.78), -- 1186
					minShade = 0.3, -- 1186
					bottomAo = 0.2 -- 1186
				}, -- 1186
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 1187
			) -- 1187
			i = i + 1 -- 1153
		end -- 1153
	end -- 1153
end -- 1138
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 1193
	if opts == nil then -- 1193
		opts = {} -- 1202
	end -- 1202
	local m = ____exports.clamp01(self.proj.morph) -- 1204
	local ba = ____exports.clamp01(bottomAlpha * m) -- 1205
	local ta = ____exports.clamp01(topAlpha * m) -- 1206
	if ba <= 0.008 and ta <= 0.008 then -- 1206
		return -- 1208
	end -- 1208
	local p0 = self:project(x0, y0, z) -- 1210
	local p1 = self:project(x1, y0, z) -- 1211
	local p2 = self:project(x1, y1, z) -- 1212
	local p3 = self:project(x0, y1, z) -- 1213
	local cBot = toColor( -- 1214
		color, -- 1214
		math.floor(255 * ba + 0.5) -- 1214
	) -- 1214
	local cTop = toColor( -- 1215
		color, -- 1215
		math.floor(255 * ta + 0.5) -- 1215
	) -- 1215
	local ____self_faces_15 = self.faces -- 1215
	____self_faces_15[#____self_faces_15 + 1] = { -- 1216
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 1217
		sortZ = z, -- 1218
		sortBias = opts.sortBias or 0.5, -- 1219
		pts = {p0, p1, p2, p3}, -- 1220
		cols = {cBot, cBot, cTop, cTop}, -- 1221
		edgeCol = nil, -- 1222
		edgeWidth = 0, -- 1223
		topHighlight = nil -- 1224
	} -- 1224
end -- 1193
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 1229
	local ta = ____exports.clamp01(topAlpha) -- 1241
	local ba = ____exports.clamp01(botAlpha) -- 1242
	if ta <= 0.005 and ba <= 0.005 then -- 1242
		return -- 1244
	end -- 1244
	local p0 = self:project(botX0, botY, z) -- 1246
	local p1 = self:project(botX1, botY, z) -- 1247
	local p2 = self:project(topX1, topY, z) -- 1248
	local p3 = self:project(topX0, topY, z) -- 1249
	local cTop = toColor( -- 1250
		color, -- 1250
		math.floor(255 * ta + 0.5) -- 1250
	) -- 1250
	local cBot = toColor( -- 1251
		color, -- 1251
		math.floor(255 * ba + 0.5) -- 1251
	) -- 1251
	local ____self_glows_16 = self.glows -- 1251
	____self_glows_16[#____self_glows_16 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1252
end -- 1229
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1262
	if opacity == nil then -- 1262
		opacity = 0.72 -- 1267
	end -- 1267
	if opts == nil then -- 1267
		opts = {} -- 1268
	end -- 1268
	local op = ____exports.clamp01(opacity) -- 1270
	if op <= 0.01 then -- 1270
		return -- 1272
	end -- 1272
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1274
	local bias = opts.sortBias or 0.2 -- 1275
	local m = ____exports.clamp01(self.proj.morph) -- 1276
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1277
	local segs = 10 -- 1280
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1281
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1282
	local innerCol = Color( -- 1283
		7, -- 1283
		9, -- 1283
		14, -- 1283
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1283
	) -- 1283
	local outerCol = Color(7, 9, 14, 0) -- 1284
	local i = 0 -- 1285
	do -- 1285
		i = 0 -- 1286
		while i < segs do -- 1286
			local a0 = i / segs * math.pi * 2 -- 1287
			local a1 = (i + 1) / segs * math.pi * 2 -- 1288
			local pA = self:project( -- 1289
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1290
				wy + 0.4, -- 1291
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1292
			) -- 1292
			local pB = self:project( -- 1294
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1295
				wy + 0.4, -- 1296
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1297
			) -- 1297
			local ____self_faces_17 = self.faces -- 1297
			____self_faces_17[#____self_faces_17 + 1] = { -- 1299
				bucket = bucket, -- 1300
				sortZ = 0.05, -- 1301
				sortBias = bias, -- 1302
				pts = {centerP, pA, pB}, -- 1303
				cols = {innerCol, outerCol, outerCol}, -- 1304
				edgeCol = nil, -- 1305
				edgeWidth = 0, -- 1306
				topHighlight = nil -- 1307
			} -- 1307
			i = i + 1 -- 1286
		end -- 1286
	end -- 1286
	local footP = self:project(wx, wy + 0.5, 0) -- 1312
	local coreRx = self.cam:len(radiusX * 0.78) -- 1313
	local coreRy = math.max( -- 1314
		2.5, -- 1314
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1314
	) -- 1314
	local coreIn = Color( -- 1315
		5, -- 1315
		7, -- 1315
		12, -- 1315
		math.floor(210 * op + 0.5) -- 1315
	) -- 1315
	local coreOut = Color( -- 1316
		5, -- 1316
		7, -- 1316
		12, -- 1316
		math.floor(32 * op + 0.5) -- 1316
	) -- 1316
	local coreSegs = 8 -- 1317
	do -- 1317
		i = 0 -- 1318
		while i < coreSegs do -- 1318
			local a0 = i / coreSegs * math.pi * 2 -- 1319
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1320
			local ____self_faces_18 = self.faces -- 1320
			____self_faces_18[#____self_faces_18 + 1] = { -- 1321
				bucket = bucket, -- 1322
				sortZ = 0.01, -- 1323
				sortBias = bias + 0.05, -- 1324
				pts = { -- 1325
					footP, -- 1326
					{ -- 1327
						x = footP.x + math.cos(a0) * coreRx, -- 1327
						y = footP.y + math.sin(a0) * coreRy, -- 1327
						scale = 1, -- 1327
						zEff = 0 -- 1327
					}, -- 1327
					{ -- 1328
						x = footP.x + math.cos(a1) * coreRx, -- 1328
						y = footP.y + math.sin(a1) * coreRy, -- 1328
						scale = 1, -- 1328
						zEff = 0 -- 1328
					} -- 1328
				}, -- 1328
				cols = {coreIn, coreOut, coreOut}, -- 1330
				edgeCol = nil, -- 1331
				edgeWidth = 0, -- 1332
				topHighlight = nil -- 1333
			} -- 1333
			i = i + 1 -- 1318
		end -- 1318
	end -- 1318
end -- 1262
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1342
	if opts == nil then -- 1342
		opts = {} -- 1351
	end -- 1351
	local pBL = self:project(x0, y0, wz) -- 1353
	local pTR = self:project(x1, y1, wz) -- 1354
	local w = math.abs(pTR.x - pBL.x) -- 1355
	local h = math.abs(pTR.y - pBL.y) -- 1356
	if w < 1 or h < 1 then -- 1356
		return false -- 1358
	end -- 1358
	return worldArt:tryPlace( -- 1360
		slotKey, -- 1361
		instanceKey, -- 1362
		(pBL.x + pTR.x) * 0.5, -- 1363
		math.min(pBL.y, pTR.y), -- 1364
		w, -- 1365
		h, -- 1366
		{ -- 1367
			color = opts.color or Color(28, 32, 42, 255), -- 1368
			opacity = opts.opacity or 0.92, -- 1369
			layer = opts.layer or 5200 -- 1370
		} -- 1370
	) -- 1370
end -- 1342
function LowpolyScene.prototype.drawFaceToNode(self, target, f) -- 1376
	if #f.pts == 3 then -- 1376
		target:drawVertices({ -- 1378
			{ -- 1379
				Vec2(f.pts[1].x, f.pts[1].y), -- 1379
				f.cols[1] -- 1379
			}, -- 1379
			{ -- 1380
				Vec2(f.pts[2].x, f.pts[2].y), -- 1380
				f.cols[2] -- 1380
			}, -- 1380
			{ -- 1381
				Vec2(f.pts[3].x, f.pts[3].y), -- 1381
				f.cols[3] -- 1381
			} -- 1381
		}) -- 1381
	elseif #f.pts == 4 then -- 1381
		local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1384
		local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1385
		local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1386
		local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1387
		target:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1388
		target:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1393
	end -- 1393
	if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1393
		local count = #f.pts -- 1400
		local k = 0 -- 1401
		do -- 1401
			k = 0 -- 1402
			while k < count do -- 1402
				local a = f.pts[k + 1] -- 1403
				local b = f.pts[(k + 1) % count + 1] -- 1404
				target:drawSegment( -- 1405
					Vec2(a.x, a.y), -- 1405
					Vec2(b.x, b.y), -- 1405
					f.edgeWidth * 0.5, -- 1405
					f.edgeCol -- 1405
				) -- 1405
				k = k + 1 -- 1402
			end -- 1402
		end -- 1402
	end -- 1402
	if f.topHighlight ~= nil then -- 1402
		local hl = f.topHighlight -- 1409
		target:drawSegment( -- 1410
			Vec2(hl[1].x, hl[1].y), -- 1410
			Vec2(hl[2].x, hl[2].y), -- 1410
			0.9, -- 1410
			hl[3] -- 1410
		) -- 1410
	end -- 1410
end -- 1376
function LowpolyScene.prototype.flush(self, draw, glowDraw, dioramaHost) -- 1419
	if #self.faces > 1 then -- 1419
		__TS__ArraySort( -- 1421
			self.faces, -- 1421
			function(____, a, b) -- 1421
				if a.bucket ~= b.bucket then -- 1421
					return a.bucket - b.bucket -- 1423
				end -- 1423
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1423
					return b.sortZ - a.sortZ -- 1426
				end -- 1426
				return a.sortBias - b.sortBias -- 1428
			end -- 1421
		) -- 1421
	end -- 1421
	local runDraw -- 1432
	local i = 0 -- 1434
	do -- 1434
		i = 0 -- 1435
		while i < #self.faces do -- 1435
			do -- 1435
				local f = self.faces[i + 1] -- 1436
				if dioramaHost ~= nil then -- 1436
					if f.cutout ~= nil then -- 1436
						runDraw = nil -- 1440
						local c = f.cutout -- 1441
						dioramaHost:placeCutoutCard({ -- 1442
							clipStr = c.clipStr, -- 1443
							x = c.x, -- 1444
							y = c.y, -- 1445
							targetW = c.w, -- 1446
							targetH = c.h, -- 1447
							order = dioramaHost:nextOrder(), -- 1448
							anchorX = c.anchorX, -- 1449
							anchorY = c.anchorY, -- 1450
							facing = c.facing, -- 1451
							flipY = c.flipY, -- 1452
							angle = c.angle, -- 1453
							color = c.color, -- 1454
							opacity = c.opacity, -- 1455
							smooth = c.smooth, -- 1456
							additive = c.additive -- 1457
						}) -- 1457
						goto __continue88 -- 1459
					end -- 1459
					if f.texture ~= nil and f.worldQuad ~= nil then -- 1459
						local order = dioramaHost:nextOrder() -- 1463
						local placed = dioramaHost:placeTexturedQuad({ -- 1464
							clipStr = f.texture, -- 1465
							v0 = f.worldQuad[1], -- 1466
							v1 = f.worldQuad[2], -- 1467
							v2 = f.worldQuad[3], -- 1468
							v3 = f.worldQuad[4], -- 1469
							segX = f.subdivX or 2, -- 1470
							segY = f.subdivY or 2, -- 1471
							projector = self, -- 1472
							bottomShade = f.texBottomShade or 1, -- 1473
							tintColor = f.texTint or f.cols[3] or Color(255, 255, 255, 255), -- 1474
							opacity = f.texOpacity or 1, -- 1475
							order = order, -- 1476
							additive = f.additive, -- 1477
							wave = f.wave -- 1478
						}) -- 1478
						if placed then -- 1478
							runDraw = nil -- 1481
							if f.topHighlight ~= nil then -- 1481
								local rimNode = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1484
								local hl = f.topHighlight -- 1485
								rimNode:drawSegment( -- 1486
									Vec2(hl[1].x, hl[1].y), -- 1486
									Vec2(hl[2].x, hl[2].y), -- 1486
									0.85, -- 1486
									hl[3] -- 1486
								) -- 1486
								runDraw = rimNode -- 1487
							end -- 1487
							goto __continue88 -- 1489
						end -- 1489
					end -- 1489
					if runDraw == nil then -- 1489
						runDraw = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1494
					end -- 1494
					self:drawFaceToNode(runDraw, f) -- 1496
				else -- 1496
					if f.cutout ~= nil then -- 1496
						goto __continue88 -- 1499
					end -- 1499
					self:drawFaceToNode(draw, f) -- 1501
				end -- 1501
			end -- 1501
			::__continue88:: -- 1501
			i = i + 1 -- 1435
		end -- 1435
	end -- 1435
	if glowDraw ~= nil and #self.glows > 0 then -- 1435
		do -- 1435
			i = 0 -- 1506
			while i < #self.glows do -- 1506
				local g = self.glows[i + 1] -- 1507
				if #g.pts == 4 then -- 1507
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1509
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1510
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1511
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1512
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1513
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1518
				end -- 1518
				i = i + 1 -- 1506
			end -- 1506
		end -- 1506
	end -- 1506
	self.faces = {} -- 1527
	self.glows = {} -- 1528
end -- 1419
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time) -- 1537
	scene:addDistantRidge( -- 1546
		{ -- 1547
			{x = room.minX - 180, y = 125}, -- 1548
			{x = room.minX + 120, y = 196}, -- 1549
			{x = room.minX + 420, y = 162}, -- 1550
			{x = room.minX + 760, y = 224}, -- 1551
			{x = room.maxX + 220, y = 150} -- 1552
		}, -- 1552
		-40, -- 1552
		420, -- 1555
		____exports.MING_MATERIALS.distantHill, -- 1556
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1557
	) -- 1557
	scene:addFogBand( -- 1559
		room.minX - 240, -- 1559
		room.maxX + 240, -- 1559
		-30, -- 1559
		175, -- 1559
		290, -- 1559
		scene.light.fogColor, -- 1559
		0.56, -- 1559
		0.04, -- 1559
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1559
	) -- 1559
	local i = 0 -- 1564
	do -- 1564
		i = 0 -- 1565
		while i < #room.floors do -- 1565
			local fl = room.floors[i + 1] -- 1566
			local isMain = fl.y <= 0.1 -- 1567
			if isMain then -- 1567
				scene:addBox({ -- 1569
					x0 = fl.x0, -- 1570
					x1 = fl.x1, -- 1571
					y0 = -48, -- 1572
					y1 = fl.y, -- 1573
					z0 = -26, -- 1574
					z1 = 88, -- 1575
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1576
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1577
					highlightTopEdge = true -- 1578
				}) -- 1578
			else -- 1578
				scene:addPlankDeck( -- 1582
					fl.x0, -- 1582
					fl.x1, -- 1582
					fl.y, -- 1582
					-24, -- 1582
					52, -- 1582
					5, -- 1582
					11, -- 1582
					____exports.MING_MATERIALS.mingTimber, -- 1582
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1582
				) -- 1582
			end -- 1582
			i = i + 1 -- 1565
		end -- 1565
	end -- 1565
	do -- 1565
		i = 0 -- 1591
		while i < #room.stairs do -- 1591
			scene:addStairFlight( -- 1592
				room.stairs[i + 1], -- 1592
				14, -- 1592
				76, -- 1592
				____exports.MING_MATERIALS.mingStoneStep, -- 1592
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1592
			) -- 1592
			i = i + 1 -- 1591
		end -- 1591
	end -- 1591
	do -- 1591
		i = 0 -- 1599
		while i < #room.solids do -- 1599
			do -- 1599
				local s = room.solids[i + 1] -- 1600
				if s.id == "outside_red_cart" then -- 1600
					goto __continue109 -- 1602
				end -- 1602
				scene:addBox({ -- 1604
					x0 = s.x, -- 1605
					x1 = s.x + s.w, -- 1606
					y0 = s.y, -- 1607
					y1 = s.y + s.h, -- 1608
					z0 = -8, -- 1609
					z1 = 72, -- 1610
					material = ____exports.MING_MATERIALS.mingBrick, -- 1611
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1612
					highlightTopEdge = true -- 1613
				}) -- 1613
				if s.y > 10 then -- 1613
					scene:addBox({ -- 1616
						x0 = s.x, -- 1617
						x1 = s.x + 18, -- 1618
						y0 = 0, -- 1619
						y1 = s.y, -- 1620
						z0 = 32, -- 1621
						z1 = 72, -- 1622
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1623
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1624
						sortBias = -0.08, -- 1625
						edgeWidth = 0.7 -- 1626
					}) -- 1626
					scene:addBox({ -- 1628
						x0 = s.x + s.w - 18, -- 1629
						x1 = s.x + s.w, -- 1630
						y0 = 0, -- 1631
						y1 = s.y, -- 1632
						z0 = 32, -- 1633
						z1 = 72, -- 1634
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1635
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1636
						sortBias = -0.08, -- 1637
						edgeWidth = 0.7 -- 1638
					}) -- 1638
				end -- 1638
			end -- 1638
			::__continue109:: -- 1638
			i = i + 1 -- 1599
		end -- 1599
	end -- 1599
	local arch = room.arch -- 1644
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1644
		scene:addBeveledFrame( -- 1646
			arch.x0, -- 1646
			arch.x1, -- 1646
			arch.y, -- 1646
			arch.y + arch.h, -- 1646
			22, -- 1646
			18, -- 1646
			-10, -- 1646
			64, -- 1646
			____exports.MING_MATERIALS.mingStoneStep, -- 1646
			{ -- 1646
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1647
				innerRimLight = rgba(176, 206, 228, 255), -- 1648
				innerRimStrength = 0.45 -- 1649
			} -- 1649
		) -- 1649
	end -- 1649
	local c = room.cart -- 1654
	if c.bodyW > 0 then -- 1654
		scene:addContactShadow( -- 1656
			cartAxle, -- 1656
			c.baseY, -- 1656
			c.bodyW * 0.62, -- 1656
			14, -- 1656
			0.7, -- 1656
			{bucket = ____exports.LP_BUCKET.PROP} -- 1656
		) -- 1656
		local clothX = cartAxle - c.bodyW * 0.5 -- 1657
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1658
		scene:addWavingQuad3D( -- 1659
			____exports.vec3(clothX - 11, clothTop - 22, -6), -- 1660
			____exports.vec3(clothX + 5, clothTop - 20, -5), -- 1661
			____exports.vec3(clothX + 8, clothTop, -4), -- 1662
			____exports.vec3(clothX - 2, clothTop, -4), -- 1663
			____exports.MING_MATERIALS.mingRedCloth, -- 1664
			{ -- 1665
				ampX = 6, -- 1665
				ampY = 2.2, -- 1665
				phase = time * 3.1, -- 1665
				freqU = 1.8, -- 1665
				freqV = 2.6, -- 1665
				pin = "top" -- 1665
			}, -- 1665
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, subdivX = 3, subdivY = 4} -- 1666
		) -- 1666
	end -- 1666
	scene:addContactShadow( -- 1671
		actorX, -- 1671
		actorY, -- 1671
		15, -- 1671
		11, -- 1671
		0.78, -- 1671
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1671
	) -- 1671
end -- 1537
return ____exports -- 1537