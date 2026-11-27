-- [ts]: lowpoly.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 22
local Color = ____Dora.Color -- 22
local Vec2 = ____Dora.Vec2 -- 22
local ____theme = require("Script.watch.fe.theme") -- 26
local lerpRGBA = ____theme.lerpRGBA -- 26
local rgba = ____theme.rgba -- 26
local toColor = ____theme.toColor -- 26
____exports.LP_BUCKET = { -- 90
	BACKDROP = 0, -- 91
	MIDGROUND = 1, -- 92
	WALK_DECK = 2, -- 93
	PROP = 3, -- 94
	FOREGROUND = 4 -- 95
} -- 95
function ____exports.clamp01(v) -- 152
	return math.max( -- 153
		0, -- 153
		math.min(1, v) -- 153
	) -- 153
end -- 152
function ____exports.smoothstep(edge0, edge1, x) -- 156
	if edge1 <= edge0 then -- 156
		return x >= edge1 and 1 or 0 -- 158
	end -- 158
	local t = ____exports.clamp01((x - edge0) / (edge1 - edge0)) -- 160
	return t * t * (3 - 2 * t) -- 161
end -- 156
function ____exports.vec3(x, y, z) -- 164
	return {x = x, y = y, z = z} -- 165
end -- 164
function ____exports.normalize3(v) -- 168
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) -- 169
	if len < 0.00001 then -- 169
		return {x = 0, y = 1, z = 0} -- 171
	end -- 171
	return {x = v.x / len, y = v.y / len, z = v.z / len} -- 173
end -- 168
local function dot3(a, b) -- 176
	return a.x * b.x + a.y * b.y + a.z * b.z -- 177
end -- 176
local function cross3(a, b) -- 180
	return {x = a.y * b.z - a.z * b.y, y = a.z * b.x - a.x * b.z, z = a.x * b.y - a.y * b.x} -- 181
end -- 180
local function sub3(a, b) -- 188
	return {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z} -- 189
end -- 188
local function clampByte(v) -- 192
	return math.max( -- 193
		0, -- 193
		math.min( -- 193
			255, -- 193
			math.floor(v + 0.5) -- 193
		) -- 193
	) -- 193
end -- 192
local function scaleRGBA(c, k, alphaMul) -- 196
	if alphaMul == nil then -- 196
		alphaMul = 1 -- 196
	end -- 196
	return { -- 197
		r = clampByte(c.r * k), -- 198
		g = clampByte(c.g * k), -- 199
		b = clampByte(c.b * k), -- 200
		a = clampByte(c.a * alphaMul) -- 201
	} -- 201
end -- 196
--- 明初温州宁村所海防卫城低模材质预设（高灰度区分度、禁现代/仙侠荧光）
____exports.MING_MATERIALS = { -- 206
	mingBrick = { -- 207
		base = rgba(96, 102, 112, 255), -- 208
		edge = rgba(154, 162, 174, 155), -- 209
		minShade = 0.3, -- 210
		rimBoost = 0.24, -- 211
		bottomAo = 0.28 -- 212
	}, -- 212
	mingBrickDark = { -- 214
		base = rgba(54, 60, 72, 255), -- 215
		edge = rgba(108, 118, 134, 135), -- 216
		minShade = 0.24, -- 217
		rimBoost = 0.18, -- 218
		bottomAo = 0.34 -- 219
	}, -- 219
	mingTimber = { -- 221
		base = rgba(114, 84, 62, 255), -- 222
		edge = rgba(168, 134, 104, 160), -- 223
		minShade = 0.26, -- 224
		rimBoost = 0.22, -- 225
		bottomAo = 0.3 -- 226
	}, -- 226
	mingTimberDark = { -- 228
		base = rgba(68, 50, 38, 255), -- 229
		edge = rgba(122, 96, 76, 145), -- 230
		minShade = 0.2, -- 231
		rimBoost = 0.16, -- 232
		bottomAo = 0.36 -- 233
	}, -- 233
	mingStoneStep = { -- 235
		base = rgba(118, 122, 128, 255), -- 236
		edge = rgba(188, 194, 200, 185), -- 237
		minShade = 0.28, -- 238
		rimBoost = 0.26, -- 239
		bottomAo = 0.26 -- 240
	}, -- 240
	mingIron = { -- 242
		base = rgba(46, 52, 62, 255), -- 243
		edge = rgba(136, 146, 158, 165), -- 244
		minShade = 0.22, -- 245
		rimBoost = 0.28, -- 246
		bottomAo = 0.25 -- 247
	}, -- 247
	mingTile = { -- 249
		base = rgba(44, 52, 66, 255), -- 250
		edge = rgba(102, 116, 136, 140), -- 251
		minShade = 0.24, -- 252
		rimBoost = 0.18, -- 253
		bottomAo = 0.24 -- 254
	}, -- 254
	mingRedCloth = { -- 256
		base = rgba(176, 52, 48, 255), -- 257
		edge = rgba(224, 116, 102, 195), -- 258
		minShade = 0.36, -- 259
		rimBoost = 0.24, -- 260
		bottomAo = 0.18 -- 261
	}, -- 261
	distantWall = { -- 263
		base = rgba(42, 52, 68, 255), -- 264
		edge = rgba(98, 114, 136, 115), -- 265
		minShade = 0.35, -- 266
		rimBoost = 0.14, -- 267
		bottomAo = 0.22 -- 268
	}, -- 268
	distantHill = { -- 270
		base = rgba(28, 38, 54, 255), -- 271
		edge = rgba(74, 92, 116, 90), -- 272
		minShade = 0.38, -- 273
		rimBoost = 0.12, -- 274
		bottomAo = 0.2 -- 275
	} -- 275
} -- 275
--- 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光）
____exports.GATE_NIGHTMARE_LIGHT = { -- 280
	keyDir = ____exports.normalize3(____exports.vec3(-0.62, 0.64, -0.45)), -- 281
	keyColor = rgba(206, 224, 240, 255), -- 282
	keyStrength = 0.88, -- 283
	rimDir = ____exports.normalize3(____exports.vec3(0.76, 0.36, -0.54)), -- 284
	rimColor = rgba(224, 196, 150, 255), -- 285
	rimStrength = 0.34, -- 286
	ambientColor = rgba(26, 34, 48, 255), -- 287
	fogColor = rgba(26, 36, 52, 255), -- 288
	fogStartZ = 36, -- 289
	fogEndZ = 560, -- 290
	fogMaxAlpha = 0.84, -- 291
	shadowContrast = 0.72 -- 292
} -- 292
____exports.OUTSIDE_JETTY_LIGHT = { -- 295
	keyDir = ____exports.normalize3(____exports.vec3(-0.56, 0.68, -0.48)), -- 296
	keyColor = rgba(196, 214, 232, 255), -- 297
	keyStrength = 0.86, -- 298
	rimDir = ____exports.normalize3(____exports.vec3(0.78, 0.32, -0.54)), -- 299
	rimColor = rgba(226, 188, 136, 255), -- 300
	rimStrength = 0.32, -- 301
	ambientColor = rgba(24, 32, 46, 255), -- 302
	fogColor = rgba(24, 34, 50, 255), -- 303
	fogStartZ = 42, -- 304
	fogEndZ = 520, -- 305
	fogMaxAlpha = 0.8, -- 306
	shadowContrast = 0.74 -- 307
} -- 307
____exports.VILLAGE_UNDERTABLE_LIGHT = { -- 310
	keyDir = ____exports.normalize3(____exports.vec3(0.72, 0.44, -0.54)), -- 311
	keyColor = rgba(214, 208, 194, 255), -- 312
	keyStrength = 0.92, -- 313
	rimDir = ____exports.normalize3(____exports.vec3(-0.64, 0.52, -0.56)), -- 314
	rimColor = rgba(146, 166, 186, 255), -- 315
	rimStrength = 0.28, -- 316
	ambientColor = rgba(18, 22, 30, 255), -- 317
	fogColor = rgba(22, 26, 34, 255), -- 318
	fogStartZ = 55, -- 319
	fogEndZ = 460, -- 320
	fogMaxAlpha = 0.78, -- 321
	shadowContrast = 0.82 -- 322
} -- 322
____exports.FOREST_CREEK_LIGHT = { -- 325
	keyDir = ____exports.normalize3(____exports.vec3(-0.48, 0.74, -0.47)), -- 326
	keyColor = rgba(178, 206, 202, 255), -- 327
	keyStrength = 0.8, -- 328
	rimDir = ____exports.normalize3(____exports.vec3(0.82, 0.28, -0.5)), -- 329
	rimColor = rgba(232, 196, 132, 255), -- 330
	rimStrength = 0.36, -- 331
	ambientColor = rgba(18, 30, 34, 255), -- 332
	fogColor = rgba(20, 34, 38, 255), -- 333
	fogStartZ = 34, -- 334
	fogEndZ = 480, -- 335
	fogMaxAlpha = 0.86, -- 336
	shadowContrast = 0.76 -- 337
} -- 337
____exports.TOWER_WEST_LAMP_LIGHT = { -- 340
	keyDir = ____exports.normalize3(____exports.vec3(-0.74, 0.48, -0.47)), -- 341
	keyColor = rgba(242, 202, 138, 255), -- 342
	keyStrength = 0.94, -- 343
	rimDir = ____exports.normalize3(____exports.vec3(0.62, 0.54, -0.57)), -- 344
	rimColor = rgba(142, 168, 198, 255), -- 345
	rimStrength = 0.26, -- 346
	ambientColor = rgba(24, 26, 36, 255), -- 347
	fogColor = rgba(24, 28, 40, 255), -- 348
	fogStartZ = 60, -- 349
	fogEndZ = 480, -- 350
	fogMaxAlpha = 0.72, -- 351
	shadowContrast = 0.7 -- 352
} -- 352
--- 核心 2.5D 低模投影：
-- 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
function ____exports.projectWorld3D(wx, wy, wz, cam, proj) -- 359
	local bx = cam:sx(wx) -- 366
	local by = cam:sy(wy, proj.baseDepth or 0) -- 367
	local m = ____exports.clamp01(proj.morph) -- 368
	if m <= 0.00001 or math.abs(wz) <= 0.00001 then -- 368
		return {x = bx, y = by, scale = 1, zEff = 0} -- 370
	end -- 370
	local focal = math.max(60, proj.focal) -- 372
	local zEff = wz * m -- 373
	local denom = math.max(focal * 0.22, focal + zEff) -- 374
	local s = focal / denom -- 375
	local vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX or 0) -- 376
	local vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY or 0) -- 377
	return {x = vpX + (bx - vpX) * s, y = vpY + (by - vpY) * s, scale = s, zEff = zEff} -- 378
end -- 359
--- 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
-- 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
function ____exports.verifyWalkPlaneAlignment(cam, proj, wx, wy) -- 390
	local p3 = ____exports.projectWorld3D( -- 396
		wx, -- 396
		wy, -- 396
		0, -- 396
		cam, -- 396
		proj -- 396
	) -- 396
	local p2 = cam:worldToScreen(wx, wy, proj.baseDepth or 0) -- 397
	local fwdDx = p3.x - p2.x -- 398
	local fwdDy = p3.y - p2.y -- 399
	local forwardErrPx = math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy) -- 400
	local inv = cam:screenToWorld(p3.x, p3.y) -- 402
	local invDx = inv.x - wx -- 403
	local invDy = inv.y - (wy + (proj.baseDepth or 0)) -- 404
	local inverseErrWorld = math.sqrt(invDx * invDx + invDy * invDy) -- 405
	return {forwardErrPx = forwardErrPx, inverseErrWorld = inverseErrWorld, screenX = p3.x, screenY = p3.y} -- 406
end -- 390
--- 计算给定法线与深度的低模平面受光+雾效颜色
function ____exports.shadeSurface(base, normal, avgZ, morph, light, mat, opacityMul) -- 415
	if opacityMul == nil then -- 415
		opacityMul = 1 -- 422
	end -- 422
	local m = ____exports.clamp01(morph) -- 424
	local n = ____exports.normalize3(normal) -- 425
	local ndl = math.max( -- 426
		0, -- 426
		dot3(n, light.keyDir) -- 426
	) -- 426
	local ndr = math.max( -- 427
		0, -- 427
		dot3(n, light.rimDir) -- 427
	) -- 427
	local minShade = mat and mat.minShade or 0.28 -- 428
	local rimBoost = mat and mat.rimBoost or 0.2 -- 429
	local contrast = light.shadowContrast * (0.45 + 0.55 * m) -- 430
	local keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25) -- 432
	local rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost) -- 433
	local rLit = base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255) + light.ambientColor.r * (0.28 * (1 - ndl * 0.5)) + light.rimColor.r * rimFactor * 0.45 -- 435
	local gLit = base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255) + light.ambientColor.g * (0.28 * (1 - ndl * 0.5)) + light.rimColor.g * rimFactor * 0.45 -- 438
	local bLit = base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255) + light.ambientColor.b * (0.28 * (1 - ndl * 0.5)) + light.rimColor.b * rimFactor * 0.45 -- 441
	local lit = { -- 445
		r = clampByte(rLit), -- 446
		g = clampByte(gLit), -- 447
		b = clampByte(bLit), -- 448
		a = clampByte(base.a * ____exports.clamp01(opacityMul)) -- 449
	} -- 449
	if avgZ > light.fogStartZ and m > 0.01 then -- 449
		local span = math.max(1, light.fogEndZ - light.fogStartZ) -- 453
		local fogT = ____exports.clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m -- 454
		local mixed = lerpRGBA(lit, light.fogColor, fogT) -- 455
		mixed.a = lit.a -- 456
		return mixed -- 457
	end -- 457
	return lit -- 459
end -- 415
--- 画家算法低模场景批处理器：
-- 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
____exports.LowpolyScene = __TS__Class() -- 466
local LowpolyScene = ____exports.LowpolyScene -- 466
LowpolyScene.name = "LowpolyScene" -- 466
function LowpolyScene.prototype.____constructor(self, cam, proj, light) -- 473
	if light == nil then -- 473
		light = ____exports.GATE_NIGHTMARE_LIGHT -- 473
	end -- 473
	self.faces = {} -- 470
	self.glows = {} -- 471
	self.cam = cam -- 474
	self.proj = proj -- 475
	self.light = light -- 476
end -- 473
function LowpolyScene.prototype.getFaceCount(self) -- 479
	return #self.faces -- 480
end -- 479
function LowpolyScene.prototype.project(self, wx, wy, wz) -- 483
	return ____exports.projectWorld3D( -- 484
		wx, -- 484
		wy, -- 484
		wz, -- 484
		self.cam, -- 484
		self.proj -- 484
	) -- 484
end -- 483
function LowpolyScene.prototype.vanishingPointScreen(self) -- 487
	return {x = self.cam.viewW * self.proj.vpFracX + (self.proj.vpOffsetX or 0), y = self.cam.viewH * self.proj.vpFracY + (self.proj.vpOffsetY or 0)} -- 488
end -- 487
function LowpolyScene.prototype.addQuad3D(self, v0, v1, v2, v3, mat, opts) -- 495
	if opts == nil then -- 495
		opts = {} -- 501
	end -- 501
	local opacity = opts.opacity or 1 -- 503
	if opacity <= 0.01 then -- 503
		return -- 505
	end -- 505
	local p0 = self:project(v0.x, v0.y, v0.z) -- 507
	local p1 = self:project(v1.x, v1.y, v1.z) -- 508
	local p2 = self:project(v2.x, v2.y, v2.z) -- 509
	local p3 = self:project(v3.x, v3.y, v3.z) -- 510
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y)) -- 513
	if area2 < 0.25 then -- 513
		return -- 518
	end -- 518
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z + v3.z) * 0.25 -- 521
	local topRgba -- 522
	if opts.unlit == true then -- 522
		topRgba = scaleRGBA(mat.base, 1, opacity) -- 524
	else -- 524
		local n = cross3( -- 526
			sub3(v1, v0), -- 526
			sub3(v3, v0) -- 526
		) -- 526
		topRgba = ____exports.shadeSurface( -- 527
			mat.base, -- 527
			n, -- 527
			avgZ, -- 527
			self.proj.morph, -- 527
			self.light, -- 527
			mat, -- 527
			opacity -- 527
		) -- 527
	end -- 527
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.22) -- 530
	local botRgba = ao > 0.005 and scaleRGBA( -- 531
		topRgba, -- 531
		math.max(0.35, 1 - ao * (0.45 + 0.55 * self.proj.morph)), -- 531
		1 -- 531
	) or topRgba -- 531
	local cBot = toColor(botRgba) -- 532
	local cTop = toColor(topRgba) -- 533
	local edgeRgba = opts.edgeColor or mat.edge -- 535
	local edgeW = opts.edgeWidth or 0 -- 536
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 537
		edgeRgba, -- 538
		math.floor(edgeRgba.a * opacity + 0.5) -- 538
	) or nil -- 538
	local ____self_faces_4 = self.faces -- 538
	____self_faces_4[#____self_faces_4 + 1] = { -- 541
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 542
		sortZ = avgZ, -- 543
		sortBias = opts.sortBias or 0, -- 544
		pts = {p0, p1, p2, p3}, -- 545
		cols = {cBot, cBot, cTop, cTop}, -- 546
		edgeCol = edgeCol, -- 547
		edgeWidth = edgeW, -- 548
		topHighlight = nil -- 549
	} -- 549
end -- 495
function LowpolyScene.prototype.addTri3D(self, v0, v1, v2, mat, opts) -- 554
	if opts == nil then -- 554
		opts = {} -- 559
	end -- 559
	local opacity = opts.opacity or 1 -- 561
	if opacity <= 0.01 then -- 561
		return -- 563
	end -- 563
	local p0 = self:project(v0.x, v0.y, v0.z) -- 565
	local p1 = self:project(v1.x, v1.y, v1.z) -- 566
	local p2 = self:project(v2.x, v2.y, v2.z) -- 567
	local area2 = math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)) -- 569
	if area2 < 0.25 then -- 569
		return -- 571
	end -- 571
	local avgZ = opts.sortZOverride ~= nil and opts.sortZOverride or (v0.z + v1.z + v2.z) / 3 -- 574
	local colRgba = opts.unlit == true and scaleRGBA(mat.base, 1, opacity) or ____exports.shadeSurface( -- 575
		mat.base, -- 577
		cross3( -- 577
			sub3(v1, v0), -- 577
			sub3(v2, v0) -- 577
		), -- 577
		avgZ, -- 577
		self.proj.morph, -- 577
		self.light, -- 577
		mat, -- 577
		opacity -- 577
	) -- 577
	local ao = opts.bottomAo ~= nil and opts.bottomAo or (mat.bottomAo or 0.16) -- 578
	local botRgba = ao > 0.005 and scaleRGBA( -- 579
		colRgba, -- 579
		math.max(0.4, 1 - ao), -- 579
		1 -- 579
	) or colRgba -- 579
	local edgeRgba = opts.edgeColor or mat.edge -- 581
	local edgeW = opts.edgeWidth or 0 -- 582
	local edgeCol = edgeRgba ~= nil and edgeW > 0 and toColor( -- 583
		edgeRgba, -- 584
		math.floor(edgeRgba.a * opacity + 0.5) -- 584
	) or nil -- 584
	local ____self_faces_5 = self.faces -- 584
	____self_faces_5[#____self_faces_5 + 1] = { -- 587
		bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND, -- 588
		sortZ = avgZ, -- 589
		sortBias = opts.sortBias or 0, -- 590
		pts = {p0, p1, p2}, -- 591
		cols = { -- 592
			toColor(botRgba), -- 592
			toColor(botRgba), -- 592
			toColor(colRgba) -- 592
		}, -- 592
		edgeCol = edgeCol, -- 593
		edgeWidth = edgeW, -- 594
		topHighlight = nil -- 595
	} -- 595
end -- 554
function LowpolyScene.prototype.addBox(self, spec) -- 603
	local opacity = spec.opacity or 1 -- 604
	if opacity <= 0.01 then -- 604
		return -- 606
	end -- 606
	local x0 = math.min(spec.x0, spec.x1) -- 608
	local x1 = math.max(spec.x0, spec.x1) -- 609
	local y0 = math.min(spec.y0, spec.y1) -- 610
	local y1 = math.max(spec.y0, spec.y1) -- 611
	local z0 = math.min(spec.z0, spec.z1) -- 612
	local z1 = math.max(spec.z0, spec.z1) -- 613
	local bucket = spec.bucket or ____exports.LP_BUCKET.MIDGROUND -- 615
	local bias = spec.sortBias or 0 -- 616
	local edgeW = spec.edgeWidth or 0.85 -- 617
	local midZ = (z0 + z1) * 0.5 -- 618
	local vp = self:vanishingPointScreen() -- 619
	local m = ____exports.clamp01(self.proj.morph) -- 620
	local sx0 = self.cam:sx(x0) -- 622
	local sx1 = self.cam:sx(x1) -- 623
	local sy0 = self.cam:sy(y0, self.proj.baseDepth or 0) -- 624
	local sy1 = self.cam:sy(y1, self.proj.baseDepth or 0) -- 625
	if m > 0.002 and z1 - z0 > 0.05 then -- 625
		if spec.skipLeft ~= true and sx0 > vp.x + 0.5 then -- 625
			self:addQuad3D( -- 630
				____exports.vec3(x0, y0, z1), -- 631
				____exports.vec3(x0, y0, z0), -- 632
				____exports.vec3(x0, y1, z0), -- 633
				____exports.vec3(x0, y1, z1), -- 634
				spec.material, -- 635
				{ -- 636
					bucket = bucket, -- 636
					sortZOverride = midZ + 0.4, -- 636
					sortBias = bias - 0.1, -- 636
					opacity = opacity, -- 636
					edgeWidth = edgeW -- 636
				} -- 636
			) -- 636
		end -- 636
		if spec.skipRight ~= true and sx1 < vp.x - 0.5 then -- 636
			self:addQuad3D( -- 641
				____exports.vec3(x1, y0, z0), -- 642
				____exports.vec3(x1, y0, z1), -- 643
				____exports.vec3(x1, y1, z1), -- 644
				____exports.vec3(x1, y1, z0), -- 645
				spec.material, -- 646
				{ -- 647
					bucket = bucket, -- 647
					sortZOverride = midZ + 0.4, -- 647
					sortBias = bias - 0.1, -- 647
					opacity = opacity, -- 647
					edgeWidth = edgeW -- 647
				} -- 647
			) -- 647
		end -- 647
		if spec.skipTop ~= true and sy1 < vp.y - 0.5 then -- 647
			self:addQuad3D( -- 652
				____exports.vec3(x0, y1, z0), -- 653
				____exports.vec3(x1, y1, z0), -- 654
				____exports.vec3(x1, y1, z1), -- 655
				____exports.vec3(x0, y1, z1), -- 656
				spec.material, -- 657
				{ -- 658
					bucket = bucket, -- 658
					sortZOverride = midZ + 0.2, -- 658
					sortBias = bias - 0.05, -- 658
					opacity = opacity, -- 658
					edgeWidth = edgeW, -- 658
					bottomAo = 0.08 -- 658
				} -- 658
			) -- 658
		end -- 658
		if spec.skipBottom ~= true and sy0 > vp.y + 0.5 then -- 658
			self:addQuad3D( -- 663
				____exports.vec3(x0, y0, z1), -- 664
				____exports.vec3(x1, y0, z1), -- 665
				____exports.vec3(x1, y0, z0), -- 666
				____exports.vec3(x0, y0, z0), -- 667
				spec.material, -- 668
				{ -- 669
					bucket = bucket, -- 669
					sortZOverride = midZ + 0.2, -- 669
					sortBias = bias - 0.05, -- 669
					opacity = opacity, -- 669
					edgeWidth = edgeW, -- 669
					bottomAo = 0.34 -- 669
				} -- 669
			) -- 669
		end -- 669
	end -- 669
	if spec.skipFront ~= true then -- 669
		local beforeLen = #self.faces -- 676
		self:addQuad3D( -- 677
			____exports.vec3(x0, y0, z0), -- 678
			____exports.vec3(x1, y0, z0), -- 679
			____exports.vec3(x1, y1, z0), -- 680
			____exports.vec3(x0, y1, z0), -- 681
			spec.material, -- 682
			{ -- 683
				bucket = bucket, -- 683
				sortZOverride = z0, -- 683
				sortBias = bias, -- 683
				opacity = opacity, -- 683
				edgeWidth = edgeW -- 683
			} -- 683
		) -- 683
		if spec.highlightTopEdge == true and #self.faces > beforeLen then -- 683
			local face = self.faces[#self.faces] -- 686
			local rimCol = spec.material.edge or rgba(198, 206, 214, 180) -- 687
			face.topHighlight = { -- 688
				face.pts[4], -- 689
				face.pts[3], -- 690
				toColor( -- 691
					rimCol, -- 691
					math.floor(math.min(245, rimCol.a * 1.15) * opacity + 0.5) -- 691
				) -- 691
			} -- 691
		end -- 691
	end -- 691
end -- 603
function LowpolyScene.prototype.addBeveledFrame(self, openX0, openX1, y0, openY1, pillarW, lintelH, z0, z1, mat, opts) -- 701
	if opts == nil then -- 701
		opts = {} -- 711
	end -- 711
	local bucket = opts.bucket or ____exports.LP_BUCKET.MIDGROUND -- 719
	local opacity = opts.opacity or 1 -- 720
	local bias = opts.sortBias or 0 -- 721
	self:addBox({ -- 724
		x0 = openX0 - pillarW, -- 725
		x1 = openX0, -- 726
		y0 = y0, -- 727
		y1 = openY1 + lintelH, -- 728
		z0 = z0, -- 729
		z1 = z1, -- 730
		material = mat, -- 731
		bucket = bucket, -- 732
		sortBias = bias, -- 733
		opacity = opacity, -- 734
		highlightTopEdge = true -- 735
	}) -- 735
	self:addBox({ -- 738
		x0 = openX1, -- 739
		x1 = openX1 + pillarW, -- 740
		y0 = y0, -- 741
		y1 = openY1 + lintelH, -- 742
		z0 = z0, -- 743
		z1 = z1, -- 744
		material = mat, -- 745
		bucket = bucket, -- 746
		sortBias = bias, -- 747
		opacity = opacity, -- 748
		highlightTopEdge = true -- 749
	}) -- 749
	self:addBox({ -- 752
		x0 = openX0 - pillarW * 0.2, -- 753
		x1 = openX1 + pillarW * 0.2, -- 754
		y0 = openY1, -- 755
		y1 = openY1 + lintelH, -- 756
		z0 = z0, -- 757
		z1 = z1, -- 758
		material = mat, -- 759
		bucket = bucket, -- 760
		sortBias = bias + 0.05, -- 761
		opacity = opacity, -- 762
		highlightTopEdge = true -- 763
	}) -- 763
	local rimAlpha = (opts.innerRimStrength or 0) * ____exports.clamp01(self.proj.morph) * opacity -- 767
	if rimAlpha > 0.02 then -- 767
		local rimCol = opts.innerRimLight or rgba(226, 236, 246, 255) -- 769
		local p0 = self:project(openX0, y0 + 2, z0) -- 770
		local p1 = self:project(openX0, y0 + 2, z1) -- 771
		local p2 = self:project(openX0, openY1 - 2, z1) -- 772
		local p3 = self:project(openX0, openY1 - 2, z0) -- 773
		local cNear = toColor( -- 774
			rimCol, -- 774
			math.floor(135 * rimAlpha + 0.5) -- 774
		) -- 774
		local cFar = toColor( -- 775
			rimCol, -- 775
			math.floor(28 * rimAlpha + 0.5) -- 775
		) -- 775
		local ____self_glows_6 = self.glows -- 775
		____self_glows_6[#____self_glows_6 + 1] = {pts = {p0, p1, p2, p3}, cols = {cNear, cFar, cFar, cNear}} -- 776
	end -- 776
end -- 701
function LowpolyScene.prototype.addStairFlight(self, stair, z0, z1, mat, opts) -- 784
	if mat == nil then -- 784
		mat = ____exports.MING_MATERIALS.mingStoneStep -- 788
	end -- 788
	if opts == nil then -- 788
		opts = {} -- 789
	end -- 789
	local n = math.max(1, stair.steps + 1) -- 791
	local stepW = (stair.x1 - stair.x0) / n -- 792
	local floorY = opts.baseY ~= nil and opts.baseY or math.min(stair.y0, stair.y1) -- 793
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 794
	local opacity = opts.opacity or 1 -- 795
	local bias = opts.sortBias or 0 -- 796
	local k = 0 -- 798
	do -- 798
		k = 0 -- 799
		while k < n do -- 799
			do -- 799
				local wy = n == 1 and stair.y1 or stair.y0 + (stair.y1 - stair.y0) * k / (n - 1) -- 800
				local wx0 = stair.x0 + stepW * k -- 801
				local wx1 = wx0 + stepW -- 802
				if wy <= floorY + 1 then -- 802
					goto __continue43 -- 804
				end -- 804
				self:addBox({ -- 806
					x0 = wx0, -- 807
					x1 = wx1, -- 808
					y0 = floorY, -- 809
					y1 = wy, -- 810
					z0 = z0, -- 811
					z1 = z1, -- 812
					material = mat, -- 813
					bucket = bucket, -- 814
					sortBias = bias + k * 0.01, -- 815
					opacity = opacity, -- 816
					highlightTopEdge = true, -- 817
					edgeWidth = 0.9 -- 818
				}) -- 818
			end -- 818
			::__continue43:: -- 818
			k = k + 1 -- 799
		end -- 799
	end -- 799
end -- 784
function LowpolyScene.prototype.addPlankDeck(self, x0, x1, topY, z0, z1, plankCount, thickness, mat, opts) -- 827
	if mat == nil then -- 827
		mat = ____exports.MING_MATERIALS.mingTimber -- 835
	end -- 835
	if opts == nil then -- 835
		opts = {} -- 836
	end -- 836
	local count = math.max( -- 844
		1, -- 844
		math.floor(plankCount) -- 844
	) -- 844
	local bucket = opts.bucket or ____exports.LP_BUCKET.WALK_DECK -- 845
	local opacity = opts.opacity or 1 -- 846
	local bias = opts.sortBias or 0 -- 847
	local spanZ = math.max(1, z1 - z0) -- 848
	local gap = math.min(2.6, spanZ / (count * 6)) -- 849
	local plankDepth = (spanZ - gap * (count - 1)) / count -- 850
	if opts.withPosts == true then -- 850
		local postBot = opts.postBottomY or topY - 92 -- 854
		local postMat = ____exports.MING_MATERIALS.mingTimberDark -- 855
		local postCount = math.max( -- 856
			2, -- 856
			math.min( -- 856
				5, -- 856
				math.floor((x1 - x0) / 110) + 1 -- 856
			) -- 856
		) -- 856
		local pi = 0 -- 857
		do -- 857
			pi = 0 -- 858
			while pi < postCount do -- 858
				local px = x0 + 18 + (x1 - x0 - 36) * pi / math.max(1, postCount - 1) -- 859
				self:addBox({ -- 860
					x0 = px - 6, -- 861
					x1 = px + 6, -- 862
					y0 = postBot, -- 863
					y1 = topY - thickness, -- 864
					z0 = z0 + 4, -- 865
					z1 = z0 + 18, -- 866
					material = postMat, -- 867
					bucket = bucket, -- 868
					sortBias = bias - 0.3, -- 869
					opacity = opacity, -- 870
					edgeWidth = 0.7 -- 871
				}) -- 871
				pi = pi + 1 -- 858
			end -- 858
		end -- 858
	end -- 858
	local i = 0 -- 877
	do -- 877
		i = 0 -- 878
		while i < count do -- 878
			local pz0 = z0 + i * (plankDepth + gap) -- 879
			local pz1 = pz0 + plankDepth -- 880
			local plankMat = i & 1 == 0 and mat or ({ -- 881
				base = scaleRGBA(mat.base, 0.88), -- 884
				edge = mat.edge, -- 885
				minShade = mat.minShade, -- 886
				rimBoost = mat.rimBoost, -- 887
				bottomAo = mat.bottomAo -- 888
			}) -- 888
			self:addBox({ -- 890
				x0 = x0, -- 891
				x1 = x1, -- 892
				y0 = topY - thickness, -- 893
				y1 = topY, -- 894
				z0 = pz0, -- 895
				z1 = pz1, -- 896
				material = plankMat, -- 897
				bucket = bucket, -- 898
				sortBias = bias + (count - i) * 0.01, -- 899
				opacity = opacity, -- 900
				highlightTopEdge = i == 0, -- 901
				edgeWidth = 0.8 -- 902
			}) -- 902
			i = i + 1 -- 878
		end -- 878
	end -- 878
end -- 827
function LowpolyScene.prototype.addDistantRidge(self, peaks, baseY, z, mat, opts) -- 908
	if mat == nil then -- 908
		mat = ____exports.MING_MATERIALS.distantHill -- 912
	end -- 912
	if opts == nil then -- 912
		opts = {} -- 913
	end -- 913
	if #peaks < 2 then -- 913
		return -- 916
	end -- 916
	local bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP -- 918
	local opacity = opts.opacity or 1 -- 919
	local bias = opts.sortBias or 0 -- 920
	local i = 0 -- 922
	do -- 922
		i = 0 -- 923
		while i < #peaks - 1 do -- 923
			local a = peaks[i + 1] -- 924
			local b = peaks[i + 1 + 1] -- 925
			local midX = (a.x + b.x) * 0.5 -- 926
			local midY = math.min(a.y, b.y) - math.abs(b.y - a.y) * 0.25 -- 927
			local ridgeMat = b.y >= a.y and mat or ({ -- 928
				base = scaleRGBA(mat.base, 0.84), -- 931
				edge = mat.edge, -- 932
				minShade = mat.minShade, -- 933
				rimBoost = mat.rimBoost, -- 934
				bottomAo = mat.bottomAo -- 935
			}) -- 935
			self:addTri3D( -- 937
				____exports.vec3(a.x, baseY, z), -- 938
				____exports.vec3(b.x, baseY, z), -- 939
				____exports.vec3(a.x, a.y, z), -- 940
				ridgeMat, -- 941
				{bucket = bucket, sortBias = bias, opacity = opacity, edgeWidth = 0} -- 942
			) -- 942
			self:addTri3D( -- 944
				____exports.vec3(b.x, baseY, z), -- 945
				____exports.vec3(b.x, b.y, z), -- 946
				____exports.vec3(a.x, a.y, z), -- 947
				ridgeMat, -- 948
				{bucket = bucket, sortBias = bias + 0.01, opacity = opacity, edgeWidth = 0} -- 949
			) -- 949
			self:addTri3D( -- 952
				____exports.vec3( -- 953
					midX, -- 953
					math.max(baseY, midY), -- 953
					z - 8 -- 953
				), -- 953
				____exports.vec3(b.x, baseY, z), -- 954
				____exports.vec3(b.x, b.y, z), -- 955
				{ -- 956
					base = scaleRGBA(mat.base, 0.78), -- 956
					minShade = 0.3, -- 956
					bottomAo = 0.2 -- 956
				}, -- 956
				{bucket = bucket, sortBias = bias + 0.02, opacity = opacity * 0.85} -- 957
			) -- 957
			i = i + 1 -- 923
		end -- 923
	end -- 923
end -- 908
function LowpolyScene.prototype.addFogBand(self, x0, x1, y0, y1, z, color, bottomAlpha, topAlpha, opts) -- 963
	if opts == nil then -- 963
		opts = {} -- 972
	end -- 972
	local m = ____exports.clamp01(self.proj.morph) -- 974
	local ba = ____exports.clamp01(bottomAlpha * m) -- 975
	local ta = ____exports.clamp01(topAlpha * m) -- 976
	if ba <= 0.008 and ta <= 0.008 then -- 976
		return -- 978
	end -- 978
	local p0 = self:project(x0, y0, z) -- 980
	local p1 = self:project(x1, y0, z) -- 981
	local p2 = self:project(x1, y1, z) -- 982
	local p3 = self:project(x0, y1, z) -- 983
	local cBot = toColor( -- 984
		color, -- 984
		math.floor(255 * ba + 0.5) -- 984
	) -- 984
	local cTop = toColor( -- 985
		color, -- 985
		math.floor(255 * ta + 0.5) -- 985
	) -- 985
	local ____self_faces_7 = self.faces -- 985
	____self_faces_7[#____self_faces_7 + 1] = { -- 986
		bucket = opts.bucket or ____exports.LP_BUCKET.BACKDROP, -- 987
		sortZ = z, -- 988
		sortBias = opts.sortBias or 0.5, -- 989
		pts = {p0, p1, p2, p3}, -- 990
		cols = {cBot, cBot, cTop, cTop}, -- 991
		edgeCol = nil, -- 992
		edgeWidth = 0, -- 993
		topHighlight = nil -- 994
	} -- 994
end -- 963
function LowpolyScene.prototype.addLightShaft(self, topX0, topX1, topY, botX0, botX1, botY, z, color, topAlpha, botAlpha) -- 999
	local ta = ____exports.clamp01(topAlpha) -- 1011
	local ba = ____exports.clamp01(botAlpha) -- 1012
	if ta <= 0.005 and ba <= 0.005 then -- 1012
		return -- 1014
	end -- 1014
	local p0 = self:project(botX0, botY, z) -- 1016
	local p1 = self:project(botX1, botY, z) -- 1017
	local p2 = self:project(topX1, topY, z) -- 1018
	local p3 = self:project(topX0, topY, z) -- 1019
	local cTop = toColor( -- 1020
		color, -- 1020
		math.floor(255 * ta + 0.5) -- 1020
	) -- 1020
	local cBot = toColor( -- 1021
		color, -- 1021
		math.floor(255 * ba + 0.5) -- 1021
	) -- 1021
	local ____self_glows_8 = self.glows -- 1021
	____self_glows_8[#____self_glows_8 + 1] = {pts = {p0, p1, p2, p3}, cols = {cBot, cBot, cTop, cTop}} -- 1022
end -- 999
function LowpolyScene.prototype.addContactShadow(self, wx, wy, radiusX, radiusZ, opacity, opts) -- 1032
	if opacity == nil then -- 1032
		opacity = 0.72 -- 1037
	end -- 1037
	if opts == nil then -- 1037
		opts = {} -- 1038
	end -- 1038
	local op = ____exports.clamp01(opacity) -- 1040
	if op <= 0.01 then -- 1040
		return -- 1042
	end -- 1042
	local bucket = opts.bucket or ____exports.LP_BUCKET.PROP -- 1044
	local bias = opts.sortBias or 0.2 -- 1045
	local m = ____exports.clamp01(self.proj.morph) -- 1046
	local castShiftX = (opts.castDirX or -self.light.keyDir.x) * radiusX * (0.28 + 0.42 * m) -- 1047
	local segs = 10 -- 1050
	local outerZ = math.max(4, radiusZ * (0.55 + 0.65 * m)) -- 1051
	local centerP = self:project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15) -- 1052
	local innerCol = Color( -- 1053
		7, -- 1053
		9, -- 1053
		14, -- 1053
		math.floor(145 * op * (0.55 + 0.45 * m) + 0.5) -- 1053
	) -- 1053
	local outerCol = Color(7, 9, 14, 0) -- 1054
	local i = 0 -- 1055
	do -- 1055
		i = 0 -- 1056
		while i < segs do -- 1056
			local a0 = i / segs * math.pi * 2 -- 1057
			local a1 = (i + 1) / segs * math.pi * 2 -- 1058
			local pA = self:project( -- 1059
				wx + castShiftX * 0.45 + math.cos(a0) * radiusX * 1.42, -- 1060
				wy + 0.4, -- 1061
				outerZ * 0.15 + math.sin(a0) * outerZ -- 1062
			) -- 1062
			local pB = self:project( -- 1064
				wx + castShiftX * 0.45 + math.cos(a1) * radiusX * 1.42, -- 1065
				wy + 0.4, -- 1066
				outerZ * 0.15 + math.sin(a1) * outerZ -- 1067
			) -- 1067
			local ____self_faces_9 = self.faces -- 1067
			____self_faces_9[#____self_faces_9 + 1] = { -- 1069
				bucket = bucket, -- 1070
				sortZ = 0.05, -- 1071
				sortBias = bias, -- 1072
				pts = {centerP, pA, pB}, -- 1073
				cols = {innerCol, outerCol, outerCol}, -- 1074
				edgeCol = nil, -- 1075
				edgeWidth = 0, -- 1076
				topHighlight = nil -- 1077
			} -- 1077
			i = i + 1 -- 1056
		end -- 1056
	end -- 1056
	local footP = self:project(wx, wy + 0.5, 0) -- 1082
	local coreRx = self.cam:len(radiusX * 0.78) -- 1083
	local coreRy = math.max( -- 1084
		2.5, -- 1084
		self.cam:len(math.max(2.4, radiusZ * 0.24)) -- 1084
	) -- 1084
	local coreIn = Color( -- 1085
		5, -- 1085
		7, -- 1085
		12, -- 1085
		math.floor(210 * op + 0.5) -- 1085
	) -- 1085
	local coreOut = Color( -- 1086
		5, -- 1086
		7, -- 1086
		12, -- 1086
		math.floor(32 * op + 0.5) -- 1086
	) -- 1086
	local coreSegs = 8 -- 1087
	do -- 1087
		i = 0 -- 1088
		while i < coreSegs do -- 1088
			local a0 = i / coreSegs * math.pi * 2 -- 1089
			local a1 = (i + 1) / coreSegs * math.pi * 2 -- 1090
			local ____self_faces_10 = self.faces -- 1090
			____self_faces_10[#____self_faces_10 + 1] = { -- 1091
				bucket = bucket, -- 1092
				sortZ = 0.01, -- 1093
				sortBias = bias + 0.05, -- 1094
				pts = { -- 1095
					footP, -- 1096
					{ -- 1097
						x = footP.x + math.cos(a0) * coreRx, -- 1097
						y = footP.y + math.sin(a0) * coreRy, -- 1097
						scale = 1, -- 1097
						zEff = 0 -- 1097
					}, -- 1097
					{ -- 1098
						x = footP.x + math.cos(a1) * coreRx, -- 1098
						y = footP.y + math.sin(a1) * coreRy, -- 1098
						scale = 1, -- 1098
						zEff = 0 -- 1098
					} -- 1098
				}, -- 1098
				cols = {coreIn, coreOut, coreOut}, -- 1100
				edgeCol = nil, -- 1101
				edgeWidth = 0, -- 1102
				topHighlight = nil -- 1103
			} -- 1103
			i = i + 1 -- 1088
		end -- 1088
	end -- 1088
end -- 1032
function LowpolyScene.prototype.placeForegroundOccluder(self, worldArt, slotKey, instanceKey, x0, x1, y0, y1, wz, opts) -- 1112
	if opts == nil then -- 1112
		opts = {} -- 1121
	end -- 1121
	local pBL = self:project(x0, y0, wz) -- 1123
	local pTR = self:project(x1, y1, wz) -- 1124
	local w = math.abs(pTR.x - pBL.x) -- 1125
	local h = math.abs(pTR.y - pBL.y) -- 1126
	if w < 1 or h < 1 then -- 1126
		return false -- 1128
	end -- 1128
	return worldArt:tryPlace( -- 1130
		slotKey, -- 1131
		instanceKey, -- 1132
		(pBL.x + pTR.x) * 0.5, -- 1133
		math.min(pBL.y, pTR.y), -- 1134
		w, -- 1135
		h, -- 1136
		{ -- 1137
			color = opts.color or Color(28, 32, 42, 255), -- 1138
			opacity = opts.opacity or 0.92, -- 1139
			layer = opts.layer or 5200 -- 1140
		} -- 1140
	) -- 1140
end -- 1112
function LowpolyScene.prototype.flush(self, draw, glowDraw) -- 1146
	if #self.faces > 1 then -- 1146
		__TS__ArraySort( -- 1148
			self.faces, -- 1148
			function(____, a, b) -- 1148
				if a.bucket ~= b.bucket then -- 1148
					return a.bucket - b.bucket -- 1150
				end -- 1150
				if math.abs(a.sortZ - b.sortZ) > 0.001 then -- 1150
					return b.sortZ - a.sortZ -- 1153
				end -- 1153
				return a.sortBias - b.sortBias -- 1155
			end -- 1148
		) -- 1148
	end -- 1148
	local i = 0 -- 1159
	do -- 1159
		i = 0 -- 1160
		while i < #self.faces do -- 1160
			local f = self.faces[i + 1] -- 1161
			if #f.pts == 3 then -- 1161
				draw:drawVertices({ -- 1163
					{ -- 1164
						Vec2(f.pts[1].x, f.pts[1].y), -- 1164
						f.cols[1] -- 1164
					}, -- 1164
					{ -- 1165
						Vec2(f.pts[2].x, f.pts[2].y), -- 1165
						f.cols[2] -- 1165
					}, -- 1165
					{ -- 1166
						Vec2(f.pts[3].x, f.pts[3].y), -- 1166
						f.cols[3] -- 1166
					} -- 1166
				}) -- 1166
			elseif #f.pts == 4 then -- 1166
				local v0 = Vec2(f.pts[1].x, f.pts[1].y) -- 1169
				local v1 = Vec2(f.pts[2].x, f.pts[2].y) -- 1170
				local v2 = Vec2(f.pts[3].x, f.pts[3].y) -- 1171
				local v3 = Vec2(f.pts[4].x, f.pts[4].y) -- 1172
				draw:drawVertices({{v0, f.cols[1]}, {v1, f.cols[2]}, {v2, f.cols[3]}}) -- 1173
				draw:drawVertices({{v0, f.cols[1]}, {v2, f.cols[3]}, {v3, f.cols[4]}}) -- 1178
			end -- 1178
			if f.edgeCol ~= nil and f.edgeWidth > 0 then -- 1178
				local count = #f.pts -- 1185
				local k = 0 -- 1186
				do -- 1186
					k = 0 -- 1187
					while k < count do -- 1187
						local a = f.pts[k + 1] -- 1188
						local b = f.pts[(k + 1) % count + 1] -- 1189
						draw:drawSegment( -- 1190
							Vec2(a.x, a.y), -- 1190
							Vec2(b.x, b.y), -- 1190
							f.edgeWidth * 0.5, -- 1190
							f.edgeCol -- 1190
						) -- 1190
						k = k + 1 -- 1187
					end -- 1187
				end -- 1187
			end -- 1187
			if f.topHighlight ~= nil then -- 1187
				local hl = f.topHighlight -- 1194
				draw:drawSegment( -- 1195
					Vec2(hl[1].x, hl[1].y), -- 1195
					Vec2(hl[2].x, hl[2].y), -- 1195
					1.15, -- 1195
					hl[3] -- 1195
				) -- 1195
			end -- 1195
			i = i + 1 -- 1160
		end -- 1160
	end -- 1160
	if glowDraw ~= nil and #self.glows > 0 then -- 1160
		do -- 1160
			i = 0 -- 1200
			while i < #self.glows do -- 1200
				local g = self.glows[i + 1] -- 1201
				if #g.pts == 4 then -- 1201
					local v0 = Vec2(g.pts[1].x, g.pts[1].y) -- 1203
					local v1 = Vec2(g.pts[2].x, g.pts[2].y) -- 1204
					local v2 = Vec2(g.pts[3].x, g.pts[3].y) -- 1205
					local v3 = Vec2(g.pts[4].x, g.pts[4].y) -- 1206
					glowDraw:drawVertices({{v0, g.cols[1]}, {v1, g.cols[2]}, {v2, g.cols[3]}}) -- 1207
					glowDraw:drawVertices({{v0, g.cols[1]}, {v2, g.cols[3]}, {v3, g.cols[4]}}) -- 1212
				end -- 1212
				i = i + 1 -- 1200
			end -- 1200
		end -- 1200
	end -- 1200
	self.faces = {} -- 1221
	self.glows = {} -- 1222
end -- 1146
--- 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
-- 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
-- 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
function ____exports.buildOutsideJettyLowpoly(scene, room, actorX, actorY, cartAxle, time) -- 1231
	scene:addDistantRidge( -- 1240
		{ -- 1241
			{x = room.minX - 180, y = 125}, -- 1242
			{x = room.minX + 120, y = 196}, -- 1243
			{x = room.minX + 420, y = 162}, -- 1244
			{x = room.minX + 760, y = 224}, -- 1245
			{x = room.maxX + 220, y = 150} -- 1246
		}, -- 1246
		-40, -- 1246
		420, -- 1249
		____exports.MING_MATERIALS.distantHill, -- 1250
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1251
	) -- 1251
	scene:addFogBand( -- 1253
		room.minX - 240, -- 1253
		room.maxX + 240, -- 1253
		-30, -- 1253
		175, -- 1253
		290, -- 1253
		scene.light.fogColor, -- 1253
		0.56, -- 1253
		0.04, -- 1253
		{bucket = ____exports.LP_BUCKET.BACKDROP} -- 1253
	) -- 1253
	local i = 0 -- 1258
	do -- 1258
		i = 0 -- 1259
		while i < #room.floors do -- 1259
			local fl = room.floors[i + 1] -- 1260
			local isMain = fl.y <= 0.1 -- 1261
			if isMain then -- 1261
				scene:addBox({ -- 1263
					x0 = fl.x0, -- 1264
					x1 = fl.x1, -- 1265
					y0 = -48, -- 1266
					y1 = fl.y, -- 1267
					z0 = -26, -- 1268
					z1 = 88, -- 1269
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1270
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1271
					highlightTopEdge = true -- 1272
				}) -- 1272
			else -- 1272
				scene:addPlankDeck( -- 1276
					fl.x0, -- 1276
					fl.x1, -- 1276
					fl.y, -- 1276
					-24, -- 1276
					52, -- 1276
					5, -- 1276
					11, -- 1276
					____exports.MING_MATERIALS.mingTimber, -- 1276
					{bucket = ____exports.LP_BUCKET.WALK_DECK, withPosts = true, postBottomY = 0} -- 1276
				) -- 1276
			end -- 1276
			i = i + 1 -- 1259
		end -- 1259
	end -- 1259
	do -- 1259
		i = 0 -- 1285
		while i < #room.stairs do -- 1285
			scene:addStairFlight( -- 1286
				room.stairs[i + 1], -- 1286
				14, -- 1286
				76, -- 1286
				____exports.MING_MATERIALS.mingStoneStep, -- 1286
				{bucket = ____exports.LP_BUCKET.MIDGROUND, baseY = 0} -- 1286
			) -- 1286
			i = i + 1 -- 1285
		end -- 1285
	end -- 1285
	do -- 1285
		i = 0 -- 1293
		while i < #room.solids do -- 1293
			local s = room.solids[i + 1] -- 1294
			scene:addBox({ -- 1295
				x0 = s.x, -- 1296
				x1 = s.x + s.w, -- 1297
				y0 = s.y, -- 1298
				y1 = s.y + s.h, -- 1299
				z0 = -8, -- 1300
				z1 = 72, -- 1301
				material = ____exports.MING_MATERIALS.mingBrick, -- 1302
				bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1303
				highlightTopEdge = true -- 1304
			}) -- 1304
			if s.y > 10 then -- 1304
				scene:addBox({ -- 1307
					x0 = s.x, -- 1308
					x1 = s.x + 18, -- 1309
					y0 = 0, -- 1310
					y1 = s.y, -- 1311
					z0 = 32, -- 1312
					z1 = 72, -- 1313
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1314
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1315
					sortBias = -0.08, -- 1316
					edgeWidth = 0.7 -- 1317
				}) -- 1317
				scene:addBox({ -- 1319
					x0 = s.x + s.w - 18, -- 1320
					x1 = s.x + s.w, -- 1321
					y0 = 0, -- 1322
					y1 = s.y, -- 1323
					z0 = 32, -- 1324
					z1 = 72, -- 1325
					material = ____exports.MING_MATERIALS.mingBrickDark, -- 1326
					bucket = ____exports.LP_BUCKET.MIDGROUND, -- 1327
					sortBias = -0.08, -- 1328
					edgeWidth = 0.7 -- 1329
				}) -- 1329
			end -- 1329
			i = i + 1 -- 1293
		end -- 1293
	end -- 1293
	local arch = room.arch -- 1335
	if arch.h > 0 and arch.x1 > arch.x0 then -- 1335
		scene:addBeveledFrame( -- 1337
			arch.x0, -- 1337
			arch.x1, -- 1337
			arch.y, -- 1337
			arch.y + arch.h, -- 1337
			22, -- 1337
			18, -- 1337
			-10, -- 1337
			64, -- 1337
			____exports.MING_MATERIALS.mingStoneStep, -- 1337
			{ -- 1337
				bucket = ____exports.LP_BUCKET.WALK_DECK, -- 1338
				innerRimLight = rgba(176, 206, 228, 255), -- 1339
				innerRimStrength = 0.45 -- 1340
			} -- 1340
		) -- 1340
	end -- 1340
	local c = room.cart -- 1345
	if c.bodyW > 0 then -- 1345
		scene:addContactShadow( -- 1347
			cartAxle, -- 1347
			c.baseY, -- 1347
			c.bodyW * 0.62, -- 1347
			14, -- 1347
			0.7, -- 1347
			{bucket = ____exports.LP_BUCKET.PROP} -- 1347
		) -- 1347
		local clothX = cartAxle - c.bodyW * 0.5 -- 1348
		local clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH -- 1349
		local sway = math.sin(time * 3.1) * 5.5 -- 1350
		scene:addTri3D( -- 1351
			____exports.vec3(clothX, clothTop, -4), -- 1352
			____exports.vec3(clothX + 9, clothTop, -4), -- 1353
			____exports.vec3(clothX - 5 + sway, clothTop - 22, -6), -- 1354
			____exports.MING_MATERIALS.mingRedCloth, -- 1355
			{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.4, edgeWidth = 0.9} -- 1356
		) -- 1356
	end -- 1356
	scene:addContactShadow( -- 1361
		actorX, -- 1361
		actorY, -- 1361
		15, -- 1361
		11, -- 1361
		0.78, -- 1361
		{bucket = ____exports.LP_BUCKET.PROP, sortBias = 0.5} -- 1361
	) -- 1361
end -- 1231
return ____exports -- 1231