-- [ts]: input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local edge -- 650
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
function edge(state, held) -- 650
	local was = state.held -- 651
	state.held = held -- 652
	if held and not was then -- 653
		state.pressed = true -- 654
	end -- 654
	if not held and was then -- 656
		state.released = true -- 657
	end -- 657
	return state -- 659
end -- 659
local function emptyKey() -- 39
	return {held = false, pressed = false, released = false} -- 40
end -- 39
____exports.Input = __TS__Class() -- 43
local Input = ____exports.Input -- 43
Input.name = "Input" -- 43
function Input.prototype.____constructor(self) -- 149
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
	self.frameInteractPressed = false -- 101
	self.suppressPickRoomOnce = false -- 103
	self.artifactTogglePressed = false -- 106
	self.bottleCanceled = false -- 107
	self.touchZoneTap = "" -- 108
	self.muteTogglePressed = false -- 109
	self.fullscreenTogglePressed = false -- 110
	self.splashSkipPressed = false -- 111
	self.navUp = false -- 114
	self.navDown = false -- 115
	self.navLeft = false -- 116
	self.navRight = false -- 117
	self.navConfirm = false -- 118
	self.navBack = false -- 119
	self.navPrevTab = false -- 120
	self.navNextTab = false -- 121
	self.reloadDirCol = 0 -- 124
	self.reloadDirRow = 0 -- 125
	self.reloadStepEdge = false -- 126
	self.reloadAutoStep = false -- 127
	self.reloadConfirm = false -- 128
	self.reloadReset = false -- 129
	self.talentDelta = 0 -- 132
	self.talentConfirm = false -- 133
	self.retryHoldProgress = 0 -- 136
	self.stageVp = computeStageViewport(1280, 720) -- 140
	self.lastPick = 0 -- 142
	self.rawMouseX = -1 -- 143
	self.rawMouseY = -1 -- 144
	self.rawMouseInited = false -- 145
	self.prevMouseLeft = false -- 146
	self.prevMouseRight = false -- 147
	self.gamepadLayout = self.settings.gamepadLayout -- 150
	if self.settings.modePref ~= "auto" then -- 151
		self.inputMode = self.settings.modePref -- 152
	end -- 152
end -- 149
function Input.prototype.bindTouch(self, router) -- 156
	self.touchRouter = router -- 157
	router.settings = self.settings -- 158
end -- 156
function Input.prototype.bindGamepad(self, router) -- 161
	self.gamepadRouter = router -- 162
	router.settings = self.settings -- 163
	self.gamepadLayout = self.settings.gamepadLayout -- 164
end -- 161
function Input.prototype.getTouch(self) -- 167
	return self.touchRouter -- 168
end -- 167
function Input.prototype.getGamepad(self) -- 171
	return self.gamepadRouter -- 172
end -- 171
function Input.prototype.setStageViewport(self, vp) -- 175
	self.stageVp = vp -- 176
end -- 175
function Input.prototype.getStageViewport(self) -- 179
	return self.stageVp -- 180
end -- 179
function Input.prototype.isTouchMode(self) -- 183
	return self.inputMode == "touch" -- 184
end -- 183
function Input.prototype.isGamepadMode(self) -- 187
	return self.inputMode == "gamepad" -- 188
end -- 187
function Input.prototype.isKbmMode(self) -- 191
	return self.inputMode == "kbm" -- 192
end -- 191
function Input.prototype.setInputMode(self, mode) -- 196
	if self.inputMode == mode then -- 197
		return -- 197
	end -- 197
	self.inputMode = mode -- 198
	if mode ~= "touch" then -- 199
		local ____opt_0 = self.touchRouter -- 200
		if ____opt_0 ~= nil then -- 200
			____opt_0:releaseAll(false) -- 200
		end -- 200
	end -- 200
end -- 196
function Input.prototype.setModePref(self, pref) -- 205
	self.settings.modePref = pref -- 206
	if pref ~= "auto" then -- 207
		self:setInputMode(pref) -- 208
	end -- 208
	saveControlSettings(self.settings) -- 210
end -- 205
function Input.prototype.cycleModePref(self, delta) -- 213
	if delta == nil then -- 213
		delta = 1 -- 213
	end -- 213
	local next = nextModePref(self.settings.modePref, delta) -- 214
	self:setModePref(next) -- 215
	return next -- 216
end -- 213
function Input.prototype.shouldShowTouchControls(self) -- 224
	if self.stageVp.isPortrait then -- 225
		return true -- 226
	end -- 226
	if self.settings.modePref == "touch" then -- 228
		return true -- 229
	end -- 229
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 231
		return false -- 232
	end -- 232
	return self.inputMode == "touch" -- 234
end -- 224
function Input.prototype.markKeyboardActivity(self) -- 238
	self.userInteracted = true -- 239
	if self.settings.modePref == "auto" then -- 240
		self:setInputMode("kbm") -- 241
	end -- 241
end -- 238
function Input.prototype.clearTransient(self, keepTouchToggles) -- 246
	if keepTouchToggles == nil then -- 246
		keepTouchToggles = false -- 246
	end -- 246
	local ____opt_2 = self.touchRouter -- 247
	if ____opt_2 ~= nil then -- 247
		____opt_2:releaseAll(keepTouchToggles) -- 247
	end -- 247
	local ____opt_4 = self.gamepadRouter -- 248
	if ____opt_4 ~= nil then -- 248
		____opt_4:clearTransient() -- 248
	end -- 248
end -- 246
function Input.prototype.update(self) -- 251
	self.gamepadLayout = self.settings.gamepadLayout -- 252
	local touch = self.touchRouter ~= nil and self.touchRouter:consumeSnapshot() or nil -- 253
	local gp = self.gamepadRouter ~= nil and self.gamepadRouter:consumeSnapshot() or nil -- 254
	local vs = App.visualSize -- 257
	local vw = View.size.width > 0 and View.size.width or self.stageVp.fullW -- 258
	local vh = View.size.height > 0 and View.size.height or self.stageVp.fullH -- 259
	local sw = vs.width > 0 and vs.width or 1 -- 260
	local sh = vs.height > 0 and vs.height or 1 -- 261
	local p = Mouse.position -- 262
	local fullX = p.x * vw / sw -- 263
	local fullY = vh - p.y * vh / sh -- 264
	local mouseLeft = Mouse.leftButtonPressed -- 266
	local mouseRight = Mouse.rightButtonPressed -- 267
	local mouseMoved = self.rawMouseInited and math.abs(fullX - self.rawMouseX) + math.abs(fullY - self.rawMouseY) >= 2.5 -- 268
	local mouseLeftPressed = mouseLeft and not self.prevMouseLeft -- 270
	local mouseLeftReleased = not mouseLeft and self.prevMouseLeft -- 271
	local mouseRightPressed = mouseRight and not self.prevMouseRight -- 272
	local mouseClicked = mouseLeftPressed or mouseRightPressed -- 273
	self.rawMouseX = fullX -- 275
	self.rawMouseY = fullY -- 276
	self.rawMouseInited = true -- 277
	self.prevMouseLeft = mouseLeft -- 278
	self.prevMouseRight = mouseRight -- 279
	local stX = self.stageVp.stageW > 0 and self.stageVp.stageX or 0 -- 281
	local stY = self.stageVp.stageH > 0 and self.stageVp.stageY or 0 -- 282
	local stW = self.stageVp.stageW > 0 and self.stageVp.stageW or vw -- 283
	local stH = self.stageVp.stageH > 0 and self.stageVp.stageH or vh -- 284
	local mouseStageX = fullX - stX -- 285
	local mouseStageY = fullY - stY -- 286
	local mouseInsideStage = mouseStageX >= 0 and mouseStageX <= stW and mouseStageY >= 0 and mouseStageY <= stH -- 287
	local suppressMouse = touch ~= nil and (touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay) -- 289
	local realMouseActive = not suppressMouse and (mouseMoved or mouseClicked and mouseInsideStage) -- 290
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 293
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 294
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 295
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 296
	local kbJump = Keyboard:isKeyPressed("Space") -- 297
	local kbCrouch = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") -- 298
	local kbCover = Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 299
	local kbInteract = Keyboard:isKeyPressed("E") -- 300
	local kbAim = Keyboard:isKeyPressed("F") -- 301
	local kbFlare = Keyboard:isKeyPressed("Q") -- 302
	local kbPause = Keyboard:isKeyPressed("Escape") -- 303
	local kbRetry = Keyboard:isKeyPressed("R") -- 304
	local kbToggle = Keyboard:isKeyPressed("G") -- 305
	local kbTab = Keyboard:isKeyPressed("Tab") -- 306
	local n1 = Keyboard:isKeyPressed("1") -- 307
	local n2 = Keyboard:isKeyPressed("2") -- 308
	local n3 = Keyboard:isKeyPressed("3") -- 309
	local anyKb = left or right or up or down or kbJump or kbCrouch or kbCover or kbInteract or kbAim or kbFlare or kbPause or kbRetry or kbToggle or kbTab or n1 or n2 or n3 or Keyboard:isKeyPressed("Return") -- 311
	local hadGp = gp ~= nil and gp.hadGamepadInput -- 316
	local hadTouchAny = touch ~= nil and touch.hadRealTouch -- 317
	if anyKb or realMouseActive or hadGp or hadTouchAny then -- 318
		self.userInteracted = true -- 319
	end -- 319
	if self.settings.modePref ~= "auto" then -- 322
		self:setInputMode(self.settings.modePref) -- 323
	else -- 323
		if hadGp then -- 325
			self:setInputMode("gamepad") -- 326
		elseif touch ~= nil and touch.hadGameplayTouch then -- 327
			self:setInputMode("touch") -- 328
		elseif anyKb or realMouseActive then -- 329
			self:setInputMode("kbm") -- 330
		elseif touch ~= nil and touch.hadUiTouch and self.inputMode == "kbm" then -- 331
			self:setInputMode("touch") -- 332
		end -- 332
	end -- 332
	local kbMoveX = (right and 1 or 0) - (left and 1 or 0) -- 337
	local kbMoveY = (down and 1 or 0) - (up and 1 or 0) -- 338
	local gpMoveX = gp ~= nil and gp.moveX or 0 -- 339
	local gpMoveY = gp ~= nil and gp.moveY or 0 -- 340
	local tMoveX = touch ~= nil and touch.moveX or 0 -- 341
	local tMoveY = touch ~= nil and touch.moveY or 0 -- 342
	self.moveX = kbMoveX ~= 0 and kbMoveX or (gpMoveX ~= 0 and gpMoveX or tMoveX) -- 343
	self.moveY = kbMoveY ~= 0 and kbMoveY or (gpMoveY ~= 0 and gpMoveY or tMoveY) -- 344
	local allowMouseFire = not suppressMouse and self.inputMode == "kbm" and mouseInsideStage -- 346
	local rawFireHeld = allowMouseFire and mouseLeft or gp ~= nil and gp.fireHeld or touch ~= nil and touch.fireHeld -- 347
	self.jump = edge(self.jump, kbJump or gp ~= nil and gp.jumpHeld or touch ~= nil and touch.jumpHeld) -- 351
	self.crouch = edge(self.crouch, kbCrouch or gp ~= nil and gp.crouchHeld or touch ~= nil and touch.crouchHeld) -- 352
	self.cover = edge(self.cover, kbCover or gp ~= nil and gp.coverHeld or touch ~= nil and touch.coverHeld) -- 353
	self.interact = edge(self.interact, kbInteract or gp ~= nil and gp.interactHeld or touch ~= nil and touch.interactHeld) -- 354
	self.aim = edge(self.aim, kbAim or gp ~= nil and gp.aimHeld or touch ~= nil and touch.aimHeld) -- 355
	self.fire = edge(self.fire, rawFireHeld) -- 356
	self.flare = edge(self.flare, kbFlare or gp ~= nil and gp.flareHeld) -- 357
	self.pause = edge(self.pause, kbPause) -- 358
	self.retry = edge(self.retry, kbRetry) -- 359
	self.toggleView = edge(self.toggleView, kbToggle) -- 360
	self.tab = edge(self.tab, kbTab) -- 361
	self.artifactTogglePressed = false -- 364
	self.bottleCanceled = false -- 365
	self.touchZoneTap = "" -- 366
	self.muteTogglePressed = false -- 367
	self.fullscreenTogglePressed = false -- 368
	self.splashSkipPressed = false -- 369
	self.navUp = false -- 371
	self.navDown = false -- 372
	self.navLeft = false -- 373
	self.navRight = false -- 374
	self.navConfirm = false -- 375
	self.navBack = false -- 376
	self.navPrevTab = false -- 377
	self.navNextTab = false -- 378
	self.reloadDirCol = 0 -- 380
	self.reloadDirRow = 0 -- 381
	self.reloadStepEdge = false -- 382
	self.reloadAutoStep = false -- 383
	self.reloadConfirm = false -- 384
	self.reloadReset = false -- 385
	self.talentDelta = 0 -- 387
	self.talentConfirm = false -- 388
	self.retryHoldProgress = 0 -- 389
	if gp ~= nil then -- 391
		if gp.jumpPressed then -- 392
			self.jump.pressed = true -- 392
		end -- 392
		if gp.crouchPressed then -- 393
			self.crouch.pressed = true -- 393
		end -- 393
		if gp.interactPressed then -- 394
			self.interact.pressed = true -- 394
		end -- 394
		if gp.aimPressed then -- 395
			self.aim.pressed = true -- 395
		end -- 395
		if gp.firePressed then -- 396
			self.fire.pressed = true -- 396
		end -- 396
		if gp.flarePressed then -- 397
			self.flare.pressed = true -- 397
		end -- 397
		if gp.pausePressed then -- 398
			self.pause.pressed = true -- 398
		end -- 398
		if gp.retryPressed then -- 399
			self.retry.pressed = true -- 399
		end -- 399
		if gp.artifactPressed then -- 400
			self.artifactTogglePressed = true -- 400
		end -- 400
		if gp.anyButtonPressed then -- 401
			self.splashSkipPressed = true -- 401
		end -- 401
		if gp.bottleCanceled then -- 402
			self.bottleCanceled = true -- 403
			self.aim.held = false -- 404
			self.aim.pressed = false -- 405
			self.aim.released = false -- 406
		end -- 406
		self.navUp = gp.navUp -- 408
		self.navDown = gp.navDown -- 409
		self.navLeft = gp.navLeft -- 410
		self.navRight = gp.navRight -- 411
		self.navConfirm = gp.navConfirm -- 412
		self.navBack = gp.navBack -- 413
		self.navPrevTab = gp.navPrevTab -- 414
		self.navNextTab = gp.navNextTab -- 415
		self.reloadDirCol = gp.reloadDirCol -- 416
		self.reloadDirRow = gp.reloadDirRow -- 417
		self.reloadStepEdge = gp.reloadStepEdge -- 418
		self.reloadAutoStep = gp.reloadAutoStep -- 419
		self.reloadConfirm = gp.reloadConfirm -- 420
		self.reloadReset = gp.reloadReset -- 421
		self.talentDelta = gp.talentDelta -- 422
		self.talentConfirm = gp.talentConfirm -- 423
		self.retryHoldProgress = gp.retryHoldProgress -- 424
	end -- 424
	if touch ~= nil then -- 427
		if touch.jumpPressed then -- 428
			self.jump.pressed = true -- 428
		end -- 428
		if touch.interactPressed then -- 429
			self.interact.pressed = true -- 429
		end -- 429
		if touch.firePressed then -- 430
			self.fire.pressed = true -- 430
		end -- 430
		if touch.pausePressed then -- 431
			self.pause.pressed = true -- 431
		end -- 431
		if touch.retryPressed then -- 432
			self.retry.pressed = true -- 432
		end -- 432
		if touch.artifactPressed then -- 433
			self.artifactTogglePressed = true -- 433
		end -- 433
		if touch.mutePressed then -- 434
			self.muteTogglePressed = true -- 434
		end -- 434
		if touch.fullscreenPressed then -- 435
			self.fullscreenTogglePressed = true -- 435
		end -- 435
		if touch.anyTapBegan then -- 436
			self.splashSkipPressed = true -- 436
		end -- 436
		if touch.zoneTap ~= "" then -- 437
			self.touchZoneTap = touch.zoneTap -- 437
		end -- 437
		if touch.navUp then -- 438
			self.navUp = true -- 438
		end -- 438
		if touch.navDown then -- 439
			self.navDown = true -- 439
		end -- 439
		if touch.navLeft then -- 440
			self.navLeft = true -- 440
		end -- 440
		if touch.navRight then -- 441
			self.navRight = true -- 441
		end -- 441
		if touch.navConfirm then -- 442
			self.navConfirm = true -- 442
		end -- 442
		if touch.navBack then -- 443
			self.navBack = true -- 443
		end -- 443
		if touch.bottleCanceled then -- 444
			self.bottleCanceled = true -- 445
			self.aim.held = false -- 446
			self.aim.pressed = false -- 447
			self.aim.released = false -- 448
		end -- 448
	end -- 448
	if not suppressMouse and self.inputMode == "kbm" and self.aim.held and mouseRightPressed then -- 452
		self.bottleCanceled = true -- 453
		self.aim.held = false -- 454
		self.aim.pressed = false -- 455
		self.aim.released = false -- 456
	end -- 456
	local pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)) -- 459
	if self.suppressPickRoomOnce then -- 460
		self.suppressPickRoomOnce = false -- 461
		self.pickRoom = 0 -- 462
	elseif pick ~= 0 and pick ~= self.lastPick then -- 463
		self.pickRoom = pick -- 464
	end -- 464
	self.lastPick = pick -- 466
	self.frameInteractPressed = self.interact.pressed -- 467
	local touchUiActive = touch ~= nil and (touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside) -- 470
	if touchUiActive and touch ~= nil then -- 473
		self.uiX = touch.uiX -- 474
		self.uiY = touch.uiY -- 475
		self.uiDx = touch.uiDx -- 476
		self.uiDy = touch.uiDy -- 477
		self.uiInside = touch.uiInside -- 478
		self.uiHeld = touch.uiHeld -- 479
		self.uiPressed = touch.uiPressed -- 480
		self.uiReleased = touch.uiReleased -- 481
		self.uiRightPressed = false -- 482
		if touch.uiHeld or touch.uiPressed then -- 483
			self.mdx = touch.uiDx -- 484
			self.mdy = touch.uiDy -- 485
			self.mx = touch.uiX -- 486
			self.my = touch.uiY -- 487
			self.inside = true -- 488
		elseif touch.hasAim then -- 489
			self.mdx = touch.aimX - self.mx -- 490
			self.mdy = touch.aimY - self.my -- 491
			self.mx = touch.aimX -- 492
			self.my = touch.aimY -- 493
			self.inside = true -- 494
		else -- 494
			self.mdx = 0 -- 496
			self.mdy = 0 -- 497
			self.inside = touch.uiInside -- 498
		end -- 498
		return -- 500
	end -- 500
	if self.inputMode == "gamepad" then -- 503
		if gp ~= nil and gp.hasAim then -- 504
			self.mdx = gp.aimX - self.mx -- 505
			self.mdy = gp.aimY - self.my -- 506
			self.mx = gp.aimX -- 507
			self.my = gp.aimY -- 508
			self.inside = true -- 509
		else -- 509
			self.mdx = 0 -- 511
			self.mdy = 0 -- 512
			self.inside = false -- 513
		end -- 513
		if not suppressMouse and mouseInsideStage and (mouseLeft or mouseLeftPressed or mouseLeftReleased) then -- 516
			self.uiDx = mouseStageX - self.uiX -- 517
			self.uiDy = mouseStageY - self.uiY -- 518
			self.uiX = mouseStageX -- 519
			self.uiY = mouseStageY -- 520
			self.uiInside = true -- 521
			self.uiHeld = mouseLeft -- 522
			self.uiPressed = mouseLeftPressed -- 523
			self.uiReleased = mouseLeftReleased -- 524
			self.uiRightPressed = mouseRightPressed -- 525
		else -- 525
			self.uiX = self.mx -- 527
			self.uiY = self.my -- 528
			self.uiDx = 0 -- 529
			self.uiDy = 0 -- 530
			self.uiInside = false -- 531
			self.uiHeld = false -- 532
			self.uiPressed = false -- 533
			self.uiReleased = false -- 534
			self.uiRightPressed = false -- 535
		end -- 535
		return -- 537
	end -- 537
	if self.inputMode == "touch" then -- 540
		if touch ~= nil and touch.hasAim then -- 541
			self.mdx = touch.aimX - self.mx -- 542
			self.mdy = touch.aimY - self.my -- 543
			self.mx = touch.aimX -- 544
			self.my = touch.aimY -- 545
			self.inside = true -- 546
		else -- 546
			self.mdx = 0 -- 548
			self.mdy = 0 -- 549
			self.inside = false -- 550
		end -- 550
		if not suppressMouse and mouseInsideStage and (mouseLeft or mouseLeftPressed or mouseLeftReleased) then -- 553
			self.uiDx = mouseStageX - self.uiX -- 554
			self.uiDy = mouseStageY - self.uiY -- 555
			self.uiX = mouseStageX -- 556
			self.uiY = mouseStageY -- 557
			self.uiInside = true -- 558
			self.uiHeld = mouseLeft -- 559
			self.uiPressed = mouseLeftPressed -- 560
			self.uiReleased = mouseLeftReleased -- 561
			self.uiRightPressed = mouseRightPressed -- 562
		else -- 562
			self.uiDx = 0 -- 564
			self.uiDy = 0 -- 565
			self.uiInside = false -- 566
			self.uiHeld = false -- 567
			self.uiPressed = false -- 568
			self.uiReleased = false -- 569
			self.uiRightPressed = false -- 570
		end -- 570
		return -- 572
	end -- 572
	self.mdx = mouseStageX - self.mx -- 576
	self.mdy = mouseStageY - self.my -- 577
	self.mx = mouseStageX -- 578
	self.my = mouseStageY -- 579
	self.inside = mouseInsideStage -- 580
	local effLeft = not suppressMouse and mouseLeft and mouseInsideStage -- 582
	local effLeftPressed = not suppressMouse and mouseLeftPressed and mouseInsideStage -- 583
	local effLeftReleased = not suppressMouse and mouseLeftReleased -- 584
	local effRightPressed = not suppressMouse and mouseRightPressed and mouseInsideStage -- 585
	self.uiX = mouseStageX -- 586
	self.uiY = mouseStageY -- 587
	self.uiDx = self.mdx -- 588
	self.uiDy = self.mdy -- 589
	self.uiInside = mouseInsideStage -- 590
	self.uiHeld = effLeft -- 591
	self.uiPressed = effLeftPressed -- 592
	self.uiReleased = effLeftReleased -- 593
	self.uiRightPressed = effRightPressed -- 594
end -- 251
function Input.prototype.consumePickRoom(self) -- 598
	self.pickRoom = 0 -- 599
	self.suppressPickRoomOnce = true -- 600
end -- 598
function Input.prototype.requestPickRoom(self, slot) -- 604
	if slot >= 1 and slot <= 3 then -- 605
		self.pickRoom = slot -- 606
	end -- 606
end -- 604
function Input.prototype.beginStep(self, first) -- 610
	if not first then -- 611
		self:clearEdges() -- 612
	end -- 612
end -- 610
function Input.prototype.endStep(self) -- 616
	self:clearEdges() -- 617
end -- 616
function Input.prototype.consumeEdges(self) -- 620
	self:clearEdges() -- 621
end -- 620
function Input.prototype.clearEdges(self) -- 624
	self.jump.pressed = false -- 625
	self.jump.released = false -- 626
	self.crouch.pressed = false -- 627
	self.crouch.released = false -- 628
	self.cover.pressed = false -- 629
	self.cover.released = false -- 630
	self.interact.pressed = false -- 631
	self.interact.released = false -- 632
	self.aim.pressed = false -- 633
	self.aim.released = false -- 634
	self.fire.pressed = false -- 635
	self.fire.released = false -- 636
	self.flare.pressed = false -- 637
	self.flare.released = false -- 638
	self.pause.pressed = false -- 639
	self.pause.released = false -- 640
	self.retry.pressed = false -- 641
	self.retry.released = false -- 642
	self.toggleView.pressed = false -- 643
	self.toggleView.released = false -- 644
	self.tab.pressed = false -- 645
	self.tab.released = false -- 646
end -- 624
return ____exports -- 624
