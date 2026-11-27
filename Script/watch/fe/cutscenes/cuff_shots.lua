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
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 89
local LINE_P05 = "「小满，慢慢数到二十。哥要是还没出来，你就往北塔走。」" -- 90
local LINE_G05 = "「我们走吧。」" -- 91
--- 统一明初守卒补线青布袖口色板（与《明朝全局美术设定》完全一致，灰度亮度差 > 60%）
____exports.CUFF_PALETTE = { -- 94
	indigoBase = rgba(34, 52, 74, 255), -- 95
	indigoShadow = rgba(18, 28, 42, 255), -- 96
	indigoFold = rgba(54, 78, 104, 255), -- 97
	patchDark = rgba(24, 38, 56, 255), -- 98
	hemEdge = rgba(68, 92, 118, 255), -- 99
	armWrapLinen = rgba(154, 142, 120, 255), -- 100
	armWrapShadow = rgba(102, 92, 78, 255), -- 101
	stitchThread = rgba(232, 224, 204, 255), -- 103
	stitchPinhole = rgba(14, 19, 28, 255), -- 104
	skinBase = rgba(188, 146, 116, 255), -- 105
	skinShadow = rgba(138, 102, 78, 255), -- 106
	skinLight = rgba(216, 178, 148, 255), -- 107
	childSkin = rgba(226, 196, 170, 255), -- 108
	childSkinShadow = rgba(176, 144, 120, 255), -- 109
	childSleeve = rgba(164, 142, 114, 255), -- 110
	childCord = rgba(168, 56, 52, 255) -- 111
} -- 111
local function rotPt(ox, oy, lx, ly, cosA, sinA, scale) -- 114
	local sx = lx * scale -- 115
	local sy = ly * scale -- 116
	return Vec2(ox + sx * cosA - sy * sinA, oy + sx * sinA + sy * cosA) -- 117
end -- 114
local function tinted(base, warmth, opacity) -- 120
	local warmTarget = rgba( -- 121
		math.min(255, base.r + 22), -- 122
		math.min(255, base.g + 12), -- 123
		math.max(0, base.b - 10), -- 124
		base.a -- 125
	) -- 125
	local mixed = lerpRGBA( -- 127
		base, -- 127
		warmTarget, -- 127
		clamp01(warmth) -- 127
	) -- 127
	return toColor( -- 128
		mixed, -- 128
		math.floor(mixed.a * clamp01(opacity) + 0.5) -- 128
	) -- 128
end -- 120
--- 统一「补过一道浅线的青布袖口」视觉组件：
-- P03 擦碎瓷、P05 城门拉袖、G05 风台重逢 与 Wave 2 E02 博物馆回柜四镜严格共用本函数。
function ____exports.drawPatchedCuff(draw, glow, opts) -- 135
	local op = clamp01(opts.opacity or 1) -- 140
	if op <= 0.01 then -- 140
		return -- 142
	end -- 142
	local ox = opts.wristX -- 144
	local oy = opts.wristY -- 145
	local s = math.max(0.2, opts.scale) -- 146
	local cosA = math.cos(opts.angleRad) -- 147
	local sinA = math.sin(opts.angleRad) -- 148
	local w = clamp01(opts.warmth or 0) -- 149
	local pull = clamp01(opts.cuffPullBack or 0) * 28 -- 150
	local function pt(lx, ly) -- 151
		return rotPt( -- 151
			ox, -- 151
			oy, -- 151
			lx, -- 151
			ly, -- 151
			cosA, -- 151
			sinA, -- 151
			s -- 151
		) -- 151
	end -- 151
	local hl = clamp01(opts.stitchHighlight or 0.25) -- 152
	if opts.uiArt ~= nil then -- 152
		local framePath = (opts.pose == "clasp" or opts.pose == "pinch") and "assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp" or "assets/art/cutscene_cuff_rig.clip|cuff_zhou_open" -- 156
		local key = opts.instanceKey or "patched_cuff_zhou" -- 159
		local spriteW = 368 * s -- 160
		local spriteH = 166 * s -- 161
		local anchorOffset = pull * 0.55 -- 162
		local placedPos = pt(-anchorOffset, 0) -- 163
		local tintCol = tinted( -- 164
			rgba(232, 238, 246, 255), -- 164
			w * 0.72, -- 164
			1 -- 164
		) -- 164
		if opts.uiArt:tryPlacePath( -- 164
			framePath, -- 165
			key, -- 165
			placedPos.x, -- 165
			placedPos.y, -- 165
			spriteW, -- 165
			spriteH, -- 165
			{ -- 165
				anchorX = 0.57, -- 166
				anchorY = 0.5, -- 167
				angle = -(opts.angleRad * 180) / math.pi, -- 168
				color = tintCol, -- 169
				opacity = op, -- 170
				smooth = true, -- 171
				layer = opts.layer or 4 -- 172
			} -- 172
		) then -- 172
			if hl > 0.08 then -- 172
				local stitchPos = pt(-58 - anchorOffset, -6) -- 175
				fillRadialGlow( -- 176
					glow, -- 177
					stitchPos.x, -- 178
					stitchPos.y, -- 179
					36 * s, -- 180
					22 * s, -- 181
					toColor( -- 182
						____exports.CUFF_PALETTE.stitchThread, -- 182
						math.floor(52 * hl * op + 0.5) -- 182
					), -- 182
					toColor(____exports.CUFF_PALETTE.stitchThread, 0), -- 183
					12 -- 184
				) -- 184
			end -- 184
			return -- 187
		end -- 187
	end -- 187
	local cuffFront = 6 - pull -- 192
	draw:drawPolygon( -- 193
		{ -- 193
			pt(-250, -48), -- 194
			pt(cuffFront, -36), -- 195
			pt(cuffFront, 38), -- 196
			pt(-250, 52) -- 197
		}, -- 197
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 198
		1.4, -- 198
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 198
	) -- 198
	draw:drawPolygon( -- 201
		{ -- 201
			pt(-250, -48), -- 202
			pt(cuffFront, -36), -- 203
			pt(cuffFront, -8), -- 204
			pt(-250, -14) -- 205
		}, -- 205
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.88) -- 206
	) -- 206
	draw:drawPolygon( -- 209
		{ -- 209
			pt(-230, 14), -- 210
			pt(cuffFront - 6, 10), -- 211
			pt(cuffFront - 4, 32), -- 212
			pt(-230, 40) -- 213
		}, -- 213
		tinted(____exports.CUFF_PALETTE.indigoFold, w, op * 0.52) -- 214
	) -- 214
	draw:drawSegment( -- 215
		pt(-185, 16), -- 215
		pt(cuffFront - 18, 12), -- 215
		1.2 * s, -- 215
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.55) -- 215
	) -- 215
	draw:drawSegment( -- 216
		pt(-160, -10), -- 216
		pt(cuffFront - 26, -6), -- 216
		1.1 * s, -- 216
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op * 0.75) -- 216
	) -- 216
	draw:drawPolygon( -- 219
		{ -- 219
			pt(cuffFront - 8, -28), -- 220
			pt(cuffFront + 16, -24), -- 221
			pt(cuffFront + 16, 26), -- 222
			pt(cuffFront - 8, 28) -- 223
		}, -- 223
		tinted(____exports.CUFF_PALETTE.armWrapLinen, w, op), -- 224
		1, -- 224
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op) -- 224
	) -- 224
	draw:drawSegment( -- 225
		pt(cuffFront + 3, -25), -- 225
		pt(cuffFront + 7, 25), -- 225
		1.3 * s, -- 225
		tinted(____exports.CUFF_PALETTE.armWrapShadow, w, op * 0.72) -- 225
	) -- 225
	draw:drawPolygon( -- 228
		{ -- 228
			pt(cuffFront - 16, -37), -- 229
			pt(cuffFront + 2, -36), -- 230
			pt(cuffFront + 2, 38), -- 231
			pt(cuffFront - 16, 39) -- 232
		}, -- 232
		tinted(____exports.CUFF_PALETTE.indigoBase, w, op), -- 233
		1.3, -- 233
		tinted(____exports.CUFF_PALETTE.hemEdge, w, op * 0.85) -- 233
	) -- 233
	local pX0 = cuffFront - 72 -- 236
	local pX1 = cuffFront - 18 -- 237
	local pY0 = -16 -- 238
	local pY1 = 22 -- 239
	draw:drawPolygon( -- 240
		{ -- 240
			pt(pX0, pY0), -- 241
			pt(pX1, pY0 + 3), -- 242
			pt(pX1 - 2, pY1), -- 243
			pt(pX0 + 3, pY1 - 2) -- 244
		}, -- 244
		tinted(____exports.CUFF_PALETTE.patchDark, w, op), -- 245
		1.1, -- 245
		tinted(____exports.CUFF_PALETTE.indigoShadow, w, op) -- 245
	) -- 245
	local seamStartX = pX0 + 6 -- 248
	local seamStartY = pY0 + 5 -- 249
	local seamEndX = pX1 - 7 -- 250
	local seamEndY = pY1 - 5 -- 251
	draw:drawSegment( -- 252
		pt(seamStartX, seamStartY), -- 253
		pt(seamEndX, seamEndY), -- 254
		1.5 * s, -- 255
		tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 256
	) -- 256
	local stitchCol = tinted(____exports.CUFF_PALETTE.stitchThread, w * 0.4, op) -- 259
	local pinCol = tinted(____exports.CUFF_PALETTE.stitchPinhole, w, op * 0.92) -- 260
	local stitches = 6 -- 261
	local k = 0 -- 262
	do -- 262
		k = 0 -- 263
		while k < stitches do -- 263
			local t = (k + 0.5) / stitches -- 264
			local mx = seamStartX + (seamEndX - seamStartX) * t -- 265
			local my = seamStartY + (seamEndY - seamStartY) * t -- 266
			local nx = -4.8 -- 267
			local ny = 6.2 -- 268
			local a = pt(mx - nx, my - ny) -- 269
			local b = pt(mx + nx, my + ny) -- 270
			draw:drawDot(a, 1.3 * s, pinCol) -- 271
			draw:drawDot(b, 1.3 * s, pinCol) -- 272
			draw:drawSegment(a, b, 2 * s, stitchCol) -- 273
			if hl > 0.05 then -- 273
				glow:drawSegment( -- 275
					a, -- 275
					b, -- 275
					2.4 * s, -- 275
					toColor( -- 275
						____exports.CUFF_PALETTE.stitchThread, -- 275
						math.floor(74 * hl * op + 0.5) -- 275
					) -- 275
				) -- 275
			end -- 275
			k = k + 1 -- 263
		end -- 263
	end -- 263
	local handBase = cuffFront + 14 -- 280
	local skinCol = tinted(____exports.CUFF_PALETTE.skinBase, w, op) -- 281
	local skinSh = tinted(____exports.CUFF_PALETTE.skinShadow, w, op) -- 282
	local skinHi = tinted(____exports.CUFF_PALETTE.skinLight, w, op * 0.85) -- 283
	if opts.pose == "wipe" then -- 283
		draw:drawPolygon( -- 287
			{ -- 287
				pt(handBase - 4, -20), -- 288
				pt(handBase + 46, -24), -- 289
				pt(handBase + 54, 4), -- 290
				pt(handBase + 38, 22), -- 291
				pt(handBase - 4, 20) -- 292
			}, -- 292
			skinCol, -- 293
			1.1, -- 293
			skinSh -- 293
		) -- 293
		draw:drawSegment( -- 294
			pt(handBase + 16, -2), -- 294
			pt(handBase + 52, -6), -- 294
			1.4 * s, -- 294
			skinSh -- 294
		) -- 294
		draw:drawSegment( -- 295
			pt(handBase + 14, 10), -- 295
			pt(handBase + 46, 8), -- 295
			1.4 * s, -- 295
			skinSh -- 295
		) -- 295
	elseif opts.pose == "pinch" then -- 295
		draw:drawPolygon( -- 298
			{ -- 298
				pt(handBase - 4, -22), -- 299
				pt(handBase + 44, -18), -- 300
				pt(handBase + 54, 6), -- 301
				pt(handBase + 28, 26), -- 302
				pt(handBase - 4, 22) -- 303
			}, -- 303
			skinCol, -- 304
			1.1, -- 304
			skinSh -- 304
		) -- 304
		draw:drawSegment( -- 305
			pt(handBase + 24, 16), -- 305
			pt(handBase + 52, 4), -- 305
			6.2 * s, -- 305
			skinHi -- 305
		) -- 305
		draw:drawSegment( -- 306
			pt(handBase + 30, -14), -- 306
			pt(handBase + 54, -4), -- 306
			5.6 * s, -- 306
			skinCol -- 306
		) -- 306
	elseif opts.pose == "clasp" then -- 306
		draw:drawPolygon( -- 309
			{ -- 309
				pt(handBase - 2, -22), -- 310
				pt(handBase + 52, -20), -- 311
				pt(handBase + 66, 2), -- 312
				pt(handBase + 44, 26), -- 313
				pt(handBase - 2, 22) -- 314
			}, -- 314
			skinCol, -- 315
			1.2, -- 315
			skinSh -- 315
		) -- 315
		draw:drawSegment( -- 316
			pt(handBase + 26, 20), -- 316
			pt(handBase + 58, 12), -- 316
			6.5 * s, -- 316
			skinHi -- 316
		) -- 316
		draw:drawSegment( -- 317
			pt(handBase + 46, -14), -- 317
			pt(handBase + 72, -10), -- 317
			5.2 * s, -- 317
			skinCol -- 317
		) -- 317
		draw:drawSegment( -- 318
			pt(handBase + 48, -2), -- 318
			pt(handBase + 76, 1), -- 318
			5.4 * s, -- 318
			skinCol -- 318
		) -- 318
	else -- 318
		local reachExt = opts.pose == "reach" and 10 or 0 -- 321
		draw:drawPolygon( -- 322
			{ -- 322
				pt(handBase - 4, -20), -- 323
				pt(handBase + 44 + reachExt, -18), -- 324
				pt(handBase + 56 + reachExt, 4), -- 325
				pt(handBase + 34 + reachExt * 0.5, 24), -- 326
				pt(handBase - 4, 20) -- 327
			}, -- 327
			skinCol, -- 328
			1.1, -- 328
			skinSh -- 328
		) -- 328
		draw:drawSegment( -- 330
			pt(handBase + 42 + reachExt, -14), -- 330
			pt(handBase + 74 + reachExt, -16), -- 330
			4.6 * s, -- 330
			skinCol -- 330
		) -- 330
		draw:drawSegment( -- 331
			pt(handBase + 46 + reachExt, -4), -- 331
			pt(handBase + 80 + reachExt, -3), -- 331
			4.8 * s, -- 331
			skinCol -- 331
		) -- 331
		draw:drawSegment( -- 332
			pt(handBase + 44 + reachExt, 6), -- 332
			pt(handBase + 76 + reachExt, 9), -- 332
			4.6 * s, -- 332
			skinCol -- 332
		) -- 332
		draw:drawSegment( -- 333
			pt(handBase + 26 + reachExt * 0.5, 18), -- 333
			pt(handBase + 56 + reachExt * 0.6, 28), -- 333
			5.2 * s, -- 333
			skinHi -- 333
		) -- 333
	end -- 333
end -- 135
--- 绘制小满伸出的小手（优先使用手绘 cutscene_cuff_rig.clip 幼童红袄手腕部件）
local function drawChildHand(draw, ox, oy, angleRad, scale, pose, opacity, withCompassCord, uiArt, instanceKey, layer) -- 338
	if withCompassCord == nil then -- 338
		withCompassCord = true -- 346
	end -- 346
	if instanceKey == nil then -- 346
		instanceKey = "cuff_child_hand" -- 348
	end -- 348
	if layer == nil then -- 348
		layer = 5 -- 349
	end -- 349
	local op = clamp01(opacity) -- 351
	if op <= 0.01 then -- 351
		return -- 353
	end -- 353
	local s = math.max(0.2, scale) -- 355
	if uiArt ~= nil then -- 355
		if pose == "two_fingers" then -- 355
			if uiArt:tryPlacePath( -- 355
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_peek", -- 359
				instanceKey .. "_peek", -- 360
				ox, -- 361
				oy, -- 362
				116 * s, -- 363
				134 * s, -- 364
				{ -- 365
					anchorX = 0.5, -- 366
					anchorY = 0.16, -- 367
					angle = 90, -- 368
					opacity = op, -- 369
					smooth = true, -- 370
					layer = layer -- 371
				} -- 371
			) then -- 371
				return -- 374
			end -- 374
		else -- 374
			local relDeg = -((angleRad - math.pi) * 180) / math.pi -- 377
			if uiArt:tryPlacePath( -- 377
				"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 379
				instanceKey .. "_reach", -- 380
				ox, -- 381
				oy, -- 382
				298 * s, -- 383
				132 * s, -- 384
				{ -- 385
					anchorX = 0.43, -- 386
					anchorY = 0.52, -- 387
					angle = relDeg, -- 388
					opacity = op, -- 389
					smooth = true, -- 390
					layer = layer -- 391
				} -- 391
			) then -- 391
				if withCompassCord then -- 391
					local cosA = math.cos(angleRad) -- 395
					local sinA = math.sin(angleRad) -- 396
					local p1 = rotPt( -- 397
						ox, -- 397
						oy, -- 397
						-12, -- 397
						-16, -- 397
						cosA, -- 397
						sinA, -- 397
						s -- 397
					) -- 397
					local p2 = rotPt( -- 398
						ox, -- 398
						oy, -- 398
						-6, -- 398
						16, -- 398
						cosA, -- 398
						sinA, -- 398
						s -- 398
					) -- 398
					draw:drawSegment( -- 399
						p1, -- 399
						p2, -- 399
						2.2 * s, -- 399
						toColor( -- 399
							____exports.CUFF_PALETTE.childCord, -- 399
							math.floor(165 * op + 0.5) -- 399
						) -- 399
					) -- 399
				end -- 399
				return -- 401
			end -- 401
		end -- 401
	end -- 401
	local cosA = math.cos(angleRad) -- 406
	local sinA = math.sin(angleRad) -- 407
	local function pt(lx, ly) -- 408
		return rotPt( -- 408
			ox, -- 408
			oy, -- 408
			lx, -- 408
			ly, -- 408
			cosA, -- 408
			sinA, -- 408
			s -- 408
		) -- 408
	end -- 408
	local skin = toColor( -- 409
		____exports.CUFF_PALETTE.childSkin, -- 409
		math.floor(255 * op + 0.5) -- 409
	) -- 409
	local sh = toColor( -- 410
		____exports.CUFF_PALETTE.childSkinShadow, -- 410
		math.floor(255 * op + 0.5) -- 410
	) -- 410
	local sleeve = toColor( -- 411
		____exports.CUFF_PALETTE.childSleeve, -- 411
		math.floor(255 * op + 0.5) -- 411
	) -- 411
	if pose == "two_fingers" then -- 411
		draw:drawSegment( -- 415
			pt(-18, -4), -- 415
			pt(18, -5), -- 415
			5 * s, -- 415
			skin -- 415
		) -- 415
		draw:drawSegment( -- 416
			pt(-16, 6), -- 416
			pt(22, 7), -- 416
			5 * s, -- 416
			skin -- 416
		) -- 416
		draw:drawDot( -- 417
			pt(18, -5), -- 417
			2.5 * s, -- 417
			sh -- 417
		) -- 417
		draw:drawDot( -- 418
			pt(22, 7), -- 418
			2.5 * s, -- 418
			sh -- 418
		) -- 418
		return -- 419
	end -- 419
	draw:drawPolygon( -- 423
		{ -- 423
			pt(-135, -24), -- 424
			pt(-6, -18), -- 425
			pt(-6, 18), -- 426
			pt(-135, 26) -- 427
		}, -- 427
		sleeve, -- 428
		1.1, -- 428
		sh -- 428
	) -- 428
	if withCompassCord then -- 428
		draw:drawSegment( -- 432
			pt(-10, -18), -- 432
			pt(-4, 18), -- 432
			2.6 * s, -- 432
			toColor( -- 432
				____exports.CUFF_PALETTE.childCord, -- 432
				math.floor(235 * op + 0.5) -- 432
			) -- 432
		) -- 432
		draw:drawSegment( -- 433
			pt(-4, -18), -- 433
			pt(2, 18), -- 433
			2.2 * s, -- 433
			toColor( -- 433
				____exports.CUFF_PALETTE.childCord, -- 433
				math.floor(200 * op + 0.5) -- 433
			) -- 433
		) -- 433
	end -- 433
	draw:drawPolygon( -- 437
		{ -- 437
			pt(-4, -15), -- 438
			pt(28, -14), -- 439
			pt(34, 2), -- 440
			pt(22, 17), -- 441
			pt(-4, 15) -- 442
		}, -- 442
		skin, -- 443
		1, -- 443
		sh -- 443
	) -- 443
	if pose == "clutch" or pose == "clasp" then -- 443
		draw:drawSegment( -- 447
			pt(24, -11), -- 447
			pt(44, -6), -- 447
			4 * s, -- 447
			skin -- 447
		) -- 447
		draw:drawSegment( -- 448
			pt(26, -2), -- 448
			pt(47, 2), -- 448
			4.2 * s, -- 448
			skin -- 448
		) -- 448
		draw:drawSegment( -- 449
			pt(24, 6), -- 449
			pt(43, 9), -- 449
			4 * s, -- 449
			skin -- 449
		) -- 449
		draw:drawSegment( -- 450
			pt(16, 14), -- 450
			pt(34, 16), -- 450
			4.2 * s, -- 450
			skin -- 450
		) -- 450
	else -- 450
		draw:drawSegment( -- 453
			pt(26, -12), -- 453
			pt(52, -16), -- 453
			3.6 * s, -- 453
			skin -- 453
		) -- 453
		draw:drawSegment( -- 454
			pt(29, -4), -- 454
			pt(57, -5), -- 454
			3.8 * s, -- 454
			skin -- 454
		) -- 454
		draw:drawSegment( -- 455
			pt(28, 4), -- 455
			pt(54, 7), -- 455
			3.6 * s, -- 455
			skin -- 455
		) -- 455
		draw:drawSegment( -- 456
			pt(24, 11), -- 456
			pt(46, 17), -- 456
			3.4 * s, -- 456
			skin -- 456
		) -- 456
		draw:drawSegment( -- 457
			pt(14, 15), -- 457
			pt(34, 26), -- 457
			4 * s, -- 457
			skin -- 457
		) -- 457
	end -- 457
end -- 338
--- 仅在 G05 重逢抬镜后绘制全幅冷月蹲姿周戍重逢插画（去生硬小弹窗框，自然融于全屏遮幅）
local function drawZhouShuReunionPortrait(draw, _inkDraw, art, glow, w, h, tiltOffsetY, alpha) -- 462
	local a = clamp01(alpha) -- 472
	if a <= 0.01 then -- 472
		return -- 474
	end -- 474
	local barH = math.floor(h * 0.068 + 0.5) -- 476
	local viewH = math.max(120, h - barH * 2) -- 477
	local scaleCover = math.max(w / 960, (viewH + 40) / 540) -- 478
	local imgW = 960 * scaleCover -- 479
	local imgH = 540 * scaleCover -- 480
	local cy = h * 0.5 - tiltOffsetY -- 481
	local placed = art:tryPlacePath( -- 483
		"assets/art/cg_g05_reunion.png", -- 484
		"g05_zhoushu_reunion_cg", -- 485
		w * 0.5, -- 486
		cy, -- 487
		imgW, -- 488
		imgH, -- 489
		{ -- 490
			anchorX = 0.5, -- 491
			anchorY = 0.5, -- 492
			opacity = a, -- 493
			smooth = true, -- 494
			layer = 1 -- 495
		} -- 495
	) -- 495
	if not placed then -- 495
		fillVGradRect( -- 499
			draw, -- 500
			0, -- 501
			barH, -- 502
			w, -- 503
			viewH, -- 504
			Color( -- 505
				10, -- 505
				15, -- 505
				24, -- 505
				math.floor(230 * a + 0.5) -- 505
			), -- 505
			Color( -- 506
				22, -- 506
				34, -- 506
				52, -- 506
				math.floor(238 * a + 0.5) -- 506
			) -- 506
		) -- 506
		art:tryPlace( -- 508
			"soldier_offer", -- 509
			"g05_zhoushu_closeup", -- 510
			w * 0.58, -- 511
			barH + 20, -- 512
			190, -- 513
			260, -- 514
			{opacity = a, layer = 2} -- 515
		) -- 515
	end -- 515
	fillVGradRect( -- 519
		draw, -- 519
		0, -- 519
		barH, -- 519
		w, -- 519
		72, -- 519
		Color( -- 519
			6, -- 519
			9, -- 519
			14, -- 519
			math.floor(145 * a + 0.5) -- 519
		), -- 519
		Color(6, 9, 14, 0) -- 519
	) -- 519
	fillVGradRect( -- 520
		draw, -- 520
		0, -- 520
		h - barH - 64, -- 520
		w, -- 520
		64, -- 520
		Color(6, 9, 14, 0), -- 520
		Color( -- 520
			6, -- 520
			9, -- 520
			14, -- 520
			math.floor(135 * a + 0.5) -- 520
		) -- 520
	) -- 520
	fillRadialGlow( -- 521
		glow, -- 521
		w * 0.54, -- 521
		h * 0.58, -- 521
		w * 0.34, -- 521
		h * 0.34, -- 521
		Color( -- 521
			196, -- 521
			214, -- 521
			232, -- 521
			math.floor(32 * a + 0.5) -- 521
		), -- 521
		Color(110, 142, 174, 0), -- 521
		16 -- 521
	) -- 521
end -- 462
____exports.CuffShotsPlugin = __TS__Class() -- 524
local CuffShotsPlugin = ____exports.CuffShotsPlugin -- 524
CuffShotsPlugin.name = "CuffShotsPlugin" -- 524
function CuffShotsPlugin.prototype.____constructor(self) -- 524
	self.id = "fe-01-cuff-shots" -- 525
	self.animTime = 0 -- 527
	self.prevPhase = "" -- 528
	self.activeShot = "" -- 529
	self.rehearsalShot = "" -- 532
	self.rehearsalTime = 0 -- 533
	self.rehearsalDuration = 3 -- 534
	self.rehearsalAutoAdvance = true -- 535
	self.p03Progress = 0 -- 538
	self.p05ExitTimer = -1 -- 539
	self.g05SleeveExtend = 0 -- 540
	self.g05ReunionElapsed = 0 -- 541
	self.g05LineTriggered = false -- 542
	self.g05AbortVisualCount = 0 -- 543
	self.lastReleasedAbortCount = 0 -- 544
end -- 524
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 546
	self.animTime = 0 -- 547
	self.prevPhase = p.phase -- 548
	self.activeShot = "" -- 549
	self.p03Progress = 0 -- 550
	self.p05ExitTimer = -1 -- 551
	self.g05SleeveExtend = 0 -- 552
	self.g05ReunionElapsed = 0 -- 553
	self.g05LineTriggered = false -- 554
	self.g05AbortVisualCount = 0 -- 555
	self.lastReleasedAbortCount = 0 -- 556
end -- 546
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 564
	self.rehearsalShot = shot -- 565
	if shot == "" then -- 565
		self.rehearsalTime = 0 -- 567
		self.rehearsalAutoAdvance = true -- 568
		return -- 569
	end -- 569
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 571
	if fixedTime ~= nil then -- 571
		self.rehearsalTime = math.max( -- 573
			0, -- 573
			math.min(self.rehearsalDuration, fixedTime) -- 573
		) -- 573
		self.rehearsalAutoAdvance = false -- 574
	else -- 574
		self.rehearsalTime = 0 -- 576
		self.rehearsalAutoAdvance = true -- 577
	end -- 577
end -- 564
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 581
	self:rehearseShot("") -- 582
end -- 581
function CuffShotsPlugin.prototype.getDebugState(self) -- 585
	return { -- 586
		activeShot = self.activeShot, -- 587
		rehearsalShot = self.rehearsalShot, -- 588
		rehearsalTime = self.rehearsalTime, -- 589
		rehearsalDuration = self.rehearsalDuration, -- 590
		p03Progress = self.p03Progress, -- 591
		p05ExitTimer = self.p05ExitTimer, -- 592
		g05SleeveExtend = self.g05SleeveExtend, -- 593
		g05ReunionElapsed = self.g05ReunionElapsed, -- 594
		g05LineTriggered = self.g05LineTriggered, -- 595
		g05AbortVisualCount = self.g05AbortVisualCount -- 596
	} -- 596
end -- 585
function CuffShotsPlugin.prototype.update(self, ctx) -- 600
	local p = ctx.p -- 601
	local view = ctx.view -- 602
	local dt = ctx.paused and 0 or ctx.worldDt -- 603
	self.animTime = self.animTime + dt -- 604
	if self.rehearsalShot ~= "" then -- 604
		self.activeShot = self.rehearsalShot -- 608
		if self.rehearsalAutoAdvance and dt > 0 then -- 608
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 610
		end -- 610
		if not ctx.paused then -- 610
			self:triggerRehearsalAudio(ctx) -- 613
		end -- 613
		self.prevPhase = p.phase -- 615
		return -- 616
	end -- 616
	self.activeShot = "" -- 619
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 619
		self.activeShot = "P03" -- 623
		self.p03Progress = clamp01(p.phaseTick / 60) -- 624
		if not ctx.paused and self.p03Progress >= 0.25 then -- 624
			ctx.audio:playOnce( -- 626
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 627
				"sfx", -- 628
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 629
				0.86, -- 630
				"cuff:p03:cloth_wipe_wood", -- 631
				p.ticks -- 632
			) -- 632
		end -- 632
		if not ctx.paused and self.p03Progress >= 0.62 then -- 632
			ctx.audio:playOnce( -- 636
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 637
				"sfx", -- 638
				"assets/audio/interact/compass_handover.wav", -- 639
				0.82, -- 640
				"cuff:p03:compass_handover", -- 641
				p.ticks -- 642
			) -- 642
		end -- 642
		self.prevPhase = p.phase -- 645
		return -- 646
	else -- 646
		self.p03Progress = 0 -- 648
	end -- 648
	if p.room.key == "gate" then -- 648
		if self.prevPhase == "gate-send" and p.phase == "gate-count" and view.countElapsedTicks <= 8 then -- 648
			self.p05ExitTimer = 0 -- 654
			if not ctx.paused then -- 654
				ctx.audio:playOnce( -- 656
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 657
					"sfx", -- 658
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 659
					0.92, -- 660
					"cuff:p05:gate_slam", -- 661
					p.ticks -- 662
				) -- 662
				ctx.audio:playOnce( -- 664
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 665
					"voice", -- 666
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 667
					0.88, -- 668
					"cuff:p05:line_farewell", -- 669
					p.ticks -- 670
				) -- 670
			end -- 670
		end -- 670
		if self.p05ExitTimer >= 0 then -- 670
			if p.phase ~= "gate-count" or view.countElapsedTicks > 240 then -- 670
				self.p05ExitTimer = -1 -- 676
			else -- 676
				if dt > 0 then -- 676
					self.p05ExitTimer = self.p05ExitTimer + dt -- 679
				end -- 679
				if self.p05ExitTimer >= 3.6 then -- 679
					self.p05ExitTimer = -1 -- 682
				else -- 682
					self.activeShot = "P05" -- 684
				end -- 684
			end -- 684
		end -- 684
	else -- 684
		self.p05ExitTimer = -1 -- 689
	end -- 689
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 693
	if inGateReunion then -- 693
		self.activeShot = "G05" -- 701
		local gr = view.gateReunion -- 702
		local completed = p.phase == "gate-hand" or gr.completed -- 703
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 703
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 706
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 707
			if not ctx.paused and view.isRehearsal then -- 707
				ctx.audio:playOnce( -- 709
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 710
					"sfx", -- 711
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 712
					0.72, -- 713
					"cuff:g05:reunion_release", -- 714
					p.ticks -- 715
				) -- 715
			end -- 715
		end -- 715
		if completed then -- 715
			self.g05SleeveExtend = 1 -- 721
			if dt > 0 then -- 721
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 723
			end -- 723
			if not ctx.paused and not self.g05LineTriggered then -- 723
				if view.isRehearsal then -- 723
					ctx.audio:playOnce( -- 727
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 728
						"sfx", -- 729
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 730
						0.88, -- 731
						"cuff:g05:hand_held", -- 732
						p.ticks -- 733
					) -- 733
				end -- 733
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 733
					self.g05LineTriggered = true -- 737
					ctx.audio:playOnce( -- 738
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 739
						"voice", -- 740
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 741
						0.94, -- 742
						"cuff:g05:line_reunion", -- 743
						p.ticks -- 744
					) -- 744
				end -- 744
			end -- 744
		else -- 744
			self.g05ReunionElapsed = 0 -- 749
			self.g05LineTriggered = false -- 750
			if gr.holding or gr.holdProgress > 0.001 then -- 750
				if gr.holdProgress >= self.g05SleeveExtend then -- 750
					self.g05SleeveExtend = gr.holdProgress -- 754
				elseif dt > 0 then -- 754
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 756
				end -- 756
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 756
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 760
			end -- 760
		end -- 760
	else -- 760
		self.g05SleeveExtend = 0 -- 764
		self.g05ReunionElapsed = 0 -- 765
		self.g05LineTriggered = false -- 766
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 767
	end -- 767
	self.prevPhase = p.phase -- 770
end -- 600
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 773
	local sid = ctx.events.roomSessionId -- 774
	local t = self.rehearsalTime -- 775
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 775
		ctx.audio:playOnce( -- 777
			"reh:p03:wipe:" .. tostring(sid), -- 777
			"sfx", -- 777
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 777
			0.88, -- 777
			"cuff:p03:cloth_wipe_wood", -- 777
			ctx.p.ticks -- 777
		) -- 777
	elseif self.rehearsalShot == "P05" then -- 777
		if t >= 0.9 then -- 777
			ctx.audio:playOnce( -- 780
				"reh:p05:line:" .. tostring(sid), -- 780
				"voice", -- 780
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 780
				0.9, -- 780
				"cuff:p05:line_farewell", -- 780
				ctx.p.ticks -- 780
			) -- 780
		end -- 780
		if t >= 2.75 then -- 780
			ctx.audio:playOnce( -- 783
				"reh:p05:slam:" .. tostring(sid), -- 783
				"sfx", -- 783
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 783
				0.94, -- 783
				"cuff:p05:gate_slam", -- 783
				ctx.p.ticks -- 783
			) -- 783
			ctx.audio:playLoop( -- 784
				"reh_p05_water", -- 784
				"water", -- 784
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 784
				0.42, -- 784
				ctx.p.ticks -- 784
			) -- 784
		end -- 784
	elseif self.rehearsalShot == "G05" then -- 784
		if t >= 0.05 then -- 784
			ctx.audio:playOnce( -- 788
				"reh:g05:knock1:" .. tostring(sid), -- 788
				"sfx", -- 788
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 788
				0.88, -- 788
				"knock:gate:1", -- 788
				ctx.p.ticks -- 788
			) -- 788
		end -- 788
		if t >= 0.25 then -- 788
			ctx.audio:playOnce( -- 791
				"reh:g05:knock2:" .. tostring(sid), -- 791
				"sfx", -- 791
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 791
				0.92, -- 791
				"knock:gate:2", -- 791
				ctx.p.ticks -- 791
			) -- 791
		end -- 791
		if t >= 1.55 then -- 791
			ctx.audio:playOnce( -- 794
				"reh:g05:clasp:" .. tostring(sid), -- 794
				"sfx", -- 794
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 794
				0.88, -- 794
				"cuff:g05:hand_held", -- 794
				ctx.p.ticks -- 794
			) -- 794
		end -- 794
		if t >= 2.35 then -- 794
			ctx.audio:playOnce( -- 797
				"reh:g05:line:" .. tostring(sid), -- 797
				"voice", -- 797
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 797
				0.94, -- 797
				"cuff:g05:line_reunion", -- 797
				ctx.p.ticks -- 797
			) -- 797
		end -- 797
	end -- 797
end -- 773
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 802
	if self.activeShot == "" then -- 802
		return false -- 810
	end -- 810
	local w = ctx.uiW -- 812
	local h = ctx.uiH -- 813
	if self.activeShot == "P03" then -- 813
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 816
		self:renderP03Shot( -- 819
			uiDraw, -- 819
			uiInkDraw, -- 819
			uiArt, -- 819
			uiGlow, -- 819
			ctx, -- 819
			w, -- 819
			h, -- 819
			prog -- 819
		) -- 819
		return true -- 820
	end -- 820
	if self.activeShot == "P05" then -- 820
		if self.rehearsalShot == "P05" then -- 820
			local prog = clamp01(self.rehearsalTime / self.rehearsalDuration) -- 825
			self:renderP05FullShot( -- 826
				uiDraw, -- 826
				uiInkDraw, -- 826
				uiArt, -- 826
				uiGlow, -- 826
				ctx, -- 826
				w, -- 826
				h, -- 826
				prog -- 826
			) -- 826
			return true -- 827
		end -- 827
		self:renderP05ExitBridge( -- 830
			uiDraw, -- 830
			uiInkDraw, -- 830
			uiArt, -- 830
			uiGlow, -- 830
			ctx, -- 830
			w, -- 830
			h, -- 830
			clamp01(self.p05ExitTimer / 3.6) -- 830
		) -- 830
		return false -- 831
	end -- 831
	if self.activeShot == "G05" then -- 831
		if self.rehearsalShot == "G05" then -- 831
			self:renderG05RehearsalShot( -- 836
				uiDraw, -- 836
				uiInkDraw, -- 836
				uiArt, -- 836
				uiGlow, -- 836
				ctx, -- 836
				w, -- 836
				h, -- 836
				self.rehearsalTime -- 836
			) -- 836
			return true -- 837
		end -- 837
		self:renderG05LiveShot( -- 839
			uiDraw, -- 839
			uiInkDraw, -- 839
			uiArt, -- 839
			uiGlow, -- 839
			ctx, -- 839
			w, -- 839
			h -- 839
		) -- 839
		return true -- 840
	end -- 840
	return false -- 843
end -- 802
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 852
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 862
	local barH = math.floor(h * 0.075 + 0.5) -- 864
	local bx = 0 -- 865
	local by = barH -- 866
	local boxW = w -- 867
	local boxH = math.max(120, h - barH * 2) -- 868
	uiDraw:drawRect( -- 870
		Rect(0, 0, w, h), -- 870
		Color( -- 870
			7, -- 870
			9, -- 870
			14, -- 870
			math.floor(232 * fade + 0.5) -- 870
		) -- 870
	) -- 870
	fillVGradRect( -- 871
		uiDraw, -- 871
		bx, -- 871
		by, -- 871
		boxW, -- 871
		boxH, -- 871
		Color( -- 871
			12, -- 871
			11, -- 871
			15, -- 871
			math.floor(248 * fade + 0.5) -- 871
		), -- 871
		Color( -- 871
			22, -- 871
			22, -- 871
			28, -- 871
			math.floor(248 * fade + 0.5) -- 871
		) -- 871
	) -- 871
	local rimY = by + boxH * 0.36 -- 873
	uiArt:tryPlacePath( -- 874
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 874
		"p03_cabinet_rim_tex", -- 874
		w * 0.5, -- 874
		(by + rimY) * 0.5, -- 874
		w, -- 874
		math.max(12, rimY - by), -- 874
		{ -- 874
			color = Color(126, 104, 86, 255), -- 875
			opacity = 0.92 * fade, -- 876
			smooth = true, -- 877
			layer = 1 -- 878
		} -- 878
	) -- 878
	uiDraw:drawSegment( -- 880
		Vec2(bx, rimY), -- 880
		Vec2(bx + boxW, rimY), -- 880
		2.2, -- 880
		Color( -- 880
			142, -- 880
			114, -- 880
			88, -- 880
			math.floor(215 * fade + 0.5) -- 880
		) -- 880
	) -- 880
	local crackX = bx + boxW * 0.72 -- 882
	uiDraw:drawRect( -- 883
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 883
		Color( -- 883
			6, -- 883
			7, -- 883
			11, -- 883
			math.floor(248 * fade + 0.5) -- 883
		) -- 883
	) -- 883
	uiArt:tryPlacePath( -- 884
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 884
		"p03_cabinet_door_tex", -- 884
		crackX + 40 + (boxW - (crackX + 40)) * 0.5, -- 884
		rimY + (by + boxH - rimY) * 0.5, -- 884
		math.max(12, boxW - (crackX + 40)), -- 884
		math.max(12, by + boxH - rimY), -- 884
		{ -- 884
			color = Color(96, 78, 62, 255), -- 885
			opacity = 0.98 * fade, -- 886
			smooth = true, -- 887
			layer = 5 -- 888
		} -- 888
	) -- 888
	fillRadialGlow( -- 890
		uiGlow, -- 890
		crackX - 18, -- 890
		rimY + 42, -- 890
		190, -- 890
		120, -- 890
		Color( -- 890
			166, -- 890
			192, -- 890
			218, -- 890
			math.floor(48 * fade + 0.5) -- 890
		), -- 890
		Color(64, 92, 124, 0), -- 890
		16 -- 890
	) -- 890
	local wipeT = smoothstep(0.3, 0.66, prog) -- 893
	local shardOffsets = {{ -- 894
		x = -72, -- 895
		y = 8, -- 895
		dx = 46, -- 895
		dy = -38, -- 895
		r = 9 -- 895
	}, { -- 895
		x = -34, -- 896
		y = 12, -- 896
		dx = 64, -- 896
		dy = -46, -- 896
		r = 7 -- 896
	}, { -- 896
		x = 4, -- 897
		y = 6, -- 897
		dx = 82, -- 897
		dy = -52, -- 897
		r = 10 -- 897
	}, { -- 897
		x = 32, -- 898
		y = 10, -- 898
		dx = 74, -- 898
		dy = -34, -- 898
		r = 6 -- 898
	}} -- 898
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 900
	if shardAlpha > 0.02 then -- 900
		local si = 0 -- 902
		do -- 902
			si = 0 -- 903
			while si < #shardOffsets do -- 903
				local sh = shardOffsets[si + 1] -- 904
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 905
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 906
				uiInkDraw:drawPolygon( -- 907
					{ -- 907
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 908
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 909
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 910
					}, -- 910
					Color( -- 911
						212, -- 911
						218, -- 911
						224, -- 911
						math.floor(235 * shardAlpha + 0.5) -- 911
					), -- 911
					0.9, -- 911
					Color( -- 911
						92, -- 911
						108, -- 911
						126, -- 911
						math.floor(200 * shardAlpha + 0.5) -- 911
					) -- 911
				) -- 911
				si = si + 1 -- 903
			end -- 903
		end -- 903
	end -- 903
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 916
	local handOut = smoothstep(0.7, 0.9, prog) -- 917
	if handOut > 0.05 then -- 917
		drawChildHand( -- 919
			uiDraw, -- 920
			crackX + 34 - handOut * 78, -- 921
			rimY + 58, -- 922
			math.pi, -- 923
			1.18, -- 924
			"open_fingers", -- 925
			fade * handOut, -- 926
			false, -- 927
			uiArt, -- 928
			"p03_child_hand", -- 929
			4 -- 930
		) -- 930
	elseif fingerEnter > 0.02 then -- 930
		drawChildHand( -- 933
			uiDraw, -- 934
			crackX + 18 - fingerEnter * 26, -- 935
			rimY + 52, -- 936
			math.pi, -- 937
			1.16, -- 938
			"two_fingers", -- 939
			fade * fingerEnter, -- 940
			false, -- 941
			uiArt, -- 942
			"p03_child_peek", -- 943
			4 -- 944
		) -- 944
	end -- 944
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 949
	if sleeveEnter > 0.01 then -- 949
		local reachT = smoothstep(0.66, 0.88, prog) -- 951
		local wx = w * 0.06 + sleeveEnter * (w * 0.14) + math.sin(wipeT * math.pi) * 92 + reachT * 84 -- 952
		local wy = rimY + 52 - math.sin(wipeT * math.pi) * 28 + reachT * 12 -- 953
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 954
		local pose = reachT > 0.2 and "reach" or "wipe" -- 955
		____exports.drawPatchedCuff( -- 956
			uiDraw, -- 956
			uiGlow, -- 956
			{ -- 956
				wristX = wx, -- 957
				wristY = wy, -- 958
				angleRad = ang, -- 959
				scale = 1.48, -- 960
				pose = pose, -- 961
				opacity = fade * sleeveEnter, -- 962
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 963
				warmth = 0.18, -- 964
				uiArt = uiArt, -- 965
				instanceKey = "p03_zhou_cuff", -- 966
				layer = 4 -- 967
			} -- 967
		) -- 967
	end -- 967
	uiInkDraw:drawRect( -- 971
		Rect(0, by, 14, boxH), -- 971
		Color( -- 971
			7, -- 971
			9, -- 971
			14, -- 971
			math.floor(140 * fade + 0.5) -- 971
		) -- 971
	) -- 971
	uiInkDraw:drawRect( -- 974
		Rect(0, 0, w, barH), -- 974
		Color( -- 974
			6, -- 974
			8, -- 974
			12, -- 974
			math.floor(245 * fade + 0.5) -- 974
		) -- 974
	) -- 974
	uiInkDraw:drawRect( -- 975
		Rect(0, h - barH, w, barH), -- 975
		Color( -- 975
			6, -- 975
			8, -- 975
			12, -- 975
			math.floor(245 * fade + 0.5) -- 975
		) -- 975
	) -- 975
	uiInkDraw:drawSegment( -- 976
		Vec2(0, barH), -- 976
		Vec2(w, barH), -- 976
		0.9, -- 976
		toColor( -- 976
			PALETTE.silkDim, -- 976
			math.floor(86 * fade + 0.5) -- 976
		) -- 976
	) -- 976
	uiInkDraw:drawSegment( -- 977
		Vec2(0, h - barH), -- 977
		Vec2(w, h - barH), -- 977
		0.9, -- 977
		toColor( -- 977
			PALETTE.silkDim, -- 977
			math.floor(86 * fade + 0.5) -- 977
		) -- 977
	) -- 977
	drawSilkVeil( -- 978
		uiDraw, -- 978
		uiArt, -- 978
		"p03_sub_veil", -- 978
		w * 0.5, -- 978
		42, -- 978
		520, -- 978
		42, -- 978
		PALETTE.inkWash, -- 978
		0.82 * fade, -- 978
		7 -- 978
	) -- 978
	local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 979
	ctx.texts:put( -- 982
		"sm", -- 982
		subText, -- 982
		w * 0.5, -- 982
		42, -- 982
		toColor(PALETTE.textBright), -- 982
		0.5, -- 982
		0.5, -- 982
		"Center", -- 982
		1, -- 982
		fade, -- 982
		0.08 -- 982
	) -- 982
end -- 852
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 991
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 1001
	local barH = math.floor(h * 0.075 + 0.5) -- 1002
	local bx = 0 -- 1003
	local by = barH -- 1004
	local boxW = w -- 1005
	local boxH = math.max(120, h - barH * 2) -- 1006
	uiDraw:drawRect( -- 1008
		Rect(0, 0, w, h), -- 1008
		Color( -- 1008
			7, -- 1008
			9, -- 1008
			14, -- 1008
			math.floor(238 * fade + 0.5) -- 1008
		) -- 1008
	) -- 1008
	fillVGradRect( -- 1010
		uiDraw, -- 1010
		bx, -- 1010
		by, -- 1010
		boxW, -- 1010
		boxH, -- 1010
		Color( -- 1010
			12, -- 1010
			19, -- 1010
			30, -- 1010
			math.floor(248 * fade + 0.5) -- 1010
		), -- 1010
		Color( -- 1010
			24, -- 1010
			38, -- 1010
			54, -- 1010
			math.floor(248 * fade + 0.5) -- 1010
		) -- 1010
	) -- 1010
	uiArt:tryPlacePath( -- 1011
		"assets/art/tex_diorama_ming.clip|ming_water", -- 1011
		"p05_moat_water", -- 1011
		w * 0.65, -- 1011
		by + boxH * 0.26, -- 1011
		w * 0.75, -- 1011
		boxH * 0.52, -- 1011
		{ -- 1011
			color = Color(124, 152, 178, 255), -- 1012
			opacity = 0.42 * fade, -- 1013
			smooth = true, -- 1014
			layer = 0 -- 1015
		} -- 1015
	) -- 1015
	fillRadialGlow( -- 1017
		uiGlow, -- 1017
		bx + boxW * 0.66, -- 1017
		by + boxH * 0.34, -- 1017
		280, -- 1017
		96, -- 1017
		Color( -- 1017
			152, -- 1017
			194, -- 1017
			224, -- 1017
			math.floor(78 * fade + 0.5) -- 1017
		), -- 1017
		Color(40, 70, 108, 0), -- 1017
		16 -- 1017
	) -- 1017
	local releaseT = smoothstep(0.68, 0.94, prog) -- 1019
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 1020
	local cuffX = w * 0.4 - releaseT * 310 -- 1023
	local cuffY = by + boxH * 0.5 -- 1024
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1025
		wristX = cuffX, -- 1026
		wristY = cuffY, -- 1027
		angleRad = -0.05, -- 1028
		scale = 1.28, -- 1029
		pose = pinchT > 0.25 and "pinch" or "open", -- 1030
		opacity = fade * (1 - releaseT * 0.88), -- 1031
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 1032
		warmth = 0.12, -- 1033
		uiArt = uiArt, -- 1034
		instanceKey = "p05_zhou_cuff", -- 1035
		layer = 4 -- 1036
	}) -- 1036
	local childHandX = w * 0.56 + releaseT * 46 -- 1040
	local childHandY = by + boxH * 0.46 - releaseT * 14 -- 1041
	drawChildHand( -- 1042
		uiDraw, -- 1043
		childHandX, -- 1044
		childHandY, -- 1045
		math.pi + 0.1, -- 1046
		1.28, -- 1047
		releaseT > 0.35 and "open_fingers" or "clutch", -- 1048
		fade, -- 1049
		true, -- 1050
		uiArt, -- 1051
		"p05_child_hand", -- 1052
		5 -- 1053
	) -- 1053
	if releaseT > 0.01 then -- 1053
		local dropH = boxH * releaseT * 0.92 -- 1058
		local gateW = w * 0.48 -- 1059
		uiArt:tryPlacePath( -- 1060
			"assets/art/tex_diorama_ming.clip|ming_timber", -- 1060
			"p05_gate_drop", -- 1060
			gateW * 0.5, -- 1060
			by + boxH - dropH * 0.5, -- 1060
			gateW, -- 1060
			math.max(8, dropH), -- 1060
			{ -- 1060
				color = Color(86, 74, 62, 255), -- 1061
				opacity = 0.96 * fade, -- 1062
				smooth = true, -- 1063
				layer = 6 -- 1064
			} -- 1064
		) -- 1064
		uiInkDraw:drawSegment( -- 1066
			Vec2(0, by + boxH - dropH), -- 1066
			Vec2(gateW, by + boxH - dropH), -- 1066
			2.8, -- 1066
			Color( -- 1066
				138, -- 1066
				122, -- 1066
				102, -- 1066
				math.floor(220 * fade + 0.5) -- 1066
			) -- 1066
		) -- 1066
	end -- 1066
	uiInkDraw:drawRect( -- 1070
		Rect(0, 0, w, barH), -- 1070
		Color( -- 1070
			6, -- 1070
			8, -- 1070
			12, -- 1070
			math.floor(245 * fade + 0.5) -- 1070
		) -- 1070
	) -- 1070
	uiInkDraw:drawRect( -- 1071
		Rect(0, h - barH, w, barH), -- 1071
		Color( -- 1071
			6, -- 1071
			8, -- 1071
			12, -- 1071
			math.floor(245 * fade + 0.5) -- 1071
		) -- 1071
	) -- 1071
	uiInkDraw:drawSegment( -- 1072
		Vec2(0, barH), -- 1072
		Vec2(w, barH), -- 1072
		0.9, -- 1072
		toColor( -- 1072
			PALETTE.silkDim, -- 1072
			math.floor(86 * fade + 0.5) -- 1072
		) -- 1072
	) -- 1072
	uiInkDraw:drawSegment( -- 1073
		Vec2(0, h - barH), -- 1073
		Vec2(w, h - barH), -- 1073
		0.9, -- 1073
		toColor( -- 1073
			PALETTE.silkDim, -- 1073
			math.floor(86 * fade + 0.5) -- 1073
		) -- 1073
	) -- 1073
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 1076
	if lineAlpha > 0.02 then -- 1076
		drawSilkVeil( -- 1078
			uiDraw, -- 1078
			uiArt, -- 1078
			"p05_sub_veil", -- 1078
			w * 0.5, -- 1078
			42, -- 1078
			740, -- 1078
			44, -- 1078
			PALETTE.inkWash, -- 1078
			0.86 * lineAlpha, -- 1078
			7 -- 1078
		) -- 1078
		drawHairline( -- 1079
			uiInkDraw, -- 1079
			uiArt, -- 1079
			"p05_sub_line", -- 1079
			w * 0.5, -- 1079
			62, -- 1079
			520, -- 1079
			PALETTE.silkDim, -- 1079
			0.52 * lineAlpha, -- 1079
			true, -- 1079
			8 -- 1079
		) -- 1079
		ctx.texts:put( -- 1080
			"sm", -- 1080
			LINE_P05, -- 1080
			w * 0.5, -- 1080
			42, -- 1080
			toColor(PALETTE.textBright), -- 1080
			0.5, -- 1080
			0.5, -- 1080
			"Center", -- 1080
			0.8, -- 1080
			lineAlpha, -- 1080
			0.08 -- 1080
		) -- 1080
	end -- 1080
end -- 991
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1085
	local enter = smoothstep(0, 0.12, t) -- 1095
	local out = smoothstep(0.66, 1, t) -- 1096
	local alpha = enter * (1 - out) -- 1097
	if alpha <= 0.02 then -- 1097
		return -- 1099
	end -- 1099
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 1101
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1102
		wristX = w * 0.27 - out * 260, -- 1103
		wristY = h * 0.4, -- 1104
		angleRad = -0.05, -- 1105
		scale = 1.04, -- 1106
		pose = pinchT > 0.25 and "pinch" or "open", -- 1107
		opacity = alpha * 0.95, -- 1108
		stitchHighlight = 0.45 + 0.28 * pinchT, -- 1109
		uiArt = uiArt, -- 1110
		instanceKey = "p05_live_zhou_cuff", -- 1111
		layer = 4 -- 1112
	}) -- 1112
	drawChildHand( -- 1114
		uiDraw, -- 1115
		w * 0.39 + out * 30, -- 1116
		h * 0.37 - out * 10, -- 1117
		math.pi + 0.1, -- 1118
		1.02, -- 1119
		out > 0.32 and "open_fingers" or "clutch", -- 1120
		alpha * 0.94, -- 1121
		true, -- 1122
		uiArt, -- 1123
		"p05_live_child_hand", -- 1124
		5 -- 1125
	) -- 1125
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 1127
	if lineAlpha > 0.02 then -- 1127
		local subY = 92 -- 1129
		drawSilkVeil( -- 1130
			uiDraw, -- 1130
			uiArt, -- 1130
			"p05_live_veil", -- 1130
			w * 0.5, -- 1130
			subY, -- 1130
			760, -- 1130
			44, -- 1130
			PALETTE.inkWash, -- 1130
			0.86 * lineAlpha, -- 1130
			7 -- 1130
		) -- 1130
		drawHairline( -- 1131
			uiInkDraw, -- 1131
			uiArt, -- 1131
			"p05_live_line", -- 1131
			w * 0.5, -- 1131
			subY + 20, -- 1131
			520, -- 1131
			PALETTE.silkDim, -- 1131
			0.52 * lineAlpha, -- 1131
			true, -- 1131
			8 -- 1131
		) -- 1131
		ctx.texts:put( -- 1132
			"sm", -- 1132
			LINE_P05, -- 1132
			w * 0.5, -- 1132
			subY, -- 1132
			toColor(PALETTE.textBright), -- 1132
			0.5, -- 1132
			0.5, -- 1132
			"Center", -- 1132
			0.8, -- 1132
			lineAlpha, -- 1132
			0.08 -- 1132
		) -- 1132
	end -- 1132
end -- 1085
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1141
	local view = ctx.view -- 1150
	local gr = view.gateReunion -- 1151
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1152
	local ext = clamp01(self.g05SleeveExtend) -- 1153
	if not completed then -- 1153
		if ext > 0.008 then -- 1153
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 1157
			fillVGradRect( -- 1158
				uiDraw, -- 1158
				0, -- 1158
				h * 0.26, -- 1158
				w, -- 1158
				h * 0.18, -- 1158
				Color(8, 11, 18, 0), -- 1158
				Color(8, 11, 18, veilA) -- 1158
			) -- 1158
			fillVGradRect( -- 1159
				uiDraw, -- 1159
				0, -- 1159
				h * 0.44, -- 1159
				w, -- 1159
				h * 0.18, -- 1159
				Color(8, 11, 18, veilA), -- 1159
				Color(8, 11, 18, 0) -- 1159
			) -- 1159
			local cuffX = -56 + ext * (w * 0.42 + 56) -- 1161
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1162
			____exports.drawPatchedCuff( -- 1163
				uiDraw, -- 1163
				uiGlow, -- 1163
				{ -- 1163
					wristX = cuffX, -- 1164
					wristY = cuffY, -- 1165
					angleRad = -0.05, -- 1166
					scale = 1.22, -- 1167
					pose = ext > 0.82 and "clasp" or "reach", -- 1168
					opacity = clamp01(0.32 + ext * 0.68), -- 1169
					stitchHighlight = 0.35 + 0.6 * ext, -- 1170
					uiArt = uiArt, -- 1171
					instanceKey = "g05_live_zhou_cuff", -- 1172
					layer = 4 -- 1173
				} -- 1173
			) -- 1173
			local childX = w * 0.66 - ext * (w * 0.13) -- 1176
			local childY = h * 0.41 + ext * 14 -- 1177
			drawChildHand( -- 1178
				uiDraw, -- 1179
				childX, -- 1180
				childY, -- 1181
				math.pi + 0.08, -- 1182
				1.2, -- 1183
				ext > 0.88 and "clasp" or "reach_up", -- 1184
				clamp01(0.25 + ext * 0.75), -- 1185
				true, -- 1186
				uiArt, -- 1187
				"g05_live_child_hand", -- 1188
				5 -- 1189
			) -- 1189
			local barW = 240 -- 1193
			local bx0 = w * 0.5 - barW * 0.5 -- 1194
			local by0 = 32 -- 1195
			uiInkDraw:drawSegment( -- 1196
				Vec2(bx0, by0), -- 1196
				Vec2(bx0 + barW, by0), -- 1196
				1.2, -- 1196
				toColor(PALETTE.silkDim, 110) -- 1196
			) -- 1196
			uiInkDraw:drawSegment( -- 1197
				Vec2(bx0, by0), -- 1197
				Vec2(bx0 + barW * ext, by0), -- 1197
				2.4, -- 1197
				toColor(PALETTE.amberCore, 230) -- 1197
			) -- 1197
		else -- 1197
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1199
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1200
				wristX = -120 + peekPulse * 18, -- 1201
				wristY = h * 0.44, -- 1202
				angleRad = -0.04, -- 1203
				scale = 1.16, -- 1204
				pose = "open", -- 1205
				opacity = 0.42 + 0.24 * peekPulse, -- 1206
				stitchHighlight = 0.35 * peekPulse, -- 1207
				uiArt = uiArt, -- 1208
				instanceKey = "g05_live_zhou_cuff", -- 1209
				layer = 4 -- 1210
			}) -- 1210
		end -- 1210
		if view.assistHintsEnabled then -- 1210
			drawSilkVeil( -- 1215
				uiDraw, -- 1215
				uiArt, -- 1215
				"g05_assist_veil", -- 1215
				w * 0.5, -- 1215
				h - 26, -- 1215
				280, -- 1215
				28, -- 1215
				PALETTE.inkWash, -- 1215
				0.72, -- 1215
				7 -- 1215
			) -- 1215
			ctx.texts:put( -- 1216
				"xs", -- 1217
				adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1218
				w * 0.5, -- 1219
				h - 26, -- 1220
				toColor(PALETTE.amberCore), -- 1221
				0.5, -- 1222
				0.5, -- 1223
				"Center", -- 1224
				1.2, -- 1225
				0.9, -- 1226
				0.08 -- 1227
			) -- 1227
		end -- 1227
		return -- 1230
	end -- 1230
	local t = self.g05ReunionElapsed -- 1234
	local claspPull = smoothstep(0, 0.35, t) -- 1235
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1236
	local armDropY = tilt * (h * 0.3) -- 1237
	local portraitAlpha = smoothstep(0.28, 0.85, t) -- 1240
	if portraitAlpha > 0.02 then -- 1240
		drawZhouShuReunionPortrait( -- 1242
			uiDraw, -- 1242
			uiInkDraw, -- 1242
			uiArt, -- 1242
			uiGlow, -- 1242
			w, -- 1242
			h, -- 1242
			(1 - portraitAlpha) * 28, -- 1242
			portraitAlpha -- 1242
		) -- 1242
	end -- 1242
	local claspFade = 1 - smoothstep(0.55, 1.08, t) -- 1246
	if claspFade > 0.02 then -- 1246
		____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1248
			wristX = w * 0.44, -- 1249
			wristY = h * 0.42 - armDropY, -- 1250
			angleRad = -0.05 + tilt * 0.22, -- 1251
			scale = 1.22, -- 1252
			pose = "clasp", -- 1253
			opacity = claspFade, -- 1254
			stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1255
			cuffPullBack = claspPull * 0.85, -- 1256
			warmth = tilt * 0.32, -- 1257
			uiArt = uiArt, -- 1258
			instanceKey = "g05_live_zhou_cuff", -- 1259
			layer = 4 -- 1260
		}) -- 1260
		drawChildHand( -- 1262
			uiDraw, -- 1263
			w * 0.56, -- 1264
			h * 0.4 - armDropY, -- 1265
			math.pi + 0.05 - tilt * 0.14, -- 1266
			1.2, -- 1267
			"clasp", -- 1268
			claspFade, -- 1269
			true, -- 1270
			uiArt, -- 1271
			"g05_live_child_hand", -- 1272
			5 -- 1273
		) -- 1273
	end -- 1273
	local barH = math.floor(h * 0.068 + 0.5) -- 1277
	if portraitAlpha > 0.05 then -- 1277
		uiInkDraw:drawRect( -- 1279
			Rect(0, 0, w, barH), -- 1279
			Color( -- 1279
				6, -- 1279
				8, -- 1279
				12, -- 1279
				math.floor(244 * portraitAlpha + 0.5) -- 1279
			) -- 1279
		) -- 1279
		uiInkDraw:drawRect( -- 1280
			Rect(0, h - barH, w, barH), -- 1280
			Color( -- 1280
				6, -- 1280
				8, -- 1280
				12, -- 1280
				math.floor(244 * portraitAlpha + 0.5) -- 1280
			) -- 1280
		) -- 1280
	end -- 1280
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1284
	if lineAlpha > 0.02 then -- 1284
		drawSilkVeil( -- 1286
			uiDraw, -- 1286
			uiArt, -- 1286
			"g05_line_veil", -- 1286
			w * 0.5, -- 1286
			42, -- 1286
			420, -- 1286
			44, -- 1286
			PALETTE.inkWash, -- 1286
			0.86 * lineAlpha, -- 1286
			7 -- 1286
		) -- 1286
		drawHairline( -- 1287
			uiInkDraw, -- 1287
			uiArt, -- 1287
			"g05_line_bar", -- 1287
			w * 0.5, -- 1287
			62, -- 1287
			260, -- 1287
			PALETTE.amber, -- 1287
			0.58 * lineAlpha, -- 1287
			true, -- 1287
			8 -- 1287
		) -- 1287
		ctx.texts:put( -- 1288
			"sm", -- 1288
			LINE_G05, -- 1288
			w * 0.5, -- 1288
			42, -- 1288
			toColor(PALETTE.textBright), -- 1288
			0.5, -- 1288
			0.5, -- 1288
			"Center", -- 1288
			2.2, -- 1288
			lineAlpha, -- 1288
			0.08 -- 1288
		) -- 1288
	end -- 1288
end -- 1141
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1293
	local holdExt = smoothstep(0.55, 1.45, t) -- 1303
	local tilt = smoothstep(1.55, 2.55, t) -- 1304
	local claspPull = smoothstep(1.4, 1.75, t) -- 1305
	local armDropY = tilt * (h * 0.28) -- 1306
	local barH = math.floor(h * 0.072 + 0.5) -- 1307
	uiDraw:drawRect( -- 1309
		Rect(0, 0, w, h), -- 1309
		Color(7, 9, 14, 248) -- 1309
	) -- 1309
	local bgTop = lerpRGBA( -- 1310
		rgba(16, 24, 36, 250), -- 1310
		rgba(20, 26, 36, 250), -- 1310
		tilt -- 1310
	) -- 1310
	local bgBot = lerpRGBA( -- 1311
		rgba(10, 15, 24, 250), -- 1311
		rgba(14, 18, 26, 250), -- 1311
		tilt -- 1311
	) -- 1311
	fillVGradRect( -- 1312
		uiDraw, -- 1312
		0, -- 1312
		barH, -- 1312
		w, -- 1312
		h - barH * 2, -- 1312
		toColor(bgBot), -- 1312
		toColor(bgTop) -- 1312
	) -- 1312
	if tilt > 0.04 then -- 1312
		drawZhouShuReunionPortrait( -- 1315
			uiDraw, -- 1315
			uiInkDraw, -- 1315
			uiArt, -- 1315
			uiGlow, -- 1315
			w, -- 1315
			h, -- 1315
			(1 - tilt) * 28, -- 1315
			tilt -- 1315
		) -- 1315
	end -- 1315
	local handFade = 1 - smoothstep(1.75, 2.38, t) -- 1318
	if handFade > 0.02 then -- 1318
		____exports.drawPatchedCuff( -- 1320
			uiDraw, -- 1320
			uiGlow, -- 1320
			{ -- 1320
				wristX = w * 0.06 + holdExt * (w * 0.38), -- 1321
				wristY = h * 0.48 - armDropY, -- 1322
				angleRad = -0.05 + tilt * 0.2, -- 1323
				scale = 1.24, -- 1324
				pose = t >= 1.4 and "clasp" or "reach", -- 1325
				opacity = clamp01(0.28 + holdExt * 0.72) * handFade, -- 1326
				stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1327
				cuffPullBack = claspPull * 0.85, -- 1328
				warmth = tilt * 0.32, -- 1329
				uiArt = uiArt, -- 1330
				instanceKey = "g05_reh_zhou_cuff", -- 1331
				layer = 4 -- 1332
			} -- 1332
		) -- 1332
		drawChildHand( -- 1334
			uiDraw, -- 1335
			w * 0.68 - holdExt * (w * 0.12), -- 1336
			h * 0.44 - armDropY, -- 1337
			math.pi + 0.06, -- 1338
			1.22, -- 1339
			t >= 1.4 and "clasp" or "reach_up", -- 1340
			clamp01(0.35 + holdExt * 0.65) * handFade, -- 1341
			true, -- 1342
			uiArt, -- 1343
			"g05_reh_child_hand", -- 1344
			5 -- 1345
		) -- 1345
	end -- 1345
	uiInkDraw:drawRect( -- 1349
		Rect(0, 0, w, barH), -- 1349
		Color(6, 8, 12, 246) -- 1349
	) -- 1349
	uiInkDraw:drawRect( -- 1350
		Rect(0, h - barH, w, barH), -- 1350
		Color(6, 8, 12, 246) -- 1350
	) -- 1350
	uiInkDraw:drawSegment( -- 1351
		Vec2(0, barH), -- 1351
		Vec2(w, barH), -- 1351
		0.9, -- 1351
		toColor(PALETTE.silkDim, 86) -- 1351
	) -- 1351
	uiInkDraw:drawSegment( -- 1352
		Vec2(0, h - barH), -- 1352
		Vec2(w, h - barH), -- 1352
		0.9, -- 1352
		toColor(PALETTE.silkDim, 86) -- 1352
	) -- 1352
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1354
	if lineAlpha > 0.02 then -- 1354
		drawSilkVeil( -- 1356
			uiDraw, -- 1356
			uiArt, -- 1356
			"g05_reh_veil", -- 1356
			w * 0.5, -- 1356
			42, -- 1356
			420, -- 1356
			44, -- 1356
			PALETTE.inkWash, -- 1356
			0.86 * lineAlpha, -- 1356
			7 -- 1356
		) -- 1356
		drawHairline( -- 1357
			uiInkDraw, -- 1357
			uiArt, -- 1357
			"g05_reh_bar", -- 1357
			w * 0.5, -- 1357
			62, -- 1357
			260, -- 1357
			PALETTE.amber, -- 1357
			0.58 * lineAlpha, -- 1357
			true, -- 1357
			8 -- 1357
		) -- 1357
		ctx.texts:put( -- 1358
			"sm", -- 1358
			LINE_G05, -- 1358
			w * 0.5, -- 1358
			42, -- 1358
			toColor(PALETTE.textBright), -- 1358
			0.5, -- 1358
			0.5, -- 1358
			"Center", -- 1358
			2.2, -- 1358
			lineAlpha, -- 1358
			0.08 -- 1358
		) -- 1358
	end -- 1358
end -- 1293
function ____exports.createCuffShotsPlugin() -- 1363
	return __TS__New(____exports.CuffShotsPlugin) -- 1364
end -- 1363
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1371
	local gateTransition = createGateTransitionPlugin() -- 1375
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1376
	fe:registerPlugin(gateTransition) -- 1377
	fe:registerPlugin(cuffShots) -- 1378
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1379
end -- 1371
return ____exports -- 1371