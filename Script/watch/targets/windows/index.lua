-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local App = ____Dora.App -- 10
local View = ____Dora.View -- 10
local ____kbm_core = require("Script.watch.input.kbm_core") -- 11
local KbmPoller = ____kbm_core.KbmPoller -- 11
local ____controls_config = require("Script.watch.controls_config") -- 12
local applyVolumeSetting = ____controls_config.applyVolumeSetting -- 12
local saveControlSettings = ____controls_config.saveControlSettings -- 12
local volumeSettingText = ____controls_config.volumeSettingText -- 12
local ____target_types = require("Script.watch.target_types") -- 14
local ZERO_SAFE_INSETS = ____target_types.ZERO_SAFE_INSETS -- 28
local getReleaseConfig = ____target_types.getReleaseConfig -- 29
local RETRY_HOLD_DEADZONE = 0.08 -- 32
local RETRY_HOLD_DURATION = 0.65 -- 33
local WINDOWS_SETTINGS_ROWS = { -- 35
	{id = "masterVol", title = "主音量"}, -- 36
	{id = "bgmVol", title = "音乐音量"}, -- 37
	{id = "sfxVol", title = "音效与环境"}, -- 38
	{id = "voiceVol", title = "人声音量"}, -- 39
	{id = "fullscreen", title = "显示模式"}, -- 40
	{id = "assistHints", title = "按键辅助"}, -- 41
	{id = "crouchToggle", title = "蹲伏方式"}, -- 42
	{id = "back", title = "返回"} -- 43
} -- 43
local WINDOWS_GUIDE = {subtitle = "键鼠操作说明 · Windows 桌面", soldierRows = { -- 46
	{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 49
	{"鼠标 + 左键 / Q·右键", "瞄准发射火铳 · Q/右键开换弹盘"}, -- 50
	{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 51
	{"E / 1·2·3 / 点提示", "交互推车工台 · 数字键或点击选本领"}, -- 52
	{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 53
	{"ESC / 长按R / V / T", "暂歇 · 重试检查点 · 札记 · 切神器"} -- 54
}, childRows = { -- 54
	{"WASD / 方向键", "前后左右纵深潜行"}, -- 57
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 58
	{"C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底（可改切换）"}, -- 59
	{"SPACE", "跳跃攀上石阶与矮台"}, -- 60
	{"E / 点世界提示", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 61
	{"F / 左键 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 62
}} -- 62
local function desktopKind() -- 66
	local plat = App.platform -- 67
	if plat == "macOS" then -- 67
		return "macos" -- 68
	end -- 68
	if plat == "Linux" then -- 68
		return "linux" -- 69
	end -- 69
	return "windows" -- 70
end -- 66
local function keyTagKbm(action) -- 73
	if action == "interact" then -- 73
		return "E" -- 74
	end -- 74
	if action == "jump" then -- 74
		return "SPACE" -- 75
	end -- 75
	if action == "crouch" then -- 75
		return "C / CTRL" -- 76
	end -- 76
	if action == "cover" then -- 76
		return "SHIFT" -- 77
	end -- 77
	if action == "fire" then -- 77
		return "左键" -- 78
	end -- 78
	if action == "aim" then -- 78
		return "F / 左键" -- 79
	end -- 79
	if action == "pause" then -- 79
		return "ESC" -- 80
	end -- 80
	if action == "retry" then -- 80
		return "长按 R" -- 81
	end -- 81
	if action == "confirm" then -- 81
		return "ENTER" -- 82
	end -- 82
	if action == "back" then -- 82
		return "ESC" -- 83
	end -- 83
	return "T" -- 84
end -- 73
local function computeWindowsViewport(fullW, fullH) -- 87
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 88
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 89
	local uiScale = math.max( -- 90
		0.25, -- 90
		math.min(w / 1280, h / 720) -- 90
	) -- 90
	return { -- 91
		fullW = w, -- 92
		fullH = h, -- 93
		stageX = 0, -- 94
		stageY = 0, -- 95
		stageW = w, -- 96
		stageH = h, -- 97
		deckH = 0, -- 98
		topBarH = 0, -- 99
		isPortrait = false, -- 100
		uiScale = uiScale, -- 101
		uiW = w / uiScale, -- 102
		uiH = h / uiScale, -- 103
		safe = ZERO_SAFE_INSETS, -- 104
		safeUi = ZERO_SAFE_INSETS -- 105
	} -- 105
end -- 87
local WindowsInputDriver = __TS__Class() -- 109
WindowsInputDriver.name = "WindowsInputDriver" -- 109
function WindowsInputDriver.prototype.____constructor(self, settings) -- 117
	self.defaultMode = "kbm" -- 110
	self.kbm = __TS__New(KbmPoller) -- 111
	self.crouchLatched = false -- 113
	self.retryHoldSec = 0 -- 114
	self.retryFired = false -- 115
	self.settings = settings -- 118
end -- 117
function WindowsInputDriver.prototype.attach(self, parent, hooks) -- 121
	self.kbm:attach(parent, hooks, {latchTouchEvents = true, disableIme = true}) -- 122
end -- 121
function WindowsInputDriver.prototype.syncFrame(self, _ctx) -- 128
end -- 128
function WindowsInputDriver.prototype.renderOverlay(self) -- 132
end -- 132
function WindowsInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 136
	self.kbm:clearTransient() -- 137
	self.retryHoldSec = 0 -- 138
	self.retryFired = false -- 139
	if not keepTouchToggles then -- 139
		self.crouchLatched = false -- 141
	end -- 141
end -- 136
function WindowsInputDriver.prototype.vibrate(self, _seconds) -- 145
end -- 145
function WindowsInputDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 149
	return false -- 150
end -- 149
function WindowsInputDriver.prototype.pollInto(self, input, dt) -- 153
	if dt == nil then -- 153
		dt = 1 / 60 -- 153
	end -- 153
	local safeDt = math.min( -- 154
		0.05, -- 154
		math.max(0.001, dt) -- 154
	) -- 154
	input.inputMode = "kbm" -- 155
	local s = self.kbm:sample( -- 156
		input:getStageViewport(), -- 156
		safeDt -- 156
	) -- 156
	if s.anyKb or s.mouseMoved or s.mouseClicked and s.mouseInsideStage then -- 156
		input.userInteracted = true -- 159
	end -- 159
	local crouchHeld = s.crouch -- 163
	if self.settings.crouchToggle then -- 163
		if s.crouchPressed then -- 163
			self.crouchLatched = not self.crouchLatched -- 166
		end -- 166
		if s.jump then -- 166
			self.crouchLatched = false -- 169
		end -- 169
		crouchHeld = self.crouchLatched -- 171
	else -- 171
		self.crouchLatched = false -- 173
	end -- 173
	local retryTriggered = false -- 177
	if s.retry then -- 177
		self.retryHoldSec = self.retryHoldSec + safeDt -- 179
		if self.retryHoldSec >= RETRY_HOLD_DURATION and not self.retryFired then -- 179
			self.retryFired = true -- 181
			retryTriggered = true -- 182
		end -- 182
	else -- 182
		self.retryHoldSec = 0 -- 185
		self.retryFired = false -- 186
	end -- 186
	input.moveX = s.moveX -- 189
	input.moveY = s.moveY -- 190
	input:applyKeyHeld( -- 191
		s.jump, -- 192
		crouchHeld, -- 193
		s.cover, -- 194
		s.interact, -- 195
		s.aim, -- 196
		s.mouseInsideStage and s.mouseLeft, -- 197
		s.flare, -- 198
		s.pause, -- 199
		false, -- 200
		s.toggleView, -- 201
		s.tab -- 202
	) -- 202
	if s.pausePressed then -- 202
		input.pause.pressed = true -- 205
	end -- 205
	if retryTriggered then -- 205
		input.retry.pressed = true -- 208
	end -- 208
	input:resetFrameSignals() -- 211
	input.retryTapPressed = s.retryTapPressed -- 212
	input.retryHoldProgress = not self.retryFired and self.retryHoldSec > RETRY_HOLD_DEADZONE and math.min(1, (self.retryHoldSec - RETRY_HOLD_DEADZONE) / (RETRY_HOLD_DURATION - RETRY_HOLD_DEADZONE)) or 0 -- 213
	input.ledgerTogglePressed = s.ledgerTogglePressed -- 216
	input.uiWheelY = s.mouseWheelY -- 217
	if (input.aim.held or input.fire.held) and s.mouseRightPressed then -- 217
		input.bottleCanceled = true -- 220
	end -- 220
	input.navUp = s.navUp -- 223
	input.navDown = s.navDown -- 224
	input.navLeft = s.navLeft -- 225
	input.navRight = s.navRight -- 226
	input.navConfirm = s.navConfirm -- 227
	input.navBack = false -- 228
	input.craftConfirm = s.uiConfirmWithE -- 229
	input.craftCancel = s.uiBackSpace -- 230
	local rCol = (s.navRight and 1 or 0) - (s.navLeft and 1 or 0) -- 232
	local rRow = (s.navUp and 1 or 0) - (s.navDown and 1 or 0) -- 233
	if rCol ~= 0 or rRow ~= 0 then -- 233
		input.reloadDirCol = rCol -- 235
		input.reloadDirRow = rRow -- 236
		input.reloadStepEdge = true -- 237
		input.reloadAutoStep = false -- 238
	end -- 238
	input.reloadConfirm = s.uiConfirmWithE -- 240
	input.reloadReset = s.uiBackSpace -- 241
	input:applyPickRoom(s.pick) -- 243
	input.frameInteractPressed = input.interact.pressed -- 244
	input.mdx = s.mouseStageX - input.mx -- 246
	input.mdy = s.mouseStageY - input.my -- 247
	input.mx = s.mouseStageX -- 248
	input.my = s.mouseStageY -- 249
	input.inside = s.mouseInsideStage -- 250
	input.uiX = s.mouseStageX -- 252
	input.uiY = s.mouseStageY -- 253
	input.uiDx = input.mdx -- 254
	input.uiDy = input.mdy -- 255
	input.uiInside = s.mouseInsideStage -- 256
	input.uiHeld = s.mouseLeft and s.mouseInsideStage -- 257
	input.uiPressed = s.mouseLeftPressed and s.mouseInsideStage -- 258
	input.uiReleased = s.mouseLeftReleased -- 259
	input.uiRightPressed = s.mouseRightPressed and s.mouseInsideStage -- 260
end -- 153
____exports.TARGET = { -- 264
	id = "windows", -- 265
	supportsKbm = true, -- 266
	supportsTouch = false, -- 267
	supportsGamepad = false, -- 268
	supportsPortrait = false, -- 269
	defaultInputMode = "kbm", -- 270
	supportedModes = {"kbm"}, -- 271
	modePrefOrder = {"kbm"}, -- 272
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}}, -- 273
	getPlatformCaps = function(self) -- 275
		local cfg = getReleaseConfig() -- 276
		return { -- 277
			kind = desktopKind(), -- 278
			target = "windows", -- 279
			isDesktop = true, -- 280
			isMobile = false, -- 281
			isWeb = false, -- 282
			isStandaloneAndroidApk = false, -- 283
			canToggleFullscreen = true, -- 284
			canQuit = true, -- 285
			hasBackButton = false, -- 286
			supportsHaptics = false, -- 287
			needsAudioUnlock = false, -- 288
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 289
			defaultInputMode = "kbm" -- 290
		} -- 290
	end, -- 275
	canToggleFullscreen = function(self) -- 294
		return true -- 295
	end, -- 294
	canQuitApp = function(self) -- 298
		return true -- 299
	end, -- 298
	isReleaseMode = function(self) -- 302
		local cfg = getReleaseConfig() -- 303
		return cfg ~= nil and cfg.isRelease == true -- 304
	end, -- 302
	computeStageViewport = function(self, fullW, fullH) -- 307
		return computeWindowsViewport(fullW, fullH) -- 308
	end, -- 307
	triggerHaptics = function(self, _seconds, _enabled) -- 311
	end, -- 311
	keyTagFor = function(self, action, _mode, _layout) -- 315
		return keyTagKbm(action) -- 316
	end, -- 315
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 319
		if rawKeyTag == "按住 F" then -- 319
			return "按住 F / 左键" -- 320
		end -- 320
		if rawKeyTag == "松开 F" then -- 320
			return "松开 F / 左键" -- 321
		end -- 321
		if rawKeyTag == "按住 Ctrl" then -- 321
			return "C / CTRL" -- 322
		end -- 322
		return rawKeyTag -- 323
	end, -- 319
	adaptHintSentence = function(self, text, _mode, _layout) -- 326
		return text -- 327
	end, -- 326
	controlsGuideRows = function(self, _tab) -- 330
		return WINDOWS_GUIDE -- 331
	end, -- 330
	splashSkipHint = function(self, _mode, _layout) -- 334
		return "点击 / ESC / SPACE  跳过" -- 335
	end, -- 334
	titleFooterHint = function(self, _mode, _layout) -- 338
		return "上下/滚轮择项   ·   回车或左键启程" -- 339
	end, -- 338
	chapterFooterHint = function(self, _mode, _confirmTag) -- 342
		return "方向键/滚轮选择   ·   回车或左键进入   ·   Esc/右键返回" -- 343
	end, -- 342
	pauseFooterHint = function(self, _mode, _layout) -- 346
		return "Esc 续行   ·   滚轮/上下择项   ·   Enter 或左键确认" -- 347
	end, -- 346
	settingsFooterHint = function(self, _mode, _layout) -- 350
		return "←/→ · 滚轮 · 点击 ‹/› 调节   ·   Esc / 右键返回   ·   自动保存" -- 351
	end, -- 350
	controlsFooterRightHint = function(self, _mode) -- 354
		return "F11 / Alt+Enter 全屏 · 鼠标右键返回 · 标题与暂歇菜单可调游戏设置" -- 355
	end, -- 354
	epilogueFooterHint = function(self, _mode, _layout) -- 358
		return "↑/↓ 或滚轮选择   ·   Enter / 左键确认   ·   Esc / 右键返回标题" -- 359
	end, -- 358
	settingsRows = function(self) -- 362
		return WINDOWS_SETTINGS_ROWS -- 363
	end, -- 362
	settingsPauseLabel = function(self, _settings) -- 366
		return "游戏设置" -- 367
	end, -- 366
	settingsHeaderTitle = function(self) -- 370
		return "游戏设置" -- 371
	end, -- 370
	settingsHeaderSummary = function(self, _activeMode) -- 374
		return "键鼠模式 · 音量、显示、按键辅助与蹲伏方式自动保存" -- 375
	end, -- 374
	settingsValueText = function(self, rowId, settings, _activeMode) -- 378
		if rowId == "fullscreen" then -- 378
			return App.fullScreen and "全屏" or "窗口" -- 380
		end -- 380
		if rowId == "assistHints" then -- 380
			return settings.assistHints and "开" or "关" -- 383
		end -- 383
		if rowId == "crouchToggle" then -- 383
			return settings.crouchToggle and "点按切换" or "按住蹲伏" -- 386
		end -- 386
		return volumeSettingText(rowId, settings) -- 388
	end, -- 378
	applySettingsDelta = function(self, rowId, delta, settings, _input) -- 391
		if rowId == "back" then -- 391
			return "back" -- 397
		end -- 397
		if rowId == "fullscreen" then -- 397
			return "display" -- 398
		end -- 398
		if rowId == "assistHints" then -- 398
			settings.assistHints = not settings.assistHints -- 400
			saveControlSettings(settings) -- 401
			return "assist" -- 402
		end -- 402
		if rowId == "crouchToggle" then -- 402
			settings.crouchToggle = not settings.crouchToggle -- 405
			saveControlSettings(settings) -- 406
			return "control" -- 407
		end -- 407
		local step = delta >= 2 and 1 or (delta <= -2 and -1 or delta) -- 409
		local wrap = math.abs(delta) >= 2 -- 410
		if applyVolumeSetting(rowId, step, settings, wrap) then -- 410
			return "audio" -- 411
		end -- 411
		return "none" -- 412
	end, -- 391
	createDriver = function(self, settings) -- 415
		return __TS__New(WindowsInputDriver, settings) -- 416
	end -- 415
} -- 415
return ____exports -- 415