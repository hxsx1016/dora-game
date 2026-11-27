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
	self.p05Progress = 0 -- 539
	self.p05ExitTimer = -1 -- 540
	self.g05SleeveExtend = 0 -- 541
	self.g05ReunionElapsed = 0 -- 542
	self.g05LineTriggered = false -- 543
	self.g05AbortVisualCount = 0 -- 544
	self.lastReleasedAbortCount = 0 -- 545
end -- 524
function CuffShotsPlugin.prototype.onBindPlay(self, p, _view) -- 547
	self.animTime = 0 -- 548
	self.prevPhase = p.phase -- 549
	self.activeShot = "" -- 550
	self.p03Progress = 0 -- 551
	self.p05Progress = 0 -- 552
	self.p05ExitTimer = -1 -- 553
	self.g05SleeveExtend = 0 -- 554
	self.g05ReunionElapsed = 0 -- 555
	self.g05LineTriggered = false -- 556
	self.g05AbortVisualCount = 0 -- 557
	self.lastReleasedAbortCount = 0 -- 558
end -- 547
function CuffShotsPlugin.prototype.rehearseShot(self, shot, fixedTime) -- 566
	self.rehearsalShot = shot -- 567
	if shot == "" then -- 567
		self.rehearsalTime = 0 -- 569
		self.rehearsalAutoAdvance = true -- 570
		return -- 571
	end -- 571
	self.rehearsalDuration = shot == "P03" and 3 or 4 -- 573
	if fixedTime ~= nil then -- 573
		self.rehearsalTime = math.max( -- 575
			0, -- 575
			math.min(self.rehearsalDuration, fixedTime) -- 575
		) -- 575
		self.rehearsalAutoAdvance = false -- 576
	else -- 576
		self.rehearsalTime = 0 -- 578
		self.rehearsalAutoAdvance = true -- 579
	end -- 579
end -- 566
function CuffShotsPlugin.prototype.stopRehearsalShot(self) -- 583
	self:rehearseShot("") -- 584
end -- 583
function CuffShotsPlugin.prototype.getDebugState(self) -- 587
	return { -- 588
		activeShot = self.activeShot, -- 589
		rehearsalShot = self.rehearsalShot, -- 590
		rehearsalTime = self.rehearsalTime, -- 591
		rehearsalDuration = self.rehearsalDuration, -- 592
		p03Progress = self.p03Progress, -- 593
		p05ExitTimer = self.p05ExitTimer, -- 594
		g05SleeveExtend = self.g05SleeveExtend, -- 595
		g05ReunionElapsed = self.g05ReunionElapsed, -- 596
		g05LineTriggered = self.g05LineTriggered, -- 597
		g05AbortVisualCount = self.g05AbortVisualCount -- 598
	} -- 598
end -- 587
function CuffShotsPlugin.prototype.update(self, ctx) -- 602
	local p = ctx.p -- 603
	local view = ctx.view -- 604
	local dt = ctx.paused and 0 or ctx.worldDt -- 605
	self.animTime = self.animTime + dt -- 606
	if self.rehearsalShot ~= "" then -- 606
		self.activeShot = self.rehearsalShot -- 610
		if self.rehearsalAutoAdvance and dt > 0 then -- 610
			self.rehearsalTime = math.min(self.rehearsalDuration, self.rehearsalTime + dt) -- 612
		end -- 612
		if not ctx.paused then -- 612
			self:triggerRehearsalAudio(ctx) -- 615
		end -- 615
		self.prevPhase = p.phase -- 617
		return -- 618
	end -- 618
	self.activeShot = "" -- 621
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 621
		self.activeShot = "P03" -- 625
		self.p03Progress = clamp01(p.phaseTick / PROLOGUE_GIVE_TICKS) -- 626
		if not ctx.paused and self.p03Progress >= 0.18 then -- 626
			ctx.audio:playOnce( -- 628
				"cuff:p03:wipe:" .. tostring(ctx.events.roomSessionId), -- 629
				"sfx", -- 630
				GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 631
				0.86, -- 632
				"cuff:p03:cloth_wipe_wood", -- 633
				p.ticks -- 634
			) -- 634
		end -- 634
		if not ctx.paused and self.p03Progress >= 0.62 then -- 634
			ctx.audio:playOnce( -- 638
				"cuff:p03:compass:" .. tostring(ctx.events.roomSessionId), -- 639
				"sfx", -- 640
				"assets/audio/interact/compass_handover.wav", -- 641
				0.82, -- 642
				"cuff:p03:compass_handover", -- 643
				p.ticks -- 644
			) -- 644
		end -- 644
		self.prevPhase = p.phase -- 647
		return -- 648
	else -- 648
		self.p03Progress = 0 -- 650
	end -- 650
	if p.room.key == "gate" and p.phase == "gate-farewell" then -- 650
		self.activeShot = "P05" -- 655
		self.p05Progress = clamp01(p.phaseTick / GATE_FAREWELL_TICKS) -- 656
		self.p05ExitTimer = p.phaseTick / 60 -- 657
		if not ctx.paused then -- 657
			if self.p05Progress >= 0.14 then -- 657
				ctx.audio:playOnce( -- 660
					"cuff:p05:line:" .. tostring(ctx.events.roomSessionId), -- 661
					"voice", -- 662
					GATE_AUDIO_ROOT .. "line_farewell.wav", -- 663
					0.88, -- 664
					"cuff:p05:line_farewell", -- 665
					p.ticks -- 666
				) -- 666
			end -- 666
			if self.p05Progress >= 0.7 then -- 666
				ctx.audio:playOnce( -- 670
					"cuff:p05:slam:" .. tostring(ctx.events.roomSessionId), -- 671
					"sfx", -- 672
					GATE_AUDIO_ROOT .. "gate_slam.wav", -- 673
					0.92, -- 674
					"cuff:p05:gate_slam", -- 675
					p.ticks -- 676
				) -- 676
			end -- 676
		end -- 676
		self.prevPhase = p.phase -- 680
		return -- 681
	else -- 681
		self.p05Progress = 0 -- 683
		self.p05ExitTimer = -1 -- 684
	end -- 684
	local inGateReunion = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-count" and view.storyRoute == "soldier" and (view.gateReunion.active or view.gateReunion.completed)) -- 688
	if inGateReunion then -- 688
		self.activeShot = "G05" -- 696
		local gr = view.gateReunion -- 697
		local completed = p.phase == "gate-hand" or gr.completed -- 698
		if gr.releasedAbortCount > self.lastReleasedAbortCount then -- 698
			self.g05AbortVisualCount = self.g05AbortVisualCount + (gr.releasedAbortCount - self.lastReleasedAbortCount) -- 701
			self.lastReleasedAbortCount = gr.releasedAbortCount -- 702
			if not ctx.paused and view.isRehearsal then -- 702
				ctx.audio:playOnce( -- 704
					(("cuff:g05:release:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(gr.releasedAbortCount), -- 705
					"sfx", -- 706
					GATE_AUDIO_ROOT .. "reunion_release.wav", -- 707
					0.72, -- 708
					"cuff:g05:reunion_release", -- 709
					p.ticks -- 710
				) -- 710
			end -- 710
		end -- 710
		if completed then -- 710
			self.g05SleeveExtend = 1 -- 716
			if dt > 0 then -- 716
				self.g05ReunionElapsed = self.g05ReunionElapsed + dt -- 718
			end -- 718
			if not ctx.paused and not self.g05LineTriggered then -- 718
				if view.isRehearsal then -- 718
					ctx.audio:playOnce( -- 722
						"cuff:g05:clasp:" .. tostring(ctx.events.roomSessionId), -- 723
						"sfx", -- 724
						GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 725
						0.88, -- 726
						"cuff:g05:hand_held", -- 727
						p.ticks -- 728
					) -- 728
				end -- 728
				if self.g05ReunionElapsed >= 0.8 or p.phase == "gate-hand" and p.phaseTick >= 42 then -- 728
					self.g05LineTriggered = true -- 732
					ctx.audio:playOnce( -- 733
						"cuff:g05:line:" .. tostring(ctx.events.roomSessionId), -- 734
						"voice", -- 735
						GATE_AUDIO_ROOT .. "line_reunion.wav", -- 736
						0.94, -- 737
						"cuff:g05:line_reunion", -- 738
						p.ticks -- 739
					) -- 739
				end -- 739
			end -- 739
		else -- 739
			self.g05ReunionElapsed = 0 -- 744
			self.g05LineTriggered = false -- 745
			if gr.holding or gr.holdProgress > 0.001 then -- 745
				if gr.holdProgress >= self.g05SleeveExtend then -- 745
					self.g05SleeveExtend = gr.holdProgress -- 749
				elseif dt > 0 then -- 749
					self.g05SleeveExtend = math.max(gr.holdProgress, self.g05SleeveExtend - dt * 4) -- 751
				end -- 751
			elseif dt > 0 and self.g05SleeveExtend > 0 then -- 751
				self.g05SleeveExtend = math.max(0, self.g05SleeveExtend - dt * 2.8) -- 755
			end -- 755
		end -- 755
	else -- 755
		self.g05SleeveExtend = 0 -- 759
		self.g05ReunionElapsed = 0 -- 760
		self.g05LineTriggered = false -- 761
		self.lastReleasedAbortCount = view.gateReunion.releasedAbortCount -- 762
	end -- 762
	self.prevPhase = p.phase -- 765
end -- 602
function CuffShotsPlugin.prototype.triggerRehearsalAudio(self, ctx) -- 768
	local sid = ctx.events.roomSessionId -- 769
	local t = self.rehearsalTime -- 770
	if self.rehearsalShot == "P03" and t >= 0.85 then -- 770
		ctx.audio:playOnce( -- 772
			"reh:p03:wipe:" .. tostring(sid), -- 772
			"sfx", -- 772
			GATE_AUDIO_ROOT .. "cloth_wipe_wood.wav", -- 772
			0.88, -- 772
			"cuff:p03:cloth_wipe_wood", -- 772
			ctx.p.ticks -- 772
		) -- 772
	elseif self.rehearsalShot == "P05" then -- 772
		if t >= 0.9 then -- 772
			ctx.audio:playOnce( -- 775
				"reh:p05:line:" .. tostring(sid), -- 775
				"voice", -- 775
				GATE_AUDIO_ROOT .. "line_farewell.wav", -- 775
				0.9, -- 775
				"cuff:p05:line_farewell", -- 775
				ctx.p.ticks -- 775
			) -- 775
		end -- 775
		if t >= 2.75 then -- 775
			ctx.audio:playOnce( -- 778
				"reh:p05:slam:" .. tostring(sid), -- 778
				"sfx", -- 778
				GATE_AUDIO_ROOT .. "gate_slam.wav", -- 778
				0.94, -- 778
				"cuff:p05:gate_slam", -- 778
				ctx.p.ticks -- 778
			) -- 778
			ctx.audio:playLoop( -- 779
				"reh_p05_water", -- 779
				"water", -- 779
				GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 779
				0.42, -- 779
				ctx.p.ticks -- 779
			) -- 779
		end -- 779
	elseif self.rehearsalShot == "G05" then -- 779
		if t >= 0.05 then -- 779
			ctx.audio:playOnce( -- 783
				"reh:g05:knock1:" .. tostring(sid), -- 783
				"sfx", -- 783
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 783
				0.88, -- 783
				"knock:gate:1", -- 783
				ctx.p.ticks -- 783
			) -- 783
		end -- 783
		if t >= 0.25 then -- 783
			ctx.audio:playOnce( -- 786
				"reh:g05:knock2:" .. tostring(sid), -- 786
				"sfx", -- 786
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 786
				0.92, -- 786
				"knock:gate:2", -- 786
				ctx.p.ticks -- 786
			) -- 786
		end -- 786
		if t >= 1.55 then -- 786
			ctx.audio:playOnce( -- 789
				"reh:g05:clasp:" .. tostring(sid), -- 789
				"sfx", -- 789
				GATE_AUDIO_ROOT .. "reunion_hold.wav", -- 789
				0.88, -- 789
				"cuff:g05:hand_held", -- 789
				ctx.p.ticks -- 789
			) -- 789
		end -- 789
		if t >= 2.35 then -- 789
			ctx.audio:playOnce( -- 792
				"reh:g05:line:" .. tostring(sid), -- 792
				"voice", -- 792
				GATE_AUDIO_ROOT .. "line_reunion.wav", -- 792
				0.94, -- 792
				"cuff:g05:line_reunion", -- 792
				ctx.p.ticks -- 792
			) -- 792
		end -- 792
	end -- 792
end -- 768
function CuffShotsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 797
	if self.activeShot == "" then -- 797
		return false -- 805
	end -- 805
	local w = ctx.uiW -- 807
	local h = ctx.uiH -- 808
	if self.activeShot == "P03" then -- 808
		local prog = self.rehearsalShot == "P03" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p03Progress -- 811
		self:renderP03Shot( -- 814
			uiDraw, -- 814
			uiInkDraw, -- 814
			uiArt, -- 814
			uiGlow, -- 814
			ctx, -- 814
			w, -- 814
			h, -- 814
			prog -- 814
		) -- 814
		return true -- 815
	end -- 815
	if self.activeShot == "P05" then -- 815
		local prog = self.rehearsalShot == "P05" and clamp01(self.rehearsalTime / self.rehearsalDuration) or self.p05Progress -- 819
		self:renderP05FullShot( -- 822
			uiDraw, -- 822
			uiInkDraw, -- 822
			uiArt, -- 822
			uiGlow, -- 822
			ctx, -- 822
			w, -- 822
			h, -- 822
			prog -- 822
		) -- 822
		return true -- 823
	end -- 823
	if self.activeShot == "G05" then -- 823
		if self.rehearsalShot == "G05" then -- 823
			self:renderG05RehearsalShot( -- 828
				uiDraw, -- 828
				uiInkDraw, -- 828
				uiArt, -- 828
				uiGlow, -- 828
				ctx, -- 828
				w, -- 828
				h, -- 828
				self.rehearsalTime -- 828
			) -- 828
			return true -- 829
		end -- 829
		self:renderG05LiveShot( -- 831
			uiDraw, -- 831
			uiInkDraw, -- 831
			uiArt, -- 831
			uiGlow, -- 831
			ctx, -- 831
			w, -- 831
			h -- 831
		) -- 831
		return true -- 832
	end -- 832
	return false -- 835
end -- 797
function CuffShotsPlugin.prototype.renderP03Shot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 844
	local fade = smoothstep(0, 0.08, prog) * (1 - smoothstep(0.92, 1, prog)) -- 854
	local barH = math.floor(h * 0.075 + 0.5) -- 856
	local bx = 0 -- 857
	local by = barH -- 858
	local boxW = w -- 859
	local boxH = math.max(120, h - barH * 2) -- 860
	uiDraw:drawRect( -- 862
		Rect(0, 0, w, h), -- 862
		Color( -- 862
			7, -- 862
			9, -- 862
			14, -- 862
			math.floor(232 * fade + 0.5) -- 862
		) -- 862
	) -- 862
	fillVGradRect( -- 863
		uiDraw, -- 863
		bx, -- 863
		by, -- 863
		boxW, -- 863
		boxH, -- 863
		Color( -- 863
			12, -- 863
			11, -- 863
			15, -- 863
			math.floor(248 * fade + 0.5) -- 863
		), -- 863
		Color( -- 863
			22, -- 863
			22, -- 863
			28, -- 863
			math.floor(248 * fade + 0.5) -- 863
		) -- 863
	) -- 863
	local rimY = by + boxH * 0.36 -- 865
	uiArt:tryPlacePath( -- 866
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 866
		"p03_cabinet_rim_tex", -- 866
		w * 0.5, -- 866
		(by + rimY) * 0.5, -- 866
		w, -- 866
		math.max(12, rimY - by), -- 866
		{ -- 866
			color = Color(126, 104, 86, 255), -- 867
			opacity = 0.92 * fade, -- 868
			smooth = true, -- 869
			layer = 1 -- 870
		} -- 870
	) -- 870
	uiDraw:drawSegment( -- 872
		Vec2(bx, rimY), -- 872
		Vec2(bx + boxW, rimY), -- 872
		2.2, -- 872
		Color( -- 872
			142, -- 872
			114, -- 872
			88, -- 872
			math.floor(215 * fade + 0.5) -- 872
		) -- 872
	) -- 872
	local crackX = bx + boxW * 0.72 -- 874
	uiDraw:drawRect( -- 875
		Rect(crackX, rimY, boxW - (crackX - bx), by + boxH - rimY), -- 875
		Color( -- 875
			6, -- 875
			7, -- 875
			11, -- 875
			math.floor(248 * fade + 0.5) -- 875
		) -- 875
	) -- 875
	uiArt:tryPlacePath( -- 876
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 876
		"p03_cabinet_door_tex", -- 876
		crackX + 40 + (boxW - (crackX + 40)) * 0.5, -- 876
		rimY + (by + boxH - rimY) * 0.5, -- 876
		math.max(12, boxW - (crackX + 40)), -- 876
		math.max(12, by + boxH - rimY), -- 876
		{ -- 876
			color = Color(96, 78, 62, 255), -- 877
			opacity = 0.98 * fade, -- 878
			smooth = true, -- 879
			layer = 5 -- 880
		} -- 880
	) -- 880
	fillRadialGlow( -- 882
		uiGlow, -- 882
		crackX - 18, -- 882
		rimY + 42, -- 882
		190, -- 882
		120, -- 882
		Color( -- 882
			166, -- 882
			192, -- 882
			218, -- 882
			math.floor(48 * fade + 0.5) -- 882
		), -- 882
		Color(64, 92, 124, 0), -- 882
		16 -- 882
	) -- 882
	local wipeT = smoothstep(0.3, 0.66, prog) -- 885
	local shardOffsets = {{ -- 886
		x = -72, -- 887
		y = 8, -- 887
		dx = 46, -- 887
		dy = -38, -- 887
		r = 9 -- 887
	}, { -- 887
		x = -34, -- 888
		y = 12, -- 888
		dx = 64, -- 888
		dy = -46, -- 888
		r = 7 -- 888
	}, { -- 888
		x = 4, -- 889
		y = 6, -- 889
		dx = 82, -- 889
		dy = -52, -- 889
		r = 10 -- 889
	}, { -- 889
		x = 32, -- 890
		y = 10, -- 890
		dx = 74, -- 890
		dy = -34, -- 890
		r = 6 -- 890
	}} -- 890
	local shardAlpha = fade * (1 - smoothstep(0.58, 0.74, prog)) -- 892
	if shardAlpha > 0.02 then -- 892
		local si = 0 -- 894
		do -- 894
			si = 0 -- 895
			while si < #shardOffsets do -- 895
				local sh = shardOffsets[si + 1] -- 896
				local sx = bx + boxW * 0.52 + sh.x + sh.dx * wipeT * wipeT -- 897
				local sy = rimY + sh.y + sh.dy * wipeT * wipeT -- 898
				uiInkDraw:drawPolygon( -- 899
					{ -- 899
						Vec2(sx - sh.r, sy - sh.r * 0.4), -- 900
						Vec2(sx + sh.r * 0.9, sy - sh.r * 0.6), -- 901
						Vec2(sx + sh.r * 0.2, sy + sh.r * 0.8) -- 902
					}, -- 902
					Color( -- 903
						212, -- 903
						218, -- 903
						224, -- 903
						math.floor(235 * shardAlpha + 0.5) -- 903
					), -- 903
					0.9, -- 903
					Color( -- 903
						92, -- 903
						108, -- 903
						126, -- 903
						math.floor(200 * shardAlpha + 0.5) -- 903
					) -- 903
				) -- 903
				si = si + 1 -- 895
			end -- 895
		end -- 895
	end -- 895
	local fingerEnter = smoothstep(0.04, 0.24, prog) -- 908
	local handOut = smoothstep(0.7, 0.9, prog) -- 909
	if handOut > 0.05 then -- 909
		drawChildHand( -- 911
			uiDraw, -- 912
			crackX + 34 - handOut * 78, -- 913
			rimY + 58, -- 914
			math.pi, -- 915
			1.18, -- 916
			"open_fingers", -- 917
			fade * handOut, -- 918
			false, -- 919
			uiArt, -- 920
			"p03_child_hand", -- 921
			4 -- 922
		) -- 922
	elseif fingerEnter > 0.02 then -- 922
		drawChildHand( -- 925
			uiDraw, -- 926
			crackX + 18 - fingerEnter * 26, -- 927
			rimY + 52, -- 928
			math.pi, -- 929
			1.16, -- 930
			"two_fingers", -- 931
			fade * fingerEnter, -- 932
			false, -- 933
			uiArt, -- 934
			"p03_child_peek", -- 935
			4 -- 936
		) -- 936
	end -- 936
	local sleeveEnter = smoothstep(0.22, 0.36, prog) -- 941
	if sleeveEnter > 0.01 then -- 941
		local reachT = smoothstep(0.66, 0.88, prog) -- 943
		local wx = w * 0.06 + sleeveEnter * (w * 0.14) + math.sin(wipeT * math.pi) * 92 + reachT * 84 -- 944
		local wy = rimY + 52 - math.sin(wipeT * math.pi) * 28 + reachT * 12 -- 945
		local ang = -0.14 * math.sin(wipeT * math.pi) + 0.04 * reachT -- 946
		local pose = reachT > 0.2 and "reach" or "wipe" -- 947
		____exports.drawPatchedCuff( -- 948
			uiDraw, -- 948
			uiGlow, -- 948
			{ -- 948
				wristX = wx, -- 949
				wristY = wy, -- 950
				angleRad = ang, -- 951
				scale = 1.48, -- 952
				pose = pose, -- 953
				opacity = fade * sleeveEnter, -- 954
				stitchHighlight = 0.35 + 0.35 * math.sin(wipeT * math.pi), -- 955
				warmth = 0.18, -- 956
				uiArt = uiArt, -- 957
				instanceKey = "p03_zhou_cuff", -- 958
				layer = 4 -- 959
			} -- 959
		) -- 959
	end -- 959
	uiInkDraw:drawRect( -- 963
		Rect(0, by, 14, boxH), -- 963
		Color( -- 963
			7, -- 963
			9, -- 963
			14, -- 963
			math.floor(140 * fade + 0.5) -- 963
		) -- 963
	) -- 963
	uiInkDraw:drawRect( -- 966
		Rect(0, 0, w, barH), -- 966
		Color( -- 966
			6, -- 966
			8, -- 966
			12, -- 966
			math.floor(245 * fade + 0.5) -- 966
		) -- 966
	) -- 966
	uiInkDraw:drawRect( -- 967
		Rect(0, h - barH, w, barH), -- 967
		Color( -- 967
			6, -- 967
			8, -- 967
			12, -- 967
			math.floor(245 * fade + 0.5) -- 967
		) -- 967
	) -- 967
	uiInkDraw:drawSegment( -- 968
		Vec2(0, barH), -- 968
		Vec2(w, barH), -- 968
		0.9, -- 968
		toColor( -- 968
			PALETTE.silkDim, -- 968
			math.floor(86 * fade + 0.5) -- 968
		) -- 968
	) -- 968
	uiInkDraw:drawSegment( -- 969
		Vec2(0, h - barH), -- 969
		Vec2(w, h - barH), -- 969
		0.9, -- 969
		toColor( -- 969
			PALETTE.silkDim, -- 969
			math.floor(86 * fade + 0.5) -- 969
		) -- 969
	) -- 969
	if self.rehearsalShot == "P03" then -- 969
		drawSilkVeil( -- 971
			uiDraw, -- 971
			uiArt, -- 971
			"p03_sub_veil", -- 971
			w * 0.5, -- 971
			42, -- 971
			520, -- 971
			42, -- 971
			PALETTE.inkWash, -- 971
			0.82 * fade, -- 971
			-1 -- 971
		) -- 971
		local subText = prog < 0.68 and "青布袖口掠过柜沿，轻轻拂开了碎瓷。" or "「是我，别怕。……这个沉，替我揣怀里。」" -- 972
		ctx.texts:put( -- 975
			"sm", -- 975
			subText, -- 975
			w * 0.5, -- 975
			42, -- 975
			toColor(PALETTE.textBright), -- 975
			0.5, -- 975
			0.5, -- 975
			"Center", -- 975
			1, -- 975
			fade, -- 975
			0.08 -- 975
		) -- 975
	end -- 975
end -- 844
function CuffShotsPlugin.prototype.renderP05FullShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, prog) -- 985
	local fade = smoothstep(0, 0.06, prog) * (1 - smoothstep(0.95, 1, prog)) -- 995
	local barH = math.floor(h * 0.075 + 0.5) -- 996
	local bx = 0 -- 997
	local by = barH -- 998
	local boxW = w -- 999
	local boxH = math.max(120, h - barH * 2) -- 1000
	uiDraw:drawRect( -- 1002
		Rect(0, 0, w, h), -- 1002
		Color( -- 1002
			7, -- 1002
			9, -- 1002
			14, -- 1002
			math.floor(238 * fade + 0.5) -- 1002
		) -- 1002
	) -- 1002
	fillVGradRect( -- 1004
		uiDraw, -- 1004
		bx, -- 1004
		by, -- 1004
		boxW, -- 1004
		boxH, -- 1004
		Color( -- 1004
			12, -- 1004
			19, -- 1004
			30, -- 1004
			math.floor(248 * fade + 0.5) -- 1004
		), -- 1004
		Color( -- 1004
			24, -- 1004
			38, -- 1004
			54, -- 1004
			math.floor(248 * fade + 0.5) -- 1004
		) -- 1004
	) -- 1004
	uiArt:tryPlacePath( -- 1005
		"assets/art/tex_diorama_ming.clip|ming_water", -- 1005
		"p05_moat_water", -- 1005
		w * 0.65, -- 1005
		by + boxH * 0.26, -- 1005
		w * 0.75, -- 1005
		boxH * 0.52, -- 1005
		{ -- 1005
			color = Color(124, 152, 178, 255), -- 1006
			opacity = 0.42 * fade, -- 1007
			smooth = true, -- 1008
			layer = 0 -- 1009
		} -- 1009
	) -- 1009
	fillRadialGlow( -- 1011
		uiGlow, -- 1011
		bx + boxW * 0.66, -- 1011
		by + boxH * 0.34, -- 1011
		280, -- 1011
		96, -- 1011
		Color( -- 1011
			152, -- 1011
			194, -- 1011
			224, -- 1011
			math.floor(78 * fade + 0.5) -- 1011
		), -- 1011
		Color(40, 70, 108, 0), -- 1011
		16 -- 1011
	) -- 1011
	local releaseT = smoothstep(0.68, 0.94, prog) -- 1013
	local pinchT = smoothstep(0.24, 0.42, prog) * (1 - releaseT) -- 1014
	local cuffX = w * 0.4 - releaseT * 310 -- 1017
	local cuffY = by + boxH * 0.5 -- 1018
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1019
		wristX = cuffX, -- 1020
		wristY = cuffY, -- 1021
		angleRad = -0.05, -- 1022
		scale = 1.28, -- 1023
		pose = pinchT > 0.25 and "pinch" or "open", -- 1024
		opacity = fade * (1 - releaseT * 0.88), -- 1025
		stitchHighlight = 0.45 + 0.3 * pinchT, -- 1026
		warmth = 0.12, -- 1027
		uiArt = uiArt, -- 1028
		instanceKey = "p05_zhou_cuff", -- 1029
		layer = 4 -- 1030
	}) -- 1030
	local childHandX = w * 0.56 + releaseT * 46 -- 1034
	local childHandY = by + boxH * 0.46 - releaseT * 14 -- 1035
	drawChildHand( -- 1036
		uiDraw, -- 1037
		childHandX, -- 1038
		childHandY, -- 1039
		math.pi + 0.1, -- 1040
		1.28, -- 1041
		releaseT > 0.35 and "open_fingers" or "clutch", -- 1042
		fade, -- 1043
		true, -- 1044
		uiArt, -- 1045
		"p05_child_hand", -- 1046
		5 -- 1047
	) -- 1047
	if releaseT > 0.01 then -- 1047
		local dropH = boxH * releaseT * 0.92 -- 1052
		local gateW = w * 0.48 -- 1053
		uiArt:tryPlacePath( -- 1054
			"assets/art/tex_diorama_ming.clip|ming_timber", -- 1054
			"p05_gate_drop", -- 1054
			gateW * 0.5, -- 1054
			by + boxH - dropH * 0.5, -- 1054
			gateW, -- 1054
			math.max(8, dropH), -- 1054
			{ -- 1054
				color = Color(86, 74, 62, 255), -- 1055
				opacity = 0.96 * fade, -- 1056
				smooth = true, -- 1057
				layer = 6 -- 1058
			} -- 1058
		) -- 1058
		uiInkDraw:drawSegment( -- 1060
			Vec2(0, by + boxH - dropH), -- 1060
			Vec2(gateW, by + boxH - dropH), -- 1060
			2.8, -- 1060
			Color( -- 1060
				138, -- 1060
				122, -- 1060
				102, -- 1060
				math.floor(220 * fade + 0.5) -- 1060
			) -- 1060
		) -- 1060
	end -- 1060
	uiInkDraw:drawRect( -- 1064
		Rect(0, 0, w, barH), -- 1064
		Color( -- 1064
			6, -- 1064
			8, -- 1064
			12, -- 1064
			math.floor(245 * fade + 0.5) -- 1064
		) -- 1064
	) -- 1064
	uiInkDraw:drawRect( -- 1065
		Rect(0, h - barH, w, barH), -- 1065
		Color( -- 1065
			6, -- 1065
			8, -- 1065
			12, -- 1065
			math.floor(245 * fade + 0.5) -- 1065
		) -- 1065
	) -- 1065
	uiInkDraw:drawSegment( -- 1066
		Vec2(0, barH), -- 1066
		Vec2(w, barH), -- 1066
		0.9, -- 1066
		toColor( -- 1066
			PALETTE.silkDim, -- 1066
			math.floor(86 * fade + 0.5) -- 1066
		) -- 1066
	) -- 1066
	uiInkDraw:drawSegment( -- 1067
		Vec2(0, h - barH), -- 1067
		Vec2(w, h - barH), -- 1067
		0.9, -- 1067
		toColor( -- 1067
			PALETTE.silkDim, -- 1067
			math.floor(86 * fade + 0.5) -- 1067
		) -- 1067
	) -- 1067
	local lineAlpha = fade * smoothstep(0.18, 0.3, prog) * (1 - smoothstep(0.86, 0.98, prog)) -- 1070
	if lineAlpha > 0.02 then -- 1070
		drawSilkVeil( -- 1072
			uiDraw, -- 1072
			uiArt, -- 1072
			"p05_sub_veil", -- 1072
			w * 0.5, -- 1072
			42, -- 1072
			740, -- 1072
			44, -- 1072
			PALETTE.inkWash, -- 1072
			0.86 * lineAlpha, -- 1072
			7 -- 1072
		) -- 1072
		drawHairline( -- 1073
			uiInkDraw, -- 1073
			uiArt, -- 1073
			"p05_sub_line", -- 1073
			w * 0.5, -- 1073
			62, -- 1073
			520, -- 1073
			PALETTE.silkDim, -- 1073
			0.52 * lineAlpha, -- 1073
			true, -- 1073
			8 -- 1073
		) -- 1073
		ctx.texts:put( -- 1074
			"sm", -- 1074
			LINE_P05, -- 1074
			w * 0.5, -- 1074
			42, -- 1074
			toColor(PALETTE.textBright), -- 1074
			0.5, -- 1074
			0.5, -- 1074
			"Center", -- 1074
			0.8, -- 1074
			lineAlpha, -- 1074
			0.08 -- 1074
		) -- 1074
	end -- 1074
end -- 985
function CuffShotsPlugin.prototype.renderP05ExitBridge(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1079
	local enter = smoothstep(0, 0.12, t) -- 1089
	local out = smoothstep(0.66, 1, t) -- 1090
	local alpha = enter * (1 - out) -- 1091
	if alpha <= 0.02 then -- 1091
		return -- 1093
	end -- 1093
	local pinchT = smoothstep(0.14, 0.34, t) * (1 - out) -- 1095
	____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1096
		wristX = w * 0.27 - out * 260, -- 1097
		wristY = h * 0.4, -- 1098
		angleRad = -0.05, -- 1099
		scale = 1.04, -- 1100
		pose = pinchT > 0.25 and "pinch" or "open", -- 1101
		opacity = alpha * 0.95, -- 1102
		stitchHighlight = 0.45 + 0.28 * pinchT, -- 1103
		uiArt = uiArt, -- 1104
		instanceKey = "p05_live_zhou_cuff", -- 1105
		layer = 4 -- 1106
	}) -- 1106
	drawChildHand( -- 1108
		uiDraw, -- 1109
		w * 0.39 + out * 30, -- 1110
		h * 0.37 - out * 10, -- 1111
		math.pi + 0.1, -- 1112
		1.02, -- 1113
		out > 0.32 and "open_fingers" or "clutch", -- 1114
		alpha * 0.94, -- 1115
		true, -- 1116
		uiArt, -- 1117
		"p05_live_child_hand", -- 1118
		5 -- 1119
	) -- 1119
	local lineAlpha = smoothstep(0.08, 0.22, t) * (1 - smoothstep(0.82, 0.98, t)) -- 1121
	if lineAlpha > 0.02 then -- 1121
		local subY = 92 -- 1123
		drawSilkVeil( -- 1124
			uiDraw, -- 1124
			uiArt, -- 1124
			"p05_live_veil", -- 1124
			w * 0.5, -- 1124
			subY, -- 1124
			760, -- 1124
			44, -- 1124
			PALETTE.inkWash, -- 1124
			0.86 * lineAlpha, -- 1124
			7 -- 1124
		) -- 1124
		drawHairline( -- 1125
			uiInkDraw, -- 1125
			uiArt, -- 1125
			"p05_live_line", -- 1125
			w * 0.5, -- 1125
			subY + 20, -- 1125
			520, -- 1125
			PALETTE.silkDim, -- 1125
			0.52 * lineAlpha, -- 1125
			true, -- 1125
			8 -- 1125
		) -- 1125
		ctx.texts:put( -- 1126
			"sm", -- 1126
			LINE_P05, -- 1126
			w * 0.5, -- 1126
			subY, -- 1126
			toColor(PALETTE.textBright), -- 1126
			0.5, -- 1126
			0.5, -- 1126
			"Center", -- 1126
			0.8, -- 1126
			lineAlpha, -- 1126
			0.08 -- 1126
		) -- 1126
	end -- 1126
end -- 1079
function CuffShotsPlugin.prototype.renderG05LiveShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1135
	local view = ctx.view -- 1144
	local gr = view.gateReunion -- 1145
	local completed = ctx.p.phase == "gate-hand" or gr.completed -- 1146
	local ext = clamp01(self.g05SleeveExtend) -- 1147
	if not completed then -- 1147
		if ext > 0.008 then -- 1147
			local veilA = math.floor(138 * clamp01(ext * 1.15) + 0.5) -- 1151
			fillVGradRect( -- 1152
				uiDraw, -- 1152
				0, -- 1152
				h * 0.26, -- 1152
				w, -- 1152
				h * 0.18, -- 1152
				Color(8, 11, 18, 0), -- 1152
				Color(8, 11, 18, veilA) -- 1152
			) -- 1152
			fillVGradRect( -- 1153
				uiDraw, -- 1153
				0, -- 1153
				h * 0.44, -- 1153
				w, -- 1153
				h * 0.18, -- 1153
				Color(8, 11, 18, veilA), -- 1153
				Color(8, 11, 18, 0) -- 1153
			) -- 1153
			local cuffX = -56 + ext * (w * 0.42 + 56) -- 1155
			local cuffY = h * 0.44 + math.sin(self.animTime * 2.2) * 2 -- 1156
			____exports.drawPatchedCuff( -- 1157
				uiDraw, -- 1157
				uiGlow, -- 1157
				{ -- 1157
					wristX = cuffX, -- 1158
					wristY = cuffY, -- 1159
					angleRad = -0.05, -- 1160
					scale = 1.22, -- 1161
					pose = ext > 0.82 and "clasp" or "reach", -- 1162
					opacity = clamp01(0.32 + ext * 0.68), -- 1163
					stitchHighlight = 0.35 + 0.6 * ext, -- 1164
					uiArt = uiArt, -- 1165
					instanceKey = "g05_live_zhou_cuff", -- 1166
					layer = 4 -- 1167
				} -- 1167
			) -- 1167
			local childX = w * 0.66 - ext * (w * 0.13) -- 1170
			local childY = h * 0.41 + ext * 14 -- 1171
			drawChildHand( -- 1172
				uiDraw, -- 1173
				childX, -- 1174
				childY, -- 1175
				math.pi + 0.08, -- 1176
				1.2, -- 1177
				ext > 0.88 and "clasp" or "reach_up", -- 1178
				clamp01(0.25 + ext * 0.75), -- 1179
				true, -- 1180
				uiArt, -- 1181
				"g05_live_child_hand", -- 1182
				5 -- 1183
			) -- 1183
			local barW = 240 -- 1187
			local bx0 = w * 0.5 - barW * 0.5 -- 1188
			local by0 = 18 -- 1189
			uiInkDraw:drawSegment( -- 1190
				Vec2(bx0, by0), -- 1190
				Vec2(bx0 + barW, by0), -- 1190
				1.2, -- 1190
				toColor(PALETTE.silkDim, 110) -- 1190
			) -- 1190
			uiInkDraw:drawSegment( -- 1191
				Vec2(bx0, by0), -- 1191
				Vec2(bx0 + barW * ext, by0), -- 1191
				2.4, -- 1191
				toColor(PALETTE.amberCore, 230) -- 1191
			) -- 1191
		else -- 1191
			local peekPulse = 0.5 + 0.5 * math.sin(self.animTime * 2.4) -- 1193
			____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1194
				wristX = -120 + peekPulse * 18, -- 1195
				wristY = h * 0.44, -- 1196
				angleRad = -0.04, -- 1197
				scale = 1.16, -- 1198
				pose = "open", -- 1199
				opacity = 0.42 + 0.24 * peekPulse, -- 1200
				stitchHighlight = 0.35 * peekPulse, -- 1201
				uiArt = uiArt, -- 1202
				instanceKey = "g05_live_zhou_cuff", -- 1203
				layer = 4 -- 1204
			}) -- 1204
		end -- 1204
		if view.assistHintsEnabled then -- 1204
			drawSilkVeil( -- 1209
				uiDraw, -- 1209
				uiArt, -- 1209
				"g05_assist_veil", -- 1209
				w * 0.5, -- 1209
				h - 26, -- 1209
				280, -- 1209
				28, -- 1209
				PALETTE.inkWash, -- 1209
				0.72, -- 1209
				7 -- 1209
			) -- 1209
			ctx.texts:put( -- 1210
				"xs", -- 1211
				getActiveTarget():adaptHintSentence("按住 E 牵住伸来的袖口", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1212
				w * 0.5, -- 1213
				h - 26, -- 1214
				toColor(PALETTE.amberCore), -- 1215
				0.5, -- 1216
				0.5, -- 1217
				"Center", -- 1218
				1.2, -- 1219
				0.9, -- 1220
				0.08 -- 1221
			) -- 1221
		end -- 1221
		return -- 1224
	end -- 1224
	local t = self.g05ReunionElapsed -- 1228
	local claspPull = smoothstep(0, 0.35, t) -- 1229
	local tilt = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, t) -- 1230
	local armDropY = tilt * (h * 0.3) -- 1231
	local portraitAlpha = smoothstep(0.28, 0.85, t) -- 1234
	if portraitAlpha > 0.02 then -- 1234
		drawZhouShuReunionPortrait( -- 1236
			uiDraw, -- 1236
			uiInkDraw, -- 1236
			uiArt, -- 1236
			uiGlow, -- 1236
			w, -- 1236
			h, -- 1236
			(1 - portraitAlpha) * 28, -- 1236
			portraitAlpha -- 1236
		) -- 1236
	end -- 1236
	local claspFade = 1 - smoothstep(0.55, 1.08, t) -- 1240
	if claspFade > 0.02 then -- 1240
		____exports.drawPatchedCuff(uiDraw, uiGlow, { -- 1242
			wristX = w * 0.44, -- 1243
			wristY = h * 0.42 - armDropY, -- 1244
			angleRad = -0.05 + tilt * 0.22, -- 1245
			scale = 1.22, -- 1246
			pose = "clasp", -- 1247
			opacity = claspFade, -- 1248
			stitchHighlight = 0.72 * (1 - tilt * 0.5), -- 1249
			cuffPullBack = claspPull * 0.85, -- 1250
			warmth = tilt * 0.32, -- 1251
			uiArt = uiArt, -- 1252
			instanceKey = "g05_live_zhou_cuff", -- 1253
			layer = 4 -- 1254
		}) -- 1254
		drawChildHand( -- 1256
			uiDraw, -- 1257
			w * 0.56, -- 1258
			h * 0.4 - armDropY, -- 1259
			math.pi + 0.05 - tilt * 0.14, -- 1260
			1.2, -- 1261
			"clasp", -- 1262
			claspFade, -- 1263
			true, -- 1264
			uiArt, -- 1265
			"g05_live_child_hand", -- 1266
			5 -- 1267
		) -- 1267
	end -- 1267
	local barH = math.floor(h * 0.068 + 0.5) -- 1271
	if portraitAlpha > 0.05 then -- 1271
		uiInkDraw:drawRect( -- 1273
			Rect(0, 0, w, barH), -- 1273
			Color( -- 1273
				6, -- 1273
				8, -- 1273
				12, -- 1273
				math.floor(244 * portraitAlpha + 0.5) -- 1273
			) -- 1273
		) -- 1273
		uiInkDraw:drawRect( -- 1274
			Rect(0, h - barH, w, barH), -- 1274
			Color( -- 1274
				6, -- 1274
				8, -- 1274
				12, -- 1274
				math.floor(244 * portraitAlpha + 0.5) -- 1274
			) -- 1274
		) -- 1274
	end -- 1274
	local lineAlpha = smoothstep(0.75, 0.98, t) -- 1278
	if lineAlpha > 0.02 then -- 1278
		drawSilkVeil( -- 1280
			uiDraw, -- 1280
			uiArt, -- 1280
			"g05_line_veil", -- 1280
			w * 0.5, -- 1280
			42, -- 1280
			420, -- 1280
			44, -- 1280
			PALETTE.inkWash, -- 1280
			0.86 * lineAlpha, -- 1280
			7 -- 1280
		) -- 1280
		drawHairline( -- 1281
			uiInkDraw, -- 1281
			uiArt, -- 1281
			"g05_line_bar", -- 1281
			w * 0.5, -- 1281
			62, -- 1281
			260, -- 1281
			PALETTE.amber, -- 1281
			0.58 * lineAlpha, -- 1281
			true, -- 1281
			8 -- 1281
		) -- 1281
		ctx.texts:put( -- 1282
			"sm", -- 1282
			LINE_G05, -- 1282
			w * 0.5, -- 1282
			42, -- 1282
			toColor(PALETTE.textBright), -- 1282
			0.5, -- 1282
			0.5, -- 1282
			"Center", -- 1282
			2.2, -- 1282
			lineAlpha, -- 1282
			0.08 -- 1282
		) -- 1282
	end -- 1282
end -- 1135
function CuffShotsPlugin.prototype.renderG05RehearsalShot(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, t) -- 1287
	local holdExt = smoothstep(0.55, 1.45, t) -- 1297
	local tilt = smoothstep(1.55, 2.55, t) -- 1298
	local claspPull = smoothstep(1.4, 1.75, t) -- 1299
	local armDropY = tilt * (h * 0.28) -- 1300
	local barH = math.floor(h * 0.072 + 0.5) -- 1301
	uiDraw:drawRect( -- 1303
		Rect(0, 0, w, h), -- 1303
		Color(7, 9, 14, 248) -- 1303
	) -- 1303
	local bgTop = lerpRGBA( -- 1304
		rgba(16, 24, 36, 250), -- 1304
		rgba(20, 26, 36, 250), -- 1304
		tilt -- 1304
	) -- 1304
	local bgBot = lerpRGBA( -- 1305
		rgba(10, 15, 24, 250), -- 1305
		rgba(14, 18, 26, 250), -- 1305
		tilt -- 1305
	) -- 1305
	fillVGradRect( -- 1306
		uiDraw, -- 1306
		0, -- 1306
		barH, -- 1306
		w, -- 1306
		h - barH * 2, -- 1306
		toColor(bgBot), -- 1306
		toColor(bgTop) -- 1306
	) -- 1306
	if tilt > 0.04 then -- 1306
		drawZhouShuReunionPortrait( -- 1309
			uiDraw, -- 1309
			uiInkDraw, -- 1309
			uiArt, -- 1309
			uiGlow, -- 1309
			w, -- 1309
			h, -- 1309
			(1 - tilt) * 28, -- 1309
			tilt -- 1309
		) -- 1309
	end -- 1309
	local handFade = 1 - smoothstep(1.75, 2.38, t) -- 1312
	if handFade > 0.02 then -- 1312
		____exports.drawPatchedCuff( -- 1314
			uiDraw, -- 1314
			uiGlow, -- 1314
			{ -- 1314
				wristX = w * 0.06 + holdExt * (w * 0.38), -- 1315
				wristY = h * 0.48 - armDropY, -- 1316
				angleRad = -0.05 + tilt * 0.2, -- 1317
				scale = 1.24, -- 1318
				pose = t >= 1.4 and "clasp" or "reach", -- 1319
				opacity = clamp01(0.28 + holdExt * 0.72) * handFade, -- 1320
				stitchHighlight = 0.45 + 0.45 * holdExt * (1 - tilt * 0.4), -- 1321
				cuffPullBack = claspPull * 0.85, -- 1322
				warmth = tilt * 0.32, -- 1323
				uiArt = uiArt, -- 1324
				instanceKey = "g05_reh_zhou_cuff", -- 1325
				layer = 4 -- 1326
			} -- 1326
		) -- 1326
		drawChildHand( -- 1328
			uiDraw, -- 1329
			w * 0.68 - holdExt * (w * 0.12), -- 1330
			h * 0.44 - armDropY, -- 1331
			math.pi + 0.06, -- 1332
			1.22, -- 1333
			t >= 1.4 and "clasp" or "reach_up", -- 1334
			clamp01(0.35 + holdExt * 0.65) * handFade, -- 1335
			true, -- 1336
			uiArt, -- 1337
			"g05_reh_child_hand", -- 1338
			5 -- 1339
		) -- 1339
	end -- 1339
	uiInkDraw:drawRect( -- 1343
		Rect(0, 0, w, barH), -- 1343
		Color(6, 8, 12, 246) -- 1343
	) -- 1343
	uiInkDraw:drawRect( -- 1344
		Rect(0, h - barH, w, barH), -- 1344
		Color(6, 8, 12, 246) -- 1344
	) -- 1344
	uiInkDraw:drawSegment( -- 1345
		Vec2(0, barH), -- 1345
		Vec2(w, barH), -- 1345
		0.9, -- 1345
		toColor(PALETTE.silkDim, 86) -- 1345
	) -- 1345
	uiInkDraw:drawSegment( -- 1346
		Vec2(0, h - barH), -- 1346
		Vec2(w, h - barH), -- 1346
		0.9, -- 1346
		toColor(PALETTE.silkDim, 86) -- 1346
	) -- 1346
	local lineAlpha = smoothstep(2.35, 2.65, t) -- 1348
	if lineAlpha > 0.02 then -- 1348
		drawSilkVeil( -- 1350
			uiDraw, -- 1350
			uiArt, -- 1350
			"g05_reh_veil", -- 1350
			w * 0.5, -- 1350
			42, -- 1350
			420, -- 1350
			44, -- 1350
			PALETTE.inkWash, -- 1350
			0.86 * lineAlpha, -- 1350
			7 -- 1350
		) -- 1350
		drawHairline( -- 1351
			uiInkDraw, -- 1351
			uiArt, -- 1351
			"g05_reh_bar", -- 1351
			w * 0.5, -- 1351
			62, -- 1351
			260, -- 1351
			PALETTE.amber, -- 1351
			0.58 * lineAlpha, -- 1351
			true, -- 1351
			8 -- 1351
		) -- 1351
		ctx.texts:put( -- 1352
			"sm", -- 1352
			LINE_G05, -- 1352
			w * 0.5, -- 1352
			42, -- 1352
			toColor(PALETTE.textBright), -- 1352
			0.5, -- 1352
			0.5, -- 1352
			"Center", -- 1352
			2.2, -- 1352
			lineAlpha, -- 1352
			0.08 -- 1352
		) -- 1352
	end -- 1352
end -- 1287
function ____exports.createCuffShotsPlugin() -- 1357
	return __TS__New(____exports.CuffShotsPlugin) -- 1358
end -- 1357
--- 供 M1 合流接线与本地验收脚本使用的一键注册辅助：
-- M1 在 frontend.ts 仅需调用 registerFe01Plugins(this)（不修改热点文件大块代码）。
function ____exports.registerFe01Plugins(fe) -- 1365
	local gateTransition = createGateTransitionPlugin() -- 1369
	local cuffShots = ____exports.createCuffShotsPlugin() -- 1370
	fe:registerPlugin(gateTransition) -- 1371
	fe:registerPlugin(cuffShots) -- 1372
	return {gateTransition = gateTransition, cuffShots = cuffShots} -- 1373
end -- 1365
return ____exports -- 1365