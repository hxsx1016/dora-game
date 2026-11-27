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
		escortDeathBoxes = ctx.escortDeathBoxes, -- 182
		ledgerButtonBox = ctx.ledgerButtonBox, -- 183
		dt = ctx.dt -- 184
	}) -- 184
end -- 163
function AndroidTouchDriver.prototype.renderOverlay(self) -- 188
	local ____opt_0 = self.controls -- 189
	if ____opt_0 ~= nil then -- 189
		____opt_0:render(self.router) -- 189
	end -- 189
end -- 188
function AndroidTouchDriver.prototype.clearTransient(self, keepTouchToggles) -- 192
	self.router:releaseAll(keepTouchToggles) -- 193
end -- 192
function AndroidTouchDriver.prototype.vibrate(self, seconds) -- 196
	self.router:vibrate(seconds) -- 197
end -- 196
function AndroidTouchDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 200
	return true -- 201
end -- 200
function AndroidTouchDriver.prototype.getTouchRouter(self) -- 204
	return self.router -- 205
end -- 204
function AndroidTouchDriver.prototype.getTouchControls(self) -- 208
	return self.controls -- 209
end -- 208
function AndroidTouchDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 212
	self.router:injectTouch( -- 213
		phase, -- 213
		id, -- 213
		x, -- 213
		y, -- 213
		fromMouse == true -- 213
	) -- 213
end -- 212
function AndroidTouchDriver.prototype.pollInto(self, input) -- 216
	input.inputMode = "touch" -- 217
	local touch = self.router:consumeSnapshot() -- 218
	if touch.hadRealTouch then -- 219
		input.userInteracted = true -- 220
	end -- 220
	input.moveX = touch.moveX -- 223
	input.moveY = touch.moveY -- 224
	input:applyKeyHeld( -- 225
		touch.jumpHeld, -- 226
		touch.crouchHeld, -- 227
		touch.coverHeld, -- 228
		touch.interactHeld, -- 229
		touch.aimHeld, -- 230
		touch.fireHeld, -- 231
		false, -- 232
		false, -- 233
		false, -- 234
		false, -- 235
		false -- 236
	) -- 236
	input:resetFrameSignals() -- 239
	if touch.jumpPressed then -- 240
		input.jump.pressed = true -- 240
	end -- 240
	if touch.interactPressed then -- 241
		input.interact.pressed = true -- 241
	end -- 241
	if touch.firePressed then -- 242
		input.fire.pressed = true -- 242
	end -- 242
	if touch.pausePressed then -- 243
		input.pause.pressed = true -- 243
	end -- 243
	if touch.retryPressed then -- 244
		input.retry.pressed = true -- 244
	end -- 244
	if touch.artifactPressed then -- 245
		input.artifactTogglePressed = true -- 245
	end -- 245
	if touch.mutePressed then -- 246
		input.muteTogglePressed = true -- 246
	end -- 246
	if touch.anyTapBegan then -- 247
		input.splashSkipPressed = true -- 247
	end -- 247
	if touch.zoneTap ~= "" then -- 248
		input.touchZoneTap = touch.zoneTap -- 248
	end -- 248
	input.navUp = touch.navUp -- 249
	input.navDown = touch.navDown -- 250
	input.navLeft = touch.navLeft -- 251
	input.navRight = touch.navRight -- 252
	input.navConfirm = touch.navConfirm -- 253
	input.navBack = touch.navBack -- 254
	input.craftConfirm = touch.navConfirm -- 255
	input.craftCancel = touch.navBack -- 256
	if touch.bottleCanceled then -- 257
		input.bottleCanceled = true -- 258
		input.aim.held = false -- 259
		input.aim.pressed = false -- 260
		input.aim.released = false -- 261
	end -- 261
	input.frameInteractPressed = input.interact.pressed -- 264
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 266
		input.uiX = touch.uiX -- 267
		input.uiY = touch.uiY -- 268
		input.uiDx = touch.uiDx -- 269
		input.uiDy = touch.uiDy -- 270
		input.uiInside = touch.uiInside -- 271
		input.uiHeld = touch.uiHeld -- 272
		input.uiPressed = touch.uiPressed -- 273
		input.uiReleased = touch.uiReleased -- 274
		input.uiRightPressed = false -- 275
		if touch.uiHeld or touch.uiPressed then -- 276
			input.mdx = touch.uiDx -- 277
			input.mdy = touch.uiDy -- 278
			input.mx = touch.uiX -- 279
			input.my = touch.uiY -- 280
			input.inside = true -- 281
		elseif touch.hasAim then -- 282
			input.mdx = touch.aimX - input.mx -- 283
			input.mdy = touch.aimY - input.my -- 284
			input.mx = touch.aimX -- 285
			input.my = touch.aimY -- 286
			input.inside = true -- 287
		else -- 287
			input.mdx = 0 -- 289
			input.mdy = 0 -- 290
			input.inside = touch.uiInside -- 291
		end -- 291
		return -- 293
	end -- 293
	if touch.hasAim then -- 296
		input.mdx = touch.aimX - input.mx -- 297
		input.mdy = touch.aimY - input.my -- 298
		input.mx = touch.aimX -- 299
		input.my = touch.aimY -- 300
		input.inside = true -- 301
	else -- 301
		input.mdx = 0 -- 303
		input.mdy = 0 -- 304
		input.inside = false -- 305
	end -- 305
	input.uiDx = 0 -- 307
	input.uiDy = 0 -- 308
	input.uiInside = false -- 309
	input.uiHeld = false -- 310
	input.uiPressed = false -- 311
	input.uiReleased = false -- 312
	input.uiRightPressed = false -- 313
end -- 216
____exports.TARGET = { -- 317
	id = "android", -- 318
	supportsKbm = false, -- 319
	supportsTouch = true, -- 320
	supportsGamepad = false, -- 321
	supportsPortrait = true, -- 322
	defaultInputMode = "touch", -- 323
	supportedModes = {"touch"}, -- 324
	modePrefOrder = {"touch"}, -- 325
	controlsGuideTabs = {{mode = "touch", label = "触屏"}}, -- 326
	getPlatformCaps = function(self) -- 328
		local standaloneApk = isStandaloneApk() -- 329
		local cfg = getReleaseConfig() -- 330
		return { -- 331
			kind = "android", -- 332
			target = "android", -- 333
			isDesktop = false, -- 334
			isMobile = true, -- 335
			isWeb = false, -- 336
			isStandaloneAndroidApk = standaloneApk, -- 337
			canToggleFullscreen = false, -- 338
			canQuit = standaloneApk, -- 339
			hasBackButton = true, -- 340
			supportsHaptics = type(App.vibrate) == "function", -- 341
			needsAudioUnlock = false, -- 342
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 343
			defaultInputMode = "touch" -- 344
		} -- 344
	end, -- 328
	canToggleFullscreen = function(self) -- 348
		return false -- 349
	end, -- 348
	canQuitApp = function(self) -- 352
		return isStandaloneApk() -- 353
	end, -- 352
	isReleaseMode = function(self) -- 356
		local cfg = getReleaseConfig() -- 357
		return cfg ~= nil and cfg.isRelease == true -- 358
	end, -- 356
	computeStageViewport = function(self, fullW, fullH) -- 361
		return computeAdaptiveViewport(fullW, fullH) -- 362
	end, -- 361
	triggerHaptics = function(self, seconds, enabled) -- 365
		triggerMobileHaptics(seconds, enabled) -- 366
	end, -- 365
	keyTagFor = function(self, action, _mode, _layout) -- 369
		return keyTagTouch(action) -- 370
	end, -- 369
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 373
		return adaptWorldKeyTagTouch(rawKeyTag) -- 374
	end, -- 373
	adaptHintSentence = function(self, text, _mode, _layout) -- 377
		return adaptHintSentenceTouch(text) -- 378
	end, -- 377
	controlsGuideRows = function(self, _tab) -- 381
		return ANDROID_GUIDE -- 382
	end, -- 381
	splashSkipHint = function(self, _mode, _layout) -- 385
		return "轻触跳过" -- 386
	end, -- 385
	titleFooterHint = function(self, _mode, _layout) -- 389
		return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程" -- 390
	end, -- 389
	chapterFooterHint = function(self, _mode, _confirmTag) -- 395
		return "轻触驿站预览   ·   再点或轻触入此卷章" -- 396
	end, -- 395
	pauseFooterHint = function(self, _mode, _layout) -- 399
		return "轻触确认   ·   点「继续游戏」续行" -- 400
	end, -- 399
	settingsFooterHint = function(self, _mode, _layout) -- 403
		return "轻触任意条目切换   ·   设置自动保存" -- 404
	end, -- 403
	controlsFooterRightHint = function(self, _mode) -- 407
		return "暂歇菜单可调触控与声音" -- 408
	end, -- 407
	epilogueFooterHint = function(self, _mode, _layout) -- 411
		return "轻触任一入口继续" -- 412
	end, -- 411
	trialSubHint = function(self, _mode, ended, seed) -- 415
		return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 416
	end, -- 415
	settingsRows = function(self) -- 419
		return ANDROID_SETTINGS_ROWS -- 420
	end, -- 419
	settingsPauseLabel = function(self, _settings) -- 423
		return "触控与声音" -- 424
	end, -- 423
	settingsHeaderTitle = function(self) -- 427
		return "触控与声音" -- 428
	end, -- 427
	settingsHeaderSummary = function(self, _activeMode) -- 431
		return "当前模式：触屏 · 操控与四通道音量实时生效" -- 432
	end, -- 431
	settingsValueText = function(self, rowId, settings, _activeMode) -- 435
		if rowId == "aimAssist" then -- 436
			return settings.aimAssist and "开" or "关" -- 436
		end -- 436
		if rowId == "touchOpacity" then -- 437
			return opacityLabelOf(settings.touchOpacity) -- 437
		end -- 437
		if rowId == "touchScale" then -- 438
			return scaleLabelOf(settings.touchScale) -- 438
		end -- 438
		if rowId == "haptics" then -- 439
			return settings.haptics and "开" or "关" -- 439
		end -- 439
		return volumeSettingText(rowId, settings) -- 440
	end, -- 435
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 443
		if rowId == "back" then -- 444
			return "back" -- 444
		end -- 444
		if rowId == "aimAssist" then -- 445
			settings.aimAssist = not settings.aimAssist -- 446
			saveControlSettings(settings) -- 447
			return "control" -- 448
		end -- 448
		if rowId == "touchOpacity" then -- 450
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 451
			saveControlSettings(settings) -- 452
			return "control" -- 453
		end -- 453
		if rowId == "touchScale" then -- 455
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 456
			saveControlSettings(settings) -- 457
			return "control" -- 458
		end -- 458
		if rowId == "haptics" then -- 460
			settings.haptics = not settings.haptics -- 461
			saveControlSettings(settings) -- 462
			if settings.haptics then -- 463
				input:vibrate(0.018) -- 464
			end -- 464
			return "control" -- 466
		end -- 466
		if applyVolumeSetting(rowId, delta, settings) then -- 468
			return "audio" -- 468
		end -- 468
		return "none" -- 469
	end, -- 443
	createDriver = function(self, settings) -- 472
		return __TS__New(AndroidTouchDriver, settings) -- 473
	end -- 472
} -- 472
return ____exports -- 472
