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
	function(____, chapter) return chapter.room.key ~= "museum" and chapter.room.key ~= "street" and chapter.room.key ~= "checkpoint" end -- 88
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
	if not inside then -- 152
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
	if key == "Up" or key == "W" then -- 232
		self.queuedKeys.up = true -- 233
	elseif key == "Down" or key == "S" then -- 234
		self.queuedKeys.down = true -- 235
	elseif key == "Left" or key == "A" then -- 236
		self.queuedKeys.left = true -- 237
	elseif key == "Right" or key == "D" then -- 238
		self.queuedKeys.right = true -- 239
	elseif key == "Return" or key == "Space" then -- 240
		self.queuedKeys.confirm = true -- 241
	elseif key == "Escape" then -- 242
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
	if frame.click and hit >= 0 then -- 291
		return hit -- 292
	end -- 292
	if frame.keys.up then -- 294
		return (selected + #boxes - 1) % #boxes -- 295
	end -- 295
	if frame.keys.down then -- 297
		return (selected + 1) % #boxes -- 298
	end -- 298
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 300
end -- 289
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 303
	if safeUi == nil then -- 319
		safeUi = ZERO_SAFE_INSETS -- 319
	end -- 319
	self.time = self.time + dt -- 321
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 322
	if screen ~= "splash" or splashDissolving then -- 323
		local artW = math.max(w, h * 16 / 9) -- 324
		local artH = artW * 9 / 16 -- 325
		if not backdropArt:tryPlace( -- 326
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
	if screen == "splash" then -- 335
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
	if screen == "title" then -- 338
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
	if screen == "chapters" then -- 341
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
	if wantSkip or t >= 4.65 then -- 367
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
		if localT <= 0 or localT >= endT then -- 379
			return 0 -- 379
		end -- 379
		if localT < fadeIn then -- 380
			local u = localT / fadeIn -- 381
			return u * u * (3 - 2 * u) -- 382
		end -- 382
		if localT <= holdEnd then -- 384
			return 1 -- 384
		end -- 384
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 385
		return 1 - u * u * (3 - 2 * u) -- 386
	end -- 378
	if t < 2.2 then -- 389
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 390
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 391
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 392
		if not uiArt:tryPlace( -- 393
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
	elseif t < 4.25 then -- 397
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
		if not uiArt:tryPlace( -- 404
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
	if t >= 0.35 and t < 4.15 then -- 409
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
	if not placedBrandTitle then -- 450
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
			if ch ~= "" then -- 496
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
	}) or baseItems -- 510
	if self.selected >= #items then -- 511
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
			if active then -- 532
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
	if hit >= 0 or frame.keys.confirm then -- 575
		local idx = hit >= 0 and hit or self.selected -- 576
		local id = items[idx + 1].id -- 577
		if id == "continue" then -- 578
			return {type = "continue"} -- 578
		end -- 578
		if id == "trial" then -- 579
			return {type = "trial"} -- 579
		end -- 579
		if id == "start" then -- 580
			return {type = "start"} -- 580
		end -- 580
		if id == "chapters" then -- 581
			return {type = "openChapters"} -- 581
		end -- 581
		if id == "quit" then -- 582
			return {type = "quit"} -- 582
		end -- 582
		return {type = "openControls"} -- 583
	end -- 583
	return {type = "none"} -- 585
end -- 422
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 588
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 598
	if frame.back then -- 599
		return back -- 600
	end -- 600
	local extraH = math.max(0, h - 720) -- 603
	local marginX = math.max( -- 604
		96, -- 604
		56 + math.max(frame.safe.left, frame.safe.right) -- 604
	) -- 604
	local splitTrack = #CHAPTERS > 8 -- 605
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 606
	local trackY = (splitTrack and 210 or 148) + extraH * 0.25 -- 607
	local rowGap = 68 -- 608
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
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58) -- 618
			s = s + 1 -- 615
		end -- 615
	end -- 615
	local prevSelected = self.chapterSelected -- 621
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 622
	local keys = frame.keys -- 623
	if frame.click and hitStation >= 0 then -- 624
		self.chapterSelected = hitStation -- 625
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 626
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 627
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 628
	elseif keys.down and self.chapterSelected < perRow then -- 629
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 630
	elseif keys.up and self.chapterSelected >= perRow then -- 631
		self.chapterSelected = self.chapterSelected - perRow -- 632
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 633
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
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 705
	texts:put( -- 708
		"xs", -- 708
		chapConfirmTag, -- 708
		goX + 156, -- 708
		goY + 21, -- 708
		toColor(PALETTE.textDim), -- 708
		0, -- 708
		0.5, -- 708
		"Left", -- 708
		1, -- 708
		0.82, -- 708
		0.08 -- 708
	) -- 708
	local veilCenterY = splitTrack and trackY - rowGap * 0.5 or trackY + 6 -- 710
	local veilH = splitTrack and 156 or 126 -- 711
	drawSilkVeil( -- 712
		uiDraw, -- 712
		uiArt, -- 712
		"chap_track_veil", -- 712
		w * 0.5, -- 712
		veilCenterY, -- 712
		w - marginX * 1.1, -- 712
		veilH, -- 712
		PALETTE.inkWash, -- 712
		0.72, -- 712
		-2 -- 712
	) -- 712
	drawMistCurve( -- 713
		uiArt, -- 713
		"chap_track_mist", -- 713
		w * 0.5, -- 713
		trackY, -- 713
		trackX1 - trackX0 + 160, -- 713
		74, -- 713
		PALETTE.inkMist, -- 713
		0.62, -- 713
		-1 -- 713
	) -- 713
	uiInkDraw:drawSegment( -- 714
		Vec2(trackX0, trackY), -- 714
		Vec2(trackX1, trackY), -- 714
		0.9, -- 714
		toColor(PALETTE.silkDim, 145) -- 714
	) -- 714
	if splitTrack then -- 716
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 717
		uiInkDraw:drawSegment( -- 718
			Vec2(trackX0, trackY - rowGap), -- 718
			Vec2(lastX, trackY - rowGap), -- 718
			0.9, -- 718
			toColor(PALETTE.silkDim, 145) -- 718
		) -- 718
	else -- 718
		local midDivX = trackX0 + stepX * 3.5 -- 720
		uiInkDraw:drawSegment( -- 721
			Vec2(midDivX, trackY - 12), -- 721
			Vec2(midDivX, trackY + 12), -- 721
			0.8, -- 721
			toColor(PALETTE.silkDim, 120) -- 721
		) -- 721
		texts:put( -- 722
			"xs", -- 722
			"上卷 · 孤城护童", -- 722
			trackX0 + stepX * 1.5, -- 722
			trackY + 52, -- 722
			toColor(PALETTE.cyan), -- 722
			0.5, -- 722
			0.5, -- 722
			"Center", -- 722
			2.2, -- 722
			0.88, -- 722
			0.08 -- 722
		) -- 722
		texts:put( -- 723
			"xs", -- 723
			"下卷 · 独赴北塔", -- 723
			trackX0 + stepX * 5.5, -- 723
			trackY + 52, -- 723
			toColor(PALETTE.amber), -- 723
			0.5, -- 723
			0.5, -- 723
			"Center", -- 723
			2.2, -- 723
			0.88, -- 723
			0.08 -- 723
		) -- 723
	end -- 723
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #CHAPTERS do -- 727
			local box = stationBoxes[i + 1] -- 728
			local sx = box.x + box.width * 0.5 -- 729
			local sy = box.y + box.height * 0.5 -- 730
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 731
			local active = self.chapterSelected == i -- 732
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 733
			if active then -- 735
				fillRadialGlow( -- 736
					uiGlow, -- 736
					sx, -- 736
					sy, -- 736
					26, -- 736
					26, -- 736
					toColor(PALETTE.rouge, 36 * breathe), -- 736
					Color(182, 58, 56, 0), -- 736
					12 -- 736
				) -- 736
				uiArt:tryPlace( -- 737
					"ink_enso_fine", -- 737
					"chap_st_ring_" .. tostring(i), -- 737
					sx, -- 737
					sy, -- 737
					32, -- 737
					32, -- 737
					{ -- 737
						color = toColor(PALETTE.silkLine), -- 738
						opacity = 0.78, -- 738
						angle = self.time * 18, -- 738
						layer = 3 -- 738
					} -- 738
				) -- 738
				drawBlossomDot( -- 740
					uiInkDraw, -- 740
					uiArt, -- 740
					"chap_st_dot_" .. tostring(i), -- 740
					sx, -- 740
					sy, -- 740
					17, -- 740
					PALETTE.rouge, -- 740
					0.98, -- 740
					4 -- 740
				) -- 740
			else -- 740
				uiArt:tryPlace( -- 742
					"ink_enso_fine", -- 742
					"chap_st_ring_" .. tostring(i), -- 742
					sx, -- 742
					sy, -- 742
					16, -- 742
					16, -- 742
					{ -- 742
						color = toColor(nodeCol), -- 743
						opacity = 0.62, -- 743
						layer = 3 -- 743
					} -- 743
				) -- 743
				drawBlossomDot( -- 745
					uiInkDraw, -- 745
					uiArt, -- 745
					"chap_st_dot_" .. tostring(i), -- 745
					sx, -- 745
					sy, -- 745
					7, -- 745
					PALETTE.silkLine, -- 745
					0.72, -- 745
					4 -- 745
				) -- 745
			end -- 745
			if not splitTrack then -- 748
				texts:put( -- 749
					"xs", -- 749
					rt.numeralZh, -- 749
					sx, -- 749
					sy + 25, -- 749
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 749
					0.5, -- 749
					0.5, -- 749
					"Center", -- 749
					0, -- 749
					active and 1 or 0.88, -- 749
					0.08 -- 749
				) -- 749
			end -- 749
			texts:put( -- 751
				"xs", -- 751
				rt.shortNameZh, -- 751
				sx, -- 751
				sy - 26, -- 751
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 751
				0.5, -- 751
				0.5, -- 751
				"Center", -- 751
				1, -- 751
				active and 1 or 0.84, -- 751
				0.08 -- 751
			) -- 751
			i = i + 1 -- 727
		end -- 727
	end -- 727
	local backX = marginX -- 754
	local backY = 40 + frame.safe.bottom * 0.45 -- 755
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 756
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 757
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 758
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 761
	drawSilkKeycap( -- 766
		uiInkDraw, -- 766
		texts, -- 766
		backX, -- 766
		backY + 5, -- 766
		48, -- 766
		24, -- 766
		chapBackTag, -- 766
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 766
		0.92, -- 766
		backHover -- 766
	) -- 766
	texts:put( -- 767
		"sm", -- 767
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 767
		backX + 60, -- 767
		backY + 17, -- 767
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 767
		0, -- 767
		0.5, -- 767
		"Left", -- 767
		1.8, -- 767
		0.9, -- 767
		0.08 -- 767
	) -- 767
	texts:put( -- 768
		"xs", -- 768
		chapFooter, -- 768
		w - marginX, -- 768
		backY + 17, -- 768
		toColor(PALETTE.textDim), -- 768
		1, -- 768
		0.5, -- 768
		"Right", -- 768
		1.2, -- 768
		0.75, -- 768
		0.08 -- 768
	) -- 768
	if frame.click and backHover then -- 770
		return back -- 771
	end -- 771
	local ____temp_2 -- 774
	if frame.mode == "touch" then -- 774
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 775
	else -- 775
		____temp_2 = hitStation >= 0 -- 776
	end -- 776
	local stationConfirmed = ____temp_2 -- 774
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 777
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 778
	end -- 778
	return {type = "none"} -- 780
end -- 588
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 784
	if backLabel == nil then -- 793
		backLabel = "返回标题" -- 793
	end -- 793
	if not self.controlsTabManual then -- 795
		self.controlsTab = frame.mode -- 796
	end -- 796
	local tabOrder = {"kbm", "gamepad", "touch"} -- 798
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 799
	local marginX = math.max( -- 800
		96, -- 800
		56 + math.max(frame.safe.left, frame.safe.right) -- 800
	) -- 800
	local tabW = 92 -- 801
	local tabH = 28 -- 802
	local tabGap = 10 -- 803
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 804
	local tabY = h - 82 - frame.safe.top * 0.35 -- 805
	local tabBoxes = { -- 806
		Rect(tabStartX, tabY, tabW, tabH), -- 807
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 808
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 809
	} -- 809
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 812
	if frame.click and hitTab >= 0 then -- 813
		self.controlsTab = tabOrder[hitTab + 1] -- 814
		self.controlsTabManual = true -- 815
	elseif frame.keys.left or frame.prevTab then -- 816
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 817
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 818
		self.controlsTabManual = true -- 819
	elseif frame.keys.right or frame.nextTab then -- 820
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 821
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 822
		self.controlsTabManual = true -- 823
	end -- 823
	local backX = marginX -- 826
	local backY = 40 + frame.safe.bottom * 0.45 -- 827
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 828
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 829
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 830
		return {type = "backTitle"} -- 831
	end -- 831
	uiDraw:drawRect( -- 833
		Rect(0, 0, w, h), -- 833
		Color(10, 12, 19, 204) -- 833
	) -- 833
	local guide = controlsGuideRows(self.controlsTab) -- 835
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 836
	texts:put( -- 837
		"banner", -- 837
		"执器要诀", -- 837
		marginX, -- 837
		topHeadY, -- 837
		toColor(PALETTE.textBright), -- 837
		0, -- 837
		0.5, -- 837
		"Left", -- 837
		4.5, -- 837
		0.96, -- 837
		0.1 -- 837
	) -- 837
	texts:put( -- 838
		"xs", -- 838
		guide.subtitle, -- 838
		marginX + 196, -- 838
		topHeadY - 4, -- 838
		toColor(PALETTE.textDim), -- 838
		0, -- 838
		0.5, -- 838
		"Left", -- 838
		1.8, -- 838
		0.85, -- 838
		0.08 -- 838
	) -- 838
	drawHairline( -- 839
		uiInkDraw, -- 839
		uiArt, -- 839
		"ctrl_top_line", -- 839
		w * 0.5, -- 839
		topHeadY - 34, -- 839
		w - marginX * 2, -- 839
		PALETTE.silkDim, -- 839
		0.6, -- 839
		true, -- 839
		2 -- 839
	) -- 839
	local ti = 0 -- 841
	do -- 841
		ti = 0 -- 842
		while ti < #tabBoxes do -- 842
			local tb = tabBoxes[ti + 1] -- 843
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 844
			local hoverTab = hitTab == ti -- 845
			uiInkDraw:drawRect( -- 846
				tb, -- 847
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 848
				0.9, -- 849
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 850
			) -- 850
			texts:put( -- 852
				"xs", -- 853
				tabLabels[ti + 1], -- 854
				tb.x + tb.width * 0.5, -- 855
				tb.y + tb.height * 0.5, -- 856
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 857
				0.5, -- 858
				0.5, -- 859
				"Center", -- 860
				0.8, -- 861
				activeTab and 0.98 or 0.82, -- 862
				0.08 -- 863
			) -- 863
			ti = ti + 1 -- 842
		end -- 842
	end -- 842
	local extraH = math.max(0, h - 720) -- 867
	local areaY = 114 + frame.safe.bottom * 0.4 -- 868
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 869
	drawFiligreeCorners( -- 870
		uiInkDraw, -- 870
		uiArt, -- 870
		"ctrl_outer", -- 870
		marginX, -- 870
		areaY, -- 870
		w - marginX * 2, -- 870
		areaH, -- 870
		PALETTE.silkDim, -- 870
		0.52, -- 870
		34, -- 870
		false, -- 870
		2 -- 870
	) -- 870
	local midX = w * 0.5 -- 872
	uiArt:tryPlace( -- 873
		"ink_vstream", -- 873
		"ctrl_mid_stream", -- 873
		midX, -- 873
		areaY + areaH * 0.5, -- 873
		32, -- 873
		areaH - 18, -- 873
		{ -- 873
			color = toColor(PALETTE.silkDim), -- 874
			opacity = 0.52, -- 874
			layer = 1 -- 874
		} -- 874
	) -- 874
	drawBlossomDot( -- 876
		uiInkDraw, -- 876
		uiArt, -- 876
		"ctrl_mid_dot", -- 876
		midX, -- 876
		areaY + areaH * 0.5, -- 876
		11, -- 876
		PALETTE.silkLine, -- 876
		0.62, -- 876
		3 -- 876
	) -- 876
	local leftColX = marginX + 34 -- 878
	local colW = midX - leftColX - 42 -- 879
	local headY = areaY + areaH - 34 -- 880
	local rowStep = 52 + extraH * 0.08 -- 881
	drawBlossomDot( -- 883
		uiInkDraw, -- 883
		uiArt, -- 883
		"ctrl_l_dot", -- 883
		leftColX + 8, -- 883
		headY, -- 883
		12, -- 883
		PALETTE.cyan, -- 883
		0.88, -- 883
		3 -- 883
	) -- 883
	texts:put( -- 884
		"md", -- 884
		"周戍 · 护送与交锋", -- 884
		leftColX + 26, -- 884
		headY, -- 884
		toColor(PALETTE.cyanCore), -- 884
		0, -- 884
		0.5, -- 884
		"Left", -- 884
		2.4, -- 884
		0.98, -- 884
		0.08 -- 884
	) -- 884
	drawHairline( -- 885
		uiInkDraw, -- 885
		uiArt, -- 885
		"ctrl_l_line", -- 885
		leftColX + colW * 0.5, -- 885
		headY - 24, -- 885
		colW, -- 885
		PALETTE.cyanDim, -- 885
		0.58, -- 885
		false, -- 885
		2 -- 885
	) -- 885
	local i = 0 -- 887
	local keycapW = 160 -- 888
	do -- 888
		i = 0 -- 889
		while i < #guide.soldierRows do -- 889
			local ry = headY - 66 - i * rowStep -- 890
			drawSilkKeycap( -- 891
				uiInkDraw, -- 891
				texts, -- 891
				leftColX + 2, -- 891
				ry - 13, -- 891
				keycapW, -- 891
				26, -- 891
				guide.soldierRows[i + 1][1], -- 891
				PALETTE.cyan, -- 891
				0.92, -- 891
				false -- 891
			) -- 891
			texts:put( -- 892
				"sm", -- 892
				guide.soldierRows[i + 1][2], -- 892
				leftColX + keycapW + 16, -- 892
				ry, -- 892
				toColor(PALETTE.textBright), -- 892
				0, -- 892
				0.5, -- 892
				"Left", -- 892
				0.8, -- 892
				0.92, -- 892
				0.08 -- 892
			) -- 892
			i = i + 1 -- 889
		end -- 889
	end -- 889
	local rightColX = midX + 44 -- 895
	drawBlossomDot( -- 896
		uiInkDraw, -- 896
		uiArt, -- 896
		"ctrl_r_dot", -- 896
		rightColX + 8, -- 896
		headY, -- 896
		12, -- 896
		PALETTE.amber, -- 896
		0.88, -- 896
		3 -- 896
	) -- 896
	texts:put( -- 897
		"md", -- 897
		"小满 · 潜行与寻路", -- 897
		rightColX + 26, -- 897
		headY, -- 897
		toColor(PALETTE.amberCore), -- 897
		0, -- 897
		0.5, -- 897
		"Left", -- 897
		2.4, -- 897
		0.98, -- 897
		0.08 -- 897
	) -- 897
	drawHairline( -- 898
		uiInkDraw, -- 898
		uiArt, -- 898
		"ctrl_r_line", -- 898
		rightColX + colW * 0.5, -- 898
		headY - 24, -- 898
		colW, -- 898
		PALETTE.amberDim, -- 898
		0.58, -- 898
		false, -- 898
		2 -- 898
	) -- 898
	do -- 898
		i = 0 -- 900
		while i < #guide.childRows do -- 900
			local ry = headY - 66 - i * rowStep -- 901
			drawSilkKeycap( -- 902
				uiInkDraw, -- 902
				texts, -- 902
				rightColX + 2, -- 902
				ry - 13, -- 902
				keycapW, -- 902
				26, -- 902
				guide.childRows[i + 1][1], -- 902
				PALETTE.amber, -- 902
				0.92, -- 902
				false -- 902
			) -- 902
			texts:put( -- 903
				"sm", -- 903
				guide.childRows[i + 1][2], -- 903
				rightColX + keycapW + 16, -- 903
				ry, -- 903
				toColor(PALETTE.textBright), -- 903
				0, -- 903
				0.5, -- 903
				"Left", -- 903
				0.8, -- 903
				0.92, -- 903
				0.08 -- 903
			) -- 903
			i = i + 1 -- 900
		end -- 900
	end -- 900
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 906
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 909
	local keyW = frame.mode == "touch" and 76 or 110 -- 914
	drawSilkKeycap( -- 915
		uiInkDraw, -- 915
		texts, -- 915
		backX, -- 915
		backY + 5, -- 915
		keyW, -- 915
		24, -- 915
		ctrlBackKey, -- 915
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 915
		0.92, -- 915
		backHover -- 915
	) -- 915
	texts:put( -- 916
		"sm", -- 916
		backLabel, -- 916
		backX + keyW + 12, -- 916
		backY + 17, -- 916
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 916
		0, -- 916
		0.5, -- 916
		"Left", -- 916
		1.8, -- 916
		0.92, -- 916
		0.08 -- 916
	) -- 916
	texts:put( -- 917
		"xs", -- 917
		ctrlRightHint, -- 917
		w - marginX, -- 917
		backY + 17, -- 917
		toColor(PALETTE.textDim), -- 917
		1, -- 917
		0.5, -- 917
		"Right", -- 917
		1.2, -- 917
		0.78, -- 917
		0.08 -- 917
	) -- 917
	return {type = "none"} -- 919
end -- 784
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 923
	if frame.back then -- 934
		return true -- 935
	end -- 935
	local caps = getPlatformCaps() -- 938
	local s = input.settings -- 939
	uiDraw:drawRect( -- 941
		Rect(0, 0, w, h), -- 941
		Color(10, 12, 19, 206) -- 941
	) -- 941
	local marginX = math.max( -- 943
		96, -- 943
		56 + math.max(frame.safe.left, frame.safe.right) -- 943
	) -- 943
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 944
	texts:put( -- 945
		"banner", -- 945
		"操控设置", -- 945
		marginX, -- 945
		topHeadY, -- 945
		toColor(PALETTE.textBright), -- 945
		0, -- 945
		0.5, -- 945
		"Left", -- 945
		4.5, -- 945
		0.96, -- 945
		0.1 -- 945
	) -- 945
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 全平台支持键鼠 / 触屏 / 手柄" -- 946
	texts:put( -- 947
		"xs", -- 947
		curSummary, -- 947
		marginX + 196, -- 947
		topHeadY - 4, -- 947
		toColor(PALETTE.amberCore), -- 947
		0, -- 947
		0.5, -- 947
		"Left", -- 947
		1.4, -- 947
		0.88, -- 947
		0.08 -- 947
	) -- 947
	drawHairline( -- 948
		uiInkDraw, -- 948
		uiArt, -- 948
		"set_top_line", -- 948
		w * 0.5, -- 948
		topHeadY - 34, -- 948
		w - marginX * 2, -- 948
		PALETTE.silkDim, -- 948
		0.6, -- 948
		true, -- 948
		2 -- 948
	) -- 948
	local panelW = math.min(760, w - marginX * 2) -- 950
	local panelX = (w - panelW) * 0.5 -- 951
	local rowH = 44 -- 952
	local rowStep = 50 -- 953
	local firstY = topHeadY - 104 -- 954
	local boxes = {} -- 956
	local i = 0 -- 957
	do -- 957
		i = 0 -- 958
		while i < #SETTINGS_ROWS do -- 958
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 959
			i = i + 1 -- 958
		end -- 958
	end -- 958
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 961
	local function applyDelta(rowId, delta) -- 963
		if rowId == "back" then -- 964
			return true -- 965
		end -- 965
		if rowId == "modePref" then -- 967
			input:cycleModePref(delta) -- 968
		elseif rowId == "aimAssist" then -- 969
			s.aimAssist = not s.aimAssist -- 970
			saveControlSettings(s) -- 971
		elseif rowId == "gpLayout" then -- 972
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 973
			input.gamepadLayout = s.gamepadLayout -- 974
			saveControlSettings(s) -- 975
		elseif rowId == "crouchMode" then -- 976
			s.crouchToggle = not s.crouchToggle -- 977
			saveControlSettings(s) -- 978
		elseif rowId == "touchOpacity" then -- 979
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 980
			saveControlSettings(s) -- 981
		elseif rowId == "touchScale" then -- 982
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 983
			saveControlSettings(s) -- 984
		elseif rowId == "haptics" then -- 985
			s.haptics = not s.haptics -- 986
			saveControlSettings(s) -- 987
			if s.haptics then -- 988
				local ____opt_3 = input:getTouch() -- 989
				if ____opt_3 ~= nil then -- 989
					____opt_3:vibrate(0.018) -- 989
				end -- 989
			end -- 989
		end -- 989
		return false -- 992
	end -- 963
	local function valueTextOf(rowId) -- 995
		if rowId == "modePref" then -- 996
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 997
		end -- 997
		if rowId == "aimAssist" then -- 1001
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1001
		end -- 1001
		if rowId == "gpLayout" then -- 1002
			return layoutLabelOf(s.gamepadLayout) -- 1002
		end -- 1002
		if rowId == "crouchMode" then -- 1003
			return s.crouchToggle and "点按切换" or "持续按住" -- 1003
		end -- 1003
		if rowId == "touchOpacity" then -- 1004
			return opacityLabelOf(s.touchOpacity) -- 1004
		end -- 1004
		if rowId == "touchScale" then -- 1005
			return scaleLabelOf(s.touchScale) -- 1005
		end -- 1005
		if rowId == "haptics" then -- 1006
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1006
		end -- 1006
		return "" -- 1007
	end -- 995
	do -- 995
		i = 0 -- 1010
		while i < #SETTINGS_ROWS do -- 1010
			local row = SETTINGS_ROWS[i + 1] -- 1011
			local box = boxes[i + 1] -- 1012
			local cy = box.y + box.height * 0.5 -- 1013
			local active = self.settingsSelected == i -- 1014
			if active then -- 1016
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1017
				drawSilkRibbon( -- 1018
					uiDraw, -- 1018
					uiArt, -- 1018
					"set_rib_" .. tostring(i), -- 1018
					panelX + panelW * 0.5, -- 1018
					cy, -- 1018
					panelW + 24, -- 1018
					rowH, -- 1018
					PALETTE.rougeSoft, -- 1018
					0.48 * breathe, -- 1018
					0 -- 1018
				) -- 1018
				drawHairline( -- 1019
					uiInkDraw, -- 1019
					uiArt, -- 1019
					"set_line_" .. tostring(i), -- 1019
					panelX + panelW * 0.5, -- 1019
					box.y + 3, -- 1019
					panelW - 24, -- 1019
					PALETTE.silkLine, -- 1019
					0.42 * breathe, -- 1019
					false, -- 1019
					2 -- 1019
				) -- 1019
				drawBlossomDot( -- 1020
					uiInkDraw, -- 1020
					uiArt, -- 1020
					"set_dot_" .. tostring(i), -- 1020
					panelX + 18, -- 1020
					cy, -- 1020
					14, -- 1020
					PALETTE.rouge, -- 1020
					0.96, -- 1020
					4 -- 1020
				) -- 1020
				fillRadialGlow( -- 1021
					uiGlow, -- 1021
					panelX + 18, -- 1021
					cy, -- 1021
					20, -- 1021
					14, -- 1021
					toColor(PALETTE.rouge, 24 * breathe), -- 1021
					Color(182, 58, 56, 0), -- 1021
					10 -- 1021
				) -- 1021
			else -- 1021
				drawBlossomDot( -- 1023
					uiInkDraw, -- 1023
					uiArt, -- 1023
					"set_dot_" .. tostring(i), -- 1023
					panelX + 18, -- 1023
					cy, -- 1023
					7, -- 1023
					PALETTE.silkDim, -- 1023
					0.42, -- 1023
					3 -- 1023
				) -- 1023
			end -- 1023
			texts:put( -- 1026
				"sm", -- 1027
				row.title, -- 1028
				panelX + 42, -- 1029
				cy, -- 1030
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1031
				0, -- 1032
				0.5, -- 1033
				"Left", -- 1034
				active and 2.4 or 1.6, -- 1035
				active and 1 or 0.88, -- 1036
				0.08 -- 1037
			) -- 1037
			local val = valueTextOf(row.id) -- 1040
			if val ~= "" then -- 1041
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1042
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1043
				texts:put( -- 1044
					"sm", -- 1044
					decorated, -- 1044
					panelX + panelW - 24, -- 1044
					cy, -- 1044
					toColor(valCol), -- 1044
					1, -- 1044
					0.5, -- 1044
					"Right", -- 1044
					1, -- 1044
					active and 1 or 0.86, -- 1044
					0.08 -- 1044
				) -- 1044
			end -- 1044
			i = i + 1 -- 1010
		end -- 1010
	end -- 1010
	local backY = 40 + frame.safe.bottom * 0.45 -- 1048
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1049
	texts:put( -- 1054
		"xs", -- 1054
		hint, -- 1054
		w * 0.5, -- 1054
		backY + 14, -- 1054
		toColor(PALETTE.textDim), -- 1054
		0.5, -- 1054
		0.5, -- 1054
		"Center", -- 1054
		1.2, -- 1054
		0.84, -- 1054
		0.08 -- 1054
	) -- 1054
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1056
	if hit >= 0 then -- 1057
		self.settingsSelected = hit -- 1058
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1059
			return true -- 1060
		end -- 1060
		self:resetInput() -- 1062
		return false -- 1063
	end -- 1063
	if frame.keys.left or frame.prevTab then -- 1065
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1066
		if id ~= "back" then -- 1067
			applyDelta(id, -1) -- 1068
			self:resetInput() -- 1069
		end -- 1069
		return false -- 1071
	end -- 1071
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1073
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1074
		if applyDelta(id, 1) then -- 1075
			return true -- 1076
		end -- 1076
		self:resetInput() -- 1078
		return false -- 1079
	end -- 1079
	return false -- 1081
end -- 923
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1089
	if assistHintsEnabled == nil then -- 1100
		assistHintsEnabled = false -- 1100
	end -- 1100
	if safeUi == nil then -- 1102
		safeUi = ZERO_SAFE_INSETS -- 1102
	end -- 1102
	self.time = self.time + dt -- 1104
	local frame = self:readFrame(input, uiScale, safeUi) -- 1105
	if self.pauseShowControls then -- 1107
		local ctrlAct = self:drawControls( -- 1108
			frame, -- 1108
			uiDraw, -- 1108
			uiInkDraw, -- 1108
			uiArt, -- 1108
			uiGlow, -- 1108
			texts, -- 1108
			w, -- 1108
			h, -- 1108
			"返回暂停" -- 1108
		) -- 1108
		if ctrlAct.type == "backTitle" then -- 1109
			self.pauseShowControls = false -- 1110
			self:resetInput() -- 1111
		end -- 1111
		return {type = "none"} -- 1113
	end -- 1113
	if self.pauseShowSettings then -- 1116
		if self:drawPauseSettings( -- 1117
			frame, -- 1117
			input, -- 1117
			uiDraw, -- 1117
			uiInkDraw, -- 1117
			uiArt, -- 1117
			uiGlow, -- 1117
			texts, -- 1117
			w, -- 1117
			h -- 1117
		) then -- 1117
			self.pauseShowSettings = false -- 1118
			self:resetInput() -- 1119
		end -- 1119
		return {type = "none"} -- 1121
	end -- 1121
	if frame.back then -- 1124
		self.pauseShowControls = false -- 1125
		self.pauseShowSettings = false -- 1126
		return {type = "resume"} -- 1127
	end -- 1127
	local allowFs = canToggleFullscreen() -- 1130
	local allowQuit = canQuitApp() -- 1131
	local pauseItems = __TS__ArrayFilter( -- 1132
		PAUSE_ITEMS, -- 1132
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1132
	) -- 1132
	if self.pauseSelected >= #pauseItems then -- 1135
		self.pauseSelected = 0 -- 1136
	end -- 1136
	uiDraw:drawRect( -- 1139
		Rect(0, 0, w, h), -- 1139
		Color(8, 10, 16, 102) -- 1139
	) -- 1139
	fillHGradRect( -- 1140
		uiDraw, -- 1140
		0, -- 1140
		0, -- 1140
		w * 0.27 + frame.safe.left, -- 1140
		h, -- 1140
		Color(9, 11, 18, 232), -- 1140
		Color(10, 13, 21, 198) -- 1140
	) -- 1140
	fillHGradRect( -- 1141
		uiDraw, -- 1141
		w * 0.27 + frame.safe.left, -- 1141
		0, -- 1141
		w * 0.21, -- 1141
		h, -- 1141
		Color(10, 13, 21, 198), -- 1141
		Color(10, 13, 21, 0) -- 1141
	) -- 1141
	local menuX = 110 + frame.safe.left * 0.6 -- 1143
	local compact = #pauseItems > 8 -- 1144
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1145
	uiArt:tryPlace( -- 1146
		"ink_vstream", -- 1146
		"pause_vstream", -- 1146
		menuX - 32, -- 1146
		h * 0.5, -- 1146
		34, -- 1146
		h * 0.78, -- 1146
		{ -- 1146
			color = toColor(PALETTE.silkDim), -- 1147
			opacity = 0.48, -- 1147
			layer = 1 -- 1147
		} -- 1147
	) -- 1147
	drawMistCurve( -- 1149
		uiArt, -- 1149
		"pause_mist", -- 1149
		menuX + 118, -- 1149
		headY - 8, -- 1149
		290, -- 1149
		72, -- 1149
		PALETTE.jadeMist, -- 1149
		0.2, -- 1149
		-1 -- 1149
	) -- 1149
	texts:put( -- 1151
		"banner", -- 1151
		"暂歇", -- 1151
		menuX + 16, -- 1151
		headY, -- 1151
		toColor(PALETTE.textBright), -- 1151
		0, -- 1151
		0.5, -- 1151
		"Left", -- 1151
		10, -- 1151
		0.98, -- 1151
		0.1 -- 1151
	) -- 1151
	texts:put( -- 1152
		"xs", -- 1152
		"月夜暂驻 · 卷页留痕", -- 1152
		menuX + 18, -- 1152
		headY - 36, -- 1152
		toColor(PALETTE.textDim), -- 1152
		0, -- 1152
		0.5, -- 1152
		"Left", -- 1152
		2, -- 1152
		0.8, -- 1152
		0.08 -- 1152
	) -- 1152
	drawHairline( -- 1153
		uiInkDraw, -- 1153
		uiArt, -- 1153
		"pause_div", -- 1153
		menuX + 124, -- 1153
		headY - 60, -- 1153
		240, -- 1153
		PALETTE.silkDim, -- 1153
		0.58, -- 1153
		true, -- 1153
		2 -- 1153
	) -- 1153
	local rowStep = compact and 42 or 46 -- 1155
	local rowH = compact and 36 or 38 -- 1156
	local firstY = compact and headY - 112 or headY - 120 -- 1157
	local boxes = {} -- 1158
	local i = 0 -- 1159
	do -- 1159
		i = 0 -- 1160
		while i < #pauseItems do -- 1160
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1161
			i = i + 1 -- 1160
		end -- 1160
	end -- 1160
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1163
	do -- 1163
		i = 0 -- 1165
		while i < #pauseItems do -- 1165
			local iy = boxes[i + 1].y -- 1166
			local active = self.pauseSelected == i -- 1167
			local cy = iy + rowH * 0.5 -- 1168
			local shiftX = active and 10 or 0 -- 1169
			local item = pauseItems[i + 1] -- 1170
			local label = item.zh -- 1171
			if item.id == "assist" then -- 1172
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1173
			elseif item.id == "fullscreen" then -- 1174
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1175
			elseif item.id == "settings" then -- 1176
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1177
			end -- 1177
			if active then -- 1180
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1181
				drawSilkRibbon( -- 1182
					uiDraw, -- 1182
					uiArt, -- 1182
					"pause_rib_" .. tostring(i), -- 1182
					menuX + 116, -- 1182
					cy, -- 1182
					282, -- 1182
					rowH, -- 1182
					PALETTE.rougeSoft, -- 1182
					0.54 * breathe, -- 1182
					0 -- 1182
				) -- 1182
				drawHairline( -- 1183
					uiInkDraw, -- 1183
					uiArt, -- 1183
					"pause_line_" .. tostring(i), -- 1183
					menuX + 106, -- 1183
					iy + 3, -- 1183
					210, -- 1183
					PALETTE.silkLine, -- 1183
					0.42 * breathe, -- 1183
					false, -- 1183
					2 -- 1183
				) -- 1183
				drawBlossomDot( -- 1184
					uiInkDraw, -- 1184
					uiArt, -- 1184
					"pause_dot_" .. tostring(i), -- 1184
					menuX + 12, -- 1184
					cy, -- 1184
					15, -- 1184
					PALETTE.rouge, -- 1184
					0.96, -- 1184
					4 -- 1184
				) -- 1184
				fillRadialGlow( -- 1185
					uiGlow, -- 1185
					menuX + 12, -- 1185
					cy, -- 1185
					22, -- 1185
					16, -- 1185
					toColor(PALETTE.rouge, 26 * breathe), -- 1185
					Color(182, 58, 56, 0), -- 1185
					10 -- 1185
				) -- 1185
			else -- 1185
				drawBlossomDot( -- 1187
					uiInkDraw, -- 1187
					uiArt, -- 1187
					"pause_dot_" .. tostring(i), -- 1187
					menuX + 12, -- 1187
					cy, -- 1187
					8, -- 1187
					PALETTE.silkDim, -- 1187
					0.4, -- 1187
					3 -- 1187
				) -- 1187
			end -- 1187
			texts:put( -- 1190
				compact and "sm" or "md", -- 1191
				label, -- 1192
				menuX + 32 + shiftX, -- 1193
				cy, -- 1194
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1195
				0, -- 1196
				0.5, -- 1197
				"Left", -- 1198
				active and 3.4 or 2.2, -- 1199
				active and 1 or 0.88, -- 1200
				0.1 -- 1201
			) -- 1201
			i = i + 1 -- 1165
		end -- 1165
	end -- 1165
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1205
	texts:put( -- 1210
		"xs", -- 1210
		pauseFooter, -- 1210
		menuX + 12, -- 1210
		38 + frame.safe.bottom * 0.4, -- 1210
		toColor(PALETTE.textDim), -- 1210
		0, -- 1210
		0.5, -- 1210
		"Left", -- 1210
		1.2, -- 1210
		0.86, -- 1210
		0.08 -- 1210
	) -- 1210
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1212
	if hit >= 0 or frame.keys.confirm then -- 1213
		local idx = hit >= 0 and hit or self.pauseSelected -- 1214
		local id = pauseItems[idx + 1].id -- 1215
		if id == "controls" then -- 1216
			self.pauseShowControls = true -- 1217
			self:resetInput() -- 1218
			return {type = "none"} -- 1219
		end -- 1219
		if id == "settings" then -- 1221
			self:openPauseSettings() -- 1222
			return {type = "none"} -- 1223
		end -- 1223
		if id == "assist" then -- 1225
			if onToggleAssist ~= nil then -- 1226
				onToggleAssist() -- 1227
			end -- 1227
			self:resetInput() -- 1229
			return {type = "none"} -- 1230
		end -- 1230
		if id == "fullscreen" then -- 1232
			self:resetInput() -- 1233
			return {type = "toggleFullscreen"} -- 1234
		end -- 1234
		self.pauseShowControls = false -- 1236
		self.pauseShowSettings = false -- 1237
		if id == "resume" then -- 1238
			return {type = "resume"} -- 1238
		end -- 1238
		if id == "retry" then -- 1239
			return {type = "retry"} -- 1239
		end -- 1239
		if id == "chapters" then -- 1240
			return {type = "openChapters"} -- 1240
		end -- 1240
		if id == "quit" then -- 1241
			return {type = "quit"} -- 1241
		end -- 1241
		return {type = "toTitle"} -- 1242
	end -- 1242
	return {type = "none"} -- 1244
end -- 1089
return ____exports -- 1089
