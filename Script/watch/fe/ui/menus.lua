-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
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
local TITLE_ITEMS = { -- 71
	{id = "start", zh = "开始游戏"}, -- 72
	{id = "chapters", zh = "选择章节"}, -- 73
	{id = "controls", zh = "操作说明"}, -- 74
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 75
	{id = "quit", zh = "退出游戏"} -- 76
} -- 76
local CHAPTERS = __TS__ArrayFilter( -- 80
	__TS__ArrayMap( -- 80
		ROOMS, -- 80
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 80
	), -- 80
	function(____, chapter) return chapter.room.key ~= "museum" and chapter.room.key ~= "street" and chapter.room.key ~= "checkpoint" end -- 81
) -- 81
local PAUSE_ITEMS = { -- 84
	{id = "resume", zh = "继续游戏"}, -- 85
	{id = "retry", zh = "重试检查点"}, -- 86
	{id = "controls", zh = "操作说明"}, -- 87
	{id = "assist", zh = "按键辅助：关"}, -- 88
	{id = "fullscreen", zh = "显示：窗口"}, -- 89
	{id = "chapters", zh = "选择章节"}, -- 90
	{id = "title", zh = "返回标题"}, -- 91
	{id = "quit", zh = "退出游戏"}, -- 92
	{id = "settings", zh = "操控设置"} -- 93
} -- 93
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 96
local EPIGRAPH_RIGHT = { -- 97
	"城", -- 97
	"破", -- 97
	"那", -- 97
	"天", -- 97
	"", -- 97
	"他", -- 97
	"留", -- 97
	"下", -- 97
	"断", -- 97
	"后" -- 97
} -- 97
local EPIGRAPH_LEFT = { -- 98
	"她", -- 98
	"独", -- 98
	"自", -- 98
	"走", -- 98
	"向", -- 98
	"北", -- 98
	"塔" -- 98
} -- 98
local function hitIndex(boxes, pointer, inside) -- 123
	if not inside then -- 124
		return -1 -- 125
	end -- 125
	return __TS__ArrayFindIndex( -- 127
		boxes, -- 127
		function(____, box) return box:containsPoint(pointer) end -- 127
	) -- 127
end -- 123
____exports.MenuRenderer = __TS__Class() -- 130
local MenuRenderer = ____exports.MenuRenderer -- 130
MenuRenderer.name = "MenuRenderer" -- 130
function MenuRenderer.prototype.____constructor(self) -- 130
	self.selected = 0 -- 131
	self.chapterSelected = 0 -- 132
	self.pauseSelected = 0 -- 133
	self.settingsSelected = 0 -- 134
	self.epilogueSelected = 0 -- 135
	self.epilogueEnding = "lamp" -- 136
	self.epilogueBothCleared = false -- 137
	self.historyCardIndex = 0 -- 138
	self.historyFromEpilogue = false -- 139
	self.hasSession = false -- 141
	self.controlsTab = "kbm" -- 143
	self.chaptersFromPause = false -- 155
	self.pauseShowControls = false -- 156
	self.pauseShowSettings = false -- 157
	self.controlsTabManual = false -- 158
	self.queuedKeys = {} -- 159
	self.queuedBack = false -- 160
	self.queuedSkip = false -- 161
	self.splashTime = 0 -- 162
	self.time = 0 -- 163
end -- 130
function MenuRenderer.prototype.emitSound(self, kind) -- 149
	if self.onUiSound ~= nil then -- 150
		self:onUiSound(kind) -- 151
	end -- 151
end -- 149
function MenuRenderer.prototype.resetSplash(self) -- 165
	self.splashTime = 0 -- 166
	self.queuedSkip = false -- 167
	self:resetInput() -- 168
end -- 165
function MenuRenderer.prototype.isShowingPauseControls(self) -- 171
	return self.pauseShowControls -- 172
end -- 171
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 175
	return self.pauseShowSettings -- 176
end -- 175
function MenuRenderer.prototype.openPauseSettings(self) -- 179
	self.pauseShowControls = false -- 180
	self.pauseShowSettings = true -- 181
	self.settingsSelected = 0 -- 182
	self:resetInput() -- 183
end -- 179
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 186
	self.chaptersFromPause = roomIndex ~= nil -- 187
	self.chapterSelected = math.max( -- 188
		0, -- 188
		__TS__ArrayFindIndex( -- 188
			CHAPTERS, -- 188
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 188
		) -- 188
	) -- 188
	self.pauseShowControls = false -- 189
	self.pauseShowSettings = false -- 190
	self:resetInput() -- 191
end -- 186
function MenuRenderer.prototype.openPause(self) -- 194
	self.pauseSelected = 0 -- 195
	self.pauseShowControls = false -- 196
	self.pauseShowSettings = false -- 197
	self:resetInput() -- 198
end -- 194
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 201
	if ending == nil then -- 201
		ending = "lamp" -- 201
	end -- 201
	if bothCleared == nil then -- 201
		bothCleared = false -- 201
	end -- 201
	self.epilogueEnding = ending -- 202
	self.epilogueBothCleared = bothCleared -- 203
	self.epilogueSelected = 0 -- 204
	self:resetInput() -- 205
end -- 201
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 208
	if fromEpilogue == nil then -- 208
		fromEpilogue = true -- 208
	end -- 208
	self.historyFromEpilogue = fromEpilogue -- 209
	self.historyCardIndex = 0 -- 210
	self:resetInput() -- 211
end -- 208
function MenuRenderer.prototype.triggerBack(self) -- 215
	self.queuedBack = true -- 216
end -- 215
function MenuRenderer.prototype.resetInput(self) -- 220
	self.queuedKeys = {} -- 221
	self.queuedBack = false -- 222
	self.queuedSkip = false -- 223
	self.controlsTabManual = false -- 224
end -- 220
function MenuRenderer.prototype.onKeyEvent(self, key) -- 228
	self.queuedSkip = true -- 229
	if key == "Up" or key == "W" then -- 230
		self.queuedKeys.up = true -- 231
	elseif key == "Down" or key == "S" then -- 232
		self.queuedKeys.down = true -- 233
	elseif key == "Left" or key == "A" then -- 234
		self.queuedKeys.left = true -- 235
	elseif key == "Right" or key == "D" then -- 236
		self.queuedKeys.right = true -- 237
	elseif key == "Return" or key == "Space" then -- 238
		self.queuedKeys.confirm = true -- 239
	elseif key == "Escape" then -- 240
		self.queuedBack = true -- 241
	end -- 241
end -- 228
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 245
	local queued = self.queuedKeys -- 246
	local useUiPtr = input.uiInside or input.uiPressed -- 249
	local rawX = useUiPtr and input.uiX or input.mx -- 250
	local rawY = useUiPtr and input.uiY or input.my -- 251
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 252
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 253
	local ____useUiPtr_0 -- 254
	if useUiPtr then -- 254
		____useUiPtr_0 = input.uiInside -- 254
	else -- 254
		____useUiPtr_0 = input.inside -- 254
	end -- 254
	local inside = ____useUiPtr_0 -- 254
	local ____useUiPtr_1 -- 255
	if useUiPtr then -- 255
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 255
	else -- 255
		____useUiPtr_1 = input.inside and input.fire.pressed -- 255
	end -- 255
	local click = ____useUiPtr_1 -- 255
	local touchMode = input:isTouchMode() -- 256
	local frame = { -- 258
		keys = { -- 259
			up = queued.up == true or input.navUp, -- 260
			down = queued.down == true or input.navDown, -- 261
			left = queued.left == true or input.navLeft, -- 262
			right = queued.right == true or input.navRight, -- 263
			confirm = queued.confirm == true or input.navConfirm -- 264
		}, -- 264
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 266
		prevTab = input.navPrevTab, -- 267
		nextTab = input.navNextTab, -- 268
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 269
		pointer = Vec2(rawX / scale, rawY / scale), -- 270
		inside = inside, -- 271
		click = click, -- 272
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 273
		mode = input.inputMode, -- 274
		layout = input.gamepadLayout, -- 275
		safe = safe -- 276
	} -- 276
	self.queuedKeys = {} -- 278
	self.queuedBack = false -- 279
	self.queuedSkip = false -- 280
	return frame -- 281
end -- 245
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 284
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 285
	if frame.click and hit >= 0 then -- 286
		return hit -- 287
	end -- 287
	if frame.keys.up then -- 289
		return (selected + #boxes - 1) % #boxes -- 290
	end -- 290
	if frame.keys.down then -- 292
		return (selected + 1) % #boxes -- 293
	end -- 293
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 295
end -- 284
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 298
	if safeUi == nil then -- 314
		safeUi = ZERO_SAFE_INSETS -- 314
	end -- 314
	self.time = self.time + dt -- 316
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 317
	if screen ~= "splash" or splashDissolving then -- 318
		local artW = math.max(w, h * 16 / 9) -- 319
		local artH = artW * 9 / 16 -- 320
		if not backdropArt:tryPlace( -- 321
			"title_backdrop", -- 321
			"menu_landscape", -- 321
			w * 0.5, -- 321
			(h - artH) * 0.5, -- 321
			artW, -- 321
			artH -- 321
		) then -- 321
			stage:drawMenuBackdrop( -- 322
				bgDraw, -- 322
				bgGlow, -- 322
				w, -- 322
				h, -- 322
				self.time -- 322
			) -- 322
		end -- 322
	end -- 322
	local frame = self:readFrame(input, uiScale, safeUi) -- 326
	w = w / uiScale -- 327
	h = h / uiScale -- 328
	if screen == "splash" then -- 330
		return self:drawSplash( -- 331
			dt, -- 331
			frame, -- 331
			uiDraw, -- 331
			uiArt, -- 331
			texts, -- 331
			w, -- 331
			h -- 331
		) -- 331
	end -- 331
	if screen == "title" then -- 333
		return self:drawTitle( -- 334
			frame, -- 334
			uiDraw, -- 334
			uiInkDraw, -- 334
			uiArt, -- 334
			uiGlow, -- 334
			texts, -- 334
			w, -- 334
			h -- 334
		) -- 334
	end -- 334
	if screen == "chapters" then -- 336
		return self:drawChapters( -- 337
			frame, -- 337
			uiDraw, -- 337
			uiInkDraw, -- 337
			uiArt, -- 337
			uiGlow, -- 337
			texts, -- 337
			w, -- 337
			h -- 337
		) -- 337
	end -- 337
	if screen == "epilogue" then -- 339
		return self:drawEpilogue( -- 340
			frame, -- 340
			uiDraw, -- 340
			uiInkDraw, -- 340
			uiArt, -- 340
			uiGlow, -- 340
			texts, -- 340
			w, -- 340
			h -- 340
		) -- 340
	end -- 340
	if screen == "history" then -- 342
		return self:drawHistory( -- 343
			frame, -- 343
			uiDraw, -- 343
			uiInkDraw, -- 343
			uiArt, -- 343
			uiGlow, -- 343
			texts, -- 343
			w, -- 343
			h -- 343
		) -- 343
	end -- 343
	return self:drawControls( -- 345
		frame, -- 345
		uiDraw, -- 345
		uiInkDraw, -- 345
		uiArt, -- 345
		uiGlow, -- 345
		texts, -- 345
		w, -- 345
		h -- 345
	) -- 345
end -- 298
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 354
	local safeDt = math.min( -- 363
		0.1, -- 363
		math.max(0, dt) -- 363
	) -- 363
	self.splashTime = self.splashTime + safeDt -- 364
	local t = self.splashTime -- 365
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 367
	if wantSkip or t >= 4.65 then -- 368
		self.splashTime = 0 -- 369
		return {type = "splashDone"} -- 370
	end -- 370
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 373
	local bgR = t < 2.2 and 13 or 11 -- 374
	local bgG = t < 2.2 and 16 or 13 -- 375
	local bgB = t < 2.2 and 24 or 19 -- 376
	uiDraw:drawRect( -- 377
		Rect(0, 0, w, h), -- 377
		Color( -- 377
			bgR, -- 377
			bgG, -- 377
			bgB, -- 377
			math.floor(255 * fadeOutCurtain + 0.5) -- 377
		) -- 377
	) -- 377
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 379
		if localT <= 0 or localT >= endT then -- 380
			return 0 -- 380
		end -- 380
		if localT < fadeIn then -- 381
			local u = localT / fadeIn -- 382
			return u * u * (3 - 2 * u) -- 383
		end -- 383
		if localT <= holdEnd then -- 385
			return 1 -- 385
		end -- 385
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 386
		return 1 - u * u * (3 - 2 * u) -- 387
	end -- 379
	if t < 2.2 then -- 390
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 391
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 392
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 393
		if not uiArt:tryPlace( -- 394
			"brand_team_logo", -- 394
			"splash_team_logo", -- 394
			w * 0.5, -- 394
			h * 0.54, -- 394
			logoH * 2, -- 394
			logoH, -- 394
			{opacity = alpha, layer = 2} -- 394
		) then -- 394
			texts:put( -- 395
				"banner", -- 395
				"OUTSIDER", -- 395
				w * 0.5, -- 395
				h * 0.52, -- 395
				toColor(PALETTE.textBright), -- 395
				0.5, -- 395
				0.5, -- 395
				"Center", -- 395
				6, -- 395
				alpha, -- 395
				0 -- 395
			) -- 395
		end -- 395
		texts:put( -- 397
			"xs", -- 397
			"Powered by Dora SSR", -- 397
			w * 0.5, -- 397
			58 + frame.safe.bottom * 0.4, -- 397
			toColor(PALETTE.textDim), -- 397
			0.5, -- 397
			0.5, -- 397
			"Center", -- 397
			1.8, -- 397
			alpha * 0.62, -- 397
			0 -- 397
		) -- 397
	elseif t < 4.25 then -- 398
		local localT = t - 2.2 -- 399
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 400
		local sway = math.sin(localT * 1.1) * 8 -- 401
		drawMistCurve( -- 402
			uiArt, -- 402
			"splash_game_mist", -- 402
			w * 0.5 + sway, -- 402
			h * 0.46, -- 402
			560, -- 402
			110, -- 402
			PALETTE.jadeMist, -- 402
			0.16 * alpha, -- 402
			1 -- 402
		) -- 402
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 403
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 404
		if not uiArt:tryPlace( -- 405
			"brand_game_logo_h", -- 405
			"splash_game_logo", -- 405
			w * 0.5, -- 405
			h * 0.52, -- 405
			logoH * 2.4, -- 405
			logoH, -- 405
			{opacity = alpha, layer = 2} -- 405
		) then -- 405
			texts:put( -- 406
				"title", -- 406
				"向西守望", -- 406
				w * 0.5, -- 406
				h * 0.52, -- 406
				toColor(PALETTE.textBright), -- 406
				0.5, -- 406
				0.5, -- 406
				"Center", -- 406
				8, -- 406
				alpha, -- 406
				0 -- 406
			) -- 406
		end -- 406
	end -- 406
	if t >= 0.35 and t < 4.15 then -- 410
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 411
		local skipText = getActiveTarget():splashSkipHint(frame.mode, frame.layout) -- 412
		texts:put( -- 413
			"xs", -- 413
			skipText, -- 413
			w - 48 - frame.safe.right * 0.6, -- 413
			36 + frame.safe.bottom * 0.4, -- 413
			toColor(PALETTE.textDim), -- 413
			1, -- 413
			0.5, -- 413
			"Right", -- 413
			1.4, -- 413
			hintA, -- 413
			0 -- 413
		) -- 413
	end -- 413
	return {type = "none"} -- 416
end -- 354
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 419
	fillHGradRect( -- 429
		uiDraw, -- 429
		0, -- 429
		0, -- 429
		w * 0.22 + frame.safe.left * 0.5, -- 429
		h, -- 429
		Color(9, 11, 18, 192), -- 429
		Color(9, 11, 18, 116) -- 429
	) -- 429
	fillHGradRect( -- 430
		uiDraw, -- 430
		w * 0.22 + frame.safe.left * 0.5, -- 430
		0, -- 430
		w * 0.28, -- 430
		h, -- 430
		Color(9, 11, 18, 116), -- 430
		Color(9, 11, 18, 0) -- 430
	) -- 430
	fillVGradRect( -- 431
		uiDraw, -- 431
		0, -- 431
		0, -- 431
		w, -- 431
		78, -- 431
		Color(8, 10, 16, 138), -- 431
		Color(8, 10, 16, 0) -- 431
	) -- 431
	local extraH = math.max(0, h - 720) -- 433
	local titleX = 148 + frame.safe.left * 0.6 -- 434
	local topY = h - 104 - frame.safe.top * 0.4 -- 435
	local charStep = 66 -- 436
	local sway = math.sin(self.time * 0.7) * 5 -- 437
	drawMistCurve( -- 438
		uiArt, -- 438
		"title_mist_wisp", -- 438
		titleX + 86 + sway, -- 438
		topY - 122, -- 438
		340, -- 438
		82, -- 438
		PALETTE.jadeMist, -- 438
		0.2, -- 438
		-1 -- 438
	) -- 438
	uiArt:tryPlace( -- 439
		"ink_petal_mist", -- 439
		"title_petals", -- 439
		titleX + 12, -- 439
		topY - 102, -- 439
		230, -- 439
		210, -- 439
		{ -- 439
			color = toColor(PALETTE.inkMist), -- 440
			opacity = 0.4, -- 440
			layer = -1 -- 440
		} -- 440
	) -- 440
	local placedBrandTitle = uiArt:tryPlace( -- 444
		"brand_game_logo_v", -- 444
		"title_brand_v", -- 444
		titleX + 22, -- 444
		topY - 106, -- 444
		240, -- 444
		304, -- 444
		{opacity = 0.98, layer = 3} -- 444
	) -- 444
	if not placedBrandTitle then -- 447
		uiArt:tryPlace( -- 448
			"ink_vstream", -- 448
			"title_vstream", -- 448
			titleX - 48, -- 448
			topY - 100, -- 448
			34, -- 448
			290, -- 448
			{ -- 448
				color = toColor(PALETTE.silkDim), -- 449
				opacity = 0.48, -- 449
				layer = 1 -- 449
			} -- 449
		) -- 449
		local c = 0 -- 451
		do -- 451
			c = 0 -- 452
			while c < #VERTICAL_TITLE do -- 452
				texts:put( -- 453
					"title", -- 454
					VERTICAL_TITLE[c + 1], -- 455
					titleX, -- 456
					topY - c * charStep, -- 457
					toColor(PALETTE.textBright), -- 458
					0.5, -- 459
					0.5, -- 460
					"Center", -- 461
					0, -- 462
					0.98, -- 463
					0.1, -- 464
					Color(8, 10, 16, 210) -- 465
				) -- 465
				c = c + 1 -- 452
			end -- 452
		end -- 452
		drawLoneSeal( -- 468
			uiInkDraw, -- 469
			uiArt, -- 470
			texts, -- 471
			"title_lone_seal", -- 472
			titleX + 46, -- 473
			topY - 3 * charStep + 8, -- 474
			26, -- 475
			52, -- 476
			"守", -- 477
			"望", -- 478
			PALETTE.sealRed, -- 479
			PALETTE.sealText, -- 480
			0.94, -- 481
			4 -- 482
		) -- 482
	end -- 482
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 487
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 488
	local poemStep = 22 -- 489
	local p = 0 -- 490
	do -- 490
		p = 0 -- 491
		while p < #EPIGRAPH_RIGHT do -- 491
			local ch = EPIGRAPH_RIGHT[p + 1] -- 492
			if ch ~= "" then -- 493
				texts:put( -- 494
					"xs", -- 494
					ch, -- 494
					colRightX, -- 494
					topY - 22 - p * poemStep, -- 494
					toColor(PALETTE.textMid), -- 494
					0.5, -- 494
					0.5, -- 494
					"Center", -- 494
					0, -- 494
					0.86, -- 494
					0.08 -- 494
				) -- 494
			end -- 494
			p = p + 1 -- 491
		end -- 491
	end -- 491
	do -- 491
		p = 0 -- 497
		while p < #EPIGRAPH_LEFT do -- 497
			texts:put( -- 498
				"xs", -- 498
				EPIGRAPH_LEFT[p + 1], -- 498
				colLeftX, -- 498
				topY - 68 - p * poemStep, -- 498
				toColor(PALETTE.amberCore), -- 498
				0.5, -- 498
				0.5, -- 498
				"Center", -- 498
				0, -- 498
				0.9, -- 498
				0.08 -- 498
			) -- 498
			p = p + 1 -- 497
		end -- 497
	end -- 497
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 502
		TITLE_ITEMS, -- 504
		function(____, it) return it.id ~= "quit" end -- 504
	) -- 504
	local items = self.hasSession and ({ -- 505
		{id = "continue", zh = "继续游戏"}, -- 506
		table.unpack(baseItems) -- 506
	}) or baseItems -- 507
	if self.selected >= #items then -- 508
		self.selected = 0 -- 509
	end -- 509
	local menuX = 112 + frame.safe.left * 0.6 -- 511
	local btnW = 280 -- 512
	local btnH = frame.mode == "touch" and 44 or 40 -- 513
	local gap = self.hasSession and 6 or 8 -- 514
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 515
	local boxes = {} -- 516
	local i = 0 -- 517
	do -- 517
		i = 0 -- 518
		while i < #items do -- 518
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 519
			i = i + 1 -- 518
		end -- 518
	end -- 518
	local prevTitleSel = self.selected -- 521
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 522
	if self.selected ~= prevTitleSel then -- 523
		self:emitSound("hover") -- 524
	end -- 524
	do -- 524
		i = 0 -- 527
		while i < #items do -- 527
			local by = boxes[i + 1].y -- 528
			local active = self.selected == i -- 529
			local cy = by + btnH * 0.5 -- 530
			local shiftX = active and 10 or 0 -- 531
			if active then -- 533
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 534
				drawSilkRibbon( -- 535
					uiDraw, -- 535
					uiArt, -- 535
					"title_rib_red_" .. tostring(i), -- 535
					menuX + 124, -- 535
					cy, -- 535
					290, -- 535
					btnH, -- 535
					PALETTE.rougeSoft, -- 535
					0.52 * breathe, -- 535
					0 -- 535
				) -- 535
				drawHairline( -- 536
					uiInkDraw, -- 536
					uiArt, -- 536
					"title_rib_line_" .. tostring(i), -- 536
					menuX + 114, -- 536
					by + 4, -- 536
					230, -- 536
					PALETTE.silkLine, -- 536
					0.42 * breathe, -- 536
					false, -- 536
					2 -- 536
				) -- 536
				drawBlossomDot( -- 537
					uiInkDraw, -- 537
					uiArt, -- 537
					"title_dot_" .. tostring(i), -- 537
					menuX + 14, -- 537
					cy, -- 537
					16, -- 537
					PALETTE.rouge, -- 537
					0.96, -- 537
					4 -- 537
				) -- 537
				fillRadialGlow( -- 538
					uiGlow, -- 538
					menuX + 14, -- 538
					cy, -- 538
					22, -- 538
					16, -- 538
					toColor(PALETTE.rouge, 28 * breathe), -- 538
					Color(182, 58, 56, 0), -- 538
					10 -- 538
				) -- 538
			else -- 538
				drawBlossomDot( -- 540
					uiInkDraw, -- 540
					uiArt, -- 540
					"title_dot_" .. tostring(i), -- 540
					menuX + 14, -- 540
					cy, -- 540
					8, -- 540
					PALETTE.silkDim, -- 540
					0.4, -- 540
					3 -- 540
				) -- 540
			end -- 540
			texts:put( -- 543
				"md", -- 544
				items[i + 1].zh, -- 545
				menuX + 34 + shiftX, -- 546
				cy, -- 547
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 548
				0, -- 549
				0.5, -- 550
				"Left", -- 551
				active and 4.4 or 2.8, -- 552
				active and 1 or 0.88, -- 553
				0.1 -- 554
			) -- 554
			i = i + 1 -- 527
		end -- 527
	end -- 527
	local titleHint = getActiveTarget():titleFooterHint(frame.mode, frame.layout) -- 558
	texts:put( -- 559
		"xs", -- 559
		titleHint, -- 559
		menuX + 12, -- 559
		42 + frame.safe.bottom * 0.45, -- 559
		toColor(PALETTE.textDim), -- 559
		0, -- 559
		0.5, -- 559
		"Left", -- 559
		1.4, -- 559
		0.88, -- 559
		0.08 -- 559
	) -- 559
	local badgeRight = w - frame.safe.right * 0.5 -- 562
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 563
	fillHGradRect( -- 564
		uiDraw, -- 564
		badgeRight - 270, -- 564
		0, -- 564
		270 + frame.safe.right * 0.5, -- 564
		86, -- 564
		Color(8, 10, 16, 0), -- 564
		Color(8, 10, 16, 204) -- 564
	) -- 564
	uiArt:tryPlace( -- 565
		"brand_team_badge", -- 565
		"title_team_badge", -- 565
		badgeRight - 118, -- 565
		badgeY, -- 565
		168, -- 565
		54, -- 565
		{opacity = 0.95, layer = 3} -- 565
	) -- 565
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 569
	if hit >= 0 or frame.keys.confirm then -- 570
		local idx = hit >= 0 and hit or self.selected -- 571
		local id = items[idx + 1].id -- 572
		if id == "continue" then -- 573
			self:emitSound("start") -- 573
			return {type = "continue"} -- 573
		end -- 573
		if id == "trial" then -- 574
			self:emitSound("start") -- 574
			return {type = "trial"} -- 574
		end -- 574
		if id == "start" then -- 575
			self:emitSound("start") -- 575
			return {type = "start"} -- 575
		end -- 575
		if id == "chapters" then -- 576
			self:emitSound("confirm") -- 576
			return {type = "openChapters"} -- 576
		end -- 576
		if id == "quit" then -- 577
			self:emitSound("back") -- 577
			return {type = "quit"} -- 577
		end -- 577
		self:emitSound("confirm") -- 578
		return {type = "openControls"} -- 579
	end -- 579
	return {type = "none"} -- 581
end -- 419
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 584
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 594
	if frame.back then -- 595
		self:emitSound("back") -- 596
		return back -- 597
	end -- 597
	local extraH = math.max(0, h - 720) -- 600
	local marginX = math.max( -- 601
		96, -- 601
		56 + math.max(frame.safe.left, frame.safe.right) -- 601
	) -- 601
	local splitTrack = #CHAPTERS > 8 -- 602
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 603
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 604
	local rowGap = 68 -- 605
	local trackX0 = marginX + 34 -- 606
	local trackX1 = w - marginX - 34 -- 607
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 608
	local stationBoxes = {} -- 610
	local s = 0 -- 611
	do -- 611
		s = 0 -- 612
		while s < #CHAPTERS do -- 612
			local sx = trackX0 + s % perRow * stepX -- 613
			local sy = trackY - math.floor(s / perRow) * rowGap -- 614
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 615
			s = s + 1 -- 612
		end -- 612
	end -- 612
	local prevSelected = self.chapterSelected -- 618
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 619
	local keys = frame.keys -- 620
	if frame.click and hitStation >= 0 then -- 621
		self.chapterSelected = hitStation -- 622
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 623
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 624
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 625
	elseif keys.down and self.chapterSelected < perRow then -- 626
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 627
	elseif keys.up and self.chapterSelected >= perRow then -- 628
		self.chapterSelected = self.chapterSelected - perRow -- 629
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 630
		self.chapterSelected = hitStation -- 631
	end -- 631
	if self.chapterSelected ~= prevSelected then -- 633
		self:emitSound("hover") -- 634
	end -- 634
	uiDraw:drawRect( -- 637
		Rect(0, 0, w, h), -- 637
		Color(10, 12, 19, 198) -- 637
	) -- 637
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 639
	texts:put( -- 640
		"banner", -- 640
		"选择章节", -- 640
		marginX, -- 640
		topHeadY, -- 640
		toColor(PALETTE.textBright), -- 640
		0, -- 640
		0.5, -- 640
		"Left", -- 640
		4.5, -- 640
		0.96, -- 640
		0.1 -- 640
	) -- 640
	drawHairline( -- 641
		uiInkDraw, -- 641
		uiArt, -- 641
		"chap_top_line", -- 641
		w * 0.5, -- 641
		topHeadY - 34, -- 641
		w - marginX * 2, -- 641
		PALETTE.silkDim, -- 641
		0.6, -- 641
		true, -- 641
		2 -- 641
	) -- 641
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 643
	local theme = themeOf(activeRoom.key) -- 644
	local winX = marginX -- 645
	local winY = 266 + extraH * 0.44 -- 646
	local winW = math.min( -- 647
		520, -- 647
		math.max(360, (w - marginX * 2) * 0.46) -- 647
	) -- 647
	local winH = 296 -- 648
	local winBox = Rect(winX, winY, winW, winH) -- 649
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 650
	uiArt:tryPlace( -- 652
		"ink_frame_mask", -- 652
		"chap_win_shadow", -- 652
		winX + winW * 0.5, -- 652
		winY + winH * 0.5, -- 652
		winW + 40, -- 652
		winH + 34, -- 652
		{ -- 652
			color = toColor(PALETTE.inkVoid), -- 653
			opacity = 0.88, -- 653
			layer = -2 -- 653
		} -- 653
	) -- 653
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 655
	uiArt:tryPlace( -- 656
		bgSlot, -- 656
		"chap_win_art", -- 656
		winX + winW * 0.5, -- 656
		winY + 4, -- 656
		winW - 8, -- 656
		winH - 8, -- 656
		{opacity = 0.92, layer = -1} -- 656
	) -- 656
	fillVGradRect( -- 659
		uiInkDraw, -- 659
		winX, -- 659
		winY, -- 659
		winW, -- 659
		56, -- 659
		Color(10, 12, 19, 200), -- 659
		Color(10, 12, 19, 0) -- 659
	) -- 659
	fillVGradRect( -- 660
		uiInkDraw, -- 660
		winX, -- 660
		winY + winH - 36, -- 660
		winW, -- 660
		36, -- 660
		Color(10, 12, 19, 0), -- 660
		Color(10, 12, 19, 130) -- 660
	) -- 660
	fillHGradRect( -- 661
		uiInkDraw, -- 661
		winX, -- 661
		winY, -- 661
		34, -- 661
		winH, -- 661
		Color(10, 12, 19, 135), -- 661
		Color(10, 12, 19, 0) -- 661
	) -- 661
	fillHGradRect( -- 662
		uiInkDraw, -- 662
		winX + winW - 34, -- 662
		winY, -- 662
		34, -- 662
		winH, -- 662
		Color(10, 12, 19, 0), -- 662
		Color(10, 12, 19, 135) -- 662
	) -- 662
	drawFiligreeCorners( -- 663
		uiInkDraw, -- 663
		uiArt, -- 663
		"chap_win_frame", -- 663
		winX, -- 663
		winY, -- 663
		winW, -- 663
		winH, -- 663
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 663
		winHover and 0.92 or 0.72, -- 663
		34, -- 663
		true, -- 663
		3 -- 663
	) -- 663
	texts:put( -- 665
		"xs", -- 665
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 665
		winX + 20, -- 665
		winY + 22, -- 665
		toColor(PALETTE.textMid), -- 665
		0, -- 665
		0.5, -- 665
		"Left", -- 665
		1.8, -- 665
		0.9, -- 665
		0.08 -- 665
	) -- 665
	local infoX = winX + winW + 40 -- 667
	local infoW = math.max(240, w - marginX - infoX) -- 668
	local infoCenterY = winY + winH * 0.5 -- 669
	drawMistCurve( -- 670
		uiArt, -- 670
		"chap_info_mist", -- 670
		infoX + infoW * 0.5, -- 670
		infoCenterY + 36, -- 670
		math.min(420, infoW + 24), -- 670
		88, -- 670
		theme.accent, -- 670
		0.22, -- 670
		-1 -- 670
	) -- 670
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 672
	texts:put( -- 673
		"xs", -- 673
		theme.volumeTagZh, -- 673
		infoX, -- 673
		winY + winH - 44, -- 673
		toColor(volCol), -- 673
		0, -- 673
		0.5, -- 673
		"Left", -- 673
		2.8, -- 673
		0.92, -- 673
		0.08 -- 673
	) -- 673
	local sep = " · " -- 675
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 676
	local titleY = winY + winH - 98 -- 677
	if theme.backdropKey ~= nil then -- 678
		texts:put( -- 679
			"lg", -- 679
			theme.titleZh, -- 679
			infoX, -- 679
			titleY, -- 679
			toColor(PALETTE.textBright) -- 679
		) -- 679
	elseif sIdx > 0 then -- 680
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 681
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 682
		local lw = visualTextWidth(leftPart, 40) -- 683
		texts:put( -- 684
			"banner", -- 684
			leftPart, -- 684
			infoX, -- 684
			titleY, -- 684
			toColor(PALETTE.textBright), -- 684
			0, -- 684
			0.5, -- 684
			"Left", -- 684
			2, -- 684
			1, -- 684
			0.1 -- 684
		) -- 684
		drawBlossomDot( -- 685
			uiInkDraw, -- 685
			uiArt, -- 685
			"chap_title_dot", -- 685
			infoX + lw + 16, -- 685
			titleY - 2, -- 685
			11, -- 685
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 685
			0.9, -- 685
			4 -- 685
		) -- 685
		texts:put( -- 686
			"banner", -- 686
			rightPart, -- 686
			infoX + lw + 32, -- 686
			titleY, -- 686
			toColor(PALETTE.textBright), -- 686
			0, -- 686
			0.5, -- 686
			"Left", -- 686
			2, -- 686
			1, -- 686
			0.1 -- 686
		) -- 686
	else -- 686
		texts:put( -- 688
			"banner", -- 688
			theme.titleZh, -- 688
			infoX, -- 688
			titleY, -- 688
			toColor(PALETTE.textBright), -- 688
			0, -- 688
			0.5, -- 688
			"Left", -- 688
			2.4, -- 688
			1, -- 688
			0.1 -- 688
		) -- 688
	end -- 688
	drawHairline( -- 691
		uiInkDraw, -- 691
		uiArt, -- 691
		"chap_info_line", -- 691
		infoX + math.min(185, infoW * 0.5), -- 691
		titleY - 36, -- 691
		math.min(370, infoW), -- 691
		PALETTE.silkDim, -- 691
		0.58, -- 691
		false, -- 691
		2 -- 691
	) -- 691
	texts:put( -- 692
		"sm", -- 692
		theme.introWhisper, -- 692
		infoX, -- 692
		titleY - 72, -- 692
		toColor(PALETTE.textMid), -- 692
		0, -- 692
		0.5, -- 692
		"Left", -- 692
		0.8, -- 692
		0.94, -- 692
		0.08 -- 692
	) -- 692
	local goX = infoX -- 694
	local goY = winY + 26 -- 695
	local goW = 220 -- 696
	local goH = 42 -- 697
	local goBox = Rect(goX, goY, goW, goH) -- 698
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 699
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 700
	drawSilkRibbon( -- 701
		uiDraw, -- 701
		uiArt, -- 701
		"chap_go_rib", -- 701
		goX + 106, -- 701
		goY + 21, -- 701
		250, -- 701
		40, -- 701
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 701
		(goHover and 0.68 or 0.46) * breathe, -- 701
		0 -- 701
	) -- 701
	drawHairline( -- 702
		uiInkDraw, -- 702
		uiArt, -- 702
		"chap_go_line", -- 702
		goX + 94, -- 702
		goY + 3, -- 702
		196, -- 702
		PALETTE.silkLine, -- 702
		goHover and 0.68 or 0.4, -- 702
		false, -- 702
		2 -- 702
	) -- 702
	drawBlossomDot( -- 703
		uiInkDraw, -- 703
		uiArt, -- 703
		"chap_go_dot", -- 703
		goX + 14, -- 703
		goY + 21, -- 703
		14, -- 703
		PALETTE.rouge, -- 703
		0.96, -- 703
		4 -- 703
	) -- 703
	texts:put( -- 704
		"md", -- 704
		"入此卷章", -- 704
		goX + 34, -- 704
		goY + 21, -- 704
		toColor(PALETTE.textBright), -- 704
		0, -- 704
		0.5, -- 704
		"Left", -- 704
		3.8, -- 704
		1, -- 704
		0.1 -- 704
	) -- 704
	local chapConfirmTag = getActiveTarget():keyTagFor("confirm", frame.mode, frame.layout) -- 705
	texts:put( -- 706
		"xs", -- 706
		chapConfirmTag, -- 706
		goX + 156, -- 706
		goY + 21, -- 706
		toColor(PALETTE.textDim), -- 706
		0, -- 706
		0.5, -- 706
		"Left", -- 706
		1, -- 706
		0.82, -- 706
		0.08 -- 706
	) -- 706
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 708
	local veilH = splitTrack and 156 or 126 -- 709
	drawSilkVeil( -- 710
		uiDraw, -- 710
		uiArt, -- 710
		"chap_track_veil", -- 710
		w * 0.5, -- 710
		veilCenterY, -- 710
		w - marginX * 1.1, -- 710
		veilH, -- 710
		PALETTE.inkWash, -- 710
		0.72, -- 710
		-2 -- 710
	) -- 710
	drawMistCurve( -- 711
		uiArt, -- 711
		"chap_track_mist", -- 711
		w * 0.5, -- 711
		trackY, -- 711
		trackX1 - trackX0 + 160, -- 711
		74, -- 711
		PALETTE.inkMist, -- 711
		0.62, -- 711
		-1 -- 711
	) -- 711
	uiInkDraw:drawSegment( -- 712
		Vec2(trackX0, trackY), -- 712
		Vec2(trackX1, trackY), -- 712
		0.9, -- 712
		toColor(PALETTE.silkDim, 145) -- 712
	) -- 712
	if splitTrack then -- 714
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 715
		uiInkDraw:drawSegment( -- 716
			Vec2(trackX0, trackY - rowGap), -- 716
			Vec2(lastX, trackY - rowGap), -- 716
			0.9, -- 716
			toColor(PALETTE.silkDim, 145) -- 716
		) -- 716
	else -- 716
		local midDivX = trackX0 + stepX * 3.5 -- 718
		uiInkDraw:drawSegment( -- 719
			Vec2(midDivX, trackY - 12), -- 719
			Vec2(midDivX, trackY + 12), -- 719
			0.8, -- 719
			toColor(PALETTE.silkDim, 120) -- 719
		) -- 719
		texts:put( -- 720
			"xs", -- 720
			"上卷 · 孤城护童", -- 720
			trackX0 + stepX * 1.5, -- 720
			trackY + 52, -- 720
			toColor(PALETTE.cyan), -- 720
			0.5, -- 720
			0.5, -- 720
			"Center", -- 720
			2.2, -- 720
			0.88, -- 720
			0.08 -- 720
		) -- 720
		texts:put( -- 721
			"xs", -- 721
			"下卷 · 独赴北塔", -- 721
			trackX0 + stepX * 5.5, -- 721
			trackY + 52, -- 721
			toColor(PALETTE.amber), -- 721
			0.5, -- 721
			0.5, -- 721
			"Center", -- 721
			2.2, -- 721
			0.88, -- 721
			0.08 -- 721
		) -- 721
	end -- 721
	local i = 0 -- 724
	do -- 724
		i = 0 -- 725
		while i < #CHAPTERS do -- 725
			local box = stationBoxes[i + 1] -- 726
			local sx = box.x + box.width * 0.5 -- 727
			local sy = box.y + box.height * 0.5 -- 728
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 729
			local active = self.chapterSelected == i -- 730
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 731
			if active then -- 733
				fillRadialGlow( -- 734
					uiGlow, -- 734
					sx, -- 734
					sy, -- 734
					26, -- 734
					26, -- 734
					toColor(PALETTE.rouge, 36 * breathe), -- 734
					Color(182, 58, 56, 0), -- 734
					12 -- 734
				) -- 734
				uiArt:tryPlace( -- 735
					"ink_enso_fine", -- 735
					"chap_st_ring_" .. tostring(i), -- 735
					sx, -- 735
					sy, -- 735
					32, -- 735
					32, -- 735
					{ -- 735
						color = toColor(PALETTE.silkLine), -- 736
						opacity = 0.78, -- 736
						angle = self.time * 18, -- 736
						layer = 3 -- 736
					} -- 736
				) -- 736
				drawBlossomDot( -- 738
					uiInkDraw, -- 738
					uiArt, -- 738
					"chap_st_dot_" .. tostring(i), -- 738
					sx, -- 738
					sy, -- 738
					17, -- 738
					PALETTE.rouge, -- 738
					0.98, -- 738
					4 -- 738
				) -- 738
			else -- 738
				uiArt:tryPlace( -- 740
					"ink_enso_fine", -- 740
					"chap_st_ring_" .. tostring(i), -- 740
					sx, -- 740
					sy, -- 740
					16, -- 740
					16, -- 740
					{ -- 740
						color = toColor(nodeCol), -- 741
						opacity = 0.62, -- 741
						layer = 3 -- 741
					} -- 741
				) -- 741
				drawBlossomDot( -- 743
					uiInkDraw, -- 743
					uiArt, -- 743
					"chap_st_dot_" .. tostring(i), -- 743
					sx, -- 743
					sy, -- 743
					7, -- 743
					PALETTE.silkLine, -- 743
					0.72, -- 743
					4 -- 743
				) -- 743
			end -- 743
			if not splitTrack then -- 746
				texts:put( -- 747
					"xs", -- 747
					rt.numeralZh, -- 747
					sx, -- 747
					sy + 25, -- 747
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 747
					0.5, -- 747
					0.5, -- 747
					"Center", -- 747
					0, -- 747
					active and 1 or 0.88, -- 747
					0.08 -- 747
				) -- 747
			end -- 747
			texts:put( -- 749
				"xs", -- 749
				rt.shortNameZh, -- 749
				sx, -- 749
				sy - 26, -- 749
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 749
				0.5, -- 749
				0.5, -- 749
				"Center", -- 749
				1, -- 749
				active and 1 or 0.84, -- 749
				0.08 -- 749
			) -- 749
			i = i + 1 -- 725
		end -- 725
	end -- 725
	local backX = marginX -- 752
	local backY = 40 + frame.safe.bottom * 0.45 -- 753
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 754
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 755
	local chapBackTag = getActiveTarget():keyTagFor("back", frame.mode, frame.layout) -- 756
	local chapFooter = getActiveTarget():chapterFooterHint(frame.mode, chapConfirmTag) -- 757
	drawSilkKeycap( -- 758
		uiInkDraw, -- 758
		texts, -- 758
		backX, -- 758
		backY + 5, -- 758
		48, -- 758
		24, -- 758
		chapBackTag, -- 758
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 758
		0.92, -- 758
		backHover -- 758
	) -- 758
	texts:put( -- 759
		"sm", -- 759
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 759
		backX + 60, -- 759
		backY + 17, -- 759
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 759
		0, -- 759
		0.5, -- 759
		"Left", -- 759
		1.8, -- 759
		0.9, -- 759
		0.08 -- 759
	) -- 759
	texts:put( -- 760
		"xs", -- 760
		chapFooter, -- 760
		w - marginX, -- 760
		backY + 17, -- 760
		toColor(PALETTE.textDim), -- 760
		1, -- 760
		0.5, -- 760
		"Right", -- 760
		1.2, -- 760
		0.75, -- 760
		0.08 -- 760
	) -- 760
	if frame.click and backHover then -- 762
		self:emitSound("back") -- 763
		return back -- 764
	end -- 764
	local ____temp_2 -- 767
	if frame.mode == "touch" then -- 767
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 768
	else -- 768
		____temp_2 = hitStation >= 0 -- 769
	end -- 769
	local stationConfirmed = ____temp_2 -- 767
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 770
		self:emitSound("start") -- 771
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 772
	end -- 772
	return {type = "none"} -- 774
end -- 584
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 778
	if backLabel == nil then -- 787
		backLabel = "返回标题" -- 787
	end -- 787
	local target = getActiveTarget() -- 789
	local tabs = target.controlsGuideTabs -- 790
	local hasMultipleTabs = #tabs > 1 -- 791
	if not self.controlsTabManual or __TS__ArrayFindIndex( -- 792
		tabs, -- 792
		function(____, t) return t.mode == self.controlsTab end -- 792
	) < 0 then -- 792
		self.controlsTab = __TS__ArrayFindIndex( -- 793
			tabs, -- 793
			function(____, t) return t.mode == frame.mode end -- 793
		) >= 0 and frame.mode or tabs[1].mode -- 793
	end -- 793
	local marginX = math.max( -- 795
		96, -- 795
		56 + math.max(frame.safe.left, frame.safe.right) -- 795
	) -- 795
	local tabW = 92 -- 796
	local tabH = 28 -- 797
	local tabGap = 10 -- 798
	local tabBoxes = {} -- 799
	local hitTab = -1 -- 800
	if hasMultipleTabs then -- 801
		local tabStartX = w - marginX - (tabW * #tabs + tabGap * (#tabs - 1)) -- 802
		local tabY = h - 82 - frame.safe.top * 0.35 -- 803
		local k = 0 -- 804
		do -- 804
			k = 0 -- 805
			while k < #tabs do -- 805
				tabBoxes[#tabBoxes + 1] = Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH) -- 806
				k = k + 1 -- 805
			end -- 805
		end -- 805
		hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 808
		if frame.click and hitTab >= 0 then -- 809
			if self.controlsTab ~= tabs[hitTab + 1].mode then -- 810
				self:emitSound("toggle") -- 811
			end -- 811
			self.controlsTab = tabs[hitTab + 1].mode -- 813
			self.controlsTabManual = true -- 814
		elseif frame.keys.left or frame.prevTab then -- 815
			local cur = __TS__ArrayFindIndex( -- 816
				tabs, -- 816
				function(____, t) return t.mode == self.controlsTab end -- 816
			) -- 816
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + #tabs - 1) % #tabs + 1].mode -- 817
			self.controlsTabManual = true -- 818
			self:emitSound("toggle") -- 819
		elseif frame.keys.right or frame.nextTab then -- 820
			local cur = __TS__ArrayFindIndex( -- 821
				tabs, -- 821
				function(____, t) return t.mode == self.controlsTab end -- 821
			) -- 821
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + 1) % #tabs + 1].mode -- 822
			self.controlsTabManual = true -- 823
			self:emitSound("toggle") -- 824
		end -- 824
	end -- 824
	local backX = marginX -- 828
	local backY = 40 + frame.safe.bottom * 0.45 -- 829
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 830
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 831
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 832
		self:emitSound("back") -- 833
		return {type = "backTitle"} -- 834
	end -- 834
	uiDraw:drawRect( -- 836
		Rect(0, 0, w, h), -- 836
		Color(10, 12, 19, 204) -- 836
	) -- 836
	local guide = target:controlsGuideRows(self.controlsTab) -- 838
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 839
	texts:put( -- 840
		"banner", -- 840
		"执器要诀", -- 840
		marginX, -- 840
		topHeadY, -- 840
		toColor(PALETTE.textBright), -- 840
		0, -- 840
		0.5, -- 840
		"Left", -- 840
		4.5, -- 840
		0.96, -- 840
		0.1 -- 840
	) -- 840
	texts:put( -- 841
		"xs", -- 841
		guide.subtitle, -- 841
		marginX + 196, -- 841
		topHeadY - 4, -- 841
		toColor(PALETTE.textDim), -- 841
		0, -- 841
		0.5, -- 841
		"Left", -- 841
		1.8, -- 841
		0.85, -- 841
		0.08 -- 841
	) -- 841
	drawHairline( -- 842
		uiInkDraw, -- 842
		uiArt, -- 842
		"ctrl_top_line", -- 842
		w * 0.5, -- 842
		topHeadY - 34, -- 842
		w - marginX * 2, -- 842
		PALETTE.silkDim, -- 842
		0.6, -- 842
		true, -- 842
		2 -- 842
	) -- 842
	if hasMultipleTabs then -- 844
		local ti = 0 -- 845
		do -- 845
			ti = 0 -- 846
			while ti < #tabBoxes do -- 846
				local tb = tabBoxes[ti + 1] -- 847
				local activeTab = self.controlsTab == tabs[ti + 1].mode -- 848
				local hoverTab = hitTab == ti -- 849
				uiInkDraw:drawRect( -- 850
					tb, -- 851
					activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 852
					0.9, -- 853
					toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 854
				) -- 854
				texts:put( -- 856
					"xs", -- 857
					tabs[ti + 1].label, -- 858
					tb.x + tb.width * 0.5, -- 859
					tb.y + tb.height * 0.5, -- 860
					toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 861
					0.5, -- 862
					0.5, -- 863
					"Center", -- 864
					0.8, -- 865
					activeTab and 0.98 or 0.82, -- 866
					0.08 -- 867
				) -- 867
				ti = ti + 1 -- 846
			end -- 846
		end -- 846
	end -- 846
	local extraH = math.max(0, h - 720) -- 872
	local areaY = 114 + frame.safe.bottom * 0.4 -- 873
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 874
	drawFiligreeCorners( -- 875
		uiInkDraw, -- 875
		uiArt, -- 875
		"ctrl_outer", -- 875
		marginX, -- 875
		areaY, -- 875
		w - marginX * 2, -- 875
		areaH, -- 875
		PALETTE.silkDim, -- 875
		0.52, -- 875
		34, -- 875
		false, -- 875
		2 -- 875
	) -- 875
	local midX = w * 0.5 -- 877
	uiArt:tryPlace( -- 878
		"ink_vstream", -- 878
		"ctrl_mid_stream", -- 878
		midX, -- 878
		areaY + areaH * 0.5, -- 878
		32, -- 878
		areaH - 18, -- 878
		{ -- 878
			color = toColor(PALETTE.silkDim), -- 879
			opacity = 0.52, -- 879
			layer = 1 -- 879
		} -- 879
	) -- 879
	drawBlossomDot( -- 881
		uiInkDraw, -- 881
		uiArt, -- 881
		"ctrl_mid_dot", -- 881
		midX, -- 881
		areaY + areaH * 0.5, -- 881
		11, -- 881
		PALETTE.silkLine, -- 881
		0.62, -- 881
		3 -- 881
	) -- 881
	local leftColX = marginX + 34 -- 883
	local colW = midX - leftColX - 42 -- 884
	local headY = areaY + areaH - 34 -- 885
	local rowStep = 52 + extraH * 0.08 -- 886
	drawBlossomDot( -- 888
		uiInkDraw, -- 888
		uiArt, -- 888
		"ctrl_l_dot", -- 888
		leftColX + 8, -- 888
		headY, -- 888
		12, -- 888
		PALETTE.cyan, -- 888
		0.88, -- 888
		3 -- 888
	) -- 888
	texts:put( -- 889
		"md", -- 889
		"周戍 · 护送与交锋", -- 889
		leftColX + 26, -- 889
		headY, -- 889
		toColor(PALETTE.cyanCore), -- 889
		0, -- 889
		0.5, -- 889
		"Left", -- 889
		2.4, -- 889
		0.98, -- 889
		0.08 -- 889
	) -- 889
	drawHairline( -- 890
		uiInkDraw, -- 890
		uiArt, -- 890
		"ctrl_l_line", -- 890
		leftColX + colW * 0.5, -- 890
		headY - 24, -- 890
		colW, -- 890
		PALETTE.cyanDim, -- 890
		0.58, -- 890
		false, -- 890
		2 -- 890
	) -- 890
	local i = 0 -- 892
	local keycapW = 160 -- 893
	do -- 893
		i = 0 -- 894
		while i < #guide.soldierRows do -- 894
			local ry = headY - 66 - i * rowStep -- 895
			drawSilkKeycap( -- 896
				uiInkDraw, -- 896
				texts, -- 896
				leftColX + 2, -- 896
				ry - 13, -- 896
				keycapW, -- 896
				26, -- 896
				guide.soldierRows[i + 1][1], -- 896
				PALETTE.cyan, -- 896
				0.92, -- 896
				false -- 896
			) -- 896
			texts:put( -- 897
				"sm", -- 897
				guide.soldierRows[i + 1][2], -- 897
				leftColX + keycapW + 16, -- 897
				ry, -- 897
				toColor(PALETTE.textBright), -- 897
				0, -- 897
				0.5, -- 897
				"Left", -- 897
				0.8, -- 897
				0.92, -- 897
				0.08 -- 897
			) -- 897
			i = i + 1 -- 894
		end -- 894
	end -- 894
	local rightColX = midX + 44 -- 900
	drawBlossomDot( -- 901
		uiInkDraw, -- 901
		uiArt, -- 901
		"ctrl_r_dot", -- 901
		rightColX + 8, -- 901
		headY, -- 901
		12, -- 901
		PALETTE.amber, -- 901
		0.88, -- 901
		3 -- 901
	) -- 901
	texts:put( -- 902
		"md", -- 902
		"小满 · 潜行与寻路", -- 902
		rightColX + 26, -- 902
		headY, -- 902
		toColor(PALETTE.amberCore), -- 902
		0, -- 902
		0.5, -- 902
		"Left", -- 902
		2.4, -- 902
		0.98, -- 902
		0.08 -- 902
	) -- 902
	drawHairline( -- 903
		uiInkDraw, -- 903
		uiArt, -- 903
		"ctrl_r_line", -- 903
		rightColX + colW * 0.5, -- 903
		headY - 24, -- 903
		colW, -- 903
		PALETTE.amberDim, -- 903
		0.58, -- 903
		false, -- 903
		2 -- 903
	) -- 903
	do -- 903
		i = 0 -- 905
		while i < #guide.childRows do -- 905
			local ry = headY - 66 - i * rowStep -- 906
			drawSilkKeycap( -- 907
				uiInkDraw, -- 907
				texts, -- 907
				rightColX + 2, -- 907
				ry - 13, -- 907
				keycapW, -- 907
				26, -- 907
				guide.childRows[i + 1][1], -- 907
				PALETTE.amber, -- 907
				0.92, -- 907
				false -- 907
			) -- 907
			texts:put( -- 908
				"sm", -- 908
				guide.childRows[i + 1][2], -- 908
				rightColX + keycapW + 16, -- 908
				ry, -- 908
				toColor(PALETTE.textBright), -- 908
				0, -- 908
				0.5, -- 908
				"Left", -- 908
				0.8, -- 908
				0.92, -- 908
				0.08 -- 908
			) -- 908
			i = i + 1 -- 905
		end -- 905
	end -- 905
	local ctrlBackKey = frame.mode == "gamepad" and (target:keyTagFor("back", "gamepad", frame.layout) .. " / ") .. target:keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 911
	local ctrlRightHint = target:controlsFooterRightHint(frame.mode) -- 914
	local keyW = frame.mode == "touch" and 76 or 110 -- 915
	drawSilkKeycap( -- 916
		uiInkDraw, -- 916
		texts, -- 916
		backX, -- 916
		backY + 5, -- 916
		keyW, -- 916
		24, -- 916
		ctrlBackKey, -- 916
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 916
		0.92, -- 916
		backHover -- 916
	) -- 916
	texts:put( -- 917
		"sm", -- 917
		backLabel, -- 917
		backX + keyW + 12, -- 917
		backY + 17, -- 917
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 917
		0, -- 917
		0.5, -- 917
		"Left", -- 917
		1.8, -- 917
		0.92, -- 917
		0.08 -- 917
	) -- 917
	texts:put( -- 918
		"xs", -- 918
		ctrlRightHint, -- 918
		w - marginX, -- 918
		backY + 17, -- 918
		toColor(PALETTE.textDim), -- 918
		1, -- 918
		0.5, -- 918
		"Right", -- 918
		1.2, -- 918
		0.78, -- 918
		0.08 -- 918
	) -- 918
	return {type = "none"} -- 920
end -- 778
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 924
	if frame.back then -- 935
		self:emitSound("back") -- 936
		return true -- 937
	end -- 937
	local target = getActiveTarget() -- 940
	local rows = target:settingsRows() -- 941
	local s = input.settings -- 942
	if self.settingsSelected >= #rows then -- 943
		self.settingsSelected = 0 -- 944
	end -- 944
	uiDraw:drawRect( -- 947
		Rect(0, 0, w, h), -- 947
		Color(10, 12, 19, 206) -- 947
	) -- 947
	local marginX = math.max( -- 949
		96, -- 949
		56 + math.max(frame.safe.left, frame.safe.right) -- 949
	) -- 949
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 950
	texts:put( -- 951
		"banner", -- 951
		target:settingsHeaderTitle(), -- 951
		marginX, -- 951
		topHeadY, -- 951
		toColor(PALETTE.textBright), -- 951
		0, -- 951
		0.5, -- 951
		"Left", -- 951
		4, -- 951
		0.96, -- 951
		0.1 -- 951
	) -- 951
	local curSummary = target:settingsHeaderSummary(input.inputMode) -- 952
	texts:put( -- 953
		"xs", -- 953
		curSummary, -- 953
		marginX + 224, -- 953
		topHeadY - 4, -- 953
		toColor(PALETTE.amberCore), -- 953
		0, -- 953
		0.5, -- 953
		"Left", -- 953
		1.4, -- 953
		0.88, -- 953
		0.08 -- 953
	) -- 953
	drawHairline( -- 954
		uiInkDraw, -- 954
		uiArt, -- 954
		"set_top_line", -- 954
		w * 0.5, -- 954
		topHeadY - 30, -- 954
		w - marginX * 2, -- 954
		PALETTE.silkDim, -- 954
		0.6, -- 954
		true, -- 954
		2 -- 954
	) -- 954
	local panelW = math.min(760, w - marginX * 2) -- 956
	local panelX = (w - panelW) * 0.5 -- 957
	local rowH = 34 -- 958
	local rowStep = #rows <= 6 and 48 or 39 -- 959
	local firstY = topHeadY - 76 -- 960
	local boxes = {} -- 962
	local i = 0 -- 963
	do -- 963
		i = 0 -- 964
		while i < #rows do -- 964
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 965
			i = i + 1 -- 964
		end -- 964
	end -- 964
	local prevSetSel = self.settingsSelected -- 967
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 968
	if self.settingsSelected ~= prevSetSel then -- 969
		self:emitSound("hover") -- 970
	end -- 970
	local function applyDelta(rowId, delta) -- 973
		local res = target:applySettingsDelta(rowId, delta, s, input) -- 974
		if res == "back" then -- 975
			self:emitSound("back") -- 976
			return true -- 977
		end -- 977
		if res == "audio" and self.onAudioSettingsChanged ~= nil then -- 979
			self:onAudioSettingsChanged(input) -- 980
		end -- 980
		if res ~= "none" then -- 982
			self:emitSound("toggle") -- 983
		end -- 983
		return false -- 985
	end -- 973
	do -- 973
		i = 0 -- 988
		while i < #rows do -- 988
			local row = rows[i + 1] -- 989
			local box = boxes[i + 1] -- 990
			local cy = box.y + box.height * 0.5 -- 991
			local active = self.settingsSelected == i -- 992
			if active then -- 994
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 995
				drawSilkRibbon( -- 996
					uiDraw, -- 996
					uiArt, -- 996
					"set_rib_" .. tostring(i), -- 996
					panelX + panelW * 0.5, -- 996
					cy, -- 996
					panelW + 24, -- 996
					rowH, -- 996
					PALETTE.rougeSoft, -- 996
					0.48 * breathe, -- 996
					0 -- 996
				) -- 996
				drawHairline( -- 997
					uiInkDraw, -- 997
					uiArt, -- 997
					"set_line_" .. tostring(i), -- 997
					panelX + panelW * 0.5, -- 997
					box.y + 3, -- 997
					panelW - 24, -- 997
					PALETTE.silkLine, -- 997
					0.42 * breathe, -- 997
					false, -- 997
					2 -- 997
				) -- 997
				drawBlossomDot( -- 998
					uiInkDraw, -- 998
					uiArt, -- 998
					"set_dot_" .. tostring(i), -- 998
					panelX + 18, -- 998
					cy, -- 998
					14, -- 998
					PALETTE.rouge, -- 998
					0.96, -- 998
					4 -- 998
				) -- 998
				fillRadialGlow( -- 999
					uiGlow, -- 999
					panelX + 18, -- 999
					cy, -- 999
					20, -- 999
					14, -- 999
					toColor(PALETTE.rouge, 24 * breathe), -- 999
					Color(182, 58, 56, 0), -- 999
					10 -- 999
				) -- 999
			else -- 999
				drawBlossomDot( -- 1001
					uiInkDraw, -- 1001
					uiArt, -- 1001
					"set_dot_" .. tostring(i), -- 1001
					panelX + 18, -- 1001
					cy, -- 1001
					7, -- 1001
					PALETTE.silkDim, -- 1001
					0.42, -- 1001
					3 -- 1001
				) -- 1001
			end -- 1001
			texts:put( -- 1004
				"sm", -- 1005
				row.title, -- 1006
				panelX + 42, -- 1007
				cy, -- 1008
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1009
				0, -- 1010
				0.5, -- 1011
				"Left", -- 1012
				active and 2.4 or 1.6, -- 1013
				active and 1 or 0.88, -- 1014
				0.08 -- 1015
			) -- 1015
			local val = target:settingsValueText(row.id, s, input.inputMode) -- 1018
			if val ~= "" then -- 1019
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1020
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1021
				texts:put( -- 1022
					"sm", -- 1022
					decorated, -- 1022
					panelX + panelW - 24, -- 1022
					cy, -- 1022
					toColor(valCol), -- 1022
					1, -- 1022
					0.5, -- 1022
					"Right", -- 1022
					1, -- 1022
					active and 1 or 0.86, -- 1022
					0.08 -- 1022
				) -- 1022
			end -- 1022
			i = i + 1 -- 988
		end -- 988
	end -- 988
	local backY = 40 + frame.safe.bottom * 0.45 -- 1026
	local hint = target:settingsFooterHint(frame.mode, frame.layout) -- 1027
	texts:put( -- 1028
		"xs", -- 1028
		hint, -- 1028
		w * 0.5, -- 1028
		backY + 14, -- 1028
		toColor(PALETTE.textDim), -- 1028
		0.5, -- 1028
		0.5, -- 1028
		"Center", -- 1028
		1.2, -- 1028
		0.84, -- 1028
		0.08 -- 1028
	) -- 1028
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1030
	if hit >= 0 then -- 1031
		self.settingsSelected = hit -- 1032
		if applyDelta(rows[hit + 1].id, 1) then -- 1033
			return true -- 1034
		end -- 1034
		self:resetInput() -- 1036
		return false -- 1037
	end -- 1037
	if frame.keys.left or frame.prevTab then -- 1039
		local id = rows[self.settingsSelected + 1].id -- 1040
		if id ~= "back" then -- 1041
			applyDelta(id, -1) -- 1042
			self:resetInput() -- 1043
		end -- 1043
		return false -- 1045
	end -- 1045
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1047
		local id = rows[self.settingsSelected + 1].id -- 1048
		if applyDelta(id, 1) then -- 1049
			return true -- 1050
		end -- 1050
		self:resetInput() -- 1052
		return false -- 1053
	end -- 1053
	return false -- 1055
end -- 924
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1063
	if assistHintsEnabled == nil then -- 1074
		assistHintsEnabled = false -- 1074
	end -- 1074
	if safeUi == nil then -- 1076
		safeUi = ZERO_SAFE_INSETS -- 1076
	end -- 1076
	self.time = self.time + dt -- 1078
	local frame = self:readFrame(input, uiScale, safeUi) -- 1079
	if self.pauseShowControls then -- 1081
		local ctrlAct = self:drawControls( -- 1082
			frame, -- 1082
			uiDraw, -- 1082
			uiInkDraw, -- 1082
			uiArt, -- 1082
			uiGlow, -- 1082
			texts, -- 1082
			w, -- 1082
			h, -- 1082
			"返回暂停" -- 1082
		) -- 1082
		if ctrlAct.type == "backTitle" then -- 1083
			self.pauseShowControls = false -- 1084
			self:resetInput() -- 1085
		end -- 1085
		return {type = "none"} -- 1087
	end -- 1087
	if self.pauseShowSettings then -- 1090
		if self:drawPauseSettings( -- 1091
			frame, -- 1091
			input, -- 1091
			uiDraw, -- 1091
			uiInkDraw, -- 1091
			uiArt, -- 1091
			uiGlow, -- 1091
			texts, -- 1091
			w, -- 1091
			h -- 1091
		) then -- 1091
			self.pauseShowSettings = false -- 1092
			self:resetInput() -- 1093
		end -- 1093
		return {type = "none"} -- 1095
	end -- 1095
	if frame.back then -- 1098
		self.pauseShowControls = false -- 1099
		self.pauseShowSettings = false -- 1100
		self:emitSound("pauseClose") -- 1101
		return {type = "resume"} -- 1102
	end -- 1102
	local allowFs = canToggleFullscreen() -- 1105
	local allowQuit = canQuitApp() -- 1106
	local pauseItems = __TS__ArrayFilter( -- 1107
		PAUSE_ITEMS, -- 1107
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1107
	) -- 1107
	if self.pauseSelected >= #pauseItems then -- 1110
		self.pauseSelected = 0 -- 1111
	end -- 1111
	uiDraw:drawRect( -- 1114
		Rect(0, 0, w, h), -- 1114
		Color(8, 10, 16, 102) -- 1114
	) -- 1114
	fillHGradRect( -- 1115
		uiDraw, -- 1115
		0, -- 1115
		0, -- 1115
		w * 0.27 + frame.safe.left, -- 1115
		h, -- 1115
		Color(9, 11, 18, 232), -- 1115
		Color(10, 13, 21, 198) -- 1115
	) -- 1115
	fillHGradRect( -- 1116
		uiDraw, -- 1116
		w * 0.27 + frame.safe.left, -- 1116
		0, -- 1116
		w * 0.21, -- 1116
		h, -- 1116
		Color(10, 13, 21, 198), -- 1116
		Color(10, 13, 21, 0) -- 1116
	) -- 1116
	local menuX = 110 + frame.safe.left * 0.6 -- 1118
	local compact = #pauseItems > 8 -- 1119
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1120
	uiArt:tryPlace( -- 1121
		"ink_vstream", -- 1121
		"pause_vstream", -- 1121
		menuX - 32, -- 1121
		h * 0.5, -- 1121
		34, -- 1121
		h * 0.78, -- 1121
		{ -- 1121
			color = toColor(PALETTE.silkDim), -- 1122
			opacity = 0.48, -- 1122
			layer = 1 -- 1122
		} -- 1122
	) -- 1122
	drawMistCurve( -- 1124
		uiArt, -- 1124
		"pause_mist", -- 1124
		menuX + 118, -- 1124
		headY - 8, -- 1124
		290, -- 1124
		72, -- 1124
		PALETTE.jadeMist, -- 1124
		0.2, -- 1124
		-1 -- 1124
	) -- 1124
	texts:put( -- 1126
		"banner", -- 1126
		"暂歇", -- 1126
		menuX + 16, -- 1126
		headY, -- 1126
		toColor(PALETTE.textBright), -- 1126
		0, -- 1126
		0.5, -- 1126
		"Left", -- 1126
		10, -- 1126
		0.98, -- 1126
		0.1 -- 1126
	) -- 1126
	texts:put( -- 1127
		"xs", -- 1127
		"月夜暂驻 · 卷页留痕", -- 1127
		menuX + 18, -- 1127
		headY - 36, -- 1127
		toColor(PALETTE.textDim), -- 1127
		0, -- 1127
		0.5, -- 1127
		"Left", -- 1127
		2, -- 1127
		0.8, -- 1127
		0.08 -- 1127
	) -- 1127
	drawHairline( -- 1128
		uiInkDraw, -- 1128
		uiArt, -- 1128
		"pause_div", -- 1128
		menuX + 124, -- 1128
		headY - 60, -- 1128
		240, -- 1128
		PALETTE.silkDim, -- 1128
		0.58, -- 1128
		true, -- 1128
		2 -- 1128
	) -- 1128
	local rowStep = compact and 42 or 46 -- 1130
	local rowH = compact and 36 or 38 -- 1131
	local firstY = compact and headY - 112 or headY - 120 -- 1132
	local boxes = {} -- 1133
	local i = 0 -- 1134
	do -- 1134
		i = 0 -- 1135
		while i < #pauseItems do -- 1135
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1136
			i = i + 1 -- 1135
		end -- 1135
	end -- 1135
	local prevPauseSel = self.pauseSelected -- 1138
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1139
	if self.pauseSelected ~= prevPauseSel then -- 1140
		self:emitSound("hover") -- 1141
	end -- 1141
	do -- 1141
		i = 0 -- 1144
		while i < #pauseItems do -- 1144
			local iy = boxes[i + 1].y -- 1145
			local active = self.pauseSelected == i -- 1146
			local cy = iy + rowH * 0.5 -- 1147
			local shiftX = active and 10 or 0 -- 1148
			local item = pauseItems[i + 1] -- 1149
			local label = item.zh -- 1150
			if item.id == "assist" then -- 1151
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1152
			elseif item.id == "fullscreen" then -- 1153
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1154
			elseif item.id == "settings" then -- 1155
				label = getActiveTarget():settingsPauseLabel(input.settings) -- 1156
			end -- 1156
			if active then -- 1159
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1160
				drawSilkRibbon( -- 1161
					uiDraw, -- 1161
					uiArt, -- 1161
					"pause_rib_" .. tostring(i), -- 1161
					menuX + 116, -- 1161
					cy, -- 1161
					282, -- 1161
					rowH, -- 1161
					PALETTE.rougeSoft, -- 1161
					0.54 * breathe, -- 1161
					0 -- 1161
				) -- 1161
				drawHairline( -- 1162
					uiInkDraw, -- 1162
					uiArt, -- 1162
					"pause_line_" .. tostring(i), -- 1162
					menuX + 106, -- 1162
					iy + 3, -- 1162
					210, -- 1162
					PALETTE.silkLine, -- 1162
					0.42 * breathe, -- 1162
					false, -- 1162
					2 -- 1162
				) -- 1162
				drawBlossomDot( -- 1163
					uiInkDraw, -- 1163
					uiArt, -- 1163
					"pause_dot_" .. tostring(i), -- 1163
					menuX + 12, -- 1163
					cy, -- 1163
					15, -- 1163
					PALETTE.rouge, -- 1163
					0.96, -- 1163
					4 -- 1163
				) -- 1163
				fillRadialGlow( -- 1164
					uiGlow, -- 1164
					menuX + 12, -- 1164
					cy, -- 1164
					22, -- 1164
					16, -- 1164
					toColor(PALETTE.rouge, 26 * breathe), -- 1164
					Color(182, 58, 56, 0), -- 1164
					10 -- 1164
				) -- 1164
			else -- 1164
				drawBlossomDot( -- 1166
					uiInkDraw, -- 1166
					uiArt, -- 1166
					"pause_dot_" .. tostring(i), -- 1166
					menuX + 12, -- 1166
					cy, -- 1166
					8, -- 1166
					PALETTE.silkDim, -- 1166
					0.4, -- 1166
					3 -- 1166
				) -- 1166
			end -- 1166
			texts:put( -- 1169
				compact and "sm" or "md", -- 1170
				label, -- 1171
				menuX + 32 + shiftX, -- 1172
				cy, -- 1173
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1174
				0, -- 1175
				0.5, -- 1176
				"Left", -- 1177
				active and 3.4 or 2.2, -- 1178
				active and 1 or 0.88, -- 1179
				0.1 -- 1180
			) -- 1180
			i = i + 1 -- 1144
		end -- 1144
	end -- 1144
	local pauseFooter = getActiveTarget():pauseFooterHint(frame.mode, frame.layout) -- 1184
	texts:put( -- 1185
		"xs", -- 1185
		pauseFooter, -- 1185
		menuX + 12, -- 1185
		38 + frame.safe.bottom * 0.4, -- 1185
		toColor(PALETTE.textDim), -- 1185
		0, -- 1185
		0.5, -- 1185
		"Left", -- 1185
		1.2, -- 1185
		0.86, -- 1185
		0.08 -- 1185
	) -- 1185
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1187
	if hit >= 0 or frame.keys.confirm then -- 1188
		local idx = hit >= 0 and hit or self.pauseSelected -- 1189
		local id = pauseItems[idx + 1].id -- 1190
		if id == "controls" then -- 1191
			self.pauseShowControls = true -- 1192
			self:emitSound("confirm") -- 1193
			self:resetInput() -- 1194
			return {type = "none"} -- 1195
		end -- 1195
		if id == "settings" then -- 1197
			self:openPauseSettings() -- 1198
			self:emitSound("confirm") -- 1199
			return {type = "none"} -- 1200
		end -- 1200
		if id == "assist" then -- 1202
			if onToggleAssist ~= nil then -- 1203
				onToggleAssist() -- 1204
			end -- 1204
			self:emitSound("toggle") -- 1206
			self:resetInput() -- 1207
			return {type = "none"} -- 1208
		end -- 1208
		if id == "fullscreen" then -- 1210
			self:emitSound("toggle") -- 1211
			self:resetInput() -- 1212
			return {type = "toggleFullscreen"} -- 1213
		end -- 1213
		self.pauseShowControls = false -- 1215
		self.pauseShowSettings = false -- 1216
		if id == "resume" then -- 1217
			self:emitSound("pauseClose") -- 1217
			return {type = "resume"} -- 1217
		end -- 1217
		if id == "retry" then -- 1218
			self:emitSound("confirm") -- 1218
			return {type = "retry"} -- 1218
		end -- 1218
		if id == "chapters" then -- 1219
			self:emitSound("confirm") -- 1219
			return {type = "openChapters"} -- 1219
		end -- 1219
		if id == "quit" then -- 1220
			self:emitSound("back") -- 1220
			return {type = "quit"} -- 1220
		end -- 1220
		self:emitSound("back") -- 1221
		return {type = "toTitle"} -- 1222
	end -- 1222
	return {type = "none"} -- 1224
end -- 1063
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1231
	if frame.back then -- 1241
		return {type = "backTitle"} -- 1242
	end -- 1242
	uiDraw:drawRect( -- 1246
		Rect(0, 0, w, h), -- 1246
		Color(7, 9, 15, 214) -- 1246
	) -- 1246
	local cx = w * 0.5 -- 1247
	local reunion = self.epilogueEnding == "reunion" -- 1248
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1249
	drawMistCurve( -- 1250
		uiArt, -- 1250
		"ep_mist", -- 1250
		cx, -- 1250
		h * 0.62, -- 1250
		620, -- 1250
		120, -- 1250
		accentCol, -- 1250
		0.2, -- 1250
		0 -- 1250
	) -- 1250
	fillRadialGlow( -- 1251
		uiGlow, -- 1251
		cx, -- 1251
		h * 0.68, -- 1251
		220, -- 1251
		140, -- 1251
		toColor(accentCol, 28), -- 1251
		Color(10, 14, 22, 0), -- 1251
		18 -- 1251
	) -- 1251
	local titleY = h * 0.72 -- 1254
	texts:put( -- 1255
		"title", -- 1255
		"向西守望", -- 1255
		cx - 18, -- 1255
		titleY, -- 1255
		toColor(PALETTE.textBright), -- 1255
		0.5, -- 1255
		0.5, -- 1255
		"Center", -- 1255
		12, -- 1255
		0.98, -- 1255
		0.12 -- 1255
	) -- 1255
	drawLoneSeal( -- 1256
		uiInkDraw, -- 1256
		uiArt, -- 1256
		texts, -- 1256
		"ep_seal", -- 1256
		cx + 148, -- 1256
		titleY - 2, -- 1256
		24, -- 1256
		46, -- 1256
		"守", -- 1256
		"望", -- 1256
		PALETTE.sealRed, -- 1256
		PALETTE.sealText, -- 1256
		0.94, -- 1256
		4 -- 1256
	) -- 1256
	drawHairline( -- 1257
		uiInkDraw, -- 1257
		uiArt, -- 1257
		"ep_div", -- 1257
		cx, -- 1257
		titleY - 46, -- 1257
		360, -- 1257
		PALETTE.silkDim, -- 1257
		0.62, -- 1257
		true, -- 1257
		2 -- 1257
	) -- 1257
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1259
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1260
	texts:put( -- 1263
		"md", -- 1263
		endingTitle, -- 1263
		cx, -- 1263
		titleY - 76, -- 1263
		toColor(PALETTE.amberCore), -- 1263
		0.5, -- 1263
		0.5, -- 1263
		"Center", -- 1263
		3.2, -- 1263
		0.96, -- 1263
		0.08 -- 1263
	) -- 1263
	texts:put( -- 1264
		"sm", -- 1264
		verse, -- 1264
		cx, -- 1264
		titleY - 114, -- 1264
		toColor(PALETTE.textMid), -- 1264
		0.5, -- 1264
		0.5, -- 1264
		"Center", -- 1264
		1, -- 1264
		0.92, -- 1264
		0.08 -- 1264
	) -- 1264
	if self.epilogueBothCleared then -- 1266
		drawSilkVeil( -- 1267
			uiDraw, -- 1267
			uiArt, -- 1267
			"ep_well_veil", -- 1267
			cx, -- 1267
			titleY - 152, -- 1267
			560, -- 1267
			30, -- 1267
			PALETTE.inkWarm, -- 1267
			0.68, -- 1267
			0 -- 1267
		) -- 1267
		texts:put( -- 1268
			"xs", -- 1268
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1268
			cx, -- 1268
			titleY - 152, -- 1268
			toColor(PALETTE.cyanCore), -- 1268
			0.5, -- 1268
			0.5, -- 1268
			"Center", -- 1268
			1, -- 1268
			0.9, -- 1268
			0.08 -- 1268
		) -- 1268
	end -- 1268
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1271
	local btnW = 286 -- 1276
	local btnH = 44 -- 1277
	local gap = 14 -- 1278
	local baseY = math.max(150, h * 0.34) -- 1279
	local boxes = {} -- 1280
	local i = 0 -- 1281
	do -- 1281
		i = 0 -- 1282
		while i < #items do -- 1282
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1283
			i = i + 1 -- 1282
		end -- 1282
	end -- 1282
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1285
	do -- 1285
		i = 0 -- 1287
		while i < #items do -- 1287
			local box = boxes[i + 1] -- 1288
			local active = self.epilogueSelected == i -- 1289
			local cy = box.y + box.height * 0.5 -- 1290
			if active then -- 1291
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1292
				drawSilkRibbon( -- 1293
					uiDraw, -- 1293
					uiArt, -- 1293
					"ep_rib_" .. tostring(i), -- 1293
					cx, -- 1293
					cy, -- 1293
					btnW + 24, -- 1293
					btnH, -- 1293
					PALETTE.rougeSoft, -- 1293
					0.62 * breathe, -- 1293
					0 -- 1293
				) -- 1293
				drawHairline( -- 1294
					uiInkDraw, -- 1294
					uiArt, -- 1294
					"ep_line_" .. tostring(i), -- 1294
					cx, -- 1294
					box.y + 3, -- 1294
					btnW - 44, -- 1294
					PALETTE.silkLine, -- 1294
					0.48 * breathe, -- 1294
					false, -- 1294
					2 -- 1294
				) -- 1294
				drawBlossomDot( -- 1295
					uiInkDraw, -- 1295
					uiArt, -- 1295
					"ep_dot_" .. tostring(i), -- 1295
					box.x + 22, -- 1295
					cy, -- 1295
					13, -- 1295
					PALETTE.rouge, -- 1295
					0.96, -- 1295
					4 -- 1295
				) -- 1295
			else -- 1295
				drawSilkVeil( -- 1297
					uiDraw, -- 1297
					uiArt, -- 1297
					"ep_idle_" .. tostring(i), -- 1297
					cx, -- 1297
					cy, -- 1297
					btnW, -- 1297
					btnH - 2, -- 1297
					PALETTE.inkWash, -- 1297
					0.58, -- 1297
					0 -- 1297
				) -- 1297
				drawBlossomDot( -- 1298
					uiInkDraw, -- 1298
					uiArt, -- 1298
					"ep_dot_" .. tostring(i), -- 1298
					box.x + 22, -- 1298
					cy, -- 1298
					8, -- 1298
					PALETTE.silkDim, -- 1298
					0.42, -- 1298
					3 -- 1298
				) -- 1298
			end -- 1298
			texts:put( -- 1300
				"sm", -- 1301
				items[i + 1].zh, -- 1302
				cx + 6, -- 1303
				cy, -- 1304
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1305
				0.5, -- 1306
				0.5, -- 1307
				"Center", -- 1308
				active and 2.6 or 1.6, -- 1309
				active and 1 or 0.88, -- 1310
				0.08 -- 1311
			) -- 1311
			i = i + 1 -- 1287
		end -- 1287
	end -- 1287
	local footer = getActiveTarget():epilogueFooterHint(frame.mode, frame.layout) -- 1315
	texts:put( -- 1316
		"xs", -- 1316
		footer, -- 1316
		cx, -- 1316
		38 + frame.safe.bottom * 0.4, -- 1316
		toColor(PALETTE.textDim), -- 1316
		0.5, -- 1316
		0.5, -- 1316
		"Center", -- 1316
		1.2, -- 1316
		0.84, -- 1316
		0.08 -- 1316
	) -- 1316
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1318
	if hit >= 0 or frame.keys.confirm then -- 1319
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1320
		local id = items[idx + 1].id -- 1321
		if id == "history" then -- 1322
			return {type = "openHistory"} -- 1322
		end -- 1322
		if id == "replay" then -- 1323
			return {type = "replayStory"} -- 1323
		end -- 1323
		return {type = "backTitle"} -- 1324
	end -- 1324
	return {type = "none"} -- 1326
end -- 1231
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1333
	if frame.back then -- 1343
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1344
	end -- 1344
	local total = #HISTORY_CARDS -- 1347
	if frame.keys.left or frame.prevTab then -- 1348
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1349
	elseif frame.keys.right or frame.nextTab then -- 1350
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1351
	end -- 1351
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1353
	uiDraw:drawRect( -- 1355
		Rect(0, 0, w, h), -- 1355
		Color(7, 9, 15, 206) -- 1355
	) -- 1355
	local cx = w * 0.5 -- 1356
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1357
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1358
	local px = cx - pageW * 0.5 -- 1359
	local py = (h - pageH) * 0.5 + 14 -- 1360
	local midY = py + pageH * 0.5 -- 1361
	uiArt:tryPlace( -- 1363
		"ink_frame_mask", -- 1363
		"hist_shadow", -- 1363
		cx, -- 1363
		midY - 6, -- 1363
		pageW + 52, -- 1363
		pageH + 46, -- 1363
		{ -- 1363
			color = toColor(PALETTE.voidDark), -- 1364
			opacity = 0.84, -- 1364
			layer = -1 -- 1364
		} -- 1364
	) -- 1364
	if not uiArt:tryPlace( -- 1366
		"ink_song_paper", -- 1366
		"hist_paper", -- 1366
		cx, -- 1366
		midY, -- 1366
		pageW, -- 1366
		pageH, -- 1366
		{opacity = 0.98, layer = 1} -- 1366
	) then -- 1366
		uiDraw:drawRect( -- 1367
			Rect(px, py, pageW, pageH), -- 1367
			toColor(PALETTE.xuanPaper, 248), -- 1367
			1, -- 1367
			toColor(PALETTE.silkDim, 180) -- 1367
		) -- 1367
	end -- 1367
	fillRadialGlow( -- 1369
		uiGlow, -- 1369
		cx, -- 1369
		midY + 40, -- 1369
		260, -- 1369
		140, -- 1369
		Color(236, 224, 202, 16), -- 1369
		Color(236, 224, 202, 0), -- 1369
		14 -- 1369
	) -- 1369
	local inX = px + 42 -- 1372
	local inY = py + 32 -- 1373
	local inW = pageW - 84 -- 1374
	local inH = pageH - 64 -- 1375
	local redSilk = toColor(PALETTE.rouge, 118) -- 1376
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1377
	uiInkDraw:drawRect( -- 1378
		Rect(inX, inY, inW, inH), -- 1378
		Color(0, 0, 0, 0), -- 1378
		0.95, -- 1378
		redSilk -- 1378
	) -- 1378
	uiInkDraw:drawRect( -- 1379
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1379
		Color(0, 0, 0, 0), -- 1379
		0.55, -- 1379
		redSilkFaint -- 1379
	) -- 1379
	local headY = inY + inH - 30 -- 1382
	texts:put( -- 1383
		"md", -- 1383
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1383
		inX + 20, -- 1383
		headY, -- 1383
		toColor(PALETTE.xuanInk), -- 1383
		0, -- 1383
		0.5, -- 1383
		"Left", -- 1383
		2, -- 1383
		0.96, -- 1383
		0 -- 1383
	) -- 1383
	texts:put( -- 1384
		"xs", -- 1384
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1384
		inX + inW - 20, -- 1384
		headY, -- 1384
		toColor(PALETTE.rouge), -- 1384
		1, -- 1384
		0.5, -- 1384
		"Right", -- 1384
		1.8, -- 1384
		0.88, -- 1384
		0 -- 1384
	) -- 1384
	uiInkDraw:drawSegment( -- 1385
		Vec2(inX + 14, headY - 22), -- 1385
		Vec2(inX + inW - 14, headY - 22), -- 1385
		0.85, -- 1385
		redSilk -- 1385
	) -- 1385
	texts:put( -- 1388
		"xs", -- 1388
		card.subtitle, -- 1388
		inX + 20, -- 1388
		headY - 42, -- 1388
		toColor(PALETTE.xuanInkSub), -- 1388
		0, -- 1388
		0.5, -- 1388
		"Left", -- 1388
		1.4, -- 1388
		0.86, -- 1388
		0 -- 1388
	) -- 1388
	local function wrapZh(src, maxUnits) -- 1391
		local out = {} -- 1392
		local buf = "" -- 1393
		local units = 0 -- 1394
		local ci = 0 -- 1395
		while ci < #src do -- 1396
			local b = __TS__StringCharCodeAt(src, ci) -- 1397
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1398
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1399
			local u = b < 128 and 0.56 or 1.02 -- 1400
			if units + u > maxUnits and buf ~= "" then -- 1401
				out[#out + 1] = buf -- 1402
				buf = ch -- 1403
				units = u -- 1404
			else -- 1404
				buf = buf .. ch -- 1406
				units = units + u -- 1407
			end -- 1407
			ci = ci + step -- 1409
		end -- 1409
		if buf ~= "" then -- 1411
			out[#out + 1] = buf -- 1412
		end -- 1412
		return out -- 1414
	end -- 1391
	local charsPerLine = math.max( -- 1417
		24, -- 1417
		math.floor((inW - 44) / 20) -- 1417
	) -- 1417
	local cursorY = headY - 76 -- 1418
	local pi = 0 -- 1419
	do -- 1419
		pi = 0 -- 1420
		while pi < #card.paragraphs do -- 1420
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1421
			local li = 0 -- 1422
			do -- 1422
				li = 0 -- 1423
				while li < #lines do -- 1423
					texts:put( -- 1424
						"sm", -- 1424
						lines[li + 1], -- 1424
						inX + 22, -- 1424
						cursorY, -- 1424
						toColor(PALETTE.xuanInk), -- 1424
						0, -- 1424
						0.5, -- 1424
						"Left", -- 1424
						0.6, -- 1424
						0.94, -- 1424
						0 -- 1424
					) -- 1424
					cursorY = cursorY - 30 -- 1425
					li = li + 1 -- 1423
				end -- 1423
			end -- 1423
			cursorY = cursorY - 12 -- 1427
			pi = pi + 1 -- 1420
		end -- 1420
	end -- 1420
	local footY = inY + 26 -- 1431
	uiInkDraw:drawSegment( -- 1432
		Vec2(inX + 14, footY + 20), -- 1432
		Vec2(inX + inW - 14, footY + 20), -- 1432
		0.6, -- 1432
		redSilkFaint -- 1432
	) -- 1432
	texts:put( -- 1433
		"xs", -- 1433
		card.footnote, -- 1433
		inX + 20, -- 1433
		footY, -- 1433
		toColor(PALETTE.xuanInkSub), -- 1433
		0, -- 1433
		0.5, -- 1433
		"Left", -- 1433
		0.4, -- 1433
		0.84, -- 1433
		0 -- 1433
	) -- 1433
	local navY = math.max(30, py - 48) -- 1436
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1437
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1438
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1439
	local function drawNavBtn(box, tag, label) -- 1441
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1442
		drawSilkVeil( -- 1443
			uiDraw, -- 1443
			uiArt, -- 1443
			"hist_btn_" .. tag, -- 1443
			box.x + box.width * 0.5, -- 1443
			box.y + box.height * 0.5, -- 1443
			box.width, -- 1443
			box.height, -- 1443
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1443
			hover and 0.86 or 0.72, -- 1443
			2 -- 1443
		) -- 1443
		texts:put( -- 1444
			"xs", -- 1444
			label, -- 1444
			box.x + box.width * 0.5, -- 1444
			box.y + box.height * 0.5, -- 1444
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1444
			0.5, -- 1444
			0.5, -- 1444
			"Center", -- 1444
			1.4, -- 1444
			0.94, -- 1444
			0.08 -- 1444
		) -- 1444
		return hover and frame.click -- 1445
	end -- 1441
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1448
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1449
	end -- 1449
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1451
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1452
	end -- 1452
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1454
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1455
	end -- 1455
	if frame.keys.confirm then -- 1458
		if self.historyCardIndex + 1 < total then -- 1459
			self.historyCardIndex = self.historyCardIndex + 1 -- 1460
		else -- 1460
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1462
		end -- 1462
	end -- 1462
	return {type = "none"} -- 1465
end -- 1333
return ____exports -- 1333
