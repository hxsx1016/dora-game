-- [ts]: menus.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
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
local ____theme = require("Script.watch.fe.theme") -- 38
local PALETTE = ____theme.PALETTE -- 39
local drawBlossomDot = ____theme.drawBlossomDot -- 40
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 41
local drawHairline = ____theme.drawHairline -- 42
local drawLoneSeal = ____theme.drawLoneSeal -- 43
local drawMistCurve = ____theme.drawMistCurve -- 44
local drawSilkKeycap = ____theme.drawSilkKeycap -- 45
local drawSilkRibbon = ____theme.drawSilkRibbon -- 46
local drawSilkVeil = ____theme.drawSilkVeil -- 47
local fillHGradRect = ____theme.fillHGradRect -- 48
local fillRadialGlow = ____theme.fillRadialGlow -- 49
local fillVGradRect = ____theme.fillVGradRect -- 50
local themeOf = ____theme.themeOf -- 51
local toColor = ____theme.toColor -- 52
local visualTextWidth = ____theme.visualTextWidth -- 53
local TITLE_ITEMS = { -- 78
	{id = "start", zh = "开始游戏"}, -- 79
	{id = "chapters", zh = "选择章节"}, -- 80
	{id = "controls", zh = "操作说明"}, -- 81
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 82
	{id = "quit", zh = "退出游戏"} -- 83
} -- 83
local CHAPTERS = __TS__ArrayFilter( -- 87
	__TS__ArrayMap( -- 87
		ROOMS, -- 87
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 87
	), -- 87
	function(____, chapter) return chapter.room.key ~= "museum" end -- 88
) -- 88
local PAUSE_ITEMS = { -- 91
	{id = "resume", zh = "继续游戏"}, -- 92
	{id = "retry", zh = "重试检查点"}, -- 93
	{id = "controls", zh = "操作说明"}, -- 94
	{id = "assist", zh = "按键辅助：关"}, -- 95
	{id = "fullscreen", zh = "显示：窗口"}, -- 96
	{id = "chapters", zh = "选择章节"}, -- 97
	{id = "title", zh = "返回标题"}, -- 98
	{id = "quit", zh = "退出游戏"}, -- 99
	{id = "settings", zh = "操控设置"} -- 100
} -- 100
local SETTINGS_ROWS = { -- 103
	{id = "modePref", title = "操作模式"}, -- 104
	{id = "aimAssist", title = "瞄准磁吸"}, -- 105
	{id = "gpLayout", title = "手柄确认键"}, -- 106
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 107
	{id = "touchOpacity", title = "触控按键透度"}, -- 108
	{id = "touchScale", title = "触控按键大小"}, -- 109
	{id = "haptics", title = "触觉震动反馈"}, -- 110
	{id = "back", title = "返回暂歇菜单"} -- 111
} -- 111
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 114
local EPIGRAPH_RIGHT = { -- 115
	"城", -- 115
	"破", -- 115
	"那", -- 115
	"天", -- 115
	"", -- 115
	"他", -- 115
	"留", -- 115
	"下", -- 115
	"断", -- 115
	"后" -- 115
} -- 115
local EPIGRAPH_LEFT = { -- 116
	"她", -- 116
	"独", -- 116
	"自", -- 116
	"走", -- 116
	"向", -- 116
	"北", -- 116
	"塔" -- 116
} -- 116
local function pressedKeys() -- 141
	return { -- 142
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 143
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 144
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 145
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 146
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 147
	} -- 147
end -- 141
local function hitIndex(boxes, pointer, inside) -- 151
	if not inside then -- 151
		return -1 -- 153
	end -- 153
	return __TS__ArrayFindIndex( -- 155
		boxes, -- 155
		function(____, box) return box:containsPoint(pointer) end -- 155
	) -- 155
end -- 151
____exports.MenuRenderer = __TS__Class() -- 158
local MenuRenderer = ____exports.MenuRenderer -- 158
MenuRenderer.name = "MenuRenderer" -- 158
function MenuRenderer.prototype.____constructor(self) -- 158
	self.selected = 0 -- 159
	self.chapterSelected = 0 -- 160
	self.pauseSelected = 0 -- 161
	self.settingsSelected = 0 -- 162
	self.hasSession = false -- 164
	self.controlsTab = "kbm" -- 166
	self.chaptersFromPause = false -- 168
	self.pauseShowControls = false -- 169
	self.pauseShowSettings = false -- 170
	self.controlsTabManual = false -- 171
	self.previousKeys = {} -- 172
	self.queuedKeys = {} -- 173
	self.queuedBack = false -- 174
	self.queuedSkip = false -- 175
	self.splashTime = 0 -- 176
	self.time = 0 -- 177
end -- 158
function MenuRenderer.prototype.resetSplash(self) -- 179
	self.splashTime = 0 -- 180
	self.queuedSkip = false -- 181
	self:resetInput() -- 182
end -- 179
function MenuRenderer.prototype.isShowingPauseControls(self) -- 185
	return self.pauseShowControls -- 186
end -- 185
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 189
	return self.pauseShowSettings -- 190
end -- 189
function MenuRenderer.prototype.openPauseSettings(self) -- 193
	self.pauseShowControls = false -- 194
	self.pauseShowSettings = true -- 195
	self.settingsSelected = 0 -- 196
	self:resetInput() -- 197
end -- 193
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 200
	self.chaptersFromPause = roomIndex ~= nil -- 201
	self.chapterSelected = math.max( -- 202
		0, -- 202
		__TS__ArrayFindIndex( -- 202
			CHAPTERS, -- 202
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 202
		) -- 202
	) -- 202
	self.pauseShowControls = false -- 203
	self.pauseShowSettings = false -- 204
	self:resetInput() -- 205
end -- 200
function MenuRenderer.prototype.openPause(self) -- 208
	self.pauseSelected = 0 -- 209
	self.pauseShowControls = false -- 210
	self.pauseShowSettings = false -- 211
	self:resetInput() -- 212
end -- 208
function MenuRenderer.prototype.triggerBack(self) -- 216
	self.queuedBack = true -- 217
end -- 216
function MenuRenderer.prototype.resetInput(self) -- 221
	self.previousKeys = pressedKeys() -- 222
	self.queuedKeys = {} -- 223
	self.queuedBack = false -- 224
	self.queuedSkip = false -- 225
	self.controlsTabManual = false -- 226
end -- 221
function MenuRenderer.prototype.onKeyEvent(self, key) -- 230
	self.queuedSkip = true -- 231
	if key == "Up" or key == "W" then -- 231
		self.queuedKeys.up = true -- 233
	elseif key == "Down" or key == "S" then -- 233
		self.queuedKeys.down = true -- 235
	elseif key == "Left" or key == "A" then -- 235
		self.queuedKeys.left = true -- 237
	elseif key == "Right" or key == "D" then -- 237
		self.queuedKeys.right = true -- 239
	elseif key == "Return" or key == "Space" then -- 239
		self.queuedKeys.confirm = true -- 241
	elseif key == "Escape" then -- 241
		self.queuedBack = true -- 243
	end -- 243
end -- 230
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 247
	local held = pressedKeys() -- 248
	local prev = self.previousKeys -- 249
	local queued = self.queuedKeys -- 250
	local useUiPtr = input.uiInside or input.uiPressed -- 253
	local rawX = useUiPtr and input.uiX or input.mx -- 254
	local rawY = useUiPtr and input.uiY or input.my -- 255
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 256
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 257
	local ____useUiPtr_0 -- 258
	if useUiPtr then -- 258
		____useUiPtr_0 = input.uiInside -- 258
	else -- 258
		____useUiPtr_0 = input.inside -- 258
	end -- 258
	local inside = ____useUiPtr_0 -- 258
	local ____useUiPtr_1 -- 259
	if useUiPtr then -- 259
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 259
	else -- 259
		____useUiPtr_1 = input.inside and input.fire.pressed -- 259
	end -- 259
	local click = ____useUiPtr_1 -- 259
	local touchMode = input:isTouchMode() -- 260
	local frame = { -- 262
		keys = { -- 263
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 264
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 265
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 266
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 267
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 268
		}, -- 268
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 270
		prevTab = input.navPrevTab, -- 271
		nextTab = input.navNextTab, -- 272
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 273
		pointer = Vec2(rawX / scale, rawY / scale), -- 274
		inside = inside, -- 275
		click = click, -- 276
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 277
		mode = input.inputMode, -- 278
		layout = input.gamepadLayout, -- 279
		safe = safe -- 280
	} -- 280
	self.previousKeys = held -- 282
	self.queuedKeys = {} -- 283
	self.queuedBack = false -- 284
	self.queuedSkip = false -- 285
	return frame -- 286
end -- 247
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 289
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 290
	if frame.click and hit >= 0 then -- 290
		return hit -- 292
	end -- 292
	if frame.keys.up then -- 292
		return (selected + #boxes - 1) % #boxes -- 295
	end -- 295
	if frame.keys.down then -- 295
		return (selected + 1) % #boxes -- 298
	end -- 298
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 300
end -- 289
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 303
	if safeUi == nil then -- 303
		safeUi = ZERO_SAFE_INSETS -- 319
	end -- 319
	self.time = self.time + dt -- 321
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 322
	if screen ~= "splash" or splashDissolving then -- 322
		local artW = math.max(w, h * 16 / 9) -- 324
		local artH = artW * 9 / 16 -- 325
		if not backdropArt:tryPlace( -- 325
			"title_backdrop", -- 326
			"menu_landscape", -- 326
			w * 0.5, -- 326
			(h - artH) * 0.5, -- 326
			artW, -- 326
			artH -- 326
		) then -- 326
			stage:drawMenuBackdrop( -- 327
				bgDraw, -- 327
				bgGlow, -- 327
				w, -- 327
				h, -- 327
				self.time -- 327
			) -- 327
		end -- 327
	end -- 327
	local frame = self:readFrame(input, uiScale, safeUi) -- 331
	w = w / uiScale -- 332
	h = h / uiScale -- 333
	if screen == "splash" then -- 333
		return self:drawSplash( -- 336
			dt, -- 336
			frame, -- 336
			uiDraw, -- 336
			uiArt, -- 336
			texts, -- 336
			w, -- 336
			h -- 336
		) -- 336
	end -- 336
	if screen == "title" then -- 336
		return self:drawTitle( -- 339
			frame, -- 339
			uiDraw, -- 339
			uiInkDraw, -- 339
			uiArt, -- 339
			uiGlow, -- 339
			texts, -- 339
			w, -- 339
			h -- 339
		) -- 339
	end -- 339
	if screen == "chapters" then -- 339
		return self:drawChapters( -- 342
			frame, -- 342
			uiDraw, -- 342
			uiInkDraw, -- 342
			uiArt, -- 342
			uiGlow, -- 342
			texts, -- 342
			w, -- 342
			h -- 342
		) -- 342
	end -- 342
	return self:drawControls( -- 344
		frame, -- 344
		uiDraw, -- 344
		uiInkDraw, -- 344
		uiArt, -- 344
		uiGlow, -- 344
		texts, -- 344
		w, -- 344
		h -- 344
	) -- 344
end -- 303
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 353
	local safeDt = math.min( -- 362
		0.1, -- 362
		math.max(0, dt) -- 362
	) -- 362
	self.splashTime = self.splashTime + safeDt -- 363
	local t = self.splashTime -- 364
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 366
	if wantSkip or t >= 4.65 then -- 366
		self.splashTime = 0 -- 368
		return {type = "splashDone"} -- 369
	end -- 369
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 372
	local bgR = t < 2.2 and 13 or 11 -- 373
	local bgG = t < 2.2 and 16 or 13 -- 374
	local bgB = t < 2.2 and 24 or 19 -- 375
	uiDraw:drawRect( -- 376
		Rect(0, 0, w, h), -- 376
		Color( -- 376
			bgR, -- 376
			bgG, -- 376
			bgB, -- 376
			math.floor(255 * fadeOutCurtain + 0.5) -- 376
		) -- 376
	) -- 376
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 378
		if localT <= 0 or localT >= endT then -- 378
			return 0 -- 379
		end -- 379
		if localT < fadeIn then -- 379
			local u = localT / fadeIn -- 381
			return u * u * (3 - 2 * u) -- 382
		end -- 382
		if localT <= holdEnd then -- 382
			return 1 -- 384
		end -- 384
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 385
		return 1 - u * u * (3 - 2 * u) -- 386
	end -- 378
	if t < 2.2 then -- 378
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 390
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 391
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 392
		if not uiArt:tryPlace( -- 392
			"brand_team_logo", -- 393
			"splash_team_logo", -- 393
			w * 0.5, -- 393
			h * 0.54, -- 393
			logoH * 2, -- 393
			logoH, -- 393
			{opacity = alpha, layer = 2} -- 393
		) then -- 393
			texts:put( -- 394
				"banner", -- 394
				"OUTSIDER", -- 394
				w * 0.5, -- 394
				h * 0.52, -- 394
				toColor(PALETTE.textBright), -- 394
				0.5, -- 394
				0.5, -- 394
				"Center", -- 394
				6, -- 394
				alpha, -- 394
				0 -- 394
			) -- 394
		end -- 394
		texts:put( -- 396
			"xs", -- 396
			"Powered by Dora SSR", -- 396
			w * 0.5, -- 396
			58 + frame.safe.bottom * 0.4, -- 396
			toColor(PALETTE.textDim), -- 396
			0.5, -- 396
			0.5, -- 396
			"Center", -- 396
			1.8, -- 396
			alpha * 0.62, -- 396
			0 -- 396
		) -- 396
	elseif t < 4.25 then -- 396
		local localT = t - 2.2 -- 398
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 399
		local sway = math.sin(localT * 1.1) * 8 -- 400
		drawMistCurve( -- 401
			uiArt, -- 401
			"splash_game_mist", -- 401
			w * 0.5 + sway, -- 401
			h * 0.46, -- 401
			560, -- 401
			110, -- 401
			PALETTE.jadeMist, -- 401
			0.16 * alpha, -- 401
			1 -- 401
		) -- 401
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 402
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 403
		if not uiArt:tryPlace( -- 403
			"brand_game_logo_h", -- 404
			"splash_game_logo", -- 404
			w * 0.5, -- 404
			h * 0.52, -- 404
			logoH * 2.4, -- 404
			logoH, -- 404
			{opacity = alpha, layer = 2} -- 404
		) then -- 404
			texts:put( -- 405
				"title", -- 405
				"向西守望", -- 405
				w * 0.5, -- 405
				h * 0.52, -- 405
				toColor(PALETTE.textBright), -- 405
				0.5, -- 405
				0.5, -- 405
				"Center", -- 405
				8, -- 405
				alpha, -- 405
				0 -- 405
			) -- 405
		end -- 405
	end -- 405
	if t >= 0.35 and t < 4.15 then -- 405
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 410
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 411
		texts:put( -- 416
			"xs", -- 416
			skipText, -- 416
			w - 48 - frame.safe.right * 0.6, -- 416
			36 + frame.safe.bottom * 0.4, -- 416
			toColor(PALETTE.textDim), -- 416
			1, -- 416
			0.5, -- 416
			"Right", -- 416
			1.4, -- 416
			hintA, -- 416
			0 -- 416
		) -- 416
	end -- 416
	return {type = "none"} -- 419
end -- 353
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 422
	fillHGradRect( -- 432
		uiDraw, -- 432
		0, -- 432
		0, -- 432
		w * 0.22 + frame.safe.left * 0.5, -- 432
		h, -- 432
		Color(9, 11, 18, 192), -- 432
		Color(9, 11, 18, 116) -- 432
	) -- 432
	fillHGradRect( -- 433
		uiDraw, -- 433
		w * 0.22 + frame.safe.left * 0.5, -- 433
		0, -- 433
		w * 0.28, -- 433
		h, -- 433
		Color(9, 11, 18, 116), -- 433
		Color(9, 11, 18, 0) -- 433
	) -- 433
	fillVGradRect( -- 434
		uiDraw, -- 434
		0, -- 434
		0, -- 434
		w, -- 434
		78, -- 434
		Color(8, 10, 16, 138), -- 434
		Color(8, 10, 16, 0) -- 434
	) -- 434
	local extraH = math.max(0, h - 720) -- 436
	local titleX = 148 + frame.safe.left * 0.6 -- 437
	local topY = h - 104 - frame.safe.top * 0.4 -- 438
	local charStep = 66 -- 439
	local sway = math.sin(self.time * 0.7) * 5 -- 440
	drawMistCurve( -- 441
		uiArt, -- 441
		"title_mist_wisp", -- 441
		titleX + 86 + sway, -- 441
		topY - 122, -- 441
		340, -- 441
		82, -- 441
		PALETTE.jadeMist, -- 441
		0.2, -- 441
		-1 -- 441
	) -- 441
	uiArt:tryPlace( -- 442
		"ink_petal_mist", -- 442
		"title_petals", -- 442
		titleX + 12, -- 442
		topY - 102, -- 442
		230, -- 442
		210, -- 442
		{ -- 442
			color = toColor(PALETTE.inkMist), -- 443
			opacity = 0.4, -- 443
			layer = -1 -- 443
		} -- 443
	) -- 443
	local placedBrandTitle = uiArt:tryPlace( -- 447
		"brand_game_logo_v", -- 447
		"title_brand_v", -- 447
		titleX + 22, -- 447
		topY - 106, -- 447
		240, -- 447
		304, -- 447
		{opacity = 0.98, layer = 3} -- 447
	) -- 447
	if not placedBrandTitle then -- 447
		uiArt:tryPlace( -- 451
			"ink_vstream", -- 451
			"title_vstream", -- 451
			titleX - 48, -- 451
			topY - 100, -- 451
			34, -- 451
			290, -- 451
			{ -- 451
				color = toColor(PALETTE.silkDim), -- 452
				opacity = 0.48, -- 452
				layer = 1 -- 452
			} -- 452
		) -- 452
		local c = 0 -- 454
		do -- 454
			c = 0 -- 455
			while c < #VERTICAL_TITLE do -- 455
				texts:put( -- 456
					"title", -- 457
					VERTICAL_TITLE[c + 1], -- 458
					titleX, -- 459
					topY - c * charStep, -- 460
					toColor(PALETTE.textBright), -- 461
					0.5, -- 462
					0.5, -- 463
					"Center", -- 464
					0, -- 465
					0.98, -- 466
					0.1, -- 467
					Color(8, 10, 16, 210) -- 468
				) -- 468
				c = c + 1 -- 455
			end -- 455
		end -- 455
		drawLoneSeal( -- 471
			uiInkDraw, -- 472
			uiArt, -- 473
			texts, -- 474
			"title_lone_seal", -- 475
			titleX + 46, -- 476
			topY - 3 * charStep + 8, -- 477
			26, -- 478
			52, -- 479
			"守", -- 480
			"望", -- 481
			PALETTE.sealRed, -- 482
			PALETTE.sealText, -- 483
			0.94, -- 484
			4 -- 485
		) -- 485
	end -- 485
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 490
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 491
	local poemStep = 22 -- 492
	local p = 0 -- 493
	do -- 493
		p = 0 -- 494
		while p < #EPIGRAPH_RIGHT do -- 494
			local ch = EPIGRAPH_RIGHT[p + 1] -- 495
			if ch ~= "" then -- 495
				texts:put( -- 497
					"xs", -- 497
					ch, -- 497
					colRightX, -- 497
					topY - 22 - p * poemStep, -- 497
					toColor(PALETTE.textMid), -- 497
					0.5, -- 497
					0.5, -- 497
					"Center", -- 497
					0, -- 497
					0.86, -- 497
					0.08 -- 497
				) -- 497
			end -- 497
			p = p + 1 -- 494
		end -- 494
	end -- 494
	do -- 494
		p = 0 -- 500
		while p < #EPIGRAPH_LEFT do -- 500
			texts:put( -- 501
				"xs", -- 501
				EPIGRAPH_LEFT[p + 1], -- 501
				colLeftX, -- 501
				topY - 68 - p * poemStep, -- 501
				toColor(PALETTE.amberCore), -- 501
				0.5, -- 501
				0.5, -- 501
				"Center", -- 501
				0, -- 501
				0.9, -- 501
				0.08 -- 501
			) -- 501
			p = p + 1 -- 500
		end -- 500
	end -- 500
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 505
		TITLE_ITEMS, -- 507
		function(____, it) return it.id ~= "quit" end -- 507
	) -- 507
	local items = self.hasSession and ({ -- 508
		{id = "continue", zh = "继续游戏"}, -- 509
		table.unpack(baseItems) -- 509
	}) or baseItems -- 509
	if self.selected >= #items then -- 509
		self.selected = 0 -- 512
	end -- 512
	local menuX = 112 + frame.safe.left * 0.6 -- 514
	local btnW = 280 -- 515
	local btnH = frame.mode == "touch" and 44 or 40 -- 516
	local gap = self.hasSession and 6 or 8 -- 517
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 518
	local boxes = {} -- 519
	local i = 0 -- 520
	do -- 520
		i = 0 -- 521
		while i < #items do -- 521
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 522
			i = i + 1 -- 521
		end -- 521
	end -- 521
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 524
	do -- 524
		i = 0 -- 526
		while i < #items do -- 526
			local by = boxes[i + 1].y -- 527
			local active = self.selected == i -- 528
			local cy = by + btnH * 0.5 -- 529
			local shiftX = active and 10 or 0 -- 530
			if active then -- 530
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 533
				drawSilkRibbon( -- 534
					uiDraw, -- 534
					uiArt, -- 534
					"title_rib_red_" .. tostring(i), -- 534
					menuX + 124, -- 534
					cy, -- 534
					290, -- 534
					btnH, -- 534
					PALETTE.rougeSoft, -- 534
					0.52 * breathe, -- 534
					0 -- 534
				) -- 534
				drawHairline( -- 535
					uiInkDraw, -- 535
					uiArt, -- 535
					"title_rib_line_" .. tostring(i), -- 535
					menuX + 114, -- 535
					by + 4, -- 535
					230, -- 535
					PALETTE.silkLine, -- 535
					0.42 * breathe, -- 535
					false, -- 535
					2 -- 535
				) -- 535
				drawBlossomDot( -- 536
					uiInkDraw, -- 536
					uiArt, -- 536
					"title_dot_" .. tostring(i), -- 536
					menuX + 14, -- 536
					cy, -- 536
					16, -- 536
					PALETTE.rouge, -- 536
					0.96, -- 536
					4 -- 536
				) -- 536
				fillRadialGlow( -- 537
					uiGlow, -- 537
					menuX + 14, -- 537
					cy, -- 537
					22, -- 537
					16, -- 537
					toColor(PALETTE.rouge, 28 * breathe), -- 537
					Color(182, 58, 56, 0), -- 537
					10 -- 537
				) -- 537
			else -- 537
				drawBlossomDot( -- 539
					uiInkDraw, -- 539
					uiArt, -- 539
					"title_dot_" .. tostring(i), -- 539
					menuX + 14, -- 539
					cy, -- 539
					8, -- 539
					PALETTE.silkDim, -- 539
					0.4, -- 539
					3 -- 539
				) -- 539
			end -- 539
			texts:put( -- 542
				"md", -- 543
				items[i + 1].zh, -- 544
				menuX + 34 + shiftX, -- 545
				cy, -- 546
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 547
				0, -- 548
				0.5, -- 549
				"Left", -- 550
				active and 4.4 or 2.8, -- 551
				active and 1 or 0.88, -- 552
				0.1 -- 553
			) -- 553
			i = i + 1 -- 526
		end -- 526
	end -- 526
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 557
	texts:put( -- 564
		"xs", -- 564
		titleHint, -- 564
		menuX + 12, -- 564
		42 + frame.safe.bottom * 0.45, -- 564
		toColor(PALETTE.textDim), -- 564
		0, -- 564
		0.5, -- 564
		"Left", -- 564
		1.4, -- 564
		0.88, -- 564
		0.08 -- 564
	) -- 564
	local badgeRight = w - frame.safe.right * 0.5 -- 567
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 568
	fillHGradRect( -- 569
		uiDraw, -- 569
		badgeRight - 270, -- 569
		0, -- 569
		270 + frame.safe.right * 0.5, -- 569
		86, -- 569
		Color(8, 10, 16, 0), -- 569
		Color(8, 10, 16, 204) -- 569
	) -- 569
	uiArt:tryPlace( -- 570
		"brand_team_badge", -- 570
		"title_team_badge", -- 570
		badgeRight - 118, -- 570
		badgeY, -- 570
		168, -- 570
		54, -- 570
		{opacity = 0.95, layer = 3} -- 570
	) -- 570
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 574
	if hit >= 0 or frame.keys.confirm then -- 574
		local idx = hit >= 0 and hit or self.selected -- 576
		local id = items[idx + 1].id -- 577
		if id == "continue" then -- 577
			return {type = "continue"} -- 578
		end -- 578
		if id == "trial" then -- 578
			return {type = "trial"} -- 579
		end -- 579
		if id == "start" then -- 579
			return {type = "start"} -- 580
		end -- 580
		if id == "chapters" then -- 580
			return {type = "openChapters"} -- 581
		end -- 581
		if id == "quit" then -- 581
			return {type = "quit"} -- 582
		end -- 582
		return {type = "openControls"} -- 583
	end -- 583
	return {type = "none"} -- 585
end -- 422
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 588
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 598
	if frame.back then -- 598
		return back -- 600
	end -- 600
	local extraH = math.max(0, h - 720) -- 603
	local marginX = math.max( -- 604
		96, -- 604
		56 + math.max(frame.safe.left, frame.safe.right) -- 604
	) -- 604
	local splitTrack = #CHAPTERS > 8 -- 605
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 606
	local trackY = (splitTrack and 195 or 148) + extraH * 0.25 -- 607
	local rowGap = 84 -- 608
	local trackX0 = marginX + 34 -- 609
	local trackX1 = w - marginX - 34 -- 610
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 611
	local stationBoxes = {} -- 613
	local s = 0 -- 614
	do -- 614
		s = 0 -- 615
		while s < #CHAPTERS do -- 615
			local sx = trackX0 + s % perRow * stepX -- 616
			local sy = trackY - math.floor(s / perRow) * rowGap -- 617
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74) -- 618
			s = s + 1 -- 615
		end -- 615
	end -- 615
	local prevSelected = self.chapterSelected -- 621
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 622
	local keys = frame.keys -- 623
	if frame.click and hitStation >= 0 then -- 623
		self.chapterSelected = hitStation -- 625
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 625
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 627
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 628
	elseif keys.down and self.chapterSelected < perRow then -- 628
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 630
	elseif keys.up and self.chapterSelected >= perRow then -- 630
		self.chapterSelected = self.chapterSelected - perRow -- 632
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 632
		self.chapterSelected = hitStation -- 634
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
		548, -- 647
		math.max(420, w * 0.43) -- 647
	) -- 647
	local winH = 300 -- 648
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
	local infoX = winX + winW + 46 -- 667
	local infoCenterY = winY + winH * 0.5 -- 668
	drawMistCurve( -- 669
		uiArt, -- 669
		"chap_info_mist", -- 669
		infoX + 210, -- 669
		infoCenterY + 36, -- 669
		420, -- 669
		88, -- 669
		theme.accent, -- 669
		0.22, -- 669
		-1 -- 669
	) -- 669
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 671
	texts:put( -- 672
		"xs", -- 672
		theme.volumeTagZh, -- 672
		infoX, -- 672
		winY + winH - 44, -- 672
		toColor(volCol), -- 672
		0, -- 672
		0.5, -- 672
		"Left", -- 672
		2.8, -- 672
		0.92, -- 672
		0.08 -- 672
	) -- 672
	local sep = " · " -- 674
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 675
	local titleY = winY + winH - 98 -- 676
	if theme.backdropKey ~= nil then -- 676
		texts:put( -- 678
			"lg", -- 678
			theme.titleZh, -- 678
			infoX, -- 678
			titleY, -- 678
			toColor(PALETTE.textBright) -- 678
		) -- 678
	elseif sIdx > 0 then -- 678
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 680
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 681
		local lw = visualTextWidth(leftPart, 40) -- 682
		texts:put( -- 683
			"banner", -- 683
			leftPart, -- 683
			infoX, -- 683
			titleY, -- 683
			toColor(PALETTE.textBright), -- 683
			0, -- 683
			0.5, -- 683
			"Left", -- 683
			2, -- 683
			1, -- 683
			0.1 -- 683
		) -- 683
		drawBlossomDot( -- 684
			uiInkDraw, -- 684
			uiArt, -- 684
			"chap_title_dot", -- 684
			infoX + lw + 16, -- 684
			titleY - 2, -- 684
			11, -- 684
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 684
			0.9, -- 684
			4 -- 684
		) -- 684
		texts:put( -- 685
			"banner", -- 685
			rightPart, -- 685
			infoX + lw + 32, -- 685
			titleY, -- 685
			toColor(PALETTE.textBright), -- 685
			0, -- 685
			0.5, -- 685
			"Left", -- 685
			2, -- 685
			1, -- 685
			0.1 -- 685
		) -- 685
	else -- 685
		texts:put( -- 687
			"banner", -- 687
			theme.titleZh, -- 687
			infoX, -- 687
			titleY, -- 687
			toColor(PALETTE.textBright), -- 687
			0, -- 687
			0.5, -- 687
			"Left", -- 687
			2.4, -- 687
			1, -- 687
			0.1 -- 687
		) -- 687
	end -- 687
	drawHairline( -- 690
		uiInkDraw, -- 690
		uiArt, -- 690
		"chap_info_line", -- 690
		infoX + 185, -- 690
		titleY - 36, -- 690
		370, -- 690
		PALETTE.silkDim, -- 690
		0.58, -- 690
		false, -- 690
		2 -- 690
	) -- 690
	texts:put( -- 691
		"sm", -- 691
		theme.introWhisper, -- 691
		infoX, -- 691
		titleY - 72, -- 691
		toColor(PALETTE.textMid), -- 691
		0, -- 691
		0.5, -- 691
		"Left", -- 691
		0.8, -- 691
		0.94, -- 691
		0.08 -- 691
	) -- 691
	local goX = infoX -- 693
	local goY = winY + 26 -- 694
	local goW = 220 -- 695
	local goH = 42 -- 696
	local goBox = Rect(goX, goY, goW, goH) -- 697
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 698
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 699
	drawSilkRibbon( -- 700
		uiDraw, -- 700
		uiArt, -- 700
		"chap_go_rib", -- 700
		goX + 106, -- 700
		goY + 21, -- 700
		250, -- 700
		40, -- 700
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 700
		(goHover and 0.68 or 0.46) * breathe, -- 700
		0 -- 700
	) -- 700
	drawHairline( -- 701
		uiInkDraw, -- 701
		uiArt, -- 701
		"chap_go_line", -- 701
		goX + 94, -- 701
		goY + 3, -- 701
		196, -- 701
		PALETTE.silkLine, -- 701
		goHover and 0.68 or 0.4, -- 701
		false, -- 701
		2 -- 701
	) -- 701
	drawBlossomDot( -- 702
		uiInkDraw, -- 702
		uiArt, -- 702
		"chap_go_dot", -- 702
		goX + 14, -- 702
		goY + 21, -- 702
		14, -- 702
		PALETTE.rouge, -- 702
		0.96, -- 702
		4 -- 702
	) -- 702
	texts:put( -- 703
		"md", -- 703
		"入此卷章", -- 703
		goX + 34, -- 703
		goY + 21, -- 703
		toColor(PALETTE.textBright), -- 703
		0, -- 703
		0.5, -- 703
		"Left", -- 703
		3.8, -- 703
		1, -- 703
		0.1 -- 703
	) -- 703
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 704
	texts:put( -- 707
		"xs", -- 707
		chapConfirmTag, -- 707
		goX + 156, -- 707
		goY + 21, -- 707
		toColor(PALETTE.textDim), -- 707
		0, -- 707
		0.5, -- 707
		"Left", -- 707
		1, -- 707
		0.82, -- 707
		0.08 -- 707
	) -- 707
	drawSilkVeil( -- 709
		uiDraw, -- 709
		uiArt, -- 709
		"chap_track_veil", -- 709
		w * 0.5, -- 709
		trackY + 6, -- 709
		w - marginX * 1.1, -- 709
		126, -- 709
		PALETTE.inkWash, -- 709
		0.72, -- 709
		-2 -- 709
	) -- 709
	drawMistCurve( -- 710
		uiArt, -- 710
		"chap_track_mist", -- 710
		w * 0.5, -- 710
		trackY, -- 710
		trackX1 - trackX0 + 160, -- 710
		74, -- 710
		PALETTE.inkMist, -- 710
		0.62, -- 710
		-1 -- 710
	) -- 710
	uiInkDraw:drawSegment( -- 711
		Vec2(trackX0, trackY), -- 711
		Vec2(trackX1, trackY), -- 711
		0.9, -- 711
		toColor(PALETTE.silkDim, 145) -- 711
	) -- 711
	if splitTrack then -- 711
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 714
		uiInkDraw:drawSegment( -- 715
			Vec2(trackX0, trackY - rowGap), -- 715
			Vec2(lastX, trackY - rowGap), -- 715
			0.9, -- 715
			toColor(PALETTE.silkDim, 145) -- 715
		) -- 715
	else -- 715
		local midDivX = trackX0 + stepX * 3.5 -- 717
		uiInkDraw:drawSegment( -- 718
			Vec2(midDivX, trackY - 12), -- 718
			Vec2(midDivX, trackY + 12), -- 718
			0.8, -- 718
			toColor(PALETTE.silkDim, 120) -- 718
		) -- 718
		texts:put( -- 719
			"xs", -- 719
			"上卷 · 孤城护童", -- 719
			trackX0 + stepX * 1.5, -- 719
			trackY + 52, -- 719
			toColor(PALETTE.cyan), -- 719
			0.5, -- 719
			0.5, -- 719
			"Center", -- 719
			2.2, -- 719
			0.88, -- 719
			0.08 -- 719
		) -- 719
		texts:put( -- 720
			"xs", -- 720
			"下卷 · 独赴北塔", -- 720
			trackX0 + stepX * 5.5, -- 720
			trackY + 52, -- 720
			toColor(PALETTE.amber), -- 720
			0.5, -- 720
			0.5, -- 720
			"Center", -- 720
			2.2, -- 720
			0.88, -- 720
			0.08 -- 720
		) -- 720
	end -- 720
	local i = 0 -- 723
	do -- 723
		i = 0 -- 724
		while i < #CHAPTERS do -- 724
			local box = stationBoxes[i + 1] -- 725
			local sx = box.x + box.width * 0.5 -- 726
			local sy = box.y + box.height * 0.5 -- 727
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 728
			local active = self.chapterSelected == i -- 729
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 730
			if active then -- 730
				fillRadialGlow( -- 733
					uiGlow, -- 733
					sx, -- 733
					sy, -- 733
					26, -- 733
					26, -- 733
					toColor(PALETTE.rouge, 36 * breathe), -- 733
					Color(182, 58, 56, 0), -- 733
					12 -- 733
				) -- 733
				uiArt:tryPlace( -- 734
					"ink_enso_fine", -- 734
					"chap_st_ring_" .. tostring(i), -- 734
					sx, -- 734
					sy, -- 734
					32, -- 734
					32, -- 734
					{ -- 734
						color = toColor(PALETTE.silkLine), -- 735
						opacity = 0.78, -- 735
						angle = self.time * 18, -- 735
						layer = 3 -- 735
					} -- 735
				) -- 735
				drawBlossomDot( -- 737
					uiInkDraw, -- 737
					uiArt, -- 737
					"chap_st_dot_" .. tostring(i), -- 737
					sx, -- 737
					sy, -- 737
					17, -- 737
					PALETTE.rouge, -- 737
					0.98, -- 737
					4 -- 737
				) -- 737
			else -- 737
				uiArt:tryPlace( -- 739
					"ink_enso_fine", -- 739
					"chap_st_ring_" .. tostring(i), -- 739
					sx, -- 739
					sy, -- 739
					16, -- 739
					16, -- 739
					{ -- 739
						color = toColor(nodeCol), -- 740
						opacity = 0.62, -- 740
						layer = 3 -- 740
					} -- 740
				) -- 740
				drawBlossomDot( -- 742
					uiInkDraw, -- 742
					uiArt, -- 742
					"chap_st_dot_" .. tostring(i), -- 742
					sx, -- 742
					sy, -- 742
					7, -- 742
					PALETTE.silkLine, -- 742
					0.72, -- 742
					4 -- 742
				) -- 742
			end -- 742
			if not splitTrack then -- 742
				texts:put( -- 746
					"xs", -- 746
					rt.numeralZh, -- 746
					sx, -- 746
					sy + 25, -- 746
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 746
					0.5, -- 746
					0.5, -- 746
					"Center", -- 746
					0, -- 746
					active and 1 or 0.88, -- 746
					0.08 -- 746
				) -- 746
			end -- 746
			texts:put( -- 748
				"xs", -- 748
				rt.shortNameZh, -- 748
				sx, -- 748
				sy - 26, -- 748
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 748
				0.5, -- 748
				0.5, -- 748
				"Center", -- 748
				1, -- 748
				active and 1 or 0.84, -- 748
				0.08 -- 748
			) -- 748
			i = i + 1 -- 724
		end -- 724
	end -- 724
	local backX = marginX -- 751
	local backY = 40 + frame.safe.bottom * 0.45 -- 752
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 753
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 754
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 755
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 758
	drawSilkKeycap( -- 763
		uiInkDraw, -- 763
		texts, -- 763
		backX, -- 763
		backY + 5, -- 763
		48, -- 763
		24, -- 763
		chapBackTag, -- 763
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 763
		0.92, -- 763
		backHover -- 763
	) -- 763
	texts:put( -- 764
		"sm", -- 764
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 764
		backX + 60, -- 764
		backY + 17, -- 764
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 764
		0, -- 764
		0.5, -- 764
		"Left", -- 764
		1.8, -- 764
		0.9, -- 764
		0.08 -- 764
	) -- 764
	texts:put( -- 765
		"xs", -- 765
		chapFooter, -- 765
		w - marginX, -- 765
		backY + 17, -- 765
		toColor(PALETTE.textDim), -- 765
		1, -- 765
		0.5, -- 765
		"Right", -- 765
		1.2, -- 765
		0.75, -- 765
		0.08 -- 765
	) -- 765
	if frame.click and backHover then -- 765
		return back -- 768
	end -- 768
	local ____temp_2 -- 771
	if frame.mode == "touch" then -- 771
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 772
	else -- 772
		____temp_2 = hitStation >= 0 -- 773
	end -- 773
	local stationConfirmed = ____temp_2 -- 771
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 771
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 775
	end -- 775
	return {type = "none"} -- 777
end -- 588
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 781
	if backLabel == nil then -- 781
		backLabel = "返回标题" -- 790
	end -- 790
	if not self.controlsTabManual then -- 790
		self.controlsTab = frame.mode -- 793
	end -- 793
	local tabOrder = {"kbm", "gamepad", "touch"} -- 795
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 796
	local marginX = math.max( -- 797
		96, -- 797
		56 + math.max(frame.safe.left, frame.safe.right) -- 797
	) -- 797
	local tabW = 92 -- 798
	local tabH = 28 -- 799
	local tabGap = 10 -- 800
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 801
	local tabY = h - 82 - frame.safe.top * 0.35 -- 802
	local tabBoxes = { -- 803
		Rect(tabStartX, tabY, tabW, tabH), -- 804
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 805
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 806
	} -- 806
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 809
	if frame.click and hitTab >= 0 then -- 809
		self.controlsTab = tabOrder[hitTab + 1] -- 811
		self.controlsTabManual = true -- 812
	elseif frame.keys.left or frame.prevTab then -- 812
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 814
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 815
		self.controlsTabManual = true -- 816
	elseif frame.keys.right or frame.nextTab then -- 816
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 818
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 819
		self.controlsTabManual = true -- 820
	end -- 820
	local backX = marginX -- 823
	local backY = 40 + frame.safe.bottom * 0.45 -- 824
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 825
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 826
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 826
		return {type = "backTitle"} -- 828
	end -- 828
	uiDraw:drawRect( -- 830
		Rect(0, 0, w, h), -- 830
		Color(10, 12, 19, 204) -- 830
	) -- 830
	local guide = controlsGuideRows(self.controlsTab) -- 832
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 833
	texts:put( -- 834
		"banner", -- 834
		"执器要诀", -- 834
		marginX, -- 834
		topHeadY, -- 834
		toColor(PALETTE.textBright), -- 834
		0, -- 834
		0.5, -- 834
		"Left", -- 834
		4.5, -- 834
		0.96, -- 834
		0.1 -- 834
	) -- 834
	texts:put( -- 835
		"xs", -- 835
		guide.subtitle, -- 835
		marginX + 196, -- 835
		topHeadY - 4, -- 835
		toColor(PALETTE.textDim), -- 835
		0, -- 835
		0.5, -- 835
		"Left", -- 835
		1.8, -- 835
		0.85, -- 835
		0.08 -- 835
	) -- 835
	drawHairline( -- 836
		uiInkDraw, -- 836
		uiArt, -- 836
		"ctrl_top_line", -- 836
		w * 0.5, -- 836
		topHeadY - 34, -- 836
		w - marginX * 2, -- 836
		PALETTE.silkDim, -- 836
		0.6, -- 836
		true, -- 836
		2 -- 836
	) -- 836
	local ti = 0 -- 838
	do -- 838
		ti = 0 -- 839
		while ti < #tabBoxes do -- 839
			local tb = tabBoxes[ti + 1] -- 840
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 841
			local hoverTab = hitTab == ti -- 842
			uiInkDraw:drawRect( -- 843
				tb, -- 844
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 845
				0.9, -- 846
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 847
			) -- 847
			texts:put( -- 849
				"xs", -- 850
				tabLabels[ti + 1], -- 851
				tb.x + tb.width * 0.5, -- 852
				tb.y + tb.height * 0.5, -- 853
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 854
				0.5, -- 855
				0.5, -- 856
				"Center", -- 857
				0.8, -- 858
				activeTab and 0.98 or 0.82, -- 859
				0.08 -- 860
			) -- 860
			ti = ti + 1 -- 839
		end -- 839
	end -- 839
	local extraH = math.max(0, h - 720) -- 864
	local areaY = 114 + frame.safe.bottom * 0.4 -- 865
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 866
	drawFiligreeCorners( -- 867
		uiInkDraw, -- 867
		uiArt, -- 867
		"ctrl_outer", -- 867
		marginX, -- 867
		areaY, -- 867
		w - marginX * 2, -- 867
		areaH, -- 867
		PALETTE.silkDim, -- 867
		0.52, -- 867
		34, -- 867
		false, -- 867
		2 -- 867
	) -- 867
	local midX = w * 0.5 -- 869
	uiArt:tryPlace( -- 870
		"ink_vstream", -- 870
		"ctrl_mid_stream", -- 870
		midX, -- 870
		areaY + areaH * 0.5, -- 870
		32, -- 870
		areaH - 18, -- 870
		{ -- 870
			color = toColor(PALETTE.silkDim), -- 871
			opacity = 0.52, -- 871
			layer = 1 -- 871
		} -- 871
	) -- 871
	drawBlossomDot( -- 873
		uiInkDraw, -- 873
		uiArt, -- 873
		"ctrl_mid_dot", -- 873
		midX, -- 873
		areaY + areaH * 0.5, -- 873
		11, -- 873
		PALETTE.silkLine, -- 873
		0.62, -- 873
		3 -- 873
	) -- 873
	local leftColX = marginX + 34 -- 875
	local colW = midX - leftColX - 42 -- 876
	local headY = areaY + areaH - 34 -- 877
	local rowStep = 52 + extraH * 0.08 -- 878
	drawBlossomDot( -- 880
		uiInkDraw, -- 880
		uiArt, -- 880
		"ctrl_l_dot", -- 880
		leftColX + 8, -- 880
		headY, -- 880
		12, -- 880
		PALETTE.cyan, -- 880
		0.88, -- 880
		3 -- 880
	) -- 880
	texts:put( -- 881
		"md", -- 881
		"周戍 · 护送与交锋", -- 881
		leftColX + 26, -- 881
		headY, -- 881
		toColor(PALETTE.cyanCore), -- 881
		0, -- 881
		0.5, -- 881
		"Left", -- 881
		2.4, -- 881
		0.98, -- 881
		0.08 -- 881
	) -- 881
	drawHairline( -- 882
		uiInkDraw, -- 882
		uiArt, -- 882
		"ctrl_l_line", -- 882
		leftColX + colW * 0.5, -- 882
		headY - 24, -- 882
		colW, -- 882
		PALETTE.cyanDim, -- 882
		0.58, -- 882
		false, -- 882
		2 -- 882
	) -- 882
	local i = 0 -- 884
	do -- 884
		i = 0 -- 885
		while i < #guide.soldierRows do -- 885
			local ry = headY - 66 - i * rowStep -- 886
			drawSilkKeycap( -- 887
				uiInkDraw, -- 887
				texts, -- 887
				leftColX + 2, -- 887
				ry - 13, -- 887
				136, -- 887
				26, -- 887
				guide.soldierRows[i + 1][1], -- 887
				PALETTE.cyan, -- 887
				0.92, -- 887
				false -- 887
			) -- 887
			texts:put( -- 888
				"sm", -- 888
				guide.soldierRows[i + 1][2], -- 888
				leftColX + 152, -- 888
				ry, -- 888
				toColor(PALETTE.textBright), -- 888
				0, -- 888
				0.5, -- 888
				"Left", -- 888
				0.8, -- 888
				0.92, -- 888
				0.08 -- 888
			) -- 888
			i = i + 1 -- 885
		end -- 885
	end -- 885
	local rightColX = midX + 44 -- 891
	drawBlossomDot( -- 892
		uiInkDraw, -- 892
		uiArt, -- 892
		"ctrl_r_dot", -- 892
		rightColX + 8, -- 892
		headY, -- 892
		12, -- 892
		PALETTE.amber, -- 892
		0.88, -- 892
		3 -- 892
	) -- 892
	texts:put( -- 893
		"md", -- 893
		"小满 · 潜行与寻路", -- 893
		rightColX + 26, -- 893
		headY, -- 893
		toColor(PALETTE.amberCore), -- 893
		0, -- 893
		0.5, -- 893
		"Left", -- 893
		2.4, -- 893
		0.98, -- 893
		0.08 -- 893
	) -- 893
	drawHairline( -- 894
		uiInkDraw, -- 894
		uiArt, -- 894
		"ctrl_r_line", -- 894
		rightColX + colW * 0.5, -- 894
		headY - 24, -- 894
		colW, -- 894
		PALETTE.amberDim, -- 894
		0.58, -- 894
		false, -- 894
		2 -- 894
	) -- 894
	do -- 894
		i = 0 -- 896
		while i < #guide.childRows do -- 896
			local ry = headY - 66 - i * rowStep -- 897
			drawSilkKeycap( -- 898
				uiInkDraw, -- 898
				texts, -- 898
				rightColX + 2, -- 898
				ry - 13, -- 898
				136, -- 898
				26, -- 898
				guide.childRows[i + 1][1], -- 898
				PALETTE.amber, -- 898
				0.92, -- 898
				false -- 898
			) -- 898
			texts:put( -- 899
				"sm", -- 899
				guide.childRows[i + 1][2], -- 899
				rightColX + 152, -- 899
				ry, -- 899
				toColor(PALETTE.textBright), -- 899
				0, -- 899
				0.5, -- 899
				"Left", -- 899
				0.8, -- 899
				0.92, -- 899
				0.08 -- 899
			) -- 899
			i = i + 1 -- 896
		end -- 896
	end -- 896
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 902
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 905
	local keyW = frame.mode == "touch" and 76 or 110 -- 910
	drawSilkKeycap( -- 911
		uiInkDraw, -- 911
		texts, -- 911
		backX, -- 911
		backY + 5, -- 911
		keyW, -- 911
		24, -- 911
		ctrlBackKey, -- 911
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 911
		0.92, -- 911
		backHover -- 911
	) -- 911
	texts:put( -- 912
		"sm", -- 912
		backLabel, -- 912
		backX + keyW + 12, -- 912
		backY + 17, -- 912
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 912
		0, -- 912
		0.5, -- 912
		"Left", -- 912
		1.8, -- 912
		0.92, -- 912
		0.08 -- 912
	) -- 912
	texts:put( -- 913
		"xs", -- 913
		ctrlRightHint, -- 913
		w - marginX, -- 913
		backY + 17, -- 913
		toColor(PALETTE.textDim), -- 913
		1, -- 913
		0.5, -- 913
		"Right", -- 913
		1.2, -- 913
		0.78, -- 913
		0.08 -- 913
	) -- 913
	return {type = "none"} -- 915
end -- 781
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 919
	if frame.back then -- 919
		return true -- 931
	end -- 931
	local caps = getPlatformCaps() -- 934
	local s = input.settings -- 935
	uiDraw:drawRect( -- 937
		Rect(0, 0, w, h), -- 937
		Color(10, 12, 19, 206) -- 937
	) -- 937
	local marginX = math.max( -- 939
		96, -- 939
		56 + math.max(frame.safe.left, frame.safe.right) -- 939
	) -- 939
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 940
	texts:put( -- 941
		"banner", -- 941
		"操控设置", -- 941
		marginX, -- 941
		topHeadY, -- 941
		toColor(PALETTE.textBright), -- 941
		0, -- 941
		0.5, -- 941
		"Left", -- 941
		4.5, -- 941
		0.96, -- 941
		0.1 -- 941
	) -- 941
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 全平台支持键鼠 / 触屏 / 手柄" -- 942
	texts:put( -- 943
		"xs", -- 943
		curSummary, -- 943
		marginX + 196, -- 943
		topHeadY - 4, -- 943
		toColor(PALETTE.amberCore), -- 943
		0, -- 943
		0.5, -- 943
		"Left", -- 943
		1.4, -- 943
		0.88, -- 943
		0.08 -- 943
	) -- 943
	drawHairline( -- 944
		uiInkDraw, -- 944
		uiArt, -- 944
		"set_top_line", -- 944
		w * 0.5, -- 944
		topHeadY - 34, -- 944
		w - marginX * 2, -- 944
		PALETTE.silkDim, -- 944
		0.6, -- 944
		true, -- 944
		2 -- 944
	) -- 944
	local panelW = math.min(760, w - marginX * 2) -- 946
	local panelX = (w - panelW) * 0.5 -- 947
	local rowH = 44 -- 948
	local rowStep = 50 -- 949
	local firstY = topHeadY - 104 -- 950
	local boxes = {} -- 952
	local i = 0 -- 953
	do -- 953
		i = 0 -- 954
		while i < #SETTINGS_ROWS do -- 954
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 955
			i = i + 1 -- 954
		end -- 954
	end -- 954
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 957
	local function applyDelta(rowId, delta) -- 959
		if rowId == "back" then -- 959
			return true -- 961
		end -- 961
		if rowId == "modePref" then -- 961
			input:cycleModePref(delta) -- 964
		elseif rowId == "aimAssist" then -- 964
			s.aimAssist = not s.aimAssist -- 966
			saveControlSettings(s) -- 967
		elseif rowId == "gpLayout" then -- 967
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 969
			input.gamepadLayout = s.gamepadLayout -- 970
			saveControlSettings(s) -- 971
		elseif rowId == "crouchMode" then -- 971
			s.crouchToggle = not s.crouchToggle -- 973
			saveControlSettings(s) -- 974
		elseif rowId == "touchOpacity" then -- 974
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 976
			saveControlSettings(s) -- 977
		elseif rowId == "touchScale" then -- 977
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 979
			saveControlSettings(s) -- 980
		elseif rowId == "haptics" then -- 980
			s.haptics = not s.haptics -- 982
			saveControlSettings(s) -- 983
			if s.haptics then -- 983
				local ____opt_3 = input:getTouch() -- 983
				if ____opt_3 ~= nil then -- 983
					____opt_3:vibrate(0.018) -- 985
				end -- 985
			end -- 985
		end -- 985
		return false -- 988
	end -- 959
	local function valueTextOf(rowId) -- 991
		if rowId == "modePref" then -- 991
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 993
		end -- 993
		if rowId == "aimAssist" then -- 993
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 997
		end -- 997
		if rowId == "gpLayout" then -- 997
			return layoutLabelOf(s.gamepadLayout) -- 998
		end -- 998
		if rowId == "crouchMode" then -- 998
			return s.crouchToggle and "点按切换" or "持续按住" -- 999
		end -- 999
		if rowId == "touchOpacity" then -- 999
			return opacityLabelOf(s.touchOpacity) -- 1000
		end -- 1000
		if rowId == "touchScale" then -- 1000
			return scaleLabelOf(s.touchScale) -- 1001
		end -- 1001
		if rowId == "haptics" then -- 1001
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1002
		end -- 1002
		return "" -- 1003
	end -- 991
	do -- 991
		i = 0 -- 1006
		while i < #SETTINGS_ROWS do -- 1006
			local row = SETTINGS_ROWS[i + 1] -- 1007
			local box = boxes[i + 1] -- 1008
			local cy = box.y + box.height * 0.5 -- 1009
			local active = self.settingsSelected == i -- 1010
			if active then -- 1010
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1013
				drawSilkRibbon( -- 1014
					uiDraw, -- 1014
					uiArt, -- 1014
					"set_rib_" .. tostring(i), -- 1014
					panelX + panelW * 0.5, -- 1014
					cy, -- 1014
					panelW + 24, -- 1014
					rowH, -- 1014
					PALETTE.rougeSoft, -- 1014
					0.48 * breathe, -- 1014
					0 -- 1014
				) -- 1014
				drawHairline( -- 1015
					uiInkDraw, -- 1015
					uiArt, -- 1015
					"set_line_" .. tostring(i), -- 1015
					panelX + panelW * 0.5, -- 1015
					box.y + 3, -- 1015
					panelW - 24, -- 1015
					PALETTE.silkLine, -- 1015
					0.42 * breathe, -- 1015
					false, -- 1015
					2 -- 1015
				) -- 1015
				drawBlossomDot( -- 1016
					uiInkDraw, -- 1016
					uiArt, -- 1016
					"set_dot_" .. tostring(i), -- 1016
					panelX + 18, -- 1016
					cy, -- 1016
					14, -- 1016
					PALETTE.rouge, -- 1016
					0.96, -- 1016
					4 -- 1016
				) -- 1016
				fillRadialGlow( -- 1017
					uiGlow, -- 1017
					panelX + 18, -- 1017
					cy, -- 1017
					20, -- 1017
					14, -- 1017
					toColor(PALETTE.rouge, 24 * breathe), -- 1017
					Color(182, 58, 56, 0), -- 1017
					10 -- 1017
				) -- 1017
			else -- 1017
				drawBlossomDot( -- 1019
					uiInkDraw, -- 1019
					uiArt, -- 1019
					"set_dot_" .. tostring(i), -- 1019
					panelX + 18, -- 1019
					cy, -- 1019
					7, -- 1019
					PALETTE.silkDim, -- 1019
					0.42, -- 1019
					3 -- 1019
				) -- 1019
			end -- 1019
			texts:put( -- 1022
				"sm", -- 1023
				row.title, -- 1024
				panelX + 42, -- 1025
				cy, -- 1026
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1027
				0, -- 1028
				0.5, -- 1029
				"Left", -- 1030
				active and 2.4 or 1.6, -- 1031
				active and 1 or 0.88, -- 1032
				0.08 -- 1033
			) -- 1033
			local val = valueTextOf(row.id) -- 1036
			if val ~= "" then -- 1036
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1038
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1039
				texts:put( -- 1040
					"sm", -- 1040
					decorated, -- 1040
					panelX + panelW - 24, -- 1040
					cy, -- 1040
					toColor(valCol), -- 1040
					1, -- 1040
					0.5, -- 1040
					"Right", -- 1040
					1, -- 1040
					active and 1 or 0.86, -- 1040
					0.08 -- 1040
				) -- 1040
			end -- 1040
			i = i + 1 -- 1006
		end -- 1006
	end -- 1006
	local backY = 40 + frame.safe.bottom * 0.45 -- 1044
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1045
	texts:put( -- 1050
		"xs", -- 1050
		hint, -- 1050
		w * 0.5, -- 1050
		backY + 14, -- 1050
		toColor(PALETTE.textDim), -- 1050
		0.5, -- 1050
		0.5, -- 1050
		"Center", -- 1050
		1.2, -- 1050
		0.84, -- 1050
		0.08 -- 1050
	) -- 1050
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1052
	if hit >= 0 then -- 1052
		self.settingsSelected = hit -- 1054
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1054
			return true -- 1056
		end -- 1056
		self:resetInput() -- 1058
		return false -- 1059
	end -- 1059
	if frame.keys.left or frame.prevTab then -- 1059
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1062
		if id ~= "back" then -- 1062
			applyDelta(id, -1) -- 1064
			self:resetInput() -- 1065
		end -- 1065
		return false -- 1067
	end -- 1067
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1067
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1070
		if applyDelta(id, 1) then -- 1070
			return true -- 1072
		end -- 1072
		self:resetInput() -- 1074
		return false -- 1075
	end -- 1075
	return false -- 1077
end -- 919
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1085
	if assistHintsEnabled == nil then -- 1085
		assistHintsEnabled = false -- 1096
	end -- 1096
	if safeUi == nil then -- 1096
		safeUi = ZERO_SAFE_INSETS -- 1098
	end -- 1098
	self.time = self.time + dt -- 1100
	local frame = self:readFrame(input, uiScale, safeUi) -- 1101
	if self.pauseShowControls then -- 1101
		local ctrlAct = self:drawControls( -- 1104
			frame, -- 1104
			uiDraw, -- 1104
			uiInkDraw, -- 1104
			uiArt, -- 1104
			uiGlow, -- 1104
			texts, -- 1104
			w, -- 1104
			h, -- 1104
			"返回暂停" -- 1104
		) -- 1104
		if ctrlAct.type == "backTitle" then -- 1104
			self.pauseShowControls = false -- 1106
			self:resetInput() -- 1107
		end -- 1107
		return {type = "none"} -- 1109
	end -- 1109
	if self.pauseShowSettings then -- 1109
		if self:drawPauseSettings( -- 1109
			frame, -- 1113
			input, -- 1113
			uiDraw, -- 1113
			uiInkDraw, -- 1113
			uiArt, -- 1113
			uiGlow, -- 1113
			texts, -- 1113
			w, -- 1113
			h -- 1113
		) then -- 1113
			self.pauseShowSettings = false -- 1114
			self:resetInput() -- 1115
		end -- 1115
		return {type = "none"} -- 1117
	end -- 1117
	if frame.back then -- 1117
		self.pauseShowControls = false -- 1121
		self.pauseShowSettings = false -- 1122
		return {type = "resume"} -- 1123
	end -- 1123
	local allowFs = canToggleFullscreen() -- 1126
	local allowQuit = canQuitApp() -- 1127
	local pauseItems = __TS__ArrayFilter( -- 1128
		PAUSE_ITEMS, -- 1128
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1128
	) -- 1128
	if self.pauseSelected >= #pauseItems then -- 1128
		self.pauseSelected = 0 -- 1132
	end -- 1132
	uiDraw:drawRect( -- 1135
		Rect(0, 0, w, h), -- 1135
		Color(8, 10, 16, 102) -- 1135
	) -- 1135
	fillHGradRect( -- 1136
		uiDraw, -- 1136
		0, -- 1136
		0, -- 1136
		w * 0.27 + frame.safe.left, -- 1136
		h, -- 1136
		Color(9, 11, 18, 232), -- 1136
		Color(10, 13, 21, 198) -- 1136
	) -- 1136
	fillHGradRect( -- 1137
		uiDraw, -- 1137
		w * 0.27 + frame.safe.left, -- 1137
		0, -- 1137
		w * 0.21, -- 1137
		h, -- 1137
		Color(10, 13, 21, 198), -- 1137
		Color(10, 13, 21, 0) -- 1137
	) -- 1137
	local menuX = 110 + frame.safe.left * 0.6 -- 1139
	local compact = #pauseItems > 8 -- 1140
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1141
	uiArt:tryPlace( -- 1142
		"ink_vstream", -- 1142
		"pause_vstream", -- 1142
		menuX - 32, -- 1142
		h * 0.5, -- 1142
		34, -- 1142
		h * 0.78, -- 1142
		{ -- 1142
			color = toColor(PALETTE.silkDim), -- 1143
			opacity = 0.48, -- 1143
			layer = 1 -- 1143
		} -- 1143
	) -- 1143
	drawMistCurve( -- 1145
		uiArt, -- 1145
		"pause_mist", -- 1145
		menuX + 118, -- 1145
		headY - 8, -- 1145
		290, -- 1145
		72, -- 1145
		PALETTE.jadeMist, -- 1145
		0.2, -- 1145
		-1 -- 1145
	) -- 1145
	texts:put( -- 1147
		"banner", -- 1147
		"暂歇", -- 1147
		menuX + 16, -- 1147
		headY, -- 1147
		toColor(PALETTE.textBright), -- 1147
		0, -- 1147
		0.5, -- 1147
		"Left", -- 1147
		10, -- 1147
		0.98, -- 1147
		0.1 -- 1147
	) -- 1147
	texts:put( -- 1148
		"xs", -- 1148
		"月夜暂驻 · 卷页留痕", -- 1148
		menuX + 18, -- 1148
		headY - 36, -- 1148
		toColor(PALETTE.textDim), -- 1148
		0, -- 1148
		0.5, -- 1148
		"Left", -- 1148
		2, -- 1148
		0.8, -- 1148
		0.08 -- 1148
	) -- 1148
	drawHairline( -- 1149
		uiInkDraw, -- 1149
		uiArt, -- 1149
		"pause_div", -- 1149
		menuX + 124, -- 1149
		headY - 60, -- 1149
		240, -- 1149
		PALETTE.silkDim, -- 1149
		0.58, -- 1149
		true, -- 1149
		2 -- 1149
	) -- 1149
	local rowStep = compact and 42 or 46 -- 1151
	local rowH = compact and 36 or 38 -- 1152
	local firstY = compact and headY - 112 or headY - 120 -- 1153
	local boxes = {} -- 1154
	local i = 0 -- 1155
	do -- 1155
		i = 0 -- 1156
		while i < #pauseItems do -- 1156
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1157
			i = i + 1 -- 1156
		end -- 1156
	end -- 1156
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1159
	do -- 1159
		i = 0 -- 1161
		while i < #pauseItems do -- 1161
			local iy = boxes[i + 1].y -- 1162
			local active = self.pauseSelected == i -- 1163
			local cy = iy + rowH * 0.5 -- 1164
			local shiftX = active and 10 or 0 -- 1165
			local item = pauseItems[i + 1] -- 1166
			local label = item.zh -- 1167
			if item.id == "assist" then -- 1167
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1169
			elseif item.id == "fullscreen" then -- 1169
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1171
			elseif item.id == "settings" then -- 1171
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1173
			end -- 1173
			if active then -- 1173
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1177
				drawSilkRibbon( -- 1178
					uiDraw, -- 1178
					uiArt, -- 1178
					"pause_rib_" .. tostring(i), -- 1178
					menuX + 116, -- 1178
					cy, -- 1178
					282, -- 1178
					rowH, -- 1178
					PALETTE.rougeSoft, -- 1178
					0.54 * breathe, -- 1178
					0 -- 1178
				) -- 1178
				drawHairline( -- 1179
					uiInkDraw, -- 1179
					uiArt, -- 1179
					"pause_line_" .. tostring(i), -- 1179
					menuX + 106, -- 1179
					iy + 3, -- 1179
					210, -- 1179
					PALETTE.silkLine, -- 1179
					0.42 * breathe, -- 1179
					false, -- 1179
					2 -- 1179
				) -- 1179
				drawBlossomDot( -- 1180
					uiInkDraw, -- 1180
					uiArt, -- 1180
					"pause_dot_" .. tostring(i), -- 1180
					menuX + 12, -- 1180
					cy, -- 1180
					15, -- 1180
					PALETTE.rouge, -- 1180
					0.96, -- 1180
					4 -- 1180
				) -- 1180
				fillRadialGlow( -- 1181
					uiGlow, -- 1181
					menuX + 12, -- 1181
					cy, -- 1181
					22, -- 1181
					16, -- 1181
					toColor(PALETTE.rouge, 26 * breathe), -- 1181
					Color(182, 58, 56, 0), -- 1181
					10 -- 1181
				) -- 1181
			else -- 1181
				drawBlossomDot( -- 1183
					uiInkDraw, -- 1183
					uiArt, -- 1183
					"pause_dot_" .. tostring(i), -- 1183
					menuX + 12, -- 1183
					cy, -- 1183
					8, -- 1183
					PALETTE.silkDim, -- 1183
					0.4, -- 1183
					3 -- 1183
				) -- 1183
			end -- 1183
			texts:put( -- 1186
				compact and "sm" or "md", -- 1187
				label, -- 1188
				menuX + 32 + shiftX, -- 1189
				cy, -- 1190
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1191
				0, -- 1192
				0.5, -- 1193
				"Left", -- 1194
				active and 3.4 or 2.2, -- 1195
				active and 1 or 0.88, -- 1196
				0.1 -- 1197
			) -- 1197
			i = i + 1 -- 1161
		end -- 1161
	end -- 1161
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1201
	texts:put( -- 1206
		"xs", -- 1206
		pauseFooter, -- 1206
		menuX + 12, -- 1206
		38 + frame.safe.bottom * 0.4, -- 1206
		toColor(PALETTE.textDim), -- 1206
		0, -- 1206
		0.5, -- 1206
		"Left", -- 1206
		1.2, -- 1206
		0.86, -- 1206
		0.08 -- 1206
	) -- 1206
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1208
	if hit >= 0 or frame.keys.confirm then -- 1208
		local idx = hit >= 0 and hit or self.pauseSelected -- 1210
		local id = pauseItems[idx + 1].id -- 1211
		if id == "controls" then -- 1211
			self.pauseShowControls = true -- 1213
			self:resetInput() -- 1214
			return {type = "none"} -- 1215
		end -- 1215
		if id == "settings" then -- 1215
			self:openPauseSettings() -- 1218
			return {type = "none"} -- 1219
		end -- 1219
		if id == "assist" then -- 1219
			if onToggleAssist ~= nil then -- 1219
				onToggleAssist() -- 1223
			end -- 1223
			self:resetInput() -- 1225
			return {type = "none"} -- 1226
		end -- 1226
		if id == "fullscreen" then -- 1226
			self:resetInput() -- 1229
			return {type = "toggleFullscreen"} -- 1230
		end -- 1230
		self.pauseShowControls = false -- 1232
		self.pauseShowSettings = false -- 1233
		if id == "resume" then -- 1233
			return {type = "resume"} -- 1234
		end -- 1234
		if id == "retry" then -- 1234
			return {type = "retry"} -- 1235
		end -- 1235
		if id == "chapters" then -- 1235
			return {type = "openChapters"} -- 1236
		end -- 1236
		if id == "quit" then -- 1236
			return {type = "quit"} -- 1237
		end -- 1237
		return {type = "toTitle"} -- 1238
	end -- 1238
	return {type = "none"} -- 1240
end -- 1085
return ____exports -- 1085