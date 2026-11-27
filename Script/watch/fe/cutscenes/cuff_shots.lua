-- [ts]: cuff_shots.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local Color = ____Dora.Color -- 21
local Rect = ____Dora.Rect -- 21
local Vec2 = ____Dora.Vec2 -- 21
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 26
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 26
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 28
local createGateTransitionPlugin = ____gate_transition.createGateTransitionPlugin -- 32
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 34
local clamp01 = ____lowpoly.clamp01 -- 34
local smoothstep = ____lowpoly.smoothstep -- 34
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 35
local computeCenteredSlideRect = ____slideshow.computeCenteredSlideRect -- 37
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 38
local drawPixelSlideshow = ____slideshow.drawPixelSlideshow -- 39
local drawSlideFrameChrome = ____slideshow.drawSlideFrameChrome -- 40
local drawSlideSubtitle = ____slideshow.drawSlideSubtitle -- 41
local ____theme = require("Script.watch.fe.theme") -- 43
local PALETTE = ____theme.PALETTE -- 44
local drawSilkVeil = ____theme.drawSilkVeil -- 47
local fillRadialGlow = ____theme.fillRadialGlow -- 48
local fillVGradRect = ____theme.fillVGradRect -- 49
local lerpRGBA = ____theme.lerpRGBA -- 50
local rgba = ____theme.rgba -- 51
local toColor = ____theme.toColor -- 52
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 91
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 92
local LINE_G05 = "「我们走吧。」" -- 93
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 96
	indigoBase = rgba(34, 52, 74, 255), -- 97
	indigoShadow = rgba(18, 28, 42, 255), -- 98
	indigoFold = rgba(54, 78, 104, 255), -- 99
	patchDark = rgba(24, 38, 56, 255), -- 100
	hemEdge = rgba(68, 92, 118, 255), -- 101
	armWrapLinen = rgba(154, 142, 120, 255), -- 102
	armWrapShadow = rgba(102, 92, 78, 255), -- 103
	stitchThread = rgba(232, 224, 204, 255), -- 105
	stitchPinhole = rgba(14, 19, 28, 255), -- 106
	skinBase = rgba(188, 146, 116, 255), -- 107
	skinShadow = rgba(138, 102, 78, 255), -- 108
	skinLight = rgba(216, 178, 148, 255), -- 109
	childSkin = rgba(226, 196, 170, 255), -- 110
	childSkinShadow = rgba(176, 144, 120, 255), -- 111
	childSleeve = rgba(164, 142, 114, 255), -- 112
	childCord = rgba(168, 56, 52, 255) -- 113
} -- 113
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 116
	local sx = lx * scale -- 117
	local sy = ly * scale -- 118
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 119
end -- 116
local function tinted(base, warmth, opacity) -- 122
	local warmTarget = rgba( -- 123
		math.min(255, base.r + 22), -- 124
		math.min(255, base.g + 12), -- 125
		math.max(0, base.b - 10), -- 126
		base.a -- 127
	) -- 127
	local mixed = lerpRGBA( -- 129
		base, -- 129
		warmTarget, -- 129
		clamp01(warmth) -- 129
	) -- 129
	return toColor( -- 130
		mixed, -- 130
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 130
	) -- 130
end -- 122
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 137
	local op = clamp01(opts.opacity or 1) -- 142
	if op <= 0.01 then -- 142
		return -- 144
	end -- 144
	local ox = opts.wristX -- 146
	local oy = opts.wristY -- 147
	local s = math.max(0.2, opts.scale) -- 148
	local cosA = math.cos(opts.angleRad) -- 149
	local sinA = math.sin(opts.angleRad) -- 150
	local w = clamp01(opts.warmth or 0) -- 151
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 152
	local function pt(lx, ly) -- 153
		return rotPt( -- 153
			ox, -- 153
			oy, -- 153
			lx, -- 153
			ly, -- 153
			cosA, -- 153
			sinA, -- 153
			s -- 153
		) -- 153
	end -- 153
	local cuffFront = 6 - pull -- 156
	draw:drawPolygon( -- 157
		{ -- 157
			pt(-250, -48), -- 158
			pt(cuffFront, -36), -- 159
			pt(cuffFront, 38), -- 160
			pt(-250, 52) -- 161
		}, -- 161
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 162
		1.4, -- 162
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 162
	) -- 162
	draw:drawPolygon( -- 165
		{ -- 165
			pt(-250, -48), -- 166
			pt(cuffFront, -36), -- 167
			pt(cuffFront, -8), -- 168
			pt(-250, -14) -- 169
		}, -- 169
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 170
	) -- 170
	draw:drawPolygon( -- 173
		{ -- 173
			pt(-230, 14), -- 174
			pt(cuffFront - 6, 10), -- 175
			pt(cuffFront - 4, 32), -- 176
			pt(-230, 40) -- 177
		}, -- 177
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 178
	) -- 178
	draw:drawSegment( -- 179
		pt(-185, 16), -- 179
		pt(cuffFront - 18, 12), -- 179
		1.2 * s, -- 179
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 179
	) -- 179
	draw:drawSegment( -- 180
		pt(-160, -10), -- 180
		pt(cuffFront - 26, -6), -- 180
		1.1 * s, -- 180
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 180
	) -- 180
	draw:drawPolygon( -- 183
		{ -- 183
			pt(cuffFront - 8, -28), -- 184
			pt(cuffFront + 16, -24), -- 185
			pt(cuffFront + 16, 26), -- 186
			pt(cuffFront - 8, 28) -- 187
		}, -- 187
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 188
		1, -- 188
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 188
	) -- 188
	draw:drawSegment( -- 189
		pt(cuffFront + 3, -25), -- 189
		pt(cuffFront + 7, 25), -- 189
		1.3 * s, -- 189
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 189
	) -- 189
	draw:drawPolygon( -- 192
		{ -- 192
			pt(cuffFront - 16, -37), -- 193
			pt(cuffFront + 2, -36), -- 194
			pt(cuffFront + 2, 38), -- 195
			pt(cuffFront - 16, 39) -- 196
		}, -- 196
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 197
		1.3, -- 197
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 197
	) -- 197
	local pX0 = cuffFront - 72 -- 200
	local pX1 = cuffFront - 18 -- 201
	local pY0 = -16 -- 202
	local pY1 = 22 -- 203
	draw:drawPolygon( -- 204
		{ -- 204
			pt(pX0, pY0), -- 205
			pt(pX1, pY0 + 3), -- 206
			pt(pX1 - 2, pY1), -- 207
			pt(pX0 + 3, pY1 - 2) -- 208
		}, -- 208
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 209
		1.1, -- 209
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 209
	) -- 209
	local seamStartX = pX0 + 6 -- 212
	local seamStartY = pY0 + 5 -- 213
	local seamEndX = pX1 - 7 -- 214
	local seamEndY = pY1 - 5 -- 215
	draw:drawSegment( -- 216
		pt(seamStartX, seamStartY), -- 217
		pt(seamEndX, seamEndY), -- 218
		1.5 * s, -- 219
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 220
	) -- 220
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 223
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 224
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 225
	local stitches = 6 -- 226
	local k = 0 -- 227
	do -- 227
		k = 0 -- 228
		while k < stitches do -- 228
			local t = (k + 0.5) / stitches -- 229
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 230
			local my = seamStartY + (seamEndY - seamStartY) * t -- 231
			local nx = -4.8 -- 232
			local ny = 6.2 -- 233
			local a = pt(mx - nx, my - ny) -- 234
			local b = pt(mx + nx, my + ny) -- 235
			draw:drawDot(a, 1.3 * s, pinCol) -- 236
			draw:drawDot(b, 1.3 * s, pinCol) -- 237
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 238
			if hl > 0.05 then -- 238
				glow:drawSegment( -- 240
					a, -- 240
					b, -- 240
					2.4 * s, -- 240
					toColor( -- 240
						____exports.CUFF_PALETTE.stitchThread, -- 240
						math.floor(74 * hl * op + 0.5) -- 240
					) -- 240
				) -- 240
			end -- 240
			k = k + 1 -- 228
		end -- 228
	end -- 228
	local handBase = cuffFront + 14 -- 245
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 246
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 247
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 248
	if opts.pose == "wipe" then -- 248
		draw:drawPolygon( -- 252
			{ -- 252
				pt(handBase - 4, -20), -- 253
				pt(handBase + 46, -24), -- 254
				pt(handBase + 54, 4), -- 255
				pt(handBase + 38, 22), -- 256
				pt(handBase - 4, 20) -- 257
			}, -- 257
			skinCol, -- 258
			1.1, -- 258
			skinSh -- 258
		) -- 258
		draw:drawSegment( -- 259
			pt(handBase + 16, -2), -- 259
			pt(handBase + 52, -6), -- 259
			1.4 * s, -- 259
			skinSh -- 259
		) -- 259
		draw:drawSegment( -- 260
			pt(handBase + 14, 10), -- 260
			pt(handBase + 46, 8), -- 260
			1.4 * s, -- 260
			skinSh -- 260
		) -- 260
	elseif opts.pose == "pinch" then -- 260
		draw:drawPolygon( -- 263
			{ -- 263
				pt(handBase - 4, -22), -- 264
				pt(handBase + 44, -18), -- 265
				pt(handBase + 54, 6), -- 266
				pt(handBase + 28, 26), -- 267
				pt(handBase - 4, 22) -- 268
			}, -- 268
			skinCol, -- 269
			1.1, -- 269
			skinSh -- 269
		) -- 269
		draw:drawSegment( -- 270
			pt(handBase + 24, 16), -- 270
			pt(handBase + 52, 4), -- 270
			6.2 * s, -- 270
			skinHi -- 270
		) -- 270
		draw:drawSegment( -- 271
			pt(handBase + 30, -14), -- 271
			pt(handBase + 54, -4), -- 271
			5.6 * s, -- 271
			skinCol -- 271
		) -- 271
	elseif opts.pose == "clasp" then -- 271
		draw:drawPolygon( -- 274
			{ -- 274
				pt(handBase - 2, -22), -- 275
				pt(handBase + 52, -20), -- 276
				pt(handBase + 66, 2), -- 277
				pt(handBase + 44, 26), -- 278
				pt(handBase - 2, 22) -- 279
			}, -- 279
			skinCol, -- 280
			1.2, -- 280
			skinSh -- 280
		) -- 280
		draw:drawSegment( -- 281
			pt(handBase + 26, 20), -- 281
			pt(handBase + 58, 12), -- 281
			6.5 * s, -- 281
			skinHi -- 281
		) -- 281
		draw:drawSegment( -- 282
			pt(handBase + 46, -14), -- 282
			pt(handBase + 72, -10), -- 282
			5.2 * s, -- 282
			skinCol -- 282
		) -- 282
		draw:drawSegment( -- 283
			pt(handBase + 48, -2), -- 283
			pt(handBase + 76, 1), -- 283
			5.4 * s, -- 283
			skinCol -- 283
		) -- 283
	else -- 283
		local reachExt = opts.pose == "reach" and 10 or 0 -- 286
		draw:drawPolygon( -- 287
			{ -- 287
				pt(handBase - 4, -20), -- 288
				pt(handBase + 44 + reachExt, -18), -- 289
				pt(handBase + 56 + reachExt, 4), -- 290
				pt(handBase + 34 + reachExt * 0.5, 24), -- 291
				pt(handBase - 4, 20) -- 292
			}, -- 292
			skinCol, -- 293
			1.1, -- 293
			skinSh -- 293
		) -- 293
		draw:drawSegment( -- 295
			pt(handBase + 42 + reachExt, -14), -- 295
			pt(handBase + 74 + reachExt, -16), -- 295
			4.6 * s, -- 295
			skinCol -- 295
		) -- 295
		draw:drawSegment( -- 296
			pt(handBase + 46 + reachExt, -4), -- 296
			pt(handBase + 80 + reachExt, -3), -- 296
			4.8 * s, -- 296
			skinCol -- 296
		) -- 296
		draw:drawSegment( -- 297
			pt(handBase + 44 + reachExt, 6), -- 297
			pt(handBase + 76 + reachExt, 9), -- 297
			4.6 * s, -- 297
			skinCol -- 297
		) -- 297
		draw:drawSegment( -- 298
			pt(handBase + 26 + reachExt * 0.5, 18), -- 298
			pt(handBase + 56 + reachExt * 0.6, 28), -- 298
			5.2 * s, -- 298
			skinHi -- 298
		) -- 298
	end -- 298
end -- 137
--- 绘制小满伸出的小手（含腕上暗红指南针布套短绳）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord) -- 303
	if withCompassCord == nil then -- 303
		withCompassCord = true -- 311
	end -- 311
	local op = clamp01(opacity) -- 313
	if op <= 0.01 then -- 313
		return -- 315
	end -- 315
	local cosA = math.cos(angleRad) -- 317
	local sinA = math.sin(angleRad) -- 318
	local s = math.max(0.2, scale) -- 319
	local function pt(lx, ly) -- 320
		return rotPt( -- 320
			ox, -- 320
			oy, -- 320
			lx, -- 320
			ly, -- 320
			cosA, -- 320
			sinA, -- 320
			s -- 320
		) -- 320
	end -- 320
	local skin = toColor( -- 321
		____exports.CUFF_PALETTE.childSkin, -- 321
		math.floor(255 * op + 0.5) -- 321
	) -- 321
	local sh = toColor( -- 322
		____exports.CUFF_PALETTE.childSkinShadow, -- 322
		math.floor(255 * op + 0.5) -- 322
	) -- 322
	local sleeve = toColor( -- 323
		____exports.CUFF_PALETTE.childSleeve, -- 323
		math.floor(255 * op + 0.5) -- 323
	) -- 323
	if pose == "two_fingers" then -- 323
		draw:drawSegment( -- 327
			pt(-18, -4), -- 327
			pt(18, -5), -- 327
			5 * s, -- 327
			skin -- 327
		) -- 327
		draw:drawSegment( -- 328
			pt(-16, 6), -- 328
			pt(22, 7), -- 328
			5 * s, -- 328
			skin -- 328
		) -- 328
		draw:drawDot( -- 329
			pt(18, -5), -- 329
			2.5 * s, -- 329
			sh -- 329
		) -- 329
		draw:drawDot( -- 330
			pt(22, 7), -- 330
			2.5 * s, -- 330
			sh -- 330
		) -- 330
		return -- 331
	end -- 331
	draw:drawPolygon( -- 335
		{ -- 335
			pt(-135, -24), -- 336
			pt(-6, -18), -- 337
			pt(-6, 18), -- 338
			pt(-135, 26) -- 339
		}, -- 339
		sleeve, -- 340
		1.1, -- 340
		sh -- 340
	) -- 340
	if withCompassCord then -- 340
		draw:drawSegment( -- 344
			pt(-10, -18), -- 344
			pt(-4, 18), -- 344
			2.6 * s, -- 344
			toColor( -- 344
				____exports.CUFF_PALETTE.childCord, -- 344
				math.floor(235 * op + 0.5) -- 344
			) -- 344
		) -- 344
		draw:drawSegment( -- 345
			pt(-4, -18), -- 345
			pt(2, 18), -- 345
			2.2 * s, -- 345
			toColor( -- 345
				____exports.CUFF_PALETTE.childCord, -- 345
				math.floor(200 * op + 0.5) -- 345
			) -- 345
		) -- 345
	end -- 345
	draw:drawPolygon( -- 349
		{ -- 349
			pt(-4, -15), -- 350
			pt(28, -14), -- 351
			pt(34, 2), -- 352
			pt(22, 17), -- 353
			pt(-4, 15) -- 354
		}, -- 354
		skin, -- 355
		1, -- 355
		sh -- 355
	) -- 355
	if pose == "clutch" or pose == "clasp" then -- 355
		draw:drawSegment( -- 359
			pt(24, -11), -- 359
			pt(44, -6), -- 359
			4 * s, -- 359
			skin -- 359
		) -- 359
		draw:drawSegment( -- 360
			pt(26, -2), -- 360
			pt(47, 2), -- 360
			4.2 * s, -- 360
			skin -- 360
		) -- 360
		draw:drawSegment( -- 361
			pt(24, 6), -- 361
			pt(43, 9), -- 361
			4 * s, -- 361
			skin -- 361
		) -- 361
		draw:drawSegment( -- 362
			pt(16, 14), -- 362
			pt(34, 16), -- 362
			4.2 * s, -- 362
			skin -- 362
		) -- 362
	else -- 362
		draw:drawSegment( -- 365
			pt(26, -12), -- 365
			pt(52, -16), -- 365
			3.6 * s, -- 365
			skin -- 365
		) -- 365
		draw:drawSegment( -- 366
			pt(29, -4), -- 366
			pt(57, -5), -- 366
			3.8 * s, -- 366
			skin -- 366
		) -- 366
		draw:drawSegment( -- 367
			pt(28, 4), -- 367
			pt(54, 7), -- 367
			3.6 * s, -- 367
			skin -- 367
		) -- 367
		draw:drawSegment( -- 368
			pt(24, 11), -- 368
			pt(46, 17), -- 368
			3.4 * s, -- 368
			skin -- 368
		) -- 368
		draw:drawSegment( -- 369
			pt(14, 15), -- 369
			pt(34, 26), -- 369
			4 * s, -- 369
			skin -- 369
		) -- 369
	end -- 369
end -- 303
--- 仅在 G05 重逢抬镜后绘制序章像素风风格的蹲姿周戍近景（复用真实像素立绘，与本体画风 100% 统一）
local function drawZhouShuReunionPortrait(draw, inkDraw, art, glow, cx, cy, scale, alpha) -- 374
	local a = clamp01(alpha) -- 384
	if a <= 0.01 then -- 384
		return -- 386
	end -- 386
	local s = scale -- 388
	local cardW = 212 * s -- 389
	local cardH = 248 * s -- 390
	local x0 = cx - cardW * 0.5 -- 391
	local y0 = cy - cardH * 0.5 -- 392
	fillVGradRect( -- 395
		draw, -- 396
		x0, -- 397
		y0, -- 398
		cardW, -- 399
		cardH, -- 400
		Color( -- 401
			10, -- 401
			15, -- 401
			24, -- 401
			math.floor(224 * a + 0.5) -- 401
		), -- 401
		Color( -- 402
			22, -- 402
			34, -- 402
			52, -- 402
			math.floor(234 * a + 0.5) -- 402
		) -- 402
	) -- 402
	local placed = art:tryPlace( -- 405
		"soldier_offer", -- 406
		"g05_zhoushu_closeup", -- 407
		cx + 4 * s, -- 408
		y0 + 18 * s, -- 409
		156 * s, -- 410
		214 * s, -- 411
		{opacity = a, layer = 4} -- 412
	) -- 412
	if not placed then -- 412
		art:tryPlace( -- 415
			"soldier_idle", -- 416
			"g05_zhoushu_closeup", -- 417
			cx, -- 418
			y0 + 18 * s, -- 419
			156 * s, -- 420
			214 * s, -- 421
			{opacity = a, layer = 4} -- 422
		) -- 422
	end -- 422
	inkDraw:drawRect( -- 426
		Rect(x0, y0, cardW, cardH), -- 426
		Color(0, 0, 0, 0), -- 426
		1.1, -- 426
		toColor( -- 426
			PALETTE.silkDim, -- 426
			math.floor(165 * a + 0.5) -- 426
		) -- 426
	) -- 426
	inkDraw:drawRect( -- 427
		Rect(x0 + 4, y0 + 4, cardW - 8, cardH - 8), -- 427
		Color(0, 0, 0, 0), -- 427
		0.7, -- 427
		toColor( -- 427
			PALETTE.amber, -- 427
			math.floor(78 * a + 0.5) -- 427
		) -- 427
	) -- 427
	fillRadialGlow( -- 428
		glow, -- 428
		cx + 12 * s, -- 428
		cy + 22 * s, -- 428
		96 * s, -- 428
		96 * s, -- 428
		Color( -- 428
			214, -- 428
			224, -- 428
			236, -- 428
			math.floor(38 * a + 0.5) -- 428
		), -- 428
		Color(120, 148, 178, 0), -- 428
		16 -- 428
	) -- 428
end -- 374
____exports.CuffShotsPlugin = __TS__Class() -- 431
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 431
CuffShotsPlugin.name = "CuffShotsPlugin" -- 431
function CuffShotsPlugin.prototype.____constructor(self) -- 431
	self.id = "fe-01-cuff-shots" -- 432
	self.animTime = 0 -- 434
	self.prevPhase = "" -- 435
	self.activeShot = "" -- 436
	self.rehearsalShot = "" -- 439
	self.rehearsalTime = 0 -- 440
	self.rehearsalDuration = 3 -- 441
	self.rehearsalAutoAdvance = true -- 442
	self.p03Progress = 0 -- 445
	self.p05ExitTimer = -1 -- 446
	self.g05SleeveExtend = 0 -- 447
	self.g05ReunionElapsed = 0 -- 448
	self.g05LineTriggered = false -- 449
	self.g05AbortVisualCount = 0 -- 450
	self.lastReleasedAbortCount = 0 -- 451
end -- 431
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 453
	self.animTime = 0 -- 454
	self.prevPhase = p.phase -- 455
	self.activeShot = "" -- 456
	self.p03Progress = 0 -- 457
	self.p05ExitTimer = -1 -- 458
	self.g05SleeveExtend = 0 -- 459
	self.g05ReunionElapsed = 0 -- 460
	self.g05LineTriggered = false -- 461
	self.g05AbortVisualCount = 0 -- 462
	self.lastReleasedAbortCount = 0 -- 463
end -- 453
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 471
	self.rehearsalShot = shot -- 472
	if shot == "" then -- 472
		self.rehearsalTime = 0 -- 474
		self.rehearsalAutoAdvance = true -- 475
		return -- 476
	end -- 476
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 478
	if fixedTime ~= nil then -- 478
		self.rehearsalTime = math.max( -- 480
			0, -- 480
			math.min(self.rehearsalDuration, fixedTime) -- 480
		) -- 480
		self.rehearsalAutoAdvance = false -- 481
	else -- 481
		self.rehearsalTime = 0 -- 483
		self.rehearsalAutoAdvance = true -- 484
	end -- 484
end -- 471
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 488
	self:rehearseShot("") -- 489
end -- 488
function CuffShotsPlugin.prototype.getDebugState(self) -- 492
	return { -- 493
		activeShot = self.activeShot, -- 494
		rehearsalShot = self.rehearsalShot, -- 495
		rehearsalTime = self.rehearsalTime, -- 496
		rehearsalDuration = self.rehearsalDuration, -- 497
		p03Progress = self.p03Progress, -- 498
		p05ExitTimer = self.p05ExitTimer, -- 499
		g05SleeveExtend = self.g05SleeveExtend, -- 500
		g05ReunionElapsed = self.g05ReunionElapsed, -- 501
		g05LineTriggered = self.g05LineTriggered, -- 502
		g05AbortVisualCount = self.g05AbortVisualCount -- 503
	} -- 503
end -- 492
function CuffShotsPlugin.prototype.update(self, ctx) -- 507
	local p = ctx.p -- 508
	local view = ctx.view -- 509
	local dt = ctx.paused and 0 or ctx.worldDt -- 510
	self.animTime = self.animTime + dt -- 511
	if self.rehearsalShot ~= "" then -- 511
		self.activeShot = self.rehearsalShot -- 515
		if self.rehearsalAutoAdvance and dt > 0 then -- 515
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 517
		end -- 517
		if not ctx.paused then -- 517
			self:triggerRehearsalAudio(ctx) -- 520
		end -- 520
		self.prevPhase = p.phase -- 522
		return -- 523
	end -- 523
	self.activeShot = "" -- 526
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 526
		self.activeShot = "P03" -- 530
		self.p03Progress = clamp01(p.phaseTick / 60) -- 531
		if not ctx.paused and self.p03Progress >= 0.25 then -- 531
			ctx.audio:playOnce( -- 533
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 534
				"sfx", -- 535
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 536
				0.86, -- 537
				"cuff:p03:cloth_wipe_wood", -- 538
				p.ticks -- 539
			) -- 539
		end -- 539
		if not ctx.paused and self.p03Progress >= 0.62 then -- 539
			ctx.audio:playOnce( -- 543
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 544
				"sfx", -- 545
				"assets/audio/interact/compass_handover.wav", -- 546
				0.82, -- 547
				"cuff:p03:compass_handover", -- 548
				p.ticks -- 549
			) -- 549
		end -- 549
		self.prevPhase = p.phase -- 552
		return -- 553
	else -- 553
		self.p03Progress = 0 -- 555
	end -- 555
	if p.room.key == "gate" then -- 555
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 555
			self.p05ExitTimer = 0 -- 561
			if not ctx.paused then -- 561
				ctx.audio:playOnce( -- 563
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 564
					"sfx", -- 565
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 566
					0.92, -- 567
					"cuff:p05:gate_slam", -- 568
					p.ticks -- 569
				) -- 569
				ctx.audio:playOnce( -- 571
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 572
					"voice", -- 573
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 574
					0.88, -- 575
					"cuff:p05:line_farewell", -- 576
					p.ticks -- 577
				) -- 577
			end -- 577
		end -- 577
		if self.p05ExitTimer >= 0 then -- 577
			if p.phase ~= "gate-count" or view.countElapsedTicks > 240 then -- 577
				self.p05ExitTimer = -1 -- 583
			else -- 583
				if dt > 0 then -- 583
					self.p05ExitTimer = self.p05ExitTimer + dt -- 586
				end -- 586
				if self.p05ExitTimer >= 3.6 then -- 586
					self.p05ExitTimer = -1 -- 589
				else -- 589
					self.activeShot = "P05" -- 591
				end -- 591
			end -- 591
		end -- 591
	else -- 591
		self.p05ExitTimer = -1 -- 596
	end -- 596
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 600
	if inGateReunion then -- 600
		self.activeShot = "G05" -- 608
		local gr = view.gateReunion -- 609
		local completed = p.phase == "gate-hand" or gr.completed -- 610
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 610
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 613
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 614
			if not ctx.paused and view.isRehearsal then -- 614
				ctx.audio:playOnce( -- 616
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 617
					"sfx", -- 618
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 619
					0.72, -- 620
					"cuff:g05:reunion_release", -- 621
					p.ticks -- 622
				) -- 622
			end -- 622
		end -- 622
		if completed then -- 622
			self.g05SleeveExtend = 1 -- 628
			if dt > 0 then -- 628
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 630
			end -- 630
			if not ctx.paused and not self.g05LineTriggered then -- 630
				if view.isRehearsal then -- 630
					ctx.audio:playOnce( -- 634
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 635
						"sfx", -- 636
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 637
						0.88, -- 638
						"cuff:g05:hand_held", -- 639
						p.ticks -- 640
					) -- 640
				end -- 640
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 640
					self.g05LineTriggered = true -- 644
					ctx.audio:playOnce( -- 645
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 646
						"voice", -- 647
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 648
						0.94, -- 649
						"cuff:g05:line_reunion", -- 650
						p.ticks -- 651
					) -- 651
				end -- 651
			end -- 651
		else -- 651
			self.g05ReunionElapsed = 0 -- 656
			self.g05LineTriggered = false -- 657
			if gr.holding or gr.holdProgress > 0.001 then -- 657
				if gr.holdProgress >= self.g05SleeveExtend then -- 657
					self.g05SleeveExtend = gr.holdProgress -- 661
				elseif dt > 0 then -- 661
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 663
				end -- 663
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 663
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 667
			end -- 667
		end -- 667
	else -- 667
		self.g05SleeveExtend = 0 -- 671
		self.g05ReunionElapsed = 0 -- 672
		self.g05LineTriggered = false -- 673
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 674
	end -- 674
	self.prevPhase = p.phase -- 677
end -- 507
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 680
	local sid = ctx.events.roomSessionId -- 681
	local t = self.rehearsalTime -- 682
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 682
		ctx.audio:playOnce( -- 684
			"reh:p03:wipe:" .. tostring(sid), -- 684
			"sfx", -- 684
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 684
			0.88, -- 684
			"cuff:p03:cloth_wipe_wood", -- 684
			ctx.p.ticks -- 684
		) -- 684
	elseif self.rehearsalShot == "P05" then -- 684
		if t >= 0.9 then -- 684
			ctx.audio:playOnce( -- 687
				"reh:p05:line:" .. tostring(sid), -- 687
				"voice", -- 687
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 687
				0.9, -- 687
				"cuff:p05:line_farewell", -- 687
				ctx.p.ticks -- 687
			) -- 687
		end -- 687
		if t >= 2.75 then -- 687
			ctx.audio:playOnce( -- 690
				"reh:p05:slam:" .. tostring(sid), -- 690
				"sfx", -- 690
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 690
				0.94, -- 690
				"cuff:p05:gate_slam", -- 690
				ctx.p.ticks -- 690
			) -- 690
			ctx.audio:playLoop( -- 691
				"reh_p05_water", -- 691
				"water", -- 691
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 691
				0.42, -- 691
				ctx.p.ticks -- 691
			) -- 691
		end -- 691
	elseif self.rehearsalShot == "G05" then -- 691
		if t >= 0.05 then -- 691
			ctx.audio:playOnce( -- 695
				"reh:g05:knock1:" .. tostring(sid), -- 695
				"sfx", -- 695
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 695
				0.88, -- 695
				"knock:gate:1", -- 695
				ctx.p.ticks -- 695
			) -- 695
		end -- 695
		if t >= 0.25 then -- 695
			ctx.audio:playOnce( -- 698
				"reh:g05:knock2:" .. tostring(sid), -- 698
				"sfx", -- 698
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 698
				0.92, -- 698
				"knock:gate:2", -- 698
				ctx.p.ticks -- 698
			) -- 698
		end -- 698
		if t >= 1.55 then -- 698
			ctx.audio:playOnce( -- 701
				"reh:g05:clasp:" .. tostring(sid), -- 701
				"sfx", -- 701
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 701
				0.88, -- 701
				"cuff:g05:hand_held", -- 701
				ctx.p.ticks -- 701
			) -- 701
		end -- 701
		if t >= 2.35 then -- 701
			ctx.audio:playOnce( -- 704
				"reh:g05:line:" .. tostring(sid), -- 704
				"voice", -- 704
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 704
				0.94, -- 704
				"cuff:g05:line_reunion", -- 704
				ctx.p.ticks -- 704
			) -- 704
		end -- 704
	end -- 704
end -- 680
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 709
	if self.activeShot == "" then -- 709
		return false -- 717
	end -- 717
	local w = ctx.uiW -- 719
	local h = ctx.uiH -- 720
	if self.activeShot == "P03" then -- 720
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 723
		self:renderP03Shot( -- 726
			uiDraw, -- 726
			uiInkDraw, -- 726
			uiArt, -- 726
			uiGlow, -- 726
			ctx, -- 726
			w, -- 726
			h, -- 726
			prog -- 726
		) -- 726
		return true -- 727
	end -- 727
	if self.activeShot == "P05" then -- 727
		if self.rehearsalShot == "P05" then -- 727
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 732
			self:renderP05FullShot( -- 733
				uiDraw, -- 733
				uiInkDraw, -- 733
				uiArt, -- 733
				uiGlow, -- 733
				ctx, -- 733
				w, -- 733
				h, -- 733
				prog -- 733
			) -- 733
			return true -- 734
		end -- 734
		self:renderP05ExitBridge( -- 737
			uiDraw, -- 737
			uiInkDraw, -- 737
			uiArt, -- 737
			uiGlow, -- 737
			ctx, -- 737
			w, -- 737
			h, -- 737
			clamp01(self.p05ExitTimer / 3.6) -- 737
		) -- 737
		return false -- 738
	end -- 738
	if self.activeShot == "G05" then -- 738
		if self.rehearsalShot == "G05" then -- 738
			self:renderG05RehearsalShot( -- 743
				uiDraw, -- 743
				uiInkDraw, -- 743
				uiArt, -- 743
				uiGlow, -- 743
				ctx, -- 743
				w, -- 743
				h, -- 743
				self.rehearsalTime -- 743
			) -- 743
			return true -- 744
		end -- 744
		self:renderG05LiveShot( -- 746
			uiDraw, -- 746
			uiInkDraw, -- 746
			uiArt, -- 746
			uiGlow, -- 746
			ctx, -- 746
			w, -- 746
			h -- 746
		) -- 746
		return true -- 747
	end -- 747
	return false -- 750
end -- 709
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 760
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 770
	local rect = computeCenteredSlideRect( -- 771
		w, -- 771
		h, -- 771
		860, -- 771
		484, -- 771
		16 -- 771
	) -- 771
	local slides = {{ -- 772
		slot = "slide_cuff_p03_01", -- 773
		start = 0, -- 773
		["end"] = 0.28, -- 773
		zoomFrom = 1, -- 773
		zoomTo = 1.02, -- 773
		transition = "cut" -- 773
	}, { -- 773
		slot = "slide_cuff_p03_02", -- 774
		start = 0.28, -- 774
		["end"] = 0.6, -- 774
		panFromX = -0.01, -- 774
		panToX = 0.01, -- 774
		transition = "dark_dip", -- 774
		transitionDur = 0.07 -- 774
	}, { -- 774
		slot = "slide_cuff_p03_03", -- 775
		start = 0.6, -- 775
		["end"] = 0.8, -- 775
		zoomFrom = 1, -- 775
		zoomTo = 1.02, -- 775
		transition = "dark_dip", -- 775
		transitionDur = 0.06 -- 775
	}, { -- 775
		slot = "slide_cuff_p03_04", -- 776
		start = 0.8, -- 776
		["end"] = 1.01, -- 776
		zoomFrom = 1.01, -- 776
		zoomTo = 1.03, -- 776
		transition = "crossfade", -- 776
		transitionDur = 0.08 -- 776
	}} -- 776
	drawPixelSlideshow( -- 778
		uiDraw, -- 778
		uiInkDraw, -- 778
		uiArt, -- 778
		slides, -- 778
		prog, -- 778
		rect, -- 778
		w, -- 778
		h, -- 778
		{frameOpacity = 1, opacity = fade, layer = 2, instancePrefix = "p03_cuff"} -- 778
	) -- 778
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 784
	drawSlideSubtitle( -- 787
		uiDraw, -- 787
		uiInkDraw, -- 787
		uiArt, -- 787
		ctx.texts, -- 787
		"p03_sub", -- 787
		subText, -- 787
		w * 0.5, -- 787
		42, -- 787
		fade, -- 787
		PALETTE.textBright, -- 787
		8 -- 787
	) -- 787
end -- 760
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 797
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 807
	local rect = computeCenteredSlideRect( -- 808
		w, -- 808
		h, -- 808
		880, -- 808
		495, -- 808
		16 -- 808
	) -- 808
	local dropShake = prog >= 0.84 and prog <= 0.92 and math.sin((prog - 0.84) * 260) * 3.2 or 0 -- 809
	local slides = {{ -- 810
		slot = "slide_cuff_p05_01", -- 811
		start = 0, -- 811
		["end"] = 0.28, -- 811
		zoomFrom = 1, -- 811
		zoomTo = 1.02, -- 811
		transition = "cut" -- 811
	}, { -- 811
		slot = "slide_cuff_p05_02", -- 812
		start = 0.28, -- 812
		["end"] = 0.64, -- 812
		zoomFrom = 1.01, -- 812
		zoomTo = 1.03, -- 812
		transition = "dark_dip", -- 812
		transitionDur = 0.06 -- 812
	}, { -- 812
		slot = "slide_cuff_p05_03", -- 813
		start = 0.64, -- 813
		["end"] = 0.84, -- 813
		panFromX = 0.006, -- 813
		panToX = -0.01, -- 813
		transition = "dark_dip", -- 813
		transitionDur = 0.06 -- 813
	}, { -- 813
		slot = "slide_cuff_p05_04", -- 814
		start = 0.84, -- 814
		["end"] = 1.01, -- 814
		panFromY = 0.01, -- 814
		panToY = 0, -- 814
		transition = "cut" -- 814
	}} -- 814
	drawPixelSlideshow( -- 816
		uiDraw, -- 816
		uiInkDraw, -- 816
		uiArt, -- 816
		slides, -- 816
		prog, -- 816
		rect, -- 816
		w, -- 816
		h, -- 816
		{ -- 816
			frameOpacity = 1, -- 817
			opacity = fade, -- 818
			shakeY = dropShake, -- 819
			layer = 2, -- 820
			instancePrefix = "p05_cuff" -- 821
		} -- 821
	) -- 821
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 824
	drawSlideSubtitle( -- 825
		uiDraw, -- 825
		uiInkDraw, -- 825
		uiArt, -- 825
		ctx.texts, -- 825
		"p05_sub", -- 825
		LINE_P05, -- 825
		w * 0.5, -- 825
		42, -- 825
		lineAlpha, -- 825
		PALETTE.textBright, -- 825
		8 -- 825
	) -- 825
end -- 797
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, t) -- 829
	local enter = smoothstep(0, 0.12, t) -- 839
	local out = smoothstep(0.7, 1, t) -- 840
	local alpha = enter * (1 - out) -- 841
	if alpha <= 0.02 then -- 841
		return -- 843
	end -- 843
	local rect = computeCenteredSlideRect( -- 845
		w, -- 845
		h, -- 845
		540, -- 845
		304, -- 845
		56 -- 845
	) -- 845
	local slides = {{slot = "slide_cuff_p05_01", start = 0, ["end"] = 0.24, transition = "cut"}, { -- 846
		slot = "slide_cuff_p05_02", -- 848
		start = 0.24, -- 848
		["end"] = 0.58, -- 848
		transition = "dark_dip", -- 848
		transitionDur = 0.06 -- 848
	}, { -- 848
		slot = "slide_cuff_p05_03", -- 849
		start = 0.58, -- 849
		["end"] = 0.8, -- 849
		transition = "dark_dip", -- 849
		transitionDur = 0.06 -- 849
	}, {slot = "slide_cuff_p05_04", start = 0.8, ["end"] = 1.01, transition = "cut"}} -- 849
	drawPixelSlideshow( -- 852
		uiDraw, -- 852
		uiInkDraw, -- 852
		uiArt, -- 852
		slides, -- 852
		t, -- 852
		rect, -- 852
		w, -- 852
		h, -- 852
		{frameOpacity = 0.72, opacity = alpha * 0.96, layer = 4, instancePrefix = "p05_live"} -- 852
	) -- 852
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 858
	drawSlideSubtitle( -- 859
		uiDraw, -- 859
		uiInkDraw, -- 859
		uiArt, -- 859
		ctx.texts, -- 859
		"p05_live", -- 859
		LINE_P05, -- 859
		w * 0.5, -- 859
		92, -- 859
		lineAlpha, -- 859
		PALETTE.textBright, -- 859
		9 -- 859
	) -- 859
end -- 829
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h) -- 867
	local view = ctx.view -- 876
	local gr = view.gateReunion -- 877
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 878
	local ext = clamp01(self.g05SleeveExtend) -- 879
	if not completed then -- 879
		if ext > 0.008 then -- 879
			local rect = computeCenteredSlideRect( -- 883
				w, -- 883
				h, -- 883
				820, -- 883
				461, -- 883
				14 -- 883
			) -- 883
			local openOp = clamp01(0.28 + ext * 0.72) -- 884
			local blend = smoothstep(0.18, 0.75, ext) -- 885
			if blend < 0.98 then -- 885
				drawPixelSlidePlate( -- 887
					uiDraw, -- 888
					uiInkDraw, -- 888
					uiArt, -- 888
					"slide_cuff_g05_01", -- 889
					"g05_live_peek", -- 889
					rect, -- 890
					openOp * (1 - blend * 0.7), -- 890
					2 -- 890
				) -- 890
			end -- 890
			if blend > 0.02 then -- 890
				drawPixelSlidePlate( -- 894
					uiDraw, -- 895
					uiInkDraw, -- 895
					uiArt, -- 895
					"slide_cuff_g05_02", -- 896
					"g05_live_reach", -- 896
					rect, -- 897
					openOp * blend, -- 897
					3, -- 897
					(1 - ext) * -0.018, -- 898
					0, -- 898
					1 + ext * 0.02 -- 898
				) -- 898
			end -- 898
			drawSlideFrameChrome( -- 901
				uiDraw, -- 901
				uiInkDraw, -- 901
				uiArt, -- 901
				rect, -- 901
				w, -- 901
				h, -- 901
				{frameOpacity = openOp * 0.92, opacity = openOp, layer = 2, instancePrefix = "g05_hold"} -- 901
			) -- 901
			local barW = 240 -- 909
			local bx0 = w * 0.5 - barW * 0.5 -- 910
			local by0 = 32 -- 911
			uiInkDraw:drawSegment( -- 912
				Vec2(bx0, by0), -- 912
				Vec2(bx0 + barW, by0), -- 912
				1.2, -- 912
				toColor(PALETTE.silkDim, 110) -- 912
			) -- 912
			uiInkDraw:drawSegment( -- 913
				Vec2(bx0, by0), -- 913
				Vec2(bx0 + barW * ext, by0), -- 913
				2.4, -- 913
				toColor(PALETTE.amberCore, 230) -- 913
			) -- 913
		else -- 913
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 916
			local peekRect = { -- 917
				x = 26, -- 917
				y = math.floor(h * 0.34 + 0.5), -- 917
				w = 224, -- 917
				h = 126 -- 917
			} -- 917
			drawPixelSlidePlate( -- 918
				uiDraw, -- 919
				uiInkDraw, -- 919
				uiArt, -- 919
				"slide_cuff_g05_01", -- 920
				"g05_live_idle_peek", -- 920
				peekRect, -- 921
				0.58 + 0.24 * peekPulse, -- 921
				2, -- 921
				-0.01 + peekPulse * 0.01 -- 922
			) -- 922
			drawSlideFrameChrome( -- 924
				uiDraw, -- 924
				uiInkDraw, -- 924
				uiArt, -- 924
				peekRect, -- 924
				w, -- 924
				h, -- 924
				{frameOpacity = 0, opacity = 0.65 + 0.2 * peekPulse, layer = 2, instancePrefix = "g05_idle_peek"} -- 924
			) -- 924
			uiInkDraw:drawRect( -- 930
				Rect(peekRect.x, peekRect.y, peekRect.w, peekRect.h), -- 930
				Color(0, 0, 0, 0), -- 930
				1, -- 930
				toColor( -- 930
					PALETTE.silkDim, -- 930
					math.floor(115 + 65 * peekPulse + 0.5) -- 930
				) -- 930
			) -- 930
		end -- 930
		if view.assistHintsEnabled then -- 930
			drawSilkVeil( -- 934
				uiDraw, -- 934
				uiArt, -- 934
				"g05_assist_veil", -- 934
				w * 0.5, -- 934
				h - 26, -- 934
				280, -- 934
				28, -- 934
				PALETTE.inkWash, -- 934
				0.72, -- 934
				7 -- 934
			) -- 934
			ctx.texts:put( -- 935
				"xs", -- 936
				adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 937
				w * 0.5, -- 938
				h - 26, -- 939
				toColor(PALETTE.amberCore), -- 940
				0.5, -- 941
				0.5, -- 942
				"Center", -- 943
				1.2, -- 944
				0.9, -- 945
				0.08 -- 946
			) -- 946
		end -- 946
		return -- 949
	end -- 949
	local t = self.g05ReunionElapsed -- 953
	local rect = computeCenteredSlideRect( -- 954
		w, -- 954
		h, -- 954
		880, -- 954
		495, -- 954
		16 -- 954
	) -- 954
	local slides = {{ -- 955
		slot = "slide_cuff_g05_03", -- 957
		start = 0, -- 958
		["end"] = 0.48, -- 959
		zoomFrom = 1, -- 960
		zoomTo = 1.03, -- 961
		transition = "cut" -- 962
	}, { -- 962
		slot = "slide_cuff_g05_04", -- 965
		start = 0.48, -- 966
		["end"] = 6, -- 967
		panFromY = -0.014, -- 968
		panToY = 0.004, -- 969
		zoomFrom = 1.01, -- 970
		zoomTo = 1.035, -- 971
		transition = "dark_dip", -- 972
		transitionDur = 0.26 -- 973
	}} -- 973
	drawPixelSlideshow( -- 976
		uiDraw, -- 976
		uiInkDraw, -- 976
		uiArt, -- 976
		slides, -- 976
		t, -- 976
		rect, -- 976
		w, -- 976
		h, -- 976
		{frameOpacity = 0.94, opacity = 1, layer = 2, instancePrefix = "g05_reunion"} -- 976
	) -- 976
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 983
	drawSlideSubtitle( -- 984
		uiDraw, -- 984
		uiInkDraw, -- 984
		uiArt, -- 984
		ctx.texts, -- 984
		"g05_line", -- 984
		LINE_G05, -- 984
		w * 0.5, -- 984
		42, -- 984
		lineAlpha, -- 984
		PALETTE.amberCore, -- 984
		8 -- 984
	) -- 984
end -- 867
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, t) -- 988
	local rect = computeCenteredSlideRect( -- 998
		w, -- 998
		h, -- 998
		880, -- 998
		495, -- 998
		16 -- 998
	) -- 998
	local slides = {{ -- 999
		slot = "slide_cuff_g05_01", -- 1000
		start = 0, -- 1000
		["end"] = 0.72, -- 1000
		zoomFrom = 1, -- 1000
		zoomTo = 1.02, -- 1000
		transition = "cut" -- 1000
	}, { -- 1000
		slot = "slide_cuff_g05_02", -- 1001
		start = 0.72, -- 1001
		["end"] = 1.48, -- 1001
		panFromX = -0.01, -- 1001
		panToX = 0.008, -- 1001
		transition = "dark_dip", -- 1001
		transitionDur = 0.18 -- 1001
	}, { -- 1001
		slot = "slide_cuff_g05_03", -- 1002
		start = 1.48, -- 1002
		["end"] = 2.2, -- 1002
		zoomFrom = 1, -- 1002
		zoomTo = 1.025, -- 1002
		transition = "dark_dip", -- 1002
		transitionDur = 0.18 -- 1002
	}, { -- 1002
		slot = "slide_cuff_g05_04", -- 1003
		start = 2.2, -- 1003
		["end"] = 4.1, -- 1003
		panFromY = -0.012, -- 1003
		panToY = 0.004, -- 1003
		zoomFrom = 1.01, -- 1003
		zoomTo = 1.03, -- 1003
		transition = "dark_dip", -- 1003
		transitionDur = 0.24 -- 1003
	}} -- 1003
	drawPixelSlideshow( -- 1005
		uiDraw, -- 1005
		uiInkDraw, -- 1005
		uiArt, -- 1005
		slides, -- 1005
		t, -- 1005
		rect, -- 1005
		w, -- 1005
		h, -- 1005
		{frameOpacity = 1, opacity = 1, layer = 2, instancePrefix = "g05_reh"} -- 1005
	) -- 1005
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1012
	drawSlideSubtitle( -- 1013
		uiDraw, -- 1013
		uiInkDraw, -- 1013
		uiArt, -- 1013
		ctx.texts, -- 1013
		"g05_reh", -- 1013
		LINE_G05, -- 1013
		w * 0.5, -- 1013
		42, -- 1013
		lineAlpha, -- 1013
		PALETTE.amberCore, -- 1013
		8 -- 1013
	) -- 1013
end -- 988
function ____exports.createCuffShotsPlugin() -- 1017
	return __TS__New(____exports.CuffShotsPlugin) -- 1018
end -- 1017
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1025
	local gateTransition = createGateTransitionPlugin() -- 1029
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1030
	fe:registerPlugin(gateTransition) -- 1031
	fe:registerPlugin(cuffShots) -- 1032
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1033
end -- 1025
return ____exports -- 1025