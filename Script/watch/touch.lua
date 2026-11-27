-- [ts]: touch.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 15
local Node = ____Dora.Node -- 15
local Size = ____Dora.Size -- 15
local Vec2 = ____Dora.Vec2 -- 15
local ____aim_assist = require("Script.watch.aim_assist") -- 16
local pickSmartFireTarget = ____aim_assist.pickSmartFireTarget -- 18
local snapConeAim = ____aim_assist.snapConeAim -- 19
local snapPointAim = ____aim_assist.snapPointAim -- 20
local ____controls_config = require("Script.watch.controls_config") -- 22
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 24
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 25
local defaultControlSettings = ____controls_config.defaultControlSettings -- 26
local nextStepValue = ____controls_config.nextStepValue -- 27
local saveControlSettings = ____controls_config.saveControlSettings -- 28
local ____platform = require("Script.watch.platform") -- 30
local computeStageViewport = ____platform.computeStageViewport -- 32
local triggerHaptics = ____platform.triggerHaptics -- 33
local viewToStage = ____platform.viewToStage -- 34
local STICK_DEAD_RATIO = 0.18 -- 243
local FIRE_STICK_DRAG_THRESHOLD_OV = 16 -- 244
local FIRE_STICK_MAX_R_OV = 54 -- 245
local BOTTLE_AIM_Y_OFFSET_UI = 52 -- 246
local SYNTHETIC_MOUSE_COOLDOWN_SEC = 0.25 -- 247
local function clamp(v, lo, hi) -- 249
	return v < lo and lo or (v > hi and hi or v) -- 250
end -- 249
local function hypot(dx, dy) -- 253
	return math.sqrt(dx * dx + dy * dy) -- 254
end -- 253
local function isInstantUiButton(id) -- 257
	return id == "pause" or id == "retry" or id == "mute" or id == "fullscreen" or id == "nav_up" or id == "nav_down" or id == "nav_left" or id == "nav_right" or id == "nav_confirm" or id == "nav_back" -- 258
end -- 257
____exports.TouchRouter = __TS__Class() -- 270
local TouchRouter = ____exports.TouchRouter -- 270
TouchRouter.name = "TouchRouter" -- 270
function TouchRouter.prototype.____constructor(self, sharedSettings) -- 386
	self.fingers = {} -- 273
	self.ctx = { -- 275
		viewport = computeStageViewport(1280, 720), -- 276
		overlayScale = 1, -- 277
		overlayActive = false, -- 278
		allowAutoGameplayTouch = true, -- 279
		allowMouseOnOverlay = false, -- 280
		modal = true, -- 281
		gameplayActive = false, -- 282
		cutsceneBlocking = false, -- 283
		childMode = false, -- 284
		allowDepth = false, -- 285
		canShoot = false, -- 286
		canBottleAim = false, -- 287
		cartNearby = false, -- 288
		cartGripping = false, -- 289
		cartUsesToggle = false, -- 290
		coverNear = false, -- 291
		playerRolling = false, -- 292
		inLowArch = false, -- 293
		inTowerEnd = false, -- 294
		playerFacing = 1, -- 295
		playerScreenX = 640, -- 296
		playerScreenY = 240, -- 297
		enemyTargets = {}, -- 298
		stickZoneMaxX = 560, -- 299
		stickZoneMaxY = 600, -- 300
		stickDefaultX = 148, -- 301
		stickDefaultY = 144, -- 302
		stickMaxR = 64, -- 303
		stickFixedOrigin = false, -- 304
		buttons = {}, -- 305
		rectZones = {}, -- 306
		bottleCancelCenter = {x = 1120, y = 120, r = 44} -- 307
	} -- 307
	self.stickFingerId = -1 -- 311
	self.stickOriginX = 148 -- 312
	self.stickOriginY = 144 -- 313
	self.stickKnobX = 148 -- 314
	self.stickKnobY = 144 -- 315
	self.stickMoveX = 0 -- 316
	self.stickMoveY = 0 -- 317
	self.stickSlow = false -- 318
	self.coverToggled = false -- 321
	self.crouchToggled = false -- 322
	self.slowToggled = false -- 323
	self.cartGripLatched = false -- 324
	self.cartGripSeenActive = false -- 325
	self.coverNearSeen = false -- 326
	self.interactFingerId = -1 -- 329
	self.jumpFingerId = -1 -- 330
	self.fireFingerId = -1 -- 331
	self.fireStickDragging = false -- 332
	self.fireOriginX = 1110 -- 333
	self.fireOriginY = 154 -- 334
	self.fireKnobX = 1110 -- 335
	self.fireKnobY = 154 -- 336
	self.bottleFingerId = -1 -- 337
	self.bottleOriginOvX = 0 -- 338
	self.bottleOriginOvY = 0 -- 339
	self.bottleCancelHover = false -- 340
	self.bottleFingerOvX = 0 -- 341
	self.bottleFingerOvY = 0 -- 342
	self.aimCanvasFingerId = -1 -- 343
	self.modalFingerId = -1 -- 346
	self.uiX = 0 -- 347
	self.uiY = 0 -- 348
	self.uiPrevX = 0 -- 349
	self.uiPrevY = 0 -- 350
	self.uiHeld = false -- 351
	self.uiPressedQueue = false -- 352
	self.uiReleasedQueue = false -- 353
	self.hasAim = false -- 356
	self.aimX = 640 -- 357
	self.aimY = 300 -- 358
	self.qHadRealTouch = false -- 361
	self.qHadGameplayTouch = false -- 362
	self.qHadUiTouch = false -- 363
	self.qAnyTapBegan = false -- 364
	self.qMouseConsumed = false -- 365
	self.qJumpPressed = false -- 366
	self.qInteractPressed = false -- 367
	self.qFirePressed = false -- 368
	self.qPausePressed = false -- 369
	self.qRetryPressed = false -- 370
	self.qArtifactPressed = false -- 371
	self.qMutePressed = false -- 372
	self.qFullscreenPressed = false -- 373
	self.qBottleCanceled = false -- 374
	self.qNavUp = false -- 375
	self.qNavDown = false -- 376
	self.qNavLeft = false -- 377
	self.qNavRight = false -- 378
	self.qNavConfirm = false -- 379
	self.qNavBack = false -- 380
	self.qZoneTap = "" -- 381
	self.clockSec = 10 -- 383
	self.lastRealTouchClock = -10 -- 384
	self.settings = sharedSettings ~= nil and sharedSettings or defaultControlSettings() -- 387
end -- 386
function TouchRouter.prototype.attach(self, parent) -- 390
	if self.listenerNode ~= nil then -- 390
		return -- 392
	end -- 392
	local n = Node() -- 394
	n.size = Size(0, 0) -- 395
	n.position = Vec2(0, 0) -- 396
	n.order = 120 -- 397
	n.swallowTouches = false -- 398
	n.touchEnabled = true -- 399
	n:onTapBegan(function(touch) -- 400
		local loc = touch.viewLocation -- 401
		self:handleTouchBegan(touch.id, loc.x, loc.y, touch.fromMouse) -- 402
	end) -- 400
	n:onTapMoved(function(touch) -- 404
		local loc = touch.viewLocation -- 405
		self:handleTouchMoved(touch.id, loc.x, loc.y, touch.fromMouse) -- 406
	end) -- 404
	n:onTapEnded(function(touch) -- 408
		local loc = touch.viewLocation -- 409
		self:handleTouchEnded(touch.id, loc.x, loc.y, touch.fromMouse) -- 410
	end) -- 408
	n:addTo(parent) -- 412
	self.listenerNode = n -- 413
end -- 390
function TouchRouter.prototype.injectTouch(self, phase, id, viewX, viewY, fromMouse) -- 417
	if fromMouse == nil then -- 417
		fromMouse = false -- 422
	end -- 422
	if phase == "began" then -- 422
		self:handleTouchBegan(id, viewX, viewY, fromMouse) -- 425
	elseif phase == "moved" then -- 425
		self:handleTouchMoved(id, viewX, viewY, fromMouse) -- 427
	else -- 427
		self:handleTouchEnded(id, viewX, viewY, fromMouse) -- 429
	end -- 429
end -- 417
function TouchRouter.prototype.cycleOpacity(self) -- 433
	self.settings.touchOpacity = nextStepValue(self.settings.touchOpacity, TOUCH_OPACITY_STEPS, 1) -- 434
	saveControlSettings(self.settings) -- 435
	return self.settings.touchOpacity -- 436
end -- 433
function TouchRouter.prototype.cycleScale(self) -- 439
	self.settings.touchScale = nextStepValue(self.settings.touchScale, TOUCH_SCALE_STEPS, 1) -- 440
	saveControlSettings(self.settings) -- 441
	return self.settings.touchScale -- 442
end -- 439
function TouchRouter.prototype.toggleAimAssist(self) -- 445
	self.settings.aimAssist = not self.settings.aimAssist -- 446
	saveControlSettings(self.settings) -- 447
	return self.settings.aimAssist -- 448
end -- 445
function TouchRouter.prototype.toggleHaptics(self) -- 451
	self.settings.haptics = not self.settings.haptics -- 452
	saveControlSettings(self.settings) -- 453
	if self.settings.haptics then -- 453
		self:vibrate(0.018) -- 455
	end -- 455
	return self.settings.haptics -- 457
end -- 451
function TouchRouter.prototype.vibrate(self, seconds) -- 460
	triggerHaptics(seconds, self.settings.haptics) -- 461
end -- 460
function TouchRouter.prototype.isSuppressingSyntheticMouse(self) -- 465
	if self:hasActiveRealFinger() then -- 465
		return true -- 467
	end -- 467
	return self.clockSec - self.lastRealTouchClock < SYNTHETIC_MOUSE_COOLDOWN_SEC -- 469
end -- 465
function TouchRouter.prototype.hasActiveRealFinger(self) -- 472
	for k in pairs(self.fingers) do -- 473
		local f = self.fingers[k] -- 474
		if f ~= nil and not f.fromMouse then -- 474
			return true -- 476
		end -- 476
	end -- 476
	return false -- 479
end -- 472
function TouchRouter.prototype.hasActiveMouseOverlayFinger(self) -- 482
	for k in pairs(self.fingers) do -- 483
		local f = self.fingers[k] -- 484
		if f ~= nil and f.fromMouse then -- 484
			return true -- 486
		end -- 486
	end -- 486
	return false -- 489
end -- 482
function TouchRouter.prototype.setFrameContext(self, next, dt) -- 492
	self.clockSec = self.clockSec + math.min( -- 493
		0.05, -- 493
		math.max(0, dt) -- 493
	) -- 493
	local wasModal = self.ctx.modal -- 494
	local wasCutscene = self.ctx.cutsceneBlocking -- 495
	self.ctx = next -- 496
	if not wasModal and next.modal or not wasCutscene and next.cutsceneBlocking then -- 496
		self:releaseGameplayFingers() -- 499
	end -- 499
	if next.playerRolling then -- 499
		self.coverToggled = false -- 503
	end -- 503
	if self.coverToggled then -- 503
		if next.coverNear then -- 503
			self.coverNearSeen = true -- 507
		elseif self.coverNearSeen then -- 507
			self.coverToggled = false -- 509
			self.coverNearSeen = false -- 510
		end -- 510
	else -- 510
		self.coverNearSeen = false -- 513
	end -- 513
	if self.cartGripLatched then -- 513
		if next.cartGripping then -- 513
			self.cartGripSeenActive = true -- 518
		elseif not next.cartNearby or self.cartGripSeenActive then -- 518
			self.cartGripLatched = false -- 520
			self.cartGripSeenActive = false -- 521
		end -- 521
	else -- 521
		self.cartGripSeenActive = false -- 524
	end -- 524
	if not next.canBottleAim and self.bottleFingerId >= 0 then -- 524
		self:releaseFingerById(self.bottleFingerId) -- 528
	end -- 528
	if next.childMode then -- 528
		self.coverToggled = false -- 532
	else -- 532
		self.crouchToggled = false -- 534
		self.slowToggled = false -- 535
	end -- 535
end -- 492
function TouchRouter.prototype.releaseAll(self, keepToggles) -- 539
	if keepToggles == nil then -- 539
		keepToggles = false -- 539
	end -- 539
	self.fingers = {} -- 540
	self.stickFingerId = -1 -- 541
	self.stickMoveX = 0 -- 542
	self.stickMoveY = 0 -- 543
	self.stickSlow = false -- 544
	self.interactFingerId = -1 -- 545
	self.jumpFingerId = -1 -- 546
	self.fireFingerId = -1 -- 547
	self.fireStickDragging = false -- 548
	self.bottleFingerId = -1 -- 549
	self.bottleCancelHover = false -- 550
	self.aimCanvasFingerId = -1 -- 551
	self.modalFingerId = -1 -- 552
	self.uiHeld = false -- 553
	self.uiPressedQueue = false -- 554
	self.uiReleasedQueue = false -- 555
	if not keepToggles then -- 555
		self.coverToggled = false -- 557
		self.crouchToggled = false -- 558
		self.slowToggled = false -- 559
		self.cartGripLatched = false -- 560
		self.cartGripSeenActive = false -- 561
		self.coverNearSeen = false -- 562
		self.hasAim = false -- 563
	end -- 563
end -- 539
function TouchRouter.prototype.clearRoomStates(self) -- 567
	self:releaseAll(false) -- 568
	self.qJumpPressed = false -- 569
	self.qInteractPressed = false -- 570
	self.qFirePressed = false -- 571
	self.qPausePressed = false -- 572
	self.qRetryPressed = false -- 573
	self.qArtifactPressed = false -- 574
	self.qMutePressed = false -- 575
	self.qFullscreenPressed = false -- 576
	self.qBottleCanceled = false -- 577
	self.qNavUp = false -- 578
	self.qNavDown = false -- 579
	self.qNavLeft = false -- 580
	self.qNavRight = false -- 581
	self.qNavConfirm = false -- 582
	self.qNavBack = false -- 583
	self.qZoneTap = "" -- 584
end -- 567
function TouchRouter.prototype.releaseGameplayFingers(self) -- 587
	local ids = {} -- 588
	for k in pairs(self.fingers) do -- 589
		local f = self.fingers[k] -- 590
		if f ~= nil and f.kind ~= "modal" then -- 590
			ids[#ids + 1] = f.id -- 592
		end -- 592
	end -- 592
	local i = 0 -- 595
	do -- 595
		i = 0 -- 596
		while i < #ids do -- 596
			self:releaseFingerById(ids[i + 1]) -- 597
			i = i + 1 -- 596
		end -- 596
	end -- 596
end -- 587
function TouchRouter.prototype.releaseFingerById(self, id) -- 601
	local f = self.fingers[id] -- 602
	if f == nil then -- 602
		return -- 603
	end -- 603
	__TS__Delete(self.fingers, id) -- 604
	if self.stickFingerId == id then -- 604
		self.stickFingerId = -1 -- 606
		self.stickMoveX = 0 -- 607
		self.stickMoveY = 0 -- 608
		self.stickSlow = false -- 609
	end -- 609
	if self.interactFingerId == id then -- 609
		self.interactFingerId = -1 -- 611
	end -- 611
	if self.jumpFingerId == id then -- 611
		self.jumpFingerId = -1 -- 612
	end -- 612
	if self.fireFingerId == id then -- 612
		self.fireFingerId = -1 -- 614
		self.fireStickDragging = false -- 615
	end -- 615
	if self.bottleFingerId == id then -- 615
		self.bottleFingerId = -1 -- 618
		self.bottleCancelHover = false -- 619
	end -- 619
	if self.aimCanvasFingerId == id then -- 619
		self.aimCanvasFingerId = -1 -- 621
	end -- 621
	if self.modalFingerId == id then -- 621
		self.modalFingerId = -1 -- 623
		self.uiHeld = false -- 624
	end -- 624
end -- 601
function TouchRouter.prototype.getStickVisual(self) -- 628
	local r = self.ctx.stickMaxR -- 629
	if self.stickFingerId >= 0 then -- 629
		return { -- 631
			active = true, -- 632
			originX = self.stickOriginX, -- 633
			originY = self.stickOriginY, -- 634
			knobX = self.stickKnobX, -- 635
			knobY = self.stickKnobY, -- 636
			radius = r, -- 637
			slowZone = self.stickSlow, -- 638
			allowDepth = self.ctx.allowDepth -- 639
		} -- 639
	end -- 639
	return { -- 642
		active = false, -- 643
		originX = self.ctx.stickDefaultX, -- 644
		originY = self.ctx.stickDefaultY, -- 645
		knobX = self.ctx.stickDefaultX, -- 646
		knobY = self.ctx.stickDefaultY, -- 647
		radius = r, -- 648
		slowZone = false, -- 649
		allowDepth = self.ctx.allowDepth -- 650
	} -- 650
end -- 628
function TouchRouter.prototype.getFireStickVisual(self) -- 654
	return { -- 655
		active = self.fireFingerId >= 0, -- 656
		dragging = self.fireStickDragging, -- 657
		originX = self.fireOriginX, -- 658
		originY = self.fireOriginY, -- 659
		knobX = self.fireKnobX, -- 660
		knobY = self.fireKnobY, -- 661
		radius = FIRE_STICK_MAX_R_OV * self.settings.touchScale -- 662
	} -- 662
end -- 654
function TouchRouter.prototype.getBottleDragVisual(self) -- 666
	return { -- 667
		active = self.bottleFingerId >= 0, -- 668
		cancelHover = self.bottleCancelHover, -- 669
		cancelX = self.ctx.bottleCancelCenter.x, -- 670
		cancelY = self.ctx.bottleCancelCenter.y, -- 671
		cancelR = self.ctx.bottleCancelCenter.r, -- 672
		fingerOvX = self.bottleFingerOvX, -- 673
		fingerOvY = self.bottleFingerOvY -- 674
	} -- 674
end -- 666
function TouchRouter.prototype.isButtonHeld(self, id) -- 678
	if id == "interact" then -- 678
		return self.interactFingerId >= 0 or self.cartGripLatched -- 679
	end -- 679
	if id == "jump" then -- 679
		return self.jumpFingerId >= 0 -- 680
	end -- 680
	if id == "fire" then -- 680
		return self.fireFingerId >= 0 -- 681
	end -- 681
	if id == "bottle" then -- 681
		return self.bottleFingerId >= 0 -- 682
	end -- 682
	if id == "cover" then -- 682
		local ____table_ctx_childMode_0 -- 683
		if self.ctx.childMode then -- 683
			____table_ctx_childMode_0 = self.slowToggled -- 683
		else -- 683
			____table_ctx_childMode_0 = self.coverToggled -- 683
		end -- 683
		return ____table_ctx_childMode_0 -- 683
	end -- 683
	if id == "crouch" then -- 683
		return self.crouchToggled -- 684
	end -- 684
	return false -- 685
end -- 678
function TouchRouter.prototype.consumeSnapshot(self) -- 688
	local uiDx = self.uiX - self.uiPrevX -- 689
	local uiDy = self.uiY - self.uiPrevY -- 690
	self.uiPrevX = self.uiX -- 691
	self.uiPrevY = self.uiY -- 692
	local cartHold = self.cartGripLatched and not self.ctx.cartUsesToggle -- 694
	local suppressSyntheticMouse = self:isSuppressingSyntheticMouse() -- 695
	local mouseConsumed = self.qMouseConsumed or self:hasActiveMouseOverlayFinger() -- 696
	local ____self_qHadRealTouch_2 = self.qHadRealTouch -- 699
	local ____self_qHadGameplayTouch_3 = self.qHadGameplayTouch -- 700
	local ____self_qHadUiTouch_4 = self.qHadUiTouch -- 701
	local ____self_qAnyTapBegan_5 = self.qAnyTapBegan -- 702
	local ____suppressSyntheticMouse_6 = suppressSyntheticMouse -- 703
	local ____self_stickMoveX_7 = self.stickMoveX -- 705
	local ____self_stickMoveY_8 = self.stickMoveY -- 706
	local ____temp_9 = self.jumpFingerId >= 0 -- 707
	local ____self_qJumpPressed_10 = self.qJumpPressed -- 708
	local ____self_crouchToggled_11 = self.crouchToggled -- 709
	local ____table_ctx_childMode_1 -- 710
	if self.ctx.childMode then -- 710
		____table_ctx_childMode_1 = self.slowToggled or self.stickSlow -- 710
	else -- 710
		____table_ctx_childMode_1 = self.coverToggled -- 710
	end -- 710
	local snap = { -- 698
		hadRealTouch = ____self_qHadRealTouch_2, -- 699
		hadGameplayTouch = ____self_qHadGameplayTouch_3, -- 700
		hadUiTouch = ____self_qHadUiTouch_4, -- 701
		anyTapBegan = ____self_qAnyTapBegan_5, -- 702
		suppressSyntheticMouse = ____suppressSyntheticMouse_6, -- 703
		mouseConsumedByOverlay = mouseConsumed, -- 704
		moveX = ____self_stickMoveX_7, -- 705
		moveY = ____self_stickMoveY_8, -- 706
		jumpHeld = ____temp_9, -- 707
		jumpPressed = ____self_qJumpPressed_10, -- 708
		crouchHeld = ____self_crouchToggled_11, -- 709
		coverHeld = ____table_ctx_childMode_1, -- 710
		interactHeld = self.interactFingerId >= 0 or cartHold, -- 711
		interactPressed = self.qInteractPressed, -- 712
		aimHeld = self.bottleFingerId >= 0, -- 713
		fireHeld = self.fireFingerId >= 0 or self.aimCanvasFingerId >= 0, -- 714
		firePressed = self.qFirePressed, -- 715
		pausePressed = self.qPausePressed, -- 716
		retryPressed = self.qRetryPressed, -- 717
		artifactPressed = self.qArtifactPressed, -- 718
		mutePressed = self.qMutePressed, -- 719
		fullscreenPressed = self.qFullscreenPressed, -- 720
		bottleCanceled = self.qBottleCanceled, -- 721
		navUp = self.qNavUp, -- 722
		navDown = self.qNavDown, -- 723
		navLeft = self.qNavLeft, -- 724
		navRight = self.qNavRight, -- 725
		navConfirm = self.qNavConfirm, -- 726
		navBack = self.qNavBack, -- 727
		hasAim = self.hasAim, -- 728
		aimX = self.aimX, -- 729
		aimY = self.aimY, -- 730
		uiHeld = self.uiHeld, -- 731
		uiPressed = self.uiPressedQueue, -- 732
		uiReleased = self.uiReleasedQueue, -- 733
		uiInside = self.uiHeld or self.uiPressedQueue or self.uiReleasedQueue, -- 734
		uiX = self.uiX, -- 735
		uiY = self.uiY, -- 736
		uiDx = uiDx, -- 737
		uiDy = uiDy, -- 738
		zoneTap = self.qZoneTap -- 739
	} -- 739
	self.qHadRealTouch = false -- 742
	self.qHadGameplayTouch = false -- 743
	self.qHadUiTouch = false -- 744
	self.qAnyTapBegan = false -- 745
	self.qMouseConsumed = false -- 746
	self.qJumpPressed = false -- 747
	self.qInteractPressed = false -- 748
	self.qFirePressed = false -- 749
	self.qPausePressed = false -- 750
	self.qRetryPressed = false -- 751
	self.qArtifactPressed = false -- 752
	self.qMutePressed = false -- 753
	self.qFullscreenPressed = false -- 754
	self.qBottleCanceled = false -- 755
	self.qNavUp = false -- 756
	self.qNavDown = false -- 757
	self.qNavLeft = false -- 758
	self.qNavRight = false -- 759
	self.qNavConfirm = false -- 760
	self.qNavBack = false -- 761
	self.qZoneTap = "" -- 762
	self.uiPressedQueue = false -- 763
	self.uiReleasedQueue = false -- 764
	return snap -- 765
end -- 688
function TouchRouter.prototype.toOverlay(self, viewX, viewY) -- 768
	local sc = math.max(0.25, self.ctx.overlayScale) -- 769
	return {x = viewX / sc, y = viewY / sc} -- 770
end -- 768
function TouchRouter.prototype.hitTestRectZones(self, ovX, ovY) -- 773
	local pt = Vec2(ovX, ovY) -- 774
	local i = 0 -- 775
	do -- 775
		i = 0 -- 776
		while i < #self.ctx.rectZones do -- 776
			local z = self.ctx.rectZones[i + 1] -- 777
			if z.rect:containsPoint(pt) then -- 777
				return z -- 779
			end -- 779
			i = i + 1 -- 776
		end -- 776
	end -- 776
	return nil -- 782
end -- 773
function TouchRouter.prototype.hitTestButtons(self, ovX, ovY) -- 785
	local pt = Vec2(ovX, ovY) -- 786
	local best -- 787
	local bestDist = 1000000000 -- 788
	local i = 0 -- 789
	do -- 789
		i = 0 -- 790
		while i < #self.ctx.buttons do -- 790
			do -- 790
				local b = self.ctx.buttons[i + 1] -- 791
				if b.rect ~= nil then -- 791
					if b.rect:containsPoint(pt) then -- 791
						return b -- 794
					end -- 794
					goto __continue82 -- 796
				end -- 796
				local hitR = b.r * 1.22 -- 798
				local d = hypot(ovX - b.x, ovY - b.y) -- 799
				if d <= hitR and d < bestDist then -- 799
					bestDist = d -- 801
					best = b -- 802
				end -- 802
			end -- 802
			::__continue82:: -- 802
			i = i + 1 -- 790
		end -- 790
	end -- 790
	return best -- 805
end -- 785
function TouchRouter.prototype.handleTouchBegan(self, id, viewX, viewY, fromMouse) -- 808
	local vp = self.ctx.viewport -- 809
	local ov = self:toOverlay(viewX, viewY) -- 810
	if fromMouse then -- 810
		if not self.ctx.allowMouseOnOverlay or not self.ctx.overlayActive then -- 810
			return -- 815
		end -- 815
		local hitBtn = self:hitTestButtons(ov.x, ov.y) -- 817
		if hitBtn ~= nil then -- 817
			self.qMouseConsumed = true -- 819
			self.fingers[id] = { -- 820
				id = id, -- 821
				fromMouse = true, -- 822
				kind = "btn", -- 823
				btnId = hitBtn.id, -- 824
				startViewX = viewX, -- 825
				startViewY = viewY, -- 826
				curViewX = viewX, -- 827
				curViewY = viewY, -- 828
				startOvX = ov.x, -- 829
				startOvY = ov.y, -- 830
				curOvX = ov.x, -- 831
				curOvY = ov.y, -- 832
				movedDistOv = 0 -- 833
			} -- 833
			self:onButtonPressed( -- 835
				hitBtn, -- 835
				id, -- 835
				viewX, -- 835
				viewY, -- 835
				ov.x, -- 835
				ov.y, -- 835
				true -- 835
			) -- 835
			return -- 836
		end -- 836
		if vp.isPortrait and self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.cutsceneBlocking and viewY < vp.deckH and ov.x <= self.ctx.stickZoneMaxX and self.stickFingerId < 0 then -- 836
			self.qMouseConsumed = true -- 840
			self:startStick( -- 841
				id, -- 841
				viewX, -- 841
				viewY, -- 841
				ov.x, -- 841
				ov.y, -- 841
				true -- 841
			) -- 841
		end -- 841
		return -- 843
	end -- 843
	self.lastRealTouchClock = self.clockSec -- 847
	self.qHadRealTouch = true -- 848
	self.qAnyTapBegan = true -- 849
	if self.ctx.overlayActive then -- 849
		local btn = self:hitTestButtons(ov.x, ov.y) -- 853
		if btn ~= nil then -- 853
			if isInstantUiButton(btn.id) then -- 853
				self.qHadUiTouch = true -- 856
			else -- 856
				self.qHadGameplayTouch = true -- 858
			end -- 858
			self.fingers[id] = { -- 860
				id = id, -- 861
				fromMouse = false, -- 862
				kind = "btn", -- 863
				btnId = btn.id, -- 864
				startViewX = viewX, -- 865
				startViewY = viewY, -- 866
				curViewX = viewX, -- 867
				curViewY = viewY, -- 868
				startOvX = ov.x, -- 869
				startOvY = ov.y, -- 870
				curOvX = ov.x, -- 871
				curOvY = ov.y, -- 872
				movedDistOv = 0 -- 873
			} -- 873
			self:onButtonPressed( -- 875
				btn, -- 875
				id, -- 875
				viewX, -- 875
				viewY, -- 875
				ov.x, -- 875
				ov.y, -- 875
				false -- 875
			) -- 875
			return -- 876
		end -- 876
	end -- 876
	local stage = viewToStage(viewX, viewY, vp) -- 880
	if self.ctx.modal or not self.ctx.gameplayActive then -- 880
		self.qHadUiTouch = true -- 884
		if self.modalFingerId < 0 and (not vp.isPortrait or stage.inside) then -- 884
			self.modalFingerId = id -- 886
			self.uiX = stage.x -- 887
			self.uiY = stage.y -- 888
			self.uiPrevX = stage.x -- 889
			self.uiPrevY = stage.y -- 890
			self.uiHeld = true -- 891
			self.uiPressedQueue = true -- 892
			self.fingers[id] = { -- 893
				id = id, -- 894
				fromMouse = false, -- 895
				kind = "modal", -- 896
				startViewX = viewX, -- 897
				startViewY = viewY, -- 898
				curViewX = viewX, -- 899
				curViewY = viewY, -- 900
				startOvX = ov.x, -- 901
				startOvY = ov.y, -- 902
				curOvX = ov.x, -- 903
				curOvY = ov.y, -- 904
				movedDistOv = 0 -- 905
			} -- 905
		end -- 905
		return -- 908
	end -- 908
	local zone = self:hitTestRectZones(ov.x, ov.y) -- 912
	if zone ~= nil then -- 912
		self.qHadUiTouch = true -- 914
		self.fingers[id] = { -- 915
			id = id, -- 916
			fromMouse = false, -- 917
			kind = "zone", -- 918
			zoneId = zone.id, -- 919
			startViewX = viewX, -- 920
			startViewY = viewY, -- 921
			curViewX = viewX, -- 922
			curViewY = viewY, -- 923
			startOvX = ov.x, -- 924
			startOvY = ov.y, -- 925
			curOvX = ov.x, -- 926
			curOvY = ov.y, -- 927
			movedDistOv = 0 -- 928
		} -- 928
		if zone.id == "pause" then -- 928
			self.qPausePressed = true -- 931
			self:vibrate(0.015) -- 932
		elseif zone.id == "retry" then -- 932
			self.qRetryPressed = true -- 934
			self:vibrate(0.015) -- 935
		elseif zone.id == "worldPrompt" then -- 935
			self:triggerInteractAction(id) -- 937
		else -- 937
			self.qZoneTap = zone.id -- 939
			self:vibrate(0.015) -- 940
		end -- 940
		return -- 942
	end -- 942
	if self.ctx.cutsceneBlocking then -- 942
		self.qHadUiTouch = true -- 947
		if self.ctx.inTowerEnd then -- 947
			self.qInteractPressed = true -- 949
			self:vibrate(0.015) -- 950
		end -- 950
		return -- 952
	end -- 952
	if not self.ctx.overlayActive and not self.ctx.allowAutoGameplayTouch then -- 952
		return -- 958
	end -- 958
	self.qHadGameplayTouch = true -- 960
	local ____vp_isPortrait_12 -- 963
	if vp.isPortrait then -- 963
		____vp_isPortrait_12 = viewY < vp.deckH and ov.x <= self.ctx.stickZoneMaxX -- 964
	else -- 964
		____vp_isPortrait_12 = ov.x <= self.ctx.stickZoneMaxX and ov.y <= self.ctx.stickZoneMaxY -- 965
	end -- 965
	local inStickZone = ____vp_isPortrait_12 -- 963
	if self.stickFingerId < 0 and inStickZone then -- 963
		self:startStick( -- 967
			id, -- 967
			viewX, -- 967
			viewY, -- 967
			ov.x, -- 967
			ov.y, -- 967
			false -- 967
		) -- 967
		return -- 968
	end -- 968
	local ovH = vp.fullH / math.max(0.25, self.ctx.overlayScale) -- 972
	local allowStageShoot = stage.inside and (vp.isPortrait or ov.y <= ovH - 84) -- 973
	if self.ctx.canShoot and self.aimCanvasFingerId < 0 and allowStageShoot then -- 973
		self.aimCanvasFingerId = id -- 975
		local assisted = snapPointAim( -- 976
			stage.x, -- 977
			stage.y, -- 978
			self.ctx.enemyTargets, -- 979
			44 * vp.uiScale, -- 980
			self.settings.aimAssist -- 981
		) -- 981
		self.aimX = assisted.x -- 983
		self.aimY = assisted.y -- 984
		self.hasAim = true -- 985
		self.qFirePressed = true -- 986
		self:vibrate(0.016) -- 987
		self.fingers[id] = { -- 988
			id = id, -- 989
			fromMouse = false, -- 990
			kind = "aim_canvas", -- 991
			startViewX = viewX, -- 992
			startViewY = viewY, -- 993
			curViewX = viewX, -- 994
			curViewY = viewY, -- 995
			startOvX = ov.x, -- 996
			startOvY = ov.y, -- 997
			curOvX = ov.x, -- 998
			curOvY = ov.y, -- 999
			movedDistOv = 0 -- 1000
		} -- 1000
	end -- 1000
end -- 808
function TouchRouter.prototype.startStick(self, id, viewX, viewY, ovX, ovY, fromMouse) -- 1005
	local vp = self.ctx.viewport -- 1013
	local r = self.ctx.stickMaxR -- 1014
	local ox = self.ctx.stickDefaultX -- 1015
	local oy = self.ctx.stickDefaultY -- 1016
	if not self.ctx.stickFixedOrigin then -- 1016
		local safeL = vp.safe.left / math.max(0.25, self.ctx.overlayScale) -- 1018
		local safeB = vp.safe.bottom / math.max(0.25, self.ctx.overlayScale) -- 1019
		ox = clamp( -- 1020
			ovX, -- 1020
			safeL + r + 14, -- 1020
			math.max(safeL + r + 14, self.ctx.stickZoneMaxX - 18) -- 1020
		) -- 1020
		oy = clamp( -- 1021
			ovY, -- 1021
			safeB + r + 14, -- 1021
			math.max(safeB + r + 14, self.ctx.stickZoneMaxY - r * 0.6) -- 1021
		) -- 1021
	end -- 1021
	self.stickFingerId = id -- 1023
	self.stickOriginX = ox -- 1024
	self.stickOriginY = oy -- 1025
	self.stickKnobX = ovX -- 1026
	self.stickKnobY = ovY -- 1027
	self.fingers[id] = { -- 1028
		id = id, -- 1029
		fromMouse = fromMouse, -- 1030
		kind = "stick", -- 1031
		startViewX = viewX, -- 1032
		startViewY = viewY, -- 1033
		curViewX = viewX, -- 1034
		curViewY = viewY, -- 1035
		startOvX = ovX, -- 1036
		startOvY = ovY, -- 1037
		curOvX = ovX, -- 1038
		curOvY = ovY, -- 1039
		movedDistOv = 0 -- 1040
	} -- 1040
	self:updateStickFromOverlay(ovX, ovY) -- 1042
end -- 1005
function TouchRouter.prototype.triggerInteractAction(self, id) -- 1045
	if self.ctx.cartNearby then -- 1045
		if self.cartGripLatched or self.ctx.cartGripping then -- 1045
			self.cartGripLatched = false -- 1048
			self.cartGripSeenActive = false -- 1049
			if self.ctx.cartUsesToggle then -- 1049
				self.qInteractPressed = true -- 1051
			end -- 1051
		else -- 1051
			self.cartGripLatched = true -- 1054
			self.cartGripSeenActive = false -- 1055
			self.qInteractPressed = true -- 1056
		end -- 1056
		self:vibrate(0.018) -- 1058
		return -- 1059
	end -- 1059
	self.interactFingerId = id -- 1061
	self.qInteractPressed = true -- 1062
	self:vibrate(0.015) -- 1063
end -- 1045
function TouchRouter.prototype.onButtonPressed(self, btn, id, _viewX, _viewY, ovX, ovY, fromMouse) -- 1066
	local vp = self.ctx.viewport -- 1075
	if btn.id == "interact" then -- 1075
		self:triggerInteractAction(id) -- 1077
	elseif btn.id == "jump" then -- 1077
		if self.ctx.childMode and self.crouchToggled and not self.ctx.inLowArch then -- 1077
			self.crouchToggled = false -- 1080
		end -- 1080
		self.jumpFingerId = id -- 1082
		self.qJumpPressed = true -- 1083
		if not fromMouse then -- 1083
			self:vibrate(0.014) -- 1084
		end -- 1084
	elseif btn.id == "cover" then -- 1084
		if self.ctx.childMode then -- 1084
			self.slowToggled = not self.slowToggled -- 1087
		else -- 1087
			self.coverToggled = not self.coverToggled -- 1089
			self.coverNearSeen = self.ctx.coverNear -- 1090
		end -- 1090
		if not fromMouse then -- 1090
			self:vibrate(0.012) -- 1092
		end -- 1092
	elseif btn.id == "crouch" then -- 1092
		self.crouchToggled = not self.crouchToggled -- 1094
		if not fromMouse then -- 1094
			self:vibrate(0.012) -- 1095
		end -- 1095
	elseif btn.id == "artifact" then -- 1095
		self.qArtifactPressed = true -- 1097
		if not fromMouse then -- 1097
			self:vibrate(0.02) -- 1098
		end -- 1098
	elseif btn.id == "pause" then -- 1098
		self.qPausePressed = true -- 1100
		if not fromMouse then -- 1100
			self:vibrate(0.014) -- 1101
		end -- 1101
	elseif btn.id == "retry" then -- 1101
		self.qRetryPressed = true -- 1103
		if not fromMouse then -- 1103
			self:vibrate(0.016) -- 1104
		end -- 1104
	elseif btn.id == "mute" then -- 1104
		self.qMutePressed = true -- 1106
	elseif btn.id == "fullscreen" then -- 1106
		self.qFullscreenPressed = true -- 1108
	elseif btn.id == "nav_up" then -- 1108
		self.qNavUp = true -- 1110
	elseif btn.id == "nav_down" then -- 1110
		self.qNavDown = true -- 1112
	elseif btn.id == "nav_left" then -- 1112
		self.qNavLeft = true -- 1114
	elseif btn.id == "nav_right" then -- 1114
		self.qNavRight = true -- 1116
	elseif btn.id == "nav_confirm" then -- 1116
		self.qNavConfirm = true -- 1118
	elseif btn.id == "nav_back" then -- 1118
		self.qNavBack = true -- 1120
	elseif btn.id == "fire" then -- 1120
		self.fireFingerId = id -- 1122
		self.fireStickDragging = false -- 1123
		self.fireOriginX = btn.x -- 1124
		self.fireOriginY = btn.y -- 1125
		self.fireKnobX = btn.x -- 1126
		self.fireKnobY = btn.y -- 1127
		local smart = pickSmartFireTarget( -- 1128
			self.ctx.playerScreenX, -- 1129
			self.ctx.playerScreenY, -- 1130
			self.stickMoveX < 0 and -1 or (self.stickMoveX > 0 and 1 or self.ctx.playerFacing), -- 1131
			vp.stageW, -- 1132
			vp.stageH, -- 1133
			vp.uiScale, -- 1134
			self.ctx.enemyTargets, -- 1135
			self.settings.aimAssist, -- 1136
			self.hasAim and ({x = self.aimX, y = self.aimY}) or nil -- 1137
		) -- 1137
		self.aimX = smart.x -- 1139
		self.aimY = smart.y -- 1140
		self.hasAim = true -- 1141
		self.qFirePressed = true -- 1142
		if not fromMouse then -- 1142
			self:vibrate(0.016) -- 1143
		end -- 1143
	elseif btn.id == "bottle" then -- 1143
		self.bottleFingerId = id -- 1145
		self.bottleOriginOvX = btn.x -- 1146
		self.bottleOriginOvY = btn.y -- 1147
		self.bottleCancelHover = false -- 1148
		self.bottleFingerOvX = ovX -- 1149
		self.bottleFingerOvY = ovY -- 1150
		local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1151
		self.aimX = clamp( -- 1152
			self.ctx.playerScreenX + dir * 180 * vp.uiScale, -- 1152
			24, -- 1152
			math.max(48, vp.stageW - 24) -- 1152
		) -- 1152
		self.aimY = clamp( -- 1153
			self.ctx.playerScreenY - 18 * vp.uiScale, -- 1153
			20, -- 1153
			math.max(40, vp.stageH - 48) -- 1153
		) -- 1153
		self.hasAim = true -- 1154
		if not fromMouse then -- 1154
			self:vibrate(0.015) -- 1155
		end -- 1155
	end -- 1155
end -- 1066
function TouchRouter.prototype.updateStickFromOverlay(self, ovX, ovY) -- 1159
	local maxR = math.max(24, self.ctx.stickMaxR) -- 1160
	local dead = maxR * STICK_DEAD_RATIO -- 1161
	local dx = ovX - self.stickOriginX -- 1162
	local dy = ovY - self.stickOriginY -- 1163
	local dist = hypot(dx, dy) -- 1164
	if dist <= 0.001 then -- 1164
		self.stickKnobX = self.stickOriginX -- 1166
		self.stickKnobY = self.stickOriginY -- 1167
		self.stickMoveX = 0 -- 1168
		self.stickMoveY = 0 -- 1169
		self.stickSlow = false -- 1170
		return -- 1171
	end -- 1171
	local clamped = math.min(dist, maxR) -- 1173
	self.stickKnobX = self.stickOriginX + dx / dist * clamped -- 1174
	self.stickKnobY = self.stickOriginY + dy / dist * clamped -- 1175
	if dist < dead then -- 1175
		self.stickMoveX = 0 -- 1178
		self.stickMoveY = 0 -- 1179
		self.stickSlow = false -- 1180
		return -- 1181
	end -- 1181
	local nx = dx / dist * (clamped / maxR) -- 1183
	local ny = dy / dist * (clamped / maxR) -- 1184
	self.stickMoveX = math.abs(nx) >= 0.22 and (nx > 0 and 1 or -1) or 0 -- 1186
	if self.ctx.allowDepth then -- 1186
		self.stickMoveY = math.abs(ny) >= 0.3 and (ny > 0 and -1 or 1) or 0 -- 1189
	else -- 1189
		self.stickMoveY = 0 -- 1191
	end -- 1191
	self.stickSlow = self.ctx.childMode and self.stickMoveX ~= 0 and clamped < maxR * 0.56 -- 1194
end -- 1159
function TouchRouter.prototype.handleTouchMoved(self, id, viewX, viewY, fromMouse) -- 1197
	local f = self.fingers[id] -- 1198
	if f == nil then -- 1198
		return -- 1200
	end -- 1200
	if not fromMouse then -- 1200
		self.lastRealTouchClock = self.clockSec -- 1203
	else -- 1203
		self.qMouseConsumed = true -- 1205
	end -- 1205
	local vp = self.ctx.viewport -- 1207
	local ov = self:toOverlay(viewX, viewY) -- 1208
	f.movedDistOv = f.movedDistOv + hypot(ov.x - f.curOvX, ov.y - f.curOvY) -- 1209
	f.curViewX = viewX -- 1210
	f.curViewY = viewY -- 1211
	f.curOvX = ov.x -- 1212
	f.curOvY = ov.y -- 1213
	if f.kind == "modal" and self.modalFingerId == id then -- 1213
		local stage = viewToStage(viewX, viewY, vp) -- 1216
		self.uiX = stage.x -- 1217
		self.uiY = stage.y -- 1218
		return -- 1219
	end -- 1219
	if f.kind == "stick" and self.stickFingerId == id then -- 1219
		self:updateStickFromOverlay(ov.x, ov.y) -- 1223
		return -- 1224
	end -- 1224
	if f.kind == "aim_canvas" and self.aimCanvasFingerId == id then -- 1224
		local stage = viewToStage(viewX, viewY, vp) -- 1228
		local assisted = snapPointAim( -- 1229
			clamp( -- 1230
				stage.x, -- 1230
				8, -- 1230
				math.max(16, vp.stageW - 8) -- 1230
			), -- 1230
			clamp( -- 1231
				stage.y, -- 1231
				8, -- 1231
				math.max(16, vp.stageH - 8) -- 1231
			), -- 1231
			self.ctx.enemyTargets, -- 1232
			34 * vp.uiScale, -- 1233
			self.settings.aimAssist -- 1234
		) -- 1234
		self.aimX = assisted.x -- 1236
		self.aimY = assisted.y -- 1237
		self.hasAim = true -- 1238
		return -- 1239
	end -- 1239
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1239
		local maxR = FIRE_STICK_MAX_R_OV * self.settings.touchScale -- 1243
		local dx = ov.x - self.fireOriginX -- 1244
		local dy = ov.y - self.fireOriginY -- 1245
		local dist = hypot(dx, dy) -- 1246
		local clamped = math.min(dist, maxR) -- 1247
		self.fireKnobX = dist > 0.001 and self.fireOriginX + dx / dist * clamped or self.fireOriginX -- 1248
		self.fireKnobY = dist > 0.001 and self.fireOriginY + dy / dist * clamped or self.fireOriginY -- 1249
		if dist >= FIRE_STICK_DRAG_THRESHOLD_OV * self.settings.touchScale then -- 1249
			self.fireStickDragging = true -- 1251
			f.firedOnDrag = true -- 1252
			local pt = snapConeAim( -- 1253
				self.ctx.playerScreenX, -- 1254
				self.ctx.playerScreenY, -- 1255
				dx / dist, -- 1256
				dy / dist, -- 1257
				260 * vp.uiScale, -- 1258
				vp.stageW, -- 1259
				vp.stageH, -- 1260
				self.ctx.enemyTargets, -- 1261
				self.settings.aimAssist -- 1262
			) -- 1262
			self.aimX = pt.x -- 1264
			self.aimY = pt.y -- 1265
			self.hasAim = true -- 1266
		end -- 1266
		return -- 1268
	end -- 1268
	if f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1268
		self.bottleFingerOvX = ov.x -- 1272
		self.bottleFingerOvY = ov.y -- 1273
		local cancel = self.ctx.bottleCancelCenter -- 1274
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1275
		self.bottleCancelHover = dCancel <= cancel.r -- 1276
		if not self.bottleCancelHover then -- 1276
			local stage = viewToStage(viewX, viewY, vp) -- 1278
			if vp.isPortrait and not stage.inside then -- 1278
				local dx = ov.x - self.bottleOriginOvX -- 1281
				local dy = ov.y - self.bottleOriginOvY -- 1282
				local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1283
				local baseForward = dir * math.min(180 * vp.uiScale, vp.stageW * 0.28) -- 1284
				self.aimX = clamp( -- 1285
					self.ctx.playerScreenX + baseForward + dx * 2.2, -- 1285
					16, -- 1285
					math.max(32, vp.stageW - 16) -- 1285
				) -- 1285
				self.aimY = clamp( -- 1286
					self.ctx.playerScreenY + dy * 1.4, -- 1286
					16, -- 1286
					math.max(32, vp.stageH - 16) -- 1286
				) -- 1286
			else -- 1286
				self.aimX = clamp( -- 1289
					stage.x, -- 1289
					16, -- 1289
					math.max(32, vp.stageW - 16) -- 1289
				) -- 1289
				self.aimY = clamp( -- 1290
					stage.y + BOTTLE_AIM_Y_OFFSET_UI * vp.uiScale, -- 1290
					16, -- 1290
					math.max(32, vp.stageH - 28) -- 1290
				) -- 1290
			end -- 1290
			self.hasAim = true -- 1292
		end -- 1292
	end -- 1292
end -- 1197
function TouchRouter.prototype.handleTouchEnded(self, id, viewX, viewY, fromMouse) -- 1297
	local f = self.fingers[id] -- 1298
	if f == nil then -- 1298
		return -- 1300
	end -- 1300
	if not fromMouse then -- 1300
		self.lastRealTouchClock = self.clockSec -- 1303
	else -- 1303
		self.qMouseConsumed = true -- 1305
	end -- 1305
	local vp = self.ctx.viewport -- 1307
	local ov = self:toOverlay(viewX, viewY) -- 1308
	if f.kind == "modal" and self.modalFingerId == id then -- 1308
		local stage = viewToStage(viewX, viewY, vp) -- 1310
		self.uiX = stage.x -- 1311
		self.uiY = stage.y -- 1312
		self.uiHeld = false -- 1313
		self.uiReleasedQueue = true -- 1314
		self.modalFingerId = -1 -- 1315
		__TS__Delete(self.fingers, id) -- 1316
		return -- 1317
	end -- 1317
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1317
		if f.firedOnDrag and self.ctx.canShoot then -- 1317
			self.qFirePressed = true -- 1322
			if not fromMouse then -- 1322
				self:vibrate(0.016) -- 1323
			end -- 1323
		end -- 1323
	elseif f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1323
		local cancel = self.ctx.bottleCancelCenter -- 1326
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1327
		if dCancel <= cancel.r then -- 1327
			self.qBottleCanceled = true -- 1329
			if not fromMouse then -- 1329
				self:vibrate(0.012) -- 1330
			end -- 1330
		end -- 1330
	end -- 1330
	self:releaseFingerById(id) -- 1334
end -- 1297
return ____exports -- 1297