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
local ____theme = require("Script.watch.fe.theme") -- 14
local PALETTE = ____theme.PALETTE -- 15
local drawDiamond = ____theme.drawDiamond -- 16
local fillChamferBox = ____theme.fillChamferBox -- 17
local fillRadialGlow = ____theme.fillRadialGlow -- 18
local fillSkewRect = ____theme.fillSkewRect -- 19
local fillVGradRect = ____theme.fillVGradRect -- 20
local themeOf = ____theme.themeOf -- 21
local toColor = ____theme.toColor -- 22
local TITLE_ITEMS = {{id = "start", zh = "开始接入", en = "INITIATE // PROLOGUE"}, {id = "chapters", zh = "章节直达", en = "CHAPTER MATRIX (01-08)"}, {id = "controls", zh = "操作图鉴", en = "CONTROL INTERFACE"}} -- 32
local PAUSE_ITEMS = {{id = "resume", zh = "继续任务", en = "RESUME"}, {id = "retry", zh = "重来本段", en = "RETRY CHECKPOINT"}, {id = "chapters", zh = "章节直达", en = "CHAPTER SELECT"}, {id = "title", zh = "返回标题", en = "DISCONNECT TO TITLE"}} -- 38
____exports.MenuRenderer = __TS__Class() -- 45
local MenuRenderer = ____exports.MenuRenderer -- 45
MenuRenderer.name = "MenuRenderer" -- 45
function MenuRenderer.prototype.____constructor(self) -- 45
	self.selected = 0 -- 46
	self.chapterSelected = 0 -- 47
	self.pauseSelected = 0 -- 48
	self.prevUp = false -- 49
	self.prevDown = false -- 50
	self.prevLeft = false -- 51
	self.prevRight = false -- 52
	self.prevEnter = false -- 53
	self.prevClick = false -- 54
	self.queuedUp = false -- 55
	self.queuedDown = false -- 56
	self.queuedLeft = false -- 57
	self.queuedRight = false -- 58
	self.queuedConfirm = false -- 59
	self.queuedBack = false -- 60
	self.time = 0 -- 61
end -- 45
function MenuRenderer.prototype.onKeyEvent(self, key) -- 64
	if key == "Up" or key == "W" then -- 64
		self.queuedUp = true -- 66
	elseif key == "Down" or key == "S" then -- 66
		self.queuedDown = true -- 68
	elseif key == "Left" or key == "A" then -- 68
		self.queuedLeft = true -- 70
	elseif key == "Right" or key == "D" then -- 70
		self.queuedRight = true -- 72
	elseif key == "Return" or key == "Space" then -- 72
		self.queuedConfirm = true -- 74
	elseif key == "Escape" then -- 74
		self.queuedBack = true -- 76
	end -- 76
end -- 64
function MenuRenderer.prototype.readMenuKeys(self) -- 80
	local u = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 81
	local d = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 82
	local l = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 83
	local r = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 84
	local e = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 85
	local res = { -- 86
		up = u and not self.prevUp or self.queuedUp, -- 87
		down = d and not self.prevDown or self.queuedDown, -- 88
		left = l and not self.prevLeft or self.queuedLeft, -- 89
		right = r and not self.prevRight or self.queuedRight, -- 90
		confirm = e and not self.prevEnter or self.queuedConfirm, -- 91
		back = self.queuedBack -- 92
	} -- 92
	self.prevUp = u -- 94
	self.prevDown = d -- 95
	self.prevLeft = l -- 96
	self.prevRight = r -- 97
	self.prevEnter = e -- 98
	self.queuedUp = false -- 99
	self.queuedDown = false -- 100
	self.queuedLeft = false -- 101
	self.queuedRight = false -- 102
	self.queuedConfirm = false -- 103
	self.queuedBack = false -- 104
	return res -- 105
end -- 80
function MenuRenderer.prototype.clickEdge(self, input) -- 108
	local held = input.fire.held -- 109
	local fired = held and not self.prevClick -- 110
	self.prevClick = held -- 111
	return fired -- 112
end -- 108
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, uiDraw, uiGlow, texts, w, h) -- 116
	self.time = self.time + dt -- 129
	stage:drawMenuBackdrop( -- 130
		bgDraw, -- 130
		bgGlow, -- 130
		w, -- 130
		h, -- 130
		self.time -- 130
	) -- 130
	local y = 16 -- 133
	while y < h do -- 133
		uiDraw:drawSegment( -- 135
			Vec2(0, y), -- 135
			Vec2(w, y), -- 135
			0.5, -- 135
			Color(72, 224, 255, 8) -- 135
		) -- 135
		y = y + 14 -- 136
	end -- 136
	uiDraw:drawSegment( -- 138
		Vec2(66, 48), -- 138
		Vec2(66, h - 48), -- 138
		1.2, -- 138
		toColor(PALETTE.cyanDim, 140) -- 138
	) -- 138
	drawDiamond( -- 139
		uiGlow, -- 139
		66, -- 139
		h - 48, -- 139
		5, -- 139
		5, -- 139
		toColor(PALETTE.cyan) -- 139
	) -- 139
	drawDiamond( -- 140
		uiGlow, -- 140
		66, -- 140
		48, -- 140
		5, -- 140
		5, -- 140
		toColor(PALETTE.cyanDim) -- 140
	) -- 140
	local mk = self:readMenuKeys() -- 142
	local clicked = self:clickEdge(input) -- 143
	if screen == "title" then -- 143
		return self:drawTitle( -- 146
			mk, -- 146
			clicked, -- 146
			input, -- 146
			uiDraw, -- 146
			uiGlow, -- 146
			texts, -- 146
			w, -- 146
			h -- 146
		) -- 146
	end -- 146
	if screen == "chapters" then -- 146
		return self:drawChapters( -- 149
			mk, -- 149
			clicked, -- 149
			input, -- 149
			uiDraw, -- 149
			uiGlow, -- 149
			texts, -- 149
			w, -- 149
			h -- 149
		) -- 149
	end -- 149
	return self:drawControls( -- 151
		mk, -- 151
		clicked, -- 151
		input, -- 151
		uiDraw, -- 151
		uiGlow, -- 151
		texts, -- 151
		w, -- 151
		h -- 151
	) -- 151
end -- 116
function MenuRenderer.prototype.drawTitle(self, mk, clicked, input, uiDraw, uiGlow, texts, w, h) -- 154
	if mk.up then -- 154
		self.selected = (self.selected + #TITLE_ITEMS - 1) % #TITLE_ITEMS -- 165
	elseif mk.down then -- 165
		self.selected = (self.selected + 1) % #TITLE_ITEMS -- 167
	end -- 167
	local leftX = 104 -- 170
	local titleY = h * 0.72 -- 171
	texts:put( -- 174
		"xs", -- 174
		"SYS // TERMINAL ACCESS   ·   DORA SSR FRONTEND PROTOTYPE", -- 174
		leftX, -- 174
		titleY + 62, -- 174
		toColor(PALETTE.cyan), -- 174
		0, -- 174
		0.5, -- 174
		"Left", -- 174
		1.8, -- 174
		0.92 -- 174
	) -- 174
	uiGlow:drawSegment( -- 175
		Vec2(leftX - 10, titleY - 12), -- 175
		Vec2(leftX + 430, titleY - 12), -- 175
		2.2, -- 175
		toColor(PALETTE.cyan, 215) -- 175
	) -- 175
	uiGlow:drawSegment( -- 176
		Vec2(leftX + 390, titleY - 12), -- 176
		Vec2(leftX + 448, titleY + 26), -- 176
		1.8, -- 176
		toColor(PALETTE.cyanCore, 180) -- 176
	) -- 176
	texts:put( -- 178
		"xl", -- 178
		"月下山谷 · 守望", -- 178
		leftX, -- 178
		titleY + 24, -- 178
		toColor(PALETTE.textBright), -- 178
		0, -- 178
		0.5, -- 178
		"Left", -- 178
		3.2, -- 178
		1 -- 178
	) -- 178
	texts:put( -- 179
		"sm", -- 179
		"VALLEY UNDER MOONLIGHT  //  双线叙事动作与潜行", -- 179
		leftX, -- 179
		titleY - 34, -- 179
		toColor(PALETTE.textMid), -- 179
		0, -- 179
		0.5, -- 179
		"Left", -- 179
		1.2, -- 179
		0.92 -- 179
	) -- 179
	texts:put( -- 180
		"xs", -- 180
		"“城破那天，一个士兵把一个孩子送出了城门；现在，她要一个人走到北方的塔。”", -- 180
		leftX, -- 180
		titleY - 64, -- 180
		toColor(PALETTE.amberCore), -- 180
		0, -- 180
		0.5, -- 180
		"Left", -- 180
		0.4, -- 180
		0.85 -- 180
	) -- 180
	local btnW = 340 -- 183
	local btnH = 50 -- 184
	local gap = 16 -- 185
	local startY = h * 0.42 -- 186
	local hitIdx = -1 -- 187
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < #TITLE_ITEMS do -- 190
			local bx = leftX -- 191
			local by = startY - i * (btnH + gap) -- 192
			local hover = input.mx >= bx and input.mx <= bx + btnW + 16 and input.my >= by and input.my <= by + btnH -- 193
			if hover then -- 193
				self.selected = i -- 195
				hitIdx = i -- 196
			end -- 196
			local active = self.selected == i -- 198
			local shiftX = active and 12 or 0 -- 199
			fillSkewRect( -- 201
				uiDraw, -- 202
				bx + shiftX, -- 203
				by, -- 204
				btnW, -- 205
				btnH, -- 206
				14, -- 207
				active and Color(18, 44, 68, 228) or toColor(PALETTE.panelBg, 195), -- 208
				active and 1.6 or 1, -- 209
				toColor(active and PALETTE.cyan or PALETTE.steelLight, active and 240 or 140) -- 210
			) -- 210
			if active then -- 210
				fillSkewRect( -- 213
					uiGlow, -- 213
					bx + shiftX - 4, -- 213
					by, -- 213
					6, -- 213
					btnH, -- 213
					14, -- 213
					toColor(PALETTE.cyanCore, 240) -- 213
				) -- 213
				fillRadialGlow( -- 214
					uiGlow, -- 214
					bx + shiftX + 24, -- 214
					by + btnH * 0.5, -- 214
					42, -- 214
					22, -- 214
					toColor(PALETTE.cyan, 85), -- 214
					Color(72, 224, 255, 0), -- 214
					12 -- 214
				) -- 214
			end -- 214
			texts:put( -- 216
				"md", -- 216
				(active and "▸  " or "   ") .. TITLE_ITEMS[i + 1].zh, -- 216
				bx + shiftX + 22, -- 216
				by + 31, -- 216
				toColor(active and PALETTE.cyanCore or PALETTE.textBright), -- 216
				0, -- 216
				0.5, -- 216
				"Left", -- 216
				1, -- 216
				1 -- 216
			) -- 216
			texts:put( -- 217
				"xs", -- 217
				TITLE_ITEMS[i + 1].en, -- 217
				bx + shiftX + 42, -- 217
				by + 12, -- 217
				toColor(active and PALETTE.cyan or PALETTE.textDim), -- 217
				0, -- 217
				0.5, -- 217
				"Left", -- 217
				1, -- 217
				0.9 -- 217
			) -- 217
			i = i + 1 -- 190
		end -- 190
	end -- 190
	texts:put( -- 221
		"xs", -- 221
		"↑ / ↓ 选择   ·   ENTER / 点击 确认   ·   支持 8 章节全链体验", -- 221
		leftX, -- 221
		52, -- 221
		toColor(PALETTE.textDim), -- 221
		0, -- 221
		0.5, -- 221
		"Left", -- 221
		0.8, -- 221
		0.85 -- 221
	) -- 221
	texts:put( -- 222
		"xs", -- 222
		"BUILD // ICEY-STYLE PROCEDURAL VECTOR FRONTEND", -- 222
		w - 48, -- 222
		52, -- 222
		toColor(PALETTE.cyanDim), -- 222
		1, -- 222
		0.5, -- 222
		"Right", -- 222
		1, -- 222
		0.8 -- 222
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
end -- 154
function MenuRenderer.prototype.drawChapters(self, mk, clicked, input, uiDraw, uiGlow, texts, w, h) -- 237
	if input.pause.pressed or mk.back then -- 237
		return {type = "backTitle"} -- 248
	end -- 248
	if mk.left then -- 248
		self.chapterSelected = (self.chapterSelected + #ROOMS - 1) % #ROOMS -- 251
	elseif mk.right then -- 251
		self.chapterSelected = (self.chapterSelected + 1) % #ROOMS -- 253
	elseif mk.up then -- 253
		self.chapterSelected = (self.chapterSelected + #ROOMS - 4) % #ROOMS -- 255
	elseif mk.down then -- 255
		self.chapterSelected = (self.chapterSelected + 4) % #ROOMS -- 257
	end -- 257
	local leftX = 104 -- 260
	texts:put( -- 261
		"xs", -- 261
		"CHAPTER MATRIX  //  双线叙事八段关卡直达", -- 261
		leftX, -- 261
		h - 78, -- 261
		toColor(PALETTE.cyan), -- 261
		0, -- 261
		0.5, -- 261
		"Left", -- 261
		1.6, -- 261
		1 -- 261
	) -- 261
	texts:put( -- 262
		"lg", -- 262
		"选择接入节点", -- 262
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
			local hover = input.mx >= cx and input.mx <= cx + cardW and input.my >= cy and input.my <= cy + cardH -- 284
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
			texts:put( -- 305
				"xs", -- 305
				theme.titleEn, -- 305
				cx + 16, -- 305
				cy + 26, -- 305
				toColor(PALETTE.textDim), -- 305
				0, -- 305
				0.5, -- 305
				"Left", -- 305
				0.5, -- 305
				0.9 -- 305
			) -- 305
			if active then -- 305
				drawDiamond( -- 307
					uiGlow, -- 307
					cx + cardW - 22, -- 307
					cy + 24, -- 307
					6, -- 307
					6, -- 307
					toColor(theme.accent) -- 307
				) -- 307
			end -- 307
			i = i + 1 -- 278
		end -- 278
	end -- 278
	local backX = leftX -- 312
	local backY = 48 -- 313
	local backHover = input.mx >= backX and input.mx <= backX + 160 and input.my >= backY and input.my <= backY + 34 -- 314
	fillSkewRect( -- 315
		uiDraw, -- 315
		backX, -- 315
		backY, -- 315
		156, -- 315
		34, -- 315
		9, -- 315
		toColor(PALETTE.panelBg, 210), -- 315
		1.2, -- 315
		toColor(backHover and PALETTE.cyan or PALETTE.steelLight, 200) -- 315
	) -- 315
	texts:put( -- 316
		"xs", -- 316
		"← 返回标题 [ESC]", -- 316
		backX + 82, -- 316
		backY + 17, -- 316
		toColor(backHover and PALETTE.cyanCore or PALETTE.textMid), -- 316
		0.5, -- 316
		0.5, -- 316
		"Center", -- 316
		0.6, -- 316
		1 -- 316
	) -- 316
	if clicked and backHover then -- 316
		return {type = "backTitle"} -- 319
	end -- 319
	if mk.confirm or clicked and hitIdx >= 0 then -- 319
		return {type = "jump", roomIndex = self.chapterSelected} -- 322
	end -- 322
	return {type = "none"} -- 324
end -- 237
function MenuRenderer.prototype.drawControls(self, mk, clicked, input, uiDraw, uiGlow, texts, w, h) -- 327
	if input.pause.pressed or mk.back or mk.confirm then -- 327
		return {type = "backTitle"} -- 338
	end -- 338
	local leftX = 104 -- 340
	texts:put( -- 341
		"xs", -- 341
		"CONTROL INTERFACE  //  双线共享键位对照", -- 341
		leftX, -- 341
		h - 78, -- 341
		toColor(PALETTE.cyan), -- 341
		0, -- 341
		0.5, -- 341
		"Left", -- 341
		1.6, -- 341
		1 -- 341
	) -- 341
	texts:put( -- 342
		"lg", -- 342
		"操作图鉴", -- 342
		leftX, -- 342
		h - 116, -- 342
		toColor(PALETTE.textBright), -- 342
		0, -- 342
		0.5, -- 342
		"Left", -- 342
		2, -- 342
		1 -- 342
	) -- 342
	uiGlow:drawSegment( -- 343
		Vec2(leftX, h - 142), -- 343
		Vec2(w - 86, h - 142), -- 343
		1.4, -- 343
		toColor(PALETTE.cyanDim, 180) -- 343
	) -- 343
	local colW = (w - leftX - 116) * 0.5 -- 345
	local panelY = h * 0.22 -- 346
	local panelH = h * 0.52 -- 347
	fillChamferBox( -- 350
		uiDraw, -- 350
		leftX, -- 350
		panelY, -- 350
		colW, -- 350
		panelH, -- 350
		16, -- 350
		toColor(PALETTE.panelBgDeep, 225), -- 350
		1.3, -- 350
		toColor(PALETTE.cyan, 185) -- 350
	) -- 350
	texts:put( -- 351
		"md", -- 351
		"周戍  //  军人线（枪战 · 掩体 · 护送）", -- 351
		leftX + 24, -- 351
		panelY + panelH - 32, -- 351
		toColor(PALETTE.cyanCore), -- 351
		0, -- 351
		0.5, -- 351
		"Left", -- 351
		0.6, -- 351
		1 -- 351
	) -- 351
	local sRows = { -- 352
		{"A / D", "战术横移"}, -- 353
		{"鼠标 + 左键", "瞄准与点射（射线判定）"}, -- 354
		{"SHIFT（按住）", "贴靠柜台/街垒掩体挡枪"}, -- 355
		{"SPACE", "平地高速翻滚 / 贴矮台翻越"}, -- 356
		{"E", "递物 / 敲两下安抚 / 按住+D 推车"}, -- 357
		{"ESC / R", "暂停系统 / 从检查点重试"} -- 358
	} -- 358
	local i = 0 -- 360
	do -- 360
		i = 0 -- 361
		while i < #sRows do -- 361
			local ry = panelY + panelH - 82 - i * 44 -- 362
			fillSkewRect( -- 363
				uiDraw, -- 363
				leftX + 24, -- 363
				ry - 12, -- 363
				132, -- 363
				24, -- 363
				6, -- 363
				Color(18, 42, 62, 220), -- 363
				1, -- 363
				toColor(PALETTE.cyanDim, 180) -- 363
			) -- 363
			texts:put( -- 364
				"xs", -- 364
				sRows[i + 1][1], -- 364
				leftX + 92, -- 364
				ry, -- 364
				toColor(PALETTE.cyanCore), -- 364
				0.5, -- 364
				0.5, -- 364
				"Center", -- 364
				0.4, -- 364
				1 -- 364
			) -- 364
			texts:put( -- 365
				"sm", -- 365
				sRows[i + 1][2], -- 365
				leftX + 174, -- 365
				ry, -- 365
				toColor(PALETTE.textBright), -- 365
				0, -- 365
				0.5, -- 365
				"Left", -- 365
				0.3, -- 365
				0.95 -- 365
			) -- 365
			i = i + 1 -- 361
		end -- 361
	end -- 361
	local rightX = leftX + colW + 28 -- 369
	fillChamferBox( -- 370
		uiDraw, -- 370
		rightX, -- 370
		panelY, -- 370
		colW, -- 370
		panelH, -- 370
		16, -- 370
		toColor(PALETTE.panelBgDeep, 225), -- 370
		1.3, -- 370
		toColor(PALETTE.amber, 185) -- 370
	) -- 370
	texts:put( -- 371
		"md", -- 371
		"小满  //  孩子线（潜行 · 平台 · 诱敌）", -- 371
		rightX + 24, -- 371
		panelY + panelH - 32, -- 371
		toColor(PALETTE.amberCore), -- 371
		0, -- 371
		0.5, -- 371
		"Left", -- 371
		0.6, -- 371
		1 -- 371
	) -- 371
	local cRows = { -- 372
		{"A / D", "潜行行走"}, -- 373
		{"SHIFT（按住）", "轻步慢走（压低脚步声）"}, -- 374
		{"S / CTRL（按住）", "蹲伏隐蔽 · 穿过 44 净高拱洞/桌下"}, -- 375
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 376
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉红布板车"}, -- 377
		{"F（按住→松手）", "预览抛物线落点，投瓶引开拾荒者"} -- 378
	} -- 378
	do -- 378
		i = 0 -- 380
		while i < #cRows do -- 380
			local ry = panelY + panelH - 82 - i * 44 -- 381
			fillSkewRect( -- 382
				uiDraw, -- 382
				rightX + 24, -- 382
				ry - 12, -- 382
				142, -- 382
				24, -- 382
				6, -- 382
				Color(52, 38, 18, 220), -- 382
				1, -- 382
				toColor(PALETTE.amberDim, 190) -- 382
			) -- 382
			texts:put( -- 383
				"xs", -- 383
				cRows[i + 1][1], -- 383
				rightX + 97, -- 383
				ry, -- 383
				toColor(PALETTE.amberCore), -- 383
				0.5, -- 383
				0.5, -- 383
				"Center", -- 383
				0.4, -- 383
				1 -- 383
			) -- 383
			texts:put( -- 384
				"sm", -- 384
				cRows[i + 1][2], -- 384
				rightX + 182, -- 384
				ry, -- 384
				toColor(PALETTE.textBright), -- 384
				0, -- 384
				0.5, -- 384
				"Left", -- 384
				0.3, -- 384
				0.95 -- 384
			) -- 384
			i = i + 1 -- 380
		end -- 380
	end -- 380
	local backX = leftX -- 387
	local backY = 48 -- 388
	local backHover = input.mx >= backX and input.mx <= backX + 190 and input.my >= backY and input.my <= backY + 34 -- 389
	fillSkewRect( -- 390
		uiDraw, -- 390
		backX, -- 390
		backY, -- 390
		186, -- 390
		34, -- 390
		9, -- 390
		toColor(PALETTE.panelBg, 210), -- 390
		1.2, -- 390
		toColor(backHover and PALETTE.cyan or PALETTE.steelLight, 200) -- 390
	) -- 390
	texts:put( -- 391
		"xs", -- 391
		"← 返回标题 [ESC / ENTER]", -- 391
		backX + 96, -- 391
		backY + 17, -- 391
		toColor(backHover and PALETTE.cyanCore or PALETTE.textMid), -- 391
		0.5, -- 391
		0.5, -- 391
		"Center", -- 391
		0.5, -- 391
		1 -- 391
	) -- 391
	if clicked and backHover then -- 391
		return {type = "backTitle"} -- 394
	end -- 394
	return {type = "none"} -- 396
end -- 327
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiGlow, texts, w, h) -- 400
	self.time = self.time + dt -- 409
	local mk = self:readMenuKeys() -- 410
	local clicked = self:clickEdge(input) -- 411
	if mk.up then -- 411
		self.pauseSelected = (self.pauseSelected + #PAUSE_ITEMS - 1) % #PAUSE_ITEMS -- 414
	elseif mk.down then -- 414
		self.pauseSelected = (self.pauseSelected + 1) % #PAUSE_ITEMS -- 416
	end -- 416
	uiDraw:drawRect( -- 420
		Rect(0, 0, w, h), -- 420
		Color(4, 7, 13, 175) -- 420
	) -- 420
	local boxW = 390 -- 422
	local boxH = 336 -- 423
	local bx = (w - boxW) * 0.5 -- 424
	local by = (h - boxH) * 0.5 -- 425
	fillChamferBox( -- 427
		uiDraw, -- 427
		bx, -- 427
		by, -- 427
		boxW, -- 427
		boxH, -- 427
		18, -- 427
		toColor(PALETTE.panelBgDeep, 242), -- 427
		1.5, -- 427
		toColor(PALETTE.cyan, 210) -- 427
	) -- 427
	fillVGradRect( -- 428
		uiGlow, -- 428
		bx, -- 428
		by + boxH - 64, -- 428
		boxW, -- 428
		64, -- 428
		Color(72, 224, 255, 0), -- 428
		Color(72, 224, 255, 42) -- 428
	) -- 428
	texts:put( -- 429
		"xs", -- 429
		"SYSTEM PAUSED  //  已挂起", -- 429
		bx + 28, -- 429
		by + boxH - 24, -- 429
		toColor(PALETTE.cyan), -- 429
		0, -- 429
		0.5, -- 429
		"Left", -- 429
		1.4, -- 429
		1 -- 429
	) -- 429
	texts:put( -- 430
		"lg", -- 430
		"任务暂停", -- 430
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
			local hover = input.mx >= ix and input.mx <= ix + iw and input.my >= iy and input.my <= iy + ih -- 439
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
				active and Color(20, 48, 72, 232) or Color(12, 18, 30, 200), -- 452
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
			texts:put( -- 460
				"xs", -- 460
				PAUSE_ITEMS[i + 1].en, -- 460
				ix + iw - 14, -- 460
				iy + 21, -- 460
				toColor(active and PALETTE.cyan or PALETTE.textDim), -- 460
				1, -- 460
				0.5, -- 460
				"Right", -- 460
				0.8, -- 460
				0.9 -- 460
			) -- 460
			i = i + 1 -- 434
		end -- 434
	end -- 434
	if mk.confirm or clicked and hitIdx >= 0 then -- 434
		local id = PAUSE_ITEMS[self.pauseSelected + 1].id -- 464
		if id == "resume" then -- 464
			return {type = "resume"} -- 466
		end -- 466
		if id == "retry" then -- 466
			return {type = "retry"} -- 469
		end -- 469
		if id == "chapters" then -- 469
			return {type = "openChapters"} -- 472
		end -- 472
		return {type = "toTitle"} -- 474
	end -- 474
	return {type = "none"} -- 476
end -- 400
return ____exports -- 400