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
function ____exports.clamp01(v) -- 203
	return math.max( -- 204
		0, -- 204
		math.min(1, v) -- 204
	) -- 204
end -- 203
function ____exports.smoothstep(edge0, edge1, x) -- 207
	if edge1 <= edge0 then -- 207
		return x >= edge1 and 1 or 0 -- 209
	end -- 209
	local t = ____exports.clamp01((x - edge0) / (edge1 - edge0)) -- 211
	return t * t * (3 - 2 * t) -- 212
end -- 207
function ____exports.vec3(x, y, z) -- 215
	return {x = x, y = y, z = z} -- 216
end -- 215
function ____exports.normalize3(v) -- 219
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) -- 220
	if len < 0.00001 then -- 220
		return {x = 0, y = 1, z = 0} -- 222
	end -- 222
	return {x = v.x / len, y = v.y / len, z = v.z / len} -- 224
end -- 219
local function dot3(a, b) -- 227
	return a.x * b.x + a.y * b.y + a.z * b.z -- 228
end -- 227
local function cross3(a, b) -- 231
	return {x = a.y * b.z - a.z * b.y, y = a.z * b.x - a.x * b.z, z = a.x * b.y - a.y * b.x} -- 232
end -- 231
local function sub3(a, b) -- 239
	return {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z} -- 240
end -- 239
local function clampByte(v) -- 243
	return math.max( -- 244
		0, -- 244
		math.min( -- 244
			255, -- 244
			math.floor(v + 0.5) -- 244
		) -- 244
	) -- 244
end -- 243
local function scaleRGBA(c, k, alphaMul) -- 247
	if alphaMul == nil then -- 247
		alphaMul = 1 -- 247
	end -- 247
	return { -- 248
		r = clampByte(c.r * k), -- 249
		g = clampByte(c.g * k), -- 250
		b = clampByte(c.b * k), -- 251
		a = clampByte(c.a * alphaMul) -- 252
	} -- 252
end -- 247
--- 明初温州宁村所海防卫城 2.5D 微缩剧场材质预设（全量接入 tex_diorama_ming 纹理 + 高灰度区分度）
____exports.MING_MATERIALS = { -- 257
	mingBrick = { -- 258
		base = rgba(96, 102, 112, 255), -- 259
		edge = rgba(154, 162, 174, 120), -- 260
		minShade = 0.34, -- 261
		rimBoost = 0.24, -- 262
		bottomAo = 0.26, -- 263
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 264
		textureTint = rgba(212, 218, 228, 255), -- 265
		subdivX = 3, -- 266
		subdivY = 2 -- 267
	}, -- 267
	mingBrickDark = { -- 269
		base = rgba(54, 60, 72, 255), -- 270
		edge = rgba(108, 118, 134, 100), -- 271
		minShade = 0.28, -- 272
		rimBoost = 0.18, -- 273
		bottomAo = 0.32, -- 274
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 275
		textureTint = rgba(146, 154, 168, 255), -- 276
		subdivX = 3, -- 277
		subdivY = 2 -- 278
	}, -- 278
	mingTimber = { -- 280
		base = rgba(114, 84, 62, 255), -- 281
		edge = rgba(168, 134, 104, 120), -- 282
		minShade = 0.3, -- 283
		rimBoost = 0.22, -- 284
		bottomAo = 0.26, -- 285
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 286
		textureTint = rgba(224, 206, 186, 255), -- 287
		subdivX = 3, -- 288
		subdivY = 2 -- 289
	}, -- 289
	mingTimberDark = { -- 291
		base = rgba(68, 50, 38, 255), -- 292
		edge = rgba(122, 96, 76, 105), -- 293
		minShade = 0.24, -- 294
		rimBoost = 0.16, -- 295
		bottomAo = 0.34, -- 296
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_timber", -- 297
		textureTint = rgba(148, 132, 118, 255), -- 298
		subdivX = 2, -- 299
		subdivY = 2 -- 300
	}, -- 300
	mingStoneStep = { -- 302
		base = rgba(118, 122, 128, 255), -- 303
		edge = rgba(188, 194, 200, 140), -- 304
		minShade = 0.32, -- 305
		rimBoost = 0.26, -- 306
		bottomAo = 0.24, -- 307
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_stone", -- 308
		textureTint = rgba(210, 216, 224, 255), -- 309
		subdivX = 2, -- 310
		subdivY = 2 -- 311
	}, -- 311
	mingPlaster = { -- 313
		base = rgba(116, 110, 100, 255), -- 314
		edge = rgba(164, 156, 144, 100), -- 315
		minShade = 0.28, -- 316
		rimBoost = 0.18, -- 317
		bottomAo = 0.32, -- 318
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_plaster", -- 319
		textureTint = rgba(196, 192, 182, 255), -- 320
		subdivX = 3, -- 321
		subdivY = 2 -- 322
	}, -- 322
	mingIron = { -- 324
		base = rgba(46, 52, 62, 255), -- 325
		edge = rgba(136, 146, 158, 130), -- 326
		minShade = 0.28, -- 327
		rimBoost = 0.3, -- 328
		bottomAo = 0.24, -- 329
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_iron", -- 330
		textureTint = rgba(178, 186, 198, 255), -- 331
		subdivX = 2, -- 332
		subdivY = 2 -- 333
	}, -- 333
	mingTile = { -- 335
		base = rgba(44, 52, 66, 255), -- 336
		edge = rgba(102, 116, 136, 110), -- 337
		minShade = 0.28, -- 338
		rimBoost = 0.2, -- 339
		bottomAo = 0.22, -- 340
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_tile", -- 341
		textureTint = rgba(176, 188, 206, 255), -- 342
		subdivX = 3, -- 343
		subdivY = 2 -- 344
	}, -- 344
	mingRedCloth = { -- 346
		base = rgba(176, 52, 48, 255), -- 347
		edge = rgba(224, 116, 102, 140), -- 348
		minShade = 0.42, -- 349
		rimBoost = 0.24, -- 350
		bottomAo = 0.16, -- 351
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 352
		textureTint = rgba(218, 68, 60, 255), -- 353
		subdivX = 3, -- 354
		subdivY = 3 -- 355
	}, -- 355
	mingHempCloth = { -- 357
		base = rgba(136, 128, 114, 255), -- 358
		edge = rgba(182, 174, 158, 110), -- 359
		minShade = 0.26, -- 360
		rimBoost = 0.18, -- 361
		bottomAo = 0.28, -- 362
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_cloth", -- 363
		textureTint = rgba(172, 166, 152, 255), -- 364
		subdivX = 3, -- 365
		subdivY = 3 -- 366
	}, -- 366
	mingWater = { -- 368
		base = rgba(28, 44, 56, 255), -- 369
		edge = rgba(124, 156, 174, 90), -- 370
		minShade = 0.42, -- 371
		rimBoost = 0.22, -- 372
		bottomAo = 0.1, -- 373
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_water", -- 374
		textureTint = rgba(182, 208, 220, 255), -- 375
		subdivX = 6, -- 376
		subdivY = 3 -- 377
	}, -- 377
	distantWall = { -- 379
		base = rgba(42, 52, 68, 255), -- 380
		edge = rgba(98, 114, 136, 85), -- 381
		minShade = 0.38, -- 382
		rimBoost = 0.14, -- 383
		bottomAo = 0.2, -- 384
		texture = ____exports.DIORAMA_TEX_CLIP .. "ming_brick", -- 385
		textureTint = rgba(126, 140, 162, 255), -- 386
		subdivX = 2, -- 387
		subdivY = 1 -- 388
	}, -- 388
	distantHill = { -- 390
		base = rgba(28, 38, 54, 255), -- 391
		edge = rgba(74, 92, 116, 70), -- 392
		minShade = 0.38, -- 393
		rimBoost = 0.12, -- 394
		bottomAo = 0.2 -- 395
	} -- 395
} -- 395
--- 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光）
____exports.GATE_NIGHTMARE_LIGHT = { -- 400
	keyDir = ____exports.normalize3(____exports.vec3(-0.62, 0.64, -0.45)), -- 401
	keyColor = rgba(206, 224, 240, 255), -- 402
	keyStrength = 0.88, -- 403
	rimDir = ____exports.normalize3(____exports.vec3(0.76, 0.36, -0.54)), -- 404
	rimColor = rgba(224, 196, 150, 255), -- 405
	rimStrength = 0.34, -- 406
	ambientColor = rgba(26, 34, 48, 255), -- 407
	fogColor = rgba(26, 36, 52, 255), -- 408
	fogStartZ = 36, -- 409
	fogEndZ = 560, -- 410
	fogMaxAlpha = 0.84, -- 411
	shadowContrast = 0.72 -- 412
} -- 412
____exports.OUTSIDE_JETTY_LIGHT = { -- 415
	keyDir = ____exports.normalize3(____exports.vec3(-0.56, 0.68, -0.48)), -- 416
	keyColor = rgba(196, 214, 232, 255), -- 417
	keyStrength = 0.86, -- 418
	rimDir = ____exports.normalize3(____exports.vec3(0.78, 0.32, -0.54)), -- 419
	rimColor = rgba(226, 188, 136, 255), -- 420
	rimStrength = 0.32, -- 421
	ambientColor = rgba(24, 32, 46, 255), -- 422
	fogColor = rgba(24, 34, 50, 255), -- 423
	fogStartZ = 42, -- 424
	fogEndZ = 520, -- 425
	fogMaxAlpha = 0.8, -- 426
	shadowContrast = 0.74 -- 427
} -- 427
____exports.VILLAGE_UNDERTABLE_LIGHT = { -- 430
	keyDir = ____exports.normalize3(____exports.vec3(0.72, 0.44, -0.54)), -- 431
	keyColor = rgba(214, 208, 194, 255), -- 432
	keyStrength = 0.92, -- 433
	rimDir = ____exports.normalize3(____exports.vec3(-0.64, 0.52, -0.56)), -- 434
	rimColor = rgba(146, 166, 186, 255), -- 435
	rimStrength = 0.28, -- 436
	ambientColor = rgba(18, 22, 30, 255), -- 437
	fogColor = rgba(22, 26, 34, 255), -- 438
	fogStartZ = 55, -- 439
	fogEndZ = 460, -- 440
	fogMaxAlpha = 0.78, -- 441
	shadowContrast = 0.82 -- 442
} -- 442
____exports.FOREST_CREEK_LIGHT = { -- 445
	keyDir = ____exports.normalize3(____exports.vec3(-0.48, 0.74, -0.47)), -- 446
	keyColor = rgba(178, 206, 202, 255), -- 447
	keyStrength = 0.8, -- 448
	rimDir = ____exports.normalize3(____exports.vec3(0.82, 0.28, -0.5)), -- 449
	rimColor = rgba(232, 196, 132, 255), -- 450
	rimStrength = 0.36, -- 451
	ambientColor = rgba(18, 30, 34, 255), -- 452
	fogColor = rgba(20, 34, 38, 255), -- 453
	fogStartZ = 34, -- 454
	fogEndZ = 480, -- 455
	fogMaxAlpha = 0.86, -- 456
	shadowContrast = 0.76 -- 457
} -- 457
____exports.TOWER_WEST_LAMP_LIGHT = { -- 460
	keyDir = ____exports.normalize3(____exports.vec3(-0.74, 0.48, -0.47)), -- 461
	keyColor = rgba(242, 202, 138, 255), -- 462
	keyStrength = 0.94, -- 463
	rimDir = ____exports.normalize3(____exports.vec3(0.62, 0.54, -0.57)), -- 464
	rimColor = rgba(142, 168, 198, 255), -- 465
	rimStrength = 0.26, -- 466
	ambientColor = rgba(24, 26, 36, 255), -- 467
	fogColor = rgba(24, 28, 40, 255), -- 468
	fogStartZ = 60, -- 469
	fogEndZ = 480, -- 470
	fogMaxAlpha = 0.72, -- 471
	shadowContrast = 0.7 -- 472
} -- 472
--- 核心 2.5D 低模投影：
-- 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
function ____exports.projectWorld3D(wx, wy, wz, cam, proj) -- 479
	local bx = cam:sx(wx) -- 486
	local by = cam:sy(wy, proj.baseDepth or 0) -- 487
	local m = ____exports.clamp01(proj.morph) -- 488
	if m <= 0.00001 or math.abs(wz) <= 0.00001 then -- 488
		return {x = bx, y = by, scale = 1, zEff = 0} -- 490
	end -- 490
	local focal = math.max(60, proj.focal) -- 492
	local zEff = wz * m -- 493
	local denom = math.max(focal * 0.22, focal + zEff) -- 494
	local s = focal / denom -- 495
	local vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX or 0) -- 496
	local vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY or 0) -- 497
	return {x = vpX + (bx - vpX) * s, y = vpY + (by - vpY) * s, scale = s, zEff = zEff} -- 498
end -- 479
--- 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
-- 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
function ____exports.verifyWalkPlaneAlignment(cam, proj, wx, wy) -- 510
	local p3 = ____exports.projectWorld3D( -- 516
		wx, -- 516
		wy, -- 516
		0, -- 516
		cam, -- 516
		proj -- 516
	) -- 516
	local p2 = cam:worldToScreen(wx, wy, proj.baseDepth or 0) -- 517
	local fwdDx = p3.x - p2.x -- 518
	local fwdDy = p3.y - p2.y -- 519
	local forwardErrPx = math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy) -- 520
	local inv = cam:screenToWorld(p3.x, p3.y) -- 522
	local invDx = inv.x - wx -- 523
	local invDy = inv.y - (wy + (proj.baseDepth or 0) * DEPTH_Y_SCALE) -- 524
	local inverseErrWorld = math.sqrt(invDx * invDx + invDy * invDy) -- 525
	return {forwardErrPx = forwardErrPx, inverseErrWorld = inverseErrWorld, screenX = p3.x, screenY = p3.y} -- 526
end -- 510
--- 计算给定法线与深度的低模平面受光+雾效颜色
function ____exports.shadeSurface(base, normal, avgZ, morph, light, mat, opacityMul) -- 535
	if opacityMul == nil then -- 535
		opacityMul = 1 -- 542
	end -- 542
	local m = ____exports.clamp01(morph) -- 544
	local n = ____exports.normalize3(normal) -- 545
	local ndl = math.max( -- 546
		0, -- 546
		dot3(n, light.keyDir) -- 546
	) -- 546
	local ndr = math.max( -- 547
		0, -- 547
		dot3(n, light.rimDir) -- 547
	) -- 547
	local minShade = mat and mat.minShade or 0.28 -- 548
	local rimBoost = mat and mat.rimBoost or 0.2 -- 549
	local contrast = light.shadowContrast * (0.45 + 0.55 * m) -- 550
	local keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25) -- 552
	local rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost) -- 553
	local rLit = base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255) + light.ambientColor.r * (0.28 * (1 - ndl * 0.5)) + light.rimColor.r * rimFactor * 0.45 -- 555
	local gLit = base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255) + light.ambientColor.g * (0.28 * (1 - ndl * 0.5)) + light.rimColor.g * rimFactor * 0.45 -- 558
	local bLit = base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255) + light.ambientColor.b * (0.28 * (1 - ndl * 0.5)) + light.rimColor.b * rimFactor * 0.45 -- 561
	local lit = { -- 565
		r = clampByte(rLit), -- 566
		g = clampByte(gLit), -- 567
		b = clampByte(bLit), -- 568
		a = clampByte(base.a * ____exports.clamp01(opacityMul)) -- 569
	} -- 569
	if avgZ > light.fogStartZ and m > 0.01 then -- 569
		local span = math.max(1, light.fogEndZ - light.fogStartZ) -- 573
		local fogT = ____exports.clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m -- 574
		local mixed = lerpRGBA(lit, light.fogColor, fogT) -- 575
		mixed.a = lit.a -- 576
		return mixed -- 577
	end -- 577
	return lit -- 579
end -- 535
--- 画家算法低模场景批处理器：
-- 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
____exports.LowpolyScene = __TS__Class() -- 586
local LowpolyScene = ____exports.LowpolyScene -- 586
LowpolyScene.name = "LowpolyScene" -- 586
function LowpolyScene.prototype.____constructor(self, cam, proj, light) -- 593
	if light == nil then -- 593
		light = ____exports.GATE_NIGHTMARE_LIGHT -- 593
	end -- 593
	self.faces = {} -- 590
	self.glows = {} -- 591
	self.cam = cam -- 594
	self.proj = proj -- 595
	self.light = light -- 596
end -- 593
function LowpolyScene.prototype.getFaceCount(self) -- 599
	return #self.faces -- 600
end -- 599
function LowpolyScene.prototype.project(self, wx, wy, wz) -- 603
	return ____exports.projectWorld3D( -- 604
		wx, -- 604
		wy, -- 604
		wz, -- 604
		self.cam, -- 604
		self.proj -- 604
	) -- 604
end -- 603
function LowpolyScene.prototype.vanishingPointScreen(self) -- 607
	return {x = self.cam.viewW * self.proj.vpFracX + (self.proj.vpOffsetX or 0), y = self.cam.viewH * self.proj.vpFracY + (self.proj.vpOffsetY or 0)} -- 608
end -- 607
function LowpolyScene.prototype.addQuad3D(self, v0, v1, v2, v3, mat, opts) -- 615
	if opts == nil then -- 615
		opts = {} -- 621
	end -- 621
	local opacity = opts.opacity or 1 -- 623
	if opacity <= 0.01 then -- 623
		return -- 625
	end -- 625
	local p0 = self:project(v0.x, v0.y, v0.z) -- 627
	local p1 = self:project(v1.x, v1.y, v1.z) -- 628
	local p2 = self:project(v2.x, v2.y, v2.z) -- 629
	local p3 = self:project(v3.x, v3.y, v3.z) -- 630
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y)) -- 633
	if area2 < 0.25 then -- 633
		return -- 638
	end -- 638
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z + v3.z) * 0.25 -- 641
	local topRgba -- 642
	local texTint -- 643
	local hasTex = mat.texture ~= nil and mat.texture ~= "" -- 644
	if opts.unlit == true then -- 644
		topRgba = scaleRGBA(mat.base, 1, opacity) -- 646
		if hasTex then -- 646
			local tb = mat.textureTint or rgba(235, 238, 244, 255) -- 648
			texTint = toColor(tb, 255) -- 649
		end -- 649
	else -- 649
		local n = cross3( -- 652
			sub3(v1, v0), -- 652
			sub3(v3, v0) -- 652
		) -- 652
		topRgba = ____exports.shadeSurface( -- 653
			mat.base, -- 653
			n, -- 653
			avgZ, -- 653
			self.proj.morph, -- 653
			self.light, -- 653
			mat, -- 653
			opacity -- 653
		) -- 653
		if hasTex then -- 653
			local tb = mat.textureTint or rgba(224, 228, 236, 255) -- 656
			local litTex = ____exports.shadeSurface( -- 657
				tb, -- 657
				n, -- 657
				avgZ, -- 657
				self.proj.morph, -- 657
				self.light, -- 657
				mat, -- 657
				1 -- 657
			) -- 657
			texTint = toColor(litTex, 255) -- 658
		end -- 658
	end -- 658
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.22) -- 662
	local botRgba = ao > 0.005 and scaleRGBA( -- 663
		topRgba, -- 663
		math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)), -- 663
		1 -- 663
	) or topRgba -- 663
	local cBot = toColor(botRgba) -- 664
	local cTop = toColor(topRgba) -- 665
	local edgeRgba = opts.edgeColor or mat.edge -- 668
	local edgeW = hasTex and 0 or (opts.edgeWidth or 0) -- 669
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 670
		edgeRgba, -- 671
		math.floor(edgeRgba.a * opacity + 0.5) -- 671
	) or nil -- 671
	local ____self_faces_11 = self.faces -- 674
	local ____temp_5 = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 675
	local ____temp_6 = opts.sortBias or 0 -- 677
	local ____temp_7 = {p0, p1, p2, p3} -- 678
	local ____temp_8 = {cBot, cBot, cTop, cTop} -- 679
	local ____edgeCol_9 = edgeCol -- 680
	local ____temp_10 = hasTex and ({v0, v1, v2, v3}) or nil -- 683
	local ____hasTex_4 -- 684
	if hasTex then -- 684
		____hasTex_4 = mat.texture -- 684
	else -- 684
		____hasTex_4 = nil -- 684
	end -- 684
	____self_faces_11[#____self_faces_11 + 1] = { -- 674
		bucket = ____temp_5, -- 675
		sortZ = avgZ, -- 676
		sortBias = ____temp_6, -- 677
		pts = ____temp_7, -- 678
		cols = ____temp_8, -- 679
		edgeCol = ____edgeCol_9, -- 680
		edgeWidth = edgeW, -- 681
		topHighlight = nil, -- 682
		worldQuad = ____temp_10, -- 683
		texture = ____hasTex_4, -- 684
		texTint = texTint, -- 685
		texOpacity = opacity, -- 686
		subdivX = opts.subdivX or mat.subdivX or 2, -- 687
		subdivY = opts.subdivY or mat.subdivY or 2, -- 688
		wave = opts.wave, -- 689
		additive = opts.additive -- 690
	} -- 690
end -- 615
function LowpolyScene.prototype.addWavingQuad3D(self, v0, v1, v2, v3, mat, wave, opts) -- 695
	if opts == nil then -- 695
		opts = {} -- 702
	end -- 702
	self:addQuad3D( -- 704
		v0, -- 704
		v1, -- 704
		v2, -- 704
		v3, -- 704
		mat, -- 704
		__TS__ObjectAssign({}, opts, {wave = wave, subdivX = opts.subdivX or mat.subdivX or 4, subdivY = opts.subdivY or mat.subdivY or 3}) -- 704
	) -- 704
end -- 695
function LowpolyScene.prototype.addCutout3D(self, clipStr, wx, wy, wz, worldW, worldH, opts) -- 716
	if opts == nil then -- 716
		opts = {} -- 723
	end -- 723
	local opacity = opts.opacity or 1 -- 725
	if opacity <= 0.01 or worldW <= 0.5 or worldH <= 0.5 then -- 725
		return -- 727
	end -- 727
	local pt = self:project(wx, wy, wz) -- 729
	local screenW = self.cam:len(worldW) * pt.scale -- 730
	local screenH = self.cam:len(worldH) * pt.scale -- 731
	if screenW < 1 or screenH < 1 then -- 731
		return -- 733
	end -- 733
	local baseTint = opts.tint or opts.color or rgba(240, 244, 248, 255) -- 735
	local finalRgba = baseTint -- 736
	if opts.unlit ~= true then -- 736
		local m = ____exports.clamp01(self.proj.morph) -- 738
		if wz > self.light.fogStartZ and m > 0.01 then -- 738
			local span = math.max(1, self.light.fogEndZ - self.light.fogStartZ) -- 740
			local fogT = ____exports.clamp01((wz - self.light.fogStartZ) / span) * self.light.fogMaxAlpha * 0.72 * m -- 741
			finalRgba = lerpRGBA(baseTint, self.light.fogColor, fogT) -- 742
		end -- 742
	end -- 742
	local ____self_faces_12 = self.faces -- 742
	____self_faces_12[#____self_faces_12 + 1] = { -- 745
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 746
		sortZ = wz, -- 747
		sortBias = opts.sortBias or 0, -- 748
		pts = {}, -- 749
		cols = {}, -- 750
		edgeCol = nil, -- 751
		edgeWidth = 0, -- 752
		topHighlight = nil, -- 753
		cutout = { -- 754
			clipStr = clipStr, -- 755
			x = pt.x, -- 756
			y = pt.y, -- 757
			w = screenW, -- 758
			h = screenH, -- 759
			anchorX = opts.anchorX or 0.5, -- 760
			anchorY = opts.anchorY or 0, -- 761
			facing = opts.facing or 1, -- 762
			flipY = opts.flipY == true, -- 763
			angle = opts.angle or 0, -- 764
			color = toColor(finalRgba, 255), -- 765
			opacity = opacity, -- 766
			smooth = opts.smooth ~= false, -- 767
			additive = opts.additive == true -- 768
		} -- 768
	} -- 768
end -- 716
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 774
	if opts == nil then -- 774
		opts = {} -- 779
	end -- 779
	local opacity = opts.opacity or 1 -- 781
	if opacity <= 0.01 then -- 781
		return -- 783
	end -- 783
	local p0 = self:project(v0.x, v0.y, v0.z) -- 785
	local p1 = self:project(v1.x, v1.y, v1.z) -- 786
	local p2 = self:project(v2.x, v2.y, v2.z) -- 787
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 789
	if area2 < 0.25 then -- 789
		return -- 791
	end -- 791
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 794
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 795
		mat.base, -- 797
		cross3( -- 797
			sub3(v1, v0), -- 797
			sub3(v2, v0) -- 797
		), -- 797
		avgZ, -- 797
		self.proj.morph, -- 797
		self.light, -- 797
		mat, -- 797
		opacity -- 797
	) -- 797
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 798
	local botRgba = ao > 0.005 and scaleRGBA( -- 799
		colRgba, -- 799
		math.max(0.4, 1 - ao), -- 799
		1 -- 799
	) or colRgba -- 799
	local edgeRgba = opts.edgeColor or mat.edge -- 801
	local edgeW = opts.edgeWidth or 0 -- 802
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 803
		edgeRgba, -- 804
		math.floor(edgeRgba.a * opacity + 0.5) -- 804
	) or nil -- 804
	local ____self_faces_13 = self.faces -- 804
	____self_faces_13[#____self_faces_13 + 1] = { -- 807
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 808
		sortZ = avgZ, -- 809
		sortBias = opts.sortBias or 0, -- 810
		pts = {p0, p1, p2}, -- 811
		cols = { -- 812
			toColor(botRgba), -- 812
			toColor(botRgba), -- 812
			toColor(colRgba) -- 812
		}, -- 812
		edgeCol = edgeCol, -- 813
		edgeWidth = edgeW, -- 814
		topHighlight = nil -- 815
	} -- 815
end -- 774
function LowpolyScene.prototype.addBox(self, spec) -- 823
	local opacity = spec.opacity or 1 -- 824
	if opacity <= 0.01 then -- 824
		return -- 826
	end -- 826
	local x0 = math.min(spec.x0, spec.x1) -- 828
	local x1 = math.max(spec.x0, spec.x1) -- 829
	local y0 = math.min(spec.y0, spec.y1) -- 830
	local y1 = math.max(spec.y0, spec.y1) -- 831
	local z0 = math.min(spec.z0, spec.z1) -- 832
	local z1 = math.max(spec.z0, spec.z1) -- 833
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 835
	local bias = spec.sortBias or 0 -- 836
	local hasTex = spec.material.texture ~= nil and spec.material.texture ~= "" -- 837
	local edgeW = hasTex and 0 or (spec.edgeWidth or 0) -- 838
	local midZ = (z0 + z1) * 0.5 -- 839
	local vp = self:vanishingPointScreen() -- 840
	local m = ____exports.clamp01(self.proj.morph) -- 841
	local sx0 = self.cam:sx(x0) -- 843
	local sx1 = self.cam:sx(x1) -- 844
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 845
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 846
	if m > 0.002 and z1 - z0 > 0.05 then -- 846
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 846
			self:addQuad3D( -- 851
				____exports.vec3(x0, y0, z1), -- 852
				____exports.vec3(x0, y0, z0), -- 853
				____exports.vec3(x0, y1, z0), -- 854
				____exports.vec3(x0, y1, z1), -- 855
				spec.material, -- 856
				{ -- 857
					bucket = bucket, -- 857
					sortZOverride = midZ + 0.4, -- 857
					sortBias = bias - 0.1, -- 857
					opacity = opacity, -- 857
					edgeWidth = edgeW -- 857
				} -- 857
			) -- 857
		end -- 857
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 857
			self:addQuad3D( -- 862
				____exports.vec3(x1, y0, z0), -- 863
				____exports.vec3(x1, y0, z1), -- 864
				____exports.vec3(x1, y1, z1), -- 865
				____exports.vec3(x1, y1, z0), -- 866
				spec.material, -- 867
				{ -- 868
					bucket = bucket, -- 868
					sortZOverride = midZ + 0.4, -- 868
					sortBias = bias - 0.1, -- 868
					opacity = opacity, -- 868
					edgeWidth = edgeW -- 868
				} -- 868
			) -- 868
		end -- 868
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 868
			self:addQuad3D( -- 873
				____exports.vec3(x0, y1, z0), -- 874
				____exports.vec3(x1, y1, z0), -- 875
				____exports.vec3(x1, y1, z1), -- 876
				____exports.vec3(x0, y1, z1), -- 877
				spec.material, -- 878
				{ -- 879
					bucket = bucket, -- 879
					sortZOverride = midZ + 0.2, -- 879
					sortBias = bias - 0.05, -- 879
					opacity = opacity, -- 879
					edgeWidth = edgeW, -- 879
					bottomAo = 0.08 -- 879
				} -- 879
			) -- 879
		end -- 879
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 879
			self:addQuad3D( -- 884
				____exports.vec3(x0, y0, z1), -- 885
				____exports.vec3(x1, y0, z1), -- 886
				____exports.vec3(x1, y0, z0), -- 887
				____exports.vec3(x0, y0, z0), -- 888
				spec.material, -- 889
				{ -- 890
					bucket = bucket, -- 890
					sortZOverride = midZ + 0.2, -- 890
					sortBias = bias - 0.05, -- 890
					opacity = opacity, -- 890
					edgeWidth = edgeW, -- 890
					bottomAo = 0.34 -- 890
				} -- 890
			) -- 890
		end -- 890
	end -- 890
	if spec.skipFront ~= true then -- 890
		local beforeLen = #self.faces -- 897
		self:addQuad3D( -- 898
			____exports.vec3(x0, y0, z0), -- 899
			____exports.vec3(x1, y0, z0), -- 900
			____exports.vec3(x1, y1, z0), -- 901
			____exports.vec3(x0, y1, z0), -- 902
			spec.material, -- 903
			{ -- 904
				bucket = bucket, -- 904
				sortZOverride = z0, -- 904
				sortBias = bias, -- 904
				opacity = opacity, -- 904
				edgeWidth = edgeW -- 904
			} -- 904
		) -- 904
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 904
			local face = self.faces[#self.faces] -- 907
			local rimCol = spec.material.edge or rgba(198, 206, 214, 110) -- 908
			local rimAlpha = math.floor(math.min(hasTex and 96 or 165, rimCol.a * (hasTex and 0.62 or 0.95)) * opacity + 0.5) -- 910
			face.topHighlight = { -- 911
				face.pts[4], -- 912
				face.pts[3], -- 913
				toColor(rimCol, rimAlpha) -- 914
			} -- 914
		end -- 914
	end -- 914
end -- 823
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 924
	if opts == nil then -- 924
		opts = {} -- 934
	end -- 934
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 942
	local opacity = opts.opacity or 1 -- 943
	local bias = opts.sortBias or 0 -- 944
	self:addBox({ -- 947
		x0 = openX0 - pillarW, -- 948
		x1 = openX0, -- 949
		y0 = y0, -- 950
		y1 = openY1 + lintelH, -- 951
		z0 = z0, -- 952
		z1 = z1, -- 953
		material = mat, -- 954
		bucket = bucket, -- 955
		sortBias = bias, -- 956
		opacity = opacity, -- 957
		highlightTopEdge = true -- 958
	}) -- 958
	self:addBox({ -- 961
		x0 = openX1, -- 962
		x1 = openX1 + pillarW, -- 963
		y0 = y0, -- 964
		y1 = openY1 + lintelH, -- 965
		z0 = z0, -- 966
		z1 = z1, -- 967
		material = mat, -- 968
		bucket = bucket, -- 969
		sortBias = bias, -- 970
		opacity = opacity, -- 971
		highlightTopEdge = true -- 972
	}) -- 972
	self:addBox({ -- 975
		x0 = openX0 - pillarW * 0.2, -- 976
		x1 = openX1 + pillarW * 0.2, -- 977
		y0 = openY1, -- 978
		y1 = openY1 + lintelH, -- 979
		z0 = z0, -- 980
		z1 = z1, -- 981
		material = mat, -- 982
		bucket = bucket, -- 983
		sortBias = bias + 0.05, -- 984
		opacity = opacity, -- 985
		highlightTopEdge = true -- 986
	}) -- 986
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 990
	if rimAlpha > 0.02 then -- 990
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 992
		local p0 = self:project(openX0, y0 + 2, z0) -- 993
		local p1 = self:project(openX0, y0 + 2, z1) -- 994
		local p2 = self:project(openX0, openY1 - 2, z1) -- 995
		local p3 = self:project(openX0, openY1 - 2, z0) -- 996
		local cNear = toColor( -- 997
			rimCol, -- 997
			math.floor(135 * rimAlpha + 0.5) -- 997
		) -- 997
		local cFar = toColor( -- 998
			rimCol, -- 998
			math.floor(28 * rimAlpha + 0.5) -- 998
		) -- 998
		local ____self_glows_14 = self.glows -- 998
		____self_glows_14[#____self_glows_14 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 999
	end -- 999
end -- 924
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 1007
	if mat == nil then -- 1007
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 1011
	end -- 1011
	if opts == nil then -- 1011
		opts = {} -- 1012
	end -- 1012
	local n = math.max(1, stair.steps + 1) -- 1014
	local stepW = (stair.x1 - stair.x0) / n -- 1015
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 1016
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1017
	local opacity = opts.opacity or 1 -- 1018
	local bias = opts.sortBias or 0 -- 1019
	local k = 0 -- 1021
	do -- 1021
		k = 0 -- 1022
		while k < n do -- 1022
			do -- 1022
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 1023
				local wx0 = stair.x0 + stepW * k -- 1024
				local wx1 = wx0 + stepW -- 1025
				if wy <= floorY + 1 then -- 1025
					goto __continue51 -- 1027
				end -- 1027
				self:addBox({ -- 1029
					x0 = wx0, -- 1030
					x1 = wx1, -- 1031
					y0 = floorY, -- 1032
					y1 = wy, -- 1033
					z0 = z0, -- 1034
					z1 = z1, -- 1035
					material = mat, -- 1036
					bucket = bucket, -- 1037
					sortBias = bias + k * 0.01, -- 1038
					opacity = opacity, -- 1039
					highlightTopEdge = true, -- 1040
					edgeWidth = 0.9 -- 1041
				}) -- 1041
			end -- 1041
			::__continue51:: -- 1041
			k = k + 1 -- 1022
		end -- 1022
	end -- 1022
end -- 1007
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 1050
	if mat == nil then -- 1050
		mat = ____exports.MING_MATERIALS.mingTimber -- 1058
	end -- 1058
	if opts == nil then -- 1058
		opts = {} -- 1059
	end -- 1059
	local count = math.max( -- 1067
		1, -- 1067
		math.floor(plankCount) -- 1067
	) -- 1067
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1068
	local opacity = opts.opacity or 1 -- 1069
	local bias = opts.sortBias or 0 -- 1070
	local spanZ = math.max(1, z1 - z0) -- 1071
	local gap = math.min(2.6, spanZ / (count * 6)) -- 1072
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 1073
	if opts.withPosts == true then -- 1073
		local postBot = opts.postBottomY or topY - 92 -- 1077
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 1078
		local postCount = math.max( -- 1079
			2, -- 1079
			math.min( -- 1079
				5, -- 1079
				math.floor((x1 - x0) / 110) + 1 -- 1079
			) -- 1079
		) -- 1079
		local pi = 0 -- 1080
		do -- 1080
			pi = 0 -- 1081
			while pi < postCount do -- 1081
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 1082
				self:addBox({ -- 1083
					x0 = px - 6, -- 1084
					x1 = px + 6, -- 1085
					y0 = postBot, -- 1086
					y1 = topY - thickness, -- 1087
					z0 = z0 + 4, -- 1088
					z1 = z0 + 18, -- 1089
					material = postMat, -- 1090
					bucket = bucket, -- 1091
					sortBias = bias - 0.3, -- 1092
					opacity = opacity, -- 1093
					edgeWidth = 0.7 -- 1094
				}) -- 1094
				pi = pi + 1 -- 1081
			end -- 1081
		end -- 1081
	end -- 1081
	local i = 0 -- 1100
	do -- 1100
		i = 0 -- 1101
		while i < count do -- 1101
			local pz0 = z0 + i * (plankDepth + gap) -- 1102
			local pz1 = pz0 + plankDepth -- 1103
			local plankMat = i & 1 == 0 and mat or ({ -- 1104
				base = scaleRGBA(mat.base, 0.88), -- 1107
				edge = mat.edge, -- 1108
				minShade = mat.minShade, -- 1109
				rimBoost = mat.rimBoost, -- 1110
				bottomAo = mat.bottomAo, -- 1111
				texture = mat.texture, -- 1112
				textureTint = mat.textureTint ~= nil and scaleRGBA(mat.textureTint, 0.9) or nil, -- 1113
				subdivX = mat.subdivX, -- 1114
				subdivY = mat.subdivY -- 1115
			}) -- 1115
			self:addBox({ -- 1117
				x0 = x0, -- 1118
				x1 = x1, -- 1119
				y0 = topY - thickness, -- 1120
				y1 = topY, -- 1121
				z0 = pz0, -- 1122
				z1 = pz1, -- 1123
				material = plankMat, -- 1124
				bucket = bucket, -- 1125
				sortBias = bias + (count - i) * 0.01, -- 1126
				opacity = opacity, -- 1127
				highlightTopEdge = i == 0, -- 1128
				edgeWidth = 0.8 -- 1129
			}) -- 1129
			i = i + 1 -- 1101
		end -- 1101
	end -- 1101
end -- 1050
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 1135
	if mat == nil then -- 1135
		mat = ____exports.MING_MATERIALS.distantHill -- 1139
	end -- 1139
	if opts == nil then -- 1139
		opts = {} -- 1140
	end -- 1140
	if #peaks < 2 then -- 1140
		return -- 1143
	end -- 1143
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 1145
	local opacity = opts.opacity or 1 -- 1146
	local bias = opts.sortBias or 0 -- 1147
	local i = 0 -- 1149
	do -- 1149
		i = 0 -- 1150
		while i < #peaks - 1 do -- 1150
			local a = peaks[i + 1] -- 1151
			local b = peaks[i + 1 + 1] -- 1152
			local midX = (a.x + b.x) * 0.5 -- 1153
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 1154
			local ridgeMat = b.y >= a.y and mat or ({ -- 1155
				base = scaleRGBA(mat.base, 0.84), -- 1158
				edge = mat.edge, -- 1159
				minShade = mat.minShade, -- 1160
				rimBoost = mat.rimBoost, -- 1161
				bottomAo = mat.bottomAo -- 1162
			}) -- 1162
			self:addTri3D( -- 1164
				____exports.vec3(a.x, baseY, z), -- 1165
				____exports.vec3(b.x, baseY, z), -- 1166
				____exports.vec3(a.x, a.y, z), -- 1167
				ridgeMat, -- 1168
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 1169
			) -- 1169
			self:addTri3D( -- 1171
				____exports.vec3(b.x, baseY, z), -- 1172
				____exports.vec3(b.x, b.y, z), -- 1173
				____exports.vec3(a.x, a.y, z), -- 1174
				ridgeMat, -- 1175
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 1176
			) -- 1176
			self:addTri3D( -- 1179
				____exports.vec3( -- 1180
					midX, -- 1180
					math.max(baseY, midY), -- 1180
					z - 8 -- 1180
				), -- 1180
				____exports.vec3(b.x, baseY, z), -- 1181
				____exports.vec3(b.x, b.y, z), -- 1182
				{ -- 1183
					base = scaleRGBA(mat.base, 0.78), -- 1183
					minShade = 0.3, -- 1183
					bottomAo = 0.2 -- 1183
				}, -- 1183
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 1184
			) -- 1184
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
end -- 1135
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 1190
	if opts == nil then -- 1190
		opts = {} -- 1199
	end -- 1199
	local m = ____exports.clamp01(self.proj.morph) -- 1201
	local ba = ____exports.clamp01(bottomAlpha * m) -- 1202
	local ta = ____exports.clamp01(topAlpha * m) -- 1203
	if ba <= 0.008 and ta <= 0.008 then -- 1203
		return -- 1205
	end -- 1205
	local p0 = self:project(x0, y0, z) -- 1207
	local p1 = self:project(x1, y0, z) -- 1208
	local p2 = self:project(x1, y1, z) -- 1209
	local p3 = self:project(x0, y1, z) -- 1210
	local cBot = toColor( -- 1211
		color, -- 1211
		math.floor(255 * ba + 0.5) -- 1211
	) -- 1211
	local cTop = toColor( -- 1212
		color, -- 1212
		math.floor(255 * ta + 0.5) -- 1212
	) -- 1212
	local ____self_faces_15 = self.faces -- 1212
	____self_faces_15[#____self_faces_15 + 1] = { -- 1213
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 1214
		sortZ = z, -- 1215
		sortBias = opts.sortBias or 0.5, -- 1216
		pts = {p0, p1, p2, p3}, -- 1217
		cols = {cBot, cBot, cTop, cTop}, -- 1218
		edgeCol = nil, -- 1219
		edgeWidth = 0, -- 1220
		topHighlight = nil -- 1221
	} -- 1221
end -- 1190
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 1226
	local ta = ____exports.clamp01(topAlpha) -- 1238
	local ba = ____exports.clamp01(botAlpha) -- 1239
	if ta <= 0.005 and ba <= 0.005 then -- 1239
		return -- 1241
	end -- 1241
	local p0 = self:project(botX0, botY, z) -- 1243
	local p1 = self:project(botX1, botY, z) -- 1244
	local p2 = self:project(topX1, topY, z) -- 1245
	local p3 = self:project(topX0, topY, z) -- 1246
	local cTop = toColor( -- 1247
		color, -- 1247
		math.floor(255 * ta + 0.5) -- 1247
	) -- 1247
	local cBot = toColor( -- 1248
		color, -- 1248
		math.floor(255 * ba + 0.5) -- 1248
	) -- 1248
	local ____self_glows_16 = self.glows -- 1248
	____self_glows_16[#____self_glows_16 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1249
end -- 1226
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1259
	if opacity == nil then -- 1259
		opacity = 0.72 -- 1264
	end -- 1264
	if opts == nil then -- 1264
		opts = {} -- 1265
	end -- 1265
	local op = ____exports.clamp01(opacity) -- 1267
	if op <= 0.01 then -- 1267
		return -- 1269
	end -- 1269
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1271
	local bias = opts.sortBias or 0.2 -- 1272
	local m = ____exports.clamp01(self.proj.morph) -- 1273
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1274
	local segs = 10 -- 1277
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1278
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1279
	local innerCol = Color( -- 1280
		7, -- 1280
		9, -- 1280
		14, -- 1280
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1280
	) -- 1280
	local outerCol = Color(7, 9, 14, 0) -- 1281
	local i = 0 -- 1282
	do -- 1282
		i = 0 -- 1283
		while i < segs do -- 1283
			local a0 = i / segs * math.pi * 2 -- 1284
			local a1 = (i + 1) / segs * math.pi * 2 -- 1285
			local pA = self:project( -- 1286
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1287
				wy + 0.4, -- 1288
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1289
			) -- 1289
			local pB = self:project( -- 1291
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1292
				wy + 0.4, -- 1293
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1294
			) -- 1294
			local ____self_faces_17 = self.faces -- 1294
			____self_faces_17[#____self_faces_17 + 1] = { -- 1296
				bucket = bucket, -- 1297
				sortZ = 0.05, -- 1298
				sortBias = bias, -- 1299
				pts = {centerP, pA, pB}, -- 1300
				cols = {innerCol, outerCol, outerCol}, -- 1301
				edgeCol = nil, -- 1302
				edgeWidth = 0, -- 1303
				topHighlight = nil -- 1304
			} -- 1304
			i = i + 1 -- 1283
		end -- 1283
	end -- 1283
	local footP = self:project(wx, wy + 0.5, 0) -- 1309
	local coreRx = self.cam:len(radiusX * 0.78) -- 1310
	local coreRy = math.max( -- 1311
		2.5, -- 1311
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1311
	) -- 1311
	local coreIn = Color( -- 1312
		5, -- 1312
		7, -- 1312
		12, -- 1312
		math.floor(210 * op + 0.5) -- 1312
	) -- 1312
	local coreOut = Color( -- 1313
		5, -- 1313
		7, -- 1313
		12, -- 1313
		math.floor(32 * op + 0.5) -- 1313
	) -- 1313
	local coreSegs = 8 -- 1314
	do -- 1314
		i = 0 -- 1315
		while i < coreSegs do -- 1315
			local a0 = i / coreSegs * math.pi * 2 -- 1316
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1317
			local ____self_faces_18 = self.faces -- 1317
			____self_faces_18[#____self_faces_18 + 1] = { -- 1318
				bucket = bucket, -- 1319
				sortZ = 0.01, -- 1320
				sortBias = bias + 0.05, -- 1321
				pts = { -- 1322
					footP, -- 1323
					{ -- 1324
						x = footP.x + math.cos(a0) * coreRx, -- 1324
						y = footP.y + math.sin(a0) * coreRy, -- 1324
						scale = 1, -- 1324
						zEff = 0 -- 1324
					}, -- 1324
					{ -- 1325
						x = footP.x + math.cos(a1) * coreRx, -- 1325
						y = footP.y + math.sin(a1) * coreRy, -- 1325
						scale = 1, -- 1325
						zEff = 0 -- 1325
					} -- 1325
				}, -- 1325
				cols = {coreIn, coreOut, coreOut}, -- 1327
				edgeCol = nil, -- 1328
				edgeWidth = 0, -- 1329
				topHighlight = nil -- 1330
			} -- 1330
			i = i + 1 -- 1315
		end -- 1315
	end -- 1315
end -- 1259
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1339
	if opts == nil then -- 1339
		opts = {} -- 1348
	end -- 1348
	local pBL = self:project(x0, y0, wz) -- 1350
	local pTR = self:project(x1, y1, wz) -- 1351
	local w = math.abs(pTR.x - pBL.x) -- 1352
	local h = math.abs(pTR.y - pBL.y) -- 1353
	if w < 1 or h < 1 then -- 1353
		return false -- 1355
	end -- 1355
	return worldArt:tryPlace( -- 1357
		slotKey, -- 1358
		instanceKey, -- 1359
		(pBL.x + pTR.x) * 0.5, -- 1360
		math.min(pBL.y, pTR.y), -- 1361
		w, -- 1362
		h, -- 1363
		{ -- 1364
			color = opts.color or Color(28, 32, 42, 255), -- 1365
			opacity = opts.opacity or 0.92, -- 1366
			layer = opts.layer or 5200 -- 1367
		} -- 1367
	) -- 1367
end -- 1339
function LowpolyScene.prototype.drawFaceToNode(self, target, f) -- 1373
	if #f.pts == 3 then -- 1373
		target:drawVertices({ -- 1375
			{ -- 1376
				Vec2(f.pts[1].x, f.pts[1].y), -- 1376
				f.cols[1] -- 1376
			}, -- 1376
			{ -- 1377
				Vec2(f.pts[2].x, f.pts[2].y), -- 1377
				f.cols[2] -- 1377
			}, -- 1377
			{ -- 1378
				Vec2(f.pts[3].x, f.pts[3].y), -- 1378
				f.cols[3] -- 1378
			} -- 1378
		}) -- 1378
	elseif #f.pts == 4 then -- 1378
		local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1381
		local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1382
		local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1383
		local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1384
		target:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1385
		target:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1390
	end -- 1390
	if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1390
		local count = #f.pts -- 1397
		local k = 0 -- 1398
		do -- 1398
			k = 0 -- 1399
			while k < count do -- 1399
				local a = f.pts[k + 1] -- 1400
				local b = f.pts[(k + 1) % count + 1] -- 1401
				target:drawSegment( -- 1402
					Vec2(a.x, a.y), -- 1402
					Vec2(b.x, b.y), -- 1402
					f.edgeWidth * 0.5, -- 1402
					f.edgeCol -- 1402
				) -- 1402
				k = k + 1 -- 1399
			end -- 1399
		end -- 1399
	end -- 1399
	if f.topHighlight ~= nil then -- 1399
		local hl = f.topHighlight -- 1406
		target:drawSegment( -- 1407
			Vec2(hl[1].x, hl[1].y), -- 1407
			Vec2(hl[2].x, hl[2].y), -- 1407
			0.9, -- 1407
			hl[3] -- 1407
		) -- 1407
	end -- 1407
end -- 1373
function LowpolyScene.prototype.flush(self, draw, glowDraw, dioramaHost) -- 1416
	if #self.faces > 1 then -- 1416
		__TS__ArraySort( -- 1418
			self.faces, -- 1418
			function(____, a, b) -- 1418
				if a.bucket ~= b.bucket then -- 1418
					return a.bucket - b.bucket -- 1420
				end -- 1420
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1420
					return b.sortZ - a.sortZ -- 1423
				end -- 1423
				return a.sortBias - b.sortBias -- 1425
			end -- 1418
		) -- 1418
	end -- 1418
	local runDraw -- 1429
	local i = 0 -- 1431
	do -- 1431
		i = 0 -- 1432
		while i < #self.faces do -- 1432
			do -- 1432
				local f = self.faces[i + 1] -- 1433
				if dioramaHost ~= nil then -- 1433
					if f.cutout ~= nil then -- 1433
						runDraw = nil -- 1437
						local c = f.cutout -- 1438
						dioramaHost:placeCutoutCard({ -- 1439
							clipStr = c.clipStr, -- 1440
							x = c.x, -- 1441
							y = c.y, -- 1442
							targetW = c.w, -- 1443
							targetH = c.h, -- 1444
							order = dioramaHost:nextOrder(), -- 1445
							anchorX = c.anchorX, -- 1446
							anchorY = c.anchorY, -- 1447
							facing = c.facing, -- 1448
							flipY = c.flipY, -- 1449
							angle = c.angle, -- 1450
							color = c.color, -- 1451
							opacity = c.opacity, -- 1452
							smooth = c.smooth, -- 1453
							additive = c.additive -- 1454
						}) -- 1454
						goto __continue88 -- 1456
					end -- 1456
					if f.texture ~= nil and f.worldQuad ~= nil then -- 1456
						local order = dioramaHost:nextOrder() -- 1460
						local placed = dioramaHost:placeTexturedQuad({ -- 1461
							clipStr = f.texture, -- 1462
							v0 = f.worldQuad[1], -- 1463
							v1 = f.worldQuad[2], -- 1464
							v2 = f.worldQuad[3], -- 1465
							v3 = f.worldQuad[4], -- 1466
							segX = f.subdivX or 2, -- 1467
							segY = f.subdivY or 2, -- 1468
							projector = self, -- 1469
							tintColor = f.texTint or f.cols[3] or Color(255, 255, 255, 255), -- 1470
							opacity = f.texOpacity or 1, -- 1471
							order = order, -- 1472
							additive = f.additive, -- 1473
							wave = f.wave -- 1474
						}) -- 1474
						if placed then -- 1474
							runDraw = nil -- 1477
							if f.topHighlight ~= nil then -- 1477
								local rimNode = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1480
								local hl = f.topHighlight -- 1481
								rimNode:drawSegment( -- 1482
									Vec2(hl[1].x, hl[1].y), -- 1482
									Vec2(hl[2].x, hl[2].y), -- 1482
									0.85, -- 1482
									hl[3] -- 1482
								) -- 1482
								runDraw = rimNode -- 1483
							end -- 1483
							goto __continue88 -- 1485
						end -- 1485
					end -- 1485
					if runDraw == nil then -- 1485
						runDraw = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1490
					end -- 1490
					self:drawFaceToNode(runDraw, f) -- 1492
				else -- 1492
					if f.cutout ~= nil then -- 1492
						goto __continue88 -- 1495
					end -- 1495
					self:drawFaceToNode(draw, f) -- 1497
				end -- 1497
			end -- 1497
			::__continue88:: -- 1497
			i = i + 1 -- 1432
		end -- 1432
	end -- 1432
	if glowDraw ~= nil and #self.glows > 0 then -- 1432
		do -- 1432
			i = 0 -- 1502
			while i < #self.glows do -- 1502
				local g = self.glows[i + 1] -- 1503
				if #g.pts == 4 then -- 1503
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1505
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1506
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1507
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1508
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1509
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1514
				end -- 1514
				i = i + 1 -- 1502
			end -- 1502
		end -- 1502
	end -- 1502
	self.faces = {} -- 1523
	self.glows = {} -- 1524
end -- 1416
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time) -- 1533
	scene:addDistantRidge( -- 1542
		{ -- 1543
			{x = room.minX - 180, y = 125}, -- 1544
			{x = room.minX + 120, y = 196}, -- 1545
			{x = room.minX + 420, y = 162}, -- 1546
			{x = room.minX + 760, y = 224}, -- 1547
			{x = room.maxX + 220, y = 150} -- 1548
		}, -- 1548
		-40, -- 1548
		420, -- 1551
		____exports.MING_MATERIALS.distantHill, -- 1552
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1553
	) -- 1553
	scene:addFogBand( -- 1555
		room.minX - 240, -- 1555
		room.maxX + 240, -- 1555
		-30, -- 1555
		175, -- 1555
		290, -- 1555
		scene.light.fogColor, -- 1555
		0.56, -- 1555
		0.04, -- 1555
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1555
	) -- 1555
	local i = 0 -- 1560
	do -- 1560
		i = 0 -- 1561
		while i < #room.floors do -- 1561
			local fl = room.floors[i + 1] -- 1562
			local isMain = fl.y <= 0.1 -- 1563
			if isMain then -- 1563
				scene:addBox({ -- 1565
					x0 = fl.x0, -- 1566
					x1 = fl.x1, -- 1567
					y0 = -48, -- 1568
					y1 = fl.y, -- 1569
					z0 = -26, -- 1570
					z1 = 88, -- 1571
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1572
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1573
					highlightTopEdge = true -- 1574
				}) -- 1574
			else -- 1574
				scene:addPlankDeck( -- 1578
					fl.x0, -- 1578
					fl.x1, -- 1578
					fl.y, -- 1578
					-24, -- 1578
					52, -- 1578
					5, -- 1578
					11, -- 1578
					____exports.MING_MATERIALS.mingTimber, -- 1578
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1578
				) -- 1578
			end -- 1578
			i = i + 1 -- 1561
		end -- 1561
	end -- 1561
	do -- 1561
		i = 0 -- 1587
		while i < #room.stairs do -- 1587
			scene:addStairFlight( -- 1588
				room.stairs[i + 1], -- 1588
				14, -- 1588
				76, -- 1588
				____exports.MING_MATERIALS.mingStoneStep, -- 1588
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1588
			) -- 1588
			i = i + 1 -- 1587
		end -- 1587
	end -- 1587
	do -- 1587
		i = 0 -- 1595
		while i < #room.solids do -- 1595
			do -- 1595
				local s = room.solids[i + 1] -- 1596
				if s.id == "outside_red_cart" then -- 1596
					goto __continue109 -- 1598
				end -- 1598
				scene:addBox({ -- 1600
					x0 = s.x, -- 1601
					x1 = s.x + s.w, -- 1602
					y0 = s.y, -- 1603
					y1 = s.y + s.h, -- 1604
					z0 = -8, -- 1605
					z1 = 72, -- 1606
					material = ____exports.MING_MATERIALS.mingBrick, -- 1607
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1608
					highlightTopEdge = true -- 1609
				}) -- 1609
				if s.y > 10 then -- 1609
					scene:addBox({ -- 1612
						x0 = s.x, -- 1613
						x1 = s.x + 18, -- 1614
						y0 = 0, -- 1615
						y1 = s.y, -- 1616
						z0 = 32, -- 1617
						z1 = 72, -- 1618
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1619
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1620
						sortBias = -0.08, -- 1621
						edgeWidth = 0.7 -- 1622
					}) -- 1622
					scene:addBox({ -- 1624
						x0 = s.x + s.w - 18, -- 1625
						x1 = s.x + s.w, -- 1626
						y0 = 0, -- 1627
						y1 = s.y, -- 1628
						z0 = 32, -- 1629
						z1 = 72, -- 1630
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1631
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1632
						sortBias = -0.08, -- 1633
						edgeWidth = 0.7 -- 1634
					}) -- 1634
				end -- 1634
			end -- 1634
			::__continue109:: -- 1634
			i = i + 1 -- 1595
		end -- 1595
	end -- 1595
	local arch = room.arch -- 1640
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1640
		scene:addBeveledFrame( -- 1642
			arch.x0, -- 1642
			arch.x1, -- 1642
			arch.y, -- 1642
			arch.y + arch.h, -- 1642
			22, -- 1642
			18, -- 1642
			-10, -- 1642
			64, -- 1642
			____exports.MING_MATERIALS.mingStoneStep, -- 1642
			{ -- 1642
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1643
				innerRimLight = rgba(176, 206, 228, 255), -- 1644
				innerRimStrength = 0.45 -- 1645
			} -- 1645
		) -- 1645
	end -- 1645
	local c = room.cart -- 1650
	if c.bodyW > 0 then -- 1650
		scene:addContactShadow( -- 1652
			cartAxle, -- 1652
			c.baseY, -- 1652
			c.bodyW * 0.62, -- 1652
			14, -- 1652
			0.7, -- 1652
			{bucket = ____exports.LP_BUCKET.PROP} -- 1652
		) -- 1652
		local clothX = cartAxle - c.bodyW * 0.5 -- 1653
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1654
		scene:addWavingQuad3D( -- 1655
			____exports.vec3(clothX - 11, clothTop - 22, -6), -- 1656
			____exports.vec3(clothX + 5, clothTop - 20, -5), -- 1657
			____exports.vec3(clothX + 8, clothTop, -4), -- 1658
			____exports.vec3(clothX - 2, clothTop, -4), -- 1659
			____exports.MING_MATERIALS.mingRedCloth, -- 1660
			{ -- 1661
				ampX = 6, -- 1661
				ampY = 2.2, -- 1661
				phase = time * 3.1, -- 1661
				freqU = 1.8, -- 1661
				freqV = 2.6, -- 1661
				pin = "top" -- 1661
			}, -- 1661
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, subdivX = 3, subdivY = 4} -- 1662
		) -- 1662
	end -- 1662
	scene:addContactShadow( -- 1667
		actorX, -- 1667
		actorY, -- 1667
		15, -- 1667
		11, -- 1667
		0.78, -- 1667
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1667
	) -- 1667
end -- 1533
return ____exports -- 1533