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
local TITLE_ITEMS = {{id = "start", zh = "开始游戏"}, {id = "chapters", zh = "选择章节"}, {id = "controls", zh = "操作说明"}, {id = "quit", zh = "退出游戏"}} -- 85
local CHAPTERS = __TS__ArrayFilter( -- 93
	__TS__ArrayMap( -- 93
		ROOMS, -- 93
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 93
	), -- 93
	function(____, chapter) return chapter.room.key ~= "museum" and chapter.room.key ~= "street" and chapter.room.key ~= "checkpoint" end -- 94
) -- 94
local PAUSE_ITEMS = { -- 97
	{id = "resume", zh = "继续游戏"}, -- 98
	{id = "retry", zh = "重试检查点"}, -- 99
	{id = "controls", zh = "操作说明"}, -- 100
	{id = "assist", zh = "按键辅助：关"}, -- 101
	{id = "fullscreen", zh = "显示：窗口"}, -- 102
	{id = "chapters", zh = "选择章节"}, -- 103
	{id = "title", zh = "返回标题"}, -- 104
	{id = "quit", zh = "退出游戏"}, -- 105
	{id = "settings", zh = "操控设置"} -- 106
} -- 106
local SETTINGS_ROWS = { -- 110
	{id = "modePref", title = "操作模式"}, -- 111
	{id = "aimAssist", title = "瞄准磁吸"}, -- 112
	{id = "gpLayout", title = "手柄确认键"}, -- 113
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 114
	{id = "touchOpacity", title = "触控按键透度"}, -- 115
	{id = "touchScale", title = "触控按键大小"}, -- 116
	{id = "haptics", title = "触觉震动反馈"}, -- 117
	{id = "masterVol", title = "主音量"}, -- 118
	{id = "bgmVol", title = "音乐音量"}, -- 119
	{id = "sfxVol", title = "音效与环境"}, -- 120
	{id = "voiceVol", title = "人声音量"}, -- 121
	{id = "back", title = "返回暂歇菜单"} -- 122
} -- 122
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 125
local EPIGRAPH_RIGHT = { -- 126
	"城", -- 126
	"破", -- 126
	"那", -- 126
	"天", -- 126
	"", -- 126
	"他", -- 126
	"留", -- 126
	"下", -- 126
	"断", -- 126
	"后" -- 126
} -- 126
local EPIGRAPH_LEFT = { -- 127
	"她", -- 127
	"独", -- 127
	"自", -- 127
	"走", -- 127
	"向", -- 127
	"北", -- 127
	"塔" -- 127
} -- 127
local function pressedKeys() -- 152
	return { -- 153
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 154
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 155
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 156
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 157
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 158
	} -- 158
end -- 152
local function hitIndex(boxes, pointer, inside) -- 162
	if not inside then -- 163
		return -1 -- 164
	end -- 164
	return __TS__ArrayFindIndex( -- 166
		boxes, -- 166
		function(____, box) return box:containsPoint(pointer) end -- 166
	) -- 166
end -- 162
____exports.MenuRenderer = __TS__Class() -- 169
local MenuRenderer = ____exports.MenuRenderer -- 169
MenuRenderer.name = "MenuRenderer" -- 169
function MenuRenderer.prototype.____constructor(self) -- 169
	self.selected = 0 -- 170
	self.chapterSelected = 0 -- 171
	self.pauseSelected = 0 -- 172
	self.settingsSelected = 0 -- 173
	self.epilogueSelected = 0 -- 174
	self.epilogueEnding = "lamp" -- 175
	self.epilogueBothCleared = false -- 176
	self.historyCardIndex = 0 -- 177
	self.historyFromEpilogue = false -- 178
	self.hasSession = false -- 180
	self.controlsTab = "kbm" -- 182
	self.chaptersFromPause = false -- 194
	self.pauseShowControls = false -- 195
	self.pauseShowSettings = false -- 196
	self.controlsTabManual = false -- 197
	self.previousKeys = {} -- 198
	self.queuedKeys = {} -- 199
	self.queuedBack = false -- 200
	self.queuedSkip = false -- 201
	self.splashTime = 0 -- 202
	self.time = 0 -- 203
end -- 169
function MenuRenderer.prototype.emitSound(self, kind) -- 188
	if self.onUiSound ~= nil then -- 189
		self:onUiSound(kind) -- 190
	end -- 190
end -- 188
function MenuRenderer.prototype.resetSplash(self) -- 205
	self.splashTime = 0 -- 206
	self.queuedSkip = false -- 207
	self:resetInput() -- 208
end -- 205
function MenuRenderer.prototype.isShowingPauseControls(self) -- 211
	return self.pauseShowControls -- 212
end -- 211
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 215
	return self.pauseShowSettings -- 216
end -- 215
function MenuRenderer.prototype.openPauseSettings(self) -- 219
	self.pauseShowControls = false -- 220
	self.pauseShowSettings = true -- 221
	self.settingsSelected = 0 -- 222
	self:resetInput() -- 223
end -- 219
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 226
	self.chaptersFromPause = roomIndex ~= nil -- 227
	self.chapterSelected = math.max( -- 228
		0, -- 228
		__TS__ArrayFindIndex( -- 228
			CHAPTERS, -- 228
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 228
		) -- 228
	) -- 228
	self.pauseShowControls = false -- 229
	self.pauseShowSettings = false -- 230
	self:resetInput() -- 231
end -- 226
function MenuRenderer.prototype.openPause(self) -- 234
	self.pauseSelected = 0 -- 235
	self.pauseShowControls = false -- 236
	self.pauseShowSettings = false -- 237
	self:resetInput() -- 238
end -- 234
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 241
	if ending == nil then -- 241
		ending = "lamp" -- 241
	end -- 241
	if bothCleared == nil then -- 241
		bothCleared = false -- 241
	end -- 241
	self.epilogueEnding = ending -- 242
	self.epilogueBothCleared = bothCleared -- 243
	self.epilogueSelected = 0 -- 244
	self:resetInput() -- 245
end -- 241
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 248
	if fromEpilogue == nil then -- 248
		fromEpilogue = true -- 248
	end -- 248
	self.historyFromEpilogue = fromEpilogue -- 249
	self.historyCardIndex = 0 -- 250
	self:resetInput() -- 251
end -- 248
function MenuRenderer.prototype.triggerBack(self) -- 255
	self.queuedBack = true -- 256
end -- 255
function MenuRenderer.prototype.resetInput(self) -- 260
	self.previousKeys = pressedKeys() -- 261
	self.queuedKeys = {} -- 262
	self.queuedBack = false -- 263
	self.queuedSkip = false -- 264
	self.controlsTabManual = false -- 265
end -- 260
function MenuRenderer.prototype.onKeyEvent(self, key) -- 269
	self.queuedSkip = true -- 270
	if key == "Up" or key == "W" then -- 271
		self.queuedKeys.up = true -- 272
	elseif key == "Down" or key == "S" then -- 273
		self.queuedKeys.down = true -- 274
	elseif key == "Left" or key == "A" then -- 275
		self.queuedKeys.left = true -- 276
	elseif key == "Right" or key == "D" then -- 277
		self.queuedKeys.right = true -- 278
	elseif key == "Return" or key == "Space" then -- 279
		self.queuedKeys.confirm = true -- 280
	elseif key == "Escape" then -- 281
		self.queuedBack = true -- 282
	end -- 282
end -- 269
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 286
	local held = pressedKeys() -- 287
	local prev = self.previousKeys -- 288
	local queued = self.queuedKeys -- 289
	local useUiPtr = input.uiInside or input.uiPressed -- 292
	local rawX = useUiPtr and input.uiX or input.mx -- 293
	local rawY = useUiPtr and input.uiY or input.my -- 294
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 295
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 296
	local ____useUiPtr_0 -- 297
	if useUiPtr then -- 297
		____useUiPtr_0 = input.uiInside -- 297
	else -- 297
		____useUiPtr_0 = input.inside -- 297
	end -- 297
	local inside = ____useUiPtr_0 -- 297
	local ____useUiPtr_1 -- 298
	if useUiPtr then -- 298
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 298
	else -- 298
		____useUiPtr_1 = input.inside and input.fire.pressed -- 298
	end -- 298
	local click = ____useUiPtr_1 -- 298
	local touchMode = input:isTouchMode() -- 299
	local frame = { -- 301
		keys = { -- 302
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 303
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 304
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 305
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 306
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 307
		}, -- 307
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 309
		prevTab = input.navPrevTab, -- 310
		nextTab = input.navNextTab, -- 311
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 312
		pointer = Vec2(rawX / scale, rawY / scale), -- 313
		inside = inside, -- 314
		click = click, -- 315
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 316
		mode = input.inputMode, -- 317
		layout = input.gamepadLayout, -- 318
		safe = safe -- 319
	} -- 319
	self.previousKeys = held -- 321
	self.queuedKeys = {} -- 322
	self.queuedBack = false -- 323
	self.queuedSkip = false -- 324
	return frame -- 325
end -- 286
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 328
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 329
	if frame.click and hit >= 0 then -- 330
		return hit -- 331
	end -- 331
	if frame.keys.up then -- 333
		return (selected + #boxes - 1) % #boxes -- 334
	end -- 334
	if frame.keys.down then -- 336
		return (selected + 1) % #boxes -- 337
	end -- 337
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 339
end -- 328
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 342
	if safeUi == nil then -- 358
		safeUi = ZERO_SAFE_INSETS -- 358
	end -- 358
	self.time = self.time + dt -- 360
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 361
	if screen ~= "splash" or splashDissolving then -- 362
		local artW = math.max(w, h * 16 / 9) -- 363
		local artH = artW * 9 / 16 -- 364
		if not backdropArt:tryPlace( -- 365
			"title_backdrop", -- 365
			"menu_landscape", -- 365
			w * 0.5, -- 365
			(h - artH) * 0.5, -- 365
			artW, -- 365
			artH -- 365
		) then -- 365
			stage:drawMenuBackdrop( -- 366
				bgDraw, -- 366
				bgGlow, -- 366
				w, -- 366
				h, -- 366
				self.time -- 366
			) -- 366
		end -- 366
	end -- 366
	local frame = self:readFrame(input, uiScale, safeUi) -- 370
	w = w / uiScale -- 371
	h = h / uiScale -- 372
	if screen == "splash" then -- 374
		return self:drawSplash( -- 375
			dt, -- 375
			frame, -- 375
			uiDraw, -- 375
			uiArt, -- 375
			texts, -- 375
			w, -- 375
			h -- 375
		) -- 375
	end -- 375
	if screen == "title" then -- 377
		return self:drawTitle( -- 378
			frame, -- 378
			uiDraw, -- 378
			uiInkDraw, -- 378
			uiArt, -- 378
			uiGlow, -- 378
			texts, -- 378
			w, -- 378
			h -- 378
		) -- 378
	end -- 378
	if screen == "chapters" then -- 380
		return self:drawChapters( -- 381
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
	if screen == "epilogue" then -- 383
		return self:drawEpilogue( -- 384
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
	if screen == "history" then -- 386
		return self:drawHistory( -- 387
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
	return self:drawControls( -- 389
		frame, -- 389
		uiDraw, -- 389
		uiInkDraw, -- 389
		uiArt, -- 389
		uiGlow, -- 389
		texts, -- 389
		w, -- 389
		h -- 389
	) -- 389
end -- 342
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 398
	local safeDt = math.min( -- 407
		0.1, -- 407
		math.max(0, dt) -- 407
	) -- 407
	self.splashTime = self.splashTime + safeDt -- 408
	local t = self.splashTime -- 409
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 411
	if wantSkip or t >= 4.65 then -- 412
		self.splashTime = 0 -- 413
		return {type = "splashDone"} -- 414
	end -- 414
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 417
	local bgR = t < 2.2 and 13 or 11 -- 418
	local bgG = t < 2.2 and 16 or 13 -- 419
	local bgB = t < 2.2 and 24 or 19 -- 420
	uiDraw:drawRect( -- 421
		Rect(0, 0, w, h), -- 421
		Color( -- 421
			bgR, -- 421
			bgG, -- 421
			bgB, -- 421
			math.floor(255 * fadeOutCurtain + 0.5) -- 421
		) -- 421
	) -- 421
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 423
		if localT <= 0 or localT >= endT then -- 424
			return 0 -- 424
		end -- 424
		if localT < fadeIn then -- 425
			local u = localT / fadeIn -- 426
			return u * u * (3 - 2 * u) -- 427
		end -- 427
		if localT <= holdEnd then -- 429
			return 1 -- 429
		end -- 429
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 430
		return 1 - u * u * (3 - 2 * u) -- 431
	end -- 423
	if t < 2.2 then -- 434
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 435
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 436
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 437
		if not uiArt:tryPlace( -- 438
			"brand_team_logo", -- 438
			"splash_team_logo", -- 438
			w * 0.5, -- 438
			h * 0.54, -- 438
			logoH * 2, -- 438
			logoH, -- 438
			{opacity = alpha, layer = 2} -- 438
		) then -- 438
			texts:put( -- 439
				"banner", -- 439
				"OUTSIDER", -- 439
				w * 0.5, -- 439
				h * 0.52, -- 439
				toColor(PALETTE.textBright), -- 439
				0.5, -- 439
				0.5, -- 439
				"Center", -- 439
				6, -- 439
				alpha, -- 439
				0 -- 439
			) -- 439
		end -- 439
		texts:put( -- 441
			"xs", -- 441
			"Powered by Dora SSR", -- 441
			w * 0.5, -- 441
			58 + frame.safe.bottom * 0.4, -- 441
			toColor(PALETTE.textDim), -- 441
			0.5, -- 441
			0.5, -- 441
			"Center", -- 441
			1.8, -- 441
			alpha * 0.62, -- 441
			0 -- 441
		) -- 441
	elseif t < 4.25 then -- 442
		local localT = t - 2.2 -- 443
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 444
		local sway = math.sin(localT * 1.1) * 8 -- 445
		drawMistCurve( -- 446
			uiArt, -- 446
			"splash_game_mist", -- 446
			w * 0.5 + sway, -- 446
			h * 0.46, -- 446
			560, -- 446
			110, -- 446
			PALETTE.jadeMist, -- 446
			0.16 * alpha, -- 446
			1 -- 446
		) -- 446
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 447
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 448
		if not uiArt:tryPlace( -- 449
			"brand_game_logo_h", -- 449
			"splash_game_logo", -- 449
			w * 0.5, -- 449
			h * 0.52, -- 449
			logoH * 2.4, -- 449
			logoH, -- 449
			{opacity = alpha, layer = 2} -- 449
		) then -- 449
			texts:put( -- 450
				"title", -- 450
				"向西守望", -- 450
				w * 0.5, -- 450
				h * 0.52, -- 450
				toColor(PALETTE.textBright), -- 450
				0.5, -- 450
				0.5, -- 450
				"Center", -- 450
				8, -- 450
				alpha, -- 450
				0 -- 450
			) -- 450
		end -- 450
	end -- 450
	if t >= 0.35 and t < 4.15 then -- 454
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 455
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 456
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
end -- 398
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
	if not placedBrandTitle then -- 495
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
			if ch ~= "" then -- 541
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
	}) or baseItems -- 555
	if self.selected >= #items then -- 556
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
	if self.selected ~= prevTitleSel then -- 571
		self:emitSound("hover") -- 572
	end -- 572
	do -- 572
		i = 0 -- 575
		while i < #items do -- 575
			local by = boxes[i + 1].y -- 576
			local active = self.selected == i -- 577
			local cy = by + btnH * 0.5 -- 578
			local shiftX = active and 10 or 0 -- 579
			if active then -- 581
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
			i = i + 1 -- 575
		end -- 575
	end -- 575
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 606
	texts:put( -- 613
		"xs", -- 613
		titleHint, -- 613
		menuX + 12, -- 613
		42 + frame.safe.bottom * 0.45, -- 613
		toColor(PALETTE.textDim), -- 613
		0, -- 613
		0.5, -- 613
		"Left", -- 613
		1.4, -- 613
		0.88, -- 613
		0.08 -- 613
	) -- 613
	local badgeRight = w - frame.safe.right * 0.5 -- 616
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 617
	fillHGradRect( -- 618
		uiDraw, -- 618
		badgeRight - 270, -- 618
		0, -- 618
		270 + frame.safe.right * 0.5, -- 618
		86, -- 618
		Color(8, 10, 16, 0), -- 618
		Color(8, 10, 16, 204) -- 618
	) -- 618
	uiArt:tryPlace( -- 619
		"brand_team_badge", -- 619
		"title_team_badge", -- 619
		badgeRight - 118, -- 619
		badgeY, -- 619
		168, -- 619
		54, -- 619
		{opacity = 0.95, layer = 3} -- 619
	) -- 619
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 623
	if hit >= 0 or frame.keys.confirm then -- 624
		local idx = hit >= 0 and hit or self.selected -- 625
		local id = items[idx + 1].id -- 626
		if id == "continue" then -- 627
			self:emitSound("start") -- 627
			return {type = "continue"} -- 627
		end -- 627
		if id == "start" then -- 628
			self:emitSound("start") -- 628
			return {type = "start"} -- 628
		end -- 628
		if id == "chapters" then -- 629
			self:emitSound("confirm") -- 629
			return {type = "openChapters"} -- 629
		end -- 629
		if id == "quit" then -- 630
			self:emitSound("back") -- 630
			return {type = "quit"} -- 630
		end -- 630
		self:emitSound("confirm") -- 631
		return {type = "openControls"} -- 632
	end -- 632
	return {type = "none"} -- 634
end -- 467
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 637
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 647
	if frame.back then -- 648
		self:emitSound("back") -- 649
		return back -- 650
	end -- 650
	local extraH = math.max(0, h - 720) -- 653
	local marginX = math.max( -- 654
		96, -- 654
		56 + math.max(frame.safe.left, frame.safe.right) -- 654
	) -- 654
	local splitTrack = #CHAPTERS > 8 -- 655
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 656
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 657
	local rowGap = 68 -- 658
	local trackX0 = marginX + 34 -- 659
	local trackX1 = w - marginX - 34 -- 660
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 661
	local stationBoxes = {} -- 663
	local s = 0 -- 664
	do -- 664
		s = 0 -- 665
		while s < #CHAPTERS do -- 665
			local sx = trackX0 + s % perRow * stepX -- 666
			local sy = trackY - math.floor(s / perRow) * rowGap -- 667
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 668
			s = s + 1 -- 665
		end -- 665
	end -- 665
	local prevSelected = self.chapterSelected -- 671
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 672
	local keys = frame.keys -- 673
	if frame.click and hitStation >= 0 then -- 674
		self.chapterSelected = hitStation -- 675
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 676
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 677
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 678
	elseif keys.down and self.chapterSelected < perRow then -- 679
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 680
	elseif keys.up and self.chapterSelected >= perRow then -- 681
		self.chapterSelected = self.chapterSelected - perRow -- 682
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 683
		self.chapterSelected = hitStation -- 684
	end -- 684
	if self.chapterSelected ~= prevSelected then -- 686
		self:emitSound("hover") -- 687
	end -- 687
	uiDraw:drawRect( -- 690
		Rect(0, 0, w, h), -- 690
		Color(10, 12, 19, 198) -- 690
	) -- 690
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 692
	texts:put( -- 693
		"banner", -- 693
		"选择章节", -- 693
		marginX, -- 693
		topHeadY, -- 693
		toColor(PALETTE.textBright), -- 693
		0, -- 693
		0.5, -- 693
		"Left", -- 693
		4.5, -- 693
		0.96, -- 693
		0.1 -- 693
	) -- 693
	drawHairline( -- 694
		uiInkDraw, -- 694
		uiArt, -- 694
		"chap_top_line", -- 694
		w * 0.5, -- 694
		topHeadY - 34, -- 694
		w - marginX * 2, -- 694
		PALETTE.silkDim, -- 694
		0.6, -- 694
		true, -- 694
		2 -- 694
	) -- 694
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 696
	local theme = themeOf(activeRoom.key) -- 697
	local winX = marginX -- 698
	local winY = 266 + extraH * 0.44 -- 699
	local winW = math.min( -- 700
		520, -- 700
		math.max(360, (w - marginX * 2) * 0.46) -- 700
	) -- 700
	local winH = 296 -- 701
	local winBox = Rect(winX, winY, winW, winH) -- 702
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 703
	uiArt:tryPlace( -- 705
		"ink_frame_mask", -- 705
		"chap_win_shadow", -- 705
		winX + winW * 0.5, -- 705
		winY + winH * 0.5, -- 705
		winW + 40, -- 705
		winH + 34, -- 705
		{ -- 705
			color = toColor(PALETTE.inkVoid), -- 706
			opacity = 0.88, -- 706
			layer = -2 -- 706
		} -- 706
	) -- 706
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 708
	uiArt:tryPlace( -- 709
		bgSlot, -- 709
		"chap_win_art", -- 709
		winX + winW * 0.5, -- 709
		winY + 4, -- 709
		winW - 8, -- 709
		winH - 8, -- 709
		{opacity = 0.92, layer = -1} -- 709
	) -- 709
	fillVGradRect( -- 712
		uiInkDraw, -- 712
		winX, -- 712
		winY, -- 712
		winW, -- 712
		56, -- 712
		Color(10, 12, 19, 200), -- 712
		Color(10, 12, 19, 0) -- 712
	) -- 712
	fillVGradRect( -- 713
		uiInkDraw, -- 713
		winX, -- 713
		winY + winH - 36, -- 713
		winW, -- 713
		36, -- 713
		Color(10, 12, 19, 0), -- 713
		Color(10, 12, 19, 130) -- 713
	) -- 713
	fillHGradRect( -- 714
		uiInkDraw, -- 714
		winX, -- 714
		winY, -- 714
		34, -- 714
		winH, -- 714
		Color(10, 12, 19, 135), -- 714
		Color(10, 12, 19, 0) -- 714
	) -- 714
	fillHGradRect( -- 715
		uiInkDraw, -- 715
		winX + winW - 34, -- 715
		winY, -- 715
		34, -- 715
		winH, -- 715
		Color(10, 12, 19, 0), -- 715
		Color(10, 12, 19, 135) -- 715
	) -- 715
	drawFiligreeCorners( -- 716
		uiInkDraw, -- 716
		uiArt, -- 716
		"chap_win_frame", -- 716
		winX, -- 716
		winY, -- 716
		winW, -- 716
		winH, -- 716
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 716
		winHover and 0.92 or 0.72, -- 716
		34, -- 716
		true, -- 716
		3 -- 716
	) -- 716
	texts:put( -- 718
		"xs", -- 718
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 718
		winX + 20, -- 718
		winY + 22, -- 718
		toColor(PALETTE.textMid), -- 718
		0, -- 718
		0.5, -- 718
		"Left", -- 718
		1.8, -- 718
		0.9, -- 718
		0.08 -- 718
	) -- 718
	local infoX = winX + winW + 40 -- 720
	local infoW = math.max(240, w - marginX - infoX) -- 721
	local infoCenterY = winY + winH * 0.5 -- 722
	drawMistCurve( -- 723
		uiArt, -- 723
		"chap_info_mist", -- 723
		infoX + infoW * 0.5, -- 723
		infoCenterY + 36, -- 723
		math.min(420, infoW + 24), -- 723
		88, -- 723
		theme.accent, -- 723
		0.22, -- 723
		-1 -- 723
	) -- 723
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 725
	texts:put( -- 726
		"xs", -- 726
		theme.volumeTagZh, -- 726
		infoX, -- 726
		winY + winH - 44, -- 726
		toColor(volCol), -- 726
		0, -- 726
		0.5, -- 726
		"Left", -- 726
		2.8, -- 726
		0.92, -- 726
		0.08 -- 726
	) -- 726
	local sep = " · " -- 728
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 729
	local titleY = winY + winH - 98 -- 730
	if theme.backdropKey ~= nil then -- 731
		texts:put( -- 732
			"lg", -- 732
			theme.titleZh, -- 732
			infoX, -- 732
			titleY, -- 732
			toColor(PALETTE.textBright) -- 732
		) -- 732
	elseif sIdx > 0 then -- 733
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 734
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 735
		local lw = visualTextWidth(leftPart, 40) -- 736
		texts:put( -- 737
			"banner", -- 737
			leftPart, -- 737
			infoX, -- 737
			titleY, -- 737
			toColor(PALETTE.textBright), -- 737
			0, -- 737
			0.5, -- 737
			"Left", -- 737
			2, -- 737
			1, -- 737
			0.1 -- 737
		) -- 737
		drawBlossomDot( -- 738
			uiInkDraw, -- 738
			uiArt, -- 738
			"chap_title_dot", -- 738
			infoX + lw + 16, -- 738
			titleY - 2, -- 738
			11, -- 738
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 738
			0.9, -- 738
			4 -- 738
		) -- 738
		texts:put( -- 739
			"banner", -- 739
			rightPart, -- 739
			infoX + lw + 32, -- 739
			titleY, -- 739
			toColor(PALETTE.textBright), -- 739
			0, -- 739
			0.5, -- 739
			"Left", -- 739
			2, -- 739
			1, -- 739
			0.1 -- 739
		) -- 739
	else -- 739
		texts:put( -- 741
			"banner", -- 741
			theme.titleZh, -- 741
			infoX, -- 741
			titleY, -- 741
			toColor(PALETTE.textBright), -- 741
			0, -- 741
			0.5, -- 741
			"Left", -- 741
			2.4, -- 741
			1, -- 741
			0.1 -- 741
		) -- 741
	end -- 741
	drawHairline( -- 744
		uiInkDraw, -- 744
		uiArt, -- 744
		"chap_info_line", -- 744
		infoX + math.min(185, infoW * 0.5), -- 744
		titleY - 36, -- 744
		math.min(370, infoW), -- 744
		PALETTE.silkDim, -- 744
		0.58, -- 744
		false, -- 744
		2 -- 744
	) -- 744
	texts:put( -- 745
		"sm", -- 745
		theme.introWhisper, -- 745
		infoX, -- 745
		titleY - 72, -- 745
		toColor(PALETTE.textMid), -- 745
		0, -- 745
		0.5, -- 745
		"Left", -- 745
		0.8, -- 745
		0.94, -- 745
		0.08 -- 745
	) -- 745
	local goX = infoX -- 747
	local goY = winY + 26 -- 748
	local goW = 220 -- 749
	local goH = 42 -- 750
	local goBox = Rect(goX, goY, goW, goH) -- 751
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 752
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 753
	drawSilkRibbon( -- 754
		uiDraw, -- 754
		uiArt, -- 754
		"chap_go_rib", -- 754
		goX + 106, -- 754
		goY + 21, -- 754
		250, -- 754
		40, -- 754
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 754
		(goHover and 0.68 or 0.46) * breathe, -- 754
		0 -- 754
	) -- 754
	drawHairline( -- 755
		uiInkDraw, -- 755
		uiArt, -- 755
		"chap_go_line", -- 755
		goX + 94, -- 755
		goY + 3, -- 755
		196, -- 755
		PALETTE.silkLine, -- 755
		goHover and 0.68 or 0.4, -- 755
		false, -- 755
		2 -- 755
	) -- 755
	drawBlossomDot( -- 756
		uiInkDraw, -- 756
		uiArt, -- 756
		"chap_go_dot", -- 756
		goX + 14, -- 756
		goY + 21, -- 756
		14, -- 756
		PALETTE.rouge, -- 756
		0.96, -- 756
		4 -- 756
	) -- 756
	texts:put( -- 757
		"md", -- 757
		"入此卷章", -- 757
		goX + 34, -- 757
		goY + 21, -- 757
		toColor(PALETTE.textBright), -- 757
		0, -- 757
		0.5, -- 757
		"Left", -- 757
		3.8, -- 757
		1, -- 757
		0.1 -- 757
	) -- 757
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 758
	texts:put( -- 761
		"xs", -- 761
		chapConfirmTag, -- 761
		goX + 156, -- 761
		goY + 21, -- 761
		toColor(PALETTE.textDim), -- 761
		0, -- 761
		0.5, -- 761
		"Left", -- 761
		1, -- 761
		0.82, -- 761
		0.08 -- 761
	) -- 761
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 763
	local veilH = splitTrack and 156 or 126 -- 764
	drawSilkVeil( -- 765
		uiDraw, -- 765
		uiArt, -- 765
		"chap_track_veil", -- 765
		w * 0.5, -- 765
		veilCenterY, -- 765
		w - marginX * 1.1, -- 765
		veilH, -- 765
		PALETTE.inkWash, -- 765
		0.72, -- 765
		-2 -- 765
	) -- 765
	drawMistCurve( -- 766
		uiArt, -- 766
		"chap_track_mist", -- 766
		w * 0.5, -- 766
		trackY, -- 766
		trackX1 - trackX0 + 160, -- 766
		74, -- 766
		PALETTE.inkMist, -- 766
		0.62, -- 766
		-1 -- 766
	) -- 766
	uiInkDraw:drawSegment( -- 767
		Vec2(trackX0, trackY), -- 767
		Vec2(trackX1, trackY), -- 767
		0.9, -- 767
		toColor(PALETTE.silkDim, 145) -- 767
	) -- 767
	if splitTrack then -- 769
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 770
		uiInkDraw:drawSegment( -- 771
			Vec2(trackX0, trackY - rowGap), -- 771
			Vec2(lastX, trackY - rowGap), -- 771
			0.9, -- 771
			toColor(PALETTE.silkDim, 145) -- 771
		) -- 771
	else -- 771
		local midDivX = trackX0 + stepX * 3.5 -- 773
		uiInkDraw:drawSegment( -- 774
			Vec2(midDivX, trackY - 12), -- 774
			Vec2(midDivX, trackY + 12), -- 774
			0.8, -- 774
			toColor(PALETTE.silkDim, 120) -- 774
		) -- 774
		texts:put( -- 775
			"xs", -- 775
			"上卷 · 孤城护童", -- 775
			trackX0 + stepX * 1.5, -- 775
			trackY + 52, -- 775
			toColor(PALETTE.cyan), -- 775
			0.5, -- 775
			0.5, -- 775
			"Center", -- 775
			2.2, -- 775
			0.88, -- 775
			0.08 -- 775
		) -- 775
		texts:put( -- 776
			"xs", -- 776
			"下卷 · 独赴北塔", -- 776
			trackX0 + stepX * 5.5, -- 776
			trackY + 52, -- 776
			toColor(PALETTE.amber), -- 776
			0.5, -- 776
			0.5, -- 776
			"Center", -- 776
			2.2, -- 776
			0.88, -- 776
			0.08 -- 776
		) -- 776
	end -- 776
	local i = 0 -- 779
	do -- 779
		i = 0 -- 780
		while i < #CHAPTERS do -- 780
			local box = stationBoxes[i + 1] -- 781
			local sx = box.x + box.width * 0.5 -- 782
			local sy = box.y + box.height * 0.5 -- 783
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 784
			local active = self.chapterSelected == i -- 785
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 786
			if active then -- 788
				fillRadialGlow( -- 789
					uiGlow, -- 789
					sx, -- 789
					sy, -- 789
					26, -- 789
					26, -- 789
					toColor(PALETTE.rouge, 36 * breathe), -- 789
					Color(182, 58, 56, 0), -- 789
					12 -- 789
				) -- 789
				uiArt:tryPlace( -- 790
					"ink_enso_fine", -- 790
					"chap_st_ring_" .. tostring(i), -- 790
					sx, -- 790
					sy, -- 790
					32, -- 790
					32, -- 790
					{ -- 790
						color = toColor(PALETTE.silkLine), -- 791
						opacity = 0.78, -- 791
						angle = self.time * 18, -- 791
						layer = 3 -- 791
					} -- 791
				) -- 791
				drawBlossomDot( -- 793
					uiInkDraw, -- 793
					uiArt, -- 793
					"chap_st_dot_" .. tostring(i), -- 793
					sx, -- 793
					sy, -- 793
					17, -- 793
					PALETTE.rouge, -- 793
					0.98, -- 793
					4 -- 793
				) -- 793
			else -- 793
				uiArt:tryPlace( -- 795
					"ink_enso_fine", -- 795
					"chap_st_ring_" .. tostring(i), -- 795
					sx, -- 795
					sy, -- 795
					16, -- 795
					16, -- 795
					{ -- 795
						color = toColor(nodeCol), -- 796
						opacity = 0.62, -- 796
						layer = 3 -- 796
					} -- 796
				) -- 796
				drawBlossomDot( -- 798
					uiInkDraw, -- 798
					uiArt, -- 798
					"chap_st_dot_" .. tostring(i), -- 798
					sx, -- 798
					sy, -- 798
					7, -- 798
					PALETTE.silkLine, -- 798
					0.72, -- 798
					4 -- 798
				) -- 798
			end -- 798
			if not splitTrack then -- 801
				texts:put( -- 802
					"xs", -- 802
					rt.numeralZh, -- 802
					sx, -- 802
					sy + 25, -- 802
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 802
					0.5, -- 802
					0.5, -- 802
					"Center", -- 802
					0, -- 802
					active and 1 or 0.88, -- 802
					0.08 -- 802
				) -- 802
			end -- 802
			texts:put( -- 804
				"xs", -- 804
				rt.shortNameZh, -- 804
				sx, -- 804
				sy - 26, -- 804
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 804
				0.5, -- 804
				0.5, -- 804
				"Center", -- 804
				1, -- 804
				active and 1 or 0.84, -- 804
				0.08 -- 804
			) -- 804
			i = i + 1 -- 780
		end -- 780
	end -- 780
	local backX = marginX -- 807
	local backY = 40 + frame.safe.bottom * 0.45 -- 808
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 809
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 810
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 811
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 814
	drawSilkKeycap( -- 819
		uiInkDraw, -- 819
		texts, -- 819
		backX, -- 819
		backY + 5, -- 819
		48, -- 819
		24, -- 819
		chapBackTag, -- 819
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 819
		0.92, -- 819
		backHover -- 819
	) -- 819
	texts:put( -- 820
		"sm", -- 820
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 820
		backX + 60, -- 820
		backY + 17, -- 820
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 820
		0, -- 820
		0.5, -- 820
		"Left", -- 820
		1.8, -- 820
		0.9, -- 820
		0.08 -- 820
	) -- 820
	texts:put( -- 821
		"xs", -- 821
		chapFooter, -- 821
		w - marginX, -- 821
		backY + 17, -- 821
		toColor(PALETTE.textDim), -- 821
		1, -- 821
		0.5, -- 821
		"Right", -- 821
		1.2, -- 821
		0.75, -- 821
		0.08 -- 821
	) -- 821
	if frame.click and backHover then -- 823
		self:emitSound("back") -- 824
		return back -- 825
	end -- 825
	local ____temp_2 -- 828
	if frame.mode == "touch" then -- 828
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 829
	else -- 829
		____temp_2 = hitStation >= 0 -- 830
	end -- 830
	local stationConfirmed = ____temp_2 -- 828
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 831
		self:emitSound("start") -- 832
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 833
	end -- 833
	return {type = "none"} -- 835
end -- 637
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 839
	if backLabel == nil then -- 848
		backLabel = "返回标题" -- 848
	end -- 848
	if not self.controlsTabManual then -- 850
		self.controlsTab = frame.mode -- 851
	end -- 851
	local tabOrder = {"kbm", "gamepad", "touch"} -- 853
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 854
	local marginX = math.max( -- 855
		96, -- 855
		56 + math.max(frame.safe.left, frame.safe.right) -- 855
	) -- 855
	local tabW = 92 -- 856
	local tabH = 28 -- 857
	local tabGap = 10 -- 858
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 859
	local tabY = h - 82 - frame.safe.top * 0.35 -- 860
	local tabBoxes = { -- 861
		Rect(tabStartX, tabY, tabW, tabH), -- 862
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 863
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 864
	} -- 864
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 867
	if frame.click and hitTab >= 0 then -- 868
		if self.controlsTab ~= tabOrder[hitTab + 1] then -- 869
			self:emitSound("toggle") -- 870
		end -- 870
		self.controlsTab = tabOrder[hitTab + 1] -- 872
		self.controlsTabManual = true -- 873
	elseif frame.keys.left or frame.prevTab then -- 874
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 875
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 876
		self.controlsTabManual = true -- 877
		self:emitSound("toggle") -- 878
	elseif frame.keys.right or frame.nextTab then -- 879
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 880
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 881
		self.controlsTabManual = true -- 882
		self:emitSound("toggle") -- 883
	end -- 883
	local backX = marginX -- 886
	local backY = 40 + frame.safe.bottom * 0.45 -- 887
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 888
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 889
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 890
		self:emitSound("back") -- 891
		return {type = "backTitle"} -- 892
	end -- 892
	uiDraw:drawRect( -- 894
		Rect(0, 0, w, h), -- 894
		Color(10, 12, 19, 204) -- 894
	) -- 894
	local guide = controlsGuideRows(self.controlsTab) -- 896
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 897
	texts:put( -- 898
		"banner", -- 898
		"执器要诀", -- 898
		marginX, -- 898
		topHeadY, -- 898
		toColor(PALETTE.textBright), -- 898
		0, -- 898
		0.5, -- 898
		"Left", -- 898
		4.5, -- 898
		0.96, -- 898
		0.1 -- 898
	) -- 898
	texts:put( -- 899
		"xs", -- 899
		guide.subtitle, -- 899
		marginX + 196, -- 899
		topHeadY - 4, -- 899
		toColor(PALETTE.textDim), -- 899
		0, -- 899
		0.5, -- 899
		"Left", -- 899
		1.8, -- 899
		0.85, -- 899
		0.08 -- 899
	) -- 899
	drawHairline( -- 900
		uiInkDraw, -- 900
		uiArt, -- 900
		"ctrl_top_line", -- 900
		w * 0.5, -- 900
		topHeadY - 34, -- 900
		w - marginX * 2, -- 900
		PALETTE.silkDim, -- 900
		0.6, -- 900
		true, -- 900
		2 -- 900
	) -- 900
	local ti = 0 -- 902
	do -- 902
		ti = 0 -- 903
		while ti < #tabBoxes do -- 903
			local tb = tabBoxes[ti + 1] -- 904
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 905
			local hoverTab = hitTab == ti -- 906
			uiInkDraw:drawRect( -- 907
				tb, -- 908
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 909
				0.9, -- 910
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 911
			) -- 911
			texts:put( -- 913
				"xs", -- 914
				tabLabels[ti + 1], -- 915
				tb.x + tb.width * 0.5, -- 916
				tb.y + tb.height * 0.5, -- 917
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 918
				0.5, -- 919
				0.5, -- 920
				"Center", -- 921
				0.8, -- 922
				activeTab and 0.98 or 0.82, -- 923
				0.08 -- 924
			) -- 924
			ti = ti + 1 -- 903
		end -- 903
	end -- 903
	local extraH = math.max(0, h - 720) -- 928
	local areaY = 114 + frame.safe.bottom * 0.4 -- 929
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 930
	drawFiligreeCorners( -- 931
		uiInkDraw, -- 931
		uiArt, -- 931
		"ctrl_outer", -- 931
		marginX, -- 931
		areaY, -- 931
		w - marginX * 2, -- 931
		areaH, -- 931
		PALETTE.silkDim, -- 931
		0.52, -- 931
		34, -- 931
		false, -- 931
		2 -- 931
	) -- 931
	local midX = w * 0.5 -- 933
	uiArt:tryPlace( -- 934
		"ink_vstream", -- 934
		"ctrl_mid_stream", -- 934
		midX, -- 934
		areaY + areaH * 0.5, -- 934
		32, -- 934
		areaH - 18, -- 934
		{ -- 934
			color = toColor(PALETTE.silkDim), -- 935
			opacity = 0.52, -- 935
			layer = 1 -- 935
		} -- 935
	) -- 935
	drawBlossomDot( -- 937
		uiInkDraw, -- 937
		uiArt, -- 937
		"ctrl_mid_dot", -- 937
		midX, -- 937
		areaY + areaH * 0.5, -- 937
		11, -- 937
		PALETTE.silkLine, -- 937
		0.62, -- 937
		3 -- 937
	) -- 937
	local leftColX = marginX + 34 -- 939
	local colW = midX - leftColX - 42 -- 940
	local headY = areaY + areaH - 34 -- 941
	local rowStep = 52 + extraH * 0.08 -- 942
	drawBlossomDot( -- 944
		uiInkDraw, -- 944
		uiArt, -- 944
		"ctrl_l_dot", -- 944
		leftColX + 8, -- 944
		headY, -- 944
		12, -- 944
		PALETTE.cyan, -- 944
		0.88, -- 944
		3 -- 944
	) -- 944
	texts:put( -- 945
		"md", -- 945
		"周戍 · 护送与交锋", -- 945
		leftColX + 26, -- 945
		headY, -- 945
		toColor(PALETTE.cyanCore), -- 945
		0, -- 945
		0.5, -- 945
		"Left", -- 945
		2.4, -- 945
		0.98, -- 945
		0.08 -- 945
	) -- 945
	drawHairline( -- 946
		uiInkDraw, -- 946
		uiArt, -- 946
		"ctrl_l_line", -- 946
		leftColX + colW * 0.5, -- 946
		headY - 24, -- 946
		colW, -- 946
		PALETTE.cyanDim, -- 946
		0.58, -- 946
		false, -- 946
		2 -- 946
	) -- 946
	local i = 0 -- 948
	local keycapW = 160 -- 949
	do -- 949
		i = 0 -- 950
		while i < #guide.soldierRows do -- 950
			local ry = headY - 66 - i * rowStep -- 951
			drawSilkKeycap( -- 952
				uiInkDraw, -- 952
				texts, -- 952
				leftColX + 2, -- 952
				ry - 13, -- 952
				keycapW, -- 952
				26, -- 952
				guide.soldierRows[i + 1][1], -- 952
				PALETTE.cyan, -- 952
				0.92, -- 952
				false -- 952
			) -- 952
			texts:put( -- 953
				"sm", -- 953
				guide.soldierRows[i + 1][2], -- 953
				leftColX + keycapW + 16, -- 953
				ry, -- 953
				toColor(PALETTE.textBright), -- 953
				0, -- 953
				0.5, -- 953
				"Left", -- 953
				0.8, -- 953
				0.92, -- 953
				0.08 -- 953
			) -- 953
			i = i + 1 -- 950
		end -- 950
	end -- 950
	local rightColX = midX + 44 -- 956
	drawBlossomDot( -- 957
		uiInkDraw, -- 957
		uiArt, -- 957
		"ctrl_r_dot", -- 957
		rightColX + 8, -- 957
		headY, -- 957
		12, -- 957
		PALETTE.amber, -- 957
		0.88, -- 957
		3 -- 957
	) -- 957
	texts:put( -- 958
		"md", -- 958
		"小满 · 潜行与寻路", -- 958
		rightColX + 26, -- 958
		headY, -- 958
		toColor(PALETTE.amberCore), -- 958
		0, -- 958
		0.5, -- 958
		"Left", -- 958
		2.4, -- 958
		0.98, -- 958
		0.08 -- 958
	) -- 958
	drawHairline( -- 959
		uiInkDraw, -- 959
		uiArt, -- 959
		"ctrl_r_line", -- 959
		rightColX + colW * 0.5, -- 959
		headY - 24, -- 959
		colW, -- 959
		PALETTE.amberDim, -- 959
		0.58, -- 959
		false, -- 959
		2 -- 959
	) -- 959
	do -- 959
		i = 0 -- 961
		while i < #guide.childRows do -- 961
			local ry = headY - 66 - i * rowStep -- 962
			drawSilkKeycap( -- 963
				uiInkDraw, -- 963
				texts, -- 963
				rightColX + 2, -- 963
				ry - 13, -- 963
				keycapW, -- 963
				26, -- 963
				guide.childRows[i + 1][1], -- 963
				PALETTE.amber, -- 963
				0.92, -- 963
				false -- 963
			) -- 963
			texts:put( -- 964
				"sm", -- 964
				guide.childRows[i + 1][2], -- 964
				rightColX + keycapW + 16, -- 964
				ry, -- 964
				toColor(PALETTE.textBright), -- 964
				0, -- 964
				0.5, -- 964
				"Left", -- 964
				0.8, -- 964
				0.92, -- 964
				0.08 -- 964
			) -- 964
			i = i + 1 -- 961
		end -- 961
	end -- 961
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 967
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 970
	local keyW = frame.mode == "touch" and 76 or 110 -- 975
	drawSilkKeycap( -- 976
		uiInkDraw, -- 976
		texts, -- 976
		backX, -- 976
		backY + 5, -- 976
		keyW, -- 976
		24, -- 976
		ctrlBackKey, -- 976
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 976
		0.92, -- 976
		backHover -- 976
	) -- 976
	texts:put( -- 977
		"sm", -- 977
		backLabel, -- 977
		backX + keyW + 12, -- 977
		backY + 17, -- 977
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 977
		0, -- 977
		0.5, -- 977
		"Left", -- 977
		1.8, -- 977
		0.92, -- 977
		0.08 -- 977
	) -- 977
	texts:put( -- 978
		"xs", -- 978
		ctrlRightHint, -- 978
		w - marginX, -- 978
		backY + 17, -- 978
		toColor(PALETTE.textDim), -- 978
		1, -- 978
		0.5, -- 978
		"Right", -- 978
		1.2, -- 978
		0.78, -- 978
		0.08 -- 978
	) -- 978
	return {type = "none"} -- 980
end -- 839
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 984
	if frame.back then -- 995
		self:emitSound("back") -- 996
		return true -- 997
	end -- 997
	local caps = getPlatformCaps() -- 1000
	local s = input.settings -- 1001
	uiDraw:drawRect( -- 1003
		Rect(0, 0, w, h), -- 1003
		Color(10, 12, 19, 206) -- 1003
	) -- 1003
	local marginX = math.max( -- 1005
		96, -- 1005
		56 + math.max(frame.safe.left, frame.safe.right) -- 1005
	) -- 1005
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1006
	texts:put( -- 1007
		"banner", -- 1007
		"操控与声音", -- 1007
		marginX, -- 1007
		topHeadY, -- 1007
		toColor(PALETTE.textBright), -- 1007
		0, -- 1007
		0.5, -- 1007
		"Left", -- 1007
		4, -- 1007
		0.96, -- 1007
		0.1 -- 1007
	) -- 1007
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 操控与四通道音量实时生效" -- 1008
	texts:put( -- 1009
		"xs", -- 1009
		curSummary, -- 1009
		marginX + 224, -- 1009
		topHeadY - 4, -- 1009
		toColor(PALETTE.amberCore), -- 1009
		0, -- 1009
		0.5, -- 1009
		"Left", -- 1009
		1.4, -- 1009
		0.88, -- 1009
		0.08 -- 1009
	) -- 1009
	drawHairline( -- 1010
		uiInkDraw, -- 1010
		uiArt, -- 1010
		"set_top_line", -- 1010
		w * 0.5, -- 1010
		topHeadY - 30, -- 1010
		w - marginX * 2, -- 1010
		PALETTE.silkDim, -- 1010
		0.6, -- 1010
		true, -- 1010
		2 -- 1010
	) -- 1010
	local panelW = math.min(760, w - marginX * 2) -- 1012
	local panelX = (w - panelW) * 0.5 -- 1013
	local rowH = 34 -- 1014
	local rowStep = 39 -- 1015
	local firstY = topHeadY - 76 -- 1016
	local boxes = {} -- 1018
	local i = 0 -- 1019
	do -- 1019
		i = 0 -- 1020
		while i < #SETTINGS_ROWS do -- 1020
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1021
			i = i + 1 -- 1020
		end -- 1020
	end -- 1020
	local prevSetSel = self.settingsSelected -- 1023
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1024
	if self.settingsSelected ~= prevSetSel then -- 1025
		self:emitSound("hover") -- 1026
	end -- 1026
	local function applyDelta(rowId, delta) -- 1029
		if rowId == "back" then -- 1030
			self:emitSound("back") -- 1031
			return true -- 1032
		end -- 1032
		local audioChanged = false -- 1034
		if rowId == "modePref" then -- 1035
			input:cycleModePref(delta) -- 1036
		elseif rowId == "aimAssist" then -- 1037
			s.aimAssist = not s.aimAssist -- 1038
			saveControlSettings(s) -- 1039
		elseif rowId == "gpLayout" then -- 1040
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1041
			input.gamepadLayout = s.gamepadLayout -- 1042
			saveControlSettings(s) -- 1043
		elseif rowId == "crouchMode" then -- 1044
			s.crouchToggle = not s.crouchToggle -- 1045
			saveControlSettings(s) -- 1046
		elseif rowId == "touchOpacity" then -- 1047
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1048
			saveControlSettings(s) -- 1049
		elseif rowId == "touchScale" then -- 1050
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1051
			saveControlSettings(s) -- 1052
		elseif rowId == "haptics" then -- 1053
			s.haptics = not s.haptics -- 1054
			saveControlSettings(s) -- 1055
			if s.haptics then -- 1056
				local ____opt_3 = input:getTouch() -- 1057
				if ____opt_3 ~= nil then -- 1057
					____opt_3:vibrate(0.018) -- 1057
				end -- 1057
			end -- 1057
		elseif rowId == "masterVol" then -- 1059
			s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 1060
			saveControlSettings(s) -- 1061
			audioChanged = true -- 1062
		elseif rowId == "bgmVol" then -- 1063
			s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 1064
			saveControlSettings(s) -- 1065
			audioChanged = true -- 1066
		elseif rowId == "sfxVol" then -- 1067
			s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 1068
			saveControlSettings(s) -- 1069
			audioChanged = true -- 1070
		elseif rowId == "voiceVol" then -- 1071
			s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 1072
			saveControlSettings(s) -- 1073
			audioChanged = true -- 1074
		end -- 1074
		if audioChanged and self.onAudioSettingsChanged ~= nil then -- 1076
			self:onAudioSettingsChanged(input) -- 1077
		end -- 1077
		self:emitSound("toggle") -- 1079
		return false -- 1080
	end -- 1029
	local function valueTextOf(rowId) -- 1083
		if rowId == "modePref" then -- 1084
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1085
		end -- 1085
		if rowId == "aimAssist" then -- 1089
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1089
		end -- 1089
		if rowId == "gpLayout" then -- 1090
			return layoutLabelOf(s.gamepadLayout) -- 1090
		end -- 1090
		if rowId == "crouchMode" then -- 1091
			return s.crouchToggle and "点按切换" or "持续按住" -- 1091
		end -- 1091
		if rowId == "touchOpacity" then -- 1092
			return opacityLabelOf(s.touchOpacity) -- 1092
		end -- 1092
		if rowId == "touchScale" then -- 1093
			return scaleLabelOf(s.touchScale) -- 1093
		end -- 1093
		if rowId == "haptics" then -- 1094
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1094
		end -- 1094
		if rowId == "masterVol" then -- 1095
			return volumeLabelOf(s.masterVol) -- 1095
		end -- 1095
		if rowId == "bgmVol" then -- 1096
			return volumeLabelOf(s.bgmVol) -- 1096
		end -- 1096
		if rowId == "sfxVol" then -- 1097
			return volumeLabelOf(s.sfxVol) -- 1097
		end -- 1097
		if rowId == "voiceVol" then -- 1098
			return volumeLabelOf(s.voiceVol) -- 1098
		end -- 1098
		return "" -- 1099
	end -- 1083
	do -- 1083
		i = 0 -- 1102
		while i < #SETTINGS_ROWS do -- 1102
			local row = SETTINGS_ROWS[i + 1] -- 1103
			local box = boxes[i + 1] -- 1104
			local cy = box.y + box.height * 0.5 -- 1105
			local active = self.settingsSelected == i -- 1106
			if active then -- 1108
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1109
				drawSilkRibbon( -- 1110
					uiDraw, -- 1110
					uiArt, -- 1110
					"set_rib_" .. tostring(i), -- 1110
					panelX + panelW * 0.5, -- 1110
					cy, -- 1110
					panelW + 24, -- 1110
					rowH, -- 1110
					PALETTE.rougeSoft, -- 1110
					0.48 * breathe, -- 1110
					0 -- 1110
				) -- 1110
				drawHairline( -- 1111
					uiInkDraw, -- 1111
					uiArt, -- 1111
					"set_line_" .. tostring(i), -- 1111
					panelX + panelW * 0.5, -- 1111
					box.y + 3, -- 1111
					panelW - 24, -- 1111
					PALETTE.silkLine, -- 1111
					0.42 * breathe, -- 1111
					false, -- 1111
					2 -- 1111
				) -- 1111
				drawBlossomDot( -- 1112
					uiInkDraw, -- 1112
					uiArt, -- 1112
					"set_dot_" .. tostring(i), -- 1112
					panelX + 18, -- 1112
					cy, -- 1112
					14, -- 1112
					PALETTE.rouge, -- 1112
					0.96, -- 1112
					4 -- 1112
				) -- 1112
				fillRadialGlow( -- 1113
					uiGlow, -- 1113
					panelX + 18, -- 1113
					cy, -- 1113
					20, -- 1113
					14, -- 1113
					toColor(PALETTE.rouge, 24 * breathe), -- 1113
					Color(182, 58, 56, 0), -- 1113
					10 -- 1113
				) -- 1113
			else -- 1113
				drawBlossomDot( -- 1115
					uiInkDraw, -- 1115
					uiArt, -- 1115
					"set_dot_" .. tostring(i), -- 1115
					panelX + 18, -- 1115
					cy, -- 1115
					7, -- 1115
					PALETTE.silkDim, -- 1115
					0.42, -- 1115
					3 -- 1115
				) -- 1115
			end -- 1115
			texts:put( -- 1118
				"sm", -- 1119
				row.title, -- 1120
				panelX + 42, -- 1121
				cy, -- 1122
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1123
				0, -- 1124
				0.5, -- 1125
				"Left", -- 1126
				active and 2.4 or 1.6, -- 1127
				active and 1 or 0.88, -- 1128
				0.08 -- 1129
			) -- 1129
			local val = valueTextOf(row.id) -- 1132
			if val ~= "" then -- 1133
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1134
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1135
				texts:put( -- 1136
					"sm", -- 1136
					decorated, -- 1136
					panelX + panelW - 24, -- 1136
					cy, -- 1136
					toColor(valCol), -- 1136
					1, -- 1136
					0.5, -- 1136
					"Right", -- 1136
					1, -- 1136
					active and 1 or 0.86, -- 1136
					0.08 -- 1136
				) -- 1136
			end -- 1136
			i = i + 1 -- 1102
		end -- 1102
	end -- 1102
	local backY = 40 + frame.safe.bottom * 0.45 -- 1140
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1141
	texts:put( -- 1146
		"xs", -- 1146
		hint, -- 1146
		w * 0.5, -- 1146
		backY + 14, -- 1146
		toColor(PALETTE.textDim), -- 1146
		0.5, -- 1146
		0.5, -- 1146
		"Center", -- 1146
		1.2, -- 1146
		0.84, -- 1146
		0.08 -- 1146
	) -- 1146
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1148
	if hit >= 0 then -- 1149
		self.settingsSelected = hit -- 1150
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1151
			return true -- 1152
		end -- 1152
		self:resetInput() -- 1154
		return false -- 1155
	end -- 1155
	if frame.keys.left or frame.prevTab then -- 1157
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1158
		if id ~= "back" then -- 1159
			applyDelta(id, -1) -- 1160
			self:resetInput() -- 1161
		end -- 1161
		return false -- 1163
	end -- 1163
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1165
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1166
		if applyDelta(id, 1) then -- 1167
			return true -- 1168
		end -- 1168
		self:resetInput() -- 1170
		return false -- 1171
	end -- 1171
	return false -- 1173
end -- 984
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi, isMaleRoguelike) -- 1181
	if assistHintsEnabled == nil then -- 1192
		assistHintsEnabled = false -- 1192
	end -- 1192
	if safeUi == nil then -- 1194
		safeUi = ZERO_SAFE_INSETS -- 1194
	end -- 1194
	if isMaleRoguelike == nil then -- 1195
		isMaleRoguelike = false -- 1195
	end -- 1195
	self.time = self.time + dt -- 1197
	local frame = self:readFrame(input, uiScale, safeUi) -- 1198
	if self.pauseShowControls then -- 1200
		local ctrlAct = self:drawControls( -- 1201
			frame, -- 1201
			uiDraw, -- 1201
			uiInkDraw, -- 1201
			uiArt, -- 1201
			uiGlow, -- 1201
			texts, -- 1201
			w, -- 1201
			h, -- 1201
			"返回暂停" -- 1201
		) -- 1201
		if ctrlAct.type == "backTitle" then -- 1202
			self.pauseShowControls = false -- 1203
			self:resetInput() -- 1204
		end -- 1204
		return {type = "none"} -- 1206
	end -- 1206
	if self.pauseShowSettings then -- 1209
		if self:drawPauseSettings( -- 1210
			frame, -- 1210
			input, -- 1210
			uiDraw, -- 1210
			uiInkDraw, -- 1210
			uiArt, -- 1210
			uiGlow, -- 1210
			texts, -- 1210
			w, -- 1210
			h -- 1210
		) then -- 1210
			self.pauseShowSettings = false -- 1211
			self:resetInput() -- 1212
		end -- 1212
		return {type = "none"} -- 1214
	end -- 1214
	if frame.back then -- 1217
		self.pauseShowControls = false -- 1218
		self.pauseShowSettings = false -- 1219
		self:emitSound("pauseClose") -- 1220
		return {type = "resume"} -- 1221
	end -- 1221
	local allowFs = canToggleFullscreen() -- 1224
	local allowQuit = canQuitApp() -- 1225
	local pauseItems = __TS__ArrayFilter( -- 1226
		PAUSE_ITEMS, -- 1226
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1226
	) -- 1226
	if self.pauseSelected >= #pauseItems then -- 1229
		self.pauseSelected = 0 -- 1230
	end -- 1230
	uiDraw:drawRect( -- 1233
		Rect(0, 0, w, h), -- 1233
		Color(8, 10, 16, 102) -- 1233
	) -- 1233
	fillHGradRect( -- 1234
		uiDraw, -- 1234
		0, -- 1234
		0, -- 1234
		w * 0.27 + frame.safe.left, -- 1234
		h, -- 1234
		Color(9, 11, 18, 232), -- 1234
		Color(10, 13, 21, 198) -- 1234
	) -- 1234
	fillHGradRect( -- 1235
		uiDraw, -- 1235
		w * 0.27 + frame.safe.left, -- 1235
		0, -- 1235
		w * 0.21, -- 1235
		h, -- 1235
		Color(10, 13, 21, 198), -- 1235
		Color(10, 13, 21, 0) -- 1235
	) -- 1235
	local menuX = 110 + frame.safe.left * 0.6 -- 1237
	local compact = #pauseItems > 8 -- 1238
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1239
	uiArt:tryPlace( -- 1240
		"ink_vstream", -- 1240
		"pause_vstream", -- 1240
		menuX - 32, -- 1240
		h * 0.5, -- 1240
		34, -- 1240
		h * 0.78, -- 1240
		{ -- 1240
			color = toColor(PALETTE.silkDim), -- 1241
			opacity = 0.48, -- 1241
			layer = 1 -- 1241
		} -- 1241
	) -- 1241
	drawMistCurve( -- 1243
		uiArt, -- 1243
		"pause_mist", -- 1243
		menuX + 118, -- 1243
		headY - 8, -- 1243
		290, -- 1243
		72, -- 1243
		PALETTE.jadeMist, -- 1243
		0.2, -- 1243
		-1 -- 1243
	) -- 1243
	texts:put( -- 1245
		"banner", -- 1245
		"暂歇", -- 1245
		menuX + 16, -- 1245
		headY, -- 1245
		toColor(PALETTE.textBright), -- 1245
		0, -- 1245
		0.5, -- 1245
		"Left", -- 1245
		10, -- 1245
		0.98, -- 1245
		0.1 -- 1245
	) -- 1245
	texts:put( -- 1246
		"xs", -- 1246
		"月夜暂驻 · 卷页留痕", -- 1246
		menuX + 18, -- 1246
		headY - 36, -- 1246
		toColor(PALETTE.textDim), -- 1246
		0, -- 1246
		0.5, -- 1246
		"Left", -- 1246
		2, -- 1246
		0.8, -- 1246
		0.08 -- 1246
	) -- 1246
	drawHairline( -- 1247
		uiInkDraw, -- 1247
		uiArt, -- 1247
		"pause_div", -- 1247
		menuX + 124, -- 1247
		headY - 60, -- 1247
		240, -- 1247
		PALETTE.silkDim, -- 1247
		0.58, -- 1247
		true, -- 1247
		2 -- 1247
	) -- 1247
	local rowStep = compact and 42 or 46 -- 1249
	local rowH = compact and 36 or 38 -- 1250
	local firstY = compact and headY - 112 or headY - 120 -- 1251
	local boxes = {} -- 1252
	local i = 0 -- 1253
	do -- 1253
		i = 0 -- 1254
		while i < #pauseItems do -- 1254
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1255
			i = i + 1 -- 1254
		end -- 1254
	end -- 1254
	local prevPauseSel = self.pauseSelected -- 1257
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1258
	if self.pauseSelected ~= prevPauseSel then -- 1259
		self:emitSound("hover") -- 1260
	end -- 1260
	do -- 1260
		i = 0 -- 1263
		while i < #pauseItems do -- 1263
			local iy = boxes[i + 1].y -- 1264
			local active = self.pauseSelected == i -- 1265
			local cy = iy + rowH * 0.5 -- 1266
			local shiftX = active and 10 or 0 -- 1267
			local item = pauseItems[i + 1] -- 1268
			local label = item.zh -- 1269
			if item.id == "retry" and isMaleRoguelike then -- 1270
				label = "重开本轮护送" -- 1271
			elseif item.id == "assist" then -- 1272
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1273
			elseif item.id == "fullscreen" then -- 1274
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1275
			elseif item.id == "settings" then -- 1276
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1277
			end -- 1277
			if active then -- 1280
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1281
				drawSilkRibbon( -- 1282
					uiDraw, -- 1282
					uiArt, -- 1282
					"pause_rib_" .. tostring(i), -- 1282
					menuX + 116, -- 1282
					cy, -- 1282
					282, -- 1282
					rowH, -- 1282
					PALETTE.rougeSoft, -- 1282
					0.54 * breathe, -- 1282
					0 -- 1282
				) -- 1282
				drawHairline( -- 1283
					uiInkDraw, -- 1283
					uiArt, -- 1283
					"pause_line_" .. tostring(i), -- 1283
					menuX + 106, -- 1283
					iy + 3, -- 1283
					210, -- 1283
					PALETTE.silkLine, -- 1283
					0.42 * breathe, -- 1283
					false, -- 1283
					2 -- 1283
				) -- 1283
				drawBlossomDot( -- 1284
					uiInkDraw, -- 1284
					uiArt, -- 1284
					"pause_dot_" .. tostring(i), -- 1284
					menuX + 12, -- 1284
					cy, -- 1284
					15, -- 1284
					PALETTE.rouge, -- 1284
					0.96, -- 1284
					4 -- 1284
				) -- 1284
				fillRadialGlow( -- 1285
					uiGlow, -- 1285
					menuX + 12, -- 1285
					cy, -- 1285
					22, -- 1285
					16, -- 1285
					toColor(PALETTE.rouge, 26 * breathe), -- 1285
					Color(182, 58, 56, 0), -- 1285
					10 -- 1285
				) -- 1285
			else -- 1285
				drawBlossomDot( -- 1287
					uiInkDraw, -- 1287
					uiArt, -- 1287
					"pause_dot_" .. tostring(i), -- 1287
					menuX + 12, -- 1287
					cy, -- 1287
					8, -- 1287
					PALETTE.silkDim, -- 1287
					0.4, -- 1287
					3 -- 1287
				) -- 1287
			end -- 1287
			texts:put( -- 1290
				compact and "sm" or "md", -- 1291
				label, -- 1292
				menuX + 32 + shiftX, -- 1293
				cy, -- 1294
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1295
				0, -- 1296
				0.5, -- 1297
				"Left", -- 1298
				active and 3.4 or 2.2, -- 1299
				active and 1 or 0.88, -- 1300
				0.1 -- 1301
			) -- 1301
			i = i + 1 -- 1263
		end -- 1263
	end -- 1263
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1305
	texts:put( -- 1310
		"xs", -- 1310
		pauseFooter, -- 1310
		menuX + 12, -- 1310
		38 + frame.safe.bottom * 0.4, -- 1310
		toColor(PALETTE.textDim), -- 1310
		0, -- 1310
		0.5, -- 1310
		"Left", -- 1310
		1.2, -- 1310
		0.86, -- 1310
		0.08 -- 1310
	) -- 1310
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1312
	if hit >= 0 or frame.keys.confirm then -- 1313
		local idx = hit >= 0 and hit or self.pauseSelected -- 1314
		local id = pauseItems[idx + 1].id -- 1315
		if id == "controls" then -- 1316
			self.pauseShowControls = true -- 1317
			self:emitSound("confirm") -- 1318
			self:resetInput() -- 1319
			return {type = "none"} -- 1320
		end -- 1320
		if id == "settings" then -- 1322
			self:openPauseSettings() -- 1323
			self:emitSound("confirm") -- 1324
			return {type = "none"} -- 1325
		end -- 1325
		if id == "assist" then -- 1327
			if onToggleAssist ~= nil then -- 1328
				onToggleAssist() -- 1329
			end -- 1329
			self:emitSound("toggle") -- 1331
			self:resetInput() -- 1332
			return {type = "none"} -- 1333
		end -- 1333
		if id == "fullscreen" then -- 1335
			self:emitSound("toggle") -- 1336
			self:resetInput() -- 1337
			return {type = "toggleFullscreen"} -- 1338
		end -- 1338
		self.pauseShowControls = false -- 1340
		self.pauseShowSettings = false -- 1341
		if id == "resume" then -- 1342
			self:emitSound("pauseClose") -- 1342
			return {type = "resume"} -- 1342
		end -- 1342
		if id == "retry" then -- 1343
			self:emitSound("confirm") -- 1343
			return {type = "retry"} -- 1343
		end -- 1343
		if id == "chapters" then -- 1344
			self:emitSound("confirm") -- 1344
			return {type = "openChapters"} -- 1344
		end -- 1344
		if id == "quit" then -- 1345
			self:emitSound("back") -- 1345
			return {type = "quit"} -- 1345
		end -- 1345
		self:emitSound("back") -- 1346
		return {type = "toTitle"} -- 1347
	end -- 1347
	return {type = "none"} -- 1349
end -- 1181
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1356
	if frame.back then -- 1366
		return {type = "backTitle"} -- 1367
	end -- 1367
	uiDraw:drawRect( -- 1371
		Rect(0, 0, w, h), -- 1371
		Color(7, 9, 15, 214) -- 1371
	) -- 1371
	local cx = w * 0.5 -- 1372
	local reunion = self.epilogueEnding == "reunion" -- 1373
	local accentCol = reunion and PALETTE.amber or PALETTE.cyan -- 1374
	drawMistCurve( -- 1375
		uiArt, -- 1375
		"ep_mist", -- 1375
		cx, -- 1375
		h * 0.62, -- 1375
		620, -- 1375
		120, -- 1375
		accentCol, -- 1375
		0.2, -- 1375
		0 -- 1375
	) -- 1375
	fillRadialGlow( -- 1376
		uiGlow, -- 1376
		cx, -- 1376
		h * 0.68, -- 1376
		220, -- 1376
		140, -- 1376
		toColor(accentCol, 28), -- 1376
		Color(10, 14, 22, 0), -- 1376
		18 -- 1376
	) -- 1376
	local titleY = h * 0.72 -- 1379
	texts:put( -- 1380
		"title", -- 1380
		"向西守望", -- 1380
		cx - 18, -- 1380
		titleY, -- 1380
		toColor(PALETTE.textBright), -- 1380
		0.5, -- 1380
		0.5, -- 1380
		"Center", -- 1380
		12, -- 1380
		0.98, -- 1380
		0.12 -- 1380
	) -- 1380
	drawLoneSeal( -- 1381
		uiInkDraw, -- 1381
		uiArt, -- 1381
		texts, -- 1381
		"ep_seal", -- 1381
		cx + 148, -- 1381
		titleY - 2, -- 1381
		24, -- 1381
		46, -- 1381
		"守", -- 1381
		"望", -- 1381
		PALETTE.sealRed, -- 1381
		PALETTE.sealText, -- 1381
		0.94, -- 1381
		4 -- 1381
	) -- 1381
	drawHairline( -- 1382
		uiInkDraw, -- 1382
		uiArt, -- 1382
		"ep_div", -- 1382
		cx, -- 1382
		titleY - 46, -- 1382
		360, -- 1382
		PALETTE.silkDim, -- 1382
		0.62, -- 1382
		true, -- 1382
		2 -- 1382
	) -- 1382
	local endingTitle = reunion and "终章 · 兄妹团圆" or "终章 · 西窗留灯" -- 1384
	local verse = reunion and "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。" or "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。" -- 1385
	texts:put( -- 1388
		"md", -- 1388
		endingTitle, -- 1388
		cx, -- 1388
		titleY - 76, -- 1388
		toColor(PALETTE.amberCore), -- 1388
		0.5, -- 1388
		0.5, -- 1388
		"Center", -- 1388
		3.2, -- 1388
		0.96, -- 1388
		0.08 -- 1388
	) -- 1388
	texts:put( -- 1389
		"sm", -- 1389
		verse, -- 1389
		cx, -- 1389
		titleY - 114, -- 1389
		toColor(PALETTE.textMid), -- 1389
		0.5, -- 1389
		0.5, -- 1389
		"Center", -- 1389
		1, -- 1389
		0.92, -- 1389
		0.08 -- 1389
	) -- 1389
	if self.epilogueBothCleared then -- 1391
		drawSilkVeil( -- 1392
			uiDraw, -- 1392
			uiArt, -- 1392
			"ep_well_veil", -- 1392
			cx, -- 1392
			titleY - 152, -- 1392
			560, -- 1392
			30, -- 1392
			PALETTE.inkWarm, -- 1392
			0.68, -- 1392
			0 -- 1392
		) -- 1392
		texts:put( -- 1393
			"xs", -- 1393
			"双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", -- 1393
			cx, -- 1393
			titleY - 152, -- 1393
			toColor(PALETTE.cyanCore), -- 1393
			0.5, -- 1393
			0.5, -- 1393
			"Center", -- 1393
			1, -- 1393
			0.9, -- 1393
			0.08 -- 1393
		) -- 1393
	end -- 1393
	local items = {{id = "history", zh = "了解历史 · 片尾史话"}, {id = "replay", zh = "再走一遍"}, {id = "title", zh = "返回标题"}} -- 1396
	local btnW = 286 -- 1401
	local btnH = 44 -- 1402
	local gap = 14 -- 1403
	local baseY = math.max(150, h * 0.34) -- 1404
	local boxes = {} -- 1405
	local i = 0 -- 1406
	do -- 1406
		i = 0 -- 1407
		while i < #items do -- 1407
			boxes[#boxes + 1] = Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH) -- 1408
			i = i + 1 -- 1407
		end -- 1407
	end -- 1407
	self.epilogueSelected = self:verticalSelection(self.epilogueSelected, boxes, frame) -- 1410
	do -- 1410
		i = 0 -- 1412
		while i < #items do -- 1412
			local box = boxes[i + 1] -- 1413
			local active = self.epilogueSelected == i -- 1414
			local cy = box.y + box.height * 0.5 -- 1415
			if active then -- 1416
				local breathe = 0.86 + 0.14 * math.sin(self.time * 2.4) -- 1417
				drawSilkRibbon( -- 1418
					uiDraw, -- 1418
					uiArt, -- 1418
					"ep_rib_" .. tostring(i), -- 1418
					cx, -- 1418
					cy, -- 1418
					btnW + 24, -- 1418
					btnH, -- 1418
					PALETTE.rougeSoft, -- 1418
					0.62 * breathe, -- 1418
					0 -- 1418
				) -- 1418
				drawHairline( -- 1419
					uiInkDraw, -- 1419
					uiArt, -- 1419
					"ep_line_" .. tostring(i), -- 1419
					cx, -- 1419
					box.y + 3, -- 1419
					btnW - 44, -- 1419
					PALETTE.silkLine, -- 1419
					0.48 * breathe, -- 1419
					false, -- 1419
					2 -- 1419
				) -- 1419
				drawBlossomDot( -- 1420
					uiInkDraw, -- 1420
					uiArt, -- 1420
					"ep_dot_" .. tostring(i), -- 1420
					box.x + 22, -- 1420
					cy, -- 1420
					13, -- 1420
					PALETTE.rouge, -- 1420
					0.96, -- 1420
					4 -- 1420
				) -- 1420
			else -- 1420
				drawSilkVeil( -- 1422
					uiDraw, -- 1422
					uiArt, -- 1422
					"ep_idle_" .. tostring(i), -- 1422
					cx, -- 1422
					cy, -- 1422
					btnW, -- 1422
					btnH - 2, -- 1422
					PALETTE.inkWash, -- 1422
					0.58, -- 1422
					0 -- 1422
				) -- 1422
				drawBlossomDot( -- 1423
					uiInkDraw, -- 1423
					uiArt, -- 1423
					"ep_dot_" .. tostring(i), -- 1423
					box.x + 22, -- 1423
					cy, -- 1423
					8, -- 1423
					PALETTE.silkDim, -- 1423
					0.42, -- 1423
					3 -- 1423
				) -- 1423
			end -- 1423
			texts:put( -- 1425
				"sm", -- 1426
				items[i + 1].zh, -- 1427
				cx + 6, -- 1428
				cy, -- 1429
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1430
				0.5, -- 1431
				0.5, -- 1432
				"Center", -- 1433
				active and 2.6 or 1.6, -- 1434
				active and 1 or 0.88, -- 1435
				0.08 -- 1436
			) -- 1436
			i = i + 1 -- 1412
		end -- 1412
	end -- 1412
	local footer = frame.mode == "gamepad" and ((keyTagFor("confirm", "gamepad", frame.layout) .. " 确认   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回标题" or (frame.mode == "touch" and "轻触任一入口继续" or "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题") -- 1440
	texts:put( -- 1443
		"xs", -- 1443
		footer, -- 1443
		cx, -- 1443
		38 + frame.safe.bottom * 0.4, -- 1443
		toColor(PALETTE.textDim), -- 1443
		0.5, -- 1443
		0.5, -- 1443
		"Center", -- 1443
		1.2, -- 1443
		0.84, -- 1443
		0.08 -- 1443
	) -- 1443
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1445
	if hit >= 0 or frame.keys.confirm then -- 1446
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1447
		local id = items[idx + 1].id -- 1448
		if id == "history" then -- 1449
			return {type = "openHistory"} -- 1449
		end -- 1449
		if id == "replay" then -- 1450
			return {type = "replayStory"} -- 1450
		end -- 1450
		return {type = "backTitle"} -- 1451
	end -- 1451
	return {type = "none"} -- 1453
end -- 1356
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1460
	if frame.back then -- 1470
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1471
	end -- 1471
	local total = #HISTORY_CARDS -- 1474
	if frame.keys.left or frame.prevTab then -- 1475
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1476
	elseif frame.keys.right or frame.nextTab then -- 1477
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1478
	end -- 1478
	local card = HISTORY_CARDS[self.historyCardIndex + 1] -- 1480
	uiDraw:drawRect( -- 1482
		Rect(0, 0, w, h), -- 1482
		Color(7, 9, 15, 206) -- 1482
	) -- 1482
	local cx = w * 0.5 -- 1483
	local pageW = math.min(w - 110 - frame.safe.left - frame.safe.right, 860) -- 1484
	local pageH = math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500) -- 1485
	local px = cx - pageW * 0.5 -- 1486
	local py = (h - pageH) * 0.5 + 14 -- 1487
	local midY = py + pageH * 0.5 -- 1488
	uiArt:tryPlace( -- 1490
		"ink_frame_mask", -- 1490
		"hist_shadow", -- 1490
		cx, -- 1490
		midY - 6, -- 1490
		pageW + 52, -- 1490
		pageH + 46, -- 1490
		{ -- 1490
			color = toColor(PALETTE.voidDark), -- 1491
			opacity = 0.84, -- 1491
			layer = -1 -- 1491
		} -- 1491
	) -- 1491
	if not uiArt:tryPlace( -- 1493
		"ink_song_paper", -- 1493
		"hist_paper", -- 1493
		cx, -- 1493
		midY, -- 1493
		pageW, -- 1493
		pageH, -- 1493
		{opacity = 0.98, layer = 1} -- 1493
	) then -- 1493
		uiDraw:drawRect( -- 1494
			Rect(px, py, pageW, pageH), -- 1494
			toColor(PALETTE.xuanPaper, 248), -- 1494
			1, -- 1494
			toColor(PALETTE.silkDim, 180) -- 1494
		) -- 1494
	end -- 1494
	fillRadialGlow( -- 1496
		uiGlow, -- 1496
		cx, -- 1496
		midY + 40, -- 1496
		260, -- 1496
		140, -- 1496
		Color(236, 224, 202, 16), -- 1496
		Color(236, 224, 202, 0), -- 1496
		14 -- 1496
	) -- 1496
	local inX = px + 42 -- 1499
	local inY = py + 32 -- 1500
	local inW = pageW - 84 -- 1501
	local inH = pageH - 64 -- 1502
	local redSilk = toColor(PALETTE.rouge, 118) -- 1503
	local redSilkFaint = toColor(PALETTE.rouge, 58) -- 1504
	uiInkDraw:drawRect( -- 1505
		Rect(inX, inY, inW, inH), -- 1505
		Color(0, 0, 0, 0), -- 1505
		0.95, -- 1505
		redSilk -- 1505
	) -- 1505
	uiInkDraw:drawRect( -- 1506
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1506
		Color(0, 0, 0, 0), -- 1506
		0.55, -- 1506
		redSilkFaint -- 1506
	) -- 1506
	local headY = inY + inH - 30 -- 1509
	texts:put( -- 1510
		"md", -- 1510
		(("片尾史话  ·  " .. card.indexZh) .. " · ") .. card.title, -- 1510
		inX + 20, -- 1510
		headY, -- 1510
		toColor(PALETTE.xuanInk), -- 1510
		0, -- 1510
		0.5, -- 1510
		"Left", -- 1510
		2, -- 1510
		0.96, -- 1510
		0 -- 1510
	) -- 1510
	texts:put( -- 1511
		"xs", -- 1511
		(tostring(self.historyCardIndex + 1) .. " / ") .. tostring(total), -- 1511
		inX + inW - 20, -- 1511
		headY, -- 1511
		toColor(PALETTE.rouge), -- 1511
		1, -- 1511
		0.5, -- 1511
		"Right", -- 1511
		1.8, -- 1511
		0.88, -- 1511
		0 -- 1511
	) -- 1511
	uiInkDraw:drawSegment( -- 1512
		Vec2(inX + 14, headY - 22), -- 1512
		Vec2(inX + inW - 14, headY - 22), -- 1512
		0.85, -- 1512
		redSilk -- 1512
	) -- 1512
	texts:put( -- 1515
		"xs", -- 1515
		card.subtitle, -- 1515
		inX + 20, -- 1515
		headY - 42, -- 1515
		toColor(PALETTE.xuanInkSub), -- 1515
		0, -- 1515
		0.5, -- 1515
		"Left", -- 1515
		1.4, -- 1515
		0.86, -- 1515
		0 -- 1515
	) -- 1515
	local function wrapZh(src, maxUnits) -- 1518
		local out = {} -- 1519
		local buf = "" -- 1520
		local units = 0 -- 1521
		local ci = 0 -- 1522
		while ci < #src do -- 1523
			local b = __TS__StringCharCodeAt(src, ci) -- 1524
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1525
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1526
			local u = b < 128 and 0.56 or 1.02 -- 1527
			if units + u > maxUnits and buf ~= "" then -- 1528
				out[#out + 1] = buf -- 1529
				buf = ch -- 1530
				units = u -- 1531
			else -- 1531
				buf = buf .. ch -- 1533
				units = units + u -- 1534
			end -- 1534
			ci = ci + step -- 1536
		end -- 1536
		if buf ~= "" then -- 1538
			out[#out + 1] = buf -- 1539
		end -- 1539
		return out -- 1541
	end -- 1518
	local charsPerLine = math.max( -- 1544
		24, -- 1544
		math.floor((inW - 44) / 20) -- 1544
	) -- 1544
	local cursorY = headY - 76 -- 1545
	local pi = 0 -- 1546
	do -- 1546
		pi = 0 -- 1547
		while pi < #card.paragraphs do -- 1547
			local lines = wrapZh("　　" .. card.paragraphs[pi + 1], charsPerLine) -- 1548
			local li = 0 -- 1549
			do -- 1549
				li = 0 -- 1550
				while li < #lines do -- 1550
					texts:put( -- 1551
						"sm", -- 1551
						lines[li + 1], -- 1551
						inX + 22, -- 1551
						cursorY, -- 1551
						toColor(PALETTE.xuanInk), -- 1551
						0, -- 1551
						0.5, -- 1551
						"Left", -- 1551
						0.6, -- 1551
						0.94, -- 1551
						0 -- 1551
					) -- 1551
					cursorY = cursorY - 30 -- 1552
					li = li + 1 -- 1550
				end -- 1550
			end -- 1550
			cursorY = cursorY - 12 -- 1554
			pi = pi + 1 -- 1547
		end -- 1547
	end -- 1547
	local footY = inY + 26 -- 1558
	uiInkDraw:drawSegment( -- 1559
		Vec2(inX + 14, footY + 20), -- 1559
		Vec2(inX + inW - 14, footY + 20), -- 1559
		0.6, -- 1559
		redSilkFaint -- 1559
	) -- 1559
	texts:put( -- 1560
		"xs", -- 1560
		card.footnote, -- 1560
		inX + 20, -- 1560
		footY, -- 1560
		toColor(PALETTE.xuanInkSub), -- 1560
		0, -- 1560
		0.5, -- 1560
		"Left", -- 1560
		0.4, -- 1560
		0.84, -- 1560
		0 -- 1560
	) -- 1560
	local navY = math.max(30, py - 48) -- 1563
	local prevBox = Rect(cx - 290, navY, 132, 34) -- 1564
	local nextBox = Rect(cx + 158, navY, 132, 34) -- 1565
	local backBox = Rect(cx - 88, navY, 176, 34) -- 1566
	local function drawNavBtn(box, tag, label) -- 1568
		local hover = frame.inside and box:containsPoint(frame.pointer) -- 1569
		drawSilkVeil( -- 1570
			uiDraw, -- 1570
			uiArt, -- 1570
			"hist_btn_" .. tag, -- 1570
			box.x + box.width * 0.5, -- 1570
			box.y + box.height * 0.5, -- 1570
			box.width, -- 1570
			box.height, -- 1570
			hover and PALETTE.rougeSoft or PALETTE.inkWash, -- 1570
			hover and 0.86 or 0.72, -- 1570
			2 -- 1570
		) -- 1570
		texts:put( -- 1571
			"xs", -- 1571
			label, -- 1571
			box.x + box.width * 0.5, -- 1571
			box.y + box.height * 0.5, -- 1571
			toColor(hover and PALETTE.textBright or PALETTE.textMid), -- 1571
			0.5, -- 1571
			0.5, -- 1571
			"Center", -- 1571
			1.4, -- 1571
			0.94, -- 1571
			0.08 -- 1571
		) -- 1571
		return hover and frame.click -- 1572
	end -- 1568
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1575
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1576
	end -- 1576
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1578
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1579
	end -- 1579
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1581
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1582
	end -- 1582
	if frame.keys.confirm then -- 1585
		if self.historyCardIndex + 1 < total then -- 1586
			self.historyCardIndex = self.historyCardIndex + 1 -- 1587
		else -- 1587
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1589
		end -- 1589
	end -- 1589
	return {type = "none"} -- 1592
end -- 1460
return ____exports -- 1460
