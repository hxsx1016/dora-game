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
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 84
local LINE_G05 = "「我们走吧。」" -- 85
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 88
	indigoBase = rgba(34, 52, 74, 255), -- 89
	indigoShadow = rgba(18, 28, 42, 255), -- 90
	indigoFold = rgba(54, 78, 104, 255), -- 91
	patchDark = rgba(24, 38, 56, 255), -- 92
	hemEdge = rgba(68, 92, 118, 255), -- 93
	armWrapLinen = rgba(154, 142, 120, 255), -- 94
	armWrapShadow = rgba(102, 92, 78, 255), -- 95
	stitchThread = rgba(232, 224, 204, 255), -- 97
	stitchPinhole = rgba(14, 19, 28, 255), -- 98
	skinBase = rgba(188, 146, 116, 255), -- 99
	skinShadow = rgba(138, 102, 78, 255), -- 100
	skinLight = rgba(216, 178, 148, 255), -- 101
	childSkin = rgba(226, 196, 170, 255), -- 102
	childSkinShadow = rgba(176, 144, 120, 255), -- 103
	childSleeve = rgba(164, 142, 114, 255), -- 104
	childCord = rgba(168, 56, 52, 255) -- 105
} -- 105
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 108
	local sx = lx * scale -- 109
	local sy = ly * scale -- 110
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 111
end -- 108
local function tinted(base, warmth, opacity) -- 114
	local warmTarget = rgba( -- 115
		math.min(255, base.r + 22), -- 116
		math.min(255, base.g + 12), -- 117
		math.max(0, base.b - 10), -- 118
		base.a -- 119
	) -- 119
	local mixed = lerpRGBA( -- 121
		base, -- 121
		warmTarget, -- 121
		clamp01(warmth) -- 121
	) -- 121
	return toColor( -- 122
		mixed, -- 122
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 122
	) -- 122
end -- 114
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 129
	local op = clamp01(opts.opacity or 1) -- 134
	if op <= 0.01 then -- 135
		return -- 136
	end -- 136
	local ox = opts.wristX -- 138
	local oy = opts.wristY -- 139
	local s = math.max(0.2, opts.scale) -- 140
	local cosA = math.cos(opts.angleRad) -- 141
	local sinA = math.sin(opts.angleRad) -- 142
	local w = clamp01(opts.warmth or 0) -- 143
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 144
	local function pt(lx, ly) -- 145
		return rotPt( -- 145
			ox, -- 145
			oy, -- 145
			lx, -- 145
			ly, -- 145
			cosA, -- 145
			sinA, -- 145
			s -- 145
		) -- 145
	end -- 145
	local cuffFront = 6 - pull -- 148
	draw:drawPolygon( -- 149
		{ -- 149
			pt(-250, -48), -- 150
			pt(cuffFront, -36), -- 151
			pt(cuffFront, 38), -- 152
			pt(-250, 52) -- 153
		}, -- 153
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 154
		1.4, -- 154
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 154
	) -- 154
	draw:drawPolygon( -- 157
		{ -- 157
			pt(-250, -48), -- 158
			pt(cuffFront, -36), -- 159
			pt(cuffFront, -8), -- 160
			pt(-250, -14) -- 161
		}, -- 161
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 162
	) -- 162
	draw:drawPolygon( -- 165
		{ -- 165
			pt(-230, 14), -- 166
			pt(cuffFront - 6, 10), -- 167
			pt(cuffFront - 4, 32), -- 168
			pt(-230, 40) -- 169
		}, -- 169
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 170
	) -- 170
	draw:drawSegment( -- 171
		pt(-185, 16), -- 171
		pt(cuffFront - 18, 12), -- 171
		1.2 * s, -- 171
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 171
	) -- 171
	draw:drawSegment( -- 172
		pt(-160, -10), -- 172
		pt(cuffFront - 26, -6), -- 172
		1.1 * s, -- 172
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 172
	) -- 172
	draw:drawPolygon( -- 175
		{ -- 175
			pt(cuffFront - 8, -28), -- 176
			pt(cuffFront + 16, -24), -- 177
			pt(cuffFront + 16, 26), -- 178
			pt(cuffFront - 8, 28) -- 179
		}, -- 179
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 180
		1, -- 180
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 180
	) -- 180
	draw:drawSegment( -- 181
		pt(cuffFront + 3, -25), -- 181
		pt(cuffFront + 7, 25), -- 181
		1.3 * s, -- 181
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 181
	) -- 181
	draw:drawPolygon( -- 184
		{ -- 184
			pt(cuffFront - 16, -37), -- 185
			pt(cuffFront + 2, -36), -- 186
			pt(cuffFront + 2, 38), -- 187
			pt(cuffFront - 16, 39) -- 188
		}, -- 188
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 189
		1.3, -- 189
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 189
	) -- 189
	local pX0 = cuffFront - 72 -- 192
	local pX1 = cuffFront - 18 -- 193
	local pY0 = -16 -- 194
	local pY1 = 22 -- 195
	draw:drawPolygon( -- 196
		{ -- 196
			pt(pX0, pY0), -- 197
			pt(pX1, pY0 + 3), -- 198
			pt(pX1 - 2, pY1), -- 199
			pt(pX0 + 3, pY1 - 2) -- 200
		}, -- 200
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 201
		1.1, -- 201
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 201
	) -- 201
	local seamStartX = pX0 + 6 -- 204
	local seamStartY = pY0 + 5 -- 205
	local seamEndX = pX1 - 7 -- 206
	local seamEndY = pY1 - 5 -- 207
	draw:drawSegment( -- 208
		pt(seamStartX, seamStartY), -- 209
		pt(seamEndX, seamEndY), -- 210
		1.5 * s, -- 211
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 212
	) -- 212
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 215
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 216
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 217
	local stitches = 6 -- 218
	local k = 0 -- 219
	do -- 219
		k = 0 -- 220
		while k < stitches do -- 220
			local t = (k + 0.5) / stitches -- 221
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 222
			local my = seamStartY + (seamEndY - seamStartY) * t -- 223
			local nx = -4.8 -- 224
			local ny = 6.2 -- 225
			local a = pt(mx - nx, my - ny) -- 226
			local b = pt(mx + nx, my + ny) -- 227
			draw:drawDot(a, 1.3 * s, pinCol) -- 228
			draw:drawDot(b, 1.3 * s, pinCol) -- 229
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 230
			if hl > 0.05 then -- 231
				glow:drawSegment( -- 232
					a, -- 232
					b, -- 232
					2.4 * s, -- 232
					toColor( -- 232
						____exports.CUFF_PALETTE.stitchThread, -- 232
						math.floor(74 * hl * op + 0.5) -- 232
					) -- 232
				) -- 232
			end -- 232
			k = k + 1 -- 220
		end -- 220
	end -- 220
	local handBase = cuffFront + 14 -- 237
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 238
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 239
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 240
	if opts.pose == "wipe" then -- 242
		draw:drawPolygon( -- 244
			{ -- 244
				pt(handBase - 4, -20), -- 245
				pt(handBase + 46, -24), -- 246
				pt(handBase + 54, 4), -- 247
				pt(handBase + 38, 22), -- 248
				pt(handBase - 4, 20) -- 249
			}, -- 249
			skinCol, -- 250
			1.1, -- 250
			skinSh -- 250
		) -- 250
		draw:drawSegment( -- 251
			pt(handBase + 16, -2), -- 251
			pt(handBase + 52, -6), -- 251
			1.4 * s, -- 251
			skinSh -- 251
		) -- 251
		draw:drawSegment( -- 252
			pt(handBase + 14, 10), -- 252
			pt(handBase + 46, 8), -- 252
			1.4 * s, -- 252
			skinSh -- 252
		) -- 252
	elseif opts.pose == "pinch" then -- 253
		draw:drawPolygon( -- 255
			{ -- 255
				pt(handBase - 4, -22), -- 256
				pt(handBase + 44, -18), -- 257
				pt(handBase + 54, 6), -- 258
				pt(handBase + 28, 26), -- 259
				pt(handBase - 4, 22) -- 260
			}, -- 260
			skinCol, -- 261
			1.1, -- 261
			skinSh -- 261
		) -- 261
		draw:drawSegment( -- 262
			pt(handBase + 24, 16), -- 262
			pt(handBase + 52, 4), -- 262
			6.2 * s, -- 262
			skinHi -- 262
		) -- 262
		draw:drawSegment( -- 263
			pt(handBase + 30, -14), -- 263
			pt(handBase + 54, -4), -- 263
			5.6 * s, -- 263
			skinCol -- 263
		) -- 263
	elseif opts.pose == "clasp" then -- 264
		draw:drawPolygon( -- 266
			{ -- 266
				pt(handBase - 2, -22), -- 267
				pt(handBase + 52, -20), -- 268
				pt(handBase + 66, 2), -- 269
				pt(handBase + 44, 26), -- 270
				pt(handBase - 2, 22) -- 271
			}, -- 271
			skinCol, -- 272
			1.2, -- 272
			skinSh -- 272
		) -- 272
		draw:drawSegment( -- 273
			pt(handBase + 26, 20), -- 273
			pt(handBase + 58, 12), -- 273
			6.5 * s, -- 273
			skinHi -- 273
		) -- 273
		draw:drawSegment( -- 274
			pt(handBase + 46, -14), -- 274
			pt(handBase + 72, -10), -- 274
			5.2 * s, -- 274
			skinCol -- 274
		) -- 274
		draw:drawSegment( -- 275
			pt(handBase + 48, -2), -- 275
			pt(handBase + 76, 1), -- 275
			5.4 * s, -- 275
			skinCol -- 275
		) -- 275
	else -- 275
		local reachExt = opts.pose == "reach" and 10 or 0 -- 278
		draw:drawPolygon( -- 279
			{ -- 279
				pt(handBase - 4, -20), -- 280
				pt(handBase + 44 + reachExt, -18), -- 281
				pt(handBase + 56 + reachExt, 4), -- 282
				pt(handBase + 34 + reachExt * 0.5, 24), -- 283
				pt(handBase - 4, 20) -- 284
			}, -- 284
			skinCol, -- 285
			1.1, -- 285
			skinSh -- 285
		) -- 285
		draw:drawSegment( -- 287
			pt(handBase + 42 + reachExt, -14), -- 287
			pt(handBase + 74 + reachExt, -16), -- 287
			4.6 * s, -- 287
			skinCol -- 287
		) -- 287
		draw:drawSegment( -- 288
			pt(handBase + 46 + reachExt, -4), -- 288
			pt(handBase + 80 + reachExt, -3), -- 288
			4.8 * s, -- 288
			skinCol -- 288
		) -- 288
		draw:drawSegment( -- 289
			pt(handBase + 44 + reachExt, 6), -- 289
			pt(handBase + 76 + reachExt, 9), -- 289
			4.6 * s, -- 289
			skinCol -- 289
		) -- 289
		draw:drawSegment( -- 290
			pt(handBase + 26 + reachExt * 0.5, 18), -- 290
			pt(handBase + 56 + reachExt * 0.6, 28), -- 290
			5.2 * s, -- 290
			skinHi -- 290
		) -- 290
	end -- 290
end -- 129
--- 绘制小满伸出的小手（含腕上暗红指南针布套短绳）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord) -- 295
	if withCompassCord == nil then -- 303
		withCompassCord = true -- 303
	end -- 303
	local op = clamp01(opacity) -- 305
	if op <= 0.01 then -- 306
		return -- 307
	end -- 307
	local cosA = math.cos(angleRad) -- 309
	local sinA = math.sin(angleRad) -- 310
	local s = math.max(0.2, scale) -- 311
	local function pt(lx, ly) -- 312
		return rotPt( -- 312
			ox, -- 312
			oy, -- 312
			lx, -- 312
			ly, -- 312
			cosA, -- 312
			sinA, -- 312
			s -- 312
		) -- 312
	end -- 312
	local skin = toColor( -- 313
		____exports.CUFF_PALETTE.childSkin, -- 313
		math.floor(255 * op + 0.5) -- 313
	) -- 313
	local sh = toColor( -- 314
		____exports.CUFF_PALETTE.childSkinShadow, -- 314
		math.floor(255 * op + 0.5) -- 314
	) -- 314
	local sleeve = toColor( -- 315
		____exports.CUFF_PALETTE.childSleeve, -- 315
		math.floor(255 * op + 0.5) -- 315
	) -- 315
	if pose == "two_fingers" then -- 317
		draw:drawSegment( -- 319
			pt(-18, -4), -- 319
			pt(18, -5), -- 319
			5 * s, -- 319
			skin -- 319
		) -- 319
		draw:drawSegment( -- 320
			pt(-16, 6), -- 320
			pt(22, 7), -- 320
			5 * s, -- 320
			skin -- 320
		) -- 320
		draw:drawDot( -- 321
			pt(18, -5), -- 321
			2.5 * s, -- 321
			sh -- 321
		) -- 321
		draw:drawDot( -- 322
			pt(22, 7), -- 322
			2.5 * s, -- 322
			sh -- 322
		) -- 322
		return -- 323
	end -- 323
	draw:drawPolygon( -- 327
		{ -- 327
			pt(-135, -24), -- 328
			pt(-6, -18), -- 329
			pt(-6, 18), -- 330
			pt(-135, 26) -- 331
		}, -- 331
		sleeve, -- 332
		1.1, -- 332
		sh -- 332
	) -- 332
	if withCompassCord then -- 334
		draw:drawSegment( -- 336
			pt(-10, -18), -- 336
			pt(-4, 18), -- 336
			2.6 * s, -- 336
			toColor( -- 336
				____exports.CUFF_PALETTE.childCord, -- 336
				math.floor(235 * op + 0.5) -- 336
			) -- 336
		) -- 336
		draw:drawSegment( -- 337
			pt(-4, -18), -- 337
			pt(2, 18), -- 337
			2.2 * s, -- 337
			toColor( -- 337
				____exports.CUFF_PALETTE.childCord, -- 337
				math.floor(200 * op + 0.5) -- 337
			) -- 337
		) -- 337
	end -- 337
	draw:drawPolygon( -- 341
		{ -- 341
			pt(-4, -15), -- 342
			pt(28, -14), -- 343
			pt(34, 2), -- 344
			pt(22, 17), -- 345
			pt(-4, 15) -- 346
		}, -- 346
		skin, -- 347
		1, -- 347
		sh -- 347
	) -- 347
	if pose == "clutch" or pose == "clasp" then -- 349
		draw:drawSegment( -- 351
			pt(24, -11), -- 351
			pt(44, -6), -- 351
			4 * s, -- 351
			skin -- 351
		) -- 351
		draw:drawSegment( -- 352
			pt(26, -2), -- 352
			pt(47, 2), -- 352
			4.2 * s, -- 352
			skin -- 352
		) -- 352
		draw:drawSegment( -- 353
			pt(24, 6), -- 353
			pt(43, 9), -- 353
			4 * s, -- 353
			skin -- 353
		) -- 353
		draw:drawSegment( -- 354
			pt(16, 14), -- 354
			pt(34, 16), -- 354
			4.2 * s, -- 354
			skin -- 354
		) -- 354
	else -- 354
		draw:drawSegment( -- 357
			pt(26, -12), -- 357
			pt(52, -16), -- 357
			3.6 * s, -- 357
			skin -- 357
		) -- 357
		draw:drawSegment( -- 358
			pt(29, -4), -- 358
			pt(57, -5), -- 358
			3.8 * s, -- 358
			skin -- 358
		) -- 358
		draw:drawSegment( -- 359
			pt(28, 4), -- 359
			pt(54, 7), -- 359
			3.6 * s, -- 359
			skin -- 359
		) -- 359
		draw:drawSegment( -- 360
			pt(24, 11), -- 360
			pt(46, 17), -- 360
			3.4 * s, -- 360
			skin -- 360
		) -- 360
		draw:drawSegment( -- 361
			pt(14, 15), -- 361
			pt(34, 26), -- 361
			4 * s, -- 361
			skin -- 361
		) -- 361
	end -- 361
end -- 295
--- 仅在 G05 重逢抬镜后绘制序章像素风风格的蹲姿周戍近景（复用真实像素立绘，与本体画风 100% 统一）
local function drawZhouShuReunionPortrait(draw, inkDraw, art, glow, cx, cy, scale, alpha) -- 366
	local a = clamp01(alpha) -- 376
	if a <= 0.01 then -- 377
		return -- 378
	end -- 378
	local s = scale -- 380
	local cardW = 212 * s -- 381
	local cardH = 248 * s -- 382
	local x0 = cx - cardW * 0.5 -- 383
	local y0 = cy - cardH * 0.5 -- 384
	fillVGradRect( -- 387
		draw, -- 388
		x0, -- 389
		y0, -- 390
		cardW, -- 391
		cardH, -- 392
		Color( -- 393
			10, -- 393
			15, -- 393
			24, -- 393
			math.floor(224 * a + 0.5) -- 393
		), -- 393
		Color( -- 394
			22, -- 394
			34, -- 394
			52, -- 394
			math.floor(234 * a + 0.5) -- 394
		) -- 394
	) -- 394
	local placed = art:tryPlace( -- 397
		"soldier_offer", -- 398
		"g05_zhoushu_closeup", -- 399
		cx + 4 * s, -- 400
		y0 + 18 * s, -- 401
		156 * s, -- 402
		214 * s, -- 403
		{opacity = a, layer = 4} -- 404
	) -- 404
	if not placed then -- 406
		art:tryPlace( -- 407
			"soldier_idle", -- 408
			"g05_zhoushu_closeup", -- 409
			cx, -- 410
			y0 + 18 * s, -- 411
			156 * s, -- 412
			214 * s, -- 413
			{opacity = a, layer = 4} -- 414
		) -- 414
	end -- 414
	inkDraw:drawRect( -- 418
		Rect(x0, y0, cardW, cardH), -- 418
		Color(0, 0, 0, 0), -- 418
		1.1, -- 418
		toColor( -- 418
			PALETTE.silkDim, -- 418
			math.floor(165 * a + 0.5) -- 418
		) -- 418
	) -- 418
	inkDraw:drawRect( -- 419
		Rect(x0 + 4, y0 + 4, cardW - 8, cardH - 8), -- 419
		Color(0, 0, 0, 0), -- 419
		0.7, -- 419
		toColor( -- 419
			PALETTE.amber, -- 419
			math.floor(78 * a + 0.5) -- 419
		) -- 419
	) -- 419
	fillRadialGlow( -- 420
		glow, -- 420
		cx + 12 * s, -- 420
		cy + 22 * s, -- 420
		96 * s, -- 420
		96 * s, -- 420
		Color( -- 420
			214, -- 420
			224, -- 420
			236, -- 420
			math.floor(38 * a + 0.5) -- 420
		), -- 420
		Color(120, 148, 178, 0), -- 420
		16 -- 420
	) -- 420
end -- 366
____exports.CuffShotsPlugin = __TS__Class() -- 423
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 423
CuffShotsPlugin.name = "CuffShotsPlugin" -- 423
function CuffShotsPlugin.prototype.____constructor(self) -- 423
	self.id = "fe-01-cuff-shots" -- 424
	self.animTime = 0 -- 426
	self.prevPhase = "" -- 427
	self.activeShot = "" -- 428
	self.rehearsalShot = "" -- 431
	self.rehearsalTime = 0 -- 432
	self.rehearsalDuration = 3 -- 433
	self.rehearsalAutoAdvance = true -- 434
	self.p03Progress = 0 -- 437
	self.p05ExitTimer = -1 -- 438
	self.g05SleeveExtend = 0 -- 439
	self.g05ReunionElapsed = 0 -- 440
	self.g05LineTriggered = false -- 441
	self.g05AbortVisualCount = 0 -- 442
	self.lastReleasedAbortCount = 0 -- 443
end -- 423
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 445
	self.animTime = 0 -- 446
	self.prevPhase = p.phase -- 447
	self.activeShot = "" -- 448
	self.p03Progress = 0 -- 449
	self.p05ExitTimer = -1 -- 450
	self.g05SleeveExtend = 0 -- 451
	self.g05ReunionElapsed = 0 -- 452
	self.g05LineTriggered = false -- 453
	self.g05AbortVisualCount = 0 -- 454
	self.lastReleasedAbortCount = 0 -- 455
end -- 445
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 463
	self.rehearsalShot = shot -- 464
	if shot == "" then -- 465
		self.rehearsalTime = 0 -- 466
		self.rehearsalAutoAdvance = true -- 467
		return -- 468
	end -- 468
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 470
	if fixedTime ~= nil then -- 471
		self.rehearsalTime = math.max( -- 472
			0, -- 472
			math.min(self.rehearsalDuration, fixedTime) -- 472
		) -- 472
		self.rehearsalAutoAdvance = false -- 473
	else -- 473
		self.rehearsalTime = 0 -- 475
		self.rehearsalAutoAdvance = true -- 476
	end -- 476
end -- 463
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 480
	self:rehearseShot("") -- 481
end -- 480
function CuffShotsPlugin.prototype.getDebugState(self) -- 484
	return { -- 485
		activeShot = self.activeShot, -- 486
		rehearsalShot = self.rehearsalShot, -- 487
		rehearsalTime = self.rehearsalTime, -- 488
		rehearsalDuration = self.rehearsalDuration, -- 489
		p03Progress = self.p03Progress, -- 490
		p05ExitTimer = self.p05ExitTimer, -- 491
		g05SleeveExtend = self.g05SleeveExtend, -- 492
		g05ReunionElapsed = self.g05ReunionElapsed, -- 493
		g05LineTriggered = self.g05LineTriggered, -- 494
		g05AbortVisualCount = self.g05AbortVisualCount -- 495
	} -- 495
end -- 484
function CuffShotsPlugin.prototype.update(self, ctx) -- 499
	local p = ctx.p -- 500
	local view = ctx.view -- 501
	local dt = ctx.paused and 0 or ctx.worldDt -- 502
	self.animTime = self.animTime + dt -- 503
	if self.rehearsalShot ~= "" then -- 506
		self.activeShot = self.rehearsalShot -- 507
		if self.rehearsalAutoAdvance and dt > 0 then -- 508
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 509
		end -- 509
		if not ctx.paused then -- 511
			self:triggerRehearsalAudio(ctx) -- 512
		end -- 512
		self.prevPhase = p.phase -- 514
		return -- 515
	end -- 515
	self.activeShot = "" -- 518
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 521
		self.activeShot = "P03" -- 522
		self.p03Progress = clamp01(p.phaseTick / 60) -- 523
		if not ctx.paused and self.p03Progress >= 0.25 then -- 524
			ctx.audio:playOnce( -- 525
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 526
				"sfx", -- 527
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 528
				0.86, -- 529
				"cuff:p03:cloth_wipe_wood", -- 530
				p.ticks -- 531
			) -- 531
		end -- 531
		self.prevPhase = p.phase -- 534
		return -- 535
	else -- 535
		self.p03Progress = 0 -- 537
	end -- 537
	if p.room.key == "gate" then -- 541
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 542
			self.p05ExitTimer = 0 -- 543
			if not ctx.paused then -- 544
				ctx.audio:playOnce( -- 545
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 546
					"sfx", -- 547
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 548
					0.92, -- 549
					"cuff:p05:gate_slam", -- 550
					p.ticks -- 551
				) -- 551
				ctx.audio:playOnce( -- 553
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 554
					"voice", -- 555
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 556
					0.88, -- 557
					"cuff:p05:line_farewell", -- 558
					p.ticks -- 559
				) -- 559
			end -- 559
		end -- 559
		if self.p05ExitTimer >= 0 then -- 563
			if p.phase ~= "gate-count" or view.countElapsedTicks > 240 then -- 564
				self.p05ExitTimer = -1 -- 565
			else -- 565
				if dt > 0 then -- 567
					self.p05ExitTimer = self.p05ExitTimer + dt -- 568
				end -- 568
				if self.p05ExitTimer >= 3.6 then -- 570
					self.p05ExitTimer = -1 -- 571
				else -- 571
					self.activeShot = "P05" -- 573
				end -- 573
			end -- 573
		end -- 573
	else -- 573
		self.p05ExitTimer = -1 -- 578
	end -- 578
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 582
	if inGateReunion then -- 589
		self.activeShot = "G05" -- 590
		local gr = view.gateReunion -- 591
		local completed = p.phase == "gate-hand" or gr.completed -- 592
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 594
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 595
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 596
			if not ctx.paused and view.isRehearsal then -- 597
				ctx.audio:playOnce( -- 598
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 599
					"sfx", -- 600
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 601
					0.72, -- 602
					"cuff:g05:reunion_release", -- 603
					p.ticks -- 604
				) -- 604
			end -- 604
		end -- 604
		if completed then -- 609
			self.g05SleeveExtend = 1 -- 610
			if dt > 0 then -- 611
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 612
			end -- 612
			if not ctx.paused and not self.g05LineTriggered then -- 614
				if view.isRehearsal then -- 615
					ctx.audio:playOnce( -- 616
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 617
						"sfx", -- 618
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 619
						0.88, -- 620
						"cuff:g05:hand_held", -- 621
						p.ticks -- 622
					) -- 622
				end -- 622
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 625
					self.g05LineTriggered = true -- 626
					ctx.audio:playOnce( -- 627
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 628
						"voice", -- 629
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 630
						0.94, -- 631
						"cuff:g05:line_reunion", -- 632
						p.ticks -- 633
					) -- 633
				end -- 633
			end -- 633
		else -- 633
			self.g05ReunionElapsed = 0 -- 638
			self.g05LineTriggered = false -- 639
			if gr.holding or gr.holdProgress > 0.001 then -- 640
				if gr.holdProgress >= self.g05SleeveExtend then -- 642
					self.g05SleeveExtend = gr.holdProgress -- 643
				elseif dt > 0 then -- 644
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 645
				end -- 645
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 647
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 649
			end -- 649
		end -- 649
	else -- 649
		self.g05SleeveExtend = 0 -- 653
		self.g05ReunionElapsed = 0 -- 654
		self.g05LineTriggered = false -- 655
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 656
	end -- 656
	self.prevPhase = p.phase -- 659
end -- 499
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 662
	local sid = ctx.events.roomSessionId -- 663
	local t = self.rehearsalTime -- 664
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 665
		ctx.audio:playOnce( -- 666
			"reh:p03:wipe:" .. tostring(sid), -- 666
			"sfx", -- 666
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 666
			0.88, -- 666
			"cuff:p03:cloth_wipe_wood", -- 666
			ctx.p.ticks -- 666
		) -- 666
	elseif self.rehearsalShot == "P05" then -- 667
		if t >= 0.9 then -- 668
			ctx.audio:playOnce( -- 669
				"reh:p05:line:" .. tostring(sid), -- 669
				"voice", -- 669
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 669
				0.9, -- 669
				"cuff:p05:line_farewell", -- 669
				ctx.p.ticks -- 669
			) -- 669
		end -- 669
		if t >= 2.75 then -- 671
			ctx.audio:playOnce( -- 672
				"reh:p05:slam:" .. tostring(sid), -- 672
				"sfx", -- 672
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 672
				0.94, -- 672
				"cuff:p05:gate_slam", -- 672
				ctx.p.ticks -- 672
			) -- 672
			ctx.audio:playLoop( -- 673
				"reh_p05_water", -- 673
				"water", -- 673
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 673
				0.42, -- 673
				ctx.p.ticks -- 673
			) -- 673
		end -- 673
	elseif self.rehearsalShot == "G05" then -- 675
		if t >= 0.05 then -- 676
			ctx.audio:playOnce( -- 677
				"reh:g05:knock1:" .. tostring(sid), -- 677
				"sfx", -- 677
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 677
				0.88, -- 677
				"knock:gate:1", -- 677
				ctx.p.ticks -- 677
			) -- 677
		end -- 677
		if t >= 0.25 then -- 679
			ctx.audio:playOnce( -- 680
				"reh:g05:knock2:" .. tostring(sid), -- 680
				"sfx", -- 680
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 680
				0.92, -- 680
				"knock:gate:2", -- 680
				ctx.p.ticks -- 680
			) -- 680
		end -- 680
		if t >= 1.55 then -- 682
			ctx.audio:playOnce( -- 683
				"reh:g05:clasp:" .. tostring(sid), -- 683
				"sfx", -- 683
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 683
				0.88, -- 683
				"cuff:g05:hand_held", -- 683
				ctx.p.ticks -- 683
			) -- 683
		end -- 683
		if t >= 2.35 then -- 685
			ctx.audio:playOnce( -- 686
				"reh:g05:line:" .. tostring(sid), -- 686
				"voice", -- 686
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 686
				0.94, -- 686
				"cuff:g05:line_reunion", -- 686
				ctx.p.ticks -- 686
			) -- 686
		end -- 686
	end -- 686
end -- 662
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 691
	if self.activeShot == "" then -- 698
		return false -- 699
	end -- 699
	local w = ctx.uiW -- 701
	local h = ctx.uiH -- 702
	if self.activeShot == "P03" then -- 704
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 705
		self:renderP03Shot( -- 708
			uiDraw, -- 708
			uiInkDraw, -- 708
			uiArt, -- 708
			uiGlow, -- 708
			ctx, -- 708
			w, -- 708
			h, -- 708
			prog -- 708
		) -- 708
		return true -- 709
	end -- 709
	if self.activeShot == "P05" then -- 712
		if self.rehearsalShot == "P05" then -- 713
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 714
			self:renderP05FullShot( -- 715
				uiDraw, -- 715
				uiInkDraw, -- 715
				uiArt, -- 715
				uiGlow, -- 715
				ctx, -- 715
				w, -- 715
				h, -- 715
				prog -- 715
			) -- 715
			return true -- 716
		end -- 716
		self:renderP05ExitBridge( -- 719
			uiDraw, -- 719
			uiInkDraw, -- 719
			uiArt, -- 719
			uiGlow, -- 719
			ctx, -- 719
			w, -- 719
			h, -- 719
			clamp01(self.p05ExitTimer / 3.6) -- 719
		) -- 719
		return false -- 720
	end -- 720
	if self.activeShot == "G05" then -- 723
		if self.rehearsalShot == "G05" then -- 724
			self:renderG05RehearsalShot( -- 725
				uiDraw, -- 725
				uiInkDraw, -- 725
				uiArt, -- 725
				uiGlow, -- 725
				ctx, -- 725
				w, -- 725
				h, -- 725
				self.rehearsalTime -- 725
			) -- 725
			return true -- 726
		end -- 726
		self:renderG05LiveShot( -- 728
			uiDraw, -- 728
			uiInkDraw, -- 728
			uiArt, -- 728
			uiGlow, -- 728
			ctx, -- 728
			w, -- 728
			h -- 728
		) -- 728
		return true -- 729
	end -- 729
	return false -- 732
end -- 691
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 741
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 751
	local boxW = math.min(w - 140, 820) -- 753
	local boxH = math.min(h - 190, 390) -- 754
	local bx = (w - boxW) * 0.5 -- 755
	local by = (h - boxH) * 0.5 + 14 -- 756
	uiDraw:drawRect( -- 758
		Rect(0, 0, w, h), -- 758
		Color( -- 758
			7, -- 758
			9, -- 758
			14, -- 758
			math.floor(135 * fade + 0.5) -- 758
		) -- 758
	) -- 758
	fillVGradRect( -- 760
		uiDraw, -- 760
		bx, -- 760
		by, -- 760
		boxW, -- 760
		boxH, -- 760
		Color( -- 760
			14, -- 760
			13, -- 760
			16, -- 760
			math.floor(248 * fade + 0.5) -- 760
		), -- 760
		Color( -- 760
			24, -- 760
			24, -- 760
			30, -- 760
			math.floor(248 * fade + 0.5) -- 760
		) -- 760
	) -- 760
	local rimY = by + boxH * 0.34 -- 762
	uiDraw:drawRect( -- 763
		Rect(bx, by, boxW, rimY - by), -- 763
		Color( -- 763
			54, -- 763
			40, -- 763
			30, -- 763
			math.floor(252 * fade + 0.5) -- 763
		) -- 763
	) -- 763
	uiDraw:drawSegment( -- 764
		Vec2(bx, rimY), -- 764
		Vec2(bx + boxW, rimY), -- 764
		2.2, -- 764
		Color( -- 764
			128, -- 764
			100, -- 764
			76, -- 764
			math.floor(220 * fade + 0.5) -- 764
		) -- 764
	) -- 764
	local crackX = bx + boxW * 0.72 -- 766
	uiDraw:drawRect( -- 767
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 767
		Color( -- 767
			8, -- 767
			9, -- 767
			13, -- 767
			math.floor(245 * fade + 0.5) -- 767
		) -- 767
	) -- 767
	uiDraw:drawRect( -- 768
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 768
		Color( -- 768
			46, -- 768
			35, -- 768
			26, -- 768
			math.floor(250 * fade + 0.5) -- 768
		) -- 768
	) -- 768
	local wipeT = smoothstep(0.3, 0.66, prog) -- 771
	local shardOffsets = {{ -- 772
		x = -72, -- 773
		y = 8, -- 773
		dx = 46, -- 773
		dy = -38, -- 773
		r = 9 -- 773
	}, { -- 774
		x = -34, -- 774
		y = 12, -- 774
		dx = 64, -- 774
		dy = -46, -- 774
		r = 7 -- 774
	}, { -- 775
		x = 4, -- 775
		y = 6, -- 775
		dx = 82, -- 775
		dy = -52, -- 775
		r = 10 -- 775
	}, { -- 776
		x = 32, -- 776
		y = 10, -- 776
		dx = 74, -- 776
		dy = -34, -- 776
		r = 6 -- 776
	}} -- 776
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 778
	if shardAlpha > 0.02 then -- 779
		local si = 0 -- 780
		do -- 780
			si = 0 -- 781
			while si < #shardOffsets do -- 781
				local sh = shardOffsets[si + 1] -- 782
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 783
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 784
				uiDraw:drawPolygon( -- 785
					{ -- 785
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 786
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 787
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 788
					}, -- 788
					Color( -- 789
						212, -- 789
						218, -- 789
						224, -- 789
						math.floor(235 * shardAlpha + 0.5) -- 789
					), -- 789
					0.9, -- 789
					Color( -- 789
						92, -- 789
						108, -- 789
						126, -- 789
						math.floor(200 * shardAlpha + 0.5) -- 789
					) -- 789
				) -- 789
				si = si + 1 -- 781
			end -- 781
		end -- 781
	end -- 781
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 794
	local handOut = smoothstep(0.7, 0.9, prog) -- 795
	if handOut > 0.05 then -- 796
		drawChildHand( -- 797
			uiDraw, -- 798
			crackX + 18 - handOut * 66, -- 799
			rimY + 52, -- 800
			math.pi, -- 801
			1.05, -- 802
			"open_fingers", -- 803
			fade * handOut, -- 804
			false -- 805
		) -- 805
	elseif fingerEnter > 0.02 then -- 807
		drawChildHand( -- 808
			uiDraw, -- 809
			crackX + 12 - fingerEnter * 24, -- 810
			rimY + 46, -- 811
			math.pi, -- 812
			1.08, -- 813
			"two_fingers", -- 814
			fade * fingerEnter, -- 815
			false -- 816
		) -- 816
	end -- 816
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 821
	if sleeveEnter > 0.01 then -- 822
		local reachT = smoothstep(0.66, 0.88, prog) -- 823
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 824
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 825
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 826
		local pose = reachT > 0.2 and "reach" or "wipe" -- 827
		____exports.drawPatchedCuff( -- 828
			uiDraw, -- 828
			uiGlow, -- 828
			{ -- 828
				wristX = wx, -- 829
				wristY = wy, -- 830
				angleRad = ang, -- 831
				scale = 1.06, -- 832
				pose = pose, -- 833
				opacity = fade * sleeveEnter, -- 834
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 835
				warmth = 0.18 -- 836
			} -- 836
		) -- 836
	end -- 836
	uiInkDraw:drawRect( -- 841
		Rect(bx, by, boxW, boxH), -- 841
		Color(0, 0, 0, 0), -- 841
		1, -- 841
		toColor( -- 841
			PALETTE.silkDim, -- 841
			math.floor(145 * fade + 0.5) -- 841
		) -- 841
	) -- 841
	drawSilkVeil( -- 842
		uiDraw, -- 842
		uiArt, -- 842
		"p03_sub_veil", -- 842
		w * 0.5, -- 842
		42, -- 842
		520, -- 842
		42, -- 842
		PALETTE.inkWash, -- 842
		0.82 * fade, -- 842
		-1 -- 842
	) -- 842
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 843
	ctx.texts:put( -- 846
		"sm", -- 846
		subText, -- 846
		w * 0.5, -- 846
		42, -- 846
		toColor(PALETTE.textBright), -- 846
		0.5, -- 846
		0.5, -- 846
		"Center", -- 846
		1, -- 846
		fade, -- 846
		0.08 -- 846
	) -- 846
end -- 741
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 855
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 865
	local boxW = math.min(w - 120, 860) -- 866
	local boxH = math.min(h - 180, 400) -- 867
	local bx = (w - boxW) * 0.5 -- 868
	local by = (h - boxH) * 0.5 + 14 -- 869
	uiDraw:drawRect( -- 871
		Rect(0, 0, w, h), -- 871
		Color( -- 871
			7, -- 871
			9, -- 871
			14, -- 871
			math.floor(145 * fade + 0.5) -- 871
		) -- 871
	) -- 871
	fillVGradRect( -- 873
		uiDraw, -- 873
		bx, -- 873
		by, -- 873
		boxW, -- 873
		boxH, -- 873
		Color( -- 873
			14, -- 873
			22, -- 873
			34, -- 873
			math.floor(248 * fade + 0.5) -- 873
		), -- 873
		Color( -- 873
			28, -- 873
			42, -- 873
			58, -- 873
			math.floor(248 * fade + 0.5) -- 873
		) -- 873
	) -- 873
	fillRadialGlow( -- 875
		uiGlow, -- 875
		bx + boxW * 0.66, -- 875
		by + boxH * 0.32, -- 875
		220, -- 875
		68, -- 875
		Color( -- 875
			152, -- 875
			194, -- 875
			224, -- 875
			math.floor(74 * fade + 0.5) -- 875
		), -- 875
		Color(40, 70, 108, 0), -- 875
		16 -- 875
	) -- 875
	local releaseT = smoothstep(0.68, 0.94, prog) -- 877
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 878
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 881
	local cuffY = by + boxH * 0.52 -- 882
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 883
		wristX = cuffX, -- 884
		wristY = cuffY, -- 885
		angleRad = -0.06, -- 886
		scale = 1.12, -- 887
		pose = pinchT > 0.25 and "pinch" or "open", -- 888
		opacity = fade * (1 - releaseT * 0.88), -- 889
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 890
		warmth = 0.12 -- 891
	}) -- 891
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 895
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 896
	drawChildHand( -- 897
		uiDraw, -- 898
		childHandX, -- 899
		childHandY, -- 900
		math.pi + 0.12, -- 901
		1.12, -- 902
		releaseT > 0.35 and "open_fingers" or "clutch", -- 903
		fade, -- 904
		true -- 905
	) -- 905
	if releaseT > 0.01 then -- 909
		local dropH = boxH * releaseT * 0.88 -- 910
		uiDraw:drawRect( -- 911
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 911
			Color( -- 911
				26, -- 911
				22, -- 911
				20, -- 911
				math.floor(238 * fade + 0.5) -- 911
			) -- 911
		) -- 911
		uiDraw:drawSegment( -- 912
			Vec2(bx, by + boxH - dropH), -- 912
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 912
			2.4, -- 912
			Color( -- 912
				118, -- 912
				104, -- 912
				88, -- 912
				math.floor(220 * fade + 0.5) -- 912
			) -- 912
		) -- 912
	end -- 912
	uiInkDraw:drawRect( -- 915
		Rect(bx, by, boxW, boxH), -- 915
		Color(0, 0, 0, 0), -- 915
		1, -- 915
		toColor( -- 915
			PALETTE.silkDim, -- 915
			math.floor(150 * fade + 0.5) -- 915
		) -- 915
	) -- 915
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 918
	if lineAlpha > 0.02 then -- 919
		drawSilkVeil( -- 920
			uiDraw, -- 920
			uiArt, -- 920
			"p05_sub_veil", -- 920
			w * 0.5, -- 920
			42, -- 920
			740, -- 920
			44, -- 920
			PALETTE.inkWash, -- 920
			0.86 * lineAlpha, -- 920
			-1 -- 920
		) -- 920
		drawHairline( -- 921
			uiInkDraw, -- 921
			uiArt, -- 921
			"p05_sub_line", -- 921
			w * 0.5, -- 921
			62, -- 921
			520, -- 921
			PALETTE.silkDim, -- 921
			0.52 * lineAlpha, -- 921
			true, -- 921
			2 -- 921
		) -- 921
		ctx.texts:put( -- 922
			"sm", -- 922
			LINE_P05, -- 922
			w * 0.5, -- 922
			42, -- 922
			toColor(PALETTE.textBright), -- 922
			0.5, -- 922
			0.5, -- 922
			"Center", -- 922
			0.8, -- 922
			lineAlpha, -- 922
			0.08 -- 922
		) -- 922
	end -- 922
end -- 855
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 927
	local enter = smoothstep(0, 0.12, t) -- 937
	local out = smoothstep(0.66, 1, t) -- 938
	local alpha = enter * (1 - out) -- 939
	if alpha <= 0.02 then -- 940
		return -- 941
	end -- 941
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 943
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 944
		wristX = w * 0.25 - out * 240, -- 945
		wristY = h * 0.4, -- 946
		angleRad = -0.05, -- 947
		scale = 0.94, -- 948
		pose = pinchT > 0.25 and "pinch" or "open", -- 949
		opacity = alpha * 0.94, -- 950
		stitchHighlight = 0.45 + 0.28 * pinchT -- 951
	}) -- 951
	drawChildHand( -- 953
		uiDraw, -- 954
		w * 0.35 + out * 26, -- 955
		h * 0.37 - out * 10, -- 956
		math.pi + 0.1, -- 957
		0.94, -- 958
		out > 0.32 and "open_fingers" or "clutch", -- 959
		alpha * 0.92, -- 960
		true -- 961
	) -- 961
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 963
	if lineAlpha > 0.02 then -- 964
		local subY = 92 -- 965
		drawSilkVeil( -- 966
			uiDraw, -- 966
			uiArt, -- 966
			"p05_live_veil", -- 966
			w * 0.5, -- 966
			subY, -- 966
			760, -- 966
			44, -- 966
			PALETTE.inkWash, -- 966
			0.86 * lineAlpha, -- 966
			-1 -- 966
		) -- 966
		drawHairline( -- 967
			uiInkDraw, -- 967
			uiArt, -- 967
			"p05_live_line", -- 967
			w * 0.5, -- 967
			subY + 20, -- 967
			520, -- 967
			PALETTE.silkDim, -- 967
			0.52 * lineAlpha, -- 967
			true, -- 967
			2 -- 967
		) -- 967
		ctx.texts:put( -- 968
			"sm", -- 968
			LINE_P05, -- 968
			w * 0.5, -- 968
			subY, -- 968
			toColor(PALETTE.textBright), -- 968
			0.5, -- 968
			0.5, -- 968
			"Center", -- 968
			0.8, -- 968
			lineAlpha, -- 968
			0.08 -- 968
		) -- 968
	end -- 968
end -- 927
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 978
	local view = ctx.view -- 987
	local gr = view.gateReunion -- 988
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 989
	local ext = clamp01(self.g05SleeveExtend) -- 990
	if not completed then -- 992
		if ext > 0.008 then -- 994
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 996
			fillVGradRect( -- 997
				uiDraw, -- 997
				0, -- 997
				h * 0.28, -- 997
				w, -- 997
				h * 0.16, -- 997
				Color(8, 11, 18, 0), -- 997
				Color(8, 11, 18, veilA) -- 997
			) -- 997
			fillVGradRect( -- 998
				uiDraw, -- 998
				0, -- 998
				h * 0.44, -- 998
				w, -- 998
				h * 0.16, -- 998
				Color(8, 11, 18, veilA), -- 998
				Color(8, 11, 18, 0) -- 998
			) -- 998
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 1000
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1001
			____exports.drawPatchedCuff( -- 1002
				uiDraw, -- 1002
				uiGlow, -- 1002
				{ -- 1002
					wristX = cuffX, -- 1003
					wristY = cuffY, -- 1004
					angleRad = -0.05, -- 1005
					scale = 1.08, -- 1006
					pose = ext > 0.82 and "clasp" or "reach", -- 1007
					opacity = clamp01(0.32 + ext * 0.68), -- 1008
					stitchHighlight = 0.35 + 0.6 * ext -- 1009
				} -- 1009
			) -- 1009
			local childX = w * 0.64 - ext * (w * 0.13) -- 1013
			local childY = h * 0.41 + ext * 14 -- 1014
			drawChildHand( -- 1015
				uiDraw, -- 1016
				childX, -- 1017
				childY, -- 1018
				math.pi + 0.08, -- 1019
				1.06, -- 1020
				ext > 0.88 and "clasp" or "reach_up", -- 1021
				clamp01(0.25 + ext * 0.75), -- 1022
				true -- 1023
			) -- 1023
			local barW = 240 -- 1027
			local bx0 = w * 0.5 - barW * 0.5 -- 1028
			local by0 = 32 -- 1029
			uiInkDraw:drawSegment( -- 1030
				Vec2(bx0, by0), -- 1030
				Vec2(bx0 + barW, by0), -- 1030
				1.2, -- 1030
				toColor(PALETTE.silkDim, 110) -- 1030
			) -- 1030
			uiInkDraw:drawSegment( -- 1031
				Vec2(bx0, by0), -- 1031
				Vec2(bx0 + barW * ext, by0), -- 1031
				2.4, -- 1031
				toColor(PALETTE.amberCore, 230) -- 1031
			) -- 1031
		else -- 1031
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1034
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1035
				wristX = -120 + peekPulse * 14, -- 1036
				wristY = h * 0.44, -- 1037
				angleRad = -0.04, -- 1038
				scale = 1.04, -- 1039
				pose = "open", -- 1040
				opacity = 0.36 + 0.22 * peekPulse, -- 1041
				stitchHighlight = 0.35 * peekPulse -- 1042
			}) -- 1042
		end -- 1042
		if view.assistHintsEnabled then -- 1047
			drawSilkVeil( -- 1048
				uiDraw, -- 1048
				uiArt, -- 1048
				"g05_assist_veil", -- 1048
				w * 0.5, -- 1048
				h - 26, -- 1048
				280, -- 1048
				28, -- 1048
				PALETTE.inkWash, -- 1048
				0.72, -- 1048
				-1 -- 1048
			) -- 1048
			ctx.texts:put( -- 1049
				"xs", -- 1050
				adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1051
				w * 0.5, -- 1052
				h - 26, -- 1053
				toColor(PALETTE.amberCore), -- 1054
				0.5, -- 1055
				0.5, -- 1056
				"Center", -- 1057
				1.2, -- 1058
				0.9, -- 1059
				0.08 -- 1060
			) -- 1060
		end -- 1060
		return -- 1063
	end -- 1063
	local t = self.g05ReunionElapsed -- 1067
	local claspPull = smoothstep(0, 0.35, t) -- 1068
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1069
	local armDropY = tilt * (h * 0.26) -- 1070
	local claspFade = 1 - smoothstep(0.95, 1.45, t) * 0.45 -- 1073
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1074
		wristX = w * 0.44, -- 1075
		wristY = h * 0.44 - armDropY, -- 1076
		angleRad = -0.05 + tilt * 0.22, -- 1077
		scale = 1.08, -- 1078
		pose = "clasp", -- 1079
		opacity = claspFade, -- 1080
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1081
		cuffPullBack = claspPull * 0.85, -- 1082
		warmth = tilt * 0.32 -- 1083
	}) -- 1083
	drawChildHand( -- 1085
		uiDraw, -- 1086
		w * 0.53, -- 1087
		h * 0.43 - armDropY, -- 1088
		math.pi + 0.05 - tilt * 0.14, -- 1089
		1.08, -- 1090
		"clasp", -- 1091
		claspFade, -- 1092
		true -- 1093
	) -- 1093
	local portraitAlpha = smoothstep(0.32, 0.88, t) -- 1097
	if portraitAlpha > 0.02 then -- 1098
		local py = h * 0.56 + (1 - portraitAlpha) * 26 -- 1099
		drawZhouShuReunionPortrait( -- 1100
			uiDraw, -- 1100
			uiInkDraw, -- 1100
			uiArt, -- 1100
			uiGlow, -- 1100
			w * 0.72, -- 1100
			py, -- 1100
			1, -- 1100
			portraitAlpha -- 1100
		) -- 1100
	end -- 1100
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1104
	if lineAlpha > 0.02 then -- 1105
		drawSilkVeil( -- 1106
			uiDraw, -- 1106
			uiArt, -- 1106
			"g05_line_veil", -- 1106
			w * 0.5, -- 1106
			42, -- 1106
			420, -- 1106
			44, -- 1106
			PALETTE.inkWash, -- 1106
			0.86 * lineAlpha, -- 1106
			-1 -- 1106
		) -- 1106
		drawHairline( -- 1107
			uiInkDraw, -- 1107
			uiArt, -- 1107
			"g05_line_bar", -- 1107
			w * 0.5, -- 1107
			62, -- 1107
			260, -- 1107
			PALETTE.amber, -- 1107
			0.58 * lineAlpha, -- 1107
			true, -- 1107
			2 -- 1107
		) -- 1107
		ctx.texts:put( -- 1108
			"sm", -- 1108
			LINE_G05, -- 1108
			w * 0.5, -- 1108
			42, -- 1108
			toColor(PALETTE.textBright), -- 1108
			0.5, -- 1108
			0.5, -- 1108
			"Center", -- 1108
			2.2, -- 1108
			lineAlpha, -- 1108
			0.08 -- 1108
		) -- 1108
	end -- 1108
end -- 978
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1113
	local holdExt = smoothstep(0.55, 1.45, t) -- 1124
	local tilt = smoothstep(1.55, 2.55, t) -- 1125
	local claspPull = smoothstep(1.4, 1.75, t) -- 1126
	local armDropY = tilt * (h * 0.24) -- 1127
	local boxW = math.min(w - 120, 860) -- 1129
	local boxH = math.min(h - 180, 400) -- 1130
	local bx = (w - boxW) * 0.5 -- 1131
	local by = (h - boxH) * 0.5 + 14 -- 1132
	uiDraw:drawRect( -- 1133
		Rect(0, 0, w, h), -- 1133
		Color(7, 9, 14, 150) -- 1133
	) -- 1133
	local bgTop = lerpRGBA( -- 1134
		rgba(16, 24, 36, 250), -- 1134
		rgba(20, 26, 36, 250), -- 1134
		tilt -- 1134
	) -- 1134
	local bgBot = lerpRGBA( -- 1135
		rgba(10, 15, 24, 250), -- 1135
		rgba(14, 18, 26, 250), -- 1135
		tilt -- 1135
	) -- 1135
	fillVGradRect( -- 1136
		uiDraw, -- 1136
		bx, -- 1136
		by, -- 1136
		boxW, -- 1136
		boxH, -- 1136
		toColor(bgBot), -- 1136
		toColor(bgTop) -- 1136
	) -- 1136
	if tilt > 0.05 then -- 1138
		drawZhouShuReunionPortrait( -- 1139
			uiDraw, -- 1139
			uiInkDraw, -- 1139
			uiArt, -- 1139
			uiGlow, -- 1139
			bx + boxW * 0.72, -- 1139
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1139
			0.92, -- 1139
			tilt -- 1139
		) -- 1139
	end -- 1139
	____exports.drawPatchedCuff( -- 1142
		uiDraw, -- 1142
		uiGlow, -- 1142
		{ -- 1142
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1143
			wristY = by + boxH * 0.52 - armDropY, -- 1144
			angleRad = -0.05 + tilt * 0.2, -- 1145
			scale = 1.06, -- 1146
			pose = t >= 1.4 and "clasp" or "reach", -- 1147
			opacity = clamp01(0.25 + holdExt * 0.75), -- 1148
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1149
			cuffPullBack = claspPull * 0.85, -- 1150
			warmth = tilt * 0.32 -- 1151
		} -- 1151
	) -- 1151
	drawChildHand( -- 1153
		uiDraw, -- 1154
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1155
		by + boxH * 0.48 - armDropY, -- 1156
		math.pi + 0.06, -- 1157
		1.06, -- 1158
		t >= 1.4 and "clasp" or "reach_up", -- 1159
		clamp01(0.35 + holdExt * 0.65), -- 1160
		true -- 1161
	) -- 1161
	uiInkDraw:drawRect( -- 1164
		Rect(bx, by, boxW, boxH), -- 1164
		Color(0, 0, 0, 0), -- 1164
		1, -- 1164
		toColor(PALETTE.silkDim, 145) -- 1164
	) -- 1164
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1166
	if lineAlpha > 0.02 then -- 1167
		drawSilkVeil( -- 1168
			uiDraw, -- 1168
			uiArt, -- 1168
			"g05_reh_veil", -- 1168
			w * 0.5, -- 1168
			42, -- 1168
			420, -- 1168
			44, -- 1168
			PALETTE.inkWash, -- 1168
			0.86 * lineAlpha, -- 1168
			-1 -- 1168
		) -- 1168
		drawHairline( -- 1169
			uiInkDraw, -- 1169
			uiArt, -- 1169
			"g05_reh_bar", -- 1169
			w * 0.5, -- 1169
			62, -- 1169
			260, -- 1169
			PALETTE.amber, -- 1169
			0.58 * lineAlpha, -- 1169
			true, -- 1169
			2 -- 1169
		) -- 1169
		ctx.texts:put( -- 1170
			"sm", -- 1170
			LINE_G05, -- 1170
			w * 0.5, -- 1170
			42, -- 1170
			toColor(PALETTE.textBright), -- 1170
			0.5, -- 1170
			0.5, -- 1170
			"Center", -- 1170
			2.2, -- 1170
			lineAlpha, -- 1170
			0.08 -- 1170
		) -- 1170
	end -- 1170
end -- 1113
function ____exports.createCuffShotsPlugin() -- 1175
	return __TS__New(____exports.CuffShotsPlugin) -- 1176
end -- 1175
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1183
	local gateTransition = createGateTransitionPlugin() -- 1187
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1188
	fe:registerPlugin(gateTransition) -- 1189
	fe:registerPlugin(cuffShots) -- 1190
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1191
end -- 1183
return ____exports -- 1183
