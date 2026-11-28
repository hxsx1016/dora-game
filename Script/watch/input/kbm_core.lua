-- [ts]: kbm_core.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local App = ____Dora.App -- 13
local Keyboard = ____Dora.Keyboard -- 13
local Mouse = ____Dora.Mouse -- 13
local Node = ____Dora.Node -- 13
local Size = ____Dora.Size -- 13
local Vec2 = ____Dora.Vec2 -- 13
local View = ____Dora.View -- 13
local NAV_REPEAT_DELAY = 0.36 -- 70
local NAV_REPEAT_INTERVAL = 0.095 -- 71
____exports.KbmPoller = __TS__Class() -- 73
local KbmPoller = ____exports.KbmPoller -- 73
KbmPoller.name = "KbmPoller" -- 73
function KbmPoller.prototype.____constructor(self) -- 73
	self.rawMouseX = -1 -- 74
	self.rawMouseY = -1 -- 75
	self.rawMouseInited = false -- 76
	self.prevMouseLeft = false -- 77
	self.prevMouseRight = false -- 78
	self.latchTouchEvents = true -- 81
	self.disableIme = false -- 82
	self.pendingLeftPressed = false -- 83
	self.pendingLeftHeld = false -- 84
	self.pendingLeftReleased = false -- 85
	self.deferredLeftRelease = false -- 86
	self.pendingRightPressed = false -- 87
	self.pendingRightHeld = false -- 88
	self.hasPendingClickPos = false -- 89
	self.pendingClickX = 0 -- 90
	self.pendingClickY = 0 -- 91
	self.pendingWheelY = 0 -- 92
	self.ignoreStuckLeft = false -- 95
	self.ignoreStuckRight = false -- 96
	self.pendingLedgerToggle = false -- 99
	self.pendingPausePressed = false -- 100
	self.pendingBackSpacePressed = false -- 101
	self.pendingRetryTap = false -- 102
	self.prevUp = false -- 104
	self.prevDown = false -- 105
	self.prevLeft = false -- 106
	self.prevRight = false -- 107
	self.prevConfirm = false -- 108
	self.prevConfirmWithE = false -- 109
	self.prevBackSpace = false -- 110
	self.prevCrouch = false -- 111
	self.prevPause = false -- 112
	self.prevRetry = false -- 113
	self.prevLedgerV = false -- 114
	self.holdUpT = 0 -- 116
	self.holdDownT = 0 -- 117
	self.holdLeftT = 0 -- 118
	self.holdRightT = 0 -- 119
	self.imeSuppressedOnce = false -- 122
end -- 73
function KbmPoller.prototype.suppressIme(self) -- 124
	if not self.disableIme or self.imeNode == nil then -- 124
		return -- 126
	end -- 126
	do -- 126
		pcall(function() -- 126
			self.imeNode:attachIME() -- 131
			self.imeNode:detachIME() -- 132
			self.imeSuppressedOnce = true -- 133
		end) -- 133
	end -- 133
end -- 124
function KbmPoller.prototype.clearTransient(self) -- 139
	self.pendingLeftPressed = false -- 140
	self.pendingLeftHeld = false -- 141
	self.pendingLeftReleased = false -- 142
	self.deferredLeftRelease = false -- 143
	self.pendingRightPressed = false -- 144
	self.pendingRightHeld = false -- 145
	self.hasPendingClickPos = false -- 146
	self.pendingWheelY = 0 -- 147
	self.pendingLedgerToggle = false -- 148
	self.pendingPausePressed = false -- 149
	self.pendingBackSpacePressed = false -- 150
	self.pendingRetryTap = false -- 151
	self.holdUpT = 0 -- 152
	self.holdDownT = 0 -- 153
	self.holdLeftT = 0 -- 154
	self.holdRightT = 0 -- 155
	self.prevMouseLeft = false -- 156
	self.prevMouseRight = false -- 157
	do -- 157
		pcall(function() -- 157
			if Mouse.leftButtonPressed then -- 157
				self.ignoreStuckLeft = true -- 160
			end -- 160
			if Mouse.rightButtonPressed then -- 160
				self.ignoreStuckRight = true -- 163
			end -- 163
		end) -- 163
	end -- 163
end -- 139
function KbmPoller.prototype.attach(self, parent, hooks, options) -- 170
	self.latchTouchEvents = (options and options.latchTouchEvents) ~= false -- 171
	self.disableIme = (options and options.disableIme) == true -- 172
	parent:onKeyDown(function(key) -- 174
		if hooks.onFirstUserGesture ~= nil then -- 174
			hooks:onFirstUserGesture() -- 176
		end -- 176
		if self.disableIme and not self.imeSuppressedOnce then -- 176
			self:suppressIme() -- 179
		end -- 179
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 179
			if hooks.onToggleFullscreen ~= nil then -- 179
				hooks:onToggleFullscreen() -- 185
			end -- 185
			return -- 187
		end -- 187
		if key == "V" then -- 187
			self.pendingLedgerToggle = true -- 190
		elseif key == "Escape" then -- 190
			self.pendingPausePressed = true -- 192
		elseif key == "BackSpace" then -- 192
			self.pendingBackSpacePressed = true -- 194
		elseif key == "R" then -- 194
			self.pendingRetryTap = true -- 196
		end -- 196
		if hooks.onKeyDownEvent ~= nil then -- 196
			hooks:onKeyDownEvent(key) -- 199
		end -- 199
	end) -- 174
	local pointerNode = Node() -- 204
	pointerNode.size = Size(16384, 16384) -- 205
	pointerNode.anchor = Vec2(0.5, 0.5) -- 206
	pointerNode.position = Vec2(0, 0) -- 207
	pointerNode.order = 120 -- 208
	pointerNode.swallowTouches = false -- 209
	pointerNode.swallowMouseWheel = false -- 210
	pointerNode.touchEnabled = true -- 211
	pointerNode:onTapBegan(function(touch) -- 212
		local isMouse = touch.fromMouse == true -- 213
		if not isMouse and not self.latchTouchEvents then -- 213
			return -- 215
		end -- 215
		if hooks.onFirstUserGesture ~= nil then -- 215
			hooks:onFirstUserGesture() -- 218
		end -- 218
		if self.disableIme and not self.imeSuppressedOnce then -- 218
			self:suppressIme() -- 221
		end -- 221
		local vl = touch.viewLocation -- 223
		if isMouse and touch.mouseButton == 2 then -- 223
			self.pendingRightPressed = true -- 225
			self.pendingRightHeld = true -- 226
			self.ignoreStuckRight = false -- 227
			self.pendingClickX = vl.x -- 228
			self.pendingClickY = vl.y -- 229
			self.hasPendingClickPos = true -- 230
		elseif not isMouse or touch.mouseButton == 1 then -- 230
			self.pendingLeftPressed = true -- 232
			self.pendingLeftHeld = true -- 233
			self.ignoreStuckLeft = false -- 234
			self.pendingClickX = vl.x -- 235
			self.pendingClickY = vl.y -- 236
			self.hasPendingClickPos = true -- 237
		end -- 237
	end) -- 212
	pointerNode:onTapEnded(function(touch) -- 240
		local isMouse = touch.fromMouse == true -- 241
		if not isMouse and not self.latchTouchEvents then -- 241
			return -- 243
		end -- 243
		if isMouse and touch.mouseButton == 2 then -- 243
			self.pendingRightHeld = false -- 246
		elseif not isMouse or touch.mouseButton == 1 then -- 246
			self.pendingLeftHeld = false -- 248
			self.pendingLeftReleased = true -- 249
		end -- 249
	end) -- 240
	pointerNode:onMouseWheel(function(delta) -- 252
		self.pendingWheelY = self.pendingWheelY + delta.y -- 253
	end) -- 252
	pointerNode:gslot( -- 255
		"AppEvent", -- 255
		function(eventType) -- 255
			if eventType == "WindowFocusLost" then -- 255
				self:clearTransient() -- 257
				return -- 258
			end -- 258
			if self.disableIme and (eventType == "WindowFocusGained" or eventType == "WindowShown") then -- 258
				self:suppressIme() -- 261
			end -- 261
		end -- 255
	) -- 255
	pointerNode:addTo(parent) -- 264
	if self.disableIme then -- 264
		local imeGuard = Node() -- 267
		imeGuard.visible = false -- 268
		imeGuard:addTo(parent) -- 269
		self.imeNode = imeGuard -- 270
		local bootFrames = 0 -- 272
		imeGuard:schedule(function() -- 273
			bootFrames = bootFrames + 1 -- 274
			if bootFrames == 3 or bootFrames == 15 then -- 274
				self:suppressIme() -- 276
			end -- 276
			return bootFrames >= 15 -- 278
		end) -- 273
	end -- 273
end -- 170
function KbmPoller.prototype.stepRepeat(self, held, prevHeld, holdT, dt) -- 283
	if not held then -- 283
		return {false, 0} -- 285
	end -- 285
	if not prevHeld then -- 285
		return {true, 0} -- 288
	end -- 288
	local nextT = holdT + dt -- 290
	if nextT >= NAV_REPEAT_DELAY then -- 290
		return {true, NAV_REPEAT_DELAY - NAV_REPEAT_INTERVAL} -- 292
	end -- 292
	return {false, nextT} -- 294
end -- 283
function KbmPoller.prototype.sample(self, vp, dt) -- 297
	if dt == nil then -- 297
		dt = 1 / 60 -- 297
	end -- 297
	local safeDt = math.min( -- 298
		0.05, -- 298
		math.max(0.001, dt) -- 298
	) -- 298
	local vs = App.visualSize -- 301
	local vw = View.size.width > 0 and View.size.width or vp.fullW -- 302
	local vh = View.size.height > 0 and View.size.height or vp.fullH -- 303
	local sw = vs.width > 0 and vs.width or 1 -- 304
	local sh = vs.height > 0 and vs.height or 1 -- 305
	local p = Mouse.position -- 306
	local fullX = p.x * vw / sw -- 307
	local fullY = vh - p.y * vh / sh -- 308
	if self.hasPendingClickPos then -- 308
		fullX = self.pendingClickX -- 310
		fullY = self.pendingClickY -- 311
		self.hasPendingClickPos = false -- 312
	end -- 312
	local rawLeft = Mouse.leftButtonPressed -- 315
	if self.ignoreStuckLeft and not rawLeft then -- 315
		self.ignoreStuckLeft = false -- 317
	end -- 317
	local ____table_ignoreStuckLeft_4 -- 319
	if self.ignoreStuckLeft then -- 319
		____table_ignoreStuckLeft_4 = false -- 319
	else -- 319
		____table_ignoreStuckLeft_4 = rawLeft -- 319
	end -- 319
	local polledLeft = ____table_ignoreStuckLeft_4 -- 319
	local rawRight = Mouse.rightButtonPressed -- 321
	if self.ignoreStuckRight and not rawRight then -- 321
		self.ignoreStuckRight = false -- 323
	end -- 323
	local ____table_ignoreStuckRight_5 -- 325
	if self.ignoreStuckRight then -- 325
		____table_ignoreStuckRight_5 = false -- 325
	else -- 325
		____table_ignoreStuckRight_5 = rawRight -- 325
	end -- 325
	local polledRight = ____table_ignoreStuckRight_5 -- 325
	local mouseLeft -- 327
	local mouseLeftPressed -- 328
	local mouseLeftReleased -- 329
	if self.pendingLeftPressed then -- 329
		mouseLeftPressed = true -- 331
		mouseLeft = true -- 332
		mouseLeftReleased = false -- 333
		if self.pendingLeftReleased and not polledLeft and not self.pendingLeftHeld then -- 333
			self.deferredLeftRelease = true -- 336
		end -- 336
		self.pendingLeftPressed = false -- 338
		self.pendingLeftReleased = false -- 339
	elseif self.deferredLeftRelease then -- 339
		self.deferredLeftRelease = false -- 341
		mouseLeft = polledLeft or self.pendingLeftHeld -- 342
		mouseLeftPressed = false -- 343
		mouseLeftReleased = not mouseLeft -- 344
	else -- 344
		mouseLeft = polledLeft or self.pendingLeftHeld -- 346
		mouseLeftPressed = mouseLeft and not self.prevMouseLeft -- 347
		mouseLeftReleased = not mouseLeft and self.prevMouseLeft or self.pendingLeftReleased -- 348
		self.pendingLeftReleased = false -- 349
	end -- 349
	local mouseRight -- 352
	local mouseRightPressed -- 353
	if self.pendingRightPressed then -- 353
		mouseRightPressed = true -- 355
		mouseRight = true -- 356
		self.pendingRightPressed = false -- 357
	else -- 357
		mouseRight = polledRight or self.pendingRightHeld -- 359
		mouseRightPressed = mouseRight and not self.prevMouseRight -- 360
	end -- 360
	local mouseMoved = self.rawMouseInited and math.abs(fullX - self.rawMouseX) + math.abs(fullY - self.rawMouseY) >= 2 -- 363
	local mouseClicked = mouseLeftPressed or mouseRightPressed -- 365
	local mouseWheelY = self.pendingWheelY -- 366
	self.pendingWheelY = 0 -- 367
	self.rawMouseX = fullX -- 369
	self.rawMouseY = fullY -- 370
	self.rawMouseInited = true -- 371
	self.prevMouseLeft = mouseLeft -- 372
	self.prevMouseRight = mouseRight -- 373
	local stX = vp.stageW > 0 and vp.stageX or 0 -- 375
	local stY = vp.stageH > 0 and vp.stageY or 0 -- 376
	local stW = vp.stageW > 0 and vp.stageW or vw -- 377
	local stH = vp.stageH > 0 and vp.stageH or vh -- 378
	local mouseStageX = fullX - stX -- 379
	local mouseStageY = fullY - stY -- 380
	local mouseInsideStage = mouseStageX >= 0 and mouseStageX <= stW and mouseStageY >= 0 and mouseStageY <= stH -- 381
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 384
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 385
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 386
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 387
	local jump = Keyboard:isKeyPressed("Space") -- 388
	local crouch = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("C") -- 389
	local cover = Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 390
	local interact = Keyboard:isKeyPressed("E") -- 391
	local aim = Keyboard:isKeyPressed("F") -- 392
	local flare = Keyboard:isKeyPressed("Q") -- 393
	local pause = Keyboard:isKeyPressed("Escape") -- 394
	local retry = Keyboard:isKeyPressed("R") -- 395
	local toggleView = Keyboard:isKeyPressed("G") -- 396
	local tab = Keyboard:isKeyPressed("Tab") -- 397
	local ledgerV = Keyboard:isKeyPressed("V") -- 398
	local ret = Keyboard:isKeyPressed("Return") -- 399
	local bs = Keyboard:isKeyPressed("BackSpace") -- 400
	local n1 = Keyboard:isKeyPressed("1") -- 401
	local n2 = Keyboard:isKeyPressed("2") -- 402
	local n3 = Keyboard:isKeyPressed("3") -- 403
	local confirm = ret or jump -- 405
	local confirmWithE = confirm or interact -- 406
	local navUp, nextUpT = table.unpack( -- 408
		self:stepRepeat(up, self.prevUp, self.holdUpT, safeDt), -- 408
		1, -- 408
		2 -- 408
	) -- 408
	local navDown, nextDownT = table.unpack( -- 409
		self:stepRepeat(down, self.prevDown, self.holdDownT, safeDt), -- 409
		1, -- 409
		2 -- 409
	) -- 409
	local navLeft, nextLeftT = table.unpack( -- 410
		self:stepRepeat(left, self.prevLeft, self.holdLeftT, safeDt), -- 410
		1, -- 410
		2 -- 410
	) -- 410
	local navRight, nextRightT = table.unpack( -- 411
		self:stepRepeat(right, self.prevRight, self.holdRightT, safeDt), -- 411
		1, -- 411
		2 -- 411
	) -- 411
	self.holdUpT = nextUpT -- 412
	self.holdDownT = nextDownT -- 413
	self.holdLeftT = nextLeftT -- 414
	self.holdRightT = nextRightT -- 415
	local navConfirm = confirm and not self.prevConfirm -- 417
	local uiConfirmWithE = confirmWithE and not self.prevConfirmWithE -- 418
	local uiBackSpace = bs and not self.prevBackSpace or self.pendingBackSpacePressed -- 419
	local crouchPressed = crouch and not self.prevCrouch -- 420
	local pausePressed = pause and not self.prevPause or self.pendingPausePressed -- 421
	local retryTapPressed = retry and not self.prevRetry or self.pendingRetryTap -- 422
	local ledgerTogglePressed = ledgerV and not self.prevLedgerV or self.pendingLedgerToggle -- 423
	self.pendingBackSpacePressed = false -- 425
	self.pendingPausePressed = false -- 426
	self.pendingRetryTap = false -- 427
	self.pendingLedgerToggle = false -- 428
	self.prevUp = up -- 430
	self.prevDown = down -- 431
	self.prevLeft = left -- 432
	self.prevRight = right -- 433
	self.prevConfirm = confirm -- 434
	self.prevConfirmWithE = confirmWithE -- 435
	self.prevBackSpace = bs -- 436
	self.prevCrouch = crouch -- 437
	self.prevPause = pause -- 438
	self.prevRetry = retry -- 439
	self.prevLedgerV = ledgerV -- 440
	local anyKb = left or right or up or down or jump or crouch or cover or interact or aim or flare or pause or retry or toggleView or tab or ledgerV or n1 or n2 or n3 or ret or bs -- 442
	return { -- 446
		mouseStageX = mouseStageX, -- 447
		mouseStageY = mouseStageY, -- 448
		mouseInsideStage = mouseInsideStage, -- 449
		mouseLeft = mouseLeft, -- 450
		mouseLeftPressed = mouseLeftPressed, -- 451
		mouseLeftReleased = mouseLeftReleased, -- 452
		mouseRight = mouseRight, -- 453
		mouseRightPressed = mouseRightPressed, -- 454
		mouseMoved = mouseMoved, -- 455
		mouseClicked = mouseClicked, -- 456
		mouseWheelY = mouseWheelY, -- 457
		moveX = (right and 1 or 0) - (left and 1 or 0), -- 458
		moveY = (down and 1 or 0) - (up and 1 or 0), -- 459
		jump = jump, -- 460
		crouch = crouch, -- 461
		crouchPressed = crouchPressed, -- 462
		cover = cover, -- 463
		interact = interact, -- 464
		aim = aim, -- 465
		flare = flare, -- 466
		pause = pause, -- 467
		pausePressed = pausePressed, -- 468
		retry = retry, -- 469
		retryTapPressed = retryTapPressed, -- 470
		toggleView = toggleView, -- 471
		tab = tab, -- 472
		pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)), -- 473
		anyKb = anyKb, -- 474
		ledgerTogglePressed = ledgerTogglePressed, -- 475
		navUp = navUp, -- 476
		navDown = navDown, -- 477
		navLeft = navLeft, -- 478
		navRight = navRight, -- 479
		navConfirm = navConfirm, -- 480
		navBack = false, -- 481
		uiConfirmWithE = uiConfirmWithE, -- 482
		uiBackSpace = uiBackSpace -- 483
	} -- 483
end -- 297
return ____exports -- 297