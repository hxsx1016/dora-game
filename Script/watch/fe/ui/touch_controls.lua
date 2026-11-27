-- [ts]: touch_controls.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 16
local BlendFunc = ____Dora.BlendFunc -- 16
local Color = ____Dora.Color -- 16
local DrawNode = ____Dora.DrawNode -- 16
local Node = ____Dora.Node -- 16
local Rect = ____Dora.Rect -- 16
local Vec2 = ____Dora.Vec2 -- 16
local ____aim_assist = require("Script.watch.aim_assist") -- 20
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 20
local ____platform = require("Script.watch.platform") -- 21
local canToggleFullscreen = ____platform.canToggleFullscreen -- 21
local isWebPlatform = ____platform.isWebPlatform -- 21
local ____adapter = require("Script.watch.fe.adapter") -- 29
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 29
local ____assets = require("Script.watch.fe.assets") -- 30
local AssetSlotHost = ____assets.AssetSlotHost -- 30
local ____textpool = require("Script.watch.fe.ui.textpool") -- 32
local TextPool = ____textpool.TextPool -- 32
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 34
local deriveInteractActionMeta = ____control_prompts.deriveInteractActionMeta -- 35
local isCutsceneBlockingPlay = ____control_prompts.isCutsceneBlockingPlay -- 36
local ____theme = require("Script.watch.fe.theme") -- 38
local PALETTE = ____theme.PALETTE -- 39
local drawBlossomDot = ____theme.drawBlossomDot -- 41
local drawDiamond = ____theme.drawDiamond -- 42
local drawHairline = ____theme.drawHairline -- 43
local drawSilkVeil = ____theme.drawSilkVeil -- 44
local fillRadialGlow = ____theme.fillRadialGlow -- 45
local fillVGradRect = ____theme.fillVGradRect -- 46
local toColor = ____theme.toColor -- 47
local visualTextWidth = ____theme.visualTextWidth -- 48
local TWO_PI = math.pi * 2 -- 51
local HALF_PI = math.pi * 0.5 -- 52
local STICK_BASE_R_LANDSCAPE = 64 -- 53
local function clamp(v, lo, hi) -- 72
	return v < lo and lo or (v > hi and hi or v) -- 73
end -- 72
local function accentPalette(accent) -- 76
	if accent == "cyan" then -- 77
		return PALETTE.cyan -- 77
	end -- 77
	if accent == "amber" then -- 78
		return PALETTE.amber -- 78
	end -- 78
	if accent == "rouge" then -- 79
		return PALETTE.rouge -- 79
	end -- 79
	if accent == "emerald" then -- 80
		return PALETTE.emerald -- 80
	end -- 80
	return PALETTE.silkLine -- 81
end -- 76
local function accentCore(accent) -- 84
	if accent == "cyan" then -- 85
		return PALETTE.cyanCore -- 85
	end -- 85
	if accent == "amber" then -- 86
		return PALETTE.amberCore -- 86
	end -- 86
	if accent == "rouge" then -- 87
		return PALETTE.crimsonCore -- 87
	end -- 87
	if accent == "emerald" then -- 88
		return PALETTE.emerald -- 88
	end -- 88
	return PALETTE.textBright -- 89
end -- 84
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 92
	if segments == nil then -- 101
		segments = 28 -- 101
	end -- 101
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 103
		return -- 103
	end -- 103
	local n = math.max( -- 104
		4, -- 104
		math.ceil(segments * math.min( -- 104
			1, -- 104
			math.abs(sweepRad) / TWO_PI -- 104
		)) -- 104
	) -- 104
	local prevX = cx + math.cos(startRad) * r -- 105
	local prevY = cy + math.sin(startRad) * r -- 106
	local i = 1 -- 107
	do -- 107
		i = 1 -- 108
		while i <= n do -- 108
			local a = startRad + sweepRad * i / n -- 109
			local nx = cx + math.cos(a) * r -- 110
			local ny = cy + math.sin(a) * r -- 111
			draw:drawSegment( -- 112
				Vec2(prevX, prevY), -- 112
				Vec2(nx, ny), -- 112
				thickness, -- 112
				color -- 112
			) -- 112
			prevX = nx -- 113
			prevY = ny -- 114
			i = i + 1 -- 108
		end -- 108
	end -- 108
end -- 92
local function fillCirclePoly(draw, cx, cy, r, fill, borderWidth, borderColor, segments) -- 118
	if borderWidth == nil then -- 124
		borderWidth = 0 -- 124
	end -- 124
	if segments == nil then -- 126
		segments = 26 -- 126
	end -- 126
	local pts = {} -- 128
	local i = 0 -- 129
	do -- 129
		i = 0 -- 130
		while i < segments do -- 130
			local a = TWO_PI * i / segments -- 131
			pts[#pts + 1] = Vec2( -- 132
				cx + math.cos(a) * r, -- 132
				cy + math.sin(a) * r -- 132
			) -- 132
			i = i + 1 -- 130
		end -- 130
	end -- 130
	if borderWidth > 0 and borderColor ~= nil then -- 134
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 135
	else -- 135
		draw:drawPolygon(pts, fill) -- 137
	end -- 137
end -- 118
local function isNearLowLedgeForButton(p) -- 141
	if p.childMode then -- 142
		return false -- 142
	end -- 142
	local a = p.player -- 143
	local probeX = a.x + a.facing * 26 -- 144
	local i = 0 -- 145
	do -- 145
		i = 0 -- 146
		while i < #p.boxes do -- 146
			do -- 146
				local b = p.boxes[i + 1] -- 147
				if b.broken == true or b.hidden == true then -- 148
					goto __continue25 -- 148
				end -- 148
				local h = b.y1 - b.y0 -- 149
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 150
					return true -- 152
				end -- 152
			end -- 152
			::__continue25:: -- 152
			i = i + 1 -- 146
		end -- 146
	end -- 146
	return false -- 155
end -- 141
local function isInLowArch(p) -- 158
	local arch = p.room.arch -- 159
	if arch.h <= 0 then -- 160
		return false -- 160
	end -- 160
	return p.player.x >= arch.x0 - 10 and p.player.x <= arch.x1 + 10 and p.player.y <= arch.y + arch.h -- 161
end -- 158
____exports.TouchControls = __TS__Class() -- 164
local TouchControls = ____exports.TouchControls -- 164
TouchControls.name = "TouchControls" -- 164
function TouchControls.prototype.____constructor(self, parent) -- 180
	self.lastMode = 1 -- 174
	self.lastScreen = "title" -- 175
	self.time = 0 -- 178
	self.overlayRoot = Node() -- 181
	self.overlayRoot.order = 60 -- 182
	self.overlayRoot:addTo(parent) -- 183
	self.deckDraw = DrawNode() -- 185
	self.deckDraw.order = 0 -- 186
	self.deckDraw:addTo(self.overlayRoot) -- 187
	self.padDraw = DrawNode() -- 189
	self.padDraw.order = 2 -- 190
	self.padDraw:addTo(self.overlayRoot) -- 191
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 193
	self.padInkDraw = DrawNode() -- 195
	self.padInkDraw.order = 5 -- 196
	self.padInkDraw:addTo(self.overlayRoot) -- 197
	local additive = BlendFunc("SrcAlpha", "One") -- 199
	self.padGlow = DrawNode() -- 200
	self.padGlow.order = 7 -- 201
	self.padGlow.blendFunc = additive -- 202
	self.padGlow:addTo(self.overlayRoot) -- 203
	self.texts = __TS__New(TextPool, self.overlayRoot, 10) -- 205
end -- 180
function TouchControls.prototype.getLayoutSummary(self, router) -- 209
	local buttonIds = {} -- 219
	local zoneIds = {} -- 220
	if self.lastContext ~= nil then -- 221
		local i = 0 -- 222
		do -- 222
			i = 0 -- 223
			while i < #self.lastContext.buttons do -- 223
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 224
				i = i + 1 -- 223
			end -- 223
		end -- 223
		do -- 223
			i = 0 -- 226
			while i < #self.lastContext.rectZones do -- 226
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 227
				i = i + 1 -- 226
			end -- 226
		end -- 226
	end -- 226
	local ____buttonIds_6 = buttonIds -- 231
	local ____zoneIds_7 = zoneIds -- 232
	local ____temp_0 -- 233
	if self.lastContext ~= nil then -- 233
		____temp_0 = self.lastContext.viewport.isPortrait -- 233
	else -- 233
		____temp_0 = false -- 233
	end -- 233
	local ____temp_1 -- 234
	if self.lastContext ~= nil then -- 234
		____temp_1 = self.lastContext.overlayActive -- 234
	else -- 234
		____temp_1 = false -- 234
	end -- 234
	local ____temp_2 -- 235
	if router ~= nil then -- 235
		____temp_2 = router.crouchToggled -- 235
	else -- 235
		____temp_2 = false -- 235
	end -- 235
	local ____temp_3 -- 236
	if router ~= nil then -- 236
		____temp_3 = router.slowToggled -- 236
	else -- 236
		____temp_3 = false -- 236
	end -- 236
	local ____temp_4 -- 237
	if router ~= nil then -- 237
		____temp_4 = router.coverToggled -- 237
	else -- 237
		____temp_4 = false -- 237
	end -- 237
	local ____temp_5 -- 238
	if router ~= nil then -- 238
		____temp_5 = router.cartGripLatched -- 238
	else -- 238
		____temp_5 = false -- 238
	end -- 238
	return { -- 230
		buttonIds = ____buttonIds_6, -- 231
		zoneIds = ____zoneIds_7, -- 232
		isPortrait = ____temp_0, -- 233
		overlayActive = ____temp_1, -- 234
		crouchToggled = ____temp_2, -- 235
		slowToggled = ____temp_3, -- 236
		coverToggled = ____temp_4, -- 237
		cartGripLatch = ____temp_5 -- 238
	} -- 238
end -- 209
function TouchControls.prototype.syncContext(self, params) -- 243
	self.time = self.time + math.min( -- 244
		0.05, -- 244
		math.max(0, params.dt) -- 244
	) -- 244
	self.lastMode = params.mode -- 245
	self.lastScreen = params.screen -- 246
	self.lastPlay = params.play -- 247
	self.lastRun = params.run -- 248
	local vp = params.viewport -- 250
	local p = params.play -- 251
	local router = params.router -- 252
	local input = params.input -- 253
	local isPortrait = vp.isPortrait -- 254
	local overlayScale = isPortrait and 1 or vp.uiScale -- 255
	local ovW = vp.fullW / math.max(0.25, overlayScale) -- 256
	local ovH = vp.fullH / math.max(0.25, overlayScale) -- 257
	local safeL = vp.safe.left / math.max(0.25, overlayScale) -- 258
	local safeR = vp.safe.right / math.max(0.25, overlayScale) -- 259
	local safeT = vp.safe.top / math.max(0.25, overlayScale) -- 260
	local safeB = vp.safe.bottom / math.max(0.25, overlayScale) -- 261
	local overlayActive = input:shouldShowTouchControls() -- 263
	local allowMouseOnOverlay = isPortrait or input.settings.modePref == "touch" -- 264
	local allowAutoGameplayTouch = input.settings.modePref == "auto" or input.settings.modePref == "touch" -- 265
	local sc = router.settings.touchScale -- 266
	local isPlayMode = params.mode == 1 and params.screen == "play" and p ~= nil -- 268
	local gameplayActive = isPlayMode -- 269
	local talentModalOpen = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and p.talentModalActive and #p:getStoryTalentOffers() > 0 -- 270
	local escortSummaryOpen = isPlayMode and p ~= nil and not p.paused and p.escortFailed -- 272
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or talentModalOpen or escortSummaryOpen) -- 274
	local ____temp_8 -- 276
	if isPlayMode and p ~= nil then -- 276
		____temp_8 = isCutsceneBlockingPlay(p) -- 277
	else -- 277
		____temp_8 = false -- 278
	end -- 278
	local cutsceneBlocking = ____temp_8 -- 276
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 280
	local cart = p ~= nil and p.room.cart or nil -- 282
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 283
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 285
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 286
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 287
	local buttons = {} -- 290
	local rectZones = {} -- 291
	local unitPortrait = clamp( -- 294
		math.min( -- 294
			vp.fullW / 420, -- 294
			math.max(180, vp.deckH) / 340 -- 294
		), -- 294
		0.72, -- 294
		1.15 -- 294
	) -- 294
	local stickMaxR = isPortrait and math.floor(52 * unitPortrait * sc + 0.5) or STICK_BASE_R_LANDSCAPE * sc -- 295
	local stickDefaultX = isPortrait and safeL + math.max( -- 298
		stickMaxR + 26, -- 299
		math.floor(ovW * 0.24 + 0.5) -- 299
	) or safeL + 126 * sc -- 300
	local stickDefaultY = isPortrait and math.max(safeB + stickMaxR + 24, vp.deckH * 0.44) or safeB + 126 * sc -- 301
	local stickZoneMaxX = isPortrait and ovW * 0.5 or ovW * 0.46 -- 304
	local stickZoneMaxY = isPortrait and math.max(40, vp.deckH - 8) or ovH - 110 -- 305
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 307
	if overlayActive then -- 310
		if isPortrait then -- 311
			local topY = ovH - vp.topBarH * 0.5 -- 313
			local pillH = 26 -- 314
			local rx = ovW - safeR - 10 -- 315
			if gameplayActive and p ~= nil and not p.paused then -- 317
				local pw = 58 -- 318
				rx = rx - pw -- 319
				buttons[#buttons + 1] = { -- 320
					id = "pause", -- 321
					x = rx + pw * 0.5, -- 322
					y = topY, -- 323
					r = 22, -- 324
					shape = "pill", -- 325
					rect = Rect(rx, topY - pillH * 0.5, pw, pillH), -- 326
					label = "暂歇", -- 327
					accent = "silk", -- 328
					active = false, -- 329
					highlighted = false, -- 330
					progress = 0, -- 331
					dimmed = false -- 332
				} -- 332
				rx = rx - 8 -- 334
				local inTowerEnd = p.room.key == "tower" and p.phase ~= "tower-wait" -- 336
				if not inTowerEnd then -- 337
					local rw = 58 -- 338
					rx = rx - rw -- 339
					buttons[#buttons + 1] = { -- 340
						id = "retry", -- 341
						x = rx + rw * 0.5, -- 342
						y = topY, -- 343
						r = 22, -- 344
						shape = "pill", -- 345
						rect = Rect(rx, topY - pillH * 0.5, rw, pillH), -- 346
						label = "重试", -- 347
						accent = "amber", -- 348
						active = false, -- 349
						highlighted = false, -- 350
						progress = 0, -- 351
						dimmed = false -- 352
					} -- 352
					rx = rx - 8 -- 354
				end -- 354
			end -- 354
			local mw = 54 -- 358
			rx = rx - mw -- 359
			buttons[#buttons + 1] = { -- 360
				id = "mute", -- 361
				x = rx + mw * 0.5, -- 362
				y = topY, -- 363
				r = 20, -- 364
				shape = "pill", -- 365
				rect = Rect(rx, topY - pillH * 0.5, mw, pillH), -- 366
				label = params.isMuted and "静音" or "有声", -- 367
				accent = params.isMuted and "rouge" or "cyan", -- 368
				active = params.isMuted, -- 369
				highlighted = false, -- 370
				progress = 0, -- 371
				dimmed = false -- 372
			} -- 372
			rx = rx - 8 -- 374
			if canToggleFullscreen() then -- 376
				local fw = 54 -- 377
				rx = rx - fw -- 378
				buttons[#buttons + 1] = { -- 379
					id = "fullscreen", -- 380
					x = rx + fw * 0.5, -- 381
					y = topY, -- 382
					r = 20, -- 383
					shape = "pill", -- 384
					rect = Rect(rx, topY - pillH * 0.5, fw, pillH), -- 385
					label = params.isFullscreen and "窗口" or "全屏", -- 386
					accent = "silk", -- 387
					active = params.isFullscreen, -- 388
					highlighted = false, -- 389
					progress = 0, -- 390
					dimmed = false -- 391
				} -- 391
			end -- 391
		else -- 391
			if isPlayMode and not modal then -- 396
				local px = ovW - safeR - 112 -- 397
				local py = ovH - safeT - 66 -- 398
				buttons[#buttons + 1] = { -- 399
					id = "pause", -- 400
					x = px + 46, -- 401
					y = py + 21, -- 402
					r = 28, -- 403
					shape = "pill", -- 404
					rect = Rect(px, py, 94, 42), -- 405
					label = "暂歇", -- 406
					accent = "silk", -- 407
					active = false, -- 408
					highlighted = false, -- 409
					progress = 0, -- 410
					dimmed = false -- 411
				} -- 411
				if isWebPlatform() then -- 414
					local mw = 58 -- 415
					local mx = px - mw - 10 -- 416
					buttons[#buttons + 1] = { -- 417
						id = "mute", -- 418
						x = mx + mw * 0.5, -- 419
						y = py + 21, -- 420
						r = 22, -- 421
						shape = "pill", -- 422
						rect = Rect(mx, py + 4, mw, 34), -- 423
						label = params.isMuted and "静音" or "有声", -- 424
						accent = params.isMuted and "rouge" or "cyan", -- 425
						active = params.isMuted, -- 426
						highlighted = false, -- 427
						progress = 0, -- 428
						dimmed = false -- 429
					} -- 429
					if canToggleFullscreen() then -- 431
						local fw = 58 -- 432
						local fx = mx - fw - 8 -- 433
						buttons[#buttons + 1] = { -- 434
							id = "fullscreen", -- 435
							x = fx + fw * 0.5, -- 436
							y = py + 21, -- 437
							r = 22, -- 438
							shape = "pill", -- 439
							rect = Rect(fx, py + 4, fw, 34), -- 440
							label = params.isFullscreen and "窗口" or "全屏", -- 441
							accent = "silk", -- 442
							active = params.isFullscreen, -- 443
							highlighted = false, -- 444
							progress = 0, -- 445
							dimmed = false -- 446
						} -- 446
					end -- 446
				end -- 446
			end -- 446
		end -- 446
	end -- 446
	if isPortrait and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and (p.paused or talentModalOpen or escortSummaryOpen)) then -- 455
		local cy = math.max(safeB + 84, vp.deckH * 0.5) -- 457
		local leftX = safeL + math.max(82, ovW * 0.25) -- 458
		local step = math.min( -- 459
			54, -- 459
			math.max(42, ovW * 0.12) -- 459
		) -- 459
		local nr = math.min( -- 460
			26, -- 460
			math.max(21, ovW * 0.06) -- 460
		) -- 460
		buttons[#buttons + 1] = { -- 461
			id = "nav_up", -- 461
			x = leftX, -- 461
			y = cy + step, -- 461
			r = nr, -- 461
			label = "上", -- 461
			accent = "silk", -- 461
			active = false, -- 461
			highlighted = false, -- 461
			progress = 0, -- 461
			dimmed = false -- 461
		} -- 461
		buttons[#buttons + 1] = { -- 462
			id = "nav_down", -- 462
			x = leftX, -- 462
			y = cy - step, -- 462
			r = nr, -- 462
			label = "下", -- 462
			accent = "silk", -- 462
			active = false, -- 462
			highlighted = false, -- 462
			progress = 0, -- 462
			dimmed = false -- 462
		} -- 462
		buttons[#buttons + 1] = { -- 463
			id = "nav_left", -- 463
			x = leftX - step, -- 463
			y = cy, -- 463
			r = nr, -- 463
			label = "左", -- 463
			accent = "silk", -- 463
			active = false, -- 463
			highlighted = false, -- 463
			progress = 0, -- 463
			dimmed = false -- 463
		} -- 463
		buttons[#buttons + 1] = { -- 464
			id = "nav_right", -- 464
			x = leftX + step, -- 464
			y = cy, -- 464
			r = nr, -- 464
			label = "右", -- 464
			accent = "silk", -- 464
			active = false, -- 464
			highlighted = false, -- 464
			progress = 0, -- 464
			dimmed = false -- 464
		} -- 464
		local rightX = ovW - safeR - math.max(76, ovW * 0.23) -- 466
		buttons[#buttons + 1] = { -- 467
			id = "nav_confirm", -- 468
			x = rightX, -- 469
			y = cy + 28, -- 470
			r = 28, -- 471
			shape = "pill", -- 472
			rect = Rect(rightX - 48, cy + 6, 96, 44), -- 473
			label = "确认", -- 474
			accent = "rouge", -- 475
			active = false, -- 476
			highlighted = true, -- 477
			progress = 0, -- 478
			dimmed = false -- 479
		} -- 479
		buttons[#buttons + 1] = { -- 481
			id = "nav_back", -- 482
			x = rightX, -- 483
			y = cy - 30, -- 484
			r = 26, -- 485
			shape = "pill", -- 486
			rect = Rect(rightX - 48, cy - 50, 96, 40), -- 487
			label = "返回", -- 488
			accent = "silk", -- 489
			active = false, -- 490
			highlighted = false, -- 491
			progress = 0, -- 492
			dimmed = false -- 493
		} -- 493
	end -- 493
	local prompt -- 498
	if isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not cutsceneBlocking then -- 499
		if p.escortFailed and params.escortDeathBoxes ~= nil then -- 500
			local function pushStageRect(zoneId, b) -- 501
				local vx = vp.stageX + b.x * vp.uiScale -- 502
				local vy = vp.stageY + b.y * vp.uiScale -- 503
				local vw = b.width * vp.uiScale -- 504
				local vh = b.height * vp.uiScale -- 505
				rectZones[#rectZones + 1] = { -- 506
					id = zoneId, -- 507
					rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 508
				} -- 508
			end -- 501
			pushStageRect("escort:retry", params.escortDeathBoxes.retry) -- 516
			pushStageRect("escort:title", params.escortDeathBoxes.title) -- 517
		elseif #params.storyTalentBoxes > 0 then -- 518
			local ti = 0 -- 520
			do -- 520
				ti = 0 -- 521
				while ti < #params.storyTalentBoxes do -- 521
					local b = params.storyTalentBoxes[ti + 1] -- 522
					local vx = vp.stageX + b.x * vp.uiScale -- 523
					local vy = vp.stageY + b.y * vp.uiScale -- 524
					local vw = b.width * vp.uiScale -- 525
					local vh = b.height * vp.uiScale -- 526
					rectZones[#rectZones + 1] = { -- 527
						id = "talent:" .. tostring(ti), -- 528
						rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 529
					} -- 529
					ti = ti + 1 -- 521
				end -- 521
			end -- 521
		end -- 521
	end -- 521
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 539
		prompt = deriveWorldPrompt(p) -- 540
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 541
			local keyW = math.max( -- 543
				24, -- 543
				visualTextWidth(prompt.keyTag, 15) + 16 -- 543
			) -- 543
			local labelW = visualTextWidth(prompt.label, 15) -- 544
			local pillW = keyW + labelW + 24 -- 545
			local padX = math.max(115, pillW * 0.5 + 24) -- 546
			local sxUi = math.max( -- 547
				padX + vp.safeUi.left, -- 547
				math.min( -- 547
					vp.uiW - padX - vp.safeUi.right, -- 547
					params.cam:sx(prompt.x) / vp.uiScale -- 547
				) -- 547
			) -- 547
			local syUi = math.max( -- 548
				96 + vp.safeUi.bottom, -- 548
				math.min( -- 548
					vp.uiH - 110 - vp.safeUi.top, -- 548
					params.cam:sy(prompt.y) / vp.uiScale -- 548
				) -- 548
			) -- 548
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 549
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 550
			rectZones[#rectZones + 1] = { -- 551
				id = "worldPrompt", -- 552
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 553
			} -- 553
		end -- 553
	end -- 553
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 564
		local cx = ovW * 0.5 -- 566
		local cy = safeB + 46 -- 567
		buttons[#buttons + 1] = { -- 568
			id = "nav_confirm", -- 569
			x = cx, -- 570
			y = cy, -- 571
			r = 26, -- 572
			shape = "pill", -- 573
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 574
			label = "继续 · 归程", -- 575
			accent = "amber", -- 576
			active = false, -- 577
			highlighted = true, -- 578
			progress = 0, -- 579
			dimmed = false -- 580
		} -- 580
	end -- 580
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 585
		local interactMeta = deriveInteractActionMeta( -- 586
			p, -- 586
			prompt or deriveWorldPrompt(p), -- 586
			cartNearby, -- 586
			router.cartGripLatched -- 586
		) -- 586
		if isPortrait then -- 588
			local u = unitPortrait * sc -- 589
			local rightX = ovW - safeR - math.floor(68 * u + 0.5) -- 590
			local bottomY = math.max( -- 591
				safeB + math.floor(70 * u + 0.5), -- 591
				vp.deckH * 0.4 -- 591
			) -- 591
			local postY = math.min( -- 592
				vp.deckH - 26, -- 592
				stickDefaultY + stickMaxR + math.floor(42 * u + 0.5) -- 592
			) -- 592
			bottleCancelCenter = { -- 593
				x = rightX - math.floor(14 * u + 0.5), -- 593
				y = bottomY + math.floor(10 * u + 0.5), -- 593
				r = math.floor(34 * u + 0.5) -- 593
			} -- 593
			if not p.childMode then -- 595
				local cw = math.floor(86 * u + 0.5) -- 597
				local ch = math.floor(32 * u + 0.5) -- 598
				buttons[#buttons + 1] = { -- 599
					id = "cover", -- 600
					x = stickDefaultX, -- 601
					y = postY, -- 602
					r = 24 * u, -- 603
					shape = "pill", -- 604
					toggle = true, -- 605
					rect = Rect(stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch), -- 606
					label = router.coverToggled and "离掩体" or "贴掩体", -- 607
					accent = "cyan", -- 608
					active = router.coverToggled or p.coverHug, -- 609
					highlighted = p.coverNear and not router.coverToggled, -- 610
					progress = 0, -- 611
					dimmed = not p.coverNear and not router.coverToggled -- 612
				} -- 612
				buttons[#buttons + 1] = { -- 616
					id = "fire", -- 617
					x = rightX, -- 618
					y = bottomY + math.floor(8 * u + 0.5), -- 619
					r = math.floor(36 * u + 0.5), -- 620
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 621
					subLabel = "拖瞄", -- 622
					accent = "rouge", -- 623
					active = router:isButtonHeld("fire"), -- 624
					highlighted = p.reloadPendingEffect ~= "", -- 625
					progress = 0, -- 626
					dimmed = p.gripping -- 627
				} -- 627
				local nearLedge = isNearLowLedgeForButton(p) -- 629
				buttons[#buttons + 1] = { -- 630
					id = "jump", -- 631
					x = rightX - math.floor(84 * u + 0.5), -- 632
					y = bottomY - math.floor(16 * u + 0.5), -- 633
					r = math.floor(28 * u + 0.5), -- 634
					label = nearLedge and "翻越" or "翻滚", -- 635
					accent = "cyan", -- 636
					active = router:isButtonHeld("jump"), -- 637
					highlighted = nearLedge, -- 638
					progress = 0, -- 639
					dimmed = p.gripping -- 640
				} -- 640
				buttons[#buttons + 1] = { -- 642
					id = "interact", -- 643
					x = rightX - math.floor(10 * u + 0.5), -- 644
					y = bottomY + math.floor(88 * u + 0.5), -- 645
					r = math.floor(30 * u + 0.5), -- 646
					label = interactMeta.label, -- 647
					subLabel = interactMeta.subLabel, -- 648
					accent = interactMeta.urgent and "rouge" or "amber", -- 649
					active = router:isButtonHeld("interact"), -- 650
					highlighted = interactMeta.available, -- 651
					progress = interactMeta.progress, -- 652
					dimmed = not interactMeta.available -- 653
				} -- 653
				if isPlayMode and p.archive.artifactOwned then -- 655
					local eq = p.equippedWeapon == "time_shuttler" -- 656
					buttons[#buttons + 1] = { -- 657
						id = "artifact", -- 658
						x = rightX - math.floor(90 * u + 0.5), -- 659
						y = bottomY + math.floor(68 * u + 0.5), -- 660
						r = math.floor(24 * u + 0.5), -- 661
						label = eq and "收器" or "穿梭", -- 662
						accent = "amber", -- 663
						active = eq, -- 664
						highlighted = eq, -- 665
						progress = 0, -- 666
						dimmed = false -- 667
					} -- 667
				end -- 667
			else -- 667
				local pw = math.floor(68 * u + 0.5) -- 672
				local ph = math.floor(32 * u + 0.5) -- 673
				buttons[#buttons + 1] = { -- 674
					id = "crouch", -- 675
					x = stickDefaultX - math.floor(38 * u + 0.5), -- 676
					y = postY, -- 677
					r = 22 * u, -- 678
					shape = "pill", -- 679
					toggle = true, -- 680
					rect = Rect( -- 681
						stickDefaultX - math.floor(38 * u + 0.5) - pw * 0.5, -- 681
						postY - ph * 0.5, -- 681
						pw, -- 681
						ph -- 681
					), -- 681
					label = router.crouchToggled and "起身" or "蹲伏", -- 682
					accent = "emerald", -- 683
					active = router.crouchToggled or p.player.crouch, -- 684
					highlighted = p.scavChase and not p.player.crouch, -- 685
					progress = 0, -- 686
					dimmed = false -- 687
				} -- 687
				buttons[#buttons + 1] = { -- 689
					id = "cover", -- 690
					x = stickDefaultX + math.floor(38 * u + 0.5), -- 691
					y = postY, -- 692
					r = 22 * u, -- 693
					shape = "pill", -- 694
					toggle = true, -- 695
					rect = Rect( -- 696
						stickDefaultX + math.floor(38 * u + 0.5) - pw * 0.5, -- 696
						postY - ph * 0.5, -- 696
						pw, -- 696
						ph -- 696
					), -- 696
					label = router.slowToggled and "常步" or "轻步", -- 697
					accent = "silk", -- 698
					active = router.slowToggled, -- 699
					highlighted = false, -- 700
					progress = 0, -- 701
					dimmed = false -- 702
				} -- 702
				buttons[#buttons + 1] = { -- 706
					id = "jump", -- 707
					x = rightX, -- 708
					y = bottomY + math.floor(8 * u + 0.5), -- 709
					r = math.floor(32 * u + 0.5), -- 710
					label = "跳跃", -- 711
					accent = "amber", -- 712
					active = router:isButtonHeld("jump"), -- 713
					highlighted = false, -- 714
					progress = 0, -- 715
					dimmed = p.gripping -- 716
				} -- 716
				buttons[#buttons + 1] = { -- 718
					id = "interact", -- 719
					x = rightX - math.floor(8 * u + 0.5), -- 720
					y = bottomY + math.floor(86 * u + 0.5), -- 721
					r = math.floor(31 * u + 0.5), -- 722
					label = interactMeta.label, -- 723
					subLabel = interactMeta.subLabel, -- 724
					accent = interactMeta.urgent and "rouge" or "amber", -- 725
					active = router:isButtonHeld("interact"), -- 726
					highlighted = interactMeta.available, -- 727
					progress = interactMeta.progress, -- 728
					dimmed = not interactMeta.available -- 729
				} -- 729
				if canBottleAim then -- 731
					buttons[#buttons + 1] = { -- 732
						id = "bottle", -- 733
						x = rightX - math.floor(86 * u + 0.5), -- 734
						y = bottomY + math.floor(46 * u + 0.5), -- 735
						r = math.floor(32 * u + 0.5), -- 736
						label = "投瓶", -- 737
						subLabel = "拖瞄", -- 738
						accent = "amber", -- 739
						active = router:isButtonHeld("bottle"), -- 740
						highlighted = true, -- 741
						progress = math.min(1, p.aimHold / 0.12), -- 742
						dimmed = false -- 743
					} -- 743
				end -- 743
			end -- 743
		else -- 743
			local rightX = ovW - safeR - 92 * sc -- 749
			local bottomY = safeB + 110 * sc -- 750
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 751
			if not p.childMode then -- 753
				buttons[#buttons + 1] = { -- 754
					id = "fire", -- 755
					x = rightX, -- 756
					y = bottomY + 12 * sc, -- 757
					r = 45 * sc, -- 758
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 759
					subLabel = "拖瞄", -- 760
					accent = "rouge", -- 761
					active = router:isButtonHeld("fire"), -- 762
					highlighted = p.reloadPendingEffect ~= "", -- 763
					progress = 0, -- 764
					dimmed = p.gripping -- 765
				} -- 765
				local nearLedge = isNearLowLedgeForButton(p) -- 767
				buttons[#buttons + 1] = { -- 768
					id = "jump", -- 769
					x = rightX - 116 * sc, -- 770
					y = bottomY - 8 * sc, -- 771
					r = 34 * sc, -- 772
					label = nearLedge and "翻越" or "翻滚", -- 773
					accent = "cyan", -- 774
					active = router:isButtonHeld("jump"), -- 775
					highlighted = nearLedge, -- 776
					progress = 0, -- 777
					dimmed = p.gripping -- 778
				} -- 778
				buttons[#buttons + 1] = { -- 780
					id = "cover", -- 781
					x = rightX - 120 * sc, -- 782
					y = bottomY + 94 * sc, -- 783
					r = 32 * sc, -- 784
					label = router.coverToggled and "离掩" or "掩体", -- 785
					accent = "cyan", -- 786
					active = router.coverToggled, -- 787
					highlighted = p.coverNear and not router.coverToggled, -- 788
					progress = 0, -- 789
					dimmed = not p.coverNear and not router.coverToggled -- 790
				} -- 790
				buttons[#buttons + 1] = { -- 792
					id = "interact", -- 793
					x = rightX - 10 * sc, -- 794
					y = bottomY + 122 * sc, -- 795
					r = 36 * sc, -- 796
					label = interactMeta.label, -- 797
					subLabel = interactMeta.subLabel, -- 798
					accent = interactMeta.urgent and "rouge" or "amber", -- 799
					active = router:isButtonHeld("interact"), -- 800
					highlighted = interactMeta.available, -- 801
					progress = interactMeta.progress, -- 802
					dimmed = not interactMeta.available -- 803
				} -- 803
				if isPlayMode and p.archive.artifactOwned then -- 805
					local eq = p.equippedWeapon == "time_shuttler" -- 806
					buttons[#buttons + 1] = { -- 807
						id = "artifact", -- 808
						x = rightX - 112 * sc, -- 809
						y = bottomY + 184 * sc, -- 810
						r = 27 * sc, -- 811
						label = eq and "收器" or "穿梭", -- 812
						accent = "amber", -- 813
						active = eq, -- 814
						highlighted = eq, -- 815
						progress = 0, -- 816
						dimmed = false -- 817
					} -- 817
				end -- 817
			else -- 817
				buttons[#buttons + 1] = { -- 821
					id = "jump", -- 822
					x = rightX, -- 823
					y = bottomY + 12 * sc, -- 824
					r = 38 * sc, -- 825
					label = "跳跃", -- 826
					accent = "amber", -- 827
					active = router:isButtonHeld("jump"), -- 828
					highlighted = false, -- 829
					progress = 0, -- 830
					dimmed = p.gripping -- 831
				} -- 831
				buttons[#buttons + 1] = { -- 833
					id = "crouch", -- 834
					x = rightX - 106 * sc, -- 835
					y = bottomY - 6 * sc, -- 836
					r = 34 * sc, -- 837
					label = router.crouchToggled and "起身" or "蹲伏", -- 838
					accent = "emerald", -- 839
					active = router.crouchToggled or p.player.crouch, -- 840
					highlighted = p.scavChase and not p.player.crouch, -- 841
					progress = 0, -- 842
					dimmed = false -- 843
				} -- 843
				buttons[#buttons + 1] = { -- 845
					id = "cover", -- 846
					x = rightX - 196 * sc, -- 847
					y = bottomY - 16 * sc, -- 848
					r = 29 * sc, -- 849
					label = router.slowToggled and "常步" or "轻步", -- 850
					accent = "silk", -- 851
					active = router.slowToggled, -- 852
					highlighted = false, -- 853
					progress = 0, -- 854
					dimmed = false -- 855
				} -- 855
				buttons[#buttons + 1] = { -- 857
					id = "interact", -- 858
					x = rightX - 12 * sc, -- 859
					y = bottomY + 114 * sc, -- 860
					r = 36 * sc, -- 861
					label = interactMeta.label, -- 862
					subLabel = interactMeta.subLabel, -- 863
					accent = interactMeta.urgent and "rouge" or "amber", -- 864
					active = router:isButtonHeld("interact"), -- 865
					highlighted = interactMeta.available, -- 866
					progress = interactMeta.progress, -- 867
					dimmed = not interactMeta.available -- 868
				} -- 868
				if canBottleAim then -- 870
					buttons[#buttons + 1] = { -- 871
						id = "bottle", -- 872
						x = rightX - 114 * sc, -- 873
						y = bottomY + 98 * sc, -- 874
						r = 38 * sc, -- 875
						label = "投瓶", -- 876
						subLabel = "拖瞄", -- 877
						accent = "amber", -- 878
						active = router:isButtonHeld("bottle"), -- 879
						highlighted = true, -- 880
						progress = math.min(1, p.aimHold / 0.12), -- 881
						dimmed = false -- 882
					} -- 882
				end -- 882
			end -- 882
		end -- 882
	end -- 882
	local enemyTargets = canShoot and p ~= nil and isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or ({}) -- 890
	local playerScreenX = vp.stageW * 0.5 -- 894
	local playerScreenY = vp.stageH * 0.38 -- 895
	if p ~= nil then -- 896
		if isPlayMode and params.cam ~= nil then -- 897
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 898
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 899
		else -- 899
			playerScreenX = vp.stageW * 0.45 -- 901
			playerScreenY = vp.stageH * 0.36 -- 902
		end -- 902
	end -- 902
	local ctx = { -- 906
		viewport = vp, -- 907
		overlayScale = overlayScale, -- 908
		overlayActive = overlayActive, -- 909
		allowAutoGameplayTouch = allowAutoGameplayTouch, -- 910
		allowMouseOnOverlay = allowMouseOnOverlay, -- 911
		modal = modal, -- 912
		gameplayActive = gameplayActive, -- 913
		cutsceneBlocking = cutsceneBlocking, -- 914
		childMode = p ~= nil and p.childMode, -- 915
		allowDepth = allowDepth, -- 916
		canShoot = canShoot, -- 917
		canBottleAim = canBottleAim, -- 918
		cartNearby = cartNearby, -- 919
		cartGripping = p ~= nil and p.gripping, -- 920
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 921
		coverNear = p ~= nil and p.coverNear, -- 922
		playerRolling = p ~= nil and p.player.rollT > 0, -- 923
		inLowArch = p ~= nil and isInLowArch(p), -- 924
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 925
		playerFacing = p ~= nil and p.player.facing or 1, -- 926
		playerScreenX = playerScreenX, -- 927
		playerScreenY = playerScreenY, -- 928
		enemyTargets = enemyTargets, -- 929
		stickZoneMaxX = stickZoneMaxX, -- 930
		stickZoneMaxY = stickZoneMaxY, -- 931
		stickDefaultX = stickDefaultX, -- 932
		stickDefaultY = stickDefaultY, -- 933
		stickMaxR = stickMaxR, -- 934
		stickFixedOrigin = isPortrait, -- 935
		buttons = buttons, -- 936
		rectZones = rectZones, -- 937
		bottleCancelCenter = bottleCancelCenter -- 938
	} -- 938
	self.lastContext = ctx -- 941
	router:setFrameContext(ctx, params.dt) -- 942
	return ctx -- 943
end -- 243
function TouchControls.prototype.render(self, router) -- 947
	self.deckDraw:clear() -- 948
	self.padDraw:clear() -- 949
	self.padInkDraw:clear() -- 950
	self.padGlow:clear() -- 951
	self.padArt:beginFrame() -- 952
	self.texts:beginFrame() -- 953
	local ctx = self.lastContext -- 955
	if ctx == nil or not ctx.overlayActive and not ctx.viewport.isPortrait then -- 956
		self.padArt:endFrame() -- 957
		self.texts:endFrame() -- 958
		return -- 959
	end -- 959
	local vp = ctx.viewport -- 962
	local sc = math.max(0.25, ctx.overlayScale) -- 963
	self.overlayRoot.scaleX = sc -- 964
	self.overlayRoot.scaleY = sc -- 965
	local ovW = vp.fullW / sc -- 967
	local ovH = vp.fullH / sc -- 968
	local baseAlpha = router.settings.touchOpacity -- 969
	if vp.isPortrait then -- 972
		self:drawPortraitFrame(ctx, ovW, ovH) -- 973
	end -- 973
	if not ctx.overlayActive then -- 976
		self.padArt:endFrame() -- 977
		self.texts:endFrame() -- 978
		return -- 979
	end -- 979
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 983
		local rx = ovW * 0.5 -- 984
		local ry = vp.isPortrait and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 985
		drawSilkVeil( -- 986
			self.padDraw, -- 986
			self.padArt, -- 986
			"touch_restart_veil", -- 986
			rx, -- 986
			ry, -- 986
			230, -- 986
			36, -- 986
			PALETTE.inkWash, -- 986
			0.78 * baseAlpha, -- 986
			1 -- 986
		) -- 986
		drawHairline( -- 987
			self.padInkDraw, -- 987
			self.padArt, -- 987
			"touch_restart_line", -- 987
			rx, -- 987
			ry + 16, -- 987
			180, -- 987
			PALETTE.amber, -- 987
			0.52 * baseAlpha, -- 987
			true, -- 987
			2 -- 987
		) -- 987
		self.texts:put( -- 988
			"xs", -- 988
			"轻触屏幕再次启程", -- 988
			rx, -- 988
			ry, -- 988
			toColor(PALETTE.amberCore), -- 988
			0.5, -- 988
			0.5, -- 988
			"Center", -- 988
			1.6, -- 988
			0.94, -- 988
			0.08 -- 988
		) -- 988
	end -- 988
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 992
		self:drawStick(router, ctx, baseAlpha) -- 993
	end -- 993
	self:drawButtons(router, ctx, baseAlpha) -- 997
	local bottleDrag = router:getBottleDragVisual() -- 1000
	if bottleDrag.active then -- 1001
		local cx = bottleDrag.cancelX -- 1002
		local cy = bottleDrag.cancelY -- 1003
		local cr = bottleDrag.cancelR -- 1004
		local hot = bottleDrag.cancelHover -- 1005
		fillCirclePoly( -- 1006
			self.padDraw, -- 1007
			cx, -- 1008
			cy, -- 1009
			cr, -- 1010
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 1011
			0, -- 1012
			nil, -- 1013
			22 -- 1014
		) -- 1014
		drawRingArc( -- 1016
			self.padInkDraw, -- 1016
			cx, -- 1016
			cy, -- 1016
			cr, -- 1016
			0, -- 1016
			TWO_PI, -- 1016
			hot and 2.2 or 1.3, -- 1016
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 1016
			22 -- 1016
		) -- 1016
		self.texts:put( -- 1017
			"xs", -- 1017
			hot and "松手取消" or "拖此取消", -- 1017
			cx, -- 1017
			cy, -- 1017
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 1017
			0.5, -- 1017
			0.5, -- 1017
			"Center", -- 1017
			0.8, -- 1017
			0.96, -- 1017
			0.08 -- 1017
		) -- 1017
	end -- 1017
	self.padArt:endFrame() -- 1020
	self.texts:endFrame() -- 1021
end -- 947
function TouchControls.prototype.drawPortraitFrame(self, ctx, w, h) -- 1024
	local vp = ctx.viewport -- 1025
	local topY = vp.stageY + vp.stageH -- 1026
	if topY < h then -- 1028
		self.deckDraw:drawRect( -- 1029
			Rect(0, topY, w, h - topY), -- 1029
			toColor(PALETTE.inkVoid, 252) -- 1029
		) -- 1029
		self.deckDraw:drawSegment( -- 1030
			Vec2(0, topY), -- 1030
			Vec2(w, topY), -- 1030
			1, -- 1030
			toColor(PALETTE.silkDim, 140) -- 1030
		) -- 1030
		local labelY = topY + (h - topY) * 0.5 -- 1031
		self.texts:put( -- 1032
			"xs", -- 1032
			"向西守望 · 掌机竖屏", -- 1032
			vp.safe.left + 12, -- 1032
			labelY, -- 1032
			toColor(PALETTE.amberCore), -- 1032
			0, -- 1032
			0.5, -- 1032
			"Left", -- 1032
			0.8, -- 1032
			0.88, -- 1032
			0.08 -- 1032
		) -- 1032
	end -- 1032
	if vp.stageX > 0 then -- 1035
		self.deckDraw:drawRect( -- 1036
			Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 1036
			toColor(PALETTE.inkVoid, 255) -- 1036
		) -- 1036
		self.deckDraw:drawRect( -- 1037
			Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 1037
			toColor(PALETTE.inkVoid, 255) -- 1037
		) -- 1037
	end -- 1037
	if vp.deckH > 0 then -- 1040
		fillVGradRect( -- 1041
			self.deckDraw, -- 1041
			0, -- 1041
			0, -- 1041
			w, -- 1041
			vp.deckH, -- 1041
			toColor(PALETTE.voidDark, 255), -- 1041
			toColor(PALETTE.inkWash, 255) -- 1041
		) -- 1041
		self.deckDraw:drawSegment( -- 1042
			Vec2(0, vp.deckH), -- 1042
			Vec2(w, vp.deckH), -- 1042
			1.2, -- 1042
			toColor(PALETTE.silkLine, 165) -- 1042
		) -- 1042
		self.deckDraw:drawSegment( -- 1043
			Vec2(18, vp.deckH - 4), -- 1043
			Vec2(w - 18, vp.deckH - 4), -- 1043
			0.6, -- 1043
			toColor(PALETTE.silkDim, 85) -- 1043
		) -- 1043
		drawDiamond( -- 1044
			self.padInkDraw, -- 1044
			w * 0.5, -- 1044
			vp.deckH, -- 1044
			5, -- 1044
			5, -- 1044
			toColor(PALETTE.rouge, 220), -- 1044
			0.9, -- 1044
			toColor(PALETTE.silkLine, 180) -- 1044
		) -- 1044
		local footY = math.max(vp.safe.bottom + 14, 16) -- 1046
		local p = self.lastPlay -- 1047
		local inOverlayModal = p ~= nil and (p.reloadOpen or p.craftBench.active) -- 1048
		local inChoiceModal = p ~= nil and (p.escortFailed or p.talentModalActive and #p:getStoryTalentOffers() > 0) -- 1049
		local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or p ~= nil and p.paused or inChoiceModal) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 1050
		self.texts:put( -- 1057
			"xs", -- 1057
			hint, -- 1057
			w * 0.5, -- 1057
			footY, -- 1057
			toColor(PALETTE.textDim), -- 1057
			0.5, -- 1057
			0.5, -- 1057
			"Center", -- 1057
			0.8, -- 1057
			0.78, -- 1057
			0.06 -- 1057
		) -- 1057
	end -- 1057
end -- 1024
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 1061
	local stick = router:getStickVisual() -- 1062
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 1063
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 1066
	fillCirclePoly( -- 1068
		self.padDraw, -- 1069
		stick.originX, -- 1070
		stick.originY, -- 1071
		stick.radius, -- 1072
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 1073
		0, -- 1074
		nil, -- 1075
		28 -- 1076
	) -- 1076
	drawRingArc( -- 1078
		self.padInkDraw, -- 1078
		stick.originX, -- 1078
		stick.originY, -- 1078
		stick.radius, -- 1078
		0, -- 1078
		TWO_PI, -- 1078
		stick.active and 1.5 or 1, -- 1078
		toColor(ringCol, 168 * stickAlpha), -- 1078
		28 -- 1078
	) -- 1078
	if stick.allowDepth then -- 1080
		local dOff = stick.radius - 10 -- 1081
		self.padInkDraw:drawDot( -- 1082
			Vec2(stick.originX, stick.originY + dOff), -- 1082
			2.1, -- 1082
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1082
		) -- 1082
		self.padInkDraw:drawDot( -- 1083
			Vec2(stick.originX, stick.originY - dOff), -- 1083
			2.1, -- 1083
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1083
		) -- 1083
		self.padInkDraw:drawDot( -- 1084
			Vec2(stick.originX - dOff, stick.originY), -- 1084
			2.1, -- 1084
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1084
		) -- 1084
		self.padInkDraw:drawDot( -- 1085
			Vec2(stick.originX + dOff, stick.originY), -- 1085
			2.1, -- 1085
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1085
		) -- 1085
	elseif ctx.childMode then -- 1086
		drawRingArc( -- 1087
			self.padInkDraw, -- 1088
			stick.originX, -- 1089
			stick.originY, -- 1090
			stick.radius * 0.56, -- 1091
			0, -- 1092
			TWO_PI, -- 1093
			0.9, -- 1094
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 1095
			20 -- 1096
		) -- 1096
	end -- 1096
	local knobR = math.max(16, stick.radius * 0.36) -- 1100
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 1101
	if stick.active then -- 1102
		fillRadialGlow( -- 1103
			self.padGlow, -- 1103
			stick.knobX, -- 1103
			stick.knobY, -- 1103
			knobR * 1.45, -- 1103
			knobR * 1.45, -- 1103
			toColor(knobAccent, 48 * stickAlpha), -- 1103
			Color(0, 0, 0, 0), -- 1103
			12 -- 1103
		) -- 1103
	end -- 1103
	fillCirclePoly( -- 1105
		self.padDraw, -- 1106
		stick.knobX, -- 1107
		stick.knobY, -- 1108
		knobR, -- 1109
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 1110
		1.3, -- 1111
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 1112
		22 -- 1113
	) -- 1113
	drawBlossomDot( -- 1115
		self.padInkDraw, -- 1115
		self.padArt, -- 1115
		"touch_stick_dot", -- 1115
		stick.knobX, -- 1115
		stick.knobY, -- 1115
		stick.active and 11 or 7, -- 1115
		knobAccent, -- 1115
		0.85 * stickAlpha, -- 1115
		4 -- 1115
	) -- 1115
	if stick.slowZone then -- 1116
		self.texts:put( -- 1117
			"xs", -- 1117
			"轻步", -- 1117
			stick.originX, -- 1117
			stick.originY + stick.radius + 14, -- 1117
			toColor(PALETTE.emerald), -- 1117
			0.5, -- 1117
			0.5, -- 1117
			"Center", -- 1117
			1, -- 1117
			0.9, -- 1117
			0.08 -- 1117
		) -- 1117
	end -- 1117
end -- 1061
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 1121
	local bottleDrag = router:getBottleDragVisual() -- 1122
	local fireStick = router:getFireStickVisual() -- 1123
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 1124
	local i = 0 -- 1126
	do -- 1126
		i = 0 -- 1127
		while i < #ctx.buttons do -- 1127
			do -- 1127
				local b = ctx.buttons[i + 1] -- 1128
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 1129
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 1130
					bAlpha = bAlpha * 0.25 -- 1131
				end -- 1131
				local col = accentPalette(b.accent) -- 1133
				local core = accentCore(b.accent) -- 1134
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 1135
				if b.shape == "pill" and b.rect ~= nil then -- 1137
					local r = b.rect -- 1138
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 1139
					self.padDraw:drawRoundedRect( -- 1142
						r, -- 1143
						6, -- 1144
						fillCol, -- 1145
						b.active and 1.4 or 1, -- 1146
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 1147
					) -- 1147
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 1149
						local icX = r.x + 22 -- 1150
						local icY = r.y + r.height * 0.5 -- 1151
						drawRingArc( -- 1152
							self.padInkDraw, -- 1152
							icX, -- 1152
							icY, -- 1152
							9, -- 1152
							0, -- 1152
							TWO_PI, -- 1152
							1, -- 1152
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 1152
							16 -- 1152
						) -- 1152
						self.padInkDraw:drawSegment( -- 1153
							Vec2(icX - 2.6, icY - 3.6), -- 1153
							Vec2(icX - 2.6, icY + 3.6), -- 1153
							1.5, -- 1153
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1153
						) -- 1153
						self.padInkDraw:drawSegment( -- 1154
							Vec2(icX + 2.6, icY - 3.6), -- 1154
							Vec2(icX + 2.6, icY + 3.6), -- 1154
							1.5, -- 1154
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1154
						) -- 1154
						self.texts:put( -- 1155
							"xs", -- 1155
							b.label, -- 1155
							r.x + r.width * 0.5 + 10, -- 1155
							icY, -- 1155
							toColor(PALETTE.textBright), -- 1155
							0.5, -- 1155
							0.5, -- 1155
							"Center", -- 1155
							1, -- 1155
							0.94 * bAlpha, -- 1155
							0.08 -- 1155
						) -- 1155
					else -- 1155
						if b.toggle and b.active then -- 1157
							drawDiamond( -- 1158
								self.padInkDraw, -- 1158
								r.x + 11, -- 1158
								r.y + r.height * 0.5, -- 1158
								3.8, -- 1158
								3.8, -- 1158
								toColor(col, 235) -- 1158
							) -- 1158
						end -- 1158
						self.texts:put( -- 1160
							"xs", -- 1161
							b.label, -- 1162
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 1163
							r.y + r.height * 0.5, -- 1164
							toColor(b.active and core or PALETTE.textBright), -- 1165
							0.5, -- 1166
							0.5, -- 1167
							"Center", -- 1168
							0.6, -- 1169
							math.min(1, bAlpha + 0.08), -- 1170
							0.08 -- 1171
						) -- 1171
					end -- 1171
					goto __continue89 -- 1174
				end -- 1174
				if b.active or b.highlighted then -- 1177
					fillRadialGlow( -- 1178
						self.padGlow, -- 1179
						b.x, -- 1180
						b.y, -- 1181
						b.r * 1.38, -- 1182
						b.r * 1.38, -- 1183
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 1184
						Color(col.r, col.g, col.b, 0), -- 1185
						12 -- 1186
					) -- 1186
				end -- 1186
				fillCirclePoly( -- 1190
					self.padDraw, -- 1191
					b.x, -- 1192
					b.y, -- 1193
					b.r, -- 1194
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 1195
					0, -- 1196
					nil, -- 1197
					24 -- 1198
				) -- 1198
				drawRingArc( -- 1200
					self.padInkDraw, -- 1201
					b.x, -- 1202
					b.y, -- 1203
					b.r, -- 1204
					0, -- 1205
					TWO_PI, -- 1206
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 1207
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 1208
					24 -- 1209
				) -- 1209
				drawRingArc( -- 1211
					self.padInkDraw, -- 1212
					b.x, -- 1213
					b.y, -- 1214
					b.r - 4.2, -- 1215
					0, -- 1216
					TWO_PI, -- 1217
					0.7, -- 1218
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 1219
					20 -- 1220
				) -- 1220
				if b.progress > 0.02 then -- 1223
					drawRingArc( -- 1224
						self.padInkDraw, -- 1225
						b.x, -- 1226
						b.y, -- 1227
						b.r + 4, -- 1228
						HALF_PI, -- 1229
						-TWO_PI * math.min(1, b.progress), -- 1230
						2.6, -- 1231
						toColor(PALETTE.amberCore, 240), -- 1232
						28 -- 1233
					) -- 1233
				end -- 1233
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 1237
				self.texts:put( -- 1238
					fontKind, -- 1239
					b.label, -- 1240
					b.x, -- 1241
					hasSub and b.y + 6 or b.y, -- 1242
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 1243
					0.5, -- 1244
					0.5, -- 1245
					"Center", -- 1246
					0.6, -- 1247
					bAlpha, -- 1248
					0.08 -- 1249
				) -- 1249
				if hasSub and b.subLabel ~= nil then -- 1251
					self.texts:put( -- 1252
						"xs", -- 1253
						b.subLabel, -- 1254
						b.x, -- 1255
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 1256
						toColor(b.active and core or PALETTE.textDim), -- 1257
						0.5, -- 1258
						0.5, -- 1259
						"Center", -- 1260
						0.4, -- 1261
						bAlpha * 0.85, -- 1262
						0.06 -- 1263
					) -- 1263
				end -- 1263
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 1267
					self.padInkDraw:drawSegment( -- 1268
						Vec2(fireStick.originX, fireStick.originY), -- 1268
						Vec2(fireStick.knobX, fireStick.knobY), -- 1268
						1.4, -- 1268
						toColor(PALETTE.rouge, 190) -- 1268
					) -- 1268
					fillCirclePoly( -- 1269
						self.padDraw, -- 1269
						fireStick.knobX, -- 1269
						fireStick.knobY, -- 1269
						12, -- 1269
						toColor(PALETTE.rouge, 210), -- 1269
						1.2, -- 1269
						toColor(PALETTE.crimsonCore, 240), -- 1269
						16 -- 1269
					) -- 1269
				end -- 1269
			end -- 1269
			::__continue89:: -- 1269
			i = i + 1 -- 1127
		end -- 1127
	end -- 1127
end -- 1121
return ____exports -- 1121
