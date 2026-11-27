-- [ts]: cuff_shots.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local Color = ____Dora.Color -- 21
local Rect = ____Dora.Rect -- 21
local Vec2 = ____Dora.Vec2 -- 21
local ____play = require("Script.watch.play") -- 22
local GATE_FAREWELL_TICKS = ____play.GATE_FAREWELL_TICKS -- 22
local PROLOGUE_GIVE_TICKS = ____play.PROLOGUE_GIVE_TICKS -- 22
local ____target = require("Script.watch.target") -- 26
local getActiveTarget = ____target.getActiveTarget -- 26
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
	self.p05Progress = 0 -- 438
	self.p05ExitTimer = -1 -- 439
	self.g05SleeveExtend = 0 -- 440
	self.g05ReunionElapsed = 0 -- 441
	self.g05LineTriggered = false -- 442
	self.g05AbortVisualCount = 0 -- 443
	self.lastReleasedAbortCount = 0 -- 444
end -- 423
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 446
	self.animTime = 0 -- 447
	self.prevPhase = p.phase -- 448
	self.activeShot = "" -- 449
	self.p03Progress = 0 -- 450
	self.p05Progress = 0 -- 451
	self.p05ExitTimer = -1 -- 452
	self.g05SleeveExtend = 0 -- 453
	self.g05ReunionElapsed = 0 -- 454
	self.g05LineTriggered = false -- 455
	self.g05AbortVisualCount = 0 -- 456
	self.lastReleasedAbortCount = 0 -- 457
end -- 446
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 465
	self.rehearsalShot = shot -- 466
	if shot == "" then -- 466
		self.rehearsalTime = 0 -- 468
		self.rehearsalAutoAdvance = true -- 469
		return -- 470
	end -- 470
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 472
	if fixedTime ~= nil then -- 472
		self.rehearsalTime = math.max( -- 474
			0, -- 474
			math.min(self.rehearsalDuration, fixedTime) -- 474
		) -- 474
		self.rehearsalAutoAdvance = false -- 475
	else -- 475
		self.rehearsalTime = 0 -- 477
		self.rehearsalAutoAdvance = true -- 478
	end -- 478
end -- 465
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 482
	self:rehearseShot("") -- 483
end -- 482
function CuffShotsPlugin.prototype.getDebugState(self) -- 486
	return { -- 487
		activeShot = self.activeShot, -- 488
		rehearsalShot = self.rehearsalShot, -- 489
		rehearsalTime = self.rehearsalTime, -- 490
		rehearsalDuration = self.rehearsalDuration, -- 491
		p03Progress = self.p03Progress, -- 492
		p05ExitTimer = self.p05ExitTimer, -- 493
		g05SleeveExtend = self.g05SleeveExtend, -- 494
		g05ReunionElapsed = self.g05ReunionElapsed, -- 495
		g05LineTriggered = self.g05LineTriggered, -- 496
		g05AbortVisualCount = self.g05AbortVisualCount -- 497
	} -- 497
end -- 486
function CuffShotsPlugin.prototype.update(self, ctx) -- 501
	local p = ctx.p -- 502
	local view = ctx.view -- 503
	local dt = ctx.paused and 0 or ctx.worldDt -- 504
	self.animTime = self.animTime + dt -- 505
	if self.rehearsalShot ~= "" then -- 505
		self.activeShot = self.rehearsalShot -- 509
		if self.rehearsalAutoAdvance and dt > 0 then -- 509
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 511
		end -- 511
		if not ctx.paused then -- 511
			self:triggerRehearsalAudio(ctx) -- 514
		end -- 514
		self.prevPhase = p.phase -- 516
		return -- 517
	end -- 517
	self.activeShot = "" -- 520
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 520
		self.activeShot = "P03" -- 524
		self.p03Progress = clamp01(p.phaseTick / PROLOGUE_GIVE_TICKS) -- 525
		if not ctx.paused and self.p03Progress >= 0.18 then -- 525
			ctx.audio:playOnce( -- 527
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 528
				"sfx", -- 529
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 530
				0.86, -- 531
				"cuff:p03:cloth_wipe_wood", -- 532
				p.ticks -- 533
			) -- 533
		end -- 533
		if not ctx.paused and self.p03Progress >= 0.62 then -- 533
			ctx.audio:playOnce( -- 537
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 538
				"sfx", -- 539
				"assets/audio/interact/compass_handover.wav", -- 540
				0.82, -- 541
				"cuff:p03:compass_handover", -- 542
				p.ticks -- 543
			) -- 543
		end -- 543
		self.prevPhase = p.phase -- 546
		return -- 547
	else -- 547
		self.p03Progress = 0 -- 549
	end -- 549
	if p.room.key == "gate" and p.phase == "gate-farewell" then -- 549
		self.activeShot = "P05" -- 554
		self.p05Progress = clamp01(p.phaseTick / GATE_FAREWELL_TICKS) -- 555
		self.p05ExitTimer = p.phaseTick / 60 -- 556
		if not ctx.paused then -- 556
			if self.p05Progress >= 0.14 then -- 556
				ctx.audio:playOnce( -- 559
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 560
					"voice", -- 561
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 562
					0.88, -- 563
					"cuff:p05:line_farewell", -- 564
					p.ticks -- 565
				) -- 565
			end -- 565
			if self.p05Progress >= 0.7 then -- 565
				ctx.audio:playOnce( -- 569
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 570
					"sfx", -- 571
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 572
					0.92, -- 573
					"cuff:p05:gate_slam", -- 574
					p.ticks -- 575
				) -- 575
			end -- 575
		end -- 575
		self.prevPhase = p.phase -- 579
		return -- 580
	else -- 580
		self.p05Progress = 0 -- 582
		self.p05ExitTimer = -1 -- 583
	end -- 583
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 587
	if inGateReunion then -- 587
		self.activeShot = "G05" -- 595
		local gr = view.gateReunion -- 596
		local completed = p.phase == "gate-hand" or gr.completed -- 597
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 597
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 600
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 601
			if not ctx.paused and view.isRehearsal then -- 601
				ctx.audio:playOnce( -- 603
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 604
					"sfx", -- 605
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 606
					0.72, -- 607
					"cuff:g05:reunion_release", -- 608
					p.ticks -- 609
				) -- 609
			end -- 609
		end -- 609
		if completed then -- 609
			self.g05SleeveExtend = 1 -- 615
			if dt > 0 then -- 615
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 617
			end -- 617
			if not ctx.paused and not self.g05LineTriggered then -- 617
				if view.isRehearsal then -- 617
					ctx.audio:playOnce( -- 621
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 622
						"sfx", -- 623
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 624
						0.88, -- 625
						"cuff:g05:hand_held", -- 626
						p.ticks -- 627
					) -- 627
				end -- 627
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 627
					self.g05LineTriggered = true -- 631
					ctx.audio:playOnce( -- 632
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 633
						"voice", -- 634
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 635
						0.94, -- 636
						"cuff:g05:line_reunion", -- 637
						p.ticks -- 638
					) -- 638
				end -- 638
			end -- 638
		else -- 638
			self.g05ReunionElapsed = 0 -- 643
			self.g05LineTriggered = false -- 644
			if gr.holding or gr.holdProgress > 0.001 then -- 644
				if gr.holdProgress >= self.g05SleeveExtend then -- 644
					self.g05SleeveExtend = gr.holdProgress -- 648
				elseif dt > 0 then -- 648
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 650
				end -- 650
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 650
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 654
			end -- 654
		end -- 654
	else -- 654
		self.g05SleeveExtend = 0 -- 658
		self.g05ReunionElapsed = 0 -- 659
		self.g05LineTriggered = false -- 660
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 661
	end -- 661
	self.prevPhase = p.phase -- 664
end -- 501
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 667
	local sid = ctx.events.roomSessionId -- 668
	local t = self.rehearsalTime -- 669
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 669
		ctx.audio:playOnce( -- 671
			"reh:p03:wipe:" .. tostring(sid), -- 671
			"sfx", -- 671
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 671
			0.88, -- 671
			"cuff:p03:cloth_wipe_wood", -- 671
			ctx.p.ticks -- 671
		) -- 671
	elseif self.rehearsalShot == "P05" then -- 671
		if t >= 0.9 then -- 671
			ctx.audio:playOnce( -- 674
				"reh:p05:line:" .. tostring(sid), -- 674
				"voice", -- 674
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 674
				0.9, -- 674
				"cuff:p05:line_farewell", -- 674
				ctx.p.ticks -- 674
			) -- 674
		end -- 674
		if t >= 2.75 then -- 674
			ctx.audio:playOnce( -- 677
				"reh:p05:slam:" .. tostring(sid), -- 677
				"sfx", -- 677
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 677
				0.94, -- 677
				"cuff:p05:gate_slam", -- 677
				ctx.p.ticks -- 677
			) -- 677
			ctx.audio:playLoop( -- 678
				"reh_p05_water", -- 678
				"water", -- 678
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 678
				0.42, -- 678
				ctx.p.ticks -- 678
			) -- 678
		end -- 678
	elseif self.rehearsalShot == "G05" then -- 678
		if t >= 0.05 then -- 678
			ctx.audio:playOnce( -- 682
				"reh:g05:knock1:" .. tostring(sid), -- 682
				"sfx", -- 682
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 682
				0.88, -- 682
				"knock:gate:1", -- 682
				ctx.p.ticks -- 682
			) -- 682
		end -- 682
		if t >= 0.25 then -- 682
			ctx.audio:playOnce( -- 685
				"reh:g05:knock2:" .. tostring(sid), -- 685
				"sfx", -- 685
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 685
				0.92, -- 685
				"knock:gate:2", -- 685
				ctx.p.ticks -- 685
			) -- 685
		end -- 685
		if t >= 1.55 then -- 685
			ctx.audio:playOnce( -- 688
				"reh:g05:clasp:" .. tostring(sid), -- 688
				"sfx", -- 688
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 688
				0.88, -- 688
				"cuff:g05:hand_held", -- 688
				ctx.p.ticks -- 688
			) -- 688
		end -- 688
		if t >= 2.35 then -- 688
			ctx.audio:playOnce( -- 691
				"reh:g05:line:" .. tostring(sid), -- 691
				"voice", -- 691
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 691
				0.94, -- 691
				"cuff:g05:line_reunion", -- 691
				ctx.p.ticks -- 691
			) -- 691
		end -- 691
	end -- 691
end -- 667
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 696
	if self.activeShot == "" then -- 696
		return false -- 704
	end -- 704
	local w = ctx.uiW -- 706
	local h = ctx.uiH -- 707
	if self.activeShot == "P03" then -- 707
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 710
		self:renderP03Shot( -- 713
			uiDraw, -- 713
			uiInkDraw, -- 713
			uiArt, -- 713
			uiGlow, -- 713
			ctx, -- 713
			w, -- 713
			h, -- 713
			prog -- 713
		) -- 713
		return true -- 714
	end -- 714
	if self.activeShot == "P05" then -- 714
		local prog = self.rehearsalShot == "P05" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p05Progress -- 718
		self:renderP05FullShot( -- 721
			uiDraw, -- 721
			uiInkDraw, -- 721
			uiArt, -- 721
			uiGlow, -- 721
			ctx, -- 721
			w, -- 721
			h, -- 721
			prog -- 721
		) -- 721
		return true -- 722
	end -- 722
	if self.activeShot == "G05" then -- 722
		if self.rehearsalShot == "G05" then -- 722
			self:renderG05RehearsalShot( -- 727
				uiDraw, -- 727
				uiInkDraw, -- 727
				uiArt, -- 727
				uiGlow, -- 727
				ctx, -- 727
				w, -- 727
				h, -- 727
				self.rehearsalTime -- 727
			) -- 727
			return true -- 728
		end -- 728
		self:renderG05LiveShot( -- 730
			uiDraw, -- 730
			uiInkDraw, -- 730
			uiArt, -- 730
			uiGlow, -- 730
			ctx, -- 730
			w, -- 730
			h -- 730
		) -- 730
		return true -- 731
	end -- 731
	return false -- 734
end -- 696
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 743
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 753
	local boxW = math.min(w - 140, 820) -- 755
	local boxH = math.min(h - 190, 390) -- 756
	local bx = (w - boxW) * 0.5 -- 757
	local by = (h - boxH) * 0.5 + 14 -- 758
	uiDraw:drawRect( -- 760
		Rect(0, 0, w, h), -- 760
		Color( -- 760
			7, -- 760
			9, -- 760
			14, -- 760
			math.floor(135 * fade + 0.5) -- 760
		) -- 760
	) -- 760
	fillVGradRect( -- 762
		uiDraw, -- 762
		bx, -- 762
		by, -- 762
		boxW, -- 762
		boxH, -- 762
		Color( -- 762
			14, -- 762
			13, -- 762
			16, -- 762
			math.floor(248 * fade + 0.5) -- 762
		), -- 762
		Color( -- 762
			24, -- 762
			24, -- 762
			30, -- 762
			math.floor(248 * fade + 0.5) -- 762
		) -- 762
	) -- 762
	local rimY = by + boxH * 0.34 -- 764
	uiDraw:drawRect( -- 765
		Rect(bx, by, boxW, rimY - by), -- 765
		Color( -- 765
			54, -- 765
			40, -- 765
			30, -- 765
			math.floor(252 * fade + 0.5) -- 765
		) -- 765
	) -- 765
	uiDraw:drawSegment( -- 766
		Vec2(bx, rimY), -- 766
		Vec2(bx + boxW, rimY), -- 766
		2.2, -- 766
		Color( -- 766
			128, -- 766
			100, -- 766
			76, -- 766
			math.floor(220 * fade + 0.5) -- 766
		) -- 766
	) -- 766
	local crackX = bx + boxW * 0.72 -- 768
	uiDraw:drawRect( -- 769
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 769
		Color( -- 769
			8, -- 769
			9, -- 769
			13, -- 769
			math.floor(245 * fade + 0.5) -- 769
		) -- 769
	) -- 769
	uiDraw:drawRect( -- 770
		Rect(crackX + 34, rimY, boxW - (crackX + 34 - bx), by + boxH - rimY), -- 770
		Color( -- 770
			46, -- 770
			35, -- 770
			26, -- 770
			math.floor(250 * fade + 0.5) -- 770
		) -- 770
	) -- 770
	local wipeT = smoothstep(0.3, 0.66, prog) -- 773
	local shardOffsets = {{ -- 774
		x = -72, -- 775
		y = 8, -- 775
		dx = 46, -- 775
		dy = -38, -- 775
		r = 9 -- 775
	}, { -- 775
		x = -34, -- 776
		y = 12, -- 776
		dx = 64, -- 776
		dy = -46, -- 776
		r = 7 -- 776
	}, { -- 776
		x = 4, -- 777
		y = 6, -- 777
		dx = 82, -- 777
		dy = -52, -- 777
		r = 10 -- 777
	}, { -- 777
		x = 32, -- 778
		y = 10, -- 778
		dx = 74, -- 778
		dy = -34, -- 778
		r = 6 -- 778
	}} -- 778
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 780
	if shardAlpha > 0.02 then -- 780
		local si = 0 -- 782
		do -- 782
			si = 0 -- 783
			while si < #shardOffsets do -- 783
				local sh = shardOffsets[si + 1] -- 784
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 785
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 786
				uiDraw:drawPolygon( -- 787
					{ -- 787
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 788
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 789
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 790
					}, -- 790
					Color( -- 791
						212, -- 791
						218, -- 791
						224, -- 791
						math.floor(235 * shardAlpha + 0.5) -- 791
					), -- 791
					0.9, -- 791
					Color( -- 791
						92, -- 791
						108, -- 791
						126, -- 791
						math.floor(200 * shardAlpha + 0.5) -- 791
					) -- 791
				) -- 791
				si = si + 1 -- 783
			end -- 783
		end -- 783
	end -- 783
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 796
	local handOut = smoothstep(0.7, 0.9, prog) -- 797
	if handOut > 0.05 then -- 797
		drawChildHand( -- 799
			uiDraw, -- 800
			crackX + 18 - handOut * 66, -- 801
			rimY + 52, -- 802
			math.pi, -- 803
			1.05, -- 804
			"open_fingers", -- 805
			fade * handOut, -- 806
			false -- 807
		) -- 807
	elseif fingerEnter > 0.02 then -- 807
		drawChildHand( -- 810
			uiDraw, -- 811
			crackX + 12 - fingerEnter * 24, -- 812
			rimY + 46, -- 813
			math.pi, -- 814
			1.08, -- 815
			"two_fingers", -- 816
			fade * fingerEnter, -- 817
			false -- 818
		) -- 818
	end -- 818
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 823
	if sleeveEnter > 0.01 then -- 823
		local reachT = smoothstep(0.66, 0.88, prog) -- 825
		local wx = bx + 110 + sleeveEnter * 195 + math.sin(wipeT * math.pi) * 78 + reachT * 82 -- 826
		local wy = rimY + 46 - math.sin(wipeT * math.pi) * 26 + reachT * 12 -- 827
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 828
		local pose = reachT > 0.2 and "reach" or "wipe" -- 829
		____exports.drawPatchedCuff( -- 830
			uiDraw, -- 830
			uiGlow, -- 830
			{ -- 830
				wristX = wx, -- 831
				wristY = wy, -- 832
				angleRad = ang, -- 833
				scale = 1.06, -- 834
				pose = pose, -- 835
				opacity = fade * sleeveEnter, -- 836
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 837
				warmth = 0.18 -- 838
			} -- 838
		) -- 838
	end -- 838
	uiInkDraw:drawRect( -- 843
		Rect(bx, by, boxW, boxH), -- 843
		Color(0, 0, 0, 0), -- 843
		1, -- 843
		toColor( -- 843
			PALETTE.silkDim, -- 843
			math.floor(145 * fade + 0.5) -- 843
		) -- 843
	) -- 843
	if self.rehearsalShot == "P03" then -- 843
		drawSilkVeil( -- 845
			uiDraw, -- 845
			uiArt, -- 845
			"p03_sub_veil", -- 845
			w * 0.5, -- 845
			42, -- 845
			520, -- 845
			42, -- 845
			PALETTE.inkWash, -- 845
			0.82 * fade, -- 845
			-1 -- 845
		) -- 845
		local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 846
		ctx.texts:put( -- 849
			"sm", -- 849
			subText, -- 849
			w * 0.5, -- 849
			42, -- 849
			toColor(PALETTE.textBright), -- 849
			0.5, -- 849
			0.5, -- 849
			"Center", -- 849
			1, -- 849
			fade, -- 849
			0.08 -- 849
		) -- 849
	end -- 849
end -- 743
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 859
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 869
	local boxW = math.min(w - 120, 860) -- 870
	local boxH = math.min(h - 180, 400) -- 871
	local bx = (w - boxW) * 0.5 -- 872
	local by = (h - boxH) * 0.5 + 14 -- 873
	uiDraw:drawRect( -- 875
		Rect(0, 0, w, h), -- 875
		Color( -- 875
			7, -- 875
			9, -- 875
			14, -- 875
			math.floor(145 * fade + 0.5) -- 875
		) -- 875
	) -- 875
	fillVGradRect( -- 877
		uiDraw, -- 877
		bx, -- 877
		by, -- 877
		boxW, -- 877
		boxH, -- 877
		Color( -- 877
			14, -- 877
			22, -- 877
			34, -- 877
			math.floor(248 * fade + 0.5) -- 877
		), -- 877
		Color( -- 877
			28, -- 877
			42, -- 877
			58, -- 877
			math.floor(248 * fade + 0.5) -- 877
		) -- 877
	) -- 877
	fillRadialGlow( -- 879
		uiGlow, -- 879
		bx + boxW * 0.66, -- 879
		by + boxH * 0.32, -- 879
		220, -- 879
		68, -- 879
		Color( -- 879
			152, -- 879
			194, -- 879
			224, -- 879
			math.floor(74 * fade + 0.5) -- 879
		), -- 879
		Color(40, 70, 108, 0), -- 879
		16 -- 879
	) -- 879
	local releaseT = smoothstep(0.68, 0.94, prog) -- 881
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 882
	local cuffX = bx + boxW * 0.42 - releaseT * 260 -- 885
	local cuffY = by + boxH * 0.52 -- 886
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 887
		wristX = cuffX, -- 888
		wristY = cuffY, -- 889
		angleRad = -0.06, -- 890
		scale = 1.12, -- 891
		pose = pinchT > 0.25 and "pinch" or "open", -- 892
		opacity = fade * (1 - releaseT * 0.88), -- 893
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 894
		warmth = 0.12 -- 895
	}) -- 895
	local childHandX = bx + boxW * 0.54 + releaseT * 36 -- 899
	local childHandY = by + boxH * 0.46 - releaseT * 12 -- 900
	drawChildHand( -- 901
		uiDraw, -- 902
		childHandX, -- 903
		childHandY, -- 904
		math.pi + 0.12, -- 905
		1.12, -- 906
		releaseT > 0.35 and "open_fingers" or "clutch", -- 907
		fade, -- 908
		true -- 909
	) -- 909
	if releaseT > 0.01 then -- 909
		local dropH = boxH * releaseT * 0.88 -- 914
		uiDraw:drawRect( -- 915
			Rect(bx, by + boxH - dropH, boxW * 0.46, dropH), -- 915
			Color( -- 915
				26, -- 915
				22, -- 915
				20, -- 915
				math.floor(238 * fade + 0.5) -- 915
			) -- 915
		) -- 915
		uiDraw:drawSegment( -- 916
			Vec2(bx, by + boxH - dropH), -- 916
			Vec2(bx + boxW * 0.46, by + boxH - dropH), -- 916
			2.4, -- 916
			Color( -- 916
				118, -- 916
				104, -- 916
				88, -- 916
				math.floor(220 * fade + 0.5) -- 916
			) -- 916
		) -- 916
	end -- 916
	uiInkDraw:drawRect( -- 919
		Rect(bx, by, boxW, boxH), -- 919
		Color(0, 0, 0, 0), -- 919
		1, -- 919
		toColor( -- 919
			PALETTE.silkDim, -- 919
			math.floor(150 * fade + 0.5) -- 919
		) -- 919
	) -- 919
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 922
	if lineAlpha > 0.02 then -- 922
		drawSilkVeil( -- 924
			uiDraw, -- 924
			uiArt, -- 924
			"p05_sub_veil", -- 924
			w * 0.5, -- 924
			42, -- 924
			740, -- 924
			44, -- 924
			PALETTE.inkWash, -- 924
			0.86 * lineAlpha, -- 924
			-1 -- 924
		) -- 924
		drawHairline( -- 925
			uiInkDraw, -- 925
			uiArt, -- 925
			"p05_sub_line", -- 925
			w * 0.5, -- 925
			62, -- 925
			520, -- 925
			PALETTE.silkDim, -- 925
			0.52 * lineAlpha, -- 925
			true, -- 925
			2 -- 925
		) -- 925
		ctx.texts:put( -- 926
			"sm", -- 926
			LINE_P05, -- 926
			w * 0.5, -- 926
			42, -- 926
			toColor(PALETTE.textBright), -- 926
			0.5, -- 926
			0.5, -- 926
			"Center", -- 926
			0.8, -- 926
			lineAlpha, -- 926
			0.08 -- 926
		) -- 926
	end -- 926
end -- 859
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 931
	local enter = smoothstep(0, 0.12, t) -- 941
	local out = smoothstep(0.66, 1, t) -- 942
	local alpha = enter * (1 - out) -- 943
	if alpha <= 0.02 then -- 943
		return -- 945
	end -- 945
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 947
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 948
		wristX = w * 0.25 - out * 240, -- 949
		wristY = h * 0.4, -- 950
		angleRad = -0.05, -- 951
		scale = 0.94, -- 952
		pose = pinchT > 0.25 and "pinch" or "open", -- 953
		opacity = alpha * 0.94, -- 954
		stitchHighlight = 0.45 + 0.28 * pinchT -- 955
	}) -- 955
	drawChildHand( -- 957
		uiDraw, -- 958
		w * 0.35 + out * 26, -- 959
		h * 0.37 - out * 10, -- 960
		math.pi + 0.1, -- 961
		0.94, -- 962
		out > 0.32 and "open_fingers" or "clutch", -- 963
		alpha * 0.92, -- 964
		true -- 965
	) -- 965
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 967
	if lineAlpha > 0.02 then -- 967
		local subY = 92 -- 969
		drawSilkVeil( -- 970
			uiDraw, -- 970
			uiArt, -- 970
			"p05_live_veil", -- 970
			w * 0.5, -- 970
			subY, -- 970
			760, -- 970
			44, -- 970
			PALETTE.inkWash, -- 970
			0.86 * lineAlpha, -- 970
			-1 -- 970
		) -- 970
		drawHairline( -- 971
			uiInkDraw, -- 971
			uiArt, -- 971
			"p05_live_line", -- 971
			w * 0.5, -- 971
			subY + 20, -- 971
			520, -- 971
			PALETTE.silkDim, -- 971
			0.52 * lineAlpha, -- 971
			true, -- 971
			2 -- 971
		) -- 971
		ctx.texts:put( -- 972
			"sm", -- 972
			LINE_P05, -- 972
			w * 0.5, -- 972
			subY, -- 972
			toColor(PALETTE.textBright), -- 972
			0.5, -- 972
			0.5, -- 972
			"Center", -- 972
			0.8, -- 972
			lineAlpha, -- 972
			0.08 -- 972
		) -- 972
	end -- 972
end -- 931
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 982
	local view = ctx.view -- 991
	local gr = view.gateReunion -- 992
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 993
	local ext = clamp01(self.g05SleeveExtend) -- 994
	if not completed then -- 994
		if ext > 0.008 then -- 994
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 1000
			fillVGradRect( -- 1001
				uiDraw, -- 1001
				0, -- 1001
				h * 0.28, -- 1001
				w, -- 1001
				h * 0.16, -- 1001
				Color(8, 11, 18, 0), -- 1001
				Color(8, 11, 18, veilA) -- 1001
			) -- 1001
			fillVGradRect( -- 1002
				uiDraw, -- 1002
				0, -- 1002
				h * 0.44, -- 1002
				w, -- 1002
				h * 0.16, -- 1002
				Color(8, 11, 18, veilA), -- 1002
				Color(8, 11, 18, 0) -- 1002
			) -- 1002
			local cuffX = -46 + ext * (w * 0.42 + 46) -- 1004
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1005
			____exports.drawPatchedCuff( -- 1006
				uiDraw, -- 1006
				uiGlow, -- 1006
				{ -- 1006
					wristX = cuffX, -- 1007
					wristY = cuffY, -- 1008
					angleRad = -0.05, -- 1009
					scale = 1.08, -- 1010
					pose = ext > 0.82 and "clasp" or "reach", -- 1011
					opacity = clamp01(0.32 + ext * 0.68), -- 1012
					stitchHighlight = 0.35 + 0.6 * ext -- 1013
				} -- 1013
			) -- 1013
			local childX = w * 0.64 - ext * (w * 0.13) -- 1017
			local childY = h * 0.41 + ext * 14 -- 1018
			drawChildHand( -- 1019
				uiDraw, -- 1020
				childX, -- 1021
				childY, -- 1022
				math.pi + 0.08, -- 1023
				1.06, -- 1024
				ext > 0.88 and "clasp" or "reach_up", -- 1025
				clamp01(0.25 + ext * 0.75), -- 1026
				true -- 1027
			) -- 1027
			local barW = 240 -- 1031
			local bx0 = w * 0.5 - barW * 0.5 -- 1032
			local by0 = 18 -- 1033
			uiInkDraw:drawSegment( -- 1034
				Vec2(bx0, by0), -- 1034
				Vec2(bx0 + barW, by0), -- 1034
				1.2, -- 1034
				toColor(PALETTE.silkDim, 110) -- 1034
			) -- 1034
			uiInkDraw:drawSegment( -- 1035
				Vec2(bx0, by0), -- 1035
				Vec2(bx0 + barW * ext, by0), -- 1035
				2.4, -- 1035
				toColor(PALETTE.amberCore, 230) -- 1035
			) -- 1035
		else -- 1035
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1038
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1039
				wristX = -120 + peekPulse * 14, -- 1040
				wristY = h * 0.44, -- 1041
				angleRad = -0.04, -- 1042
				scale = 1.04, -- 1043
				pose = "open", -- 1044
				opacity = 0.36 + 0.22 * peekPulse, -- 1045
				stitchHighlight = 0.35 * peekPulse -- 1046
			}) -- 1046
		end -- 1046
		if view.assistHintsEnabled then -- 1046
			drawSilkVeil( -- 1052
				uiDraw, -- 1052
				uiArt, -- 1052
				"g05_assist_veil", -- 1052
				w * 0.5, -- 1052
				h - 26, -- 1052
				280, -- 1052
				28, -- 1052
				PALETTE.inkWash, -- 1052
				0.72, -- 1052
				-1 -- 1052
			) -- 1052
			ctx.texts:put( -- 1053
				"xs", -- 1054
				getActiveTarget():adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1055
				w * 0.5, -- 1056
				h - 26, -- 1057
				toColor(PALETTE.amberCore), -- 1058
				0.5, -- 1059
				0.5, -- 1060
				"Center", -- 1061
				1.2, -- 1062
				0.9, -- 1063
				0.08 -- 1064
			) -- 1064
		end -- 1064
		return -- 1067
	end -- 1067
	local t = self.g05ReunionElapsed -- 1071
	local claspPull = smoothstep(0, 0.35, t) -- 1072
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1073
	local armDropY = tilt * (h * 0.26) -- 1074
	local claspFade = 1 - smoothstep(0.95, 1.45, t) * 0.45 -- 1077
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1078
		wristX = w * 0.44, -- 1079
		wristY = h * 0.44 - armDropY, -- 1080
		angleRad = -0.05 + tilt * 0.22, -- 1081
		scale = 1.08, -- 1082
		pose = "clasp", -- 1083
		opacity = claspFade, -- 1084
		stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1085
		cuffPullBack = claspPull * 0.85, -- 1086
		warmth = tilt * 0.32 -- 1087
	}) -- 1087
	drawChildHand( -- 1089
		uiDraw, -- 1090
		w * 0.53, -- 1091
		h * 0.43 - armDropY, -- 1092
		math.pi + 0.05 - tilt * 0.14, -- 1093
		1.08, -- 1094
		"clasp", -- 1095
		claspFade, -- 1096
		true -- 1097
	) -- 1097
	local portraitAlpha = smoothstep(0.32, 0.88, t) -- 1101
	if portraitAlpha > 0.02 then -- 1101
		local py = h * 0.56 + (1 - portraitAlpha) * 26 -- 1103
		drawZhouShuReunionPortrait( -- 1104
			uiDraw, -- 1104
			uiInkDraw, -- 1104
			uiArt, -- 1104
			uiGlow, -- 1104
			w * 0.72, -- 1104
			py, -- 1104
			1, -- 1104
			portraitAlpha -- 1104
		) -- 1104
	end -- 1104
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1108
	if lineAlpha > 0.02 then -- 1108
		drawSilkVeil( -- 1110
			uiDraw, -- 1110
			uiArt, -- 1110
			"g05_line_veil", -- 1110
			w * 0.5, -- 1110
			42, -- 1110
			420, -- 1110
			44, -- 1110
			PALETTE.inkWash, -- 1110
			0.86 * lineAlpha, -- 1110
			-1 -- 1110
		) -- 1110
		drawHairline( -- 1111
			uiInkDraw, -- 1111
			uiArt, -- 1111
			"g05_line_bar", -- 1111
			w * 0.5, -- 1111
			62, -- 1111
			260, -- 1111
			PALETTE.amber, -- 1111
			0.58 * lineAlpha, -- 1111
			true, -- 1111
			2 -- 1111
		) -- 1111
		ctx.texts:put( -- 1112
			"sm", -- 1112
			LINE_G05, -- 1112
			w * 0.5, -- 1112
			42, -- 1112
			toColor(PALETTE.textBright), -- 1112
			0.5, -- 1112
			0.5, -- 1112
			"Center", -- 1112
			2.2, -- 1112
			lineAlpha, -- 1112
			0.08 -- 1112
		) -- 1112
	end -- 1112
end -- 982
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1117
	local holdExt = smoothstep(0.55, 1.45, t) -- 1128
	local tilt = smoothstep(1.55, 2.55, t) -- 1129
	local claspPull = smoothstep(1.4, 1.75, t) -- 1130
	local armDropY = tilt * (h * 0.24) -- 1131
	local boxW = math.min(w - 120, 860) -- 1133
	local boxH = math.min(h - 180, 400) -- 1134
	local bx = (w - boxW) * 0.5 -- 1135
	local by = (h - boxH) * 0.5 + 14 -- 1136
	uiDraw:drawRect( -- 1137
		Rect(0, 0, w, h), -- 1137
		Color(7, 9, 14, 150) -- 1137
	) -- 1137
	local bgTop = lerpRGBA( -- 1138
		rgba(16, 24, 36, 250), -- 1138
		rgba(20, 26, 36, 250), -- 1138
		tilt -- 1138
	) -- 1138
	local bgBot = lerpRGBA( -- 1139
		rgba(10, 15, 24, 250), -- 1139
		rgba(14, 18, 26, 250), -- 1139
		tilt -- 1139
	) -- 1139
	fillVGradRect( -- 1140
		uiDraw, -- 1140
		bx, -- 1140
		by, -- 1140
		boxW, -- 1140
		boxH, -- 1140
		toColor(bgBot), -- 1140
		toColor(bgTop) -- 1140
	) -- 1140
	if tilt > 0.05 then -- 1140
		drawZhouShuReunionPortrait( -- 1143
			uiDraw, -- 1143
			uiInkDraw, -- 1143
			uiArt, -- 1143
			uiGlow, -- 1143
			bx + boxW * 0.72, -- 1143
			by + boxH * 0.54 + (1 - tilt) * 24, -- 1143
			0.92, -- 1143
			tilt -- 1143
		) -- 1143
	end -- 1143
	____exports.drawPatchedCuff( -- 1146
		uiDraw, -- 1146
		uiGlow, -- 1146
		{ -- 1146
			wristX = bx + 20 + holdExt * (boxW * 0.4), -- 1147
			wristY = by + boxH * 0.52 - armDropY, -- 1148
			angleRad = -0.05 + tilt * 0.2, -- 1149
			scale = 1.06, -- 1150
			pose = t >= 1.4 and "clasp" or "reach", -- 1151
			opacity = clamp01(0.25 + holdExt * 0.75), -- 1152
			stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1153
			cuffPullBack = claspPull * 0.85, -- 1154
			warmth = tilt * 0.32 -- 1155
		} -- 1155
	) -- 1155
	drawChildHand( -- 1157
		uiDraw, -- 1158
		bx + boxW * 0.64 - holdExt * (boxW * 0.12), -- 1159
		by + boxH * 0.48 - armDropY, -- 1160
		math.pi + 0.06, -- 1161
		1.06, -- 1162
		t >= 1.4 and "clasp" or "reach_up", -- 1163
		clamp01(0.35 + holdExt * 0.65), -- 1164
		true -- 1165
	) -- 1165
	uiInkDraw:drawRect( -- 1168
		Rect(bx, by, boxW, boxH), -- 1168
		Color(0, 0, 0, 0), -- 1168
		1, -- 1168
		toColor(PALETTE.silkDim, 145) -- 1168
	) -- 1168
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1170
	if lineAlpha > 0.02 then -- 1170
		drawSilkVeil( -- 1172
			uiDraw, -- 1172
			uiArt, -- 1172
			"g05_reh_veil", -- 1172
			w * 0.5, -- 1172
			42, -- 1172
			420, -- 1172
			44, -- 1172
			PALETTE.inkWash, -- 1172
			0.86 * lineAlpha, -- 1172
			-1 -- 1172
		) -- 1172
		drawHairline( -- 1173
			uiInkDraw, -- 1173
			uiArt, -- 1173
			"g05_reh_bar", -- 1173
			w * 0.5, -- 1173
			62, -- 1173
			260, -- 1173
			PALETTE.amber, -- 1173
			0.58 * lineAlpha, -- 1173
			true, -- 1173
			2 -- 1173
		) -- 1173
		ctx.texts:put( -- 1174
			"sm", -- 1174
			LINE_G05, -- 1174
			w * 0.5, -- 1174
			42, -- 1174
			toColor(PALETTE.textBright), -- 1174
			0.5, -- 1174
			0.5, -- 1174
			"Center", -- 1174
			2.2, -- 1174
			lineAlpha, -- 1174
			0.08 -- 1174
		) -- 1174
	end -- 1174
end -- 1117
function ____exports.createCuffShotsPlugin() -- 1179
	return __TS__New(____exports.CuffShotsPlugin) -- 1180
end -- 1179
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1187
	local gateTransition = createGateTransitionPlugin() -- 1191
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1192
	fe:registerPlugin(gateTransition) -- 1193
	fe:registerPlugin(cuffShots) -- 1194
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1195
end -- 1187
return ____exports -- 1187