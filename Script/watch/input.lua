-- [ts]: input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local edge -- 1
local ____Dora = require("Dora") -- 14
local App = ____Dora.App -- 14
local Keyboard = ____Dora.Keyboard -- 14
local Mouse = ____Dora.Mouse -- 14
local View = ____Dora.View -- 14
local ____controls_config = require("Script.watch.controls_config") -- 15
local loadControlSettings = ____controls_config.loadControlSettings -- 20
local nextModePref = ____controls_config.nextModePref -- 21
local saveControlSettings = ____controls_config.saveControlSettings -- 22
local ____platform = require("Script.watch.platform") -- 25
local computeStageViewport = ____platform.computeStageViewport -- 27
local getPlatformCaps = ____platform.getPlatformCaps -- 28
function edge(state, held) -- 616
	local was = state.held -- 617
	state.held = held -- 618
	if held and not was then -- 618
		state.pressed = true -- 620
	end -- 620
	if not held and was then -- 620
		state.released = true -- 623
	end -- 623
	return state -- 625
end -- 625
local function emptyKey() -- 39
	return {held = false, pressed = false, released = false} -- 40
end -- 39
____exports.Input = __TS__Class() -- 43
local Input = ____exports.Input -- 43
Input.name = "Input" -- 43
function Input.prototype.____constructor(self) -- 144
	self.moveX = 0 -- 45
	self.moveY = 0 -- 47
	self.jump = emptyKey() -- 49
	self.crouch = emptyKey() -- 50
	self.cover = emptyKey() -- 51
	self.interact = emptyKey() -- 52
	self.aim = emptyKey() -- 53
	self.fire = emptyKey() -- 54
	self.flare = emptyKey() -- 55
	self.pause = emptyKey() -- 56
	self.retry = emptyKey() -- 57
	self.toggleView = emptyKey() -- 58
	self.tab = emptyKey() -- 59
	self.pickRoom = 0 -- 62
	self.mx = 0 -- 65
	self.my = 0 -- 66
	self.inside = true -- 68
	self.mdx = 0 -- 71
	self.mdy = 0 -- 72
	self.uiX = 0 -- 78
	self.uiY = 0 -- 79
	self.uiDx = 0 -- 80
	self.uiDy = 0 -- 81
	self.uiInside = false -- 82
	self.uiHeld = false -- 83
	self.uiPressed = false -- 84
	self.uiReleased = false -- 85
	self.uiRightPressed = false -- 86
	self.settings = loadControlSettings() -- 89
	self.inputMode = getPlatformCaps().defaultInputMode -- 92
	self.gamepadLayout = "xbox" -- 95
	self.userInteracted = false -- 98
	self.artifactTogglePressed = false -- 101
	self.bottleCanceled = false -- 102
	self.touchZoneTap = "" -- 103
	self.muteTogglePressed = false -- 104
	self.fullscreenTogglePressed = false -- 105
	self.splashSkipPressed = false -- 106
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
	self.talentDelta = 0 -- 127
	self.talentConfirm = false -- 128
	self.retryHoldProgress = 0 -- 131
	self.stageVp = computeStageViewport(1280, 720) -- 135
	self.lastPick = 0 -- 137
	self.rawMouseX = -1 -- 138
	self.rawMouseY = -1 -- 139
	self.rawMouseInited = false -- 140
	self.prevMouseLeft = false -- 141
	self.prevMouseRight = false -- 142
	self.gamepadLayout = self.settings.gamepadLayout -- 145
	if self.settings.modePref ~= "auto" then -- 145
		self.inputMode = self.settings.modePref -- 147
	end -- 147
end -- 144
function Input.prototype.bindTouch(self, router) -- 151
	self.touchRouter = router -- 152
	router.settings = self.settings -- 153
end -- 151
function Input.prototype.bindGamepad(self, router) -- 156
	self.gamepadRouter = router -- 157
	router.settings = self.settings -- 158
	self.gamepadLayout = self.settings.gamepadLayout -- 159
end -- 156
function Input.prototype.getTouch(self) -- 162
	return self.touchRouter -- 163
end -- 162
function Input.prototype.getGamepad(self) -- 166
	return self.gamepadRouter -- 167
end -- 166
function Input.prototype.setStageViewport(self, vp) -- 170
	self.stageVp = vp -- 171
end -- 170
function Input.prototype.getStageViewport(self) -- 174
	return self.stageVp -- 175
end -- 174
function Input.prototype.isTouchMode(self) -- 178
	return self.inputMode == "touch" -- 179
end -- 178
function Input.prototype.isGamepadMode(self) -- 182
	return self.inputMode == "gamepad" -- 183
end -- 182
function Input.prototype.isKbmMode(self) -- 186
	return self.inputMode == "kbm" -- 187
end -- 186
function Input.prototype.setInputMode(self, mode) -- 191
	if self.inputMode == mode then -- 191
		return -- 192
	end -- 192
	self.inputMode = mode -- 193
	if mode ~= "touch" then -- 193
		local ____opt_0 = self.touchRouter -- 193
		if ____opt_0 ~= nil then -- 193
			____opt_0:releaseAll(false) -- 195
		end -- 195
	end -- 195
end -- 191
function Input.prototype.setModePref(self, pref) -- 200
	self.settings.modePref = pref -- 201
	if pref ~= "auto" then -- 201
		self:setInputMode(pref) -- 203
	end -- 203
	saveControlSettings(self.settings) -- 205
end -- 200
function Input.prototype.cycleModePref(self, delta) -- 208
	if delta == nil then -- 208
		delta = 1 -- 208
	end -- 208
	local next = nextModePref(self.settings.modePref, delta) -- 209
	self:setModePref(next) -- 210
	return next -- 211
end -- 208
function Input.prototype.shouldShowTouchControls(self) -- 219
	if self.stageVp.isPortrait then -- 219
		return true -- 221
	end -- 221
	if self.settings.modePref == "touch" then -- 221
		return true -- 224
	end -- 224
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 224
		return false -- 227
	end -- 227
	return self.inputMode == "touch" -- 229
end -- 219
function Input.prototype.markKeyboardActivity(self) -- 233
	self.userInteracted = true -- 234
	if self.settings.modePref == "auto" then -- 234
		self:setInputMode("kbm") -- 236
	end -- 236
end -- 233
function Input.prototype.clearTransient(self, keepTouchToggles) -- 241
	if keepTouchToggles == nil then -- 241
		keepTouchToggles = false -- 241
	end -- 241
	local ____opt_2 = self.touchRouter -- 241
	if ____opt_2 ~= nil then -- 241
		____opt_2:releaseAll(keepTouchToggles) -- 242
	end -- 242
	local ____opt_4 = self.gamepadRouter -- 242
	if ____opt_4 ~= nil then -- 242
		____opt_4:clearTransient() -- 243
	end -- 243
end -- 241
function Input.prototype.update(self) -- 246
	self.gamepadLayout = self.settings.gamepadLayout -- 247
	local touch = self.touchRouter ~= nil and self.touchRouter:consumeSnapshot() or nil -- 248
	local gp = self.gamepadRouter ~= nil and self.gamepadRouter:consumeSnapshot() or nil -- 249
	local vs = App.visualSize -- 252
	local vw = View.size.width > 0 and View.size.width or self.stageVp.fullW -- 253
	local vh = View.size.height > 0 and View.size.height or self.stageVp.fullH -- 254
	local sw = vs.width > 0 and vs.width or 1 -- 255
	local sh = vs.height > 0 and vs.height or 1 -- 256
	local p = Mouse.position -- 257
	local fullX = p.x * vw / sw -- 258
	local fullY = vh - p.y * vh / sh -- 259
	local mouseLeft = Mouse.leftButtonPressed -- 261
	local mouseRight = Mouse.rightButtonPressed -- 262
	local mouseMoved = self.rawMouseInited and math.abs(fullX - self.rawMouseX) + math.abs(fullY - self.rawMouseY) >= 2.5 -- 263
	local mouseLeftPressed = mouseLeft and not self.prevMouseLeft -- 265
	local mouseLeftReleased = not mouseLeft and self.prevMouseLeft -- 266
	local mouseRightPressed = mouseRight and not self.prevMouseRight -- 267
	local mouseClicked = mouseLeftPressed or mouseRightPressed -- 268
	self.rawMouseX = fullX -- 270
	self.rawMouseY = fullY -- 271
	self.rawMouseInited = true -- 272
	self.prevMouseLeft = mouseLeft -- 273
	self.prevMouseRight = mouseRight -- 274
	local stX = self.stageVp.stageW > 0 and self.stageVp.stageX or 0 -- 276
	local stY = self.stageVp.stageH > 0 and self.stageVp.stageY or 0 -- 277
	local stW = self.stageVp.stageW > 0 and self.stageVp.stageW or vw -- 278
	local stH = self.stageVp.stageH > 0 and self.stageVp.stageH or vh -- 279
	local mouseStageX = fullX - stX -- 280
	local mouseStageY = fullY - stY -- 281
	local mouseInsideStage = mouseStageX >= 0 and mouseStageX <= stW and mouseStageY >= 0 and mouseStageY <= stH -- 282
	local suppressMouse = touch ~= nil and (touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay) -- 284
	local realMouseActive = not suppressMouse and (mouseMoved or mouseClicked and mouseInsideStage) -- 285
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 288
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 289
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 290
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 291
	local kbJump = Keyboard:isKeyPressed("Space") -- 292
	local kbCrouch = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") -- 293
	local kbCover = Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 294
	local kbInteract = Keyboard:isKeyPressed("E") -- 295
	local kbAim = Keyboard:isKeyPressed("F") -- 296
	local kbFlare = Keyboard:isKeyPressed("Q") -- 297
	local kbPause = Keyboard:isKeyPressed("Escape") -- 298
	local kbRetry = Keyboard:isKeyPressed("R") -- 299
	local kbToggle = Keyboard:isKeyPressed("G") -- 300
	local kbTab = Keyboard:isKeyPressed("Tab") -- 301
	local n1 = Keyboard:isKeyPressed("1") -- 302
	local n2 = Keyboard:isKeyPressed("2") -- 303
	local n3 = Keyboard:isKeyPressed("3") -- 304
	local anyKb = left or right or up or down or kbJump or kbCrouch or kbCover or kbInteract or kbAim or kbFlare or kbPause or kbRetry or kbToggle or kbTab or n1 or n2 or n3 or Keyboard:isKeyPressed("Return") -- 306
	local hadGp = gp ~= nil and gp.hadGamepadInput -- 311
	local hadTouchAny = touch ~= nil and touch.hadRealTouch -- 312
	if anyKb or realMouseActive or hadGp or hadTouchAny then -- 312
		self.userInteracted = true -- 314
	end -- 314
	if self.settings.modePref ~= "auto" then -- 314
		self:setInputMode(self.settings.modePref) -- 318
	else -- 318
		if hadGp then -- 318
			self:setInputMode("gamepad") -- 321
		elseif touch ~= nil and touch.hadGameplayTouch then -- 321
			self:setInputMode("touch") -- 323
		elseif anyKb or realMouseActive then -- 323
			self:setInputMode("kbm") -- 325
		elseif touch ~= nil and touch.hadUiTouch and self.inputMode == "kbm" then -- 325
			self:setInputMode("touch") -- 327
		end -- 327
	end -- 327
	local kbMoveX = (right and 1 or 0) - (left and 1 or 0) -- 332
	local kbMoveY = (down and 1 or 0) - (up and 1 or 0) -- 333
	local gpMoveX = gp ~= nil and gp.moveX or 0 -- 334
	local gpMoveY = gp ~= nil and gp.moveY or 0 -- 335
	local tMoveX = touch ~= nil and touch.moveX or 0 -- 336
	local tMoveY = touch ~= nil and touch.moveY or 0 -- 337
	self.moveX = kbMoveX ~= 0 and kbMoveX or (gpMoveX ~= 0 and gpMoveX or tMoveX) -- 338
	self.moveY = kbMoveY ~= 0 and kbMoveY or (gpMoveY ~= 0 and gpMoveY or tMoveY) -- 339
	local allowMouseFire = not suppressMouse and self.inputMode == "kbm" and mouseInsideStage -- 341
	local rawFireHeld = allowMouseFire and mouseLeft or gp ~= nil and gp.fireHeld or touch ~= nil and touch.fireHeld -- 342
	self.jump = edge(self.jump, kbJump or gp ~= nil and gp.jumpHeld or touch ~= nil and touch.jumpHeld) -- 346
	self.crouch = edge(self.crouch, kbCrouch or gp ~= nil and gp.crouchHeld or touch ~= nil and touch.crouchHeld) -- 347
	self.cover = edge(self.cover, kbCover or gp ~= nil and gp.coverHeld or touch ~= nil and touch.coverHeld) -- 348
	self.interact = edge(self.interact, kbInteract or gp ~= nil and gp.interactHeld or touch ~= nil and touch.interactHeld) -- 349
	self.aim = edge(self.aim, kbAim or gp ~= nil and gp.aimHeld or touch ~= nil and touch.aimHeld) -- 350
	self.fire = edge(self.fire, rawFireHeld) -- 351
	self.flare = edge(self.flare, kbFlare or gp ~= nil and gp.flareHeld) -- 352
	self.pause = edge(self.pause, kbPause) -- 353
	self.retry = edge(self.retry, kbRetry) -- 354
	self.toggleView = edge(self.toggleView, kbToggle) -- 355
	self.tab = edge(self.tab, kbTab) -- 356
	self.artifactTogglePressed = false -- 359
	self.bottleCanceled = false -- 360
	self.touchZoneTap = "" -- 361
	self.muteTogglePressed = false -- 362
	self.fullscreenTogglePressed = false -- 363
	self.splashSkipPressed = false -- 364
	self.navUp = false -- 366
	self.navDown = false -- 367
	self.navLeft = false -- 368
	self.navRight = false -- 369
	self.navConfirm = false -- 370
	self.navBack = false -- 371
	self.navPrevTab = false -- 372
	self.navNextTab = false -- 373
	self.reloadDirCol = 0 -- 375
	self.reloadDirRow = 0 -- 376
	self.reloadStepEdge = false -- 377
	self.reloadAutoStep = false -- 378
	self.reloadConfirm = false -- 379
	self.reloadReset = false -- 380
	self.talentDelta = 0 -- 382
	self.talentConfirm = false -- 383
	self.retryHoldProgress = 0 -- 384
	if gp ~= nil then -- 384
		if gp.jumpPressed then -- 384
			self.jump.pressed = true -- 387
		end -- 387
		if gp.crouchPressed then -- 387
			self.crouch.pressed = true -- 388
		end -- 388
		if gp.interactPressed then -- 388
			self.interact.pressed = true -- 389
		end -- 389
		if gp.aimPressed then -- 389
			self.aim.pressed = true -- 390
		end -- 390
		if gp.firePressed then -- 390
			self.fire.pressed = true -- 391
		end -- 391
		if gp.flarePressed then -- 391
			self.flare.pressed = true -- 392
		end -- 392
		if gp.pausePressed then -- 392
			self.pause.pressed = true -- 393
		end -- 393
		if gp.retryPressed then -- 393
			self.retry.pressed = true -- 394
		end -- 394
		if gp.artifactPressed then -- 394
			self.artifactTogglePressed = true -- 395
		end -- 395
		if gp.anyButtonPressed then -- 395
			self.splashSkipPressed = true -- 396
		end -- 396
		if gp.bottleCanceled then -- 396
			self.bottleCanceled = true -- 398
			self.aim.held = false -- 399
			self.aim.pressed = false -- 400
			self.aim.released = false -- 401
		end -- 401
		self.navUp = gp.navUp -- 403
		self.navDown = gp.navDown -- 404
		self.navLeft = gp.navLeft -- 405
		self.navRight = gp.navRight -- 406
		self.navConfirm = gp.navConfirm -- 407
		self.navBack = gp.navBack -- 408
		self.navPrevTab = gp.navPrevTab -- 409
		self.navNextTab = gp.navNextTab -- 410
		self.reloadDirCol = gp.reloadDirCol -- 411
		self.reloadDirRow = gp.reloadDirRow -- 412
		self.reloadStepEdge = gp.reloadStepEdge -- 413
		self.reloadAutoStep = gp.reloadAutoStep -- 414
		self.reloadConfirm = gp.reloadConfirm -- 415
		self.reloadReset = gp.reloadReset -- 416
		self.talentDelta = gp.talentDelta -- 417
		self.talentConfirm = gp.talentConfirm -- 418
		self.retryHoldProgress = gp.retryHoldProgress -- 419
	end -- 419
	if touch ~= nil then -- 419
		if touch.jumpPressed then -- 419
			self.jump.pressed = true -- 423
		end -- 423
		if touch.interactPressed then -- 423
			self.interact.pressed = true -- 424
		end -- 424
		if touch.firePressed then -- 424
			self.fire.pressed = true -- 425
		end -- 425
		if touch.pausePressed then -- 425
			self.pause.pressed = true -- 426
		end -- 426
		if touch.retryPressed then -- 426
			self.retry.pressed = true -- 427
		end -- 427
		if touch.artifactPressed then -- 427
			self.artifactTogglePressed = true -- 428
		end -- 428
		if touch.mutePressed then -- 428
			self.muteTogglePressed = true -- 429
		end -- 429
		if touch.fullscreenPressed then -- 429
			self.fullscreenTogglePressed = true -- 430
		end -- 430
		if touch.anyTapBegan then -- 430
			self.splashSkipPressed = true -- 431
		end -- 431
		if touch.zoneTap ~= "" then -- 431
			self.touchZoneTap = touch.zoneTap -- 432
		end -- 432
		if touch.navUp then -- 432
			self.navUp = true -- 433
		end -- 433
		if touch.navDown then -- 433
			self.navDown = true -- 434
		end -- 434
		if touch.navLeft then -- 434
			self.navLeft = true -- 435
		end -- 435
		if touch.navRight then -- 435
			self.navRight = true -- 436
		end -- 436
		if touch.navConfirm then -- 436
			self.navConfirm = true -- 437
		end -- 437
		if touch.navBack then -- 437
			self.navBack = true -- 438
		end -- 438
		if touch.bottleCanceled then -- 438
			self.bottleCanceled = true -- 440
			self.aim.held = false -- 441
			self.aim.pressed = false -- 442
			self.aim.released = false -- 443
		end -- 443
	end -- 443
	local pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)) -- 447
	if pick ~= 0 and pick ~= self.lastPick then -- 447
		self.pickRoom = pick -- 449
	end -- 449
	self.lastPick = pick -- 451
	local touchUiActive = touch ~= nil and (touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside) -- 454
	if touchUiActive and touch ~= nil then -- 454
		self.uiX = touch.uiX -- 458
		self.uiY = touch.uiY -- 459
		self.uiDx = touch.uiDx -- 460
		self.uiDy = touch.uiDy -- 461
		self.uiInside = touch.uiInside -- 462
		self.uiHeld = touch.uiHeld -- 463
		self.uiPressed = touch.uiPressed -- 464
		self.uiReleased = touch.uiReleased -- 465
		self.uiRightPressed = false -- 466
		if touch.uiHeld or touch.uiPressed then -- 466
			self.mdx = touch.uiDx -- 468
			self.mdy = touch.uiDy -- 469
			self.mx = touch.uiX -- 470
			self.my = touch.uiY -- 471
			self.inside = true -- 472
		elseif touch.hasAim then -- 472
			self.mdx = touch.aimX - self.mx -- 474
			self.mdy = touch.aimY - self.my -- 475
			self.mx = touch.aimX -- 476
			self.my = touch.aimY -- 477
			self.inside = true -- 478
		else -- 478
			self.mdx = 0 -- 480
			self.mdy = 0 -- 481
			self.inside = touch.uiInside -- 482
		end -- 482
		return -- 484
	end -- 484
	if self.inputMode == "gamepad" then -- 484
		if gp ~= nil and gp.hasAim then -- 484
			self.mdx = gp.aimX - self.mx -- 489
			self.mdy = gp.aimY - self.my -- 490
			self.mx = gp.aimX -- 491
			self.my = gp.aimY -- 492
			self.inside = true -- 493
		else -- 493
			self.mdx = 0 -- 495
			self.mdy = 0 -- 496
			self.inside = false -- 497
		end -- 497
		self.uiX = self.mx -- 500
		self.uiY = self.my -- 501
		self.uiDx = 0 -- 502
		self.uiDy = 0 -- 503
		self.uiInside = false -- 504
		self.uiHeld = false -- 505
		self.uiPressed = false -- 506
		self.uiReleased = false -- 507
		self.uiRightPressed = false -- 508
		return -- 509
	end -- 509
	if self.inputMode == "touch" then -- 509
		if touch ~= nil and touch.hasAim then -- 509
			self.mdx = touch.aimX - self.mx -- 514
			self.mdy = touch.aimY - self.my -- 515
			self.mx = touch.aimX -- 516
			self.my = touch.aimY -- 517
			self.inside = true -- 518
		else -- 518
			self.mdx = 0 -- 520
			self.mdy = 0 -- 521
			self.inside = false -- 522
		end -- 522
		if not suppressMouse and mouseInsideStage and (mouseLeft or mouseLeftPressed or mouseLeftReleased) then -- 522
			self.uiDx = mouseStageX - self.uiX -- 526
			self.uiDy = mouseStageY - self.uiY -- 527
			self.uiX = mouseStageX -- 528
			self.uiY = mouseStageY -- 529
			self.uiInside = true -- 530
			self.uiHeld = mouseLeft -- 531
			self.uiPressed = mouseLeftPressed -- 532
			self.uiReleased = mouseLeftReleased -- 533
			self.uiRightPressed = mouseRightPressed -- 534
		else -- 534
			self.uiDx = 0 -- 536
			self.uiDy = 0 -- 537
			self.uiInside = false -- 538
			self.uiHeld = false -- 539
			self.uiPressed = false -- 540
			self.uiReleased = false -- 541
			self.uiRightPressed = false -- 542
		end -- 542
		return -- 544
	end -- 544
	self.mdx = mouseStageX - self.mx -- 548
	self.mdy = mouseStageY - self.my -- 549
	self.mx = mouseStageX -- 550
	self.my = mouseStageY -- 551
	self.inside = mouseInsideStage -- 552
	local effLeft = not suppressMouse and mouseLeft and mouseInsideStage -- 554
	local effLeftPressed = not suppressMouse and mouseLeftPressed and mouseInsideStage -- 555
	local effLeftReleased = not suppressMouse and mouseLeftReleased -- 556
	local effRightPressed = not suppressMouse and mouseRightPressed and mouseInsideStage -- 557
	self.uiX = mouseStageX -- 558
	self.uiY = mouseStageY -- 559
	self.uiDx = self.mdx -- 560
	self.uiDy = self.mdy -- 561
	self.uiInside = mouseInsideStage -- 562
	self.uiHeld = effLeft -- 563
	self.uiPressed = effLeftPressed -- 564
	self.uiReleased = effLeftReleased -- 565
	self.uiRightPressed = effRightPressed -- 566
end -- 246
function Input.prototype.requestPickRoom(self, slot) -- 570
	if slot >= 1 and slot <= 3 then -- 570
		self.pickRoom = slot -- 572
	end -- 572
end -- 570
function Input.prototype.beginStep(self, first) -- 576
	if not first then -- 576
		self:clearEdges() -- 578
	end -- 578
end -- 576
function Input.prototype.endStep(self) -- 582
	self:clearEdges() -- 583
end -- 582
function Input.prototype.consumeEdges(self) -- 586
	self:clearEdges() -- 587
end -- 586
function Input.prototype.clearEdges(self) -- 590
	self.jump.pressed = false -- 591
	self.jump.released = false -- 592
	self.crouch.pressed = false -- 593
	self.crouch.released = false -- 594
	self.cover.pressed = false -- 595
	self.cover.released = false -- 596
	self.interact.pressed = false -- 597
	self.interact.released = false -- 598
	self.aim.pressed = false -- 599
	self.aim.released = false -- 600
	self.fire.pressed = false -- 601
	self.fire.released = false -- 602
	self.flare.pressed = false -- 603
	self.flare.released = false -- 604
	self.pause.pressed = false -- 605
	self.pause.released = false -- 606
	self.retry.pressed = false -- 607
	self.retry.released = false -- 608
	self.toggleView.pressed = false -- 609
	self.toggleView.released = false -- 610
	self.tab.pressed = false -- 611
	self.tab.released = false -- 612
end -- 590
return ____exports -- 590