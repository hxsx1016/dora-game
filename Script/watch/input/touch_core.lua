-- [ts]: touch_core.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Node = ____Dora.Node -- 12
local Size = ____Dora.Size -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____aim_assist = require("Script.watch.input.aim_assist") -- 13
local pickSmartFireTarget = ____aim_assist.pickSmartFireTarget -- 15
local snapConeAim = ____aim_assist.snapConeAim -- 16
local snapPointAim = ____aim_assist.snapPointAim -- 17
local ____controls_config = require("Script.watch.controls_config") -- 19
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 21
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 22
local defaultControlSettings = ____controls_config.defaultControlSettings -- 23
local nextStepValue = ____controls_config.nextStepValue -- 24
local saveControlSettings = ____controls_config.saveControlSettings -- 25
local ____platform_mobile = require("Script.watch.platform_mobile") -- 27
local computeLandscapeSafeViewport = ____platform_mobile.computeLandscapeSafeViewport -- 28
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 29
local viewToStage = ____platform_mobile.viewToStage -- 30
local STICK_DEAD_RATIO = 0.18 -- 212
local FIRE_STICK_DRAG_THRESHOLD_OV = 16 -- 213
local FIRE_STICK_MAX_R_OV = 54 -- 214
local BOTTLE_AIM_Y_OFFSET_UI = 52 -- 215
local SYNTHETIC_MOUSE_COOLDOWN_SEC = 0.25 -- 216
local function clamp(v, lo, hi) -- 218
	return v < lo and lo or (v > hi and hi or v) -- 219
end -- 218
local function hypot(dx, dy) -- 222
	return math.sqrt(dx * dx + dy * dy) -- 223
end -- 222
local function isInstantUiButton(id) -- 226
	return id == "pause" or id == "retry" or id == "mute" or id == "fullscreen" or id == "nav_up" or id == "nav_down" or id == "nav_left" or id == "nav_right" or id == "nav_confirm" or id == "nav_back" -- 227
end -- 226
____exports.TouchRouter = __TS__Class() -- 239
local TouchRouter = ____exports.TouchRouter -- 239
TouchRouter.name = "TouchRouter" -- 239
function TouchRouter.prototype.____constructor(self, sharedSettings, opts) -- 351
	self.fingers = {} -- 244
	self.ctx = { -- 246
		viewport = computeLandscapeSafeViewport(1280, 720), -- 247
		overlayScale = 1, -- 248
		overlayActive = false, -- 249
		allowAutoGameplayTouch = true, -- 250
		allowMouseOnOverlay = false, -- 251
		modal = true, -- 252
		gameplayActive = false, -- 253
		cutsceneBlocking = false, -- 254
		childMode = false, -- 255
		allowDepth = false, -- 256
		canShoot = false, -- 257
		canBottleAim = false, -- 258
		cartNearby = false, -- 259
		cartGripping = false, -- 260
		cartUsesToggle = false, -- 261
		coverNear = false, -- 262
		playerRolling = false, -- 263
		inLowArch = false, -- 264
		inTowerEnd = false, -- 265
		playerFacing = 1, -- 266
		playerScreenX = 640, -- 267
		playerScreenY = 240, -- 268
		enemyTargets = {}, -- 269
		stickZoneMaxX = 560, -- 270
		stickZoneMaxY = 600, -- 271
		stickDefaultX = 148, -- 272
		stickDefaultY = 144, -- 273
		stickMaxR = 64, -- 274
		stickFixedOrigin = false, -- 275
		buttons = {}, -- 276
		rectZones = {}, -- 277
		bottleCancelCenter = {x = 1120, y = 120, r = 44} -- 278
	} -- 278
	self.stickFingerId = -1 -- 281
	self.stickOriginX = 148 -- 282
	self.stickOriginY = 144 -- 283
	self.stickKnobX = 148 -- 284
	self.stickKnobY = 144 -- 285
	self.stickMoveX = 0 -- 286
	self.stickMoveY = 0 -- 287
	self.stickSlow = false -- 288
	self.coverToggled = false -- 290
	self.crouchToggled = false -- 291
	self.slowToggled = false -- 292
	self.cartGripLatched = false -- 293
	self.cartGripSeenActive = false -- 294
	self.coverNearSeen = false -- 295
	self.interactFingerId = -1 -- 297
	self.jumpFingerId = -1 -- 298
	self.fireFingerId = -1 -- 299
	self.fireStickDragging = false -- 300
	self.fireOriginX = 1110 -- 301
	self.fireOriginY = 154 -- 302
	self.fireKnobX = 1110 -- 303
	self.fireKnobY = 154 -- 304
	self.bottleFingerId = -1 -- 305
	self.bottleOriginOvX = 0 -- 306
	self.bottleOriginOvY = 0 -- 307
	self.bottleCancelHover = false -- 308
	self.bottleFingerOvX = 0 -- 309
	self.bottleFingerOvY = 0 -- 310
	self.aimCanvasFingerId = -1 -- 311
	self.modalFingerId = -1 -- 313
	self.uiX = 0 -- 314
	self.uiY = 0 -- 315
	self.uiPrevX = 0 -- 316
	self.uiPrevY = 0 -- 317
	self.uiHeld = false -- 318
	self.uiPressedQueue = false -- 319
	self.uiReleasedQueue = false -- 320
	self.hasAim = false -- 322
	self.aimX = 640 -- 323
	self.aimY = 300 -- 324
	self.qHadRealTouch = false -- 326
	self.qHadGameplayTouch = false -- 327
	self.qHadUiTouch = false -- 328
	self.qAnyTapBegan = false -- 329
	self.qMouseConsumed = false -- 330
	self.qJumpPressed = false -- 331
	self.qInteractPressed = false -- 332
	self.qFirePressed = false -- 333
	self.qPausePressed = false -- 334
	self.qRetryPressed = false -- 335
	self.qArtifactPressed = false -- 336
	self.qMutePressed = false -- 337
	self.qFullscreenPressed = false -- 338
	self.qBottleCanceled = false -- 339
	self.qNavUp = false -- 340
	self.qNavDown = false -- 341
	self.qNavLeft = false -- 342
	self.qNavRight = false -- 343
	self.qNavConfirm = false -- 344
	self.qNavBack = false -- 345
	self.qZoneTap = "" -- 346
	self.clockSec = 10 -- 348
	self.lastRealTouchClock = -10 -- 349
	self.settings = sharedSettings ~= nil and sharedSettings or defaultControlSettings() -- 352
	self.enableMouseCompat = (opts and opts.enableMouseCompat) == true -- 353
	self.enablePortrait = (opts and opts.enablePortrait) ~= false -- 354
end -- 351
function TouchRouter.prototype.attach(self, parent) -- 357
	if self.listenerNode ~= nil then -- 358
		return -- 359
	end -- 359
	local n = Node() -- 361
	n.size = Size(0, 0) -- 362
	n.position = Vec2(0, 0) -- 363
	n.order = 120 -- 364
	n.swallowTouches = false -- 365
	n.touchEnabled = true -- 366
	n:onTapBegan(function(touch) -- 367
		local loc = touch.viewLocation -- 368
		self:handleTouchBegan(touch.id, loc.x, loc.y, touch.fromMouse) -- 369
	end) -- 367
	n:onTapMoved(function(touch) -- 371
		local loc = touch.viewLocation -- 372
		self:handleTouchMoved(touch.id, loc.x, loc.y, touch.fromMouse) -- 373
	end) -- 371
	n:onTapEnded(function(touch) -- 375
		local loc = touch.viewLocation -- 376
		self:handleTouchEnded(touch.id, loc.x, loc.y, touch.fromMouse) -- 377
	end) -- 375
	n:addTo(parent) -- 379
	self.listenerNode = n -- 380
end -- 357
function TouchRouter.prototype.injectTouch(self, phase, id, viewX, viewY, fromMouse) -- 383
	if fromMouse == nil then -- 388
		fromMouse = false -- 388
	end -- 388
	if phase == "began" then -- 390
		self:handleTouchBegan(id, viewX, viewY, fromMouse) -- 391
	elseif phase == "moved" then -- 392
		self:handleTouchMoved(id, viewX, viewY, fromMouse) -- 393
	else -- 393
		self:handleTouchEnded(id, viewX, viewY, fromMouse) -- 395
	end -- 395
end -- 383
function TouchRouter.prototype.cycleOpacity(self) -- 399
	self.settings.touchOpacity = nextStepValue(self.settings.touchOpacity, TOUCH_OPACITY_STEPS, 1) -- 400
	saveControlSettings(self.settings) -- 401
	return self.settings.touchOpacity -- 402
end -- 399
function TouchRouter.prototype.cycleScale(self) -- 405
	self.settings.touchScale = nextStepValue(self.settings.touchScale, TOUCH_SCALE_STEPS, 1) -- 406
	saveControlSettings(self.settings) -- 407
	return self.settings.touchScale -- 408
end -- 405
function TouchRouter.prototype.toggleAimAssist(self) -- 411
	self.settings.aimAssist = not self.settings.aimAssist -- 412
	saveControlSettings(self.settings) -- 413
	return self.settings.aimAssist -- 414
end -- 411
function TouchRouter.prototype.toggleHaptics(self) -- 417
	self.settings.haptics = not self.settings.haptics -- 418
	saveControlSettings(self.settings) -- 419
	if self.settings.haptics then -- 420
		self:vibrate(0.018) -- 421
	end -- 421
	return self.settings.haptics -- 423
end -- 417
function TouchRouter.prototype.vibrate(self, seconds) -- 426
	triggerMobileHaptics(seconds, self.settings.haptics) -- 427
end -- 426
function TouchRouter.prototype.isSuppressingSyntheticMouse(self) -- 430
	if not self.enableMouseCompat then -- 431
		return false -- 432
	end -- 432
	if self:hasActiveRealFinger() then -- 434
		return true -- 435
	end -- 435
	return self.clockSec - self.lastRealTouchClock < SYNTHETIC_MOUSE_COOLDOWN_SEC -- 437
end -- 430
function TouchRouter.prototype.hasActiveRealFinger(self) -- 440
	for k in pairs(self.fingers) do -- 441
		local f = self.fingers[k] -- 442
		if f ~= nil and not f.fromMouse then -- 443
			return true -- 444
		end -- 444
	end -- 444
	return false -- 447
end -- 440
function TouchRouter.prototype.hasActiveMouseOverlayFinger(self) -- 450
	if not self.enableMouseCompat then -- 451
		return false -- 452
	end -- 452
	for k in pairs(self.fingers) do -- 454
		local f = self.fingers[k] -- 455
		if f ~= nil and f.fromMouse then -- 456
			return true -- 457
		end -- 457
	end -- 457
	return false -- 460
end -- 450
function TouchRouter.prototype.setFrameContext(self, next, dt) -- 463
	if self.enableMouseCompat then -- 464
		self.clockSec = self.clockSec + math.min( -- 465
			0.05, -- 465
			math.max(0, dt) -- 465
		) -- 465
	end -- 465
	local wasModal = self.ctx.modal -- 467
	local wasCutscene = self.ctx.cutsceneBlocking -- 468
	self.ctx = next -- 469
	if not wasModal and next.modal or not wasCutscene and next.cutsceneBlocking then -- 471
		self:releaseGameplayFingers() -- 472
	end -- 472
	if next.playerRolling then -- 475
		self.coverToggled = false -- 476
	end -- 476
	if self.coverToggled then -- 478
		if next.coverNear then -- 479
			self.coverNearSeen = true -- 480
		elseif self.coverNearSeen then -- 481
			self.coverToggled = false -- 482
			self.coverNearSeen = false -- 483
		end -- 483
	else -- 483
		self.coverNearSeen = false -- 486
	end -- 486
	if self.cartGripLatched then -- 489
		if next.cartGripping then -- 490
			self.cartGripSeenActive = true -- 491
		elseif not next.cartNearby or self.cartGripSeenActive then -- 492
			self.cartGripLatched = false -- 493
			self.cartGripSeenActive = false -- 494
		end -- 494
	else -- 494
		self.cartGripSeenActive = false -- 497
	end -- 497
	if not next.canBottleAim and self.bottleFingerId >= 0 then -- 500
		self:releaseFingerById(self.bottleFingerId) -- 501
	end -- 501
	if next.childMode then -- 504
		self.coverToggled = false -- 505
	else -- 505
		self.crouchToggled = false -- 507
		self.slowToggled = false -- 508
	end -- 508
end -- 463
function TouchRouter.prototype.releaseAll(self, keepToggles) -- 512
	if keepToggles == nil then -- 512
		keepToggles = false -- 512
	end -- 512
	self.fingers = {} -- 513
	self.stickFingerId = -1 -- 514
	self.stickMoveX = 0 -- 515
	self.stickMoveY = 0 -- 516
	self.stickSlow = false -- 517
	self.interactFingerId = -1 -- 518
	self.jumpFingerId = -1 -- 519
	self.fireFingerId = -1 -- 520
	self.fireStickDragging = false -- 521
	self.bottleFingerId = -1 -- 522
	self.bottleCancelHover = false -- 523
	self.aimCanvasFingerId = -1 -- 524
	self.modalFingerId = -1 -- 525
	self.uiHeld = false -- 526
	self.uiPressedQueue = false -- 527
	self.uiReleasedQueue = false -- 528
	if not keepToggles then -- 529
		self.coverToggled = false -- 530
		self.crouchToggled = false -- 531
		self.slowToggled = false -- 532
		self.cartGripLatched = false -- 533
		self.cartGripSeenActive = false -- 534
		self.coverNearSeen = false -- 535
		self.hasAim = false -- 536
	end -- 536
end -- 512
function TouchRouter.prototype.clearRoomStates(self) -- 540
	self:releaseAll(false) -- 541
	self.qJumpPressed = false -- 542
	self.qInteractPressed = false -- 543
	self.qFirePressed = false -- 544
	self.qPausePressed = false -- 545
	self.qRetryPressed = false -- 546
	self.qArtifactPressed = false -- 547
	self.qMutePressed = false -- 548
	self.qFullscreenPressed = false -- 549
	self.qBottleCanceled = false -- 550
	self.qNavUp = false -- 551
	self.qNavDown = false -- 552
	self.qNavLeft = false -- 553
	self.qNavRight = false -- 554
	self.qNavConfirm = false -- 555
	self.qNavBack = false -- 556
	self.qZoneTap = "" -- 557
end -- 540
function TouchRouter.prototype.releaseGameplayFingers(self) -- 560
	local ids = {} -- 561
	for k in pairs(self.fingers) do -- 562
		local f = self.fingers[k] -- 563
		if f ~= nil and f.kind ~= "modal" then -- 564
			ids[#ids + 1] = f.id -- 565
		end -- 565
	end -- 565
	local i = 0 -- 568
	do -- 568
		i = 0 -- 569
		while i < #ids do -- 569
			self:releaseFingerById(ids[i + 1]) -- 570
			i = i + 1 -- 569
		end -- 569
	end -- 569
end -- 560
function TouchRouter.prototype.releaseFingerById(self, id) -- 574
	local f = self.fingers[id] -- 575
	if f == nil then -- 576
		return -- 576
	end -- 576
	__TS__Delete(self.fingers, id) -- 577
	if self.stickFingerId == id then -- 578
		self.stickFingerId = -1 -- 579
		self.stickMoveX = 0 -- 580
		self.stickMoveY = 0 -- 581
		self.stickSlow = false -- 582
	end -- 582
	if self.interactFingerId == id then -- 584
		self.interactFingerId = -1 -- 584
	end -- 584
	if self.jumpFingerId == id then -- 585
		self.jumpFingerId = -1 -- 585
	end -- 585
	if self.fireFingerId == id then -- 586
		self.fireFingerId = -1 -- 587
		self.fireStickDragging = false -- 588
	end -- 588
	if self.bottleFingerId == id then -- 590
		self.bottleFingerId = -1 -- 591
		self.bottleCancelHover = false -- 592
	end -- 592
	if self.aimCanvasFingerId == id then -- 594
		self.aimCanvasFingerId = -1 -- 594
	end -- 594
	if self.modalFingerId == id then -- 595
		self.modalFingerId = -1 -- 596
		self.uiHeld = false -- 597
	end -- 597
end -- 574
function TouchRouter.prototype.getStickVisual(self) -- 601
	local r = self.ctx.stickMaxR -- 602
	if self.stickFingerId >= 0 then -- 603
		return { -- 604
			active = true, -- 605
			originX = self.stickOriginX, -- 606
			originY = self.stickOriginY, -- 607
			knobX = self.stickKnobX, -- 608
			knobY = self.stickKnobY, -- 609
			radius = r, -- 610
			slowZone = self.stickSlow, -- 611
			allowDepth = self.ctx.allowDepth -- 612
		} -- 612
	end -- 612
	return { -- 615
		active = false, -- 616
		originX = self.ctx.stickDefaultX, -- 617
		originY = self.ctx.stickDefaultY, -- 618
		knobX = self.ctx.stickDefaultX, -- 619
		knobY = self.ctx.stickDefaultY, -- 620
		radius = r, -- 621
		slowZone = false, -- 622
		allowDepth = self.ctx.allowDepth -- 623
	} -- 623
end -- 601
function TouchRouter.prototype.getFireStickVisual(self) -- 627
	return { -- 628
		active = self.fireFingerId >= 0, -- 629
		dragging = self.fireStickDragging, -- 630
		originX = self.fireOriginX, -- 631
		originY = self.fireOriginY, -- 632
		knobX = self.fireKnobX, -- 633
		knobY = self.fireKnobY, -- 634
		radius = FIRE_STICK_MAX_R_OV * self.settings.touchScale -- 635
	} -- 635
end -- 627
function TouchRouter.prototype.getBottleDragVisual(self) -- 639
	return { -- 640
		active = self.bottleFingerId >= 0, -- 641
		cancelHover = self.bottleCancelHover, -- 642
		cancelX = self.ctx.bottleCancelCenter.x, -- 643
		cancelY = self.ctx.bottleCancelCenter.y, -- 644
		cancelR = self.ctx.bottleCancelCenter.r, -- 645
		fingerOvX = self.bottleFingerOvX, -- 646
		fingerOvY = self.bottleFingerOvY -- 647
	} -- 647
end -- 639
function TouchRouter.prototype.isButtonHeld(self, id) -- 651
	if id == "interact" then -- 652
		return self.interactFingerId >= 0 or self.cartGripLatched -- 652
	end -- 652
	if id == "jump" then -- 653
		return self.jumpFingerId >= 0 -- 653
	end -- 653
	if id == "fire" then -- 654
		return self.fireFingerId >= 0 -- 654
	end -- 654
	if id == "bottle" then -- 655
		return self.bottleFingerId >= 0 -- 655
	end -- 655
	if id == "cover" then -- 656
		local ____table_ctx_childMode_4 -- 656
		if self.ctx.childMode then -- 656
			____table_ctx_childMode_4 = self.slowToggled -- 656
		else -- 656
			____table_ctx_childMode_4 = self.coverToggled -- 656
		end -- 656
		return ____table_ctx_childMode_4 -- 656
	end -- 656
	if id == "crouch" then -- 657
		return self.crouchToggled -- 657
	end -- 657
	return false -- 658
end -- 651
function TouchRouter.prototype.consumeSnapshot(self) -- 661
	local uiDx = self.uiX - self.uiPrevX -- 662
	local uiDy = self.uiY - self.uiPrevY -- 663
	self.uiPrevX = self.uiX -- 664
	self.uiPrevY = self.uiY -- 665
	local cartHold = self.cartGripLatched and not self.ctx.cartUsesToggle -- 667
	local suppressSyntheticMouse = self:isSuppressingSyntheticMouse() -- 668
	local mouseConsumed = self.enableMouseCompat and (self.qMouseConsumed or self:hasActiveMouseOverlayFinger()) -- 669
	local ____self_qHadRealTouch_6 = self.qHadRealTouch -- 672
	local ____self_qHadGameplayTouch_7 = self.qHadGameplayTouch -- 673
	local ____self_qHadUiTouch_8 = self.qHadUiTouch -- 674
	local ____self_qAnyTapBegan_9 = self.qAnyTapBegan -- 675
	local ____suppressSyntheticMouse_10 = suppressSyntheticMouse -- 676
	local ____self_stickMoveX_11 = self.stickMoveX -- 678
	local ____self_stickMoveY_12 = self.stickMoveY -- 679
	local ____temp_13 = self.jumpFingerId >= 0 -- 680
	local ____self_qJumpPressed_14 = self.qJumpPressed -- 681
	local ____self_crouchToggled_15 = self.crouchToggled -- 682
	local ____table_ctx_childMode_5 -- 683
	if self.ctx.childMode then -- 683
		____table_ctx_childMode_5 = self.slowToggled or self.stickSlow -- 683
	else -- 683
		____table_ctx_childMode_5 = self.coverToggled -- 683
	end -- 683
	local snap = { -- 671
		hadRealTouch = ____self_qHadRealTouch_6, -- 672
		hadGameplayTouch = ____self_qHadGameplayTouch_7, -- 673
		hadUiTouch = ____self_qHadUiTouch_8, -- 674
		anyTapBegan = ____self_qAnyTapBegan_9, -- 675
		suppressSyntheticMouse = ____suppressSyntheticMouse_10, -- 676
		mouseConsumedByOverlay = mouseConsumed, -- 677
		moveX = ____self_stickMoveX_11, -- 678
		moveY = ____self_stickMoveY_12, -- 679
		jumpHeld = ____temp_13, -- 680
		jumpPressed = ____self_qJumpPressed_14, -- 681
		crouchHeld = ____self_crouchToggled_15, -- 682
		coverHeld = ____table_ctx_childMode_5, -- 683
		interactHeld = self.interactFingerId >= 0 or cartHold, -- 684
		interactPressed = self.qInteractPressed, -- 685
		aimHeld = self.bottleFingerId >= 0, -- 686
		fireHeld = self.fireFingerId >= 0 or self.aimCanvasFingerId >= 0, -- 687
		firePressed = self.qFirePressed, -- 688
		pausePressed = self.qPausePressed, -- 689
		retryPressed = self.qRetryPressed, -- 690
		artifactPressed = self.qArtifactPressed, -- 691
		mutePressed = self.qMutePressed, -- 692
		fullscreenPressed = self.qFullscreenPressed, -- 693
		bottleCanceled = self.qBottleCanceled, -- 694
		navUp = self.qNavUp, -- 695
		navDown = self.qNavDown, -- 696
		navLeft = self.qNavLeft, -- 697
		navRight = self.qNavRight, -- 698
		navConfirm = self.qNavConfirm, -- 699
		navBack = self.qNavBack, -- 700
		hasAim = self.hasAim, -- 701
		aimX = self.aimX, -- 702
		aimY = self.aimY, -- 703
		uiHeld = self.uiHeld, -- 704
		uiPressed = self.uiPressedQueue, -- 705
		uiReleased = self.uiReleasedQueue, -- 706
		uiInside = self.uiHeld or self.uiPressedQueue or self.uiReleasedQueue, -- 707
		uiX = self.uiX, -- 708
		uiY = self.uiY, -- 709
		uiDx = uiDx, -- 710
		uiDy = uiDy, -- 711
		zoneTap = self.qZoneTap -- 712
	} -- 712
	self.qHadRealTouch = false -- 715
	self.qHadGameplayTouch = false -- 716
	self.qHadUiTouch = false -- 717
	self.qAnyTapBegan = false -- 718
	self.qMouseConsumed = false -- 719
	self.qJumpPressed = false -- 720
	self.qInteractPressed = false -- 721
	self.qFirePressed = false -- 722
	self.qPausePressed = false -- 723
	self.qRetryPressed = false -- 724
	self.qArtifactPressed = false -- 725
	self.qMutePressed = false -- 726
	self.qFullscreenPressed = false -- 727
	self.qBottleCanceled = false -- 728
	self.qNavUp = false -- 729
	self.qNavDown = false -- 730
	self.qNavLeft = false -- 731
	self.qNavRight = false -- 732
	self.qNavConfirm = false -- 733
	self.qNavBack = false -- 734
	self.qZoneTap = "" -- 735
	self.uiPressedQueue = false -- 736
	self.uiReleasedQueue = false -- 737
	return snap -- 738
end -- 661
function TouchRouter.prototype.toOverlay(self, viewX, viewY) -- 741
	local sc = math.max(0.25, self.ctx.overlayScale) -- 742
	return {x = viewX / sc, y = viewY / sc} -- 743
end -- 741
function TouchRouter.prototype.hitTestRectZones(self, ovX, ovY) -- 746
	local pt = Vec2(ovX, ovY) -- 747
	local i = 0 -- 748
	do -- 748
		i = 0 -- 749
		while i < #self.ctx.rectZones do -- 749
			local z = self.ctx.rectZones[i + 1] -- 750
			if z.rect:containsPoint(pt) then -- 751
				return z -- 752
			end -- 752
			i = i + 1 -- 749
		end -- 749
	end -- 749
	return nil -- 755
end -- 746
function TouchRouter.prototype.hitTestButtons(self, ovX, ovY) -- 758
	local pt = Vec2(ovX, ovY) -- 759
	local best -- 760
	local bestDist = 1000000000 -- 761
	local i = 0 -- 762
	do -- 762
		i = 0 -- 763
		while i < #self.ctx.buttons do -- 763
			do -- 763
				local b = self.ctx.buttons[i + 1] -- 764
				if b.rect ~= nil then -- 765
					if b.rect:containsPoint(pt) then -- 766
						return b -- 767
					end -- 767
					goto __continue85 -- 769
				end -- 769
				local hitR = b.r * 1.22 -- 771
				local d = hypot(ovX - b.x, ovY - b.y) -- 772
				if d <= hitR and d < bestDist then -- 773
					bestDist = d -- 774
					best = b -- 775
				end -- 775
			end -- 775
			::__continue85:: -- 775
			i = i + 1 -- 763
		end -- 763
	end -- 763
	return best -- 778
end -- 758
function TouchRouter.prototype.handleTouchBegan(self, id, viewX, viewY, fromMouse) -- 781
	if fromMouse then -- 782
		if not self.enableMouseCompat or not self.ctx.allowMouseOnOverlay or not self.ctx.overlayActive then -- 783
			return -- 784
		end -- 784
		local vp = self.ctx.viewport -- 786
		local ov = self:toOverlay(viewX, viewY) -- 787
		local hitBtn = self:hitTestButtons(ov.x, ov.y) -- 788
		if hitBtn ~= nil then -- 789
			self.qMouseConsumed = true -- 790
			self.fingers[id] = { -- 791
				id = id, -- 792
				fromMouse = true, -- 793
				kind = "btn", -- 794
				btnId = hitBtn.id, -- 795
				startViewX = viewX, -- 796
				startViewY = viewY, -- 797
				curViewX = viewX, -- 798
				curViewY = viewY, -- 799
				startOvX = ov.x, -- 800
				startOvY = ov.y, -- 801
				curOvX = ov.x, -- 802
				curOvY = ov.y, -- 803
				movedDistOv = 0 -- 804
			} -- 804
			self:onButtonPressed( -- 806
				hitBtn, -- 806
				id, -- 806
				ov.x, -- 806
				ov.y, -- 806
				true -- 806
			) -- 806
			return -- 807
		end -- 807
		if self.enablePortrait and vp.isPortrait and self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.cutsceneBlocking and viewY < vp.deckH and ov.x <= self.ctx.stickZoneMaxX and self.stickFingerId < 0 then -- 809
			self.qMouseConsumed = true -- 811
			self:startStick( -- 812
				id, -- 812
				viewX, -- 812
				viewY, -- 812
				ov.x, -- 812
				ov.y, -- 812
				true -- 812
			) -- 812
		end -- 812
		return -- 814
	end -- 814
	local vp = self.ctx.viewport -- 817
	local ov = self:toOverlay(viewX, viewY) -- 818
	local portrait = self.enablePortrait and vp.isPortrait -- 819
	if self.enableMouseCompat then -- 821
		self.lastRealTouchClock = self.clockSec -- 822
	end -- 822
	self.qHadRealTouch = true -- 824
	self.qAnyTapBegan = true -- 825
	if self.ctx.overlayActive then -- 827
		local btn = self:hitTestButtons(ov.x, ov.y) -- 828
		if btn ~= nil then -- 829
			if isInstantUiButton(btn.id) then -- 830
				self.qHadUiTouch = true -- 831
			else -- 831
				self.qHadGameplayTouch = true -- 833
			end -- 833
			self.fingers[id] = { -- 835
				id = id, -- 836
				fromMouse = false, -- 837
				kind = "btn", -- 838
				btnId = btn.id, -- 839
				startViewX = viewX, -- 840
				startViewY = viewY, -- 841
				curViewX = viewX, -- 842
				curViewY = viewY, -- 843
				startOvX = ov.x, -- 844
				startOvY = ov.y, -- 845
				curOvX = ov.x, -- 846
				curOvY = ov.y, -- 847
				movedDistOv = 0 -- 848
			} -- 848
			self:onButtonPressed( -- 850
				btn, -- 850
				id, -- 850
				ov.x, -- 850
				ov.y, -- 850
				false -- 850
			) -- 850
			return -- 851
		end -- 851
	end -- 851
	local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = viewX >= 0 and viewX <= vp.stageW and viewY >= 0 and viewY <= vp.stageH}) -- 855
	if self.ctx.gameplayActive and #self.ctx.rectZones > 0 then -- 858
		local zone = self:hitTestRectZones(ov.x, ov.y) -- 859
		if zone ~= nil then -- 860
			self.qHadUiTouch = true -- 861
			self.fingers[id] = { -- 862
				id = id, -- 863
				fromMouse = false, -- 864
				kind = "zone", -- 865
				zoneId = zone.id, -- 866
				startViewX = viewX, -- 867
				startViewY = viewY, -- 868
				curViewX = viewX, -- 869
				curViewY = viewY, -- 870
				startOvX = ov.x, -- 871
				startOvY = ov.y, -- 872
				curOvX = ov.x, -- 873
				curOvY = ov.y, -- 874
				movedDistOv = 0 -- 875
			} -- 875
			if zone.id == "pause" then -- 877
				self.qPausePressed = true -- 878
				self:vibrate(0.015) -- 879
			elseif zone.id == "retry" then -- 880
				self.qRetryPressed = true -- 881
				self:vibrate(0.015) -- 882
			elseif zone.id == "worldPrompt" then -- 883
				self:triggerInteractAction(id) -- 884
			else -- 884
				self.qZoneTap = zone.id -- 886
				self:vibrate(0.015) -- 887
			end -- 887
			return -- 889
		end -- 889
	end -- 889
	if self.ctx.modal or not self.ctx.gameplayActive then -- 894
		self.qHadUiTouch = true -- 895
		if self.modalFingerId < 0 and (not portrait or stage.inside) then -- 896
			self.modalFingerId = id -- 897
			self.uiX = stage.x -- 898
			self.uiY = stage.y -- 899
			self.uiPrevX = stage.x -- 900
			self.uiPrevY = stage.y -- 901
			self.uiHeld = true -- 902
			self.uiPressedQueue = true -- 903
			self.fingers[id] = { -- 904
				id = id, -- 905
				fromMouse = false, -- 906
				kind = "modal", -- 907
				startViewX = viewX, -- 908
				startViewY = viewY, -- 909
				curViewX = viewX, -- 910
				curViewY = viewY, -- 911
				startOvX = ov.x, -- 912
				startOvY = ov.y, -- 913
				curOvX = ov.x, -- 914
				curOvY = ov.y, -- 915
				movedDistOv = 0 -- 916
			} -- 916
		end -- 916
		return -- 919
	end -- 919
	if self.ctx.cutsceneBlocking then -- 923
		self.qHadUiTouch = true -- 924
		if self.ctx.inTowerEnd then -- 925
			self.qInteractPressed = true -- 926
			self:vibrate(0.015) -- 927
		end -- 927
		return -- 929
	end -- 929
	if not self.ctx.overlayActive and not self.ctx.allowAutoGameplayTouch then -- 932
		return -- 933
	end -- 933
	self.qHadGameplayTouch = true -- 935
	local ____portrait_16 -- 937
	if portrait then -- 937
		____portrait_16 = viewY < vp.deckH and ov.x <= self.ctx.stickZoneMaxX -- 938
	else -- 938
		____portrait_16 = ov.x <= self.ctx.stickZoneMaxX and ov.y <= self.ctx.stickZoneMaxY -- 939
	end -- 939
	local inStickZone = ____portrait_16 -- 937
	if self.stickFingerId < 0 and inStickZone then -- 940
		self:startStick( -- 941
			id, -- 941
			viewX, -- 941
			viewY, -- 941
			ov.x, -- 941
			ov.y, -- 941
			false -- 941
		) -- 941
		return -- 942
	end -- 942
	local ovH = vp.fullH / math.max(0.25, self.ctx.overlayScale) -- 945
	local allowStageShoot = stage.inside and (portrait or ov.y <= ovH - 84) -- 946
	if self.ctx.canShoot and self.aimCanvasFingerId < 0 and allowStageShoot then -- 947
		self.aimCanvasFingerId = id -- 948
		local assisted = snapPointAim( -- 949
			stage.x, -- 950
			stage.y, -- 951
			self.ctx.enemyTargets, -- 952
			44 * vp.uiScale, -- 953
			self.settings.aimAssist -- 954
		) -- 954
		self.aimX = assisted.x -- 956
		self.aimY = assisted.y -- 957
		self.hasAim = true -- 958
		self.qFirePressed = true -- 959
		self:vibrate(0.016) -- 960
		self.fingers[id] = { -- 961
			id = id, -- 962
			fromMouse = false, -- 963
			kind = "aim_canvas", -- 964
			startViewX = viewX, -- 965
			startViewY = viewY, -- 966
			curViewX = viewX, -- 967
			curViewY = viewY, -- 968
			startOvX = ov.x, -- 969
			startOvY = ov.y, -- 970
			curOvX = ov.x, -- 971
			curOvY = ov.y, -- 972
			movedDistOv = 0 -- 973
		} -- 973
	end -- 973
end -- 781
function TouchRouter.prototype.startStick(self, id, viewX, viewY, ovX, ovY, fromMouse) -- 978
	local vp = self.ctx.viewport -- 986
	local r = self.ctx.stickMaxR -- 987
	local ox = self.ctx.stickDefaultX -- 988
	local oy = self.ctx.stickDefaultY -- 989
	if not self.ctx.stickFixedOrigin then -- 990
		local safeL = vp.safe.left / math.max(0.25, self.ctx.overlayScale) -- 991
		local safeB = vp.safe.bottom / math.max(0.25, self.ctx.overlayScale) -- 992
		ox = clamp( -- 993
			ovX, -- 993
			safeL + r + 14, -- 993
			math.max(safeL + r + 14, self.ctx.stickZoneMaxX - 18) -- 993
		) -- 993
		oy = clamp( -- 994
			ovY, -- 994
			safeB + r + 14, -- 994
			math.max(safeB + r + 14, self.ctx.stickZoneMaxY - r * 0.6) -- 994
		) -- 994
	end -- 994
	self.stickFingerId = id -- 996
	self.stickOriginX = ox -- 997
	self.stickOriginY = oy -- 998
	self.stickKnobX = ovX -- 999
	self.stickKnobY = ovY -- 1000
	self.fingers[id] = { -- 1001
		id = id, -- 1002
		fromMouse = fromMouse, -- 1003
		kind = "stick", -- 1004
		startViewX = viewX, -- 1005
		startViewY = viewY, -- 1006
		curViewX = viewX, -- 1007
		curViewY = viewY, -- 1008
		startOvX = ovX, -- 1009
		startOvY = ovY, -- 1010
		curOvX = ovX, -- 1011
		curOvY = ovY, -- 1012
		movedDistOv = 0 -- 1013
	} -- 1013
	self:updateStickFromOverlay(ovX, ovY) -- 1015
end -- 978
function TouchRouter.prototype.triggerInteractAction(self, id) -- 1018
	if self.ctx.cartNearby then -- 1019
		if self.cartGripLatched or self.ctx.cartGripping then -- 1020
			self.cartGripLatched = false -- 1021
			self.cartGripSeenActive = false -- 1022
			if self.ctx.cartUsesToggle then -- 1023
				self.qInteractPressed = true -- 1024
			end -- 1024
		else -- 1024
			self.cartGripLatched = true -- 1027
			self.cartGripSeenActive = false -- 1028
			self.qInteractPressed = true -- 1029
		end -- 1029
		self:vibrate(0.018) -- 1031
		return -- 1032
	end -- 1032
	self.interactFingerId = id -- 1034
	self.qInteractPressed = true -- 1035
	self:vibrate(0.015) -- 1036
end -- 1018
function TouchRouter.prototype.onButtonPressed(self, btn, id, ovX, ovY, fromMouse) -- 1039
	local vp = self.ctx.viewport -- 1046
	if btn.id == "interact" then -- 1047
		self:triggerInteractAction(id) -- 1048
	elseif btn.id == "jump" then -- 1049
		if self.ctx.childMode and self.crouchToggled and not self.ctx.inLowArch then -- 1050
			self.crouchToggled = false -- 1051
		end -- 1051
		self.jumpFingerId = id -- 1053
		self.qJumpPressed = true -- 1054
		if not fromMouse then -- 1055
			self:vibrate(0.014) -- 1055
		end -- 1055
	elseif btn.id == "cover" then -- 1056
		if self.ctx.childMode then -- 1057
			self.slowToggled = not self.slowToggled -- 1058
		else -- 1058
			self.coverToggled = not self.coverToggled -- 1060
			self.coverNearSeen = self.ctx.coverNear -- 1061
		end -- 1061
		if not fromMouse then -- 1063
			self:vibrate(0.012) -- 1063
		end -- 1063
	elseif btn.id == "crouch" then -- 1064
		self.crouchToggled = not self.crouchToggled -- 1065
		if not fromMouse then -- 1066
			self:vibrate(0.012) -- 1066
		end -- 1066
	elseif btn.id == "artifact" then -- 1067
		self.qArtifactPressed = true -- 1068
		if not fromMouse then -- 1069
			self:vibrate(0.02) -- 1069
		end -- 1069
	elseif btn.id == "pause" then -- 1070
		self.qPausePressed = true -- 1071
		if not fromMouse then -- 1072
			self:vibrate(0.014) -- 1072
		end -- 1072
	elseif btn.id == "retry" then -- 1073
		self.qRetryPressed = true -- 1074
		if not fromMouse then -- 1075
			self:vibrate(0.016) -- 1075
		end -- 1075
	elseif btn.id == "mute" then -- 1076
		self.qMutePressed = true -- 1077
	elseif btn.id == "fullscreen" then -- 1078
		self.qFullscreenPressed = true -- 1079
	elseif btn.id == "nav_up" then -- 1080
		self.qNavUp = true -- 1081
	elseif btn.id == "nav_down" then -- 1082
		self.qNavDown = true -- 1083
	elseif btn.id == "nav_left" then -- 1084
		self.qNavLeft = true -- 1085
	elseif btn.id == "nav_right" then -- 1086
		self.qNavRight = true -- 1087
	elseif btn.id == "nav_confirm" then -- 1088
		self.qNavConfirm = true -- 1089
	elseif btn.id == "nav_back" then -- 1090
		self.qNavBack = true -- 1091
	elseif btn.id == "fire" then -- 1092
		self.fireFingerId = id -- 1093
		self.fireStickDragging = false -- 1094
		self.fireOriginX = btn.x -- 1095
		self.fireOriginY = btn.y -- 1096
		self.fireKnobX = btn.x -- 1097
		self.fireKnobY = btn.y -- 1098
		local smart = pickSmartFireTarget( -- 1099
			self.ctx.playerScreenX, -- 1100
			self.ctx.playerScreenY, -- 1101
			self.stickMoveX < 0 and -1 or (self.stickMoveX > 0 and 1 or self.ctx.playerFacing), -- 1102
			vp.stageW, -- 1103
			vp.stageH, -- 1104
			vp.uiScale, -- 1105
			self.ctx.enemyTargets, -- 1106
			self.settings.aimAssist, -- 1107
			self.hasAim and ({x = self.aimX, y = self.aimY}) or nil -- 1108
		) -- 1108
		self.aimX = smart.x -- 1110
		self.aimY = smart.y -- 1111
		self.hasAim = true -- 1112
		if not fromMouse then -- 1113
			self:vibrate(0.012) -- 1113
		end -- 1113
	elseif btn.id == "bottle" then -- 1114
		self.bottleFingerId = id -- 1115
		self.bottleOriginOvX = btn.x -- 1116
		self.bottleOriginOvY = btn.y -- 1117
		self.bottleCancelHover = false -- 1118
		self.bottleFingerOvX = ovX -- 1119
		self.bottleFingerOvY = ovY -- 1120
		local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1121
		self.aimX = clamp( -- 1122
			self.ctx.playerScreenX + dir * 180 * vp.uiScale, -- 1122
			24, -- 1122
			math.max(48, vp.stageW - 24) -- 1122
		) -- 1122
		self.aimY = clamp( -- 1123
			self.ctx.playerScreenY - 18 * vp.uiScale, -- 1123
			20, -- 1123
			math.max(40, vp.stageH - 48) -- 1123
		) -- 1123
		self.hasAim = true -- 1124
		if not fromMouse then -- 1125
			self:vibrate(0.015) -- 1125
		end -- 1125
	end -- 1125
end -- 1039
function TouchRouter.prototype.updateStickFromOverlay(self, ovX, ovY) -- 1129
	local maxR = math.max(24, self.ctx.stickMaxR) -- 1130
	local dead = maxR * STICK_DEAD_RATIO -- 1131
	local dx = ovX - self.stickOriginX -- 1132
	local dy = ovY - self.stickOriginY -- 1133
	local dist = hypot(dx, dy) -- 1134
	if dist <= 0.001 then -- 1135
		self.stickKnobX = self.stickOriginX -- 1136
		self.stickKnobY = self.stickOriginY -- 1137
		self.stickMoveX = 0 -- 1138
		self.stickMoveY = 0 -- 1139
		self.stickSlow = false -- 1140
		return -- 1141
	end -- 1141
	local clamped = math.min(dist, maxR) -- 1143
	self.stickKnobX = self.stickOriginX + dx / dist * clamped -- 1144
	self.stickKnobY = self.stickOriginY + dy / dist * clamped -- 1145
	if dist < dead then -- 1147
		self.stickMoveX = 0 -- 1148
		self.stickMoveY = 0 -- 1149
		self.stickSlow = false -- 1150
		return -- 1151
	end -- 1151
	local nx = dx / dist * (clamped / maxR) -- 1153
	local ny = dy / dist * (clamped / maxR) -- 1154
	self.stickMoveX = math.abs(nx) >= 0.22 and (nx > 0 and 1 or -1) or 0 -- 1156
	if self.ctx.allowDepth then -- 1157
		self.stickMoveY = math.abs(ny) >= 0.3 and (ny > 0 and -1 or 1) or 0 -- 1158
	else -- 1158
		self.stickMoveY = 0 -- 1160
	end -- 1160
	self.stickSlow = self.ctx.childMode and self.stickMoveX ~= 0 and clamped < maxR * 0.56 -- 1162
end -- 1129
function TouchRouter.prototype.handleTouchMoved(self, id, viewX, viewY, fromMouse) -- 1165
	local f = self.fingers[id] -- 1166
	if f == nil then -- 1167
		return -- 1168
	end -- 1168
	if self.enableMouseCompat then -- 1170
		if not fromMouse then -- 1171
			self.lastRealTouchClock = self.clockSec -- 1172
		else -- 1172
			self.qMouseConsumed = true -- 1174
		end -- 1174
	end -- 1174
	local vp = self.ctx.viewport -- 1177
	local portrait = self.enablePortrait and vp.isPortrait -- 1178
	local ov = self:toOverlay(viewX, viewY) -- 1179
	f.movedDistOv = f.movedDistOv + hypot(ov.x - f.curOvX, ov.y - f.curOvY) -- 1180
	f.curViewX = viewX -- 1181
	f.curViewY = viewY -- 1182
	f.curOvX = ov.x -- 1183
	f.curOvY = ov.y -- 1184
	if f.kind == "modal" and self.modalFingerId == id then -- 1186
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1187
		self.uiX = stage.x -- 1188
		self.uiY = stage.y -- 1189
		return -- 1190
	end -- 1190
	if f.kind == "stick" and self.stickFingerId == id then -- 1193
		self:updateStickFromOverlay(ov.x, ov.y) -- 1194
		return -- 1195
	end -- 1195
	if f.kind == "aim_canvas" and self.aimCanvasFingerId == id then -- 1198
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1199
		local assisted = snapPointAim( -- 1200
			clamp( -- 1201
				stage.x, -- 1201
				8, -- 1201
				math.max(16, vp.stageW - 8) -- 1201
			), -- 1201
			clamp( -- 1202
				stage.y, -- 1202
				8, -- 1202
				math.max(16, vp.stageH - 8) -- 1202
			), -- 1202
			self.ctx.enemyTargets, -- 1203
			34 * vp.uiScale, -- 1204
			self.settings.aimAssist -- 1205
		) -- 1205
		self.aimX = assisted.x -- 1207
		self.aimY = assisted.y -- 1208
		self.hasAim = true -- 1209
		return -- 1210
	end -- 1210
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1213
		local maxR = FIRE_STICK_MAX_R_OV * self.settings.touchScale -- 1214
		local dx = ov.x - self.fireOriginX -- 1215
		local dy = ov.y - self.fireOriginY -- 1216
		local dist = hypot(dx, dy) -- 1217
		local clamped = math.min(dist, maxR) -- 1218
		self.fireKnobX = dist > 0.001 and self.fireOriginX + dx / dist * clamped or self.fireOriginX -- 1219
		self.fireKnobY = dist > 0.001 and self.fireOriginY + dy / dist * clamped or self.fireOriginY -- 1220
		if dist >= FIRE_STICK_DRAG_THRESHOLD_OV * self.settings.touchScale then -- 1221
			self.fireStickDragging = true -- 1222
			f.firedOnDrag = true -- 1223
			local pt = snapConeAim( -- 1224
				self.ctx.playerScreenX, -- 1225
				self.ctx.playerScreenY, -- 1226
				dx / dist, -- 1227
				dy / dist, -- 1228
				260 * vp.uiScale, -- 1229
				vp.stageW, -- 1230
				vp.stageH, -- 1231
				self.ctx.enemyTargets, -- 1232
				self.settings.aimAssist -- 1233
			) -- 1233
			self.aimX = pt.x -- 1235
			self.aimY = pt.y -- 1236
			self.hasAim = true -- 1237
		end -- 1237
		return -- 1239
	end -- 1239
	if f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1242
		self.bottleFingerOvX = ov.x -- 1243
		self.bottleFingerOvY = ov.y -- 1244
		local cancel = self.ctx.bottleCancelCenter -- 1245
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1246
		self.bottleCancelHover = dCancel <= cancel.r -- 1247
		if not self.bottleCancelHover then -- 1248
			local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1249
			if portrait and not stage.inside then -- 1250
				local dx = ov.x - self.bottleOriginOvX -- 1251
				local dy = ov.y - self.bottleOriginOvY -- 1252
				local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1253
				local baseForward = dir * math.min(180 * vp.uiScale, vp.stageW * 0.28) -- 1254
				self.aimX = clamp( -- 1255
					self.ctx.playerScreenX + baseForward + dx * 2.2, -- 1255
					16, -- 1255
					math.max(32, vp.stageW - 16) -- 1255
				) -- 1255
				self.aimY = clamp( -- 1256
					self.ctx.playerScreenY + dy * 1.4, -- 1256
					16, -- 1256
					math.max(32, vp.stageH - 16) -- 1256
				) -- 1256
			else -- 1256
				self.aimX = clamp( -- 1258
					stage.x, -- 1258
					16, -- 1258
					math.max(32, vp.stageW - 16) -- 1258
				) -- 1258
				self.aimY = clamp( -- 1259
					stage.y + BOTTLE_AIM_Y_OFFSET_UI * vp.uiScale, -- 1259
					16, -- 1259
					math.max(32, vp.stageH - 28) -- 1259
				) -- 1259
			end -- 1259
			self.hasAim = true -- 1261
		end -- 1261
	end -- 1261
end -- 1165
function TouchRouter.prototype.handleTouchEnded(self, id, viewX, viewY, fromMouse) -- 1266
	local f = self.fingers[id] -- 1267
	if f == nil then -- 1268
		return -- 1269
	end -- 1269
	if self.enableMouseCompat then -- 1271
		if not fromMouse then -- 1272
			self.lastRealTouchClock = self.clockSec -- 1273
		else -- 1273
			self.qMouseConsumed = true -- 1275
		end -- 1275
	end -- 1275
	local vp = self.ctx.viewport -- 1278
	local portrait = self.enablePortrait and vp.isPortrait -- 1279
	local ov = self:toOverlay(viewX, viewY) -- 1280
	if f.kind == "modal" and self.modalFingerId == id then -- 1281
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1282
		self.uiX = stage.x -- 1283
		self.uiY = stage.y -- 1284
		self.uiHeld = false -- 1285
		self.uiReleasedQueue = true -- 1286
		self.modalFingerId = -1 -- 1287
		__TS__Delete(self.fingers, id) -- 1288
		return -- 1289
	end -- 1289
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1292
		if self.ctx.canShoot then -- 1293
			self.qFirePressed = true -- 1294
			if not fromMouse then -- 1295
				self:vibrate(0.016) -- 1295
			end -- 1295
		end -- 1295
	elseif f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1297
		local cancel = self.ctx.bottleCancelCenter -- 1298
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1299
		if dCancel <= cancel.r then -- 1300
			self.qBottleCanceled = true -- 1301
			if not fromMouse then -- 1302
				self:vibrate(0.012) -- 1302
			end -- 1302
		end -- 1302
	end -- 1302
	self:releaseFingerById(id) -- 1306
end -- 1266
return ____exports -- 1266
