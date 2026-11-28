-- [ts]: slideshow.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local Color = ____Dora.Color -- 11
local Rect = ____Dora.Rect -- 11
local Vec2 = ____Dora.Vec2 -- 11
local ____theme = require("Script.watch.fe.theme") -- 13
local PALETTE = ____theme.PALETTE -- 14
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 16
local drawHairline = ____theme.drawHairline -- 17
local drawSilkVeil = ____theme.drawSilkVeil -- 18
local fillHGradRect = ____theme.fillHGradRect -- 19
local fillRadialGlow = ____theme.fillRadialGlow -- 20
local fillVGradRect = ____theme.fillVGradRect -- 21
local toColor = ____theme.toColor -- 22
local WHITE = Color(255, 255, 255, 255) -- 26
local function clamp01(v) -- 75
	if v <= 0 then -- 75
		return 0 -- 77
	end -- 77
	if v >= 1 then -- 77
		return 1 -- 80
	end -- 80
	return v -- 82
end -- 75
local function smooth(v) -- 85
	local t = clamp01(v) -- 86
	return t * t * (3 - 2 * t) -- 87
end -- 85
--- 计算居中的 16:9 像素特写画框区域（用于 P03/P05/G05/E02 回柜等绘卷特写）
function ____exports.computeCenteredSlideRect(uiW, uiH, maxW, maxH, offsetY) -- 91
	if maxW == nil then -- 91
		maxW = 880 -- 94
	end -- 94
	if maxH == nil then -- 94
		maxH = 495 -- 95
	end -- 95
	if offsetY == nil then -- 95
		offsetY = 14 -- 96
	end -- 96
	local availW = math.min(maxW, uiW - 96) -- 98
	local availH = math.min(maxH, uiH - 148) -- 99
	local aspect = 16 / 9 -- 100
	local w = availW -- 101
	local h = w / aspect -- 102
	if h > availH then -- 102
		h = availH -- 104
		w = h * aspect -- 105
	end -- 105
	return { -- 107
		x = math.floor((uiW - w) * 0.5 + 0.5), -- 108
		y = math.floor((uiH - h) * 0.5 + offsetY + 0.5), -- 109
		w = math.floor(w + 0.5), -- 110
		h = math.floor(h + 0.5) -- 111
	} -- 111
end -- 91
--- 计算全屏覆盖 16:9 像素画幅区域（cover 适配，无黑边漏缝）
function ____exports.computeFullscreenSlideRect(uiW, uiH) -- 116
	local aspect = 16 / 9 -- 117
	local w = uiW -- 118
	local h = w / aspect -- 119
	if h < uiH then -- 119
		h = uiH -- 121
		w = h * aspect -- 122
	end -- 122
	return { -- 124
		x = math.floor((uiW - w) * 0.5 + 0.5), -- 125
		y = math.floor((uiH - h) * 0.5 + 0.5), -- 126
		w = math.floor(w + 0.5), -- 127
		h = math.floor(h + 0.5) -- 128
	} -- 128
end -- 116
--- 绘制单张像素幻灯片（支持微运镜与安全回退底幕）
function ____exports.drawPixelSlidePlate(uiDraw, _uiInkDraw, uiArt, slotKey, instanceKey, rect, opacity, layer, panX, panY, zoom, tint) -- 133
	if opacity == nil then -- 133
		opacity = 1 -- 140
	end -- 140
	if layer == nil then -- 140
		layer = 2 -- 141
	end -- 141
	if panX == nil then -- 141
		panX = 0 -- 142
	end -- 142
	if panY == nil then -- 142
		panY = 0 -- 143
	end -- 143
	if zoom == nil then -- 143
		zoom = 1 -- 144
	end -- 144
	local op = clamp01(opacity) -- 147
	if op <= 0.004 then -- 147
		return false -- 149
	end -- 149
	local cx = rect.x + rect.w * 0.5 + panX * rect.w -- 151
	local cy = rect.y + rect.h * 0.5 + panY * rect.h -- 152
	local tw = math.floor(rect.w * zoom + 0.5) -- 153
	local th = math.floor(rect.h * zoom + 0.5) -- 154
	local col = tint ~= nil and toColor(tint, 255) or WHITE -- 155
	local placed = uiArt:tryPlace( -- 156
		slotKey, -- 156
		instanceKey, -- 156
		math.floor(cx + 0.5), -- 156
		math.floor(cy + 0.5), -- 156
		tw, -- 156
		th, -- 156
		{opacity = op, color = col, layer = layer} -- 156
	) -- 156
	if not placed then -- 156
		fillVGradRect( -- 162
			uiDraw, -- 163
			rect.x, -- 164
			rect.y, -- 165
			rect.w, -- 166
			rect.h, -- 167
			toColor( -- 168
				PALETTE.inkVoid, -- 168
				math.floor(235 * op + 0.5) -- 168
			), -- 168
			toColor( -- 169
				PALETTE.inkMist, -- 169
				math.floor(235 * op + 0.5) -- 169
			) -- 169
		) -- 169
	end -- 169
	return placed -- 172
end -- 133
--- 绘制绘卷玄漆外框、宋明海棠折角与电影黑边遮幅
function ____exports.drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, rect, uiW, uiH, opts) -- 176
	local op = clamp01(opts.opacity or 1) -- 185
	local frameOp = clamp01(opts.frameOpacity or 0) -- 186
	local baseLayer = opts.layer or 2 -- 187
	if frameOp > 0.01 then -- 187
		uiDraw:drawRect( -- 191
			Rect(0, 0, uiW, uiH), -- 191
			toColor( -- 191
				PALETTE.inkVoid, -- 191
				math.floor(182 * op * frameOp + 0.5) -- 191
			) -- 191
		) -- 191
		local pad = 8 -- 193
		uiDraw:drawRect( -- 194
			Rect(rect.x - pad, rect.y - pad - 3, rect.w + pad * 2, rect.h + pad * 2 + 3), -- 195
			Color( -- 196
				4, -- 196
				6, -- 196
				10, -- 196
				math.floor(215 * op * frameOp + 0.5) -- 196
			) -- 196
		) -- 196
		drawFiligreeCorners( -- 199
			uiInkDraw, -- 200
			uiArt, -- 201
			opts.instancePrefix .. "_corners", -- 202
			rect.x - 1, -- 203
			rect.y - 1, -- 204
			rect.w + 2, -- 205
			rect.h + 2, -- 206
			PALETTE.silkLine, -- 207
			0.62 * op * frameOp, -- 208
			26, -- 209
			true, -- 210
			baseLayer + 6 -- 211
		) -- 211
	end -- 211
	local barH = opts.letterboxH or 0 -- 215
	if barH > 0 then -- 215
		uiInkDraw:drawRect( -- 217
			Rect(0, uiH - barH, uiW, barH), -- 217
			toColor( -- 217
				PALETTE.inkVoid, -- 217
				math.floor(245 * op + 0.5) -- 217
			) -- 217
		) -- 217
		uiInkDraw:drawRect( -- 218
			Rect(0, 0, uiW, barH), -- 218
			toColor( -- 218
				PALETTE.inkVoid, -- 218
				math.floor(245 * op + 0.5) -- 218
			) -- 218
		) -- 218
		uiInkDraw:drawSegment( -- 219
			Vec2(0, uiH - barH), -- 219
			Vec2(uiW, uiH - barH), -- 219
			0.8, -- 219
			toColor( -- 219
				PALETTE.silkDim, -- 219
				math.floor(74 * op + 0.5) -- 219
			) -- 219
		) -- 219
		uiInkDraw:drawSegment( -- 220
			Vec2(0, barH), -- 220
			Vec2(uiW, barH), -- 220
			0.8, -- 220
			toColor( -- 220
				PALETTE.silkDim, -- 220
				math.floor(74 * op + 0.5) -- 220
			) -- 220
		) -- 220
	end -- 220
end -- 176
--- 播放一组时间轴驱动的像素幻灯片（明月绘卷内核）。
-- - 自动按 t 选择当前关键帧；
-- - dark_dip 模式在帧界做短暂暗幕沉顿（零半透明重影，电影剪辑感强）；
-- - crossfade 模式用于同机位光影变化（如西窗亮灯、风台叠化、井底同心反光）。
function ____exports.drawPixelSlideshow(uiDraw, uiInkDraw, uiArt, keyframes, t, rect, uiW, uiH, opts) -- 230
	if #keyframes == 0 then -- 230
		return -1 -- 242
	end -- 242
	local baseOp = clamp01(opts.opacity or 1) -- 244
	local baseLayer = opts.layer or 2 -- 245
	local shakeX = opts.shakeX or 0 -- 246
	local shakeY = opts.shakeY or 0 -- 247
	local shiftedRect = { -- 248
		x = math.floor(rect.x + shakeX + 0.5), -- 249
		y = math.floor(rect.y + shakeY + 0.5), -- 250
		w = rect.w, -- 251
		h = rect.h -- 252
	} -- 252
	local activeIdx = #keyframes - 1 -- 255
	local i = 0 -- 256
	do -- 256
		i = 0 -- 257
		while i < #keyframes do -- 257
			if t < keyframes[i + 1]["end"] or i == #keyframes - 1 then -- 257
				activeIdx = i -- 259
				break -- 260
			end -- 260
			i = i + 1 -- 257
		end -- 257
	end -- 257
	local kf = keyframes[activeIdx + 1] -- 264
	local span = math.max(0.0001, kf["end"] - kf.start) -- 265
	local localU = clamp01((t - kf.start) / span) -- 266
	local easedU = smooth(localU) -- 267
	local panX = (kf.panFromX or 0) + ((kf.panToX or 0) - (kf.panFromX or 0)) * easedU -- 268
	local panY = (kf.panFromY or 0) + ((kf.panToY or 0) - (kf.panFromY or 0)) * easedU -- 269
	local zoom = (kf.zoomFrom or 1) + ((kf.zoomTo or 1) - (kf.zoomFrom or 1)) * easedU -- 270
	local trans = kf.transition or "dark_dip" -- 272
	local transDur = math.max(0.001, kf.transitionDur or 0.22) -- 273
	local sinceStart = t - kf.start -- 274
	local dipShade = 0 -- 276
	if activeIdx > 0 and sinceStart >= 0 and sinceStart < transDur then -- 276
		local prev = keyframes[activeIdx] -- 278
		local prevPanX = prev.panToX or 0 -- 279
		local prevPanY = prev.panToY or 0 -- 280
		local prevZoom = prev.zoomTo or 1 -- 281
		local k = smooth(sinceStart / transDur) -- 282
		if trans == "crossfade" then -- 282
			____exports.drawPixelSlidePlate( -- 285
				uiDraw, -- 286
				uiInkDraw, -- 286
				uiArt, -- 286
				prev.slot, -- 287
				(opts.instancePrefix .. "_prev_") .. tostring(activeIdx - 1), -- 287
				shiftedRect, -- 288
				baseOp * (1 - k * 0.65), -- 288
				baseLayer, -- 288
				prevPanX, -- 289
				prevPanY, -- 289
				prevZoom, -- 289
				prev.tint -- 289
			) -- 289
			____exports.drawPixelSlidePlate( -- 291
				uiDraw, -- 292
				uiInkDraw, -- 292
				uiArt, -- 292
				kf.slot, -- 293
				(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 293
				shiftedRect, -- 294
				baseOp * k, -- 294
				baseLayer + 1, -- 294
				panX, -- 295
				panY, -- 295
				zoom, -- 295
				kf.tint -- 295
			) -- 295
		elseif trans == "dark_dip" then -- 295
			if k < 0.45 then -- 295
				local prevOp = 1 - smooth(k / 0.45) -- 299
				____exports.drawPixelSlidePlate( -- 300
					uiDraw, -- 301
					uiInkDraw, -- 301
					uiArt, -- 301
					prev.slot, -- 302
					(opts.instancePrefix .. "_prev_") .. tostring(activeIdx - 1), -- 302
					shiftedRect, -- 303
					baseOp * prevOp, -- 303
					baseLayer, -- 303
					prevPanX, -- 304
					prevPanY, -- 304
					prevZoom, -- 304
					prev.tint -- 304
				) -- 304
				dipShade = 0.85 * smooth(k / 0.45) -- 306
			else -- 306
				local curOp = smooth((k - 0.45) / 0.55) -- 308
				____exports.drawPixelSlidePlate( -- 309
					uiDraw, -- 310
					uiInkDraw, -- 310
					uiArt, -- 310
					kf.slot, -- 311
					(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 311
					shiftedRect, -- 312
					baseOp * curOp, -- 312
					baseLayer, -- 312
					panX, -- 313
					panY, -- 313
					zoom, -- 313
					kf.tint -- 313
				) -- 313
				dipShade = 0.85 * (1 - curOp) -- 315
			end -- 315
		else -- 315
			____exports.drawPixelSlidePlate( -- 318
				uiDraw, -- 319
				uiInkDraw, -- 319
				uiArt, -- 319
				kf.slot, -- 320
				(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 320
				shiftedRect, -- 321
				baseOp, -- 321
				baseLayer, -- 321
				panX, -- 322
				panY, -- 322
				zoom, -- 322
				kf.tint -- 322
			) -- 322
		end -- 322
	else -- 322
		____exports.drawPixelSlidePlate( -- 326
			uiDraw, -- 327
			uiInkDraw, -- 327
			uiArt, -- 327
			kf.slot, -- 328
			(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 328
			shiftedRect, -- 329
			baseOp, -- 329
			baseLayer, -- 329
			panX, -- 330
			panY, -- 330
			zoom, -- 330
			kf.tint -- 330
		) -- 330
	end -- 330
	if dipShade > 0.01 then -- 330
		uiInkDraw:drawRect( -- 335
			Rect(shiftedRect.x, shiftedRect.y, shiftedRect.w, shiftedRect.h), -- 336
			toColor( -- 337
				PALETTE.inkVoid, -- 337
				math.floor(235 * dipShade * baseOp + 0.5) -- 337
			) -- 337
		) -- 337
	end -- 337
	local moteAlpha = baseOp * (1 - dipShade) * 0.58 -- 342
	if moteAlpha > 0.04 then -- 342
		do -- 342
			local m = 0 -- 344
			while m < 14 do -- 344
				local seed = m * 37.3 + 11.7 -- 345
				local u = (math.sin(seed) * 43758.5453 % 1 + 1) % 1 -- 346
				local v = (math.sin(seed * 1.7) * 24634.6345 % 1 + 1) % 1 -- 347
				local mx = shiftedRect.x + (u + t * (0.018 + m % 3 * 0.007)) % 1 * shiftedRect.w -- 348
				local my = shiftedRect.y + (v + t * (0.012 + m % 2 * 0.008)) % 1 * shiftedRect.h -- 349
				local tw = 0.45 + 0.55 * math.sin(t * 2.4 + m * 1.9) -- 350
				local col = m % 3 == 0 and PALETTE.amberCore or PALETTE.jadeMist -- 351
				uiInkDraw:drawDot( -- 352
					Vec2(mx, my), -- 352
					1.1 + m % 2 * 0.65, -- 352
					toColor(col, 118 * tw * moteAlpha) -- 352
				) -- 352
				m = m + 1 -- 344
			end -- 344
		end -- 344
	end -- 344
	____exports.drawSlideFrameChrome( -- 356
		uiDraw, -- 356
		uiInkDraw, -- 356
		uiArt, -- 356
		shiftedRect, -- 356
		uiW, -- 356
		uiH, -- 356
		opts -- 356
	) -- 356
	return activeIdx -- 357
end -- 230
--- 绘制统一宋明烟黛过场字幕条
function ____exports.drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, texts, keyPrefix, text, cx, cy, alpha, color, layer) -- 361
	if color == nil then -- 361
		color = PALETTE.textBright -- 371
	end -- 371
	if layer == nil then -- 371
		layer = 8 -- 372
	end -- 372
	local a = clamp01(alpha) -- 374
	if a <= 0.01 or text == "" then -- 374
		return -- 376
	end -- 376
	local veilW = math.max( -- 378
		320, -- 378
		math.min(760, #text * 15 + 140) -- 378
	) -- 378
	drawSilkVeil( -- 379
		uiDraw, -- 379
		uiArt, -- 379
		keyPrefix .. "_veil", -- 379
		cx, -- 379
		cy, -- 379
		veilW, -- 379
		44, -- 379
		PALETTE.inkWash, -- 379
		0.84 * a, -- 379
		layer -- 379
	) -- 379
	drawHairline( -- 380
		uiInkDraw, -- 380
		uiArt, -- 380
		keyPrefix .. "_hair", -- 380
		cx, -- 380
		cy + 20, -- 380
		veilW * 0.62, -- 380
		PALETTE.silkDim, -- 380
		0.48 * a, -- 380
		true, -- 380
		layer + 1 -- 380
	) -- 380
	texts:put( -- 381
		"sm", -- 381
		text, -- 381
		cx, -- 381
		cy, -- 381
		toColor(color), -- 381
		0.5, -- 381
		0.5, -- 381
		"Center", -- 381
		1.2, -- 381
		a, -- 381
		0.08 -- 381
	) -- 381
end -- 361
--- 小满单人线「冷月像素电影剧场」氛围调色与四周压边暗角。
-- 绝不使用硬描边或多边形块，仅用克制冷靛月雾渐变与四角柔光暗晕衬托像素场景。
function ____exports.drawChildColdMoonGrade(draw, glow, w, h, intensity, warmShift) -- 388
	if intensity == nil then -- 388
		intensity = 1 -- 393
	end -- 393
	if warmShift == nil then -- 393
		warmShift = 0 -- 394
	end -- 394
	local k = clamp01(intensity) -- 396
	if k <= 0.01 then -- 396
		return -- 398
	end -- 398
	local coldAmt = k * (1 - clamp01(warmShift) * 0.72) -- 400
	local zeroVoid = Color(10, 14, 22, 0) -- 401
	fillVGradRect( -- 403
		draw, -- 403
		0, -- 403
		h * 0.64, -- 403
		w, -- 403
		h * 0.36, -- 403
		zeroVoid, -- 403
		Color( -- 403
			8, -- 403
			12, -- 403
			22, -- 403
			math.floor(96 * coldAmt + 0.5) -- 403
		) -- 403
	) -- 403
	fillVGradRect( -- 404
		draw, -- 404
		0, -- 404
		0, -- 404
		w, -- 404
		h * 0.14, -- 404
		Color( -- 404
			6, -- 404
			9, -- 404
			16, -- 404
			math.floor(115 * k + 0.5) -- 404
		), -- 404
		zeroVoid -- 404
	) -- 404
	fillHGradRect( -- 406
		draw, -- 406
		0, -- 406
		0, -- 406
		w * 0.14, -- 406
		h, -- 406
		Color( -- 406
			7, -- 406
			10, -- 406
			18, -- 406
			math.floor(112 * coldAmt + 0.5) -- 406
		), -- 406
		zeroVoid -- 406
	) -- 406
	fillHGradRect( -- 407
		draw, -- 407
		w * 0.86, -- 407
		0, -- 407
		w * 0.14, -- 407
		h, -- 407
		zeroVoid, -- 407
		Color( -- 407
			7, -- 407
			10, -- 407
			18, -- 407
			math.floor(112 * coldAmt + 0.5) -- 407
		) -- 407
	) -- 407
	if coldAmt > 0.05 then -- 407
		fillRadialGlow( -- 410
			glow, -- 411
			w * 0.72, -- 412
			h * 0.78, -- 413
			w * 0.38, -- 414
			h * 0.34, -- 415
			Color( -- 416
				138, -- 416
				174, -- 416
				206, -- 416
				math.floor(24 * coldAmt + 0.5) -- 416
			), -- 416
			Color(24, 42, 68, 0), -- 417
			14 -- 418
		) -- 418
	end -- 418
end -- 388
--- 绘制全屏硬核木刻暗黑漫画逐帧序列（确定性时间轴，暂停即刻冻结）
function ____exports.drawComicSequence(uiDraw, uiInkDraw, uiArt, keyframes, t, uiW, uiH, opts) -- 474
	if #keyframes == 0 then -- 474
		return -1 -- 485
	end -- 485
	local baseOp = clamp01(opts.opacity or 1) -- 487
	if baseOp <= 0.004 then -- 487
		return -1 -- 489
	end -- 489
	local baseLayer = opts.layer or 2 -- 491
	local barH = opts.letterboxH or math.floor(uiH * 0.068 + 0.5) -- 492
	uiDraw:drawRect( -- 495
		Rect(0, 0, uiW, uiH), -- 495
		Color( -- 495
			6, -- 495
			7, -- 495
			10, -- 495
			math.floor(255 * baseOp + 0.5) -- 495
		) -- 495
	) -- 495
	local activeIdx = #keyframes - 1 -- 497
	local i = 0 -- 498
	do -- 498
		i = 0 -- 499
		while i < #keyframes do -- 499
			if t < keyframes[i + 1]["end"] or i == #keyframes - 1 then -- 499
				activeIdx = i -- 501
				break -- 502
			end -- 502
			i = i + 1 -- 499
		end -- 499
	end -- 499
	local kf = keyframes[activeIdx + 1] -- 506
	local span = math.max(0.0001, kf["end"] - kf.start) -- 507
	local localT = math.max(0, t - kf.start) -- 508
	local localU = clamp01(localT / span) -- 509
	local easedU = smooth(localU) -- 510
	local panX = (kf.panFromX or 0) + ((kf.panToX or 0) - (kf.panFromX or 0)) * easedU -- 512
	local panY = (kf.panFromY or 0) + ((kf.panToY or 0) - (kf.panFromY or 0)) * easedU -- 513
	local zoom = (kf.zoomFrom or 1) + ((kf.zoomTo or 1) - (kf.zoomFrom or 1)) * easedU -- 514
	local shakeX = 0 -- 517
	local shakeY = 0 -- 518
	local amp = kf.shakeAmp or 0 -- 519
	if amp > 0.05 then -- 519
		local decay = math.exp(-localT * 13.5) -- 521
		if decay > 0.02 then -- 521
			local freq = kf.shakeFreq or 58 -- 523
			local steppedT = math.floor(localT * 24) / 24 -- 525
			shakeX = math.floor(math.sin(steppedT * freq + 0.6) * amp * decay + 0.5) -- 526
			shakeY = math.floor(math.cos(steppedT * freq * 1.17) * amp * 0.68 * decay + 0.5) -- 527
		end -- 527
	end -- 527
	local coverRect = ____exports.computeFullscreenSlideRect(uiW, uiH) -- 531
	local shiftedRect = {x = coverRect.x + shakeX, y = coverRect.y + shakeY, w = coverRect.w, h = coverRect.h} -- 532
	local trans = kf.transition or "cut" -- 539
	local transDur = math.max(0.001, kf.transitionDur or 0.1) -- 540
	if activeIdx > 0 and localT < transDur and trans == "slash_cut" then -- 540
		local prev = keyframes[activeIdx] -- 544
		local k = clamp01(localT / transDur) -- 545
		if k < 0.42 then -- 545
			____exports.drawPixelSlidePlate( -- 547
				uiDraw, -- 548
				uiInkDraw, -- 548
				uiArt, -- 548
				prev.slot, -- 549
				(opts.instancePrefix .. "_prev_") .. tostring(activeIdx - 1), -- 549
				coverRect, -- 550
				baseOp, -- 550
				baseLayer, -- 550
				prev.panToX or 0, -- 551
				prev.panToY or 0, -- 551
				prev.zoomTo or 1, -- 551
				prev.tint -- 551
			) -- 551
		else -- 551
			____exports.drawPixelSlidePlate( -- 554
				uiDraw, -- 555
				uiInkDraw, -- 555
				uiArt, -- 555
				kf.slot, -- 556
				(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 556
				shiftedRect, -- 557
				baseOp, -- 557
				baseLayer, -- 557
				panX, -- 558
				panY, -- 558
				zoom, -- 558
				kf.tint -- 558
			) -- 558
		end -- 558
		local slashAlpha = math.sin(k * math.pi) -- 562
		uiInkDraw:drawRect( -- 563
			Rect(0, 0, uiW, uiH), -- 563
			Color( -- 563
				6, -- 563
				7, -- 563
				10, -- 563
				math.floor(230 * slashAlpha * baseOp + 0.5) -- 563
			) -- 563
		) -- 563
		local sx0 = uiW * (0.86 - k * 0.14) -- 564
		local sx1 = uiW * (0.18 - k * 0.14) -- 565
		uiInkDraw:drawSegment( -- 566
			Vec2(sx0, uiH), -- 566
			Vec2(sx1, 0), -- 566
			5.5, -- 566
			Color( -- 566
				242, -- 566
				234, -- 566
				218, -- 566
				math.floor(240 * slashAlpha * baseOp + 0.5) -- 566
			) -- 566
		) -- 566
		uiInkDraw:drawSegment( -- 567
			Vec2(sx0 + 7, uiH), -- 567
			Vec2(sx1 + 7, 0), -- 567
			3, -- 567
			Color( -- 567
				196, -- 567
				44, -- 567
				44, -- 567
				math.floor(235 * slashAlpha * baseOp + 0.5) -- 567
			) -- 567
		) -- 567
	elseif activeIdx > 0 and localT < transDur and trans == "crossfade" then -- 567
		local prev = keyframes[activeIdx] -- 569
		local k = smooth(localT / transDur) -- 570
		____exports.drawPixelSlidePlate( -- 571
			uiDraw, -- 572
			uiInkDraw, -- 572
			uiArt, -- 572
			prev.slot, -- 573
			(opts.instancePrefix .. "_prev_") .. tostring(activeIdx - 1), -- 573
			coverRect, -- 574
			baseOp * (1 - k * 0.65), -- 574
			baseLayer, -- 574
			prev.panToX or 0, -- 575
			prev.panToY or 0, -- 575
			prev.zoomTo or 1, -- 575
			prev.tint -- 575
		) -- 575
		____exports.drawPixelSlidePlate( -- 577
			uiDraw, -- 578
			uiInkDraw, -- 578
			uiArt, -- 578
			kf.slot, -- 579
			(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 579
			shiftedRect, -- 580
			baseOp * k, -- 580
			baseLayer + 1, -- 580
			panX, -- 581
			panY, -- 581
			zoom, -- 581
			kf.tint -- 581
		) -- 581
	elseif activeIdx > 0 and localT < transDur and trans == "dark_dip" then -- 581
		local prev = keyframes[activeIdx] -- 584
		local k = clamp01(localT / transDur) -- 585
		local dip = math.sin(k * math.pi) -- 586
		if k < 0.5 then -- 586
			____exports.drawPixelSlidePlate( -- 588
				uiDraw, -- 589
				uiInkDraw, -- 589
				uiArt, -- 589
				prev.slot, -- 590
				(opts.instancePrefix .. "_prev_") .. tostring(activeIdx - 1), -- 590
				coverRect, -- 591
				baseOp * (1 - dip), -- 591
				baseLayer, -- 591
				prev.panToX or 0, -- 592
				prev.panToY or 0, -- 592
				prev.zoomTo or 1, -- 592
				prev.tint -- 592
			) -- 592
		else -- 592
			____exports.drawPixelSlidePlate( -- 595
				uiDraw, -- 596
				uiInkDraw, -- 596
				uiArt, -- 596
				kf.slot, -- 597
				(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 597
				shiftedRect, -- 598
				baseOp * (1 - dip), -- 598
				baseLayer, -- 598
				panX, -- 599
				panY, -- 599
				zoom, -- 599
				kf.tint -- 599
			) -- 599
		end -- 599
		uiInkDraw:drawRect( -- 602
			Rect(0, 0, uiW, uiH), -- 602
			Color( -- 602
				6, -- 602
				7, -- 602
				10, -- 602
				math.floor(245 * dip * baseOp + 0.5) -- 602
			) -- 602
		) -- 602
	else -- 602
		____exports.drawPixelSlidePlate( -- 604
			uiDraw, -- 605
			uiInkDraw, -- 605
			uiArt, -- 605
			kf.slot, -- 606
			(opts.instancePrefix .. "_cur_") .. tostring(activeIdx), -- 606
			shiftedRect, -- 607
			baseOp, -- 607
			baseLayer, -- 607
			panX, -- 608
			panY, -- 608
			zoom, -- 608
			kf.tint -- 608
		) -- 608
	end -- 608
	if kf.impactFlash == true then -- 608
		local impDur = kf.impactDur or math.min(0.22, span) -- 614
		if localT <= impDur then -- 614
			local impK = 1 - clamp01(localT / math.max(0.01, impDur)) -- 616
			local borderA = math.floor((165 + 85 * impK) * baseOp + 0.5) -- 617
			local insetY = barH -- 618
			local boxH = math.max(40, uiH - insetY * 2) -- 619
			uiInkDraw:drawRect( -- 620
				Rect(2, insetY + 1, uiW - 4, boxH - 2), -- 621
				Color(0, 0, 0, 0), -- 622
				3.2, -- 623
				Color(204, 42, 42, borderA) -- 624
			) -- 624
			uiInkDraw:drawRect( -- 626
				Rect(6, insetY + 5, uiW - 12, boxH - 10), -- 627
				Color(0, 0, 0, 0), -- 628
				1.2, -- 629
				Color( -- 630
					246, -- 630
					240, -- 630
					226, -- 630
					math.floor(140 * impK * baseOp + 0.5) -- 630
				) -- 630
			) -- 630
		end -- 630
	end -- 630
	if barH > 0 then -- 630
		local barA = math.floor(252 * baseOp + 0.5) -- 637
		uiInkDraw:drawRect( -- 638
			Rect(0, uiH - barH, uiW, barH), -- 638
			Color(6, 7, 10, barA) -- 638
		) -- 638
		uiInkDraw:drawRect( -- 639
			Rect(0, 0, uiW, barH), -- 639
			Color(6, 7, 10, barA) -- 639
		) -- 639
		if opts.accentBorder ~= false then -- 639
			local lineCol = kf.impactFlash == true and Color( -- 641
				204, -- 642
				46, -- 642
				46, -- 642
				math.floor(180 * baseOp + 0.5) -- 642
			) or toColor( -- 642
				PALETTE.silkDim, -- 643
				math.floor(84 * baseOp + 0.5) -- 643
			) -- 643
			uiInkDraw:drawSegment( -- 644
				Vec2(0, uiH - barH), -- 644
				Vec2(uiW, uiH - barH), -- 644
				1, -- 644
				lineCol -- 644
			) -- 644
			uiInkDraw:drawSegment( -- 645
				Vec2(0, barH), -- 645
				Vec2(uiW, barH), -- 645
				1, -- 645
				lineCol -- 645
			) -- 645
		end -- 645
	end -- 645
	return activeIdx -- 649
end -- 474
--- 绘制非阻塞漫画插格（供 F01 缝衣闪回、M02 工台试握等在实机画面上炸出的高张力漫画格）。
-- 具备硬黑底衬、骨白内框与暗朱角线，绝不阻断输入或遮盖主操作区。
function ____exports.drawComicInsertPanel(uiDraw, uiInkDraw, uiArt, keyframes, t, rect, opacity, instancePrefix, layer) -- 656
	if layer == nil then -- 656
		layer = 4 -- 665
	end -- 665
	local op = clamp01(opacity) -- 667
	if #keyframes == 0 or op <= 0.01 then -- 667
		return -1 -- 669
	end -- 669
	local activeIdx = #keyframes - 1 -- 671
	local i = 0 -- 672
	do -- 672
		i = 0 -- 673
		while i < #keyframes do -- 673
			if t < keyframes[i + 1]["end"] or i == #keyframes - 1 then -- 673
				activeIdx = i -- 675
				break -- 676
			end -- 676
			i = i + 1 -- 673
		end -- 673
	end -- 673
	local kf = keyframes[activeIdx + 1] -- 679
	local span = math.max(0.0001, kf["end"] - kf.start) -- 680
	local localU = clamp01((t - kf.start) / span) -- 681
	local zoom = (kf.zoomFrom or 1) + ((kf.zoomTo or 1) - (kf.zoomFrom or 1)) * smooth(localU) -- 682
	local pad = 6 -- 685
	uiDraw:drawRect( -- 686
		Rect(rect.x - pad + 5, rect.y - pad - 5, rect.w + pad * 2, rect.h + pad * 2), -- 687
		Color( -- 688
			5, -- 688
			6, -- 688
			9, -- 688
			math.floor(230 * op + 0.5) -- 688
		) -- 688
	) -- 688
	uiDraw:drawRect( -- 690
		Rect(rect.x - pad, rect.y - pad, rect.w + pad * 2, rect.h + pad * 2), -- 691
		Color( -- 692
			8, -- 692
			9, -- 692
			13, -- 692
			math.floor(248 * op + 0.5) -- 692
		) -- 692
	) -- 692
	____exports.drawPixelSlidePlate( -- 694
		uiDraw, -- 695
		uiInkDraw, -- 695
		uiArt, -- 695
		kf.slot, -- 696
		(instancePrefix .. "_ins_") .. tostring(activeIdx), -- 696
		rect, -- 697
		op, -- 697
		layer, -- 697
		0, -- 698
		0, -- 698
		zoom, -- 698
		kf.tint -- 698
	) -- 698
	uiInkDraw:drawRect( -- 700
		Rect(rect.x - 1, rect.y - 1, rect.w + 2, rect.h + 2), -- 701
		Color(0, 0, 0, 0), -- 702
		2, -- 703
		Color( -- 704
			232, -- 704
			224, -- 704
			208, -- 704
			math.floor(220 * op + 0.5) -- 704
		) -- 704
	) -- 704
	local corner = 24 -- 707
	local red = Color( -- 708
		192, -- 708
		48, -- 708
		46, -- 708
		math.floor(235 * op + 0.5) -- 708
	) -- 708
	uiInkDraw:drawSegment( -- 709
		Vec2(rect.x - 4, rect.y + rect.h + 4), -- 709
		Vec2(rect.x + corner, rect.y + rect.h + 4), -- 709
		2.4, -- 709
		red -- 709
	) -- 709
	uiInkDraw:drawSegment( -- 710
		Vec2(rect.x - 4, rect.y + rect.h + 4), -- 710
		Vec2(rect.x - 4, rect.y + rect.h - corner), -- 710
		2.4, -- 710
		red -- 710
	) -- 710
	uiInkDraw:drawSegment( -- 711
		Vec2(rect.x + rect.w + 4, rect.y - 4), -- 711
		Vec2(rect.x + rect.w - corner, rect.y - 4), -- 711
		2.4, -- 711
		red -- 711
	) -- 711
	uiInkDraw:drawSegment( -- 712
		Vec2(rect.x + rect.w + 4, rect.y - 4), -- 712
		Vec2(rect.x + rect.w + 4, rect.y + corner), -- 712
		2.4, -- 712
		red -- 712
	) -- 712
	return activeIdx -- 713
end -- 656
return ____exports -- 656