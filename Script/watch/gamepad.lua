-- [ts]: gamepad.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 16
local Controller = ____Dora.Controller -- 16
local Node = ____Dora.Node -- 16
local Size = ____Dora.Size -- 16
local Vec2 = ____Dora.Vec2 -- 16
local ____aim_assist = require("Script.watch.aim_assist") -- 17
local snapConeAim = ____aim_assist.snapConeAim -- 17
local ____controls_config = require("Script.watch.controls_config") -- 18
local defaultControlSettings = ____controls_config.defaultControlSettings -- 21
local saveControlSettings = ____controls_config.saveControlSettings -- 22
local MAX_CONTROLLER_SLOTS = 4 -- 136
local STICK_MENU_DEADZONE = 0.55 -- 137
local MENU_REPEAT_INITIAL = 0.38 -- 138
local MENU_REPEAT_INTERVAL = 0.13 -- 139
local TRIGGER_PRESS_THRESHOLD = 0.35 -- 140
local TRIGGER_RELEASE_THRESHOLD = 0.2 -- 141
local RETRY_HOLD_SEC = 0.55 -- 142
local BOTTLE_AIM_SPEED_UI = 460 -- 143
local function emptyRaw() -- 168
	return { -- 169
		a = false, -- 170
		b = false, -- 170
		x = false, -- 170
		y = false, -- 170
		up = false, -- 171
		down = false, -- 171
		left = false, -- 171
		right = false, -- 171
		lb = false, -- 172
		rb = false, -- 172
		ls = false, -- 172
		rs = false, -- 172
		back = false, -- 173
		start = false, -- 173
		leftX = 0, -- 174
		leftY = 0, -- 174
		rightX = 0, -- 174
		rightY = 0, -- 174
		lt = 0, -- 175
		rt = 0 -- 175
	} -- 175
end -- 168
local function clamp(v, lo, hi) -- 179
	return v < lo and lo or (v > hi and hi or v) -- 180
end -- 179
local function hypot(dx, dy) -- 183
	return math.sqrt(dx * dx + dy * dy) -- 184
end -- 183
local function safeButtonPressed(id, btn) -- 187
	if type(Controller) == "nil" then -- 187
		return false -- 188
	end -- 188
	return Controller:isButtonPressed(id, btn) -- 189
end -- 187
local function safeButtonDown(id, btn) -- 192
	if type(Controller) == "nil" then -- 192
		return false -- 193
	end -- 193
	return Controller:isButtonDown(id, btn) -- 194
end -- 192
local function safeAxis(id, axis) -- 197
	if type(Controller) == "nil" then -- 197
		return 0 -- 198
	end -- 198
	local v = Controller:getAxis(id, axis) -- 199
	return type(v) == "number" and v or 0 -- 200
end -- 197
____exports.GamepadRouter = __TS__Class() -- 203
local GamepadRouter = ____exports.GamepadRouter -- 203
GamepadRouter.name = "GamepadRouter" -- 203
function GamepadRouter.prototype.____constructor(self, sharedSettings) -- 283
	self.activeControllerId = 0 -- 205
	self.latchedButtons = {} -- 209
	self.ctx = { -- 211
		stageW = 1280, -- 212
		stageH = 720, -- 213
		uiScale = 1, -- 214
		modal = true, -- 215
		gameplayActive = false, -- 216
		reloadActive = false, -- 217
		craftActive = false, -- 218
		talentOfferCount = 0, -- 219
		childMode = false, -- 220
		allowDepth = false, -- 221
		canShoot = false, -- 222
		canBottleAim = false, -- 223
		playerRolling = false, -- 224
		inLowArch = false, -- 225
		inTowerEnd = false, -- 226
		playerFacing = 1, -- 227
		playerScreenX = 640, -- 228
		playerScreenY = 240, -- 229
		enemyTargets = {} -- 230
	} -- 230
	self.prevA = false -- 234
	self.prevB = false -- 235
	self.prevX = false -- 236
	self.prevY = false -- 237
	self.prevUp = false -- 238
	self.prevDown = false -- 239
	self.prevLeft = false -- 240
	self.prevRight = false -- 241
	self.prevLb = false -- 242
	self.prevRb = false -- 243
	self.prevLs = false -- 244
	self.prevRs = false -- 245
	self.prevBack = false -- 246
	self.prevStart = false -- 247
	self.ltPressed = false -- 248
	self.rtPressed = false -- 249
	self.prevRtPressed = false -- 250
	self.chordLocked = false -- 253
	self.backHoldSec = 0 -- 254
	self.backRetryFired = false -- 255
	self.crouchToggled = false -- 258
	self.bottleCancelLock = false -- 259
	self.repeatDirX = 0 -- 262
	self.repeatDirY = 0 -- 263
	self.repeatTimer = 0 -- 264
	self.reloadStickCol = 0 -- 267
	self.reloadStickRow = 0 -- 268
	self.reloadStickTimer = 0 -- 269
	self.reloadStickArmed = false -- 270
	self.aimAngle = 0 -- 273
	self.aimLastFacing = 1 -- 274
	self.aimX = 640 -- 275
	self.aimY = 260 -- 276
	self.bottleOffsetX = 160 -- 277
	self.bottleOffsetY = 0 -- 278
	self.wasBottleAiming = false -- 279
	self.lastDt = 1 / 60 -- 281
	self.settings = sharedSettings ~= nil and sharedSettings or defaultControlSettings() -- 284
end -- 283
function GamepadRouter.prototype.attach(self, parent) -- 287
	if self.listenerNode ~= nil then -- 287
		return -- 289
	end -- 289
	local n = Node() -- 291
	n.size = Size(0, 0) -- 292
	n.position = Vec2(0, 0) -- 293
	n.order = 115 -- 294
	n.controllerEnabled = true -- 295
	n.touchEnabled = false -- 296
	n:onButtonDown(function(controllerId, buttonName) -- 298
		self.activeControllerId = controllerId -- 299
		self.latchedButtons[buttonName] = true -- 300
	end) -- 298
	n:onAxis(function(controllerId, _axisName, value) -- 303
		if math.abs(value) > 0.35 then -- 303
			self.activeControllerId = controllerId -- 305
		end -- 305
	end) -- 303
	n:addTo(parent) -- 309
	self.listenerNode = n -- 310
end -- 287
function GamepadRouter.prototype.setSimulatedState(self, state) -- 314
	self.simState = state -- 315
end -- 314
function GamepadRouter.prototype.toggleLayout(self) -- 318
	self.settings.gamepadLayout = self.settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 319
	saveControlSettings(self.settings) -- 320
	return self.settings.gamepadLayout -- 321
end -- 318
function GamepadRouter.prototype.toggleAimAssist(self) -- 324
	self.settings.aimAssist = not self.settings.aimAssist -- 325
	saveControlSettings(self.settings) -- 326
	return self.settings.aimAssist -- 327
end -- 324
function GamepadRouter.prototype.toggleCrouchMode(self) -- 330
	self.settings.crouchToggle = not self.settings.crouchToggle -- 331
	if not self.settings.crouchToggle then -- 331
		self.crouchToggled = false -- 333
	end -- 333
	saveControlSettings(self.settings) -- 335
	return self.settings.crouchToggle -- 336
end -- 330
function GamepadRouter.prototype.setFrameContext(self, next, dt) -- 339
	self.lastDt = math.min( -- 340
		0.05, -- 340
		math.max(0.001, dt) -- 340
	) -- 340
	local wasChild = self.ctx.childMode -- 341
	local wasReload = self.ctx.reloadActive -- 342
	self.ctx = next -- 343
	if wasChild ~= next.childMode or next.modal then -- 343
		self.crouchToggled = false -- 345
	end -- 345
	if next.reloadActive and not wasReload then -- 345
		self.reloadStickCol = 0 -- 348
		self.reloadStickRow = 0 -- 349
		self.reloadStickTimer = 0 -- 350
		self.reloadStickArmed = false -- 351
	end -- 351
	if not next.canBottleAim then -- 351
		self.wasBottleAiming = false -- 354
		self.bottleCancelLock = false -- 355
	end -- 355
end -- 339
function GamepadRouter.prototype.clearTransient(self) -- 359
	self.latchedButtons = {} -- 360
	self.backHoldSec = 0 -- 361
	self.backRetryFired = false -- 362
	self.chordLocked = false -- 363
	self.crouchToggled = false -- 364
	self.bottleCancelLock = false -- 365
	self.wasBottleAiming = false -- 366
	self.repeatDirX = 0 -- 367
	self.repeatDirY = 0 -- 368
	self.repeatTimer = 0 -- 369
end -- 359
function GamepadRouter.prototype.sampleRaw(self) -- 372
	if self.simState ~= nil then -- 372
		local s = self.simState -- 374
		return { -- 375
			a = s.a == true, -- 376
			b = s.b == true, -- 377
			x = s.x == true, -- 378
			y = s.y == true, -- 379
			up = s.up == true, -- 380
			down = s.down == true, -- 381
			left = s.left == true, -- 382
			right = s.right == true, -- 383
			lb = s.lb == true, -- 384
			rb = s.rb == true, -- 385
			ls = s.ls == true, -- 386
			rs = s.rs == true, -- 387
			back = s.back == true, -- 388
			start = s.start == true, -- 389
			leftX = s.leftX or 0, -- 390
			leftY = s.leftY or 0, -- 391
			rightX = s.rightX or 0, -- 392
			rightY = s.rightY or 0, -- 393
			lt = s.lt or 0, -- 394
			rt = s.rt or 0 -- 395
		} -- 395
	end -- 395
	local out = emptyRaw() -- 399
	if type(Controller) == "nil" then -- 399
		return out -- 401
	end -- 401
	local cid = 0 -- 404
	do -- 404
		cid = 0 -- 405
		while cid < MAX_CONTROLLER_SLOTS do -- 405
			local a = safeButtonPressed(cid, "a") or safeButtonDown(cid, "a") -- 406
			local b = safeButtonPressed(cid, "b") or safeButtonDown(cid, "b") -- 407
			local x = safeButtonPressed(cid, "x") or safeButtonDown(cid, "x") -- 408
			local y = safeButtonPressed(cid, "y") or safeButtonDown(cid, "y") -- 409
			local up = safeButtonPressed(cid, "dpup") or safeButtonDown(cid, "dpup") -- 410
			local down = safeButtonPressed(cid, "dpdown") or safeButtonDown(cid, "dpdown") -- 411
			local left = safeButtonPressed(cid, "dpleft") or safeButtonDown(cid, "dpleft") -- 412
			local right = safeButtonPressed(cid, "dpright") or safeButtonDown(cid, "dpright") -- 413
			local lb = safeButtonPressed(cid, "leftshoulder") or safeButtonDown(cid, "leftshoulder") -- 414
			local rb = safeButtonPressed(cid, "rightshoulder") or safeButtonDown(cid, "rightshoulder") -- 415
			local ls = safeButtonPressed(cid, "leftstick") or safeButtonDown(cid, "leftstick") -- 416
			local rs = safeButtonPressed(cid, "rightstick") or safeButtonDown(cid, "rightstick") -- 417
			local back = safeButtonPressed(cid, "back") or safeButtonDown(cid, "back") -- 418
			local start = safeButtonPressed(cid, "start") or safeButtonDown(cid, "start") -- 419
			local lx = safeAxis(cid, "leftx") -- 421
			local ly = safeAxis(cid, "lefty") -- 422
			local rx = safeAxis(cid, "rightx") -- 423
			local ry = safeAxis(cid, "righty") -- 424
			local lt = math.max( -- 425
				0, -- 425
				safeAxis(cid, "lefttrigger") -- 425
			) -- 425
			local rt = math.max( -- 426
				0, -- 426
				safeAxis(cid, "righttrigger") -- 426
			) -- 426
			local anyBtn = a or b or x or y or up or down or left or right or lb or rb or ls or rs or back or start -- 428
			local anyAxis = math.abs(lx) > 0.25 or math.abs(ly) > 0.25 or math.abs(rx) > 0.25 or math.abs(ry) > 0.25 or lt > 0.25 or rt > 0.25 -- 429
			if anyBtn or anyAxis then -- 429
				self.activeControllerId = cid -- 431
			end -- 431
			if a then -- 431
				out.a = true -- 433
			end -- 433
			if b then -- 433
				out.b = true -- 434
			end -- 434
			if x then -- 434
				out.x = true -- 435
			end -- 435
			if y then -- 435
				out.y = true -- 436
			end -- 436
			if up then -- 436
				out.up = true -- 437
			end -- 437
			if down then -- 437
				out.down = true -- 438
			end -- 438
			if left then -- 438
				out.left = true -- 439
			end -- 439
			if right then -- 439
				out.right = true -- 440
			end -- 440
			if lb then -- 440
				out.lb = true -- 441
			end -- 441
			if rb then -- 441
				out.rb = true -- 442
			end -- 442
			if ls then -- 442
				out.ls = true -- 443
			end -- 443
			if rs then -- 443
				out.rs = true -- 444
			end -- 444
			if back then -- 444
				out.back = true -- 445
			end -- 445
			if start then -- 445
				out.start = true -- 446
			end -- 446
			if math.abs(lx) > math.abs(out.leftX) then -- 446
				out.leftX = lx -- 448
			end -- 448
			if math.abs(ly) > math.abs(out.leftY) then -- 448
				out.leftY = ly -- 449
			end -- 449
			if math.abs(rx) > math.abs(out.rightX) then -- 449
				out.rightX = rx -- 450
			end -- 450
			if math.abs(ry) > math.abs(out.rightY) then -- 450
				out.rightY = ry -- 451
			end -- 451
			if lt > out.lt then -- 451
				out.lt = lt -- 452
			end -- 452
			if rt > out.rt then -- 452
				out.rt = rt -- 453
			end -- 453
			cid = cid + 1 -- 405
		end -- 405
	end -- 405
	if self.latchedButtons.a then -- 405
		out.a = true -- 456
	end -- 456
	if self.latchedButtons.b then -- 456
		out.b = true -- 457
	end -- 457
	if self.latchedButtons.x then -- 457
		out.x = true -- 458
	end -- 458
	if self.latchedButtons.y then -- 458
		out.y = true -- 459
	end -- 459
	if self.latchedButtons.dpup then -- 459
		out.up = true -- 460
	end -- 460
	if self.latchedButtons.dpdown then -- 460
		out.down = true -- 461
	end -- 461
	if self.latchedButtons.dpleft then -- 461
		out.left = true -- 462
	end -- 462
	if self.latchedButtons.dpright then -- 462
		out.right = true -- 463
	end -- 463
	if self.latchedButtons.leftshoulder then -- 463
		out.lb = true -- 464
	end -- 464
	if self.latchedButtons.rightshoulder then -- 464
		out.rb = true -- 465
	end -- 465
	if self.latchedButtons.leftstick then -- 465
		out.ls = true -- 466
	end -- 466
	if self.latchedButtons.rightstick then -- 466
		out.rs = true -- 467
	end -- 467
	if self.latchedButtons.back then -- 467
		out.back = true -- 468
	end -- 468
	if self.latchedButtons.start then -- 468
		out.start = true -- 469
	end -- 469
	self.latchedButtons = {} -- 470
	return out -- 472
end -- 372
function GamepadRouter.prototype.consumeSnapshot(self) -- 475
	local dt = self.lastDt -- 476
	local raw = self:sampleRaw() -- 477
	local ____table_ltPressed_0 -- 480
	if self.ltPressed then -- 480
		____table_ltPressed_0 = raw.lt > TRIGGER_RELEASE_THRESHOLD -- 480
	else -- 480
		____table_ltPressed_0 = raw.lt > TRIGGER_PRESS_THRESHOLD -- 480
	end -- 480
	local ltNow = ____table_ltPressed_0 -- 480
	local ____table_rtPressed_1 -- 481
	if self.rtPressed then -- 481
		____table_rtPressed_1 = raw.rt > TRIGGER_RELEASE_THRESHOLD -- 481
	else -- 481
		____table_rtPressed_1 = raw.rt > TRIGGER_PRESS_THRESHOLD -- 481
	end -- 481
	local rtNow = ____table_rtPressed_1 -- 481
	self.ltPressed = ltNow -- 482
	self.rtPressed = rtNow -- 483
	local aPressed = raw.a and not self.prevA -- 485
	local bPressed = raw.b and not self.prevB -- 486
	local xPressed = raw.x and not self.prevX -- 487
	local yPressed = raw.y and not self.prevY -- 488
	local upPressed = raw.up and not self.prevUp -- 489
	local downPressed = raw.down and not self.prevDown -- 490
	local leftPressed = raw.left and not self.prevLeft -- 491
	local rightPressed = raw.right and not self.prevRight -- 492
	local lbPressed = raw.lb and not self.prevLb -- 493
	local rbPressed = raw.rb and not self.prevRb -- 494
	local lsPressed = raw.ls and not self.prevLs -- 495
	local rsPressed = raw.rs and not self.prevRs -- 496
	local startPressed = raw.start and not self.prevStart -- 497
	local rtEdge = rtNow and not self.prevRtPressed -- 498
	local dzL = self.settings.deadzoneLeft -- 500
	local dzR = self.settings.deadzoneRight -- 501
	local lMag = hypot(raw.leftX, raw.leftY) -- 502
	local rMag = hypot(raw.rightX, raw.rightY) -- 503
	local hadGamepadInput = raw.a or raw.b or raw.x or raw.y or raw.up or raw.down or raw.left or raw.right or raw.lb or raw.rb or raw.ls or raw.rs or raw.back or raw.start or ltNow or rtNow or lMag > dzL or rMag > dzR -- 504
	local anyButtonPressed = aPressed or bPressed or xPressed or yPressed or startPressed or lbPressed or rbPressed -- 509
	local pausePressed = false -- 512
	local retryPressed = false -- 513
	if raw.back and raw.start then -- 513
		self.chordLocked = true -- 515
		self.backHoldSec = 0 -- 516
		self.backRetryFired = false -- 517
	elseif self.chordLocked then -- 517
		if not raw.back and not raw.start then -- 517
			self.chordLocked = false -- 520
		end -- 520
		self.backHoldSec = 0 -- 522
		self.backRetryFired = false -- 523
	else -- 523
		if startPressed and not raw.back then -- 523
			pausePressed = true -- 526
		end -- 526
		if raw.back and not raw.start and self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.inTowerEnd then -- 526
			self.backHoldSec = self.backHoldSec + dt -- 529
			if self.backHoldSec >= RETRY_HOLD_SEC and not self.backRetryFired then -- 529
				retryPressed = true -- 531
				self.backRetryFired = true -- 532
			end -- 532
		else -- 532
			self.backHoldSec = 0 -- 535
			self.backRetryFired = false -- 536
		end -- 536
	end -- 536
	local retryHoldProgress = raw.back and not self.chordLocked and not raw.start and self.ctx.gameplayActive and not self.ctx.modal and clamp(self.backHoldSec / RETRY_HOLD_SEC, 0, 1) or 0 -- 539
	local dpadX = (raw.right and 1 or 0) - (raw.left and 1 or 0) -- 544
	local dpadY = (raw.down and 1 or 0) - (raw.up and 1 or 0) -- 545
	local stickMoveX = 0 -- 546
	local stickMoveY = 0 -- 547
	local stickSlowWalk = false -- 548
	if lMag > dzL then -- 548
		local normMag = clamp( -- 550
			(lMag - dzL) / math.max(0.05, 1 - dzL), -- 550
			0, -- 550
			1 -- 550
		) -- 550
		local nx = raw.leftX / lMag -- 551
		local ny = raw.leftY / lMag -- 552
		if self.ctx.allowDepth then -- 552
			local maxAxis = math.max( -- 554
				math.abs(nx), -- 554
				math.abs(ny), -- 554
				0.001 -- 554
			) -- 554
			stickMoveX = clamp(nx / maxAxis * normMag, -1, 1) -- 555
			stickMoveY = clamp(ny / maxAxis * normMag, -1, 1) -- 556
		else -- 556
			if math.abs(raw.leftX) > dzL * 0.85 then -- 556
				stickMoveX = raw.leftX > 0 and 1 or -1 -- 559
				if lMag < 0.56 then -- 559
					stickSlowWalk = true -- 561
				end -- 561
			end -- 561
			if raw.leftY > 0.65 and math.abs(raw.leftY) > math.abs(raw.leftX) * 1.15 then -- 561
				stickMoveY = 1 -- 565
			elseif raw.leftY < -0.65 and math.abs(raw.leftY) > math.abs(raw.leftX) * 1.15 then -- 565
				stickMoveY = -1 -- 567
			end -- 567
		end -- 567
	end -- 567
	local moveX = dpadX ~= 0 and dpadX or stickMoveX -- 571
	local moveY = dpadY ~= 0 and dpadY or stickMoveY -- 572
	local sMenuX = math.abs(raw.leftX) >= STICK_MENU_DEADZONE and (raw.leftX > 0 and 1 or -1) or 0 -- 575
	local sMenuY = math.abs(raw.leftY) >= STICK_MENU_DEADZONE and (raw.leftY > 0 and 1 or -1) or 0 -- 576
	local stickNavX = 0 -- 577
	local stickNavY = 0 -- 578
	if sMenuX == 0 and sMenuY == 0 then -- 578
		self.repeatDirX = 0 -- 580
		self.repeatDirY = 0 -- 581
		self.repeatTimer = 0 -- 582
	elseif sMenuX ~= self.repeatDirX or sMenuY ~= self.repeatDirY then -- 582
		self.repeatDirX = sMenuX -- 584
		self.repeatDirY = sMenuY -- 585
		self.repeatTimer = MENU_REPEAT_INITIAL -- 586
		stickNavX = sMenuX -- 587
		stickNavY = sMenuY -- 588
	else -- 588
		self.repeatTimer = self.repeatTimer - dt -- 590
		if self.repeatTimer <= 0 then -- 590
			self.repeatTimer = MENU_REPEAT_INTERVAL -- 592
			stickNavX = sMenuX -- 593
			stickNavY = sMenuY -- 594
		end -- 594
	end -- 594
	local navUp = upPressed or stickNavY < 0 -- 598
	local navDown = downPressed or stickNavY > 0 -- 599
	local navLeft = leftPressed or stickNavX < 0 -- 600
	local navRight = rightPressed or stickNavX > 0 -- 601
	local ____temp_2 -- 602
	if self.settings.gamepadLayout == "nintendo" then -- 602
		____temp_2 = bPressed -- 602
	else -- 602
		____temp_2 = aPressed -- 602
	end -- 602
	local navConfirm = ____temp_2 -- 602
	local ____temp_3 -- 603
	if self.settings.gamepadLayout == "nintendo" then -- 603
		____temp_3 = aPressed -- 603
	else -- 603
		____temp_3 = bPressed -- 603
	end -- 603
	local navBack = ____temp_3 -- 603
	local navPrevTab = lbPressed -- 604
	local navNextTab = rbPressed -- 605
	local reloadDirCol = 0 -- 608
	local reloadDirRow = 0 -- 609
	local reloadStepEdge = false -- 610
	local reloadAutoStep = false -- 611
	if self.ctx.reloadActive then -- 611
		local dpCol = (rightPressed and 1 or 0) - (leftPressed and 1 or 0) -- 613
		local dpRow = (upPressed and 1 or 0) - (downPressed and 1 or 0) -- 614
		if dpCol ~= 0 or dpRow ~= 0 then -- 614
			reloadDirCol = dpCol -- 616
			reloadDirRow = dpRow -- 617
			reloadStepEdge = true -- 618
		else -- 618
			local rMagL = hypot(raw.leftX, raw.leftY) -- 620
			if rMagL >= 0.45 then -- 620
				local ux = raw.leftX / rMagL -- 622
				local uy = -raw.leftY / rMagL -- 623
				local qCol = ux > 0.38 and 1 or (ux < -0.38 and -1 or 0) -- 624
				local qRow = uy > 0.38 and 1 or (uy < -0.38 and -1 or 0) -- 625
				if qCol ~= self.reloadStickCol or qRow ~= self.reloadStickRow then -- 625
					self.reloadStickCol = qCol -- 627
					self.reloadStickRow = qRow -- 628
					self.reloadStickTimer = 0.24 -- 629
					self.reloadStickArmed = true -- 630
					reloadDirCol = qCol -- 631
					reloadDirRow = qRow -- 632
					reloadStepEdge = true -- 633
					reloadAutoStep = true -- 634
				elseif self.reloadStickArmed then -- 634
					self.reloadStickTimer = self.reloadStickTimer - dt -- 636
					if self.reloadStickTimer <= 0 then -- 636
						self.reloadStickTimer = 0.16 -- 638
						reloadDirCol = qCol -- 639
						reloadDirRow = qRow -- 640
						reloadStepEdge = true -- 641
						reloadAutoStep = true -- 642
					end -- 642
				end -- 642
			else -- 642
				self.reloadStickCol = 0 -- 646
				self.reloadStickRow = 0 -- 647
				self.reloadStickTimer = 0 -- 648
				self.reloadStickArmed = false -- 649
			end -- 649
		end -- 649
	end -- 649
	local reloadConfirm = self.ctx.reloadActive and (aPressed or yPressed or rtEdge) -- 653
	local reloadReset = self.ctx.reloadActive and (bPressed or xPressed) -- 654
	local talentDelta = 0 -- 657
	local talentConfirm = false -- 658
	if self.ctx.talentOfferCount > 0 and not self.ctx.modal and not self.ctx.reloadActive and not self.ctx.craftActive then -- 658
		if lbPressed then -- 658
			talentDelta = talentDelta - 1 -- 660
		end -- 660
		if rbPressed then -- 660
			talentDelta = talentDelta + 1 -- 661
		end -- 661
		if lsPressed or rsPressed or raw.lb and rbPressed or raw.rb and lbPressed then -- 661
			talentConfirm = true -- 663
		end -- 663
	end -- 663
	local gpActive = self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.reloadActive and not self.ctx.craftActive -- 668
	local jumpHeld = false -- 669
	local jumpPressed = false -- 670
	local crouchHeld = false -- 671
	local crouchPressed = false -- 672
	local coverHeld = false -- 673
	local interactHeld = false -- 674
	local interactPressed = false -- 675
	local aimHeld = false -- 676
	local aimPressed = false -- 677
	local bottleCanceled = false -- 678
	local fireHeld = false -- 679
	local firePressed = false -- 680
	local flareHeld = false -- 681
	local flarePressed = false -- 682
	local artifactPressed = false -- 683
	if gpActive then -- 683
		jumpHeld = raw.a -- 686
		jumpPressed = aPressed -- 687
		if self.settings.crouchToggle and self.ctx.childMode then -- 687
			if bPressed and not self.wasBottleAiming then -- 687
				self.crouchToggled = not self.crouchToggled -- 691
				crouchPressed = true -- 692
			end -- 692
			crouchHeld = self.crouchToggled -- 694
		else -- 694
			crouchHeld = raw.b and not self.wasBottleAiming -- 696
			crouchPressed = bPressed and not self.wasBottleAiming -- 697
		end -- 697
		coverHeld = ltNow or raw.lb or self.ctx.childMode and stickSlowWalk -- 700
		interactHeld = raw.y or raw.rb -- 701
		interactPressed = yPressed or rbPressed -- 702
		if self.ctx.childMode then -- 702
			local rawBottleBtn = rtNow or raw.x -- 705
			if self.ctx.canBottleAim then -- 705
				if self.bottleCancelLock then -- 705
					if not rawBottleBtn then -- 705
						self.bottleCancelLock = false -- 709
					end -- 709
					aimHeld = false -- 711
				elseif rawBottleBtn and bPressed and self.wasBottleAiming then -- 711
					bottleCanceled = true -- 713
					self.bottleCancelLock = true -- 714
					self.wasBottleAiming = false -- 715
					aimHeld = false -- 716
				else -- 716
					aimHeld = rawBottleBtn -- 718
					aimPressed = (rtEdge or xPressed) and not self.wasBottleAiming -- 719
					self.wasBottleAiming = rawBottleBtn -- 720
				end -- 720
			else -- 720
				self.wasBottleAiming = false -- 723
				self.bottleCancelLock = false -- 724
			end -- 724
		else -- 724
			fireHeld = rtNow or raw.x -- 727
			firePressed = rtEdge or xPressed -- 728
			if lsPressed and self.ctx.talentOfferCount == 0 then -- 728
				artifactPressed = true -- 730
			end -- 730
		end -- 730
	end -- 730
	local hasAim = false -- 736
	local scale = math.max(0.25, self.ctx.uiScale) -- 737
	if gpActive and not self.ctx.childMode and self.ctx.canShoot then -- 737
		if self.ctx.playerFacing ~= self.aimLastFacing and rMag <= dzR then -- 737
			self.aimAngle = self.ctx.playerFacing >= 0 and 0 or math.pi -- 740
			self.aimLastFacing = self.ctx.playerFacing -- 741
		end -- 741
		if rMag > dzR then -- 741
			self.aimAngle = math.atan(-raw.rightY, raw.rightX) -- 744
			self.aimLastFacing = raw.rightX >= 0 and 1 or -1 -- 745
		end -- 745
		local pt = snapConeAim( -- 747
			self.ctx.playerScreenX, -- 748
			self.ctx.playerScreenY, -- 749
			math.cos(self.aimAngle), -- 750
			math.sin(self.aimAngle), -- 751
			215 * scale, -- 752
			self.ctx.stageW, -- 753
			self.ctx.stageH, -- 754
			self.ctx.enemyTargets, -- 755
			self.settings.aimAssist -- 756
		) -- 756
		self.aimX = pt.x -- 758
		self.aimY = pt.y -- 759
		hasAim = true -- 760
	elseif gpActive and self.ctx.childMode and self.ctx.canBottleAim then -- 760
		if aimPressed then -- 760
			self.bottleOffsetX = self.ctx.playerFacing * 155 * scale -- 763
			self.bottleOffsetY = 0 -- 764
		end -- 764
		if aimHeld then -- 764
			local steerX = rMag > dzR and raw.rightX or (lMag > dzL and raw.leftX or 0) -- 767
			local steerY = rMag > dzR and -raw.rightY or (lMag > dzL and -raw.leftY or 0) -- 768
			self.bottleOffsetX = clamp(self.bottleOffsetX + steerX * BOTTLE_AIM_SPEED_UI * scale * dt, -self.ctx.stageW * 0.48, self.ctx.stageW * 0.48) -- 769
			self.bottleOffsetY = clamp(self.bottleOffsetY + steerY * BOTTLE_AIM_SPEED_UI * 0.7 * scale * dt, -self.ctx.stageH * 0.35, self.ctx.stageH * 0.45) -- 774
			self.aimX = clamp( -- 779
				self.ctx.playerScreenX + self.bottleOffsetX, -- 779
				16, -- 779
				math.max(32, self.ctx.stageW - 16) -- 779
			) -- 779
			self.aimY = clamp( -- 780
				self.ctx.playerScreenY + self.bottleOffsetY, -- 780
				16, -- 780
				math.max(32, self.ctx.stageH - 16) -- 780
			) -- 780
			hasAim = true -- 781
		end -- 781
	end -- 781
	self.prevA = raw.a -- 786
	self.prevB = raw.b -- 787
	self.prevX = raw.x -- 788
	self.prevY = raw.y -- 789
	self.prevUp = raw.up -- 790
	self.prevDown = raw.down -- 791
	self.prevLeft = raw.left -- 792
	self.prevRight = raw.right -- 793
	self.prevLb = raw.lb -- 794
	self.prevRb = raw.rb -- 795
	self.prevLs = raw.ls -- 796
	self.prevRs = raw.rs -- 797
	self.prevBack = raw.back -- 798
	self.prevStart = raw.start -- 799
	self.prevRtPressed = rtNow -- 800
	return { -- 802
		hadGamepadInput = hadGamepadInput, -- 803
		anyButtonPressed = anyButtonPressed, -- 804
		moveX = moveX, -- 805
		moveY = moveY, -- 806
		jumpHeld = jumpHeld, -- 807
		jumpPressed = jumpPressed, -- 808
		crouchHeld = crouchHeld, -- 809
		crouchPressed = crouchPressed, -- 810
		coverHeld = coverHeld, -- 811
		interactHeld = interactHeld, -- 812
		interactPressed = interactPressed, -- 813
		aimHeld = aimHeld, -- 814
		aimPressed = aimPressed, -- 815
		bottleCanceled = bottleCanceled, -- 816
		fireHeld = fireHeld, -- 817
		firePressed = firePressed, -- 818
		flareHeld = flareHeld, -- 819
		flarePressed = flarePressed, -- 820
		pausePressed = pausePressed, -- 821
		retryPressed = retryPressed, -- 822
		retryHoldProgress = retryHoldProgress, -- 823
		artifactPressed = artifactPressed, -- 824
		hasAim = hasAim, -- 825
		aimX = self.aimX, -- 826
		aimY = self.aimY, -- 827
		navUp = navUp, -- 828
		navDown = navDown, -- 829
		navLeft = navLeft, -- 830
		navRight = navRight, -- 831
		navConfirm = navConfirm, -- 832
		navBack = navBack, -- 833
		navPrevTab = navPrevTab, -- 834
		navNextTab = navNextTab, -- 835
		reloadDirCol = reloadDirCol, -- 836
		reloadDirRow = reloadDirRow, -- 837
		reloadStepEdge = reloadStepEdge, -- 838
		reloadAutoStep = reloadAutoStep, -- 839
		reloadConfirm = reloadConfirm, -- 840
		reloadReset = reloadReset, -- 841
		talentDelta = talentDelta, -- 842
		talentConfirm = talentConfirm -- 843
	} -- 843
end -- 475
return ____exports -- 475