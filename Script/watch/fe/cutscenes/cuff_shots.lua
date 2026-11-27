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
--- P03 柜边相认硬核木刻漫画逐帧拍表（归一化进度 0..1）
local P03_COMIC_SEQ = {{ -- 95
	slot = "comic_p03_01_two_fingers", -- 96
	start = 0, -- 96
	["end"] = 0.28, -- 96
	zoomFrom = 1, -- 96
	zoomTo = 1.012, -- 96
	transition = "cut" -- 96
}, { -- 96
	slot = "comic_p03_02_cuff_enter", -- 97
	start = 0.28, -- 97
	["end"] = 0.52, -- 97
	zoomFrom = 1.005, -- 97
	zoomTo = 1.016, -- 97
	transition = "cut" -- 97
}, { -- 97
	slot = "comic_p03_03_cuff_wipe", -- 98
	start = 0.52, -- 98
	["end"] = 0.76, -- 98
	zoomFrom = 1.01, -- 98
	zoomTo = 1.022, -- 98
	transition = "cut", -- 98
	shakeAmp = 2.6, -- 98
	shakeFreq = 52 -- 98
}, { -- 98
	slot = "comic_p03_04_hand_meet", -- 99
	start = 0.76, -- 99
	["end"] = 1, -- 99
	zoomFrom = 1.012, -- 99
	zoomTo = 1, -- 99
	transition = "cut" -- 99
}} -- 99
--- P05 城门送别硬核木刻漫画逐帧拍表（归一化进度 0..1，含 0.72 落门单帧三色木刻冲击）
local P05_COMIC_SEQ = { -- 103
	{ -- 104
		slot = "comic_p05_01_clutch_cuff", -- 104
		start = 0, -- 104
		["end"] = 0.2, -- 104
		zoomFrom = 1, -- 104
		zoomTo = 1.01, -- 104
		transition = "cut" -- 104
	}, -- 104
	{ -- 105
		slot = "comic_p05_02_brother_pinch", -- 105
		start = 0.2, -- 105
		["end"] = 0.44, -- 105
		zoomFrom = 1.005, -- 105
		zoomTo = 1.015, -- 105
		transition = "cut" -- 105
	}, -- 105
	{ -- 106
		slot = "comic_p05_03_sleeve_pull", -- 106
		start = 0.44, -- 106
		["end"] = 0.64, -- 106
		zoomFrom = 1.008, -- 106
		zoomTo = 1.02, -- 106
		transition = "cut" -- 106
	}, -- 106
	{ -- 107
		slot = "comic_p05_04_gate_drop", -- 107
		start = 0.64, -- 107
		["end"] = 0.72, -- 107
		zoomFrom = 1.015, -- 107
		zoomTo = 1.028, -- 107
		transition = "cut", -- 107
		shakeAmp = 4, -- 107
		shakeFreq = 62 -- 107
	}, -- 107
	{ -- 108
		slot = "comic_p05_05_gate_slam_impact", -- 108
		start = 0.72, -- 108
		["end"] = 0.79, -- 108
		zoomFrom = 1.036, -- 108
		zoomTo = 1.036, -- 108
		transition = "cut", -- 108
		impactFlash = true, -- 108
		impactDur = 0.07, -- 108
		shakeAmp = 12, -- 108
		shakeFreq = 74 -- 108
	}, -- 108
	{ -- 109
		slot = "comic_p05_06_open_fingers", -- 109
		start = 0.79, -- 109
		["end"] = 1, -- 109
		zoomFrom = 1.012, -- 109
		zoomTo = 1, -- 109
		transition = "cut", -- 109
		shakeAmp = 2.2 -- 109
	} -- 109
} -- 109
--- G05 长按伸袖交互拍表（严格跟随 holdProgress 0..1）
local G05_HOLD_COMIC_SEQ = {{ -- 113
	slot = "comic_g05_01_cuff_peek", -- 114
	start = 0, -- 114
	["end"] = 0.3, -- 114
	zoomFrom = 1, -- 114
	zoomTo = 1.01, -- 114
	transition = "cut" -- 114
}, { -- 114
	slot = "comic_g05_02_cuff_extend", -- 115
	start = 0.3, -- 115
	["end"] = 0.7, -- 115
	zoomFrom = 1.005, -- 115
	zoomTo = 1.015, -- 115
	transition = "cut" -- 115
}, { -- 115
	slot = "comic_g05_03_hands_meet", -- 116
	start = 0.7, -- 116
	["end"] = 1, -- 116
	zoomFrom = 1.01, -- 116
	zoomTo = 1.02, -- 116
	transition = "cut" -- 116
}} -- 116
--- G05 握稳重逢顺臂抬镜至周戍露脸拍表（秒）
local G05_REUNION_COMIC_SEQ = { -- 120
	{ -- 121
		slot = "comic_g05_04_hands_clasp", -- 121
		start = 0, -- 121
		["end"] = 0.38, -- 121
		zoomFrom = 1, -- 121
		zoomTo = 1.012, -- 121
		transition = "cut" -- 121
	}, -- 121
	{ -- 122
		slot = "comic_g05_05_tilt_arm", -- 122
		start = 0.38, -- 122
		["end"] = 0.78, -- 122
		zoomFrom = 1.005, -- 122
		zoomTo = 1.015, -- 122
		transition = "cut" -- 122
	}, -- 122
	{ -- 123
		slot = "comic_g05_06_tilt_shoulder", -- 123
		start = 0.78, -- 123
		["end"] = 1.18, -- 123
		zoomFrom = 1.005, -- 123
		zoomTo = 1.015, -- 123
		transition = "cut" -- 123
	}, -- 123
	{ -- 124
		slot = "comic_g05_07_zhoushu_reveal", -- 124
		start = 1.18, -- 124
		["end"] = 1.72, -- 124
		zoomFrom = 1, -- 124
		zoomTo = 1.012, -- 124
		transition = "cut" -- 124
	}, -- 124
	{ -- 125
		slot = "comic_g05_08_zhoushu_warm", -- 125
		start = 1.72, -- 125
		["end"] = 12, -- 125
		zoomFrom = 1.008, -- 125
		zoomTo = 1, -- 125
		transition = "cut" -- 125
	} -- 125
} -- 125
--- G05 4 秒独立排演全 8 帧连续拍表
local G05_REHEARSAL_COMIC_SEQ = { -- 129
	{ -- 130
		slot = "comic_g05_01_cuff_peek", -- 130
		start = 0, -- 130
		["end"] = 0.5, -- 130
		zoomFrom = 1, -- 130
		zoomTo = 1.01, -- 130
		transition = "cut" -- 130
	}, -- 130
	{ -- 131
		slot = "comic_g05_02_cuff_extend", -- 131
		start = 0.5, -- 131
		["end"] = 1, -- 131
		zoomFrom = 1, -- 131
		zoomTo = 1.01, -- 131
		transition = "cut" -- 131
	}, -- 131
	{ -- 132
		slot = "comic_g05_03_hands_meet", -- 132
		start = 1, -- 132
		["end"] = 1.45, -- 132
		zoomFrom = 1.005, -- 132
		zoomTo = 1.015, -- 132
		transition = "cut" -- 132
	}, -- 132
	{ -- 133
		slot = "comic_g05_04_hands_clasp", -- 133
		start = 1.45, -- 133
		["end"] = 1.88, -- 133
		zoomFrom = 1.005, -- 133
		zoomTo = 1.012, -- 133
		transition = "cut" -- 133
	}, -- 133
	{ -- 134
		slot = "comic_g05_05_tilt_arm", -- 134
		start = 1.88, -- 134
		["end"] = 2.3, -- 134
		zoomFrom = 1.005, -- 134
		zoomTo = 1.012, -- 134
		transition = "cut" -- 134
	}, -- 134
	{ -- 135
		slot = "comic_g05_06_tilt_shoulder", -- 135
		start = 2.3, -- 135
		["end"] = 2.72, -- 135
		zoomFrom = 1.005, -- 135
		zoomTo = 1.012, -- 135
		transition = "cut" -- 135
	}, -- 135
	{ -- 136
		slot = "comic_g05_07_zhoushu_reveal", -- 136
		start = 2.72, -- 136
		["end"] = 3.3, -- 136
		zoomFrom = 1, -- 136
		zoomTo = 1.01, -- 136
		transition = "cut" -- 136
	}, -- 136
	{ -- 137
		slot = "comic_g05_08_zhoushu_warm", -- 137
		start = 3.3, -- 137
		["end"] = 4.5, -- 137
		zoomFrom = 1.006, -- 137
		zoomTo = 1, -- 137
		transition = "cut" -- 137
	} -- 137
} -- 137
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 141
	indigoBase = rgba(34, 52, 74, 255), -- 142
	indigoShadow = rgba(18, 28, 42, 255), -- 143
	indigoFold = rgba(54, 78, 104, 255), -- 144
	patchDark = rgba(24, 38, 56, 255), -- 145
	hemEdge = rgba(68, 92, 118, 255), -- 146
	armWrapLinen = rgba(154, 142, 120, 255), -- 147
	armWrapShadow = rgba(102, 92, 78, 255), -- 148
	stitchThread = rgba(232, 224, 204, 255), -- 150
	stitchPinhole = rgba(14, 19, 28, 255), -- 151
	skinBase = rgba(188, 146, 116, 255), -- 152
	skinShadow = rgba(138, 102, 78, 255), -- 153
	skinLight = rgba(216, 178, 148, 255), -- 154
	childSkin = rgba(226, 196, 170, 255), -- 155
	childSkinShadow = rgba(176, 144, 120, 255), -- 156
	childSleeve = rgba(164, 142, 114, 255), -- 157
	childCord = rgba(168, 56, 52, 255) -- 158
} -- 158
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 161
	local sx = lx * scale -- 162
	local sy = ly * scale -- 163
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 164
end -- 161
local function tinted(base, warmth, opacity) -- 167
	local warmTarget = rgba( -- 168
		math.min(255, base.r + 22), -- 169
		math.min(255, base.g + 12), -- 170
		math.max(0, base.b - 10), -- 171
		base.a -- 172
	) -- 172
	local mixed = lerpRGBA( -- 174
		base, -- 174
		warmTarget, -- 174
		clamp01(warmth) -- 174
	) -- 174
	return toColor( -- 175
		mixed, -- 175
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 175
	) -- 175
end -- 167
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 182
	local op = clamp01(opts.opacity or 1) -- 187
	if op <= 0.01 then -- 187
		return -- 189
	end -- 189
	local ox = opts.wristX -- 191
	local oy = opts.wristY -- 192
	local s = math.max(0.2, opts.scale) -- 193
	local cosA = math.cos(opts.angleRad) -- 194
	local sinA = math.sin(opts.angleRad) -- 195
	local w = clamp01(opts.warmth or 0) -- 196
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 197
	local function pt(lx, ly) -- 198
		return rotPt( -- 198
			ox, -- 198
			oy, -- 198
			lx, -- 198
			ly, -- 198
			cosA, -- 198
			sinA, -- 198
			s -- 198
		) -- 198
	end -- 198
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 199
	if opts.uiArt ~= nil then -- 199
		local framePath = (opts.pose == "clasp" or opts.pose == "pinch") and "assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp" or "assets/art/cutscene_cuff_rig.clip|cuff_zhou_open" -- 203
		local key = opts.instanceKey or "patched_cuff_zhou" -- 206
		local spriteW = 368 * s -- 207
		local spriteH = 166 * s -- 208
		local anchorOffset = pull * 0.55 -- 209
		local placedPos = pt(-anchorOffset, 0) -- 210
		local tintCol = tinted( -- 211
			rgba(232, 238, 246, 255), -- 211
			w * 0.72, -- 211
			1 -- 211
		) -- 211
		if opts.uiArt:tryPlacePath( -- 211
			framePath, -- 212
			key, -- 212
			placedPos.x, -- 212
			placedPos.y, -- 212
			spriteW, -- 212
			spriteH, -- 212
			{ -- 212
				anchorX = 0.57, -- 213
				anchorY = 0.5, -- 214
				angle = -(opts.angleRad * 180) / math.pi, -- 215
				color = tintCol, -- 216
				opacity = op, -- 217
				smooth = true, -- 218
				layer = opts.layer or 4 -- 219
			} -- 219
		) then -- 219
			if hl > 0.08 then -- 219
				local stitchPos = pt(-58 - anchorOffset, -6) -- 222
				fillRadialGlow( -- 223
					glow, -- 224
					stitchPos.x, -- 225
					stitchPos.y, -- 226
					36 * s, -- 227
					22 * s, -- 228
					toColor( -- 229
						____exports.CUFF_PALETTE.stitchThread, -- 229
						math.floor(52 * hl * op + 0.5) -- 229
					), -- 229
					toColor(____exports.CUFF_PALETTE.stitchThread, 0), -- 230
					12 -- 231
				) -- 231
			end -- 231
			return -- 234
		end -- 234
	end -- 234
	local cuffFront = 6 - pull -- 239
	draw:drawPolygon( -- 240
		{ -- 240
			pt(-250, -48), -- 241
			pt(cuffFront, -36), -- 242
			pt(cuffFront, 38), -- 243
			pt(-250, 52) -- 244
		}, -- 244
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 245
		1.4, -- 245
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 245
	) -- 245
	draw:drawPolygon( -- 248
		{ -- 248
			pt(-250, -48), -- 249
			pt(cuffFront, -36), -- 250
			pt(cuffFront, -8), -- 251
			pt(-250, -14) -- 252
		}, -- 252
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 253
	) -- 253
	draw:drawPolygon( -- 256
		{ -- 256
			pt(-230, 14), -- 257
			pt(cuffFront - 6, 10), -- 258
			pt(cuffFront - 4, 32), -- 259
			pt(-230, 40) -- 260
		}, -- 260
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 261
	) -- 261
	draw:drawSegment( -- 262
		pt(-185, 16), -- 262
		pt(cuffFront - 18, 12), -- 262
		1.2 * s, -- 262
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 262
	) -- 262
	draw:drawSegment( -- 263
		pt(-160, -10), -- 263
		pt(cuffFront - 26, -6), -- 263
		1.1 * s, -- 263
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 263
	) -- 263
	draw:drawPolygon( -- 266
		{ -- 266
			pt(cuffFront - 8, -28), -- 267
			pt(cuffFront + 16, -24), -- 268
			pt(cuffFront + 16, 26), -- 269
			pt(cuffFront - 8, 28) -- 270
		}, -- 270
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 271
		1, -- 271
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 271
	) -- 271
	draw:drawSegment( -- 272
		pt(cuffFront + 3, -25), -- 272
		pt(cuffFront + 7, 25), -- 272
		1.3 * s, -- 272
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 272
	) -- 272
	draw:drawPolygon( -- 275
		{ -- 275
			pt(cuffFront - 16, -37), -- 276
			pt(cuffFront + 2, -36), -- 277
			pt(cuffFront + 2, 38), -- 278
			pt(cuffFront - 16, 39) -- 279
		}, -- 279
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 280
		1.3, -- 280
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 280
	) -- 280
	local pX0 = cuffFront - 72 -- 283
	local pX1 = cuffFront - 18 -- 284
	local pY0 = -16 -- 285
	local pY1 = 22 -- 286
	draw:drawPolygon( -- 287
		{ -- 287
			pt(pX0, pY0), -- 288
			pt(pX1, pY0 + 3), -- 289
			pt(pX1 - 2, pY1), -- 290
			pt(pX0 + 3, pY1 - 2) -- 291
		}, -- 291
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 292
		1.1, -- 292
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 292
	) -- 292
	local seamStartX = pX0 + 6 -- 295
	local seamStartY = pY0 + 5 -- 296
	local seamEndX = pX1 - 7 -- 297
	local seamEndY = pY1 - 5 -- 298
	draw:drawSegment( -- 299
		pt(seamStartX, seamStartY), -- 300
		pt(seamEndX, seamEndY), -- 301
		1.5 * s, -- 302
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 303
	) -- 303
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 306
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 307
	local stitches = 6 -- 308
	local k = 0 -- 309
	do -- 309
		k = 0 -- 310
		while k < stitches do -- 310
			local t = (k + 0.5) / stitches -- 311
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 312
			local my = seamStartY + (seamEndY - seamStartY) * t -- 313
			local nx = -4.8 -- 314
			local ny = 6.2 -- 315
			local a = pt(mx - nx, my - ny) -- 316
			local b = pt(mx + nx, my + ny) -- 317
			draw:drawDot(a, 1.3 * s, pinCol) -- 318
			draw:drawDot(b, 1.3 * s, pinCol) -- 319
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 320
			if hl > 0.05 then -- 320
				glow:drawSegment( -- 322
					a, -- 322
					b, -- 322
					2.4 * s, -- 322
					toColor( -- 322
						____exports.CUFF_PALETTE.stitchThread, -- 322
						math.floor(74 * hl * op + 0.5) -- 322
					) -- 322
				) -- 322
			end -- 322
			k = k + 1 -- 310
		end -- 310
	end -- 310
	local handBase = cuffFront + 14 -- 327
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 328
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 329
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 330
	if opts.pose == "wipe" then -- 330
		draw:drawPolygon( -- 334
			{ -- 334
				pt(handBase - 4, -20), -- 335
				pt(handBase + 46, -24), -- 336
				pt(handBase + 54, 4), -- 337
				pt(handBase + 38, 22), -- 338
				pt(handBase - 4, 20) -- 339
			}, -- 339
			skinCol, -- 340
			1.1, -- 340
			skinSh -- 340
		) -- 340
		draw:drawSegment( -- 341
			pt(handBase + 16, -2), -- 341
			pt(handBase + 52, -6), -- 341
			1.4 * s, -- 341
			skinSh -- 341
		) -- 341
		draw:drawSegment( -- 342
			pt(handBase + 14, 10), -- 342
			pt(handBase + 46, 8), -- 342
			1.4 * s, -- 342
			skinSh -- 342
		) -- 342
	elseif opts.pose == "pinch" then -- 342
		draw:drawPolygon( -- 345
			{ -- 345
				pt(handBase - 4, -22), -- 346
				pt(handBase + 44, -18), -- 347
				pt(handBase + 54, 6), -- 348
				pt(handBase + 28, 26), -- 349
				pt(handBase - 4, 22) -- 350
			}, -- 350
			skinCol, -- 351
			1.1, -- 351
			skinSh -- 351
		) -- 351
		draw:drawSegment( -- 352
			pt(handBase + 24, 16), -- 352
			pt(handBase + 52, 4), -- 352
			6.2 * s, -- 352
			skinHi -- 352
		) -- 352
		draw:drawSegment( -- 353
			pt(handBase + 30, -14), -- 353
			pt(handBase + 54, -4), -- 353
			5.6 * s, -- 353
			skinCol -- 353
		) -- 353
	elseif opts.pose == "clasp" then -- 353
		draw:drawPolygon( -- 356
			{ -- 356
				pt(handBase - 2, -22), -- 357
				pt(handBase + 52, -20), -- 358
				pt(handBase + 66, 2), -- 359
				pt(handBase + 44, 26), -- 360
				pt(handBase - 2, 22) -- 361
			}, -- 361
			skinCol, -- 362
			1.2, -- 362
			skinSh -- 362
		) -- 362
		draw:drawSegment( -- 363
			pt(handBase + 26, 20), -- 363
			pt(handBase + 58, 12), -- 363
			6.5 * s, -- 363
			skinHi -- 363
		) -- 363
		draw:drawSegment( -- 364
			pt(handBase + 46, -14), -- 364
			pt(handBase + 72, -10), -- 364
			5.2 * s, -- 364
			skinCol -- 364
		) -- 364
		draw:drawSegment( -- 365
			pt(handBase + 48, -2), -- 365
			pt(handBase + 76, 1), -- 365
			5.4 * s, -- 365
			skinCol -- 365
		) -- 365
	else -- 365
		local reachExt = opts.pose == "reach" and 10 or 0 -- 368
		draw:drawPolygon( -- 369
			{ -- 369
				pt(handBase - 4, -20), -- 370
				pt(handBase + 44 + reachExt, -18), -- 371
				pt(handBase + 56 + reachExt, 4), -- 372
				pt(handBase + 34 + reachExt * 0.5, 24), -- 373
				pt(handBase - 4, 20) -- 374
			}, -- 374
			skinCol, -- 375
			1.1, -- 375
			skinSh -- 375
		) -- 375
		draw:drawSegment( -- 377
			pt(handBase + 42 + reachExt, -14), -- 377
			pt(handBase + 74 + reachExt, -16), -- 377
			4.6 * s, -- 377
			skinCol -- 377
		) -- 377
		draw:drawSegment( -- 378
			pt(handBase + 46 + reachExt, -4), -- 378
			pt(handBase + 80 + reachExt, -3), -- 378
			4.8 * s, -- 378
			skinCol -- 378
		) -- 378
		draw:drawSegment( -- 379
			pt(handBase + 44 + reachExt, 6), -- 379
			pt(handBase + 76 + reachExt, 9), -- 379
			4.6 * s, -- 379
			skinCol -- 379
		) -- 379
		draw:drawSegment( -- 380
			pt(handBase + 26 + reachExt * 0.5, 18), -- 380
			pt(handBase + 56 + reachExt * 0.6, 28), -- 380
			5.2 * s, -- 380
			skinHi -- 380
		) -- 380
	end -- 380
end -- 182
--- 绘制小满伸出的小手（优先使用手绘 cutscene_cuff_rig.clip 幼童红袄手腕部件）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord, uiArt, instanceKey, layer) -- 385
	if withCompassCord == nil then -- 385
		withCompassCord = true -- 393
	end -- 393
	if instanceKey == nil then -- 393
		instanceKey = "cuff_child_hand" -- 395
	end -- 395
	if layer == nil then -- 395
		layer = 5 -- 396
	end -- 396
	local op = clamp01(opacity) -- 398
	if op <= 0.01 then -- 398
		return -- 400
	end -- 400
	local s = math.max(0.2, scale) -- 402
	if uiArt ~= nil then -- 402
		if pose == "two_fingers" then -- 402
			if uiArt:tryPlacePath( -- 402
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_peek", -- 406
				instanceKey .. "_peek", -- 407
				ox, -- 408
				oy, -- 409
				116 * s, -- 410
				134 * s, -- 411
				{ -- 412
					anchorX = 0.5, -- 413
					anchorY = 0.16, -- 414
					angle = 90, -- 415
					opacity = op, -- 416
					smooth = true, -- 417
					layer = layer -- 418
				} -- 418
			) then -- 418
				return -- 421
			end -- 421
		else -- 421
			local relDeg = -((angleRad - math.pi) * 180) / math.pi -- 424
			if uiArt:tryPlacePath( -- 424
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 426
				instanceKey .. "_reach", -- 427
				ox, -- 428
				oy, -- 429
				298 * s, -- 430
				132 * s, -- 431
				{ -- 432
					anchorX = 0.43, -- 433
					anchorY = 0.52, -- 434
					angle = relDeg, -- 435
					opacity = op, -- 436
					smooth = true, -- 437
					layer = layer -- 438
				} -- 438
			) then -- 438
				if withCompassCord then -- 438
					local cosA = math.cos(angleRad) -- 442
					local sinA = math.sin(angleRad) -- 443
					local p1 = rotPt( -- 444
						ox, -- 444
						oy, -- 444
						-12, -- 444
						-16, -- 444
						cosA, -- 444
						sinA, -- 444
						s -- 444
					) -- 444
					local p2 = rotPt( -- 445
						ox, -- 445
						oy, -- 445
						-6, -- 445
						16, -- 445
						cosA, -- 445
						sinA, -- 445
						s -- 445
					) -- 445
					draw:drawSegment( -- 446
						p1, -- 446
						p2, -- 446
						2.2 * s, -- 446
						toColor( -- 446
							____exports.CUFF_PALETTE.childCord, -- 446
							math.floor(165 * op + 0.5) -- 446
						) -- 446
					) -- 446
				end -- 446
				return -- 448
			end -- 448
		end -- 448
	end -- 448
	local cosA = math.cos(angleRad) -- 453
	local sinA = math.sin(angleRad) -- 454
	local function pt(lx, ly) -- 455
		return rotPt( -- 455
			ox, -- 455
			oy, -- 455
			lx, -- 455
			ly, -- 455
			cosA, -- 455
			sinA, -- 455
			s -- 455
		) -- 455
	end -- 455
	local skin = toColor( -- 456
		____exports.CUFF_PALETTE.childSkin, -- 456
		math.floor(255 * op + 0.5) -- 456
	) -- 456
	local sh = toColor( -- 457
		____exports.CUFF_PALETTE.childSkinShadow, -- 457
		math.floor(255 * op + 0.5) -- 457
	) -- 457
	local sleeve = toColor( -- 458
		____exports.CUFF_PALETTE.childSleeve, -- 458
		math.floor(255 * op + 0.5) -- 458
	) -- 458
	if pose == "two_fingers" then -- 458
		draw:drawSegment( -- 462
			pt(-18, -4), -- 462
			pt(18, -5), -- 462
			5 * s, -- 462
			skin -- 462
		) -- 462
		draw:drawSegment( -- 463
			pt(-16, 6), -- 463
			pt(22, 7), -- 463
			5 * s, -- 463
			skin -- 463
		) -- 463
		draw:drawDot( -- 464
			pt(18, -5), -- 464
			2.5 * s, -- 464
			sh -- 464
		) -- 464
		draw:drawDot( -- 465
			pt(22, 7), -- 465
			2.5 * s, -- 465
			sh -- 465
		) -- 465
		return -- 466
	end -- 466
	draw:drawPolygon( -- 470
		{ -- 470
			pt(-135, -24), -- 471
			pt(-6, -18), -- 472
			pt(-6, 18), -- 473
			pt(-135, 26) -- 474
		}, -- 474
		sleeve, -- 475
		1.1, -- 475
		sh -- 475
	) -- 475
	if withCompassCord then -- 475
		draw:drawSegment( -- 479
			pt(-10, -18), -- 479
			pt(-4, 18), -- 479
			2.6 * s, -- 479
			toColor( -- 479
				____exports.CUFF_PALETTE.childCord, -- 479
				math.floor(235 * op + 0.5) -- 479
			) -- 479
		) -- 479
		draw:drawSegment( -- 480
			pt(-4, -18), -- 480
			pt(2, 18), -- 480
			2.2 * s, -- 480
			toColor( -- 480
				____exports.CUFF_PALETTE.childCord, -- 480
				math.floor(200 * op + 0.5) -- 480
			) -- 480
		) -- 480
	end -- 480
	draw:drawPolygon( -- 484
		{ -- 484
			pt(-4, -15), -- 485
			pt(28, -14), -- 486
			pt(34, 2), -- 487
			pt(22, 17), -- 488
			pt(-4, 15) -- 489
		}, -- 489
		skin, -- 490
		1, -- 490
		sh -- 490
	) -- 490
	if pose == "clutch" or pose == "clasp" then -- 490
		draw:drawSegment( -- 494
			pt(24, -11), -- 494
			pt(44, -6), -- 494
			4 * s, -- 494
			skin -- 494
		) -- 494
		draw:drawSegment( -- 495
			pt(26, -2), -- 495
			pt(47, 2), -- 495
			4.2 * s, -- 495
			skin -- 495
		) -- 495
		draw:drawSegment( -- 496
			pt(24, 6), -- 496
			pt(43, 9), -- 496
			4 * s, -- 496
			skin -- 496
		) -- 496
		draw:drawSegment( -- 497
			pt(16, 14), -- 497
			pt(34, 16), -- 497
			4.2 * s, -- 497
			skin -- 497
		) -- 497
	else -- 497
		draw:drawSegment( -- 500
			pt(26, -12), -- 500
			pt(52, -16), -- 500
			3.6 * s, -- 500
			skin -- 500
		) -- 500
		draw:drawSegment( -- 501
			pt(29, -4), -- 501
			pt(57, -5), -- 501
			3.8 * s, -- 501
			skin -- 501
		) -- 501
		draw:drawSegment( -- 502
			pt(28, 4), -- 502
			pt(54, 7), -- 502
			3.6 * s, -- 502
			skin -- 502
		) -- 502
		draw:drawSegment( -- 503
			pt(24, 11), -- 503
			pt(46, 17), -- 503
			3.4 * s, -- 503
			skin -- 503
		) -- 503
		draw:drawSegment( -- 504
			pt(14, 15), -- 504
			pt(34, 26), -- 504
			4 * s, -- 504
			skin -- 504
		) -- 504
	end -- 504
end -- 385
--- 仅在 G05 重逢抬镜后绘制全幅冷月蹲姿周戍重逢插画（去生硬小弹窗框，自然融于全屏遮幅）
local function drawZhouShuReunionPortrait(draw, _inkDraw, art, glow, w, h, tiltOffsetY, alpha) -- 509
	local a = clamp01(alpha) -- 519
	if a <= 0.01 then -- 519
		return -- 521
	end -- 521
	local barH = math.floor(h * 0.068 + 0.5) -- 523
	local viewH = math.max(120, h - barH * 2) -- 524
	local scaleCover = math.max(w / 960, (viewH + 40) / 540) -- 525
	local imgW = 960 * scaleCover -- 526
	local imgH = 540 * scaleCover -- 527
	local cy = h * 0.5 - tiltOffsetY -- 528
	local placed = art:tryPlacePath( -- 530
		"assets/art/cg_g05_reunion.png", -- 531
		"g05_zhoushu_reunion_cg", -- 532
		w * 0.5, -- 533
		cy, -- 534
		imgW, -- 535
		imgH, -- 536
		{ -- 537
			anchorX = 0.5, -- 538
			anchorY = 0.5, -- 539
			opacity = a, -- 540
			smooth = true, -- 541
			layer = 1 -- 542
		} -- 542
	) -- 542
	if not placed then -- 542
		fillVGradRect( -- 546
			draw, -- 547
			0, -- 548
			barH, -- 549
			w, -- 550
			viewH, -- 551
			Color( -- 552
				10, -- 552
				15, -- 552
				24, -- 552
				math.floor(230 * a + 0.5) -- 552
			), -- 552
			Color( -- 553
				22, -- 553
				34, -- 553
				52, -- 553
				math.floor(238 * a + 0.5) -- 553
			) -- 553
		) -- 553
		art:tryPlace( -- 555
			"soldier_offer", -- 556
			"g05_zhoushu_closeup", -- 557
			w * 0.58, -- 558
			barH + 20, -- 559
			190, -- 560
			260, -- 561
			{opacity = a, layer = 2} -- 562
		) -- 562
	end -- 562
	fillVGradRect( -- 566
		draw, -- 566
		0, -- 566
		barH, -- 566
		w, -- 566
		72, -- 566
		Color( -- 566
			6, -- 566
			9, -- 566
			14, -- 566
			math.floor(145 * a + 0.5) -- 566
		), -- 566
		Color(6, 9, 14, 0) -- 566
	) -- 566
	fillVGradRect( -- 567
		draw, -- 567
		0, -- 567
		h - barH - 64, -- 567
		w, -- 567
		64, -- 567
		Color(6, 9, 14, 0), -- 567
		Color( -- 567
			6, -- 567
			9, -- 567
			14, -- 567
			math.floor(135 * a + 0.5) -- 567
		) -- 567
	) -- 567
	fillRadialGlow( -- 568
		glow, -- 568
		w * 0.54, -- 568
		h * 0.58, -- 568
		w * 0.34, -- 568
		h * 0.34, -- 568
		Color( -- 568
			196, -- 568
			214, -- 568
			232, -- 568
			math.floor(32 * a + 0.5) -- 568
		), -- 568
		Color(110, 142, 174, 0), -- 568
		16 -- 568
	) -- 568
end -- 509
____exports.CuffShotsPlugin = __TS__Class() -- 571
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 571
CuffShotsPlugin.name = "CuffShotsPlugin" -- 571
function CuffShotsPlugin.prototype.____constructor(self) -- 571
	self.id = "fe-01-cuff-shots" -- 572
	self.animTime = 0 -- 574
	self.prevPhase = "" -- 575
	self.activeShot = "" -- 576
	self.rehearsalShot = "" -- 579
	self.rehearsalTime = 0 -- 580
	self.rehearsalDuration = 3 -- 581
	self.rehearsalAutoAdvance = true -- 582
	self.p03Progress = 0 -- 585
	self.p05Progress = 0 -- 586
	self.p05ExitTimer = -1 -- 587
	self.g05SleeveExtend = 0 -- 588
	self.g05ReunionElapsed = 0 -- 589
	self.g05LineTriggered = false -- 590
	self.g05AbortVisualCount = 0 -- 591
	self.lastReleasedAbortCount = 0 -- 592
end -- 571
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 594
	self.animTime = 0 -- 595
	self.prevPhase = p.phase -- 596
	self.activeShot = "" -- 597
	self.p03Progress = 0 -- 598
	self.p05Progress = 0 -- 599
	self.p05ExitTimer = -1 -- 600
	self.g05SleeveExtend = 0 -- 601
	self.g05ReunionElapsed = 0 -- 602
	self.g05LineTriggered = false -- 603
	self.g05AbortVisualCount = 0 -- 604
	self.lastReleasedAbortCount = 0 -- 605
end -- 594
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 613
	self.rehearsalShot = shot -- 614
	if shot == "" then -- 614
		self.rehearsalTime = 0 -- 616
		self.rehearsalAutoAdvance = true -- 617
		return -- 618
	end -- 618
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 620
	if fixedTime ~= nil then -- 620
		self.rehearsalTime = math.max( -- 622
			0, -- 622
			math.min(self.rehearsalDuration, fixedTime) -- 622
		) -- 622
		self.rehearsalAutoAdvance = false -- 623
	else -- 623
		self.rehearsalTime = 0 -- 625
		self.rehearsalAutoAdvance = true -- 626
	end -- 626
end -- 613
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 630
	self:rehearseShot("") -- 631
end -- 630
function CuffShotsPlugin.prototype.getDebugState(self) -- 634
	return { -- 635
		activeShot = self.activeShot, -- 636
		rehearsalShot = self.rehearsalShot, -- 637
		rehearsalTime = self.rehearsalTime, -- 638
		rehearsalDuration = self.rehearsalDuration, -- 639
		p03Progress = self.p03Progress, -- 640
		p05ExitTimer = self.p05ExitTimer, -- 641
		g05SleeveExtend = self.g05SleeveExtend, -- 642
		g05ReunionElapsed = self.g05ReunionElapsed, -- 643
		g05LineTriggered = self.g05LineTriggered, -- 644
		g05AbortVisualCount = self.g05AbortVisualCount -- 645
	} -- 645
end -- 634
function CuffShotsPlugin.prototype.update(self, ctx) -- 649
	local p = ctx.p -- 650
	local view = ctx.view -- 651
	local dt = ctx.paused and 0 or ctx.worldDt -- 652
	self.animTime = self.animTime + dt -- 653
	if self.rehearsalShot ~= "" then -- 653
		self.activeShot = self.rehearsalShot -- 657
		if self.rehearsalAutoAdvance and dt > 0 then -- 657
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 659
		end -- 659
		if not ctx.paused then -- 659
			self:triggerRehearsalAudio(ctx) -- 662
		end -- 662
		self.prevPhase = p.phase -- 664
		return -- 665
	end -- 665
	self.activeShot = "" -- 668
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 668
		self.activeShot = "P03" -- 672
		self.p03Progress = clamp01(p.phaseTick / PROLOGUE_GIVE_TICKS) -- 673
		if not ctx.paused and self.p03Progress >= 0.18 then -- 673
			ctx.audio:playOnce( -- 675
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 676
				"sfx", -- 677
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 678
				0.86, -- 679
				"cuff:p03:cloth_wipe_wood", -- 680
				p.ticks -- 681
			) -- 681
		end -- 681
		if not ctx.paused and self.p03Progress >= 0.62 then -- 681
			ctx.audio:playOnce( -- 685
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 686
				"sfx", -- 687
				"assets/audio/interact/compass_handover.wav", -- 688
				0.82, -- 689
				"cuff:p03:compass_handover", -- 690
				p.ticks -- 691
			) -- 691
		end -- 691
		self.prevPhase = p.phase -- 694
		return -- 695
	else -- 695
		self.p03Progress = 0 -- 697
	end -- 697
	if p.room.key == "gate" and p.phase == "gate-farewell" then -- 697
		self.activeShot = "P05" -- 702
		self.p05Progress = clamp01(p.phaseTick / GATE_FAREWELL_TICKS) -- 703
		self.p05ExitTimer = p.phaseTick / 60 -- 704
		if not ctx.paused then -- 704
			if self.p05Progress >= 0.14 then -- 704
				ctx.audio:playOnce( -- 707
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 708
					"voice", -- 709
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 710
					0.88, -- 711
					"cuff:p05:line_farewell", -- 712
					p.ticks -- 713
				) -- 713
			end -- 713
			if self.p05Progress >= 0.7 then -- 713
				ctx.audio:playOnce( -- 717
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 718
					"sfx", -- 719
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 720
					0.92, -- 721
					"cuff:p05:gate_slam", -- 722
					p.ticks -- 723
				) -- 723
			end -- 723
		end -- 723
		self.prevPhase = p.phase -- 727
		return -- 728
	else -- 728
		self.p05Progress = 0 -- 730
		self.p05ExitTimer = -1 -- 731
	end -- 731
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 735
	if inGateReunion then -- 735
		self.activeShot = "G05" -- 743
		local gr = view.gateReunion -- 744
		local completed = p.phase == "gate-hand" or gr.completed -- 745
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 745
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 748
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 749
			if not ctx.paused and view.isRehearsal then -- 749
				ctx.audio:playOnce( -- 751
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 752
					"sfx", -- 753
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 754
					0.72, -- 755
					"cuff:g05:reunion_release", -- 756
					p.ticks -- 757
				) -- 757
			end -- 757
		end -- 757
		if completed then -- 757
			self.g05SleeveExtend = 1 -- 763
			if dt > 0 then -- 763
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 765
			end -- 765
			if not ctx.paused and not self.g05LineTriggered then -- 765
				if view.isRehearsal then -- 765
					ctx.audio:playOnce( -- 769
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 770
						"sfx", -- 771
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 772
						0.88, -- 773
						"cuff:g05:hand_held", -- 774
						p.ticks -- 775
					) -- 775
				end -- 775
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 775
					self.g05LineTriggered = true -- 779
					ctx.audio:playOnce( -- 780
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 781
						"voice", -- 782
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 783
						0.94, -- 784
						"cuff:g05:line_reunion", -- 785
						p.ticks -- 786
					) -- 786
				end -- 786
			end -- 786
		else -- 786
			self.g05ReunionElapsed = 0 -- 791
			self.g05LineTriggered = false -- 792
			if gr.holding or gr.holdProgress > 0.001 then -- 792
				if gr.holdProgress >= self.g05SleeveExtend then -- 792
					self.g05SleeveExtend = gr.holdProgress -- 796
				elseif dt > 0 then -- 796
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 798
				end -- 798
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 798
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 802
			end -- 802
		end -- 802
	else -- 802
		self.g05SleeveExtend = 0 -- 806
		self.g05ReunionElapsed = 0 -- 807
		self.g05LineTriggered = false -- 808
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 809
	end -- 809
	self.prevPhase = p.phase -- 812
end -- 649
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 815
	local sid = ctx.events.roomSessionId -- 816
	local t = self.rehearsalTime -- 817
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 817
		ctx.audio:playOnce( -- 819
			"reh:p03:wipe:" .. tostring(sid), -- 819
			"sfx", -- 819
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 819
			0.88, -- 819
			"cuff:p03:cloth_wipe_wood", -- 819
			ctx.p.ticks -- 819
		) -- 819
	elseif self.rehearsalShot == "P05" then -- 819
		if t >= 0.9 then -- 819
			ctx.audio:playOnce( -- 822
				"reh:p05:line:" .. tostring(sid), -- 822
				"voice", -- 822
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 822
				0.9, -- 822
				"cuff:p05:line_farewell", -- 822
				ctx.p.ticks -- 822
			) -- 822
		end -- 822
		if t >= 2.75 then -- 822
			ctx.audio:playOnce( -- 825
				"reh:p05:slam:" .. tostring(sid), -- 825
				"sfx", -- 825
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 825
				0.94, -- 825
				"cuff:p05:gate_slam", -- 825
				ctx.p.ticks -- 825
			) -- 825
			ctx.audio:playLoop( -- 826
				"reh_p05_water", -- 826
				"water", -- 826
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 826
				0.42, -- 826
				ctx.p.ticks -- 826
			) -- 826
		end -- 826
	elseif self.rehearsalShot == "G05" then -- 826
		if t >= 0.05 then -- 826
			ctx.audio:playOnce( -- 830
				"reh:g05:knock1:" .. tostring(sid), -- 830
				"sfx", -- 830
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 830
				0.88, -- 830
				"knock:gate:1", -- 830
				ctx.p.ticks -- 830
			) -- 830
		end -- 830
		if t >= 0.25 then -- 830
			ctx.audio:playOnce( -- 833
				"reh:g05:knock2:" .. tostring(sid), -- 833
				"sfx", -- 833
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 833
				0.92, -- 833
				"knock:gate:2", -- 833
				ctx.p.ticks -- 833
			) -- 833
		end -- 833
		if t >= 1.55 then -- 833
			ctx.audio:playOnce( -- 836
				"reh:g05:clasp:" .. tostring(sid), -- 836
				"sfx", -- 836
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 836
				0.88, -- 836
				"cuff:g05:hand_held", -- 836
				ctx.p.ticks -- 836
			) -- 836
		end -- 836
		if t >= 2.35 then -- 836
			ctx.audio:playOnce( -- 839
				"reh:g05:line:" .. tostring(sid), -- 839
				"voice", -- 839
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 839
				0.94, -- 839
				"cuff:g05:line_reunion", -- 839
				ctx.p.ticks -- 839
			) -- 839
		end -- 839
	end -- 839
end -- 815
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 844
	if self.activeShot == "" then -- 844
		return false -- 852
	end -- 852
	local w = ctx.uiW -- 854
	local h = ctx.uiH -- 855
	if self.activeShot == "P03" then -- 855
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 858
		self:renderP03Shot( -- 861
			uiDraw, -- 861
			uiInkDraw, -- 861
			uiArt, -- 861
			uiGlow, -- 861
			ctx, -- 861
			w, -- 861
			h, -- 861
			prog -- 861
		) -- 861
		return true -- 862
	end -- 862
	if self.activeShot == "P05" then -- 862
		local prog = self.rehearsalShot == "P05" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p05Progress -- 866
		self:renderP05FullShot( -- 869
			uiDraw, -- 869
			uiInkDraw, -- 869
			uiArt, -- 869
			uiGlow, -- 869
			ctx, -- 869
			w, -- 869
			h, -- 869
			prog -- 869
		) -- 869
		return true -- 870
	end -- 870
	if self.activeShot == "G05" then -- 870
		if self.rehearsalShot == "G05" then -- 870
			self:renderG05RehearsalShot( -- 875
				uiDraw, -- 875
				uiInkDraw, -- 875
				uiArt, -- 875
				uiGlow, -- 875
				ctx, -- 875
				w, -- 875
				h, -- 875
				self.rehearsalTime -- 875
			) -- 875
			return true -- 876
		end -- 876
		self:renderG05LiveShot( -- 878
			uiDraw, -- 878
			uiInkDraw, -- 878
			uiArt, -- 878
			uiGlow, -- 878
			ctx, -- 878
			w, -- 878
			h -- 878
		) -- 878
		return true -- 879
	end -- 879
	return false -- 882
end -- 844
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 891
	local fade = smoothstep(0, 0.07, prog) * (1 - smoothstep(0.93, 1, prog)) -- 901
	local barH = math.floor(h * 0.075 + 0.5) -- 902
	drawComicSequence( -- 904
		uiDraw, -- 905
		uiInkDraw, -- 906
		uiArt, -- 907
		P03_COMIC_SEQ, -- 908
		prog, -- 909
		w, -- 910
		h, -- 911
		{ -- 912
			letterboxH = barH, -- 913
			opacity = fade, -- 914
			layer = 2, -- 915
			instancePrefix = "p03_comic", -- 916
			accentBorder = true -- 917
		} -- 917
	) -- 917
	if self.rehearsalShot == "P03" then -- 917
		drawSilkVeil( -- 922
			uiDraw, -- 922
			uiArt, -- 922
			"p03_sub_veil", -- 922
			w * 0.5, -- 922
			42, -- 922
			520, -- 922
			42, -- 922
			PALETTE.inkWash, -- 922
			0.82 * fade, -- 922
			7 -- 922
		) -- 922
		local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 923
		ctx.texts:put( -- 926
			"sm", -- 926
			subText, -- 926
			w * 0.5, -- 926
			42, -- 926
			toColor(PALETTE.textBright), -- 926
			0.5, -- 926
			0.5, -- 926
			"Center", -- 926
			1, -- 926
			fade, -- 926
			0.08 -- 926
		) -- 926
	end -- 926
end -- 891
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, prog) -- 937
	local fade = smoothstep(0, 0.05, prog) * (1 - smoothstep(0.95, 1, prog)) -- 947
	local barH = math.floor(h * 0.075 + 0.5) -- 948
	drawComicSequence( -- 950
		uiDraw, -- 951
		uiInkDraw, -- 952
		uiArt, -- 953
		P05_COMIC_SEQ, -- 954
		prog, -- 955
		w, -- 956
		h, -- 957
		{ -- 958
			letterboxH = barH, -- 959
			opacity = fade, -- 960
			layer = 2, -- 961
			instancePrefix = "p05_comic", -- 962
			accentBorder = true -- 963
		} -- 963
	) -- 963
	local lineAlpha = fade * smoothstep(0.14, 0.26, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 968
	if lineAlpha > 0.02 then -- 968
		drawSilkVeil( -- 970
			uiDraw, -- 970
			uiArt, -- 970
			"p05_sub_veil", -- 970
			w * 0.5, -- 970
			42, -- 970
			740, -- 970
			44, -- 970
			PALETTE.inkWash, -- 970
			0.86 * lineAlpha, -- 970
			7 -- 970
		) -- 970
		drawHairline( -- 971
			uiInkDraw, -- 971
			uiArt, -- 971
			"p05_sub_line", -- 971
			w * 0.5, -- 971
			62, -- 971
			520, -- 971
			PALETTE.silkDim, -- 971
			0.52 * lineAlpha, -- 971
			true, -- 971
			8 -- 971
		) -- 971
		ctx.texts:put( -- 972
			"sm", -- 972
			LINE_P05, -- 972
			w * 0.5, -- 972
			42, -- 972
			toColor(PALETTE.textBright), -- 972
			0.5, -- 972
			0.5, -- 972
			"Center", -- 972
			0.8, -- 972
			lineAlpha, -- 972
			0.08 -- 972
		) -- 972
	end -- 972
end -- 937
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 977
	local enter = smoothstep(0, 0.12, t) -- 987
	local out = smoothstep(0.66, 1, t) -- 988
	local alpha = enter * (1 - out) -- 989
	if alpha <= 0.02 then -- 989
		return -- 991
	end -- 991
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 993
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 994
		wristX = w * 0.27 - out * 260, -- 995
		wristY = h * 0.4, -- 996
		angleRad = -0.05, -- 997
		scale = 1.04, -- 998
		pose = pinchT > 0.25 and "pinch" or "open", -- 999
		opacity = alpha * 0.95, -- 1000
		stitchHighlight = 0.45 + 0.28 * pinchT, -- 1001
		uiArt = uiArt, -- 1002
		instanceKey = "p05_live_zhou_cuff", -- 1003
		layer = 4 -- 1004
	}) -- 1004
	drawChildHand( -- 1006
		uiDraw, -- 1007
		w * 0.39 + out * 30, -- 1008
		h * 0.37 - out * 10, -- 1009
		math.pi + 0.1, -- 1010
		1.02, -- 1011
		out > 0.32 and "open_fingers" or "clutch", -- 1012
		alpha * 0.94, -- 1013
		true, -- 1014
		uiArt, -- 1015
		"p05_live_child_hand", -- 1016
		5 -- 1017
	) -- 1017
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 1019
	if lineAlpha > 0.02 then -- 1019
		local subY = 92 -- 1021
		drawSilkVeil( -- 1022
			uiDraw, -- 1022
			uiArt, -- 1022
			"p05_live_veil", -- 1022
			w * 0.5, -- 1022
			subY, -- 1022
			760, -- 1022
			44, -- 1022
			PALETTE.inkWash, -- 1022
			0.86 * lineAlpha, -- 1022
			7 -- 1022
		) -- 1022
		drawHairline( -- 1023
			uiInkDraw, -- 1023
			uiArt, -- 1023
			"p05_live_line", -- 1023
			w * 0.5, -- 1023
			subY + 20, -- 1023
			520, -- 1023
			PALETTE.silkDim, -- 1023
			0.52 * lineAlpha, -- 1023
			true, -- 1023
			8 -- 1023
		) -- 1023
		ctx.texts:put( -- 1024
			"sm", -- 1024
			LINE_P05, -- 1024
			w * 0.5, -- 1024
			subY, -- 1024
			toColor(PALETTE.textBright), -- 1024
			0.5, -- 1024
			0.5, -- 1024
			"Center", -- 1024
			0.8, -- 1024
			lineAlpha, -- 1024
			0.08 -- 1024
		) -- 1024
	end -- 1024
end -- 977
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1033
	local view = ctx.view -- 1042
	local gr = view.gateReunion -- 1043
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1044
	local ext = clamp01(self.g05SleeveExtend) -- 1045
	if not completed then -- 1045
		if ext > 0.008 then -- 1045
			local comicOp = smoothstep(0.01, 0.16, ext) -- 1049
			drawComicSequence( -- 1050
				uiDraw, -- 1051
				uiInkDraw, -- 1052
				uiArt, -- 1053
				G05_HOLD_COMIC_SEQ, -- 1054
				ext, -- 1055
				w, -- 1056
				h, -- 1057
				{ -- 1058
					letterboxH = math.floor(h * 0.068 + 0.5), -- 1059
					opacity = comicOp, -- 1060
					layer = 2, -- 1061
					instancePrefix = "g05_hold_comic", -- 1062
					accentBorder = true -- 1063
				} -- 1063
			) -- 1063
			local barW = 240 -- 1068
			local bx0 = w * 0.5 - barW * 0.5 -- 1069
			local by0 = 18 -- 1070
			uiInkDraw:drawSegment( -- 1071
				Vec2(bx0, by0), -- 1071
				Vec2(bx0 + barW, by0), -- 1071
				1.2, -- 1071
				toColor(PALETTE.silkDim, 110) -- 1071
			) -- 1071
			uiInkDraw:drawSegment( -- 1072
				Vec2(bx0, by0), -- 1072
				Vec2(bx0 + barW * ext, by0), -- 1072
				2.4, -- 1072
				toColor(PALETTE.amberCore, 230) -- 1072
			) -- 1072
		else -- 1072
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1074
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1075
				wristX = -120 + peekPulse * 18, -- 1076
				wristY = h * 0.44, -- 1077
				angleRad = -0.04, -- 1078
				scale = 1.16, -- 1079
				pose = "open", -- 1080
				opacity = 0.42 + 0.24 * peekPulse, -- 1081
				stitchHighlight = 0.35 * peekPulse, -- 1082
				uiArt = uiArt, -- 1083
				instanceKey = "g05_live_zhou_cuff", -- 1084
				layer = 4 -- 1085
			}) -- 1085
		end -- 1085
		if view.assistHintsEnabled then -- 1085
			drawSilkVeil( -- 1090
				uiDraw, -- 1090
				uiArt, -- 1090
				"g05_assist_veil", -- 1090
				w * 0.5, -- 1090
				h - 26, -- 1090
				280, -- 1090
				28, -- 1090
				PALETTE.inkWash, -- 1090
				0.72, -- 1090
				7 -- 1090
			) -- 1090
			ctx.texts:put( -- 1091
				"xs", -- 1092
				getActiveTarget():adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1093
				w * 0.5, -- 1094
				h - 26, -- 1095
				toColor(PALETTE.amberCore), -- 1096
				0.5, -- 1097
				0.5, -- 1098
				"Center", -- 1099
				1.2, -- 1100
				0.9, -- 1101
				0.08 -- 1102
			) -- 1102
		end -- 1102
		return -- 1105
	end -- 1105
	local t = self.g05ReunionElapsed -- 1109
	local barH = math.floor(h * 0.068 + 0.5) -- 1110
	drawComicSequence( -- 1111
		uiDraw, -- 1112
		uiInkDraw, -- 1113
		uiArt, -- 1114
		G05_REUNION_COMIC_SEQ, -- 1115
		t, -- 1116
		w, -- 1117
		h, -- 1118
		{ -- 1119
			letterboxH = barH, -- 1120
			opacity = 1, -- 1121
			layer = 2, -- 1122
			instancePrefix = "g05_reunion_comic", -- 1123
			accentBorder = true -- 1124
		} -- 1124
	) -- 1124
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1129
	if lineAlpha > 0.02 then -- 1129
		drawSilkVeil( -- 1131
			uiDraw, -- 1131
			uiArt, -- 1131
			"g05_line_veil", -- 1131
			w * 0.5, -- 1131
			42, -- 1131
			420, -- 1131
			44, -- 1131
			PALETTE.inkWash, -- 1131
			0.86 * lineAlpha, -- 1131
			7 -- 1131
		) -- 1131
		drawHairline( -- 1132
			uiInkDraw, -- 1132
			uiArt, -- 1132
			"g05_line_bar", -- 1132
			w * 0.5, -- 1132
			62, -- 1132
			260, -- 1132
			PALETTE.amber, -- 1132
			0.58 * lineAlpha, -- 1132
			true, -- 1132
			8 -- 1132
		) -- 1132
		ctx.texts:put( -- 1133
			"sm", -- 1133
			LINE_G05, -- 1133
			w * 0.5, -- 1133
			42, -- 1133
			toColor(PALETTE.textBright), -- 1133
			0.5, -- 1133
			0.5, -- 1133
			"Center", -- 1133
			2.2, -- 1133
			lineAlpha, -- 1133
			0.08 -- 1133
		) -- 1133
	end -- 1133
end -- 1033
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h, t) -- 1138
	local barH = math.floor(h * 0.072 + 0.5) -- 1148
	drawComicSequence( -- 1149
		uiDraw, -- 1150
		uiInkDraw, -- 1151
		uiArt, -- 1152
		G05_REHEARSAL_COMIC_SEQ, -- 1153
		t, -- 1154
		w, -- 1155
		h, -- 1156
		{ -- 1157
			letterboxH = barH, -- 1158
			opacity = 1, -- 1159
			layer = 2, -- 1160
			instancePrefix = "g05_reh_comic", -- 1161
			accentBorder = true -- 1162
		} -- 1162
	) -- 1162
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1166
	if lineAlpha > 0.02 then -- 1166
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
			7 -- 1168
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
			8 -- 1169
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
end -- 1138
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