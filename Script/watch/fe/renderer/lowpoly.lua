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
____exports.LP_BUCKET = { -- 116
	BACKDROP = 0, -- 117
	MIDGROUND = 1, -- 118
	WALK_DECK = 2, -- 119
	PROP = 3, -- 120
	FOREGROUND = 4 -- 121
} -- 121
function ____exports.clamp01(v) -- 202
	return math.max( -- 203
		0, -- 203
		math.min(1, v) -- 203
	) -- 203
end -- 202
function ____exports.smoothstep(edge0, edge1, x) -- 206
	if edge1 <= edge0 then -- 206
		return x >= edge1 and 1 or 0 -- 208
	end -- 208
	local t = ____exports.clamp01((x - edge0) / (edge1 - edge0)) -- 210
	return t * t * (3 - 2 * t) -- 211
end -- 206
function ____exports.vec3(x, y, z) -- 214
	return {x = x, y = y, z = z} -- 215
end -- 214
function ____exports.normalize3(v) -- 218
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) -- 219
	if len < 0.00001 then -- 219
		return {x = 0, y = 1, z = 0} -- 221
	end -- 221
	return {x = v.x / len, y = v.y / len, z = v.z / len} -- 223
end -- 218
local function dot3(a, b) -- 226
	return a.x * b.x + a.y * b.y + a.z * b.z -- 227
end -- 226
local function cross3(a, b) -- 230
	return {x = a.y * b.z - a.z * b.y, y = a.z * b.x - a.x * b.z, z = a.x * b.y - a.y * b.x} -- 231
end -- 230
local function sub3(a, b) -- 238
	return {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z} -- 239
end -- 238
local function clampByte(v) -- 242
	return math.max( -- 243
		0, -- 243
		math.min( -- 243
			255, -- 243
			math.floor(v + 0.5) -- 243
		) -- 243
	) -- 243
end -- 242
local function scaleRGBA(c, k, alphaMul) -- 246
	if alphaMul == nil then -- 246
		alphaMul = 1 -- 246
	end -- 246
	return { -- 247
		r = clampByte(c.r * k), -- 248
		g = clampByte(c.g * k), -- 249
		b = clampByte(c.b * k), -- 250
		a = clampByte(c.a * alphaMul) -- 251
	} -- 251
end -- 246
--- 明初温州宁村所海防卫城 2.5D 微缩剧场材质预设（全量接入 tex_diorama_ming 纹理 + 高灰度区分度）
____exports.MING_MATERIALS = { -- 256
	mingBrick = { -- 257
		base = rgba(96, 102, 112, 255), -- 258
		edge = rgba(154, 162, 174, 120), -- 259
		minShade = 0.34, -- 260
		rimBoost = 0.24, -- 261
		bottomAo = 0.26, -- 262
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 263
		textureTint = rgba(212, 218, 228, 255), -- 264
		subdivX = 3, -- 265
		subdivY = 2 -- 266
	}, -- 266
	mingBrickDark = { -- 268
		base = rgba(54, 60, 72, 255), -- 269
		edge = rgba(108, 118, 134, 100), -- 270
		minShade = 0.28, -- 271
		rimBoost = 0.18, -- 272
		bottomAo = 0.32, -- 273
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 274
		textureTint = rgba(146, 154, 168, 255), -- 275
		subdivX = 3, -- 276
		subdivY = 2 -- 277
	}, -- 277
	mingTimber = { -- 279
		base = rgba(114, 84, 62, 255), -- 280
		edge = rgba(168, 134, 104, 120), -- 281
		minShade = 0.3, -- 282
		rimBoost = 0.22, -- 283
		bottomAo = 0.26, -- 284
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 285
		textureTint = rgba(224, 206, 186, 255), -- 286
		subdivX = 3, -- 287
		subdivY = 2 -- 288
	}, -- 288
	mingTimberDark = { -- 290
		base = rgba(68, 50, 38, 255), -- 291
		edge = rgba(122, 96, 76, 105), -- 292
		minShade = 0.24, -- 293
		rimBoost = 0.16, -- 294
		bottomAo = 0.34, -- 295
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 296
		textureTint = rgba(148, 132, 118, 255), -- 297
		subdivX = 2, -- 298
		subdivY = 2 -- 299
	}, -- 299
	mingStoneStep = { -- 301
		base = rgba(118, 122, 128, 255), -- 302
		edge = rgba(188, 194, 200, 140), -- 303
		minShade = 0.32, -- 304
		rimBoost = 0.26, -- 305
		bottomAo = 0.24, -- 306
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_stone", -- 307
		textureTint = rgba(210, 216, 224, 255), -- 308
		subdivX = 2, -- 309
		subdivY = 2 -- 310
	}, -- 310
	mingPlaster = { -- 312
		base = rgba(116, 110, 100, 255), -- 313
		edge = rgba(164, 156, 144, 100), -- 314
		minShade = 0.28, -- 315
		rimBoost = 0.18, -- 316
		bottomAo = 0.32, -- 317
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_plaster", -- 318
		textureTint = rgba(196, 192, 182, 255), -- 319
		subdivX = 3, -- 320
		subdivY = 2 -- 321
	}, -- 321
	mingIron = { -- 323
		base = rgba(46, 52, 62, 255), -- 324
		edge = rgba(136, 146, 158, 130), -- 325
		minShade = 0.28, -- 326
		rimBoost = 0.3, -- 327
		bottomAo = 0.24, -- 328
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_iron", -- 329
		textureTint = rgba(178, 186, 198, 255), -- 330
		subdivX = 2, -- 331
		subdivY = 2 -- 332
	}, -- 332
	mingTile = { -- 334
		base = rgba(44, 52, 66, 255), -- 335
		edge = rgba(102, 116, 136, 110), -- 336
		minShade = 0.28, -- 337
		rimBoost = 0.2, -- 338
		bottomAo = 0.22, -- 339
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_tile", -- 340
		textureTint = rgba(176, 188, 206, 255), -- 341
		subdivX = 3, -- 342
		subdivY = 2 -- 343
	}, -- 343
	mingRedCloth = { -- 345
		base = rgba(176, 52, 48, 255), -- 346
		edge = rgba(224, 116, 102, 140), -- 347
		minShade = 0.42, -- 348
		rimBoost = 0.24, -- 349
		bottomAo = 0.16, -- 350
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 351
		textureTint = rgba(218, 68, 60, 255), -- 352
		subdivX = 3, -- 353
		subdivY = 3 -- 354
	}, -- 354
	mingHempCloth = { -- 356
		base = rgba(136, 128, 114, 255), -- 357
		edge = rgba(182, 174, 158, 110), -- 358
		minShade = 0.26, -- 359
		rimBoost = 0.18, -- 360
		bottomAo = 0.28, -- 361
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 362
		textureTint = rgba(172, 166, 152, 255), -- 363
		subdivX = 3, -- 364
		subdivY = 3 -- 365
	}, -- 365
	mingWater = { -- 367
		base = rgba(28, 44, 56, 255), -- 368
		edge = rgba(124, 156, 174, 90), -- 369
		minShade = 0.42, -- 370
		rimBoost = 0.22, -- 371
		bottomAo = 0.1, -- 372
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_water", -- 373
		textureTint = rgba(182, 208, 220, 255), -- 374
		subdivX = 6, -- 375
		subdivY = 3 -- 376
	}, -- 376
	distantWall = { -- 378
		base = rgba(42, 52, 68, 255), -- 379
		edge = rgba(98, 114, 136, 85), -- 380
		minShade = 0.38, -- 381
		rimBoost = 0.14, -- 382
		bottomAo = 0.2, -- 383
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 384
		textureTint = rgba(126, 140, 162, 255), -- 385
		subdivX = 2, -- 386
		subdivY = 1 -- 387
	}, -- 387
	distantHill = { -- 389
		base = rgba(28, 38, 54, 255), -- 390
		edge = rgba(74, 92, 116, 70), -- 391
		minShade = 0.38, -- 392
		rimBoost = 0.12, -- 393
		bottomAo = 0.2 -- 394
	} -- 394
} -- 394
--- 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光）
____exports.GATE_NIGHTMARE_LIGHT = { -- 399
	keyDir = ____exports.normalize3(____exports.vec3(-0.62, 0.64, -0.45)), -- 400
	keyColor = rgba(206, 224, 240, 255), -- 401
	keyStrength = 0.88, -- 402
	rimDir = ____exports.normalize3(____exports.vec3(0.76, 0.36, -0.54)), -- 403
	rimColor = rgba(224, 196, 150, 255), -- 404
	rimStrength = 0.34, -- 405
	ambientColor = rgba(26, 34, 48, 255), -- 406
	fogColor = rgba(26, 36, 52, 255), -- 407
	fogStartZ = 36, -- 408
	fogEndZ = 560, -- 409
	fogMaxAlpha = 0.84, -- 410
	shadowContrast = 0.72 -- 411
} -- 411
____exports.OUTSIDE_JETTY_LIGHT = { -- 414
	keyDir = ____exports.normalize3(____exports.vec3(-0.56, 0.68, -0.48)), -- 415
	keyColor = rgba(196, 214, 232, 255), -- 416
	keyStrength = 0.86, -- 417
	rimDir = ____exports.normalize3(____exports.vec3(0.78, 0.32, -0.54)), -- 418
	rimColor = rgba(226, 188, 136, 255), -- 419
	rimStrength = 0.32, -- 420
	ambientColor = rgba(24, 32, 46, 255), -- 421
	fogColor = rgba(24, 34, 50, 255), -- 422
	fogStartZ = 42, -- 423
	fogEndZ = 520, -- 424
	fogMaxAlpha = 0.8, -- 425
	shadowContrast = 0.74 -- 426
} -- 426
____exports.VILLAGE_UNDERTABLE_LIGHT = { -- 429
	keyDir = ____exports.normalize3(____exports.vec3(0.72, 0.44, -0.54)), -- 430
	keyColor = rgba(214, 208, 194, 255), -- 431
	keyStrength = 0.92, -- 432
	rimDir = ____exports.normalize3(____exports.vec3(-0.64, 0.52, -0.56)), -- 433
	rimColor = rgba(146, 166, 186, 255), -- 434
	rimStrength = 0.28, -- 435
	ambientColor = rgba(18, 22, 30, 255), -- 436
	fogColor = rgba(22, 26, 34, 255), -- 437
	fogStartZ = 55, -- 438
	fogEndZ = 460, -- 439
	fogMaxAlpha = 0.78, -- 440
	shadowContrast = 0.82 -- 441
} -- 441
____exports.FOREST_CREEK_LIGHT = { -- 444
	keyDir = ____exports.normalize3(____exports.vec3(-0.48, 0.74, -0.47)), -- 445
	keyColor = rgba(178, 206, 202, 255), -- 446
	keyStrength = 0.8, -- 447
	rimDir = ____exports.normalize3(____exports.vec3(0.82, 0.28, -0.5)), -- 448
	rimColor = rgba(232, 196, 132, 255), -- 449
	rimStrength = 0.36, -- 450
	ambientColor = rgba(18, 30, 34, 255), -- 451
	fogColor = rgba(20, 34, 38, 255), -- 452
	fogStartZ = 34, -- 453
	fogEndZ = 480, -- 454
	fogMaxAlpha = 0.86, -- 455
	shadowContrast = 0.76 -- 456
} -- 456
____exports.TOWER_WEST_LAMP_LIGHT = { -- 459
	keyDir = ____exports.normalize3(____exports.vec3(-0.74, 0.48, -0.47)), -- 460
	keyColor = rgba(242, 202, 138, 255), -- 461
	keyStrength = 0.94, -- 462
	rimDir = ____exports.normalize3(____exports.vec3(0.62, 0.54, -0.57)), -- 463
	rimColor = rgba(142, 168, 198, 255), -- 464
	rimStrength = 0.26, -- 465
	ambientColor = rgba(24, 26, 36, 255), -- 466
	fogColor = rgba(24, 28, 40, 255), -- 467
	fogStartZ = 60, -- 468
	fogEndZ = 480, -- 469
	fogMaxAlpha = 0.72, -- 470
	shadowContrast = 0.7 -- 471
} -- 471
--- 核心 2.5D 低模投影：
-- 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
function ____exports.projectWorld3D(wx, wy, wz, cam, proj) -- 478
	local bx = cam:sx(wx) -- 485
	local by = cam:sy(wy, proj.baseDepth or 0) -- 486
	local m = ____exports.clamp01(proj.morph) -- 487
	if m <= 0.00001 or math.abs(wz) <= 0.00001 then -- 487
		return {x = bx, y = by, scale = 1, zEff = 0} -- 489
	end -- 489
	local focal = math.max(60, proj.focal) -- 491
	local zEff = wz * m -- 492
	local denom = math.max(focal * 0.22, focal + zEff) -- 493
	local s = focal / denom -- 494
	local vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX or 0) -- 495
	local vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY or 0) -- 496
	return {x = vpX + (bx - vpX) * s, y = vpY + (by - vpY) * s, scale = s, zEff = zEff} -- 497
end -- 478
--- 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
-- 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
function ____exports.verifyWalkPlaneAlignment(cam, proj, wx, wy) -- 509
	local p3 = ____exports.projectWorld3D( -- 515
		wx, -- 515
		wy, -- 515
		0, -- 515
		cam, -- 515
		proj -- 515
	) -- 515
	local p2 = cam:worldToScreen(wx, wy, proj.baseDepth or 0) -- 516
	local fwdDx = p3.x - p2.x -- 517
	local fwdDy = p3.y - p2.y -- 518
	local forwardErrPx = math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy) -- 519
	local inv = cam:screenToWorld(p3.x, p3.y) -- 521
	local invDx = inv.x - wx -- 522
	local invDy = inv.y - (wy + (proj.baseDepth or 0) * DEPTH_Y_SCALE) -- 523
	local inverseErrWorld = math.sqrt(invDx * invDx + invDy * invDy) -- 524
	return {forwardErrPx = forwardErrPx, inverseErrWorld = inverseErrWorld, screenX = p3.x, screenY = p3.y} -- 525
end -- 509
--- 计算给定法线与深度的低模平面受光+雾效颜色
function ____exports.shadeSurface(base, normal, avgZ, morph, light, mat, opacityMul) -- 534
	if opacityMul == nil then -- 534
		opacityMul = 1 -- 541
	end -- 541
	local m = ____exports.clamp01(morph) -- 543
	local n = ____exports.normalize3(normal) -- 544
	local ndl = math.max( -- 545
		0, -- 545
		dot3(n, light.keyDir) -- 545
	) -- 545
	local ndr = math.max( -- 546
		0, -- 546
		dot3(n, light.rimDir) -- 546
	) -- 546
	local minShade = mat and mat.minShade or 0.28 -- 547
	local rimBoost = mat and mat.rimBoost or 0.2 -- 548
	local contrast = light.shadowContrast * (0.45 + 0.55 * m) -- 549
	local keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25) -- 551
	local rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost) -- 552
	local rLit = base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255) + light.ambientColor.r * (0.28 * (1 - ndl * 0.5)) + light.rimColor.r * rimFactor * 0.45 -- 554
	local gLit = base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255) + light.ambientColor.g * (0.28 * (1 - ndl * 0.5)) + light.rimColor.g * rimFactor * 0.45 -- 557
	local bLit = base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255) + light.ambientColor.b * (0.28 * (1 - ndl * 0.5)) + light.rimColor.b * rimFactor * 0.45 -- 560
	local lit = { -- 564
		r = clampByte(rLit), -- 565
		g = clampByte(gLit), -- 566
		b = clampByte(bLit), -- 567
		a = clampByte(base.a * ____exports.clamp01(opacityMul)) -- 568
	} -- 568
	if avgZ > light.fogStartZ and m > 0.01 then -- 568
		local span = math.max(1, light.fogEndZ - light.fogStartZ) -- 572
		local fogT = ____exports.clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m -- 573
		local mixed = lerpRGBA(lit, light.fogColor, fogT) -- 574
		mixed.a = lit.a -- 575
		return mixed -- 576
	end -- 576
	return lit -- 578
end -- 534
--- 画家算法低模场景批处理器：
-- 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
____exports.LowpolyScene = __TS__Class() -- 585
local LowpolyScene = ____exports.LowpolyScene -- 585
LowpolyScene.name = "LowpolyScene" -- 585
function LowpolyScene.prototype.____constructor(self, cam, proj, light) -- 592
	if light == nil then -- 592
		light = ____exports.GATE_NIGHTMARE_LIGHT -- 592
	end -- 592
	self.faces = {} -- 589
	self.glows = {} -- 590
	self.cam = cam -- 593
	self.proj = proj -- 594
	self.light = light -- 595
end -- 592
function LowpolyScene.prototype.getFaceCount(self) -- 598
	return #self.faces -- 599
end -- 598
function LowpolyScene.prototype.project(self, wx, wy, wz) -- 602
	return ____exports.projectWorld3D( -- 603
		wx, -- 603
		wy, -- 603
		wz, -- 603
		self.cam, -- 603
		self.proj -- 603
	) -- 603
end -- 602
function LowpolyScene.prototype.vanishingPointScreen(self) -- 606
	return {x = self.cam.viewW * self.proj.vpFracX + (self.proj.vpOffsetX or 0), y = self.cam.viewH * self.proj.vpFracY + (self.proj.vpOffsetY or 0)} -- 607
end -- 606
function LowpolyScene.prototype.addQuad3D(self, v0, v1, v2, v3, mat, opts) -- 614
	if opts == nil then -- 614
		opts = {} -- 620
	end -- 620
	local opacity = opts.opacity or 1 -- 622
	if opacity <= 0.01 then -- 622
		return -- 624
	end -- 624
	local p0 = self:project(v0.x, v0.y, v0.z) -- 626
	local p1 = self:project(v1.x, v1.y, v1.z) -- 627
	local p2 = self:project(v2.x, v2.y, v2.z) -- 628
	local p3 = self:project(v3.x, v3.y, v3.z) -- 629
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y)) -- 632
	if area2 < 0.25 then -- 632
		return -- 637
	end -- 637
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z + v3.z) * 0.25 -- 640
	local topRgba -- 641
	local texTint -- 642
	local hasTex = mat.texture ~= nil and mat.texture ~= "" -- 643
	if opts.unlit == true then -- 643
		topRgba = scaleRGBA(mat.base, 1, opacity) -- 645
		if hasTex then -- 645
			local tb = mat.textureTint or rgba(235, 238, 244, 255) -- 647
			texTint = toColor(tb, 255) -- 648
		end -- 648
	else -- 648
		local n = cross3( -- 651
			sub3(v1, v0), -- 651
			sub3(v3, v0) -- 651
		) -- 651
		topRgba = ____exports.shadeSurface( -- 652
			mat.base, -- 652
			n, -- 652
			avgZ, -- 652
			self.proj.morph, -- 652
			self.light, -- 652
			mat, -- 652
			opacity -- 652
		) -- 652
		if hasTex then -- 652
			local tb = mat.textureTint or rgba(224, 228, 236, 255) -- 655
			local litTex = ____exports.shadeSurface( -- 656
				tb, -- 656
				n, -- 656
				avgZ, -- 656
				self.proj.morph, -- 656
				self.light, -- 656
				mat, -- 656
				1 -- 656
			) -- 656
			texTint = toColor(litTex, 255) -- 657
		end -- 657
	end -- 657
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.22) -- 661
	local botRgba = ao > 0.005 and scaleRGBA( -- 662
		topRgba, -- 662
		math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)), -- 662
		1 -- 662
	) or topRgba -- 662
	local cBot = toColor(botRgba) -- 663
	local cTop = toColor(topRgba) -- 664
	local edgeRgba = opts.edgeColor or mat.edge -- 667
	local edgeW = hasTex and 0 or (opts.edgeWidth or 0) -- 668
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 669
		edgeRgba, -- 670
		math.floor(edgeRgba.a * opacity + 0.5) -- 670
	) or nil -- 670
	local ____self_faces_11 = self.faces -- 673
	local ____temp_5 = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 674
	local ____temp_6 = opts.sortBias or 0 -- 676
	local ____temp_7 = {p0, p1, p2, p3} -- 677
	local ____temp_8 = {cBot, cBot, cTop, cTop} -- 678
	local ____edgeCol_9 = edgeCol -- 679
	local ____temp_10 = hasTex and ({v0, v1, v2, v3}) or nil -- 682
	local ____hasTex_4 -- 683
	if hasTex then -- 683
		____hasTex_4 = mat.texture -- 683
	else -- 683
		____hasTex_4 = nil -- 683
	end -- 683
	____self_faces_11[#____self_faces_11 + 1] = { -- 673
		bucket = ____temp_5, -- 674
		sortZ = avgZ, -- 675
		sortBias = ____temp_6, -- 676
		pts = ____temp_7, -- 677
		cols = ____temp_8, -- 678
		edgeCol = ____edgeCol_9, -- 679
		edgeWidth = edgeW, -- 680
		topHighlight = nil, -- 681
		worldQuad = ____temp_10, -- 682
		texture = ____hasTex_4, -- 683
		texTint = texTint, -- 684
		texOpacity = opacity, -- 685
		subdivX = opts.subdivX or mat.subdivX or 2, -- 686
		subdivY = opts.subdivY or mat.subdivY or 2, -- 687
		wave = opts.wave, -- 688
		additive = opts.additive -- 689
	} -- 689
end -- 614
function LowpolyScene.prototype.addWavingQuad3D(self, v0, v1, v2, v3, mat, wave, opts) -- 694
	if opts == nil then -- 694
		opts = {} -- 701
	end -- 701
	self:addQuad3D( -- 703
		v0, -- 703
		v1, -- 703
		v2, -- 703
		v3, -- 703
		mat, -- 703
		__TS__ObjectAssign({}, opts, {wave = wave, subdivX = opts.subdivX or mat.subdivX or 4, subdivY = opts.subdivY or mat.subdivY or 3}) -- 703
	) -- 703
end -- 694
function LowpolyScene.prototype.addCutout3D(self, clipStr, wx, wy, wz, worldW, worldH, opts) -- 715
	if opts == nil then -- 715
		opts = {} -- 722
	end -- 722
	local opacity = opts.opacity or 1 -- 724
	if opacity <= 0.01 or worldW <= 0.5 or worldH <= 0.5 then -- 724
		return -- 726
	end -- 726
	local pt = self:project(wx, wy, wz) -- 728
	local screenW = self.cam:len(worldW) * pt.scale -- 729
	local screenH = self.cam:len(worldH) * pt.scale -- 730
	if screenW < 1 or screenH < 1 then -- 730
		return -- 732
	end -- 732
	local baseTint = opts.tint or rgba(240, 244, 248, 255) -- 734
	local finalRgba = baseTint -- 735
	if opts.unlit ~= true then -- 735
		local m = ____exports.clamp01(self.proj.morph) -- 737
		if wz > self.light.fogStartZ and m > 0.01 then -- 737
			local span = math.max(1, self.light.fogEndZ - self.light.fogStartZ) -- 739
			local fogT = ____exports.clamp01((wz - self.light.fogStartZ) / span) * self.light.fogMaxAlpha * 0.72 * m -- 740
			finalRgba = lerpRGBA(baseTint, self.light.fogColor, fogT) -- 741
		end -- 741
	end -- 741
	local ____self_faces_12 = self.faces -- 741
	____self_faces_12[#____self_faces_12 + 1] = { -- 744
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 745
		sortZ = wz, -- 746
		sortBias = opts.sortBias or 0, -- 747
		pts = {}, -- 748
		cols = {}, -- 749
		edgeCol = nil, -- 750
		edgeWidth = 0, -- 751
		topHighlight = nil, -- 752
		cutout = { -- 753
			clipStr = clipStr, -- 754
			x = pt.x, -- 755
			y = pt.y, -- 756
			w = screenW, -- 757
			h = screenH, -- 758
			anchorX = opts.anchorX or 0.5, -- 759
			anchorY = opts.anchorY or 0, -- 760
			facing = opts.facing or 1, -- 761
			flipY = opts.flipY == true, -- 762
			angle = opts.angle or 0, -- 763
			color = toColor(finalRgba, 255), -- 764
			opacity = opacity, -- 765
			smooth = opts.smooth ~= false, -- 766
			additive = opts.additive == true -- 767
		} -- 767
	} -- 767
end -- 715
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 773
	if opts == nil then -- 773
		opts = {} -- 778
	end -- 778
	local opacity = opts.opacity or 1 -- 780
	if opacity <= 0.01 then -- 780
		return -- 782
	end -- 782
	local p0 = self:project(v0.x, v0.y, v0.z) -- 784
	local p1 = self:project(v1.x, v1.y, v1.z) -- 785
	local p2 = self:project(v2.x, v2.y, v2.z) -- 786
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 788
	if area2 < 0.25 then -- 788
		return -- 790
	end -- 790
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 793
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 794
		mat.base, -- 796
		cross3( -- 796
			sub3(v1, v0), -- 796
			sub3(v2, v0) -- 796
		), -- 796
		avgZ, -- 796
		self.proj.morph, -- 796
		self.light, -- 796
		mat, -- 796
		opacity -- 796
	) -- 796
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 797
	local botRgba = ao > 0.005 and scaleRGBA( -- 798
		colRgba, -- 798
		math.max(0.4, 1 - ao), -- 798
		1 -- 798
	) or colRgba -- 798
	local edgeRgba = opts.edgeColor or mat.edge -- 800
	local edgeW = opts.edgeWidth or 0 -- 801
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 802
		edgeRgba, -- 803
		math.floor(edgeRgba.a * opacity + 0.5) -- 803
	) or nil -- 803
	local ____self_faces_13 = self.faces -- 803
	____self_faces_13[#____self_faces_13 + 1] = { -- 806
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 807
		sortZ = avgZ, -- 808
		sortBias = opts.sortBias or 0, -- 809
		pts = {p0, p1, p2}, -- 810
		cols = { -- 811
			toColor(botRgba), -- 811
			toColor(botRgba), -- 811
			toColor(colRgba) -- 811
		}, -- 811
		edgeCol = edgeCol, -- 812
		edgeWidth = edgeW, -- 813
		topHighlight = nil -- 814
	} -- 814
end -- 773
function LowpolyScene.prototype.addBox(self, spec) -- 822
	local opacity = spec.opacity or 1 -- 823
	if opacity <= 0.01 then -- 823
		return -- 825
	end -- 825
	local x0 = math.min(spec.x0, spec.x1) -- 827
	local x1 = math.max(spec.x0, spec.x1) -- 828
	local y0 = math.min(spec.y0, spec.y1) -- 829
	local y1 = math.max(spec.y0, spec.y1) -- 830
	local z0 = math.min(spec.z0, spec.z1) -- 831
	local z1 = math.max(spec.z0, spec.z1) -- 832
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 834
	local bias = spec.sortBias or 0 -- 835
	local hasTex = spec.material.texture ~= nil and spec.material.texture ~= "" -- 836
	local edgeW = hasTex and 0 or (spec.edgeWidth or 0) -- 837
	local midZ = (z0 + z1) * 0.5 -- 838
	local vp = self:vanishingPointScreen() -- 839
	local m = ____exports.clamp01(self.proj.morph) -- 840
	local sx0 = self.cam:sx(x0) -- 842
	local sx1 = self.cam:sx(x1) -- 843
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 844
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 845
	if m > 0.002 and z1 - z0 > 0.05 then -- 845
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 845
			self:addQuad3D( -- 850
				____exports.vec3(x0, y0, z1), -- 851
				____exports.vec3(x0, y0, z0), -- 852
				____exports.vec3(x0, y1, z0), -- 853
				____exports.vec3(x0, y1, z1), -- 854
				spec.material, -- 855
				{ -- 856
					bucket = bucket, -- 856
					sortZOverride = midZ + 0.4, -- 856
					sortBias = bias - 0.1, -- 856
					opacity = opacity, -- 856
					edgeWidth = edgeW -- 856
				} -- 856
			) -- 856
		end -- 856
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 856
			self:addQuad3D( -- 861
				____exports.vec3(x1, y0, z0), -- 862
				____exports.vec3(x1, y0, z1), -- 863
				____exports.vec3(x1, y1, z1), -- 864
				____exports.vec3(x1, y1, z0), -- 865
				spec.material, -- 866
				{ -- 867
					bucket = bucket, -- 867
					sortZOverride = midZ + 0.4, -- 867
					sortBias = bias - 0.1, -- 867
					opacity = opacity, -- 867
					edgeWidth = edgeW -- 867
				} -- 867
			) -- 867
		end -- 867
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 867
			self:addQuad3D( -- 872
				____exports.vec3(x0, y1, z0), -- 873
				____exports.vec3(x1, y1, z0), -- 874
				____exports.vec3(x1, y1, z1), -- 875
				____exports.vec3(x0, y1, z1), -- 876
				spec.material, -- 877
				{ -- 878
					bucket = bucket, -- 878
					sortZOverride = midZ + 0.2, -- 878
					sortBias = bias - 0.05, -- 878
					opacity = opacity, -- 878
					edgeWidth = edgeW, -- 878
					bottomAo = 0.08 -- 878
				} -- 878
			) -- 878
		end -- 878
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 878
			self:addQuad3D( -- 883
				____exports.vec3(x0, y0, z1), -- 884
				____exports.vec3(x1, y0, z1), -- 885
				____exports.vec3(x1, y0, z0), -- 886
				____exports.vec3(x0, y0, z0), -- 887
				spec.material, -- 888
				{ -- 889
					bucket = bucket, -- 889
					sortZOverride = midZ + 0.2, -- 889
					sortBias = bias - 0.05, -- 889
					opacity = opacity, -- 889
					edgeWidth = edgeW, -- 889
					bottomAo = 0.34 -- 889
				} -- 889
			) -- 889
		end -- 889
	end -- 889
	if spec.skipFront ~= true then -- 889
		local beforeLen = #self.faces -- 896
		self:addQuad3D( -- 897
			____exports.vec3(x0, y0, z0), -- 898
			____exports.vec3(x1, y0, z0), -- 899
			____exports.vec3(x1, y1, z0), -- 900
			____exports.vec3(x0, y1, z0), -- 901
			spec.material, -- 902
			{ -- 903
				bucket = bucket, -- 903
				sortZOverride = z0, -- 903
				sortBias = bias, -- 903
				opacity = opacity, -- 903
				edgeWidth = edgeW -- 903
			} -- 903
		) -- 903
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 903
			local face = self.faces[#self.faces] -- 906
			local rimCol = spec.material.edge or rgba(198, 206, 214, 110) -- 907
			local rimAlpha = math.floor(math.min(hasTex and 96 or 165, rimCol.a * (hasTex and 0.62 or 0.95)) * opacity + 0.5) -- 909
			face.topHighlight = { -- 910
				face.pts[4], -- 911
				face.pts[3], -- 912
				toColor(rimCol, rimAlpha) -- 913
			} -- 913
		end -- 913
	end -- 913
end -- 822
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 923
	if opts == nil then -- 923
		opts = {} -- 933
	end -- 933
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 941
	local opacity = opts.opacity or 1 -- 942
	local bias = opts.sortBias or 0 -- 943
	self:addBox({ -- 946
		x0 = openX0 - pillarW, -- 947
		x1 = openX0, -- 948
		y0 = y0, -- 949
		y1 = openY1 + lintelH, -- 950
		z0 = z0, -- 951
		z1 = z1, -- 952
		material = mat, -- 953
		bucket = bucket, -- 954
		sortBias = bias, -- 955
		opacity = opacity, -- 956
		highlightTopEdge = true -- 957
	}) -- 957
	self:addBox({ -- 960
		x0 = openX1, -- 961
		x1 = openX1 + pillarW, -- 962
		y0 = y0, -- 963
		y1 = openY1 + lintelH, -- 964
		z0 = z0, -- 965
		z1 = z1, -- 966
		material = mat, -- 967
		bucket = bucket, -- 968
		sortBias = bias, -- 969
		opacity = opacity, -- 970
		highlightTopEdge = true -- 971
	}) -- 971
	self:addBox({ -- 974
		x0 = openX0 - pillarW * 0.2, -- 975
		x1 = openX1 + pillarW * 0.2, -- 976
		y0 = openY1, -- 977
		y1 = openY1 + lintelH, -- 978
		z0 = z0, -- 979
		z1 = z1, -- 980
		material = mat, -- 981
		bucket = bucket, -- 982
		sortBias = bias + 0.05, -- 983
		opacity = opacity, -- 984
		highlightTopEdge = true -- 985
	}) -- 985
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 989
	if rimAlpha > 0.02 then -- 989
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 991
		local p0 = self:project(openX0, y0 + 2, z0) -- 992
		local p1 = self:project(openX0, y0 + 2, z1) -- 993
		local p2 = self:project(openX0, openY1 - 2, z1) -- 994
		local p3 = self:project(openX0, openY1 - 2, z0) -- 995
		local cNear = toColor( -- 996
			rimCol, -- 996
			math.floor(135 * rimAlpha + 0.5) -- 996
		) -- 996
		local cFar = toColor( -- 997
			rimCol, -- 997
			math.floor(28 * rimAlpha + 0.5) -- 997
		) -- 997
		local ____self_glows_14 = self.glows -- 997
		____self_glows_14[#____self_glows_14 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 998
	end -- 998
end -- 923
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 1006
	if mat == nil then -- 1006
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 1010
	end -- 1010
	if opts == nil then -- 1010
		opts = {} -- 1011
	end -- 1011
	local n = math.max(1, stair.steps + 1) -- 1013
	local stepW = (stair.x1 - stair.x0) / n -- 1014
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 1015
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1016
	local opacity = opts.opacity or 1 -- 1017
	local bias = opts.sortBias or 0 -- 1018
	local k = 0 -- 1020
	do -- 1020
		k = 0 -- 1021
		while k < n do -- 1021
			do -- 1021
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 1022
				local wx0 = stair.x0 + stepW * k -- 1023
				local wx1 = wx0 + stepW -- 1024
				if wy <= floorY + 1 then -- 1024
					goto __continue51 -- 1026
				end -- 1026
				self:addBox({ -- 1028
					x0 = wx0, -- 1029
					x1 = wx1, -- 1030
					y0 = floorY, -- 1031
					y1 = wy, -- 1032
					z0 = z0, -- 1033
					z1 = z1, -- 1034
					material = mat, -- 1035
					bucket = bucket, -- 1036
					sortBias = bias + k * 0.01, -- 1037
					opacity = opacity, -- 1038
					highlightTopEdge = true, -- 1039
					edgeWidth = 0.9 -- 1040
				}) -- 1040
			end -- 1040
			::__continue51:: -- 1040
			k = k + 1 -- 1021
		end -- 1021
	end -- 1021
end -- 1006
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 1049
	if mat == nil then -- 1049
		mat = ____exports.MING_MATERIALS.mingTimber -- 1057
	end -- 1057
	if opts == nil then -- 1057
		opts = {} -- 1058
	end -- 1058
	local count = math.max( -- 1066
		1, -- 1066
		math.floor(plankCount) -- 1066
	) -- 1066
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1067
	local opacity = opts.opacity or 1 -- 1068
	local bias = opts.sortBias or 0 -- 1069
	local spanZ = math.max(1, z1 - z0) -- 1070
	local gap = math.min(2.6, spanZ / (count * 6)) -- 1071
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 1072
	if opts.withPosts == true then -- 1072
		local postBot = opts.postBottomY or topY - 92 -- 1076
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 1077
		local postCount = math.max( -- 1078
			2, -- 1078
			math.min( -- 1078
				5, -- 1078
				math.floor((x1 - x0) / 110) + 1 -- 1078
			) -- 1078
		) -- 1078
		local pi = 0 -- 1079
		do -- 1079
			pi = 0 -- 1080
			while pi < postCount do -- 1080
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 1081
				self:addBox({ -- 1082
					x0 = px - 6, -- 1083
					x1 = px + 6, -- 1084
					y0 = postBot, -- 1085
					y1 = topY - thickness, -- 1086
					z0 = z0 + 4, -- 1087
					z1 = z0 + 18, -- 1088
					material = postMat, -- 1089
					bucket = bucket, -- 1090
					sortBias = bias - 0.3, -- 1091
					opacity = opacity, -- 1092
					edgeWidth = 0.7 -- 1093
				}) -- 1093
				pi = pi + 1 -- 1080
			end -- 1080
		end -- 1080
	end -- 1080
	local i = 0 -- 1099
	do -- 1099
		i = 0 -- 1100
		while i < count do -- 1100
			local pz0 = z0 + i * (plankDepth + gap) -- 1101
			local pz1 = pz0 + plankDepth -- 1102
			local plankMat = i & 1 == 0 and mat or ({ -- 1103
				base = scaleRGBA(mat.base, 0.88), -- 1106
				edge = mat.edge, -- 1107
				minShade = mat.minShade, -- 1108
				rimBoost = mat.rimBoost, -- 1109
				bottomAo = mat.bottomAo, -- 1110
				texture = mat.texture, -- 1111
				textureTint = mat.textureTint ~= nil and scaleRGBA(mat.textureTint, 0.9) or nil, -- 1112
				subdivX = mat.subdivX, -- 1113
				subdivY = mat.subdivY -- 1114
			}) -- 1114
			self:addBox({ -- 1116
				x0 = x0, -- 1117
				x1 = x1, -- 1118
				y0 = topY - thickness, -- 1119
				y1 = topY, -- 1120
				z0 = pz0, -- 1121
				z1 = pz1, -- 1122
				material = plankMat, -- 1123
				bucket = bucket, -- 1124
				sortBias = bias + (count - i) * 0.01, -- 1125
				opacity = opacity, -- 1126
				highlightTopEdge = i == 0, -- 1127
				edgeWidth = 0.8 -- 1128
			}) -- 1128
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
end -- 1049
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 1134
	if mat == nil then -- 1134
		mat = ____exports.MING_MATERIALS.distantHill -- 1138
	end -- 1138
	if opts == nil then -- 1138
		opts = {} -- 1139
	end -- 1139
	if #peaks < 2 then -- 1139
		return -- 1142
	end -- 1142
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 1144
	local opacity = opts.opacity or 1 -- 1145
	local bias = opts.sortBias or 0 -- 1146
	local i = 0 -- 1148
	do -- 1148
		i = 0 -- 1149
		while i < #peaks - 1 do -- 1149
			local a = peaks[i + 1] -- 1150
			local b = peaks[i + 1 + 1] -- 1151
			local midX = (a.x + b.x) * 0.5 -- 1152
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 1153
			local ridgeMat = b.y >= a.y and mat or ({ -- 1154
				base = scaleRGBA(mat.base, 0.84), -- 1157
				edge = mat.edge, -- 1158
				minShade = mat.minShade, -- 1159
				rimBoost = mat.rimBoost, -- 1160
				bottomAo = mat.bottomAo -- 1161
			}) -- 1161
			self:addTri3D( -- 1163
				____exports.vec3(a.x, baseY, z), -- 1164
				____exports.vec3(b.x, baseY, z), -- 1165
				____exports.vec3(a.x, a.y, z), -- 1166
				ridgeMat, -- 1167
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 1168
			) -- 1168
			self:addTri3D( -- 1170
				____exports.vec3(b.x, baseY, z), -- 1171
				____exports.vec3(b.x, b.y, z), -- 1172
				____exports.vec3(a.x, a.y, z), -- 1173
				ridgeMat, -- 1174
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 1175
			) -- 1175
			self:addTri3D( -- 1178
				____exports.vec3( -- 1179
					midX, -- 1179
					math.max(baseY, midY), -- 1179
					z - 8 -- 1179
				), -- 1179
				____exports.vec3(b.x, baseY, z), -- 1180
				____exports.vec3(b.x, b.y, z), -- 1181
				{ -- 1182
					base = scaleRGBA(mat.base, 0.78), -- 1182
					minShade = 0.3, -- 1182
					bottomAo = 0.2 -- 1182
				}, -- 1182
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 1183
			) -- 1183
			i = i + 1 -- 1149
		end -- 1149
	end -- 1149
end -- 1134
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 1189
	if opts == nil then -- 1189
		opts = {} -- 1198
	end -- 1198
	local m = ____exports.clamp01(self.proj.morph) -- 1200
	local ba = ____exports.clamp01(bottomAlpha * m) -- 1201
	local ta = ____exports.clamp01(topAlpha * m) -- 1202
	if ba <= 0.008 and ta <= 0.008 then -- 1202
		return -- 1204
	end -- 1204
	local p0 = self:project(x0, y0, z) -- 1206
	local p1 = self:project(x1, y0, z) -- 1207
	local p2 = self:project(x1, y1, z) -- 1208
	local p3 = self:project(x0, y1, z) -- 1209
	local cBot = toColor( -- 1210
		color, -- 1210
		math.floor(255 * ba + 0.5) -- 1210
	) -- 1210
	local cTop = toColor( -- 1211
		color, -- 1211
		math.floor(255 * ta + 0.5) -- 1211
	) -- 1211
	local ____self_faces_15 = self.faces -- 1211
	____self_faces_15[#____self_faces_15 + 1] = { -- 1212
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 1213
		sortZ = z, -- 1214
		sortBias = opts.sortBias or 0.5, -- 1215
		pts = {p0, p1, p2, p3}, -- 1216
		cols = {cBot, cBot, cTop, cTop}, -- 1217
		edgeCol = nil, -- 1218
		edgeWidth = 0, -- 1219
		topHighlight = nil -- 1220
	} -- 1220
end -- 1189
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 1225
	local ta = ____exports.clamp01(topAlpha) -- 1237
	local ba = ____exports.clamp01(botAlpha) -- 1238
	if ta <= 0.005 and ba <= 0.005 then -- 1238
		return -- 1240
	end -- 1240
	local p0 = self:project(botX0, botY, z) -- 1242
	local p1 = self:project(botX1, botY, z) -- 1243
	local p2 = self:project(topX1, topY, z) -- 1244
	local p3 = self:project(topX0, topY, z) -- 1245
	local cTop = toColor( -- 1246
		color, -- 1246
		math.floor(255 * ta + 0.5) -- 1246
	) -- 1246
	local cBot = toColor( -- 1247
		color, -- 1247
		math.floor(255 * ba + 0.5) -- 1247
	) -- 1247
	local ____self_glows_16 = self.glows -- 1247
	____self_glows_16[#____self_glows_16 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1248
end -- 1225
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1258
	if opacity == nil then -- 1258
		opacity = 0.72 -- 1263
	end -- 1263
	if opts == nil then -- 1263
		opts = {} -- 1264
	end -- 1264
	local op = ____exports.clamp01(opacity) -- 1266
	if op <= 0.01 then -- 1266
		return -- 1268
	end -- 1268
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1270
	local bias = opts.sortBias or 0.2 -- 1271
	local m = ____exports.clamp01(self.proj.morph) -- 1272
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1273
	local segs = 10 -- 1276
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1277
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1278
	local innerCol = Color( -- 1279
		7, -- 1279
		9, -- 1279
		14, -- 1279
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1279
	) -- 1279
	local outerCol = Color(7, 9, 14, 0) -- 1280
	local i = 0 -- 1281
	do -- 1281
		i = 0 -- 1282
		while i < segs do -- 1282
			local a0 = i / segs * math.pi * 2 -- 1283
			local a1 = (i + 1) / segs * math.pi * 2 -- 1284
			local pA = self:project( -- 1285
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1286
				wy + 0.4, -- 1287
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1288
			) -- 1288
			local pB = self:project( -- 1290
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1291
				wy + 0.4, -- 1292
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1293
			) -- 1293
			local ____self_faces_17 = self.faces -- 1293
			____self_faces_17[#____self_faces_17 + 1] = { -- 1295
				bucket = bucket, -- 1296
				sortZ = 0.05, -- 1297
				sortBias = bias, -- 1298
				pts = {centerP, pA, pB}, -- 1299
				cols = {innerCol, outerCol, outerCol}, -- 1300
				edgeCol = nil, -- 1301
				edgeWidth = 0, -- 1302
				topHighlight = nil -- 1303
			} -- 1303
			i = i + 1 -- 1282
		end -- 1282
	end -- 1282
	local footP = self:project(wx, wy + 0.5, 0) -- 1308
	local coreRx = self.cam:len(radiusX * 0.78) -- 1309
	local coreRy = math.max( -- 1310
		2.5, -- 1310
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1310
	) -- 1310
	local coreIn = Color( -- 1311
		5, -- 1311
		7, -- 1311
		12, -- 1311
		math.floor(210 * op + 0.5) -- 1311
	) -- 1311
	local coreOut = Color( -- 1312
		5, -- 1312
		7, -- 1312
		12, -- 1312
		math.floor(32 * op + 0.5) -- 1312
	) -- 1312
	local coreSegs = 8 -- 1313
	do -- 1313
		i = 0 -- 1314
		while i < coreSegs do -- 1314
			local a0 = i / coreSegs * math.pi * 2 -- 1315
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1316
			local ____self_faces_18 = self.faces -- 1316
			____self_faces_18[#____self_faces_18 + 1] = { -- 1317
				bucket = bucket, -- 1318
				sortZ = 0.01, -- 1319
				sortBias = bias + 0.05, -- 1320
				pts = { -- 1321
					footP, -- 1322
					{ -- 1323
						x = footP.x + math.cos(a0) * coreRx, -- 1323
						y = footP.y + math.sin(a0) * coreRy, -- 1323
						scale = 1, -- 1323
						zEff = 0 -- 1323
					}, -- 1323
					{ -- 1324
						x = footP.x + math.cos(a1) * coreRx, -- 1324
						y = footP.y + math.sin(a1) * coreRy, -- 1324
						scale = 1, -- 1324
						zEff = 0 -- 1324
					} -- 1324
				}, -- 1324
				cols = {coreIn, coreOut, coreOut}, -- 1326
				edgeCol = nil, -- 1327
				edgeWidth = 0, -- 1328
				topHighlight = nil -- 1329
			} -- 1329
			i = i + 1 -- 1314
		end -- 1314
	end -- 1314
end -- 1258
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1338
	if opts == nil then -- 1338
		opts = {} -- 1347
	end -- 1347
	local pBL = self:project(x0, y0, wz) -- 1349
	local pTR = self:project(x1, y1, wz) -- 1350
	local w = math.abs(pTR.x - pBL.x) -- 1351
	local h = math.abs(pTR.y - pBL.y) -- 1352
	if w < 1 or h < 1 then -- 1352
		return false -- 1354
	end -- 1354
	return worldArt:tryPlace( -- 1356
		slotKey, -- 1357
		instanceKey, -- 1358
		(pBL.x + pTR.x) * 0.5, -- 1359
		math.min(pBL.y, pTR.y), -- 1360
		w, -- 1361
		h, -- 1362
		{ -- 1363
			color = opts.color or Color(28, 32, 42, 255), -- 1364
			opacity = opts.opacity or 0.92, -- 1365
			layer = opts.layer or 5200 -- 1366
		} -- 1366
	) -- 1366
end -- 1338
function LowpolyScene.prototype.drawFaceToNode(self, target, f) -- 1372
	if #f.pts == 3 then -- 1372
		target:drawVertices({ -- 1374
			{ -- 1375
				Vec2(f.pts[1].x, f.pts[1].y), -- 1375
				f.cols[1] -- 1375
			}, -- 1375
			{ -- 1376
				Vec2(f.pts[2].x, f.pts[2].y), -- 1376
				f.cols[2] -- 1376
			}, -- 1376
			{ -- 1377
				Vec2(f.pts[3].x, f.pts[3].y), -- 1377
				f.cols[3] -- 1377
			} -- 1377
		}) -- 1377
	elseif #f.pts == 4 then -- 1377
		local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1380
		local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1381
		local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1382
		local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1383
		target:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1384
		target:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1389
	end -- 1389
	if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1389
		local count = #f.pts -- 1396
		local k = 0 -- 1397
		do -- 1397
			k = 0 -- 1398
			while k < count do -- 1398
				local a = f.pts[k + 1] -- 1399
				local b = f.pts[(k + 1) % count + 1] -- 1400
				target:drawSegment( -- 1401
					Vec2(a.x, a.y), -- 1401
					Vec2(b.x, b.y), -- 1401
					f.edgeWidth * 0.5, -- 1401
					f.edgeCol -- 1401
				) -- 1401
				k = k + 1 -- 1398
			end -- 1398
		end -- 1398
	end -- 1398
	if f.topHighlight ~= nil then -- 1398
		local hl = f.topHighlight -- 1405
		target:drawSegment( -- 1406
			Vec2(hl[1].x, hl[1].y), -- 1406
			Vec2(hl[2].x, hl[2].y), -- 1406
			0.9, -- 1406
			hl[3] -- 1406
		) -- 1406
	end -- 1406
end -- 1372
function LowpolyScene.prototype.flush(self, draw, glowDraw, dioramaHost) -- 1415
	if #self.faces > 1 then -- 1415
		__TS__ArraySort( -- 1417
			self.faces, -- 1417
			function(____, a, b) -- 1417
				if a.bucket ~= b.bucket then -- 1417
					return a.bucket - b.bucket -- 1419
				end -- 1419
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1419
					return b.sortZ - a.sortZ -- 1422
				end -- 1422
				return a.sortBias - b.sortBias -- 1424
			end -- 1417
		) -- 1417
	end -- 1417
	local runDraw -- 1428
	local i = 0 -- 1430
	do -- 1430
		i = 0 -- 1431
		while i < #self.faces do -- 1431
			do -- 1431
				local f = self.faces[i + 1] -- 1432
				if dioramaHost ~= nil then -- 1432
					if f.cutout ~= nil then -- 1432
						runDraw = nil -- 1436
						local c = f.cutout -- 1437
						dioramaHost:placeCutoutCard({ -- 1438
							clipStr = c.clipStr, -- 1439
							x = c.x, -- 1440
							y = c.y, -- 1441
							targetW = c.w, -- 1442
							targetH = c.h, -- 1443
							order = dioramaHost:nextOrder(), -- 1444
							anchorX = c.anchorX, -- 1445
							anchorY = c.anchorY, -- 1446
							facing = c.facing, -- 1447
							flipY = c.flipY, -- 1448
							angle = c.angle, -- 1449
							color = c.color, -- 1450
							opacity = c.opacity, -- 1451
							smooth = c.smooth, -- 1452
							additive = c.additive -- 1453
						}) -- 1453
						goto __continue88 -- 1455
					end -- 1455
					if f.texture ~= nil and f.worldQuad ~= nil then -- 1455
						local order = dioramaHost:nextOrder() -- 1459
						local placed = dioramaHost:placeTexturedQuad({ -- 1460
							clipStr = f.texture, -- 1461
							v0 = f.worldQuad[1], -- 1462
							v1 = f.worldQuad[2], -- 1463
							v2 = f.worldQuad[3], -- 1464
							v3 = f.worldQuad[4], -- 1465
							segX = f.subdivX or 2, -- 1466
							segY = f.subdivY or 2, -- 1467
							projector = self, -- 1468
							tintColor = f.texTint or f.cols[3] or Color(255, 255, 255, 255), -- 1469
							opacity = f.texOpacity or 1, -- 1470
							order = order, -- 1471
							additive = f.additive, -- 1472
							wave = f.wave -- 1473
						}) -- 1473
						if placed then -- 1473
							runDraw = nil -- 1476
							if f.topHighlight ~= nil then -- 1476
								local rimNode = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1479
								local hl = f.topHighlight -- 1480
								rimNode:drawSegment( -- 1481
									Vec2(hl[1].x, hl[1].y), -- 1481
									Vec2(hl[2].x, hl[2].y), -- 1481
									0.85, -- 1481
									hl[3] -- 1481
								) -- 1481
								runDraw = rimNode -- 1482
							end -- 1482
							goto __continue88 -- 1484
						end -- 1484
					end -- 1484
					if runDraw == nil then -- 1484
						runDraw = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1489
					end -- 1489
					self:drawFaceToNode(runDraw, f) -- 1491
				else -- 1491
					if f.cutout ~= nil then -- 1491
						goto __continue88 -- 1494
					end -- 1494
					self:drawFaceToNode(draw, f) -- 1496
				end -- 1496
			end -- 1496
			::__continue88:: -- 1496
			i = i + 1 -- 1431
		end -- 1431
	end -- 1431
	if glowDraw ~= nil and #self.glows > 0 then -- 1431
		do -- 1431
			i = 0 -- 1501
			while i < #self.glows do -- 1501
				local g = self.glows[i + 1] -- 1502
				if #g.pts == 4 then -- 1502
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1504
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1505
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1506
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1507
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1508
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1513
				end -- 1513
				i = i + 1 -- 1501
			end -- 1501
		end -- 1501
	end -- 1501
	self.faces = {} -- 1522
	self.glows = {} -- 1523
end -- 1415
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time) -- 1532
	scene:addDistantRidge( -- 1541
		{ -- 1542
			{x = room.minX - 180, y = 125}, -- 1543
			{x = room.minX + 120, y = 196}, -- 1544
			{x = room.minX + 420, y = 162}, -- 1545
			{x = room.minX + 760, y = 224}, -- 1546
			{x = room.maxX + 220, y = 150} -- 1547
		}, -- 1547
		-40, -- 1547
		420, -- 1550
		____exports.MING_MATERIALS.distantHill, -- 1551
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1552
	) -- 1552
	scene:addFogBand( -- 1554
		room.minX - 240, -- 1554
		room.maxX + 240, -- 1554
		-30, -- 1554
		175, -- 1554
		290, -- 1554
		scene.light.fogColor, -- 1554
		0.56, -- 1554
		0.04, -- 1554
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1554
	) -- 1554
	local i = 0 -- 1559
	do -- 1559
		i = 0 -- 1560
		while i < #room.floors do -- 1560
			local fl = room.floors[i + 1] -- 1561
			local isMain = fl.y <= 0.1 -- 1562
			if isMain then -- 1562
				scene:addBox({ -- 1564
					x0 = fl.x0, -- 1565
					x1 = fl.x1, -- 1566
					y0 = -48, -- 1567
					y1 = fl.y, -- 1568
					z0 = -26, -- 1569
					z1 = 88, -- 1570
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1571
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1572
					highlightTopEdge = true -- 1573
				}) -- 1573
			else -- 1573
				scene:addPlankDeck( -- 1577
					fl.x0, -- 1577
					fl.x1, -- 1577
					fl.y, -- 1577
					-24, -- 1577
					52, -- 1577
					5, -- 1577
					11, -- 1577
					____exports.MING_MATERIALS.mingTimber, -- 1577
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1577
				) -- 1577
			end -- 1577
			i = i + 1 -- 1560
		end -- 1560
	end -- 1560
	do -- 1560
		i = 0 -- 1586
		while i < #room.stairs do -- 1586
			scene:addStairFlight( -- 1587
				room.stairs[i + 1], -- 1587
				14, -- 1587
				76, -- 1587
				____exports.MING_MATERIALS.mingStoneStep, -- 1587
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1587
			) -- 1587
			i = i + 1 -- 1586
		end -- 1586
	end -- 1586
	do -- 1586
		i = 0 -- 1594
		while i < #room.solids do -- 1594
			do -- 1594
				local s = room.solids[i + 1] -- 1595
				if s.id == "outside_red_cart" then -- 1595
					goto __continue109 -- 1597
				end -- 1597
				scene:addBox({ -- 1599
					x0 = s.x, -- 1600
					x1 = s.x + s.w, -- 1601
					y0 = s.y, -- 1602
					y1 = s.y + s.h, -- 1603
					z0 = -8, -- 1604
					z1 = 72, -- 1605
					material = ____exports.MING_MATERIALS.mingBrick, -- 1606
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1607
					highlightTopEdge = true -- 1608
				}) -- 1608
				if s.y > 10 then -- 1608
					scene:addBox({ -- 1611
						x0 = s.x, -- 1612
						x1 = s.x + 18, -- 1613
						y0 = 0, -- 1614
						y1 = s.y, -- 1615
						z0 = 32, -- 1616
						z1 = 72, -- 1617
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1618
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1619
						sortBias = -0.08, -- 1620
						edgeWidth = 0.7 -- 1621
					}) -- 1621
					scene:addBox({ -- 1623
						x0 = s.x + s.w - 18, -- 1624
						x1 = s.x + s.w, -- 1625
						y0 = 0, -- 1626
						y1 = s.y, -- 1627
						z0 = 32, -- 1628
						z1 = 72, -- 1629
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1630
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1631
						sortBias = -0.08, -- 1632
						edgeWidth = 0.7 -- 1633
					}) -- 1633
				end -- 1633
			end -- 1633
			::__continue109:: -- 1633
			i = i + 1 -- 1594
		end -- 1594
	end -- 1594
	local arch = room.arch -- 1639
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1639
		scene:addBeveledFrame( -- 1641
			arch.x0, -- 1641
			arch.x1, -- 1641
			arch.y, -- 1641
			arch.y + arch.h, -- 1641
			22, -- 1641
			18, -- 1641
			-10, -- 1641
			64, -- 1641
			____exports.MING_MATERIALS.mingStoneStep, -- 1641
			{ -- 1641
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1642
				innerRimLight = rgba(176, 206, 228, 255), -- 1643
				innerRimStrength = 0.45 -- 1644
			} -- 1644
		) -- 1644
	end -- 1644
	local c = room.cart -- 1649
	if c.bodyW > 0 then -- 1649
		scene:addContactShadow( -- 1651
			cartAxle, -- 1651
			c.baseY, -- 1651
			c.bodyW * 0.62, -- 1651
			14, -- 1651
			0.7, -- 1651
			{bucket = ____exports.LP_BUCKET.PROP} -- 1651
		) -- 1651
		local clothX = cartAxle - c.bodyW * 0.5 -- 1652
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1653
		scene:addWavingQuad3D( -- 1654
			____exports.vec3(clothX - 11, clothTop - 22, -6), -- 1655
			____exports.vec3(clothX + 5, clothTop - 20, -5), -- 1656
			____exports.vec3(clothX + 8, clothTop, -4), -- 1657
			____exports.vec3(clothX - 2, clothTop, -4), -- 1658
			____exports.MING_MATERIALS.mingRedCloth, -- 1659
			{ -- 1660
				ampX = 6, -- 1660
				ampY = 2.2, -- 1660
				phase = time * 3.1, -- 1660
				freqU = 1.8, -- 1660
				freqV = 2.6, -- 1660
				pin = "top" -- 1660
			}, -- 1660
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, subdivX = 3, subdivY = 4} -- 1661
		) -- 1661
	end -- 1661
	scene:addContactShadow( -- 1666
		actorX, -- 1666
		actorY, -- 1666
		15, -- 1666
		11, -- 1666
		0.78, -- 1666
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1666
	) -- 1666
end -- 1532
return ____exports -- 1532