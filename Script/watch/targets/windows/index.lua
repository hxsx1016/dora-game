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
local WINDOWS_SETTINGS_ROWS = { -- 32
	{id = "masterVol", title = "主音量"}, -- 33
	{id = "bgmVol", title = "音乐音量"}, -- 34
	{id = "sfxVol", title = "音效与环境"}, -- 35
	{id = "voiceVol", title = "人声音量"}, -- 36
	{id = "fullscreen", title = "显示模式"}, -- 37
	{id = "assistHints", title = "按键辅助"}, -- 38
	{id = "back", title = "返回"} -- 39
} -- 39
local WINDOWS_GUIDE = {subtitle = "键鼠操作说明 · Windows 桌面", soldierRows = { -- 42
	{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 45
	{"鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"}, -- 46
	{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 47
	{"E / 1·2·3", "交互推车工台 · 数字键选护送本领"}, -- 48
	{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 49
	{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 50
}, childRows = { -- 50
	{"WASD / 方向键", "前后左右纵深潜行"}, -- 53
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 54
	{"按住 C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 55
	{"SPACE", "跳跃攀上石阶与矮台"}, -- 56
	{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 57
	{"F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 58
}} -- 58
local function desktopKind() -- 62
	local plat = App.platform -- 63
	if plat == "macOS" then -- 63
		return "macos" -- 64
	end -- 64
	if plat == "Linux" then -- 64
		return "linux" -- 65
	end -- 65
	return "windows" -- 66
end -- 62
local function keyTagKbm(action) -- 69
	if action == "interact" then -- 69
		return "E" -- 70
	end -- 70
	if action == "jump" then -- 70
		return "SPACE" -- 71
	end -- 71
	if action == "crouch" then -- 71
		return "CTRL" -- 72
	end -- 72
	if action == "cover" then -- 72
		return "SHIFT" -- 73
	end -- 73
	if action == "fire" then -- 73
		return "左键" -- 74
	end -- 74
	if action == "aim" then -- 74
		return "F" -- 75
	end -- 75
	if action == "pause" then -- 75
		return "ESC" -- 76
	end -- 76
	if action == "retry" then -- 76
		return "R" -- 77
	end -- 77
	if action == "confirm" then -- 77
		return "ENTER" -- 78
	end -- 78
	if action == "back" then -- 78
		return "ESC" -- 79
	end -- 79
	return "T" -- 80
end -- 69
local function computeWindowsViewport(fullW, fullH) -- 83
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 84
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 85
	local uiScale = math.max( -- 86
		0.25, -- 86
		math.min(w / 1280, h / 720) -- 86
	) -- 86
	return { -- 87
		fullW = w, -- 88
		fullH = h, -- 89
		stageX = 0, -- 90
		stageY = 0, -- 91
		stageW = w, -- 92
		stageH = h, -- 93
		deckH = 0, -- 94
		topBarH = 0, -- 95
		isPortrait = false, -- 96
		uiScale = uiScale, -- 97
		uiW = w / uiScale, -- 98
		uiH = h / uiScale, -- 99
		safe = ZERO_SAFE_INSETS, -- 100
		safeUi = ZERO_SAFE_INSETS -- 101
	} -- 101
end -- 83
local WindowsInputDriver = __TS__Class() -- 105
WindowsInputDriver.name = "WindowsInputDriver" -- 105
function WindowsInputDriver.prototype.____constructor(self) -- 105
	self.defaultMode = "kbm" -- 106
	self.kbm = __TS__New(KbmPoller) -- 107
end -- 105
function WindowsInputDriver.prototype.attach(self, parent, hooks) -- 109
	self.kbm:attach(parent, hooks) -- 110
end -- 109
function WindowsInputDriver.prototype.syncFrame(self, _ctx) -- 113
end -- 113
function WindowsInputDriver.prototype.renderOverlay(self) -- 117
end -- 117
function WindowsInputDriver.prototype.clearTransient(self, _keepTouchToggles) -- 121
end -- 121
function WindowsInputDriver.prototype.vibrate(self, _seconds) -- 125
end -- 125
function WindowsInputDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 129
	return false -- 130
end -- 129
function WindowsInputDriver.prototype.pollInto(self, input) -- 133
	input.inputMode = "kbm" -- 134
	local s = self.kbm:sample(input:getStageViewport()) -- 135
	if s.anyKb or s.mouseMoved or s.mouseClicked and s.mouseInsideStage then -- 135
		input.userInteracted = true -- 138
	end -- 138
	input.moveX = s.moveX -- 141
	input.moveY = s.moveY -- 142
	input:applyKeyHeld( -- 143
		s.jump, -- 144
		s.crouch, -- 145
		s.cover, -- 146
		s.interact, -- 147
		s.aim, -- 148
		s.mouseInsideStage and s.mouseLeft, -- 149
		s.flare, -- 150
		s.pause, -- 151
		s.retry, -- 152
		s.toggleView, -- 153
		s.tab -- 154
	) -- 154
	input:resetFrameSignals() -- 157
	if input.aim.held and s.mouseRightPressed then -- 157
		input.bottleCanceled = true -- 159
		input.aim.held = false -- 160
		input.aim.pressed = false -- 161
		input.aim.released = false -- 162
	end -- 162
	input.navUp = s.navUp -- 165
	input.navDown = s.navDown -- 166
	input.navLeft = s.navLeft -- 167
	input.navRight = s.navRight -- 168
	input.navConfirm = s.navConfirm -- 169
	input.navBack = false -- 170
	input.craftConfirm = s.uiConfirmWithE -- 171
	input.craftCancel = s.uiBackSpace -- 172
	local rCol = (s.navRight and 1 or 0) - (s.navLeft and 1 or 0) -- 174
	local rRow = (s.navUp and 1 or 0) - (s.navDown and 1 or 0) -- 175
	if rCol ~= 0 or rRow ~= 0 then -- 175
		input.reloadDirCol = rCol -- 177
		input.reloadDirRow = rRow -- 178
		input.reloadStepEdge = true -- 179
		input.reloadAutoStep = false -- 180
	end -- 180
	input.reloadConfirm = s.uiConfirmWithE -- 182
	input.reloadReset = s.uiBackSpace -- 183
	input:applyPickRoom(s.pick) -- 185
	input.frameInteractPressed = input.interact.pressed -- 186
	input.mdx = s.mouseStageX - input.mx -- 188
	input.mdy = s.mouseStageY - input.my -- 189
	input.mx = s.mouseStageX -- 190
	input.my = s.mouseStageY -- 191
	input.inside = s.mouseInsideStage -- 192
	input.uiX = s.mouseStageX -- 194
	input.uiY = s.mouseStageY -- 195
	input.uiDx = input.mdx -- 196
	input.uiDy = input.mdy -- 197
	input.uiInside = s.mouseInsideStage -- 198
	input.uiHeld = s.mouseLeft and s.mouseInsideStage -- 199
	input.uiPressed = s.mouseLeftPressed and s.mouseInsideStage -- 200
	input.uiReleased = s.mouseLeftReleased -- 201
	input.uiRightPressed = s.mouseRightPressed and s.mouseInsideStage -- 202
end -- 133
____exports.TARGET = { -- 206
	id = "windows", -- 207
	supportsKbm = true, -- 208
	supportsTouch = false, -- 209
	supportsGamepad = false, -- 210
	supportsPortrait = false, -- 211
	defaultInputMode = "kbm", -- 212
	supportedModes = {"kbm"}, -- 213
	modePrefOrder = {"kbm"}, -- 214
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}}, -- 215
	getPlatformCaps = function(self) -- 217
		local cfg = getReleaseConfig() -- 218
		return { -- 219
			kind = desktopKind(), -- 220
			target = "windows", -- 221
			isDesktop = true, -- 222
			isMobile = false, -- 223
			isWeb = false, -- 224
			isStandaloneAndroidApk = false, -- 225
			canToggleFullscreen = true, -- 226
			canQuit = true, -- 227
			hasBackButton = false, -- 228
			supportsHaptics = false, -- 229
			needsAudioUnlock = false, -- 230
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 231
			defaultInputMode = "kbm" -- 232
		} -- 232
	end, -- 217
	canToggleFullscreen = function(self) -- 236
		return true -- 237
	end, -- 236
	canQuitApp = function(self) -- 240
		return true -- 241
	end, -- 240
	isReleaseMode = function(self) -- 244
		local cfg = getReleaseConfig() -- 245
		return cfg ~= nil and cfg.isRelease == true -- 246
	end, -- 244
	computeStageViewport = function(self, fullW, fullH) -- 249
		return computeWindowsViewport(fullW, fullH) -- 250
	end, -- 249
	triggerHaptics = function(self, _seconds, _enabled) -- 253
	end, -- 253
	keyTagFor = function(self, action, _mode, _layout) -- 257
		return keyTagKbm(action) -- 258
	end, -- 257
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 261
		return rawKeyTag -- 262
	end, -- 261
	adaptHintSentence = function(self, text, _mode, _layout) -- 265
		return text -- 266
	end, -- 265
	controlsGuideRows = function(self, _tab) -- 269
		return WINDOWS_GUIDE -- 270
	end, -- 269
	splashSkipHint = function(self, _mode, _layout) -- 273
		return "ESC / SPACE  SKIP" -- 274
	end, -- 273
	titleFooterHint = function(self, _mode, _layout) -- 277
		return "上下择项   ·   回车或点选启程" -- 278
	end, -- 277
	chapterFooterHint = function(self, _mode, _confirmTag) -- 281
		return "方向键选择   ·   回车或点击进入" -- 282
	end, -- 281
	pauseFooterHint = function(self, _mode, _layout) -- 285
		return "Esc 续行   ·   Enter 或点击确认" -- 286
	end, -- 285
	settingsFooterHint = function(self, _mode, _layout) -- 289
		return "←/→ 或回车/点击切换   ·   Esc 返回   ·   设置自动保存" -- 290
	end, -- 289
	controlsFooterRightHint = function(self, _mode) -- 293
		return "F11 / Alt+Enter 全屏   ·   标题与暂歇菜单可调游戏设置" -- 294
	end, -- 293
	epilogueFooterHint = function(self, _mode, _layout) -- 297
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 298
	end, -- 297
	settingsRows = function(self) -- 301
		return WINDOWS_SETTINGS_ROWS -- 302
	end, -- 301
	settingsPauseLabel = function(self, _settings) -- 305
		return "游戏设置" -- 306
	end, -- 305
	settingsHeaderTitle = function(self) -- 309
		return "游戏设置" -- 310
	end, -- 309
	settingsHeaderSummary = function(self, _activeMode) -- 313
		return "键鼠模式 · 音量、显示与按键辅助自动保存" -- 314
	end, -- 313
	settingsValueText = function(self, rowId, settings, _activeMode) -- 317
		if rowId == "fullscreen" then -- 317
			return App.fullScreen and "全屏" or "窗口" -- 319
		end -- 319
		if rowId == "assistHints" then -- 319
			return settings.assistHints and "开" or "关" -- 322
		end -- 322
		return volumeSettingText(rowId, settings) -- 324
	end, -- 317
	applySettingsDelta = function(self, rowId, delta, settings, _input) -- 327
		if rowId == "back" then -- 327
			return "back" -- 333
		end -- 333
		if rowId == "fullscreen" then -- 333
			return "display" -- 334
		end -- 334
		if rowId == "assistHints" then -- 334
			settings.assistHints = not settings.assistHints -- 336
			saveControlSettings(settings) -- 337
			return "assist" -- 338
		end -- 338
		if applyVolumeSetting(rowId, delta, settings) then -- 338
			return "audio" -- 340
		end -- 340
		return "none" -- 341
	end, -- 327
	createDriver = function(self, _settings) -- 344
		return __TS__New(WindowsInputDriver) -- 345
	end -- 344
} -- 344
return ____exports -- 344