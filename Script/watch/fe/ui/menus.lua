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
local TITLE_ITEMS = {{id = "start", zh = "开始游戏"}, {id = "chapters", zh = "选择章节"}, {id = "controls", zh = "操作说明"}, {id = "quit", zh = "退出游戏"}} -- 71
local CHAPTERS = (function() -- 90
	local out = {} -- 91
	local i = 0 -- 92
	do -- 92
		i = 0 -- 93
		while i < #ROOMS do -- 93
			do -- 93
				local room = ROOMS[i + 1] -- 94
				if room.key == "museum" or room.key == "street" or room.key == "checkpoint" then -- 94
					goto __continue4 -- 96
				end -- 96
				if room.key == "tower" then -- 96
					out[#out + 1] = { -- 99
						room = room, -- 100
						roomIndex = i, -- 101
						route = "child", -- 102
						titleOverride = "终章 · 北塔留灯", -- 103
						shortNameOverride = "北塔·留灯", -- 104
						lineTagOverride = "小满", -- 105
						whisperOverride = "孤身叩响北塔门，西窗留一盏向西的灯。" -- 106
					} -- 106
					out[#out + 1] = { -- 108
						room = room, -- 109
						roomIndex = i, -- 110
						route = "soldier", -- 111
						titleOverride = "终章 · 北塔团圆", -- 112
						shortNameOverride = "北塔·团圆", -- 113
						lineTagOverride = "周戍", -- 114
						whisperOverride = "兄妹并肩跨过塔门，两行姓名同落登记簿。" -- 115
					} -- 115
					goto __continue4 -- 117
				end -- 117
				out[#out + 1] = {room = room, roomIndex = i} -- 119
			end -- 119
			::__continue4:: -- 119
			i = i + 1 -- 93
		end -- 93
	end -- 93
	return out -- 121
end)() -- 90
local PAUSE_ITEMS = { -- 125
	{id = "resume", zh = "继续游戏"}, -- 126
	{id = "retry", zh = "重试检查点"}, -- 127
	{id = "controls", zh = "操作说明"}, -- 128
	{id = "assist", zh = "按键辅助：关"}, -- 129
	{id = "fullscreen", zh = "显示：窗口"}, -- 130
	{id = "chapters", zh = "选择章节"}, -- 131
	{id = "title", zh = "返回标题"}, -- 132
	{id = "quit", zh = "退出游戏"}, -- 133
	{id = "settings", zh = "操控设置"}, -- 134
	{id = "ledger", zh = "行军札记"} -- 135
} -- 135
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 138
local EPIGRAPH_RIGHT = { -- 139
	"城", -- 139
	"破", -- 139
	"那", -- 139
	"天", -- 139
	"", -- 139
	"他", -- 139
	"留", -- 139
	"下", -- 139
	"断", -- 139
	"后" -- 139
} -- 139
local EPIGRAPH_LEFT = { -- 140
	"她", -- 140
	"独", -- 140
	"自", -- 140
	"走", -- 140
	"向", -- 140
	"北", -- 140
	"塔" -- 140
} -- 140
local function hitIndex(boxes, pointer, inside) -- 165
	if not inside then -- 165
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
	self.sessionLabel = "" -- 185
	self.controlsTab = "kbm" -- 191
	self.chaptersFromPause = false -- 203
	self.pauseShowControls = false -- 204
	self.pauseShowSettings = false -- 205
	self.controlsTabManual = false -- 206
	self.queuedKeys = {} -- 207
	self.queuedBack = false -- 208
	self.queuedSkip = false -- 209
	self.splashTime = 0 -- 210
	self.time = 0 -- 211
end -- 172
function MenuRenderer.prototype.setSessionRoomKey(self, roomKey) -- 187
	self.sessionLabel = roomKey ~= "" and themeOf(roomKey).shortNameZh or "" -- 188
end -- 187
function MenuRenderer.prototype.emitSound(self, kind) -- 197
	if self.onUiSound ~= nil then -- 197
		self:onUiSound(kind) -- 199
	end -- 199
end -- 197
function MenuRenderer.prototype.resetSplash(self) -- 213
	self.splashTime = 0 -- 214
	self.queuedSkip = false -- 215
	self:resetInput() -- 216
end -- 213
function MenuRenderer.prototype.isShowingPauseControls(self) -- 219
	return self.pauseShowControls -- 220
end -- 219
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 223
	return self.pauseShowSettings -- 224
end -- 223
function MenuRenderer.prototype.openPauseSettings(self) -- 227
	self.pauseShowControls = false -- 228
	self.pauseShowSettings = true -- 229
	self.settingsSelected = 0 -- 230
	self:resetInput() -- 231
end -- 227
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 234
	self.chaptersFromPause = roomIndex ~= nil -- 235
	self.chapterSelected = math.max( -- 236
		0, -- 236
		__TS__ArrayFindIndex( -- 236
			CHAPTERS, -- 236
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 236
		) -- 236
	) -- 236
	self.pauseShowControls = false -- 237
	self.pauseShowSettings = false -- 238
	self:resetInput() -- 239
end -- 234
function MenuRenderer.prototype.openPause(self) -- 242
	self.pauseSelected = 0 -- 243
	self.pauseShowControls = false -- 244
	self.pauseShowSettings = false -- 245
	self:resetInput() -- 246
end -- 242
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 249
	if ending == nil then -- 249
		ending = "lamp" -- 249
	end -- 249
	if bothCleared == nil then -- 249
		bothCleared = false -- 249
	end -- 249
	self.epilogueEnding = ending -- 250
	self.epilogueBothCleared = bothCleared -- 251
	self.epilogueSelected = 0 -- 252
	self:resetInput() -- 253
end -- 249
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 256
	if fromEpilogue == nil then -- 256
		fromEpilogue = true -- 256
	end -- 256
	self.historyFromEpilogue = fromEpilogue -- 257
	self.historyCardIndex = 0 -- 258
	self:resetInput() -- 259
end -- 256
function MenuRenderer.prototype.triggerBack(self) -- 263
	self.queuedBack = true -- 264
end -- 263
function MenuRenderer.prototype.resetInput(self) -- 268
	self.queuedKeys = {} -- 269
	self.queuedBack = false -- 270
	self.queuedSkip = false -- 271
	self.controlsTabManual = false -- 272
end -- 268
function MenuRenderer.prototype.onKeyEvent(self, key) -- 276
	self.queuedSkip = true -- 277
	if key == "Up" or key == "W" then -- 277
		self.queuedKeys.up = true -- 279
	elseif key == "Down" or key == "S" then -- 279
		self.queuedKeys.down = true -- 281
	elseif key == "Left" or key == "A" then -- 281
		self.queuedKeys.left = true -- 283
	elseif key == "Right" or key == "D" then -- 283
		self.queuedKeys.right = true -- 285
	elseif key == "Return" or key == "Space" then -- 285
		self.queuedKeys.confirm = true -- 287
	elseif key == "Escape" then -- 287
		self.queuedBack = true -- 289
	end -- 289
end -- 276
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 293
	local queued = self.queuedKeys -- 294
	local useUiPtr = input.uiInside or input.uiPressed -- 297
	local rawX = useUiPtr and input.uiX or input.mx -- 298
	local rawY = useUiPtr and input.uiY or input.my -- 299
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 300
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 301
	local ____useUiPtr_0 -- 302
	if useUiPtr then -- 302
		____useUiPtr_0 = input.uiInside -- 302
	else -- 302
		____useUiPtr_0 = input.inside -- 302
	end -- 302
	local inside = ____useUiPtr_0 -- 302
	local ____useUiPtr_1 -- 303
	if useUiPtr then -- 303
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 303
	else -- 303
		____useUiPtr_1 = input.inside and input.fire.pressed -- 303
	end -- 303
	local click = ____useUiPtr_1 -- 303
	local touchMode = input:isTouchMode() -- 304
	local frame = { -- 306
		keys = { -- 307
			up = queued.up == true or input.navUp, -- 308
			down = queued.down == true or input.navDown, -- 309
			left = queued.left == true or input.navLeft, -- 310
			right = queued.right == true or input.navRight, -- 311
			confirm = queued.confirm == true or input.navConfirm -- 312
		}, -- 312
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 314
		prevTab = input.navPrevTab, -- 315
		nextTab = input.navNextTab, -- 316
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 317
		pointer = Vec2(rawX / scale, rawY / scale), -- 318
		inside = inside, -- 319
		click = click, -- 320
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 321
		mode = input.inputMode, -- 322
		layout = input.gamepadLayout, -- 323
		safe = safe -- 324
	} -- 324
	self.queuedKeys = {} -- 326
	self.queuedBack = false -- 327
	self.queuedSkip = false -- 328
	return frame -- 329
end -- 293
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 332
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 333
	if frame.click and hit >= 0 then -- 333
		return hit -- 335
	end -- 335
	if frame.keys.up then -- 335
		return (selected + #boxes - 1) % #boxes -- 338
	end -- 338
	if frame.keys.down then -- 338
		return (selected + 1) % #boxes -- 341
	end -- 341
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 343
end -- 332
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 346
	if safeUi == nil then -- 346
		safeUi = ZERO_SAFE_INSETS -- 362
	end -- 362
	self.time = self.time + dt -- 364
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 365
	if screen ~= "splash" or splashDissolving then -- 365
		local artW = math.max(w, h * 16 / 9) -- 367
		local artH = artW * 9 / 16 -- 368
		if not backdropArt:tryPlace( -- 368
			"title_backdrop", -- 369
			"menu_landscape", -- 369
			w * 0.5, -- 369
			(h - artH) * 0.5, -- 369
			artW, -- 369
			artH -- 369
		) then -- 369
			stage:drawMenuBackdrop( -- 370
				bgDraw, -- 370
				bgGlow, -- 370
				w, -- 370
				h, -- 370
				self.time -- 370
			) -- 370
		end -- 370
	end -- 370
	local frame = self:readFrame(input, uiScale, safeUi) -- 374
	w = w / uiScale -- 375
	h = h / uiScale -- 376
	if screen == "splash" then -- 376
		return self:drawSplash( -- 379
			dt, -- 379
			frame, -- 379
			uiDraw, -- 379
			uiArt, -- 379
			texts, -- 379
			w, -- 379
			h -- 379
		) -- 379
	end -- 379
	if screen == "title" then -- 379
		return self:drawTitle( -- 382
			frame, -- 382
			uiDraw, -- 382
			uiInkDraw, -- 382
			uiArt, -- 382
			uiGlow, -- 382
			texts, -- 382
			w, -- 382
			h -- 382
		) -- 382
	end -- 382
	if screen == "chapters" then -- 382
		return self:drawChapters( -- 385
			frame, -- 385
			uiDraw, -- 385
			uiInkDraw, -- 385
			uiArt, -- 385
			uiGlow, -- 385
			texts, -- 385
			w, -- 385
			h -- 385
		) -- 385
	end -- 385
	if screen == "epilogue" then -- 385
		return self:drawEpilogue( -- 388
			frame, -- 388
			uiDraw, -- 388
			uiInkDraw, -- 388
			uiArt, -- 388
			uiGlow, -- 388
			texts, -- 388
			w, -- 388
			h -- 388
		) -- 388
	end -- 388
	if screen == "history" then -- 388
		return self:drawHistory( -- 391
			frame, -- 391
			uiDraw, -- 391
			uiInkDraw, -- 391
			uiArt, -- 391
			uiGlow, -- 391
			texts, -- 391
			w, -- 391
			h -- 391
		) -- 391
	end -- 391
	return self:drawControls( -- 393
		frame, -- 393
		uiDraw, -- 393
		uiInkDraw, -- 393
		uiArt, -- 393
		uiGlow, -- 393
		texts, -- 393
		w, -- 393
		h -- 393
	) -- 393
end -- 346
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 402
	local safeDt = math.min( -- 411
		0.1, -- 411
		math.max(0, dt) -- 411
	) -- 411
	self.splashTime = self.splashTime + safeDt -- 412
	local t = self.splashTime -- 413
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 415
	if wantSkip or t >= 4.65 then -- 415
		self.splashTime = 0 -- 417
		return {type = "splashDone"} -- 418
	end -- 418
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 421
	local bgR = t < 2.2 and 13 or 11 -- 422
	local bgG = t < 2.2 and 16 or 13 -- 423
	local bgB = t < 2.2 and 24 or 19 -- 424
	uiDraw:drawRect( -- 425
		Rect(0, 0, w, h), -- 425
		Color( -- 425
			bgR, -- 425
			bgG, -- 425
			bgB, -- 425
			math.floor(255 * fadeOutCurtain + 0.5) -- 425
		) -- 425
	) -- 425
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 427
		if localT <= 0 or localT >= endT then -- 427
			return 0 -- 428
		end -- 428
		if localT < fadeIn then -- 428
			local u = localT / fadeIn -- 430
			return u * u * (3 - 2 * u) -- 431
		end -- 431
		if localT <= holdEnd then -- 431
			return 1 -- 433
		end -- 433
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 434
		return 1 - u * u * (3 - 2 * u) -- 435
	end -- 427
	if t < 2.2 then -- 427
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 439
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 440
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 441
		if not uiArt:tryPlace( -- 441
			"brand_team_logo", -- 442
			"splash_team_logo", -- 442
			w * 0.5, -- 442
			h * 0.54, -- 442
			logoH * 2, -- 442
			logoH, -- 442
			{opacity = alpha, layer = 2} -- 442
		) then -- 442
			texts:put( -- 443
				"banner", -- 443
				"OUTSIDER", -- 443
				w * 0.5, -- 443
				h * 0.52, -- 443
				toColor(PALETTE.textBright), -- 443
				0.5, -- 443
				0.5, -- 443
				"Center", -- 443
				6, -- 443
				alpha, -- 443
				0 -- 443
			) -- 443
		end -- 443
		texts:put( -- 445
			"xs", -- 445
			"Powered by Dora SSR", -- 445
			w * 0.5, -- 445
			58 + frame.safe.bottom * 0.4, -- 445
			toColor(PALETTE.textDim), -- 445
			0.5, -- 445
			0.5, -- 445
			"Center", -- 445
			1.8, -- 445
			alpha * 0.62, -- 445
			0 -- 445
		) -- 445
	elseif t < 4.25 then -- 445
		local localT = t - 2.2 -- 447
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 448
		local sway = math.sin(localT * 1.1) * 8 -- 449
		drawMistCurve( -- 450
			uiArt, -- 450
			"splash_game_mist", -- 450
			w * 0.5 + sway, -- 450
			h * 0.46, -- 450
			560, -- 450
			110, -- 450
			PALETTE.jadeMist, -- 450
			0.16 * alpha, -- 450
			1 -- 450
		) -- 450
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 451
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 452
		if not uiArt:tryPlace( -- 452
			"brand_game_logo_h", -- 453
			"splash_game_logo", -- 453
			w * 0.5, -- 453
			h * 0.52, -- 453
			logoH * 2.4, -- 453
			logoH, -- 453
			{opacity = alpha, layer = 2} -- 453
		) then -- 453
			texts:put( -- 454
				"title", -- 454
				"向西守望", -- 454
				w * 0.5, -- 454
				h * 0.52, -- 454
				toColor(PALETTE.textBright), -- 454
				0.5, -- 454
				0.5, -- 454
				"Center", -- 454
				8, -- 454
				alpha, -- 454
				0 -- 454
			) -- 454
		end -- 454
	end -- 454
	if t >= 0.35 and t < 4.15 then -- 454
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 459
		local skipText = getActiveTarget():splashSkipHint(frame.mode, frame.layout) -- 460
		texts:put( -- 461
			"xs", -- 461
			skipText, -- 461
			w - 48 - frame.safe.right * 0.6, -- 461
			36 + frame.safe.bottom * 0.4, -- 461
			toColor(PALETTE.textDim), -- 461
			1, -- 461
			0.5, -- 461
			"Right", -- 461
			1.4, -- 461
			hintA, -- 461
			0 -- 461
		) -- 461
	end -- 461
	return {type = "none"} -- 464
end -- 402
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 467
	fillHGradRect( -- 477
		uiDraw, -- 477
		0, -- 477
		0, -- 477
		w * 0.22 + frame.safe.left * 0.5, -- 477
		h, -- 477
		Color(9, 11, 18, 192), -- 477
		Color(9, 11, 18, 116) -- 477
	) -- 477
	fillHGradRect( -- 478
		uiDraw, -- 478
		w * 0.22 + frame.safe.left * 0.5, -- 478
		0, -- 478
		w * 0.28, -- 478
		h, -- 478
		Color(9, 11, 18, 116), -- 478
		Color(9, 11, 18, 0) -- 478
	) -- 478
	fillVGradRect( -- 479
		uiDraw, -- 479
		0, -- 479
		0, -- 479
		w, -- 479
		78, -- 479
		Color(8, 10, 16, 138), -- 479
		Color(8, 10, 16, 0) -- 479
	) -- 479
	local extraH = math.max(0, h - 720) -- 481
	local titleX = 148 + frame.safe.left * 0.6 -- 482
	local topY = h - 104 - frame.safe.top * 0.4 -- 483
	local charStep = 66 -- 484
	local sway = math.sin(self.time * 0.7) * 5 -- 485
	drawMistCurve( -- 486
		uiArt, -- 486
		"title_mist_wisp", -- 486
		titleX + 86 + sway, -- 486
		topY - 122, -- 486
		340, -- 486
		82, -- 486
		PALETTE.jadeMist, -- 486
		0.2, -- 486
		-1 -- 486
	) -- 486
	uiArt:tryPlace( -- 487
		"ink_petal_mist", -- 487
		"title_petals", -- 487
		titleX + 12, -- 487
		topY - 102, -- 487
		230, -- 487
		210, -- 487
		{ -- 487
			color = toColor(PALETTE.inkMist), -- 488
			opacity = 0.4, -- 488
			layer = -1 -- 488
		} -- 488
	) -- 488
	local placedBrandTitle = uiArt:tryPlace( -- 492
		"brand_game_logo_v", -- 492
		"title_brand_v", -- 492
		titleX + 22, -- 492
		topY - 106, -- 492
		240, -- 492
		304, -- 492
		{opacity = 0.98, layer = 3} -- 492
	) -- 492
	if not placedBrandTitle then -- 492
		uiArt:tryPlace( -- 496
			"ink_vstream", -- 496
			"title_vstream", -- 496
			titleX - 48, -- 496
			topY - 100, -- 496
			34, -- 496
			290, -- 496
			{ -- 496
				color = toColor(PALETTE.silkDim), -- 497
				opacity = 0.48, -- 497
				layer = 1 -- 497
			} -- 497
		) -- 497
		local c = 0 -- 499
		do -- 499
			c = 0 -- 500
			while c < #VERTICAL_TITLE do -- 500
				texts:put( -- 501
					"title", -- 502
					VERTICAL_TITLE[c + 1], -- 503
					titleX, -- 504
					topY - c * charStep, -- 505
					toColor(PALETTE.textBright), -- 506
					0.5, -- 507
					0.5, -- 508
					"Center", -- 509
					0, -- 510
					0.98, -- 511
					0.1, -- 512
					Color(8, 10, 16, 210) -- 513
				) -- 513
				c = c + 1 -- 500
			end -- 500
		end -- 500
		drawLoneSeal( -- 516
			uiInkDraw, -- 517
			uiArt, -- 518
			texts, -- 519
			"title_lone_seal", -- 520
			titleX + 46, -- 521
			topY - 3 * charStep + 8, -- 522
			26, -- 523
			52, -- 524
			"守", -- 525
			"望", -- 526
			PALETTE.sealRed, -- 527
			PALETTE.sealText, -- 528
			0.94, -- 529
			4 -- 530
		) -- 530
	end -- 530
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 535
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 536
	local poemStep = 22 -- 537
	local p = 0 -- 538
	do -- 538
		p = 0 -- 539
		while p < #EPIGRAPH_RIGHT do -- 539
			local ch = EPIGRAPH_RIGHT[p + 1] -- 540
			if ch ~= "" then -- 540
				texts:put( -- 542
					"xs", -- 542
					ch, -- 542
					colRightX, -- 542
					topY - 22 - p * poemStep, -- 542
					toColor(PALETTE.textMid), -- 542
					0.5, -- 542
					0.5, -- 542
					"Center", -- 542
					0, -- 542
					0.86, -- 542
					0.08 -- 542
				) -- 542
			end -- 542
			p = p + 1 -- 539
		end -- 539
	end -- 539
	do -- 539
		p = 0 -- 545
		while p < #EPIGRAPH_LEFT do -- 545
			texts:put( -- 546
				"xs", -- 546
				EPIGRAPH_LEFT[p + 1], -- 546
				colLeftX, -- 546
				topY - 68 - p * poemStep, -- 546
				toColor(PALETTE.amberCore), -- 546
				0.5, -- 546
				0.5, -- 546
				"Center", -- 546
				0, -- 546
				0.9, -- 546
				0.08 -- 546
			) -- 546
			p = p + 1 -- 545
		end -- 545
	end -- 545
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 550
		TITLE_ITEMS, -- 552
		function(____, it) return it.id ~= "quit" end -- 552
	) -- 552
	local items = self.hasSession and ({ -- 553
		{id = "continue", zh = "继续游戏"}, -- 554
		table.unpack(baseItems) -- 554
	}) or baseItems -- 554
	if self.selected >= #items then -- 554
		self.selected = 0 -- 557
	end -- 557
	local menuX = 112 + frame.safe.left * 0.6 -- 559
	local btnW = 280 -- 560
	local btnH = frame.mode == "touch" and 44 or 40 -- 561
	local gap = self.hasSession and 6 or 8 -- 562
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 563
	local boxes = {} -- 564
	local i = 0 -- 565
	do -- 565
		i = 0 -- 566
		while i < #items do -- 566
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 567
			i = i + 1 -- 566
		end -- 566
	end -- 566
	local prevTitleSel = self.selected -- 569
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 570
	if self.selected ~= prevTitleSel then -- 570
		self:emitSound("hover") -- 572
	end -- 572
	do -- 572
		i = 0 -- 575
		while i < #items do -- 575
			local by = boxes[i + 1].y -- 576
			local active = self.selected == i -- 577
			local cy = by + btnH * 0.5 -- 578
			local shiftX = active and 10 or 0 -- 579
			if active then -- 579
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 582
				drawSilkRibbon( -- 583
					uiDraw, -- 583
					uiArt, -- 583
					"title_rib_red_" .. tostring(i), -- 583
					menuX + 124, -- 583
					cy, -- 583
					290, -- 583
					btnH, -- 583
					PALETTE.rougeSoft, -- 583
					0.52 * breathe, -- 583
					0 -- 583
				) -- 583
				drawHairline( -- 584
					uiInkDraw, -- 584
					uiArt, -- 584
					"title_rib_line_" .. tostring(i), -- 584
					menuX + 114, -- 584
					by + 4, -- 584
					230, -- 584
					PALETTE.silkLine, -- 584
					0.42 * breathe, -- 584
					false, -- 584
					2 -- 584
				) -- 584
				drawBlossomDot( -- 585
					uiInkDraw, -- 585
					uiArt, -- 585
					"title_dot_" .. tostring(i), -- 585
					menuX + 14, -- 585
					cy, -- 585
					16, -- 585
					PALETTE.rouge, -- 585
					0.96, -- 585
					4 -- 585
				) -- 585
				fillRadialGlow( -- 586
					uiGlow, -- 586
					menuX + 14, -- 586
					cy, -- 586
					22, -- 586
					16, -- 586
					toColor(PALETTE.rouge, 28 * breathe), -- 586
					Color(182, 58, 56, 0), -- 586
					10 -- 586
				) -- 586
			else -- 586
				drawBlossomDot( -- 588
					uiInkDraw, -- 588
					uiArt, -- 588
					"title_dot_" .. tostring(i), -- 588
					menuX + 14, -- 588
					cy, -- 588
					8, -- 588
					PALETTE.silkDim, -- 588
					0.4, -- 588
					3 -- 588
				) -- 588
			end -- 588
			texts:put( -- 591
				"md", -- 592
				items[i + 1].zh, -- 593
				menuX + 34 + shiftX, -- 594
				cy, -- 595
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 596
				0, -- 597
				0.5, -- 598
				"Left", -- 599
				active and 4.4 or 2.8, -- 600
				active and 1 or 0.88, -- 601
				0.1 -- 602
			) -- 602
			if items[i + 1].id == "continue" and self.sessionLabel ~= "" then -- 602
				texts:put( -- 605
					"xs", -- 606
					"· " .. self.sessionLabel, -- 607
					menuX + 168 + shiftX, -- 608
					cy, -- 609
					toColor(active and PALETTE.amberCore or PALETTE.textDim), -- 610
					0, -- 611
					0.5, -- 612
					"Left", -- 613
					1.2, -- 614
					active and 0.92 or 0.72, -- 615
					0.08 -- 616
				) -- 616
			end -- 616
			i = i + 1 -- 575
		end -- 575
	end -- 575
	local titleHint = getActiveTarget():titleFooterHint(frame.mode, frame.layout) -- 621
	texts:put( -- 622
		"xs", -- 622
		titleHint, -- 622
		menuX + 12, -- 622
		42 + frame.safe.bottom * 0.45, -- 622
		toColor(PALETTE.textDim), -- 622
		0, -- 622
		0.5, -- 622
		"Left", -- 622
		1.4, -- 622
		0.88, -- 622
		0.08 -- 622
	) -- 622
	local badgeRight = w - frame.safe.right * 0.5 -- 625
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 626
	fillHGradRect( -- 627
		uiDraw, -- 627
		badgeRight - 270, -- 627
		0, -- 627
		270 + frame.safe.right * 0.5, -- 627
		86, -- 627
		Color(8, 10, 16, 0), -- 627
		Color(8, 10, 16, 204) -- 627
	) -- 627
	uiArt:tryPlace( -- 628
		"brand_team_badge", -- 628
		"title_team_badge", -- 628
		badgeRight - 118, -- 628
		badgeY, -- 628
		168, -- 628
		54, -- 628
		{opacity = 0.95, layer = 3} -- 628
	) -- 628
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 632
	if hit >= 0 or frame.keys.confirm then -- 632
		local idx = hit >= 0 and hit or self.selected -- 634
		local id = items[idx + 1].id -- 635
		if id == "continue" then -- 635
			self:emitSound("start") -- 636
			return {type = "continue"} -- 636
		end -- 636
		if id == "start" then -- 636
			self:emitSound("start") -- 637
			return {type = "start"} -- 637
		end -- 637
		if id == "chapters" then -- 637
			self:emitSound("confirm") -- 638
			return {type = "openChapters"} -- 638
		end -- 638
		if id == "quit" then -- 638
			self:emitSound("back") -- 639
			return {type = "quit"} -- 639
		end -- 639
		self:emitSound("confirm") -- 640
		return {type = "openControls"} -- 641
	end -- 641
	return {type = "none"} -- 643
end -- 467
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 646
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 656
	if frame.back then -- 656
		self:emitSound("back") -- 658
		return back -- 659
	end -- 659
	local extraH = math.max(0, h - 720) -- 662
	local marginX = math.max( -- 663
		96, -- 663
		56 + math.max(frame.safe.left, frame.safe.right) -- 663
	) -- 663
	local splitTrack = #CHAPTERS > 8 -- 664
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 665
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 666
	local rowGap = 68 -- 667
	local trackX0 = marginX + 34 -- 668
	local trackX1 = w - marginX - 34 -- 669
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 670
	local stationBoxes = {} -- 672
	local s = 0 -- 673
	do -- 673
		s = 0 -- 674
		while s < #CHAPTERS do -- 674
			local sx = trackX0 + s % perRow * stepX -- 675
			local sy = trackY - math.floor(s / perRow) * rowGap -- 676
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 677
			s = s + 1 -- 674
		end -- 674
	end -- 674
	local prevSelected = self.chapterSelected -- 680
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 681
	local keys = frame.keys -- 682
	if frame.click and hitStation >= 0 then -- 682
		self.chapterSelected = hitStation -- 684
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 684
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 686
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 687
	elseif keys.down and self.chapterSelected < perRow then -- 687
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 689
	elseif keys.up and self.chapterSelected >= perRow then -- 689
		self.chapterSelected = self.chapterSelected - perRow -- 691
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 691
		self.chapterSelected = hitStation -- 693
	end -- 693
	if self.chapterSelected ~= prevSelected then -- 693
		self:emitSound("hover") -- 696
	end -- 696
	uiDraw:drawRect( -- 699
		Rect(0, 0, w, h), -- 699
		Color(10, 12, 19, 198) -- 699
	) -- 699
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 701
	texts:put( -- 702
		"banner", -- 702
		"选择章节", -- 702
		marginX, -- 702
		topHeadY, -- 702
		toColor(PALETTE.textBright), -- 702
		0, -- 702
		0.5, -- 702
		"Left", -- 702
		4.5, -- 702
		0.96, -- 702
		0.1 -- 702
	) -- 702
	drawHairline( -- 703
		uiInkDraw, -- 703
		uiArt, -- 703
		"chap_top_line", -- 703
		w * 0.5, -- 703
		topHeadY - 34, -- 703
		w - marginX * 2, -- 703
		PALETTE.silkDim, -- 703
		0.6, -- 703
		true, -- 703
		2 -- 703
	) -- 703
	local activeEntry = CHAPTERS[self.chapterSelected + 1] -- 705
	local activeRoom = activeEntry.room -- 706
	local theme = themeOf(activeRoom.key) -- 707
	local activeTitleZh = activeEntry.titleOverride or theme.titleZh -- 708
	local activeLineTag = activeEntry.lineTagOverride or theme.lineTag -- 709
	local activeWhisper = activeEntry.whisperOverride or theme.introWhisper -- 710
	local winX = marginX -- 711
	local winY = 266 + extraH * 0.44 -- 712
	local winW = math.min( -- 713
		520, -- 713
		math.max(360, (w - marginX * 2) * 0.46) -- 713
	) -- 713
	local winH = 296 -- 714
	local winBox = Rect(winX, winY, winW, winH) -- 715
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 716
	uiArt:tryPlace( -- 718
		"ink_frame_mask", -- 718
		"chap_win_shadow", -- 718
		winX + winW * 0.5, -- 718
		winY + winH * 0.5, -- 718
		winW + 40, -- 718
		winH + 34, -- 718
		{ -- 718
			color = toColor(PALETTE.inkVoid), -- 719
			opacity = 0.88, -- 719
			layer = -2 -- 719
		} -- 719
	) -- 719
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 721
	uiArt:tryPlace( -- 722
		bgSlot, -- 722
		"chap_win_art", -- 722
		winX + winW * 0.5, -- 722
		winY + 4, -- 722
		winW - 8, -- 722
		winH - 8, -- 722
		{opacity = 0.92, layer = -1} -- 722
	) -- 722
	fillVGradRect( -- 725
		uiInkDraw, -- 725
		winX, -- 725
		winY, -- 725
		winW, -- 725
		56, -- 725
		Color(10, 12, 19, 200), -- 725
		Color(10, 12, 19, 0) -- 725
	) -- 725
	fillVGradRect( -- 726
		uiInkDraw, -- 726
		winX, -- 726
		winY + winH - 36, -- 726
		winW, -- 726
		36, -- 726
		Color(10, 12, 19, 0), -- 726
		Color(10, 12, 19, 130) -- 726
	) -- 726
	fillHGradRect( -- 727
		uiInkDraw, -- 727
		winX, -- 727
		winY, -- 727
		34, -- 727
		winH, -- 727
		Color(10, 12, 19, 135), -- 727
		Color(10, 12, 19, 0) -- 727
	) -- 727
	fillHGradRect( -- 728
		uiInkDraw, -- 728
		winX + winW - 34, -- 728
		winY, -- 728
		34, -- 728
		winH, -- 728
		Color(10, 12, 19, 0), -- 728
		Color(10, 12, 19, 135) -- 728
	) -- 728
	drawFiligreeCorners( -- 729
		uiInkDraw, -- 729
		uiArt, -- 729
		"chap_win_frame", -- 729
		winX, -- 729
		winY, -- 729
		winW, -- 729
		winH, -- 729
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 729
		winHover and 0.92 or 0.72, -- 729
		34, -- 729
		true, -- 729
		3 -- 729
	) -- 729
	texts:put( -- 731
		"xs", -- 731
		(theme.actCode .. "  ·  ") .. activeLineTag, -- 731
		winX + 20, -- 731
		winY + 22, -- 731
		toColor(PALETTE.textMid), -- 731
		0, -- 731
		0.5, -- 731
		"Left", -- 731
		1.8, -- 731
		0.9, -- 731
		0.08 -- 731
	) -- 731
	local infoX = winX + winW + 40 -- 733
	local infoW = math.max(240, w - marginX - infoX) -- 734
	local infoCenterY = winY + winH * 0.5 -- 735
	drawMistCurve( -- 736
		uiArt, -- 736
		"chap_info_mist", -- 736
		infoX + infoW * 0.5, -- 736
		infoCenterY + 36, -- 736
		math.min(420, infoW + 24), -- 736
		88, -- 736
		theme.accent, -- 736
		0.22, -- 736
		-1 -- 736
	) -- 736
	local volCol = activeLineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 738
	texts:put( -- 739
		"xs", -- 739
		theme.volumeTagZh, -- 739
		infoX, -- 739
		winY + winH - 44, -- 739
		toColor(volCol), -- 739
		0, -- 739
		0.5, -- 739
		"Left", -- 739
		2.8, -- 739
		0.92, -- 739
		0.08 -- 739
	) -- 739
	local sep = " · " -- 741
	local sIdx = (string.find(activeTitleZh, sep, nil, true) or 0) - 1 -- 742
	local titleY = winY + winH - 98 -- 743
	if theme.backdropKey ~= nil then -- 743
		texts:put( -- 745
			"lg", -- 745
			activeTitleZh, -- 745
			infoX, -- 745
			titleY, -- 745
			toColor(PALETTE.textBright) -- 745
		) -- 745
	elseif sIdx > 0 then -- 745
		local leftPart = __TS__StringSlice(activeTitleZh, 0, sIdx) -- 747
		local rightPart = __TS__StringSlice(activeTitleZh, sIdx + #sep) -- 748
		local lw = visualTextWidth(leftPart, 40) -- 749
		texts:put( -- 750
			"banner", -- 750
			leftPart, -- 750
			infoX, -- 750
			titleY, -- 750
			toColor(PALETTE.textBright), -- 750
			0, -- 750
			0.5, -- 750
			"Left", -- 750
			2, -- 750
			1, -- 750
			0.1 -- 750
		) -- 750
		drawBlossomDot( -- 751
			uiInkDraw, -- 751
			uiArt, -- 751
			"chap_title_dot", -- 751
			infoX + lw + 16, -- 751
			titleY - 2, -- 751
			11, -- 751
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 751
			0.9, -- 751
			4 -- 751
		) -- 751
		texts:put( -- 752
			"banner", -- 752
			rightPart, -- 752
			infoX + lw + 32, -- 752
			titleY, -- 752
			toColor(PALETTE.textBright), -- 752
			0, -- 752
			0.5, -- 752
			"Left", -- 752
			2, -- 752
			1, -- 752
			0.1 -- 752
		) -- 752
	else -- 752
		texts:put( -- 754
			"banner", -- 754
			activeTitleZh, -- 754
			infoX, -- 754
			titleY, -- 754
			toColor(PALETTE.textBright), -- 754
			0, -- 754
			0.5, -- 754
			"Left", -- 754
			2.4, -- 754
			1, -- 754
			0.1 -- 754
		) -- 754
	end -- 754
	drawHairline( -- 757
		uiInkDraw, -- 757
		uiArt, -- 757
		"chap_info_line", -- 757
		infoX + math.min(185, infoW * 0.5), -- 757
		titleY - 36, -- 757
		math.min(370, infoW), -- 757
		PALETTE.silkDim, -- 757
		0.58, -- 757
		false, -- 757
		2 -- 757
	) -- 757
	texts:put( -- 758
		"sm", -- 758
		activeWhisper, -- 758
		infoX, -- 758
		titleY - 72, -- 758
		toColor(PALETTE.textMid), -- 758
		0, -- 758
		0.5, -- 758
		"Left", -- 758
		0.8, -- 758
		0.94, -- 758
		0.08 -- 758
	) -- 758
	local goX = infoX -- 760
	local goY = winY + 26 -- 761
	local goW = 220 -- 762
	local goH = 42 -- 763
	local goBox = Rect(goX, goY, goW, goH) -- 764
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 765
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 766
	drawSilkRibbon( -- 767
		uiDraw, -- 767
		uiArt, -- 767
		"chap_go_rib", -- 767
		goX + 106, -- 767
		goY + 21, -- 767
		250, -- 767
		40, -- 767
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 767
		(goHover and 0.68 or 0.46) * breathe, -- 767
		0 -- 767
	) -- 767
	drawHairline( -- 768
		uiInkDraw, -- 768
		uiArt, -- 768
		"chap_go_line", -- 768
		goX + 94, -- 768
		goY + 3, -- 768
		196, -- 768
		PALETTE.silkLine, -- 768
		goHover and 0.68 or 0.4, -- 768
		false, -- 768
		2 -- 768
	) -- 768
	drawBlossomDot( -- 769
		uiInkDraw, -- 769
		uiArt, -- 769
		"chap_go_dot", -- 769
		goX + 14, -- 769
		goY + 21, -- 769
		14, -- 769
		PALETTE.rouge, -- 769
		0.96, -- 769
		4 -- 769
	) -- 769
	texts:put( -- 770
		"md", -- 770
		"入此卷章", -- 770
		goX + 34, -- 770
		goY + 21, -- 770
		toColor(PALETTE.textBright), -- 770
		0, -- 770
		0.5, -- 770
		"Left", -- 770
		3.8, -- 770
		1, -- 770
		0.1 -- 770
	) -- 770
	local chapConfirmTag = getActiveTarget():keyTagFor("confirm", frame.mode, frame.layout) -- 771
	texts:put( -- 772
		"xs", -- 772
		chapConfirmTag, -- 772
		goX + 156, -- 772
		goY + 21, -- 772
		toColor(PALETTE.textDim), -- 772
		0, -- 772
		0.5, -- 772
		"Left", -- 772
		1, -- 772
		0.82, -- 772
		0.08 -- 772
	) -- 772
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 774
	local veilH = splitTrack and 156 or 126 -- 775
	drawSilkVeil( -- 776
		uiDraw, -- 776
		uiArt, -- 776
		"chap_track_veil", -- 776
		w * 0.5, -- 776
		veilCenterY, -- 776
		w - marginX * 1.1, -- 776
		veilH, -- 776
		PALETTE.inkWash, -- 776
		0.72, -- 776
		-2 -- 776
	) -- 776
	drawMistCurve( -- 777
		uiArt, -- 777
		"chap_track_mist", -- 777
		w * 0.5, -- 777
		trackY, -- 777
		trackX1 - trackX0 + 160, -- 777
		74, -- 777
		PALETTE.inkMist, -- 777
		0.62, -- 777
		-1 -- 777
	) -- 777
	uiInkDraw:drawSegment( -- 778
		Vec2(trackX0, trackY), -- 778
		Vec2(trackX1, trackY), -- 778
		0.9, -- 778
		toColor(PALETTE.silkDim, 145) -- 778
	) -- 778
	if splitTrack then -- 778
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 781
		uiInkDraw:drawSegment( -- 782
			Vec2(trackX0, trackY - rowGap), -- 782
			Vec2(lastX, trackY - rowGap), -- 782
			0.9, -- 782
			toColor(PALETTE.silkDim, 145) -- 782
		) -- 782
	else -- 782
		local midDivX = trackX0 + stepX * 3.5 -- 784
		uiInkDraw:drawSegment( -- 785
			Vec2(midDivX, trackY - 12), -- 785
			Vec2(midDivX, trackY + 12), -- 785
			0.8, -- 785
			toColor(PALETTE.silkDim, 120) -- 785
		) -- 785
		texts:put( -- 786
			"xs", -- 786
			"上卷 · 孤城护童", -- 786
			trackX0 + stepX * 1.5, -- 786
			trackY + 52, -- 786
			toColor(PALETTE.cyan), -- 786
			0.5, -- 786
			0.5, -- 786
			"Center", -- 786
			2.2, -- 786
			0.88, -- 786
			0.08 -- 786
		) -- 786
		texts:put( -- 787
			"xs", -- 787
			"下卷 · 独赴北塔", -- 787
			trackX0 + stepX * 5.5, -- 787
			trackY + 52, -- 787
			toColor(PALETTE.amber), -- 787
			0.5, -- 787
			0.5, -- 787
			"Center", -- 787
			2.2, -- 787
			0.88, -- 787
			0.08 -- 787
		) -- 787
	end -- 787
	local i = 0 -- 790
	do -- 790
		i = 0 -- 791
		while i < #CHAPTERS do -- 791
			local box = stationBoxes[i + 1] -- 792
			local sx = box.x + box.width * 0.5 -- 793
			local sy = box.y + box.height * 0.5 -- 794
			local entry = CHAPTERS[i + 1] -- 795
			local rt = themeOf(entry.room.key) -- 796
			local entryLineTag = entry.lineTagOverride or rt.lineTag -- 797
			local entryShortName = entry.shortNameOverride or rt.shortNameZh -- 798
			local active = self.chapterSelected == i -- 799
			local nodeCol = active and PALETTE.rouge or (entryLineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 800
			if active then -- 800
				fillRadialGlow( -- 803
					uiGlow, -- 803
					sx, -- 803
					sy, -- 803
					26, -- 803
					26, -- 803
					toColor(PALETTE.rouge, 36 * breathe), -- 803
					Color(182, 58, 56, 0), -- 803
					12 -- 803
				) -- 803
				uiArt:tryPlace( -- 804
					"ink_enso_fine", -- 804
					"chap_st_ring_" .. tostring(i), -- 804
					sx, -- 804
					sy, -- 804
					32, -- 804
					32, -- 804
					{ -- 804
						color = toColor(PALETTE.silkLine), -- 805
						opacity = 0.78, -- 805
						angle = self.time * 18, -- 805
						layer = 3 -- 805
					} -- 805
				) -- 805
				drawBlossomDot( -- 807
					uiInkDraw, -- 807
					uiArt, -- 807
					"chap_st_dot_" .. tostring(i), -- 807
					sx, -- 807
					sy, -- 807
					17, -- 807
					PALETTE.rouge, -- 807
					0.98, -- 807
					4 -- 807
				) -- 807
			else -- 807
				uiArt:tryPlace( -- 809
					"ink_enso_fine", -- 809
					"chap_st_ring_" .. tostring(i), -- 809
					sx, -- 809
					sy, -- 809
					16, -- 809
					16, -- 809
					{ -- 809
						color = toColor(nodeCol), -- 810
						opacity = 0.62, -- 810
						layer = 3 -- 810
					} -- 810
				) -- 810
				drawBlossomDot( -- 812
					uiInkDraw, -- 812
					uiArt, -- 812
					"chap_st_dot_" .. tostring(i), -- 812
					sx, -- 812
					sy, -- 812
					7, -- 812
					PALETTE.silkLine, -- 812
					0.72, -- 812
					4 -- 812
				) -- 812
			end -- 812
			if not splitTrack then -- 812
				texts:put( -- 816
					"xs", -- 816
					rt.numeralZh, -- 816
					sx, -- 816
					sy + 25, -- 816
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 816
					0.5, -- 816
					0.5, -- 816
					"Center", -- 816
					0, -- 816
					active and 1 or 0.88, -- 816
					0.08 -- 816
				) -- 816
			end -- 816
			texts:put( -- 818
				"xs", -- 818
				entryShortName, -- 818
				sx, -- 818
				sy - 26, -- 818
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 818
				0.5, -- 818
				0.5, -- 818
				"Center", -- 818
				1, -- 818
				active and 1 or 0.84, -- 818
				0.08 -- 818
			) -- 818
			i = i + 1 -- 791
		end -- 791
	end -- 791
	local backX = marginX -- 821
	local backY = 40 + frame.safe.bottom * 0.45 -- 822
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 823
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 824
	local chapBackTag = getActiveTarget():keyTagFor("back", frame.mode, frame.layout) -- 825
	local chapFooter = getActiveTarget():chapterFooterHint(frame.mode, chapConfirmTag) -- 826
	drawSilkKeycap( -- 827
		uiInkDraw, -- 827
		texts, -- 827
		backX, -- 827
		backY + 5, -- 827
		48, -- 827
		24, -- 827
		chapBackTag, -- 827
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 827
		0.92, -- 827
		backHover -- 827
	) -- 827
	texts:put( -- 828
		"sm", -- 828
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 828
		backX + 60, -- 828
		backY + 17, -- 828
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 828
		0, -- 828
		0.5, -- 828
		"Left", -- 828
		1.8, -- 828
		0.9, -- 828
		0.08 -- 828
	) -- 828
	texts:put( -- 829
		"xs", -- 829
		chapFooter, -- 829
		w - marginX, -- 829
		backY + 17, -- 829
		toColor(PALETTE.textDim), -- 829
		1, -- 829
		0.5, -- 829
		"Right", -- 829
		1.2, -- 829
		0.75, -- 829
		0.08 -- 829
	) -- 829
	if frame.click and backHover then -- 829
		self:emitSound("back") -- 832
		return back -- 833
	end -- 833
	local ____temp_2 -- 836
	if frame.mode == "touch" then -- 836
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 837
	else -- 837
		____temp_2 = hitStation >= 0 -- 838
	end -- 838
	local stationConfirmed = ____temp_2 -- 836
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 836
		self:emitSound("start") -- 840
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex, route = CHAPTERS[self.chapterSelected + 1].route} -- 841
	end -- 841
	return {type = "none"} -- 847
end -- 646
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 851
	if backLabel == nil then -- 851
		backLabel = "返回标题" -- 860
	end -- 860
	local target = getActiveTarget() -- 862
	local tabs = target.controlsGuideTabs -- 863
	local hasMultipleTabs = #tabs > 1 -- 864
	if not self.controlsTabManual or __TS__ArrayFindIndex( -- 864
		tabs, -- 865
		function(____, t) return t.mode == self.controlsTab end -- 865
	) < 0 then -- 865
		self.controlsTab = __TS__ArrayFindIndex( -- 866
			tabs, -- 866
			function(____, t) return t.mode == frame.mode end -- 866
		) >= 0 and frame.mode or tabs[1].mode -- 866
	end -- 866
	local marginX = math.max( -- 868
		96, -- 868
		56 + math.max(frame.safe.left, frame.safe.right) -- 868
	) -- 868
	local tabW = 92 -- 869
	local tabH = 28 -- 870
	local tabGap = 10 -- 871
	local tabBoxes = {} -- 872
	local hitTab = -1 -- 873
	if hasMultipleTabs then -- 873
		local tabStartX = w - marginX - (tabW * #tabs + tabGap * (#tabs - 1)) -- 875
		local tabY = h - 82 - frame.safe.top * 0.35 -- 876
		local k = 0 -- 877
		do -- 877
			k = 0 -- 878
			while k < #tabs do -- 878
				tabBoxes[#tabBoxes + 1] = Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH) -- 879
				k = k + 1 -- 878
			end -- 878
		end -- 878
		hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 881
		if frame.click and hitTab >= 0 then -- 881
			if self.controlsTab ~= tabs[hitTab + 1].mode then -- 881
				self:emitSound("toggle") -- 884
			end -- 884
			self.controlsTab = tabs[hitTab + 1].mode -- 886
			self.controlsTabManual = true -- 887
		elseif frame.keys.left or frame.prevTab then -- 887
			local cur = __TS__ArrayFindIndex( -- 889
				tabs, -- 889
				function(____, t) return t.mode == self.controlsTab end -- 889
			) -- 889
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + #tabs - 1) % #tabs + 1].mode -- 890
			self.controlsTabManual = true -- 891
			self:emitSound("toggle") -- 892
		elseif frame.keys.right or frame.nextTab then -- 892
			local cur = __TS__ArrayFindIndex( -- 894
				tabs, -- 894
				function(____, t) return t.mode == self.controlsTab end -- 894
			) -- 894
			self.controlsTab = tabs[((cur >= 0 and cur or 0) + 1) % #tabs + 1].mode -- 895
			self.controlsTabManual = true -- 896
			self:emitSound("toggle") -- 897
		end -- 897
	end -- 897
	local backX = marginX -- 901
	local backY = 40 + frame.safe.bottom * 0.45 -- 902
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 903
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 904
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 904
		self:emitSound("back") -- 906
		return {type = "backTitle"} -- 907
	end -- 907
	uiDraw:drawRect( -- 909
		Rect(0, 0, w, h), -- 909
		Color(10, 12, 19, 204) -- 909
	) -- 909
	local guide = target:controlsGuideRows(self.controlsTab) -- 911
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 912
	texts:put( -- 913
		"banner", -- 913
		"执器要诀", -- 913
		marginX, -- 913
		topHeadY, -- 913
		toColor(PALETTE.textBright), -- 913
		0, -- 913
		0.5, -- 913
		"Left", -- 913
		4.5, -- 913
		0.96, -- 913
		0.1 -- 913
	) -- 913
	texts:put( -- 914
		"xs", -- 914
		guide.subtitle, -- 914
		marginX + 196, -- 914
		topHeadY - 4, -- 914
		toColor(PALETTE.textDim), -- 914
		0, -- 914
		0.5, -- 914
		"Left", -- 914
		1.8, -- 914
		0.85, -- 914
		0.08 -- 914
	) -- 914
	drawHairline( -- 915
		uiInkDraw, -- 915
		uiArt, -- 915
		"ctrl_top_line", -- 915
		w * 0.5, -- 915
		topHeadY - 34, -- 915
		w - marginX * 2, -- 915
		PALETTE.silkDim, -- 915
		0.6, -- 915
		true, -- 915
		2 -- 915
	) -- 915
	if hasMultipleTabs then -- 915
		local ti = 0 -- 918
		do -- 918
			ti = 0 -- 919
			while ti < #tabBoxes do -- 919
				local tb = tabBoxes[ti + 1] -- 920
				local activeTab = self.controlsTab == tabs[ti + 1].mode -- 921
				local hoverTab = hitTab == ti -- 922
				uiInkDraw:drawRect( -- 923
					tb, -- 924
					activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 925
					0.9, -- 926
					toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 927
				) -- 927
				texts:put( -- 929
					"xs", -- 930
					tabs[ti + 1].label, -- 931
					tb.x + tb.width * 0.5, -- 932
					tb.y + tb.height * 0.5, -- 933
					toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 934
					0.5, -- 935
					0.5, -- 936
					"Center", -- 937
					0.8, -- 938
					activeTab and 0.98 or 0.82, -- 939
					0.08 -- 940
				) -- 940
				ti = ti + 1 -- 919
			end -- 919
		end -- 919
	end -- 919
	local extraH = math.max(0, h - 720) -- 945
	local areaY = 114 + frame.safe.bottom * 0.4 -- 946
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 947
	drawFiligreeCorners( -- 948
		uiInkDraw, -- 948
		uiArt, -- 948
		"ctrl_outer", -- 948
		marginX, -- 948
		areaY, -- 948
		w - marginX * 2, -- 948
		areaH, -- 948
		PALETTE.silkDim, -- 948
		0.52, -- 948
		34, -- 948
		false, -- 948
		2 -- 948
	) -- 948
	local midX = w * 0.5 -- 950
	uiArt:tryPlace( -- 951
		"ink_vstream", -- 951
		"ctrl_mid_stream", -- 951
		midX, -- 951
		areaY + areaH * 0.5, -- 951
		32, -- 951
		areaH - 18, -- 951
		{ -- 951
			color = toColor(PALETTE.silkDim), -- 952
			opacity = 0.52, -- 952
			layer = 1 -- 952
		} -- 952
	) -- 952
	drawBlossomDot( -- 954
		uiInkDraw, -- 954
		uiArt, -- 954
		"ctrl_mid_dot", -- 954
		midX, -- 954
		areaY + areaH * 0.5, -- 954
		11, -- 954
		PALETTE.silkLine, -- 954
		0.62, -- 954
		3 -- 954
	) -- 954
	local leftColX = marginX + 34 -- 956
	local colW = midX - leftColX - 42 -- 957
	local headY = areaY + areaH - 34 -- 958
	local rowStep = 52 + extraH * 0.08 -- 959
	drawBlossomDot( -- 961
		uiInkDraw, -- 961
		uiArt, -- 961
		"ctrl_l_dot", -- 961
		leftColX + 8, -- 961
		headY, -- 961
		12, -- 961
		PALETTE.cyan, -- 961
		0.88, -- 961
		3 -- 961
	) -- 961
	texts:put( -- 962
		"md", -- 962
		"周戍 · 护送与交锋", -- 962
		leftColX + 26, -- 962
		headY, -- 962
		toColor(PALETTE.cyanCore), -- 962
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
		"ctrl_l_line", -- 963
		leftColX + colW * 0.5, -- 963
		headY - 24, -- 963
		colW, -- 963
		PALETTE.cyanDim, -- 963
		0.58, -- 963
		false, -- 963
		2 -- 963
	) -- 963
	local i = 0 -- 965
	local keycapW = 160 -- 966
	do -- 966
		i = 0 -- 967
		while i < #guide.soldierRows do -- 967
			local ry = headY - 66 - i * rowStep -- 968
			drawSilkKeycap( -- 969
				uiInkDraw, -- 969
				texts, -- 969
				leftColX + 2, -- 969
				ry - 13, -- 969
				keycapW, -- 969
				26, -- 969
				guide.soldierRows[i + 1][1], -- 969
				PALETTE.cyan, -- 969
				0.92, -- 969
				false -- 969
			) -- 969
			texts:put( -- 970
				"sm", -- 970
				guide.soldierRows[i + 1][2], -- 970
				leftColX + keycapW + 16, -- 970
				ry, -- 970
				toColor(PALETTE.textBright), -- 970
				0, -- 970
				0.5, -- 970
				"Left", -- 970
				0.8, -- 970
				0.92, -- 970
				0.08 -- 970
			) -- 970
			i = i + 1 -- 967
		end -- 967
	end -- 967
	local rightColX = midX + 44 -- 973
	drawBlossomDot( -- 974
		uiInkDraw, -- 974
		uiArt, -- 974
		"ctrl_r_dot", -- 974
		rightColX + 8, -- 974
		headY, -- 974
		12, -- 974
		PALETTE.amber, -- 974
		0.88, -- 974
		3 -- 974
	) -- 974
	texts:put( -- 975
		"md", -- 975
		"小满 · 潜行与寻路", -- 975
		rightColX + 26, -- 975
		headY, -- 975
		toColor(PALETTE.amberCore), -- 975
		0, -- 975
		0.5, -- 975
		"Left", -- 975
		2.4, -- 975
		0.98, -- 975
		0.08 -- 975
	) -- 975
	drawHairline( -- 976
		uiInkDraw, -- 976
		uiArt, -- 976
		"ctrl_r_line", -- 976
		rightColX + colW * 0.5, -- 976
		headY - 24, -- 976
		colW, -- 976
		PALETTE.amberDim, -- 976
		0.58, -- 976
		false, -- 976
		2 -- 976
	) -- 976
	do -- 976
		i = 0 -- 978
		while i < #guide.childRows do -- 978
			local ry = headY - 66 - i * rowStep -- 979
			drawSilkKeycap( -- 980
				uiInkDraw, -- 980
				texts, -- 980
				rightColX + 2, -- 980
				ry - 13, -- 980
				keycapW, -- 980
				26, -- 980
				guide.childRows[i + 1][1], -- 980
				PALETTE.amber, -- 980
				0.92, -- 980
				false -- 980
			) -- 980
			texts:put( -- 981
				"sm", -- 981
				guide.childRows[i + 1][2], -- 981
				rightColX + keycapW + 16, -- 981
				ry, -- 981
				toColor(PALETTE.textBright), -- 981
				0, -- 981
				0.5, -- 981
				"Left", -- 981
				0.8, -- 981
				0.92, -- 981
				0.08 -- 981
			) -- 981
			i = i + 1 -- 978
		end -- 978
	end -- 978
	local ctrlBackKey = frame.mode == "gamepad" and (target:keyTagFor("back", "gamepad", frame.layout) .. " / ") .. target:keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 984
	local ctrlRightHint = target:controlsFooterRightHint(frame.mode) -- 987
	local keyW = frame.mode == "touch" and 76 or 110 -- 988
	drawSilkKeycap( -- 989
		uiInkDraw, -- 989
		texts, -- 989
		backX, -- 989
		backY + 5, -- 989
		keyW, -- 989
		24, -- 989
		ctrlBackKey, -- 989
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 989
		0.92, -- 989
		backHover -- 989
	) -- 989
	texts:put( -- 990
		"sm", -- 990
		backLabel, -- 990
		backX + keyW + 12, -- 990
		backY + 17, -- 990
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 990
		0, -- 990
		0.5, -- 990
		"Left", -- 990
		1.8, -- 990
		0.92, -- 990
		0.08 -- 990
	) -- 990
	texts:put( -- 991
		"xs", -- 991
		ctrlRightHint, -- 991
		w - marginX, -- 991
		backY + 17, -- 991
		toColor(PALETTE.textDim), -- 991
		1, -- 991
		0.5, -- 991
		"Right", -- 991
		1.2, -- 991
		0.78, -- 991
		0.08 -- 991
	) -- 991
	return {type = "none"} -- 993
end -- 851
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 997
	if frame.back then -- 997
		self:emitSound("back") -- 1009
		return true -- 1010
	end -- 1010
	local target = getActiveTarget() -- 1013
	local rows = target:settingsRows() -- 1014
	local s = input.settings -- 1015
	if self.settingsSelected >= #rows then -- 1015
		self.settingsSelected = 0 -- 1017
	end -- 1017
	uiDraw:drawRect( -- 1020
		Rect(0, 0, w, h), -- 1020
		Color(10, 12, 19, 206) -- 1020
	) -- 1020
	local marginX = math.max( -- 1022
		96, -- 1022
		56 + math.max(frame.safe.left, frame.safe.right) -- 1022
	) -- 1022
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1023
	texts:put( -- 1024
		"banner", -- 1024
		target:settingsHeaderTitle(), -- 1024
		marginX, -- 1024
		topHeadY, -- 1024
		toColor(PALETTE.textBright), -- 1024
		0, -- 1024
		0.5, -- 1024
		"Left", -- 1024
		4, -- 1024
		0.96, -- 1024
		0.1 -- 1024
	) -- 1024
	local curSummary = target:settingsHeaderSummary(input.inputMode) -- 1025
	texts:put( -- 1026
		"xs", -- 1026
		curSummary, -- 1026
		marginX + 224, -- 1026
		topHeadY - 4, -- 1026
		toColor(PALETTE.amberCore), -- 1026
		0, -- 1026
		0.5, -- 1026
		"Left", -- 1026
		1.4, -- 1026
		0.88, -- 1026
		0.08 -- 1026
	) -- 1026
	drawHairline( -- 1027
		uiInkDraw, -- 1027
		uiArt, -- 1027
		"set_top_line", -- 1027
		w * 0.5, -- 1027
		topHeadY - 30, -- 1027
		w - marginX * 2, -- 1027
		PALETTE.silkDim, -- 1027
		0.6, -- 1027
		true, -- 1027
		2 -- 1027
	) -- 1027
	local panelW = math.min(760, w - marginX * 2) -- 1029
	local panelX = (w - panelW) * 0.5 -- 1030
	local rowH = 34 -- 1031
	local rowStep = #rows <= 6 and 48 or 39 -- 1032
	local firstY = topHeadY - 76 -- 1033
	local boxes = {} -- 1035
	local i = 0 -- 1036
	do -- 1036
		i = 0 -- 1037
		while i < #rows do -- 1037
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1038
			i = i + 1 -- 1037
		end -- 1037
	end -- 1037
	local prevSetSel = self.settingsSelected -- 1040
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1041
	if self.settingsSelected ~= prevSetSel then -- 1041
		self:emitSound("hover") -- 1043
	end -- 1043
	local function applyDelta(rowId, delta) -- 1046
		local res = target:applySettingsDelta(rowId, delta, s, input) -- 1047
		if res == "back" then -- 1047
			self:emitSound("back") -- 1049
			return true -- 1050
		end -- 1050
		if res == "audio" and self.onAudioSettingsChanged ~= nil then -- 1050
			self:onAudioSettingsChanged(input) -- 1053
		end -- 1053
		if res ~= "none" then -- 1053
			self:emitSound("toggle") -- 1056
		end -- 1056
		return false -- 1058
	end -- 1046
	do -- 1046
		i = 0 -- 1061
		while i < #rows do -- 1061
			local row = rows[i + 1] -- 1062
			local box = boxes[i + 1] -- 1063
			local cy = box.y + box.height * 0.5 -- 1064
			local active = self.settingsSelected == i -- 1065
			if active then -- 1065
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1068
				drawSilkRibbon( -- 1069
					uiDraw, -- 1069
					uiArt, -- 1069
					"set_rib_" .. tostring(i), -- 1069
					panelX + panelW * 0.5, -- 1069
					cy, -- 1069
					panelW + 24, -- 1069
					rowH, -- 1069
					PALETTE.rougeSoft, -- 1069
					0.48 * breathe, -- 1069
					0 -- 1069
				) -- 1069
				drawHairline( -- 1070
					uiInkDraw, -- 1070
					uiArt, -- 1070
					"set_line_" .. tostring(i), -- 1070
					panelX + panelW * 0.5, -- 1070
					box.y + 3, -- 1070
					panelW - 24, -- 1070
					PALETTE.silkLine, -- 1070
					0.42 * breathe, -- 1070
					false, -- 1070
					2 -- 1070
				) -- 1070
				drawBlossomDot( -- 1071
					uiInkDraw, -- 1071
					uiArt, -- 1071
					"set_dot_" .. tostring(i), -- 1071
					panelX + 18, -- 1071
					cy, -- 1071
					14, -- 1071
					PALETTE.rouge, -- 1071
					0.96, -- 1071
					4 -- 1071
				) -- 1071
				fillRadialGlow( -- 1072
					uiGlow, -- 1072
					panelX + 18, -- 1072
					cy, -- 1072
					20, -- 1072
					14, -- 1072
					toColor(PALETTE.rouge, 24 * breathe), -- 1072
					Color(182, 58, 56, 0), -- 1072
					10 -- 1072
				) -- 1072
			else -- 1072
				drawBlossomDot( -- 1074
					uiInkDraw, -- 1074
					uiArt, -- 1074
					"set_dot_" .. tostring(i), -- 1074
					panelX + 18, -- 1074
					cy, -- 1074
					7, -- 1074
					PALETTE.silkDim, -- 1074
					0.42, -- 1074
					3 -- 1074
				) -- 1074
			end -- 1074
			texts:put( -- 1077
				"sm", -- 1078
				row.title, -- 1079
				panelX + 42, -- 1080
				cy, -- 1081
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1082
				0, -- 1083
				0.5, -- 1084
				"Left", -- 1085
				active and 2.4 or 1.6, -- 1086
				active and 1 or 0.88, -- 1087
				0.08 -- 1088
			) -- 1088
			local val = target:settingsValueText(row.id, s, input.inputMode) -- 1091
			if val ~= "" then -- 1091
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1093
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1094
				texts:put( -- 1095
					"sm", -- 1095
					decorated, -- 1095
					panelX + panelW - 24, -- 1095
					cy, -- 1095
					toColor(valCol), -- 1095
					1, -- 1095
					0.5, -- 1095
					"Right", -- 1095
					1, -- 1095
					active and 1 or 0.86, -- 1095
					0.08 -- 1095
				) -- 1095
			end -- 1095
			i = i + 1 -- 1061
		end -- 1061
	end -- 1061
	local backY = 40 + frame.safe.bottom * 0.45 -- 1099
	local hint = target:settingsFooterHint(frame.mode, frame.layout) -- 1100
	texts:put( -- 1101
		"xs", -- 1101
		hint, -- 1101
		w * 0.5, -- 1101
		backY + 14, -- 1101
		toColor(PALETTE.textDim), -- 1101
		0.5, -- 1101
		0.5, -- 1101
		"Center", -- 1101
		1.2, -- 1101
		0.84, -- 1101
		0.08 -- 1101
	) -- 1101
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1103
	if hit >= 0 then -- 1103
		self.settingsSelected = hit -- 1105
		if applyDelta(rows[hit + 1].id, 1) then -- 1105
			return true -- 1107
		end -- 1107
		self:resetInput() -- 1109
		return false -- 1110
	end -- 1110
	if frame.keys.left or frame.prevTab then -- 1110
		local id = rows[self.settingsSelected + 1].id -- 1113
		if id ~= "back" then -- 1113
			applyDelta(id, -1) -- 1115
			self:resetInput() -- 1116
		end -- 1116
		return false -- 1118
	end -- 1118
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1118
		local id = rows[self.settingsSelected + 1].id -- 1121
		if applyDelta(id, 1) then -- 1121
			return true -- 1123
		end -- 1123
		self:resetInput() -- 1125
		return false -- 1126
	end -- 1126
	return false -- 1128
end -- 997
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi, isMaleRoguelike, showLedgerEntry, onOpenLedger) -- 1136
	if assistHintsEnabled == nil then -- 1136
		assistHintsEnabled = false -- 1147
	end -- 1147
	if safeUi == nil then -- 1147
		safeUi = ZERO_SAFE_INSETS -- 1149
	end -- 1149
	if isMaleRoguelike == nil then -- 1149
		isMaleRoguelike = false -- 1150
	end -- 1150
	if showLedgerEntry == nil then -- 1150
		showLedgerEntry = false -- 1151
	end -- 1151
	self.time = self.time + dt -- 1154
	local frame = self:readFrame(input, uiScale, safeUi) -- 1155
	if self.pauseShowControls then -- 1155
		local ctrlAct = self:drawControls( -- 1158
			frame, -- 1158
			uiDraw, -- 1158
			uiInkDraw, -- 1158
			uiArt, -- 1158
			uiGlow, -- 1158
			texts, -- 1158
			w, -- 1158
			h, -- 1158
			"返回暂停" -- 1158
		) -- 1158
		if ctrlAct.type == "backTitle" then -- 1158
			self.pauseShowControls = false -- 1160
			self:resetInput() -- 1161
		end -- 1161
		return {type = "none"} -- 1163
	end -- 1163
	if self.pauseShowSettings then -- 1163
		if self:drawPauseSettings( -- 1163
			frame, -- 1167
			input, -- 1167
			uiDraw, -- 1167
			uiInkDraw, -- 1167
			uiArt, -- 1167
			uiGlow, -- 1167
			texts, -- 1167
			w, -- 1167
			h -- 1167
		) then -- 1167
			self.pauseShowSettings = false -- 1168
			self:resetInput() -- 1169
		end -- 1169
		return {type = "none"} -- 1171
	end -- 1171
	if frame.back then -- 1171
		self.pauseShowControls = false -- 1175
		self.pauseShowSettings = false -- 1176
		self:emitSound("pauseClose") -- 1177
		return {type = "resume"} -- 1178
	end -- 1178
	local allowFs = canToggleFullscreen() -- 1181
	local allowQuit = canQuitApp() -- 1182
	local pauseItems = __TS__ArrayFilter( -- 1183
		PAUSE_ITEMS, -- 1183
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) and (item.id ~= "ledger" or showLedgerEntry) end -- 1183
	) -- 1183
	if self.pauseSelected >= #pauseItems then -- 1183
		self.pauseSelected = 0 -- 1189
	end -- 1189
	uiDraw:drawRect( -- 1192
		Rect(0, 0, w, h), -- 1192
		Color(8, 10, 16, 102) -- 1192
	) -- 1192
	fillHGradRect( -- 1193
		uiDraw, -- 1193
		0, -- 1193
		0, -- 1193
		w * 0.27 + frame.safe.left, -- 1193
		h, -- 1193
		Color(9, 11, 18, 232), -- 1193
		Color(10, 13, 21, 198) -- 1193
	) -- 1193
	fillHGradRect( -- 1194
		uiDraw, -- 1194
		w * 0.27 + frame.safe.left, -- 1194
		0, -- 1194
		w * 0.21, -- 1194
		h, -- 1194
		Color(10, 13, 21, 198), -- 1194
		Color(10, 13, 21, 0) -- 1194
	) -- 1194
	local menuX = 110 + frame.safe.left * 0.6 -- 1196
	local compact = #pauseItems > 8 -- 1197
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1198
	uiArt:tryPlace( -- 1199
		"ink_vstream", -- 1199
		"pause_vstream", -- 1199
		menuX - 32, -- 1199
		h * 0.5, -- 1199
		34, -- 1199
		h * 0.78, -- 1199
		{ -- 1199
			color = toColor(PALETTE.silkDim), -- 1200
			opacity = 0.48, -- 1200
			layer = 1 -- 1200
		} -- 1200
	) -- 1200
	drawMistCurve( -- 1202
		uiArt, -- 1202
		"pause_mist", -- 1202
		menuX + 118, -- 1202
		headY - 8, -- 1202
		290, -- 1202
		72, -- 1202
		PALETTE.jadeMist, -- 1202
		0.2, -- 1202
		-1 -- 1202
	) -- 1202
	texts:put( -- 1204
		"banner", -- 1204
		"暂歇", -- 1204
		menuX + 16, -- 1204
		headY, -- 1204
		toColor(PALETTE.textBright), -- 1204
		0, -- 1204
		0.5, -- 1204
		"Left", -- 1204
		10, -- 1204
		0.98, -- 1204
		0.1 -- 1204
	) -- 1204
	texts:put( -- 1205
		"xs", -- 1205
		"月夜暂驻 · 卷页留痕", -- 1205
		menuX + 18, -- 1205
		headY - 36, -- 1205
		toColor(PALETTE.textDim), -- 1205
		0, -- 1205
		0.5, -- 1205
		"Left", -- 1205
		2, -- 1205
		0.8, -- 1205
		0.08 -- 1205
	) -- 1205
	drawHairline( -- 1206
		uiInkDraw, -- 1206
		uiArt, -- 1206
		"pause_div", -- 1206
		menuX + 124, -- 1206
		headY - 60, -- 1206
		240, -- 1206
		PALETTE.silkDim, -- 1206
		0.58, -- 1206
		true, -- 1206
		2 -- 1206
	) -- 1206
	local rowStep = compact and 42 or 46 -- 1208
	local rowH = compact and 36 or 38 -- 1209
	local firstY = compact and headY - 112 or headY - 120 -- 1210
	local boxes = {} -- 1211
	local i = 0 -- 1212
	do -- 1212
		i = 0 -- 1213
		while i < #pauseItems do -- 1213
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1214
			i = i + 1 -- 1213
		end -- 1213
	end -- 1213
	local prevPauseSel = self.pauseSelected -- 1216
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1217
	if self.pauseSelected ~= prevPauseSel then -- 1217
		self:emitSound("hover") -- 1219
	end -- 1219
	do -- 1219
		i = 0 -- 1222
		while i < #pauseItems do -- 1222
			local iy = boxes[i + 1].y -- 1223
			local active = self.pauseSelected == i -- 1224
			local cy = iy + rowH * 0.5 -- 1225
			local shiftX = active and 10 or 0 -- 1226
			local item = pauseItems[i + 1] -- 1227
			local label = item.zh -- 1228
			if item.id == "retry" and isMaleRoguelike then -- 1228
				label = "重开本轮护送" -- 1230
			elseif item.id == "assist" then -- 1230
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1232
			elseif item.id == "fullscreen" then -- 1232
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1234
			elseif item.id == "settings" then -- 1234
				label = getActiveTarget():settingsPauseLabel(input.settings) -- 1236
			end -- 1236
			if active then -- 1236
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1240
				drawSilkRibbon( -- 1241
					uiDraw, -- 1241
					uiArt, -- 1241
					"pause_rib_" .. tostring(i), -- 1241
					menuX + 116, -- 1241
					cy, -- 1241
					282, -- 1241
					rowH, -- 1241
					PALETTE.rougeSoft, -- 1241
					0.54 * breathe, -- 1241
					0 -- 1241
				) -- 1241
				drawHairline( -- 1242
					uiInkDraw, -- 1242
					uiArt, -- 1242
					"pause_line_" .. tostring(i), -- 1242
					menuX + 106, -- 1242
					iy + 3, -- 1242
					210, -- 1242
					PALETTE.silkLine, -- 1242
					0.42 * breathe, -- 1242
					false, -- 1242
					2 -- 1242
				) -- 1242
				drawBlossomDot( -- 1243
					uiInkDraw, -- 1243
					uiArt, -- 1243
					"pause_dot_" .. tostring(i), -- 1243
					menuX + 12, -- 1243
					cy, -- 1243
					15, -- 1243
					PALETTE.rouge, -- 1243
					0.96, -- 1243
					4 -- 1243
				) -- 1243
				fillRadialGlow( -- 1244
					uiGlow, -- 1244
					menuX + 12, -- 1244
					cy, -- 1244
					22, -- 1244
					16, -- 1244
					toColor(PALETTE.rouge, 26 * breathe), -- 1244
					Color(182, 58, 56, 0), -- 1244
					10 -- 1244
				) -- 1244
			else -- 1244
				drawBlossomDot( -- 1246
					uiInkDraw, -- 1246
					uiArt, -- 1246
					"pause_dot_" .. tostring(i), -- 1246
					menuX + 12, -- 1246
					cy, -- 1246
					8, -- 1246
					PALETTE.silkDim, -- 1246
					0.4, -- 1246
					3 -- 1246
				) -- 1246
			end -- 1246
			texts:put( -- 1249
				compact and "sm" or "md", -- 1250
				label, -- 1251
				menuX + 32 + shiftX, -- 1252
				cy, -- 1253
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1254
				0, -- 1255
				0.5, -- 1256
				"Left", -- 1257
				active and 3.4 or 2.2, -- 1258
				active and 1 or 0.88, -- 1259
				0.1 -- 1260
			) -- 1260
			i = i + 1 -- 1222
		end -- 1222
	end -- 1222
	local pauseFooter = getActiveTarget():pauseFooterHint(frame.mode, frame.layout) -- 1264
	texts:put( -- 1265
		"xs", -- 1265
		pauseFooter, -- 1265
		menuX + 12, -- 1265
		38 + frame.safe.bottom * 0.4, -- 1265
		toColor(PALETTE.textDim), -- 1265
		0, -- 1265
		0.5, -- 1265
		"Left", -- 1265
		1.2, -- 1265
		0.86, -- 1265
		0.08 -- 1265
	) -- 1265
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1267
	if hit >= 0 or frame.keys.confirm then -- 1267
		local idx = hit >= 0 and hit or self.pauseSelected -- 1269
		local id = pauseItems[idx + 1].id -- 1270
		if id == "controls" then -- 1270
			self.pauseShowControls = true -- 1272
			self:emitSound("confirm") -- 1273
			self:resetInput() -- 1274
			return {type = "none"} -- 1275
		end -- 1275
		if id == "settings" then -- 1275
			self:openPauseSettings() -- 1278
			self:emitSound("confirm") -- 1279
			return {type = "none"} -- 1280
		end -- 1280
		if id == "ledger" then -- 1280
			if onOpenLedger ~= nil then -- 1280
				onOpenLedger() -- 1284
			end -- 1284
			self.pauseShowControls = false -- 1286
			self.pauseShowSettings = false -- 1287
			self:emitSound("confirm") -- 1288
			return {type = "resume"} -- 1289
		end -- 1289
		if id == "assist" then -- 1289
			if onToggleAssist ~= nil then -- 1289
				onToggleAssist() -- 1293
			end -- 1293
			self:emitSound("toggle") -- 1295
			self:resetInput() -- 1296
			return {type = "none"} -- 1297
		end -- 1297
		if id == "fullscreen" then -- 1297
			self:emitSound("toggle") -- 1300
			self:resetInput() -- 1301
			return {type = "toggleFullscreen"} -- 1302
		end -- 1302
		self.pauseShowControls = false -- 1304
		self.pauseShowSettings = false -- 1305
		if id == "resume" then -- 1305
			self:emitSound("pauseClose") -- 1306
			return {type = "resume"} -- 1306
		end -- 1306
		if id == "retry" then -- 1306
			self:emitSound("confirm") -- 1307
			return {type = "retry"} -- 1307
		end -- 1307
		if id == "chapters" then -- 1307
			self:emitSound("confirm") -- 1308
			return {type = "openChapters"} -- 1308
		end -- 1308
		if id == "quit" then -- 1308
			self:emitSound("back") -- 1309
			return {type = "quit"} -- 1309
		end -- 1309
		self:emitSound("back") -- 1310
		return {type = "toTitle"} -- 1311
	end -- 1311
	return {type = "none"} -- 1313
end -- 1136
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1320
	if frame.back then -- 1320
		return {type = "backTitle"} -- 1331
	end -- 1331
	uiDraw:drawRect( -- 1335
		Rect(0, 0, w, h), -- 1335
		Color(7, 9, 15, 214) -- 1335
	) -- 1335
	local cx = w * 0.5 -- 1336
	local reunion = self.epilogueEnding == "reunion" -- 1337
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1338
	drawMistCurve( -- 1339
		uiArt, -- 1339
		"ep_mist", -- 1339
		cx, -- 1339
		h * 0.62, -- 1339
		620, -- 1339
		120, -- 1339
		accentCol, -- 1339
		0.2, -- 1339
		0 -- 1339
	) -- 1339
	fillRadialGlow( -- 1340
		uiGlow, -- 1340
		cx, -- 1340
		h * 0.68, -- 1340
		220, -- 1340
		140, -- 1340
		toColor(accentCol, 28), -- 1340
		Color(10, 14, 22, 0), -- 1340
		18 -- 1340
	) -- 1340
	local titleY = h * 0.72 -- 1343
	texts:put( -- 1344
		"title", -- 1344
		"向西守望", -- 1344
		cx - 18, -- 1344
		titleY, -- 1344
		toColor(PALETTE.textBright), -- 1344
		0.5, -- 1344
		0.5, -- 1344
		"Center", -- 1344
		12, -- 1344
		0.98, -- 1344
		0.12 -- 1344
	) -- 1344
	drawLoneSeal( -- 1345
		uiInkDraw, -- 1345
		uiArt, -- 1345
		texts, -- 1345
		"ep_seal", -- 1345
		cx + 148, -- 1345
		titleY - 2, -- 1345
		24, -- 1345
		46, -- 1345
		"守", -- 1345
		"望", -- 1345
		PALETTE.sealRed, -- 1345
		PALETTE.sealText, -- 1345
		0.94, -- 1345
		4 -- 1345
	) -- 1345
	drawHairline( -- 1346
		uiInkDraw, -- 1346
		uiArt, -- 1346
		"ep_div", -- 1346
		cx, -- 1346
		titleY - 46, -- 1346
		360, -- 1346
		PALETTE.silkDim, -- 1346
		0.62, -- 1346
		true, -- 1346
		2 -- 1346
	) -- 1346
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1348
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1349
	texts:put( -- 1352
		"md", -- 1352
		endingTitle, -- 1352
		cx, -- 1352
		titleY - 76, -- 1352
		toColor(PALETTE.amberCore), -- 1352
		0.5, -- 1352
		0.5, -- 1352
		"Center", -- 1352
		3.2, -- 1352
		0.96, -- 1352
		0.08 -- 1352
	) -- 1352
	texts:put( -- 1353
		"sm", -- 1353
		verse, -- 1353
		cx, -- 1353
		titleY - 114, -- 1353
		toColor(PALETTE.textMid), -- 1353
		0.5, -- 1353
		0.5, -- 1353
		"Center", -- 1353
		1, -- 1353
		0.92, -- 1353
		0.08 -- 1353
	) -- 1353
	if self.epilogueBothCleared then -- 1353
		drawSilkVeil( -- 1356
			uiDraw, -- 1356
			uiArt, -- 1356
			"ep_well_veil", -- 1356
			cx, -- 1356
			titleY - 152, -- 1356
			560, -- 1356
			30, -- 1356
			PALETTE.inkWarm, -- 1356
			0.68, -- 1356
			0 -- 1356
		) -- 1356
		texts:put( -- 1357
			"xs", -- 1357
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1357
			cx, -- 1357
			titleY - 152, -- 1357
			toColor(PALETTE.cyanCore), -- 1357
			0.5, -- 1357
			0.5, -- 1357
			"Center", -- 1357
			1, -- 1357
			0.9, -- 1357
			0.08 -- 1357
		) -- 1357
	end -- 1357
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1360
	local btnW = 286 -- 1365
	local btnH = 44 -- 1366
	local gap = 14 -- 1367
	local baseY = math.max(150, h * 0.34) -- 1368
	local boxes = {} -- 1369
	local i = 0 -- 1370
	do -- 1370
		i = 0 -- 1371
		while i < #items do -- 1371
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1372
			i = i + 1 -- 1371
		end -- 1371
	end -- 1371
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1374
	do -- 1374
		i = 0 -- 1376
		while i < #items do -- 1376
			local box = boxes[i + 1] -- 1377
			local active = self.epilogueSelected == i -- 1378
			local cy = box.y + box.height * 0.5 -- 1379
			if active then -- 1379
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1381
				drawSilkRibbon( -- 1382
					uiDraw, -- 1382
					uiArt, -- 1382
					"ep_rib_" .. tostring(i), -- 1382
					cx, -- 1382
					cy, -- 1382
					btnW + 24, -- 1382
					btnH, -- 1382
					PALETTE.rougeSoft, -- 1382
					0.62 * breathe, -- 1382
					0 -- 1382
				) -- 1382
				drawHairline( -- 1383
					uiInkDraw, -- 1383
					uiArt, -- 1383
					"ep_line_" .. tostring(i), -- 1383
					cx, -- 1383
					box.y + 3, -- 1383
					btnW - 44, -- 1383
					PALETTE.silkLine, -- 1383
					0.48 * breathe, -- 1383
					false, -- 1383
					2 -- 1383
				) -- 1383
				drawBlossomDot( -- 1384
					uiInkDraw, -- 1384
					uiArt, -- 1384
					"ep_dot_" .. tostring(i), -- 1384
					box.x + 22, -- 1384
					cy, -- 1384
					13, -- 1384
					PALETTE.rouge, -- 1384
					0.96, -- 1384
					4 -- 1384
				) -- 1384
			else -- 1384
				drawSilkVeil( -- 1386
					uiDraw, -- 1386
					uiArt, -- 1386
					"ep_idle_" .. tostring(i), -- 1386
					cx, -- 1386
					cy, -- 1386
					btnW, -- 1386
					btnH - 2, -- 1386
					PALETTE.inkWash, -- 1386
					0.58, -- 1386
					0 -- 1386
				) -- 1386
				drawBlossomDot( -- 1387
					uiInkDraw, -- 1387
					uiArt, -- 1387
					"ep_dot_" .. tostring(i), -- 1387
					box.x + 22, -- 1387
					cy, -- 1387
					8, -- 1387
					PALETTE.silkDim, -- 1387
					0.42, -- 1387
					3 -- 1387
				) -- 1387
			end -- 1387
			texts:put( -- 1389
				"sm", -- 1390
				items[i + 1].zh, -- 1391
				cx + 6, -- 1392
				cy, -- 1393
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1394
				0.5, -- 1395
				0.5, -- 1396
				"Center", -- 1397
				active and 2.6 or 1.6, -- 1398
				active and 1 or 0.88, -- 1399
				0.08 -- 1400
			) -- 1400
			i = i + 1 -- 1376
		end -- 1376
	end -- 1376
	local footer = getActiveTarget():epilogueFooterHint(frame.mode, frame.layout) -- 1404
	texts:put( -- 1405
		"xs", -- 1405
		footer, -- 1405
		cx, -- 1405
		38 + frame.safe.bottom * 0.4, -- 1405
		toColor(PALETTE.textDim), -- 1405
		0.5, -- 1405
		0.5, -- 1405
		"Center", -- 1405
		1.2, -- 1405
		0.84, -- 1405
		0.08 -- 1405
	) -- 1405
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1407
	if hit >= 0 or frame.keys.confirm then -- 1407
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1409
		local id = items[idx + 1].id -- 1410
		if id == "history" then -- 1410
			return {type = "openHistory"} -- 1411
		end -- 1411
		if id == "replay" then -- 1411
			return {type = "replayStory"} -- 1412
		end -- 1412
		return {type = "backTitle"} -- 1413
	end -- 1413
	return {type = "none"} -- 1415
end -- 1320
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1422
	if frame.back then -- 1422
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1433
	end -- 1433
	local total = #HISTORY_CARDS -- 1436
	if frame.keys.left or frame.prevTab then -- 1436
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1438
	elseif frame.keys.right or frame.nextTab then -- 1438
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1440
	end -- 1440
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1442
	uiDraw:drawRect( -- 1444
		Rect(0, 0, w, h), -- 1444
		Color(7, 9, 15, 206) -- 1444
	) -- 1444
	local cx = w * 0.5 -- 1445
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1446
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1447
	local px = cx - pageW * 0.5 -- 1448
	local py = (h - pageH) * 0.5 + 14 -- 1449
	local midY = py + pageH * 0.5 -- 1450
	uiArt:tryPlace( -- 1452
		"ink_frame_mask", -- 1452
		"hist_shadow", -- 1452
		cx, -- 1452
		midY - 6, -- 1452
		pageW + 52, -- 1452
		pageH + 46, -- 1452
		{ -- 1452
			color = toColor(PALETTE.voidDark), -- 1453
			opacity = 0.84, -- 1453
			layer = -1 -- 1453
		} -- 1453
	) -- 1453
	if not uiArt:tryPlace( -- 1453
		"ink_song_paper", -- 1455
		"hist_paper", -- 1455
		cx, -- 1455
		midY, -- 1455
		pageW, -- 1455
		pageH, -- 1455
		{opacity = 0.98, layer = 1} -- 1455
	) then -- 1455
		uiDraw:drawRect( -- 1456
			Rect(px, py, pageW, pageH), -- 1456
			toColor(PALETTE.xuanPaper, 248), -- 1456
			1, -- 1456
			toColor(PALETTE.silkDim, 180) -- 1456
		) -- 1456
	end -- 1456
	fillRadialGlow( -- 1458
		uiGlow, -- 1458
		cx, -- 1458
		midY + 40, -- 1458
		260, -- 1458
		140, -- 1458
		Color(236, 224, 202, 16), -- 1458
		Color(236, 224, 202, 0), -- 1458
		14 -- 1458
	) -- 1458
	local inX = px + 42 -- 1461
	local inY = py + 32 -- 1462
	local inW = pageW - 84 -- 1463
	local inH = pageH - 64 -- 1464
	local redSilk = toColor(PALETTE.rouge, 118) -- 1465
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1466
	uiInkDraw:drawRect( -- 1467
		Rect(inX, inY, inW, inH), -- 1467
		Color(0, 0, 0, 0), -- 1467
		0.95, -- 1467
		redSilk -- 1467
	) -- 1467
	uiInkDraw:drawRect( -- 1468
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1468
		Color(0, 0, 0, 0), -- 1468
		0.55, -- 1468
		redSilkFaint -- 1468
	) -- 1468
	local headY = inY + inH - 30 -- 1471
	texts:put( -- 1472
		"md", -- 1472
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1472
		inX + 20, -- 1472
		headY, -- 1472
		toColor(PALETTE.xuanInk), -- 1472
		0, -- 1472
		0.5, -- 1472
		"Left", -- 1472
		2, -- 1472
		0.96, -- 1472
		0 -- 1472
	) -- 1472
	texts:put( -- 1473
		"xs", -- 1473
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1473
		inX + inW - 20, -- 1473
		headY, -- 1473
		toColor(PALETTE.rouge), -- 1473
		1, -- 1473
		0.5, -- 1473
		"Right", -- 1473
		1.8, -- 1473
		0.88, -- 1473
		0 -- 1473
	) -- 1473
	uiInkDraw:drawSegment( -- 1474
		Vec2(inX + 14, headY - 22), -- 1474
		Vec2(inX + inW - 14, headY - 22), -- 1474
		0.85, -- 1474
		redSilk -- 1474
	) -- 1474
	texts:put( -- 1477
		"xs", -- 1477
		card.subtitle, -- 1477
		inX + 20, -- 1477
		headY - 42, -- 1477
		toColor(PALETTE.xuanInkSub), -- 1477
		0, -- 1477
		0.5, -- 1477
		"Left", -- 1477
		1.4, -- 1477
		0.86, -- 1477
		0 -- 1477
	) -- 1477
	local function wrapZh(src, maxUnits) -- 1480
		local out = {} -- 1481
		local buf = "" -- 1482
		local units = 0 -- 1483
		local ci = 0 -- 1484
		while ci < #src do -- 1484
			local b = __TS__StringCharCodeAt(src, ci) -- 1486
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1487
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1488
			local u = b < 128 and 0.56 or 1.02 -- 1489
			if units + u > maxUnits and buf ~= "" then -- 1489
				out[#out + 1] = buf -- 1491
				buf = ch -- 1492
				units = u -- 1493
			else -- 1493
				buf = buf .. ch -- 1495
				units = units + u -- 1496
			end -- 1496
			ci = ci + step -- 1498
		end -- 1498
		if buf ~= "" then -- 1498
			out[#out + 1] = buf -- 1501
		end -- 1501
		return out -- 1503
	end -- 1480
	local charsPerLine = math.max( -- 1506
		24, -- 1506
		math.floor((inW - 44) / 20) -- 1506
	) -- 1506
	local cursorY = headY - 76 -- 1507
	local pi = 0 -- 1508
	do -- 1508
		pi = 0 -- 1509
		while pi < #card.paragraphs do -- 1509
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1510
			local li = 0 -- 1511
			do -- 1511
				li = 0 -- 1512
				while li < #lines do -- 1512
					texts:put( -- 1513
						"sm", -- 1513
						lines[li + 1], -- 1513
						inX + 22, -- 1513
						cursorY, -- 1513
						toColor(PALETTE.xuanInk), -- 1513
						0, -- 1513
						0.5, -- 1513
						"Left", -- 1513
						0.6, -- 1513
						0.94, -- 1513
						0 -- 1513
					) -- 1513
					cursorY = cursorY - 30 -- 1514
					li = li + 1 -- 1512
				end -- 1512
			end -- 1512
			cursorY = cursorY - 12 -- 1516
			pi = pi + 1 -- 1509
		end -- 1509
	end -- 1509
	local footY = inY + 26 -- 1520
	uiInkDraw:drawSegment( -- 1521
		Vec2(inX + 14, footY + 20), -- 1521
		Vec2(inX + inW - 14, footY + 20), -- 1521
		0.6, -- 1521
		redSilkFaint -- 1521
	) -- 1521
	texts:put( -- 1522
		"xs", -- 1522
		card.footnote, -- 1522
		inX + 20, -- 1522
		footY, -- 1522
		toColor(PALETTE.xuanInkSub), -- 1522
		0, -- 1522
		0.5, -- 1522
		"Left", -- 1522
		0.4, -- 1522
		0.84, -- 1522
		0 -- 1522
	) -- 1522
	local navY = math.max(30, py - 48) -- 1525
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1526
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1527
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1528
	local function drawNavBtn(box, tag, label) -- 1530
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1531
		drawSilkVeil( -- 1532
			uiDraw, -- 1532
			uiArt, -- 1532
			"hist_btn_" .. tag, -- 1532
			box.x + box.width * 0.5, -- 1532
			box.y + box.height * 0.5, -- 1532
			box.width, -- 1532
			box.height, -- 1532
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1532
			hover and 0.86 or 0.72, -- 1532
			2 -- 1532
		) -- 1532
		texts:put( -- 1533
			"xs", -- 1533
			label, -- 1533
			box.x + box.width * 0.5, -- 1533
			box.y + box.height * 0.5, -- 1533
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1533
			0.5, -- 1533
			0.5, -- 1533
			"Center", -- 1533
			1.4, -- 1533
			0.94, -- 1533
			0.08 -- 1533
		) -- 1533
		return hover and frame.click -- 1534
	end -- 1530
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1530
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1538
	end -- 1538
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1538
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1541
	end -- 1541
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1541
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1544
	end -- 1544
	if frame.keys.confirm then -- 1544
		if self.historyCardIndex + 1 < total then -- 1544
			self.historyCardIndex = self.historyCardIndex + 1 -- 1549
		else -- 1549
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1551
		end -- 1551
	end -- 1551
	return {type = "none"} -- 1554
end -- 1422
return ____exports -- 1422