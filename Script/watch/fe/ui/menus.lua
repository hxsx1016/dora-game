-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
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
local drawBrushDivider = ____theme.drawBrushDivider -- 19
local drawInkKeycap = ____theme.drawInkKeycap -- 20
local drawInkPanel = ____theme.drawInkPanel -- 21
local drawInkWashStrip = ____theme.drawInkWashStrip -- 22
local drawOvalSeal = ____theme.drawOvalSeal -- 23
local drawScrollFrame = ____theme.drawScrollFrame -- 24
local drawSealStamp = ____theme.drawSealStamp -- 25
local fillHGradRect = ____theme.fillHGradRect -- 26
local fillRadialGlow = ____theme.fillRadialGlow -- 27
local fillVGradRect = ____theme.fillVGradRect -- 28
local themeOf = ____theme.themeOf -- 29
local toColor = ____theme.toColor -- 30
local TITLE_ITEMS = {{id = "start", zh = "开始游戏", seal = "启"}, {id = "chapters", zh = "选择章节", seal = "卷"}, {id = "controls", zh = "操作说明", seal = "诀"}} -- 40
local PAUSE_ITEMS = {{id = "resume", zh = "继续游戏", seal = "续"}, {id = "retry", zh = "重试检查点", seal = "重"}, {id = "chapters", zh = "选择章节", seal = "卷"}, {id = "title", zh = "返回标题", seal = "归"}} -- 46
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 53
____exports.MenuRenderer = __TS__Class() -- 55
local MenuRenderer = ____exports.MenuRenderer -- 55
MenuRenderer.name = "MenuRenderer" -- 55
function MenuRenderer.prototype.____constructor(self) -- 55
	self.selected = 0 -- 56
	self.chapterSelected = 0 -- 57
	self.pauseSelected = 0 -- 58
	self.prevUp = false -- 59
	self.prevDown = false -- 60
	self.prevLeft = false -- 61
	self.prevRight = false -- 62
	self.prevEnter = false -- 63
	self.chaptersFromPause = false -- 64
	self.pointerActive = false -- 65
	self.queuedUp = false -- 66
	self.queuedDown = false -- 67
	self.queuedLeft = false -- 68
	self.queuedRight = false -- 69
	self.queuedConfirm = false -- 70
	self.queuedBack = false -- 71
	self.time = 0 -- 72
end -- 55
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 74
	self.chaptersFromPause = roomIndex ~= nil -- 75
	self.chapterSelected = roomIndex or 0 -- 76
	self:resetInput() -- 77
end -- 74
function MenuRenderer.prototype.openPause(self) -- 80
	self.pauseSelected = 0 -- 81
	self:resetInput() -- 82
end -- 80
function MenuRenderer.prototype.resetInput(self) -- 86
	self.prevUp = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 87
	self.prevDown = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 88
	self.prevLeft = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 89
	self.prevRight = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 90
	self.prevEnter = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 91
	self.queuedRight = false -- 92
	self.queuedLeft = false -- 92
	self.queuedDown = false -- 92
	self.queuedUp = false -- 92
	self.queuedBack = false -- 93
	self.queuedConfirm = false -- 93
end -- 86
function MenuRenderer.prototype.onKeyEvent(self, key) -- 97
	if key == "Up" or key == "W" then -- 97
		self.queuedUp = true -- 99
	elseif key == "Down" or key == "S" then -- 99
		self.queuedDown = true -- 101
	elseif key == "Left" or key == "A" then -- 101
		self.queuedLeft = true -- 103
	elseif key == "Right" or key == "D" then -- 103
		self.queuedRight = true -- 105
	elseif key == "Return" or key == "Space" then -- 105
		self.queuedConfirm = true -- 107
	elseif key == "Escape" then -- 107
		self.queuedBack = true -- 109
	end -- 109
end -- 97
function MenuRenderer.prototype.readMenuKeys(self) -- 113
	local u = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 114
	local d = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 115
	local l = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 116
	local r = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 117
	local e = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 118
	local res = { -- 119
		up = u and not self.prevUp or self.queuedUp, -- 120
		down = d and not self.prevDown or self.queuedDown, -- 121
		left = l and not self.prevLeft or self.queuedLeft, -- 122
		right = r and not self.prevRight or self.queuedRight, -- 123
		confirm = e and not self.prevEnter or self.queuedConfirm, -- 124
		back = self.queuedBack -- 125
	} -- 125
	self.prevUp = u -- 127
	self.prevDown = d -- 128
	self.prevLeft = l -- 129
	self.prevRight = r -- 130
	self.prevEnter = e -- 131
	self.queuedUp = false -- 132
	self.queuedDown = false -- 133
	self.queuedLeft = false -- 134
	self.queuedRight = false -- 135
	self.queuedConfirm = false -- 136
	self.queuedBack = false -- 137
	return res -- 138
end -- 113
function MenuRenderer.prototype.clickEdge(self, input) -- 141
	return input.inside and input.fire.pressed -- 142
end -- 141
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 146
	self.time = self.time + dt -- 163
	local artW = math.max(w, h * 16 / 9) -- 164
	local artH = artW * 9 / 16 -- 165
	if not backdropArt:tryPlace( -- 165
		"title_backdrop", -- 166
		"menu_landscape", -- 166
		w * 0.5, -- 166
		(h - artH) * 0.5, -- 166
		artW, -- 166
		artH -- 166
	) then -- 166
		stage:drawMenuBackdrop( -- 167
			bgDraw, -- 167
			bgGlow, -- 167
			w, -- 167
			h, -- 167
			self.time -- 167
		) -- 167
	end -- 167
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 170
	w = w / uiScale -- 171
	h = h / uiScale -- 172
	local mk = self:readMenuKeys() -- 174
	local clicked = self:clickEdge(input) -- 175
	self.pointerActive = input.inside and (clicked or math.abs(input.mdx) + math.abs(input.mdy) >= uiScale and not mk.up and not mk.down and not mk.left and not mk.right and not mk.confirm) -- 176
	if screen == "title" then -- 176
		return self:drawTitle( -- 181
			mk, -- 181
			clicked, -- 181
			pointer, -- 181
			uiDraw, -- 181
			uiInkDraw, -- 181
			uiArt, -- 181
			uiGlow, -- 181
			texts, -- 181
			w, -- 181
			h -- 181
		) -- 181
	end -- 181
	if screen == "chapters" then -- 181
		return self:drawChapters( -- 184
			mk, -- 184
			clicked, -- 184
			input, -- 184
			pointer, -- 184
			uiDraw, -- 184
			uiInkDraw, -- 184
			uiArt, -- 184
			uiGlow, -- 184
			texts, -- 184
			w, -- 184
			h -- 184
		) -- 184
	end -- 184
	return self:drawControls( -- 186
		mk, -- 186
		clicked, -- 186
		input, -- 186
		pointer, -- 186
		uiDraw, -- 186
		uiInkDraw, -- 186
		uiArt, -- 186
		uiGlow, -- 186
		texts, -- 186
		w, -- 186
		h -- 186
	) -- 186
end -- 146
function MenuRenderer.prototype.drawTitle(self, mk, clicked, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 189
	if mk.up then -- 189
		self.selected = (self.selected + #TITLE_ITEMS - 1) % #TITLE_ITEMS -- 202
	elseif mk.down then -- 202
		self.selected = (self.selected + 1) % #TITLE_ITEMS -- 204
	end -- 204
	fillHGradRect( -- 208
		uiDraw, -- 208
		0, -- 208
		0, -- 208
		w * 0.24, -- 208
		h, -- 208
		Color(10, 11, 16, 198), -- 208
		Color(10, 11, 16, 138) -- 208
	) -- 208
	fillHGradRect( -- 209
		uiDraw, -- 209
		w * 0.24, -- 209
		0, -- 209
		w * 0.28, -- 209
		h, -- 209
		Color(10, 11, 16, 138), -- 209
		Color(10, 11, 16, 0) -- 209
	) -- 209
	fillVGradRect( -- 210
		uiDraw, -- 210
		0, -- 210
		0, -- 210
		w, -- 210
		86, -- 210
		Color(8, 9, 13, 155), -- 210
		Color(8, 9, 13, 0) -- 210
	) -- 210
	local titleX = 152 -- 213
	local topY = h - 108 -- 214
	local charStep = 64 -- 215
	uiArt:tryPlace( -- 218
		"ink_splatter", -- 218
		"title_mist", -- 218
		titleX + 8, -- 218
		topY - 96, -- 218
		220, -- 218
		260, -- 218
		{ -- 218
			color = toColor(PALETTE.inkVoid), -- 219
			opacity = 0.42, -- 219
			layer = -1 -- 219
		} -- 219
	) -- 219
	uiArt:tryPlace( -- 221
		"ink_vbrush", -- 221
		"title_vrule_l", -- 221
		titleX - 48, -- 221
		topY - 102, -- 221
		16, -- 221
		264, -- 221
		{ -- 221
			color = toColor(PALETTE.bronzeDim), -- 222
			opacity = 0.56, -- 222
			layer = 1 -- 222
		} -- 222
	) -- 222
	uiArt:tryPlace( -- 224
		"ink_vbrush", -- 224
		"title_vrule_r", -- 224
		titleX + 76, -- 224
		topY - 118, -- 224
		12, -- 224
		228, -- 224
		{ -- 224
			color = toColor(PALETTE.bronzeLine), -- 225
			opacity = 0.36, -- 225
			layer = 1 -- 225
		} -- 225
	) -- 225
	local c = 0 -- 228
	do -- 228
		c = 0 -- 229
		while c < #VERTICAL_TITLE do -- 229
			local cy = topY - c * charStep -- 230
			texts:put( -- 231
				"title", -- 232
				VERTICAL_TITLE[c + 1], -- 233
				titleX, -- 234
				cy, -- 235
				toColor(PALETTE.textBright), -- 236
				0.5, -- 237
				0.5, -- 238
				"Center", -- 239
				0, -- 240
				0.98, -- 241
				0.15, -- 242
				Color(8, 9, 13, 235) -- 243
			) -- 243
			c = c + 1 -- 229
		end -- 229
	end -- 229
	drawOvalSeal( -- 248
		uiInkDraw, -- 249
		uiArt, -- 250
		texts, -- 251
		"title_seal", -- 252
		titleX + 46, -- 253
		topY - 3 * charStep + 10, -- 254
		32, -- 255
		58, -- 256
		"守", -- 257
		"望", -- 258
		PALETTE.sealRed, -- 259
		PALETTE.sealText, -- 260
		0.96, -- 261
		4 -- 262
	) -- 262
	local epigraphX = titleX + 100 -- 266
	texts:put( -- 267
		"sm", -- 267
		"城破那天，他留下断后。", -- 267
		epigraphX, -- 267
		topY - 82, -- 267
		toColor(PALETTE.textMid), -- 267
		0, -- 267
		0.5, -- 267
		"Left", -- 267
		1, -- 267
		0.92 -- 267
	) -- 267
	texts:put( -- 268
		"sm", -- 268
		"她独自走向北塔。", -- 268
		epigraphX, -- 268
		topY - 114, -- 268
		toColor(PALETTE.amberCore), -- 268
		0, -- 268
		0.5, -- 268
		"Left", -- 268
		1, -- 268
		0.9 -- 268
	) -- 268
	drawBrushDivider( -- 269
		uiInkDraw, -- 269
		uiArt, -- 269
		"title_epigraph_div", -- 269
		epigraphX + 94, -- 269
		topY - 140, -- 269
		196, -- 269
		12, -- 269
		PALETTE.bronzeDim, -- 269
		0.62, -- 269
		2 -- 269
	) -- 269
	texts:put( -- 270
		"xs", -- 270
		"双线叙事 · 护送与潜行", -- 270
		epigraphX, -- 270
		topY - 162, -- 270
		toColor(PALETTE.textDim), -- 270
		0, -- 270
		0.5, -- 270
		"Left", -- 270
		1.4, -- 270
		0.85 -- 270
	) -- 270
	local menuX = 114 -- 273
	local btnW = 304 -- 274
	local btnH = 48 -- 275
	local gap = 14 -- 276
	local startY = 266 -- 277
	local hitIdx = -1 -- 278
	local i = 0 -- 280
	do -- 280
		i = 0 -- 281
		while i < #TITLE_ITEMS do -- 281
			local by = startY - i * (btnH + gap) -- 282
			local hover = pointer.x >= menuX - 10 and pointer.x <= menuX + btnW and pointer.y >= by and pointer.y <= by + btnH -- 283
			if hover and self.pointerActive then -- 283
				self.selected = i -- 285
				hitIdx = i -- 286
			end -- 286
			local active = self.selected == i -- 288
			local cy = by + btnH * 0.5 -- 289
			local shiftX = active and 8 or 0 -- 290
			if active then -- 290
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.6) -- 293
				drawInkWashStrip( -- 295
					uiDraw, -- 295
					uiArt, -- 295
					"title_btn_ink_" .. tostring(i), -- 295
					menuX + btnW * 0.5 + 4, -- 295
					cy, -- 295
					btnW + 34, -- 295
					btnH + 10, -- 295
					PALETTE.inkWash, -- 295
					0.84, -- 295
					false, -- 295
					0 -- 295
				) -- 295
				drawInkWashStrip( -- 296
					uiDraw, -- 296
					uiArt, -- 296
					"title_btn_red_" .. tostring(i), -- 296
					menuX + btnW * 0.44 + 4, -- 296
					cy, -- 296
					btnW * 0.84, -- 296
					btnH - 2, -- 296
					PALETTE.cinnabarDeep, -- 296
					0.46 * breathe, -- 296
					false, -- 296
					1 -- 296
				) -- 296
				drawBrushDivider( -- 297
					uiInkDraw, -- 297
					uiArt, -- 297
					"title_btn_line_" .. tostring(i), -- 297
					menuX + btnW * 0.46, -- 297
					by + 3, -- 297
					btnW * 0.78, -- 297
					10, -- 297
					PALETTE.bronzeLine, -- 297
					0.55, -- 297
					2 -- 297
				) -- 297
				drawSealStamp( -- 299
					uiInkDraw, -- 299
					uiArt, -- 299
					texts, -- 299
					"title_btn_seal_" .. tostring(i), -- 299
					menuX + 18, -- 299
					cy, -- 299
					26, -- 299
					TITLE_ITEMS[i + 1].seal, -- 299
					PALETTE.sealRed, -- 299
					PALETTE.sealText, -- 299
					0.96, -- 299
					true, -- 299
					4 -- 299
				) -- 299
				fillRadialGlow( -- 300
					uiGlow, -- 300
					menuX + 18, -- 300
					cy, -- 300
					34, -- 300
					20, -- 300
					toColor(PALETTE.cinnabar, 36 * breathe), -- 300
					Color(168, 46, 40, 0), -- 300
					12 -- 300
				) -- 300
			else -- 300
				uiArt:tryPlace( -- 303
					"ink_dot", -- 303
					"title_btn_dot_" .. tostring(i), -- 303
					menuX + 18, -- 303
					cy, -- 303
					9, -- 303
					9, -- 303
					{ -- 303
						color = toColor(PALETTE.bronzeDim), -- 304
						opacity = 0.58, -- 304
						layer = 2 -- 304
					} -- 304
				) -- 304
			end -- 304
			texts:put( -- 308
				"md", -- 309
				TITLE_ITEMS[i + 1].zh, -- 310
				menuX + 42 + shiftX, -- 311
				cy, -- 312
				toColor(active and PALETTE.amberCore or PALETTE.textMid), -- 313
				0, -- 314
				0.5, -- 315
				"Left", -- 316
				active and 3.2 or 2, -- 317
				active and 1 or 0.88 -- 318
			) -- 318
			i = i + 1 -- 281
		end -- 281
	end -- 281
	texts:put( -- 322
		"xs", -- 322
		"↑ ↓ 择项   ·   Enter 或点击启程", -- 322
		menuX + 8, -- 322
		46, -- 322
		toColor(PALETTE.textDim), -- 322
		0, -- 322
		0.5, -- 322
		"Left", -- 322
		0.8, -- 322
		0.85 -- 322
	) -- 322
	if mk.confirm or clicked and hitIdx >= 0 then -- 322
		local id = TITLE_ITEMS[self.selected + 1].id -- 325
		if id == "start" then -- 325
			return {type = "start"} -- 327
		end -- 327
		if id == "chapters" then -- 327
			return {type = "openChapters"} -- 330
		end -- 330
		return {type = "openControls"} -- 332
	end -- 332
	return {type = "none"} -- 334
end -- 189
function MenuRenderer.prototype.drawChapters(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 337
	if input.pause.pressed or mk.back then -- 337
		return {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 351
	end -- 351
	if mk.left then -- 351
		self.chapterSelected = (self.chapterSelected + #ROOMS - 1) % #ROOMS -- 354
	elseif mk.right then -- 354
		self.chapterSelected = (self.chapterSelected + 1) % #ROOMS -- 356
	elseif mk.up then -- 356
		self.chapterSelected = (self.chapterSelected + #ROOMS - 4) % #ROOMS -- 358
	elseif mk.down then -- 358
		self.chapterSelected = (self.chapterSelected + 4) % #ROOMS -- 360
	end -- 360
	uiDraw:drawRect( -- 364
		Rect(0, 0, w, h), -- 364
		Color(11, 12, 17, 178) -- 364
	) -- 364
	local leftX = 96 -- 366
	drawSealStamp( -- 368
		uiInkDraw, -- 368
		uiArt, -- 368
		texts, -- 368
		"chap_head_seal", -- 368
		leftX + 18, -- 368
		h - 86, -- 368
		34, -- 368
		"卷", -- 368
		PALETTE.sealRed, -- 368
		PALETTE.sealText, -- 368
		0.96, -- 368
		true, -- 368
		4 -- 368
	) -- 368
	texts:put( -- 369
		"banner", -- 369
		"选择章节", -- 369
		leftX + 48, -- 369
		h - 86, -- 369
		toColor(PALETTE.textBright), -- 369
		0, -- 369
		0.5, -- 369
		"Left", -- 369
		4, -- 369
		1 -- 369
	) -- 369
	texts:put( -- 370
		"xs", -- 370
		"双线八幕 · 行纪直达", -- 370
		leftX + 236, -- 370
		h - 90, -- 370
		toColor(PALETTE.textDim), -- 370
		0, -- 370
		0.5, -- 370
		"Left", -- 370
		1.2, -- 370
		0.88 -- 370
	) -- 370
	drawBrushDivider( -- 371
		uiInkDraw, -- 371
		uiArt, -- 371
		"chap_head_div", -- 371
		w * 0.5, -- 371
		h - 118, -- 371
		w - leftX * 2, -- 371
		14, -- 371
		PALETTE.bronzeDim, -- 371
		0.72, -- 371
		2 -- 371
	) -- 371
	local cols = 4 -- 373
	local gapX = 22 -- 374
	local cardW = math.min(262, (w - leftX * 2 - (cols - 1) * gapX) / cols) -- 375
	local cardH = 140 -- 376
	local rowY0 = h * 0.52 -- 377
	local rowY1 = h * 0.21 -- 378
	local hitIdx = -1 -- 379
	drawSealStamp( -- 382
		uiInkDraw, -- 382
		uiArt, -- 382
		texts, -- 382
		"vol1_seal", -- 382
		leftX + 12, -- 382
		rowY0 + cardH + 22, -- 382
		22, -- 382
		"上", -- 382
		PALETTE.cyanDim, -- 382
		PALETTE.moonPale, -- 382
		0.92, -- 382
		true, -- 382
		4 -- 382
	) -- 382
	texts:put( -- 383
		"sm", -- 383
		"上卷 · 孤城护童（周戍）", -- 383
		leftX + 30, -- 383
		rowY0 + cardH + 22, -- 383
		toColor(PALETTE.cyanCore), -- 383
		0, -- 383
		0.5, -- 383
		"Left", -- 383
		1.2, -- 383
		0.95 -- 383
	) -- 383
	drawSealStamp( -- 385
		uiInkDraw, -- 385
		uiArt, -- 385
		texts, -- 385
		"vol2_seal", -- 385
		leftX + 12, -- 385
		rowY1 + cardH + 22, -- 385
		22, -- 385
		"下", -- 385
		PALETTE.amberDim, -- 385
		PALETTE.amberCore, -- 385
		0.92, -- 385
		true, -- 385
		4 -- 385
	) -- 385
	texts:put( -- 386
		"sm", -- 386
		"下卷 · 独赴北塔（小满）", -- 386
		leftX + 30, -- 386
		rowY1 + cardH + 22, -- 386
		toColor(PALETTE.amberCore), -- 386
		0, -- 386
		0.5, -- 386
		"Left", -- 386
		1.2, -- 386
		0.95 -- 386
	) -- 386
	local i = 0 -- 388
	do -- 388
		i = 0 -- 389
		while i < #ROOMS do -- 389
			local col = i % cols -- 390
			local row = math.floor(i / cols) -- 391
			local cx = leftX + col * (cardW + gapX) -- 392
			local cy = row == 0 and rowY0 or rowY1 -- 393
			local theme = themeOf(ROOMS[i + 1].key) -- 394
			local hover = pointer.x >= cx and pointer.x <= cx + cardW and pointer.y >= cy and pointer.y <= cy + cardH -- 395
			if hover and self.pointerActive then -- 395
				self.chapterSelected = i -- 397
				hitIdx = i -- 398
			end -- 398
			local active = self.chapterSelected == i -- 400
			drawInkPanel( -- 403
				uiDraw, -- 403
				uiArt, -- 403
				"chap_panel_" .. tostring(i), -- 403
				cx, -- 403
				cy, -- 403
				cardW, -- 403
				cardH, -- 403
				active and PALETTE.inkWarm or PALETTE.inkWash, -- 403
				active and 0.94 or 0.82, -- 403
				active, -- 403
				-2 -- 403
			) -- 403
			local bgSlot = "bgFar_" .. ROOMS[i + 1].key -- 405
			uiArt:tryPlace( -- 406
				bgSlot, -- 406
				"chap_thumb_" .. tostring(i), -- 406
				cx + cardW * 0.5, -- 406
				cy + 6, -- 406
				cardW - 12, -- 406
				cardH - 12, -- 406
				{opacity = active and 0.44 or 0.24, layer = -1} -- 406
			) -- 406
			fillVGradRect( -- 410
				uiInkDraw, -- 411
				cx + 4, -- 412
				cy + 4, -- 413
				cardW - 8, -- 414
				cardH * 0.72, -- 415
				Color(12, 13, 18, active and 215 or 200), -- 416
				Color(12, 13, 18, 25) -- 417
			) -- 417
			local frameCol = active and (ROOMS[i + 1].key == "gate" and PALETTE.sealRedBright or PALETTE.amber) or PALETTE.bronzeDim -- 420
			drawScrollFrame( -- 421
				uiInkDraw, -- 421
				uiArt, -- 421
				"chap_frame_" .. tostring(i), -- 421
				cx, -- 421
				cy, -- 421
				cardW, -- 421
				cardH, -- 421
				frameCol, -- 421
				active and 1 or 0.65, -- 421
				active, -- 421
				false, -- 421
				18, -- 421
				2 -- 421
			) -- 421
			if active then -- 421
				fillRadialGlow( -- 424
					uiGlow, -- 424
					cx + cardW - 26, -- 424
					cy + cardH - 26, -- 424
					36, -- 424
					36, -- 424
					toColor(PALETTE.cinnabar, 36), -- 424
					Color(186, 66, 54, 0), -- 424
					12 -- 424
				) -- 424
			end -- 424
			drawSealStamp( -- 428
				uiInkDraw, -- 429
				uiArt, -- 430
				texts, -- 431
				"chap_num_" .. tostring(i), -- 432
				cx + cardW - 26, -- 433
				cy + cardH - 26, -- 434
				30, -- 435
				theme.numeralZh, -- 436
				active and PALETTE.sealRed or PALETTE.bronzeDim, -- 437
				active and PALETTE.sealText or PALETTE.textMid, -- 438
				active and 0.98 or 0.85, -- 439
				active, -- 440
				4 -- 441
			) -- 441
			texts:put( -- 445
				"xs", -- 445
				(theme.actCode .. " · ") .. theme.lineTag, -- 445
				cx + 16, -- 445
				cy + 54, -- 445
				toColor(active and PALETTE.amberCore or theme.accent), -- 445
				0, -- 445
				0.5, -- 445
				"Left", -- 445
				0.8, -- 445
				0.94 -- 445
			) -- 445
			texts:put( -- 446
				"md", -- 446
				theme.titleZh, -- 446
				cx + 16, -- 446
				cy + 26, -- 446
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 446
				0, -- 446
				0.5, -- 446
				"Left", -- 446
				0.6, -- 446
				1 -- 446
			) -- 446
			i = i + 1 -- 389
		end -- 389
	end -- 389
	local backX = leftX -- 450
	local backY = 44 -- 451
	local backHover = pointer.x >= backX and pointer.x <= backX + 188 and pointer.y >= backY and pointer.y <= backY + 38 -- 452
	drawInkWashStrip( -- 453
		uiDraw, -- 453
		uiArt, -- 453
		"chap_back_bg", -- 453
		backX + 90, -- 453
		backY + 19, -- 453
		200, -- 453
		38, -- 453
		backHover and PALETTE.cinnabarDeep or PALETTE.inkWash, -- 453
		backHover and 0.78 or 0.64, -- 453
		false, -- 453
		0 -- 453
	) -- 453
	drawInkKeycap( -- 454
		uiInkDraw, -- 454
		texts, -- 454
		backX + 6, -- 454
		backY + 7, -- 454
		46, -- 454
		24, -- 454
		"ESC", -- 454
		backHover and PALETTE.sealRedBright or PALETTE.bronzeLine, -- 454
		0.95, -- 454
		backHover -- 454
	) -- 454
	texts:put( -- 455
		"sm", -- 455
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 455
		backX + 62, -- 455
		backY + 19, -- 455
		toColor(backHover and PALETTE.amberCore or PALETTE.textMid), -- 455
		0, -- 455
		0.5, -- 455
		"Left", -- 455
		1.2, -- 455
		1 -- 455
	) -- 455
	if clicked and backHover then -- 455
		return {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 458
	end -- 458
	if mk.confirm or clicked and hitIdx >= 0 then -- 458
		return {type = "jump", roomIndex = self.chapterSelected} -- 461
	end -- 461
	return {type = "none"} -- 463
end -- 337
function MenuRenderer.prototype.drawControls(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 466
	if input.pause.pressed or mk.back or mk.confirm then -- 466
		return {type = "backTitle"} -- 480
	end -- 480
	uiDraw:drawRect( -- 482
		Rect(0, 0, w, h), -- 482
		Color(11, 12, 17, 182) -- 482
	) -- 482
	local leftX = 96 -- 484
	drawSealStamp( -- 485
		uiInkDraw, -- 485
		uiArt, -- 485
		texts, -- 485
		"ctrl_head_seal", -- 485
		leftX + 18, -- 485
		h - 86, -- 485
		34, -- 485
		"诀", -- 485
		PALETTE.sealRed, -- 485
		PALETTE.sealText, -- 485
		0.96, -- 485
		true, -- 485
		4 -- 485
	) -- 485
	texts:put( -- 486
		"banner", -- 486
		"操作说明", -- 486
		leftX + 48, -- 486
		h - 86, -- 486
		toColor(PALETTE.textBright), -- 486
		0, -- 486
		0.5, -- 486
		"Left", -- 486
		4, -- 486
		1 -- 486
	) -- 486
	texts:put( -- 487
		"xs", -- 487
		"键鼠执器要诀", -- 487
		leftX + 236, -- 487
		h - 90, -- 487
		toColor(PALETTE.textDim), -- 487
		0, -- 487
		0.5, -- 487
		"Left", -- 487
		1.2, -- 487
		0.88 -- 487
	) -- 487
	drawBrushDivider( -- 488
		uiInkDraw, -- 488
		uiArt, -- 488
		"ctrl_head_div", -- 488
		w * 0.5, -- 488
		h - 118, -- 488
		w - leftX * 2, -- 488
		14, -- 488
		PALETTE.bronzeDim, -- 488
		0.72, -- 488
		2 -- 488
	) -- 488
	local colGap = 34 -- 490
	local colW = (w - leftX * 2 - colGap) * 0.5 -- 491
	local panelY = h * 0.18 -- 492
	local panelH = h * 0.58 -- 493
	drawInkPanel( -- 496
		uiDraw, -- 496
		uiArt, -- 496
		"ctrl_left_bg", -- 496
		leftX, -- 496
		panelY, -- 496
		colW, -- 496
		panelH, -- 496
		PALETTE.inkWash, -- 496
		0.92, -- 496
		true, -- 496
		-1 -- 496
	) -- 496
	drawScrollFrame( -- 497
		uiInkDraw, -- 497
		uiArt, -- 497
		"ctrl_left_frame", -- 497
		leftX, -- 497
		panelY, -- 497
		colW, -- 497
		panelH, -- 497
		PALETTE.cyan, -- 497
		0.88, -- 497
		true, -- 497
		true, -- 497
		20, -- 497
		2 -- 497
	) -- 497
	drawSealStamp( -- 498
		uiInkDraw, -- 498
		uiArt, -- 498
		texts, -- 498
		"ctrl_left_seal", -- 498
		leftX + 38, -- 498
		panelY + panelH - 36, -- 498
		28, -- 498
		"戍", -- 498
		PALETTE.cyanDim, -- 498
		PALETTE.moonPale, -- 498
		0.96, -- 498
		true, -- 498
		4 -- 498
	) -- 498
	texts:put( -- 499
		"md", -- 499
		"周戍 · 护送与交锋", -- 499
		leftX + 62, -- 499
		panelY + panelH - 36, -- 499
		toColor(PALETTE.cyanCore), -- 499
		0, -- 499
		0.5, -- 499
		"Left", -- 499
		1.2, -- 499
		1 -- 499
	) -- 499
	drawBrushDivider( -- 500
		uiInkDraw, -- 500
		uiArt, -- 500
		"ctrl_left_div", -- 500
		leftX + colW * 0.5, -- 500
		panelY + panelH - 60, -- 500
		colW - 44, -- 500
		10, -- 500
		PALETTE.cyanDim, -- 500
		0.65, -- 500
		2 -- 500
	) -- 500
	local sRows = { -- 502
		{"A / D", "左右移动"}, -- 503
		{"鼠标 + 左键", "瞄准 / 发射火铳"}, -- 504
		{"SHIFT 按住", "贴靠柜台 / 街垒挡枪"}, -- 505
		{"SPACE", "平地翻滚 / 贴矮台翻越"}, -- 506
		{"E", "递物 / 敲两下安抚 / 按住+D 推车"}, -- 507
		{"ESC / R", "暂歇 / 从检查点重试"} -- 508
	} -- 508
	local i = 0 -- 510
	do -- 510
		i = 0 -- 511
		while i < #sRows do -- 511
			local ry = panelY + panelH - 96 - i * 48 -- 512
			drawInkKeycap( -- 513
				uiInkDraw, -- 513
				texts, -- 513
				leftX + 26, -- 513
				ry - 13, -- 513
				124, -- 513
				26, -- 513
				sRows[i + 1][1], -- 513
				PALETTE.cyan, -- 513
				0.95, -- 513
				false -- 513
			) -- 513
			texts:put( -- 514
				"sm", -- 514
				sRows[i + 1][2], -- 514
				leftX + 166, -- 514
				ry, -- 514
				toColor(PALETTE.textBright), -- 514
				0, -- 514
				0.5, -- 514
				"Left", -- 514
				0.4, -- 514
				0.95 -- 514
			) -- 514
			i = i + 1 -- 511
		end -- 511
	end -- 511
	local rightX = leftX + colW + colGap -- 518
	drawInkPanel( -- 519
		uiDraw, -- 519
		uiArt, -- 519
		"ctrl_right_bg", -- 519
		rightX, -- 519
		panelY, -- 519
		colW, -- 519
		panelH, -- 519
		PALETTE.inkWash, -- 519
		0.92, -- 519
		true, -- 519
		-1 -- 519
	) -- 519
	drawScrollFrame( -- 520
		uiInkDraw, -- 520
		uiArt, -- 520
		"ctrl_right_frame", -- 520
		rightX, -- 520
		panelY, -- 520
		colW, -- 520
		panelH, -- 520
		PALETTE.amber, -- 520
		0.88, -- 520
		true, -- 520
		true, -- 520
		20, -- 520
		2 -- 520
	) -- 520
	drawSealStamp( -- 521
		uiInkDraw, -- 521
		uiArt, -- 521
		texts, -- 521
		"ctrl_right_seal", -- 521
		rightX + 38, -- 521
		panelY + panelH - 36, -- 521
		28, -- 521
		"满", -- 521
		PALETTE.amberDim, -- 521
		PALETTE.amberCore, -- 521
		0.96, -- 521
		true, -- 521
		4 -- 521
	) -- 521
	texts:put( -- 522
		"md", -- 522
		"小满 · 潜行与寻路", -- 522
		rightX + 62, -- 522
		panelY + panelH - 36, -- 522
		toColor(PALETTE.amberCore), -- 522
		0, -- 522
		0.5, -- 522
		"Left", -- 522
		1.2, -- 522
		1 -- 522
	) -- 522
	drawBrushDivider( -- 523
		uiInkDraw, -- 523
		uiArt, -- 523
		"ctrl_right_div", -- 523
		rightX + colW * 0.5, -- 523
		panelY + panelH - 60, -- 523
		colW - 44, -- 523
		10, -- 523
		PALETTE.amberDim, -- 523
		0.65, -- 523
		2 -- 523
	) -- 523
	local cRows = { -- 525
		{"A / D", "潜行行走"}, -- 526
		{"SHIFT 按住", "轻步慢走（压低脚步声）"}, -- 527
		{"S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 528
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 529
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉板车"}, -- 530
		{"F 按住→松手", "预览落点，投瓶引开拾荒者"} -- 531
	} -- 531
	do -- 531
		i = 0 -- 533
		while i < #cRows do -- 533
			local ry = panelY + panelH - 96 - i * 48 -- 534
			drawInkKeycap( -- 535
				uiInkDraw, -- 535
				texts, -- 535
				rightX + 26, -- 535
				ry - 13, -- 535
				128, -- 535
				26, -- 535
				cRows[i + 1][1], -- 535
				PALETTE.amber, -- 535
				0.95, -- 535
				false -- 535
			) -- 535
			texts:put( -- 536
				"sm", -- 536
				cRows[i + 1][2], -- 536
				rightX + 170, -- 536
				ry, -- 536
				toColor(PALETTE.textBright), -- 536
				0, -- 536
				0.5, -- 536
				"Left", -- 536
				0.4, -- 536
				0.95 -- 536
			) -- 536
			i = i + 1 -- 533
		end -- 533
	end -- 533
	local backX = leftX -- 540
	local backY = 44 -- 541
	local backHover = pointer.x >= backX and pointer.x <= backX + 224 and pointer.y >= backY and pointer.y <= backY + 38 -- 542
	drawInkWashStrip( -- 543
		uiDraw, -- 543
		uiArt, -- 543
		"ctrl_back_bg", -- 543
		backX + 108, -- 543
		backY + 19, -- 543
		232, -- 543
		38, -- 543
		backHover and PALETTE.cinnabarDeep or PALETTE.inkWash, -- 543
		backHover and 0.78 or 0.64, -- 543
		false, -- 543
		0 -- 543
	) -- 543
	drawInkKeycap( -- 544
		uiInkDraw, -- 544
		texts, -- 544
		backX + 6, -- 544
		backY + 7, -- 544
		88, -- 544
		24, -- 544
		"ESC / ENTER", -- 544
		backHover and PALETTE.sealRedBright or PALETTE.bronzeLine, -- 544
		0.95, -- 544
		backHover -- 544
	) -- 544
	texts:put( -- 545
		"sm", -- 545
		"返回标题", -- 545
		backX + 104, -- 545
		backY + 19, -- 545
		toColor(backHover and PALETTE.amberCore or PALETTE.textMid), -- 545
		0, -- 545
		0.5, -- 545
		"Left", -- 545
		1.2, -- 545
		1 -- 545
	) -- 545
	if clicked and backHover then -- 545
		return {type = "backTitle"} -- 548
	end -- 548
	return {type = "none"} -- 550
end -- 466
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale) -- 554
	self.time = self.time + dt -- 566
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 567
	local mk = self:readMenuKeys() -- 568
	local clicked = self:clickEdge(input) -- 569
	self.pointerActive = input.inside and (clicked or math.abs(input.mdx) + math.abs(input.mdy) >= uiScale and not mk.up and not mk.down and not mk.confirm) -- 570
	if mk.back or input.pause.pressed then -- 570
		return {type = "resume"} -- 574
	end -- 574
	if mk.up then -- 574
		self.pauseSelected = (self.pauseSelected + #PAUSE_ITEMS - 1) % #PAUSE_ITEMS -- 578
	elseif mk.down then -- 578
		self.pauseSelected = (self.pauseSelected + 1) % #PAUSE_ITEMS -- 580
	end -- 580
	uiDraw:drawRect( -- 584
		Rect(0, 0, w, h), -- 584
		Color(9, 10, 14, 178) -- 584
	) -- 584
	local boxW = 376 -- 586
	local boxH = 368 -- 587
	local bx = (w - boxW) * 0.5 -- 588
	local by = (h - boxH) * 0.5 -- 589
	drawInkPanel( -- 592
		uiDraw, -- 592
		uiArt, -- 592
		"pause_scroll_bg", -- 592
		bx, -- 592
		by, -- 592
		boxW, -- 592
		boxH, -- 592
		PALETTE.inkWash, -- 592
		0.94, -- 592
		true, -- 592
		-1 -- 592
	) -- 592
	drawScrollFrame( -- 593
		uiInkDraw, -- 593
		uiArt, -- 593
		"pause_scroll_frame", -- 593
		bx, -- 593
		by, -- 593
		boxW, -- 593
		boxH, -- 593
		PALETTE.bronzeLine, -- 593
		0.94, -- 593
		true, -- 593
		true, -- 593
		22, -- 593
		2 -- 593
	) -- 593
	texts:put( -- 596
		"banner", -- 596
		"暂歇", -- 596
		w * 0.5 - 16, -- 596
		by + boxH - 52, -- 596
		toColor(PALETTE.textBright), -- 596
		0.5, -- 596
		0.5, -- 596
		"Center", -- 596
		8, -- 596
		1 -- 596
	) -- 596
	drawSealStamp( -- 597
		uiInkDraw, -- 597
		uiArt, -- 597
		texts, -- 597
		"pause_head_seal", -- 597
		w * 0.5 + 52, -- 597
		by + boxH - 52, -- 597
		26, -- 597
		"停", -- 597
		PALETTE.sealRed, -- 597
		PALETTE.sealText, -- 597
		0.95, -- 597
		true, -- 597
		4 -- 597
	) -- 597
	drawBrushDivider( -- 598
		uiInkDraw, -- 598
		uiArt, -- 598
		"pause_head_div", -- 598
		w * 0.5, -- 598
		by + boxH - 86, -- 598
		boxW - 64, -- 598
		12, -- 598
		PALETTE.bronzeDim, -- 598
		0.7, -- 598
		2 -- 598
	) -- 598
	local hitIdx = -1 -- 600
	local i = 0 -- 601
	do -- 601
		i = 0 -- 602
		while i < #PAUSE_ITEMS do -- 602
			local iy = by + boxH - 146 - i * 56 -- 603
			local ix = bx + 36 -- 604
			local iw = boxW - 72 -- 605
			local ih = 44 -- 606
			local hover = pointer.x >= ix and pointer.x <= ix + iw and pointer.y >= iy and pointer.y <= iy + ih -- 607
			if hover and self.pointerActive then -- 607
				self.pauseSelected = i -- 609
				hitIdx = i -- 610
			end -- 610
			local active = self.pauseSelected == i -- 612
			local cy = iy + ih * 0.5 -- 613
			if active then -- 613
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.8) -- 616
				drawInkWashStrip( -- 617
					uiDraw, -- 617
					uiArt, -- 617
					"pause_item_red_" .. tostring(i), -- 617
					ix + iw * 0.5, -- 617
					cy, -- 617
					iw + 16, -- 617
					ih + 4, -- 617
					PALETTE.cinnabarDeep, -- 617
					0.56 * breathe, -- 617
					true, -- 617
					0 -- 617
				) -- 617
				drawBrushDivider( -- 618
					uiInkDraw, -- 618
					uiArt, -- 618
					"pause_item_line_" .. tostring(i), -- 618
					ix + iw * 0.5, -- 618
					iy + 2, -- 618
					iw - 12, -- 618
					8, -- 618
					PALETTE.bronzeLine, -- 618
					0.52, -- 618
					2 -- 618
				) -- 618
				drawSealStamp( -- 619
					uiInkDraw, -- 619
					uiArt, -- 619
					texts, -- 619
					"pause_item_seal_" .. tostring(i), -- 619
					ix + 24, -- 619
					cy, -- 619
					24, -- 619
					PAUSE_ITEMS[i + 1].seal, -- 619
					PALETTE.sealRed, -- 619
					PALETTE.sealText, -- 619
					0.96, -- 619
					true, -- 619
					4 -- 619
				) -- 619
				fillRadialGlow( -- 620
					uiGlow, -- 620
					ix + 24, -- 620
					cy, -- 620
					28, -- 620
					18, -- 620
					toColor(PALETTE.cinnabar, 32 * breathe), -- 620
					Color(168, 46, 40, 0), -- 620
					10 -- 620
				) -- 620
			else -- 620
				uiArt:tryPlace( -- 622
					"ink_dot", -- 622
					"pause_item_dot_" .. tostring(i), -- 622
					ix + 24, -- 622
					cy, -- 622
					8, -- 622
					8, -- 622
					{ -- 622
						color = toColor(PALETTE.bronzeDim), -- 623
						opacity = 0.55, -- 623
						layer = 2 -- 623
					} -- 623
				) -- 623
			end -- 623
			texts:put( -- 627
				"md", -- 628
				PAUSE_ITEMS[i + 1].zh, -- 629
				ix + (active and 54 or 46), -- 630
				cy, -- 631
				toColor(active and PALETTE.amberCore or PALETTE.textMid), -- 632
				0, -- 633
				0.5, -- 634
				"Left", -- 635
				active and 2.4 or 1.4, -- 636
				active and 1 or 0.88 -- 637
			) -- 637
			i = i + 1 -- 602
		end -- 602
	end -- 602
	texts:put( -- 641
		"xs", -- 641
		"ESC 继续   ·   Enter 或点击确认", -- 641
		w * 0.5, -- 641
		by + 24, -- 641
		toColor(PALETTE.textDim), -- 641
		0.5, -- 641
		0.5, -- 641
		"Center", -- 641
		0.6, -- 641
		0.85 -- 641
	) -- 641
	if mk.confirm or clicked and hitIdx >= 0 then -- 641
		local id = PAUSE_ITEMS[self.pauseSelected + 1].id -- 644
		if id == "resume" then -- 644
			return {type = "resume"} -- 646
		end -- 646
		if id == "retry" then -- 646
			return {type = "retry"} -- 649
		end -- 649
		if id == "chapters" then -- 649
			return {type = "openChapters"} -- 652
		end -- 652
		return {type = "toTitle"} -- 654
	end -- 654
	return {type = "none"} -- 656
end -- 554
return ____exports -- 554