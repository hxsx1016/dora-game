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
	{id = "assist", zh = "按键辅助：开"}, -- 144
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
local function hitIndex(boxes, pointer, inside) -- 183
	if not inside then -- 183
		return -1 -- 185
	end -- 185
	return __TS__ArrayFindIndex( -- 187
		boxes, -- 187
		function(____, box) return box:containsPoint(pointer) end -- 187
	) -- 187
end -- 183
____exports.MenuRenderer = __TS__Class() -- 190
local MenuRenderer = ____exports.MenuRenderer -- 190
MenuRenderer.name = "MenuRenderer" -- 190
function MenuRenderer.prototype.____constructor(self) -- 190
	self.selected = 0 -- 191
	self.chapterSelected = 0 -- 192
	self.pauseSelected = 0 -- 193
	self.settingsSelected = 0 -- 194
	self.saveSelected = 0 -- 195
	self.saveActionSelected = 0 -- 196
	self.epilogueSelected = 0 -- 197
	self.epilogueEnding = "lamp" -- 198
	self.epilogueBothCleared = false -- 199
	self.historyCardIndex = 0 -- 200
	self.historyFromEpilogue = false -- 201
	self.hasSession = false -- 203
	self.sessionLabel = "" -- 205
	self.saveSlots = {} -- 207
	self.controlsTab = "kbm" -- 213
	self.chaptersFromPause = false -- 229
	self.pauseShowControls = false -- 230
	self.pauseShowSettings = false -- 231
	self.pauseShowSaves = false -- 232
	self.titleConfirmNewGame = false -- 233
	self.titleConfirmSel = 1 -- 234
	self.saveConfirmKind = "" -- 235
	self.saveConfirmSlot = 1 -- 236
	self.saveConfirmSel = 1 -- 237
	self.controlsTabManual = false -- 238
	self.queuedKeys = {} -- 239
	self.queuedBack = false -- 240
	self.queuedSkip = false -- 241
	self.splashTime = 0 -- 242
	self.splashGuardT = 0 -- 243
	self.time = 0 -- 244
end -- 190
function MenuRenderer.prototype.setSessionRoomKey(self, roomKey) -- 209
	self.sessionLabel = roomKey ~= "" and themeOf(roomKey).shortNameZh or "" -- 210
end -- 209
function MenuRenderer.prototype.emitSound(self, kind) -- 223
	if self.onUiSound ~= nil then -- 223
		self:onUiSound(kind) -- 225
	end -- 225
end -- 223
function MenuRenderer.prototype.resetSplash(self) -- 246
	self.splashTime = 0 -- 247
	self.splashGuardT = 0 -- 248
	self.queuedSkip = false -- 249
	self:resetInput() -- 250
end -- 246
function MenuRenderer.prototype.focusQuit(self, screen) -- 254
	if screen == "title" then -- 254
		local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 256
			TITLE_ITEMS, -- 258
			function(____, it) return it.id ~= "quit" end -- 258
		) -- 258
		local items = self.hasSession and ({ -- 259
			{id = "continue", zh = "继续游戏"}, -- 260
			table.unpack(baseItems) -- 260
		}) or baseItems -- 260
		local qIdx = __TS__ArrayFindIndex( -- 262
			items, -- 262
			function(____, it) return it.id == "quit" end -- 262
		) -- 262
		if qIdx >= 0 then -- 262
			self.selected = qIdx -- 264
		end -- 264
		self.titleConfirmNewGame = false -- 266
	elseif screen == "play" then -- 266
		self.pauseShowControls = false -- 268
		self.pauseShowSettings = false -- 269
		self.pauseShowSaves = false -- 270
		self.saveConfirmKind = "" -- 271
		local allowFs = canToggleFullscreen() -- 272
		local allowQuit = canQuitApp() -- 273
		local pauseItems = __TS__ArrayFilter( -- 274
			PAUSE_ITEMS, -- 274
			function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) and item.id ~= "ledger" end -- 274
		) -- 274
		local qIdx = __TS__ArrayFindIndex( -- 279
			pauseItems, -- 279
			function(____, item) return item.id == "quit" end -- 279
		) -- 279
		if qIdx >= 0 then -- 279
			self.pauseSelected = qIdx -- 281
		end -- 281
	end -- 281
	self:resetInput() -- 284
end -- 254
function MenuRenderer.prototype.isShowingPauseControls(self) -- 287
	return self.pauseShowControls -- 288
end -- 287
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 291
	return self.pauseShowSettings -- 292
end -- 291
function MenuRenderer.prototype.isShowingPauseSaves(self) -- 295
	return self.pauseShowSaves -- 296
end -- 295
function MenuRenderer.prototype.isShowingTitleConfirm(self) -- 299
	return self.titleConfirmNewGame -- 300
end -- 299
function MenuRenderer.prototype.refreshSaveSlots(self) -- 303
	self.saveSlots = listSaveSlots() -- 304
end -- 303
function MenuRenderer.prototype.openSaves(self, fromPause) -- 307
	if fromPause == nil then -- 307
		fromPause = false -- 307
	end -- 307
	self:refreshSaveSlots() -- 308
	self.saveSelected = fromPause and 1 or 0 -- 309
	self.saveActionSelected = 0 -- 310
	self.saveConfirmKind = "" -- 311
	self.saveConfirmSel = 1 -- 312
	self.pauseShowControls = false -- 313
	self.pauseShowSettings = false -- 314
	self.pauseShowSaves = fromPause -- 315
	self:resetInput() -- 316
end -- 307
function MenuRenderer.prototype.openSettings(self) -- 319
	self.settingsSelected = 0 -- 320
	self.titleConfirmNewGame = false -- 321
	self:resetInput() -- 322
end -- 319
function MenuRenderer.prototype.openPauseSettings(self) -- 325
	self.pauseShowControls = false -- 326
	self.pauseShowSaves = false -- 327
	self.pauseShowSettings = true -- 328
	self.settingsSelected = 0 -- 329
	self:resetInput() -- 330
end -- 325
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 333
	self.chaptersFromPause = roomIndex ~= nil -- 334
	self.chapterSelected = math.max( -- 335
		0, -- 335
		__TS__ArrayFindIndex( -- 335
			CHAPTERS, -- 335
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 335
		) -- 335
	) -- 335
	self.pauseShowControls = false -- 336
	self.pauseShowSettings = false -- 337
	self.pauseShowSaves = false -- 338
	self.titleConfirmNewGame = false -- 339
	self:resetInput() -- 340
end -- 333
function MenuRenderer.prototype.openPause(self) -- 343
	self.pauseSelected = 0 -- 344
	self.pauseShowControls = false -- 345
	self.pauseShowSettings = false -- 346
	self.pauseShowSaves = false -- 347
	self.saveConfirmKind = "" -- 348
	self:resetInput() -- 349
end -- 343
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 352
	if ending == nil then -- 352
		ending = "lamp" -- 352
	end -- 352
	if bothCleared == nil then -- 352
		bothCleared = false -- 352
	end -- 352
	self.epilogueEnding = ending -- 353
	self.epilogueBothCleared = bothCleared -- 354
	self.epilogueSelected = 0 -- 355
	self:resetInput() -- 356
end -- 352
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 359
	if fromEpilogue == nil then -- 359
		fromEpilogue = true -- 359
	end -- 359
	self.historyFromEpilogue = fromEpilogue -- 360
	self.historyCardIndex = 0 -- 361
	self:resetInput() -- 362
end -- 359
function MenuRenderer.prototype.triggerBack(self) -- 366
	self.queuedBack = true -- 367
end -- 366
function MenuRenderer.prototype.resetInput(self) -- 371
	self.queuedKeys = {} -- 372
	self.queuedBack = false -- 373
	self.queuedSkip = false -- 374
	self.controlsTabManual = false -- 375
end -- 371
function MenuRenderer.prototype.onKeyEvent(self, key) -- 379
	self.queuedSkip = true -- 380
	if key == "Up" or key == "W" then -- 380
		self.queuedKeys.up = true -- 382
	elseif key == "Down" or key == "S" then -- 382
		self.queuedKeys.down = true -- 384
	elseif key == "Left" or key == "A" then -- 384
		self.queuedKeys.left = true -- 386
	elseif key == "Right" or key == "D" then -- 386
		self.queuedKeys.right = true -- 388
	elseif key == "Return" or key == "Space" then -- 388
		self.queuedKeys.confirm = true -- 390
	elseif key == "Escape" then -- 390
		self.queuedBack = true -- 392
	end -- 392
end -- 379
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 396
	local queued = self.queuedKeys -- 397
	local guarded = self.splashGuardT > 0 -- 398
	local useUiPtr = input.uiInside or input.uiPressed -- 401
	local rawX = useUiPtr and input.uiX or input.mx -- 402
	local rawY = useUiPtr and input.uiY or input.my -- 403
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 404
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 405
	local ____useUiPtr_0 -- 406
	if useUiPtr then -- 406
		____useUiPtr_0 = input.uiInside -- 406
	else -- 406
		____useUiPtr_0 = input.inside -- 406
	end -- 406
	local inside = ____useUiPtr_0 -- 406
	local ____useUiPtr_1 -- 407
	if useUiPtr then -- 407
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 407
	else -- 407
		____useUiPtr_1 = input.inside and input.fire.pressed -- 407
	end -- 407
	local click = ____useUiPtr_1 -- 407
	local touchMode = input:isTouchMode() -- 408
	local frame = { -- 410
		keys = { -- 411
			up = queued.up == true or input.navUp, -- 412
			down = queued.down == true or input.navDown, -- 413
			left = queued.left == true or input.navLeft, -- 414
			right = queued.right == true or input.navRight, -- 415
			confirm = not guarded and (queued.confirm == true or input.navConfirm) -- 416
		}, -- 416
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 418
		prevTab = input.navPrevTab, -- 419
		nextTab = input.navNextTab, -- 420
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 421
		pointer = Vec2(rawX / scale, rawY / scale), -- 422
		inside = inside, -- 423
		click = not guarded and click, -- 424
		rightClick = not guarded and input.uiRightPressed, -- 425
		wheelY = input.uiWheelY, -- 426
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 427
		mode = input.inputMode, -- 428
		layout = input.gamepadLayout, -- 429
		safe = safe -- 430
	} -- 430
	self.queuedKeys = {} -- 432
	self.queuedBack = false -- 433
	self.queuedSkip = false -- 434
	return frame -- 435
end -- 396
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame, allowWheel) -- 438
	if allowWheel == nil then -- 438
		allowWheel = true -- 438
	end -- 438
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 439
	if frame.click and hit >= 0 then -- 439
		return hit -- 441
	end -- 441
	if frame.keys.up or allowWheel and frame.wheelY > 0.1 then -- 441
		return (selected + #boxes - 1) % #boxes -- 444
	end -- 444
	if frame.keys.down or allowWheel and frame.wheelY < -0.1 then -- 444
		return (selected + 1) % #boxes -- 447
	end -- 447
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 449
end -- 438
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 452
	if safeUi == nil then -- 452
		safeUi = ZERO_SAFE_INSETS -- 468
	end -- 468
	self.time = self.time + dt -- 470
	if self.splashGuardT > 0 then -- 470
		self.splashGuardT = math.max( -- 472
			0, -- 472
			self.splashGuardT - math.min( -- 472
				0.05, -- 472
				math.max(0, dt) -- 472
			) -- 472
		) -- 472
	end -- 472
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 474
	if screen ~= "splash" or splashDissolving then -- 474
		local artW = math.max(w, h * 16 / 9) -- 476
		local artH = artW * 9 / 16 -- 477
		if not backdropArt:tryPlace( -- 477
			"title_backdrop", -- 478
			"menu_landscape", -- 478
			w * 0.5, -- 478
			(h - artH) * 0.5, -- 478
			artW, -- 478
			artH -- 478
		) then -- 478
			stage:drawMenuBackdrop( -- 479
				bgDraw, -- 479
				bgGlow, -- 479
				w, -- 479
				h, -- 479
				self.time -- 479
			) -- 479
		end -- 479
	end -- 479
	local frame = self:readFrame(input, uiScale, safeUi) -- 483
	w = w / uiScale -- 484
	h = h / uiScale -- 485
	if screen == "splash" then -- 485
		return self:drawSplash( -- 488
			dt, -- 488
			frame, -- 488
			uiDraw, -- 488
			uiArt, -- 488
			texts, -- 488
			w, -- 488
			h -- 488
		) -- 488
	end -- 488
	if screen == "title" then -- 488
		return self:drawTitle( -- 491
			frame, -- 491
			uiDraw, -- 491
			uiInkDraw, -- 491
			uiArt, -- 491
			uiGlow, -- 491
			texts, -- 491
			w, -- 491
			h -- 491
		) -- 491
	end -- 491
	if screen == "chapters" then -- 491
		return self:drawChapters( -- 494
			frame, -- 494
			uiDraw, -- 494
			uiInkDraw, -- 494
			uiArt, -- 494
			uiGlow, -- 494
			texts, -- 494
			w, -- 494
			h -- 494
		) -- 494
	end -- 494
	if screen == "saves" then -- 494
		return self:drawSavesPanel( -- 497
			frame, -- 497
			uiDraw, -- 497
			uiInkDraw, -- 497
			uiArt, -- 497
			uiGlow, -- 497
			texts, -- 497
			w, -- 497
			h, -- 497
			false, -- 497
			false -- 497
		) -- 497
	end -- 497
	if screen == "settings" then -- 497
		if self:drawPauseSettings( -- 497
			frame, -- 500
			input, -- 500
			uiDraw, -- 500
			uiInkDraw, -- 500
			uiArt, -- 500
			uiGlow, -- 500
			texts, -- 500
			w, -- 500
			h -- 500
		) then -- 500
			return {type = "backTitle"} -- 501
		end -- 501
		return {type = "none"} -- 503
	end -- 503
	if screen == "epilogue" then -- 503
		return self:drawEpilogue( -- 506
			frame, -- 506
			uiDraw, -- 506
			uiInkDraw, -- 506
			uiArt, -- 506
			uiGlow, -- 506
			texts, -- 506
			w, -- 506
			h -- 506
		) -- 506
	end -- 506
	if screen == "history" then -- 506
		return self:drawHistory( -- 509
			frame, -- 509
			uiDraw, -- 509
			uiInkDraw, -- 509
			uiArt, -- 509
			uiGlow, -- 509
			texts, -- 509
			w, -- 509
			h -- 509
		) -- 509
	end -- 509
	return self:drawControls( -- 511
		frame, -- 511
		uiDraw, -- 511
		uiInkDraw, -- 511
		uiArt, -- 511
		uiGlow, -- 511
		texts, -- 511
		w, -- 511
		h -- 511
	) -- 511
end -- 452
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 520
	local safeDt = math.min( -- 529
		0.1, -- 529
		math.max(0, dt) -- 529
	) -- 529
	self.splashTime = self.splashTime + safeDt -- 530
	local t = self.splashTime -- 531
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 533
	if wantSkip or t >= 4.65 then -- 533
		self.splashTime = 0 -- 535
		if wantSkip then -- 535
			self.splashGuardT = 0.18 -- 537
		end -- 537
		return {type = "splashDone"} -- 539
	end -- 539
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 542
	local bgR = t < 2.2 and 13 or 11 -- 543
	local bgG = t < 2.2 and 16 or 13 -- 544
	local bgB = t < 2.2 and 24 or 19 -- 545
	uiDraw:drawRect( -- 546
		Rect(0, 0, w, h), -- 546
		Color( -- 546
			bgR, -- 546
			bgG, -- 546
			bgB, -- 546
			math.floor(255 * fadeOutCurtain + 0.5) -- 546
		) -- 546
	) -- 546
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 548
		if localT <= 0 or localT >= endT then -- 548
			return 0 -- 549
		end -- 549
		if localT < fadeIn then -- 549
			local u = localT / fadeIn -- 551
			return u * u * (3 - 2 * u) -- 552
		end -- 552
		if localT <= holdEnd then -- 552
			return 1 -- 554
		end -- 554
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 555
		return 1 - u * u * (3 - 2 * u) -- 556
	end -- 548
	if t < 2.2 then -- 548
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 560
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 561
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 562
		if not uiArt:tryPlace( -- 562
			"brand_team_logo", -- 563
			"splash_team_logo", -- 563
			w * 0.5, -- 563
			h * 0.54, -- 563
			logoH * 2, -- 563
			logoH, -- 563
			{opacity = alpha, layer = 2} -- 563
		) then -- 563
			texts:put( -- 564
				"banner", -- 564
				"OUTSIDER", -- 564
				w * 0.5, -- 564
				h * 0.52, -- 564
				toColor(PALETTE.textBright), -- 564
				0.5, -- 564
				0.5, -- 564
				"Center", -- 564
				6, -- 564
				alpha, -- 564
				0 -- 564
			) -- 564
		end -- 564
		texts:put( -- 566
			"xs", -- 566
			"Powered by Dora SSR", -- 566
			w * 0.5, -- 566
			58 + frame.safe.bottom * 0.4, -- 566
			toColor(PALETTE.textDim), -- 566
			0.5, -- 566
			0.5, -- 566
			"Center", -- 566
			1.8, -- 566
			alpha * 0.62, -- 566
			0 -- 566
		) -- 566
	elseif t < 4.25 then -- 566
		local localT = t - 2.2 -- 568
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 569
		local sway = math.sin(localT * 1.1) * 8 -- 570
		drawMistCurve( -- 571
			uiArt, -- 571
			"splash_game_mist", -- 571
			w * 0.5 + sway, -- 571
			h * 0.46, -- 571
			560, -- 571
			110, -- 571
			PALETTE.jadeMist, -- 571
			0.16 * alpha, -- 571
			1 -- 571
		) -- 571
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 572
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 573
		if not uiArt:tryPlace( -- 573
			"brand_game_logo_h", -- 574
			"splash_game_logo", -- 574
			w * 0.5, -- 574
			h * 0.52, -- 574
			logoH * 2.4, -- 574
			logoH, -- 574
			{opacity = alpha, layer = 2} -- 574
		) then -- 574
			texts:put( -- 575
				"title", -- 575
				"向西守望", -- 575
				w * 0.5, -- 575
				h * 0.52, -- 575
				toColor(PALETTE.textBright), -- 575
				0.5, -- 575
				0.5, -- 575
				"Center", -- 575
				8, -- 575
				alpha, -- 575
				0 -- 575
			) -- 575
		end -- 575
	end -- 575
	if t >= 0.35 and t < 4.15 then -- 575
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 580
		local skipText = getActiveTarget():splashSkipHint(frame.mode, frame.layout) -- 581
		texts:put( -- 582
			"xs", -- 582
			skipText, -- 582
			w - 48 - frame.safe.right * 0.6, -- 582
			36 + frame.safe.bottom * 0.4, -- 582
			toColor(PALETTE.textDim), -- 582
			1, -- 582
			0.5, -- 582
			"Right", -- 582
			1.4, -- 582
			hintA, -- 582
			0 -- 582
		) -- 582
	end -- 582
	return {type = "none"} -- 585
end -- 520
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 588
	fillHGradRect( -- 598
		uiDraw, -- 598
		0, -- 598
		0, -- 598
		w * 0.22 + frame.safe.left * 0.5, -- 598
		h, -- 598
		Color(9, 11, 18, 192), -- 598
		Color(9, 11, 18, 116) -- 598
	) -- 598
	fillHGradRect( -- 599
		uiDraw, -- 599
		w * 0.22 + frame.safe.left * 0.5, -- 599
		0, -- 599
		w * 0.28, -- 599
		h, -- 599
		Color(9, 11, 18, 116), -- 599
		Color(9, 11, 18, 0) -- 599
	) -- 599
	fillVGradRect( -- 600
		uiDraw, -- 600
		0, -- 600
		0, -- 600
		w, -- 600
		78, -- 600
		Color(8, 10, 16, 138), -- 600
		Color(8, 10, 16, 0) -- 600
	) -- 600
	local extraH = math.max(0, h - 720) -- 602
	local titleX = 148 + frame.safe.left * 0.6 -- 603
	local topY = h - 104 - frame.safe.top * 0.4 -- 604
	local charStep = 66 -- 605
	local sway = math.sin(self.time * 0.7) * 5 -- 606
	drawMistCurve( -- 607
		uiArt, -- 607
		"title_mist_wisp", -- 607
		titleX + 86 + sway, -- 607
		topY - 122, -- 607
		340, -- 607
		82, -- 607
		PALETTE.jadeMist, -- 607
		0.2, -- 607
		-1 -- 607
	) -- 607
	uiArt:tryPlace( -- 608
		"ink_petal_mist", -- 608
		"title_petals", -- 608
		titleX + 12, -- 608
		topY - 102, -- 608
		230, -- 608
		210, -- 608
		{ -- 608
			color = toColor(PALETTE.inkMist), -- 609
			opacity = 0.4, -- 609
			layer = -1 -- 609
		} -- 609
	) -- 609
	local placedBrandTitle = uiArt:tryPlace( -- 613
		"brand_game_logo_v", -- 613
		"title_brand_v", -- 613
		titleX + 22, -- 613
		topY - 106, -- 613
		240, -- 613
		304, -- 613
		{opacity = 0.98, layer = 3} -- 613
	) -- 613
	if not placedBrandTitle then -- 613
		uiArt:tryPlace( -- 617
			"ink_vstream", -- 617
			"title_vstream", -- 617
			titleX - 48, -- 617
			topY - 100, -- 617
			34, -- 617
			290, -- 617
			{ -- 617
				color = toColor(PALETTE.silkDim), -- 618
				opacity = 0.48, -- 618
				layer = 1 -- 618
			} -- 618
		) -- 618
		local c = 0 -- 620
		do -- 620
			c = 0 -- 621
			while c < #VERTICAL_TITLE do -- 621
				texts:put( -- 622
					"title", -- 623
					VERTICAL_TITLE[c + 1], -- 624
					titleX, -- 625
					topY - c * charStep, -- 626
					toColor(PALETTE.textBright), -- 627
					0.5, -- 628
					0.5, -- 629
					"Center", -- 630
					0, -- 631
					0.98, -- 632
					0.1, -- 633
					Color(8, 10, 16, 210) -- 634
				) -- 634
				c = c + 1 -- 621
			end -- 621
		end -- 621
		drawLoneSeal( -- 637
			uiInkDraw, -- 638
			uiArt, -- 639
			texts, -- 640
			"title_lone_seal", -- 641
			titleX + 46, -- 642
			topY - 3 * charStep + 8, -- 643
			26, -- 644
			52, -- 645
			"守", -- 646
			"望", -- 647
			PALETTE.sealRed, -- 648
			PALETTE.sealText, -- 649
			0.94, -- 650
			4 -- 651
		) -- 651
	end -- 651
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 656
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 657
	local poemStep = 22 -- 658
	local p = 0 -- 659
	do -- 659
		p = 0 -- 660
		while p < #EPIGRAPH_RIGHT do -- 660
			local ch = EPIGRAPH_RIGHT[p + 1] -- 661
			if ch ~= "" then -- 661
				texts:put( -- 663
					"xs", -- 663
					ch, -- 663
					colRightX, -- 663
					topY - 22 - p * poemStep, -- 663
					toColor(PALETTE.textMid), -- 663
					0.5, -- 663
					0.5, -- 663
					"Center", -- 663
					0, -- 663
					0.86, -- 663
					0.08 -- 663
				) -- 663
			end -- 663
			p = p + 1 -- 660
		end -- 660
	end -- 660
	do -- 660
		p = 0 -- 666
		while p < #EPIGRAPH_LEFT do -- 666
			texts:put( -- 667
				"xs", -- 667
				EPIGRAPH_LEFT[p + 1], -- 667
				colLeftX, -- 667
				topY - 68 - p * poemStep, -- 667
				toColor(PALETTE.amberCore), -- 667
				0.5, -- 667
				0.5, -- 667
				"Center", -- 667
				0, -- 667
				0.9, -- 667
				0.08 -- 667
			) -- 667
			p = p + 1 -- 666
		end -- 666
	end -- 666
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 671
		TITLE_ITEMS, -- 673
		function(____, it) return it.id ~= "quit" end -- 673
	) -- 673
	local items = self.hasSession and ({ -- 674
		{id = "continue", zh = "继续游戏"}, -- 675
		table.unpack(baseItems) -- 675
	}) or baseItems -- 675
	if self.selected >= #items then -- 675
		self.selected = 0 -- 678
	end -- 678
	local denseTitle = #items >= 6 -- 680
	local veryDenseTitle = #items >= 7 -- 681
	local menuX = 112 + frame.safe.left * 0.6 -- 682
	local btnW = 280 -- 683
	local btnH = veryDenseTitle and 34 or (denseTitle and 36 or (frame.mode == "touch" and 44 or 40)) -- 684
	local gap = veryDenseTitle and 5 or (denseTitle and 5 or 8) -- 685
	local startY = (veryDenseTitle and 306 or (denseTitle and 274 or 268)) + extraH * 0.35 -- 686
	local boxes = {} -- 687
	local i = 0 -- 688
	do -- 688
		i = 0 -- 689
		while i < #items do -- 689
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 690
			i = i + 1 -- 689
		end -- 689
	end -- 689
	if not self.titleConfirmNewGame then -- 689
		local prevTitleSel = self.selected -- 694
		self.selected = self:verticalSelection(self.selected, boxes, frame) -- 695
		if self.selected ~= prevTitleSel then -- 695
			self:emitSound("hover") -- 697
		end -- 697
	end -- 697
	do -- 697
		i = 0 -- 701
		while i < #items do -- 701
			local by = boxes[i + 1].y -- 702
			local active = not self.titleConfirmNewGame and self.selected == i -- 703
			local cy = by + btnH * 0.5 -- 704
			local shiftX = active and 10 or 0 -- 705
			if active then -- 705
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 708
				drawSilkRibbon( -- 709
					uiDraw, -- 709
					uiArt, -- 709
					"title_rib_red_" .. tostring(i), -- 709
					menuX + 124, -- 709
					cy, -- 709
					290, -- 709
					btnH, -- 709
					PALETTE.rougeSoft, -- 709
					0.52 * breathe, -- 709
					0 -- 709
				) -- 709
				drawHairline( -- 710
					uiInkDraw, -- 710
					uiArt, -- 710
					"title_rib_line_" .. tostring(i), -- 710
					menuX + 114, -- 710
					by + 4, -- 710
					230, -- 710
					PALETTE.silkLine, -- 710
					0.42 * breathe, -- 710
					false, -- 710
					2 -- 710
				) -- 710
				drawBlossomDot( -- 711
					uiInkDraw, -- 711
					uiArt, -- 711
					"title_dot_" .. tostring(i), -- 711
					menuX + 14, -- 711
					cy, -- 711
					15, -- 711
					PALETTE.rouge, -- 711
					0.96, -- 711
					4 -- 711
				) -- 711
				fillRadialGlow( -- 712
					uiGlow, -- 712
					menuX + 14, -- 712
					cy, -- 712
					22, -- 712
					16, -- 712
					toColor(PALETTE.rouge, 28 * breathe), -- 712
					Color(182, 58, 56, 0), -- 712
					10 -- 712
				) -- 712
			else -- 712
				drawBlossomDot( -- 714
					uiInkDraw, -- 714
					uiArt, -- 714
					"title_dot_" .. tostring(i), -- 714
					menuX + 14, -- 714
					cy, -- 714
					8, -- 714
					PALETTE.silkDim, -- 714
					0.4, -- 714
					3 -- 714
				) -- 714
			end -- 714
			texts:put( -- 717
				veryDenseTitle and "sm" or "md", -- 718
				items[i + 1].zh, -- 719
				menuX + 34 + shiftX, -- 720
				cy, -- 721
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 722
				0, -- 723
				0.5, -- 724
				"Left", -- 725
				active and 4 or 2.6, -- 726
				active and 1 or 0.88, -- 727
				0.1 -- 728
			) -- 728
			if items[i + 1].id == "continue" and self.sessionLabel ~= "" then -- 728
				texts:put( -- 731
					"xs", -- 732
					"· " .. self.sessionLabel, -- 733
					menuX + 168 + shiftX, -- 734
					cy, -- 735
					toColor(active and PALETTE.amberCore or PALETTE.textDim), -- 736
					0, -- 737
					0.5, -- 738
					"Left", -- 739
					1.2, -- 740
					active and 0.92 or 0.72, -- 741
					0.08 -- 742
				) -- 742
			end -- 742
			i = i + 1 -- 701
		end -- 701
	end -- 701
	local titleHint = getActiveTarget():titleFooterHint(frame.mode, frame.layout) -- 747
	texts:put( -- 748
		"xs", -- 748
		titleHint, -- 748
		menuX + 12, -- 748
		34 + frame.safe.bottom * 0.45, -- 748
		toColor(PALETTE.textDim), -- 748
		0, -- 748
		0.5, -- 748
		"Left", -- 748
		1.4, -- 748
		0.88, -- 748
		0.08 -- 748
	) -- 748
	local badgeRight = w - frame.safe.right * 0.5 -- 751
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 752
	fillHGradRect( -- 753
		uiDraw, -- 753
		badgeRight - 270, -- 753
		0, -- 753
		270 + frame.safe.right * 0.5, -- 753
		86, -- 753
		Color(8, 10, 16, 0), -- 753
		Color(8, 10, 16, 204) -- 753
	) -- 753
	uiArt:tryPlace( -- 754
		"brand_team_badge", -- 754
		"title_team_badge", -- 754
		badgeRight - 118, -- 754
		badgeY, -- 754
		168, -- 754
		54, -- 754
		{opacity = 0.95, layer = 3} -- 754
	) -- 754
	if self.titleConfirmNewGame then -- 754
		local dlgRes = self:drawConfirmDialog( -- 759
			frame, -- 760
			uiDraw, -- 761
			uiInkDraw, -- 762
			uiArt, -- 763
			texts, -- 764
			w, -- 765
			h, -- 766
			"开启新旅程", -- 767
			"当前已有自动存档，开始新游戏将覆盖自动存档（手动槽位保留）。", -- 768
			"确认开始", -- 769
			"取消返回", -- 770
			self.titleConfirmSel, -- 771
			function(sel) -- 772
				self.titleConfirmSel = sel -- 773
			end -- 772
		) -- 772
		if dlgRes == "confirm" then -- 772
			self.titleConfirmNewGame = false -- 777
			self:emitSound("start") -- 778
			self:resetInput() -- 779
			return {type = "start"} -- 780
		end -- 780
		if dlgRes == "cancel" then -- 780
			self.titleConfirmNewGame = false -- 783
			self:emitSound("back") -- 784
			self:resetInput() -- 785
		end -- 785
		return {type = "none"} -- 787
	end -- 787
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 790
	if hit >= 0 or frame.keys.confirm then -- 790
		local idx = hit >= 0 and hit or self.selected -- 792
		local id = items[idx + 1].id -- 793
		if id == "continue" then -- 793
			self:emitSound("start") -- 794
			return {type = "continue"} -- 794
		end -- 794
		if id == "start" then -- 794
			if self.hasSession then -- 794
				self.titleConfirmNewGame = true -- 797
				self.titleConfirmSel = 1 -- 798
				self:emitSound("confirm") -- 799
				self:resetInput() -- 800
				return {type = "none"} -- 801
			end -- 801
			self:emitSound("start") -- 803
			return {type = "start"} -- 804
		end -- 804
		if id == "chapters" then -- 804
			self:emitSound("confirm") -- 806
			return {type = "openChapters"} -- 806
		end -- 806
		if id == "saves" then -- 806
			self:openSaves(false) -- 808
			self:emitSound("confirm") -- 809
			return {type = "openSaves"} -- 810
		end -- 810
		if id == "settings" then -- 810
			self:openSettings() -- 813
			self:emitSound("confirm") -- 814
			return {type = "openSettings"} -- 815
		end -- 815
		if id == "quit" then -- 815
			self:emitSound("back") -- 817
			return {type = "quit"} -- 817
		end -- 817
		self:emitSound("confirm") -- 818
		return {type = "openControls"} -- 819
	end -- 819
	return {type = "none"} -- 821
end -- 588
function MenuRenderer.prototype.drawConfirmDialog(self, frame, uiDraw, uiInkDraw, uiArt, texts, w, h, heading, message, confirmLabel, cancelLabel, selected, setSelected) -- 825
	if frame.back or frame.rightClick then -- 825
		return "cancel" -- 841
	end -- 841
	local dlgW = math.min(540, w - 120) -- 843
	local dlgH = 224 -- 844
	local dlgX = (w - dlgW) * 0.5 -- 845
	local dlgY = (h - dlgH) * 0.5 -- 846
	local btnW = 166 -- 847
	local btnH = 40 -- 848
	local btnGap = 28 -- 849
	local btnY = dlgY + 28 -- 850
	local btn0X = w * 0.5 - btnW - btnGap * 0.5 -- 851
	local btn1X = w * 0.5 + btnGap * 0.5 -- 852
	local boxes = { -- 853
		Rect(btn0X, btnY, btnW, btnH), -- 853
		Rect(btn1X, btnY, btnW, btnH) -- 853
	} -- 853
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 855
	local cur = selected -- 856
	if frame.click and hit >= 0 then -- 856
		cur = hit -- 858
	elseif frame.keys.left or frame.keys.up then -- 858
		cur = 0 -- 860
	elseif frame.keys.right or frame.keys.down then -- 860
		cur = 1 -- 862
	elseif frame.pointerMoved and hit >= 0 and not frame.keys.confirm then -- 862
		cur = hit -- 864
	end -- 864
	if cur ~= selected then -- 864
		setSelected(cur) -- 867
		self:emitSound("hover") -- 868
	end -- 868
	uiDraw:drawRect( -- 871
		Rect(0, 0, w, h), -- 871
		Color(6, 8, 14, 186) -- 871
	) -- 871
	uiDraw:drawRect( -- 872
		Rect(dlgX, dlgY, dlgW, dlgH), -- 872
		Color(14, 17, 26, 244) -- 872
	) -- 872
	drawFiligreeCorners( -- 873
		uiInkDraw, -- 873
		uiArt, -- 873
		"confirm_dlg_frame", -- 873
		dlgX, -- 873
		dlgY, -- 873
		dlgW, -- 873
		dlgH, -- 873
		PALETTE.silkLine, -- 873
		0.85, -- 873
		28, -- 873
		true, -- 873
		5 -- 873
	) -- 873
	texts:put( -- 874
		"lg", -- 874
		heading, -- 874
		w * 0.5, -- 874
		dlgY + dlgH - 44, -- 874
		toColor(PALETTE.textBright), -- 874
		0.5, -- 874
		0.5, -- 874
		"Center", -- 874
		3, -- 874
		0.98, -- 874
		0.1 -- 874
	) -- 874
	drawHairline( -- 875
		uiInkDraw, -- 875
		uiArt, -- 875
		"confirm_dlg_div", -- 875
		w * 0.5, -- 875
		dlgY + dlgH - 72, -- 875
		dlgW - 84, -- 875
		PALETTE.silkDim, -- 875
		0.56, -- 875
		true, -- 875
		4 -- 875
	) -- 875
	texts:put( -- 876
		"sm", -- 876
		message, -- 876
		w * 0.5, -- 876
		dlgY + dlgH - 110, -- 876
		toColor(PALETTE.textMid), -- 876
		0.5, -- 876
		0.5, -- 876
		"Center", -- 876
		0.8, -- 876
		0.94, -- 876
		0.08 -- 876
	) -- 876
	local labels = {confirmLabel, cancelLabel} -- 878
	local bi = 0 -- 879
	do -- 879
		bi = 0 -- 880
		while bi < 2 do -- 880
			local bx = boxes[bi + 1] -- 881
			local isSel = cur == bi -- 882
			local fillCol = isSel and (bi == 0 and toColor(PALETTE.rougeSoft, 185) or Color(32, 40, 56, 215)) or Color(18, 22, 32, 165) -- 883
			local borderCol = isSel and (bi == 0 and PALETTE.rouge or PALETTE.amberCore) or PALETTE.silkDim -- 886
			uiInkDraw:drawRect( -- 889
				bx, -- 889
				fillCol, -- 889
				1.1, -- 889
				toColor(borderCol, isSel and 235 or 145) -- 889
			) -- 889
			texts:put( -- 890
				"sm", -- 891
				labels[bi + 1], -- 892
				bx.x + bx.width * 0.5, -- 893
				bx.y + bx.height * 0.5, -- 894
				toColor(isSel and PALETTE.textBright or PALETTE.textMid), -- 895
				0.5, -- 896
				0.5, -- 897
				"Center", -- 898
				2, -- 899
				isSel and 1 or 0.84, -- 900
				0.08 -- 901
			) -- 901
			bi = bi + 1 -- 880
		end -- 880
	end -- 880
	if frame.click and hit >= 0 or frame.keys.confirm then -- 880
		return cur == 0 and "confirm" or "cancel" -- 906
	end -- 906
	return "none" -- 908
end -- 825
function MenuRenderer.prototype.drawSavesPanel(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, fromPause, canSave) -- 912
	local backAction = {type = fromPause and "backPause" or "backTitle"} -- 924
	if #self.saveSlots == 0 then -- 924
		self:refreshSaveSlots() -- 926
	end -- 926
	local slots = self.saveSlots -- 928
	if self.saveSelected >= #slots then -- 928
		self.saveSelected = 0 -- 930
	end -- 930
	if self.saveConfirmKind == "" and (frame.back or frame.rightClick) then -- 930
		self:emitSound("back") -- 934
		return backAction -- 935
	end -- 935
	uiDraw:drawRect( -- 938
		Rect(0, 0, w, h), -- 938
		Color(10, 12, 19, 208) -- 938
	) -- 938
	local marginX = math.max( -- 940
		96, -- 940
		56 + math.max(frame.safe.left, frame.safe.right) -- 940
	) -- 940
	local topHeadY = h - 58 - frame.safe.top * 0.35 -- 941
	texts:put( -- 942
		"lg", -- 942
		fromPause and "存取档案" or "读取存档", -- 942
		marginX, -- 942
		topHeadY, -- 942
		toColor(PALETTE.textBright), -- 942
		0, -- 942
		0.5, -- 942
		"Left", -- 942
		4, -- 942
		0.98, -- 942
		0.1 -- 942
	) -- 942
	local subDesc = fromPause and (canSave and "自动存档随进度更新 · 可存入或读取三处手动槽位" or "当前段落仅可读取或清理已有存档") or "便携目录 saves/ · 支持自动存档与三处独立槽位" -- 943
	texts:put( -- 946
		"xs", -- 946
		subDesc, -- 946
		marginX + 168, -- 946
		topHeadY - 2, -- 946
		toColor(PALETTE.amberCore), -- 946
		0, -- 946
		0.5, -- 946
		"Left", -- 946
		1.2, -- 946
		0.86, -- 946
		0.08 -- 946
	) -- 946
	drawHairline( -- 947
		uiInkDraw, -- 947
		uiArt, -- 947
		"saves_top_line", -- 947
		w * 0.5, -- 947
		topHeadY - 30, -- 947
		w - marginX * 2, -- 947
		PALETTE.silkDim, -- 947
		0.6, -- 947
		true, -- 947
		2 -- 947
	) -- 947
	local panelW = math.min(880, w - marginX * 2) -- 949
	local panelX = (w - panelW) * 0.5 -- 950
	local cardH = 92 -- 951
	local cardGap = 16 -- 952
	local firstTop = topHeadY - 58 -- 953
	local cardBoxes = {} -- 954
	local i = 0 -- 955
	do -- 955
		i = 0 -- 956
		while i < #slots do -- 956
			local cyBottom = firstTop - (i + 1) * cardH - i * cardGap -- 957
			cardBoxes[#cardBoxes + 1] = Rect(panelX, cyBottom, panelW, cardH) -- 958
			i = i + 1 -- 956
		end -- 956
	end -- 956
	local function actionsForSlot(slot) -- 961
		local acts = {} -- 962
		if fromPause and canSave and slot.id ~= "auto" then -- 962
			acts[#acts + 1] = {id = "save", zh = slot.exists and "覆盖保存" or "存入此档"} -- 964
		end -- 964
		if slot.exists then -- 964
			acts[#acts + 1] = {id = "load", zh = "读取"} -- 967
			acts[#acts + 1] = {id = "delete", zh = "删除"} -- 968
		end -- 968
		return acts -- 970
	end -- 961
	if self.saveConfirmKind == "" then -- 961
		local prevSel = self.saveSelected -- 974
		self.saveSelected = self:verticalSelection(self.saveSelected, cardBoxes, frame) -- 975
		if self.saveSelected ~= prevSel then -- 975
			self.saveActionSelected = 0 -- 977
			self:emitSound("hover") -- 978
		end -- 978
	end -- 978
	local function slotTitleOf(id) -- 982
		if id == "auto" then -- 982
			return "自动存档" -- 983
		end -- 983
		if id == 1 then -- 983
			return "档案一" -- 984
		end -- 984
		if id == 2 then -- 984
			return "档案二" -- 985
		end -- 985
		return "档案三" -- 986
	end -- 982
	local activeActionBoxes = {} -- 989
	local activeActions = {} -- 990
	do -- 990
		i = 0 -- 992
		while i < #slots do -- 992
			local slot = slots[i + 1] -- 993
			local box = cardBoxes[i + 1] -- 994
			local active = self.saveSelected == i and self.saveConfirmKind == "" -- 995
			local acts = actionsForSlot(slot) -- 996
			if self.saveSelected == i then -- 996
				activeActions = acts -- 998
				if self.saveActionSelected >= #acts then -- 998
					self.saveActionSelected = 0 -- 1000
				end -- 1000
			end -- 1000
			local cardBg = active and Color(22, 26, 38, 224) or Color(13, 16, 24, 182) -- 1004
			local cardBorder = active and PALETTE.rouge or PALETTE.silkDim -- 1005
			uiInkDraw:drawRect( -- 1006
				box, -- 1006
				cardBg, -- 1006
				active and 1.3 or 0.8, -- 1006
				toColor(cardBorder, active and 225 or 120) -- 1006
			) -- 1006
			if active then -- 1006
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 1008
				drawSilkRibbon( -- 1009
					uiDraw, -- 1009
					uiArt, -- 1009
					"save_rib_" .. tostring(i), -- 1009
					panelX + panelW * 0.5, -- 1009
					box.y + box.height * 0.5, -- 1009
					panelW + 10, -- 1009
					box.height - 6, -- 1009
					PALETTE.rougeSoft, -- 1009
					0.24 * breathe, -- 1009
					0 -- 1009
				) -- 1009
				drawBlossomDot( -- 1010
					uiInkDraw, -- 1010
					uiArt, -- 1010
					"save_dot_" .. tostring(i), -- 1010
					box.x + 22, -- 1010
					box.y + box.height - 28, -- 1010
					13, -- 1010
					PALETTE.rouge, -- 1010
					0.96, -- 1010
					4 -- 1010
				) -- 1010
				fillRadialGlow( -- 1011
					uiGlow, -- 1011
					box.x + 22, -- 1011
					box.y + box.height - 28, -- 1011
					18, -- 1011
					14, -- 1011
					toColor(PALETTE.rouge, 24 * breathe), -- 1011
					Color(182, 58, 56, 0), -- 1011
					10 -- 1011
				) -- 1011
			else -- 1011
				drawBlossomDot( -- 1013
					uiInkDraw, -- 1013
					uiArt, -- 1013
					"save_dot_" .. tostring(i), -- 1013
					box.x + 22, -- 1013
					box.y + box.height - 28, -- 1013
					7, -- 1013
					PALETTE.silkDim, -- 1013
					0.48, -- 1013
					3 -- 1013
				) -- 1013
			end -- 1013
			local titleX = box.x + 44 -- 1016
			local titleY = box.y + box.height - 28 -- 1017
			texts:put( -- 1018
				"md", -- 1018
				slotTitleOf(slot.id), -- 1018
				titleX, -- 1018
				titleY, -- 1018
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1018
				0, -- 1018
				0.5, -- 1018
				"Left", -- 1018
				2.2, -- 1018
				active and 1 or 0.88, -- 1018
				0.08 -- 1018
			) -- 1018
			if slot.exists then -- 1018
				local rt = themeOf(slot.roomKey) -- 1021
				local routeZh = slot.route == "soldier" and "周戍线" or (slot.route == "child" and "小满线" or "序章") -- 1022
				local chapTag = (rt.shortNameZh .. " · ") .. routeZh -- 1023
				texts:put( -- 1024
					"sm", -- 1024
					chapTag, -- 1024
					titleX + 118, -- 1024
					titleY, -- 1024
					toColor(slot.route == "soldier" and PALETTE.cyanCore or PALETTE.amberCore), -- 1024
					0, -- 1024
					0.5, -- 1024
					"Left", -- 1024
					1.4, -- 1024
					0.94, -- 1024
					0.08 -- 1024
				) -- 1024
				local parts = {} -- 1026
				parts[#parts + 1] = (("血量 " .. tostring(slot.hp)) .. "/") .. tostring(slot.maxHp) -- 1027
				local dur = formatPlayDuration(slot.playSeconds) -- 1028
				if dur ~= "" then -- 1028
					parts[#parts + 1] = "时长 " .. dur -- 1030
				end -- 1030
				local savedStr = formatSavedAt(slot.savedAt) -- 1032
				if savedStr ~= "" then -- 1032
					parts[#parts + 1] = "保存于 " .. savedStr -- 1034
				end -- 1034
				if slot.recovered then -- 1034
					parts[#parts + 1] = "备份恢复" -- 1037
				end -- 1037
				texts:put( -- 1039
					"xs", -- 1039
					table.concat(parts, "   ·   "), -- 1039
					titleX, -- 1039
					box.y + 26, -- 1039
					toColor(PALETTE.textDim), -- 1039
					0, -- 1039
					0.5, -- 1039
					"Left", -- 1039
					0.8, -- 1039
					0.88, -- 1039
					0.08 -- 1039
				) -- 1039
			elseif slot.status == "corrupt" or slot.status == "unsupported" then -- 1039
				texts:put( -- 1041
					"sm", -- 1041
					slot.status == "corrupt" and "存档已损坏" or "版本不兼容", -- 1041
					titleX + 118, -- 1041
					titleY, -- 1041
					toColor(PALETTE.rouge), -- 1041
					0, -- 1041
					0.5, -- 1041
					"Left", -- 1041
					1.4, -- 1041
					0.94, -- 1041
					0.08 -- 1041
				) -- 1041
				texts:put( -- 1042
					"xs", -- 1042
					"原件已隔离于 backups 目录，可覆盖保存或忽略", -- 1042
					titleX, -- 1042
					box.y + 26, -- 1042
					toColor(PALETTE.textDim), -- 1042
					0, -- 1042
					0.5, -- 1042
					"Left", -- 1042
					0.8, -- 1042
					0.82, -- 1042
					0.08 -- 1042
				) -- 1042
			else -- 1042
				texts:put( -- 1044
					"sm", -- 1044
					"空档", -- 1044
					titleX + 118, -- 1044
					titleY, -- 1044
					toColor(PALETTE.textDim), -- 1044
					0, -- 1044
					0.5, -- 1044
					"Left", -- 1044
					1.4, -- 1044
					0.72, -- 1044
					0.08 -- 1044
				) -- 1044
				local emptyTip = slot.id == "auto" and "推进剧情、切房或暂停时自动记录" or (fromPause and canSave and "按回车或点击右侧「存入此档」保存当前进度" or "游玩中可在暂歇菜单手动保存") -- 1045
				texts:put( -- 1048
					"xs", -- 1048
					emptyTip, -- 1048
					titleX, -- 1048
					box.y + 26, -- 1048
					toColor(PALETTE.textDim), -- 1048
					0, -- 1048
					0.5, -- 1048
					"Left", -- 1048
					0.8, -- 1048
					0.7, -- 1048
					0.08 -- 1048
				) -- 1048
			end -- 1048
			local btnW = 88 -- 1052
			local btnH = 30 -- 1053
			local btnGap = 8 -- 1054
			local totalActW = #acts > 0 and #acts * btnW + (#acts - 1) * btnGap or 0 -- 1055
			local actStartX = box.x + box.width - 18 - totalActW -- 1056
			local actY = box.y + (box.height - btnH) * 0.5 -- 1057
			local rowBtnBoxes = {} -- 1058
			local ai = 0 -- 1059
			do -- 1059
				ai = 0 -- 1060
				while ai < #acts do -- 1060
					local bx = Rect(actStartX + ai * (btnW + btnGap), actY, btnW, btnH) -- 1061
					rowBtnBoxes[#rowBtnBoxes + 1] = bx -- 1062
					local btnFocused = active and self.saveActionSelected == ai -- 1063
					local btnHover = self.saveConfirmKind == "" and frame.inside and bx:containsPoint(frame.pointer) -- 1064
					local highlight = btnFocused or btnHover -- 1065
					local isDel = acts[ai + 1].id == "delete" -- 1066
					local bg = highlight and (isDel and Color(118, 36, 36, 210) or toColor(PALETTE.rougeSoft, 195)) or Color(18, 22, 32, 168) -- 1067
					local bd = highlight and (isDel and PALETTE.rouge or PALETTE.amberCore) or PALETTE.silkDim -- 1070
					uiInkDraw:drawRect( -- 1073
						bx, -- 1073
						bg, -- 1073
						1, -- 1073
						toColor(bd, highlight and 235 or 135) -- 1073
					) -- 1073
					texts:put( -- 1074
						"xs", -- 1075
						acts[ai + 1].zh, -- 1076
						bx.x + bx.width * 0.5, -- 1077
						bx.y + bx.height * 0.5, -- 1078
						toColor(highlight and PALETTE.textBright or PALETTE.textMid), -- 1079
						0.5, -- 1080
						0.5, -- 1081
						"Center", -- 1082
						0.8, -- 1083
						highlight and 1 or 0.86, -- 1084
						0.08 -- 1085
					) -- 1085
					ai = ai + 1 -- 1060
				end -- 1060
			end -- 1060
			if self.saveSelected == i then -- 1060
				activeActionBoxes = rowBtnBoxes -- 1089
			end -- 1089
			i = i + 1 -- 992
		end -- 992
	end -- 992
	local backX = marginX -- 1093
	local backY = 38 + frame.safe.bottom * 0.45 -- 1094
	local backBox = Rect(backX - 6, backY - 6, 210, 44) -- 1095
	local backHover = self.saveConfirmKind == "" and frame.inside and backBox:containsPoint(frame.pointer) -- 1096
	drawSilkKeycap( -- 1097
		uiInkDraw, -- 1097
		texts, -- 1097
		backX, -- 1097
		backY + 4, -- 1097
		52, -- 1097
		24, -- 1097
		"ESC", -- 1097
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1097
		0.92, -- 1097
		backHover -- 1097
	) -- 1097
	texts:put( -- 1098
		"sm", -- 1098
		fromPause and "返回暂停" or "返回标题", -- 1098
		backX + 64, -- 1098
		backY + 16, -- 1098
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1098
		0, -- 1098
		0.5, -- 1098
		"Left", -- 1098
		1.8, -- 1098
		0.9, -- 1098
		0.08 -- 1098
	) -- 1098
	texts:put( -- 1099
		"xs", -- 1099
		"上下选槽位   ·   左右选动作   ·   回车或点击确认", -- 1099
		w - marginX, -- 1099
		backY + 16, -- 1099
		toColor(PALETTE.textDim), -- 1099
		1, -- 1099
		0.5, -- 1099
		"Right", -- 1099
		1.2, -- 1099
		0.78, -- 1099
		0.08 -- 1099
	) -- 1099
	if self.saveConfirmKind ~= "" then -- 1099
		local isDel = self.saveConfirmKind == "delete" -- 1102
		local dlgRes = self:drawConfirmDialog( -- 1103
			frame, -- 1104
			uiDraw, -- 1105
			uiInkDraw, -- 1106
			uiArt, -- 1107
			texts, -- 1108
			w, -- 1109
			h, -- 1110
			isDel and "删除存档" or "覆盖存档", -- 1111
			isDel and ("确定删除「" .. slotTitleOf(self.saveConfirmSlot)) .. "」？删除后无法恢复。" or ("确定覆盖「" .. slotTitleOf(self.saveConfirmSlot)) .. "」？原存档进度将被替换。", -- 1112
			isDel and "确认删除" or "确认覆盖", -- 1115
			"取消", -- 1116
			self.saveConfirmSel, -- 1117
			function(sel) -- 1118
				self.saveConfirmSel = sel -- 1119
			end -- 1118
		) -- 1118
		if dlgRes == "confirm" then -- 1118
			local kind = self.saveConfirmKind -- 1123
			local slotId = self.saveConfirmSlot -- 1124
			self.saveConfirmKind = "" -- 1125
			self:resetInput() -- 1126
			self:emitSound(kind == "delete" and "back" or "confirm") -- 1127
			return {type = kind == "delete" and "deleteSlot" or "saveSlot", slot = slotId} -- 1128
		end -- 1128
		if dlgRes == "cancel" then -- 1128
			self.saveConfirmKind = "" -- 1131
			self:emitSound("back") -- 1132
			self:resetInput() -- 1133
		end -- 1133
		return {type = "none"} -- 1135
	end -- 1135
	if frame.click and backHover then -- 1135
		self:emitSound("back") -- 1139
		return backAction -- 1140
	end -- 1140
	if #activeActions > 0 then -- 1140
		local hitAct = hitIndex(activeActionBoxes, frame.pointer, frame.inside) -- 1144
		if frame.pointerMoved and hitAct >= 0 and not frame.keys.confirm and hitAct ~= self.saveActionSelected then -- 1144
			self.saveActionSelected = hitAct -- 1146
			self:emitSound("hover") -- 1147
		end -- 1147
		if frame.keys.left then -- 1147
			self.saveActionSelected = (self.saveActionSelected + #activeActions - 1) % #activeActions -- 1150
			self:emitSound("hover") -- 1151
		elseif frame.keys.right then -- 1151
			self.saveActionSelected = (self.saveActionSelected + 1) % #activeActions -- 1153
			self:emitSound("hover") -- 1154
		end -- 1154
		local triggerIdx = -1 -- 1157
		if frame.click and hitAct >= 0 then -- 1157
			self.saveActionSelected = hitAct -- 1159
			triggerIdx = hitAct -- 1160
		elseif frame.keys.confirm then -- 1160
			triggerIdx = self.saveActionSelected -- 1162
		end -- 1162
		if triggerIdx >= 0 and triggerIdx < #activeActions then -- 1162
			local chosen = activeActions[triggerIdx + 1] -- 1166
			local slot = slots[self.saveSelected + 1] -- 1167
			if chosen.id == "load" then -- 1167
				self:emitSound("start") -- 1169
				self:resetInput() -- 1170
				return {type = "loadSlot", slot = slot.id} -- 1171
			end -- 1171
			if chosen.id == "save" then -- 1171
				if slot.exists then -- 1171
					self.saveConfirmKind = "overwrite" -- 1175
					self.saveConfirmSlot = slot.id -- 1176
					self.saveConfirmSel = 1 -- 1177
					self:emitSound("confirm") -- 1178
					self:resetInput() -- 1179
					return {type = "none"} -- 1180
				end -- 1180
				self:emitSound("confirm") -- 1182
				self:resetInput() -- 1183
				return {type = "saveSlot", slot = slot.id} -- 1184
			end -- 1184
			if chosen.id == "delete" then -- 1184
				self.saveConfirmKind = "delete" -- 1187
				self.saveConfirmSlot = slot.id -- 1188
				self.saveConfirmSel = 1 -- 1189
				self:emitSound("confirm") -- 1190
				self:resetInput() -- 1191
				return {type = "none"} -- 1192
			end -- 1192
		end -- 1192
	end -- 1192
	return {type = "none"} -- 1197
end -- 912
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1200
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 1210
	if frame.back or frame.rightClick then -- 1210
		self:emitSound("back") -- 1212
		return back -- 1213
	end -- 1213
	local extraH = math.max(0, h - 720) -- 1216
	local marginX = math.max( -- 1217
		96, -- 1217
		56 + math.max(frame.safe.left, frame.safe.right) -- 1217
	) -- 1217
	local splitTrack = #CHAPTERS > 8 -- 1218
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 1219
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 1220
	local rowGap = 68 -- 1221
	local trackX0 = marginX + 34 -- 1222
	local trackX1 = w - marginX - 34 -- 1223
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 1224
	local stationBoxes = {} -- 1226
	local s = 0 -- 1227
	do -- 1227
		s = 0 -- 1228
		while s < #CHAPTERS do -- 1228
			local sx = trackX0 + s % perRow * stepX -- 1229
			local sy = trackY - math.floor(s / perRow) * rowGap -- 1230
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 1231
			s = s + 1 -- 1228
		end -- 1228
	end -- 1228
	local prevSelected = self.chapterSelected -- 1234
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 1235
	local keys = frame.keys -- 1236
	if frame.click and hitStation >= 0 then -- 1236
		self.chapterSelected = hitStation -- 1238
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 1238
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 1240
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 1241
	elseif keys.down and self.chapterSelected < perRow then -- 1241
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 1243
	elseif keys.up and self.chapterSelected >= perRow then -- 1243
		self.chapterSelected = self.chapterSelected - perRow -- 1245
	elseif frame.wheelY > 0.1 or frame.wheelY < -0.1 then -- 1245
		local step = frame.wheelY > 0.1 and -1 or 1 -- 1247
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 1248
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 1248
		self.chapterSelected = hitStation -- 1250
	end -- 1250
	if self.chapterSelected ~= prevSelected then -- 1250
		self:emitSound("hover") -- 1253
	end -- 1253
	uiDraw:drawRect( -- 1256
		Rect(0, 0, w, h), -- 1256
		Color(10, 12, 19, 198) -- 1256
	) -- 1256
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 1258
	texts:put( -- 1259
		"banner", -- 1259
		"选择章节", -- 1259
		marginX, -- 1259
		topHeadY, -- 1259
		toColor(PALETTE.textBright), -- 1259
		0, -- 1259
		0.5, -- 1259
		"Left", -- 1259
		4.5, -- 1259
		0.96, -- 1259
		0.1 -- 1259
	) -- 1259
	drawHairline( -- 1260
		uiInkDraw, -- 1260
		uiArt, -- 1260
		"chap_top_line", -- 1260
		w * 0.5, -- 1260
		topHeadY - 34, -- 1260
		w - marginX * 2, -- 1260
		PALETTE.silkDim, -- 1260
		0.6, -- 1260
		true, -- 1260
		2 -- 1260
	) -- 1260
	local activeEntry = CHAPTERS[self.chapterSelected + 1] -- 1262
	local activeRoom = activeEntry.room -- 1263
	local theme = themeOf(activeRoom.key) -- 1264
	local activeTitleZh = activeEntry.titleOverride or theme.titleZh -- 1265
	local activeLineTag = activeEntry.lineTagOverride or theme.lineTag -- 1266
	local activeWhisper = activeEntry.whisperOverride or theme.introWhisper -- 1267
	local winX = marginX -- 1268
	local winY = 266 + extraH * 0.44 -- 1269
	local winW = math.min( -- 1270
		520, -- 1270
		math.max(360, (w - marginX * 2) * 0.46) -- 1270
	) -- 1270
	local winH = 296 -- 1271
	local winBox = Rect(winX, winY, winW, winH) -- 1272
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 1273
	uiArt:tryPlace( -- 1275
		"ink_frame_mask", -- 1275
		"chap_win_shadow", -- 1275
		winX + winW * 0.5, -- 1275
		winY + winH * 0.5, -- 1275
		winW + 40, -- 1275
		winH + 34, -- 1275
		{ -- 1275
			color = toColor(PALETTE.inkVoid), -- 1276
			opacity = 0.88, -- 1276
			layer = -2 -- 1276
		} -- 1276
	) -- 1276
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 1278
	uiArt:tryPlace( -- 1279
		bgSlot, -- 1279
		"chap_win_art", -- 1279
		winX + winW * 0.5, -- 1279
		winY + 4, -- 1279
		winW - 8, -- 1279
		winH - 8, -- 1279
		{opacity = 0.92, layer = -1} -- 1279
	) -- 1279
	fillVGradRect( -- 1282
		uiInkDraw, -- 1282
		winX, -- 1282
		winY, -- 1282
		winW, -- 1282
		56, -- 1282
		Color(10, 12, 19, 200), -- 1282
		Color(10, 12, 19, 0) -- 1282
	) -- 1282
	fillVGradRect( -- 1283
		uiInkDraw, -- 1283
		winX, -- 1283
		winY + winH - 36, -- 1283
		winW, -- 1283
		36, -- 1283
		Color(10, 12, 19, 0), -- 1283
		Color(10, 12, 19, 130) -- 1283
	) -- 1283
	fillHGradRect( -- 1284
		uiInkDraw, -- 1284
		winX, -- 1284
		winY, -- 1284
		34, -- 1284
		winH, -- 1284
		Color(10, 12, 19, 135), -- 1284
		Color(10, 12, 19, 0) -- 1284
	) -- 1284
	fillHGradRect( -- 1285
		uiInkDraw, -- 1285
		winX + winW - 34, -- 1285
		winY, -- 1285
		34, -- 1285
		winH, -- 1285
		Color(10, 12, 19, 0), -- 1285
		Color(10, 12, 19, 135) -- 1285
	) -- 1285
	drawFiligreeCorners( -- 1286
		uiInkDraw, -- 1286
		uiArt, -- 1286
		"chap_win_frame", -- 1286
		winX, -- 1286
		winY, -- 1286
		winW, -- 1286
		winH, -- 1286
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 1286
		winHover and 0.92 or 0.72, -- 1286
		34, -- 1286
		true, -- 1286
		3 -- 1286
	) -- 1286
	texts:put( -- 1288
		"xs", -- 1288
		(theme.actCode .. "  ·  ") .. activeLineTag, -- 1288
		winX + 20, -- 1288
		winY + 22, -- 1288
		toColor(PALETTE.textMid), -- 1288
		0, -- 1288
		0.5, -- 1288
		"Left", -- 1288
		1.8, -- 1288
		0.9, -- 1288
		0.08 -- 1288
	) -- 1288
	local infoX = winX + winW + 40 -- 1290
	local infoW = math.max(240, w - marginX - infoX) -- 1291
	local infoCenterY = winY + winH * 0.5 -- 1292
	drawMistCurve( -- 1293
		uiArt, -- 1293
		"chap_info_mist", -- 1293
		infoX + infoW * 0.5, -- 1293
		infoCenterY + 36, -- 1293
		math.min(420, infoW + 24), -- 1293
		88, -- 1293
		theme.accent, -- 1293
		0.22, -- 1293
		-1 -- 1293
	) -- 1293
	local volCol = activeLineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 1295
	texts:put( -- 1296
		"xs", -- 1296
		theme.volumeTagZh, -- 1296
		infoX, -- 1296
		winY + winH - 44, -- 1296
		toColor(volCol), -- 1296
		0, -- 1296
		0.5, -- 1296
		"Left", -- 1296
		2.8, -- 1296
		0.92, -- 1296
		0.08 -- 1296
	) -- 1296
	local sep = " · " -- 1298
	local sIdx = (string.find(activeTitleZh, sep, nil, true) or 0) - 1 -- 1299
	local titleY = winY + winH - 98 -- 1300
	if theme.backdropKey ~= nil then -- 1300
		texts:put( -- 1302
			"lg", -- 1302
			activeTitleZh, -- 1302
			infoX, -- 1302
			titleY, -- 1302
			toColor(PALETTE.textBright) -- 1302
		) -- 1302
	elseif sIdx > 0 then -- 1302
		local leftPart = __TS__StringSlice(activeTitleZh, 0, sIdx) -- 1304
		local rightPart = __TS__StringSlice(activeTitleZh, sIdx + #sep) -- 1305
		local lw = visualTextWidth(leftPart, 40) -- 1306
		texts:put( -- 1307
			"banner", -- 1307
			leftPart, -- 1307
			infoX, -- 1307
			titleY, -- 1307
			toColor(PALETTE.textBright), -- 1307
			0, -- 1307
			0.5, -- 1307
			"Left", -- 1307
			2, -- 1307
			1, -- 1307
			0.1 -- 1307
		) -- 1307
		drawBlossomDot( -- 1308
			uiInkDraw, -- 1308
			uiArt, -- 1308
			"chap_title_dot", -- 1308
			infoX + lw + 16, -- 1308
			titleY - 2, -- 1308
			11, -- 1308
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 1308
			0.9, -- 1308
			4 -- 1308
		) -- 1308
		texts:put( -- 1309
			"banner", -- 1309
			rightPart, -- 1309
			infoX + lw + 32, -- 1309
			titleY, -- 1309
			toColor(PALETTE.textBright), -- 1309
			0, -- 1309
			0.5, -- 1309
			"Left", -- 1309
			2, -- 1309
			1, -- 1309
			0.1 -- 1309
		) -- 1309
	else -- 1309
		texts:put( -- 1311
			"banner", -- 1311
			activeTitleZh, -- 1311
			infoX, -- 1311
			titleY, -- 1311
			toColor(PALETTE.textBright), -- 1311
			0, -- 1311
			0.5, -- 1311
			"Left", -- 1311
			2.4, -- 1311
			1, -- 1311
			0.1 -- 1311
		) -- 1311
	end -- 1311
	drawHairline( -- 1314
		uiInkDraw, -- 1314
		uiArt, -- 1314
		"chap_info_line", -- 1314
		infoX + math.min(185, infoW * 0.5), -- 1314
		titleY - 36, -- 1314
		math.min(370, infoW), -- 1314
		PALETTE.silkDim, -- 1314
		0.58, -- 1314
		false, -- 1314
		2 -- 1314
	) -- 1314
	texts:put( -- 1315
		"sm", -- 1315
		activeWhisper, -- 1315
		infoX, -- 1315
		titleY - 72, -- 1315
		toColor(PALETTE.textMid), -- 1315
		0, -- 1315
		0.5, -- 1315
		"Left", -- 1315
		0.8, -- 1315
		0.94, -- 1315
		0.08 -- 1315
	) -- 1315
	local goX = infoX -- 1317
	local goY = winY + 26 -- 1318
	local goW = 220 -- 1319
	local goH = 42 -- 1320
	local goBox = Rect(goX, goY, goW, goH) -- 1321
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 1322
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1323
	drawSilkRibbon( -- 1324
		uiDraw, -- 1324
		uiArt, -- 1324
		"chap_go_rib", -- 1324
		goX + 106, -- 1324
		goY + 21, -- 1324
		250, -- 1324
		40, -- 1324
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 1324
		(goHover and 0.68 or 0.46) * breathe, -- 1324
		0 -- 1324
	) -- 1324
	drawHairline( -- 1325
		uiInkDraw, -- 1325
		uiArt, -- 1325
		"chap_go_line", -- 1325
		goX + 94, -- 1325
		goY + 3, -- 1325
		196, -- 1325
		PALETTE.silkLine, -- 1325
		goHover and 0.68 or 0.4, -- 1325
		false, -- 1325
		2 -- 1325
	) -- 1325
	drawBlossomDot( -- 1326
		uiInkDraw, -- 1326
		uiArt, -- 1326
		"chap_go_dot", -- 1326
		goX + 14, -- 1326
		goY + 21, -- 1326
		14, -- 1326
		PALETTE.rouge, -- 1326
		0.96, -- 1326
		4 -- 1326
	) -- 1326
	texts:put( -- 1327
		"md", -- 1327
		"入此卷章", -- 1327
		goX + 34, -- 1327
		goY + 21, -- 1327
		toColor(PALETTE.textBright), -- 1327
		0, -- 1327
		0.5, -- 1327
		"Left", -- 1327
		3.8, -- 1327
		1, -- 1327
		0.1 -- 1327
	) -- 1327
	local chapConfirmTag = getActiveTarget():keyTagFor("confirm", frame.mode, frame.layout) -- 1328
	texts:put( -- 1329
		"xs", -- 1329
		chapConfirmTag, -- 1329
		goX + 156, -- 1329
		goY + 21, -- 1329
		toColor(PALETTE.textDim), -- 1329
		0, -- 1329
		0.5, -- 1329
		"Left", -- 1329
		1, -- 1329
		0.82, -- 1329
		0.08 -- 1329
	) -- 1329
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 1331
	local veilH = splitTrack and 156 or 126 -- 1332
	drawSilkVeil( -- 1333
		uiDraw, -- 1333
		uiArt, -- 1333
		"chap_track_veil", -- 1333
		w * 0.5, -- 1333
		veilCenterY, -- 1333
		w - marginX * 1.1, -- 1333
		veilH, -- 1333
		PALETTE.inkWash, -- 1333
		0.72, -- 1333
		-2 -- 1333
	) -- 1333
	drawMistCurve( -- 1334
		uiArt, -- 1334
		"chap_track_mist", -- 1334
		w * 0.5, -- 1334
		trackY, -- 1334
		trackX1 - trackX0 + 160, -- 1334
		74, -- 1334
		PALETTE.inkMist, -- 1334
		0.62, -- 1334
		-1 -- 1334
	) -- 1334
	uiInkDraw:drawSegment( -- 1335
		Vec2(trackX0, trackY), -- 1335
		Vec2(trackX1, trackY), -- 1335
		0.9, -- 1335
		toColor(PALETTE.silkDim, 145) -- 1335
	) -- 1335
	if splitTrack then -- 1335
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 1338
		uiInkDraw:drawSegment( -- 1339
			Vec2(trackX0, trackY - rowGap), -- 1339
			Vec2(lastX, trackY - rowGap), -- 1339
			0.9, -- 1339
			toColor(PALETTE.silkDim, 145) -- 1339
		) -- 1339
	else -- 1339
		local midDivX = trackX0 + stepX * 3.5 -- 1341
		uiInkDraw:drawSegment( -- 1342
			Vec2(midDivX, trackY - 12), -- 1342
			Vec2(midDivX, trackY + 12), -- 1342
			0.8, -- 1342
			toColor(PALETTE.silkDim, 120) -- 1342
		) -- 1342
		texts:put( -- 1343
			"xs", -- 1343
			"上卷 · 孤城护童", -- 1343
			trackX0 + stepX * 1.5, -- 1343
			trackY + 52, -- 1343
			toColor(PALETTE.cyan), -- 1343
			0.5, -- 1343
			0.5, -- 1343
			"Center", -- 1343
			2.2, -- 1343
			0.88, -- 1343
			0.08 -- 1343
		) -- 1343
		texts:put( -- 1344
			"xs", -- 1344
			"下卷 · 独赴北塔", -- 1344
			trackX0 + stepX * 5.5, -- 1344
			trackY + 52, -- 1344
			toColor(PALETTE.amber), -- 1344
			0.5, -- 1344
			0.5, -- 1344
			"Center", -- 1344
			2.2, -- 1344
			0.88, -- 1344
			0.08 -- 1344
		) -- 1344
	end -- 1344
	local i = 0 -- 1347
	do -- 1347
		i = 0 -- 1348
		while i < #CHAPTERS do -- 1348
			local box = stationBoxes[i + 1] -- 1349
			local sx = box.x + box.width * 0.5 -- 1350
			local sy = box.y + box.height * 0.5 -- 1351
			local entry = CHAPTERS[i + 1] -- 1352
			local rt = themeOf(entry.room.key) -- 1353
			local entryLineTag = entry.lineTagOverride or rt.lineTag -- 1354
			local entryShortName = entry.shortNameOverride or rt.shortNameZh -- 1355
			local active = self.chapterSelected == i -- 1356
			local nodeCol = active and PALETTE.rouge or (entryLineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 1357
			if active then -- 1357
				fillRadialGlow( -- 1360
					uiGlow, -- 1360
					sx, -- 1360
					sy, -- 1360
					26, -- 1360
					26, -- 1360
					toColor(PALETTE.rouge, 36 * breathe), -- 1360
					Color(182, 58, 56, 0), -- 1360
					12 -- 1360
				) -- 1360
				uiArt:tryPlace( -- 1361
					"ink_enso_fine", -- 1361
					"chap_st_ring_" .. tostring(i), -- 1361
					sx, -- 1361
					sy, -- 1361
					32, -- 1361
					32, -- 1361
					{ -- 1361
						color = toColor(PALETTE.silkLine), -- 1362
						opacity = 0.78, -- 1362
						angle = self.time * 18, -- 1362
						layer = 3 -- 1362
					} -- 1362
				) -- 1362
				drawBlossomDot( -- 1364
					uiInkDraw, -- 1364
					uiArt, -- 1364
					"chap_st_dot_" .. tostring(i), -- 1364
					sx, -- 1364
					sy, -- 1364
					17, -- 1364
					PALETTE.rouge, -- 1364
					0.98, -- 1364
					4 -- 1364
				) -- 1364
			else -- 1364
				uiArt:tryPlace( -- 1366
					"ink_enso_fine", -- 1366
					"chap_st_ring_" .. tostring(i), -- 1366
					sx, -- 1366
					sy, -- 1366
					16, -- 1366
					16, -- 1366
					{ -- 1366
						color = toColor(nodeCol), -- 1367
						opacity = 0.62, -- 1367
						layer = 3 -- 1367
					} -- 1367
				) -- 1367
				drawBlossomDot( -- 1369
					uiInkDraw, -- 1369
					uiArt, -- 1369
					"chap_st_dot_" .. tostring(i), -- 1369
					sx, -- 1369
					sy, -- 1369
					7, -- 1369
					PALETTE.silkLine, -- 1369
					0.72, -- 1369
					4 -- 1369
				) -- 1369
			end -- 1369
			if not splitTrack then -- 1369
				texts:put( -- 1373
					"xs", -- 1373
					rt.numeralZh, -- 1373
					sx, -- 1373
					sy + 25, -- 1373
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 1373
					0.5, -- 1373
					0.5, -- 1373
					"Center", -- 1373
					0, -- 1373
					active and 1 or 0.88, -- 1373
					0.08 -- 1373
				) -- 1373
			end -- 1373
			texts:put( -- 1375
				"xs", -- 1375
				entryShortName, -- 1375
				sx, -- 1375
				sy - 26, -- 1375
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1375
				0.5, -- 1375
				0.5, -- 1375
				"Center", -- 1375
				1, -- 1375
				active and 1 or 0.84, -- 1375
				0.08 -- 1375
			) -- 1375
			i = i + 1 -- 1348
		end -- 1348
	end -- 1348
	local backX = marginX -- 1378
	local backY = 40 + frame.safe.bottom * 0.45 -- 1379
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 1380
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 1381
	local chapBackTag = getActiveTarget():keyTagFor("back", frame.mode, frame.layout) -- 1382
	local chapFooter = getActiveTarget():chapterFooterHint(frame.mode, chapConfirmTag) -- 1383
	drawSilkKeycap( -- 1384
		uiInkDraw, -- 1384
		texts, -- 1384
		backX, -- 1384
		backY + 5, -- 1384
		48, -- 1384
		24, -- 1384
		chapBackTag, -- 1384
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1384
		0.92, -- 1384
		backHover -- 1384
	) -- 1384
	texts:put( -- 1385
		"sm", -- 1385
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 1385
		backX + 60, -- 1385
		backY + 17, -- 1385
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1385
		0, -- 1385
		0.5, -- 1385
		"Left", -- 1385
		1.8, -- 1385
		0.9, -- 1385
		0.08 -- 1385
	) -- 1385
	texts:put( -- 1386
		"xs", -- 1386
		chapFooter, -- 1386
		w - marginX, -- 1386
		backY + 17, -- 1386
		toColor(PALETTE.textDim), -- 1386
		1, -- 1386
		0.5, -- 1386
		"Right", -- 1386
		1.2, -- 1386
		0.75, -- 1386
		0.08 -- 1386
	) -- 1386
	if frame.click and backHover then -- 1386
		self:emitSound("back") -- 1389
		return back -- 1390
	end -- 1390
	local ____temp_2 -- 1393
	if frame.mode == "touch" then -- 1393
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 1394
	else -- 1394
		____temp_2 = hitStation >= 0 -- 1395
	end -- 1395
	local stationConfirmed = ____temp_2 -- 1393
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 1393
		self:emitSound("start") -- 1397
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex, route = CHAPTERS[self.chapterSelected + 1].route} -- 1398
	end -- 1398
	return {type = "none"} -- 1404
end -- 1200
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 1408
	if backLabel == nil then -- 1408
		backLabel = "返回标题" -- 1417
	end -- 1417
	local target = getActiveTarget() -- 1419
	local tabs = target.controlsGuideTabs -- 1420
	local hasMultipleTabs = #tabs > 1 -- 1421
	if not self.controlsTabManual or __TS__ArrayFindIndex( -- 1421
		tabs, -- 1422
		function(____, t) return t.mode == self.controlsTab end -- 1422
	) < 0 then -- 1422
		self.controlsTab = __TS__ArrayFindIndex( -- 1423
			tabs, -- 1423
			function(____, t) return t.mode == frame.mode end -- 1423
		) >= 0 and frame.mode or tabs[1].mode -- 1423
	end -- 1423
	local marginX = math.max( -- 1425
		96, -- 1425
		56 + math.max(frame.safe.left, frame.safe.right) -- 1425
	) -- 1425
	local tabW = 92 -- 1426
	local tabH = 28 -- 1427
	local tabGap = 10 -- 1428
	local tabBoxes = {} -- 1429
	local hitTab = -1 -- 1430
	if hasMultipleTabs then -- 1430
		local tabStartX = w - marginX - (tabW * #tabs + tabGap * (#tabs - 1)) -- 1432
		local tabY = h - 82 - frame.safe.top * 0.35 -- 1433
		local k = 0 -- 1434
		do -- 1434
			k = 0 -- 1435
			while k < #tabs do -- 1435
				tabBoxes[#tabBoxes + 1] = Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH) -- 1436
				k = k + 1 -- 1435
			end -- 1435
		end -- 1435
		hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 1438
		if frame.click and hitTab >= 0 then -- 1438
			if self.controlsTab ~= tabs[hitTab + 1].mode then -- 1438
				self:emitSound("toggle") -- 1441
			end -- 1441
			self.controlsTab = tabs[hitTab + 1].mode -- 1443
			self.controlsTabManual = true -- 1444
		elseif frame.keys.left or frame.prevTab then -- 1444
			local cur = __TS__ArrayFindIndex( -- 1446
				tabs, -- 1446
				function(____, t) return t.mode == self.controlsTab end -- 1446
			) -- 1446
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + #tabs - 1) % #tabs + 1].mode -- 1447
			self.controlsTabManual = true -- 1448
			self:emitSound("toggle") -- 1449
		elseif frame.keys.right or frame.nextTab then -- 1449
			local cur = __TS__ArrayFindIndex( -- 1451
				tabs, -- 1451
				function(____, t) return t.mode == self.controlsTab end -- 1451
			) -- 1451
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + 1) % #tabs + 1].mode -- 1452
			self.controlsTabManual = true -- 1453
			self:emitSound("toggle") -- 1454
		end -- 1454
	end -- 1454
	local backX = marginX -- 1458
	local backY = 40 + frame.safe.bottom * 0.45 -- 1459
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 1460
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 1461
	if frame.back or frame.rightClick or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 1461
		self:emitSound("back") -- 1463
		return {type = "backTitle"} -- 1464
	end -- 1464
	uiDraw:drawRect( -- 1466
		Rect(0, 0, w, h), -- 1466
		Color(10, 12, 19, 204) -- 1466
	) -- 1466
	local guide = target:controlsGuideRows(self.controlsTab) -- 1468
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 1469
	texts:put( -- 1470
		"banner", -- 1470
		"执器要诀", -- 1470
		marginX, -- 1470
		topHeadY, -- 1470
		toColor(PALETTE.textBright), -- 1470
		0, -- 1470
		0.5, -- 1470
		"Left", -- 1470
		4.5, -- 1470
		0.96, -- 1470
		0.1 -- 1470
	) -- 1470
	texts:put( -- 1471
		"xs", -- 1471
		guide.subtitle, -- 1471
		marginX + 196, -- 1471
		topHeadY - 4, -- 1471
		toColor(PALETTE.textDim), -- 1471
		0, -- 1471
		0.5, -- 1471
		"Left", -- 1471
		1.8, -- 1471
		0.85, -- 1471
		0.08 -- 1471
	) -- 1471
	drawHairline( -- 1472
		uiInkDraw, -- 1472
		uiArt, -- 1472
		"ctrl_top_line", -- 1472
		w * 0.5, -- 1472
		topHeadY - 34, -- 1472
		w - marginX * 2, -- 1472
		PALETTE.silkDim, -- 1472
		0.6, -- 1472
		true, -- 1472
		2 -- 1472
	) -- 1472
	if hasMultipleTabs then -- 1472
		local ti = 0 -- 1475
		do -- 1475
			ti = 0 -- 1476
			while ti < #tabBoxes do -- 1476
				local tb = tabBoxes[ti + 1] -- 1477
				local activeTab = self.controlsTab == tabs[ti + 1].mode -- 1478
				local hoverTab = hitTab == ti -- 1479
				uiInkDraw:drawRect( -- 1480
					tb, -- 1481
					activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 1482
					0.9, -- 1483
					toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 1484
				) -- 1484
				texts:put( -- 1486
					"xs", -- 1487
					tabs[ti + 1].label, -- 1488
					tb.x + tb.width * 0.5, -- 1489
					tb.y + tb.height * 0.5, -- 1490
					toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 1491
					0.5, -- 1492
					0.5, -- 1493
					"Center", -- 1494
					0.8, -- 1495
					activeTab and 0.98 or 0.82, -- 1496
					0.08 -- 1497
				) -- 1497
				ti = ti + 1 -- 1476
			end -- 1476
		end -- 1476
	end -- 1476
	local extraH = math.max(0, h - 720) -- 1502
	local areaY = 114 + frame.safe.bottom * 0.4 -- 1503
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 1504
	drawFiligreeCorners( -- 1505
		uiInkDraw, -- 1505
		uiArt, -- 1505
		"ctrl_outer", -- 1505
		marginX, -- 1505
		areaY, -- 1505
		w - marginX * 2, -- 1505
		areaH, -- 1505
		PALETTE.silkDim, -- 1505
		0.52, -- 1505
		34, -- 1505
		false, -- 1505
		2 -- 1505
	) -- 1505
	local midX = w * 0.5 -- 1507
	uiArt:tryPlace( -- 1508
		"ink_vstream", -- 1508
		"ctrl_mid_stream", -- 1508
		midX, -- 1508
		areaY + areaH * 0.5, -- 1508
		32, -- 1508
		areaH - 18, -- 1508
		{ -- 1508
			color = toColor(PALETTE.silkDim), -- 1509
			opacity = 0.52, -- 1509
			layer = 1 -- 1509
		} -- 1509
	) -- 1509
	drawBlossomDot( -- 1511
		uiInkDraw, -- 1511
		uiArt, -- 1511
		"ctrl_mid_dot", -- 1511
		midX, -- 1511
		areaY + areaH * 0.5, -- 1511
		11, -- 1511
		PALETTE.silkLine, -- 1511
		0.62, -- 1511
		3 -- 1511
	) -- 1511
	local leftColX = marginX + 34 -- 1513
	local colW = midX - leftColX - 42 -- 1514
	local headY = areaY + areaH - 34 -- 1515
	local rowStep = 52 + extraH * 0.08 -- 1516
	drawBlossomDot( -- 1518
		uiInkDraw, -- 1518
		uiArt, -- 1518
		"ctrl_l_dot", -- 1518
		leftColX + 8, -- 1518
		headY, -- 1518
		12, -- 1518
		PALETTE.cyan, -- 1518
		0.88, -- 1518
		3 -- 1518
	) -- 1518
	texts:put( -- 1519
		"md", -- 1519
		"周戍 · 护送与交锋", -- 1519
		leftColX + 26, -- 1519
		headY, -- 1519
		toColor(PALETTE.cyanCore), -- 1519
		0, -- 1519
		0.5, -- 1519
		"Left", -- 1519
		2.4, -- 1519
		0.98, -- 1519
		0.08 -- 1519
	) -- 1519
	drawHairline( -- 1520
		uiInkDraw, -- 1520
		uiArt, -- 1520
		"ctrl_l_line", -- 1520
		leftColX + colW * 0.5, -- 1520
		headY - 24, -- 1520
		colW, -- 1520
		PALETTE.cyanDim, -- 1520
		0.58, -- 1520
		false, -- 1520
		2 -- 1520
	) -- 1520
	local i = 0 -- 1522
	local keycapW = 160 -- 1523
	do -- 1523
		i = 0 -- 1524
		while i < #guide.soldierRows do -- 1524
			local ry = headY - 66 - i * rowStep -- 1525
			drawSilkKeycap( -- 1526
				uiInkDraw, -- 1526
				texts, -- 1526
				leftColX + 2, -- 1526
				ry - 13, -- 1526
				keycapW, -- 1526
				26, -- 1526
				guide.soldierRows[i + 1][1], -- 1526
				PALETTE.cyan, -- 1526
				0.92, -- 1526
				false -- 1526
			) -- 1526
			texts:put( -- 1527
				"sm", -- 1527
				guide.soldierRows[i + 1][2], -- 1527
				leftColX + keycapW + 16, -- 1527
				ry, -- 1527
				toColor(PALETTE.textBright), -- 1527
				0, -- 1527
				0.5, -- 1527
				"Left", -- 1527
				0.8, -- 1527
				0.92, -- 1527
				0.08 -- 1527
			) -- 1527
			i = i + 1 -- 1524
		end -- 1524
	end -- 1524
	local rightColX = midX + 44 -- 1530
	drawBlossomDot( -- 1531
		uiInkDraw, -- 1531
		uiArt, -- 1531
		"ctrl_r_dot", -- 1531
		rightColX + 8, -- 1531
		headY, -- 1531
		12, -- 1531
		PALETTE.amber, -- 1531
		0.88, -- 1531
		3 -- 1531
	) -- 1531
	texts:put( -- 1532
		"md", -- 1532
		"小满 · 潜行与寻路", -- 1532
		rightColX + 26, -- 1532
		headY, -- 1532
		toColor(PALETTE.amberCore), -- 1532
		0, -- 1532
		0.5, -- 1532
		"Left", -- 1532
		2.4, -- 1532
		0.98, -- 1532
		0.08 -- 1532
	) -- 1532
	drawHairline( -- 1533
		uiInkDraw, -- 1533
		uiArt, -- 1533
		"ctrl_r_line", -- 1533
		rightColX + colW * 0.5, -- 1533
		headY - 24, -- 1533
		colW, -- 1533
		PALETTE.amberDim, -- 1533
		0.58, -- 1533
		false, -- 1533
		2 -- 1533
	) -- 1533
	do -- 1533
		i = 0 -- 1535
		while i < #guide.childRows do -- 1535
			local ry = headY - 66 - i * rowStep -- 1536
			drawSilkKeycap( -- 1537
				uiInkDraw, -- 1537
				texts, -- 1537
				rightColX + 2, -- 1537
				ry - 13, -- 1537
				keycapW, -- 1537
				26, -- 1537
				guide.childRows[i + 1][1], -- 1537
				PALETTE.amber, -- 1537
				0.92, -- 1537
				false -- 1537
			) -- 1537
			texts:put( -- 1538
				"sm", -- 1538
				guide.childRows[i + 1][2], -- 1538
				rightColX + keycapW + 16, -- 1538
				ry, -- 1538
				toColor(PALETTE.textBright), -- 1538
				0, -- 1538
				0.5, -- 1538
				"Left", -- 1538
				0.8, -- 1538
				0.92, -- 1538
				0.08 -- 1538
			) -- 1538
			i = i + 1 -- 1535
		end -- 1535
	end -- 1535
	local ctrlBackKey = frame.mode == "gamepad" and (target:keyTagFor("back", "gamepad", frame.layout) .. " / ") .. target:keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 1541
	local ctrlRightHint = target:controlsFooterRightHint(frame.mode) -- 1544
	local keyW = frame.mode == "touch" and 76 or 110 -- 1545
	drawSilkKeycap( -- 1546
		uiInkDraw, -- 1546
		texts, -- 1546
		backX, -- 1546
		backY + 5, -- 1546
		keyW, -- 1546
		24, -- 1546
		ctrlBackKey, -- 1546
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 1546
		0.92, -- 1546
		backHover -- 1546
	) -- 1546
	texts:put( -- 1547
		"sm", -- 1547
		backLabel, -- 1547
		backX + keyW + 12, -- 1547
		backY + 17, -- 1547
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 1547
		0, -- 1547
		0.5, -- 1547
		"Left", -- 1547
		1.8, -- 1547
		0.92, -- 1547
		0.08 -- 1547
	) -- 1547
	texts:put( -- 1548
		"xs", -- 1548
		ctrlRightHint, -- 1548
		w - marginX, -- 1548
		backY + 17, -- 1548
		toColor(PALETTE.textDim), -- 1548
		1, -- 1548
		0.5, -- 1548
		"Right", -- 1548
		1.2, -- 1548
		0.78, -- 1548
		0.08 -- 1548
	) -- 1548
	return {type = "none"} -- 1550
end -- 1408
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1554
	if frame.back then -- 1554
		self:emitSound("back") -- 1566
		return true -- 1567
	end -- 1567
	local target = getActiveTarget() -- 1570
	local rows = target:settingsRows() -- 1571
	local s = input.settings -- 1572
	if self.settingsSelected >= #rows then -- 1572
		self.settingsSelected = 0 -- 1574
	end -- 1574
	uiDraw:drawRect( -- 1577
		Rect(0, 0, w, h), -- 1577
		Color(10, 12, 19, 206) -- 1577
	) -- 1577
	local marginX = math.max( -- 1579
		96, -- 1579
		56 + math.max(frame.safe.left, frame.safe.right) -- 1579
	) -- 1579
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1580
	texts:put( -- 1581
		"banner", -- 1581
		target:settingsHeaderTitle(), -- 1581
		marginX, -- 1581
		topHeadY, -- 1581
		toColor(PALETTE.textBright), -- 1581
		0, -- 1581
		0.5, -- 1581
		"Left", -- 1581
		4, -- 1581
		0.96, -- 1581
		0.1 -- 1581
	) -- 1581
	local curSummary = target:settingsHeaderSummary(input.inputMode) -- 1582
	texts:put( -- 1583
		"xs", -- 1583
		curSummary, -- 1583
		marginX + 224, -- 1583
		topHeadY - 4, -- 1583
		toColor(PALETTE.amberCore), -- 1583
		0, -- 1583
		0.5, -- 1583
		"Left", -- 1583
		1.4, -- 1583
		0.88, -- 1583
		0.08 -- 1583
	) -- 1583
	drawHairline( -- 1584
		uiInkDraw, -- 1584
		uiArt, -- 1584
		"set_top_line", -- 1584
		w * 0.5, -- 1584
		topHeadY - 30, -- 1584
		w - marginX * 2, -- 1584
		PALETTE.silkDim, -- 1584
		0.6, -- 1584
		true, -- 1584
		2 -- 1584
	) -- 1584
	local panelW = math.min(760, w - marginX * 2) -- 1586
	local panelX = (w - panelW) * 0.5 -- 1587
	local rowH = 34 -- 1588
	local rowStep = #rows <= 6 and 48 or 39 -- 1589
	local firstY = topHeadY - 76 -- 1590
	local boxes = {} -- 1592
	local i = 0 -- 1593
	do -- 1593
		i = 0 -- 1594
		while i < #rows do -- 1594
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1595
			i = i + 1 -- 1594
		end -- 1594
	end -- 1594
	local decMinX = panelX + panelW - 196 -- 1597
	local incMinX = panelX + panelW - 92 -- 1598
	local hoverRow = hitIndex(boxes, frame.pointer, frame.inside) -- 1599
	local wheelOnValueRow = frame.wheelY ~= 0 and hoverRow >= 0 and rows[hoverRow + 1].id ~= "back" -- 1600
	local prevSetSel = self.settingsSelected -- 1601
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame, not wheelOnValueRow) -- 1602
	if self.settingsSelected ~= prevSetSel then -- 1602
		self:emitSound("hover") -- 1604
	end -- 1604
	local function applyDelta(rowId, delta) -- 1607
		local res = target:applySettingsDelta(rowId, delta, s, input) -- 1608
		if res == "back" then -- 1608
			self:emitSound("back") -- 1610
			return true -- 1611
		end -- 1611
		if res == "audio" and self.onAudioSettingsChanged ~= nil then -- 1611
			self:onAudioSettingsChanged(input) -- 1614
		end -- 1614
		if res == "assist" and self.onAssistSettingsChanged ~= nil then -- 1614
			self:onAssistSettingsChanged(input) -- 1617
		end -- 1617
		if res == "display" then -- 1617
			if self.onToggleFullscreen ~= nil then -- 1617
				self:onToggleFullscreen() -- 1621
			elseif canToggleFullscreen() then -- 1621
				do -- 1621
					pcall(function() -- 1621
						App.fullScreen = not App.fullScreen -- 1624
					end) -- 1624
				end -- 1624
			end -- 1624
		end -- 1624
		if res ~= "none" then -- 1624
			self:emitSound("toggle") -- 1631
		end -- 1631
		return false -- 1633
	end -- 1607
	do -- 1607
		i = 0 -- 1636
		while i < #rows do -- 1636
			local row = rows[i + 1] -- 1637
			local box = boxes[i + 1] -- 1638
			local cy = box.y + box.height * 0.5 -- 1639
			local active = self.settingsSelected == i -- 1640
			if active then -- 1640
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1643
				drawSilkRibbon( -- 1644
					uiDraw, -- 1644
					uiArt, -- 1644
					"set_rib_" .. tostring(i), -- 1644
					panelX + panelW * 0.5, -- 1644
					cy, -- 1644
					panelW + 24, -- 1644
					rowH, -- 1644
					PALETTE.rougeSoft, -- 1644
					0.48 * breathe, -- 1644
					0 -- 1644
				) -- 1644
				drawHairline( -- 1645
					uiInkDraw, -- 1645
					uiArt, -- 1645
					"set_line_" .. tostring(i), -- 1645
					panelX + panelW * 0.5, -- 1645
					box.y + 3, -- 1645
					panelW - 24, -- 1645
					PALETTE.silkLine, -- 1645
					0.42 * breathe, -- 1645
					false, -- 1645
					2 -- 1645
				) -- 1645
				drawBlossomDot( -- 1646
					uiInkDraw, -- 1646
					uiArt, -- 1646
					"set_dot_" .. tostring(i), -- 1646
					panelX + 18, -- 1646
					cy, -- 1646
					14, -- 1646
					PALETTE.rouge, -- 1646
					0.96, -- 1646
					4 -- 1646
				) -- 1646
				fillRadialGlow( -- 1647
					uiGlow, -- 1647
					panelX + 18, -- 1647
					cy, -- 1647
					20, -- 1647
					14, -- 1647
					toColor(PALETTE.rouge, 24 * breathe), -- 1647
					Color(182, 58, 56, 0), -- 1647
					10 -- 1647
				) -- 1647
			else -- 1647
				drawBlossomDot( -- 1649
					uiInkDraw, -- 1649
					uiArt, -- 1649
					"set_dot_" .. tostring(i), -- 1649
					panelX + 18, -- 1649
					cy, -- 1649
					7, -- 1649
					PALETTE.silkDim, -- 1649
					0.42, -- 1649
					3 -- 1649
				) -- 1649
			end -- 1649
			texts:put( -- 1652
				"sm", -- 1653
				row.title, -- 1654
				panelX + 42, -- 1655
				cy, -- 1656
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1657
				0, -- 1658
				0.5, -- 1659
				"Left", -- 1660
				active and 2.4 or 1.6, -- 1661
				active and 1 or 0.88, -- 1662
				0.08 -- 1663
			) -- 1663
			local val = target:settingsValueText(row.id, s, input.inputMode) -- 1666
			if val ~= "" then -- 1666
				local hoverDec = hoverRow == i and frame.pointer.x >= decMinX and frame.pointer.x < incMinX -- 1668
				local hoverInc = hoverRow == i and frame.pointer.x >= incMinX -- 1669
				if hoverDec then -- 1669
					uiInkDraw:drawRect( -- 1671
						Rect(decMinX, box.y + 4, incMinX - decMinX - 4, box.height - 8), -- 1671
						toColor(PALETTE.rougeSoft, 90), -- 1671
						0.8, -- 1671
						toColor(PALETTE.amberCore, 165) -- 1671
					) -- 1671
				elseif hoverInc then -- 1671
					uiInkDraw:drawRect( -- 1673
						Rect(incMinX + 4, box.y + 4, panelX + panelW - incMinX - 8, box.height - 8), -- 1673
						toColor(PALETTE.rougeSoft, 90), -- 1673
						0.8, -- 1673
						toColor(PALETTE.amberCore, 165) -- 1673
					) -- 1673
				end -- 1673
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1675
				local decorated = (active or hoverRow == i) and ("‹  " .. val) .. "  ›" or val -- 1676
				texts:put( -- 1677
					"sm", -- 1677
					decorated, -- 1677
					panelX + panelW - 24, -- 1677
					cy, -- 1677
					toColor(valCol), -- 1677
					1, -- 1677
					0.5, -- 1677
					"Right", -- 1677
					1, -- 1677
					active and 1 or 0.86, -- 1677
					0.08 -- 1677
				) -- 1677
			end -- 1677
			i = i + 1 -- 1636
		end -- 1636
	end -- 1636
	local backY = 40 + frame.safe.bottom * 0.45 -- 1681
	local hint = target:settingsFooterHint(frame.mode, frame.layout) -- 1682
	texts:put( -- 1683
		"xs", -- 1683
		hint, -- 1683
		w * 0.5, -- 1683
		backY + 14, -- 1683
		toColor(PALETTE.textDim), -- 1683
		0.5, -- 1683
		0.5, -- 1683
		"Center", -- 1683
		1.2, -- 1683
		0.84, -- 1683
		0.08 -- 1683
	) -- 1683
	if frame.rightClick then -- 1683
		if hoverRow >= 0 and rows[hoverRow + 1].id ~= "back" then -- 1683
			self.settingsSelected = hoverRow -- 1687
			applyDelta(rows[hoverRow + 1].id, -1) -- 1688
			self:resetInput() -- 1689
			return false -- 1690
		end -- 1690
		self:emitSound("back") -- 1692
		return true -- 1693
	end -- 1693
	if wheelOnValueRow then -- 1693
		self.settingsSelected = hoverRow -- 1696
		applyDelta(rows[hoverRow + 1].id, frame.wheelY > 0 and 1 or -1) -- 1697
		self:resetInput() -- 1698
		return false -- 1699
	end -- 1699
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1702
	if hit >= 0 then -- 1702
		self.settingsSelected = hit -- 1704
		local rowId = rows[hit + 1].id -- 1705
		local clickDelta = target.id == "windows" and 2 or 1 -- 1706
		if rowId ~= "back" then -- 1706
			if frame.pointer.x >= decMinX and frame.pointer.x < incMinX then -- 1706
				clickDelta = -1 -- 1709
			elseif frame.pointer.x >= incMinX then -- 1709
				clickDelta = 1 -- 1711
			end -- 1711
		end -- 1711
		if applyDelta(rowId, clickDelta) then -- 1711
			return true -- 1715
		end -- 1715
		self:resetInput() -- 1717
		return false -- 1718
	end -- 1718
	if frame.keys.left or frame.prevTab then -- 1718
		local id = rows[self.settingsSelected + 1].id -- 1721
		if id ~= "back" then -- 1721
			applyDelta(id, -1) -- 1723
			self:resetInput() -- 1724
		end -- 1724
		return false -- 1726
	end -- 1726
	if frame.keys.right or frame.nextTab then -- 1726
		local id = rows[self.settingsSelected + 1].id -- 1729
		if id ~= "back" then -- 1729
			applyDelta(id, 1) -- 1731
			self:resetInput() -- 1732
		end -- 1732
		return false -- 1734
	end -- 1734
	if frame.keys.confirm then -- 1734
		local id = rows[self.settingsSelected + 1].id -- 1737
		if applyDelta(id, target.id == "windows" and 2 or 1) then -- 1737
			return true -- 1739
		end -- 1739
		self:resetInput() -- 1741
		return false -- 1742
	end -- 1742
	return false -- 1744
end -- 1554
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi, isMaleRoguelike, showLedgerEntry, onOpenLedger, canSaveSlots) -- 1752
	if assistHintsEnabled == nil then -- 1752
		assistHintsEnabled = true -- 1763
	end -- 1763
	if safeUi == nil then -- 1763
		safeUi = ZERO_SAFE_INSETS -- 1765
	end -- 1765
	if isMaleRoguelike == nil then -- 1765
		isMaleRoguelike = false -- 1766
	end -- 1766
	if showLedgerEntry == nil then -- 1766
		showLedgerEntry = false -- 1767
	end -- 1767
	if canSaveSlots == nil then -- 1767
		canSaveSlots = false -- 1769
	end -- 1769
	self.time = self.time + dt -- 1771
	local frame = self:readFrame(input, uiScale, safeUi) -- 1772
	if self.pauseShowControls then -- 1772
		local ctrlAct = self:drawControls( -- 1775
			frame, -- 1775
			uiDraw, -- 1775
			uiInkDraw, -- 1775
			uiArt, -- 1775
			uiGlow, -- 1775
			texts, -- 1775
			w, -- 1775
			h, -- 1775
			"返回暂停" -- 1775
		) -- 1775
		if ctrlAct.type == "backTitle" then -- 1775
			self.pauseShowControls = false -- 1777
			self:resetInput() -- 1778
		end -- 1778
		return {type = "none"} -- 1780
	end -- 1780
	if self.pauseShowSettings then -- 1780
		if self:drawPauseSettings( -- 1780
			frame, -- 1784
			input, -- 1784
			uiDraw, -- 1784
			uiInkDraw, -- 1784
			uiArt, -- 1784
			uiGlow, -- 1784
			texts, -- 1784
			w, -- 1784
			h -- 1784
		) then -- 1784
			self.pauseShowSettings = false -- 1785
			self:resetInput() -- 1786
		end -- 1786
		return {type = "none"} -- 1788
	end -- 1788
	if self.pauseShowSaves then -- 1788
		local saveAct = self:drawSavesPanel( -- 1792
			frame, -- 1792
			uiDraw, -- 1792
			uiInkDraw, -- 1792
			uiArt, -- 1792
			uiGlow, -- 1792
			texts, -- 1792
			w, -- 1792
			h, -- 1792
			true, -- 1792
			canSaveSlots -- 1792
		) -- 1792
		if saveAct.type == "backPause" then -- 1792
			self.pauseShowSaves = false -- 1794
			self:resetInput() -- 1795
			return {type = "none"} -- 1796
		end -- 1796
		if saveAct.type == "loadSlot" then -- 1796
			self.pauseShowSaves = false -- 1799
			return saveAct -- 1800
		end -- 1800
		return saveAct -- 1802
	end -- 1802
	if frame.back or frame.rightClick then -- 1802
		self.pauseShowControls = false -- 1806
		self.pauseShowSettings = false -- 1807
		self.pauseShowSaves = false -- 1808
		self:emitSound("pauseClose") -- 1809
		return {type = "resume"} -- 1810
	end -- 1810
	local allowFs = canToggleFullscreen() -- 1813
	local allowQuit = canQuitApp() -- 1814
	local pauseItems = __TS__ArrayFilter( -- 1815
		PAUSE_ITEMS, -- 1815
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) and (item.id ~= "ledger" or showLedgerEntry) end -- 1815
	) -- 1815
	if self.pauseSelected >= #pauseItems then -- 1815
		self.pauseSelected = 0 -- 1821
	end -- 1821
	uiDraw:drawRect( -- 1824
		Rect(0, 0, w, h), -- 1824
		Color(8, 10, 16, 102) -- 1824
	) -- 1824
	fillHGradRect( -- 1825
		uiDraw, -- 1825
		0, -- 1825
		0, -- 1825
		w * 0.27 + frame.safe.left, -- 1825
		h, -- 1825
		Color(9, 11, 18, 232), -- 1825
		Color(10, 13, 21, 198) -- 1825
	) -- 1825
	fillHGradRect( -- 1826
		uiDraw, -- 1826
		w * 0.27 + frame.safe.left, -- 1826
		0, -- 1826
		w * 0.21, -- 1826
		h, -- 1826
		Color(10, 13, 21, 198), -- 1826
		Color(10, 13, 21, 0) -- 1826
	) -- 1826
	local menuX = 110 + frame.safe.left * 0.6 -- 1828
	local veryCompact = #pauseItems >= 10 -- 1829
	local compact = #pauseItems > 8 -- 1830
	local headY = (veryCompact and h - 92 or (compact and h - 114 or h - 146)) - frame.safe.top * 0.35 -- 1831
	uiArt:tryPlace( -- 1832
		"ink_vstream", -- 1832
		"pause_vstream", -- 1832
		menuX - 32, -- 1832
		h * 0.5, -- 1832
		34, -- 1832
		h * 0.78, -- 1832
		{ -- 1832
			color = toColor(PALETTE.silkDim), -- 1833
			opacity = 0.48, -- 1833
			layer = 1 -- 1833
		} -- 1833
	) -- 1833
	drawMistCurve( -- 1835
		uiArt, -- 1835
		"pause_mist", -- 1835
		menuX + 118, -- 1835
		headY - 8, -- 1835
		290, -- 1835
		72, -- 1835
		PALETTE.jadeMist, -- 1835
		0.2, -- 1835
		-1 -- 1835
	) -- 1835
	texts:put( -- 1837
		"banner", -- 1837
		"暂歇", -- 1837
		menuX + 16, -- 1837
		headY, -- 1837
		toColor(PALETTE.textBright), -- 1837
		0, -- 1837
		0.5, -- 1837
		"Left", -- 1837
		10, -- 1837
		0.98, -- 1837
		0.1 -- 1837
	) -- 1837
	texts:put( -- 1838
		"xs", -- 1838
		"月夜暂驻 · 卷页留痕", -- 1838
		menuX + 18, -- 1838
		headY - 36, -- 1838
		toColor(PALETTE.textDim), -- 1838
		0, -- 1838
		0.5, -- 1838
		"Left", -- 1838
		2, -- 1838
		0.8, -- 1838
		0.08 -- 1838
	) -- 1838
	drawHairline( -- 1839
		uiInkDraw, -- 1839
		uiArt, -- 1839
		"pause_div", -- 1839
		menuX + 124, -- 1839
		headY - 56, -- 1839
		240, -- 1839
		PALETTE.silkDim, -- 1839
		0.58, -- 1839
		true, -- 1839
		2 -- 1839
	) -- 1839
	local rowStep = veryCompact and 37 or (compact and 42 or 46) -- 1841
	local rowH = veryCompact and 32 or (compact and 36 or 38) -- 1842
	local firstY = veryCompact and headY - 88 or (compact and headY - 106 or headY - 120) -- 1843
	local boxes = {} -- 1844
	local i = 0 -- 1845
	do -- 1845
		i = 0 -- 1846
		while i < #pauseItems do -- 1846
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1847
			i = i + 1 -- 1846
		end -- 1846
	end -- 1846
	local prevPauseSel = self.pauseSelected -- 1849
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1850
	if self.pauseSelected ~= prevPauseSel then -- 1850
		self:emitSound("hover") -- 1852
	end -- 1852
	do -- 1852
		i = 0 -- 1855
		while i < #pauseItems do -- 1855
			local iy = boxes[i + 1].y -- 1856
			local active = self.pauseSelected == i -- 1857
			local cy = iy + rowH * 0.5 -- 1858
			local shiftX = active and 10 or 0 -- 1859
			local item = pauseItems[i + 1] -- 1860
			local label = item.zh -- 1861
			if item.id == "retry" and isMaleRoguelike then -- 1861
				label = "重开本轮护送" -- 1863
			elseif item.id == "assist" then -- 1863
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1865
			elseif item.id == "fullscreen" then -- 1865
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1867
			elseif item.id == "settings" then -- 1867
				label = getActiveTarget():settingsPauseLabel(input.settings) -- 1869
			end -- 1869
			if active then -- 1869
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1873
				drawSilkRibbon( -- 1874
					uiDraw, -- 1874
					uiArt, -- 1874
					"pause_rib_" .. tostring(i), -- 1874
					menuX + 116, -- 1874
					cy, -- 1874
					282, -- 1874
					rowH, -- 1874
					PALETTE.rougeSoft, -- 1874
					0.54 * breathe, -- 1874
					0 -- 1874
				) -- 1874
				drawHairline( -- 1875
					uiInkDraw, -- 1875
					uiArt, -- 1875
					"pause_line_" .. tostring(i), -- 1875
					menuX + 106, -- 1875
					iy + 3, -- 1875
					210, -- 1875
					PALETTE.silkLine, -- 1875
					0.42 * breathe, -- 1875
					false, -- 1875
					2 -- 1875
				) -- 1875
				drawBlossomDot( -- 1876
					uiInkDraw, -- 1876
					uiArt, -- 1876
					"pause_dot_" .. tostring(i), -- 1876
					menuX + 12, -- 1876
					cy, -- 1876
					15, -- 1876
					PALETTE.rouge, -- 1876
					0.96, -- 1876
					4 -- 1876
				) -- 1876
				fillRadialGlow( -- 1877
					uiGlow, -- 1877
					menuX + 12, -- 1877
					cy, -- 1877
					22, -- 1877
					16, -- 1877
					toColor(PALETTE.rouge, 26 * breathe), -- 1877
					Color(182, 58, 56, 0), -- 1877
					10 -- 1877
				) -- 1877
			else -- 1877
				drawBlossomDot( -- 1879
					uiInkDraw, -- 1879
					uiArt, -- 1879
					"pause_dot_" .. tostring(i), -- 1879
					menuX + 12, -- 1879
					cy, -- 1879
					8, -- 1879
					PALETTE.silkDim, -- 1879
					0.4, -- 1879
					3 -- 1879
				) -- 1879
			end -- 1879
			texts:put( -- 1882
				compact and "sm" or "md", -- 1883
				label, -- 1884
				menuX + 32 + shiftX, -- 1885
				cy, -- 1886
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1887
				0, -- 1888
				0.5, -- 1889
				"Left", -- 1890
				active and 3.4 or 2.2, -- 1891
				active and 1 or 0.88, -- 1892
				0.1 -- 1893
			) -- 1893
			i = i + 1 -- 1855
		end -- 1855
	end -- 1855
	local pauseFooter = getActiveTarget():pauseFooterHint(frame.mode, frame.layout) -- 1897
	texts:put( -- 1898
		"xs", -- 1898
		pauseFooter, -- 1898
		menuX + 12, -- 1898
		38 + frame.safe.bottom * 0.4, -- 1898
		toColor(PALETTE.textDim), -- 1898
		0, -- 1898
		0.5, -- 1898
		"Left", -- 1898
		1.2, -- 1898
		0.86, -- 1898
		0.08 -- 1898
	) -- 1898
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1900
	if hit >= 0 or frame.keys.confirm then -- 1900
		local idx = hit >= 0 and hit or self.pauseSelected -- 1902
		local id = pauseItems[idx + 1].id -- 1903
		if id == "controls" then -- 1903
			self.pauseShowControls = true -- 1905
			self:emitSound("confirm") -- 1906
			self:resetInput() -- 1907
			return {type = "none"} -- 1908
		end -- 1908
		if id == "settings" then -- 1908
			self:openPauseSettings() -- 1911
			self:emitSound("confirm") -- 1912
			return {type = "none"} -- 1913
		end -- 1913
		if id == "saves" then -- 1913
			self:openSaves(true) -- 1916
			self:emitSound("confirm") -- 1917
			return {type = "none"} -- 1918
		end -- 1918
		if id == "ledger" then -- 1918
			if onOpenLedger ~= nil then -- 1918
				onOpenLedger() -- 1922
			end -- 1922
			self.pauseShowControls = false -- 1924
			self.pauseShowSettings = false -- 1925
			self:emitSound("confirm") -- 1926
			return {type = "resume"} -- 1927
		end -- 1927
		if id == "assist" then -- 1927
			if onToggleAssist ~= nil then -- 1927
				onToggleAssist() -- 1931
			end -- 1931
			self:emitSound("toggle") -- 1933
			self:resetInput() -- 1934
			return {type = "none"} -- 1935
		end -- 1935
		if id == "fullscreen" then -- 1935
			self:emitSound("toggle") -- 1938
			self:resetInput() -- 1939
			return {type = "toggleFullscreen"} -- 1940
		end -- 1940
		self.pauseShowControls = false -- 1942
		self.pauseShowSettings = false -- 1943
		if id == "resume" then -- 1943
			self:emitSound("pauseClose") -- 1944
			return {type = "resume"} -- 1944
		end -- 1944
		if id == "retry" then -- 1944
			self:emitSound("confirm") -- 1945
			return {type = "retry"} -- 1945
		end -- 1945
		if id == "chapters" then -- 1945
			self:emitSound("confirm") -- 1946
			return {type = "openChapters"} -- 1946
		end -- 1946
		if id == "quit" then -- 1946
			self:emitSound("back") -- 1947
			return {type = "quit"} -- 1947
		end -- 1947
		self:emitSound("back") -- 1948
		return {type = "toTitle"} -- 1949
	end -- 1949
	return {type = "none"} -- 1951
end -- 1752
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1958
	if frame.back or frame.rightClick then -- 1958
		self:emitSound("back") -- 1969
		return {type = "backTitle"} -- 1970
	end -- 1970
	uiDraw:drawRect( -- 1974
		Rect(0, 0, w, h), -- 1974
		Color(7, 9, 15, 214) -- 1974
	) -- 1974
	local cx = w * 0.5 -- 1975
	local reunion = self.epilogueEnding == "reunion" -- 1976
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1977
	drawMistCurve( -- 1978
		uiArt, -- 1978
		"ep_mist", -- 1978
		cx, -- 1978
		h * 0.62, -- 1978
		620, -- 1978
		120, -- 1978
		accentCol, -- 1978
		0.2, -- 1978
		0 -- 1978
	) -- 1978
	fillRadialGlow( -- 1979
		uiGlow, -- 1979
		cx, -- 1979
		h * 0.68, -- 1979
		220, -- 1979
		140, -- 1979
		toColor(accentCol, 28), -- 1979
		Color(10, 14, 22, 0), -- 1979
		18 -- 1979
	) -- 1979
	local titleY = h * 0.72 -- 1982
	texts:put( -- 1983
		"title", -- 1983
		"向西守望", -- 1983
		cx - 18, -- 1983
		titleY, -- 1983
		toColor(PALETTE.textBright), -- 1983
		0.5, -- 1983
		0.5, -- 1983
		"Center", -- 1983
		12, -- 1983
		0.98, -- 1983
		0.12 -- 1983
	) -- 1983
	drawLoneSeal( -- 1984
		uiInkDraw, -- 1984
		uiArt, -- 1984
		texts, -- 1984
		"ep_seal", -- 1984
		cx + 148, -- 1984
		titleY - 2, -- 1984
		24, -- 1984
		46, -- 1984
		"守", -- 1984
		"望", -- 1984
		PALETTE.sealRed, -- 1984
		PALETTE.sealText, -- 1984
		0.94, -- 1984
		4 -- 1984
	) -- 1984
	drawHairline( -- 1985
		uiInkDraw, -- 1985
		uiArt, -- 1985
		"ep_div", -- 1985
		cx, -- 1985
		titleY - 46, -- 1985
		360, -- 1985
		PALETTE.silkDim, -- 1985
		0.62, -- 1985
		true, -- 1985
		2 -- 1985
	) -- 1985
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1987
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1988
	texts:put( -- 1991
		"md", -- 1991
		endingTitle, -- 1991
		cx, -- 1991
		titleY - 76, -- 1991
		toColor(PALETTE.amberCore), -- 1991
		0.5, -- 1991
		0.5, -- 1991
		"Center", -- 1991
		3.2, -- 1991
		0.96, -- 1991
		0.08 -- 1991
	) -- 1991
	texts:put( -- 1992
		"sm", -- 1992
		verse, -- 1992
		cx, -- 1992
		titleY - 114, -- 1992
		toColor(PALETTE.textMid), -- 1992
		0.5, -- 1992
		0.5, -- 1992
		"Center", -- 1992
		1, -- 1992
		0.92, -- 1992
		0.08 -- 1992
	) -- 1992
	if self.epilogueBothCleared then -- 1992
		drawSilkVeil( -- 1995
			uiDraw, -- 1995
			uiArt, -- 1995
			"ep_well_veil", -- 1995
			cx, -- 1995
			titleY - 152, -- 1995
			560, -- 1995
			30, -- 1995
			PALETTE.inkWarm, -- 1995
			0.68, -- 1995
			0 -- 1995
		) -- 1995
		texts:put( -- 1996
			"xs", -- 1996
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1996
			cx, -- 1996
			titleY - 152, -- 1996
			toColor(PALETTE.cyanCore), -- 1996
			0.5, -- 1996
			0.5, -- 1996
			"Center", -- 1996
			1, -- 1996
			0.9, -- 1996
			0.08 -- 1996
		) -- 1996
	end -- 1996
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1999
	local btnW = 286 -- 2004
	local btnH = 44 -- 2005
	local gap = 14 -- 2006
	local baseY = math.max(150, h * 0.34) -- 2007
	local boxes = {} -- 2008
	local i = 0 -- 2009
	do -- 2009
		i = 0 -- 2010
		while i < #items do -- 2010
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 2011
			i = i + 1 -- 2010
		end -- 2010
	end -- 2010
	local prevEpSel = self.epilogueSelected -- 2013
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 2014
	if self.epilogueSelected ~= prevEpSel then -- 2014
		self:emitSound("hover") -- 2016
	end -- 2016
	do -- 2016
		i = 0 -- 2019
		while i < #items do -- 2019
			local box = boxes[i + 1] -- 2020
			local active = self.epilogueSelected == i -- 2021
			local cy = box.y + box.height * 0.5 -- 2022
			if active then -- 2022
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 2024
				drawSilkRibbon( -- 2025
					uiDraw, -- 2025
					uiArt, -- 2025
					"ep_rib_" .. tostring(i), -- 2025
					cx, -- 2025
					cy, -- 2025
					btnW + 24, -- 2025
					btnH, -- 2025
					PALETTE.rougeSoft, -- 2025
					0.62 * breathe, -- 2025
					0 -- 2025
				) -- 2025
				drawHairline( -- 2026
					uiInkDraw, -- 2026
					uiArt, -- 2026
					"ep_line_" .. tostring(i), -- 2026
					cx, -- 2026
					box.y + 3, -- 2026
					btnW - 44, -- 2026
					PALETTE.silkLine, -- 2026
					0.48 * breathe, -- 2026
					false, -- 2026
					2 -- 2026
				) -- 2026
				drawBlossomDot( -- 2027
					uiInkDraw, -- 2027
					uiArt, -- 2027
					"ep_dot_" .. tostring(i), -- 2027
					box.x + 22, -- 2027
					cy, -- 2027
					13, -- 2027
					PALETTE.rouge, -- 2027
					0.96, -- 2027
					4 -- 2027
				) -- 2027
			else -- 2027
				drawSilkVeil( -- 2029
					uiDraw, -- 2029
					uiArt, -- 2029
					"ep_idle_" .. tostring(i), -- 2029
					cx, -- 2029
					cy, -- 2029
					btnW, -- 2029
					btnH - 2, -- 2029
					PALETTE.inkWash, -- 2029
					0.58, -- 2029
					0 -- 2029
				) -- 2029
				drawBlossomDot( -- 2030
					uiInkDraw, -- 2030
					uiArt, -- 2030
					"ep_dot_" .. tostring(i), -- 2030
					box.x + 22, -- 2030
					cy, -- 2030
					8, -- 2030
					PALETTE.silkDim, -- 2030
					0.42, -- 2030
					3 -- 2030
				) -- 2030
			end -- 2030
			texts:put( -- 2032
				"sm", -- 2033
				items[i + 1].zh, -- 2034
				cx + 6, -- 2035
				cy, -- 2036
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 2037
				0.5, -- 2038
				0.5, -- 2039
				"Center", -- 2040
				active and 2.6 or 1.6, -- 2041
				active and 1 or 0.88, -- 2042
				0.08 -- 2043
			) -- 2043
			i = i + 1 -- 2019
		end -- 2019
	end -- 2019
	local footer = getActiveTarget():epilogueFooterHint(frame.mode, frame.layout) -- 2047
	texts:put( -- 2048
		"xs", -- 2048
		footer, -- 2048
		cx, -- 2048
		38 + frame.safe.bottom * 0.4, -- 2048
		toColor(PALETTE.textDim), -- 2048
		0.5, -- 2048
		0.5, -- 2048
		"Center", -- 2048
		1.2, -- 2048
		0.84, -- 2048
		0.08 -- 2048
	) -- 2048
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 2050
	if hit >= 0 or frame.keys.confirm then -- 2050
		local idx = hit >= 0 and hit or self.epilogueSelected -- 2052
		local id = items[idx + 1].id -- 2053
		if id == "history" then -- 2053
			self:emitSound("confirm") -- 2054
			return {type = "openHistory"} -- 2054
		end -- 2054
		if id == "replay" then -- 2054
			self:emitSound("start") -- 2055
			return {type = "replayStory"} -- 2055
		end -- 2055
		self:emitSound("back") -- 2056
		return {type = "backTitle"} -- 2057
	end -- 2057
	return {type = "none"} -- 2059
end -- 1958
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 2066
	if frame.back or frame.rightClick then -- 2066
		self:emitSound("back") -- 2077
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 2078
	end -- 2078
	local total = #HISTORY_CARDS -- 2081
	if frame.keys.left or frame.prevTab or frame.wheelY > 0.1 then -- 2081
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 2083
		self:emitSound("toggle") -- 2084
	elseif frame.keys.right or frame.nextTab or frame.wheelY < -0.1 then -- 2084
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 2086
		self:emitSound("toggle") -- 2087
	end -- 2087
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 2089
	uiDraw:drawRect( -- 2091
		Rect(0, 0, w, h), -- 2091
		Color(7, 9, 15, 206) -- 2091
	) -- 2091
	local cx = w * 0.5 -- 2092
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 2093
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 2094
	local px = cx - pageW * 0.5 -- 2095
	local py = (h - pageH) * 0.5 + 14 -- 2096
	local midY = py + pageH * 0.5 -- 2097
	uiArt:tryPlace( -- 2099
		"ink_frame_mask", -- 2099
		"hist_shadow", -- 2099
		cx, -- 2099
		midY - 6, -- 2099
		pageW + 52, -- 2099
		pageH + 46, -- 2099
		{ -- 2099
			color = toColor(PALETTE.voidDark), -- 2100
			opacity = 0.84, -- 2100
			layer = -1 -- 2100
		} -- 2100
	) -- 2100
	if not uiArt:tryPlace( -- 2100
		"ink_song_paper", -- 2102
		"hist_paper", -- 2102
		cx, -- 2102
		midY, -- 2102
		pageW, -- 2102
		pageH, -- 2102
		{opacity = 0.98, layer = 1} -- 2102
	) then -- 2102
		uiDraw:drawRect( -- 2103
			Rect(px, py, pageW, pageH), -- 2103
			toColor(PALETTE.xuanPaper, 248), -- 2103
			1, -- 2103
			toColor(PALETTE.silkDim, 180) -- 2103
		) -- 2103
	end -- 2103
	fillRadialGlow( -- 2105
		uiGlow, -- 2105
		cx, -- 2105
		midY + 40, -- 2105
		260, -- 2105
		140, -- 2105
		Color(236, 224, 202, 16), -- 2105
		Color(236, 224, 202, 0), -- 2105
		14 -- 2105
	) -- 2105
	local inX = px + 42 -- 2108
	local inY = py + 32 -- 2109
	local inW = pageW - 84 -- 2110
	local inH = pageH - 64 -- 2111
	local redSilk = toColor(PALETTE.rouge, 118) -- 2112
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 2113
	uiInkDraw:drawRect( -- 2114
		Rect(inX, inY, inW, inH), -- 2114
		Color(0, 0, 0, 0), -- 2114
		0.95, -- 2114
		redSilk -- 2114
	) -- 2114
	uiInkDraw:drawRect( -- 2115
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 2115
		Color(0, 0, 0, 0), -- 2115
		0.55, -- 2115
		redSilkFaint -- 2115
	) -- 2115
	local headY = inY + inH - 30 -- 2118
	texts:put( -- 2119
		"md", -- 2119
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 2119
		inX + 20, -- 2119
		headY, -- 2119
		toColor(PALETTE.xuanInk), -- 2119
		0, -- 2119
		0.5, -- 2119
		"Left", -- 2119
		2, -- 2119
		0.96, -- 2119
		0 -- 2119
	) -- 2119
	texts:put( -- 2120
		"xs", -- 2120
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 2120
		inX + inW - 20, -- 2120
		headY, -- 2120
		toColor(PALETTE.rouge), -- 2120
		1, -- 2120
		0.5, -- 2120
		"Right", -- 2120
		1.8, -- 2120
		0.88, -- 2120
		0 -- 2120
	) -- 2120
	uiInkDraw:drawSegment( -- 2121
		Vec2(inX + 14, headY - 22), -- 2121
		Vec2(inX + inW - 14, headY - 22), -- 2121
		0.85, -- 2121
		redSilk -- 2121
	) -- 2121
	texts:put( -- 2124
		"xs", -- 2124
		card.subtitle, -- 2124
		inX + 20, -- 2124
		headY - 42, -- 2124
		toColor(PALETTE.xuanInkSub), -- 2124
		0, -- 2124
		0.5, -- 2124
		"Left", -- 2124
		1.4, -- 2124
		0.86, -- 2124
		0 -- 2124
	) -- 2124
	local function wrapZh(src, maxUnits) -- 2127
		local out = {} -- 2128
		local buf = "" -- 2129
		local units = 0 -- 2130
		local ci = 0 -- 2131
		while ci < #src do -- 2131
			local b = __TS__StringCharCodeAt(src, ci) -- 2133
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 2134
			local ch = __TS__StringSlice(src, ci, ci + step) -- 2135
			local u = b < 128 and 0.56 or 1.02 -- 2136
			if units + u > maxUnits and buf ~= "" then -- 2136
				out[#out + 1] = buf -- 2138
				buf = ch -- 2139
				units = u -- 2140
			else -- 2140
				buf = buf .. ch -- 2142
				units = units + u -- 2143
			end -- 2143
			ci = ci + step -- 2145
		end -- 2145
		if buf ~= "" then -- 2145
			out[#out + 1] = buf -- 2148
		end -- 2148
		return out -- 2150
	end -- 2127
	local charsPerLine = math.max( -- 2153
		24, -- 2153
		math.floor((inW - 44) / 20) -- 2153
	) -- 2153
	local cursorY = headY - 76 -- 2154
	local pi = 0 -- 2155
	do -- 2155
		pi = 0 -- 2156
		while pi < #card.paragraphs do -- 2156
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 2157
			local li = 0 -- 2158
			do -- 2158
				li = 0 -- 2159
				while li < #lines do -- 2159
					texts:put( -- 2160
						"sm", -- 2160
						lines[li + 1], -- 2160
						inX + 22, -- 2160
						cursorY, -- 2160
						toColor(PALETTE.xuanInk), -- 2160
						0, -- 2160
						0.5, -- 2160
						"Left", -- 2160
						0.6, -- 2160
						0.94, -- 2160
						0 -- 2160
					) -- 2160
					cursorY = cursorY - 30 -- 2161
					li = li + 1 -- 2159
				end -- 2159
			end -- 2159
			cursorY = cursorY - 12 -- 2163
			pi = pi + 1 -- 2156
		end -- 2156
	end -- 2156
	local footY = inY + 26 -- 2167
	uiInkDraw:drawSegment( -- 2168
		Vec2(inX + 14, footY + 20), -- 2168
		Vec2(inX + inW - 14, footY + 20), -- 2168
		0.6, -- 2168
		redSilkFaint -- 2168
	) -- 2168
	texts:put( -- 2169
		"xs", -- 2169
		card.footnote, -- 2169
		inX + 20, -- 2169
		footY, -- 2169
		toColor(PALETTE.xuanInkSub), -- 2169
		0, -- 2169
		0.5, -- 2169
		"Left", -- 2169
		0.4, -- 2169
		0.84, -- 2169
		0 -- 2169
	) -- 2169
	local navY = math.max(30, py - 48) -- 2172
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 2173
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 2174
	local backBox = Rect(cx - 88, navY, 176, 34) -- 2175
	local function drawNavBtn(box, tag, label) -- 2177
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 2178
		drawSilkVeil( -- 2179
			uiDraw, -- 2179
			uiArt, -- 2179
			"hist_btn_" .. tag, -- 2179
			box.x + box.width * 0.5, -- 2179
			box.y + box.height * 0.5, -- 2179
			box.width, -- 2179
			box.height, -- 2179
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 2179
			hover and 0.86 or 0.72, -- 2179
			2 -- 2179
		) -- 2179
		texts:put( -- 2180
			"xs", -- 2180
			label, -- 2180
			box.x + box.width * 0.5, -- 2180
			box.y + box.height * 0.5, -- 2180
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 2180
			0.5, -- 2180
			0.5, -- 2180
			"Center", -- 2180
			1.4, -- 2180
			0.94, -- 2180
			0.08 -- 2180
		) -- 2180
		return hover and frame.click -- 2181
	end -- 2177
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 2177
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 2185
		self:emitSound("toggle") -- 2186
	end -- 2186
	if drawNavBtn(nextBox, "next", "下一篇") then -- 2186
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 2189
		self:emitSound("toggle") -- 2190
	end -- 2190
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 2190
		self:emitSound("back") -- 2193
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 2194
	end -- 2194
	if frame.keys.confirm then -- 2194
		if self.historyCardIndex + 1 < total then -- 2194
			self.historyCardIndex = self.historyCardIndex + 1 -- 2199
			self:emitSound("toggle") -- 2200
		else -- 2200
			self:emitSound("back") -- 2202
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 2203
		end -- 2203
	end -- 2203
	return {type = "none"} -- 2206
end -- 2066
return ____exports -- 2066