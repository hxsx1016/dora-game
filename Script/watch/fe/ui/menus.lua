-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
local Color = ____Dora.Color -- 11
local Keyboard = ____Dora.Keyboard -- 11
local Rect = ____Dora.Rect -- 11
local Vec2 = ____Dora.Vec2 -- 11
local ____rooms = require("Script.watch.rooms") -- 12
local ROOMS = ____rooms.ROOMS -- 12
local ____controls_config = require("Script.watch.controls_config") -- 14
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 17
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 18
local inputModeLabelOf = ____controls_config.inputModeLabelOf -- 19
local layoutLabelOf = ____controls_config.layoutLabelOf -- 20
local modePrefLabelOf = ____controls_config.modePrefLabelOf -- 21
local nextStepValue = ____controls_config.nextStepValue -- 22
local opacityLabelOf = ____controls_config.opacityLabelOf -- 23
local saveControlSettings = ____controls_config.saveControlSettings -- 24
local scaleLabelOf = ____controls_config.scaleLabelOf -- 25
local ____platform = require("Script.watch.platform") -- 27
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 29
local canQuitApp = ____platform.canQuitApp -- 30
local canToggleFullscreen = ____platform.canToggleFullscreen -- 31
local getPlatformCaps = ____platform.getPlatformCaps -- 32
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 34
local controlsGuideRows = ____control_prompts.controlsGuideRows -- 34
local keyTagFor = ____control_prompts.keyTagFor -- 34
local ____dialogues = require("Script.watch.dialogues") -- 35
local HISTORY_CARDS = ____dialogues.HISTORY_CARDS -- 35
local ____theme = require("Script.watch.fe.theme") -- 39
local PALETTE = ____theme.PALETTE -- 40
local drawBlossomDot = ____theme.drawBlossomDot -- 41
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 42
local drawHairline = ____theme.drawHairline -- 43
local drawLoneSeal = ____theme.drawLoneSeal -- 44
local drawMistCurve = ____theme.drawMistCurve -- 45
local drawSilkKeycap = ____theme.drawSilkKeycap -- 46
local drawSilkRibbon = ____theme.drawSilkRibbon -- 47
local drawSilkVeil = ____theme.drawSilkVeil -- 48
local fillHGradRect = ____theme.fillHGradRect -- 49
local fillRadialGlow = ____theme.fillRadialGlow -- 50
local fillVGradRect = ____theme.fillVGradRect -- 51
local themeOf = ____theme.themeOf -- 52
local toColor = ____theme.toColor -- 53
local visualTextWidth = ____theme.visualTextWidth -- 54
local TITLE_ITEMS = { -- 82
	{id = "start", zh = "开始游戏"}, -- 83
	{id = "chapters", zh = "选择章节"}, -- 84
	{id = "controls", zh = "操作说明"}, -- 85
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 86
	{id = "quit", zh = "退出游戏"} -- 87
} -- 87
local CHAPTERS = __TS__ArrayFilter( -- 91
	__TS__ArrayMap( -- 91
		ROOMS, -- 91
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 91
	), -- 91
	function(____, chapter) return chapter.room.key ~= "museum" and chapter.room.key ~= "street" and chapter.room.key ~= "checkpoint" end -- 92
) -- 92
local PAUSE_ITEMS = { -- 95
	{id = "resume", zh = "继续游戏"}, -- 96
	{id = "retry", zh = "重试检查点"}, -- 97
	{id = "controls", zh = "操作说明"}, -- 98
	{id = "assist", zh = "按键辅助：关"}, -- 99
	{id = "fullscreen", zh = "显示：窗口"}, -- 100
	{id = "chapters", zh = "选择章节"}, -- 101
	{id = "title", zh = "返回标题"}, -- 102
	{id = "quit", zh = "退出游戏"}, -- 103
	{id = "settings", zh = "操控设置"} -- 104
} -- 104
local SETTINGS_ROWS = { -- 107
	{id = "modePref", title = "操作模式"}, -- 108
	{id = "aimAssist", title = "瞄准磁吸"}, -- 109
	{id = "gpLayout", title = "手柄确认键"}, -- 110
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 111
	{id = "touchOpacity", title = "触控按键透度"}, -- 112
	{id = "touchScale", title = "触控按键大小"}, -- 113
	{id = "haptics", title = "触觉震动反馈"}, -- 114
	{id = "back", title = "返回暂歇菜单"} -- 115
} -- 115
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 118
local EPIGRAPH_RIGHT = { -- 119
	"城", -- 119
	"破", -- 119
	"那", -- 119
	"天", -- 119
	"", -- 119
	"他", -- 119
	"留", -- 119
	"下", -- 119
	"断", -- 119
	"后" -- 119
} -- 119
local EPIGRAPH_LEFT = { -- 120
	"她", -- 120
	"独", -- 120
	"自", -- 120
	"走", -- 120
	"向", -- 120
	"北", -- 120
	"塔" -- 120
} -- 120
local function pressedKeys() -- 145
	return { -- 146
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 147
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 148
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 149
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 150
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 151
	} -- 151
end -- 145
local function hitIndex(boxes, pointer, inside) -- 155
	if not inside then -- 156
		return -1 -- 157
	end -- 157
	return __TS__ArrayFindIndex( -- 159
		boxes, -- 159
		function(____, box) return box:containsPoint(pointer) end -- 159
	) -- 159
end -- 155
____exports.MenuRenderer = __TS__Class() -- 162
local MenuRenderer = ____exports.MenuRenderer -- 162
MenuRenderer.name = "MenuRenderer" -- 162
function MenuRenderer.prototype.____constructor(self) -- 162
	self.selected = 0 -- 163
	self.chapterSelected = 0 -- 164
	self.pauseSelected = 0 -- 165
	self.settingsSelected = 0 -- 166
	self.epilogueSelected = 0 -- 167
	self.epilogueEnding = "lamp" -- 168
	self.epilogueBothCleared = false -- 169
	self.historyCardIndex = 0 -- 170
	self.historyFromEpilogue = false -- 171
	self.hasSession = false -- 173
	self.controlsTab = "kbm" -- 175
	self.chaptersFromPause = false -- 177
	self.pauseShowControls = false -- 178
	self.pauseShowSettings = false -- 179
	self.controlsTabManual = false -- 180
	self.previousKeys = {} -- 181
	self.queuedKeys = {} -- 182
	self.queuedBack = false -- 183
	self.queuedSkip = false -- 184
	self.splashTime = 0 -- 185
	self.time = 0 -- 186
end -- 162
function MenuRenderer.prototype.resetSplash(self) -- 188
	self.splashTime = 0 -- 189
	self.queuedSkip = false -- 190
	self:resetInput() -- 191
end -- 188
function MenuRenderer.prototype.isShowingPauseControls(self) -- 194
	return self.pauseShowControls -- 195
end -- 194
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 198
	return self.pauseShowSettings -- 199
end -- 198
function MenuRenderer.prototype.openPauseSettings(self) -- 202
	self.pauseShowControls = false -- 203
	self.pauseShowSettings = true -- 204
	self.settingsSelected = 0 -- 205
	self:resetInput() -- 206
end -- 202
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 209
	self.chaptersFromPause = roomIndex ~= nil -- 210
	self.chapterSelected = math.max( -- 211
		0, -- 211
		__TS__ArrayFindIndex( -- 211
			CHAPTERS, -- 211
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 211
		) -- 211
	) -- 211
	self.pauseShowControls = false -- 212
	self.pauseShowSettings = false -- 213
	self:resetInput() -- 214
end -- 209
function MenuRenderer.prototype.openPause(self) -- 217
	self.pauseSelected = 0 -- 218
	self.pauseShowControls = false -- 219
	self.pauseShowSettings = false -- 220
	self:resetInput() -- 221
end -- 217
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 224
	if ending == nil then -- 224
		ending = "lamp" -- 224
	end -- 224
	if bothCleared == nil then -- 224
		bothCleared = false -- 224
	end -- 224
	self.epilogueEnding = ending -- 225
	self.epilogueBothCleared = bothCleared -- 226
	self.epilogueSelected = 0 -- 227
	self:resetInput() -- 228
end -- 224
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 231
	if fromEpilogue == nil then -- 231
		fromEpilogue = true -- 231
	end -- 231
	self.historyFromEpilogue = fromEpilogue -- 232
	self.historyCardIndex = 0 -- 233
	self:resetInput() -- 234
end -- 231
function MenuRenderer.prototype.triggerBack(self) -- 238
	self.queuedBack = true -- 239
end -- 238
function MenuRenderer.prototype.resetInput(self) -- 243
	self.previousKeys = pressedKeys() -- 244
	self.queuedKeys = {} -- 245
	self.queuedBack = false -- 246
	self.queuedSkip = false -- 247
	self.controlsTabManual = false -- 248
end -- 243
function MenuRenderer.prototype.onKeyEvent(self, key) -- 252
	self.queuedSkip = true -- 253
	if key == "Up" or key == "W" then -- 254
		self.queuedKeys.up = true -- 255
	elseif key == "Down" or key == "S" then -- 256
		self.queuedKeys.down = true -- 257
	elseif key == "Left" or key == "A" then -- 258
		self.queuedKeys.left = true -- 259
	elseif key == "Right" or key == "D" then -- 260
		self.queuedKeys.right = true -- 261
	elseif key == "Return" or key == "Space" then -- 262
		self.queuedKeys.confirm = true -- 263
	elseif key == "Escape" then -- 264
		self.queuedBack = true -- 265
	end -- 265
end -- 252
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 269
	local held = pressedKeys() -- 270
	local prev = self.previousKeys -- 271
	local queued = self.queuedKeys -- 272
	local useUiPtr = input.uiInside or input.uiPressed -- 275
	local rawX = useUiPtr and input.uiX or input.mx -- 276
	local rawY = useUiPtr and input.uiY or input.my -- 277
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 278
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 279
	local ____useUiPtr_0 -- 280
	if useUiPtr then -- 280
		____useUiPtr_0 = input.uiInside -- 280
	else -- 280
		____useUiPtr_0 = input.inside -- 280
	end -- 280
	local inside = ____useUiPtr_0 -- 280
	local ____useUiPtr_1 -- 281
	if useUiPtr then -- 281
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 281
	else -- 281
		____useUiPtr_1 = input.inside and input.fire.pressed -- 281
	end -- 281
	local click = ____useUiPtr_1 -- 281
	local touchMode = input:isTouchMode() -- 282
	local frame = { -- 284
		keys = { -- 285
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 286
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 287
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 288
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 289
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 290
		}, -- 290
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 292
		prevTab = input.navPrevTab, -- 293
		nextTab = input.navNextTab, -- 294
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 295
		pointer = Vec2(rawX / scale, rawY / scale), -- 296
		inside = inside, -- 297
		click = click, -- 298
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 299
		mode = input.inputMode, -- 300
		layout = input.gamepadLayout, -- 301
		safe = safe -- 302
	} -- 302
	self.previousKeys = held -- 304
	self.queuedKeys = {} -- 305
	self.queuedBack = false -- 306
	self.queuedSkip = false -- 307
	return frame -- 308
end -- 269
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 311
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 312
	if frame.click and hit >= 0 then -- 313
		return hit -- 314
	end -- 314
	if frame.keys.up then -- 316
		return (selected + #boxes - 1) % #boxes -- 317
	end -- 317
	if frame.keys.down then -- 319
		return (selected + 1) % #boxes -- 320
	end -- 320
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 322
end -- 311
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 325
	if safeUi == nil then -- 341
		safeUi = ZERO_SAFE_INSETS -- 341
	end -- 341
	self.time = self.time + dt -- 343
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 344
	if screen ~= "splash" or splashDissolving then -- 345
		local artW = math.max(w, h * 16 / 9) -- 346
		local artH = artW * 9 / 16 -- 347
		if not backdropArt:tryPlace( -- 348
			"title_backdrop", -- 348
			"menu_landscape", -- 348
			w * 0.5, -- 348
			(h - artH) * 0.5, -- 348
			artW, -- 348
			artH -- 348
		) then -- 348
			stage:drawMenuBackdrop( -- 349
				bgDraw, -- 349
				bgGlow, -- 349
				w, -- 349
				h, -- 349
				self.time -- 349
			) -- 349
		end -- 349
	end -- 349
	local frame = self:readFrame(input, uiScale, safeUi) -- 353
	w = w / uiScale -- 354
	h = h / uiScale -- 355
	if screen == "splash" then -- 357
		return self:drawSplash( -- 358
			dt, -- 358
			frame, -- 358
			uiDraw, -- 358
			uiArt, -- 358
			texts, -- 358
			w, -- 358
			h -- 358
		) -- 358
	end -- 358
	if screen == "title" then -- 360
		return self:drawTitle( -- 361
			frame, -- 361
			uiDraw, -- 361
			uiInkDraw, -- 361
			uiArt, -- 361
			uiGlow, -- 361
			texts, -- 361
			w, -- 361
			h -- 361
		) -- 361
	end -- 361
	if screen == "chapters" then -- 363
		return self:drawChapters( -- 364
			frame, -- 364
			uiDraw, -- 364
			uiInkDraw, -- 364
			uiArt, -- 364
			uiGlow, -- 364
			texts, -- 364
			w, -- 364
			h -- 364
		) -- 364
	end -- 364
	if screen == "epilogue" then -- 366
		return self:drawEpilogue( -- 367
			frame, -- 367
			uiDraw, -- 367
			uiInkDraw, -- 367
			uiArt, -- 367
			uiGlow, -- 367
			texts, -- 367
			w, -- 367
			h -- 367
		) -- 367
	end -- 367
	if screen == "history" then -- 369
		return self:drawHistory( -- 370
			frame, -- 370
			uiDraw, -- 370
			uiInkDraw, -- 370
			uiArt, -- 370
			uiGlow, -- 370
			texts, -- 370
			w, -- 370
			h -- 370
		) -- 370
	end -- 370
	return self:drawControls( -- 372
		frame, -- 372
		uiDraw, -- 372
		uiInkDraw, -- 372
		uiArt, -- 372
		uiGlow, -- 372
		texts, -- 372
		w, -- 372
		h -- 372
	) -- 372
end -- 325
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 381
	local safeDt = math.min( -- 390
		0.1, -- 390
		math.max(0, dt) -- 390
	) -- 390
	self.splashTime = self.splashTime + safeDt -- 391
	local t = self.splashTime -- 392
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 394
	if wantSkip or t >= 4.65 then -- 395
		self.splashTime = 0 -- 396
		return {type = "splashDone"} -- 397
	end -- 397
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 400
	local bgR = t < 2.2 and 13 or 11 -- 401
	local bgG = t < 2.2 and 16 or 13 -- 402
	local bgB = t < 2.2 and 24 or 19 -- 403
	uiDraw:drawRect( -- 404
		Rect(0, 0, w, h), -- 404
		Color( -- 404
			bgR, -- 404
			bgG, -- 404
			bgB, -- 404
			math.floor(255 * fadeOutCurtain + 0.5) -- 404
		) -- 404
	) -- 404
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 406
		if localT <= 0 or localT >= endT then -- 407
			return 0 -- 407
		end -- 407
		if localT < fadeIn then -- 408
			local u = localT / fadeIn -- 409
			return u * u * (3 - 2 * u) -- 410
		end -- 410
		if localT <= holdEnd then -- 412
			return 1 -- 412
		end -- 412
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 413
		return 1 - u * u * (3 - 2 * u) -- 414
	end -- 406
	if t < 2.2 then -- 417
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 418
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 419
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 420
		if not uiArt:tryPlace( -- 421
			"brand_team_logo", -- 421
			"splash_team_logo", -- 421
			w * 0.5, -- 421
			h * 0.54, -- 421
			logoH * 2, -- 421
			logoH, -- 421
			{opacity = alpha, layer = 2} -- 421
		) then -- 421
			texts:put( -- 422
				"banner", -- 422
				"OUTSIDER", -- 422
				w * 0.5, -- 422
				h * 0.52, -- 422
				toColor(PALETTE.textBright), -- 422
				0.5, -- 422
				0.5, -- 422
				"Center", -- 422
				6, -- 422
				alpha, -- 422
				0 -- 422
			) -- 422
		end -- 422
		texts:put( -- 424
			"xs", -- 424
			"Powered by Dora SSR", -- 424
			w * 0.5, -- 424
			58 + frame.safe.bottom * 0.4, -- 424
			toColor(PALETTE.textDim), -- 424
			0.5, -- 424
			0.5, -- 424
			"Center", -- 424
			1.8, -- 424
			alpha * 0.62, -- 424
			0 -- 424
		) -- 424
	elseif t < 4.25 then -- 425
		local localT = t - 2.2 -- 426
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 427
		local sway = math.sin(localT * 1.1) * 8 -- 428
		drawMistCurve( -- 429
			uiArt, -- 429
			"splash_game_mist", -- 429
			w * 0.5 + sway, -- 429
			h * 0.46, -- 429
			560, -- 429
			110, -- 429
			PALETTE.jadeMist, -- 429
			0.16 * alpha, -- 429
			1 -- 429
		) -- 429
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 430
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 431
		if not uiArt:tryPlace( -- 432
			"brand_game_logo_h", -- 432
			"splash_game_logo", -- 432
			w * 0.5, -- 432
			h * 0.52, -- 432
			logoH * 2.4, -- 432
			logoH, -- 432
			{opacity = alpha, layer = 2} -- 432
		) then -- 432
			texts:put( -- 433
				"title", -- 433
				"向西守望", -- 433
				w * 0.5, -- 433
				h * 0.52, -- 433
				toColor(PALETTE.textBright), -- 433
				0.5, -- 433
				0.5, -- 433
				"Center", -- 433
				8, -- 433
				alpha, -- 433
				0 -- 433
			) -- 433
		end -- 433
	end -- 433
	if t >= 0.35 and t < 4.15 then -- 437
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 438
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 439
		texts:put( -- 444
			"xs", -- 444
			skipText, -- 444
			w - 48 - frame.safe.right * 0.6, -- 444
			36 + frame.safe.bottom * 0.4, -- 444
			toColor(PALETTE.textDim), -- 444
			1, -- 444
			0.5, -- 444
			"Right", -- 444
			1.4, -- 444
			hintA, -- 444
			0 -- 444
		) -- 444
	end -- 444
	return {type = "none"} -- 447
end -- 381
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 450
	fillHGradRect( -- 460
		uiDraw, -- 460
		0, -- 460
		0, -- 460
		w * 0.22 + frame.safe.left * 0.5, -- 460
		h, -- 460
		Color(9, 11, 18, 192), -- 460
		Color(9, 11, 18, 116) -- 460
	) -- 460
	fillHGradRect( -- 461
		uiDraw, -- 461
		w * 0.22 + frame.safe.left * 0.5, -- 461
		0, -- 461
		w * 0.28, -- 461
		h, -- 461
		Color(9, 11, 18, 116), -- 461
		Color(9, 11, 18, 0) -- 461
	) -- 461
	fillVGradRect( -- 462
		uiDraw, -- 462
		0, -- 462
		0, -- 462
		w, -- 462
		78, -- 462
		Color(8, 10, 16, 138), -- 462
		Color(8, 10, 16, 0) -- 462
	) -- 462
	local extraH = math.max(0, h - 720) -- 464
	local titleX = 148 + frame.safe.left * 0.6 -- 465
	local topY = h - 104 - frame.safe.top * 0.4 -- 466
	local charStep = 66 -- 467
	local sway = math.sin(self.time * 0.7) * 5 -- 468
	drawMistCurve( -- 469
		uiArt, -- 469
		"title_mist_wisp", -- 469
		titleX + 86 + sway, -- 469
		topY - 122, -- 469
		340, -- 469
		82, -- 469
		PALETTE.jadeMist, -- 469
		0.2, -- 469
		-1 -- 469
	) -- 469
	uiArt:tryPlace( -- 470
		"ink_petal_mist", -- 470
		"title_petals", -- 470
		titleX + 12, -- 470
		topY - 102, -- 470
		230, -- 470
		210, -- 470
		{ -- 470
			color = toColor(PALETTE.inkMist), -- 471
			opacity = 0.4, -- 471
			layer = -1 -- 471
		} -- 471
	) -- 471
	local placedBrandTitle = uiArt:tryPlace( -- 475
		"brand_game_logo_v", -- 475
		"title_brand_v", -- 475
		titleX + 22, -- 475
		topY - 106, -- 475
		240, -- 475
		304, -- 475
		{opacity = 0.98, layer = 3} -- 475
	) -- 475
	if not placedBrandTitle then -- 478
		uiArt:tryPlace( -- 479
			"ink_vstream", -- 479
			"title_vstream", -- 479
			titleX - 48, -- 479
			topY - 100, -- 479
			34, -- 479
			290, -- 479
			{ -- 479
				color = toColor(PALETTE.silkDim), -- 480
				opacity = 0.48, -- 480
				layer = 1 -- 480
			} -- 480
		) -- 480
		local c = 0 -- 482
		do -- 482
			c = 0 -- 483
			while c < #VERTICAL_TITLE do -- 483
				texts:put( -- 484
					"title", -- 485
					VERTICAL_TITLE[c + 1], -- 486
					titleX, -- 487
					topY - c * charStep, -- 488
					toColor(PALETTE.textBright), -- 489
					0.5, -- 490
					0.5, -- 491
					"Center", -- 492
					0, -- 493
					0.98, -- 494
					0.1, -- 495
					Color(8, 10, 16, 210) -- 496
				) -- 496
				c = c + 1 -- 483
			end -- 483
		end -- 483
		drawLoneSeal( -- 499
			uiInkDraw, -- 500
			uiArt, -- 501
			texts, -- 502
			"title_lone_seal", -- 503
			titleX + 46, -- 504
			topY - 3 * charStep + 8, -- 505
			26, -- 506
			52, -- 507
			"守", -- 508
			"望", -- 509
			PALETTE.sealRed, -- 510
			PALETTE.sealText, -- 511
			0.94, -- 512
			4 -- 513
		) -- 513
	end -- 513
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 518
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 519
	local poemStep = 22 -- 520
	local p = 0 -- 521
	do -- 521
		p = 0 -- 522
		while p < #EPIGRAPH_RIGHT do -- 522
			local ch = EPIGRAPH_RIGHT[p + 1] -- 523
			if ch ~= "" then -- 524
				texts:put( -- 525
					"xs", -- 525
					ch, -- 525
					colRightX, -- 525
					topY - 22 - p * poemStep, -- 525
					toColor(PALETTE.textMid), -- 525
					0.5, -- 525
					0.5, -- 525
					"Center", -- 525
					0, -- 525
					0.86, -- 525
					0.08 -- 525
				) -- 525
			end -- 525
			p = p + 1 -- 522
		end -- 522
	end -- 522
	do -- 522
		p = 0 -- 528
		while p < #EPIGRAPH_LEFT do -- 528
			texts:put( -- 529
				"xs", -- 529
				EPIGRAPH_LEFT[p + 1], -- 529
				colLeftX, -- 529
				topY - 68 - p * poemStep, -- 529
				toColor(PALETTE.amberCore), -- 529
				0.5, -- 529
				0.5, -- 529
				"Center", -- 529
				0, -- 529
				0.9, -- 529
				0.08 -- 529
			) -- 529
			p = p + 1 -- 528
		end -- 528
	end -- 528
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 533
		TITLE_ITEMS, -- 535
		function(____, it) return it.id ~= "quit" end -- 535
	) -- 535
	local items = self.hasSession and ({ -- 536
		{id = "continue", zh = "继续游戏"}, -- 537
		table.unpack(baseItems) -- 537
	}) or baseItems -- 538
	if self.selected >= #items then -- 539
		self.selected = 0 -- 540
	end -- 540
	local menuX = 112 + frame.safe.left * 0.6 -- 542
	local btnW = 280 -- 543
	local btnH = frame.mode == "touch" and 44 or 40 -- 544
	local gap = self.hasSession and 6 or 8 -- 545
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 546
	local boxes = {} -- 547
	local i = 0 -- 548
	do -- 548
		i = 0 -- 549
		while i < #items do -- 549
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 550
			i = i + 1 -- 549
		end -- 549
	end -- 549
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 552
	do -- 552
		i = 0 -- 554
		while i < #items do -- 554
			local by = boxes[i + 1].y -- 555
			local active = self.selected == i -- 556
			local cy = by + btnH * 0.5 -- 557
			local shiftX = active and 10 or 0 -- 558
			if active then -- 560
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 561
				drawSilkRibbon( -- 562
					uiDraw, -- 562
					uiArt, -- 562
					"title_rib_red_" .. tostring(i), -- 562
					menuX + 124, -- 562
					cy, -- 562
					290, -- 562
					btnH, -- 562
					PALETTE.rougeSoft, -- 562
					0.52 * breathe, -- 562
					0 -- 562
				) -- 562
				drawHairline( -- 563
					uiInkDraw, -- 563
					uiArt, -- 563
					"title_rib_line_" .. tostring(i), -- 563
					menuX + 114, -- 563
					by + 4, -- 563
					230, -- 563
					PALETTE.silkLine, -- 563
					0.42 * breathe, -- 563
					false, -- 563
					2 -- 563
				) -- 563
				drawBlossomDot( -- 564
					uiInkDraw, -- 564
					uiArt, -- 564
					"title_dot_" .. tostring(i), -- 564
					menuX + 14, -- 564
					cy, -- 564
					16, -- 564
					PALETTE.rouge, -- 564
					0.96, -- 564
					4 -- 564
				) -- 564
				fillRadialGlow( -- 565
					uiGlow, -- 565
					menuX + 14, -- 565
					cy, -- 565
					22, -- 565
					16, -- 565
					toColor(PALETTE.rouge, 28 * breathe), -- 565
					Color(182, 58, 56, 0), -- 565
					10 -- 565
				) -- 565
			else -- 565
				drawBlossomDot( -- 567
					uiInkDraw, -- 567
					uiArt, -- 567
					"title_dot_" .. tostring(i), -- 567
					menuX + 14, -- 567
					cy, -- 567
					8, -- 567
					PALETTE.silkDim, -- 567
					0.4, -- 567
					3 -- 567
				) -- 567
			end -- 567
			texts:put( -- 570
				"md", -- 571
				items[i + 1].zh, -- 572
				menuX + 34 + shiftX, -- 573
				cy, -- 574
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 575
				0, -- 576
				0.5, -- 577
				"Left", -- 578
				active and 4.4 or 2.8, -- 579
				active and 1 or 0.88, -- 580
				0.1 -- 581
			) -- 581
			i = i + 1 -- 554
		end -- 554
	end -- 554
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 585
	texts:put( -- 592
		"xs", -- 592
		titleHint, -- 592
		menuX + 12, -- 592
		42 + frame.safe.bottom * 0.45, -- 592
		toColor(PALETTE.textDim), -- 592
		0, -- 592
		0.5, -- 592
		"Left", -- 592
		1.4, -- 592
		0.88, -- 592
		0.08 -- 592
	) -- 592
	local badgeRight = w - frame.safe.right * 0.5 -- 595
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 596
	fillHGradRect( -- 597
		uiDraw, -- 597
		badgeRight - 270, -- 597
		0, -- 597
		270 + frame.safe.right * 0.5, -- 597
		86, -- 597
		Color(8, 10, 16, 0), -- 597
		Color(8, 10, 16, 204) -- 597
	) -- 597
	uiArt:tryPlace( -- 598
		"brand_team_badge", -- 598
		"title_team_badge", -- 598
		badgeRight - 118, -- 598
		badgeY, -- 598
		168, -- 598
		54, -- 598
		{opacity = 0.95, layer = 3} -- 598
	) -- 598
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 602
	if hit >= 0 or frame.keys.confirm then -- 603
		local idx = hit >= 0 and hit or self.selected -- 604
		local id = items[idx + 1].id -- 605
		if id == "continue" then -- 606
			return {type = "continue"} -- 606
		end -- 606
		if id == "trial" then -- 607
			return {type = "trial"} -- 607
		end -- 607
		if id == "start" then -- 608
			return {type = "start"} -- 608
		end -- 608
		if id == "chapters" then -- 609
			return {type = "openChapters"} -- 609
		end -- 609
		if id == "quit" then -- 610
			return {type = "quit"} -- 610
		end -- 610
		return {type = "openControls"} -- 611
	end -- 611
	return {type = "none"} -- 613
end -- 450
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 616
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 626
	if frame.back then -- 627
		return back -- 628
	end -- 628
	local extraH = math.max(0, h - 720) -- 631
	local marginX = math.max( -- 632
		96, -- 632
		56 + math.max(frame.safe.left, frame.safe.right) -- 632
	) -- 632
	local splitTrack = #CHAPTERS > 8 -- 633
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 634
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 635
	local rowGap = 68 -- 636
	local trackX0 = marginX + 34 -- 637
	local trackX1 = w - marginX - 34 -- 638
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 639
	local stationBoxes = {} -- 641
	local s = 0 -- 642
	do -- 642
		s = 0 -- 643
		while s < #CHAPTERS do -- 643
			local sx = trackX0 + s % perRow * stepX -- 644
			local sy = trackY - math.floor(s / perRow) * rowGap -- 645
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 646
			s = s + 1 -- 643
		end -- 643
	end -- 643
	local prevSelected = self.chapterSelected -- 649
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 650
	local keys = frame.keys -- 651
	if frame.click and hitStation >= 0 then -- 652
		self.chapterSelected = hitStation -- 653
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 654
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 655
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 656
	elseif keys.down and self.chapterSelected < perRow then -- 657
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 658
	elseif keys.up and self.chapterSelected >= perRow then -- 659
		self.chapterSelected = self.chapterSelected - perRow -- 660
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 661
		self.chapterSelected = hitStation -- 662
	end -- 662
	uiDraw:drawRect( -- 665
		Rect(0, 0, w, h), -- 665
		Color(10, 12, 19, 198) -- 665
	) -- 665
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 667
	texts:put( -- 668
		"banner", -- 668
		"选择章节", -- 668
		marginX, -- 668
		topHeadY, -- 668
		toColor(PALETTE.textBright), -- 668
		0, -- 668
		0.5, -- 668
		"Left", -- 668
		4.5, -- 668
		0.96, -- 668
		0.1 -- 668
	) -- 668
	drawHairline( -- 669
		uiInkDraw, -- 669
		uiArt, -- 669
		"chap_top_line", -- 669
		w * 0.5, -- 669
		topHeadY - 34, -- 669
		w - marginX * 2, -- 669
		PALETTE.silkDim, -- 669
		0.6, -- 669
		true, -- 669
		2 -- 669
	) -- 669
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 671
	local theme = themeOf(activeRoom.key) -- 672
	local winX = marginX -- 673
	local winY = 266 + extraH * 0.44 -- 674
	local winW = math.min( -- 675
		520, -- 675
		math.max(360, (w - marginX * 2) * 0.46) -- 675
	) -- 675
	local winH = 296 -- 676
	local winBox = Rect(winX, winY, winW, winH) -- 677
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 678
	uiArt:tryPlace( -- 680
		"ink_frame_mask", -- 680
		"chap_win_shadow", -- 680
		winX + winW * 0.5, -- 680
		winY + winH * 0.5, -- 680
		winW + 40, -- 680
		winH + 34, -- 680
		{ -- 680
			color = toColor(PALETTE.inkVoid), -- 681
			opacity = 0.88, -- 681
			layer = -2 -- 681
		} -- 681
	) -- 681
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 683
	uiArt:tryPlace( -- 684
		bgSlot, -- 684
		"chap_win_art", -- 684
		winX + winW * 0.5, -- 684
		winY + 4, -- 684
		winW - 8, -- 684
		winH - 8, -- 684
		{opacity = 0.92, layer = -1} -- 684
	) -- 684
	fillVGradRect( -- 687
		uiInkDraw, -- 687
		winX, -- 687
		winY, -- 687
		winW, -- 687
		56, -- 687
		Color(10, 12, 19, 200), -- 687
		Color(10, 12, 19, 0) -- 687
	) -- 687
	fillVGradRect( -- 688
		uiInkDraw, -- 688
		winX, -- 688
		winY + winH - 36, -- 688
		winW, -- 688
		36, -- 688
		Color(10, 12, 19, 0), -- 688
		Color(10, 12, 19, 130) -- 688
	) -- 688
	fillHGradRect( -- 689
		uiInkDraw, -- 689
		winX, -- 689
		winY, -- 689
		34, -- 689
		winH, -- 689
		Color(10, 12, 19, 135), -- 689
		Color(10, 12, 19, 0) -- 689
	) -- 689
	fillHGradRect( -- 690
		uiInkDraw, -- 690
		winX + winW - 34, -- 690
		winY, -- 690
		34, -- 690
		winH, -- 690
		Color(10, 12, 19, 0), -- 690
		Color(10, 12, 19, 135) -- 690
	) -- 690
	drawFiligreeCorners( -- 691
		uiInkDraw, -- 691
		uiArt, -- 691
		"chap_win_frame", -- 691
		winX, -- 691
		winY, -- 691
		winW, -- 691
		winH, -- 691
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 691
		winHover and 0.92 or 0.72, -- 691
		34, -- 691
		true, -- 691
		3 -- 691
	) -- 691
	texts:put( -- 693
		"xs", -- 693
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 693
		winX + 20, -- 693
		winY + 22, -- 693
		toColor(PALETTE.textMid), -- 693
		0, -- 693
		0.5, -- 693
		"Left", -- 693
		1.8, -- 693
		0.9, -- 693
		0.08 -- 693
	) -- 693
	local infoX = winX + winW + 40 -- 695
	local infoW = math.max(240, w - marginX - infoX) -- 696
	local infoCenterY = winY + winH * 0.5 -- 697
	drawMistCurve( -- 698
		uiArt, -- 698
		"chap_info_mist", -- 698
		infoX + infoW * 0.5, -- 698
		infoCenterY + 36, -- 698
		math.min(420, infoW + 24), -- 698
		88, -- 698
		theme.accent, -- 698
		0.22, -- 698
		-1 -- 698
	) -- 698
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 700
	texts:put( -- 701
		"xs", -- 701
		theme.volumeTagZh, -- 701
		infoX, -- 701
		winY + winH - 44, -- 701
		toColor(volCol), -- 701
		0, -- 701
		0.5, -- 701
		"Left", -- 701
		2.8, -- 701
		0.92, -- 701
		0.08 -- 701
	) -- 701
	local sep = " · " -- 703
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 704
	local titleY = winY + winH - 98 -- 705
	if theme.backdropKey ~= nil then -- 706
		texts:put( -- 707
			"lg", -- 707
			theme.titleZh, -- 707
			infoX, -- 707
			titleY, -- 707
			toColor(PALETTE.textBright) -- 707
		) -- 707
	elseif sIdx > 0 then -- 708
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 709
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 710
		local lw = visualTextWidth(leftPart, 40) -- 711
		texts:put( -- 712
			"banner", -- 712
			leftPart, -- 712
			infoX, -- 712
			titleY, -- 712
			toColor(PALETTE.textBright), -- 712
			0, -- 712
			0.5, -- 712
			"Left", -- 712
			2, -- 712
			1, -- 712
			0.1 -- 712
		) -- 712
		drawBlossomDot( -- 713
			uiInkDraw, -- 713
			uiArt, -- 713
			"chap_title_dot", -- 713
			infoX + lw + 16, -- 713
			titleY - 2, -- 713
			11, -- 713
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 713
			0.9, -- 713
			4 -- 713
		) -- 713
		texts:put( -- 714
			"banner", -- 714
			rightPart, -- 714
			infoX + lw + 32, -- 714
			titleY, -- 714
			toColor(PALETTE.textBright), -- 714
			0, -- 714
			0.5, -- 714
			"Left", -- 714
			2, -- 714
			1, -- 714
			0.1 -- 714
		) -- 714
	else -- 714
		texts:put( -- 716
			"banner", -- 716
			theme.titleZh, -- 716
			infoX, -- 716
			titleY, -- 716
			toColor(PALETTE.textBright), -- 716
			0, -- 716
			0.5, -- 716
			"Left", -- 716
			2.4, -- 716
			1, -- 716
			0.1 -- 716
		) -- 716
	end -- 716
	drawHairline( -- 719
		uiInkDraw, -- 719
		uiArt, -- 719
		"chap_info_line", -- 719
		infoX + math.min(185, infoW * 0.5), -- 719
		titleY - 36, -- 719
		math.min(370, infoW), -- 719
		PALETTE.silkDim, -- 719
		0.58, -- 719
		false, -- 719
		2 -- 719
	) -- 719
	texts:put( -- 720
		"sm", -- 720
		theme.introWhisper, -- 720
		infoX, -- 720
		titleY - 72, -- 720
		toColor(PALETTE.textMid), -- 720
		0, -- 720
		0.5, -- 720
		"Left", -- 720
		0.8, -- 720
		0.94, -- 720
		0.08 -- 720
	) -- 720
	local goX = infoX -- 722
	local goY = winY + 26 -- 723
	local goW = 220 -- 724
	local goH = 42 -- 725
	local goBox = Rect(goX, goY, goW, goH) -- 726
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 727
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 728
	drawSilkRibbon( -- 729
		uiDraw, -- 729
		uiArt, -- 729
		"chap_go_rib", -- 729
		goX + 106, -- 729
		goY + 21, -- 729
		250, -- 729
		40, -- 729
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 729
		(goHover and 0.68 or 0.46) * breathe, -- 729
		0 -- 729
	) -- 729
	drawHairline( -- 730
		uiInkDraw, -- 730
		uiArt, -- 730
		"chap_go_line", -- 730
		goX + 94, -- 730
		goY + 3, -- 730
		196, -- 730
		PALETTE.silkLine, -- 730
		goHover and 0.68 or 0.4, -- 730
		false, -- 730
		2 -- 730
	) -- 730
	drawBlossomDot( -- 731
		uiInkDraw, -- 731
		uiArt, -- 731
		"chap_go_dot", -- 731
		goX + 14, -- 731
		goY + 21, -- 731
		14, -- 731
		PALETTE.rouge, -- 731
		0.96, -- 731
		4 -- 731
	) -- 731
	texts:put( -- 732
		"md", -- 732
		"入此卷章", -- 732
		goX + 34, -- 732
		goY + 21, -- 732
		toColor(PALETTE.textBright), -- 732
		0, -- 732
		0.5, -- 732
		"Left", -- 732
		3.8, -- 732
		1, -- 732
		0.1 -- 732
	) -- 732
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 733
	texts:put( -- 736
		"xs", -- 736
		chapConfirmTag, -- 736
		goX + 156, -- 736
		goY + 21, -- 736
		toColor(PALETTE.textDim), -- 736
		0, -- 736
		0.5, -- 736
		"Left", -- 736
		1, -- 736
		0.82, -- 736
		0.08 -- 736
	) -- 736
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 738
	local veilH = splitTrack and 156 or 126 -- 739
	drawSilkVeil( -- 740
		uiDraw, -- 740
		uiArt, -- 740
		"chap_track_veil", -- 740
		w * 0.5, -- 740
		veilCenterY, -- 740
		w - marginX * 1.1, -- 740
		veilH, -- 740
		PALETTE.inkWash, -- 740
		0.72, -- 740
		-2 -- 740
	) -- 740
	drawMistCurve( -- 741
		uiArt, -- 741
		"chap_track_mist", -- 741
		w * 0.5, -- 741
		trackY, -- 741
		trackX1 - trackX0 + 160, -- 741
		74, -- 741
		PALETTE.inkMist, -- 741
		0.62, -- 741
		-1 -- 741
	) -- 741
	uiInkDraw:drawSegment( -- 742
		Vec2(trackX0, trackY), -- 742
		Vec2(trackX1, trackY), -- 742
		0.9, -- 742
		toColor(PALETTE.silkDim, 145) -- 742
	) -- 742
	if splitTrack then -- 744
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 745
		uiInkDraw:drawSegment( -- 746
			Vec2(trackX0, trackY - rowGap), -- 746
			Vec2(lastX, trackY - rowGap), -- 746
			0.9, -- 746
			toColor(PALETTE.silkDim, 145) -- 746
		) -- 746
	else -- 746
		local midDivX = trackX0 + stepX * 3.5 -- 748
		uiInkDraw:drawSegment( -- 749
			Vec2(midDivX, trackY - 12), -- 749
			Vec2(midDivX, trackY + 12), -- 749
			0.8, -- 749
			toColor(PALETTE.silkDim, 120) -- 749
		) -- 749
		texts:put( -- 750
			"xs", -- 750
			"上卷 · 孤城护童", -- 750
			trackX0 + stepX * 1.5, -- 750
			trackY + 52, -- 750
			toColor(PALETTE.cyan), -- 750
			0.5, -- 750
			0.5, -- 750
			"Center", -- 750
			2.2, -- 750
			0.88, -- 750
			0.08 -- 750
		) -- 750
		texts:put( -- 751
			"xs", -- 751
			"下卷 · 独赴北塔", -- 751
			trackX0 + stepX * 5.5, -- 751
			trackY + 52, -- 751
			toColor(PALETTE.amber), -- 751
			0.5, -- 751
			0.5, -- 751
			"Center", -- 751
			2.2, -- 751
			0.88, -- 751
			0.08 -- 751
		) -- 751
	end -- 751
	local i = 0 -- 754
	do -- 754
		i = 0 -- 755
		while i < #CHAPTERS do -- 755
			local box = stationBoxes[i + 1] -- 756
			local sx = box.x + box.width * 0.5 -- 757
			local sy = box.y + box.height * 0.5 -- 758
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 759
			local active = self.chapterSelected == i -- 760
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 761
			if active then -- 763
				fillRadialGlow( -- 764
					uiGlow, -- 764
					sx, -- 764
					sy, -- 764
					26, -- 764
					26, -- 764
					toColor(PALETTE.rouge, 36 * breathe), -- 764
					Color(182, 58, 56, 0), -- 764
					12 -- 764
				) -- 764
				uiArt:tryPlace( -- 765
					"ink_enso_fine", -- 765
					"chap_st_ring_" .. tostring(i), -- 765
					sx, -- 765
					sy, -- 765
					32, -- 765
					32, -- 765
					{ -- 765
						color = toColor(PALETTE.silkLine), -- 766
						opacity = 0.78, -- 766
						angle = self.time * 18, -- 766
						layer = 3 -- 766
					} -- 766
				) -- 766
				drawBlossomDot( -- 768
					uiInkDraw, -- 768
					uiArt, -- 768
					"chap_st_dot_" .. tostring(i), -- 768
					sx, -- 768
					sy, -- 768
					17, -- 768
					PALETTE.rouge, -- 768
					0.98, -- 768
					4 -- 768
				) -- 768
			else -- 768
				uiArt:tryPlace( -- 770
					"ink_enso_fine", -- 770
					"chap_st_ring_" .. tostring(i), -- 770
					sx, -- 770
					sy, -- 770
					16, -- 770
					16, -- 770
					{ -- 770
						color = toColor(nodeCol), -- 771
						opacity = 0.62, -- 771
						layer = 3 -- 771
					} -- 771
				) -- 771
				drawBlossomDot( -- 773
					uiInkDraw, -- 773
					uiArt, -- 773
					"chap_st_dot_" .. tostring(i), -- 773
					sx, -- 773
					sy, -- 773
					7, -- 773
					PALETTE.silkLine, -- 773
					0.72, -- 773
					4 -- 773
				) -- 773
			end -- 773
			if not splitTrack then -- 776
				texts:put( -- 777
					"xs", -- 777
					rt.numeralZh, -- 777
					sx, -- 777
					sy + 25, -- 777
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 777
					0.5, -- 777
					0.5, -- 777
					"Center", -- 777
					0, -- 777
					active and 1 or 0.88, -- 777
					0.08 -- 777
				) -- 777
			end -- 777
			texts:put( -- 779
				"xs", -- 779
				rt.shortNameZh, -- 779
				sx, -- 779
				sy - 26, -- 779
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 779
				0.5, -- 779
				0.5, -- 779
				"Center", -- 779
				1, -- 779
				active and 1 or 0.84, -- 779
				0.08 -- 779
			) -- 779
			i = i + 1 -- 755
		end -- 755
	end -- 755
	local backX = marginX -- 782
	local backY = 40 + frame.safe.bottom * 0.45 -- 783
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 784
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 785
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 786
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 789
	drawSilkKeycap( -- 794
		uiInkDraw, -- 794
		texts, -- 794
		backX, -- 794
		backY + 5, -- 794
		48, -- 794
		24, -- 794
		chapBackTag, -- 794
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 794
		0.92, -- 794
		backHover -- 794
	) -- 794
	texts:put( -- 795
		"sm", -- 795
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 795
		backX + 60, -- 795
		backY + 17, -- 795
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 795
		0, -- 795
		0.5, -- 795
		"Left", -- 795
		1.8, -- 795
		0.9, -- 795
		0.08 -- 795
	) -- 795
	texts:put( -- 796
		"xs", -- 796
		chapFooter, -- 796
		w - marginX, -- 796
		backY + 17, -- 796
		toColor(PALETTE.textDim), -- 796
		1, -- 796
		0.5, -- 796
		"Right", -- 796
		1.2, -- 796
		0.75, -- 796
		0.08 -- 796
	) -- 796
	if frame.click and backHover then -- 798
		return back -- 799
	end -- 799
	local ____temp_2 -- 802
	if frame.mode == "touch" then -- 802
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 803
	else -- 803
		____temp_2 = hitStation >= 0 -- 804
	end -- 804
	local stationConfirmed = ____temp_2 -- 802
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 805
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 806
	end -- 806
	return {type = "none"} -- 808
end -- 616
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 812
	if backLabel == nil then -- 821
		backLabel = "返回标题" -- 821
	end -- 821
	if not self.controlsTabManual then -- 823
		self.controlsTab = frame.mode -- 824
	end -- 824
	local tabOrder = {"kbm", "gamepad", "touch"} -- 826
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 827
	local marginX = math.max( -- 828
		96, -- 828
		56 + math.max(frame.safe.left, frame.safe.right) -- 828
	) -- 828
	local tabW = 92 -- 829
	local tabH = 28 -- 830
	local tabGap = 10 -- 831
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 832
	local tabY = h - 82 - frame.safe.top * 0.35 -- 833
	local tabBoxes = { -- 834
		Rect(tabStartX, tabY, tabW, tabH), -- 835
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 836
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 837
	} -- 837
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 840
	if frame.click and hitTab >= 0 then -- 841
		self.controlsTab = tabOrder[hitTab + 1] -- 842
		self.controlsTabManual = true -- 843
	elseif frame.keys.left or frame.prevTab then -- 844
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 845
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 846
		self.controlsTabManual = true -- 847
	elseif frame.keys.right or frame.nextTab then -- 848
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 849
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 850
		self.controlsTabManual = true -- 851
	end -- 851
	local backX = marginX -- 854
	local backY = 40 + frame.safe.bottom * 0.45 -- 855
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 856
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 857
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 858
		return {type = "backTitle"} -- 859
	end -- 859
	uiDraw:drawRect( -- 861
		Rect(0, 0, w, h), -- 861
		Color(10, 12, 19, 204) -- 861
	) -- 861
	local guide = controlsGuideRows(self.controlsTab) -- 863
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 864
	texts:put( -- 865
		"banner", -- 865
		"执器要诀", -- 865
		marginX, -- 865
		topHeadY, -- 865
		toColor(PALETTE.textBright), -- 865
		0, -- 865
		0.5, -- 865
		"Left", -- 865
		4.5, -- 865
		0.96, -- 865
		0.1 -- 865
	) -- 865
	texts:put( -- 866
		"xs", -- 866
		guide.subtitle, -- 866
		marginX + 196, -- 866
		topHeadY - 4, -- 866
		toColor(PALETTE.textDim), -- 866
		0, -- 866
		0.5, -- 866
		"Left", -- 866
		1.8, -- 866
		0.85, -- 866
		0.08 -- 866
	) -- 866
	drawHairline( -- 867
		uiInkDraw, -- 867
		uiArt, -- 867
		"ctrl_top_line", -- 867
		w * 0.5, -- 867
		topHeadY - 34, -- 867
		w - marginX * 2, -- 867
		PALETTE.silkDim, -- 867
		0.6, -- 867
		true, -- 867
		2 -- 867
	) -- 867
	local ti = 0 -- 869
	do -- 869
		ti = 0 -- 870
		while ti < #tabBoxes do -- 870
			local tb = tabBoxes[ti + 1] -- 871
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 872
			local hoverTab = hitTab == ti -- 873
			uiInkDraw:drawRect( -- 874
				tb, -- 875
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 876
				0.9, -- 877
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 878
			) -- 878
			texts:put( -- 880
				"xs", -- 881
				tabLabels[ti + 1], -- 882
				tb.x + tb.width * 0.5, -- 883
				tb.y + tb.height * 0.5, -- 884
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 885
				0.5, -- 886
				0.5, -- 887
				"Center", -- 888
				0.8, -- 889
				activeTab and 0.98 or 0.82, -- 890
				0.08 -- 891
			) -- 891
			ti = ti + 1 -- 870
		end -- 870
	end -- 870
	local extraH = math.max(0, h - 720) -- 895
	local areaY = 114 + frame.safe.bottom * 0.4 -- 896
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 897
	drawFiligreeCorners( -- 898
		uiInkDraw, -- 898
		uiArt, -- 898
		"ctrl_outer", -- 898
		marginX, -- 898
		areaY, -- 898
		w - marginX * 2, -- 898
		areaH, -- 898
		PALETTE.silkDim, -- 898
		0.52, -- 898
		34, -- 898
		false, -- 898
		2 -- 898
	) -- 898
	local midX = w * 0.5 -- 900
	uiArt:tryPlace( -- 901
		"ink_vstream", -- 901
		"ctrl_mid_stream", -- 901
		midX, -- 901
		areaY + areaH * 0.5, -- 901
		32, -- 901
		areaH - 18, -- 901
		{ -- 901
			color = toColor(PALETTE.silkDim), -- 902
			opacity = 0.52, -- 902
			layer = 1 -- 902
		} -- 902
	) -- 902
	drawBlossomDot( -- 904
		uiInkDraw, -- 904
		uiArt, -- 904
		"ctrl_mid_dot", -- 904
		midX, -- 904
		areaY + areaH * 0.5, -- 904
		11, -- 904
		PALETTE.silkLine, -- 904
		0.62, -- 904
		3 -- 904
	) -- 904
	local leftColX = marginX + 34 -- 906
	local colW = midX - leftColX - 42 -- 907
	local headY = areaY + areaH - 34 -- 908
	local rowStep = 52 + extraH * 0.08 -- 909
	drawBlossomDot( -- 911
		uiInkDraw, -- 911
		uiArt, -- 911
		"ctrl_l_dot", -- 911
		leftColX + 8, -- 911
		headY, -- 911
		12, -- 911
		PALETTE.cyan, -- 911
		0.88, -- 911
		3 -- 911
	) -- 911
	texts:put( -- 912
		"md", -- 912
		"周戍 · 护送与交锋", -- 912
		leftColX + 26, -- 912
		headY, -- 912
		toColor(PALETTE.cyanCore), -- 912
		0, -- 912
		0.5, -- 912
		"Left", -- 912
		2.4, -- 912
		0.98, -- 912
		0.08 -- 912
	) -- 912
	drawHairline( -- 913
		uiInkDraw, -- 913
		uiArt, -- 913
		"ctrl_l_line", -- 913
		leftColX + colW * 0.5, -- 913
		headY - 24, -- 913
		colW, -- 913
		PALETTE.cyanDim, -- 913
		0.58, -- 913
		false, -- 913
		2 -- 913
	) -- 913
	local i = 0 -- 915
	local keycapW = 160 -- 916
	do -- 916
		i = 0 -- 917
		while i < #guide.soldierRows do -- 917
			local ry = headY - 66 - i * rowStep -- 918
			drawSilkKeycap( -- 919
				uiInkDraw, -- 919
				texts, -- 919
				leftColX + 2, -- 919
				ry - 13, -- 919
				keycapW, -- 919
				26, -- 919
				guide.soldierRows[i + 1][1], -- 919
				PALETTE.cyan, -- 919
				0.92, -- 919
				false -- 919
			) -- 919
			texts:put( -- 920
				"sm", -- 920
				guide.soldierRows[i + 1][2], -- 920
				leftColX + keycapW + 16, -- 920
				ry, -- 920
				toColor(PALETTE.textBright), -- 920
				0, -- 920
				0.5, -- 920
				"Left", -- 920
				0.8, -- 920
				0.92, -- 920
				0.08 -- 920
			) -- 920
			i = i + 1 -- 917
		end -- 917
	end -- 917
	local rightColX = midX + 44 -- 923
	drawBlossomDot( -- 924
		uiInkDraw, -- 924
		uiArt, -- 924
		"ctrl_r_dot", -- 924
		rightColX + 8, -- 924
		headY, -- 924
		12, -- 924
		PALETTE.amber, -- 924
		0.88, -- 924
		3 -- 924
	) -- 924
	texts:put( -- 925
		"md", -- 925
		"小满 · 潜行与寻路", -- 925
		rightColX + 26, -- 925
		headY, -- 925
		toColor(PALETTE.amberCore), -- 925
		0, -- 925
		0.5, -- 925
		"Left", -- 925
		2.4, -- 925
		0.98, -- 925
		0.08 -- 925
	) -- 925
	drawHairline( -- 926
		uiInkDraw, -- 926
		uiArt, -- 926
		"ctrl_r_line", -- 926
		rightColX + colW * 0.5, -- 926
		headY - 24, -- 926
		colW, -- 926
		PALETTE.amberDim, -- 926
		0.58, -- 926
		false, -- 926
		2 -- 926
	) -- 926
	do -- 926
		i = 0 -- 928
		while i < #guide.childRows do -- 928
			local ry = headY - 66 - i * rowStep -- 929
			drawSilkKeycap( -- 930
				uiInkDraw, -- 930
				texts, -- 930
				rightColX + 2, -- 930
				ry - 13, -- 930
				keycapW, -- 930
				26, -- 930
				guide.childRows[i + 1][1], -- 930
				PALETTE.amber, -- 930
				0.92, -- 930
				false -- 930
			) -- 930
			texts:put( -- 931
				"sm", -- 931
				guide.childRows[i + 1][2], -- 931
				rightColX + keycapW + 16, -- 931
				ry, -- 931
				toColor(PALETTE.textBright), -- 931
				0, -- 931
				0.5, -- 931
				"Left", -- 931
				0.8, -- 931
				0.92, -- 931
				0.08 -- 931
			) -- 931
			i = i + 1 -- 928
		end -- 928
	end -- 928
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 934
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 937
	local keyW = frame.mode == "touch" and 76 or 110 -- 942
	drawSilkKeycap( -- 943
		uiInkDraw, -- 943
		texts, -- 943
		backX, -- 943
		backY + 5, -- 943
		keyW, -- 943
		24, -- 943
		ctrlBackKey, -- 943
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 943
		0.92, -- 943
		backHover -- 943
	) -- 943
	texts:put( -- 944
		"sm", -- 944
		backLabel, -- 944
		backX + keyW + 12, -- 944
		backY + 17, -- 944
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 944
		0, -- 944
		0.5, -- 944
		"Left", -- 944
		1.8, -- 944
		0.92, -- 944
		0.08 -- 944
	) -- 944
	texts:put( -- 945
		"xs", -- 945
		ctrlRightHint, -- 945
		w - marginX, -- 945
		backY + 17, -- 945
		toColor(PALETTE.textDim), -- 945
		1, -- 945
		0.5, -- 945
		"Right", -- 945
		1.2, -- 945
		0.78, -- 945
		0.08 -- 945
	) -- 945
	return {type = "none"} -- 947
end -- 812
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 951
	if frame.back then -- 962
		return true -- 963
	end -- 963
	local caps = getPlatformCaps() -- 966
	local s = input.settings -- 967
	uiDraw:drawRect( -- 969
		Rect(0, 0, w, h), -- 969
		Color(10, 12, 19, 206) -- 969
	) -- 969
	local marginX = math.max( -- 971
		96, -- 971
		56 + math.max(frame.safe.left, frame.safe.right) -- 971
	) -- 971
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 972
	texts:put( -- 973
		"banner", -- 973
		"操控设置", -- 973
		marginX, -- 973
		topHeadY, -- 973
		toColor(PALETTE.textBright), -- 973
		0, -- 973
		0.5, -- 973
		"Left", -- 973
		4.5, -- 973
		0.96, -- 973
		0.1 -- 973
	) -- 973
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 全平台支持键鼠 / 触屏 / 手柄" -- 974
	texts:put( -- 975
		"xs", -- 975
		curSummary, -- 975
		marginX + 196, -- 975
		topHeadY - 4, -- 975
		toColor(PALETTE.amberCore), -- 975
		0, -- 975
		0.5, -- 975
		"Left", -- 975
		1.4, -- 975
		0.88, -- 975
		0.08 -- 975
	) -- 975
	drawHairline( -- 976
		uiInkDraw, -- 976
		uiArt, -- 976
		"set_top_line", -- 976
		w * 0.5, -- 976
		topHeadY - 34, -- 976
		w - marginX * 2, -- 976
		PALETTE.silkDim, -- 976
		0.6, -- 976
		true, -- 976
		2 -- 976
	) -- 976
	local panelW = math.min(760, w - marginX * 2) -- 978
	local panelX = (w - panelW) * 0.5 -- 979
	local rowH = 44 -- 980
	local rowStep = 50 -- 981
	local firstY = topHeadY - 104 -- 982
	local boxes = {} -- 984
	local i = 0 -- 985
	do -- 985
		i = 0 -- 986
		while i < #SETTINGS_ROWS do -- 986
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 987
			i = i + 1 -- 986
		end -- 986
	end -- 986
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 989
	local function applyDelta(rowId, delta) -- 991
		if rowId == "back" then -- 992
			return true -- 993
		end -- 993
		if rowId == "modePref" then -- 995
			input:cycleModePref(delta) -- 996
		elseif rowId == "aimAssist" then -- 997
			s.aimAssist = not s.aimAssist -- 998
			saveControlSettings(s) -- 999
		elseif rowId == "gpLayout" then -- 1000
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1001
			input.gamepadLayout = s.gamepadLayout -- 1002
			saveControlSettings(s) -- 1003
		elseif rowId == "crouchMode" then -- 1004
			s.crouchToggle = not s.crouchToggle -- 1005
			saveControlSettings(s) -- 1006
		elseif rowId == "touchOpacity" then -- 1007
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1008
			saveControlSettings(s) -- 1009
		elseif rowId == "touchScale" then -- 1010
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1011
			saveControlSettings(s) -- 1012
		elseif rowId == "haptics" then -- 1013
			s.haptics = not s.haptics -- 1014
			saveControlSettings(s) -- 1015
			if s.haptics then -- 1016
				local ____opt_3 = input:getTouch() -- 1017
				if ____opt_3 ~= nil then -- 1017
					____opt_3:vibrate(0.018) -- 1017
				end -- 1017
			end -- 1017
		end -- 1017
		return false -- 1020
	end -- 991
	local function valueTextOf(rowId) -- 1023
		if rowId == "modePref" then -- 1024
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1025
		end -- 1025
		if rowId == "aimAssist" then -- 1029
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1029
		end -- 1029
		if rowId == "gpLayout" then -- 1030
			return layoutLabelOf(s.gamepadLayout) -- 1030
		end -- 1030
		if rowId == "crouchMode" then -- 1031
			return s.crouchToggle and "点按切换" or "持续按住" -- 1031
		end -- 1031
		if rowId == "touchOpacity" then -- 1032
			return opacityLabelOf(s.touchOpacity) -- 1032
		end -- 1032
		if rowId == "touchScale" then -- 1033
			return scaleLabelOf(s.touchScale) -- 1033
		end -- 1033
		if rowId == "haptics" then -- 1034
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1034
		end -- 1034
		return "" -- 1035
	end -- 1023
	do -- 1023
		i = 0 -- 1038
		while i < #SETTINGS_ROWS do -- 1038
			local row = SETTINGS_ROWS[i + 1] -- 1039
			local box = boxes[i + 1] -- 1040
			local cy = box.y + box.height * 0.5 -- 1041
			local active = self.settingsSelected == i -- 1042
			if active then -- 1044
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1045
				drawSilkRibbon( -- 1046
					uiDraw, -- 1046
					uiArt, -- 1046
					"set_rib_" .. tostring(i), -- 1046
					panelX + panelW * 0.5, -- 1046
					cy, -- 1046
					panelW + 24, -- 1046
					rowH, -- 1046
					PALETTE.rougeSoft, -- 1046
					0.48 * breathe, -- 1046
					0 -- 1046
				) -- 1046
				drawHairline( -- 1047
					uiInkDraw, -- 1047
					uiArt, -- 1047
					"set_line_" .. tostring(i), -- 1047
					panelX + panelW * 0.5, -- 1047
					box.y + 3, -- 1047
					panelW - 24, -- 1047
					PALETTE.silkLine, -- 1047
					0.42 * breathe, -- 1047
					false, -- 1047
					2 -- 1047
				) -- 1047
				drawBlossomDot( -- 1048
					uiInkDraw, -- 1048
					uiArt, -- 1048
					"set_dot_" .. tostring(i), -- 1048
					panelX + 18, -- 1048
					cy, -- 1048
					14, -- 1048
					PALETTE.rouge, -- 1048
					0.96, -- 1048
					4 -- 1048
				) -- 1048
				fillRadialGlow( -- 1049
					uiGlow, -- 1049
					panelX + 18, -- 1049
					cy, -- 1049
					20, -- 1049
					14, -- 1049
					toColor(PALETTE.rouge, 24 * breathe), -- 1049
					Color(182, 58, 56, 0), -- 1049
					10 -- 1049
				) -- 1049
			else -- 1049
				drawBlossomDot( -- 1051
					uiInkDraw, -- 1051
					uiArt, -- 1051
					"set_dot_" .. tostring(i), -- 1051
					panelX + 18, -- 1051
					cy, -- 1051
					7, -- 1051
					PALETTE.silkDim, -- 1051
					0.42, -- 1051
					3 -- 1051
				) -- 1051
			end -- 1051
			texts:put( -- 1054
				"sm", -- 1055
				row.title, -- 1056
				panelX + 42, -- 1057
				cy, -- 1058
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1059
				0, -- 1060
				0.5, -- 1061
				"Left", -- 1062
				active and 2.4 or 1.6, -- 1063
				active and 1 or 0.88, -- 1064
				0.08 -- 1065
			) -- 1065
			local val = valueTextOf(row.id) -- 1068
			if val ~= "" then -- 1069
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1070
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1071
				texts:put( -- 1072
					"sm", -- 1072
					decorated, -- 1072
					panelX + panelW - 24, -- 1072
					cy, -- 1072
					toColor(valCol), -- 1072
					1, -- 1072
					0.5, -- 1072
					"Right", -- 1072
					1, -- 1072
					active and 1 or 0.86, -- 1072
					0.08 -- 1072
				) -- 1072
			end -- 1072
			i = i + 1 -- 1038
		end -- 1038
	end -- 1038
	local backY = 40 + frame.safe.bottom * 0.45 -- 1076
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1077
	texts:put( -- 1082
		"xs", -- 1082
		hint, -- 1082
		w * 0.5, -- 1082
		backY + 14, -- 1082
		toColor(PALETTE.textDim), -- 1082
		0.5, -- 1082
		0.5, -- 1082
		"Center", -- 1082
		1.2, -- 1082
		0.84, -- 1082
		0.08 -- 1082
	) -- 1082
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1084
	if hit >= 0 then -- 1085
		self.settingsSelected = hit -- 1086
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1087
			return true -- 1088
		end -- 1088
		self:resetInput() -- 1090
		return false -- 1091
	end -- 1091
	if frame.keys.left or frame.prevTab then -- 1093
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1094
		if id ~= "back" then -- 1095
			applyDelta(id, -1) -- 1096
			self:resetInput() -- 1097
		end -- 1097
		return false -- 1099
	end -- 1099
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1101
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1102
		if applyDelta(id, 1) then -- 1103
			return true -- 1104
		end -- 1104
		self:resetInput() -- 1106
		return false -- 1107
	end -- 1107
	return false -- 1109
end -- 951
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1117
	if assistHintsEnabled == nil then -- 1128
		assistHintsEnabled = false -- 1128
	end -- 1128
	if safeUi == nil then -- 1130
		safeUi = ZERO_SAFE_INSETS -- 1130
	end -- 1130
	self.time = self.time + dt -- 1132
	local frame = self:readFrame(input, uiScale, safeUi) -- 1133
	if self.pauseShowControls then -- 1135
		local ctrlAct = self:drawControls( -- 1136
			frame, -- 1136
			uiDraw, -- 1136
			uiInkDraw, -- 1136
			uiArt, -- 1136
			uiGlow, -- 1136
			texts, -- 1136
			w, -- 1136
			h, -- 1136
			"返回暂停" -- 1136
		) -- 1136
		if ctrlAct.type == "backTitle" then -- 1137
			self.pauseShowControls = false -- 1138
			self:resetInput() -- 1139
		end -- 1139
		return {type = "none"} -- 1141
	end -- 1141
	if self.pauseShowSettings then -- 1144
		if self:drawPauseSettings( -- 1145
			frame, -- 1145
			input, -- 1145
			uiDraw, -- 1145
			uiInkDraw, -- 1145
			uiArt, -- 1145
			uiGlow, -- 1145
			texts, -- 1145
			w, -- 1145
			h -- 1145
		) then -- 1145
			self.pauseShowSettings = false -- 1146
			self:resetInput() -- 1147
		end -- 1147
		return {type = "none"} -- 1149
	end -- 1149
	if frame.back then -- 1152
		self.pauseShowControls = false -- 1153
		self.pauseShowSettings = false -- 1154
		return {type = "resume"} -- 1155
	end -- 1155
	local allowFs = canToggleFullscreen() -- 1158
	local allowQuit = canQuitApp() -- 1159
	local pauseItems = __TS__ArrayFilter( -- 1160
		PAUSE_ITEMS, -- 1160
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1160
	) -- 1160
	if self.pauseSelected >= #pauseItems then -- 1163
		self.pauseSelected = 0 -- 1164
	end -- 1164
	uiDraw:drawRect( -- 1167
		Rect(0, 0, w, h), -- 1167
		Color(8, 10, 16, 102) -- 1167
	) -- 1167
	fillHGradRect( -- 1168
		uiDraw, -- 1168
		0, -- 1168
		0, -- 1168
		w * 0.27 + frame.safe.left, -- 1168
		h, -- 1168
		Color(9, 11, 18, 232), -- 1168
		Color(10, 13, 21, 198) -- 1168
	) -- 1168
	fillHGradRect( -- 1169
		uiDraw, -- 1169
		w * 0.27 + frame.safe.left, -- 1169
		0, -- 1169
		w * 0.21, -- 1169
		h, -- 1169
		Color(10, 13, 21, 198), -- 1169
		Color(10, 13, 21, 0) -- 1169
	) -- 1169
	local menuX = 110 + frame.safe.left * 0.6 -- 1171
	local compact = #pauseItems > 8 -- 1172
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1173
	uiArt:tryPlace( -- 1174
		"ink_vstream", -- 1174
		"pause_vstream", -- 1174
		menuX - 32, -- 1174
		h * 0.5, -- 1174
		34, -- 1174
		h * 0.78, -- 1174
		{ -- 1174
			color = toColor(PALETTE.silkDim), -- 1175
			opacity = 0.48, -- 1175
			layer = 1 -- 1175
		} -- 1175
	) -- 1175
	drawMistCurve( -- 1177
		uiArt, -- 1177
		"pause_mist", -- 1177
		menuX + 118, -- 1177
		headY - 8, -- 1177
		290, -- 1177
		72, -- 1177
		PALETTE.jadeMist, -- 1177
		0.2, -- 1177
		-1 -- 1177
	) -- 1177
	texts:put( -- 1179
		"banner", -- 1179
		"暂歇", -- 1179
		menuX + 16, -- 1179
		headY, -- 1179
		toColor(PALETTE.textBright), -- 1179
		0, -- 1179
		0.5, -- 1179
		"Left", -- 1179
		10, -- 1179
		0.98, -- 1179
		0.1 -- 1179
	) -- 1179
	texts:put( -- 1180
		"xs", -- 1180
		"月夜暂驻 · 卷页留痕", -- 1180
		menuX + 18, -- 1180
		headY - 36, -- 1180
		toColor(PALETTE.textDim), -- 1180
		0, -- 1180
		0.5, -- 1180
		"Left", -- 1180
		2, -- 1180
		0.8, -- 1180
		0.08 -- 1180
	) -- 1180
	drawHairline( -- 1181
		uiInkDraw, -- 1181
		uiArt, -- 1181
		"pause_div", -- 1181
		menuX + 124, -- 1181
		headY - 60, -- 1181
		240, -- 1181
		PALETTE.silkDim, -- 1181
		0.58, -- 1181
		true, -- 1181
		2 -- 1181
	) -- 1181
	local rowStep = compact and 42 or 46 -- 1183
	local rowH = compact and 36 or 38 -- 1184
	local firstY = compact and headY - 112 or headY - 120 -- 1185
	local boxes = {} -- 1186
	local i = 0 -- 1187
	do -- 1187
		i = 0 -- 1188
		while i < #pauseItems do -- 1188
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1189
			i = i + 1 -- 1188
		end -- 1188
	end -- 1188
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1191
	do -- 1191
		i = 0 -- 1193
		while i < #pauseItems do -- 1193
			local iy = boxes[i + 1].y -- 1194
			local active = self.pauseSelected == i -- 1195
			local cy = iy + rowH * 0.5 -- 1196
			local shiftX = active and 10 or 0 -- 1197
			local item = pauseItems[i + 1] -- 1198
			local label = item.zh -- 1199
			if item.id == "assist" then -- 1200
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1201
			elseif item.id == "fullscreen" then -- 1202
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1203
			elseif item.id == "settings" then -- 1204
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1205
			end -- 1205
			if active then -- 1208
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1209
				drawSilkRibbon( -- 1210
					uiDraw, -- 1210
					uiArt, -- 1210
					"pause_rib_" .. tostring(i), -- 1210
					menuX + 116, -- 1210
					cy, -- 1210
					282, -- 1210
					rowH, -- 1210
					PALETTE.rougeSoft, -- 1210
					0.54 * breathe, -- 1210
					0 -- 1210
				) -- 1210
				drawHairline( -- 1211
					uiInkDraw, -- 1211
					uiArt, -- 1211
					"pause_line_" .. tostring(i), -- 1211
					menuX + 106, -- 1211
					iy + 3, -- 1211
					210, -- 1211
					PALETTE.silkLine, -- 1211
					0.42 * breathe, -- 1211
					false, -- 1211
					2 -- 1211
				) -- 1211
				drawBlossomDot( -- 1212
					uiInkDraw, -- 1212
					uiArt, -- 1212
					"pause_dot_" .. tostring(i), -- 1212
					menuX + 12, -- 1212
					cy, -- 1212
					15, -- 1212
					PALETTE.rouge, -- 1212
					0.96, -- 1212
					4 -- 1212
				) -- 1212
				fillRadialGlow( -- 1213
					uiGlow, -- 1213
					menuX + 12, -- 1213
					cy, -- 1213
					22, -- 1213
					16, -- 1213
					toColor(PALETTE.rouge, 26 * breathe), -- 1213
					Color(182, 58, 56, 0), -- 1213
					10 -- 1213
				) -- 1213
			else -- 1213
				drawBlossomDot( -- 1215
					uiInkDraw, -- 1215
					uiArt, -- 1215
					"pause_dot_" .. tostring(i), -- 1215
					menuX + 12, -- 1215
					cy, -- 1215
					8, -- 1215
					PALETTE.silkDim, -- 1215
					0.4, -- 1215
					3 -- 1215
				) -- 1215
			end -- 1215
			texts:put( -- 1218
				compact and "sm" or "md", -- 1219
				label, -- 1220
				menuX + 32 + shiftX, -- 1221
				cy, -- 1222
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1223
				0, -- 1224
				0.5, -- 1225
				"Left", -- 1226
				active and 3.4 or 2.2, -- 1227
				active and 1 or 0.88, -- 1228
				0.1 -- 1229
			) -- 1229
			i = i + 1 -- 1193
		end -- 1193
	end -- 1193
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1233
	texts:put( -- 1238
		"xs", -- 1238
		pauseFooter, -- 1238
		menuX + 12, -- 1238
		38 + frame.safe.bottom * 0.4, -- 1238
		toColor(PALETTE.textDim), -- 1238
		0, -- 1238
		0.5, -- 1238
		"Left", -- 1238
		1.2, -- 1238
		0.86, -- 1238
		0.08 -- 1238
	) -- 1238
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1240
	if hit >= 0 or frame.keys.confirm then -- 1241
		local idx = hit >= 0 and hit or self.pauseSelected -- 1242
		local id = pauseItems[idx + 1].id -- 1243
		if id == "controls" then -- 1244
			self.pauseShowControls = true -- 1245
			self:resetInput() -- 1246
			return {type = "none"} -- 1247
		end -- 1247
		if id == "settings" then -- 1249
			self:openPauseSettings() -- 1250
			return {type = "none"} -- 1251
		end -- 1251
		if id == "assist" then -- 1253
			if onToggleAssist ~= nil then -- 1254
				onToggleAssist() -- 1255
			end -- 1255
			self:resetInput() -- 1257
			return {type = "none"} -- 1258
		end -- 1258
		if id == "fullscreen" then -- 1260
			self:resetInput() -- 1261
			return {type = "toggleFullscreen"} -- 1262
		end -- 1262
		self.pauseShowControls = false -- 1264
		self.pauseShowSettings = false -- 1265
		if id == "resume" then -- 1266
			return {type = "resume"} -- 1266
		end -- 1266
		if id == "retry" then -- 1267
			return {type = "retry"} -- 1267
		end -- 1267
		if id == "chapters" then -- 1268
			return {type = "openChapters"} -- 1268
		end -- 1268
		if id == "quit" then -- 1269
			return {type = "quit"} -- 1269
		end -- 1269
		return {type = "toTitle"} -- 1270
	end -- 1270
	return {type = "none"} -- 1272
end -- 1117
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1279
	if frame.back then -- 1289
		return {type = "backTitle"} -- 1290
	end -- 1290
	uiDraw:drawRect( -- 1294
		Rect(0, 0, w, h), -- 1294
		Color(7, 9, 15, 214) -- 1294
	) -- 1294
	local cx = w * 0.5 -- 1295
	local reunion = self.epilogueEnding == "reunion" -- 1296
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1297
	drawMistCurve( -- 1298
		uiArt, -- 1298
		"ep_mist", -- 1298
		cx, -- 1298
		h * 0.62, -- 1298
		620, -- 1298
		120, -- 1298
		accentCol, -- 1298
		0.2, -- 1298
		0 -- 1298
	) -- 1298
	fillRadialGlow( -- 1299
		uiGlow, -- 1299
		cx, -- 1299
		h * 0.68, -- 1299
		220, -- 1299
		140, -- 1299
		toColor(accentCol, 28), -- 1299
		Color(10, 14, 22, 0), -- 1299
		18 -- 1299
	) -- 1299
	local titleY = h * 0.72 -- 1302
	texts:put( -- 1303
		"title", -- 1303
		"向西守望", -- 1303
		cx - 18, -- 1303
		titleY, -- 1303
		toColor(PALETTE.textBright), -- 1303
		0.5, -- 1303
		0.5, -- 1303
		"Center", -- 1303
		12, -- 1303
		0.98, -- 1303
		0.12 -- 1303
	) -- 1303
	drawLoneSeal( -- 1304
		uiInkDraw, -- 1304
		uiArt, -- 1304
		texts, -- 1304
		"ep_seal", -- 1304
		cx + 148, -- 1304
		titleY - 2, -- 1304
		24, -- 1304
		46, -- 1304
		"守", -- 1304
		"望", -- 1304
		PALETTE.sealRed, -- 1304
		PALETTE.sealText, -- 1304
		0.94, -- 1304
		4 -- 1304
	) -- 1304
	drawHairline( -- 1305
		uiInkDraw, -- 1305
		uiArt, -- 1305
		"ep_div", -- 1305
		cx, -- 1305
		titleY - 46, -- 1305
		360, -- 1305
		PALETTE.silkDim, -- 1305
		0.62, -- 1305
		true, -- 1305
		2 -- 1305
	) -- 1305
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1307
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1308
	texts:put( -- 1311
		"md", -- 1311
		endingTitle, -- 1311
		cx, -- 1311
		titleY - 76, -- 1311
		toColor(PALETTE.amberCore), -- 1311
		0.5, -- 1311
		0.5, -- 1311
		"Center", -- 1311
		3.2, -- 1311
		0.96, -- 1311
		0.08 -- 1311
	) -- 1311
	texts:put( -- 1312
		"sm", -- 1312
		verse, -- 1312
		cx, -- 1312
		titleY - 114, -- 1312
		toColor(PALETTE.textMid), -- 1312
		0.5, -- 1312
		0.5, -- 1312
		"Center", -- 1312
		1, -- 1312
		0.92, -- 1312
		0.08 -- 1312
	) -- 1312
	if self.epilogueBothCleared then -- 1314
		drawSilkVeil( -- 1315
			uiDraw, -- 1315
			uiArt, -- 1315
			"ep_well_veil", -- 1315
			cx, -- 1315
			titleY - 152, -- 1315
			560, -- 1315
			30, -- 1315
			PALETTE.inkWarm, -- 1315
			0.68, -- 1315
			0 -- 1315
		) -- 1315
		texts:put( -- 1316
			"xs", -- 1316
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1316
			cx, -- 1316
			titleY - 152, -- 1316
			toColor(PALETTE.cyanCore), -- 1316
			0.5, -- 1316
			0.5, -- 1316
			"Center", -- 1316
			1, -- 1316
			0.9, -- 1316
			0.08 -- 1316
		) -- 1316
	end -- 1316
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1319
	local btnW = 286 -- 1324
	local btnH = 44 -- 1325
	local gap = 14 -- 1326
	local baseY = math.max(150, h * 0.34) -- 1327
	local boxes = {} -- 1328
	local i = 0 -- 1329
	do -- 1329
		i = 0 -- 1330
		while i < #items do -- 1330
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1331
			i = i + 1 -- 1330
		end -- 1330
	end -- 1330
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1333
	do -- 1333
		i = 0 -- 1335
		while i < #items do -- 1335
			local box = boxes[i + 1] -- 1336
			local active = self.epilogueSelected == i -- 1337
			local cy = box.y + box.height * 0.5 -- 1338
			if active then -- 1339
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1340
				drawSilkRibbon( -- 1341
					uiDraw, -- 1341
					uiArt, -- 1341
					"ep_rib_" .. tostring(i), -- 1341
					cx, -- 1341
					cy, -- 1341
					btnW + 24, -- 1341
					btnH, -- 1341
					PALETTE.rougeSoft, -- 1341
					0.62 * breathe, -- 1341
					0 -- 1341
				) -- 1341
				drawHairline( -- 1342
					uiInkDraw, -- 1342
					uiArt, -- 1342
					"ep_line_" .. tostring(i), -- 1342
					cx, -- 1342
					box.y + 3, -- 1342
					btnW - 44, -- 1342
					PALETTE.silkLine, -- 1342
					0.48 * breathe, -- 1342
					false, -- 1342
					2 -- 1342
				) -- 1342
				drawBlossomDot( -- 1343
					uiInkDraw, -- 1343
					uiArt, -- 1343
					"ep_dot_" .. tostring(i), -- 1343
					box.x + 22, -- 1343
					cy, -- 1343
					13, -- 1343
					PALETTE.rouge, -- 1343
					0.96, -- 1343
					4 -- 1343
				) -- 1343
			else -- 1343
				drawSilkVeil( -- 1345
					uiDraw, -- 1345
					uiArt, -- 1345
					"ep_idle_" .. tostring(i), -- 1345
					cx, -- 1345
					cy, -- 1345
					btnW, -- 1345
					btnH - 2, -- 1345
					PALETTE.inkWash, -- 1345
					0.58, -- 1345
					0 -- 1345
				) -- 1345
				drawBlossomDot( -- 1346
					uiInkDraw, -- 1346
					uiArt, -- 1346
					"ep_dot_" .. tostring(i), -- 1346
					box.x + 22, -- 1346
					cy, -- 1346
					8, -- 1346
					PALETTE.silkDim, -- 1346
					0.42, -- 1346
					3 -- 1346
				) -- 1346
			end -- 1346
			texts:put( -- 1348
				"sm", -- 1349
				items[i + 1].zh, -- 1350
				cx + 6, -- 1351
				cy, -- 1352
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1353
				0.5, -- 1354
				0.5, -- 1355
				"Center", -- 1356
				active and 2.6 or 1.6, -- 1357
				active and 1 or 0.88, -- 1358
				0.08 -- 1359
			) -- 1359
			i = i + 1 -- 1335
		end -- 1335
	end -- 1335
	local footer = frame.mode == "gamepad" and ((keyTagFor("confirm", "gamepad", frame.layout) .. " 确认   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回标题" or (frame.mode == "touch" and "轻触任一入口继续" or "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题") -- 1363
	texts:put( -- 1366
		"xs", -- 1366
		footer, -- 1366
		cx, -- 1366
		38 + frame.safe.bottom * 0.4, -- 1366
		toColor(PALETTE.textDim), -- 1366
		0.5, -- 1366
		0.5, -- 1366
		"Center", -- 1366
		1.2, -- 1366
		0.84, -- 1366
		0.08 -- 1366
	) -- 1366
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1368
	if hit >= 0 or frame.keys.confirm then -- 1369
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1370
		local id = items[idx + 1].id -- 1371
		if id == "history" then -- 1372
			return {type = "openHistory"} -- 1372
		end -- 1372
		if id == "replay" then -- 1373
			return {type = "replayStory"} -- 1373
		end -- 1373
		return {type = "backTitle"} -- 1374
	end -- 1374
	return {type = "none"} -- 1376
end -- 1279
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1383
	if frame.back then -- 1393
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1394
	end -- 1394
	local total = #HISTORY_CARDS -- 1397
	if frame.keys.left or frame.prevTab then -- 1398
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1399
	elseif frame.keys.right or frame.nextTab then -- 1400
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1401
	end -- 1401
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1403
	uiDraw:drawRect( -- 1405
		Rect(0, 0, w, h), -- 1405
		Color(7, 9, 15, 206) -- 1405
	) -- 1405
	local cx = w * 0.5 -- 1406
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1407
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1408
	local px = cx - pageW * 0.5 -- 1409
	local py = (h - pageH) * 0.5 + 14 -- 1410
	local midY = py + pageH * 0.5 -- 1411
	uiArt:tryPlace( -- 1413
		"ink_frame_mask", -- 1413
		"hist_shadow", -- 1413
		cx, -- 1413
		midY - 6, -- 1413
		pageW + 52, -- 1413
		pageH + 46, -- 1413
		{ -- 1413
			color = toColor(PALETTE.voidDark), -- 1414
			opacity = 0.84, -- 1414
			layer = -1 -- 1414
		} -- 1414
	) -- 1414
	if not uiArt:tryPlace( -- 1416
		"ink_song_paper", -- 1416
		"hist_paper", -- 1416
		cx, -- 1416
		midY, -- 1416
		pageW, -- 1416
		pageH, -- 1416
		{opacity = 0.98, layer = 1} -- 1416
	) then -- 1416
		uiDraw:drawRect( -- 1417
			Rect(px, py, pageW, pageH), -- 1417
			toColor(PALETTE.xuanPaper, 248), -- 1417
			1, -- 1417
			toColor(PALETTE.silkDim, 180) -- 1417
		) -- 1417
	end -- 1417
	fillRadialGlow( -- 1419
		uiGlow, -- 1419
		cx, -- 1419
		midY + 40, -- 1419
		260, -- 1419
		140, -- 1419
		Color(236, 224, 202, 16), -- 1419
		Color(236, 224, 202, 0), -- 1419
		14 -- 1419
	) -- 1419
	local inX = px + 42 -- 1422
	local inY = py + 32 -- 1423
	local inW = pageW - 84 -- 1424
	local inH = pageH - 64 -- 1425
	local redSilk = toColor(PALETTE.rouge, 118) -- 1426
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1427
	uiInkDraw:drawRect( -- 1428
		Rect(inX, inY, inW, inH), -- 1428
		Color(0, 0, 0, 0), -- 1428
		0.95, -- 1428
		redSilk -- 1428
	) -- 1428
	uiInkDraw:drawRect( -- 1429
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1429
		Color(0, 0, 0, 0), -- 1429
		0.55, -- 1429
		redSilkFaint -- 1429
	) -- 1429
	local headY = inY + inH - 30 -- 1432
	texts:put( -- 1433
		"md", -- 1433
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1433
		inX + 20, -- 1433
		headY, -- 1433
		toColor(PALETTE.xuanInk), -- 1433
		0, -- 1433
		0.5, -- 1433
		"Left", -- 1433
		2, -- 1433
		0.96, -- 1433
		0 -- 1433
	) -- 1433
	texts:put( -- 1434
		"xs", -- 1434
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1434
		inX + inW - 20, -- 1434
		headY, -- 1434
		toColor(PALETTE.rouge), -- 1434
		1, -- 1434
		0.5, -- 1434
		"Right", -- 1434
		1.8, -- 1434
		0.88, -- 1434
		0 -- 1434
	) -- 1434
	uiInkDraw:drawSegment( -- 1435
		Vec2(inX + 14, headY - 22), -- 1435
		Vec2(inX + inW - 14, headY - 22), -- 1435
		0.85, -- 1435
		redSilk -- 1435
	) -- 1435
	texts:put( -- 1438
		"xs", -- 1438
		card.subtitle, -- 1438
		inX + 20, -- 1438
		headY - 42, -- 1438
		toColor(PALETTE.xuanInkSub), -- 1438
		0, -- 1438
		0.5, -- 1438
		"Left", -- 1438
		1.4, -- 1438
		0.86, -- 1438
		0 -- 1438
	) -- 1438
	local function wrapZh(src, maxUnits) -- 1441
		local out = {} -- 1442
		local buf = "" -- 1443
		local units = 0 -- 1444
		local ci = 0 -- 1445
		while ci < #src do -- 1446
			local b = __TS__StringCharCodeAt(src, ci) -- 1447
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1448
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1449
			local u = b < 128 and 0.56 or 1.02 -- 1450
			if units + u > maxUnits and buf ~= "" then -- 1451
				out[#out + 1] = buf -- 1452
				buf = ch -- 1453
				units = u -- 1454
			else -- 1454
				buf = buf .. ch -- 1456
				units = units + u -- 1457
			end -- 1457
			ci = ci + step -- 1459
		end -- 1459
		if buf ~= "" then -- 1461
			out[#out + 1] = buf -- 1462
		end -- 1462
		return out -- 1464
	end -- 1441
	local charsPerLine = math.max( -- 1467
		24, -- 1467
		math.floor((inW - 44) / 20) -- 1467
	) -- 1467
	local cursorY = headY - 76 -- 1468
	local pi = 0 -- 1469
	do -- 1469
		pi = 0 -- 1470
		while pi < #card.paragraphs do -- 1470
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1471
			local li = 0 -- 1472
			do -- 1472
				li = 0 -- 1473
				while li < #lines do -- 1473
					texts:put( -- 1474
						"sm", -- 1474
						lines[li + 1], -- 1474
						inX + 22, -- 1474
						cursorY, -- 1474
						toColor(PALETTE.xuanInk), -- 1474
						0, -- 1474
						0.5, -- 1474
						"Left", -- 1474
						0.6, -- 1474
						0.94, -- 1474
						0 -- 1474
					) -- 1474
					cursorY = cursorY - 30 -- 1475
					li = li + 1 -- 1473
				end -- 1473
			end -- 1473
			cursorY = cursorY - 12 -- 1477
			pi = pi + 1 -- 1470
		end -- 1470
	end -- 1470
	local footY = inY + 26 -- 1481
	uiInkDraw:drawSegment( -- 1482
		Vec2(inX + 14, footY + 20), -- 1482
		Vec2(inX + inW - 14, footY + 20), -- 1482
		0.6, -- 1482
		redSilkFaint -- 1482
	) -- 1482
	texts:put( -- 1483
		"xs", -- 1483
		card.footnote, -- 1483
		inX + 20, -- 1483
		footY, -- 1483
		toColor(PALETTE.xuanInkSub), -- 1483
		0, -- 1483
		0.5, -- 1483
		"Left", -- 1483
		0.4, -- 1483
		0.84, -- 1483
		0 -- 1483
	) -- 1483
	local navY = math.max(30, py - 48) -- 1486
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1487
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1488
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1489
	local function drawNavBtn(box, tag, label) -- 1491
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1492
		drawSilkVeil( -- 1493
			uiDraw, -- 1493
			uiArt, -- 1493
			"hist_btn_" .. tag, -- 1493
			box.x + box.width * 0.5, -- 1493
			box.y + box.height * 0.5, -- 1493
			box.width, -- 1493
			box.height, -- 1493
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1493
			hover and 0.86 or 0.72, -- 1493
			2 -- 1493
		) -- 1493
		texts:put( -- 1494
			"xs", -- 1494
			label, -- 1494
			box.x + box.width * 0.5, -- 1494
			box.y + box.height * 0.5, -- 1494
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1494
			0.5, -- 1494
			0.5, -- 1494
			"Center", -- 1494
			1.4, -- 1494
			0.94, -- 1494
			0.08 -- 1494
		) -- 1494
		return hover and frame.click -- 1495
	end -- 1491
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1498
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1499
	end -- 1499
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1501
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1502
	end -- 1502
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1504
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1505
	end -- 1505
	if frame.keys.confirm then -- 1508
		if self.historyCardIndex + 1 < total then -- 1509
			self.historyCardIndex = self.historyCardIndex + 1 -- 1510
		else -- 1510
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1512
		end -- 1512
	end -- 1512
	return {type = "none"} -- 1515
end -- 1383
return ____exports -- 1383
