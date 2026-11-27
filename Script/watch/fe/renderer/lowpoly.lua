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
	local bottomShade = ao > 0.005 and math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)) or 1 -- 663
	local botRgba = scaleRGBA(topRgba, bottomShade) -- 664
	local cBot = toColor(botRgba) -- 665
	local cTop = toColor(topRgba) -- 666
	local edgeRgba = opts.edgeColor or mat.edge -- 669
	local edgeW = hasTex and 0 or (opts.edgeWidth or 0) -- 670
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 671
		edgeRgba, -- 672
		math.floor(edgeRgba.a * opacity + 0.5) -- 672
	) or nil -- 672
	local ____self_faces_11 = self.faces -- 675
	local ____temp_5 = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 676
	local ____temp_6 = opts.sortBias or 0 -- 678
	local ____temp_7 = {p0, p1, p2, p3} -- 679
	local ____temp_8 = {cBot, cBot, cTop, cTop} -- 680
	local ____edgeCol_9 = edgeCol -- 681
	local ____temp_10 = hasTex and ({v0, v1, v2, v3}) or nil -- 684
	local ____hasTex_4 -- 685
	if hasTex then -- 685
		____hasTex_4 = mat.texture -- 685
	else -- 685
		____hasTex_4 = nil -- 685
	end -- 685
	____self_faces_11[#____self_faces_11 + 1] = { -- 675
		bucket = ____temp_5, -- 676
		sortZ = avgZ, -- 677
		sortBias = ____temp_6, -- 678
		pts = ____temp_7, -- 679
		cols = ____temp_8, -- 680
		edgeCol = ____edgeCol_9, -- 681
		edgeWidth = edgeW, -- 682
		topHighlight = nil, -- 683
		worldQuad = ____temp_10, -- 684
		texture = ____hasTex_4, -- 685
		texTint = texTint, -- 686
		texBottomShade = bottomShade, -- 687
		texOpacity = opacity, -- 688
		subdivX = opts.subdivX or mat.subdivX or 2, -- 689
		subdivY = opts.subdivY or mat.subdivY or 2, -- 690
		wave = opts.wave, -- 691
		additive = opts.additive -- 692
	} -- 692
end -- 615
function LowpolyScene.prototype.addWavingQuad3D(self, v0, v1, v2, v3, mat, wave, opts) -- 697
	if opts == nil then -- 697
		opts = {} -- 704
	end -- 704
	self:addQuad3D( -- 706
		v0, -- 706
		v1, -- 706
		v2, -- 706
		v3, -- 706
		mat, -- 706
		__TS__ObjectAssign({}, opts, {wave = wave, subdivX = opts.subdivX or mat.subdivX or 4, subdivY = opts.subdivY or mat.subdivY or 3}) -- 706
	) -- 706
end -- 697
function LowpolyScene.prototype.addCutout3D(self, clipStr, wx, wy, wz, worldW, worldH, opts) -- 718
	if opts == nil then -- 718
		opts = {} -- 725
	end -- 725
	local opacity = opts.opacity or 1 -- 727
	if opacity <= 0.01 or worldW <= 0.5 or worldH <= 0.5 then -- 727
		return -- 729
	end -- 729
	local pt = self:project(wx, wy, wz) -- 731
	local screenW = self.cam:len(worldW) * pt.scale -- 732
	local screenH = self.cam:len(worldH) * pt.scale -- 733
	if screenW < 1 or screenH < 1 then -- 733
		return -- 735
	end -- 735
	local baseTint = opts.tint or rgba(240, 244, 248, 255) -- 737
	local finalRgba = baseTint -- 738
	if opts.unlit ~= true then -- 738
		local m = ____exports.clamp01(self.proj.morph) -- 740
		if wz > self.light.fogStartZ and m > 0.01 then -- 740
			local span = math.max(1, self.light.fogEndZ - self.light.fogStartZ) -- 742
			local fogT = ____exports.clamp01((wz - self.light.fogStartZ) / span) * self.light.fogMaxAlpha * 0.72 * m -- 743
			finalRgba = lerpRGBA(baseTint, self.light.fogColor, fogT) -- 744
		end -- 744
	end -- 744
	local ____self_faces_12 = self.faces -- 744
	____self_faces_12[#____self_faces_12 + 1] = { -- 747
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 748
		sortZ = wz, -- 749
		sortBias = opts.sortBias or 0, -- 750
		pts = {}, -- 751
		cols = {}, -- 752
		edgeCol = nil, -- 753
		edgeWidth = 0, -- 754
		topHighlight = nil, -- 755
		cutout = { -- 756
			clipStr = clipStr, -- 757
			x = pt.x, -- 758
			y = pt.y, -- 759
			w = screenW, -- 760
			h = screenH, -- 761
			anchorX = opts.anchorX or 0.5, -- 762
			anchorY = opts.anchorY or 0, -- 763
			facing = opts.facing or 1, -- 764
			flipY = opts.flipY == true, -- 765
			angle = opts.angle or 0, -- 766
			color = toColor(finalRgba, 255), -- 767
			opacity = opacity, -- 768
			smooth = opts.smooth ~= false, -- 769
			additive = opts.additive == true -- 770
		} -- 770
	} -- 770
end -- 718
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 776
	if opts == nil then -- 776
		opts = {} -- 781
	end -- 781
	local opacity = opts.opacity or 1 -- 783
	if opacity <= 0.01 then -- 783
		return -- 785
	end -- 785
	local p0 = self:project(v0.x, v0.y, v0.z) -- 787
	local p1 = self:project(v1.x, v1.y, v1.z) -- 788
	local p2 = self:project(v2.x, v2.y, v2.z) -- 789
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 791
	if area2 < 0.25 then -- 791
		return -- 793
	end -- 793
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 796
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 797
		mat.base, -- 799
		cross3( -- 799
			sub3(v1, v0), -- 799
			sub3(v2, v0) -- 799
		), -- 799
		avgZ, -- 799
		self.proj.morph, -- 799
		self.light, -- 799
		mat, -- 799
		opacity -- 799
	) -- 799
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 800
	local botRgba = ao > 0.005 and scaleRGBA( -- 801
		colRgba, -- 801
		math.max(0.4, 1 - ao), -- 801
		1 -- 801
	) or colRgba -- 801
	local edgeRgba = opts.edgeColor or mat.edge -- 803
	local edgeW = opts.edgeWidth or 0 -- 804
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 805
		edgeRgba, -- 806
		math.floor(edgeRgba.a * opacity + 0.5) -- 806
	) or nil -- 806
	local ____self_faces_13 = self.faces -- 806
	____self_faces_13[#____self_faces_13 + 1] = { -- 809
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 810
		sortZ = avgZ, -- 811
		sortBias = opts.sortBias or 0, -- 812
		pts = {p0, p1, p2}, -- 813
		cols = { -- 814
			toColor(botRgba), -- 814
			toColor(botRgba), -- 814
			toColor(colRgba) -- 814
		}, -- 814
		edgeCol = edgeCol, -- 815
		edgeWidth = edgeW, -- 816
		topHighlight = nil -- 817
	} -- 817
end -- 776
function LowpolyScene.prototype.addBox(self, spec) -- 825
	local opacity = spec.opacity or 1 -- 826
	if opacity <= 0.01 then -- 826
		return -- 828
	end -- 828
	local x0 = math.min(spec.x0, spec.x1) -- 830
	local x1 = math.max(spec.x0, spec.x1) -- 831
	local y0 = math.min(spec.y0, spec.y1) -- 832
	local y1 = math.max(spec.y0, spec.y1) -- 833
	local z0 = math.min(spec.z0, spec.z1) -- 834
	local z1 = math.max(spec.z0, spec.z1) -- 835
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 837
	local bias = spec.sortBias or 0 -- 838
	local hasTex = spec.material.texture ~= nil and spec.material.texture ~= "" -- 839
	local edgeW = hasTex and 0 or (spec.edgeWidth or 0) -- 840
	local midZ = (z0 + z1) * 0.5 -- 841
	local vp = self:vanishingPointScreen() -- 842
	local m = ____exports.clamp01(self.proj.morph) -- 843
	local sx0 = self.cam:sx(x0) -- 845
	local sx1 = self.cam:sx(x1) -- 846
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 847
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 848
	if m > 0.002 and z1 - z0 > 0.05 then -- 848
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 848
			self:addQuad3D( -- 853
				____exports.vec3(x0, y0, z1), -- 854
				____exports.vec3(x0, y0, z0), -- 855
				____exports.vec3(x0, y1, z0), -- 856
				____exports.vec3(x0, y1, z1), -- 857
				spec.material, -- 858
				{ -- 859
					bucket = bucket, -- 859
					sortZOverride = midZ + 0.4, -- 859
					sortBias = bias - 0.1, -- 859
					opacity = opacity, -- 859
					edgeWidth = edgeW -- 859
				} -- 859
			) -- 859
		end -- 859
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 859
			self:addQuad3D( -- 864
				____exports.vec3(x1, y0, z0), -- 865
				____exports.vec3(x1, y0, z1), -- 866
				____exports.vec3(x1, y1, z1), -- 867
				____exports.vec3(x1, y1, z0), -- 868
				spec.material, -- 869
				{ -- 870
					bucket = bucket, -- 870
					sortZOverride = midZ + 0.4, -- 870
					sortBias = bias - 0.1, -- 870
					opacity = opacity, -- 870
					edgeWidth = edgeW -- 870
				} -- 870
			) -- 870
		end -- 870
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 870
			self:addQuad3D( -- 875
				____exports.vec3(x0, y1, z0), -- 876
				____exports.vec3(x1, y1, z0), -- 877
				____exports.vec3(x1, y1, z1), -- 878
				____exports.vec3(x0, y1, z1), -- 879
				spec.material, -- 880
				{ -- 881
					bucket = bucket, -- 881
					sortZOverride = midZ + 0.2, -- 881
					sortBias = bias - 0.05, -- 881
					opacity = opacity, -- 881
					edgeWidth = edgeW, -- 881
					bottomAo = 0.08 -- 881
				} -- 881
			) -- 881
		end -- 881
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 881
			self:addQuad3D( -- 886
				____exports.vec3(x0, y0, z1), -- 887
				____exports.vec3(x1, y0, z1), -- 888
				____exports.vec3(x1, y0, z0), -- 889
				____exports.vec3(x0, y0, z0), -- 890
				spec.material, -- 891
				{ -- 892
					bucket = bucket, -- 892
					sortZOverride = midZ + 0.2, -- 892
					sortBias = bias - 0.05, -- 892
					opacity = opacity, -- 892
					edgeWidth = edgeW, -- 892
					bottomAo = 0.34 -- 892
				} -- 892
			) -- 892
		end -- 892
	end -- 892
	if spec.skipFront ~= true then -- 892
		local beforeLen = #self.faces -- 899
		self:addQuad3D( -- 900
			____exports.vec3(x0, y0, z0), -- 901
			____exports.vec3(x1, y0, z0), -- 902
			____exports.vec3(x1, y1, z0), -- 903
			____exports.vec3(x0, y1, z0), -- 904
			spec.material, -- 905
			{ -- 906
				bucket = bucket, -- 906
				sortZOverride = z0, -- 906
				sortBias = bias, -- 906
				opacity = opacity, -- 906
				edgeWidth = edgeW -- 906
			} -- 906
		) -- 906
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 906
			local face = self.faces[#self.faces] -- 909
			local rimCol = spec.material.edge or rgba(198, 206, 214, 110) -- 910
			local rimAlpha = math.floor(math.min(hasTex and 96 or 165, rimCol.a * (hasTex and 0.62 or 0.95)) * opacity + 0.5) -- 912
			face.topHighlight = { -- 913
				face.pts[4], -- 914
				face.pts[3], -- 915
				toColor(rimCol, rimAlpha) -- 916
			} -- 916
		end -- 916
	end -- 916
end -- 825
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 926
	if opts == nil then -- 926
		opts = {} -- 936
	end -- 936
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 944
	local opacity = opts.opacity or 1 -- 945
	local bias = opts.sortBias or 0 -- 946
	self:addBox({ -- 949
		x0 = openX0 - pillarW, -- 950
		x1 = openX0, -- 951
		y0 = y0, -- 952
		y1 = openY1 + lintelH, -- 953
		z0 = z0, -- 954
		z1 = z1, -- 955
		material = mat, -- 956
		bucket = bucket, -- 957
		sortBias = bias, -- 958
		opacity = opacity, -- 959
		highlightTopEdge = true -- 960
	}) -- 960
	self:addBox({ -- 963
		x0 = openX1, -- 964
		x1 = openX1 + pillarW, -- 965
		y0 = y0, -- 966
		y1 = openY1 + lintelH, -- 967
		z0 = z0, -- 968
		z1 = z1, -- 969
		material = mat, -- 970
		bucket = bucket, -- 971
		sortBias = bias, -- 972
		opacity = opacity, -- 973
		highlightTopEdge = true -- 974
	}) -- 974
	self:addBox({ -- 977
		x0 = openX0 - pillarW * 0.2, -- 978
		x1 = openX1 + pillarW * 0.2, -- 979
		y0 = openY1, -- 980
		y1 = openY1 + lintelH, -- 981
		z0 = z0, -- 982
		z1 = z1, -- 983
		material = mat, -- 984
		bucket = bucket, -- 985
		sortBias = bias + 0.05, -- 986
		opacity = opacity, -- 987
		highlightTopEdge = true -- 988
	}) -- 988
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 992
	if rimAlpha > 0.02 then -- 992
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 994
		local p0 = self:project(openX0, y0 + 2, z0) -- 995
		local p1 = self:project(openX0, y0 + 2, z1) -- 996
		local p2 = self:project(openX0, openY1 - 2, z1) -- 997
		local p3 = self:project(openX0, openY1 - 2, z0) -- 998
		local cNear = toColor( -- 999
			rimCol, -- 999
			math.floor(135 * rimAlpha + 0.5) -- 999
		) -- 999
		local cFar = toColor( -- 1000
			rimCol, -- 1000
			math.floor(28 * rimAlpha + 0.5) -- 1000
		) -- 1000
		local ____self_glows_14 = self.glows -- 1000
		____self_glows_14[#____self_glows_14 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 1001
	end -- 1001
end -- 926
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 1009
	if mat == nil then -- 1009
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 1013
	end -- 1013
	if opts == nil then -- 1013
		opts = {} -- 1014
	end -- 1014
	local n = math.max(1, stair.steps + 1) -- 1016
	local stepW = (stair.x1 - stair.x0) / n -- 1017
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 1018
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1019
	local opacity = opts.opacity or 1 -- 1020
	local bias = opts.sortBias or 0 -- 1021
	local k = 0 -- 1023
	do -- 1023
		k = 0 -- 1024
		while k < n do -- 1024
			do -- 1024
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 1025
				local wx0 = stair.x0 + stepW * k -- 1026
				local wx1 = wx0 + stepW -- 1027
				if wy <= floorY + 1 then -- 1027
					goto __continue51 -- 1029
				end -- 1029
				self:addBox({ -- 1031
					x0 = wx0, -- 1032
					x1 = wx1, -- 1033
					y0 = floorY, -- 1034
					y1 = wy, -- 1035
					z0 = z0, -- 1036
					z1 = z1, -- 1037
					material = mat, -- 1038
					bucket = bucket, -- 1039
					sortBias = bias + k * 0.01, -- 1040
					opacity = opacity, -- 1041
					highlightTopEdge = true, -- 1042
					edgeWidth = 0.9 -- 1043
				}) -- 1043
			end -- 1043
			::__continue51:: -- 1043
			k = k + 1 -- 1024
		end -- 1024
	end -- 1024
end -- 1009
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 1052
	if mat == nil then -- 1052
		mat = ____exports.MING_MATERIALS.mingTimber -- 1060
	end -- 1060
	if opts == nil then -- 1060
		opts = {} -- 1061
	end -- 1061
	local count = math.max( -- 1069
		1, -- 1069
		math.floor(plankCount) -- 1069
	) -- 1069
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 1070
	local opacity = opts.opacity or 1 -- 1071
	local bias = opts.sortBias or 0 -- 1072
	local spanZ = math.max(1, z1 - z0) -- 1073
	local gap = math.min(2.6, spanZ / (count * 6)) -- 1074
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 1075
	if opts.withPosts == true then -- 1075
		local postBot = opts.postBottomY or topY - 92 -- 1079
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 1080
		local postCount = math.max( -- 1081
			2, -- 1081
			math.min( -- 1081
				5, -- 1081
				math.floor((x1 - x0) / 110) + 1 -- 1081
			) -- 1081
		) -- 1081
		local pi = 0 -- 1082
		do -- 1082
			pi = 0 -- 1083
			while pi < postCount do -- 1083
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 1084
				self:addBox({ -- 1085
					x0 = px - 6, -- 1086
					x1 = px + 6, -- 1087
					y0 = postBot, -- 1088
					y1 = topY - thickness, -- 1089
					z0 = z0 + 4, -- 1090
					z1 = z0 + 18, -- 1091
					material = postMat, -- 1092
					bucket = bucket, -- 1093
					sortBias = bias - 0.3, -- 1094
					opacity = opacity, -- 1095
					edgeWidth = 0.7 -- 1096
				}) -- 1096
				pi = pi + 1 -- 1083
			end -- 1083
		end -- 1083
	end -- 1083
	local i = 0 -- 1102
	do -- 1102
		i = 0 -- 1103
		while i < count do -- 1103
			local pz0 = z0 + i * (plankDepth + gap) -- 1104
			local pz1 = pz0 + plankDepth -- 1105
			local plankMat = i & 1 == 0 and mat or ({ -- 1106
				base = scaleRGBA(mat.base, 0.88), -- 1109
				edge = mat.edge, -- 1110
				minShade = mat.minShade, -- 1111
				rimBoost = mat.rimBoost, -- 1112
				bottomAo = mat.bottomAo, -- 1113
				texture = mat.texture, -- 1114
				textureTint = mat.textureTint ~= nil and scaleRGBA(mat.textureTint, 0.9) or nil, -- 1115
				subdivX = mat.subdivX, -- 1116
				subdivY = mat.subdivY -- 1117
			}) -- 1117
			self:addBox({ -- 1119
				x0 = x0, -- 1120
				x1 = x1, -- 1121
				y0 = topY - thickness, -- 1122
				y1 = topY, -- 1123
				z0 = pz0, -- 1124
				z1 = pz1, -- 1125
				material = plankMat, -- 1126
				bucket = bucket, -- 1127
				sortBias = bias + (count - i) * 0.01, -- 1128
				opacity = opacity, -- 1129
				highlightTopEdge = i == 0, -- 1130
				edgeWidth = 0.8 -- 1131
			}) -- 1131
			i = i + 1 -- 1103
		end -- 1103
	end -- 1103
end -- 1052
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 1137
	if mat == nil then -- 1137
		mat = ____exports.MING_MATERIALS.distantHill -- 1141
	end -- 1141
	if opts == nil then -- 1141
		opts = {} -- 1142
	end -- 1142
	if #peaks < 2 then -- 1142
		return -- 1145
	end -- 1145
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 1147
	local opacity = opts.opacity or 1 -- 1148
	local bias = opts.sortBias or 0 -- 1149
	local i = 0 -- 1151
	do -- 1151
		i = 0 -- 1152
		while i < #peaks - 1 do -- 1152
			local a = peaks[i + 1] -- 1153
			local b = peaks[i + 1 + 1] -- 1154
			local midX = (a.x + b.x) * 0.5 -- 1155
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 1156
			local ridgeMat = b.y >= a.y and mat or ({ -- 1157
				base = scaleRGBA(mat.base, 0.84), -- 1160
				edge = mat.edge, -- 1161
				minShade = mat.minShade, -- 1162
				rimBoost = mat.rimBoost, -- 1163
				bottomAo = mat.bottomAo -- 1164
			}) -- 1164
			self:addTri3D( -- 1166
				____exports.vec3(a.x, baseY, z), -- 1167
				____exports.vec3(b.x, baseY, z), -- 1168
				____exports.vec3(a.x, a.y, z), -- 1169
				ridgeMat, -- 1170
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 1171
			) -- 1171
			self:addTri3D( -- 1173
				____exports.vec3(b.x, baseY, z), -- 1174
				____exports.vec3(b.x, b.y, z), -- 1175
				____exports.vec3(a.x, a.y, z), -- 1176
				ridgeMat, -- 1177
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 1178
			) -- 1178
			self:addTri3D( -- 1181
				____exports.vec3( -- 1182
					midX, -- 1182
					math.max(baseY, midY), -- 1182
					z - 8 -- 1182
				), -- 1182
				____exports.vec3(b.x, baseY, z), -- 1183
				____exports.vec3(b.x, b.y, z), -- 1184
				{ -- 1185
					base = scaleRGBA(mat.base, 0.78), -- 1185
					minShade = 0.3, -- 1185
					bottomAo = 0.2 -- 1185
				}, -- 1185
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 1186
			) -- 1186
			i = i + 1 -- 1152
		end -- 1152
	end -- 1152
end -- 1137
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 1192
	if opts == nil then -- 1192
		opts = {} -- 1201
	end -- 1201
	local m = ____exports.clamp01(self.proj.morph) -- 1203
	local ba = ____exports.clamp01(bottomAlpha * m) -- 1204
	local ta = ____exports.clamp01(topAlpha * m) -- 1205
	if ba <= 0.008 and ta <= 0.008 then -- 1205
		return -- 1207
	end -- 1207
	local p0 = self:project(x0, y0, z) -- 1209
	local p1 = self:project(x1, y0, z) -- 1210
	local p2 = self:project(x1, y1, z) -- 1211
	local p3 = self:project(x0, y1, z) -- 1212
	local cBot = toColor( -- 1213
		color, -- 1213
		math.floor(255 * ba + 0.5) -- 1213
	) -- 1213
	local cTop = toColor( -- 1214
		color, -- 1214
		math.floor(255 * ta + 0.5) -- 1214
	) -- 1214
	local ____self_faces_15 = self.faces -- 1214
	____self_faces_15[#____self_faces_15 + 1] = { -- 1215
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 1216
		sortZ = z, -- 1217
		sortBias = opts.sortBias or 0.5, -- 1218
		pts = {p0, p1, p2, p3}, -- 1219
		cols = {cBot, cBot, cTop, cTop}, -- 1220
		edgeCol = nil, -- 1221
		edgeWidth = 0, -- 1222
		topHighlight = nil -- 1223
	} -- 1223
end -- 1192
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 1228
	local ta = ____exports.clamp01(topAlpha) -- 1240
	local ba = ____exports.clamp01(botAlpha) -- 1241
	if ta <= 0.005 and ba <= 0.005 then -- 1241
		return -- 1243
	end -- 1243
	local p0 = self:project(botX0, botY, z) -- 1245
	local p1 = self:project(botX1, botY, z) -- 1246
	local p2 = self:project(topX1, topY, z) -- 1247
	local p3 = self:project(topX0, topY, z) -- 1248
	local cTop = toColor( -- 1249
		color, -- 1249
		math.floor(255 * ta + 0.5) -- 1249
	) -- 1249
	local cBot = toColor( -- 1250
		color, -- 1250
		math.floor(255 * ba + 0.5) -- 1250
	) -- 1250
	local ____self_glows_16 = self.glows -- 1250
	____self_glows_16[#____self_glows_16 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1251
end -- 1228
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1261
	if opacity == nil then -- 1261
		opacity = 0.72 -- 1266
	end -- 1266
	if opts == nil then -- 1266
		opts = {} -- 1267
	end -- 1267
	local op = ____exports.clamp01(opacity) -- 1269
	if op <= 0.01 then -- 1269
		return -- 1271
	end -- 1271
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1273
	local bias = opts.sortBias or 0.2 -- 1274
	local m = ____exports.clamp01(self.proj.morph) -- 1275
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1276
	local segs = 10 -- 1279
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1280
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1281
	local innerCol = Color( -- 1282
		7, -- 1282
		9, -- 1282
		14, -- 1282
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1282
	) -- 1282
	local outerCol = Color(7, 9, 14, 0) -- 1283
	local i = 0 -- 1284
	do -- 1284
		i = 0 -- 1285
		while i < segs do -- 1285
			local a0 = i / segs * math.pi * 2 -- 1286
			local a1 = (i + 1) / segs * math.pi * 2 -- 1287
			local pA = self:project( -- 1288
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1289
				wy + 0.4, -- 1290
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1291
			) -- 1291
			local pB = self:project( -- 1293
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1294
				wy + 0.4, -- 1295
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1296
			) -- 1296
			local ____self_faces_17 = self.faces -- 1296
			____self_faces_17[#____self_faces_17 + 1] = { -- 1298
				bucket = bucket, -- 1299
				sortZ = 0.05, -- 1300
				sortBias = bias, -- 1301
				pts = {centerP, pA, pB}, -- 1302
				cols = {innerCol, outerCol, outerCol}, -- 1303
				edgeCol = nil, -- 1304
				edgeWidth = 0, -- 1305
				topHighlight = nil -- 1306
			} -- 1306
			i = i + 1 -- 1285
		end -- 1285
	end -- 1285
	local footP = self:project(wx, wy + 0.5, 0) -- 1311
	local coreRx = self.cam:len(radiusX * 0.78) -- 1312
	local coreRy = math.max( -- 1313
		2.5, -- 1313
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1313
	) -- 1313
	local coreIn = Color( -- 1314
		5, -- 1314
		7, -- 1314
		12, -- 1314
		math.floor(210 * op + 0.5) -- 1314
	) -- 1314
	local coreOut = Color( -- 1315
		5, -- 1315
		7, -- 1315
		12, -- 1315
		math.floor(32 * op + 0.5) -- 1315
	) -- 1315
	local coreSegs = 8 -- 1316
	do -- 1316
		i = 0 -- 1317
		while i < coreSegs do -- 1317
			local a0 = i / coreSegs * math.pi * 2 -- 1318
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1319
			local ____self_faces_18 = self.faces -- 1319
			____self_faces_18[#____self_faces_18 + 1] = { -- 1320
				bucket = bucket, -- 1321
				sortZ = 0.01, -- 1322
				sortBias = bias + 0.05, -- 1323
				pts = { -- 1324
					footP, -- 1325
					{ -- 1326
						x = footP.x + math.cos(a0) * coreRx, -- 1326
						y = footP.y + math.sin(a0) * coreRy, -- 1326
						scale = 1, -- 1326
						zEff = 0 -- 1326
					}, -- 1326
					{ -- 1327
						x = footP.x + math.cos(a1) * coreRx, -- 1327
						y = footP.y + math.sin(a1) * coreRy, -- 1327
						scale = 1, -- 1327
						zEff = 0 -- 1327
					} -- 1327
				}, -- 1327
				cols = {coreIn, coreOut, coreOut}, -- 1329
				edgeCol = nil, -- 1330
				edgeWidth = 0, -- 1331
				topHighlight = nil -- 1332
			} -- 1332
			i = i + 1 -- 1317
		end -- 1317
	end -- 1317
end -- 1261
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1341
	if opts == nil then -- 1341
		opts = {} -- 1350
	end -- 1350
	local pBL = self:project(x0, y0, wz) -- 1352
	local pTR = self:project(x1, y1, wz) -- 1353
	local w = math.abs(pTR.x - pBL.x) -- 1354
	local h = math.abs(pTR.y - pBL.y) -- 1355
	if w < 1 or h < 1 then -- 1355
		return false -- 1357
	end -- 1357
	return worldArt:tryPlace( -- 1359
		slotKey, -- 1360
		instanceKey, -- 1361
		(pBL.x + pTR.x) * 0.5, -- 1362
		math.min(pBL.y, pTR.y), -- 1363
		w, -- 1364
		h, -- 1365
		{ -- 1366
			color = opts.color or Color(28, 32, 42, 255), -- 1367
			opacity = opts.opacity or 0.92, -- 1368
			layer = opts.layer or 5200 -- 1369
		} -- 1369
	) -- 1369
end -- 1341
function LowpolyScene.prototype.drawFaceToNode(self, target, f) -- 1375
	if #f.pts == 3 then -- 1375
		target:drawVertices({ -- 1377
			{ -- 1378
				Vec2(f.pts[1].x, f.pts[1].y), -- 1378
				f.cols[1] -- 1378
			}, -- 1378
			{ -- 1379
				Vec2(f.pts[2].x, f.pts[2].y), -- 1379
				f.cols[2] -- 1379
			}, -- 1379
			{ -- 1380
				Vec2(f.pts[3].x, f.pts[3].y), -- 1380
				f.cols[3] -- 1380
			} -- 1380
		}) -- 1380
	elseif #f.pts == 4 then -- 1380
		local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1383
		local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1384
		local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1385
		local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1386
		target:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1387
		target:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1392
	end -- 1392
	if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1392
		local count = #f.pts -- 1399
		local k = 0 -- 1400
		do -- 1400
			k = 0 -- 1401
			while k < count do -- 1401
				local a = f.pts[k + 1] -- 1402
				local b = f.pts[(k + 1) % count + 1] -- 1403
				target:drawSegment( -- 1404
					Vec2(a.x, a.y), -- 1404
					Vec2(b.x, b.y), -- 1404
					f.edgeWidth * 0.5, -- 1404
					f.edgeCol -- 1404
				) -- 1404
				k = k + 1 -- 1401
			end -- 1401
		end -- 1401
	end -- 1401
	if f.topHighlight ~= nil then -- 1401
		local hl = f.topHighlight -- 1408
		target:drawSegment( -- 1409
			Vec2(hl[1].x, hl[1].y), -- 1409
			Vec2(hl[2].x, hl[2].y), -- 1409
			0.9, -- 1409
			hl[3] -- 1409
		) -- 1409
	end -- 1409
end -- 1375
function LowpolyScene.prototype.flush(self, draw, glowDraw, dioramaHost) -- 1418
	if #self.faces > 1 then -- 1418
		__TS__ArraySort( -- 1420
			self.faces, -- 1420
			function(____, a, b) -- 1420
				if a.bucket ~= b.bucket then -- 1420
					return a.bucket - b.bucket -- 1422
				end -- 1422
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1422
					return b.sortZ - a.sortZ -- 1425
				end -- 1425
				return a.sortBias - b.sortBias -- 1427
			end -- 1420
		) -- 1420
	end -- 1420
	local runDraw -- 1431
	local i = 0 -- 1433
	do -- 1433
		i = 0 -- 1434
		while i < #self.faces do -- 1434
			do -- 1434
				local f = self.faces[i + 1] -- 1435
				if dioramaHost ~= nil then -- 1435
					if f.cutout ~= nil then -- 1435
						runDraw = nil -- 1439
						local c = f.cutout -- 1440
						dioramaHost:placeCutoutCard({ -- 1441
							clipStr = c.clipStr, -- 1442
							x = c.x, -- 1443
							y = c.y, -- 1444
							targetW = c.w, -- 1445
							targetH = c.h, -- 1446
							order = dioramaHost:nextOrder(), -- 1447
							anchorX = c.anchorX, -- 1448
							anchorY = c.anchorY, -- 1449
							facing = c.facing, -- 1450
							flipY = c.flipY, -- 1451
							angle = c.angle, -- 1452
							color = c.color, -- 1453
							opacity = c.opacity, -- 1454
							smooth = c.smooth, -- 1455
							additive = c.additive -- 1456
						}) -- 1456
						goto __continue88 -- 1458
					end -- 1458
					if f.texture ~= nil and f.worldQuad ~= nil then -- 1458
						local order = dioramaHost:nextOrder() -- 1462
						local placed = dioramaHost:placeTexturedQuad({ -- 1463
							clipStr = f.texture, -- 1464
							v0 = f.worldQuad[1], -- 1465
							v1 = f.worldQuad[2], -- 1466
							v2 = f.worldQuad[3], -- 1467
							v3 = f.worldQuad[4], -- 1468
							segX = f.subdivX or 2, -- 1469
							segY = f.subdivY or 2, -- 1470
							projector = self, -- 1471
							bottomShade = f.texBottomShade or 1, -- 1472
							tintColor = f.texTint or f.cols[3] or Color(255, 255, 255, 255), -- 1473
							opacity = f.texOpacity or 1, -- 1474
							order = order, -- 1475
							additive = f.additive, -- 1476
							wave = f.wave -- 1477
						}) -- 1477
						if placed then -- 1477
							runDraw = nil -- 1480
							if f.topHighlight ~= nil then -- 1480
								local rimNode = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1483
								local hl = f.topHighlight -- 1484
								rimNode:drawSegment( -- 1485
									Vec2(hl[1].x, hl[1].y), -- 1485
									Vec2(hl[2].x, hl[2].y), -- 1485
									0.85, -- 1485
									hl[3] -- 1485
								) -- 1485
								runDraw = rimNode -- 1486
							end -- 1486
							goto __continue88 -- 1488
						end -- 1488
					end -- 1488
					if runDraw == nil then -- 1488
						runDraw = dioramaHost:acquireDrawRun(dioramaHost:nextOrder()) -- 1493
					end -- 1493
					self:drawFaceToNode(runDraw, f) -- 1495
				else -- 1495
					if f.cutout ~= nil then -- 1495
						goto __continue88 -- 1498
					end -- 1498
					self:drawFaceToNode(draw, f) -- 1500
				end -- 1500
			end -- 1500
			::__continue88:: -- 1500
			i = i + 1 -- 1434
		end -- 1434
	end -- 1434
	if glowDraw ~= nil and #self.glows > 0 then -- 1434
		do -- 1434
			i = 0 -- 1505
			while i < #self.glows do -- 1505
				local g = self.glows[i + 1] -- 1506
				if #g.pts == 4 then -- 1506
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1508
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1509
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1510
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1511
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1512
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1517
				end -- 1517
				i = i + 1 -- 1505
			end -- 1505
		end -- 1505
	end -- 1505
	self.faces = {} -- 1526
	self.glows = {} -- 1527
end -- 1418
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time) -- 1536
	scene:addDistantRidge( -- 1545
		{ -- 1546
			{x = room.minX - 180, y = 125}, -- 1547
			{x = room.minX + 120, y = 196}, -- 1548
			{x = room.minX + 420, y = 162}, -- 1549
			{x = room.minX + 760, y = 224}, -- 1550
			{x = room.maxX + 220, y = 150} -- 1551
		}, -- 1551
		-40, -- 1551
		420, -- 1554
		____exports.MING_MATERIALS.distantHill, -- 1555
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1556
	) -- 1556
	scene:addFogBand( -- 1558
		room.minX - 240, -- 1558
		room.maxX + 240, -- 1558
		-30, -- 1558
		175, -- 1558
		290, -- 1558
		scene.light.fogColor, -- 1558
		0.56, -- 1558
		0.04, -- 1558
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1558
	) -- 1558
	local i = 0 -- 1563
	do -- 1563
		i = 0 -- 1564
		while i < #room.floors do -- 1564
			local fl = room.floors[i + 1] -- 1565
			local isMain = fl.y <= 0.1 -- 1566
			if isMain then -- 1566
				scene:addBox({ -- 1568
					x0 = fl.x0, -- 1569
					x1 = fl.x1, -- 1570
					y0 = -48, -- 1571
					y1 = fl.y, -- 1572
					z0 = -26, -- 1573
					z1 = 88, -- 1574
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1575
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1576
					highlightTopEdge = true -- 1577
				}) -- 1577
			else -- 1577
				scene:addPlankDeck( -- 1581
					fl.x0, -- 1581
					fl.x1, -- 1581
					fl.y, -- 1581
					-24, -- 1581
					52, -- 1581
					5, -- 1581
					11, -- 1581
					____exports.MING_MATERIALS.mingTimber, -- 1581
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1581
				) -- 1581
			end -- 1581
			i = i + 1 -- 1564
		end -- 1564
	end -- 1564
	do -- 1564
		i = 0 -- 1590
		while i < #room.stairs do -- 1590
			scene:addStairFlight( -- 1591
				room.stairs[i + 1], -- 1591
				14, -- 1591
				76, -- 1591
				____exports.MING_MATERIALS.mingStoneStep, -- 1591
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1591
			) -- 1591
			i = i + 1 -- 1590
		end -- 1590
	end -- 1590
	do -- 1590
		i = 0 -- 1598
		while i < #room.solids do -- 1598
			do -- 1598
				local s = room.solids[i + 1] -- 1599
				if s.id == "outside_red_cart" then -- 1599
					goto __continue109 -- 1601
				end -- 1601
				scene:addBox({ -- 1603
					x0 = s.x, -- 1604
					x1 = s.x + s.w, -- 1605
					y0 = s.y, -- 1606
					y1 = s.y + s.h, -- 1607
					z0 = -8, -- 1608
					z1 = 72, -- 1609
					material = ____exports.MING_MATERIALS.mingBrick, -- 1610
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1611
					highlightTopEdge = true -- 1612
				}) -- 1612
				if s.y > 10 then -- 1612
					scene:addBox({ -- 1615
						x0 = s.x, -- 1616
						x1 = s.x + 18, -- 1617
						y0 = 0, -- 1618
						y1 = s.y, -- 1619
						z0 = 32, -- 1620
						z1 = 72, -- 1621
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1622
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1623
						sortBias = -0.08, -- 1624
						edgeWidth = 0.7 -- 1625
					}) -- 1625
					scene:addBox({ -- 1627
						x0 = s.x + s.w - 18, -- 1628
						x1 = s.x + s.w, -- 1629
						y0 = 0, -- 1630
						y1 = s.y, -- 1631
						z0 = 32, -- 1632
						z1 = 72, -- 1633
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1634
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1635
						sortBias = -0.08, -- 1636
						edgeWidth = 0.7 -- 1637
					}) -- 1637
				end -- 1637
			end -- 1637
			::__continue109:: -- 1637
			i = i + 1 -- 1598
		end -- 1598
	end -- 1598
	local arch = room.arch -- 1643
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1643
		scene:addBeveledFrame( -- 1645
			arch.x0, -- 1645
			arch.x1, -- 1645
			arch.y, -- 1645
			arch.y + arch.h, -- 1645
			22, -- 1645
			18, -- 1645
			-10, -- 1645
			64, -- 1645
			____exports.MING_MATERIALS.mingStoneStep, -- 1645
			{ -- 1645
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1646
				innerRimLight = rgba(176, 206, 228, 255), -- 1647
				innerRimStrength = 0.45 -- 1648
			} -- 1648
		) -- 1648
	end -- 1648
	local c = room.cart -- 1653
	if c.bodyW > 0 then -- 1653
		scene:addContactShadow( -- 1655
			cartAxle, -- 1655
			c.baseY, -- 1655
			c.bodyW * 0.62, -- 1655
			14, -- 1655
			0.7, -- 1655
			{bucket = ____exports.LP_BUCKET.PROP} -- 1655
		) -- 1655
		local clothX = cartAxle - c.bodyW * 0.5 -- 1656
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1657
		scene:addWavingQuad3D( -- 1658
			____exports.vec3(clothX - 11, clothTop - 22, -6), -- 1659
			____exports.vec3(clothX + 5, clothTop - 20, -5), -- 1660
			____exports.vec3(clothX + 8, clothTop, -4), -- 1661
			____exports.vec3(clothX - 2, clothTop, -4), -- 1662
			____exports.MING_MATERIALS.mingRedCloth, -- 1663
			{ -- 1664
				ampX = 6, -- 1664
				ampY = 2.2, -- 1664
				phase = time * 3.1, -- 1664
				freqU = 1.8, -- 1664
				freqV = 2.6, -- 1664
				pin = "top" -- 1664
			}, -- 1664
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, subdivX = 3, subdivY = 4} -- 1665
		) -- 1665
	end -- 1665
	scene:addContactShadow( -- 1670
		actorX, -- 1670
		actorY, -- 1670
		15, -- 1670
		11, -- 1670
		0.78, -- 1670
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1670
	) -- 1670
end -- 1536
return ____exports -- 1536