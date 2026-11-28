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
--- P05 城门送别硬核木刻漫画逐帧拍表（归一化进度 0..1，含 0.72 落门单帧三色木刻冲击）
local P05_COMIC_SEQ = { -- 129
	{ -- 130
		slot = "comic_p05_01_clutch_cuff", -- 130
		start = 0, -- 130
		["end"] = 0.2, -- 130
		zoomFrom = 1, -- 130
		zoomTo = 1.01, -- 130
		transition = "cut" -- 130
	}, -- 130
	{ -- 131
		slot = "comic_p05_02_brother_pinch", -- 131
		start = 0.2, -- 131
		["end"] = 0.44, -- 131
		zoomFrom = 1.005, -- 131
		zoomTo = 1.015, -- 131
		transition = "cut" -- 131
	}, -- 131
	{ -- 132
		slot = "comic_p05_03_sleeve_pull", -- 132
		start = 0.44, -- 132
		["end"] = 0.64, -- 132
		zoomFrom = 1.008, -- 132
		zoomTo = 1.02, -- 132
		transition = "cut" -- 132
	}, -- 132
	{ -- 133
		slot = "comic_p05_04_gate_drop", -- 133
		start = 0.64, -- 133
		["end"] = 0.72, -- 133
		zoomFrom = 1.015, -- 133
		zoomTo = 1.028, -- 133
		transition = "cut", -- 133
		shakeAmp = 4, -- 133
		shakeFreq = 62 -- 133
	}, -- 133
	{ -- 134
		slot = "comic_p05_05_gate_slam_impact", -- 134
		start = 0.72, -- 134
		["end"] = 0.79, -- 134
		zoomFrom = 1.036, -- 134
		zoomTo = 1.036, -- 134
		transition = "cut", -- 134
		impactFlash = true, -- 134
		impactDur = 0.07, -- 134
		shakeAmp = 12, -- 134
		shakeFreq = 74 -- 134
	}, -- 134
	{ -- 135
		slot = "comic_p05_06_open_fingers", -- 135
		start = 0.79, -- 135
		["end"] = 1, -- 135
		zoomFrom = 1.012, -- 135
		zoomTo = 1, -- 135
		transition = "cut", -- 135
		shakeAmp = 2.2 -- 135
	} -- 135
} -- 135
--- G05 长按伸袖交互拍表（严格跟随 holdProgress 0..1）
local G05_HOLD_COMIC_SEQ = {{ -- 139
	slot = "comic_g05_01_cuff_peek", -- 140
	start = 0, -- 140
	["end"] = 0.3, -- 140
	zoomFrom = 1, -- 140
	zoomTo = 1.01, -- 140
	transition = "cut" -- 140
}, { -- 140
	slot = "comic_g05_02_cuff_extend", -- 141
	start = 0.3, -- 141
	["end"] = 0.7, -- 141
	zoomFrom = 1.005, -- 141
	zoomTo = 1.015, -- 141
	transition = "cut" -- 141
}, { -- 141
	slot = "comic_g05_03_hands_meet", -- 142
	start = 0.7, -- 142
	["end"] = 1, -- 142
	zoomFrom = 1.01, -- 142
	zoomTo = 1.02, -- 142
	transition = "cut" -- 142
}} -- 142
--- G05 握稳重逢顺臂抬镜至周戍露脸拍表（秒）
local G05_REUNION_COMIC_SEQ = { -- 146
	{ -- 147
		slot = "comic_g05_04_hands_clasp", -- 147
		start = 0, -- 147
		["end"] = 0.38, -- 147
		zoomFrom = 1, -- 147
		zoomTo = 1.012, -- 147
		transition = "cut" -- 147
	}, -- 147
	{ -- 148
		slot = "comic_g05_05_tilt_arm", -- 148
		start = 0.38, -- 148
		["end"] = 0.78, -- 148
		zoomFrom = 1.005, -- 148
		zoomTo = 1.015, -- 148
		transition = "cut" -- 148
	}, -- 148
	{ -- 149
		slot = "comic_g05_06_tilt_shoulder", -- 149
		start = 0.78, -- 149
		["end"] = 1.18, -- 149
		zoomFrom = 1.005, -- 149
		zoomTo = 1.015, -- 149
		transition = "cut" -- 149
	}, -- 149
	{ -- 150
		slot = "comic_g05_07_zhoushu_reveal", -- 150
		start = 1.18, -- 150
		["end"] = 1.72, -- 150
		zoomFrom = 1, -- 150
		zoomTo = 1.012, -- 150
		transition = "cut" -- 150
	}, -- 150
	{ -- 151
		slot = "comic_g05_08_zhoushu_warm", -- 151
		start = 1.72, -- 151
		["end"] = 12, -- 151
		zoomFrom = 1.008, -- 151
		zoomTo = 1, -- 151
		transition = "cut" -- 151
	} -- 151
} -- 151
--- G05 4 秒独立排演全 8 帧连续拍表
local G05_REHEARSAL_COMIC_SEQ = { -- 155
	{ -- 156
		slot = "comic_g05_01_cuff_peek", -- 156
		start = 0, -- 156
		["end"] = 0.5, -- 156
		zoomFrom = 1, -- 156
		zoomTo = 1.01, -- 156
		transition = "cut" -- 156
	}, -- 156
	{ -- 157
		slot = "comic_g05_02_cuff_extend", -- 157
		start = 0.5, -- 157
		["end"] = 1, -- 157
		zoomFrom = 1, -- 157
		zoomTo = 1.01, -- 157
		transition = "cut" -- 157
	}, -- 157
	{ -- 158
		slot = "comic_g05_03_hands_meet", -- 158
		start = 1, -- 158
		["end"] = 1.45, -- 158
		zoomFrom = 1.005, -- 158
		zoomTo = 1.015, -- 158
		transition = "cut" -- 158
	}, -- 158
	{ -- 159
		slot = "comic_g05_04_hands_clasp", -- 159
		start = 1.45, -- 159
		["end"] = 1.88, -- 159
		zoomFrom = 1.005, -- 159
		zoomTo = 1.012, -- 159
		transition = "cut" -- 159
	}, -- 159
	{ -- 160
		slot = "comic_g05_05_tilt_arm", -- 160
		start = 1.88, -- 160
		["end"] = 2.3, -- 160
		zoomFrom = 1.005, -- 160
		zoomTo = 1.012, -- 160
		transition = "cut" -- 160
	}, -- 160
	{ -- 161
		slot = "comic_g05_06_tilt_shoulder", -- 161
		start = 2.3, -- 161
		["end"] = 2.72, -- 161
		zoomFrom = 1.005, -- 161
		zoomTo = 1.012, -- 161
		transition = "cut" -- 161
	}, -- 161
	{ -- 162
		slot = "comic_g05_07_zhoushu_reveal", -- 162
		start = 2.72, -- 162
		["end"] = 3.3, -- 162
		zoomFrom = 1, -- 162
		zoomTo = 1.01, -- 162
		transition = "cut" -- 162
	}, -- 162
	{ -- 163
		slot = "comic_g05_08_zhoushu_warm", -- 163
		start = 3.3, -- 163
		["end"] = 4.5, -- 163
		zoomFrom = 1.006, -- 163
		zoomTo = 1, -- 163
		transition = "cut" -- 163
	} -- 163
} -- 163
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 167
	indigoBase = rgba(34, 52, 74, 255), -- 168
	indigoShadow = rgba(18, 28, 42, 255), -- 169
	indigoFold = rgba(54, 78, 104, 255), -- 170
	patchDark = rgba(24, 38, 56, 255), -- 171
	hemEdge = rgba(68, 92, 118, 255), -- 172
	armWrapLinen = rgba(154, 142, 120, 255), -- 173
	armWrapShadow = rgba(102, 92, 78, 255), -- 174
	stitchThread = rgba(232, 224, 204, 255), -- 176
	stitchPinhole = rgba(14, 19, 28, 255), -- 177
	skinBase = rgba(188, 146, 116, 255), -- 178
	skinShadow = rgba(138, 102, 78, 255), -- 179
	skinLight = rgba(216, 178, 148, 255), -- 180
	childSkin = rgba(226, 196, 170, 255), -- 181
	childSkinShadow = rgba(176, 144, 120, 255), -- 182
	childSleeve = rgba(164, 142, 114, 255), -- 183
	childCord = rgba(168, 56, 52, 255) -- 184
} -- 184
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 187
	local sx = lx * scale -- 188
	local sy = ly * scale -- 189
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 190
end -- 187
local function tinted(base, warmth, opacity) -- 193
	local warmTarget = rgba( -- 194
		math.min(255, base.r + 22), -- 195
		math.min(255, base.g + 12), -- 196
		math.max(0, base.b - 10), -- 197
		base.a -- 198
	) -- 198
	local mixed = lerpRGBA( -- 200
		base, -- 200
		warmTarget, -- 200
		clamp01(warmth) -- 200
	) -- 200
	return toColor( -- 201
		mixed, -- 201
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 201
	) -- 201
end -- 193
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 208
	local op = clamp01(opts.opacity or 1) -- 213
	if op <= 0.01 then -- 213
		return -- 215
	end -- 215
	local ox = opts.wristX -- 217
	local oy = opts.wristY -- 218
	local s = math.max(0.2, opts.scale) -- 219
	local cosA = math.cos(opts.angleRad) -- 220
	local sinA = math.sin(opts.angleRad) -- 221
	local w = clamp01(opts.warmth or 0) -- 222
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 223
	local function pt(lx, ly) -- 224
		return rotPt( -- 224
			ox, -- 224
			oy, -- 224
			lx, -- 224
			ly, -- 224
			cosA, -- 224
			sinA, -- 224
			s -- 224
		) -- 224
	end -- 224
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 225
	if opts.uiArt ~= nil then -- 225
		local framePath = (opts.pose == "clasp" or opts.pose == "pinch") and "assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp" or "assets/art/cutscene_cuff_rig.clip|cuff_zhou_open" -- 229
		local key = opts.instanceKey or "patched_cuff_zhou" -- 232
		local spriteW = 368 * s -- 233
		local spriteH = 166 * s -- 234
		local anchorOffset = pull * 0.55 -- 235
		local placedPos = pt(-anchorOffset, 0) -- 236
		local tintCol = tinted( -- 237
			rgba(232, 238, 246, 255), -- 237
			w * 0.72, -- 237
			1 -- 237
		) -- 237
		if opts.uiArt:tryPlacePath( -- 237
			framePath, -- 238
			key, -- 238
			placedPos.x, -- 238
			placedPos.y, -- 238
			spriteW, -- 238
			spriteH, -- 238
			{ -- 238
				anchorX = 0.57, -- 239
				anchorY = 0.5, -- 240
				angle = -(opts.angleRad * 180) / math.pi, -- 241
				color = tintCol, -- 242
				opacity = op, -- 243
				smooth = true, -- 244
				layer = opts.layer or 4 -- 245
			} -- 245
		) then -- 245
			if hl > 0.08 then -- 245
				local stitchPos = pt(-58 - anchorOffset, -6) -- 248
				fillRadialGlow( -- 249
					glow, -- 250
					stitchPos.x, -- 251
					stitchPos.y, -- 252
					36 * s, -- 253
					22 * s, -- 254
					toColor( -- 255
						____exports.CUFF_PALETTE.stitchThread, -- 255
						math.floor(52 * hl * op + 0.5) -- 255
					), -- 255
					toColor(____exports.CUFF_PALETTE.stitchThread, 0), -- 256
					12 -- 257
				) -- 257
			end -- 257
			return -- 260
		end -- 260
	end -- 260
	local cuffFront = 6 - pull -- 265
	draw:drawPolygon( -- 266
		{ -- 266
			pt(-250, -48), -- 267
			pt(cuffFront, -36), -- 268
			pt(cuffFront, 38), -- 269
			pt(-250, 52) -- 270
		}, -- 270
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 271
		1.4, -- 271
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 271
	) -- 271
	draw:drawPolygon( -- 274
		{ -- 274
			pt(-250, -48), -- 275
			pt(cuffFront, -36), -- 276
			pt(cuffFront, -8), -- 277
			pt(-250, -14) -- 278
		}, -- 278
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 279
	) -- 279
	draw:drawPolygon( -- 282
		{ -- 282
			pt(-230, 14), -- 283
			pt(cuffFront - 6, 10), -- 284
			pt(cuffFront - 4, 32), -- 285
			pt(-230, 40) -- 286
		}, -- 286
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 287
	) -- 287
	draw:drawSegment( -- 288
		pt(-185, 16), -- 288
		pt(cuffFront - 18, 12), -- 288
		1.2 * s, -- 288
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 288
	) -- 288
	draw:drawSegment( -- 289
		pt(-160, -10), -- 289
		pt(cuffFront - 26, -6), -- 289
		1.1 * s, -- 289
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 289
	) -- 289
	draw:drawPolygon( -- 292
		{ -- 292
			pt(cuffFront - 8, -28), -- 293
			pt(cuffFront + 16, -24), -- 294
			pt(cuffFront + 16, 26), -- 295
			pt(cuffFront - 8, 28) -- 296
		}, -- 296
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 297
		1, -- 297
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 297
	) -- 297
	draw:drawSegment( -- 298
		pt(cuffFront + 3, -25), -- 298
		pt(cuffFront + 7, 25), -- 298
		1.3 * s, -- 298
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 298
	) -- 298
	draw:drawPolygon( -- 301
		{ -- 301
			pt(cuffFront - 16, -37), -- 302
			pt(cuffFront + 2, -36), -- 303
			pt(cuffFront + 2, 38), -- 304
			pt(cuffFront - 16, 39) -- 305
		}, -- 305
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 306
		1.3, -- 306
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 306
	) -- 306
	local pX0 = cuffFront - 72 -- 309
	local pX1 = cuffFront - 18 -- 310
	local pY0 = -16 -- 311
	local pY1 = 22 -- 312
	draw:drawPolygon( -- 313
		{ -- 313
			pt(pX0, pY0), -- 314
			pt(pX1, pY0 + 3), -- 315
			pt(pX1 - 2, pY1), -- 316
			pt(pX0 + 3, pY1 - 2) -- 317
		}, -- 317
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 318
		1.1, -- 318
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 318
	) -- 318
	local seamStartX = pX0 + 6 -- 321
	local seamStartY = pY0 + 5 -- 322
	local seamEndX = pX1 - 7 -- 323
	local seamEndY = pY1 - 5 -- 324
	draw:drawSegment( -- 325
		pt(seamStartX, seamStartY), -- 326
		pt(seamEndX, seamEndY), -- 327
		1.5 * s, -- 328
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 329
	) -- 329
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 332
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 333
	local stitches = 6 -- 334
	local k = 0 -- 335
	do -- 335
		k = 0 -- 336
		while k < stitches do -- 336
			local t = (k + 0.5) / stitches -- 337
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 338
			local my = seamStartY + (seamEndY - seamStartY) * t -- 339
			local nx = -4.8 -- 340
			local ny = 6.2 -- 341
			local a = pt(mx - nx, my - ny) -- 342
			local b = pt(mx + nx, my + ny) -- 343
			draw:drawDot(a, 1.3 * s, pinCol) -- 344
			draw:drawDot(b, 1.3 * s, pinCol) -- 345
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 346
			if hl > 0.05 then -- 346
				glow:drawSegment( -- 348
					a, -- 348
					b, -- 348
					2.4 * s, -- 348
					toColor( -- 348
						____exports.CUFF_PALETTE.stitchThread, -- 348
						math.floor(74 * hl * op + 0.5) -- 348
					) -- 348
				) -- 348
			end -- 348
			k = k + 1 -- 336
		end -- 336
	end -- 336
	local handBase = cuffFront + 14 -- 353
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 354
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 355
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 356
	if opts.pose == "wipe" then -- 356
		draw:drawPolygon( -- 360
			{ -- 360
				pt(handBase - 4, -20), -- 361
				pt(handBase + 46, -24), -- 362
				pt(handBase + 54, 4), -- 363
				pt(handBase + 38, 22), -- 364
				pt(handBase - 4, 20) -- 365
			}, -- 365
			skinCol, -- 366
			1.1, -- 366
			skinSh -- 366
		) -- 366
		draw:drawSegment( -- 367
			pt(handBase + 16, -2), -- 367
			pt(handBase + 52, -6), -- 367
			1.4 * s, -- 367
			skinSh -- 367
		) -- 367
		draw:drawSegment( -- 368
			pt(handBase + 14, 10), -- 368
			pt(handBase + 46, 8), -- 368
			1.4 * s, -- 368
			skinSh -- 368
		) -- 368
	elseif opts.pose == "pinch" then -- 368
		draw:drawPolygon( -- 371
			{ -- 371
				pt(handBase - 4, -22), -- 372
				pt(handBase + 44, -18), -- 373
				pt(handBase + 54, 6), -- 374
				pt(handBase + 28, 26), -- 375
				pt(handBase - 4, 22) -- 376
			}, -- 376
			skinCol, -- 377
			1.1, -- 377
			skinSh -- 377
		) -- 377
		draw:drawSegment( -- 378
			pt(handBase + 24, 16), -- 378
			pt(handBase + 52, 4), -- 378
			6.2 * s, -- 378
			skinHi -- 378
		) -- 378
		draw:drawSegment( -- 379
			pt(handBase + 30, -14), -- 379
			pt(handBase + 54, -4), -- 379
			5.6 * s, -- 379
			skinCol -- 379
		) -- 379
	elseif opts.pose == "clasp" then -- 379
		draw:drawPolygon( -- 382
			{ -- 382
				pt(handBase - 2, -22), -- 383
				pt(handBase + 52, -20), -- 384
				pt(handBase + 66, 2), -- 385
				pt(handBase + 44, 26), -- 386
				pt(handBase - 2, 22) -- 387
			}, -- 387
			skinCol, -- 388
			1.2, -- 388
			skinSh -- 388
		) -- 388
		draw:drawSegment( -- 389
			pt(handBase + 26, 20), -- 389
			pt(handBase + 58, 12), -- 389
			6.5 * s, -- 389
			skinHi -- 389
		) -- 389
		draw:drawSegment( -- 390
			pt(handBase + 46, -14), -- 390
			pt(handBase + 72, -10), -- 390
			5.2 * s, -- 390
			skinCol -- 390
		) -- 390
		draw:drawSegment( -- 391
			pt(handBase + 48, -2), -- 391
			pt(handBase + 76, 1), -- 391
			5.4 * s, -- 391
			skinCol -- 391
		) -- 391
	else -- 391
		local reachExt = opts.pose == "reach" and 10 or 0 -- 394
		draw:drawPolygon( -- 395
			{ -- 395
				pt(handBase - 4, -20), -- 396
				pt(handBase + 44 + reachExt, -18), -- 397
				pt(handBase + 56 + reachExt, 4), -- 398
				pt(handBase + 34 + reachExt * 0.5, 24), -- 399
				pt(handBase - 4, 20) -- 400
			}, -- 400
			skinCol, -- 401
			1.1, -- 401
			skinSh -- 401
		) -- 401
		draw:drawSegment( -- 403
			pt(handBase + 42 + reachExt, -14), -- 403
			pt(handBase + 74 + reachExt, -16), -- 403
			4.6 * s, -- 403
			skinCol -- 403
		) -- 403
		draw:drawSegment( -- 404
			pt(handBase + 46 + reachExt, -4), -- 404
			pt(handBase + 80 + reachExt, -3), -- 404
			4.8 * s, -- 404
			skinCol -- 404
		) -- 404
		draw:drawSegment( -- 405
			pt(handBase + 44 + reachExt, 6), -- 405
			pt(handBase + 76 + reachExt, 9), -- 405
			4.6 * s, -- 405
			skinCol -- 405
		) -- 405
		draw:drawSegment( -- 406
			pt(handBase + 26 + reachExt * 0.5, 18), -- 406
			pt(handBase + 56 + reachExt * 0.6, 28), -- 406
			5.2 * s, -- 406
			skinHi -- 406
		) -- 406
	end -- 406
end -- 208
--- 绘制小满伸出的小手（优先使用手绘 cutscene_cuff_rig.clip 幼童红袄手腕部件）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord, uiArt, instanceKey, layer) -- 411
	if withCompassCord == nil then -- 411
		withCompassCord = true -- 419
	end -- 419
	if instanceKey == nil then -- 419
		instanceKey = "cuff_child_hand" -- 421
	end -- 421
	if layer == nil then -- 421
		layer = 5 -- 422
	end -- 422
	local op = clamp01(opacity) -- 424
	if op <= 0.01 then -- 424
		return -- 426
	end -- 426
	local s = math.max(0.2, scale) -- 428
	if uiArt ~= nil then -- 428
		if pose == "two_fingers" then -- 428
			if uiArt:tryPlacePath( -- 428
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_peek", -- 432
				instanceKey .. "_peek", -- 433
				ox, -- 434
				oy, -- 435
				116 * s, -- 436
				134 * s, -- 437
				{ -- 438
					anchorX = 0.5, -- 439
					anchorY = 0.16, -- 440
					angle = 90, -- 441
					opacity = op, -- 442
					smooth = true, -- 443
					layer = layer -- 444
				} -- 444
			) then -- 444
				return -- 447
			end -- 447
		else -- 447
			local relDeg = -((angleRad - math.pi) * 180) / math.pi -- 450
			if uiArt:tryPlacePath( -- 450
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 452
				instanceKey .. "_reach", -- 453
				ox, -- 454
				oy, -- 455
				298 * s, -- 456
				132 * s, -- 457
				{ -- 458
					anchorX = 0.43, -- 459
					anchorY = 0.52, -- 460
					angle = relDeg, -- 461
					opacity = op, -- 462
					smooth = true, -- 463
					layer = layer -- 464
				} -- 464
			) then -- 464
				if withCompassCord then -- 464
					local cosA = math.cos(angleRad) -- 468
					local sinA = math.sin(angleRad) -- 469
					local p1 = rotPt( -- 470
						ox, -- 470
						oy, -- 470
						-12, -- 470
						-16, -- 470
						cosA, -- 470
						sinA, -- 470
						s -- 470
					) -- 470
					local p2 = rotPt( -- 471
						ox, -- 471
						oy, -- 471
						-6, -- 471
						16, -- 471
						cosA, -- 471
						sinA, -- 471
						s -- 471
					) -- 471
					draw:drawSegment( -- 472
						p1, -- 472
						p2, -- 472
						2.2 * s, -- 472
						toColor( -- 472
							____exports.CUFF_PALETTE.childCord, -- 472
							math.floor(165 * op + 0.5) -- 472
						) -- 472
					) -- 472
				end -- 472
				return -- 474
			end -- 474
		end -- 474
	end -- 474
	local cosA = math.cos(angleRad) -- 479
	local sinA = math.sin(angleRad) -- 480
	local function pt(lx, ly) -- 481
		return rotPt( -- 481
			ox, -- 481
			oy, -- 481
			lx, -- 481
			ly, -- 481
			cosA, -- 481
			sinA, -- 481
			s -- 481
		) -- 481
	end -- 481
	local skin = toColor( -- 482
		____exports.CUFF_PALETTE.childSkin, -- 482
		math.floor(255 * op + 0.5) -- 482
	) -- 482
	local sh = toColor( -- 483
		____exports.CUFF_PALETTE.childSkinShadow, -- 483
		math.floor(255 * op + 0.5) -- 483
	) -- 483
	local sleeve = toColor( -- 484
		____exports.CUFF_PALETTE.childSleeve, -- 484
		math.floor(255 * op + 0.5) -- 484
	) -- 484
	if pose == "two_fingers" then -- 484
		draw:drawSegment( -- 488
			pt(-18, -4), -- 488
			pt(18, -5), -- 488
			5 * s, -- 488
			skin -- 488
		) -- 488
		draw:drawSegment( -- 489
			pt(-16, 6), -- 489
			pt(22, 7), -- 489
			5 * s, -- 489
			skin -- 489
		) -- 489
		draw:drawDot( -- 490
			pt(18, -5), -- 490
			2.5 * s, -- 490
			sh -- 490
		) -- 490
		draw:drawDot( -- 491
			pt(22, 7), -- 491
			2.5 * s, -- 491
			sh -- 491
		) -- 491
		return -- 492
	end -- 492
	draw:drawPolygon( -- 496
		{ -- 496
			pt(-135, -24), -- 497
			pt(-6, -18), -- 498
			pt(-6, 18), -- 499
			pt(-135, 26) -- 500
		}, -- 500
		sleeve, -- 501
		1.1, -- 501
		sh -- 501
	) -- 501
	if withCompassCord then -- 501
		draw:drawSegment( -- 505
			pt(-10, -18), -- 505
			pt(-4, 18), -- 505
			2.6 * s, -- 505
			toColor( -- 505
				____exports.CUFF_PALETTE.childCord, -- 505
				math.floor(235 * op + 0.5) -- 505
			) -- 505
		) -- 505
		draw:drawSegment( -- 506
			pt(-4, -18), -- 506
			pt(2, 18), -- 506
			2.2 * s, -- 506
			toColor( -- 506
				____exports.CUFF_PALETTE.childCord, -- 506
				math.floor(200 * op + 0.5) -- 506
			) -- 506
		) -- 506
	end -- 506
	draw:drawPolygon( -- 510
		{ -- 510
			pt(-4, -15), -- 511
			pt(28, -14), -- 512
			pt(34, 2), -- 513
			pt(22, 17), -- 514
			pt(-4, 15) -- 515
		}, -- 515
		skin, -- 516
		1, -- 516
		sh -- 516
	) -- 516
	if pose == "clutch" or pose == "clasp" then -- 516
		draw:drawSegment( -- 520
			pt(24, -11), -- 520
			pt(44, -6), -- 520
			4 * s, -- 520
			skin -- 520
		) -- 520
		draw:drawSegment( -- 521
			pt(26, -2), -- 521
			pt(47, 2), -- 521
			4.2 * s, -- 521
			skin -- 521
		) -- 521
		draw:drawSegment( -- 522
			pt(24, 6), -- 522
			pt(43, 9), -- 522
			4 * s, -- 522
			skin -- 522
		) -- 522
		draw:drawSegment( -- 523
			pt(16, 14), -- 523
			pt(34, 16), -- 523
			4.2 * s, -- 523
			skin -- 523
		) -- 523
	else -- 523
		draw:drawSegment( -- 526
			pt(26, -12), -- 526
			pt(52, -16), -- 526
			3.6 * s, -- 526
			skin -- 526
		) -- 526
		draw:drawSegment( -- 527
			pt(29, -4), -- 527
			pt(57, -5), -- 527
			3.8 * s, -- 527
			skin -- 527
		) -- 527
		draw:drawSegment( -- 528
			pt(28, 4), -- 528
			pt(54, 7), -- 528
			3.6 * s, -- 528
			skin -- 528
		) -- 528
		draw:drawSegment( -- 529
			pt(24, 11), -- 529
			pt(46, 17), -- 529
			3.4 * s, -- 529
			skin -- 529
		) -- 529
		draw:drawSegment( -- 530
			pt(14, 15), -- 530
			pt(34, 26), -- 530
			4 * s, -- 530
			skin -- 530
		) -- 530
	end -- 530
end -- 411
--- 仅在 G05 重逢抬镜后绘制全幅冷月蹲姿周戍重逢插画（去生硬小弹窗框，自然融于全屏遮幅）
local function drawZhouShuReunionPortrait(draw, _inkDraw, art, glow, w, h, tiltOffsetY, alpha) -- 535
	local a = clamp01(alpha) -- 545
	if a <= 0.01 then -- 545
		return -- 547
	end -- 547
	local barH = math.floor(h * 0.068 + 0.5) -- 549
	local viewH = math.max(120, h - barH * 2) -- 550
	local scaleCover = math.max(w / 960, (viewH + 40) / 540) -- 551
	local imgW = 960 * scaleCover -- 552
	local imgH = 540 * scaleCover -- 553
	local cy = h * 0.5 - tiltOffsetY -- 554
	local placed = art:tryPlacePath( -- 556
		"assets/art/cg_g05_reunion.png", -- 557
		"g05_zhoushu_reunion_cg", -- 558
		w * 0.5, -- 559
		cy, -- 560
		imgW, -- 561
		imgH, -- 562
		{ -- 563
			anchorX = 0.5, -- 564
			anchorY = 0.5, -- 565
			opacity = a, -- 566
			smooth = true, -- 567
			layer = 1 -- 568
		} -- 568
	) -- 568
	if not placed then -- 568
		fillVGradRect( -- 572
			draw, -- 573
			0, -- 574
			barH, -- 575
			w, -- 576
			viewH, -- 577
			Color( -- 578
				10, -- 578
				15, -- 578
				24, -- 578
				math.floor(230 * a + 0.5) -- 578
			), -- 578
			Color( -- 579
				22, -- 579
				34, -- 579
				52, -- 579
				math.floor(238 * a + 0.5) -- 579
			) -- 579
		) -- 579
		art:tryPlace( -- 581
			"soldier_offer", -- 582
			"g05_zhoushu_closeup", -- 583
			w * 0.58, -- 584
			barH + 20, -- 585
			190, -- 586
			260, -- 587
			{opacity = a, layer = 2} -- 588
		) -- 588
	end -- 588
	fillVGradRect( -- 592
		draw, -- 592
		0, -- 592
		barH, -- 592
		w, -- 592
		72, -- 592
		Color( -- 592
			6, -- 592
			9, -- 592
			14, -- 592
			math.floor(145 * a + 0.5) -- 592
		), -- 592
		Color(6, 9, 14, 0) -- 592
	) -- 592
	fillVGradRect( -- 593
		draw, -- 593
		0, -- 593
		h - barH - 64, -- 593
		w, -- 593
		64, -- 593
		Color(6, 9, 14, 0), -- 593
		Color( -- 593
			6, -- 593
			9, -- 593
			14, -- 593
			math.floor(135 * a + 0.5) -- 593
		) -- 593
	) -- 593
	fillRadialGlow( -- 594
		glow, -- 594
		w * 0.54, -- 594
		h * 0.58, -- 594
		w * 0.34, -- 594
		h * 0.34, -- 594
		Color( -- 594
			196, -- 594
			214, -- 594
			232, -- 594
			math.floor(32 * a + 0.5) -- 594
		), -- 594
		Color(110, 142, 174, 0), -- 594
		16 -- 594
	) -- 594
end -- 535
____exports.CuffShotsPlugin = __TS__Class() -- 597
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 597
CuffShotsPlugin.name = "CuffShotsPlugin" -- 597
function CuffShotsPlugin.prototype.____constructor(self) -- 597
	self.id = "fe-01-cuff-shots" -- 598
	self.animTime = 0 -- 600
	self.prevPhase = "" -- 601
	self.activeShot = "" -- 602
	self.rehearsalShot = "" -- 605
	self.rehearsalTime = 0 -- 606
	self.rehearsalDuration = 3 -- 607
	self.rehearsalAutoAdvance = true -- 608
	self.p03Progress = 0 -- 611
	self.p05Progress = 0 -- 612
	self.p05ExitTimer = -1 -- 613
	self.g05SleeveExtend = 0 -- 614
	self.g05ReunionElapsed = 0 -- 615
	self.g05LineTriggered = false -- 616
	self.g05AbortVisualCount = 0 -- 617
	self.lastReleasedAbortCount = 0 -- 618
end -- 597
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 620
	self.animTime = 0 -- 621
	self.prevPhase = p.phase -- 622
	self.activeShot = "" -- 623
	self.p03Progress = 0 -- 624
	self.p05Progress = 0 -- 625
	self.p05ExitTimer = -1 -- 626
	self.g05SleeveExtend = 0 -- 627
	self.g05ReunionElapsed = 0 -- 628
	self.g05LineTriggered = false -- 629
	self.g05AbortVisualCount = 0 -- 630
	self.lastReleasedAbortCount = 0 -- 631
end -- 620
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 639
	self.rehearsalShot = shot -- 640
	if shot == "" then -- 640
		self.rehearsalTime = 0 -- 642
		self.rehearsalAutoAdvance = true -- 643
		return -- 644
	end -- 644
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 646
	if fixedTime ~= nil then -- 646
		self.rehearsalTime = math.max( -- 648
			0, -- 648
			math.min(self.rehearsalDuration, fixedTime) -- 648
		) -- 648
		self.rehearsalAutoAdvance = false -- 649
	else -- 649
		self.rehearsalTime = 0 -- 651
		self.rehearsalAutoAdvance = true -- 652
	end -- 652
end -- 639
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 656
	self:rehearseShot("") -- 657
end -- 656
function CuffShotsPlugin.prototype.getDebugState(self) -- 660
	return { -- 661
		activeShot = self.activeShot, -- 662
		rehearsalShot = self.rehearsalShot, -- 663
		rehearsalTime = self.rehearsalTime, -- 664
		rehearsalDuration = self.rehearsalDuration, -- 665
		p03Progress = self.p03Progress, -- 666
		p05ExitTimer = self.p05ExitTimer, -- 667
		g05SleeveExtend = self.g05SleeveExtend, -- 668
		g05ReunionElapsed = self.g05ReunionElapsed, -- 669
		g05LineTriggered = self.g05LineTriggered, -- 670
		g05AbortVisualCount = self.g05AbortVisualCount -- 671
	} -- 671
end -- 660
function CuffShotsPlugin.prototype.update(self, ctx) -- 675
	local p = ctx.p -- 676
	local view = ctx.view -- 677
	local dt = ctx.paused and 0 or ctx.worldDt -- 678
	self.animTime = self.animTime + dt -- 679
	if self.rehearsalShot ~= "" then -- 679
		self.activeShot = self.rehearsalShot -- 683
		if self.rehearsalAutoAdvance and dt > 0 then -- 683
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 685
		end -- 685
		if not ctx.paused then -- 685
			self:triggerRehearsalAudio(ctx) -- 688
		end -- 688
		self.prevPhase = p.phase -- 690
		return -- 691
	end -- 691
	self.activeShot = "" -- 694
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 694
		self.activeShot = "P03" -- 698
		self.p03Progress = clamp01(p.phaseTick / PROLOGUE_GIVE_TICKS) -- 699
		if not ctx.paused and self.p03Progress >= 0.18 then -- 699
			ctx.audio:playOnce( -- 701
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 702
				"sfx", -- 703
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 704
				0.86, -- 705
				"cuff:p03:cloth_wipe_wood", -- 706
				p.ticks -- 707
			) -- 707
		end -- 707
		if not ctx.paused and self.p03Progress >= 0.62 then -- 707
			ctx.audio:playOnce( -- 711
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 712
				"sfx", -- 713
				"assets/audio/interact/compass_handover.wav", -- 714
				0.82, -- 715
				"cuff:p03:compass_handover", -- 716
				p.ticks -- 717
			) -- 717
		end -- 717
		self.prevPhase = p.phase -- 720
		return -- 721
	else -- 721
		self.p03Progress = 0 -- 723
	end -- 723
	if p.room.key == "gate" and p.phase == "gate-farewell" then -- 723
		self.activeShot = "P05" -- 728
		self.p05Progress = clamp01(p.phaseTick / GATE_FAREWELL_TICKS) -- 729
		self.p05ExitTimer = p.phaseTick / 60 -- 730
		if not ctx.paused then -- 730
			if self.p05Progress >= 0.14 then -- 730
				ctx.audio:playOnce( -- 733
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 734
					"voice", -- 735
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 736
					0.88, -- 737
					"cuff:p05:line_farewell", -- 738
					p.ticks -- 739
				) -- 739
			end -- 739
			if self.p05Progress >= 0.7 then -- 739
				ctx.audio:playOnce( -- 743
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 744
					"sfx", -- 745
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 746
					0.92, -- 747
					"cuff:p05:gate_slam", -- 748
					p.ticks -- 749
				) -- 749
			end -- 749
		end -- 749
		self.prevPhase = p.phase -- 753
		return -- 754
	else -- 754
		self.p05Progress = 0 -- 756
		self.p05ExitTimer = -1 -- 757
	end -- 757
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 761
	if inGateReunion then -- 761
		self.activeShot = "G05" -- 769
		local gr = view.gateReunion -- 770
		local completed = p.phase == "gate-hand" or gr.completed -- 771
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 771
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 774
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 775
			if not ctx.paused and view.isRehearsal then -- 775
				ctx.audio:playOnce( -- 777
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 778
					"sfx", -- 779
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 780
					0.72, -- 781
					"cuff:g05:reunion_release", -- 782
					p.ticks -- 783
				) -- 783
			end -- 783
		end -- 783
		if completed then -- 783
			self.g05SleeveExtend = 1 -- 789
			if dt > 0 then -- 789
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 791
			end -- 791
			if not ctx.paused and not self.g05LineTriggered then -- 791
				if view.isRehearsal then -- 791
					ctx.audio:playOnce( -- 795
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 796
						"sfx", -- 797
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 798
						0.88, -- 799
						"cuff:g05:hand_held", -- 800
						p.ticks -- 801
					) -- 801
				end -- 801
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 801
					self.g05LineTriggered = true -- 805
					ctx.audio:playOnce( -- 806
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 807
						"voice", -- 808
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 809
						0.94, -- 810
						"cuff:g05:line_reunion", -- 811
						p.ticks -- 812
					) -- 812
				end -- 812
			end -- 812
		else -- 812
			self.g05ReunionElapsed = 0 -- 817
			self.g05LineTriggered = false -- 818
			if gr.holding or gr.holdProgress > 0.001 then -- 818
				if gr.holdProgress >= self.g05SleeveExtend then -- 818
					self.g05SleeveExtend = gr.holdProgress -- 822
				elseif dt > 0 then -- 822
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 824
				end -- 824
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 824
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 828
			end -- 828
		end -- 828
	else -- 828
		self.g05SleeveExtend = 0 -- 832
		self.g05ReunionElapsed = 0 -- 833
		self.g05LineTriggered = false -- 834
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 835
	end -- 835
	self.prevPhase = p.phase -- 838
end -- 675
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 841
	local sid = ctx.events.roomSessionId -- 842
	local t = self.rehearsalTime -- 843
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 843
		ctx.audio:playOnce( -- 845
			"reh:p03:wipe:" .. tostring(sid), -- 845
			"sfx", -- 845
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 845
			0.88, -- 845
			"cuff:p03:cloth_wipe_wood", -- 845
			ctx.p.ticks -- 845
		) -- 845
	elseif self.rehearsalShot == "P05" then -- 845
		if t >= 0.9 then -- 845
			ctx.audio:playOnce( -- 848
				"reh:p05:line:" .. tostring(sid), -- 848
				"voice", -- 848
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 848
				0.9, -- 848
				"cuff:p05:line_farewell", -- 848
				ctx.p.ticks -- 848
			) -- 848
		end -- 848
		if t >= 2.75 then -- 848
			ctx.audio:playOnce( -- 851
				"reh:p05:slam:" .. tostring(sid), -- 851
				"sfx", -- 851
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 851
				0.94, -- 851
				"cuff:p05:gate_slam", -- 851
				ctx.p.ticks -- 851
			) -- 851
			ctx.audio:playLoop( -- 852
				"reh_p05_water", -- 852
				"water", -- 852
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 852
				0.42, -- 852
				ctx.p.ticks -- 852
			) -- 852
		end -- 852
	elseif self.rehearsalShot == "G05" then -- 852
		if t >= 0.05 then -- 852
			ctx.audio:playOnce( -- 856
				"reh:g05:knock1:" .. tostring(sid), -- 856
				"sfx", -- 856
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 856
				0.88, -- 856
				"knock:gate:1", -- 856
				ctx.p.ticks -- 856
			) -- 856
		end -- 856
		if t >= 0.25 then -- 856
			ctx.audio:playOnce( -- 859
				"reh:g05:knock2:" .. tostring(sid), -- 859
				"sfx", -- 859
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 859
				0.92, -- 859
				"knock:gate:2", -- 859
				ctx.p.ticks -- 859
			) -- 859
		end -- 859
		if t >= 1.55 then -- 859
			ctx.audio:playOnce( -- 862
				"reh:g05:clasp:" .. tostring(sid), -- 862
				"sfx", -- 862
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 862
				0.88, -- 862
				"cuff:g05:hand_held", -- 862
				ctx.p.ticks -- 862
			) -- 862
		end -- 862
		if t >= 2.35 then -- 862
			ctx.audio:playOnce( -- 865
				"reh:g05:line:" .. tostring(sid), -- 865
				"voice", -- 865
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 865
				0.94, -- 865
				"cuff:g05:line_reunion", -- 865
				ctx.p.ticks -- 865
			) -- 865
		end -- 865
	end -- 865
end -- 841
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 870
	if self.activeShot == "" then -- 870
		return false -- 878
	end -- 878
	local w = ctx.uiW -- 880
	local h = ctx.uiH -- 881
	if self.activeShot == "P03" then -- 881
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 884
		self:renderP03Shot( -- 887
			uiDraw, -- 887
			uiInkDraw, -- 887
			uiArt, -- 887
			uiGlow, -- 887
			ctx, -- 887
			w, -- 887
			h, -- 887
			prog -- 887
		) -- 887
		return true -- 888
	end -- 888
	if self.activeShot == "P05" then -- 888
		local prog = self.rehearsalShot == "P05" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p05Progress -- 892
		self:renderP05FullShot( -- 895
			uiDraw, -- 895
			uiInkDraw, -- 895
			uiArt, -- 895
			uiGlow, -- 895
			ctx, -- 895
			w, -- 895
			h, -- 895
			prog -- 895
		) -- 895
		return true -- 896
	end -- 896
	if self.activeShot == "G05" then -- 896
		if self.rehearsalShot == "G05" then -- 896
			self:renderG05RehearsalShot( -- 901
				uiDraw, -- 901
				uiInkDraw, -- 901
				uiArt, -- 901
				uiGlow, -- 901
				ctx, -- 901
				w, -- 901
				h, -- 901
				self.rehearsalTime -- 901
			) -- 901
			return true -- 902
		end -- 902
		self:renderG05LiveShot( -- 904
			uiDraw, -- 904
			uiInkDraw, -- 904
			uiArt, -- 904
			uiGlow, -- 904
			ctx, -- 904
			w, -- 904
			h -- 904
		) -- 904
		return true -- 905
	end -- 905
	return false -- 908
end -- 870
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 917
	local fade = smoothstep(0, 0.03, prog) * (1 - smoothstep(0.96, 1, prog)) -- 927
	local barH = math.floor(h * 0.075 + 0.5) -- 928
	drawComicSequence( -- 930
		uiDraw, -- 931
		uiInkDraw, -- 932
		uiArt, -- 933
		P03_COMIC_SEQ, -- 934
		prog, -- 935
		w, -- 936
		h, -- 937
		{ -- 938
			letterboxH = barH, -- 939
			opacity = fade, -- 940
			layer = 2, -- 941
			instancePrefix = "p03_comic", -- 942
			accentBorder = true -- 943
		} -- 943
	) -- 943
	if self.rehearsalShot == "P03" then -- 943
		drawSilkVeil( -- 948
			uiDraw, -- 948
			uiArt, -- 948
			"p03_sub_veil", -- 948
			w * 0.5, -- 948
			42, -- 948
			520, -- 948
			42, -- 948
			PALETTE.inkWash, -- 948
			0.82 * fade, -- 948
			7 -- 948
		) -- 948
		local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 949
		ctx.texts:put( -- 952
			"sm", -- 952
			subText, -- 952
			w * 0.5, -- 952
			42, -- 952
			toColor(PALETTE.textBright), -- 952
			0.5, -- 952
			0.5, -- 952
			"Center", -- 952
			1, -- 952
			fade, -- 952
			0.08 -- 952
		) -- 952
	end -- 952
end -- 917
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 963
	local fade = smoothstep(0, 0.05, prog) * (1 - smoothstep(0.95, 1, prog)) -- 973
	local barH = math.floor(h * 0.075 + 0.5) -- 974
	drawComicSequence( -- 976
		uiDraw, -- 977
		uiInkDraw, -- 978
		uiArt, -- 979
		P05_COMIC_SEQ, -- 980
		prog, -- 981
		w, -- 982
		h, -- 983
		{ -- 984
			letterboxH = barH, -- 985
			opacity = fade, -- 986
			layer = 2, -- 987
			instancePrefix = "p05_comic", -- 988
			accentBorder = true -- 989
		} -- 989
	) -- 989
	local lineAlpha = fade * smoothstep(0.14, 0.26, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 994
	if lineAlpha > 0.02 then -- 994
		drawSilkVeil( -- 996
			uiDraw, -- 996
			uiArt, -- 996
			"p05_sub_veil", -- 996
			w * 0.5, -- 996
			42, -- 996
			740, -- 996
			44, -- 996
			PALETTE.inkWash, -- 996
			0.86 * lineAlpha, -- 996
			7 -- 996
		) -- 996
		drawHairline( -- 997
			uiInkDraw, -- 997
			uiArt, -- 997
			"p05_sub_line", -- 997
			w * 0.5, -- 997
			62, -- 997
			520, -- 997
			PALETTE.silkDim, -- 997
			0.52 * lineAlpha, -- 997
			true, -- 997
			8 -- 997
		) -- 997
		ctx.texts:put( -- 998
			"sm", -- 998
			LINE_P05, -- 998
			w * 0.5, -- 998
			42, -- 998
			toColor(PALETTE.textBright), -- 998
			0.5, -- 998
			0.5, -- 998
			"Center", -- 998
			0.8, -- 998
			lineAlpha, -- 998
			0.08 -- 998
		) -- 998
	end -- 998
end -- 963
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1003
	local enter = smoothstep(0, 0.12, t) -- 1013
	local out = smoothstep(0.66, 1, t) -- 1014
	local alpha = enter * (1 - out) -- 1015
	if alpha <= 0.02 then -- 1015
		return -- 1017
	end -- 1017
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 1019
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1020
		wristX = w * 0.27 - out * 260, -- 1021
		wristY = h * 0.4, -- 1022
		angleRad = -0.05, -- 1023
		scale = 1.04, -- 1024
		pose = pinchT > 0.25 and "pinch" or "open", -- 1025
		opacity = alpha * 0.95, -- 1026
		stitchHighlight = 0.45 + 0.28 * pinchT, -- 1027
		uiArt = uiArt, -- 1028
		instanceKey = "p05_live_zhou_cuff", -- 1029
		layer = 4 -- 1030
	}) -- 1030
	drawChildHand( -- 1032
		uiDraw, -- 1033
		w * 0.39 + out * 30, -- 1034
		h * 0.37 - out * 10, -- 1035
		math.pi + 0.1, -- 1036
		1.02, -- 1037
		out > 0.32 and "open_fingers" or "clutch", -- 1038
		alpha * 0.94, -- 1039
		true, -- 1040
		uiArt, -- 1041
		"p05_live_child_hand", -- 1042
		5 -- 1043
	) -- 1043
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 1045
	if lineAlpha > 0.02 then -- 1045
		local subY = 92 -- 1047
		drawSilkVeil( -- 1048
			uiDraw, -- 1048
			uiArt, -- 1048
			"p05_live_veil", -- 1048
			w * 0.5, -- 1048
			subY, -- 1048
			760, -- 1048
			44, -- 1048
			PALETTE.inkWash, -- 1048
			0.86 * lineAlpha, -- 1048
			7 -- 1048
		) -- 1048
		drawHairline( -- 1049
			uiInkDraw, -- 1049
			uiArt, -- 1049
			"p05_live_line", -- 1049
			w * 0.5, -- 1049
			subY + 20, -- 1049
			520, -- 1049
			PALETTE.silkDim, -- 1049
			0.52 * lineAlpha, -- 1049
			true, -- 1049
			8 -- 1049
		) -- 1049
		ctx.texts:put( -- 1050
			"sm", -- 1050
			LINE_P05, -- 1050
			w * 0.5, -- 1050
			subY, -- 1050
			toColor(PALETTE.textBright), -- 1050
			0.5, -- 1050
			0.5, -- 1050
			"Center", -- 1050
			0.8, -- 1050
			lineAlpha, -- 1050
			0.08 -- 1050
		) -- 1050
	end -- 1050
end -- 1003
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1059
	local view = ctx.view -- 1068
	local gr = view.gateReunion -- 1069
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1070
	local ext = clamp01(self.g05SleeveExtend) -- 1071
	if not completed then -- 1071
		if ext > 0.008 then -- 1071
			local comicOp = smoothstep(0.01, 0.16, ext) -- 1075
			drawComicSequence( -- 1076
				uiDraw, -- 1077
				uiInkDraw, -- 1078
				uiArt, -- 1079
				G05_HOLD_COMIC_SEQ, -- 1080
				ext, -- 1081
				w, -- 1082
				h, -- 1083
				{ -- 1084
					letterboxH = math.floor(h * 0.068 + 0.5), -- 1085
					opacity = comicOp, -- 1086
					layer = 2, -- 1087
					instancePrefix = "g05_hold_comic", -- 1088
					accentBorder = true -- 1089
				} -- 1089
			) -- 1089
			local barW = 240 -- 1094
			local bx0 = w * 0.5 - barW * 0.5 -- 1095
			local by0 = 18 -- 1096
			uiInkDraw:drawSegment( -- 1097
				Vec2(bx0, by0), -- 1097
				Vec2(bx0 + barW, by0), -- 1097
				1.2, -- 1097
				toColor(PALETTE.silkDim, 110) -- 1097
			) -- 1097
			uiInkDraw:drawSegment( -- 1098
				Vec2(bx0, by0), -- 1098
				Vec2(bx0 + barW * ext, by0), -- 1098
				2.4, -- 1098
				toColor(PALETTE.amberCore, 230) -- 1098
			) -- 1098
		else -- 1098
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1100
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1101
				wristX = -120 + peekPulse * 18, -- 1102
				wristY = h * 0.44, -- 1103
				angleRad = -0.04, -- 1104
				scale = 1.16, -- 1105
				pose = "open", -- 1106
				opacity = 0.42 + 0.24 * peekPulse, -- 1107
				stitchHighlight = 0.35 * peekPulse, -- 1108
				uiArt = uiArt, -- 1109
				instanceKey = "g05_live_zhou_cuff", -- 1110
				layer = 4 -- 1111
			}) -- 1111
		end -- 1111
		if view.assistHintsEnabled then -- 1111
			drawSilkVeil( -- 1116
				uiDraw, -- 1116
				uiArt, -- 1116
				"g05_assist_veil", -- 1116
				w * 0.5, -- 1116
				h - 26, -- 1116
				280, -- 1116
				28, -- 1116
				PALETTE.inkWash, -- 1116
				0.72, -- 1116
				7 -- 1116
			) -- 1116
			ctx.texts:put( -- 1117
				"xs", -- 1118
				getActiveTarget():adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1119
				w * 0.5, -- 1120
				h - 26, -- 1121
				toColor(PALETTE.amberCore), -- 1122
				0.5, -- 1123
				0.5, -- 1124
				"Center", -- 1125
				1.2, -- 1126
				0.9, -- 1127
				0.08 -- 1128
			) -- 1128
		end -- 1128
		return -- 1131
	end -- 1131
	local t = self.g05ReunionElapsed -- 1135
	local barH = math.floor(h * 0.068 + 0.5) -- 1136
	drawComicSequence( -- 1137
		uiDraw, -- 1138
		uiInkDraw, -- 1139
		uiArt, -- 1140
		G05_REUNION_COMIC_SEQ, -- 1141
		t, -- 1142
		w, -- 1143
		h, -- 1144
		{ -- 1145
			letterboxH = barH, -- 1146
			opacity = 1, -- 1147
			layer = 2, -- 1148
			instancePrefix = "g05_reunion_comic", -- 1149
			accentBorder = true -- 1150
		} -- 1150
	) -- 1150
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1155
	if lineAlpha > 0.02 then -- 1155
		drawSilkVeil( -- 1157
			uiDraw, -- 1157
			uiArt, -- 1157
			"g05_line_veil", -- 1157
			w * 0.5, -- 1157
			42, -- 1157
			420, -- 1157
			44, -- 1157
			PALETTE.inkWash, -- 1157
			0.86 * lineAlpha, -- 1157
			7 -- 1157
		) -- 1157
		drawHairline( -- 1158
			uiInkDraw, -- 1158
			uiArt, -- 1158
			"g05_line_bar", -- 1158
			w * 0.5, -- 1158
			62, -- 1158
			260, -- 1158
			PALETTE.amber, -- 1158
			0.58 * lineAlpha, -- 1158
			true, -- 1158
			8 -- 1158
		) -- 1158
		ctx.texts:put( -- 1159
			"sm", -- 1159
			LINE_G05, -- 1159
			w * 0.5, -- 1159
			42, -- 1159
			toColor(PALETTE.textBright), -- 1159
			0.5, -- 1159
			0.5, -- 1159
			"Center", -- 1159
			2.2, -- 1159
			lineAlpha, -- 1159
			0.08 -- 1159
		) -- 1159
	end -- 1159
end -- 1059
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, t) -- 1164
	local barH = math.floor(h * 0.072 + 0.5) -- 1174
	drawComicSequence( -- 1175
		uiDraw, -- 1176
		uiInkDraw, -- 1177
		uiArt, -- 1178
		G05_REHEARSAL_COMIC_SEQ, -- 1179
		t, -- 1180
		w, -- 1181
		h, -- 1182
		{ -- 1183
			letterboxH = barH, -- 1184
			opacity = 1, -- 1185
			layer = 2, -- 1186
			instancePrefix = "g05_reh_comic", -- 1187
			accentBorder = true -- 1188
		} -- 1188
	) -- 1188
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
			7 -- 1194
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
			8 -- 1195
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
end -- 1164
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