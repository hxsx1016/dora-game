-- [ts]: gamepad_core.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Controller = ____Dora.Controller -- 7
local Node = ____Dora.Node -- 7
local Size = ____Dora.Size -- 7
local Vec2 = ____Dora.Vec2 -- 7
local ____aim_assist = require("Script.watch.input.aim_assist") -- 8
local snapConeAim = ____aim_assist.snapConeAim -- 8
local ____controls_config = require("Script.watch.controls_config") -- 9
local defaultControlSettings = ____controls_config.defaultControlSettings -- 12
local saveControlSettings = ____controls_config.saveControlSettings -- 13
local MAX_CONTROLLER_SLOTS = 4 -- 105
local STICK_MENU_DEADZONE = 0.55 -- 106
local MENU_REPEAT_INITIAL = 0.38 -- 107
local MENU_REPEAT_INTERVAL = 0.13 -- 108
local TRIGGER_PRESS_THRESHOLD = 0.35 -- 109
local TRIGGER_RELEASE_THRESHOLD = 0.2 -- 110
local RETRY_HOLD_SEC = 0.55 -- 111
local BOTTLE_AIM_SPEED_UI = 460 -- 112
local function emptyRaw() -- 137
	return { -- 138
		a = false, -- 139
		b = false, -- 139
		x = false, -- 139
		y = false, -- 139
		up = false, -- 140
		down = false, -- 140
		left = false, -- 140
		right = false, -- 140
		lb = false, -- 141
		rb = false, -- 141
		ls = false, -- 141
		rs = false, -- 141
		back = false, -- 142
		start = false, -- 142
		leftX = 0, -- 143
		leftY = 0, -- 143
		rightX = 0, -- 143
		rightY = 0, -- 143
		lt = 0, -- 144
		rt = 0 -- 144
	} -- 144
end -- 137
local function clamp(v, lo, hi) -- 148
	return v < lo and lo or (v > hi and hi or v) -- 149
end -- 148
local function hypot(dx, dy) -- 152
	return math.sqrt(dx * dx + dy * dy) -- 153
end -- 152
local function safeButtonPressed(id, btn) -- 156
	if type(Controller) == "nil" then -- 157
		return false -- 157
	end -- 157
	return Controller:isButtonPressed(id, btn) -- 158
end -- 156
local function safeButtonDown(id, btn) -- 161
	if type(Controller) == "nil" then -- 162
		return false -- 162
	end -- 162
	return Controller:isButtonDown(id, btn) -- 163
end -- 161
local function safeAxis(id, axis) -- 166
	if type(Controller) == "nil" then -- 167
		return 0 -- 167
	end -- 167
	local v = Controller:getAxis(id, axis) -- 168
	return type(v) == "number" and v or 0 -- 169
end -- 166
____exports.GamepadRouter = __TS__Class() -- 172
local GamepadRouter = ____exports.GamepadRouter -- 172
GamepadRouter.name = "GamepadRouter" -- 172
function GamepadRouter.prototype.____constructor(self, sharedSettings) -- 246
	self.activeControllerId = 0 -- 174
	self.latchedButtons = {} -- 178
	self.ctx = { -- 180
		stageW = 1280, -- 181
		stageH = 720, -- 182
		uiScale = 1, -- 183
		modal = true, -- 184
		gameplayActive = false, -- 185
		reloadActive = false, -- 186
		craftActive = false, -- 187
		talentOfferCount = 0, -- 188
		childMode = false, -- 189
		allowDepth = false, -- 190
		canShoot = false, -- 191
		canBottleAim = false, -- 192
		playerRolling = false, -- 193
		inLowArch = false, -- 194
		inTowerEnd = false, -- 195
		playerFacing = 1, -- 196
		playerScreenX = 640, -- 197
		playerScreenY = 240, -- 198
		enemyTargets = {} -- 199
	} -- 199
	self.prevA = false -- 202
	self.prevB = false -- 203
	self.prevX = false -- 204
	self.prevY = false -- 205
	self.prevUp = false -- 206
	self.prevDown = false -- 207
	self.prevLeft = false -- 208
	self.prevRight = false -- 209
	self.prevLb = false -- 210
	self.prevRb = false -- 211
	self.prevLs = false -- 212
	self.prevRs = false -- 213
	self.prevBack = false -- 214
	self.prevStart = false -- 215
	self.ltPressed = false -- 216
	self.rtPressed = false -- 217
	self.prevRtPressed = false -- 218
	self.chordLocked = false -- 220
	self.backHoldSec = 0 -- 221
	self.backRetryFired = false -- 222
	self.crouchToggled = false -- 224
	self.bottleCancelLock = false -- 225
	self.repeatDirX = 0 -- 227
	self.repeatDirY = 0 -- 228
	self.repeatTimer = 0 -- 229
	self.reloadStickCol = 0 -- 231
	self.reloadStickRow = 0 -- 232
	self.reloadStickTimer = 0 -- 233
	self.reloadStickArmed = false -- 234
	self.aimAngle = 0 -- 236
	self.aimLastFacing = 1 -- 237
	self.aimX = 640 -- 238
	self.aimY = 260 -- 239
	self.bottleOffsetX = 160 -- 240
	self.bottleOffsetY = 0 -- 241
	self.wasBottleAiming = false -- 242
	self.lastDt = 1 / 60 -- 244
	self.settings = sharedSettings ~= nil and sharedSettings or defaultControlSettings() -- 247
end -- 246
function GamepadRouter.prototype.attach(self, parent) -- 250
	if self.listenerNode ~= nil then -- 251
		return -- 252
	end -- 252
	local n = Node() -- 254
	n.size = Size(0, 0) -- 255
	n.position = Vec2(0, 0) -- 256
	n.order = 115 -- 257
	n.controllerEnabled = true -- 258
	n.touchEnabled = false -- 259
	n:onButtonDown(function(controllerId, buttonName) -- 261
		self.activeControllerId = controllerId -- 262
		self.latchedButtons[buttonName] = true -- 263
	end) -- 261
	n:onAxis(function(controllerId, _axisName, value) -- 266
		if math.abs(value) > 0.35 then -- 267
			self.activeControllerId = controllerId -- 268
		end -- 268
	end) -- 266
	n:addTo(parent) -- 272
	self.listenerNode = n -- 273
end -- 250
function GamepadRouter.prototype.setSimulatedState(self, state) -- 276
	self.simState = state -- 277
end -- 276
function GamepadRouter.prototype.toggleLayout(self) -- 280
	self.settings.gamepadLayout = self.settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 281
	saveControlSettings(self.settings) -- 282
	return self.settings.gamepadLayout -- 283
end -- 280
function GamepadRouter.prototype.toggleAimAssist(self) -- 286
	self.settings.aimAssist = not self.settings.aimAssist -- 287
	saveControlSettings(self.settings) -- 288
	return self.settings.aimAssist -- 289
end -- 286
function GamepadRouter.prototype.toggleCrouchMode(self) -- 292
	self.settings.crouchToggle = not self.settings.crouchToggle -- 293
	if not self.settings.crouchToggle then -- 294
		self.crouchToggled = false -- 295
	end -- 295
	saveControlSettings(self.settings) -- 297
	return self.settings.crouchToggle -- 298
end -- 292
function GamepadRouter.prototype.setFrameContext(self, next, dt) -- 301
	self.lastDt = math.min( -- 302
		0.05, -- 302
		math.max(0.001, dt) -- 302
	) -- 302
	local wasChild = self.ctx.childMode -- 303
	local wasReload = self.ctx.reloadActive -- 304
	self.ctx = next -- 305
	if wasChild ~= next.childMode or next.modal then -- 306
		self.crouchToggled = false -- 307
	end -- 307
	if next.reloadActive and not wasReload then -- 309
		self.reloadStickCol = 0 -- 310
		self.reloadStickRow = 0 -- 311
		self.reloadStickTimer = 0 -- 312
		self.reloadStickArmed = false -- 313
	end -- 313
	if not next.canBottleAim then -- 315
		self.wasBottleAiming = false -- 316
		self.bottleCancelLock = false -- 317
	end -- 317
end -- 301
function GamepadRouter.prototype.clearTransient(self) -- 321
	self.latchedButtons = {} -- 322
	self.backHoldSec = 0 -- 323
	self.backRetryFired = false -- 324
	self.chordLocked = false -- 325
	self.crouchToggled = false -- 326
	self.bottleCancelLock = false -- 327
	self.wasBottleAiming = false -- 328
	self.repeatDirX = 0 -- 329
	self.repeatDirY = 0 -- 330
	self.repeatTimer = 0 -- 331
end -- 321
function GamepadRouter.prototype.sampleRaw(self) -- 334
	if self.simState ~= nil then -- 335
		local s = self.simState -- 336
		return { -- 337
			a = s.a == true, -- 338
			b = s.b == true, -- 339
			x = s.x == true, -- 340
			y = s.y == true, -- 341
			up = s.up == true, -- 342
			down = s.down == true, -- 343
			left = s.left == true, -- 344
			right = s.right == true, -- 345
			lb = s.lb == true, -- 346
			rb = s.rb == true, -- 347
			ls = s.ls == true, -- 348
			rs = s.rs == true, -- 349
			back = s.back == true, -- 350
			start = s.start == true, -- 351
			leftX = s.leftX or 0, -- 352
			leftY = s.leftY or 0, -- 353
			rightX = s.rightX or 0, -- 354
			rightY = s.rightY or 0, -- 355
			lt = s.lt or 0, -- 356
			rt = s.rt or 0 -- 357
		} -- 357
	end -- 357
	local out = emptyRaw() -- 361
	if type(Controller) == "nil" then -- 362
		return out -- 363
	end -- 363
	local cid = 0 -- 366
	do -- 366
		cid = 0 -- 367
		while cid < MAX_CONTROLLER_SLOTS do -- 367
			local a = safeButtonPressed(cid, "a") or safeButtonDown(cid, "a") -- 368
			local b = safeButtonPressed(cid, "b") or safeButtonDown(cid, "b") -- 369
			local x = safeButtonPressed(cid, "x") or safeButtonDown(cid, "x") -- 370
			local y = safeButtonPressed(cid, "y") or safeButtonDown(cid, "y") -- 371
			local up = safeButtonPressed(cid, "dpup") or safeButtonDown(cid, "dpup") -- 372
			local down = safeButtonPressed(cid, "dpdown") or safeButtonDown(cid, "dpdown") -- 373
			local left = safeButtonPressed(cid, "dpleft") or safeButtonDown(cid, "dpleft") -- 374
			local right = safeButtonPressed(cid, "dpright") or safeButtonDown(cid, "dpright") -- 375
			local lb = safeButtonPressed(cid, "leftshoulder") or safeButtonDown(cid, "leftshoulder") -- 376
			local rb = safeButtonPressed(cid, "rightshoulder") or safeButtonDown(cid, "rightshoulder") -- 377
			local ls = safeButtonPressed(cid, "leftstick") or safeButtonDown(cid, "leftstick") -- 378
			local rs = safeButtonPressed(cid, "rightstick") or safeButtonDown(cid, "rightstick") -- 379
			local back = safeButtonPressed(cid, "back") or safeButtonDown(cid, "back") -- 380
			local start = safeButtonPressed(cid, "start") or safeButtonDown(cid, "start") -- 381
			local lx = safeAxis(cid, "leftx") -- 383
			local ly = safeAxis(cid, "lefty") -- 384
			local rx = safeAxis(cid, "rightx") -- 385
			local ry = safeAxis(cid, "righty") -- 386
			local lt = math.max( -- 387
				0, -- 387
				safeAxis(cid, "lefttrigger") -- 387
			) -- 387
			local rt = math.max( -- 388
				0, -- 388
				safeAxis(cid, "righttrigger") -- 388
			) -- 388
			local anyBtn = a or b or x or y or up or down or left or right or lb or rb or ls or rs or back or start -- 390
			local anyAxis = math.abs(lx) > 0.25 or math.abs(ly) > 0.25 or math.abs(rx) > 0.25 or math.abs(ry) > 0.25 or lt > 0.25 or rt > 0.25 -- 391
			if anyBtn or anyAxis then -- 392
				self.activeControllerId = cid -- 393
			end -- 393
			if a then -- 395
				out.a = true -- 395
			end -- 395
			if b then -- 396
				out.b = true -- 396
			end -- 396
			if x then -- 397
				out.x = true -- 397
			end -- 397
			if y then -- 398
				out.y = true -- 398
			end -- 398
			if up then -- 399
				out.up = true -- 399
			end -- 399
			if down then -- 400
				out.down = true -- 400
			end -- 400
			if left then -- 401
				out.left = true -- 401
			end -- 401
			if right then -- 402
				out.right = true -- 402
			end -- 402
			if lb then -- 403
				out.lb = true -- 403
			end -- 403
			if rb then -- 404
				out.rb = true -- 404
			end -- 404
			if ls then -- 405
				out.ls = true -- 405
			end -- 405
			if rs then -- 406
				out.rs = true -- 406
			end -- 406
			if back then -- 407
				out.back = true -- 407
			end -- 407
			if start then -- 408
				out.start = true -- 408
			end -- 408
			if math.abs(lx) > math.abs(out.leftX) then -- 410
				out.leftX = lx -- 410
			end -- 410
			if math.abs(ly) > math.abs(out.leftY) then -- 411
				out.leftY = ly -- 411
			end -- 411
			if math.abs(rx) > math.abs(out.rightX) then -- 412
				out.rightX = rx -- 412
			end -- 412
			if math.abs(ry) > math.abs(out.rightY) then -- 413
				out.rightY = ry -- 413
			end -- 413
			if lt > out.lt then -- 414
				out.lt = lt -- 414
			end -- 414
			if rt > out.rt then -- 415
				out.rt = rt -- 415
			end -- 415
			cid = cid + 1 -- 367
		end -- 367
	end -- 367
	if self.latchedButtons.a then -- 418
		out.a = true -- 418
	end -- 418
	if self.latchedButtons.b then -- 419
		out.b = true -- 419
	end -- 419
	if self.latchedButtons.x then -- 420
		out.x = true -- 420
	end -- 420
	if self.latchedButtons.y then -- 421
		out.y = true -- 421
	end -- 421
	if self.latchedButtons.dpup then -- 422
		out.up = true -- 422
	end -- 422
	if self.latchedButtons.dpdown then -- 423
		out.down = true -- 423
	end -- 423
	if self.latchedButtons.dpleft then -- 424
		out.left = true -- 424
	end -- 424
	if self.latchedButtons.dpright then -- 425
		out.right = true -- 425
	end -- 425
	if self.latchedButtons.leftshoulder then -- 426
		out.lb = true -- 426
	end -- 426
	if self.latchedButtons.rightshoulder then -- 427
		out.rb = true -- 427
	end -- 427
	if self.latchedButtons.leftstick then -- 428
		out.ls = true -- 428
	end -- 428
	if self.latchedButtons.rightstick then -- 429
		out.rs = true -- 429
	end -- 429
	if self.latchedButtons.back then -- 430
		out.back = true -- 430
	end -- 430
	if self.latchedButtons.start then -- 431
		out.start = true -- 431
	end -- 431
	self.latchedButtons = {} -- 432
	return out -- 434
end -- 334
function GamepadRouter.prototype.consumeSnapshot(self) -- 437
	local dt = self.lastDt -- 438
	local raw = self:sampleRaw() -- 439
	local ____table_ltPressed_0 -- 441
	if self.ltPressed then -- 441
		____table_ltPressed_0 = raw.lt > TRIGGER_RELEASE_THRESHOLD -- 441
	else -- 441
		____table_ltPressed_0 = raw.lt > TRIGGER_PRESS_THRESHOLD -- 441
	end -- 441
	local ltNow = ____table_ltPressed_0 -- 441
	local ____table_rtPressed_1 -- 442
	if self.rtPressed then -- 442
		____table_rtPressed_1 = raw.rt > TRIGGER_RELEASE_THRESHOLD -- 442
	else -- 442
		____table_rtPressed_1 = raw.rt > TRIGGER_PRESS_THRESHOLD -- 442
	end -- 442
	local rtNow = ____table_rtPressed_1 -- 442
	self.ltPressed = ltNow -- 443
	self.rtPressed = rtNow -- 444
	local aPressed = raw.a and not self.prevA -- 446
	local bPressed = raw.b and not self.prevB -- 447
	local xPressed = raw.x and not self.prevX -- 448
	local yPressed = raw.y and not self.prevY -- 449
	local upPressed = raw.up and not self.prevUp -- 450
	local downPressed = raw.down and not self.prevDown -- 451
	local leftPressed = raw.left and not self.prevLeft -- 452
	local rightPressed = raw.right and not self.prevRight -- 453
	local lbPressed = raw.lb and not self.prevLb -- 454
	local rbPressed = raw.rb and not self.prevRb -- 455
	local lsPressed = raw.ls and not self.prevLs -- 456
	local rsPressed = raw.rs and not self.prevRs -- 457
	local startPressed = raw.start and not self.prevStart -- 458
	local rtEdge = rtNow and not self.prevRtPressed -- 459
	local dzL = self.settings.deadzoneLeft -- 461
	local dzR = self.settings.deadzoneRight -- 462
	local lMag = hypot(raw.leftX, raw.leftY) -- 463
	local rMag = hypot(raw.rightX, raw.rightY) -- 464
	local hadGamepadInput = raw.a or raw.b or raw.x or raw.y or raw.up or raw.down or raw.left or raw.right or raw.lb or raw.rb or raw.ls or raw.rs or raw.back or raw.start or ltNow or rtNow or lMag > dzL or rMag > dzR -- 465
	local anyButtonPressed = aPressed or bPressed or xPressed or yPressed or startPressed or lbPressed or rbPressed -- 470
	local pausePressed = false -- 473
	local retryPressed = false -- 474
	if raw.back and raw.start then -- 475
		self.chordLocked = true -- 476
		self.backHoldSec = 0 -- 477
		self.backRetryFired = false -- 478
	elseif self.chordLocked then -- 479
		if not raw.back and not raw.start then -- 480
			self.chordLocked = false -- 481
		end -- 481
		self.backHoldSec = 0 -- 483
		self.backRetryFired = false -- 484
	else -- 484
		if startPressed and not raw.back then -- 486
			pausePressed = true -- 487
		end -- 487
		if raw.back and not raw.start and self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.inTowerEnd then -- 489
			self.backHoldSec = self.backHoldSec + dt -- 490
			if self.backHoldSec >= RETRY_HOLD_SEC and not self.backRetryFired then -- 491
				retryPressed = true -- 492
				self.backRetryFired = true -- 493
			end -- 493
		else -- 493
			self.backHoldSec = 0 -- 496
			self.backRetryFired = false -- 497
		end -- 497
	end -- 497
	local retryHoldProgress = raw.back and not self.chordLocked and not raw.start and self.ctx.gameplayActive and not self.ctx.modal and clamp(self.backHoldSec / RETRY_HOLD_SEC, 0, 1) or 0 -- 500
	local dpadX = (raw.right and 1 or 0) - (raw.left and 1 or 0) -- 505
	local dpadY = (raw.down and 1 or 0) - (raw.up and 1 or 0) -- 506
	local stickMoveX = 0 -- 507
	local stickMoveY = 0 -- 508
	local stickSlowWalk = false -- 509
	if lMag > dzL then -- 510
		local normMag = clamp( -- 511
			(lMag - dzL) / math.max(0.05, 1 - dzL), -- 511
			0, -- 511
			1 -- 511
		) -- 511
		local nx = raw.leftX / lMag -- 512
		local ny = raw.leftY / lMag -- 513
		if self.ctx.allowDepth then -- 514
			local maxAxis = math.max( -- 515
				math.abs(nx), -- 515
				math.abs(ny), -- 515
				0.001 -- 515
			) -- 515
			stickMoveX = clamp(nx / maxAxis * normMag, -1, 1) -- 516
			stickMoveY = clamp(ny / maxAxis * normMag, -1, 1) -- 517
		else -- 517
			if math.abs(raw.leftX) > dzL * 0.85 then -- 519
				stickMoveX = raw.leftX > 0 and 1 or -1 -- 520
				if lMag < 0.56 then -- 521
					stickSlowWalk = true -- 522
				end -- 522
			end -- 522
			if raw.leftY > 0.65 and math.abs(raw.leftY) > math.abs(raw.leftX) * 1.15 then -- 525
				stickMoveY = 1 -- 526
			elseif raw.leftY < -0.65 and math.abs(raw.leftY) > math.abs(raw.leftX) * 1.15 then -- 527
				stickMoveY = -1 -- 528
			end -- 528
		end -- 528
	end -- 528
	local bottleSteerLocksMove = self.ctx.gameplayActive and self.ctx.childMode and self.ctx.canBottleAim and (rtNow or raw.x) and not self.bottleCancelLock and rMag <= dzR -- 532
	local moveX = bottleSteerLocksMove and 0 or (dpadX ~= 0 and dpadX or stickMoveX) -- 534
	local moveY = bottleSteerLocksMove and 0 or (dpadY ~= 0 and dpadY or stickMoveY) -- 535
	local sMenuX = math.abs(raw.leftX) >= STICK_MENU_DEADZONE and (raw.leftX > 0 and 1 or -1) or 0 -- 538
	local sMenuY = math.abs(raw.leftY) >= STICK_MENU_DEADZONE and (raw.leftY > 0 and 1 or -1) or 0 -- 539
	local stickNavX = 0 -- 540
	local stickNavY = 0 -- 541
	if sMenuX == 0 and sMenuY == 0 then -- 542
		self.repeatDirX = 0 -- 543
		self.repeatDirY = 0 -- 544
		self.repeatTimer = 0 -- 545
	elseif sMenuX ~= self.repeatDirX or sMenuY ~= self.repeatDirY then -- 546
		self.repeatDirX = sMenuX -- 547
		self.repeatDirY = sMenuY -- 548
		self.repeatTimer = MENU_REPEAT_INITIAL -- 549
		stickNavX = sMenuX -- 550
		stickNavY = sMenuY -- 551
	else -- 551
		self.repeatTimer = self.repeatTimer - dt -- 553
		if self.repeatTimer <= 0 then -- 554
			self.repeatTimer = MENU_REPEAT_INTERVAL -- 555
			stickNavX = sMenuX -- 556
			stickNavY = sMenuY -- 557
		end -- 557
	end -- 557
	local navUp = upPressed or stickNavY < 0 -- 561
	local navDown = downPressed or stickNavY > 0 -- 562
	local navLeft = leftPressed or stickNavX < 0 -- 563
	local navRight = rightPressed or stickNavX > 0 -- 564
	local ____temp_2 -- 565
	if self.settings.gamepadLayout == "nintendo" then -- 565
		____temp_2 = bPressed -- 565
	else -- 565
		____temp_2 = aPressed -- 565
	end -- 565
	local navConfirm = ____temp_2 -- 565
	local ____temp_3 -- 566
	if self.settings.gamepadLayout == "nintendo" then -- 566
		____temp_3 = aPressed -- 566
	else -- 566
		____temp_3 = bPressed -- 566
	end -- 566
	local navBack = ____temp_3 -- 566
	local navPrevTab = lbPressed -- 567
	local navNextTab = rbPressed -- 568
	local reloadDirCol = 0 -- 571
	local reloadDirRow = 0 -- 572
	local reloadStepEdge = false -- 573
	local reloadAutoStep = false -- 574
	if self.ctx.reloadActive then -- 575
		local dpCol = (rightPressed and 1 or 0) - (leftPressed and 1 or 0) -- 576
		local dpRow = (upPressed and 1 or 0) - (downPressed and 1 or 0) -- 577
		if dpCol ~= 0 or dpRow ~= 0 then -- 578
			reloadDirCol = dpCol -- 579
			reloadDirRow = dpRow -- 580
			reloadStepEdge = true -- 581
		else -- 581
			local rMagL = hypot(raw.leftX, raw.leftY) -- 583
			if rMagL >= 0.45 then -- 584
				local ux = raw.leftX / rMagL -- 585
				local uy = -raw.leftY / rMagL -- 586
				local qCol = ux > 0.38 and 1 or (ux < -0.38 and -1 or 0) -- 587
				local qRow = uy > 0.38 and 1 or (uy < -0.38 and -1 or 0) -- 588
				if qCol ~= self.reloadStickCol or qRow ~= self.reloadStickRow then -- 589
					self.reloadStickCol = qCol -- 590
					self.reloadStickRow = qRow -- 591
					self.reloadStickTimer = 0.24 -- 592
					self.reloadStickArmed = true -- 593
					reloadDirCol = qCol -- 594
					reloadDirRow = qRow -- 595
					reloadStepEdge = true -- 596
					reloadAutoStep = true -- 597
				elseif self.reloadStickArmed then -- 598
					self.reloadStickTimer = self.reloadStickTimer - dt -- 599
					if self.reloadStickTimer <= 0 then -- 600
						self.reloadStickTimer = 0.16 -- 601
						reloadDirCol = qCol -- 602
						reloadDirRow = qRow -- 603
						reloadStepEdge = true -- 604
						reloadAutoStep = true -- 605
					end -- 605
				end -- 605
			else -- 605
				self.reloadStickCol = 0 -- 609
				self.reloadStickRow = 0 -- 610
				self.reloadStickTimer = 0 -- 611
				self.reloadStickArmed = false -- 612
			end -- 612
		end -- 612
	end -- 612
	local ____temp_4 -- 616
	if self.settings.gamepadLayout == "nintendo" then -- 616
		____temp_4 = bPressed -- 616
	else -- 616
		____temp_4 = aPressed -- 616
	end -- 616
	local gpReloadConfirmBtn = ____temp_4 -- 616
	local ____temp_5 -- 617
	if self.settings.gamepadLayout == "nintendo" then -- 617
		____temp_5 = aPressed -- 617
	else -- 617
		____temp_5 = bPressed -- 617
	end -- 617
	local gpReloadResetBtn = ____temp_5 -- 617
	local reloadConfirm = self.ctx.reloadActive and (gpReloadConfirmBtn or yPressed or rtEdge) -- 618
	local reloadReset = self.ctx.reloadActive and (gpReloadResetBtn or xPressed) -- 619
	local talentDelta = 0 -- 622
	local talentConfirm = false -- 623
	if self.ctx.talentOfferCount > 0 and not self.ctx.reloadActive and not self.ctx.craftActive then -- 624
		if lbPressed then -- 625
			talentDelta = talentDelta - 1 -- 625
		end -- 625
		if rbPressed then -- 626
			talentDelta = talentDelta + 1 -- 626
		end -- 626
		if lsPressed or rsPressed or raw.lb and rbPressed or raw.rb and lbPressed then -- 627
			talentConfirm = true -- 628
		end -- 628
	end -- 628
	local gpActive = self.ctx.gameplayActive and not self.ctx.modal and not self.ctx.reloadActive and not self.ctx.craftActive -- 633
	local jumpHeld = false -- 634
	local jumpPressed = false -- 635
	local crouchHeld = false -- 636
	local crouchPressed = false -- 637
	local coverHeld = false -- 638
	local interactHeld = false -- 639
	local interactPressed = false -- 640
	local aimHeld = false -- 641
	local aimPressed = false -- 642
	local bottleCanceled = false -- 643
	local fireHeld = false -- 644
	local firePressed = false -- 645
	local flareHeld = false -- 646
	local flarePressed = false -- 647
	local artifactPressed = false -- 648
	if gpActive then -- 650
		jumpHeld = raw.a -- 651
		jumpPressed = aPressed -- 652
		if self.settings.crouchToggle and self.ctx.childMode then -- 654
			if bPressed and not self.wasBottleAiming then -- 655
				self.crouchToggled = not self.crouchToggled -- 656
				crouchPressed = true -- 657
			end -- 657
			crouchHeld = self.crouchToggled -- 659
		else -- 659
			crouchHeld = raw.b and not self.wasBottleAiming -- 661
			crouchPressed = bPressed and not self.wasBottleAiming -- 662
		end -- 662
		coverHeld = ltNow or raw.lb or self.ctx.childMode and stickSlowWalk -- 665
		interactHeld = raw.y or raw.rb -- 666
		interactPressed = yPressed or rbPressed -- 667
		if self.ctx.childMode then -- 669
			local rawBottleBtn = rtNow or raw.x -- 670
			if self.ctx.canBottleAim then -- 671
				if self.bottleCancelLock then -- 672
					if not rawBottleBtn then -- 673
						self.bottleCancelLock = false -- 674
					end -- 674
					aimHeld = false -- 676
				elseif rawBottleBtn and bPressed and self.wasBottleAiming then -- 677
					bottleCanceled = true -- 678
					self.bottleCancelLock = true -- 679
					self.wasBottleAiming = false -- 680
					aimHeld = false -- 681
				else -- 681
					aimHeld = rawBottleBtn -- 683
					aimPressed = (rtEdge or xPressed) and not self.wasBottleAiming -- 684
					self.wasBottleAiming = rawBottleBtn -- 685
				end -- 685
			else -- 685
				self.wasBottleAiming = false -- 688
				self.bottleCancelLock = false -- 689
			end -- 689
		else -- 689
			fireHeld = rtNow or raw.x -- 692
			firePressed = rtEdge or xPressed -- 693
			if lsPressed and self.ctx.talentOfferCount == 0 then -- 694
				artifactPressed = true -- 695
			end -- 695
		end -- 695
	end -- 695
	local hasAim = false -- 701
	local scale = math.max(0.25, self.ctx.uiScale) -- 702
	if gpActive and not self.ctx.childMode and self.ctx.canShoot then -- 703
		if self.ctx.playerFacing ~= self.aimLastFacing and rMag <= dzR then -- 704
			self.aimAngle = self.ctx.playerFacing >= 0 and 0 or math.pi -- 705
			self.aimLastFacing = self.ctx.playerFacing -- 706
		end -- 706
		if rMag > dzR then -- 708
			self.aimAngle = math.atan(-raw.rightY, raw.rightX) -- 709
			self.aimLastFacing = raw.rightX >= 0 and 1 or -1 -- 710
		end -- 710
		local pt = snapConeAim( -- 712
			self.ctx.playerScreenX, -- 713
			self.ctx.playerScreenY, -- 714
			math.cos(self.aimAngle), -- 715
			math.sin(self.aimAngle), -- 716
			215 * scale, -- 717
			self.ctx.stageW, -- 718
			self.ctx.stageH, -- 719
			self.ctx.enemyTargets, -- 720
			self.settings.aimAssist -- 721
		) -- 721
		self.aimX = pt.x -- 723
		self.aimY = pt.y -- 724
		hasAim = true -- 725
	elseif gpActive and self.ctx.childMode and self.ctx.canBottleAim then -- 726
		if aimPressed then -- 727
			self.bottleOffsetX = self.ctx.playerFacing * 155 * scale -- 728
			self.bottleOffsetY = 0 -- 729
		end -- 729
		if aimHeld then -- 731
			local steerX = rMag > dzR and raw.rightX or (lMag > dzL and raw.leftX or 0) -- 732
			local steerY = rMag > dzR and -raw.rightY or (lMag > dzL and -raw.leftY or 0) -- 733
			self.bottleOffsetX = clamp(self.bottleOffsetX + steerX * BOTTLE_AIM_SPEED_UI * scale * dt, -self.ctx.stageW * 0.48, self.ctx.stageW * 0.48) -- 734
			self.bottleOffsetY = clamp(self.bottleOffsetY + steerY * BOTTLE_AIM_SPEED_UI * 0.7 * scale * dt, -self.ctx.stageH * 0.35, self.ctx.stageH * 0.45) -- 739
			self.aimX = clamp( -- 744
				self.ctx.playerScreenX + self.bottleOffsetX, -- 744
				16, -- 744
				math.max(32, self.ctx.stageW - 16) -- 744
			) -- 744
			self.aimY = clamp( -- 745
				self.ctx.playerScreenY + self.bottleOffsetY, -- 745
				16, -- 745
				math.max(32, self.ctx.stageH - 16) -- 745
			) -- 745
			hasAim = true -- 746
		end -- 746
	end -- 746
	self.prevA = raw.a -- 750
	self.prevB = raw.b -- 751
	self.prevX = raw.x -- 752
	self.prevY = raw.y -- 753
	self.prevUp = raw.up -- 754
	self.prevDown = raw.down -- 755
	self.prevLeft = raw.left -- 756
	self.prevRight = raw.right -- 757
	self.prevLb = raw.lb -- 758
	self.prevRb = raw.rb -- 759
	self.prevLs = raw.ls -- 760
	self.prevRs = raw.rs -- 761
	self.prevBack = raw.back -- 762
	self.prevStart = raw.start -- 763
	self.prevRtPressed = rtNow -- 764
	return { -- 766
		hadGamepadInput = hadGamepadInput, -- 767
		anyButtonPressed = anyButtonPressed, -- 768
		moveX = moveX, -- 769
		moveY = moveY, -- 770
		jumpHeld = jumpHeld, -- 771
		jumpPressed = jumpPressed, -- 772
		crouchHeld = crouchHeld, -- 773
		crouchPressed = crouchPressed, -- 774
		coverHeld = coverHeld, -- 775
		interactHeld = interactHeld, -- 776
		interactPressed = interactPressed, -- 777
		aimHeld = aimHeld, -- 778
		aimPressed = aimPressed, -- 779
		bottleCanceled = bottleCanceled, -- 780
		fireHeld = fireHeld, -- 781
		firePressed = firePressed, -- 782
		flareHeld = flareHeld, -- 783
		flarePressed = flarePressed, -- 784
		pausePressed = pausePressed, -- 785
		retryPressed = retryPressed, -- 786
		retryHoldProgress = retryHoldProgress, -- 787
		artifactPressed = artifactPressed, -- 788
		hasAim = hasAim, -- 789
		aimX = self.aimX, -- 790
		aimY = self.aimY, -- 791
		navUp = navUp, -- 792
		navDown = navDown, -- 793
		navLeft = navLeft, -- 794
		navRight = navRight, -- 795
		navConfirm = navConfirm, -- 796
		navBack = navBack, -- 797
		navPrevTab = navPrevTab, -- 798
		navNextTab = navNextTab, -- 799
		reloadDirCol = reloadDirCol, -- 800
		reloadDirRow = reloadDirRow, -- 801
		reloadStepEdge = reloadStepEdge, -- 802
		reloadAutoStep = reloadAutoStep, -- 803
		reloadConfirm = reloadConfirm, -- 804
		reloadReset = reloadReset, -- 805
		talentDelta = talentDelta, -- 806
		talentConfirm = talentConfirm -- 807
	} -- 807
end -- 437
return ____exports -- 437
