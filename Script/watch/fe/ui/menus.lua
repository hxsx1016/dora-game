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
local PAUSE_ITEMS = { -- 49
	{id = "resume", zh = "继续游戏"}, -- 50
	{id = "retry", zh = "重试检查点"}, -- 51
	{id = "controls", zh = "操作说明"}, -- 52
	{id = "assist", zh = "按键辅助：关"}, -- 53
	{id = "chapters", zh = "选择章节"}, -- 54
	{id = "title", zh = "返回标题"} -- 55
} -- 55
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 58
local EPIGRAPH_RIGHT = { -- 60
	"城", -- 60
	"破", -- 60
	"那", -- 60
	"天", -- 60
	"", -- 60
	"他", -- 60
	"留", -- 60
	"下", -- 60
	"断", -- 60
	"后" -- 60
} -- 60
local EPIGRAPH_LEFT = { -- 61
	"她", -- 61
	"独", -- 61
	"自", -- 61
	"走", -- 61
	"向", -- 61
	"北", -- 61
	"塔" -- 61
} -- 61
local function pressedKeys() -- 80
	return { -- 81
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 82
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 83
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 84
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 85
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 86
	} -- 86
end -- 80
local function hitIndex(boxes, pointer, inside) -- 90
	if not inside then -- 90
		return -1 -- 92
	end -- 92
	return __TS__ArrayFindIndex( -- 94
		boxes, -- 94
		function(____, box) return box:containsPoint(pointer) end -- 94
	) -- 94
end -- 90
____exports.MenuRenderer = __TS__Class() -- 97
local MenuRenderer = ____exports.MenuRenderer -- 97
MenuRenderer.name = "MenuRenderer" -- 97
function MenuRenderer.prototype.____constructor(self) -- 97
	self.selected = 0 -- 98
	self.chapterSelected = 0 -- 99
	self.pauseSelected = 0 -- 100
	self.chaptersFromPause = false -- 101
	self.pauseShowControls = false -- 103
	self.previousKeys = {} -- 104
	self.queuedKeys = {} -- 105
	self.queuedBack = false -- 106
	self.time = 0 -- 107
end -- 97
function MenuRenderer.prototype.isShowingPauseControls(self) -- 109
	return self.pauseShowControls -- 110
end -- 109
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 113
	self.chaptersFromPause = roomIndex ~= nil -- 114
	self.chapterSelected = roomIndex or 0 -- 115
	self.pauseShowControls = false -- 116
	self:resetInput() -- 117
end -- 113
function MenuRenderer.prototype.openPause(self) -- 120
	self.pauseSelected = 0 -- 121
	self.pauseShowControls = false -- 122
	self:resetInput() -- 123
end -- 120
function MenuRenderer.prototype.resetInput(self) -- 127
	self.previousKeys = pressedKeys() -- 128
	self.queuedKeys = {} -- 129
	self.queuedBack = false -- 130
end -- 127
function MenuRenderer.prototype.onKeyEvent(self, key) -- 134
	if key == "Up" or key == "W" then -- 134
		self.queuedKeys.up = true -- 136
	elseif key == "Down" or key == "S" then -- 136
		self.queuedKeys.down = true -- 138
	elseif key == "Left" or key == "A" then -- 138
		self.queuedKeys.left = true -- 140
	elseif key == "Right" or key == "D" then -- 140
		self.queuedKeys.right = true -- 142
	elseif key == "Return" or key == "Space" then -- 142
		self.queuedKeys.confirm = true -- 144
	elseif key == "Escape" then -- 144
		self.queuedBack = true -- 146
	end -- 146
end -- 134
function MenuRenderer.prototype.readFrame(self, input, scale) -- 150
	local held = pressedKeys() -- 151
	local prev = self.previousKeys -- 152
	local queued = self.queuedKeys -- 153
	local frame = { -- 154
		keys = { -- 155
			up = queued.up == true or held.up and not prev.up, -- 156
			down = queued.down == true or held.down and not prev.down, -- 157
			left = queued.left == true or held.left and not prev.left, -- 158
			right = queued.right == true or held.right and not prev.right, -- 159
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 160
		}, -- 160
		back = self.queuedBack or input.pause.pressed, -- 162
		pointer = Vec2(input.mx / scale, input.my / scale), -- 163
		inside = input.inside, -- 164
		click = input.inside and input.fire.pressed, -- 165
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 166
	} -- 166
	self.previousKeys = held -- 168
	self.queuedKeys = {} -- 169
	self.queuedBack = false -- 170
	return frame -- 171
end -- 150
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 174
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 175
	if frame.click and hit >= 0 then -- 175
		return hit -- 177
	end -- 177
	if frame.keys.up then -- 177
		return (selected + #boxes - 1) % #boxes -- 180
	end -- 180
	if frame.keys.down then -- 180
		return (selected + 1) % #boxes -- 183
	end -- 183
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 185
end -- 174
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 188
	self.time = self.time + dt -- 205
	local artW = math.max(w, h * 16 / 9) -- 206
	local artH = artW * 9 / 16 -- 207
	if not backdropArt:tryPlace( -- 207
		"title_backdrop", -- 208
		"menu_landscape", -- 208
		w * 0.5, -- 208
		(h - artH) * 0.5, -- 208
		artW, -- 208
		artH -- 208
	) then -- 208
		stage:drawMenuBackdrop( -- 209
			bgDraw, -- 209
			bgGlow, -- 209
			w, -- 209
			h, -- 209
			self.time -- 209
		) -- 209
	end -- 209
	local frame = self:readFrame(input, uiScale) -- 212
	w = w / uiScale -- 213
	h = h / uiScale -- 214
	if screen == "title" then -- 214
		return self:drawTitle( -- 217
			frame, -- 217
			uiDraw, -- 217
			uiInkDraw, -- 217
			uiArt, -- 217
			uiGlow, -- 217
			texts, -- 217
			w, -- 217
			h -- 217
		) -- 217
	end -- 217
	if screen == "chapters" then -- 217
		return self:drawChapters( -- 220
			frame, -- 220
			uiDraw, -- 220
			uiInkDraw, -- 220
			uiArt, -- 220
			uiGlow, -- 220
			texts, -- 220
			w, -- 220
			h -- 220
		) -- 220
	end -- 220
	return self:drawControls( -- 222
		frame, -- 222
		uiDraw, -- 222
		uiInkDraw, -- 222
		uiArt, -- 222
		uiGlow, -- 222
		texts, -- 222
		w, -- 222
		h -- 222
	) -- 222
end -- 188
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 225
	fillHGradRect( -- 236
		uiDraw, -- 236
		0, -- 236
		0, -- 236
		w * 0.22, -- 236
		h, -- 236
		Color(9, 11, 18, 192), -- 236
		Color(9, 11, 18, 116) -- 236
	) -- 236
	fillHGradRect( -- 237
		uiDraw, -- 237
		w * 0.22, -- 237
		0, -- 237
		w * 0.28, -- 237
		h, -- 237
		Color(9, 11, 18, 116), -- 237
		Color(9, 11, 18, 0) -- 237
	) -- 237
	fillVGradRect( -- 238
		uiDraw, -- 238
		0, -- 238
		0, -- 238
		w, -- 238
		78, -- 238
		Color(8, 10, 16, 138), -- 238
		Color(8, 10, 16, 0) -- 238
	) -- 238
	local titleX = 148 -- 241
	local topY = h - 104 -- 242
	local charStep = 66 -- 243
	local sway = math.sin(self.time * 0.7) * 5 -- 244
	drawMistCurve( -- 245
		uiArt, -- 245
		"title_mist_wisp", -- 245
		titleX + 86 + sway, -- 245
		topY - 122, -- 245
		340, -- 245
		82, -- 245
		PALETTE.jadeMist, -- 245
		0.2, -- 245
		-1 -- 245
	) -- 245
	uiArt:tryPlace( -- 246
		"ink_petal_mist", -- 246
		"title_petals", -- 246
		titleX + 12, -- 246
		topY - 102, -- 246
		230, -- 246
		210, -- 246
		{ -- 246
			color = toColor(PALETTE.inkMist), -- 247
			opacity = 0.4, -- 247
			layer = -1 -- 247
		} -- 247
	) -- 247
	uiArt:tryPlace( -- 249
		"ink_vstream", -- 249
		"title_vstream", -- 249
		titleX - 48, -- 249
		topY - 100, -- 249
		34, -- 249
		290, -- 249
		{ -- 249
			color = toColor(PALETTE.silkDim), -- 250
			opacity = 0.48, -- 250
			layer = 1 -- 250
		} -- 250
	) -- 250
	local c = 0 -- 254
	do -- 254
		c = 0 -- 255
		while c < #VERTICAL_TITLE do -- 255
			texts:put( -- 256
				"title", -- 257
				VERTICAL_TITLE[c + 1], -- 258
				titleX, -- 259
				topY - c * charStep, -- 260
				toColor(PALETTE.textBright), -- 261
				0.5, -- 262
				0.5, -- 263
				"Center", -- 264
				0, -- 265
				0.98, -- 266
				0.1, -- 267
				Color(8, 10, 16, 210) -- 268
			) -- 268
			c = c + 1 -- 255
		end -- 255
	end -- 255
	drawLoneSeal( -- 273
		uiInkDraw, -- 274
		uiArt, -- 275
		texts, -- 276
		"title_lone_seal", -- 277
		titleX + 46, -- 278
		topY - 3 * charStep + 8, -- 279
		26, -- 280
		52, -- 281
		"守", -- 282
		"望", -- 283
		PALETTE.sealRed, -- 284
		PALETTE.sealText, -- 285
		0.94, -- 286
		4 -- 287
	) -- 287
	local colRightX = titleX + 132 -- 291
	local colLeftX = titleX + 102 -- 292
	local poemStep = 22 -- 293
	local p = 0 -- 294
	do -- 294
		p = 0 -- 295
		while p < #EPIGRAPH_RIGHT do -- 295
			local ch = EPIGRAPH_RIGHT[p + 1] -- 296
			if ch ~= "" then -- 296
				texts:put( -- 298
					"xs", -- 298
					ch, -- 298
					colRightX, -- 298
					topY - 22 - p * poemStep, -- 298
					toColor(PALETTE.textMid), -- 298
					0.5, -- 298
					0.5, -- 298
					"Center", -- 298
					0, -- 298
					0.86, -- 298
					0.08 -- 298
				) -- 298
			end -- 298
			p = p + 1 -- 295
		end -- 295
	end -- 295
	do -- 295
		p = 0 -- 301
		while p < #EPIGRAPH_LEFT do -- 301
			texts:put( -- 302
				"xs", -- 302
				EPIGRAPH_LEFT[p + 1], -- 302
				colLeftX, -- 302
				topY - 68 - p * poemStep, -- 302
				toColor(PALETTE.amberCore), -- 302
				0.5, -- 302
				0.5, -- 302
				"Center", -- 302
				0, -- 302
				0.9, -- 302
				0.08 -- 302
			) -- 302
			p = p + 1 -- 301
		end -- 301
	end -- 301
	local menuX = 112 -- 306
	local btnW = 280 -- 307
	local btnH = 44 -- 308
	local gap = 12 -- 309
	local startY = 252 -- 310
	local boxes = {} -- 311
	local i = 0 -- 312
	do -- 312
		i = 0 -- 313
		while i < #TITLE_ITEMS do -- 313
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 314
			i = i + 1 -- 313
		end -- 313
	end -- 313
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 316
	do -- 316
		i = 0 -- 318
		while i < #TITLE_ITEMS do -- 318
			local by = boxes[i + 1].y -- 319
			local active = self.selected == i -- 320
			local cy = by + btnH * 0.5 -- 321
			local shiftX = active and 10 or 0 -- 322
			if active then -- 322
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 325
				drawSilkRibbon( -- 326
					uiDraw, -- 326
					uiArt, -- 326
					"title_rib_red_" .. tostring(i), -- 326
					menuX + 124, -- 326
					cy, -- 326
					290, -- 326
					40, -- 326
					PALETTE.rougeSoft, -- 326
					0.52 * breathe, -- 326
					0 -- 326
				) -- 326
				drawHairline( -- 327
					uiInkDraw, -- 327
					uiArt, -- 327
					"title_rib_line_" .. tostring(i), -- 327
					menuX + 114, -- 327
					by + 4, -- 327
					230, -- 327
					PALETTE.silkLine, -- 327
					0.42 * breathe, -- 327
					false, -- 327
					2 -- 327
				) -- 327
				drawBlossomDot( -- 328
					uiInkDraw, -- 328
					uiArt, -- 328
					"title_dot_" .. tostring(i), -- 328
					menuX + 14, -- 328
					cy, -- 328
					16, -- 328
					PALETTE.rouge, -- 328
					0.96, -- 328
					4 -- 328
				) -- 328
				fillRadialGlow( -- 329
					uiGlow, -- 329
					menuX + 14, -- 329
					cy, -- 329
					22, -- 329
					16, -- 329
					toColor(PALETTE.rouge, 28 * breathe), -- 329
					Color(182, 58, 56, 0), -- 329
					10 -- 329
				) -- 329
			else -- 329
				drawBlossomDot( -- 331
					uiInkDraw, -- 331
					uiArt, -- 331
					"title_dot_" .. tostring(i), -- 331
					menuX + 14, -- 331
					cy, -- 331
					8, -- 331
					PALETTE.silkDim, -- 331
					0.4, -- 331
					3 -- 331
				) -- 331
			end -- 331
			texts:put( -- 334
				"md", -- 335
				TITLE_ITEMS[i + 1].zh, -- 336
				menuX + 34 + shiftX, -- 337
				cy, -- 338
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 339
				0, -- 340
				0.5, -- 341
				"Left", -- 342
				active and 4.4 or 2.8, -- 343
				active and 1 or 0.88, -- 344
				0.1 -- 345
			) -- 345
			i = i + 1 -- 318
		end -- 318
	end -- 318
	texts:put( -- 349
		"xs", -- 349
		"上下择项   ·   回车或点选启程", -- 349
		menuX + 12, -- 349
		42, -- 349
		toColor(PALETTE.textDim), -- 349
		0, -- 349
		0.5, -- 349
		"Left", -- 349
		1.4, -- 349
		0.88, -- 349
		0.08 -- 349
	) -- 349
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 351
	if hit >= 0 or frame.keys.confirm then -- 351
		local idx = hit >= 0 and hit or self.selected -- 353
		local id = TITLE_ITEMS[idx + 1].id -- 354
		if id == "trial" then -- 354
			return {type = "trial"} -- 355
		end -- 355
		if id == "start" then -- 355
			return {type = "start"} -- 357
		end -- 357
		if id == "chapters" then -- 357
			return {type = "openChapters"} -- 360
		end -- 360
		return {type = "openControls"} -- 362
	end -- 362
	return {type = "none"} -- 364
end -- 225
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 371
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 381
	if frame.back then -- 381
		return back -- 383
	end -- 383
	local marginX = 96 -- 386
	local trackY = 148 -- 387
	local trackX0 = marginX + 34 -- 388
	local trackX1 = w - marginX - 34 -- 389
	local stepX = (trackX1 - trackX0) / (#ROOMS - 1) -- 390
	local stationBoxes = {} -- 392
	local s = 0 -- 393
	do -- 393
		s = 0 -- 394
		while s < #ROOMS do -- 394
			local sx = trackX0 + s * stepX -- 395
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, trackY - 46, stepX * 0.9, 92) -- 396
			s = s + 1 -- 394
		end -- 394
	end -- 394
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 399
	local keys = frame.keys -- 400
	if frame.click and hitStation >= 0 then -- 400
		self.chapterSelected = hitStation -- 402
	elseif keys.left or keys.right or keys.up or keys.down then -- 402
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 404
		self.chapterSelected = (self.chapterSelected + step + #ROOMS) % #ROOMS -- 405
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 405
		self.chapterSelected = hitStation -- 407
	end -- 407
	uiDraw:drawRect( -- 411
		Rect(0, 0, w, h), -- 411
		Color(10, 12, 19, 198) -- 411
	) -- 411
	texts:put( -- 414
		"banner", -- 414
		"千里行纪", -- 414
		marginX, -- 414
		h - 66, -- 414
		toColor(PALETTE.textBright), -- 414
		0, -- 414
		0.5, -- 414
		"Left", -- 414
		4.5, -- 414
		0.96, -- 414
		0.1 -- 414
	) -- 414
	texts:put( -- 415
		"xs", -- 415
		"双线八驿 · 择章重历", -- 415
		marginX + 196, -- 415
		h - 70, -- 415
		toColor(PALETTE.textDim), -- 415
		0, -- 415
		0.5, -- 415
		"Left", -- 415
		2, -- 415
		0.85, -- 415
		0.08 -- 415
	) -- 415
	drawHairline( -- 416
		uiInkDraw, -- 416
		uiArt, -- 416
		"chap_top_line", -- 416
		w * 0.5, -- 416
		h - 100, -- 416
		w - marginX * 2, -- 416
		PALETTE.silkDim, -- 416
		0.6, -- 416
		true, -- 416
		2 -- 416
	) -- 416
	local activeRoom = ROOMS[self.chapterSelected + 1] -- 419
	local theme = themeOf(activeRoom.key) -- 420
	local winX = marginX -- 421
	local winY = 266 -- 422
	local winW = 548 -- 423
	local winH = 300 -- 424
	local winBox = Rect(winX, winY, winW, winH) -- 425
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 426
	uiArt:tryPlace( -- 429
		"ink_frame_mask", -- 429
		"chap_win_shadow", -- 429
		winX + winW * 0.5, -- 429
		winY + winH * 0.5, -- 429
		winW + 40, -- 429
		winH + 34, -- 429
		{ -- 429
			color = toColor(PALETTE.inkVoid), -- 430
			opacity = 0.88, -- 430
			layer = -2 -- 430
		} -- 430
	) -- 430
	local bgSlot = "bgFar_" .. activeRoom.key -- 432
	uiArt:tryPlace( -- 433
		bgSlot, -- 433
		"chap_win_art", -- 433
		winX + winW * 0.5, -- 433
		winY + 4, -- 433
		winW - 8, -- 433
		winH - 8, -- 433
		{opacity = 0.92, layer = -1} -- 433
	) -- 433
	fillVGradRect( -- 437
		uiInkDraw, -- 437
		winX, -- 437
		winY, -- 437
		winW, -- 437
		56, -- 437
		Color(10, 12, 19, 200), -- 437
		Color(10, 12, 19, 0) -- 437
	) -- 437
	fillVGradRect( -- 438
		uiInkDraw, -- 438
		winX, -- 438
		winY + winH - 36, -- 438
		winW, -- 438
		36, -- 438
		Color(10, 12, 19, 0), -- 438
		Color(10, 12, 19, 130) -- 438
	) -- 438
	fillHGradRect( -- 439
		uiInkDraw, -- 439
		winX, -- 439
		winY, -- 439
		34, -- 439
		winH, -- 439
		Color(10, 12, 19, 135), -- 439
		Color(10, 12, 19, 0) -- 439
	) -- 439
	fillHGradRect( -- 440
		uiInkDraw, -- 440
		winX + winW - 34, -- 440
		winY, -- 440
		34, -- 440
		winH, -- 440
		Color(10, 12, 19, 0), -- 440
		Color(10, 12, 19, 135) -- 440
	) -- 440
	drawFiligreeCorners( -- 442
		uiInkDraw, -- 442
		uiArt, -- 442
		"chap_win_frame", -- 442
		winX, -- 442
		winY, -- 442
		winW, -- 442
		winH, -- 442
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 442
		winHover and 0.92 or 0.72, -- 442
		34, -- 442
		true, -- 442
		3 -- 442
	) -- 442
	texts:put( -- 445
		"xs", -- 445
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 445
		winX + 20, -- 445
		winY + 22, -- 445
		toColor(PALETTE.textMid), -- 445
		0, -- 445
		0.5, -- 445
		"Left", -- 445
		1.8, -- 445
		0.9, -- 445
		0.08 -- 445
	) -- 445
	local infoX = winX + winW + 46 -- 448
	local infoCenterY = winY + winH * 0.5 -- 449
	drawMistCurve( -- 450
		uiArt, -- 450
		"chap_info_mist", -- 450
		infoX + 210, -- 450
		infoCenterY + 36, -- 450
		420, -- 450
		88, -- 450
		theme.accent, -- 450
		0.22, -- 450
		-1 -- 450
	) -- 450
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 453
	texts:put( -- 454
		"xs", -- 454
		theme.volumeTagZh, -- 454
		infoX, -- 454
		winY + winH - 44, -- 454
		toColor(volCol), -- 454
		0, -- 454
		0.5, -- 454
		"Left", -- 454
		2.8, -- 454
		0.92, -- 454
		0.08 -- 454
	) -- 454
	local sep = " · " -- 457
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 458
	local titleY = winY + winH - 98 -- 459
	if sIdx > 0 then -- 459
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 461
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 462
		local lw = visualTextWidth(leftPart, 40) -- 463
		texts:put( -- 464
			"banner", -- 464
			leftPart, -- 464
			infoX, -- 464
			titleY, -- 464
			toColor(PALETTE.textBright), -- 464
			0, -- 464
			0.5, -- 464
			"Left", -- 464
			2, -- 464
			1, -- 464
			0.1 -- 464
		) -- 464
		drawBlossomDot( -- 465
			uiInkDraw, -- 465
			uiArt, -- 465
			"chap_title_dot", -- 465
			infoX + lw + 16, -- 465
			titleY - 2, -- 465
			11, -- 465
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 465
			0.9, -- 465
			4 -- 465
		) -- 465
		texts:put( -- 466
			"banner", -- 466
			rightPart, -- 466
			infoX + lw + 32, -- 466
			titleY, -- 466
			toColor(PALETTE.textBright), -- 466
			0, -- 466
			0.5, -- 466
			"Left", -- 466
			2, -- 466
			1, -- 466
			0.1 -- 466
		) -- 466
	else -- 466
		texts:put( -- 468
			"banner", -- 468
			theme.titleZh, -- 468
			infoX, -- 468
			titleY, -- 468
			toColor(PALETTE.textBright), -- 468
			0, -- 468
			0.5, -- 468
			"Left", -- 468
			2.4, -- 468
			1, -- 468
			0.1 -- 468
		) -- 468
	end -- 468
	drawHairline( -- 471
		uiInkDraw, -- 471
		uiArt, -- 471
		"chap_info_line", -- 471
		infoX + 185, -- 471
		titleY - 36, -- 471
		370, -- 471
		PALETTE.silkDim, -- 471
		0.58, -- 471
		false, -- 471
		2 -- 471
	) -- 471
	texts:put( -- 474
		"sm", -- 474
		theme.introWhisper, -- 474
		infoX, -- 474
		titleY - 72, -- 474
		toColor(PALETTE.textMid), -- 474
		0, -- 474
		0.5, -- 474
		"Left", -- 474
		0.8, -- 474
		0.94, -- 474
		0.08 -- 474
	) -- 474
	local goX = infoX -- 477
	local goY = winY + 26 -- 478
	local goW = 220 -- 479
	local goH = 42 -- 480
	local goBox = Rect(goX, goY, goW, goH) -- 481
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 482
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 483
	drawSilkRibbon( -- 484
		uiDraw, -- 484
		uiArt, -- 484
		"chap_go_rib", -- 484
		goX + 106, -- 484
		goY + 21, -- 484
		250, -- 484
		40, -- 484
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 484
		(goHover and 0.68 or 0.46) * breathe, -- 484
		0 -- 484
	) -- 484
	drawHairline( -- 485
		uiInkDraw, -- 485
		uiArt, -- 485
		"chap_go_line", -- 485
		goX + 94, -- 485
		goY + 3, -- 485
		196, -- 485
		PALETTE.silkLine, -- 485
		goHover and 0.68 or 0.4, -- 485
		false, -- 485
		2 -- 485
	) -- 485
	drawBlossomDot( -- 486
		uiInkDraw, -- 486
		uiArt, -- 486
		"chap_go_dot", -- 486
		goX + 14, -- 486
		goY + 21, -- 486
		14, -- 486
		PALETTE.rouge, -- 486
		0.96, -- 486
		4 -- 486
	) -- 486
	texts:put( -- 487
		"md", -- 487
		"入此卷章", -- 487
		goX + 34, -- 487
		goY + 21, -- 487
		toColor(PALETTE.textBright), -- 487
		0, -- 487
		0.5, -- 487
		"Left", -- 487
		3.8, -- 487
		1, -- 487
		0.1 -- 487
	) -- 487
	texts:put( -- 488
		"xs", -- 488
		"Enter", -- 488
		goX + 156, -- 488
		goY + 21, -- 488
		toColor(PALETTE.textDim), -- 488
		0, -- 488
		0.5, -- 488
		"Left", -- 488
		1, -- 488
		0.82, -- 488
		0.08 -- 488
	) -- 488
	drawSilkVeil( -- 491
		uiDraw, -- 491
		uiArt, -- 491
		"chap_track_veil", -- 491
		w * 0.5, -- 491
		trackY + 6, -- 491
		w - marginX * 1.1, -- 491
		126, -- 491
		PALETTE.inkWash, -- 491
		0.72, -- 491
		-2 -- 491
	) -- 491
	drawMistCurve( -- 492
		uiArt, -- 492
		"chap_track_mist", -- 492
		w * 0.5, -- 492
		trackY, -- 492
		trackX1 - trackX0 + 160, -- 492
		74, -- 492
		PALETTE.inkMist, -- 492
		0.62, -- 492
		-1 -- 492
	) -- 492
	uiInkDraw:drawSegment( -- 493
		Vec2(trackX0, trackY), -- 493
		Vec2(trackX1, trackY), -- 493
		0.9, -- 493
		toColor(PALETTE.silkDim, 145) -- 493
	) -- 493
	local midDivX = trackX0 + stepX * 3.5 -- 496
	uiInkDraw:drawSegment( -- 497
		Vec2(midDivX, trackY - 12), -- 497
		Vec2(midDivX, trackY + 12), -- 497
		0.8, -- 497
		toColor(PALETTE.silkDim, 120) -- 497
	) -- 497
	texts:put( -- 498
		"xs", -- 498
		"上卷 · 孤城护童", -- 498
		trackX0 + stepX * 1.5, -- 498
		trackY + 52, -- 498
		toColor(PALETTE.cyan), -- 498
		0.5, -- 498
		0.5, -- 498
		"Center", -- 498
		2.2, -- 498
		0.88, -- 498
		0.08 -- 498
	) -- 498
	texts:put( -- 499
		"xs", -- 499
		"下卷 · 独赴北塔", -- 499
		trackX0 + stepX * 5.5, -- 499
		trackY + 52, -- 499
		toColor(PALETTE.amber), -- 499
		0.5, -- 499
		0.5, -- 499
		"Center", -- 499
		2.2, -- 499
		0.88, -- 499
		0.08 -- 499
	) -- 499
	local i = 0 -- 501
	do -- 501
		i = 0 -- 502
		while i < #ROOMS do -- 502
			local sx = trackX0 + i * stepX -- 503
			local rt = themeOf(ROOMS[i + 1].key) -- 504
			local active = self.chapterSelected == i -- 505
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 506
			if active then -- 506
				fillRadialGlow( -- 509
					uiGlow, -- 509
					sx, -- 509
					trackY, -- 509
					26, -- 509
					26, -- 509
					toColor(PALETTE.rouge, 36 * breathe), -- 509
					Color(182, 58, 56, 0), -- 509
					12 -- 509
				) -- 509
				uiArt:tryPlace( -- 510
					"ink_enso_fine", -- 510
					"chap_st_ring_" .. tostring(i), -- 510
					sx, -- 510
					trackY, -- 510
					32, -- 510
					32, -- 510
					{ -- 510
						color = toColor(PALETTE.silkLine), -- 511
						opacity = 0.78, -- 511
						angle = self.time * 18, -- 511
						layer = 3 -- 511
					} -- 511
				) -- 511
				drawBlossomDot( -- 513
					uiInkDraw, -- 513
					uiArt, -- 513
					"chap_st_dot_" .. tostring(i), -- 513
					sx, -- 513
					trackY, -- 513
					17, -- 513
					PALETTE.rouge, -- 513
					0.98, -- 513
					4 -- 513
				) -- 513
			else -- 513
				uiArt:tryPlace( -- 515
					"ink_enso_fine", -- 515
					"chap_st_ring_" .. tostring(i), -- 515
					sx, -- 515
					trackY, -- 515
					16, -- 515
					16, -- 515
					{ -- 515
						color = toColor(nodeCol), -- 516
						opacity = 0.62, -- 516
						layer = 3 -- 516
					} -- 516
				) -- 516
				drawBlossomDot( -- 518
					uiInkDraw, -- 518
					uiArt, -- 518
					"chap_st_dot_" .. tostring(i), -- 518
					sx, -- 518
					trackY, -- 518
					7, -- 518
					PALETTE.silkLine, -- 518
					0.72, -- 518
					4 -- 518
				) -- 518
			end -- 518
			texts:put( -- 521
				"xs", -- 521
				rt.numeralZh, -- 521
				sx, -- 521
				trackY + 25, -- 521
				toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 521
				0.5, -- 521
				0.5, -- 521
				"Center", -- 521
				0, -- 521
				active and 1 or 0.88, -- 521
				0.08 -- 521
			) -- 521
			texts:put( -- 522
				"xs", -- 522
				rt.shortNameZh, -- 522
				sx, -- 522
				trackY - 26, -- 522
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 522
				0.5, -- 522
				0.5, -- 522
				"Center", -- 522
				1, -- 522
				active and 1 or 0.84, -- 522
				0.08 -- 522
			) -- 522
			i = i + 1 -- 502
		end -- 502
	end -- 502
	local backX = marginX -- 526
	local backY = 40 -- 527
	local backBox = Rect(backX, backY, 190, 34) -- 528
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 529
	drawSilkKeycap( -- 530
		uiInkDraw, -- 530
		texts, -- 530
		backX, -- 530
		backY + 5, -- 530
		44, -- 530
		24, -- 530
		"ESC", -- 530
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 530
		0.92, -- 530
		backHover -- 530
	) -- 530
	texts:put( -- 531
		"sm", -- 531
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 531
		backX + 56, -- 531
		backY + 17, -- 531
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 531
		0, -- 531
		0.5, -- 531
		"Left", -- 531
		1.8, -- 531
		0.9, -- 531
		0.08 -- 531
	) -- 531
	texts:put( -- 532
		"xs", -- 532
		"← / → 沿驿道阅览   ·   Enter 或点选入章", -- 532
		w - marginX, -- 532
		backY + 17, -- 532
		toColor(PALETTE.textDim), -- 532
		1, -- 532
		0.5, -- 532
		"Right", -- 532
		1.2, -- 532
		0.75, -- 532
		0.08 -- 532
	) -- 532
	if frame.click and backHover then -- 532
		return back -- 535
	end -- 535
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 535
		return {type = "jump", roomIndex = self.chapterSelected} -- 538
	end -- 538
	return {type = "none"} -- 540
end -- 371
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 546
	if backLabel == nil then -- 546
		backLabel = "返回标题" -- 555
	end -- 555
	local marginX = 96 -- 557
	local backX = marginX -- 558
	local backY = 40 -- 559
	local backBox = Rect(backX, backY, 230, 34) -- 560
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 561
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 561
		return {type = "backTitle"} -- 563
	end -- 563
	uiDraw:drawRect( -- 565
		Rect(0, 0, w, h), -- 565
		Color(10, 12, 19, 204) -- 565
	) -- 565
	texts:put( -- 567
		"banner", -- 567
		"执器要诀", -- 567
		marginX, -- 567
		h - 66, -- 567
		toColor(PALETTE.textBright), -- 567
		0, -- 567
		0.5, -- 567
		"Left", -- 567
		4.5, -- 567
		0.96, -- 567
		0.1 -- 567
	) -- 567
	texts:put( -- 568
		"xs", -- 568
		"键鼠操作说明", -- 568
		marginX + 196, -- 568
		h - 70, -- 568
		toColor(PALETTE.textDim), -- 568
		0, -- 568
		0.5, -- 568
		"Left", -- 568
		2, -- 568
		0.85, -- 568
		0.08 -- 568
	) -- 568
	drawHairline( -- 569
		uiInkDraw, -- 569
		uiArt, -- 569
		"ctrl_top_line", -- 569
		w * 0.5, -- 569
		h - 100, -- 569
		w - marginX * 2, -- 569
		PALETTE.silkDim, -- 569
		0.6, -- 569
		true, -- 569
		2 -- 569
	) -- 569
	local areaY = 114 -- 572
	local areaH = h - 244 -- 573
	drawFiligreeCorners( -- 574
		uiInkDraw, -- 574
		uiArt, -- 574
		"ctrl_outer", -- 574
		marginX, -- 574
		areaY, -- 574
		w - marginX * 2, -- 574
		areaH, -- 574
		PALETTE.silkDim, -- 574
		0.52, -- 574
		34, -- 574
		false, -- 574
		2 -- 574
	) -- 574
	local midX = w * 0.5 -- 577
	uiArt:tryPlace( -- 578
		"ink_vstream", -- 578
		"ctrl_mid_stream", -- 578
		midX, -- 578
		areaY + areaH * 0.5, -- 578
		32, -- 578
		areaH - 18, -- 578
		{ -- 578
			color = toColor(PALETTE.silkDim), -- 579
			opacity = 0.52, -- 579
			layer = 1 -- 579
		} -- 579
	) -- 579
	drawBlossomDot( -- 581
		uiInkDraw, -- 581
		uiArt, -- 581
		"ctrl_mid_dot", -- 581
		midX, -- 581
		areaY + areaH * 0.5, -- 581
		11, -- 581
		PALETTE.silkLine, -- 581
		0.62, -- 581
		3 -- 581
	) -- 581
	local leftColX = marginX + 34 -- 584
	local colW = midX - leftColX - 42 -- 585
	local headY = areaY + areaH - 34 -- 586
	drawBlossomDot( -- 587
		uiInkDraw, -- 587
		uiArt, -- 587
		"ctrl_l_dot", -- 587
		leftColX + 8, -- 587
		headY, -- 587
		12, -- 587
		PALETTE.cyan, -- 587
		0.88, -- 587
		3 -- 587
	) -- 587
	texts:put( -- 588
		"md", -- 588
		"周戍 · 护送与交锋", -- 588
		leftColX + 26, -- 588
		headY, -- 588
		toColor(PALETTE.cyanCore), -- 588
		0, -- 588
		0.5, -- 588
		"Left", -- 588
		2.4, -- 588
		0.98, -- 588
		0.08 -- 588
	) -- 588
	drawHairline( -- 589
		uiInkDraw, -- 589
		uiArt, -- 589
		"ctrl_l_line", -- 589
		leftColX + colW * 0.5, -- 589
		headY - 24, -- 589
		colW, -- 589
		PALETTE.cyanDim, -- 589
		0.58, -- 589
		false, -- 589
		2 -- 589
	) -- 589
	local sRows = { -- 591
		{"WASD / 方向键", "左右、前后自由移动"}, -- 592
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 593
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 594
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 595
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 596
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 597
	} -- 597
	local i = 0 -- 599
	do -- 599
		i = 0 -- 600
		while i < #sRows do -- 600
			local ry = headY - 66 - i * 52 -- 601
			drawSilkKeycap( -- 602
				uiInkDraw, -- 602
				texts, -- 602
				leftColX + 2, -- 602
				ry - 13, -- 602
				132, -- 602
				26, -- 602
				sRows[i + 1][1], -- 602
				PALETTE.cyan, -- 602
				0.92, -- 602
				false -- 602
			) -- 602
			texts:put( -- 603
				"sm", -- 603
				sRows[i + 1][2], -- 603
				leftColX + 150, -- 603
				ry, -- 603
				toColor(PALETTE.textBright), -- 603
				0, -- 603
				0.5, -- 603
				"Left", -- 603
				0.8, -- 603
				0.92, -- 603
				0.08 -- 603
			) -- 603
			i = i + 1 -- 600
		end -- 600
	end -- 600
	local rightColX = midX + 44 -- 607
	drawBlossomDot( -- 608
		uiInkDraw, -- 608
		uiArt, -- 608
		"ctrl_r_dot", -- 608
		rightColX + 8, -- 608
		headY, -- 608
		12, -- 608
		PALETTE.amber, -- 608
		0.88, -- 608
		3 -- 608
	) -- 608
	texts:put( -- 609
		"md", -- 609
		"小满 · 潜行与寻路", -- 609
		rightColX + 26, -- 609
		headY, -- 609
		toColor(PALETTE.amberCore), -- 609
		0, -- 609
		0.5, -- 609
		"Left", -- 609
		2.4, -- 609
		0.98, -- 609
		0.08 -- 609
	) -- 609
	drawHairline( -- 610
		uiInkDraw, -- 610
		uiArt, -- 610
		"ctrl_r_line", -- 610
		rightColX + colW * 0.5, -- 610
		headY - 24, -- 610
		colW, -- 610
		PALETTE.amberDim, -- 610
		0.58, -- 610
		false, -- 610
		2 -- 610
	) -- 610
	local cRows = { -- 612
		{"A / D · ← / →", "左右潜行"}, -- 613
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 614
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 615
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 616
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 617
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 618
	} -- 618
	do -- 618
		i = 0 -- 620
		while i < #cRows do -- 620
			local ry = headY - 66 - i * 52 -- 621
			drawSilkKeycap( -- 622
				uiInkDraw, -- 622
				texts, -- 622
				rightColX + 2, -- 622
				ry - 13, -- 622
				132, -- 622
				26, -- 622
				cRows[i + 1][1], -- 622
				PALETTE.amber, -- 622
				0.92, -- 622
				false -- 622
			) -- 622
			texts:put( -- 623
				"sm", -- 623
				cRows[i + 1][2], -- 623
				rightColX + 150, -- 623
				ry, -- 623
				toColor(PALETTE.textBright), -- 623
				0, -- 623
				0.5, -- 623
				"Left", -- 623
				0.8, -- 623
				0.92, -- 623
				0.08 -- 623
			) -- 623
			i = i + 1 -- 620
		end -- 620
	end -- 620
	drawSilkKeycap( -- 627
		uiInkDraw, -- 627
		texts, -- 627
		backX, -- 627
		backY + 5, -- 627
		110, -- 627
		24, -- 627
		"ESC / ENTER", -- 627
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 627
		0.92, -- 627
		backHover -- 627
	) -- 627
	texts:put( -- 628
		"sm", -- 628
		backLabel, -- 628
		backX + 122, -- 628
		backY + 17, -- 628
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 628
		0, -- 628
		0.5, -- 628
		"Left", -- 628
		1.8, -- 628
		0.92, -- 628
		0.08 -- 628
	) -- 628
	return {type = "none"} -- 630
end -- 546
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist) -- 637
	if assistHintsEnabled == nil then -- 637
		assistHintsEnabled = false -- 648
	end -- 648
	self.time = self.time + dt -- 651
	local frame = self:readFrame(input, uiScale) -- 652
	if self.pauseShowControls then -- 652
		local ctrlAct = self:drawControls( -- 656
			frame, -- 656
			uiDraw, -- 656
			uiInkDraw, -- 656
			uiArt, -- 656
			uiGlow, -- 656
			texts, -- 656
			w, -- 656
			h, -- 656
			"返回暂停" -- 656
		) -- 656
		if ctrlAct.type == "backTitle" then -- 656
			self.pauseShowControls = false -- 658
			self:resetInput() -- 659
		end -- 659
		return {type = "none"} -- 661
	end -- 661
	if frame.back then -- 661
		self.pauseShowControls = false -- 665
		return {type = "resume"} -- 666
	end -- 666
	uiDraw:drawRect( -- 670
		Rect(0, 0, w, h), -- 670
		Color(8, 10, 16, 102) -- 670
	) -- 670
	fillHGradRect( -- 671
		uiDraw, -- 671
		0, -- 671
		0, -- 671
		w * 0.27, -- 671
		h, -- 671
		Color(9, 11, 18, 232), -- 671
		Color(10, 13, 21, 198) -- 671
	) -- 671
	fillHGradRect( -- 672
		uiDraw, -- 672
		w * 0.27, -- 672
		0, -- 672
		w * 0.21, -- 672
		h, -- 672
		Color(10, 13, 21, 198), -- 672
		Color(10, 13, 21, 0) -- 672
	) -- 672
	local menuX = 110 -- 675
	uiArt:tryPlace( -- 676
		"ink_vstream", -- 676
		"pause_vstream", -- 676
		menuX - 32, -- 676
		h * 0.5, -- 676
		34, -- 676
		h * 0.78, -- 676
		{ -- 676
			color = toColor(PALETTE.silkDim), -- 677
			opacity = 0.48, -- 677
			layer = 1 -- 677
		} -- 677
	) -- 677
	drawMistCurve( -- 679
		uiArt, -- 679
		"pause_mist", -- 679
		menuX + 118, -- 679
		h - 154, -- 679
		290, -- 679
		72, -- 679
		PALETTE.jadeMist, -- 679
		0.2, -- 679
		-1 -- 679
	) -- 679
	texts:put( -- 682
		"banner", -- 682
		"暂歇", -- 682
		menuX + 16, -- 682
		h - 146, -- 682
		toColor(PALETTE.textBright), -- 682
		0, -- 682
		0.5, -- 682
		"Left", -- 682
		10, -- 682
		0.98, -- 682
		0.1 -- 682
	) -- 682
	texts:put( -- 683
		"xs", -- 683
		"月夜暂驻 · 卷页留痕", -- 683
		menuX + 18, -- 683
		h - 184, -- 683
		toColor(PALETTE.textDim), -- 683
		0, -- 683
		0.5, -- 683
		"Left", -- 683
		2, -- 683
		0.8, -- 683
		0.08 -- 683
	) -- 683
	drawHairline( -- 684
		uiInkDraw, -- 684
		uiArt, -- 684
		"pause_div", -- 684
		menuX + 124, -- 684
		h - 210, -- 684
		240, -- 684
		PALETTE.silkDim, -- 684
		0.58, -- 684
		true, -- 684
		2 -- 684
	) -- 684
	local boxes = {} -- 686
	local i = 0 -- 687
	do -- 687
		i = 0 -- 688
		while i < #PAUSE_ITEMS do -- 688
			boxes[#boxes + 1] = Rect(menuX - 10, h - 270 - i * 52, 270, 42) -- 689
			i = i + 1 -- 688
		end -- 688
	end -- 688
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 691
	do -- 691
		i = 0 -- 693
		while i < #PAUSE_ITEMS do -- 693
			local iy = boxes[i + 1].y -- 694
			local active = self.pauseSelected == i -- 695
			local cy = iy + 21 -- 696
			local shiftX = active and 10 or 0 -- 697
			local item = PAUSE_ITEMS[i + 1] -- 698
			local label = item.id == "assist" and (assistHintsEnabled and "按键辅助：开" or "按键辅助：关") or item.zh -- 699
			if active then -- 699
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 704
				drawSilkRibbon( -- 705
					uiDraw, -- 705
					uiArt, -- 705
					"pause_rib_" .. tostring(i), -- 705
					menuX + 116, -- 705
					cy, -- 705
					276, -- 705
					38, -- 705
					PALETTE.rougeSoft, -- 705
					0.54 * breathe, -- 705
					0 -- 705
				) -- 705
				drawHairline( -- 706
					uiInkDraw, -- 706
					uiArt, -- 706
					"pause_line_" .. tostring(i), -- 706
					menuX + 106, -- 706
					iy + 3, -- 706
					210, -- 706
					PALETTE.silkLine, -- 706
					0.42 * breathe, -- 706
					false, -- 706
					2 -- 706
				) -- 706
				drawBlossomDot( -- 707
					uiInkDraw, -- 707
					uiArt, -- 707
					"pause_dot_" .. tostring(i), -- 707
					menuX + 12, -- 707
					cy, -- 707
					15, -- 707
					PALETTE.rouge, -- 707
					0.96, -- 707
					4 -- 707
				) -- 707
				fillRadialGlow( -- 708
					uiGlow, -- 708
					menuX + 12, -- 708
					cy, -- 708
					22, -- 708
					16, -- 708
					toColor(PALETTE.rouge, 26 * breathe), -- 708
					Color(182, 58, 56, 0), -- 708
					10 -- 708
				) -- 708
			else -- 708
				drawBlossomDot( -- 710
					uiInkDraw, -- 710
					uiArt, -- 710
					"pause_dot_" .. tostring(i), -- 710
					menuX + 12, -- 710
					cy, -- 710
					8, -- 710
					PALETTE.silkDim, -- 710
					0.4, -- 710
					3 -- 710
				) -- 710
			end -- 710
			texts:put( -- 713
				"md", -- 714
				label, -- 715
				menuX + 32 + shiftX, -- 716
				cy, -- 717
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 718
				0, -- 719
				0.5, -- 720
				"Left", -- 721
				active and 3.8 or 2.4, -- 722
				active and 1 or 0.88, -- 723
				0.1 -- 724
			) -- 724
			i = i + 1 -- 693
		end -- 693
	end -- 693
	texts:put( -- 728
		"xs", -- 728
		"Esc 续行   ·   Enter 或点击确认", -- 728
		menuX + 12, -- 728
		56, -- 728
		toColor(PALETTE.textDim), -- 728
		0, -- 728
		0.5, -- 728
		"Left", -- 728
		1.2, -- 728
		0.86, -- 728
		0.08 -- 728
	) -- 728
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 730
	if hit >= 0 or frame.keys.confirm then -- 730
		local idx = hit >= 0 and hit or self.pauseSelected -- 732
		local id = PAUSE_ITEMS[idx + 1].id -- 733
		if id == "controls" then -- 733
			self.pauseShowControls = true -- 735
			self:resetInput() -- 736
			return {type = "none"} -- 737
		end -- 737
		if id == "assist" then -- 737
			if onToggleAssist ~= nil then -- 737
				onToggleAssist() -- 741
			end -- 741
			self:resetInput() -- 743
			return {type = "none"} -- 744
		end -- 744
		self.pauseShowControls = false -- 746
		if id == "resume" then -- 746
			return {type = "resume"} -- 748
		end -- 748
		if id == "retry" then -- 748
			return {type = "retry"} -- 751
		end -- 751
		if id == "chapters" then -- 751
			return {type = "openChapters"} -- 754
		end -- 754
		return {type = "toTitle"} -- 756
	end -- 756
	return {type = "none"} -- 758
end -- 637
return ____exports -- 637