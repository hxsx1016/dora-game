-- [ts]: lowpoly.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 22
local Color = ____Dora.Color -- 22
local Vec2 = ____Dora.Vec2 -- 22
local ____depth = require("Script.watch.depth") -- 23
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 23
local ____theme = require("Script.watch.fe.theme") -- 27
local lerpRGBA = ____theme.lerpRGBA -- 27
local rgba = ____theme.rgba -- 27
local toColor = ____theme.toColor -- 27
____exports.LP_BUCKET = { -- 91
	BACKDROP = 0, -- 92
	MIDGROUND = 1, -- 93
	WALK_DECK = 2, -- 94
	PROP = 3, -- 95
	FOREGROUND = 4 -- 96
} -- 96
function ____exports.clamp01(v) -- 153
	return math.max( -- 154
		0, -- 154
		math.min(1, v) -- 154
	) -- 154
end -- 153
function ____exports.smoothstep(edge0, edge1, x) -- 157
	if edge1 <= edge0 then -- 158
		return x >= edge1 and 1 or 0 -- 159
	end -- 159
	local t = ____exports.clamp01((x - edge0) / (edge1 - edge0)) -- 161
	return t * t * (3 - 2 * t) -- 162
end -- 157
function ____exports.vec3(x, y, z) -- 165
	return {x = x, y = y, z = z} -- 166
end -- 165
function ____exports.normalize3(v) -- 169
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) -- 170
	if len < 0.00001 then -- 171
		return {x = 0, y = 1, z = 0} -- 172
	end -- 172
	return {x = v.x / len, y = v.y / len, z = v.z / len} -- 174
end -- 169
local function dot3(a, b) -- 177
	return a.x * b.x + a.y * b.y + a.z * b.z -- 178
end -- 177
local function cross3(a, b) -- 181
	return {x = a.y * b.z - a.z * b.y, y = a.z * b.x - a.x * b.z, z = a.x * b.y - a.y * b.x} -- 182
end -- 181
local function sub3(a, b) -- 189
	return {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z} -- 190
end -- 189
local function clampByte(v) -- 193
	return math.max( -- 194
		0, -- 194
		math.min( -- 194
			255, -- 194
			math.floor(v + 0.5) -- 194
		) -- 194
	) -- 194
end -- 193
local function scaleRGBA(c, k, alphaMul) -- 197
	if alphaMul == nil then -- 197
		alphaMul = 1 -- 197
	end -- 197
	return { -- 198
		r = clampByte(c.r * k), -- 199
		g = clampByte(c.g * k), -- 200
		b = clampByte(c.b * k), -- 201
		a = clampByte(c.a * alphaMul) -- 202
	} -- 202
end -- 197
--- 明初温州宁村所海防卫城低模材质预设（高灰度区分度、去刺眼白线框 CAD 观感、禁现代/仙侠荧光）
____exports.MING_MATERIALS = { -- 207
	mingBrick = { -- 208
		base = rgba(88, 95, 108, 255), -- 209
		edge = rgba(128, 138, 152, 72), -- 210
		minShade = 0.3, -- 211
		rimBoost = 0.24, -- 212
		bottomAo = 0.3 -- 213
	}, -- 213
	mingBrickDark = { -- 215
		base = rgba(46, 53, 66, 255), -- 216
		edge = rgba(88, 98, 114, 58), -- 217
		minShade = 0.24, -- 218
		rimBoost = 0.18, -- 219
		bottomAo = 0.36 -- 220
	}, -- 220
	mingTimber = { -- 222
		base = rgba(108, 78, 56, 255), -- 223
		edge = rgba(146, 114, 86, 78), -- 224
		minShade = 0.26, -- 225
		rimBoost = 0.22, -- 226
		bottomAo = 0.32 -- 227
	}, -- 227
	mingTimberDark = { -- 229
		base = rgba(60, 44, 33, 255), -- 230
		edge = rgba(102, 78, 60, 66), -- 231
		minShade = 0.2, -- 232
		rimBoost = 0.16, -- 233
		bottomAo = 0.38 -- 234
	}, -- 234
	mingStoneStep = { -- 236
		base = rgba(108, 114, 124, 255), -- 237
		edge = rgba(168, 178, 190, 96), -- 238
		minShade = 0.28, -- 239
		rimBoost = 0.26, -- 240
		bottomAo = 0.26 -- 241
	}, -- 241
	mingIron = { -- 243
		base = rgba(44, 50, 60, 255), -- 244
		edge = rgba(122, 132, 146, 86), -- 245
		minShade = 0.22, -- 246
		rimBoost = 0.28, -- 247
		bottomAo = 0.25 -- 248
	}, -- 248
	mingTile = { -- 250
		base = rgba(40, 48, 62, 255), -- 251
		edge = rgba(88, 102, 122, 64), -- 252
		minShade = 0.24, -- 253
		rimBoost = 0.18, -- 254
		bottomAo = 0.26 -- 255
	}, -- 255
	mingRedCloth = { -- 257
		base = rgba(176, 52, 48, 255), -- 258
		edge = rgba(218, 108, 94, 128), -- 259
		minShade = 0.36, -- 260
		rimBoost = 0.24, -- 261
		bottomAo = 0.18 -- 262
	}, -- 262
	distantWall = { -- 264
		base = rgba(38, 48, 64, 255), -- 265
		edge = rgba(82, 98, 118, 48), -- 266
		minShade = 0.35, -- 267
		rimBoost = 0.14, -- 268
		bottomAo = 0.22 -- 269
	}, -- 269
	distantHill = { -- 271
		base = rgba(24, 34, 50, 255), -- 272
		edge = rgba(64, 82, 106, 38), -- 273
		minShade = 0.38, -- 274
		rimBoost = 0.12, -- 275
		bottomAo = 0.2 -- 276
	} -- 276
} -- 276
--- 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光）
____exports.GATE_NIGHTMARE_LIGHT = { -- 281
	keyDir = ____exports.normalize3(____exports.vec3(-0.62, 0.64, -0.45)), -- 282
	keyColor = rgba(206, 224, 240, 255), -- 283
	keyStrength = 0.88, -- 284
	rimDir = ____exports.normalize3(____exports.vec3(0.76, 0.36, -0.54)), -- 285
	rimColor = rgba(224, 196, 150, 255), -- 286
	rimStrength = 0.34, -- 287
	ambientColor = rgba(26, 34, 48, 255), -- 288
	fogColor = rgba(26, 36, 52, 255), -- 289
	fogStartZ = 36, -- 290
	fogEndZ = 560, -- 291
	fogMaxAlpha = 0.84, -- 292
	shadowContrast = 0.72 -- 293
} -- 293
____exports.OUTSIDE_JETTY_LIGHT = { -- 296
	keyDir = ____exports.normalize3(____exports.vec3(-0.56, 0.68, -0.48)), -- 297
	keyColor = rgba(196, 214, 232, 255), -- 298
	keyStrength = 0.86, -- 299
	rimDir = ____exports.normalize3(____exports.vec3(0.78, 0.32, -0.54)), -- 300
	rimColor = rgba(226, 188, 136, 255), -- 301
	rimStrength = 0.32, -- 302
	ambientColor = rgba(24, 32, 46, 255), -- 303
	fogColor = rgba(24, 34, 50, 255), -- 304
	fogStartZ = 42, -- 305
	fogEndZ = 520, -- 306
	fogMaxAlpha = 0.8, -- 307
	shadowContrast = 0.74 -- 308
} -- 308
____exports.VILLAGE_UNDERTABLE_LIGHT = { -- 311
	keyDir = ____exports.normalize3(____exports.vec3(0.72, 0.44, -0.54)), -- 312
	keyColor = rgba(214, 208, 194, 255), -- 313
	keyStrength = 0.92, -- 314
	rimDir = ____exports.normalize3(____exports.vec3(-0.64, 0.52, -0.56)), -- 315
	rimColor = rgba(146, 166, 186, 255), -- 316
	rimStrength = 0.28, -- 317
	ambientColor = rgba(18, 22, 30, 255), -- 318
	fogColor = rgba(22, 26, 34, 255), -- 319
	fogStartZ = 55, -- 320
	fogEndZ = 460, -- 321
	fogMaxAlpha = 0.78, -- 322
	shadowContrast = 0.82 -- 323
} -- 323
____exports.FOREST_CREEK_LIGHT = { -- 326
	keyDir = ____exports.normalize3(____exports.vec3(-0.48, 0.74, -0.47)), -- 327
	keyColor = rgba(178, 206, 202, 255), -- 328
	keyStrength = 0.8, -- 329
	rimDir = ____exports.normalize3(____exports.vec3(0.82, 0.28, -0.5)), -- 330
	rimColor = rgba(232, 196, 132, 255), -- 331
	rimStrength = 0.36, -- 332
	ambientColor = rgba(18, 30, 34, 255), -- 333
	fogColor = rgba(20, 34, 38, 255), -- 334
	fogStartZ = 34, -- 335
	fogEndZ = 480, -- 336
	fogMaxAlpha = 0.86, -- 337
	shadowContrast = 0.76 -- 338
} -- 338
____exports.TOWER_WEST_LAMP_LIGHT = { -- 341
	keyDir = ____exports.normalize3(____exports.vec3(-0.74, 0.48, -0.47)), -- 342
	keyColor = rgba(242, 202, 138, 255), -- 343
	keyStrength = 0.94, -- 344
	rimDir = ____exports.normalize3(____exports.vec3(0.62, 0.54, -0.57)), -- 345
	rimColor = rgba(142, 168, 198, 255), -- 346
	rimStrength = 0.26, -- 347
	ambientColor = rgba(24, 26, 36, 255), -- 348
	fogColor = rgba(24, 28, 40, 255), -- 349
	fogStartZ = 60, -- 350
	fogEndZ = 480, -- 351
	fogMaxAlpha = 0.72, -- 352
	shadowContrast = 0.7 -- 353
} -- 353
--- 核心 2.5D 低模投影：
-- 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
function ____exports.projectWorld3D(wx, wy, wz, cam, proj) -- 360
	local bx = cam:sx(wx) -- 367
	local by = cam:sy(wy, proj.baseDepth or 0) -- 368
	local m = ____exports.clamp01(proj.morph) -- 369
	if m <= 0.00001 or math.abs(wz) <= 0.00001 then -- 370
		return {x = bx, y = by, scale = 1, zEff = 0} -- 371
	end -- 371
	local focal = math.max(60, proj.focal) -- 373
	local zEff = wz * m -- 374
	local denom = math.max(focal * 0.22, focal + zEff) -- 375
	local s = focal / denom -- 376
	local vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX or 0) -- 377
	local vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY or 0) -- 378
	return {x = vpX + (bx - vpX) * s, y = vpY + (by - vpY) * s, scale = s, zEff = zEff} -- 379
end -- 360
--- 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
-- 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
function ____exports.verifyWalkPlaneAlignment(cam, proj, wx, wy) -- 391
	local p3 = ____exports.projectWorld3D( -- 397
		wx, -- 397
		wy, -- 397
		0, -- 397
		cam, -- 397
		proj -- 397
	) -- 397
	local p2 = cam:worldToScreen(wx, wy, proj.baseDepth or 0) -- 398
	local fwdDx = p3.x - p2.x -- 399
	local fwdDy = p3.y - p2.y -- 400
	local forwardErrPx = math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy) -- 401
	local inv = cam:screenToWorld(p3.x, p3.y) -- 403
	local invDx = inv.x - wx -- 404
	local invDy = inv.y - (wy + (proj.baseDepth or 0) * DEPTH_Y_SCALE) -- 405
	local inverseErrWorld = math.sqrt(invDx * invDx + invDy * invDy) -- 406
	return {forwardErrPx = forwardErrPx, inverseErrWorld = inverseErrWorld, screenX = p3.x, screenY = p3.y} -- 407
end -- 391
--- 计算给定法线与深度的低模平面受光+雾效颜色
function ____exports.shadeSurface(base, normal, avgZ, morph, light, mat, opacityMul) -- 416
	if opacityMul == nil then -- 423
		opacityMul = 1 -- 423
	end -- 423
	local m = ____exports.clamp01(morph) -- 425
	local n = ____exports.normalize3(normal) -- 426
	local ndl = math.max( -- 427
		0, -- 427
		dot3(n, light.keyDir) -- 427
	) -- 427
	local ndr = math.max( -- 428
		0, -- 428
		dot3(n, light.rimDir) -- 428
	) -- 428
	local minShade = mat and mat.minShade or 0.28 -- 429
	local rimBoost = mat and mat.rimBoost or 0.2 -- 430
	local contrast = light.shadowContrast * (0.45 + 0.55 * m) -- 431
	local keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25) -- 433
	local rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost) -- 434
	local rLit = base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255) + light.ambientColor.r * (0.28 * (1 - ndl * 0.5)) + light.rimColor.r * rimFactor * 0.45 -- 436
	local gLit = base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255) + light.ambientColor.g * (0.28 * (1 - ndl * 0.5)) + light.rimColor.g * rimFactor * 0.45 -- 439
	local bLit = base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255) + light.ambientColor.b * (0.28 * (1 - ndl * 0.5)) + light.rimColor.b * rimFactor * 0.45 -- 442
	local lit = { -- 446
		r = clampByte(rLit), -- 447
		g = clampByte(gLit), -- 448
		b = clampByte(bLit), -- 449
		a = clampByte(base.a * ____exports.clamp01(opacityMul)) -- 450
	} -- 450
	if avgZ > light.fogStartZ and m > 0.01 then -- 453
		local span = math.max(1, light.fogEndZ - light.fogStartZ) -- 454
		local fogT = ____exports.clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m -- 455
		local mixed = lerpRGBA(lit, light.fogColor, fogT) -- 456
		mixed.a = lit.a -- 457
		return mixed -- 458
	end -- 458
	return lit -- 460
end -- 416
--- 画家算法低模场景批处理器：
-- 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
____exports.LowpolyScene = __TS__Class() -- 467
local LowpolyScene = ____exports.LowpolyScene -- 467
LowpolyScene.name = "LowpolyScene" -- 467
function LowpolyScene.prototype.____constructor(self, cam, proj, light) -- 474
	if light == nil then -- 474
		light = ____exports.GATE_NIGHTMARE_LIGHT -- 474
	end -- 474
	self.faces = {} -- 471
	self.glows = {} -- 472
	self.cam = cam -- 475
	self.proj = proj -- 476
	self.light = light -- 477
end -- 474
function LowpolyScene.prototype.getFaceCount(self) -- 480
	return #self.faces -- 481
end -- 480
function LowpolyScene.prototype.project(self, wx, wy, wz) -- 484
	return ____exports.projectWorld3D( -- 485
		wx, -- 485
		wy, -- 485
		wz, -- 485
		self.cam, -- 485
		self.proj -- 485
	) -- 485
end -- 484
function LowpolyScene.prototype.vanishingPointScreen(self) -- 488
	return {x = self.cam.viewW * self.proj.vpFracX + (self.proj.vpOffsetX or 0), y = self.cam.viewH * self.proj.vpFracY + (self.proj.vpOffsetY or 0)} -- 489
end -- 488
function LowpolyScene.prototype.addQuad3D(self, v0, v1, v2, v3, mat, opts) -- 496
	if opts == nil then -- 502
		opts = {} -- 502
	end -- 502
	local opacity = opts.opacity or 1 -- 504
	if opacity <= 0.01 then -- 505
		return -- 506
	end -- 506
	local p0 = self:project(v0.x, v0.y, v0.z) -- 508
	local p1 = self:project(v1.x, v1.y, v1.z) -- 509
	local p2 = self:project(v2.x, v2.y, v2.z) -- 510
	local p3 = self:project(v3.x, v3.y, v3.z) -- 511
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y)) -- 514
	if area2 < 0.25 then -- 518
		return -- 519
	end -- 519
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z + v3.z) * 0.25 -- 522
	local topRgba -- 523
	if opts.unlit == true then -- 524
		topRgba = scaleRGBA(mat.base, 1, opacity) -- 525
	else -- 525
		local n = cross3( -- 527
			sub3(v1, v0), -- 527
			sub3(v3, v0) -- 527
		) -- 527
		topRgba = ____exports.shadeSurface( -- 528
			mat.base, -- 528
			n, -- 528
			avgZ, -- 528
			self.proj.morph, -- 528
			self.light, -- 528
			mat, -- 528
			opacity -- 528
		) -- 528
	end -- 528
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.22) -- 531
	local botRgba = ao > 0.005 and scaleRGBA( -- 532
		topRgba, -- 532
		math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)), -- 532
		1 -- 532
	) or topRgba -- 532
	local cBot = toColor(botRgba) -- 533
	local cTop = toColor(topRgba) -- 534
	local edgeRgba = opts.edgeColor or mat.edge -- 536
	local edgeW = opts.edgeWidth or 0 -- 537
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 538
		edgeRgba, -- 539
		math.floor(edgeRgba.a * opacity + 0.5) -- 539
	) or nil -- 540
	local ____self_faces_4 = self.faces -- 542
	____self_faces_4[#____self_faces_4 + 1] = { -- 542
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 543
		sortZ = avgZ, -- 544
		sortBias = opts.sortBias or 0, -- 545
		pts = {p0, p1, p2, p3}, -- 546
		cols = {cBot, cBot, cTop, cTop}, -- 547
		edgeCol = edgeCol, -- 548
		edgeWidth = edgeW, -- 549
		topHighlight = nil -- 550
	} -- 550
end -- 496
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 555
	if opts == nil then -- 560
		opts = {} -- 560
	end -- 560
	local opacity = opts.opacity or 1 -- 562
	if opacity <= 0.01 then -- 563
		return -- 564
	end -- 564
	local p0 = self:project(v0.x, v0.y, v0.z) -- 566
	local p1 = self:project(v1.x, v1.y, v1.z) -- 567
	local p2 = self:project(v2.x, v2.y, v2.z) -- 568
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 570
	if area2 < 0.25 then -- 571
		return -- 572
	end -- 572
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 575
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 576
		mat.base, -- 578
		cross3( -- 578
			sub3(v1, v0), -- 578
			sub3(v2, v0) -- 578
		), -- 578
		avgZ, -- 578
		self.proj.morph, -- 578
		self.light, -- 578
		mat, -- 578
		opacity -- 578
	) -- 578
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 579
	local botRgba = ao > 0.005 and scaleRGBA( -- 580
		colRgba, -- 580
		math.max(0.4, 1 - ao), -- 580
		1 -- 580
	) or colRgba -- 580
	local edgeRgba = opts.edgeColor or mat.edge -- 582
	local edgeW = opts.edgeWidth or 0 -- 583
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 584
		edgeRgba, -- 585
		math.floor(edgeRgba.a * opacity + 0.5) -- 585
	) or nil -- 586
	local ____self_faces_5 = self.faces -- 588
	____self_faces_5[#____self_faces_5 + 1] = { -- 588
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 589
		sortZ = avgZ, -- 590
		sortBias = opts.sortBias or 0, -- 591
		pts = {p0, p1, p2}, -- 592
		cols = { -- 593
			toColor(botRgba), -- 593
			toColor(botRgba), -- 593
			toColor(colRgba) -- 593
		}, -- 593
		edgeCol = edgeCol, -- 594
		edgeWidth = edgeW, -- 595
		topHighlight = nil -- 596
	} -- 596
end -- 555
function LowpolyScene.prototype.addBox(self, spec) -- 604
	local opacity = spec.opacity or 1 -- 605
	if opacity <= 0.01 then -- 606
		return -- 607
	end -- 607
	local x0 = math.min(spec.x0, spec.x1) -- 609
	local x1 = math.max(spec.x0, spec.x1) -- 610
	local y0 = math.min(spec.y0, spec.y1) -- 611
	local y1 = math.max(spec.y0, spec.y1) -- 612
	local z0 = math.min(spec.z0, spec.z1) -- 613
	local z1 = math.max(spec.z0, spec.z1) -- 614
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 616
	local bias = spec.sortBias or 0 -- 617
	local edgeW = spec.edgeWidth or 0.85 -- 618
	local midZ = (z0 + z1) * 0.5 -- 619
	local vp = self:vanishingPointScreen() -- 620
	local m = ____exports.clamp01(self.proj.morph) -- 621
	local sx0 = self.cam:sx(x0) -- 623
	local sx1 = self.cam:sx(x1) -- 624
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 625
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 626
	if m > 0.002 and z1 - z0 > 0.05 then -- 628
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 630
			self:addQuad3D( -- 631
				____exports.vec3(x0, y0, z1), -- 632
				____exports.vec3(x0, y0, z0), -- 633
				____exports.vec3(x0, y1, z0), -- 634
				____exports.vec3(x0, y1, z1), -- 635
				spec.material, -- 636
				{ -- 637
					bucket = bucket, -- 637
					sortZOverride = midZ + 0.4, -- 637
					sortBias = bias - 0.1, -- 637
					opacity = opacity, -- 637
					edgeWidth = edgeW -- 637
				} -- 637
			) -- 637
		end -- 637
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 641
			self:addQuad3D( -- 642
				____exports.vec3(x1, y0, z0), -- 643
				____exports.vec3(x1, y0, z1), -- 644
				____exports.vec3(x1, y1, z1), -- 645
				____exports.vec3(x1, y1, z0), -- 646
				spec.material, -- 647
				{ -- 648
					bucket = bucket, -- 648
					sortZOverride = midZ + 0.4, -- 648
					sortBias = bias - 0.1, -- 648
					opacity = opacity, -- 648
					edgeWidth = edgeW -- 648
				} -- 648
			) -- 648
		end -- 648
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 652
			self:addQuad3D( -- 653
				____exports.vec3(x0, y1, z0), -- 654
				____exports.vec3(x1, y1, z0), -- 655
				____exports.vec3(x1, y1, z1), -- 656
				____exports.vec3(x0, y1, z1), -- 657
				spec.material, -- 658
				{ -- 659
					bucket = bucket, -- 659
					sortZOverride = midZ + 0.2, -- 659
					sortBias = bias - 0.05, -- 659
					opacity = opacity, -- 659
					edgeWidth = edgeW, -- 659
					bottomAo = 0.08 -- 659
				} -- 659
			) -- 659
		end -- 659
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 663
			self:addQuad3D( -- 664
				____exports.vec3(x0, y0, z1), -- 665
				____exports.vec3(x1, y0, z1), -- 666
				____exports.vec3(x1, y0, z0), -- 667
				____exports.vec3(x0, y0, z0), -- 668
				spec.material, -- 669
				{ -- 670
					bucket = bucket, -- 670
					sortZOverride = midZ + 0.2, -- 670
					sortBias = bias - 0.05, -- 670
					opacity = opacity, -- 670
					edgeWidth = edgeW, -- 670
					bottomAo = 0.34 -- 670
				} -- 670
			) -- 670
		end -- 670
	end -- 670
	if spec.skipFront ~= true then -- 676
		local beforeLen = #self.faces -- 677
		self:addQuad3D( -- 678
			____exports.vec3(x0, y0, z0), -- 679
			____exports.vec3(x1, y0, z0), -- 680
			____exports.vec3(x1, y1, z0), -- 681
			____exports.vec3(x0, y1, z0), -- 682
			spec.material, -- 683
			{ -- 684
				bucket = bucket, -- 684
				sortZOverride = z0, -- 684
				sortBias = bias, -- 684
				opacity = opacity, -- 684
				edgeWidth = edgeW -- 684
			} -- 684
		) -- 684
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 686
			local face = self.faces[#self.faces] -- 687
			local rimCol = spec.material.edge or rgba(198, 206, 214, 180) -- 688
			face.topHighlight = { -- 689
				face.pts[4], -- 690
				face.pts[3], -- 691
				toColor( -- 692
					rimCol, -- 692
					math.floor(math.min(245, rimCol.a * 1.15) * opacity + 0.5) -- 692
				) -- 692
			} -- 692
		end -- 692
	end -- 692
end -- 604
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 702
	if opts == nil then -- 712
		opts = {} -- 712
	end -- 712
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 720
	local opacity = opts.opacity or 1 -- 721
	local bias = opts.sortBias or 0 -- 722
	self:addBox({ -- 725
		x0 = openX0 - pillarW, -- 726
		x1 = openX0, -- 727
		y0 = y0, -- 728
		y1 = openY1 + lintelH, -- 729
		z0 = z0, -- 730
		z1 = z1, -- 731
		material = mat, -- 732
		bucket = bucket, -- 733
		sortBias = bias, -- 734
		opacity = opacity, -- 735
		highlightTopEdge = true -- 736
	}) -- 736
	self:addBox({ -- 739
		x0 = openX1, -- 740
		x1 = openX1 + pillarW, -- 741
		y0 = y0, -- 742
		y1 = openY1 + lintelH, -- 743
		z0 = z0, -- 744
		z1 = z1, -- 745
		material = mat, -- 746
		bucket = bucket, -- 747
		sortBias = bias, -- 748
		opacity = opacity, -- 749
		highlightTopEdge = true -- 750
	}) -- 750
	self:addBox({ -- 753
		x0 = openX0 - pillarW * 0.2, -- 754
		x1 = openX1 + pillarW * 0.2, -- 755
		y0 = openY1, -- 756
		y1 = openY1 + lintelH, -- 757
		z0 = z0, -- 758
		z1 = z1, -- 759
		material = mat, -- 760
		bucket = bucket, -- 761
		sortBias = bias + 0.05, -- 762
		opacity = opacity, -- 763
		highlightTopEdge = true -- 764
	}) -- 764
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 768
	if rimAlpha > 0.02 then -- 769
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 770
		local p0 = self:project(openX0, y0 + 2, z0) -- 771
		local p1 = self:project(openX0, y0 + 2, z1) -- 772
		local p2 = self:project(openX0, openY1 - 2, z1) -- 773
		local p3 = self:project(openX0, openY1 - 2, z0) -- 774
		local cNear = toColor( -- 775
			rimCol, -- 775
			math.floor(135 * rimAlpha + 0.5) -- 775
		) -- 775
		local cFar = toColor( -- 776
			rimCol, -- 776
			math.floor(28 * rimAlpha + 0.5) -- 776
		) -- 776
		local ____self_glows_6 = self.glows -- 777
		____self_glows_6[#____self_glows_6 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 777
	end -- 777
end -- 702
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 785
	if mat == nil then -- 789
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 789
	end -- 789
	if opts == nil then -- 790
		opts = {} -- 790
	end -- 790
	local n = math.max(1, stair.steps + 1) -- 792
	local stepW = (stair.x1 - stair.x0) / n -- 793
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 794
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 795
	local opacity = opts.opacity or 1 -- 796
	local bias = opts.sortBias or 0 -- 797
	local k = 0 -- 799
	do -- 799
		k = 0 -- 800
		while k < n do -- 800
			do -- 800
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 801
				local wx0 = stair.x0 + stepW * k -- 802
				local wx1 = wx0 + stepW -- 803
				if wy <= floorY + 1 then -- 804
					goto __continue43 -- 805
				end -- 805
				self:addBox({ -- 807
					x0 = wx0, -- 808
					x1 = wx1, -- 809
					y0 = floorY, -- 810
					y1 = wy, -- 811
					z0 = z0, -- 812
					z1 = z1, -- 813
					material = mat, -- 814
					bucket = bucket, -- 815
					sortBias = bias + k * 0.01, -- 816
					opacity = opacity, -- 817
					highlightTopEdge = true, -- 818
					edgeWidth = 0.9 -- 819
				}) -- 819
			end -- 819
			::__continue43:: -- 819
			k = k + 1 -- 800
		end -- 800
	end -- 800
end -- 785
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 828
	if mat == nil then -- 836
		mat = ____exports.MING_MATERIALS.mingTimber -- 836
	end -- 836
	if opts == nil then -- 837
		opts = {} -- 837
	end -- 837
	local count = math.max( -- 845
		1, -- 845
		math.floor(plankCount) -- 845
	) -- 845
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 846
	local opacity = opts.opacity or 1 -- 847
	local bias = opts.sortBias or 0 -- 848
	local spanZ = math.max(1, z1 - z0) -- 849
	local gap = math.min(2.6, spanZ / (count * 6)) -- 850
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 851
	if opts.withPosts == true then -- 854
		local postBot = opts.postBottomY or topY - 92 -- 855
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 856
		local postCount = math.max( -- 857
			2, -- 857
			math.min( -- 857
				5, -- 857
				math.floor((x1 - x0) / 110) + 1 -- 857
			) -- 857
		) -- 857
		local pi = 0 -- 858
		do -- 858
			pi = 0 -- 859
			while pi < postCount do -- 859
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 860
				self:addBox({ -- 861
					x0 = px - 6, -- 862
					x1 = px + 6, -- 863
					y0 = postBot, -- 864
					y1 = topY - thickness, -- 865
					z0 = z0 + 4, -- 866
					z1 = z0 + 18, -- 867
					material = postMat, -- 868
					bucket = bucket, -- 869
					sortBias = bias - 0.3, -- 870
					opacity = opacity, -- 871
					edgeWidth = 0.7 -- 872
				}) -- 872
				pi = pi + 1 -- 859
			end -- 859
		end -- 859
	end -- 859
	local i = 0 -- 878
	do -- 878
		i = 0 -- 879
		while i < count do -- 879
			local pz0 = z0 + i * (plankDepth + gap) -- 880
			local pz1 = pz0 + plankDepth -- 881
			local plankMat = i & 1 == 0 and mat or ({ -- 882
				base = scaleRGBA(mat.base, 0.88), -- 885
				edge = mat.edge, -- 886
				minShade = mat.minShade, -- 887
				rimBoost = mat.rimBoost, -- 888
				bottomAo = mat.bottomAo -- 889
			}) -- 889
			self:addBox({ -- 891
				x0 = x0, -- 892
				x1 = x1, -- 893
				y0 = topY - thickness, -- 894
				y1 = topY, -- 895
				z0 = pz0, -- 896
				z1 = pz1, -- 897
				material = plankMat, -- 898
				bucket = bucket, -- 899
				sortBias = bias + (count - i) * 0.01, -- 900
				opacity = opacity, -- 901
				highlightTopEdge = i == 0, -- 902
				edgeWidth = 0.8 -- 903
			}) -- 903
			i = i + 1 -- 879
		end -- 879
	end -- 879
end -- 828
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 909
	if mat == nil then -- 913
		mat = ____exports.MING_MATERIALS.distantHill -- 913
	end -- 913
	if opts == nil then -- 914
		opts = {} -- 914
	end -- 914
	if #peaks < 2 then -- 916
		return -- 917
	end -- 917
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 919
	local opacity = opts.opacity or 1 -- 920
	local bias = opts.sortBias or 0 -- 921
	local i = 0 -- 923
	do -- 923
		i = 0 -- 924
		while i < #peaks - 1 do -- 924
			local a = peaks[i + 1] -- 925
			local b = peaks[i + 1 + 1] -- 926
			local midX = (a.x + b.x) * 0.5 -- 927
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 928
			local ridgeMat = b.y >= a.y and mat or ({ -- 929
				base = scaleRGBA(mat.base, 0.84), -- 932
				edge = mat.edge, -- 933
				minShade = mat.minShade, -- 934
				rimBoost = mat.rimBoost, -- 935
				bottomAo = mat.bottomAo -- 936
			}) -- 936
			self:addTri3D( -- 938
				____exports.vec3(a.x, baseY, z), -- 939
				____exports.vec3(b.x, baseY, z), -- 940
				____exports.vec3(a.x, a.y, z), -- 941
				ridgeMat, -- 942
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 943
			) -- 943
			self:addTri3D( -- 945
				____exports.vec3(b.x, baseY, z), -- 946
				____exports.vec3(b.x, b.y, z), -- 947
				____exports.vec3(a.x, a.y, z), -- 948
				ridgeMat, -- 949
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 950
			) -- 950
			self:addTri3D( -- 953
				____exports.vec3( -- 954
					midX, -- 954
					math.max(baseY, midY), -- 954
					z - 8 -- 954
				), -- 954
				____exports.vec3(b.x, baseY, z), -- 955
				____exports.vec3(b.x, b.y, z), -- 956
				{ -- 957
					base = scaleRGBA(mat.base, 0.78), -- 957
					minShade = 0.3, -- 957
					bottomAo = 0.2 -- 957
				}, -- 957
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 958
			) -- 958
			i = i + 1 -- 924
		end -- 924
	end -- 924
end -- 909
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 964
	if opts == nil then -- 973
		opts = {} -- 973
	end -- 973
	local m = ____exports.clamp01(self.proj.morph) -- 975
	local ba = ____exports.clamp01(bottomAlpha * m) -- 976
	local ta = ____exports.clamp01(topAlpha * m) -- 977
	if ba <= 0.008 and ta <= 0.008 then -- 978
		return -- 979
	end -- 979
	local p0 = self:project(x0, y0, z) -- 981
	local p1 = self:project(x1, y0, z) -- 982
	local p2 = self:project(x1, y1, z) -- 983
	local p3 = self:project(x0, y1, z) -- 984
	local cBot = toColor( -- 985
		color, -- 985
		math.floor(255 * ba + 0.5) -- 985
	) -- 985
	local cTop = toColor( -- 986
		color, -- 986
		math.floor(255 * ta + 0.5) -- 986
	) -- 986
	local ____self_faces_7 = self.faces -- 987
	____self_faces_7[#____self_faces_7 + 1] = { -- 987
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 988
		sortZ = z, -- 989
		sortBias = opts.sortBias or 0.5, -- 990
		pts = {p0, p1, p2, p3}, -- 991
		cols = {cBot, cBot, cTop, cTop}, -- 992
		edgeCol = nil, -- 993
		edgeWidth = 0, -- 994
		topHighlight = nil -- 995
	} -- 995
end -- 964
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 1000
	local ta = ____exports.clamp01(topAlpha) -- 1012
	local ba = ____exports.clamp01(botAlpha) -- 1013
	if ta <= 0.005 and ba <= 0.005 then -- 1014
		return -- 1015
	end -- 1015
	local p0 = self:project(botX0, botY, z) -- 1017
	local p1 = self:project(botX1, botY, z) -- 1018
	local p2 = self:project(topX1, topY, z) -- 1019
	local p3 = self:project(topX0, topY, z) -- 1020
	local cTop = toColor( -- 1021
		color, -- 1021
		math.floor(255 * ta + 0.5) -- 1021
	) -- 1021
	local cBot = toColor( -- 1022
		color, -- 1022
		math.floor(255 * ba + 0.5) -- 1022
	) -- 1022
	local ____self_glows_8 = self.glows -- 1023
	____self_glows_8[#____self_glows_8 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1023
end -- 1000
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1033
	if opacity == nil then -- 1038
		opacity = 0.72 -- 1038
	end -- 1038
	if opts == nil then -- 1039
		opts = {} -- 1039
	end -- 1039
	local op = ____exports.clamp01(opacity) -- 1041
	if op <= 0.01 then -- 1042
		return -- 1043
	end -- 1043
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1045
	local bias = opts.sortBias or 0.2 -- 1046
	local m = ____exports.clamp01(self.proj.morph) -- 1047
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1048
	local segs = 10 -- 1051
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1052
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1053
	local innerCol = Color( -- 1054
		7, -- 1054
		9, -- 1054
		14, -- 1054
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1054
	) -- 1054
	local outerCol = Color(7, 9, 14, 0) -- 1055
	local i = 0 -- 1056
	do -- 1056
		i = 0 -- 1057
		while i < segs do -- 1057
			local a0 = i / segs * math.pi * 2 -- 1058
			local a1 = (i + 1) / segs * math.pi * 2 -- 1059
			local pA = self:project( -- 1060
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1061
				wy + 0.4, -- 1062
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1063
			) -- 1063
			local pB = self:project( -- 1065
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1066
				wy + 0.4, -- 1067
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1068
			) -- 1068
			local ____self_faces_9 = self.faces -- 1070
			____self_faces_9[#____self_faces_9 + 1] = { -- 1070
				bucket = bucket, -- 1071
				sortZ = 0.05, -- 1072
				sortBias = bias, -- 1073
				pts = {centerP, pA, pB}, -- 1074
				cols = {innerCol, outerCol, outerCol}, -- 1075
				edgeCol = nil, -- 1076
				edgeWidth = 0, -- 1077
				topHighlight = nil -- 1078
			} -- 1078
			i = i + 1 -- 1057
		end -- 1057
	end -- 1057
	local footP = self:project(wx, wy + 0.5, 0) -- 1083
	local coreRx = self.cam:len(radiusX * 0.78) -- 1084
	local coreRy = math.max( -- 1085
		2.5, -- 1085
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1085
	) -- 1085
	local coreIn = Color( -- 1086
		5, -- 1086
		7, -- 1086
		12, -- 1086
		math.floor(210 * op + 0.5) -- 1086
	) -- 1086
	local coreOut = Color( -- 1087
		5, -- 1087
		7, -- 1087
		12, -- 1087
		math.floor(32 * op + 0.5) -- 1087
	) -- 1087
	local coreSegs = 8 -- 1088
	do -- 1088
		i = 0 -- 1089
		while i < coreSegs do -- 1089
			local a0 = i / coreSegs * math.pi * 2 -- 1090
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1091
			local ____self_faces_10 = self.faces -- 1092
			____self_faces_10[#____self_faces_10 + 1] = { -- 1092
				bucket = bucket, -- 1093
				sortZ = 0.01, -- 1094
				sortBias = bias + 0.05, -- 1095
				pts = { -- 1096
					footP, -- 1097
					{ -- 1098
						x = footP.x + math.cos(a0) * coreRx, -- 1098
						y = footP.y + math.sin(a0) * coreRy, -- 1098
						scale = 1, -- 1098
						zEff = 0 -- 1098
					}, -- 1098
					{ -- 1099
						x = footP.x + math.cos(a1) * coreRx, -- 1099
						y = footP.y + math.sin(a1) * coreRy, -- 1099
						scale = 1, -- 1099
						zEff = 0 -- 1099
					} -- 1099
				}, -- 1099
				cols = {coreIn, coreOut, coreOut}, -- 1101
				edgeCol = nil, -- 1102
				edgeWidth = 0, -- 1103
				topHighlight = nil -- 1104
			} -- 1104
			i = i + 1 -- 1089
		end -- 1089
	end -- 1089
end -- 1033
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1113
	if opts == nil then -- 1122
		opts = {} -- 1122
	end -- 1122
	local pBL = self:project(x0, y0, wz) -- 1124
	local pTR = self:project(x1, y1, wz) -- 1125
	local w = math.abs(pTR.x - pBL.x) -- 1126
	local h = math.abs(pTR.y - pBL.y) -- 1127
	if w < 1 or h < 1 then -- 1128
		return false -- 1129
	end -- 1129
	return worldArt:tryPlace( -- 1131
		slotKey, -- 1132
		instanceKey, -- 1133
		(pBL.x + pTR.x) * 0.5, -- 1134
		math.min(pBL.y, pTR.y), -- 1135
		w, -- 1136
		h, -- 1137
		{ -- 1138
			color = opts.color or Color(28, 32, 42, 255), -- 1139
			opacity = opts.opacity or 0.92, -- 1140
			layer = opts.layer or 5200 -- 1141
		} -- 1141
	) -- 1141
end -- 1113
function LowpolyScene.prototype.flush(self, draw, glowDraw) -- 1147
	if #self.faces > 1 then -- 1148
		__TS__ArraySort( -- 1149
			self.faces, -- 1149
			function(____, a, b) -- 1149
				if a.bucket ~= b.bucket then -- 1150
					return a.bucket - b.bucket -- 1151
				end -- 1151
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1153
					return b.sortZ - a.sortZ -- 1154
				end -- 1154
				return a.sortBias - b.sortBias -- 1156
			end -- 1149
		) -- 1149
	end -- 1149
	local i = 0 -- 1160
	do -- 1160
		i = 0 -- 1161
		while i < #self.faces do -- 1161
			local f = self.faces[i + 1] -- 1162
			if #f.pts == 3 then -- 1163
				draw:drawVertices({ -- 1164
					{ -- 1165
						Vec2(f.pts[1].x, f.pts[1].y), -- 1165
						f.cols[1] -- 1165
					}, -- 1165
					{ -- 1166
						Vec2(f.pts[2].x, f.pts[2].y), -- 1166
						f.cols[2] -- 1166
					}, -- 1166
					{ -- 1167
						Vec2(f.pts[3].x, f.pts[3].y), -- 1167
						f.cols[3] -- 1167
					} -- 1167
				}) -- 1167
			elseif #f.pts == 4 then -- 1169
				local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1170
				local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1171
				local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1172
				local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1173
				draw:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1174
				draw:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1179
			end -- 1179
			if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1185
				local count = #f.pts -- 1186
				local k = 0 -- 1187
				do -- 1187
					k = 0 -- 1188
					while k < count do -- 1188
						local a = f.pts[k + 1] -- 1189
						local b = f.pts[(k + 1) % count + 1] -- 1190
						draw:drawSegment( -- 1191
							Vec2(a.x, a.y), -- 1191
							Vec2(b.x, b.y), -- 1191
							f.edgeWidth * 0.5, -- 1191
							f.edgeCol -- 1191
						) -- 1191
						k = k + 1 -- 1188
					end -- 1188
				end -- 1188
			end -- 1188
			if f.topHighlight ~= nil then -- 1194
				local hl = f.topHighlight -- 1195
				draw:drawSegment( -- 1196
					Vec2(hl[1].x, hl[1].y), -- 1196
					Vec2(hl[2].x, hl[2].y), -- 1196
					1.15, -- 1196
					hl[3] -- 1196
				) -- 1196
			end -- 1196
			i = i + 1 -- 1161
		end -- 1161
	end -- 1161
	if glowDraw ~= nil and #self.glows > 0 then -- 1200
		do -- 1200
			i = 0 -- 1201
			while i < #self.glows do -- 1201
				local g = self.glows[i + 1] -- 1202
				if #g.pts == 4 then -- 1203
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1204
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1205
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1206
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1207
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1208
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1213
				end -- 1213
				i = i + 1 -- 1201
			end -- 1201
		end -- 1201
	end -- 1201
	self.faces = {} -- 1222
	self.glows = {} -- 1223
end -- 1147
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time, skipBackdrop) -- 1232
	if skipBackdrop == nil then -- 1239
		skipBackdrop = false -- 1239
	end -- 1239
	if not skipBackdrop then -- 1242
		scene:addDistantRidge( -- 1243
			{ -- 1244
				{x = room.minX - 180, y = 125}, -- 1245
				{x = room.minX + 120, y = 196}, -- 1246
				{x = room.minX + 420, y = 162}, -- 1247
				{x = room.minX + 760, y = 224}, -- 1248
				{x = room.maxX + 220, y = 150} -- 1249
			}, -- 1249
			-40, -- 1251
			420, -- 1252
			____exports.MING_MATERIALS.distantHill, -- 1253
			{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1254
		) -- 1254
		scene:addFogBand( -- 1256
			room.minX - 240, -- 1256
			room.maxX + 240, -- 1256
			-30, -- 1256
			175, -- 1256
			290, -- 1256
			scene.light.fogColor, -- 1256
			0.56, -- 1256
			0.04, -- 1256
			{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1256
		) -- 1256
	end -- 1256
	local i = 0 -- 1262
	do -- 1262
		i = 0 -- 1263
		while i < #room.floors do -- 1263
			local fl = room.floors[i + 1] -- 1264
			local isMain = fl.y <= 0.1 -- 1265
			if isMain then -- 1266
				scene:addBox({ -- 1267
					x0 = fl.x0, -- 1268
					x1 = fl.x1, -- 1269
					y0 = -48, -- 1270
					y1 = fl.y, -- 1271
					z0 = -26, -- 1272
					z1 = 88, -- 1273
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1274
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1275
					highlightTopEdge = true -- 1276
				}) -- 1276
			else -- 1276
				scene:addPlankDeck( -- 1280
					fl.x0, -- 1280
					fl.x1, -- 1280
					fl.y, -- 1280
					-24, -- 1280
					52, -- 1280
					5, -- 1280
					11, -- 1280
					____exports.MING_MATERIALS.mingTimber, -- 1280
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1280
				) -- 1280
			end -- 1280
			i = i + 1 -- 1263
		end -- 1263
	end -- 1263
	do -- 1263
		i = 0 -- 1289
		while i < #room.stairs do -- 1289
			scene:addStairFlight( -- 1290
				room.stairs[i + 1], -- 1290
				14, -- 1290
				76, -- 1290
				____exports.MING_MATERIALS.mingStoneStep, -- 1290
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1290
			) -- 1290
			i = i + 1 -- 1289
		end -- 1289
	end -- 1289
	do -- 1289
		i = 0 -- 1297
		while i < #room.solids do -- 1297
			do -- 1297
				local s = room.solids[i + 1] -- 1298
				if s.id == "outside_red_cart" then -- 1299
					goto __continue93 -- 1300
				end -- 1300
				scene:addBox({ -- 1302
					x0 = s.x, -- 1303
					x1 = s.x + s.w, -- 1304
					y0 = s.y, -- 1305
					y1 = s.y + s.h, -- 1306
					z0 = -8, -- 1307
					z1 = 72, -- 1308
					material = ____exports.MING_MATERIALS.mingBrick, -- 1309
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1310
					highlightTopEdge = true -- 1311
				}) -- 1311
				if s.y > 10 then -- 1313
					scene:addBox({ -- 1314
						x0 = s.x, -- 1315
						x1 = s.x + 18, -- 1316
						y0 = 0, -- 1317
						y1 = s.y, -- 1318
						z0 = 32, -- 1319
						z1 = 72, -- 1320
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1321
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1322
						sortBias = -0.08, -- 1323
						edgeWidth = 0.7 -- 1324
					}) -- 1324
					scene:addBox({ -- 1326
						x0 = s.x + s.w - 18, -- 1327
						x1 = s.x + s.w, -- 1328
						y0 = 0, -- 1329
						y1 = s.y, -- 1330
						z0 = 32, -- 1331
						z1 = 72, -- 1332
						material = ____exports.MING_MATERIALS.mingBrickDark, -- 1333
						bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1334
						sortBias = -0.08, -- 1335
						edgeWidth = 0.7 -- 1336
					}) -- 1336
				end -- 1336
			end -- 1336
			::__continue93:: -- 1336
			i = i + 1 -- 1297
		end -- 1297
	end -- 1297
	local arch = room.arch -- 1342
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1343
		scene:addBeveledFrame( -- 1344
			arch.x0, -- 1344
			arch.x1, -- 1344
			arch.y, -- 1344
			arch.y + arch.h, -- 1344
			22, -- 1344
			18, -- 1344
			-10, -- 1344
			64, -- 1344
			____exports.MING_MATERIALS.mingStoneStep, -- 1344
			{ -- 1344
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1345
				innerRimLight = rgba(176, 206, 228, 255), -- 1346
				innerRimStrength = 0.45 -- 1347
			} -- 1347
		) -- 1347
	end -- 1347
	local c = room.cart -- 1352
	if c.bodyW > 0 then -- 1353
		scene:addContactShadow( -- 1354
			cartAxle, -- 1354
			c.baseY, -- 1354
			c.bodyW * 0.62, -- 1354
			14, -- 1354
			0.7, -- 1354
			{bucket = ____exports.LP_BUCKET.PROP} -- 1354
		) -- 1354
		local clothX = cartAxle - c.bodyW * 0.5 -- 1355
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1356
		local sway = math.sin(time * 3.1) * 5.5 -- 1357
		scene:addTri3D( -- 1358
			____exports.vec3(clothX, clothTop, -4), -- 1359
			____exports.vec3(clothX + 9, clothTop, -4), -- 1360
			____exports.vec3(clothX - 5 + sway, clothTop - 22, -6), -- 1361
			____exports.MING_MATERIALS.mingRedCloth, -- 1362
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, edgeWidth = 0.9} -- 1363
		) -- 1363
	end -- 1363
	scene:addContactShadow( -- 1368
		actorX, -- 1368
		actorY, -- 1368
		15, -- 1368
		11, -- 1368
		0.78, -- 1368
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1368
	) -- 1368
end -- 1232
return ____exports -- 1232
