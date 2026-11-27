-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
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
local TITLE_ITEMS = { -- 87
	{id = "start", zh = "开始游戏"}, -- 88
	{id = "chapters", zh = "选择章节"}, -- 89
	{id = "controls", zh = "操作说明"}, -- 90
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 91
	{id = "quit", zh = "退出游戏"} -- 92
} -- 92
local CHAPTERS = (function() -- 107
	local out = {} -- 108
	local i = 0 -- 109
	do -- 109
		i = 0 -- 110
		while i < #ROOMS do -- 110
			do -- 110
				local room = ROOMS[i + 1] -- 111
				if room.key == "museum" or room.key == "street" or room.key == "checkpoint" then -- 112
					goto __continue4 -- 113
				end -- 113
				if room.key == "tower" then -- 115
					out[#out + 1] = { -- 116
						room = room, -- 117
						roomIndex = i, -- 118
						route = "child", -- 119
						titleOverride = "终章 · 北塔留灯", -- 120
						shortNameOverride = "北塔·留灯", -- 121
						lineTagOverride = "小满", -- 122
						whisperOverride = "孤身叩响北塔门，西窗留一盏向西的灯。" -- 123
					} -- 123
					out[#out + 1] = { -- 125
						room = room, -- 126
						roomIndex = i, -- 127
						route = "soldier", -- 128
						titleOverride = "终章 · 北塔团圆", -- 129
						shortNameOverride = "北塔·团圆", -- 130
						lineTagOverride = "周戍", -- 131
						whisperOverride = "兄妹并肩跨过塔门，两行姓名同落登记簿。" -- 132
					} -- 132
					goto __continue4 -- 134
				end -- 134
				out[#out + 1] = {room = room, roomIndex = i} -- 136
			end -- 136
			::__continue4:: -- 136
			i = i + 1 -- 110
		end -- 110
	end -- 110
	return out -- 138
end)() -- 107
local PAUSE_ITEMS = { -- 142
	{id = "resume", zh = "继续游戏"}, -- 143
	{id = "retry", zh = "重试检查点"}, -- 144
	{id = "controls", zh = "操作说明"}, -- 145
	{id = "assist", zh = "按键辅助：关"}, -- 146
	{id = "fullscreen", zh = "显示：窗口"}, -- 147
	{id = "chapters", zh = "选择章节"}, -- 148
	{id = "title", zh = "返回标题"}, -- 149
	{id = "quit", zh = "退出游戏"}, -- 150
	{id = "settings", zh = "操控设置"} -- 151
} -- 151
local SETTINGS_ROWS = { -- 155
	{id = "modePref", title = "操作模式"}, -- 156
	{id = "aimAssist", title = "瞄准磁吸"}, -- 157
	{id = "gpLayout", title = "手柄确认键"}, -- 158
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 159
	{id = "touchOpacity", title = "触控按键透度"}, -- 160
	{id = "touchScale", title = "触控按键大小"}, -- 161
	{id = "haptics", title = "触觉震动反馈"}, -- 162
	{id = "masterVol", title = "主音量"}, -- 163
	{id = "bgmVol", title = "音乐音量"}, -- 164
	{id = "sfxVol", title = "音效与环境"}, -- 165
	{id = "voiceVol", title = "人声音量"}, -- 166
	{id = "back", title = "返回暂歇菜单"} -- 167
} -- 167
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 170
local EPIGRAPH_RIGHT = { -- 171
	"城", -- 171
	"破", -- 171
	"那", -- 171
	"天", -- 171
	"", -- 171
	"他", -- 171
	"留", -- 171
	"下", -- 171
	"断", -- 171
	"后" -- 171
} -- 171
local EPIGRAPH_LEFT = { -- 172
	"她", -- 172
	"独", -- 172
	"自", -- 172
	"走", -- 172
	"向", -- 172
	"北", -- 172
	"塔" -- 172
} -- 172
local function pressedKeys() -- 197
	return { -- 198
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 199
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 200
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 201
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 202
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 203
	} -- 203
end -- 197
local function hitIndex(boxes, pointer, inside) -- 207
	if not inside then -- 208
		return -1 -- 209
	end -- 209
	return __TS__ArrayFindIndex( -- 211
		boxes, -- 211
		function(____, box) return box:containsPoint(pointer) end -- 211
	) -- 211
end -- 207
____exports.MenuRenderer = __TS__Class() -- 214
local MenuRenderer = ____exports.MenuRenderer -- 214
MenuRenderer.name = "MenuRenderer" -- 214
function MenuRenderer.prototype.____constructor(self) -- 214
	self.selected = 0 -- 215
	self.chapterSelected = 0 -- 216
	self.pauseSelected = 0 -- 217
	self.settingsSelected = 0 -- 218
	self.epilogueSelected = 0 -- 219
	self.epilogueEnding = "lamp" -- 220
	self.epilogueBothCleared = false -- 221
	self.historyCardIndex = 0 -- 222
	self.historyFromEpilogue = false -- 223
	self.hasSession = false -- 225
	self.sessionLabel = "" -- 227
	self.controlsTab = "kbm" -- 233
	self.chaptersFromPause = false -- 245
	self.pauseShowControls = false -- 246
	self.pauseShowSettings = false -- 247
	self.controlsTabManual = false -- 248
	self.previousKeys = {} -- 249
	self.queuedKeys = {} -- 250
	self.queuedBack = false -- 251
	self.queuedSkip = false -- 252
	self.splashTime = 0 -- 253
	self.time = 0 -- 254
end -- 214
function MenuRenderer.prototype.setSessionRoomKey(self, roomKey) -- 229
	self.sessionLabel = roomKey ~= "" and themeOf(roomKey).shortNameZh or "" -- 230
end -- 229
function MenuRenderer.prototype.emitSound(self, kind) -- 239
	if self.onUiSound ~= nil then -- 240
		self:onUiSound(kind) -- 241
	end -- 241
end -- 239
function MenuRenderer.prototype.resetSplash(self) -- 256
	self.splashTime = 0 -- 257
	self.queuedSkip = false -- 258
	self:resetInput() -- 259
end -- 256
function MenuRenderer.prototype.isShowingPauseControls(self) -- 262
	return self.pauseShowControls -- 263
end -- 262
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 266
	return self.pauseShowSettings -- 267
end -- 266
function MenuRenderer.prototype.openPauseSettings(self) -- 270
	self.pauseShowControls = false -- 271
	self.pauseShowSettings = true -- 272
	self.settingsSelected = 0 -- 273
	self:resetInput() -- 274
end -- 270
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 277
	self.chaptersFromPause = roomIndex ~= nil -- 278
	self.chapterSelected = math.max( -- 279
		0, -- 279
		__TS__ArrayFindIndex( -- 279
			CHAPTERS, -- 279
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 279
		) -- 279
	) -- 279
	self.pauseShowControls = false -- 280
	self.pauseShowSettings = false -- 281
	self:resetInput() -- 282
end -- 277
function MenuRenderer.prototype.openPause(self) -- 285
	self.pauseSelected = 0 -- 286
	self.pauseShowControls = false -- 287
	self.pauseShowSettings = false -- 288
	self:resetInput() -- 289
end -- 285
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 292
	if ending == nil then -- 292
		ending = "lamp" -- 292
	end -- 292
	if bothCleared == nil then -- 292
		bothCleared = false -- 292
	end -- 292
	self.epilogueEnding = ending -- 293
	self.epilogueBothCleared = bothCleared -- 294
	self.epilogueSelected = 0 -- 295
	self:resetInput() -- 296
end -- 292
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 299
	if fromEpilogue == nil then -- 299
		fromEpilogue = true -- 299
	end -- 299
	self.historyFromEpilogue = fromEpilogue -- 300
	self.historyCardIndex = 0 -- 301
	self:resetInput() -- 302
end -- 299
function MenuRenderer.prototype.triggerBack(self) -- 306
	self.queuedBack = true -- 307
end -- 306
function MenuRenderer.prototype.resetInput(self) -- 311
	self.previousKeys = pressedKeys() -- 312
	self.queuedKeys = {} -- 313
	self.queuedBack = false -- 314
	self.queuedSkip = false -- 315
	self.controlsTabManual = false -- 316
end -- 311
function MenuRenderer.prototype.onKeyEvent(self, key) -- 320
	self.queuedSkip = true -- 321
	if key == "Up" or key == "W" then -- 322
		self.queuedKeys.up = true -- 323
	elseif key == "Down" or key == "S" then -- 324
		self.queuedKeys.down = true -- 325
	elseif key == "Left" or key == "A" then -- 326
		self.queuedKeys.left = true -- 327
	elseif key == "Right" or key == "D" then -- 328
		self.queuedKeys.right = true -- 329
	elseif key == "Return" or key == "Space" then -- 330
		self.queuedKeys.confirm = true -- 331
	elseif key == "Escape" then -- 332
		self.queuedBack = true -- 333
	end -- 333
end -- 320
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 337
	local held = pressedKeys() -- 338
	local prev = self.previousKeys -- 339
	local queued = self.queuedKeys -- 340
	local useUiPtr = input.uiInside or input.uiPressed -- 343
	local rawX = useUiPtr and input.uiX or input.mx -- 344
	local rawY = useUiPtr and input.uiY or input.my -- 345
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 346
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 347
	local ____useUiPtr_0 -- 348
	if useUiPtr then -- 348
		____useUiPtr_0 = input.uiInside -- 348
	else -- 348
		____useUiPtr_0 = input.inside -- 348
	end -- 348
	local inside = ____useUiPtr_0 -- 348
	local ____useUiPtr_1 -- 349
	if useUiPtr then -- 349
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 349
	else -- 349
		____useUiPtr_1 = input.inside and input.fire.pressed -- 349
	end -- 349
	local click = ____useUiPtr_1 -- 349
	local touchMode = input:isTouchMode() -- 350
	local frame = { -- 352
		keys = { -- 353
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 354
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 355
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 356
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 357
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 358
		}, -- 358
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 360
		prevTab = input.navPrevTab, -- 361
		nextTab = input.navNextTab, -- 362
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 363
		pointer = Vec2(rawX / scale, rawY / scale), -- 364
		inside = inside, -- 365
		click = click, -- 366
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 367
		mode = input.inputMode, -- 368
		layout = input.gamepadLayout, -- 369
		safe = safe -- 370
	} -- 370
	self.previousKeys = held -- 372
	self.queuedKeys = {} -- 373
	self.queuedBack = false -- 374
	self.queuedSkip = false -- 375
	return frame -- 376
end -- 337
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 379
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 380
	if frame.click and hit >= 0 then -- 381
		return hit -- 382
	end -- 382
	if frame.keys.up then -- 384
		return (selected + #boxes - 1) % #boxes -- 385
	end -- 385
	if frame.keys.down then -- 387
		return (selected + 1) % #boxes -- 388
	end -- 388
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 390
end -- 379
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 393
	if safeUi == nil then -- 409
		safeUi = ZERO_SAFE_INSETS -- 409
	end -- 409
	self.time = self.time + dt -- 411
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 412
	if screen ~= "splash" or splashDissolving then -- 413
		local artW = math.max(w, h * 16 / 9) -- 414
		local artH = artW * 9 / 16 -- 415
		if not backdropArt:tryPlace( -- 416
			"title_backdrop", -- 416
			"menu_landscape", -- 416
			w * 0.5, -- 416
			(h - artH) * 0.5, -- 416
			artW, -- 416
			artH -- 416
		) then -- 416
			stage:drawMenuBackdrop( -- 417
				bgDraw, -- 417
				bgGlow, -- 417
				w, -- 417
				h, -- 417
				self.time -- 417
			) -- 417
		end -- 417
	end -- 417
	local frame = self:readFrame(input, uiScale, safeUi) -- 421
	w = w / uiScale -- 422
	h = h / uiScale -- 423
	if screen == "splash" then -- 425
		return self:drawSplash( -- 426
			dt, -- 426
			frame, -- 426
			uiDraw, -- 426
			uiArt, -- 426
			texts, -- 426
			w, -- 426
			h -- 426
		) -- 426
	end -- 426
	if screen == "title" then -- 428
		return self:drawTitle( -- 429
			frame, -- 429
			uiDraw, -- 429
			uiInkDraw, -- 429
			uiArt, -- 429
			uiGlow, -- 429
			texts, -- 429
			w, -- 429
			h -- 429
		) -- 429
	end -- 429
	if screen == "chapters" then -- 431
		return self:drawChapters( -- 432
			frame, -- 432
			uiDraw, -- 432
			uiInkDraw, -- 432
			uiArt, -- 432
			uiGlow, -- 432
			texts, -- 432
			w, -- 432
			h -- 432
		) -- 432
	end -- 432
	if screen == "epilogue" then -- 434
		return self:drawEpilogue( -- 435
			frame, -- 435
			uiDraw, -- 435
			uiInkDraw, -- 435
			uiArt, -- 435
			uiGlow, -- 435
			texts, -- 435
			w, -- 435
			h -- 435
		) -- 435
	end -- 435
	if screen == "history" then -- 437
		return self:drawHistory( -- 438
			frame, -- 438
			uiDraw, -- 438
			uiInkDraw, -- 438
			uiArt, -- 438
			uiGlow, -- 438
			texts, -- 438
			w, -- 438
			h -- 438
		) -- 438
	end -- 438
	return self:drawControls( -- 440
		frame, -- 440
		uiDraw, -- 440
		uiInkDraw, -- 440
		uiArt, -- 440
		uiGlow, -- 440
		texts, -- 440
		w, -- 440
		h -- 440
	) -- 440
end -- 393
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 449
	local safeDt = math.min( -- 458
		0.1, -- 458
		math.max(0, dt) -- 458
	) -- 458
	self.splashTime = self.splashTime + safeDt -- 459
	local t = self.splashTime -- 460
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 462
	if wantSkip or t >= 4.65 then -- 463
		self.splashTime = 0 -- 464
		return {type = "splashDone"} -- 465
	end -- 465
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 468
	local bgR = t < 2.2 and 13 or 11 -- 469
	local bgG = t < 2.2 and 16 or 13 -- 470
	local bgB = t < 2.2 and 24 or 19 -- 471
	uiDraw:drawRect( -- 472
		Rect(0, 0, w, h), -- 472
		Color( -- 472
			bgR, -- 472
			bgG, -- 472
			bgB, -- 472
			math.floor(255 * fadeOutCurtain + 0.5) -- 472
		) -- 472
	) -- 472
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 474
		if localT <= 0 or localT >= endT then -- 475
			return 0 -- 475
		end -- 475
		if localT < fadeIn then -- 476
			local u = localT / fadeIn -- 477
			return u * u * (3 - 2 * u) -- 478
		end -- 478
		if localT <= holdEnd then -- 480
			return 1 -- 480
		end -- 480
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 481
		return 1 - u * u * (3 - 2 * u) -- 482
	end -- 474
	if t < 2.2 then -- 485
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 486
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 487
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 488
		if not uiArt:tryPlace( -- 489
			"brand_team_logo", -- 489
			"splash_team_logo", -- 489
			w * 0.5, -- 489
			h * 0.54, -- 489
			logoH * 2, -- 489
			logoH, -- 489
			{opacity = alpha, layer = 2} -- 489
		) then -- 489
			texts:put( -- 490
				"banner", -- 490
				"OUTSIDER", -- 490
				w * 0.5, -- 490
				h * 0.52, -- 490
				toColor(PALETTE.textBright), -- 490
				0.5, -- 490
				0.5, -- 490
				"Center", -- 490
				6, -- 490
				alpha, -- 490
				0 -- 490
			) -- 490
		end -- 490
		texts:put( -- 492
			"xs", -- 492
			"Powered by Dora SSR", -- 492
			w * 0.5, -- 492
			58 + frame.safe.bottom * 0.4, -- 492
			toColor(PALETTE.textDim), -- 492
			0.5, -- 492
			0.5, -- 492
			"Center", -- 492
			1.8, -- 492
			alpha * 0.62, -- 492
			0 -- 492
		) -- 492
	elseif t < 4.25 then -- 493
		local localT = t - 2.2 -- 494
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 495
		local sway = math.sin(localT * 1.1) * 8 -- 496
		drawMistCurve( -- 497
			uiArt, -- 497
			"splash_game_mist", -- 497
			w * 0.5 + sway, -- 497
			h * 0.46, -- 497
			560, -- 497
			110, -- 497
			PALETTE.jadeMist, -- 497
			0.16 * alpha, -- 497
			1 -- 497
		) -- 497
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 498
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 499
		if not uiArt:tryPlace( -- 500
			"brand_game_logo_h", -- 500
			"splash_game_logo", -- 500
			w * 0.5, -- 500
			h * 0.52, -- 500
			logoH * 2.4, -- 500
			logoH, -- 500
			{opacity = alpha, layer = 2} -- 500
		) then -- 500
			texts:put( -- 501
				"title", -- 501
				"向西守望", -- 501
				w * 0.5, -- 501
				h * 0.52, -- 501
				toColor(PALETTE.textBright), -- 501
				0.5, -- 501
				0.5, -- 501
				"Center", -- 501
				8, -- 501
				alpha, -- 501
				0 -- 501
			) -- 501
		end -- 501
	end -- 501
	if t >= 0.35 and t < 4.15 then -- 505
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 506
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 507
		texts:put( -- 512
			"xs", -- 512
			skipText, -- 512
			w - 48 - frame.safe.right * 0.6, -- 512
			36 + frame.safe.bottom * 0.4, -- 512
			toColor(PALETTE.textDim), -- 512
			1, -- 512
			0.5, -- 512
			"Right", -- 512
			1.4, -- 512
			hintA, -- 512
			0 -- 512
		) -- 512
	end -- 512
	return {type = "none"} -- 515
end -- 449
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 518
	fillHGradRect( -- 528
		uiDraw, -- 528
		0, -- 528
		0, -- 528
		w * 0.22 + frame.safe.left * 0.5, -- 528
		h, -- 528
		Color(9, 11, 18, 192), -- 528
		Color(9, 11, 18, 116) -- 528
	) -- 528
	fillHGradRect( -- 529
		uiDraw, -- 529
		w * 0.22 + frame.safe.left * 0.5, -- 529
		0, -- 529
		w * 0.28, -- 529
		h, -- 529
		Color(9, 11, 18, 116), -- 529
		Color(9, 11, 18, 0) -- 529
	) -- 529
	fillVGradRect( -- 530
		uiDraw, -- 530
		0, -- 530
		0, -- 530
		w, -- 530
		78, -- 530
		Color(8, 10, 16, 138), -- 530
		Color(8, 10, 16, 0) -- 530
	) -- 530
	local extraH = math.max(0, h - 720) -- 532
	local titleX = 148 + frame.safe.left * 0.6 -- 533
	local topY = h - 104 - frame.safe.top * 0.4 -- 534
	local charStep = 66 -- 535
	local sway = math.sin(self.time * 0.7) * 5 -- 536
	drawMistCurve( -- 537
		uiArt, -- 537
		"title_mist_wisp", -- 537
		titleX + 86 + sway, -- 537
		topY - 122, -- 537
		340, -- 537
		82, -- 537
		PALETTE.jadeMist, -- 537
		0.2, -- 537
		-1 -- 537
	) -- 537
	uiArt:tryPlace( -- 538
		"ink_petal_mist", -- 538
		"title_petals", -- 538
		titleX + 12, -- 538
		topY - 102, -- 538
		230, -- 538
		210, -- 538
		{ -- 538
			color = toColor(PALETTE.inkMist), -- 539
			opacity = 0.4, -- 539
			layer = -1 -- 539
		} -- 539
	) -- 539
	local placedBrandTitle = uiArt:tryPlace( -- 543
		"brand_game_logo_v", -- 543
		"title_brand_v", -- 543
		titleX + 22, -- 543
		topY - 106, -- 543
		240, -- 543
		304, -- 543
		{opacity = 0.98, layer = 3} -- 543
	) -- 543
	if not placedBrandTitle then -- 546
		uiArt:tryPlace( -- 547
			"ink_vstream", -- 547
			"title_vstream", -- 547
			titleX - 48, -- 547
			topY - 100, -- 547
			34, -- 547
			290, -- 547
			{ -- 547
				color = toColor(PALETTE.silkDim), -- 548
				opacity = 0.48, -- 548
				layer = 1 -- 548
			} -- 548
		) -- 548
		local c = 0 -- 550
		do -- 550
			c = 0 -- 551
			while c < #VERTICAL_TITLE do -- 551
				texts:put( -- 552
					"title", -- 553
					VERTICAL_TITLE[c + 1], -- 554
					titleX, -- 555
					topY - c * charStep, -- 556
					toColor(PALETTE.textBright), -- 557
					0.5, -- 558
					0.5, -- 559
					"Center", -- 560
					0, -- 561
					0.98, -- 562
					0.1, -- 563
					Color(8, 10, 16, 210) -- 564
				) -- 564
				c = c + 1 -- 551
			end -- 551
		end -- 551
		drawLoneSeal( -- 567
			uiInkDraw, -- 568
			uiArt, -- 569
			texts, -- 570
			"title_lone_seal", -- 571
			titleX + 46, -- 572
			topY - 3 * charStep + 8, -- 573
			26, -- 574
			52, -- 575
			"守", -- 576
			"望", -- 577
			PALETTE.sealRed, -- 578
			PALETTE.sealText, -- 579
			0.94, -- 580
			4 -- 581
		) -- 581
	end -- 581
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 586
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 587
	local poemStep = 22 -- 588
	local p = 0 -- 589
	do -- 589
		p = 0 -- 590
		while p < #EPIGRAPH_RIGHT do -- 590
			local ch = EPIGRAPH_RIGHT[p + 1] -- 591
			if ch ~= "" then -- 592
				texts:put( -- 593
					"xs", -- 593
					ch, -- 593
					colRightX, -- 593
					topY - 22 - p * poemStep, -- 593
					toColor(PALETTE.textMid), -- 593
					0.5, -- 593
					0.5, -- 593
					"Center", -- 593
					0, -- 593
					0.86, -- 593
					0.08 -- 593
				) -- 593
			end -- 593
			p = p + 1 -- 590
		end -- 590
	end -- 590
	do -- 590
		p = 0 -- 596
		while p < #EPIGRAPH_LEFT do -- 596
			texts:put( -- 597
				"xs", -- 597
				EPIGRAPH_LEFT[p + 1], -- 597
				colLeftX, -- 597
				topY - 68 - p * poemStep, -- 597
				toColor(PALETTE.amberCore), -- 597
				0.5, -- 597
				0.5, -- 597
				"Center", -- 597
				0, -- 597
				0.9, -- 597
				0.08 -- 597
			) -- 597
			p = p + 1 -- 596
		end -- 596
	end -- 596
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 601
		TITLE_ITEMS, -- 603
		function(____, it) return it.id ~= "quit" end -- 603
	) -- 603
	local items = self.hasSession and ({ -- 604
		{id = "continue", zh = "继续游戏"}, -- 605
		table.unpack(baseItems) -- 605
	}) or baseItems -- 606
	if self.selected >= #items then -- 607
		self.selected = 0 -- 608
	end -- 608
	local menuX = 112 + frame.safe.left * 0.6 -- 610
	local btnW = 280 -- 611
	local btnH = frame.mode == "touch" and 44 or 40 -- 612
	local gap = self.hasSession and 6 or 8 -- 613
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 614
	local boxes = {} -- 615
	local i = 0 -- 616
	do -- 616
		i = 0 -- 617
		while i < #items do -- 617
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 618
			i = i + 1 -- 617
		end -- 617
	end -- 617
	local prevTitleSel = self.selected -- 620
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 621
	if self.selected ~= prevTitleSel then -- 622
		self:emitSound("hover") -- 623
	end -- 623
	do -- 623
		i = 0 -- 626
		while i < #items do -- 626
			local by = boxes[i + 1].y -- 627
			local active = self.selected == i -- 628
			local cy = by + btnH * 0.5 -- 629
			local shiftX = active and 10 or 0 -- 630
			if active then -- 632
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 633
				drawSilkRibbon( -- 634
					uiDraw, -- 634
					uiArt, -- 634
					"title_rib_red_" .. tostring(i), -- 634
					menuX + 124, -- 634
					cy, -- 634
					290, -- 634
					btnH, -- 634
					PALETTE.rougeSoft, -- 634
					0.52 * breathe, -- 634
					0 -- 634
				) -- 634
				drawHairline( -- 635
					uiInkDraw, -- 635
					uiArt, -- 635
					"title_rib_line_" .. tostring(i), -- 635
					menuX + 114, -- 635
					by + 4, -- 635
					230, -- 635
					PALETTE.silkLine, -- 635
					0.42 * breathe, -- 635
					false, -- 635
					2 -- 635
				) -- 635
				drawBlossomDot( -- 636
					uiInkDraw, -- 636
					uiArt, -- 636
					"title_dot_" .. tostring(i), -- 636
					menuX + 14, -- 636
					cy, -- 636
					16, -- 636
					PALETTE.rouge, -- 636
					0.96, -- 636
					4 -- 636
				) -- 636
				fillRadialGlow( -- 637
					uiGlow, -- 637
					menuX + 14, -- 637
					cy, -- 637
					22, -- 637
					16, -- 637
					toColor(PALETTE.rouge, 28 * breathe), -- 637
					Color(182, 58, 56, 0), -- 637
					10 -- 637
				) -- 637
			else -- 637
				drawBlossomDot( -- 639
					uiInkDraw, -- 639
					uiArt, -- 639
					"title_dot_" .. tostring(i), -- 639
					menuX + 14, -- 639
					cy, -- 639
					8, -- 639
					PALETTE.silkDim, -- 639
					0.4, -- 639
					3 -- 639
				) -- 639
			end -- 639
			texts:put( -- 642
				"md", -- 643
				items[i + 1].zh, -- 644
				menuX + 34 + shiftX, -- 645
				cy, -- 646
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 647
				0, -- 648
				0.5, -- 649
				"Left", -- 650
				active and 4.4 or 2.8, -- 651
				active and 1 or 0.88, -- 652
				0.1 -- 653
			) -- 653
			if items[i + 1].id == "continue" and self.sessionLabel ~= "" then -- 655
				texts:put( -- 656
					"xs", -- 657
					"· " .. self.sessionLabel, -- 658
					menuX + 168 + shiftX, -- 659
					cy, -- 660
					toColor(active and PALETTE.amberCore or PALETTE.textDim), -- 661
					0, -- 662
					0.5, -- 663
					"Left", -- 664
					1.2, -- 665
					active and 0.92 or 0.72, -- 666
					0.08 -- 667
				) -- 667
			end -- 667
			i = i + 1 -- 626
		end -- 626
	end -- 626
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 672
	texts:put( -- 679
		"xs", -- 679
		titleHint, -- 679
		menuX + 12, -- 679
		42 + frame.safe.bottom * 0.45, -- 679
		toColor(PALETTE.textDim), -- 679
		0, -- 679
		0.5, -- 679
		"Left", -- 679
		1.4, -- 679
		0.88, -- 679
		0.08 -- 679
	) -- 679
	local badgeRight = w - frame.safe.right * 0.5 -- 682
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 683
	fillHGradRect( -- 684
		uiDraw, -- 684
		badgeRight - 270, -- 684
		0, -- 684
		270 + frame.safe.right * 0.5, -- 684
		86, -- 684
		Color(8, 10, 16, 0), -- 684
		Color(8, 10, 16, 204) -- 684
	) -- 684
	uiArt:tryPlace( -- 685
		"brand_team_badge", -- 685
		"title_team_badge", -- 685
		badgeRight - 118, -- 685
		badgeY, -- 685
		168, -- 685
		54, -- 685
		{opacity = 0.95, layer = 3} -- 685
	) -- 685
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 689
	if hit >= 0 or frame.keys.confirm then -- 690
		local idx = hit >= 0 and hit or self.selected -- 691
		local id = items[idx + 1].id -- 692
		if id == "continue" then -- 693
			self:emitSound("start") -- 693
			return {type = "continue"} -- 693
		end -- 693
		if id == "trial" then -- 694
			self:emitSound("start") -- 694
			return {type = "trial"} -- 694
		end -- 694
		if id == "start" then -- 695
			self:emitSound("start") -- 695
			return {type = "start"} -- 695
		end -- 695
		if id == "chapters" then -- 696
			self:emitSound("confirm") -- 696
			return {type = "openChapters"} -- 696
		end -- 696
		if id == "quit" then -- 697
			self:emitSound("back") -- 697
			return {type = "quit"} -- 697
		end -- 697
		self:emitSound("confirm") -- 698
		return {type = "openControls"} -- 699
	end -- 699
	return {type = "none"} -- 701
end -- 518
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 704
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 714
	if frame.back then -- 715
		self:emitSound("back") -- 716
		return back -- 717
	end -- 717
	local extraH = math.max(0, h - 720) -- 720
	local marginX = math.max( -- 721
		96, -- 721
		56 + math.max(frame.safe.left, frame.safe.right) -- 721
	) -- 721
	local splitTrack = #CHAPTERS > 8 -- 722
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 723
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 724
	local rowGap = 68 -- 725
	local trackX0 = marginX + 34 -- 726
	local trackX1 = w - marginX - 34 -- 727
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 728
	local stationBoxes = {} -- 730
	local s = 0 -- 731
	do -- 731
		s = 0 -- 732
		while s < #CHAPTERS do -- 732
			local sx = trackX0 + s % perRow * stepX -- 733
			local sy = trackY - math.floor(s / perRow) * rowGap -- 734
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 735
			s = s + 1 -- 732
		end -- 732
	end -- 732
	local prevSelected = self.chapterSelected -- 738
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 739
	local keys = frame.keys -- 740
	if frame.click and hitStation >= 0 then -- 741
		self.chapterSelected = hitStation -- 742
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 743
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 744
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 745
	elseif keys.down and self.chapterSelected < perRow then -- 746
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 747
	elseif keys.up and self.chapterSelected >= perRow then -- 748
		self.chapterSelected = self.chapterSelected - perRow -- 749
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 750
		self.chapterSelected = hitStation -- 751
	end -- 751
	if self.chapterSelected ~= prevSelected then -- 753
		self:emitSound("hover") -- 754
	end -- 754
	uiDraw:drawRect( -- 757
		Rect(0, 0, w, h), -- 757
		Color(10, 12, 19, 198) -- 757
	) -- 757
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 759
	texts:put( -- 760
		"banner", -- 760
		"选择章节", -- 760
		marginX, -- 760
		topHeadY, -- 760
		toColor(PALETTE.textBright), -- 760
		0, -- 760
		0.5, -- 760
		"Left", -- 760
		4.5, -- 760
		0.96, -- 760
		0.1 -- 760
	) -- 760
	drawHairline( -- 761
		uiInkDraw, -- 761
		uiArt, -- 761
		"chap_top_line", -- 761
		w * 0.5, -- 761
		topHeadY - 34, -- 761
		w - marginX * 2, -- 761
		PALETTE.silkDim, -- 761
		0.6, -- 761
		true, -- 761
		2 -- 761
	) -- 761
	local activeEntry = CHAPTERS[self.chapterSelected + 1] -- 763
	local activeRoom = activeEntry.room -- 764
	local theme = themeOf(activeRoom.key) -- 765
	local activeTitleZh = activeEntry.titleOverride or theme.titleZh -- 766
	local activeLineTag = activeEntry.lineTagOverride or theme.lineTag -- 767
	local activeWhisper = activeEntry.whisperOverride or theme.introWhisper -- 768
	local winX = marginX -- 769
	local winY = 266 + extraH * 0.44 -- 770
	local winW = math.min( -- 771
		520, -- 771
		math.max(360, (w - marginX * 2) * 0.46) -- 771
	) -- 771
	local winH = 296 -- 772
	local winBox = Rect(winX, winY, winW, winH) -- 773
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 774
	uiArt:tryPlace( -- 776
		"ink_frame_mask", -- 776
		"chap_win_shadow", -- 776
		winX + winW * 0.5, -- 776
		winY + winH * 0.5, -- 776
		winW + 40, -- 776
		winH + 34, -- 776
		{ -- 776
			color = toColor(PALETTE.inkVoid), -- 777
			opacity = 0.88, -- 777
			layer = -2 -- 777
		} -- 777
	) -- 777
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 779
	uiArt:tryPlace( -- 780
		bgSlot, -- 780
		"chap_win_art", -- 780
		winX + winW * 0.5, -- 780
		winY + 4, -- 780
		winW - 8, -- 780
		winH - 8, -- 780
		{opacity = 0.92, layer = -1} -- 780
	) -- 780
	fillVGradRect( -- 783
		uiInkDraw, -- 783
		winX, -- 783
		winY, -- 783
		winW, -- 783
		56, -- 783
		Color(10, 12, 19, 200), -- 783
		Color(10, 12, 19, 0) -- 783
	) -- 783
	fillVGradRect( -- 784
		uiInkDraw, -- 784
		winX, -- 784
		winY + winH - 36, -- 784
		winW, -- 784
		36, -- 784
		Color(10, 12, 19, 0), -- 784
		Color(10, 12, 19, 130) -- 784
	) -- 784
	fillHGradRect( -- 785
		uiInkDraw, -- 785
		winX, -- 785
		winY, -- 785
		34, -- 785
		winH, -- 785
		Color(10, 12, 19, 135), -- 785
		Color(10, 12, 19, 0) -- 785
	) -- 785
	fillHGradRect( -- 786
		uiInkDraw, -- 786
		winX + winW - 34, -- 786
		winY, -- 786
		34, -- 786
		winH, -- 786
		Color(10, 12, 19, 0), -- 786
		Color(10, 12, 19, 135) -- 786
	) -- 786
	drawFiligreeCorners( -- 787
		uiInkDraw, -- 787
		uiArt, -- 787
		"chap_win_frame", -- 787
		winX, -- 787
		winY, -- 787
		winW, -- 787
		winH, -- 787
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 787
		winHover and 0.92 or 0.72, -- 787
		34, -- 787
		true, -- 787
		3 -- 787
	) -- 787
	texts:put( -- 789
		"xs", -- 789
		(theme.actCode .. "  ·  ") .. activeLineTag, -- 789
		winX + 20, -- 789
		winY + 22, -- 789
		toColor(PALETTE.textMid), -- 789
		0, -- 789
		0.5, -- 789
		"Left", -- 789
		1.8, -- 789
		0.9, -- 789
		0.08 -- 789
	) -- 789
	local infoX = winX + winW + 40 -- 791
	local infoW = math.max(240, w - marginX - infoX) -- 792
	local infoCenterY = winY + winH * 0.5 -- 793
	drawMistCurve( -- 794
		uiArt, -- 794
		"chap_info_mist", -- 794
		infoX + infoW * 0.5, -- 794
		infoCenterY + 36, -- 794
		math.min(420, infoW + 24), -- 794
		88, -- 794
		theme.accent, -- 794
		0.22, -- 794
		-1 -- 794
	) -- 794
	local volCol = activeLineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 796
	texts:put( -- 797
		"xs", -- 797
		theme.volumeTagZh, -- 797
		infoX, -- 797
		winY + winH - 44, -- 797
		toColor(volCol), -- 797
		0, -- 797
		0.5, -- 797
		"Left", -- 797
		2.8, -- 797
		0.92, -- 797
		0.08 -- 797
	) -- 797
	local sep = " · " -- 799
	local sIdx = (string.find(activeTitleZh, sep, nil, true) or 0) - 1 -- 800
	local titleY = winY + winH - 98 -- 801
	if theme.backdropKey ~= nil then -- 802
		texts:put( -- 803
			"lg", -- 803
			activeTitleZh, -- 803
			infoX, -- 803
			titleY, -- 803
			toColor(PALETTE.textBright) -- 803
		) -- 803
	elseif sIdx > 0 then -- 804
		local leftPart = __TS__StringSlice(activeTitleZh, 0, sIdx) -- 805
		local rightPart = __TS__StringSlice(activeTitleZh, sIdx + #sep) -- 806
		local lw = visualTextWidth(leftPart, 40) -- 807
		texts:put( -- 808
			"banner", -- 808
			leftPart, -- 808
			infoX, -- 808
			titleY, -- 808
			toColor(PALETTE.textBright), -- 808
			0, -- 808
			0.5, -- 808
			"Left", -- 808
			2, -- 808
			1, -- 808
			0.1 -- 808
		) -- 808
		drawBlossomDot( -- 809
			uiInkDraw, -- 809
			uiArt, -- 809
			"chap_title_dot", -- 809
			infoX + lw + 16, -- 809
			titleY - 2, -- 809
			11, -- 809
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 809
			0.9, -- 809
			4 -- 809
		) -- 809
		texts:put( -- 810
			"banner", -- 810
			rightPart, -- 810
			infoX + lw + 32, -- 810
			titleY, -- 810
			toColor(PALETTE.textBright), -- 810
			0, -- 810
			0.5, -- 810
			"Left", -- 810
			2, -- 810
			1, -- 810
			0.1 -- 810
		) -- 810
	else -- 810
		texts:put( -- 812
			"banner", -- 812
			activeTitleZh, -- 812
			infoX, -- 812
			titleY, -- 812
			toColor(PALETTE.textBright), -- 812
			0, -- 812
			0.5, -- 812
			"Left", -- 812
			2.4, -- 812
			1, -- 812
			0.1 -- 812
		) -- 812
	end -- 812
	drawHairline( -- 815
		uiInkDraw, -- 815
		uiArt, -- 815
		"chap_info_line", -- 815
		infoX + math.min(185, infoW * 0.5), -- 815
		titleY - 36, -- 815
		math.min(370, infoW), -- 815
		PALETTE.silkDim, -- 815
		0.58, -- 815
		false, -- 815
		2 -- 815
	) -- 815
	texts:put( -- 816
		"sm", -- 816
		activeWhisper, -- 816
		infoX, -- 816
		titleY - 72, -- 816
		toColor(PALETTE.textMid), -- 816
		0, -- 816
		0.5, -- 816
		"Left", -- 816
		0.8, -- 816
		0.94, -- 816
		0.08 -- 816
	) -- 816
	local goX = infoX -- 818
	local goY = winY + 26 -- 819
	local goW = 220 -- 820
	local goH = 42 -- 821
	local goBox = Rect(goX, goY, goW, goH) -- 822
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 823
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 824
	drawSilkRibbon( -- 825
		uiDraw, -- 825
		uiArt, -- 825
		"chap_go_rib", -- 825
		goX + 106, -- 825
		goY + 21, -- 825
		250, -- 825
		40, -- 825
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 825
		(goHover and 0.68 or 0.46) * breathe, -- 825
		0 -- 825
	) -- 825
	drawHairline( -- 826
		uiInkDraw, -- 826
		uiArt, -- 826
		"chap_go_line", -- 826
		goX + 94, -- 826
		goY + 3, -- 826
		196, -- 826
		PALETTE.silkLine, -- 826
		goHover and 0.68 or 0.4, -- 826
		false, -- 826
		2 -- 826
	) -- 826
	drawBlossomDot( -- 827
		uiInkDraw, -- 827
		uiArt, -- 827
		"chap_go_dot", -- 827
		goX + 14, -- 827
		goY + 21, -- 827
		14, -- 827
		PALETTE.rouge, -- 827
		0.96, -- 827
		4 -- 827
	) -- 827
	texts:put( -- 828
		"md", -- 828
		"入此卷章", -- 828
		goX + 34, -- 828
		goY + 21, -- 828
		toColor(PALETTE.textBright), -- 828
		0, -- 828
		0.5, -- 828
		"Left", -- 828
		3.8, -- 828
		1, -- 828
		0.1 -- 828
	) -- 828
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 829
	texts:put( -- 832
		"xs", -- 832
		chapConfirmTag, -- 832
		goX + 156, -- 832
		goY + 21, -- 832
		toColor(PALETTE.textDim), -- 832
		0, -- 832
		0.5, -- 832
		"Left", -- 832
		1, -- 832
		0.82, -- 832
		0.08 -- 832
	) -- 832
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 834
	local veilH = splitTrack and 156 or 126 -- 835
	drawSilkVeil( -- 836
		uiDraw, -- 836
		uiArt, -- 836
		"chap_track_veil", -- 836
		w * 0.5, -- 836
		veilCenterY, -- 836
		w - marginX * 1.1, -- 836
		veilH, -- 836
		PALETTE.inkWash, -- 836
		0.72, -- 836
		-2 -- 836
	) -- 836
	drawMistCurve( -- 837
		uiArt, -- 837
		"chap_track_mist", -- 837
		w * 0.5, -- 837
		trackY, -- 837
		trackX1 - trackX0 + 160, -- 837
		74, -- 837
		PALETTE.inkMist, -- 837
		0.62, -- 837
		-1 -- 837
	) -- 837
	uiInkDraw:drawSegment( -- 838
		Vec2(trackX0, trackY), -- 838
		Vec2(trackX1, trackY), -- 838
		0.9, -- 838
		toColor(PALETTE.silkDim, 145) -- 838
	) -- 838
	if splitTrack then -- 840
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 841
		uiInkDraw:drawSegment( -- 842
			Vec2(trackX0, trackY - rowGap), -- 842
			Vec2(lastX, trackY - rowGap), -- 842
			0.9, -- 842
			toColor(PALETTE.silkDim, 145) -- 842
		) -- 842
	else -- 842
		local midDivX = trackX0 + stepX * 3.5 -- 844
		uiInkDraw:drawSegment( -- 845
			Vec2(midDivX, trackY - 12), -- 845
			Vec2(midDivX, trackY + 12), -- 845
			0.8, -- 845
			toColor(PALETTE.silkDim, 120) -- 845
		) -- 845
		texts:put( -- 846
			"xs", -- 846
			"上卷 · 孤城护童", -- 846
			trackX0 + stepX * 1.5, -- 846
			trackY + 52, -- 846
			toColor(PALETTE.cyan), -- 846
			0.5, -- 846
			0.5, -- 846
			"Center", -- 846
			2.2, -- 846
			0.88, -- 846
			0.08 -- 846
		) -- 846
		texts:put( -- 847
			"xs", -- 847
			"下卷 · 独赴北塔", -- 847
			trackX0 + stepX * 5.5, -- 847
			trackY + 52, -- 847
			toColor(PALETTE.amber), -- 847
			0.5, -- 847
			0.5, -- 847
			"Center", -- 847
			2.2, -- 847
			0.88, -- 847
			0.08 -- 847
		) -- 847
	end -- 847
	local i = 0 -- 850
	do -- 850
		i = 0 -- 851
		while i < #CHAPTERS do -- 851
			local box = stationBoxes[i + 1] -- 852
			local sx = box.x + box.width * 0.5 -- 853
			local sy = box.y + box.height * 0.5 -- 854
			local entry = CHAPTERS[i + 1] -- 855
			local rt = themeOf(entry.room.key) -- 856
			local entryLineTag = entry.lineTagOverride or rt.lineTag -- 857
			local entryShortName = entry.shortNameOverride or rt.shortNameZh -- 858
			local active = self.chapterSelected == i -- 859
			local nodeCol = active and PALETTE.rouge or (entryLineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 860
			if active then -- 862
				fillRadialGlow( -- 863
					uiGlow, -- 863
					sx, -- 863
					sy, -- 863
					26, -- 863
					26, -- 863
					toColor(PALETTE.rouge, 36 * breathe), -- 863
					Color(182, 58, 56, 0), -- 863
					12 -- 863
				) -- 863
				uiArt:tryPlace( -- 864
					"ink_enso_fine", -- 864
					"chap_st_ring_" .. tostring(i), -- 864
					sx, -- 864
					sy, -- 864
					32, -- 864
					32, -- 864
					{ -- 864
						color = toColor(PALETTE.silkLine), -- 865
						opacity = 0.78, -- 865
						angle = self.time * 18, -- 865
						layer = 3 -- 865
					} -- 865
				) -- 865
				drawBlossomDot( -- 867
					uiInkDraw, -- 867
					uiArt, -- 867
					"chap_st_dot_" .. tostring(i), -- 867
					sx, -- 867
					sy, -- 867
					17, -- 867
					PALETTE.rouge, -- 867
					0.98, -- 867
					4 -- 867
				) -- 867
			else -- 867
				uiArt:tryPlace( -- 869
					"ink_enso_fine", -- 869
					"chap_st_ring_" .. tostring(i), -- 869
					sx, -- 869
					sy, -- 869
					16, -- 869
					16, -- 869
					{ -- 869
						color = toColor(nodeCol), -- 870
						opacity = 0.62, -- 870
						layer = 3 -- 870
					} -- 870
				) -- 870
				drawBlossomDot( -- 872
					uiInkDraw, -- 872
					uiArt, -- 872
					"chap_st_dot_" .. tostring(i), -- 872
					sx, -- 872
					sy, -- 872
					7, -- 872
					PALETTE.silkLine, -- 872
					0.72, -- 872
					4 -- 872
				) -- 872
			end -- 872
			if not splitTrack then -- 875
				texts:put( -- 876
					"xs", -- 876
					rt.numeralZh, -- 876
					sx, -- 876
					sy + 25, -- 876
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 876
					0.5, -- 876
					0.5, -- 876
					"Center", -- 876
					0, -- 876
					active and 1 or 0.88, -- 876
					0.08 -- 876
				) -- 876
			end -- 876
			texts:put( -- 878
				"xs", -- 878
				entryShortName, -- 878
				sx, -- 878
				sy - 26, -- 878
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 878
				0.5, -- 878
				0.5, -- 878
				"Center", -- 878
				1, -- 878
				active and 1 or 0.84, -- 878
				0.08 -- 878
			) -- 878
			i = i + 1 -- 851
		end -- 851
	end -- 851
	local backX = marginX -- 881
	local backY = 40 + frame.safe.bottom * 0.45 -- 882
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 883
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 884
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 885
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 888
	drawSilkKeycap( -- 893
		uiInkDraw, -- 893
		texts, -- 893
		backX, -- 893
		backY + 5, -- 893
		48, -- 893
		24, -- 893
		chapBackTag, -- 893
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 893
		0.92, -- 893
		backHover -- 893
	) -- 893
	texts:put( -- 894
		"sm", -- 894
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 894
		backX + 60, -- 894
		backY + 17, -- 894
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 894
		0, -- 894
		0.5, -- 894
		"Left", -- 894
		1.8, -- 894
		0.9, -- 894
		0.08 -- 894
	) -- 894
	texts:put( -- 895
		"xs", -- 895
		chapFooter, -- 895
		w - marginX, -- 895
		backY + 17, -- 895
		toColor(PALETTE.textDim), -- 895
		1, -- 895
		0.5, -- 895
		"Right", -- 895
		1.2, -- 895
		0.75, -- 895
		0.08 -- 895
	) -- 895
	if frame.click and backHover then -- 897
		self:emitSound("back") -- 898
		return back -- 899
	end -- 899
	local ____temp_2 -- 902
	if frame.mode == "touch" then -- 902
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 903
	else -- 903
		____temp_2 = hitStation >= 0 -- 904
	end -- 904
	local stationConfirmed = ____temp_2 -- 902
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 905
		self:emitSound("start") -- 906
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex, route = CHAPTERS[self.chapterSelected + 1].route} -- 907
	end -- 907
	return {type = "none"} -- 913
end -- 704
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 917
	if backLabel == nil then -- 926
		backLabel = "返回标题" -- 926
	end -- 926
	if not self.controlsTabManual then -- 928
		self.controlsTab = frame.mode -- 929
	end -- 929
	local tabOrder = {"kbm", "gamepad", "touch"} -- 931
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 932
	local marginX = math.max( -- 933
		96, -- 933
		56 + math.max(frame.safe.left, frame.safe.right) -- 933
	) -- 933
	local tabW = 92 -- 934
	local tabH = 28 -- 935
	local tabGap = 10 -- 936
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 937
	local tabY = h - 82 - frame.safe.top * 0.35 -- 938
	local tabBoxes = { -- 939
		Rect(tabStartX, tabY, tabW, tabH), -- 940
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 941
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 942
	} -- 942
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 945
	if frame.click and hitTab >= 0 then -- 946
		if self.controlsTab ~= tabOrder[hitTab + 1] then -- 947
			self:emitSound("toggle") -- 948
		end -- 948
		self.controlsTab = tabOrder[hitTab + 1] -- 950
		self.controlsTabManual = true -- 951
	elseif frame.keys.left or frame.prevTab then -- 952
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 953
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 954
		self.controlsTabManual = true -- 955
		self:emitSound("toggle") -- 956
	elseif frame.keys.right or frame.nextTab then -- 957
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 958
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 959
		self.controlsTabManual = true -- 960
		self:emitSound("toggle") -- 961
	end -- 961
	local backX = marginX -- 964
	local backY = 40 + frame.safe.bottom * 0.45 -- 965
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 966
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 967
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 968
		self:emitSound("back") -- 969
		return {type = "backTitle"} -- 970
	end -- 970
	uiDraw:drawRect( -- 972
		Rect(0, 0, w, h), -- 972
		Color(10, 12, 19, 204) -- 972
	) -- 972
	local guide = controlsGuideRows(self.controlsTab) -- 974
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 975
	texts:put( -- 976
		"banner", -- 976
		"执器要诀", -- 976
		marginX, -- 976
		topHeadY, -- 976
		toColor(PALETTE.textBright), -- 976
		0, -- 976
		0.5, -- 976
		"Left", -- 976
		4.5, -- 976
		0.96, -- 976
		0.1 -- 976
	) -- 976
	texts:put( -- 977
		"xs", -- 977
		guide.subtitle, -- 977
		marginX + 196, -- 977
		topHeadY - 4, -- 977
		toColor(PALETTE.textDim), -- 977
		0, -- 977
		0.5, -- 977
		"Left", -- 977
		1.8, -- 977
		0.85, -- 977
		0.08 -- 977
	) -- 977
	drawHairline( -- 978
		uiInkDraw, -- 978
		uiArt, -- 978
		"ctrl_top_line", -- 978
		w * 0.5, -- 978
		topHeadY - 34, -- 978
		w - marginX * 2, -- 978
		PALETTE.silkDim, -- 978
		0.6, -- 978
		true, -- 978
		2 -- 978
	) -- 978
	local ti = 0 -- 980
	do -- 980
		ti = 0 -- 981
		while ti < #tabBoxes do -- 981
			local tb = tabBoxes[ti + 1] -- 982
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 983
			local hoverTab = hitTab == ti -- 984
			uiInkDraw:drawRect( -- 985
				tb, -- 986
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 987
				0.9, -- 988
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 989
			) -- 989
			texts:put( -- 991
				"xs", -- 992
				tabLabels[ti + 1], -- 993
				tb.x + tb.width * 0.5, -- 994
				tb.y + tb.height * 0.5, -- 995
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 996
				0.5, -- 997
				0.5, -- 998
				"Center", -- 999
				0.8, -- 1000
				activeTab and 0.98 or 0.82, -- 1001
				0.08 -- 1002
			) -- 1002
			ti = ti + 1 -- 981
		end -- 981
	end -- 981
	local extraH = math.max(0, h - 720) -- 1006
	local areaY = 114 + frame.safe.bottom * 0.4 -- 1007
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 1008
	drawFiligreeCorners( -- 1009
		uiInkDraw, -- 1009
		uiArt, -- 1009
		"ctrl_outer", -- 1009
		marginX, -- 1009
		areaY, -- 1009
		w - marginX * 2, -- 1009
		areaH, -- 1009
		PALETTE.silkDim, -- 1009
		0.52, -- 1009
		34, -- 1009
		false, -- 1009
		2 -- 1009
	) -- 1009
	local midX = w * 0.5 -- 1011
	uiArt:tryPlace( -- 1012
		"ink_vstream", -- 1012
		"ctrl_mid_stream", -- 1012
		midX, -- 1012
		areaY + areaH * 0.5, -- 1012
		32, -- 1012
		areaH - 18, -- 1012
		{ -- 1012
			color = toColor(PALETTE.silkDim), -- 1013
			opacity = 0.52, -- 1013
			layer = 1 -- 1013
		} -- 1013
	) -- 1013
	drawBlossomDot( -- 1015
		uiInkDraw, -- 1015
		uiArt, -- 1015
		"ctrl_mid_dot", -- 1015
		midX, -- 1015
		areaY + areaH * 0.5, -- 1015
		11, -- 1015
		PALETTE.silkLine, -- 1015
		0.62, -- 1015
		3 -- 1015
	) -- 1015
	local leftColX = marginX + 34 -- 1017
	local colW = midX - leftColX - 42 -- 1018
	local headY = areaY + areaH - 34 -- 1019
	local rowStep = 52 + extraH * 0.08 -- 1020
	drawBlossomDot( -- 1022
		uiInkDraw, -- 1022
		uiArt, -- 1022
		"ctrl_l_dot", -- 1022
		leftColX + 8, -- 1022
		headY, -- 1022
		12, -- 1022
		PALETTE.cyan, -- 1022
		0.88, -- 1022
		3 -- 1022
	) -- 1022
	texts:put( -- 1023
		"md", -- 1023
		"周戍 · 护送与交锋", -- 1023
		leftColX + 26, -- 1023
		headY, -- 1023
		toColor(PALETTE.cyanCore), -- 1023
		0, -- 1023
		0.5, -- 1023
		"Left", -- 1023
		2.4, -- 1023
		0.98, -- 1023
		0.08 -- 1023
	) -- 1023
	drawHairline( -- 1024
		uiInkDraw, -- 1024
		uiArt, -- 1024
		"ctrl_l_line", -- 1024
		leftColX + colW * 0.5, -- 1024
		headY - 24, -- 1024
		colW, -- 1024
		PALETTE.cyanDim, -- 1024
		0.58, -- 1024
		false, -- 1024
		2 -- 1024
	) -- 1024
	local i = 0 -- 1026
	local keycapW = 160 -- 1027
	do -- 1027
		i = 0 -- 1028
		while i < #guide.soldierRows do -- 1028
			local ry = headY - 66 - i * rowStep -- 1029
			drawSilkKeycap( -- 1030
				uiInkDraw, -- 1030
				texts, -- 1030
				leftColX + 2, -- 1030
				ry - 13, -- 1030
				keycapW, -- 1030
				26, -- 1030
				guide.soldierRows[i + 1][1], -- 1030
				PALETTE.cyan, -- 1030
				0.92, -- 1030
				false -- 1030
			) -- 1030
			texts:put( -- 1031
				"sm", -- 1031
				guide.soldierRows[i + 1][2], -- 1031
				leftColX + keycapW + 16, -- 1031
				ry, -- 1031
				toColor(PALETTE.textBright), -- 1031
				0, -- 1031
				0.5, -- 1031
				"Left", -- 1031
				0.8, -- 1031
				0.92, -- 1031
				0.08 -- 1031
			) -- 1031
			i = i + 1 -- 1028
		end -- 1028
	end -- 1028
	local rightColX = midX + 44 -- 1034
	drawBlossomDot( -- 1035
		uiInkDraw, -- 1035
		uiArt, -- 1035
		"ctrl_r_dot", -- 1035
		rightColX + 8, -- 1035
		headY, -- 1035
		12, -- 1035
		PALETTE.amber, -- 1035
		0.88, -- 1035
		3 -- 1035
	) -- 1035
	texts:put( -- 1036
		"md", -- 1036
		"小满 · 潜行与寻路", -- 1036
		rightColX + 26, -- 1036
		headY, -- 1036
		toColor(PALETTE.amberCore), -- 1036
		0, -- 1036
		0.5, -- 1036
		"Left", -- 1036
		2.4, -- 1036
		0.98, -- 1036
		0.08 -- 1036
	) -- 1036
	drawHairline( -- 1037
		uiInkDraw, -- 1037
		uiArt, -- 1037
		"ctrl_r_line", -- 1037
		rightColX + colW * 0.5, -- 1037
		headY - 24, -- 1037
		colW, -- 1037
		PALETTE.amberDim, -- 1037
		0.58, -- 1037
		false, -- 1037
		2 -- 1037
	) -- 1037
	do -- 1037
		i = 0 -- 1039
		while i < #guide.childRows do -- 1039
			local ry = headY - 66 - i * rowStep -- 1040
			drawSilkKeycap( -- 1041
				uiInkDraw, -- 1041
				texts, -- 1041
				rightColX + 2, -- 1041
				ry - 13, -- 1041
				keycapW, -- 1041
				26, -- 1041
				guide.childRows[i + 1][1], -- 1041
				PALETTE.amber, -- 1041
				0.92, -- 1041
				false -- 1041
			) -- 1041
			texts:put( -- 1042
				"sm", -- 1042
				guide.childRows[i + 1][2], -- 1042
				rightColX + keycapW + 16, -- 1042
				ry, -- 1042
				toColor(PALETTE.textBright), -- 1042
				0, -- 1042
				0.5, -- 1042
				"Left", -- 1042
				0.8, -- 1042
				0.92, -- 1042
				0.08 -- 1042
			) -- 1042
			i = i + 1 -- 1039
		end -- 1039
	end -- 1039
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 1045
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 1048
	local keyW = frame.mode == "touch" and 76 or 110 -- 1053
	drawSilkKeycap( -- 1054
		uiInkDraw, -- 1054
		texts, -- 1054
		backX, -- 1054
		backY + 5, -- 1054
		keyW, -- 1054
		24, -- 1054
		ctrlBackKey, -- 1054
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1054
		0.92, -- 1054
		backHover -- 1054
	) -- 1054
	texts:put( -- 1055
		"sm", -- 1055
		backLabel, -- 1055
		backX + keyW + 12, -- 1055
		backY + 17, -- 1055
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1055
		0, -- 1055
		0.5, -- 1055
		"Left", -- 1055
		1.8, -- 1055
		0.92, -- 1055
		0.08 -- 1055
	) -- 1055
	texts:put( -- 1056
		"xs", -- 1056
		ctrlRightHint, -- 1056
		w - marginX, -- 1056
		backY + 17, -- 1056
		toColor(PALETTE.textDim), -- 1056
		1, -- 1056
		0.5, -- 1056
		"Right", -- 1056
		1.2, -- 1056
		0.78, -- 1056
		0.08 -- 1056
	) -- 1056
	return {type = "none"} -- 1058
end -- 917
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1062
	if frame.back then -- 1073
		self:emitSound("back") -- 1074
		return true -- 1075
	end -- 1075
	local caps = getPlatformCaps() -- 1078
	local s = input.settings -- 1079
	uiDraw:drawRect( -- 1081
		Rect(0, 0, w, h), -- 1081
		Color(10, 12, 19, 206) -- 1081
	) -- 1081
	local marginX = math.max( -- 1083
		96, -- 1083
		56 + math.max(frame.safe.left, frame.safe.right) -- 1083
	) -- 1083
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1084
	texts:put( -- 1085
		"banner", -- 1085
		"操控与声音", -- 1085
		marginX, -- 1085
		topHeadY, -- 1085
		toColor(PALETTE.textBright), -- 1085
		0, -- 1085
		0.5, -- 1085
		"Left", -- 1085
		4, -- 1085
		0.96, -- 1085
		0.1 -- 1085
	) -- 1085
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 操控与四通道音量实时生效" -- 1086
	texts:put( -- 1087
		"xs", -- 1087
		curSummary, -- 1087
		marginX + 224, -- 1087
		topHeadY - 4, -- 1087
		toColor(PALETTE.amberCore), -- 1087
		0, -- 1087
		0.5, -- 1087
		"Left", -- 1087
		1.4, -- 1087
		0.88, -- 1087
		0.08 -- 1087
	) -- 1087
	drawHairline( -- 1088
		uiInkDraw, -- 1088
		uiArt, -- 1088
		"set_top_line", -- 1088
		w * 0.5, -- 1088
		topHeadY - 30, -- 1088
		w - marginX * 2, -- 1088
		PALETTE.silkDim, -- 1088
		0.6, -- 1088
		true, -- 1088
		2 -- 1088
	) -- 1088
	local panelW = math.min(760, w - marginX * 2) -- 1090
	local panelX = (w - panelW) * 0.5 -- 1091
	local rowH = 34 -- 1092
	local rowStep = 39 -- 1093
	local firstY = topHeadY - 76 -- 1094
	local boxes = {} -- 1096
	local i = 0 -- 1097
	do -- 1097
		i = 0 -- 1098
		while i < #SETTINGS_ROWS do -- 1098
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1099
			i = i + 1 -- 1098
		end -- 1098
	end -- 1098
	local prevSetSel = self.settingsSelected -- 1101
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1102
	if self.settingsSelected ~= prevSetSel then -- 1103
		self:emitSound("hover") -- 1104
	end -- 1104
	local function applyDelta(rowId, delta) -- 1107
		if rowId == "back" then -- 1108
			self:emitSound("back") -- 1109
			return true -- 1110
		end -- 1110
		local audioChanged = false -- 1112
		if rowId == "modePref" then -- 1113
			input:cycleModePref(delta) -- 1114
		elseif rowId == "aimAssist" then -- 1115
			s.aimAssist = not s.aimAssist -- 1116
			saveControlSettings(s) -- 1117
		elseif rowId == "gpLayout" then -- 1118
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1119
			input.gamepadLayout = s.gamepadLayout -- 1120
			saveControlSettings(s) -- 1121
		elseif rowId == "crouchMode" then -- 1122
			s.crouchToggle = not s.crouchToggle -- 1123
			saveControlSettings(s) -- 1124
		elseif rowId == "touchOpacity" then -- 1125
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1126
			saveControlSettings(s) -- 1127
		elseif rowId == "touchScale" then -- 1128
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1129
			saveControlSettings(s) -- 1130
		elseif rowId == "haptics" then -- 1131
			s.haptics = not s.haptics -- 1132
			saveControlSettings(s) -- 1133
			if s.haptics then -- 1134
				local ____opt_3 = input:getTouch() -- 1135
				if ____opt_3 ~= nil then -- 1135
					____opt_3:vibrate(0.018) -- 1135
				end -- 1135
			end -- 1135
		elseif rowId == "masterVol" then -- 1137
			s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 1138
			saveControlSettings(s) -- 1139
			audioChanged = true -- 1140
		elseif rowId == "bgmVol" then -- 1141
			s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 1142
			saveControlSettings(s) -- 1143
			audioChanged = true -- 1144
		elseif rowId == "sfxVol" then -- 1145
			s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 1146
			saveControlSettings(s) -- 1147
			audioChanged = true -- 1148
		elseif rowId == "voiceVol" then -- 1149
			s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 1150
			saveControlSettings(s) -- 1151
			audioChanged = true -- 1152
		end -- 1152
		if audioChanged and self.onAudioSettingsChanged ~= nil then -- 1154
			self:onAudioSettingsChanged(input) -- 1155
		end -- 1155
		self:emitSound("toggle") -- 1157
		return false -- 1158
	end -- 1107
	local function valueTextOf(rowId) -- 1161
		if rowId == "modePref" then -- 1162
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1163
		end -- 1163
		if rowId == "aimAssist" then -- 1167
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1167
		end -- 1167
		if rowId == "gpLayout" then -- 1168
			return layoutLabelOf(s.gamepadLayout) -- 1168
		end -- 1168
		if rowId == "crouchMode" then -- 1169
			return s.crouchToggle and "点按切换" or "持续按住" -- 1169
		end -- 1169
		if rowId == "touchOpacity" then -- 1170
			return opacityLabelOf(s.touchOpacity) -- 1170
		end -- 1170
		if rowId == "touchScale" then -- 1171
			return scaleLabelOf(s.touchScale) -- 1171
		end -- 1171
		if rowId == "haptics" then -- 1172
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1172
		end -- 1172
		if rowId == "masterVol" then -- 1173
			return volumeLabelOf(s.masterVol) -- 1173
		end -- 1173
		if rowId == "bgmVol" then -- 1174
			return volumeLabelOf(s.bgmVol) -- 1174
		end -- 1174
		if rowId == "sfxVol" then -- 1175
			return volumeLabelOf(s.sfxVol) -- 1175
		end -- 1175
		if rowId == "voiceVol" then -- 1176
			return volumeLabelOf(s.voiceVol) -- 1176
		end -- 1176
		return "" -- 1177
	end -- 1161
	do -- 1161
		i = 0 -- 1180
		while i < #SETTINGS_ROWS do -- 1180
			local row = SETTINGS_ROWS[i + 1] -- 1181
			local box = boxes[i + 1] -- 1182
			local cy = box.y + box.height * 0.5 -- 1183
			local active = self.settingsSelected == i -- 1184
			if active then -- 1186
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1187
				drawSilkRibbon( -- 1188
					uiDraw, -- 1188
					uiArt, -- 1188
					"set_rib_" .. tostring(i), -- 1188
					panelX + panelW * 0.5, -- 1188
					cy, -- 1188
					panelW + 24, -- 1188
					rowH, -- 1188
					PALETTE.rougeSoft, -- 1188
					0.48 * breathe, -- 1188
					0 -- 1188
				) -- 1188
				drawHairline( -- 1189
					uiInkDraw, -- 1189
					uiArt, -- 1189
					"set_line_" .. tostring(i), -- 1189
					panelX + panelW * 0.5, -- 1189
					box.y + 3, -- 1189
					panelW - 24, -- 1189
					PALETTE.silkLine, -- 1189
					0.42 * breathe, -- 1189
					false, -- 1189
					2 -- 1189
				) -- 1189
				drawBlossomDot( -- 1190
					uiInkDraw, -- 1190
					uiArt, -- 1190
					"set_dot_" .. tostring(i), -- 1190
					panelX + 18, -- 1190
					cy, -- 1190
					14, -- 1190
					PALETTE.rouge, -- 1190
					0.96, -- 1190
					4 -- 1190
				) -- 1190
				fillRadialGlow( -- 1191
					uiGlow, -- 1191
					panelX + 18, -- 1191
					cy, -- 1191
					20, -- 1191
					14, -- 1191
					toColor(PALETTE.rouge, 24 * breathe), -- 1191
					Color(182, 58, 56, 0), -- 1191
					10 -- 1191
				) -- 1191
			else -- 1191
				drawBlossomDot( -- 1193
					uiInkDraw, -- 1193
					uiArt, -- 1193
					"set_dot_" .. tostring(i), -- 1193
					panelX + 18, -- 1193
					cy, -- 1193
					7, -- 1193
					PALETTE.silkDim, -- 1193
					0.42, -- 1193
					3 -- 1193
				) -- 1193
			end -- 1193
			texts:put( -- 1196
				"sm", -- 1197
				row.title, -- 1198
				panelX + 42, -- 1199
				cy, -- 1200
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1201
				0, -- 1202
				0.5, -- 1203
				"Left", -- 1204
				active and 2.4 or 1.6, -- 1205
				active and 1 or 0.88, -- 1206
				0.08 -- 1207
			) -- 1207
			local val = valueTextOf(row.id) -- 1210
			if val ~= "" then -- 1211
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1212
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1213
				texts:put( -- 1214
					"sm", -- 1214
					decorated, -- 1214
					panelX + panelW - 24, -- 1214
					cy, -- 1214
					toColor(valCol), -- 1214
					1, -- 1214
					0.5, -- 1214
					"Right", -- 1214
					1, -- 1214
					active and 1 or 0.86, -- 1214
					0.08 -- 1214
				) -- 1214
			end -- 1214
			i = i + 1 -- 1180
		end -- 1180
	end -- 1180
	local backY = 40 + frame.safe.bottom * 0.45 -- 1218
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1219
	texts:put( -- 1224
		"xs", -- 1224
		hint, -- 1224
		w * 0.5, -- 1224
		backY + 14, -- 1224
		toColor(PALETTE.textDim), -- 1224
		0.5, -- 1224
		0.5, -- 1224
		"Center", -- 1224
		1.2, -- 1224
		0.84, -- 1224
		0.08 -- 1224
	) -- 1224
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1226
	if hit >= 0 then -- 1227
		self.settingsSelected = hit -- 1228
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1229
			return true -- 1230
		end -- 1230
		self:resetInput() -- 1232
		return false -- 1233
	end -- 1233
	if frame.keys.left or frame.prevTab then -- 1235
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1236
		if id ~= "back" then -- 1237
			applyDelta(id, -1) -- 1238
			self:resetInput() -- 1239
		end -- 1239
		return false -- 1241
	end -- 1241
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1243
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1244
		if applyDelta(id, 1) then -- 1245
			return true -- 1246
		end -- 1246
		self:resetInput() -- 1248
		return false -- 1249
	end -- 1249
	return false -- 1251
end -- 1062
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1259
	if assistHintsEnabled == nil then -- 1270
		assistHintsEnabled = false -- 1270
	end -- 1270
	if safeUi == nil then -- 1272
		safeUi = ZERO_SAFE_INSETS -- 1272
	end -- 1272
	self.time = self.time + dt -- 1274
	local frame = self:readFrame(input, uiScale, safeUi) -- 1275
	if self.pauseShowControls then -- 1277
		local ctrlAct = self:drawControls( -- 1278
			frame, -- 1278
			uiDraw, -- 1278
			uiInkDraw, -- 1278
			uiArt, -- 1278
			uiGlow, -- 1278
			texts, -- 1278
			w, -- 1278
			h, -- 1278
			"返回暂停" -- 1278
		) -- 1278
		if ctrlAct.type == "backTitle" then -- 1279
			self.pauseShowControls = false -- 1280
			self:resetInput() -- 1281
		end -- 1281
		return {type = "none"} -- 1283
	end -- 1283
	if self.pauseShowSettings then -- 1286
		if self:drawPauseSettings( -- 1287
			frame, -- 1287
			input, -- 1287
			uiDraw, -- 1287
			uiInkDraw, -- 1287
			uiArt, -- 1287
			uiGlow, -- 1287
			texts, -- 1287
			w, -- 1287
			h -- 1287
		) then -- 1287
			self.pauseShowSettings = false -- 1288
			self:resetInput() -- 1289
		end -- 1289
		return {type = "none"} -- 1291
	end -- 1291
	if frame.back then -- 1294
		self.pauseShowControls = false -- 1295
		self.pauseShowSettings = false -- 1296
		self:emitSound("pauseClose") -- 1297
		return {type = "resume"} -- 1298
	end -- 1298
	local allowFs = canToggleFullscreen() -- 1301
	local allowQuit = canQuitApp() -- 1302
	local pauseItems = __TS__ArrayFilter( -- 1303
		PAUSE_ITEMS, -- 1303
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1303
	) -- 1303
	if self.pauseSelected >= #pauseItems then -- 1306
		self.pauseSelected = 0 -- 1307
	end -- 1307
	uiDraw:drawRect( -- 1310
		Rect(0, 0, w, h), -- 1310
		Color(8, 10, 16, 102) -- 1310
	) -- 1310
	fillHGradRect( -- 1311
		uiDraw, -- 1311
		0, -- 1311
		0, -- 1311
		w * 0.27 + frame.safe.left, -- 1311
		h, -- 1311
		Color(9, 11, 18, 232), -- 1311
		Color(10, 13, 21, 198) -- 1311
	) -- 1311
	fillHGradRect( -- 1312
		uiDraw, -- 1312
		w * 0.27 + frame.safe.left, -- 1312
		0, -- 1312
		w * 0.21, -- 1312
		h, -- 1312
		Color(10, 13, 21, 198), -- 1312
		Color(10, 13, 21, 0) -- 1312
	) -- 1312
	local menuX = 110 + frame.safe.left * 0.6 -- 1314
	local compact = #pauseItems > 8 -- 1315
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1316
	uiArt:tryPlace( -- 1317
		"ink_vstream", -- 1317
		"pause_vstream", -- 1317
		menuX - 32, -- 1317
		h * 0.5, -- 1317
		34, -- 1317
		h * 0.78, -- 1317
		{ -- 1317
			color = toColor(PALETTE.silkDim), -- 1318
			opacity = 0.48, -- 1318
			layer = 1 -- 1318
		} -- 1318
	) -- 1318
	drawMistCurve( -- 1320
		uiArt, -- 1320
		"pause_mist", -- 1320
		menuX + 118, -- 1320
		headY - 8, -- 1320
		290, -- 1320
		72, -- 1320
		PALETTE.jadeMist, -- 1320
		0.2, -- 1320
		-1 -- 1320
	) -- 1320
	texts:put( -- 1322
		"banner", -- 1322
		"暂歇", -- 1322
		menuX + 16, -- 1322
		headY, -- 1322
		toColor(PALETTE.textBright), -- 1322
		0, -- 1322
		0.5, -- 1322
		"Left", -- 1322
		10, -- 1322
		0.98, -- 1322
		0.1 -- 1322
	) -- 1322
	texts:put( -- 1323
		"xs", -- 1323
		"月夜暂驻 · 卷页留痕", -- 1323
		menuX + 18, -- 1323
		headY - 36, -- 1323
		toColor(PALETTE.textDim), -- 1323
		0, -- 1323
		0.5, -- 1323
		"Left", -- 1323
		2, -- 1323
		0.8, -- 1323
		0.08 -- 1323
	) -- 1323
	drawHairline( -- 1324
		uiInkDraw, -- 1324
		uiArt, -- 1324
		"pause_div", -- 1324
		menuX + 124, -- 1324
		headY - 60, -- 1324
		240, -- 1324
		PALETTE.silkDim, -- 1324
		0.58, -- 1324
		true, -- 1324
		2 -- 1324
	) -- 1324
	local rowStep = compact and 42 or 46 -- 1326
	local rowH = compact and 36 or 38 -- 1327
	local firstY = compact and headY - 112 or headY - 120 -- 1328
	local boxes = {} -- 1329
	local i = 0 -- 1330
	do -- 1330
		i = 0 -- 1331
		while i < #pauseItems do -- 1331
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1332
			i = i + 1 -- 1331
		end -- 1331
	end -- 1331
	local prevPauseSel = self.pauseSelected -- 1334
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1335
	if self.pauseSelected ~= prevPauseSel then -- 1336
		self:emitSound("hover") -- 1337
	end -- 1337
	do -- 1337
		i = 0 -- 1340
		while i < #pauseItems do -- 1340
			local iy = boxes[i + 1].y -- 1341
			local active = self.pauseSelected == i -- 1342
			local cy = iy + rowH * 0.5 -- 1343
			local shiftX = active and 10 or 0 -- 1344
			local item = pauseItems[i + 1] -- 1345
			local label = item.zh -- 1346
			if item.id == "assist" then -- 1347
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1348
			elseif item.id == "fullscreen" then -- 1349
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1350
			elseif item.id == "settings" then -- 1351
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1352
			end -- 1352
			if active then -- 1355
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1356
				drawSilkRibbon( -- 1357
					uiDraw, -- 1357
					uiArt, -- 1357
					"pause_rib_" .. tostring(i), -- 1357
					menuX + 116, -- 1357
					cy, -- 1357
					282, -- 1357
					rowH, -- 1357
					PALETTE.rougeSoft, -- 1357
					0.54 * breathe, -- 1357
					0 -- 1357
				) -- 1357
				drawHairline( -- 1358
					uiInkDraw, -- 1358
					uiArt, -- 1358
					"pause_line_" .. tostring(i), -- 1358
					menuX + 106, -- 1358
					iy + 3, -- 1358
					210, -- 1358
					PALETTE.silkLine, -- 1358
					0.42 * breathe, -- 1358
					false, -- 1358
					2 -- 1358
				) -- 1358
				drawBlossomDot( -- 1359
					uiInkDraw, -- 1359
					uiArt, -- 1359
					"pause_dot_" .. tostring(i), -- 1359
					menuX + 12, -- 1359
					cy, -- 1359
					15, -- 1359
					PALETTE.rouge, -- 1359
					0.96, -- 1359
					4 -- 1359
				) -- 1359
				fillRadialGlow( -- 1360
					uiGlow, -- 1360
					menuX + 12, -- 1360
					cy, -- 1360
					22, -- 1360
					16, -- 1360
					toColor(PALETTE.rouge, 26 * breathe), -- 1360
					Color(182, 58, 56, 0), -- 1360
					10 -- 1360
				) -- 1360
			else -- 1360
				drawBlossomDot( -- 1362
					uiInkDraw, -- 1362
					uiArt, -- 1362
					"pause_dot_" .. tostring(i), -- 1362
					menuX + 12, -- 1362
					cy, -- 1362
					8, -- 1362
					PALETTE.silkDim, -- 1362
					0.4, -- 1362
					3 -- 1362
				) -- 1362
			end -- 1362
			texts:put( -- 1365
				compact and "sm" or "md", -- 1366
				label, -- 1367
				menuX + 32 + shiftX, -- 1368
				cy, -- 1369
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1370
				0, -- 1371
				0.5, -- 1372
				"Left", -- 1373
				active and 3.4 or 2.2, -- 1374
				active and 1 or 0.88, -- 1375
				0.1 -- 1376
			) -- 1376
			i = i + 1 -- 1340
		end -- 1340
	end -- 1340
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1380
	texts:put( -- 1385
		"xs", -- 1385
		pauseFooter, -- 1385
		menuX + 12, -- 1385
		38 + frame.safe.bottom * 0.4, -- 1385
		toColor(PALETTE.textDim), -- 1385
		0, -- 1385
		0.5, -- 1385
		"Left", -- 1385
		1.2, -- 1385
		0.86, -- 1385
		0.08 -- 1385
	) -- 1385
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1387
	if hit >= 0 or frame.keys.confirm then -- 1388
		local idx = hit >= 0 and hit or self.pauseSelected -- 1389
		local id = pauseItems[idx + 1].id -- 1390
		if id == "controls" then -- 1391
			self.pauseShowControls = true -- 1392
			self:emitSound("confirm") -- 1393
			self:resetInput() -- 1394
			return {type = "none"} -- 1395
		end -- 1395
		if id == "settings" then -- 1397
			self:openPauseSettings() -- 1398
			self:emitSound("confirm") -- 1399
			return {type = "none"} -- 1400
		end -- 1400
		if id == "assist" then -- 1402
			if onToggleAssist ~= nil then -- 1403
				onToggleAssist() -- 1404
			end -- 1404
			self:emitSound("toggle") -- 1406
			self:resetInput() -- 1407
			return {type = "none"} -- 1408
		end -- 1408
		if id == "fullscreen" then -- 1410
			self:emitSound("toggle") -- 1411
			self:resetInput() -- 1412
			return {type = "toggleFullscreen"} -- 1413
		end -- 1413
		self.pauseShowControls = false -- 1415
		self.pauseShowSettings = false -- 1416
		if id == "resume" then -- 1417
			self:emitSound("pauseClose") -- 1417
			return {type = "resume"} -- 1417
		end -- 1417
		if id == "retry" then -- 1418
			self:emitSound("confirm") -- 1418
			return {type = "retry"} -- 1418
		end -- 1418
		if id == "chapters" then -- 1419
			self:emitSound("confirm") -- 1419
			return {type = "openChapters"} -- 1419
		end -- 1419
		if id == "quit" then -- 1420
			self:emitSound("back") -- 1420
			return {type = "quit"} -- 1420
		end -- 1420
		self:emitSound("back") -- 1421
		return {type = "toTitle"} -- 1422
	end -- 1422
	return {type = "none"} -- 1424
end -- 1259
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1431
	if frame.back then -- 1441
		return {type = "backTitle"} -- 1442
	end -- 1442
	uiDraw:drawRect( -- 1446
		Rect(0, 0, w, h), -- 1446
		Color(7, 9, 15, 214) -- 1446
	) -- 1446
	local cx = w * 0.5 -- 1447
	local reunion = self.epilogueEnding == "reunion" -- 1448
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1449
	drawMistCurve( -- 1450
		uiArt, -- 1450
		"ep_mist", -- 1450
		cx, -- 1450
		h * 0.62, -- 1450
		620, -- 1450
		120, -- 1450
		accentCol, -- 1450
		0.2, -- 1450
		0 -- 1450
	) -- 1450
	fillRadialGlow( -- 1451
		uiGlow, -- 1451
		cx, -- 1451
		h * 0.68, -- 1451
		220, -- 1451
		140, -- 1451
		toColor(accentCol, 28), -- 1451
		Color(10, 14, 22, 0), -- 1451
		18 -- 1451
	) -- 1451
	local titleY = h * 0.72 -- 1454
	texts:put( -- 1455
		"title", -- 1455
		"向西守望", -- 1455
		cx - 18, -- 1455
		titleY, -- 1455
		toColor(PALETTE.textBright), -- 1455
		0.5, -- 1455
		0.5, -- 1455
		"Center", -- 1455
		12, -- 1455
		0.98, -- 1455
		0.12 -- 1455
	) -- 1455
	drawLoneSeal( -- 1456
		uiInkDraw, -- 1456
		uiArt, -- 1456
		texts, -- 1456
		"ep_seal", -- 1456
		cx + 148, -- 1456
		titleY - 2, -- 1456
		24, -- 1456
		46, -- 1456
		"守", -- 1456
		"望", -- 1456
		PALETTE.sealRed, -- 1456
		PALETTE.sealText, -- 1456
		0.94, -- 1456
		4 -- 1456
	) -- 1456
	drawHairline( -- 1457
		uiInkDraw, -- 1457
		uiArt, -- 1457
		"ep_div", -- 1457
		cx, -- 1457
		titleY - 46, -- 1457
		360, -- 1457
		PALETTE.silkDim, -- 1457
		0.62, -- 1457
		true, -- 1457
		2 -- 1457
	) -- 1457
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1459
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1460
	texts:put( -- 1463
		"md", -- 1463
		endingTitle, -- 1463
		cx, -- 1463
		titleY - 76, -- 1463
		toColor(PALETTE.amberCore), -- 1463
		0.5, -- 1463
		0.5, -- 1463
		"Center", -- 1463
		3.2, -- 1463
		0.96, -- 1463
		0.08 -- 1463
	) -- 1463
	texts:put( -- 1464
		"sm", -- 1464
		verse, -- 1464
		cx, -- 1464
		titleY - 114, -- 1464
		toColor(PALETTE.textMid), -- 1464
		0.5, -- 1464
		0.5, -- 1464
		"Center", -- 1464
		1, -- 1464
		0.92, -- 1464
		0.08 -- 1464
	) -- 1464
	if self.epilogueBothCleared then -- 1466
		drawSilkVeil( -- 1467
			uiDraw, -- 1467
			uiArt, -- 1467
			"ep_well_veil", -- 1467
			cx, -- 1467
			titleY - 152, -- 1467
			560, -- 1467
			30, -- 1467
			PALETTE.inkWarm, -- 1467
			0.68, -- 1467
			0 -- 1467
		) -- 1467
		texts:put( -- 1468
			"xs", -- 1468
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1468
			cx, -- 1468
			titleY - 152, -- 1468
			toColor(PALETTE.cyanCore), -- 1468
			0.5, -- 1468
			0.5, -- 1468
			"Center", -- 1468
			1, -- 1468
			0.9, -- 1468
			0.08 -- 1468
		) -- 1468
	end -- 1468
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1471
	local btnW = 286 -- 1476
	local btnH = 44 -- 1477
	local gap = 14 -- 1478
	local baseY = math.max(150, h * 0.34) -- 1479
	local boxes = {} -- 1480
	local i = 0 -- 1481
	do -- 1481
		i = 0 -- 1482
		while i < #items do -- 1482
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1483
			i = i + 1 -- 1482
		end -- 1482
	end -- 1482
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1485
	do -- 1485
		i = 0 -- 1487
		while i < #items do -- 1487
			local box = boxes[i + 1] -- 1488
			local active = self.epilogueSelected == i -- 1489
			local cy = box.y + box.height * 0.5 -- 1490
			if active then -- 1491
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1492
				drawSilkRibbon( -- 1493
					uiDraw, -- 1493
					uiArt, -- 1493
					"ep_rib_" .. tostring(i), -- 1493
					cx, -- 1493
					cy, -- 1493
					btnW + 24, -- 1493
					btnH, -- 1493
					PALETTE.rougeSoft, -- 1493
					0.62 * breathe, -- 1493
					0 -- 1493
				) -- 1493
				drawHairline( -- 1494
					uiInkDraw, -- 1494
					uiArt, -- 1494
					"ep_line_" .. tostring(i), -- 1494
					cx, -- 1494
					box.y + 3, -- 1494
					btnW - 44, -- 1494
					PALETTE.silkLine, -- 1494
					0.48 * breathe, -- 1494
					false, -- 1494
					2 -- 1494
				) -- 1494
				drawBlossomDot( -- 1495
					uiInkDraw, -- 1495
					uiArt, -- 1495
					"ep_dot_" .. tostring(i), -- 1495
					box.x + 22, -- 1495
					cy, -- 1495
					13, -- 1495
					PALETTE.rouge, -- 1495
					0.96, -- 1495
					4 -- 1495
				) -- 1495
			else -- 1495
				drawSilkVeil( -- 1497
					uiDraw, -- 1497
					uiArt, -- 1497
					"ep_idle_" .. tostring(i), -- 1497
					cx, -- 1497
					cy, -- 1497
					btnW, -- 1497
					btnH - 2, -- 1497
					PALETTE.inkWash, -- 1497
					0.58, -- 1497
					0 -- 1497
				) -- 1497
				drawBlossomDot( -- 1498
					uiInkDraw, -- 1498
					uiArt, -- 1498
					"ep_dot_" .. tostring(i), -- 1498
					box.x + 22, -- 1498
					cy, -- 1498
					8, -- 1498
					PALETTE.silkDim, -- 1498
					0.42, -- 1498
					3 -- 1498
				) -- 1498
			end -- 1498
			texts:put( -- 1500
				"sm", -- 1501
				items[i + 1].zh, -- 1502
				cx + 6, -- 1503
				cy, -- 1504
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1505
				0.5, -- 1506
				0.5, -- 1507
				"Center", -- 1508
				active and 2.6 or 1.6, -- 1509
				active and 1 or 0.88, -- 1510
				0.08 -- 1511
			) -- 1511
			i = i + 1 -- 1487
		end -- 1487
	end -- 1487
	local footer = frame.mode == "gamepad" and ((keyTagFor("confirm", "gamepad", frame.layout) .. " 确认   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回标题" or (frame.mode == "touch" and "轻触任一入口继续" or "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题") -- 1515
	texts:put( -- 1518
		"xs", -- 1518
		footer, -- 1518
		cx, -- 1518
		38 + frame.safe.bottom * 0.4, -- 1518
		toColor(PALETTE.textDim), -- 1518
		0.5, -- 1518
		0.5, -- 1518
		"Center", -- 1518
		1.2, -- 1518
		0.84, -- 1518
		0.08 -- 1518
	) -- 1518
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1520
	if hit >= 0 or frame.keys.confirm then -- 1521
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1522
		local id = items[idx + 1].id -- 1523
		if id == "history" then -- 1524
			return {type = "openHistory"} -- 1524
		end -- 1524
		if id == "replay" then -- 1525
			return {type = "replayStory"} -- 1525
		end -- 1525
		return {type = "backTitle"} -- 1526
	end -- 1526
	return {type = "none"} -- 1528
end -- 1431
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1535
	if frame.back then -- 1545
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1546
	end -- 1546
	local total = #HISTORY_CARDS -- 1549
	if frame.keys.left or frame.prevTab then -- 1550
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1551
	elseif frame.keys.right or frame.nextTab then -- 1552
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1553
	end -- 1553
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1555
	uiDraw:drawRect( -- 1557
		Rect(0, 0, w, h), -- 1557
		Color(7, 9, 15, 206) -- 1557
	) -- 1557
	local cx = w * 0.5 -- 1558
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1559
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1560
	local px = cx - pageW * 0.5 -- 1561
	local py = (h - pageH) * 0.5 + 14 -- 1562
	local midY = py + pageH * 0.5 -- 1563
	uiArt:tryPlace( -- 1565
		"ink_frame_mask", -- 1565
		"hist_shadow", -- 1565
		cx, -- 1565
		midY - 6, -- 1565
		pageW + 52, -- 1565
		pageH + 46, -- 1565
		{ -- 1565
			color = toColor(PALETTE.voidDark), -- 1566
			opacity = 0.84, -- 1566
			layer = -1 -- 1566
		} -- 1566
	) -- 1566
	if not uiArt:tryPlace( -- 1568
		"ink_song_paper", -- 1568
		"hist_paper", -- 1568
		cx, -- 1568
		midY, -- 1568
		pageW, -- 1568
		pageH, -- 1568
		{opacity = 0.98, layer = 1} -- 1568
	) then -- 1568
		uiDraw:drawRect( -- 1569
			Rect(px, py, pageW, pageH), -- 1569
			toColor(PALETTE.xuanPaper, 248), -- 1569
			1, -- 1569
			toColor(PALETTE.silkDim, 180) -- 1569
		) -- 1569
	end -- 1569
	fillRadialGlow( -- 1571
		uiGlow, -- 1571
		cx, -- 1571
		midY + 40, -- 1571
		260, -- 1571
		140, -- 1571
		Color(236, 224, 202, 16), -- 1571
		Color(236, 224, 202, 0), -- 1571
		14 -- 1571
	) -- 1571
	local inX = px + 42 -- 1574
	local inY = py + 32 -- 1575
	local inW = pageW - 84 -- 1576
	local inH = pageH - 64 -- 1577
	local redSilk = toColor(PALETTE.rouge, 118) -- 1578
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1579
	uiInkDraw:drawRect( -- 1580
		Rect(inX, inY, inW, inH), -- 1580
		Color(0, 0, 0, 0), -- 1580
		0.95, -- 1580
		redSilk -- 1580
	) -- 1580
	uiInkDraw:drawRect( -- 1581
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1581
		Color(0, 0, 0, 0), -- 1581
		0.55, -- 1581
		redSilkFaint -- 1581
	) -- 1581
	local headY = inY + inH - 30 -- 1584
	texts:put( -- 1585
		"md", -- 1585
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1585
		inX + 20, -- 1585
		headY, -- 1585
		toColor(PALETTE.xuanInk), -- 1585
		0, -- 1585
		0.5, -- 1585
		"Left", -- 1585
		2, -- 1585
		0.96, -- 1585
		0 -- 1585
	) -- 1585
	texts:put( -- 1586
		"xs", -- 1586
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1586
		inX + inW - 20, -- 1586
		headY, -- 1586
		toColor(PALETTE.rouge), -- 1586
		1, -- 1586
		0.5, -- 1586
		"Right", -- 1586
		1.8, -- 1586
		0.88, -- 1586
		0 -- 1586
	) -- 1586
	uiInkDraw:drawSegment( -- 1587
		Vec2(inX + 14, headY - 22), -- 1587
		Vec2(inX + inW - 14, headY - 22), -- 1587
		0.85, -- 1587
		redSilk -- 1587
	) -- 1587
	texts:put( -- 1590
		"xs", -- 1590
		card.subtitle, -- 1590
		inX + 20, -- 1590
		headY - 42, -- 1590
		toColor(PALETTE.xuanInkSub), -- 1590
		0, -- 1590
		0.5, -- 1590
		"Left", -- 1590
		1.4, -- 1590
		0.86, -- 1590
		0 -- 1590
	) -- 1590
	local function wrapZh(src, maxUnits) -- 1593
		local out = {} -- 1594
		local buf = "" -- 1595
		local units = 0 -- 1596
		local ci = 0 -- 1597
		while ci < #src do -- 1598
			local b = __TS__StringCharCodeAt(src, ci) -- 1599
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1600
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1601
			local u = b < 128 and 0.56 or 1.02 -- 1602
			if units + u > maxUnits and buf ~= "" then -- 1603
				out[#out + 1] = buf -- 1604
				buf = ch -- 1605
				units = u -- 1606
			else -- 1606
				buf = buf .. ch -- 1608
				units = units + u -- 1609
			end -- 1609
			ci = ci + step -- 1611
		end -- 1611
		if buf ~= "" then -- 1613
			out[#out + 1] = buf -- 1614
		end -- 1614
		return out -- 1616
	end -- 1593
	local charsPerLine = math.max( -- 1619
		24, -- 1619
		math.floor((inW - 44) / 20) -- 1619
	) -- 1619
	local cursorY = headY - 76 -- 1620
	local pi = 0 -- 1621
	do -- 1621
		pi = 0 -- 1622
		while pi < #card.paragraphs do -- 1622
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1623
			local li = 0 -- 1624
			do -- 1624
				li = 0 -- 1625
				while li < #lines do -- 1625
					texts:put( -- 1626
						"sm", -- 1626
						lines[li + 1], -- 1626
						inX + 22, -- 1626
						cursorY, -- 1626
						toColor(PALETTE.xuanInk), -- 1626
						0, -- 1626
						0.5, -- 1626
						"Left", -- 1626
						0.6, -- 1626
						0.94, -- 1626
						0 -- 1626
					) -- 1626
					cursorY = cursorY - 30 -- 1627
					li = li + 1 -- 1625
				end -- 1625
			end -- 1625
			cursorY = cursorY - 12 -- 1629
			pi = pi + 1 -- 1622
		end -- 1622
	end -- 1622
	local footY = inY + 26 -- 1633
	uiInkDraw:drawSegment( -- 1634
		Vec2(inX + 14, footY + 20), -- 1634
		Vec2(inX + inW - 14, footY + 20), -- 1634
		0.6, -- 1634
		redSilkFaint -- 1634
	) -- 1634
	texts:put( -- 1635
		"xs", -- 1635
		card.footnote, -- 1635
		inX + 20, -- 1635
		footY, -- 1635
		toColor(PALETTE.xuanInkSub), -- 1635
		0, -- 1635
		0.5, -- 1635
		"Left", -- 1635
		0.4, -- 1635
		0.84, -- 1635
		0 -- 1635
	) -- 1635
	local navY = math.max(30, py - 48) -- 1638
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1639
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1640
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1641
	local function drawNavBtn(box, tag, label) -- 1643
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1644
		drawSilkVeil( -- 1645
			uiDraw, -- 1645
			uiArt, -- 1645
			"hist_btn_" .. tag, -- 1645
			box.x + box.width * 0.5, -- 1645
			box.y + box.height * 0.5, -- 1645
			box.width, -- 1645
			box.height, -- 1645
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1645
			hover and 0.86 or 0.72, -- 1645
			2 -- 1645
		) -- 1645
		texts:put( -- 1646
			"xs", -- 1646
			label, -- 1646
			box.x + box.width * 0.5, -- 1646
			box.y + box.height * 0.5, -- 1646
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1646
			0.5, -- 1646
			0.5, -- 1646
			"Center", -- 1646
			1.4, -- 1646
			0.94, -- 1646
			0.08 -- 1646
		) -- 1646
		return hover and frame.click -- 1647
	end -- 1643
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1650
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1651
	end -- 1651
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1653
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1654
	end -- 1654
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1656
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1657
	end -- 1657
	if frame.keys.confirm then -- 1660
		if self.historyCardIndex + 1 < total then -- 1661
			self.historyCardIndex = self.historyCardIndex + 1 -- 1662
		else -- 1662
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1664
		end -- 1664
	end -- 1664
	return {type = "none"} -- 1667
end -- 1535
return ____exports -- 1535
