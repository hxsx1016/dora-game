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
	if held and not was then -- 42
		state.pressed = true -- 44
	end -- 44
	if not held and was then -- 44
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
	if self.settings.modePref ~= "auto" and __TS__ArrayIndexOf(self.target.supportedModes, self.settings.modePref) < 0 then -- 138
		self.settings.modePref = "auto" -- 140
	end -- 140
	self.driver = self.target:createDriver(self.settings) -- 142
	self.stageVp = self.target:computeStageViewport(1280, 720) -- 143
	self.gamepadLayout = self.settings.gamepadLayout -- 144
	self.inputMode = self.driver.defaultMode -- 145
	if self.settings.modePref ~= "auto" then -- 145
		self.inputMode = self.settings.modePref -- 147
	end -- 147
end -- 137
function Input.prototype.attach(self, parent, hooks) -- 151
	self.driver:attach(parent, hooks) -- 152
end -- 151
function Input.prototype.syncFrame(self, ctx) -- 155
	self.driver:syncFrame(ctx) -- 156
end -- 155
function Input.prototype.renderOverlay(self) -- 159
	self.driver:renderOverlay() -- 160
end -- 159
function Input.prototype.getTouchRouter(self) -- 163
	local ____temp_0 -- 164
	if self.driver.getTouchRouter ~= nil then -- 164
		____temp_0 = self.driver:getTouchRouter() -- 164
	else -- 164
		____temp_0 = nil -- 164
	end -- 164
	return ____temp_0 -- 164
end -- 163
function Input.prototype.getGamepadRouter(self) -- 167
	local ____temp_1 -- 168
	if self.driver.getGamepadRouter ~= nil then -- 168
		____temp_1 = self.driver:getGamepadRouter() -- 168
	else -- 168
		____temp_1 = nil -- 168
	end -- 168
	return ____temp_1 -- 168
end -- 167
function Input.prototype.getTouchControls(self) -- 171
	local ____temp_2 -- 172
	if self.driver.getTouchControls ~= nil then -- 172
		____temp_2 = self.driver:getTouchControls() -- 172
	else -- 172
		____temp_2 = nil -- 172
	end -- 172
	return ____temp_2 -- 172
end -- 171
function Input.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 175
	if self.driver.injectTouch ~= nil then -- 175
		self.driver:injectTouch( -- 177
			phase, -- 177
			id, -- 177
			x, -- 177
			y, -- 177
			fromMouse -- 177
		) -- 177
	end -- 177
end -- 175
function Input.prototype.setGamepadSim(self, state) -- 181
	if self.driver.setGamepadSim ~= nil then -- 181
		self.driver:setGamepadSim(state) -- 183
	end -- 183
end -- 181
function Input.prototype.setStageViewport(self, vp) -- 187
	self.stageVp = vp -- 188
end -- 187
function Input.prototype.getStageViewport(self) -- 191
	return self.stageVp -- 192
end -- 191
function Input.prototype.isTouchMode(self) -- 195
	return self.inputMode == "touch" -- 196
end -- 195
function Input.prototype.isGamepadMode(self) -- 199
	return self.inputMode == "gamepad" -- 200
end -- 199
function Input.prototype.isKbmMode(self) -- 203
	return self.inputMode == "kbm" -- 204
end -- 203
function Input.prototype.setInputMode(self, mode) -- 207
	if __TS__ArrayIndexOf(self.target.supportedModes, mode) < 0 then -- 207
		return -- 209
	end -- 209
	if self.inputMode == mode then -- 209
		return -- 211
	end -- 211
	self.inputMode = mode -- 212
	if self.driver.onInputModeChanged ~= nil then -- 212
		self.driver:onInputModeChanged(mode) -- 214
	end -- 214
end -- 207
function Input.prototype.setModePref(self, pref) -- 218
	if __TS__ArrayIndexOf(self.target.modePrefOrder, pref) < 0 then -- 218
		return -- 220
	end -- 220
	self.settings.modePref = pref -- 222
	if pref ~= "auto" then -- 222
		self:setInputMode(pref) -- 224
	end -- 224
	saveControlSettings(self.settings) -- 226
end -- 218
function Input.prototype.cycleModePref(self, delta) -- 229
	if delta == nil then -- 229
		delta = 1 -- 229
	end -- 229
	local order = self.target.modePrefOrder -- 230
	if #order <= 1 then -- 230
		return order[1] or self.inputMode -- 232
	end -- 232
	local next = nextPrefInList(self.settings.modePref, order, delta) -- 234
	self:setModePref(next) -- 235
	return next -- 236
end -- 229
function Input.prototype.shouldShowTouchControls(self) -- 239
	return self.driver:shouldShowTouchControls(self, self.stageVp) -- 240
end -- 239
function Input.prototype.markKeyboardActivity(self) -- 243
	if not self.target.supportsKbm then -- 243
		return -- 245
	end -- 245
	self.userInteracted = true -- 247
	if self.settings.modePref == "auto" then -- 247
		self:setInputMode("kbm") -- 249
	end -- 249
end -- 243
function Input.prototype.vibrate(self, seconds) -- 253
	self.driver:vibrate(seconds) -- 254
end -- 253
function Input.prototype.clearTransient(self, keepTouchToggles) -- 257
	if keepTouchToggles == nil then -- 257
		keepTouchToggles = false -- 257
	end -- 257
	self.driver:clearTransient(keepTouchToggles) -- 258
end -- 257
function Input.prototype.update(self) -- 261
	self.driver:pollInto(self) -- 262
end -- 261
function Input.prototype.applyKeyHeld(self, jump, crouch, cover, interact, aim, fire, flare, pause, retry, toggleView, tab) -- 266
	self.jump = edge(self.jump, jump) -- 279
	self.crouch = edge(self.crouch, crouch) -- 280
	self.cover = edge(self.cover, cover) -- 281
	self.interact = edge(self.interact, interact) -- 282
	self.aim = edge(self.aim, aim) -- 283
	self.fire = edge(self.fire, fire) -- 284
	self.flare = edge(self.flare, flare) -- 285
	self.pause = edge(self.pause, pause) -- 286
	self.retry = edge(self.retry, retry) -- 287
	self.toggleView = edge(self.toggleView, toggleView) -- 288
	self.tab = edge(self.tab, tab) -- 289
end -- 266
function Input.prototype.resetFrameSignals(self) -- 293
	self.artifactTogglePressed = false -- 294
	self.bottleCanceled = false -- 295
	self.touchZoneTap = "" -- 296
	self.muteTogglePressed = false -- 297
	self.fullscreenTogglePressed = false -- 298
	self.splashSkipPressed = false -- 299
	self.navUp = false -- 301
	self.navDown = false -- 302
	self.navLeft = false -- 303
	self.navRight = false -- 304
	self.navConfirm = false -- 305
	self.navBack = false -- 306
	self.navPrevTab = false -- 307
	self.navNextTab = false -- 308
	self.reloadDirCol = 0 -- 310
	self.reloadDirRow = 0 -- 311
	self.reloadStepEdge = false -- 312
	self.reloadAutoStep = false -- 313
	self.reloadConfirm = false -- 314
	self.reloadReset = false -- 315
	self.craftConfirm = false -- 317
	self.craftCancel = false -- 318
	self.talentDelta = 0 -- 320
	self.talentConfirm = false -- 321
	self.retryHoldProgress = 0 -- 322
end -- 293
function Input.prototype.applyPickRoom(self, pick) -- 325
	if self.suppressPickRoomOnce then -- 325
		self.suppressPickRoomOnce = false -- 327
		self.pickRoom = 0 -- 328
	elseif pick ~= 0 and pick ~= self.lastPick then -- 328
		self.pickRoom = pick -- 330
	end -- 330
	self.lastPick = pick -- 332
end -- 325
function Input.prototype.consumePickRoom(self) -- 335
	self.pickRoom = 0 -- 336
	self.suppressPickRoomOnce = true -- 337
end -- 335
function Input.prototype.requestPickRoom(self, slot) -- 340
	if slot >= 1 and slot <= 3 then -- 340
		self.pickRoom = slot -- 342
	end -- 342
end -- 340
function Input.prototype.beginStep(self, first) -- 346
	if not first then -- 346
		self:clearEdges() -- 348
	end -- 348
end -- 346
function Input.prototype.endStep(self) -- 352
	self:clearEdges() -- 353
end -- 352
function Input.prototype.consumeEdges(self) -- 356
	self:clearEdges() -- 357
end -- 356
function Input.prototype.clearEdges(self) -- 360
	self.jump.pressed = false -- 361
	self.jump.released = false -- 362
	self.crouch.pressed = false -- 363
	self.crouch.released = false -- 364
	self.cover.pressed = false -- 365
	self.cover.released = false -- 366
	self.interact.pressed = false -- 367
	self.interact.released = false -- 368
	self.aim.pressed = false -- 369
	self.aim.released = false -- 370
	self.fire.pressed = false -- 371
	self.fire.released = false -- 372
	self.flare.pressed = false -- 373
	self.flare.released = false -- 374
	self.pause.pressed = false -- 375
	self.pause.released = false -- 376
	self.retry.pressed = false -- 377
	self.retry.released = false -- 378
	self.toggleView.pressed = false -- 379
	self.toggleView.released = false -- 380
	self.tab.pressed = false -- 381
	self.tab.released = false -- 382
end -- 360
return ____exports -- 360