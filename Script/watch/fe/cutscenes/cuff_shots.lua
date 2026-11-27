-- [ts]: cuff_shots.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local Color = ____Dora.Color -- 21
local Rect = ____Dora.Rect -- 21
local Vec2 = ____Dora.Vec2 -- 21
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 27
local G05_PIXEL_RETURN_END = ____gate_transition.G05_PIXEL_RETURN_END -- 28
local G05_PIXEL_RETURN_START = ____gate_transition.G05_PIXEL_RETURN_START -- 29
local createGateTransitionPlugin = ____gate_transition.createGateTransitionPlugin -- 31
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 33
local clamp01 = ____lowpoly.clamp01 -- 33
local smoothstep = ____lowpoly.smoothstep -- 33
local ____theme = require("Script.watch.fe.theme") -- 34
local PALETTE = ____theme.PALETTE -- 35
local drawHairline = ____theme.drawHairline -- 37
local drawSilkVeil = ____theme.drawSilkVeil -- 38
local fillRadialGlow = ____theme.fillRadialGlow -- 39
local fillVGradRect = ____theme.fillVGradRect -- 40
local lerpRGBA = ____theme.lerpRGBA -- 41
local rgba = ____theme.rgba -- 42
local toColor = ____theme.toColor -- 43
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 82
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 83
local LINE_G05 = "「我们走吧。」" -- 84
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 87
	indigoBase = rgba(34, 52, 74, 255), -- 88
	indigoShadow = rgba(18, 28, 42, 255), -- 89
	indigoFold = rgba(54, 78, 104, 255), -- 90
	patchDark = rgba(24, 38, 56, 255), -- 91
	hemEdge = rgba(68, 92, 118, 255), -- 92
	armWrapLinen = rgba(154, 142, 120, 255), -- 93
	armWrapShadow = rgba(102, 92, 78, 255), -- 94
	stitchThread = rgba(232, 224, 204, 255), -- 96
	stitchPinhole = rgba(14, 19, 28, 255), -- 97
	skinBase = rgba(188, 146, 116, 255), -- 98
	skinShadow = rgba(138, 102, 78, 255), -- 99
	skinLight = rgba(216, 178, 148, 255), -- 100
	childSkin = rgba(226, 196, 170, 255), -- 101
	childSkinShadow = rgba(176, 144, 120, 255), -- 102
	childSleeve = rgba(164, 142, 114, 255), -- 103
	childCord = rgba(168, 56, 52, 255) -- 104
} -- 104
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 107
	local sx = lx * scale -- 108
	local sy = ly * scale -- 109
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 110
end -- 107
local function tinted(base, warmth, opacity) -- 113
	local warmTarget = rgba( -- 114
		math.min(255, base.r + 22), -- 115
		math.min(255, base.g + 12), -- 116
		math.max(0, base.b - 10), -- 117
		base.a -- 118
	) -- 118
	local mixed = lerpRGBA( -- 120
		base, -- 120
		warmTarget, -- 120
		clamp01(warmth) -- 120
	) -- 120
	return toColor( -- 121
		mixed, -- 121
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 121
	) -- 121
end -- 113
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 128
	local op = clamp01(opts.opacity or 1) -- 133
	if op <= 0.01 then -- 133
		return -- 135
	end -- 135
	local ox = opts.wristX -- 137
	local oy = opts.wristY -- 138
	local s = math.max(0.2, opts.scale) -- 139
	local cosA = math.cos(opts.angleRad) -- 140
	local sinA = math.sin(opts.angleRad) -- 141
	local w = clamp01(opts.warmth or 0) -- 142
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 143
	local function pt(lx, ly) -- 144
		return rotPt( -- 144
			ox, -- 144
			oy, -- 144
			lx, -- 144
			ly, -- 144
			cosA, -- 144
			sinA, -- 144
			s -- 144
		) -- 144
	end -- 144
	local cuffFront = 6 - pull -- 147
	draw:drawPolygon( -- 148
		{ -- 148
			pt(-250, -48), -- 149
			pt(cuffFront, -36), -- 150
			pt(cuffFront, 38), -- 151
			pt(-250, 52) -- 152
		}, -- 152
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 153
		1.4, -- 153
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 153
	) -- 153
	draw:drawPolygon( -- 156
		{ -- 156
			pt(-250, -48), -- 157
			pt(cuffFront, -36), -- 158
			pt(cuffFront, -8), -- 159
			pt(-250, -14) -- 160
		}, -- 160
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 161
	) -- 161
	draw:drawPolygon( -- 164
		{ -- 164
			pt(-230, 14), -- 165
			pt(cuffFront - 6, 10), -- 166
			pt(cuffFront - 4, 32), -- 167
			pt(-230, 40) -- 168
		}, -- 168
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 169
	) -- 169
	draw:drawSegment( -- 170
		pt(-185, 16), -- 170
		pt(cuffFront - 18, 12), -- 170
		1.2 * s, -- 170
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 170
	) -- 170
	draw:drawSegment( -- 171
		pt(-160, -10), -- 171
		pt(cuffFront - 26, -6), -- 171
		1.1 * s, -- 171
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 171
	) -- 171
	draw:drawPolygon( -- 174
		{ -- 174
			pt(cuffFront - 8, -28), -- 175
			pt(cuffFront + 16, -24), -- 176
			pt(cuffFront + 16, 26), -- 177
			pt(cuffFront - 8, 28) -- 178
		}, -- 178
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 179
		1, -- 179
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 179
	) -- 179
	draw:drawSegment( -- 180
		pt(cuffFront + 3, -25), -- 180
		pt(cuffFront + 7, 25), -- 180
		1.3 * s, -- 180
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 180
	) -- 180
	draw:drawPolygon( -- 183
		{ -- 183
			pt(cuffFront - 16, -37), -- 184
			pt(cuffFront + 2, -36), -- 185
			pt(cuffFront + 2, 38), -- 186
			pt(cuffFront - 16, 39) -- 187
		}, -- 187
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 188
		1.3, -- 188
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 188
	) -- 188
	local pX0 = cuffFront - 72 -- 191
	local pX1 = cuffFront - 18 -- 192
	local pY0 = -16 -- 193
	local pY1 = 22 -- 194
	draw:drawPolygon( -- 195
		{ -- 195
			pt(pX0, pY0), -- 196
			pt(pX1, pY0 + 3), -- 197
			pt(pX1 - 2, pY1), -- 198
			pt(pX0 + 3, pY1 - 2) -- 199
		}, -- 199
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 200
		1.1, -- 200
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 200
	) -- 200
	local seamStartX = pX0 + 6 -- 203
	local seamStartY = pY0 + 5 -- 204
	local seamEndX = pX1 - 7 -- 205
	local seamEndY = pY1 - 5 -- 206
	draw:drawSegment( -- 207
		pt(seamStartX, seamStartY), -- 208
		pt(seamEndX, seamEndY), -- 209
		1.5 * s, -- 210
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 211
	) -- 211
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 214
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 215
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 216
	local stitches = 6 -- 217
	local k = 0 -- 218
	do -- 218
		k = 0 -- 219
		while k < stitches do -- 219
			local t = (k + 0.5) / stitches -- 220
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 221
			local my = seamStartY + (seamEndY - seamStartY) * t -- 222
			local nx = -4.8 -- 223
			local ny = 6.2 -- 224
			local a = pt(mx - nx, my - ny) -- 225
			local b = pt(mx + nx, my + ny) -- 226
			draw:drawDot(a, 1.3 * s, pinCol) -- 227
			draw:drawDot(b, 1.3 * s, pinCol) -- 228
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 229
			if hl > 0.05 then -- 229
				glow:drawSegment( -- 231
					a, -- 231
					b, -- 231
					2.4 * s, -- 231
					toColor( -- 231
						____exports.CUFF_PALETTE.stitchThread, -- 231
						math.floor(74 * hl * op + 0.5) -- 231
					) -- 231
				) -- 231
			end -- 231
			k = k + 1 -- 219
		end -- 219
	end -- 219
	local handBase = cuffFront + 14 -- 236
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 237
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 238
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 239
	if opts.pose == "wipe" then -- 239
		draw:drawPolygon( -- 243
			{ -- 243
				pt(handBase - 4, -20), -- 244
				pt(handBase + 46, -24), -- 245
				pt(handBase + 54, 4), -- 246
				pt(handBase + 38, 22), -- 247
				pt(handBase - 4, 20) -- 248
			}, -- 248
			skinCol, -- 249
			1.1, -- 249
			skinSh -- 249
		) -- 249
		draw:drawSegment( -- 250
			pt(handBase + 16, -2), -- 250
			pt(handBase + 52, -6), -- 250
			1.4 * s, -- 250
			skinSh -- 250
		) -- 250
		draw:drawSegment( -- 251
			pt(handBase + 14, 10), -- 251
			pt(handBase + 46, 8), -- 251
			1.4 * s, -- 251
			skinSh -- 251
		) -- 251
	elseif opts.pose == "pinch" then -- 251
		draw:drawPolygon( -- 254
			{ -- 254
				pt(handBase - 4, -22), -- 255
				pt(handBase + 44, -18), -- 256
				pt(handBase + 54, 6), -- 257
				pt(handBase + 28, 26), -- 258
				pt(handBase - 4, 22) -- 259
			}, -- 259
			skinCol, -- 260
			1.1, -- 260
			skinSh -- 260
		) -- 260
		draw:drawSegment( -- 261
			pt(handBase + 24, 16), -- 261
			pt(handBase + 52, 4), -- 261
			6.2 * s, -- 261
			skinHi -- 261
		) -- 261
		draw:drawSegment( -- 262
			pt(handBase + 30, -14), -- 262
			pt(handBase + 54, -4), -- 262
			5.6 * s, -- 262
			skinCol -- 262
		) -- 262
	elseif opts.pose == "clasp" then -- 262
		draw:drawPolygon( -- 265
			{ -- 265
				pt(handBase - 2, -22), -- 266
				pt(handBase + 52, -20), -- 267
				pt(handBase + 66, 2), -- 268
				pt(handBase + 44, 26), -- 269
				pt(handBase - 2, 22) -- 270
			}, -- 270
			skinCol, -- 271
			1.2, -- 271
			skinSh -- 271
		) -- 271
		draw:drawSegment( -- 272
			pt(handBase + 26, 20), -- 272
			pt(handBase + 58, 12), -- 272
			6.5 * s, -- 272
			skinHi -- 272
		) -- 272
		draw:drawSegment( -- 273
			pt(handBase + 46, -14), -- 273
			pt(handBase + 72, -10), -- 273
			5.2 * s, -- 273
			skinCol -- 273
		) -- 273
		draw:drawSegment( -- 274
			pt(handBase + 48, -2), -- 274
			pt(handBase + 76, 1), -- 274
			5.4 * s, -- 274
			skinCol -- 274
		) -- 274
	else -- 274
		local reachExt = opts.pose == "reach" and 10 or 0 -- 277
		draw:drawPolygon( -- 278
			{ -- 278
				pt(handBase - 4, -20), -- 279
				pt(handBase + 44 + reachExt, -18), -- 280
				pt(handBase + 56 + reachExt, 4), -- 281
				pt(handBase + 34 + reachExt * 0.5, 24), -- 282
				pt(handBase - 4, 20) -- 283
			}, -- 283
			skinCol, -- 284
			1.1, -- 284
			skinSh -- 284
		) -- 284
		draw:drawSegment( -- 286
			pt(handBase + 42 + reachExt, -14), -- 286
			pt(handBase + 74 + reachExt, -16), -- 286
			4.6 * s, -- 286
			skinCol -- 286
		) -- 286
		draw:drawSegment( -- 287
			pt(handBase + 46 + reachExt, -4), -- 287
			pt(handBase + 80 + reachExt, -3), -- 287
			4.8 * s, -- 287
			skinCol -- 287
		) -- 287
		draw:drawSegment( -- 288
			pt(handBase + 44 + reachExt, 6), -- 288
			pt(handBase + 76 + reachExt, 9), -- 288
			4.6 * s, -- 288
			skinCol -- 288
		) -- 288
		draw:drawSegment( -- 289
			pt(handBase + 26 + reachExt * 0.5, 18), -- 289
			pt(handBase + 56 + reachExt * 0.6, 28), -- 289
			5.2 * s, -- 289
			skinHi -- 289
		) -- 289
	end -- 289
end -- 128
--- 绘制小满伸出的小手（含腕上暗红指南针布套短绳）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord) -- 294
	if withCompassCord == nil then -- 294
		withCompassCord = true -- 302
	end -- 302
	local op = clamp01(opacity) -- 304
	if op <= 0.01 then -- 304
		return -- 306
	end -- 306
	local cosA = math.cos(angleRad) -- 308
	local sinA = math.sin(angleRad) -- 309
	local s = math.max(0.2, scale) -- 310
	local function pt(lx, ly) -- 311
		return rotPt( -- 311
			ox, -- 311
			oy, -- 311
			lx, -- 311
			ly, -- 311
			cosA, -- 311
			sinA, -- 311
			s -- 311
		) -- 311
	end -- 311
	local skin = toColor( -- 312
		____exports.CUFF_PALETTE.childSkin, -- 312
		math.floor(255 * op + 0.5) -- 312
	) -- 312
	local sh = toColor( -- 313
		____exports.CUFF_PALETTE.childSkinShadow, -- 313
		math.floor(255 * op + 0.5) -- 313
	) -- 313
	local sleeve = toColor( -- 314
		____exports.CUFF_PALETTE.childSleeve, -- 314
		math.floor(255 * op + 0.5) -- 314
	) -- 314
	if pose == "two_fingers" then -- 314
		draw:drawSegment( -- 318
			pt(-18, -4), -- 318
			pt(18, -5), -- 318
			5 * s, -- 318
			skin -- 318
		) -- 318
		draw:drawSegment( -- 319
			pt(-16, 6), -- 319
			pt(22, 7), -- 319
			5 * s, -- 319
			skin -- 319
		) -- 319
		draw:drawDot( -- 320
			pt(18, -5), -- 320
			2.5 * s, -- 320
			sh -- 320
		) -- 320
		draw:drawDot( -- 321
			pt(22, 7), -- 321
			2.5 * s, -- 321
			sh -- 321
		) -- 321
		return -- 322
	end -- 322
	draw:drawPolygon( -- 326
		{ -- 326
			pt(-135, -24), -- 327
			pt(-6, -18), -- 328
			pt(-6, 18), -- 329
			pt(-135, 26) -- 330
		}, -- 330
		sleeve, -- 331
		1.1, -- 331
		sh -- 331
	) -- 331
	if withCompassCord then -- 331
		draw:drawSegment( -- 335
			pt(-10, -18), -- 335
			pt(-4, 18), -- 335
			2.6 * s, -- 335
			toColor( -- 335
				____exports.CUFF_PALETTE.childCord, -- 335
				math.floor(235 * op + 0.5) -- 335
			) -- 335
		) -- 335
		draw:drawSegment( -- 336
			pt(-4, -18), -- 336
			pt(2, 18), -- 336
			2.2 * s, -- 336
			toColor( -- 336
				____exports.CUFF_PALETTE.childCord, -- 336
				math.floor(200 * op + 0.5) -- 336
			) -- 336
		) -- 336
	end -- 336
	draw:drawPolygon( -- 340
		{ -- 340
			pt(-4, -15), -- 341
			pt(28, -14), -- 342
			pt(34, 2), -- 343
			pt(22, 17), -- 344
			pt(-4, 15) -- 345
		}, -- 345
		skin, -- 346
		1, -- 346
		sh -- 346
	) -- 346
	if pose == "clutch" or pose == "clasp" then -- 346
		draw:drawSegment( -- 350
			pt(24, -11), -- 350
			pt(44, -6), -- 350
			4 * s, -- 350
			skin -- 350
		) -- 350
		draw:drawSegment( -- 351
			pt(26, -2), -- 351
			pt(47, 2), -- 351
			4.2 * s, -- 351
			skin -- 351
		) -- 351
		draw:drawSegment( -- 352
			pt(24, 6), -- 352
			pt(43, 9), -- 352
			4 * s, -- 352
			skin -- 352
		) -- 352
		draw:drawSegment( -- 353
			pt(16, 14), -- 353
			pt(34, 16), -- 353
			4.2 * s, -- 353
			skin -- 353
		) -- 353
	else -- 353
		draw:drawSegment( -- 356
			pt(26, -12), -- 356
			pt(52, -16), -- 356
			3.6 * s, -- 356
			skin -- 356
		) -- 356
		draw:drawSegment( -- 357
			pt(29, -4), -- 357
			pt(57, -5), -- 357
			3.8 * s, -- 357
			skin -- 357
		) -- 357
		draw:drawSegment( -- 358
			pt(28, 4), -- 358
			pt(54, 7), -- 358
			3.6 * s, -- 358
			skin -- 358
		) -- 358
		draw:drawSegment( -- 359
			pt(24, 11), -- 359
			pt(46, 17), -- 359
			3.4 * s, -- 359
			skin -- 359
		) -- 359
		draw:drawSegment( -- 360
			pt(14, 15), -- 360
			pt(34, 26), -- 360
			4 * s, -- 360
			skin -- 360
		) -- 360
	end -- 360
end -- 294
--- 仅在 G05 重逢抬镜后绘制序章像素风风格的蹲姿周戍近景（复用真实像素立绘，与本体画风 100% 统一）
local function drawZhouShuReunionPortrait(draw, inkDraw, art, glow, cx, cy, scale, alpha) -- 365
	local a = clamp01(alpha) -- 375
	if a <= 0.01 then -- 375
		return -- 377
	end -- 377
	local s = scale -- 379
	local cardW = 212 * s -- 380
	local cardH = 248 * s -- 381
	local x0 = cx - cardW * 0.5 -- 382
	local y0 = cy - cardH * 0.5 -- 383
	fillVGradRect( -- 386
		draw, -- 387
		x0, -- 388
		y0, -- 389
		cardW, -- 390
		cardH, -- 391
		Color( -- 392
			10, -- 392
			15, -- 392
			24, -- 392
			math.floor(224 * a + 0.5) -- 392
		), -- 392
		Color( -- 393
			22, -- 393
			34, -- 393
			52, -- 393
			math.floor(234 * a + 0.5) -- 393
		) -- 393
	) -- 393
	local placed = art:tryPlace( -- 396
		"soldier_offer", -- 397
		"g05_zhoushu_closeup", -- 398
		cx + 4 * s, -- 399
		y0 + 18 * s, -- 400
		156 * s, -- 401
		214 * s, -- 402
		{opacity = a, layer = 4} -- 403
	) -- 403
	if not placed then -- 403
		art:tryPlace( -- 406
			"soldier_idle", -- 407
			"g05_zhoushu_closeup", -- 408
			cx, -- 409
			y0 + 18 * s, -- 410
			156 * s, -- 411
			214 * s, -- 412
			{opacity = a, layer = 4} -- 413
		) -- 413
	end -- 413
	inkDraw:drawRect( -- 417
		Rect(x0, y0, cardW, cardH), -- 417
		Color(0, 0, 0, 0), -- 417
		1.1, -- 417
		toColor( -- 417
			PALETTE.silkDim, -- 417
			math.floor(165 * a + 0.5) -- 417
		) -- 417
	) -- 417
	inkDraw:drawRect( -- 418
		Rect(x0 + 4, y0 + 4, cardW - 8, cardH - 8), -- 418
		Color(0, 0, 0, 0), -- 418
		0.7, -- 418
		toColor( -- 418
			PALETTE.amber, -- 418
			math.floor(78 * a + 0.5) -- 418
		) -- 418
	) -- 418
	fillRadialGlow( -- 419
		glow, -- 419
		cx + 12 * s, -- 419
		cy + 22 * s, -- 419
		96 * s, -- 419
		96 * s, -- 419
		Color( -- 419
			214, -- 419
			224, -- 419
			236, -- 419
			math.floor(38 * a + 0.5) -- 419
		), -- 419
		Color(120, 148, 178, 0), -- 419
		16 -- 419
	) -- 419
end -- 365
____exports.CuffShotsPlugin = __TS__Class() -- 422
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 422
CuffShotsPlugin.name = "CuffShotsPlugin" -- 422
function CuffShotsPlugin.prototype.____constructor(self) -- 422
	self.id = "fe-01-cuff-shots" -- 423
	self.animTime = 0 -- 425
	self.prevPhase = "" -- 426
	self.activeShot = "" -- 427
	self.rehearsalShot = "" -- 430
	self.rehearsalTime = 0 -- 431
	self.rehearsalDuration = 3 -- 432
	self.rehearsalAutoAdvance = true -- 433
	self.p03Progress = 0 -- 436
	self.p05ExitTimer = -1 -- 437
	self.g05SleeveExtend = 0 -- 438
	self.g05ReunionElapsed = 0 -- 439
	self.g05LineTriggered = false -- 440
	self.g05AbortVisualCount = 0 -- 441
	self.lastReleasedAbortCount = 0 -- 442
end -- 422
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 444
	self.animTime = 0 -- 445
	self.prevPhase = p.phase -- 446
	self.activeShot = "" -- 447
	self.p03Progress = 0 -- 448
	self.p05ExitTimer = -1 -- 449
	self.g05SleeveExtend = 0 -- 450
	self.g05ReunionElapsed = 0 -- 451
	self.g05LineTriggered = false -- 452
	self.g05AbortVisualCount = 0 -- 453
	self.lastReleasedAbortCount = 0 -- 454
end -- 444
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 462
	self.rehearsalShot = shot -- 463
	if shot == "" then -- 463
		self.rehearsalTime = 0 -- 465
		self.rehearsalAutoAdvance = true -- 466
		return -- 467
	end -- 467
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 469
	if fixedTime ~= nil then -- 469
		self.rehearsalTime = math.max( -- 471
			0, -- 471
			math.min(self.rehearsalDuration, fixedTime) -- 471
		) -- 471
		self.rehearsalAutoAdvance = false -- 472
	else -- 472
		self.rehearsalTime = 0 -- 474
		self.rehearsalAutoAdvance = true -- 475
	end -- 475
end -- 462
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 479
	self:rehearseShot("") -- 480
end -- 479
function CuffShotsPlugin.prototype.getDebugState(self) -- 483
	return { -- 484
		activeShot = self.activeShot, -- 485
		rehearsalShot = self.rehearsalShot, -- 486
		rehearsalTime = self.rehearsalTime, -- 487
		rehearsalDuration = self.rehearsalDuration, -- 488
		p03Progress = self.p03Progress, -- 489
		p05ExitTimer = self.p05ExitTimer, -- 490
		g05SleeveExtend = self.g05SleeveExtend, -- 491
		g05ReunionElapsed = self.g05ReunionElapsed, -- 492
		g05LineTriggered = self.g05LineTriggered, -- 493
		g05AbortVisualCount = self.g05AbortVisualCount -- 494
	} -- 494
end -- 483
function CuffShotsPlugin.prototype.update(self, ctx) -- 498
	local p = ctx.p -- 499
	local view = ctx.view -- 500
	local dt = ctx.paused and 0 or ctx.worldDt -- 501
	self.animTime = self.animTime + dt -- 502
	if self.rehearsalShot ~= "" then -- 502
		self.activeShot = self.rehearsalShot -- 506
		if self.rehearsalAutoAdvance and dt > 0 then -- 506
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 508
		end -- 508
		if not ctx.paused then -- 508
			self:triggerRehearsalAudio(ctx) -- 511
		end -- 511
		self.prevPhase = p.phase -- 513
		return -- 514
	end -- 514
	self.activeShot = "" -- 517
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 517
		self.activeShot = "P03" -- 521
		self.p03Progress = clamp01(p.phaseTick / 60) -- 522
		if not ctx.paused and self.p03Progress >= 0.25 then -- 522
			ctx.audio:playOnce( -- 524
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 525
				"sfx", -- 526
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 527
				0.86, -- 528
				"cuff:p03:cloth_wipe_wood", -- 529
				p.ticks -- 530
			) -- 530
		end -- 530
		if not ctx.paused and self.p03Progress >= 0.62 then -- 530
			ctx.audio:playOnce( -- 534
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 535
				"sfx", -- 536
				"assets/audio/interact/compass_handover.wav", -- 537
				0.82, -- 538
				"cuff:p03:compass_handover", -- 539
				p.ticks -- 540
			) -- 540
		end -- 540
		self.prevPhase = p.phase -- 543
		return -- 544
	else -- 544
		self.p03Progress = 0 -- 546
	end -- 546
	if p.room.key == "gate" then -- 546
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 546
			self.p05ExitTimer = 0 -- 552
			if not ctx.paused then -- 552
				ctx.audio:playOnce( -- 554
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 555
					"sfx", -- 556
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 557
					0.92, -- 558
					"cuff:p05:gate_slam", -- 559
					p.ticks -- 560
				) -- 560
				ctx.audio:playOnce( -- 562
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 563
					"voice", -- 564
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 565
					0.88, -- 566
					"cuff:p05:line_farewell", -- 567
					p.ticks -- 568
				) -- 568
			end -- 568
		end -- 568
		if self.p05ExitTimer >= 0 then -- 568
			if p.phase ~= "gate-count" or view.countElapsedTicks > 90 then -- 568
				self.p05ExitTimer = -1 -- 574
			else -- 574
				if dt > 0 then -- 574
					self.p05ExitTimer = self.p05ExitTimer + dt -- 577
				end -- 577
				if self.p05ExitTimer >= 0.85 then -- 577
					self.p05ExitTimer = -1 -- 580
				else -- 580
					self.activeShot = "P05" -- 582
				end -- 582
			end -- 582
		end -- 582
	else -- 582
		self.p05ExitTimer = -1 -- 587
	end -- 587
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 591
	if inGateReunion then -- 591
		self.activeShot = "G05" -- 599
		local gr = view.gateReunion -- 600
		local completed = p.phase == "gate-hand" or gr.completed -- 601
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 601
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 604
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 605
			if not ctx.paused and view.isRehearsal then -- 605
				ctx.audio:playOnce( -- 607
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 608
					"sfx", -- 609
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 610
					0.72, -- 611
					"cuff:g05:reunion_release", -- 612
					p.ticks -- 613
				) -- 613
			end -- 613
		end -- 613
		if completed then -- 613
			self.g05SleeveExtend = 1 -- 619
			if dt > 0 then -- 619
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 621
			end -- 621
			if not ctx.paused and not self.g05LineTriggered then -- 621
				if view.isRehearsal then -- 621
					ctx.audio:playOnce( -- 625
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 626
						"sfx", -- 627
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 628
						0.88, -- 629
						"cuff:g05:hand_held", -- 630
						p.ticks -- 631
					) -- 631
				end -- 631
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 631
					self.g05LineTriggered = true -- 635
					ctx.audio:playOnce( -- 636
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 637
						"voice", -- 638
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 639
						0.94, -- 640
						"cuff:g05:line_reunion", -- 641
						p.ticks -- 642
					) -- 642
				end -- 642
			end -- 642
		else -- 642
			self.g05ReunionElapsed = 0 -- 647
			self.g05LineTriggered = false -- 648
			if gr.holding or gr.holdProgress > 0.001 then -- 648
				if gr.holdProgress >= self.g05SleeveExtend then -- 648
					self.g05SleeveExtend = gr.holdProgress -- 652
				elseif dt > 0 then -- 652
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 654
				end -- 654
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 654
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 658
			end -- 658
		end -- 658
	else -- 658
		self.g05SleeveExtend = 0 -- 662
		self.g05ReunionElapsed = 0 -- 663
		self.g05LineTriggered = false -- 664
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 665
	end -- 665
	self.prevPhase = p.phase -- 668
end -- 498
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 671
	local sid = ctx.events.roomSessionId -- 672
	local t = self.rehearsalTime -- 673
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 673
		ctx.audio:playOnce( -- 675
			"reh:p03:wipe:" .. tostring(sid), -- 675
			"sfx", -- 675
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 675
			0.88, -- 675
			"cuff:p03:cloth_wipe_wood", -- 675
			ctx.p.ticks -- 675
		) -- 675
	elseif self.rehearsalShot == "P05" then -- 675
		if t >= 0.9 then -- 675
			ctx.audio:playOnce( -- 678
				"reh:p05:line:" .. tostring(sid), -- 678
				"voice", -- 678
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 678
				0.9, -- 678
				"cuff:p05:line_farewell", -- 678
				ctx.p.ticks -- 678
			) -- 678
		end -- 678
		if t >= 2.75 then -- 678
			ctx.audio:playOnce( -- 681
				"reh:p05:slam:" .. tostring(sid), -- 681
				"sfx", -- 681
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 681
				0.94, -- 681
				"cuff:p05:gate_slam", -- 681
				ctx.p.ticks -- 681
			) -- 681
			ctx.audio:playLoop( -- 682
				"reh_p05_water", -- 682
				"water", -- 682
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 682
				0.42, -- 682
				ctx.p.ticks -- 682
			) -- 682
		end -- 682
	elseif self.rehearsalShot == "G05" then -- 682
		if t >= 0.05 then -- 682
			ctx.audio:playOnce( -- 686
				"reh:g05:knock1:" .. tostring(sid), -- 686
				"sfx", -- 686
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 686
				0.88, -- 686
				"knock:gate:1", -- 686
				ctx.p.ticks -- 686
			) -- 686
		end -- 686
		if t >= 0.25 then -- 686
			ctx.audio:playOnce( -- 689
				"reh:g05:knock2:" .. tostring(sid), -- 689
				"sfx", -- 689
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 689
				0.92, -- 689
				"knock:gate:2", -- 689
				ctx.p.ticks -- 689
			) -- 689
		end -- 689
		if t >= 1.55 then -- 689
			ctx.audio:playOnce( -- 692
				"reh:g05:clasp:" .. tostring(sid), -- 692
				"sfx", -- 692
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 692
				0.88, -- 692
				"cuff:g05:hand_held", -- 692
				ctx.p.ticks -- 692
			) -- 692
		end -- 692
		if t >= 2.35 then -- 692
			ctx.audio:playOnce( -- 695
				"reh:g05:line:" .. tostring(sid), -- 695
				"voice", -- 695
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 695
				0.94, -- 695
				"cuff:g05:line_reunion", -- 695
				ctx.p.ticks -- 695
			) -- 695
		end -- 695
	end -- 695
end -- 671
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 700
	if self.activeShot == "" then -- 700
		return false -- 708
	end -- 708
	local w = ctx.uiW -- 710
	local h = ctx.uiH -- 711
	if self.activeShot == "P03" then -- 711
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 714
		self:renderP03Shot( -- 717
			uiDraw, -- 717
			uiInkDraw, -- 717
			uiArt, -- 717
			uiGlow, -- 717
			ctx, -- 717
			w, -- 717
			h, -- 717
			prog -- 717
		) -- 717
		return true -- 718
	end -- 718
	if self.activeShot == "P05" then -- 718
		if self.rehearsalShot == "P05" then -- 718
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 723
			self:renderP05FullShot( -- 724
				uiDraw, -- 724
				uiInkDraw, -- 724
				uiArt, -- 724
				uiGlow, -- 724
				ctx, -- 724
				w, -- 724
				h, -- 724
				prog -- 724
			) -- 724
			return true -- 725
		end -- 725
		self:renderP05ExitBridge( -- 728
			uiDraw, -- 728
			uiInkDraw, -- 728
			uiArt, -- 728
			uiGlow, -- 728
			ctx, -- 728
			w, -- 728
			h, -- 728
			clamp01(self.p05ExitTimer / 0.85) -- 728
		) -- 728
		return false -- 729
	end -- 729
	if self.activeShot == "G05" then -- 729
		if self.rehearsalShot == "G05" then -- 729
			self:renderG05RehearsalShot( -- 734
				uiDraw, -- 734
				uiInkDraw, -- 734
				uiArt, -- 734
				uiGlow, -- 734
				ctx, -- 734
				w, -- 734
				h, -- 734
				self.rehearsalTime -- 734
			) -- 734
			return true -- 735
		end -- 735
		self:renderG05LiveShot( -- 737
			uiDraw, -- 737
			uiInkDraw, -- 737
			uiArt, -- 737
			uiGlow, -- 737
			ctx, -- 737
			w, -- 737
			h -- 737
		) -- 737
		return true -- 738
	end -- 738
	return false -- 741
end -- 700
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 750
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 760
	local boxW = math.min(w - 140, 820) -- 762
	local boxH = math.min(h - 190, 390) -- 763
	local bx = (w - boxW) * 0.5 -- 764
	local by = (h - boxH) * 0.5 + 14 -- 765
	uiDraw:drawRect( -- 767
		Rect(0, 0, w, h), -- 767
		Color( -- 767
			7, -- 767
			9, -- 767
			14, -- 767
			math.floor(135 * fade + 0.5) -- 767
		) -- 767
	) -- 767
	fillVGradRect( -- 769
		uiDraw, -- 769
		bx, -- 769
		by, -- 769
		boxW, -- 769
		boxH, -- 769
		Color( -- 769
			14, -- 769
			13, -- 769
			16, -- 769
			math.floor(248 * fade + 0.5) -- 769
		), -- 769
		Color( -- 769
			24, -- 769
			24, -- 769
			30, -- 769
			math.floor(248 * fade + 0.5) -- 769
		) -- 769
	) -- 769
	local rimY = by + boxH * 0.34 -- 771
	uiDraw:drawRect( -- 772
		Rect(bx, by, boxW, rimY - by), -- 772
		Color( -- 772
			54, -- 772
			40, -- 772
			30, -- 772
			math.floor(252 * fade + 0.5) -- 772
		) -- 772
	) -- 772
	uiDraw:drawSegment( -- 773
		Vec2(bx, rimY), -- 773
		Vec2(bx + boxW, rimY), -- 773
		2.2, -- 773
		Color( -- 773
			128, -- 773
			100, -- 773
			76, -- 773
			math.floor(220 * fade + 0.5) -- 773
		) -- 773
	) -- 773
	local crackX = bx + boxW * 0.72 -- 775
	uiDraw:drawRect( -- 776
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 776
		Color( -- 776
			8, -- 776
			9, -- 776
			13, -- 776
			math.floor(245 * fade + 0.5) -- 776
		) -- 776
	) -- 776
	uiDraw:drawRect( -- 777
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 777
		Color( -- 777
			46, -- 777
			35, -- 777
			26, -- 777
			math.floor(250 * fade + 0.5) -- 777
		) -- 777
	) -- 777
	local wipeT = smoothstep(0.3, 0.66, prog) -- 780
	local shardOffsets = {{ -- 781
		x = -72, -- 782
		y = 8, -- 782
		dx = 46, -- 782
		dy = -38, -- 782
		r = 9 -- 782
	}, { -- 782
		x = -34, -- 783
		y = 12, -- 783
		dx = 64, -- 783
		dy = -46, -- 783
		r = 7 -- 783
	}, { -- 783
		x = 4, -- 784
		y = 6, -- 784
		dx = 82, -- 784
		dy = -52, -- 784
		r = 10 -- 784
	}, { -- 784
		x = 32, -- 785
		y = 10, -- 785
		dx = 74, -- 785
		dy = -34, -- 785
		r = 6 -- 785
	}} -- 785
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 787
	if shardAlpha > 0.02 then -- 787
		local si = 0 -- 789
		do -- 789
			si = 0 -- 790
			while si < #shardOffsets do -- 790
				local sh = shardOffsets[si + 1] -- 791
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 792
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 793
				uiDraw:drawPolygon( -- 794
					{ -- 794
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 795
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 796
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 797
					}, -- 797
					Color( -- 798
						212, -- 798
						218, -- 798
						224, -- 798
						math.floor(235 * shardAlpha + 0.5) -- 798
					), -- 798
					0.9, -- 798
					Color( -- 798
						92, -- 798
						108, -- 798
						126, -- 798
						math.floor(200 * shardAlpha + 0.5) -- 798
					) -- 798
				) -- 798
				si = si + 1 -- 790
			end -- 790
		end -- 790
	end -- 790
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 803
	local handOut = smoothstep(0.7, 0.9, prog) -- 804
	if handOut > 0.05 then -- 804
		drawChildHand( -- 806
			uiDraw, -- 807
			crackX + 18 - handOut * 66, -- 808
			rimY + 52, -- 809
			math.pi, -- 810
			1.05, -- 811
			"open_fingers", -- 812
			fade * handOut, -- 813
			false -- 814
		) -- 814
	elseif fingerEnter > 0.02 then -- 814
		drawChildHand( -- 817
			uiDraw, -- 818
			crackX + 12 - fingerEnter * 24, -- 819
			rimY + 46, -- 820
			math.pi, -- 821
			1.08, -- 822
			"two_fingers", -- 823
			fade * fingerEnter, -- 824
			false -- 825
		) -- 825
	end -- 825
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 830
	if sleeveEnter > 0.01 then -- 830
		local reachT = smoothstep(0.66, 0.88, prog) -- 832
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 833
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 834
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 835
		local pose = reachT > 0.2 and "reach" or "wipe" -- 836
		____exports.drawPatchedCuff( -- 837
			uiDraw, -- 837
			uiGlow, -- 837
			{ -- 837
				wristX = wx, -- 838
				wristY = wy, -- 839
				angleRad = ang, -- 840
				scale = 1.06, -- 841
				pose = pose, -- 842
				opacity = fade * sleeveEnter, -- 843
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 844
				warmth = 0.18 -- 845
			} -- 845
		) -- 845
	end -- 845
	uiInkDraw:drawRect( -- 850
		Rect(bx, by, boxW, boxH), -- 850
		Color(0, 0, 0, 0), -- 850
		1, -- 850
		toColor( -- 850
			PALETTE.silkDim, -- 850
			math.floor(145 * fade + 0.5) -- 850
		) -- 850
	) -- 850
	drawSilkVeil( -- 851
		uiDraw, -- 851
		uiArt, -- 851
		"p03_sub_veil", -- 851
		w * 0.5, -- 851
		42, -- 851
		520, -- 851
		42, -- 851
		PALETTE.inkWash, -- 851
		0.82 * fade, -- 851
		-1 -- 851
	) -- 851
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 852
	ctx.texts:put( -- 855
		"sm", -- 855
		subText, -- 855
		w * 0.5, -- 855
		42, -- 855
		toColor(PALETTE.textBright), -- 855
		0.5, -- 855
		0.5, -- 855
		"Center", -- 855
		1, -- 855
		fade, -- 855
		0.08 -- 855
	) -- 855
end -- 750
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 864
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 874
	local boxW = math.min(w - 120, 860) -- 875
	local boxH = math.min(h - 180, 400) -- 876
	local bx = (w - boxW) * 0.5 -- 877
	local by = (h - boxH) * 0.5 + 14 -- 878
	uiDraw:drawRect( -- 880
		Rect(0, 0, w, h), -- 880
		Color( -- 880
			7, -- 880
			9, -- 880
			14, -- 880
			math.floor(145 * fade + 0.5) -- 880
		) -- 880
	) -- 880
	fillVGradRect( -- 882
		uiDraw, -- 882
		bx, -- 882
		by, -- 882
		boxW, -- 882
		boxH, -- 882
		Color( -- 882
			14, -- 882
			22, -- 882
			34, -- 882
			math.floor(248 * fade + 0.5) -- 882
		), -- 882
		Color( -- 882
			28, -- 882
			42, -- 882
			58, -- 882
			math.floor(248 * fade + 0.5) -- 882
		) -- 882
	) -- 882
	fillRadialGlow( -- 884
		uiGlow, -- 884
		bx + boxW * 0.66, -- 884
		by + boxH * 0.32, -- 884
		220, -- 884
		68, -- 884
		Color( -- 884
			152, -- 884
			194, -- 884
			224, -- 884
			math.floor(74 * fade + 0.5) -- 884
		), -- 884
		Color(40, 70, 108, 0), -- 884
		16 -- 884
	) -- 884
	local releaseT = smoothstep(0.68, 0.94, prog) -- 886
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 887
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 890
	local cuffY = by + boxH * 0.52 -- 891
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 892
		wristX = cuffX, -- 893
		wristY = cuffY, -- 894
		angleRad = -0.06, -- 895
		scale = 1.12, -- 896
		pose = pinchT > 0.25 and "pinch" or "open", -- 897
		opacity = fade * (1 - releaseT * 0.88), -- 898
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 899
		warmth = 0.12 -- 900
	}) -- 900
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 904
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 905
	drawChildHand( -- 906
		uiDraw, -- 907
		childHandX, -- 908
		childHandY, -- 909
		math.pi + 0.12, -- 910
		1.12, -- 911
		releaseT > 0.35 and "open_fingers" or "clutch", -- 912
		fade, -- 913
		true -- 914
	) -- 914
	if releaseT > 0.01 then -- 914
		local dropH = boxH * releaseT * 0.88 -- 919
		uiDraw:drawRect( -- 920
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 920
			Color( -- 920
				26, -- 920
				22, -- 920
				20, -- 920
				math.floor(238 * fade + 0.5) -- 920
			) -- 920
		) -- 920
		uiDraw:drawSegment( -- 921
			Vec2(bx, by + boxH - dropH), -- 921
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 921
			2.4, -- 921
			Color( -- 921
				118, -- 921
				104, -- 921
				88, -- 921
				math.floor(220 * fade + 0.5) -- 921
			) -- 921
		) -- 921
	end -- 921
	uiInkDraw:drawRect( -- 924
		Rect(bx, by, boxW, boxH), -- 924
		Color(0, 0, 0, 0), -- 924
		1, -- 924
		toColor( -- 924
			PALETTE.silkDim, -- 924
			math.floor(150 * fade + 0.5) -- 924
		) -- 924
	) -- 924
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 927
	if lineAlpha > 0.02 then -- 927
		drawSilkVeil( -- 929
			uiDraw, -- 929
			uiArt, -- 929
			"p05_sub_veil", -- 929
			w * 0.5, -- 929
			42, -- 929
			740, -- 929
			44, -- 929
			PALETTE.inkWash, -- 929
			0.86 * lineAlpha, -- 929
			-1 -- 929
		) -- 929
		drawHairline( -- 930
			uiInkDraw, -- 930
			uiArt, -- 930
			"p05_sub_line", -- 930
			w * 0.5, -- 930
			62, -- 930
			520, -- 930
			PALETTE.silkDim, -- 930
			0.52 * lineAlpha, -- 930
			true, -- 930
			2 -- 930
		) -- 930
		ctx.texts:put( -- 931
			"sm", -- 931
			LINE_P05, -- 931
			w * 0.5, -- 931
			42, -- 931
			toColor(PALETTE.textBright), -- 931
			0.5, -- 931
			0.5, -- 931
			"Center", -- 931
			0.8, -- 931
			lineAlpha, -- 931
			0.08 -- 931
		) -- 931
	end -- 931
end -- 864
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, _uiInkDraw, _uiArt, uiGlow, _ctx, w, h, t) -- 936
	local out = smoothstep(0, 1, t) -- 946
	local alpha = 1 - out -- 947
	if alpha <= 0.02 then -- 947
		return -- 949
	end -- 949
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 951
		wristX = w * 0.24 - out * 240, -- 952
		wristY = h * 0.4, -- 953
		angleRad = -0.05, -- 954
		scale = 0.92, -- 955
		pose = "open", -- 956
		opacity = alpha * 0.92, -- 957
		stitchHighlight = 0.45 -- 958
	}) -- 958
end -- 936
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 968
	local view = ctx.view -- 977
	local gr = view.gateReunion -- 978
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 979
	local ext = clamp01(self.g05SleeveExtend) -- 980
	if not completed then -- 980
		if ext > 0.008 then -- 980
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 986
			fillVGradRect( -- 987
				uiDraw, -- 987
				0, -- 987
				h * 0.28, -- 987
				w, -- 987
				h * 0.16, -- 987
				Color(8, 11, 18, 0), -- 987
				Color(8, 11, 18, veilA) -- 987
			) -- 987
			fillVGradRect( -- 988
				uiDraw, -- 988
				0, -- 988
				h * 0.44, -- 988
				w, -- 988
				h * 0.16, -- 988
				Color(8, 11, 18, veilA), -- 988
				Color(8, 11, 18, 0) -- 988
			) -- 988
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 990
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 991
			____exports.drawPatchedCuff( -- 992
				uiDraw, -- 992
				uiGlow, -- 992
				{ -- 992
					wristX = cuffX, -- 993
					wristY = cuffY, -- 994
					angleRad = -0.05, -- 995
					scale = 1.08, -- 996
					pose = ext > 0.82 and "clasp" or "reach", -- 997
					opacity = clamp01(0.32 + ext * 0.68), -- 998
					stitchHighlight = 0.35 + 0.6 * ext -- 999
				} -- 999
			) -- 999
			local childX = w * 0.64 - ext * (w * 0.13) -- 1003
			local childY = h * 0.41 + ext * 14 -- 1004
			drawChildHand( -- 1005
				uiDraw, -- 1006
				childX, -- 1007
				childY, -- 1008
				math.pi + 0.08, -- 1009
				1.06, -- 1010
				ext > 0.88 and "clasp" or "reach_up", -- 1011
				clamp01(0.25 + ext * 0.75), -- 1012
				true -- 1013
			) -- 1013
			local barW = 240 -- 1017
			local bx0 = w * 0.5 - barW * 0.5 -- 1018
			local by0 = 32 -- 1019
			uiInkDraw:drawSegment( -- 1020
				Vec2(bx0, by0), -- 1020
				Vec2(bx0 + barW, by0), -- 1020
				1.2, -- 1020
				toColor(PALETTE.silkDim, 110) -- 1020
			) -- 1020
			uiInkDraw:drawSegment( -- 1021
				Vec2(bx0, by0), -- 1021
				Vec2(bx0 + barW * ext, by0), -- 1021
				2.4, -- 1021
				toColor(PALETTE.amberCore, 230) -- 1021
			) -- 1021
		else -- 1021
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1024
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1025
				wristX = -120 + peekPulse * 14, -- 1026
				wristY = h * 0.44, -- 1027
				angleRad = -0.04, -- 1028
				scale = 1.04, -- 1029
				pose = "open", -- 1030
				opacity = 0.36 + 0.22 * peekPulse, -- 1031
				stitchHighlight = 0.35 * peekPulse -- 1032
			}) -- 1032
		end -- 1032
		if view.assistHintsEnabled then -- 1032
			drawSilkVeil( -- 1038
				uiDraw, -- 1038
				uiArt, -- 1038
				"g05_assist_veil", -- 1038
				w * 0.5, -- 1038
				h - 26, -- 1038
				280, -- 1038
				28, -- 1038
				PALETTE.inkWash, -- 1038
				0.72, -- 1038
				-1 -- 1038
			) -- 1038
			ctx.texts:put( -- 1039
				"xs", -- 1039
				"按住 E 牵住伸来的袖口", -- 1039
				w * 0.5, -- 1039
				h - 26, -- 1039
				toColor(PALETTE.amberCore), -- 1039
				0.5, -- 1039
				0.5, -- 1039
				"Center", -- 1039
				1.2, -- 1039
				0.9, -- 1039
				0.08 -- 1039
			) -- 1039
		end -- 1039
		return -- 1041
	end -- 1041
	local t = self.g05ReunionElapsed -- 1045
	local claspPull = smoothstep(0, 0.35, t) -- 1046
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1047
	local armDropY = tilt * (h * 0.26) -- 1048
	local claspFade = 1 - smoothstep(0.95, 1.45, t) * 0.45 -- 1051
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1052
		wristX = w * 0.44, -- 1053
		wristY = h * 0.44 - armDropY, -- 1054
		angleRad = -0.05 + tilt * 0.22, -- 1055
		scale = 1.08, -- 1056
		pose = "clasp", -- 1057
		opacity = claspFade, -- 1058
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1059
		cuffPullBack = claspPull * 0.85, -- 1060
		warmth = tilt * 0.32 -- 1061
	}) -- 1061
	drawChildHand( -- 1063
		uiDraw, -- 1064
		w * 0.53, -- 1065
		h * 0.43 - armDropY, -- 1066
		math.pi + 0.05 - tilt * 0.14, -- 1067
		1.08, -- 1068
		"clasp", -- 1069
		claspFade, -- 1070
		true -- 1071
	) -- 1071
	local portraitAlpha = smoothstep(0.32, 0.88, t) -- 1075
	if portraitAlpha > 0.02 then -- 1075
		local py = h * 0.56 + (1 - portraitAlpha) * 26 -- 1077
		drawZhouShuReunionPortrait( -- 1078
			uiDraw, -- 1078
			uiInkDraw, -- 1078
			uiArt, -- 1078
			uiGlow, -- 1078
			w * 0.72, -- 1078
			py, -- 1078
			1, -- 1078
			portraitAlpha -- 1078
		) -- 1078
	end -- 1078
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1082
	if lineAlpha > 0.02 then -- 1082
		drawSilkVeil( -- 1084
			uiDraw, -- 1084
			uiArt, -- 1084
			"g05_line_veil", -- 1084
			w * 0.5, -- 1084
			42, -- 1084
			420, -- 1084
			44, -- 1084
			PALETTE.inkWash, -- 1084
			0.86 * lineAlpha, -- 1084
			-1 -- 1084
		) -- 1084
		drawHairline( -- 1085
			uiInkDraw, -- 1085
			uiArt, -- 1085
			"g05_line_bar", -- 1085
			w * 0.5, -- 1085
			62, -- 1085
			260, -- 1085
			PALETTE.amber, -- 1085
			0.58 * lineAlpha, -- 1085
			true, -- 1085
			2 -- 1085
		) -- 1085
		ctx.texts:put( -- 1086
			"sm", -- 1086
			LINE_G05, -- 1086
			w * 0.5, -- 1086
			42, -- 1086
			toColor(PALETTE.textBright), -- 1086
			0.5, -- 1086
			0.5, -- 1086
			"Center", -- 1086
			2.2, -- 1086
			lineAlpha, -- 1086
			0.08 -- 1086
		) -- 1086
	end -- 1086
end -- 968
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1091
	local holdExt = smoothstep(0.55, 1.45, t) -- 1102
	local tilt = smoothstep(1.55, 2.55, t) -- 1103
	local claspPull = smoothstep(1.4, 1.75, t) -- 1104
	local armDropY = tilt * (h * 0.24) -- 1105
	local boxW = math.min(w - 120, 860) -- 1107
	local boxH = math.min(h - 180, 400) -- 1108
	local bx = (w - boxW) * 0.5 -- 1109
	local by = (h - boxH) * 0.5 + 14 -- 1110
	uiDraw:drawRect( -- 1111
		Rect(0, 0, w, h), -- 1111
		Color(7, 9, 14, 150) -- 1111
	) -- 1111
	local bgTop = lerpRGBA( -- 1112
		rgba(16, 24, 36, 250), -- 1112
		rgba(20, 26, 36, 250), -- 1112
		tilt -- 1112
	) -- 1112
	local bgBot = lerpRGBA( -- 1113
		rgba(10, 15, 24, 250), -- 1113
		rgba(14, 18, 26, 250), -- 1113
		tilt -- 1113
	) -- 1113
	fillVGradRect( -- 1114
		uiDraw, -- 1114
		bx, -- 1114
		by, -- 1114
		boxW, -- 1114
		boxH, -- 1114
		toColor(bgBot), -- 1114
		toColor(bgTop) -- 1114
	) -- 1114
	if tilt > 0.05 then -- 1114
		drawZhouShuReunionPortrait( -- 1117
			uiDraw, -- 1117
			uiInkDraw, -- 1117
			uiArt, -- 1117
			uiGlow, -- 1117
			bx + boxW * 0.72, -- 1117
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1117
			0.92, -- 1117
			tilt -- 1117
		) -- 1117
	end -- 1117
	____exports.drawPatchedCuff( -- 1120
		uiDraw, -- 1120
		uiGlow, -- 1120
		{ -- 1120
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1121
			wristY = by + boxH * 0.52 - armDropY, -- 1122
			angleRad = -0.05 + tilt * 0.2, -- 1123
			scale = 1.06, -- 1124
			pose = t >= 1.4 and "clasp" or "reach", -- 1125
			opacity = clamp01(0.25 + holdExt * 0.75), -- 1126
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1127
			cuffPullBack = claspPull * 0.85, -- 1128
			warmth = tilt * 0.32 -- 1129
		} -- 1129
	) -- 1129
	drawChildHand( -- 1131
		uiDraw, -- 1132
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1133
		by + boxH * 0.48 - armDropY, -- 1134
		math.pi + 0.06, -- 1135
		1.06, -- 1136
		t >= 1.4 and "clasp" or "reach_up", -- 1137
		clamp01(0.35 + holdExt * 0.65), -- 1138
		true -- 1139
	) -- 1139
	uiInkDraw:drawRect( -- 1142
		Rect(bx, by, boxW, boxH), -- 1142
		Color(0, 0, 0, 0), -- 1142
		1, -- 1142
		toColor(PALETTE.silkDim, 145) -- 1142
	) -- 1142
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1144
	if lineAlpha > 0.02 then -- 1144
		drawSilkVeil( -- 1146
			uiDraw, -- 1146
			uiArt, -- 1146
			"g05_reh_veil", -- 1146
			w * 0.5, -- 1146
			42, -- 1146
			420, -- 1146
			44, -- 1146
			PALETTE.inkWash, -- 1146
			0.86 * lineAlpha, -- 1146
			-1 -- 1146
		) -- 1146
		drawHairline( -- 1147
			uiInkDraw, -- 1147
			uiArt, -- 1147
			"g05_reh_bar", -- 1147
			w * 0.5, -- 1147
			62, -- 1147
			260, -- 1147
			PALETTE.amber, -- 1147
			0.58 * lineAlpha, -- 1147
			true, -- 1147
			2 -- 1147
		) -- 1147
		ctx.texts:put( -- 1148
			"sm", -- 1148
			LINE_G05, -- 1148
			w * 0.5, -- 1148
			42, -- 1148
			toColor(PALETTE.textBright), -- 1148
			0.5, -- 1148
			0.5, -- 1148
			"Center", -- 1148
			2.2, -- 1148
			lineAlpha, -- 1148
			0.08 -- 1148
		) -- 1148
	end -- 1148
end -- 1091
function ____exports.createCuffShotsPlugin() -- 1153
	return __TS__New(____exports.CuffShotsPlugin) -- 1154
end -- 1153
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1161
	local gateTransition = createGateTransitionPlugin() -- 1165
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1166
	fe:registerPlugin(gateTransition) -- 1167
	fe:registerPlugin(cuffShots) -- 1168
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1169
end -- 1161
return ____exports -- 1161