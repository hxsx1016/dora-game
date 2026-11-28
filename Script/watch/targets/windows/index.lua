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
local volumeSettingText = ____controls_config.volumeSettingText -- 12
local ____target_types = require("Script.watch.target_types") -- 14
local ZERO_SAFE_INSETS = ____target_types.ZERO_SAFE_INSETS -- 28
local getReleaseConfig = ____target_types.getReleaseConfig -- 29
local WINDOWS_SETTINGS_ROWS = { -- 32
	{id = "masterVol", title = "主音量"}, -- 33
	{id = "bgmVol", title = "音乐音量"}, -- 34
	{id = "sfxVol", title = "音效与环境"}, -- 35
	{id = "voiceVol", title = "人声音量"}, -- 36
	{id = "back", title = "返回暂歇菜单"} -- 37
} -- 37
local WINDOWS_GUIDE = {subtitle = "键鼠操作说明 · Windows 桌面", soldierRows = { -- 40
	{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 43
	{"鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"}, -- 44
	{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 45
	{"E / 1·2·3", "交互推车工台 · 数字键选护送本领"}, -- 46
	{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 47
	{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 48
}, childRows = { -- 48
	{"WASD / 方向键", "前后左右纵深潜行"}, -- 51
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 52
	{"按住 C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 53
	{"SPACE", "跳跃攀上石阶与矮台"}, -- 54
	{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 55
	{"F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 56
}} -- 56
local function desktopKind() -- 60
	local plat = App.platform -- 61
	if plat == "macOS" then -- 61
		return "macos" -- 62
	end -- 62
	if plat == "Linux" then -- 62
		return "linux" -- 63
	end -- 63
	return "windows" -- 64
end -- 60
local function keyTagKbm(action) -- 67
	if action == "interact" then -- 67
		return "E" -- 68
	end -- 68
	if action == "jump" then -- 68
		return "SPACE" -- 69
	end -- 69
	if action == "crouch" then -- 69
		return "CTRL" -- 70
	end -- 70
	if action == "cover" then -- 70
		return "SHIFT" -- 71
	end -- 71
	if action == "fire" then -- 71
		return "左键" -- 72
	end -- 72
	if action == "aim" then -- 72
		return "F" -- 73
	end -- 73
	if action == "pause" then -- 73
		return "ESC" -- 74
	end -- 74
	if action == "retry" then -- 74
		return "R" -- 75
	end -- 75
	if action == "confirm" then -- 75
		return "ENTER" -- 76
	end -- 76
	if action == "back" then -- 76
		return "ESC" -- 77
	end -- 77
	return "T" -- 78
end -- 67
local function computeWindowsViewport(fullW, fullH) -- 81
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 82
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 83
	local uiScale = math.max( -- 84
		0.25, -- 84
		math.min(w / 1280, h / 720) -- 84
	) -- 84
	return { -- 85
		fullW = w, -- 86
		fullH = h, -- 87
		stageX = 0, -- 88
		stageY = 0, -- 89
		stageW = w, -- 90
		stageH = h, -- 91
		deckH = 0, -- 92
		topBarH = 0, -- 93
		isPortrait = false, -- 94
		uiScale = uiScale, -- 95
		uiW = w / uiScale, -- 96
		uiH = h / uiScale, -- 97
		safe = ZERO_SAFE_INSETS, -- 98
		safeUi = ZERO_SAFE_INSETS -- 99
	} -- 99
end -- 81
local WindowsInputDriver = __TS__Class() -- 103
WindowsInputDriver.name = "WindowsInputDriver" -- 103
function WindowsInputDriver.prototype.____constructor(self) -- 103
	self.defaultMode = "kbm" -- 104
	self.kbm = __TS__New(KbmPoller) -- 105
end -- 103
function WindowsInputDriver.prototype.attach(self, parent, hooks) -- 107
	self.kbm:attach(parent, hooks) -- 108
end -- 107
function WindowsInputDriver.prototype.syncFrame(self, _ctx) -- 111
end -- 111
function WindowsInputDriver.prototype.renderOverlay(self) -- 115
end -- 115
function WindowsInputDriver.prototype.clearTransient(self, _keepTouchToggles) -- 119
end -- 119
function WindowsInputDriver.prototype.vibrate(self, _seconds) -- 123
end -- 123
function WindowsInputDriver.prototype.shouldShowTouchControls(self, _input, _vp) -- 127
	return false -- 128
end -- 127
function WindowsInputDriver.prototype.pollInto(self, input) -- 131
	input.inputMode = "kbm" -- 132
	local s = self.kbm:sample(input:getStageViewport()) -- 133
	if s.anyKb or s.mouseMoved or s.mouseClicked and s.mouseInsideStage then -- 133
		input.userInteracted = true -- 136
	end -- 136
	input.moveX = s.moveX -- 139
	input.moveY = s.moveY -- 140
	input:applyKeyHeld( -- 141
		s.jump, -- 142
		s.crouch, -- 143
		s.cover, -- 144
		s.interact, -- 145
		s.aim, -- 146
		s.mouseInsideStage and s.mouseLeft, -- 147
		s.flare, -- 148
		s.pause, -- 149
		s.retry, -- 150
		s.toggleView, -- 151
		s.tab -- 152
	) -- 152
	input:resetFrameSignals() -- 155
	if input.aim.held and s.mouseRightPressed then -- 155
		input.bottleCanceled = true -- 157
		input.aim.held = false -- 158
		input.aim.pressed = false -- 159
		input.aim.released = false -- 160
	end -- 160
	input.navUp = s.navUp -- 163
	input.navDown = s.navDown -- 164
	input.navLeft = s.navLeft -- 165
	input.navRight = s.navRight -- 166
	input.navConfirm = s.navConfirm -- 167
	input.navBack = false -- 168
	input.craftConfirm = s.uiConfirmWithE -- 169
	input.craftCancel = s.uiBackSpace -- 170
	local rCol = (s.navRight and 1 or 0) - (s.navLeft and 1 or 0) -- 172
	local rRow = (s.navUp and 1 or 0) - (s.navDown and 1 or 0) -- 173
	if rCol ~= 0 or rRow ~= 0 then -- 173
		input.reloadDirCol = rCol -- 175
		input.reloadDirRow = rRow -- 176
		input.reloadStepEdge = true -- 177
		input.reloadAutoStep = false -- 178
	end -- 178
	input.reloadConfirm = s.uiConfirmWithE -- 180
	input.reloadReset = s.uiBackSpace -- 181
	input:applyPickRoom(s.pick) -- 183
	input.frameInteractPressed = input.interact.pressed -- 184
	input.mdx = s.mouseStageX - input.mx -- 186
	input.mdy = s.mouseStageY - input.my -- 187
	input.mx = s.mouseStageX -- 188
	input.my = s.mouseStageY -- 189
	input.inside = s.mouseInsideStage -- 190
	input.uiX = s.mouseStageX -- 192
	input.uiY = s.mouseStageY -- 193
	input.uiDx = input.mdx -- 194
	input.uiDy = input.mdy -- 195
	input.uiInside = s.mouseInsideStage -- 196
	input.uiHeld = s.mouseLeft and s.mouseInsideStage -- 197
	input.uiPressed = s.mouseLeftPressed and s.mouseInsideStage -- 198
	input.uiReleased = s.mouseLeftReleased -- 199
	input.uiRightPressed = s.mouseRightPressed and s.mouseInsideStage -- 200
end -- 131
____exports.TARGET = { -- 204
	id = "windows", -- 205
	supportsKbm = true, -- 206
	supportsTouch = false, -- 207
	supportsGamepad = false, -- 208
	supportsPortrait = false, -- 209
	defaultInputMode = "kbm", -- 210
	supportedModes = {"kbm"}, -- 211
	modePrefOrder = {"kbm"}, -- 212
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}}, -- 213
	getPlatformCaps = function(self) -- 215
		local cfg = getReleaseConfig() -- 216
		return { -- 217
			kind = desktopKind(), -- 218
			target = "windows", -- 219
			isDesktop = true, -- 220
			isMobile = false, -- 221
			isWeb = false, -- 222
			isStandaloneAndroidApk = false, -- 223
			canToggleFullscreen = true, -- 224
			canQuit = true, -- 225
			hasBackButton = false, -- 226
			supportsHaptics = false, -- 227
			needsAudioUnlock = false, -- 228
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 229
			defaultInputMode = "kbm" -- 230
		} -- 230
	end, -- 215
	canToggleFullscreen = function(self) -- 234
		return true -- 235
	end, -- 234
	canQuitApp = function(self) -- 238
		return true -- 239
	end, -- 238
	isReleaseMode = function(self) -- 242
		local cfg = getReleaseConfig() -- 243
		return cfg ~= nil and cfg.isRelease == true -- 244
	end, -- 242
	computeStageViewport = function(self, fullW, fullH) -- 247
		return computeWindowsViewport(fullW, fullH) -- 248
	end, -- 247
	triggerHaptics = function(self, _seconds, _enabled) -- 251
	end, -- 251
	keyTagFor = function(self, action, _mode, _layout) -- 255
		return keyTagKbm(action) -- 256
	end, -- 255
	adaptWorldKeyTag = function(self, rawKeyTag, _mode, _layout) -- 259
		return rawKeyTag -- 260
	end, -- 259
	adaptHintSentence = function(self, text, _mode, _layout) -- 263
		return text -- 264
	end, -- 263
	controlsGuideRows = function(self, _tab) -- 267
		return WINDOWS_GUIDE -- 268
	end, -- 267
	splashSkipHint = function(self, _mode, _layout) -- 271
		return "ESC / SPACE  SKIP" -- 272
	end, -- 271
	titleFooterHint = function(self, _mode, _layout) -- 275
		return "上下择项   ·   回车或点选启程" -- 276
	end, -- 275
	chapterFooterHint = function(self, _mode, _confirmTag) -- 279
		return "方向键选择   ·   回车或点击进入" -- 280
	end, -- 279
	pauseFooterHint = function(self, _mode, _layout) -- 283
		return "Esc 续行   ·   Enter 或点击确认" -- 284
	end, -- 283
	settingsFooterHint = function(self, _mode, _layout) -- 287
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 288
	end, -- 287
	controlsFooterRightHint = function(self, _mode) -- 291
		return "F11 / Alt+Enter 全屏   ·   暂歇菜单可调声音设置" -- 292
	end, -- 291
	epilogueFooterHint = function(self, _mode, _layout) -- 295
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 296
	end, -- 295
	settingsRows = function(self) -- 299
		return WINDOWS_SETTINGS_ROWS -- 300
	end, -- 299
	settingsPauseLabel = function(self, _settings) -- 303
		return "声音设置" -- 304
	end, -- 303
	settingsHeaderTitle = function(self) -- 307
		return "声音设置" -- 308
	end, -- 307
	settingsHeaderSummary = function(self, _activeMode) -- 311
		return "当前模式：键鼠 · 四通道音量实时生效" -- 312
	end, -- 311
	settingsValueText = function(self, rowId, settings, _activeMode) -- 315
		return volumeSettingText(rowId, settings) -- 316
	end, -- 315
	applySettingsDelta = function(self, rowId, delta, settings, _input) -- 319
		if rowId == "back" then -- 319
			return "back" -- 320
		end -- 320
		if applyVolumeSetting(rowId, delta, settings) then -- 320
			return "audio" -- 321
		end -- 321
		return "none" -- 322
	end, -- 319
	createDriver = function(self, _settings) -- 325
		return __TS__New(WindowsInputDriver) -- 326
	end -- 325
} -- 325
return ____exports -- 325