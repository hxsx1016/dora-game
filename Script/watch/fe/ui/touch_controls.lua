-- [ts]: touch_controls.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 16
local BlendFunc = ____Dora.BlendFunc -- 16
local Color = ____Dora.Color -- 16
local DrawNode = ____Dora.DrawNode -- 16
local Node = ____Dora.Node -- 16
local Rect = ____Dora.Rect -- 16
local Vec2 = ____Dora.Vec2 -- 16
local ____run = require("Script.watch.run") -- 19
local talentNames = ____run.talentNames -- 19
local ____aim_assist = require("Script.watch.aim_assist") -- 20
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 20
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 20
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
local function clamp(v, lo, hi) -- 71
	return v < lo and lo or (v > hi and hi or v) -- 72
end -- 71
local function accentPalette(accent) -- 75
	if accent == "cyan" then -- 76
		return PALETTE.cyan -- 76
	end -- 76
	if accent == "amber" then -- 77
		return PALETTE.amber -- 77
	end -- 77
	if accent == "rouge" then -- 78
		return PALETTE.rouge -- 78
	end -- 78
	if accent == "emerald" then -- 79
		return PALETTE.emerald -- 79
	end -- 79
	return PALETTE.silkLine -- 80
end -- 75
local function accentCore(accent) -- 83
	if accent == "cyan" then -- 84
		return PALETTE.cyanCore -- 84
	end -- 84
	if accent == "amber" then -- 85
		return PALETTE.amberCore -- 85
	end -- 85
	if accent == "rouge" then -- 86
		return PALETTE.crimsonCore -- 86
	end -- 86
	if accent == "emerald" then -- 87
		return PALETTE.emerald -- 87
	end -- 87
	return PALETTE.textBright -- 88
end -- 83
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 91
	if segments == nil then -- 100
		segments = 28 -- 100
	end -- 100
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 102
		return -- 102
	end -- 102
	local n = math.max( -- 103
		4, -- 103
		math.ceil(segments * math.min( -- 103
			1, -- 103
			math.abs(sweepRad) / TWO_PI -- 103
		)) -- 103
	) -- 103
	local prevX = cx + math.cos(startRad) * r -- 104
	local prevY = cy + math.sin(startRad) * r -- 105
	local i = 1 -- 106
	do -- 106
		i = 1 -- 107
		while i <= n do -- 107
			local a = startRad + sweepRad * i / n -- 108
			local nx = cx + math.cos(a) * r -- 109
			local ny = cy + math.sin(a) * r -- 110
			draw:drawSegment( -- 111
				Vec2(prevX, prevY), -- 111
				Vec2(nx, ny), -- 111
				thickness, -- 111
				color -- 111
			) -- 111
			prevX = nx -- 112
			prevY = ny -- 113
			i = i + 1 -- 107
		end -- 107
	end -- 107
end -- 91
local function fillCirclePoly(draw, cx, cy, r, fill, borderWidth, borderColor, segments) -- 117
	if borderWidth == nil then -- 123
		borderWidth = 0 -- 123
	end -- 123
	if segments == nil then -- 125
		segments = 26 -- 125
	end -- 125
	local pts = {} -- 127
	local i = 0 -- 128
	do -- 128
		i = 0 -- 129
		while i < segments do -- 129
			local a = TWO_PI * i / segments -- 130
			pts[#pts + 1] = Vec2( -- 131
				cx + math.cos(a) * r, -- 131
				cy + math.sin(a) * r -- 131
			) -- 131
			i = i + 1 -- 129
		end -- 129
	end -- 129
	if borderWidth > 0 and borderColor ~= nil then -- 133
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 134
	else -- 134
		draw:drawPolygon(pts, fill) -- 136
	end -- 136
end -- 117
local function isNearLowLedgeForButton(p) -- 140
	if p.childMode then -- 141
		return false -- 141
	end -- 141
	local a = p.player -- 142
	local probeX = a.x + a.facing * 26 -- 143
	local i = 0 -- 144
	do -- 144
		i = 0 -- 145
		while i < #p.boxes do -- 145
			do -- 145
				local b = p.boxes[i + 1] -- 146
				if b.broken == true or b.hidden == true then -- 147
					goto __continue25 -- 147
				end -- 147
				local h = b.y1 - b.y0 -- 148
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 149
					return true -- 151
				end -- 151
			end -- 151
			::__continue25:: -- 151
			i = i + 1 -- 145
		end -- 145
	end -- 145
	return false -- 154
end -- 140
local function isInLowArch(p) -- 157
	local arch = p.room.arch -- 158
	if arch.h <= 0 then -- 159
		return false -- 159
	end -- 159
	return p.player.x >= arch.x0 - 10 and p.player.x <= arch.x1 + 10 and p.player.y <= arch.y + arch.h -- 160
end -- 157
____exports.TouchControls = __TS__Class() -- 163
local TouchControls = ____exports.TouchControls -- 163
TouchControls.name = "TouchControls" -- 163
function TouchControls.prototype.____constructor(self, parent) -- 179
	self.lastMode = 1 -- 173
	self.lastScreen = "title" -- 174
	self.time = 0 -- 177
	self.overlayRoot = Node() -- 180
	self.overlayRoot.order = 60 -- 181
	self.overlayRoot:addTo(parent) -- 182
	self.deckDraw = DrawNode() -- 184
	self.deckDraw.order = 0 -- 185
	self.deckDraw:addTo(self.overlayRoot) -- 186
	self.padDraw = DrawNode() -- 188
	self.padDraw.order = 2 -- 189
	self.padDraw:addTo(self.overlayRoot) -- 190
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 192
	self.padInkDraw = DrawNode() -- 194
	self.padInkDraw.order = 5 -- 195
	self.padInkDraw:addTo(self.overlayRoot) -- 196
	local additive = BlendFunc("SrcAlpha", "One") -- 198
	self.padGlow = DrawNode() -- 199
	self.padGlow.order = 7 -- 200
	self.padGlow.blendFunc = additive -- 201
	self.padGlow:addTo(self.overlayRoot) -- 202
	self.texts = __TS__New(TextPool, self.overlayRoot, 10) -- 204
end -- 179
function TouchControls.prototype.getLayoutSummary(self, router) -- 208
	local buttonIds = {} -- 218
	local zoneIds = {} -- 219
	if self.lastContext ~= nil then -- 220
		local i = 0 -- 221
		do -- 221
			i = 0 -- 222
			while i < #self.lastContext.buttons do -- 222
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 223
				i = i + 1 -- 222
			end -- 222
		end -- 222
		do -- 222
			i = 0 -- 225
			while i < #self.lastContext.rectZones do -- 225
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 226
				i = i + 1 -- 225
			end -- 225
		end -- 225
	end -- 225
	local ____buttonIds_6 = buttonIds -- 230
	local ____zoneIds_7 = zoneIds -- 231
	local ____temp_0 -- 232
	if self.lastContext ~= nil then -- 232
		____temp_0 = self.lastContext.viewport.isPortrait -- 232
	else -- 232
		____temp_0 = false -- 232
	end -- 232
	local ____temp_1 -- 233
	if self.lastContext ~= nil then -- 233
		____temp_1 = self.lastContext.overlayActive -- 233
	else -- 233
		____temp_1 = false -- 233
	end -- 233
	local ____temp_2 -- 234
	if router ~= nil then -- 234
		____temp_2 = router.crouchToggled -- 234
	else -- 234
		____temp_2 = false -- 234
	end -- 234
	local ____temp_3 -- 235
	if router ~= nil then -- 235
		____temp_3 = router.slowToggled -- 235
	else -- 235
		____temp_3 = false -- 235
	end -- 235
	local ____temp_4 -- 236
	if router ~= nil then -- 236
		____temp_4 = router.coverToggled -- 236
	else -- 236
		____temp_4 = false -- 236
	end -- 236
	local ____temp_5 -- 237
	if router ~= nil then -- 237
		____temp_5 = router.cartGripLatched -- 237
	else -- 237
		____temp_5 = false -- 237
	end -- 237
	return { -- 229
		buttonIds = ____buttonIds_6, -- 230
		zoneIds = ____zoneIds_7, -- 231
		isPortrait = ____temp_0, -- 232
		overlayActive = ____temp_1, -- 233
		crouchToggled = ____temp_2, -- 234
		slowToggled = ____temp_3, -- 235
		coverToggled = ____temp_4, -- 236
		cartGripLatch = ____temp_5 -- 237
	} -- 237
end -- 208
function TouchControls.prototype.syncContext(self, params) -- 242
	self.time = self.time + math.min( -- 243
		0.05, -- 243
		math.max(0, params.dt) -- 243
	) -- 243
	self.lastMode = params.mode -- 244
	self.lastScreen = params.screen -- 245
	self.lastPlay = params.play -- 246
	self.lastRun = params.run -- 247
	local vp = params.viewport -- 249
	local p = params.play -- 250
	local router = params.router -- 251
	local input = params.input -- 252
	local isPortrait = vp.isPortrait -- 253
	local overlayScale = isPortrait and 1 or vp.uiScale -- 254
	local ovW = vp.fullW / math.max(0.25, overlayScale) -- 255
	local ovH = vp.fullH / math.max(0.25, overlayScale) -- 256
	local safeL = vp.safe.left / math.max(0.25, overlayScale) -- 257
	local safeR = vp.safe.right / math.max(0.25, overlayScale) -- 258
	local safeT = vp.safe.top / math.max(0.25, overlayScale) -- 259
	local safeB = vp.safe.bottom / math.max(0.25, overlayScale) -- 260
	local overlayActive = input:shouldShowTouchControls() -- 262
	local allowMouseOnOverlay = isPortrait or input.settings.modePref == "touch" -- 263
	local allowAutoGameplayTouch = input.settings.modePref == "auto" or input.settings.modePref == "touch" -- 264
	local sc = router.settings.touchScale -- 265
	local isPlayMode = params.mode == 1 and params.screen == "play" and p ~= nil -- 267
	local isTrialMode = params.mode == 2 and p ~= nil -- 268
	local gameplayActive = isPlayMode or isTrialMode -- 269
	local ____opt_8 = params.run -- 271
	local trial = ____opt_8 and ____opt_8.trial -- 271
	local ____temp_13 = isTrialMode and trial ~= nil -- 272
	if ____temp_13 then -- 272
		local ____trial_lost_12 = trial.lost -- 272
		if not ____trial_lost_12 then -- 272
			local ____opt_10 = params.run -- 272
			____trial_lost_12 = (____opt_10 and ____opt_10.finished) == true -- 272
		end -- 272
		____temp_13 = ____trial_lost_12 -- 272
	end -- 272
	local trialEnded = ____temp_13 -- 272
	local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 273
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) -- 275
	local ____temp_14 -- 277
	if isPlayMode and p ~= nil then -- 277
		____temp_14 = isCutsceneBlockingPlay(p) -- 278
	else -- 278
		____temp_14 = isTrialMode and p ~= nil and (p.paused or trialEnded or trialHasOffers) -- 279
	end -- 279
	local cutsceneBlocking = ____temp_14 -- 277
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 281
	local cart = p ~= nil and p.room.cart or nil -- 283
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 284
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 286
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 287
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 288
	local buttons = {} -- 291
	local rectZones = {} -- 292
	local unitPortrait = clamp( -- 295
		math.min( -- 295
			vp.fullW / 420, -- 295
			math.max(180, vp.deckH) / 340 -- 295
		), -- 295
		0.72, -- 295
		1.15 -- 295
	) -- 295
	local stickMaxR = isPortrait and math.floor(52 * unitPortrait * sc + 0.5) or STICK_BASE_R_LANDSCAPE * sc -- 296
	local stickDefaultX = isPortrait and safeL + math.max( -- 299
		stickMaxR + 26, -- 300
		math.floor(ovW * 0.24 + 0.5) -- 300
	) or safeL + 126 * sc -- 301
	local stickDefaultY = isPortrait and math.max(safeB + stickMaxR + 24, vp.deckH * 0.44) or safeB + 126 * sc -- 302
	local stickZoneMaxX = isPortrait and ovW * 0.5 or ovW * 0.46 -- 305
	local stickZoneMaxY = isPortrait and math.max(40, vp.deckH - 8) or ovH - 110 -- 306
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 308
	if overlayActive then -- 311
		if isPortrait then -- 312
			local topY = ovH - vp.topBarH * 0.5 -- 314
			local pillH = 26 -- 315
			local rx = ovW - safeR - 10 -- 316
			if gameplayActive and p ~= nil and not p.paused then -- 318
				local pw = 58 -- 319
				rx = rx - pw -- 320
				buttons[#buttons + 1] = { -- 321
					id = "pause", -- 322
					x = rx + pw * 0.5, -- 323
					y = topY, -- 324
					r = 22, -- 325
					shape = "pill", -- 326
					rect = Rect(rx, topY - pillH * 0.5, pw, pillH), -- 327
					label = "暂歇", -- 328
					accent = "silk", -- 329
					active = false, -- 330
					highlighted = false, -- 331
					progress = 0, -- 332
					dimmed = false -- 333
				} -- 333
				rx = rx - 8 -- 335
				local inTowerEnd = p.room.key == "tower" and p.phase ~= "tower-wait" -- 337
				if not inTowerEnd then -- 338
					local rw = 58 -- 339
					rx = rx - rw -- 340
					buttons[#buttons + 1] = { -- 341
						id = "retry", -- 342
						x = rx + rw * 0.5, -- 343
						y = topY, -- 344
						r = 22, -- 345
						shape = "pill", -- 346
						rect = Rect(rx, topY - pillH * 0.5, rw, pillH), -- 347
						label = "重试", -- 348
						accent = "amber", -- 349
						active = false, -- 350
						highlighted = false, -- 351
						progress = 0, -- 352
						dimmed = false -- 353
					} -- 353
					rx = rx - 8 -- 355
				end -- 355
			end -- 355
			local mw = 54 -- 359
			rx = rx - mw -- 360
			buttons[#buttons + 1] = { -- 361
				id = "mute", -- 362
				x = rx + mw * 0.5, -- 363
				y = topY, -- 364
				r = 20, -- 365
				shape = "pill", -- 366
				rect = Rect(rx, topY - pillH * 0.5, mw, pillH), -- 367
				label = params.isMuted and "静音" or "有声", -- 368
				accent = params.isMuted and "rouge" or "cyan", -- 369
				active = params.isMuted, -- 370
				highlighted = false, -- 371
				progress = 0, -- 372
				dimmed = false -- 373
			} -- 373
			rx = rx - 8 -- 375
			if canToggleFullscreen() then -- 377
				local fw = 54 -- 378
				rx = rx - fw -- 379
				buttons[#buttons + 1] = { -- 380
					id = "fullscreen", -- 381
					x = rx + fw * 0.5, -- 382
					y = topY, -- 383
					r = 20, -- 384
					shape = "pill", -- 385
					rect = Rect(rx, topY - pillH * 0.5, fw, pillH), -- 386
					label = params.isFullscreen and "窗口" or "全屏", -- 387
					accent = "silk", -- 388
					active = params.isFullscreen, -- 389
					highlighted = false, -- 390
					progress = 0, -- 391
					dimmed = false -- 392
				} -- 392
			end -- 392
		else -- 392
			if isPlayMode and not modal then -- 397
				local px = ovW - safeR - 112 -- 398
				local py = ovH - safeT - 66 -- 399
				buttons[#buttons + 1] = { -- 400
					id = "pause", -- 401
					x = px + 46, -- 402
					y = py + 21, -- 403
					r = 28, -- 404
					shape = "pill", -- 405
					rect = Rect(px, py, 94, 42), -- 406
					label = "暂歇", -- 407
					accent = "silk", -- 408
					active = false, -- 409
					highlighted = false, -- 410
					progress = 0, -- 411
					dimmed = false -- 412
				} -- 412
				if isWebPlatform() then -- 415
					local mw = 58 -- 416
					local mx = px - mw - 10 -- 417
					buttons[#buttons + 1] = { -- 418
						id = "mute", -- 419
						x = mx + mw * 0.5, -- 420
						y = py + 21, -- 421
						r = 22, -- 422
						shape = "pill", -- 423
						rect = Rect(mx, py + 4, mw, 34), -- 424
						label = params.isMuted and "静音" or "有声", -- 425
						accent = params.isMuted and "rouge" or "cyan", -- 426
						active = params.isMuted, -- 427
						highlighted = false, -- 428
						progress = 0, -- 429
						dimmed = false -- 430
					} -- 430
					if canToggleFullscreen() then -- 432
						local fw = 58 -- 433
						local fx = mx - fw - 8 -- 434
						buttons[#buttons + 1] = { -- 435
							id = "fullscreen", -- 436
							x = fx + fw * 0.5, -- 437
							y = py + 21, -- 438
							r = 22, -- 439
							shape = "pill", -- 440
							rect = Rect(fx, py + 4, fw, 34), -- 441
							label = params.isFullscreen and "窗口" or "全屏", -- 442
							accent = "silk", -- 443
							active = params.isFullscreen, -- 444
							highlighted = false, -- 445
							progress = 0, -- 446
							dimmed = false -- 447
						} -- 447
					end -- 447
				end -- 447
			end -- 447
		end -- 447
	end -- 447
	if isPortrait and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 456
		local cy = math.max(safeB + 84, vp.deckH * 0.5) -- 458
		local leftX = safeL + math.max(82, ovW * 0.25) -- 459
		local step = math.min( -- 460
			54, -- 460
			math.max(42, ovW * 0.12) -- 460
		) -- 460
		local nr = math.min( -- 461
			26, -- 461
			math.max(21, ovW * 0.06) -- 461
		) -- 461
		buttons[#buttons + 1] = { -- 462
			id = "nav_up", -- 462
			x = leftX, -- 462
			y = cy + step, -- 462
			r = nr, -- 462
			label = "上", -- 462
			accent = "silk", -- 462
			active = false, -- 462
			highlighted = false, -- 462
			progress = 0, -- 462
			dimmed = false -- 462
		} -- 462
		buttons[#buttons + 1] = { -- 463
			id = "nav_down", -- 463
			x = leftX, -- 463
			y = cy - step, -- 463
			r = nr, -- 463
			label = "下", -- 463
			accent = "silk", -- 463
			active = false, -- 463
			highlighted = false, -- 463
			progress = 0, -- 463
			dimmed = false -- 463
		} -- 463
		buttons[#buttons + 1] = { -- 464
			id = "nav_left", -- 464
			x = leftX - step, -- 464
			y = cy, -- 464
			r = nr, -- 464
			label = "左", -- 464
			accent = "silk", -- 464
			active = false, -- 464
			highlighted = false, -- 464
			progress = 0, -- 464
			dimmed = false -- 464
		} -- 464
		buttons[#buttons + 1] = { -- 465
			id = "nav_right", -- 465
			x = leftX + step, -- 465
			y = cy, -- 465
			r = nr, -- 465
			label = "右", -- 465
			accent = "silk", -- 465
			active = false, -- 465
			highlighted = false, -- 465
			progress = 0, -- 465
			dimmed = false -- 465
		} -- 465
		local rightX = ovW - safeR - math.max(76, ovW * 0.23) -- 467
		buttons[#buttons + 1] = { -- 468
			id = "nav_confirm", -- 469
			x = rightX, -- 470
			y = cy + 28, -- 471
			r = 28, -- 472
			shape = "pill", -- 473
			rect = Rect(rightX - 48, cy + 6, 96, 44), -- 474
			label = "确认", -- 475
			accent = "rouge", -- 476
			active = false, -- 477
			highlighted = true, -- 478
			progress = 0, -- 479
			dimmed = false -- 480
		} -- 480
		buttons[#buttons + 1] = { -- 482
			id = "nav_back", -- 483
			x = rightX, -- 484
			y = cy - 30, -- 485
			r = 26, -- 486
			shape = "pill", -- 487
			rect = Rect(rightX - 48, cy - 50, 96, 40), -- 488
			label = "返回", -- 489
			accent = "silk", -- 490
			active = false, -- 491
			highlighted = false, -- 492
			progress = 0, -- 493
			dimmed = false -- 494
		} -- 494
	end -- 494
	local prompt -- 499
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 500
		if #params.storyTalentBoxes > 0 then -- 502
			local ti = 0 -- 503
			do -- 503
				ti = 0 -- 504
				while ti < #params.storyTalentBoxes do -- 504
					local b = params.storyTalentBoxes[ti + 1] -- 505
					local vx = vp.stageX + b.x * vp.uiScale -- 506
					local vy = vp.stageY + b.y * vp.uiScale -- 507
					local vw = b.width * vp.uiScale -- 508
					local vh = b.height * vp.uiScale -- 509
					rectZones[#rectZones + 1] = { -- 510
						id = "talent:" .. tostring(ti), -- 511
						rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 512
					} -- 512
					ti = ti + 1 -- 504
				end -- 504
			end -- 504
		end -- 504
		prompt = deriveWorldPrompt(p) -- 522
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 523
			local keyW = math.max( -- 525
				24, -- 525
				visualTextWidth(prompt.keyTag, 15) + 16 -- 525
			) -- 525
			local labelW = visualTextWidth(prompt.label, 15) -- 526
			local pillW = keyW + labelW + 24 -- 527
			local padX = math.max(115, pillW * 0.5 + 24) -- 528
			local sxUi = math.max( -- 529
				padX + vp.safeUi.left, -- 529
				math.min( -- 529
					vp.uiW - padX - vp.safeUi.right, -- 529
					params.cam:sx(prompt.x) / vp.uiScale -- 529
				) -- 529
			) -- 529
			local syUi = math.max( -- 530
				96 + vp.safeUi.bottom, -- 530
				math.min( -- 530
					vp.uiH - 110 - vp.safeUi.top, -- 530
					params.cam:sy(prompt.y) / vp.uiScale -- 530
				) -- 530
			) -- 530
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 531
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 532
			rectZones[#rectZones + 1] = { -- 533
				id = "worldPrompt", -- 534
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 535
			} -- 535
		end -- 535
	end -- 535
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 546
		local cx = ovW * 0.5 -- 548
		local cy = safeB + 46 -- 549
		buttons[#buttons + 1] = { -- 550
			id = "nav_confirm", -- 551
			x = cx, -- 552
			y = cy, -- 553
			r = 26, -- 554
			shape = "pill", -- 555
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 556
			label = "继续 · 归程", -- 557
			accent = "amber", -- 558
			active = false, -- 559
			highlighted = true, -- 560
			progress = 0, -- 561
			dimmed = false -- 562
		} -- 562
	end -- 562
	if isTrialMode and p ~= nil and overlayActive then -- 567
		if p.paused or trialEnded then -- 568
			local cx = ovW * 0.5 -- 569
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 570
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 571
			local bh = isPortrait and 44 or 50 -- 572
			local step = bh + 14 -- 573
			if p.paused and not trialEnded then -- 574
				rectZones[#rectZones + 1] = { -- 575
					id = "trial:resume", -- 575
					rect = Rect(cx - bw * 0.5, cy + step * 0.8, bw, bh) -- 575
				} -- 575
			end -- 575
			rectZones[#rectZones + 1] = { -- 577
				id = "trial:retry", -- 577
				rect = Rect(cx - bw * 0.5, cy - bh * 0.2, bw, bh) -- 577
			} -- 577
			rectZones[#rectZones + 1] = { -- 578
				id = "trial:title", -- 578
				rect = Rect(cx - bw * 0.5, cy - step * 1.2, bw, bh) -- 578
			} -- 578
		elseif trialHasOffers and trial ~= nil then -- 579
			local count = #trial.offers -- 580
			local cardW = isPortrait and math.min( -- 581
				114, -- 581
				math.floor((ovW - 44) / math.max(1, count) - 10) -- 581
			) or 216 -- 581
			local cardH = isPortrait and 52 or 62 -- 582
			local gap = isPortrait and 10 or 18 -- 583
			local totalW = count * cardW + (count - 1) * gap -- 584
			local startX = (ovW - totalW) * 0.5 -- 585
			local y = (isPortrait and vp.deckH * 0.52 or ovH * 0.48) - cardH * 0.5 -- 586
			local i = 0 -- 587
			do -- 587
				i = 0 -- 588
				while i < count do -- 588
					rectZones[#rectZones + 1] = { -- 589
						id = "talent:" .. tostring(i), -- 590
						rect = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 591
					} -- 591
					i = i + 1 -- 588
				end -- 588
			end -- 588
			if not isPortrait then -- 594
				rectZones[#rectZones + 1] = { -- 595
					id = "pause", -- 595
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 595
				} -- 595
			end -- 595
		elseif not isPortrait then -- 597
			rectZones[#rectZones + 1] = { -- 598
				id = "pause", -- 598
				rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 598
			} -- 598
			rectZones[#rectZones + 1] = { -- 599
				id = "retry", -- 599
				rect = Rect(ovW - safeR - 210, ovH - safeT - 64, 92, 46) -- 599
			} -- 599
		end -- 599
	end -- 599
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 604
		local interactMeta = deriveInteractActionMeta( -- 605
			p, -- 605
			prompt or deriveWorldPrompt(p), -- 605
			cartNearby, -- 605
			router.cartGripLatched -- 605
		) -- 605
		if isPortrait then -- 607
			local u = unitPortrait * sc -- 608
			local rightX = ovW - safeR - math.floor(68 * u + 0.5) -- 609
			local bottomY = math.max( -- 610
				safeB + math.floor(70 * u + 0.5), -- 610
				vp.deckH * 0.4 -- 610
			) -- 610
			local postY = math.min( -- 611
				vp.deckH - 26, -- 611
				stickDefaultY + stickMaxR + math.floor(42 * u + 0.5) -- 611
			) -- 611
			bottleCancelCenter = { -- 612
				x = rightX - math.floor(14 * u + 0.5), -- 612
				y = bottomY + math.floor(10 * u + 0.5), -- 612
				r = math.floor(34 * u + 0.5) -- 612
			} -- 612
			if not p.childMode then -- 614
				local cw = math.floor(86 * u + 0.5) -- 616
				local ch = math.floor(32 * u + 0.5) -- 617
				buttons[#buttons + 1] = { -- 618
					id = "cover", -- 619
					x = stickDefaultX, -- 620
					y = postY, -- 621
					r = 24 * u, -- 622
					shape = "pill", -- 623
					toggle = true, -- 624
					rect = Rect(stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch), -- 625
					label = router.coverToggled and "离掩体" or "贴掩体", -- 626
					accent = "cyan", -- 627
					active = router.coverToggled or p.coverHug, -- 628
					highlighted = p.coverNear and not router.coverToggled, -- 629
					progress = 0, -- 630
					dimmed = not p.coverNear and not router.coverToggled -- 631
				} -- 631
				buttons[#buttons + 1] = { -- 635
					id = "fire", -- 636
					x = rightX, -- 637
					y = bottomY + math.floor(8 * u + 0.5), -- 638
					r = math.floor(36 * u + 0.5), -- 639
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 640
					subLabel = "拖瞄", -- 641
					accent = "rouge", -- 642
					active = router:isButtonHeld("fire"), -- 643
					highlighted = p.reloadPendingEffect ~= "", -- 644
					progress = 0, -- 645
					dimmed = p.gripping -- 646
				} -- 646
				local nearLedge = isNearLowLedgeForButton(p) -- 648
				buttons[#buttons + 1] = { -- 649
					id = "jump", -- 650
					x = rightX - math.floor(84 * u + 0.5), -- 651
					y = bottomY - math.floor(16 * u + 0.5), -- 652
					r = math.floor(28 * u + 0.5), -- 653
					label = nearLedge and "翻越" or "翻滚", -- 654
					accent = "cyan", -- 655
					active = router:isButtonHeld("jump"), -- 656
					highlighted = nearLedge, -- 657
					progress = 0, -- 658
					dimmed = p.gripping -- 659
				} -- 659
				buttons[#buttons + 1] = { -- 661
					id = "interact", -- 662
					x = rightX - math.floor(10 * u + 0.5), -- 663
					y = bottomY + math.floor(88 * u + 0.5), -- 664
					r = math.floor(30 * u + 0.5), -- 665
					label = interactMeta.label, -- 666
					subLabel = interactMeta.subLabel, -- 667
					accent = interactMeta.urgent and "rouge" or "amber", -- 668
					active = router:isButtonHeld("interact"), -- 669
					highlighted = interactMeta.available, -- 670
					progress = interactMeta.progress, -- 671
					dimmed = not interactMeta.available -- 672
				} -- 672
				if isPlayMode and p.archive.artifactOwned then -- 674
					local eq = p.equippedWeapon == "time_shuttler" -- 675
					buttons[#buttons + 1] = { -- 676
						id = "artifact", -- 677
						x = rightX - math.floor(90 * u + 0.5), -- 678
						y = bottomY + math.floor(68 * u + 0.5), -- 679
						r = math.floor(24 * u + 0.5), -- 680
						label = eq and "收器" or "穿梭", -- 681
						accent = "amber", -- 682
						active = eq, -- 683
						highlighted = eq, -- 684
						progress = 0, -- 685
						dimmed = false -- 686
					} -- 686
				end -- 686
			else -- 686
				local pw = math.floor(68 * u + 0.5) -- 691
				local ph = math.floor(32 * u + 0.5) -- 692
				buttons[#buttons + 1] = { -- 693
					id = "crouch", -- 694
					x = stickDefaultX - math.floor(38 * u + 0.5), -- 695
					y = postY, -- 696
					r = 22 * u, -- 697
					shape = "pill", -- 698
					toggle = true, -- 699
					rect = Rect( -- 700
						stickDefaultX - math.floor(38 * u + 0.5) - pw * 0.5, -- 700
						postY - ph * 0.5, -- 700
						pw, -- 700
						ph -- 700
					), -- 700
					label = router.crouchToggled and "起身" or "蹲伏", -- 701
					accent = "emerald", -- 702
					active = router.crouchToggled or p.player.crouch, -- 703
					highlighted = p.scavChase and not p.player.crouch, -- 704
					progress = 0, -- 705
					dimmed = false -- 706
				} -- 706
				buttons[#buttons + 1] = { -- 708
					id = "cover", -- 709
					x = stickDefaultX + math.floor(38 * u + 0.5), -- 710
					y = postY, -- 711
					r = 22 * u, -- 712
					shape = "pill", -- 713
					toggle = true, -- 714
					rect = Rect( -- 715
						stickDefaultX + math.floor(38 * u + 0.5) - pw * 0.5, -- 715
						postY - ph * 0.5, -- 715
						pw, -- 715
						ph -- 715
					), -- 715
					label = router.slowToggled and "常步" or "轻步", -- 716
					accent = "silk", -- 717
					active = router.slowToggled, -- 718
					highlighted = false, -- 719
					progress = 0, -- 720
					dimmed = false -- 721
				} -- 721
				buttons[#buttons + 1] = { -- 725
					id = "jump", -- 726
					x = rightX, -- 727
					y = bottomY + math.floor(8 * u + 0.5), -- 728
					r = math.floor(32 * u + 0.5), -- 729
					label = "跳跃", -- 730
					accent = "amber", -- 731
					active = router:isButtonHeld("jump"), -- 732
					highlighted = false, -- 733
					progress = 0, -- 734
					dimmed = p.gripping -- 735
				} -- 735
				buttons[#buttons + 1] = { -- 737
					id = "interact", -- 738
					x = rightX - math.floor(8 * u + 0.5), -- 739
					y = bottomY + math.floor(86 * u + 0.5), -- 740
					r = math.floor(31 * u + 0.5), -- 741
					label = interactMeta.label, -- 742
					subLabel = interactMeta.subLabel, -- 743
					accent = interactMeta.urgent and "rouge" or "amber", -- 744
					active = router:isButtonHeld("interact"), -- 745
					highlighted = interactMeta.available, -- 746
					progress = interactMeta.progress, -- 747
					dimmed = not interactMeta.available -- 748
				} -- 748
				if canBottleAim then -- 750
					buttons[#buttons + 1] = { -- 751
						id = "bottle", -- 752
						x = rightX - math.floor(86 * u + 0.5), -- 753
						y = bottomY + math.floor(46 * u + 0.5), -- 754
						r = math.floor(32 * u + 0.5), -- 755
						label = "投瓶", -- 756
						subLabel = "拖瞄", -- 757
						accent = "amber", -- 758
						active = router:isButtonHeld("bottle"), -- 759
						highlighted = true, -- 760
						progress = math.min(1, p.aimHold / 0.12), -- 761
						dimmed = false -- 762
					} -- 762
				end -- 762
			end -- 762
		else -- 762
			local rightX = ovW - safeR - 92 * sc -- 768
			local bottomY = safeB + 110 * sc -- 769
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 770
			if not p.childMode then -- 772
				buttons[#buttons + 1] = { -- 773
					id = "fire", -- 774
					x = rightX, -- 775
					y = bottomY + 12 * sc, -- 776
					r = 45 * sc, -- 777
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 778
					subLabel = "拖瞄", -- 779
					accent = "rouge", -- 780
					active = router:isButtonHeld("fire"), -- 781
					highlighted = p.reloadPendingEffect ~= "", -- 782
					progress = 0, -- 783
					dimmed = p.gripping -- 784
				} -- 784
				local nearLedge = isNearLowLedgeForButton(p) -- 786
				buttons[#buttons + 1] = { -- 787
					id = "jump", -- 788
					x = rightX - 116 * sc, -- 789
					y = bottomY - 8 * sc, -- 790
					r = 34 * sc, -- 791
					label = nearLedge and "翻越" or "翻滚", -- 792
					accent = "cyan", -- 793
					active = router:isButtonHeld("jump"), -- 794
					highlighted = nearLedge, -- 795
					progress = 0, -- 796
					dimmed = p.gripping -- 797
				} -- 797
				buttons[#buttons + 1] = { -- 799
					id = "cover", -- 800
					x = rightX - 120 * sc, -- 801
					y = bottomY + 94 * sc, -- 802
					r = 32 * sc, -- 803
					label = router.coverToggled and "离掩" or "掩体", -- 804
					accent = "cyan", -- 805
					active = router.coverToggled, -- 806
					highlighted = p.coverNear and not router.coverToggled, -- 807
					progress = 0, -- 808
					dimmed = not p.coverNear and not router.coverToggled -- 809
				} -- 809
				buttons[#buttons + 1] = { -- 811
					id = "interact", -- 812
					x = rightX - 10 * sc, -- 813
					y = bottomY + 122 * sc, -- 814
					r = 36 * sc, -- 815
					label = interactMeta.label, -- 816
					subLabel = interactMeta.subLabel, -- 817
					accent = interactMeta.urgent and "rouge" or "amber", -- 818
					active = router:isButtonHeld("interact"), -- 819
					highlighted = interactMeta.available, -- 820
					progress = interactMeta.progress, -- 821
					dimmed = not interactMeta.available -- 822
				} -- 822
				if isPlayMode and p.archive.artifactOwned then -- 824
					local eq = p.equippedWeapon == "time_shuttler" -- 825
					buttons[#buttons + 1] = { -- 826
						id = "artifact", -- 827
						x = rightX - 112 * sc, -- 828
						y = bottomY + 184 * sc, -- 829
						r = 27 * sc, -- 830
						label = eq and "收器" or "穿梭", -- 831
						accent = "amber", -- 832
						active = eq, -- 833
						highlighted = eq, -- 834
						progress = 0, -- 835
						dimmed = false -- 836
					} -- 836
				end -- 836
			else -- 836
				buttons[#buttons + 1] = { -- 840
					id = "jump", -- 841
					x = rightX, -- 842
					y = bottomY + 12 * sc, -- 843
					r = 38 * sc, -- 844
					label = "跳跃", -- 845
					accent = "amber", -- 846
					active = router:isButtonHeld("jump"), -- 847
					highlighted = false, -- 848
					progress = 0, -- 849
					dimmed = p.gripping -- 850
				} -- 850
				buttons[#buttons + 1] = { -- 852
					id = "crouch", -- 853
					x = rightX - 106 * sc, -- 854
					y = bottomY - 6 * sc, -- 855
					r = 34 * sc, -- 856
					label = router.crouchToggled and "起身" or "蹲伏", -- 857
					accent = "emerald", -- 858
					active = router.crouchToggled or p.player.crouch, -- 859
					highlighted = p.scavChase and not p.player.crouch, -- 860
					progress = 0, -- 861
					dimmed = false -- 862
				} -- 862
				buttons[#buttons + 1] = { -- 864
					id = "cover", -- 865
					x = rightX - 196 * sc, -- 866
					y = bottomY - 16 * sc, -- 867
					r = 29 * sc, -- 868
					label = router.slowToggled and "常步" or "轻步", -- 869
					accent = "silk", -- 870
					active = router.slowToggled, -- 871
					highlighted = false, -- 872
					progress = 0, -- 873
					dimmed = false -- 874
				} -- 874
				buttons[#buttons + 1] = { -- 876
					id = "interact", -- 877
					x = rightX - 12 * sc, -- 878
					y = bottomY + 114 * sc, -- 879
					r = 36 * sc, -- 880
					label = interactMeta.label, -- 881
					subLabel = interactMeta.subLabel, -- 882
					accent = interactMeta.urgent and "rouge" or "amber", -- 883
					active = router:isButtonHeld("interact"), -- 884
					highlighted = interactMeta.available, -- 885
					progress = interactMeta.progress, -- 886
					dimmed = not interactMeta.available -- 887
				} -- 887
				if canBottleAim then -- 889
					buttons[#buttons + 1] = { -- 890
						id = "bottle", -- 891
						x = rightX - 114 * sc, -- 892
						y = bottomY + 98 * sc, -- 893
						r = 38 * sc, -- 894
						label = "投瓶", -- 895
						subLabel = "拖瞄", -- 896
						accent = "amber", -- 897
						active = router:isButtonHeld("bottle"), -- 898
						highlighted = true, -- 899
						progress = math.min(1, p.aimHold / 0.12), -- 900
						dimmed = false -- 901
					} -- 901
				end -- 901
			end -- 901
		end -- 901
	end -- 901
	local enemyTargets = canShoot and p ~= nil and (isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH)) or ({}) -- 909
	local playerScreenX = vp.stageW * 0.5 -- 915
	local playerScreenY = vp.stageH * 0.38 -- 916
	if p ~= nil then -- 917
		if isPlayMode and params.cam ~= nil then -- 918
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 919
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 920
		else -- 920
			playerScreenX = vp.stageW * 0.45 -- 922
			playerScreenY = vp.stageH * 0.36 -- 923
		end -- 923
	end -- 923
	local ctx = { -- 927
		viewport = vp, -- 928
		overlayScale = overlayScale, -- 929
		overlayActive = overlayActive, -- 930
		allowAutoGameplayTouch = allowAutoGameplayTouch, -- 931
		allowMouseOnOverlay = allowMouseOnOverlay, -- 932
		modal = modal, -- 933
		gameplayActive = gameplayActive, -- 934
		cutsceneBlocking = cutsceneBlocking, -- 935
		childMode = p ~= nil and p.childMode, -- 936
		allowDepth = allowDepth, -- 937
		canShoot = canShoot, -- 938
		canBottleAim = canBottleAim, -- 939
		cartNearby = cartNearby, -- 940
		cartGripping = p ~= nil and p.gripping, -- 941
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 942
		coverNear = p ~= nil and p.coverNear, -- 943
		playerRolling = p ~= nil and p.player.rollT > 0, -- 944
		inLowArch = p ~= nil and isInLowArch(p), -- 945
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 946
		playerFacing = p ~= nil and p.player.facing or 1, -- 947
		playerScreenX = playerScreenX, -- 948
		playerScreenY = playerScreenY, -- 949
		enemyTargets = enemyTargets, -- 950
		stickZoneMaxX = stickZoneMaxX, -- 951
		stickZoneMaxY = stickZoneMaxY, -- 952
		stickDefaultX = stickDefaultX, -- 953
		stickDefaultY = stickDefaultY, -- 954
		stickMaxR = stickMaxR, -- 955
		stickFixedOrigin = isPortrait, -- 956
		buttons = buttons, -- 957
		rectZones = rectZones, -- 958
		bottleCancelCenter = bottleCancelCenter -- 959
	} -- 959
	self.lastContext = ctx -- 962
	router:setFrameContext(ctx, params.dt) -- 963
	return ctx -- 964
end -- 242
function TouchControls.prototype.render(self, router) -- 968
	self.deckDraw:clear() -- 969
	self.padDraw:clear() -- 970
	self.padInkDraw:clear() -- 971
	self.padGlow:clear() -- 972
	self.padArt:beginFrame() -- 973
	self.texts:beginFrame() -- 974
	local ctx = self.lastContext -- 976
	if ctx == nil or not ctx.overlayActive and not ctx.viewport.isPortrait then -- 977
		self.padArt:endFrame() -- 978
		self.texts:endFrame() -- 979
		return -- 980
	end -- 980
	local vp = ctx.viewport -- 983
	local sc = math.max(0.25, ctx.overlayScale) -- 984
	self.overlayRoot.scaleX = sc -- 985
	self.overlayRoot.scaleY = sc -- 986
	local ovW = vp.fullW / sc -- 988
	local ovH = vp.fullH / sc -- 989
	local baseAlpha = router.settings.touchOpacity -- 990
	if vp.isPortrait then -- 993
		self:drawPortraitFrame(ctx, ovW, ovH) -- 994
	end -- 994
	if not ctx.overlayActive then -- 997
		self.padArt:endFrame() -- 998
		self.texts:endFrame() -- 999
		return -- 1000
	end -- 1000
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 1004
		local rx = ovW * 0.5 -- 1005
		local ry = vp.isPortrait and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 1006
		drawSilkVeil( -- 1007
			self.padDraw, -- 1007
			self.padArt, -- 1007
			"touch_restart_veil", -- 1007
			rx, -- 1007
			ry, -- 1007
			230, -- 1007
			36, -- 1007
			PALETTE.inkWash, -- 1007
			0.78 * baseAlpha, -- 1007
			1 -- 1007
		) -- 1007
		drawHairline( -- 1008
			self.padInkDraw, -- 1008
			self.padArt, -- 1008
			"touch_restart_line", -- 1008
			rx, -- 1008
			ry + 16, -- 1008
			180, -- 1008
			PALETTE.amber, -- 1008
			0.52 * baseAlpha, -- 1008
			true, -- 1008
			2 -- 1008
		) -- 1008
		self.texts:put( -- 1009
			"xs", -- 1009
			"轻触屏幕再次启程", -- 1009
			rx, -- 1009
			ry, -- 1009
			toColor(PALETTE.amberCore), -- 1009
			0.5, -- 1009
			0.5, -- 1009
			"Center", -- 1009
			1.6, -- 1009
			0.94, -- 1009
			0.08 -- 1009
		) -- 1009
	end -- 1009
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 1013
		self:drawTrialZones(ctx, baseAlpha) -- 1014
	end -- 1014
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 1018
		self:drawStick(router, ctx, baseAlpha) -- 1019
	end -- 1019
	self:drawButtons(router, ctx, baseAlpha) -- 1023
	local bottleDrag = router:getBottleDragVisual() -- 1026
	if bottleDrag.active then -- 1027
		local cx = bottleDrag.cancelX -- 1028
		local cy = bottleDrag.cancelY -- 1029
		local cr = bottleDrag.cancelR -- 1030
		local hot = bottleDrag.cancelHover -- 1031
		fillCirclePoly( -- 1032
			self.padDraw, -- 1033
			cx, -- 1034
			cy, -- 1035
			cr, -- 1036
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 1037
			0, -- 1038
			nil, -- 1039
			22 -- 1040
		) -- 1040
		drawRingArc( -- 1042
			self.padInkDraw, -- 1042
			cx, -- 1042
			cy, -- 1042
			cr, -- 1042
			0, -- 1042
			TWO_PI, -- 1042
			hot and 2.2 or 1.3, -- 1042
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 1042
			22 -- 1042
		) -- 1042
		self.texts:put( -- 1043
			"xs", -- 1043
			hot and "松手取消" or "拖此取消", -- 1043
			cx, -- 1043
			cy, -- 1043
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 1043
			0.5, -- 1043
			0.5, -- 1043
			"Center", -- 1043
			0.8, -- 1043
			0.96, -- 1043
			0.08 -- 1043
		) -- 1043
	end -- 1043
	self.padArt:endFrame() -- 1046
	self.texts:endFrame() -- 1047
end -- 968
function TouchControls.prototype.drawPortraitFrame(self, ctx, w, h) -- 1050
	local vp = ctx.viewport -- 1051
	local topY = vp.stageY + vp.stageH -- 1052
	if topY < h then -- 1054
		self.deckDraw:drawRect( -- 1055
			Rect(0, topY, w, h - topY), -- 1055
			toColor(PALETTE.inkVoid, 252) -- 1055
		) -- 1055
		self.deckDraw:drawSegment( -- 1056
			Vec2(0, topY), -- 1056
			Vec2(w, topY), -- 1056
			1, -- 1056
			toColor(PALETTE.silkDim, 140) -- 1056
		) -- 1056
		local labelY = topY + (h - topY) * 0.5 -- 1057
		self.texts:put( -- 1058
			"xs", -- 1058
			"向西守望 · 掌机竖屏", -- 1058
			vp.safe.left + 12, -- 1058
			labelY, -- 1058
			toColor(PALETTE.amberCore), -- 1058
			0, -- 1058
			0.5, -- 1058
			"Left", -- 1058
			0.8, -- 1058
			0.88, -- 1058
			0.08 -- 1058
		) -- 1058
	end -- 1058
	if vp.stageX > 0 then -- 1061
		self.deckDraw:drawRect( -- 1062
			Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 1062
			toColor(PALETTE.inkVoid, 255) -- 1062
		) -- 1062
		self.deckDraw:drawRect( -- 1063
			Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 1063
			toColor(PALETTE.inkVoid, 255) -- 1063
		) -- 1063
	end -- 1063
	if vp.deckH > 0 then -- 1066
		fillVGradRect( -- 1067
			self.deckDraw, -- 1067
			0, -- 1067
			0, -- 1067
			w, -- 1067
			vp.deckH, -- 1067
			toColor(PALETTE.voidDark, 255), -- 1067
			toColor(PALETTE.inkWash, 255) -- 1067
		) -- 1067
		self.deckDraw:drawSegment( -- 1068
			Vec2(0, vp.deckH), -- 1068
			Vec2(w, vp.deckH), -- 1068
			1.2, -- 1068
			toColor(PALETTE.silkLine, 165) -- 1068
		) -- 1068
		self.deckDraw:drawSegment( -- 1069
			Vec2(18, vp.deckH - 4), -- 1069
			Vec2(w - 18, vp.deckH - 4), -- 1069
			0.6, -- 1069
			toColor(PALETTE.silkDim, 85) -- 1069
		) -- 1069
		drawDiamond( -- 1070
			self.padInkDraw, -- 1070
			w * 0.5, -- 1070
			vp.deckH, -- 1070
			5, -- 1070
			5, -- 1070
			toColor(PALETTE.rouge, 220), -- 1070
			0.9, -- 1070
			toColor(PALETTE.silkLine, 180) -- 1070
		) -- 1070
		local footY = math.max(vp.safe.bottom + 14, 16) -- 1072
		local p = self.lastPlay -- 1073
		local inOverlayModal = p ~= nil and (p.reloadOpen or p.craftBench.active) -- 1074
		local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or p ~= nil and p.paused) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 1075
		self.texts:put( -- 1082
			"xs", -- 1082
			hint, -- 1082
			w * 0.5, -- 1082
			footY, -- 1082
			toColor(PALETTE.textDim), -- 1082
			0.5, -- 1082
			0.5, -- 1082
			"Center", -- 1082
			0.8, -- 1082
			0.78, -- 1082
			0.06 -- 1082
		) -- 1082
	end -- 1082
end -- 1050
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 1086
	local stick = router:getStickVisual() -- 1087
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 1088
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 1091
	fillCirclePoly( -- 1093
		self.padDraw, -- 1094
		stick.originX, -- 1095
		stick.originY, -- 1096
		stick.radius, -- 1097
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 1098
		0, -- 1099
		nil, -- 1100
		28 -- 1101
	) -- 1101
	drawRingArc( -- 1103
		self.padInkDraw, -- 1103
		stick.originX, -- 1103
		stick.originY, -- 1103
		stick.radius, -- 1103
		0, -- 1103
		TWO_PI, -- 1103
		stick.active and 1.5 or 1, -- 1103
		toColor(ringCol, 168 * stickAlpha), -- 1103
		28 -- 1103
	) -- 1103
	if stick.allowDepth then -- 1105
		local dOff = stick.radius - 10 -- 1106
		self.padInkDraw:drawDot( -- 1107
			Vec2(stick.originX, stick.originY + dOff), -- 1107
			2.1, -- 1107
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1107
		) -- 1107
		self.padInkDraw:drawDot( -- 1108
			Vec2(stick.originX, stick.originY - dOff), -- 1108
			2.1, -- 1108
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1108
		) -- 1108
		self.padInkDraw:drawDot( -- 1109
			Vec2(stick.originX - dOff, stick.originY), -- 1109
			2.1, -- 1109
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1109
		) -- 1109
		self.padInkDraw:drawDot( -- 1110
			Vec2(stick.originX + dOff, stick.originY), -- 1110
			2.1, -- 1110
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1110
		) -- 1110
	elseif ctx.childMode then -- 1111
		drawRingArc( -- 1112
			self.padInkDraw, -- 1113
			stick.originX, -- 1114
			stick.originY, -- 1115
			stick.radius * 0.56, -- 1116
			0, -- 1117
			TWO_PI, -- 1118
			0.9, -- 1119
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 1120
			20 -- 1121
		) -- 1121
	end -- 1121
	local knobR = math.max(16, stick.radius * 0.36) -- 1125
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 1126
	if stick.active then -- 1127
		fillRadialGlow( -- 1128
			self.padGlow, -- 1128
			stick.knobX, -- 1128
			stick.knobY, -- 1128
			knobR * 1.45, -- 1128
			knobR * 1.45, -- 1128
			toColor(knobAccent, 48 * stickAlpha), -- 1128
			Color(0, 0, 0, 0), -- 1128
			12 -- 1128
		) -- 1128
	end -- 1128
	fillCirclePoly( -- 1130
		self.padDraw, -- 1131
		stick.knobX, -- 1132
		stick.knobY, -- 1133
		knobR, -- 1134
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 1135
		1.3, -- 1136
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 1137
		22 -- 1138
	) -- 1138
	drawBlossomDot( -- 1140
		self.padInkDraw, -- 1140
		self.padArt, -- 1140
		"touch_stick_dot", -- 1140
		stick.knobX, -- 1140
		stick.knobY, -- 1140
		stick.active and 11 or 7, -- 1140
		knobAccent, -- 1140
		0.85 * stickAlpha, -- 1140
		4 -- 1140
	) -- 1140
	if stick.slowZone then -- 1141
		self.texts:put( -- 1142
			"xs", -- 1142
			"轻步", -- 1142
			stick.originX, -- 1142
			stick.originY + stick.radius + 14, -- 1142
			toColor(PALETTE.emerald), -- 1142
			0.5, -- 1142
			0.5, -- 1142
			"Center", -- 1142
			1, -- 1142
			0.9, -- 1142
			0.08 -- 1142
		) -- 1142
	end -- 1142
end -- 1086
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 1146
	local bottleDrag = router:getBottleDragVisual() -- 1147
	local fireStick = router:getFireStickVisual() -- 1148
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 1149
	local i = 0 -- 1151
	do -- 1151
		i = 0 -- 1152
		while i < #ctx.buttons do -- 1152
			do -- 1152
				local b = ctx.buttons[i + 1] -- 1153
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 1154
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 1155
					bAlpha = bAlpha * 0.25 -- 1156
				end -- 1156
				local col = accentPalette(b.accent) -- 1158
				local core = accentCore(b.accent) -- 1159
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 1160
				if b.shape == "pill" and b.rect ~= nil then -- 1162
					local r = b.rect -- 1163
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 1164
					self.padDraw:drawRoundedRect( -- 1167
						r, -- 1168
						6, -- 1169
						fillCol, -- 1170
						b.active and 1.4 or 1, -- 1171
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 1172
					) -- 1172
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 1174
						local icX = r.x + 22 -- 1175
						local icY = r.y + r.height * 0.5 -- 1176
						drawRingArc( -- 1177
							self.padInkDraw, -- 1177
							icX, -- 1177
							icY, -- 1177
							9, -- 1177
							0, -- 1177
							TWO_PI, -- 1177
							1, -- 1177
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 1177
							16 -- 1177
						) -- 1177
						self.padInkDraw:drawSegment( -- 1178
							Vec2(icX - 2.6, icY - 3.6), -- 1178
							Vec2(icX - 2.6, icY + 3.6), -- 1178
							1.5, -- 1178
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1178
						) -- 1178
						self.padInkDraw:drawSegment( -- 1179
							Vec2(icX + 2.6, icY - 3.6), -- 1179
							Vec2(icX + 2.6, icY + 3.6), -- 1179
							1.5, -- 1179
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1179
						) -- 1179
						self.texts:put( -- 1180
							"xs", -- 1180
							b.label, -- 1180
							r.x + r.width * 0.5 + 10, -- 1180
							icY, -- 1180
							toColor(PALETTE.textBright), -- 1180
							0.5, -- 1180
							0.5, -- 1180
							"Center", -- 1180
							1, -- 1180
							0.94 * bAlpha, -- 1180
							0.08 -- 1180
						) -- 1180
					else -- 1180
						if b.toggle and b.active then -- 1182
							drawDiamond( -- 1183
								self.padInkDraw, -- 1183
								r.x + 11, -- 1183
								r.y + r.height * 0.5, -- 1183
								3.8, -- 1183
								3.8, -- 1183
								toColor(col, 235) -- 1183
							) -- 1183
						end -- 1183
						self.texts:put( -- 1185
							"xs", -- 1186
							b.label, -- 1187
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 1188
							r.y + r.height * 0.5, -- 1189
							toColor(b.active and core or PALETTE.textBright), -- 1190
							0.5, -- 1191
							0.5, -- 1192
							"Center", -- 1193
							0.6, -- 1194
							math.min(1, bAlpha + 0.08), -- 1195
							0.08 -- 1196
						) -- 1196
					end -- 1196
					goto __continue95 -- 1199
				end -- 1199
				if b.active or b.highlighted then -- 1202
					fillRadialGlow( -- 1203
						self.padGlow, -- 1204
						b.x, -- 1205
						b.y, -- 1206
						b.r * 1.38, -- 1207
						b.r * 1.38, -- 1208
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 1209
						Color(col.r, col.g, col.b, 0), -- 1210
						12 -- 1211
					) -- 1211
				end -- 1211
				fillCirclePoly( -- 1215
					self.padDraw, -- 1216
					b.x, -- 1217
					b.y, -- 1218
					b.r, -- 1219
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 1220
					0, -- 1221
					nil, -- 1222
					24 -- 1223
				) -- 1223
				drawRingArc( -- 1225
					self.padInkDraw, -- 1226
					b.x, -- 1227
					b.y, -- 1228
					b.r, -- 1229
					0, -- 1230
					TWO_PI, -- 1231
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 1232
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 1233
					24 -- 1234
				) -- 1234
				drawRingArc( -- 1236
					self.padInkDraw, -- 1237
					b.x, -- 1238
					b.y, -- 1239
					b.r - 4.2, -- 1240
					0, -- 1241
					TWO_PI, -- 1242
					0.7, -- 1243
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 1244
					20 -- 1245
				) -- 1245
				if b.progress > 0.02 then -- 1248
					drawRingArc( -- 1249
						self.padInkDraw, -- 1250
						b.x, -- 1251
						b.y, -- 1252
						b.r + 4, -- 1253
						HALF_PI, -- 1254
						-TWO_PI * math.min(1, b.progress), -- 1255
						2.6, -- 1256
						toColor(PALETTE.amberCore, 240), -- 1257
						28 -- 1258
					) -- 1258
				end -- 1258
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 1262
				self.texts:put( -- 1263
					fontKind, -- 1264
					b.label, -- 1265
					b.x, -- 1266
					hasSub and b.y + 6 or b.y, -- 1267
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 1268
					0.5, -- 1269
					0.5, -- 1270
					"Center", -- 1271
					0.6, -- 1272
					bAlpha, -- 1273
					0.08 -- 1274
				) -- 1274
				if hasSub and b.subLabel ~= nil then -- 1276
					self.texts:put( -- 1277
						"xs", -- 1278
						b.subLabel, -- 1279
						b.x, -- 1280
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 1281
						toColor(b.active and core or PALETTE.textDim), -- 1282
						0.5, -- 1283
						0.5, -- 1284
						"Center", -- 1285
						0.4, -- 1286
						bAlpha * 0.85, -- 1287
						0.06 -- 1288
					) -- 1288
				end -- 1288
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 1292
					self.padInkDraw:drawSegment( -- 1293
						Vec2(fireStick.originX, fireStick.originY), -- 1293
						Vec2(fireStick.knobX, fireStick.knobY), -- 1293
						1.4, -- 1293
						toColor(PALETTE.rouge, 190) -- 1293
					) -- 1293
					fillCirclePoly( -- 1294
						self.padDraw, -- 1294
						fireStick.knobX, -- 1294
						fireStick.knobY, -- 1294
						12, -- 1294
						toColor(PALETTE.rouge, 210), -- 1294
						1.2, -- 1294
						toColor(PALETTE.crimsonCore, 240), -- 1294
						16 -- 1294
					) -- 1294
				end -- 1294
			end -- 1294
			::__continue95:: -- 1294
			i = i + 1 -- 1152
		end -- 1152
	end -- 1152
end -- 1146
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 1299
	local ____opt_15 = self.lastRun -- 1300
	local trial = ____opt_15 and ____opt_15.trial -- 1300
	local i = 0 -- 1301
	do -- 1301
		i = 0 -- 1302
		while i < #ctx.rectZones do -- 1302
			local z = ctx.rectZones[i + 1] -- 1303
			local r = z.rect -- 1304
			local cx = r.x + r.width * 0.5 -- 1305
			local cy = r.y + r.height * 0.5 -- 1306
			if z.id == "pause" or z.id == "retry" then -- 1307
				self.padDraw:drawRoundedRect( -- 1308
					r, -- 1308
					6, -- 1308
					toColor(PALETTE.inkWash, 185 * alpha), -- 1308
					1.2, -- 1308
					toColor(PALETTE.silkLine, 175 * alpha) -- 1308
				) -- 1308
				self.texts:put( -- 1309
					"xs", -- 1309
					z.id == "pause" and "暂停" or "重开", -- 1309
					cx, -- 1309
					cy, -- 1309
					toColor(PALETTE.textBright), -- 1309
					0.5, -- 1309
					0.5, -- 1309
					"Center", -- 1309
					0.8, -- 1309
					0.94, -- 1309
					0.08 -- 1309
				) -- 1309
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 1310
				local idx = __TS__Number(string.sub(z.id, 8)) -- 1311
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 1312
				self.padDraw:drawRoundedRect( -- 1313
					r, -- 1313
					6, -- 1313
					toColor(PALETTE.panelBgDeep, 235), -- 1313
					1.6, -- 1313
					toColor(PALETTE.amber, 225) -- 1313
				) -- 1313
				self.texts:put( -- 1314
					"xs", -- 1314
					(tostring(idx + 1) .. " · ") .. tName, -- 1314
					cx, -- 1314
					cy, -- 1314
					toColor(PALETTE.amberCore), -- 1314
					0.5, -- 1314
					0.5, -- 1314
					"Center", -- 1314
					0.6, -- 1314
					0.98, -- 1314
					0.08 -- 1314
				) -- 1314
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1315
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1316
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1317
				self.padDraw:drawRoundedRect( -- 1318
					r, -- 1318
					6, -- 1318
					toColor(PALETTE.panelBgDeep, 235), -- 1318
					1.5, -- 1318
					toColor(border, 220) -- 1318
				) -- 1318
				self.texts:put( -- 1319
					"sm", -- 1319
					label, -- 1319
					cx, -- 1319
					cy, -- 1319
					toColor(PALETTE.textBright), -- 1319
					0.5, -- 1319
					0.5, -- 1319
					"Center", -- 1319
					1, -- 1319
					0.98, -- 1319
					0.08 -- 1319
				) -- 1319
			end -- 1319
			i = i + 1 -- 1302
		end -- 1302
	end -- 1302
end -- 1299
return ____exports -- 1299
