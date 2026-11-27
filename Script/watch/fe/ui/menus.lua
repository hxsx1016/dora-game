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
local ____theme = require("Script.watch.fe.theme") -- 40
local PALETTE = ____theme.PALETTE -- 41
local drawBlossomDot = ____theme.drawBlossomDot -- 42
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 43
local drawHairline = ____theme.drawHairline -- 44
local drawLoneSeal = ____theme.drawLoneSeal -- 45
local drawMistCurve = ____theme.drawMistCurve -- 46
local drawSilkKeycap = ____theme.drawSilkKeycap -- 47
local drawSilkRibbon = ____theme.drawSilkRibbon -- 48
local drawSilkVeil = ____theme.drawSilkVeil -- 49
local fillHGradRect = ____theme.fillHGradRect -- 50
local fillRadialGlow = ____theme.fillRadialGlow -- 51
local fillVGradRect = ____theme.fillVGradRect -- 52
local themeOf = ____theme.themeOf -- 53
local toColor = ____theme.toColor -- 54
local visualTextWidth = ____theme.visualTextWidth -- 55
local TITLE_ITEMS = { -- 82
	{id = "start", zh = "开始游戏"}, -- 83
	{id = "chapters", zh = "选择章节"}, -- 84
	{id = "controls", zh = "操作说明"}, -- 85
	{id = "trial", zh = "护送试炼 · 肉鸽"}, -- 86
	{id = "quit", zh = "退出游戏"} -- 87
} -- 87
local CHAPTERS = __TS__ArrayFilter( -- 91
	__TS__ArrayMap( -- 91
		ROOMS, -- 91
		function(____, room, roomIndex) return {room = room, roomIndex = roomIndex} end -- 91
	), -- 91
	function(____, chapter) return chapter.room.key ~= "museum" end -- 92
) -- 92
local PAUSE_ITEMS = { -- 95
	{id = "resume", zh = "继续游戏"}, -- 96
	{id = "retry", zh = "重试检查点"}, -- 97
	{id = "controls", zh = "操作说明"}, -- 98
	{id = "assist", zh = "按键辅助：关"}, -- 99
	{id = "fullscreen", zh = "显示：窗口"}, -- 100
	{id = "chapters", zh = "选择章节"}, -- 101
	{id = "title", zh = "返回标题"}, -- 102
	{id = "quit", zh = "退出游戏"}, -- 103
	{id = "settings", zh = "操控设置"} -- 104
} -- 104
local SETTINGS_ROWS = { -- 108
	{id = "modePref", title = "操作模式"}, -- 109
	{id = "aimAssist", title = "瞄准磁吸"}, -- 110
	{id = "gpLayout", title = "手柄确认键"}, -- 111
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 112
	{id = "touchOpacity", title = "触控按键透度"}, -- 113
	{id = "touchScale", title = "触控按键大小"}, -- 114
	{id = "haptics", title = "触觉震动反馈"}, -- 115
	{id = "masterVol", title = "主音量"}, -- 116
	{id = "bgmVol", title = "音乐音量"}, -- 117
	{id = "sfxVol", title = "音效与环境"}, -- 118
	{id = "voiceVol", title = "人声音量"}, -- 119
	{id = "back", title = "返回暂歇菜单"} -- 120
} -- 120
local VERTICAL_TITLE = {"向", "西", "守", "望"} -- 123
local EPIGRAPH_RIGHT = { -- 124
	"城", -- 124
	"破", -- 124
	"那", -- 124
	"天", -- 124
	"", -- 124
	"他", -- 124
	"留", -- 124
	"下", -- 124
	"断", -- 124
	"后" -- 124
} -- 124
local EPIGRAPH_LEFT = { -- 125
	"她", -- 125
	"独", -- 125
	"自", -- 125
	"走", -- 125
	"向", -- 125
	"北", -- 125
	"塔" -- 125
} -- 125
local function pressedKeys() -- 150
	return { -- 151
		up = Keyboard:isKeyPressed("Up") or Keyboard:isKeyPressed("W"), -- 152
		down = Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("S"), -- 153
		left = Keyboard:isKeyPressed("Left") or Keyboard:isKeyPressed("A"), -- 154
		right = Keyboard:isKeyPressed("Right") or Keyboard:isKeyPressed("D"), -- 155
		confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") -- 156
	} -- 156
end -- 150
local function hitIndex(boxes, pointer, inside) -- 160
	if not inside then -- 160
		return -1 -- 162
	end -- 162
	return __TS__ArrayFindIndex( -- 164
		boxes, -- 164
		function(____, box) return box:containsPoint(pointer) end -- 164
	) -- 164
end -- 160
____exports.MenuRenderer = __TS__Class() -- 167
local MenuRenderer = ____exports.MenuRenderer -- 167
MenuRenderer.name = "MenuRenderer" -- 167
function MenuRenderer.prototype.____constructor(self) -- 167
	self.selected = 0 -- 168
	self.chapterSelected = 0 -- 169
	self.pauseSelected = 0 -- 170
	self.settingsSelected = 0 -- 171
	self.hasSession = false -- 173
	self.controlsTab = "kbm" -- 175
	self.chaptersFromPause = false -- 187
	self.pauseShowControls = false -- 188
	self.pauseShowSettings = false -- 189
	self.controlsTabManual = false -- 190
	self.previousKeys = {} -- 191
	self.queuedKeys = {} -- 192
	self.queuedBack = false -- 193
	self.queuedSkip = false -- 194
	self.splashTime = 0 -- 195
	self.time = 0 -- 196
end -- 167
function MenuRenderer.prototype.emitSound(self, kind) -- 181
	if self.onUiSound ~= nil then -- 181
		self:onUiSound(kind) -- 183
	end -- 183
end -- 181
function MenuRenderer.prototype.resetSplash(self) -- 198
	self.splashTime = 0 -- 199
	self.queuedSkip = false -- 200
	self:resetInput() -- 201
end -- 198
function MenuRenderer.prototype.isShowingPauseControls(self) -- 204
	return self.pauseShowControls -- 205
end -- 204
function MenuRenderer.prototype.isShowingPauseSettings(self) -- 208
	return self.pauseShowSettings -- 209
end -- 208
function MenuRenderer.prototype.openPauseSettings(self) -- 212
	self.pauseShowControls = false -- 213
	self.pauseShowSettings = true -- 214
	self.settingsSelected = 0 -- 215
	self:resetInput() -- 216
end -- 212
function MenuRenderer.prototype.openChapters(self, roomIndex) -- 219
	self.chaptersFromPause = roomIndex ~= nil -- 220
	self.chapterSelected = math.max( -- 221
		0, -- 221
		__TS__ArrayFindIndex( -- 221
			CHAPTERS, -- 221
			function(____, chapter) return chapter.roomIndex == roomIndex end -- 221
		) -- 221
	) -- 221
	self.pauseShowControls = false -- 222
	self.pauseShowSettings = false -- 223
	self:resetInput() -- 224
end -- 219
function MenuRenderer.prototype.openPause(self) -- 227
	self.pauseSelected = 0 -- 228
	self.pauseShowControls = false -- 229
	self.pauseShowSettings = false -- 230
	self:resetInput() -- 231
end -- 227
function MenuRenderer.prototype.triggerBack(self) -- 235
	self.queuedBack = true -- 236
end -- 235
function MenuRenderer.prototype.resetInput(self) -- 240
	self.previousKeys = pressedKeys() -- 241
	self.queuedKeys = {} -- 242
	self.queuedBack = false -- 243
	self.queuedSkip = false -- 244
	self.controlsTabManual = false -- 245
end -- 240
function MenuRenderer.prototype.onKeyEvent(self, key) -- 249
	self.queuedSkip = true -- 250
	if key == "Up" or key == "W" then -- 250
		self.queuedKeys.up = true -- 252
	elseif key == "Down" or key == "S" then -- 252
		self.queuedKeys.down = true -- 254
	elseif key == "Left" or key == "A" then -- 254
		self.queuedKeys.left = true -- 256
	elseif key == "Right" or key == "D" then -- 256
		self.queuedKeys.right = true -- 258
	elseif key == "Return" or key == "Space" then -- 258
		self.queuedKeys.confirm = true -- 260
	elseif key == "Escape" then -- 260
		self.queuedBack = true -- 262
	end -- 262
end -- 249
function MenuRenderer.prototype.readFrame(self, input, scale, safe) -- 266
	local held = pressedKeys() -- 267
	local prev = self.previousKeys -- 268
	local queued = self.queuedKeys -- 269
	local useUiPtr = input.uiInside or input.uiPressed -- 272
	local rawX = useUiPtr and input.uiX or input.mx -- 273
	local rawY = useUiPtr and input.uiY or input.my -- 274
	local rawDx = useUiPtr and input.uiDx or input.mdx -- 275
	local rawDy = useUiPtr and input.uiDy or input.mdy -- 276
	local ____useUiPtr_0 -- 277
	if useUiPtr then -- 277
		____useUiPtr_0 = input.uiInside -- 277
	else -- 277
		____useUiPtr_0 = input.inside -- 277
	end -- 277
	local inside = ____useUiPtr_0 -- 277
	local ____useUiPtr_1 -- 278
	if useUiPtr then -- 278
		____useUiPtr_1 = input.uiInside and input.uiPressed -- 278
	else -- 278
		____useUiPtr_1 = input.inside and input.fire.pressed -- 278
	end -- 278
	local click = ____useUiPtr_1 -- 278
	local touchMode = input:isTouchMode() -- 279
	local frame = { -- 281
		keys = { -- 282
			up = queued.up == true or held.up and not prev.up or input.navUp, -- 283
			down = queued.down == true or held.down and not prev.down or input.navDown, -- 284
			left = queued.left == true or held.left and not prev.left or input.navLeft, -- 285
			right = queued.right == true or held.right and not prev.right or input.navRight, -- 286
			confirm = queued.confirm == true or held.confirm and not prev.confirm or input.navConfirm -- 287
		}, -- 287
		back = self.queuedBack or input.pause.pressed or input.navBack, -- 289
		prevTab = input.navPrevTab, -- 290
		nextTab = input.navNextTab, -- 291
		skipInput = self.queuedSkip or input.splashSkipPressed, -- 292
		pointer = Vec2(rawX / scale, rawY / scale), -- 293
		inside = inside, -- 294
		click = click, -- 295
		pointerMoved = not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= scale, -- 296
		mode = input.inputMode, -- 297
		layout = input.gamepadLayout, -- 298
		safe = safe -- 299
	} -- 299
	self.previousKeys = held -- 301
	self.queuedKeys = {} -- 302
	self.queuedBack = false -- 303
	self.queuedSkip = false -- 304
	return frame -- 305
end -- 266
function MenuRenderer.prototype.verticalSelection(self, selected, boxes, frame) -- 308
	local hit = hitIndex(boxes, frame.pointer, frame.inside) -- 309
	if frame.click and hit >= 0 then -- 309
		return hit -- 311
	end -- 311
	if frame.keys.up then -- 311
		return (selected + #boxes - 1) % #boxes -- 314
	end -- 314
	if frame.keys.down then -- 314
		return (selected + 1) % #boxes -- 317
	end -- 317
	return frame.pointerMoved and hit >= 0 and not frame.keys.confirm and hit or selected -- 319
end -- 308
function MenuRenderer.prototype.updateAndDrawScreen(self, dt, screen, input, stage, bgDraw, bgGlow, backdropArt, uiArt, uiDraw, uiInkDraw, uiGlow, texts, w, h, uiScale, safeUi) -- 322
	if safeUi == nil then -- 322
		safeUi = ZERO_SAFE_INSETS -- 338
	end -- 338
	self.time = self.time + dt -- 340
	local splashDissolving = screen == "splash" and self.splashTime >= 4.15 -- 341
	if screen ~= "splash" or splashDissolving then -- 341
		local artW = math.max(w, h * 16 / 9) -- 343
		local artH = artW * 9 / 16 -- 344
		if not backdropArt:tryPlace( -- 344
			"title_backdrop", -- 345
			"menu_landscape", -- 345
			w * 0.5, -- 345
			(h - artH) * 0.5, -- 345
			artW, -- 345
			artH -- 345
		) then -- 345
			stage:drawMenuBackdrop( -- 346
				bgDraw, -- 346
				bgGlow, -- 346
				w, -- 346
				h, -- 346
				self.time -- 346
			) -- 346
		end -- 346
	end -- 346
	local frame = self:readFrame(input, uiScale, safeUi) -- 350
	w = w / uiScale -- 351
	h = h / uiScale -- 352
	if screen == "splash" then -- 352
		return self:drawSplash( -- 355
			dt, -- 355
			frame, -- 355
			uiDraw, -- 355
			uiArt, -- 355
			texts, -- 355
			w, -- 355
			h -- 355
		) -- 355
	end -- 355
	if screen == "title" then -- 355
		return self:drawTitle( -- 358
			frame, -- 358
			uiDraw, -- 358
			uiInkDraw, -- 358
			uiArt, -- 358
			uiGlow, -- 358
			texts, -- 358
			w, -- 358
			h -- 358
		) -- 358
	end -- 358
	if screen == "chapters" then -- 358
		return self:drawChapters( -- 361
			frame, -- 361
			uiDraw, -- 361
			uiInkDraw, -- 361
			uiArt, -- 361
			uiGlow, -- 361
			texts, -- 361
			w, -- 361
			h -- 361
		) -- 361
	end -- 361
	return self:drawControls( -- 363
		frame, -- 363
		uiDraw, -- 363
		uiInkDraw, -- 363
		uiArt, -- 363
		uiGlow, -- 363
		texts, -- 363
		w, -- 363
		h -- 363
	) -- 363
end -- 322
function MenuRenderer.prototype.drawSplash(self, dt, frame, uiDraw, uiArt, texts, w, h) -- 372
	local safeDt = math.min( -- 381
		0.1, -- 381
		math.max(0, dt) -- 381
	) -- 381
	self.splashTime = self.splashTime + safeDt -- 382
	local t = self.splashTime -- 383
	local wantSkip = t >= 0.25 and (frame.skipInput or frame.click or frame.keys.confirm or frame.back) -- 385
	if wantSkip or t >= 4.65 then -- 385
		self.splashTime = 0 -- 387
		return {type = "splashDone"} -- 388
	end -- 388
	local fadeOutCurtain = t >= 4.2 and math.max(0, 1 - (t - 4.2) / 0.45) or 1 -- 391
	local bgR = t < 2.2 and 13 or 11 -- 392
	local bgG = t < 2.2 and 16 or 13 -- 393
	local bgB = t < 2.2 and 24 or 19 -- 394
	uiDraw:drawRect( -- 395
		Rect(0, 0, w, h), -- 395
		Color( -- 395
			bgR, -- 395
			bgG, -- 395
			bgB, -- 395
			math.floor(255 * fadeOutCurtain + 0.5) -- 395
		) -- 395
	) -- 395
	local function smoothEnvelope(localT, fadeIn, holdEnd, endT) -- 397
		if localT <= 0 or localT >= endT then -- 397
			return 0 -- 398
		end -- 398
		if localT < fadeIn then -- 398
			local u = localT / fadeIn -- 400
			return u * u * (3 - 2 * u) -- 401
		end -- 401
		if localT <= holdEnd then -- 401
			return 1 -- 403
		end -- 403
		local u = (localT - holdEnd) / math.max(0.01, endT - holdEnd) -- 404
		return 1 - u * u * (3 - 2 * u) -- 405
	end -- 397
	if t < 2.2 then -- 397
		local alpha = smoothEnvelope(t, 0.42, 1.72, 2.2) -- 409
		local scaleBreath = 0.985 + 0.03 * (t / 2.2) -- 410
		local logoH = math.min(384, h * 0.54) * scaleBreath -- 411
		if not uiArt:tryPlace( -- 411
			"brand_team_logo", -- 412
			"splash_team_logo", -- 412
			w * 0.5, -- 412
			h * 0.54, -- 412
			logoH * 2, -- 412
			logoH, -- 412
			{opacity = alpha, layer = 2} -- 412
		) then -- 412
			texts:put( -- 413
				"banner", -- 413
				"OUTSIDER", -- 413
				w * 0.5, -- 413
				h * 0.52, -- 413
				toColor(PALETTE.textBright), -- 413
				0.5, -- 413
				0.5, -- 413
				"Center", -- 413
				6, -- 413
				alpha, -- 413
				0 -- 413
			) -- 413
		end -- 413
		texts:put( -- 415
			"xs", -- 415
			"Powered by Dora SSR", -- 415
			w * 0.5, -- 415
			58 + frame.safe.bottom * 0.4, -- 415
			toColor(PALETTE.textDim), -- 415
			0.5, -- 415
			0.5, -- 415
			"Center", -- 415
			1.8, -- 415
			alpha * 0.62, -- 415
			0 -- 415
		) -- 415
	elseif t < 4.25 then -- 415
		local localT = t - 2.2 -- 417
		local alpha = smoothEnvelope(localT, 0.45, 1.6, 2.05) -- 418
		local sway = math.sin(localT * 1.1) * 8 -- 419
		drawMistCurve( -- 420
			uiArt, -- 420
			"splash_game_mist", -- 420
			w * 0.5 + sway, -- 420
			h * 0.46, -- 420
			560, -- 420
			110, -- 420
			PALETTE.jadeMist, -- 420
			0.16 * alpha, -- 420
			1 -- 420
		) -- 420
		local scaleBreath = 0.985 + 0.028 * (localT / 2.05) -- 421
		local logoH = math.min(310, h * 0.44) * scaleBreath -- 422
		if not uiArt:tryPlace( -- 422
			"brand_game_logo_h", -- 423
			"splash_game_logo", -- 423
			w * 0.5, -- 423
			h * 0.52, -- 423
			logoH * 2.4, -- 423
			logoH, -- 423
			{opacity = alpha, layer = 2} -- 423
		) then -- 423
			texts:put( -- 424
				"title", -- 424
				"向西守望", -- 424
				w * 0.5, -- 424
				h * 0.52, -- 424
				toColor(PALETTE.textBright), -- 424
				0.5, -- 424
				0.5, -- 424
				"Center", -- 424
				8, -- 424
				alpha, -- 424
				0 -- 424
			) -- 424
		end -- 424
	end -- 424
	if t >= 0.35 and t < 4.15 then -- 424
		local hintA = math.min(1, (t - 0.35) / 0.35) * 0.52 -- 429
		local skipText = frame.mode == "touch" and "轻触跳过" or (frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) .. " / START  跳过" or "ESC / SPACE  SKIP") -- 430
		texts:put( -- 435
			"xs", -- 435
			skipText, -- 435
			w - 48 - frame.safe.right * 0.6, -- 435
			36 + frame.safe.bottom * 0.4, -- 435
			toColor(PALETTE.textDim), -- 435
			1, -- 435
			0.5, -- 435
			"Right", -- 435
			1.4, -- 435
			hintA, -- 435
			0 -- 435
		) -- 435
	end -- 435
	return {type = "none"} -- 438
end -- 372
function MenuRenderer.prototype.drawTitle(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 441
	fillHGradRect( -- 451
		uiDraw, -- 451
		0, -- 451
		0, -- 451
		w * 0.22 + frame.safe.left * 0.5, -- 451
		h, -- 451
		Color(9, 11, 18, 192), -- 451
		Color(9, 11, 18, 116) -- 451
	) -- 451
	fillHGradRect( -- 452
		uiDraw, -- 452
		w * 0.22 + frame.safe.left * 0.5, -- 452
		0, -- 452
		w * 0.28, -- 452
		h, -- 452
		Color(9, 11, 18, 116), -- 452
		Color(9, 11, 18, 0) -- 452
	) -- 452
	fillVGradRect( -- 453
		uiDraw, -- 453
		0, -- 453
		0, -- 453
		w, -- 453
		78, -- 453
		Color(8, 10, 16, 138), -- 453
		Color(8, 10, 16, 0) -- 453
	) -- 453
	local extraH = math.max(0, h - 720) -- 455
	local titleX = 148 + frame.safe.left * 0.6 -- 456
	local topY = h - 104 - frame.safe.top * 0.4 -- 457
	local charStep = 66 -- 458
	local sway = math.sin(self.time * 0.7) * 5 -- 459
	drawMistCurve( -- 460
		uiArt, -- 460
		"title_mist_wisp", -- 460
		titleX + 86 + sway, -- 460
		topY - 122, -- 460
		340, -- 460
		82, -- 460
		PALETTE.jadeMist, -- 460
		0.2, -- 460
		-1 -- 460
	) -- 460
	uiArt:tryPlace( -- 461
		"ink_petal_mist", -- 461
		"title_petals", -- 461
		titleX + 12, -- 461
		topY - 102, -- 461
		230, -- 461
		210, -- 461
		{ -- 461
			color = toColor(PALETTE.inkMist), -- 462
			opacity = 0.4, -- 462
			layer = -1 -- 462
		} -- 462
	) -- 462
	local placedBrandTitle = uiArt:tryPlace( -- 466
		"brand_game_logo_v", -- 466
		"title_brand_v", -- 466
		titleX + 22, -- 466
		topY - 106, -- 466
		240, -- 466
		304, -- 466
		{opacity = 0.98, layer = 3} -- 466
	) -- 466
	if not placedBrandTitle then -- 466
		uiArt:tryPlace( -- 470
			"ink_vstream", -- 470
			"title_vstream", -- 470
			titleX - 48, -- 470
			topY - 100, -- 470
			34, -- 470
			290, -- 470
			{ -- 470
				color = toColor(PALETTE.silkDim), -- 471
				opacity = 0.48, -- 471
				layer = 1 -- 471
			} -- 471
		) -- 471
		local c = 0 -- 473
		do -- 473
			c = 0 -- 474
			while c < #VERTICAL_TITLE do -- 474
				texts:put( -- 475
					"title", -- 476
					VERTICAL_TITLE[c + 1], -- 477
					titleX, -- 478
					topY - c * charStep, -- 479
					toColor(PALETTE.textBright), -- 480
					0.5, -- 481
					0.5, -- 482
					"Center", -- 483
					0, -- 484
					0.98, -- 485
					0.1, -- 486
					Color(8, 10, 16, 210) -- 487
				) -- 487
				c = c + 1 -- 474
			end -- 474
		end -- 474
		drawLoneSeal( -- 490
			uiInkDraw, -- 491
			uiArt, -- 492
			texts, -- 493
			"title_lone_seal", -- 494
			titleX + 46, -- 495
			topY - 3 * charStep + 8, -- 496
			26, -- 497
			52, -- 498
			"守", -- 499
			"望", -- 500
			PALETTE.sealRed, -- 501
			PALETTE.sealText, -- 502
			0.94, -- 503
			4 -- 504
		) -- 504
	end -- 504
	local colRightX = placedBrandTitle and titleX + 190 or titleX + 132 -- 509
	local colLeftX = placedBrandTitle and titleX + 160 or titleX + 102 -- 510
	local poemStep = 22 -- 511
	local p = 0 -- 512
	do -- 512
		p = 0 -- 513
		while p < #EPIGRAPH_RIGHT do -- 513
			local ch = EPIGRAPH_RIGHT[p + 1] -- 514
			if ch ~= "" then -- 514
				texts:put( -- 516
					"xs", -- 516
					ch, -- 516
					colRightX, -- 516
					topY - 22 - p * poemStep, -- 516
					toColor(PALETTE.textMid), -- 516
					0.5, -- 516
					0.5, -- 516
					"Center", -- 516
					0, -- 516
					0.86, -- 516
					0.08 -- 516
				) -- 516
			end -- 516
			p = p + 1 -- 513
		end -- 513
	end -- 513
	do -- 513
		p = 0 -- 519
		while p < #EPIGRAPH_LEFT do -- 519
			texts:put( -- 520
				"xs", -- 520
				EPIGRAPH_LEFT[p + 1], -- 520
				colLeftX, -- 520
				topY - 68 - p * poemStep, -- 520
				toColor(PALETTE.amberCore), -- 520
				0.5, -- 520
				0.5, -- 520
				"Center", -- 520
				0, -- 520
				0.9, -- 520
				0.08 -- 520
			) -- 520
			p = p + 1 -- 519
		end -- 519
	end -- 519
	local baseItems = canQuitApp() and TITLE_ITEMS or __TS__ArrayFilter( -- 524
		TITLE_ITEMS, -- 526
		function(____, it) return it.id ~= "quit" end -- 526
	) -- 526
	local items = self.hasSession and ({ -- 527
		{id = "continue", zh = "继续游戏"}, -- 528
		table.unpack(baseItems) -- 528
	}) or baseItems -- 528
	if self.selected >= #items then -- 528
		self.selected = 0 -- 531
	end -- 531
	local menuX = 112 + frame.safe.left * 0.6 -- 533
	local btnW = 280 -- 534
	local btnH = frame.mode == "touch" and 44 or 40 -- 535
	local gap = self.hasSession and 6 or 8 -- 536
	local startY = (self.hasSession and 298 or 268) + extraH * 0.35 -- 537
	local boxes = {} -- 538
	local i = 0 -- 539
	do -- 539
		i = 0 -- 540
		while i < #items do -- 540
			boxes[#boxes + 1] = Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH) -- 541
			i = i + 1 -- 540
		end -- 540
	end -- 540
	local prevTitleSel = self.selected -- 543
	self.selected = self:verticalSelection(self.selected, boxes, frame) -- 544
	if self.selected ~= prevTitleSel then -- 544
		self:emitSound("hover") -- 546
	end -- 546
	do -- 546
		i = 0 -- 549
		while i < #items do -- 549
			local by = boxes[i + 1].y -- 550
			local active = self.selected == i -- 551
			local cy = by + btnH * 0.5 -- 552
			local shiftX = active and 10 or 0 -- 553
			if active then -- 553
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.2) -- 556
				drawSilkRibbon( -- 557
					uiDraw, -- 557
					uiArt, -- 557
					"title_rib_red_" .. tostring(i), -- 557
					menuX + 124, -- 557
					cy, -- 557
					290, -- 557
					btnH, -- 557
					PALETTE.rougeSoft, -- 557
					0.52 * breathe, -- 557
					0 -- 557
				) -- 557
				drawHairline( -- 558
					uiInkDraw, -- 558
					uiArt, -- 558
					"title_rib_line_" .. tostring(i), -- 558
					menuX + 114, -- 558
					by + 4, -- 558
					230, -- 558
					PALETTE.silkLine, -- 558
					0.42 * breathe, -- 558
					false, -- 558
					2 -- 558
				) -- 558
				drawBlossomDot( -- 559
					uiInkDraw, -- 559
					uiArt, -- 559
					"title_dot_" .. tostring(i), -- 559
					menuX + 14, -- 559
					cy, -- 559
					16, -- 559
					PALETTE.rouge, -- 559
					0.96, -- 559
					4 -- 559
				) -- 559
				fillRadialGlow( -- 560
					uiGlow, -- 560
					menuX + 14, -- 560
					cy, -- 560
					22, -- 560
					16, -- 560
					toColor(PALETTE.rouge, 28 * breathe), -- 560
					Color(182, 58, 56, 0), -- 560
					10 -- 560
				) -- 560
			else -- 560
				drawBlossomDot( -- 562
					uiInkDraw, -- 562
					uiArt, -- 562
					"title_dot_" .. tostring(i), -- 562
					menuX + 14, -- 562
					cy, -- 562
					8, -- 562
					PALETTE.silkDim, -- 562
					0.4, -- 562
					3 -- 562
				) -- 562
			end -- 562
			texts:put( -- 565
				"md", -- 566
				items[i + 1].zh, -- 567
				menuX + 34 + shiftX, -- 568
				cy, -- 569
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 570
				0, -- 571
				0.5, -- 572
				"Left", -- 573
				active and 4.4 or 2.8, -- 574
				active and 1 or 0.88, -- 575
				0.1 -- 576
			) -- 576
			i = i + 1 -- 549
		end -- 549
	end -- 549
	local titleHint = frame.mode == "gamepad" and ("左摇杆 / 十字键择项   ·   " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 或点选启程" or (frame.mode == "touch" and (getPlatformCaps().hasBackButton and canQuitApp() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持键鼠与手柄") or "上下择项   ·   回车或点选启程") -- 580
	texts:put( -- 587
		"xs", -- 587
		titleHint, -- 587
		menuX + 12, -- 587
		42 + frame.safe.bottom * 0.45, -- 587
		toColor(PALETTE.textDim), -- 587
		0, -- 587
		0.5, -- 587
		"Left", -- 587
		1.4, -- 587
		0.88, -- 587
		0.08 -- 587
	) -- 587
	local badgeRight = w - frame.safe.right * 0.5 -- 590
	local badgeY = 42 + frame.safe.bottom * 0.4 -- 591
	fillHGradRect( -- 592
		uiDraw, -- 592
		badgeRight - 270, -- 592
		0, -- 592
		270 + frame.safe.right * 0.5, -- 592
		86, -- 592
		Color(8, 10, 16, 0), -- 592
		Color(8, 10, 16, 204) -- 592
	) -- 592
	uiArt:tryPlace( -- 593
		"brand_team_badge", -- 593
		"title_team_badge", -- 593
		badgeRight - 118, -- 593
		badgeY, -- 593
		168, -- 593
		54, -- 593
		{opacity = 0.95, layer = 3} -- 593
	) -- 593
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 597
	if hit >= 0 or frame.keys.confirm then -- 597
		local idx = hit >= 0 and hit or self.selected -- 599
		local id = items[idx + 1].id -- 600
		if id == "continue" then -- 600
			self:emitSound("start") -- 601
			return {type = "continue"} -- 601
		end -- 601
		if id == "trial" then -- 601
			self:emitSound("start") -- 602
			return {type = "trial"} -- 602
		end -- 602
		if id == "start" then -- 602
			self:emitSound("start") -- 603
			return {type = "start"} -- 603
		end -- 603
		if id == "chapters" then -- 603
			self:emitSound("confirm") -- 604
			return {type = "openChapters"} -- 604
		end -- 604
		if id == "quit" then -- 604
			self:emitSound("back") -- 605
			return {type = "quit"} -- 605
		end -- 605
		self:emitSound("confirm") -- 606
		return {type = "openControls"} -- 607
	end -- 607
	return {type = "none"} -- 609
end -- 441
function MenuRenderer.prototype.drawChapters(self, frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 612
	local back = {type = self.chaptersFromPause and "backPause" or "backTitle"} -- 622
	if frame.back then -- 622
		self:emitSound("back") -- 624
		return back -- 625
	end -- 625
	local extraH = math.max(0, h - 720) -- 628
	local marginX = math.max( -- 629
		96, -- 629
		56 + math.max(frame.safe.left, frame.safe.right) -- 629
	) -- 629
	local splitTrack = #CHAPTERS > 8 -- 630
	local perRow = splitTrack and math.ceil(#CHAPTERS / 2) or #CHAPTERS -- 631
	local trackY = (splitTrack and 195 or 148) + extraH * 0.25 -- 632
	local rowGap = 84 -- 633
	local trackX0 = marginX + 34 -- 634
	local trackX1 = w - marginX - 34 -- 635
	local stepX = (trackX1 - trackX0) / math.max(1, perRow - 1) -- 636
	local stationBoxes = {} -- 638
	local s = 0 -- 639
	do -- 639
		s = 0 -- 640
		while s < #CHAPTERS do -- 640
			local sx = trackX0 + s % perRow * stepX -- 641
			local sy = trackY - math.floor(s / perRow) * rowGap -- 642
			stationBoxes[#stationBoxes + 1] = Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74) -- 643
			s = s + 1 -- 640
		end -- 640
	end -- 640
	local prevSelected = self.chapterSelected -- 646
	local hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside) -- 647
	local keys = frame.keys -- 648
	if frame.click and hitStation >= 0 then -- 648
		self.chapterSelected = hitStation -- 650
	elseif keys.left or keys.right or not splitTrack and (keys.up or keys.down) then -- 650
		local step = keys.left and -1 or (keys.right and 1 or 4) -- 652
		self.chapterSelected = (self.chapterSelected + step + #CHAPTERS) % #CHAPTERS -- 653
	elseif keys.down and self.chapterSelected < perRow then -- 653
		self.chapterSelected = math.min(#CHAPTERS - 1, self.chapterSelected + perRow) -- 655
	elseif keys.up and self.chapterSelected >= perRow then -- 655
		self.chapterSelected = self.chapterSelected - perRow -- 657
	elseif frame.pointerMoved and hitStation >= 0 and not keys.confirm then -- 657
		self.chapterSelected = hitStation -- 659
	end -- 659
	if self.chapterSelected ~= prevSelected then -- 659
		self:emitSound("hover") -- 662
	end -- 662
	uiDraw:drawRect( -- 665
		Rect(0, 0, w, h), -- 665
		Color(10, 12, 19, 198) -- 665
	) -- 665
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 667
	texts:put( -- 668
		"banner", -- 668
		"选择章节", -- 668
		marginX, -- 668
		topHeadY, -- 668
		toColor(PALETTE.textBright), -- 668
		0, -- 668
		0.5, -- 668
		"Left", -- 668
		4.5, -- 668
		0.96, -- 668
		0.1 -- 668
	) -- 668
	drawHairline( -- 669
		uiInkDraw, -- 669
		uiArt, -- 669
		"chap_top_line", -- 669
		w * 0.5, -- 669
		topHeadY - 34, -- 669
		w - marginX * 2, -- 669
		PALETTE.silkDim, -- 669
		0.6, -- 669
		true, -- 669
		2 -- 669
	) -- 669
	local activeRoom = CHAPTERS[self.chapterSelected + 1].room -- 671
	local theme = themeOf(activeRoom.key) -- 672
	local winX = marginX -- 673
	local winY = 266 + extraH * 0.44 -- 674
	local winW = math.min( -- 675
		548, -- 675
		math.max(420, w * 0.43) -- 675
	) -- 675
	local winH = 300 -- 676
	local winBox = Rect(winX, winY, winW, winH) -- 677
	local winHover = frame.inside and winBox:containsPoint(frame.pointer) -- 678
	uiArt:tryPlace( -- 680
		"ink_frame_mask", -- 680
		"chap_win_shadow", -- 680
		winX + winW * 0.5, -- 680
		winY + winH * 0.5, -- 680
		winW + 40, -- 680
		winH + 34, -- 680
		{ -- 680
			color = toColor(PALETTE.inkVoid), -- 681
			opacity = 0.88, -- 681
			layer = -2 -- 681
		} -- 681
	) -- 681
	local bgSlot = "bgFar_" .. (theme.backdropKey or activeRoom.key) -- 683
	uiArt:tryPlace( -- 684
		bgSlot, -- 684
		"chap_win_art", -- 684
		winX + winW * 0.5, -- 684
		winY + 4, -- 684
		winW - 8, -- 684
		winH - 8, -- 684
		{opacity = 0.92, layer = -1} -- 684
	) -- 684
	fillVGradRect( -- 687
		uiInkDraw, -- 687
		winX, -- 687
		winY, -- 687
		winW, -- 687
		56, -- 687
		Color(10, 12, 19, 200), -- 687
		Color(10, 12, 19, 0) -- 687
	) -- 687
	fillVGradRect( -- 688
		uiInkDraw, -- 688
		winX, -- 688
		winY + winH - 36, -- 688
		winW, -- 688
		36, -- 688
		Color(10, 12, 19, 0), -- 688
		Color(10, 12, 19, 130) -- 688
	) -- 688
	fillHGradRect( -- 689
		uiInkDraw, -- 689
		winX, -- 689
		winY, -- 689
		34, -- 689
		winH, -- 689
		Color(10, 12, 19, 135), -- 689
		Color(10, 12, 19, 0) -- 689
	) -- 689
	fillHGradRect( -- 690
		uiInkDraw, -- 690
		winX + winW - 34, -- 690
		winY, -- 690
		34, -- 690
		winH, -- 690
		Color(10, 12, 19, 0), -- 690
		Color(10, 12, 19, 135) -- 690
	) -- 690
	drawFiligreeCorners( -- 691
		uiInkDraw, -- 691
		uiArt, -- 691
		"chap_win_frame", -- 691
		winX, -- 691
		winY, -- 691
		winW, -- 691
		winH, -- 691
		winHover and PALETTE.textBright or PALETTE.silkLine, -- 691
		winHover and 0.92 or 0.72, -- 691
		34, -- 691
		true, -- 691
		3 -- 691
	) -- 691
	texts:put( -- 693
		"xs", -- 693
		(theme.actCode .. "  ·  ") .. theme.lineTag, -- 693
		winX + 20, -- 693
		winY + 22, -- 693
		toColor(PALETTE.textMid), -- 693
		0, -- 693
		0.5, -- 693
		"Left", -- 693
		1.8, -- 693
		0.9, -- 693
		0.08 -- 693
	) -- 693
	local infoX = winX + winW + 46 -- 695
	local infoCenterY = winY + winH * 0.5 -- 696
	drawMistCurve( -- 697
		uiArt, -- 697
		"chap_info_mist", -- 697
		infoX + 210, -- 697
		infoCenterY + 36, -- 697
		420, -- 697
		88, -- 697
		theme.accent, -- 697
		0.22, -- 697
		-1 -- 697
	) -- 697
	local volCol = theme.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber -- 699
	texts:put( -- 700
		"xs", -- 700
		theme.volumeTagZh, -- 700
		infoX, -- 700
		winY + winH - 44, -- 700
		toColor(volCol), -- 700
		0, -- 700
		0.5, -- 700
		"Left", -- 700
		2.8, -- 700
		0.92, -- 700
		0.08 -- 700
	) -- 700
	local sep = " · " -- 702
	local sIdx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 703
	local titleY = winY + winH - 98 -- 704
	if theme.backdropKey ~= nil then -- 704
		texts:put( -- 706
			"lg", -- 706
			theme.titleZh, -- 706
			infoX, -- 706
			titleY, -- 706
			toColor(PALETTE.textBright) -- 706
		) -- 706
	elseif sIdx > 0 then -- 706
		local leftPart = __TS__StringSlice(theme.titleZh, 0, sIdx) -- 708
		local rightPart = __TS__StringSlice(theme.titleZh, sIdx + #sep) -- 709
		local lw = visualTextWidth(leftPart, 40) -- 710
		texts:put( -- 711
			"banner", -- 711
			leftPart, -- 711
			infoX, -- 711
			titleY, -- 711
			toColor(PALETTE.textBright), -- 711
			0, -- 711
			0.5, -- 711
			"Left", -- 711
			2, -- 711
			1, -- 711
			0.1 -- 711
		) -- 711
		drawBlossomDot( -- 712
			uiInkDraw, -- 712
			uiArt, -- 712
			"chap_title_dot", -- 712
			infoX + lw + 16, -- 712
			titleY - 2, -- 712
			11, -- 712
			activeRoom.key == "gate" and PALETTE.rouge or PALETTE.silkLine, -- 712
			0.9, -- 712
			4 -- 712
		) -- 712
		texts:put( -- 713
			"banner", -- 713
			rightPart, -- 713
			infoX + lw + 32, -- 713
			titleY, -- 713
			toColor(PALETTE.textBright), -- 713
			0, -- 713
			0.5, -- 713
			"Left", -- 713
			2, -- 713
			1, -- 713
			0.1 -- 713
		) -- 713
	else -- 713
		texts:put( -- 715
			"banner", -- 715
			theme.titleZh, -- 715
			infoX, -- 715
			titleY, -- 715
			toColor(PALETTE.textBright), -- 715
			0, -- 715
			0.5, -- 715
			"Left", -- 715
			2.4, -- 715
			1, -- 715
			0.1 -- 715
		) -- 715
	end -- 715
	drawHairline( -- 718
		uiInkDraw, -- 718
		uiArt, -- 718
		"chap_info_line", -- 718
		infoX + 185, -- 718
		titleY - 36, -- 718
		370, -- 718
		PALETTE.silkDim, -- 718
		0.58, -- 718
		false, -- 718
		2 -- 718
	) -- 718
	texts:put( -- 719
		"sm", -- 719
		theme.introWhisper, -- 719
		infoX, -- 719
		titleY - 72, -- 719
		toColor(PALETTE.textMid), -- 719
		0, -- 719
		0.5, -- 719
		"Left", -- 719
		0.8, -- 719
		0.94, -- 719
		0.08 -- 719
	) -- 719
	local goX = infoX -- 721
	local goY = winY + 26 -- 722
	local goW = 220 -- 723
	local goH = 42 -- 724
	local goBox = Rect(goX, goY, goW, goH) -- 725
	local goHover = frame.inside and goBox:containsPoint(frame.pointer) -- 726
	local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 727
	drawSilkRibbon( -- 728
		uiDraw, -- 728
		uiArt, -- 728
		"chap_go_rib", -- 728
		goX + 106, -- 728
		goY + 21, -- 728
		250, -- 728
		40, -- 728
		goHover and PALETTE.rouge or PALETTE.rougeSoft, -- 728
		(goHover and 0.68 or 0.46) * breathe, -- 728
		0 -- 728
	) -- 728
	drawHairline( -- 729
		uiInkDraw, -- 729
		uiArt, -- 729
		"chap_go_line", -- 729
		goX + 94, -- 729
		goY + 3, -- 729
		196, -- 729
		PALETTE.silkLine, -- 729
		goHover and 0.68 or 0.4, -- 729
		false, -- 729
		2 -- 729
	) -- 729
	drawBlossomDot( -- 730
		uiInkDraw, -- 730
		uiArt, -- 730
		"chap_go_dot", -- 730
		goX + 14, -- 730
		goY + 21, -- 730
		14, -- 730
		PALETTE.rouge, -- 730
		0.96, -- 730
		4 -- 730
	) -- 730
	texts:put( -- 731
		"md", -- 731
		"入此卷章", -- 731
		goX + 34, -- 731
		goY + 21, -- 731
		toColor(PALETTE.textBright), -- 731
		0, -- 731
		0.5, -- 731
		"Left", -- 731
		3.8, -- 731
		1, -- 731
		0.1 -- 731
	) -- 731
	local chapConfirmTag = frame.mode == "gamepad" and keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "点选" or "Enter") -- 732
	texts:put( -- 735
		"xs", -- 735
		chapConfirmTag, -- 735
		goX + 156, -- 735
		goY + 21, -- 735
		toColor(PALETTE.textDim), -- 735
		0, -- 735
		0.5, -- 735
		"Left", -- 735
		1, -- 735
		0.82, -- 735
		0.08 -- 735
	) -- 735
	drawSilkVeil( -- 737
		uiDraw, -- 737
		uiArt, -- 737
		"chap_track_veil", -- 737
		w * 0.5, -- 737
		trackY + 6, -- 737
		w - marginX * 1.1, -- 737
		126, -- 737
		PALETTE.inkWash, -- 737
		0.72, -- 737
		-2 -- 737
	) -- 737
	drawMistCurve( -- 738
		uiArt, -- 738
		"chap_track_mist", -- 738
		w * 0.5, -- 738
		trackY, -- 738
		trackX1 - trackX0 + 160, -- 738
		74, -- 738
		PALETTE.inkMist, -- 738
		0.62, -- 738
		-1 -- 738
	) -- 738
	uiInkDraw:drawSegment( -- 739
		Vec2(trackX0, trackY), -- 739
		Vec2(trackX1, trackY), -- 739
		0.9, -- 739
		toColor(PALETTE.silkDim, 145) -- 739
	) -- 739
	if splitTrack then -- 739
		local lastX = trackX0 + (#CHAPTERS - perRow - 1) * stepX -- 742
		uiInkDraw:drawSegment( -- 743
			Vec2(trackX0, trackY - rowGap), -- 743
			Vec2(lastX, trackY - rowGap), -- 743
			0.9, -- 743
			toColor(PALETTE.silkDim, 145) -- 743
		) -- 743
	else -- 743
		local midDivX = trackX0 + stepX * 3.5 -- 745
		uiInkDraw:drawSegment( -- 746
			Vec2(midDivX, trackY - 12), -- 746
			Vec2(midDivX, trackY + 12), -- 746
			0.8, -- 746
			toColor(PALETTE.silkDim, 120) -- 746
		) -- 746
		texts:put( -- 747
			"xs", -- 747
			"上卷 · 孤城护童", -- 747
			trackX0 + stepX * 1.5, -- 747
			trackY + 52, -- 747
			toColor(PALETTE.cyan), -- 747
			0.5, -- 747
			0.5, -- 747
			"Center", -- 747
			2.2, -- 747
			0.88, -- 747
			0.08 -- 747
		) -- 747
		texts:put( -- 748
			"xs", -- 748
			"下卷 · 独赴北塔", -- 748
			trackX0 + stepX * 5.5, -- 748
			trackY + 52, -- 748
			toColor(PALETTE.amber), -- 748
			0.5, -- 748
			0.5, -- 748
			"Center", -- 748
			2.2, -- 748
			0.88, -- 748
			0.08 -- 748
		) -- 748
	end -- 748
	local i = 0 -- 751
	do -- 751
		i = 0 -- 752
		while i < #CHAPTERS do -- 752
			local box = stationBoxes[i + 1] -- 753
			local sx = box.x + box.width * 0.5 -- 754
			local sy = box.y + box.height * 0.5 -- 755
			local rt = themeOf(CHAPTERS[i + 1].room.key) -- 756
			local active = self.chapterSelected == i -- 757
			local nodeCol = active and PALETTE.rouge or (rt.lineTag == "周戍" and PALETTE.cyan or PALETTE.amber) -- 758
			if active then -- 758
				fillRadialGlow( -- 761
					uiGlow, -- 761
					sx, -- 761
					sy, -- 761
					26, -- 761
					26, -- 761
					toColor(PALETTE.rouge, 36 * breathe), -- 761
					Color(182, 58, 56, 0), -- 761
					12 -- 761
				) -- 761
				uiArt:tryPlace( -- 762
					"ink_enso_fine", -- 762
					"chap_st_ring_" .. tostring(i), -- 762
					sx, -- 762
					sy, -- 762
					32, -- 762
					32, -- 762
					{ -- 762
						color = toColor(PALETTE.silkLine), -- 763
						opacity = 0.78, -- 763
						angle = self.time * 18, -- 763
						layer = 3 -- 763
					} -- 763
				) -- 763
				drawBlossomDot( -- 765
					uiInkDraw, -- 765
					uiArt, -- 765
					"chap_st_dot_" .. tostring(i), -- 765
					sx, -- 765
					sy, -- 765
					17, -- 765
					PALETTE.rouge, -- 765
					0.98, -- 765
					4 -- 765
				) -- 765
			else -- 765
				uiArt:tryPlace( -- 767
					"ink_enso_fine", -- 767
					"chap_st_ring_" .. tostring(i), -- 767
					sx, -- 767
					sy, -- 767
					16, -- 767
					16, -- 767
					{ -- 767
						color = toColor(nodeCol), -- 768
						opacity = 0.62, -- 768
						layer = 3 -- 768
					} -- 768
				) -- 768
				drawBlossomDot( -- 770
					uiInkDraw, -- 770
					uiArt, -- 770
					"chap_st_dot_" .. tostring(i), -- 770
					sx, -- 770
					sy, -- 770
					7, -- 770
					PALETTE.silkLine, -- 770
					0.72, -- 770
					4 -- 770
				) -- 770
			end -- 770
			if not splitTrack then -- 770
				texts:put( -- 774
					"xs", -- 774
					rt.numeralZh, -- 774
					sx, -- 774
					sy + 25, -- 774
					toColor(active and PALETTE.crimsonCore or PALETTE.textMid), -- 774
					0.5, -- 774
					0.5, -- 774
					"Center", -- 774
					0, -- 774
					active and 1 or 0.88, -- 774
					0.08 -- 774
				) -- 774
			end -- 774
			texts:put( -- 776
				"xs", -- 776
				rt.shortNameZh, -- 776
				sx, -- 776
				sy - 26, -- 776
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 776
				0.5, -- 776
				0.5, -- 776
				"Center", -- 776
				1, -- 776
				active and 1 or 0.84, -- 776
				0.08 -- 776
			) -- 776
			i = i + 1 -- 752
		end -- 752
	end -- 752
	local backX = marginX -- 779
	local backY = 40 + frame.safe.bottom * 0.45 -- 780
	local backBox = Rect(backX - 6, backY - 6, 210, 46) -- 781
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 782
	local chapBackTag = frame.mode == "gamepad" and keyTagFor("back", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC") -- 783
	local chapFooter = frame.mode == "gamepad" and ("摇杆/十字键选择   ·   " .. chapConfirmTag) .. " 或点选进入" or (frame.mode == "touch" and "轻触驿站预览   ·   再点或轻触入此卷章" or "方向键选择   ·   回车或点击进入") -- 786
	drawSilkKeycap( -- 791
		uiInkDraw, -- 791
		texts, -- 791
		backX, -- 791
		backY + 5, -- 791
		48, -- 791
		24, -- 791
		chapBackTag, -- 791
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 791
		0.92, -- 791
		backHover -- 791
	) -- 791
	texts:put( -- 792
		"sm", -- 792
		self.chaptersFromPause and "返回暂停" or "返回标题", -- 792
		backX + 60, -- 792
		backY + 17, -- 792
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 792
		0, -- 792
		0.5, -- 792
		"Left", -- 792
		1.8, -- 792
		0.9, -- 792
		0.08 -- 792
	) -- 792
	texts:put( -- 793
		"xs", -- 793
		chapFooter, -- 793
		w - marginX, -- 793
		backY + 17, -- 793
		toColor(PALETTE.textDim), -- 793
		1, -- 793
		0.5, -- 793
		"Right", -- 793
		1.2, -- 793
		0.75, -- 793
		0.08 -- 793
	) -- 793
	if frame.click and backHover then -- 793
		self:emitSound("back") -- 796
		return back -- 797
	end -- 797
	local ____temp_2 -- 800
	if frame.mode == "touch" then -- 800
		____temp_2 = hitStation >= 0 and hitStation == prevSelected -- 801
	else -- 801
		____temp_2 = hitStation >= 0 -- 802
	end -- 802
	local stationConfirmed = ____temp_2 -- 800
	if keys.confirm or frame.click and (stationConfirmed or winHover or goHover) then -- 800
		self:emitSound("start") -- 804
		return {type = "jump", roomIndex = CHAPTERS[self.chapterSelected + 1].roomIndex} -- 805
	end -- 805
	return {type = "none"} -- 807
end -- 612
function MenuRenderer.prototype.drawControls(self, frame, uiDraw, uiInkDraw, uiArt, _uiGlow, texts, w, h, backLabel) -- 811
	if backLabel == nil then -- 811
		backLabel = "返回标题" -- 820
	end -- 820
	if not self.controlsTabManual then -- 820
		self.controlsTab = frame.mode -- 823
	end -- 823
	local tabOrder = {"kbm", "gamepad", "touch"} -- 825
	local tabLabels = {"键鼠", "手柄", "触屏"} -- 826
	local marginX = math.max( -- 827
		96, -- 827
		56 + math.max(frame.safe.left, frame.safe.right) -- 827
	) -- 827
	local tabW = 92 -- 828
	local tabH = 28 -- 829
	local tabGap = 10 -- 830
	local tabStartX = w - marginX - (tabW * 3 + tabGap * 2) -- 831
	local tabY = h - 82 - frame.safe.top * 0.35 -- 832
	local tabBoxes = { -- 833
		Rect(tabStartX, tabY, tabW, tabH), -- 834
		Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH), -- 835
		Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH) -- 836
	} -- 836
	local hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside) -- 839
	if frame.click and hitTab >= 0 then -- 839
		if self.controlsTab ~= tabOrder[hitTab + 1] then -- 839
			self:emitSound("toggle") -- 842
		end -- 842
		self.controlsTab = tabOrder[hitTab + 1] -- 844
		self.controlsTabManual = true -- 845
	elseif frame.keys.left or frame.prevTab then -- 845
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 847
		self.controlsTab = tabOrder[(cur + #tabOrder - 1) % #tabOrder + 1] -- 848
		self.controlsTabManual = true -- 849
		self:emitSound("toggle") -- 850
	elseif frame.keys.right or frame.nextTab then -- 850
		local cur = __TS__ArrayIndexOf(tabOrder, self.controlsTab) -- 852
		self.controlsTab = tabOrder[(cur + 1) % #tabOrder + 1] -- 853
		self.controlsTabManual = true -- 854
		self:emitSound("toggle") -- 855
	end -- 855
	local backX = marginX -- 858
	local backY = 40 + frame.safe.bottom * 0.45 -- 859
	local backBox = Rect(backX - 6, backY - 6, 250, 46) -- 860
	local backHover = frame.inside and backBox:containsPoint(frame.pointer) -- 861
	if frame.back or frame.keys.confirm and not (frame.click and hitTab >= 0) or frame.click and backHover then -- 861
		self:emitSound("back") -- 863
		return {type = "backTitle"} -- 864
	end -- 864
	uiDraw:drawRect( -- 866
		Rect(0, 0, w, h), -- 866
		Color(10, 12, 19, 204) -- 866
	) -- 866
	local guide = controlsGuideRows(self.controlsTab) -- 868
	local topHeadY = h - 66 - frame.safe.top * 0.35 -- 869
	texts:put( -- 870
		"banner", -- 870
		"执器要诀", -- 870
		marginX, -- 870
		topHeadY, -- 870
		toColor(PALETTE.textBright), -- 870
		0, -- 870
		0.5, -- 870
		"Left", -- 870
		4.5, -- 870
		0.96, -- 870
		0.1 -- 870
	) -- 870
	texts:put( -- 871
		"xs", -- 871
		guide.subtitle, -- 871
		marginX + 196, -- 871
		topHeadY - 4, -- 871
		toColor(PALETTE.textDim), -- 871
		0, -- 871
		0.5, -- 871
		"Left", -- 871
		1.8, -- 871
		0.85, -- 871
		0.08 -- 871
	) -- 871
	drawHairline( -- 872
		uiInkDraw, -- 872
		uiArt, -- 872
		"ctrl_top_line", -- 872
		w * 0.5, -- 872
		topHeadY - 34, -- 872
		w - marginX * 2, -- 872
		PALETTE.silkDim, -- 872
		0.6, -- 872
		true, -- 872
		2 -- 872
	) -- 872
	local ti = 0 -- 874
	do -- 874
		ti = 0 -- 875
		while ti < #tabBoxes do -- 875
			local tb = tabBoxes[ti + 1] -- 876
			local activeTab = self.controlsTab == tabOrder[ti + 1] -- 877
			local hoverTab = hitTab == ti -- 878
			uiInkDraw:drawRect( -- 879
				tb, -- 880
				activeTab and toColor(PALETTE.rougeSoft, 150) or Color(14, 17, 25, hoverTab and 185 or 130), -- 881
				0.9, -- 882
				toColor(activeTab and PALETTE.rouge or (hoverTab and PALETTE.textBright or PALETTE.silkDim), activeTab and 225 or 155) -- 883
			) -- 883
			texts:put( -- 885
				"xs", -- 886
				tabLabels[ti + 1], -- 887
				tb.x + tb.width * 0.5, -- 888
				tb.y + tb.height * 0.5, -- 889
				toColor(activeTab and PALETTE.textBright or PALETTE.textMid), -- 890
				0.5, -- 891
				0.5, -- 892
				"Center", -- 893
				0.8, -- 894
				activeTab and 0.98 or 0.82, -- 895
				0.08 -- 896
			) -- 896
			ti = ti + 1 -- 875
		end -- 875
	end -- 875
	local extraH = math.max(0, h - 720) -- 900
	local areaY = 114 + frame.safe.bottom * 0.4 -- 901
	local areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4 -- 902
	drawFiligreeCorners( -- 903
		uiInkDraw, -- 903
		uiArt, -- 903
		"ctrl_outer", -- 903
		marginX, -- 903
		areaY, -- 903
		w - marginX * 2, -- 903
		areaH, -- 903
		PALETTE.silkDim, -- 903
		0.52, -- 903
		34, -- 903
		false, -- 903
		2 -- 903
	) -- 903
	local midX = w * 0.5 -- 905
	uiArt:tryPlace( -- 906
		"ink_vstream", -- 906
		"ctrl_mid_stream", -- 906
		midX, -- 906
		areaY + areaH * 0.5, -- 906
		32, -- 906
		areaH - 18, -- 906
		{ -- 906
			color = toColor(PALETTE.silkDim), -- 907
			opacity = 0.52, -- 907
			layer = 1 -- 907
		} -- 907
	) -- 907
	drawBlossomDot( -- 909
		uiInkDraw, -- 909
		uiArt, -- 909
		"ctrl_mid_dot", -- 909
		midX, -- 909
		areaY + areaH * 0.5, -- 909
		11, -- 909
		PALETTE.silkLine, -- 909
		0.62, -- 909
		3 -- 909
	) -- 909
	local leftColX = marginX + 34 -- 911
	local colW = midX - leftColX - 42 -- 912
	local headY = areaY + areaH - 34 -- 913
	local rowStep = 52 + extraH * 0.08 -- 914
	drawBlossomDot( -- 916
		uiInkDraw, -- 916
		uiArt, -- 916
		"ctrl_l_dot", -- 916
		leftColX + 8, -- 916
		headY, -- 916
		12, -- 916
		PALETTE.cyan, -- 916
		0.88, -- 916
		3 -- 916
	) -- 916
	texts:put( -- 917
		"md", -- 917
		"周戍 · 护送与交锋", -- 917
		leftColX + 26, -- 917
		headY, -- 917
		toColor(PALETTE.cyanCore), -- 917
		0, -- 917
		0.5, -- 917
		"Left", -- 917
		2.4, -- 917
		0.98, -- 917
		0.08 -- 917
	) -- 917
	drawHairline( -- 918
		uiInkDraw, -- 918
		uiArt, -- 918
		"ctrl_l_line", -- 918
		leftColX + colW * 0.5, -- 918
		headY - 24, -- 918
		colW, -- 918
		PALETTE.cyanDim, -- 918
		0.58, -- 918
		false, -- 918
		2 -- 918
	) -- 918
	local i = 0 -- 920
	do -- 920
		i = 0 -- 921
		while i < #guide.soldierRows do -- 921
			local ry = headY - 66 - i * rowStep -- 922
			drawSilkKeycap( -- 923
				uiInkDraw, -- 923
				texts, -- 923
				leftColX + 2, -- 923
				ry - 13, -- 923
				136, -- 923
				26, -- 923
				guide.soldierRows[i + 1][1], -- 923
				PALETTE.cyan, -- 923
				0.92, -- 923
				false -- 923
			) -- 923
			texts:put( -- 924
				"sm", -- 924
				guide.soldierRows[i + 1][2], -- 924
				leftColX + 152, -- 924
				ry, -- 924
				toColor(PALETTE.textBright), -- 924
				0, -- 924
				0.5, -- 924
				"Left", -- 924
				0.8, -- 924
				0.92, -- 924
				0.08 -- 924
			) -- 924
			i = i + 1 -- 921
		end -- 921
	end -- 921
	local rightColX = midX + 44 -- 927
	drawBlossomDot( -- 928
		uiInkDraw, -- 928
		uiArt, -- 928
		"ctrl_r_dot", -- 928
		rightColX + 8, -- 928
		headY, -- 928
		12, -- 928
		PALETTE.amber, -- 928
		0.88, -- 928
		3 -- 928
	) -- 928
	texts:put( -- 929
		"md", -- 929
		"小满 · 潜行与寻路", -- 929
		rightColX + 26, -- 929
		headY, -- 929
		toColor(PALETTE.amberCore), -- 929
		0, -- 929
		0.5, -- 929
		"Left", -- 929
		2.4, -- 929
		0.98, -- 929
		0.08 -- 929
	) -- 929
	drawHairline( -- 930
		uiInkDraw, -- 930
		uiArt, -- 930
		"ctrl_r_line", -- 930
		rightColX + colW * 0.5, -- 930
		headY - 24, -- 930
		colW, -- 930
		PALETTE.amberDim, -- 930
		0.58, -- 930
		false, -- 930
		2 -- 930
	) -- 930
	do -- 930
		i = 0 -- 932
		while i < #guide.childRows do -- 932
			local ry = headY - 66 - i * rowStep -- 933
			drawSilkKeycap( -- 934
				uiInkDraw, -- 934
				texts, -- 934
				rightColX + 2, -- 934
				ry - 13, -- 934
				136, -- 934
				26, -- 934
				guide.childRows[i + 1][1], -- 934
				PALETTE.amber, -- 934
				0.92, -- 934
				false -- 934
			) -- 934
			texts:put( -- 935
				"sm", -- 935
				guide.childRows[i + 1][2], -- 935
				rightColX + 152, -- 935
				ry, -- 935
				toColor(PALETTE.textBright), -- 935
				0, -- 935
				0.5, -- 935
				"Left", -- 935
				0.8, -- 935
				0.92, -- 935
				0.08 -- 935
			) -- 935
			i = i + 1 -- 932
		end -- 932
	end -- 932
	local ctrlBackKey = frame.mode == "gamepad" and (keyTagFor("back", "gamepad", frame.layout) .. " / ") .. keyTagFor("confirm", "gamepad", frame.layout) or (frame.mode == "touch" and "返回" or "ESC / ENTER") -- 938
	local ctrlRightHint = frame.mode == "gamepad" and "LB / RB 或左右切换键位图" or (frame.mode == "touch" and "轻触右上页签切图 · 暂歇菜单可调操控设置" or (canToggleFullscreen() and "←/→ 切页   ·   F11 / Alt+Enter 全屏" or "←/→ 切页   ·   暂歇菜单可调操控设置")) -- 941
	local keyW = frame.mode == "touch" and 76 or 110 -- 946
	drawSilkKeycap( -- 947
		uiInkDraw, -- 947
		texts, -- 947
		backX, -- 947
		backY + 5, -- 947
		keyW, -- 947
		24, -- 947
		ctrlBackKey, -- 947
		backHover and PALETTE.rouge or PALETTE.silkDim, -- 947
		0.92, -- 947
		backHover -- 947
	) -- 947
	texts:put( -- 948
		"sm", -- 948
		backLabel, -- 948
		backX + keyW + 12, -- 948
		backY + 17, -- 948
		toColor(backHover and PALETTE.textBright or PALETTE.textMid), -- 948
		0, -- 948
		0.5, -- 948
		"Left", -- 948
		1.8, -- 948
		0.92, -- 948
		0.08 -- 948
	) -- 948
	texts:put( -- 949
		"xs", -- 949
		ctrlRightHint, -- 949
		w - marginX, -- 949
		backY + 17, -- 949
		toColor(PALETTE.textDim), -- 949
		1, -- 949
		0.5, -- 949
		"Right", -- 949
		1.2, -- 949
		0.78, -- 949
		0.08 -- 949
	) -- 949
	return {type = "none"} -- 951
end -- 811
function MenuRenderer.prototype.drawPauseSettings(self, frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h) -- 955
	if frame.back then -- 955
		self:emitSound("back") -- 967
		return true -- 968
	end -- 968
	local caps = getPlatformCaps() -- 971
	local s = input.settings -- 972
	uiDraw:drawRect( -- 974
		Rect(0, 0, w, h), -- 974
		Color(10, 12, 19, 206) -- 974
	) -- 974
	local marginX = math.max( -- 976
		96, -- 976
		56 + math.max(frame.safe.left, frame.safe.right) -- 976
	) -- 976
	local topHeadY = h - 56 - frame.safe.top * 0.35 -- 977
	texts:put( -- 978
		"banner", -- 978
		"操控与声音", -- 978
		marginX, -- 978
		topHeadY, -- 978
		toColor(PALETTE.textBright), -- 978
		0, -- 978
		0.5, -- 978
		"Left", -- 978
		4, -- 978
		0.96, -- 978
		0.1 -- 978
	) -- 978
	local curSummary = ("当前模式：" .. inputModeLabelOf(input.inputMode)) .. " · 操控与四通道音量实时生效" -- 979
	texts:put( -- 980
		"xs", -- 980
		curSummary, -- 980
		marginX + 224, -- 980
		topHeadY - 4, -- 980
		toColor(PALETTE.amberCore), -- 980
		0, -- 980
		0.5, -- 980
		"Left", -- 980
		1.4, -- 980
		0.88, -- 980
		0.08 -- 980
	) -- 980
	drawHairline( -- 981
		uiInkDraw, -- 981
		uiArt, -- 981
		"set_top_line", -- 981
		w * 0.5, -- 981
		topHeadY - 30, -- 981
		w - marginX * 2, -- 981
		PALETTE.silkDim, -- 981
		0.6, -- 981
		true, -- 981
		2 -- 981
	) -- 981
	local panelW = math.min(760, w - marginX * 2) -- 983
	local panelX = (w - panelW) * 0.5 -- 984
	local rowH = 34 -- 985
	local rowStep = 39 -- 986
	local firstY = topHeadY - 76 -- 987
	local boxes = {} -- 989
	local i = 0 -- 990
	do -- 990
		i = 0 -- 991
		while i < #SETTINGS_ROWS do -- 991
			boxes[#boxes + 1] = Rect(panelX, firstY - i * rowStep, panelW, rowH) -- 992
			i = i + 1 -- 991
		end -- 991
	end -- 991
	local prevSetSel = self.settingsSelected -- 994
	self.settingsSelected = self:verticalSelection(self.settingsSelected, boxes, frame) -- 995
	if self.settingsSelected ~= prevSetSel then -- 995
		self:emitSound("hover") -- 997
	end -- 997
	local function applyDelta(rowId, delta) -- 1000
		if rowId == "back" then -- 1000
			self:emitSound("back") -- 1002
			return true -- 1003
		end -- 1003
		local audioChanged = false -- 1005
		if rowId == "modePref" then -- 1005
			input:cycleModePref(delta) -- 1007
		elseif rowId == "aimAssist" then -- 1007
			s.aimAssist = not s.aimAssist -- 1009
			saveControlSettings(s) -- 1010
		elseif rowId == "gpLayout" then -- 1010
			s.gamepadLayout = s.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 1012
			input.gamepadLayout = s.gamepadLayout -- 1013
			saveControlSettings(s) -- 1014
		elseif rowId == "crouchMode" then -- 1014
			s.crouchToggle = not s.crouchToggle -- 1016
			saveControlSettings(s) -- 1017
		elseif rowId == "touchOpacity" then -- 1017
			s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 1019
			saveControlSettings(s) -- 1020
		elseif rowId == "touchScale" then -- 1020
			s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta) -- 1022
			saveControlSettings(s) -- 1023
		elseif rowId == "haptics" then -- 1023
			s.haptics = not s.haptics -- 1025
			saveControlSettings(s) -- 1026
			if s.haptics then -- 1026
				local ____opt_3 = input:getTouch() -- 1026
				if ____opt_3 ~= nil then -- 1026
					____opt_3:vibrate(0.018) -- 1028
				end -- 1028
			end -- 1028
		elseif rowId == "masterVol" then -- 1028
			s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 1031
			saveControlSettings(s) -- 1032
			audioChanged = true -- 1033
		elseif rowId == "bgmVol" then -- 1033
			s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 1035
			saveControlSettings(s) -- 1036
			audioChanged = true -- 1037
		elseif rowId == "sfxVol" then -- 1037
			s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 1039
			saveControlSettings(s) -- 1040
			audioChanged = true -- 1041
		elseif rowId == "voiceVol" then -- 1041
			s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 1043
			saveControlSettings(s) -- 1044
			audioChanged = true -- 1045
		end -- 1045
		if audioChanged and self.onAudioSettingsChanged ~= nil then -- 1045
			self:onAudioSettingsChanged(input) -- 1048
		end -- 1048
		self:emitSound("toggle") -- 1050
		return false -- 1051
	end -- 1000
	local function valueTextOf(rowId) -- 1054
		if rowId == "modePref" then -- 1054
			return s.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(input.inputMode)) .. "）" or "锁定 · " .. modePrefLabelOf(s.modePref) -- 1056
		end -- 1056
		if rowId == "aimAssist" then -- 1056
			return s.aimAssist and "开（触屏与手柄共用）" or "关" -- 1060
		end -- 1060
		if rowId == "gpLayout" then -- 1060
			return layoutLabelOf(s.gamepadLayout) -- 1061
		end -- 1061
		if rowId == "crouchMode" then -- 1061
			return s.crouchToggle and "点按切换" or "持续按住" -- 1062
		end -- 1062
		if rowId == "touchOpacity" then -- 1062
			return opacityLabelOf(s.touchOpacity) -- 1063
		end -- 1063
		if rowId == "touchScale" then -- 1063
			return scaleLabelOf(s.touchScale) -- 1064
		end -- 1064
		if rowId == "haptics" then -- 1064
			return caps.supportsHaptics and (s.haptics and "开" or "关") or (s.haptics and "开（仅移动端生效）" or "关") -- 1065
		end -- 1065
		if rowId == "masterVol" then -- 1065
			return volumeLabelOf(s.masterVol) -- 1066
		end -- 1066
		if rowId == "bgmVol" then -- 1066
			return volumeLabelOf(s.bgmVol) -- 1067
		end -- 1067
		if rowId == "sfxVol" then -- 1067
			return volumeLabelOf(s.sfxVol) -- 1068
		end -- 1068
		if rowId == "voiceVol" then -- 1068
			return volumeLabelOf(s.voiceVol) -- 1069
		end -- 1069
		return "" -- 1070
	end -- 1054
	do -- 1054
		i = 0 -- 1073
		while i < #SETTINGS_ROWS do -- 1073
			local row = SETTINGS_ROWS[i + 1] -- 1074
			local box = boxes[i + 1] -- 1075
			local cy = box.y + box.height * 0.5 -- 1076
			local active = self.settingsSelected == i -- 1077
			if active then -- 1077
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1080
				drawSilkRibbon( -- 1081
					uiDraw, -- 1081
					uiArt, -- 1081
					"set_rib_" .. tostring(i), -- 1081
					panelX + panelW * 0.5, -- 1081
					cy, -- 1081
					panelW + 24, -- 1081
					rowH, -- 1081
					PALETTE.rougeSoft, -- 1081
					0.48 * breathe, -- 1081
					0 -- 1081
				) -- 1081
				drawHairline( -- 1082
					uiInkDraw, -- 1082
					uiArt, -- 1082
					"set_line_" .. tostring(i), -- 1082
					panelX + panelW * 0.5, -- 1082
					box.y + 3, -- 1082
					panelW - 24, -- 1082
					PALETTE.silkLine, -- 1082
					0.42 * breathe, -- 1082
					false, -- 1082
					2 -- 1082
				) -- 1082
				drawBlossomDot( -- 1083
					uiInkDraw, -- 1083
					uiArt, -- 1083
					"set_dot_" .. tostring(i), -- 1083
					panelX + 18, -- 1083
					cy, -- 1083
					14, -- 1083
					PALETTE.rouge, -- 1083
					0.96, -- 1083
					4 -- 1083
				) -- 1083
				fillRadialGlow( -- 1084
					uiGlow, -- 1084
					panelX + 18, -- 1084
					cy, -- 1084
					20, -- 1084
					14, -- 1084
					toColor(PALETTE.rouge, 24 * breathe), -- 1084
					Color(182, 58, 56, 0), -- 1084
					10 -- 1084
				) -- 1084
			else -- 1084
				drawBlossomDot( -- 1086
					uiInkDraw, -- 1086
					uiArt, -- 1086
					"set_dot_" .. tostring(i), -- 1086
					panelX + 18, -- 1086
					cy, -- 1086
					7, -- 1086
					PALETTE.silkDim, -- 1086
					0.42, -- 1086
					3 -- 1086
				) -- 1086
			end -- 1086
			texts:put( -- 1089
				"sm", -- 1090
				row.title, -- 1091
				panelX + 42, -- 1092
				cy, -- 1093
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1094
				0, -- 1095
				0.5, -- 1096
				"Left", -- 1097
				active and 2.4 or 1.6, -- 1098
				active and 1 or 0.88, -- 1099
				0.08 -- 1100
			) -- 1100
			local val = valueTextOf(row.id) -- 1103
			if val ~= "" then -- 1103
				local valCol = active and PALETTE.amberCore or PALETTE.cyanCore -- 1105
				local decorated = active and ("‹  " .. val) .. "  ›" or val -- 1106
				texts:put( -- 1107
					"sm", -- 1107
					decorated, -- 1107
					panelX + panelW - 24, -- 1107
					cy, -- 1107
					toColor(valCol), -- 1107
					1, -- 1107
					0.5, -- 1107
					"Right", -- 1107
					1, -- 1107
					active and 1 or 0.86, -- 1107
					0.08 -- 1107
				) -- 1107
			end -- 1107
			i = i + 1 -- 1073
		end -- 1073
	end -- 1073
	local backY = 40 + frame.safe.bottom * 0.45 -- 1111
	local hint = frame.mode == "gamepad" and ((("左右或 " .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 切换   ·   ") .. keyTagFor("back", "gamepad", frame.layout)) .. " 返回暂停" or (frame.mode == "touch" and "轻触任意条目切换   ·   设置自动保存" or "←/→ 或回车/点击切换   ·   Esc 返回暂停") -- 1112
	texts:put( -- 1117
		"xs", -- 1117
		hint, -- 1117
		w * 0.5, -- 1117
		backY + 14, -- 1117
		toColor(PALETTE.textDim), -- 1117
		0.5, -- 1117
		0.5, -- 1117
		"Center", -- 1117
		1.2, -- 1117
		0.84, -- 1117
		0.08 -- 1117
	) -- 1117
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1119
	if hit >= 0 then -- 1119
		self.settingsSelected = hit -- 1121
		if applyDelta(SETTINGS_ROWS[hit + 1].id, 1) then -- 1121
			return true -- 1123
		end -- 1123
		self:resetInput() -- 1125
		return false -- 1126
	end -- 1126
	if frame.keys.left or frame.prevTab then -- 1126
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1129
		if id ~= "back" then -- 1129
			applyDelta(id, -1) -- 1131
			self:resetInput() -- 1132
		end -- 1132
		return false -- 1134
	end -- 1134
	if frame.keys.right or frame.nextTab or frame.keys.confirm then -- 1134
		local id = SETTINGS_ROWS[self.settingsSelected + 1].id -- 1137
		if applyDelta(id, 1) then -- 1137
			return true -- 1139
		end -- 1139
		self:resetInput() -- 1141
		return false -- 1142
	end -- 1142
	return false -- 1144
end -- 955
function MenuRenderer.prototype.updateAndDrawPause(self, dt, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, uiScale, assistHintsEnabled, onToggleAssist, safeUi) -- 1152
	if assistHintsEnabled == nil then -- 1152
		assistHintsEnabled = false -- 1163
	end -- 1163
	if safeUi == nil then -- 1163
		safeUi = ZERO_SAFE_INSETS -- 1165
	end -- 1165
	self.time = self.time + dt -- 1167
	local frame = self:readFrame(input, uiScale, safeUi) -- 1168
	if self.pauseShowControls then -- 1168
		local ctrlAct = self:drawControls( -- 1171
			frame, -- 1171
			uiDraw, -- 1171
			uiInkDraw, -- 1171
			uiArt, -- 1171
			uiGlow, -- 1171
			texts, -- 1171
			w, -- 1171
			h, -- 1171
			"返回暂停" -- 1171
		) -- 1171
		if ctrlAct.type == "backTitle" then -- 1171
			self.pauseShowControls = false -- 1173
			self:resetInput() -- 1174
		end -- 1174
		return {type = "none"} -- 1176
	end -- 1176
	if self.pauseShowSettings then -- 1176
		if self:drawPauseSettings( -- 1176
			frame, -- 1180
			input, -- 1180
			uiDraw, -- 1180
			uiInkDraw, -- 1180
			uiArt, -- 1180
			uiGlow, -- 1180
			texts, -- 1180
			w, -- 1180
			h -- 1180
		) then -- 1180
			self.pauseShowSettings = false -- 1181
			self:resetInput() -- 1182
		end -- 1182
		return {type = "none"} -- 1184
	end -- 1184
	if frame.back then -- 1184
		self.pauseShowControls = false -- 1188
		self.pauseShowSettings = false -- 1189
		self:emitSound("pauseClose") -- 1190
		return {type = "resume"} -- 1191
	end -- 1191
	local allowFs = canToggleFullscreen() -- 1194
	local allowQuit = canQuitApp() -- 1195
	local pauseItems = __TS__ArrayFilter( -- 1196
		PAUSE_ITEMS, -- 1196
		function(____, item) return (item.id ~= "fullscreen" or allowFs) and (item.id ~= "quit" or allowQuit) end -- 1196
	) -- 1196
	if self.pauseSelected >= #pauseItems then -- 1196
		self.pauseSelected = 0 -- 1200
	end -- 1200
	uiDraw:drawRect( -- 1203
		Rect(0, 0, w, h), -- 1203
		Color(8, 10, 16, 102) -- 1203
	) -- 1203
	fillHGradRect( -- 1204
		uiDraw, -- 1204
		0, -- 1204
		0, -- 1204
		w * 0.27 + frame.safe.left, -- 1204
		h, -- 1204
		Color(9, 11, 18, 232), -- 1204
		Color(10, 13, 21, 198) -- 1204
	) -- 1204
	fillHGradRect( -- 1205
		uiDraw, -- 1205
		w * 0.27 + frame.safe.left, -- 1205
		0, -- 1205
		w * 0.21, -- 1205
		h, -- 1205
		Color(10, 13, 21, 198), -- 1205
		Color(10, 13, 21, 0) -- 1205
	) -- 1205
	local menuX = 110 + frame.safe.left * 0.6 -- 1207
	local compact = #pauseItems > 8 -- 1208
	local headY = (compact and h - 122 or h - 146) - frame.safe.top * 0.35 -- 1209
	uiArt:tryPlace( -- 1210
		"ink_vstream", -- 1210
		"pause_vstream", -- 1210
		menuX - 32, -- 1210
		h * 0.5, -- 1210
		34, -- 1210
		h * 0.78, -- 1210
		{ -- 1210
			color = toColor(PALETTE.silkDim), -- 1211
			opacity = 0.48, -- 1211
			layer = 1 -- 1211
		} -- 1211
	) -- 1211
	drawMistCurve( -- 1213
		uiArt, -- 1213
		"pause_mist", -- 1213
		menuX + 118, -- 1213
		headY - 8, -- 1213
		290, -- 1213
		72, -- 1213
		PALETTE.jadeMist, -- 1213
		0.2, -- 1213
		-1 -- 1213
	) -- 1213
	texts:put( -- 1215
		"banner", -- 1215
		"暂歇", -- 1215
		menuX + 16, -- 1215
		headY, -- 1215
		toColor(PALETTE.textBright), -- 1215
		0, -- 1215
		0.5, -- 1215
		"Left", -- 1215
		10, -- 1215
		0.98, -- 1215
		0.1 -- 1215
	) -- 1215
	texts:put( -- 1216
		"xs", -- 1216
		"月夜暂驻 · 卷页留痕", -- 1216
		menuX + 18, -- 1216
		headY - 36, -- 1216
		toColor(PALETTE.textDim), -- 1216
		0, -- 1216
		0.5, -- 1216
		"Left", -- 1216
		2, -- 1216
		0.8, -- 1216
		0.08 -- 1216
	) -- 1216
	drawHairline( -- 1217
		uiInkDraw, -- 1217
		uiArt, -- 1217
		"pause_div", -- 1217
		menuX + 124, -- 1217
		headY - 60, -- 1217
		240, -- 1217
		PALETTE.silkDim, -- 1217
		0.58, -- 1217
		true, -- 1217
		2 -- 1217
	) -- 1217
	local rowStep = compact and 42 or 46 -- 1219
	local rowH = compact and 36 or 38 -- 1220
	local firstY = compact and headY - 112 or headY - 120 -- 1221
	local boxes = {} -- 1222
	local i = 0 -- 1223
	do -- 1223
		i = 0 -- 1224
		while i < #pauseItems do -- 1224
			boxes[#boxes + 1] = Rect(menuX - 10, firstY - i * rowStep, 286, rowH) -- 1225
			i = i + 1 -- 1224
		end -- 1224
	end -- 1224
	local prevPauseSel = self.pauseSelected -- 1227
	self.pauseSelected = self:verticalSelection(self.pauseSelected, boxes, frame) -- 1228
	if self.pauseSelected ~= prevPauseSel then -- 1228
		self:emitSound("hover") -- 1230
	end -- 1230
	do -- 1230
		i = 0 -- 1233
		while i < #pauseItems do -- 1233
			local iy = boxes[i + 1].y -- 1234
			local active = self.pauseSelected == i -- 1235
			local cy = iy + rowH * 0.5 -- 1236
			local shiftX = active and 10 or 0 -- 1237
			local item = pauseItems[i + 1] -- 1238
			local label = item.zh -- 1239
			if item.id == "assist" then -- 1239
				label = assistHintsEnabled and "按键辅助：开" or "按键辅助：关" -- 1241
			elseif item.id == "fullscreen" then -- 1241
				label = App.fullScreen and "显示：全屏" or "显示：窗口" -- 1243
			elseif item.id == "settings" then -- 1243
				label = "操控设置 · " .. modePrefLabelOf(input.settings.modePref) -- 1245
			end -- 1245
			if active then -- 1245
				local breathe = 0.84 + 0.16 * math.sin(self.time * 2.4) -- 1249
				drawSilkRibbon( -- 1250
					uiDraw, -- 1250
					uiArt, -- 1250
					"pause_rib_" .. tostring(i), -- 1250
					menuX + 116, -- 1250
					cy, -- 1250
					282, -- 1250
					rowH, -- 1250
					PALETTE.rougeSoft, -- 1250
					0.54 * breathe, -- 1250
					0 -- 1250
				) -- 1250
				drawHairline( -- 1251
					uiInkDraw, -- 1251
					uiArt, -- 1251
					"pause_line_" .. tostring(i), -- 1251
					menuX + 106, -- 1251
					iy + 3, -- 1251
					210, -- 1251
					PALETTE.silkLine, -- 1251
					0.42 * breathe, -- 1251
					false, -- 1251
					2 -- 1251
				) -- 1251
				drawBlossomDot( -- 1252
					uiInkDraw, -- 1252
					uiArt, -- 1252
					"pause_dot_" .. tostring(i), -- 1252
					menuX + 12, -- 1252
					cy, -- 1252
					15, -- 1252
					PALETTE.rouge, -- 1252
					0.96, -- 1252
					4 -- 1252
				) -- 1252
				fillRadialGlow( -- 1253
					uiGlow, -- 1253
					menuX + 12, -- 1253
					cy, -- 1253
					22, -- 1253
					16, -- 1253
					toColor(PALETTE.rouge, 26 * breathe), -- 1253
					Color(182, 58, 56, 0), -- 1253
					10 -- 1253
				) -- 1253
			else -- 1253
				drawBlossomDot( -- 1255
					uiInkDraw, -- 1255
					uiArt, -- 1255
					"pause_dot_" .. tostring(i), -- 1255
					menuX + 12, -- 1255
					cy, -- 1255
					8, -- 1255
					PALETTE.silkDim, -- 1255
					0.4, -- 1255
					3 -- 1255
				) -- 1255
			end -- 1255
			texts:put( -- 1258
				compact and "sm" or "md", -- 1259
				label, -- 1260
				menuX + 32 + shiftX, -- 1261
				cy, -- 1262
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 1263
				0, -- 1264
				0.5, -- 1265
				"Left", -- 1266
				active and 3.4 or 2.2, -- 1267
				active and 1 or 0.88, -- 1268
				0.1 -- 1269
			) -- 1269
			i = i + 1 -- 1233
		end -- 1233
	end -- 1233
	local pauseFooter = frame.mode == "gamepad" and ((keyTagFor("back", "gamepad", frame.layout) .. " / START 续行   ·   ") .. keyTagFor("confirm", "gamepad", frame.layout)) .. " 确认" or (frame.mode == "touch" and "轻触确认   ·   点「继续游戏」续行" or "Esc 续行   ·   Enter 或点击确认") -- 1273
	texts:put( -- 1278
		"xs", -- 1278
		pauseFooter, -- 1278
		menuX + 12, -- 1278
		38 + frame.safe.bottom * 0.4, -- 1278
		toColor(PALETTE.textDim), -- 1278
		0, -- 1278
		0.5, -- 1278
		"Left", -- 1278
		1.2, -- 1278
		0.86, -- 1278
		0.08 -- 1278
	) -- 1278
	local hit = frame.click and hitIndex(boxes, frame.pointer, frame.inside) or -1 -- 1280
	if hit >= 0 or frame.keys.confirm then -- 1280
		local idx = hit >= 0 and hit or self.pauseSelected -- 1282
		local id = pauseItems[idx + 1].id -- 1283
		if id == "controls" then -- 1283
			self.pauseShowControls = true -- 1285
			self:emitSound("confirm") -- 1286
			self:resetInput() -- 1287
			return {type = "none"} -- 1288
		end -- 1288
		if id == "settings" then -- 1288
			self:openPauseSettings() -- 1291
			self:emitSound("confirm") -- 1292
			return {type = "none"} -- 1293
		end -- 1293
		if id == "assist" then -- 1293
			if onToggleAssist ~= nil then -- 1293
				onToggleAssist() -- 1297
			end -- 1297
			self:emitSound("toggle") -- 1299
			self:resetInput() -- 1300
			return {type = "none"} -- 1301
		end -- 1301
		if id == "fullscreen" then -- 1301
			self:emitSound("toggle") -- 1304
			self:resetInput() -- 1305
			return {type = "toggleFullscreen"} -- 1306
		end -- 1306
		self.pauseShowControls = false -- 1308
		self.pauseShowSettings = false -- 1309
		if id == "resume" then -- 1309
			self:emitSound("pauseClose") -- 1310
			return {type = "resume"} -- 1310
		end -- 1310
		if id == "retry" then -- 1310
			self:emitSound("confirm") -- 1311
			return {type = "retry"} -- 1311
		end -- 1311
		if id == "chapters" then -- 1311
			self:emitSound("confirm") -- 1312
			return {type = "openChapters"} -- 1312
		end -- 1312
		if id == "quit" then -- 1312
			self:emitSound("back") -- 1313
			return {type = "quit"} -- 1313
		end -- 1313
		self:emitSound("back") -- 1314
		return {type = "toTitle"} -- 1315
	end -- 1315
	return {type = "none"} -- 1317
end -- 1152
return ____exports -- 1152