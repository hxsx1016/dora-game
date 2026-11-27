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
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 38
local drawTalentGlyph = ____talent_catalog.drawTalentGlyph -- 38
local resolveTalentVisual = ____talent_catalog.resolveTalentVisual -- 38
local ____theme = require("Script.watch.fe.theme") -- 39
local PALETTE = ____theme.PALETTE -- 40
local drawBlossomDot = ____theme.drawBlossomDot -- 42
local drawDiamond = ____theme.drawDiamond -- 43
local drawHairline = ____theme.drawHairline -- 44
local drawSilkVeil = ____theme.drawSilkVeil -- 45
local fillRadialGlow = ____theme.fillRadialGlow -- 46
local fillVGradRect = ____theme.fillVGradRect -- 47
local toColor = ____theme.toColor -- 48
local visualTextWidth = ____theme.visualTextWidth -- 49
local TWO_PI = math.pi * 2 -- 52
local HALF_PI = math.pi * 0.5 -- 53
local STICK_BASE_R_LANDSCAPE = 64 -- 54
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
function TouchControls.prototype.____constructor(self, parent) -- 181
	self.lastMode = 1 -- 174
	self.lastScreen = "title" -- 175
	self.portraitTalentCards = {} -- 178
	self.time = 0 -- 179
	self.overlayRoot = Node() -- 182
	self.overlayRoot.order = 60 -- 183
	self.overlayRoot:addTo(parent) -- 184
	self.deckDraw = DrawNode() -- 186
	self.deckDraw.order = 0 -- 187
	self.deckDraw:addTo(self.overlayRoot) -- 188
	self.padDraw = DrawNode() -- 190
	self.padDraw.order = 2 -- 191
	self.padDraw:addTo(self.overlayRoot) -- 192
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 194
	self.padInkDraw = DrawNode() -- 196
	self.padInkDraw.order = 5 -- 197
	self.padInkDraw:addTo(self.overlayRoot) -- 198
	local additive = BlendFunc("SrcAlpha", "One") -- 200
	self.padGlow = DrawNode() -- 201
	self.padGlow.order = 7 -- 202
	self.padGlow.blendFunc = additive -- 203
	self.padGlow:addTo(self.overlayRoot) -- 204
	self.texts = __TS__New(TextPool, self.overlayRoot, 10) -- 206
end -- 181
function TouchControls.prototype.getLayoutSummary(self, router) -- 210
	local buttonIds = {} -- 220
	local zoneIds = {} -- 221
	if self.lastContext ~= nil then -- 222
		local i = 0 -- 223
		do -- 223
			i = 0 -- 224
			while i < #self.lastContext.buttons do -- 224
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 225
				i = i + 1 -- 224
			end -- 224
		end -- 224
		do -- 224
			i = 0 -- 227
			while i < #self.lastContext.rectZones do -- 227
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 228
				i = i + 1 -- 227
			end -- 227
		end -- 227
	end -- 227
	local ____buttonIds_6 = buttonIds -- 232
	local ____zoneIds_7 = zoneIds -- 233
	local ____temp_0 -- 234
	if self.lastContext ~= nil then -- 234
		____temp_0 = self.lastContext.viewport.isPortrait -- 234
	else -- 234
		____temp_0 = false -- 234
	end -- 234
	local ____temp_1 -- 235
	if self.lastContext ~= nil then -- 235
		____temp_1 = self.lastContext.overlayActive -- 235
	else -- 235
		____temp_1 = false -- 235
	end -- 235
	local ____temp_2 -- 236
	if router ~= nil then -- 236
		____temp_2 = router.crouchToggled -- 236
	else -- 236
		____temp_2 = false -- 236
	end -- 236
	local ____temp_3 -- 237
	if router ~= nil then -- 237
		____temp_3 = router.slowToggled -- 237
	else -- 237
		____temp_3 = false -- 237
	end -- 237
	local ____temp_4 -- 238
	if router ~= nil then -- 238
		____temp_4 = router.coverToggled -- 238
	else -- 238
		____temp_4 = false -- 238
	end -- 238
	local ____temp_5 -- 239
	if router ~= nil then -- 239
		____temp_5 = router.cartGripLatched -- 239
	else -- 239
		____temp_5 = false -- 239
	end -- 239
	return { -- 231
		buttonIds = ____buttonIds_6, -- 232
		zoneIds = ____zoneIds_7, -- 233
		isPortrait = ____temp_0, -- 234
		overlayActive = ____temp_1, -- 235
		crouchToggled = ____temp_2, -- 236
		slowToggled = ____temp_3, -- 237
		coverToggled = ____temp_4, -- 238
		cartGripLatch = ____temp_5 -- 239
	} -- 239
end -- 210
function TouchControls.prototype.syncContext(self, params) -- 244
	self.time = self.time + math.min( -- 245
		0.05, -- 245
		math.max(0, params.dt) -- 245
	) -- 245
	self.lastMode = params.mode -- 246
	self.lastScreen = params.screen -- 247
	self.lastPlay = params.play -- 248
	self.lastRun = params.run -- 249
	local vp = params.viewport -- 251
	local p = params.play -- 252
	local router = params.router -- 253
	local input = params.input -- 254
	local isPortrait = vp.isPortrait -- 255
	local overlayScale = isPortrait and 1 or vp.uiScale -- 256
	local ovW = vp.fullW / math.max(0.25, overlayScale) -- 257
	local ovH = vp.fullH / math.max(0.25, overlayScale) -- 258
	local safeL = vp.safe.left / math.max(0.25, overlayScale) -- 259
	local safeR = vp.safe.right / math.max(0.25, overlayScale) -- 260
	local safeT = vp.safe.top / math.max(0.25, overlayScale) -- 261
	local safeB = vp.safe.bottom / math.max(0.25, overlayScale) -- 262
	local overlayActive = input:shouldShowTouchControls() -- 264
	local allowMouseOnOverlay = isPortrait or input.settings.modePref == "touch" -- 265
	local allowAutoGameplayTouch = input.settings.modePref == "auto" or input.settings.modePref == "touch" -- 266
	local sc = router.settings.touchScale -- 267
	local isPlayMode = params.mode == 1 and params.screen == "play" and p ~= nil -- 269
	local isTrialMode = params.mode == 2 and p ~= nil -- 270
	local gameplayActive = isPlayMode or isTrialMode -- 271
	local ____opt_8 = params.run -- 273
	local trial = ____opt_8 and ____opt_8.trial -- 273
	local ____temp_13 = isTrialMode and trial ~= nil -- 274
	if ____temp_13 then -- 274
		local ____trial_lost_12 = trial.lost -- 274
		if not ____trial_lost_12 then -- 274
			local ____opt_10 = params.run -- 274
			____trial_lost_12 = (____opt_10 and ____opt_10.finished) == true -- 274
		end -- 274
		____temp_13 = ____trial_lost_12 -- 274
	end -- 274
	local trialEnded = ____temp_13 -- 274
	local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 275
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) -- 277
	local ____temp_14 -- 279
	if isPlayMode and p ~= nil then -- 279
		____temp_14 = isCutsceneBlockingPlay(p) -- 280
	else -- 280
		____temp_14 = isTrialMode and p ~= nil and (p.paused or trialEnded or trialHasOffers) -- 281
	end -- 281
	local cutsceneBlocking = ____temp_14 -- 279
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 283
	local cart = p ~= nil and p.room.cart or nil -- 285
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 286
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 288
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 289
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 290
	local buttons = {} -- 293
	local rectZones = {} -- 294
	local unitPortrait = clamp( -- 297
		math.min( -- 297
			vp.fullW / 420, -- 297
			math.max(180, vp.deckH) / 340 -- 297
		), -- 297
		0.72, -- 297
		1.15 -- 297
	) -- 297
	local stickMaxR = isPortrait and math.floor(52 * unitPortrait * sc + 0.5) or STICK_BASE_R_LANDSCAPE * sc -- 298
	local stickDefaultX = isPortrait and safeL + math.max( -- 301
		stickMaxR + 26, -- 302
		math.floor(ovW * 0.24 + 0.5) -- 302
	) or safeL + 126 * sc -- 303
	local stickDefaultY = isPortrait and math.max(safeB + stickMaxR + 24, vp.deckH * 0.44) or safeB + 126 * sc -- 304
	local stickZoneMaxX = isPortrait and ovW * 0.5 or ovW * 0.46 -- 307
	local stickZoneMaxY = isPortrait and math.max(40, vp.deckH - 8) or ovH - 110 -- 308
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 310
	if overlayActive then -- 313
		if isPortrait then -- 314
			local topY = ovH - vp.topBarH * 0.5 -- 316
			local pillH = 26 -- 317
			local rx = ovW - safeR - 10 -- 318
			if gameplayActive and p ~= nil and not p.paused then -- 320
				local pw = 58 -- 321
				rx = rx - pw -- 322
				buttons[#buttons + 1] = { -- 323
					id = "pause", -- 324
					x = rx + pw * 0.5, -- 325
					y = topY, -- 326
					r = 22, -- 327
					shape = "pill", -- 328
					rect = Rect(rx, topY - pillH * 0.5, pw, pillH), -- 329
					label = "暂歇", -- 330
					accent = "silk", -- 331
					active = false, -- 332
					highlighted = false, -- 333
					progress = 0, -- 334
					dimmed = false -- 335
				} -- 335
				rx = rx - 8 -- 337
				local inTowerEnd = p.room.key == "tower" and p.phase ~= "tower-wait" -- 339
				if not inTowerEnd then -- 340
					local rw = 58 -- 341
					rx = rx - rw -- 342
					buttons[#buttons + 1] = { -- 343
						id = "retry", -- 344
						x = rx + rw * 0.5, -- 345
						y = topY, -- 346
						r = 22, -- 347
						shape = "pill", -- 348
						rect = Rect(rx, topY - pillH * 0.5, rw, pillH), -- 349
						label = "重试", -- 350
						accent = "amber", -- 351
						active = false, -- 352
						highlighted = false, -- 353
						progress = 0, -- 354
						dimmed = false -- 355
					} -- 355
					rx = rx - 8 -- 357
				end -- 357
			end -- 357
			local mw = 54 -- 361
			rx = rx - mw -- 362
			buttons[#buttons + 1] = { -- 363
				id = "mute", -- 364
				x = rx + mw * 0.5, -- 365
				y = topY, -- 366
				r = 20, -- 367
				shape = "pill", -- 368
				rect = Rect(rx, topY - pillH * 0.5, mw, pillH), -- 369
				label = params.isMuted and "静音" or "有声", -- 370
				accent = params.isMuted and "rouge" or "cyan", -- 371
				active = params.isMuted, -- 372
				highlighted = false, -- 373
				progress = 0, -- 374
				dimmed = false -- 375
			} -- 375
			rx = rx - 8 -- 377
			if canToggleFullscreen() then -- 379
				local fw = 54 -- 380
				rx = rx - fw -- 381
				buttons[#buttons + 1] = { -- 382
					id = "fullscreen", -- 383
					x = rx + fw * 0.5, -- 384
					y = topY, -- 385
					r = 20, -- 386
					shape = "pill", -- 387
					rect = Rect(rx, topY - pillH * 0.5, fw, pillH), -- 388
					label = params.isFullscreen and "窗口" or "全屏", -- 389
					accent = "silk", -- 390
					active = params.isFullscreen, -- 391
					highlighted = false, -- 392
					progress = 0, -- 393
					dimmed = false -- 394
				} -- 394
			end -- 394
		else -- 394
			if isPlayMode and not modal then -- 399
				local px = ovW - safeR - 112 -- 400
				local py = ovH - safeT - 66 -- 401
				buttons[#buttons + 1] = { -- 402
					id = "pause", -- 403
					x = px + 46, -- 404
					y = py + 21, -- 405
					r = 28, -- 406
					shape = "pill", -- 407
					rect = Rect(px, py, 94, 42), -- 408
					label = "暂歇", -- 409
					accent = "silk", -- 410
					active = false, -- 411
					highlighted = false, -- 412
					progress = 0, -- 413
					dimmed = false -- 414
				} -- 414
				if isWebPlatform() then -- 417
					local mw = 58 -- 418
					local mx = px - mw - 10 -- 419
					buttons[#buttons + 1] = { -- 420
						id = "mute", -- 421
						x = mx + mw * 0.5, -- 422
						y = py + 21, -- 423
						r = 22, -- 424
						shape = "pill", -- 425
						rect = Rect(mx, py + 4, mw, 34), -- 426
						label = params.isMuted and "静音" or "有声", -- 427
						accent = params.isMuted and "rouge" or "cyan", -- 428
						active = params.isMuted, -- 429
						highlighted = false, -- 430
						progress = 0, -- 431
						dimmed = false -- 432
					} -- 432
					if canToggleFullscreen() then -- 434
						local fw = 58 -- 435
						local fx = mx - fw - 8 -- 436
						buttons[#buttons + 1] = { -- 437
							id = "fullscreen", -- 438
							x = fx + fw * 0.5, -- 439
							y = py + 21, -- 440
							r = 22, -- 441
							shape = "pill", -- 442
							rect = Rect(fx, py + 4, fw, 34), -- 443
							label = params.isFullscreen and "窗口" or "全屏", -- 444
							accent = "silk", -- 445
							active = params.isFullscreen, -- 446
							highlighted = false, -- 447
							progress = 0, -- 448
							dimmed = false -- 449
						} -- 449
					end -- 449
				end -- 449
			end -- 449
		end -- 449
	end -- 449
	if isPortrait and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 458
		local cy = math.max(safeB + 84, vp.deckH * 0.5) -- 460
		local leftX = safeL + math.max(82, ovW * 0.25) -- 461
		local step = math.min( -- 462
			54, -- 462
			math.max(42, ovW * 0.12) -- 462
		) -- 462
		local nr = math.min( -- 463
			26, -- 463
			math.max(21, ovW * 0.06) -- 463
		) -- 463
		buttons[#buttons + 1] = { -- 464
			id = "nav_up", -- 464
			x = leftX, -- 464
			y = cy + step, -- 464
			r = nr, -- 464
			label = "上", -- 464
			accent = "silk", -- 464
			active = false, -- 464
			highlighted = false, -- 464
			progress = 0, -- 464
			dimmed = false -- 464
		} -- 464
		buttons[#buttons + 1] = { -- 465
			id = "nav_down", -- 465
			x = leftX, -- 465
			y = cy - step, -- 465
			r = nr, -- 465
			label = "下", -- 465
			accent = "silk", -- 465
			active = false, -- 465
			highlighted = false, -- 465
			progress = 0, -- 465
			dimmed = false -- 465
		} -- 465
		buttons[#buttons + 1] = { -- 466
			id = "nav_left", -- 466
			x = leftX - step, -- 466
			y = cy, -- 466
			r = nr, -- 466
			label = "左", -- 466
			accent = "silk", -- 466
			active = false, -- 466
			highlighted = false, -- 466
			progress = 0, -- 466
			dimmed = false -- 466
		} -- 466
		buttons[#buttons + 1] = { -- 467
			id = "nav_right", -- 467
			x = leftX + step, -- 467
			y = cy, -- 467
			r = nr, -- 467
			label = "右", -- 467
			accent = "silk", -- 467
			active = false, -- 467
			highlighted = false, -- 467
			progress = 0, -- 467
			dimmed = false -- 467
		} -- 467
		local rightX = ovW - safeR - math.max(76, ovW * 0.23) -- 469
		buttons[#buttons + 1] = { -- 470
			id = "nav_confirm", -- 471
			x = rightX, -- 472
			y = cy + 28, -- 473
			r = 28, -- 474
			shape = "pill", -- 475
			rect = Rect(rightX - 48, cy + 6, 96, 44), -- 476
			label = "确认", -- 477
			accent = "rouge", -- 478
			active = false, -- 479
			highlighted = true, -- 480
			progress = 0, -- 481
			dimmed = false -- 482
		} -- 482
		buttons[#buttons + 1] = { -- 484
			id = "nav_back", -- 485
			x = rightX, -- 486
			y = cy - 30, -- 487
			r = 26, -- 488
			shape = "pill", -- 489
			rect = Rect(rightX - 48, cy - 50, 96, 40), -- 490
			label = "返回", -- 491
			accent = "silk", -- 492
			active = false, -- 493
			highlighted = false, -- 494
			progress = 0, -- 495
			dimmed = false -- 496
		} -- 496
	end -- 496
	self.portraitTalentCards = {} -- 501
	local prompt -- 502
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 503
		if #params.storyTalentBoxes > 0 then -- 505
			local ti = 0 -- 506
			do -- 506
				ti = 0 -- 507
				while ti < #params.storyTalentBoxes do -- 507
					local b = params.storyTalentBoxes[ti + 1] -- 508
					local vx = vp.stageX + b.x * vp.uiScale -- 509
					local vy = vp.stageY + b.y * vp.uiScale -- 510
					local vw = b.width * vp.uiScale -- 511
					local vh = b.height * vp.uiScale -- 512
					rectZones[#rectZones + 1] = { -- 513
						id = "talent:" .. tostring(ti), -- 514
						rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 515
					} -- 515
					ti = ti + 1 -- 507
				end -- 507
			end -- 507
			if isPortrait and overlayActive and vp.deckH >= 220 then -- 525
				local offers = p:getStoryTalentOffers() -- 526
				local count = math.min(#offers, #params.storyTalentBoxes) -- 527
				if count > 0 then -- 528
					local padX = math.max(12, safeL + 10) -- 529
					local gap = 8 -- 530
					local availW = ovW - padX * 2 -- 531
					local cardW = (availW - gap * (count - 1)) / count -- 532
					local cardH = 34 -- 533
					local cardY = vp.deckH - cardH - 8 -- 534
					do -- 534
						ti = 0 -- 535
						while ti < count do -- 535
							local r = Rect(padX + ti * (cardW + gap), cardY, cardW, cardH) -- 536
							rectZones[#rectZones + 1] = { -- 537
								id = "talent:" .. tostring(ti), -- 537
								rect = r -- 537
							} -- 537
							local ____self_portraitTalentCards_15 = self.portraitTalentCards -- 538
							____self_portraitTalentCards_15[#____self_portraitTalentCards_15 + 1] = {slot = ti, id = offers[ti + 1], rect = r} -- 538
							ti = ti + 1 -- 535
						end -- 535
					end -- 535
				end -- 535
			end -- 535
		end -- 535
		local g = _G -- 545
		local ____opt_18 = g.package -- 546
		local ____opt_16 = ____opt_18 and ____opt_18.loaded -- 546
		local watchFe = ____opt_16 and ____opt_16["watch.fe"] -- 546
		local rgPlugin = watchFe and watchFe.roguelikeUi -- 547
		if rgPlugin ~= nil and type(rgPlugin.getLedgerButtonRect) == "function" then -- 548
			local lb = rgPlugin:getLedgerButtonRect() -- 549
			if lb.width > 0 and lb.height > 0 then -- 550
				local lx = vp.stageX + lb.x * vp.uiScale -- 551
				local ly = vp.stageY + lb.y * vp.uiScale -- 552
				rectZones[#rectZones + 1] = { -- 553
					id = "ledger:toggle", -- 554
					rect = Rect((lx - 4) / overlayScale, (ly - 4) / overlayScale, (lb.width + 8) * vp.uiScale / overlayScale, (lb.height + 8) * vp.uiScale / overlayScale) -- 555
				} -- 555
			end -- 555
		end -- 555
		prompt = deriveWorldPrompt(p) -- 565
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 566
			local keyW = math.max( -- 568
				24, -- 568
				visualTextWidth(prompt.keyTag, 15) + 16 -- 568
			) -- 568
			local labelW = visualTextWidth(prompt.label, 15) -- 569
			local pillW = keyW + labelW + 24 -- 570
			local padX = math.max(115, pillW * 0.5 + 24) -- 571
			local sxUi = math.max( -- 572
				padX + vp.safeUi.left, -- 572
				math.min( -- 572
					vp.uiW - padX - vp.safeUi.right, -- 572
					params.cam:sx(prompt.x) / vp.uiScale -- 572
				) -- 572
			) -- 572
			local syUi = math.max( -- 573
				96 + vp.safeUi.bottom, -- 573
				math.min( -- 573
					vp.uiH - 110 - vp.safeUi.top, -- 573
					params.cam:sy(prompt.y) / vp.uiScale -- 573
				) -- 573
			) -- 573
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 574
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 575
			rectZones[#rectZones + 1] = { -- 576
				id = "worldPrompt", -- 577
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 578
			} -- 578
		end -- 578
	end -- 578
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 589
		local cx = ovW * 0.5 -- 591
		local cy = safeB + 46 -- 592
		buttons[#buttons + 1] = { -- 593
			id = "nav_confirm", -- 594
			x = cx, -- 595
			y = cy, -- 596
			r = 26, -- 597
			shape = "pill", -- 598
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 599
			label = "继续 · 归程", -- 600
			accent = "amber", -- 601
			active = false, -- 602
			highlighted = true, -- 603
			progress = 0, -- 604
			dimmed = false -- 605
		} -- 605
	end -- 605
	if isTrialMode and p ~= nil and overlayActive then -- 610
		if p.paused or trialEnded then -- 611
			local cx = ovW * 0.5 -- 612
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 613
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 614
			local bh = isPortrait and 44 or 50 -- 615
			local step = bh + 14 -- 616
			if p.paused and not trialEnded then -- 617
				rectZones[#rectZones + 1] = { -- 618
					id = "trial:resume", -- 618
					rect = Rect(cx - bw * 0.5, cy + step * 0.8, bw, bh) -- 618
				} -- 618
			end -- 618
			rectZones[#rectZones + 1] = { -- 620
				id = "trial:retry", -- 620
				rect = Rect(cx - bw * 0.5, cy - bh * 0.2, bw, bh) -- 620
			} -- 620
			rectZones[#rectZones + 1] = { -- 621
				id = "trial:title", -- 621
				rect = Rect(cx - bw * 0.5, cy - step * 1.2, bw, bh) -- 621
			} -- 621
		elseif trialHasOffers and trial ~= nil then -- 622
			local count = #trial.offers -- 623
			local cardW = isPortrait and math.min( -- 624
				114, -- 624
				math.floor((ovW - 44) / math.max(1, count) - 10) -- 624
			) or 216 -- 624
			local cardH = isPortrait and 52 or 62 -- 625
			local gap = isPortrait and 10 or 18 -- 626
			local totalW = count * cardW + (count - 1) * gap -- 627
			local startX = (ovW - totalW) * 0.5 -- 628
			local y = (isPortrait and vp.deckH * 0.52 or ovH * 0.48) - cardH * 0.5 -- 629
			local i = 0 -- 630
			do -- 630
				i = 0 -- 631
				while i < count do -- 631
					rectZones[#rectZones + 1] = { -- 632
						id = "talent:" .. tostring(i), -- 633
						rect = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 634
					} -- 634
					i = i + 1 -- 631
				end -- 631
			end -- 631
			if not isPortrait then -- 637
				rectZones[#rectZones + 1] = { -- 638
					id = "pause", -- 638
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 638
				} -- 638
			end -- 638
		elseif not isPortrait then -- 640
			rectZones[#rectZones + 1] = { -- 641
				id = "pause", -- 641
				rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 641
			} -- 641
			rectZones[#rectZones + 1] = { -- 642
				id = "retry", -- 642
				rect = Rect(ovW - safeR - 210, ovH - safeT - 64, 92, 46) -- 642
			} -- 642
		end -- 642
	end -- 642
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 647
		local interactMeta = deriveInteractActionMeta( -- 648
			p, -- 648
			prompt or deriveWorldPrompt(p), -- 648
			cartNearby, -- 648
			router.cartGripLatched -- 648
		) -- 648
		if isPortrait then -- 650
			local u = unitPortrait * sc -- 651
			local rightX = ovW - safeR - math.floor(68 * u + 0.5) -- 652
			local bottomY = math.max( -- 653
				safeB + math.floor(70 * u + 0.5), -- 653
				vp.deckH * 0.4 -- 653
			) -- 653
			local postY = math.min( -- 654
				vp.deckH - 26, -- 654
				stickDefaultY + stickMaxR + math.floor(42 * u + 0.5) -- 654
			) -- 654
			bottleCancelCenter = { -- 655
				x = rightX - math.floor(14 * u + 0.5), -- 655
				y = bottomY + math.floor(10 * u + 0.5), -- 655
				r = math.floor(34 * u + 0.5) -- 655
			} -- 655
			if not p.childMode then -- 657
				local cw = math.floor(86 * u + 0.5) -- 659
				local ch = math.floor(32 * u + 0.5) -- 660
				buttons[#buttons + 1] = { -- 661
					id = "cover", -- 662
					x = stickDefaultX, -- 663
					y = postY, -- 664
					r = 24 * u, -- 665
					shape = "pill", -- 666
					toggle = true, -- 667
					rect = Rect(stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch), -- 668
					label = router.coverToggled and "离掩体" or "贴掩体", -- 669
					accent = "cyan", -- 670
					active = router.coverToggled or p.coverHug, -- 671
					highlighted = p.coverNear and not router.coverToggled, -- 672
					progress = 0, -- 673
					dimmed = not p.coverNear and not router.coverToggled -- 674
				} -- 674
				buttons[#buttons + 1] = { -- 678
					id = "fire", -- 679
					x = rightX, -- 680
					y = bottomY + math.floor(8 * u + 0.5), -- 681
					r = math.floor(36 * u + 0.5), -- 682
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 683
					subLabel = "拖瞄", -- 684
					accent = "rouge", -- 685
					active = router:isButtonHeld("fire"), -- 686
					highlighted = p.reloadPendingEffect ~= "", -- 687
					progress = 0, -- 688
					dimmed = p.gripping -- 689
				} -- 689
				local nearLedge = isNearLowLedgeForButton(p) -- 691
				buttons[#buttons + 1] = { -- 692
					id = "jump", -- 693
					x = rightX - math.floor(84 * u + 0.5), -- 694
					y = bottomY - math.floor(16 * u + 0.5), -- 695
					r = math.floor(28 * u + 0.5), -- 696
					label = nearLedge and "翻越" or "翻滚", -- 697
					accent = "cyan", -- 698
					active = router:isButtonHeld("jump"), -- 699
					highlighted = nearLedge, -- 700
					progress = 0, -- 701
					dimmed = p.gripping -- 702
				} -- 702
				buttons[#buttons + 1] = { -- 704
					id = "interact", -- 705
					x = rightX - math.floor(10 * u + 0.5), -- 706
					y = bottomY + math.floor(88 * u + 0.5), -- 707
					r = math.floor(30 * u + 0.5), -- 708
					label = interactMeta.label, -- 709
					subLabel = interactMeta.subLabel, -- 710
					accent = interactMeta.urgent and "rouge" or "amber", -- 711
					active = router:isButtonHeld("interact"), -- 712
					highlighted = interactMeta.available, -- 713
					progress = interactMeta.progress, -- 714
					dimmed = not interactMeta.available -- 715
				} -- 715
				if isPlayMode and p.archive.artifactOwned then -- 717
					local eq = p.equippedWeapon == "time_shuttler" -- 718
					buttons[#buttons + 1] = { -- 719
						id = "artifact", -- 720
						x = rightX - math.floor(90 * u + 0.5), -- 721
						y = bottomY + math.floor(68 * u + 0.5), -- 722
						r = math.floor(24 * u + 0.5), -- 723
						label = eq and "收器" or "穿梭", -- 724
						accent = "amber", -- 725
						active = eq, -- 726
						highlighted = eq, -- 727
						progress = 0, -- 728
						dimmed = false -- 729
					} -- 729
				end -- 729
			else -- 729
				local pw = math.floor(68 * u + 0.5) -- 734
				local ph = math.floor(32 * u + 0.5) -- 735
				buttons[#buttons + 1] = { -- 736
					id = "crouch", -- 737
					x = stickDefaultX - math.floor(38 * u + 0.5), -- 738
					y = postY, -- 739
					r = 22 * u, -- 740
					shape = "pill", -- 741
					toggle = true, -- 742
					rect = Rect( -- 743
						stickDefaultX - math.floor(38 * u + 0.5) - pw * 0.5, -- 743
						postY - ph * 0.5, -- 743
						pw, -- 743
						ph -- 743
					), -- 743
					label = router.crouchToggled and "起身" or "蹲伏", -- 744
					accent = "emerald", -- 745
					active = router.crouchToggled or p.player.crouch, -- 746
					highlighted = p.scavChase and not p.player.crouch, -- 747
					progress = 0, -- 748
					dimmed = false -- 749
				} -- 749
				buttons[#buttons + 1] = { -- 751
					id = "cover", -- 752
					x = stickDefaultX + math.floor(38 * u + 0.5), -- 753
					y = postY, -- 754
					r = 22 * u, -- 755
					shape = "pill", -- 756
					toggle = true, -- 757
					rect = Rect( -- 758
						stickDefaultX + math.floor(38 * u + 0.5) - pw * 0.5, -- 758
						postY - ph * 0.5, -- 758
						pw, -- 758
						ph -- 758
					), -- 758
					label = router.slowToggled and "常步" or "轻步", -- 759
					accent = "silk", -- 760
					active = router.slowToggled, -- 761
					highlighted = false, -- 762
					progress = 0, -- 763
					dimmed = false -- 764
				} -- 764
				buttons[#buttons + 1] = { -- 768
					id = "jump", -- 769
					x = rightX, -- 770
					y = bottomY + math.floor(8 * u + 0.5), -- 771
					r = math.floor(32 * u + 0.5), -- 772
					label = "跳跃", -- 773
					accent = "amber", -- 774
					active = router:isButtonHeld("jump"), -- 775
					highlighted = false, -- 776
					progress = 0, -- 777
					dimmed = p.gripping -- 778
				} -- 778
				buttons[#buttons + 1] = { -- 780
					id = "interact", -- 781
					x = rightX - math.floor(8 * u + 0.5), -- 782
					y = bottomY + math.floor(86 * u + 0.5), -- 783
					r = math.floor(31 * u + 0.5), -- 784
					label = interactMeta.label, -- 785
					subLabel = interactMeta.subLabel, -- 786
					accent = interactMeta.urgent and "rouge" or "amber", -- 787
					active = router:isButtonHeld("interact"), -- 788
					highlighted = interactMeta.available, -- 789
					progress = interactMeta.progress, -- 790
					dimmed = not interactMeta.available -- 791
				} -- 791
				if canBottleAim then -- 793
					buttons[#buttons + 1] = { -- 794
						id = "bottle", -- 795
						x = rightX - math.floor(86 * u + 0.5), -- 796
						y = bottomY + math.floor(46 * u + 0.5), -- 797
						r = math.floor(32 * u + 0.5), -- 798
						label = "投瓶", -- 799
						subLabel = "拖瞄", -- 800
						accent = "amber", -- 801
						active = router:isButtonHeld("bottle"), -- 802
						highlighted = true, -- 803
						progress = math.min(1, p.aimHold / 0.12), -- 804
						dimmed = false -- 805
					} -- 805
				end -- 805
			end -- 805
		else -- 805
			local rightX = ovW - safeR - 92 * sc -- 811
			local bottomY = safeB + 110 * sc -- 812
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 813
			if not p.childMode then -- 815
				buttons[#buttons + 1] = { -- 816
					id = "fire", -- 817
					x = rightX, -- 818
					y = bottomY + 12 * sc, -- 819
					r = 45 * sc, -- 820
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 821
					subLabel = "拖瞄", -- 822
					accent = "rouge", -- 823
					active = router:isButtonHeld("fire"), -- 824
					highlighted = p.reloadPendingEffect ~= "", -- 825
					progress = 0, -- 826
					dimmed = p.gripping -- 827
				} -- 827
				local nearLedge = isNearLowLedgeForButton(p) -- 829
				buttons[#buttons + 1] = { -- 830
					id = "jump", -- 831
					x = rightX - 116 * sc, -- 832
					y = bottomY - 8 * sc, -- 833
					r = 34 * sc, -- 834
					label = nearLedge and "翻越" or "翻滚", -- 835
					accent = "cyan", -- 836
					active = router:isButtonHeld("jump"), -- 837
					highlighted = nearLedge, -- 838
					progress = 0, -- 839
					dimmed = p.gripping -- 840
				} -- 840
				buttons[#buttons + 1] = { -- 842
					id = "cover", -- 843
					x = rightX - 120 * sc, -- 844
					y = bottomY + 94 * sc, -- 845
					r = 32 * sc, -- 846
					label = router.coverToggled and "离掩" or "掩体", -- 847
					accent = "cyan", -- 848
					active = router.coverToggled, -- 849
					highlighted = p.coverNear and not router.coverToggled, -- 850
					progress = 0, -- 851
					dimmed = not p.coverNear and not router.coverToggled -- 852
				} -- 852
				buttons[#buttons + 1] = { -- 854
					id = "interact", -- 855
					x = rightX - 10 * sc, -- 856
					y = bottomY + 122 * sc, -- 857
					r = 36 * sc, -- 858
					label = interactMeta.label, -- 859
					subLabel = interactMeta.subLabel, -- 860
					accent = interactMeta.urgent and "rouge" or "amber", -- 861
					active = router:isButtonHeld("interact"), -- 862
					highlighted = interactMeta.available, -- 863
					progress = interactMeta.progress, -- 864
					dimmed = not interactMeta.available -- 865
				} -- 865
				if isPlayMode and p.archive.artifactOwned then -- 867
					local eq = p.equippedWeapon == "time_shuttler" -- 868
					buttons[#buttons + 1] = { -- 869
						id = "artifact", -- 870
						x = rightX - 112 * sc, -- 871
						y = bottomY + 184 * sc, -- 872
						r = 27 * sc, -- 873
						label = eq and "收器" or "穿梭", -- 874
						accent = "amber", -- 875
						active = eq, -- 876
						highlighted = eq, -- 877
						progress = 0, -- 878
						dimmed = false -- 879
					} -- 879
				end -- 879
			else -- 879
				buttons[#buttons + 1] = { -- 883
					id = "jump", -- 884
					x = rightX, -- 885
					y = bottomY + 12 * sc, -- 886
					r = 38 * sc, -- 887
					label = "跳跃", -- 888
					accent = "amber", -- 889
					active = router:isButtonHeld("jump"), -- 890
					highlighted = false, -- 891
					progress = 0, -- 892
					dimmed = p.gripping -- 893
				} -- 893
				buttons[#buttons + 1] = { -- 895
					id = "crouch", -- 896
					x = rightX - 106 * sc, -- 897
					y = bottomY - 6 * sc, -- 898
					r = 34 * sc, -- 899
					label = router.crouchToggled and "起身" or "蹲伏", -- 900
					accent = "emerald", -- 901
					active = router.crouchToggled or p.player.crouch, -- 902
					highlighted = p.scavChase and not p.player.crouch, -- 903
					progress = 0, -- 904
					dimmed = false -- 905
				} -- 905
				buttons[#buttons + 1] = { -- 907
					id = "cover", -- 908
					x = rightX - 196 * sc, -- 909
					y = bottomY - 16 * sc, -- 910
					r = 29 * sc, -- 911
					label = router.slowToggled and "常步" or "轻步", -- 912
					accent = "silk", -- 913
					active = router.slowToggled, -- 914
					highlighted = false, -- 915
					progress = 0, -- 916
					dimmed = false -- 917
				} -- 917
				buttons[#buttons + 1] = { -- 919
					id = "interact", -- 920
					x = rightX - 12 * sc, -- 921
					y = bottomY + 114 * sc, -- 922
					r = 36 * sc, -- 923
					label = interactMeta.label, -- 924
					subLabel = interactMeta.subLabel, -- 925
					accent = interactMeta.urgent and "rouge" or "amber", -- 926
					active = router:isButtonHeld("interact"), -- 927
					highlighted = interactMeta.available, -- 928
					progress = interactMeta.progress, -- 929
					dimmed = not interactMeta.available -- 930
				} -- 930
				if canBottleAim then -- 932
					buttons[#buttons + 1] = { -- 933
						id = "bottle", -- 934
						x = rightX - 114 * sc, -- 935
						y = bottomY + 98 * sc, -- 936
						r = 38 * sc, -- 937
						label = "投瓶", -- 938
						subLabel = "拖瞄", -- 939
						accent = "amber", -- 940
						active = router:isButtonHeld("bottle"), -- 941
						highlighted = true, -- 942
						progress = math.min(1, p.aimHold / 0.12), -- 943
						dimmed = false -- 944
					} -- 944
				end -- 944
			end -- 944
		end -- 944
	end -- 944
	local enemyTargets = canShoot and p ~= nil and (isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH)) or ({}) -- 952
	local playerScreenX = vp.stageW * 0.5 -- 958
	local playerScreenY = vp.stageH * 0.38 -- 959
	if p ~= nil then -- 960
		if isPlayMode and params.cam ~= nil then -- 961
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 962
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 963
		else -- 963
			playerScreenX = vp.stageW * 0.45 -- 965
			playerScreenY = vp.stageH * 0.36 -- 966
		end -- 966
	end -- 966
	local ctx = { -- 970
		viewport = vp, -- 971
		overlayScale = overlayScale, -- 972
		overlayActive = overlayActive, -- 973
		allowAutoGameplayTouch = allowAutoGameplayTouch, -- 974
		allowMouseOnOverlay = allowMouseOnOverlay, -- 975
		modal = modal, -- 976
		gameplayActive = gameplayActive, -- 977
		cutsceneBlocking = cutsceneBlocking, -- 978
		childMode = p ~= nil and p.childMode, -- 979
		allowDepth = allowDepth, -- 980
		canShoot = canShoot, -- 981
		canBottleAim = canBottleAim, -- 982
		cartNearby = cartNearby, -- 983
		cartGripping = p ~= nil and p.gripping, -- 984
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 985
		coverNear = p ~= nil and p.coverNear, -- 986
		playerRolling = p ~= nil and p.player.rollT > 0, -- 987
		inLowArch = p ~= nil and isInLowArch(p), -- 988
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 989
		playerFacing = p ~= nil and p.player.facing or 1, -- 990
		playerScreenX = playerScreenX, -- 991
		playerScreenY = playerScreenY, -- 992
		enemyTargets = enemyTargets, -- 993
		stickZoneMaxX = stickZoneMaxX, -- 994
		stickZoneMaxY = stickZoneMaxY, -- 995
		stickDefaultX = stickDefaultX, -- 996
		stickDefaultY = stickDefaultY, -- 997
		stickMaxR = stickMaxR, -- 998
		stickFixedOrigin = isPortrait, -- 999
		buttons = buttons, -- 1000
		rectZones = rectZones, -- 1001
		bottleCancelCenter = bottleCancelCenter -- 1002
	} -- 1002
	self.lastContext = ctx -- 1005
	router:setFrameContext(ctx, params.dt) -- 1006
	return ctx -- 1007
end -- 244
function TouchControls.prototype.render(self, router) -- 1011
	self.deckDraw:clear() -- 1012
	self.padDraw:clear() -- 1013
	self.padInkDraw:clear() -- 1014
	self.padGlow:clear() -- 1015
	self.padArt:beginFrame() -- 1016
	self.texts:beginFrame() -- 1017
	local ctx = self.lastContext -- 1019
	if ctx == nil or not ctx.overlayActive and not ctx.viewport.isPortrait then -- 1020
		self.padArt:endFrame() -- 1021
		self.texts:endFrame() -- 1022
		return -- 1023
	end -- 1023
	local vp = ctx.viewport -- 1026
	local sc = math.max(0.25, ctx.overlayScale) -- 1027
	self.overlayRoot.scaleX = sc -- 1028
	self.overlayRoot.scaleY = sc -- 1029
	local ovW = vp.fullW / sc -- 1031
	local ovH = vp.fullH / sc -- 1032
	local baseAlpha = router.settings.touchOpacity -- 1033
	if vp.isPortrait then -- 1036
		self:drawPortraitFrame(ctx, ovW, ovH) -- 1037
	end -- 1037
	if not ctx.overlayActive then -- 1040
		self.padArt:endFrame() -- 1041
		self.texts:endFrame() -- 1042
		return -- 1043
	end -- 1043
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 1047
		local rx = ovW * 0.5 -- 1048
		local ry = vp.isPortrait and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 1049
		drawSilkVeil( -- 1050
			self.padDraw, -- 1050
			self.padArt, -- 1050
			"touch_restart_veil", -- 1050
			rx, -- 1050
			ry, -- 1050
			230, -- 1050
			36, -- 1050
			PALETTE.inkWash, -- 1050
			0.78 * baseAlpha, -- 1050
			1 -- 1050
		) -- 1050
		drawHairline( -- 1051
			self.padInkDraw, -- 1051
			self.padArt, -- 1051
			"touch_restart_line", -- 1051
			rx, -- 1051
			ry + 16, -- 1051
			180, -- 1051
			PALETTE.amber, -- 1051
			0.52 * baseAlpha, -- 1051
			true, -- 1051
			2 -- 1051
		) -- 1051
		self.texts:put( -- 1052
			"xs", -- 1052
			"轻触屏幕再次启程", -- 1052
			rx, -- 1052
			ry, -- 1052
			toColor(PALETTE.amberCore), -- 1052
			0.5, -- 1052
			0.5, -- 1052
			"Center", -- 1052
			1.6, -- 1052
			0.94, -- 1052
			0.08 -- 1052
		) -- 1052
	end -- 1052
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 1056
		self:drawTrialZones(ctx, baseAlpha) -- 1057
	elseif self.lastMode == 1 and vp.isPortrait and #self.portraitTalentCards > 0 then -- 1058
		self:drawPortraitStoryTalentCards(baseAlpha) -- 1059
	end -- 1059
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 1063
		self:drawStick(router, ctx, baseAlpha) -- 1064
	end -- 1064
	self:drawButtons(router, ctx, baseAlpha) -- 1068
	local bottleDrag = router:getBottleDragVisual() -- 1071
	if bottleDrag.active then -- 1072
		local cx = bottleDrag.cancelX -- 1073
		local cy = bottleDrag.cancelY -- 1074
		local cr = bottleDrag.cancelR -- 1075
		local hot = bottleDrag.cancelHover -- 1076
		fillCirclePoly( -- 1077
			self.padDraw, -- 1078
			cx, -- 1079
			cy, -- 1080
			cr, -- 1081
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 1082
			0, -- 1083
			nil, -- 1084
			22 -- 1085
		) -- 1085
		drawRingArc( -- 1087
			self.padInkDraw, -- 1087
			cx, -- 1087
			cy, -- 1087
			cr, -- 1087
			0, -- 1087
			TWO_PI, -- 1087
			hot and 2.2 or 1.3, -- 1087
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 1087
			22 -- 1087
		) -- 1087
		self.texts:put( -- 1088
			"xs", -- 1088
			hot and "松手取消" or "拖此取消", -- 1088
			cx, -- 1088
			cy, -- 1088
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 1088
			0.5, -- 1088
			0.5, -- 1088
			"Center", -- 1088
			0.8, -- 1088
			0.96, -- 1088
			0.08 -- 1088
		) -- 1088
	end -- 1088
	self.padArt:endFrame() -- 1091
	self.texts:endFrame() -- 1092
end -- 1011
function TouchControls.prototype.drawPortraitFrame(self, ctx, w, h) -- 1095
	local vp = ctx.viewport -- 1096
	local topY = vp.stageY + vp.stageH -- 1097
	if topY < h then -- 1099
		self.deckDraw:drawRect( -- 1100
			Rect(0, topY, w, h - topY), -- 1100
			toColor(PALETTE.inkVoid, 252) -- 1100
		) -- 1100
		self.deckDraw:drawSegment( -- 1101
			Vec2(0, topY), -- 1101
			Vec2(w, topY), -- 1101
			1, -- 1101
			toColor(PALETTE.silkDim, 140) -- 1101
		) -- 1101
		local labelY = topY + (h - topY) * 0.5 -- 1102
		self.texts:put( -- 1103
			"xs", -- 1103
			"向西守望 · 掌机竖屏", -- 1103
			vp.safe.left + 12, -- 1103
			labelY, -- 1103
			toColor(PALETTE.amberCore), -- 1103
			0, -- 1103
			0.5, -- 1103
			"Left", -- 1103
			0.8, -- 1103
			0.88, -- 1103
			0.08 -- 1103
		) -- 1103
	end -- 1103
	if vp.stageX > 0 then -- 1106
		self.deckDraw:drawRect( -- 1107
			Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 1107
			toColor(PALETTE.inkVoid, 255) -- 1107
		) -- 1107
		self.deckDraw:drawRect( -- 1108
			Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 1108
			toColor(PALETTE.inkVoid, 255) -- 1108
		) -- 1108
	end -- 1108
	if vp.deckH > 0 then -- 1111
		fillVGradRect( -- 1112
			self.deckDraw, -- 1112
			0, -- 1112
			0, -- 1112
			w, -- 1112
			vp.deckH, -- 1112
			toColor(PALETTE.voidDark, 255), -- 1112
			toColor(PALETTE.inkWash, 255) -- 1112
		) -- 1112
		self.deckDraw:drawSegment( -- 1113
			Vec2(0, vp.deckH), -- 1113
			Vec2(w, vp.deckH), -- 1113
			1.2, -- 1113
			toColor(PALETTE.silkLine, 165) -- 1113
		) -- 1113
		self.deckDraw:drawSegment( -- 1114
			Vec2(18, vp.deckH - 4), -- 1114
			Vec2(w - 18, vp.deckH - 4), -- 1114
			0.6, -- 1114
			toColor(PALETTE.silkDim, 85) -- 1114
		) -- 1114
		drawDiamond( -- 1115
			self.padInkDraw, -- 1115
			w * 0.5, -- 1115
			vp.deckH, -- 1115
			5, -- 1115
			5, -- 1115
			toColor(PALETTE.rouge, 220), -- 1115
			0.9, -- 1115
			toColor(PALETTE.silkLine, 180) -- 1115
		) -- 1115
		local footY = math.max(vp.safe.bottom + 14, 16) -- 1117
		local p = self.lastPlay -- 1118
		local inOverlayModal = p ~= nil and (p.reloadOpen or p.craftBench.active) -- 1119
		local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or p ~= nil and p.paused) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 1120
		self.texts:put( -- 1127
			"xs", -- 1127
			hint, -- 1127
			w * 0.5, -- 1127
			footY, -- 1127
			toColor(PALETTE.textDim), -- 1127
			0.5, -- 1127
			0.5, -- 1127
			"Center", -- 1127
			0.8, -- 1127
			0.78, -- 1127
			0.06 -- 1127
		) -- 1127
	end -- 1127
end -- 1095
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 1131
	local stick = router:getStickVisual() -- 1132
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 1133
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 1136
	fillCirclePoly( -- 1138
		self.padDraw, -- 1139
		stick.originX, -- 1140
		stick.originY, -- 1141
		stick.radius, -- 1142
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 1143
		0, -- 1144
		nil, -- 1145
		28 -- 1146
	) -- 1146
	drawRingArc( -- 1148
		self.padInkDraw, -- 1148
		stick.originX, -- 1148
		stick.originY, -- 1148
		stick.radius, -- 1148
		0, -- 1148
		TWO_PI, -- 1148
		stick.active and 1.5 or 1, -- 1148
		toColor(ringCol, 168 * stickAlpha), -- 1148
		28 -- 1148
	) -- 1148
	if stick.allowDepth then -- 1150
		local dOff = stick.radius - 10 -- 1151
		self.padInkDraw:drawDot( -- 1152
			Vec2(stick.originX, stick.originY + dOff), -- 1152
			2.1, -- 1152
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1152
		) -- 1152
		self.padInkDraw:drawDot( -- 1153
			Vec2(stick.originX, stick.originY - dOff), -- 1153
			2.1, -- 1153
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1153
		) -- 1153
		self.padInkDraw:drawDot( -- 1154
			Vec2(stick.originX - dOff, stick.originY), -- 1154
			2.1, -- 1154
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1154
		) -- 1154
		self.padInkDraw:drawDot( -- 1155
			Vec2(stick.originX + dOff, stick.originY), -- 1155
			2.1, -- 1155
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1155
		) -- 1155
	elseif ctx.childMode then -- 1156
		drawRingArc( -- 1157
			self.padInkDraw, -- 1158
			stick.originX, -- 1159
			stick.originY, -- 1160
			stick.radius * 0.56, -- 1161
			0, -- 1162
			TWO_PI, -- 1163
			0.9, -- 1164
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 1165
			20 -- 1166
		) -- 1166
	end -- 1166
	local knobR = math.max(16, stick.radius * 0.36) -- 1170
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 1171
	if stick.active then -- 1172
		fillRadialGlow( -- 1173
			self.padGlow, -- 1173
			stick.knobX, -- 1173
			stick.knobY, -- 1173
			knobR * 1.45, -- 1173
			knobR * 1.45, -- 1173
			toColor(knobAccent, 48 * stickAlpha), -- 1173
			Color(0, 0, 0, 0), -- 1173
			12 -- 1173
		) -- 1173
	end -- 1173
	fillCirclePoly( -- 1175
		self.padDraw, -- 1176
		stick.knobX, -- 1177
		stick.knobY, -- 1178
		knobR, -- 1179
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 1180
		1.3, -- 1181
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 1182
		22 -- 1183
	) -- 1183
	drawBlossomDot( -- 1185
		self.padInkDraw, -- 1185
		self.padArt, -- 1185
		"touch_stick_dot", -- 1185
		stick.knobX, -- 1185
		stick.knobY, -- 1185
		stick.active and 11 or 7, -- 1185
		knobAccent, -- 1185
		0.85 * stickAlpha, -- 1185
		4 -- 1185
	) -- 1185
	if stick.slowZone then -- 1186
		self.texts:put( -- 1187
			"xs", -- 1187
			"轻步", -- 1187
			stick.originX, -- 1187
			stick.originY + stick.radius + 14, -- 1187
			toColor(PALETTE.emerald), -- 1187
			0.5, -- 1187
			0.5, -- 1187
			"Center", -- 1187
			1, -- 1187
			0.9, -- 1187
			0.08 -- 1187
		) -- 1187
	end -- 1187
end -- 1131
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 1191
	local bottleDrag = router:getBottleDragVisual() -- 1192
	local fireStick = router:getFireStickVisual() -- 1193
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 1194
	local i = 0 -- 1196
	do -- 1196
		i = 0 -- 1197
		while i < #ctx.buttons do -- 1197
			do -- 1197
				local b = ctx.buttons[i + 1] -- 1198
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 1199
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 1200
					bAlpha = bAlpha * 0.25 -- 1201
				end -- 1201
				local col = accentPalette(b.accent) -- 1203
				local core = accentCore(b.accent) -- 1204
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 1205
				if b.shape == "pill" and b.rect ~= nil then -- 1207
					local r = b.rect -- 1208
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 1209
					self.padDraw:drawRoundedRect( -- 1212
						r, -- 1213
						6, -- 1214
						fillCol, -- 1215
						b.active and 1.4 or 1, -- 1216
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 1217
					) -- 1217
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 1219
						local icX = r.x + 22 -- 1220
						local icY = r.y + r.height * 0.5 -- 1221
						drawRingArc( -- 1222
							self.padInkDraw, -- 1222
							icX, -- 1222
							icY, -- 1222
							9, -- 1222
							0, -- 1222
							TWO_PI, -- 1222
							1, -- 1222
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 1222
							16 -- 1222
						) -- 1222
						self.padInkDraw:drawSegment( -- 1223
							Vec2(icX - 2.6, icY - 3.6), -- 1223
							Vec2(icX - 2.6, icY + 3.6), -- 1223
							1.5, -- 1223
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1223
						) -- 1223
						self.padInkDraw:drawSegment( -- 1224
							Vec2(icX + 2.6, icY - 3.6), -- 1224
							Vec2(icX + 2.6, icY + 3.6), -- 1224
							1.5, -- 1224
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1224
						) -- 1224
						self.texts:put( -- 1225
							"xs", -- 1225
							b.label, -- 1225
							r.x + r.width * 0.5 + 10, -- 1225
							icY, -- 1225
							toColor(PALETTE.textBright), -- 1225
							0.5, -- 1225
							0.5, -- 1225
							"Center", -- 1225
							1, -- 1225
							0.94 * bAlpha, -- 1225
							0.08 -- 1225
						) -- 1225
					else -- 1225
						if b.toggle and b.active then -- 1227
							drawDiamond( -- 1228
								self.padInkDraw, -- 1228
								r.x + 11, -- 1228
								r.y + r.height * 0.5, -- 1228
								3.8, -- 1228
								3.8, -- 1228
								toColor(col, 235) -- 1228
							) -- 1228
						end -- 1228
						self.texts:put( -- 1230
							"xs", -- 1231
							b.label, -- 1232
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 1233
							r.y + r.height * 0.5, -- 1234
							toColor(b.active and core or PALETTE.textBright), -- 1235
							0.5, -- 1236
							0.5, -- 1237
							"Center", -- 1238
							0.6, -- 1239
							math.min(1, bAlpha + 0.08), -- 1240
							0.08 -- 1241
						) -- 1241
					end -- 1241
					goto __continue102 -- 1244
				end -- 1244
				if b.active or b.highlighted then -- 1247
					fillRadialGlow( -- 1248
						self.padGlow, -- 1249
						b.x, -- 1250
						b.y, -- 1251
						b.r * 1.38, -- 1252
						b.r * 1.38, -- 1253
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 1254
						Color(col.r, col.g, col.b, 0), -- 1255
						12 -- 1256
					) -- 1256
				end -- 1256
				fillCirclePoly( -- 1260
					self.padDraw, -- 1261
					b.x, -- 1262
					b.y, -- 1263
					b.r, -- 1264
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 1265
					0, -- 1266
					nil, -- 1267
					24 -- 1268
				) -- 1268
				drawRingArc( -- 1270
					self.padInkDraw, -- 1271
					b.x, -- 1272
					b.y, -- 1273
					b.r, -- 1274
					0, -- 1275
					TWO_PI, -- 1276
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 1277
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 1278
					24 -- 1279
				) -- 1279
				drawRingArc( -- 1281
					self.padInkDraw, -- 1282
					b.x, -- 1283
					b.y, -- 1284
					b.r - 4.2, -- 1285
					0, -- 1286
					TWO_PI, -- 1287
					0.7, -- 1288
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 1289
					20 -- 1290
				) -- 1290
				if b.progress > 0.02 then -- 1293
					drawRingArc( -- 1294
						self.padInkDraw, -- 1295
						b.x, -- 1296
						b.y, -- 1297
						b.r + 4, -- 1298
						HALF_PI, -- 1299
						-TWO_PI * math.min(1, b.progress), -- 1300
						2.6, -- 1301
						toColor(PALETTE.amberCore, 240), -- 1302
						28 -- 1303
					) -- 1303
				end -- 1303
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 1307
				self.texts:put( -- 1308
					fontKind, -- 1309
					b.label, -- 1310
					b.x, -- 1311
					hasSub and b.y + 6 or b.y, -- 1312
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 1313
					0.5, -- 1314
					0.5, -- 1315
					"Center", -- 1316
					0.6, -- 1317
					bAlpha, -- 1318
					0.08 -- 1319
				) -- 1319
				if hasSub and b.subLabel ~= nil then -- 1321
					self.texts:put( -- 1322
						"xs", -- 1323
						b.subLabel, -- 1324
						b.x, -- 1325
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 1326
						toColor(b.active and core or PALETTE.textDim), -- 1327
						0.5, -- 1328
						0.5, -- 1329
						"Center", -- 1330
						0.4, -- 1331
						bAlpha * 0.85, -- 1332
						0.06 -- 1333
					) -- 1333
				end -- 1333
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 1337
					self.padInkDraw:drawSegment( -- 1338
						Vec2(fireStick.originX, fireStick.originY), -- 1338
						Vec2(fireStick.knobX, fireStick.knobY), -- 1338
						1.4, -- 1338
						toColor(PALETTE.rouge, 190) -- 1338
					) -- 1338
					fillCirclePoly( -- 1339
						self.padDraw, -- 1339
						fireStick.knobX, -- 1339
						fireStick.knobY, -- 1339
						12, -- 1339
						toColor(PALETTE.rouge, 210), -- 1339
						1.2, -- 1339
						toColor(PALETTE.crimsonCore, 240), -- 1339
						16 -- 1339
					) -- 1339
				end -- 1339
			end -- 1339
			::__continue102:: -- 1339
			i = i + 1 -- 1197
		end -- 1197
	end -- 1197
end -- 1191
function TouchControls.prototype.drawPortraitStoryTalentCards(self, alpha) -- 1344
	local i = 0 -- 1345
	do -- 1345
		i = 0 -- 1346
		while i < #self.portraitTalentCards do -- 1346
			local card = self.portraitTalentCards[i + 1] -- 1347
			local meta = resolveTalentVisual(card.id) -- 1348
			local r = card.rect -- 1349
			local cy = r.y + r.height * 0.5 -- 1350
			self.padDraw:drawRoundedRect( -- 1351
				r, -- 1352
				5, -- 1353
				toColor( -- 1354
					PALETTE.panelBgDeep, -- 1354
					math.floor(228 * alpha + 0.5) -- 1354
				), -- 1354
				1.2, -- 1355
				toColor( -- 1356
					meta.accent, -- 1356
					math.floor(215 * alpha + 0.5) -- 1356
				) -- 1356
			) -- 1356
			drawTalentGlyph( -- 1358
				self.padInkDraw, -- 1358
				r.x + 17, -- 1358
				cy, -- 1358
				8.5, -- 1358
				card.id, -- 1358
				meta.accent, -- 1358
				math.min(1, alpha + 0.1), -- 1358
				meta.accentCore -- 1358
			) -- 1358
			self.texts:put( -- 1359
				"xs", -- 1360
				meta.title .. " · 落印", -- 1361
				r.x + 31, -- 1362
				cy, -- 1363
				toColor(meta.accentCore), -- 1364
				0, -- 1365
				0.5, -- 1366
				"Left", -- 1367
				0.4, -- 1368
				math.min(1, alpha + 0.12), -- 1369
				0.08 -- 1370
			) -- 1370
			i = i + 1 -- 1346
		end -- 1346
	end -- 1346
end -- 1344
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 1375
	local ____opt_22 = self.lastRun -- 1376
	local trial = ____opt_22 and ____opt_22.trial -- 1376
	local i = 0 -- 1377
	do -- 1377
		i = 0 -- 1378
		while i < #ctx.rectZones do -- 1378
			local z = ctx.rectZones[i + 1] -- 1379
			local r = z.rect -- 1380
			local cx = r.x + r.width * 0.5 -- 1381
			local cy = r.y + r.height * 0.5 -- 1382
			if z.id == "pause" or z.id == "retry" then -- 1383
				self.padDraw:drawRoundedRect( -- 1384
					r, -- 1384
					6, -- 1384
					toColor(PALETTE.inkWash, 185 * alpha), -- 1384
					1.2, -- 1384
					toColor(PALETTE.silkLine, 175 * alpha) -- 1384
				) -- 1384
				self.texts:put( -- 1385
					"xs", -- 1385
					z.id == "pause" and "暂停" or "重开", -- 1385
					cx, -- 1385
					cy, -- 1385
					toColor(PALETTE.textBright), -- 1385
					0.5, -- 1385
					0.5, -- 1385
					"Center", -- 1385
					0.8, -- 1385
					0.94, -- 1385
					0.08 -- 1385
				) -- 1385
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 1386
				local idx = __TS__Number(string.sub(z.id, 8)) -- 1387
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 1388
				self.padDraw:drawRoundedRect( -- 1389
					r, -- 1389
					6, -- 1389
					toColor(PALETTE.panelBgDeep, 235), -- 1389
					1.6, -- 1389
					toColor(PALETTE.amber, 225) -- 1389
				) -- 1389
				self.texts:put( -- 1390
					"xs", -- 1390
					(tostring(idx + 1) .. " · ") .. tName, -- 1390
					cx, -- 1390
					cy, -- 1390
					toColor(PALETTE.amberCore), -- 1390
					0.5, -- 1390
					0.5, -- 1390
					"Center", -- 1390
					0.6, -- 1390
					0.98, -- 1390
					0.08 -- 1390
				) -- 1390
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1391
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1392
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1393
				self.padDraw:drawRoundedRect( -- 1394
					r, -- 1394
					6, -- 1394
					toColor(PALETTE.panelBgDeep, 235), -- 1394
					1.5, -- 1394
					toColor(border, 220) -- 1394
				) -- 1394
				self.texts:put( -- 1395
					"sm", -- 1395
					label, -- 1395
					cx, -- 1395
					cy, -- 1395
					toColor(PALETTE.textBright), -- 1395
					0.5, -- 1395
					0.5, -- 1395
					"Center", -- 1395
					1, -- 1395
					0.98, -- 1395
					0.08 -- 1395
				) -- 1395
			end -- 1395
			i = i + 1 -- 1378
		end -- 1378
	end -- 1378
end -- 1375
return ____exports -- 1375
