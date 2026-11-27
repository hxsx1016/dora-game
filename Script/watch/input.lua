-- [ts]: input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____controls_config = require("Script.watch.controls_config") -- 11
local loadControlSettings = ____controls_config.loadControlSettings -- 16
local nextPrefInList = ____controls_config.nextPrefInList -- 17
local saveControlSettings = ____controls_config.saveControlSettings -- 18
local ____target = require("Script.watch.target") -- 20
local getActiveTarget = ____target.getActiveTarget -- 20
local function emptyKey() -- 36
	return {held = false, pressed = false, released = false} -- 37
end -- 36
local function edge(state, held) -- 40
	local was = state.held -- 41
	state.held = held -- 42
	if held and not was then -- 43
		state.pressed = true -- 44
	end -- 44
	if not held and was then -- 46
		state.released = true -- 47
	end -- 47
	return state -- 49
end -- 40
____exports.Input = __TS__Class() -- 52
local Input = ____exports.Input -- 52
Input.name = "Input" -- 52
function Input.prototype.____constructor(self) -- 137
	self.moveX = 0 -- 53
	self.moveY = 0 -- 54
	self.jump = emptyKey() -- 56
	self.crouch = emptyKey() -- 57
	self.cover = emptyKey() -- 58
	self.interact = emptyKey() -- 59
	self.aim = emptyKey() -- 60
	self.fire = emptyKey() -- 61
	self.flare = emptyKey() -- 62
	self.pause = emptyKey() -- 63
	self.retry = emptyKey() -- 64
	self.toggleView = emptyKey() -- 65
	self.tab = emptyKey() -- 66
	self.pickRoom = 0 -- 68
	self.mx = 0 -- 71
	self.my = 0 -- 72
	self.inside = true -- 73
	self.mdx = 0 -- 74
	self.mdy = 0 -- 75
	self.uiX = 0 -- 78
	self.uiY = 0 -- 79
	self.uiDx = 0 -- 80
	self.uiDy = 0 -- 81
	self.uiInside = false -- 82
	self.uiHeld = false -- 83
	self.uiPressed = false -- 84
	self.uiReleased = false -- 85
	self.uiRightPressed = false -- 86
	self.settings = loadControlSettings() -- 88
	self.gamepadLayout = "xbox" -- 93
	self.userInteracted = false -- 94
	self.frameInteractPressed = false -- 96
	self.suppressPickRoomOnce = false -- 97
	self.artifactTogglePressed = false -- 99
	self.bottleCanceled = false -- 100
	self.touchZoneTap = "" -- 101
	self.muteTogglePressed = false -- 102
	self.fullscreenTogglePressed = false -- 103
	self.splashSkipPressed = false -- 104
	self.navUp = false -- 106
	self.navDown = false -- 107
	self.navLeft = false -- 108
	self.navRight = false -- 109
	self.navConfirm = false -- 110
	self.navBack = false -- 111
	self.navPrevTab = false -- 112
	self.navNextTab = false -- 113
	self.reloadDirCol = 0 -- 116
	self.reloadDirRow = 0 -- 117
	self.reloadStepEdge = false -- 118
	self.reloadAutoStep = false -- 119
	self.reloadConfirm = false -- 120
	self.reloadReset = false -- 121
	self.craftConfirm = false -- 124
	self.craftCancel = false -- 125
	self.talentDelta = 0 -- 128
	self.talentConfirm = false -- 129
	self.retryHoldProgress = 0 -- 132
	self.lastPick = 0 -- 135
	self.target = getActiveTarget() -- 138
	self.driver = self.target:createDriver(self.settings) -- 139
	self.stageVp = self.target:computeStageViewport(1280, 720) -- 140
	self.gamepadLayout = self.settings.gamepadLayout -- 141
	self.inputMode = self.driver.defaultMode -- 142
	if self.settings.modePref ~= "auto" and __TS__ArrayIndexOf(self.target.supportedModes, self.settings.modePref) >= 0 then -- 143
		self.inputMode = self.settings.modePref -- 144
	end -- 144
end -- 137
function Input.prototype.attach(self, parent, hooks) -- 148
	self.driver:attach(parent, hooks) -- 149
end -- 148
function Input.prototype.syncFrame(self, ctx) -- 152
	self.driver:syncFrame(ctx) -- 153
end -- 152
function Input.prototype.renderOverlay(self) -- 156
	self.driver:renderOverlay() -- 157
end -- 156
function Input.prototype.getTouchRouter(self) -- 160
	local ____temp_0 -- 161
	if self.driver.getTouchRouter ~= nil then -- 161
		____temp_0 = self.driver:getTouchRouter() -- 161
	else -- 161
		____temp_0 = nil -- 161
	end -- 161
	return ____temp_0 -- 161
end -- 160
function Input.prototype.getGamepadRouter(self) -- 164
	local ____temp_1 -- 165
	if self.driver.getGamepadRouter ~= nil then -- 165
		____temp_1 = self.driver:getGamepadRouter() -- 165
	else -- 165
		____temp_1 = nil -- 165
	end -- 165
	return ____temp_1 -- 165
end -- 164
function Input.prototype.getTouchControls(self) -- 168
	local ____temp_2 -- 169
	if self.driver.getTouchControls ~= nil then -- 169
		____temp_2 = self.driver:getTouchControls() -- 169
	else -- 169
		____temp_2 = nil -- 169
	end -- 169
	return ____temp_2 -- 169
end -- 168
function Input.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 172
	if self.driver.injectTouch ~= nil then -- 173
		self.driver:injectTouch( -- 174
			phase, -- 174
			id, -- 174
			x, -- 174
			y, -- 174
			fromMouse -- 174
		) -- 174
	end -- 174
end -- 172
function Input.prototype.setGamepadSim(self, state) -- 178
	if self.driver.setGamepadSim ~= nil then -- 179
		self.driver:setGamepadSim(state) -- 180
	end -- 180
end -- 178
function Input.prototype.setStageViewport(self, vp) -- 184
	self.stageVp = vp -- 185
end -- 184
function Input.prototype.getStageViewport(self) -- 188
	return self.stageVp -- 189
end -- 188
function Input.prototype.isTouchMode(self) -- 192
	return self.inputMode == "touch" -- 193
end -- 192
function Input.prototype.isGamepadMode(self) -- 196
	return self.inputMode == "gamepad" -- 197
end -- 196
function Input.prototype.isKbmMode(self) -- 200
	return self.inputMode == "kbm" -- 201
end -- 200
function Input.prototype.setInputMode(self, mode) -- 204
	if __TS__ArrayIndexOf(self.target.supportedModes, mode) < 0 then -- 205
		return -- 206
	end -- 206
	if self.inputMode == mode then -- 208
		return -- 208
	end -- 208
	self.inputMode = mode -- 209
	if self.driver.onInputModeChanged ~= nil then -- 210
		self.driver:onInputModeChanged(mode) -- 211
	end -- 211
end -- 204
function Input.prototype.setModePref(self, pref) -- 215
	if __TS__ArrayIndexOf(self.target.modePrefOrder, pref) < 0 then -- 216
		return -- 217
	end -- 217
	self.settings.modePref = pref -- 219
	if pref ~= "auto" then -- 220
		self:setInputMode(pref) -- 221
	end -- 221
	saveControlSettings(self.settings) -- 223
end -- 215
function Input.prototype.cycleModePref(self, delta) -- 226
	if delta == nil then -- 226
		delta = 1 -- 226
	end -- 226
	local order = self.target.modePrefOrder -- 227
	if #order <= 1 then -- 228
		return order[1] or self.inputMode -- 229
	end -- 229
	local next = nextPrefInList(self.settings.modePref, order, delta) -- 231
	self:setModePref(next) -- 232
	return next -- 233
end -- 226
function Input.prototype.shouldShowTouchControls(self) -- 236
	return self.driver:shouldShowTouchControls(self, self.stageVp) -- 237
end -- 236
function Input.prototype.markKeyboardActivity(self) -- 240
	if not self.target.supportsKbm then -- 241
		return -- 242
	end -- 242
	self.userInteracted = true -- 244
	if self.settings.modePref == "auto" then -- 245
		self:setInputMode("kbm") -- 246
	end -- 246
end -- 240
function Input.prototype.vibrate(self, seconds) -- 250
	self.driver:vibrate(seconds) -- 251
end -- 250
function Input.prototype.clearTransient(self, keepTouchToggles) -- 254
	if keepTouchToggles == nil then -- 254
		keepTouchToggles = false -- 254
	end -- 254
	self.driver:clearTransient(keepTouchToggles) -- 255
end -- 254
function Input.prototype.update(self) -- 258
	self.driver:pollInto(self) -- 259
end -- 258
function Input.prototype.applyKeyHeld(self, jump, crouch, cover, interact, aim, fire, flare, pause, retry, toggleView, tab) -- 263
	self.jump = edge(self.jump, jump) -- 276
	self.crouch = edge(self.crouch, crouch) -- 277
	self.cover = edge(self.cover, cover) -- 278
	self.interact = edge(self.interact, interact) -- 279
	self.aim = edge(self.aim, aim) -- 280
	self.fire = edge(self.fire, fire) -- 281
	self.flare = edge(self.flare, flare) -- 282
	self.pause = edge(self.pause, pause) -- 283
	self.retry = edge(self.retry, retry) -- 284
	self.toggleView = edge(self.toggleView, toggleView) -- 285
	self.tab = edge(self.tab, tab) -- 286
end -- 263
function Input.prototype.resetFrameSignals(self) -- 290
	self.artifactTogglePressed = false -- 291
	self.bottleCanceled = false -- 292
	self.touchZoneTap = "" -- 293
	self.muteTogglePressed = false -- 294
	self.fullscreenTogglePressed = false -- 295
	self.splashSkipPressed = false -- 296
	self.navUp = false -- 298
	self.navDown = false -- 299
	self.navLeft = false -- 300
	self.navRight = false -- 301
	self.navConfirm = false -- 302
	self.navBack = false -- 303
	self.navPrevTab = false -- 304
	self.navNextTab = false -- 305
	self.reloadDirCol = 0 -- 307
	self.reloadDirRow = 0 -- 308
	self.reloadStepEdge = false -- 309
	self.reloadAutoStep = false -- 310
	self.reloadConfirm = false -- 311
	self.reloadReset = false -- 312
	self.craftConfirm = false -- 314
	self.craftCancel = false -- 315
	self.talentDelta = 0 -- 317
	self.talentConfirm = false -- 318
	self.retryHoldProgress = 0 -- 319
end -- 290
function Input.prototype.applyPickRoom(self, pick) -- 322
	if self.suppressPickRoomOnce then -- 323
		self.suppressPickRoomOnce = false -- 324
		self.pickRoom = 0 -- 325
	elseif pick ~= 0 and pick ~= self.lastPick then -- 326
		self.pickRoom = pick -- 327
	end -- 327
	self.lastPick = pick -- 329
end -- 322
function Input.prototype.consumePickRoom(self) -- 332
	self.pickRoom = 0 -- 333
	self.suppressPickRoomOnce = true -- 334
end -- 332
function Input.prototype.requestPickRoom(self, slot) -- 337
	if slot >= 1 and slot <= 3 then -- 338
		self.pickRoom = slot -- 339
	end -- 339
end -- 337
function Input.prototype.beginStep(self, first) -- 343
	if not first then -- 344
		self:clearEdges() -- 345
	end -- 345
end -- 343
function Input.prototype.endStep(self) -- 349
	self:clearEdges() -- 350
end -- 349
function Input.prototype.consumeEdges(self) -- 353
	self:clearEdges() -- 354
end -- 353
function Input.prototype.clearEdges(self) -- 357
	self.jump.pressed = false -- 358
	self.jump.released = false -- 359
	self.crouch.pressed = false -- 360
	self.crouch.released = false -- 361
	self.cover.pressed = false -- 362
	self.cover.released = false -- 363
	self.interact.pressed = false -- 364
	self.interact.released = false -- 365
	self.aim.pressed = false -- 366
	self.aim.released = false -- 367
	self.fire.pressed = false -- 368
	self.fire.released = false -- 369
	self.flare.pressed = false -- 370
	self.flare.released = false -- 371
	self.pause.pressed = false -- 372
	self.pause.released = false -- 373
	self.retry.pressed = false -- 374
	self.retry.released = false -- 375
	self.toggleView.pressed = false -- 376
	self.toggleView.released = false -- 377
	self.tab.pressed = false -- 378
	self.tab.released = false -- 379
end -- 357
return ____exports -- 357
