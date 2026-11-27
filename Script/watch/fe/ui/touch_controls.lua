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
	if accent == "cyan" then -- 75
		return PALETTE.cyan -- 76
	end -- 76
	if accent == "amber" then -- 76
		return PALETTE.amber -- 77
	end -- 77
	if accent == "rouge" then -- 77
		return PALETTE.rouge -- 78
	end -- 78
	if accent == "emerald" then -- 78
		return PALETTE.emerald -- 79
	end -- 79
	return PALETTE.silkLine -- 80
end -- 75
local function accentCore(accent) -- 83
	if accent == "cyan" then -- 83
		return PALETTE.cyanCore -- 84
	end -- 84
	if accent == "amber" then -- 84
		return PALETTE.amberCore -- 85
	end -- 85
	if accent == "rouge" then -- 85
		return PALETTE.crimsonCore -- 86
	end -- 86
	if accent == "emerald" then -- 86
		return PALETTE.emerald -- 87
	end -- 87
	return PALETTE.textBright -- 88
end -- 83
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 91
	if segments == nil then -- 91
		segments = 28 -- 100
	end -- 100
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 100
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
	if borderWidth == nil then -- 117
		borderWidth = 0 -- 123
	end -- 123
	if segments == nil then -- 123
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
	if borderWidth > 0 and borderColor ~= nil then -- 129
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 134
	else -- 134
		draw:drawPolygon(pts, fill) -- 136
	end -- 136
end -- 117
local function isNearLowLedgeForButton(p) -- 140
	if p.childMode then -- 140
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
				if b.broken == true or b.hidden == true then -- 146
					goto __continue25 -- 147
				end -- 147
				local h = b.y1 - b.y0 -- 148
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 148
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
	if arch.h <= 0 then -- 158
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
	if self.lastContext ~= nil then -- 219
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
	local ____opt_8 = params.run -- 269
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
	) or safeL + 126 * sc -- 300
	local stickDefaultY = isPortrait and math.max(safeB + stickMaxR + 24, vp.deckH * 0.44) or safeB + 126 * sc -- 302
	local stickZoneMaxX = isPortrait and ovW * 0.5 or ovW * 0.46 -- 305
	local stickZoneMaxY = isPortrait and math.max(40, vp.deckH - 8) or ovH - 110 -- 306
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 308
	if overlayActive then -- 308
		if isPortrait then -- 308
			local topY = ovH - vp.topBarH * 0.5 -- 314
			local pillH = 26 -- 315
			local rx = ovW - safeR - 10 -- 316
			if gameplayActive and p ~= nil and not p.paused then -- 316
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
				if not inTowerEnd then -- 337
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
			if canToggleFullscreen() then -- 375
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
			if isPlayMode and not modal then -- 392
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
				if isWebPlatform() then -- 412
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
					if canToggleFullscreen() then -- 430
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
	if isPortrait and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 447
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
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 499
		if #params.storyTalentBoxes > 0 then -- 499
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
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 522
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
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 535
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
	if isTrialMode and p ~= nil and overlayActive then -- 562
		if p.paused or trialEnded then -- 562
			local cx = ovW * 0.5 -- 569
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 570
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 571
			local bh = isPortrait and 44 or 50 -- 572
			local step = bh + 14 -- 573
			if p.paused and not trialEnded then -- 573
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
		elseif trialHasOffers and trial ~= nil then -- 578
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
			if not isPortrait then -- 588
				rectZones[#rectZones + 1] = { -- 595
					id = "pause", -- 595
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 595
				} -- 595
			end -- 595
		elseif not isPortrait then -- 595
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
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 599
		local interactMeta = deriveInteractActionMeta( -- 605
			p, -- 605
			prompt or deriveWorldPrompt(p), -- 605
			cartNearby, -- 605
			router.cartGripLatched -- 605
		) -- 605
		if isPortrait then -- 605
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
			if not p.childMode then -- 612
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
				if isPlayMode and p.archive.artifactOwned then -- 672
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
				if canBottleAim then -- 748
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
			if not p.childMode then -- 770
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
				if isPlayMode and p.archive.artifactOwned then -- 822
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
				if canBottleAim then -- 887
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
	local enemyTargets = canShoot and p ~= nil and (isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or (params.cam ~= nil and collectTrialAimTargets(p, params.cam, vp.stageW, vp.stageH) or ({}))) or ({}) -- 909
	local playerScreenX = vp.stageW * 0.5 -- 917
	local playerScreenY = vp.stageH * 0.38 -- 918
	if p ~= nil then -- 918
		if isPlayMode and params.cam ~= nil then -- 918
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 921
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 922
		elseif params.cam ~= nil then -- 922
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 924
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 925
		else -- 925
			playerScreenX = vp.stageW * 0.45 -- 927
			playerScreenY = vp.stageH * 0.36 -- 928
		end -- 928
	end -- 928
	local ctx = { -- 932
		viewport = vp, -- 933
		overlayScale = overlayScale, -- 934
		overlayActive = overlayActive, -- 935
		allowAutoGameplayTouch = allowAutoGameplayTouch, -- 936
		allowMouseOnOverlay = allowMouseOnOverlay, -- 937
		modal = modal, -- 938
		gameplayActive = gameplayActive, -- 939
		cutsceneBlocking = cutsceneBlocking, -- 940
		childMode = p ~= nil and p.childMode, -- 941
		allowDepth = allowDepth, -- 942
		canShoot = canShoot, -- 943
		canBottleAim = canBottleAim, -- 944
		cartNearby = cartNearby, -- 945
		cartGripping = p ~= nil and p.gripping, -- 946
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 947
		coverNear = p ~= nil and p.coverNear, -- 948
		playerRolling = p ~= nil and p.player.rollT > 0, -- 949
		inLowArch = p ~= nil and isInLowArch(p), -- 950
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 951
		playerFacing = p ~= nil and p.player.facing or 1, -- 952
		playerScreenX = playerScreenX, -- 953
		playerScreenY = playerScreenY, -- 954
		enemyTargets = enemyTargets, -- 955
		stickZoneMaxX = stickZoneMaxX, -- 956
		stickZoneMaxY = stickZoneMaxY, -- 957
		stickDefaultX = stickDefaultX, -- 958
		stickDefaultY = stickDefaultY, -- 959
		stickMaxR = stickMaxR, -- 960
		stickFixedOrigin = isPortrait, -- 961
		buttons = buttons, -- 962
		rectZones = rectZones, -- 963
		bottleCancelCenter = bottleCancelCenter -- 964
	} -- 964
	self.lastContext = ctx -- 967
	router:setFrameContext(ctx, params.dt) -- 968
	return ctx -- 969
end -- 242
function TouchControls.prototype.render(self, router) -- 973
	self.deckDraw:clear() -- 974
	self.padDraw:clear() -- 975
	self.padInkDraw:clear() -- 976
	self.padGlow:clear() -- 977
	self.padArt:beginFrame() -- 978
	self.texts:beginFrame() -- 979
	local ctx = self.lastContext -- 981
	if ctx == nil or not ctx.overlayActive and not ctx.viewport.isPortrait then -- 981
		self.padArt:endFrame() -- 983
		self.texts:endFrame() -- 984
		return -- 985
	end -- 985
	local vp = ctx.viewport -- 988
	local sc = math.max(0.25, ctx.overlayScale) -- 989
	self.overlayRoot.scaleX = sc -- 990
	self.overlayRoot.scaleY = sc -- 991
	local ovW = vp.fullW / sc -- 993
	local ovH = vp.fullH / sc -- 994
	local baseAlpha = router.settings.touchOpacity -- 995
	if vp.isPortrait then -- 995
		self:drawPortraitFrame(ctx, ovW, ovH) -- 999
	end -- 999
	if not ctx.overlayActive then -- 999
		self.padArt:endFrame() -- 1003
		self.texts:endFrame() -- 1004
		return -- 1005
	end -- 1005
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 1005
		local rx = ovW * 0.5 -- 1010
		local ry = vp.isPortrait and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 1011
		drawSilkVeil( -- 1012
			self.padDraw, -- 1012
			self.padArt, -- 1012
			"touch_restart_veil", -- 1012
			rx, -- 1012
			ry, -- 1012
			230, -- 1012
			36, -- 1012
			PALETTE.inkWash, -- 1012
			0.78 * baseAlpha, -- 1012
			1 -- 1012
		) -- 1012
		drawHairline( -- 1013
			self.padInkDraw, -- 1013
			self.padArt, -- 1013
			"touch_restart_line", -- 1013
			rx, -- 1013
			ry + 16, -- 1013
			180, -- 1013
			PALETTE.amber, -- 1013
			0.52 * baseAlpha, -- 1013
			true, -- 1013
			2 -- 1013
		) -- 1013
		self.texts:put( -- 1014
			"xs", -- 1014
			"轻触屏幕再次启程", -- 1014
			rx, -- 1014
			ry, -- 1014
			toColor(PALETTE.amberCore), -- 1014
			0.5, -- 1014
			0.5, -- 1014
			"Center", -- 1014
			1.6, -- 1014
			0.94, -- 1014
			0.08 -- 1014
		) -- 1014
	end -- 1014
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 1014
		self:drawTrialZones(ctx, baseAlpha) -- 1019
	end -- 1019
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 1019
		self:drawStick(router, ctx, baseAlpha) -- 1024
	end -- 1024
	self:drawButtons(router, ctx, baseAlpha) -- 1028
	local bottleDrag = router:getBottleDragVisual() -- 1031
	if bottleDrag.active then -- 1031
		local cx = bottleDrag.cancelX -- 1033
		local cy = bottleDrag.cancelY -- 1034
		local cr = bottleDrag.cancelR -- 1035
		local hot = bottleDrag.cancelHover -- 1036
		fillCirclePoly( -- 1037
			self.padDraw, -- 1038
			cx, -- 1039
			cy, -- 1040
			cr, -- 1041
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 1042
			0, -- 1043
			nil, -- 1044
			22 -- 1045
		) -- 1045
		drawRingArc( -- 1047
			self.padInkDraw, -- 1047
			cx, -- 1047
			cy, -- 1047
			cr, -- 1047
			0, -- 1047
			TWO_PI, -- 1047
			hot and 2.2 or 1.3, -- 1047
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 1047
			22 -- 1047
		) -- 1047
		self.texts:put( -- 1048
			"xs", -- 1048
			hot and "松手取消" or "拖此取消", -- 1048
			cx, -- 1048
			cy, -- 1048
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 1048
			0.5, -- 1048
			0.5, -- 1048
			"Center", -- 1048
			0.8, -- 1048
			0.96, -- 1048
			0.08 -- 1048
		) -- 1048
	end -- 1048
	self.padArt:endFrame() -- 1051
	self.texts:endFrame() -- 1052
end -- 973
function TouchControls.prototype.drawPortraitFrame(self, ctx, w, h) -- 1055
	local vp = ctx.viewport -- 1056
	local topY = vp.stageY + vp.stageH -- 1057
	if topY < h then -- 1057
		self.deckDraw:drawRect( -- 1060
			Rect(0, topY, w, h - topY), -- 1060
			toColor(PALETTE.inkVoid, 252) -- 1060
		) -- 1060
		self.deckDraw:drawSegment( -- 1061
			Vec2(0, topY), -- 1061
			Vec2(w, topY), -- 1061
			1, -- 1061
			toColor(PALETTE.silkDim, 140) -- 1061
		) -- 1061
		local labelY = topY + (h - topY) * 0.5 -- 1062
		self.texts:put( -- 1063
			"xs", -- 1063
			"向西守望 · 掌机竖屏", -- 1063
			vp.safe.left + 12, -- 1063
			labelY, -- 1063
			toColor(PALETTE.amberCore), -- 1063
			0, -- 1063
			0.5, -- 1063
			"Left", -- 1063
			0.8, -- 1063
			0.88, -- 1063
			0.08 -- 1063
		) -- 1063
	end -- 1063
	if vp.stageX > 0 then -- 1063
		self.deckDraw:drawRect( -- 1067
			Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 1067
			toColor(PALETTE.inkVoid, 255) -- 1067
		) -- 1067
		self.deckDraw:drawRect( -- 1068
			Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 1068
			toColor(PALETTE.inkVoid, 255) -- 1068
		) -- 1068
	end -- 1068
	if vp.deckH > 0 then -- 1068
		fillVGradRect( -- 1072
			self.deckDraw, -- 1072
			0, -- 1072
			0, -- 1072
			w, -- 1072
			vp.deckH, -- 1072
			toColor(PALETTE.voidDark, 255), -- 1072
			toColor(PALETTE.inkWash, 255) -- 1072
		) -- 1072
		self.deckDraw:drawSegment( -- 1073
			Vec2(0, vp.deckH), -- 1073
			Vec2(w, vp.deckH), -- 1073
			1.2, -- 1073
			toColor(PALETTE.silkLine, 165) -- 1073
		) -- 1073
		self.deckDraw:drawSegment( -- 1074
			Vec2(18, vp.deckH - 4), -- 1074
			Vec2(w - 18, vp.deckH - 4), -- 1074
			0.6, -- 1074
			toColor(PALETTE.silkDim, 85) -- 1074
		) -- 1074
		drawDiamond( -- 1075
			self.padInkDraw, -- 1075
			w * 0.5, -- 1075
			vp.deckH, -- 1075
			5, -- 1075
			5, -- 1075
			toColor(PALETTE.rouge, 220), -- 1075
			0.9, -- 1075
			toColor(PALETTE.silkLine, 180) -- 1075
		) -- 1075
		local footY = math.max(vp.safe.bottom + 14, 16) -- 1077
		local p = self.lastPlay -- 1078
		local inOverlayModal = p ~= nil and (p.reloadOpen or p.craftBench.active) -- 1079
		local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or p ~= nil and p.paused) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 1080
		self.texts:put( -- 1087
			"xs", -- 1087
			hint, -- 1087
			w * 0.5, -- 1087
			footY, -- 1087
			toColor(PALETTE.textDim), -- 1087
			0.5, -- 1087
			0.5, -- 1087
			"Center", -- 1087
			0.8, -- 1087
			0.78, -- 1087
			0.06 -- 1087
		) -- 1087
	end -- 1087
end -- 1055
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 1091
	local stick = router:getStickVisual() -- 1092
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 1093
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 1096
	fillCirclePoly( -- 1098
		self.padDraw, -- 1099
		stick.originX, -- 1100
		stick.originY, -- 1101
		stick.radius, -- 1102
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 1103
		0, -- 1104
		nil, -- 1105
		28 -- 1106
	) -- 1106
	drawRingArc( -- 1108
		self.padInkDraw, -- 1108
		stick.originX, -- 1108
		stick.originY, -- 1108
		stick.radius, -- 1108
		0, -- 1108
		TWO_PI, -- 1108
		stick.active and 1.5 or 1, -- 1108
		toColor(ringCol, 168 * stickAlpha), -- 1108
		28 -- 1108
	) -- 1108
	if stick.allowDepth then -- 1108
		local dOff = stick.radius - 10 -- 1111
		self.padInkDraw:drawDot( -- 1112
			Vec2(stick.originX, stick.originY + dOff), -- 1112
			2.1, -- 1112
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1112
		) -- 1112
		self.padInkDraw:drawDot( -- 1113
			Vec2(stick.originX, stick.originY - dOff), -- 1113
			2.1, -- 1113
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1113
		) -- 1113
		self.padInkDraw:drawDot( -- 1114
			Vec2(stick.originX - dOff, stick.originY), -- 1114
			2.1, -- 1114
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1114
		) -- 1114
		self.padInkDraw:drawDot( -- 1115
			Vec2(stick.originX + dOff, stick.originY), -- 1115
			2.1, -- 1115
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1115
		) -- 1115
	elseif ctx.childMode then -- 1115
		drawRingArc( -- 1117
			self.padInkDraw, -- 1118
			stick.originX, -- 1119
			stick.originY, -- 1120
			stick.radius * 0.56, -- 1121
			0, -- 1122
			TWO_PI, -- 1123
			0.9, -- 1124
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 1125
			20 -- 1126
		) -- 1126
	end -- 1126
	local knobR = math.max(16, stick.radius * 0.36) -- 1130
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 1131
	if stick.active then -- 1131
		fillRadialGlow( -- 1133
			self.padGlow, -- 1133
			stick.knobX, -- 1133
			stick.knobY, -- 1133
			knobR * 1.45, -- 1133
			knobR * 1.45, -- 1133
			toColor(knobAccent, 48 * stickAlpha), -- 1133
			Color(0, 0, 0, 0), -- 1133
			12 -- 1133
		) -- 1133
	end -- 1133
	fillCirclePoly( -- 1135
		self.padDraw, -- 1136
		stick.knobX, -- 1137
		stick.knobY, -- 1138
		knobR, -- 1139
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 1140
		1.3, -- 1141
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 1142
		22 -- 1143
	) -- 1143
	drawBlossomDot( -- 1145
		self.padInkDraw, -- 1145
		self.padArt, -- 1145
		"touch_stick_dot", -- 1145
		stick.knobX, -- 1145
		stick.knobY, -- 1145
		stick.active and 11 or 7, -- 1145
		knobAccent, -- 1145
		0.85 * stickAlpha, -- 1145
		4 -- 1145
	) -- 1145
	if stick.slowZone then -- 1145
		self.texts:put( -- 1147
			"xs", -- 1147
			"轻步", -- 1147
			stick.originX, -- 1147
			stick.originY + stick.radius + 14, -- 1147
			toColor(PALETTE.emerald), -- 1147
			0.5, -- 1147
			0.5, -- 1147
			"Center", -- 1147
			1, -- 1147
			0.9, -- 1147
			0.08 -- 1147
		) -- 1147
	end -- 1147
end -- 1091
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 1151
	local bottleDrag = router:getBottleDragVisual() -- 1152
	local fireStick = router:getFireStickVisual() -- 1153
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 1154
	local i = 0 -- 1156
	do -- 1156
		i = 0 -- 1157
		while i < #ctx.buttons do -- 1157
			do -- 1157
				local b = ctx.buttons[i + 1] -- 1158
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 1159
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 1159
					bAlpha = bAlpha * 0.25 -- 1161
				end -- 1161
				local col = accentPalette(b.accent) -- 1163
				local core = accentCore(b.accent) -- 1164
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 1165
				if b.shape == "pill" and b.rect ~= nil then -- 1165
					local r = b.rect -- 1168
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 1169
					self.padDraw:drawRoundedRect( -- 1172
						r, -- 1173
						6, -- 1174
						fillCol, -- 1175
						b.active and 1.4 or 1, -- 1176
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 1177
					) -- 1177
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 1177
						local icX = r.x + 22 -- 1180
						local icY = r.y + r.height * 0.5 -- 1181
						drawRingArc( -- 1182
							self.padInkDraw, -- 1182
							icX, -- 1182
							icY, -- 1182
							9, -- 1182
							0, -- 1182
							TWO_PI, -- 1182
							1, -- 1182
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 1182
							16 -- 1182
						) -- 1182
						self.padInkDraw:drawSegment( -- 1183
							Vec2(icX - 2.6, icY - 3.6), -- 1183
							Vec2(icX - 2.6, icY + 3.6), -- 1183
							1.5, -- 1183
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1183
						) -- 1183
						self.padInkDraw:drawSegment( -- 1184
							Vec2(icX + 2.6, icY - 3.6), -- 1184
							Vec2(icX + 2.6, icY + 3.6), -- 1184
							1.5, -- 1184
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1184
						) -- 1184
						self.texts:put( -- 1185
							"xs", -- 1185
							b.label, -- 1185
							r.x + r.width * 0.5 + 10, -- 1185
							icY, -- 1185
							toColor(PALETTE.textBright), -- 1185
							0.5, -- 1185
							0.5, -- 1185
							"Center", -- 1185
							1, -- 1185
							0.94 * bAlpha, -- 1185
							0.08 -- 1185
						) -- 1185
					else -- 1185
						if b.toggle and b.active then -- 1185
							drawDiamond( -- 1188
								self.padInkDraw, -- 1188
								r.x + 11, -- 1188
								r.y + r.height * 0.5, -- 1188
								3.8, -- 1188
								3.8, -- 1188
								toColor(col, 235) -- 1188
							) -- 1188
						end -- 1188
						self.texts:put( -- 1190
							"xs", -- 1191
							b.label, -- 1192
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 1193
							r.y + r.height * 0.5, -- 1194
							toColor(b.active and core or PALETTE.textBright), -- 1195
							0.5, -- 1196
							0.5, -- 1197
							"Center", -- 1198
							0.6, -- 1199
							math.min(1, bAlpha + 0.08), -- 1200
							0.08 -- 1201
						) -- 1201
					end -- 1201
					goto __continue96 -- 1204
				end -- 1204
				if b.active or b.highlighted then -- 1204
					fillRadialGlow( -- 1208
						self.padGlow, -- 1209
						b.x, -- 1210
						b.y, -- 1211
						b.r * 1.38, -- 1212
						b.r * 1.38, -- 1213
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 1214
						Color(col.r, col.g, col.b, 0), -- 1215
						12 -- 1216
					) -- 1216
				end -- 1216
				fillCirclePoly( -- 1220
					self.padDraw, -- 1221
					b.x, -- 1222
					b.y, -- 1223
					b.r, -- 1224
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 1225
					0, -- 1226
					nil, -- 1227
					24 -- 1228
				) -- 1228
				drawRingArc( -- 1230
					self.padInkDraw, -- 1231
					b.x, -- 1232
					b.y, -- 1233
					b.r, -- 1234
					0, -- 1235
					TWO_PI, -- 1236
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 1237
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 1238
					24 -- 1239
				) -- 1239
				drawRingArc( -- 1241
					self.padInkDraw, -- 1242
					b.x, -- 1243
					b.y, -- 1244
					b.r - 4.2, -- 1245
					0, -- 1246
					TWO_PI, -- 1247
					0.7, -- 1248
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 1249
					20 -- 1250
				) -- 1250
				if b.progress > 0.02 then -- 1250
					drawRingArc( -- 1254
						self.padInkDraw, -- 1255
						b.x, -- 1256
						b.y, -- 1257
						b.r + 4, -- 1258
						HALF_PI, -- 1259
						-TWO_PI * math.min(1, b.progress), -- 1260
						2.6, -- 1261
						toColor(PALETTE.amberCore, 240), -- 1262
						28 -- 1263
					) -- 1263
				end -- 1263
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 1267
				self.texts:put( -- 1268
					fontKind, -- 1269
					b.label, -- 1270
					b.x, -- 1271
					hasSub and b.y + 6 or b.y, -- 1272
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 1273
					0.5, -- 1274
					0.5, -- 1275
					"Center", -- 1276
					0.6, -- 1277
					bAlpha, -- 1278
					0.08 -- 1279
				) -- 1279
				if hasSub and b.subLabel ~= nil then -- 1279
					self.texts:put( -- 1282
						"xs", -- 1283
						b.subLabel, -- 1284
						b.x, -- 1285
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 1286
						toColor(b.active and core or PALETTE.textDim), -- 1287
						0.5, -- 1288
						0.5, -- 1289
						"Center", -- 1290
						0.4, -- 1291
						bAlpha * 0.85, -- 1292
						0.06 -- 1293
					) -- 1293
				end -- 1293
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 1293
					self.padInkDraw:drawSegment( -- 1298
						Vec2(fireStick.originX, fireStick.originY), -- 1298
						Vec2(fireStick.knobX, fireStick.knobY), -- 1298
						1.4, -- 1298
						toColor(PALETTE.rouge, 190) -- 1298
					) -- 1298
					fillCirclePoly( -- 1299
						self.padDraw, -- 1299
						fireStick.knobX, -- 1299
						fireStick.knobY, -- 1299
						12, -- 1299
						toColor(PALETTE.rouge, 210), -- 1299
						1.2, -- 1299
						toColor(PALETTE.crimsonCore, 240), -- 1299
						16 -- 1299
					) -- 1299
				end -- 1299
			end -- 1299
			::__continue96:: -- 1299
			i = i + 1 -- 1157
		end -- 1157
	end -- 1157
end -- 1151
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 1304
	local ____opt_15 = self.lastRun -- 1304
	local trial = ____opt_15 and ____opt_15.trial -- 1305
	local i = 0 -- 1306
	do -- 1306
		i = 0 -- 1307
		while i < #ctx.rectZones do -- 1307
			local z = ctx.rectZones[i + 1] -- 1308
			local r = z.rect -- 1309
			local cx = r.x + r.width * 0.5 -- 1310
			local cy = r.y + r.height * 0.5 -- 1311
			if z.id == "pause" or z.id == "retry" then -- 1311
				self.padDraw:drawRoundedRect( -- 1313
					r, -- 1313
					6, -- 1313
					toColor(PALETTE.inkWash, 185 * alpha), -- 1313
					1.2, -- 1313
					toColor(PALETTE.silkLine, 175 * alpha) -- 1313
				) -- 1313
				self.texts:put( -- 1314
					"xs", -- 1314
					z.id == "pause" and "暂停" or "重开", -- 1314
					cx, -- 1314
					cy, -- 1314
					toColor(PALETTE.textBright), -- 1314
					0.5, -- 1314
					0.5, -- 1314
					"Center", -- 1314
					0.8, -- 1314
					0.94, -- 1314
					0.08 -- 1314
				) -- 1314
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 1314
				local idx = __TS__Number(string.sub(z.id, 8)) -- 1316
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 1317
				self.padDraw:drawRoundedRect( -- 1318
					r, -- 1318
					6, -- 1318
					toColor(PALETTE.panelBgDeep, 235), -- 1318
					1.6, -- 1318
					toColor(PALETTE.amber, 225) -- 1318
				) -- 1318
				self.texts:put( -- 1319
					"xs", -- 1319
					(tostring(idx + 1) .. " · ") .. tName, -- 1319
					cx, -- 1319
					cy, -- 1319
					toColor(PALETTE.amberCore), -- 1319
					0.5, -- 1319
					0.5, -- 1319
					"Center", -- 1319
					0.6, -- 1319
					0.98, -- 1319
					0.08 -- 1319
				) -- 1319
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1319
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1321
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1322
				self.padDraw:drawRoundedRect( -- 1323
					r, -- 1323
					6, -- 1323
					toColor(PALETTE.panelBgDeep, 235), -- 1323
					1.5, -- 1323
					toColor(border, 220) -- 1323
				) -- 1323
				self.texts:put( -- 1324
					"sm", -- 1324
					label, -- 1324
					cx, -- 1324
					cy, -- 1324
					toColor(PALETTE.textBright), -- 1324
					0.5, -- 1324
					0.5, -- 1324
					"Center", -- 1324
					1, -- 1324
					0.98, -- 1324
					0.08 -- 1324
				) -- 1324
			end -- 1324
			i = i + 1 -- 1307
		end -- 1307
	end -- 1307
end -- 1304
return ____exports -- 1304