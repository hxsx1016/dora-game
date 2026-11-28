-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
local Color = ____Dora.Color -- 11
local Rect = ____Dora.Rect -- 11
local Vec2 = ____Dora.Vec2 -- 11
local ____rooms = require("Script.watch.rooms") -- 12
local ROOMS = ____rooms.ROOMS -- 12
local ____save = require("Script.watch.save") -- 15
local formatPlayDuration = ____save.formatPlayDuration -- 18
local formatSavedAt = ____save.formatSavedAt -- 19
local listSaveSlots = ____save.listSaveSlots -- 20
local ____platform = require("Script.watch.platform") -- 22
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 24
local canQuitApp = ____platform.canQuitApp -- 25
local canToggleFullscreen = ____platform.canToggleFullscreen -- 26
local ____target = require("Script.watch.target") -- 28
local getActiveTarget = ____target.getActiveTarget -- 28
local ____dialogues = require("Script.watch.dialogues") -- 29
local HISTORY_CARDS = ____dialogues.HISTORY_CARDS -- 29
local ____theme = require("Script.watch.fe.theme") -- 33
local PALETTE = ____theme.PALETTE -- 34
local drawBlossomDot = ____theme.drawBlossomDot -- 35
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 36
local drawHairline = ____theme.drawHairline -- 37
local drawLoneSeal = ____theme.drawLoneSeal -- 38
local drawMistCurve = ____theme.drawMistCurve -- 39
local drawSilkKeycap = ____theme.drawSilkKeycap -- 40
local drawSilkRibbon = ____theme.drawSilkRibbon -- 41
local drawSilkVeil = ____theme.drawSilkVeil -- 42
local fillHGradRect = ____theme.fillHGradRect -- 43
local fillRadialGlow = ____theme.fillRadialGlow -- 44
local fillVGradRect = ____theme.fillVGradRect -- 45
local themeOf = ____theme.themeOf -- 46
local toColor = ____theme.toColor -- 47
local visualTextWidth = ____theme.visualTextWidth -- 48
local TITLE_ITEMS = { -- 84
	{id = "start", zh = "开始游戏"}, -- 85
	{id = "chapters", zh = "选择章节"}, -- 86
	{id = "controls", zh = "操作说明"}, -- 87
	{id = "saves", zh = "读取存档"}, -- 88
	{id = "settings", zh = "游戏设置"}, -- 89
	{id = "quit", zh = "退出游戏"} -- 90
} -- 90
local CHAPTERS = (function() -- 105
	local out = {} -- 106
	local i = 0 -- 107
	do -- 107
		i = 0 -- 108
		while i < #ROOMS do -- 108
			do -- 108
				local room = ROOMS[i + 1] -- 109
				if room.key == "museum" or room.key == "street" or room.key == "checkpoint" then -- 109
					goto __continue4 -- 111
				end -- 111
				if room.key == "tower" then -- 111
					out[#out + 1] = { -- 114
						room = room, -- 115
						roomIndex = i, -- 116
						route = "child", -- 117
						titleOverride = "终章 · 北塔留灯", -- 118
						shortNameOverride = "北塔·留灯", -- 119
						lineTagOverride = "小满", -- 120
						whisperOverride = "孤身叩响北塔门，西窗留一盏向西的灯。" -- 121
					} -- 121
					out[#out + 1] = { -- 123
						room = room, -- 124
						roomIndex = i, -- 125
						route = "soldier", -- 126
						titleOverride = "终章 · 北塔团圆", -- 127
						shortNameOverride = "北塔·团圆", -- 128
						lineTagOverride = "周戍", -- 129
						whisperOverride = "兄妹并肩跨过塔门，两行姓名同落登记簿。" -- 130
					} -- 130
					goto __continue4 -- 132
				end -- 132
				out[#out + 1] = {room = room, roomIndex = i} -- 134
			end -- 134
			::__continue4:: -- 134
			i = i + 1 -- 108
		end -- 108
	end -- 108
	return out -- 136
end)() -- 105
local PAUSE_ITEMS = { -- 140
	{id = "resume", zh = "继续游戏"}, -- 141
	{id = "retry", zh = "重试检查点"}, -- 142
	{id = "controls", zh = "操作说明"}, -- 143
	{id = "assist", zh = "按键辅助：关"}, -- 144
	{id = "fullscreen", zh = "显示：窗口"}, -- 145
	{id = "chapters", zh = "选择章节"}, -- 146
	{id = "title", zh = "返回标题"}, -- 147
	{id = "quit", zh = "退出游戏"}, -- 148
	{id = "settings", zh = "操控设置"}, -- 149
	{id = "ledger", zh = "行军札记"}, -- 150
	{id = "saves", zh = "存取档案"} -- 151
} -- 151
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 154
local EPIGRAPH_RIGHT = { -- 155
	"城", -- 155
	"破", -- 155
	"那", -- 155
	"天", -- 155
	"", -- 155
	"他", -- 155
	"留", -- 155
	"下", -- 155
	"断", -- 155
	"后" -- 155
} -- 155
local EPIGRAPH_LEFT = { -- 156
	"她", -- 156
	"独", -- 156
	"自", -- 156
	"走", -- 156
	"向", -- 156
	"北", -- 156
	"塔" -- 156
} -- 156
local function hitIndex(boxes, pointer, inside) -- 181
	if not inside then -- 181
		return -1 -- 183
	end -- 183
	return __TS__ArrayFindIndex( -- 185
		boxes, -- 185
		function(____, box) return box:containsPoint(pointer) end -- 185
	) -- 185
end -- 181
____exports.MenuRenderer = __TS__Class() -- 188
local MenuRenderer = ____exports.MenuRenderer -- 188
MenuRenderer.name = "MenuRenderer" -- 188
function MenuRenderer.prototype.____constructor(self) -- 188
	self.selected = 0 -- 189
	self.chapterSelected = 0 -- 190
	self.pauseSelected = 0 -- 191
	self.settingsSelected = 0 -- 192
	self.saveSelected = 0 -- 193
	self.saveActionSelected = 0 -- 194
	self.epilogueSelected = 0 -- 195
	self.epilogueEnding = "lamp" -- 196
	self.epilogueBothCleared = false -- 197
	self.historyCardIndex = 0 -- 198
	self.historyFromEpilogue = false -- 199
	self.hasSession = false -- 201
	self.sessionLabel = "" -- 203
	self.saveSlots = {} -- 205
	self.controlsTab = "kbm" -- 211
	self.chaptersFromPause = false -- 227
	self.pauseShowControls = false -- 228
	self.pauseShowSettings = false -- 229
	self.pauseShowSaves = false -- 230
	self.titleConfirmNewGame = false -- 231
	self.titleConfirmSel = 1 -- 232
	self.saveConfirmKind = "" -- 233
	self.saveConfirmSlot = 1 -- 234
	self.saveConfirmSel = 1 -- 235
	self.controlsTabManual = false -- 236
	self.queuedKeys = {} -- 237
	self.queuedBack = false -- 238
	self.queuedSkip = false -- 239
	self.splashTime = 0 -- 240
	self.time = 0 -- 241
end -- 188
function MenuRenderer.prototype.setSessionRoomKey(self, roomKey) -- 207
	self.sessionLabel = roomKey ~= "" and themeOf(roomKey).shortNameZh or "" -- 208
end -- 207
function MenuRenderer.prototype.emitSound(self, kind) -- 221
	if self.onUiSound ~= nil then -- 221
		self:onUiSound(kind) -- 223
	end -- 223
end -- 221
function MenuRenderer.prototype.resetSplash(self) -- 243
	self.splashTime = 0 -- 244
	self.queuedSkip = false -- 245
	self:resetInput() -- 246
end -- 243
function MenuRenderer.prototype.isShowingPauseControls(self) -- 249
	return self.pauseShowControls -- 250
end -- 249
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 253
	return self.pauseShowSettings -- 254
end -- 253
function MenuRenderer.prototype.isShowingPauseSaves(self) -- 257
	return self.pauseShowSaves -- 258
end -- 257
function MenuRenderer.prototype.isShowingTitleConfirm(self) -- 261
	return self.titleConfirmNewGame -- 262
end -- 261
function MenuRenderer.prototype.refreshSaveSlots(self) -- 265
	self.saveSlots = listSaveSlots() -- 266
end -- 265
function MenuRenderer.prototype.openSaves(self, fromPause) -- 269
	if fromPause == nil then -- 269
		fromPause = false -- 269
	end -- 269
	self:refreshSaveSlots() -- 270
	self.saveSelected = fromPause and 1 or 0 -- 271
	self.saveActionSelected = 0 -- 272
	self.saveConfirmKind = "" -- 273
	self.saveConfirmSel = 1 -- 274
	self.pauseShowControls = false -- 275
	self.pauseShowSettings = false -- 276
	self.pauseShowSaves = fromPause -- 277
	self:resetInput() -- 278
end -- 269
function MenuRenderer.prototype.openSettings(self) -- 281
	self.settingsSelected = 0 -- 282
	self.titleConfirmNewGame = false -- 283
	self:resetInput() -- 284
end -- 281
function MenuRenderer.prototype.openPauseSettings(self) -- 287
	self.pauseShowControls = false -- 288
	self.pauseShowSaves = false -- 289
	self.pauseShowSettings = true -- 290
	self.settingsSelected = 0 -- 291
	self:resetInput() -- 292
end -- 287
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 295
	self.chaptersFromPause = roomIndex ~= nil -- 296
	self.chapterSelected = math.max( -- 297
		0, -- 297
		__TS__ArrayFindIndex( -- 297
			CHAPTERS, -- 297
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 297
		) -- 297
	) -- 297
	self.pauseShowControls = false -- 298
	self.pauseShowSettings = false -- 299
	self.pauseShowSaves = false -- 300
	self.titleConfirmNewGame = false -- 301
	self:resetInput() -- 302
end -- 295
function MenuRenderer.prototype.openPause(self) -- 305
	self.pauseSelected = 0 -- 306
	self.pauseShowControls = false -- 307
	self.pauseShowSettings = false -- 308
	self.pauseShowSaves = false -- 309
	self.saveConfirmKind = "" -- 310
	self:resetInput() -- 311
end -- 305
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 314
	if ending == nil then -- 314
		ending = "lamp" -- 314
	end -- 314
	if bothCleared == nil then -- 314
		bothCleared = false -- 314
	end -- 314
	self.epilogueEnding = ending -- 315
	self.epilogueBothCleared = bothCleared -- 316
	self.epilogueSelected = 0 -- 317
	self:resetInput() -- 318
end -- 314
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 321
	if fromEpilogue == nil then -- 321
		fromEpilogue = true -- 321
	end -- 321
	self.historyFromEpilogue = fromEpilogue -- 322
	self.historyCardIndex = 0 -- 323
	self:resetInput() -- 324
end -- 321
function MenuRenderer.prototype.triggerBack(self) -- 328
	self.queuedBack = true -- 329
end -- 328
function MenuRenderer.prototype.resetInput(self) -- 333
	self.queuedKeys = {} -- 334
	self.queuedBack = false -- 335
	self.queuedSkip = false -- 336
	self.controlsTabManual = false -- 337
end -- 333
function MenuRenderer.prototype.onKeyEvent(self, key) -- 341
	self.queuedSkip = true -- 342
	if key == "Up" or key == "W" then -- 342
		self.queuedKeys.up = true -- 344
	elseif key == "Down" or key == "S" then -- 344
		self.queuedKeys.down = true -- 346
	elseif key == "Left" or key == "A" then -- 346
		self.queuedKeys.left = true -- 348
	elseif key == "Right" or key == "D" then -- 348
		self.queuedKeys.right = true -- 350
	elseif key == "Return" or key == "Space" then -- 350
		self.queuedKeys.confirm = true -- 352
	elseif key == "Escape" then -- 352
		self.queuedBack = true -- 354
	end -- 354
end -- 341
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 358
	local queued = self.queuedKeys -- 359
	local useUiPtr = input.uiInside or input.uiPressed -- 362
	local rawX = useUiPtr and input.uiX or input.mx -- 363
	local rawY = useUiPtr and input.uiY or input.my -- 364
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 365
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 366
	local ____useUiPtr_0 -- 367
	if useUiPtr then -- 367
		____useUiPtr_0 = input.uiInside -- 367
	else -- 367
		____useUiPtr_0 = input.inside -- 367
	end -- 367
	local inside = ____useUiPtr_0 -- 367
	local ____useUiPtr_1 -- 368
	if useUiPtr then -- 368
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 368
	else -- 368
		____useUiPtr_1 = input.inside and input.fire.pressed -- 368
	end -- 368
	local click = ____useUiPtr_1 -- 368
	local touchMode = input:isTouchMode() -- 369
	local frame = { -- 371
		keys = { -- 372
			up = queued.up == true or input.navUp, -- 373
			down = queued.down == true or input.navDown, -- 374
			left = queued.left == true or input.navLeft, -- 375
			right = queued.right == true or input.navRight, -- 376
			confirm = queued.confirm == true or input.navConfirm -- 377
		}, -- 377
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 379
		prevTab = input.navPrevTab, -- 380
		nextTab = input.navNextTab, -- 381
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 382
		pointer = Vec2(rawX / scale, rawY / scale), -- 383
		inside = inside, -- 384
		click = click, -- 385
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 386
		mode = input.inputMode, -- 387
		layout = input.gamepadLayout, -- 388
		safe = safe -- 389
	} -- 389
	self.queuedKeys = {} -- 391
	self.queuedBack = false -- 392
	self.queuedSkip = false -- 393
	return frame -- 394
end -- 358
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 397
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 398
	if frame.click and hit >= 0 then -- 398
		return hit -- 400
	end -- 400
	if frame.keys.up then -- 400
		return (selected + #boxes - 1) % #boxes -- 403
	end -- 403
	if frame.keys.down then -- 403
		return (selected + 1) % #boxes -- 406
	end -- 406
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 408
end -- 397
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 411
	if safeUi == nil then -- 411
		safeUi = ZERO_SAFE_INSETS -- 427
	end -- 427
	self.time = self.time + dt -- 429
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 430
	if screen ~= "splash" or splashDissolving then -- 430
		local artW = math.max(w, h * 16 / 9) -- 432
		local artH = artW * 9 / 16 -- 433
		if not backdropArt:tryPlace( -- 433
			"title_backdrop", -- 434
			"menu_landscape", -- 434
			w * 0.5, -- 434
			(h - artH) * 0.5, -- 434
			artW, -- 434
			artH -- 434
		) then -- 434
			stage:drawMenuBackdrop( -- 435
				bgDraw, -- 435
				bgGlow, -- 435
				w, -- 435
				h, -- 435
				self.time -- 435
			) -- 435
		end -- 435
	end -- 435
	local frame = self:readFrame(input, uiScale, safeUi) -- 439
	w = w / uiScale -- 440
	h = h / uiScale -- 441
	if screen == "splash" then -- 441
		return self:drawSplash( -- 444
			dt, -- 444
			frame, -- 444
			uiDraw, -- 444
			uiArt, -- 444
			texts, -- 444
			w, -- 444
			h -- 444
		) -- 444
	end -- 444
	if screen == "title" then -- 444
		return self:drawTitle( -- 447
			frame, -- 447
			uiDraw, -- 447
			uiInkDraw, -- 447
			uiArt, -- 447
			uiGlow, -- 447
			texts, -- 447
			w, -- 447
			h -- 447
		) -- 447
	end -- 447
	if screen == "chapters" then -- 447
		return self:drawChapters( -- 450
			frame, -- 450
			uiDraw, -- 450
			uiInkDraw, -- 450
			uiArt, -- 450
			uiGlow, -- 450
			texts, -- 450
			w, -- 450
			h -- 450
		) -- 450
	end -- 450
	if screen == "saves" then -- 450
		return self:drawSavesPanel( -- 453
			frame, -- 453
			uiDraw, -- 453
			uiInkDraw, -- 453
			uiArt, -- 453
			uiGlow, -- 453
			texts, -- 453
			w, -- 453
			h, -- 453
			false, -- 453
			false -- 453
		) -- 453
	end -- 453
	if screen == "settings" then -- 453
		if self:drawPauseSettings( -- 453
			frame, -- 456
			input, -- 456
			uiDraw, -- 456
			uiInkDraw, -- 456
			uiArt, -- 456
			uiGlow, -- 456
			texts, -- 456
			w, -- 456
			h -- 456
		) then -- 456
			return {type = "backTitle"} -- 457
		end -- 457
		return {type = "none"} -- 459
	end -- 459
	if screen == "epilogue" then -- 459
		return self:drawEpilogue( -- 462
			frame, -- 462
			uiDraw, -- 462
			uiInkDraw, -- 462
			uiArt, -- 462
			uiGlow, -- 462
			texts, -- 462
			w, -- 462
			h -- 462
		) -- 462
	end -- 462
	if screen == "history" then -- 462
		return self:drawHistory( -- 465
			frame, -- 465
			uiDraw, -- 465
			uiInkDraw, -- 465
			uiArt, -- 465
			uiGlow, -- 465
			texts, -- 465
			w, -- 465
			h -- 465
		) -- 465
	end -- 465
	return self:drawControls( -- 467
		frame, -- 467
		uiDraw, -- 467
		uiInkDraw, -- 467
		uiArt, -- 467
		uiGlow, -- 467
		texts, -- 467
		w, -- 467
		h -- 467
	) -- 467
end -- 411
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 476
	local safeDt = math.min( -- 485
		0.1, -- 485
		math.max(0, dt) -- 485
	) -- 485
	self.splashTime = self.splashTime + safeDt -- 486
	local t = self.splashTime -- 487
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 489
	if wantSkip or t >= 4.65 then -- 489
		self.splashTime = 0 -- 491
		return {type = "splashDone"} -- 492
	end -- 492
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 495
	local bgR = t < 2.2 and 13 or 11 -- 496
	local bgG = t < 2.2 and 16 or 13 -- 497
	local bgB = t < 2.2 and 24 or 19 -- 498
	uiDraw:drawRect( -- 499
		Rect(0, 0, w, h), -- 499
		Color( -- 499
			bgR, -- 499
			bgG, -- 499
			bgB, -- 499
			math.floor(255 * fadeOutCurtain + 0.5) -- 499
		) -- 499
	) -- 499
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 501
		if localT <= 0 or localT >= endT then -- 501
			return 0 -- 502
		end -- 502
		if localT < fadeIn then -- 502
			local u = localT / fadeIn -- 504
			return u * u * (3 - 2 * u) -- 505
		end -- 505
		if localT <= holdEnd then -- 505
			return 1 -- 507
		end -- 507
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 508
		return 1 - u * u * (3 - 2 * u) -- 509
	end -- 501
	if t < 2.2 then -- 501
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 513
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 514
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 515
		if not uiArt:tryPlace( -- 515
			"brand_team_logo", -- 516
			"splash_team_logo", -- 516
			w * 0.5, -- 516
			h * 0.54, -- 516
			logoH * 2, -- 516
			logoH, -- 516
			{opacity = alpha, layer = 2} -- 516
		) then -- 516
			texts:put( -- 517
				"banner", -- 517
				"OUTSIDER", -- 517
				w * 0.5, -- 517
				h * 0.52, -- 517
				toColor(PALETTE.textBright), -- 517
				0.5, -- 517
				0.5, -- 517
				"Center", -- 517
				6, -- 517
				alpha, -- 517
				0 -- 517
			) -- 517
		end -- 517
		texts:put( -- 519
			"xs", -- 519
			"Powered by Dora SSR", -- 519
			w * 0.5, -- 519
			58 + frame.safe.bottom * 0.4, -- 519
			toColor(PALETTE.textDim), -- 519
			0.5, -- 519
			0.5, -- 519
			"Center", -- 519
			1.8, -- 519
			alpha * 0.62, -- 519
			0 -- 519
		) -- 519
	elseif t < 4.25 then -- 519
		local localT = t - 2.2 -- 521
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 522
		local sway = math.sin(localT * 1.1) * 8 -- 523
		drawMistCurve( -- 524
			uiArt, -- 524
			"splash_game_mist", -- 524
			w * 0.5 + sway, -- 524
			h * 0.46, -- 524
			560, -- 524
			110, -- 524
			PALETTE.jadeMist, -- 524
			0.16 * alpha, -- 524
			1 -- 524
		) -- 524
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 525
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 526
		if not uiArt:tryPlace( -- 526
			"brand_game_logo_h", -- 527
			"splash_game_logo", -- 527
			w * 0.5, -- 527
			h * 0.52, -- 527
			logoH * 2.4, -- 527
			logoH, -- 527
			{opacity = alpha, layer = 2} -- 527
		) then -- 527
			texts:put( -- 528
				"title", -- 528
				"向西守望", -- 528
				w * 0.5, -- 528
				h * 0.52, -- 528
				toColor(PALETTE.textBright), -- 528
				0.5, -- 528
				0.5, -- 528
				"Center", -- 528
				8, -- 528
				alpha, -- 528
				0 -- 528
			) -- 528
		end -- 528
	end -- 528
	if t >= 0.35 and t < 4.15 then -- 528
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 533
		local skipText = getActiveTarget():splashSkipHint(frame.mode, frame.layout) -- 534
		texts:put( -- 535
			"xs", -- 535
			skipText, -- 535
			w - 48 - frame.safe.right * 0.6, -- 535
			36 + frame.safe.bottom * 0.4, -- 535
			toColor(PALETTE.textDim), -- 535
			1, -- 535
			0.5, -- 535
			"Right", -- 535
			1.4, -- 535
			hintA, -- 535
			0 -- 535
		) -- 535
	end -- 535
	return {type = "none"} -- 538
end -- 476
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 541
	fillHGradRect( -- 551
		uiDraw, -- 551
		0, -- 551
		0, -- 551
		w * 0.22 + frame.safe.left * 0.5, -- 551
		h, -- 551
		Color(9, 11, 18, 192), -- 551
		Color(9, 11, 18, 116) -- 551
	) -- 551
	fillHGradRect( -- 552
		uiDraw, -- 552
		w * 0.22 + frame.safe.left * 0.5, -- 552
		0, -- 552
		w * 0.28, -- 552
		h, -- 552
		Color(9, 11, 18, 116), -- 552
		Color(9, 11, 18, 0) -- 552
	) -- 552
	fillVGradRect( -- 553
		uiDraw, -- 553
		0, -- 553
		0, -- 553
		w, -- 553
		78, -- 553
		Color(8, 10, 16, 138), -- 553
		Color(8, 10, 16, 0) -- 553
	) -- 553
	local extraH = math.max(0, h - 720) -- 555
	local titleX = 148 + frame.safe.left * 0.6 -- 556
	local topY = h - 104 - frame.safe.top * 0.4 -- 557
	local charStep = 66 -- 558
	local sway = math.sin(self.time * 0.7) * 5 -- 559
	drawMistCurve( -- 560
		uiArt, -- 560
		"title_mist_wisp", -- 560
		titleX + 86 + sway, -- 560
		topY - 122, -- 560
		340, -- 560
		82, -- 560
		PALETTE.jadeMist, -- 560
		0.2, -- 560
		-1 -- 560
	) -- 560
	uiArt:tryPlace( -- 561
		"ink_petal_mist", -- 561
		"title_petals", -- 561
		titleX + 12, -- 561
		topY - 102, -- 561
		230, -- 561
		210, -- 561
		{ -- 561
			color = toColor(PALETTE.inkMist), -- 562
			opacity = 0.4, -- 562
			layer = -1 -- 562
		} -- 562
	) -- 562
	local placedBrandTitle = uiArt:tryPlace( -- 566
		"brand_game_logo_v", -- 566
		"title_brand_v", -- 566
		titleX + 22, -- 566
		topY - 106, -- 566
		240, -- 566
		304, -- 566
		{opacity = 0.98, layer = 3} -- 566
	) -- 566
	if not placedBrandTitle then -- 566
		uiArt:tryPlace( -- 570
			"ink_vstream", -- 570
			"title_vstream", -- 570
			titleX - 48, -- 570
			topY - 100, -- 570
			34, -- 570
			290, -- 570
			{ -- 570
				color = toColor(PALETTE.silkDim), -- 571
				opacity = 0.48, -- 571
				layer = 1 -- 571
			} -- 571
		) -- 571
		local c = 0 -- 573
		do -- 573
			c = 0 -- 574
			while c < #VERTICAL_TITLE do -- 574
				texts:put( -- 575
					"title", -- 576
					VERTICAL_TITLE[c + 1], -- 577
					titleX, -- 578
					topY - c * charStep, -- 579
					toColor(PALETTE.textBright), -- 580
					0.5, -- 581
					0.5, -- 582
					"Center", -- 583
					0, -- 584
					0.98, -- 585
					0.1, -- 586
					Color(8, 10, 16, 210) -- 587
				) -- 587
				c = c + 1 -- 574
			end -- 574
		end -- 574
		drawLoneSeal( -- 590
			uiInkDraw, -- 591
			uiArt, -- 592
			texts, -- 593
			"title_lone_seal", -- 594
			titleX + 46, -- 595
			topY - 3 * charStep + 8, -- 596
			26, -- 597
			52, -- 598
			"守", -- 599
			"望", -- 600
			PALETTE.sealRed, -- 601
			PALETTE.sealText, -- 602
			0.94, -- 603
			4 -- 604
		) -- 604
	end -- 604
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 609
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 610
	local poemStep = 22 -- 611
	local p = 0 -- 612
	do -- 612
		p = 0 -- 613
		while p < #EPIGRAPH_RIGHT do -- 613
			local ch = EPIGRAPH_RIGHT[p + 1] -- 614
			if ch ~= "" then -- 614
				texts:put( -- 616
					"xs", -- 616
					ch, -- 616
					colRightX, -- 616
					topY - 22 - p * poemStep, -- 616
					toColor(PALETTE.textMid), -- 616
					0.5, -- 616
					0.5, -- 616
					"Center", -- 616
					0, -- 616
					0.86, -- 616
					0.08 -- 616
				) -- 616
			end -- 616
			p = p + 1 -- 613
		end -- 613
	end -- 613
	do -- 613
		p = 0 -- 619
		while p < #EPIGRAPH_LEFT do -- 619
			texts:put( -- 620
				"xs", -- 620
				EPIGRAPH_LEFT[p + 1], -- 620
				colLeftX, -- 620
				topY - 68 - p * poemStep, -- 620
				toColor(PALETTE.amberCore), -- 620
				0.5, -- 620
				0.5, -- 620
				"Center", -- 620
				0, -- 620
				0.9, -- 620
				0.08 -- 620
			) -- 620
			p = p + 1 -- 619
		end -- 619
	end -- 619
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 624
		TITLE_ITEMS, -- 626
		function(____, it) return it.id ~= "quit" end -- 626
	) -- 626
	local items = self.hasSession and ({ -- 627
		{id = "continue", zh = "继续游戏"}, -- 628
		table.unpack(baseItems) -- 628
	}) or baseItems -- 628
	if self.selected >= #items then -- 628
		self.selected = 0 -- 631
	end -- 631
	local denseTitle = #items >= 6 -- 633
	local veryDenseTitle = #items >= 7 -- 634
	local menuX = 112 + frame.safe.left * 0.6 -- 635
	local btnW = 280 -- 636
	local btnH = veryDenseTitle and 34 or (denseTitle and 36 or (frame.mode == "touch" and 44 or 40)) -- 637
	local gap = veryDenseTitle and 5 or (denseTitle and 5 or 8) -- 638
	local startY = (veryDenseTitle and 306 or (denseTitle and 274 or 268)) + extraH * 0.35 -- 639
	local boxes = {} -- 640
	local i = 0 -- 641
	do -- 641
		i = 0 -- 642
		while i < #items do -- 642
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 643
			i = i + 1 -- 642
		end -- 642
	end -- 642
	if not self.titleConfirmNewGame then -- 642
		local prevTitleSel = self.selected -- 647
		self.selected = self:verticalSelection(self.selected, boxes, frame) -- 648
		if self.selected ~= prevTitleSel then -- 648
			self:emitSound("hover") -- 650
		end -- 650
	end -- 650
	do -- 650
		i = 0 -- 654
		while i < #items do -- 654
			local by = boxes[i + 1].y -- 655
			local active = not self.titleConfirmNewGame and self.selected == i -- 656
			local cy = by + btnH * 0.5 -- 657
			local shiftX = active and 10 or 0 -- 658
			if active then -- 658
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 661
				drawSilkRibbon( -- 662
					uiDraw, -- 662
					uiArt, -- 662
					"title_rib_red_" .. tostring(i), -- 662
					menuX + 124, -- 662
					cy, -- 662
					290, -- 662
					btnH, -- 662
					PALETTE.rougeSoft, -- 662
					0.52 * breathe, -- 662
					0 -- 662
				) -- 662
				drawHairline( -- 663
					uiInkDraw, -- 663
					uiArt, -- 663
					"title_rib_line_" .. tostring(i), -- 663
					menuX + 114, -- 663
					by + 4, -- 663
					230, -- 663
					PALETTE.silkLine, -- 663
					0.42 * breathe, -- 663
					false, -- 663
					2 -- 663
				) -- 663
				drawBlossomDot( -- 664
					uiInkDraw, -- 664
					uiArt, -- 664
					"title_dot_" .. tostring(i), -- 664
					menuX + 14, -- 664
					cy, -- 664
					15, -- 664
					PALETTE.rouge, -- 664
					0.96, -- 664
					4 -- 664
				) -- 664
				fillRadialGlow( -- 665
					uiGlow, -- 665
					menuX + 14, -- 665
					cy, -- 665
					22, -- 665
					16, -- 665
					toColor(PALETTE.rouge, 28 * breathe), -- 665
					Color(182, 58, 56, 0), -- 665
					10 -- 665
				) -- 665
			else -- 665
				drawBlossomDot( -- 667
					uiInkDraw, -- 667
					uiArt, -- 667
					"title_dot_" .. tostring(i), -- 667
					menuX + 14, -- 667
					cy, -- 667
					8, -- 667
					PALETTE.silkDim, -- 667
					0.4, -- 667
					3 -- 667
				) -- 667
			end -- 667
			texts:put( -- 670
				veryDenseTitle and "sm" or "md", -- 671
				items[i + 1].zh, -- 672
				menuX + 34 + shiftX, -- 673
				cy, -- 674
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 675
				0, -- 676
				0.5, -- 677
				"Left", -- 678
				active and 4 or 2.6, -- 679
				active and 1 or 0.88, -- 680
				0.1 -- 681
			) -- 681
			if items[i + 1].id == "continue" and self.sessionLabel ~= "" then -- 681
				texts:put( -- 684
					"xs", -- 685
					"· " .. self.sessionLabel, -- 686
					menuX + 168 + shiftX, -- 687
					cy, -- 688
					toColor(active and PALETTE.amberCore or PALETTE.textDim), -- 689
					0, -- 690
					0.5, -- 691
					"Left", -- 692
					1.2, -- 693
					active and 0.92 or 0.72, -- 694
					0.08 -- 695
				) -- 695
			end -- 695
			i = i + 1 -- 654
		end -- 654
	end -- 654
	local titleHint = getActiveTarget():titleFooterHint(frame.mode, frame.layout) -- 700
	texts:put( -- 701
		"xs", -- 701
		titleHint, -- 701
		menuX + 12, -- 701
		34 + frame.safe.bottom * 0.45, -- 701
		toColor(PALETTE.textDim), -- 701
		0, -- 701
		0.5, -- 701
		"Left", -- 701
		1.4, -- 701
		0.88, -- 701
		0.08 -- 701
	) -- 701
	local badgeRight = w - frame.safe.right * 0.5 -- 704
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 705
	fillHGradRect( -- 706
		uiDraw, -- 706
		badgeRight - 270, -- 706
		0, -- 706
		270 + frame.safe.right * 0.5, -- 706
		86, -- 706
		Color(8, 10, 16, 0), -- 706
		Color(8, 10, 16, 204) -- 706
	) -- 706
	uiArt:tryPlace( -- 707
		"brand_team_badge", -- 707
		"title_team_badge", -- 707
		badgeRight - 118, -- 707
		badgeY, -- 707
		168, -- 707
		54, -- 707
		{opacity = 0.95, layer = 3} -- 707
	) -- 707
	if self.titleConfirmNewGame then -- 707
		local dlgRes = self:drawConfirmDialog( -- 712
			frame, -- 713
			uiDraw, -- 714
			uiInkDraw, -- 715
			uiArt, -- 716
			texts, -- 717
			w, -- 718
			h, -- 719
			"开启新旅程", -- 720
			"当前已有自动存档，开始新游戏将覆盖自动存档（手动槽位保留）。", -- 721
			"确认开始", -- 722
			"取消返回", -- 723
			self.titleConfirmSel, -- 724
			function(sel) -- 725
				self.titleConfirmSel = sel -- 726
			end -- 725
		) -- 725
		if dlgRes == "confirm" then -- 725
			self.titleConfirmNewGame = false -- 730
			self:emitSound("start") -- 731
			self:resetInput() -- 732
			return {type = "start"} -- 733
		end -- 733
		if dlgRes == "cancel" then -- 733
			self.titleConfirmNewGame = false -- 736
			self:emitSound("back") -- 737
			self:resetInput() -- 738
		end -- 738
		return {type = "none"} -- 740
	end -- 740
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 743
	if hit >= 0 or frame.keys.confirm then -- 743
		local idx = hit >= 0 and hit or self.selected -- 745
		local id = items[idx + 1].id -- 746
		if id == "continue" then -- 746
			self:emitSound("start") -- 747
			return {type = "continue"} -- 747
		end -- 747
		if id == "start" then -- 747
			if self.hasSession then -- 747
				self.titleConfirmNewGame = true -- 750
				self.titleConfirmSel = 1 -- 751
				self:emitSound("confirm") -- 752
				self:resetInput() -- 753
				return {type = "none"} -- 754
			end -- 754
			self:emitSound("start") -- 756
			return {type = "start"} -- 757
		end -- 757
		if id == "chapters" then -- 757
			self:emitSound("confirm") -- 759
			return {type = "openChapters"} -- 759
		end -- 759
		if id == "saves" then -- 759
			self:openSaves(false) -- 761
			self:emitSound("confirm") -- 762
			return {type = "openSaves"} -- 763
		end -- 763
		if id == "settings" then -- 763
			self:openSettings() -- 766
			self:emitSound("confirm") -- 767
			return {type = "openSettings"} -- 768
		end -- 768
		if id == "quit" then -- 768
			self:emitSound("back") -- 770
			return {type = "quit"} -- 770
		end -- 770
		self:emitSound("confirm") -- 771
		return {type = "openControls"} -- 772
	end -- 772
	return {type = "none"} -- 774
end -- 541
function MenuRenderer.prototype.drawConfirmDialog(self, frame, uiDraw, uiInkDraw, uiArt, texts, w, h, heading, message, confirmLabel, cancelLabel, selected, setSelected) -- 778
	if frame.back then -- 778
		return "cancel" -- 794
	end -- 794
	local dlgW = math.min(540, w - 120) -- 796
	local dlgH = 224 -- 797
	local dlgX = (w - dlgW) * 0.5 -- 798
	local dlgY = (h - dlgH) * 0.5 -- 799
	local btnW = 166 -- 800
	local btnH = 40 -- 801
	local btnGap = 28 -- 802
	local btnY = dlgY + 28 -- 803
	local btn0X = w * 0.5 - btnW - btnGap * 0.5 -- 804
	local btn1X = w * 0.5 + btnGap * 0.5 -- 805
	local boxes = { -- 806
		Rect(btn0X, btnY, btnW, btnH), -- 806
		Rect(btn1X, btnY, btnW, btnH) -- 806
	} -- 806
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 808
	local cur = selected -- 809
	if frame.click and hit >= 0 then -- 809
		cur = hit -- 811
	elseif frame.keys.left or frame.keys.up then -- 811
		cur = 0 -- 813
	elseif frame.keys.right or frame.keys.down then -- 813
		cur = 1 -- 815
	elseif frame.pointerMoved and hit >= 0 and not frame.keys.confirm then -- 815
		cur = hit -- 817
	end -- 817
	if cur ~= selected then -- 817
		setSelected(cur) -- 820
		self:emitSound("hover") -- 821
	end -- 821
	uiDraw:drawRect( -- 824
		Rect(0, 0, w, h), -- 824
		Color(6, 8, 14, 186) -- 824
	) -- 824
	uiDraw:drawRect( -- 825
		Rect(dlgX, dlgY, dlgW, dlgH), -- 825
		Color(14, 17, 26, 244) -- 825
	) -- 825
	drawFiligreeCorners( -- 826
		uiInkDraw, -- 826
		uiArt, -- 826
		"confirm_dlg_frame", -- 826
		dlgX, -- 826
		dlgY, -- 826
		dlgW, -- 826
		dlgH, -- 826
		PALETTE.silkLine, -- 826
		0.85, -- 826
		28, -- 826
		true, -- 826
		5 -- 826
	) -- 826
	texts:put( -- 827
		"lg", -- 827
		heading, -- 827
		w * 0.5, -- 827
		dlgY + dlgH - 44, -- 827
		toColor(PALETTE.textBright), -- 827
		0.5, -- 827
		0.5, -- 827
		"Center", -- 827
		3, -- 827
		0.98, -- 827
		0.1 -- 827
	) -- 827
	drawHairline( -- 828
		uiInkDraw, -- 828
		uiArt, -- 828
		"confirm_dlg_div", -- 828
		w * 0.5, -- 828
		dlgY + dlgH - 72, -- 828
		dlgW - 84, -- 828
		PALETTE.silkDim, -- 828
		0.56, -- 828
		true, -- 828
		4 -- 828
	) -- 828
	texts:put( -- 829
		"sm", -- 829
		message, -- 829
		w * 0.5, -- 829
		dlgY + dlgH - 110, -- 829
		toColor(PALETTE.textMid), -- 829
		0.5, -- 829
		0.5, -- 829
		"Center", -- 829
		0.8, -- 829
		0.94, -- 829
		0.08 -- 829
	) -- 829
	local labels = {confirmLabel, cancelLabel} -- 831
	local bi = 0 -- 832
	do -- 832
		bi = 0 -- 833
		while bi < 2 do -- 833
			local bx = boxes[bi + 1] -- 834
			local isSel = cur == bi -- 835
			local fillCol = isSel and (bi == 0 and toColor(PALETTE.rougeSoft, 185) or Color(32, 40, 56, 215)) or Color(18, 22, 32, 165) -- 836
			local borderCol = isSel and (bi == 0 and PALETTE.rouge or PALETTE.amberCore) or PALETTE.silkDim -- 839
			uiInkDraw:drawRect( -- 842
				bx, -- 842
				fillCol, -- 842
				1.1, -- 842
				toColor(borderCol, isSel and 235 or 145) -- 842
			) -- 842
			texts:put( -- 843
				"sm", -- 844
				labels[bi + 1], -- 845
				bx.x + bx.width * 0.5, -- 846
				bx.y + bx.height * 0.5, -- 847
				toColor(isSel and PALETTE.textBright or PALETTE.textMid), -- 848
				0.5, -- 849
				0.5, -- 850
				"Center", -- 851
				2, -- 852
				isSel and 1 or 0.84, -- 853
				0.08 -- 854
			) -- 854
			bi = bi + 1 -- 833
		end -- 833
	end -- 833
	if frame.click and hit >= 0 or frame.keys.confirm then -- 833
		return cur == 0 and "confirm" or "cancel" -- 859
	end -- 859
	return "none" -- 861
end -- 778
function MenuRenderer.prototype.drawSavesPanel(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, fromPause, canSave) -- 865
	local backAction = {type = fromPause and "backPause" or "backTitle"} -- 877
	if #self.saveSlots == 0 then -- 877
		self:refreshSaveSlots() -- 879
	end -- 879
	local slots = self.saveSlots -- 881
	if self.saveSelected >= #slots then -- 881
		self.saveSelected = 0 -- 883
	end -- 883
	if self.saveConfirmKind == "" and frame.back then -- 883
		self:emitSound("back") -- 887
		return backAction -- 888
	end -- 888
	uiDraw:drawRect( -- 891
		Rect(0, 0, w, h), -- 891
		Color(10, 12, 19, 208) -- 891
	) -- 891
	local marginX = math.max( -- 893
		96, -- 893
		56 + math.max(frame.safe.left, frame.safe.right) -- 893
	) -- 893
	local topHeadY = h - 58 - frame.safe.top * 0.35 -- 894
	texts:put( -- 895
		"lg", -- 895
		fromPause and "存取档案" or "读取存档", -- 895
		marginX, -- 895
		topHeadY, -- 895
		toColor(PALETTE.textBright), -- 895
		0, -- 895
		0.5, -- 895
		"Left", -- 895
		4, -- 895
		0.98, -- 895
		0.1 -- 895
	) -- 895
	local subDesc = fromPause and (canSave and "自动存档随进度更新 · 可存入或读取三处手动槽位" or "当前段落仅可读取或清理已有存档") or "便携目录 saves/ · 支持自动存档与三处独立槽位" -- 896
	texts:put( -- 899
		"xs", -- 899
		subDesc, -- 899
		marginX + 168, -- 899
		topHeadY - 2, -- 899
		toColor(PALETTE.amberCore), -- 899
		0, -- 899
		0.5, -- 899
		"Left", -- 899
		1.2, -- 899
		0.86, -- 899
		0.08 -- 899
	) -- 899
	drawHairline( -- 900
		uiInkDraw, -- 900
		uiArt, -- 900
		"saves_top_line", -- 900
		w * 0.5, -- 900
		topHeadY - 30, -- 900
		w - marginX * 2, -- 900
		PALETTE.silkDim, -- 900
		0.6, -- 900
		true, -- 900
		2 -- 900
	) -- 900
	local panelW = math.min(880, w - marginX * 2) -- 902
	local panelX = (w - panelW) * 0.5 -- 903
	local cardH = 92 -- 904
	local cardGap = 16 -- 905
	local firstTop = topHeadY - 58 -- 906
	local cardBoxes = {} -- 907
	local i = 0 -- 908
	do -- 908
		i = 0 -- 909
		while i < #slots do -- 909
			local cyBottom = firstTop - (i + 1) * cardH - i * cardGap -- 910
			cardBoxes[#cardBoxes + 1] = Rect(panelX, cyBottom, panelW, cardH) -- 911
			i = i + 1 -- 909
		end -- 909
	end -- 909
	local function actionsForSlot(slot) -- 914
		local acts = {} -- 915
		if fromPause and canSave and slot.id ~= "auto" then -- 915
			acts[#acts + 1] = {id = "save", zh = slot.exists and "覆盖保存" or "存入此档"} -- 917
		end -- 917
		if slot.exists then -- 917
			acts[#acts + 1] = {id = "load", zh = "读取"} -- 920
			acts[#acts + 1] = {id = "delete", zh = "删除"} -- 921
		end -- 921
		return acts -- 923
	end -- 914
	if self.saveConfirmKind == "" then -- 914
		local prevSel = self.saveSelected -- 927
		self.saveSelected = self:verticalSelection(self.saveSelected, cardBoxes, frame) -- 928
		if self.saveSelected ~= prevSel then -- 928
			self.saveActionSelected = 0 -- 930
			self:emitSound("hover") -- 931
		end -- 931
	end -- 931
	local function slotTitleOf(id) -- 935
		if id == "auto" then -- 935
			return "自动存档" -- 936
		end -- 936
		if id == 1 then -- 936
			return "档案一" -- 937
		end -- 937
		if id == 2 then -- 937
			return "档案二" -- 938
		end -- 938
		return "档案三" -- 939
	end -- 935
	local activeActionBoxes = {} -- 942
	local activeActions = {} -- 943
	do -- 943
		i = 0 -- 945
		while i < #slots do -- 945
			local slot = slots[i + 1] -- 946
			local box = cardBoxes[i + 1] -- 947
			local active = self.saveSelected == i and self.saveConfirmKind == "" -- 948
			local acts = actionsForSlot(slot) -- 949
			if self.saveSelected == i then -- 949
				activeActions = acts -- 951
				if self.saveActionSelected >= #acts then -- 951
					self.saveActionSelected = 0 -- 953
				end -- 953
			end -- 953
			local cardBg = active and Color(22, 26, 38, 224) or Color(13, 16, 24, 182) -- 957
			local cardBorder = active and PALETTE.rouge or PALETTE.silkDim -- 958
			uiInkDraw:drawRect( -- 959
				box, -- 959
				cardBg, -- 959
				active and 1.3 or 0.8, -- 959
				toColor(cardBorder, active and 225 or 120) -- 959
			) -- 959
			if active then -- 959
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 961
				drawSilkRibbon( -- 962
					uiDraw, -- 962
					uiArt, -- 962
					"save_rib_" .. tostring(i), -- 962
					panelX + panelW * 0.5, -- 962
					box.y + box.height * 0.5, -- 962
					panelW + 10, -- 962
					box.height - 6, -- 962
					PALETTE.rougeSoft, -- 962
					0.24 * breathe, -- 962
					0 -- 962
				) -- 962
				drawBlossomDot( -- 963
					uiInkDraw, -- 963
					uiArt, -- 963
					"save_dot_" .. tostring(i), -- 963
					box.x + 22, -- 963
					box.y + box.height - 28, -- 963
					13, -- 963
					PALETTE.rouge, -- 963
					0.96, -- 963
					4 -- 963
				) -- 963
				fillRadialGlow( -- 964
					uiGlow, -- 964
					box.x + 22, -- 964
					box.y + box.height - 28, -- 964
					18, -- 964
					14, -- 964
					toColor(PALETTE.rouge, 24 * breathe), -- 964
					Color(182, 58, 56, 0), -- 964
					10 -- 964
				) -- 964
			else -- 964
				drawBlossomDot( -- 966
					uiInkDraw, -- 966
					uiArt, -- 966
					"save_dot_" .. tostring(i), -- 966
					box.x + 22, -- 966
					box.y + box.height - 28, -- 966
					7, -- 966
					PALETTE.silkDim, -- 966
					0.48, -- 966
					3 -- 966
				) -- 966
			end -- 966
			local titleX = box.x + 44 -- 969
			local titleY = box.y + box.height - 28 -- 970
			texts:put( -- 971
				"md", -- 971
				slotTitleOf(slot.id), -- 971
				titleX, -- 971
				titleY, -- 971
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 971
				0, -- 971
				0.5, -- 971
				"Left", -- 971
				2.2, -- 971
				active and 1 or 0.88, -- 971
				0.08 -- 971
			) -- 971
			if slot.exists then -- 971
				local rt = themeOf(slot.roomKey) -- 974
				local routeZh = slot.route == "soldier" and "周戍线" or (slot.route == "child" and "小满线" or "序章") -- 975
				local chapTag = (rt.shortNameZh .. " · ") .. routeZh -- 976
				texts:put( -- 977
					"sm", -- 977
					chapTag, -- 977
					titleX + 118, -- 977
					titleY, -- 977
					toColor(slot.route == "soldier" and PALETTE.cyanCore or PALETTE.amberCore), -- 977
					0, -- 977
					0.5, -- 977
					"Left", -- 977
					1.4, -- 977
					0.94, -- 977
					0.08 -- 977
				) -- 977
				local parts = {} -- 979
				parts[#parts + 1] = (("血量 " .. tostring(slot.hp)) .. "/") .. tostring(slot.maxHp) -- 980
				local dur = formatPlayDuration(slot.playSeconds) -- 981
				if dur ~= "" then -- 981
					parts[#parts + 1] = "时长 " .. dur -- 983
				end -- 983
				local savedStr = formatSavedAt(slot.savedAt) -- 985
				if savedStr ~= "" then -- 985
					parts[#parts + 1] = "保存于 " .. savedStr -- 987
				end -- 987
				if slot.recovered then -- 987
					parts[#parts + 1] = "备份恢复" -- 990
				end -- 990
				texts:put( -- 992
					"xs", -- 992
					table.concat(parts, "   ·   "), -- 992
					titleX, -- 992
					box.y + 26, -- 992
					toColor(PALETTE.textDim), -- 992
					0, -- 992
					0.5, -- 992
					"Left", -- 992
					0.8, -- 992
					0.88, -- 992
					0.08 -- 992
				) -- 992
			elseif slot.status == "corrupt" or slot.status == "unsupported" then -- 992
				texts:put( -- 994
					"sm", -- 994
					slot.status == "corrupt" and "存档已损坏" or "版本不兼容", -- 994
					titleX + 118, -- 994
					titleY, -- 994
					toColor(PALETTE.rouge), -- 994
					0, -- 994
					0.5, -- 994
					"Left", -- 994
					1.4, -- 994
					0.94, -- 994
					0.08 -- 994
				) -- 994
				texts:put( -- 995
					"xs", -- 995
					"原件已隔离于 backups 目录，可覆盖保存或忽略", -- 995
					titleX, -- 995
					box.y + 26, -- 995
					toColor(PALETTE.textDim), -- 995
					0, -- 995
					0.5, -- 995
					"Left", -- 995
					0.8, -- 995
					0.82, -- 995
					0.08 -- 995
				) -- 995
			else -- 995
				texts:put( -- 997
					"sm", -- 997
					"空档", -- 997
					titleX + 118, -- 997
					titleY, -- 997
					toColor(PALETTE.textDim), -- 997
					0, -- 997
					0.5, -- 997
					"Left", -- 997
					1.4, -- 997
					0.72, -- 997
					0.08 -- 997
				) -- 997
				local emptyTip = slot.id == "auto" and "推进剧情、切房或暂停时自动记录" or (fromPause and canSave and "按回车或点击右侧「存入此档」保存当前进度" or "游玩中可在暂歇菜单手动保存") -- 998
				texts:put( -- 1001
					"xs", -- 1001
					emptyTip, -- 1001
					titleX, -- 1001
					box.y + 26, -- 1001
					toColor(PALETTE.textDim), -- 1001
					0, -- 1001
					0.5, -- 1001
					"Left", -- 1001
					0.8, -- 1001
					0.7, -- 1001
					0.08 -- 1001
				) -- 1001
			end -- 1001
			local btnW = 88 -- 1005
			local btnH = 30 -- 1006
			local btnGap = 8 -- 1007
			local totalActW = #acts > 0 and #acts * btnW + (#acts - 1) * btnGap or 0 -- 1008
			local actStartX = box.x + box.width - 18 - totalActW -- 1009
			local actY = box.y + (box.height - btnH) * 0.5 -- 1010
			local rowBtnBoxes = {} -- 1011
			local ai = 0 -- 1012
			do -- 1012
				ai = 0 -- 1013
				while ai < #acts do -- 1013
					local bx = Rect(actStartX + ai * (btnW + btnGap), actY, btnW, btnH) -- 1014
					rowBtnBoxes[#rowBtnBoxes + 1] = bx -- 1015
					local btnFocused = active and self.saveActionSelected == ai -- 1016
					local btnHover = self.saveConfirmKind == "" and frame.inside and bx:containsPoint(frame.pointer) -- 1017
					local highlight = btnFocused or btnHover -- 1018
					local isDel = acts[ai + 1].id == "delete" -- 1019
					local bg = highlight and (isDel and Color(118, 36, 36, 210) or toColor(PALETTE.rougeSoft, 195)) or Color(18, 22, 32, 168) -- 1020
					local bd = highlight and (isDel and PALETTE.rouge or PALETTE.amberCore) or PALETTE.silkDim -- 1023
					uiInkDraw:drawRect( -- 1026
						bx, -- 1026
						bg, -- 1026
						1, -- 1026
						toColor(bd, highlight and 235 or 135) -- 1026
					) -- 1026
					texts:put( -- 1027
						"xs", -- 1028
						acts[ai + 1].zh, -- 1029
						bx.x + bx.width * 0.5, -- 1030
						bx.y + bx.height * 0.5, -- 1031
						toColor(highlight and PALETTE.textBright or PALETTE.textMid), -- 1032
						0.5, -- 1033
						0.5, -- 1034
						"Center", -- 1035
						0.8, -- 1036
						highlight and 1 or 0.86, -- 1037
						0.08 -- 1038
					) -- 1038
					ai = ai + 1 -- 1013
				end -- 1013
			end -- 1013
			if self.saveSelected == i then -- 1013
				activeActionBoxes = rowBtnBoxes -- 1042
			end -- 1042
			i = i + 1 -- 945
		end -- 945
	end -- 945
	local backX = marginX -- 1046
	local backY = 38 + frame.safe.bottom * 0.45 -- 1047
	local backBox = Rect(backX - 6, backY - 6, 210, 44) -- 1048
	local backHover = self.saveConfirmKind == "" and frame.inside and backBox:containsPoint(frame.pointer) -- 1049
	drawSilkKeycap( -- 1050
		uiInkDraw, -- 1050
		texts, -- 1050
		backX, -- 1050
		backY + 4, -- 1050
		52, -- 1050
		24, -- 1050
		"ESC", -- 1050
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1050
		0.92, -- 1050
		backHover -- 1050
	) -- 1050
	texts:put( -- 1051
		"sm", -- 1051
		fromPause and "返回暂停" or "返回标题", -- 1051
		backX + 64, -- 1051
		backY + 16, -- 1051
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1051
		0, -- 1051
		0.5, -- 1051
		"Left", -- 1051
		1.8, -- 1051
		0.9, -- 1051
		0.08 -- 1051
	) -- 1051
	texts:put( -- 1052
		"xs", -- 1052
		"上下选槽位   ·   左右选动作   ·   回车或点击确认", -- 1052
		w - marginX, -- 1052
		backY + 16, -- 1052
		toColor(PALETTE.textDim), -- 1052
		1, -- 1052
		0.5, -- 1052
		"Right", -- 1052
		1.2, -- 1052
		0.78, -- 1052
		0.08 -- 1052
	) -- 1052
	if self.saveConfirmKind ~= "" then -- 1052
		local isDel = self.saveConfirmKind == "delete" -- 1055
		local dlgRes = self:drawConfirmDialog( -- 1056
			frame, -- 1057
			uiDraw, -- 1058
			uiInkDraw, -- 1059
			uiArt, -- 1060
			texts, -- 1061
			w, -- 1062
			h, -- 1063
			isDel and "删除存档" or "覆盖存档", -- 1064
			isDel and ("确定删除「" .. slotTitleOf(self.saveConfirmSlot)) .. "」？删除后无法恢复。" or ("确定覆盖「" .. slotTitleOf(self.saveConfirmSlot)) .. "」？原存档进度将被替换。", -- 1065
			isDel and "确认删除" or "确认覆盖", -- 1068
			"取消", -- 1069
			self.saveConfirmSel, -- 1070
			function(sel) -- 1071
				self.saveConfirmSel = sel -- 1072
			end -- 1071
		) -- 1071
		if dlgRes == "confirm" then -- 1071
			local kind = self.saveConfirmKind -- 1076
			local slotId = self.saveConfirmSlot -- 1077
			self.saveConfirmKind = "" -- 1078
			self:resetInput() -- 1079
			self:emitSound(kind == "delete" and "back" or "confirm") -- 1080
			return {type = kind == "delete" and "deleteSlot" or "saveSlot", slot = slotId} -- 1081
		end -- 1081
		if dlgRes == "cancel" then -- 1081
			self.saveConfirmKind = "" -- 1084
			self:emitSound("back") -- 1085
			self:resetInput() -- 1086
		end -- 1086
		return {type = "none"} -- 1088
	end -- 1088
	if frame.click and backHover then -- 1088
		self:emitSound("back") -- 1092
		return backAction -- 1093
	end -- 1093
	if #activeActions > 0 then -- 1093
		local hitAct = hitIndex(activeActionBoxes, frame.pointer, frame.inside) -- 1097
		if frame.pointerMoved and hitAct >= 0 and not frame.keys.confirm and hitAct ~= self.saveActionSelected then -- 1097
			self.saveActionSelected = hitAct -- 1099
			self:emitSound("hover") -- 1100
		end -- 1100
		if frame.keys.left then -- 1100
			self.saveActionSelected = (self.saveActionSelected + #activeActions - 1) % #activeActions -- 1103
			self:emitSound("hover") -- 1104
		elseif frame.keys.right then -- 1104
			self.saveActionSelected = (self.saveActionSelected + 1) % #activeActions -- 1106
			self:emitSound("hover") -- 1107
		end -- 1107
		local triggerIdx = -1 -- 1110
		if frame.click and hitAct >= 0 then -- 1110
			self.saveActionSelected = hitAct -- 1112
			triggerIdx = hitAct -- 1113
		elseif frame.keys.confirm then -- 1113
			triggerIdx = self.saveActionSelected -- 1115
		end -- 1115
		if triggerIdx >= 0 and triggerIdx < #activeActions then -- 1115
			local chosen = activeActions[triggerIdx + 1] -- 1119
			local slot = slots[self.saveSelected + 1] -- 1120
			if chosen.id == "load" then -- 1120
				self:emitSound("start") -- 1122
				self:resetInput() -- 1123
				return {type = "loadSlot", slot = slot.id} -- 1124
			end -- 1124
			if chosen.id == "save" then -- 1124
				if slot.exists then -- 1124
					self.saveConfirmKind = "overwrite" -- 1128
					self.saveConfirmSlot = slot.id -- 1129
					self.saveConfirmSel = 1 -- 1130
					self:emitSound("confirm") -- 1131
					self:resetInput() -- 1132
					return {type = "none"} -- 1133
				end -- 1133
				self:emitSound("confirm") -- 1135
				self:resetInput() -- 1136
				return {type = "saveSlot", slot = slot.id} -- 1137
			end -- 1137
			if chosen.id == "delete" then -- 1137
				self.saveConfirmKind = "delete" -- 1140
				self.saveConfirmSlot = slot.id -- 1141
				self.saveConfirmSel = 1 -- 1142
				self:emitSound("confirm") -- 1143
				self:resetInput() -- 1144
				return {type = "none"} -- 1145
			end -- 1145
		end -- 1145
	end -- 1145
	return {type = "none"} -- 1150
end -- 865
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1153
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 1163
	if frame.back then -- 1163
		self:emitSound("back") -- 1165
		return back -- 1166
	end -- 1166
	local extraH = math.max(0, h - 720) -- 1169
	local marginX = math.max( -- 1170
		96, -- 1170
		56 + math.max(frame.safe.left, frame.safe.right) -- 1170
	) -- 1170
	local splitTrack = #CHAPTERS > 8 -- 1171
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 1172
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 1173
	local rowGap = 68 -- 1174
	local trackX0 = marginX + 34 -- 1175
	local trackX1 = w - marginX - 34 -- 1176
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 1177
	local stationBoxes = {} -- 1179
	local s = 0 -- 1180
	do -- 1180
		s = 0 -- 1181
		while s < #CHAPTERS do -- 1181
			local sx = trackX0 + s % perRow * stepX -- 1182
			local sy = trackY - math.floor(s / perRow) * rowGap -- 1183
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 1184
			s = s + 1 -- 1181
		end -- 1181
	end -- 1181
	local prevSelected = self.chapterSelected -- 1187
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 1188
	local keys = frame.keys -- 1189
	if frame.click and hitStation >= 0 then -- 1189
		self.chapterSelected = hitStation -- 1191
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 1191
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 1193
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 1194
	elseif keys.down and self.chapterSelected < perRow then -- 1194
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 1196
	elseif keys.up and self.chapterSelected >= perRow then -- 1196
		self.chapterSelected = self.chapterSelected - perRow -- 1198
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 1198
		self.chapterSelected = hitStation -- 1200
	end -- 1200
	if self.chapterSelected ~= prevSelected then -- 1200
		self:emitSound("hover") -- 1203
	end -- 1203
	uiDraw:drawRect( -- 1206
		Rect(0, 0, w, h), -- 1206
		Color(10, 12, 19, 198) -- 1206
	) -- 1206
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 1208
	texts:put( -- 1209
		"banner", -- 1209
		"选择章节", -- 1209
		marginX, -- 1209
		topHeadY, -- 1209
		toColor(PALETTE.textBright), -- 1209
		0, -- 1209
		0.5, -- 1209
		"Left", -- 1209
		4.5, -- 1209
		0.96, -- 1209
		0.1 -- 1209
	) -- 1209
	drawHairline( -- 1210
		uiInkDraw, -- 1210
		uiArt, -- 1210
		"chap_top_line", -- 1210
		w * 0.5, -- 1210
		topHeadY - 34, -- 1210
		w - marginX * 2, -- 1210
		PALETTE.silkDim, -- 1210
		0.6, -- 1210
		true, -- 1210
		2 -- 1210
	) -- 1210
	local activeEntry = CHAPTERS[self.chapterSelected + 1] -- 1212
	local activeRoom = activeEntry.room -- 1213
	local theme = themeOf(activeRoom.key) -- 1214
	local activeTitleZh = activeEntry.titleOverride or theme.titleZh -- 1215
	local activeLineTag = activeEntry.lineTagOverride or theme.lineTag -- 1216
	local activeWhisper = activeEntry.whisperOverride or theme.introWhisper -- 1217
	local winX = marginX -- 1218
	local winY = 266 + extraH * 0.44 -- 1219
	local winW = math.min( -- 1220
		520, -- 1220
		math.max(360, (w - marginX * 2) * 0.46) -- 1220
	) -- 1220
	local winH = 296 -- 1221
	local winBox = Rect(winX, winY, winW, winH) -- 1222
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 1223
	uiArt:tryPlace( -- 1225
		"ink_frame_mask", -- 1225
		"chap_win_shadow", -- 1225
		winX + winW * 0.5, -- 1225
		winY + winH * 0.5, -- 1225
		winW + 40, -- 1225
		winH + 34, -- 1225
		{ -- 1225
			color = toColor(PALETTE.inkVoid), -- 1226
			opacity = 0.88, -- 1226
			layer = -2 -- 1226
		} -- 1226
	) -- 1226
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 1228
	uiArt:tryPlace( -- 1229
		bgSlot, -- 1229
		"chap_win_art", -- 1229
		winX + winW * 0.5, -- 1229
		winY + 4, -- 1229
		winW - 8, -- 1229
		winH - 8, -- 1229
		{opacity = 0.92, layer = -1} -- 1229
	) -- 1229
	fillVGradRect( -- 1232
		uiInkDraw, -- 1232
		winX, -- 1232
		winY, -- 1232
		winW, -- 1232
		56, -- 1232
		Color(10, 12, 19, 200), -- 1232
		Color(10, 12, 19, 0) -- 1232
	) -- 1232
	fillVGradRect( -- 1233
		uiInkDraw, -- 1233
		winX, -- 1233
		winY + winH - 36, -- 1233
		winW, -- 1233
		36, -- 1233
		Color(10, 12, 19, 0), -- 1233
		Color(10, 12, 19, 130) -- 1233
	) -- 1233
	fillHGradRect( -- 1234
		uiInkDraw, -- 1234
		winX, -- 1234
		winY, -- 1234
		34, -- 1234
		winH, -- 1234
		Color(10, 12, 19, 135), -- 1234
		Color(10, 12, 19, 0) -- 1234
	) -- 1234
	fillHGradRect( -- 1235
		uiInkDraw, -- 1235
		winX + winW - 34, -- 1235
		winY, -- 1235
		34, -- 1235
		winH, -- 1235
		Color(10, 12, 19, 0), -- 1235
		Color(10, 12, 19, 135) -- 1235
	) -- 1235
	drawFiligreeCorners( -- 1236
		uiInkDraw, -- 1236
		uiArt, -- 1236
		"chap_win_frame", -- 1236
		winX, -- 1236
		winY, -- 1236
		winW, -- 1236
		winH, -- 1236
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 1236
		winHover and 0.92 or 0.72, -- 1236
		34, -- 1236
		true, -- 1236
		3 -- 1236
	) -- 1236
	texts:put( -- 1238
		"xs", -- 1238
		(theme.actCode .. "  ·  ") .. activeLineTag, -- 1238
		winX + 20, -- 1238
		winY + 22, -- 1238
		toColor(PALETTE.textMid), -- 1238
		0, -- 1238
		0.5, -- 1238
		"Left", -- 1238
		1.8, -- 1238
		0.9, -- 1238
		0.08 -- 1238
	) -- 1238
	local infoX = winX + winW + 40 -- 1240
	local infoW = math.max(240, w - marginX - infoX) -- 1241
	local infoCenterY = winY + winH * 0.5 -- 1242
	drawMistCurve( -- 1243
		uiArt, -- 1243
		"chap_info_mist", -- 1243
		infoX + infoW * 0.5, -- 1243
		infoCenterY + 36, -- 1243
		math.min(420, infoW + 24), -- 1243
		88, -- 1243
		theme.accent, -- 1243
		0.22, -- 1243
		-1 -- 1243
	) -- 1243
	local volCol = activeLineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 1245
	texts:put( -- 1246
		"xs", -- 1246
		theme.volumeTagZh, -- 1246
		infoX, -- 1246
		winY + winH - 44, -- 1246
		toColor(volCol), -- 1246
		0, -- 1246
		0.5, -- 1246
		"Left", -- 1246
		2.8, -- 1246
		0.92, -- 1246
		0.08 -- 1246
	) -- 1246
	local sep = " · " -- 1248
	local sIdx = (string.find(activeTitleZh, sep, nil, true) or 0) - 1 -- 1249
	local titleY = winY + winH - 98 -- 1250
	if theme.backdropKey ~= nil then -- 1250
		texts:put( -- 1252
			"lg", -- 1252
			activeTitleZh, -- 1252
			infoX, -- 1252
			titleY, -- 1252
			toColor(PALETTE.textBright) -- 1252
		) -- 1252
	elseif sIdx > 0 then -- 1252
		local leftPart = __TS__StringSlice(activeTitleZh, 0, sIdx) -- 1254
		local rightPart = __TS__StringSlice(activeTitleZh, sIdx + #sep) -- 1255
		local lw = visualTextWidth(leftPart, 40) -- 1256
		texts:put( -- 1257
			"banner", -- 1257
			leftPart, -- 1257
			infoX, -- 1257
			titleY, -- 1257
			toColor(PALETTE.textBright), -- 1257
			0, -- 1257
			0.5, -- 1257
			"Left", -- 1257
			2, -- 1257
			1, -- 1257
			0.1 -- 1257
		) -- 1257
		drawBlossomDot( -- 1258
			uiInkDraw, -- 1258
			uiArt, -- 1258
			"chap_title_dot", -- 1258
			infoX + lw + 16, -- 1258
			titleY - 2, -- 1258
			11, -- 1258
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 1258
			0.9, -- 1258
			4 -- 1258
		) -- 1258
		texts:put( -- 1259
			"banner", -- 1259
			rightPart, -- 1259
			infoX + lw + 32, -- 1259
			titleY, -- 1259
			toColor(PALETTE.textBright), -- 1259
			0, -- 1259
			0.5, -- 1259
			"Left", -- 1259
			2, -- 1259
			1, -- 1259
			0.1 -- 1259
		) -- 1259
	else -- 1259
		texts:put( -- 1261
			"banner", -- 1261
			activeTitleZh, -- 1261
			infoX, -- 1261
			titleY, -- 1261
			toColor(PALETTE.textBright), -- 1261
			0, -- 1261
			0.5, -- 1261
			"Left", -- 1261
			2.4, -- 1261
			1, -- 1261
			0.1 -- 1261
		) -- 1261
	end -- 1261
	drawHairline( -- 1264
		uiInkDraw, -- 1264
		uiArt, -- 1264
		"chap_info_line", -- 1264
		infoX + math.min(185, infoW * 0.5), -- 1264
		titleY - 36, -- 1264
		math.min(370, infoW), -- 1264
		PALETTE.silkDim, -- 1264
		0.58, -- 1264
		false, -- 1264
		2 -- 1264
	) -- 1264
	texts:put( -- 1265
		"sm", -- 1265
		activeWhisper, -- 1265
		infoX, -- 1265
		titleY - 72, -- 1265
		toColor(PALETTE.textMid), -- 1265
		0, -- 1265
		0.5, -- 1265
		"Left", -- 1265
		0.8, -- 1265
		0.94, -- 1265
		0.08 -- 1265
	) -- 1265
	local goX = infoX -- 1267
	local goY = winY + 26 -- 1268
	local goW = 220 -- 1269
	local goH = 42 -- 1270
	local goBox = Rect(goX, goY, goW, goH) -- 1271
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 1272
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1273
	drawSilkRibbon( -- 1274
		uiDraw, -- 1274
		uiArt, -- 1274
		"chap_go_rib", -- 1274
		goX + 106, -- 1274
		goY + 21, -- 1274
		250, -- 1274
		40, -- 1274
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 1274
		(goHover and 0.68 or 0.46) * breathe, -- 1274
		0 -- 1274
	) -- 1274
	drawHairline( -- 1275
		uiInkDraw, -- 1275
		uiArt, -- 1275
		"chap_go_line", -- 1275
		goX + 94, -- 1275
		goY + 3, -- 1275
		196, -- 1275
		PALETTE.silkLine, -- 1275
		goHover and 0.68 or 0.4, -- 1275
		false, -- 1275
		2 -- 1275
	) -- 1275
	drawBlossomDot( -- 1276
		uiInkDraw, -- 1276
		uiArt, -- 1276
		"chap_go_dot", -- 1276
		goX + 14, -- 1276
		goY + 21, -- 1276
		14, -- 1276
		PALETTE.rouge, -- 1276
		0.96, -- 1276
		4 -- 1276
	) -- 1276
	texts:put( -- 1277
		"md", -- 1277
		"入此卷章", -- 1277
		goX + 34, -- 1277
		goY + 21, -- 1277
		toColor(PALETTE.textBright), -- 1277
		0, -- 1277
		0.5, -- 1277
		"Left", -- 1277
		3.8, -- 1277
		1, -- 1277
		0.1 -- 1277
	) -- 1277
	local chapConfirmTag = getActiveTarget():keyTagFor("confirm", frame.mode, frame.layout) -- 1278
	texts:put( -- 1279
		"xs", -- 1279
		chapConfirmTag, -- 1279
		goX + 156, -- 1279
		goY + 21, -- 1279
		toColor(PALETTE.textDim), -- 1279
		0, -- 1279
		0.5, -- 1279
		"Left", -- 1279
		1, -- 1279
		0.82, -- 1279
		0.08 -- 1279
	) -- 1279
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 1281
	local veilH = splitTrack and 156 or 126 -- 1282
	drawSilkVeil( -- 1283
		uiDraw, -- 1283
		uiArt, -- 1283
		"chap_track_veil", -- 1283
		w * 0.5, -- 1283
		veilCenterY, -- 1283
		w - marginX * 1.1, -- 1283
		veilH, -- 1283
		PALETTE.inkWash, -- 1283
		0.72, -- 1283
		-2 -- 1283
	) -- 1283
	drawMistCurve( -- 1284
		uiArt, -- 1284
		"chap_track_mist", -- 1284
		w * 0.5, -- 1284
		trackY, -- 1284
		trackX1 - trackX0 + 160, -- 1284
		74, -- 1284
		PALETTE.inkMist, -- 1284
		0.62, -- 1284
		-1 -- 1284
	) -- 1284
	uiInkDraw:drawSegment( -- 1285
		Vec2(trackX0, trackY), -- 1285
		Vec2(trackX1, trackY), -- 1285
		0.9, -- 1285
		toColor(PALETTE.silkDim, 145) -- 1285
	) -- 1285
	if splitTrack then -- 1285
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 1288
		uiInkDraw:drawSegment( -- 1289
			Vec2(trackX0, trackY - rowGap), -- 1289
			Vec2(lastX, trackY - rowGap), -- 1289
			0.9, -- 1289
			toColor(PALETTE.silkDim, 145) -- 1289
		) -- 1289
	else -- 1289
		local midDivX = trackX0 + stepX * 3.5 -- 1291
		uiInkDraw:drawSegment( -- 1292
			Vec2(midDivX, trackY - 12), -- 1292
			Vec2(midDivX, trackY + 12), -- 1292
			0.8, -- 1292
			toColor(PALETTE.silkDim, 120) -- 1292
		) -- 1292
		texts:put( -- 1293
			"xs", -- 1293
			"上卷 · 孤城护童", -- 1293
			trackX0 + stepX * 1.5, -- 1293
			trackY + 52, -- 1293
			toColor(PALETTE.cyan), -- 1293
			0.5, -- 1293
			0.5, -- 1293
			"Center", -- 1293
			2.2, -- 1293
			0.88, -- 1293
			0.08 -- 1293
		) -- 1293
		texts:put( -- 1294
			"xs", -- 1294
			"下卷 · 独赴北塔", -- 1294
			trackX0 + stepX * 5.5, -- 1294
			trackY + 52, -- 1294
			toColor(PALETTE.amber), -- 1294
			0.5, -- 1294
			0.5, -- 1294
			"Center", -- 1294
			2.2, -- 1294
			0.88, -- 1294
			0.08 -- 1294
		) -- 1294
	end -- 1294
	local i = 0 -- 1297
	do -- 1297
		i = 0 -- 1298
		while i < #CHAPTERS do -- 1298
			local box = stationBoxes[i + 1] -- 1299
			local sx = box.x + box.width * 0.5 -- 1300
			local sy = box.y + box.height * 0.5 -- 1301
			local entry = CHAPTERS[i + 1] -- 1302
			local rt = themeOf(entry.room.key) -- 1303
			local entryLineTag = entry.lineTagOverride or rt.lineTag -- 1304
			local entryShortName = entry.shortNameOverride or rt.shortNameZh -- 1305
			local active = self.chapterSelected == i -- 1306
			local nodeCol = active and PALETTE.rouge or (entryLineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 1307
			if active then -- 1307
				fillRadialGlow( -- 1310
					uiGlow, -- 1310
					sx, -- 1310
					sy, -- 1310
					26, -- 1310
					26, -- 1310
					toColor(PALETTE.rouge, 36 * breathe), -- 1310
					Color(182, 58, 56, 0), -- 1310
					12 -- 1310
				) -- 1310
				uiArt:tryPlace( -- 1311
					"ink_enso_fine", -- 1311
					"chap_st_ring_" .. tostring(i), -- 1311
					sx, -- 1311
					sy, -- 1311
					32, -- 1311
					32, -- 1311
					{ -- 1311
						color = toColor(PALETTE.silkLine), -- 1312
						opacity = 0.78, -- 1312
						angle = self.time * 18, -- 1312
						layer = 3 -- 1312
					} -- 1312
				) -- 1312
				drawBlossomDot( -- 1314
					uiInkDraw, -- 1314
					uiArt, -- 1314
					"chap_st_dot_" .. tostring(i), -- 1314
					sx, -- 1314
					sy, -- 1314
					17, -- 1314
					PALETTE.rouge, -- 1314
					0.98, -- 1314
					4 -- 1314
				) -- 1314
			else -- 1314
				uiArt:tryPlace( -- 1316
					"ink_enso_fine", -- 1316
					"chap_st_ring_" .. tostring(i), -- 1316
					sx, -- 1316
					sy, -- 1316
					16, -- 1316
					16, -- 1316
					{ -- 1316
						color = toColor(nodeCol), -- 1317
						opacity = 0.62, -- 1317
						layer = 3 -- 1317
					} -- 1317
				) -- 1317
				drawBlossomDot( -- 1319
					uiInkDraw, -- 1319
					uiArt, -- 1319
					"chap_st_dot_" .. tostring(i), -- 1319
					sx, -- 1319
					sy, -- 1319
					7, -- 1319
					PALETTE.silkLine, -- 1319
					0.72, -- 1319
					4 -- 1319
				) -- 1319
			end -- 1319
			if not splitTrack then -- 1319
				texts:put( -- 1323
					"xs", -- 1323
					rt.numeralZh, -- 1323
					sx, -- 1323
					sy + 25, -- 1323
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 1323
					0.5, -- 1323
					0.5, -- 1323
					"Center", -- 1323
					0, -- 1323
					active and 1 or 0.88, -- 1323
					0.08 -- 1323
				) -- 1323
			end -- 1323
			texts:put( -- 1325
				"xs", -- 1325
				entryShortName, -- 1325
				sx, -- 1325
				sy - 26, -- 1325
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1325
				0.5, -- 1325
				0.5, -- 1325
				"Center", -- 1325
				1, -- 1325
				active and 1 or 0.84, -- 1325
				0.08 -- 1325
			) -- 1325
			i = i + 1 -- 1298
		end -- 1298
	end -- 1298
	local backX = marginX -- 1328
	local backY = 40 + frame.safe.bottom * 0.45 -- 1329
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 1330
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 1331
	local chapBackTag = getActiveTarget():keyTagFor("back", frame.mode, frame.layout) -- 1332
	local chapFooter = getActiveTarget():chapterFooterHint(frame.mode, chapConfirmTag) -- 1333
	drawSilkKeycap( -- 1334
		uiInkDraw, -- 1334
		texts, -- 1334
		backX, -- 1334
		backY + 5, -- 1334
		48, -- 1334
		24, -- 1334
		chapBackTag, -- 1334
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1334
		0.92, -- 1334
		backHover -- 1334
	) -- 1334
	texts:put( -- 1335
		"sm", -- 1335
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 1335
		backX + 60, -- 1335
		backY + 17, -- 1335
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1335
		0, -- 1335
		0.5, -- 1335
		"Left", -- 1335
		1.8, -- 1335
		0.9, -- 1335
		0.08 -- 1335
	) -- 1335
	texts:put( -- 1336
		"xs", -- 1336
		chapFooter, -- 1336
		w - marginX, -- 1336
		backY + 17, -- 1336
		toColor(PALETTE.textDim), -- 1336
		1, -- 1336
		0.5, -- 1336
		"Right", -- 1336
		1.2, -- 1336
		0.75, -- 1336
		0.08 -- 1336
	) -- 1336
	if frame.click and backHover then -- 1336
		self:emitSound("back") -- 1339
		return back -- 1340
	end -- 1340
	local ____temp_2 -- 1343
	if frame.mode == "touch" then -- 1343
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 1344
	else -- 1344
		____temp_2 = hitStation >= 0 -- 1345
	end -- 1345
	local stationConfirmed = ____temp_2 -- 1343
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 1343
		self:emitSound("start") -- 1347
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex, route = CHAPTERS[self.chapterSelected + 1].route} -- 1348
	end -- 1348
	return {type = "none"} -- 1354
end -- 1153
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 1358
	if backLabel == nil then -- 1358
		backLabel = "返回标题" -- 1367
	end -- 1367
	local target = getActiveTarget() -- 1369
	local tabs = target.controlsGuideTabs -- 1370
	local hasMultipleTabs = #tabs > 1 -- 1371
	if not self.controlsTabManual or __TS__ArrayFindIndex( -- 1371
		tabs, -- 1372
		function(____, t) return t.mode == self.controlsTab end -- 1372
	) < 0 then -- 1372
		self.controlsTab = __TS__ArrayFindIndex( -- 1373
			tabs, -- 1373
			function(____, t) return t.mode == frame.mode end -- 1373
		) >= 0 and frame.mode or tabs[1].mode -- 1373
	end -- 1373
	local marginX = math.max( -- 1375
		96, -- 1375
		56 + math.max(frame.safe.left, frame.safe.right) -- 1375
	) -- 1375
	local tabW = 92 -- 1376
	local tabH = 28 -- 1377
	local tabGap = 10 -- 1378
	local tabBoxes = {} -- 1379
	local hitTab = -1 -- 1380
	if hasMultipleTabs then -- 1380
		local tabStartX = w - marginX - (tabW * #tabs + tabGap * (#tabs - 1)) -- 1382
		local tabY = h - 82 - frame.safe.top * 0.35 -- 1383
		local k = 0 -- 1384
		do -- 1384
			k = 0 -- 1385
			while k < #tabs do -- 1385
				tabBoxes[#tabBoxes + 1] = Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH) -- 1386
				k = k + 1 -- 1385
			end -- 1385
		end -- 1385
		hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 1388
		if frame.click and hitTab >= 0 then -- 1388
			if self.controlsTab ~= tabs[hitTab + 1].mode then -- 1388
				self:emitSound("toggle") -- 1391
			end -- 1391
			self.controlsTab = tabs[hitTab + 1].mode -- 1393
			self.controlsTabManual = true -- 1394
		elseif frame.keys.left or frame.prevTab then -- 1394
			local cur = __TS__ArrayFindIndex( -- 1396
				tabs, -- 1396
				function(____, t) return t.mode == self.controlsTab end -- 1396
			) -- 1396
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + #tabs - 1) % #tabs + 1].mode -- 1397
			self.controlsTabManual = true -- 1398
			self:emitSound("toggle") -- 1399
		elseif frame.keys.right or frame.nextTab then -- 1399
			local cur = __TS__ArrayFindIndex( -- 1401
				tabs, -- 1401
				function(____, t) return t.mode == self.controlsTab end -- 1401
			) -- 1401
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + 1) % #tabs + 1].mode -- 1402
			self.controlsTabManual = true -- 1403
			self:emitSound("toggle") -- 1404
		end -- 1404
	end -- 1404
	local backX = marginX -- 1408
	local backY = 40 + frame.safe.bottom * 0.45 -- 1409
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 1410
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 1411
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 1411
		self:emitSound("back") -- 1413
		return {type = "backTitle"} -- 1414
	end -- 1414
	uiDraw:drawRect( -- 1416
		Rect(0, 0, w, h), -- 1416
		Color(10, 12, 19, 204) -- 1416
	) -- 1416
	local guide = target:controlsGuideRows(self.controlsTab) -- 1418
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 1419
	texts:put( -- 1420
		"banner", -- 1420
		"执器要诀", -- 1420
		marginX, -- 1420
		topHeadY, -- 1420
		toColor(PALETTE.textBright), -- 1420
		0, -- 1420
		0.5, -- 1420
		"Left", -- 1420
		4.5, -- 1420
		0.96, -- 1420
		0.1 -- 1420
	) -- 1420
	texts:put( -- 1421
		"xs", -- 1421
		guide.subtitle, -- 1421
		marginX + 196, -- 1421
		topHeadY - 4, -- 1421
		toColor(PALETTE.textDim), -- 1421
		0, -- 1421
		0.5, -- 1421
		"Left", -- 1421
		1.8, -- 1421
		0.85, -- 1421
		0.08 -- 1421
	) -- 1421
	drawHairline( -- 1422
		uiInkDraw, -- 1422
		uiArt, -- 1422
		"ctrl_top_line", -- 1422
		w * 0.5, -- 1422
		topHeadY - 34, -- 1422
		w - marginX * 2, -- 1422
		PALETTE.silkDim, -- 1422
		0.6, -- 1422
		true, -- 1422
		2 -- 1422
	) -- 1422
	if hasMultipleTabs then -- 1422
		local ti = 0 -- 1425
		do -- 1425
			ti = 0 -- 1426
			while ti < #tabBoxes do -- 1426
				local tb = tabBoxes[ti + 1] -- 1427
				local activeTab = self.controlsTab == tabs[ti + 1].mode -- 1428
				local hoverTab = hitTab == ti -- 1429
				uiInkDraw:drawRect( -- 1430
					tb, -- 1431
					activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 1432
					0.9, -- 1433
					toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 1434
				) -- 1434
				texts:put( -- 1436
					"xs", -- 1437
					tabs[ti + 1].label, -- 1438
					tb.x + tb.width * 0.5, -- 1439
					tb.y + tb.height * 0.5, -- 1440
					toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 1441
					0.5, -- 1442
					0.5, -- 1443
					"Center", -- 1444
					0.8, -- 1445
					activeTab and 0.98 or 0.82, -- 1446
					0.08 -- 1447
				) -- 1447
				ti = ti + 1 -- 1426
			end -- 1426
		end -- 1426
	end -- 1426
	local extraH = math.max(0, h - 720) -- 1452
	local areaY = 114 + frame.safe.bottom * 0.4 -- 1453
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 1454
	drawFiligreeCorners( -- 1455
		uiInkDraw, -- 1455
		uiArt, -- 1455
		"ctrl_outer", -- 1455
		marginX, -- 1455
		areaY, -- 1455
		w - marginX * 2, -- 1455
		areaH, -- 1455
		PALETTE.silkDim, -- 1455
		0.52, -- 1455
		34, -- 1455
		false, -- 1455
		2 -- 1455
	) -- 1455
	local midX = w * 0.5 -- 1457
	uiArt:tryPlace( -- 1458
		"ink_vstream", -- 1458
		"ctrl_mid_stream", -- 1458
		midX, -- 1458
		areaY + areaH * 0.5, -- 1458
		32, -- 1458
		areaH - 18, -- 1458
		{ -- 1458
			color = toColor(PALETTE.silkDim), -- 1459
			opacity = 0.52, -- 1459
			layer = 1 -- 1459
		} -- 1459
	) -- 1459
	drawBlossomDot( -- 1461
		uiInkDraw, -- 1461
		uiArt, -- 1461
		"ctrl_mid_dot", -- 1461
		midX, -- 1461
		areaY + areaH * 0.5, -- 1461
		11, -- 1461
		PALETTE.silkLine, -- 1461
		0.62, -- 1461
		3 -- 1461
	) -- 1461
	local leftColX = marginX + 34 -- 1463
	local colW = midX - leftColX - 42 -- 1464
	local headY = areaY + areaH - 34 -- 1465
	local rowStep = 52 + extraH * 0.08 -- 1466
	drawBlossomDot( -- 1468
		uiInkDraw, -- 1468
		uiArt, -- 1468
		"ctrl_l_dot", -- 1468
		leftColX + 8, -- 1468
		headY, -- 1468
		12, -- 1468
		PALETTE.cyan, -- 1468
		0.88, -- 1468
		3 -- 1468
	) -- 1468
	texts:put( -- 1469
		"md", -- 1469
		"周戍 · 护送与交锋", -- 1469
		leftColX + 26, -- 1469
		headY, -- 1469
		toColor(PALETTE.cyanCore), -- 1469
		0, -- 1469
		0.5, -- 1469
		"Left", -- 1469
		2.4, -- 1469
		0.98, -- 1469
		0.08 -- 1469
	) -- 1469
	drawHairline( -- 1470
		uiInkDraw, -- 1470
		uiArt, -- 1470
		"ctrl_l_line", -- 1470
		leftColX + colW * 0.5, -- 1470
		headY - 24, -- 1470
		colW, -- 1470
		PALETTE.cyanDim, -- 1470
		0.58, -- 1470
		false, -- 1470
		2 -- 1470
	) -- 1470
	local i = 0 -- 1472
	local keycapW = 160 -- 1473
	do -- 1473
		i = 0 -- 1474
		while i < #guide.soldierRows do -- 1474
			local ry = headY - 66 - i * rowStep -- 1475
			drawSilkKeycap( -- 1476
				uiInkDraw, -- 1476
				texts, -- 1476
				leftColX + 2, -- 1476
				ry - 13, -- 1476
				keycapW, -- 1476
				26, -- 1476
				guide.soldierRows[i + 1][1], -- 1476
				PALETTE.cyan, -- 1476
				0.92, -- 1476
				false -- 1476
			) -- 1476
			texts:put( -- 1477
				"sm", -- 1477
				guide.soldierRows[i + 1][2], -- 1477
				leftColX + keycapW + 16, -- 1477
				ry, -- 1477
				toColor(PALETTE.textBright), -- 1477
				0, -- 1477
				0.5, -- 1477
				"Left", -- 1477
				0.8, -- 1477
				0.92, -- 1477
				0.08 -- 1477
			) -- 1477
			i = i + 1 -- 1474
		end -- 1474
	end -- 1474
	local rightColX = midX + 44 -- 1480
	drawBlossomDot( -- 1481
		uiInkDraw, -- 1481
		uiArt, -- 1481
		"ctrl_r_dot", -- 1481
		rightColX + 8, -- 1481
		headY, -- 1481
		12, -- 1481
		PALETTE.amber, -- 1481
		0.88, -- 1481
		3 -- 1481
	) -- 1481
	texts:put( -- 1482
		"md", -- 1482
		"小满 · 潜行与寻路", -- 1482
		rightColX + 26, -- 1482
		headY, -- 1482
		toColor(PALETTE.amberCore), -- 1482
		0, -- 1482
		0.5, -- 1482
		"Left", -- 1482
		2.4, -- 1482
		0.98, -- 1482
		0.08 -- 1482
	) -- 1482
	drawHairline( -- 1483
		uiInkDraw, -- 1483
		uiArt, -- 1483
		"ctrl_r_line", -- 1483
		rightColX + colW * 0.5, -- 1483
		headY - 24, -- 1483
		colW, -- 1483
		PALETTE.amberDim, -- 1483
		0.58, -- 1483
		false, -- 1483
		2 -- 1483
	) -- 1483
	do -- 1483
		i = 0 -- 1485
		while i < #guide.childRows do -- 1485
			local ry = headY - 66 - i * rowStep -- 1486
			drawSilkKeycap( -- 1487
				uiInkDraw, -- 1487
				texts, -- 1487
				rightColX + 2, -- 1487
				ry - 13, -- 1487
				keycapW, -- 1487
				26, -- 1487
				guide.childRows[i + 1][1], -- 1487
				PALETTE.amber, -- 1487
				0.92, -- 1487
				false -- 1487
			) -- 1487
			texts:put( -- 1488
				"sm", -- 1488
				guide.childRows[i + 1][2], -- 1488
				rightColX + keycapW + 16, -- 1488
				ry, -- 1488
				toColor(PALETTE.textBright), -- 1488
				0, -- 1488
				0.5, -- 1488
				"Left", -- 1488
				0.8, -- 1488
				0.92, -- 1488
				0.08 -- 1488
			) -- 1488
			i = i + 1 -- 1485
		end -- 1485
	end -- 1485
	local ctrlBackKey = frame.mode == "gamepad" and (target:keyTagFor("back", "gamepad", frame.layout) .. " / ") .. target:keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 1491
	local ctrlRightHint = target:controlsFooterRightHint(frame.mode) -- 1494
	local keyW = frame.mode == "touch" and 76 or 110 -- 1495
	drawSilkKeycap( -- 1496
		uiInkDraw, -- 1496
		texts, -- 1496
		backX, -- 1496
		backY + 5, -- 1496
		keyW, -- 1496
		24, -- 1496
		ctrlBackKey, -- 1496
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1496
		0.92, -- 1496
		backHover -- 1496
	) -- 1496
	texts:put( -- 1497
		"sm", -- 1497
		backLabel, -- 1497
		backX + keyW + 12, -- 1497
		backY + 17, -- 1497
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1497
		0, -- 1497
		0.5, -- 1497
		"Left", -- 1497
		1.8, -- 1497
		0.92, -- 1497
		0.08 -- 1497
	) -- 1497
	texts:put( -- 1498
		"xs", -- 1498
		ctrlRightHint, -- 1498
		w - marginX, -- 1498
		backY + 17, -- 1498
		toColor(PALETTE.textDim), -- 1498
		1, -- 1498
		0.5, -- 1498
		"Right", -- 1498
		1.2, -- 1498
		0.78, -- 1498
		0.08 -- 1498
	) -- 1498
	return {type = "none"} -- 1500
end -- 1358
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1504
	if frame.back then -- 1504
		self:emitSound("back") -- 1516
		return true -- 1517
	end -- 1517
	local target = getActiveTarget() -- 1520
	local rows = target:settingsRows() -- 1521
	local s = input.settings -- 1522
	if self.settingsSelected >= #rows then -- 1522
		self.settingsSelected = 0 -- 1524
	end -- 1524
	uiDraw:drawRect( -- 1527
		Rect(0, 0, w, h), -- 1527
		Color(10, 12, 19, 206) -- 1527
	) -- 1527
	local marginX = math.max( -- 1529
		96, -- 1529
		56 + math.max(frame.safe.left, frame.safe.right) -- 1529
	) -- 1529
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1530
	texts:put( -- 1531
		"banner", -- 1531
		target:settingsHeaderTitle(), -- 1531
		marginX, -- 1531
		topHeadY, -- 1531
		toColor(PALETTE.textBright), -- 1531
		0, -- 1531
		0.5, -- 1531
		"Left", -- 1531
		4, -- 1531
		0.96, -- 1531
		0.1 -- 1531
	) -- 1531
	local curSummary = target:settingsHeaderSummary(input.inputMode) -- 1532
	texts:put( -- 1533
		"xs", -- 1533
		curSummary, -- 1533
		marginX + 224, -- 1533
		topHeadY - 4, -- 1533
		toColor(PALETTE.amberCore), -- 1533
		0, -- 1533
		0.5, -- 1533
		"Left", -- 1533
		1.4, -- 1533
		0.88, -- 1533
		0.08 -- 1533
	) -- 1533
	drawHairline( -- 1534
		uiInkDraw, -- 1534
		uiArt, -- 1534
		"set_top_line", -- 1534
		w * 0.5, -- 1534
		topHeadY - 30, -- 1534
		w - marginX * 2, -- 1534
		PALETTE.silkDim, -- 1534
		0.6, -- 1534
		true, -- 1534
		2 -- 1534
	) -- 1534
	local panelW = math.min(760, w - marginX * 2) -- 1536
	local panelX = (w - panelW) * 0.5 -- 1537
	local rowH = 34 -- 1538
	local rowStep = #rows <= 6 and 48 or 39 -- 1539
	local firstY = topHeadY - 76 -- 1540
	local boxes = {} -- 1542
	local i = 0 -- 1543
	do -- 1543
		i = 0 -- 1544
		while i < #rows do -- 1544
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1545
			i = i + 1 -- 1544
		end -- 1544
	end -- 1544
	local prevSetSel = self.settingsSelected -- 1547
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1548
	if self.settingsSelected ~= prevSetSel then -- 1548
		self:emitSound("hover") -- 1550
	end -- 1550
	local function applyDelta(rowId, delta) -- 1553
		local res = target:applySettingsDelta(rowId, delta, s, input) -- 1554
		if res == "back" then -- 1554
			self:emitSound("back") -- 1556
			return true -- 1557
		end -- 1557
		if res == "audio" and self.onAudioSettingsChanged ~= nil then -- 1557
			self:onAudioSettingsChanged(input) -- 1560
		end -- 1560
		if res == "assist" and self.onAssistSettingsChanged ~= nil then -- 1560
			self:onAssistSettingsChanged(input) -- 1563
		end -- 1563
		if res == "display" then -- 1563
			if self.onToggleFullscreen ~= nil then -- 1563
				self:onToggleFullscreen() -- 1567
			elseif canToggleFullscreen() then -- 1567
				do -- 1567
					pcall(function() -- 1567
						App.fullScreen = not App.fullScreen -- 1570
					end) -- 1570
				end -- 1570
			end -- 1570
		end -- 1570
		if res ~= "none" then -- 1570
			self:emitSound("toggle") -- 1577
		end -- 1577
		return false -- 1579
	end -- 1553
	do -- 1553
		i = 0 -- 1582
		while i < #rows do -- 1582
			local row = rows[i + 1] -- 1583
			local box = boxes[i + 1] -- 1584
			local cy = box.y + box.height * 0.5 -- 1585
			local active = self.settingsSelected == i -- 1586
			if active then -- 1586
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1589
				drawSilkRibbon( -- 1590
					uiDraw, -- 1590
					uiArt, -- 1590
					"set_rib_" .. tostring(i), -- 1590
					panelX + panelW * 0.5, -- 1590
					cy, -- 1590
					panelW + 24, -- 1590
					rowH, -- 1590
					PALETTE.rougeSoft, -- 1590
					0.48 * breathe, -- 1590
					0 -- 1590
				) -- 1590
				drawHairline( -- 1591
					uiInkDraw, -- 1591
					uiArt, -- 1591
					"set_line_" .. tostring(i), -- 1591
					panelX + panelW * 0.5, -- 1591
					box.y + 3, -- 1591
					panelW - 24, -- 1591
					PALETTE.silkLine, -- 1591
					0.42 * breathe, -- 1591
					false, -- 1591
					2 -- 1591
				) -- 1591
				drawBlossomDot( -- 1592
					uiInkDraw, -- 1592
					uiArt, -- 1592
					"set_dot_" .. tostring(i), -- 1592
					panelX + 18, -- 1592
					cy, -- 1592
					14, -- 1592
					PALETTE.rouge, -- 1592
					0.96, -- 1592
					4 -- 1592
				) -- 1592
				fillRadialGlow( -- 1593
					uiGlow, -- 1593
					panelX + 18, -- 1593
					cy, -- 1593
					20, -- 1593
					14, -- 1593
					toColor(PALETTE.rouge, 24 * breathe), -- 1593
					Color(182, 58, 56, 0), -- 1593
					10 -- 1593
				) -- 1593
			else -- 1593
				drawBlossomDot( -- 1595
					uiInkDraw, -- 1595
					uiArt, -- 1595
					"set_dot_" .. tostring(i), -- 1595
					panelX + 18, -- 1595
					cy, -- 1595
					7, -- 1595
					PALETTE.silkDim, -- 1595
					0.42, -- 1595
					3 -- 1595
				) -- 1595
			end -- 1595
			texts:put( -- 1598
				"sm", -- 1599
				row.title, -- 1600
				panelX + 42, -- 1601
				cy, -- 1602
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1603
				0, -- 1604
				0.5, -- 1605
				"Left", -- 1606
				active and 2.4 or 1.6, -- 1607
				active and 1 or 0.88, -- 1608
				0.08 -- 1609
			) -- 1609
			local val = target:settingsValueText(row.id, s, input.inputMode) -- 1612
			if val ~= "" then -- 1612
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1614
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1615
				texts:put( -- 1616
					"sm", -- 1616
					decorated, -- 1616
					panelX + panelW - 24, -- 1616
					cy, -- 1616
					toColor(valCol), -- 1616
					1, -- 1616
					0.5, -- 1616
					"Right", -- 1616
					1, -- 1616
					active and 1 or 0.86, -- 1616
					0.08 -- 1616
				) -- 1616
			end -- 1616
			i = i + 1 -- 1582
		end -- 1582
	end -- 1582
	local backY = 40 + frame.safe.bottom * 0.45 -- 1620
	local hint = target:settingsFooterHint(frame.mode, frame.layout) -- 1621
	texts:put( -- 1622
		"xs", -- 1622
		hint, -- 1622
		w * 0.5, -- 1622
		backY + 14, -- 1622
		toColor(PALETTE.textDim), -- 1622
		0.5, -- 1622
		0.5, -- 1622
		"Center", -- 1622
		1.2, -- 1622
		0.84, -- 1622
		0.08 -- 1622
	) -- 1622
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1624
	if hit >= 0 then -- 1624
		self.settingsSelected = hit -- 1626
		if applyDelta(rows[hit + 1].id, 1) then -- 1626
			return true -- 1628
		end -- 1628
		self:resetInput() -- 1630
		return false -- 1631
	end -- 1631
	if frame.keys.left or frame.prevTab then -- 1631
		local id = rows[self.settingsSelected + 1].id -- 1634
		if id ~= "back" then -- 1634
			applyDelta(id, -1) -- 1636
			self:resetInput() -- 1637
		end -- 1637
		return false -- 1639
	end -- 1639
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1639
		local id = rows[self.settingsSelected + 1].id -- 1642
		if applyDelta(id, 1) then -- 1642
			return true -- 1644
		end -- 1644
		self:resetInput() -- 1646
		return false -- 1647
	end -- 1647
	return false -- 1649
end -- 1504
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi, isMaleRoguelike, showLedgerEntry, onOpenLedger, canSaveSlots) -- 1657
	if assistHintsEnabled == nil then -- 1657
		assistHintsEnabled = false -- 1668
	end -- 1668
	if safeUi == nil then -- 1668
		safeUi = ZERO_SAFE_INSETS -- 1670
	end -- 1670
	if isMaleRoguelike == nil then -- 1670
		isMaleRoguelike = false -- 1671
	end -- 1671
	if showLedgerEntry == nil then -- 1671
		showLedgerEntry = false -- 1672
	end -- 1672
	if canSaveSlots == nil then -- 1672
		canSaveSlots = false -- 1674
	end -- 1674
	self.time = self.time + dt -- 1676
	local frame = self:readFrame(input, uiScale, safeUi) -- 1677
	if self.pauseShowControls then -- 1677
		local ctrlAct = self:drawControls( -- 1680
			frame, -- 1680
			uiDraw, -- 1680
			uiInkDraw, -- 1680
			uiArt, -- 1680
			uiGlow, -- 1680
			texts, -- 1680
			w, -- 1680
			h, -- 1680
			"返回暂停" -- 1680
		) -- 1680
		if ctrlAct.type == "backTitle" then -- 1680
			self.pauseShowControls = false -- 1682
			self:resetInput() -- 1683
		end -- 1683
		return {type = "none"} -- 1685
	end -- 1685
	if self.pauseShowSettings then -- 1685
		if self:drawPauseSettings( -- 1685
			frame, -- 1689
			input, -- 1689
			uiDraw, -- 1689
			uiInkDraw, -- 1689
			uiArt, -- 1689
			uiGlow, -- 1689
			texts, -- 1689
			w, -- 1689
			h -- 1689
		) then -- 1689
			self.pauseShowSettings = false -- 1690
			self:resetInput() -- 1691
		end -- 1691
		return {type = "none"} -- 1693
	end -- 1693
	if self.pauseShowSaves then -- 1693
		local saveAct = self:drawSavesPanel( -- 1697
			frame, -- 1697
			uiDraw, -- 1697
			uiInkDraw, -- 1697
			uiArt, -- 1697
			uiGlow, -- 1697
			texts, -- 1697
			w, -- 1697
			h, -- 1697
			true, -- 1697
			canSaveSlots -- 1697
		) -- 1697
		if saveAct.type == "backPause" then -- 1697
			self.pauseShowSaves = false -- 1699
			self:resetInput() -- 1700
			return {type = "none"} -- 1701
		end -- 1701
		if saveAct.type == "loadSlot" then -- 1701
			self.pauseShowSaves = false -- 1704
			return saveAct -- 1705
		end -- 1705
		return saveAct -- 1707
	end -- 1707
	if frame.back then -- 1707
		self.pauseShowControls = false -- 1711
		self.pauseShowSettings = false -- 1712
		self.pauseShowSaves = false -- 1713
		self:emitSound("pauseClose") -- 1714
		return {type = "resume"} -- 1715
	end -- 1715
	local allowFs = canToggleFullscreen() -- 1718
	local allowQuit = canQuitApp() -- 1719
	local pauseItems = __TS__ArrayFilter( -- 1720
		PAUSE_ITEMS, -- 1720
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) and (item.id ~= "ledger" or showLedgerEntry) end -- 1720
	) -- 1720
	if self.pauseSelected >= #pauseItems then -- 1720
		self.pauseSelected = 0 -- 1726
	end -- 1726
	uiDraw:drawRect( -- 1729
		Rect(0, 0, w, h), -- 1729
		Color(8, 10, 16, 102) -- 1729
	) -- 1729
	fillHGradRect( -- 1730
		uiDraw, -- 1730
		0, -- 1730
		0, -- 1730
		w * 0.27 + frame.safe.left, -- 1730
		h, -- 1730
		Color(9, 11, 18, 232), -- 1730
		Color(10, 13, 21, 198) -- 1730
	) -- 1730
	fillHGradRect( -- 1731
		uiDraw, -- 1731
		w * 0.27 + frame.safe.left, -- 1731
		0, -- 1731
		w * 0.21, -- 1731
		h, -- 1731
		Color(10, 13, 21, 198), -- 1731
		Color(10, 13, 21, 0) -- 1731
	) -- 1731
	local menuX = 110 + frame.safe.left * 0.6 -- 1733
	local veryCompact = #pauseItems >= 10 -- 1734
	local compact = #pauseItems > 8 -- 1735
	local headY = (veryCompact and h - 92 or (compact and h - 114 or h - 146)) - frame.safe.top * 0.35 -- 1736
	uiArt:tryPlace( -- 1737
		"ink_vstream", -- 1737
		"pause_vstream", -- 1737
		menuX - 32, -- 1737
		h * 0.5, -- 1737
		34, -- 1737
		h * 0.78, -- 1737
		{ -- 1737
			color = toColor(PALETTE.silkDim), -- 1738
			opacity = 0.48, -- 1738
			layer = 1 -- 1738
		} -- 1738
	) -- 1738
	drawMistCurve( -- 1740
		uiArt, -- 1740
		"pause_mist", -- 1740
		menuX + 118, -- 1740
		headY - 8, -- 1740
		290, -- 1740
		72, -- 1740
		PALETTE.jadeMist, -- 1740
		0.2, -- 1740
		-1 -- 1740
	) -- 1740
	texts:put( -- 1742
		"banner", -- 1742
		"暂歇", -- 1742
		menuX + 16, -- 1742
		headY, -- 1742
		toColor(PALETTE.textBright), -- 1742
		0, -- 1742
		0.5, -- 1742
		"Left", -- 1742
		10, -- 1742
		0.98, -- 1742
		0.1 -- 1742
	) -- 1742
	texts:put( -- 1743
		"xs", -- 1743
		"月夜暂驻 · 卷页留痕", -- 1743
		menuX + 18, -- 1743
		headY - 36, -- 1743
		toColor(PALETTE.textDim), -- 1743
		0, -- 1743
		0.5, -- 1743
		"Left", -- 1743
		2, -- 1743
		0.8, -- 1743
		0.08 -- 1743
	) -- 1743
	drawHairline( -- 1744
		uiInkDraw, -- 1744
		uiArt, -- 1744
		"pause_div", -- 1744
		menuX + 124, -- 1744
		headY - 56, -- 1744
		240, -- 1744
		PALETTE.silkDim, -- 1744
		0.58, -- 1744
		true, -- 1744
		2 -- 1744
	) -- 1744
	local rowStep = veryCompact and 37 or (compact and 42 or 46) -- 1746
	local rowH = veryCompact and 32 or (compact and 36 or 38) -- 1747
	local firstY = veryCompact and headY - 88 or (compact and headY - 106 or headY - 120) -- 1748
	local boxes = {} -- 1749
	local i = 0 -- 1750
	do -- 1750
		i = 0 -- 1751
		while i < #pauseItems do -- 1751
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1752
			i = i + 1 -- 1751
		end -- 1751
	end -- 1751
	local prevPauseSel = self.pauseSelected -- 1754
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1755
	if self.pauseSelected ~= prevPauseSel then -- 1755
		self:emitSound("hover") -- 1757
	end -- 1757
	do -- 1757
		i = 0 -- 1760
		while i < #pauseItems do -- 1760
			local iy = boxes[i + 1].y -- 1761
			local active = self.pauseSelected == i -- 1762
			local cy = iy + rowH * 0.5 -- 1763
			local shiftX = active and 10 or 0 -- 1764
			local item = pauseItems[i + 1] -- 1765
			local label = item.zh -- 1766
			if item.id == "retry" and isMaleRoguelike then -- 1766
				label = "重开本轮护送" -- 1768
			elseif item.id == "assist" then -- 1768
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1770
			elseif item.id == "fullscreen" then -- 1770
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1772
			elseif item.id == "settings" then -- 1772
				label = getActiveTarget():settingsPauseLabel(input.settings) -- 1774
			end -- 1774
			if active then -- 1774
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1778
				drawSilkRibbon( -- 1779
					uiDraw, -- 1779
					uiArt, -- 1779
					"pause_rib_" .. tostring(i), -- 1779
					menuX + 116, -- 1779
					cy, -- 1779
					282, -- 1779
					rowH, -- 1779
					PALETTE.rougeSoft, -- 1779
					0.54 * breathe, -- 1779
					0 -- 1779
				) -- 1779
				drawHairline( -- 1780
					uiInkDraw, -- 1780
					uiArt, -- 1780
					"pause_line_" .. tostring(i), -- 1780
					menuX + 106, -- 1780
					iy + 3, -- 1780
					210, -- 1780
					PALETTE.silkLine, -- 1780
					0.42 * breathe, -- 1780
					false, -- 1780
					2 -- 1780
				) -- 1780
				drawBlossomDot( -- 1781
					uiInkDraw, -- 1781
					uiArt, -- 1781
					"pause_dot_" .. tostring(i), -- 1781
					menuX + 12, -- 1781
					cy, -- 1781
					15, -- 1781
					PALETTE.rouge, -- 1781
					0.96, -- 1781
					4 -- 1781
				) -- 1781
				fillRadialGlow( -- 1782
					uiGlow, -- 1782
					menuX + 12, -- 1782
					cy, -- 1782
					22, -- 1782
					16, -- 1782
					toColor(PALETTE.rouge, 26 * breathe), -- 1782
					Color(182, 58, 56, 0), -- 1782
					10 -- 1782
				) -- 1782
			else -- 1782
				drawBlossomDot( -- 1784
					uiInkDraw, -- 1784
					uiArt, -- 1784
					"pause_dot_" .. tostring(i), -- 1784
					menuX + 12, -- 1784
					cy, -- 1784
					8, -- 1784
					PALETTE.silkDim, -- 1784
					0.4, -- 1784
					3 -- 1784
				) -- 1784
			end -- 1784
			texts:put( -- 1787
				compact and "sm" or "md", -- 1788
				label, -- 1789
				menuX + 32 + shiftX, -- 1790
				cy, -- 1791
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1792
				0, -- 1793
				0.5, -- 1794
				"Left", -- 1795
				active and 3.4 or 2.2, -- 1796
				active and 1 or 0.88, -- 1797
				0.1 -- 1798
			) -- 1798
			i = i + 1 -- 1760
		end -- 1760
	end -- 1760
	local pauseFooter = getActiveTarget():pauseFooterHint(frame.mode, frame.layout) -- 1802
	texts:put( -- 1803
		"xs", -- 1803
		pauseFooter, -- 1803
		menuX + 12, -- 1803
		38 + frame.safe.bottom * 0.4, -- 1803
		toColor(PALETTE.textDim), -- 1803
		0, -- 1803
		0.5, -- 1803
		"Left", -- 1803
		1.2, -- 1803
		0.86, -- 1803
		0.08 -- 1803
	) -- 1803
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1805
	if hit >= 0 or frame.keys.confirm then -- 1805
		local idx = hit >= 0 and hit or self.pauseSelected -- 1807
		local id = pauseItems[idx + 1].id -- 1808
		if id == "controls" then -- 1808
			self.pauseShowControls = true -- 1810
			self:emitSound("confirm") -- 1811
			self:resetInput() -- 1812
			return {type = "none"} -- 1813
		end -- 1813
		if id == "settings" then -- 1813
			self:openPauseSettings() -- 1816
			self:emitSound("confirm") -- 1817
			return {type = "none"} -- 1818
		end -- 1818
		if id == "saves" then -- 1818
			self:openSaves(true) -- 1821
			self:emitSound("confirm") -- 1822
			return {type = "none"} -- 1823
		end -- 1823
		if id == "ledger" then -- 1823
			if onOpenLedger ~= nil then -- 1823
				onOpenLedger() -- 1827
			end -- 1827
			self.pauseShowControls = false -- 1829
			self.pauseShowSettings = false -- 1830
			self:emitSound("confirm") -- 1831
			return {type = "resume"} -- 1832
		end -- 1832
		if id == "assist" then -- 1832
			if onToggleAssist ~= nil then -- 1832
				onToggleAssist() -- 1836
			end -- 1836
			self:emitSound("toggle") -- 1838
			self:resetInput() -- 1839
			return {type = "none"} -- 1840
		end -- 1840
		if id == "fullscreen" then -- 1840
			self:emitSound("toggle") -- 1843
			self:resetInput() -- 1844
			return {type = "toggleFullscreen"} -- 1845
		end -- 1845
		self.pauseShowControls = false -- 1847
		self.pauseShowSettings = false -- 1848
		if id == "resume" then -- 1848
			self:emitSound("pauseClose") -- 1849
			return {type = "resume"} -- 1849
		end -- 1849
		if id == "retry" then -- 1849
			self:emitSound("confirm") -- 1850
			return {type = "retry"} -- 1850
		end -- 1850
		if id == "chapters" then -- 1850
			self:emitSound("confirm") -- 1851
			return {type = "openChapters"} -- 1851
		end -- 1851
		if id == "quit" then -- 1851
			self:emitSound("back") -- 1852
			return {type = "quit"} -- 1852
		end -- 1852
		self:emitSound("back") -- 1853
		return {type = "toTitle"} -- 1854
	end -- 1854
	return {type = "none"} -- 1856
end -- 1657
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1863
	if frame.back then -- 1863
		return {type = "backTitle"} -- 1874
	end -- 1874
	uiDraw:drawRect( -- 1878
		Rect(0, 0, w, h), -- 1878
		Color(7, 9, 15, 214) -- 1878
	) -- 1878
	local cx = w * 0.5 -- 1879
	local reunion = self.epilogueEnding == "reunion" -- 1880
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1881
	drawMistCurve( -- 1882
		uiArt, -- 1882
		"ep_mist", -- 1882
		cx, -- 1882
		h * 0.62, -- 1882
		620, -- 1882
		120, -- 1882
		accentCol, -- 1882
		0.2, -- 1882
		0 -- 1882
	) -- 1882
	fillRadialGlow( -- 1883
		uiGlow, -- 1883
		cx, -- 1883
		h * 0.68, -- 1883
		220, -- 1883
		140, -- 1883
		toColor(accentCol, 28), -- 1883
		Color(10, 14, 22, 0), -- 1883
		18 -- 1883
	) -- 1883
	local titleY = h * 0.72 -- 1886
	texts:put( -- 1887
		"title", -- 1887
		"向西守望", -- 1887
		cx - 18, -- 1887
		titleY, -- 1887
		toColor(PALETTE.textBright), -- 1887
		0.5, -- 1887
		0.5, -- 1887
		"Center", -- 1887
		12, -- 1887
		0.98, -- 1887
		0.12 -- 1887
	) -- 1887
	drawLoneSeal( -- 1888
		uiInkDraw, -- 1888
		uiArt, -- 1888
		texts, -- 1888
		"ep_seal", -- 1888
		cx + 148, -- 1888
		titleY - 2, -- 1888
		24, -- 1888
		46, -- 1888
		"守", -- 1888
		"望", -- 1888
		PALETTE.sealRed, -- 1888
		PALETTE.sealText, -- 1888
		0.94, -- 1888
		4 -- 1888
	) -- 1888
	drawHairline( -- 1889
		uiInkDraw, -- 1889
		uiArt, -- 1889
		"ep_div", -- 1889
		cx, -- 1889
		titleY - 46, -- 1889
		360, -- 1889
		PALETTE.silkDim, -- 1889
		0.62, -- 1889
		true, -- 1889
		2 -- 1889
	) -- 1889
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1891
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1892
	texts:put( -- 1895
		"md", -- 1895
		endingTitle, -- 1895
		cx, -- 1895
		titleY - 76, -- 1895
		toColor(PALETTE.amberCore), -- 1895
		0.5, -- 1895
		0.5, -- 1895
		"Center", -- 1895
		3.2, -- 1895
		0.96, -- 1895
		0.08 -- 1895
	) -- 1895
	texts:put( -- 1896
		"sm", -- 1896
		verse, -- 1896
		cx, -- 1896
		titleY - 114, -- 1896
		toColor(PALETTE.textMid), -- 1896
		0.5, -- 1896
		0.5, -- 1896
		"Center", -- 1896
		1, -- 1896
		0.92, -- 1896
		0.08 -- 1896
	) -- 1896
	if self.epilogueBothCleared then -- 1896
		drawSilkVeil( -- 1899
			uiDraw, -- 1899
			uiArt, -- 1899
			"ep_well_veil", -- 1899
			cx, -- 1899
			titleY - 152, -- 1899
			560, -- 1899
			30, -- 1899
			PALETTE.inkWarm, -- 1899
			0.68, -- 1899
			0 -- 1899
		) -- 1899
		texts:put( -- 1900
			"xs", -- 1900
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1900
			cx, -- 1900
			titleY - 152, -- 1900
			toColor(PALETTE.cyanCore), -- 1900
			0.5, -- 1900
			0.5, -- 1900
			"Center", -- 1900
			1, -- 1900
			0.9, -- 1900
			0.08 -- 1900
		) -- 1900
	end -- 1900
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1903
	local btnW = 286 -- 1908
	local btnH = 44 -- 1909
	local gap = 14 -- 1910
	local baseY = math.max(150, h * 0.34) -- 1911
	local boxes = {} -- 1912
	local i = 0 -- 1913
	do -- 1913
		i = 0 -- 1914
		while i < #items do -- 1914
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1915
			i = i + 1 -- 1914
		end -- 1914
	end -- 1914
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1917
	do -- 1917
		i = 0 -- 1919
		while i < #items do -- 1919
			local box = boxes[i + 1] -- 1920
			local active = self.epilogueSelected == i -- 1921
			local cy = box.y + box.height * 0.5 -- 1922
			if active then -- 1922
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1924
				drawSilkRibbon( -- 1925
					uiDraw, -- 1925
					uiArt, -- 1925
					"ep_rib_" .. tostring(i), -- 1925
					cx, -- 1925
					cy, -- 1925
					btnW + 24, -- 1925
					btnH, -- 1925
					PALETTE.rougeSoft, -- 1925
					0.62 * breathe, -- 1925
					0 -- 1925
				) -- 1925
				drawHairline( -- 1926
					uiInkDraw, -- 1926
					uiArt, -- 1926
					"ep_line_" .. tostring(i), -- 1926
					cx, -- 1926
					box.y + 3, -- 1926
					btnW - 44, -- 1926
					PALETTE.silkLine, -- 1926
					0.48 * breathe, -- 1926
					false, -- 1926
					2 -- 1926
				) -- 1926
				drawBlossomDot( -- 1927
					uiInkDraw, -- 1927
					uiArt, -- 1927
					"ep_dot_" .. tostring(i), -- 1927
					box.x + 22, -- 1927
					cy, -- 1927
					13, -- 1927
					PALETTE.rouge, -- 1927
					0.96, -- 1927
					4 -- 1927
				) -- 1927
			else -- 1927
				drawSilkVeil( -- 1929
					uiDraw, -- 1929
					uiArt, -- 1929
					"ep_idle_" .. tostring(i), -- 1929
					cx, -- 1929
					cy, -- 1929
					btnW, -- 1929
					btnH - 2, -- 1929
					PALETTE.inkWash, -- 1929
					0.58, -- 1929
					0 -- 1929
				) -- 1929
				drawBlossomDot( -- 1930
					uiInkDraw, -- 1930
					uiArt, -- 1930
					"ep_dot_" .. tostring(i), -- 1930
					box.x + 22, -- 1930
					cy, -- 1930
					8, -- 1930
					PALETTE.silkDim, -- 1930
					0.42, -- 1930
					3 -- 1930
				) -- 1930
			end -- 1930
			texts:put( -- 1932
				"sm", -- 1933
				items[i + 1].zh, -- 1934
				cx + 6, -- 1935
				cy, -- 1936
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1937
				0.5, -- 1938
				0.5, -- 1939
				"Center", -- 1940
				active and 2.6 or 1.6, -- 1941
				active and 1 or 0.88, -- 1942
				0.08 -- 1943
			) -- 1943
			i = i + 1 -- 1919
		end -- 1919
	end -- 1919
	local footer = getActiveTarget():epilogueFooterHint(frame.mode, frame.layout) -- 1947
	texts:put( -- 1948
		"xs", -- 1948
		footer, -- 1948
		cx, -- 1948
		38 + frame.safe.bottom * 0.4, -- 1948
		toColor(PALETTE.textDim), -- 1948
		0.5, -- 1948
		0.5, -- 1948
		"Center", -- 1948
		1.2, -- 1948
		0.84, -- 1948
		0.08 -- 1948
	) -- 1948
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1950
	if hit >= 0 or frame.keys.confirm then -- 1950
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1952
		local id = items[idx + 1].id -- 1953
		if id == "history" then -- 1953
			return {type = "openHistory"} -- 1954
		end -- 1954
		if id == "replay" then -- 1954
			return {type = "replayStory"} -- 1955
		end -- 1955
		return {type = "backTitle"} -- 1956
	end -- 1956
	return {type = "none"} -- 1958
end -- 1863
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1965
	if frame.back then -- 1965
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1976
	end -- 1976
	local total = #HISTORY_CARDS -- 1979
	if frame.keys.left or frame.prevTab then -- 1979
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1981
	elseif frame.keys.right or frame.nextTab then -- 1981
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1983
	end -- 1983
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1985
	uiDraw:drawRect( -- 1987
		Rect(0, 0, w, h), -- 1987
		Color(7, 9, 15, 206) -- 1987
	) -- 1987
	local cx = w * 0.5 -- 1988
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1989
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1990
	local px = cx - pageW * 0.5 -- 1991
	local py = (h - pageH) * 0.5 + 14 -- 1992
	local midY = py + pageH * 0.5 -- 1993
	uiArt:tryPlace( -- 1995
		"ink_frame_mask", -- 1995
		"hist_shadow", -- 1995
		cx, -- 1995
		midY - 6, -- 1995
		pageW + 52, -- 1995
		pageH + 46, -- 1995
		{ -- 1995
			color = toColor(PALETTE.voidDark), -- 1996
			opacity = 0.84, -- 1996
			layer = -1 -- 1996
		} -- 1996
	) -- 1996
	if not uiArt:tryPlace( -- 1996
		"ink_song_paper", -- 1998
		"hist_paper", -- 1998
		cx, -- 1998
		midY, -- 1998
		pageW, -- 1998
		pageH, -- 1998
		{opacity = 0.98, layer = 1} -- 1998
	) then -- 1998
		uiDraw:drawRect( -- 1999
			Rect(px, py, pageW, pageH), -- 1999
			toColor(PALETTE.xuanPaper, 248), -- 1999
			1, -- 1999
			toColor(PALETTE.silkDim, 180) -- 1999
		) -- 1999
	end -- 1999
	fillRadialGlow( -- 2001
		uiGlow, -- 2001
		cx, -- 2001
		midY + 40, -- 2001
		260, -- 2001
		140, -- 2001
		Color(236, 224, 202, 16), -- 2001
		Color(236, 224, 202, 0), -- 2001
		14 -- 2001
	) -- 2001
	local inX = px + 42 -- 2004
	local inY = py + 32 -- 2005
	local inW = pageW - 84 -- 2006
	local inH = pageH - 64 -- 2007
	local redSilk = toColor(PALETTE.rouge, 118) -- 2008
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 2009
	uiInkDraw:drawRect( -- 2010
		Rect(inX, inY, inW, inH), -- 2010
		Color(0, 0, 0, 0), -- 2010
		0.95, -- 2010
		redSilk -- 2010
	) -- 2010
	uiInkDraw:drawRect( -- 2011
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 2011
		Color(0, 0, 0, 0), -- 2011
		0.55, -- 2011
		redSilkFaint -- 2011
	) -- 2011
	local headY = inY + inH - 30 -- 2014
	texts:put( -- 2015
		"md", -- 2015
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 2015
		inX + 20, -- 2015
		headY, -- 2015
		toColor(PALETTE.xuanInk), -- 2015
		0, -- 2015
		0.5, -- 2015
		"Left", -- 2015
		2, -- 2015
		0.96, -- 2015
		0 -- 2015
	) -- 2015
	texts:put( -- 2016
		"xs", -- 2016
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 2016
		inX + inW - 20, -- 2016
		headY, -- 2016
		toColor(PALETTE.rouge), -- 2016
		1, -- 2016
		0.5, -- 2016
		"Right", -- 2016
		1.8, -- 2016
		0.88, -- 2016
		0 -- 2016
	) -- 2016
	uiInkDraw:drawSegment( -- 2017
		Vec2(inX + 14, headY - 22), -- 2017
		Vec2(inX + inW - 14, headY - 22), -- 2017
		0.85, -- 2017
		redSilk -- 2017
	) -- 2017
	texts:put( -- 2020
		"xs", -- 2020
		card.subtitle, -- 2020
		inX + 20, -- 2020
		headY - 42, -- 2020
		toColor(PALETTE.xuanInkSub), -- 2020
		0, -- 2020
		0.5, -- 2020
		"Left", -- 2020
		1.4, -- 2020
		0.86, -- 2020
		0 -- 2020
	) -- 2020
	local function wrapZh(src, maxUnits) -- 2023
		local out = {} -- 2024
		local buf = "" -- 2025
		local units = 0 -- 2026
		local ci = 0 -- 2027
		while ci < #src do -- 2027
			local b = __TS__StringCharCodeAt(src, ci) -- 2029
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 2030
			local ch = __TS__StringSlice(src, ci, ci + step) -- 2031
			local u = b < 128 and 0.56 or 1.02 -- 2032
			if units + u > maxUnits and buf ~= "" then -- 2032
				out[#out + 1] = buf -- 2034
				buf = ch -- 2035
				units = u -- 2036
			else -- 2036
				buf = buf .. ch -- 2038
				units = units + u -- 2039
			end -- 2039
			ci = ci + step -- 2041
		end -- 2041
		if buf ~= "" then -- 2041
			out[#out + 1] = buf -- 2044
		end -- 2044
		return out -- 2046
	end -- 2023
	local charsPerLine = math.max( -- 2049
		24, -- 2049
		math.floor((inW - 44) / 20) -- 2049
	) -- 2049
	local cursorY = headY - 76 -- 2050
	local pi = 0 -- 2051
	do -- 2051
		pi = 0 -- 2052
		while pi < #card.paragraphs do -- 2052
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 2053
			local li = 0 -- 2054
			do -- 2054
				li = 0 -- 2055
				while li < #lines do -- 2055
					texts:put( -- 2056
						"sm", -- 2056
						lines[li + 1], -- 2056
						inX + 22, -- 2056
						cursorY, -- 2056
						toColor(PALETTE.xuanInk), -- 2056
						0, -- 2056
						0.5, -- 2056
						"Left", -- 2056
						0.6, -- 2056
						0.94, -- 2056
						0 -- 2056
					) -- 2056
					cursorY = cursorY - 30 -- 2057
					li = li + 1 -- 2055
				end -- 2055
			end -- 2055
			cursorY = cursorY - 12 -- 2059
			pi = pi + 1 -- 2052
		end -- 2052
	end -- 2052
	local footY = inY + 26 -- 2063
	uiInkDraw:drawSegment( -- 2064
		Vec2(inX + 14, footY + 20), -- 2064
		Vec2(inX + inW - 14, footY + 20), -- 2064
		0.6, -- 2064
		redSilkFaint -- 2064
	) -- 2064
	texts:put( -- 2065
		"xs", -- 2065
		card.footnote, -- 2065
		inX + 20, -- 2065
		footY, -- 2065
		toColor(PALETTE.xuanInkSub), -- 2065
		0, -- 2065
		0.5, -- 2065
		"Left", -- 2065
		0.4, -- 2065
		0.84, -- 2065
		0 -- 2065
	) -- 2065
	local navY = math.max(30, py - 48) -- 2068
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 2069
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 2070
	local backBox = Rect(cx - 88, navY, 176, 34) -- 2071
	local function drawNavBtn(box, tag, label) -- 2073
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 2074
		drawSilkVeil( -- 2075
			uiDraw, -- 2075
			uiArt, -- 2075
			"hist_btn_" .. tag, -- 2075
			box.x + box.width * 0.5, -- 2075
			box.y + box.height * 0.5, -- 2075
			box.width, -- 2075
			box.height, -- 2075
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 2075
			hover and 0.86 or 0.72, -- 2075
			2 -- 2075
		) -- 2075
		texts:put( -- 2076
			"xs", -- 2076
			label, -- 2076
			box.x + box.width * 0.5, -- 2076
			box.y + box.height * 0.5, -- 2076
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 2076
			0.5, -- 2076
			0.5, -- 2076
			"Center", -- 2076
			1.4, -- 2076
			0.94, -- 2076
			0.08 -- 2076
		) -- 2076
		return hover and frame.click -- 2077
	end -- 2073
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 2073
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 2081
	end -- 2081
	if drawNavBtn(nextBox, "next", "下一篇") then -- 2081
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 2084
	end -- 2084
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 2084
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 2087
	end -- 2087
	if frame.keys.confirm then -- 2087
		if self.historyCardIndex + 1 < total then -- 2087
			self.historyCardIndex = self.historyCardIndex + 1 -- 2092
		else -- 2092
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 2094
		end -- 2094
	end -- 2094
	return {type = "none"} -- 2097
end -- 1965
return ____exports -- 1965