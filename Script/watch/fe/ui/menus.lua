-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Keyboard = ____Dora.Keyboard -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____rooms = require("Script.watch.rooms") -- 10
local ROOMS = ____rooms.ROOMS -- 10
local ____theme = require("Script.watch.fe.theme") -- 15
local PALETTE = ____theme.PALETTE -- 16
local drawDiamond = ____theme.drawDiamond -- 17
local fillChamferBox = ____theme.fillChamferBox -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 19
local fillSkewRect = ____theme.fillSkewRect -- 20
local fillVGradRect = ____theme.fillVGradRect -- 21
local themeOf = ____theme.themeOf -- 22
local toColor = ____theme.toColor -- 23
local TITLE_ITEMS = {{id = "start", zh = "开始游戏"}, {id = "chapters", zh = "选择章节"}, {id = "controls", zh = "操作说明"}} -- 33
local PAUSE_ITEMS = {{id = "resume", zh = "继续游戏"}, {id = "retry", zh = "重试检查点"}, {id = "chapters", zh = "选择章节"}, {id = "title", zh = "返回标题"}} -- 39
____exports.MenuRenderer = __TS__Class() -- 46
local MenuRenderer = ____exports.MenuRenderer -- 46
MenuRenderer.name = "MenuRenderer" -- 46
function MenuRenderer.prototype.____constructor(self) -- 46
	self.selected = 0 -- 47
	self.chapterSelected = 0 -- 48
	self.pauseSelected = 0 -- 49
	self.prevUp = false -- 50
	self.prevDown = false -- 51
	self.prevLeft = false -- 52
	self.prevRight = false -- 53
	self.prevEnter = false -- 54
	self.prevClick = false -- 55
	self.queuedUp = false -- 56
	self.queuedDown = false -- 57
	self.queuedLeft = false -- 58
	self.queuedRight = false -- 59
	self.queuedConfirm = false -- 60
	self.queuedBack = false -- 61
	self.time = 0 -- 62
end -- 46
function MenuRenderer.prototype.onKeyEvent(self, key) -- 65
	if key == "Up" or key == "W" then -- 65
		self.queuedUp = true -- 67
	elseif key == "Down" or key == "S" then -- 67
		self.queuedDown = true -- 69
	elseif key == "Left" or key == "A" then -- 69
		self.queuedLeft = true -- 71
	elseif key == "Right" or key == "D" then -- 71
		self.queuedRight = true -- 73
	elseif key == "Return" or key == "Space" then -- 73
		self.queuedConfirm = true -- 75
	elseif key == "Escape" then -- 75
		self.queuedBack = true -- 77
	end -- 77
end -- 65
function MenuRenderer.prototype.readMenuKeys(self) -- 81
	local u = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 82
	local d = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 83
	local l = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 84
	local r = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 85
	local e = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 86
	local res = { -- 87
		up = u and not self.prevUp or self.queuedUp, -- 88
		down = d and not self.prevDown or self.queuedDown, -- 89
		left = l and not self.prevLeft or self.queuedLeft, -- 90
		right = r and not self.prevRight or self.queuedRight, -- 91
		confirm = e and not self.prevEnter or self.queuedConfirm, -- 92
		back = self.queuedBack -- 93
	} -- 93
	self.prevUp = u -- 95
	self.prevDown = d -- 96
	self.prevLeft = l -- 97
	self.prevRight = r -- 98
	self.prevEnter = e -- 99
	self.queuedUp = false -- 100
	self.queuedDown = false -- 101
	self.queuedLeft = false -- 102
	self.queuedRight = false -- 103
	self.queuedConfirm = false -- 104
	self.queuedBack = false -- 105
	return res -- 106
end -- 81
function MenuRenderer.prototype.clickEdge(self, input) -- 109
	local held = input.fire.held -- 110
	local fired = held and not self.prevClick -- 111
	self.prevClick = held -- 112
	return fired -- 113
end -- 109
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiGlow, texts, w, h, uiScale) -- 117
	self.time = self.time + dt -- 133
	local artW = math.max(w, h * 16 / 9) -- 134
	local artH = artW * 9 / 16 -- 135
	if not backdropArt:tryPlace( -- 135
		"title_backdrop", -- 136
		"menu_landscape", -- 136
		w * 0.5, -- 136
		(h - artH) * 0.5, -- 136
		artW, -- 136
		artH -- 136
	) then -- 136
		stage:drawMenuBackdrop( -- 137
			bgDraw, -- 137
			bgGlow, -- 137
			w, -- 137
			h, -- 137
			self.time -- 137
		) -- 137
	end -- 137
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 140
	w = w / uiScale -- 141
	h = h / uiScale -- 142
	local titleScreen = screen == "title" -- 143
	uiDraw:drawRect( -- 144
		Rect(0, 0, w, h), -- 144
		Color(15, 14, 20, titleScreen and 25 or 118) -- 144
	) -- 144
	uiArt:tryPlace( -- 145
		"ui_corner", -- 145
		"menu_corner", -- 145
		88, -- 145
		titleScreen and h * 0.72 + 58 or h - 145, -- 145
		42, -- 146
		45, -- 146
		{opacity = 0.87} -- 146
	) -- 146
	local mk = self:readMenuKeys() -- 148
	local clicked = self:clickEdge(input) -- 149
	if screen == "title" then -- 149
		return self:drawTitle( -- 152
			mk, -- 152
			clicked, -- 152
			pointer, -- 152
			uiDraw, -- 152
			uiGlow, -- 152
			texts, -- 152
			w, -- 152
			h -- 152
		) -- 152
	end -- 152
	if screen == "chapters" then -- 152
		return self:drawChapters( -- 155
			mk, -- 155
			clicked, -- 155
			input, -- 155
			pointer, -- 155
			uiDraw, -- 155
			uiGlow, -- 155
			texts, -- 155
			w, -- 155
			h -- 155
		) -- 155
	end -- 155
	return self:drawControls( -- 157
		mk, -- 157
		clicked, -- 157
		input, -- 157
		pointer, -- 157
		uiDraw, -- 157
		uiGlow, -- 157
		texts, -- 157
		w, -- 157
		h -- 157
	) -- 157
end -- 117
function MenuRenderer.prototype.drawTitle(self, mk, clicked, pointer, uiDraw, uiGlow, texts, w, h) -- 160
	if mk.up then -- 160
		self.selected = (self.selected + #TITLE_ITEMS - 1) % #TITLE_ITEMS -- 171
	elseif mk.down then -- 171
		self.selected = (self.selected + 1) % #TITLE_ITEMS -- 173
	end -- 173
	local leftX = 106 -- 176
	local titleY = h * 0.72 -- 177
	texts:put( -- 179
		"xl", -- 179
		"向西守望", -- 179
		leftX, -- 179
		titleY + 24, -- 179
		toColor(PALETTE.textBright), -- 179
		0, -- 179
		0.5, -- 179
		"Left", -- 179
		3.2, -- 179
		1 -- 179
	) -- 179
	uiDraw:drawSegment( -- 180
		Vec2(leftX, titleY - 16), -- 180
		Vec2(leftX + 310, titleY - 16), -- 180
		1.3, -- 180
		toColor(PALETTE.amberDim, 210) -- 180
	) -- 180
	texts:put( -- 181
		"sm", -- 181
		"城破那天，他留下断后。她独自走向北塔。", -- 181
		leftX, -- 181
		titleY - 48, -- 181
		toColor(PALETTE.textMid), -- 182
		0, -- 182
		0.5, -- 182
		"Left", -- 182
		0.4, -- 182
		1 -- 182
	) -- 182
	local btnW = 340 -- 184
	local btnH = 50 -- 185
	local gap = 16 -- 186
	local startY = h * 0.42 -- 187
	local hitIdx = -1 -- 188
	local i = 0 -- 190
	do -- 190
		i = 0 -- 191
		while i < #TITLE_ITEMS do -- 191
			local bx = leftX -- 192
			local by = startY - i * (btnH + gap) -- 193
			local hover = pointer.x >= bx and pointer.x <= bx + btnW + 16 and pointer.y >= by and pointer.y <= by + btnH -- 194
			if hover then -- 194
				self.selected = i -- 196
				hitIdx = i -- 197
			end -- 197
			local active = self.selected == i -- 199
			local shiftX = active and 7 or 0 -- 200
			fillSkewRect( -- 202
				uiDraw, -- 203
				bx + shiftX, -- 204
				by, -- 205
				btnW, -- 206
				btnH, -- 207
				14, -- 208
				active and Color(60, 45, 42, 240) or toColor(PALETTE.panelBg, 195), -- 209
				active and 1.6 or 1, -- 210
				toColor(active and PALETTE.cyan or PALETTE.steelLight, active and 240 or 140) -- 211
			) -- 211
			if active then -- 211
				fillSkewRect( -- 214
					uiGlow, -- 214
					bx + shiftX - 4, -- 214
					by, -- 214
					6, -- 214
					btnH, -- 214
					14, -- 214
					toColor(PALETTE.cyanCore, 240) -- 214
				) -- 214
				fillRadialGlow( -- 215
					uiGlow, -- 215
					bx + shiftX + 24, -- 215
					by + btnH * 0.5, -- 215
					42, -- 215
					22, -- 215
					toColor(PALETTE.cyan, 85), -- 215
					Color(193, 161, 114, 0), -- 215
					12 -- 215
				) -- 215
			end -- 215
			texts:put( -- 217
				"md", -- 217
				(active and "▸  " or "   ") .. TITLE_ITEMS[i + 1].zh, -- 217
				bx + shiftX + 22, -- 217
				by + btnH * 0.5, -- 217
				toColor(active and PALETTE.amberCore or PALETTE.textBright), -- 218
				0, -- 218
				0.5, -- 218
				"Left", -- 218
				0.8, -- 218
				1 -- 218
			) -- 218
			i = i + 1 -- 191
		end -- 191
	end -- 191
	texts:put( -- 221
		"xs", -- 221
		"↑ / ↓ 选择   ·   Enter 或点击确认", -- 221
		leftX, -- 221
		52, -- 221
		toColor(PALETTE.textMid), -- 222
		0, -- 222
		0.5, -- 222
		"Left", -- 222
		0.3, -- 222
		1 -- 222
	) -- 222
	if mk.confirm or clicked and hitIdx >= 0 then -- 222
		local id = TITLE_ITEMS[self.selected + 1].id -- 225
		if id == "start" then -- 225
			return {type = "start"} -- 227
		end -- 227
		if id == "chapters" then -- 227
			return {type = "openChapters"} -- 230
		end -- 230
		return {type = "openControls"} -- 232
	end -- 232
	return {type = "none"} -- 234
end -- 160
function MenuRenderer.prototype.drawChapters(self, mk, clicked, input, pointer, uiDraw, uiGlow, texts, w, h) -- 237
	if input.pause.pressed or mk.back then -- 237
		return {type = "backTitle"} -- 249
	end -- 249
	if mk.left then -- 249
		self.chapterSelected = (self.chapterSelected + #ROOMS - 1) % #ROOMS -- 252
	elseif mk.right then -- 252
		self.chapterSelected = (self.chapterSelected + 1) % #ROOMS -- 254
	elseif mk.up then -- 254
		self.chapterSelected = (self.chapterSelected + #ROOMS - 4) % #ROOMS -- 256
	elseif mk.down then -- 256
		self.chapterSelected = (self.chapterSelected + 4) % #ROOMS -- 258
	end -- 258
	local leftX = 106 -- 261
	texts:put( -- 262
		"lg", -- 262
		"选择章节", -- 262
		leftX, -- 262
		h - 116, -- 262
		toColor(PALETTE.textBright), -- 262
		0, -- 262
		0.5, -- 262
		"Left", -- 262
		2, -- 262
		1 -- 262
	) -- 262
	uiGlow:drawSegment( -- 263
		Vec2(leftX, h - 142), -- 263
		Vec2(w - 86, h - 142), -- 263
		1.4, -- 263
		toColor(PALETTE.cyanDim, 180) -- 263
	) -- 263
	local cols = 4 -- 266
	local cardW = math.min(256, (w - leftX - 110 - (cols - 1) * 20) / cols) -- 267
	local cardH = 128 -- 268
	local gapX = 20 -- 269
	local rowY0 = h * 0.54 -- 270
	local rowY1 = h * 0.24 -- 271
	local hitIdx = -1 -- 272
	texts:put( -- 274
		"xs", -- 274
		"PHASE I  //  军人线 · 护送周戍与小满出城", -- 274
		leftX, -- 274
		rowY0 + cardH + 20, -- 274
		toColor(PALETTE.cyan), -- 274
		0, -- 274
		0.5, -- 274
		"Left", -- 274
		1, -- 274
		0.95 -- 274
	) -- 274
	texts:put( -- 275
		"xs", -- 275
		"PHASE II  //  孩子线 · 小满独自前往北塔", -- 275
		leftX, -- 275
		rowY1 + cardH + 20, -- 275
		toColor(PALETTE.amber), -- 275
		0, -- 275
		0.5, -- 275
		"Left", -- 275
		1, -- 275
		0.95 -- 275
	) -- 275
	local i = 0 -- 277
	do -- 277
		i = 0 -- 278
		while i < #ROOMS do -- 278
			local col = i % cols -- 279
			local row = math.floor(i / cols) -- 280
			local cx = leftX + col * (cardW + gapX) -- 281
			local cy = row == 0 and rowY0 or rowY1 -- 282
			local theme = themeOf(ROOMS[i + 1].key) -- 283
			local hover = pointer.x >= cx and pointer.x <= cx + cardW and pointer.y >= cy and pointer.y <= cy + cardH -- 284
			if hover then -- 284
				self.chapterSelected = i -- 286
				hitIdx = i -- 287
			end -- 287
			local active = self.chapterSelected == i -- 289
			fillChamferBox( -- 291
				uiDraw, -- 292
				cx, -- 293
				cy, -- 294
				cardW, -- 295
				cardH, -- 296
				14, -- 297
				active and Color(18, 36, 56, 232) or toColor(PALETTE.panelBg, 205), -- 298
				active and 1.8 or 1, -- 299
				toColor(active and theme.accent or PALETTE.steelLight, active and 245 or 130) -- 300
			) -- 300
			fillVGradRect( -- 302
				uiGlow, -- 302
				cx, -- 302
				cy + cardH - 36, -- 302
				cardW, -- 302
				36, -- 302
				Color(theme.accent.r, theme.accent.g, theme.accent.b, 0), -- 302
				toColor(theme.accent, active and 68 or 26) -- 302
			) -- 302
			texts:put( -- 303
				"xs", -- 303
				(theme.actCode .. "  //  ") .. theme.lineTag, -- 303
				cx + 16, -- 303
				cy + cardH - 20, -- 303
				toColor(theme.accent), -- 303
				0, -- 303
				0.5, -- 303
				"Left", -- 303
				0.8, -- 303
				1 -- 303
			) -- 303
			texts:put( -- 304
				"md", -- 304
				theme.titleZh, -- 304
				cx + 16, -- 304
				cy + cardH - 54, -- 304
				toColor(PALETTE.textBright), -- 304
				0, -- 304
				0.5, -- 304
				"Left", -- 304
				0.6, -- 304
				1 -- 304
			) -- 304
			if active then -- 304
				drawDiamond( -- 306
					uiGlow, -- 306
					cx + cardW - 22, -- 306
					cy + 24, -- 306
					6, -- 306
					6, -- 306
					toColor(theme.accent) -- 306
				) -- 306
			end -- 306
			i = i + 1 -- 278
		end -- 278
	end -- 278
	local backX = leftX -- 311
	local backY = 48 -- 312
	local backHover = pointer.x >= backX and pointer.x <= backX + 160 and pointer.y >= backY and pointer.y <= backY + 34 -- 313
	fillSkewRect( -- 314
		uiDraw, -- 314
		backX, -- 314
		backY, -- 314
		156, -- 314
		34, -- 314
		9, -- 314
		toColor(PALETTE.panelBg, 210), -- 314
		1.2, -- 314
		toColor(backHover and PALETTE.cyan or PALETTE.steelLight, 200) -- 314
	) -- 314
	texts:put( -- 315
		"xs", -- 315
		"← 返回标题 [ESC]", -- 315
		backX + 82, -- 315
		backY + 17, -- 315
		toColor(backHover and PALETTE.cyanCore or PALETTE.textMid), -- 315
		0.5, -- 315
		0.5, -- 315
		"Center", -- 315
		0.6, -- 315
		1 -- 315
	) -- 315
	if clicked and backHover then -- 315
		return {type = "backTitle"} -- 318
	end -- 318
	if mk.confirm or clicked and hitIdx >= 0 then -- 318
		return {type = "jump", roomIndex = self.chapterSelected} -- 321
	end -- 321
	return {type = "none"} -- 323
end -- 237
function MenuRenderer.prototype.drawControls(self, mk, clicked, input, pointer, uiDraw, uiGlow, texts, w, h) -- 326
	if input.pause.pressed or mk.back or mk.confirm then -- 326
		return {type = "backTitle"} -- 338
	end -- 338
	local leftX = 106 -- 340
	texts:put( -- 341
		"lg", -- 341
		"操作说明", -- 341
		leftX, -- 341
		h - 116, -- 341
		toColor(PALETTE.textBright), -- 341
		0, -- 341
		0.5, -- 341
		"Left", -- 341
		2, -- 341
		1 -- 341
	) -- 341
	uiGlow:drawSegment( -- 342
		Vec2(leftX, h - 142), -- 342
		Vec2(w - 86, h - 142), -- 342
		1.4, -- 342
		toColor(PALETTE.cyanDim, 180) -- 342
	) -- 342
	local colW = (w - leftX - 116) * 0.5 -- 344
	local panelY = h * 0.22 -- 345
	local panelH = h * 0.52 -- 346
	fillChamferBox( -- 349
		uiDraw, -- 349
		leftX, -- 349
		panelY, -- 349
		colW, -- 349
		panelH, -- 349
		16, -- 349
		toColor(PALETTE.panelBgDeep, 225), -- 349
		1.3, -- 349
		toColor(PALETTE.cyan, 185) -- 349
	) -- 349
	texts:put( -- 350
		"md", -- 350
		"周戍  //  军人线（枪战 · 掩体 · 护送）", -- 350
		leftX + 24, -- 350
		panelY + panelH - 32, -- 350
		toColor(PALETTE.cyanCore), -- 350
		0, -- 350
		0.5, -- 350
		"Left", -- 350
		0.6, -- 350
		1 -- 350
	) -- 350
	local sRows = { -- 351
		{"A / D", "左右移动"}, -- 352
		{"鼠标 + 左键", "瞄准与点射"}, -- 353
		{"SHIFT（按住）", "贴靠柜台/街垒掩体挡枪"}, -- 354
		{"SPACE", "平地高速翻滚 / 贴矮台翻越"}, -- 355
		{"E", "递物 / 敲两下安抚 / 按住+D 推车"}, -- 356
		{"ESC / R", "暂停 / 从检查点重试"} -- 357
	} -- 357
	local i = 0 -- 359
	do -- 359
		i = 0 -- 360
		while i < #sRows do -- 360
			local ry = panelY + panelH - 82 - i * 44 -- 361
			fillSkewRect( -- 362
				uiDraw, -- 362
				leftX + 24, -- 362
				ry - 12, -- 362
				132, -- 362
				24, -- 362
				6, -- 362
				Color(18, 42, 62, 220), -- 362
				1, -- 362
				toColor(PALETTE.cyanDim, 180) -- 362
			) -- 362
			texts:put( -- 363
				"xs", -- 363
				sRows[i + 1][1], -- 363
				leftX + 92, -- 363
				ry, -- 363
				toColor(PALETTE.cyanCore), -- 363
				0.5, -- 363
				0.5, -- 363
				"Center", -- 363
				0.4, -- 363
				1 -- 363
			) -- 363
			texts:put( -- 364
				"sm", -- 364
				sRows[i + 1][2], -- 364
				leftX + 174, -- 364
				ry, -- 364
				toColor(PALETTE.textBright), -- 364
				0, -- 364
				0.5, -- 364
				"Left", -- 364
				0.3, -- 364
				0.95 -- 364
			) -- 364
			i = i + 1 -- 360
		end -- 360
	end -- 360
	local rightX = leftX + colW + 28 -- 368
	fillChamferBox( -- 369
		uiDraw, -- 369
		rightX, -- 369
		panelY, -- 369
		colW, -- 369
		panelH, -- 369
		16, -- 369
		toColor(PALETTE.panelBgDeep, 225), -- 369
		1.3, -- 369
		toColor(PALETTE.amber, 185) -- 369
	) -- 369
	texts:put( -- 370
		"md", -- 370
		"小满  //  孩子线（潜行 · 平台 · 诱敌）", -- 370
		rightX + 24, -- 370
		panelY + panelH - 32, -- 370
		toColor(PALETTE.amberCore), -- 370
		0, -- 370
		0.5, -- 370
		"Left", -- 370
		0.6, -- 370
		1 -- 370
	) -- 370
	local cRows = { -- 371
		{"A / D", "潜行行走"}, -- 372
		{"SHIFT（按住）", "轻步慢走（压低脚步声）"}, -- 373
		{"S / CTRL（按住）", "蹲伏隐蔽 · 穿过 44 净高拱洞/桌下"}, -- 374
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 375
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉红布板车"}, -- 376
		{"F（按住→松手）", "预览抛物线落点，投瓶引开拾荒者"} -- 377
	} -- 377
	do -- 377
		i = 0 -- 379
		while i < #cRows do -- 379
			local ry = panelY + panelH - 82 - i * 44 -- 380
			fillSkewRect( -- 381
				uiDraw, -- 381
				rightX + 24, -- 381
				ry - 12, -- 381
				142, -- 381
				24, -- 381
				6, -- 381
				Color(52, 38, 18, 220), -- 381
				1, -- 381
				toColor(PALETTE.amberDim, 190) -- 381
			) -- 381
			texts:put( -- 382
				"xs", -- 382
				cRows[i + 1][1], -- 382
				rightX + 97, -- 382
				ry, -- 382
				toColor(PALETTE.amberCore), -- 382
				0.5, -- 382
				0.5, -- 382
				"Center", -- 382
				0.4, -- 382
				1 -- 382
			) -- 382
			texts:put( -- 383
				"sm", -- 383
				cRows[i + 1][2], -- 383
				rightX + 182, -- 383
				ry, -- 383
				toColor(PALETTE.textBright), -- 383
				0, -- 383
				0.5, -- 383
				"Left", -- 383
				0.3, -- 383
				0.95 -- 383
			) -- 383
			i = i + 1 -- 379
		end -- 379
	end -- 379
	local backX = leftX -- 386
	local backY = 48 -- 387
	local backHover = pointer.x >= backX and pointer.x <= backX + 190 and pointer.y >= backY and pointer.y <= backY + 34 -- 388
	fillSkewRect( -- 389
		uiDraw, -- 389
		backX, -- 389
		backY, -- 389
		186, -- 389
		34, -- 389
		9, -- 389
		toColor(PALETTE.panelBg, 210), -- 389
		1.2, -- 389
		toColor(backHover and PALETTE.cyan or PALETTE.steelLight, 200) -- 389
	) -- 389
	texts:put( -- 390
		"xs", -- 390
		"← 返回标题 [ESC / ENTER]", -- 390
		backX + 96, -- 390
		backY + 17, -- 390
		toColor(backHover and PALETTE.cyanCore or PALETTE.textMid), -- 390
		0.5, -- 390
		0.5, -- 390
		"Center", -- 390
		0.5, -- 390
		1 -- 390
	) -- 390
	if clicked and backHover then -- 390
		return {type = "backTitle"} -- 393
	end -- 393
	return {type = "none"} -- 395
end -- 326
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiGlow, texts, w, h, uiScale) -- 399
	self.time = self.time + dt -- 409
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 410
	local mk = self:readMenuKeys() -- 411
	local clicked = self:clickEdge(input) -- 412
	if mk.up then -- 412
		self.pauseSelected = (self.pauseSelected + #PAUSE_ITEMS - 1) % #PAUSE_ITEMS -- 415
	elseif mk.down then -- 415
		self.pauseSelected = (self.pauseSelected + 1) % #PAUSE_ITEMS -- 417
	end -- 417
	uiDraw:drawRect( -- 421
		Rect(0, 0, w, h), -- 421
		Color(4, 7, 13, 175) -- 421
	) -- 421
	local boxW = 390 -- 423
	local boxH = 336 -- 424
	local bx = (w - boxW) * 0.5 -- 425
	local by = (h - boxH) * 0.5 -- 426
	fillChamferBox( -- 428
		uiDraw, -- 428
		bx, -- 428
		by, -- 428
		boxW, -- 428
		boxH, -- 428
		18, -- 428
		toColor(PALETTE.panelBgDeep, 242), -- 428
		1.5, -- 428
		toColor(PALETTE.cyan, 210) -- 428
	) -- 428
	fillVGradRect( -- 429
		uiGlow, -- 429
		bx, -- 429
		by + boxH - 64, -- 429
		boxW, -- 429
		64, -- 429
		Color(193, 161, 114, 0), -- 429
		Color(193, 161, 114, 36) -- 429
	) -- 429
	texts:put( -- 430
		"lg", -- 430
		"游戏暂停", -- 430
		bx + 28, -- 430
		by + boxH - 56, -- 430
		toColor(PALETTE.textBright), -- 430
		0, -- 430
		0.5, -- 430
		"Left", -- 430
		1.8, -- 430
		1 -- 430
	) -- 430
	local hitIdx = -1 -- 432
	local i = 0 -- 433
	do -- 433
		i = 0 -- 434
		while i < #PAUSE_ITEMS do -- 434
			local iy = by + boxH - 122 - i * 54 -- 435
			local ix = bx + 28 -- 436
			local iw = boxW - 56 -- 437
			local ih = 42 -- 438
			local hover = pointer.x >= ix and pointer.x <= ix + iw and pointer.y >= iy and pointer.y <= iy + ih -- 439
			if hover then -- 439
				self.pauseSelected = i -- 441
				hitIdx = i -- 442
			end -- 442
			local active = self.pauseSelected == i -- 444
			fillSkewRect( -- 445
				uiDraw, -- 446
				ix, -- 447
				iy, -- 448
				iw, -- 449
				ih, -- 450
				10, -- 451
				active and Color(59, 44, 41, 233) or Color(12, 18, 30, 200), -- 452
				active and 1.5 or 1, -- 453
				toColor(active and PALETTE.cyan or PALETTE.steelLight, active and 240 or 130) -- 454
			) -- 454
			if active then -- 454
				fillSkewRect( -- 457
					uiGlow, -- 457
					ix - 3, -- 457
					iy, -- 457
					5, -- 457
					ih, -- 457
					10, -- 457
					toColor(PALETTE.cyanCore, 235) -- 457
				) -- 457
			end -- 457
			texts:put( -- 459
				"sm", -- 459
				(active and "▸  " or "   ") .. PAUSE_ITEMS[i + 1].zh, -- 459
				ix + 18, -- 459
				iy + 21, -- 459
				toColor(active and PALETTE.cyanCore or PALETTE.textBright), -- 459
				0, -- 459
				0.5, -- 459
				"Left", -- 459
				0.8, -- 459
				1 -- 459
			) -- 459
			i = i + 1 -- 434
		end -- 434
	end -- 434
	if mk.confirm or clicked and hitIdx >= 0 then -- 434
		local id = PAUSE_ITEMS[self.pauseSelected + 1].id -- 463
		if id == "resume" then -- 463
			return {type = "resume"} -- 465
		end -- 465
		if id == "retry" then -- 465
			return {type = "retry"} -- 468
		end -- 468
		if id == "chapters" then -- 468
			return {type = "openChapters"} -- 471
		end -- 471
		return {type = "toTitle"} -- 473
	end -- 473
	return {type = "none"} -- 475
end -- 399
return ____exports -- 399