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
local VOLUME_STEPS = ____controls_config.VOLUME_STEPS -- 19
local inputModeLabelOf = ____controls_config.inputModeLabelOf -- 20
local layoutLabelOf = ____controls_config.layoutLabelOf -- 21
local modePrefLabelOf = ____controls_config.modePrefLabelOf -- 22
local nextStepValue = ____controls_config.nextStepValue -- 23
local opacityLabelOf = ____controls_config.opacityLabelOf -- 24
local saveControlSettings = ____controls_config.saveControlSettings -- 25
local scaleLabelOf = ____controls_config.scaleLabelOf -- 26
local volumeLabelOf = ____controls_config.volumeLabelOf -- 27
local ____platform = require("Script.watch.platform") -- 29
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 31
local canQuitApp = ____platform.canQuitApp -- 32
local canToggleFullscreen = ____platform.canToggleFullscreen -- 33
local getPlatformCaps = ____platform.getPlatformCaps -- 34
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 36
local controlsGuideRows = ____control_prompts.controlsGuideRows -- 36
local keyTagFor = ____control_prompts.keyTagFor -- 36
local ____dialogues = require("Script.watch.dialogues") -- 37
local HISTORY_CARDS = ____dialogues.HISTORY_CARDS -- 37
local ____theme = require("Script.watch.fe.theme") -- 41
local PALETTE = ____theme.PALETTE -- 42
local drawBlossomDot = ____theme.drawBlossomDot -- 43
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 44
local drawHairline = ____theme.drawHairline -- 45
local drawLoneSeal = ____theme.drawLoneSeal -- 46
local drawMistCurve = ____theme.drawMistCurve -- 47
local drawSilkKeycap = ____theme.drawSilkKeycap -- 48
local drawSilkRibbon = ____theme.drawSilkRibbon -- 49
local drawSilkVeil = ____theme.drawSilkVeil -- 50
local fillHGradRect = ____theme.fillHGradRect -- 51
local fillRadialGlow = ____theme.fillRadialGlow -- 52
local fillVGradRect = ____theme.fillVGradRect -- 53
local themeOf = ____theme.themeOf -- 54
local toColor = ____theme.toColor -- 55
local visualTextWidth = ____theme.visualTextWidth -- 56
local TITLE_ITEMS = { -- 86
	{id = "start", zh = "开始游戏"}, -- 87
	{id = "chapters", zh = "选择章节"}, -- 88
	{id = "controls", zh = "操作说明"}, -- 89
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 90
	{id = "quit", zh = "退出游戏"} -- 91
} -- 91
local CHAPTERS = __TS__ArrayFilter( -- 95
	__TS__ArrayMap( -- 95
		ROOMS, -- 95
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 95
	), -- 95
	function(____, chapter) return chapter.room.key ~= "museum" and chapter.room.key ~= "street" and chapter.room.key ~= "checkpoint" end -- 96
) -- 96
local PAUSE_ITEMS = { -- 99
	{id = "resume", zh = "继续游戏"}, -- 100
	{id = "retry", zh = "重试检查点"}, -- 101
	{id = "controls", zh = "操作说明"}, -- 102
	{id = "assist", zh = "按键辅助：关"}, -- 103
	{id = "fullscreen", zh = "显示：窗口"}, -- 104
	{id = "chapters", zh = "选择章节"}, -- 105
	{id = "title", zh = "返回标题"}, -- 106
	{id = "quit", zh = "退出游戏"}, -- 107
	{id = "settings", zh = "操控设置"}, -- 108
	{id = "ledger", zh = "行军札记"} -- 109
} -- 109
local SETTINGS_ROWS = { -- 113
	{id = "modePref", title = "操作模式"}, -- 114
	{id = "aimAssist", title = "瞄准磁吸"}, -- 115
	{id = "gpLayout", title = "手柄确认键"}, -- 116
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 117
	{id = "touchOpacity", title = "触控按键透度"}, -- 118
	{id = "touchScale", title = "触控按键大小"}, -- 119
	{id = "haptics", title = "触觉震动反馈"}, -- 120
	{id = "masterVol", title = "主音量"}, -- 121
	{id = "bgmVol", title = "音乐音量"}, -- 122
	{id = "sfxVol", title = "音效与环境"}, -- 123
	{id = "voiceVol", title = "人声音量"}, -- 124
	{id = "back", title = "返回暂歇菜单"} -- 125
} -- 125
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 128
local EPIGRAPH_RIGHT = { -- 129
	"城", -- 129
	"破", -- 129
	"那", -- 129
	"天", -- 129
	"", -- 129
	"他", -- 129
	"留", -- 129
	"下", -- 129
	"断", -- 129
	"后" -- 129
} -- 129
local EPIGRAPH_LEFT = { -- 130
	"她", -- 130
	"独", -- 130
	"自", -- 130
	"走", -- 130
	"向", -- 130
	"北", -- 130
	"塔" -- 130
} -- 130
local function pressedKeys() -- 155
	return { -- 156
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 157
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 158
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 159
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 160
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 161
	} -- 161
end -- 155
local function hitIndex(boxes, pointer, inside) -- 165
	if not inside then -- 166
		return -1 -- 167
	end -- 167
	return __TS__ArrayFindIndex( -- 169
		boxes, -- 169
		function(____, box) return box:containsPoint(pointer) end -- 169
	) -- 169
end -- 165
____exports.MenuRenderer = __TS__Class() -- 172
local MenuRenderer = ____exports.MenuRenderer -- 172
MenuRenderer.name = "MenuRenderer" -- 172
function MenuRenderer.prototype.____constructor(self) -- 172
	self.selected = 0 -- 173
	self.chapterSelected = 0 -- 174
	self.pauseSelected = 0 -- 175
	self.settingsSelected = 0 -- 176
	self.epilogueSelected = 0 -- 177
	self.epilogueEnding = "lamp" -- 178
	self.epilogueBothCleared = false -- 179
	self.historyCardIndex = 0 -- 180
	self.historyFromEpilogue = false -- 181
	self.hasSession = false -- 183
	self.controlsTab = "kbm" -- 185
	self.chaptersFromPause = false -- 197
	self.pauseShowControls = false -- 198
	self.pauseShowSettings = false -- 199
	self.controlsTabManual = false -- 200
	self.previousKeys = {} -- 201
	self.queuedKeys = {} -- 202
	self.queuedBack = false -- 203
	self.queuedSkip = false -- 204
	self.splashTime = 0 -- 205
	self.time = 0 -- 206
end -- 172
function MenuRenderer.prototype.emitSound(self, kind) -- 191
	if self.onUiSound ~= nil then -- 192
		self:onUiSound(kind) -- 193
	end -- 193
end -- 191
function MenuRenderer.prototype.resetSplash(self) -- 208
	self.splashTime = 0 -- 209
	self.queuedSkip = false -- 210
	self:resetInput() -- 211
end -- 208
function MenuRenderer.prototype.isShowingPauseControls(self) -- 214
	return self.pauseShowControls -- 215
end -- 214
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 218
	return self.pauseShowSettings -- 219
end -- 218
function MenuRenderer.prototype.openPauseSettings(self) -- 222
	self.pauseShowControls = false -- 223
	self.pauseShowSettings = true -- 224
	self.settingsSelected = 0 -- 225
	self:resetInput() -- 226
end -- 222
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 229
	self.chaptersFromPause = roomIndex ~= nil -- 230
	self.chapterSelected = math.max( -- 231
		0, -- 231
		__TS__ArrayFindIndex( -- 231
			CHAPTERS, -- 231
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 231
		) -- 231
	) -- 231
	self.pauseShowControls = false -- 232
	self.pauseShowSettings = false -- 233
	self:resetInput() -- 234
end -- 229
function MenuRenderer.prototype.openPause(self) -- 237
	self.pauseSelected = 0 -- 238
	self.pauseShowControls = false -- 239
	self.pauseShowSettings = false -- 240
	self:resetInput() -- 241
end -- 237
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 244
	if ending == nil then -- 244
		ending = "lamp" -- 244
	end -- 244
	if bothCleared == nil then -- 244
		bothCleared = false -- 244
	end -- 244
	self.epilogueEnding = ending -- 245
	self.epilogueBothCleared = bothCleared -- 246
	self.epilogueSelected = 0 -- 247
	self:resetInput() -- 248
end -- 244
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 251
	if fromEpilogue == nil then -- 251
		fromEpilogue = true -- 251
	end -- 251
	self.historyFromEpilogue = fromEpilogue -- 252
	self.historyCardIndex = 0 -- 253
	self:resetInput() -- 254
end -- 251
function MenuRenderer.prototype.triggerBack(self) -- 258
	self.queuedBack = true -- 259
end -- 258
function MenuRenderer.prototype.resetInput(self) -- 263
	self.previousKeys = pressedKeys() -- 264
	self.queuedKeys = {} -- 265
	self.queuedBack = false -- 266
	self.queuedSkip = false -- 267
	self.controlsTabManual = false -- 268
end -- 263
function MenuRenderer.prototype.onKeyEvent(self, key) -- 272
	self.queuedSkip = true -- 273
	if key == "Up" or key == "W" then -- 274
		self.queuedKeys.up = true -- 275
	elseif key == "Down" or key == "S" then -- 276
		self.queuedKeys.down = true -- 277
	elseif key == "Left" or key == "A" then -- 278
		self.queuedKeys.left = true -- 279
	elseif key == "Right" or key == "D" then -- 280
		self.queuedKeys.right = true -- 281
	elseif key == "Return" or key == "Space" then -- 282
		self.queuedKeys.confirm = true -- 283
	elseif key == "Escape" then -- 284
		self.queuedBack = true -- 285
	end -- 285
end -- 272
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 289
	local held = pressedKeys() -- 290
	local prev = self.previousKeys -- 291
	local queued = self.queuedKeys -- 292
	local useUiPtr = input.uiInside or input.uiPressed -- 295
	local rawX = useUiPtr and input.uiX or input.mx -- 296
	local rawY = useUiPtr and input.uiY or input.my -- 297
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 298
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 299
	local ____useUiPtr_0 -- 300
	if useUiPtr then -- 300
		____useUiPtr_0 = input.uiInside -- 300
	else -- 300
		____useUiPtr_0 = input.inside -- 300
	end -- 300
	local inside = ____useUiPtr_0 -- 300
	local ____useUiPtr_1 -- 301
	if useUiPtr then -- 301
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 301
	else -- 301
		____useUiPtr_1 = input.inside and input.fire.pressed -- 301
	end -- 301
	local click = ____useUiPtr_1 -- 301
	local touchMode = input:isTouchMode() -- 302
	local frame = { -- 304
		keys = { -- 305
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 306
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 307
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 308
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 309
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 310
		}, -- 310
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 312
		prevTab = input.navPrevTab, -- 313
		nextTab = input.navNextTab, -- 314
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 315
		pointer = Vec2(rawX / scale, rawY / scale), -- 316
		inside = inside, -- 317
		click = click, -- 318
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 319
		mode = input.inputMode, -- 320
		layout = input.gamepadLayout, -- 321
		safe = safe -- 322
	} -- 322
	self.previousKeys = held -- 324
	self.queuedKeys = {} -- 325
	self.queuedBack = false -- 326
	self.queuedSkip = false -- 327
	return frame -- 328
end -- 289
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 331
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 332
	if frame.click and hit >= 0 then -- 333
		return hit -- 334
	end -- 334
	if frame.keys.up then -- 336
		return (selected + #boxes - 1) % #boxes -- 337
	end -- 337
	if frame.keys.down then -- 339
		return (selected + 1) % #boxes -- 340
	end -- 340
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 342
end -- 331
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 345
	if safeUi == nil then -- 361
		safeUi = ZERO_SAFE_INSETS -- 361
	end -- 361
	self.time = self.time + dt -- 363
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 364
	if screen ~= "splash" or splashDissolving then -- 365
		local artW = math.max(w, h * 16 / 9) -- 366
		local artH = artW * 9 / 16 -- 367
		if not backdropArt:tryPlace( -- 368
			"title_backdrop", -- 368
			"menu_landscape", -- 368
			w * 0.5, -- 368
			(h - artH) * 0.5, -- 368
			artW, -- 368
			artH -- 368
		) then -- 368
			stage:drawMenuBackdrop( -- 369
				bgDraw, -- 369
				bgGlow, -- 369
				w, -- 369
				h, -- 369
				self.time -- 369
			) -- 369
		end -- 369
	end -- 369
	local frame = self:readFrame(input, uiScale, safeUi) -- 373
	w = w / uiScale -- 374
	h = h / uiScale -- 375
	if screen == "splash" then -- 377
		return self:drawSplash( -- 378
			dt, -- 378
			frame, -- 378
			uiDraw, -- 378
			uiArt, -- 378
			texts, -- 378
			w, -- 378
			h -- 378
		) -- 378
	end -- 378
	if screen == "title" then -- 380
		return self:drawTitle( -- 381
			frame, -- 381
			uiDraw, -- 381
			uiInkDraw, -- 381
			uiArt, -- 381
			uiGlow, -- 381
			texts, -- 381
			w, -- 381
			h -- 381
		) -- 381
	end -- 381
	if screen == "chapters" then -- 383
		return self:drawChapters( -- 384
			frame, -- 384
			uiDraw, -- 384
			uiInkDraw, -- 384
			uiArt, -- 384
			uiGlow, -- 384
			texts, -- 384
			w, -- 384
			h -- 384
		) -- 384
	end -- 384
	if screen == "epilogue" then -- 386
		return self:drawEpilogue( -- 387
			frame, -- 387
			uiDraw, -- 387
			uiInkDraw, -- 387
			uiArt, -- 387
			uiGlow, -- 387
			texts, -- 387
			w, -- 387
			h -- 387
		) -- 387
	end -- 387
	if screen == "history" then -- 389
		return self:drawHistory( -- 390
			frame, -- 390
			uiDraw, -- 390
			uiInkDraw, -- 390
			uiArt, -- 390
			uiGlow, -- 390
			texts, -- 390
			w, -- 390
			h -- 390
		) -- 390
	end -- 390
	return self:drawControls( -- 392
		frame, -- 392
		uiDraw, -- 392
		uiInkDraw, -- 392
		uiArt, -- 392
		uiGlow, -- 392
		texts, -- 392
		w, -- 392
		h -- 392
	) -- 392
end -- 345
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 401
	local safeDt = math.min( -- 410
		0.1, -- 410
		math.max(0, dt) -- 410
	) -- 410
	self.splashTime = self.splashTime + safeDt -- 411
	local t = self.splashTime -- 412
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 414
	if wantSkip or t >= 4.65 then -- 415
		self.splashTime = 0 -- 416
		return {type = "splashDone"} -- 417
	end -- 417
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 420
	local bgR = t < 2.2 and 13 or 11 -- 421
	local bgG = t < 2.2 and 16 or 13 -- 422
	local bgB = t < 2.2 and 24 or 19 -- 423
	uiDraw:drawRect( -- 424
		Rect(0, 0, w, h), -- 424
		Color( -- 424
			bgR, -- 424
			bgG, -- 424
			bgB, -- 424
			math.floor(255 * fadeOutCurtain + 0.5) -- 424
		) -- 424
	) -- 424
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 426
		if localT <= 0 or localT >= endT then -- 427
			return 0 -- 427
		end -- 427
		if localT < fadeIn then -- 428
			local u = localT / fadeIn -- 429
			return u * u * (3 - 2 * u) -- 430
		end -- 430
		if localT <= holdEnd then -- 432
			return 1 -- 432
		end -- 432
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 433
		return 1 - u * u * (3 - 2 * u) -- 434
	end -- 426
	if t < 2.2 then -- 437
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 438
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 439
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 440
		if not uiArt:tryPlace( -- 441
			"brand_team_logo", -- 441
			"splash_team_logo", -- 441
			w * 0.5, -- 441
			h * 0.54, -- 441
			logoH * 2, -- 441
			logoH, -- 441
			{opacity = alpha, layer = 2} -- 441
		) then -- 441
			texts:put( -- 442
				"banner", -- 442
				"OUTSIDER", -- 442
				w * 0.5, -- 442
				h * 0.52, -- 442
				toColor(PALETTE.textBright), -- 442
				0.5, -- 442
				0.5, -- 442
				"Center", -- 442
				6, -- 442
				alpha, -- 442
				0 -- 442
			) -- 442
		end -- 442
		texts:put( -- 444
			"xs", -- 444
			"Powered by Dora SSR", -- 444
			w * 0.5, -- 444
			58 + frame.safe.bottom * 0.4, -- 444
			toColor(PALETTE.textDim), -- 444
			0.5, -- 444
			0.5, -- 444
			"Center", -- 444
			1.8, -- 444
			alpha * 0.62, -- 444
			0 -- 444
		) -- 444
	elseif t < 4.25 then -- 445
		local localT = t - 2.2 -- 446
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 447
		local sway = math.sin(localT * 1.1) * 8 -- 448
		drawMistCurve( -- 449
			uiArt, -- 449
			"splash_game_mist", -- 449
			w * 0.5 + sway, -- 449
			h * 0.46, -- 449
			560, -- 449
			110, -- 449
			PALETTE.jadeMist, -- 449
			0.16 * alpha, -- 449
			1 -- 449
		) -- 449
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 450
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 451
		if not uiArt:tryPlace( -- 452
			"brand_game_logo_h", -- 452
			"splash_game_logo", -- 452
			w * 0.5, -- 452
			h * 0.52, -- 452
			logoH * 2.4, -- 452
			logoH, -- 452
			{opacity = alpha, layer = 2} -- 452
		) then -- 452
			texts:put( -- 453
				"title", -- 453
				"向西守望", -- 453
				w * 0.5, -- 453
				h * 0.52, -- 453
				toColor(PALETTE.textBright), -- 453
				0.5, -- 453
				0.5, -- 453
				"Center", -- 453
				8, -- 453
				alpha, -- 453
				0 -- 453
			) -- 453
		end -- 453
	end -- 453
	if t >= 0.35 and t < 4.15 then -- 457
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 458
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 459
		texts:put( -- 464
			"xs", -- 464
			skipText, -- 464
			w - 48 - frame.safe.right * 0.6, -- 464
			36 + frame.safe.bottom * 0.4, -- 464
			toColor(PALETTE.textDim), -- 464
			1, -- 464
			0.5, -- 464
			"Right", -- 464
			1.4, -- 464
			hintA, -- 464
			0 -- 464
		) -- 464
	end -- 464
	return {type = "none"} -- 467
end -- 401
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 470
	fillHGradRect( -- 480
		uiDraw, -- 480
		0, -- 480
		0, -- 480
		w * 0.22 + frame.safe.left * 0.5, -- 480
		h, -- 480
		Color(9, 11, 18, 192), -- 480
		Color(9, 11, 18, 116) -- 480
	) -- 480
	fillHGradRect( -- 481
		uiDraw, -- 481
		w * 0.22 + frame.safe.left * 0.5, -- 481
		0, -- 481
		w * 0.28, -- 481
		h, -- 481
		Color(9, 11, 18, 116), -- 481
		Color(9, 11, 18, 0) -- 481
	) -- 481
	fillVGradRect( -- 482
		uiDraw, -- 482
		0, -- 482
		0, -- 482
		w, -- 482
		78, -- 482
		Color(8, 10, 16, 138), -- 482
		Color(8, 10, 16, 0) -- 482
	) -- 482
	local extraH = math.max(0, h - 720) -- 484
	local titleX = 148 + frame.safe.left * 0.6 -- 485
	local topY = h - 104 - frame.safe.top * 0.4 -- 486
	local charStep = 66 -- 487
	local sway = math.sin(self.time * 0.7) * 5 -- 488
	drawMistCurve( -- 489
		uiArt, -- 489
		"title_mist_wisp", -- 489
		titleX + 86 + sway, -- 489
		topY - 122, -- 489
		340, -- 489
		82, -- 489
		PALETTE.jadeMist, -- 489
		0.2, -- 489
		-1 -- 489
	) -- 489
	uiArt:tryPlace( -- 490
		"ink_petal_mist", -- 490
		"title_petals", -- 490
		titleX + 12, -- 490
		topY - 102, -- 490
		230, -- 490
		210, -- 490
		{ -- 490
			color = toColor(PALETTE.inkMist), -- 491
			opacity = 0.4, -- 491
			layer = -1 -- 491
		} -- 491
	) -- 491
	local placedBrandTitle = uiArt:tryPlace( -- 495
		"brand_game_logo_v", -- 495
		"title_brand_v", -- 495
		titleX + 22, -- 495
		topY - 106, -- 495
		240, -- 495
		304, -- 495
		{opacity = 0.98, layer = 3} -- 495
	) -- 495
	if not placedBrandTitle then -- 498
		uiArt:tryPlace( -- 499
			"ink_vstream", -- 499
			"title_vstream", -- 499
			titleX - 48, -- 499
			topY - 100, -- 499
			34, -- 499
			290, -- 499
			{ -- 499
				color = toColor(PALETTE.silkDim), -- 500
				opacity = 0.48, -- 500
				layer = 1 -- 500
			} -- 500
		) -- 500
		local c = 0 -- 502
		do -- 502
			c = 0 -- 503
			while c < #VERTICAL_TITLE do -- 503
				texts:put( -- 504
					"title", -- 505
					VERTICAL_TITLE[c + 1], -- 506
					titleX, -- 507
					topY - c * charStep, -- 508
					toColor(PALETTE.textBright), -- 509
					0.5, -- 510
					0.5, -- 511
					"Center", -- 512
					0, -- 513
					0.98, -- 514
					0.1, -- 515
					Color(8, 10, 16, 210) -- 516
				) -- 516
				c = c + 1 -- 503
			end -- 503
		end -- 503
		drawLoneSeal( -- 519
			uiInkDraw, -- 520
			uiArt, -- 521
			texts, -- 522
			"title_lone_seal", -- 523
			titleX + 46, -- 524
			topY - 3 * charStep + 8, -- 525
			26, -- 526
			52, -- 527
			"守", -- 528
			"望", -- 529
			PALETTE.sealRed, -- 530
			PALETTE.sealText, -- 531
			0.94, -- 532
			4 -- 533
		) -- 533
	end -- 533
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 538
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 539
	local poemStep = 22 -- 540
	local p = 0 -- 541
	do -- 541
		p = 0 -- 542
		while p < #EPIGRAPH_RIGHT do -- 542
			local ch = EPIGRAPH_RIGHT[p + 1] -- 543
			if ch ~= "" then -- 544
				texts:put( -- 545
					"xs", -- 545
					ch, -- 545
					colRightX, -- 545
					topY - 22 - p * poemStep, -- 545
					toColor(PALETTE.textMid), -- 545
					0.5, -- 545
					0.5, -- 545
					"Center", -- 545
					0, -- 545
					0.86, -- 545
					0.08 -- 545
				) -- 545
			end -- 545
			p = p + 1 -- 542
		end -- 542
	end -- 542
	do -- 542
		p = 0 -- 548
		while p < #EPIGRAPH_LEFT do -- 548
			texts:put( -- 549
				"xs", -- 549
				EPIGRAPH_LEFT[p + 1], -- 549
				colLeftX, -- 549
				topY - 68 - p * poemStep, -- 549
				toColor(PALETTE.amberCore), -- 549
				0.5, -- 549
				0.5, -- 549
				"Center", -- 549
				0, -- 549
				0.9, -- 549
				0.08 -- 549
			) -- 549
			p = p + 1 -- 548
		end -- 548
	end -- 548
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 553
		TITLE_ITEMS, -- 555
		function(____, it) return it.id ~= "quit" end -- 555
	) -- 555
	local items = self.hasSession and ({ -- 556
		{id = "continue", zh = "继续游戏"}, -- 557
		table.unpack(baseItems) -- 557
	}) or baseItems -- 558
	if self.selected >= #items then -- 559
		self.selected = 0 -- 560
	end -- 560
	local menuX = 112 + frame.safe.left * 0.6 -- 562
	local btnW = 280 -- 563
	local btnH = frame.mode == "touch" and 44 or 40 -- 564
	local gap = self.hasSession and 6 or 8 -- 565
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 566
	local boxes = {} -- 567
	local i = 0 -- 568
	do -- 568
		i = 0 -- 569
		while i < #items do -- 569
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 570
			i = i + 1 -- 569
		end -- 569
	end -- 569
	local prevTitleSel = self.selected -- 572
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 573
	if self.selected ~= prevTitleSel then -- 574
		self:emitSound("hover") -- 575
	end -- 575
	do -- 575
		i = 0 -- 578
		while i < #items do -- 578
			local by = boxes[i + 1].y -- 579
			local active = self.selected == i -- 580
			local cy = by + btnH * 0.5 -- 581
			local shiftX = active and 10 or 0 -- 582
			if active then -- 584
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 585
				drawSilkRibbon( -- 586
					uiDraw, -- 586
					uiArt, -- 586
					"title_rib_red_" .. tostring(i), -- 586
					menuX + 124, -- 586
					cy, -- 586
					290, -- 586
					btnH, -- 586
					PALETTE.rougeSoft, -- 586
					0.52 * breathe, -- 586
					0 -- 586
				) -- 586
				drawHairline( -- 587
					uiInkDraw, -- 587
					uiArt, -- 587
					"title_rib_line_" .. tostring(i), -- 587
					menuX + 114, -- 587
					by + 4, -- 587
					230, -- 587
					PALETTE.silkLine, -- 587
					0.42 * breathe, -- 587
					false, -- 587
					2 -- 587
				) -- 587
				drawBlossomDot( -- 588
					uiInkDraw, -- 588
					uiArt, -- 588
					"title_dot_" .. tostring(i), -- 588
					menuX + 14, -- 588
					cy, -- 588
					16, -- 588
					PALETTE.rouge, -- 588
					0.96, -- 588
					4 -- 588
				) -- 588
				fillRadialGlow( -- 589
					uiGlow, -- 589
					menuX + 14, -- 589
					cy, -- 589
					22, -- 589
					16, -- 589
					toColor(PALETTE.rouge, 28 * breathe), -- 589
					Color(182, 58, 56, 0), -- 589
					10 -- 589
				) -- 589
			else -- 589
				drawBlossomDot( -- 591
					uiInkDraw, -- 591
					uiArt, -- 591
					"title_dot_" .. tostring(i), -- 591
					menuX + 14, -- 591
					cy, -- 591
					8, -- 591
					PALETTE.silkDim, -- 591
					0.4, -- 591
					3 -- 591
				) -- 591
			end -- 591
			texts:put( -- 594
				"md", -- 595
				items[i + 1].zh, -- 596
				menuX + 34 + shiftX, -- 597
				cy, -- 598
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 599
				0, -- 600
				0.5, -- 601
				"Left", -- 602
				active and 4.4 or 2.8, -- 603
				active and 1 or 0.88, -- 604
				0.1 -- 605
			) -- 605
			i = i + 1 -- 578
		end -- 578
	end -- 578
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 609
	texts:put( -- 616
		"xs", -- 616
		titleHint, -- 616
		menuX + 12, -- 616
		42 + frame.safe.bottom * 0.45, -- 616
		toColor(PALETTE.textDim), -- 616
		0, -- 616
		0.5, -- 616
		"Left", -- 616
		1.4, -- 616
		0.88, -- 616
		0.08 -- 616
	) -- 616
	local badgeRight = w - frame.safe.right * 0.5 -- 619
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 620
	fillHGradRect( -- 621
		uiDraw, -- 621
		badgeRight - 270, -- 621
		0, -- 621
		270 + frame.safe.right * 0.5, -- 621
		86, -- 621
		Color(8, 10, 16, 0), -- 621
		Color(8, 10, 16, 204) -- 621
	) -- 621
	uiArt:tryPlace( -- 622
		"brand_team_badge", -- 622
		"title_team_badge", -- 622
		badgeRight - 118, -- 622
		badgeY, -- 622
		168, -- 622
		54, -- 622
		{opacity = 0.95, layer = 3} -- 622
	) -- 622
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 626
	if hit >= 0 or frame.keys.confirm then -- 627
		local idx = hit >= 0 and hit or self.selected -- 628
		local id = items[idx + 1].id -- 629
		if id == "continue" then -- 630
			self:emitSound("start") -- 630
			return {type = "continue"} -- 630
		end -- 630
		if id == "trial" then -- 631
			self:emitSound("start") -- 631
			return {type = "trial"} -- 631
		end -- 631
		if id == "start" then -- 632
			self:emitSound("start") -- 632
			return {type = "start"} -- 632
		end -- 632
		if id == "chapters" then -- 633
			self:emitSound("confirm") -- 633
			return {type = "openChapters"} -- 633
		end -- 633
		if id == "quit" then -- 634
			self:emitSound("back") -- 634
			return {type = "quit"} -- 634
		end -- 634
		self:emitSound("confirm") -- 635
		return {type = "openControls"} -- 636
	end -- 636
	return {type = "none"} -- 638
end -- 470
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 641
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 651
	if frame.back then -- 652
		self:emitSound("back") -- 653
		return back -- 654
	end -- 654
	local extraH = math.max(0, h - 720) -- 657
	local marginX = math.max( -- 658
		96, -- 658
		56 + math.max(frame.safe.left, frame.safe.right) -- 658
	) -- 658
	local splitTrack = #CHAPTERS > 8 -- 659
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 660
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 661
	local rowGap = 68 -- 662
	local trackX0 = marginX + 34 -- 663
	local trackX1 = w - marginX - 34 -- 664
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 665
	local stationBoxes = {} -- 667
	local s = 0 -- 668
	do -- 668
		s = 0 -- 669
		while s < #CHAPTERS do -- 669
			local sx = trackX0 + s % perRow * stepX -- 670
			local sy = trackY - math.floor(s / perRow) * rowGap -- 671
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 672
			s = s + 1 -- 669
		end -- 669
	end -- 669
	local prevSelected = self.chapterSelected -- 675
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 676
	local keys = frame.keys -- 677
	if frame.click and hitStation >= 0 then -- 678
		self.chapterSelected = hitStation -- 679
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 680
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 681
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 682
	elseif keys.down and self.chapterSelected < perRow then -- 683
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 684
	elseif keys.up and self.chapterSelected >= perRow then -- 685
		self.chapterSelected = self.chapterSelected - perRow -- 686
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 687
		self.chapterSelected = hitStation -- 688
	end -- 688
	if self.chapterSelected ~= prevSelected then -- 690
		self:emitSound("hover") -- 691
	end -- 691
	uiDraw:drawRect( -- 694
		Rect(0, 0, w, h), -- 694
		Color(10, 12, 19, 198) -- 694
	) -- 694
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 696
	texts:put( -- 697
		"banner", -- 697
		"选择章节", -- 697
		marginX, -- 697
		topHeadY, -- 697
		toColor(PALETTE.textBright), -- 697
		0, -- 697
		0.5, -- 697
		"Left", -- 697
		4.5, -- 697
		0.96, -- 697
		0.1 -- 697
	) -- 697
	drawHairline( -- 698
		uiInkDraw, -- 698
		uiArt, -- 698
		"chap_top_line", -- 698
		w * 0.5, -- 698
		topHeadY - 34, -- 698
		w - marginX * 2, -- 698
		PALETTE.silkDim, -- 698
		0.6, -- 698
		true, -- 698
		2 -- 698
	) -- 698
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 700
	local theme = themeOf(activeRoom.key) -- 701
	local winX = marginX -- 702
	local winY = 266 + extraH * 0.44 -- 703
	local winW = math.min( -- 704
		520, -- 704
		math.max(360, (w - marginX * 2) * 0.46) -- 704
	) -- 704
	local winH = 296 -- 705
	local winBox = Rect(winX, winY, winW, winH) -- 706
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 707
	uiArt:tryPlace( -- 709
		"ink_frame_mask", -- 709
		"chap_win_shadow", -- 709
		winX + winW * 0.5, -- 709
		winY + winH * 0.5, -- 709
		winW + 40, -- 709
		winH + 34, -- 709
		{ -- 709
			color = toColor(PALETTE.inkVoid), -- 710
			opacity = 0.88, -- 710
			layer = -2 -- 710
		} -- 710
	) -- 710
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 712
	uiArt:tryPlace( -- 713
		bgSlot, -- 713
		"chap_win_art", -- 713
		winX + winW * 0.5, -- 713
		winY + 4, -- 713
		winW - 8, -- 713
		winH - 8, -- 713
		{opacity = 0.92, layer = -1} -- 713
	) -- 713
	fillVGradRect( -- 716
		uiInkDraw, -- 716
		winX, -- 716
		winY, -- 716
		winW, -- 716
		56, -- 716
		Color(10, 12, 19, 200), -- 716
		Color(10, 12, 19, 0) -- 716
	) -- 716
	fillVGradRect( -- 717
		uiInkDraw, -- 717
		winX, -- 717
		winY + winH - 36, -- 717
		winW, -- 717
		36, -- 717
		Color(10, 12, 19, 0), -- 717
		Color(10, 12, 19, 130) -- 717
	) -- 717
	fillHGradRect( -- 718
		uiInkDraw, -- 718
		winX, -- 718
		winY, -- 718
		34, -- 718
		winH, -- 718
		Color(10, 12, 19, 135), -- 718
		Color(10, 12, 19, 0) -- 718
	) -- 718
	fillHGradRect( -- 719
		uiInkDraw, -- 719
		winX + winW - 34, -- 719
		winY, -- 719
		34, -- 719
		winH, -- 719
		Color(10, 12, 19, 0), -- 719
		Color(10, 12, 19, 135) -- 719
	) -- 719
	drawFiligreeCorners( -- 720
		uiInkDraw, -- 720
		uiArt, -- 720
		"chap_win_frame", -- 720
		winX, -- 720
		winY, -- 720
		winW, -- 720
		winH, -- 720
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 720
		winHover and 0.92 or 0.72, -- 720
		34, -- 720
		true, -- 720
		3 -- 720
	) -- 720
	texts:put( -- 722
		"xs", -- 722
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 722
		winX + 20, -- 722
		winY + 22, -- 722
		toColor(PALETTE.textMid), -- 722
		0, -- 722
		0.5, -- 722
		"Left", -- 722
		1.8, -- 722
		0.9, -- 722
		0.08 -- 722
	) -- 722
	local infoX = winX + winW + 40 -- 724
	local infoW = math.max(240, w - marginX - infoX) -- 725
	local infoCenterY = winY + winH * 0.5 -- 726
	drawMistCurve( -- 727
		uiArt, -- 727
		"chap_info_mist", -- 727
		infoX + infoW * 0.5, -- 727
		infoCenterY + 36, -- 727
		math.min(420, infoW + 24), -- 727
		88, -- 727
		theme.accent, -- 727
		0.22, -- 727
		-1 -- 727
	) -- 727
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 729
	texts:put( -- 730
		"xs", -- 730
		theme.volumeTagZh, -- 730
		infoX, -- 730
		winY + winH - 44, -- 730
		toColor(volCol), -- 730
		0, -- 730
		0.5, -- 730
		"Left", -- 730
		2.8, -- 730
		0.92, -- 730
		0.08 -- 730
	) -- 730
	local sep = " · " -- 732
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 733
	local titleY = winY + winH - 98 -- 734
	if theme.backdropKey ~= nil then -- 735
		texts:put( -- 736
			"lg", -- 736
			theme.titleZh, -- 736
			infoX, -- 736
			titleY, -- 736
			toColor(PALETTE.textBright) -- 736
		) -- 736
	elseif sIdx > 0 then -- 737
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 738
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 739
		local lw = visualTextWidth(leftPart, 40) -- 740
		texts:put( -- 741
			"banner", -- 741
			leftPart, -- 741
			infoX, -- 741
			titleY, -- 741
			toColor(PALETTE.textBright), -- 741
			0, -- 741
			0.5, -- 741
			"Left", -- 741
			2, -- 741
			1, -- 741
			0.1 -- 741
		) -- 741
		drawBlossomDot( -- 742
			uiInkDraw, -- 742
			uiArt, -- 742
			"chap_title_dot", -- 742
			infoX + lw + 16, -- 742
			titleY - 2, -- 742
			11, -- 742
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 742
			0.9, -- 742
			4 -- 742
		) -- 742
		texts:put( -- 743
			"banner", -- 743
			rightPart, -- 743
			infoX + lw + 32, -- 743
			titleY, -- 743
			toColor(PALETTE.textBright), -- 743
			0, -- 743
			0.5, -- 743
			"Left", -- 743
			2, -- 743
			1, -- 743
			0.1 -- 743
		) -- 743
	else -- 743
		texts:put( -- 745
			"banner", -- 745
			theme.titleZh, -- 745
			infoX, -- 745
			titleY, -- 745
			toColor(PALETTE.textBright), -- 745
			0, -- 745
			0.5, -- 745
			"Left", -- 745
			2.4, -- 745
			1, -- 745
			0.1 -- 745
		) -- 745
	end -- 745
	drawHairline( -- 748
		uiInkDraw, -- 748
		uiArt, -- 748
		"chap_info_line", -- 748
		infoX + math.min(185, infoW * 0.5), -- 748
		titleY - 36, -- 748
		math.min(370, infoW), -- 748
		PALETTE.silkDim, -- 748
		0.58, -- 748
		false, -- 748
		2 -- 748
	) -- 748
	texts:put( -- 749
		"sm", -- 749
		theme.introWhisper, -- 749
		infoX, -- 749
		titleY - 72, -- 749
		toColor(PALETTE.textMid), -- 749
		0, -- 749
		0.5, -- 749
		"Left", -- 749
		0.8, -- 749
		0.94, -- 749
		0.08 -- 749
	) -- 749
	local goX = infoX -- 751
	local goY = winY + 26 -- 752
	local goW = 220 -- 753
	local goH = 42 -- 754
	local goBox = Rect(goX, goY, goW, goH) -- 755
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 756
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 757
	drawSilkRibbon( -- 758
		uiDraw, -- 758
		uiArt, -- 758
		"chap_go_rib", -- 758
		goX + 106, -- 758
		goY + 21, -- 758
		250, -- 758
		40, -- 758
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 758
		(goHover and 0.68 or 0.46) * breathe, -- 758
		0 -- 758
	) -- 758
	drawHairline( -- 759
		uiInkDraw, -- 759
		uiArt, -- 759
		"chap_go_line", -- 759
		goX + 94, -- 759
		goY + 3, -- 759
		196, -- 759
		PALETTE.silkLine, -- 759
		goHover and 0.68 or 0.4, -- 759
		false, -- 759
		2 -- 759
	) -- 759
	drawBlossomDot( -- 760
		uiInkDraw, -- 760
		uiArt, -- 760
		"chap_go_dot", -- 760
		goX + 14, -- 760
		goY + 21, -- 760
		14, -- 760
		PALETTE.rouge, -- 760
		0.96, -- 760
		4 -- 760
	) -- 760
	texts:put( -- 761
		"md", -- 761
		"入此卷章", -- 761
		goX + 34, -- 761
		goY + 21, -- 761
		toColor(PALETTE.textBright), -- 761
		0, -- 761
		0.5, -- 761
		"Left", -- 761
		3.8, -- 761
		1, -- 761
		0.1 -- 761
	) -- 761
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 762
	texts:put( -- 765
		"xs", -- 765
		chapConfirmTag, -- 765
		goX + 156, -- 765
		goY + 21, -- 765
		toColor(PALETTE.textDim), -- 765
		0, -- 765
		0.5, -- 765
		"Left", -- 765
		1, -- 765
		0.82, -- 765
		0.08 -- 765
	) -- 765
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 767
	local veilH = splitTrack and 156 or 126 -- 768
	drawSilkVeil( -- 769
		uiDraw, -- 769
		uiArt, -- 769
		"chap_track_veil", -- 769
		w * 0.5, -- 769
		veilCenterY, -- 769
		w - marginX * 1.1, -- 769
		veilH, -- 769
		PALETTE.inkWash, -- 769
		0.72, -- 769
		-2 -- 769
	) -- 769
	drawMistCurve( -- 770
		uiArt, -- 770
		"chap_track_mist", -- 770
		w * 0.5, -- 770
		trackY, -- 770
		trackX1 - trackX0 + 160, -- 770
		74, -- 770
		PALETTE.inkMist, -- 770
		0.62, -- 770
		-1 -- 770
	) -- 770
	uiInkDraw:drawSegment( -- 771
		Vec2(trackX0, trackY), -- 771
		Vec2(trackX1, trackY), -- 771
		0.9, -- 771
		toColor(PALETTE.silkDim, 145) -- 771
	) -- 771
	if splitTrack then -- 773
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 774
		uiInkDraw:drawSegment( -- 775
			Vec2(trackX0, trackY - rowGap), -- 775
			Vec2(lastX, trackY - rowGap), -- 775
			0.9, -- 775
			toColor(PALETTE.silkDim, 145) -- 775
		) -- 775
	else -- 775
		local midDivX = trackX0 + stepX * 3.5 -- 777
		uiInkDraw:drawSegment( -- 778
			Vec2(midDivX, trackY - 12), -- 778
			Vec2(midDivX, trackY + 12), -- 778
			0.8, -- 778
			toColor(PALETTE.silkDim, 120) -- 778
		) -- 778
		texts:put( -- 779
			"xs", -- 779
			"上卷 · 孤城护童", -- 779
			trackX0 + stepX * 1.5, -- 779
			trackY + 52, -- 779
			toColor(PALETTE.cyan), -- 779
			0.5, -- 779
			0.5, -- 779
			"Center", -- 779
			2.2, -- 779
			0.88, -- 779
			0.08 -- 779
		) -- 779
		texts:put( -- 780
			"xs", -- 780
			"下卷 · 独赴北塔", -- 780
			trackX0 + stepX * 5.5, -- 780
			trackY + 52, -- 780
			toColor(PALETTE.amber), -- 780
			0.5, -- 780
			0.5, -- 780
			"Center", -- 780
			2.2, -- 780
			0.88, -- 780
			0.08 -- 780
		) -- 780
	end -- 780
	local i = 0 -- 783
	do -- 783
		i = 0 -- 784
		while i < #CHAPTERS do -- 784
			local box = stationBoxes[i + 1] -- 785
			local sx = box.x + box.width * 0.5 -- 786
			local sy = box.y + box.height * 0.5 -- 787
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 788
			local active = self.chapterSelected == i -- 789
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 790
			if active then -- 792
				fillRadialGlow( -- 793
					uiGlow, -- 793
					sx, -- 793
					sy, -- 793
					26, -- 793
					26, -- 793
					toColor(PALETTE.rouge, 36 * breathe), -- 793
					Color(182, 58, 56, 0), -- 793
					12 -- 793
				) -- 793
				uiArt:tryPlace( -- 794
					"ink_enso_fine", -- 794
					"chap_st_ring_" .. tostring(i), -- 794
					sx, -- 794
					sy, -- 794
					32, -- 794
					32, -- 794
					{ -- 794
						color = toColor(PALETTE.silkLine), -- 795
						opacity = 0.78, -- 795
						angle = self.time * 18, -- 795
						layer = 3 -- 795
					} -- 795
				) -- 795
				drawBlossomDot( -- 797
					uiInkDraw, -- 797
					uiArt, -- 797
					"chap_st_dot_" .. tostring(i), -- 797
					sx, -- 797
					sy, -- 797
					17, -- 797
					PALETTE.rouge, -- 797
					0.98, -- 797
					4 -- 797
				) -- 797
			else -- 797
				uiArt:tryPlace( -- 799
					"ink_enso_fine", -- 799
					"chap_st_ring_" .. tostring(i), -- 799
					sx, -- 799
					sy, -- 799
					16, -- 799
					16, -- 799
					{ -- 799
						color = toColor(nodeCol), -- 800
						opacity = 0.62, -- 800
						layer = 3 -- 800
					} -- 800
				) -- 800
				drawBlossomDot( -- 802
					uiInkDraw, -- 802
					uiArt, -- 802
					"chap_st_dot_" .. tostring(i), -- 802
					sx, -- 802
					sy, -- 802
					7, -- 802
					PALETTE.silkLine, -- 802
					0.72, -- 802
					4 -- 802
				) -- 802
			end -- 802
			if not splitTrack then -- 805
				texts:put( -- 806
					"xs", -- 806
					rt.numeralZh, -- 806
					sx, -- 806
					sy + 25, -- 806
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 806
					0.5, -- 806
					0.5, -- 806
					"Center", -- 806
					0, -- 806
					active and 1 or 0.88, -- 806
					0.08 -- 806
				) -- 806
			end -- 806
			texts:put( -- 808
				"xs", -- 808
				rt.shortNameZh, -- 808
				sx, -- 808
				sy - 26, -- 808
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 808
				0.5, -- 808
				0.5, -- 808
				"Center", -- 808
				1, -- 808
				active and 1 or 0.84, -- 808
				0.08 -- 808
			) -- 808
			i = i + 1 -- 784
		end -- 784
	end -- 784
	local backX = marginX -- 811
	local backY = 40 + frame.safe.bottom * 0.45 -- 812
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 813
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 814
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 815
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 818
	drawSilkKeycap( -- 823
		uiInkDraw, -- 823
		texts, -- 823
		backX, -- 823
		backY + 5, -- 823
		48, -- 823
		24, -- 823
		chapBackTag, -- 823
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 823
		0.92, -- 823
		backHover -- 823
	) -- 823
	texts:put( -- 824
		"sm", -- 824
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 824
		backX + 60, -- 824
		backY + 17, -- 824
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 824
		0, -- 824
		0.5, -- 824
		"Left", -- 824
		1.8, -- 824
		0.9, -- 824
		0.08 -- 824
	) -- 824
	texts:put( -- 825
		"xs", -- 825
		chapFooter, -- 825
		w - marginX, -- 825
		backY + 17, -- 825
		toColor(PALETTE.textDim), -- 825
		1, -- 825
		0.5, -- 825
		"Right", -- 825
		1.2, -- 825
		0.75, -- 825
		0.08 -- 825
	) -- 825
	if frame.click and backHover then -- 827
		self:emitSound("back") -- 828
		return back -- 829
	end -- 829
	local ____temp_2 -- 832
	if frame.mode == "touch" then -- 832
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 833
	else -- 833
		____temp_2 = hitStation >= 0 -- 834
	end -- 834
	local stationConfirmed = ____temp_2 -- 832
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 835
		self:emitSound("start") -- 836
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 837
	end -- 837
	return {type = "none"} -- 839
end -- 641
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 843
	if backLabel == nil then -- 852
		backLabel = "返回标题" -- 852
	end -- 852
	if not self.controlsTabManual then -- 854
		self.controlsTab = frame.mode -- 855
	end -- 855
	local tabOrder = {"kbm", "gamepad", "touch"} -- 857
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 858
	local marginX = math.max( -- 859
		96, -- 859
		56 + math.max(frame.safe.left, frame.safe.right) -- 859
	) -- 859
	local tabW = 92 -- 860
	local tabH = 28 -- 861
	local tabGap = 10 -- 862
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 863
	local tabY = h - 82 - frame.safe.top * 0.35 -- 864
	local tabBoxes = { -- 865
		Rect(tabStartX, tabY, tabW, tabH), -- 866
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 867
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 868
	} -- 868
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 871
	if frame.click and hitTab >= 0 then -- 872
		if self.controlsTab ~= tabOrder[hitTab + 1] then -- 873
			self:emitSound("toggle") -- 874
		end -- 874
		self.controlsTab = tabOrder[hitTab + 1] -- 876
		self.controlsTabManual = true -- 877
	elseif frame.keys.left or frame.prevTab then -- 878
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 879
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 880
		self.controlsTabManual = true -- 881
		self:emitSound("toggle") -- 882
	elseif frame.keys.right or frame.nextTab then -- 883
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 884
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 885
		self.controlsTabManual = true -- 886
		self:emitSound("toggle") -- 887
	end -- 887
	local backX = marginX -- 890
	local backY = 40 + frame.safe.bottom * 0.45 -- 891
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 892
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 893
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 894
		self:emitSound("back") -- 895
		return {type = "backTitle"} -- 896
	end -- 896
	uiDraw:drawRect( -- 898
		Rect(0, 0, w, h), -- 898
		Color(10, 12, 19, 204) -- 898
	) -- 898
	local guide = controlsGuideRows(self.controlsTab) -- 900
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 901
	texts:put( -- 902
		"banner", -- 902
		"执器要诀", -- 902
		marginX, -- 902
		topHeadY, -- 902
		toColor(PALETTE.textBright), -- 902
		0, -- 902
		0.5, -- 902
		"Left", -- 902
		4.5, -- 902
		0.96, -- 902
		0.1 -- 902
	) -- 902
	texts:put( -- 903
		"xs", -- 903
		guide.subtitle, -- 903
		marginX + 196, -- 903
		topHeadY - 4, -- 903
		toColor(PALETTE.textDim), -- 903
		0, -- 903
		0.5, -- 903
		"Left", -- 903
		1.8, -- 903
		0.85, -- 903
		0.08 -- 903
	) -- 903
	drawHairline( -- 904
		uiInkDraw, -- 904
		uiArt, -- 904
		"ctrl_top_line", -- 904
		w * 0.5, -- 904
		topHeadY - 34, -- 904
		w - marginX * 2, -- 904
		PALETTE.silkDim, -- 904
		0.6, -- 904
		true, -- 904
		2 -- 904
	) -- 904
	local ti = 0 -- 906
	do -- 906
		ti = 0 -- 907
		while ti < #tabBoxes do -- 907
			local tb = tabBoxes[ti + 1] -- 908
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 909
			local hoverTab = hitTab == ti -- 910
			uiInkDraw:drawRect( -- 911
				tb, -- 912
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 913
				0.9, -- 914
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 915
			) -- 915
			texts:put( -- 917
				"xs", -- 918
				tabLabels[ti + 1], -- 919
				tb.x + tb.width * 0.5, -- 920
				tb.y + tb.height * 0.5, -- 921
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 922
				0.5, -- 923
				0.5, -- 924
				"Center", -- 925
				0.8, -- 926
				activeTab and 0.98 or 0.82, -- 927
				0.08 -- 928
			) -- 928
			ti = ti + 1 -- 907
		end -- 907
	end -- 907
	local extraH = math.max(0, h - 720) -- 932
	local areaY = 114 + frame.safe.bottom * 0.4 -- 933
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 934
	drawFiligreeCorners( -- 935
		uiInkDraw, -- 935
		uiArt, -- 935
		"ctrl_outer", -- 935
		marginX, -- 935
		areaY, -- 935
		w - marginX * 2, -- 935
		areaH, -- 935
		PALETTE.silkDim, -- 935
		0.52, -- 935
		34, -- 935
		false, -- 935
		2 -- 935
	) -- 935
	local midX = w * 0.5 -- 937
	uiArt:tryPlace( -- 938
		"ink_vstream", -- 938
		"ctrl_mid_stream", -- 938
		midX, -- 938
		areaY + areaH * 0.5, -- 938
		32, -- 938
		areaH - 18, -- 938
		{ -- 938
			color = toColor(PALETTE.silkDim), -- 939
			opacity = 0.52, -- 939
			layer = 1 -- 939
		} -- 939
	) -- 939
	drawBlossomDot( -- 941
		uiInkDraw, -- 941
		uiArt, -- 941
		"ctrl_mid_dot", -- 941
		midX, -- 941
		areaY + areaH * 0.5, -- 941
		11, -- 941
		PALETTE.silkLine, -- 941
		0.62, -- 941
		3 -- 941
	) -- 941
	local leftColX = marginX + 34 -- 943
	local colW = midX - leftColX - 42 -- 944
	local headY = areaY + areaH - 34 -- 945
	local rowStep = 52 + extraH * 0.08 -- 946
	drawBlossomDot( -- 948
		uiInkDraw, -- 948
		uiArt, -- 948
		"ctrl_l_dot", -- 948
		leftColX + 8, -- 948
		headY, -- 948
		12, -- 948
		PALETTE.cyan, -- 948
		0.88, -- 948
		3 -- 948
	) -- 948
	texts:put( -- 949
		"md", -- 949
		"周戍 · 护送与交锋", -- 949
		leftColX + 26, -- 949
		headY, -- 949
		toColor(PALETTE.cyanCore), -- 949
		0, -- 949
		0.5, -- 949
		"Left", -- 949
		2.4, -- 949
		0.98, -- 949
		0.08 -- 949
	) -- 949
	drawHairline( -- 950
		uiInkDraw, -- 950
		uiArt, -- 950
		"ctrl_l_line", -- 950
		leftColX + colW * 0.5, -- 950
		headY - 24, -- 950
		colW, -- 950
		PALETTE.cyanDim, -- 950
		0.58, -- 950
		false, -- 950
		2 -- 950
	) -- 950
	local i = 0 -- 952
	local keycapW = 160 -- 953
	do -- 953
		i = 0 -- 954
		while i < #guide.soldierRows do -- 954
			local ry = headY - 66 - i * rowStep -- 955
			drawSilkKeycap( -- 956
				uiInkDraw, -- 956
				texts, -- 956
				leftColX + 2, -- 956
				ry - 13, -- 956
				keycapW, -- 956
				26, -- 956
				guide.soldierRows[i + 1][1], -- 956
				PALETTE.cyan, -- 956
				0.92, -- 956
				false -- 956
			) -- 956
			texts:put( -- 957
				"sm", -- 957
				guide.soldierRows[i + 1][2], -- 957
				leftColX + keycapW + 16, -- 957
				ry, -- 957
				toColor(PALETTE.textBright), -- 957
				0, -- 957
				0.5, -- 957
				"Left", -- 957
				0.8, -- 957
				0.92, -- 957
				0.08 -- 957
			) -- 957
			i = i + 1 -- 954
		end -- 954
	end -- 954
	local rightColX = midX + 44 -- 960
	drawBlossomDot( -- 961
		uiInkDraw, -- 961
		uiArt, -- 961
		"ctrl_r_dot", -- 961
		rightColX + 8, -- 961
		headY, -- 961
		12, -- 961
		PALETTE.amber, -- 961
		0.88, -- 961
		3 -- 961
	) -- 961
	texts:put( -- 962
		"md", -- 962
		"小满 · 潜行与寻路", -- 962
		rightColX + 26, -- 962
		headY, -- 962
		toColor(PALETTE.amberCore), -- 962
		0, -- 962
		0.5, -- 962
		"Left", -- 962
		2.4, -- 962
		0.98, -- 962
		0.08 -- 962
	) -- 962
	drawHairline( -- 963
		uiInkDraw, -- 963
		uiArt, -- 963
		"ctrl_r_line", -- 963
		rightColX + colW * 0.5, -- 963
		headY - 24, -- 963
		colW, -- 963
		PALETTE.amberDim, -- 963
		0.58, -- 963
		false, -- 963
		2 -- 963
	) -- 963
	do -- 963
		i = 0 -- 965
		while i < #guide.childRows do -- 965
			local ry = headY - 66 - i * rowStep -- 966
			drawSilkKeycap( -- 967
				uiInkDraw, -- 967
				texts, -- 967
				rightColX + 2, -- 967
				ry - 13, -- 967
				keycapW, -- 967
				26, -- 967
				guide.childRows[i + 1][1], -- 967
				PALETTE.amber, -- 967
				0.92, -- 967
				false -- 967
			) -- 967
			texts:put( -- 968
				"sm", -- 968
				guide.childRows[i + 1][2], -- 968
				rightColX + keycapW + 16, -- 968
				ry, -- 968
				toColor(PALETTE.textBright), -- 968
				0, -- 968
				0.5, -- 968
				"Left", -- 968
				0.8, -- 968
				0.92, -- 968
				0.08 -- 968
			) -- 968
			i = i + 1 -- 965
		end -- 965
	end -- 965
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 971
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 974
	local keyW = frame.mode == "touch" and 76 or 110 -- 979
	drawSilkKeycap( -- 980
		uiInkDraw, -- 980
		texts, -- 980
		backX, -- 980
		backY + 5, -- 980
		keyW, -- 980
		24, -- 980
		ctrlBackKey, -- 980
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 980
		0.92, -- 980
		backHover -- 980
	) -- 980
	texts:put( -- 981
		"sm", -- 981
		backLabel, -- 981
		backX + keyW + 12, -- 981
		backY + 17, -- 981
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 981
		0, -- 981
		0.5, -- 981
		"Left", -- 981
		1.8, -- 981
		0.92, -- 981
		0.08 -- 981
	) -- 981
	texts:put( -- 982
		"xs", -- 982
		ctrlRightHint, -- 982
		w - marginX, -- 982
		backY + 17, -- 982
		toColor(PALETTE.textDim), -- 982
		1, -- 982
		0.5, -- 982
		"Right", -- 982
		1.2, -- 982
		0.78, -- 982
		0.08 -- 982
	) -- 982
	return {type = "none"} -- 984
end -- 843
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 988
	if frame.back then -- 999
		self:emitSound("back") -- 1000
		return true -- 1001
	end -- 1001
	local caps = getPlatformCaps() -- 1004
	local s = input.settings -- 1005
	uiDraw:drawRect( -- 1007
		Rect(0, 0, w, h), -- 1007
		Color(10, 12, 19, 206) -- 1007
	) -- 1007
	local marginX = math.max( -- 1009
		96, -- 1009
		56 + math.max(frame.safe.left, frame.safe.right) -- 1009
	) -- 1009
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1010
	texts:put( -- 1011
		"banner", -- 1011
		"操控与声音", -- 1011
		marginX, -- 1011
		topHeadY, -- 1011
		toColor(PALETTE.textBright), -- 1011
		0, -- 1011
		0.5, -- 1011
		"Left", -- 1011
		4, -- 1011
		0.96, -- 1011
		0.1 -- 1011
	) -- 1011
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 操控与四通道音量实时生效" -- 1012
	texts:put( -- 1013
		"xs", -- 1013
		curSummary, -- 1013
		marginX + 224, -- 1013
		topHeadY - 4, -- 1013
		toColor(PALETTE.amberCore), -- 1013
		0, -- 1013
		0.5, -- 1013
		"Left", -- 1013
		1.4, -- 1013
		0.88, -- 1013
		0.08 -- 1013
	) -- 1013
	drawHairline( -- 1014
		uiInkDraw, -- 1014
		uiArt, -- 1014
		"set_top_line", -- 1014
		w * 0.5, -- 1014
		topHeadY - 30, -- 1014
		w - marginX * 2, -- 1014
		PALETTE.silkDim, -- 1014
		0.6, -- 1014
		true, -- 1014
		2 -- 1014
	) -- 1014
	local panelW = math.min(760, w - marginX * 2) -- 1016
	local panelX = (w - panelW) * 0.5 -- 1017
	local rowH = 34 -- 1018
	local rowStep = 39 -- 1019
	local firstY = topHeadY - 76 -- 1020
	local boxes = {} -- 1022
	local i = 0 -- 1023
	do -- 1023
		i = 0 -- 1024
		while i < #SETTINGS_ROWS do -- 1024
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1025
			i = i + 1 -- 1024
		end -- 1024
	end -- 1024
	local prevSetSel = self.settingsSelected -- 1027
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1028
	if self.settingsSelected ~= prevSetSel then -- 1029
		self:emitSound("hover") -- 1030
	end -- 1030
	local function applyDelta(rowId, delta) -- 1033
		if rowId == "back" then -- 1034
			self:emitSound("back") -- 1035
			return true -- 1036
		end -- 1036
		local audioChanged = false -- 1038
		if rowId == "modePref" then -- 1039
			input:cycleModePref(delta) -- 1040
		elseif rowId == "aimAssist" then -- 1041
			s.aimAssist = not s.aimAssist -- 1042
			saveControlSettings(s) -- 1043
		elseif rowId == "gpLayout" then -- 1044
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1045
			input.gamepadLayout = s.gamepadLayout -- 1046
			saveControlSettings(s) -- 1047
		elseif rowId == "crouchMode" then -- 1048
			s.crouchToggle = not s.crouchToggle -- 1049
			saveControlSettings(s) -- 1050
		elseif rowId == "touchOpacity" then -- 1051
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1052
			saveControlSettings(s) -- 1053
		elseif rowId == "touchScale" then -- 1054
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1055
			saveControlSettings(s) -- 1056
		elseif rowId == "haptics" then -- 1057
			s.haptics = not s.haptics -- 1058
			saveControlSettings(s) -- 1059
			if s.haptics then -- 1060
				local ____opt_3 = input:getTouch() -- 1061
				if ____opt_3 ~= nil then -- 1061
					____opt_3:vibrate(0.018) -- 1061
				end -- 1061
			end -- 1061
		elseif rowId == "masterVol" then -- 1063
			s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 1064
			saveControlSettings(s) -- 1065
			audioChanged = true -- 1066
		elseif rowId == "bgmVol" then -- 1067
			s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 1068
			saveControlSettings(s) -- 1069
			audioChanged = true -- 1070
		elseif rowId == "sfxVol" then -- 1071
			s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 1072
			saveControlSettings(s) -- 1073
			audioChanged = true -- 1074
		elseif rowId == "voiceVol" then -- 1075
			s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 1076
			saveControlSettings(s) -- 1077
			audioChanged = true -- 1078
		end -- 1078
		if audioChanged and self.onAudioSettingsChanged ~= nil then -- 1080
			self:onAudioSettingsChanged(input) -- 1081
		end -- 1081
		self:emitSound("toggle") -- 1083
		return false -- 1084
	end -- 1033
	local function valueTextOf(rowId) -- 1087
		if rowId == "modePref" then -- 1088
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1089
		end -- 1089
		if rowId == "aimAssist" then -- 1093
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1093
		end -- 1093
		if rowId == "gpLayout" then -- 1094
			return layoutLabelOf(s.gamepadLayout) -- 1094
		end -- 1094
		if rowId == "crouchMode" then -- 1095
			return s.crouchToggle and "点按切换" or "持续按住" -- 1095
		end -- 1095
		if rowId == "touchOpacity" then -- 1096
			return opacityLabelOf(s.touchOpacity) -- 1096
		end -- 1096
		if rowId == "touchScale" then -- 1097
			return scaleLabelOf(s.touchScale) -- 1097
		end -- 1097
		if rowId == "haptics" then -- 1098
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1098
		end -- 1098
		if rowId == "masterVol" then -- 1099
			return volumeLabelOf(s.masterVol) -- 1099
		end -- 1099
		if rowId == "bgmVol" then -- 1100
			return volumeLabelOf(s.bgmVol) -- 1100
		end -- 1100
		if rowId == "sfxVol" then -- 1101
			return volumeLabelOf(s.sfxVol) -- 1101
		end -- 1101
		if rowId == "voiceVol" then -- 1102
			return volumeLabelOf(s.voiceVol) -- 1102
		end -- 1102
		return "" -- 1103
	end -- 1087
	do -- 1087
		i = 0 -- 1106
		while i < #SETTINGS_ROWS do -- 1106
			local row = SETTINGS_ROWS[i + 1] -- 1107
			local box = boxes[i + 1] -- 1108
			local cy = box.y + box.height * 0.5 -- 1109
			local active = self.settingsSelected == i -- 1110
			if active then -- 1112
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1113
				drawSilkRibbon( -- 1114
					uiDraw, -- 1114
					uiArt, -- 1114
					"set_rib_" .. tostring(i), -- 1114
					panelX + panelW * 0.5, -- 1114
					cy, -- 1114
					panelW + 24, -- 1114
					rowH, -- 1114
					PALETTE.rougeSoft, -- 1114
					0.48 * breathe, -- 1114
					0 -- 1114
				) -- 1114
				drawHairline( -- 1115
					uiInkDraw, -- 1115
					uiArt, -- 1115
					"set_line_" .. tostring(i), -- 1115
					panelX + panelW * 0.5, -- 1115
					box.y + 3, -- 1115
					panelW - 24, -- 1115
					PALETTE.silkLine, -- 1115
					0.42 * breathe, -- 1115
					false, -- 1115
					2 -- 1115
				) -- 1115
				drawBlossomDot( -- 1116
					uiInkDraw, -- 1116
					uiArt, -- 1116
					"set_dot_" .. tostring(i), -- 1116
					panelX + 18, -- 1116
					cy, -- 1116
					14, -- 1116
					PALETTE.rouge, -- 1116
					0.96, -- 1116
					4 -- 1116
				) -- 1116
				fillRadialGlow( -- 1117
					uiGlow, -- 1117
					panelX + 18, -- 1117
					cy, -- 1117
					20, -- 1117
					14, -- 1117
					toColor(PALETTE.rouge, 24 * breathe), -- 1117
					Color(182, 58, 56, 0), -- 1117
					10 -- 1117
				) -- 1117
			else -- 1117
				drawBlossomDot( -- 1119
					uiInkDraw, -- 1119
					uiArt, -- 1119
					"set_dot_" .. tostring(i), -- 1119
					panelX + 18, -- 1119
					cy, -- 1119
					7, -- 1119
					PALETTE.silkDim, -- 1119
					0.42, -- 1119
					3 -- 1119
				) -- 1119
			end -- 1119
			texts:put( -- 1122
				"sm", -- 1123
				row.title, -- 1124
				panelX + 42, -- 1125
				cy, -- 1126
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1127
				0, -- 1128
				0.5, -- 1129
				"Left", -- 1130
				active and 2.4 or 1.6, -- 1131
				active and 1 or 0.88, -- 1132
				0.08 -- 1133
			) -- 1133
			local val = valueTextOf(row.id) -- 1136
			if val ~= "" then -- 1137
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1138
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1139
				texts:put( -- 1140
					"sm", -- 1140
					decorated, -- 1140
					panelX + panelW - 24, -- 1140
					cy, -- 1140
					toColor(valCol), -- 1140
					1, -- 1140
					0.5, -- 1140
					"Right", -- 1140
					1, -- 1140
					active and 1 or 0.86, -- 1140
					0.08 -- 1140
				) -- 1140
			end -- 1140
			i = i + 1 -- 1106
		end -- 1106
	end -- 1106
	local backY = 40 + frame.safe.bottom * 0.45 -- 1144
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1145
	texts:put( -- 1150
		"xs", -- 1150
		hint, -- 1150
		w * 0.5, -- 1150
		backY + 14, -- 1150
		toColor(PALETTE.textDim), -- 1150
		0.5, -- 1150
		0.5, -- 1150
		"Center", -- 1150
		1.2, -- 1150
		0.84, -- 1150
		0.08 -- 1150
	) -- 1150
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1152
	if hit >= 0 then -- 1153
		self.settingsSelected = hit -- 1154
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1155
			return true -- 1156
		end -- 1156
		self:resetInput() -- 1158
		return false -- 1159
	end -- 1159
	if frame.keys.left or frame.prevTab then -- 1161
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1162
		if id ~= "back" then -- 1163
			applyDelta(id, -1) -- 1164
			self:resetInput() -- 1165
		end -- 1165
		return false -- 1167
	end -- 1167
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1169
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1170
		if applyDelta(id, 1) then -- 1171
			return true -- 1172
		end -- 1172
		self:resetInput() -- 1174
		return false -- 1175
	end -- 1175
	return false -- 1177
end -- 988
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi, showLedgerEntry, onOpenLedger) -- 1185
	if assistHintsEnabled == nil then -- 1196
		assistHintsEnabled = false -- 1196
	end -- 1196
	if safeUi == nil then -- 1198
		safeUi = ZERO_SAFE_INSETS -- 1198
	end -- 1198
	if showLedgerEntry == nil then -- 1199
		showLedgerEntry = false -- 1199
	end -- 1199
	self.time = self.time + dt -- 1202
	local frame = self:readFrame(input, uiScale, safeUi) -- 1203
	if self.pauseShowControls then -- 1205
		local ctrlAct = self:drawControls( -- 1206
			frame, -- 1206
			uiDraw, -- 1206
			uiInkDraw, -- 1206
			uiArt, -- 1206
			uiGlow, -- 1206
			texts, -- 1206
			w, -- 1206
			h, -- 1206
			"返回暂停" -- 1206
		) -- 1206
		if ctrlAct.type == "backTitle" then -- 1207
			self.pauseShowControls = false -- 1208
			self:resetInput() -- 1209
		end -- 1209
		return {type = "none"} -- 1211
	end -- 1211
	if self.pauseShowSettings then -- 1214
		if self:drawPauseSettings( -- 1215
			frame, -- 1215
			input, -- 1215
			uiDraw, -- 1215
			uiInkDraw, -- 1215
			uiArt, -- 1215
			uiGlow, -- 1215
			texts, -- 1215
			w, -- 1215
			h -- 1215
		) then -- 1215
			self.pauseShowSettings = false -- 1216
			self:resetInput() -- 1217
		end -- 1217
		return {type = "none"} -- 1219
	end -- 1219
	if frame.back then -- 1222
		self.pauseShowControls = false -- 1223
		self.pauseShowSettings = false -- 1224
		self:emitSound("pauseClose") -- 1225
		return {type = "resume"} -- 1226
	end -- 1226
	local allowFs = canToggleFullscreen() -- 1229
	local allowQuit = canQuitApp() -- 1230
	local pauseItems = __TS__ArrayFilter( -- 1231
		PAUSE_ITEMS, -- 1231
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) and (item.id ~= "ledger" or showLedgerEntry) end -- 1231
	) -- 1231
	if self.pauseSelected >= #pauseItems then -- 1236
		self.pauseSelected = 0 -- 1237
	end -- 1237
	uiDraw:drawRect( -- 1240
		Rect(0, 0, w, h), -- 1240
		Color(8, 10, 16, 102) -- 1240
	) -- 1240
	fillHGradRect( -- 1241
		uiDraw, -- 1241
		0, -- 1241
		0, -- 1241
		w * 0.27 + frame.safe.left, -- 1241
		h, -- 1241
		Color(9, 11, 18, 232), -- 1241
		Color(10, 13, 21, 198) -- 1241
	) -- 1241
	fillHGradRect( -- 1242
		uiDraw, -- 1242
		w * 0.27 + frame.safe.left, -- 1242
		0, -- 1242
		w * 0.21, -- 1242
		h, -- 1242
		Color(10, 13, 21, 198), -- 1242
		Color(10, 13, 21, 0) -- 1242
	) -- 1242
	local menuX = 110 + frame.safe.left * 0.6 -- 1244
	local compact = #pauseItems > 8 -- 1245
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1246
	uiArt:tryPlace( -- 1247
		"ink_vstream", -- 1247
		"pause_vstream", -- 1247
		menuX - 32, -- 1247
		h * 0.5, -- 1247
		34, -- 1247
		h * 0.78, -- 1247
		{ -- 1247
			color = toColor(PALETTE.silkDim), -- 1248
			opacity = 0.48, -- 1248
			layer = 1 -- 1248
		} -- 1248
	) -- 1248
	drawMistCurve( -- 1250
		uiArt, -- 1250
		"pause_mist", -- 1250
		menuX + 118, -- 1250
		headY - 8, -- 1250
		290, -- 1250
		72, -- 1250
		PALETTE.jadeMist, -- 1250
		0.2, -- 1250
		-1 -- 1250
	) -- 1250
	texts:put( -- 1252
		"banner", -- 1252
		"暂歇", -- 1252
		menuX + 16, -- 1252
		headY, -- 1252
		toColor(PALETTE.textBright), -- 1252
		0, -- 1252
		0.5, -- 1252
		"Left", -- 1252
		10, -- 1252
		0.98, -- 1252
		0.1 -- 1252
	) -- 1252
	texts:put( -- 1253
		"xs", -- 1253
		"月夜暂驻 · 卷页留痕", -- 1253
		menuX + 18, -- 1253
		headY - 36, -- 1253
		toColor(PALETTE.textDim), -- 1253
		0, -- 1253
		0.5, -- 1253
		"Left", -- 1253
		2, -- 1253
		0.8, -- 1253
		0.08 -- 1253
	) -- 1253
	drawHairline( -- 1254
		uiInkDraw, -- 1254
		uiArt, -- 1254
		"pause_div", -- 1254
		menuX + 124, -- 1254
		headY - 60, -- 1254
		240, -- 1254
		PALETTE.silkDim, -- 1254
		0.58, -- 1254
		true, -- 1254
		2 -- 1254
	) -- 1254
	local rowStep = compact and 42 or 46 -- 1256
	local rowH = compact and 36 or 38 -- 1257
	local firstY = compact and headY - 112 or headY - 120 -- 1258
	local boxes = {} -- 1259
	local i = 0 -- 1260
	do -- 1260
		i = 0 -- 1261
		while i < #pauseItems do -- 1261
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1262
			i = i + 1 -- 1261
		end -- 1261
	end -- 1261
	local prevPauseSel = self.pauseSelected -- 1264
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1265
	if self.pauseSelected ~= prevPauseSel then -- 1266
		self:emitSound("hover") -- 1267
	end -- 1267
	do -- 1267
		i = 0 -- 1270
		while i < #pauseItems do -- 1270
			local iy = boxes[i + 1].y -- 1271
			local active = self.pauseSelected == i -- 1272
			local cy = iy + rowH * 0.5 -- 1273
			local shiftX = active and 10 or 0 -- 1274
			local item = pauseItems[i + 1] -- 1275
			local label = item.zh -- 1276
			if item.id == "assist" then -- 1277
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1278
			elseif item.id == "fullscreen" then -- 1279
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1280
			elseif item.id == "settings" then -- 1281
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1282
			end -- 1282
			if active then -- 1285
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1286
				drawSilkRibbon( -- 1287
					uiDraw, -- 1287
					uiArt, -- 1287
					"pause_rib_" .. tostring(i), -- 1287
					menuX + 116, -- 1287
					cy, -- 1287
					282, -- 1287
					rowH, -- 1287
					PALETTE.rougeSoft, -- 1287
					0.54 * breathe, -- 1287
					0 -- 1287
				) -- 1287
				drawHairline( -- 1288
					uiInkDraw, -- 1288
					uiArt, -- 1288
					"pause_line_" .. tostring(i), -- 1288
					menuX + 106, -- 1288
					iy + 3, -- 1288
					210, -- 1288
					PALETTE.silkLine, -- 1288
					0.42 * breathe, -- 1288
					false, -- 1288
					2 -- 1288
				) -- 1288
				drawBlossomDot( -- 1289
					uiInkDraw, -- 1289
					uiArt, -- 1289
					"pause_dot_" .. tostring(i), -- 1289
					menuX + 12, -- 1289
					cy, -- 1289
					15, -- 1289
					PALETTE.rouge, -- 1289
					0.96, -- 1289
					4 -- 1289
				) -- 1289
				fillRadialGlow( -- 1290
					uiGlow, -- 1290
					menuX + 12, -- 1290
					cy, -- 1290
					22, -- 1290
					16, -- 1290
					toColor(PALETTE.rouge, 26 * breathe), -- 1290
					Color(182, 58, 56, 0), -- 1290
					10 -- 1290
				) -- 1290
			else -- 1290
				drawBlossomDot( -- 1292
					uiInkDraw, -- 1292
					uiArt, -- 1292
					"pause_dot_" .. tostring(i), -- 1292
					menuX + 12, -- 1292
					cy, -- 1292
					8, -- 1292
					PALETTE.silkDim, -- 1292
					0.4, -- 1292
					3 -- 1292
				) -- 1292
			end -- 1292
			texts:put( -- 1295
				compact and "sm" or "md", -- 1296
				label, -- 1297
				menuX + 32 + shiftX, -- 1298
				cy, -- 1299
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1300
				0, -- 1301
				0.5, -- 1302
				"Left", -- 1303
				active and 3.4 or 2.2, -- 1304
				active and 1 or 0.88, -- 1305
				0.1 -- 1306
			) -- 1306
			i = i + 1 -- 1270
		end -- 1270
	end -- 1270
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1310
	texts:put( -- 1315
		"xs", -- 1315
		pauseFooter, -- 1315
		menuX + 12, -- 1315
		38 + frame.safe.bottom * 0.4, -- 1315
		toColor(PALETTE.textDim), -- 1315
		0, -- 1315
		0.5, -- 1315
		"Left", -- 1315
		1.2, -- 1315
		0.86, -- 1315
		0.08 -- 1315
	) -- 1315
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1317
	if hit >= 0 or frame.keys.confirm then -- 1318
		local idx = hit >= 0 and hit or self.pauseSelected -- 1319
		local id = pauseItems[idx + 1].id -- 1320
		if id == "controls" then -- 1321
			self.pauseShowControls = true -- 1322
			self:emitSound("confirm") -- 1323
			self:resetInput() -- 1324
			return {type = "none"} -- 1325
		end -- 1325
		if id == "settings" then -- 1327
			self:openPauseSettings() -- 1328
			self:emitSound("confirm") -- 1329
			return {type = "none"} -- 1330
		end -- 1330
		if id == "ledger" then -- 1332
			if onOpenLedger ~= nil then -- 1333
				onOpenLedger() -- 1334
			end -- 1334
			self.pauseShowControls = false -- 1336
			self.pauseShowSettings = false -- 1337
			self:emitSound("confirm") -- 1338
			return {type = "resume"} -- 1339
		end -- 1339
		if id == "assist" then -- 1341
			if onToggleAssist ~= nil then -- 1342
				onToggleAssist() -- 1343
			end -- 1343
			self:emitSound("toggle") -- 1345
			self:resetInput() -- 1346
			return {type = "none"} -- 1347
		end -- 1347
		if id == "fullscreen" then -- 1349
			self:emitSound("toggle") -- 1350
			self:resetInput() -- 1351
			return {type = "toggleFullscreen"} -- 1352
		end -- 1352
		self.pauseShowControls = false -- 1354
		self.pauseShowSettings = false -- 1355
		if id == "resume" then -- 1356
			self:emitSound("pauseClose") -- 1356
			return {type = "resume"} -- 1356
		end -- 1356
		if id == "retry" then -- 1357
			self:emitSound("confirm") -- 1357
			return {type = "retry"} -- 1357
		end -- 1357
		if id == "chapters" then -- 1358
			self:emitSound("confirm") -- 1358
			return {type = "openChapters"} -- 1358
		end -- 1358
		if id == "quit" then -- 1359
			self:emitSound("back") -- 1359
			return {type = "quit"} -- 1359
		end -- 1359
		self:emitSound("back") -- 1360
		return {type = "toTitle"} -- 1361
	end -- 1361
	return {type = "none"} -- 1363
end -- 1185
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1370
	if frame.back then -- 1380
		return {type = "backTitle"} -- 1381
	end -- 1381
	uiDraw:drawRect( -- 1385
		Rect(0, 0, w, h), -- 1385
		Color(7, 9, 15, 214) -- 1385
	) -- 1385
	local cx = w * 0.5 -- 1386
	local reunion = self.epilogueEnding == "reunion" -- 1387
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1388
	drawMistCurve( -- 1389
		uiArt, -- 1389
		"ep_mist", -- 1389
		cx, -- 1389
		h * 0.62, -- 1389
		620, -- 1389
		120, -- 1389
		accentCol, -- 1389
		0.2, -- 1389
		0 -- 1389
	) -- 1389
	fillRadialGlow( -- 1390
		uiGlow, -- 1390
		cx, -- 1390
		h * 0.68, -- 1390
		220, -- 1390
		140, -- 1390
		toColor(accentCol, 28), -- 1390
		Color(10, 14, 22, 0), -- 1390
		18 -- 1390
	) -- 1390
	local titleY = h * 0.72 -- 1393
	texts:put( -- 1394
		"title", -- 1394
		"向西守望", -- 1394
		cx - 18, -- 1394
		titleY, -- 1394
		toColor(PALETTE.textBright), -- 1394
		0.5, -- 1394
		0.5, -- 1394
		"Center", -- 1394
		12, -- 1394
		0.98, -- 1394
		0.12 -- 1394
	) -- 1394
	drawLoneSeal( -- 1395
		uiInkDraw, -- 1395
		uiArt, -- 1395
		texts, -- 1395
		"ep_seal", -- 1395
		cx + 148, -- 1395
		titleY - 2, -- 1395
		24, -- 1395
		46, -- 1395
		"守", -- 1395
		"望", -- 1395
		PALETTE.sealRed, -- 1395
		PALETTE.sealText, -- 1395
		0.94, -- 1395
		4 -- 1395
	) -- 1395
	drawHairline( -- 1396
		uiInkDraw, -- 1396
		uiArt, -- 1396
		"ep_div", -- 1396
		cx, -- 1396
		titleY - 46, -- 1396
		360, -- 1396
		PALETTE.silkDim, -- 1396
		0.62, -- 1396
		true, -- 1396
		2 -- 1396
	) -- 1396
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1398
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1399
	texts:put( -- 1402
		"md", -- 1402
		endingTitle, -- 1402
		cx, -- 1402
		titleY - 76, -- 1402
		toColor(PALETTE.amberCore), -- 1402
		0.5, -- 1402
		0.5, -- 1402
		"Center", -- 1402
		3.2, -- 1402
		0.96, -- 1402
		0.08 -- 1402
	) -- 1402
	texts:put( -- 1403
		"sm", -- 1403
		verse, -- 1403
		cx, -- 1403
		titleY - 114, -- 1403
		toColor(PALETTE.textMid), -- 1403
		0.5, -- 1403
		0.5, -- 1403
		"Center", -- 1403
		1, -- 1403
		0.92, -- 1403
		0.08 -- 1403
	) -- 1403
	if self.epilogueBothCleared then -- 1405
		drawSilkVeil( -- 1406
			uiDraw, -- 1406
			uiArt, -- 1406
			"ep_well_veil", -- 1406
			cx, -- 1406
			titleY - 152, -- 1406
			560, -- 1406
			30, -- 1406
			PALETTE.inkWarm, -- 1406
			0.68, -- 1406
			0 -- 1406
		) -- 1406
		texts:put( -- 1407
			"xs", -- 1407
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1407
			cx, -- 1407
			titleY - 152, -- 1407
			toColor(PALETTE.cyanCore), -- 1407
			0.5, -- 1407
			0.5, -- 1407
			"Center", -- 1407
			1, -- 1407
			0.9, -- 1407
			0.08 -- 1407
		) -- 1407
	end -- 1407
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1410
	local btnW = 286 -- 1415
	local btnH = 44 -- 1416
	local gap = 14 -- 1417
	local baseY = math.max(150, h * 0.34) -- 1418
	local boxes = {} -- 1419
	local i = 0 -- 1420
	do -- 1420
		i = 0 -- 1421
		while i < #items do -- 1421
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1422
			i = i + 1 -- 1421
		end -- 1421
	end -- 1421
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1424
	do -- 1424
		i = 0 -- 1426
		while i < #items do -- 1426
			local box = boxes[i + 1] -- 1427
			local active = self.epilogueSelected == i -- 1428
			local cy = box.y + box.height * 0.5 -- 1429
			if active then -- 1430
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1431
				drawSilkRibbon( -- 1432
					uiDraw, -- 1432
					uiArt, -- 1432
					"ep_rib_" .. tostring(i), -- 1432
					cx, -- 1432
					cy, -- 1432
					btnW + 24, -- 1432
					btnH, -- 1432
					PALETTE.rougeSoft, -- 1432
					0.62 * breathe, -- 1432
					0 -- 1432
				) -- 1432
				drawHairline( -- 1433
					uiInkDraw, -- 1433
					uiArt, -- 1433
					"ep_line_" .. tostring(i), -- 1433
					cx, -- 1433
					box.y + 3, -- 1433
					btnW - 44, -- 1433
					PALETTE.silkLine, -- 1433
					0.48 * breathe, -- 1433
					false, -- 1433
					2 -- 1433
				) -- 1433
				drawBlossomDot( -- 1434
					uiInkDraw, -- 1434
					uiArt, -- 1434
					"ep_dot_" .. tostring(i), -- 1434
					box.x + 22, -- 1434
					cy, -- 1434
					13, -- 1434
					PALETTE.rouge, -- 1434
					0.96, -- 1434
					4 -- 1434
				) -- 1434
			else -- 1434
				drawSilkVeil( -- 1436
					uiDraw, -- 1436
					uiArt, -- 1436
					"ep_idle_" .. tostring(i), -- 1436
					cx, -- 1436
					cy, -- 1436
					btnW, -- 1436
					btnH - 2, -- 1436
					PALETTE.inkWash, -- 1436
					0.58, -- 1436
					0 -- 1436
				) -- 1436
				drawBlossomDot( -- 1437
					uiInkDraw, -- 1437
					uiArt, -- 1437
					"ep_dot_" .. tostring(i), -- 1437
					box.x + 22, -- 1437
					cy, -- 1437
					8, -- 1437
					PALETTE.silkDim, -- 1437
					0.42, -- 1437
					3 -- 1437
				) -- 1437
			end -- 1437
			texts:put( -- 1439
				"sm", -- 1440
				items[i + 1].zh, -- 1441
				cx + 6, -- 1442
				cy, -- 1443
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1444
				0.5, -- 1445
				0.5, -- 1446
				"Center", -- 1447
				active and 2.6 or 1.6, -- 1448
				active and 1 or 0.88, -- 1449
				0.08 -- 1450
			) -- 1450
			i = i + 1 -- 1426
		end -- 1426
	end -- 1426
	local footer = frame.mode == "gamepad" and ((keyTagFor("confirm", "gamepad", frame.layout) .. " 确认   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回标题" or (frame.mode == "touch" and "轻触任一入口继续" or "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题") -- 1454
	texts:put( -- 1457
		"xs", -- 1457
		footer, -- 1457
		cx, -- 1457
		38 + frame.safe.bottom * 0.4, -- 1457
		toColor(PALETTE.textDim), -- 1457
		0.5, -- 1457
		0.5, -- 1457
		"Center", -- 1457
		1.2, -- 1457
		0.84, -- 1457
		0.08 -- 1457
	) -- 1457
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1459
	if hit >= 0 or frame.keys.confirm then -- 1460
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1461
		local id = items[idx + 1].id -- 1462
		if id == "history" then -- 1463
			return {type = "openHistory"} -- 1463
		end -- 1463
		if id == "replay" then -- 1464
			return {type = "replayStory"} -- 1464
		end -- 1464
		return {type = "backTitle"} -- 1465
	end -- 1465
	return {type = "none"} -- 1467
end -- 1370
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1474
	if frame.back then -- 1484
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1485
	end -- 1485
	local total = #HISTORY_CARDS -- 1488
	if frame.keys.left or frame.prevTab then -- 1489
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1490
	elseif frame.keys.right or frame.nextTab then -- 1491
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1492
	end -- 1492
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1494
	uiDraw:drawRect( -- 1496
		Rect(0, 0, w, h), -- 1496
		Color(7, 9, 15, 206) -- 1496
	) -- 1496
	local cx = w * 0.5 -- 1497
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1498
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1499
	local px = cx - pageW * 0.5 -- 1500
	local py = (h - pageH) * 0.5 + 14 -- 1501
	local midY = py + pageH * 0.5 -- 1502
	uiArt:tryPlace( -- 1504
		"ink_frame_mask", -- 1504
		"hist_shadow", -- 1504
		cx, -- 1504
		midY - 6, -- 1504
		pageW + 52, -- 1504
		pageH + 46, -- 1504
		{ -- 1504
			color = toColor(PALETTE.voidDark), -- 1505
			opacity = 0.84, -- 1505
			layer = -1 -- 1505
		} -- 1505
	) -- 1505
	if not uiArt:tryPlace( -- 1507
		"ink_song_paper", -- 1507
		"hist_paper", -- 1507
		cx, -- 1507
		midY, -- 1507
		pageW, -- 1507
		pageH, -- 1507
		{opacity = 0.98, layer = 1} -- 1507
	) then -- 1507
		uiDraw:drawRect( -- 1508
			Rect(px, py, pageW, pageH), -- 1508
			toColor(PALETTE.xuanPaper, 248), -- 1508
			1, -- 1508
			toColor(PALETTE.silkDim, 180) -- 1508
		) -- 1508
	end -- 1508
	fillRadialGlow( -- 1510
		uiGlow, -- 1510
		cx, -- 1510
		midY + 40, -- 1510
		260, -- 1510
		140, -- 1510
		Color(236, 224, 202, 16), -- 1510
		Color(236, 224, 202, 0), -- 1510
		14 -- 1510
	) -- 1510
	local inX = px + 42 -- 1513
	local inY = py + 32 -- 1514
	local inW = pageW - 84 -- 1515
	local inH = pageH - 64 -- 1516
	local redSilk = toColor(PALETTE.rouge, 118) -- 1517
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1518
	uiInkDraw:drawRect( -- 1519
		Rect(inX, inY, inW, inH), -- 1519
		Color(0, 0, 0, 0), -- 1519
		0.95, -- 1519
		redSilk -- 1519
	) -- 1519
	uiInkDraw:drawRect( -- 1520
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1520
		Color(0, 0, 0, 0), -- 1520
		0.55, -- 1520
		redSilkFaint -- 1520
	) -- 1520
	local headY = inY + inH - 30 -- 1523
	texts:put( -- 1524
		"md", -- 1524
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1524
		inX + 20, -- 1524
		headY, -- 1524
		toColor(PALETTE.xuanInk), -- 1524
		0, -- 1524
		0.5, -- 1524
		"Left", -- 1524
		2, -- 1524
		0.96, -- 1524
		0 -- 1524
	) -- 1524
	texts:put( -- 1525
		"xs", -- 1525
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1525
		inX + inW - 20, -- 1525
		headY, -- 1525
		toColor(PALETTE.rouge), -- 1525
		1, -- 1525
		0.5, -- 1525
		"Right", -- 1525
		1.8, -- 1525
		0.88, -- 1525
		0 -- 1525
	) -- 1525
	uiInkDraw:drawSegment( -- 1526
		Vec2(inX + 14, headY - 22), -- 1526
		Vec2(inX + inW - 14, headY - 22), -- 1526
		0.85, -- 1526
		redSilk -- 1526
	) -- 1526
	texts:put( -- 1529
		"xs", -- 1529
		card.subtitle, -- 1529
		inX + 20, -- 1529
		headY - 42, -- 1529
		toColor(PALETTE.xuanInkSub), -- 1529
		0, -- 1529
		0.5, -- 1529
		"Left", -- 1529
		1.4, -- 1529
		0.86, -- 1529
		0 -- 1529
	) -- 1529
	local function wrapZh(src, maxUnits) -- 1532
		local out = {} -- 1533
		local buf = "" -- 1534
		local units = 0 -- 1535
		local ci = 0 -- 1536
		while ci < #src do -- 1537
			local b = __TS__StringCharCodeAt(src, ci) -- 1538
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1539
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1540
			local u = b < 128 and 0.56 or 1.02 -- 1541
			if units + u > maxUnits and buf ~= "" then -- 1542
				out[#out + 1] = buf -- 1543
				buf = ch -- 1544
				units = u -- 1545
			else -- 1545
				buf = buf .. ch -- 1547
				units = units + u -- 1548
			end -- 1548
			ci = ci + step -- 1550
		end -- 1550
		if buf ~= "" then -- 1552
			out[#out + 1] = buf -- 1553
		end -- 1553
		return out -- 1555
	end -- 1532
	local charsPerLine = math.max( -- 1558
		24, -- 1558
		math.floor((inW - 44) / 20) -- 1558
	) -- 1558
	local cursorY = headY - 76 -- 1559
	local pi = 0 -- 1560
	do -- 1560
		pi = 0 -- 1561
		while pi < #card.paragraphs do -- 1561
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1562
			local li = 0 -- 1563
			do -- 1563
				li = 0 -- 1564
				while li < #lines do -- 1564
					texts:put( -- 1565
						"sm", -- 1565
						lines[li + 1], -- 1565
						inX + 22, -- 1565
						cursorY, -- 1565
						toColor(PALETTE.xuanInk), -- 1565
						0, -- 1565
						0.5, -- 1565
						"Left", -- 1565
						0.6, -- 1565
						0.94, -- 1565
						0 -- 1565
					) -- 1565
					cursorY = cursorY - 30 -- 1566
					li = li + 1 -- 1564
				end -- 1564
			end -- 1564
			cursorY = cursorY - 12 -- 1568
			pi = pi + 1 -- 1561
		end -- 1561
	end -- 1561
	local footY = inY + 26 -- 1572
	uiInkDraw:drawSegment( -- 1573
		Vec2(inX + 14, footY + 20), -- 1573
		Vec2(inX + inW - 14, footY + 20), -- 1573
		0.6, -- 1573
		redSilkFaint -- 1573
	) -- 1573
	texts:put( -- 1574
		"xs", -- 1574
		card.footnote, -- 1574
		inX + 20, -- 1574
		footY, -- 1574
		toColor(PALETTE.xuanInkSub), -- 1574
		0, -- 1574
		0.5, -- 1574
		"Left", -- 1574
		0.4, -- 1574
		0.84, -- 1574
		0 -- 1574
	) -- 1574
	local navY = math.max(30, py - 48) -- 1577
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1578
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1579
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1580
	local function drawNavBtn(box, tag, label) -- 1582
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1583
		drawSilkVeil( -- 1584
			uiDraw, -- 1584
			uiArt, -- 1584
			"hist_btn_" .. tag, -- 1584
			box.x + box.width * 0.5, -- 1584
			box.y + box.height * 0.5, -- 1584
			box.width, -- 1584
			box.height, -- 1584
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1584
			hover and 0.86 or 0.72, -- 1584
			2 -- 1584
		) -- 1584
		texts:put( -- 1585
			"xs", -- 1585
			label, -- 1585
			box.x + box.width * 0.5, -- 1585
			box.y + box.height * 0.5, -- 1585
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1585
			0.5, -- 1585
			0.5, -- 1585
			"Center", -- 1585
			1.4, -- 1585
			0.94, -- 1585
			0.08 -- 1585
		) -- 1585
		return hover and frame.click -- 1586
	end -- 1582
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1589
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1590
	end -- 1590
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1592
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1593
	end -- 1593
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1595
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1596
	end -- 1596
	if frame.keys.confirm then -- 1599
		if self.historyCardIndex + 1 < total then -- 1600
			self.historyCardIndex = self.historyCardIndex + 1 -- 1601
		else -- 1601
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1603
		end -- 1603
	end -- 1603
	return {type = "none"} -- 1606
end -- 1474
return ____exports -- 1474
