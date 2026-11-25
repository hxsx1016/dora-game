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
		self.prevPhase = p.phase -- 533
		return -- 534
	else -- 534
		self.p03Progress = 0 -- 536
	end -- 536
	if p.room.key == "gate" then -- 536
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 536
			self.p05ExitTimer = 0 -- 542
			if not ctx.paused then -- 542
				ctx.audio:playOnce( -- 544
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 545
					"sfx", -- 546
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 547
					0.92, -- 548
					"cuff:p05:gate_slam", -- 549
					p.ticks -- 550
				) -- 550
				ctx.audio:playOnce( -- 552
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 553
					"voice", -- 554
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 555
					0.88, -- 556
					"cuff:p05:line_farewell", -- 557
					p.ticks -- 558
				) -- 558
			end -- 558
		end -- 558
		if self.p05ExitTimer >= 0 then -- 558
			if p.phase ~= "gate-count" or view.countElapsedTicks > 90 then -- 558
				self.p05ExitTimer = -1 -- 564
			else -- 564
				if dt > 0 then -- 564
					self.p05ExitTimer = self.p05ExitTimer + dt -- 567
				end -- 567
				if self.p05ExitTimer >= 0.85 then -- 567
					self.p05ExitTimer = -1 -- 570
				else -- 570
					self.activeShot = "P05" -- 572
				end -- 572
			end -- 572
		end -- 572
	else -- 572
		self.p05ExitTimer = -1 -- 577
	end -- 577
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 581
	if inGateReunion then -- 581
		self.activeShot = "G05" -- 589
		local gr = view.gateReunion -- 590
		local completed = p.phase == "gate-hand" or gr.completed -- 591
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 591
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 594
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 595
			if not ctx.paused and view.isRehearsal then -- 595
				ctx.audio:playOnce( -- 597
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 598
					"sfx", -- 599
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 600
					0.72, -- 601
					"cuff:g05:reunion_release", -- 602
					p.ticks -- 603
				) -- 603
			end -- 603
		end -- 603
		if completed then -- 603
			self.g05SleeveExtend = 1 -- 609
			if dt > 0 then -- 609
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 611
			end -- 611
			if not ctx.paused and not self.g05LineTriggered then -- 611
				if view.isRehearsal then -- 611
					ctx.audio:playOnce( -- 615
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 616
						"sfx", -- 617
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 618
						0.88, -- 619
						"cuff:g05:hand_held", -- 620
						p.ticks -- 621
					) -- 621
				end -- 621
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 621
					self.g05LineTriggered = true -- 625
					ctx.audio:playOnce( -- 626
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 627
						"voice", -- 628
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 629
						0.94, -- 630
						"cuff:g05:line_reunion", -- 631
						p.ticks -- 632
					) -- 632
				end -- 632
			end -- 632
		else -- 632
			self.g05ReunionElapsed = 0 -- 637
			self.g05LineTriggered = false -- 638
			if gr.holding or gr.holdProgress > 0.001 then -- 638
				if gr.holdProgress >= self.g05SleeveExtend then -- 638
					self.g05SleeveExtend = gr.holdProgress -- 642
				elseif dt > 0 then -- 642
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 644
				end -- 644
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 644
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 648
			end -- 648
		end -- 648
	else -- 648
		self.g05SleeveExtend = 0 -- 652
		self.g05ReunionElapsed = 0 -- 653
		self.g05LineTriggered = false -- 654
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 655
	end -- 655
	self.prevPhase = p.phase -- 658
end -- 498
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 661
	local sid = ctx.events.roomSessionId -- 662
	local t = self.rehearsalTime -- 663
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 663
		ctx.audio:playOnce( -- 665
			"reh:p03:wipe:" .. tostring(sid), -- 665
			"sfx", -- 665
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 665
			0.88, -- 665
			"cuff:p03:cloth_wipe_wood", -- 665
			ctx.p.ticks -- 665
		) -- 665
	elseif self.rehearsalShot == "P05" then -- 665
		if t >= 0.9 then -- 665
			ctx.audio:playOnce( -- 668
				"reh:p05:line:" .. tostring(sid), -- 668
				"voice", -- 668
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 668
				0.9, -- 668
				"cuff:p05:line_farewell", -- 668
				ctx.p.ticks -- 668
			) -- 668
		end -- 668
		if t >= 2.75 then -- 668
			ctx.audio:playOnce( -- 671
				"reh:p05:slam:" .. tostring(sid), -- 671
				"sfx", -- 671
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 671
				0.94, -- 671
				"cuff:p05:gate_slam", -- 671
				ctx.p.ticks -- 671
			) -- 671
			ctx.audio:playLoop( -- 672
				"reh_p05_water", -- 672
				"water", -- 672
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 672
				0.42, -- 672
				ctx.p.ticks -- 672
			) -- 672
		end -- 672
	elseif self.rehearsalShot == "G05" then -- 672
		if t >= 0.05 then -- 672
			ctx.audio:playOnce( -- 676
				"reh:g05:knock1:" .. tostring(sid), -- 676
				"sfx", -- 676
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 676
				0.88, -- 676
				"knock:gate:1", -- 676
				ctx.p.ticks -- 676
			) -- 676
		end -- 676
		if t >= 0.25 then -- 676
			ctx.audio:playOnce( -- 679
				"reh:g05:knock2:" .. tostring(sid), -- 679
				"sfx", -- 679
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 679
				0.92, -- 679
				"knock:gate:2", -- 679
				ctx.p.ticks -- 679
			) -- 679
		end -- 679
		if t >= 1.55 then -- 679
			ctx.audio:playOnce( -- 682
				"reh:g05:clasp:" .. tostring(sid), -- 682
				"sfx", -- 682
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 682
				0.88, -- 682
				"cuff:g05:hand_held", -- 682
				ctx.p.ticks -- 682
			) -- 682
		end -- 682
		if t >= 2.35 then -- 682
			ctx.audio:playOnce( -- 685
				"reh:g05:line:" .. tostring(sid), -- 685
				"voice", -- 685
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 685
				0.94, -- 685
				"cuff:g05:line_reunion", -- 685
				ctx.p.ticks -- 685
			) -- 685
		end -- 685
	end -- 685
end -- 661
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 690
	if self.activeShot == "" then -- 690
		return false -- 698
	end -- 698
	local w = ctx.uiW -- 700
	local h = ctx.uiH -- 701
	if self.activeShot == "P03" then -- 701
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 704
		self:renderP03Shot( -- 707
			uiDraw, -- 707
			uiInkDraw, -- 707
			uiArt, -- 707
			uiGlow, -- 707
			ctx, -- 707
			w, -- 707
			h, -- 707
			prog -- 707
		) -- 707
		return true -- 708
	end -- 708
	if self.activeShot == "P05" then -- 708
		if self.rehearsalShot == "P05" then -- 708
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 713
			self:renderP05FullShot( -- 714
				uiDraw, -- 714
				uiInkDraw, -- 714
				uiArt, -- 714
				uiGlow, -- 714
				ctx, -- 714
				w, -- 714
				h, -- 714
				prog -- 714
			) -- 714
			return true -- 715
		end -- 715
		self:renderP05ExitBridge( -- 718
			uiDraw, -- 718
			uiInkDraw, -- 718
			uiArt, -- 718
			uiGlow, -- 718
			ctx, -- 718
			w, -- 718
			h, -- 718
			clamp01(self.p05ExitTimer / 0.85) -- 718
		) -- 718
		return false -- 719
	end -- 719
	if self.activeShot == "G05" then -- 719
		if self.rehearsalShot == "G05" then -- 719
			self:renderG05RehearsalShot( -- 724
				uiDraw, -- 724
				uiInkDraw, -- 724
				uiArt, -- 724
				uiGlow, -- 724
				ctx, -- 724
				w, -- 724
				h, -- 724
				self.rehearsalTime -- 724
			) -- 724
			return true -- 725
		end -- 725
		self:renderG05LiveShot( -- 727
			uiDraw, -- 727
			uiInkDraw, -- 727
			uiArt, -- 727
			uiGlow, -- 727
			ctx, -- 727
			w, -- 727
			h -- 727
		) -- 727
		return true -- 728
	end -- 728
	return false -- 731
end -- 690
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 740
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 750
	local boxW = math.min(w - 140, 820) -- 752
	local boxH = math.min(h - 190, 390) -- 753
	local bx = (w - boxW) * 0.5 -- 754
	local by = (h - boxH) * 0.5 + 14 -- 755
	uiDraw:drawRect( -- 757
		Rect(0, 0, w, h), -- 757
		Color( -- 757
			7, -- 757
			9, -- 757
			14, -- 757
			math.floor(135 * fade + 0.5) -- 757
		) -- 757
	) -- 757
	fillVGradRect( -- 759
		uiDraw, -- 759
		bx, -- 759
		by, -- 759
		boxW, -- 759
		boxH, -- 759
		Color( -- 759
			14, -- 759
			13, -- 759
			16, -- 759
			math.floor(248 * fade + 0.5) -- 759
		), -- 759
		Color( -- 759
			24, -- 759
			24, -- 759
			30, -- 759
			math.floor(248 * fade + 0.5) -- 759
		) -- 759
	) -- 759
	local rimY = by + boxH * 0.34 -- 761
	uiDraw:drawRect( -- 762
		Rect(bx, by, boxW, rimY - by), -- 762
		Color( -- 762
			54, -- 762
			40, -- 762
			30, -- 762
			math.floor(252 * fade + 0.5) -- 762
		) -- 762
	) -- 762
	uiDraw:drawSegment( -- 763
		Vec2(bx, rimY), -- 763
		Vec2(bx + boxW, rimY), -- 763
		2.2, -- 763
		Color( -- 763
			128, -- 763
			100, -- 763
			76, -- 763
			math.floor(220 * fade + 0.5) -- 763
		) -- 763
	) -- 763
	local crackX = bx + boxW * 0.72 -- 765
	uiDraw:drawRect( -- 766
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 766
		Color( -- 766
			8, -- 766
			9, -- 766
			13, -- 766
			math.floor(245 * fade + 0.5) -- 766
		) -- 766
	) -- 766
	uiDraw:drawRect( -- 767
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 767
		Color( -- 767
			46, -- 767
			35, -- 767
			26, -- 767
			math.floor(250 * fade + 0.5) -- 767
		) -- 767
	) -- 767
	local wipeT = smoothstep(0.3, 0.66, prog) -- 770
	local shardOffsets = {{ -- 771
		x = -72, -- 772
		y = 8, -- 772
		dx = 46, -- 772
		dy = -38, -- 772
		r = 9 -- 772
	}, { -- 772
		x = -34, -- 773
		y = 12, -- 773
		dx = 64, -- 773
		dy = -46, -- 773
		r = 7 -- 773
	}, { -- 773
		x = 4, -- 774
		y = 6, -- 774
		dx = 82, -- 774
		dy = -52, -- 774
		r = 10 -- 774
	}, { -- 774
		x = 32, -- 775
		y = 10, -- 775
		dx = 74, -- 775
		dy = -34, -- 775
		r = 6 -- 775
	}} -- 775
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 777
	if shardAlpha > 0.02 then -- 777
		local si = 0 -- 779
		do -- 779
			si = 0 -- 780
			while si < #shardOffsets do -- 780
				local sh = shardOffsets[si + 1] -- 781
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 782
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 783
				uiDraw:drawPolygon( -- 784
					{ -- 784
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 785
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 786
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 787
					}, -- 787
					Color( -- 788
						212, -- 788
						218, -- 788
						224, -- 788
						math.floor(235 * shardAlpha + 0.5) -- 788
					), -- 788
					0.9, -- 788
					Color( -- 788
						92, -- 788
						108, -- 788
						126, -- 788
						math.floor(200 * shardAlpha + 0.5) -- 788
					) -- 788
				) -- 788
				si = si + 1 -- 780
			end -- 780
		end -- 780
	end -- 780
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 793
	local handOut = smoothstep(0.7, 0.9, prog) -- 794
	if handOut > 0.05 then -- 794
		drawChildHand( -- 796
			uiDraw, -- 797
			crackX + 18 - handOut * 66, -- 798
			rimY + 52, -- 799
			math.pi, -- 800
			1.05, -- 801
			"open_fingers", -- 802
			fade * handOut, -- 803
			false -- 804
		) -- 804
	elseif fingerEnter > 0.02 then -- 804
		drawChildHand( -- 807
			uiDraw, -- 808
			crackX + 12 - fingerEnter * 24, -- 809
			rimY + 46, -- 810
			math.pi, -- 811
			1.08, -- 812
			"two_fingers", -- 813
			fade * fingerEnter, -- 814
			false -- 815
		) -- 815
	end -- 815
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 820
	if sleeveEnter > 0.01 then -- 820
		local reachT = smoothstep(0.66, 0.88, prog) -- 822
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 823
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 824
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 825
		local pose = reachT > 0.2 and "reach" or "wipe" -- 826
		____exports.drawPatchedCuff( -- 827
			uiDraw, -- 827
			uiGlow, -- 827
			{ -- 827
				wristX = wx, -- 828
				wristY = wy, -- 829
				angleRad = ang, -- 830
				scale = 1.06, -- 831
				pose = pose, -- 832
				opacity = fade * sleeveEnter, -- 833
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 834
				warmth = 0.18 -- 835
			} -- 835
		) -- 835
	end -- 835
	uiInkDraw:drawRect( -- 840
		Rect(bx, by, boxW, boxH), -- 840
		Color(0, 0, 0, 0), -- 840
		1, -- 840
		toColor( -- 840
			PALETTE.silkDim, -- 840
			math.floor(145 * fade + 0.5) -- 840
		) -- 840
	) -- 840
	drawSilkVeil( -- 841
		uiDraw, -- 841
		uiArt, -- 841
		"p03_sub_veil", -- 841
		w * 0.5, -- 841
		42, -- 841
		520, -- 841
		42, -- 841
		PALETTE.inkWash, -- 841
		0.82 * fade, -- 841
		-1 -- 841
	) -- 841
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 842
	ctx.texts:put( -- 845
		"sm", -- 845
		subText, -- 845
		w * 0.5, -- 845
		42, -- 845
		toColor(PALETTE.textBright), -- 845
		0.5, -- 845
		0.5, -- 845
		"Center", -- 845
		1, -- 845
		fade, -- 845
		0.08 -- 845
	) -- 845
end -- 740
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 854
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 864
	local boxW = math.min(w - 120, 860) -- 865
	local boxH = math.min(h - 180, 400) -- 866
	local bx = (w - boxW) * 0.5 -- 867
	local by = (h - boxH) * 0.5 + 14 -- 868
	uiDraw:drawRect( -- 870
		Rect(0, 0, w, h), -- 870
		Color( -- 870
			7, -- 870
			9, -- 870
			14, -- 870
			math.floor(145 * fade + 0.5) -- 870
		) -- 870
	) -- 870
	fillVGradRect( -- 872
		uiDraw, -- 872
		bx, -- 872
		by, -- 872
		boxW, -- 872
		boxH, -- 872
		Color( -- 872
			14, -- 872
			22, -- 872
			34, -- 872
			math.floor(248 * fade + 0.5) -- 872
		), -- 872
		Color( -- 872
			28, -- 872
			42, -- 872
			58, -- 872
			math.floor(248 * fade + 0.5) -- 872
		) -- 872
	) -- 872
	fillRadialGlow( -- 874
		uiGlow, -- 874
		bx + boxW * 0.66, -- 874
		by + boxH * 0.32, -- 874
		220, -- 874
		68, -- 874
		Color( -- 874
			152, -- 874
			194, -- 874
			224, -- 874
			math.floor(74 * fade + 0.5) -- 874
		), -- 874
		Color(40, 70, 108, 0), -- 874
		16 -- 874
	) -- 874
	local releaseT = smoothstep(0.68, 0.94, prog) -- 876
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 877
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 880
	local cuffY = by + boxH * 0.52 -- 881
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 882
		wristX = cuffX, -- 883
		wristY = cuffY, -- 884
		angleRad = -0.06, -- 885
		scale = 1.12, -- 886
		pose = pinchT > 0.25 and "pinch" or "open", -- 887
		opacity = fade * (1 - releaseT * 0.88), -- 888
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 889
		warmth = 0.12 -- 890
	}) -- 890
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 894
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 895
	drawChildHand( -- 896
		uiDraw, -- 897
		childHandX, -- 898
		childHandY, -- 899
		math.pi + 0.12, -- 900
		1.12, -- 901
		releaseT > 0.35 and "open_fingers" or "clutch", -- 902
		fade, -- 903
		true -- 904
	) -- 904
	if releaseT > 0.01 then -- 904
		local dropH = boxH * releaseT * 0.88 -- 909
		uiDraw:drawRect( -- 910
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 910
			Color( -- 910
				26, -- 910
				22, -- 910
				20, -- 910
				math.floor(238 * fade + 0.5) -- 910
			) -- 910
		) -- 910
		uiDraw:drawSegment( -- 911
			Vec2(bx, by + boxH - dropH), -- 911
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 911
			2.4, -- 911
			Color( -- 911
				118, -- 911
				104, -- 911
				88, -- 911
				math.floor(220 * fade + 0.5) -- 911
			) -- 911
		) -- 911
	end -- 911
	uiInkDraw:drawRect( -- 914
		Rect(bx, by, boxW, boxH), -- 914
		Color(0, 0, 0, 0), -- 914
		1, -- 914
		toColor( -- 914
			PALETTE.silkDim, -- 914
			math.floor(150 * fade + 0.5) -- 914
		) -- 914
	) -- 914
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 917
	if lineAlpha > 0.02 then -- 917
		drawSilkVeil( -- 919
			uiDraw, -- 919
			uiArt, -- 919
			"p05_sub_veil", -- 919
			w * 0.5, -- 919
			42, -- 919
			740, -- 919
			44, -- 919
			PALETTE.inkWash, -- 919
			0.86 * lineAlpha, -- 919
			-1 -- 919
		) -- 919
		drawHairline( -- 920
			uiInkDraw, -- 920
			uiArt, -- 920
			"p05_sub_line", -- 920
			w * 0.5, -- 920
			62, -- 920
			520, -- 920
			PALETTE.silkDim, -- 920
			0.52 * lineAlpha, -- 920
			true, -- 920
			2 -- 920
		) -- 920
		ctx.texts:put( -- 921
			"sm", -- 921
			LINE_P05, -- 921
			w * 0.5, -- 921
			42, -- 921
			toColor(PALETTE.textBright), -- 921
			0.5, -- 921
			0.5, -- 921
			"Center", -- 921
			0.8, -- 921
			lineAlpha, -- 921
			0.08 -- 921
		) -- 921
	end -- 921
end -- 854
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, _uiInkDraw, _uiArt, uiGlow, _ctx, w, h, t) -- 926
	local out = smoothstep(0, 1, t) -- 936
	local alpha = 1 - out -- 937
	if alpha <= 0.02 then -- 937
		return -- 939
	end -- 939
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 941
		wristX = w * 0.24 - out * 240, -- 942
		wristY = h * 0.4, -- 943
		angleRad = -0.05, -- 944
		scale = 0.92, -- 945
		pose = "open", -- 946
		opacity = alpha * 0.92, -- 947
		stitchHighlight = 0.45 -- 948
	}) -- 948
end -- 926
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 958
	local view = ctx.view -- 967
	local gr = view.gateReunion -- 968
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 969
	local ext = clamp01(self.g05SleeveExtend) -- 970
	if not completed then -- 970
		if ext > 0.008 then -- 970
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 976
			fillVGradRect( -- 977
				uiDraw, -- 977
				0, -- 977
				h * 0.28, -- 977
				w, -- 977
				h * 0.16, -- 977
				Color(8, 11, 18, 0), -- 977
				Color(8, 11, 18, veilA) -- 977
			) -- 977
			fillVGradRect( -- 978
				uiDraw, -- 978
				0, -- 978
				h * 0.44, -- 978
				w, -- 978
				h * 0.16, -- 978
				Color(8, 11, 18, veilA), -- 978
				Color(8, 11, 18, 0) -- 978
			) -- 978
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 980
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 981
			____exports.drawPatchedCuff( -- 982
				uiDraw, -- 982
				uiGlow, -- 982
				{ -- 982
					wristX = cuffX, -- 983
					wristY = cuffY, -- 984
					angleRad = -0.05, -- 985
					scale = 1.08, -- 986
					pose = ext > 0.82 and "clasp" or "reach", -- 987
					opacity = clamp01(0.32 + ext * 0.68), -- 988
					stitchHighlight = 0.35 + 0.6 * ext -- 989
				} -- 989
			) -- 989
			local childX = w * 0.64 - ext * (w * 0.13) -- 993
			local childY = h * 0.41 + ext * 14 -- 994
			drawChildHand( -- 995
				uiDraw, -- 996
				childX, -- 997
				childY, -- 998
				math.pi + 0.08, -- 999
				1.06, -- 1000
				ext > 0.88 and "clasp" or "reach_up", -- 1001
				clamp01(0.25 + ext * 0.75), -- 1002
				true -- 1003
			) -- 1003
			local barW = 240 -- 1007
			local bx0 = w * 0.5 - barW * 0.5 -- 1008
			local by0 = 32 -- 1009
			uiInkDraw:drawSegment( -- 1010
				Vec2(bx0, by0), -- 1010
				Vec2(bx0 + barW, by0), -- 1010
				1.2, -- 1010
				toColor(PALETTE.silkDim, 110) -- 1010
			) -- 1010
			uiInkDraw:drawSegment( -- 1011
				Vec2(bx0, by0), -- 1011
				Vec2(bx0 + barW * ext, by0), -- 1011
				2.4, -- 1011
				toColor(PALETTE.amberCore, 230) -- 1011
			) -- 1011
		else -- 1011
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1014
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1015
				wristX = -120 + peekPulse * 14, -- 1016
				wristY = h * 0.44, -- 1017
				angleRad = -0.04, -- 1018
				scale = 1.04, -- 1019
				pose = "open", -- 1020
				opacity = 0.36 + 0.22 * peekPulse, -- 1021
				stitchHighlight = 0.35 * peekPulse -- 1022
			}) -- 1022
		end -- 1022
		if view.assistHintsEnabled then -- 1022
			drawSilkVeil( -- 1028
				uiDraw, -- 1028
				uiArt, -- 1028
				"g05_assist_veil", -- 1028
				w * 0.5, -- 1028
				h - 26, -- 1028
				280, -- 1028
				28, -- 1028
				PALETTE.inkWash, -- 1028
				0.72, -- 1028
				-1 -- 1028
			) -- 1028
			ctx.texts:put( -- 1029
				"xs", -- 1029
				"按住 E 牵住伸来的袖口", -- 1029
				w * 0.5, -- 1029
				h - 26, -- 1029
				toColor(PALETTE.amberCore), -- 1029
				0.5, -- 1029
				0.5, -- 1029
				"Center", -- 1029
				1.2, -- 1029
				0.9, -- 1029
				0.08 -- 1029
			) -- 1029
		end -- 1029
		return -- 1031
	end -- 1031
	local t = self.g05ReunionElapsed -- 1035
	local claspPull = smoothstep(0, 0.35, t) -- 1036
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1037
	local armDropY = tilt * (h * 0.26) -- 1038
	local claspFade = 1 - smoothstep(0.95, 1.45, t) * 0.45 -- 1041
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1042
		wristX = w * 0.44, -- 1043
		wristY = h * 0.44 - armDropY, -- 1044
		angleRad = -0.05 + tilt * 0.22, -- 1045
		scale = 1.08, -- 1046
		pose = "clasp", -- 1047
		opacity = claspFade, -- 1048
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1049
		cuffPullBack = claspPull * 0.85, -- 1050
		warmth = tilt * 0.32 -- 1051
	}) -- 1051
	drawChildHand( -- 1053
		uiDraw, -- 1054
		w * 0.53, -- 1055
		h * 0.43 - armDropY, -- 1056
		math.pi + 0.05 - tilt * 0.14, -- 1057
		1.08, -- 1058
		"clasp", -- 1059
		claspFade, -- 1060
		true -- 1061
	) -- 1061
	local portraitAlpha = smoothstep(0.32, 0.88, t) -- 1065
	if portraitAlpha > 0.02 then -- 1065
		local py = h * 0.56 + (1 - portraitAlpha) * 26 -- 1067
		drawZhouShuReunionPortrait( -- 1068
			uiDraw, -- 1068
			uiInkDraw, -- 1068
			uiArt, -- 1068
			uiGlow, -- 1068
			w * 0.72, -- 1068
			py, -- 1068
			1, -- 1068
			portraitAlpha -- 1068
		) -- 1068
	end -- 1068
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1072
	if lineAlpha > 0.02 then -- 1072
		drawSilkVeil( -- 1074
			uiDraw, -- 1074
			uiArt, -- 1074
			"g05_line_veil", -- 1074
			w * 0.5, -- 1074
			42, -- 1074
			420, -- 1074
			44, -- 1074
			PALETTE.inkWash, -- 1074
			0.86 * lineAlpha, -- 1074
			-1 -- 1074
		) -- 1074
		drawHairline( -- 1075
			uiInkDraw, -- 1075
			uiArt, -- 1075
			"g05_line_bar", -- 1075
			w * 0.5, -- 1075
			62, -- 1075
			260, -- 1075
			PALETTE.amber, -- 1075
			0.58 * lineAlpha, -- 1075
			true, -- 1075
			2 -- 1075
		) -- 1075
		ctx.texts:put( -- 1076
			"sm", -- 1076
			LINE_G05, -- 1076
			w * 0.5, -- 1076
			42, -- 1076
			toColor(PALETTE.textBright), -- 1076
			0.5, -- 1076
			0.5, -- 1076
			"Center", -- 1076
			2.2, -- 1076
			lineAlpha, -- 1076
			0.08 -- 1076
		) -- 1076
	end -- 1076
end -- 958
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1081
	local holdExt = smoothstep(0.55, 1.45, t) -- 1092
	local tilt = smoothstep(1.55, 2.55, t) -- 1093
	local claspPull = smoothstep(1.4, 1.75, t) -- 1094
	local armDropY = tilt * (h * 0.24) -- 1095
	local boxW = math.min(w - 120, 860) -- 1097
	local boxH = math.min(h - 180, 400) -- 1098
	local bx = (w - boxW) * 0.5 -- 1099
	local by = (h - boxH) * 0.5 + 14 -- 1100
	uiDraw:drawRect( -- 1101
		Rect(0, 0, w, h), -- 1101
		Color(7, 9, 14, 150) -- 1101
	) -- 1101
	local bgTop = lerpRGBA( -- 1102
		rgba(16, 24, 36, 250), -- 1102
		rgba(20, 26, 36, 250), -- 1102
		tilt -- 1102
	) -- 1102
	local bgBot = lerpRGBA( -- 1103
		rgba(10, 15, 24, 250), -- 1103
		rgba(14, 18, 26, 250), -- 1103
		tilt -- 1103
	) -- 1103
	fillVGradRect( -- 1104
		uiDraw, -- 1104
		bx, -- 1104
		by, -- 1104
		boxW, -- 1104
		boxH, -- 1104
		toColor(bgBot), -- 1104
		toColor(bgTop) -- 1104
	) -- 1104
	if tilt > 0.05 then -- 1104
		drawZhouShuReunionPortrait( -- 1107
			uiDraw, -- 1107
			uiInkDraw, -- 1107
			uiArt, -- 1107
			uiGlow, -- 1107
			bx + boxW * 0.72, -- 1107
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1107
			0.92, -- 1107
			tilt -- 1107
		) -- 1107
	end -- 1107
	____exports.drawPatchedCuff( -- 1110
		uiDraw, -- 1110
		uiGlow, -- 1110
		{ -- 1110
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1111
			wristY = by + boxH * 0.52 - armDropY, -- 1112
			angleRad = -0.05 + tilt * 0.2, -- 1113
			scale = 1.06, -- 1114
			pose = t >= 1.4 and "clasp" or "reach", -- 1115
			opacity = clamp01(0.25 + holdExt * 0.75), -- 1116
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1117
			cuffPullBack = claspPull * 0.85, -- 1118
			warmth = tilt * 0.32 -- 1119
		} -- 1119
	) -- 1119
	drawChildHand( -- 1121
		uiDraw, -- 1122
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1123
		by + boxH * 0.48 - armDropY, -- 1124
		math.pi + 0.06, -- 1125
		1.06, -- 1126
		t >= 1.4 and "clasp" or "reach_up", -- 1127
		clamp01(0.35 + holdExt * 0.65), -- 1128
		true -- 1129
	) -- 1129
	uiInkDraw:drawRect( -- 1132
		Rect(bx, by, boxW, boxH), -- 1132
		Color(0, 0, 0, 0), -- 1132
		1, -- 1132
		toColor(PALETTE.silkDim, 145) -- 1132
	) -- 1132
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1134
	if lineAlpha > 0.02 then -- 1134
		drawSilkVeil( -- 1136
			uiDraw, -- 1136
			uiArt, -- 1136
			"g05_reh_veil", -- 1136
			w * 0.5, -- 1136
			42, -- 1136
			420, -- 1136
			44, -- 1136
			PALETTE.inkWash, -- 1136
			0.86 * lineAlpha, -- 1136
			-1 -- 1136
		) -- 1136
		drawHairline( -- 1137
			uiInkDraw, -- 1137
			uiArt, -- 1137
			"g05_reh_bar", -- 1137
			w * 0.5, -- 1137
			62, -- 1137
			260, -- 1137
			PALETTE.amber, -- 1137
			0.58 * lineAlpha, -- 1137
			true, -- 1137
			2 -- 1137
		) -- 1137
		ctx.texts:put( -- 1138
			"sm", -- 1138
			LINE_G05, -- 1138
			w * 0.5, -- 1138
			42, -- 1138
			toColor(PALETTE.textBright), -- 1138
			0.5, -- 1138
			0.5, -- 1138
			"Center", -- 1138
			2.2, -- 1138
			lineAlpha, -- 1138
			0.08 -- 1138
		) -- 1138
	end -- 1138
end -- 1081
function ____exports.createCuffShotsPlugin() -- 1143
	return __TS__New(____exports.CuffShotsPlugin) -- 1144
end -- 1143
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1151
	local gateTransition = createGateTransitionPlugin() -- 1155
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1156
	fe:registerPlugin(gateTransition) -- 1157
	fe:registerPlugin(cuffShots) -- 1158
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1159
end -- 1151
return ____exports -- 1151