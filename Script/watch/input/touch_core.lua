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
	if self.ctx.modal or not self.ctx.gameplayActive then -- 857
		self.qHadUiTouch = true -- 858
		if self.modalFingerId < 0 and (not portrait or stage.inside) then -- 859
			self.modalFingerId = id -- 860
			self.uiX = stage.x -- 861
			self.uiY = stage.y -- 862
			self.uiPrevX = stage.x -- 863
			self.uiPrevY = stage.y -- 864
			self.uiHeld = true -- 865
			self.uiPressedQueue = true -- 866
			self.fingers[id] = { -- 867
				id = id, -- 868
				fromMouse = false, -- 869
				kind = "modal", -- 870
				startViewX = viewX, -- 871
				startViewY = viewY, -- 872
				curViewX = viewX, -- 873
				curViewY = viewY, -- 874
				startOvX = ov.x, -- 875
				startOvY = ov.y, -- 876
				curOvX = ov.x, -- 877
				curOvY = ov.y, -- 878
				movedDistOv = 0 -- 879
			} -- 879
		end -- 879
		return -- 882
	end -- 882
	local zone = self:hitTestRectZones(ov.x, ov.y) -- 885
	if zone ~= nil then -- 886
		self.qHadUiTouch = true -- 887
		self.fingers[id] = { -- 888
			id = id, -- 889
			fromMouse = false, -- 890
			kind = "zone", -- 891
			zoneId = zone.id, -- 892
			startViewX = viewX, -- 893
			startViewY = viewY, -- 894
			curViewX = viewX, -- 895
			curViewY = viewY, -- 896
			startOvX = ov.x, -- 897
			startOvY = ov.y, -- 898
			curOvX = ov.x, -- 899
			curOvY = ov.y, -- 900
			movedDistOv = 0 -- 901
		} -- 901
		if zone.id == "pause" then -- 903
			self.qPausePressed = true -- 904
			self:vibrate(0.015) -- 905
		elseif zone.id == "retry" then -- 906
			self.qRetryPressed = true -- 907
			self:vibrate(0.015) -- 908
		elseif zone.id == "worldPrompt" then -- 909
			self:triggerInteractAction(id) -- 910
		else -- 910
			self.qZoneTap = zone.id -- 912
			self:vibrate(0.015) -- 913
		end -- 913
		return -- 915
	end -- 915
	if self.ctx.cutsceneBlocking then -- 918
		self.qHadUiTouch = true -- 919
		if self.ctx.inTowerEnd then -- 920
			self.qInteractPressed = true -- 921
			self:vibrate(0.015) -- 922
		end -- 922
		return -- 924
	end -- 924
	if not self.ctx.overlayActive and not self.ctx.allowAutoGameplayTouch then -- 927
		return -- 928
	end -- 928
	self.qHadGameplayTouch = true -- 930
	local ____portrait_16 -- 932
	if portrait then -- 932
		____portrait_16 = viewY < vp.deckH and ov.x <= self.ctx.stickZoneMaxX -- 933
	else -- 933
		____portrait_16 = ov.x <= self.ctx.stickZoneMaxX and ov.y <= self.ctx.stickZoneMaxY -- 934
	end -- 934
	local inStickZone = ____portrait_16 -- 932
	if self.stickFingerId < 0 and inStickZone then -- 935
		self:startStick( -- 936
			id, -- 936
			viewX, -- 936
			viewY, -- 936
			ov.x, -- 936
			ov.y, -- 936
			false -- 936
		) -- 936
		return -- 937
	end -- 937
	local ovH = vp.fullH / math.max(0.25, self.ctx.overlayScale) -- 940
	local allowStageShoot = stage.inside and (portrait or ov.y <= ovH - 84) -- 941
	if self.ctx.canShoot and self.aimCanvasFingerId < 0 and allowStageShoot then -- 942
		self.aimCanvasFingerId = id -- 943
		local assisted = snapPointAim( -- 944
			stage.x, -- 945
			stage.y, -- 946
			self.ctx.enemyTargets, -- 947
			44 * vp.uiScale, -- 948
			self.settings.aimAssist -- 949
		) -- 949
		self.aimX = assisted.x -- 951
		self.aimY = assisted.y -- 952
		self.hasAim = true -- 953
		self.qFirePressed = true -- 954
		self:vibrate(0.016) -- 955
		self.fingers[id] = { -- 956
			id = id, -- 957
			fromMouse = false, -- 958
			kind = "aim_canvas", -- 959
			startViewX = viewX, -- 960
			startViewY = viewY, -- 961
			curViewX = viewX, -- 962
			curViewY = viewY, -- 963
			startOvX = ov.x, -- 964
			startOvY = ov.y, -- 965
			curOvX = ov.x, -- 966
			curOvY = ov.y, -- 967
			movedDistOv = 0 -- 968
		} -- 968
	end -- 968
end -- 781
function TouchRouter.prototype.startStick(self, id, viewX, viewY, ovX, ovY, fromMouse) -- 973
	local vp = self.ctx.viewport -- 981
	local r = self.ctx.stickMaxR -- 982
	local ox = self.ctx.stickDefaultX -- 983
	local oy = self.ctx.stickDefaultY -- 984
	if not self.ctx.stickFixedOrigin then -- 985
		local safeL = vp.safe.left / math.max(0.25, self.ctx.overlayScale) -- 986
		local safeB = vp.safe.bottom / math.max(0.25, self.ctx.overlayScale) -- 987
		ox = clamp( -- 988
			ovX, -- 988
			safeL + r + 14, -- 988
			math.max(safeL + r + 14, self.ctx.stickZoneMaxX - 18) -- 988
		) -- 988
		oy = clamp( -- 989
			ovY, -- 989
			safeB + r + 14, -- 989
			math.max(safeB + r + 14, self.ctx.stickZoneMaxY - r * 0.6) -- 989
		) -- 989
	end -- 989
	self.stickFingerId = id -- 991
	self.stickOriginX = ox -- 992
	self.stickOriginY = oy -- 993
	self.stickKnobX = ovX -- 994
	self.stickKnobY = ovY -- 995
	self.fingers[id] = { -- 996
		id = id, -- 997
		fromMouse = fromMouse, -- 998
		kind = "stick", -- 999
		startViewX = viewX, -- 1000
		startViewY = viewY, -- 1001
		curViewX = viewX, -- 1002
		curViewY = viewY, -- 1003
		startOvX = ovX, -- 1004
		startOvY = ovY, -- 1005
		curOvX = ovX, -- 1006
		curOvY = ovY, -- 1007
		movedDistOv = 0 -- 1008
	} -- 1008
	self:updateStickFromOverlay(ovX, ovY) -- 1010
end -- 973
function TouchRouter.prototype.triggerInteractAction(self, id) -- 1013
	if self.ctx.cartNearby then -- 1014
		if self.cartGripLatched or self.ctx.cartGripping then -- 1015
			self.cartGripLatched = false -- 1016
			self.cartGripSeenActive = false -- 1017
			if self.ctx.cartUsesToggle then -- 1018
				self.qInteractPressed = true -- 1019
			end -- 1019
		else -- 1019
			self.cartGripLatched = true -- 1022
			self.cartGripSeenActive = false -- 1023
			self.qInteractPressed = true -- 1024
		end -- 1024
		self:vibrate(0.018) -- 1026
		return -- 1027
	end -- 1027
	self.interactFingerId = id -- 1029
	self.qInteractPressed = true -- 1030
	self:vibrate(0.015) -- 1031
end -- 1013
function TouchRouter.prototype.onButtonPressed(self, btn, id, ovX, ovY, fromMouse) -- 1034
	local vp = self.ctx.viewport -- 1041
	if btn.id == "interact" then -- 1042
		self:triggerInteractAction(id) -- 1043
	elseif btn.id == "jump" then -- 1044
		if self.ctx.childMode and self.crouchToggled and not self.ctx.inLowArch then -- 1045
			self.crouchToggled = false -- 1046
		end -- 1046
		self.jumpFingerId = id -- 1048
		self.qJumpPressed = true -- 1049
		if not fromMouse then -- 1050
			self:vibrate(0.014) -- 1050
		end -- 1050
	elseif btn.id == "cover" then -- 1051
		if self.ctx.childMode then -- 1052
			self.slowToggled = not self.slowToggled -- 1053
		else -- 1053
			self.coverToggled = not self.coverToggled -- 1055
			self.coverNearSeen = self.ctx.coverNear -- 1056
		end -- 1056
		if not fromMouse then -- 1058
			self:vibrate(0.012) -- 1058
		end -- 1058
	elseif btn.id == "crouch" then -- 1059
		self.crouchToggled = not self.crouchToggled -- 1060
		if not fromMouse then -- 1061
			self:vibrate(0.012) -- 1061
		end -- 1061
	elseif btn.id == "artifact" then -- 1062
		self.qArtifactPressed = true -- 1063
		if not fromMouse then -- 1064
			self:vibrate(0.02) -- 1064
		end -- 1064
	elseif btn.id == "pause" then -- 1065
		self.qPausePressed = true -- 1066
		if not fromMouse then -- 1067
			self:vibrate(0.014) -- 1067
		end -- 1067
	elseif btn.id == "retry" then -- 1068
		self.qRetryPressed = true -- 1069
		if not fromMouse then -- 1070
			self:vibrate(0.016) -- 1070
		end -- 1070
	elseif btn.id == "mute" then -- 1071
		self.qMutePressed = true -- 1072
	elseif btn.id == "fullscreen" then -- 1073
		self.qFullscreenPressed = true -- 1074
	elseif btn.id == "nav_up" then -- 1075
		self.qNavUp = true -- 1076
	elseif btn.id == "nav_down" then -- 1077
		self.qNavDown = true -- 1078
	elseif btn.id == "nav_left" then -- 1079
		self.qNavLeft = true -- 1080
	elseif btn.id == "nav_right" then -- 1081
		self.qNavRight = true -- 1082
	elseif btn.id == "nav_confirm" then -- 1083
		self.qNavConfirm = true -- 1084
	elseif btn.id == "nav_back" then -- 1085
		self.qNavBack = true -- 1086
	elseif btn.id == "fire" then -- 1087
		self.fireFingerId = id -- 1088
		self.fireStickDragging = false -- 1089
		self.fireOriginX = btn.x -- 1090
		self.fireOriginY = btn.y -- 1091
		self.fireKnobX = btn.x -- 1092
		self.fireKnobY = btn.y -- 1093
		local smart = pickSmartFireTarget( -- 1094
			self.ctx.playerScreenX, -- 1095
			self.ctx.playerScreenY, -- 1096
			self.stickMoveX < 0 and -1 or (self.stickMoveX > 0 and 1 or self.ctx.playerFacing), -- 1097
			vp.stageW, -- 1098
			vp.stageH, -- 1099
			vp.uiScale, -- 1100
			self.ctx.enemyTargets, -- 1101
			self.settings.aimAssist, -- 1102
			self.hasAim and ({x = self.aimX, y = self.aimY}) or nil -- 1103
		) -- 1103
		self.aimX = smart.x -- 1105
		self.aimY = smart.y -- 1106
		self.hasAim = true -- 1107
		if not fromMouse then -- 1108
			self:vibrate(0.012) -- 1108
		end -- 1108
	elseif btn.id == "bottle" then -- 1109
		self.bottleFingerId = id -- 1110
		self.bottleOriginOvX = btn.x -- 1111
		self.bottleOriginOvY = btn.y -- 1112
		self.bottleCancelHover = false -- 1113
		self.bottleFingerOvX = ovX -- 1114
		self.bottleFingerOvY = ovY -- 1115
		local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1116
		self.aimX = clamp( -- 1117
			self.ctx.playerScreenX + dir * 180 * vp.uiScale, -- 1117
			24, -- 1117
			math.max(48, vp.stageW - 24) -- 1117
		) -- 1117
		self.aimY = clamp( -- 1118
			self.ctx.playerScreenY - 18 * vp.uiScale, -- 1118
			20, -- 1118
			math.max(40, vp.stageH - 48) -- 1118
		) -- 1118
		self.hasAim = true -- 1119
		if not fromMouse then -- 1120
			self:vibrate(0.015) -- 1120
		end -- 1120
	end -- 1120
end -- 1034
function TouchRouter.prototype.updateStickFromOverlay(self, ovX, ovY) -- 1124
	local maxR = math.max(24, self.ctx.stickMaxR) -- 1125
	local dead = maxR * STICK_DEAD_RATIO -- 1126
	local dx = ovX - self.stickOriginX -- 1127
	local dy = ovY - self.stickOriginY -- 1128
	local dist = hypot(dx, dy) -- 1129
	if dist <= 0.001 then -- 1130
		self.stickKnobX = self.stickOriginX -- 1131
		self.stickKnobY = self.stickOriginY -- 1132
		self.stickMoveX = 0 -- 1133
		self.stickMoveY = 0 -- 1134
		self.stickSlow = false -- 1135
		return -- 1136
	end -- 1136
	local clamped = math.min(dist, maxR) -- 1138
	self.stickKnobX = self.stickOriginX + dx / dist * clamped -- 1139
	self.stickKnobY = self.stickOriginY + dy / dist * clamped -- 1140
	if dist < dead then -- 1142
		self.stickMoveX = 0 -- 1143
		self.stickMoveY = 0 -- 1144
		self.stickSlow = false -- 1145
		return -- 1146
	end -- 1146
	local nx = dx / dist * (clamped / maxR) -- 1148
	local ny = dy / dist * (clamped / maxR) -- 1149
	self.stickMoveX = math.abs(nx) >= 0.22 and (nx > 0 and 1 or -1) or 0 -- 1151
	if self.ctx.allowDepth then -- 1152
		self.stickMoveY = math.abs(ny) >= 0.3 and (ny > 0 and -1 or 1) or 0 -- 1153
	else -- 1153
		self.stickMoveY = 0 -- 1155
	end -- 1155
	self.stickSlow = self.ctx.childMode and self.stickMoveX ~= 0 and clamped < maxR * 0.56 -- 1157
end -- 1124
function TouchRouter.prototype.handleTouchMoved(self, id, viewX, viewY, fromMouse) -- 1160
	local f = self.fingers[id] -- 1161
	if f == nil then -- 1162
		return -- 1163
	end -- 1163
	if self.enableMouseCompat then -- 1165
		if not fromMouse then -- 1166
			self.lastRealTouchClock = self.clockSec -- 1167
		else -- 1167
			self.qMouseConsumed = true -- 1169
		end -- 1169
	end -- 1169
	local vp = self.ctx.viewport -- 1172
	local portrait = self.enablePortrait and vp.isPortrait -- 1173
	local ov = self:toOverlay(viewX, viewY) -- 1174
	f.movedDistOv = f.movedDistOv + hypot(ov.x - f.curOvX, ov.y - f.curOvY) -- 1175
	f.curViewX = viewX -- 1176
	f.curViewY = viewY -- 1177
	f.curOvX = ov.x -- 1178
	f.curOvY = ov.y -- 1179
	if f.kind == "modal" and self.modalFingerId == id then -- 1181
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1182
		self.uiX = stage.x -- 1183
		self.uiY = stage.y -- 1184
		return -- 1185
	end -- 1185
	if f.kind == "stick" and self.stickFingerId == id then -- 1188
		self:updateStickFromOverlay(ov.x, ov.y) -- 1189
		return -- 1190
	end -- 1190
	if f.kind == "aim_canvas" and self.aimCanvasFingerId == id then -- 1193
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1194
		local assisted = snapPointAim( -- 1195
			clamp( -- 1196
				stage.x, -- 1196
				8, -- 1196
				math.max(16, vp.stageW - 8) -- 1196
			), -- 1196
			clamp( -- 1197
				stage.y, -- 1197
				8, -- 1197
				math.max(16, vp.stageH - 8) -- 1197
			), -- 1197
			self.ctx.enemyTargets, -- 1198
			34 * vp.uiScale, -- 1199
			self.settings.aimAssist -- 1200
		) -- 1200
		self.aimX = assisted.x -- 1202
		self.aimY = assisted.y -- 1203
		self.hasAim = true -- 1204
		return -- 1205
	end -- 1205
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1208
		local maxR = FIRE_STICK_MAX_R_OV * self.settings.touchScale -- 1209
		local dx = ov.x - self.fireOriginX -- 1210
		local dy = ov.y - self.fireOriginY -- 1211
		local dist = hypot(dx, dy) -- 1212
		local clamped = math.min(dist, maxR) -- 1213
		self.fireKnobX = dist > 0.001 and self.fireOriginX + dx / dist * clamped or self.fireOriginX -- 1214
		self.fireKnobY = dist > 0.001 and self.fireOriginY + dy / dist * clamped or self.fireOriginY -- 1215
		if dist >= FIRE_STICK_DRAG_THRESHOLD_OV * self.settings.touchScale then -- 1216
			self.fireStickDragging = true -- 1217
			f.firedOnDrag = true -- 1218
			local pt = snapConeAim( -- 1219
				self.ctx.playerScreenX, -- 1220
				self.ctx.playerScreenY, -- 1221
				dx / dist, -- 1222
				dy / dist, -- 1223
				260 * vp.uiScale, -- 1224
				vp.stageW, -- 1225
				vp.stageH, -- 1226
				self.ctx.enemyTargets, -- 1227
				self.settings.aimAssist -- 1228
			) -- 1228
			self.aimX = pt.x -- 1230
			self.aimY = pt.y -- 1231
			self.hasAim = true -- 1232
		end -- 1232
		return -- 1234
	end -- 1234
	if f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1237
		self.bottleFingerOvX = ov.x -- 1238
		self.bottleFingerOvY = ov.y -- 1239
		local cancel = self.ctx.bottleCancelCenter -- 1240
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1241
		self.bottleCancelHover = dCancel <= cancel.r -- 1242
		if not self.bottleCancelHover then -- 1243
			local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1244
			if portrait and not stage.inside then -- 1245
				local dx = ov.x - self.bottleOriginOvX -- 1246
				local dy = ov.y - self.bottleOriginOvY -- 1247
				local dir = self.ctx.playerFacing < 0 and -1 or 1 -- 1248
				local baseForward = dir * math.min(180 * vp.uiScale, vp.stageW * 0.28) -- 1249
				self.aimX = clamp( -- 1250
					self.ctx.playerScreenX + baseForward + dx * 2.2, -- 1250
					16, -- 1250
					math.max(32, vp.stageW - 16) -- 1250
				) -- 1250
				self.aimY = clamp( -- 1251
					self.ctx.playerScreenY + dy * 1.4, -- 1251
					16, -- 1251
					math.max(32, vp.stageH - 16) -- 1251
				) -- 1251
			else -- 1251
				self.aimX = clamp( -- 1253
					stage.x, -- 1253
					16, -- 1253
					math.max(32, vp.stageW - 16) -- 1253
				) -- 1253
				self.aimY = clamp( -- 1254
					stage.y + BOTTLE_AIM_Y_OFFSET_UI * vp.uiScale, -- 1254
					16, -- 1254
					math.max(32, vp.stageH - 28) -- 1254
				) -- 1254
			end -- 1254
			self.hasAim = true -- 1256
		end -- 1256
	end -- 1256
end -- 1160
function TouchRouter.prototype.handleTouchEnded(self, id, viewX, viewY, fromMouse) -- 1261
	local f = self.fingers[id] -- 1262
	if f == nil then -- 1263
		return -- 1264
	end -- 1264
	if self.enableMouseCompat then -- 1266
		if not fromMouse then -- 1267
			self.lastRealTouchClock = self.clockSec -- 1268
		else -- 1268
			self.qMouseConsumed = true -- 1270
		end -- 1270
	end -- 1270
	local vp = self.ctx.viewport -- 1273
	local portrait = self.enablePortrait and vp.isPortrait -- 1274
	local ov = self:toOverlay(viewX, viewY) -- 1275
	if f.kind == "modal" and self.modalFingerId == id then -- 1276
		local stage = portrait and viewToStage(viewX, viewY, vp) or ({x = viewX, y = viewY, inside = true}) -- 1277
		self.uiX = stage.x -- 1278
		self.uiY = stage.y -- 1279
		self.uiHeld = false -- 1280
		self.uiReleasedQueue = true -- 1281
		self.modalFingerId = -1 -- 1282
		__TS__Delete(self.fingers, id) -- 1283
		return -- 1284
	end -- 1284
	if f.kind == "btn" and f.btnId == "fire" and self.fireFingerId == id then -- 1287
		if self.ctx.canShoot then -- 1288
			self.qFirePressed = true -- 1289
			if not fromMouse then -- 1290
				self:vibrate(0.016) -- 1290
			end -- 1290
		end -- 1290
	elseif f.kind == "btn" and f.btnId == "bottle" and self.bottleFingerId == id then -- 1292
		local cancel = self.ctx.bottleCancelCenter -- 1293
		local dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y) -- 1294
		if dCancel <= cancel.r then -- 1295
			self.qBottleCanceled = true -- 1296
			if not fromMouse then -- 1297
				self:vibrate(0.012) -- 1297
			end -- 1297
		end -- 1297
	end -- 1297
	self:releaseFingerById(id) -- 1301
end -- 1261
return ____exports -- 1261
