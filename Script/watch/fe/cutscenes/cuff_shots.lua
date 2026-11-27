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
local G05_PIXEL_RETURN_END = ____gate_transition.G05_PIXEL_RETURN_END -- 29
local G05_PIXEL_RETURN_START = ____gate_transition.G05_PIXEL_RETURN_START -- 30
local createGateTransitionPlugin = ____gate_transition.createGateTransitionPlugin -- 32
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 34
local clamp01 = ____lowpoly.clamp01 -- 34
local smoothstep = ____lowpoly.smoothstep -- 34
local ____theme = require("Script.watch.fe.theme") -- 35
local PALETTE = ____theme.PALETTE -- 36
local drawHairline = ____theme.drawHairline -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 39
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local fillVGradRect = ____theme.fillVGradRect -- 41
local lerpRGBA = ____theme.lerpRGBA -- 42
local rgba = ____theme.rgba -- 43
local toColor = ____theme.toColor -- 44
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 83
local REUNION_ART = "assets/art/gate/reunion.png" -- 84
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 85
local LINE_G05 = "「我们走吧。」" -- 86
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 89
	indigoBase = rgba(34, 52, 74, 255), -- 90
	indigoShadow = rgba(18, 28, 42, 255), -- 91
	indigoFold = rgba(54, 78, 104, 255), -- 92
	patchDark = rgba(24, 38, 56, 255), -- 93
	hemEdge = rgba(68, 92, 118, 255), -- 94
	armWrapLinen = rgba(154, 142, 120, 255), -- 95
	armWrapShadow = rgba(102, 92, 78, 255), -- 96
	stitchThread = rgba(232, 224, 204, 255), -- 98
	stitchPinhole = rgba(14, 19, 28, 255), -- 99
	skinBase = rgba(188, 146, 116, 255), -- 100
	skinShadow = rgba(138, 102, 78, 255), -- 101
	skinLight = rgba(216, 178, 148, 255), -- 102
	childSkin = rgba(226, 196, 170, 255), -- 103
	childSkinShadow = rgba(176, 144, 120, 255), -- 104
	childSleeve = rgba(164, 142, 114, 255), -- 105
	childCord = rgba(168, 56, 52, 255) -- 106
} -- 106
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 109
	local sx = lx * scale -- 110
	local sy = ly * scale -- 111
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 112
end -- 109
local function tinted(base, warmth, opacity) -- 115
	local warmTarget = rgba( -- 116
		math.min(255, base.r + 22), -- 117
		math.min(255, base.g + 12), -- 118
		math.max(0, base.b - 10), -- 119
		base.a -- 120
	) -- 120
	local mixed = lerpRGBA( -- 122
		base, -- 122
		warmTarget, -- 122
		clamp01(warmth) -- 122
	) -- 122
	return toColor( -- 123
		mixed, -- 123
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 123
	) -- 123
end -- 115
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 130
	local op = clamp01(opts.opacity or 1) -- 135
	if op <= 0.01 then -- 135
		return -- 137
	end -- 137
	local ox = opts.wristX -- 139
	local oy = opts.wristY -- 140
	local s = math.max(0.2, opts.scale) -- 141
	local cosA = math.cos(opts.angleRad) -- 142
	local sinA = math.sin(opts.angleRad) -- 143
	local w = clamp01(opts.warmth or 0) -- 144
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 145
	local function pt(lx, ly) -- 146
		return rotPt( -- 146
			ox, -- 146
			oy, -- 146
			lx, -- 146
			ly, -- 146
			cosA, -- 146
			sinA, -- 146
			s -- 146
		) -- 146
	end -- 146
	local cuffFront = 6 - pull -- 149
	draw:drawPolygon( -- 150
		{ -- 150
			pt(-250, -48), -- 151
			pt(cuffFront, -36), -- 152
			pt(cuffFront, 38), -- 153
			pt(-250, 52) -- 154
		}, -- 154
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 155
		1.4, -- 155
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 155
	) -- 155
	draw:drawPolygon( -- 158
		{ -- 158
			pt(-250, -48), -- 159
			pt(cuffFront, -36), -- 160
			pt(cuffFront, -8), -- 161
			pt(-250, -14) -- 162
		}, -- 162
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 163
	) -- 163
	draw:drawPolygon( -- 166
		{ -- 166
			pt(-230, 14), -- 167
			pt(cuffFront - 6, 10), -- 168
			pt(cuffFront - 4, 32), -- 169
			pt(-230, 40) -- 170
		}, -- 170
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 171
	) -- 171
	draw:drawSegment( -- 172
		pt(-185, 16), -- 172
		pt(cuffFront - 18, 12), -- 172
		1.2 * s, -- 172
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 172
	) -- 172
	draw:drawSegment( -- 173
		pt(-160, -10), -- 173
		pt(cuffFront - 26, -6), -- 173
		1.1 * s, -- 173
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 173
	) -- 173
	draw:drawPolygon( -- 176
		{ -- 176
			pt(cuffFront - 8, -28), -- 177
			pt(cuffFront + 16, -24), -- 178
			pt(cuffFront + 16, 26), -- 179
			pt(cuffFront - 8, 28) -- 180
		}, -- 180
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 181
		1, -- 181
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 181
	) -- 181
	draw:drawSegment( -- 182
		pt(cuffFront + 3, -25), -- 182
		pt(cuffFront + 7, 25), -- 182
		1.3 * s, -- 182
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 182
	) -- 182
	draw:drawPolygon( -- 185
		{ -- 185
			pt(cuffFront - 16, -37), -- 186
			pt(cuffFront + 2, -36), -- 187
			pt(cuffFront + 2, 38), -- 188
			pt(cuffFront - 16, 39) -- 189
		}, -- 189
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 190
		1.3, -- 190
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 190
	) -- 190
	local pX0 = cuffFront - 72 -- 193
	local pX1 = cuffFront - 18 -- 194
	local pY0 = -16 -- 195
	local pY1 = 22 -- 196
	draw:drawPolygon( -- 197
		{ -- 197
			pt(pX0, pY0), -- 198
			pt(pX1, pY0 + 3), -- 199
			pt(pX1 - 2, pY1), -- 200
			pt(pX0 + 3, pY1 - 2) -- 201
		}, -- 201
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 202
		1.1, -- 202
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 202
	) -- 202
	local seamStartX = pX0 + 6 -- 205
	local seamStartY = pY0 + 5 -- 206
	local seamEndX = pX1 - 7 -- 207
	local seamEndY = pY1 - 5 -- 208
	draw:drawSegment( -- 209
		pt(seamStartX, seamStartY), -- 210
		pt(seamEndX, seamEndY), -- 211
		1.5 * s, -- 212
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 213
	) -- 213
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 216
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 217
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 218
	local stitches = 6 -- 219
	local k = 0 -- 220
	do -- 220
		k = 0 -- 221
		while k < stitches do -- 221
			local t = (k + 0.5) / stitches -- 222
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 223
			local my = seamStartY + (seamEndY - seamStartY) * t -- 224
			local nx = -4.8 -- 225
			local ny = 6.2 -- 226
			local a = pt(mx - nx, my - ny) -- 227
			local b = pt(mx + nx, my + ny) -- 228
			draw:drawDot(a, 1.3 * s, pinCol) -- 229
			draw:drawDot(b, 1.3 * s, pinCol) -- 230
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 231
			if hl > 0.05 then -- 231
				glow:drawSegment( -- 233
					a, -- 233
					b, -- 233
					2.4 * s, -- 233
					toColor( -- 233
						____exports.CUFF_PALETTE.stitchThread, -- 233
						math.floor(74 * hl * op + 0.5) -- 233
					) -- 233
				) -- 233
			end -- 233
			k = k + 1 -- 221
		end -- 221
	end -- 221
	local handBase = cuffFront + 14 -- 238
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 239
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 240
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 241
	if opts.pose == "wipe" then -- 241
		draw:drawPolygon( -- 245
			{ -- 245
				pt(handBase - 4, -20), -- 246
				pt(handBase + 46, -24), -- 247
				pt(handBase + 54, 4), -- 248
				pt(handBase + 38, 22), -- 249
				pt(handBase - 4, 20) -- 250
			}, -- 250
			skinCol, -- 251
			1.1, -- 251
			skinSh -- 251
		) -- 251
		draw:drawSegment( -- 252
			pt(handBase + 16, -2), -- 252
			pt(handBase + 52, -6), -- 252
			1.4 * s, -- 252
			skinSh -- 252
		) -- 252
		draw:drawSegment( -- 253
			pt(handBase + 14, 10), -- 253
			pt(handBase + 46, 8), -- 253
			1.4 * s, -- 253
			skinSh -- 253
		) -- 253
	elseif opts.pose == "pinch" then -- 253
		draw:drawPolygon( -- 256
			{ -- 256
				pt(handBase - 4, -22), -- 257
				pt(handBase + 44, -18), -- 258
				pt(handBase + 54, 6), -- 259
				pt(handBase + 28, 26), -- 260
				pt(handBase - 4, 22) -- 261
			}, -- 261
			skinCol, -- 262
			1.1, -- 262
			skinSh -- 262
		) -- 262
		draw:drawSegment( -- 263
			pt(handBase + 24, 16), -- 263
			pt(handBase + 52, 4), -- 263
			6.2 * s, -- 263
			skinHi -- 263
		) -- 263
		draw:drawSegment( -- 264
			pt(handBase + 30, -14), -- 264
			pt(handBase + 54, -4), -- 264
			5.6 * s, -- 264
			skinCol -- 264
		) -- 264
	elseif opts.pose == "clasp" then -- 264
		draw:drawPolygon( -- 267
			{ -- 267
				pt(handBase - 2, -22), -- 268
				pt(handBase + 52, -20), -- 269
				pt(handBase + 66, 2), -- 270
				pt(handBase + 44, 26), -- 271
				pt(handBase - 2, 22) -- 272
			}, -- 272
			skinCol, -- 273
			1.2, -- 273
			skinSh -- 273
		) -- 273
		draw:drawSegment( -- 274
			pt(handBase + 26, 20), -- 274
			pt(handBase + 58, 12), -- 274
			6.5 * s, -- 274
			skinHi -- 274
		) -- 274
		draw:drawSegment( -- 275
			pt(handBase + 46, -14), -- 275
			pt(handBase + 72, -10), -- 275
			5.2 * s, -- 275
			skinCol -- 275
		) -- 275
		draw:drawSegment( -- 276
			pt(handBase + 48, -2), -- 276
			pt(handBase + 76, 1), -- 276
			5.4 * s, -- 276
			skinCol -- 276
		) -- 276
	else -- 276
		local reachExt = opts.pose == "reach" and 10 or 0 -- 279
		draw:drawPolygon( -- 280
			{ -- 280
				pt(handBase - 4, -20), -- 281
				pt(handBase + 44 + reachExt, -18), -- 282
				pt(handBase + 56 + reachExt, 4), -- 283
				pt(handBase + 34 + reachExt * 0.5, 24), -- 284
				pt(handBase - 4, 20) -- 285
			}, -- 285
			skinCol, -- 286
			1.1, -- 286
			skinSh -- 286
		) -- 286
		draw:drawSegment( -- 288
			pt(handBase + 42 + reachExt, -14), -- 288
			pt(handBase + 74 + reachExt, -16), -- 288
			4.6 * s, -- 288
			skinCol -- 288
		) -- 288
		draw:drawSegment( -- 289
			pt(handBase + 46 + reachExt, -4), -- 289
			pt(handBase + 80 + reachExt, -3), -- 289
			4.8 * s, -- 289
			skinCol -- 289
		) -- 289
		draw:drawSegment( -- 290
			pt(handBase + 44 + reachExt, 6), -- 290
			pt(handBase + 76 + reachExt, 9), -- 290
			4.6 * s, -- 290
			skinCol -- 290
		) -- 290
		draw:drawSegment( -- 291
			pt(handBase + 26 + reachExt * 0.5, 18), -- 291
			pt(handBase + 56 + reachExt * 0.6, 28), -- 291
			5.2 * s, -- 291
			skinHi -- 291
		) -- 291
	end -- 291
end -- 130
--- 绘制小满伸出的小手（含腕上暗红指南针布套短绳）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord) -- 296
	if withCompassCord == nil then -- 296
		withCompassCord = true -- 304
	end -- 304
	local op = clamp01(opacity) -- 306
	if op <= 0.01 then -- 306
		return -- 308
	end -- 308
	local cosA = math.cos(angleRad) -- 310
	local sinA = math.sin(angleRad) -- 311
	local s = math.max(0.2, scale) -- 312
	local function pt(lx, ly) -- 313
		return rotPt( -- 313
			ox, -- 313
			oy, -- 313
			lx, -- 313
			ly, -- 313
			cosA, -- 313
			sinA, -- 313
			s -- 313
		) -- 313
	end -- 313
	local skin = toColor( -- 314
		____exports.CUFF_PALETTE.childSkin, -- 314
		math.floor(255 * op + 0.5) -- 314
	) -- 314
	local sh = toColor( -- 315
		____exports.CUFF_PALETTE.childSkinShadow, -- 315
		math.floor(255 * op + 0.5) -- 315
	) -- 315
	local sleeve = toColor( -- 316
		____exports.CUFF_PALETTE.childSleeve, -- 316
		math.floor(255 * op + 0.5) -- 316
	) -- 316
	if pose == "two_fingers" then -- 316
		draw:drawSegment( -- 320
			pt(-18, -4), -- 320
			pt(18, -5), -- 320
			5 * s, -- 320
			skin -- 320
		) -- 320
		draw:drawSegment( -- 321
			pt(-16, 6), -- 321
			pt(22, 7), -- 321
			5 * s, -- 321
			skin -- 321
		) -- 321
		draw:drawDot( -- 322
			pt(18, -5), -- 322
			2.5 * s, -- 322
			sh -- 322
		) -- 322
		draw:drawDot( -- 323
			pt(22, 7), -- 323
			2.5 * s, -- 323
			sh -- 323
		) -- 323
		return -- 324
	end -- 324
	draw:drawPolygon( -- 328
		{ -- 328
			pt(-135, -24), -- 329
			pt(-6, -18), -- 330
			pt(-6, 18), -- 331
			pt(-135, 26) -- 332
		}, -- 332
		sleeve, -- 333
		1.1, -- 333
		sh -- 333
	) -- 333
	if withCompassCord then -- 333
		draw:drawSegment( -- 337
			pt(-10, -18), -- 337
			pt(-4, 18), -- 337
			2.6 * s, -- 337
			toColor( -- 337
				____exports.CUFF_PALETTE.childCord, -- 337
				math.floor(235 * op + 0.5) -- 337
			) -- 337
		) -- 337
		draw:drawSegment( -- 338
			pt(-4, -18), -- 338
			pt(2, 18), -- 338
			2.2 * s, -- 338
			toColor( -- 338
				____exports.CUFF_PALETTE.childCord, -- 338
				math.floor(200 * op + 0.5) -- 338
			) -- 338
		) -- 338
	end -- 338
	draw:drawPolygon( -- 342
		{ -- 342
			pt(-4, -15), -- 343
			pt(28, -14), -- 344
			pt(34, 2), -- 345
			pt(22, 17), -- 346
			pt(-4, 15) -- 347
		}, -- 347
		skin, -- 348
		1, -- 348
		sh -- 348
	) -- 348
	if pose == "clutch" or pose == "clasp" then -- 348
		draw:drawSegment( -- 352
			pt(24, -11), -- 352
			pt(44, -6), -- 352
			4 * s, -- 352
			skin -- 352
		) -- 352
		draw:drawSegment( -- 353
			pt(26, -2), -- 353
			pt(47, 2), -- 353
			4.2 * s, -- 353
			skin -- 353
		) -- 353
		draw:drawSegment( -- 354
			pt(24, 6), -- 354
			pt(43, 9), -- 354
			4 * s, -- 354
			skin -- 354
		) -- 354
		draw:drawSegment( -- 355
			pt(16, 14), -- 355
			pt(34, 16), -- 355
			4.2 * s, -- 355
			skin -- 355
		) -- 355
	else -- 355
		draw:drawSegment( -- 358
			pt(26, -12), -- 358
			pt(52, -16), -- 358
			3.6 * s, -- 358
			skin -- 358
		) -- 358
		draw:drawSegment( -- 359
			pt(29, -4), -- 359
			pt(57, -5), -- 359
			3.8 * s, -- 359
			skin -- 359
		) -- 359
		draw:drawSegment( -- 360
			pt(28, 4), -- 360
			pt(54, 7), -- 360
			3.6 * s, -- 360
			skin -- 360
		) -- 360
		draw:drawSegment( -- 361
			pt(24, 11), -- 361
			pt(46, 17), -- 361
			3.4 * s, -- 361
			skin -- 361
		) -- 361
		draw:drawSegment( -- 362
			pt(14, 15), -- 362
			pt(34, 26), -- 362
			4 * s, -- 362
			skin -- 362
		) -- 362
	end -- 362
end -- 296
--- 仅在 G05 重逢抬镜后绘制序章像素风风格的蹲姿周戍近景（复用真实像素立绘，与本体画风 100% 统一）
local function drawZhouShuReunionPortrait(draw, inkDraw, art, glow, cx, cy, scale, alpha) -- 367
	local a = clamp01(alpha) -- 377
	if a <= 0.01 then -- 377
		return -- 379
	end -- 379
	local s = scale -- 381
	local cardW = 212 * s -- 382
	local cardH = 248 * s -- 383
	local x0 = cx - cardW * 0.5 -- 384
	local y0 = cy - cardH * 0.5 -- 385
	fillVGradRect( -- 388
		draw, -- 389
		x0, -- 390
		y0, -- 391
		cardW, -- 392
		cardH, -- 393
		Color( -- 394
			10, -- 394
			15, -- 394
			24, -- 394
			math.floor(224 * a + 0.5) -- 394
		), -- 394
		Color( -- 395
			22, -- 395
			34, -- 395
			52, -- 395
			math.floor(234 * a + 0.5) -- 395
		) -- 395
	) -- 395
	local placed = art:tryPlace( -- 398
		"soldier_offer", -- 399
		"g05_zhoushu_closeup", -- 400
		cx + 4 * s, -- 401
		y0 + 18 * s, -- 402
		156 * s, -- 403
		214 * s, -- 404
		{opacity = a, layer = 4} -- 405
	) -- 405
	if not placed then -- 405
		art:tryPlace( -- 408
			"soldier_idle", -- 409
			"g05_zhoushu_closeup", -- 410
			cx, -- 411
			y0 + 18 * s, -- 412
			156 * s, -- 413
			214 * s, -- 414
			{opacity = a, layer = 4} -- 415
		) -- 415
	end -- 415
	inkDraw:drawRect( -- 419
		Rect(x0, y0, cardW, cardH), -- 419
		Color(0, 0, 0, 0), -- 419
		1.1, -- 419
		toColor( -- 419
			PALETTE.silkDim, -- 419
			math.floor(165 * a + 0.5) -- 419
		) -- 419
	) -- 419
	inkDraw:drawRect( -- 420
		Rect(x0 + 4, y0 + 4, cardW - 8, cardH - 8), -- 420
		Color(0, 0, 0, 0), -- 420
		0.7, -- 420
		toColor( -- 420
			PALETTE.amber, -- 420
			math.floor(78 * a + 0.5) -- 420
		) -- 420
	) -- 420
	fillRadialGlow( -- 421
		glow, -- 421
		cx + 12 * s, -- 421
		cy + 22 * s, -- 421
		96 * s, -- 421
		96 * s, -- 421
		Color( -- 421
			214, -- 421
			224, -- 421
			236, -- 421
			math.floor(38 * a + 0.5) -- 421
		), -- 421
		Color(120, 148, 178, 0), -- 421
		16 -- 421
	) -- 421
end -- 367
local function drawReunionArt(draw, art, w, h, tilt, alpha) -- 424
	if alpha <= 0.01 then -- 424
		return false -- 429
	end -- 429
	local height = h * (0.92 - 0.19 * tilt) -- 432
	local handY = h * (0.437 - 0.095 * tilt) -- 433
	local placed = art:tryPlacePath( -- 434
		REUNION_ART, -- 435
		"g05_reunion_two_shot", -- 435
		w * 0.505, -- 435
		handY, -- 435
		height * 1.16, -- 435
		height, -- 435
		{ -- 436
			anchorX = 0.66, -- 436
			anchorY = 0.51, -- 436
			opacity = alpha, -- 436
			layer = 3, -- 436
			smooth = true -- 436
		} -- 436
	) -- 436
	if placed then -- 436
		fillVGradRect( -- 439
			draw, -- 439
			0, -- 439
			0, -- 439
			w, -- 439
			h, -- 439
			Color( -- 440
				7, -- 440
				11, -- 440
				18, -- 440
				math.floor(218 * alpha + 0.5) -- 440
			), -- 440
			Color( -- 441
				9, -- 441
				16, -- 441
				27, -- 441
				math.floor(142 * alpha + 0.5) -- 441
			) -- 441
		) -- 441
	end -- 441
	return placed -- 444
end -- 424
____exports.CuffShotsPlugin = __TS__Class() -- 447
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 447
CuffShotsPlugin.name = "CuffShotsPlugin" -- 447
function CuffShotsPlugin.prototype.____constructor(self) -- 447
	self.id = "fe-01-cuff-shots" -- 448
	self.animTime = 0 -- 450
	self.prevPhase = "" -- 451
	self.activeShot = "" -- 452
	self.rehearsalShot = "" -- 455
	self.rehearsalTime = 0 -- 456
	self.rehearsalDuration = 3 -- 457
	self.rehearsalAutoAdvance = true -- 458
	self.p03Progress = 0 -- 461
	self.p05ExitTimer = -1 -- 462
	self.g05SleeveExtend = 0 -- 463
	self.g05ReunionElapsed = 0 -- 464
	self.g05LineTriggered = false -- 465
	self.g05AbortVisualCount = 0 -- 466
	self.lastReleasedAbortCount = 0 -- 467
end -- 447
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 469
	self.animTime = 0 -- 470
	self.prevPhase = p.phase -- 471
	self.activeShot = "" -- 472
	self.p03Progress = 0 -- 473
	self.p05ExitTimer = -1 -- 474
	self.g05SleeveExtend = 0 -- 475
	self.g05ReunionElapsed = 0 -- 476
	self.g05LineTriggered = false -- 477
	self.g05AbortVisualCount = 0 -- 478
	self.lastReleasedAbortCount = 0 -- 479
end -- 469
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 487
	self.rehearsalShot = shot -- 488
	if shot == "" then -- 488
		self.rehearsalTime = 0 -- 490
		self.rehearsalAutoAdvance = true -- 491
		return -- 492
	end -- 492
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 494
	if fixedTime ~= nil then -- 494
		self.rehearsalTime = math.max( -- 496
			0, -- 496
			math.min(self.rehearsalDuration, fixedTime) -- 496
		) -- 496
		self.rehearsalAutoAdvance = false -- 497
	else -- 497
		self.rehearsalTime = 0 -- 499
		self.rehearsalAutoAdvance = true -- 500
	end -- 500
end -- 487
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 504
	self:rehearseShot("") -- 505
end -- 504
function CuffShotsPlugin.prototype.getDebugState(self) -- 508
	return { -- 509
		activeShot = self.activeShot, -- 510
		rehearsalShot = self.rehearsalShot, -- 511
		rehearsalTime = self.rehearsalTime, -- 512
		rehearsalDuration = self.rehearsalDuration, -- 513
		p03Progress = self.p03Progress, -- 514
		p05ExitTimer = self.p05ExitTimer, -- 515
		g05SleeveExtend = self.g05SleeveExtend, -- 516
		g05ReunionElapsed = self.g05ReunionElapsed, -- 517
		g05LineTriggered = self.g05LineTriggered, -- 518
		g05AbortVisualCount = self.g05AbortVisualCount -- 519
	} -- 519
end -- 508
function CuffShotsPlugin.prototype.update(self, ctx) -- 523
	local p = ctx.p -- 524
	local view = ctx.view -- 525
	local dt = ctx.paused and 0 or ctx.worldDt -- 526
	self.animTime = self.animTime + dt -- 527
	if self.rehearsalShot ~= "" then -- 527
		self.activeShot = self.rehearsalShot -- 531
		if self.rehearsalAutoAdvance and dt > 0 then -- 531
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 533
		end -- 533
		if not ctx.paused then -- 533
			self:triggerRehearsalAudio(ctx) -- 536
		end -- 536
		self.prevPhase = p.phase -- 538
		return -- 539
	end -- 539
	self.activeShot = "" -- 542
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 542
		self.activeShot = "P03" -- 546
		self.p03Progress = clamp01(p.phaseTick / 60) -- 547
		if not ctx.paused and self.p03Progress >= 0.25 then -- 547
			ctx.audio:playOnce( -- 549
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 550
				"sfx", -- 551
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 552
				0.86, -- 553
				"cuff:p03:cloth_wipe_wood", -- 554
				p.ticks -- 555
			) -- 555
		end -- 555
		if not ctx.paused and self.p03Progress >= 0.62 then -- 555
			ctx.audio:playOnce( -- 559
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 560
				"sfx", -- 561
				"assets/audio/interact/compass_handover.wav", -- 562
				0.82, -- 563
				"cuff:p03:compass_handover", -- 564
				p.ticks -- 565
			) -- 565
		end -- 565
		self.prevPhase = p.phase -- 568
		return -- 569
	else -- 569
		self.p03Progress = 0 -- 571
	end -- 571
	if p.room.key == "gate" then -- 571
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 571
			self.p05ExitTimer = 0 -- 577
			if not ctx.paused then -- 577
				ctx.audio:playOnce( -- 579
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 580
					"sfx", -- 581
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 582
					0.92, -- 583
					"cuff:p05:gate_slam", -- 584
					p.ticks -- 585
				) -- 585
				ctx.audio:playOnce( -- 587
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 588
					"voice", -- 589
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 590
					0.88, -- 591
					"cuff:p05:line_farewell", -- 592
					p.ticks -- 593
				) -- 593
			end -- 593
		end -- 593
		if self.p05ExitTimer >= 0 then -- 593
			if p.phase ~= "gate-count" or view.countElapsedTicks > 240 then -- 593
				self.p05ExitTimer = -1 -- 599
			else -- 599
				if dt > 0 then -- 599
					self.p05ExitTimer = self.p05ExitTimer + dt -- 602
				end -- 602
				if self.p05ExitTimer >= 3.6 then -- 602
					self.p05ExitTimer = -1 -- 605
				else -- 605
					self.activeShot = "P05" -- 607
				end -- 607
			end -- 607
		end -- 607
	else -- 607
		self.p05ExitTimer = -1 -- 612
	end -- 612
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 616
	if inGateReunion then -- 616
		self.activeShot = "G05" -- 624
		local gr = view.gateReunion -- 625
		local completed = p.phase == "gate-hand" or gr.completed -- 626
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 626
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 629
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 630
			if not ctx.paused and view.isRehearsal then -- 630
				ctx.audio:playOnce( -- 632
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 633
					"sfx", -- 634
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 635
					0.72, -- 636
					"cuff:g05:reunion_release", -- 637
					p.ticks -- 638
				) -- 638
			end -- 638
		end -- 638
		if completed then -- 638
			self.g05SleeveExtend = 1 -- 644
			if dt > 0 then -- 644
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 646
			end -- 646
			if not ctx.paused and not self.g05LineTriggered then -- 646
				if view.isRehearsal then -- 646
					ctx.audio:playOnce( -- 650
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 651
						"sfx", -- 652
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 653
						0.88, -- 654
						"cuff:g05:hand_held", -- 655
						p.ticks -- 656
					) -- 656
				end -- 656
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 656
					self.g05LineTriggered = true -- 660
					ctx.audio:playOnce( -- 661
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 662
						"voice", -- 663
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 664
						0.94, -- 665
						"cuff:g05:line_reunion", -- 666
						p.ticks -- 667
					) -- 667
				end -- 667
			end -- 667
		else -- 667
			self.g05ReunionElapsed = 0 -- 672
			self.g05LineTriggered = false -- 673
			if gr.holding or gr.holdProgress > 0.001 then -- 673
				if gr.holdProgress >= self.g05SleeveExtend then -- 673
					self.g05SleeveExtend = gr.holdProgress -- 677
				elseif dt > 0 then -- 677
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 679
				end -- 679
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 679
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 683
			end -- 683
		end -- 683
	else -- 683
		self.g05SleeveExtend = 0 -- 687
		self.g05ReunionElapsed = 0 -- 688
		self.g05LineTriggered = false -- 689
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 690
	end -- 690
	self.prevPhase = p.phase -- 693
end -- 523
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 696
	local sid = ctx.events.roomSessionId -- 697
	local t = self.rehearsalTime -- 698
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 698
		ctx.audio:playOnce( -- 700
			"reh:p03:wipe:" .. tostring(sid), -- 700
			"sfx", -- 700
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 700
			0.88, -- 700
			"cuff:p03:cloth_wipe_wood", -- 700
			ctx.p.ticks -- 700
		) -- 700
	elseif self.rehearsalShot == "P05" then -- 700
		if t >= 0.9 then -- 700
			ctx.audio:playOnce( -- 703
				"reh:p05:line:" .. tostring(sid), -- 703
				"voice", -- 703
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 703
				0.9, -- 703
				"cuff:p05:line_farewell", -- 703
				ctx.p.ticks -- 703
			) -- 703
		end -- 703
		if t >= 2.75 then -- 703
			ctx.audio:playOnce( -- 706
				"reh:p05:slam:" .. tostring(sid), -- 706
				"sfx", -- 706
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 706
				0.94, -- 706
				"cuff:p05:gate_slam", -- 706
				ctx.p.ticks -- 706
			) -- 706
			ctx.audio:playLoop( -- 707
				"reh_p05_water", -- 707
				"water", -- 707
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 707
				0.42, -- 707
				ctx.p.ticks -- 707
			) -- 707
		end -- 707
	elseif self.rehearsalShot == "G05" then -- 707
		if t >= 0.05 then -- 707
			ctx.audio:playOnce( -- 711
				"reh:g05:knock1:" .. tostring(sid), -- 711
				"sfx", -- 711
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 711
				0.88, -- 711
				"knock:gate:1", -- 711
				ctx.p.ticks -- 711
			) -- 711
		end -- 711
		if t >= 0.25 then -- 711
			ctx.audio:playOnce( -- 714
				"reh:g05:knock2:" .. tostring(sid), -- 714
				"sfx", -- 714
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 714
				0.92, -- 714
				"knock:gate:2", -- 714
				ctx.p.ticks -- 714
			) -- 714
		end -- 714
		if t >= 1.55 then -- 714
			ctx.audio:playOnce( -- 717
				"reh:g05:clasp:" .. tostring(sid), -- 717
				"sfx", -- 717
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 717
				0.88, -- 717
				"cuff:g05:hand_held", -- 717
				ctx.p.ticks -- 717
			) -- 717
		end -- 717
		if t >= 2.35 then -- 717
			ctx.audio:playOnce( -- 720
				"reh:g05:line:" .. tostring(sid), -- 720
				"voice", -- 720
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 720
				0.94, -- 720
				"cuff:g05:line_reunion", -- 720
				ctx.p.ticks -- 720
			) -- 720
		end -- 720
	end -- 720
end -- 696
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 725
	if self.activeShot == "" then -- 725
		return false -- 733
	end -- 733
	local w = ctx.uiW -- 735
	local h = ctx.uiH -- 736
	if self.activeShot == "P03" then -- 736
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 739
		self:renderP03Shot( -- 742
			uiDraw, -- 742
			uiInkDraw, -- 742
			uiArt, -- 742
			uiGlow, -- 742
			ctx, -- 742
			w, -- 742
			h, -- 742
			prog -- 742
		) -- 742
		return true -- 743
	end -- 743
	if self.activeShot == "P05" then -- 743
		if self.rehearsalShot == "P05" then -- 743
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 748
			self:renderP05FullShot( -- 749
				uiDraw, -- 749
				uiInkDraw, -- 749
				uiArt, -- 749
				uiGlow, -- 749
				ctx, -- 749
				w, -- 749
				h, -- 749
				prog -- 749
			) -- 749
			return true -- 750
		end -- 750
		self:renderP05ExitBridge( -- 753
			uiDraw, -- 753
			uiInkDraw, -- 753
			uiArt, -- 753
			uiGlow, -- 753
			ctx, -- 753
			w, -- 753
			h, -- 753
			clamp01(self.p05ExitTimer / 3.6) -- 753
		) -- 753
		return false -- 754
	end -- 754
	if self.activeShot == "G05" then -- 754
		if self.rehearsalShot == "G05" then -- 754
			self:renderG05RehearsalShot( -- 759
				uiDraw, -- 759
				uiInkDraw, -- 759
				uiArt, -- 759
				uiGlow, -- 759
				ctx, -- 759
				w, -- 759
				h, -- 759
				self.rehearsalTime -- 759
			) -- 759
			return true -- 760
		end -- 760
		self:renderG05LiveShot( -- 762
			uiDraw, -- 762
			uiInkDraw, -- 762
			uiArt, -- 762
			uiGlow, -- 762
			ctx, -- 762
			w, -- 762
			h -- 762
		) -- 762
		return true -- 763
	end -- 763
	return false -- 766
end -- 725
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 775
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 785
	local boxW = math.min(w - 140, 820) -- 787
	local boxH = math.min(h - 190, 390) -- 788
	local bx = (w - boxW) * 0.5 -- 789
	local by = (h - boxH) * 0.5 + 14 -- 790
	uiDraw:drawRect( -- 792
		Rect(0, 0, w, h), -- 792
		Color( -- 792
			7, -- 792
			9, -- 792
			14, -- 792
			math.floor(135 * fade + 0.5) -- 792
		) -- 792
	) -- 792
	fillVGradRect( -- 794
		uiDraw, -- 794
		bx, -- 794
		by, -- 794
		boxW, -- 794
		boxH, -- 794
		Color( -- 794
			14, -- 794
			13, -- 794
			16, -- 794
			math.floor(248 * fade + 0.5) -- 794
		), -- 794
		Color( -- 794
			24, -- 794
			24, -- 794
			30, -- 794
			math.floor(248 * fade + 0.5) -- 794
		) -- 794
	) -- 794
	local rimY = by + boxH * 0.34 -- 796
	uiDraw:drawRect( -- 797
		Rect(bx, by, boxW, rimY - by), -- 797
		Color( -- 797
			54, -- 797
			40, -- 797
			30, -- 797
			math.floor(252 * fade + 0.5) -- 797
		) -- 797
	) -- 797
	uiDraw:drawSegment( -- 798
		Vec2(bx, rimY), -- 798
		Vec2(bx + boxW, rimY), -- 798
		2.2, -- 798
		Color( -- 798
			128, -- 798
			100, -- 798
			76, -- 798
			math.floor(220 * fade + 0.5) -- 798
		) -- 798
	) -- 798
	local crackX = bx + boxW * 0.72 -- 800
	uiDraw:drawRect( -- 801
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 801
		Color( -- 801
			8, -- 801
			9, -- 801
			13, -- 801
			math.floor(245 * fade + 0.5) -- 801
		) -- 801
	) -- 801
	uiDraw:drawRect( -- 802
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 802
		Color( -- 802
			46, -- 802
			35, -- 802
			26, -- 802
			math.floor(250 * fade + 0.5) -- 802
		) -- 802
	) -- 802
	local wipeT = smoothstep(0.3, 0.66, prog) -- 805
	local shardOffsets = {{ -- 806
		x = -72, -- 807
		y = 8, -- 807
		dx = 46, -- 807
		dy = -38, -- 807
		r = 9 -- 807
	}, { -- 807
		x = -34, -- 808
		y = 12, -- 808
		dx = 64, -- 808
		dy = -46, -- 808
		r = 7 -- 808
	}, { -- 808
		x = 4, -- 809
		y = 6, -- 809
		dx = 82, -- 809
		dy = -52, -- 809
		r = 10 -- 809
	}, { -- 809
		x = 32, -- 810
		y = 10, -- 810
		dx = 74, -- 810
		dy = -34, -- 810
		r = 6 -- 810
	}} -- 810
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 812
	if shardAlpha > 0.02 then -- 812
		local si = 0 -- 814
		do -- 814
			si = 0 -- 815
			while si < #shardOffsets do -- 815
				local sh = shardOffsets[si + 1] -- 816
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 817
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 818
				uiDraw:drawPolygon( -- 819
					{ -- 819
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 820
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 821
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 822
					}, -- 822
					Color( -- 823
						212, -- 823
						218, -- 823
						224, -- 823
						math.floor(235 * shardAlpha + 0.5) -- 823
					), -- 823
					0.9, -- 823
					Color( -- 823
						92, -- 823
						108, -- 823
						126, -- 823
						math.floor(200 * shardAlpha + 0.5) -- 823
					) -- 823
				) -- 823
				si = si + 1 -- 815
			end -- 815
		end -- 815
	end -- 815
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 828
	local handOut = smoothstep(0.7, 0.9, prog) -- 829
	if handOut > 0.05 then -- 829
		drawChildHand( -- 831
			uiDraw, -- 832
			crackX + 18 - handOut * 66, -- 833
			rimY + 52, -- 834
			math.pi, -- 835
			1.05, -- 836
			"open_fingers", -- 837
			fade * handOut, -- 838
			false -- 839
		) -- 839
	elseif fingerEnter > 0.02 then -- 839
		drawChildHand( -- 842
			uiDraw, -- 843
			crackX + 12 - fingerEnter * 24, -- 844
			rimY + 46, -- 845
			math.pi, -- 846
			1.08, -- 847
			"two_fingers", -- 848
			fade * fingerEnter, -- 849
			false -- 850
		) -- 850
	end -- 850
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 855
	if sleeveEnter > 0.01 then -- 855
		local reachT = smoothstep(0.66, 0.88, prog) -- 857
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 858
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 859
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 860
		local pose = reachT > 0.2 and "reach" or "wipe" -- 861
		____exports.drawPatchedCuff( -- 862
			uiDraw, -- 862
			uiGlow, -- 862
			{ -- 862
				wristX = wx, -- 863
				wristY = wy, -- 864
				angleRad = ang, -- 865
				scale = 1.06, -- 866
				pose = pose, -- 867
				opacity = fade * sleeveEnter, -- 868
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 869
				warmth = 0.18 -- 870
			} -- 870
		) -- 870
	end -- 870
	uiInkDraw:drawRect( -- 875
		Rect(bx, by, boxW, boxH), -- 875
		Color(0, 0, 0, 0), -- 875
		1, -- 875
		toColor( -- 875
			PALETTE.silkDim, -- 875
			math.floor(145 * fade + 0.5) -- 875
		) -- 875
	) -- 875
	drawSilkVeil( -- 876
		uiDraw, -- 876
		uiArt, -- 876
		"p03_sub_veil", -- 876
		w * 0.5, -- 876
		42, -- 876
		520, -- 876
		42, -- 876
		PALETTE.inkWash, -- 876
		0.82 * fade, -- 876
		-1 -- 876
	) -- 876
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 877
	ctx.texts:put( -- 880
		"sm", -- 880
		subText, -- 880
		w * 0.5, -- 880
		42, -- 880
		toColor(PALETTE.textBright), -- 880
		0.5, -- 880
		0.5, -- 880
		"Center", -- 880
		1, -- 880
		fade, -- 880
		0.08 -- 880
	) -- 880
end -- 775
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 889
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 899
	local boxW = math.min(w - 120, 860) -- 900
	local boxH = math.min(h - 180, 400) -- 901
	local bx = (w - boxW) * 0.5 -- 902
	local by = (h - boxH) * 0.5 + 14 -- 903
	uiDraw:drawRect( -- 905
		Rect(0, 0, w, h), -- 905
		Color( -- 905
			7, -- 905
			9, -- 905
			14, -- 905
			math.floor(145 * fade + 0.5) -- 905
		) -- 905
	) -- 905
	fillVGradRect( -- 907
		uiDraw, -- 907
		bx, -- 907
		by, -- 907
		boxW, -- 907
		boxH, -- 907
		Color( -- 907
			14, -- 907
			22, -- 907
			34, -- 907
			math.floor(248 * fade + 0.5) -- 907
		), -- 907
		Color( -- 907
			28, -- 907
			42, -- 907
			58, -- 907
			math.floor(248 * fade + 0.5) -- 907
		) -- 907
	) -- 907
	fillRadialGlow( -- 909
		uiGlow, -- 909
		bx + boxW * 0.66, -- 909
		by + boxH * 0.32, -- 909
		220, -- 909
		68, -- 909
		Color( -- 909
			152, -- 909
			194, -- 909
			224, -- 909
			math.floor(74 * fade + 0.5) -- 909
		), -- 909
		Color(40, 70, 108, 0), -- 909
		16 -- 909
	) -- 909
	local releaseT = smoothstep(0.68, 0.94, prog) -- 911
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 912
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 915
	local cuffY = by + boxH * 0.52 -- 916
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 917
		wristX = cuffX, -- 918
		wristY = cuffY, -- 919
		angleRad = -0.06, -- 920
		scale = 1.12, -- 921
		pose = pinchT > 0.25 and "pinch" or "open", -- 922
		opacity = fade * (1 - releaseT * 0.88), -- 923
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 924
		warmth = 0.12 -- 925
	}) -- 925
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 929
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 930
	drawChildHand( -- 931
		uiDraw, -- 932
		childHandX, -- 933
		childHandY, -- 934
		math.pi + 0.12, -- 935
		1.12, -- 936
		releaseT > 0.35 and "open_fingers" or "clutch", -- 937
		fade, -- 938
		true -- 939
	) -- 939
	if releaseT > 0.01 then -- 939
		local dropH = boxH * releaseT * 0.88 -- 944
		uiDraw:drawRect( -- 945
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 945
			Color( -- 945
				26, -- 945
				22, -- 945
				20, -- 945
				math.floor(238 * fade + 0.5) -- 945
			) -- 945
		) -- 945
		uiDraw:drawSegment( -- 946
			Vec2(bx, by + boxH - dropH), -- 946
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 946
			2.4, -- 946
			Color( -- 946
				118, -- 946
				104, -- 946
				88, -- 946
				math.floor(220 * fade + 0.5) -- 946
			) -- 946
		) -- 946
	end -- 946
	uiInkDraw:drawRect( -- 949
		Rect(bx, by, boxW, boxH), -- 949
		Color(0, 0, 0, 0), -- 949
		1, -- 949
		toColor( -- 949
			PALETTE.silkDim, -- 949
			math.floor(150 * fade + 0.5) -- 949
		) -- 949
	) -- 949
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 952
	if lineAlpha > 0.02 then -- 952
		drawSilkVeil( -- 954
			uiDraw, -- 954
			uiArt, -- 954
			"p05_sub_veil", -- 954
			w * 0.5, -- 954
			42, -- 954
			740, -- 954
			44, -- 954
			PALETTE.inkWash, -- 954
			0.86 * lineAlpha, -- 954
			-1 -- 954
		) -- 954
		drawHairline( -- 955
			uiInkDraw, -- 955
			uiArt, -- 955
			"p05_sub_line", -- 955
			w * 0.5, -- 955
			62, -- 955
			520, -- 955
			PALETTE.silkDim, -- 955
			0.52 * lineAlpha, -- 955
			true, -- 955
			2 -- 955
		) -- 955
		ctx.texts:put( -- 956
			"sm", -- 956
			LINE_P05, -- 956
			w * 0.5, -- 956
			42, -- 956
			toColor(PALETTE.textBright), -- 956
			0.5, -- 956
			0.5, -- 956
			"Center", -- 956
			0.8, -- 956
			lineAlpha, -- 956
			0.08 -- 956
		) -- 956
	end -- 956
end -- 889
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 961
	local enter = smoothstep(0, 0.12, t) -- 971
	local out = smoothstep(0.66, 1, t) -- 972
	local alpha = enter * (1 - out) -- 973
	if alpha <= 0.02 then -- 973
		return -- 975
	end -- 975
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 977
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 978
		wristX = w * 0.25 - out * 240, -- 979
		wristY = h * 0.4, -- 980
		angleRad = -0.05, -- 981
		scale = 0.94, -- 982
		pose = pinchT > 0.25 and "pinch" or "open", -- 983
		opacity = alpha * 0.94, -- 984
		stitchHighlight = 0.45 + 0.28 * pinchT -- 985
	}) -- 985
	drawChildHand( -- 987
		uiDraw, -- 988
		w * 0.35 + out * 26, -- 989
		h * 0.37 - out * 10, -- 990
		math.pi + 0.1, -- 991
		0.94, -- 992
		out > 0.32 and "open_fingers" or "clutch", -- 993
		alpha * 0.92, -- 994
		true -- 995
	) -- 995
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 997
	if lineAlpha > 0.02 then -- 997
		local subY = 92 -- 999
		drawSilkVeil( -- 1000
			uiDraw, -- 1000
			uiArt, -- 1000
			"p05_live_veil", -- 1000
			w * 0.5, -- 1000
			subY, -- 1000
			760, -- 1000
			44, -- 1000
			PALETTE.inkWash, -- 1000
			0.86 * lineAlpha, -- 1000
			-1 -- 1000
		) -- 1000
		drawHairline( -- 1001
			uiInkDraw, -- 1001
			uiArt, -- 1001
			"p05_live_line", -- 1001
			w * 0.5, -- 1001
			subY + 20, -- 1001
			520, -- 1001
			PALETTE.silkDim, -- 1001
			0.52 * lineAlpha, -- 1001
			true, -- 1001
			2 -- 1001
		) -- 1001
		ctx.texts:put( -- 1002
			"sm", -- 1002
			LINE_P05, -- 1002
			w * 0.5, -- 1002
			subY, -- 1002
			toColor(PALETTE.textBright), -- 1002
			0.5, -- 1002
			0.5, -- 1002
			"Center", -- 1002
			0.8, -- 1002
			lineAlpha, -- 1002
			0.08 -- 1002
		) -- 1002
	end -- 1002
end -- 961
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1012
	local view = ctx.view -- 1021
	local gr = view.gateReunion -- 1022
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1023
	local ext = smoothstep(0, 1, self.g05SleeveExtend) -- 1024
	if not completed then -- 1024
		if ext > 0.008 then -- 1024
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 1030
			fillVGradRect( -- 1031
				uiDraw, -- 1031
				0, -- 1031
				h * 0.28, -- 1031
				w, -- 1031
				h * 0.16, -- 1031
				Color(8, 11, 18, 0), -- 1031
				Color(8, 11, 18, veilA) -- 1031
			) -- 1031
			fillVGradRect( -- 1032
				uiDraw, -- 1032
				0, -- 1032
				h * 0.44, -- 1032
				w, -- 1032
				h * 0.16, -- 1032
				Color(8, 11, 18, veilA), -- 1032
				Color(8, 11, 18, 0) -- 1032
			) -- 1032
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 1034
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1035
			____exports.drawPatchedCuff( -- 1036
				uiDraw, -- 1036
				uiGlow, -- 1036
				{ -- 1036
					wristX = cuffX, -- 1037
					wristY = cuffY, -- 1038
					angleRad = -0.05, -- 1039
					scale = 1.08, -- 1040
					pose = ext > 0.82 and "clasp" or "reach", -- 1041
					opacity = clamp01(0.32 + ext * 0.68), -- 1042
					stitchHighlight = 0.35 + 0.6 * ext -- 1043
				} -- 1043
			) -- 1043
			local childX = w * 0.64 - ext * (w * 0.13) -- 1047
			local childY = h * 0.41 + ext * 14 -- 1048
			drawChildHand( -- 1049
				uiDraw, -- 1050
				childX, -- 1051
				childY, -- 1052
				math.pi + 0.08, -- 1053
				1.06, -- 1054
				ext > 0.88 and "clasp" or "reach_up", -- 1055
				clamp01(0.25 + ext * 0.75), -- 1056
				true -- 1057
			) -- 1057
		else -- 1057
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1062
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1063
				wristX = -120 + peekPulse * 14, -- 1064
				wristY = h * 0.44, -- 1065
				angleRad = -0.04, -- 1066
				scale = 1.04, -- 1067
				pose = "open", -- 1068
				opacity = 0.36 + 0.22 * peekPulse, -- 1069
				stitchHighlight = 0.35 * peekPulse -- 1070
			}) -- 1070
		end -- 1070
		if view.assistHintsEnabled then -- 1070
			drawSilkVeil( -- 1076
				uiDraw, -- 1076
				uiArt, -- 1076
				"g05_assist_veil", -- 1076
				w * 0.5, -- 1076
				h - 26, -- 1076
				280, -- 1076
				28, -- 1076
				PALETTE.inkWash, -- 1076
				0.72, -- 1076
				-1 -- 1076
			) -- 1076
			ctx.texts:put( -- 1077
				"xs", -- 1078
				adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1079
				w * 0.5, -- 1080
				h - 26, -- 1081
				toColor(PALETTE.amberCore), -- 1082
				0.5, -- 1083
				0.5, -- 1084
				"Center", -- 1085
				1.2, -- 1086
				0.9, -- 1087
				0.08 -- 1088
			) -- 1088
		end -- 1088
		return -- 1091
	end -- 1091
	local t = self.g05ReunionElapsed -- 1095
	local claspPull = smoothstep(0, 0.35, t) -- 1096
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1097
	local armDropY = tilt * (h * 0.095) -- 1098
	local artAlpha = smoothstep(0.1, 0.48, t) * (1 - smoothstep(1.19, 1.5, t) * 0.82) -- 1099
	local placed = drawReunionArt( -- 1100
		uiDraw, -- 1100
		uiArt, -- 1100
		w, -- 1100
		h, -- 1100
		tilt, -- 1100
		artAlpha -- 1100
	) -- 1100
	local claspFade = (placed and 1 - artAlpha or 1) * (1 - smoothstep(0.95, 1.48, t)) -- 1101
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1102
		wristX = w * 0.43, -- 1103
		wristY = h * 0.44 - armDropY, -- 1104
		angleRad = -0.05 + tilt * 0.18, -- 1105
		scale = 1.08, -- 1106
		pose = "clasp", -- 1107
		opacity = claspFade, -- 1108
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1109
		cuffPullBack = claspPull * 0.85, -- 1110
		warmth = tilt * 0.32 -- 1111
	}) -- 1111
	if claspFade > 0.01 then -- 1111
		drawChildHand( -- 1114
			uiDraw, -- 1115
			w * 0.53, -- 1115
			h * 0.43 - armDropY, -- 1115
			math.pi + 0.05 - tilt * 0.14, -- 1116
			1.08, -- 1116
			"clasp", -- 1116
			claspFade, -- 1116
			true -- 1116
		) -- 1116
	end -- 1116
	if not placed and tilt > 0.02 then -- 1116
		drawZhouShuReunionPortrait( -- 1121
			uiDraw, -- 1121
			uiInkDraw, -- 1121
			uiArt, -- 1121
			uiGlow, -- 1121
			w * 0.72, -- 1121
			h * 0.56, -- 1121
			1, -- 1121
			tilt -- 1121
		) -- 1121
	end -- 1121
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1125
	if lineAlpha > 0.02 then -- 1125
		drawSilkVeil( -- 1127
			uiDraw, -- 1127
			uiArt, -- 1127
			"g05_line_veil", -- 1127
			w * 0.5, -- 1127
			42, -- 1127
			420, -- 1127
			44, -- 1127
			PALETTE.inkWash, -- 1127
			0.86 * lineAlpha, -- 1127
			-1 -- 1127
		) -- 1127
		drawHairline( -- 1128
			uiInkDraw, -- 1128
			uiArt, -- 1128
			"g05_line_bar", -- 1128
			w * 0.5, -- 1128
			62, -- 1128
			260, -- 1128
			PALETTE.amber, -- 1128
			0.58 * lineAlpha, -- 1128
			true, -- 1128
			2 -- 1128
		) -- 1128
		ctx.texts:put( -- 1129
			"sm", -- 1129
			LINE_G05, -- 1129
			w * 0.5, -- 1129
			42, -- 1129
			toColor(PALETTE.textBright), -- 1129
			0.5, -- 1129
			0.5, -- 1129
			"Center", -- 1129
			2.2, -- 1129
			lineAlpha, -- 1129
			0.08 -- 1129
		) -- 1129
	end -- 1129
end -- 1012
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1134
	local holdExt = smoothstep(0.55, 1.45, t) -- 1145
	local tilt = smoothstep(1.55, 2.55, t) -- 1146
	local claspPull = smoothstep(1.4, 1.75, t) -- 1147
	local armDropY = tilt * (h * 0.24) -- 1148
	local boxW = math.min(w - 120, 860) -- 1150
	local boxH = math.min(h - 180, 400) -- 1151
	local bx = (w - boxW) * 0.5 -- 1152
	local by = (h - boxH) * 0.5 + 14 -- 1153
	uiDraw:drawRect( -- 1154
		Rect(0, 0, w, h), -- 1154
		Color(7, 9, 14, 150) -- 1154
	) -- 1154
	local bgTop = lerpRGBA( -- 1155
		rgba(16, 24, 36, 250), -- 1155
		rgba(20, 26, 36, 250), -- 1155
		tilt -- 1155
	) -- 1155
	local bgBot = lerpRGBA( -- 1156
		rgba(10, 15, 24, 250), -- 1156
		rgba(14, 18, 26, 250), -- 1156
		tilt -- 1156
	) -- 1156
	fillVGradRect( -- 1157
		uiDraw, -- 1157
		bx, -- 1157
		by, -- 1157
		boxW, -- 1157
		boxH, -- 1157
		toColor(bgBot), -- 1157
		toColor(bgTop) -- 1157
	) -- 1157
	local artAlpha = smoothstep(1.55, 2.1, t) -- 1159
	local placed = drawReunionArt( -- 1160
		uiDraw, -- 1160
		uiArt, -- 1160
		w, -- 1160
		h, -- 1160
		tilt, -- 1160
		artAlpha -- 1160
	) -- 1160
	local handAlpha = placed and 1 - artAlpha or 1 -- 1161
	if not placed and tilt > 0.05 then -- 1161
		drawZhouShuReunionPortrait( -- 1163
			uiDraw, -- 1163
			uiInkDraw, -- 1163
			uiArt, -- 1163
			uiGlow, -- 1163
			bx + boxW * 0.72, -- 1163
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1163
			0.92, -- 1163
			tilt -- 1163
		) -- 1163
	end -- 1163
	____exports.drawPatchedCuff( -- 1166
		uiDraw, -- 1166
		uiGlow, -- 1166
		{ -- 1166
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1167
			wristY = by + boxH * 0.52 - armDropY, -- 1168
			angleRad = -0.05 + tilt * 0.2, -- 1169
			scale = 1.06, -- 1170
			pose = t >= 1.4 and "clasp" or "reach", -- 1171
			opacity = handAlpha * clamp01(0.25 + holdExt * 0.75), -- 1172
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1173
			cuffPullBack = claspPull * 0.85, -- 1174
			warmth = tilt * 0.32 -- 1175
		} -- 1175
	) -- 1175
	drawChildHand( -- 1177
		uiDraw, -- 1178
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1179
		by + boxH * 0.48 - armDropY, -- 1180
		math.pi + 0.06, -- 1181
		1.06, -- 1182
		t >= 1.4 and "clasp" or "reach_up", -- 1183
		handAlpha * clamp01(0.35 + holdExt * 0.65), -- 1184
		true -- 1185
	) -- 1185
	if handAlpha > 0.01 then -- 1185
		uiInkDraw:drawRect( -- 1189
			Rect(bx, by, boxW, boxH), -- 1189
			Color(0, 0, 0, 0), -- 1189
			1, -- 1189
			toColor( -- 1189
				PALETTE.silkDim, -- 1189
				math.floor(145 * handAlpha + 0.5) -- 1189
			) -- 1189
		) -- 1189
	end -- 1189
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1192
	if lineAlpha > 0.02 then -- 1192
		drawSilkVeil( -- 1194
			uiDraw, -- 1194
			uiArt, -- 1194
			"g05_reh_veil", -- 1194
			w * 0.5, -- 1194
			42, -- 1194
			420, -- 1194
			44, -- 1194
			PALETTE.inkWash, -- 1194
			0.86 * lineAlpha, -- 1194
			-1 -- 1194
		) -- 1194
		drawHairline( -- 1195
			uiInkDraw, -- 1195
			uiArt, -- 1195
			"g05_reh_bar", -- 1195
			w * 0.5, -- 1195
			62, -- 1195
			260, -- 1195
			PALETTE.amber, -- 1195
			0.58 * lineAlpha, -- 1195
			true, -- 1195
			2 -- 1195
		) -- 1195
		ctx.texts:put( -- 1196
			"sm", -- 1196
			LINE_G05, -- 1196
			w * 0.5, -- 1196
			42, -- 1196
			toColor(PALETTE.textBright), -- 1196
			0.5, -- 1196
			0.5, -- 1196
			"Center", -- 1196
			2.2, -- 1196
			lineAlpha, -- 1196
			0.08 -- 1196
		) -- 1196
	end -- 1196
end -- 1134
function ____exports.createCuffShotsPlugin() -- 1201
	return __TS__New(____exports.CuffShotsPlugin) -- 1202
end -- 1201
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1209
	local gateTransition = createGateTransitionPlugin() -- 1213
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1214
	fe:registerPlugin(gateTransition) -- 1215
	fe:registerPlugin(cuffShots) -- 1216
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1217
end -- 1209
return ____exports -- 1209