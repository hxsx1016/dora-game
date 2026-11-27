-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
local ____touch_core = require("Script.watch.input.touch_core") -- 12
local TouchRouter = ____touch_core.TouchRouter -- 12
local ____touch_hud_landscape = require("Script.watch.input.touch_hud_landscape") -- 13
local TouchControls = ____touch_hud_landscape.TouchControls -- 13
local ____touch_hud_portrait = require("Script.watch.input.touch_hud_portrait") -- 14
local PORTRAIT_TOUCH_DELEGATE = ____touch_hud_portrait.PORTRAIT_TOUCH_DELEGATE -- 14
local ____platform_mobile = require("Script.watch.platform_mobile") -- 15
local computeAdaptiveViewport = ____platform_mobile.computeAdaptiveViewport -- 15
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 15
local ____controls_config = require("Script.watch.controls_config") -- 16
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 17
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 18
local applyVolumeSetting = ____controls_config.applyVolumeSetting -- 19
local nextStepValue = ____controls_config.nextStepValue -- 20
local opacityLabelOf = ____controls_config.opacityLabelOf -- 21
local saveControlSettings = ____controls_config.saveControlSettings -- 22
local scaleLabelOf = ____controls_config.scaleLabelOf -- 23
local volumeSettingText = ____controls_config.volumeSettingText -- 24
local ____target_types = require("Script.watch.target_types") -- 27
local getReleaseConfig = ____target_types.getReleaseConfig -- 40
local ANDROID_SETTINGS_ROWS = { -- 43
	{id = "aimAssist", title = "瞄准磁吸"}, -- 44
	{id = "touchOpacity", title = "触控按键透度"}, -- 45
	{id = "touchScale", title = "触控按键大小"}, -- 46
	{id = "haptics", title = "触觉震动反馈"}, -- 47
	{id = "masterVol", title = "主音量"}, -- 48
	{id = "bgmVol", title = "音乐音量"}, -- 49
	{id = "sfxVol", title = "音效与环境"}, -- 50
	{id = "voiceVol", title = "人声音量"}, -- 51
	{id = "back", title = "返回暂歇菜单"} -- 52
} -- 52
local ANDROID_GUIDE = {subtitle = "触屏操作说明 · 横屏全屏 / 竖屏掌机台", soldierRows = { -- 55
	{"左水墨摇杆", "全向走位与里外道切线"}, -- 58
	{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 59
	{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 60
	{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 61
	{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 62
	{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 63
}, childRows = { -- 63
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 66
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 67
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 68
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 69
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 70
	{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 71
}} -- 71
local function isStandaloneApk() -- 75
	local cfg = getReleaseConfig() -- 76
	return cfg ~= nil and cfg.platform == "Android" -- 77
end -- 75
local function keyTagTouch(action) -- 80
	if action == "interact" then -- 80
		return "点按" -- 81
	end -- 81
	if action == "jump" then -- 81
		return "跳/滚" -- 82
	end -- 82
	if action == "crouch" then -- 82
		return "蹲伏" -- 83
	end -- 83
	if action == "cover" then -- 83
		return "掩体" -- 84
	end -- 84
	if action == "fire" then -- 84
		return "开火" -- 85
	end -- 85
	if action == "aim" then -- 85
		return "拖投瓶" -- 86
	end -- 86
	if action == "pause" then -- 86
		return "暂歇" -- 87
	end -- 87
	if action == "retry" then -- 87
		return "重试" -- 88
	end -- 88
	if action == "confirm" then -- 88
		return "点选" -- 89
	end -- 89
	if action == "back" then -- 89
		return "返回" -- 90
	end -- 90
	return "穿梭" -- 91
end -- 80
local function adaptWorldKeyTagTouch(rawKeyTag) -- 94
	if rawKeyTag == "E" then -- 94
		return "轻触" -- 95
	end -- 95
	if rawKeyTag == "按住 E" then -- 95
		return "长按交互" -- 96
	end -- 96
	if rawKeyTag == "松开再按住 E" then -- 96
		return "松开再长按" -- 97
	end -- 97
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 97
		return "点推车+摇杆" -- 98
	end -- 98
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 98
		return "开火" -- 99
	end -- 99
	if rawKeyTag == "按住 F" then -- 99
		return "拖投瓶" -- 100
	end -- 100
	if rawKeyTag == "松开 F" then -- 100
		return "松手投" -- 101
	end -- 101
	if rawKeyTag == "按住 Ctrl" then -- 101
		return "点蹲伏" -- 102
	end -- 102
	if rawKeyTag == "按住 Shift" then -- 102
		return "点掩体" -- 103
	end -- 103
	if rawKeyTag == "连线" then -- 103
		return "一笔划连" -- 104
	end -- 104
	return rawKeyTag -- 105
end -- 94
local function adaptHintSentenceTouch(text) -- 108
	if text == "" then -- 108
		return text -- 109
	end -- 109
	return table.concat( -- 110
		__TS__StringSplit( -- 110
			table.concat( -- 110
				__TS__StringSplit( -- 110
					table.concat( -- 110
						__TS__StringSplit( -- 110
							table.concat( -- 110
								__TS__StringSplit( -- 110
									table.concat( -- 110
										__TS__StringSplit( -- 110
											table.concat( -- 110
												__TS__StringSplit( -- 110
													table.concat( -- 110
														__TS__StringSplit( -- 110
															table.concat( -- 110
																__TS__StringSplit( -- 110
																	table.concat( -- 110
																		__TS__StringSplit( -- 110
																			table.concat( -- 110
																				__TS__StringSplit( -- 110
																					table.concat( -- 110
																						__TS__StringSplit( -- 110
																							table.concat( -- 110
																								__TS__StringSplit( -- 110
																									table.concat( -- 110
																										__TS__StringSplit( -- 110
																											table.concat( -- 110
																												__TS__StringSplit( -- 110
																													table.concat( -- 110
																														__TS__StringSplit( -- 110
																															table.concat( -- 110
																																__TS__StringSplit( -- 110
																																	table.concat( -- 110
																																		__TS__StringSplit( -- 110
																																			table.concat( -- 110
																																				__TS__StringSplit( -- 110
																																					table.concat( -- 110
																																						__TS__StringSplit( -- 110
																																							table.concat( -- 110
																																								__TS__StringSplit( -- 110
																																									table.concat( -- 110
																																										__TS__StringSplit( -- 110
																																											table.concat( -- 110
																																												__TS__StringSplit( -- 110
																																													table.concat( -- 110
																																														__TS__StringSplit( -- 110
																																															table.concat( -- 110
																																																__TS__StringSplit( -- 110
																																																	table.concat( -- 110
																																																		__TS__StringSplit( -- 110
																																																			table.concat( -- 110
																																																				__TS__StringSplit( -- 110
																																																					table.concat( -- 110
																																																						__TS__StringSplit( -- 110
																																																							table.concat( -- 110
																																																								__TS__StringSplit( -- 110
																																																									table.concat( -- 110
																																																										__TS__StringSplit( -- 110
																																																											table.concat( -- 110
																																																												__TS__StringSplit( -- 110
																																																													table.concat( -- 110
																																																														__TS__StringSplit(text, "按住 [E]+[D]"), -- 110
																																																														"点按推/拉车并推摇杆" -- 111
																																																													), -- 111
																																																													"[E]+[D]" -- 112
																																																												), -- 112
																																																												"推/拉车并推摇杆" -- 112
																																																											), -- 112
																																																											"速按 [CTRL]" -- 113
																																																										), -- 113
																																																										"点按「蹲伏」" -- 113
																																																									), -- 113
																																																									"按住 [CTRL]" -- 114
																																																								), -- 114
																																																								"点按「蹲伏」" -- 114
																																																							), -- 114
																																																							"按 [CTRL]" -- 115
																																																						), -- 115
																																																						"点按「蹲伏」" -- 115
																																																					), -- 115
																																																					"[CTRL]" -- 116
																																																				), -- 116
																																																				"「蹲伏」" -- 116
																																																			), -- 116
																																																			"按住 [SHIFT]" -- 117
																																																		), -- 117
																																																		"点按「轻步/掩体」" -- 117
																																																	), -- 117
																																																	"[SHIFT]" -- 118
																																																), -- 118
																																																"「轻步/掩体」" -- 118
																																															), -- 118
																																															"按住 [F]" -- 119
																																														), -- 119
																																														"按住「投瓶」拖拽" -- 119
																																													), -- 119
																																													"[F]" -- 120
																																												), -- 120
																																												"「投瓶」" -- 120
																																											), -- 120
																																											"按住 E" -- 121
																																										), -- 121
																																										"长按「交互」" -- 121
																																									), -- 121
																																									"按 [E]" -- 122
																																								), -- 122
																																								"点按「交互」" -- 122
																																							), -- 122
																																							"[E]" -- 123
																																						), -- 123
																																						"「交互」" -- 123
																																					), -- 123
																																					"方向键" -- 124
																																				), -- 124
																																				"左下摇杆" -- 124
																																			), -- 124
																																			"按 [ESC]" -- 125
																																		), -- 125
																																		"轻触右上「暂歇」" -- 125
																																	), -- 125
																																	"[ESC]" -- 126
																																), -- 126
																																"右上「暂歇」" -- 126
																															), -- 126
																															"按 [SPACE]" -- 127
																														), -- 127
																														"点按「翻滚/跳跃」" -- 127
																													), -- 127
																													"[SPACE]" -- 128
																												), -- 128
																												"「翻滚/跳跃」" -- 128
																											), -- 128
																											"按 [R]" -- 129
																										), -- 129
																										"在暂歇菜单重试" -- 129
																									), -- 129
																									"[A/D]" -- 130
																								), -- 130
																								"左下摇杆" -- 130
																							), -- 130
																							"[W/S]" -- 131
																						), -- 131
																						"摇杆上下" -- 131
																					), -- 131
																					"[W]" -- 132
																				), -- 132
																				"摇杆向上" -- 132
																			), -- 132
																			"[S]" -- 133
																		), -- 133
																		"摇杆向下" -- 133
																	), -- 133
																	"鼠标瞄准，左键发射火铳" -- 134
																), -- 134
																"点屏或拖「开火」发射火铳" -- 134
															), -- 134
															"左键先手击倒" -- 135
														), -- 135
														"点屏或「开火」先手击倒" -- 135
													), -- 135
													"左键发射火铳" -- 136
												), -- 136
												"点屏或「开火」发射火铳" -- 136
											), -- 136
											"左键发铳" -- 137
										), -- 137
										"点屏或「开火」发铳" -- 137
									), -- 137
									"左键" -- 138
								), -- 138
								"点屏或「开火」" -- 138
							), -- 138
							"鼠标" -- 139
						), -- 139
						"触屏" -- 139
					), -- 139
					"按 E 再次启程" -- 140
				), -- 140
				"轻触屏幕再次启程" -- 140
			), -- 140
			"Esc 暂歇" -- 141
		), -- 141
		"轻触右上暂歇" -- 141
	) -- 141
end -- 108
local AndroidTouchDriver = __TS__Class() -- 144
AndroidTouchDriver.name = "AndroidTouchDriver" -- 144
function AndroidTouchDriver.prototype.____constructor(self, settings) -- 149
	self.defaultMode = "touch" -- 145
	self.router = __TS__New(TouchRouter, settings, {enableMouseCompat = false, enablePortrait = true}) -- 150
end -- 149
function AndroidTouchDriver.prototype.attach(self, parent, _hooks) -- 156
	self.router:attach(parent) -- 157
	if self.controls == nil then -- 157
		self.controls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 159
	end -- 159
end -- 156
function AndroidTouchDriver.prototype.syncFrame(self, ctx) -- 163
	if self.controls == nil then -- 163
		return -- 164
	end -- 164
	self.controls:syncContext({ -- 165
		viewport = ctx.viewport, -- 166
		mode = ctx.mode, -- 167
		screen = ctx.screen, -- 168
		play = ctx.play, -- 169
		run = ctx.run, -- 170
		cam = ctx.cam, -- 171
		router = self.router, -- 172
		overlayActive = true, -- 173
		allowAutoGameplayTouch = true, -- 174
		allowMouseOnOverlay = false, -- 175
		showWebTopPills = false, -- 176
		canToggleFullscreen = false, -- 177
		assistHintsEnabled = ctx.assistHintsEnabled, -- 178
		isMuted = ctx.isMuted, -- 179
		isFullscreen = false, -- 180
		storyTalentBoxes = ctx.storyTalentBoxes, -- 181
		escortDeathBoxes = ctx.escortDeathBoxes, -- 182
		ledgerOpen = ctx.ledgerOpen, -- 183
		ledgerBox = ctx.ledgerBox, -- 184
		dt = ctx.dt -- 185
	}) -- 185
end -- 163
function AndroidTouchDriver.prototype.renderOverlay(self) -- 189
	local ____opt_0 = self.controls -- 189
	if ____opt_0 ~= nil then -- 189
		____opt_0:render(self.router) -- 190
	end -- 190
end -- 189
function AndroidTouchDriver.prototype.clearTransient(self, keepTouchToggles) -- 193
	self.router:releaseAll(keepTouchToggles) -- 194
end -- 193
function AndroidTouchDriver.prototype.vibrate(self, seconds) -- 197
	self.router:vibrate(seconds) -- 198
end -- 197
function AndroidTouchDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 201
	return true -- 202
end -- 201
function AndroidTouchDriver.prototype.getTouchRouter(self) -- 205
	return self.router -- 206
end -- 205
function AndroidTouchDriver.prototype.getTouchControls(self) -- 209
	return self.controls -- 210
end -- 209
function AndroidTouchDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 213
	self.router:injectTouch( -- 214
		phase, -- 214
		id, -- 214
		x, -- 214
		y, -- 214
		fromMouse == true -- 214
	) -- 214
end -- 213
function AndroidTouchDriver.prototype.pollInto(self, input) -- 217
	input.inputMode = "touch" -- 218
	local touch = self.router:consumeSnapshot() -- 219
	if touch.hadRealTouch then -- 219
		input.userInteracted = true -- 221
	end -- 221
	input.moveX = touch.moveX -- 224
	input.moveY = touch.moveY -- 225
	input:applyKeyHeld( -- 226
		touch.jumpHeld, -- 227
		touch.crouchHeld, -- 228
		touch.coverHeld, -- 229
		touch.interactHeld, -- 230
		touch.aimHeld, -- 231
		touch.fireHeld, -- 232
		false, -- 233
		false, -- 234
		false, -- 235
		false, -- 236
		false -- 237
	) -- 237
	input:resetFrameSignals() -- 240
	if touch.jumpPressed then -- 240
		input.jump.pressed = true -- 241
	end -- 241
	if touch.interactPressed then -- 241
		input.interact.pressed = true -- 242
	end -- 242
	if touch.firePressed then -- 242
		input.fire.pressed = true -- 243
	end -- 243
	if touch.pausePressed then -- 243
		input.pause.pressed = true -- 244
	end -- 244
	if touch.retryPressed then -- 244
		input.retry.pressed = true -- 245
	end -- 245
	if touch.artifactPressed then -- 245
		input.artifactTogglePressed = true -- 246
	end -- 246
	if touch.mutePressed then -- 246
		input.muteTogglePressed = true -- 247
	end -- 247
	if touch.anyTapBegan then -- 247
		input.splashSkipPressed = true -- 248
	end -- 248
	if touch.zoneTap ~= "" then -- 248
		input.touchZoneTap = touch.zoneTap -- 249
	end -- 249
	input.navUp = touch.navUp -- 250
	input.navDown = touch.navDown -- 251
	input.navLeft = touch.navLeft -- 252
	input.navRight = touch.navRight -- 253
	input.navConfirm = touch.navConfirm -- 254
	input.navBack = touch.navBack -- 255
	input.craftConfirm = touch.navConfirm -- 256
	input.craftCancel = touch.navBack -- 257
	if touch.bottleCanceled then -- 257
		input.bottleCanceled = true -- 259
		input.aim.held = false -- 260
		input.aim.pressed = false -- 261
		input.aim.released = false -- 262
	end -- 262
	input.frameInteractPressed = input.interact.pressed -- 265
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 265
		input.uiX = touch.uiX -- 268
		input.uiY = touch.uiY -- 269
		input.uiDx = touch.uiDx -- 270
		input.uiDy = touch.uiDy -- 271
		input.uiInside = touch.uiInside -- 272
		input.uiHeld = touch.uiHeld -- 273
		input.uiPressed = touch.uiPressed -- 274
		input.uiReleased = touch.uiReleased -- 275
		input.uiRightPressed = false -- 276
		if touch.uiHeld or touch.uiPressed then -- 276
			input.mdx = touch.uiDx -- 278
			input.mdy = touch.uiDy -- 279
			input.mx = touch.uiX -- 280
			input.my = touch.uiY -- 281
			input.inside = true -- 282
		elseif touch.hasAim then -- 282
			input.mdx = touch.aimX - input.mx -- 284
			input.mdy = touch.aimY - input.my -- 285
			input.mx = touch.aimX -- 286
			input.my = touch.aimY -- 287
			input.inside = true -- 288
		else -- 288
			input.mdx = 0 -- 290
			input.mdy = 0 -- 291
			input.inside = touch.uiInside -- 292
		end -- 292
		return -- 294
	end -- 294
	if touch.hasAim then -- 294
		input.mdx = touch.aimX - input.mx -- 298
		input.mdy = touch.aimY - input.my -- 299
		input.mx = touch.aimX -- 300
		input.my = touch.aimY -- 301
		input.inside = true -- 302
	else -- 302
		input.mdx = 0 -- 304
		input.mdy = 0 -- 305
		input.inside = false -- 306
	end -- 306
	input.uiDx = 0 -- 308
	input.uiDy = 0 -- 309
	input.uiInside = false -- 310
	input.uiHeld = false -- 311
	input.uiPressed = false -- 312
	input.uiReleased = false -- 313
	input.uiRightPressed = false -- 314
end -- 217
____exports.TARGET = { -- 318
	id = "android", -- 319
	supportsKbm = false, -- 320
	supportsTouch = true, -- 321
	supportsGamepad = false, -- 322
	supportsPortrait = true, -- 323
	defaultInputMode = "touch", -- 324
	supportedModes = {"touch"}, -- 325
	modePrefOrder = {"touch"}, -- 326
	controlsGuideTabs = {{mode = "touch", label = "触屏"}}, -- 327
	getPlatformCaps = function(self) -- 329
		local standaloneApk = isStandaloneApk() -- 330
		local cfg = getReleaseConfig() -- 331
		return { -- 332
			kind = "android", -- 333
			target = "android", -- 334
			isDesktop = false, -- 335
			isMobile = true, -- 336
			isWeb = false, -- 337
			isStandaloneAndroidApk = standaloneApk, -- 338
			canToggleFullscreen = false, -- 339
			canQuit = standaloneApk, -- 340
			hasBackButton = true, -- 341
			supportsHaptics = type(App.vibrate) == "function", -- 342
			needsAudioUnlock = false, -- 343
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 344
			defaultInputMode = "touch" -- 345
		} -- 345
	end, -- 329
	canToggleFullscreen = function(self) -- 349
		return false -- 350
	end, -- 349
	canQuitApp = function(self) -- 353
		return isStandaloneApk() -- 354
	end, -- 353
	isReleaseMode = function(self) -- 357
		local cfg = getReleaseConfig() -- 358
		return cfg ~= nil and cfg.isRelease == true -- 359
	end, -- 357
	computeStageViewport = function(self, fullW, fullH) -- 362
		return computeAdaptiveViewport(fullW, fullH) -- 363
	end, -- 362
	triggerHaptics = function(self, seconds, enabled) -- 366
		triggerMobileHaptics(seconds, enabled) -- 367
	end, -- 366
	keyTagFor = function(self, action, _mode, _layout) -- 370
		return keyTagTouch(action) -- 371
	end, -- 370
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 374
		return adaptWorldKeyTagTouch(rawKeyTag) -- 375
	end, -- 374
	adaptHintSentence = function(self, text, _mode, _layout) -- 378
		return adaptHintSentenceTouch(text) -- 379
	end, -- 378
	controlsGuideRows = function(self, _tab) -- 382
		return ANDROID_GUIDE -- 383
	end, -- 382
	splashSkipHint = function(self, _mode, _layout) -- 386
		return "轻触跳过" -- 387
	end, -- 386
	titleFooterHint = function(self, _mode, _layout) -- 390
		return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程" -- 391
	end, -- 390
	chapterFooterHint = function(self, _mode, _confirmTag) -- 396
		return "轻触驿站预览   ·   再点或轻触入此卷章" -- 397
	end, -- 396
	pauseFooterHint = function(self, _mode, _layout) -- 400
		return "轻触确认   ·   点「继续游戏」续行" -- 401
	end, -- 400
	settingsFooterHint = function(self, _mode, _layout) -- 404
		return "轻触任意条目切换   ·   设置自动保存" -- 405
	end, -- 404
	controlsFooterRightHint = function(self, _mode) -- 408
		return "暂歇菜单可调触控与声音" -- 409
	end, -- 408
	epilogueFooterHint = function(self, _mode, _layout) -- 412
		return "轻触任一入口继续" -- 413
	end, -- 412
	settingsRows = function(self) -- 416
		return ANDROID_SETTINGS_ROWS -- 417
	end, -- 416
	settingsPauseLabel = function(self, _settings) -- 420
		return "触控与声音" -- 421
	end, -- 420
	settingsHeaderTitle = function(self) -- 424
		return "触控与声音" -- 425
	end, -- 424
	settingsHeaderSummary = function(self, _activeMode) -- 428
		return "当前模式：触屏 · 操控与四通道音量实时生效" -- 429
	end, -- 428
	settingsValueText = function(self, rowId, settings, _activeMode) -- 432
		if rowId == "aimAssist" then -- 432
			return settings.aimAssist and "开" or "关" -- 433
		end -- 433
		if rowId == "touchOpacity" then -- 433
			return opacityLabelOf(settings.touchOpacity) -- 434
		end -- 434
		if rowId == "touchScale" then -- 434
			return scaleLabelOf(settings.touchScale) -- 435
		end -- 435
		if rowId == "haptics" then -- 435
			return settings.haptics and "开" or "关" -- 436
		end -- 436
		return volumeSettingText(rowId, settings) -- 437
	end, -- 432
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 440
		if rowId == "back" then -- 440
			return "back" -- 441
		end -- 441
		if rowId == "aimAssist" then -- 441
			settings.aimAssist = not settings.aimAssist -- 443
			saveControlSettings(settings) -- 444
			return "control" -- 445
		end -- 445
		if rowId == "touchOpacity" then -- 445
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 448
			saveControlSettings(settings) -- 449
			return "control" -- 450
		end -- 450
		if rowId == "touchScale" then -- 450
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 453
			saveControlSettings(settings) -- 454
			return "control" -- 455
		end -- 455
		if rowId == "haptics" then -- 455
			settings.haptics = not settings.haptics -- 458
			saveControlSettings(settings) -- 459
			if settings.haptics then -- 459
				input:vibrate(0.018) -- 461
			end -- 461
			return "control" -- 463
		end -- 463
		if applyVolumeSetting(rowId, delta, settings) then -- 463
			return "audio" -- 465
		end -- 465
		return "none" -- 466
	end, -- 440
	createDriver = function(self, settings) -- 469
		return __TS__New(AndroidTouchDriver, settings) -- 470
	end -- 469
} -- 469
return ____exports -- 469