-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
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
____exports.MenuRenderer = __TS__Class() -- 60
local MenuRenderer = ____exports.MenuRenderer -- 60
MenuRenderer.name = "MenuRenderer" -- 60
function MenuRenderer.prototype.____constructor(self) -- 60
	self.selected = 0 -- 61
	self.chapterSelected = 0 -- 62
	self.pauseSelected = 0 -- 63
	self.prevUp = false -- 64
	self.prevDown = false -- 65
	self.prevLeft = false -- 66
	self.prevRight = false -- 67
	self.prevEnter = false -- 68
	self.prevClick = false -- 69
	self.queuedUp = false -- 70
	self.queuedDown = false -- 71
	self.queuedLeft = false -- 72
	self.queuedRight = false -- 73
	self.queuedConfirm = false -- 74
	self.queuedBack = false -- 75
	self.time = 0 -- 76
end -- 60
function MenuRenderer.prototype.onKeyEvent(self, key) -- 78
	if key == "Up" or key == "W" then -- 78
		self.queuedUp = true -- 80
	elseif key == "Down" or key == "S" then -- 80
		self.queuedDown = true -- 82
	elseif key == "Left" or key == "A" then -- 82
		self.queuedLeft = true -- 84
	elseif key == "Right" or key == "D" then -- 84
		self.queuedRight = true -- 86
	elseif key == "Return" or key == "Space" then -- 86
		self.queuedConfirm = true -- 88
	elseif key == "Escape" then -- 88
		self.queuedBack = true -- 90
	end -- 90
end -- 78
function MenuRenderer.prototype.readMenuKeys(self) -- 94
	local u = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W") -- 95
	local d = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S") -- 96
	local l = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A") -- 97
	local r = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D") -- 98
	local e = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 99
	local res = { -- 100
		up = u and not self.prevUp or self.queuedUp, -- 101
		down = d and not self.prevDown or self.queuedDown, -- 102
		left = l and not self.prevLeft or self.queuedLeft, -- 103
		right = r and not self.prevRight or self.queuedRight, -- 104
		confirm = e and not self.prevEnter or self.queuedConfirm, -- 105
		back = self.queuedBack -- 106
	} -- 106
	self.prevUp = u -- 108
	self.prevDown = d -- 109
	self.prevLeft = l -- 110
	self.prevRight = r -- 111
	self.prevEnter = e -- 112
	self.queuedUp = false -- 113
	self.queuedDown = false -- 114
	self.queuedLeft = false -- 115
	self.queuedRight = false -- 116
	self.queuedConfirm = false -- 117
	self.queuedBack = false -- 118
	return res -- 119
end -- 94
function MenuRenderer.prototype.clickEdge(self, input) -- 122
	local held = input.fire.held -- 123
	local fired = held and not self.prevClick -- 124
	self.prevClick = held -- 125
	return fired -- 126
end -- 122
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale) -- 129
	self.time = self.time + dt -- 146
	local artW = math.max(w, h * 16 / 9) -- 147
	local artH = artW * 9 / 16 -- 148
	if not backdropArt:tryPlace( -- 148
		"title_backdrop", -- 149
		"menu_landscape", -- 149
		w * 0.5, -- 149
		(h - artH) * 0.5, -- 149
		artW, -- 149
		artH -- 149
	) then -- 149
		stage:drawMenuBackdrop( -- 150
			bgDraw, -- 150
			bgGlow, -- 150
			w, -- 150
			h, -- 150
			self.time -- 150
		) -- 150
	end -- 150
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 153
	w = w / uiScale -- 154
	h = h / uiScale -- 155
	local mk = self:readMenuKeys() -- 157
	local clicked = self:clickEdge(input) -- 158
	if screen == "title" then -- 158
		return self:drawTitle( -- 161
			mk, -- 161
			clicked, -- 161
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
	if screen == "chapters" then -- 161
		return self:drawChapters( -- 164
			mk, -- 164
			clicked, -- 164
			input, -- 164
			pointer, -- 164
			uiDraw, -- 164
			uiInkDraw, -- 164
			uiArt, -- 164
			uiGlow, -- 164
			texts, -- 164
			w, -- 164
			h -- 164
		) -- 164
	end -- 164
	return self:drawControls( -- 166
		mk, -- 166
		clicked, -- 166
		input, -- 166
		pointer, -- 166
		uiDraw, -- 166
		uiInkDraw, -- 166
		uiArt, -- 166
		uiGlow, -- 166
		texts, -- 166
		w, -- 166
		h -- 166
	) -- 166
end -- 129
function MenuRenderer.prototype.drawTitle(self, mk, clicked, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 169
	if mk.up then -- 169
		self.selected = (self.selected + #TITLE_ITEMS - 1) % #TITLE_ITEMS -- 182
	elseif mk.down then -- 182
		self.selected = (self.selected + 1) % #TITLE_ITEMS -- 184
	end -- 184
	fillHGradRect( -- 188
		uiDraw, -- 188
		0, -- 188
		0, -- 188
		w * 0.22, -- 188
		h, -- 188
		Color(9, 11, 18, 192), -- 188
		Color(9, 11, 18, 116) -- 188
	) -- 188
	fillHGradRect( -- 189
		uiDraw, -- 189
		w * 0.22, -- 189
		0, -- 189
		w * 0.28, -- 189
		h, -- 189
		Color(9, 11, 18, 116), -- 189
		Color(9, 11, 18, 0) -- 189
	) -- 189
	fillVGradRect( -- 190
		uiDraw, -- 190
		0, -- 190
		0, -- 190
		w, -- 190
		78, -- 190
		Color(8, 10, 16, 138), -- 190
		Color(8, 10, 16, 0) -- 190
	) -- 190
	local titleX = 148 -- 193
	local topY = h - 104 -- 194
	local charStep = 66 -- 195
	local sway = math.sin(self.time * 0.7) * 5 -- 196
	drawMistCurve( -- 197
		uiArt, -- 197
		"title_mist_wisp", -- 197
		titleX + 86 + sway, -- 197
		topY - 122, -- 197
		340, -- 197
		82, -- 197
		PALETTE.jadeMist, -- 197
		0.2, -- 197
		-1 -- 197
	) -- 197
	uiArt:tryPlace( -- 198
		"ink_petal_mist", -- 198
		"title_petals", -- 198
		titleX + 12, -- 198
		topY - 102, -- 198
		230, -- 198
		210, -- 198
		{ -- 198
			color = toColor(PALETTE.inkMist), -- 199
			opacity = 0.4, -- 199
			layer = -1 -- 199
		} -- 199
	) -- 199
	uiArt:tryPlace( -- 201
		"ink_vstream", -- 201
		"title_vstream", -- 201
		titleX - 48, -- 201
		topY - 100, -- 201
		34, -- 201
		290, -- 201
		{ -- 201
			color = toColor(PALETTE.silkDim), -- 202
			opacity = 0.48, -- 202
			layer = 1 -- 202
		} -- 202
	) -- 202
	local c = 0 -- 206
	do -- 206
		c = 0 -- 207
		while c < #VERTICAL_TITLE do -- 207
			texts:put( -- 208
				"title", -- 209
				VERTICAL_TITLE[c + 1], -- 210
				titleX, -- 211
				topY - c * charStep, -- 212
				toColor(PALETTE.textBright), -- 213
				0.5, -- 214
				0.5, -- 215
				"Center", -- 216
				0, -- 217
				0.98, -- 218
				0.1, -- 219
				Color(8, 10, 16, 210) -- 220
			) -- 220
			c = c + 1 -- 207
		end -- 207
	end -- 207
	drawLoneSeal( -- 225
		uiInkDraw, -- 226
		uiArt, -- 227
		texts, -- 228
		"title_lone_seal", -- 229
		titleX + 46, -- 230
		topY - 3 * charStep + 8, -- 231
		26, -- 232
		52, -- 233
		"守", -- 234
		"望", -- 235
		PALETTE.sealRed, -- 236
		PALETTE.sealText, -- 237
		0.94, -- 238
		4 -- 239
	) -- 239
	local colRightX = titleX + 132 -- 243
	local colLeftX = titleX + 102 -- 244
	local poemStep = 22 -- 245
	local p = 0 -- 246
	do -- 246
		p = 0 -- 247
		while p < #EPIGRAPH_RIGHT do -- 247
			local ch = EPIGRAPH_RIGHT[p + 1] -- 248
			if ch ~= "" then -- 248
				texts:put( -- 250
					"xs", -- 250
					ch, -- 250
					colRightX, -- 250
					topY - 22 - p * poemStep, -- 250
					toColor(PALETTE.textMid), -- 250
					0.5, -- 250
					0.5, -- 250
					"Center", -- 250
					0, -- 250
					0.86, -- 250
					0.08 -- 250
				) -- 250
			end -- 250
			p = p + 1 -- 247
		end -- 247
	end -- 247
	do -- 247
		p = 0 -- 253
		while p < #EPIGRAPH_LEFT do -- 253
			texts:put( -- 254
				"xs", -- 254
				EPIGRAPH_LEFT[p + 1], -- 254
				colLeftX, -- 254
				topY - 68 - p * poemStep, -- 254
				toColor(PALETTE.amberCore), -- 254
				0.5, -- 254
				0.5, -- 254
				"Center", -- 254
				0, -- 254
				0.9, -- 254
				0.08 -- 254
			) -- 254
			p = p + 1 -- 253
		end -- 253
	end -- 253
	local menuX = 112 -- 258
	local btnW = 280 -- 259
	local btnH = 44 -- 260
	local gap = 12 -- 261
	local startY = 252 -- 262
	local hitIdx = -1 -- 263
	local i = 0 -- 265
	do -- 265
		i = 0 -- 266
		while i < #TITLE_ITEMS do -- 266
			local by = startY - i * (btnH + gap) -- 267
			local hover = pointer.x >= menuX - 10 and pointer.x <= menuX + btnW and pointer.y >= by and pointer.y <= by + btnH -- 268
			if hover then -- 268
				self.selected = i -- 270
				hitIdx = i -- 271
			end -- 271
			local active = self.selected == i -- 273
			local cy = by + btnH * 0.5 -- 274
			local shiftX = active and 10 or 0 -- 275
			if active then -- 275
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 278
				drawSilkRibbon( -- 280
					uiDraw, -- 280
					uiArt, -- 280
					"title_rib_red_" .. tostring(i), -- 280
					menuX + 124, -- 280
					cy, -- 280
					290, -- 280
					40, -- 280
					PALETTE.rougeSoft, -- 280
					0.52 * breathe, -- 280
					0 -- 280
				) -- 280
				drawHairline( -- 281
					uiInkDraw, -- 281
					uiArt, -- 281
					"title_rib_line_" .. tostring(i), -- 281
					menuX + 114, -- 281
					by + 4, -- 281
					230, -- 281
					PALETTE.silkLine, -- 281
					0.42 * breathe, -- 281
					false, -- 281
					2 -- 281
				) -- 281
				drawBlossomDot( -- 282
					uiInkDraw, -- 282
					uiArt, -- 282
					"title_dot_" .. tostring(i), -- 282
					menuX + 14, -- 282
					cy, -- 282
					16, -- 282
					PALETTE.rouge, -- 282
					0.96, -- 282
					4 -- 282
				) -- 282
				fillRadialGlow( -- 283
					uiGlow, -- 283
					menuX + 14, -- 283
					cy, -- 283
					22, -- 283
					16, -- 283
					toColor(PALETTE.rouge, 28 * breathe), -- 283
					Color(182, 58, 56, 0), -- 283
					10 -- 283
				) -- 283
			else -- 283
				drawBlossomDot( -- 285
					uiInkDraw, -- 285
					uiArt, -- 285
					"title_dot_" .. tostring(i), -- 285
					menuX + 14, -- 285
					cy, -- 285
					8, -- 285
					PALETTE.silkDim, -- 285
					0.4, -- 285
					3 -- 285
				) -- 285
			end -- 285
			texts:put( -- 288
				"md", -- 289
				TITLE_ITEMS[i + 1].zh, -- 290
				menuX + 34 + shiftX, -- 291
				cy, -- 292
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 293
				0, -- 294
				0.5, -- 295
				"Left", -- 296
				active and 4.4 or 2.8, -- 297
				active and 1 or 0.88, -- 298
				0.1 -- 299
			) -- 299
			i = i + 1 -- 266
		end -- 266
	end -- 266
	texts:put( -- 303
		"xs", -- 303
		"上下择项   ·   回车或点选启程", -- 303
		menuX + 12, -- 303
		42, -- 303
		toColor(PALETTE.textDim), -- 303
		0, -- 303
		0.5, -- 303
		"Left", -- 303
		1.4, -- 303
		0.88, -- 303
		0.08 -- 303
	) -- 303
	if mk.confirm or clicked and hitIdx >= 0 then -- 303
		local id = TITLE_ITEMS[self.selected + 1].id -- 306
		if id == "start" then -- 306
			return {type = "start"} -- 308
		end -- 308
		if id == "chapters" then -- 308
			return {type = "openChapters"} -- 311
		end -- 311
		return {type = "openControls"} -- 313
	end -- 313
	return {type = "none"} -- 315
end -- 169
function MenuRenderer.prototype.drawChapters(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 322
	if input.pause.pressed or mk.back then -- 322
		return {type = "backTitle"} -- 336
	end -- 336
	if mk.left then -- 336
		self.chapterSelected = (self.chapterSelected + #ROOMS - 1) % #ROOMS -- 339
	elseif mk.right then -- 339
		self.chapterSelected = (self.chapterSelected + 1) % #ROOMS -- 341
	elseif mk.up or mk.down then -- 341
		self.chapterSelected = (self.chapterSelected + 4) % #ROOMS -- 343
	end -- 343
	uiDraw:drawRect( -- 347
		Rect(0, 0, w, h), -- 347
		Color(10, 12, 19, 198) -- 347
	) -- 347
	local marginX = 96 -- 349
	texts:put( -- 351
		"banner", -- 351
		"千里行纪", -- 351
		marginX, -- 351
		h - 66, -- 351
		toColor(PALETTE.textBright), -- 351
		0, -- 351
		0.5, -- 351
		"Left", -- 351
		4.5, -- 351
		0.96, -- 351
		0.1 -- 351
	) -- 351
	texts:put( -- 352
		"xs", -- 352
		"双线八驿 · 择章重历", -- 352
		marginX + 196, -- 352
		h - 70, -- 352
		toColor(PALETTE.textDim), -- 352
		0, -- 352
		0.5, -- 352
		"Left", -- 352
		2, -- 352
		0.85, -- 352
		0.08 -- 352
	) -- 352
	drawHairline( -- 353
		uiInkDraw, -- 353
		uiArt, -- 353
		"chap_top_line", -- 353
		w * 0.5, -- 353
		h - 100, -- 353
		w - marginX * 2, -- 353
		PALETTE.silkDim, -- 353
		0.6, -- 353
		true, -- 353
		2 -- 353
	) -- 353
	local activeRoom = ROOMS[self.chapterSelected + 1] -- 356
	local theme = themeOf(activeRoom.key) -- 357
	local winX = marginX -- 358
	local winY = 266 -- 359
	local winW = 548 -- 360
	local winH = 300 -- 361
	local winHover = pointer.x >= winX and pointer.x <= winX + winW and pointer.y >= winY and pointer.y <= winY + winH -- 362
	uiArt:tryPlace( -- 365
		"ink_frame_mask", -- 365
		"chap_win_shadow", -- 365
		winX + winW * 0.5, -- 365
		winY + winH * 0.5, -- 365
		winW + 40, -- 365
		winH + 34, -- 365
		{ -- 365
			color = toColor(PALETTE.inkVoid), -- 366
			opacity = 0.88, -- 366
			layer = -2 -- 366
		} -- 366
	) -- 366
	local bgSlot = "bgFar_" .. activeRoom.key -- 368
	uiArt:tryPlace( -- 369
		bgSlot, -- 369
		"chap_win_art", -- 369
		winX + winW * 0.5, -- 369
		winY + 4, -- 369
		winW - 8, -- 369
		winH - 8, -- 369
		{opacity = 0.92, layer = -1} -- 369
	) -- 369
	fillVGradRect( -- 373
		uiInkDraw, -- 373
		winX, -- 373
		winY, -- 373
		winW, -- 373
		56, -- 373
		Color(10, 12, 19, 200), -- 373
		Color(10, 12, 19, 0) -- 373
	) -- 373
	fillVGradRect( -- 374
		uiInkDraw, -- 374
		winX, -- 374
		winY + winH - 36, -- 374
		winW, -- 374
		36, -- 374
		Color(10, 12, 19, 0), -- 374
		Color(10, 12, 19, 130) -- 374
	) -- 374
	fillHGradRect( -- 375
		uiInkDraw, -- 375
		winX, -- 375
		winY, -- 375
		34, -- 375
		winH, -- 375
		Color(10, 12, 19, 135), -- 375
		Color(10, 12, 19, 0) -- 375
	) -- 375
	fillHGradRect( -- 376
		uiInkDraw, -- 376
		winX + winW - 34, -- 376
		winY, -- 376
		34, -- 376
		winH, -- 376
		Color(10, 12, 19, 0), -- 376
		Color(10, 12, 19, 135) -- 376
	) -- 376
	drawFiligreeCorners( -- 378
		uiInkDraw, -- 378
		uiArt, -- 378
		"chap_win_frame", -- 378
		winX, -- 378
		winY, -- 378
		winW, -- 378
		winH, -- 378
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 378
		winHover and 0.92 or 0.72, -- 378
		34, -- 378
		true, -- 378
		3 -- 378
	) -- 378
	texts:put( -- 381
		"xs", -- 381
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 381
		winX + 20, -- 381
		winY + 22, -- 381
		toColor(PALETTE.textMid), -- 381
		0, -- 381
		0.5, -- 381
		"Left", -- 381
		1.8, -- 381
		0.9, -- 381
		0.08 -- 381
	) -- 381
	local infoX = winX + winW + 46 -- 384
	local infoCenterY = winY + winH * 0.5 -- 385
	drawMistCurve( -- 386
		uiArt, -- 386
		"chap_info_mist", -- 386
		infoX + 210, -- 386
		infoCenterY + 36, -- 386
		420, -- 386
		88, -- 386
		theme.accent, -- 386
		0.22, -- 386
		-1 -- 386
	) -- 386
	local volCol = self.chapterSelected < 4 and PALETTE.cyan or PALETTE.amber -- 389
	texts:put( -- 390
		"xs", -- 390
		theme.volumeTagZh, -- 390
		infoX, -- 390
		winY + winH - 44, -- 390
		toColor(volCol), -- 390
		0, -- 390
		0.5, -- 390
		"Left", -- 390
		2.8, -- 390
		0.92, -- 390
		0.08 -- 390
	) -- 390
	local sep = " · " -- 393
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 394
	local titleY = winY + winH - 98 -- 395
	if sIdx > 0 then -- 395
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 397
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 398
		local lw = visualTextWidth(leftPart, 40) -- 399
		texts:put( -- 400
			"banner", -- 400
			leftPart, -- 400
			infoX, -- 400
			titleY, -- 400
			toColor(PALETTE.textBright), -- 400
			0, -- 400
			0.5, -- 400
			"Left", -- 400
			2, -- 400
			1, -- 400
			0.1 -- 400
		) -- 400
		drawBlossomDot( -- 401
			uiInkDraw, -- 401
			uiArt, -- 401
			"chap_title_dot", -- 401
			infoX + lw + 16, -- 401
			titleY - 2, -- 401
			11, -- 401
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 401
			0.9, -- 401
			4 -- 401
		) -- 401
		texts:put( -- 402
			"banner", -- 402
			rightPart, -- 402
			infoX + lw + 32, -- 402
			titleY, -- 402
			toColor(PALETTE.textBright), -- 402
			0, -- 402
			0.5, -- 402
			"Left", -- 402
			2, -- 402
			1, -- 402
			0.1 -- 402
		) -- 402
	else -- 402
		texts:put( -- 404
			"banner", -- 404
			theme.titleZh, -- 404
			infoX, -- 404
			titleY, -- 404
			toColor(PALETTE.textBright), -- 404
			0, -- 404
			0.5, -- 404
			"Left", -- 404
			2.4, -- 404
			1, -- 404
			0.1 -- 404
		) -- 404
	end -- 404
	drawHairline( -- 407
		uiInkDraw, -- 407
		uiArt, -- 407
		"chap_info_line", -- 407
		infoX + 185, -- 407
		titleY - 36, -- 407
		370, -- 407
		PALETTE.silkDim, -- 407
		0.58, -- 407
		false, -- 407
		2 -- 407
	) -- 407
	texts:put( -- 410
		"sm", -- 410
		theme.introWhisper, -- 410
		infoX, -- 410
		titleY - 72, -- 410
		toColor(PALETTE.textMid), -- 410
		0, -- 410
		0.5, -- 410
		"Left", -- 410
		0.8, -- 410
		0.94, -- 410
		0.08 -- 410
	) -- 410
	local goX = infoX -- 413
	local goY = winY + 26 -- 414
	local goW = 220 -- 415
	local goH = 42 -- 416
	local goHover = pointer.x >= goX and pointer.x <= goX + goW and pointer.y >= goY and pointer.y <= goY + goH -- 417
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 418
	drawSilkRibbon( -- 419
		uiDraw, -- 419
		uiArt, -- 419
		"chap_go_rib", -- 419
		goX + 106, -- 419
		goY + 21, -- 419
		250, -- 419
		40, -- 419
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 419
		(goHover and 0.68 or 0.46) * breathe, -- 419
		0 -- 419
	) -- 419
	drawHairline( -- 420
		uiInkDraw, -- 420
		uiArt, -- 420
		"chap_go_line", -- 420
		goX + 94, -- 420
		goY + 3, -- 420
		196, -- 420
		PALETTE.silkLine, -- 420
		goHover and 0.68 or 0.4, -- 420
		false, -- 420
		2 -- 420
	) -- 420
	drawBlossomDot( -- 421
		uiInkDraw, -- 421
		uiArt, -- 421
		"chap_go_dot", -- 421
		goX + 14, -- 421
		goY + 21, -- 421
		14, -- 421
		PALETTE.rouge, -- 421
		0.96, -- 421
		4 -- 421
	) -- 421
	texts:put( -- 422
		"md", -- 422
		"入此卷章", -- 422
		goX + 34, -- 422
		goY + 21, -- 422
		toColor(PALETTE.textBright), -- 422
		0, -- 422
		0.5, -- 422
		"Left", -- 422
		3.8, -- 422
		1, -- 422
		0.1 -- 422
	) -- 422
	texts:put( -- 423
		"xs", -- 423
		"Enter", -- 423
		goX + 156, -- 423
		goY + 21, -- 423
		toColor(PALETTE.textDim), -- 423
		0, -- 423
		0.5, -- 423
		"Left", -- 423
		1, -- 423
		0.82, -- 423
		0.08 -- 423
	) -- 423
	local trackY = 148 -- 426
	local trackX0 = marginX + 34 -- 427
	local trackX1 = w - marginX - 34 -- 428
	local stepX = (trackX1 - trackX0) / (#ROOMS - 1) -- 429
	drawSilkVeil( -- 432
		uiDraw, -- 432
		uiArt, -- 432
		"chap_track_veil", -- 432
		w * 0.5, -- 432
		trackY + 6, -- 432
		w - marginX * 1.1, -- 432
		126, -- 432
		PALETTE.inkWash, -- 432
		0.72, -- 432
		-2 -- 432
	) -- 432
	drawMistCurve( -- 433
		uiArt, -- 433
		"chap_track_mist", -- 433
		w * 0.5, -- 433
		trackY, -- 433
		trackX1 - trackX0 + 160, -- 433
		74, -- 433
		PALETTE.inkMist, -- 433
		0.62, -- 433
		-1 -- 433
	) -- 433
	uiInkDraw:drawSegment( -- 434
		Vec2(trackX0, trackY), -- 434
		Vec2(trackX1, trackY), -- 434
		0.9, -- 434
		toColor(PALETTE.silkDim, 145) -- 434
	) -- 434
	local midDivX = trackX0 + stepX * 3.5 -- 437
	uiInkDraw:drawSegment( -- 438
		Vec2(midDivX, trackY - 12), -- 438
		Vec2(midDivX, trackY + 12), -- 438
		0.8, -- 438
		toColor(PALETTE.silkDim, 120) -- 438
	) -- 438
	texts:put( -- 439
		"xs", -- 439
		"上卷 · 孤城护童", -- 439
		trackX0 + stepX * 1.5, -- 439
		trackY + 52, -- 439
		toColor(PALETTE.cyan), -- 439
		0.5, -- 439
		0.5, -- 439
		"Center", -- 439
		2.2, -- 439
		0.88, -- 439
		0.08 -- 439
	) -- 439
	texts:put( -- 440
		"xs", -- 440
		"下卷 · 独赴北塔", -- 440
		trackX0 + stepX * 5.5, -- 440
		trackY + 52, -- 440
		toColor(PALETTE.amber), -- 440
		0.5, -- 440
		0.5, -- 440
		"Center", -- 440
		2.2, -- 440
		0.88, -- 440
		0.08 -- 440
	) -- 440
	local hitStation = -1 -- 442
	local i = 0 -- 443
	do -- 443
		i = 0 -- 444
		while i < #ROOMS do -- 444
			local sx = trackX0 + i * stepX -- 445
			local rt = themeOf(ROOMS[i + 1].key) -- 446
			local hover = math.abs(pointer.x - sx) <= stepX * 0.45 and math.abs(pointer.y - trackY) <= 46 -- 447
			if hover then -- 447
				self.chapterSelected = i -- 449
				hitStation = i -- 450
			end -- 450
			local active = self.chapterSelected == i -- 452
			local nodeCol = active and PALETTE.rouge or (i < 4 and PALETTE.cyan or PALETTE.amber) -- 453
			if active then -- 453
				fillRadialGlow( -- 456
					uiGlow, -- 456
					sx, -- 456
					trackY, -- 456
					26, -- 456
					26, -- 456
					toColor(PALETTE.rouge, 36 * breathe), -- 456
					Color(182, 58, 56, 0), -- 456
					12 -- 456
				) -- 456
				uiArt:tryPlace( -- 457
					"ink_enso_fine", -- 457
					"chap_st_ring_" .. tostring(i), -- 457
					sx, -- 457
					trackY, -- 457
					32, -- 457
					32, -- 457
					{ -- 457
						color = toColor(PALETTE.silkLine), -- 458
						opacity = 0.78, -- 458
						angle = self.time * 18, -- 458
						layer = 3 -- 458
					} -- 458
				) -- 458
				drawBlossomDot( -- 460
					uiInkDraw, -- 460
					uiArt, -- 460
					"chap_st_dot_" .. tostring(i), -- 460
					sx, -- 460
					trackY, -- 460
					17, -- 460
					PALETTE.rouge, -- 460
					0.98, -- 460
					4 -- 460
				) -- 460
			else -- 460
				uiArt:tryPlace( -- 462
					"ink_enso_fine", -- 462
					"chap_st_ring_" .. tostring(i), -- 462
					sx, -- 462
					trackY, -- 462
					16, -- 462
					16, -- 462
					{ -- 462
						color = toColor(nodeCol), -- 463
						opacity = 0.62, -- 463
						layer = 3 -- 463
					} -- 463
				) -- 463
				drawBlossomDot( -- 465
					uiInkDraw, -- 465
					uiArt, -- 465
					"chap_st_dot_" .. tostring(i), -- 465
					sx, -- 465
					trackY, -- 465
					7, -- 465
					PALETTE.silkLine, -- 465
					0.72, -- 465
					4 -- 465
				) -- 465
			end -- 465
			texts:put( -- 468
				"xs", -- 468
				rt.numeralZh, -- 468
				sx, -- 468
				trackY + 25, -- 468
				toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 468
				0.5, -- 468
				0.5, -- 468
				"Center", -- 468
				0, -- 468
				active and 1 or 0.88, -- 468
				0.08 -- 468
			) -- 468
			texts:put( -- 469
				"xs", -- 469
				rt.shortNameZh, -- 469
				sx, -- 469
				trackY - 26, -- 469
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 469
				0.5, -- 469
				0.5, -- 469
				"Center", -- 469
				1, -- 469
				active and 1 or 0.84, -- 469
				0.08 -- 469
			) -- 469
			i = i + 1 -- 444
		end -- 444
	end -- 444
	local backX = marginX -- 473
	local backY = 40 -- 474
	local backHover = pointer.x >= backX and pointer.x <= backX + 168 and pointer.y >= backY and pointer.y <= backY + 34 -- 475
	drawSilkKeycap( -- 476
		uiInkDraw, -- 476
		texts, -- 476
		backX, -- 476
		backY + 5, -- 476
		44, -- 476
		24, -- 476
		"ESC", -- 476
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 476
		0.92, -- 476
		backHover -- 476
	) -- 476
	texts:put( -- 477
		"sm", -- 477
		"返回标题", -- 477
		backX + 56, -- 477
		backY + 17, -- 477
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 477
		0, -- 477
		0.5, -- 477
		"Left", -- 477
		1.8, -- 477
		0.9, -- 477
		0.08 -- 477
	) -- 477
	texts:put( -- 478
		"xs", -- 478
		"← / → 沿驿道阅览   ·   Enter 或点选入章", -- 478
		w - marginX, -- 478
		backY + 17, -- 478
		toColor(PALETTE.textDim), -- 478
		1, -- 478
		0.5, -- 478
		"Right", -- 478
		1.2, -- 478
		0.75, -- 478
		0.08 -- 478
	) -- 478
	if clicked and backHover then -- 478
		return {type = "backTitle"} -- 481
	end -- 481
	if mk.confirm or clicked and (hitStation >= 0 or winHover or goHover) then -- 481
		return {type = "jump", roomIndex = self.chapterSelected} -- 484
	end -- 484
	return {type = "none"} -- 486
end -- 322
function MenuRenderer.prototype.drawControls(self, mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h) -- 492
	if input.pause.pressed or mk.back or mk.confirm then -- 492
		return {type = "backTitle"} -- 506
	end -- 506
	uiDraw:drawRect( -- 508
		Rect(0, 0, w, h), -- 508
		Color(10, 12, 19, 204) -- 508
	) -- 508
	local marginX = 96 -- 510
	texts:put( -- 511
		"banner", -- 511
		"执器要诀", -- 511
		marginX, -- 511
		h - 66, -- 511
		toColor(PALETTE.textBright), -- 511
		0, -- 511
		0.5, -- 511
		"Left", -- 511
		4.5, -- 511
		0.96, -- 511
		0.1 -- 511
	) -- 511
	texts:put( -- 512
		"xs", -- 512
		"键鼠操作说明", -- 512
		marginX + 196, -- 512
		h - 70, -- 512
		toColor(PALETTE.textDim), -- 512
		0, -- 512
		0.5, -- 512
		"Left", -- 512
		2, -- 512
		0.85, -- 512
		0.08 -- 512
	) -- 512
	drawHairline( -- 513
		uiInkDraw, -- 513
		uiArt, -- 513
		"ctrl_top_line", -- 513
		w * 0.5, -- 513
		h - 100, -- 513
		w - marginX * 2, -- 513
		PALETTE.silkDim, -- 513
		0.6, -- 513
		true, -- 513
		2 -- 513
	) -- 513
	local areaY = 114 -- 516
	local areaH = h - 244 -- 517
	drawFiligreeCorners( -- 518
		uiInkDraw, -- 518
		uiArt, -- 518
		"ctrl_outer", -- 518
		marginX, -- 518
		areaY, -- 518
		w - marginX * 2, -- 518
		areaH, -- 518
		PALETTE.silkDim, -- 518
		0.52, -- 518
		34, -- 518
		false, -- 518
		2 -- 518
	) -- 518
	local midX = w * 0.5 -- 521
	uiArt:tryPlace( -- 522
		"ink_vstream", -- 522
		"ctrl_mid_stream", -- 522
		midX, -- 522
		areaY + areaH * 0.5, -- 522
		32, -- 522
		areaH - 18, -- 522
		{ -- 522
			color = toColor(PALETTE.silkDim), -- 523
			opacity = 0.52, -- 523
			layer = 1 -- 523
		} -- 523
	) -- 523
	drawBlossomDot( -- 525
		uiInkDraw, -- 525
		uiArt, -- 525
		"ctrl_mid_dot", -- 525
		midX, -- 525
		areaY + areaH * 0.5, -- 525
		11, -- 525
		PALETTE.silkLine, -- 525
		0.62, -- 525
		3 -- 525
	) -- 525
	local leftColX = marginX + 34 -- 528
	local colW = midX - leftColX - 42 -- 529
	local headY = areaY + areaH - 34 -- 530
	drawBlossomDot( -- 531
		uiInkDraw, -- 531
		uiArt, -- 531
		"ctrl_l_dot", -- 531
		leftColX + 8, -- 531
		headY, -- 531
		12, -- 531
		PALETTE.cyan, -- 531
		0.88, -- 531
		3 -- 531
	) -- 531
	texts:put( -- 532
		"md", -- 532
		"周戍 · 护送与交锋", -- 532
		leftColX + 26, -- 532
		headY, -- 532
		toColor(PALETTE.cyanCore), -- 532
		0, -- 532
		0.5, -- 532
		"Left", -- 532
		2.4, -- 532
		0.98, -- 532
		0.08 -- 532
	) -- 532
	drawHairline( -- 533
		uiInkDraw, -- 533
		uiArt, -- 533
		"ctrl_l_line", -- 533
		leftColX + colW * 0.5, -- 533
		headY - 24, -- 533
		colW, -- 533
		PALETTE.cyanDim, -- 533
		0.58, -- 533
		false, -- 533
		2 -- 533
	) -- 533
	local sRows = { -- 535
		{"A / D", "左右移动"}, -- 536
		{"鼠标 + 左键", "瞄准与点射"}, -- 537
		{"SHIFT 按住", "贴靠柜台 / 街垒挡枪"}, -- 538
		{"SPACE", "平地翻滚 / 贴矮台翻越"}, -- 539
		{"E", "递物 / 敲两下安抚 / 按住+D 推车"}, -- 540
		{"ESC / R", "暂歇 / 从检查点重试"} -- 541
	} -- 541
	local i = 0 -- 543
	do -- 543
		i = 0 -- 544
		while i < #sRows do -- 544
			local ry = headY - 66 - i * 52 -- 545
			drawSilkKeycap( -- 546
				uiInkDraw, -- 546
				texts, -- 546
				leftColX + 2, -- 546
				ry - 13, -- 546
				122, -- 546
				26, -- 546
				sRows[i + 1][1], -- 546
				PALETTE.cyan, -- 546
				0.92, -- 546
				false -- 546
			) -- 546
			texts:put( -- 547
				"sm", -- 547
				sRows[i + 1][2], -- 547
				leftColX + 144, -- 547
				ry, -- 547
				toColor(PALETTE.textBright), -- 547
				0, -- 547
				0.5, -- 547
				"Left", -- 547
				0.8, -- 547
				0.92, -- 547
				0.08 -- 547
			) -- 547
			i = i + 1 -- 544
		end -- 544
	end -- 544
	local rightColX = midX + 44 -- 551
	drawBlossomDot( -- 552
		uiInkDraw, -- 552
		uiArt, -- 552
		"ctrl_r_dot", -- 552
		rightColX + 8, -- 552
		headY, -- 552
		12, -- 552
		PALETTE.amber, -- 552
		0.88, -- 552
		3 -- 552
	) -- 552
	texts:put( -- 553
		"md", -- 553
		"小满 · 潜行与寻路", -- 553
		rightColX + 26, -- 553
		headY, -- 553
		toColor(PALETTE.amberCore), -- 553
		0, -- 553
		0.5, -- 553
		"Left", -- 553
		2.4, -- 553
		0.98, -- 553
		0.08 -- 553
	) -- 553
	drawHairline( -- 554
		uiInkDraw, -- 554
		uiArt, -- 554
		"ctrl_r_line", -- 554
		rightColX + colW * 0.5, -- 554
		headY - 24, -- 554
		colW, -- 554
		PALETTE.amberDim, -- 554
		0.58, -- 554
		false, -- 554
		2 -- 554
	) -- 554
	local cRows = { -- 556
		{"A / D", "潜行行走"}, -- 557
		{"SHIFT 按住", "轻步慢走（压低脚步声）"}, -- 558
		{"S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 559
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 560
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉板车"}, -- 561
		{"F 按住→松手", "预览落点，投瓶引开拾荒者"} -- 562
	} -- 562
	do -- 562
		i = 0 -- 564
		while i < #cRows do -- 564
			local ry = headY - 66 - i * 52 -- 565
			drawSilkKeycap( -- 566
				uiInkDraw, -- 566
				texts, -- 566
				rightColX + 2, -- 566
				ry - 13, -- 566
				126, -- 566
				26, -- 566
				cRows[i + 1][1], -- 566
				PALETTE.amber, -- 566
				0.92, -- 566
				false -- 566
			) -- 566
			texts:put( -- 567
				"sm", -- 567
				cRows[i + 1][2], -- 567
				rightColX + 148, -- 567
				ry, -- 567
				toColor(PALETTE.textBright), -- 567
				0, -- 567
				0.5, -- 567
				"Left", -- 567
				0.8, -- 567
				0.92, -- 567
				0.08 -- 567
			) -- 567
			i = i + 1 -- 564
		end -- 564
	end -- 564
	local backX = marginX -- 571
	local backY = 40 -- 572
	local backHover = pointer.x >= backX and pointer.x <= backX + 230 and pointer.y >= backY and pointer.y <= backY + 34 -- 573
	drawSilkKeycap( -- 574
		uiInkDraw, -- 574
		texts, -- 574
		backX, -- 574
		backY + 5, -- 574
		110, -- 574
		24, -- 574
		"ESC / ENTER", -- 574
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 574
		0.92, -- 574
		backHover -- 574
	) -- 574
	texts:put( -- 575
		"sm", -- 575
		"返回标题", -- 575
		backX + 122, -- 575
		backY + 17, -- 575
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 575
		0, -- 575
		0.5, -- 575
		"Left", -- 575
		1.8, -- 575
		0.92, -- 575
		0.08 -- 575
	) -- 575
	if clicked and backHover then -- 575
		return {type = "backTitle"} -- 578
	end -- 578
	return {type = "none"} -- 580
end -- 492
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale) -- 586
	self.time = self.time + dt -- 598
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 599
	local mk = self:readMenuKeys() -- 600
	local clicked = self:clickEdge(input) -- 601
	if mk.up then -- 601
		self.pauseSelected = (self.pauseSelected + #PAUSE_ITEMS - 1) % #PAUSE_ITEMS -- 604
	elseif mk.down then -- 604
		self.pauseSelected = (self.pauseSelected + 1) % #PAUSE_ITEMS -- 606
	end -- 606
	uiDraw:drawRect( -- 610
		Rect(0, 0, w, h), -- 610
		Color(8, 10, 16, 102) -- 610
	) -- 610
	fillHGradRect( -- 611
		uiDraw, -- 611
		0, -- 611
		0, -- 611
		w * 0.27, -- 611
		h, -- 611
		Color(9, 11, 18, 232), -- 611
		Color(10, 13, 21, 198) -- 611
	) -- 611
	fillHGradRect( -- 612
		uiDraw, -- 612
		w * 0.27, -- 612
		0, -- 612
		w * 0.21, -- 612
		h, -- 612
		Color(10, 13, 21, 198), -- 612
		Color(10, 13, 21, 0) -- 612
	) -- 612
	local menuX = 110 -- 615
	uiArt:tryPlace( -- 616
		"ink_vstream", -- 616
		"pause_vstream", -- 616
		menuX - 32, -- 616
		h * 0.5, -- 616
		34, -- 616
		h * 0.78, -- 616
		{ -- 616
			color = toColor(PALETTE.silkDim), -- 617
			opacity = 0.48, -- 617
			layer = 1 -- 617
		} -- 617
	) -- 617
	drawMistCurve( -- 619
		uiArt, -- 619
		"pause_mist", -- 619
		menuX + 118, -- 619
		h - 154, -- 619
		290, -- 619
		72, -- 619
		PALETTE.jadeMist, -- 619
		0.2, -- 619
		-1 -- 619
	) -- 619
	texts:put( -- 622
		"banner", -- 622
		"暂歇", -- 622
		menuX + 16, -- 622
		h - 146, -- 622
		toColor(PALETTE.textBright), -- 622
		0, -- 622
		0.5, -- 622
		"Left", -- 622
		10, -- 622
		0.98, -- 622
		0.1 -- 622
	) -- 622
	texts:put( -- 623
		"xs", -- 623
		"月夜暂驻 · 卷页留痕", -- 623
		menuX + 18, -- 623
		h - 184, -- 623
		toColor(PALETTE.textDim), -- 623
		0, -- 623
		0.5, -- 623
		"Left", -- 623
		2, -- 623
		0.8, -- 623
		0.08 -- 623
	) -- 623
	drawHairline( -- 624
		uiInkDraw, -- 624
		uiArt, -- 624
		"pause_div", -- 624
		menuX + 124, -- 624
		h - 210, -- 624
		240, -- 624
		PALETTE.silkDim, -- 624
		0.58, -- 624
		true, -- 624
		2 -- 624
	) -- 624
	local hitIdx = -1 -- 626
	local i = 0 -- 627
	do -- 627
		i = 0 -- 628
		while i < #PAUSE_ITEMS do -- 628
			local iy = h - 284 - i * 60 -- 629
			local iw = 260 -- 630
			local ih = 44 -- 631
			local hover = pointer.x >= menuX - 10 and pointer.x <= menuX + iw and pointer.y >= iy and pointer.y <= iy + ih -- 632
			if hover then -- 632
				self.pauseSelected = i -- 634
				hitIdx = i -- 635
			end -- 635
			local active = self.pauseSelected == i -- 637
			local cy = iy + ih * 0.5 -- 638
			local shiftX = active and 10 or 0 -- 639
			if active then -- 639
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 642
				drawSilkRibbon( -- 643
					uiDraw, -- 643
					uiArt, -- 643
					"pause_rib_" .. tostring(i), -- 643
					menuX + 116, -- 643
					cy, -- 643
					276, -- 643
					40, -- 643
					PALETTE.rougeSoft, -- 643
					0.54 * breathe, -- 643
					0 -- 643
				) -- 643
				drawHairline( -- 644
					uiInkDraw, -- 644
					uiArt, -- 644
					"pause_line_" .. tostring(i), -- 644
					menuX + 106, -- 644
					iy + 4, -- 644
					210, -- 644
					PALETTE.silkLine, -- 644
					0.42 * breathe, -- 644
					false, -- 644
					2 -- 644
				) -- 644
				drawBlossomDot( -- 645
					uiInkDraw, -- 645
					uiArt, -- 645
					"pause_dot_" .. tostring(i), -- 645
					menuX + 12, -- 645
					cy, -- 645
					15, -- 645
					PALETTE.rouge, -- 645
					0.96, -- 645
					4 -- 645
				) -- 645
				fillRadialGlow( -- 646
					uiGlow, -- 646
					menuX + 12, -- 646
					cy, -- 646
					22, -- 646
					16, -- 646
					toColor(PALETTE.rouge, 26 * breathe), -- 646
					Color(182, 58, 56, 0), -- 646
					10 -- 646
				) -- 646
			else -- 646
				drawBlossomDot( -- 648
					uiInkDraw, -- 648
					uiArt, -- 648
					"pause_dot_" .. tostring(i), -- 648
					menuX + 12, -- 648
					cy, -- 648
					8, -- 648
					PALETTE.silkDim, -- 648
					0.4, -- 648
					3 -- 648
				) -- 648
			end -- 648
			texts:put( -- 651
				"md", -- 652
				PAUSE_ITEMS[i + 1].zh, -- 653
				menuX + 32 + shiftX, -- 654
				cy, -- 655
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 656
				0, -- 657
				0.5, -- 658
				"Left", -- 659
				active and 3.8 or 2.4, -- 660
				active and 1 or 0.88, -- 661
				0.1 -- 662
			) -- 662
			i = i + 1 -- 628
		end -- 628
	end -- 628
	texts:put( -- 666
		"xs", -- 666
		"Esc 续行   ·   Enter 或点击确认", -- 666
		menuX + 12, -- 666
		56, -- 666
		toColor(PALETTE.textDim), -- 666
		0, -- 666
		0.5, -- 666
		"Left", -- 666
		1.2, -- 666
		0.86, -- 666
		0.08 -- 666
	) -- 666
	if mk.confirm or clicked and hitIdx >= 0 then -- 666
		local id = PAUSE_ITEMS[self.pauseSelected + 1].id -- 669
		if id == "resume" then -- 669
			return {type = "resume"} -- 671
		end -- 671
		if id == "retry" then -- 671
			return {type = "retry"} -- 674
		end -- 674
		if id == "chapters" then -- 674
			return {type = "openChapters"} -- 677
		end -- 677
		return {type = "toTitle"} -- 679
	end -- 679
	return {type = "none"} -- 681
end -- 586
return ____exports -- 586