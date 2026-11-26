-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
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
local CHAPTERS = __TS__ArrayFilter( -- 50
	__TS__ArrayMap( -- 50
		ROOMS, -- 50
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 50
	), -- 50
	function(____, chapter) return chapter.room.key ~= "museum" end -- 51
) -- 51
local PAUSE_ITEMS = { -- 53
	{id = "resume", zh = "继续游戏"}, -- 54
	{id = "retry", zh = "重试检查点"}, -- 55
	{id = "controls", zh = "操作说明"}, -- 56
	{id = "assist", zh = "按键辅助：关"}, -- 57
	{id = "chapters", zh = "选择章节"}, -- 58
	{id = "title", zh = "返回标题"} -- 59
} -- 59
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 62
local EPIGRAPH_RIGHT = { -- 64
	"城", -- 64
	"破", -- 64
	"那", -- 64
	"天", -- 64
	"", -- 64
	"他", -- 64
	"留", -- 64
	"下", -- 64
	"断", -- 64
	"后" -- 64
} -- 64
local EPIGRAPH_LEFT = { -- 65
	"她", -- 65
	"独", -- 65
	"自", -- 65
	"走", -- 65
	"向", -- 65
	"北", -- 65
	"塔" -- 65
} -- 65
local function pressedKeys() -- 84
	return { -- 85
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 86
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 87
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 88
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 89
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 90
	} -- 90
end -- 84
local function hitIndex(boxes, pointer, inside) -- 94
	if not inside then -- 94
		return -1 -- 96
	end -- 96
	return __TS__ArrayFindIndex( -- 98
		boxes, -- 98
		function(____, box) return box:containsPoint(pointer) end -- 98
	) -- 98
end -- 94
____exports.MenuRenderer = __TS__Class() -- 101
local MenuRenderer = ____exports.MenuRenderer -- 101
MenuRenderer.name = "MenuRenderer" -- 101
function MenuRenderer.prototype.____constructor(self) -- 101
	self.selected = 0 -- 102
	self.chapterSelected = 0 -- 103
	self.pauseSelected = 0 -- 104
	self.chaptersFromPause = false -- 105
	self.pauseShowControls = false -- 107
	self.previousKeys = {} -- 108
	self.queuedKeys = {} -- 109
	self.queuedBack = false -- 110
	self.time = 0 -- 111
end -- 101
function MenuRenderer.prototype.isShowingPauseControls(self) -- 113
	return self.pauseShowControls -- 114
end -- 113
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 117
	self.chaptersFromPause = roomIndex ~= nil -- 118
	self.chapterSelected = math.max( -- 119
		0, -- 119
		__TS__ArrayFindIndex( -- 119
			CHAPTERS, -- 119
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 119
		) -- 119
	) -- 119
	self.pauseShowControls = false -- 120
	self:resetInput() -- 121
end -- 117
function MenuRenderer.prototype.openPause(self) -- 124
	self.pauseSelected = 0 -- 125
	self.pauseShowControls = false -- 126
	self:resetInput() -- 127
end -- 124
function MenuRenderer.prototype.resetInput(self) -- 131
	self.previousKeys = pressedKeys() -- 132
	self.queuedKeys = {} -- 133
	self.queuedBack = false -- 134
end -- 131
function MenuRenderer.prototype.onKeyEvent(self, key) -- 138
	if key == "Up" or key == "W" then -- 138
		self.queuedKeys.up = true -- 140
	elseif key == "Down" or key == "S" then -- 140
		self.queuedKeys.down = true -- 142
	elseif key == "Left" or key == "A" then -- 142
		self.queuedKeys.left = true -- 144
	elseif key == "Right" or key == "D" then -- 144
		self.queuedKeys.right = true -- 146
	elseif key == "Return" or key == "Space" then -- 146
		self.queuedKeys.confirm = true -- 148
	elseif key == "Escape" then -- 148
		self.queuedBack = true -- 150
	end -- 150
end -- 138
function MenuRenderer.prototype.readFrame(self, input, scale) -- 154
	local held = pressedKeys() -- 155
	local prev = self.previousKeys -- 156
	local queued = self.queuedKeys -- 157
	local frame = { -- 158
		keys = { -- 159
			up = queued.up == true or held.up and not prev.up, -- 160
			down = queued.down == true or held.down and not prev.down, -- 161
			left = queued.left == true or held.left and not prev.left, -- 162
			right = queued.right == true or held.right and not prev.right, -- 163
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 164
		}, -- 164
		back = self.queuedBack or input.pause.pressed, -- 166
		pointer = Vec2(input.mx / scale, input.my / scale), -- 167
		inside = input.inside, -- 168
		click = input.inside and input.fire.pressed, -- 169
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 170
	} -- 170
	self.previousKeys = held -- 172
	self.queuedKeys = {} -- 173
	self.queuedBack = false -- 174
	return frame -- 175
end -- 154
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 178
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 179
	if frame.click and hit >= 0 then -- 179
		return hit -- 181
	end -- 181
	if frame.keys.up then -- 181
		return (selected + #boxes - 1) % #boxes -- 184
	end -- 184
	if frame.keys.down then -- 184
		return (selected + 1) % #boxes -- 187
	end -- 187
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 189
end -- 178
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 192
	self.time = self.time + dt -- 209
	local artW = math.max(w, h * 16 / 9) -- 210
	local artH = artW * 9 / 16 -- 211
	if not backdropArt:tryPlace( -- 211
		"title_backdrop", -- 212
		"menu_landscape", -- 212
		w * 0.5, -- 212
		(h - artH) * 0.5, -- 212
		artW, -- 212
		artH -- 212
	) then -- 212
		stage:drawMenuBackdrop( -- 213
			bgDraw, -- 213
			bgGlow, -- 213
			w, -- 213
			h, -- 213
			self.time -- 213
		) -- 213
	end -- 213
	local frame = self:readFrame(input, uiScale) -- 216
	w = w / uiScale -- 217
	h = h / uiScale -- 218
	if screen == "title" then -- 218
		return self:drawTitle( -- 221
			frame, -- 221
			uiDraw, -- 221
			uiInkDraw, -- 221
			uiArt, -- 221
			uiGlow, -- 221
			texts, -- 221
			w, -- 221
			h -- 221
		) -- 221
	end -- 221
	if screen == "chapters" then -- 221
		return self:drawChapters( -- 224
			frame, -- 224
			uiDraw, -- 224
			uiInkDraw, -- 224
			uiArt, -- 224
			uiGlow, -- 224
			texts, -- 224
			w, -- 224
			h -- 224
		) -- 224
	end -- 224
	return self:drawControls( -- 226
		frame, -- 226
		uiDraw, -- 226
		uiInkDraw, -- 226
		uiArt, -- 226
		uiGlow, -- 226
		texts, -- 226
		w, -- 226
		h -- 226
	) -- 226
end -- 192
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 229
	fillHGradRect( -- 240
		uiDraw, -- 240
		0, -- 240
		0, -- 240
		w * 0.22, -- 240
		h, -- 240
		Color(9, 11, 18, 192), -- 240
		Color(9, 11, 18, 116) -- 240
	) -- 240
	fillHGradRect( -- 241
		uiDraw, -- 241
		w * 0.22, -- 241
		0, -- 241
		w * 0.28, -- 241
		h, -- 241
		Color(9, 11, 18, 116), -- 241
		Color(9, 11, 18, 0) -- 241
	) -- 241
	fillVGradRect( -- 242
		uiDraw, -- 242
		0, -- 242
		0, -- 242
		w, -- 242
		78, -- 242
		Color(8, 10, 16, 138), -- 242
		Color(8, 10, 16, 0) -- 242
	) -- 242
	local titleX = 148 -- 245
	local topY = h - 104 -- 246
	local charStep = 66 -- 247
	local sway = math.sin(self.time * 0.7) * 5 -- 248
	drawMistCurve( -- 249
		uiArt, -- 249
		"title_mist_wisp", -- 249
		titleX + 86 + sway, -- 249
		topY - 122, -- 249
		340, -- 249
		82, -- 249
		PALETTE.jadeMist, -- 249
		0.2, -- 249
		-1 -- 249
	) -- 249
	uiArt:tryPlace( -- 250
		"ink_petal_mist", -- 250
		"title_petals", -- 250
		titleX + 12, -- 250
		topY - 102, -- 250
		230, -- 250
		210, -- 250
		{ -- 250
			color = toColor(PALETTE.inkMist), -- 251
			opacity = 0.4, -- 251
			layer = -1 -- 251
		} -- 251
	) -- 251
	uiArt:tryPlace( -- 253
		"ink_vstream", -- 253
		"title_vstream", -- 253
		titleX - 48, -- 253
		topY - 100, -- 253
		34, -- 253
		290, -- 253
		{ -- 253
			color = toColor(PALETTE.silkDim), -- 254
			opacity = 0.48, -- 254
			layer = 1 -- 254
		} -- 254
	) -- 254
	local c = 0 -- 258
	do -- 258
		c = 0 -- 259
		while c < #VERTICAL_TITLE do -- 259
			texts:put( -- 260
				"title", -- 261
				VERTICAL_TITLE[c + 1], -- 262
				titleX, -- 263
				topY - c * charStep, -- 264
				toColor(PALETTE.textBright), -- 265
				0.5, -- 266
				0.5, -- 267
				"Center", -- 268
				0, -- 269
				0.98, -- 270
				0.1, -- 271
				Color(8, 10, 16, 210) -- 272
			) -- 272
			c = c + 1 -- 259
		end -- 259
	end -- 259
	drawLoneSeal( -- 277
		uiInkDraw, -- 278
		uiArt, -- 279
		texts, -- 280
		"title_lone_seal", -- 281
		titleX + 46, -- 282
		topY - 3 * charStep + 8, -- 283
		26, -- 284
		52, -- 285
		"守", -- 286
		"望", -- 287
		PALETTE.sealRed, -- 288
		PALETTE.sealText, -- 289
		0.94, -- 290
		4 -- 291
	) -- 291
	local colRightX = titleX + 132 -- 295
	local colLeftX = titleX + 102 -- 296
	local poemStep = 22 -- 297
	local p = 0 -- 298
	do -- 298
		p = 0 -- 299
		while p < #EPIGRAPH_RIGHT do -- 299
			local ch = EPIGRAPH_RIGHT[p + 1] -- 300
			if ch ~= "" then -- 300
				texts:put( -- 302
					"xs", -- 302
					ch, -- 302
					colRightX, -- 302
					topY - 22 - p * poemStep, -- 302
					toColor(PALETTE.textMid), -- 302
					0.5, -- 302
					0.5, -- 302
					"Center", -- 302
					0, -- 302
					0.86, -- 302
					0.08 -- 302
				) -- 302
			end -- 302
			p = p + 1 -- 299
		end -- 299
	end -- 299
	do -- 299
		p = 0 -- 305
		while p < #EPIGRAPH_LEFT do -- 305
			texts:put( -- 306
				"xs", -- 306
				EPIGRAPH_LEFT[p + 1], -- 306
				colLeftX, -- 306
				topY - 68 - p * poemStep, -- 306
				toColor(PALETTE.amberCore), -- 306
				0.5, -- 306
				0.5, -- 306
				"Center", -- 306
				0, -- 306
				0.9, -- 306
				0.08 -- 306
			) -- 306
			p = p + 1 -- 305
		end -- 305
	end -- 305
	local menuX = 112 -- 310
	local btnW = 280 -- 311
	local btnH = 44 -- 312
	local gap = 12 -- 313
	local startY = 252 -- 314
	local boxes = {} -- 315
	local i = 0 -- 316
	do -- 316
		i = 0 -- 317
		while i < #TITLE_ITEMS do -- 317
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 318
			i = i + 1 -- 317
		end -- 317
	end -- 317
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 320
	do -- 320
		i = 0 -- 322
		while i < #TITLE_ITEMS do -- 322
			local by = boxes[i + 1].y -- 323
			local active = self.selected == i -- 324
			local cy = by + btnH * 0.5 -- 325
			local shiftX = active and 10 or 0 -- 326
			if active then -- 326
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 329
				drawSilkRibbon( -- 330
					uiDraw, -- 330
					uiArt, -- 330
					"title_rib_red_" .. tostring(i), -- 330
					menuX + 124, -- 330
					cy, -- 330
					290, -- 330
					40, -- 330
					PALETTE.rougeSoft, -- 330
					0.52 * breathe, -- 330
					0 -- 330
				) -- 330
				drawHairline( -- 331
					uiInkDraw, -- 331
					uiArt, -- 331
					"title_rib_line_" .. tostring(i), -- 331
					menuX + 114, -- 331
					by + 4, -- 331
					230, -- 331
					PALETTE.silkLine, -- 331
					0.42 * breathe, -- 331
					false, -- 331
					2 -- 331
				) -- 331
				drawBlossomDot( -- 332
					uiInkDraw, -- 332
					uiArt, -- 332
					"title_dot_" .. tostring(i), -- 332
					menuX + 14, -- 332
					cy, -- 332
					16, -- 332
					PALETTE.rouge, -- 332
					0.96, -- 332
					4 -- 332
				) -- 332
				fillRadialGlow( -- 333
					uiGlow, -- 333
					menuX + 14, -- 333
					cy, -- 333
					22, -- 333
					16, -- 333
					toColor(PALETTE.rouge, 28 * breathe), -- 333
					Color(182, 58, 56, 0), -- 333
					10 -- 333
				) -- 333
			else -- 333
				drawBlossomDot( -- 335
					uiInkDraw, -- 335
					uiArt, -- 335
					"title_dot_" .. tostring(i), -- 335
					menuX + 14, -- 335
					cy, -- 335
					8, -- 335
					PALETTE.silkDim, -- 335
					0.4, -- 335
					3 -- 335
				) -- 335
			end -- 335
			texts:put( -- 338
				"md", -- 339
				TITLE_ITEMS[i + 1].zh, -- 340
				menuX + 34 + shiftX, -- 341
				cy, -- 342
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 343
				0, -- 344
				0.5, -- 345
				"Left", -- 346
				active and 4.4 or 2.8, -- 347
				active and 1 or 0.88, -- 348
				0.1 -- 349
			) -- 349
			i = i + 1 -- 322
		end -- 322
	end -- 322
	texts:put( -- 353
		"xs", -- 353
		"上下择项   ·   回车或点选启程", -- 353
		menuX + 12, -- 353
		42, -- 353
		toColor(PALETTE.textDim), -- 353
		0, -- 353
		0.5, -- 353
		"Left", -- 353
		1.4, -- 353
		0.88, -- 353
		0.08 -- 353
	) -- 353
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 355
	if hit >= 0 or frame.keys.confirm then -- 355
		local idx = hit >= 0 and hit or self.selected -- 357
		local id = TITLE_ITEMS[idx + 1].id -- 358
		if id == "trial" then -- 358
			return {type = "trial"} -- 359
		end -- 359
		if id == "start" then -- 359
			return {type = "start"} -- 361
		end -- 361
		if id == "chapters" then -- 361
			return {type = "openChapters"} -- 364
		end -- 364
		return {type = "openControls"} -- 366
	end -- 366
	return {type = "none"} -- 368
end -- 229
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 375
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 385
	if frame.back then -- 385
		return back -- 387
	end -- 387
	local marginX = 96 -- 390
	local splitTrack = #CHAPTERS > 8 -- 391
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 392
	local trackY = splitTrack and 195 or 148 -- 393
	local rowGap = 84 -- 394
	local trackX0 = marginX + 34 -- 395
	local trackX1 = w - marginX - 34 -- 396
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 397
	local stationBoxes = {} -- 399
	local s = 0 -- 400
	do -- 400
		s = 0 -- 401
		while s < #CHAPTERS do -- 401
			local sx = trackX0 + s % perRow * stepX -- 402
			local sy = trackY - math.floor(s / perRow) * rowGap -- 403
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74) -- 404
			s = s + 1 -- 401
		end -- 401
	end -- 401
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 407
	local keys = frame.keys -- 408
	if frame.click and hitStation >= 0 then -- 408
		self.chapterSelected = hitStation -- 410
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 410
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 412
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 413
	elseif keys.down and self.chapterSelected < perRow then -- 413
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 415
	elseif keys.up and self.chapterSelected >= perRow then -- 415
		self.chapterSelected = self.chapterSelected - perRow -- 417
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 417
		self.chapterSelected = hitStation -- 419
	end -- 419
	uiDraw:drawRect( -- 423
		Rect(0, 0, w, h), -- 423
		Color(10, 12, 19, 198) -- 423
	) -- 423
	texts:put( -- 426
		"banner", -- 426
		"选择章节", -- 426
		marginX, -- 426
		h - 66, -- 426
		toColor(PALETTE.textBright), -- 426
		0, -- 426
		0.5, -- 426
		"Left", -- 426
		4.5, -- 426
		0.96, -- 426
		0.1 -- 426
	) -- 426
	drawHairline( -- 427
		uiInkDraw, -- 427
		uiArt, -- 427
		"chap_top_line", -- 427
		w * 0.5, -- 427
		h - 100, -- 427
		w - marginX * 2, -- 427
		PALETTE.silkDim, -- 427
		0.6, -- 427
		true, -- 427
		2 -- 427
	) -- 427
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 430
	local theme = themeOf(activeRoom.key) -- 431
	local winX = marginX -- 432
	local winY = 266 -- 433
	local winW = 548 -- 434
	local winH = 300 -- 435
	local winBox = Rect(winX, winY, winW, winH) -- 436
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 437
	uiArt:tryPlace( -- 440
		"ink_frame_mask", -- 440
		"chap_win_shadow", -- 440
		winX + winW * 0.5, -- 440
		winY + winH * 0.5, -- 440
		winW + 40, -- 440
		winH + 34, -- 440
		{ -- 440
			color = toColor(PALETTE.inkVoid), -- 441
			opacity = 0.88, -- 441
			layer = -2 -- 441
		} -- 441
	) -- 441
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 443
	uiArt:tryPlace( -- 444
		bgSlot, -- 444
		"chap_win_art", -- 444
		winX + winW * 0.5, -- 444
		winY + 4, -- 444
		winW - 8, -- 444
		winH - 8, -- 444
		{opacity = 0.92, layer = -1} -- 444
	) -- 444
	fillVGradRect( -- 448
		uiInkDraw, -- 448
		winX, -- 448
		winY, -- 448
		winW, -- 448
		56, -- 448
		Color(10, 12, 19, 200), -- 448
		Color(10, 12, 19, 0) -- 448
	) -- 448
	fillVGradRect( -- 449
		uiInkDraw, -- 449
		winX, -- 449
		winY + winH - 36, -- 449
		winW, -- 449
		36, -- 449
		Color(10, 12, 19, 0), -- 449
		Color(10, 12, 19, 130) -- 449
	) -- 449
	fillHGradRect( -- 450
		uiInkDraw, -- 450
		winX, -- 450
		winY, -- 450
		34, -- 450
		winH, -- 450
		Color(10, 12, 19, 135), -- 450
		Color(10, 12, 19, 0) -- 450
	) -- 450
	fillHGradRect( -- 451
		uiInkDraw, -- 451
		winX + winW - 34, -- 451
		winY, -- 451
		34, -- 451
		winH, -- 451
		Color(10, 12, 19, 0), -- 451
		Color(10, 12, 19, 135) -- 451
	) -- 451
	drawFiligreeCorners( -- 453
		uiInkDraw, -- 453
		uiArt, -- 453
		"chap_win_frame", -- 453
		winX, -- 453
		winY, -- 453
		winW, -- 453
		winH, -- 453
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 453
		winHover and 0.92 or 0.72, -- 453
		34, -- 453
		true, -- 453
		3 -- 453
	) -- 453
	texts:put( -- 456
		"xs", -- 456
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 456
		winX + 20, -- 456
		winY + 22, -- 456
		toColor(PALETTE.textMid), -- 456
		0, -- 456
		0.5, -- 456
		"Left", -- 456
		1.8, -- 456
		0.9, -- 456
		0.08 -- 456
	) -- 456
	local infoX = winX + winW + 46 -- 459
	local infoCenterY = winY + winH * 0.5 -- 460
	drawMistCurve( -- 461
		uiArt, -- 461
		"chap_info_mist", -- 461
		infoX + 210, -- 461
		infoCenterY + 36, -- 461
		420, -- 461
		88, -- 461
		theme.accent, -- 461
		0.22, -- 461
		-1 -- 461
	) -- 461
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 464
	texts:put( -- 465
		"xs", -- 465
		theme.volumeTagZh, -- 465
		infoX, -- 465
		winY + winH - 44, -- 465
		toColor(volCol), -- 465
		0, -- 465
		0.5, -- 465
		"Left", -- 465
		2.8, -- 465
		0.92, -- 465
		0.08 -- 465
	) -- 465
	local sep = " · " -- 468
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 469
	local titleY = winY + winH - 98 -- 470
	if theme.backdropKey ~= nil then -- 470
		texts:put( -- 472
			"lg", -- 472
			theme.titleZh, -- 472
			infoX, -- 472
			titleY, -- 472
			toColor(PALETTE.textBright) -- 472
		) -- 472
	elseif sIdx > 0 then -- 472
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 474
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 475
		local lw = visualTextWidth(leftPart, 40) -- 476
		texts:put( -- 477
			"banner", -- 477
			leftPart, -- 477
			infoX, -- 477
			titleY, -- 477
			toColor(PALETTE.textBright), -- 477
			0, -- 477
			0.5, -- 477
			"Left", -- 477
			2, -- 477
			1, -- 477
			0.1 -- 477
		) -- 477
		drawBlossomDot( -- 478
			uiInkDraw, -- 478
			uiArt, -- 478
			"chap_title_dot", -- 478
			infoX + lw + 16, -- 478
			titleY - 2, -- 478
			11, -- 478
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 478
			0.9, -- 478
			4 -- 478
		) -- 478
		texts:put( -- 479
			"banner", -- 479
			rightPart, -- 479
			infoX + lw + 32, -- 479
			titleY, -- 479
			toColor(PALETTE.textBright), -- 479
			0, -- 479
			0.5, -- 479
			"Left", -- 479
			2, -- 479
			1, -- 479
			0.1 -- 479
		) -- 479
	else -- 479
		texts:put( -- 481
			"banner", -- 481
			theme.titleZh, -- 481
			infoX, -- 481
			titleY, -- 481
			toColor(PALETTE.textBright), -- 481
			0, -- 481
			0.5, -- 481
			"Left", -- 481
			2.4, -- 481
			1, -- 481
			0.1 -- 481
		) -- 481
	end -- 481
	drawHairline( -- 484
		uiInkDraw, -- 484
		uiArt, -- 484
		"chap_info_line", -- 484
		infoX + 185, -- 484
		titleY - 36, -- 484
		370, -- 484
		PALETTE.silkDim, -- 484
		0.58, -- 484
		false, -- 484
		2 -- 484
	) -- 484
	texts:put( -- 487
		"sm", -- 487
		theme.introWhisper, -- 487
		infoX, -- 487
		titleY - 72, -- 487
		toColor(PALETTE.textMid), -- 487
		0, -- 487
		0.5, -- 487
		"Left", -- 487
		0.8, -- 487
		0.94, -- 487
		0.08 -- 487
	) -- 487
	local goX = infoX -- 490
	local goY = winY + 26 -- 491
	local goW = 220 -- 492
	local goH = 42 -- 493
	local goBox = Rect(goX, goY, goW, goH) -- 494
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 495
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 496
	drawSilkRibbon( -- 497
		uiDraw, -- 497
		uiArt, -- 497
		"chap_go_rib", -- 497
		goX + 106, -- 497
		goY + 21, -- 497
		250, -- 497
		40, -- 497
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 497
		(goHover and 0.68 or 0.46) * breathe, -- 497
		0 -- 497
	) -- 497
	drawHairline( -- 498
		uiInkDraw, -- 498
		uiArt, -- 498
		"chap_go_line", -- 498
		goX + 94, -- 498
		goY + 3, -- 498
		196, -- 498
		PALETTE.silkLine, -- 498
		goHover and 0.68 or 0.4, -- 498
		false, -- 498
		2 -- 498
	) -- 498
	drawBlossomDot( -- 499
		uiInkDraw, -- 499
		uiArt, -- 499
		"chap_go_dot", -- 499
		goX + 14, -- 499
		goY + 21, -- 499
		14, -- 499
		PALETTE.rouge, -- 499
		0.96, -- 499
		4 -- 499
	) -- 499
	texts:put( -- 500
		"md", -- 500
		"入此卷章", -- 500
		goX + 34, -- 500
		goY + 21, -- 500
		toColor(PALETTE.textBright), -- 500
		0, -- 500
		0.5, -- 500
		"Left", -- 500
		3.8, -- 500
		1, -- 500
		0.1 -- 500
	) -- 500
	texts:put( -- 501
		"xs", -- 501
		"Enter", -- 501
		goX + 156, -- 501
		goY + 21, -- 501
		toColor(PALETTE.textDim), -- 501
		0, -- 501
		0.5, -- 501
		"Left", -- 501
		1, -- 501
		0.82, -- 501
		0.08 -- 501
	) -- 501
	drawSilkVeil( -- 504
		uiDraw, -- 504
		uiArt, -- 504
		"chap_track_veil", -- 504
		w * 0.5, -- 504
		trackY + 6, -- 504
		w - marginX * 1.1, -- 504
		126, -- 504
		PALETTE.inkWash, -- 504
		0.72, -- 504
		-2 -- 504
	) -- 504
	drawMistCurve( -- 505
		uiArt, -- 505
		"chap_track_mist", -- 505
		w * 0.5, -- 505
		trackY, -- 505
		trackX1 - trackX0 + 160, -- 505
		74, -- 505
		PALETTE.inkMist, -- 505
		0.62, -- 505
		-1 -- 505
	) -- 505
	uiInkDraw:drawSegment( -- 506
		Vec2(trackX0, trackY), -- 506
		Vec2(trackX1, trackY), -- 506
		0.9, -- 506
		toColor(PALETTE.silkDim, 145) -- 506
	) -- 506
	if splitTrack then -- 506
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 509
		uiInkDraw:drawSegment( -- 510
			Vec2(trackX0, trackY - rowGap), -- 510
			Vec2(lastX, trackY - rowGap), -- 510
			0.9, -- 510
			toColor(PALETTE.silkDim, 145) -- 510
		) -- 510
	else -- 510
		local midDivX = trackX0 + stepX * 3.5 -- 512
		uiInkDraw:drawSegment( -- 513
			Vec2(midDivX, trackY - 12), -- 513
			Vec2(midDivX, trackY + 12), -- 513
			0.8, -- 513
			toColor(PALETTE.silkDim, 120) -- 513
		) -- 513
		texts:put( -- 514
			"xs", -- 514
			"上卷 · 孤城护童", -- 514
			trackX0 + stepX * 1.5, -- 514
			trackY + 52, -- 514
			toColor(PALETTE.cyan), -- 514
			0.5, -- 514
			0.5, -- 514
			"Center", -- 514
			2.2, -- 514
			0.88, -- 514
			0.08 -- 514
		) -- 514
		texts:put( -- 515
			"xs", -- 515
			"下卷 · 独赴北塔", -- 515
			trackX0 + stepX * 5.5, -- 515
			trackY + 52, -- 515
			toColor(PALETTE.amber), -- 515
			0.5, -- 515
			0.5, -- 515
			"Center", -- 515
			2.2, -- 515
			0.88, -- 515
			0.08 -- 515
		) -- 515
	end -- 515
	local i = 0 -- 518
	do -- 518
		i = 0 -- 519
		while i < #CHAPTERS do -- 519
			local box = stationBoxes[i + 1] -- 520
			local sx = box.x + box.width * 0.5 -- 521
			local sy = box.y + box.height * 0.5 -- 522
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 523
			local active = self.chapterSelected == i -- 524
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 525
			if active then -- 525
				fillRadialGlow( -- 528
					uiGlow, -- 528
					sx, -- 528
					sy, -- 528
					26, -- 528
					26, -- 528
					toColor(PALETTE.rouge, 36 * breathe), -- 528
					Color(182, 58, 56, 0), -- 528
					12 -- 528
				) -- 528
				uiArt:tryPlace( -- 529
					"ink_enso_fine", -- 529
					"chap_st_ring_" .. tostring(i), -- 529
					sx, -- 529
					sy, -- 529
					32, -- 529
					32, -- 529
					{ -- 529
						color = toColor(PALETTE.silkLine), -- 530
						opacity = 0.78, -- 530
						angle = self.time * 18, -- 530
						layer = 3 -- 530
					} -- 530
				) -- 530
				drawBlossomDot( -- 532
					uiInkDraw, -- 532
					uiArt, -- 532
					"chap_st_dot_" .. tostring(i), -- 532
					sx, -- 532
					sy, -- 532
					17, -- 532
					PALETTE.rouge, -- 532
					0.98, -- 532
					4 -- 532
				) -- 532
			else -- 532
				uiArt:tryPlace( -- 534
					"ink_enso_fine", -- 534
					"chap_st_ring_" .. tostring(i), -- 534
					sx, -- 534
					sy, -- 534
					16, -- 534
					16, -- 534
					{ -- 534
						color = toColor(nodeCol), -- 535
						opacity = 0.62, -- 535
						layer = 3 -- 535
					} -- 535
				) -- 535
				drawBlossomDot( -- 537
					uiInkDraw, -- 537
					uiArt, -- 537
					"chap_st_dot_" .. tostring(i), -- 537
					sx, -- 537
					sy, -- 537
					7, -- 537
					PALETTE.silkLine, -- 537
					0.72, -- 537
					4 -- 537
				) -- 537
			end -- 537
			if not splitTrack then -- 537
				texts:put( -- 541
					"xs", -- 541
					rt.numeralZh, -- 541
					sx, -- 541
					sy + 25, -- 541
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 541
					0.5, -- 541
					0.5, -- 541
					"Center", -- 541
					0, -- 541
					active and 1 or 0.88, -- 541
					0.08 -- 541
				) -- 541
			end -- 541
			texts:put( -- 543
				"xs", -- 543
				rt.shortNameZh, -- 543
				sx, -- 543
				sy - 26, -- 543
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 543
				0.5, -- 543
				0.5, -- 543
				"Center", -- 543
				1, -- 543
				active and 1 or 0.84, -- 543
				0.08 -- 543
			) -- 543
			i = i + 1 -- 519
		end -- 519
	end -- 519
	local backX = marginX -- 547
	local backY = 40 -- 548
	local backBox = Rect(backX, backY, 190, 34) -- 549
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 550
	drawSilkKeycap( -- 551
		uiInkDraw, -- 551
		texts, -- 551
		backX, -- 551
		backY + 5, -- 551
		44, -- 551
		24, -- 551
		"ESC", -- 551
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 551
		0.92, -- 551
		backHover -- 551
	) -- 551
	texts:put( -- 552
		"sm", -- 552
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 552
		backX + 56, -- 552
		backY + 17, -- 552
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 552
		0, -- 552
		0.5, -- 552
		"Left", -- 552
		1.8, -- 552
		0.9, -- 552
		0.08 -- 552
	) -- 552
	texts:put( -- 553
		"xs", -- 553
		"方向键选择   ·   回车或点击进入", -- 553
		w - marginX, -- 553
		backY + 17, -- 553
		toColor(PALETTE.textDim), -- 553
		1, -- 553
		0.5, -- 553
		"Right", -- 553
		1.2, -- 553
		0.75, -- 553
		0.08 -- 553
	) -- 553
	if frame.click and backHover then -- 553
		return back -- 556
	end -- 556
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 556
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 559
	end -- 559
	return {type = "none"} -- 561
end -- 375
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 567
	if backLabel == nil then -- 567
		backLabel = "返回标题" -- 576
	end -- 576
	local marginX = 96 -- 578
	local backX = marginX -- 579
	local backY = 40 -- 580
	local backBox = Rect(backX, backY, 230, 34) -- 581
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 582
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 582
		return {type = "backTitle"} -- 584
	end -- 584
	uiDraw:drawRect( -- 586
		Rect(0, 0, w, h), -- 586
		Color(10, 12, 19, 204) -- 586
	) -- 586
	texts:put( -- 588
		"banner", -- 588
		"执器要诀", -- 588
		marginX, -- 588
		h - 66, -- 588
		toColor(PALETTE.textBright), -- 588
		0, -- 588
		0.5, -- 588
		"Left", -- 588
		4.5, -- 588
		0.96, -- 588
		0.1 -- 588
	) -- 588
	texts:put( -- 589
		"xs", -- 589
		"键鼠操作说明", -- 589
		marginX + 196, -- 589
		h - 70, -- 589
		toColor(PALETTE.textDim), -- 589
		0, -- 589
		0.5, -- 589
		"Left", -- 589
		2, -- 589
		0.85, -- 589
		0.08 -- 589
	) -- 589
	drawHairline( -- 590
		uiInkDraw, -- 590
		uiArt, -- 590
		"ctrl_top_line", -- 590
		w * 0.5, -- 590
		h - 100, -- 590
		w - marginX * 2, -- 590
		PALETTE.silkDim, -- 590
		0.6, -- 590
		true, -- 590
		2 -- 590
	) -- 590
	local areaY = 114 -- 593
	local areaH = h - 244 -- 594
	drawFiligreeCorners( -- 595
		uiInkDraw, -- 595
		uiArt, -- 595
		"ctrl_outer", -- 595
		marginX, -- 595
		areaY, -- 595
		w - marginX * 2, -- 595
		areaH, -- 595
		PALETTE.silkDim, -- 595
		0.52, -- 595
		34, -- 595
		false, -- 595
		2 -- 595
	) -- 595
	local midX = w * 0.5 -- 598
	uiArt:tryPlace( -- 599
		"ink_vstream", -- 599
		"ctrl_mid_stream", -- 599
		midX, -- 599
		areaY + areaH * 0.5, -- 599
		32, -- 599
		areaH - 18, -- 599
		{ -- 599
			color = toColor(PALETTE.silkDim), -- 600
			opacity = 0.52, -- 600
			layer = 1 -- 600
		} -- 600
	) -- 600
	drawBlossomDot( -- 602
		uiInkDraw, -- 602
		uiArt, -- 602
		"ctrl_mid_dot", -- 602
		midX, -- 602
		areaY + areaH * 0.5, -- 602
		11, -- 602
		PALETTE.silkLine, -- 602
		0.62, -- 602
		3 -- 602
	) -- 602
	local leftColX = marginX + 34 -- 605
	local colW = midX - leftColX - 42 -- 606
	local headY = areaY + areaH - 34 -- 607
	drawBlossomDot( -- 608
		uiInkDraw, -- 608
		uiArt, -- 608
		"ctrl_l_dot", -- 608
		leftColX + 8, -- 608
		headY, -- 608
		12, -- 608
		PALETTE.cyan, -- 608
		0.88, -- 608
		3 -- 608
	) -- 608
	texts:put( -- 609
		"md", -- 609
		"周戍 · 护送与交锋", -- 609
		leftColX + 26, -- 609
		headY, -- 609
		toColor(PALETTE.cyanCore), -- 609
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
		"ctrl_l_line", -- 610
		leftColX + colW * 0.5, -- 610
		headY - 24, -- 610
		colW, -- 610
		PALETTE.cyanDim, -- 610
		0.58, -- 610
		false, -- 610
		2 -- 610
	) -- 610
	local sRows = { -- 612
		{"WASD / 方向键", "左右、前后自由移动"}, -- 613
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 614
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 615
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 616
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 617
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 618
	} -- 618
	local i = 0 -- 620
	do -- 620
		i = 0 -- 621
		while i < #sRows do -- 621
			local ry = headY - 66 - i * 52 -- 622
			drawSilkKeycap( -- 623
				uiInkDraw, -- 623
				texts, -- 623
				leftColX + 2, -- 623
				ry - 13, -- 623
				132, -- 623
				26, -- 623
				sRows[i + 1][1], -- 623
				PALETTE.cyan, -- 623
				0.92, -- 623
				false -- 623
			) -- 623
			texts:put( -- 624
				"sm", -- 624
				sRows[i + 1][2], -- 624
				leftColX + 150, -- 624
				ry, -- 624
				toColor(PALETTE.textBright), -- 624
				0, -- 624
				0.5, -- 624
				"Left", -- 624
				0.8, -- 624
				0.92, -- 624
				0.08 -- 624
			) -- 624
			i = i + 1 -- 621
		end -- 621
	end -- 621
	local rightColX = midX + 44 -- 628
	drawBlossomDot( -- 629
		uiInkDraw, -- 629
		uiArt, -- 629
		"ctrl_r_dot", -- 629
		rightColX + 8, -- 629
		headY, -- 629
		12, -- 629
		PALETTE.amber, -- 629
		0.88, -- 629
		3 -- 629
	) -- 629
	texts:put( -- 630
		"md", -- 630
		"小满 · 潜行与寻路", -- 630
		rightColX + 26, -- 630
		headY, -- 630
		toColor(PALETTE.amberCore), -- 630
		0, -- 630
		0.5, -- 630
		"Left", -- 630
		2.4, -- 630
		0.98, -- 630
		0.08 -- 630
	) -- 630
	drawHairline( -- 631
		uiInkDraw, -- 631
		uiArt, -- 631
		"ctrl_r_line", -- 631
		rightColX + colW * 0.5, -- 631
		headY - 24, -- 631
		colW, -- 631
		PALETTE.amberDim, -- 631
		0.58, -- 631
		false, -- 631
		2 -- 631
	) -- 631
	local cRows = { -- 633
		{"A / D · ← / →", "左右潜行"}, -- 634
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 635
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 636
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 637
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 638
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 639
	} -- 639
	do -- 639
		i = 0 -- 641
		while i < #cRows do -- 641
			local ry = headY - 66 - i * 52 -- 642
			drawSilkKeycap( -- 643
				uiInkDraw, -- 643
				texts, -- 643
				rightColX + 2, -- 643
				ry - 13, -- 643
				132, -- 643
				26, -- 643
				cRows[i + 1][1], -- 643
				PALETTE.amber, -- 643
				0.92, -- 643
				false -- 643
			) -- 643
			texts:put( -- 644
				"sm", -- 644
				cRows[i + 1][2], -- 644
				rightColX + 150, -- 644
				ry, -- 644
				toColor(PALETTE.textBright), -- 644
				0, -- 644
				0.5, -- 644
				"Left", -- 644
				0.8, -- 644
				0.92, -- 644
				0.08 -- 644
			) -- 644
			i = i + 1 -- 641
		end -- 641
	end -- 641
	drawSilkKeycap( -- 648
		uiInkDraw, -- 648
		texts, -- 648
		backX, -- 648
		backY + 5, -- 648
		110, -- 648
		24, -- 648
		"ESC / ENTER", -- 648
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 648
		0.92, -- 648
		backHover -- 648
	) -- 648
	texts:put( -- 649
		"sm", -- 649
		backLabel, -- 649
		backX + 122, -- 649
		backY + 17, -- 649
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 649
		0, -- 649
		0.5, -- 649
		"Left", -- 649
		1.8, -- 649
		0.92, -- 649
		0.08 -- 649
	) -- 649
	return {type = "none"} -- 651
end -- 567
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist) -- 658
	if assistHintsEnabled == nil then -- 658
		assistHintsEnabled = false -- 669
	end -- 669
	self.time = self.time + dt -- 672
	local frame = self:readFrame(input, uiScale) -- 673
	if self.pauseShowControls then -- 673
		local ctrlAct = self:drawControls( -- 677
			frame, -- 677
			uiDraw, -- 677
			uiInkDraw, -- 677
			uiArt, -- 677
			uiGlow, -- 677
			texts, -- 677
			w, -- 677
			h, -- 677
			"返回暂停" -- 677
		) -- 677
		if ctrlAct.type == "backTitle" then -- 677
			self.pauseShowControls = false -- 679
			self:resetInput() -- 680
		end -- 680
		return {type = "none"} -- 682
	end -- 682
	if frame.back then -- 682
		self.pauseShowControls = false -- 686
		return {type = "resume"} -- 687
	end -- 687
	uiDraw:drawRect( -- 691
		Rect(0, 0, w, h), -- 691
		Color(8, 10, 16, 102) -- 691
	) -- 691
	fillHGradRect( -- 692
		uiDraw, -- 692
		0, -- 692
		0, -- 692
		w * 0.27, -- 692
		h, -- 692
		Color(9, 11, 18, 232), -- 692
		Color(10, 13, 21, 198) -- 692
	) -- 692
	fillHGradRect( -- 693
		uiDraw, -- 693
		w * 0.27, -- 693
		0, -- 693
		w * 0.21, -- 693
		h, -- 693
		Color(10, 13, 21, 198), -- 693
		Color(10, 13, 21, 0) -- 693
	) -- 693
	local menuX = 110 -- 696
	uiArt:tryPlace( -- 697
		"ink_vstream", -- 697
		"pause_vstream", -- 697
		menuX - 32, -- 697
		h * 0.5, -- 697
		34, -- 697
		h * 0.78, -- 697
		{ -- 697
			color = toColor(PALETTE.silkDim), -- 698
			opacity = 0.48, -- 698
			layer = 1 -- 698
		} -- 698
	) -- 698
	drawMistCurve( -- 700
		uiArt, -- 700
		"pause_mist", -- 700
		menuX + 118, -- 700
		h - 154, -- 700
		290, -- 700
		72, -- 700
		PALETTE.jadeMist, -- 700
		0.2, -- 700
		-1 -- 700
	) -- 700
	texts:put( -- 703
		"banner", -- 703
		"暂歇", -- 703
		menuX + 16, -- 703
		h - 146, -- 703
		toColor(PALETTE.textBright), -- 703
		0, -- 703
		0.5, -- 703
		"Left", -- 703
		10, -- 703
		0.98, -- 703
		0.1 -- 703
	) -- 703
	texts:put( -- 704
		"xs", -- 704
		"月夜暂驻 · 卷页留痕", -- 704
		menuX + 18, -- 704
		h - 184, -- 704
		toColor(PALETTE.textDim), -- 704
		0, -- 704
		0.5, -- 704
		"Left", -- 704
		2, -- 704
		0.8, -- 704
		0.08 -- 704
	) -- 704
	drawHairline( -- 705
		uiInkDraw, -- 705
		uiArt, -- 705
		"pause_div", -- 705
		menuX + 124, -- 705
		h - 210, -- 705
		240, -- 705
		PALETTE.silkDim, -- 705
		0.58, -- 705
		true, -- 705
		2 -- 705
	) -- 705
	local boxes = {} -- 707
	local i = 0 -- 708
	do -- 708
		i = 0 -- 709
		while i < #PAUSE_ITEMS do -- 709
			boxes[#boxes + 1] = Rect(menuX - 10, h - 270 - i * 52, 270, 42) -- 710
			i = i + 1 -- 709
		end -- 709
	end -- 709
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 712
	do -- 712
		i = 0 -- 714
		while i < #PAUSE_ITEMS do -- 714
			local iy = boxes[i + 1].y -- 715
			local active = self.pauseSelected == i -- 716
			local cy = iy + 21 -- 717
			local shiftX = active and 10 or 0 -- 718
			local item = PAUSE_ITEMS[i + 1] -- 719
			local label = item.id == "assist" and (assistHintsEnabled and "按键辅助：开" or "按键辅助：关") or item.zh -- 720
			if active then -- 720
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 725
				drawSilkRibbon( -- 726
					uiDraw, -- 726
					uiArt, -- 726
					"pause_rib_" .. tostring(i), -- 726
					menuX + 116, -- 726
					cy, -- 726
					276, -- 726
					38, -- 726
					PALETTE.rougeSoft, -- 726
					0.54 * breathe, -- 726
					0 -- 726
				) -- 726
				drawHairline( -- 727
					uiInkDraw, -- 727
					uiArt, -- 727
					"pause_line_" .. tostring(i), -- 727
					menuX + 106, -- 727
					iy + 3, -- 727
					210, -- 727
					PALETTE.silkLine, -- 727
					0.42 * breathe, -- 727
					false, -- 727
					2 -- 727
				) -- 727
				drawBlossomDot( -- 728
					uiInkDraw, -- 728
					uiArt, -- 728
					"pause_dot_" .. tostring(i), -- 728
					menuX + 12, -- 728
					cy, -- 728
					15, -- 728
					PALETTE.rouge, -- 728
					0.96, -- 728
					4 -- 728
				) -- 728
				fillRadialGlow( -- 729
					uiGlow, -- 729
					menuX + 12, -- 729
					cy, -- 729
					22, -- 729
					16, -- 729
					toColor(PALETTE.rouge, 26 * breathe), -- 729
					Color(182, 58, 56, 0), -- 729
					10 -- 729
				) -- 729
			else -- 729
				drawBlossomDot( -- 731
					uiInkDraw, -- 731
					uiArt, -- 731
					"pause_dot_" .. tostring(i), -- 731
					menuX + 12, -- 731
					cy, -- 731
					8, -- 731
					PALETTE.silkDim, -- 731
					0.4, -- 731
					3 -- 731
				) -- 731
			end -- 731
			texts:put( -- 734
				"md", -- 735
				label, -- 736
				menuX + 32 + shiftX, -- 737
				cy, -- 738
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 739
				0, -- 740
				0.5, -- 741
				"Left", -- 742
				active and 3.8 or 2.4, -- 743
				active and 1 or 0.88, -- 744
				0.1 -- 745
			) -- 745
			i = i + 1 -- 714
		end -- 714
	end -- 714
	texts:put( -- 749
		"xs", -- 749
		"Esc 续行   ·   Enter 或点击确认", -- 749
		menuX + 12, -- 749
		56, -- 749
		toColor(PALETTE.textDim), -- 749
		0, -- 749
		0.5, -- 749
		"Left", -- 749
		1.2, -- 749
		0.86, -- 749
		0.08 -- 749
	) -- 749
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 751
	if hit >= 0 or frame.keys.confirm then -- 751
		local idx = hit >= 0 and hit or self.pauseSelected -- 753
		local id = PAUSE_ITEMS[idx + 1].id -- 754
		if id == "controls" then -- 754
			self.pauseShowControls = true -- 756
			self:resetInput() -- 757
			return {type = "none"} -- 758
		end -- 758
		if id == "assist" then -- 758
			if onToggleAssist ~= nil then -- 758
				onToggleAssist() -- 762
			end -- 762
			self:resetInput() -- 764
			return {type = "none"} -- 765
		end -- 765
		self.pauseShowControls = false -- 767
		if id == "resume" then -- 767
			return {type = "resume"} -- 769
		end -- 769
		if id == "retry" then -- 769
			return {type = "retry"} -- 772
		end -- 772
		if id == "chapters" then -- 772
			return {type = "openChapters"} -- 775
		end -- 775
		return {type = "toTitle"} -- 777
	end -- 777
	return {type = "none"} -- 779
end -- 658
return ____exports -- 658