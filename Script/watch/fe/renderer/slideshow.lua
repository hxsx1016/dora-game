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
	____exports.drawSlideFrameChrome( -- 341
		uiDraw, -- 341
		uiInkDraw, -- 341
		uiArt, -- 341
		shiftedRect, -- 341
		uiW, -- 341
		uiH, -- 341
		opts -- 341
	) -- 341
	return activeIdx -- 342
end -- 230
--- 绘制统一宋明烟黛过场字幕条
function ____exports.drawSlideSubtitle(uiDraw, uiInkDraw, uiArt, texts, keyPrefix, text, cx, cy, alpha, color, layer) -- 346
	if color == nil then -- 346
		color = PALETTE.textBright -- 356
	end -- 356
	if layer == nil then -- 356
		layer = 8 -- 357
	end -- 357
	local a = clamp01(alpha) -- 359
	if a <= 0.01 or text == "" then -- 359
		return -- 361
	end -- 361
	local veilW = math.max( -- 363
		320, -- 363
		math.min(760, #text * 15 + 140) -- 363
	) -- 363
	drawSilkVeil( -- 364
		uiDraw, -- 364
		uiArt, -- 364
		keyPrefix .. "_veil", -- 364
		cx, -- 364
		cy, -- 364
		veilW, -- 364
		44, -- 364
		PALETTE.inkWash, -- 364
		0.84 * a, -- 364
		layer -- 364
	) -- 364
	drawHairline( -- 365
		uiInkDraw, -- 365
		uiArt, -- 365
		keyPrefix .. "_hair", -- 365
		cx, -- 365
		cy + 20, -- 365
		veilW * 0.62, -- 365
		PALETTE.silkDim, -- 365
		0.48 * a, -- 365
		true, -- 365
		layer + 1 -- 365
	) -- 365
	texts:put( -- 366
		"sm", -- 366
		text, -- 366
		cx, -- 366
		cy, -- 366
		toColor(color), -- 366
		0.5, -- 366
		0.5, -- 366
		"Center", -- 366
		1.2, -- 366
		a, -- 366
		0.08 -- 366
	) -- 366
end -- 346
--- 小满单人线「冷月像素电影剧场」氛围调色与四周压边暗角。
-- 绝不使用硬描边或多边形块，仅用克制冷靛月雾渐变与四角柔光暗晕衬托像素场景。
function ____exports.drawChildColdMoonGrade(draw, glow, w, h, intensity, warmShift) -- 373
	if intensity == nil then -- 373
		intensity = 1 -- 378
	end -- 378
	if warmShift == nil then -- 378
		warmShift = 0 -- 379
	end -- 379
	local k = clamp01(intensity) -- 381
	if k <= 0.01 then -- 381
		return -- 383
	end -- 383
	local coldAmt = k * (1 - clamp01(warmShift) * 0.72) -- 385
	local zeroVoid = Color(10, 14, 22, 0) -- 386
	fillVGradRect( -- 388
		draw, -- 388
		0, -- 388
		h * 0.64, -- 388
		w, -- 388
		h * 0.36, -- 388
		zeroVoid, -- 388
		Color( -- 388
			8, -- 388
			12, -- 388
			22, -- 388
			math.floor(96 * coldAmt + 0.5) -- 388
		) -- 388
	) -- 388
	fillVGradRect( -- 389
		draw, -- 389
		0, -- 389
		0, -- 389
		w, -- 389
		h * 0.14, -- 389
		Color( -- 389
			6, -- 389
			9, -- 389
			16, -- 389
			math.floor(115 * k + 0.5) -- 389
		), -- 389
		zeroVoid -- 389
	) -- 389
	fillHGradRect( -- 391
		draw, -- 391
		0, -- 391
		0, -- 391
		w * 0.14, -- 391
		h, -- 391
		Color( -- 391
			7, -- 391
			10, -- 391
			18, -- 391
			math.floor(112 * coldAmt + 0.5) -- 391
		), -- 391
		zeroVoid -- 391
	) -- 391
	fillHGradRect( -- 392
		draw, -- 392
		w * 0.86, -- 392
		0, -- 392
		w * 0.14, -- 392
		h, -- 392
		zeroVoid, -- 392
		Color( -- 392
			7, -- 392
			10, -- 392
			18, -- 392
			math.floor(112 * coldAmt + 0.5) -- 392
		) -- 392
	) -- 392
	if coldAmt > 0.05 then -- 392
		fillRadialGlow( -- 395
			glow, -- 396
			w * 0.72, -- 397
			h * 0.78, -- 398
			w * 0.38, -- 399
			h * 0.34, -- 400
			Color( -- 401
				138, -- 401
				174, -- 401
				206, -- 401
				math.floor(24 * coldAmt + 0.5) -- 401
			), -- 401
			Color(24, 42, 68, 0), -- 402
			14 -- 403
		) -- 403
	end -- 403
end -- 373
return ____exports -- 373