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
function Input.prototype.____constructor(self) -- 140
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
	self.uiWheelY = 0 -- 87
	self.settings = loadControlSettings() -- 89
	self.gamepadLayout = "xbox" -- 94
	self.userInteracted = false -- 95
	self.frameInteractPressed = false -- 97
	self.suppressPickRoomOnce = false -- 98
	self.artifactTogglePressed = false -- 100
	self.bottleCanceled = false -- 101
	self.touchZoneTap = "" -- 102
	self.muteTogglePressed = false -- 103
	self.fullscreenTogglePressed = false -- 104
	self.splashSkipPressed = false -- 105
	self.ledgerTogglePressed = false -- 106
	self.retryTapPressed = false -- 107
	self.navUp = false -- 109
	self.navDown = false -- 110
	self.navLeft = false -- 111
	self.navRight = false -- 112
	self.navConfirm = false -- 113
	self.navBack = false -- 114
	self.navPrevTab = false -- 115
	self.navNextTab = false -- 116
	self.reloadDirCol = 0 -- 119
	self.reloadDirRow = 0 -- 120
	self.reloadStepEdge = false -- 121
	self.reloadAutoStep = false -- 122
	self.reloadConfirm = false -- 123
	self.reloadReset = false -- 124
	self.craftConfirm = false -- 127
	self.craftCancel = false -- 128
	self.talentDelta = 0 -- 131
	self.talentConfirm = false -- 132
	self.retryHoldProgress = 0 -- 135
	self.lastPick = 0 -- 138
	self.target = getActiveTarget() -- 141
	if self.settings.modePref ~= "auto" and __TS__ArrayIndexOf(self.target.supportedModes, self.settings.modePref) < 0 then -- 141
		self.settings.modePref = "auto" -- 143
	end -- 143
	self.driver = self.target:createDriver(self.settings) -- 145
	self.stageVp = self.target:computeStageViewport(1280, 720) -- 146
	self.gamepadLayout = self.settings.gamepadLayout -- 147
	self.inputMode = self.driver.defaultMode -- 148
	if self.settings.modePref ~= "auto" then -- 148
		self.inputMode = self.settings.modePref -- 150
	end -- 150
end -- 140
function Input.prototype.attach(self, parent, hooks) -- 154
	self.driver:attach(parent, hooks) -- 155
end -- 154
function Input.prototype.syncFrame(self, ctx) -- 158
	self.driver:syncFrame(ctx) -- 159
end -- 158
function Input.prototype.renderOverlay(self) -- 162
	self.driver:renderOverlay() -- 163
end -- 162
function Input.prototype.getTouchRouter(self) -- 166
	local ____temp_0 -- 167
	if self.driver.getTouchRouter ~= nil then -- 167
		____temp_0 = self.driver:getTouchRouter() -- 167
	else -- 167
		____temp_0 = nil -- 167
	end -- 167
	return ____temp_0 -- 167
end -- 166
function Input.prototype.getGamepadRouter(self) -- 170
	local ____temp_1 -- 171
	if self.driver.getGamepadRouter ~= nil then -- 171
		____temp_1 = self.driver:getGamepadRouter() -- 171
	else -- 171
		____temp_1 = nil -- 171
	end -- 171
	return ____temp_1 -- 171
end -- 170
function Input.prototype.getTouchControls(self) -- 174
	local ____temp_2 -- 175
	if self.driver.getTouchControls ~= nil then -- 175
		____temp_2 = self.driver:getTouchControls() -- 175
	else -- 175
		____temp_2 = nil -- 175
	end -- 175
	return ____temp_2 -- 175
end -- 174
function Input.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 178
	if self.driver.injectTouch ~= nil then -- 178
		self.driver:injectTouch( -- 180
			phase, -- 180
			id, -- 180
			x, -- 180
			y, -- 180
			fromMouse -- 180
		) -- 180
	end -- 180
end -- 178
function Input.prototype.setGamepadSim(self, state) -- 184
	if self.driver.setGamepadSim ~= nil then -- 184
		self.driver:setGamepadSim(state) -- 186
	end -- 186
end -- 184
function Input.prototype.setStageViewport(self, vp) -- 190
	self.stageVp = vp -- 191
end -- 190
function Input.prototype.getStageViewport(self) -- 194
	return self.stageVp -- 195
end -- 194
function Input.prototype.isTouchMode(self) -- 198
	return self.inputMode == "touch" -- 199
end -- 198
function Input.prototype.isGamepadMode(self) -- 202
	return self.inputMode == "gamepad" -- 203
end -- 202
function Input.prototype.isKbmMode(self) -- 206
	return self.inputMode == "kbm" -- 207
end -- 206
function Input.prototype.setInputMode(self, mode) -- 210
	if __TS__ArrayIndexOf(self.target.supportedModes, mode) < 0 then -- 210
		return -- 212
	end -- 212
	if self.inputMode == mode then -- 212
		return -- 214
	end -- 214
	self.inputMode = mode -- 215
	if self.driver.onInputModeChanged ~= nil then -- 215
		self.driver:onInputModeChanged(mode) -- 217
	end -- 217
end -- 210
function Input.prototype.setModePref(self, pref) -- 221
	if __TS__ArrayIndexOf(self.target.modePrefOrder, pref) < 0 then -- 221
		return -- 223
	end -- 223
	self.settings.modePref = pref -- 225
	if pref ~= "auto" then -- 225
		self:setInputMode(pref) -- 227
	end -- 227
	saveControlSettings(self.settings) -- 229
end -- 221
function Input.prototype.cycleModePref(self, delta) -- 232
	if delta == nil then -- 232
		delta = 1 -- 232
	end -- 232
	local order = self.target.modePrefOrder -- 233
	if #order <= 1 then -- 233
		return order[1] or self.inputMode -- 235
	end -- 235
	local next = nextPrefInList(self.settings.modePref, order, delta) -- 237
	self:setModePref(next) -- 238
	return next -- 239
end -- 232
function Input.prototype.shouldShowTouchControls(self) -- 242
	return self.driver:shouldShowTouchControls(self, self.stageVp) -- 243
end -- 242
function Input.prototype.markKeyboardActivity(self) -- 246
	if not self.target.supportsKbm then -- 246
		return -- 248
	end -- 248
	self.userInteracted = true -- 250
	if self.settings.modePref == "auto" then -- 250
		self:setInputMode("kbm") -- 252
	end -- 252
end -- 246
function Input.prototype.vibrate(self, seconds) -- 256
	self.driver:vibrate(seconds) -- 257
end -- 256
function Input.prototype.clearTransient(self, keepTouchToggles) -- 260
	if keepTouchToggles == nil then -- 260
		keepTouchToggles = false -- 260
	end -- 260
	self.driver:clearTransient(keepTouchToggles) -- 261
end -- 260
function Input.prototype.update(self, dt) -- 264
	if dt == nil then -- 264
		dt = 1 / 60 -- 264
	end -- 264
	self.driver:pollInto(self, dt) -- 265
end -- 264
function Input.prototype.applyKeyHeld(self, jump, crouch, cover, interact, aim, fire, flare, pause, retry, toggleView, tab) -- 269
	self.jump = edge(self.jump, jump) -- 282
	self.crouch = edge(self.crouch, crouch) -- 283
	self.cover = edge(self.cover, cover) -- 284
	self.interact = edge(self.interact, interact) -- 285
	self.aim = edge(self.aim, aim) -- 286
	self.fire = edge(self.fire, fire) -- 287
	self.flare = edge(self.flare, flare) -- 288
	self.pause = edge(self.pause, pause) -- 289
	self.retry = edge(self.retry, retry) -- 290
	self.toggleView = edge(self.toggleView, toggleView) -- 291
	self.tab = edge(self.tab, tab) -- 292
end -- 269
function Input.prototype.resetFrameSignals(self) -- 296
	self.artifactTogglePressed = false -- 297
	self.bottleCanceled = false -- 298
	self.touchZoneTap = "" -- 299
	self.muteTogglePressed = false -- 300
	self.fullscreenTogglePressed = false -- 301
	self.splashSkipPressed = false -- 302
	self.ledgerTogglePressed = false -- 303
	self.retryTapPressed = false -- 304
	self.uiWheelY = 0 -- 305
	self.navUp = false -- 307
	self.navDown = false -- 308
	self.navLeft = false -- 309
	self.navRight = false -- 310
	self.navConfirm = false -- 311
	self.navBack = false -- 312
	self.navPrevTab = false -- 313
	self.navNextTab = false -- 314
	self.reloadDirCol = 0 -- 316
	self.reloadDirRow = 0 -- 317
	self.reloadStepEdge = false -- 318
	self.reloadAutoStep = false -- 319
	self.reloadConfirm = false -- 320
	self.reloadReset = false -- 321
	self.craftConfirm = false -- 323
	self.craftCancel = false -- 324
	self.talentDelta = 0 -- 326
	self.talentConfirm = false -- 327
	self.retryHoldProgress = 0 -- 328
end -- 296
function Input.prototype.applyPickRoom(self, pick) -- 331
	if self.suppressPickRoomOnce then -- 331
		self.suppressPickRoomOnce = false -- 333
		self.pickRoom = 0 -- 334
	elseif pick ~= 0 and pick ~= self.lastPick then -- 334
		self.pickRoom = pick -- 336
	end -- 336
	self.lastPick = pick -- 338
end -- 331
function Input.prototype.consumePickRoom(self) -- 341
	self.pickRoom = 0 -- 342
	self.suppressPickRoomOnce = true -- 343
end -- 341
function Input.prototype.requestPickRoom(self, slot) -- 346
	if slot >= 1 and slot <= 3 then -- 346
		self.pickRoom = slot -- 348
	end -- 348
end -- 346
function Input.prototype.beginStep(self, first) -- 352
	if not first then -- 352
		self:clearEdges() -- 354
	end -- 354
end -- 352
function Input.prototype.endStep(self) -- 358
	self:clearEdges() -- 359
end -- 358
function Input.prototype.consumeEdges(self) -- 362
	self:clearEdges() -- 363
end -- 362
function Input.prototype.clearEdges(self) -- 366
	self.jump.pressed = false -- 367
	self.jump.released = false -- 368
	self.crouch.pressed = false -- 369
	self.crouch.released = false -- 370
	self.cover.pressed = false -- 371
	self.cover.released = false -- 372
	self.interact.pressed = false -- 373
	self.interact.released = false -- 374
	self.aim.pressed = false -- 375
	self.aim.released = false -- 376
	self.fire.pressed = false -- 377
	self.fire.released = false -- 378
	self.flare.pressed = false -- 379
	self.flare.released = false -- 380
	self.pause.pressed = false -- 381
	self.pause.released = false -- 382
	self.retry.pressed = false -- 383
	self.retry.released = false -- 384
	self.toggleView.pressed = false -- 385
	self.toggleView.released = false -- 386
	self.tab.pressed = false -- 387
	self.tab.released = false -- 388
end -- 366
return ____exports -- 366