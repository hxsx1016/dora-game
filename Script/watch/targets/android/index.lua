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
}, childRows = { -- 65
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
	if action == "interact" then -- 81
		return "点按" -- 81
	end -- 81
	if action == "jump" then -- 82
		return "跳/滚" -- 82
	end -- 82
	if action == "crouch" then -- 83
		return "蹲伏" -- 83
	end -- 83
	if action == "cover" then -- 84
		return "掩体" -- 84
	end -- 84
	if action == "fire" then -- 85
		return "开火" -- 85
	end -- 85
	if action == "aim" then -- 86
		return "拖投瓶" -- 86
	end -- 86
	if action == "pause" then -- 87
		return "暂歇" -- 87
	end -- 87
	if action == "retry" then -- 88
		return "重试" -- 88
	end -- 88
	if action == "confirm" then -- 89
		return "点选" -- 89
	end -- 89
	if action == "back" then -- 90
		return "返回" -- 90
	end -- 90
	return "穿梭" -- 91
end -- 80
local function adaptWorldKeyTagTouch(rawKeyTag) -- 94
	if rawKeyTag == "E" then -- 95
		return "轻触" -- 95
	end -- 95
	if rawKeyTag == "按住 E" then -- 96
		return "长按交互" -- 96
	end -- 96
	if rawKeyTag == "松开再按住 E" then -- 97
		return "松开再长按" -- 97
	end -- 97
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 98
		return "点推车+摇杆" -- 98
	end -- 98
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 99
		return "开火" -- 99
	end -- 99
	if rawKeyTag == "按住 F" then -- 100
		return "拖投瓶" -- 100
	end -- 100
	if rawKeyTag == "松开 F" then -- 101
		return "松手投" -- 101
	end -- 101
	if rawKeyTag == "按住 Ctrl" then -- 102
		return "点蹲伏" -- 102
	end -- 102
	if rawKeyTag == "按住 Shift" then -- 103
		return "点掩体" -- 103
	end -- 103
	if rawKeyTag == "连线" then -- 104
		return "一笔划连" -- 104
	end -- 104
	return rawKeyTag -- 105
end -- 94
local function adaptHintSentenceTouch(text) -- 108
	if text == "" then -- 109
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
	if self.controls == nil then -- 158
		self.controls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 159
	end -- 159
end -- 156
function AndroidTouchDriver.prototype.syncFrame(self, ctx) -- 163
	if self.controls == nil then -- 164
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
		dt = ctx.dt -- 182
	}) -- 182
end -- 163
function AndroidTouchDriver.prototype.renderOverlay(self) -- 186
	local ____opt_0 = self.controls -- 187
	if ____opt_0 ~= nil then -- 187
		____opt_0:render(self.router) -- 187
	end -- 187
end -- 186
function AndroidTouchDriver.prototype.clearTransient(self, keepTouchToggles) -- 190
	self.router:releaseAll(keepTouchToggles) -- 191
end -- 190
function AndroidTouchDriver.prototype.vibrate(self, seconds) -- 194
	self.router:vibrate(seconds) -- 195
end -- 194
function AndroidTouchDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 198
	return true -- 199
end -- 198
function AndroidTouchDriver.prototype.getTouchRouter(self) -- 202
	return self.router -- 203
end -- 202
function AndroidTouchDriver.prototype.getTouchControls(self) -- 206
	return self.controls -- 207
end -- 206
function AndroidTouchDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 210
	self.router:injectTouch( -- 211
		phase, -- 211
		id, -- 211
		x, -- 211
		y, -- 211
		fromMouse == true -- 211
	) -- 211
end -- 210
function AndroidTouchDriver.prototype.pollInto(self, input) -- 214
	input.inputMode = "touch" -- 215
	local touch = self.router:consumeSnapshot() -- 216
	if touch.hadRealTouch then -- 217
		input.userInteracted = true -- 218
	end -- 218
	input.moveX = touch.moveX -- 221
	input.moveY = touch.moveY -- 222
	input:applyKeyHeld( -- 223
		touch.jumpHeld, -- 224
		touch.crouchHeld, -- 225
		touch.coverHeld, -- 226
		touch.interactHeld, -- 227
		touch.aimHeld, -- 228
		touch.fireHeld, -- 229
		false, -- 230
		false, -- 231
		false, -- 232
		false, -- 233
		false -- 234
	) -- 234
	input:resetFrameSignals() -- 237
	if touch.jumpPressed then -- 238
		input.jump.pressed = true -- 238
	end -- 238
	if touch.interactPressed then -- 239
		input.interact.pressed = true -- 239
	end -- 239
	if touch.firePressed then -- 240
		input.fire.pressed = true -- 240
	end -- 240
	if touch.pausePressed then -- 241
		input.pause.pressed = true -- 241
	end -- 241
	if touch.retryPressed then -- 242
		input.retry.pressed = true -- 242
	end -- 242
	if touch.artifactPressed then -- 243
		input.artifactTogglePressed = true -- 243
	end -- 243
	if touch.mutePressed then -- 244
		input.muteTogglePressed = true -- 244
	end -- 244
	if touch.anyTapBegan then -- 245
		input.splashSkipPressed = true -- 245
	end -- 245
	if touch.zoneTap ~= "" then -- 246
		input.touchZoneTap = touch.zoneTap -- 246
	end -- 246
	input.navUp = touch.navUp -- 247
	input.navDown = touch.navDown -- 248
	input.navLeft = touch.navLeft -- 249
	input.navRight = touch.navRight -- 250
	input.navConfirm = touch.navConfirm -- 251
	input.navBack = touch.navBack -- 252
	input.craftConfirm = touch.navConfirm -- 253
	input.craftCancel = touch.navBack -- 254
	if touch.bottleCanceled then -- 255
		input.bottleCanceled = true -- 256
		input.aim.held = false -- 257
		input.aim.pressed = false -- 258
		input.aim.released = false -- 259
	end -- 259
	input.frameInteractPressed = input.interact.pressed -- 262
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 264
		input.uiX = touch.uiX -- 265
		input.uiY = touch.uiY -- 266
		input.uiDx = touch.uiDx -- 267
		input.uiDy = touch.uiDy -- 268
		input.uiInside = touch.uiInside -- 269
		input.uiHeld = touch.uiHeld -- 270
		input.uiPressed = touch.uiPressed -- 271
		input.uiReleased = touch.uiReleased -- 272
		input.uiRightPressed = false -- 273
		if touch.uiHeld or touch.uiPressed then -- 274
			input.mdx = touch.uiDx -- 275
			input.mdy = touch.uiDy -- 276
			input.mx = touch.uiX -- 277
			input.my = touch.uiY -- 278
			input.inside = true -- 279
		elseif touch.hasAim then -- 280
			input.mdx = touch.aimX - input.mx -- 281
			input.mdy = touch.aimY - input.my -- 282
			input.mx = touch.aimX -- 283
			input.my = touch.aimY -- 284
			input.inside = true -- 285
		else -- 285
			input.mdx = 0 -- 287
			input.mdy = 0 -- 288
			input.inside = touch.uiInside -- 289
		end -- 289
		return -- 291
	end -- 291
	if touch.hasAim then -- 294
		input.mdx = touch.aimX - input.mx -- 295
		input.mdy = touch.aimY - input.my -- 296
		input.mx = touch.aimX -- 297
		input.my = touch.aimY -- 298
		input.inside = true -- 299
	else -- 299
		input.mdx = 0 -- 301
		input.mdy = 0 -- 302
		input.inside = false -- 303
	end -- 303
	input.uiDx = 0 -- 305
	input.uiDy = 0 -- 306
	input.uiInside = false -- 307
	input.uiHeld = false -- 308
	input.uiPressed = false -- 309
	input.uiReleased = false -- 310
	input.uiRightPressed = false -- 311
end -- 214
____exports.TARGET = { -- 315
	id = "android", -- 316
	supportsKbm = false, -- 317
	supportsTouch = true, -- 318
	supportsGamepad = false, -- 319
	supportsPortrait = true, -- 320
	defaultInputMode = "touch", -- 321
	supportedModes = {"touch"}, -- 322
	modePrefOrder = {"touch"}, -- 323
	controlsGuideTabs = {{mode = "touch", label = "触屏"}}, -- 324
	getPlatformCaps = function(self) -- 326
		local standaloneApk = isStandaloneApk() -- 327
		local cfg = getReleaseConfig() -- 328
		return { -- 329
			kind = "android", -- 330
			target = "android", -- 331
			isDesktop = false, -- 332
			isMobile = true, -- 333
			isWeb = false, -- 334
			isStandaloneAndroidApk = standaloneApk, -- 335
			canToggleFullscreen = false, -- 336
			canQuit = standaloneApk, -- 337
			hasBackButton = true, -- 338
			supportsHaptics = type(App.vibrate) == "function", -- 339
			needsAudioUnlock = false, -- 340
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 341
			defaultInputMode = "touch" -- 342
		} -- 342
	end, -- 326
	canToggleFullscreen = function(self) -- 346
		return false -- 347
	end, -- 346
	canQuitApp = function(self) -- 350
		return isStandaloneApk() -- 351
	end, -- 350
	isReleaseMode = function(self) -- 354
		local cfg = getReleaseConfig() -- 355
		return cfg ~= nil and cfg.isRelease == true -- 356
	end, -- 354
	computeStageViewport = function(self, fullW, fullH) -- 359
		return computeAdaptiveViewport(fullW, fullH) -- 360
	end, -- 359
	triggerHaptics = function(self, seconds, enabled) -- 363
		triggerMobileHaptics(seconds, enabled) -- 364
	end, -- 363
	keyTagFor = function(self, action, _mode, _layout) -- 367
		return keyTagTouch(action) -- 368
	end, -- 367
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 371
		return adaptWorldKeyTagTouch(rawKeyTag) -- 372
	end, -- 371
	adaptHintSentence = function(self, text, _mode, _layout) -- 375
		return adaptHintSentenceTouch(text) -- 376
	end, -- 375
	controlsGuideRows = function(self, _tab) -- 379
		return ANDROID_GUIDE -- 380
	end, -- 379
	splashSkipHint = function(self, _mode, _layout) -- 383
		return "轻触跳过" -- 384
	end, -- 383
	titleFooterHint = function(self, _mode, _layout) -- 387
		return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程" -- 388
	end, -- 387
	chapterFooterHint = function(self, _mode, _confirmTag) -- 393
		return "轻触驿站预览   ·   再点或轻触入此卷章" -- 394
	end, -- 393
	pauseFooterHint = function(self, _mode, _layout) -- 397
		return "轻触确认   ·   点「继续游戏」续行" -- 398
	end, -- 397
	settingsFooterHint = function(self, _mode, _layout) -- 401
		return "轻触任意条目切换   ·   设置自动保存" -- 402
	end, -- 401
	controlsFooterRightHint = function(self, _mode) -- 405
		return "暂歇菜单可调触控与声音" -- 406
	end, -- 405
	epilogueFooterHint = function(self, _mode, _layout) -- 409
		return "轻触任一入口继续" -- 410
	end, -- 409
	trialSubHint = function(self, _mode, ended, seed) -- 413
		return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 414
	end, -- 413
	settingsRows = function(self) -- 417
		return ANDROID_SETTINGS_ROWS -- 418
	end, -- 417
	settingsPauseLabel = function(self, _settings) -- 421
		return "触控与声音" -- 422
	end, -- 421
	settingsHeaderTitle = function(self) -- 425
		return "触控与声音" -- 426
	end, -- 425
	settingsHeaderSummary = function(self, _activeMode) -- 429
		return "当前模式：触屏 · 操控与四通道音量实时生效" -- 430
	end, -- 429
	settingsValueText = function(self, rowId, settings, _activeMode) -- 433
		if rowId == "aimAssist" then -- 434
			return settings.aimAssist and "开" or "关" -- 434
		end -- 434
		if rowId == "touchOpacity" then -- 435
			return opacityLabelOf(settings.touchOpacity) -- 435
		end -- 435
		if rowId == "touchScale" then -- 436
			return scaleLabelOf(settings.touchScale) -- 436
		end -- 436
		if rowId == "haptics" then -- 437
			return settings.haptics and "开" or "关" -- 437
		end -- 437
		return volumeSettingText(rowId, settings) -- 438
	end, -- 433
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 441
		if rowId == "back" then -- 442
			return "back" -- 442
		end -- 442
		if rowId == "aimAssist" then -- 443
			settings.aimAssist = not settings.aimAssist -- 444
			saveControlSettings(settings) -- 445
			return "control" -- 446
		end -- 446
		if rowId == "touchOpacity" then -- 448
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 449
			saveControlSettings(settings) -- 450
			return "control" -- 451
		end -- 451
		if rowId == "touchScale" then -- 453
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 454
			saveControlSettings(settings) -- 455
			return "control" -- 456
		end -- 456
		if rowId == "haptics" then -- 458
			settings.haptics = not settings.haptics -- 459
			saveControlSettings(settings) -- 460
			if settings.haptics then -- 461
				input:vibrate(0.018) -- 462
			end -- 462
			return "control" -- 464
		end -- 464
		if applyVolumeSetting(rowId, delta, settings) then -- 466
			return "audio" -- 466
		end -- 466
		return "none" -- 467
	end, -- 441
	createDriver = function(self, settings) -- 470
		return __TS__New(AndroidTouchDriver, settings) -- 471
	end -- 470
} -- 470
return ____exports -- 470
