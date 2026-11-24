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
local TITLE_ITEMS = {{id = "start", zh = "开始游戏"}, {id = "chapters", zh = "选择章节"}, {id = "controls", zh = "操作说明"}} -- 42
local PAUSE_ITEMS = {{id = "resume", zh = "继续游戏"}, {id = "retry", zh = "重试检查点"}, {id = "chapters", zh = "选择章节"}, {id = "title", zh = "返回标题"}} -- 48
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 55
local EPIGRAPH_RIGHT = { -- 57
	"城", -- 57
	"破", -- 57
	"那", -- 57
	"天", -- 57
	"", -- 57
	"他", -- 57
	"留", -- 57
	"下", -- 57
	"断", -- 57
	"后" -- 57
} -- 57
local EPIGRAPH_LEFT = { -- 58
	"她", -- 58
	"独", -- 58
	"自", -- 58
	"走", -- 58
	"向", -- 58
	"北", -- 58
	"塔" -- 58
} -- 58
local function pressedKeys() -- 77
	return { -- 78
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 79
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 80
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 81
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 82
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 83
	} -- 83
end -- 77
local function hitIndex(boxes, pointer, inside) -- 87
	if not inside then -- 87
		return -1 -- 89
	end -- 89
	return __TS__ArrayFindIndex( -- 91
		boxes, -- 91
		function(____, box) return box:containsPoint(pointer) end -- 91
	) -- 91
end -- 87
____exports.MenuRenderer = __TS__Class() -- 94
local MenuRenderer = ____exports.MenuRenderer -- 94
MenuRenderer.name = "MenuRenderer" -- 94
function MenuRenderer.prototype.____constructor(self) -- 94
	self.selected = 0 -- 95
	self.chapterSelected = 0 -- 96
	self.pauseSelected = 0 -- 97
	self.chaptersFromPause = false -- 98
	self.previousKeys = {} -- 99
	self.queuedKeys = {} -- 100
	self.queuedBack = false -- 101
	self.time = 0 -- 102
end -- 94
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 104
	self.chaptersFromPause = roomIndex ~= nil -- 105
	self.chapterSelected = roomIndex or 0 -- 106
	self:resetInput() -- 107
end -- 104
function MenuRenderer.prototype.openPause(self) -- 110
	self.pauseSelected = 0 -- 111
	self:resetInput() -- 112
end -- 110
function MenuRenderer.prototype.resetInput(self) -- 116
	self.previousKeys = pressedKeys() -- 117
	self.queuedKeys = {} -- 118
	self.queuedBack = false -- 119
end -- 116
function MenuRenderer.prototype.onKeyEvent(self, key) -- 123
	if key == "Up" or key == "W" then -- 123
		self.queuedKeys.up = true -- 125
	elseif key == "Down" or key == "S" then -- 125
		self.queuedKeys.down = true -- 127
	elseif key == "Left" or key == "A" then -- 127
		self.queuedKeys.left = true -- 129
	elseif key == "Right" or key == "D" then -- 129
		self.queuedKeys.right = true -- 131
	elseif key == "Return" or key == "Space" then -- 131
		self.queuedKeys.confirm = true -- 133
	elseif key == "Escape" then -- 133
		self.queuedBack = true -- 135
	end -- 135
end -- 123
function MenuRenderer.prototype.readFrame(self, input, scale) -- 139
	local held = pressedKeys() -- 140
	local prev = self.previousKeys -- 141
	local queued = self.queuedKeys -- 142
	local frame = { -- 143
		keys = { -- 144
			up = queued.up == true or held.up and not prev.up, -- 145
			down = queued.down == true or held.down and not prev.down, -- 146
			left = queued.left == true or held.left and not prev.left, -- 147
			right = queued.right == true or held.right and not prev.right, -- 148
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 149
		}, -- 149
		back = self.queuedBack or input.pause.pressed, -- 151
		pointer = Vec2(input.mx / scale, input.my / scale), -- 152
		inside = input.inside, -- 153
		click = input.inside and input.fire.pressed, -- 154
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 155
	} -- 155
	self.previousKeys = held -- 157
	self.queuedKeys = {} -- 158
	self.queuedBack = false -- 159
	return frame -- 160
end -- 139
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 163
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 164
	if frame.click and hit >= 0 then -- 164
		return hit -- 166
	end -- 166
	if frame.keys.up then -- 166
		return (selected + #boxes - 1) % #boxes -- 169
	end -- 169
	if frame.keys.down then -- 169
		return (selected + 1) % #boxes -- 172
	end -- 172
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 174
end -- 163
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 177
	self.time = self.time + dt -- 194
	local artW = math.max(w, h * 16 / 9) -- 195
	local artH = artW * 9 / 16 -- 196
	if not backdropArt:tryPlace( -- 196
		"title_backdrop", -- 197
		"menu_landscape", -- 197
		w * 0.5, -- 197
		(h - artH) * 0.5, -- 197
		artW, -- 197
		artH -- 197
	) then -- 197
		stage:drawMenuBackdrop( -- 198
			bgDraw, -- 198
			bgGlow, -- 198
			w, -- 198
			h, -- 198
			self.time -- 198
		) -- 198
	end -- 198
	local frame = self:readFrame(input, uiScale) -- 201
	w = w / uiScale -- 202
	h = h / uiScale -- 203
	if screen == "title" then -- 203
		return self:drawTitle( -- 206
			frame, -- 206
			uiDraw, -- 206
			uiInkDraw, -- 206
			uiArt, -- 206
			uiGlow, -- 206
			texts, -- 206
			w, -- 206
			h -- 206
		) -- 206
	end -- 206
	if screen == "chapters" then -- 206
		return self:drawChapters( -- 209
			frame, -- 209
			uiDraw, -- 209
			uiInkDraw, -- 209
			uiArt, -- 209
			uiGlow, -- 209
			texts, -- 209
			w, -- 209
			h -- 209
		) -- 209
	end -- 209
	return self:drawControls( -- 211
		frame, -- 211
		uiDraw, -- 211
		uiInkDraw, -- 211
		uiArt, -- 211
		uiGlow, -- 211
		texts, -- 211
		w, -- 211
		h -- 211
	) -- 211
end -- 177
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 214
	fillHGradRect( -- 225
		uiDraw, -- 225
		0, -- 225
		0, -- 225
		w * 0.22, -- 225
		h, -- 225
		Color(9, 11, 18, 192), -- 225
		Color(9, 11, 18, 116) -- 225
	) -- 225
	fillHGradRect( -- 226
		uiDraw, -- 226
		w * 0.22, -- 226
		0, -- 226
		w * 0.28, -- 226
		h, -- 226
		Color(9, 11, 18, 116), -- 226
		Color(9, 11, 18, 0) -- 226
	) -- 226
	fillVGradRect( -- 227
		uiDraw, -- 227
		0, -- 227
		0, -- 227
		w, -- 227
		78, -- 227
		Color(8, 10, 16, 138), -- 227
		Color(8, 10, 16, 0) -- 227
	) -- 227
	local titleX = 148 -- 230
	local topY = h - 104 -- 231
	local charStep = 66 -- 232
	local sway = math.sin(self.time * 0.7) * 5 -- 233
	drawMistCurve( -- 234
		uiArt, -- 234
		"title_mist_wisp", -- 234
		titleX + 86 + sway, -- 234
		topY - 122, -- 234
		340, -- 234
		82, -- 234
		PALETTE.jadeMist, -- 234
		0.2, -- 234
		-1 -- 234
	) -- 234
	uiArt:tryPlace( -- 235
		"ink_petal_mist", -- 235
		"title_petals", -- 235
		titleX + 12, -- 235
		topY - 102, -- 235
		230, -- 235
		210, -- 235
		{ -- 235
			color = toColor(PALETTE.inkMist), -- 236
			opacity = 0.4, -- 236
			layer = -1 -- 236
		} -- 236
	) -- 236
	uiArt:tryPlace( -- 238
		"ink_vstream", -- 238
		"title_vstream", -- 238
		titleX - 48, -- 238
		topY - 100, -- 238
		34, -- 238
		290, -- 238
		{ -- 238
			color = toColor(PALETTE.silkDim), -- 239
			opacity = 0.48, -- 239
			layer = 1 -- 239
		} -- 239
	) -- 239
	local c = 0 -- 243
	do -- 243
		c = 0 -- 244
		while c < #VERTICAL_TITLE do -- 244
			texts:put( -- 245
				"title", -- 246
				VERTICAL_TITLE[c + 1], -- 247
				titleX, -- 248
				topY - c * charStep, -- 249
				toColor(PALETTE.textBright), -- 250
				0.5, -- 251
				0.5, -- 252
				"Center", -- 253
				0, -- 254
				0.98, -- 255
				0.1, -- 256
				Color(8, 10, 16, 210) -- 257
			) -- 257
			c = c + 1 -- 244
		end -- 244
	end -- 244
	drawLoneSeal( -- 262
		uiInkDraw, -- 263
		uiArt, -- 264
		texts, -- 265
		"title_lone_seal", -- 266
		titleX + 46, -- 267
		topY - 3 * charStep + 8, -- 268
		26, -- 269
		52, -- 270
		"守", -- 271
		"望", -- 272
		PALETTE.sealRed, -- 273
		PALETTE.sealText, -- 274
		0.94, -- 275
		4 -- 276
	) -- 276
	local colRightX = titleX + 132 -- 280
	local colLeftX = titleX + 102 -- 281
	local poemStep = 22 -- 282
	local p = 0 -- 283
	do -- 283
		p = 0 -- 284
		while p < #EPIGRAPH_RIGHT do -- 284
			local ch = EPIGRAPH_RIGHT[p + 1] -- 285
			if ch ~= "" then -- 285
				texts:put( -- 287
					"xs", -- 287
					ch, -- 287
					colRightX, -- 287
					topY - 22 - p * poemStep, -- 287
					toColor(PALETTE.textMid), -- 287
					0.5, -- 287
					0.5, -- 287
					"Center", -- 287
					0, -- 287
					0.86, -- 287
					0.08 -- 287
				) -- 287
			end -- 287
			p = p + 1 -- 284
		end -- 284
	end -- 284
	do -- 284
		p = 0 -- 290
		while p < #EPIGRAPH_LEFT do -- 290
			texts:put( -- 291
				"xs", -- 291
				EPIGRAPH_LEFT[p + 1], -- 291
				colLeftX, -- 291
				topY - 68 - p * poemStep, -- 291
				toColor(PALETTE.amberCore), -- 291
				0.5, -- 291
				0.5, -- 291
				"Center", -- 291
				0, -- 291
				0.9, -- 291
				0.08 -- 291
			) -- 291
			p = p + 1 -- 290
		end -- 290
	end -- 290
	local menuX = 112 -- 295
	local btnW = 280 -- 296
	local btnH = 44 -- 297
	local gap = 12 -- 298
	local startY = 252 -- 299
	local boxes = {} -- 300
	local i = 0 -- 301
	do -- 301
		i = 0 -- 302
		while i < #TITLE_ITEMS do -- 302
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 303
			i = i + 1 -- 302
		end -- 302
	end -- 302
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 305
	do -- 305
		i = 0 -- 307
		while i < #TITLE_ITEMS do -- 307
			local by = boxes[i + 1].y -- 308
			local active = self.selected == i -- 309
			local cy = by + btnH * 0.5 -- 310
			local shiftX = active and 10 or 0 -- 311
			if active then -- 311
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 314
				drawSilkRibbon( -- 315
					uiDraw, -- 315
					uiArt, -- 315
					"title_rib_red_" .. tostring(i), -- 315
					menuX + 124, -- 315
					cy, -- 315
					290, -- 315
					40, -- 315
					PALETTE.rougeSoft, -- 315
					0.52 * breathe, -- 315
					0 -- 315
				) -- 315
				drawHairline( -- 316
					uiInkDraw, -- 316
					uiArt, -- 316
					"title_rib_line_" .. tostring(i), -- 316
					menuX + 114, -- 316
					by + 4, -- 316
					230, -- 316
					PALETTE.silkLine, -- 316
					0.42 * breathe, -- 316
					false, -- 316
					2 -- 316
				) -- 316
				drawBlossomDot( -- 317
					uiInkDraw, -- 317
					uiArt, -- 317
					"title_dot_" .. tostring(i), -- 317
					menuX + 14, -- 317
					cy, -- 317
					16, -- 317
					PALETTE.rouge, -- 317
					0.96, -- 317
					4 -- 317
				) -- 317
				fillRadialGlow( -- 318
					uiGlow, -- 318
					menuX + 14, -- 318
					cy, -- 318
					22, -- 318
					16, -- 318
					toColor(PALETTE.rouge, 28 * breathe), -- 318
					Color(182, 58, 56, 0), -- 318
					10 -- 318
				) -- 318
			else -- 318
				drawBlossomDot( -- 320
					uiInkDraw, -- 320
					uiArt, -- 320
					"title_dot_" .. tostring(i), -- 320
					menuX + 14, -- 320
					cy, -- 320
					8, -- 320
					PALETTE.silkDim, -- 320
					0.4, -- 320
					3 -- 320
				) -- 320
			end -- 320
			texts:put( -- 323
				"md", -- 324
				TITLE_ITEMS[i + 1].zh, -- 325
				menuX + 34 + shiftX, -- 326
				cy, -- 327
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 328
				0, -- 329
				0.5, -- 330
				"Left", -- 331
				active and 4.4 or 2.8, -- 332
				active and 1 or 0.88, -- 333
				0.1 -- 334
			) -- 334
			i = i + 1 -- 307
		end -- 307
	end -- 307
	texts:put( -- 338
		"xs", -- 338
		"上下择项   ·   回车或点选启程", -- 338
		menuX + 12, -- 338
		42, -- 338
		toColor(PALETTE.textDim), -- 338
		0, -- 338
		0.5, -- 338
		"Left", -- 338
		1.4, -- 338
		0.88, -- 338
		0.08 -- 338
	) -- 338
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 340
	if hit >= 0 or frame.keys.confirm then -- 340
		local idx = hit >= 0 and hit or self.selected -- 342
		local id = TITLE_ITEMS[idx + 1].id -- 343
		if id == "start" then -- 343
			return {type = "start"} -- 345
		end -- 345
		if id == "chapters" then -- 345
			return {type = "openChapters"} -- 348
		end -- 348
		return {type = "openControls"} -- 350
	end -- 350
	return {type = "none"} -- 352
end -- 214
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 359
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 369
	if frame.back then -- 369
		return back -- 371
	end -- 371
	local marginX = 96 -- 374
	local trackY = 148 -- 375
	local trackX0 = marginX + 34 -- 376
	local trackX1 = w - marginX - 34 -- 377
	local stepX = (trackX1 - trackX0) / (#ROOMS - 1) -- 378
	local stationBoxes = {} -- 380
	local s = 0 -- 381
	do -- 381
		s = 0 -- 382
		while s < #ROOMS do -- 382
			local sx = trackX0 + s * stepX -- 383
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, trackY - 46, stepX * 0.9, 92) -- 384
			s = s + 1 -- 382
		end -- 382
	end -- 382
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 387
	local keys = frame.keys -- 388
	if frame.click and hitStation >= 0 then -- 388
		self.chapterSelected = hitStation -- 390
	elseif keys.left or keys.right or keys.up or keys.down then -- 390
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 392
		self.chapterSelected = (self.chapterSelected + step + #ROOMS) % #ROOMS -- 393
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 393
		self.chapterSelected = hitStation -- 395
	end -- 395
	uiDraw:drawRect( -- 399
		Rect(0, 0, w, h), -- 399
		Color(10, 12, 19, 198) -- 399
	) -- 399
	texts:put( -- 402
		"banner", -- 402
		"千里行纪", -- 402
		marginX, -- 402
		h - 66, -- 402
		toColor(PALETTE.textBright), -- 402
		0, -- 402
		0.5, -- 402
		"Left", -- 402
		4.5, -- 402
		0.96, -- 402
		0.1 -- 402
	) -- 402
	texts:put( -- 403
		"xs", -- 403
		"双线八驿 · 择章重历", -- 403
		marginX + 196, -- 403
		h - 70, -- 403
		toColor(PALETTE.textDim), -- 403
		0, -- 403
		0.5, -- 403
		"Left", -- 403
		2, -- 403
		0.85, -- 403
		0.08 -- 403
	) -- 403
	drawHairline( -- 404
		uiInkDraw, -- 404
		uiArt, -- 404
		"chap_top_line", -- 404
		w * 0.5, -- 404
		h - 100, -- 404
		w - marginX * 2, -- 404
		PALETTE.silkDim, -- 404
		0.6, -- 404
		true, -- 404
		2 -- 404
	) -- 404
	local activeRoom = ROOMS[self.chapterSelected + 1] -- 407
	local theme = themeOf(activeRoom.key) -- 408
	local winX = marginX -- 409
	local winY = 266 -- 410
	local winW = 548 -- 411
	local winH = 300 -- 412
	local winBox = Rect(winX, winY, winW, winH) -- 413
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 414
	uiArt:tryPlace( -- 417
		"ink_frame_mask", -- 417
		"chap_win_shadow", -- 417
		winX + winW * 0.5, -- 417
		winY + winH * 0.5, -- 417
		winW + 40, -- 417
		winH + 34, -- 417
		{ -- 417
			color = toColor(PALETTE.inkVoid), -- 418
			opacity = 0.88, -- 418
			layer = -2 -- 418
		} -- 418
	) -- 418
	local bgSlot = "bgFar_" .. activeRoom.key -- 420
	uiArt:tryPlace( -- 421
		bgSlot, -- 421
		"chap_win_art", -- 421
		winX + winW * 0.5, -- 421
		winY + 4, -- 421
		winW - 8, -- 421
		winH - 8, -- 421
		{opacity = 0.92, layer = -1} -- 421
	) -- 421
	fillVGradRect( -- 425
		uiInkDraw, -- 425
		winX, -- 425
		winY, -- 425
		winW, -- 425
		56, -- 425
		Color(10, 12, 19, 200), -- 425
		Color(10, 12, 19, 0) -- 425
	) -- 425
	fillVGradRect( -- 426
		uiInkDraw, -- 426
		winX, -- 426
		winY + winH - 36, -- 426
		winW, -- 426
		36, -- 426
		Color(10, 12, 19, 0), -- 426
		Color(10, 12, 19, 130) -- 426
	) -- 426
	fillHGradRect( -- 427
		uiInkDraw, -- 427
		winX, -- 427
		winY, -- 427
		34, -- 427
		winH, -- 427
		Color(10, 12, 19, 135), -- 427
		Color(10, 12, 19, 0) -- 427
	) -- 427
	fillHGradRect( -- 428
		uiInkDraw, -- 428
		winX + winW - 34, -- 428
		winY, -- 428
		34, -- 428
		winH, -- 428
		Color(10, 12, 19, 0), -- 428
		Color(10, 12, 19, 135) -- 428
	) -- 428
	drawFiligreeCorners( -- 430
		uiInkDraw, -- 430
		uiArt, -- 430
		"chap_win_frame", -- 430
		winX, -- 430
		winY, -- 430
		winW, -- 430
		winH, -- 430
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 430
		winHover and 0.92 or 0.72, -- 430
		34, -- 430
		true, -- 430
		3 -- 430
	) -- 430
	texts:put( -- 433
		"xs", -- 433
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 433
		winX + 20, -- 433
		winY + 22, -- 433
		toColor(PALETTE.textMid), -- 433
		0, -- 433
		0.5, -- 433
		"Left", -- 433
		1.8, -- 433
		0.9, -- 433
		0.08 -- 433
	) -- 433
	local infoX = winX + winW + 46 -- 436
	local infoCenterY = winY + winH * 0.5 -- 437
	drawMistCurve( -- 438
		uiArt, -- 438
		"chap_info_mist", -- 438
		infoX + 210, -- 438
		infoCenterY + 36, -- 438
		420, -- 438
		88, -- 438
		theme.accent, -- 438
		0.22, -- 438
		-1 -- 438
	) -- 438
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 441
	texts:put( -- 442
		"xs", -- 442
		theme.volumeTagZh, -- 442
		infoX, -- 442
		winY + winH - 44, -- 442
		toColor(volCol), -- 442
		0, -- 442
		0.5, -- 442
		"Left", -- 442
		2.8, -- 442
		0.92, -- 442
		0.08 -- 442
	) -- 442
	local sep = " · " -- 445
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 446
	local titleY = winY + winH - 98 -- 447
	if sIdx > 0 then -- 447
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 449
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 450
		local lw = visualTextWidth(leftPart, 40) -- 451
		texts:put( -- 452
			"banner", -- 452
			leftPart, -- 452
			infoX, -- 452
			titleY, -- 452
			toColor(PALETTE.textBright), -- 452
			0, -- 452
			0.5, -- 452
			"Left", -- 452
			2, -- 452
			1, -- 452
			0.1 -- 452
		) -- 452
		drawBlossomDot( -- 453
			uiInkDraw, -- 453
			uiArt, -- 453
			"chap_title_dot", -- 453
			infoX + lw + 16, -- 453
			titleY - 2, -- 453
			11, -- 453
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 453
			0.9, -- 453
			4 -- 453
		) -- 453
		texts:put( -- 454
			"banner", -- 454
			rightPart, -- 454
			infoX + lw + 32, -- 454
			titleY, -- 454
			toColor(PALETTE.textBright), -- 454
			0, -- 454
			0.5, -- 454
			"Left", -- 454
			2, -- 454
			1, -- 454
			0.1 -- 454
		) -- 454
	else -- 454
		texts:put( -- 456
			"banner", -- 456
			theme.titleZh, -- 456
			infoX, -- 456
			titleY, -- 456
			toColor(PALETTE.textBright), -- 456
			0, -- 456
			0.5, -- 456
			"Left", -- 456
			2.4, -- 456
			1, -- 456
			0.1 -- 456
		) -- 456
	end -- 456
	drawHairline( -- 459
		uiInkDraw, -- 459
		uiArt, -- 459
		"chap_info_line", -- 459
		infoX + 185, -- 459
		titleY - 36, -- 459
		370, -- 459
		PALETTE.silkDim, -- 459
		0.58, -- 459
		false, -- 459
		2 -- 459
	) -- 459
	texts:put( -- 462
		"sm", -- 462
		theme.introWhisper, -- 462
		infoX, -- 462
		titleY - 72, -- 462
		toColor(PALETTE.textMid), -- 462
		0, -- 462
		0.5, -- 462
		"Left", -- 462
		0.8, -- 462
		0.94, -- 462
		0.08 -- 462
	) -- 462
	local goX = infoX -- 465
	local goY = winY + 26 -- 466
	local goW = 220 -- 467
	local goH = 42 -- 468
	local goBox = Rect(goX, goY, goW, goH) -- 469
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 470
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 471
	drawSilkRibbon( -- 472
		uiDraw, -- 472
		uiArt, -- 472
		"chap_go_rib", -- 472
		goX + 106, -- 472
		goY + 21, -- 472
		250, -- 472
		40, -- 472
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 472
		(goHover and 0.68 or 0.46) * breathe, -- 472
		0 -- 472
	) -- 472
	drawHairline( -- 473
		uiInkDraw, -- 473
		uiArt, -- 473
		"chap_go_line", -- 473
		goX + 94, -- 473
		goY + 3, -- 473
		196, -- 473
		PALETTE.silkLine, -- 473
		goHover and 0.68 or 0.4, -- 473
		false, -- 473
		2 -- 473
	) -- 473
	drawBlossomDot( -- 474
		uiInkDraw, -- 474
		uiArt, -- 474
		"chap_go_dot", -- 474
		goX + 14, -- 474
		goY + 21, -- 474
		14, -- 474
		PALETTE.rouge, -- 474
		0.96, -- 474
		4 -- 474
	) -- 474
	texts:put( -- 475
		"md", -- 475
		"入此卷章", -- 475
		goX + 34, -- 475
		goY + 21, -- 475
		toColor(PALETTE.textBright), -- 475
		0, -- 475
		0.5, -- 475
		"Left", -- 475
		3.8, -- 475
		1, -- 475
		0.1 -- 475
	) -- 475
	texts:put( -- 476
		"xs", -- 476
		"Enter", -- 476
		goX + 156, -- 476
		goY + 21, -- 476
		toColor(PALETTE.textDim), -- 476
		0, -- 476
		0.5, -- 476
		"Left", -- 476
		1, -- 476
		0.82, -- 476
		0.08 -- 476
	) -- 476
	drawSilkVeil( -- 479
		uiDraw, -- 479
		uiArt, -- 479
		"chap_track_veil", -- 479
		w * 0.5, -- 479
		trackY + 6, -- 479
		w - marginX * 1.1, -- 479
		126, -- 479
		PALETTE.inkWash, -- 479
		0.72, -- 479
		-2 -- 479
	) -- 479
	drawMistCurve( -- 480
		uiArt, -- 480
		"chap_track_mist", -- 480
		w * 0.5, -- 480
		trackY, -- 480
		trackX1 - trackX0 + 160, -- 480
		74, -- 480
		PALETTE.inkMist, -- 480
		0.62, -- 480
		-1 -- 480
	) -- 480
	uiInkDraw:drawSegment( -- 481
		Vec2(trackX0, trackY), -- 481
		Vec2(trackX1, trackY), -- 481
		0.9, -- 481
		toColor(PALETTE.silkDim, 145) -- 481
	) -- 481
	local midDivX = trackX0 + stepX * 3.5 -- 484
	uiInkDraw:drawSegment( -- 485
		Vec2(midDivX, trackY - 12), -- 485
		Vec2(midDivX, trackY + 12), -- 485
		0.8, -- 485
		toColor(PALETTE.silkDim, 120) -- 485
	) -- 485
	texts:put( -- 486
		"xs", -- 486
		"上卷 · 孤城护童", -- 486
		trackX0 + stepX * 1.5, -- 486
		trackY + 52, -- 486
		toColor(PALETTE.cyan), -- 486
		0.5, -- 486
		0.5, -- 486
		"Center", -- 486
		2.2, -- 486
		0.88, -- 486
		0.08 -- 486
	) -- 486
	texts:put( -- 487
		"xs", -- 487
		"下卷 · 独赴北塔", -- 487
		trackX0 + stepX * 5.5, -- 487
		trackY + 52, -- 487
		toColor(PALETTE.amber), -- 487
		0.5, -- 487
		0.5, -- 487
		"Center", -- 487
		2.2, -- 487
		0.88, -- 487
		0.08 -- 487
	) -- 487
	local i = 0 -- 489
	do -- 489
		i = 0 -- 490
		while i < #ROOMS do -- 490
			local sx = trackX0 + i * stepX -- 491
			local rt = themeOf(ROOMS[i + 1].key) -- 492
			local active = self.chapterSelected == i -- 493
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 494
			if active then -- 494
				fillRadialGlow( -- 497
					uiGlow, -- 497
					sx, -- 497
					trackY, -- 497
					26, -- 497
					26, -- 497
					toColor(PALETTE.rouge, 36 * breathe), -- 497
					Color(182, 58, 56, 0), -- 497
					12 -- 497
				) -- 497
				uiArt:tryPlace( -- 498
					"ink_enso_fine", -- 498
					"chap_st_ring_" .. tostring(i), -- 498
					sx, -- 498
					trackY, -- 498
					32, -- 498
					32, -- 498
					{ -- 498
						color = toColor(PALETTE.silkLine), -- 499
						opacity = 0.78, -- 499
						angle = self.time * 18, -- 499
						layer = 3 -- 499
					} -- 499
				) -- 499
				drawBlossomDot( -- 501
					uiInkDraw, -- 501
					uiArt, -- 501
					"chap_st_dot_" .. tostring(i), -- 501
					sx, -- 501
					trackY, -- 501
					17, -- 501
					PALETTE.rouge, -- 501
					0.98, -- 501
					4 -- 501
				) -- 501
			else -- 501
				uiArt:tryPlace( -- 503
					"ink_enso_fine", -- 503
					"chap_st_ring_" .. tostring(i), -- 503
					sx, -- 503
					trackY, -- 503
					16, -- 503
					16, -- 503
					{ -- 503
						color = toColor(nodeCol), -- 504
						opacity = 0.62, -- 504
						layer = 3 -- 504
					} -- 504
				) -- 504
				drawBlossomDot( -- 506
					uiInkDraw, -- 506
					uiArt, -- 506
					"chap_st_dot_" .. tostring(i), -- 506
					sx, -- 506
					trackY, -- 506
					7, -- 506
					PALETTE.silkLine, -- 506
					0.72, -- 506
					4 -- 506
				) -- 506
			end -- 506
			texts:put( -- 509
				"xs", -- 509
				rt.numeralZh, -- 509
				sx, -- 509
				trackY + 25, -- 509
				toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 509
				0.5, -- 509
				0.5, -- 509
				"Center", -- 509
				0, -- 509
				active and 1 or 0.88, -- 509
				0.08 -- 509
			) -- 509
			texts:put( -- 510
				"xs", -- 510
				rt.shortNameZh, -- 510
				sx, -- 510
				trackY - 26, -- 510
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 510
				0.5, -- 510
				0.5, -- 510
				"Center", -- 510
				1, -- 510
				active and 1 or 0.84, -- 510
				0.08 -- 510
			) -- 510
			i = i + 1 -- 490
		end -- 490
	end -- 490
	local backX = marginX -- 514
	local backY = 40 -- 515
	local backBox = Rect(backX, backY, 190, 34) -- 516
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 517
	drawSilkKeycap( -- 518
		uiInkDraw, -- 518
		texts, -- 518
		backX, -- 518
		backY + 5, -- 518
		44, -- 518
		24, -- 518
		"ESC", -- 518
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 518
		0.92, -- 518
		backHover -- 518
	) -- 518
	texts:put( -- 519
		"sm", -- 519
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 519
		backX + 56, -- 519
		backY + 17, -- 519
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 519
		0, -- 519
		0.5, -- 519
		"Left", -- 519
		1.8, -- 519
		0.9, -- 519
		0.08 -- 519
	) -- 519
	texts:put( -- 520
		"xs", -- 520
		"← / → 沿驿道阅览   ·   Enter 或点选入章", -- 520
		w - marginX, -- 520
		backY + 17, -- 520
		toColor(PALETTE.textDim), -- 520
		1, -- 520
		0.5, -- 520
		"Right", -- 520
		1.2, -- 520
		0.75, -- 520
		0.08 -- 520
	) -- 520
	if frame.click and backHover then -- 520
		return back -- 523
	end -- 523
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 523
		return {type = "jump", roomIndex = self.chapterSelected} -- 526
	end -- 526
	return {type = "none"} -- 528
end -- 359
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h) -- 534
	local marginX = 96 -- 544
	local backX = marginX -- 545
	local backY = 40 -- 546
	local backBox = Rect(backX, backY, 230, 34) -- 547
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 548
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 548
		return {type = "backTitle"} -- 550
	end -- 550
	uiDraw:drawRect( -- 552
		Rect(0, 0, w, h), -- 552
		Color(10, 12, 19, 204) -- 552
	) -- 552
	texts:put( -- 554
		"banner", -- 554
		"执器要诀", -- 554
		marginX, -- 554
		h - 66, -- 554
		toColor(PALETTE.textBright), -- 554
		0, -- 554
		0.5, -- 554
		"Left", -- 554
		4.5, -- 554
		0.96, -- 554
		0.1 -- 554
	) -- 554
	texts:put( -- 555
		"xs", -- 555
		"键鼠操作说明", -- 555
		marginX + 196, -- 555
		h - 70, -- 555
		toColor(PALETTE.textDim), -- 555
		0, -- 555
		0.5, -- 555
		"Left", -- 555
		2, -- 555
		0.85, -- 555
		0.08 -- 555
	) -- 555
	drawHairline( -- 556
		uiInkDraw, -- 556
		uiArt, -- 556
		"ctrl_top_line", -- 556
		w * 0.5, -- 556
		h - 100, -- 556
		w - marginX * 2, -- 556
		PALETTE.silkDim, -- 556
		0.6, -- 556
		true, -- 556
		2 -- 556
	) -- 556
	local areaY = 114 -- 559
	local areaH = h - 244 -- 560
	drawFiligreeCorners( -- 561
		uiInkDraw, -- 561
		uiArt, -- 561
		"ctrl_outer", -- 561
		marginX, -- 561
		areaY, -- 561
		w - marginX * 2, -- 561
		areaH, -- 561
		PALETTE.silkDim, -- 561
		0.52, -- 561
		34, -- 561
		false, -- 561
		2 -- 561
	) -- 561
	local midX = w * 0.5 -- 564
	uiArt:tryPlace( -- 565
		"ink_vstream", -- 565
		"ctrl_mid_stream", -- 565
		midX, -- 565
		areaY + areaH * 0.5, -- 565
		32, -- 565
		areaH - 18, -- 565
		{ -- 565
			color = toColor(PALETTE.silkDim), -- 566
			opacity = 0.52, -- 566
			layer = 1 -- 566
		} -- 566
	) -- 566
	drawBlossomDot( -- 568
		uiInkDraw, -- 568
		uiArt, -- 568
		"ctrl_mid_dot", -- 568
		midX, -- 568
		areaY + areaH * 0.5, -- 568
		11, -- 568
		PALETTE.silkLine, -- 568
		0.62, -- 568
		3 -- 568
	) -- 568
	local leftColX = marginX + 34 -- 571
	local colW = midX - leftColX - 42 -- 572
	local headY = areaY + areaH - 34 -- 573
	drawBlossomDot( -- 574
		uiInkDraw, -- 574
		uiArt, -- 574
		"ctrl_l_dot", -- 574
		leftColX + 8, -- 574
		headY, -- 574
		12, -- 574
		PALETTE.cyan, -- 574
		0.88, -- 574
		3 -- 574
	) -- 574
	texts:put( -- 575
		"md", -- 575
		"周戍 · 护送与交锋", -- 575
		leftColX + 26, -- 575
		headY, -- 575
		toColor(PALETTE.cyanCore), -- 575
		0, -- 575
		0.5, -- 575
		"Left", -- 575
		2.4, -- 575
		0.98, -- 575
		0.08 -- 575
	) -- 575
	drawHairline( -- 576
		uiInkDraw, -- 576
		uiArt, -- 576
		"ctrl_l_line", -- 576
		leftColX + colW * 0.5, -- 576
		headY - 24, -- 576
		colW, -- 576
		PALETTE.cyanDim, -- 576
		0.58, -- 576
		false, -- 576
		2 -- 576
	) -- 576
	local sRows = { -- 578
		{"WASD / 方向键", "左右移动，按上下换一条路"}, -- 579
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 580
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 581
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 582
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 583
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 584
	} -- 584
	local i = 0 -- 586
	do -- 586
		i = 0 -- 587
		while i < #sRows do -- 587
			local ry = headY - 66 - i * 52 -- 588
			drawSilkKeycap( -- 589
				uiInkDraw, -- 589
				texts, -- 589
				leftColX + 2, -- 589
				ry - 13, -- 589
				132, -- 589
				26, -- 589
				sRows[i + 1][1], -- 589
				PALETTE.cyan, -- 589
				0.92, -- 589
				false -- 589
			) -- 589
			texts:put( -- 590
				"sm", -- 590
				sRows[i + 1][2], -- 590
				leftColX + 150, -- 590
				ry, -- 590
				toColor(PALETTE.textBright), -- 590
				0, -- 590
				0.5, -- 590
				"Left", -- 590
				0.8, -- 590
				0.92, -- 590
				0.08 -- 590
			) -- 590
			i = i + 1 -- 587
		end -- 587
	end -- 587
	local rightColX = midX + 44 -- 594
	drawBlossomDot( -- 595
		uiInkDraw, -- 595
		uiArt, -- 595
		"ctrl_r_dot", -- 595
		rightColX + 8, -- 595
		headY, -- 595
		12, -- 595
		PALETTE.amber, -- 595
		0.88, -- 595
		3 -- 595
	) -- 595
	texts:put( -- 596
		"md", -- 596
		"小满 · 潜行与寻路", -- 596
		rightColX + 26, -- 596
		headY, -- 596
		toColor(PALETTE.amberCore), -- 596
		0, -- 596
		0.5, -- 596
		"Left", -- 596
		2.4, -- 596
		0.98, -- 596
		0.08 -- 596
	) -- 596
	drawHairline( -- 597
		uiInkDraw, -- 597
		uiArt, -- 597
		"ctrl_r_line", -- 597
		rightColX + colW * 0.5, -- 597
		headY - 24, -- 597
		colW, -- 597
		PALETTE.amberDim, -- 597
		0.58, -- 597
		false, -- 597
		2 -- 597
	) -- 597
	local cRows = { -- 599
		{"A / D · ← / →", "左右潜行"}, -- 600
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 601
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 602
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 603
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 604
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 605
	} -- 605
	do -- 605
		i = 0 -- 607
		while i < #cRows do -- 607
			local ry = headY - 66 - i * 52 -- 608
			drawSilkKeycap( -- 609
				uiInkDraw, -- 609
				texts, -- 609
				rightColX + 2, -- 609
				ry - 13, -- 609
				132, -- 609
				26, -- 609
				cRows[i + 1][1], -- 609
				PALETTE.amber, -- 609
				0.92, -- 609
				false -- 609
			) -- 609
			texts:put( -- 610
				"sm", -- 610
				cRows[i + 1][2], -- 610
				rightColX + 150, -- 610
				ry, -- 610
				toColor(PALETTE.textBright), -- 610
				0, -- 610
				0.5, -- 610
				"Left", -- 610
				0.8, -- 610
				0.92, -- 610
				0.08 -- 610
			) -- 610
			i = i + 1 -- 607
		end -- 607
	end -- 607
	drawSilkKeycap( -- 614
		uiInkDraw, -- 614
		texts, -- 614
		backX, -- 614
		backY + 5, -- 614
		110, -- 614
		24, -- 614
		"ESC / ENTER", -- 614
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 614
		0.92, -- 614
		backHover -- 614
	) -- 614
	texts:put( -- 615
		"sm", -- 615
		"返回标题", -- 615
		backX + 122, -- 615
		backY + 17, -- 615
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 615
		0, -- 615
		0.5, -- 615
		"Left", -- 615
		1.8, -- 615
		0.92, -- 615
		0.08 -- 615
	) -- 615
	return {type = "none"} -- 617
end -- 534
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale) -- 623
	self.time = self.time + dt -- 635
	local frame = self:readFrame(input, uiScale) -- 636
	if frame.back then -- 636
		return {type = "resume"} -- 638
	end -- 638
	uiDraw:drawRect( -- 642
		Rect(0, 0, w, h), -- 642
		Color(8, 10, 16, 102) -- 642
	) -- 642
	fillHGradRect( -- 643
		uiDraw, -- 643
		0, -- 643
		0, -- 643
		w * 0.27, -- 643
		h, -- 643
		Color(9, 11, 18, 232), -- 643
		Color(10, 13, 21, 198) -- 643
	) -- 643
	fillHGradRect( -- 644
		uiDraw, -- 644
		w * 0.27, -- 644
		0, -- 644
		w * 0.21, -- 644
		h, -- 644
		Color(10, 13, 21, 198), -- 644
		Color(10, 13, 21, 0) -- 644
	) -- 644
	local menuX = 110 -- 647
	uiArt:tryPlace( -- 648
		"ink_vstream", -- 648
		"pause_vstream", -- 648
		menuX - 32, -- 648
		h * 0.5, -- 648
		34, -- 648
		h * 0.78, -- 648
		{ -- 648
			color = toColor(PALETTE.silkDim), -- 649
			opacity = 0.48, -- 649
			layer = 1 -- 649
		} -- 649
	) -- 649
	drawMistCurve( -- 651
		uiArt, -- 651
		"pause_mist", -- 651
		menuX + 118, -- 651
		h - 154, -- 651
		290, -- 651
		72, -- 651
		PALETTE.jadeMist, -- 651
		0.2, -- 651
		-1 -- 651
	) -- 651
	texts:put( -- 654
		"banner", -- 654
		"暂歇", -- 654
		menuX + 16, -- 654
		h - 146, -- 654
		toColor(PALETTE.textBright), -- 654
		0, -- 654
		0.5, -- 654
		"Left", -- 654
		10, -- 654
		0.98, -- 654
		0.1 -- 654
	) -- 654
	texts:put( -- 655
		"xs", -- 655
		"月夜暂驻 · 卷页留痕", -- 655
		menuX + 18, -- 655
		h - 184, -- 655
		toColor(PALETTE.textDim), -- 655
		0, -- 655
		0.5, -- 655
		"Left", -- 655
		2, -- 655
		0.8, -- 655
		0.08 -- 655
	) -- 655
	drawHairline( -- 656
		uiInkDraw, -- 656
		uiArt, -- 656
		"pause_div", -- 656
		menuX + 124, -- 656
		h - 210, -- 656
		240, -- 656
		PALETTE.silkDim, -- 656
		0.58, -- 656
		true, -- 656
		2 -- 656
	) -- 656
	local boxes = {} -- 658
	local i = 0 -- 659
	do -- 659
		i = 0 -- 660
		while i < #PAUSE_ITEMS do -- 660
			boxes[#boxes + 1] = Rect(menuX - 10, h - 284 - i * 60, 270, 44) -- 661
			i = i + 1 -- 660
		end -- 660
	end -- 660
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 663
	do -- 663
		i = 0 -- 665
		while i < #PAUSE_ITEMS do -- 665
			local iy = boxes[i + 1].y -- 666
			local active = self.pauseSelected == i -- 667
			local cy = iy + 22 -- 668
			local shiftX = active and 10 or 0 -- 669
			if active then -- 669
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 672
				drawSilkRibbon( -- 673
					uiDraw, -- 673
					uiArt, -- 673
					"pause_rib_" .. tostring(i), -- 673
					menuX + 116, -- 673
					cy, -- 673
					276, -- 673
					40, -- 673
					PALETTE.rougeSoft, -- 673
					0.54 * breathe, -- 673
					0 -- 673
				) -- 673
				drawHairline( -- 674
					uiInkDraw, -- 674
					uiArt, -- 674
					"pause_line_" .. tostring(i), -- 674
					menuX + 106, -- 674
					iy + 4, -- 674
					210, -- 674
					PALETTE.silkLine, -- 674
					0.42 * breathe, -- 674
					false, -- 674
					2 -- 674
				) -- 674
				drawBlossomDot( -- 675
					uiInkDraw, -- 675
					uiArt, -- 675
					"pause_dot_" .. tostring(i), -- 675
					menuX + 12, -- 675
					cy, -- 675
					15, -- 675
					PALETTE.rouge, -- 675
					0.96, -- 675
					4 -- 675
				) -- 675
				fillRadialGlow( -- 676
					uiGlow, -- 676
					menuX + 12, -- 676
					cy, -- 676
					22, -- 676
					16, -- 676
					toColor(PALETTE.rouge, 26 * breathe), -- 676
					Color(182, 58, 56, 0), -- 676
					10 -- 676
				) -- 676
			else -- 676
				drawBlossomDot( -- 678
					uiInkDraw, -- 678
					uiArt, -- 678
					"pause_dot_" .. tostring(i), -- 678
					menuX + 12, -- 678
					cy, -- 678
					8, -- 678
					PALETTE.silkDim, -- 678
					0.4, -- 678
					3 -- 678
				) -- 678
			end -- 678
			texts:put( -- 681
				"md", -- 682
				PAUSE_ITEMS[i + 1].zh, -- 683
				menuX + 32 + shiftX, -- 684
				cy, -- 685
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 686
				0, -- 687
				0.5, -- 688
				"Left", -- 689
				active and 3.8 or 2.4, -- 690
				active and 1 or 0.88, -- 691
				0.1 -- 692
			) -- 692
			i = i + 1 -- 665
		end -- 665
	end -- 665
	texts:put( -- 696
		"xs", -- 696
		"Esc 续行   ·   Enter 或点击确认", -- 696
		menuX + 12, -- 696
		56, -- 696
		toColor(PALETTE.textDim), -- 696
		0, -- 696
		0.5, -- 696
		"Left", -- 696
		1.2, -- 696
		0.86, -- 696
		0.08 -- 696
	) -- 696
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 698
	if hit >= 0 or frame.keys.confirm then -- 698
		local idx = hit >= 0 and hit or self.pauseSelected -- 700
		local id = PAUSE_ITEMS[idx + 1].id -- 701
		if id == "resume" then -- 701
			return {type = "resume"} -- 703
		end -- 703
		if id == "retry" then -- 703
			return {type = "retry"} -- 706
		end -- 706
		if id == "chapters" then -- 706
			return {type = "openChapters"} -- 709
		end -- 709
		return {type = "toTitle"} -- 711
	end -- 711
	return {type = "none"} -- 713
end -- 623
return ____exports -- 623