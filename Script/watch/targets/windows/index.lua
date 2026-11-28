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
		input.aim.held = false -- 221
		input.aim.pressed = false -- 222
		input.aim.released = false -- 223
	end -- 223
	input.navUp = s.navUp -- 226
	input.navDown = s.navDown -- 227
	input.navLeft = s.navLeft -- 228
	input.navRight = s.navRight -- 229
	input.navConfirm = s.navConfirm -- 230
	input.navBack = false -- 231
	input.craftConfirm = s.uiConfirmWithE -- 232
	input.craftCancel = s.uiBackSpace -- 233
	local rCol = (s.navRight and 1 or 0) - (s.navLeft and 1 or 0) -- 235
	local rRow = (s.navUp and 1 or 0) - (s.navDown and 1 or 0) -- 236
	if rCol ~= 0 or rRow ~= 0 then -- 236
		input.reloadDirCol = rCol -- 238
		input.reloadDirRow = rRow -- 239
		input.reloadStepEdge = true -- 240
		input.reloadAutoStep = false -- 241
	end -- 241
	input.reloadConfirm = s.uiConfirmWithE -- 243
	input.reloadReset = s.uiBackSpace -- 244
	input:applyPickRoom(s.pick) -- 246
	input.frameInteractPressed = input.interact.pressed -- 247
	input.mdx = s.mouseStageX - input.mx -- 249
	input.mdy = s.mouseStageY - input.my -- 250
	input.mx = s.mouseStageX -- 251
	input.my = s.mouseStageY -- 252
	input.inside = s.mouseInsideStage -- 253
	input.uiX = s.mouseStageX -- 255
	input.uiY = s.mouseStageY -- 256
	input.uiDx = input.mdx -- 257
	input.uiDy = input.mdy -- 258
	input.uiInside = s.mouseInsideStage -- 259
	input.uiHeld = s.mouseLeft and s.mouseInsideStage -- 260
	input.uiPressed = s.mouseLeftPressed and s.mouseInsideStage -- 261
	input.uiReleased = s.mouseLeftReleased -- 262
	input.uiRightPressed = s.mouseRightPressed and s.mouseInsideStage -- 263
end -- 153
____exports.TARGET = { -- 267
	id = "windows", -- 268
	supportsKbm = true, -- 269
	supportsTouch = false, -- 270
	supportsGamepad = false, -- 271
	supportsPortrait = false, -- 272
	defaultInputMode = "kbm", -- 273
	supportedModes = {"kbm"}, -- 274
	modePrefOrder = {"kbm"}, -- 275
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}}, -- 276
	getPlatformCaps = function(self) -- 278
		local cfg = getReleaseConfig() -- 279
		return { -- 280
			kind = desktopKind(), -- 281
			target = "windows", -- 282
			isDesktop = true, -- 283
			isMobile = false, -- 284
			isWeb = false, -- 285
			isStandaloneAndroidApk = false, -- 286
			canToggleFullscreen = true, -- 287
			canQuit = true, -- 288
			hasBackButton = false, -- 289
			supportsHaptics = false, -- 290
			needsAudioUnlock = false, -- 291
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 292
			defaultInputMode = "kbm" -- 293
		} -- 293
	end, -- 278
	canToggleFullscreen = function(self) -- 297
		return true -- 298
	end, -- 297
	canQuitApp = function(self) -- 301
		return true -- 302
	end, -- 301
	isReleaseMode = function(self) -- 305
		local cfg = getReleaseConfig() -- 306
		return cfg ~= nil and cfg.isRelease == true -- 307
	end, -- 305
	computeStageViewport = function(self, fullW, fullH) -- 310
		return computeWindowsViewport(fullW, fullH) -- 311
	end, -- 310
	triggerHaptics = function(self, _seconds, _enabled) -- 314
	end, -- 314
	keyTagFor = function(self, action, _mode, _layout) -- 318
		return keyTagKbm(action) -- 319
	end, -- 318
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 322
		if rawKeyTag == "按住 F" then -- 322
			return "按住 F / 左键" -- 323
		end -- 323
		if rawKeyTag == "松开 F" then -- 323
			return "松开 F / 左键" -- 324
		end -- 324
		if rawKeyTag == "按住 Ctrl" then -- 324
			return "C / CTRL" -- 325
		end -- 325
		return rawKeyTag -- 326
	end, -- 322
	adaptHintSentence = function(self, text, _mode, _layout) -- 329
		return text -- 330
	end, -- 329
	controlsGuideRows = function(self, _tab) -- 333
		return WINDOWS_GUIDE -- 334
	end, -- 333
	splashSkipHint = function(self, _mode, _layout) -- 337
		return "点击 / ESC / SPACE  跳过" -- 338
	end, -- 337
	titleFooterHint = function(self, _mode, _layout) -- 341
		return "上下/滚轮择项   ·   回车或左键启程" -- 342
	end, -- 341
	chapterFooterHint = function(self, _mode, _confirmTag) -- 345
		return "方向键/滚轮选择   ·   回车或左键进入   ·   Esc/右键返回" -- 346
	end, -- 345
	pauseFooterHint = function(self, _mode, _layout) -- 349
		return "Esc 续行   ·   滚轮/上下择项   ·   Enter 或左键确认" -- 350
	end, -- 349
	settingsFooterHint = function(self, _mode, _layout) -- 353
		return "←/→ · 滚轮 · 点击 ‹/› 调节   ·   Esc / 右键返回   ·   自动保存" -- 354
	end, -- 353
	controlsFooterRightHint = function(self, _mode) -- 357
		return "F11 / Alt+Enter 全屏 · 鼠标右键返回 · 标题与暂歇菜单可调游戏设置" -- 358
	end, -- 357
	epilogueFooterHint = function(self, _mode, _layout) -- 361
		return "↑/↓ 或滚轮选择   ·   Enter / 左键确认   ·   Esc / 右键返回标题" -- 362
	end, -- 361
	settingsRows = function(self) -- 365
		return WINDOWS_SETTINGS_ROWS -- 366
	end, -- 365
	settingsPauseLabel = function(self, _settings) -- 369
		return "游戏设置" -- 370
	end, -- 369
	settingsHeaderTitle = function(self) -- 373
		return "游戏设置" -- 374
	end, -- 373
	settingsHeaderSummary = function(self, _activeMode) -- 377
		return "键鼠模式 · 音量、显示、按键辅助与蹲伏方式自动保存" -- 378
	end, -- 377
	settingsValueText = function(self, rowId, settings, _activeMode) -- 381
		if rowId == "fullscreen" then -- 381
			return App.fullScreen and "全屏" or "窗口" -- 383
		end -- 383
		if rowId == "assistHints" then -- 383
			return settings.assistHints and "开" or "关" -- 386
		end -- 386
		if rowId == "crouchToggle" then -- 386
			return settings.crouchToggle and "点按切换" or "按住蹲伏" -- 389
		end -- 389
		return volumeSettingText(rowId, settings) -- 391
	end, -- 381
	applySettingsDelta = function(self, rowId, delta, settings, _input) -- 394
		if rowId == "back" then -- 394
			return "back" -- 400
		end -- 400
		if rowId == "fullscreen" then -- 400
			return "display" -- 401
		end -- 401
		if rowId == "assistHints" then -- 401
			settings.assistHints = not settings.assistHints -- 403
			saveControlSettings(settings) -- 404
			return "assist" -- 405
		end -- 405
		if rowId == "crouchToggle" then -- 405
			settings.crouchToggle = not settings.crouchToggle -- 408
			saveControlSettings(settings) -- 409
			return "control" -- 410
		end -- 410
		local step = delta >= 2 and 1 or (delta <= -2 and -1 or delta) -- 412
		local wrap = math.abs(delta) >= 2 -- 413
		if applyVolumeSetting(rowId, step, settings, wrap) then -- 413
			return "audio" -- 414
		end -- 414
		return "none" -- 415
	end, -- 394
	createDriver = function(self, settings) -- 418
		return __TS__New(WindowsInputDriver, settings) -- 419
	end -- 418
} -- 418
return ____exports -- 418