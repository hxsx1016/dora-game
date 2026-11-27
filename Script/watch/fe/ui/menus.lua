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
	{id = "settings", zh = "操控设置"} -- 108
} -- 108
local SETTINGS_ROWS = { -- 112
	{id = "modePref", title = "操作模式"}, -- 113
	{id = "aimAssist", title = "瞄准磁吸"}, -- 114
	{id = "gpLayout", title = "手柄确认键"}, -- 115
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 116
	{id = "touchOpacity", title = "触控按键透度"}, -- 117
	{id = "touchScale", title = "触控按键大小"}, -- 118
	{id = "haptics", title = "触觉震动反馈"}, -- 119
	{id = "masterVol", title = "主音量"}, -- 120
	{id = "bgmVol", title = "音乐音量"}, -- 121
	{id = "sfxVol", title = "音效与环境"}, -- 122
	{id = "voiceVol", title = "人声音量"}, -- 123
	{id = "back", title = "返回暂歇菜单"} -- 124
} -- 124
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 127
local EPIGRAPH_RIGHT = { -- 128
	"城", -- 128
	"破", -- 128
	"那", -- 128
	"天", -- 128
	"", -- 128
	"他", -- 128
	"留", -- 128
	"下", -- 128
	"断", -- 128
	"后" -- 128
} -- 128
local EPIGRAPH_LEFT = { -- 129
	"她", -- 129
	"独", -- 129
	"自", -- 129
	"走", -- 129
	"向", -- 129
	"北", -- 129
	"塔" -- 129
} -- 129
local function pressedKeys() -- 154
	return { -- 155
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 156
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 157
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 158
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 159
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 160
	} -- 160
end -- 154
local function hitIndex(boxes, pointer, inside) -- 164
	if not inside then -- 164
		return -1 -- 166
	end -- 166
	return __TS__ArrayFindIndex( -- 168
		boxes, -- 168
		function(____, box) return box:containsPoint(pointer) end -- 168
	) -- 168
end -- 164
____exports.MenuRenderer = __TS__Class() -- 171
local MenuRenderer = ____exports.MenuRenderer -- 171
MenuRenderer.name = "MenuRenderer" -- 171
function MenuRenderer.prototype.____constructor(self) -- 171
	self.selected = 0 -- 172
	self.chapterSelected = 0 -- 173
	self.pauseSelected = 0 -- 174
	self.settingsSelected = 0 -- 175
	self.epilogueSelected = 0 -- 176
	self.epilogueEnding = "lamp" -- 177
	self.epilogueBothCleared = false -- 178
	self.historyCardIndex = 0 -- 179
	self.historyFromEpilogue = false -- 180
	self.hasSession = false -- 182
	self.controlsTab = "kbm" -- 184
	self.chaptersFromPause = false -- 196
	self.pauseShowControls = false -- 197
	self.pauseShowSettings = false -- 198
	self.controlsTabManual = false -- 199
	self.previousKeys = {} -- 200
	self.queuedKeys = {} -- 201
	self.queuedBack = false -- 202
	self.queuedSkip = false -- 203
	self.splashTime = 0 -- 204
	self.time = 0 -- 205
end -- 171
function MenuRenderer.prototype.emitSound(self, kind) -- 190
	if self.onUiSound ~= nil then -- 190
		self:onUiSound(kind) -- 192
	end -- 192
end -- 190
function MenuRenderer.prototype.resetSplash(self) -- 207
	self.splashTime = 0 -- 208
	self.queuedSkip = false -- 209
	self:resetInput() -- 210
end -- 207
function MenuRenderer.prototype.isShowingPauseControls(self) -- 213
	return self.pauseShowControls -- 214
end -- 213
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 217
	return self.pauseShowSettings -- 218
end -- 217
function MenuRenderer.prototype.openPauseSettings(self) -- 221
	self.pauseShowControls = false -- 222
	self.pauseShowSettings = true -- 223
	self.settingsSelected = 0 -- 224
	self:resetInput() -- 225
end -- 221
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 228
	self.chaptersFromPause = roomIndex ~= nil -- 229
	self.chapterSelected = math.max( -- 230
		0, -- 230
		__TS__ArrayFindIndex( -- 230
			CHAPTERS, -- 230
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 230
		) -- 230
	) -- 230
	self.pauseShowControls = false -- 231
	self.pauseShowSettings = false -- 232
	self:resetInput() -- 233
end -- 228
function MenuRenderer.prototype.openPause(self) -- 236
	self.pauseSelected = 0 -- 237
	self.pauseShowControls = false -- 238
	self.pauseShowSettings = false -- 239
	self:resetInput() -- 240
end -- 236
function MenuRenderer.prototype.openEpilogue(self, ending, bothCleared) -- 243
	if ending == nil then -- 243
		ending = "lamp" -- 243
	end -- 243
	if bothCleared == nil then -- 243
		bothCleared = false -- 243
	end -- 243
	self.epilogueEnding = ending -- 244
	self.epilogueBothCleared = bothCleared -- 245
	self.epilogueSelected = 0 -- 246
	self:resetInput() -- 247
end -- 243
function MenuRenderer.prototype.openHistory(self, fromEpilogue) -- 250
	if fromEpilogue == nil then -- 250
		fromEpilogue = true -- 250
	end -- 250
	self.historyFromEpilogue = fromEpilogue -- 251
	self.historyCardIndex = 0 -- 252
	self:resetInput() -- 253
end -- 250
function MenuRenderer.prototype.triggerBack(self) -- 257
	self.queuedBack = true -- 258
end -- 257
function MenuRenderer.prototype.resetInput(self) -- 262
	self.previousKeys = pressedKeys() -- 263
	self.queuedKeys = {} -- 264
	self.queuedBack = false -- 265
	self.queuedSkip = false -- 266
	self.controlsTabManual = false -- 267
end -- 262
function MenuRenderer.prototype.onKeyEvent(self, key) -- 271
	self.queuedSkip = true -- 272
	if key == "Up" or key == "W" then -- 272
		self.queuedKeys.up = true -- 274
	elseif key == "Down" or key == "S" then -- 274
		self.queuedKeys.down = true -- 276
	elseif key == "Left" or key == "A" then -- 276
		self.queuedKeys.left = true -- 278
	elseif key == "Right" or key == "D" then -- 278
		self.queuedKeys.right = true -- 280
	elseif key == "Return" or key == "Space" then -- 280
		self.queuedKeys.confirm = true -- 282
	elseif key == "Escape" then -- 282
		self.queuedBack = true -- 284
	end -- 284
end -- 271
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 288
	local held = pressedKeys() -- 289
	local prev = self.previousKeys -- 290
	local queued = self.queuedKeys -- 291
	local useUiPtr = input.uiInside or input.uiPressed -- 294
	local rawX = useUiPtr and input.uiX or input.mx -- 295
	local rawY = useUiPtr and input.uiY or input.my -- 296
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 297
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 298
	local ____useUiPtr_0 -- 299
	if useUiPtr then -- 299
		____useUiPtr_0 = input.uiInside -- 299
	else -- 299
		____useUiPtr_0 = input.inside -- 299
	end -- 299
	local inside = ____useUiPtr_0 -- 299
	local ____useUiPtr_1 -- 300
	if useUiPtr then -- 300
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 300
	else -- 300
		____useUiPtr_1 = input.inside and input.fire.pressed -- 300
	end -- 300
	local click = ____useUiPtr_1 -- 300
	local touchMode = input:isTouchMode() -- 301
	local frame = { -- 303
		keys = { -- 304
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 305
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 306
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 307
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 308
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 309
		}, -- 309
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 311
		prevTab = input.navPrevTab, -- 312
		nextTab = input.navNextTab, -- 313
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 314
		pointer = Vec2(rawX / scale, rawY / scale), -- 315
		inside = inside, -- 316
		click = click, -- 317
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 318
		mode = input.inputMode, -- 319
		layout = input.gamepadLayout, -- 320
		safe = safe -- 321
	} -- 321
	self.previousKeys = held -- 323
	self.queuedKeys = {} -- 324
	self.queuedBack = false -- 325
	self.queuedSkip = false -- 326
	return frame -- 327
end -- 288
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 330
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 331
	if frame.click and hit >= 0 then -- 331
		return hit -- 333
	end -- 333
	if frame.keys.up then -- 333
		return (selected + #boxes - 1) % #boxes -- 336
	end -- 336
	if frame.keys.down then -- 336
		return (selected + 1) % #boxes -- 339
	end -- 339
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 341
end -- 330
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 344
	if safeUi == nil then -- 344
		safeUi = ZERO_SAFE_INSETS -- 360
	end -- 360
	self.time = self.time + dt -- 362
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 363
	if screen ~= "splash" or splashDissolving then -- 363
		local artW = math.max(w, h * 16 / 9) -- 365
		local artH = artW * 9 / 16 -- 366
		if not backdropArt:tryPlace( -- 366
			"title_backdrop", -- 367
			"menu_landscape", -- 367
			w * 0.5, -- 367
			(h - artH) * 0.5, -- 367
			artW, -- 367
			artH -- 367
		) then -- 367
			stage:drawMenuBackdrop( -- 368
				bgDraw, -- 368
				bgGlow, -- 368
				w, -- 368
				h, -- 368
				self.time -- 368
			) -- 368
		end -- 368
	end -- 368
	local frame = self:readFrame(input, uiScale, safeUi) -- 372
	w = w / uiScale -- 373
	h = h / uiScale -- 374
	if screen == "splash" then -- 374
		return self:drawSplash( -- 377
			dt, -- 377
			frame, -- 377
			uiDraw, -- 377
			uiArt, -- 377
			texts, -- 377
			w, -- 377
			h -- 377
		) -- 377
	end -- 377
	if screen == "title" then -- 377
		return self:drawTitle( -- 380
			frame, -- 380
			uiDraw, -- 380
			uiInkDraw, -- 380
			uiArt, -- 380
			uiGlow, -- 380
			texts, -- 380
			w, -- 380
			h -- 380
		) -- 380
	end -- 380
	if screen == "chapters" then -- 380
		return self:drawChapters( -- 383
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
	if screen == "epilogue" then -- 383
		return self:drawEpilogue( -- 386
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
	if screen == "history" then -- 386
		return self:drawHistory( -- 389
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
	return self:drawControls( -- 391
		frame, -- 391
		uiDraw, -- 391
		uiInkDraw, -- 391
		uiArt, -- 391
		uiGlow, -- 391
		texts, -- 391
		w, -- 391
		h -- 391
	) -- 391
end -- 344
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 400
	local safeDt = math.min( -- 409
		0.1, -- 409
		math.max(0, dt) -- 409
	) -- 409
	self.splashTime = self.splashTime + safeDt -- 410
	local t = self.splashTime -- 411
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 413
	if wantSkip or t >= 4.65 then -- 413
		self.splashTime = 0 -- 415
		return {type = "splashDone"} -- 416
	end -- 416
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 419
	local bgR = t < 2.2 and 13 or 11 -- 420
	local bgG = t < 2.2 and 16 or 13 -- 421
	local bgB = t < 2.2 and 24 or 19 -- 422
	uiDraw:drawRect( -- 423
		Rect(0, 0, w, h), -- 423
		Color( -- 423
			bgR, -- 423
			bgG, -- 423
			bgB, -- 423
			math.floor(255 * fadeOutCurtain + 0.5) -- 423
		) -- 423
	) -- 423
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 425
		if localT <= 0 or localT >= endT then -- 425
			return 0 -- 426
		end -- 426
		if localT < fadeIn then -- 426
			local u = localT / fadeIn -- 428
			return u * u * (3 - 2 * u) -- 429
		end -- 429
		if localT <= holdEnd then -- 429
			return 1 -- 431
		end -- 431
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 432
		return 1 - u * u * (3 - 2 * u) -- 433
	end -- 425
	if t < 2.2 then -- 425
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 437
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 438
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 439
		if not uiArt:tryPlace( -- 439
			"brand_team_logo", -- 440
			"splash_team_logo", -- 440
			w * 0.5, -- 440
			h * 0.54, -- 440
			logoH * 2, -- 440
			logoH, -- 440
			{opacity = alpha, layer = 2} -- 440
		) then -- 440
			texts:put( -- 441
				"banner", -- 441
				"OUTSIDER", -- 441
				w * 0.5, -- 441
				h * 0.52, -- 441
				toColor(PALETTE.textBright), -- 441
				0.5, -- 441
				0.5, -- 441
				"Center", -- 441
				6, -- 441
				alpha, -- 441
				0 -- 441
			) -- 441
		end -- 441
		texts:put( -- 443
			"xs", -- 443
			"Powered by Dora SSR", -- 443
			w * 0.5, -- 443
			58 + frame.safe.bottom * 0.4, -- 443
			toColor(PALETTE.textDim), -- 443
			0.5, -- 443
			0.5, -- 443
			"Center", -- 443
			1.8, -- 443
			alpha * 0.62, -- 443
			0 -- 443
		) -- 443
	elseif t < 4.25 then -- 443
		local localT = t - 2.2 -- 445
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 446
		local sway = math.sin(localT * 1.1) * 8 -- 447
		drawMistCurve( -- 448
			uiArt, -- 448
			"splash_game_mist", -- 448
			w * 0.5 + sway, -- 448
			h * 0.46, -- 448
			560, -- 448
			110, -- 448
			PALETTE.jadeMist, -- 448
			0.16 * alpha, -- 448
			1 -- 448
		) -- 448
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 449
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 450
		if not uiArt:tryPlace( -- 450
			"brand_game_logo_h", -- 451
			"splash_game_logo", -- 451
			w * 0.5, -- 451
			h * 0.52, -- 451
			logoH * 2.4, -- 451
			logoH, -- 451
			{opacity = alpha, layer = 2} -- 451
		) then -- 451
			texts:put( -- 452
				"title", -- 452
				"向西守望", -- 452
				w * 0.5, -- 452
				h * 0.52, -- 452
				toColor(PALETTE.textBright), -- 452
				0.5, -- 452
				0.5, -- 452
				"Center", -- 452
				8, -- 452
				alpha, -- 452
				0 -- 452
			) -- 452
		end -- 452
	end -- 452
	if t >= 0.35 and t < 4.15 then -- 452
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 457
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 458
		texts:put( -- 463
			"xs", -- 463
			skipText, -- 463
			w - 48 - frame.safe.right * 0.6, -- 463
			36 + frame.safe.bottom * 0.4, -- 463
			toColor(PALETTE.textDim), -- 463
			1, -- 463
			0.5, -- 463
			"Right", -- 463
			1.4, -- 463
			hintA, -- 463
			0 -- 463
		) -- 463
	end -- 463
	return {type = "none"} -- 466
end -- 400
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 469
	fillHGradRect( -- 479
		uiDraw, -- 479
		0, -- 479
		0, -- 479
		w * 0.22 + frame.safe.left * 0.5, -- 479
		h, -- 479
		Color(9, 11, 18, 192), -- 479
		Color(9, 11, 18, 116) -- 479
	) -- 479
	fillHGradRect( -- 480
		uiDraw, -- 480
		w * 0.22 + frame.safe.left * 0.5, -- 480
		0, -- 480
		w * 0.28, -- 480
		h, -- 480
		Color(9, 11, 18, 116), -- 480
		Color(9, 11, 18, 0) -- 480
	) -- 480
	fillVGradRect( -- 481
		uiDraw, -- 481
		0, -- 481
		0, -- 481
		w, -- 481
		78, -- 481
		Color(8, 10, 16, 138), -- 481
		Color(8, 10, 16, 0) -- 481
	) -- 481
	local extraH = math.max(0, h - 720) -- 483
	local titleX = 148 + frame.safe.left * 0.6 -- 484
	local topY = h - 104 - frame.safe.top * 0.4 -- 485
	local charStep = 66 -- 486
	local sway = math.sin(self.time * 0.7) * 5 -- 487
	drawMistCurve( -- 488
		uiArt, -- 488
		"title_mist_wisp", -- 488
		titleX + 86 + sway, -- 488
		topY - 122, -- 488
		340, -- 488
		82, -- 488
		PALETTE.jadeMist, -- 488
		0.2, -- 488
		-1 -- 488
	) -- 488
	uiArt:tryPlace( -- 489
		"ink_petal_mist", -- 489
		"title_petals", -- 489
		titleX + 12, -- 489
		topY - 102, -- 489
		230, -- 489
		210, -- 489
		{ -- 489
			color = toColor(PALETTE.inkMist), -- 490
			opacity = 0.4, -- 490
			layer = -1 -- 490
		} -- 490
	) -- 490
	local placedBrandTitle = uiArt:tryPlace( -- 494
		"brand_game_logo_v", -- 494
		"title_brand_v", -- 494
		titleX + 22, -- 494
		topY - 106, -- 494
		240, -- 494
		304, -- 494
		{opacity = 0.98, layer = 3} -- 494
	) -- 494
	if not placedBrandTitle then -- 494
		uiArt:tryPlace( -- 498
			"ink_vstream", -- 498
			"title_vstream", -- 498
			titleX - 48, -- 498
			topY - 100, -- 498
			34, -- 498
			290, -- 498
			{ -- 498
				color = toColor(PALETTE.silkDim), -- 499
				opacity = 0.48, -- 499
				layer = 1 -- 499
			} -- 499
		) -- 499
		local c = 0 -- 501
		do -- 501
			c = 0 -- 502
			while c < #VERTICAL_TITLE do -- 502
				texts:put( -- 503
					"title", -- 504
					VERTICAL_TITLE[c + 1], -- 505
					titleX, -- 506
					topY - c * charStep, -- 507
					toColor(PALETTE.textBright), -- 508
					0.5, -- 509
					0.5, -- 510
					"Center", -- 511
					0, -- 512
					0.98, -- 513
					0.1, -- 514
					Color(8, 10, 16, 210) -- 515
				) -- 515
				c = c + 1 -- 502
			end -- 502
		end -- 502
		drawLoneSeal( -- 518
			uiInkDraw, -- 519
			uiArt, -- 520
			texts, -- 521
			"title_lone_seal", -- 522
			titleX + 46, -- 523
			topY - 3 * charStep + 8, -- 524
			26, -- 525
			52, -- 526
			"守", -- 527
			"望", -- 528
			PALETTE.sealRed, -- 529
			PALETTE.sealText, -- 530
			0.94, -- 531
			4 -- 532
		) -- 532
	end -- 532
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 537
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 538
	local poemStep = 22 -- 539
	local p = 0 -- 540
	do -- 540
		p = 0 -- 541
		while p < #EPIGRAPH_RIGHT do -- 541
			local ch = EPIGRAPH_RIGHT[p + 1] -- 542
			if ch ~= "" then -- 542
				texts:put( -- 544
					"xs", -- 544
					ch, -- 544
					colRightX, -- 544
					topY - 22 - p * poemStep, -- 544
					toColor(PALETTE.textMid), -- 544
					0.5, -- 544
					0.5, -- 544
					"Center", -- 544
					0, -- 544
					0.86, -- 544
					0.08 -- 544
				) -- 544
			end -- 544
			p = p + 1 -- 541
		end -- 541
	end -- 541
	do -- 541
		p = 0 -- 547
		while p < #EPIGRAPH_LEFT do -- 547
			texts:put( -- 548
				"xs", -- 548
				EPIGRAPH_LEFT[p + 1], -- 548
				colLeftX, -- 548
				topY - 68 - p * poemStep, -- 548
				toColor(PALETTE.amberCore), -- 548
				0.5, -- 548
				0.5, -- 548
				"Center", -- 548
				0, -- 548
				0.9, -- 548
				0.08 -- 548
			) -- 548
			p = p + 1 -- 547
		end -- 547
	end -- 547
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 552
		TITLE_ITEMS, -- 554
		function(____, it) return it.id ~= "quit" end -- 554
	) -- 554
	local items = self.hasSession and ({ -- 555
		{id = "continue", zh = "继续游戏"}, -- 556
		table.unpack(baseItems) -- 556
	}) or baseItems -- 556
	if self.selected >= #items then -- 556
		self.selected = 0 -- 559
	end -- 559
	local menuX = 112 + frame.safe.left * 0.6 -- 561
	local btnW = 280 -- 562
	local btnH = frame.mode == "touch" and 44 or 40 -- 563
	local gap = self.hasSession and 6 or 8 -- 564
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 565
	local boxes = {} -- 566
	local i = 0 -- 567
	do -- 567
		i = 0 -- 568
		while i < #items do -- 568
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 569
			i = i + 1 -- 568
		end -- 568
	end -- 568
	local prevTitleSel = self.selected -- 571
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 572
	if self.selected ~= prevTitleSel then -- 572
		self:emitSound("hover") -- 574
	end -- 574
	do -- 574
		i = 0 -- 577
		while i < #items do -- 577
			local by = boxes[i + 1].y -- 578
			local active = self.selected == i -- 579
			local cy = by + btnH * 0.5 -- 580
			local shiftX = active and 10 or 0 -- 581
			if active then -- 581
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 584
				drawSilkRibbon( -- 585
					uiDraw, -- 585
					uiArt, -- 585
					"title_rib_red_" .. tostring(i), -- 585
					menuX + 124, -- 585
					cy, -- 585
					290, -- 585
					btnH, -- 585
					PALETTE.rougeSoft, -- 585
					0.52 * breathe, -- 585
					0 -- 585
				) -- 585
				drawHairline( -- 586
					uiInkDraw, -- 586
					uiArt, -- 586
					"title_rib_line_" .. tostring(i), -- 586
					menuX + 114, -- 586
					by + 4, -- 586
					230, -- 586
					PALETTE.silkLine, -- 586
					0.42 * breathe, -- 586
					false, -- 586
					2 -- 586
				) -- 586
				drawBlossomDot( -- 587
					uiInkDraw, -- 587
					uiArt, -- 587
					"title_dot_" .. tostring(i), -- 587
					menuX + 14, -- 587
					cy, -- 587
					16, -- 587
					PALETTE.rouge, -- 587
					0.96, -- 587
					4 -- 587
				) -- 587
				fillRadialGlow( -- 588
					uiGlow, -- 588
					menuX + 14, -- 588
					cy, -- 588
					22, -- 588
					16, -- 588
					toColor(PALETTE.rouge, 28 * breathe), -- 588
					Color(182, 58, 56, 0), -- 588
					10 -- 588
				) -- 588
			else -- 588
				drawBlossomDot( -- 590
					uiInkDraw, -- 590
					uiArt, -- 590
					"title_dot_" .. tostring(i), -- 590
					menuX + 14, -- 590
					cy, -- 590
					8, -- 590
					PALETTE.silkDim, -- 590
					0.4, -- 590
					3 -- 590
				) -- 590
			end -- 590
			texts:put( -- 593
				"md", -- 594
				items[i + 1].zh, -- 595
				menuX + 34 + shiftX, -- 596
				cy, -- 597
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 598
				0, -- 599
				0.5, -- 600
				"Left", -- 601
				active and 4.4 or 2.8, -- 602
				active and 1 or 0.88, -- 603
				0.1 -- 604
			) -- 604
			i = i + 1 -- 577
		end -- 577
	end -- 577
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 608
	texts:put( -- 615
		"xs", -- 615
		titleHint, -- 615
		menuX + 12, -- 615
		42 + frame.safe.bottom * 0.45, -- 615
		toColor(PALETTE.textDim), -- 615
		0, -- 615
		0.5, -- 615
		"Left", -- 615
		1.4, -- 615
		0.88, -- 615
		0.08 -- 615
	) -- 615
	local badgeRight = w - frame.safe.right * 0.5 -- 618
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 619
	fillHGradRect( -- 620
		uiDraw, -- 620
		badgeRight - 270, -- 620
		0, -- 620
		270 + frame.safe.right * 0.5, -- 620
		86, -- 620
		Color(8, 10, 16, 0), -- 620
		Color(8, 10, 16, 204) -- 620
	) -- 620
	uiArt:tryPlace( -- 621
		"brand_team_badge", -- 621
		"title_team_badge", -- 621
		badgeRight - 118, -- 621
		badgeY, -- 621
		168, -- 621
		54, -- 621
		{opacity = 0.95, layer = 3} -- 621
	) -- 621
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 625
	if hit >= 0 or frame.keys.confirm then -- 625
		local idx = hit >= 0 and hit or self.selected -- 627
		local id = items[idx + 1].id -- 628
		if id == "continue" then -- 628
			self:emitSound("start") -- 629
			return {type = "continue"} -- 629
		end -- 629
		if id == "trial" then -- 629
			self:emitSound("start") -- 630
			return {type = "trial"} -- 630
		end -- 630
		if id == "start" then -- 630
			self:emitSound("start") -- 631
			return {type = "start"} -- 631
		end -- 631
		if id == "chapters" then -- 631
			self:emitSound("confirm") -- 632
			return {type = "openChapters"} -- 632
		end -- 632
		if id == "quit" then -- 632
			self:emitSound("back") -- 633
			return {type = "quit"} -- 633
		end -- 633
		self:emitSound("confirm") -- 634
		return {type = "openControls"} -- 635
	end -- 635
	return {type = "none"} -- 637
end -- 469
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 640
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 650
	if frame.back then -- 650
		self:emitSound("back") -- 652
		return back -- 653
	end -- 653
	local extraH = math.max(0, h - 720) -- 656
	local marginX = math.max( -- 657
		96, -- 657
		56 + math.max(frame.safe.left, frame.safe.right) -- 657
	) -- 657
	local splitTrack = #CHAPTERS > 8 -- 658
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 659
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 660
	local rowGap = 68 -- 661
	local trackX0 = marginX + 34 -- 662
	local trackX1 = w - marginX - 34 -- 663
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 664
	local stationBoxes = {} -- 666
	local s = 0 -- 667
	do -- 667
		s = 0 -- 668
		while s < #CHAPTERS do -- 668
			local sx = trackX0 + s % perRow * stepX -- 669
			local sy = trackY - math.floor(s / perRow) * rowGap -- 670
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 671
			s = s + 1 -- 668
		end -- 668
	end -- 668
	local prevSelected = self.chapterSelected -- 674
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 675
	local keys = frame.keys -- 676
	if frame.click and hitStation >= 0 then -- 676
		self.chapterSelected = hitStation -- 678
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 678
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 680
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 681
	elseif keys.down and self.chapterSelected < perRow then -- 681
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 683
	elseif keys.up and self.chapterSelected >= perRow then -- 683
		self.chapterSelected = self.chapterSelected - perRow -- 685
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 685
		self.chapterSelected = hitStation -- 687
	end -- 687
	if self.chapterSelected ~= prevSelected then -- 687
		self:emitSound("hover") -- 690
	end -- 690
	uiDraw:drawRect( -- 693
		Rect(0, 0, w, h), -- 693
		Color(10, 12, 19, 198) -- 693
	) -- 693
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 695
	texts:put( -- 696
		"banner", -- 696
		"选择章节", -- 696
		marginX, -- 696
		topHeadY, -- 696
		toColor(PALETTE.textBright), -- 696
		0, -- 696
		0.5, -- 696
		"Left", -- 696
		4.5, -- 696
		0.96, -- 696
		0.1 -- 696
	) -- 696
	drawHairline( -- 697
		uiInkDraw, -- 697
		uiArt, -- 697
		"chap_top_line", -- 697
		w * 0.5, -- 697
		topHeadY - 34, -- 697
		w - marginX * 2, -- 697
		PALETTE.silkDim, -- 697
		0.6, -- 697
		true, -- 697
		2 -- 697
	) -- 697
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 699
	local theme = themeOf(activeRoom.key) -- 700
	local winX = marginX -- 701
	local winY = 266 + extraH * 0.44 -- 702
	local winW = math.min( -- 703
		520, -- 703
		math.max(360, (w - marginX * 2) * 0.46) -- 703
	) -- 703
	local winH = 296 -- 704
	local winBox = Rect(winX, winY, winW, winH) -- 705
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 706
	uiArt:tryPlace( -- 708
		"ink_frame_mask", -- 708
		"chap_win_shadow", -- 708
		winX + winW * 0.5, -- 708
		winY + winH * 0.5, -- 708
		winW + 40, -- 708
		winH + 34, -- 708
		{ -- 708
			color = toColor(PALETTE.inkVoid), -- 709
			opacity = 0.88, -- 709
			layer = -2 -- 709
		} -- 709
	) -- 709
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 711
	uiArt:tryPlace( -- 712
		bgSlot, -- 712
		"chap_win_art", -- 712
		winX + winW * 0.5, -- 712
		winY + 4, -- 712
		winW - 8, -- 712
		winH - 8, -- 712
		{opacity = 0.92, layer = -1} -- 712
	) -- 712
	fillVGradRect( -- 715
		uiInkDraw, -- 715
		winX, -- 715
		winY, -- 715
		winW, -- 715
		56, -- 715
		Color(10, 12, 19, 200), -- 715
		Color(10, 12, 19, 0) -- 715
	) -- 715
	fillVGradRect( -- 716
		uiInkDraw, -- 716
		winX, -- 716
		winY + winH - 36, -- 716
		winW, -- 716
		36, -- 716
		Color(10, 12, 19, 0), -- 716
		Color(10, 12, 19, 130) -- 716
	) -- 716
	fillHGradRect( -- 717
		uiInkDraw, -- 717
		winX, -- 717
		winY, -- 717
		34, -- 717
		winH, -- 717
		Color(10, 12, 19, 135), -- 717
		Color(10, 12, 19, 0) -- 717
	) -- 717
	fillHGradRect( -- 718
		uiInkDraw, -- 718
		winX + winW - 34, -- 718
		winY, -- 718
		34, -- 718
		winH, -- 718
		Color(10, 12, 19, 0), -- 718
		Color(10, 12, 19, 135) -- 718
	) -- 718
	drawFiligreeCorners( -- 719
		uiInkDraw, -- 719
		uiArt, -- 719
		"chap_win_frame", -- 719
		winX, -- 719
		winY, -- 719
		winW, -- 719
		winH, -- 719
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 719
		winHover and 0.92 or 0.72, -- 719
		34, -- 719
		true, -- 719
		3 -- 719
	) -- 719
	texts:put( -- 721
		"xs", -- 721
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 721
		winX + 20, -- 721
		winY + 22, -- 721
		toColor(PALETTE.textMid), -- 721
		0, -- 721
		0.5, -- 721
		"Left", -- 721
		1.8, -- 721
		0.9, -- 721
		0.08 -- 721
	) -- 721
	local infoX = winX + winW + 40 -- 723
	local infoW = math.max(240, w - marginX - infoX) -- 724
	local infoCenterY = winY + winH * 0.5 -- 725
	drawMistCurve( -- 726
		uiArt, -- 726
		"chap_info_mist", -- 726
		infoX + infoW * 0.5, -- 726
		infoCenterY + 36, -- 726
		math.min(420, infoW + 24), -- 726
		88, -- 726
		theme.accent, -- 726
		0.22, -- 726
		-1 -- 726
	) -- 726
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 728
	texts:put( -- 729
		"xs", -- 729
		theme.volumeTagZh, -- 729
		infoX, -- 729
		winY + winH - 44, -- 729
		toColor(volCol), -- 729
		0, -- 729
		0.5, -- 729
		"Left", -- 729
		2.8, -- 729
		0.92, -- 729
		0.08 -- 729
	) -- 729
	local sep = " · " -- 731
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 732
	local titleY = winY + winH - 98 -- 733
	if theme.backdropKey ~= nil then -- 733
		texts:put( -- 735
			"lg", -- 735
			theme.titleZh, -- 735
			infoX, -- 735
			titleY, -- 735
			toColor(PALETTE.textBright) -- 735
		) -- 735
	elseif sIdx > 0 then -- 735
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 737
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 738
		local lw = visualTextWidth(leftPart, 40) -- 739
		texts:put( -- 740
			"banner", -- 740
			leftPart, -- 740
			infoX, -- 740
			titleY, -- 740
			toColor(PALETTE.textBright), -- 740
			0, -- 740
			0.5, -- 740
			"Left", -- 740
			2, -- 740
			1, -- 740
			0.1 -- 740
		) -- 740
		drawBlossomDot( -- 741
			uiInkDraw, -- 741
			uiArt, -- 741
			"chap_title_dot", -- 741
			infoX + lw + 16, -- 741
			titleY - 2, -- 741
			11, -- 741
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 741
			0.9, -- 741
			4 -- 741
		) -- 741
		texts:put( -- 742
			"banner", -- 742
			rightPart, -- 742
			infoX + lw + 32, -- 742
			titleY, -- 742
			toColor(PALETTE.textBright), -- 742
			0, -- 742
			0.5, -- 742
			"Left", -- 742
			2, -- 742
			1, -- 742
			0.1 -- 742
		) -- 742
	else -- 742
		texts:put( -- 744
			"banner", -- 744
			theme.titleZh, -- 744
			infoX, -- 744
			titleY, -- 744
			toColor(PALETTE.textBright), -- 744
			0, -- 744
			0.5, -- 744
			"Left", -- 744
			2.4, -- 744
			1, -- 744
			0.1 -- 744
		) -- 744
	end -- 744
	drawHairline( -- 747
		uiInkDraw, -- 747
		uiArt, -- 747
		"chap_info_line", -- 747
		infoX + math.min(185, infoW * 0.5), -- 747
		titleY - 36, -- 747
		math.min(370, infoW), -- 747
		PALETTE.silkDim, -- 747
		0.58, -- 747
		false, -- 747
		2 -- 747
	) -- 747
	texts:put( -- 748
		"sm", -- 748
		theme.introWhisper, -- 748
		infoX, -- 748
		titleY - 72, -- 748
		toColor(PALETTE.textMid), -- 748
		0, -- 748
		0.5, -- 748
		"Left", -- 748
		0.8, -- 748
		0.94, -- 748
		0.08 -- 748
	) -- 748
	local goX = infoX -- 750
	local goY = winY + 26 -- 751
	local goW = 220 -- 752
	local goH = 42 -- 753
	local goBox = Rect(goX, goY, goW, goH) -- 754
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 755
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 756
	drawSilkRibbon( -- 757
		uiDraw, -- 757
		uiArt, -- 757
		"chap_go_rib", -- 757
		goX + 106, -- 757
		goY + 21, -- 757
		250, -- 757
		40, -- 757
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 757
		(goHover and 0.68 or 0.46) * breathe, -- 757
		0 -- 757
	) -- 757
	drawHairline( -- 758
		uiInkDraw, -- 758
		uiArt, -- 758
		"chap_go_line", -- 758
		goX + 94, -- 758
		goY + 3, -- 758
		196, -- 758
		PALETTE.silkLine, -- 758
		goHover and 0.68 or 0.4, -- 758
		false, -- 758
		2 -- 758
	) -- 758
	drawBlossomDot( -- 759
		uiInkDraw, -- 759
		uiArt, -- 759
		"chap_go_dot", -- 759
		goX + 14, -- 759
		goY + 21, -- 759
		14, -- 759
		PALETTE.rouge, -- 759
		0.96, -- 759
		4 -- 759
	) -- 759
	texts:put( -- 760
		"md", -- 760
		"入此卷章", -- 760
		goX + 34, -- 760
		goY + 21, -- 760
		toColor(PALETTE.textBright), -- 760
		0, -- 760
		0.5, -- 760
		"Left", -- 760
		3.8, -- 760
		1, -- 760
		0.1 -- 760
	) -- 760
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 761
	texts:put( -- 764
		"xs", -- 764
		chapConfirmTag, -- 764
		goX + 156, -- 764
		goY + 21, -- 764
		toColor(PALETTE.textDim), -- 764
		0, -- 764
		0.5, -- 764
		"Left", -- 764
		1, -- 764
		0.82, -- 764
		0.08 -- 764
	) -- 764
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 766
	local veilH = splitTrack and 156 or 126 -- 767
	drawSilkVeil( -- 768
		uiDraw, -- 768
		uiArt, -- 768
		"chap_track_veil", -- 768
		w * 0.5, -- 768
		veilCenterY, -- 768
		w - marginX * 1.1, -- 768
		veilH, -- 768
		PALETTE.inkWash, -- 768
		0.72, -- 768
		-2 -- 768
	) -- 768
	drawMistCurve( -- 769
		uiArt, -- 769
		"chap_track_mist", -- 769
		w * 0.5, -- 769
		trackY, -- 769
		trackX1 - trackX0 + 160, -- 769
		74, -- 769
		PALETTE.inkMist, -- 769
		0.62, -- 769
		-1 -- 769
	) -- 769
	uiInkDraw:drawSegment( -- 770
		Vec2(trackX0, trackY), -- 770
		Vec2(trackX1, trackY), -- 770
		0.9, -- 770
		toColor(PALETTE.silkDim, 145) -- 770
	) -- 770
	if splitTrack then -- 770
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 773
		uiInkDraw:drawSegment( -- 774
			Vec2(trackX0, trackY - rowGap), -- 774
			Vec2(lastX, trackY - rowGap), -- 774
			0.9, -- 774
			toColor(PALETTE.silkDim, 145) -- 774
		) -- 774
	else -- 774
		local midDivX = trackX0 + stepX * 3.5 -- 776
		uiInkDraw:drawSegment( -- 777
			Vec2(midDivX, trackY - 12), -- 777
			Vec2(midDivX, trackY + 12), -- 777
			0.8, -- 777
			toColor(PALETTE.silkDim, 120) -- 777
		) -- 777
		texts:put( -- 778
			"xs", -- 778
			"上卷 · 孤城护童", -- 778
			trackX0 + stepX * 1.5, -- 778
			trackY + 52, -- 778
			toColor(PALETTE.cyan), -- 778
			0.5, -- 778
			0.5, -- 778
			"Center", -- 778
			2.2, -- 778
			0.88, -- 778
			0.08 -- 778
		) -- 778
		texts:put( -- 779
			"xs", -- 779
			"下卷 · 独赴北塔", -- 779
			trackX0 + stepX * 5.5, -- 779
			trackY + 52, -- 779
			toColor(PALETTE.amber), -- 779
			0.5, -- 779
			0.5, -- 779
			"Center", -- 779
			2.2, -- 779
			0.88, -- 779
			0.08 -- 779
		) -- 779
	end -- 779
	local i = 0 -- 782
	do -- 782
		i = 0 -- 783
		while i < #CHAPTERS do -- 783
			local box = stationBoxes[i + 1] -- 784
			local sx = box.x + box.width * 0.5 -- 785
			local sy = box.y + box.height * 0.5 -- 786
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 787
			local active = self.chapterSelected == i -- 788
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 789
			if active then -- 789
				fillRadialGlow( -- 792
					uiGlow, -- 792
					sx, -- 792
					sy, -- 792
					26, -- 792
					26, -- 792
					toColor(PALETTE.rouge, 36 * breathe), -- 792
					Color(182, 58, 56, 0), -- 792
					12 -- 792
				) -- 792
				uiArt:tryPlace( -- 793
					"ink_enso_fine", -- 793
					"chap_st_ring_" .. tostring(i), -- 793
					sx, -- 793
					sy, -- 793
					32, -- 793
					32, -- 793
					{ -- 793
						color = toColor(PALETTE.silkLine), -- 794
						opacity = 0.78, -- 794
						angle = self.time * 18, -- 794
						layer = 3 -- 794
					} -- 794
				) -- 794
				drawBlossomDot( -- 796
					uiInkDraw, -- 796
					uiArt, -- 796
					"chap_st_dot_" .. tostring(i), -- 796
					sx, -- 796
					sy, -- 796
					17, -- 796
					PALETTE.rouge, -- 796
					0.98, -- 796
					4 -- 796
				) -- 796
			else -- 796
				uiArt:tryPlace( -- 798
					"ink_enso_fine", -- 798
					"chap_st_ring_" .. tostring(i), -- 798
					sx, -- 798
					sy, -- 798
					16, -- 798
					16, -- 798
					{ -- 798
						color = toColor(nodeCol), -- 799
						opacity = 0.62, -- 799
						layer = 3 -- 799
					} -- 799
				) -- 799
				drawBlossomDot( -- 801
					uiInkDraw, -- 801
					uiArt, -- 801
					"chap_st_dot_" .. tostring(i), -- 801
					sx, -- 801
					sy, -- 801
					7, -- 801
					PALETTE.silkLine, -- 801
					0.72, -- 801
					4 -- 801
				) -- 801
			end -- 801
			if not splitTrack then -- 801
				texts:put( -- 805
					"xs", -- 805
					rt.numeralZh, -- 805
					sx, -- 805
					sy + 25, -- 805
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 805
					0.5, -- 805
					0.5, -- 805
					"Center", -- 805
					0, -- 805
					active and 1 or 0.88, -- 805
					0.08 -- 805
				) -- 805
			end -- 805
			texts:put( -- 807
				"xs", -- 807
				rt.shortNameZh, -- 807
				sx, -- 807
				sy - 26, -- 807
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 807
				0.5, -- 807
				0.5, -- 807
				"Center", -- 807
				1, -- 807
				active and 1 or 0.84, -- 807
				0.08 -- 807
			) -- 807
			i = i + 1 -- 783
		end -- 783
	end -- 783
	local backX = marginX -- 810
	local backY = 40 + frame.safe.bottom * 0.45 -- 811
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 812
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 813
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 814
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 817
	drawSilkKeycap( -- 822
		uiInkDraw, -- 822
		texts, -- 822
		backX, -- 822
		backY + 5, -- 822
		48, -- 822
		24, -- 822
		chapBackTag, -- 822
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 822
		0.92, -- 822
		backHover -- 822
	) -- 822
	texts:put( -- 823
		"sm", -- 823
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 823
		backX + 60, -- 823
		backY + 17, -- 823
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 823
		0, -- 823
		0.5, -- 823
		"Left", -- 823
		1.8, -- 823
		0.9, -- 823
		0.08 -- 823
	) -- 823
	texts:put( -- 824
		"xs", -- 824
		chapFooter, -- 824
		w - marginX, -- 824
		backY + 17, -- 824
		toColor(PALETTE.textDim), -- 824
		1, -- 824
		0.5, -- 824
		"Right", -- 824
		1.2, -- 824
		0.75, -- 824
		0.08 -- 824
	) -- 824
	if frame.click and backHover then -- 824
		self:emitSound("back") -- 827
		return back -- 828
	end -- 828
	local ____temp_2 -- 831
	if frame.mode == "touch" then -- 831
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 832
	else -- 832
		____temp_2 = hitStation >= 0 -- 833
	end -- 833
	local stationConfirmed = ____temp_2 -- 831
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 831
		self:emitSound("start") -- 835
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 836
	end -- 836
	return {type = "none"} -- 838
end -- 640
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 842
	if backLabel == nil then -- 842
		backLabel = "返回标题" -- 851
	end -- 851
	if not self.controlsTabManual then -- 851
		self.controlsTab = frame.mode -- 854
	end -- 854
	local tabOrder = {"kbm", "gamepad", "touch"} -- 856
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 857
	local marginX = math.max( -- 858
		96, -- 858
		56 + math.max(frame.safe.left, frame.safe.right) -- 858
	) -- 858
	local tabW = 92 -- 859
	local tabH = 28 -- 860
	local tabGap = 10 -- 861
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 862
	local tabY = h - 82 - frame.safe.top * 0.35 -- 863
	local tabBoxes = { -- 864
		Rect(tabStartX, tabY, tabW, tabH), -- 865
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 866
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 867
	} -- 867
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 870
	if frame.click and hitTab >= 0 then -- 870
		if self.controlsTab ~= tabOrder[hitTab + 1] then -- 870
			self:emitSound("toggle") -- 873
		end -- 873
		self.controlsTab = tabOrder[hitTab + 1] -- 875
		self.controlsTabManual = true -- 876
	elseif frame.keys.left or frame.prevTab then -- 876
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 878
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 879
		self.controlsTabManual = true -- 880
		self:emitSound("toggle") -- 881
	elseif frame.keys.right or frame.nextTab then -- 881
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 883
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 884
		self.controlsTabManual = true -- 885
		self:emitSound("toggle") -- 886
	end -- 886
	local backX = marginX -- 889
	local backY = 40 + frame.safe.bottom * 0.45 -- 890
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 891
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 892
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 892
		self:emitSound("back") -- 894
		return {type = "backTitle"} -- 895
	end -- 895
	uiDraw:drawRect( -- 897
		Rect(0, 0, w, h), -- 897
		Color(10, 12, 19, 204) -- 897
	) -- 897
	local guide = controlsGuideRows(self.controlsTab) -- 899
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 900
	texts:put( -- 901
		"banner", -- 901
		"执器要诀", -- 901
		marginX, -- 901
		topHeadY, -- 901
		toColor(PALETTE.textBright), -- 901
		0, -- 901
		0.5, -- 901
		"Left", -- 901
		4.5, -- 901
		0.96, -- 901
		0.1 -- 901
	) -- 901
	texts:put( -- 902
		"xs", -- 902
		guide.subtitle, -- 902
		marginX + 196, -- 902
		topHeadY - 4, -- 902
		toColor(PALETTE.textDim), -- 902
		0, -- 902
		0.5, -- 902
		"Left", -- 902
		1.8, -- 902
		0.85, -- 902
		0.08 -- 902
	) -- 902
	drawHairline( -- 903
		uiInkDraw, -- 903
		uiArt, -- 903
		"ctrl_top_line", -- 903
		w * 0.5, -- 903
		topHeadY - 34, -- 903
		w - marginX * 2, -- 903
		PALETTE.silkDim, -- 903
		0.6, -- 903
		true, -- 903
		2 -- 903
	) -- 903
	local ti = 0 -- 905
	do -- 905
		ti = 0 -- 906
		while ti < #tabBoxes do -- 906
			local tb = tabBoxes[ti + 1] -- 907
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 908
			local hoverTab = hitTab == ti -- 909
			uiInkDraw:drawRect( -- 910
				tb, -- 911
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 912
				0.9, -- 913
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 914
			) -- 914
			texts:put( -- 916
				"xs", -- 917
				tabLabels[ti + 1], -- 918
				tb.x + tb.width * 0.5, -- 919
				tb.y + tb.height * 0.5, -- 920
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 921
				0.5, -- 922
				0.5, -- 923
				"Center", -- 924
				0.8, -- 925
				activeTab and 0.98 or 0.82, -- 926
				0.08 -- 927
			) -- 927
			ti = ti + 1 -- 906
		end -- 906
	end -- 906
	local extraH = math.max(0, h - 720) -- 931
	local areaY = 114 + frame.safe.bottom * 0.4 -- 932
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 933
	drawFiligreeCorners( -- 934
		uiInkDraw, -- 934
		uiArt, -- 934
		"ctrl_outer", -- 934
		marginX, -- 934
		areaY, -- 934
		w - marginX * 2, -- 934
		areaH, -- 934
		PALETTE.silkDim, -- 934
		0.52, -- 934
		34, -- 934
		false, -- 934
		2 -- 934
	) -- 934
	local midX = w * 0.5 -- 936
	uiArt:tryPlace( -- 937
		"ink_vstream", -- 937
		"ctrl_mid_stream", -- 937
		midX, -- 937
		areaY + areaH * 0.5, -- 937
		32, -- 937
		areaH - 18, -- 937
		{ -- 937
			color = toColor(PALETTE.silkDim), -- 938
			opacity = 0.52, -- 938
			layer = 1 -- 938
		} -- 938
	) -- 938
	drawBlossomDot( -- 940
		uiInkDraw, -- 940
		uiArt, -- 940
		"ctrl_mid_dot", -- 940
		midX, -- 940
		areaY + areaH * 0.5, -- 940
		11, -- 940
		PALETTE.silkLine, -- 940
		0.62, -- 940
		3 -- 940
	) -- 940
	local leftColX = marginX + 34 -- 942
	local colW = midX - leftColX - 42 -- 943
	local headY = areaY + areaH - 34 -- 944
	local rowStep = 52 + extraH * 0.08 -- 945
	drawBlossomDot( -- 947
		uiInkDraw, -- 947
		uiArt, -- 947
		"ctrl_l_dot", -- 947
		leftColX + 8, -- 947
		headY, -- 947
		12, -- 947
		PALETTE.cyan, -- 947
		0.88, -- 947
		3 -- 947
	) -- 947
	texts:put( -- 948
		"md", -- 948
		"周戍 · 护送与交锋", -- 948
		leftColX + 26, -- 948
		headY, -- 948
		toColor(PALETTE.cyanCore), -- 948
		0, -- 948
		0.5, -- 948
		"Left", -- 948
		2.4, -- 948
		0.98, -- 948
		0.08 -- 948
	) -- 948
	drawHairline( -- 949
		uiInkDraw, -- 949
		uiArt, -- 949
		"ctrl_l_line", -- 949
		leftColX + colW * 0.5, -- 949
		headY - 24, -- 949
		colW, -- 949
		PALETTE.cyanDim, -- 949
		0.58, -- 949
		false, -- 949
		2 -- 949
	) -- 949
	local i = 0 -- 951
	local keycapW = 160 -- 952
	do -- 952
		i = 0 -- 953
		while i < #guide.soldierRows do -- 953
			local ry = headY - 66 - i * rowStep -- 954
			drawSilkKeycap( -- 955
				uiInkDraw, -- 955
				texts, -- 955
				leftColX + 2, -- 955
				ry - 13, -- 955
				keycapW, -- 955
				26, -- 955
				guide.soldierRows[i + 1][1], -- 955
				PALETTE.cyan, -- 955
				0.92, -- 955
				false -- 955
			) -- 955
			texts:put( -- 956
				"sm", -- 956
				guide.soldierRows[i + 1][2], -- 956
				leftColX + keycapW + 16, -- 956
				ry, -- 956
				toColor(PALETTE.textBright), -- 956
				0, -- 956
				0.5, -- 956
				"Left", -- 956
				0.8, -- 956
				0.92, -- 956
				0.08 -- 956
			) -- 956
			i = i + 1 -- 953
		end -- 953
	end -- 953
	local rightColX = midX + 44 -- 959
	drawBlossomDot( -- 960
		uiInkDraw, -- 960
		uiArt, -- 960
		"ctrl_r_dot", -- 960
		rightColX + 8, -- 960
		headY, -- 960
		12, -- 960
		PALETTE.amber, -- 960
		0.88, -- 960
		3 -- 960
	) -- 960
	texts:put( -- 961
		"md", -- 961
		"小满 · 潜行与寻路", -- 961
		rightColX + 26, -- 961
		headY, -- 961
		toColor(PALETTE.amberCore), -- 961
		0, -- 961
		0.5, -- 961
		"Left", -- 961
		2.4, -- 961
		0.98, -- 961
		0.08 -- 961
	) -- 961
	drawHairline( -- 962
		uiInkDraw, -- 962
		uiArt, -- 962
		"ctrl_r_line", -- 962
		rightColX + colW * 0.5, -- 962
		headY - 24, -- 962
		colW, -- 962
		PALETTE.amberDim, -- 962
		0.58, -- 962
		false, -- 962
		2 -- 962
	) -- 962
	do -- 962
		i = 0 -- 964
		while i < #guide.childRows do -- 964
			local ry = headY - 66 - i * rowStep -- 965
			drawSilkKeycap( -- 966
				uiInkDraw, -- 966
				texts, -- 966
				rightColX + 2, -- 966
				ry - 13, -- 966
				keycapW, -- 966
				26, -- 966
				guide.childRows[i + 1][1], -- 966
				PALETTE.amber, -- 966
				0.92, -- 966
				false -- 966
			) -- 966
			texts:put( -- 967
				"sm", -- 967
				guide.childRows[i + 1][2], -- 967
				rightColX + keycapW + 16, -- 967
				ry, -- 967
				toColor(PALETTE.textBright), -- 967
				0, -- 967
				0.5, -- 967
				"Left", -- 967
				0.8, -- 967
				0.92, -- 967
				0.08 -- 967
			) -- 967
			i = i + 1 -- 964
		end -- 964
	end -- 964
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 970
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 973
	local keyW = frame.mode == "touch" and 76 or 110 -- 978
	drawSilkKeycap( -- 979
		uiInkDraw, -- 979
		texts, -- 979
		backX, -- 979
		backY + 5, -- 979
		keyW, -- 979
		24, -- 979
		ctrlBackKey, -- 979
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 979
		0.92, -- 979
		backHover -- 979
	) -- 979
	texts:put( -- 980
		"sm", -- 980
		backLabel, -- 980
		backX + keyW + 12, -- 980
		backY + 17, -- 980
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 980
		0, -- 980
		0.5, -- 980
		"Left", -- 980
		1.8, -- 980
		0.92, -- 980
		0.08 -- 980
	) -- 980
	texts:put( -- 981
		"xs", -- 981
		ctrlRightHint, -- 981
		w - marginX, -- 981
		backY + 17, -- 981
		toColor(PALETTE.textDim), -- 981
		1, -- 981
		0.5, -- 981
		"Right", -- 981
		1.2, -- 981
		0.78, -- 981
		0.08 -- 981
	) -- 981
	return {type = "none"} -- 983
end -- 842
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 987
	if frame.back then -- 987
		self:emitSound("back") -- 999
		return true -- 1000
	end -- 1000
	local caps = getPlatformCaps() -- 1003
	local s = input.settings -- 1004
	uiDraw:drawRect( -- 1006
		Rect(0, 0, w, h), -- 1006
		Color(10, 12, 19, 206) -- 1006
	) -- 1006
	local marginX = math.max( -- 1008
		96, -- 1008
		56 + math.max(frame.safe.left, frame.safe.right) -- 1008
	) -- 1008
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 1009
	texts:put( -- 1010
		"banner", -- 1010
		"操控与声音", -- 1010
		marginX, -- 1010
		topHeadY, -- 1010
		toColor(PALETTE.textBright), -- 1010
		0, -- 1010
		0.5, -- 1010
		"Left", -- 1010
		4, -- 1010
		0.96, -- 1010
		0.1 -- 1010
	) -- 1010
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 操控与四通道音量实时生效" -- 1011
	texts:put( -- 1012
		"xs", -- 1012
		curSummary, -- 1012
		marginX + 224, -- 1012
		topHeadY - 4, -- 1012
		toColor(PALETTE.amberCore), -- 1012
		0, -- 1012
		0.5, -- 1012
		"Left", -- 1012
		1.4, -- 1012
		0.88, -- 1012
		0.08 -- 1012
	) -- 1012
	drawHairline( -- 1013
		uiInkDraw, -- 1013
		uiArt, -- 1013
		"set_top_line", -- 1013
		w * 0.5, -- 1013
		topHeadY - 30, -- 1013
		w - marginX * 2, -- 1013
		PALETTE.silkDim, -- 1013
		0.6, -- 1013
		true, -- 1013
		2 -- 1013
	) -- 1013
	local panelW = math.min(760, w - marginX * 2) -- 1015
	local panelX = (w - panelW) * 0.5 -- 1016
	local rowH = 34 -- 1017
	local rowStep = 39 -- 1018
	local firstY = topHeadY - 76 -- 1019
	local boxes = {} -- 1021
	local i = 0 -- 1022
	do -- 1022
		i = 0 -- 1023
		while i < #SETTINGS_ROWS do -- 1023
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 1024
			i = i + 1 -- 1023
		end -- 1023
	end -- 1023
	local prevSetSel = self.settingsSelected -- 1026
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 1027
	if self.settingsSelected ~= prevSetSel then -- 1027
		self:emitSound("hover") -- 1029
	end -- 1029
	local function applyDelta(rowId, delta) -- 1032
		if rowId == "back" then -- 1032
			self:emitSound("back") -- 1034
			return true -- 1035
		end -- 1035
		local audioChanged = false -- 1037
		if rowId == "modePref" then -- 1037
			input:cycleModePref(delta) -- 1039
		elseif rowId == "aimAssist" then -- 1039
			s.aimAssist = not s.aimAssist -- 1041
			saveControlSettings(s) -- 1042
		elseif rowId == "gpLayout" then -- 1042
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1044
			input.gamepadLayout = s.gamepadLayout -- 1045
			saveControlSettings(s) -- 1046
		elseif rowId == "crouchMode" then -- 1046
			s.crouchToggle = not s.crouchToggle -- 1048
			saveControlSettings(s) -- 1049
		elseif rowId == "touchOpacity" then -- 1049
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1051
			saveControlSettings(s) -- 1052
		elseif rowId == "touchScale" then -- 1052
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1054
			saveControlSettings(s) -- 1055
		elseif rowId == "haptics" then -- 1055
			s.haptics = not s.haptics -- 1057
			saveControlSettings(s) -- 1058
			if s.haptics then -- 1058
				local ____opt_3 = input:getTouch() -- 1058
				if ____opt_3 ~= nil then -- 1058
					____opt_3:vibrate(0.018) -- 1060
				end -- 1060
			end -- 1060
		elseif rowId == "masterVol" then -- 1060
			s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 1063
			saveControlSettings(s) -- 1064
			audioChanged = true -- 1065
		elseif rowId == "bgmVol" then -- 1065
			s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 1067
			saveControlSettings(s) -- 1068
			audioChanged = true -- 1069
		elseif rowId == "sfxVol" then -- 1069
			s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 1071
			saveControlSettings(s) -- 1072
			audioChanged = true -- 1073
		elseif rowId == "voiceVol" then -- 1073
			s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 1075
			saveControlSettings(s) -- 1076
			audioChanged = true -- 1077
		end -- 1077
		if audioChanged and self.onAudioSettingsChanged ~= nil then -- 1077
			self:onAudioSettingsChanged(input) -- 1080
		end -- 1080
		self:emitSound("toggle") -- 1082
		return false -- 1083
	end -- 1032
	local function valueTextOf(rowId) -- 1086
		if rowId == "modePref" then -- 1086
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1088
		end -- 1088
		if rowId == "aimAssist" then -- 1088
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1092
		end -- 1092
		if rowId == "gpLayout" then -- 1092
			return layoutLabelOf(s.gamepadLayout) -- 1093
		end -- 1093
		if rowId == "crouchMode" then -- 1093
			return s.crouchToggle and "点按切换" or "持续按住" -- 1094
		end -- 1094
		if rowId == "touchOpacity" then -- 1094
			return opacityLabelOf(s.touchOpacity) -- 1095
		end -- 1095
		if rowId == "touchScale" then -- 1095
			return scaleLabelOf(s.touchScale) -- 1096
		end -- 1096
		if rowId == "haptics" then -- 1096
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1097
		end -- 1097
		if rowId == "masterVol" then -- 1097
			return volumeLabelOf(s.masterVol) -- 1098
		end -- 1098
		if rowId == "bgmVol" then -- 1098
			return volumeLabelOf(s.bgmVol) -- 1099
		end -- 1099
		if rowId == "sfxVol" then -- 1099
			return volumeLabelOf(s.sfxVol) -- 1100
		end -- 1100
		if rowId == "voiceVol" then -- 1100
			return volumeLabelOf(s.voiceVol) -- 1101
		end -- 1101
		return "" -- 1102
	end -- 1086
	do -- 1086
		i = 0 -- 1105
		while i < #SETTINGS_ROWS do -- 1105
			local row = SETTINGS_ROWS[i + 1] -- 1106
			local box = boxes[i + 1] -- 1107
			local cy = box.y + box.height * 0.5 -- 1108
			local active = self.settingsSelected == i -- 1109
			if active then -- 1109
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1112
				drawSilkRibbon( -- 1113
					uiDraw, -- 1113
					uiArt, -- 1113
					"set_rib_" .. tostring(i), -- 1113
					panelX + panelW * 0.5, -- 1113
					cy, -- 1113
					panelW + 24, -- 1113
					rowH, -- 1113
					PALETTE.rougeSoft, -- 1113
					0.48 * breathe, -- 1113
					0 -- 1113
				) -- 1113
				drawHairline( -- 1114
					uiInkDraw, -- 1114
					uiArt, -- 1114
					"set_line_" .. tostring(i), -- 1114
					panelX + panelW * 0.5, -- 1114
					box.y + 3, -- 1114
					panelW - 24, -- 1114
					PALETTE.silkLine, -- 1114
					0.42 * breathe, -- 1114
					false, -- 1114
					2 -- 1114
				) -- 1114
				drawBlossomDot( -- 1115
					uiInkDraw, -- 1115
					uiArt, -- 1115
					"set_dot_" .. tostring(i), -- 1115
					panelX + 18, -- 1115
					cy, -- 1115
					14, -- 1115
					PALETTE.rouge, -- 1115
					0.96, -- 1115
					4 -- 1115
				) -- 1115
				fillRadialGlow( -- 1116
					uiGlow, -- 1116
					panelX + 18, -- 1116
					cy, -- 1116
					20, -- 1116
					14, -- 1116
					toColor(PALETTE.rouge, 24 * breathe), -- 1116
					Color(182, 58, 56, 0), -- 1116
					10 -- 1116
				) -- 1116
			else -- 1116
				drawBlossomDot( -- 1118
					uiInkDraw, -- 1118
					uiArt, -- 1118
					"set_dot_" .. tostring(i), -- 1118
					panelX + 18, -- 1118
					cy, -- 1118
					7, -- 1118
					PALETTE.silkDim, -- 1118
					0.42, -- 1118
					3 -- 1118
				) -- 1118
			end -- 1118
			texts:put( -- 1121
				"sm", -- 1122
				row.title, -- 1123
				panelX + 42, -- 1124
				cy, -- 1125
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1126
				0, -- 1127
				0.5, -- 1128
				"Left", -- 1129
				active and 2.4 or 1.6, -- 1130
				active and 1 or 0.88, -- 1131
				0.08 -- 1132
			) -- 1132
			local val = valueTextOf(row.id) -- 1135
			if val ~= "" then -- 1135
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1137
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1138
				texts:put( -- 1139
					"sm", -- 1139
					decorated, -- 1139
					panelX + panelW - 24, -- 1139
					cy, -- 1139
					toColor(valCol), -- 1139
					1, -- 1139
					0.5, -- 1139
					"Right", -- 1139
					1, -- 1139
					active and 1 or 0.86, -- 1139
					0.08 -- 1139
				) -- 1139
			end -- 1139
			i = i + 1 -- 1105
		end -- 1105
	end -- 1105
	local backY = 40 + frame.safe.bottom * 0.45 -- 1143
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1144
	texts:put( -- 1149
		"xs", -- 1149
		hint, -- 1149
		w * 0.5, -- 1149
		backY + 14, -- 1149
		toColor(PALETTE.textDim), -- 1149
		0.5, -- 1149
		0.5, -- 1149
		"Center", -- 1149
		1.2, -- 1149
		0.84, -- 1149
		0.08 -- 1149
	) -- 1149
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1151
	if hit >= 0 then -- 1151
		self.settingsSelected = hit -- 1153
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1153
			return true -- 1155
		end -- 1155
		self:resetInput() -- 1157
		return false -- 1158
	end -- 1158
	if frame.keys.left or frame.prevTab then -- 1158
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1161
		if id ~= "back" then -- 1161
			applyDelta(id, -1) -- 1163
			self:resetInput() -- 1164
		end -- 1164
		return false -- 1166
	end -- 1166
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1166
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1169
		if applyDelta(id, 1) then -- 1169
			return true -- 1171
		end -- 1171
		self:resetInput() -- 1173
		return false -- 1174
	end -- 1174
	return false -- 1176
end -- 987
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1184
	if assistHintsEnabled == nil then -- 1184
		assistHintsEnabled = false -- 1195
	end -- 1195
	if safeUi == nil then -- 1195
		safeUi = ZERO_SAFE_INSETS -- 1197
	end -- 1197
	self.time = self.time + dt -- 1199
	local frame = self:readFrame(input, uiScale, safeUi) -- 1200
	if self.pauseShowControls then -- 1200
		local ctrlAct = self:drawControls( -- 1203
			frame, -- 1203
			uiDraw, -- 1203
			uiInkDraw, -- 1203
			uiArt, -- 1203
			uiGlow, -- 1203
			texts, -- 1203
			w, -- 1203
			h, -- 1203
			"返回暂停" -- 1203
		) -- 1203
		if ctrlAct.type == "backTitle" then -- 1203
			self.pauseShowControls = false -- 1205
			self:resetInput() -- 1206
		end -- 1206
		return {type = "none"} -- 1208
	end -- 1208
	if self.pauseShowSettings then -- 1208
		if self:drawPauseSettings( -- 1208
			frame, -- 1212
			input, -- 1212
			uiDraw, -- 1212
			uiInkDraw, -- 1212
			uiArt, -- 1212
			uiGlow, -- 1212
			texts, -- 1212
			w, -- 1212
			h -- 1212
		) then -- 1212
			self.pauseShowSettings = false -- 1213
			self:resetInput() -- 1214
		end -- 1214
		return {type = "none"} -- 1216
	end -- 1216
	if frame.back then -- 1216
		self.pauseShowControls = false -- 1220
		self.pauseShowSettings = false -- 1221
		self:emitSound("pauseClose") -- 1222
		return {type = "resume"} -- 1223
	end -- 1223
	local allowFs = canToggleFullscreen() -- 1226
	local allowQuit = canQuitApp() -- 1227
	local pauseItems = __TS__ArrayFilter( -- 1228
		PAUSE_ITEMS, -- 1228
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1228
	) -- 1228
	if self.pauseSelected >= #pauseItems then -- 1228
		self.pauseSelected = 0 -- 1232
	end -- 1232
	uiDraw:drawRect( -- 1235
		Rect(0, 0, w, h), -- 1235
		Color(8, 10, 16, 102) -- 1235
	) -- 1235
	fillHGradRect( -- 1236
		uiDraw, -- 1236
		0, -- 1236
		0, -- 1236
		w * 0.27 + frame.safe.left, -- 1236
		h, -- 1236
		Color(9, 11, 18, 232), -- 1236
		Color(10, 13, 21, 198) -- 1236
	) -- 1236
	fillHGradRect( -- 1237
		uiDraw, -- 1237
		w * 0.27 + frame.safe.left, -- 1237
		0, -- 1237
		w * 0.21, -- 1237
		h, -- 1237
		Color(10, 13, 21, 198), -- 1237
		Color(10, 13, 21, 0) -- 1237
	) -- 1237
	local menuX = 110 + frame.safe.left * 0.6 -- 1239
	local compact = #pauseItems > 8 -- 1240
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1241
	uiArt:tryPlace( -- 1242
		"ink_vstream", -- 1242
		"pause_vstream", -- 1242
		menuX - 32, -- 1242
		h * 0.5, -- 1242
		34, -- 1242
		h * 0.78, -- 1242
		{ -- 1242
			color = toColor(PALETTE.silkDim), -- 1243
			opacity = 0.48, -- 1243
			layer = 1 -- 1243
		} -- 1243
	) -- 1243
	drawMistCurve( -- 1245
		uiArt, -- 1245
		"pause_mist", -- 1245
		menuX + 118, -- 1245
		headY - 8, -- 1245
		290, -- 1245
		72, -- 1245
		PALETTE.jadeMist, -- 1245
		0.2, -- 1245
		-1 -- 1245
	) -- 1245
	texts:put( -- 1247
		"banner", -- 1247
		"暂歇", -- 1247
		menuX + 16, -- 1247
		headY, -- 1247
		toColor(PALETTE.textBright), -- 1247
		0, -- 1247
		0.5, -- 1247
		"Left", -- 1247
		10, -- 1247
		0.98, -- 1247
		0.1 -- 1247
	) -- 1247
	texts:put( -- 1248
		"xs", -- 1248
		"月夜暂驻 · 卷页留痕", -- 1248
		menuX + 18, -- 1248
		headY - 36, -- 1248
		toColor(PALETTE.textDim), -- 1248
		0, -- 1248
		0.5, -- 1248
		"Left", -- 1248
		2, -- 1248
		0.8, -- 1248
		0.08 -- 1248
	) -- 1248
	drawHairline( -- 1249
		uiInkDraw, -- 1249
		uiArt, -- 1249
		"pause_div", -- 1249
		menuX + 124, -- 1249
		headY - 60, -- 1249
		240, -- 1249
		PALETTE.silkDim, -- 1249
		0.58, -- 1249
		true, -- 1249
		2 -- 1249
	) -- 1249
	local rowStep = compact and 42 or 46 -- 1251
	local rowH = compact and 36 or 38 -- 1252
	local firstY = compact and headY - 112 or headY - 120 -- 1253
	local boxes = {} -- 1254
	local i = 0 -- 1255
	do -- 1255
		i = 0 -- 1256
		while i < #pauseItems do -- 1256
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1257
			i = i + 1 -- 1256
		end -- 1256
	end -- 1256
	local prevPauseSel = self.pauseSelected -- 1259
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1260
	if self.pauseSelected ~= prevPauseSel then -- 1260
		self:emitSound("hover") -- 1262
	end -- 1262
	do -- 1262
		i = 0 -- 1265
		while i < #pauseItems do -- 1265
			local iy = boxes[i + 1].y -- 1266
			local active = self.pauseSelected == i -- 1267
			local cy = iy + rowH * 0.5 -- 1268
			local shiftX = active and 10 or 0 -- 1269
			local item = pauseItems[i + 1] -- 1270
			local label = item.zh -- 1271
			if item.id == "assist" then -- 1271
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1273
			elseif item.id == "fullscreen" then -- 1273
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1275
			elseif item.id == "settings" then -- 1275
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1277
			end -- 1277
			if active then -- 1277
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
			i = i + 1 -- 1265
		end -- 1265
	end -- 1265
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
	if hit >= 0 or frame.keys.confirm then -- 1312
		local idx = hit >= 0 and hit or self.pauseSelected -- 1314
		local id = pauseItems[idx + 1].id -- 1315
		if id == "controls" then -- 1315
			self.pauseShowControls = true -- 1317
			self:emitSound("confirm") -- 1318
			self:resetInput() -- 1319
			return {type = "none"} -- 1320
		end -- 1320
		if id == "settings" then -- 1320
			self:openPauseSettings() -- 1323
			self:emitSound("confirm") -- 1324
			return {type = "none"} -- 1325
		end -- 1325
		if id == "assist" then -- 1325
			if onToggleAssist ~= nil then -- 1325
				onToggleAssist() -- 1329
			end -- 1329
			self:emitSound("toggle") -- 1331
			self:resetInput() -- 1332
			return {type = "none"} -- 1333
		end -- 1333
		if id == "fullscreen" then -- 1333
			self:emitSound("toggle") -- 1336
			self:resetInput() -- 1337
			return {type = "toggleFullscreen"} -- 1338
		end -- 1338
		self.pauseShowControls = false -- 1340
		self.pauseShowSettings = false -- 1341
		if id == "resume" then -- 1341
			self:emitSound("pauseClose") -- 1342
			return {type = "resume"} -- 1342
		end -- 1342
		if id == "retry" then -- 1342
			self:emitSound("confirm") -- 1343
			return {type = "retry"} -- 1343
		end -- 1343
		if id == "chapters" then -- 1343
			self:emitSound("confirm") -- 1344
			return {type = "openChapters"} -- 1344
		end -- 1344
		if id == "quit" then -- 1344
			self:emitSound("back") -- 1345
			return {type = "quit"} -- 1345
		end -- 1345
		self:emitSound("back") -- 1346
		return {type = "toTitle"} -- 1347
	end -- 1347
	return {type = "none"} -- 1349
end -- 1184
function MenuRenderer.prototype.drawEpilogue(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1356
	if frame.back then -- 1356
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
	if self.epilogueBothCleared then -- 1389
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
			if active then -- 1415
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
	if hit >= 0 or frame.keys.confirm then -- 1445
		local idx = hit >= 0 and hit or self.epilogueSelected -- 1447
		local id = items[idx + 1].id -- 1448
		if id == "history" then -- 1448
			return {type = "openHistory"} -- 1449
		end -- 1449
		if id == "replay" then -- 1449
			return {type = "replayStory"} -- 1450
		end -- 1450
		return {type = "backTitle"} -- 1451
	end -- 1451
	return {type = "none"} -- 1453
end -- 1356
function MenuRenderer.prototype.drawHistory(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 1460
	if frame.back then -- 1460
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1471
	end -- 1471
	local total = #HISTORY_CARDS -- 1474
	if frame.keys.left or frame.prevTab then -- 1474
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1476
	elseif frame.keys.right or frame.nextTab then -- 1476
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
	if not uiArt:tryPlace( -- 1491
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
		while ci < #src do -- 1522
			local b = __TS__StringCharCodeAt(src, ci) -- 1524
			local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 1525
			local ch = __TS__StringSlice(src, ci, ci + step) -- 1526
			local u = b < 128 and 0.56 or 1.02 -- 1527
			if units + u > maxUnits and buf ~= "" then -- 1527
				out[#out + 1] = buf -- 1529
				buf = ch -- 1530
				units = u -- 1531
			else -- 1531
				buf = buf .. ch -- 1533
				units = units + u -- 1534
			end -- 1534
			ci = ci + step -- 1536
		end -- 1536
		if buf ~= "" then -- 1536
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
	if drawNavBtn(prevBox, "prev", "上一篇") then -- 1568
		self.historyCardIndex = (self.historyCardIndex + total - 1) % total -- 1576
	end -- 1576
	if drawNavBtn(nextBox, "next", "下一篇") then -- 1576
		self.historyCardIndex = (self.historyCardIndex + 1) % total -- 1579
	end -- 1579
	if drawNavBtn(backBox, "back", self.historyFromEpilogue and "返回尾声" or "返回标题") then -- 1579
		return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1582
	end -- 1582
	if frame.keys.confirm then -- 1582
		if self.historyCardIndex + 1 < total then -- 1582
			self.historyCardIndex = self.historyCardIndex + 1 -- 1587
		else -- 1587
			return {type = self.historyFromEpilogue and "backEpilogue" or "backTitle"} -- 1589
		end -- 1589
	end -- 1589
	return {type = "none"} -- 1592
end -- 1460
return ____exports -- 1460