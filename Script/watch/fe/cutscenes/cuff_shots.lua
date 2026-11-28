-- [ts]: cuff_shots.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local Color = ____Dora.Color -- 21
local Vec2 = ____Dora.Vec2 -- 21
local ____play = require("Script.watch.play") -- 22
local GATE_FAREWELL_TICKS = ____play.GATE_FAREWELL_TICKS -- 22
local PROLOGUE_GIVE_TICKS = ____play.PROLOGUE_GIVE_TICKS -- 22
local ____target = require("Script.watch.target") -- 26
local getActiveTarget = ____target.getActiveTarget -- 26
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 28
local createGateTransitionPlugin = ____gate_transition.createGateTransitionPlugin -- 32
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 34
local clamp01 = ____lowpoly.clamp01 -- 34
local smoothstep = ____lowpoly.smoothstep -- 34
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 35
local drawComicSequence = ____slideshow.drawComicSequence -- 35
local ____theme = require("Script.watch.fe.theme") -- 36
local PALETTE = ____theme.PALETTE -- 37
local drawHairline = ____theme.drawHairline -- 39
local drawSilkVeil = ____theme.drawSilkVeil -- 40
local fillRadialGlow = ____theme.fillRadialGlow -- 41
local fillVGradRect = ____theme.fillVGradRect -- 42
local lerpRGBA = ____theme.lerpRGBA -- 43
local rgba = ____theme.rgba -- 44
local toColor = ____theme.toColor -- 45
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 90
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 91
local LINE_G05 = "「我们走吧。」" -- 92
--- P03 柜边相认硬核木刻漫画 24 帧逐帧动画拍表（归一化 0..1 对应 3.00s，均速 8.0 fps、拂瓷高潮 11.4 fps）
local P03_COMIC_SEQ = { -- 95
	{slot = "comic_p03_f01", start = 0, ["end"] = 0.0467, transition = "cut"}, -- 97
	{slot = "comic_p03_f02", start = 0.0467, ["end"] = 0.0933, transition = "cut"}, -- 98
	{slot = "comic_p03_f03", start = 0.0933, ["end"] = 0.14, transition = "cut"}, -- 99
	{slot = "comic_p03_f04", start = 0.14, ["end"] = 0.1833, transition = "cut"}, -- 100
	{slot = "comic_p03_f05", start = 0.1833, ["end"] = 0.22, transition = "cut"}, -- 102
	{slot = "comic_p03_f06", start = 0.22, ["end"] = 0.2567, transition = "cut"}, -- 103
	{slot = "comic_p03_f07", start = 0.2567, ["end"] = 0.2933, transition = "cut"}, -- 104
	{slot = "comic_p03_f08", start = 0.2933, ["end"] = 0.3333, transition = "cut"}, -- 105
	{ -- 107
		slot = "comic_p03_f09", -- 107
		start = 0.3333, -- 107
		["end"] = 0.3633, -- 107
		transition = "cut", -- 107
		shakeAmp = 2.2, -- 107
		shakeFreq = 54 -- 107
	}, -- 107
	{slot = "comic_p03_f10", start = 0.3633, ["end"] = 0.3917, transition = "cut"}, -- 108
	{slot = "comic_p03_f11", start = 0.3917, ["end"] = 0.42, transition = "cut"}, -- 109
	{ -- 110
		slot = "comic_p03_f12", -- 110
		start = 0.42, -- 110
		["end"] = 0.45, -- 110
		transition = "cut", -- 110
		shakeAmp = 4.5, -- 110
		shakeFreq = 66 -- 110
	}, -- 110
	{slot = "comic_p03_f13", start = 0.45, ["end"] = 0.4833, transition = "cut"}, -- 112
	{slot = "comic_p03_f14", start = 0.4833, ["end"] = 0.52, transition = "cut"}, -- 113
	{slot = "comic_p03_f15", start = 0.52, ["end"] = 0.56, transition = "cut"}, -- 114
	{slot = "comic_p03_f16", start = 0.56, ["end"] = 0.6067, transition = "cut"}, -- 115
	{slot = "comic_p03_f17", start = 0.6067, ["end"] = 0.65, transition = "cut"}, -- 117
	{slot = "comic_p03_f18", start = 0.65, ["end"] = 0.69, transition = "cut"}, -- 118
	{slot = "comic_p03_f19", start = 0.69, ["end"] = 0.73, transition = "cut"}, -- 119
	{slot = "comic_p03_f20", start = 0.73, ["end"] = 0.7733, transition = "cut"}, -- 120
	{slot = "comic_p03_f21", start = 0.7733, ["end"] = 0.82, transition = "cut"}, -- 122
	{slot = "comic_p03_f22", start = 0.82, ["end"] = 0.8667, transition = "cut"}, -- 123
	{slot = "comic_p03_f23", start = 0.8667, ["end"] = 0.9167, transition = "cut"}, -- 124
	{slot = "comic_p03_f24", start = 0.9167, ["end"] = 1, transition = "cut"} -- 125
} -- 125
--- P05 城门送别硬核木刻漫画 17 帧逐帧动画拍表（归一化进度 0..1，含 0.72 落门单帧三色木刻冲击与峰值 11 fps 爆裂收指）
local P05_COMIC_SEQ = { -- 129
	{slot = "comic_p05_f01", start = 0, ["end"] = 0.095, transition = "cut"}, -- 130
	{slot = "comic_p05_f02", start = 0.095, ["end"] = 0.19, transition = "cut"}, -- 131
	{slot = "comic_p05_f03", start = 0.19, ["end"] = 0.285, transition = "cut"}, -- 132
	{slot = "comic_p05_f04", start = 0.285, ["end"] = 0.375, transition = "cut"}, -- 133
	{slot = "comic_p05_f05", start = 0.375, ["end"] = 0.46, transition = "cut"}, -- 134
	{slot = "comic_p05_f06", start = 0.46, ["end"] = 0.54, transition = "cut"}, -- 135
	{slot = "comic_p05_f07", start = 0.54, ["end"] = 0.61, transition = "cut"}, -- 136
	{ -- 137
		slot = "comic_p05_f08", -- 137
		start = 0.61, -- 137
		["end"] = 0.665, -- 137
		transition = "cut", -- 137
		shakeAmp = 3.2, -- 137
		shakeFreq = 56 -- 137
	}, -- 137
	{ -- 138
		slot = "comic_p05_f09", -- 138
		start = 0.665, -- 138
		["end"] = 0.72, -- 138
		transition = "cut", -- 138
		shakeAmp = 5, -- 138
		shakeFreq = 64 -- 138
	}, -- 138
	{ -- 139
		slot = "comic_p05_f10", -- 139
		start = 0.72, -- 139
		["end"] = 0.77, -- 139
		zoomFrom = 1.036, -- 139
		zoomTo = 1.036, -- 139
		transition = "cut", -- 139
		impactFlash = true, -- 139
		impactDur = 0.06, -- 139
		shakeAmp = 12, -- 139
		shakeFreq = 74 -- 139
	}, -- 139
	{ -- 140
		slot = "comic_p05_f11", -- 140
		start = 0.77, -- 140
		["end"] = 0.805, -- 140
		transition = "cut", -- 140
		shakeAmp = 4.5, -- 140
		shakeFreq = 60 -- 140
	}, -- 140
	{ -- 141
		slot = "comic_p05_f12", -- 141
		start = 0.805, -- 141
		["end"] = 0.84, -- 141
		transition = "cut", -- 141
		shakeAmp = 2.5 -- 141
	}, -- 141
	{slot = "comic_p05_f13", start = 0.84, ["end"] = 0.875, transition = "cut"}, -- 142
	{slot = "comic_p05_f14", start = 0.875, ["end"] = 0.908, transition = "cut"}, -- 143
	{slot = "comic_p05_f15", start = 0.908, ["end"] = 0.94, transition = "cut"}, -- 144
	{slot = "comic_p05_f16", start = 0.94, ["end"] = 0.97, transition = "cut"}, -- 145
	{slot = "comic_p05_f17", start = 0.97, ["end"] = 1, transition = "cut"} -- 146
} -- 146
--- G05 长按伸袖交互 8 帧连续拍表（严格跟随 holdProgress 0..1）
local G05_HOLD_COMIC_SEQ = { -- 150
	{slot = "comic_g05_f01", start = 0, ["end"] = 0.125, transition = "cut"}, -- 151
	{slot = "comic_g05_f02", start = 0.125, ["end"] = 0.25, transition = "cut"}, -- 152
	{slot = "comic_g05_f03", start = 0.25, ["end"] = 0.375, transition = "cut"}, -- 153
	{slot = "comic_g05_f04", start = 0.375, ["end"] = 0.5, transition = "cut"}, -- 154
	{slot = "comic_g05_f05", start = 0.5, ["end"] = 0.625, transition = "cut"}, -- 155
	{slot = "comic_g05_f06", start = 0.625, ["end"] = 0.75, transition = "cut"}, -- 156
	{slot = "comic_g05_f07", start = 0.75, ["end"] = 0.875, transition = "cut"}, -- 157
	{slot = "comic_g05_f08", start = 0.875, ["end"] = 1, transition = "cut"} -- 158
} -- 158
--- G05 握稳重逢顺臂抬镜至周戍露脸暖笑 12 帧连续拍表（秒）
local G05_REUNION_COMIC_SEQ = { -- 162
	{slot = "comic_g05_f09", start = 0, ["end"] = 0.16, transition = "cut"}, -- 163
	{slot = "comic_g05_f10", start = 0.16, ["end"] = 0.32, transition = "cut"}, -- 164
	{slot = "comic_g05_f11", start = 0.32, ["end"] = 0.48, transition = "cut"}, -- 165
	{slot = "comic_g05_f12", start = 0.48, ["end"] = 0.66, transition = "cut"}, -- 166
	{slot = "comic_g05_f13", start = 0.66, ["end"] = 0.84, transition = "cut"}, -- 167
	{slot = "comic_g05_f14", start = 0.84, ["end"] = 1.02, transition = "cut"}, -- 168
	{slot = "comic_g05_f15", start = 1.02, ["end"] = 1.2, transition = "cut"}, -- 169
	{slot = "comic_g05_f16", start = 1.2, ["end"] = 1.4, transition = "cut"}, -- 170
	{slot = "comic_g05_f17", start = 1.4, ["end"] = 1.62, transition = "cut"}, -- 171
	{slot = "comic_g05_f18", start = 1.62, ["end"] = 1.86, transition = "cut"}, -- 172
	{slot = "comic_g05_f19", start = 1.86, ["end"] = 2.12, transition = "cut"}, -- 173
	{slot = "comic_g05_f20", start = 2.12, ["end"] = 12, transition = "cut"} -- 174
} -- 174
--- G05 4.5 秒独立排演全 20 帧连续拍表（6–8 fps）
local G05_REHEARSAL_COMIC_SEQ = { -- 178
	{slot = "comic_g05_f01", start = 0, ["end"] = 0.19, transition = "cut"}, -- 179
	{slot = "comic_g05_f02", start = 0.19, ["end"] = 0.38, transition = "cut"}, -- 180
	{slot = "comic_g05_f03", start = 0.38, ["end"] = 0.57, transition = "cut"}, -- 181
	{slot = "comic_g05_f04", start = 0.57, ["end"] = 0.76, transition = "cut"}, -- 182
	{slot = "comic_g05_f05", start = 0.76, ["end"] = 0.94, transition = "cut"}, -- 183
	{slot = "comic_g05_f06", start = 0.94, ["end"] = 1.12, transition = "cut"}, -- 184
	{slot = "comic_g05_f07", start = 1.12, ["end"] = 1.3, transition = "cut"}, -- 185
	{slot = "comic_g05_f08", start = 1.3, ["end"] = 1.48, transition = "cut"}, -- 186
	{slot = "comic_g05_f09", start = 1.48, ["end"] = 1.66, transition = "cut"}, -- 187
	{slot = "comic_g05_f10", start = 1.66, ["end"] = 1.84, transition = "cut"}, -- 188
	{slot = "comic_g05_f11", start = 1.84, ["end"] = 2.02, transition = "cut"}, -- 189
	{slot = "comic_g05_f12", start = 2.02, ["end"] = 2.2, transition = "cut"}, -- 190
	{slot = "comic_g05_f13", start = 2.2, ["end"] = 2.38, transition = "cut"}, -- 191
	{slot = "comic_g05_f14", start = 2.38, ["end"] = 2.58, transition = "cut"}, -- 192
	{slot = "comic_g05_f15", start = 2.58, ["end"] = 2.78, transition = "cut"}, -- 193
	{slot = "comic_g05_f16", start = 2.78, ["end"] = 3, transition = "cut"}, -- 194
	{slot = "comic_g05_f17", start = 3, ["end"] = 3.24, transition = "cut"}, -- 195
	{slot = "comic_g05_f18", start = 3.24, ["end"] = 3.5, transition = "cut"}, -- 196
	{slot = "comic_g05_f19", start = 3.5, ["end"] = 3.8, transition = "cut"}, -- 197
	{slot = "comic_g05_f20", start = 3.8, ["end"] = 4.5, transition = "cut"} -- 198
} -- 198
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 202
	indigoBase = rgba(34, 52, 74, 255), -- 203
	indigoShadow = rgba(18, 28, 42, 255), -- 204
	indigoFold = rgba(54, 78, 104, 255), -- 205
	patchDark = rgba(24, 38, 56, 255), -- 206
	hemEdge = rgba(68, 92, 118, 255), -- 207
	armWrapLinen = rgba(154, 142, 120, 255), -- 208
	armWrapShadow = rgba(102, 92, 78, 255), -- 209
	stitchThread = rgba(232, 224, 204, 255), -- 211
	stitchPinhole = rgba(14, 19, 28, 255), -- 212
	skinBase = rgba(188, 146, 116, 255), -- 213
	skinShadow = rgba(138, 102, 78, 255), -- 214
	skinLight = rgba(216, 178, 148, 255), -- 215
	childSkin = rgba(226, 196, 170, 255), -- 216
	childSkinShadow = rgba(176, 144, 120, 255), -- 217
	childSleeve = rgba(164, 142, 114, 255), -- 218
	childCord = rgba(168, 56, 52, 255) -- 219
} -- 219
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 222
	local sx = lx * scale -- 223
	local sy = ly * scale -- 224
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 225
end -- 222
local function tinted(base, warmth, opacity) -- 228
	local warmTarget = rgba( -- 229
		math.min(255, base.r + 22), -- 230
		math.min(255, base.g + 12), -- 231
		math.max(0, base.b - 10), -- 232
		base.a -- 233
	) -- 233
	local mixed = lerpRGBA( -- 235
		base, -- 235
		warmTarget, -- 235
		clamp01(warmth) -- 235
	) -- 235
	return toColor( -- 236
		mixed, -- 236
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 236
	) -- 236
end -- 228
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 243
	local op = clamp01(opts.opacity or 1) -- 248
	if op <= 0.01 then -- 248
		return -- 250
	end -- 250
	local ox = opts.wristX -- 252
	local oy = opts.wristY -- 253
	local s = math.max(0.2, opts.scale) -- 254
	local cosA = math.cos(opts.angleRad) -- 255
	local sinA = math.sin(opts.angleRad) -- 256
	local w = clamp01(opts.warmth or 0) -- 257
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 258
	local function pt(lx, ly) -- 259
		return rotPt( -- 259
			ox, -- 259
			oy, -- 259
			lx, -- 259
			ly, -- 259
			cosA, -- 259
			sinA, -- 259
			s -- 259
		) -- 259
	end -- 259
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 260
	if opts.uiArt ~= nil then -- 260
		local framePath = (opts.pose == "clasp" or opts.pose == "pinch") and "assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp" or "assets/art/cutscene_cuff_rig.clip|cuff_zhou_open" -- 264
		local key = opts.instanceKey or "patched_cuff_zhou" -- 267
		local spriteW = 368 * s -- 268
		local spriteH = 166 * s -- 269
		local anchorOffset = pull * 0.55 -- 270
		local placedPos = pt(-anchorOffset, 0) -- 271
		local tintCol = tinted( -- 272
			rgba(232, 238, 246, 255), -- 272
			w * 0.72, -- 272
			1 -- 272
		) -- 272
		if opts.uiArt:tryPlacePath( -- 272
			framePath, -- 273
			key, -- 273
			placedPos.x, -- 273
			placedPos.y, -- 273
			spriteW, -- 273
			spriteH, -- 273
			{ -- 273
				anchorX = 0.57, -- 274
				anchorY = 0.5, -- 275
				angle = -(opts.angleRad * 180) / math.pi, -- 276
				color = tintCol, -- 277
				opacity = op, -- 278
				smooth = true, -- 279
				layer = opts.layer or 4 -- 280
			} -- 280
		) then -- 280
			if hl > 0.08 then -- 280
				local stitchPos = pt(-58 - anchorOffset, -6) -- 283
				fillRadialGlow( -- 284
					glow, -- 285
					stitchPos.x, -- 286
					stitchPos.y, -- 287
					36 * s, -- 288
					22 * s, -- 289
					toColor( -- 290
						____exports.CUFF_PALETTE.stitchThread, -- 290
						math.floor(52 * hl * op + 0.5) -- 290
					), -- 290
					toColor(____exports.CUFF_PALETTE.stitchThread, 0), -- 291
					12 -- 292
				) -- 292
			end -- 292
			return -- 295
		end -- 295
	end -- 295
	local cuffFront = 6 - pull -- 300
	draw:drawPolygon( -- 301
		{ -- 301
			pt(-250, -48), -- 302
			pt(cuffFront, -36), -- 303
			pt(cuffFront, 38), -- 304
			pt(-250, 52) -- 305
		}, -- 305
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 306
		1.4, -- 306
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 306
	) -- 306
	draw:drawPolygon( -- 309
		{ -- 309
			pt(-250, -48), -- 310
			pt(cuffFront, -36), -- 311
			pt(cuffFront, -8), -- 312
			pt(-250, -14) -- 313
		}, -- 313
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 314
	) -- 314
	draw:drawPolygon( -- 317
		{ -- 317
			pt(-230, 14), -- 318
			pt(cuffFront - 6, 10), -- 319
			pt(cuffFront - 4, 32), -- 320
			pt(-230, 40) -- 321
		}, -- 321
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 322
	) -- 322
	draw:drawSegment( -- 323
		pt(-185, 16), -- 323
		pt(cuffFront - 18, 12), -- 323
		1.2 * s, -- 323
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 323
	) -- 323
	draw:drawSegment( -- 324
		pt(-160, -10), -- 324
		pt(cuffFront - 26, -6), -- 324
		1.1 * s, -- 324
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 324
	) -- 324
	draw:drawPolygon( -- 327
		{ -- 327
			pt(cuffFront - 8, -28), -- 328
			pt(cuffFront + 16, -24), -- 329
			pt(cuffFront + 16, 26), -- 330
			pt(cuffFront - 8, 28) -- 331
		}, -- 331
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 332
		1, -- 332
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 332
	) -- 332
	draw:drawSegment( -- 333
		pt(cuffFront + 3, -25), -- 333
		pt(cuffFront + 7, 25), -- 333
		1.3 * s, -- 333
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 333
	) -- 333
	draw:drawPolygon( -- 336
		{ -- 336
			pt(cuffFront - 16, -37), -- 337
			pt(cuffFront + 2, -36), -- 338
			pt(cuffFront + 2, 38), -- 339
			pt(cuffFront - 16, 39) -- 340
		}, -- 340
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 341
		1.3, -- 341
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 341
	) -- 341
	local pX0 = cuffFront - 72 -- 344
	local pX1 = cuffFront - 18 -- 345
	local pY0 = -16 -- 346
	local pY1 = 22 -- 347
	draw:drawPolygon( -- 348
		{ -- 348
			pt(pX0, pY0), -- 349
			pt(pX1, pY0 + 3), -- 350
			pt(pX1 - 2, pY1), -- 351
			pt(pX0 + 3, pY1 - 2) -- 352
		}, -- 352
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 353
		1.1, -- 353
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 353
	) -- 353
	local seamStartX = pX0 + 6 -- 356
	local seamStartY = pY0 + 5 -- 357
	local seamEndX = pX1 - 7 -- 358
	local seamEndY = pY1 - 5 -- 359
	draw:drawSegment( -- 360
		pt(seamStartX, seamStartY), -- 361
		pt(seamEndX, seamEndY), -- 362
		1.5 * s, -- 363
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 364
	) -- 364
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 367
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 368
	local stitches = 6 -- 369
	local k = 0 -- 370
	do -- 370
		k = 0 -- 371
		while k < stitches do -- 371
			local t = (k + 0.5) / stitches -- 372
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 373
			local my = seamStartY + (seamEndY - seamStartY) * t -- 374
			local nx = -4.8 -- 375
			local ny = 6.2 -- 376
			local a = pt(mx - nx, my - ny) -- 377
			local b = pt(mx + nx, my + ny) -- 378
			draw:drawDot(a, 1.3 * s, pinCol) -- 379
			draw:drawDot(b, 1.3 * s, pinCol) -- 380
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 381
			if hl > 0.05 then -- 381
				glow:drawSegment( -- 383
					a, -- 383
					b, -- 383
					2.4 * s, -- 383
					toColor( -- 383
						____exports.CUFF_PALETTE.stitchThread, -- 383
						math.floor(74 * hl * op + 0.5) -- 383
					) -- 383
				) -- 383
			end -- 383
			k = k + 1 -- 371
		end -- 371
	end -- 371
	local handBase = cuffFront + 14 -- 388
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 389
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 390
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 391
	if opts.pose == "wipe" then -- 391
		draw:drawPolygon( -- 395
			{ -- 395
				pt(handBase - 4, -20), -- 396
				pt(handBase + 46, -24), -- 397
				pt(handBase + 54, 4), -- 398
				pt(handBase + 38, 22), -- 399
				pt(handBase - 4, 20) -- 400
			}, -- 400
			skinCol, -- 401
			1.1, -- 401
			skinSh -- 401
		) -- 401
		draw:drawSegment( -- 402
			pt(handBase + 16, -2), -- 402
			pt(handBase + 52, -6), -- 402
			1.4 * s, -- 402
			skinSh -- 402
		) -- 402
		draw:drawSegment( -- 403
			pt(handBase + 14, 10), -- 403
			pt(handBase + 46, 8), -- 403
			1.4 * s, -- 403
			skinSh -- 403
		) -- 403
	elseif opts.pose == "pinch" then -- 403
		draw:drawPolygon( -- 406
			{ -- 406
				pt(handBase - 4, -22), -- 407
				pt(handBase + 44, -18), -- 408
				pt(handBase + 54, 6), -- 409
				pt(handBase + 28, 26), -- 410
				pt(handBase - 4, 22) -- 411
			}, -- 411
			skinCol, -- 412
			1.1, -- 412
			skinSh -- 412
		) -- 412
		draw:drawSegment( -- 413
			pt(handBase + 24, 16), -- 413
			pt(handBase + 52, 4), -- 413
			6.2 * s, -- 413
			skinHi -- 413
		) -- 413
		draw:drawSegment( -- 414
			pt(handBase + 30, -14), -- 414
			pt(handBase + 54, -4), -- 414
			5.6 * s, -- 414
			skinCol -- 414
		) -- 414
	elseif opts.pose == "clasp" then -- 414
		draw:drawPolygon( -- 417
			{ -- 417
				pt(handBase - 2, -22), -- 418
				pt(handBase + 52, -20), -- 419
				pt(handBase + 66, 2), -- 420
				pt(handBase + 44, 26), -- 421
				pt(handBase - 2, 22) -- 422
			}, -- 422
			skinCol, -- 423
			1.2, -- 423
			skinSh -- 423
		) -- 423
		draw:drawSegment( -- 424
			pt(handBase + 26, 20), -- 424
			pt(handBase + 58, 12), -- 424
			6.5 * s, -- 424
			skinHi -- 424
		) -- 424
		draw:drawSegment( -- 425
			pt(handBase + 46, -14), -- 425
			pt(handBase + 72, -10), -- 425
			5.2 * s, -- 425
			skinCol -- 425
		) -- 425
		draw:drawSegment( -- 426
			pt(handBase + 48, -2), -- 426
			pt(handBase + 76, 1), -- 426
			5.4 * s, -- 426
			skinCol -- 426
		) -- 426
	else -- 426
		local reachExt = opts.pose == "reach" and 10 or 0 -- 429
		draw:drawPolygon( -- 430
			{ -- 430
				pt(handBase - 4, -20), -- 431
				pt(handBase + 44 + reachExt, -18), -- 432
				pt(handBase + 56 + reachExt, 4), -- 433
				pt(handBase + 34 + reachExt * 0.5, 24), -- 434
				pt(handBase - 4, 20) -- 435
			}, -- 435
			skinCol, -- 436
			1.1, -- 436
			skinSh -- 436
		) -- 436
		draw:drawSegment( -- 438
			pt(handBase + 42 + reachExt, -14), -- 438
			pt(handBase + 74 + reachExt, -16), -- 438
			4.6 * s, -- 438
			skinCol -- 438
		) -- 438
		draw:drawSegment( -- 439
			pt(handBase + 46 + reachExt, -4), -- 439
			pt(handBase + 80 + reachExt, -3), -- 439
			4.8 * s, -- 439
			skinCol -- 439
		) -- 439
		draw:drawSegment( -- 440
			pt(handBase + 44 + reachExt, 6), -- 440
			pt(handBase + 76 + reachExt, 9), -- 440
			4.6 * s, -- 440
			skinCol -- 440
		) -- 440
		draw:drawSegment( -- 441
			pt(handBase + 26 + reachExt * 0.5, 18), -- 441
			pt(handBase + 56 + reachExt * 0.6, 28), -- 441
			5.2 * s, -- 441
			skinHi -- 441
		) -- 441
	end -- 441
end -- 243
--- 绘制小满伸出的小手（优先使用手绘 cutscene_cuff_rig.clip 幼童红袄手腕部件）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord, uiArt, instanceKey, layer) -- 446
	if withCompassCord == nil then -- 446
		withCompassCord = true -- 454
	end -- 454
	if instanceKey == nil then -- 454
		instanceKey = "cuff_child_hand" -- 456
	end -- 456
	if layer == nil then -- 456
		layer = 5 -- 457
	end -- 457
	local op = clamp01(opacity) -- 459
	if op <= 0.01 then -- 459
		return -- 461
	end -- 461
	local s = math.max(0.2, scale) -- 463
	if uiArt ~= nil then -- 463
		if pose == "two_fingers" then -- 463
			if uiArt:tryPlacePath( -- 463
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_peek", -- 467
				instanceKey .. "_peek", -- 468
				ox, -- 469
				oy, -- 470
				116 * s, -- 471
				134 * s, -- 472
				{ -- 473
					anchorX = 0.5, -- 474
					anchorY = 0.16, -- 475
					angle = 90, -- 476
					opacity = op, -- 477
					smooth = true, -- 478
					layer = layer -- 479
				} -- 479
			) then -- 479
				return -- 482
			end -- 482
		else -- 482
			local relDeg = -((angleRad - math.pi) * 180) / math.pi -- 485
			if uiArt:tryPlacePath( -- 485
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 487
				instanceKey .. "_reach", -- 488
				ox, -- 489
				oy, -- 490
				298 * s, -- 491
				132 * s, -- 492
				{ -- 493
					anchorX = 0.43, -- 494
					anchorY = 0.52, -- 495
					angle = relDeg, -- 496
					opacity = op, -- 497
					smooth = true, -- 498
					layer = layer -- 499
				} -- 499
			) then -- 499
				if withCompassCord then -- 499
					local cosA = math.cos(angleRad) -- 503
					local sinA = math.sin(angleRad) -- 504
					local p1 = rotPt( -- 505
						ox, -- 505
						oy, -- 505
						-12, -- 505
						-16, -- 505
						cosA, -- 505
						sinA, -- 505
						s -- 505
					) -- 505
					local p2 = rotPt( -- 506
						ox, -- 506
						oy, -- 506
						-6, -- 506
						16, -- 506
						cosA, -- 506
						sinA, -- 506
						s -- 506
					) -- 506
					draw:drawSegment( -- 507
						p1, -- 507
						p2, -- 507
						2.2 * s, -- 507
						toColor( -- 507
							____exports.CUFF_PALETTE.childCord, -- 507
							math.floor(165 * op + 0.5) -- 507
						) -- 507
					) -- 507
				end -- 507
				return -- 509
			end -- 509
		end -- 509
	end -- 509
	local cosA = math.cos(angleRad) -- 514
	local sinA = math.sin(angleRad) -- 515
	local function pt(lx, ly) -- 516
		return rotPt( -- 516
			ox, -- 516
			oy, -- 516
			lx, -- 516
			ly, -- 516
			cosA, -- 516
			sinA, -- 516
			s -- 516
		) -- 516
	end -- 516
	local skin = toColor( -- 517
		____exports.CUFF_PALETTE.childSkin, -- 517
		math.floor(255 * op + 0.5) -- 517
	) -- 517
	local sh = toColor( -- 518
		____exports.CUFF_PALETTE.childSkinShadow, -- 518
		math.floor(255 * op + 0.5) -- 518
	) -- 518
	local sleeve = toColor( -- 519
		____exports.CUFF_PALETTE.childSleeve, -- 519
		math.floor(255 * op + 0.5) -- 519
	) -- 519
	if pose == "two_fingers" then -- 519
		draw:drawSegment( -- 523
			pt(-18, -4), -- 523
			pt(18, -5), -- 523
			5 * s, -- 523
			skin -- 523
		) -- 523
		draw:drawSegment( -- 524
			pt(-16, 6), -- 524
			pt(22, 7), -- 524
			5 * s, -- 524
			skin -- 524
		) -- 524
		draw:drawDot( -- 525
			pt(18, -5), -- 525
			2.5 * s, -- 525
			sh -- 525
		) -- 525
		draw:drawDot( -- 526
			pt(22, 7), -- 526
			2.5 * s, -- 526
			sh -- 526
		) -- 526
		return -- 527
	end -- 527
	draw:drawPolygon( -- 531
		{ -- 531
			pt(-135, -24), -- 532
			pt(-6, -18), -- 533
			pt(-6, 18), -- 534
			pt(-135, 26) -- 535
		}, -- 535
		sleeve, -- 536
		1.1, -- 536
		sh -- 536
	) -- 536
	if withCompassCord then -- 536
		draw:drawSegment( -- 540
			pt(-10, -18), -- 540
			pt(-4, 18), -- 540
			2.6 * s, -- 540
			toColor( -- 540
				____exports.CUFF_PALETTE.childCord, -- 540
				math.floor(235 * op + 0.5) -- 540
			) -- 540
		) -- 540
		draw:drawSegment( -- 541
			pt(-4, -18), -- 541
			pt(2, 18), -- 541
			2.2 * s, -- 541
			toColor( -- 541
				____exports.CUFF_PALETTE.childCord, -- 541
				math.floor(200 * op + 0.5) -- 541
			) -- 541
		) -- 541
	end -- 541
	draw:drawPolygon( -- 545
		{ -- 545
			pt(-4, -15), -- 546
			pt(28, -14), -- 547
			pt(34, 2), -- 548
			pt(22, 17), -- 549
			pt(-4, 15) -- 550
		}, -- 550
		skin, -- 551
		1, -- 551
		sh -- 551
	) -- 551
	if pose == "clutch" or pose == "clasp" then -- 551
		draw:drawSegment( -- 555
			pt(24, -11), -- 555
			pt(44, -6), -- 555
			4 * s, -- 555
			skin -- 555
		) -- 555
		draw:drawSegment( -- 556
			pt(26, -2), -- 556
			pt(47, 2), -- 556
			4.2 * s, -- 556
			skin -- 556
		) -- 556
		draw:drawSegment( -- 557
			pt(24, 6), -- 557
			pt(43, 9), -- 557
			4 * s, -- 557
			skin -- 557
		) -- 557
		draw:drawSegment( -- 558
			pt(16, 14), -- 558
			pt(34, 16), -- 558
			4.2 * s, -- 558
			skin -- 558
		) -- 558
	else -- 558
		draw:drawSegment( -- 561
			pt(26, -12), -- 561
			pt(52, -16), -- 561
			3.6 * s, -- 561
			skin -- 561
		) -- 561
		draw:drawSegment( -- 562
			pt(29, -4), -- 562
			pt(57, -5), -- 562
			3.8 * s, -- 562
			skin -- 562
		) -- 562
		draw:drawSegment( -- 563
			pt(28, 4), -- 563
			pt(54, 7), -- 563
			3.6 * s, -- 563
			skin -- 563
		) -- 563
		draw:drawSegment( -- 564
			pt(24, 11), -- 564
			pt(46, 17), -- 564
			3.4 * s, -- 564
			skin -- 564
		) -- 564
		draw:drawSegment( -- 565
			pt(14, 15), -- 565
			pt(34, 26), -- 565
			4 * s, -- 565
			skin -- 565
		) -- 565
	end -- 565
end -- 446
--- 仅在 G05 重逢抬镜后绘制全幅冷月蹲姿周戍重逢插画（去生硬小弹窗框，自然融于全屏遮幅）
local function drawZhouShuReunionPortrait(draw, _inkDraw, art, glow, w, h, tiltOffsetY, alpha) -- 570
	local a = clamp01(alpha) -- 580
	if a <= 0.01 then -- 580
		return -- 582
	end -- 582
	local barH = math.floor(h * 0.068 + 0.5) -- 584
	local viewH = math.max(120, h - barH * 2) -- 585
	local scaleCover = math.max(w / 960, (viewH + 40) / 540) -- 586
	local imgW = 960 * scaleCover -- 587
	local imgH = 540 * scaleCover -- 588
	local cy = h * 0.5 - tiltOffsetY -- 589
	local placed = art:tryPlacePath( -- 591
		"assets/art/cg_g05_reunion.png", -- 592
		"g05_zhoushu_reunion_cg", -- 593
		w * 0.5, -- 594
		cy, -- 595
		imgW, -- 596
		imgH, -- 597
		{ -- 598
			anchorX = 0.5, -- 599
			anchorY = 0.5, -- 600
			opacity = a, -- 601
			smooth = true, -- 602
			layer = 1 -- 603
		} -- 603
	) -- 603
	if not placed then -- 603
		fillVGradRect( -- 607
			draw, -- 608
			0, -- 609
			barH, -- 610
			w, -- 611
			viewH, -- 612
			Color( -- 613
				10, -- 613
				15, -- 613
				24, -- 613
				math.floor(230 * a + 0.5) -- 613
			), -- 613
			Color( -- 614
				22, -- 614
				34, -- 614
				52, -- 614
				math.floor(238 * a + 0.5) -- 614
			) -- 614
		) -- 614
		art:tryPlace( -- 616
			"soldier_offer", -- 617
			"g05_zhoushu_closeup", -- 618
			w * 0.58, -- 619
			barH + 20, -- 620
			190, -- 621
			260, -- 622
			{opacity = a, layer = 2} -- 623
		) -- 623
	end -- 623
	fillVGradRect( -- 627
		draw, -- 627
		0, -- 627
		barH, -- 627
		w, -- 627
		72, -- 627
		Color( -- 627
			6, -- 627
			9, -- 627
			14, -- 627
			math.floor(145 * a + 0.5) -- 627
		), -- 627
		Color(6, 9, 14, 0) -- 627
	) -- 627
	fillVGradRect( -- 628
		draw, -- 628
		0, -- 628
		h - barH - 64, -- 628
		w, -- 628
		64, -- 628
		Color(6, 9, 14, 0), -- 628
		Color( -- 628
			6, -- 628
			9, -- 628
			14, -- 628
			math.floor(135 * a + 0.5) -- 628
		) -- 628
	) -- 628
	fillRadialGlow( -- 629
		glow, -- 629
		w * 0.54, -- 629
		h * 0.58, -- 629
		w * 0.34, -- 629
		h * 0.34, -- 629
		Color( -- 629
			196, -- 629
			214, -- 629
			232, -- 629
			math.floor(32 * a + 0.5) -- 629
		), -- 629
		Color(110, 142, 174, 0), -- 629
		16 -- 629
	) -- 629
end -- 570
____exports.CuffShotsPlugin = __TS__Class() -- 632
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 632
CuffShotsPlugin.name = "CuffShotsPlugin" -- 632
function CuffShotsPlugin.prototype.____constructor(self) -- 632
	self.id = "fe-01-cuff-shots" -- 633
	self.animTime = 0 -- 635
	self.prevPhase = "" -- 636
	self.activeShot = "" -- 637
	self.rehearsalShot = "" -- 640
	self.rehearsalTime = 0 -- 641
	self.rehearsalDuration = 3 -- 642
	self.rehearsalAutoAdvance = true -- 643
	self.p03Progress = 0 -- 646
	self.p05Progress = 0 -- 647
	self.p05ExitTimer = -1 -- 648
	self.g05SleeveExtend = 0 -- 649
	self.g05ReunionElapsed = 0 -- 650
	self.g05LineTriggered = false -- 651
	self.g05AbortVisualCount = 0 -- 652
	self.lastReleasedAbortCount = 0 -- 653
end -- 632
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 655
	self.animTime = 0 -- 656
	self.prevPhase = p.phase -- 657
	self.activeShot = "" -- 658
	self.p03Progress = 0 -- 659
	self.p05Progress = 0 -- 660
	self.p05ExitTimer = -1 -- 661
	self.g05SleeveExtend = 0 -- 662
	self.g05ReunionElapsed = 0 -- 663
	self.g05LineTriggered = false -- 664
	self.g05AbortVisualCount = 0 -- 665
	self.lastReleasedAbortCount = 0 -- 666
end -- 655
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 674
	self.rehearsalShot = shot -- 675
	if shot == "" then -- 675
		self.rehearsalTime = 0 -- 677
		self.rehearsalAutoAdvance = true -- 678
		return -- 679
	end -- 679
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 681
	if fixedTime ~= nil then -- 681
		self.rehearsalTime = math.max( -- 683
			0, -- 683
			math.min(self.rehearsalDuration, fixedTime) -- 683
		) -- 683
		self.rehearsalAutoAdvance = false -- 684
	else -- 684
		self.rehearsalTime = 0 -- 686
		self.rehearsalAutoAdvance = true -- 687
	end -- 687
end -- 674
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 691
	self:rehearseShot("") -- 692
end -- 691
function CuffShotsPlugin.prototype.getDebugState(self) -- 695
	return { -- 696
		activeShot = self.activeShot, -- 697
		rehearsalShot = self.rehearsalShot, -- 698
		rehearsalTime = self.rehearsalTime, -- 699
		rehearsalDuration = self.rehearsalDuration, -- 700
		p03Progress = self.p03Progress, -- 701
		p05ExitTimer = self.p05ExitTimer, -- 702
		g05SleeveExtend = self.g05SleeveExtend, -- 703
		g05ReunionElapsed = self.g05ReunionElapsed, -- 704
		g05LineTriggered = self.g05LineTriggered, -- 705
		g05AbortVisualCount = self.g05AbortVisualCount -- 706
	} -- 706
end -- 695
function CuffShotsPlugin.prototype.update(self, ctx) -- 710
	local p = ctx.p -- 711
	local view = ctx.view -- 712
	local dt = ctx.paused and 0 or ctx.worldDt -- 713
	self.animTime = self.animTime + dt -- 714
	if self.rehearsalShot ~= "" then -- 714
		self.activeShot = self.rehearsalShot -- 718
		if self.rehearsalAutoAdvance and dt > 0 then -- 718
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 720
		end -- 720
		if not ctx.paused then -- 720
			self:triggerRehearsalAudio(ctx) -- 723
		end -- 723
		self.prevPhase = p.phase -- 725
		return -- 726
	end -- 726
	self.activeShot = "" -- 729
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 729
		self.activeShot = "P03" -- 733
		self.p03Progress = clamp01(p.phaseTick / PROLOGUE_GIVE_TICKS) -- 734
		if not ctx.paused and self.p03Progress >= 0.18 then -- 734
			ctx.audio:playOnce( -- 736
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 737
				"sfx", -- 738
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 739
				0.86, -- 740
				"cuff:p03:cloth_wipe_wood", -- 741
				p.ticks -- 742
			) -- 742
		end -- 742
		if not ctx.paused and self.p03Progress >= 0.62 then -- 742
			ctx.audio:playOnce( -- 746
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 747
				"sfx", -- 748
				"assets/audio/interact/compass_handover.wav", -- 749
				0.82, -- 750
				"cuff:p03:compass_handover", -- 751
				p.ticks -- 752
			) -- 752
		end -- 752
		self.prevPhase = p.phase -- 755
		return -- 756
	else -- 756
		self.p03Progress = 0 -- 758
	end -- 758
	if p.room.key == "gate" and p.phase == "gate-farewell" then -- 758
		self.activeShot = "P05" -- 763
		self.p05Progress = clamp01(p.phaseTick / GATE_FAREWELL_TICKS) -- 764
		self.p05ExitTimer = p.phaseTick / 60 -- 765
		if not ctx.paused then -- 765
			if self.p05Progress >= 0.14 then -- 765
				ctx.audio:playOnce( -- 768
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 769
					"voice", -- 770
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 771
					0.88, -- 772
					"cuff:p05:line_farewell", -- 773
					p.ticks -- 774
				) -- 774
			end -- 774
			if self.p05Progress >= 0.7 then -- 774
				ctx.audio:playOnce( -- 778
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 779
					"sfx", -- 780
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 781
					0.92, -- 782
					"cuff:p05:gate_slam", -- 783
					p.ticks -- 784
				) -- 784
			end -- 784
		end -- 784
		self.prevPhase = p.phase -- 788
		return -- 789
	else -- 789
		self.p05Progress = 0 -- 791
		self.p05ExitTimer = -1 -- 792
	end -- 792
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 796
	if inGateReunion then -- 796
		self.activeShot = "G05" -- 804
		local gr = view.gateReunion -- 805
		local completed = p.phase == "gate-hand" or gr.completed -- 806
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 806
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 809
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 810
			if not ctx.paused and view.isRehearsal then -- 810
				ctx.audio:playOnce( -- 812
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 813
					"sfx", -- 814
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 815
					0.72, -- 816
					"cuff:g05:reunion_release", -- 817
					p.ticks -- 818
				) -- 818
			end -- 818
		end -- 818
		if completed then -- 818
			self.g05SleeveExtend = 1 -- 824
			if dt > 0 then -- 824
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 826
			end -- 826
			if not ctx.paused and not self.g05LineTriggered then -- 826
				if view.isRehearsal then -- 826
					ctx.audio:playOnce( -- 830
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 831
						"sfx", -- 832
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 833
						0.88, -- 834
						"cuff:g05:hand_held", -- 835
						p.ticks -- 836
					) -- 836
				end -- 836
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 836
					self.g05LineTriggered = true -- 840
					ctx.audio:playOnce( -- 841
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 842
						"voice", -- 843
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 844
						0.94, -- 845
						"cuff:g05:line_reunion", -- 846
						p.ticks -- 847
					) -- 847
				end -- 847
			end -- 847
		else -- 847
			self.g05ReunionElapsed = 0 -- 852
			self.g05LineTriggered = false -- 853
			if gr.holding or gr.holdProgress > 0.001 then -- 853
				if gr.holdProgress >= self.g05SleeveExtend then -- 853
					self.g05SleeveExtend = gr.holdProgress -- 857
				elseif dt > 0 then -- 857
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 859
				end -- 859
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 859
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 863
			end -- 863
		end -- 863
	else -- 863
		self.g05SleeveExtend = 0 -- 867
		self.g05ReunionElapsed = 0 -- 868
		self.g05LineTriggered = false -- 869
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 870
	end -- 870
	self.prevPhase = p.phase -- 873
end -- 710
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 876
	local sid = ctx.events.roomSessionId -- 877
	local t = self.rehearsalTime -- 878
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 878
		ctx.audio:playOnce( -- 880
			"reh:p03:wipe:" .. tostring(sid), -- 880
			"sfx", -- 880
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 880
			0.88, -- 880
			"cuff:p03:cloth_wipe_wood", -- 880
			ctx.p.ticks -- 880
		) -- 880
	elseif self.rehearsalShot == "P05" then -- 880
		if t >= 0.9 then -- 880
			ctx.audio:playOnce( -- 883
				"reh:p05:line:" .. tostring(sid), -- 883
				"voice", -- 883
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 883
				0.9, -- 883
				"cuff:p05:line_farewell", -- 883
				ctx.p.ticks -- 883
			) -- 883
		end -- 883
		if t >= 2.75 then -- 883
			ctx.audio:playOnce( -- 886
				"reh:p05:slam:" .. tostring(sid), -- 886
				"sfx", -- 886
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 886
				0.94, -- 886
				"cuff:p05:gate_slam", -- 886
				ctx.p.ticks -- 886
			) -- 886
			ctx.audio:playLoop( -- 887
				"reh_p05_water", -- 887
				"water", -- 887
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 887
				0.42, -- 887
				ctx.p.ticks -- 887
			) -- 887
		end -- 887
	elseif self.rehearsalShot == "G05" then -- 887
		if t >= 0.05 then -- 887
			ctx.audio:playOnce( -- 891
				"reh:g05:knock1:" .. tostring(sid), -- 891
				"sfx", -- 891
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 891
				0.88, -- 891
				"knock:gate:1", -- 891
				ctx.p.ticks -- 891
			) -- 891
		end -- 891
		if t >= 0.25 then -- 891
			ctx.audio:playOnce( -- 894
				"reh:g05:knock2:" .. tostring(sid), -- 894
				"sfx", -- 894
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 894
				0.92, -- 894
				"knock:gate:2", -- 894
				ctx.p.ticks -- 894
			) -- 894
		end -- 894
		if t >= 1.55 then -- 894
			ctx.audio:playOnce( -- 897
				"reh:g05:clasp:" .. tostring(sid), -- 897
				"sfx", -- 897
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 897
				0.88, -- 897
				"cuff:g05:hand_held", -- 897
				ctx.p.ticks -- 897
			) -- 897
		end -- 897
		if t >= 2.35 then -- 897
			ctx.audio:playOnce( -- 900
				"reh:g05:line:" .. tostring(sid), -- 900
				"voice", -- 900
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 900
				0.94, -- 900
				"cuff:g05:line_reunion", -- 900
				ctx.p.ticks -- 900
			) -- 900
		end -- 900
	end -- 900
end -- 876
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 905
	if self.activeShot == "" then -- 905
		return false -- 913
	end -- 913
	local w = ctx.uiW -- 915
	local h = ctx.uiH -- 916
	if self.activeShot == "P03" then -- 916
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 919
		self:renderP03Shot( -- 922
			uiDraw, -- 922
			uiInkDraw, -- 922
			uiArt, -- 922
			uiGlow, -- 922
			ctx, -- 922
			w, -- 922
			h, -- 922
			prog -- 922
		) -- 922
		return true -- 923
	end -- 923
	if self.activeShot == "P05" then -- 923
		local prog = self.rehearsalShot == "P05" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p05Progress -- 927
		self:renderP05FullShot( -- 930
			uiDraw, -- 930
			uiInkDraw, -- 930
			uiArt, -- 930
			uiGlow, -- 930
			ctx, -- 930
			w, -- 930
			h, -- 930
			prog -- 930
		) -- 930
		return true -- 931
	end -- 931
	if self.activeShot == "G05" then -- 931
		if self.rehearsalShot == "G05" then -- 931
			self:renderG05RehearsalShot( -- 936
				uiDraw, -- 936
				uiInkDraw, -- 936
				uiArt, -- 936
				uiGlow, -- 936
				ctx, -- 936
				w, -- 936
				h, -- 936
				self.rehearsalTime -- 936
			) -- 936
			return true -- 937
		end -- 937
		self:renderG05LiveShot( -- 939
			uiDraw, -- 939
			uiInkDraw, -- 939
			uiArt, -- 939
			uiGlow, -- 939
			ctx, -- 939
			w, -- 939
			h -- 939
		) -- 939
		return true -- 940
	end -- 940
	return false -- 943
end -- 905
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 952
	local fade = smoothstep(0, 0.03, prog) * (1 - smoothstep(0.96, 1, prog)) -- 962
	local barH = math.floor(h * 0.075 + 0.5) -- 963
	drawComicSequence( -- 965
		uiDraw, -- 966
		uiInkDraw, -- 967
		uiArt, -- 968
		P03_COMIC_SEQ, -- 969
		prog, -- 970
		w, -- 971
		h, -- 972
		{ -- 973
			letterboxH = barH, -- 974
			opacity = fade, -- 975
			layer = 2, -- 976
			instancePrefix = "p03_comic", -- 977
			accentBorder = true -- 978
		} -- 978
	) -- 978
	if self.rehearsalShot == "P03" then -- 978
		drawSilkVeil( -- 983
			uiDraw, -- 983
			uiArt, -- 983
			"p03_sub_veil", -- 983
			w * 0.5, -- 983
			42, -- 983
			520, -- 983
			42, -- 983
			PALETTE.inkWash, -- 983
			0.82 * fade, -- 983
			7 -- 983
		) -- 983
		local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 984
		ctx.texts:put( -- 987
			"sm", -- 987
			subText, -- 987
			w * 0.5, -- 987
			42, -- 987
			toColor(PALETTE.textBright), -- 987
			0.5, -- 987
			0.5, -- 987
			"Center", -- 987
			1, -- 987
			fade, -- 987
			0.08 -- 987
		) -- 987
	end -- 987
end -- 952
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 998
	local fade = smoothstep(0, 0.05, prog) * (1 - smoothstep(0.95, 1, prog)) -- 1008
	local barH = math.floor(h * 0.075 + 0.5) -- 1009
	drawComicSequence( -- 1011
		uiDraw, -- 1012
		uiInkDraw, -- 1013
		uiArt, -- 1014
		P05_COMIC_SEQ, -- 1015
		prog, -- 1016
		w, -- 1017
		h, -- 1018
		{ -- 1019
			letterboxH = barH, -- 1020
			opacity = fade, -- 1021
			layer = 2, -- 1022
			instancePrefix = "p05_comic", -- 1023
			accentBorder = true -- 1024
		} -- 1024
	) -- 1024
	local lineAlpha = fade * smoothstep(0.14, 0.26, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 1029
	if lineAlpha > 0.02 then -- 1029
		drawSilkVeil( -- 1031
			uiDraw, -- 1031
			uiArt, -- 1031
			"p05_sub_veil", -- 1031
			w * 0.5, -- 1031
			42, -- 1031
			740, -- 1031
			44, -- 1031
			PALETTE.inkWash, -- 1031
			0.86 * lineAlpha, -- 1031
			7 -- 1031
		) -- 1031
		drawHairline( -- 1032
			uiInkDraw, -- 1032
			uiArt, -- 1032
			"p05_sub_line", -- 1032
			w * 0.5, -- 1032
			62, -- 1032
			520, -- 1032
			PALETTE.silkDim, -- 1032
			0.52 * lineAlpha, -- 1032
			true, -- 1032
			8 -- 1032
		) -- 1032
		ctx.texts:put( -- 1033
			"sm", -- 1033
			LINE_P05, -- 1033
			w * 0.5, -- 1033
			42, -- 1033
			toColor(PALETTE.textBright), -- 1033
			0.5, -- 1033
			0.5, -- 1033
			"Center", -- 1033
			0.8, -- 1033
			lineAlpha, -- 1033
			0.08 -- 1033
		) -- 1033
	end -- 1033
end -- 998
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1038
	local enter = smoothstep(0, 0.12, t) -- 1048
	local out = smoothstep(0.66, 1, t) -- 1049
	local alpha = enter * (1 - out) -- 1050
	if alpha <= 0.02 then -- 1050
		return -- 1052
	end -- 1052
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 1054
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1055
		wristX = w * 0.27 - out * 260, -- 1056
		wristY = h * 0.4, -- 1057
		angleRad = -0.05, -- 1058
		scale = 1.04, -- 1059
		pose = pinchT > 0.25 and "pinch" or "open", -- 1060
		opacity = alpha * 0.95, -- 1061
		stitchHighlight = 0.45 + 0.28 * pinchT, -- 1062
		uiArt = uiArt, -- 1063
		instanceKey = "p05_live_zhou_cuff", -- 1064
		layer = 4 -- 1065
	}) -- 1065
	drawChildHand( -- 1067
		uiDraw, -- 1068
		w * 0.39 + out * 30, -- 1069
		h * 0.37 - out * 10, -- 1070
		math.pi + 0.1, -- 1071
		1.02, -- 1072
		out > 0.32 and "open_fingers" or "clutch", -- 1073
		alpha * 0.94, -- 1074
		true, -- 1075
		uiArt, -- 1076
		"p05_live_child_hand", -- 1077
		5 -- 1078
	) -- 1078
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 1080
	if lineAlpha > 0.02 then -- 1080
		local subY = 92 -- 1082
		drawSilkVeil( -- 1083
			uiDraw, -- 1083
			uiArt, -- 1083
			"p05_live_veil", -- 1083
			w * 0.5, -- 1083
			subY, -- 1083
			760, -- 1083
			44, -- 1083
			PALETTE.inkWash, -- 1083
			0.86 * lineAlpha, -- 1083
			7 -- 1083
		) -- 1083
		drawHairline( -- 1084
			uiInkDraw, -- 1084
			uiArt, -- 1084
			"p05_live_line", -- 1084
			w * 0.5, -- 1084
			subY + 20, -- 1084
			520, -- 1084
			PALETTE.silkDim, -- 1084
			0.52 * lineAlpha, -- 1084
			true, -- 1084
			8 -- 1084
		) -- 1084
		ctx.texts:put( -- 1085
			"sm", -- 1085
			LINE_P05, -- 1085
			w * 0.5, -- 1085
			subY, -- 1085
			toColor(PALETTE.textBright), -- 1085
			0.5, -- 1085
			0.5, -- 1085
			"Center", -- 1085
			0.8, -- 1085
			lineAlpha, -- 1085
			0.08 -- 1085
		) -- 1085
	end -- 1085
end -- 1038
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1094
	local view = ctx.view -- 1103
	local gr = view.gateReunion -- 1104
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1105
	local ext = clamp01(self.g05SleeveExtend) -- 1106
	if not completed then -- 1106
		if ext > 0.008 then -- 1106
			local comicOp = smoothstep(0.01, 0.16, ext) -- 1110
			drawComicSequence( -- 1111
				uiDraw, -- 1112
				uiInkDraw, -- 1113
				uiArt, -- 1114
				G05_HOLD_COMIC_SEQ, -- 1115
				ext, -- 1116
				w, -- 1117
				h, -- 1118
				{ -- 1119
					letterboxH = math.floor(h * 0.068 + 0.5), -- 1120
					opacity = comicOp, -- 1121
					layer = 2, -- 1122
					instancePrefix = "g05_hold_comic", -- 1123
					accentBorder = true -- 1124
				} -- 1124
			) -- 1124
			local barW = 240 -- 1129
			local bx0 = w * 0.5 - barW * 0.5 -- 1130
			local by0 = 18 -- 1131
			uiInkDraw:drawSegment( -- 1132
				Vec2(bx0, by0), -- 1132
				Vec2(bx0 + barW, by0), -- 1132
				1.2, -- 1132
				toColor(PALETTE.silkDim, 110) -- 1132
			) -- 1132
			uiInkDraw:drawSegment( -- 1133
				Vec2(bx0, by0), -- 1133
				Vec2(bx0 + barW * ext, by0), -- 1133
				2.4, -- 1133
				toColor(PALETTE.amberCore, 230) -- 1133
			) -- 1133
		else -- 1133
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1135
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1136
				wristX = -120 + peekPulse * 18, -- 1137
				wristY = h * 0.44, -- 1138
				angleRad = -0.04, -- 1139
				scale = 1.16, -- 1140
				pose = "open", -- 1141
				opacity = 0.42 + 0.24 * peekPulse, -- 1142
				stitchHighlight = 0.35 * peekPulse, -- 1143
				uiArt = uiArt, -- 1144
				instanceKey = "g05_live_zhou_cuff", -- 1145
				layer = 4 -- 1146
			}) -- 1146
		end -- 1146
		if view.assistHintsEnabled then -- 1146
			drawSilkVeil( -- 1151
				uiDraw, -- 1151
				uiArt, -- 1151
				"g05_assist_veil", -- 1151
				w * 0.5, -- 1151
				h - 26, -- 1151
				280, -- 1151
				28, -- 1151
				PALETTE.inkWash, -- 1151
				0.72, -- 1151
				7 -- 1151
			) -- 1151
			ctx.texts:put( -- 1152
				"xs", -- 1153
				getActiveTarget():adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1154
				w * 0.5, -- 1155
				h - 26, -- 1156
				toColor(PALETTE.amberCore), -- 1157
				0.5, -- 1158
				0.5, -- 1159
				"Center", -- 1160
				1.2, -- 1161
				0.9, -- 1162
				0.08 -- 1163
			) -- 1163
		end -- 1163
		return -- 1166
	end -- 1166
	local t = self.g05ReunionElapsed -- 1170
	local barH = math.floor(h * 0.068 + 0.5) -- 1171
	drawComicSequence( -- 1172
		uiDraw, -- 1173
		uiInkDraw, -- 1174
		uiArt, -- 1175
		G05_REUNION_COMIC_SEQ, -- 1176
		t, -- 1177
		w, -- 1178
		h, -- 1179
		{ -- 1180
			letterboxH = barH, -- 1181
			opacity = 1, -- 1182
			layer = 2, -- 1183
			instancePrefix = "g05_reunion_comic", -- 1184
			accentBorder = true -- 1185
		} -- 1185
	) -- 1185
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1190
	if lineAlpha > 0.02 then -- 1190
		drawSilkVeil( -- 1192
			uiDraw, -- 1192
			uiArt, -- 1192
			"g05_line_veil", -- 1192
			w * 0.5, -- 1192
			42, -- 1192
			420, -- 1192
			44, -- 1192
			PALETTE.inkWash, -- 1192
			0.86 * lineAlpha, -- 1192
			7 -- 1192
		) -- 1192
		drawHairline( -- 1193
			uiInkDraw, -- 1193
			uiArt, -- 1193
			"g05_line_bar", -- 1193
			w * 0.5, -- 1193
			62, -- 1193
			260, -- 1193
			PALETTE.amber, -- 1193
			0.58 * lineAlpha, -- 1193
			true, -- 1193
			8 -- 1193
		) -- 1193
		ctx.texts:put( -- 1194
			"sm", -- 1194
			LINE_G05, -- 1194
			w * 0.5, -- 1194
			42, -- 1194
			toColor(PALETTE.textBright), -- 1194
			0.5, -- 1194
			0.5, -- 1194
			"Center", -- 1194
			2.2, -- 1194
			lineAlpha, -- 1194
			0.08 -- 1194
		) -- 1194
	end -- 1194
end -- 1094
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, t) -- 1199
	local barH = math.floor(h * 0.072 + 0.5) -- 1209
	drawComicSequence( -- 1210
		uiDraw, -- 1211
		uiInkDraw, -- 1212
		uiArt, -- 1213
		G05_REHEARSAL_COMIC_SEQ, -- 1214
		t, -- 1215
		w, -- 1216
		h, -- 1217
		{ -- 1218
			letterboxH = barH, -- 1219
			opacity = 1, -- 1220
			layer = 2, -- 1221
			instancePrefix = "g05_reh_comic", -- 1222
			accentBorder = true -- 1223
		} -- 1223
	) -- 1223
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1227
	if lineAlpha > 0.02 then -- 1227
		drawSilkVeil( -- 1229
			uiDraw, -- 1229
			uiArt, -- 1229
			"g05_reh_veil", -- 1229
			w * 0.5, -- 1229
			42, -- 1229
			420, -- 1229
			44, -- 1229
			PALETTE.inkWash, -- 1229
			0.86 * lineAlpha, -- 1229
			7 -- 1229
		) -- 1229
		drawHairline( -- 1230
			uiInkDraw, -- 1230
			uiArt, -- 1230
			"g05_reh_bar", -- 1230
			w * 0.5, -- 1230
			62, -- 1230
			260, -- 1230
			PALETTE.amber, -- 1230
			0.58 * lineAlpha, -- 1230
			true, -- 1230
			8 -- 1230
		) -- 1230
		ctx.texts:put( -- 1231
			"sm", -- 1231
			LINE_G05, -- 1231
			w * 0.5, -- 1231
			42, -- 1231
			toColor(PALETTE.textBright), -- 1231
			0.5, -- 1231
			0.5, -- 1231
			"Center", -- 1231
			2.2, -- 1231
			lineAlpha, -- 1231
			0.08 -- 1231
		) -- 1231
	end -- 1231
end -- 1199
function ____exports.createCuffShotsPlugin() -- 1236
	return __TS__New(____exports.CuffShotsPlugin) -- 1237
end -- 1236
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1244
	local gateTransition = createGateTransitionPlugin() -- 1248
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1249
	fe:registerPlugin(gateTransition) -- 1250
	fe:registerPlugin(cuffShots) -- 1251
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1252
end -- 1244
return ____exports -- 1244