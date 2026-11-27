-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
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
local TITLE_ITEMS = { -- 42
	{id = "start", zh = "开始游戏"}, -- 43
	{id = "chapters", zh = "选择章节"}, -- 44
	{id = "controls", zh = "操作说明"}, -- 45
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 46
	{id = "quit", zh = "退出游戏"} -- 47
} -- 47
local CHAPTERS = __TS__ArrayFilter( -- 51
	__TS__ArrayMap( -- 51
		ROOMS, -- 51
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 51
	), -- 51
	function(____, chapter) return chapter.room.key ~= "museum" end -- 52
) -- 52
local PAUSE_ITEMS = { -- 54
	{id = "resume", zh = "继续游戏"}, -- 55
	{id = "retry", zh = "重试检查点"}, -- 56
	{id = "controls", zh = "操作说明"}, -- 57
	{id = "assist", zh = "按键辅助：关"}, -- 58
	{id = "fullscreen", zh = "显示：窗口"}, -- 59
	{id = "chapters", zh = "选择章节"}, -- 60
	{id = "title", zh = "返回标题"}, -- 61
	{id = "quit", zh = "退出游戏"} -- 62
} -- 62
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 65
local EPIGRAPH_RIGHT = { -- 67
	"城", -- 67
	"破", -- 67
	"那", -- 67
	"天", -- 67
	"", -- 67
	"他", -- 67
	"留", -- 67
	"下", -- 67
	"断", -- 67
	"后" -- 67
} -- 67
local EPIGRAPH_LEFT = { -- 68
	"她", -- 68
	"独", -- 68
	"自", -- 68
	"走", -- 68
	"向", -- 68
	"北", -- 68
	"塔" -- 68
} -- 68
local function pressedKeys() -- 87
	return { -- 88
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 89
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 90
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 91
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 92
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 93
	} -- 93
end -- 87
local function hitIndex(boxes, pointer, inside) -- 97
	if not inside then -- 97
		return -1 -- 99
	end -- 99
	return __TS__ArrayFindIndex( -- 101
		boxes, -- 101
		function(____, box) return box:containsPoint(pointer) end -- 101
	) -- 101
end -- 97
____exports.MenuRenderer = __TS__Class() -- 104
local MenuRenderer = ____exports.MenuRenderer -- 104
MenuRenderer.name = "MenuRenderer" -- 104
function MenuRenderer.prototype.____constructor(self) -- 104
	self.selected = 0 -- 105
	self.chapterSelected = 0 -- 106
	self.pauseSelected = 0 -- 107
	self.hasSession = false -- 109
	self.chaptersFromPause = false -- 110
	self.pauseShowControls = false -- 112
	self.previousKeys = {} -- 113
	self.queuedKeys = {} -- 114
	self.queuedBack = false -- 115
	self.time = 0 -- 116
end -- 104
function MenuRenderer.prototype.isShowingPauseControls(self) -- 118
	return self.pauseShowControls -- 119
end -- 118
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 122
	self.chaptersFromPause = roomIndex ~= nil -- 123
	self.chapterSelected = math.max( -- 124
		0, -- 124
		__TS__ArrayFindIndex( -- 124
			CHAPTERS, -- 124
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 124
		) -- 124
	) -- 124
	self.pauseShowControls = false -- 125
	self:resetInput() -- 126
end -- 122
function MenuRenderer.prototype.openPause(self) -- 129
	self.pauseSelected = 0 -- 130
	self.pauseShowControls = false -- 131
	self:resetInput() -- 132
end -- 129
function MenuRenderer.prototype.resetInput(self) -- 136
	self.previousKeys = pressedKeys() -- 137
	self.queuedKeys = {} -- 138
	self.queuedBack = false -- 139
end -- 136
function MenuRenderer.prototype.onKeyEvent(self, key) -- 143
	if key == "Up" or key == "W" then -- 143
		self.queuedKeys.up = true -- 145
	elseif key == "Down" or key == "S" then -- 145
		self.queuedKeys.down = true -- 147
	elseif key == "Left" or key == "A" then -- 147
		self.queuedKeys.left = true -- 149
	elseif key == "Right" or key == "D" then -- 149
		self.queuedKeys.right = true -- 151
	elseif key == "Return" or key == "Space" then -- 151
		self.queuedKeys.confirm = true -- 153
	elseif key == "Escape" then -- 153
		self.queuedBack = true -- 155
	end -- 155
end -- 143
function MenuRenderer.prototype.readFrame(self, input, scale) -- 159
	local held = pressedKeys() -- 160
	local prev = self.previousKeys -- 161
	local queued = self.queuedKeys -- 162
	local frame = { -- 163
		keys = { -- 164
			up = queued.up == true or held.up and not prev.up, -- 165
			down = queued.down == true or held.down and not prev.down, -- 166
			left = queued.left == true or held.left and not prev.left, -- 167
			right = queued.right == true or held.right and not prev.right, -- 168
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 169
		}, -- 169
		back = self.queuedBack or input.pause.pressed, -- 171
		pointer = Vec2(input.mx / scale, input.my / scale), -- 172
		inside = input.inside, -- 173
		click = input.inside and input.fire.pressed, -- 174
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 175
	} -- 175
	self.previousKeys = held -- 177
	self.queuedKeys = {} -- 178
	self.queuedBack = false -- 179
	return frame -- 180
end -- 159
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 183
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 184
	if frame.click and hit >= 0 then -- 184
		return hit -- 186
	end -- 186
	if frame.keys.up then -- 186
		return (selected + #boxes - 1) % #boxes -- 189
	end -- 189
	if frame.keys.down then -- 189
		return (selected + 1) % #boxes -- 192
	end -- 192
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 194
end -- 183
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 197
	self.time = self.time + dt -- 214
	local artW = math.max(w, h * 16 / 9) -- 215
	local artH = artW * 9 / 16 -- 216
	if not backdropArt:tryPlace( -- 216
		"title_backdrop", -- 217
		"menu_landscape", -- 217
		w * 0.5, -- 217
		(h - artH) * 0.5, -- 217
		artW, -- 217
		artH -- 217
	) then -- 217
		stage:drawMenuBackdrop( -- 218
			bgDraw, -- 218
			bgGlow, -- 218
			w, -- 218
			h, -- 218
			self.time -- 218
		) -- 218
	end -- 218
	local frame = self:readFrame(input, uiScale) -- 221
	w = w / uiScale -- 222
	h = h / uiScale -- 223
	if screen == "title" then -- 223
		return self:drawTitle( -- 226
			frame, -- 226
			uiDraw, -- 226
			uiInkDraw, -- 226
			uiArt, -- 226
			uiGlow, -- 226
			texts, -- 226
			w, -- 226
			h -- 226
		) -- 226
	end -- 226
	if screen == "chapters" then -- 226
		return self:drawChapters( -- 229
			frame, -- 229
			uiDraw, -- 229
			uiInkDraw, -- 229
			uiArt, -- 229
			uiGlow, -- 229
			texts, -- 229
			w, -- 229
			h -- 229
		) -- 229
	end -- 229
	return self:drawControls( -- 231
		frame, -- 231
		uiDraw, -- 231
		uiInkDraw, -- 231
		uiArt, -- 231
		uiGlow, -- 231
		texts, -- 231
		w, -- 231
		h -- 231
	) -- 231
end -- 197
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 234
	fillHGradRect( -- 245
		uiDraw, -- 245
		0, -- 245
		0, -- 245
		w * 0.22, -- 245
		h, -- 245
		Color(9, 11, 18, 192), -- 245
		Color(9, 11, 18, 116) -- 245
	) -- 245
	fillHGradRect( -- 246
		uiDraw, -- 246
		w * 0.22, -- 246
		0, -- 246
		w * 0.28, -- 246
		h, -- 246
		Color(9, 11, 18, 116), -- 246
		Color(9, 11, 18, 0) -- 246
	) -- 246
	fillVGradRect( -- 247
		uiDraw, -- 247
		0, -- 247
		0, -- 247
		w, -- 247
		78, -- 247
		Color(8, 10, 16, 138), -- 247
		Color(8, 10, 16, 0) -- 247
	) -- 247
	local titleX = 148 -- 250
	local topY = h - 104 -- 251
	local charStep = 66 -- 252
	local sway = math.sin(self.time * 0.7) * 5 -- 253
	drawMistCurve( -- 254
		uiArt, -- 254
		"title_mist_wisp", -- 254
		titleX + 86 + sway, -- 254
		topY - 122, -- 254
		340, -- 254
		82, -- 254
		PALETTE.jadeMist, -- 254
		0.2, -- 254
		-1 -- 254
	) -- 254
	uiArt:tryPlace( -- 255
		"ink_petal_mist", -- 255
		"title_petals", -- 255
		titleX + 12, -- 255
		topY - 102, -- 255
		230, -- 255
		210, -- 255
		{ -- 255
			color = toColor(PALETTE.inkMist), -- 256
			opacity = 0.4, -- 256
			layer = -1 -- 256
		} -- 256
	) -- 256
	uiArt:tryPlace( -- 258
		"ink_vstream", -- 258
		"title_vstream", -- 258
		titleX - 48, -- 258
		topY - 100, -- 258
		34, -- 258
		290, -- 258
		{ -- 258
			color = toColor(PALETTE.silkDim), -- 259
			opacity = 0.48, -- 259
			layer = 1 -- 259
		} -- 259
	) -- 259
	local c = 0 -- 263
	do -- 263
		c = 0 -- 264
		while c < #VERTICAL_TITLE do -- 264
			texts:put( -- 265
				"title", -- 266
				VERTICAL_TITLE[c + 1], -- 267
				titleX, -- 268
				topY - c * charStep, -- 269
				toColor(PALETTE.textBright), -- 270
				0.5, -- 271
				0.5, -- 272
				"Center", -- 273
				0, -- 274
				0.98, -- 275
				0.1, -- 276
				Color(8, 10, 16, 210) -- 277
			) -- 277
			c = c + 1 -- 264
		end -- 264
	end -- 264
	drawLoneSeal( -- 282
		uiInkDraw, -- 283
		uiArt, -- 284
		texts, -- 285
		"title_lone_seal", -- 286
		titleX + 46, -- 287
		topY - 3 * charStep + 8, -- 288
		26, -- 289
		52, -- 290
		"守", -- 291
		"望", -- 292
		PALETTE.sealRed, -- 293
		PALETTE.sealText, -- 294
		0.94, -- 295
		4 -- 296
	) -- 296
	local colRightX = titleX + 132 -- 300
	local colLeftX = titleX + 102 -- 301
	local poemStep = 22 -- 302
	local p = 0 -- 303
	do -- 303
		p = 0 -- 304
		while p < #EPIGRAPH_RIGHT do -- 304
			local ch = EPIGRAPH_RIGHT[p + 1] -- 305
			if ch ~= "" then -- 305
				texts:put( -- 307
					"xs", -- 307
					ch, -- 307
					colRightX, -- 307
					topY - 22 - p * poemStep, -- 307
					toColor(PALETTE.textMid), -- 307
					0.5, -- 307
					0.5, -- 307
					"Center", -- 307
					0, -- 307
					0.86, -- 307
					0.08 -- 307
				) -- 307
			end -- 307
			p = p + 1 -- 304
		end -- 304
	end -- 304
	do -- 304
		p = 0 -- 310
		while p < #EPIGRAPH_LEFT do -- 310
			texts:put( -- 311
				"xs", -- 311
				EPIGRAPH_LEFT[p + 1], -- 311
				colLeftX, -- 311
				topY - 68 - p * poemStep, -- 311
				toColor(PALETTE.amberCore), -- 311
				0.5, -- 311
				0.5, -- 311
				"Center", -- 311
				0, -- 311
				0.9, -- 311
				0.08 -- 311
			) -- 311
			p = p + 1 -- 310
		end -- 310
	end -- 310
	local items = self.hasSession and ({ -- 315
		{id = "continue", zh = "继续游戏"}, -- 316
		table.unpack(TITLE_ITEMS) -- 316
	}) or TITLE_ITEMS -- 316
	if self.selected >= #items then -- 316
		self.selected = 0 -- 319
	end -- 319
	local menuX = 112 -- 321
	local btnW = 280 -- 322
	local btnH = 40 -- 323
	local gap = self.hasSession and 6 or 8 -- 324
	local startY = self.hasSession and 294 or 264 -- 325
	local boxes = {} -- 326
	local i = 0 -- 327
	do -- 327
		i = 0 -- 328
		while i < #items do -- 328
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 329
			i = i + 1 -- 328
		end -- 328
	end -- 328
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 331
	do -- 331
		i = 0 -- 333
		while i < #items do -- 333
			local by = boxes[i + 1].y -- 334
			local active = self.selected == i -- 335
			local cy = by + btnH * 0.5 -- 336
			local shiftX = active and 10 or 0 -- 337
			if active then -- 337
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 340
				drawSilkRibbon( -- 341
					uiDraw, -- 341
					uiArt, -- 341
					"title_rib_red_" .. tostring(i), -- 341
					menuX + 124, -- 341
					cy, -- 341
					290, -- 341
					40, -- 341
					PALETTE.rougeSoft, -- 341
					0.52 * breathe, -- 341
					0 -- 341
				) -- 341
				drawHairline( -- 342
					uiInkDraw, -- 342
					uiArt, -- 342
					"title_rib_line_" .. tostring(i), -- 342
					menuX + 114, -- 342
					by + 4, -- 342
					230, -- 342
					PALETTE.silkLine, -- 342
					0.42 * breathe, -- 342
					false, -- 342
					2 -- 342
				) -- 342
				drawBlossomDot( -- 343
					uiInkDraw, -- 343
					uiArt, -- 343
					"title_dot_" .. tostring(i), -- 343
					menuX + 14, -- 343
					cy, -- 343
					16, -- 343
					PALETTE.rouge, -- 343
					0.96, -- 343
					4 -- 343
				) -- 343
				fillRadialGlow( -- 344
					uiGlow, -- 344
					menuX + 14, -- 344
					cy, -- 344
					22, -- 344
					16, -- 344
					toColor(PALETTE.rouge, 28 * breathe), -- 344
					Color(182, 58, 56, 0), -- 344
					10 -- 344
				) -- 344
			else -- 344
				drawBlossomDot( -- 346
					uiInkDraw, -- 346
					uiArt, -- 346
					"title_dot_" .. tostring(i), -- 346
					menuX + 14, -- 346
					cy, -- 346
					8, -- 346
					PALETTE.silkDim, -- 346
					0.4, -- 346
					3 -- 346
				) -- 346
			end -- 346
			texts:put( -- 349
				"md", -- 350
				items[i + 1].zh, -- 351
				menuX + 34 + shiftX, -- 352
				cy, -- 353
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 354
				0, -- 355
				0.5, -- 356
				"Left", -- 357
				active and 4.4 or 2.8, -- 358
				active and 1 or 0.88, -- 359
				0.1 -- 360
			) -- 360
			i = i + 1 -- 333
		end -- 333
	end -- 333
	texts:put( -- 364
		"xs", -- 364
		"上下择项   ·   回车或点选启程", -- 364
		menuX + 12, -- 364
		42, -- 364
		toColor(PALETTE.textDim), -- 364
		0, -- 364
		0.5, -- 364
		"Left", -- 364
		1.4, -- 364
		0.88, -- 364
		0.08 -- 364
	) -- 364
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 366
	if hit >= 0 or frame.keys.confirm then -- 366
		local idx = hit >= 0 and hit or self.selected -- 368
		local id = items[idx + 1].id -- 369
		if id == "continue" then -- 369
			return {type = "continue"} -- 371
		end -- 371
		if id == "trial" then -- 371
			return {type = "trial"} -- 373
		end -- 373
		if id == "start" then -- 373
			return {type = "start"} -- 375
		end -- 375
		if id == "chapters" then -- 375
			return {type = "openChapters"} -- 378
		end -- 378
		if id == "quit" then -- 378
			return {type = "quit"} -- 381
		end -- 381
		return {type = "openControls"} -- 383
	end -- 383
	return {type = "none"} -- 385
end -- 234
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 392
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 402
	if frame.back then -- 402
		return back -- 404
	end -- 404
	local marginX = 96 -- 407
	local splitTrack = #CHAPTERS > 8 -- 408
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 409
	local trackY = splitTrack and 195 or 148 -- 410
	local rowGap = 84 -- 411
	local trackX0 = marginX + 34 -- 412
	local trackX1 = w - marginX - 34 -- 413
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 414
	local stationBoxes = {} -- 416
	local s = 0 -- 417
	do -- 417
		s = 0 -- 418
		while s < #CHAPTERS do -- 418
			local sx = trackX0 + s % perRow * stepX -- 419
			local sy = trackY - math.floor(s / perRow) * rowGap -- 420
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74) -- 421
			s = s + 1 -- 418
		end -- 418
	end -- 418
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 424
	local keys = frame.keys -- 425
	if frame.click and hitStation >= 0 then -- 425
		self.chapterSelected = hitStation -- 427
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 427
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 429
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 430
	elseif keys.down and self.chapterSelected < perRow then -- 430
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 432
	elseif keys.up and self.chapterSelected >= perRow then -- 432
		self.chapterSelected = self.chapterSelected - perRow -- 434
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 434
		self.chapterSelected = hitStation -- 436
	end -- 436
	uiDraw:drawRect( -- 440
		Rect(0, 0, w, h), -- 440
		Color(10, 12, 19, 198) -- 440
	) -- 440
	texts:put( -- 443
		"banner", -- 443
		"选择章节", -- 443
		marginX, -- 443
		h - 66, -- 443
		toColor(PALETTE.textBright), -- 443
		0, -- 443
		0.5, -- 443
		"Left", -- 443
		4.5, -- 443
		0.96, -- 443
		0.1 -- 443
	) -- 443
	drawHairline( -- 444
		uiInkDraw, -- 444
		uiArt, -- 444
		"chap_top_line", -- 444
		w * 0.5, -- 444
		h - 100, -- 444
		w - marginX * 2, -- 444
		PALETTE.silkDim, -- 444
		0.6, -- 444
		true, -- 444
		2 -- 444
	) -- 444
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 447
	local theme = themeOf(activeRoom.key) -- 448
	local winX = marginX -- 449
	local winY = 266 -- 450
	local winW = 548 -- 451
	local winH = 300 -- 452
	local winBox = Rect(winX, winY, winW, winH) -- 453
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 454
	uiArt:tryPlace( -- 457
		"ink_frame_mask", -- 457
		"chap_win_shadow", -- 457
		winX + winW * 0.5, -- 457
		winY + winH * 0.5, -- 457
		winW + 40, -- 457
		winH + 34, -- 457
		{ -- 457
			color = toColor(PALETTE.inkVoid), -- 458
			opacity = 0.88, -- 458
			layer = -2 -- 458
		} -- 458
	) -- 458
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 460
	uiArt:tryPlace( -- 461
		bgSlot, -- 461
		"chap_win_art", -- 461
		winX + winW * 0.5, -- 461
		winY + 4, -- 461
		winW - 8, -- 461
		winH - 8, -- 461
		{opacity = 0.92, layer = -1} -- 461
	) -- 461
	fillVGradRect( -- 465
		uiInkDraw, -- 465
		winX, -- 465
		winY, -- 465
		winW, -- 465
		56, -- 465
		Color(10, 12, 19, 200), -- 465
		Color(10, 12, 19, 0) -- 465
	) -- 465
	fillVGradRect( -- 466
		uiInkDraw, -- 466
		winX, -- 466
		winY + winH - 36, -- 466
		winW, -- 466
		36, -- 466
		Color(10, 12, 19, 0), -- 466
		Color(10, 12, 19, 130) -- 466
	) -- 466
	fillHGradRect( -- 467
		uiInkDraw, -- 467
		winX, -- 467
		winY, -- 467
		34, -- 467
		winH, -- 467
		Color(10, 12, 19, 135), -- 467
		Color(10, 12, 19, 0) -- 467
	) -- 467
	fillHGradRect( -- 468
		uiInkDraw, -- 468
		winX + winW - 34, -- 468
		winY, -- 468
		34, -- 468
		winH, -- 468
		Color(10, 12, 19, 0), -- 468
		Color(10, 12, 19, 135) -- 468
	) -- 468
	drawFiligreeCorners( -- 470
		uiInkDraw, -- 470
		uiArt, -- 470
		"chap_win_frame", -- 470
		winX, -- 470
		winY, -- 470
		winW, -- 470
		winH, -- 470
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 470
		winHover and 0.92 or 0.72, -- 470
		34, -- 470
		true, -- 470
		3 -- 470
	) -- 470
	texts:put( -- 473
		"xs", -- 473
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 473
		winX + 20, -- 473
		winY + 22, -- 473
		toColor(PALETTE.textMid), -- 473
		0, -- 473
		0.5, -- 473
		"Left", -- 473
		1.8, -- 473
		0.9, -- 473
		0.08 -- 473
	) -- 473
	local infoX = winX + winW + 46 -- 476
	local infoCenterY = winY + winH * 0.5 -- 477
	drawMistCurve( -- 478
		uiArt, -- 478
		"chap_info_mist", -- 478
		infoX + 210, -- 478
		infoCenterY + 36, -- 478
		420, -- 478
		88, -- 478
		theme.accent, -- 478
		0.22, -- 478
		-1 -- 478
	) -- 478
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 481
	texts:put( -- 482
		"xs", -- 482
		theme.volumeTagZh, -- 482
		infoX, -- 482
		winY + winH - 44, -- 482
		toColor(volCol), -- 482
		0, -- 482
		0.5, -- 482
		"Left", -- 482
		2.8, -- 482
		0.92, -- 482
		0.08 -- 482
	) -- 482
	local sep = " · " -- 485
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 486
	local titleY = winY + winH - 98 -- 487
	if theme.backdropKey ~= nil then -- 487
		texts:put( -- 489
			"lg", -- 489
			theme.titleZh, -- 489
			infoX, -- 489
			titleY, -- 489
			toColor(PALETTE.textBright) -- 489
		) -- 489
	elseif sIdx > 0 then -- 489
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 491
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 492
		local lw = visualTextWidth(leftPart, 40) -- 493
		texts:put( -- 494
			"banner", -- 494
			leftPart, -- 494
			infoX, -- 494
			titleY, -- 494
			toColor(PALETTE.textBright), -- 494
			0, -- 494
			0.5, -- 494
			"Left", -- 494
			2, -- 494
			1, -- 494
			0.1 -- 494
		) -- 494
		drawBlossomDot( -- 495
			uiInkDraw, -- 495
			uiArt, -- 495
			"chap_title_dot", -- 495
			infoX + lw + 16, -- 495
			titleY - 2, -- 495
			11, -- 495
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 495
			0.9, -- 495
			4 -- 495
		) -- 495
		texts:put( -- 496
			"banner", -- 496
			rightPart, -- 496
			infoX + lw + 32, -- 496
			titleY, -- 496
			toColor(PALETTE.textBright), -- 496
			0, -- 496
			0.5, -- 496
			"Left", -- 496
			2, -- 496
			1, -- 496
			0.1 -- 496
		) -- 496
	else -- 496
		texts:put( -- 498
			"banner", -- 498
			theme.titleZh, -- 498
			infoX, -- 498
			titleY, -- 498
			toColor(PALETTE.textBright), -- 498
			0, -- 498
			0.5, -- 498
			"Left", -- 498
			2.4, -- 498
			1, -- 498
			0.1 -- 498
		) -- 498
	end -- 498
	drawHairline( -- 501
		uiInkDraw, -- 501
		uiArt, -- 501
		"chap_info_line", -- 501
		infoX + 185, -- 501
		titleY - 36, -- 501
		370, -- 501
		PALETTE.silkDim, -- 501
		0.58, -- 501
		false, -- 501
		2 -- 501
	) -- 501
	texts:put( -- 504
		"sm", -- 504
		theme.introWhisper, -- 504
		infoX, -- 504
		titleY - 72, -- 504
		toColor(PALETTE.textMid), -- 504
		0, -- 504
		0.5, -- 504
		"Left", -- 504
		0.8, -- 504
		0.94, -- 504
		0.08 -- 504
	) -- 504
	local goX = infoX -- 507
	local goY = winY + 26 -- 508
	local goW = 220 -- 509
	local goH = 42 -- 510
	local goBox = Rect(goX, goY, goW, goH) -- 511
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 512
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 513
	drawSilkRibbon( -- 514
		uiDraw, -- 514
		uiArt, -- 514
		"chap_go_rib", -- 514
		goX + 106, -- 514
		goY + 21, -- 514
		250, -- 514
		40, -- 514
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 514
		(goHover and 0.68 or 0.46) * breathe, -- 514
		0 -- 514
	) -- 514
	drawHairline( -- 515
		uiInkDraw, -- 515
		uiArt, -- 515
		"chap_go_line", -- 515
		goX + 94, -- 515
		goY + 3, -- 515
		196, -- 515
		PALETTE.silkLine, -- 515
		goHover and 0.68 or 0.4, -- 515
		false, -- 515
		2 -- 515
	) -- 515
	drawBlossomDot( -- 516
		uiInkDraw, -- 516
		uiArt, -- 516
		"chap_go_dot", -- 516
		goX + 14, -- 516
		goY + 21, -- 516
		14, -- 516
		PALETTE.rouge, -- 516
		0.96, -- 516
		4 -- 516
	) -- 516
	texts:put( -- 517
		"md", -- 517
		"入此卷章", -- 517
		goX + 34, -- 517
		goY + 21, -- 517
		toColor(PALETTE.textBright), -- 517
		0, -- 517
		0.5, -- 517
		"Left", -- 517
		3.8, -- 517
		1, -- 517
		0.1 -- 517
	) -- 517
	texts:put( -- 518
		"xs", -- 518
		"Enter", -- 518
		goX + 156, -- 518
		goY + 21, -- 518
		toColor(PALETTE.textDim), -- 518
		0, -- 518
		0.5, -- 518
		"Left", -- 518
		1, -- 518
		0.82, -- 518
		0.08 -- 518
	) -- 518
	drawSilkVeil( -- 521
		uiDraw, -- 521
		uiArt, -- 521
		"chap_track_veil", -- 521
		w * 0.5, -- 521
		trackY + 6, -- 521
		w - marginX * 1.1, -- 521
		126, -- 521
		PALETTE.inkWash, -- 521
		0.72, -- 521
		-2 -- 521
	) -- 521
	drawMistCurve( -- 522
		uiArt, -- 522
		"chap_track_mist", -- 522
		w * 0.5, -- 522
		trackY, -- 522
		trackX1 - trackX0 + 160, -- 522
		74, -- 522
		PALETTE.inkMist, -- 522
		0.62, -- 522
		-1 -- 522
	) -- 522
	uiInkDraw:drawSegment( -- 523
		Vec2(trackX0, trackY), -- 523
		Vec2(trackX1, trackY), -- 523
		0.9, -- 523
		toColor(PALETTE.silkDim, 145) -- 523
	) -- 523
	if splitTrack then -- 523
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 526
		uiInkDraw:drawSegment( -- 527
			Vec2(trackX0, trackY - rowGap), -- 527
			Vec2(lastX, trackY - rowGap), -- 527
			0.9, -- 527
			toColor(PALETTE.silkDim, 145) -- 527
		) -- 527
	else -- 527
		local midDivX = trackX0 + stepX * 3.5 -- 529
		uiInkDraw:drawSegment( -- 530
			Vec2(midDivX, trackY - 12), -- 530
			Vec2(midDivX, trackY + 12), -- 530
			0.8, -- 530
			toColor(PALETTE.silkDim, 120) -- 530
		) -- 530
		texts:put( -- 531
			"xs", -- 531
			"上卷 · 孤城护童", -- 531
			trackX0 + stepX * 1.5, -- 531
			trackY + 52, -- 531
			toColor(PALETTE.cyan), -- 531
			0.5, -- 531
			0.5, -- 531
			"Center", -- 531
			2.2, -- 531
			0.88, -- 531
			0.08 -- 531
		) -- 531
		texts:put( -- 532
			"xs", -- 532
			"下卷 · 独赴北塔", -- 532
			trackX0 + stepX * 5.5, -- 532
			trackY + 52, -- 532
			toColor(PALETTE.amber), -- 532
			0.5, -- 532
			0.5, -- 532
			"Center", -- 532
			2.2, -- 532
			0.88, -- 532
			0.08 -- 532
		) -- 532
	end -- 532
	local i = 0 -- 535
	do -- 535
		i = 0 -- 536
		while i < #CHAPTERS do -- 536
			local box = stationBoxes[i + 1] -- 537
			local sx = box.x + box.width * 0.5 -- 538
			local sy = box.y + box.height * 0.5 -- 539
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 540
			local active = self.chapterSelected == i -- 541
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 542
			if active then -- 542
				fillRadialGlow( -- 545
					uiGlow, -- 545
					sx, -- 545
					sy, -- 545
					26, -- 545
					26, -- 545
					toColor(PALETTE.rouge, 36 * breathe), -- 545
					Color(182, 58, 56, 0), -- 545
					12 -- 545
				) -- 545
				uiArt:tryPlace( -- 546
					"ink_enso_fine", -- 546
					"chap_st_ring_" .. tostring(i), -- 546
					sx, -- 546
					sy, -- 546
					32, -- 546
					32, -- 546
					{ -- 546
						color = toColor(PALETTE.silkLine), -- 547
						opacity = 0.78, -- 547
						angle = self.time * 18, -- 547
						layer = 3 -- 547
					} -- 547
				) -- 547
				drawBlossomDot( -- 549
					uiInkDraw, -- 549
					uiArt, -- 549
					"chap_st_dot_" .. tostring(i), -- 549
					sx, -- 549
					sy, -- 549
					17, -- 549
					PALETTE.rouge, -- 549
					0.98, -- 549
					4 -- 549
				) -- 549
			else -- 549
				uiArt:tryPlace( -- 551
					"ink_enso_fine", -- 551
					"chap_st_ring_" .. tostring(i), -- 551
					sx, -- 551
					sy, -- 551
					16, -- 551
					16, -- 551
					{ -- 551
						color = toColor(nodeCol), -- 552
						opacity = 0.62, -- 552
						layer = 3 -- 552
					} -- 552
				) -- 552
				drawBlossomDot( -- 554
					uiInkDraw, -- 554
					uiArt, -- 554
					"chap_st_dot_" .. tostring(i), -- 554
					sx, -- 554
					sy, -- 554
					7, -- 554
					PALETTE.silkLine, -- 554
					0.72, -- 554
					4 -- 554
				) -- 554
			end -- 554
			if not splitTrack then -- 554
				texts:put( -- 558
					"xs", -- 558
					rt.numeralZh, -- 558
					sx, -- 558
					sy + 25, -- 558
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 558
					0.5, -- 558
					0.5, -- 558
					"Center", -- 558
					0, -- 558
					active and 1 or 0.88, -- 558
					0.08 -- 558
				) -- 558
			end -- 558
			texts:put( -- 560
				"xs", -- 560
				rt.shortNameZh, -- 560
				sx, -- 560
				sy - 26, -- 560
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 560
				0.5, -- 560
				0.5, -- 560
				"Center", -- 560
				1, -- 560
				active and 1 or 0.84, -- 560
				0.08 -- 560
			) -- 560
			i = i + 1 -- 536
		end -- 536
	end -- 536
	local backX = marginX -- 564
	local backY = 40 -- 565
	local backBox = Rect(backX, backY, 190, 34) -- 566
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 567
	drawSilkKeycap( -- 568
		uiInkDraw, -- 568
		texts, -- 568
		backX, -- 568
		backY + 5, -- 568
		44, -- 568
		24, -- 568
		"ESC", -- 568
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 568
		0.92, -- 568
		backHover -- 568
	) -- 568
	texts:put( -- 569
		"sm", -- 569
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 569
		backX + 56, -- 569
		backY + 17, -- 569
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 569
		0, -- 569
		0.5, -- 569
		"Left", -- 569
		1.8, -- 569
		0.9, -- 569
		0.08 -- 569
	) -- 569
	texts:put( -- 570
		"xs", -- 570
		"方向键选择   ·   回车或点击进入", -- 570
		w - marginX, -- 570
		backY + 17, -- 570
		toColor(PALETTE.textDim), -- 570
		1, -- 570
		0.5, -- 570
		"Right", -- 570
		1.2, -- 570
		0.75, -- 570
		0.08 -- 570
	) -- 570
	if frame.click and backHover then -- 570
		return back -- 573
	end -- 573
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 573
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 576
	end -- 576
	return {type = "none"} -- 578
end -- 392
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 584
	if backLabel == nil then -- 584
		backLabel = "返回标题" -- 593
	end -- 593
	local marginX = 96 -- 595
	local backX = marginX -- 596
	local backY = 40 -- 597
	local backBox = Rect(backX, backY, 230, 34) -- 598
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 599
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 599
		return {type = "backTitle"} -- 601
	end -- 601
	uiDraw:drawRect( -- 603
		Rect(0, 0, w, h), -- 603
		Color(10, 12, 19, 204) -- 603
	) -- 603
	texts:put( -- 605
		"banner", -- 605
		"执器要诀", -- 605
		marginX, -- 605
		h - 66, -- 605
		toColor(PALETTE.textBright), -- 605
		0, -- 605
		0.5, -- 605
		"Left", -- 605
		4.5, -- 605
		0.96, -- 605
		0.1 -- 605
	) -- 605
	texts:put( -- 606
		"xs", -- 606
		"键鼠操作说明", -- 606
		marginX + 196, -- 606
		h - 70, -- 606
		toColor(PALETTE.textDim), -- 606
		0, -- 606
		0.5, -- 606
		"Left", -- 606
		2, -- 606
		0.85, -- 606
		0.08 -- 606
	) -- 606
	drawHairline( -- 607
		uiInkDraw, -- 607
		uiArt, -- 607
		"ctrl_top_line", -- 607
		w * 0.5, -- 607
		h - 100, -- 607
		w - marginX * 2, -- 607
		PALETTE.silkDim, -- 607
		0.6, -- 607
		true, -- 607
		2 -- 607
	) -- 607
	local areaY = 114 -- 610
	local areaH = h - 244 -- 611
	drawFiligreeCorners( -- 612
		uiInkDraw, -- 612
		uiArt, -- 612
		"ctrl_outer", -- 612
		marginX, -- 612
		areaY, -- 612
		w - marginX * 2, -- 612
		areaH, -- 612
		PALETTE.silkDim, -- 612
		0.52, -- 612
		34, -- 612
		false, -- 612
		2 -- 612
	) -- 612
	local midX = w * 0.5 -- 615
	uiArt:tryPlace( -- 616
		"ink_vstream", -- 616
		"ctrl_mid_stream", -- 616
		midX, -- 616
		areaY + areaH * 0.5, -- 616
		32, -- 616
		areaH - 18, -- 616
		{ -- 616
			color = toColor(PALETTE.silkDim), -- 617
			opacity = 0.52, -- 617
			layer = 1 -- 617
		} -- 617
	) -- 617
	drawBlossomDot( -- 619
		uiInkDraw, -- 619
		uiArt, -- 619
		"ctrl_mid_dot", -- 619
		midX, -- 619
		areaY + areaH * 0.5, -- 619
		11, -- 619
		PALETTE.silkLine, -- 619
		0.62, -- 619
		3 -- 619
	) -- 619
	local leftColX = marginX + 34 -- 622
	local colW = midX - leftColX - 42 -- 623
	local headY = areaY + areaH - 34 -- 624
	drawBlossomDot( -- 625
		uiInkDraw, -- 625
		uiArt, -- 625
		"ctrl_l_dot", -- 625
		leftColX + 8, -- 625
		headY, -- 625
		12, -- 625
		PALETTE.cyan, -- 625
		0.88, -- 625
		3 -- 625
	) -- 625
	texts:put( -- 626
		"md", -- 626
		"周戍 · 护送与交锋", -- 626
		leftColX + 26, -- 626
		headY, -- 626
		toColor(PALETTE.cyanCore), -- 626
		0, -- 626
		0.5, -- 626
		"Left", -- 626
		2.4, -- 626
		0.98, -- 626
		0.08 -- 626
	) -- 626
	drawHairline( -- 627
		uiInkDraw, -- 627
		uiArt, -- 627
		"ctrl_l_line", -- 627
		leftColX + colW * 0.5, -- 627
		headY - 24, -- 627
		colW, -- 627
		PALETTE.cyanDim, -- 627
		0.58, -- 627
		false, -- 627
		2 -- 627
	) -- 627
	local sRows = { -- 629
		{"WASD / 方向键", "左右、前后自由移动"}, -- 630
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 631
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 632
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 633
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 634
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 635
	} -- 635
	local i = 0 -- 637
	do -- 637
		i = 0 -- 638
		while i < #sRows do -- 638
			local ry = headY - 66 - i * 52 -- 639
			drawSilkKeycap( -- 640
				uiInkDraw, -- 640
				texts, -- 640
				leftColX + 2, -- 640
				ry - 13, -- 640
				132, -- 640
				26, -- 640
				sRows[i + 1][1], -- 640
				PALETTE.cyan, -- 640
				0.92, -- 640
				false -- 640
			) -- 640
			texts:put( -- 641
				"sm", -- 641
				sRows[i + 1][2], -- 641
				leftColX + 150, -- 641
				ry, -- 641
				toColor(PALETTE.textBright), -- 641
				0, -- 641
				0.5, -- 641
				"Left", -- 641
				0.8, -- 641
				0.92, -- 641
				0.08 -- 641
			) -- 641
			i = i + 1 -- 638
		end -- 638
	end -- 638
	local rightColX = midX + 44 -- 645
	drawBlossomDot( -- 646
		uiInkDraw, -- 646
		uiArt, -- 646
		"ctrl_r_dot", -- 646
		rightColX + 8, -- 646
		headY, -- 646
		12, -- 646
		PALETTE.amber, -- 646
		0.88, -- 646
		3 -- 646
	) -- 646
	texts:put( -- 647
		"md", -- 647
		"小满 · 潜行与寻路", -- 647
		rightColX + 26, -- 647
		headY, -- 647
		toColor(PALETTE.amberCore), -- 647
		0, -- 647
		0.5, -- 647
		"Left", -- 647
		2.4, -- 647
		0.98, -- 647
		0.08 -- 647
	) -- 647
	drawHairline( -- 648
		uiInkDraw, -- 648
		uiArt, -- 648
		"ctrl_r_line", -- 648
		rightColX + colW * 0.5, -- 648
		headY - 24, -- 648
		colW, -- 648
		PALETTE.amberDim, -- 648
		0.58, -- 648
		false, -- 648
		2 -- 648
	) -- 648
	local cRows = { -- 650
		{"A / D · ← / →", "左右潜行"}, -- 651
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 652
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 653
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 654
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 655
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 656
	} -- 656
	do -- 656
		i = 0 -- 658
		while i < #cRows do -- 658
			local ry = headY - 66 - i * 52 -- 659
			drawSilkKeycap( -- 660
				uiInkDraw, -- 660
				texts, -- 660
				rightColX + 2, -- 660
				ry - 13, -- 660
				132, -- 660
				26, -- 660
				cRows[i + 1][1], -- 660
				PALETTE.amber, -- 660
				0.92, -- 660
				false -- 660
			) -- 660
			texts:put( -- 661
				"sm", -- 661
				cRows[i + 1][2], -- 661
				rightColX + 150, -- 661
				ry, -- 661
				toColor(PALETTE.textBright), -- 661
				0, -- 661
				0.5, -- 661
				"Left", -- 661
				0.8, -- 661
				0.92, -- 661
				0.08 -- 661
			) -- 661
			i = i + 1 -- 658
		end -- 658
	end -- 658
	drawSilkKeycap( -- 665
		uiInkDraw, -- 665
		texts, -- 665
		backX, -- 665
		backY + 5, -- 665
		110, -- 665
		24, -- 665
		"ESC / ENTER", -- 665
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 665
		0.92, -- 665
		backHover -- 665
	) -- 665
	texts:put( -- 666
		"sm", -- 666
		backLabel, -- 666
		backX + 122, -- 666
		backY + 17, -- 666
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 666
		0, -- 666
		0.5, -- 666
		"Left", -- 666
		1.8, -- 666
		0.92, -- 666
		0.08 -- 666
	) -- 666
	texts:put( -- 667
		"xs", -- 667
		"F11 / Alt+Enter 切换全屏", -- 667
		w - marginX, -- 667
		backY + 17, -- 667
		toColor(PALETTE.textDim), -- 667
		1, -- 667
		0.5, -- 667
		"Right", -- 667
		1.2, -- 667
		0.78, -- 667
		0.08 -- 667
	) -- 667
	return {type = "none"} -- 669
end -- 584
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist) -- 676
	if assistHintsEnabled == nil then -- 676
		assistHintsEnabled = false -- 687
	end -- 687
	self.time = self.time + dt -- 690
	local frame = self:readFrame(input, uiScale) -- 691
	if self.pauseShowControls then -- 691
		local ctrlAct = self:drawControls( -- 695
			frame, -- 695
			uiDraw, -- 695
			uiInkDraw, -- 695
			uiArt, -- 695
			uiGlow, -- 695
			texts, -- 695
			w, -- 695
			h, -- 695
			"返回暂停" -- 695
		) -- 695
		if ctrlAct.type == "backTitle" then -- 695
			self.pauseShowControls = false -- 697
			self:resetInput() -- 698
		end -- 698
		return {type = "none"} -- 700
	end -- 700
	if frame.back then -- 700
		self.pauseShowControls = false -- 704
		return {type = "resume"} -- 705
	end -- 705
	uiDraw:drawRect( -- 709
		Rect(0, 0, w, h), -- 709
		Color(8, 10, 16, 102) -- 709
	) -- 709
	fillHGradRect( -- 710
		uiDraw, -- 710
		0, -- 710
		0, -- 710
		w * 0.27, -- 710
		h, -- 710
		Color(9, 11, 18, 232), -- 710
		Color(10, 13, 21, 198) -- 710
	) -- 710
	fillHGradRect( -- 711
		uiDraw, -- 711
		w * 0.27, -- 711
		0, -- 711
		w * 0.21, -- 711
		h, -- 711
		Color(10, 13, 21, 198), -- 711
		Color(10, 13, 21, 0) -- 711
	) -- 711
	local menuX = 110 -- 714
	uiArt:tryPlace( -- 715
		"ink_vstream", -- 715
		"pause_vstream", -- 715
		menuX - 32, -- 715
		h * 0.5, -- 715
		34, -- 715
		h * 0.78, -- 715
		{ -- 715
			color = toColor(PALETTE.silkDim), -- 716
			opacity = 0.48, -- 716
			layer = 1 -- 716
		} -- 716
	) -- 716
	drawMistCurve( -- 718
		uiArt, -- 718
		"pause_mist", -- 718
		menuX + 118, -- 718
		h - 154, -- 718
		290, -- 718
		72, -- 718
		PALETTE.jadeMist, -- 718
		0.2, -- 718
		-1 -- 718
	) -- 718
	texts:put( -- 721
		"banner", -- 721
		"暂歇", -- 721
		menuX + 16, -- 721
		h - 146, -- 721
		toColor(PALETTE.textBright), -- 721
		0, -- 721
		0.5, -- 721
		"Left", -- 721
		10, -- 721
		0.98, -- 721
		0.1 -- 721
	) -- 721
	texts:put( -- 722
		"xs", -- 722
		"月夜暂驻 · 卷页留痕", -- 722
		menuX + 18, -- 722
		h - 184, -- 722
		toColor(PALETTE.textDim), -- 722
		0, -- 722
		0.5, -- 722
		"Left", -- 722
		2, -- 722
		0.8, -- 722
		0.08 -- 722
	) -- 722
	drawHairline( -- 723
		uiInkDraw, -- 723
		uiArt, -- 723
		"pause_div", -- 723
		menuX + 124, -- 723
		h - 210, -- 723
		240, -- 723
		PALETTE.silkDim, -- 723
		0.58, -- 723
		true, -- 723
		2 -- 723
	) -- 723
	local boxes = {} -- 725
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #PAUSE_ITEMS do -- 727
			boxes[#boxes + 1] = Rect(menuX - 10, h - 266 - i * 46, 270, 38) -- 728
			i = i + 1 -- 727
		end -- 727
	end -- 727
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 730
	do -- 730
		i = 0 -- 732
		while i < #PAUSE_ITEMS do -- 732
			local iy = boxes[i + 1].y -- 733
			local active = self.pauseSelected == i -- 734
			local cy = iy + 19 -- 735
			local shiftX = active and 10 or 0 -- 736
			local item = PAUSE_ITEMS[i + 1] -- 737
			local label = item.id == "assist" and (assistHintsEnabled and "按键辅助：开" or "按键辅助：关") or (item.id == "fullscreen" and (App.fullScreen and "显示：全屏" or "显示：窗口") or item.zh) -- 738
			if active then -- 738
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 745
				drawSilkRibbon( -- 746
					uiDraw, -- 746
					uiArt, -- 746
					"pause_rib_" .. tostring(i), -- 746
					menuX + 116, -- 746
					cy, -- 746
					276, -- 746
					38, -- 746
					PALETTE.rougeSoft, -- 746
					0.54 * breathe, -- 746
					0 -- 746
				) -- 746
				drawHairline( -- 747
					uiInkDraw, -- 747
					uiArt, -- 747
					"pause_line_" .. tostring(i), -- 747
					menuX + 106, -- 747
					iy + 3, -- 747
					210, -- 747
					PALETTE.silkLine, -- 747
					0.42 * breathe, -- 747
					false, -- 747
					2 -- 747
				) -- 747
				drawBlossomDot( -- 748
					uiInkDraw, -- 748
					uiArt, -- 748
					"pause_dot_" .. tostring(i), -- 748
					menuX + 12, -- 748
					cy, -- 748
					15, -- 748
					PALETTE.rouge, -- 748
					0.96, -- 748
					4 -- 748
				) -- 748
				fillRadialGlow( -- 749
					uiGlow, -- 749
					menuX + 12, -- 749
					cy, -- 749
					22, -- 749
					16, -- 749
					toColor(PALETTE.rouge, 26 * breathe), -- 749
					Color(182, 58, 56, 0), -- 749
					10 -- 749
				) -- 749
			else -- 749
				drawBlossomDot( -- 751
					uiInkDraw, -- 751
					uiArt, -- 751
					"pause_dot_" .. tostring(i), -- 751
					menuX + 12, -- 751
					cy, -- 751
					8, -- 751
					PALETTE.silkDim, -- 751
					0.4, -- 751
					3 -- 751
				) -- 751
			end -- 751
			texts:put( -- 754
				"md", -- 755
				label, -- 756
				menuX + 32 + shiftX, -- 757
				cy, -- 758
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 759
				0, -- 760
				0.5, -- 761
				"Left", -- 762
				active and 3.8 or 2.4, -- 763
				active and 1 or 0.88, -- 764
				0.1 -- 765
			) -- 765
			i = i + 1 -- 732
		end -- 732
	end -- 732
	texts:put( -- 769
		"xs", -- 769
		"Esc 续行   ·   Enter 或点击确认", -- 769
		menuX + 12, -- 769
		56, -- 769
		toColor(PALETTE.textDim), -- 769
		0, -- 769
		0.5, -- 769
		"Left", -- 769
		1.2, -- 769
		0.86, -- 769
		0.08 -- 769
	) -- 769
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 771
	if hit >= 0 or frame.keys.confirm then -- 771
		local idx = hit >= 0 and hit or self.pauseSelected -- 773
		local id = PAUSE_ITEMS[idx + 1].id -- 774
		if id == "controls" then -- 774
			self.pauseShowControls = true -- 776
			self:resetInput() -- 777
			return {type = "none"} -- 778
		end -- 778
		if id == "assist" then -- 778
			if onToggleAssist ~= nil then -- 778
				onToggleAssist() -- 782
			end -- 782
			self:resetInput() -- 784
			return {type = "none"} -- 785
		end -- 785
		if id == "fullscreen" then -- 785
			self:resetInput() -- 788
			return {type = "toggleFullscreen"} -- 789
		end -- 789
		self.pauseShowControls = false -- 791
		if id == "resume" then -- 791
			return {type = "resume"} -- 793
		end -- 793
		if id == "retry" then -- 793
			return {type = "retry"} -- 796
		end -- 796
		if id == "chapters" then -- 796
			return {type = "openChapters"} -- 799
		end -- 799
		if id == "quit" then -- 799
			return {type = "quit"} -- 802
		end -- 802
		return {type = "toTitle"} -- 804
	end -- 804
	return {type = "none"} -- 806
end -- 676
return ____exports -- 676