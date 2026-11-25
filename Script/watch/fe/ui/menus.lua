-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local Color = ____Dora.Color -- 11
local Keyboard = ____Dora.Keyboard -- 11
local Rect = ____Dora.Rect -- 11
local Vec2 = ____Dora.Vec2 -- 11
local ____rooms = require("Script.watch.rooms") -- 12
local ROOMS = ____rooms.ROOMS -- 12
local ____theme = require("Script.watch.fe.theme") -- 17
local PALETTE = ____theme.PALETTE -- 18
local drawBlossomDot = ____theme.drawBlossomDot -- 19
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 20
local drawHairline = ____theme.drawHairline -- 21
local drawLoneSeal = ____theme.drawLoneSeal -- 22
local drawMistCurve = ____theme.drawMistCurve -- 23
local drawSilkKeycap = ____theme.drawSilkKeycap -- 24
local drawSilkRibbon = ____theme.drawSilkRibbon -- 25
local drawSilkVeil = ____theme.drawSilkVeil -- 26
local fillHGradRect = ____theme.fillHGradRect -- 27
local fillRadialGlow = ____theme.fillRadialGlow -- 28
local fillVGradRect = ____theme.fillVGradRect -- 29
local themeOf = ____theme.themeOf -- 30
local toColor = ____theme.toColor -- 31
local visualTextWidth = ____theme.visualTextWidth -- 32
local TITLE_ITEMS = {{id = "start", zh = "开始游戏"}, {id = "chapters", zh = "选择章节"}, {id = "controls", zh = "操作说明"}, {id = "trial", zh = "护送试炼 · 肉鸽"}} -- 42
local PAUSE_ITEMS = {{id = "resume", zh = "继续游戏"}, {id = "retry", zh = "重试检查点"}, {id = "chapters", zh = "选择章节"}, {id = "title", zh = "返回标题"}} -- 49
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 56
local EPIGRAPH_RIGHT = { -- 58
	"城", -- 58
	"破", -- 58
	"那", -- 58
	"天", -- 58
	"", -- 58
	"他", -- 58
	"留", -- 58
	"下", -- 58
	"断", -- 58
	"后" -- 58
} -- 58
local EPIGRAPH_LEFT = { -- 59
	"她", -- 59
	"独", -- 59
	"自", -- 59
	"走", -- 59
	"向", -- 59
	"北", -- 59
	"塔" -- 59
} -- 59
local function pressedKeys() -- 78
	return { -- 79
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 80
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 81
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 82
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 83
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 84
	} -- 84
end -- 78
local function hitIndex(boxes, pointer, inside) -- 88
	if not inside then -- 88
		return -1 -- 90
	end -- 90
	return __TS__ArrayFindIndex( -- 92
		boxes, -- 92
		function(____, box) return box:containsPoint(pointer) end -- 92
	) -- 92
end -- 88
____exports.MenuRenderer = __TS__Class() -- 95
local MenuRenderer = ____exports.MenuRenderer -- 95
MenuRenderer.name = "MenuRenderer" -- 95
function MenuRenderer.prototype.____constructor(self) -- 95
	self.selected = 0 -- 96
	self.chapterSelected = 0 -- 97
	self.pauseSelected = 0 -- 98
	self.chaptersFromPause = false -- 99
	self.previousKeys = {} -- 100
	self.queuedKeys = {} -- 101
	self.queuedBack = false -- 102
	self.time = 0 -- 103
end -- 95
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 105
	self.chaptersFromPause = roomIndex ~= nil -- 106
	self.chapterSelected = roomIndex or 0 -- 107
	self:resetInput() -- 108
end -- 105
function MenuRenderer.prototype.openPause(self) -- 111
	self.pauseSelected = 0 -- 112
	self:resetInput() -- 113
end -- 111
function MenuRenderer.prototype.resetInput(self) -- 117
	self.previousKeys = pressedKeys() -- 118
	self.queuedKeys = {} -- 119
	self.queuedBack = false -- 120
end -- 117
function MenuRenderer.prototype.onKeyEvent(self, key) -- 124
	if key == "Up" or key == "W" then -- 124
		self.queuedKeys.up = true -- 126
	elseif key == "Down" or key == "S" then -- 126
		self.queuedKeys.down = true -- 128
	elseif key == "Left" or key == "A" then -- 128
		self.queuedKeys.left = true -- 130
	elseif key == "Right" or key == "D" then -- 130
		self.queuedKeys.right = true -- 132
	elseif key == "Return" or key == "Space" then -- 132
		self.queuedKeys.confirm = true -- 134
	elseif key == "Escape" then -- 134
		self.queuedBack = true -- 136
	end -- 136
end -- 124
function MenuRenderer.prototype.readFrame(self, input, scale) -- 140
	local held = pressedKeys() -- 141
	local prev = self.previousKeys -- 142
	local queued = self.queuedKeys -- 143
	local frame = { -- 144
		keys = { -- 145
			up = queued.up == true or held.up and not prev.up, -- 146
			down = queued.down == true or held.down and not prev.down, -- 147
			left = queued.left == true or held.left and not prev.left, -- 148
			right = queued.right == true or held.right and not prev.right, -- 149
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 150
		}, -- 150
		back = self.queuedBack or input.pause.pressed, -- 152
		pointer = Vec2(input.mx / scale, input.my / scale), -- 153
		inside = input.inside, -- 154
		click = input.inside and input.fire.pressed, -- 155
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 156
	} -- 156
	self.previousKeys = held -- 158
	self.queuedKeys = {} -- 159
	self.queuedBack = false -- 160
	return frame -- 161
end -- 140
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 164
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 165
	if frame.click and hit >= 0 then -- 165
		return hit -- 167
	end -- 167
	if frame.keys.up then -- 167
		return (selected + #boxes - 1) % #boxes -- 170
	end -- 170
	if frame.keys.down then -- 170
		return (selected + 1) % #boxes -- 173
	end -- 173
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 175
end -- 164
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 178
	self.time = self.time + dt -- 195
	local artW = math.max(w, h * 16 / 9) -- 196
	local artH = artW * 9 / 16 -- 197
	if not backdropArt:tryPlace( -- 197
		"title_backdrop", -- 198
		"menu_landscape", -- 198
		w * 0.5, -- 198
		(h - artH) * 0.5, -- 198
		artW, -- 198
		artH -- 198
	) then -- 198
		stage:drawMenuBackdrop( -- 199
			bgDraw, -- 199
			bgGlow, -- 199
			w, -- 199
			h, -- 199
			self.time -- 199
		) -- 199
	end -- 199
	local frame = self:readFrame(input, uiScale) -- 202
	w = w / uiScale -- 203
	h = h / uiScale -- 204
	if screen == "title" then -- 204
		return self:drawTitle( -- 207
			frame, -- 207
			uiDraw, -- 207
			uiInkDraw, -- 207
			uiArt, -- 207
			uiGlow, -- 207
			texts, -- 207
			w, -- 207
			h -- 207
		) -- 207
	end -- 207
	if screen == "chapters" then -- 207
		return self:drawChapters( -- 210
			frame, -- 210
			uiDraw, -- 210
			uiInkDraw, -- 210
			uiArt, -- 210
			uiGlow, -- 210
			texts, -- 210
			w, -- 210
			h -- 210
		) -- 210
	end -- 210
	return self:drawControls( -- 212
		frame, -- 212
		uiDraw, -- 212
		uiInkDraw, -- 212
		uiArt, -- 212
		uiGlow, -- 212
		texts, -- 212
		w, -- 212
		h -- 212
	) -- 212
end -- 178
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 215
	fillHGradRect( -- 226
		uiDraw, -- 226
		0, -- 226
		0, -- 226
		w * 0.22, -- 226
		h, -- 226
		Color(9, 11, 18, 192), -- 226
		Color(9, 11, 18, 116) -- 226
	) -- 226
	fillHGradRect( -- 227
		uiDraw, -- 227
		w * 0.22, -- 227
		0, -- 227
		w * 0.28, -- 227
		h, -- 227
		Color(9, 11, 18, 116), -- 227
		Color(9, 11, 18, 0) -- 227
	) -- 227
	fillVGradRect( -- 228
		uiDraw, -- 228
		0, -- 228
		0, -- 228
		w, -- 228
		78, -- 228
		Color(8, 10, 16, 138), -- 228
		Color(8, 10, 16, 0) -- 228
	) -- 228
	local titleX = 148 -- 231
	local topY = h - 104 -- 232
	local charStep = 66 -- 233
	local sway = math.sin(self.time * 0.7) * 5 -- 234
	drawMistCurve( -- 235
		uiArt, -- 235
		"title_mist_wisp", -- 235
		titleX + 86 + sway, -- 235
		topY - 122, -- 235
		340, -- 235
		82, -- 235
		PALETTE.jadeMist, -- 235
		0.2, -- 235
		-1 -- 235
	) -- 235
	uiArt:tryPlace( -- 236
		"ink_petal_mist", -- 236
		"title_petals", -- 236
		titleX + 12, -- 236
		topY - 102, -- 236
		230, -- 236
		210, -- 236
		{ -- 236
			color = toColor(PALETTE.inkMist), -- 237
			opacity = 0.4, -- 237
			layer = -1 -- 237
		} -- 237
	) -- 237
	uiArt:tryPlace( -- 239
		"ink_vstream", -- 239
		"title_vstream", -- 239
		titleX - 48, -- 239
		topY - 100, -- 239
		34, -- 239
		290, -- 239
		{ -- 239
			color = toColor(PALETTE.silkDim), -- 240
			opacity = 0.48, -- 240
			layer = 1 -- 240
		} -- 240
	) -- 240
	local c = 0 -- 244
	do -- 244
		c = 0 -- 245
		while c < #VERTICAL_TITLE do -- 245
			texts:put( -- 246
				"title", -- 247
				VERTICAL_TITLE[c + 1], -- 248
				titleX, -- 249
				topY - c * charStep, -- 250
				toColor(PALETTE.textBright), -- 251
				0.5, -- 252
				0.5, -- 253
				"Center", -- 254
				0, -- 255
				0.98, -- 256
				0.1, -- 257
				Color(8, 10, 16, 210) -- 258
			) -- 258
			c = c + 1 -- 245
		end -- 245
	end -- 245
	drawLoneSeal( -- 263
		uiInkDraw, -- 264
		uiArt, -- 265
		texts, -- 266
		"title_lone_seal", -- 267
		titleX + 46, -- 268
		topY - 3 * charStep + 8, -- 269
		26, -- 270
		52, -- 271
		"守", -- 272
		"望", -- 273
		PALETTE.sealRed, -- 274
		PALETTE.sealText, -- 275
		0.94, -- 276
		4 -- 277
	) -- 277
	local colRightX = titleX + 132 -- 281
	local colLeftX = titleX + 102 -- 282
	local poemStep = 22 -- 283
	local p = 0 -- 284
	do -- 284
		p = 0 -- 285
		while p < #EPIGRAPH_RIGHT do -- 285
			local ch = EPIGRAPH_RIGHT[p + 1] -- 286
			if ch ~= "" then -- 286
				texts:put( -- 288
					"xs", -- 288
					ch, -- 288
					colRightX, -- 288
					topY - 22 - p * poemStep, -- 288
					toColor(PALETTE.textMid), -- 288
					0.5, -- 288
					0.5, -- 288
					"Center", -- 288
					0, -- 288
					0.86, -- 288
					0.08 -- 288
				) -- 288
			end -- 288
			p = p + 1 -- 285
		end -- 285
	end -- 285
	do -- 285
		p = 0 -- 291
		while p < #EPIGRAPH_LEFT do -- 291
			texts:put( -- 292
				"xs", -- 292
				EPIGRAPH_LEFT[p + 1], -- 292
				colLeftX, -- 292
				topY - 68 - p * poemStep, -- 292
				toColor(PALETTE.amberCore), -- 292
				0.5, -- 292
				0.5, -- 292
				"Center", -- 292
				0, -- 292
				0.9, -- 292
				0.08 -- 292
			) -- 292
			p = p + 1 -- 291
		end -- 291
	end -- 291
	local menuX = 112 -- 296
	local btnW = 280 -- 297
	local btnH = 44 -- 298
	local gap = 12 -- 299
	local startY = 252 -- 300
	local boxes = {} -- 301
	local i = 0 -- 302
	do -- 302
		i = 0 -- 303
		while i < #TITLE_ITEMS do -- 303
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 304
			i = i + 1 -- 303
		end -- 303
	end -- 303
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 306
	do -- 306
		i = 0 -- 308
		while i < #TITLE_ITEMS do -- 308
			local by = boxes[i + 1].y -- 309
			local active = self.selected == i -- 310
			local cy = by + btnH * 0.5 -- 311
			local shiftX = active and 10 or 0 -- 312
			if active then -- 312
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 315
				drawSilkRibbon( -- 316
					uiDraw, -- 316
					uiArt, -- 316
					"title_rib_red_" .. tostring(i), -- 316
					menuX + 124, -- 316
					cy, -- 316
					290, -- 316
					40, -- 316
					PALETTE.rougeSoft, -- 316
					0.52 * breathe, -- 316
					0 -- 316
				) -- 316
				drawHairline( -- 317
					uiInkDraw, -- 317
					uiArt, -- 317
					"title_rib_line_" .. tostring(i), -- 317
					menuX + 114, -- 317
					by + 4, -- 317
					230, -- 317
					PALETTE.silkLine, -- 317
					0.42 * breathe, -- 317
					false, -- 317
					2 -- 317
				) -- 317
				drawBlossomDot( -- 318
					uiInkDraw, -- 318
					uiArt, -- 318
					"title_dot_" .. tostring(i), -- 318
					menuX + 14, -- 318
					cy, -- 318
					16, -- 318
					PALETTE.rouge, -- 318
					0.96, -- 318
					4 -- 318
				) -- 318
				fillRadialGlow( -- 319
					uiGlow, -- 319
					menuX + 14, -- 319
					cy, -- 319
					22, -- 319
					16, -- 319
					toColor(PALETTE.rouge, 28 * breathe), -- 319
					Color(182, 58, 56, 0), -- 319
					10 -- 319
				) -- 319
			else -- 319
				drawBlossomDot( -- 321
					uiInkDraw, -- 321
					uiArt, -- 321
					"title_dot_" .. tostring(i), -- 321
					menuX + 14, -- 321
					cy, -- 321
					8, -- 321
					PALETTE.silkDim, -- 321
					0.4, -- 321
					3 -- 321
				) -- 321
			end -- 321
			texts:put( -- 324
				"md", -- 325
				TITLE_ITEMS[i + 1].zh, -- 326
				menuX + 34 + shiftX, -- 327
				cy, -- 328
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 329
				0, -- 330
				0.5, -- 331
				"Left", -- 332
				active and 4.4 or 2.8, -- 333
				active and 1 or 0.88, -- 334
				0.1 -- 335
			) -- 335
			i = i + 1 -- 308
		end -- 308
	end -- 308
	texts:put( -- 339
		"xs", -- 339
		"上下择项   ·   回车或点选启程", -- 339
		menuX + 12, -- 339
		42, -- 339
		toColor(PALETTE.textDim), -- 339
		0, -- 339
		0.5, -- 339
		"Left", -- 339
		1.4, -- 339
		0.88, -- 339
		0.08 -- 339
	) -- 339
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 341
	if hit >= 0 or frame.keys.confirm then -- 341
		local idx = hit >= 0 and hit or self.selected -- 343
		local id = TITLE_ITEMS[idx + 1].id -- 344
		if id == "trial" then -- 344
			return {type = "trial"} -- 345
		end -- 345
		if id == "start" then -- 345
			return {type = "start"} -- 347
		end -- 347
		if id == "chapters" then -- 347
			return {type = "openChapters"} -- 350
		end -- 350
		return {type = "openControls"} -- 352
	end -- 352
	return {type = "none"} -- 354
end -- 215
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 361
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 371
	if frame.back then -- 371
		return back -- 373
	end -- 373
	local marginX = 96 -- 376
	local trackY = 148 -- 377
	local trackX0 = marginX + 34 -- 378
	local trackX1 = w - marginX - 34 -- 379
	local stepX = (trackX1 - trackX0) / (#ROOMS - 1) -- 380
	local stationBoxes = {} -- 382
	local s = 0 -- 383
	do -- 383
		s = 0 -- 384
		while s < #ROOMS do -- 384
			local sx = trackX0 + s * stepX -- 385
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, trackY - 46, stepX * 0.9, 92) -- 386
			s = s + 1 -- 384
		end -- 384
	end -- 384
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 389
	local keys = frame.keys -- 390
	if frame.click and hitStation >= 0 then -- 390
		self.chapterSelected = hitStation -- 392
	elseif keys.left or keys.right or keys.up or keys.down then -- 392
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 394
		self.chapterSelected = (self.chapterSelected + step + #ROOMS) % #ROOMS -- 395
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 395
		self.chapterSelected = hitStation -- 397
	end -- 397
	uiDraw:drawRect( -- 401
		Rect(0, 0, w, h), -- 401
		Color(10, 12, 19, 198) -- 401
	) -- 401
	texts:put( -- 404
		"banner", -- 404
		"千里行纪", -- 404
		marginX, -- 404
		h - 66, -- 404
		toColor(PALETTE.textBright), -- 404
		0, -- 404
		0.5, -- 404
		"Left", -- 404
		4.5, -- 404
		0.96, -- 404
		0.1 -- 404
	) -- 404
	texts:put( -- 405
		"xs", -- 405
		"双线八驿 · 择章重历", -- 405
		marginX + 196, -- 405
		h - 70, -- 405
		toColor(PALETTE.textDim), -- 405
		0, -- 405
		0.5, -- 405
		"Left", -- 405
		2, -- 405
		0.85, -- 405
		0.08 -- 405
	) -- 405
	drawHairline( -- 406
		uiInkDraw, -- 406
		uiArt, -- 406
		"chap_top_line", -- 406
		w * 0.5, -- 406
		h - 100, -- 406
		w - marginX * 2, -- 406
		PALETTE.silkDim, -- 406
		0.6, -- 406
		true, -- 406
		2 -- 406
	) -- 406
	local activeRoom = ROOMS[self.chapterSelected + 1] -- 409
	local theme = themeOf(activeRoom.key) -- 410
	local winX = marginX -- 411
	local winY = 266 -- 412
	local winW = 548 -- 413
	local winH = 300 -- 414
	local winBox = Rect(winX, winY, winW, winH) -- 415
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 416
	uiArt:tryPlace( -- 419
		"ink_frame_mask", -- 419
		"chap_win_shadow", -- 419
		winX + winW * 0.5, -- 419
		winY + winH * 0.5, -- 419
		winW + 40, -- 419
		winH + 34, -- 419
		{ -- 419
			color = toColor(PALETTE.inkVoid), -- 420
			opacity = 0.88, -- 420
			layer = -2 -- 420
		} -- 420
	) -- 420
	local bgSlot = "bgFar_" .. activeRoom.key -- 422
	uiArt:tryPlace( -- 423
		bgSlot, -- 423
		"chap_win_art", -- 423
		winX + winW * 0.5, -- 423
		winY + 4, -- 423
		winW - 8, -- 423
		winH - 8, -- 423
		{opacity = 0.92, layer = -1} -- 423
	) -- 423
	fillVGradRect( -- 427
		uiInkDraw, -- 427
		winX, -- 427
		winY, -- 427
		winW, -- 427
		56, -- 427
		Color(10, 12, 19, 200), -- 427
		Color(10, 12, 19, 0) -- 427
	) -- 427
	fillVGradRect( -- 428
		uiInkDraw, -- 428
		winX, -- 428
		winY + winH - 36, -- 428
		winW, -- 428
		36, -- 428
		Color(10, 12, 19, 0), -- 428
		Color(10, 12, 19, 130) -- 428
	) -- 428
	fillHGradRect( -- 429
		uiInkDraw, -- 429
		winX, -- 429
		winY, -- 429
		34, -- 429
		winH, -- 429
		Color(10, 12, 19, 135), -- 429
		Color(10, 12, 19, 0) -- 429
	) -- 429
	fillHGradRect( -- 430
		uiInkDraw, -- 430
		winX + winW - 34, -- 430
		winY, -- 430
		34, -- 430
		winH, -- 430
		Color(10, 12, 19, 0), -- 430
		Color(10, 12, 19, 135) -- 430
	) -- 430
	drawFiligreeCorners( -- 432
		uiInkDraw, -- 432
		uiArt, -- 432
		"chap_win_frame", -- 432
		winX, -- 432
		winY, -- 432
		winW, -- 432
		winH, -- 432
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 432
		winHover and 0.92 or 0.72, -- 432
		34, -- 432
		true, -- 432
		3 -- 432
	) -- 432
	texts:put( -- 435
		"xs", -- 435
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 435
		winX + 20, -- 435
		winY + 22, -- 435
		toColor(PALETTE.textMid), -- 435
		0, -- 435
		0.5, -- 435
		"Left", -- 435
		1.8, -- 435
		0.9, -- 435
		0.08 -- 435
	) -- 435
	local infoX = winX + winW + 46 -- 438
	local infoCenterY = winY + winH * 0.5 -- 439
	drawMistCurve( -- 440
		uiArt, -- 440
		"chap_info_mist", -- 440
		infoX + 210, -- 440
		infoCenterY + 36, -- 440
		420, -- 440
		88, -- 440
		theme.accent, -- 440
		0.22, -- 440
		-1 -- 440
	) -- 440
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 443
	texts:put( -- 444
		"xs", -- 444
		theme.volumeTagZh, -- 444
		infoX, -- 444
		winY + winH - 44, -- 444
		toColor(volCol), -- 444
		0, -- 444
		0.5, -- 444
		"Left", -- 444
		2.8, -- 444
		0.92, -- 444
		0.08 -- 444
	) -- 444
	local sep = " · " -- 447
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 448
	local titleY = winY + winH - 98 -- 449
	if sIdx > 0 then -- 449
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 451
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 452
		local lw = visualTextWidth(leftPart, 40) -- 453
		texts:put( -- 454
			"banner", -- 454
			leftPart, -- 454
			infoX, -- 454
			titleY, -- 454
			toColor(PALETTE.textBright), -- 454
			0, -- 454
			0.5, -- 454
			"Left", -- 454
			2, -- 454
			1, -- 454
			0.1 -- 454
		) -- 454
		drawBlossomDot( -- 455
			uiInkDraw, -- 455
			uiArt, -- 455
			"chap_title_dot", -- 455
			infoX + lw + 16, -- 455
			titleY - 2, -- 455
			11, -- 455
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 455
			0.9, -- 455
			4 -- 455
		) -- 455
		texts:put( -- 456
			"banner", -- 456
			rightPart, -- 456
			infoX + lw + 32, -- 456
			titleY, -- 456
			toColor(PALETTE.textBright), -- 456
			0, -- 456
			0.5, -- 456
			"Left", -- 456
			2, -- 456
			1, -- 456
			0.1 -- 456
		) -- 456
	else -- 456
		texts:put( -- 458
			"banner", -- 458
			theme.titleZh, -- 458
			infoX, -- 458
			titleY, -- 458
			toColor(PALETTE.textBright), -- 458
			0, -- 458
			0.5, -- 458
			"Left", -- 458
			2.4, -- 458
			1, -- 458
			0.1 -- 458
		) -- 458
	end -- 458
	drawHairline( -- 461
		uiInkDraw, -- 461
		uiArt, -- 461
		"chap_info_line", -- 461
		infoX + 185, -- 461
		titleY - 36, -- 461
		370, -- 461
		PALETTE.silkDim, -- 461
		0.58, -- 461
		false, -- 461
		2 -- 461
	) -- 461
	texts:put( -- 464
		"sm", -- 464
		theme.introWhisper, -- 464
		infoX, -- 464
		titleY - 72, -- 464
		toColor(PALETTE.textMid), -- 464
		0, -- 464
		0.5, -- 464
		"Left", -- 464
		0.8, -- 464
		0.94, -- 464
		0.08 -- 464
	) -- 464
	local goX = infoX -- 467
	local goY = winY + 26 -- 468
	local goW = 220 -- 469
	local goH = 42 -- 470
	local goBox = Rect(goX, goY, goW, goH) -- 471
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 472
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 473
	drawSilkRibbon( -- 474
		uiDraw, -- 474
		uiArt, -- 474
		"chap_go_rib", -- 474
		goX + 106, -- 474
		goY + 21, -- 474
		250, -- 474
		40, -- 474
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 474
		(goHover and 0.68 or 0.46) * breathe, -- 474
		0 -- 474
	) -- 474
	drawHairline( -- 475
		uiInkDraw, -- 475
		uiArt, -- 475
		"chap_go_line", -- 475
		goX + 94, -- 475
		goY + 3, -- 475
		196, -- 475
		PALETTE.silkLine, -- 475
		goHover and 0.68 or 0.4, -- 475
		false, -- 475
		2 -- 475
	) -- 475
	drawBlossomDot( -- 476
		uiInkDraw, -- 476
		uiArt, -- 476
		"chap_go_dot", -- 476
		goX + 14, -- 476
		goY + 21, -- 476
		14, -- 476
		PALETTE.rouge, -- 476
		0.96, -- 476
		4 -- 476
	) -- 476
	texts:put( -- 477
		"md", -- 477
		"入此卷章", -- 477
		goX + 34, -- 477
		goY + 21, -- 477
		toColor(PALETTE.textBright), -- 477
		0, -- 477
		0.5, -- 477
		"Left", -- 477
		3.8, -- 477
		1, -- 477
		0.1 -- 477
	) -- 477
	texts:put( -- 478
		"xs", -- 478
		"Enter", -- 478
		goX + 156, -- 478
		goY + 21, -- 478
		toColor(PALETTE.textDim), -- 478
		0, -- 478
		0.5, -- 478
		"Left", -- 478
		1, -- 478
		0.82, -- 478
		0.08 -- 478
	) -- 478
	drawSilkVeil( -- 481
		uiDraw, -- 481
		uiArt, -- 481
		"chap_track_veil", -- 481
		w * 0.5, -- 481
		trackY + 6, -- 481
		w - marginX * 1.1, -- 481
		126, -- 481
		PALETTE.inkWash, -- 481
		0.72, -- 481
		-2 -- 481
	) -- 481
	drawMistCurve( -- 482
		uiArt, -- 482
		"chap_track_mist", -- 482
		w * 0.5, -- 482
		trackY, -- 482
		trackX1 - trackX0 + 160, -- 482
		74, -- 482
		PALETTE.inkMist, -- 482
		0.62, -- 482
		-1 -- 482
	) -- 482
	uiInkDraw:drawSegment( -- 483
		Vec2(trackX0, trackY), -- 483
		Vec2(trackX1, trackY), -- 483
		0.9, -- 483
		toColor(PALETTE.silkDim, 145) -- 483
	) -- 483
	local midDivX = trackX0 + stepX * 3.5 -- 486
	uiInkDraw:drawSegment( -- 487
		Vec2(midDivX, trackY - 12), -- 487
		Vec2(midDivX, trackY + 12), -- 487
		0.8, -- 487
		toColor(PALETTE.silkDim, 120) -- 487
	) -- 487
	texts:put( -- 488
		"xs", -- 488
		"上卷 · 孤城护童", -- 488
		trackX0 + stepX * 1.5, -- 488
		trackY + 52, -- 488
		toColor(PALETTE.cyan), -- 488
		0.5, -- 488
		0.5, -- 488
		"Center", -- 488
		2.2, -- 488
		0.88, -- 488
		0.08 -- 488
	) -- 488
	texts:put( -- 489
		"xs", -- 489
		"下卷 · 独赴北塔", -- 489
		trackX0 + stepX * 5.5, -- 489
		trackY + 52, -- 489
		toColor(PALETTE.amber), -- 489
		0.5, -- 489
		0.5, -- 489
		"Center", -- 489
		2.2, -- 489
		0.88, -- 489
		0.08 -- 489
	) -- 489
	local i = 0 -- 491
	do -- 491
		i = 0 -- 492
		while i < #ROOMS do -- 492
			local sx = trackX0 + i * stepX -- 493
			local rt = themeOf(ROOMS[i + 1].key) -- 494
			local active = self.chapterSelected == i -- 495
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 496
			if active then -- 496
				fillRadialGlow( -- 499
					uiGlow, -- 499
					sx, -- 499
					trackY, -- 499
					26, -- 499
					26, -- 499
					toColor(PALETTE.rouge, 36 * breathe), -- 499
					Color(182, 58, 56, 0), -- 499
					12 -- 499
				) -- 499
				uiArt:tryPlace( -- 500
					"ink_enso_fine", -- 500
					"chap_st_ring_" .. tostring(i), -- 500
					sx, -- 500
					trackY, -- 500
					32, -- 500
					32, -- 500
					{ -- 500
						color = toColor(PALETTE.silkLine), -- 501
						opacity = 0.78, -- 501
						angle = self.time * 18, -- 501
						layer = 3 -- 501
					} -- 501
				) -- 501
				drawBlossomDot( -- 503
					uiInkDraw, -- 503
					uiArt, -- 503
					"chap_st_dot_" .. tostring(i), -- 503
					sx, -- 503
					trackY, -- 503
					17, -- 503
					PALETTE.rouge, -- 503
					0.98, -- 503
					4 -- 503
				) -- 503
			else -- 503
				uiArt:tryPlace( -- 505
					"ink_enso_fine", -- 505
					"chap_st_ring_" .. tostring(i), -- 505
					sx, -- 505
					trackY, -- 505
					16, -- 505
					16, -- 505
					{ -- 505
						color = toColor(nodeCol), -- 506
						opacity = 0.62, -- 506
						layer = 3 -- 506
					} -- 506
				) -- 506
				drawBlossomDot( -- 508
					uiInkDraw, -- 508
					uiArt, -- 508
					"chap_st_dot_" .. tostring(i), -- 508
					sx, -- 508
					trackY, -- 508
					7, -- 508
					PALETTE.silkLine, -- 508
					0.72, -- 508
					4 -- 508
				) -- 508
			end -- 508
			texts:put( -- 511
				"xs", -- 511
				rt.numeralZh, -- 511
				sx, -- 511
				trackY + 25, -- 511
				toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 511
				0.5, -- 511
				0.5, -- 511
				"Center", -- 511
				0, -- 511
				active and 1 or 0.88, -- 511
				0.08 -- 511
			) -- 511
			texts:put( -- 512
				"xs", -- 512
				rt.shortNameZh, -- 512
				sx, -- 512
				trackY - 26, -- 512
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 512
				0.5, -- 512
				0.5, -- 512
				"Center", -- 512
				1, -- 512
				active and 1 or 0.84, -- 512
				0.08 -- 512
			) -- 512
			i = i + 1 -- 492
		end -- 492
	end -- 492
	local backX = marginX -- 516
	local backY = 40 -- 517
	local backBox = Rect(backX, backY, 190, 34) -- 518
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 519
	drawSilkKeycap( -- 520
		uiInkDraw, -- 520
		texts, -- 520
		backX, -- 520
		backY + 5, -- 520
		44, -- 520
		24, -- 520
		"ESC", -- 520
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 520
		0.92, -- 520
		backHover -- 520
	) -- 520
	texts:put( -- 521
		"sm", -- 521
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 521
		backX + 56, -- 521
		backY + 17, -- 521
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 521
		0, -- 521
		0.5, -- 521
		"Left", -- 521
		1.8, -- 521
		0.9, -- 521
		0.08 -- 521
	) -- 521
	texts:put( -- 522
		"xs", -- 522
		"← / → 沿驿道阅览   ·   Enter 或点选入章", -- 522
		w - marginX, -- 522
		backY + 17, -- 522
		toColor(PALETTE.textDim), -- 522
		1, -- 522
		0.5, -- 522
		"Right", -- 522
		1.2, -- 522
		0.75, -- 522
		0.08 -- 522
	) -- 522
	if frame.click and backHover then -- 522
		return back -- 525
	end -- 525
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 525
		return {type = "jump", roomIndex = self.chapterSelected} -- 528
	end -- 528
	return {type = "none"} -- 530
end -- 361
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h) -- 536
	local marginX = 96 -- 546
	local backX = marginX -- 547
	local backY = 40 -- 548
	local backBox = Rect(backX, backY, 230, 34) -- 549
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 550
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 550
		return {type = "backTitle"} -- 552
	end -- 552
	uiDraw:drawRect( -- 554
		Rect(0, 0, w, h), -- 554
		Color(10, 12, 19, 204) -- 554
	) -- 554
	texts:put( -- 556
		"banner", -- 556
		"执器要诀", -- 556
		marginX, -- 556
		h - 66, -- 556
		toColor(PALETTE.textBright), -- 556
		0, -- 556
		0.5, -- 556
		"Left", -- 556
		4.5, -- 556
		0.96, -- 556
		0.1 -- 556
	) -- 556
	texts:put( -- 557
		"xs", -- 557
		"键鼠操作说明", -- 557
		marginX + 196, -- 557
		h - 70, -- 557
		toColor(PALETTE.textDim), -- 557
		0, -- 557
		0.5, -- 557
		"Left", -- 557
		2, -- 557
		0.85, -- 557
		0.08 -- 557
	) -- 557
	drawHairline( -- 558
		uiInkDraw, -- 558
		uiArt, -- 558
		"ctrl_top_line", -- 558
		w * 0.5, -- 558
		h - 100, -- 558
		w - marginX * 2, -- 558
		PALETTE.silkDim, -- 558
		0.6, -- 558
		true, -- 558
		2 -- 558
	) -- 558
	local areaY = 114 -- 561
	local areaH = h - 244 -- 562
	drawFiligreeCorners( -- 563
		uiInkDraw, -- 563
		uiArt, -- 563
		"ctrl_outer", -- 563
		marginX, -- 563
		areaY, -- 563
		w - marginX * 2, -- 563
		areaH, -- 563
		PALETTE.silkDim, -- 563
		0.52, -- 563
		34, -- 563
		false, -- 563
		2 -- 563
	) -- 563
	local midX = w * 0.5 -- 566
	uiArt:tryPlace( -- 567
		"ink_vstream", -- 567
		"ctrl_mid_stream", -- 567
		midX, -- 567
		areaY + areaH * 0.5, -- 567
		32, -- 567
		areaH - 18, -- 567
		{ -- 567
			color = toColor(PALETTE.silkDim), -- 568
			opacity = 0.52, -- 568
			layer = 1 -- 568
		} -- 568
	) -- 568
	drawBlossomDot( -- 570
		uiInkDraw, -- 570
		uiArt, -- 570
		"ctrl_mid_dot", -- 570
		midX, -- 570
		areaY + areaH * 0.5, -- 570
		11, -- 570
		PALETTE.silkLine, -- 570
		0.62, -- 570
		3 -- 570
	) -- 570
	local leftColX = marginX + 34 -- 573
	local colW = midX - leftColX - 42 -- 574
	local headY = areaY + areaH - 34 -- 575
	drawBlossomDot( -- 576
		uiInkDraw, -- 576
		uiArt, -- 576
		"ctrl_l_dot", -- 576
		leftColX + 8, -- 576
		headY, -- 576
		12, -- 576
		PALETTE.cyan, -- 576
		0.88, -- 576
		3 -- 576
	) -- 576
	texts:put( -- 577
		"md", -- 577
		"周戍 · 护送与交锋", -- 577
		leftColX + 26, -- 577
		headY, -- 577
		toColor(PALETTE.cyanCore), -- 577
		0, -- 577
		0.5, -- 577
		"Left", -- 577
		2.4, -- 577
		0.98, -- 577
		0.08 -- 577
	) -- 577
	drawHairline( -- 578
		uiInkDraw, -- 578
		uiArt, -- 578
		"ctrl_l_line", -- 578
		leftColX + colW * 0.5, -- 578
		headY - 24, -- 578
		colW, -- 578
		PALETTE.cyanDim, -- 578
		0.58, -- 578
		false, -- 578
		2 -- 578
	) -- 578
	local sRows = { -- 580
		{"WASD / 方向键", "左右、前后自由移动"}, -- 581
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 582
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 583
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 584
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 585
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 586
	} -- 586
	local i = 0 -- 588
	do -- 588
		i = 0 -- 589
		while i < #sRows do -- 589
			local ry = headY - 66 - i * 52 -- 590
			drawSilkKeycap( -- 591
				uiInkDraw, -- 591
				texts, -- 591
				leftColX + 2, -- 591
				ry - 13, -- 591
				132, -- 591
				26, -- 591
				sRows[i + 1][1], -- 591
				PALETTE.cyan, -- 591
				0.92, -- 591
				false -- 591
			) -- 591
			texts:put( -- 592
				"sm", -- 592
				sRows[i + 1][2], -- 592
				leftColX + 150, -- 592
				ry, -- 592
				toColor(PALETTE.textBright), -- 592
				0, -- 592
				0.5, -- 592
				"Left", -- 592
				0.8, -- 592
				0.92, -- 592
				0.08 -- 592
			) -- 592
			i = i + 1 -- 589
		end -- 589
	end -- 589
	local rightColX = midX + 44 -- 596
	drawBlossomDot( -- 597
		uiInkDraw, -- 597
		uiArt, -- 597
		"ctrl_r_dot", -- 597
		rightColX + 8, -- 597
		headY, -- 597
		12, -- 597
		PALETTE.amber, -- 597
		0.88, -- 597
		3 -- 597
	) -- 597
	texts:put( -- 598
		"md", -- 598
		"小满 · 潜行与寻路", -- 598
		rightColX + 26, -- 598
		headY, -- 598
		toColor(PALETTE.amberCore), -- 598
		0, -- 598
		0.5, -- 598
		"Left", -- 598
		2.4, -- 598
		0.98, -- 598
		0.08 -- 598
	) -- 598
	drawHairline( -- 599
		uiInkDraw, -- 599
		uiArt, -- 599
		"ctrl_r_line", -- 599
		rightColX + colW * 0.5, -- 599
		headY - 24, -- 599
		colW, -- 599
		PALETTE.amberDim, -- 599
		0.58, -- 599
		false, -- 599
		2 -- 599
	) -- 599
	local cRows = { -- 601
		{"A / D · ← / →", "左右潜行"}, -- 602
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 603
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 604
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 605
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 606
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 607
	} -- 607
	do -- 607
		i = 0 -- 609
		while i < #cRows do -- 609
			local ry = headY - 66 - i * 52 -- 610
			drawSilkKeycap( -- 611
				uiInkDraw, -- 611
				texts, -- 611
				rightColX + 2, -- 611
				ry - 13, -- 611
				132, -- 611
				26, -- 611
				cRows[i + 1][1], -- 611
				PALETTE.amber, -- 611
				0.92, -- 611
				false -- 611
			) -- 611
			texts:put( -- 612
				"sm", -- 612
				cRows[i + 1][2], -- 612
				rightColX + 150, -- 612
				ry, -- 612
				toColor(PALETTE.textBright), -- 612
				0, -- 612
				0.5, -- 612
				"Left", -- 612
				0.8, -- 612
				0.92, -- 612
				0.08 -- 612
			) -- 612
			i = i + 1 -- 609
		end -- 609
	end -- 609
	drawSilkKeycap( -- 616
		uiInkDraw, -- 616
		texts, -- 616
		backX, -- 616
		backY + 5, -- 616
		110, -- 616
		24, -- 616
		"ESC / ENTER", -- 616
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 616
		0.92, -- 616
		backHover -- 616
	) -- 616
	texts:put( -- 617
		"sm", -- 617
		"返回标题", -- 617
		backX + 122, -- 617
		backY + 17, -- 617
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 617
		0, -- 617
		0.5, -- 617
		"Left", -- 617
		1.8, -- 617
		0.92, -- 617
		0.08 -- 617
	) -- 617
	return {type = "none"} -- 619
end -- 536
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale) -- 625
	self.time = self.time + dt -- 637
	local frame = self:readFrame(input, uiScale) -- 638
	if frame.back then -- 638
		return {type = "resume"} -- 640
	end -- 640
	uiDraw:drawRect( -- 644
		Rect(0, 0, w, h), -- 644
		Color(8, 10, 16, 102) -- 644
	) -- 644
	fillHGradRect( -- 645
		uiDraw, -- 645
		0, -- 645
		0, -- 645
		w * 0.27, -- 645
		h, -- 645
		Color(9, 11, 18, 232), -- 645
		Color(10, 13, 21, 198) -- 645
	) -- 645
	fillHGradRect( -- 646
		uiDraw, -- 646
		w * 0.27, -- 646
		0, -- 646
		w * 0.21, -- 646
		h, -- 646
		Color(10, 13, 21, 198), -- 646
		Color(10, 13, 21, 0) -- 646
	) -- 646
	local menuX = 110 -- 649
	uiArt:tryPlace( -- 650
		"ink_vstream", -- 650
		"pause_vstream", -- 650
		menuX - 32, -- 650
		h * 0.5, -- 650
		34, -- 650
		h * 0.78, -- 650
		{ -- 650
			color = toColor(PALETTE.silkDim), -- 651
			opacity = 0.48, -- 651
			layer = 1 -- 651
		} -- 651
	) -- 651
	drawMistCurve( -- 653
		uiArt, -- 653
		"pause_mist", -- 653
		menuX + 118, -- 653
		h - 154, -- 653
		290, -- 653
		72, -- 653
		PALETTE.jadeMist, -- 653
		0.2, -- 653
		-1 -- 653
	) -- 653
	texts:put( -- 656
		"banner", -- 656
		"暂歇", -- 656
		menuX + 16, -- 656
		h - 146, -- 656
		toColor(PALETTE.textBright), -- 656
		0, -- 656
		0.5, -- 656
		"Left", -- 656
		10, -- 656
		0.98, -- 656
		0.1 -- 656
	) -- 656
	texts:put( -- 657
		"xs", -- 657
		"月夜暂驻 · 卷页留痕", -- 657
		menuX + 18, -- 657
		h - 184, -- 657
		toColor(PALETTE.textDim), -- 657
		0, -- 657
		0.5, -- 657
		"Left", -- 657
		2, -- 657
		0.8, -- 657
		0.08 -- 657
	) -- 657
	drawHairline( -- 658
		uiInkDraw, -- 658
		uiArt, -- 658
		"pause_div", -- 658
		menuX + 124, -- 658
		h - 210, -- 658
		240, -- 658
		PALETTE.silkDim, -- 658
		0.58, -- 658
		true, -- 658
		2 -- 658
	) -- 658
	local boxes = {} -- 660
	local i = 0 -- 661
	do -- 661
		i = 0 -- 662
		while i < #PAUSE_ITEMS do -- 662
			boxes[#boxes + 1] = Rect(menuX - 10, h - 284 - i * 60, 270, 44) -- 663
			i = i + 1 -- 662
		end -- 662
	end -- 662
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 665
	do -- 665
		i = 0 -- 667
		while i < #PAUSE_ITEMS do -- 667
			local iy = boxes[i + 1].y -- 668
			local active = self.pauseSelected == i -- 669
			local cy = iy + 22 -- 670
			local shiftX = active and 10 or 0 -- 671
			if active then -- 671
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 674
				drawSilkRibbon( -- 675
					uiDraw, -- 675
					uiArt, -- 675
					"pause_rib_" .. tostring(i), -- 675
					menuX + 116, -- 675
					cy, -- 675
					276, -- 675
					40, -- 675
					PALETTE.rougeSoft, -- 675
					0.54 * breathe, -- 675
					0 -- 675
				) -- 675
				drawHairline( -- 676
					uiInkDraw, -- 676
					uiArt, -- 676
					"pause_line_" .. tostring(i), -- 676
					menuX + 106, -- 676
					iy + 4, -- 676
					210, -- 676
					PALETTE.silkLine, -- 676
					0.42 * breathe, -- 676
					false, -- 676
					2 -- 676
				) -- 676
				drawBlossomDot( -- 677
					uiInkDraw, -- 677
					uiArt, -- 677
					"pause_dot_" .. tostring(i), -- 677
					menuX + 12, -- 677
					cy, -- 677
					15, -- 677
					PALETTE.rouge, -- 677
					0.96, -- 677
					4 -- 677
				) -- 677
				fillRadialGlow( -- 678
					uiGlow, -- 678
					menuX + 12, -- 678
					cy, -- 678
					22, -- 678
					16, -- 678
					toColor(PALETTE.rouge, 26 * breathe), -- 678
					Color(182, 58, 56, 0), -- 678
					10 -- 678
				) -- 678
			else -- 678
				drawBlossomDot( -- 680
					uiInkDraw, -- 680
					uiArt, -- 680
					"pause_dot_" .. tostring(i), -- 680
					menuX + 12, -- 680
					cy, -- 680
					8, -- 680
					PALETTE.silkDim, -- 680
					0.4, -- 680
					3 -- 680
				) -- 680
			end -- 680
			texts:put( -- 683
				"md", -- 684
				PAUSE_ITEMS[i + 1].zh, -- 685
				menuX + 32 + shiftX, -- 686
				cy, -- 687
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 688
				0, -- 689
				0.5, -- 690
				"Left", -- 691
				active and 3.8 or 2.4, -- 692
				active and 1 or 0.88, -- 693
				0.1 -- 694
			) -- 694
			i = i + 1 -- 667
		end -- 667
	end -- 667
	texts:put( -- 698
		"xs", -- 698
		"Esc 续行   ·   Enter 或点击确认", -- 698
		menuX + 12, -- 698
		56, -- 698
		toColor(PALETTE.textDim), -- 698
		0, -- 698
		0.5, -- 698
		"Left", -- 698
		1.2, -- 698
		0.86, -- 698
		0.08 -- 698
	) -- 698
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 700
	if hit >= 0 or frame.keys.confirm then -- 700
		local idx = hit >= 0 and hit or self.pauseSelected -- 702
		local id = PAUSE_ITEMS[idx + 1].id -- 703
		if id == "resume" then -- 703
			return {type = "resume"} -- 705
		end -- 705
		if id == "retry" then -- 705
			return {type = "retry"} -- 708
		end -- 708
		if id == "chapters" then -- 708
			return {type = "openChapters"} -- 711
		end -- 711
		return {type = "toTitle"} -- 713
	end -- 713
	return {type = "none"} -- 715
end -- 625
return ____exports -- 625