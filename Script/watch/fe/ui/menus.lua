-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Keyboard = ____Dora.Keyboard -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____rooms = require("Script.watch.rooms") -- 4
local ROOMS = ____rooms.ROOMS -- 4
local ____theme = require("Script.watch.fe.theme") -- 9
local PALETTE = ____theme.PALETTE -- 9
local toColor = ____theme.toColor -- 9
local TITLE_ITEMS = {{label = "开始游戏", action = {type = "start"}}, {label = "选择章节", action = {type = "openChapters"}}, {label = "操作说明", action = {type = "openControls"}}} -- 23
local PAUSE_ITEMS = {{label = "继续游戏", action = {type = "resume"}}, {label = "重试检查点", action = {type = "retry"}}, {label = "选择章节", action = {type = "openChapters"}}, {label = "返回标题", action = {type = "toTitle"}}} -- 29
local CHAPTER_TITLES = { -- 36
	prologue = "序章", -- 37
	street = "街道", -- 38
	checkpoint = "检查站", -- 39
	gate = "城门", -- 40
	outside = "城墙外", -- 41
	village = "废弃村庄", -- 42
	forest = "北塔森林", -- 43
	tower = "北塔" -- 44
} -- 44
local SOLDIER_CONTROLS = {{"鼠标 / 左键", "瞄准 / 开枪"}, {"按住 Shift", "贴住掩体挡枪"}, {"空格", "翻滚 / 靠近矮柜时翻越"}, {"按住 E + D", "握住车把，推车向前"}} -- 47
local CHILD_CONTROLS = { -- 54
	{"空格", "跳跃"}, -- 55
	{"按住 Shift", "轻步慢走"}, -- 56
	{"按住 S 或 Ctrl", "蹲下"}, -- 57
	{"F", "按住瞄准，松开投瓶"}, -- 58
	{"按住 E + D", "握住车把，拉车向前"} -- 59
} -- 59
local function pressedKeys() -- 78
	return { -- 79
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 80
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 81
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 82
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 83
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 84
	} -- 84
end -- 78
local function hitIndex(boxes, pointer) -- 88
	return __TS__ArrayFindIndex( -- 89
		boxes, -- 89
		function(____, box) return box:containsPoint(pointer) end -- 89
	) -- 89
end -- 88
local function verticalBoxes(x, firstY, width, count) -- 92
	local boxes = {} -- 93
	do -- 93
		local i = 0 -- 94
		while i < count do -- 94
			boxes[#boxes + 1] = Rect(x, firstY - i * 58, width, 48) -- 95
			i = i + 1 -- 94
		end -- 94
	end -- 94
	return boxes -- 97
end -- 92
local function drawButton(draw, texts, box, label, active) -- 100
	local border = active and PALETTE.amber or PALETTE.steelLight -- 101
	draw:drawRect( -- 102
		box, -- 102
		toColor(active and PALETTE.steelMid or PALETTE.panelBgDeep, 245), -- 102
		active and 2 or 1, -- 103
		toColor(border, active and 255 or 170) -- 103
	) -- 103
	texts:put( -- 104
		"md", -- 104
		label, -- 104
		box.x + 19, -- 104
		box.centerY, -- 104
		toColor(PALETTE.textBright) -- 104
	) -- 104
end -- 100
____exports.MenuRenderer = __TS__Class() -- 107
local MenuRenderer = ____exports.MenuRenderer -- 107
MenuRenderer.name = "MenuRenderer" -- 107
function MenuRenderer.prototype.____constructor(self) -- 107
	self.selected = 0 -- 108
	self.chapterSelected = 0 -- 109
	self.pauseSelected = 0 -- 110
	self.chaptersFromPause = false -- 111
	self.previousKeys = {} -- 112
	self.queuedKeys = {} -- 113
	self.queuedBack = false -- 114
	self.time = 0 -- 115
end -- 107
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 117
	self.chaptersFromPause = roomIndex ~= nil -- 118
	self.chapterSelected = roomIndex or 0 -- 119
	self:resetInput() -- 120
end -- 117
function MenuRenderer.prototype.openPause(self) -- 123
	self.pauseSelected = 0 -- 124
	self:resetInput() -- 125
end -- 123
function MenuRenderer.prototype.resetInput(self) -- 129
	self.previousKeys = pressedKeys() -- 130
	self.queuedKeys = {} -- 131
	self.queuedBack = false -- 132
end -- 129
function MenuRenderer.prototype.onKeyEvent(self, key) -- 136
	if key == "Up" or key == "W" then -- 136
		self.queuedKeys.up = true -- 138
	elseif key == "Down" or key == "S" then -- 138
		self.queuedKeys.down = true -- 140
	elseif key == "Left" or key == "A" then -- 140
		self.queuedKeys.left = true -- 142
	elseif key == "Right" or key == "D" then -- 142
		self.queuedKeys.right = true -- 144
	elseif key == "Return" or key == "Space" then -- 144
		self.queuedKeys.confirm = true -- 146
	elseif key == "Escape" then -- 146
		self.queuedBack = true -- 148
	end -- 148
end -- 136
function MenuRenderer.prototype.readFrame(self, input, scale) -- 152
	local held = pressedKeys() -- 153
	local prev = self.previousKeys -- 154
	local queued = self.queuedKeys -- 155
	local frame = { -- 156
		keys = { -- 157
			up = queued.up == true or held.up and not prev.up, -- 158
			down = queued.down == true or held.down and not prev.down, -- 159
			left = queued.left == true or held.left and not prev.left, -- 160
			right = queued.right == true or held.right and not prev.right, -- 161
			confirm = queued.confirm == true or held.confirm and not prev.confirm -- 162
		}, -- 162
		back = self.queuedBack or input.pause.pressed, -- 164
		pointer = Vec2(input.mx / scale, input.my / scale), -- 165
		click = input.inside and input.fire.pressed, -- 166
		pointerMoved = input.inside and math.abs(input.mdx) + math.abs(input.mdy) >= scale -- 167
	} -- 167
	self.previousKeys = held -- 169
	self.queuedKeys = {} -- 170
	self.queuedBack = false -- 171
	return frame -- 172
end -- 152
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 175
	local hit = hitIndex(boxes, frame.pointer) -- 176
	if frame.click and hit >= 0 then -- 176
		return hit -- 178
	end -- 178
	if frame.keys.up then -- 178
		return (selected + #boxes - 1) % #boxes -- 181
	end -- 181
	if frame.keys.down then -- 181
		return (selected + 1) % #boxes -- 184
	end -- 184
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 186
end -- 175
function MenuRenderer.prototype.drawActions(self, draw, texts, items, boxes, selected, frame) -- 189
	do -- 189
		local i = 0 -- 193
		while i < #items do -- 193
			drawButton( -- 194
				draw, -- 194
				texts, -- 194
				boxes[i + 1], -- 194
				items[i + 1].label, -- 194
				i == selected -- 194
			) -- 194
			i = i + 1 -- 193
		end -- 193
	end -- 193
	local hit = frame.click and hitIndex(boxes, frame.pointer) or -1 -- 196
	return hit >= 0 and items[hit + 1].action or (frame.keys.confirm and items[selected + 1].action or ({type = "none"})) -- 197
end -- 189
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiDraw, texts, w, h, uiScale) -- 200
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
	local title = screen == "title" -- 215
	uiDraw:drawRect( -- 216
		Rect(0, 0, w, h), -- 216
		Color(15, 14, 20, title and 32 or 158) -- 216
	) -- 216
	local left = math.min(110, w * 0.085) -- 217
	if title then -- 217
		local heading = h * 0.74 -- 220
		texts:put( -- 221
			"xl", -- 221
			"向西守望", -- 221
			left, -- 221
			heading, -- 221
			toColor(PALETTE.textBright) -- 221
		) -- 221
		texts:put( -- 222
			"sm", -- 222
			"城破后，护送小满出城。", -- 222
			left, -- 222
			heading - 56, -- 222
			toColor(PALETTE.textMid) -- 222
		) -- 222
		local boxes = verticalBoxes(left, h * 0.43, 300, #TITLE_ITEMS) -- 223
		self.selected = self:verticalSelection(self.selected, boxes, frame) -- 224
		texts:put( -- 225
			"sm", -- 225
			"↑ ↓ 选择　Enter 确认", -- 225
			left, -- 225
			boxes[3].y - 34, -- 225
			toColor(PALETTE.textMid) -- 225
		) -- 225
		return self:drawActions( -- 226
			uiDraw, -- 226
			texts, -- 226
			TITLE_ITEMS, -- 226
			boxes, -- 226
			self.selected, -- 226
			frame -- 226
		) -- 226
	end -- 226
	if screen == "chapters" then -- 226
		return self:drawChapters( -- 229
			frame, -- 229
			uiDraw, -- 229
			texts, -- 229
			left, -- 229
			w, -- 229
			h -- 229
		) -- 229
	end -- 229
	return self:drawControls( -- 231
		frame, -- 231
		uiDraw, -- 231
		texts, -- 231
		left, -- 231
		w, -- 231
		h -- 231
	) -- 231
end -- 200
function MenuRenderer.prototype.drawChapters(self, frame, draw, texts, left, w, h) -- 234
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 237
	if frame.back then -- 237
		return back -- 239
	end -- 239
	local cols = 4 -- 241
	local width = math.min(248, (w - left * 2 - 3 * 16) / cols) -- 242
	local boxes = __TS__ArrayMap( -- 243
		ROOMS, -- 243
		function(____, _, i) -- 243
			local y = i < cols and h * 0.53 or h * 0.3 -- 244
			return Rect(left + i % cols * (width + 16), y, width, 58) -- 245
		end -- 243
	) -- 243
	local hit = hitIndex(boxes, frame.pointer) -- 247
	local keys = frame.keys -- 248
	if frame.click and hit >= 0 then -- 248
		self.chapterSelected = hit -- 250
	elseif keys.left or keys.right or keys.up or keys.down then -- 250
		local step = keys.left and -1 or (keys.right and 1 or cols) -- 252
		self.chapterSelected = (self.chapterSelected + step + #ROOMS) % #ROOMS -- 253
	elseif frame.pointerMoved and hit >= 0 and not keys.confirm then -- 253
		self.chapterSelected = hit -- 255
	end -- 255
	texts:put( -- 258
		"lg", -- 258
		"选择章节", -- 258
		left, -- 258
		h - 100, -- 258
		toColor(PALETTE.textBright) -- 258
	) -- 258
	texts:put( -- 259
		"sm", -- 259
		"周戍 · 护送", -- 259
		left, -- 259
		boxes[1].top + 27, -- 259
		toColor(PALETTE.textMid) -- 259
	) -- 259
	texts:put( -- 260
		"sm", -- 260
		"小满 · 潜行", -- 260
		left, -- 260
		boxes[cols + 1].top + 27, -- 260
		toColor(PALETTE.textMid) -- 260
	) -- 260
	do -- 260
		local i = 0 -- 261
		while i < #ROOMS do -- 261
			drawButton( -- 262
				draw, -- 262
				texts, -- 262
				boxes[i + 1], -- 262
				CHAPTER_TITLES[ROOMS[i + 1].key] or ROOMS[i + 1].name, -- 262
				i == self.chapterSelected -- 262
			) -- 262
			i = i + 1 -- 261
		end -- 261
	end -- 261
	local backBox = Rect(left, 48, 188, 44) -- 264
	local hoveringBack = backBox:containsPoint(frame.pointer) -- 265
	drawButton( -- 266
		draw, -- 266
		texts, -- 266
		backBox, -- 266
		self.chaptersFromPause and "返回暂停菜单" or "返回标题", -- 266
		hoveringBack -- 266
	) -- 266
	texts:put( -- 267
		"sm", -- 267
		"方向键选择　Enter 进入　Esc 返回", -- 267
		backBox.right + 24, -- 267
		backBox.centerY, -- 267
		toColor(PALETTE.textMid) -- 268
	) -- 268
	if frame.click and hoveringBack then -- 268
		return back -- 270
	end -- 270
	return (keys.confirm or frame.click and hit >= 0) and ({type = "jump", roomIndex = self.chapterSelected}) or ({type = "none"}) -- 272
end -- 234
function MenuRenderer.prototype.drawControls(self, frame, draw, texts, left, w, h) -- 277
	local backBox = Rect(left, 48, 188, 44) -- 280
	local hoveringBack = backBox:containsPoint(frame.pointer) -- 281
	if frame.back or frame.keys.confirm or frame.click and hoveringBack then -- 281
		return {type = "backTitle"} -- 283
	end -- 283
	texts:put( -- 286
		"lg", -- 286
		"操作说明", -- 286
		left, -- 286
		h - 92, -- 286
		toColor(PALETTE.textBright) -- 286
	) -- 286
	texts:put( -- 287
		"md", -- 287
		"A / D 或 ← / → 移动　　E 互动　　Esc 暂停　　R 重试检查点", -- 287
		left, -- 287
		h - 150, -- 287
		toColor(PALETTE.textBright) -- 288
	) -- 288
	local width = math.min(550, (w - left * 2 - 24) / 2) -- 290
	local panelY = h * 0.23 -- 291
	local height = h * 0.45 -- 292
	self:drawControlGroup( -- 293
		draw, -- 293
		texts, -- 293
		Rect(left, panelY, width, height), -- 293
		"周戍", -- 293
		SOLDIER_CONTROLS -- 293
	) -- 293
	self:drawControlGroup( -- 294
		draw, -- 294
		texts, -- 294
		Rect(left + width + 24, panelY, width, height), -- 294
		"小满", -- 294
		CHILD_CONTROLS -- 294
	) -- 294
	drawButton( -- 296
		draw, -- 296
		texts, -- 296
		backBox, -- 296
		"返回标题", -- 296
		hoveringBack -- 296
	) -- 296
	texts:put( -- 297
		"sm", -- 297
		"Esc 返回", -- 297
		backBox.right + 24, -- 297
		backBox.centerY, -- 297
		toColor(PALETTE.textMid) -- 297
	) -- 297
	return {type = "none"} -- 298
end -- 277
function MenuRenderer.prototype.drawControlGroup(self, draw, texts, box, heading, rows) -- 301
	draw:drawRect( -- 304
		box, -- 304
		toColor(PALETTE.panelBgDeep), -- 304
		1, -- 304
		toColor(PALETTE.steelLight) -- 304
	) -- 304
	texts:put( -- 305
		"md", -- 305
		heading, -- 305
		box.x + 22, -- 305
		box.top - 30, -- 305
		toColor(PALETTE.amberCore) -- 305
	) -- 305
	do -- 305
		local i = 0 -- 306
		while i < #rows do -- 306
			local y = box.top - 82 - i * 42 -- 307
			texts:put( -- 308
				"sm", -- 308
				rows[i + 1][1], -- 308
				box.x + 22, -- 308
				y, -- 308
				toColor(PALETTE.textMid) -- 308
			) -- 308
			texts:put( -- 309
				"sm", -- 309
				rows[i + 1][2], -- 309
				box.x + 166, -- 309
				y, -- 309
				toColor(PALETTE.textBright) -- 309
			) -- 309
			i = i + 1 -- 306
		end -- 306
	end -- 306
end -- 301
function MenuRenderer.prototype.updateAndDrawPause(self, input, draw, texts, w, h, uiScale) -- 313
	local frame = self:readFrame(input, uiScale) -- 316
	if frame.back then -- 316
		return {type = "resume"} -- 318
	end -- 318
	draw:drawRect( -- 321
		Rect(0, 0, w, h), -- 321
		Color(10, 10, 16, 176) -- 321
	) -- 321
	local box = Rect((w - 404) * 0.5, (h - 378) * 0.5, 404, 378) -- 322
	draw:drawRect( -- 323
		box, -- 323
		toColor(PALETTE.panelBgDeep, 251), -- 323
		1, -- 323
		toColor(PALETTE.steelLight) -- 323
	) -- 323
	texts:put( -- 324
		"lg", -- 324
		"游戏暂停", -- 324
		box.x + 25, -- 324
		box.top - 45, -- 324
		toColor(PALETTE.textBright) -- 324
	) -- 324
	local boxes = verticalBoxes(box.x + 25, box.top - 122, box.width - 50, #PAUSE_ITEMS) -- 325
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 326
	texts:put( -- 327
		"sm", -- 327
		"Esc 继续游戏", -- 327
		box.x + 25, -- 327
		box.y + 34, -- 327
		toColor(PALETTE.textMid) -- 327
	) -- 327
	return self:drawActions( -- 328
		draw, -- 328
		texts, -- 328
		PAUSE_ITEMS, -- 328
		boxes, -- 328
		self.pauseSelected, -- 328
		frame -- 328
	) -- 328
end -- 313
return ____exports -- 313