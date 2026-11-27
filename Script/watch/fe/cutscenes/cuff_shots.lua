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
	if op <= 0.01 then -- 134
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
			if hl > 0.05 then -- 230
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
	if opts.pose == "wipe" then -- 240
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
	elseif opts.pose == "pinch" then -- 252
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
	elseif opts.pose == "clasp" then -- 263
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
	if withCompassCord == nil then -- 295
		withCompassCord = true -- 303
	end -- 303
	local op = clamp01(opacity) -- 305
	if op <= 0.01 then -- 305
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
	if pose == "two_fingers" then -- 315
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
	if withCompassCord then -- 332
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
	if pose == "clutch" or pose == "clasp" then -- 347
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
	if a <= 0.01 then -- 376
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
	if not placed then -- 404
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
	if shot == "" then -- 464
		self.rehearsalTime = 0 -- 466
		self.rehearsalAutoAdvance = true -- 467
		return -- 468
	end -- 468
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 470
	if fixedTime ~= nil then -- 470
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
	if self.rehearsalShot ~= "" then -- 503
		self.activeShot = self.rehearsalShot -- 507
		if self.rehearsalAutoAdvance and dt > 0 then -- 507
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 509
		end -- 509
		if not ctx.paused then -- 509
			self:triggerRehearsalAudio(ctx) -- 512
		end -- 512
		self.prevPhase = p.phase -- 514
		return -- 515
	end -- 515
	self.activeShot = "" -- 518
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 518
		self.activeShot = "P03" -- 522
		self.p03Progress = clamp01(p.phaseTick / 60) -- 523
		if not ctx.paused and self.p03Progress >= 0.25 then -- 523
			ctx.audio:playOnce( -- 525
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 526
				"sfx", -- 527
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 528
				0.86, -- 529
				"cuff:p03:cloth_wipe_wood", -- 530
				p.ticks -- 531
			) -- 531
		end -- 531
		if not ctx.paused and self.p03Progress >= 0.62 then -- 531
			ctx.audio:playOnce( -- 535
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 536
				"sfx", -- 537
				"assets/audio/interact/compass_handover.wav", -- 538
				0.82, -- 539
				"cuff:p03:compass_handover", -- 540
				p.ticks -- 541
			) -- 541
		end -- 541
		self.prevPhase = p.phase -- 544
		return -- 545
	else -- 545
		self.p03Progress = 0 -- 547
	end -- 547
	if p.room.key == "gate" then -- 547
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 547
			self.p05ExitTimer = 0 -- 553
			if not ctx.paused then -- 553
				ctx.audio:playOnce( -- 555
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 556
					"sfx", -- 557
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 558
					0.92, -- 559
					"cuff:p05:gate_slam", -- 560
					p.ticks -- 561
				) -- 561
				ctx.audio:playOnce( -- 563
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 564
					"voice", -- 565
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 566
					0.88, -- 567
					"cuff:p05:line_farewell", -- 568
					p.ticks -- 569
				) -- 569
			end -- 569
		end -- 569
		if self.p05ExitTimer >= 0 then -- 569
			if p.phase ~= "gate-count" or view.countElapsedTicks > 240 then -- 569
				self.p05ExitTimer = -1 -- 575
			else -- 575
				if dt > 0 then -- 575
					self.p05ExitTimer = self.p05ExitTimer + dt -- 578
				end -- 578
				if self.p05ExitTimer >= 3.6 then -- 578
					self.p05ExitTimer = -1 -- 581
				else -- 581
					self.activeShot = "P05" -- 583
				end -- 583
			end -- 583
		end -- 583
	else -- 583
		self.p05ExitTimer = -1 -- 588
	end -- 588
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 592
	if inGateReunion then -- 592
		self.activeShot = "G05" -- 600
		local gr = view.gateReunion -- 601
		local completed = p.phase == "gate-hand" or gr.completed -- 602
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 602
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 605
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 606
			if not ctx.paused and view.isRehearsal then -- 606
				ctx.audio:playOnce( -- 608
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 609
					"sfx", -- 610
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 611
					0.72, -- 612
					"cuff:g05:reunion_release", -- 613
					p.ticks -- 614
				) -- 614
			end -- 614
		end -- 614
		if completed then -- 614
			self.g05SleeveExtend = 1 -- 620
			if dt > 0 then -- 620
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 622
			end -- 622
			if not ctx.paused and not self.g05LineTriggered then -- 622
				if view.isRehearsal then -- 622
					ctx.audio:playOnce( -- 626
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 627
						"sfx", -- 628
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 629
						0.88, -- 630
						"cuff:g05:hand_held", -- 631
						p.ticks -- 632
					) -- 632
				end -- 632
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 632
					self.g05LineTriggered = true -- 636
					ctx.audio:playOnce( -- 637
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 638
						"voice", -- 639
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 640
						0.94, -- 641
						"cuff:g05:line_reunion", -- 642
						p.ticks -- 643
					) -- 643
				end -- 643
			end -- 643
		else -- 643
			self.g05ReunionElapsed = 0 -- 648
			self.g05LineTriggered = false -- 649
			if gr.holding or gr.holdProgress > 0.001 then -- 649
				if gr.holdProgress >= self.g05SleeveExtend then -- 649
					self.g05SleeveExtend = gr.holdProgress -- 653
				elseif dt > 0 then -- 653
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 655
				end -- 655
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 655
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 659
			end -- 659
		end -- 659
	else -- 659
		self.g05SleeveExtend = 0 -- 663
		self.g05ReunionElapsed = 0 -- 664
		self.g05LineTriggered = false -- 665
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 666
	end -- 666
	self.prevPhase = p.phase -- 669
end -- 499
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 672
	local sid = ctx.events.roomSessionId -- 673
	local t = self.rehearsalTime -- 674
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 674
		ctx.audio:playOnce( -- 676
			"reh:p03:wipe:" .. tostring(sid), -- 676
			"sfx", -- 676
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 676
			0.88, -- 676
			"cuff:p03:cloth_wipe_wood", -- 676
			ctx.p.ticks -- 676
		) -- 676
	elseif self.rehearsalShot == "P05" then -- 676
		if t >= 0.9 then -- 676
			ctx.audio:playOnce( -- 679
				"reh:p05:line:" .. tostring(sid), -- 679
				"voice", -- 679
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 679
				0.9, -- 679
				"cuff:p05:line_farewell", -- 679
				ctx.p.ticks -- 679
			) -- 679
		end -- 679
		if t >= 2.75 then -- 679
			ctx.audio:playOnce( -- 682
				"reh:p05:slam:" .. tostring(sid), -- 682
				"sfx", -- 682
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 682
				0.94, -- 682
				"cuff:p05:gate_slam", -- 682
				ctx.p.ticks -- 682
			) -- 682
			ctx.audio:playLoop( -- 683
				"reh_p05_water", -- 683
				"water", -- 683
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 683
				0.42, -- 683
				ctx.p.ticks -- 683
			) -- 683
		end -- 683
	elseif self.rehearsalShot == "G05" then -- 683
		if t >= 0.05 then -- 683
			ctx.audio:playOnce( -- 687
				"reh:g05:knock1:" .. tostring(sid), -- 687
				"sfx", -- 687
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 687
				0.88, -- 687
				"knock:gate:1", -- 687
				ctx.p.ticks -- 687
			) -- 687
		end -- 687
		if t >= 0.25 then -- 687
			ctx.audio:playOnce( -- 690
				"reh:g05:knock2:" .. tostring(sid), -- 690
				"sfx", -- 690
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 690
				0.92, -- 690
				"knock:gate:2", -- 690
				ctx.p.ticks -- 690
			) -- 690
		end -- 690
		if t >= 1.55 then -- 690
			ctx.audio:playOnce( -- 693
				"reh:g05:clasp:" .. tostring(sid), -- 693
				"sfx", -- 693
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 693
				0.88, -- 693
				"cuff:g05:hand_held", -- 693
				ctx.p.ticks -- 693
			) -- 693
		end -- 693
		if t >= 2.35 then -- 693
			ctx.audio:playOnce( -- 696
				"reh:g05:line:" .. tostring(sid), -- 696
				"voice", -- 696
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 696
				0.94, -- 696
				"cuff:g05:line_reunion", -- 696
				ctx.p.ticks -- 696
			) -- 696
		end -- 696
	end -- 696
end -- 672
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 701
	if self.activeShot == "" then -- 701
		return false -- 709
	end -- 709
	local w = ctx.uiW -- 711
	local h = ctx.uiH -- 712
	if self.activeShot == "P03" then -- 712
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 715
		self:renderP03Shot( -- 718
			uiDraw, -- 718
			uiInkDraw, -- 718
			uiArt, -- 718
			uiGlow, -- 718
			ctx, -- 718
			w, -- 718
			h, -- 718
			prog -- 718
		) -- 718
		return true -- 719
	end -- 719
	if self.activeShot == "P05" then -- 719
		if self.rehearsalShot == "P05" then -- 719
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 724
			self:renderP05FullShot( -- 725
				uiDraw, -- 725
				uiInkDraw, -- 725
				uiArt, -- 725
				uiGlow, -- 725
				ctx, -- 725
				w, -- 725
				h, -- 725
				prog -- 725
			) -- 725
			return true -- 726
		end -- 726
		self:renderP05ExitBridge( -- 729
			uiDraw, -- 729
			uiInkDraw, -- 729
			uiArt, -- 729
			uiGlow, -- 729
			ctx, -- 729
			w, -- 729
			h, -- 729
			clamp01(self.p05ExitTimer / 3.6) -- 729
		) -- 729
		return false -- 730
	end -- 730
	if self.activeShot == "G05" then -- 730
		if self.rehearsalShot == "G05" then -- 730
			self:renderG05RehearsalShot( -- 735
				uiDraw, -- 735
				uiInkDraw, -- 735
				uiArt, -- 735
				uiGlow, -- 735
				ctx, -- 735
				w, -- 735
				h, -- 735
				self.rehearsalTime -- 735
			) -- 735
			return true -- 736
		end -- 736
		self:renderG05LiveShot( -- 738
			uiDraw, -- 738
			uiInkDraw, -- 738
			uiArt, -- 738
			uiGlow, -- 738
			ctx, -- 738
			w, -- 738
			h -- 738
		) -- 738
		return true -- 739
	end -- 739
	return false -- 742
end -- 701
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 751
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 761
	local boxW = math.min(w - 140, 820) -- 763
	local boxH = math.min(h - 190, 390) -- 764
	local bx = (w - boxW) * 0.5 -- 765
	local by = (h - boxH) * 0.5 + 14 -- 766
	uiDraw:drawRect( -- 768
		Rect(0, 0, w, h), -- 768
		Color( -- 768
			7, -- 768
			9, -- 768
			14, -- 768
			math.floor(135 * fade + 0.5) -- 768
		) -- 768
	) -- 768
	fillVGradRect( -- 770
		uiDraw, -- 770
		bx, -- 770
		by, -- 770
		boxW, -- 770
		boxH, -- 770
		Color( -- 770
			14, -- 770
			13, -- 770
			16, -- 770
			math.floor(248 * fade + 0.5) -- 770
		), -- 770
		Color( -- 770
			24, -- 770
			24, -- 770
			30, -- 770
			math.floor(248 * fade + 0.5) -- 770
		) -- 770
	) -- 770
	local rimY = by + boxH * 0.34 -- 772
	uiDraw:drawRect( -- 773
		Rect(bx, by, boxW, rimY - by), -- 773
		Color( -- 773
			54, -- 773
			40, -- 773
			30, -- 773
			math.floor(252 * fade + 0.5) -- 773
		) -- 773
	) -- 773
	uiDraw:drawSegment( -- 774
		Vec2(bx, rimY), -- 774
		Vec2(bx + boxW, rimY), -- 774
		2.2, -- 774
		Color( -- 774
			128, -- 774
			100, -- 774
			76, -- 774
			math.floor(220 * fade + 0.5) -- 774
		) -- 774
	) -- 774
	local crackX = bx + boxW * 0.72 -- 776
	uiDraw:drawRect( -- 777
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 777
		Color( -- 777
			8, -- 777
			9, -- 777
			13, -- 777
			math.floor(245 * fade + 0.5) -- 777
		) -- 777
	) -- 777
	uiDraw:drawRect( -- 778
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 778
		Color( -- 778
			46, -- 778
			35, -- 778
			26, -- 778
			math.floor(250 * fade + 0.5) -- 778
		) -- 778
	) -- 778
	local wipeT = smoothstep(0.3, 0.66, prog) -- 781
	local shardOffsets = {{ -- 782
		x = -72, -- 783
		y = 8, -- 783
		dx = 46, -- 783
		dy = -38, -- 783
		r = 9 -- 783
	}, { -- 783
		x = -34, -- 784
		y = 12, -- 784
		dx = 64, -- 784
		dy = -46, -- 784
		r = 7 -- 784
	}, { -- 784
		x = 4, -- 785
		y = 6, -- 785
		dx = 82, -- 785
		dy = -52, -- 785
		r = 10 -- 785
	}, { -- 785
		x = 32, -- 786
		y = 10, -- 786
		dx = 74, -- 786
		dy = -34, -- 786
		r = 6 -- 786
	}} -- 786
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 788
	if shardAlpha > 0.02 then -- 788
		local si = 0 -- 790
		do -- 790
			si = 0 -- 791
			while si < #shardOffsets do -- 791
				local sh = shardOffsets[si + 1] -- 792
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 793
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 794
				uiDraw:drawPolygon( -- 795
					{ -- 795
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 796
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 797
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 798
					}, -- 798
					Color( -- 799
						212, -- 799
						218, -- 799
						224, -- 799
						math.floor(235 * shardAlpha + 0.5) -- 799
					), -- 799
					0.9, -- 799
					Color( -- 799
						92, -- 799
						108, -- 799
						126, -- 799
						math.floor(200 * shardAlpha + 0.5) -- 799
					) -- 799
				) -- 799
				si = si + 1 -- 791
			end -- 791
		end -- 791
	end -- 791
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 804
	local handOut = smoothstep(0.7, 0.9, prog) -- 805
	if handOut > 0.05 then -- 805
		drawChildHand( -- 807
			uiDraw, -- 808
			crackX + 18 - handOut * 66, -- 809
			rimY + 52, -- 810
			math.pi, -- 811
			1.05, -- 812
			"open_fingers", -- 813
			fade * handOut, -- 814
			false -- 815
		) -- 815
	elseif fingerEnter > 0.02 then -- 815
		drawChildHand( -- 818
			uiDraw, -- 819
			crackX + 12 - fingerEnter * 24, -- 820
			rimY + 46, -- 821
			math.pi, -- 822
			1.08, -- 823
			"two_fingers", -- 824
			fade * fingerEnter, -- 825
			false -- 826
		) -- 826
	end -- 826
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 831
	if sleeveEnter > 0.01 then -- 831
		local reachT = smoothstep(0.66, 0.88, prog) -- 833
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 834
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 835
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 836
		local pose = reachT > 0.2 and "reach" or "wipe" -- 837
		____exports.drawPatchedCuff( -- 838
			uiDraw, -- 838
			uiGlow, -- 838
			{ -- 838
				wristX = wx, -- 839
				wristY = wy, -- 840
				angleRad = ang, -- 841
				scale = 1.06, -- 842
				pose = pose, -- 843
				opacity = fade * sleeveEnter, -- 844
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 845
				warmth = 0.18 -- 846
			} -- 846
		) -- 846
	end -- 846
	uiInkDraw:drawRect( -- 851
		Rect(bx, by, boxW, boxH), -- 851
		Color(0, 0, 0, 0), -- 851
		1, -- 851
		toColor( -- 851
			PALETTE.silkDim, -- 851
			math.floor(145 * fade + 0.5) -- 851
		) -- 851
	) -- 851
	drawSilkVeil( -- 852
		uiDraw, -- 852
		uiArt, -- 852
		"p03_sub_veil", -- 852
		w * 0.5, -- 852
		42, -- 852
		520, -- 852
		42, -- 852
		PALETTE.inkWash, -- 852
		0.82 * fade, -- 852
		-1 -- 852
	) -- 852
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 853
	ctx.texts:put( -- 856
		"sm", -- 856
		subText, -- 856
		w * 0.5, -- 856
		42, -- 856
		toColor(PALETTE.textBright), -- 856
		0.5, -- 856
		0.5, -- 856
		"Center", -- 856
		1, -- 856
		fade, -- 856
		0.08 -- 856
	) -- 856
end -- 751
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 865
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 875
	local boxW = math.min(w - 120, 860) -- 876
	local boxH = math.min(h - 180, 400) -- 877
	local bx = (w - boxW) * 0.5 -- 878
	local by = (h - boxH) * 0.5 + 14 -- 879
	uiDraw:drawRect( -- 881
		Rect(0, 0, w, h), -- 881
		Color( -- 881
			7, -- 881
			9, -- 881
			14, -- 881
			math.floor(145 * fade + 0.5) -- 881
		) -- 881
	) -- 881
	fillVGradRect( -- 883
		uiDraw, -- 883
		bx, -- 883
		by, -- 883
		boxW, -- 883
		boxH, -- 883
		Color( -- 883
			14, -- 883
			22, -- 883
			34, -- 883
			math.floor(248 * fade + 0.5) -- 883
		), -- 883
		Color( -- 883
			28, -- 883
			42, -- 883
			58, -- 883
			math.floor(248 * fade + 0.5) -- 883
		) -- 883
	) -- 883
	fillRadialGlow( -- 885
		uiGlow, -- 885
		bx + boxW * 0.66, -- 885
		by + boxH * 0.32, -- 885
		220, -- 885
		68, -- 885
		Color( -- 885
			152, -- 885
			194, -- 885
			224, -- 885
			math.floor(74 * fade + 0.5) -- 885
		), -- 885
		Color(40, 70, 108, 0), -- 885
		16 -- 885
	) -- 885
	local releaseT = smoothstep(0.68, 0.94, prog) -- 887
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 888
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 891
	local cuffY = by + boxH * 0.52 -- 892
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 893
		wristX = cuffX, -- 894
		wristY = cuffY, -- 895
		angleRad = -0.06, -- 896
		scale = 1.12, -- 897
		pose = pinchT > 0.25 and "pinch" or "open", -- 898
		opacity = fade * (1 - releaseT * 0.88), -- 899
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 900
		warmth = 0.12 -- 901
	}) -- 901
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 905
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 906
	drawChildHand( -- 907
		uiDraw, -- 908
		childHandX, -- 909
		childHandY, -- 910
		math.pi + 0.12, -- 911
		1.12, -- 912
		releaseT > 0.35 and "open_fingers" or "clutch", -- 913
		fade, -- 914
		true -- 915
	) -- 915
	if releaseT > 0.01 then -- 915
		local dropH = boxH * releaseT * 0.88 -- 920
		uiDraw:drawRect( -- 921
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 921
			Color( -- 921
				26, -- 921
				22, -- 921
				20, -- 921
				math.floor(238 * fade + 0.5) -- 921
			) -- 921
		) -- 921
		uiDraw:drawSegment( -- 922
			Vec2(bx, by + boxH - dropH), -- 922
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 922
			2.4, -- 922
			Color( -- 922
				118, -- 922
				104, -- 922
				88, -- 922
				math.floor(220 * fade + 0.5) -- 922
			) -- 922
		) -- 922
	end -- 922
	uiInkDraw:drawRect( -- 925
		Rect(bx, by, boxW, boxH), -- 925
		Color(0, 0, 0, 0), -- 925
		1, -- 925
		toColor( -- 925
			PALETTE.silkDim, -- 925
			math.floor(150 * fade + 0.5) -- 925
		) -- 925
	) -- 925
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 928
	if lineAlpha > 0.02 then -- 928
		drawSilkVeil( -- 930
			uiDraw, -- 930
			uiArt, -- 930
			"p05_sub_veil", -- 930
			w * 0.5, -- 930
			42, -- 930
			740, -- 930
			44, -- 930
			PALETTE.inkWash, -- 930
			0.86 * lineAlpha, -- 930
			-1 -- 930
		) -- 930
		drawHairline( -- 931
			uiInkDraw, -- 931
			uiArt, -- 931
			"p05_sub_line", -- 931
			w * 0.5, -- 931
			62, -- 931
			520, -- 931
			PALETTE.silkDim, -- 931
			0.52 * lineAlpha, -- 931
			true, -- 931
			2 -- 931
		) -- 931
		ctx.texts:put( -- 932
			"sm", -- 932
			LINE_P05, -- 932
			w * 0.5, -- 932
			42, -- 932
			toColor(PALETTE.textBright), -- 932
			0.5, -- 932
			0.5, -- 932
			"Center", -- 932
			0.8, -- 932
			lineAlpha, -- 932
			0.08 -- 932
		) -- 932
	end -- 932
end -- 865
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 937
	local enter = smoothstep(0, 0.12, t) -- 947
	local out = smoothstep(0.66, 1, t) -- 948
	local alpha = enter * (1 - out) -- 949
	if alpha <= 0.02 then -- 949
		return -- 951
	end -- 951
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 953
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 954
		wristX = w * 0.25 - out * 240, -- 955
		wristY = h * 0.4, -- 956
		angleRad = -0.05, -- 957
		scale = 0.94, -- 958
		pose = pinchT > 0.25 and "pinch" or "open", -- 959
		opacity = alpha * 0.94, -- 960
		stitchHighlight = 0.45 + 0.28 * pinchT -- 961
	}) -- 961
	drawChildHand( -- 963
		uiDraw, -- 964
		w * 0.35 + out * 26, -- 965
		h * 0.37 - out * 10, -- 966
		math.pi + 0.1, -- 967
		0.94, -- 968
		out > 0.32 and "open_fingers" or "clutch", -- 969
		alpha * 0.92, -- 970
		true -- 971
	) -- 971
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 973
	if lineAlpha > 0.02 then -- 973
		local subY = 92 -- 975
		drawSilkVeil( -- 976
			uiDraw, -- 976
			uiArt, -- 976
			"p05_live_veil", -- 976
			w * 0.5, -- 976
			subY, -- 976
			760, -- 976
			44, -- 976
			PALETTE.inkWash, -- 976
			0.86 * lineAlpha, -- 976
			-1 -- 976
		) -- 976
		drawHairline( -- 977
			uiInkDraw, -- 977
			uiArt, -- 977
			"p05_live_line", -- 977
			w * 0.5, -- 977
			subY + 20, -- 977
			520, -- 977
			PALETTE.silkDim, -- 977
			0.52 * lineAlpha, -- 977
			true, -- 977
			2 -- 977
		) -- 977
		ctx.texts:put( -- 978
			"sm", -- 978
			LINE_P05, -- 978
			w * 0.5, -- 978
			subY, -- 978
			toColor(PALETTE.textBright), -- 978
			0.5, -- 978
			0.5, -- 978
			"Center", -- 978
			0.8, -- 978
			lineAlpha, -- 978
			0.08 -- 978
		) -- 978
	end -- 978
end -- 937
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 988
	local view = ctx.view -- 997
	local gr = view.gateReunion -- 998
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 999
	local ext = clamp01(self.g05SleeveExtend) -- 1000
	if not completed then -- 1000
		if ext > 0.008 then -- 1000
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 1006
			fillVGradRect( -- 1007
				uiDraw, -- 1007
				0, -- 1007
				h * 0.28, -- 1007
				w, -- 1007
				h * 0.16, -- 1007
				Color(8, 11, 18, 0), -- 1007
				Color(8, 11, 18, veilA) -- 1007
			) -- 1007
			fillVGradRect( -- 1008
				uiDraw, -- 1008
				0, -- 1008
				h * 0.44, -- 1008
				w, -- 1008
				h * 0.16, -- 1008
				Color(8, 11, 18, veilA), -- 1008
				Color(8, 11, 18, 0) -- 1008
			) -- 1008
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 1010
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1011
			____exports.drawPatchedCuff( -- 1012
				uiDraw, -- 1012
				uiGlow, -- 1012
				{ -- 1012
					wristX = cuffX, -- 1013
					wristY = cuffY, -- 1014
					angleRad = -0.05, -- 1015
					scale = 1.08, -- 1016
					pose = ext > 0.82 and "clasp" or "reach", -- 1017
					opacity = clamp01(0.32 + ext * 0.68), -- 1018
					stitchHighlight = 0.35 + 0.6 * ext -- 1019
				} -- 1019
			) -- 1019
			local childX = w * 0.64 - ext * (w * 0.13) -- 1023
			local childY = h * 0.41 + ext * 14 -- 1024
			drawChildHand( -- 1025
				uiDraw, -- 1026
				childX, -- 1027
				childY, -- 1028
				math.pi + 0.08, -- 1029
				1.06, -- 1030
				ext > 0.88 and "clasp" or "reach_up", -- 1031
				clamp01(0.25 + ext * 0.75), -- 1032
				true -- 1033
			) -- 1033
			local barW = 240 -- 1037
			local bx0 = w * 0.5 - barW * 0.5 -- 1038
			local by0 = 32 -- 1039
			uiInkDraw:drawSegment( -- 1040
				Vec2(bx0, by0), -- 1040
				Vec2(bx0 + barW, by0), -- 1040
				1.2, -- 1040
				toColor(PALETTE.silkDim, 110) -- 1040
			) -- 1040
			uiInkDraw:drawSegment( -- 1041
				Vec2(bx0, by0), -- 1041
				Vec2(bx0 + barW * ext, by0), -- 1041
				2.4, -- 1041
				toColor(PALETTE.amberCore, 230) -- 1041
			) -- 1041
		else -- 1041
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1044
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1045
				wristX = -120 + peekPulse * 14, -- 1046
				wristY = h * 0.44, -- 1047
				angleRad = -0.04, -- 1048
				scale = 1.04, -- 1049
				pose = "open", -- 1050
				opacity = 0.36 + 0.22 * peekPulse, -- 1051
				stitchHighlight = 0.35 * peekPulse -- 1052
			}) -- 1052
		end -- 1052
		if view.assistHintsEnabled then -- 1052
			drawSilkVeil( -- 1058
				uiDraw, -- 1058
				uiArt, -- 1058
				"g05_assist_veil", -- 1058
				w * 0.5, -- 1058
				h - 26, -- 1058
				280, -- 1058
				28, -- 1058
				PALETTE.inkWash, -- 1058
				0.72, -- 1058
				-1 -- 1058
			) -- 1058
			ctx.texts:put( -- 1059
				"xs", -- 1060
				adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1061
				w * 0.5, -- 1062
				h - 26, -- 1063
				toColor(PALETTE.amberCore), -- 1064
				0.5, -- 1065
				0.5, -- 1066
				"Center", -- 1067
				1.2, -- 1068
				0.9, -- 1069
				0.08 -- 1070
			) -- 1070
		end -- 1070
		return -- 1073
	end -- 1073
	local t = self.g05ReunionElapsed -- 1077
	local claspPull = smoothstep(0, 0.35, t) -- 1078
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1079
	local armDropY = tilt * (h * 0.26) -- 1080
	local claspFade = 1 - smoothstep(0.95, 1.45, t) * 0.45 -- 1083
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1084
		wristX = w * 0.44, -- 1085
		wristY = h * 0.44 - armDropY, -- 1086
		angleRad = -0.05 + tilt * 0.22, -- 1087
		scale = 1.08, -- 1088
		pose = "clasp", -- 1089
		opacity = claspFade, -- 1090
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1091
		cuffPullBack = claspPull * 0.85, -- 1092
		warmth = tilt * 0.32 -- 1093
	}) -- 1093
	drawChildHand( -- 1095
		uiDraw, -- 1096
		w * 0.53, -- 1097
		h * 0.43 - armDropY, -- 1098
		math.pi + 0.05 - tilt * 0.14, -- 1099
		1.08, -- 1100
		"clasp", -- 1101
		claspFade, -- 1102
		true -- 1103
	) -- 1103
	local portraitAlpha = smoothstep(0.32, 0.88, t) -- 1107
	if portraitAlpha > 0.02 then -- 1107
		local py = h * 0.56 + (1 - portraitAlpha) * 26 -- 1109
		drawZhouShuReunionPortrait( -- 1110
			uiDraw, -- 1110
			uiInkDraw, -- 1110
			uiArt, -- 1110
			uiGlow, -- 1110
			w * 0.72, -- 1110
			py, -- 1110
			1, -- 1110
			portraitAlpha -- 1110
		) -- 1110
	end -- 1110
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1114
	if lineAlpha > 0.02 then -- 1114
		drawSilkVeil( -- 1116
			uiDraw, -- 1116
			uiArt, -- 1116
			"g05_line_veil", -- 1116
			w * 0.5, -- 1116
			42, -- 1116
			420, -- 1116
			44, -- 1116
			PALETTE.inkWash, -- 1116
			0.86 * lineAlpha, -- 1116
			-1 -- 1116
		) -- 1116
		drawHairline( -- 1117
			uiInkDraw, -- 1117
			uiArt, -- 1117
			"g05_line_bar", -- 1117
			w * 0.5, -- 1117
			62, -- 1117
			260, -- 1117
			PALETTE.amber, -- 1117
			0.58 * lineAlpha, -- 1117
			true, -- 1117
			2 -- 1117
		) -- 1117
		ctx.texts:put( -- 1118
			"sm", -- 1118
			LINE_G05, -- 1118
			w * 0.5, -- 1118
			42, -- 1118
			toColor(PALETTE.textBright), -- 1118
			0.5, -- 1118
			0.5, -- 1118
			"Center", -- 1118
			2.2, -- 1118
			lineAlpha, -- 1118
			0.08 -- 1118
		) -- 1118
	end -- 1118
end -- 988
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1123
	local holdExt = smoothstep(0.55, 1.45, t) -- 1134
	local tilt = smoothstep(1.55, 2.55, t) -- 1135
	local claspPull = smoothstep(1.4, 1.75, t) -- 1136
	local armDropY = tilt * (h * 0.24) -- 1137
	local boxW = math.min(w - 120, 860) -- 1139
	local boxH = math.min(h - 180, 400) -- 1140
	local bx = (w - boxW) * 0.5 -- 1141
	local by = (h - boxH) * 0.5 + 14 -- 1142
	uiDraw:drawRect( -- 1143
		Rect(0, 0, w, h), -- 1143
		Color(7, 9, 14, 150) -- 1143
	) -- 1143
	local bgTop = lerpRGBA( -- 1144
		rgba(16, 24, 36, 250), -- 1144
		rgba(20, 26, 36, 250), -- 1144
		tilt -- 1144
	) -- 1144
	local bgBot = lerpRGBA( -- 1145
		rgba(10, 15, 24, 250), -- 1145
		rgba(14, 18, 26, 250), -- 1145
		tilt -- 1145
	) -- 1145
	fillVGradRect( -- 1146
		uiDraw, -- 1146
		bx, -- 1146
		by, -- 1146
		boxW, -- 1146
		boxH, -- 1146
		toColor(bgBot), -- 1146
		toColor(bgTop) -- 1146
	) -- 1146
	if tilt > 0.05 then -- 1146
		drawZhouShuReunionPortrait( -- 1149
			uiDraw, -- 1149
			uiInkDraw, -- 1149
			uiArt, -- 1149
			uiGlow, -- 1149
			bx + boxW * 0.72, -- 1149
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1149
			0.92, -- 1149
			tilt -- 1149
		) -- 1149
	end -- 1149
	____exports.drawPatchedCuff( -- 1152
		uiDraw, -- 1152
		uiGlow, -- 1152
		{ -- 1152
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1153
			wristY = by + boxH * 0.52 - armDropY, -- 1154
			angleRad = -0.05 + tilt * 0.2, -- 1155
			scale = 1.06, -- 1156
			pose = t >= 1.4 and "clasp" or "reach", -- 1157
			opacity = clamp01(0.25 + holdExt * 0.75), -- 1158
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1159
			cuffPullBack = claspPull * 0.85, -- 1160
			warmth = tilt * 0.32 -- 1161
		} -- 1161
	) -- 1161
	drawChildHand( -- 1163
		uiDraw, -- 1164
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1165
		by + boxH * 0.48 - armDropY, -- 1166
		math.pi + 0.06, -- 1167
		1.06, -- 1168
		t >= 1.4 and "clasp" or "reach_up", -- 1169
		clamp01(0.35 + holdExt * 0.65), -- 1170
		true -- 1171
	) -- 1171
	uiInkDraw:drawRect( -- 1174
		Rect(bx, by, boxW, boxH), -- 1174
		Color(0, 0, 0, 0), -- 1174
		1, -- 1174
		toColor(PALETTE.silkDim, 145) -- 1174
	) -- 1174
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1176
	if lineAlpha > 0.02 then -- 1176
		drawSilkVeil( -- 1178
			uiDraw, -- 1178
			uiArt, -- 1178
			"g05_reh_veil", -- 1178
			w * 0.5, -- 1178
			42, -- 1178
			420, -- 1178
			44, -- 1178
			PALETTE.inkWash, -- 1178
			0.86 * lineAlpha, -- 1178
			-1 -- 1178
		) -- 1178
		drawHairline( -- 1179
			uiInkDraw, -- 1179
			uiArt, -- 1179
			"g05_reh_bar", -- 1179
			w * 0.5, -- 1179
			62, -- 1179
			260, -- 1179
			PALETTE.amber, -- 1179
			0.58 * lineAlpha, -- 1179
			true, -- 1179
			2 -- 1179
		) -- 1179
		ctx.texts:put( -- 1180
			"sm", -- 1180
			LINE_G05, -- 1180
			w * 0.5, -- 1180
			42, -- 1180
			toColor(PALETTE.textBright), -- 1180
			0.5, -- 1180
			0.5, -- 1180
			"Center", -- 1180
			2.2, -- 1180
			lineAlpha, -- 1180
			0.08 -- 1180
		) -- 1180
	end -- 1180
end -- 1123
function ____exports.createCuffShotsPlugin() -- 1185
	return __TS__New(____exports.CuffShotsPlugin) -- 1186
end -- 1185
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1193
	local gateTransition = createGateTransitionPlugin() -- 1197
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1198
	fe:registerPlugin(gateTransition) -- 1199
	fe:registerPlugin(cuffShots) -- 1200
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1201
end -- 1193
return ____exports -- 1193