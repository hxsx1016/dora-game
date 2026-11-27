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
local ____platform = require("Script.watch.platform") -- 15
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 17
local canQuitApp = ____platform.canQuitApp -- 18
local canToggleFullscreen = ____platform.canToggleFullscreen -- 19
local ____target = require("Script.watch.target") -- 21
local getActiveTarget = ____target.getActiveTarget -- 21
local ____dialogues = require("Script.watch.dialogues") -- 22
local HISTORY_CARDS = ____dialogues.HISTORY_CARDS -- 22
local ____theme = require("Script.watch.fe.theme") -- 26
local PALETTE = ____theme.PALETTE -- 27
local drawBlossomDot = ____theme.drawBlossomDot -- 28
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 29
local drawHairline = ____theme.drawHairline -- 30
local drawLoneSeal = ____theme.drawLoneSeal -- 31
local drawMistCurve = ____theme.drawMistCurve -- 32
local drawSilkKeycap = ____theme.drawSilkKeycap -- 33
local drawSilkRibbon = ____theme.drawSilkRibbon -- 34
local drawSilkVeil = ____theme.drawSilkVeil -- 35
local fillHGradRect = ____theme.fillHGradRect -- 36
local fillRadialGlow = ____theme.fillRadialGlow -- 37
local fillVGradRect = ____theme.fillVGradRect -- 38
local themeOf = ____theme.themeOf -- 39
local toColor = ____theme.toColor -- 40
local visualTextWidth = ____theme.visualTextWidth -- 41
local TITLE_ITEMS = { -- 72
	{id = "start", zh = "开始游戏"}, -- 73
	{id = "chapters", zh = "选择章节"}, -- 74
	{id = "controls", zh = "操作说明"}, -- 75
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 76
	{id = "quit", zh = "退出游戏"} -- 77
} -- 77
local CHAPTERS = (function() -- 92
	local out = {} -- 93
	local i = 0 -- 94
	do -- 94
		i = 0 -- 95
		while i < #ROOMS do -- 95
			do -- 95
				local room = ROOMS[i + 1] -- 96
				if room.key == "museum" or room.key == "street" or room.key == "checkpoint" then -- 97
					goto __continue4 -- 98
				end -- 98
				if room.key == "tower" then -- 100
					out[#out + 1] = { -- 101
						room = room, -- 102
						roomIndex = i, -- 103
						route = "child", -- 104
						titleOverride = "终章 · 北塔留灯", -- 105
						shortNameOverride = "北塔·留灯", -- 106
						lineTagOverride = "小满", -- 107
						whisperOverride = "孤身叩响北塔门，西窗留一盏向西的灯。" -- 108
					} -- 108
					out[#out + 1] = { -- 110
						room = room, -- 111
						roomIndex = i, -- 112
						route = "soldier", -- 113
						titleOverride = "终章 · 北塔团圆", -- 114
						shortNameOverride = "北塔·团圆", -- 115
						lineTagOverride = "周戍", -- 116
						whisperOverride = "兄妹并肩跨过塔门，两行姓名同落登记簿。" -- 117
					} -- 117
					goto __continue4 -- 119
				end -- 119
				out[#out + 1] = {room = room, roomIndex = i} -- 121
			end -- 121
			::__continue4:: -- 121
			i = i + 1 -- 95
		end -- 95
	end -- 95
	return out -- 123
end)() -- 92
local PAUSE_ITEMS = { -- 127
	{id = "resume", zh = "继续游戏"}, -- 128
	{id = "retry", zh = "重试检查点"}, -- 129
	{id = "controls", zh = "操作说明"}, -- 130
	{id = "assist", zh = "按键辅助：关"}, -- 131
	{id = "fullscreen", zh = "显示：窗口"}, -- 132
	{id = "chapters", zh = "选择章节"}, -- 133
	{id = "title", zh = "返回标题"}, -- 134
	{id = "quit", zh = "退出游戏"}, -- 135
	{id = "settings", zh = "操控设置"} -- 136
} -- 136
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 139
local EPIGRAPH_RIGHT = { -- 140
	"城", -- 140
	"破", -- 140
	"那", -- 140
	"天", -- 140
	"", -- 140
	"他", -- 140
	"留", -- 140
	"下", -- 140
	"断", -- 140
	"后" -- 140
} -- 140
local EPIGRAPH_LEFT = { -- 141
	"她", -- 141
	"独", -- 141
	"自", -- 141
	"走", -- 141
	"向", -- 141
	"北", -- 141
	"塔" -- 141
} -- 141
local function hitIndex(boxes, pointer, inside) -- 166
	if not inside then -- 167
		return -1 -- 168
	end -- 168
	return __TS__ArrayFindIndex( -- 170
		boxes, -- 170
		function(____, box) return box:containsPoint(pointer) end -- 170
	) -- 170
end -- 166
____exports.MenuRenderer = __TS__Class() -- 173
local MenuRenderer = ____exports.MenuRenderer -- 173
MenuRenderer.name = "MenuRenderer" -- 173
function MenuRenderer.prototype.____constructor(self) -- 173
	self.selected = 0 -- 174
	self.chapterSelected = 0 -- 175
	self.pauseSelected = 0 -- 176
	self.settingsSelected = 0 -- 177
	self.epilogueSelected = 0 -- 178
	self.epilogueEnding = "lamp" -- 179
	self.epilogueBothCleared = false -- 180
	self.historyCardIndex = 0 -- 181
	self.historyFromEpilogue = false -- 182
	self.hasSession = false -- 184
	self.sessionLabel = "" -- 186
	self.controlsTab = "kbm" -- 192
	self.chaptersFromPause = false -- 204
	self.pauseShowControls = false -- 205
	self.pauseShowSettings = false -- 206
	self.controlsTabManual = false -- 207
	self.queuedKeys = {} -- 208
	self.queuedBack = false -- 209
	self.queuedSkip = false -- 210
	self.splashTime = 0 -- 211
	self.time = 0 -- 212
end -- 173
function MenuRenderer.prototype.setSessionRoomKey(self, roomKey) -- 188
	self.sessionLabel = roomKey ~= "" and themeOf(roomKey).shortNameZh or "" -- 189
end -- 188
function MenuRenderer.prototype.emitSound(self, kind) -- 198
	if self.onUiSound ~= nil then -- 199
		self:onUiSound(kind) -- 200
	end -- 200
end -- 198
function MenuRenderer.prototype.resetSplash(self) -- 214
	self.splashTime = 0 -- 215
	self.queuedSkip = false -- 216
	self:resetInput() -- 217
end -- 214
function MenuRenderer.prototype.isShowingPauseControls(self) -- 220
	return self.pauseShowControls -- 221
end -- 220
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 224
	return self.pauseShowSettings -- 225
end -- 224
function MenuRenderer.prototype.openPauseSettings(self) -- 228
	self.pauseShowControls = false -- 229
	self.pauseShowSettings = true -- 230
	self.settingsSelected = 0 -- 231
	self:resetInput() -- 232
end -- 228
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 235
	self.chaptersFromPause = roomIndex ~= nil -- 236
	self.chapterSelected = math.max( -- 237
		0, -- 237
		__TS__ArrayFindIndex( -- 237
			CHAPTERS, -- 237
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 237
		) -- 237
	) -- 237
	self.pauseShowControls = false -- 238
	self.pauseShowSettings = false -- 239
	self:resetInput() -- 240
end -- 235
function MenuRenderer.prototype.openPause(self) -- 243
	self.pauseSelected = 0 -- 244
	self.pauseShowControls = false -- 245
	self.pauseShowSettings = false -- 246
	self:resetInput() -- 247
end -- 243
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 250
	if ending == nil then -- 250
		ending = "lamp" -- 250
	end -- 250
	if bothCleared == nil then -- 250
		bothCleared = false -- 250
	end -- 250
	self.epilogueEnding = ending -- 251
	self.epilogueBothCleared = bothCleared -- 252
	self.epilogueSelected = 0 -- 253
	self:resetInput() -- 254
end -- 250
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 257
	if fromEpilogue == nil then -- 257
		fromEpilogue = true -- 257
	end -- 257
	self.historyFromEpilogue = fromEpilogue -- 258
	self.historyCardIndex = 0 -- 259
	self:resetInput() -- 260
end -- 257
function MenuRenderer.prototype.triggerBack(self) -- 264
	self.queuedBack = true -- 265
end -- 264
function MenuRenderer.prototype.resetInput(self) -- 269
	self.queuedKeys = {} -- 270
	self.queuedBack = false -- 271
	self.queuedSkip = false -- 272
	self.controlsTabManual = false -- 273
end -- 269
function MenuRenderer.prototype.onKeyEvent(self, key) -- 277
	self.queuedSkip = true -- 278
	if key == "Up" or key == "W" then -- 279
		self.queuedKeys.up = true -- 280
	elseif key == "Down" or key == "S" then -- 281
		self.queuedKeys.down = true -- 282
	elseif key == "Left" or key == "A" then -- 283
		self.queuedKeys.left = true -- 284
	elseif key == "Right" or key == "D" then -- 285
		self.queuedKeys.right = true -- 286
	elseif key == "Return" or key == "Space" then -- 287
		self.queuedKeys.confirm = true -- 288
	elseif key == "Escape" then -- 289
		self.queuedBack = true -- 290
	end -- 290
end -- 277
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 294
	local queued = self.queuedKeys -- 295
	local useUiPtr = input.uiInside or input.uiPressed -- 298
	local rawX = useUiPtr and input.uiX or input.mx -- 299
	local rawY = useUiPtr and input.uiY or input.my -- 300
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 301
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 302
	local ____useUiPtr_0 -- 303
	if useUiPtr then -- 303
		____useUiPtr_0 = input.uiInside -- 303
	else -- 303
		____useUiPtr_0 = input.inside -- 303
	end -- 303
	local inside = ____useUiPtr_0 -- 303
	local ____useUiPtr_1 -- 304
	if useUiPtr then -- 304
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 304
	else -- 304
		____useUiPtr_1 = input.inside and input.fire.pressed -- 304
	end -- 304
	local click = ____useUiPtr_1 -- 304
	local touchMode = input:isTouchMode() -- 305
	local frame = { -- 307
		keys = { -- 308
			up = queued.up == true or input.navUp, -- 309
			down = queued.down == true or input.navDown, -- 310
			left = queued.left == true or input.navLeft, -- 311
			right = queued.right == true or input.navRight, -- 312
			confirm = queued.confirm == true or input.navConfirm -- 313
		}, -- 313
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 315
		prevTab = input.navPrevTab, -- 316
		nextTab = input.navNextTab, -- 317
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 318
		pointer = Vec2(rawX / scale, rawY / scale), -- 319
		inside = inside, -- 320
		click = click, -- 321
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 322
		mode = input.inputMode, -- 323
		layout = input.gamepadLayout, -- 324
		safe = safe -- 325
	} -- 325
	self.queuedKeys = {} -- 327
	self.queuedBack = false -- 328
	self.queuedSkip = false -- 329
	return frame -- 330
end -- 294
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 333
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 334
	if frame.click and hit >= 0 then -- 335
		return hit -- 336
	end -- 336
	if frame.keys.up then -- 338
		return (selected + #boxes - 1) % #boxes -- 339
	end -- 339
	if frame.keys.down then -- 341
		return (selected + 1) % #boxes -- 342
	end -- 342
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 344
end -- 333
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 347
	if safeUi == nil then -- 363
		safeUi = ZERO_SAFE_INSETS -- 363
	end -- 363
	self.time = self.time + dt -- 365
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 366
	if screen ~= "splash" or splashDissolving then -- 367
		local artW = math.max(w, h * 16 / 9) -- 368
		local artH = artW * 9 / 16 -- 369
		if not backdropArt:tryPlace( -- 370
			"title_backdrop", -- 370
			"menu_landscape", -- 370
			w * 0.5, -- 370
			(h - artH) * 0.5, -- 370
			artW, -- 370
			artH -- 370
		) then -- 370
			stage:drawMenuBackdrop( -- 371
				bgDraw, -- 371
				bgGlow, -- 371
				w, -- 371
				h, -- 371
				self.time -- 371
			) -- 371
		end -- 371
	end -- 371
	local frame = self:readFrame(input, uiScale, safeUi) -- 375
	w = w / uiScale -- 376
	h = h / uiScale -- 377
	if screen == "splash" then -- 379
		return self:drawSplash( -- 380
			dt, -- 380
			frame, -- 380
			uiDraw, -- 380
			uiArt, -- 380
			texts, -- 380
			w, -- 380
			h -- 380
		) -- 380
	end -- 380
	if screen == "title" then -- 382
		return self:drawTitle( -- 383
			frame, -- 383
			uiDraw, -- 383
			uiInkDraw, -- 383
			uiArt, -- 383
			uiGlow, -- 383
			texts, -- 383
			w, -- 383
			h -- 383
		) -- 383
	end -- 383
	if screen == "chapters" then -- 385
		return self:drawChapters( -- 386
			frame, -- 386
			uiDraw, -- 386
			uiInkDraw, -- 386
			uiArt, -- 386
			uiGlow, -- 386
			texts, -- 386
			w, -- 386
			h -- 386
		) -- 386
	end -- 386
	if screen == "epilogue" then -- 388
		return self:drawEpilogue( -- 389
			frame, -- 389
			uiDraw, -- 389
			uiInkDraw, -- 389
			uiArt, -- 389
			uiGlow, -- 389
			texts, -- 389
			w, -- 389
			h -- 389
		) -- 389
	end -- 389
	if screen == "history" then -- 391
		return self:drawHistory( -- 392
			frame, -- 392
			uiDraw, -- 392
			uiInkDraw, -- 392
			uiArt, -- 392
			uiGlow, -- 392
			texts, -- 392
			w, -- 392
			h -- 392
		) -- 392
	end -- 392
	return self:drawControls( -- 394
		frame, -- 394
		uiDraw, -- 394
		uiInkDraw, -- 394
		uiArt, -- 394
		uiGlow, -- 394
		texts, -- 394
		w, -- 394
		h -- 394
	) -- 394
end -- 347
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 403
	local safeDt = math.min( -- 412
		0.1, -- 412
		math.max(0, dt) -- 412
	) -- 412
	self.splashTime = self.splashTime + safeDt -- 413
	local t = self.splashTime -- 414
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 416
	if wantSkip or t >= 4.65 then -- 417
		self.splashTime = 0 -- 418
		return {type = "splashDone"} -- 419
	end -- 419
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 422
	local bgR = t < 2.2 and 13 or 11 -- 423
	local bgG = t < 2.2 and 16 or 13 -- 424
	local bgB = t < 2.2 and 24 or 19 -- 425
	uiDraw:drawRect( -- 426
		Rect(0, 0, w, h), -- 426
		Color( -- 426
			bgR, -- 426
			bgG, -- 426
			bgB, -- 426
			math.floor(255 * fadeOutCurtain + 0.5) -- 426
		) -- 426
	) -- 426
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 428
		if localT <= 0 or localT >= endT then -- 429
			return 0 -- 429
		end -- 429
		if localT < fadeIn then -- 430
			local u = localT / fadeIn -- 431
			return u * u * (3 - 2 * u) -- 432
		end -- 432
		if localT <= holdEnd then -- 434
			return 1 -- 434
		end -- 434
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 435
		return 1 - u * u * (3 - 2 * u) -- 436
	end -- 428
	if t < 2.2 then -- 439
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 440
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 441
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 442
		if not uiArt:tryPlace( -- 443
			"brand_team_logo", -- 443
			"splash_team_logo", -- 443
			w * 0.5, -- 443
			h * 0.54, -- 443
			logoH * 2, -- 443
			logoH, -- 443
			{opacity = alpha, layer = 2} -- 443
		) then -- 443
			texts:put( -- 444
				"banner", -- 444
				"OUTSIDER", -- 444
				w * 0.5, -- 444
				h * 0.52, -- 444
				toColor(PALETTE.textBright), -- 444
				0.5, -- 444
				0.5, -- 444
				"Center", -- 444
				6, -- 444
				alpha, -- 444
				0 -- 444
			) -- 444
		end -- 444
		texts:put( -- 446
			"xs", -- 446
			"Powered by Dora SSR", -- 446
			w * 0.5, -- 446
			58 + frame.safe.bottom * 0.4, -- 446
			toColor(PALETTE.textDim), -- 446
			0.5, -- 446
			0.5, -- 446
			"Center", -- 446
			1.8, -- 446
			alpha * 0.62, -- 446
			0 -- 446
		) -- 446
	elseif t < 4.25 then -- 447
		local localT = t - 2.2 -- 448
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 449
		local sway = math.sin(localT * 1.1) * 8 -- 450
		drawMistCurve( -- 451
			uiArt, -- 451
			"splash_game_mist", -- 451
			w * 0.5 + sway, -- 451
			h * 0.46, -- 451
			560, -- 451
			110, -- 451
			PALETTE.jadeMist, -- 451
			0.16 * alpha, -- 451
			1 -- 451
		) -- 451
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 452
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 453
		if not uiArt:tryPlace( -- 454
			"brand_game_logo_h", -- 454
			"splash_game_logo", -- 454
			w * 0.5, -- 454
			h * 0.52, -- 454
			logoH * 2.4, -- 454
			logoH, -- 454
			{opacity = alpha, layer = 2} -- 454
		) then -- 454
			texts:put( -- 455
				"title", -- 455
				"向西守望", -- 455
				w * 0.5, -- 455
				h * 0.52, -- 455
				toColor(PALETTE.textBright), -- 455
				0.5, -- 455
				0.5, -- 455
				"Center", -- 455
				8, -- 455
				alpha, -- 455
				0 -- 455
			) -- 455
		end -- 455
	end -- 455
	if t >= 0.35 and t < 4.15 then -- 459
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 460
		local skipText = getActiveTarget():splashSkipHint(frame.mode, frame.layout) -- 461
		texts:put( -- 462
			"xs", -- 462
			skipText, -- 462
			w - 48 - frame.safe.right * 0.6, -- 462
			36 + frame.safe.bottom * 0.4, -- 462
			toColor(PALETTE.textDim), -- 462
			1, -- 462
			0.5, -- 462
			"Right", -- 462
			1.4, -- 462
			hintA, -- 462
			0 -- 462
		) -- 462
	end -- 462
	return {type = "none"} -- 465
end -- 403
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 468
	fillHGradRect( -- 478
		uiDraw, -- 478
		0, -- 478
		0, -- 478
		w * 0.22 + frame.safe.left * 0.5, -- 478
		h, -- 478
		Color(9, 11, 18, 192), -- 478
		Color(9, 11, 18, 116) -- 478
	) -- 478
	fillHGradRect( -- 479
		uiDraw, -- 479
		w * 0.22 + frame.safe.left * 0.5, -- 479
		0, -- 479
		w * 0.28, -- 479
		h, -- 479
		Color(9, 11, 18, 116), -- 479
		Color(9, 11, 18, 0) -- 479
	) -- 479
	fillVGradRect( -- 480
		uiDraw, -- 480
		0, -- 480
		0, -- 480
		w, -- 480
		78, -- 480
		Color(8, 10, 16, 138), -- 480
		Color(8, 10, 16, 0) -- 480
	) -- 480
	local extraH = math.max(0, h - 720) -- 482
	local titleX = 148 + frame.safe.left * 0.6 -- 483
	local topY = h - 104 - frame.safe.top * 0.4 -- 484
	local charStep = 66 -- 485
	local sway = math.sin(self.time * 0.7) * 5 -- 486
	drawMistCurve( -- 487
		uiArt, -- 487
		"title_mist_wisp", -- 487
		titleX + 86 + sway, -- 487
		topY - 122, -- 487
		340, -- 487
		82, -- 487
		PALETTE.jadeMist, -- 487
		0.2, -- 487
		-1 -- 487
	) -- 487
	uiArt:tryPlace( -- 488
		"ink_petal_mist", -- 488
		"title_petals", -- 488
		titleX + 12, -- 488
		topY - 102, -- 488
		230, -- 488
		210, -- 488
		{ -- 488
			color = toColor(PALETTE.inkMist), -- 489
			opacity = 0.4, -- 489
			layer = -1 -- 489
		} -- 489
	) -- 489
	local placedBrandTitle = uiArt:tryPlace( -- 493
		"brand_game_logo_v", -- 493
		"title_brand_v", -- 493
		titleX + 22, -- 493
		topY - 106, -- 493
		240, -- 493
		304, -- 493
		{opacity = 0.98, layer = 3} -- 493
	) -- 493
	if not placedBrandTitle then -- 496
		uiArt:tryPlace( -- 497
			"ink_vstream", -- 497
			"title_vstream", -- 497
			titleX - 48, -- 497
			topY - 100, -- 497
			34, -- 497
			290, -- 497
			{ -- 497
				color = toColor(PALETTE.silkDim), -- 498
				opacity = 0.48, -- 498
				layer = 1 -- 498
			} -- 498
		) -- 498
		local c = 0 -- 500
		do -- 500
			c = 0 -- 501
			while c < #VERTICAL_TITLE do -- 501
				texts:put( -- 502
					"title", -- 503
					VERTICAL_TITLE[c + 1], -- 504
					titleX, -- 505
					topY - c * charStep, -- 506
					toColor(PALETTE.textBright), -- 507
					0.5, -- 508
					0.5, -- 509
					"Center", -- 510
					0, -- 511
					0.98, -- 512
					0.1, -- 513
					Color(8, 10, 16, 210) -- 514
				) -- 514
				c = c + 1 -- 501
			end -- 501
		end -- 501
		drawLoneSeal( -- 517
			uiInkDraw, -- 518
			uiArt, -- 519
			texts, -- 520
			"title_lone_seal", -- 521
			titleX + 46, -- 522
			topY - 3 * charStep + 8, -- 523
			26, -- 524
			52, -- 525
			"守", -- 526
			"望", -- 527
			PALETTE.sealRed, -- 528
			PALETTE.sealText, -- 529
			0.94, -- 530
			4 -- 531
		) -- 531
	end -- 531
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 536
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 537
	local poemStep = 22 -- 538
	local p = 0 -- 539
	do -- 539
		p = 0 -- 540
		while p < #EPIGRAPH_RIGHT do -- 540
			local ch = EPIGRAPH_RIGHT[p + 1] -- 541
			if ch ~= "" then -- 542
				texts:put( -- 543
					"xs", -- 543
					ch, -- 543
					colRightX, -- 543
					topY - 22 - p * poemStep, -- 543
					toColor(PALETTE.textMid), -- 543
					0.5, -- 543
					0.5, -- 543
					"Center", -- 543
					0, -- 543
					0.86, -- 543
					0.08 -- 543
				) -- 543
			end -- 543
			p = p + 1 -- 540
		end -- 540
	end -- 540
	do -- 540
		p = 0 -- 546
		while p < #EPIGRAPH_LEFT do -- 546
			texts:put( -- 547
				"xs", -- 547
				EPIGRAPH_LEFT[p + 1], -- 547
				colLeftX, -- 547
				topY - 68 - p * poemStep, -- 547
				toColor(PALETTE.amberCore), -- 547
				0.5, -- 547
				0.5, -- 547
				"Center", -- 547
				0, -- 547
				0.9, -- 547
				0.08 -- 547
			) -- 547
			p = p + 1 -- 546
		end -- 546
	end -- 546
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 551
		TITLE_ITEMS, -- 553
		function(____, it) return it.id ~= "quit" end -- 553
	) -- 553
	local items = self.hasSession and ({ -- 554
		{id = "continue", zh = "继续游戏"}, -- 555
		table.unpack(baseItems) -- 555
	}) or baseItems -- 556
	if self.selected >= #items then -- 557
		self.selected = 0 -- 558
	end -- 558
	local menuX = 112 + frame.safe.left * 0.6 -- 560
	local btnW = 280 -- 561
	local btnH = frame.mode == "touch" and 44 or 40 -- 562
	local gap = self.hasSession and 6 or 8 -- 563
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 564
	local boxes = {} -- 565
	local i = 0 -- 566
	do -- 566
		i = 0 -- 567
		while i < #items do -- 567
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 568
			i = i + 1 -- 567
		end -- 567
	end -- 567
	local prevTitleSel = self.selected -- 570
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 571
	if self.selected ~= prevTitleSel then -- 572
		self:emitSound("hover") -- 573
	end -- 573
	do -- 573
		i = 0 -- 576
		while i < #items do -- 576
			local by = boxes[i + 1].y -- 577
			local active = self.selected == i -- 578
			local cy = by + btnH * 0.5 -- 579
			local shiftX = active and 10 or 0 -- 580
			if active then -- 582
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 583
				drawSilkRibbon( -- 584
					uiDraw, -- 584
					uiArt, -- 584
					"title_rib_red_" .. tostring(i), -- 584
					menuX + 124, -- 584
					cy, -- 584
					290, -- 584
					btnH, -- 584
					PALETTE.rougeSoft, -- 584
					0.52 * breathe, -- 584
					0 -- 584
				) -- 584
				drawHairline( -- 585
					uiInkDraw, -- 585
					uiArt, -- 585
					"title_rib_line_" .. tostring(i), -- 585
					menuX + 114, -- 585
					by + 4, -- 585
					230, -- 585
					PALETTE.silkLine, -- 585
					0.42 * breathe, -- 585
					false, -- 585
					2 -- 585
				) -- 585
				drawBlossomDot( -- 586
					uiInkDraw, -- 586
					uiArt, -- 586
					"title_dot_" .. tostring(i), -- 586
					menuX + 14, -- 586
					cy, -- 586
					16, -- 586
					PALETTE.rouge, -- 586
					0.96, -- 586
					4 -- 586
				) -- 586
				fillRadialGlow( -- 587
					uiGlow, -- 587
					menuX + 14, -- 587
					cy, -- 587
					22, -- 587
					16, -- 587
					toColor(PALETTE.rouge, 28 * breathe), -- 587
					Color(182, 58, 56, 0), -- 587
					10 -- 587
				) -- 587
			else -- 587
				drawBlossomDot( -- 589
					uiInkDraw, -- 589
					uiArt, -- 589
					"title_dot_" .. tostring(i), -- 589
					menuX + 14, -- 589
					cy, -- 589
					8, -- 589
					PALETTE.silkDim, -- 589
					0.4, -- 589
					3 -- 589
				) -- 589
			end -- 589
			texts:put( -- 592
				"md", -- 593
				items[i + 1].zh, -- 594
				menuX + 34 + shiftX, -- 595
				cy, -- 596
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 597
				0, -- 598
				0.5, -- 599
				"Left", -- 600
				active and 4.4 or 2.8, -- 601
				active and 1 or 0.88, -- 602
				0.1 -- 603
			) -- 603
			if items[i + 1].id == "continue" and self.sessionLabel ~= "" then -- 605
				texts:put( -- 606
					"xs", -- 607
					"· " .. self.sessionLabel, -- 608
					menuX + 168 + shiftX, -- 609
					cy, -- 610
					toColor(active and PALETTE.amberCore or PALETTE.textDim), -- 611
					0, -- 612
					0.5, -- 613
					"Left", -- 614
					1.2, -- 615
					active and 0.92 or 0.72, -- 616
					0.08 -- 617
				) -- 617
			end -- 617
			i = i + 1 -- 576
		end -- 576
	end -- 576
	local titleHint = getActiveTarget():titleFooterHint(frame.mode, frame.layout) -- 622
	texts:put( -- 623
		"xs", -- 623
		titleHint, -- 623
		menuX + 12, -- 623
		42 + frame.safe.bottom * 0.45, -- 623
		toColor(PALETTE.textDim), -- 623
		0, -- 623
		0.5, -- 623
		"Left", -- 623
		1.4, -- 623
		0.88, -- 623
		0.08 -- 623
	) -- 623
	local badgeRight = w - frame.safe.right * 0.5 -- 626
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 627
	fillHGradRect( -- 628
		uiDraw, -- 628
		badgeRight - 270, -- 628
		0, -- 628
		270 + frame.safe.right * 0.5, -- 628
		86, -- 628
		Color(8, 10, 16, 0), -- 628
		Color(8, 10, 16, 204) -- 628
	) -- 628
	uiArt:tryPlace( -- 629
		"brand_team_badge", -- 629
		"title_team_badge", -- 629
		badgeRight - 118, -- 629
		badgeY, -- 629
		168, -- 629
		54, -- 629
		{opacity = 0.95, layer = 3} -- 629
	) -- 629
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 633
	if hit >= 0 or frame.keys.confirm then -- 634
		local idx = hit >= 0 and hit or self.selected -- 635
		local id = items[idx + 1].id -- 636
		if id == "continue" then -- 637
			self:emitSound("start") -- 637
			return {type = "continue"} -- 637
		end -- 637
		if id == "trial" then -- 638
			self:emitSound("start") -- 638
			return {type = "trial"} -- 638
		end -- 638
		if id == "start" then -- 639
			self:emitSound("start") -- 639
			return {type = "start"} -- 639
		end -- 639
		if id == "chapters" then -- 640
			self:emitSound("confirm") -- 640
			return {type = "openChapters"} -- 640
		end -- 640
		if id == "quit" then -- 641
			self:emitSound("back") -- 641
			return {type = "quit"} -- 641
		end -- 641
		self:emitSound("confirm") -- 642
		return {type = "openControls"} -- 643
	end -- 643
	return {type = "none"} -- 645
end -- 468
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 648
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 658
	if frame.back then -- 659
		self:emitSound("back") -- 660
		return back -- 661
	end -- 661
	local extraH = math.max(0, h - 720) -- 664
	local marginX = math.max( -- 665
		96, -- 665
		56 + math.max(frame.safe.left, frame.safe.right) -- 665
	) -- 665
	local splitTrack = #CHAPTERS > 8 -- 666
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 667
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 668
	local rowGap = 68 -- 669
	local trackX0 = marginX + 34 -- 670
	local trackX1 = w - marginX - 34 -- 671
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 672
	local stationBoxes = {} -- 674
	local s = 0 -- 675
	do -- 675
		s = 0 -- 676
		while s < #CHAPTERS do -- 676
			local sx = trackX0 + s % perRow * stepX -- 677
			local sy = trackY - math.floor(s / perRow) * rowGap -- 678
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 679
			s = s + 1 -- 676
		end -- 676
	end -- 676
	local prevSelected = self.chapterSelected -- 682
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 683
	local keys = frame.keys -- 684
	if frame.click and hitStation >= 0 then -- 685
		self.chapterSelected = hitStation -- 686
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 687
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 688
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 689
	elseif keys.down and self.chapterSelected < perRow then -- 690
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 691
	elseif keys.up and self.chapterSelected >= perRow then -- 692
		self.chapterSelected = self.chapterSelected - perRow -- 693
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 694
		self.chapterSelected = hitStation -- 695
	end -- 695
	if self.chapterSelected ~= prevSelected then -- 697
		self:emitSound("hover") -- 698
	end -- 698
	uiDraw:drawRect( -- 701
		Rect(0, 0, w, h), -- 701
		Color(10, 12, 19, 198) -- 701
	) -- 701
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 703
	texts:put( -- 704
		"banner", -- 704
		"选择章节", -- 704
		marginX, -- 704
		topHeadY, -- 704
		toColor(PALETTE.textBright), -- 704
		0, -- 704
		0.5, -- 704
		"Left", -- 704
		4.5, -- 704
		0.96, -- 704
		0.1 -- 704
	) -- 704
	drawHairline( -- 705
		uiInkDraw, -- 705
		uiArt, -- 705
		"chap_top_line", -- 705
		w * 0.5, -- 705
		topHeadY - 34, -- 705
		w - marginX * 2, -- 705
		PALETTE.silkDim, -- 705
		0.6, -- 705
		true, -- 705
		2 -- 705
	) -- 705
	local activeEntry = CHAPTERS[self.chapterSelected + 1] -- 707
	local activeRoom = activeEntry.room -- 708
	local theme = themeOf(activeRoom.key) -- 709
	local activeTitleZh = activeEntry.titleOverride or theme.titleZh -- 710
	local activeLineTag = activeEntry.lineTagOverride or theme.lineTag -- 711
	local activeWhisper = activeEntry.whisperOverride or theme.introWhisper -- 712
	local winX = marginX -- 713
	local winY = 266 + extraH * 0.44 -- 714
	local winW = math.min( -- 715
		520, -- 715
		math.max(360, (w - marginX * 2) * 0.46) -- 715
	) -- 715
	local winH = 296 -- 716
	local winBox = Rect(winX, winY, winW, winH) -- 717
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 718
	uiArt:tryPlace( -- 720
		"ink_frame_mask", -- 720
		"chap_win_shadow", -- 720
		winX + winW * 0.5, -- 720
		winY + winH * 0.5, -- 720
		winW + 40, -- 720
		winH + 34, -- 720
		{ -- 720
			color = toColor(PALETTE.inkVoid), -- 721
			opacity = 0.88, -- 721
			layer = -2 -- 721
		} -- 721
	) -- 721
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 723
	uiArt:tryPlace( -- 724
		bgSlot, -- 724
		"chap_win_art", -- 724
		winX + winW * 0.5, -- 724
		winY + 4, -- 724
		winW - 8, -- 724
		winH - 8, -- 724
		{opacity = 0.92, layer = -1} -- 724
	) -- 724
	fillVGradRect( -- 727
		uiInkDraw, -- 727
		winX, -- 727
		winY, -- 727
		winW, -- 727
		56, -- 727
		Color(10, 12, 19, 200), -- 727
		Color(10, 12, 19, 0) -- 727
	) -- 727
	fillVGradRect( -- 728
		uiInkDraw, -- 728
		winX, -- 728
		winY + winH - 36, -- 728
		winW, -- 728
		36, -- 728
		Color(10, 12, 19, 0), -- 728
		Color(10, 12, 19, 130) -- 728
	) -- 728
	fillHGradRect( -- 729
		uiInkDraw, -- 729
		winX, -- 729
		winY, -- 729
		34, -- 729
		winH, -- 729
		Color(10, 12, 19, 135), -- 729
		Color(10, 12, 19, 0) -- 729
	) -- 729
	fillHGradRect( -- 730
		uiInkDraw, -- 730
		winX + winW - 34, -- 730
		winY, -- 730
		34, -- 730
		winH, -- 730
		Color(10, 12, 19, 0), -- 730
		Color(10, 12, 19, 135) -- 730
	) -- 730
	drawFiligreeCorners( -- 731
		uiInkDraw, -- 731
		uiArt, -- 731
		"chap_win_frame", -- 731
		winX, -- 731
		winY, -- 731
		winW, -- 731
		winH, -- 731
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 731
		winHover and 0.92 or 0.72, -- 731
		34, -- 731
		true, -- 731
		3 -- 731
	) -- 731
	texts:put( -- 733
		"xs", -- 733
		(theme.actCode .. "  ·  ") .. activeLineTag, -- 733
		winX + 20, -- 733
		winY + 22, -- 733
		toColor(PALETTE.textMid), -- 733
		0, -- 733
		0.5, -- 733
		"Left", -- 733
		1.8, -- 733
		0.9, -- 733
		0.08 -- 733
	) -- 733
	local infoX = winX + winW + 40 -- 735
	local infoW = math.max(240, w - marginX - infoX) -- 736
	local infoCenterY = winY + winH * 0.5 -- 737
	drawMistCurve( -- 738
		uiArt, -- 738
		"chap_info_mist", -- 738
		infoX + infoW * 0.5, -- 738
		infoCenterY + 36, -- 738
		math.min(420, infoW + 24), -- 738
		88, -- 738
		theme.accent, -- 738
		0.22, -- 738
		-1 -- 738
	) -- 738
	local volCol = activeLineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 740
	texts:put( -- 741
		"xs", -- 741
		theme.volumeTagZh, -- 741
		infoX, -- 741
		winY + winH - 44, -- 741
		toColor(volCol), -- 741
		0, -- 741
		0.5, -- 741
		"Left", -- 741
		2.8, -- 741
		0.92, -- 741
		0.08 -- 741
	) -- 741
	local sep = " · " -- 743
	local sIdx = (string.find(activeTitleZh, sep, nil, true) or 0) - 1 -- 744
	local titleY = winY + winH - 98 -- 745
	if theme.backdropKey ~= nil then -- 746
		texts:put( -- 747
			"lg", -- 747
			activeTitleZh, -- 747
			infoX, -- 747
			titleY, -- 747
			toColor(PALETTE.textBright) -- 747
		) -- 747
	elseif sIdx > 0 then -- 748
		local leftPart = __TS__StringSlice(activeTitleZh, 0, sIdx) -- 749
		local rightPart = __TS__StringSlice(activeTitleZh, sIdx + #sep) -- 750
		local lw = visualTextWidth(leftPart, 40) -- 751
		texts:put( -- 752
			"banner", -- 752
			leftPart, -- 752
			infoX, -- 752
			titleY, -- 752
			toColor(PALETTE.textBright), -- 752
			0, -- 752
			0.5, -- 752
			"Left", -- 752
			2, -- 752
			1, -- 752
			0.1 -- 752
		) -- 752
		drawBlossomDot( -- 753
			uiInkDraw, -- 753
			uiArt, -- 753
			"chap_title_dot", -- 753
			infoX + lw + 16, -- 753
			titleY - 2, -- 753
			11, -- 753
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 753
			0.9, -- 753
			4 -- 753
		) -- 753
		texts:put( -- 754
			"banner", -- 754
			rightPart, -- 754
			infoX + lw + 32, -- 754
			titleY, -- 754
			toColor(PALETTE.textBright), -- 754
			0, -- 754
			0.5, -- 754
			"Left", -- 754
			2, -- 754
			1, -- 754
			0.1 -- 754
		) -- 754
	else -- 754
		texts:put( -- 756
			"banner", -- 756
			activeTitleZh, -- 756
			infoX, -- 756
			titleY, -- 756
			toColor(PALETTE.textBright), -- 756
			0, -- 756
			0.5, -- 756
			"Left", -- 756
			2.4, -- 756
			1, -- 756
			0.1 -- 756
		) -- 756
	end -- 756
	drawHairline( -- 759
		uiInkDraw, -- 759
		uiArt, -- 759
		"chap_info_line", -- 759
		infoX + math.min(185, infoW * 0.5), -- 759
		titleY - 36, -- 759
		math.min(370, infoW), -- 759
		PALETTE.silkDim, -- 759
		0.58, -- 759
		false, -- 759
		2 -- 759
	) -- 759
	texts:put( -- 760
		"sm", -- 760
		activeWhisper, -- 760
		infoX, -- 760
		titleY - 72, -- 760
		toColor(PALETTE.textMid), -- 760
		0, -- 760
		0.5, -- 760
		"Left", -- 760
		0.8, -- 760
		0.94, -- 760
		0.08 -- 760
	) -- 760
	local goX = infoX -- 762
	local goY = winY + 26 -- 763
	local goW = 220 -- 764
	local goH = 42 -- 765
	local goBox = Rect(goX, goY, goW, goH) -- 766
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 767
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 768
	drawSilkRibbon( -- 769
		uiDraw, -- 769
		uiArt, -- 769
		"chap_go_rib", -- 769
		goX + 106, -- 769
		goY + 21, -- 769
		250, -- 769
		40, -- 769
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 769
		(goHover and 0.68 or 0.46) * breathe, -- 769
		0 -- 769
	) -- 769
	drawHairline( -- 770
		uiInkDraw, -- 770
		uiArt, -- 770
		"chap_go_line", -- 770
		goX + 94, -- 770
		goY + 3, -- 770
		196, -- 770
		PALETTE.silkLine, -- 770
		goHover and 0.68 or 0.4, -- 770
		false, -- 770
		2 -- 770
	) -- 770
	drawBlossomDot( -- 771
		uiInkDraw, -- 771
		uiArt, -- 771
		"chap_go_dot", -- 771
		goX + 14, -- 771
		goY + 21, -- 771
		14, -- 771
		PALETTE.rouge, -- 771
		0.96, -- 771
		4 -- 771
	) -- 771
	texts:put( -- 772
		"md", -- 772
		"入此卷章", -- 772
		goX + 34, -- 772
		goY + 21, -- 772
		toColor(PALETTE.textBright), -- 772
		0, -- 772
		0.5, -- 772
		"Left", -- 772
		3.8, -- 772
		1, -- 772
		0.1 -- 772
	) -- 772
	local chapConfirmTag = getActiveTarget():keyTagFor("confirm", frame.mode, frame.layout) -- 773
	texts:put( -- 774
		"xs", -- 774
		chapConfirmTag, -- 774
		goX + 156, -- 774
		goY + 21, -- 774
		toColor(PALETTE.textDim), -- 774
		0, -- 774
		0.5, -- 774
		"Left", -- 774
		1, -- 774
		0.82, -- 774
		0.08 -- 774
	) -- 774
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 776
	local veilH = splitTrack and 156 or 126 -- 777
	drawSilkVeil( -- 778
		uiDraw, -- 778
		uiArt, -- 778
		"chap_track_veil", -- 778
		w * 0.5, -- 778
		veilCenterY, -- 778
		w - marginX * 1.1, -- 778
		veilH, -- 778
		PALETTE.inkWash, -- 778
		0.72, -- 778
		-2 -- 778
	) -- 778
	drawMistCurve( -- 779
		uiArt, -- 779
		"chap_track_mist", -- 779
		w * 0.5, -- 779
		trackY, -- 779
		trackX1 - trackX0 + 160, -- 779
		74, -- 779
		PALETTE.inkMist, -- 779
		0.62, -- 779
		-1 -- 779
	) -- 779
	uiInkDraw:drawSegment( -- 780
		Vec2(trackX0, trackY), -- 780
		Vec2(trackX1, trackY), -- 780
		0.9, -- 780
		toColor(PALETTE.silkDim, 145) -- 780
	) -- 780
	if splitTrack then -- 782
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 783
		uiInkDraw:drawSegment( -- 784
			Vec2(trackX0, trackY - rowGap), -- 784
			Vec2(lastX, trackY - rowGap), -- 784
			0.9, -- 784
			toColor(PALETTE.silkDim, 145) -- 784
		) -- 784
	else -- 784
		local midDivX = trackX0 + stepX * 3.5 -- 786
		uiInkDraw:drawSegment( -- 787
			Vec2(midDivX, trackY - 12), -- 787
			Vec2(midDivX, trackY + 12), -- 787
			0.8, -- 787
			toColor(PALETTE.silkDim, 120) -- 787
		) -- 787
		texts:put( -- 788
			"xs", -- 788
			"上卷 · 孤城护童", -- 788
			trackX0 + stepX * 1.5, -- 788
			trackY + 52, -- 788
			toColor(PALETTE.cyan), -- 788
			0.5, -- 788
			0.5, -- 788
			"Center", -- 788
			2.2, -- 788
			0.88, -- 788
			0.08 -- 788
		) -- 788
		texts:put( -- 789
			"xs", -- 789
			"下卷 · 独赴北塔", -- 789
			trackX0 + stepX * 5.5, -- 789
			trackY + 52, -- 789
			toColor(PALETTE.amber), -- 789
			0.5, -- 789
			0.5, -- 789
			"Center", -- 789
			2.2, -- 789
			0.88, -- 789
			0.08 -- 789
		) -- 789
	end -- 789
	local i = 0 -- 792
	do -- 792
		i = 0 -- 793
		while i < #CHAPTERS do -- 793
			local box = stationBoxes[i + 1] -- 794
			local sx = box.x + box.width * 0.5 -- 795
			local sy = box.y + box.height * 0.5 -- 796
			local entry = CHAPTERS[i + 1] -- 797
			local rt = themeOf(entry.room.key) -- 798
			local entryLineTag = entry.lineTagOverride or rt.lineTag -- 799
			local entryShortName = entry.shortNameOverride or rt.shortNameZh -- 800
			local active = self.chapterSelected == i -- 801
			local nodeCol = active and PALETTE.rouge or (entryLineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 802
			if active then -- 804
				fillRadialGlow( -- 805
					uiGlow, -- 805
					sx, -- 805
					sy, -- 805
					26, -- 805
					26, -- 805
					toColor(PALETTE.rouge, 36 * breathe), -- 805
					Color(182, 58, 56, 0), -- 805
					12 -- 805
				) -- 805
				uiArt:tryPlace( -- 806
					"ink_enso_fine", -- 806
					"chap_st_ring_" .. tostring(i), -- 806
					sx, -- 806
					sy, -- 806
					32, -- 806
					32, -- 806
					{ -- 806
						color = toColor(PALETTE.silkLine), -- 807
						opacity = 0.78, -- 807
						angle = self.time * 18, -- 807
						layer = 3 -- 807
					} -- 807
				) -- 807
				drawBlossomDot( -- 809
					uiInkDraw, -- 809
					uiArt, -- 809
					"chap_st_dot_" .. tostring(i), -- 809
					sx, -- 809
					sy, -- 809
					17, -- 809
					PALETTE.rouge, -- 809
					0.98, -- 809
					4 -- 809
				) -- 809
			else -- 809
				uiArt:tryPlace( -- 811
					"ink_enso_fine", -- 811
					"chap_st_ring_" .. tostring(i), -- 811
					sx, -- 811
					sy, -- 811
					16, -- 811
					16, -- 811
					{ -- 811
						color = toColor(nodeCol), -- 812
						opacity = 0.62, -- 812
						layer = 3 -- 812
					} -- 812
				) -- 812
				drawBlossomDot( -- 814
					uiInkDraw, -- 814
					uiArt, -- 814
					"chap_st_dot_" .. tostring(i), -- 814
					sx, -- 814
					sy, -- 814
					7, -- 814
					PALETTE.silkLine, -- 814
					0.72, -- 814
					4 -- 814
				) -- 814
			end -- 814
			if not splitTrack then -- 817
				texts:put( -- 818
					"xs", -- 818
					rt.numeralZh, -- 818
					sx, -- 818
					sy + 25, -- 818
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 818
					0.5, -- 818
					0.5, -- 818
					"Center", -- 818
					0, -- 818
					active and 1 or 0.88, -- 818
					0.08 -- 818
				) -- 818
			end -- 818
			texts:put( -- 820
				"xs", -- 820
				entryShortName, -- 820
				sx, -- 820
				sy - 26, -- 820
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 820
				0.5, -- 820
				0.5, -- 820
				"Center", -- 820
				1, -- 820
				active and 1 or 0.84, -- 820
				0.08 -- 820
			) -- 820
			i = i + 1 -- 793
		end -- 793
	end -- 793
	local backX = marginX -- 823
	local backY = 40 + frame.safe.bottom * 0.45 -- 824
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 825
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 826
	local chapBackTag = getActiveTarget():keyTagFor("back", frame.mode, frame.layout) -- 827
	local chapFooter = getActiveTarget():chapterFooterHint(frame.mode, chapConfirmTag) -- 828
	drawSilkKeycap( -- 829
		uiInkDraw, -- 829
		texts, -- 829
		backX, -- 829
		backY + 5, -- 829
		48, -- 829
		24, -- 829
		chapBackTag, -- 829
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 829
		0.92, -- 829
		backHover -- 829
	) -- 829
	texts:put( -- 830
		"sm", -- 830
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 830
		backX + 60, -- 830
		backY + 17, -- 830
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 830
		0, -- 830
		0.5, -- 830
		"Left", -- 830
		1.8, -- 830
		0.9, -- 830
		0.08 -- 830
	) -- 830
	texts:put( -- 831
		"xs", -- 831
		chapFooter, -- 831
		w - marginX, -- 831
		backY + 17, -- 831
		toColor(PALETTE.textDim), -- 831
		1, -- 831
		0.5, -- 831
		"Right", -- 831
		1.2, -- 831
		0.75, -- 831
		0.08 -- 831
	) -- 831
	if frame.click and backHover then -- 833
		self:emitSound("back") -- 834
		return back -- 835
	end -- 835
	local ____temp_2 -- 838
	if frame.mode == "touch" then -- 838
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 839
	else -- 839
		____temp_2 = hitStation >= 0 -- 840
	end -- 840
	local stationConfirmed = ____temp_2 -- 838
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 841
		self:emitSound("start") -- 842
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex, route = CHAPTERS[self.chapterSelected + 1].route} -- 843
	end -- 843
	return {type = "none"} -- 849
end -- 648
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 853
	if backLabel == nil then -- 862
		backLabel = "返回标题" -- 862
	end -- 862
	local target = getActiveTarget() -- 864
	local tabs = target.controlsGuideTabs -- 865
	local hasMultipleTabs = #tabs > 1 -- 866
	if not self.controlsTabManual or __TS__ArrayFindIndex( -- 867
		tabs, -- 867
		function(____, t) return t.mode == self.controlsTab end -- 867
	) < 0 then -- 867
		self.controlsTab = __TS__ArrayFindIndex( -- 868
			tabs, -- 868
			function(____, t) return t.mode == frame.mode end -- 868
		) >= 0 and frame.mode or tabs[1].mode -- 868
	end -- 868
	local marginX = math.max( -- 870
		96, -- 870
		56 + math.max(frame.safe.left, frame.safe.right) -- 870
	) -- 870
	local tabW = 92 -- 871
	local tabH = 28 -- 872
	local tabGap = 10 -- 873
	local tabBoxes = {} -- 874
	local hitTab = -1 -- 875
	if hasMultipleTabs then -- 876
		local tabStartX = w - marginX - (tabW * #tabs + tabGap * (#tabs - 1)) -- 877
		local tabY = h - 82 - frame.safe.top * 0.35 -- 878
		local k = 0 -- 879
		do -- 879
			k = 0 -- 880
			while k < #tabs do -- 880
				tabBoxes[#tabBoxes + 1] = Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH) -- 881
				k = k + 1 -- 880
			end -- 880
		end -- 880
		hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 883
		if frame.click and hitTab >= 0 then -- 884
			if self.controlsTab ~= tabs[hitTab + 1].mode then -- 885
				self:emitSound("toggle") -- 886
			end -- 886
			self.controlsTab = tabs[hitTab + 1].mode -- 888
			self.controlsTabManual = true -- 889
		elseif frame.keys.left or frame.prevTab then -- 890
			local cur = __TS__ArrayFindIndex( -- 891
				tabs, -- 891
				function(____, t) return t.mode == self.controlsTab end -- 891
			) -- 891
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + #tabs - 1) % #tabs + 1].mode -- 892
			self.controlsTabManual = true -- 893
			self:emitSound("toggle") -- 894
		elseif frame.keys.right or frame.nextTab then -- 895
			local cur = __TS__ArrayFindIndex( -- 896
				tabs, -- 896
				function(____, t) return t.mode == self.controlsTab end -- 896
			) -- 896
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + 1) % #tabs + 1].mode -- 897
			self.controlsTabManual = true -- 898
			self:emitSound("toggle") -- 899
		end -- 899
	end -- 899
	local backX = marginX -- 903
	local backY = 40 + frame.safe.bottom * 0.45 -- 904
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 905
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 906
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 907
		self:emitSound("back") -- 908
		return {type = "backTitle"} -- 909
	end -- 909
	uiDraw:drawRect( -- 911
		Rect(0, 0, w, h), -- 911
		Color(10, 12, 19, 204) -- 911
	) -- 911
	local guide = target:controlsGuideRows(self.controlsTab) -- 913
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 914
	texts:put( -- 915
		"banner", -- 915
		"执器要诀", -- 915
		marginX, -- 915
		topHeadY, -- 915
		toColor(PALETTE.textBright), -- 915
		0, -- 915
		0.5, -- 915
		"Left", -- 915
		4.5, -- 915
		0.96, -- 915
		0.1 -- 915
	) -- 915
	texts:put( -- 916
		"xs", -- 916
		guide.subtitle, -- 916
		marginX + 196, -- 916
		topHeadY - 4, -- 916
		toColor(PALETTE.textDim), -- 916
		0, -- 916
		0.5, -- 916
		"Left", -- 916
		1.8, -- 916
		0.85, -- 916
		0.08 -- 916
	) -- 916
	drawHairline( -- 917
		uiInkDraw, -- 917
		uiArt, -- 917
		"ctrl_top_line", -- 917
		w * 0.5, -- 917
		topHeadY - 34, -- 917
		w - marginX * 2, -- 917
		PALETTE.silkDim, -- 917
		0.6, -- 917
		true, -- 917
		2 -- 917
	) -- 917
	if hasMultipleTabs then -- 919
		local ti = 0 -- 920
		do -- 920
			ti = 0 -- 921
			while ti < #tabBoxes do -- 921
				local tb = tabBoxes[ti + 1] -- 922
				local activeTab = self.controlsTab == tabs[ti + 1].mode -- 923
				local hoverTab = hitTab == ti -- 924
				uiInkDraw:drawRect( -- 925
					tb, -- 926
					activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 927
					0.9, -- 928
					toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 929
				) -- 929
				texts:put( -- 931
					"xs", -- 932
					tabs[ti + 1].label, -- 933
					tb.x + tb.width * 0.5, -- 934
					tb.y + tb.height * 0.5, -- 935
					toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 936
					0.5, -- 937
					0.5, -- 938
					"Center", -- 939
					0.8, -- 940
					activeTab and 0.98 or 0.82, -- 941
					0.08 -- 942
				) -- 942
				ti = ti + 1 -- 921
			end -- 921
		end -- 921
	end -- 921
	local extraH = math.max(0, h - 720) -- 947
	local areaY = 114 + frame.safe.bottom * 0.4 -- 948
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 949
	drawFiligreeCorners( -- 950
		uiInkDraw, -- 950
		uiArt, -- 950
		"ctrl_outer", -- 950
		marginX, -- 950
		areaY, -- 950
		w - marginX * 2, -- 950
		areaH, -- 950
		PALETTE.silkDim, -- 950
		0.52, -- 950
		34, -- 950
		false, -- 950
		2 -- 950
	) -- 950
	local midX = w * 0.5 -- 952
	uiArt:tryPlace( -- 953
		"ink_vstream", -- 953
		"ctrl_mid_stream", -- 953
		midX, -- 953
		areaY + areaH * 0.5, -- 953
		32, -- 953
		areaH - 18, -- 953
		{ -- 953
			color = toColor(PALETTE.silkDim), -- 954
			opacity = 0.52, -- 954
			layer = 1 -- 954
		} -- 954
	) -- 954
	drawBlossomDot( -- 956
		uiInkDraw, -- 956
		uiArt, -- 956
		"ctrl_mid_dot", -- 956
		midX, -- 956
		areaY + areaH * 0.5, -- 956
		11, -- 956
		PALETTE.silkLine, -- 956
		0.62, -- 956
		3 -- 956
	) -- 956
	local leftColX = marginX + 34 -- 958
	local colW = midX - leftColX - 42 -- 959
	local headY = areaY + areaH - 34 -- 960
	local rowStep = 52 + extraH * 0.08 -- 961
	drawBlossomDot( -- 963
		uiInkDraw, -- 963
		uiArt, -- 963
		"ctrl_l_dot", -- 963
		leftColX + 8, -- 963
		headY, -- 963
		12, -- 963
		PALETTE.cyan, -- 963
		0.88, -- 963
		3 -- 963
	) -- 963
	texts:put( -- 964
		"md", -- 964
		"周戍 · 护送与交锋", -- 964
		leftColX + 26, -- 964
		headY, -- 964
		toColor(PALETTE.cyanCore), -- 964
		0, -- 964
		0.5, -- 964
		"Left", -- 964
		2.4, -- 964
		0.98, -- 964
		0.08 -- 964
	) -- 964
	drawHairline( -- 965
		uiInkDraw, -- 965
		uiArt, -- 965
		"ctrl_l_line", -- 965
		leftColX + colW * 0.5, -- 965
		headY - 24, -- 965
		colW, -- 965
		PALETTE.cyanDim, -- 965
		0.58, -- 965
		false, -- 965
		2 -- 965
	) -- 965
	local i = 0 -- 967
	local keycapW = 160 -- 968
	do -- 968
		i = 0 -- 969
		while i < #guide.soldierRows do -- 969
			local ry = headY - 66 - i * rowStep -- 970
			drawSilkKeycap( -- 971
				uiInkDraw, -- 971
				texts, -- 971
				leftColX + 2, -- 971
				ry - 13, -- 971
				keycapW, -- 971
				26, -- 971
				guide.soldierRows[i + 1][1], -- 971
				PALETTE.cyan, -- 971
				0.92, -- 971
				false -- 971
			) -- 971
			texts:put( -- 972
				"sm", -- 972
				guide.soldierRows[i + 1][2], -- 972
				leftColX + keycapW + 16, -- 972
				ry, -- 972
				toColor(PALETTE.textBright), -- 972
				0, -- 972
				0.5, -- 972
				"Left", -- 972
				0.8, -- 972
				0.92, -- 972
				0.08 -- 972
			) -- 972
			i = i + 1 -- 969
		end -- 969
	end -- 969
	local rightColX = midX + 44 -- 975
	drawBlossomDot( -- 976
		uiInkDraw, -- 976
		uiArt, -- 976
		"ctrl_r_dot", -- 976
		rightColX + 8, -- 976
		headY, -- 976
		12, -- 976
		PALETTE.amber, -- 976
		0.88, -- 976
		3 -- 976
	) -- 976
	texts:put( -- 977
		"md", -- 977
		"小满 · 潜行与寻路", -- 977
		rightColX + 26, -- 977
		headY, -- 977
		toColor(PALETTE.amberCore), -- 977
		0, -- 977
		0.5, -- 977
		"Left", -- 977
		2.4, -- 977
		0.98, -- 977
		0.08 -- 977
	) -- 977
	drawHairline( -- 978
		uiInkDraw, -- 978
		uiArt, -- 978
		"ctrl_r_line", -- 978
		rightColX + colW * 0.5, -- 978
		headY - 24, -- 978
		colW, -- 978
		PALETTE.amberDim, -- 978
		0.58, -- 978
		false, -- 978
		2 -- 978
	) -- 978
	do -- 978
		i = 0 -- 980
		while i < #guide.childRows do -- 980
			local ry = headY - 66 - i * rowStep -- 981
			drawSilkKeycap( -- 982
				uiInkDraw, -- 982
				texts, -- 982
				rightColX + 2, -- 982
				ry - 13, -- 982
				keycapW, -- 982
				26, -- 982
				guide.childRows[i + 1][1], -- 982
				PALETTE.amber, -- 982
				0.92, -- 982
				false -- 982
			) -- 982
			texts:put( -- 983
				"sm", -- 983
				guide.childRows[i + 1][2], -- 983
				rightColX + keycapW + 16, -- 983
				ry, -- 983
				toColor(PALETTE.textBright), -- 983
				0, -- 983
				0.5, -- 983
				"Left", -- 983
				0.8, -- 983
				0.92, -- 983
				0.08 -- 983
			) -- 983
			i = i + 1 -- 980
		end -- 980
	end -- 980
	local ctrlBackKey = frame.mode == "gamepad" and (target:keyTagFor("back", "gamepad", frame.layout) .. " / ") .. target:keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 986
	local ctrlRightHint = target:controlsFooterRightHint(frame.mode) -- 989
	local keyW = frame.mode == "touch" and 76 or 110 -- 990
	drawSilkKeycap( -- 991
		uiInkDraw, -- 991
		texts, -- 991
		backX, -- 991
		backY + 5, -- 991
		keyW, -- 991
		24, -- 991
		ctrlBackKey, -- 991
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 991
		0.92, -- 991
		backHover -- 991
	) -- 991
	texts:put( -- 992
		"sm", -- 992
		backLabel, -- 992
		backX + keyW + 12, -- 992
		backY + 17, -- 992
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 992
		0, -- 992
		0.5, -- 992
		"Left", -- 992
		1.8, -- 992
		0.92, -- 992
		0.08 -- 992
	) -- 992
	texts:put( -- 993
		"xs", -- 993
		ctrlRightHint, -- 993
		w - marginX, -- 993
		backY + 17, -- 993
		toColor(PALETTE.textDim), -- 993
		1, -- 993
		0.5, -- 993
		"Right", -- 993
		1.2, -- 993
		0.78, -- 993
		0.08 -- 993
	) -- 993
	return {type = "none"} -- 995
end -- 853
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 999
	if frame.back then -- 1010
		self:emitSound("back") -- 1011
		return true -- 1012
	end -- 1012
	local target = getActiveTarget() -- 1015
	local rows = target:settingsRows() -- 1016
	local s = input.settings -- 1017
	if self.settingsSelected >= #rows then -- 1018
		self.settingsSelected = 0 -- 1019
	end -- 1019
	uiDraw:drawRect( -- 1022
		Rect(0, 0, w, h), -- 1022
		Color(10, 12, 19, 206) -- 1022
	) -- 1022
	local marginX = math.max( -- 1024
		96, -- 1024
		56 + math.max(frame.safe.left, frame.safe.right) -- 1024
	) -- 1024
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1025
	texts:put( -- 1026
		"banner", -- 1026
		target:settingsHeaderTitle(), -- 1026
		marginX, -- 1026
		topHeadY, -- 1026
		toColor(PALETTE.textBright), -- 1026
		0, -- 1026
		0.5, -- 1026
		"Left", -- 1026
		4, -- 1026
		0.96, -- 1026
		0.1 -- 1026
	) -- 1026
	local curSummary = target:settingsHeaderSummary(input.inputMode) -- 1027
	texts:put( -- 1028
		"xs", -- 1028
		curSummary, -- 1028
		marginX + 224, -- 1028
		topHeadY - 4, -- 1028
		toColor(PALETTE.amberCore), -- 1028
		0, -- 1028
		0.5, -- 1028
		"Left", -- 1028
		1.4, -- 1028
		0.88, -- 1028
		0.08 -- 1028
	) -- 1028
	drawHairline( -- 1029
		uiInkDraw, -- 1029
		uiArt, -- 1029
		"set_top_line", -- 1029
		w * 0.5, -- 1029
		topHeadY - 30, -- 1029
		w - marginX * 2, -- 1029
		PALETTE.silkDim, -- 1029
		0.6, -- 1029
		true, -- 1029
		2 -- 1029
	) -- 1029
	local panelW = math.min(760, w - marginX * 2) -- 1031
	local panelX = (w - panelW) * 0.5 -- 1032
	local rowH = 34 -- 1033
	local rowStep = #rows <= 6 and 48 or 39 -- 1034
	local firstY = topHeadY - 76 -- 1035
	local boxes = {} -- 1037
	local i = 0 -- 1038
	do -- 1038
		i = 0 -- 1039
		while i < #rows do -- 1039
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1040
			i = i + 1 -- 1039
		end -- 1039
	end -- 1039
	local prevSetSel = self.settingsSelected -- 1042
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1043
	if self.settingsSelected ~= prevSetSel then -- 1044
		self:emitSound("hover") -- 1045
	end -- 1045
	local function applyDelta(rowId, delta) -- 1048
		local res = target:applySettingsDelta(rowId, delta, s, input) -- 1049
		if res == "back" then -- 1050
			self:emitSound("back") -- 1051
			return true -- 1052
		end -- 1052
		if res == "audio" and self.onAudioSettingsChanged ~= nil then -- 1054
			self:onAudioSettingsChanged(input) -- 1055
		end -- 1055
		if res ~= "none" then -- 1057
			self:emitSound("toggle") -- 1058
		end -- 1058
		return false -- 1060
	end -- 1048
	do -- 1048
		i = 0 -- 1063
		while i < #rows do -- 1063
			local row = rows[i + 1] -- 1064
			local box = boxes[i + 1] -- 1065
			local cy = box.y + box.height * 0.5 -- 1066
			local active = self.settingsSelected == i -- 1067
			if active then -- 1069
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1070
				drawSilkRibbon( -- 1071
					uiDraw, -- 1071
					uiArt, -- 1071
					"set_rib_" .. tostring(i), -- 1071
					panelX + panelW * 0.5, -- 1071
					cy, -- 1071
					panelW + 24, -- 1071
					rowH, -- 1071
					PALETTE.rougeSoft, -- 1071
					0.48 * breathe, -- 1071
					0 -- 1071
				) -- 1071
				drawHairline( -- 1072
					uiInkDraw, -- 1072
					uiArt, -- 1072
					"set_line_" .. tostring(i), -- 1072
					panelX + panelW * 0.5, -- 1072
					box.y + 3, -- 1072
					panelW - 24, -- 1072
					PALETTE.silkLine, -- 1072
					0.42 * breathe, -- 1072
					false, -- 1072
					2 -- 1072
				) -- 1072
				drawBlossomDot( -- 1073
					uiInkDraw, -- 1073
					uiArt, -- 1073
					"set_dot_" .. tostring(i), -- 1073
					panelX + 18, -- 1073
					cy, -- 1073
					14, -- 1073
					PALETTE.rouge, -- 1073
					0.96, -- 1073
					4 -- 1073
				) -- 1073
				fillRadialGlow( -- 1074
					uiGlow, -- 1074
					panelX + 18, -- 1074
					cy, -- 1074
					20, -- 1074
					14, -- 1074
					toColor(PALETTE.rouge, 24 * breathe), -- 1074
					Color(182, 58, 56, 0), -- 1074
					10 -- 1074
				) -- 1074
			else -- 1074
				drawBlossomDot( -- 1076
					uiInkDraw, -- 1076
					uiArt, -- 1076
					"set_dot_" .. tostring(i), -- 1076
					panelX + 18, -- 1076
					cy, -- 1076
					7, -- 1076
					PALETTE.silkDim, -- 1076
					0.42, -- 1076
					3 -- 1076
				) -- 1076
			end -- 1076
			texts:put( -- 1079
				"sm", -- 1080
				row.title, -- 1081
				panelX + 42, -- 1082
				cy, -- 1083
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1084
				0, -- 1085
				0.5, -- 1086
				"Left", -- 1087
				active and 2.4 or 1.6, -- 1088
				active and 1 or 0.88, -- 1089
				0.08 -- 1090
			) -- 1090
			local val = target:settingsValueText(row.id, s, input.inputMode) -- 1093
			if val ~= "" then -- 1094
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1095
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1096
				texts:put( -- 1097
					"sm", -- 1097
					decorated, -- 1097
					panelX + panelW - 24, -- 1097
					cy, -- 1097
					toColor(valCol), -- 1097
					1, -- 1097
					0.5, -- 1097
					"Right", -- 1097
					1, -- 1097
					active and 1 or 0.86, -- 1097
					0.08 -- 1097
				) -- 1097
			end -- 1097
			i = i + 1 -- 1063
		end -- 1063
	end -- 1063
	local backY = 40 + frame.safe.bottom * 0.45 -- 1101
	local hint = target:settingsFooterHint(frame.mode, frame.layout) -- 1102
	texts:put( -- 1103
		"xs", -- 1103
		hint, -- 1103
		w * 0.5, -- 1103
		backY + 14, -- 1103
		toColor(PALETTE.textDim), -- 1103
		0.5, -- 1103
		0.5, -- 1103
		"Center", -- 1103
		1.2, -- 1103
		0.84, -- 1103
		0.08 -- 1103
	) -- 1103
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1105
	if hit >= 0 then -- 1106
		self.settingsSelected = hit -- 1107
		if applyDelta(rows[hit + 1].id, 1) then -- 1108
			return true -- 1109
		end -- 1109
		self:resetInput() -- 1111
		return false -- 1112
	end -- 1112
	if frame.keys.left or frame.prevTab then -- 1114
		local id = rows[self.settingsSelected + 1].id -- 1115
		if id ~= "back" then -- 1116
			applyDelta(id, -1) -- 1117
			self:resetInput() -- 1118
		end -- 1118
		return false -- 1120
	end -- 1120
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1122
		local id = rows[self.settingsSelected + 1].id -- 1123
		if applyDelta(id, 1) then -- 1124
			return true -- 1125
		end -- 1125
		self:resetInput() -- 1127
		return false -- 1128
	end -- 1128
	return false -- 1130
end -- 999
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1138
	if assistHintsEnabled == nil then -- 1149
		assistHintsEnabled = false -- 1149
	end -- 1149
	if safeUi == nil then -- 1151
		safeUi = ZERO_SAFE_INSETS -- 1151
	end -- 1151
	self.time = self.time + dt -- 1153
	local frame = self:readFrame(input, uiScale, safeUi) -- 1154
	if self.pauseShowControls then -- 1156
		local ctrlAct = self:drawControls( -- 1157
			frame, -- 1157
			uiDraw, -- 1157
			uiInkDraw, -- 1157
			uiArt, -- 1157
			uiGlow, -- 1157
			texts, -- 1157
			w, -- 1157
			h, -- 1157
			"返回暂停" -- 1157
		) -- 1157
		if ctrlAct.type == "backTitle" then -- 1158
			self.pauseShowControls = false -- 1159
			self:resetInput() -- 1160
		end -- 1160
		return {type = "none"} -- 1162
	end -- 1162
	if self.pauseShowSettings then -- 1165
		if self:drawPauseSettings( -- 1166
			frame, -- 1166
			input, -- 1166
			uiDraw, -- 1166
			uiInkDraw, -- 1166
			uiArt, -- 1166
			uiGlow, -- 1166
			texts, -- 1166
			w, -- 1166
			h -- 1166
		) then -- 1166
			self.pauseShowSettings = false -- 1167
			self:resetInput() -- 1168
		end -- 1168
		return {type = "none"} -- 1170
	end -- 1170
	if frame.back then -- 1173
		self.pauseShowControls = false -- 1174
		self.pauseShowSettings = false -- 1175
		self:emitSound("pauseClose") -- 1176
		return {type = "resume"} -- 1177
	end -- 1177
	local allowFs = canToggleFullscreen() -- 1180
	local allowQuit = canQuitApp() -- 1181
	local pauseItems = __TS__ArrayFilter( -- 1182
		PAUSE_ITEMS, -- 1182
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1182
	) -- 1182
	if self.pauseSelected >= #pauseItems then -- 1185
		self.pauseSelected = 0 -- 1186
	end -- 1186
	uiDraw:drawRect( -- 1189
		Rect(0, 0, w, h), -- 1189
		Color(8, 10, 16, 102) -- 1189
	) -- 1189
	fillHGradRect( -- 1190
		uiDraw, -- 1190
		0, -- 1190
		0, -- 1190
		w * 0.27 + frame.safe.left, -- 1190
		h, -- 1190
		Color(9, 11, 18, 232), -- 1190
		Color(10, 13, 21, 198) -- 1190
	) -- 1190
	fillHGradRect( -- 1191
		uiDraw, -- 1191
		w * 0.27 + frame.safe.left, -- 1191
		0, -- 1191
		w * 0.21, -- 1191
		h, -- 1191
		Color(10, 13, 21, 198), -- 1191
		Color(10, 13, 21, 0) -- 1191
	) -- 1191
	local menuX = 110 + frame.safe.left * 0.6 -- 1193
	local compact = #pauseItems > 8 -- 1194
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1195
	uiArt:tryPlace( -- 1196
		"ink_vstream", -- 1196
		"pause_vstream", -- 1196
		menuX - 32, -- 1196
		h * 0.5, -- 1196
		34, -- 1196
		h * 0.78, -- 1196
		{ -- 1196
			color = toColor(PALETTE.silkDim), -- 1197
			opacity = 0.48, -- 1197
			layer = 1 -- 1197
		} -- 1197
	) -- 1197
	drawMistCurve( -- 1199
		uiArt, -- 1199
		"pause_mist", -- 1199
		menuX + 118, -- 1199
		headY - 8, -- 1199
		290, -- 1199
		72, -- 1199
		PALETTE.jadeMist, -- 1199
		0.2, -- 1199
		-1 -- 1199
	) -- 1199
	texts:put( -- 1201
		"banner", -- 1201
		"暂歇", -- 1201
		menuX + 16, -- 1201
		headY, -- 1201
		toColor(PALETTE.textBright), -- 1201
		0, -- 1201
		0.5, -- 1201
		"Left", -- 1201
		10, -- 1201
		0.98, -- 1201
		0.1 -- 1201
	) -- 1201
	texts:put( -- 1202
		"xs", -- 1202
		"月夜暂驻 · 卷页留痕", -- 1202
		menuX + 18, -- 1202
		headY - 36, -- 1202
		toColor(PALETTE.textDim), -- 1202
		0, -- 1202
		0.5, -- 1202
		"Left", -- 1202
		2, -- 1202
		0.8, -- 1202
		0.08 -- 1202
	) -- 1202
	drawHairline( -- 1203
		uiInkDraw, -- 1203
		uiArt, -- 1203
		"pause_div", -- 1203
		menuX + 124, -- 1203
		headY - 60, -- 1203
		240, -- 1203
		PALETTE.silkDim, -- 1203
		0.58, -- 1203
		true, -- 1203
		2 -- 1203
	) -- 1203
	local rowStep = compact and 42 or 46 -- 1205
	local rowH = compact and 36 or 38 -- 1206
	local firstY = compact and headY - 112 or headY - 120 -- 1207
	local boxes = {} -- 1208
	local i = 0 -- 1209
	do -- 1209
		i = 0 -- 1210
		while i < #pauseItems do -- 1210
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1211
			i = i + 1 -- 1210
		end -- 1210
	end -- 1210
	local prevPauseSel = self.pauseSelected -- 1213
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1214
	if self.pauseSelected ~= prevPauseSel then -- 1215
		self:emitSound("hover") -- 1216
	end -- 1216
	do -- 1216
		i = 0 -- 1219
		while i < #pauseItems do -- 1219
			local iy = boxes[i + 1].y -- 1220
			local active = self.pauseSelected == i -- 1221
			local cy = iy + rowH * 0.5 -- 1222
			local shiftX = active and 10 or 0 -- 1223
			local item = pauseItems[i + 1] -- 1224
			local label = item.zh -- 1225
			if item.id == "assist" then -- 1226
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1227
			elseif item.id == "fullscreen" then -- 1228
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1229
			elseif item.id == "settings" then -- 1230
				label = getActiveTarget():settingsPauseLabel(input.settings) -- 1231
			end -- 1231
			if active then -- 1234
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1235
				drawSilkRibbon( -- 1236
					uiDraw, -- 1236
					uiArt, -- 1236
					"pause_rib_" .. tostring(i), -- 1236
					menuX + 116, -- 1236
					cy, -- 1236
					282, -- 1236
					rowH, -- 1236
					PALETTE.rougeSoft, -- 1236
					0.54 * breathe, -- 1236
					0 -- 1236
				) -- 1236
				drawHairline( -- 1237
					uiInkDraw, -- 1237
					uiArt, -- 1237
					"pause_line_" .. tostring(i), -- 1237
					menuX + 106, -- 1237
					iy + 3, -- 1237
					210, -- 1237
					PALETTE.silkLine, -- 1237
					0.42 * breathe, -- 1237
					false, -- 1237
					2 -- 1237
				) -- 1237
				drawBlossomDot( -- 1238
					uiInkDraw, -- 1238
					uiArt, -- 1238
					"pause_dot_" .. tostring(i), -- 1238
					menuX + 12, -- 1238
					cy, -- 1238
					15, -- 1238
					PALETTE.rouge, -- 1238
					0.96, -- 1238
					4 -- 1238
				) -- 1238
				fillRadialGlow( -- 1239
					uiGlow, -- 1239
					menuX + 12, -- 1239
					cy, -- 1239
					22, -- 1239
					16, -- 1239
					toColor(PALETTE.rouge, 26 * breathe), -- 1239
					Color(182, 58, 56, 0), -- 1239
					10 -- 1239
				) -- 1239
			else -- 1239
				drawBlossomDot( -- 1241
					uiInkDraw, -- 1241
					uiArt, -- 1241
					"pause_dot_" .. tostring(i), -- 1241
					menuX + 12, -- 1241
					cy, -- 1241
					8, -- 1241
					PALETTE.silkDim, -- 1241
					0.4, -- 1241
					3 -- 1241
				) -- 1241
			end -- 1241
			texts:put( -- 1244
				compact and "sm" or "md", -- 1245
				label, -- 1246
				menuX + 32 + shiftX, -- 1247
				cy, -- 1248
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1249
				0, -- 1250
				0.5, -- 1251
				"Left", -- 1252
				active and 3.4 or 2.2, -- 1253
				active and 1 or 0.88, -- 1254
				0.1 -- 1255
			) -- 1255
			i = i + 1 -- 1219
		end -- 1219
	end -- 1219
	local pauseFooter = getActiveTarget():pauseFooterHint(frame.mode, frame.layout) -- 1259
	texts:put( -- 1260
		"xs", -- 1260
		pauseFooter, -- 1260
		menuX + 12, -- 1260
		38 + frame.safe.bottom * 0.4, -- 1260
		toColor(PALETTE.textDim), -- 1260
		0, -- 1260
		0.5, -- 1260
		"Left", -- 1260
		1.2, -- 1260
		0.86, -- 1260
		0.08 -- 1260
	) -- 1260
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1262
	if hit >= 0 or frame.keys.confirm then -- 1263
		local idx = hit >= 0 and hit or self.pauseSelected -- 1264
		local id = pauseItems[idx + 1].id -- 1265
		if id == "controls" then -- 1266
			self.pauseShowControls = true -- 1267
			self:emitSound("confirm") -- 1268
			self:resetInput() -- 1269
			return {type = "none"} -- 1270
		end -- 1270
		if id == "settings" then -- 1272
			self:openPauseSettings() -- 1273
			self:emitSound("confirm") -- 1274
			return {type = "none"} -- 1275
		end -- 1275
		if id == "assist" then -- 1277
			if onToggleAssist ~= nil then -- 1278
				onToggleAssist() -- 1279
			end -- 1279
			self:emitSound("toggle") -- 1281
			self:resetInput() -- 1282
			return {type = "none"} -- 1283
		end -- 1283
		if id == "fullscreen" then -- 1285
			self:emitSound("toggle") -- 1286
			self:resetInput() -- 1287
			return {type = "toggleFullscreen"} -- 1288
		end -- 1288
		self.pauseShowControls = false -- 1290
		self.pauseShowSettings = false -- 1291
		if id == "resume" then -- 1292
			self:emitSound("pauseClose") -- 1292
			return {type = "resume"} -- 1292
		end -- 1292
		if id == "retry" then -- 1293
			self:emitSound("confirm") -- 1293
			return {type = "retry"} -- 1293
		end -- 1293
		if id == "chapters" then -- 1294
			self:emitSound("confirm") -- 1294
			return {type = "openChapters"} -- 1294
		end -- 1294
		if id == "quit" then -- 1295
			self:emitSound("back") -- 1295
			return {type = "quit"} -- 1295
		end -- 1295
		self:emitSound("back") -- 1296
		return {type = "toTitle"} -- 1297
	end -- 1297
	return {type = "none"} -- 1299
end -- 1138
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1306
	if frame.back then -- 1316
		return {type = "backTitle"} -- 1317
	end -- 1317
	uiDraw:drawRect( -- 1321
		Rect(0, 0, w, h), -- 1321
		Color(7, 9, 15, 214) -- 1321
	) -- 1321
	local cx = w * 0.5 -- 1322
	local reunion = self.epilogueEnding == "reunion" -- 1323
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1324
	drawMistCurve( -- 1325
		uiArt, -- 1325
		"ep_mist", -- 1325
		cx, -- 1325
		h * 0.62, -- 1325
		620, -- 1325
		120, -- 1325
		accentCol, -- 1325
		0.2, -- 1325
		0 -- 1325
	) -- 1325
	fillRadialGlow( -- 1326
		uiGlow, -- 1326
		cx, -- 1326
		h * 0.68, -- 1326
		220, -- 1326
		140, -- 1326
		toColor(accentCol, 28), -- 1326
		Color(10, 14, 22, 0), -- 1326
		18 -- 1326
	) -- 1326
	local titleY = h * 0.72 -- 1329
	texts:put( -- 1330
		"title", -- 1330
		"向西守望", -- 1330
		cx - 18, -- 1330
		titleY, -- 1330
		toColor(PALETTE.textBright), -- 1330
		0.5, -- 1330
		0.5, -- 1330
		"Center", -- 1330
		12, -- 1330
		0.98, -- 1330
		0.12 -- 1330
	) -- 1330
	drawLoneSeal( -- 1331
		uiInkDraw, -- 1331
		uiArt, -- 1331
		texts, -- 1331
		"ep_seal", -- 1331
		cx + 148, -- 1331
		titleY - 2, -- 1331
		24, -- 1331
		46, -- 1331
		"守", -- 1331
		"望", -- 1331
		PALETTE.sealRed, -- 1331
		PALETTE.sealText, -- 1331
		0.94, -- 1331
		4 -- 1331
	) -- 1331
	drawHairline( -- 1332
		uiInkDraw, -- 1332
		uiArt, -- 1332
		"ep_div", -- 1332
		cx, -- 1332
		titleY - 46, -- 1332
		360, -- 1332
		PALETTE.silkDim, -- 1332
		0.62, -- 1332
		true, -- 1332
		2 -- 1332
	) -- 1332
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1334
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1335
	texts:put( -- 1338
		"md", -- 1338
		endingTitle, -- 1338
		cx, -- 1338
		titleY - 76, -- 1338
		toColor(PALETTE.amberCore), -- 1338
		0.5, -- 1338
		0.5, -- 1338
		"Center", -- 1338
		3.2, -- 1338
		0.96, -- 1338
		0.08 -- 1338
	) -- 1338
	texts:put( -- 1339
		"sm", -- 1339
		verse, -- 1339
		cx, -- 1339
		titleY - 114, -- 1339
		toColor(PALETTE.textMid), -- 1339
		0.5, -- 1339
		0.5, -- 1339
		"Center", -- 1339
		1, -- 1339
		0.92, -- 1339
		0.08 -- 1339
	) -- 1339
	if self.epilogueBothCleared then -- 1341
		drawSilkVeil( -- 1342
			uiDraw, -- 1342
			uiArt, -- 1342
			"ep_well_veil", -- 1342
			cx, -- 1342
			titleY - 152, -- 1342
			560, -- 1342
			30, -- 1342
			PALETTE.inkWarm, -- 1342
			0.68, -- 1342
			0 -- 1342
		) -- 1342
		texts:put( -- 1343
			"xs", -- 1343
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1343
			cx, -- 1343
			titleY - 152, -- 1343
			toColor(PALETTE.cyanCore), -- 1343
			0.5, -- 1343
			0.5, -- 1343
			"Center", -- 1343
			1, -- 1343
			0.9, -- 1343
			0.08 -- 1343
		) -- 1343
	end -- 1343
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1346
	local btnW = 286 -- 1351
	local btnH = 44 -- 1352
	local gap = 14 -- 1353
	local baseY = math.max(150, h * 0.34) -- 1354
	local boxes = {} -- 1355
	local i = 0 -- 1356
	do -- 1356
		i = 0 -- 1357
		while i < #items do -- 1357
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1358
			i = i + 1 -- 1357
		end -- 1357
	end -- 1357
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1360
	do -- 1360
		i = 0 -- 1362
		while i < #items do -- 1362
			local box = boxes[i + 1] -- 1363
			local active = self.epilogueSelected == i -- 1364
			local cy = box.y + box.height * 0.5 -- 1365
			if active then -- 1366
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1367
				drawSilkRibbon( -- 1368
					uiDraw, -- 1368
					uiArt, -- 1368
					"ep_rib_" .. tostring(i), -- 1368
					cx, -- 1368
					cy, -- 1368
					btnW + 24, -- 1368
					btnH, -- 1368
					PALETTE.rougeSoft, -- 1368
					0.62 * breathe, -- 1368
					0 -- 1368
				) -- 1368
				drawHairline( -- 1369
					uiInkDraw, -- 1369
					uiArt, -- 1369
					"ep_line_" .. tostring(i), -- 1369
					cx, -- 1369
					box.y + 3, -- 1369
					btnW - 44, -- 1369
					PALETTE.silkLine, -- 1369
					0.48 * breathe, -- 1369
					false, -- 1369
					2 -- 1369
				) -- 1369
				drawBlossomDot( -- 1370
					uiInkDraw, -- 1370
					uiArt, -- 1370
					"ep_dot_" .. tostring(i), -- 1370
					box.x + 22, -- 1370
					cy, -- 1370
					13, -- 1370
					PALETTE.rouge, -- 1370
					0.96, -- 1370
					4 -- 1370
				) -- 1370
			else -- 1370
				drawSilkVeil( -- 1372
					uiDraw, -- 1372
					uiArt, -- 1372
					"ep_idle_" .. tostring(i), -- 1372
					cx, -- 1372
					cy, -- 1372
					btnW, -- 1372
					btnH - 2, -- 1372
					PALETTE.inkWash, -- 1372
					0.58, -- 1372
					0 -- 1372
				) -- 1372
				drawBlossomDot( -- 1373
					uiInkDraw, -- 1373
					uiArt, -- 1373
					"ep_dot_" .. tostring(i), -- 1373
					box.x + 22, -- 1373
					cy, -- 1373
					8, -- 1373
					PALETTE.silkDim, -- 1373
					0.42, -- 1373
					3 -- 1373
				) -- 1373
			end -- 1373
			texts:put( -- 1375
				"sm", -- 1376
				items[i + 1].zh, -- 1377
				cx + 6, -- 1378
				cy, -- 1379
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1380
				0.5, -- 1381
				0.5, -- 1382
				"Center", -- 1383
				active and 2.6 or 1.6, -- 1384
				active and 1 or 0.88, -- 1385
				0.08 -- 1386
			) -- 1386
			i = i + 1 -- 1362
		end -- 1362
	end -- 1362
	local footer = getActiveTarget():epilogueFooterHint(frame.mode, frame.layout) -- 1390
	texts:put( -- 1391
		"xs", -- 1391
		footer, -- 1391
		cx, -- 1391
		38 + frame.safe.bottom * 0.4, -- 1391
		toColor(PALETTE.textDim), -- 1391
		0.5, -- 1391
		0.5, -- 1391
		"Center", -- 1391
		1.2, -- 1391
		0.84, -- 1391
		0.08 -- 1391
	) -- 1391
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1393
	if hit >= 0 or frame.keys.confirm then -- 1394
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1395
		local id = items[idx + 1].id -- 1396
		if id == "history" then -- 1397
			return {type = "openHistory"} -- 1397
		end -- 1397
		if id == "replay" then -- 1398
			return {type = "replayStory"} -- 1398
		end -- 1398
		return {type = "backTitle"} -- 1399
	end -- 1399
	return {type = "none"} -- 1401
end -- 1306
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1408
	if frame.back then -- 1418
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1419
	end -- 1419
	local total = #HISTORY_CARDS -- 1422
	if frame.keys.left or frame.prevTab then -- 1423
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1424
	elseif frame.keys.right or frame.nextTab then -- 1425
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1426
	end -- 1426
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1428
	uiDraw:drawRect( -- 1430
		Rect(0, 0, w, h), -- 1430
		Color(7, 9, 15, 206) -- 1430
	) -- 1430
	local cx = w * 0.5 -- 1431
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1432
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1433
	local px = cx - pageW * 0.5 -- 1434
	local py = (h - pageH) * 0.5 + 14 -- 1435
	local midY = py + pageH * 0.5 -- 1436
	uiArt:tryPlace( -- 1438
		"ink_frame_mask", -- 1438
		"hist_shadow", -- 1438
		cx, -- 1438
		midY - 6, -- 1438
		pageW + 52, -- 1438
		pageH + 46, -- 1438
		{ -- 1438
			color = toColor(PALETTE.voidDark), -- 1439
			opacity = 0.84, -- 1439
			layer = -1 -- 1439
		} -- 1439
	) -- 1439
	if not uiArt:tryPlace( -- 1441
		"ink_song_paper", -- 1441
		"hist_paper", -- 1441
		cx, -- 1441
		midY, -- 1441
		pageW, -- 1441
		pageH, -- 1441
		{opacity = 0.98, layer = 1} -- 1441
	) then -- 1441
		uiDraw:drawRect( -- 1442
			Rect(px, py, pageW, pageH), -- 1442
			toColor(PALETTE.xuanPaper, 248), -- 1442
			1, -- 1442
			toColor(PALETTE.silkDim, 180) -- 1442
		) -- 1442
	end -- 1442
	fillRadialGlow( -- 1444
		uiGlow, -- 1444
		cx, -- 1444
		midY + 40, -- 1444
		260, -- 1444
		140, -- 1444
		Color(236, 224, 202, 16), -- 1444
		Color(236, 224, 202, 0), -- 1444
		14 -- 1444
	) -- 1444
	local inX = px + 42 -- 1447
	local inY = py + 32 -- 1448
	local inW = pageW - 84 -- 1449
	local inH = pageH - 64 -- 1450
	local redSilk = toColor(PALETTE.rouge, 118) -- 1451
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1452
	uiInkDraw:drawRect( -- 1453
		Rect(inX, inY, inW, inH), -- 1453
		Color(0, 0, 0, 0), -- 1453
		0.95, -- 1453
		redSilk -- 1453
	) -- 1453
	uiInkDraw:drawRect( -- 1454
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1454
		Color(0, 0, 0, 0), -- 1454
		0.55, -- 1454
		redSilkFaint -- 1454
	) -- 1454
	local headY = inY + inH - 30 -- 1457
	texts:put( -- 1458
		"md", -- 1458
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1458
		inX + 20, -- 1458
		headY, -- 1458
		toColor(PALETTE.xuanInk), -- 1458
		0, -- 1458
		0.5, -- 1458
		"Left", -- 1458
		2, -- 1458
		0.96, -- 1458
		0 -- 1458
	) -- 1458
	texts:put( -- 1459
		"xs", -- 1459
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1459
		inX + inW - 20, -- 1459
		headY, -- 1459
		toColor(PALETTE.rouge), -- 1459
		1, -- 1459
		0.5, -- 1459
		"Right", -- 1459
		1.8, -- 1459
		0.88, -- 1459
		0 -- 1459
	) -- 1459
	uiInkDraw:drawSegment( -- 1460
		Vec2(inX + 14, headY - 22), -- 1460
		Vec2(inX + inW - 14, headY - 22), -- 1460
		0.85, -- 1460
		redSilk -- 1460
	) -- 1460
	texts:put( -- 1463
		"xs", -- 1463
		card.subtitle, -- 1463
		inX + 20, -- 1463
		headY - 42, -- 1463
		toColor(PALETTE.xuanInkSub), -- 1463
		0, -- 1463
		0.5, -- 1463
		"Left", -- 1463
		1.4, -- 1463
		0.86, -- 1463
		0 -- 1463
	) -- 1463
	local function wrapZh(src, maxUnits) -- 1466
		local out = {} -- 1467
		local buf = "" -- 1468
		local units = 0 -- 1469
		local ci = 0 -- 1470
		while ci < #src do -- 1471
			local b = __TS__StringCharCodeAt(src, ci) -- 1472
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1473
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1474
			local u = b < 128 and 0.56 or 1.02 -- 1475
			if units + u > maxUnits and buf ~= "" then -- 1476
				out[#out + 1] = buf -- 1477
				buf = ch -- 1478
				units = u -- 1479
			else -- 1479
				buf = buf .. ch -- 1481
				units = units + u -- 1482
			end -- 1482
			ci = ci + step -- 1484
		end -- 1484
		if buf ~= "" then -- 1486
			out[#out + 1] = buf -- 1487
		end -- 1487
		return out -- 1489
	end -- 1466
	local charsPerLine = math.max( -- 1492
		24, -- 1492
		math.floor((inW - 44) / 20) -- 1492
	) -- 1492
	local cursorY = headY - 76 -- 1493
	local pi = 0 -- 1494
	do -- 1494
		pi = 0 -- 1495
		while pi < #card.paragraphs do -- 1495
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1496
			local li = 0 -- 1497
			do -- 1497
				li = 0 -- 1498
				while li < #lines do -- 1498
					texts:put( -- 1499
						"sm", -- 1499
						lines[li + 1], -- 1499
						inX + 22, -- 1499
						cursorY, -- 1499
						toColor(PALETTE.xuanInk), -- 1499
						0, -- 1499
						0.5, -- 1499
						"Left", -- 1499
						0.6, -- 1499
						0.94, -- 1499
						0 -- 1499
					) -- 1499
					cursorY = cursorY - 30 -- 1500
					li = li + 1 -- 1498
				end -- 1498
			end -- 1498
			cursorY = cursorY - 12 -- 1502
			pi = pi + 1 -- 1495
		end -- 1495
	end -- 1495
	local footY = inY + 26 -- 1506
	uiInkDraw:drawSegment( -- 1507
		Vec2(inX + 14, footY + 20), -- 1507
		Vec2(inX + inW - 14, footY + 20), -- 1507
		0.6, -- 1507
		redSilkFaint -- 1507
	) -- 1507
	texts:put( -- 1508
		"xs", -- 1508
		card.footnote, -- 1508
		inX + 20, -- 1508
		footY, -- 1508
		toColor(PALETTE.xuanInkSub), -- 1508
		0, -- 1508
		0.5, -- 1508
		"Left", -- 1508
		0.4, -- 1508
		0.84, -- 1508
		0 -- 1508
	) -- 1508
	local navY = math.max(30, py - 48) -- 1511
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1512
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1513
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1514
	local function drawNavBtn(box, tag, label) -- 1516
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1517
		drawSilkVeil( -- 1518
			uiDraw, -- 1518
			uiArt, -- 1518
			"hist_btn_" .. tag, -- 1518
			box.x + box.width * 0.5, -- 1518
			box.y + box.height * 0.5, -- 1518
			box.width, -- 1518
			box.height, -- 1518
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1518
			hover and 0.86 or 0.72, -- 1518
			2 -- 1518
		) -- 1518
		texts:put( -- 1519
			"xs", -- 1519
			label, -- 1519
			box.x + box.width * 0.5, -- 1519
			box.y + box.height * 0.5, -- 1519
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1519
			0.5, -- 1519
			0.5, -- 1519
			"Center", -- 1519
			1.4, -- 1519
			0.94, -- 1519
			0.08 -- 1519
		) -- 1519
		return hover and frame.click -- 1520
	end -- 1516
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1523
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1524
	end -- 1524
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1526
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1527
	end -- 1527
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1529
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1530
	end -- 1530
	if frame.keys.confirm then -- 1533
		if self.historyCardIndex + 1 < total then -- 1534
			self.historyCardIndex = self.historyCardIndex + 1 -- 1535
		else -- 1535
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1537
		end -- 1537
	end -- 1537
	return {type = "none"} -- 1540
end -- 1408
return ____exports -- 1408
