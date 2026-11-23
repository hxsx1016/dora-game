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
	self.prevClick = false -- 64
	self.queuedUp = false -- 65
	self.queuedDown = false -- 66
	self.queuedLeft = false -- 67
	self.queuedRight = false -- 68
	self.queuedConfirm = false -- 69
	self.queuedBack = false -- 70
	self.time = 0 -- 71
end -- 55
function MenuRenderer.prototype.onKeyEvent(self, key) -- 74
	if key == "Up" or key == "W" then -- 74
		self.queuedUp = true -- 76
	elseif key == "Down" or key == "S" then -- 76
		self.queuedDown = true -- 78
	elseif key == "Left" or key == "A" then -- 78
		self.queuedLeft = true -- 80
	elseif key == "Right" or key == "D" then -- 80
		self.queuedRight = true -- 82
	elseif key == "Return" or key == "Space" then -- 82
		self.queuedConfirm = true -- 84
	elseif key == "Escape" then -- 84
		self.queuedBack = true -- 86
	end -- 86
end -- 74
function MenuRenderer.prototype.readMenuKeys(self) -- 90
	local u = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 91
	local d = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 92
	local l = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 93
	local r = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 94
	local e = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 95
	local res = { -- 96
		up = u and not self.prevUp or self.queuedUp, -- 97
		down = d and not self.prevDown or self.queuedDown, -- 98
		left = l and not self.prevLeft or self.queuedLeft, -- 99
		right = r and not self.prevRight or self.queuedRight, -- 100
		confirm = e and not self.prevEnter or self.queuedConfirm, -- 101
		back = self.queuedBack -- 102
	} -- 102
	self.prevUp = u -- 104
	self.prevDown = d -- 105
	self.prevLeft = l -- 106
	self.prevRight = r -- 107
	self.prevEnter = e -- 108
	self.queuedUp = false -- 109
	self.queuedDown = false -- 110
	self.queuedLeft = false -- 111
	self.queuedRight = false -- 112
	self.queuedConfirm = false -- 113
	self.queuedBack = false -- 114
	return res -- 115
end -- 90
function MenuRenderer.prototype.clickEdge(self, input) -- 118
	local held = input.fire.held -- 119
	local fired = held and not self.prevClick -- 120
	self.prevClick = held -- 121
	return fired -- 122
end -- 118
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 126
	self.time = self.time + dt -- 143
	local artW = math.max(w, h * 16 / 9) -- 144
	local artH = artW * 9 / 16 -- 145
	if not backdropArt:tryPlace( -- 145
		"title_backdrop", -- 146
		"menu_landscape", -- 146
		w * 0.5, -- 146
		(h - artH) * 0.5, -- 146
		artW, -- 146
		artH -- 146
	) then -- 146
		stage:drawMenuBackdrop( -- 147
			bgDraw, -- 147
			bgGlow, -- 147
			w, -- 147
			h, -- 147
			self.time -- 147
		) -- 147
	end -- 147
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 150
	w = w / uiScale -- 151
	h = h / uiScale -- 152
	local mk = self:readMenuKeys() -- 154
	local clicked = self:clickEdge(input) -- 155
	if screen == "title" then -- 155
		return self:drawTitle( -- 158
			mk, -- 158
			clicked, -- 158
			pointer, -- 158
			uiDraw, -- 158
			uiInkDraw, -- 158
			uiArt, -- 158
			uiGlow, -- 158
			texts, -- 158
			w, -- 158
			h -- 158
		) -- 158
	end -- 158
	if screen == "chapters" then -- 158
		return self:drawChapters( -- 161
			mk, -- 161
			clicked, -- 161
			input, -- 161
			pointer, -- 161
			uiDraw, -- 161
			uiInkDraw, -- 161
			uiArt, -- 161
			uiGlow, -- 161
			texts, -- 161
			w, -- 161
			h -- 161
		) -- 161
	end -- 161
	return self:drawControls( -- 163
		mk, -- 163
		clicked, -- 163
		input, -- 163
		pointer, -- 163
		uiDraw, -- 163
		uiInkDraw, -- 163
		uiArt, -- 163
		uiGlow, -- 163
		texts, -- 163
		w, -- 163
		h -- 163
	) -- 163
end -- 126
function MenuRenderer.prototype.drawTitle(self, mk, clicked, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 166
	if mk.up then -- 166
		self.selected = (self.selected + #TITLE_ITEMS - 1) % #TITLE_ITEMS -- 179
	elseif mk.down then -- 179
		self.selected = (self.selected + 1) % #TITLE_ITEMS -- 181
	end -- 181
	fillHGradRect( -- 185
		uiDraw, -- 185
		0, -- 185
		0, -- 185
		w * 0.24, -- 185
		h, -- 185
		Color(10, 11, 16, 198), -- 185
		Color(10, 11, 16, 138) -- 185
	) -- 185
	fillHGradRect( -- 186
		uiDraw, -- 186
		w * 0.24, -- 186
		0, -- 186
		w * 0.28, -- 186
		h, -- 186
		Color(10, 11, 16, 138), -- 186
		Color(10, 11, 16, 0) -- 186
	) -- 186
	fillVGradRect( -- 187
		uiDraw, -- 187
		0, -- 187
		0, -- 187
		w, -- 187
		86, -- 187
		Color(8, 9, 13, 155), -- 187
		Color(8, 9, 13, 0) -- 187
	) -- 187
	local titleX = 152 -- 190
	local topY = h - 108 -- 191
	local charStep = 64 -- 192
	uiArt:tryPlace( -- 195
		"ink_splatter", -- 195
		"title_mist", -- 195
		titleX + 8, -- 195
		topY - 96, -- 195
		220, -- 195
		260, -- 195
		{ -- 195
			color = toColor(PALETTE.inkVoid), -- 196
			opacity = 0.42, -- 196
			layer = -1 -- 196
		} -- 196
	) -- 196
	uiArt:tryPlace( -- 198
		"ink_vbrush", -- 198
		"title_vrule_l", -- 198
		titleX - 48, -- 198
		topY - 102, -- 198
		16, -- 198
		264, -- 198
		{ -- 198
			color = toColor(PALETTE.bronzeDim), -- 199
			opacity = 0.56, -- 199
			layer = 1 -- 199
		} -- 199
	) -- 199
	uiArt:tryPlace( -- 201
		"ink_vbrush", -- 201
		"title_vrule_r", -- 201
		titleX + 76, -- 201
		topY - 118, -- 201
		12, -- 201
		228, -- 201
		{ -- 201
			color = toColor(PALETTE.bronzeLine), -- 202
			opacity = 0.36, -- 202
			layer = 1 -- 202
		} -- 202
	) -- 202
	local c = 0 -- 205
	do -- 205
		c = 0 -- 206
		while c < #VERTICAL_TITLE do -- 206
			local cy = topY - c * charStep -- 207
			texts:put( -- 208
				"title", -- 209
				VERTICAL_TITLE[c + 1], -- 210
				titleX, -- 211
				cy, -- 212
				toColor(PALETTE.textBright), -- 213
				0.5, -- 214
				0.5, -- 215
				"Center", -- 216
				0, -- 217
				0.98, -- 218
				0.15, -- 219
				Color(8, 9, 13, 235) -- 220
			) -- 220
			c = c + 1 -- 206
		end -- 206
	end -- 206
	drawOvalSeal( -- 225
		uiInkDraw, -- 226
		uiArt, -- 227
		texts, -- 228
		"title_seal", -- 229
		titleX + 46, -- 230
		topY - 3 * charStep + 10, -- 231
		32, -- 232
		58, -- 233
		"守", -- 234
		"望", -- 235
		PALETTE.sealRed, -- 236
		PALETTE.sealText, -- 237
		0.96, -- 238
		4 -- 239
	) -- 239
	local epigraphX = titleX + 100 -- 243
	texts:put( -- 244
		"sm", -- 244
		"城破那天，他留下断后。", -- 244
		epigraphX, -- 244
		topY - 82, -- 244
		toColor(PALETTE.textMid), -- 244
		0, -- 244
		0.5, -- 244
		"Left", -- 244
		1, -- 244
		0.92 -- 244
	) -- 244
	texts:put( -- 245
		"sm", -- 245
		"她独自走向北塔。", -- 245
		epigraphX, -- 245
		topY - 114, -- 245
		toColor(PALETTE.amberCore), -- 245
		0, -- 245
		0.5, -- 245
		"Left", -- 245
		1, -- 245
		0.9 -- 245
	) -- 245
	drawBrushDivider( -- 246
		uiInkDraw, -- 246
		uiArt, -- 246
		"title_epigraph_div", -- 246
		epigraphX + 94, -- 246
		topY - 140, -- 246
		196, -- 246
		12, -- 246
		PALETTE.bronzeDim, -- 246
		0.62, -- 246
		2 -- 246
	) -- 246
	texts:put( -- 247
		"xs", -- 247
		"双线叙事 · 护送与潜行", -- 247
		epigraphX, -- 247
		topY - 162, -- 247
		toColor(PALETTE.textDim), -- 247
		0, -- 247
		0.5, -- 247
		"Left", -- 247
		1.4, -- 247
		0.85 -- 247
	) -- 247
	local menuX = 114 -- 250
	local btnW = 304 -- 251
	local btnH = 48 -- 252
	local gap = 14 -- 253
	local startY = 266 -- 254
	local hitIdx = -1 -- 255
	local i = 0 -- 257
	do -- 257
		i = 0 -- 258
		while i < #TITLE_ITEMS do -- 258
			local by = startY - i * (btnH + gap) -- 259
			local hover = pointer.x >= menuX - 10 and pointer.x <= menuX + btnW and pointer.y >= by and pointer.y <= by + btnH -- 260
			if hover then -- 260
				self.selected = i -- 262
				hitIdx = i -- 263
			end -- 263
			local active = self.selected == i -- 265
			local cy = by + btnH * 0.5 -- 266
			local shiftX = active and 8 or 0 -- 267
			if active then -- 267
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.6) -- 270
				drawInkWashStrip( -- 272
					uiDraw, -- 272
					uiArt, -- 272
					"title_btn_ink_" .. tostring(i), -- 272
					menuX + btnW * 0.5 + 4, -- 272
					cy, -- 272
					btnW + 34, -- 272
					btnH + 10, -- 272
					PALETTE.inkWash, -- 272
					0.84, -- 272
					false, -- 272
					0 -- 272
				) -- 272
				drawInkWashStrip( -- 273
					uiDraw, -- 273
					uiArt, -- 273
					"title_btn_red_" .. tostring(i), -- 273
					menuX + btnW * 0.44 + 4, -- 273
					cy, -- 273
					btnW * 0.84, -- 273
					btnH - 2, -- 273
					PALETTE.cinnabarDeep, -- 273
					0.46 * breathe, -- 273
					false, -- 273
					1 -- 273
				) -- 273
				drawBrushDivider( -- 274
					uiInkDraw, -- 274
					uiArt, -- 274
					"title_btn_line_" .. tostring(i), -- 274
					menuX + btnW * 0.46, -- 274
					by + 3, -- 274
					btnW * 0.78, -- 274
					10, -- 274
					PALETTE.bronzeLine, -- 274
					0.55, -- 274
					2 -- 274
				) -- 274
				drawSealStamp( -- 276
					uiInkDraw, -- 276
					uiArt, -- 276
					texts, -- 276
					"title_btn_seal_" .. tostring(i), -- 276
					menuX + 18, -- 276
					cy, -- 276
					26, -- 276
					TITLE_ITEMS[i + 1].seal, -- 276
					PALETTE.sealRed, -- 276
					PALETTE.sealText, -- 276
					0.96, -- 276
					true, -- 276
					4 -- 276
				) -- 276
				fillRadialGlow( -- 277
					uiGlow, -- 277
					menuX + 18, -- 277
					cy, -- 277
					34, -- 277
					20, -- 277
					toColor(PALETTE.cinnabar, 36 * breathe), -- 277
					Color(168, 46, 40, 0), -- 277
					12 -- 277
				) -- 277
			else -- 277
				uiArt:tryPlace( -- 280
					"ink_dot", -- 280
					"title_btn_dot_" .. tostring(i), -- 280
					menuX + 18, -- 280
					cy, -- 280
					9, -- 280
					9, -- 280
					{ -- 280
						color = toColor(PALETTE.bronzeDim), -- 281
						opacity = 0.58, -- 281
						layer = 2 -- 281
					} -- 281
				) -- 281
			end -- 281
			texts:put( -- 285
				"md", -- 286
				TITLE_ITEMS[i + 1].zh, -- 287
				menuX + 42 + shiftX, -- 288
				cy, -- 289
				toColor(active and PALETTE.amberCore or PALETTE.textMid), -- 290
				0, -- 291
				0.5, -- 292
				"Left", -- 293
				active and 3.2 or 2, -- 294
				active and 1 or 0.88 -- 295
			) -- 295
			i = i + 1 -- 258
		end -- 258
	end -- 258
	texts:put( -- 299
		"xs", -- 299
		"↑ ↓ 择项   ·   Enter 或点击启程", -- 299
		menuX + 8, -- 299
		46, -- 299
		toColor(PALETTE.textDim), -- 299
		0, -- 299
		0.5, -- 299
		"Left", -- 299
		0.8, -- 299
		0.85 -- 299
	) -- 299
	if mk.confirm or clicked and hitIdx >= 0 then -- 299
		local id = TITLE_ITEMS[self.selected + 1].id -- 302
		if id == "start" then -- 302
			return {type = "start"} -- 304
		end -- 304
		if id == "chapters" then -- 304
			return {type = "openChapters"} -- 307
		end -- 307
		return {type = "openControls"} -- 309
	end -- 309
	return {type = "none"} -- 311
end -- 166
function MenuRenderer.prototype.drawChapters(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 314
	if input.pause.pressed or mk.back then -- 314
		return {type = "backTitle"} -- 328
	end -- 328
	if mk.left then -- 328
		self.chapterSelected = (self.chapterSelected + #ROOMS - 1) % #ROOMS -- 331
	elseif mk.right then -- 331
		self.chapterSelected = (self.chapterSelected + 1) % #ROOMS -- 333
	elseif mk.up then -- 333
		self.chapterSelected = (self.chapterSelected + #ROOMS - 4) % #ROOMS -- 335
	elseif mk.down then -- 335
		self.chapterSelected = (self.chapterSelected + 4) % #ROOMS -- 337
	end -- 337
	uiDraw:drawRect( -- 341
		Rect(0, 0, w, h), -- 341
		Color(11, 12, 17, 178) -- 341
	) -- 341
	local leftX = 96 -- 343
	drawSealStamp( -- 345
		uiInkDraw, -- 345
		uiArt, -- 345
		texts, -- 345
		"chap_head_seal", -- 345
		leftX + 18, -- 345
		h - 86, -- 345
		34, -- 345
		"卷", -- 345
		PALETTE.sealRed, -- 345
		PALETTE.sealText, -- 345
		0.96, -- 345
		true, -- 345
		4 -- 345
	) -- 345
	texts:put( -- 346
		"banner", -- 346
		"选择章节", -- 346
		leftX + 48, -- 346
		h - 86, -- 346
		toColor(PALETTE.textBright), -- 346
		0, -- 346
		0.5, -- 346
		"Left", -- 346
		4, -- 346
		1 -- 346
	) -- 346
	texts:put( -- 347
		"xs", -- 347
		"双线八幕 · 行纪直达", -- 347
		leftX + 236, -- 347
		h - 90, -- 347
		toColor(PALETTE.textDim), -- 347
		0, -- 347
		0.5, -- 347
		"Left", -- 347
		1.2, -- 347
		0.88 -- 347
	) -- 347
	drawBrushDivider( -- 348
		uiInkDraw, -- 348
		uiArt, -- 348
		"chap_head_div", -- 348
		w * 0.5, -- 348
		h - 118, -- 348
		w - leftX * 2, -- 348
		14, -- 348
		PALETTE.bronzeDim, -- 348
		0.72, -- 348
		2 -- 348
	) -- 348
	local cols = 4 -- 350
	local gapX = 22 -- 351
	local cardW = math.min(262, (w - leftX * 2 - (cols - 1) * gapX) / cols) -- 352
	local cardH = 140 -- 353
	local rowY0 = h * 0.52 -- 354
	local rowY1 = h * 0.21 -- 355
	local hitIdx = -1 -- 356
	drawSealStamp( -- 359
		uiInkDraw, -- 359
		uiArt, -- 359
		texts, -- 359
		"vol1_seal", -- 359
		leftX + 12, -- 359
		rowY0 + cardH + 22, -- 359
		22, -- 359
		"上", -- 359
		PALETTE.cyanDim, -- 359
		PALETTE.moonPale, -- 359
		0.92, -- 359
		true, -- 359
		4 -- 359
	) -- 359
	texts:put( -- 360
		"sm", -- 360
		"上卷 · 孤城护童（周戍）", -- 360
		leftX + 30, -- 360
		rowY0 + cardH + 22, -- 360
		toColor(PALETTE.cyanCore), -- 360
		0, -- 360
		0.5, -- 360
		"Left", -- 360
		1.2, -- 360
		0.95 -- 360
	) -- 360
	drawSealStamp( -- 362
		uiInkDraw, -- 362
		uiArt, -- 362
		texts, -- 362
		"vol2_seal", -- 362
		leftX + 12, -- 362
		rowY1 + cardH + 22, -- 362
		22, -- 362
		"下", -- 362
		PALETTE.amberDim, -- 362
		PALETTE.amberCore, -- 362
		0.92, -- 362
		true, -- 362
		4 -- 362
	) -- 362
	texts:put( -- 363
		"sm", -- 363
		"下卷 · 独赴北塔（小满）", -- 363
		leftX + 30, -- 363
		rowY1 + cardH + 22, -- 363
		toColor(PALETTE.amberCore), -- 363
		0, -- 363
		0.5, -- 363
		"Left", -- 363
		1.2, -- 363
		0.95 -- 363
	) -- 363
	local i = 0 -- 365
	do -- 365
		i = 0 -- 366
		while i < #ROOMS do -- 366
			local col = i % cols -- 367
			local row = math.floor(i / cols) -- 368
			local cx = leftX + col * (cardW + gapX) -- 369
			local cy = row == 0 and rowY0 or rowY1 -- 370
			local theme = themeOf(ROOMS[i + 1].key) -- 371
			local hover = pointer.x >= cx and pointer.x <= cx + cardW and pointer.y >= cy and pointer.y <= cy + cardH -- 372
			if hover then -- 372
				self.chapterSelected = i -- 374
				hitIdx = i -- 375
			end -- 375
			local active = self.chapterSelected == i -- 377
			drawInkPanel( -- 380
				uiDraw, -- 380
				uiArt, -- 380
				"chap_panel_" .. tostring(i), -- 380
				cx, -- 380
				cy, -- 380
				cardW, -- 380
				cardH, -- 380
				active and PALETTE.inkWarm or PALETTE.inkWash, -- 380
				active and 0.94 or 0.82, -- 380
				active, -- 380
				-2 -- 380
			) -- 380
			local bgSlot = "bgFar_" .. ROOMS[i + 1].key -- 382
			uiArt:tryPlace( -- 383
				bgSlot, -- 383
				"chap_thumb_" .. tostring(i), -- 383
				cx + cardW * 0.5, -- 383
				cy + 6, -- 383
				cardW - 12, -- 383
				cardH - 12, -- 383
				{opacity = active and 0.44 or 0.24, layer = -1} -- 383
			) -- 383
			fillVGradRect( -- 387
				uiInkDraw, -- 388
				cx + 4, -- 389
				cy + 4, -- 390
				cardW - 8, -- 391
				cardH * 0.72, -- 392
				Color(12, 13, 18, active and 215 or 200), -- 393
				Color(12, 13, 18, 25) -- 394
			) -- 394
			local frameCol = active and (ROOMS[i + 1].key == "gate" and PALETTE.sealRedBright or PALETTE.amber) or PALETTE.bronzeDim -- 397
			drawScrollFrame( -- 398
				uiInkDraw, -- 398
				uiArt, -- 398
				"chap_frame_" .. tostring(i), -- 398
				cx, -- 398
				cy, -- 398
				cardW, -- 398
				cardH, -- 398
				frameCol, -- 398
				active and 1 or 0.65, -- 398
				active, -- 398
				false, -- 398
				18, -- 398
				2 -- 398
			) -- 398
			if active then -- 398
				fillRadialGlow( -- 401
					uiGlow, -- 401
					cx + cardW - 26, -- 401
					cy + cardH - 26, -- 401
					36, -- 401
					36, -- 401
					toColor(PALETTE.cinnabar, 36), -- 401
					Color(186, 66, 54, 0), -- 401
					12 -- 401
				) -- 401
			end -- 401
			drawSealStamp( -- 405
				uiInkDraw, -- 406
				uiArt, -- 407
				texts, -- 408
				"chap_num_" .. tostring(i), -- 409
				cx + cardW - 26, -- 410
				cy + cardH - 26, -- 411
				30, -- 412
				theme.numeralZh, -- 413
				active and PALETTE.sealRed or PALETTE.bronzeDim, -- 414
				active and PALETTE.sealText or PALETTE.textMid, -- 415
				active and 0.98 or 0.85, -- 416
				active, -- 417
				4 -- 418
			) -- 418
			texts:put( -- 422
				"xs", -- 422
				(theme.actCode .. " · ") .. theme.lineTag, -- 422
				cx + 16, -- 422
				cy + 54, -- 422
				toColor(active and PALETTE.amberCore or theme.accent), -- 422
				0, -- 422
				0.5, -- 422
				"Left", -- 422
				0.8, -- 422
				0.94 -- 422
			) -- 422
			texts:put( -- 423
				"md", -- 423
				theme.titleZh, -- 423
				cx + 16, -- 423
				cy + 26, -- 423
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 423
				0, -- 423
				0.5, -- 423
				"Left", -- 423
				0.6, -- 423
				1 -- 423
			) -- 423
			i = i + 1 -- 366
		end -- 366
	end -- 366
	local backX = leftX -- 427
	local backY = 44 -- 428
	local backHover = pointer.x >= backX and pointer.x <= backX + 188 and pointer.y >= backY and pointer.y <= backY + 38 -- 429
	drawInkWashStrip( -- 430
		uiDraw, -- 430
		uiArt, -- 430
		"chap_back_bg", -- 430
		backX + 90, -- 430
		backY + 19, -- 430
		200, -- 430
		38, -- 430
		backHover and PALETTE.cinnabarDeep or PALETTE.inkWash, -- 430
		backHover and 0.78 or 0.64, -- 430
		false, -- 430
		0 -- 430
	) -- 430
	drawInkKeycap( -- 431
		uiInkDraw, -- 431
		texts, -- 431
		backX + 6, -- 431
		backY + 7, -- 431
		46, -- 431
		24, -- 431
		"ESC", -- 431
		backHover and PALETTE.sealRedBright or PALETTE.bronzeLine, -- 431
		0.95, -- 431
		backHover -- 431
	) -- 431
	texts:put( -- 432
		"sm", -- 432
		"返回标题", -- 432
		backX + 62, -- 432
		backY + 19, -- 432
		toColor(backHover and PALETTE.amberCore or PALETTE.textMid), -- 432
		0, -- 432
		0.5, -- 432
		"Left", -- 432
		1.2, -- 432
		1 -- 432
	) -- 432
	if clicked and backHover then -- 432
		return {type = "backTitle"} -- 435
	end -- 435
	if mk.confirm or clicked and hitIdx >= 0 then -- 435
		return {type = "jump", roomIndex = self.chapterSelected} -- 438
	end -- 438
	return {type = "none"} -- 440
end -- 314
function MenuRenderer.prototype.drawControls(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 443
	if input.pause.pressed or mk.back or mk.confirm then -- 443
		return {type = "backTitle"} -- 457
	end -- 457
	uiDraw:drawRect( -- 459
		Rect(0, 0, w, h), -- 459
		Color(11, 12, 17, 182) -- 459
	) -- 459
	local leftX = 96 -- 461
	drawSealStamp( -- 462
		uiInkDraw, -- 462
		uiArt, -- 462
		texts, -- 462
		"ctrl_head_seal", -- 462
		leftX + 18, -- 462
		h - 86, -- 462
		34, -- 462
		"诀", -- 462
		PALETTE.sealRed, -- 462
		PALETTE.sealText, -- 462
		0.96, -- 462
		true, -- 462
		4 -- 462
	) -- 462
	texts:put( -- 463
		"banner", -- 463
		"操作说明", -- 463
		leftX + 48, -- 463
		h - 86, -- 463
		toColor(PALETTE.textBright), -- 463
		0, -- 463
		0.5, -- 463
		"Left", -- 463
		4, -- 463
		1 -- 463
	) -- 463
	texts:put( -- 464
		"xs", -- 464
		"键鼠执器要诀", -- 464
		leftX + 236, -- 464
		h - 90, -- 464
		toColor(PALETTE.textDim), -- 464
		0, -- 464
		0.5, -- 464
		"Left", -- 464
		1.2, -- 464
		0.88 -- 464
	) -- 464
	drawBrushDivider( -- 465
		uiInkDraw, -- 465
		uiArt, -- 465
		"ctrl_head_div", -- 465
		w * 0.5, -- 465
		h - 118, -- 465
		w - leftX * 2, -- 465
		14, -- 465
		PALETTE.bronzeDim, -- 465
		0.72, -- 465
		2 -- 465
	) -- 465
	local colGap = 34 -- 467
	local colW = (w - leftX * 2 - colGap) * 0.5 -- 468
	local panelY = h * 0.18 -- 469
	local panelH = h * 0.58 -- 470
	drawInkPanel( -- 473
		uiDraw, -- 473
		uiArt, -- 473
		"ctrl_left_bg", -- 473
		leftX, -- 473
		panelY, -- 473
		colW, -- 473
		panelH, -- 473
		PALETTE.inkWash, -- 473
		0.92, -- 473
		true, -- 473
		-1 -- 473
	) -- 473
	drawScrollFrame( -- 474
		uiInkDraw, -- 474
		uiArt, -- 474
		"ctrl_left_frame", -- 474
		leftX, -- 474
		panelY, -- 474
		colW, -- 474
		panelH, -- 474
		PALETTE.cyan, -- 474
		0.88, -- 474
		true, -- 474
		true, -- 474
		20, -- 474
		2 -- 474
	) -- 474
	drawSealStamp( -- 475
		uiInkDraw, -- 475
		uiArt, -- 475
		texts, -- 475
		"ctrl_left_seal", -- 475
		leftX + 38, -- 475
		panelY + panelH - 36, -- 475
		28, -- 475
		"戍", -- 475
		PALETTE.cyanDim, -- 475
		PALETTE.moonPale, -- 475
		0.96, -- 475
		true, -- 475
		4 -- 475
	) -- 475
	texts:put( -- 476
		"md", -- 476
		"周戍 · 护送与交锋", -- 476
		leftX + 62, -- 476
		panelY + panelH - 36, -- 476
		toColor(PALETTE.cyanCore), -- 476
		0, -- 476
		0.5, -- 476
		"Left", -- 476
		1.2, -- 476
		1 -- 476
	) -- 476
	drawBrushDivider( -- 477
		uiInkDraw, -- 477
		uiArt, -- 477
		"ctrl_left_div", -- 477
		leftX + colW * 0.5, -- 477
		panelY + panelH - 60, -- 477
		colW - 44, -- 477
		10, -- 477
		PALETTE.cyanDim, -- 477
		0.65, -- 477
		2 -- 477
	) -- 477
	local sRows = { -- 479
		{"A / D", "左右移动"}, -- 480
		{"鼠标 + 左键", "瞄准与点射"}, -- 481
		{"SHIFT 按住", "贴靠柜台 / 街垒挡枪"}, -- 482
		{"SPACE", "平地翻滚 / 贴矮台翻越"}, -- 483
		{"E", "递物 / 敲两下安抚 / 按住+D 推车"}, -- 484
		{"ESC / R", "暂歇 / 从检查点重试"} -- 485
	} -- 485
	local i = 0 -- 487
	do -- 487
		i = 0 -- 488
		while i < #sRows do -- 488
			local ry = panelY + panelH - 96 - i * 48 -- 489
			drawInkKeycap( -- 490
				uiInkDraw, -- 490
				texts, -- 490
				leftX + 26, -- 490
				ry - 13, -- 490
				124, -- 490
				26, -- 490
				sRows[i + 1][1], -- 490
				PALETTE.cyan, -- 490
				0.95, -- 490
				false -- 490
			) -- 490
			texts:put( -- 491
				"sm", -- 491
				sRows[i + 1][2], -- 491
				leftX + 166, -- 491
				ry, -- 491
				toColor(PALETTE.textBright), -- 491
				0, -- 491
				0.5, -- 491
				"Left", -- 491
				0.4, -- 491
				0.95 -- 491
			) -- 491
			i = i + 1 -- 488
		end -- 488
	end -- 488
	local rightX = leftX + colW + colGap -- 495
	drawInkPanel( -- 496
		uiDraw, -- 496
		uiArt, -- 496
		"ctrl_right_bg", -- 496
		rightX, -- 496
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
		"ctrl_right_frame", -- 497
		rightX, -- 497
		panelY, -- 497
		colW, -- 497
		panelH, -- 497
		PALETTE.amber, -- 497
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
		"ctrl_right_seal", -- 498
		rightX + 38, -- 498
		panelY + panelH - 36, -- 498
		28, -- 498
		"满", -- 498
		PALETTE.amberDim, -- 498
		PALETTE.amberCore, -- 498
		0.96, -- 498
		true, -- 498
		4 -- 498
	) -- 498
	texts:put( -- 499
		"md", -- 499
		"小满 · 潜行与寻路", -- 499
		rightX + 62, -- 499
		panelY + panelH - 36, -- 499
		toColor(PALETTE.amberCore), -- 499
		0, -- 499
		0.5, -- 499
		"Left", -- 499
		1.2, -- 499
		1 -- 499
	) -- 499
	drawBrushDivider( -- 500
		uiInkDraw, -- 500
		uiArt, -- 500
		"ctrl_right_div", -- 500
		rightX + colW * 0.5, -- 500
		panelY + panelH - 60, -- 500
		colW - 44, -- 500
		10, -- 500
		PALETTE.amberDim, -- 500
		0.65, -- 500
		2 -- 500
	) -- 500
	local cRows = { -- 502
		{"A / D", "潜行行走"}, -- 503
		{"SHIFT 按住", "轻步慢走（压低脚步声）"}, -- 504
		{"S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 505
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 506
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉板车"}, -- 507
		{"F 按住→松手", "预览落点，投瓶引开拾荒者"} -- 508
	} -- 508
	do -- 508
		i = 0 -- 510
		while i < #cRows do -- 510
			local ry = panelY + panelH - 96 - i * 48 -- 511
			drawInkKeycap( -- 512
				uiInkDraw, -- 512
				texts, -- 512
				rightX + 26, -- 512
				ry - 13, -- 512
				128, -- 512
				26, -- 512
				cRows[i + 1][1], -- 512
				PALETTE.amber, -- 512
				0.95, -- 512
				false -- 512
			) -- 512
			texts:put( -- 513
				"sm", -- 513
				cRows[i + 1][2], -- 513
				rightX + 170, -- 513
				ry, -- 513
				toColor(PALETTE.textBright), -- 513
				0, -- 513
				0.5, -- 513
				"Left", -- 513
				0.4, -- 513
				0.95 -- 513
			) -- 513
			i = i + 1 -- 510
		end -- 510
	end -- 510
	local backX = leftX -- 517
	local backY = 44 -- 518
	local backHover = pointer.x >= backX and pointer.x <= backX + 224 and pointer.y >= backY and pointer.y <= backY + 38 -- 519
	drawInkWashStrip( -- 520
		uiDraw, -- 520
		uiArt, -- 520
		"ctrl_back_bg", -- 520
		backX + 108, -- 520
		backY + 19, -- 520
		232, -- 520
		38, -- 520
		backHover and PALETTE.cinnabarDeep or PALETTE.inkWash, -- 520
		backHover and 0.78 or 0.64, -- 520
		false, -- 520
		0 -- 520
	) -- 520
	drawInkKeycap( -- 521
		uiInkDraw, -- 521
		texts, -- 521
		backX + 6, -- 521
		backY + 7, -- 521
		88, -- 521
		24, -- 521
		"ESC / ENTER", -- 521
		backHover and PALETTE.sealRedBright or PALETTE.bronzeLine, -- 521
		0.95, -- 521
		backHover -- 521
	) -- 521
	texts:put( -- 522
		"sm", -- 522
		"返回标题", -- 522
		backX + 104, -- 522
		backY + 19, -- 522
		toColor(backHover and PALETTE.amberCore or PALETTE.textMid), -- 522
		0, -- 522
		0.5, -- 522
		"Left", -- 522
		1.2, -- 522
		1 -- 522
	) -- 522
	if clicked and backHover then -- 522
		return {type = "backTitle"} -- 525
	end -- 525
	return {type = "none"} -- 527
end -- 443
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale) -- 531
	self.time = self.time + dt -- 543
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 544
	local mk = self:readMenuKeys() -- 545
	local clicked = self:clickEdge(input) -- 546
	if mk.up then -- 546
		self.pauseSelected = (self.pauseSelected + #PAUSE_ITEMS - 1) % #PAUSE_ITEMS -- 549
	elseif mk.down then -- 549
		self.pauseSelected = (self.pauseSelected + 1) % #PAUSE_ITEMS -- 551
	end -- 551
	uiDraw:drawRect( -- 555
		Rect(0, 0, w, h), -- 555
		Color(9, 10, 14, 178) -- 555
	) -- 555
	local boxW = 376 -- 557
	local boxH = 368 -- 558
	local bx = (w - boxW) * 0.5 -- 559
	local by = (h - boxH) * 0.5 -- 560
	drawInkPanel( -- 563
		uiDraw, -- 563
		uiArt, -- 563
		"pause_scroll_bg", -- 563
		bx, -- 563
		by, -- 563
		boxW, -- 563
		boxH, -- 563
		PALETTE.inkWash, -- 563
		0.94, -- 563
		true, -- 563
		-1 -- 563
	) -- 563
	drawScrollFrame( -- 564
		uiInkDraw, -- 564
		uiArt, -- 564
		"pause_scroll_frame", -- 564
		bx, -- 564
		by, -- 564
		boxW, -- 564
		boxH, -- 564
		PALETTE.bronzeLine, -- 564
		0.94, -- 564
		true, -- 564
		true, -- 564
		22, -- 564
		2 -- 564
	) -- 564
	texts:put( -- 567
		"banner", -- 567
		"暂歇", -- 567
		w * 0.5 - 16, -- 567
		by + boxH - 52, -- 567
		toColor(PALETTE.textBright), -- 567
		0.5, -- 567
		0.5, -- 567
		"Center", -- 567
		8, -- 567
		1 -- 567
	) -- 567
	drawSealStamp( -- 568
		uiInkDraw, -- 568
		uiArt, -- 568
		texts, -- 568
		"pause_head_seal", -- 568
		w * 0.5 + 52, -- 568
		by + boxH - 52, -- 568
		26, -- 568
		"停", -- 568
		PALETTE.sealRed, -- 568
		PALETTE.sealText, -- 568
		0.95, -- 568
		true, -- 568
		4 -- 568
	) -- 568
	drawBrushDivider( -- 569
		uiInkDraw, -- 569
		uiArt, -- 569
		"pause_head_div", -- 569
		w * 0.5, -- 569
		by + boxH - 86, -- 569
		boxW - 64, -- 569
		12, -- 569
		PALETTE.bronzeDim, -- 569
		0.7, -- 569
		2 -- 569
	) -- 569
	local hitIdx = -1 -- 571
	local i = 0 -- 572
	do -- 572
		i = 0 -- 573
		while i < #PAUSE_ITEMS do -- 573
			local iy = by + boxH - 146 - i * 56 -- 574
			local ix = bx + 36 -- 575
			local iw = boxW - 72 -- 576
			local ih = 44 -- 577
			local hover = pointer.x >= ix and pointer.x <= ix + iw and pointer.y >= iy and pointer.y <= iy + ih -- 578
			if hover then -- 578
				self.pauseSelected = i -- 580
				hitIdx = i -- 581
			end -- 581
			local active = self.pauseSelected == i -- 583
			local cy = iy + ih * 0.5 -- 584
			if active then -- 584
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.8) -- 587
				drawInkWashStrip( -- 588
					uiDraw, -- 588
					uiArt, -- 588
					"pause_item_red_" .. tostring(i), -- 588
					ix + iw * 0.5, -- 588
					cy, -- 588
					iw + 16, -- 588
					ih + 4, -- 588
					PALETTE.cinnabarDeep, -- 588
					0.56 * breathe, -- 588
					true, -- 588
					0 -- 588
				) -- 588
				drawBrushDivider( -- 589
					uiInkDraw, -- 589
					uiArt, -- 589
					"pause_item_line_" .. tostring(i), -- 589
					ix + iw * 0.5, -- 589
					iy + 2, -- 589
					iw - 12, -- 589
					8, -- 589
					PALETTE.bronzeLine, -- 589
					0.52, -- 589
					2 -- 589
				) -- 589
				drawSealStamp( -- 590
					uiInkDraw, -- 590
					uiArt, -- 590
					texts, -- 590
					"pause_item_seal_" .. tostring(i), -- 590
					ix + 24, -- 590
					cy, -- 590
					24, -- 590
					PAUSE_ITEMS[i + 1].seal, -- 590
					PALETTE.sealRed, -- 590
					PALETTE.sealText, -- 590
					0.96, -- 590
					true, -- 590
					4 -- 590
				) -- 590
				fillRadialGlow( -- 591
					uiGlow, -- 591
					ix + 24, -- 591
					cy, -- 591
					28, -- 591
					18, -- 591
					toColor(PALETTE.cinnabar, 32 * breathe), -- 591
					Color(168, 46, 40, 0), -- 591
					10 -- 591
				) -- 591
			else -- 591
				uiArt:tryPlace( -- 593
					"ink_dot", -- 593
					"pause_item_dot_" .. tostring(i), -- 593
					ix + 24, -- 593
					cy, -- 593
					8, -- 593
					8, -- 593
					{ -- 593
						color = toColor(PALETTE.bronzeDim), -- 594
						opacity = 0.55, -- 594
						layer = 2 -- 594
					} -- 594
				) -- 594
			end -- 594
			texts:put( -- 598
				"md", -- 599
				PAUSE_ITEMS[i + 1].zh, -- 600
				ix + (active and 54 or 46), -- 601
				cy, -- 602
				toColor(active and PALETTE.amberCore or PALETTE.textMid), -- 603
				0, -- 604
				0.5, -- 605
				"Left", -- 606
				active and 2.4 or 1.4, -- 607
				active and 1 or 0.88 -- 608
			) -- 608
			i = i + 1 -- 573
		end -- 573
	end -- 573
	texts:put( -- 612
		"xs", -- 612
		"ESC 继续   ·   Enter 或点击确认", -- 612
		w * 0.5, -- 612
		by + 24, -- 612
		toColor(PALETTE.textDim), -- 612
		0.5, -- 612
		0.5, -- 612
		"Center", -- 612
		0.6, -- 612
		0.85 -- 612
	) -- 612
	if mk.confirm or clicked and hitIdx >= 0 then -- 612
		local id = PAUSE_ITEMS[self.pauseSelected + 1].id -- 615
		if id == "resume" then -- 615
			return {type = "resume"} -- 617
		end -- 617
		if id == "retry" then -- 617
			return {type = "retry"} -- 620
		end -- 620
		if id == "chapters" then -- 620
			return {type = "openChapters"} -- 623
		end -- 623
		return {type = "toTitle"} -- 625
	end -- 625
	return {type = "none"} -- 627
end -- 531
return ____exports -- 531