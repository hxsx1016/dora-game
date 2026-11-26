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
	self.chaptersFromPause = false -- 108
	self.pauseShowControls = false -- 110
	self.previousKeys = {} -- 111
	self.queuedKeys = {} -- 112
	self.queuedBack = false -- 113
	self.time = 0 -- 114
end -- 104
function MenuRenderer.prototype.isShowingPauseControls(self) -- 116
	return self.pauseShowControls -- 117
end -- 116
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 120
	self.chaptersFromPause = roomIndex ~= nil -- 121
	self.chapterSelected = math.max( -- 122
		0, -- 122
		__TS__ArrayFindIndex( -- 122
			CHAPTERS, -- 122
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 122
		) -- 122
	) -- 122
	self.pauseShowControls = false -- 123
	self:resetInput() -- 124
end -- 120
function MenuRenderer.prototype.openPause(self) -- 127
	self.pauseSelected = 0 -- 128
	self.pauseShowControls = false -- 129
	self:resetInput() -- 130
end -- 127
function MenuRenderer.prototype.resetInput(self) -- 134
	self.previousKeys = pressedKeys() -- 135
	self.queuedKeys = {} -- 136
	self.queuedBack = false -- 137
end -- 134
function MenuRenderer.prototype.onKeyEvent(self, key) -- 141
	if key == "Up" or key == "W" then -- 141
		self.queuedKeys.up = true -- 143
	elseif key == "Down" or key == "S" then -- 143
		self.queuedKeys.down = true -- 145
	elseif key == "Left" or key == "A" then -- 145
		self.queuedKeys.left = true -- 147
	elseif key == "Right" or key == "D" then -- 147
		self.queuedKeys.right = true -- 149
	elseif key == "Return" or key == "Space" then -- 149
		self.queuedKeys.confirm = true -- 151
	elseif key == "Escape" then -- 151
		self.queuedBack = true -- 153
	end -- 153
end -- 141
function MenuRenderer.prototype.readFrame(self, input, scale) -- 157
	local held = pressedKeys() -- 158
	local prev = self.previousKeys -- 159
	local queued = self.queuedKeys -- 160
	local frame = { -- 161
		keys = { -- 162
			up = queued.up == true or held.up and not prev.up, -- 163
			down = queued.down == true or held.down and not prev.down, -- 164
			left = queued.left == true or held.left and not prev.left, -- 165
			right = queued.right == true or held.right and not prev.right, -- 166
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 167
		}, -- 167
		back = self.queuedBack or input.pause.pressed, -- 169
		pointer = Vec2(input.mx / scale, input.my / scale), -- 170
		inside = input.inside, -- 171
		click = input.inside and input.fire.pressed, -- 172
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 173
	} -- 173
	self.previousKeys = held -- 175
	self.queuedKeys = {} -- 176
	self.queuedBack = false -- 177
	return frame -- 178
end -- 157
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 181
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 182
	if frame.click and hit >= 0 then -- 182
		return hit -- 184
	end -- 184
	if frame.keys.up then -- 184
		return (selected + #boxes - 1) % #boxes -- 187
	end -- 187
	if frame.keys.down then -- 187
		return (selected + 1) % #boxes -- 190
	end -- 190
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 192
end -- 181
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 195
	self.time = self.time + dt -- 212
	local artW = math.max(w, h * 16 / 9) -- 213
	local artH = artW * 9 / 16 -- 214
	if not backdropArt:tryPlace( -- 214
		"title_backdrop", -- 215
		"menu_landscape", -- 215
		w * 0.5, -- 215
		(h - artH) * 0.5, -- 215
		artW, -- 215
		artH -- 215
	) then -- 215
		stage:drawMenuBackdrop( -- 216
			bgDraw, -- 216
			bgGlow, -- 216
			w, -- 216
			h, -- 216
			self.time -- 216
		) -- 216
	end -- 216
	local frame = self:readFrame(input, uiScale) -- 219
	w = w / uiScale -- 220
	h = h / uiScale -- 221
	if screen == "title" then -- 221
		return self:drawTitle( -- 224
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
	if screen == "chapters" then -- 224
		return self:drawChapters( -- 227
			frame, -- 227
			uiDraw, -- 227
			uiInkDraw, -- 227
			uiArt, -- 227
			uiGlow, -- 227
			texts, -- 227
			w, -- 227
			h -- 227
		) -- 227
	end -- 227
	return self:drawControls( -- 229
		frame, -- 229
		uiDraw, -- 229
		uiInkDraw, -- 229
		uiArt, -- 229
		uiGlow, -- 229
		texts, -- 229
		w, -- 229
		h -- 229
	) -- 229
end -- 195
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 232
	fillHGradRect( -- 243
		uiDraw, -- 243
		0, -- 243
		0, -- 243
		w * 0.22, -- 243
		h, -- 243
		Color(9, 11, 18, 192), -- 243
		Color(9, 11, 18, 116) -- 243
	) -- 243
	fillHGradRect( -- 244
		uiDraw, -- 244
		w * 0.22, -- 244
		0, -- 244
		w * 0.28, -- 244
		h, -- 244
		Color(9, 11, 18, 116), -- 244
		Color(9, 11, 18, 0) -- 244
	) -- 244
	fillVGradRect( -- 245
		uiDraw, -- 245
		0, -- 245
		0, -- 245
		w, -- 245
		78, -- 245
		Color(8, 10, 16, 138), -- 245
		Color(8, 10, 16, 0) -- 245
	) -- 245
	local titleX = 148 -- 248
	local topY = h - 104 -- 249
	local charStep = 66 -- 250
	local sway = math.sin(self.time * 0.7) * 5 -- 251
	drawMistCurve( -- 252
		uiArt, -- 252
		"title_mist_wisp", -- 252
		titleX + 86 + sway, -- 252
		topY - 122, -- 252
		340, -- 252
		82, -- 252
		PALETTE.jadeMist, -- 252
		0.2, -- 252
		-1 -- 252
	) -- 252
	uiArt:tryPlace( -- 253
		"ink_petal_mist", -- 253
		"title_petals", -- 253
		titleX + 12, -- 253
		topY - 102, -- 253
		230, -- 253
		210, -- 253
		{ -- 253
			color = toColor(PALETTE.inkMist), -- 254
			opacity = 0.4, -- 254
			layer = -1 -- 254
		} -- 254
	) -- 254
	uiArt:tryPlace( -- 256
		"ink_vstream", -- 256
		"title_vstream", -- 256
		titleX - 48, -- 256
		topY - 100, -- 256
		34, -- 256
		290, -- 256
		{ -- 256
			color = toColor(PALETTE.silkDim), -- 257
			opacity = 0.48, -- 257
			layer = 1 -- 257
		} -- 257
	) -- 257
	local c = 0 -- 261
	do -- 261
		c = 0 -- 262
		while c < #VERTICAL_TITLE do -- 262
			texts:put( -- 263
				"title", -- 264
				VERTICAL_TITLE[c + 1], -- 265
				titleX, -- 266
				topY - c * charStep, -- 267
				toColor(PALETTE.textBright), -- 268
				0.5, -- 269
				0.5, -- 270
				"Center", -- 271
				0, -- 272
				0.98, -- 273
				0.1, -- 274
				Color(8, 10, 16, 210) -- 275
			) -- 275
			c = c + 1 -- 262
		end -- 262
	end -- 262
	drawLoneSeal( -- 280
		uiInkDraw, -- 281
		uiArt, -- 282
		texts, -- 283
		"title_lone_seal", -- 284
		titleX + 46, -- 285
		topY - 3 * charStep + 8, -- 286
		26, -- 287
		52, -- 288
		"守", -- 289
		"望", -- 290
		PALETTE.sealRed, -- 291
		PALETTE.sealText, -- 292
		0.94, -- 293
		4 -- 294
	) -- 294
	local colRightX = titleX + 132 -- 298
	local colLeftX = titleX + 102 -- 299
	local poemStep = 22 -- 300
	local p = 0 -- 301
	do -- 301
		p = 0 -- 302
		while p < #EPIGRAPH_RIGHT do -- 302
			local ch = EPIGRAPH_RIGHT[p + 1] -- 303
			if ch ~= "" then -- 303
				texts:put( -- 305
					"xs", -- 305
					ch, -- 305
					colRightX, -- 305
					topY - 22 - p * poemStep, -- 305
					toColor(PALETTE.textMid), -- 305
					0.5, -- 305
					0.5, -- 305
					"Center", -- 305
					0, -- 305
					0.86, -- 305
					0.08 -- 305
				) -- 305
			end -- 305
			p = p + 1 -- 302
		end -- 302
	end -- 302
	do -- 302
		p = 0 -- 308
		while p < #EPIGRAPH_LEFT do -- 308
			texts:put( -- 309
				"xs", -- 309
				EPIGRAPH_LEFT[p + 1], -- 309
				colLeftX, -- 309
				topY - 68 - p * poemStep, -- 309
				toColor(PALETTE.amberCore), -- 309
				0.5, -- 309
				0.5, -- 309
				"Center", -- 309
				0, -- 309
				0.9, -- 309
				0.08 -- 309
			) -- 309
			p = p + 1 -- 308
		end -- 308
	end -- 308
	local menuX = 112 -- 313
	local btnW = 280 -- 314
	local btnH = 40 -- 315
	local gap = 8 -- 316
	local startY = 264 -- 317
	local boxes = {} -- 318
	local i = 0 -- 319
	do -- 319
		i = 0 -- 320
		while i < #TITLE_ITEMS do -- 320
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 321
			i = i + 1 -- 320
		end -- 320
	end -- 320
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 323
	do -- 323
		i = 0 -- 325
		while i < #TITLE_ITEMS do -- 325
			local by = boxes[i + 1].y -- 326
			local active = self.selected == i -- 327
			local cy = by + btnH * 0.5 -- 328
			local shiftX = active and 10 or 0 -- 329
			if active then -- 329
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 332
				drawSilkRibbon( -- 333
					uiDraw, -- 333
					uiArt, -- 333
					"title_rib_red_" .. tostring(i), -- 333
					menuX + 124, -- 333
					cy, -- 333
					290, -- 333
					40, -- 333
					PALETTE.rougeSoft, -- 333
					0.52 * breathe, -- 333
					0 -- 333
				) -- 333
				drawHairline( -- 334
					uiInkDraw, -- 334
					uiArt, -- 334
					"title_rib_line_" .. tostring(i), -- 334
					menuX + 114, -- 334
					by + 4, -- 334
					230, -- 334
					PALETTE.silkLine, -- 334
					0.42 * breathe, -- 334
					false, -- 334
					2 -- 334
				) -- 334
				drawBlossomDot( -- 335
					uiInkDraw, -- 335
					uiArt, -- 335
					"title_dot_" .. tostring(i), -- 335
					menuX + 14, -- 335
					cy, -- 335
					16, -- 335
					PALETTE.rouge, -- 335
					0.96, -- 335
					4 -- 335
				) -- 335
				fillRadialGlow( -- 336
					uiGlow, -- 336
					menuX + 14, -- 336
					cy, -- 336
					22, -- 336
					16, -- 336
					toColor(PALETTE.rouge, 28 * breathe), -- 336
					Color(182, 58, 56, 0), -- 336
					10 -- 336
				) -- 336
			else -- 336
				drawBlossomDot( -- 338
					uiInkDraw, -- 338
					uiArt, -- 338
					"title_dot_" .. tostring(i), -- 338
					menuX + 14, -- 338
					cy, -- 338
					8, -- 338
					PALETTE.silkDim, -- 338
					0.4, -- 338
					3 -- 338
				) -- 338
			end -- 338
			texts:put( -- 341
				"md", -- 342
				TITLE_ITEMS[i + 1].zh, -- 343
				menuX + 34 + shiftX, -- 344
				cy, -- 345
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 346
				0, -- 347
				0.5, -- 348
				"Left", -- 349
				active and 4.4 or 2.8, -- 350
				active and 1 or 0.88, -- 351
				0.1 -- 352
			) -- 352
			i = i + 1 -- 325
		end -- 325
	end -- 325
	texts:put( -- 356
		"xs", -- 356
		"上下择项   ·   回车或点选启程", -- 356
		menuX + 12, -- 356
		42, -- 356
		toColor(PALETTE.textDim), -- 356
		0, -- 356
		0.5, -- 356
		"Left", -- 356
		1.4, -- 356
		0.88, -- 356
		0.08 -- 356
	) -- 356
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 358
	if hit >= 0 or frame.keys.confirm then -- 358
		local idx = hit >= 0 and hit or self.selected -- 360
		local id = TITLE_ITEMS[idx + 1].id -- 361
		if id == "trial" then -- 361
			return {type = "trial"} -- 362
		end -- 362
		if id == "start" then -- 362
			return {type = "start"} -- 364
		end -- 364
		if id == "chapters" then -- 364
			return {type = "openChapters"} -- 367
		end -- 367
		if id == "quit" then -- 367
			return {type = "quit"} -- 370
		end -- 370
		return {type = "openControls"} -- 372
	end -- 372
	return {type = "none"} -- 374
end -- 232
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 381
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 391
	if frame.back then -- 391
		return back -- 393
	end -- 393
	local marginX = 96 -- 396
	local splitTrack = #CHAPTERS > 8 -- 397
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 398
	local trackY = splitTrack and 195 or 148 -- 399
	local rowGap = 84 -- 400
	local trackX0 = marginX + 34 -- 401
	local trackX1 = w - marginX - 34 -- 402
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 403
	local stationBoxes = {} -- 405
	local s = 0 -- 406
	do -- 406
		s = 0 -- 407
		while s < #CHAPTERS do -- 407
			local sx = trackX0 + s % perRow * stepX -- 408
			local sy = trackY - math.floor(s / perRow) * rowGap -- 409
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74) -- 410
			s = s + 1 -- 407
		end -- 407
	end -- 407
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 413
	local keys = frame.keys -- 414
	if frame.click and hitStation >= 0 then -- 414
		self.chapterSelected = hitStation -- 416
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 416
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 418
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 419
	elseif keys.down and self.chapterSelected < perRow then -- 419
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 421
	elseif keys.up and self.chapterSelected >= perRow then -- 421
		self.chapterSelected = self.chapterSelected - perRow -- 423
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 423
		self.chapterSelected = hitStation -- 425
	end -- 425
	uiDraw:drawRect( -- 429
		Rect(0, 0, w, h), -- 429
		Color(10, 12, 19, 198) -- 429
	) -- 429
	texts:put( -- 432
		"banner", -- 432
		"选择章节", -- 432
		marginX, -- 432
		h - 66, -- 432
		toColor(PALETTE.textBright), -- 432
		0, -- 432
		0.5, -- 432
		"Left", -- 432
		4.5, -- 432
		0.96, -- 432
		0.1 -- 432
	) -- 432
	drawHairline( -- 433
		uiInkDraw, -- 433
		uiArt, -- 433
		"chap_top_line", -- 433
		w * 0.5, -- 433
		h - 100, -- 433
		w - marginX * 2, -- 433
		PALETTE.silkDim, -- 433
		0.6, -- 433
		true, -- 433
		2 -- 433
	) -- 433
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 436
	local theme = themeOf(activeRoom.key) -- 437
	local winX = marginX -- 438
	local winY = 266 -- 439
	local winW = 548 -- 440
	local winH = 300 -- 441
	local winBox = Rect(winX, winY, winW, winH) -- 442
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 443
	uiArt:tryPlace( -- 446
		"ink_frame_mask", -- 446
		"chap_win_shadow", -- 446
		winX + winW * 0.5, -- 446
		winY + winH * 0.5, -- 446
		winW + 40, -- 446
		winH + 34, -- 446
		{ -- 446
			color = toColor(PALETTE.inkVoid), -- 447
			opacity = 0.88, -- 447
			layer = -2 -- 447
		} -- 447
	) -- 447
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 449
	uiArt:tryPlace( -- 450
		bgSlot, -- 450
		"chap_win_art", -- 450
		winX + winW * 0.5, -- 450
		winY + 4, -- 450
		winW - 8, -- 450
		winH - 8, -- 450
		{opacity = 0.92, layer = -1} -- 450
	) -- 450
	fillVGradRect( -- 454
		uiInkDraw, -- 454
		winX, -- 454
		winY, -- 454
		winW, -- 454
		56, -- 454
		Color(10, 12, 19, 200), -- 454
		Color(10, 12, 19, 0) -- 454
	) -- 454
	fillVGradRect( -- 455
		uiInkDraw, -- 455
		winX, -- 455
		winY + winH - 36, -- 455
		winW, -- 455
		36, -- 455
		Color(10, 12, 19, 0), -- 455
		Color(10, 12, 19, 130) -- 455
	) -- 455
	fillHGradRect( -- 456
		uiInkDraw, -- 456
		winX, -- 456
		winY, -- 456
		34, -- 456
		winH, -- 456
		Color(10, 12, 19, 135), -- 456
		Color(10, 12, 19, 0) -- 456
	) -- 456
	fillHGradRect( -- 457
		uiInkDraw, -- 457
		winX + winW - 34, -- 457
		winY, -- 457
		34, -- 457
		winH, -- 457
		Color(10, 12, 19, 0), -- 457
		Color(10, 12, 19, 135) -- 457
	) -- 457
	drawFiligreeCorners( -- 459
		uiInkDraw, -- 459
		uiArt, -- 459
		"chap_win_frame", -- 459
		winX, -- 459
		winY, -- 459
		winW, -- 459
		winH, -- 459
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 459
		winHover and 0.92 or 0.72, -- 459
		34, -- 459
		true, -- 459
		3 -- 459
	) -- 459
	texts:put( -- 462
		"xs", -- 462
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 462
		winX + 20, -- 462
		winY + 22, -- 462
		toColor(PALETTE.textMid), -- 462
		0, -- 462
		0.5, -- 462
		"Left", -- 462
		1.8, -- 462
		0.9, -- 462
		0.08 -- 462
	) -- 462
	local infoX = winX + winW + 46 -- 465
	local infoCenterY = winY + winH * 0.5 -- 466
	drawMistCurve( -- 467
		uiArt, -- 467
		"chap_info_mist", -- 467
		infoX + 210, -- 467
		infoCenterY + 36, -- 467
		420, -- 467
		88, -- 467
		theme.accent, -- 467
		0.22, -- 467
		-1 -- 467
	) -- 467
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 470
	texts:put( -- 471
		"xs", -- 471
		theme.volumeTagZh, -- 471
		infoX, -- 471
		winY + winH - 44, -- 471
		toColor(volCol), -- 471
		0, -- 471
		0.5, -- 471
		"Left", -- 471
		2.8, -- 471
		0.92, -- 471
		0.08 -- 471
	) -- 471
	local sep = " · " -- 474
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 475
	local titleY = winY + winH - 98 -- 476
	if theme.backdropKey ~= nil then -- 476
		texts:put( -- 478
			"lg", -- 478
			theme.titleZh, -- 478
			infoX, -- 478
			titleY, -- 478
			toColor(PALETTE.textBright) -- 478
		) -- 478
	elseif sIdx > 0 then -- 478
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 480
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 481
		local lw = visualTextWidth(leftPart, 40) -- 482
		texts:put( -- 483
			"banner", -- 483
			leftPart, -- 483
			infoX, -- 483
			titleY, -- 483
			toColor(PALETTE.textBright), -- 483
			0, -- 483
			0.5, -- 483
			"Left", -- 483
			2, -- 483
			1, -- 483
			0.1 -- 483
		) -- 483
		drawBlossomDot( -- 484
			uiInkDraw, -- 484
			uiArt, -- 484
			"chap_title_dot", -- 484
			infoX + lw + 16, -- 484
			titleY - 2, -- 484
			11, -- 484
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 484
			0.9, -- 484
			4 -- 484
		) -- 484
		texts:put( -- 485
			"banner", -- 485
			rightPart, -- 485
			infoX + lw + 32, -- 485
			titleY, -- 485
			toColor(PALETTE.textBright), -- 485
			0, -- 485
			0.5, -- 485
			"Left", -- 485
			2, -- 485
			1, -- 485
			0.1 -- 485
		) -- 485
	else -- 485
		texts:put( -- 487
			"banner", -- 487
			theme.titleZh, -- 487
			infoX, -- 487
			titleY, -- 487
			toColor(PALETTE.textBright), -- 487
			0, -- 487
			0.5, -- 487
			"Left", -- 487
			2.4, -- 487
			1, -- 487
			0.1 -- 487
		) -- 487
	end -- 487
	drawHairline( -- 490
		uiInkDraw, -- 490
		uiArt, -- 490
		"chap_info_line", -- 490
		infoX + 185, -- 490
		titleY - 36, -- 490
		370, -- 490
		PALETTE.silkDim, -- 490
		0.58, -- 490
		false, -- 490
		2 -- 490
	) -- 490
	texts:put( -- 493
		"sm", -- 493
		theme.introWhisper, -- 493
		infoX, -- 493
		titleY - 72, -- 493
		toColor(PALETTE.textMid), -- 493
		0, -- 493
		0.5, -- 493
		"Left", -- 493
		0.8, -- 493
		0.94, -- 493
		0.08 -- 493
	) -- 493
	local goX = infoX -- 496
	local goY = winY + 26 -- 497
	local goW = 220 -- 498
	local goH = 42 -- 499
	local goBox = Rect(goX, goY, goW, goH) -- 500
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 501
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 502
	drawSilkRibbon( -- 503
		uiDraw, -- 503
		uiArt, -- 503
		"chap_go_rib", -- 503
		goX + 106, -- 503
		goY + 21, -- 503
		250, -- 503
		40, -- 503
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 503
		(goHover and 0.68 or 0.46) * breathe, -- 503
		0 -- 503
	) -- 503
	drawHairline( -- 504
		uiInkDraw, -- 504
		uiArt, -- 504
		"chap_go_line", -- 504
		goX + 94, -- 504
		goY + 3, -- 504
		196, -- 504
		PALETTE.silkLine, -- 504
		goHover and 0.68 or 0.4, -- 504
		false, -- 504
		2 -- 504
	) -- 504
	drawBlossomDot( -- 505
		uiInkDraw, -- 505
		uiArt, -- 505
		"chap_go_dot", -- 505
		goX + 14, -- 505
		goY + 21, -- 505
		14, -- 505
		PALETTE.rouge, -- 505
		0.96, -- 505
		4 -- 505
	) -- 505
	texts:put( -- 506
		"md", -- 506
		"入此卷章", -- 506
		goX + 34, -- 506
		goY + 21, -- 506
		toColor(PALETTE.textBright), -- 506
		0, -- 506
		0.5, -- 506
		"Left", -- 506
		3.8, -- 506
		1, -- 506
		0.1 -- 506
	) -- 506
	texts:put( -- 507
		"xs", -- 507
		"Enter", -- 507
		goX + 156, -- 507
		goY + 21, -- 507
		toColor(PALETTE.textDim), -- 507
		0, -- 507
		0.5, -- 507
		"Left", -- 507
		1, -- 507
		0.82, -- 507
		0.08 -- 507
	) -- 507
	drawSilkVeil( -- 510
		uiDraw, -- 510
		uiArt, -- 510
		"chap_track_veil", -- 510
		w * 0.5, -- 510
		trackY + 6, -- 510
		w - marginX * 1.1, -- 510
		126, -- 510
		PALETTE.inkWash, -- 510
		0.72, -- 510
		-2 -- 510
	) -- 510
	drawMistCurve( -- 511
		uiArt, -- 511
		"chap_track_mist", -- 511
		w * 0.5, -- 511
		trackY, -- 511
		trackX1 - trackX0 + 160, -- 511
		74, -- 511
		PALETTE.inkMist, -- 511
		0.62, -- 511
		-1 -- 511
	) -- 511
	uiInkDraw:drawSegment( -- 512
		Vec2(trackX0, trackY), -- 512
		Vec2(trackX1, trackY), -- 512
		0.9, -- 512
		toColor(PALETTE.silkDim, 145) -- 512
	) -- 512
	if splitTrack then -- 512
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 515
		uiInkDraw:drawSegment( -- 516
			Vec2(trackX0, trackY - rowGap), -- 516
			Vec2(lastX, trackY - rowGap), -- 516
			0.9, -- 516
			toColor(PALETTE.silkDim, 145) -- 516
		) -- 516
	else -- 516
		local midDivX = trackX0 + stepX * 3.5 -- 518
		uiInkDraw:drawSegment( -- 519
			Vec2(midDivX, trackY - 12), -- 519
			Vec2(midDivX, trackY + 12), -- 519
			0.8, -- 519
			toColor(PALETTE.silkDim, 120) -- 519
		) -- 519
		texts:put( -- 520
			"xs", -- 520
			"上卷 · 孤城护童", -- 520
			trackX0 + stepX * 1.5, -- 520
			trackY + 52, -- 520
			toColor(PALETTE.cyan), -- 520
			0.5, -- 520
			0.5, -- 520
			"Center", -- 520
			2.2, -- 520
			0.88, -- 520
			0.08 -- 520
		) -- 520
		texts:put( -- 521
			"xs", -- 521
			"下卷 · 独赴北塔", -- 521
			trackX0 + stepX * 5.5, -- 521
			trackY + 52, -- 521
			toColor(PALETTE.amber), -- 521
			0.5, -- 521
			0.5, -- 521
			"Center", -- 521
			2.2, -- 521
			0.88, -- 521
			0.08 -- 521
		) -- 521
	end -- 521
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < #CHAPTERS do -- 525
			local box = stationBoxes[i + 1] -- 526
			local sx = box.x + box.width * 0.5 -- 527
			local sy = box.y + box.height * 0.5 -- 528
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 529
			local active = self.chapterSelected == i -- 530
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 531
			if active then -- 531
				fillRadialGlow( -- 534
					uiGlow, -- 534
					sx, -- 534
					sy, -- 534
					26, -- 534
					26, -- 534
					toColor(PALETTE.rouge, 36 * breathe), -- 534
					Color(182, 58, 56, 0), -- 534
					12 -- 534
				) -- 534
				uiArt:tryPlace( -- 535
					"ink_enso_fine", -- 535
					"chap_st_ring_" .. tostring(i), -- 535
					sx, -- 535
					sy, -- 535
					32, -- 535
					32, -- 535
					{ -- 535
						color = toColor(PALETTE.silkLine), -- 536
						opacity = 0.78, -- 536
						angle = self.time * 18, -- 536
						layer = 3 -- 536
					} -- 536
				) -- 536
				drawBlossomDot( -- 538
					uiInkDraw, -- 538
					uiArt, -- 538
					"chap_st_dot_" .. tostring(i), -- 538
					sx, -- 538
					sy, -- 538
					17, -- 538
					PALETTE.rouge, -- 538
					0.98, -- 538
					4 -- 538
				) -- 538
			else -- 538
				uiArt:tryPlace( -- 540
					"ink_enso_fine", -- 540
					"chap_st_ring_" .. tostring(i), -- 540
					sx, -- 540
					sy, -- 540
					16, -- 540
					16, -- 540
					{ -- 540
						color = toColor(nodeCol), -- 541
						opacity = 0.62, -- 541
						layer = 3 -- 541
					} -- 541
				) -- 541
				drawBlossomDot( -- 543
					uiInkDraw, -- 543
					uiArt, -- 543
					"chap_st_dot_" .. tostring(i), -- 543
					sx, -- 543
					sy, -- 543
					7, -- 543
					PALETTE.silkLine, -- 543
					0.72, -- 543
					4 -- 543
				) -- 543
			end -- 543
			if not splitTrack then -- 543
				texts:put( -- 547
					"xs", -- 547
					rt.numeralZh, -- 547
					sx, -- 547
					sy + 25, -- 547
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 547
					0.5, -- 547
					0.5, -- 547
					"Center", -- 547
					0, -- 547
					active and 1 or 0.88, -- 547
					0.08 -- 547
				) -- 547
			end -- 547
			texts:put( -- 549
				"xs", -- 549
				rt.shortNameZh, -- 549
				sx, -- 549
				sy - 26, -- 549
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 549
				0.5, -- 549
				0.5, -- 549
				"Center", -- 549
				1, -- 549
				active and 1 or 0.84, -- 549
				0.08 -- 549
			) -- 549
			i = i + 1 -- 525
		end -- 525
	end -- 525
	local backX = marginX -- 553
	local backY = 40 -- 554
	local backBox = Rect(backX, backY, 190, 34) -- 555
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 556
	drawSilkKeycap( -- 557
		uiInkDraw, -- 557
		texts, -- 557
		backX, -- 557
		backY + 5, -- 557
		44, -- 557
		24, -- 557
		"ESC", -- 557
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 557
		0.92, -- 557
		backHover -- 557
	) -- 557
	texts:put( -- 558
		"sm", -- 558
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 558
		backX + 56, -- 558
		backY + 17, -- 558
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 558
		0, -- 558
		0.5, -- 558
		"Left", -- 558
		1.8, -- 558
		0.9, -- 558
		0.08 -- 558
	) -- 558
	texts:put( -- 559
		"xs", -- 559
		"方向键选择   ·   回车或点击进入", -- 559
		w - marginX, -- 559
		backY + 17, -- 559
		toColor(PALETTE.textDim), -- 559
		1, -- 559
		0.5, -- 559
		"Right", -- 559
		1.2, -- 559
		0.75, -- 559
		0.08 -- 559
	) -- 559
	if frame.click and backHover then -- 559
		return back -- 562
	end -- 562
	if keys.confirm or frame.click and (hitStation >= 0 or winHover or goHover) then -- 562
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 565
	end -- 565
	return {type = "none"} -- 567
end -- 381
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 573
	if backLabel == nil then -- 573
		backLabel = "返回标题" -- 582
	end -- 582
	local marginX = 96 -- 584
	local backX = marginX -- 585
	local backY = 40 -- 586
	local backBox = Rect(backX, backY, 230, 34) -- 587
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 588
	if frame.back or frame.keys.confirm or frame.click and backHover then -- 588
		return {type = "backTitle"} -- 590
	end -- 590
	uiDraw:drawRect( -- 592
		Rect(0, 0, w, h), -- 592
		Color(10, 12, 19, 204) -- 592
	) -- 592
	texts:put( -- 594
		"banner", -- 594
		"执器要诀", -- 594
		marginX, -- 594
		h - 66, -- 594
		toColor(PALETTE.textBright), -- 594
		0, -- 594
		0.5, -- 594
		"Left", -- 594
		4.5, -- 594
		0.96, -- 594
		0.1 -- 594
	) -- 594
	texts:put( -- 595
		"xs", -- 595
		"键鼠操作说明", -- 595
		marginX + 196, -- 595
		h - 70, -- 595
		toColor(PALETTE.textDim), -- 595
		0, -- 595
		0.5, -- 595
		"Left", -- 595
		2, -- 595
		0.85, -- 595
		0.08 -- 595
	) -- 595
	drawHairline( -- 596
		uiInkDraw, -- 596
		uiArt, -- 596
		"ctrl_top_line", -- 596
		w * 0.5, -- 596
		h - 100, -- 596
		w - marginX * 2, -- 596
		PALETTE.silkDim, -- 596
		0.6, -- 596
		true, -- 596
		2 -- 596
	) -- 596
	local areaY = 114 -- 599
	local areaH = h - 244 -- 600
	drawFiligreeCorners( -- 601
		uiInkDraw, -- 601
		uiArt, -- 601
		"ctrl_outer", -- 601
		marginX, -- 601
		areaY, -- 601
		w - marginX * 2, -- 601
		areaH, -- 601
		PALETTE.silkDim, -- 601
		0.52, -- 601
		34, -- 601
		false, -- 601
		2 -- 601
	) -- 601
	local midX = w * 0.5 -- 604
	uiArt:tryPlace( -- 605
		"ink_vstream", -- 605
		"ctrl_mid_stream", -- 605
		midX, -- 605
		areaY + areaH * 0.5, -- 605
		32, -- 605
		areaH - 18, -- 605
		{ -- 605
			color = toColor(PALETTE.silkDim), -- 606
			opacity = 0.52, -- 606
			layer = 1 -- 606
		} -- 606
	) -- 606
	drawBlossomDot( -- 608
		uiInkDraw, -- 608
		uiArt, -- 608
		"ctrl_mid_dot", -- 608
		midX, -- 608
		areaY + areaH * 0.5, -- 608
		11, -- 608
		PALETTE.silkLine, -- 608
		0.62, -- 608
		3 -- 608
	) -- 608
	local leftColX = marginX + 34 -- 611
	local colW = midX - leftColX - 42 -- 612
	local headY = areaY + areaH - 34 -- 613
	drawBlossomDot( -- 614
		uiInkDraw, -- 614
		uiArt, -- 614
		"ctrl_l_dot", -- 614
		leftColX + 8, -- 614
		headY, -- 614
		12, -- 614
		PALETTE.cyan, -- 614
		0.88, -- 614
		3 -- 614
	) -- 614
	texts:put( -- 615
		"md", -- 615
		"周戍 · 护送与交锋", -- 615
		leftColX + 26, -- 615
		headY, -- 615
		toColor(PALETTE.cyanCore), -- 615
		0, -- 615
		0.5, -- 615
		"Left", -- 615
		2.4, -- 615
		0.98, -- 615
		0.08 -- 615
	) -- 615
	drawHairline( -- 616
		uiInkDraw, -- 616
		uiArt, -- 616
		"ctrl_l_line", -- 616
		leftColX + colW * 0.5, -- 616
		headY - 24, -- 616
		colW, -- 616
		PALETTE.cyanDim, -- 616
		0.58, -- 616
		false, -- 616
		2 -- 616
	) -- 616
	local sRows = { -- 618
		{"WASD / 方向键", "左右、前后自由移动"}, -- 619
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 620
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 621
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 622
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 623
		{"ESC / R", "暂歇菜单 / 重试检查点"} -- 624
	} -- 624
	local i = 0 -- 626
	do -- 626
		i = 0 -- 627
		while i < #sRows do -- 627
			local ry = headY - 66 - i * 52 -- 628
			drawSilkKeycap( -- 629
				uiInkDraw, -- 629
				texts, -- 629
				leftColX + 2, -- 629
				ry - 13, -- 629
				132, -- 629
				26, -- 629
				sRows[i + 1][1], -- 629
				PALETTE.cyan, -- 629
				0.92, -- 629
				false -- 629
			) -- 629
			texts:put( -- 630
				"sm", -- 630
				sRows[i + 1][2], -- 630
				leftColX + 150, -- 630
				ry, -- 630
				toColor(PALETTE.textBright), -- 630
				0, -- 630
				0.5, -- 630
				"Left", -- 630
				0.8, -- 630
				0.92, -- 630
				0.08 -- 630
			) -- 630
			i = i + 1 -- 627
		end -- 627
	end -- 627
	local rightColX = midX + 44 -- 634
	drawBlossomDot( -- 635
		uiInkDraw, -- 635
		uiArt, -- 635
		"ctrl_r_dot", -- 635
		rightColX + 8, -- 635
		headY, -- 635
		12, -- 635
		PALETTE.amber, -- 635
		0.88, -- 635
		3 -- 635
	) -- 635
	texts:put( -- 636
		"md", -- 636
		"小满 · 潜行与寻路", -- 636
		rightColX + 26, -- 636
		headY, -- 636
		toColor(PALETTE.amberCore), -- 636
		0, -- 636
		0.5, -- 636
		"Left", -- 636
		2.4, -- 636
		0.98, -- 636
		0.08 -- 636
	) -- 636
	drawHairline( -- 637
		uiInkDraw, -- 637
		uiArt, -- 637
		"ctrl_r_line", -- 637
		rightColX + colW * 0.5, -- 637
		headY - 24, -- 637
		colW, -- 637
		PALETTE.amberDim, -- 637
		0.58, -- 637
		false, -- 637
		2 -- 637
	) -- 637
	local cRows = { -- 639
		{"A / D · ← / →", "左右潜行"}, -- 640
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 641
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 642
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 643
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 644
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 645
	} -- 645
	do -- 645
		i = 0 -- 647
		while i < #cRows do -- 647
			local ry = headY - 66 - i * 52 -- 648
			drawSilkKeycap( -- 649
				uiInkDraw, -- 649
				texts, -- 649
				rightColX + 2, -- 649
				ry - 13, -- 649
				132, -- 649
				26, -- 649
				cRows[i + 1][1], -- 649
				PALETTE.amber, -- 649
				0.92, -- 649
				false -- 649
			) -- 649
			texts:put( -- 650
				"sm", -- 650
				cRows[i + 1][2], -- 650
				rightColX + 150, -- 650
				ry, -- 650
				toColor(PALETTE.textBright), -- 650
				0, -- 650
				0.5, -- 650
				"Left", -- 650
				0.8, -- 650
				0.92, -- 650
				0.08 -- 650
			) -- 650
			i = i + 1 -- 647
		end -- 647
	end -- 647
	drawSilkKeycap( -- 654
		uiInkDraw, -- 654
		texts, -- 654
		backX, -- 654
		backY + 5, -- 654
		110, -- 654
		24, -- 654
		"ESC / ENTER", -- 654
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 654
		0.92, -- 654
		backHover -- 654
	) -- 654
	texts:put( -- 655
		"sm", -- 655
		backLabel, -- 655
		backX + 122, -- 655
		backY + 17, -- 655
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 655
		0, -- 655
		0.5, -- 655
		"Left", -- 655
		1.8, -- 655
		0.92, -- 655
		0.08 -- 655
	) -- 655
	texts:put( -- 656
		"xs", -- 656
		"F11 / Alt+Enter 切换全屏", -- 656
		w - marginX, -- 656
		backY + 17, -- 656
		toColor(PALETTE.textDim), -- 656
		1, -- 656
		0.5, -- 656
		"Right", -- 656
		1.2, -- 656
		0.78, -- 656
		0.08 -- 656
	) -- 656
	return {type = "none"} -- 658
end -- 573
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist) -- 665
	if assistHintsEnabled == nil then -- 665
		assistHintsEnabled = false -- 676
	end -- 676
	self.time = self.time + dt -- 679
	local frame = self:readFrame(input, uiScale) -- 680
	if self.pauseShowControls then -- 680
		local ctrlAct = self:drawControls( -- 684
			frame, -- 684
			uiDraw, -- 684
			uiInkDraw, -- 684
			uiArt, -- 684
			uiGlow, -- 684
			texts, -- 684
			w, -- 684
			h, -- 684
			"返回暂停" -- 684
		) -- 684
		if ctrlAct.type == "backTitle" then -- 684
			self.pauseShowControls = false -- 686
			self:resetInput() -- 687
		end -- 687
		return {type = "none"} -- 689
	end -- 689
	if frame.back then -- 689
		self.pauseShowControls = false -- 693
		return {type = "resume"} -- 694
	end -- 694
	uiDraw:drawRect( -- 698
		Rect(0, 0, w, h), -- 698
		Color(8, 10, 16, 102) -- 698
	) -- 698
	fillHGradRect( -- 699
		uiDraw, -- 699
		0, -- 699
		0, -- 699
		w * 0.27, -- 699
		h, -- 699
		Color(9, 11, 18, 232), -- 699
		Color(10, 13, 21, 198) -- 699
	) -- 699
	fillHGradRect( -- 700
		uiDraw, -- 700
		w * 0.27, -- 700
		0, -- 700
		w * 0.21, -- 700
		h, -- 700
		Color(10, 13, 21, 198), -- 700
		Color(10, 13, 21, 0) -- 700
	) -- 700
	local menuX = 110 -- 703
	uiArt:tryPlace( -- 704
		"ink_vstream", -- 704
		"pause_vstream", -- 704
		menuX - 32, -- 704
		h * 0.5, -- 704
		34, -- 704
		h * 0.78, -- 704
		{ -- 704
			color = toColor(PALETTE.silkDim), -- 705
			opacity = 0.48, -- 705
			layer = 1 -- 705
		} -- 705
	) -- 705
	drawMistCurve( -- 707
		uiArt, -- 707
		"pause_mist", -- 707
		menuX + 118, -- 707
		h - 154, -- 707
		290, -- 707
		72, -- 707
		PALETTE.jadeMist, -- 707
		0.2, -- 707
		-1 -- 707
	) -- 707
	texts:put( -- 710
		"banner", -- 710
		"暂歇", -- 710
		menuX + 16, -- 710
		h - 146, -- 710
		toColor(PALETTE.textBright), -- 710
		0, -- 710
		0.5, -- 710
		"Left", -- 710
		10, -- 710
		0.98, -- 710
		0.1 -- 710
	) -- 710
	texts:put( -- 711
		"xs", -- 711
		"月夜暂驻 · 卷页留痕", -- 711
		menuX + 18, -- 711
		h - 184, -- 711
		toColor(PALETTE.textDim), -- 711
		0, -- 711
		0.5, -- 711
		"Left", -- 711
		2, -- 711
		0.8, -- 711
		0.08 -- 711
	) -- 711
	drawHairline( -- 712
		uiInkDraw, -- 712
		uiArt, -- 712
		"pause_div", -- 712
		menuX + 124, -- 712
		h - 210, -- 712
		240, -- 712
		PALETTE.silkDim, -- 712
		0.58, -- 712
		true, -- 712
		2 -- 712
	) -- 712
	local boxes = {} -- 714
	local i = 0 -- 715
	do -- 715
		i = 0 -- 716
		while i < #PAUSE_ITEMS do -- 716
			boxes[#boxes + 1] = Rect(menuX - 10, h - 266 - i * 46, 270, 38) -- 717
			i = i + 1 -- 716
		end -- 716
	end -- 716
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 719
	do -- 719
		i = 0 -- 721
		while i < #PAUSE_ITEMS do -- 721
			local iy = boxes[i + 1].y -- 722
			local active = self.pauseSelected == i -- 723
			local cy = iy + 19 -- 724
			local shiftX = active and 10 or 0 -- 725
			local item = PAUSE_ITEMS[i + 1] -- 726
			local label = item.id == "assist" and (assistHintsEnabled and "按键辅助：开" or "按键辅助：关") or (item.id == "fullscreen" and (App.fullScreen and "显示：全屏" or "显示：窗口") or item.zh) -- 727
			if active then -- 727
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 734
				drawSilkRibbon( -- 735
					uiDraw, -- 735
					uiArt, -- 735
					"pause_rib_" .. tostring(i), -- 735
					menuX + 116, -- 735
					cy, -- 735
					276, -- 735
					38, -- 735
					PALETTE.rougeSoft, -- 735
					0.54 * breathe, -- 735
					0 -- 735
				) -- 735
				drawHairline( -- 736
					uiInkDraw, -- 736
					uiArt, -- 736
					"pause_line_" .. tostring(i), -- 736
					menuX + 106, -- 736
					iy + 3, -- 736
					210, -- 736
					PALETTE.silkLine, -- 736
					0.42 * breathe, -- 736
					false, -- 736
					2 -- 736
				) -- 736
				drawBlossomDot( -- 737
					uiInkDraw, -- 737
					uiArt, -- 737
					"pause_dot_" .. tostring(i), -- 737
					menuX + 12, -- 737
					cy, -- 737
					15, -- 737
					PALETTE.rouge, -- 737
					0.96, -- 737
					4 -- 737
				) -- 737
				fillRadialGlow( -- 738
					uiGlow, -- 738
					menuX + 12, -- 738
					cy, -- 738
					22, -- 738
					16, -- 738
					toColor(PALETTE.rouge, 26 * breathe), -- 738
					Color(182, 58, 56, 0), -- 738
					10 -- 738
				) -- 738
			else -- 738
				drawBlossomDot( -- 740
					uiInkDraw, -- 740
					uiArt, -- 740
					"pause_dot_" .. tostring(i), -- 740
					menuX + 12, -- 740
					cy, -- 740
					8, -- 740
					PALETTE.silkDim, -- 740
					0.4, -- 740
					3 -- 740
				) -- 740
			end -- 740
			texts:put( -- 743
				"md", -- 744
				label, -- 745
				menuX + 32 + shiftX, -- 746
				cy, -- 747
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 748
				0, -- 749
				0.5, -- 750
				"Left", -- 751
				active and 3.8 or 2.4, -- 752
				active and 1 or 0.88, -- 753
				0.1 -- 754
			) -- 754
			i = i + 1 -- 721
		end -- 721
	end -- 721
	texts:put( -- 758
		"xs", -- 758
		"Esc 续行   ·   Enter 或点击确认", -- 758
		menuX + 12, -- 758
		56, -- 758
		toColor(PALETTE.textDim), -- 758
		0, -- 758
		0.5, -- 758
		"Left", -- 758
		1.2, -- 758
		0.86, -- 758
		0.08 -- 758
	) -- 758
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 760
	if hit >= 0 or frame.keys.confirm then -- 760
		local idx = hit >= 0 and hit or self.pauseSelected -- 762
		local id = PAUSE_ITEMS[idx + 1].id -- 763
		if id == "controls" then -- 763
			self.pauseShowControls = true -- 765
			self:resetInput() -- 766
			return {type = "none"} -- 767
		end -- 767
		if id == "assist" then -- 767
			if onToggleAssist ~= nil then -- 767
				onToggleAssist() -- 771
			end -- 771
			self:resetInput() -- 773
			return {type = "none"} -- 774
		end -- 774
		if id == "fullscreen" then -- 774
			self:resetInput() -- 777
			return {type = "toggleFullscreen"} -- 778
		end -- 778
		self.pauseShowControls = false -- 780
		if id == "resume" then -- 780
			return {type = "resume"} -- 782
		end -- 782
		if id == "retry" then -- 782
			return {type = "retry"} -- 785
		end -- 785
		if id == "chapters" then -- 785
			return {type = "openChapters"} -- 788
		end -- 788
		if id == "quit" then -- 788
			return {type = "quit"} -- 791
		end -- 791
		return {type = "toTitle"} -- 793
	end -- 793
	return {type = "none"} -- 795
end -- 665
return ____exports -- 665