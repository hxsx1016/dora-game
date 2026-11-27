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
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 287
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
	) or safeL + 126 * sc -- 299
	local stickDefaultY = isPortrait and math.max(safeB + stickMaxR + 24, vp.deckH * 0.44) or safeB + 126 * sc -- 301
	local stickZoneMaxX = isPortrait and ovW * 0.5 or ovW * 0.46 -- 304
	local stickZoneMaxY = isPortrait and math.max(40, vp.deckH - 8) or ovH - 110 -- 305
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 307
	if overlayActive then -- 307
		if isPortrait then -- 307
			local topY = ovH - vp.topBarH * 0.5 -- 313
			local pillH = 26 -- 314
			local rx = ovW - safeR - 10 -- 315
			if gameplayActive and p ~= nil and not p.paused then -- 315
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
				if not inTowerEnd then -- 336
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
			if canToggleFullscreen() then -- 374
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
			if isPlayMode and not modal then -- 391
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
				if isWebPlatform() then -- 411
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
					if canToggleFullscreen() then -- 429
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
	if isPortrait and overlayActive and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 446
		local cy = math.max(safeB + 84, vp.deckH * 0.5) -- 456
		local leftX = safeL + math.max(82, ovW * 0.25) -- 457
		local step = math.min( -- 458
			54, -- 458
			math.max(42, ovW * 0.12) -- 458
		) -- 458
		local nr = math.min( -- 459
			26, -- 459
			math.max(21, ovW * 0.06) -- 459
		) -- 459
		buttons[#buttons + 1] = { -- 460
			id = "nav_up", -- 460
			x = leftX, -- 460
			y = cy + step, -- 460
			r = nr, -- 460
			label = "上", -- 460
			accent = "silk", -- 460
			active = false, -- 460
			highlighted = false, -- 460
			progress = 0, -- 460
			dimmed = false -- 460
		} -- 460
		buttons[#buttons + 1] = { -- 461
			id = "nav_down", -- 461
			x = leftX, -- 461
			y = cy - step, -- 461
			r = nr, -- 461
			label = "下", -- 461
			accent = "silk", -- 461
			active = false, -- 461
			highlighted = false, -- 461
			progress = 0, -- 461
			dimmed = false -- 461
		} -- 461
		buttons[#buttons + 1] = { -- 462
			id = "nav_left", -- 462
			x = leftX - step, -- 462
			y = cy, -- 462
			r = nr, -- 462
			label = "左", -- 462
			accent = "silk", -- 462
			active = false, -- 462
			highlighted = false, -- 462
			progress = 0, -- 462
			dimmed = false -- 462
		} -- 462
		buttons[#buttons + 1] = { -- 463
			id = "nav_right", -- 463
			x = leftX + step, -- 463
			y = cy, -- 463
			r = nr, -- 463
			label = "右", -- 463
			accent = "silk", -- 463
			active = false, -- 463
			highlighted = false, -- 463
			progress = 0, -- 463
			dimmed = false -- 463
		} -- 463
		local rightX = ovW - safeR - math.max(76, ovW * 0.23) -- 465
		buttons[#buttons + 1] = { -- 466
			id = "nav_confirm", -- 467
			x = rightX, -- 468
			y = cy + 28, -- 469
			r = 28, -- 470
			shape = "pill", -- 471
			rect = Rect(rightX - 48, cy + 6, 96, 44), -- 472
			label = "确认", -- 473
			accent = "rouge", -- 474
			active = false, -- 475
			highlighted = true, -- 476
			progress = 0, -- 477
			dimmed = false -- 478
		} -- 478
		buttons[#buttons + 1] = { -- 480
			id = "nav_back", -- 481
			x = rightX, -- 482
			y = cy - 30, -- 483
			r = 26, -- 484
			shape = "pill", -- 485
			rect = Rect(rightX - 48, cy - 50, 96, 40), -- 486
			label = "返回", -- 487
			accent = "silk", -- 488
			active = false, -- 489
			highlighted = false, -- 490
			progress = 0, -- 491
			dimmed = false -- 492
		} -- 492
	end -- 492
	local prompt -- 497
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 497
		if #params.storyTalentBoxes > 0 then -- 497
			local ti = 0 -- 501
			do -- 501
				ti = 0 -- 502
				while ti < #params.storyTalentBoxes do -- 502
					local b = params.storyTalentBoxes[ti + 1] -- 503
					local vx = vp.stageX + b.x * vp.uiScale -- 504
					local vy = vp.stageY + b.y * vp.uiScale -- 505
					local vw = b.width * vp.uiScale -- 506
					local vh = b.height * vp.uiScale -- 507
					rectZones[#rectZones + 1] = { -- 508
						id = "talent:" .. tostring(ti), -- 509
						rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 510
					} -- 510
					ti = ti + 1 -- 502
				end -- 502
			end -- 502
		end -- 502
		prompt = deriveWorldPrompt(p) -- 520
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and (params.assistHintsEnabled or overlayActive) then -- 520
			local keyW = math.max( -- 523
				24, -- 523
				visualTextWidth(prompt.keyTag, 15) + 16 -- 523
			) -- 523
			local labelW = visualTextWidth(prompt.label, 15) -- 524
			local pillW = keyW + labelW + 24 -- 525
			local padX = math.max(115, pillW * 0.5 + 24) -- 526
			local sxUi = math.max( -- 527
				padX + vp.safeUi.left, -- 527
				math.min( -- 527
					vp.uiW - padX - vp.safeUi.right, -- 527
					params.cam:sx(prompt.x) / vp.uiScale -- 527
				) -- 527
			) -- 527
			local syUi = math.max( -- 528
				96 + vp.safeUi.bottom, -- 528
				math.min( -- 528
					vp.uiH - 110 - vp.safeUi.top, -- 528
					params.cam:sy(prompt.y) / vp.uiScale -- 528
				) -- 528
			) -- 528
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 529
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 530
			rectZones[#rectZones + 1] = { -- 531
				id = "worldPrompt", -- 532
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 533
			} -- 533
		end -- 533
	end -- 533
	if isTrialMode and p ~= nil and overlayActive then -- 533
		if p.paused or trialEnded then -- 533
			local cx = ovW * 0.5 -- 546
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 547
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 548
			local bh = isPortrait and 44 or 50 -- 549
			local step = bh + 14 -- 550
			if p.paused and not trialEnded then -- 550
				rectZones[#rectZones + 1] = { -- 552
					id = "trial:resume", -- 552
					rect = Rect(cx - bw * 0.5, cy + step * 0.8, bw, bh) -- 552
				} -- 552
			end -- 552
			rectZones[#rectZones + 1] = { -- 554
				id = "trial:retry", -- 554
				rect = Rect(cx - bw * 0.5, cy - bh * 0.2, bw, bh) -- 554
			} -- 554
			rectZones[#rectZones + 1] = { -- 555
				id = "trial:title", -- 555
				rect = Rect(cx - bw * 0.5, cy - step * 1.2, bw, bh) -- 555
			} -- 555
		elseif trialHasOffers and trial ~= nil then -- 555
			local count = #trial.offers -- 557
			local cardW = isPortrait and math.min( -- 558
				114, -- 558
				math.floor((ovW - 44) / math.max(1, count) - 10) -- 558
			) or 216 -- 558
			local cardH = isPortrait and 52 or 62 -- 559
			local gap = isPortrait and 10 or 18 -- 560
			local totalW = count * cardW + (count - 1) * gap -- 561
			local startX = (ovW - totalW) * 0.5 -- 562
			local y = (isPortrait and vp.deckH * 0.52 or ovH * 0.48) - cardH * 0.5 -- 563
			local i = 0 -- 564
			do -- 564
				i = 0 -- 565
				while i < count do -- 565
					rectZones[#rectZones + 1] = { -- 566
						id = "talent:" .. tostring(i), -- 567
						rect = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 568
					} -- 568
					i = i + 1 -- 565
				end -- 565
			end -- 565
			if not isPortrait then -- 565
				rectZones[#rectZones + 1] = { -- 572
					id = "pause", -- 572
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 572
				} -- 572
			end -- 572
		elseif not isPortrait then -- 572
			rectZones[#rectZones + 1] = { -- 575
				id = "pause", -- 575
				rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 575
			} -- 575
			rectZones[#rectZones + 1] = { -- 576
				id = "retry", -- 576
				rect = Rect(ovW - safeR - 210, ovH - safeT - 64, 92, 46) -- 576
			} -- 576
		end -- 576
	end -- 576
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 576
		local interactMeta = deriveInteractActionMeta( -- 582
			p, -- 582
			prompt or deriveWorldPrompt(p), -- 582
			cartNearby, -- 582
			router.cartGripLatched -- 582
		) -- 582
		if isPortrait then -- 582
			local u = unitPortrait * sc -- 585
			local rightX = ovW - safeR - math.floor(68 * u + 0.5) -- 586
			local bottomY = math.max( -- 587
				safeB + math.floor(70 * u + 0.5), -- 587
				vp.deckH * 0.4 -- 587
			) -- 587
			local postY = math.min( -- 588
				vp.deckH - 26, -- 588
				stickDefaultY + stickMaxR + math.floor(42 * u + 0.5) -- 588
			) -- 588
			bottleCancelCenter = { -- 589
				x = rightX - math.floor(14 * u + 0.5), -- 589
				y = bottomY + math.floor(10 * u + 0.5), -- 589
				r = math.floor(34 * u + 0.5) -- 589
			} -- 589
			if not p.childMode then -- 589
				local cw = math.floor(86 * u + 0.5) -- 593
				local ch = math.floor(32 * u + 0.5) -- 594
				buttons[#buttons + 1] = { -- 595
					id = "cover", -- 596
					x = stickDefaultX, -- 597
					y = postY, -- 598
					r = 24 * u, -- 599
					shape = "pill", -- 600
					toggle = true, -- 601
					rect = Rect(stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch), -- 602
					label = router.coverToggled and "离掩体" or "贴掩体", -- 603
					accent = "cyan", -- 604
					active = router.coverToggled or p.coverHug, -- 605
					highlighted = p.coverNear and not router.coverToggled, -- 606
					progress = 0, -- 607
					dimmed = not p.coverNear and not router.coverToggled -- 608
				} -- 608
				buttons[#buttons + 1] = { -- 612
					id = "fire", -- 613
					x = rightX, -- 614
					y = bottomY + math.floor(8 * u + 0.5), -- 615
					r = math.floor(36 * u + 0.5), -- 616
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 617
					subLabel = "拖瞄", -- 618
					accent = "rouge", -- 619
					active = router:isButtonHeld("fire"), -- 620
					highlighted = p.reloadPendingEffect ~= "", -- 621
					progress = 0, -- 622
					dimmed = p.gripping -- 623
				} -- 623
				local nearLedge = isNearLowLedgeForButton(p) -- 625
				buttons[#buttons + 1] = { -- 626
					id = "jump", -- 627
					x = rightX - math.floor(84 * u + 0.5), -- 628
					y = bottomY - math.floor(16 * u + 0.5), -- 629
					r = math.floor(28 * u + 0.5), -- 630
					label = nearLedge and "翻越" or "翻滚", -- 631
					accent = "cyan", -- 632
					active = router:isButtonHeld("jump"), -- 633
					highlighted = nearLedge, -- 634
					progress = 0, -- 635
					dimmed = p.gripping -- 636
				} -- 636
				buttons[#buttons + 1] = { -- 638
					id = "interact", -- 639
					x = rightX - math.floor(10 * u + 0.5), -- 640
					y = bottomY + math.floor(88 * u + 0.5), -- 641
					r = math.floor(30 * u + 0.5), -- 642
					label = interactMeta.label, -- 643
					subLabel = interactMeta.subLabel, -- 644
					accent = interactMeta.urgent and "rouge" or "amber", -- 645
					active = router:isButtonHeld("interact"), -- 646
					highlighted = interactMeta.available, -- 647
					progress = interactMeta.progress, -- 648
					dimmed = not interactMeta.available -- 649
				} -- 649
				if isPlayMode and p.archive.artifactOwned then -- 649
					local eq = p.equippedWeapon == "time_shuttler" -- 652
					buttons[#buttons + 1] = { -- 653
						id = "artifact", -- 654
						x = rightX - math.floor(90 * u + 0.5), -- 655
						y = bottomY + math.floor(68 * u + 0.5), -- 656
						r = math.floor(24 * u + 0.5), -- 657
						label = eq and "收器" or "穿梭", -- 658
						accent = "amber", -- 659
						active = eq, -- 660
						highlighted = eq, -- 661
						progress = 0, -- 662
						dimmed = false -- 663
					} -- 663
				end -- 663
			else -- 663
				local pw = math.floor(68 * u + 0.5) -- 668
				local ph = math.floor(32 * u + 0.5) -- 669
				buttons[#buttons + 1] = { -- 670
					id = "crouch", -- 671
					x = stickDefaultX - math.floor(38 * u + 0.5), -- 672
					y = postY, -- 673
					r = 22 * u, -- 674
					shape = "pill", -- 675
					toggle = true, -- 676
					rect = Rect( -- 677
						stickDefaultX - math.floor(38 * u + 0.5) - pw * 0.5, -- 677
						postY - ph * 0.5, -- 677
						pw, -- 677
						ph -- 677
					), -- 677
					label = router.crouchToggled and "起身" or "蹲伏", -- 678
					accent = "emerald", -- 679
					active = router.crouchToggled or p.player.crouch, -- 680
					highlighted = p.scavChase and not p.player.crouch, -- 681
					progress = 0, -- 682
					dimmed = false -- 683
				} -- 683
				buttons[#buttons + 1] = { -- 685
					id = "cover", -- 686
					x = stickDefaultX + math.floor(38 * u + 0.5), -- 687
					y = postY, -- 688
					r = 22 * u, -- 689
					shape = "pill", -- 690
					toggle = true, -- 691
					rect = Rect( -- 692
						stickDefaultX + math.floor(38 * u + 0.5) - pw * 0.5, -- 692
						postY - ph * 0.5, -- 692
						pw, -- 692
						ph -- 692
					), -- 692
					label = router.slowToggled and "常步" or "轻步", -- 693
					accent = "silk", -- 694
					active = router.slowToggled, -- 695
					highlighted = false, -- 696
					progress = 0, -- 697
					dimmed = false -- 698
				} -- 698
				buttons[#buttons + 1] = { -- 702
					id = "jump", -- 703
					x = rightX, -- 704
					y = bottomY + math.floor(8 * u + 0.5), -- 705
					r = math.floor(32 * u + 0.5), -- 706
					label = "跳跃", -- 707
					accent = "amber", -- 708
					active = router:isButtonHeld("jump"), -- 709
					highlighted = false, -- 710
					progress = 0, -- 711
					dimmed = p.gripping -- 712
				} -- 712
				buttons[#buttons + 1] = { -- 714
					id = "interact", -- 715
					x = rightX - math.floor(8 * u + 0.5), -- 716
					y = bottomY + math.floor(86 * u + 0.5), -- 717
					r = math.floor(31 * u + 0.5), -- 718
					label = interactMeta.label, -- 719
					subLabel = interactMeta.subLabel, -- 720
					accent = interactMeta.urgent and "rouge" or "amber", -- 721
					active = router:isButtonHeld("interact"), -- 722
					highlighted = interactMeta.available, -- 723
					progress = interactMeta.progress, -- 724
					dimmed = not interactMeta.available -- 725
				} -- 725
				if canBottleAim then -- 725
					buttons[#buttons + 1] = { -- 728
						id = "bottle", -- 729
						x = rightX - math.floor(86 * u + 0.5), -- 730
						y = bottomY + math.floor(46 * u + 0.5), -- 731
						r = math.floor(32 * u + 0.5), -- 732
						label = "投瓶", -- 733
						subLabel = "拖瞄", -- 734
						accent = "amber", -- 735
						active = router:isButtonHeld("bottle"), -- 736
						highlighted = true, -- 737
						progress = math.min(1, p.aimHold / 0.12), -- 738
						dimmed = false -- 739
					} -- 739
				end -- 739
			end -- 739
		else -- 739
			local rightX = ovW - safeR - 92 * sc -- 745
			local bottomY = safeB + 110 * sc -- 746
			bottleCancelCenter = {x = rightX - 14 * sc, y = bottomY + 14 * sc, r = 44 * sc} -- 747
			if not p.childMode then -- 747
				buttons[#buttons + 1] = { -- 750
					id = "fire", -- 751
					x = rightX, -- 752
					y = bottomY + 12 * sc, -- 753
					r = 45 * sc, -- 754
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 755
					subLabel = "拖瞄", -- 756
					accent = "rouge", -- 757
					active = router:isButtonHeld("fire"), -- 758
					highlighted = p.reloadPendingEffect ~= "", -- 759
					progress = 0, -- 760
					dimmed = p.gripping -- 761
				} -- 761
				local nearLedge = isNearLowLedgeForButton(p) -- 763
				buttons[#buttons + 1] = { -- 764
					id = "jump", -- 765
					x = rightX - 116 * sc, -- 766
					y = bottomY - 8 * sc, -- 767
					r = 34 * sc, -- 768
					label = nearLedge and "翻越" or "翻滚", -- 769
					accent = "cyan", -- 770
					active = router:isButtonHeld("jump"), -- 771
					highlighted = nearLedge, -- 772
					progress = 0, -- 773
					dimmed = p.gripping -- 774
				} -- 774
				buttons[#buttons + 1] = { -- 776
					id = "cover", -- 777
					x = rightX - 120 * sc, -- 778
					y = bottomY + 94 * sc, -- 779
					r = 32 * sc, -- 780
					label = router.coverToggled and "离掩" or "掩体", -- 781
					accent = "cyan", -- 782
					active = router.coverToggled, -- 783
					highlighted = p.coverNear and not router.coverToggled, -- 784
					progress = 0, -- 785
					dimmed = not p.coverNear and not router.coverToggled -- 786
				} -- 786
				buttons[#buttons + 1] = { -- 788
					id = "interact", -- 789
					x = rightX - 10 * sc, -- 790
					y = bottomY + 122 * sc, -- 791
					r = 36 * sc, -- 792
					label = interactMeta.label, -- 793
					subLabel = interactMeta.subLabel, -- 794
					accent = interactMeta.urgent and "rouge" or "amber", -- 795
					active = router:isButtonHeld("interact"), -- 796
					highlighted = interactMeta.available, -- 797
					progress = interactMeta.progress, -- 798
					dimmed = not interactMeta.available -- 799
				} -- 799
				if isPlayMode and p.archive.artifactOwned then -- 799
					local eq = p.equippedWeapon == "time_shuttler" -- 802
					buttons[#buttons + 1] = { -- 803
						id = "artifact", -- 804
						x = rightX - 112 * sc, -- 805
						y = bottomY + 184 * sc, -- 806
						r = 27 * sc, -- 807
						label = eq and "收器" or "穿梭", -- 808
						accent = "amber", -- 809
						active = eq, -- 810
						highlighted = eq, -- 811
						progress = 0, -- 812
						dimmed = false -- 813
					} -- 813
				end -- 813
			else -- 813
				buttons[#buttons + 1] = { -- 817
					id = "jump", -- 818
					x = rightX, -- 819
					y = bottomY + 12 * sc, -- 820
					r = 38 * sc, -- 821
					label = "跳跃", -- 822
					accent = "amber", -- 823
					active = router:isButtonHeld("jump"), -- 824
					highlighted = false, -- 825
					progress = 0, -- 826
					dimmed = p.gripping -- 827
				} -- 827
				buttons[#buttons + 1] = { -- 829
					id = "crouch", -- 830
					x = rightX - 106 * sc, -- 831
					y = bottomY - 6 * sc, -- 832
					r = 34 * sc, -- 833
					label = router.crouchToggled and "起身" or "蹲伏", -- 834
					accent = "emerald", -- 835
					active = router.crouchToggled or p.player.crouch, -- 836
					highlighted = p.scavChase and not p.player.crouch, -- 837
					progress = 0, -- 838
					dimmed = false -- 839
				} -- 839
				buttons[#buttons + 1] = { -- 841
					id = "cover", -- 842
					x = rightX - 196 * sc, -- 843
					y = bottomY - 16 * sc, -- 844
					r = 29 * sc, -- 845
					label = router.slowToggled and "常步" or "轻步", -- 846
					accent = "silk", -- 847
					active = router.slowToggled, -- 848
					highlighted = false, -- 849
					progress = 0, -- 850
					dimmed = false -- 851
				} -- 851
				buttons[#buttons + 1] = { -- 853
					id = "interact", -- 854
					x = rightX - 12 * sc, -- 855
					y = bottomY + 114 * sc, -- 856
					r = 36 * sc, -- 857
					label = interactMeta.label, -- 858
					subLabel = interactMeta.subLabel, -- 859
					accent = interactMeta.urgent and "rouge" or "amber", -- 860
					active = router:isButtonHeld("interact"), -- 861
					highlighted = interactMeta.available, -- 862
					progress = interactMeta.progress, -- 863
					dimmed = not interactMeta.available -- 864
				} -- 864
				if canBottleAim then -- 864
					buttons[#buttons + 1] = { -- 867
						id = "bottle", -- 868
						x = rightX - 114 * sc, -- 869
						y = bottomY + 98 * sc, -- 870
						r = 38 * sc, -- 871
						label = "投瓶", -- 872
						subLabel = "拖瞄", -- 873
						accent = "amber", -- 874
						active = router:isButtonHeld("bottle"), -- 875
						highlighted = true, -- 876
						progress = math.min(1, p.aimHold / 0.12), -- 877
						dimmed = false -- 878
					} -- 878
				end -- 878
			end -- 878
		end -- 878
	end -- 878
	local enemyTargets = canShoot and p ~= nil and (isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH)) or ({}) -- 886
	local playerScreenX = vp.stageW * 0.5 -- 892
	local playerScreenY = vp.stageH * 0.38 -- 893
	if p ~= nil then -- 893
		if isPlayMode and params.cam ~= nil then -- 893
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 896
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 897
		else -- 897
			playerScreenX = vp.stageW * 0.45 -- 899
			playerScreenY = vp.stageH * 0.36 -- 900
		end -- 900
	end -- 900
	local ctx = { -- 904
		viewport = vp, -- 905
		overlayScale = overlayScale, -- 906
		overlayActive = overlayActive, -- 907
		allowAutoGameplayTouch = allowAutoGameplayTouch, -- 908
		allowMouseOnOverlay = allowMouseOnOverlay, -- 909
		modal = modal, -- 910
		gameplayActive = gameplayActive, -- 911
		cutsceneBlocking = cutsceneBlocking, -- 912
		childMode = p ~= nil and p.childMode, -- 913
		allowDepth = allowDepth, -- 914
		canShoot = canShoot, -- 915
		canBottleAim = canBottleAim, -- 916
		cartNearby = cartNearby, -- 917
		cartGripping = p ~= nil and p.gripping, -- 918
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 919
		coverNear = p ~= nil and p.coverNear, -- 920
		playerRolling = p ~= nil and p.player.rollT > 0, -- 921
		inLowArch = p ~= nil and isInLowArch(p), -- 922
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 923
		playerFacing = p ~= nil and p.player.facing or 1, -- 924
		playerScreenX = playerScreenX, -- 925
		playerScreenY = playerScreenY, -- 926
		enemyTargets = enemyTargets, -- 927
		stickZoneMaxX = stickZoneMaxX, -- 928
		stickZoneMaxY = stickZoneMaxY, -- 929
		stickDefaultX = stickDefaultX, -- 930
		stickDefaultY = stickDefaultY, -- 931
		stickMaxR = stickMaxR, -- 932
		stickFixedOrigin = isPortrait, -- 933
		buttons = buttons, -- 934
		rectZones = rectZones, -- 935
		bottleCancelCenter = bottleCancelCenter -- 936
	} -- 936
	self.lastContext = ctx -- 939
	router:setFrameContext(ctx, params.dt) -- 940
	return ctx -- 941
end -- 242
function TouchControls.prototype.render(self, router) -- 945
	self.deckDraw:clear() -- 946
	self.padDraw:clear() -- 947
	self.padInkDraw:clear() -- 948
	self.padGlow:clear() -- 949
	self.padArt:beginFrame() -- 950
	self.texts:beginFrame() -- 951
	local ctx = self.lastContext -- 953
	if ctx == nil or not ctx.overlayActive and not ctx.viewport.isPortrait then -- 953
		self.padArt:endFrame() -- 955
		self.texts:endFrame() -- 956
		return -- 957
	end -- 957
	local vp = ctx.viewport -- 960
	local sc = math.max(0.25, ctx.overlayScale) -- 961
	self.overlayRoot.scaleX = sc -- 962
	self.overlayRoot.scaleY = sc -- 963
	local ovW = vp.fullW / sc -- 965
	local ovH = vp.fullH / sc -- 966
	local baseAlpha = router.settings.touchOpacity -- 967
	if vp.isPortrait then -- 967
		self:drawPortraitFrame(ctx, ovW, ovH) -- 971
	end -- 971
	if not ctx.overlayActive then -- 971
		self.padArt:endFrame() -- 975
		self.texts:endFrame() -- 976
		return -- 977
	end -- 977
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 977
		local rx = ovW * 0.5 -- 982
		local ry = vp.isPortrait and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 983
		drawSilkVeil( -- 984
			self.padDraw, -- 984
			self.padArt, -- 984
			"touch_restart_veil", -- 984
			rx, -- 984
			ry, -- 984
			230, -- 984
			36, -- 984
			PALETTE.inkWash, -- 984
			0.78 * baseAlpha, -- 984
			1 -- 984
		) -- 984
		drawHairline( -- 985
			self.padInkDraw, -- 985
			self.padArt, -- 985
			"touch_restart_line", -- 985
			rx, -- 985
			ry + 16, -- 985
			180, -- 985
			PALETTE.amber, -- 985
			0.52 * baseAlpha, -- 985
			true, -- 985
			2 -- 985
		) -- 985
		self.texts:put( -- 986
			"xs", -- 986
			"轻触屏幕再次启程", -- 986
			rx, -- 986
			ry, -- 986
			toColor(PALETTE.amberCore), -- 986
			0.5, -- 986
			0.5, -- 986
			"Center", -- 986
			1.6, -- 986
			0.94, -- 986
			0.08 -- 986
		) -- 986
	end -- 986
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 986
		self:drawTrialZones(ctx, baseAlpha) -- 991
	end -- 991
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 991
		self:drawStick(router, ctx, baseAlpha) -- 996
	end -- 996
	self:drawButtons(router, ctx, baseAlpha) -- 1000
	local bottleDrag = router:getBottleDragVisual() -- 1003
	if bottleDrag.active then -- 1003
		local cx = bottleDrag.cancelX -- 1005
		local cy = bottleDrag.cancelY -- 1006
		local cr = bottleDrag.cancelR -- 1007
		local hot = bottleDrag.cancelHover -- 1008
		fillCirclePoly( -- 1009
			self.padDraw, -- 1010
			cx, -- 1011
			cy, -- 1012
			cr, -- 1013
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 1014
			0, -- 1015
			nil, -- 1016
			22 -- 1017
		) -- 1017
		drawRingArc( -- 1019
			self.padInkDraw, -- 1019
			cx, -- 1019
			cy, -- 1019
			cr, -- 1019
			0, -- 1019
			TWO_PI, -- 1019
			hot and 2.2 or 1.3, -- 1019
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 1019
			22 -- 1019
		) -- 1019
		self.texts:put( -- 1020
			"xs", -- 1020
			hot and "松手取消" or "拖此取消", -- 1020
			cx, -- 1020
			cy, -- 1020
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 1020
			0.5, -- 1020
			0.5, -- 1020
			"Center", -- 1020
			0.8, -- 1020
			0.96, -- 1020
			0.08 -- 1020
		) -- 1020
	end -- 1020
	self.padArt:endFrame() -- 1023
	self.texts:endFrame() -- 1024
end -- 945
function TouchControls.prototype.drawPortraitFrame(self, ctx, w, h) -- 1027
	local vp = ctx.viewport -- 1028
	local topY = vp.stageY + vp.stageH -- 1029
	if topY < h then -- 1029
		self.deckDraw:drawRect( -- 1032
			Rect(0, topY, w, h - topY), -- 1032
			toColor(PALETTE.inkVoid, 252) -- 1032
		) -- 1032
		self.deckDraw:drawSegment( -- 1033
			Vec2(0, topY), -- 1033
			Vec2(w, topY), -- 1033
			1, -- 1033
			toColor(PALETTE.silkDim, 140) -- 1033
		) -- 1033
		local labelY = topY + (h - topY) * 0.5 -- 1034
		self.texts:put( -- 1035
			"xs", -- 1035
			"向西守望 · 掌机竖屏", -- 1035
			vp.safe.left + 12, -- 1035
			labelY, -- 1035
			toColor(PALETTE.amberCore), -- 1035
			0, -- 1035
			0.5, -- 1035
			"Left", -- 1035
			0.8, -- 1035
			0.88, -- 1035
			0.08 -- 1035
		) -- 1035
	end -- 1035
	if vp.stageX > 0 then -- 1035
		self.deckDraw:drawRect( -- 1039
			Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 1039
			toColor(PALETTE.inkVoid, 255) -- 1039
		) -- 1039
		self.deckDraw:drawRect( -- 1040
			Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 1040
			toColor(PALETTE.inkVoid, 255) -- 1040
		) -- 1040
	end -- 1040
	if vp.deckH > 0 then -- 1040
		fillVGradRect( -- 1044
			self.deckDraw, -- 1044
			0, -- 1044
			0, -- 1044
			w, -- 1044
			vp.deckH, -- 1044
			toColor(PALETTE.voidDark, 255), -- 1044
			toColor(PALETTE.inkWash, 255) -- 1044
		) -- 1044
		self.deckDraw:drawSegment( -- 1045
			Vec2(0, vp.deckH), -- 1045
			Vec2(w, vp.deckH), -- 1045
			1.2, -- 1045
			toColor(PALETTE.silkLine, 165) -- 1045
		) -- 1045
		self.deckDraw:drawSegment( -- 1046
			Vec2(18, vp.deckH - 4), -- 1046
			Vec2(w - 18, vp.deckH - 4), -- 1046
			0.6, -- 1046
			toColor(PALETTE.silkDim, 85) -- 1046
		) -- 1046
		drawDiamond( -- 1047
			self.padInkDraw, -- 1047
			w * 0.5, -- 1047
			vp.deckH, -- 1047
			5, -- 1047
			5, -- 1047
			toColor(PALETTE.rouge, 220), -- 1047
			0.9, -- 1047
			toColor(PALETTE.silkLine, 180) -- 1047
		) -- 1047
		local footY = math.max(vp.safe.bottom + 14, 16) -- 1049
		local p = self.lastPlay -- 1050
		local inOverlayModal = p ~= nil and (p.reloadOpen or p.craftBench.active) -- 1051
		local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or p ~= nil and p.paused) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 1052
		self.texts:put( -- 1059
			"xs", -- 1059
			hint, -- 1059
			w * 0.5, -- 1059
			footY, -- 1059
			toColor(PALETTE.textDim), -- 1059
			0.5, -- 1059
			0.5, -- 1059
			"Center", -- 1059
			0.8, -- 1059
			0.78, -- 1059
			0.06 -- 1059
		) -- 1059
	end -- 1059
end -- 1027
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 1063
	local stick = router:getStickVisual() -- 1064
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 1065
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 1068
	fillCirclePoly( -- 1070
		self.padDraw, -- 1071
		stick.originX, -- 1072
		stick.originY, -- 1073
		stick.radius, -- 1074
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 1075
		0, -- 1076
		nil, -- 1077
		28 -- 1078
	) -- 1078
	drawRingArc( -- 1080
		self.padInkDraw, -- 1080
		stick.originX, -- 1080
		stick.originY, -- 1080
		stick.radius, -- 1080
		0, -- 1080
		TWO_PI, -- 1080
		stick.active and 1.5 or 1, -- 1080
		toColor(ringCol, 168 * stickAlpha), -- 1080
		28 -- 1080
	) -- 1080
	if stick.allowDepth then -- 1080
		local dOff = stick.radius - 10 -- 1083
		self.padInkDraw:drawDot( -- 1084
			Vec2(stick.originX, stick.originY + dOff), -- 1084
			2.1, -- 1084
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1084
		) -- 1084
		self.padInkDraw:drawDot( -- 1085
			Vec2(stick.originX, stick.originY - dOff), -- 1085
			2.1, -- 1085
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 1085
		) -- 1085
		self.padInkDraw:drawDot( -- 1086
			Vec2(stick.originX - dOff, stick.originY), -- 1086
			2.1, -- 1086
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1086
		) -- 1086
		self.padInkDraw:drawDot( -- 1087
			Vec2(stick.originX + dOff, stick.originY), -- 1087
			2.1, -- 1087
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 1087
		) -- 1087
	elseif ctx.childMode then -- 1087
		drawRingArc( -- 1089
			self.padInkDraw, -- 1090
			stick.originX, -- 1091
			stick.originY, -- 1092
			stick.radius * 0.56, -- 1093
			0, -- 1094
			TWO_PI, -- 1095
			0.9, -- 1096
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 1097
			20 -- 1098
		) -- 1098
	end -- 1098
	local knobR = math.max(16, stick.radius * 0.36) -- 1102
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 1103
	if stick.active then -- 1103
		fillRadialGlow( -- 1105
			self.padGlow, -- 1105
			stick.knobX, -- 1105
			stick.knobY, -- 1105
			knobR * 1.45, -- 1105
			knobR * 1.45, -- 1105
			toColor(knobAccent, 48 * stickAlpha), -- 1105
			Color(0, 0, 0, 0), -- 1105
			12 -- 1105
		) -- 1105
	end -- 1105
	fillCirclePoly( -- 1107
		self.padDraw, -- 1108
		stick.knobX, -- 1109
		stick.knobY, -- 1110
		knobR, -- 1111
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 1112
		1.3, -- 1113
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 1114
		22 -- 1115
	) -- 1115
	drawBlossomDot( -- 1117
		self.padInkDraw, -- 1117
		self.padArt, -- 1117
		"touch_stick_dot", -- 1117
		stick.knobX, -- 1117
		stick.knobY, -- 1117
		stick.active and 11 or 7, -- 1117
		knobAccent, -- 1117
		0.85 * stickAlpha, -- 1117
		4 -- 1117
	) -- 1117
	if stick.slowZone then -- 1117
		self.texts:put( -- 1119
			"xs", -- 1119
			"轻步", -- 1119
			stick.originX, -- 1119
			stick.originY + stick.radius + 14, -- 1119
			toColor(PALETTE.emerald), -- 1119
			0.5, -- 1119
			0.5, -- 1119
			"Center", -- 1119
			1, -- 1119
			0.9, -- 1119
			0.08 -- 1119
		) -- 1119
	end -- 1119
end -- 1063
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 1123
	local bottleDrag = router:getBottleDragVisual() -- 1124
	local fireStick = router:getFireStickVisual() -- 1125
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 1126
	local i = 0 -- 1128
	do -- 1128
		i = 0 -- 1129
		while i < #ctx.buttons do -- 1129
			do -- 1129
				local b = ctx.buttons[i + 1] -- 1130
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 1131
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 1131
					bAlpha = bAlpha * 0.25 -- 1133
				end -- 1133
				local col = accentPalette(b.accent) -- 1135
				local core = accentCore(b.accent) -- 1136
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 1137
				if b.shape == "pill" and b.rect ~= nil then -- 1137
					local r = b.rect -- 1140
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 1141
					self.padDraw:drawRoundedRect( -- 1144
						r, -- 1145
						6, -- 1146
						fillCol, -- 1147
						b.active and 1.4 or 1, -- 1148
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 1149
					) -- 1149
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 1149
						local icX = r.x + 22 -- 1152
						local icY = r.y + r.height * 0.5 -- 1153
						drawRingArc( -- 1154
							self.padInkDraw, -- 1154
							icX, -- 1154
							icY, -- 1154
							9, -- 1154
							0, -- 1154
							TWO_PI, -- 1154
							1, -- 1154
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 1154
							16 -- 1154
						) -- 1154
						self.padInkDraw:drawSegment( -- 1155
							Vec2(icX - 2.6, icY - 3.6), -- 1155
							Vec2(icX - 2.6, icY + 3.6), -- 1155
							1.5, -- 1155
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1155
						) -- 1155
						self.padInkDraw:drawSegment( -- 1156
							Vec2(icX + 2.6, icY - 3.6), -- 1156
							Vec2(icX + 2.6, icY + 3.6), -- 1156
							1.5, -- 1156
							toColor(PALETTE.textBright, 225 * bAlpha) -- 1156
						) -- 1156
						self.texts:put( -- 1157
							"xs", -- 1157
							b.label, -- 1157
							r.x + r.width * 0.5 + 10, -- 1157
							icY, -- 1157
							toColor(PALETTE.textBright), -- 1157
							0.5, -- 1157
							0.5, -- 1157
							"Center", -- 1157
							1, -- 1157
							0.94 * bAlpha, -- 1157
							0.08 -- 1157
						) -- 1157
					else -- 1157
						if b.toggle and b.active then -- 1157
							drawDiamond( -- 1160
								self.padInkDraw, -- 1160
								r.x + 11, -- 1160
								r.y + r.height * 0.5, -- 1160
								3.8, -- 1160
								3.8, -- 1160
								toColor(col, 235) -- 1160
							) -- 1160
						end -- 1160
						self.texts:put( -- 1162
							"xs", -- 1163
							b.label, -- 1164
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 1165
							r.y + r.height * 0.5, -- 1166
							toColor(b.active and core or PALETTE.textBright), -- 1167
							0.5, -- 1168
							0.5, -- 1169
							"Center", -- 1170
							0.6, -- 1171
							math.min(1, bAlpha + 0.08), -- 1172
							0.08 -- 1173
						) -- 1173
					end -- 1173
					goto __continue94 -- 1176
				end -- 1176
				if b.active or b.highlighted then -- 1176
					fillRadialGlow( -- 1180
						self.padGlow, -- 1181
						b.x, -- 1182
						b.y, -- 1183
						b.r * 1.38, -- 1184
						b.r * 1.38, -- 1185
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 1186
						Color(col.r, col.g, col.b, 0), -- 1187
						12 -- 1188
					) -- 1188
				end -- 1188
				fillCirclePoly( -- 1192
					self.padDraw, -- 1193
					b.x, -- 1194
					b.y, -- 1195
					b.r, -- 1196
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 1197
					0, -- 1198
					nil, -- 1199
					24 -- 1200
				) -- 1200
				drawRingArc( -- 1202
					self.padInkDraw, -- 1203
					b.x, -- 1204
					b.y, -- 1205
					b.r, -- 1206
					0, -- 1207
					TWO_PI, -- 1208
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 1209
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 1210
					24 -- 1211
				) -- 1211
				drawRingArc( -- 1213
					self.padInkDraw, -- 1214
					b.x, -- 1215
					b.y, -- 1216
					b.r - 4.2, -- 1217
					0, -- 1218
					TWO_PI, -- 1219
					0.7, -- 1220
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 1221
					20 -- 1222
				) -- 1222
				if b.progress > 0.02 then -- 1222
					drawRingArc( -- 1226
						self.padInkDraw, -- 1227
						b.x, -- 1228
						b.y, -- 1229
						b.r + 4, -- 1230
						HALF_PI, -- 1231
						-TWO_PI * math.min(1, b.progress), -- 1232
						2.6, -- 1233
						toColor(PALETTE.amberCore, 240), -- 1234
						28 -- 1235
					) -- 1235
				end -- 1235
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 1239
				self.texts:put( -- 1240
					fontKind, -- 1241
					b.label, -- 1242
					b.x, -- 1243
					hasSub and b.y + 6 or b.y, -- 1244
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 1245
					0.5, -- 1246
					0.5, -- 1247
					"Center", -- 1248
					0.6, -- 1249
					bAlpha, -- 1250
					0.08 -- 1251
				) -- 1251
				if hasSub and b.subLabel ~= nil then -- 1251
					self.texts:put( -- 1254
						"xs", -- 1255
						b.subLabel, -- 1256
						b.x, -- 1257
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 1258
						toColor(b.active and core or PALETTE.textDim), -- 1259
						0.5, -- 1260
						0.5, -- 1261
						"Center", -- 1262
						0.4, -- 1263
						bAlpha * 0.85, -- 1264
						0.06 -- 1265
					) -- 1265
				end -- 1265
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 1265
					self.padInkDraw:drawSegment( -- 1270
						Vec2(fireStick.originX, fireStick.originY), -- 1270
						Vec2(fireStick.knobX, fireStick.knobY), -- 1270
						1.4, -- 1270
						toColor(PALETTE.rouge, 190) -- 1270
					) -- 1270
					fillCirclePoly( -- 1271
						self.padDraw, -- 1271
						fireStick.knobX, -- 1271
						fireStick.knobY, -- 1271
						12, -- 1271
						toColor(PALETTE.rouge, 210), -- 1271
						1.2, -- 1271
						toColor(PALETTE.crimsonCore, 240), -- 1271
						16 -- 1271
					) -- 1271
				end -- 1271
			end -- 1271
			::__continue94:: -- 1271
			i = i + 1 -- 1129
		end -- 1129
	end -- 1129
end -- 1123
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 1276
	local ____opt_15 = self.lastRun -- 1276
	local trial = ____opt_15 and ____opt_15.trial -- 1277
	local i = 0 -- 1278
	do -- 1278
		i = 0 -- 1279
		while i < #ctx.rectZones do -- 1279
			local z = ctx.rectZones[i + 1] -- 1280
			local r = z.rect -- 1281
			local cx = r.x + r.width * 0.5 -- 1282
			local cy = r.y + r.height * 0.5 -- 1283
			if z.id == "pause" or z.id == "retry" then -- 1283
				self.padDraw:drawRoundedRect( -- 1285
					r, -- 1285
					6, -- 1285
					toColor(PALETTE.inkWash, 185 * alpha), -- 1285
					1.2, -- 1285
					toColor(PALETTE.silkLine, 175 * alpha) -- 1285
				) -- 1285
				self.texts:put( -- 1286
					"xs", -- 1286
					z.id == "pause" and "暂停" or "重开", -- 1286
					cx, -- 1286
					cy, -- 1286
					toColor(PALETTE.textBright), -- 1286
					0.5, -- 1286
					0.5, -- 1286
					"Center", -- 1286
					0.8, -- 1286
					0.94, -- 1286
					0.08 -- 1286
				) -- 1286
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 1286
				local idx = __TS__Number(string.sub(z.id, 8)) -- 1288
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 1289
				self.padDraw:drawRoundedRect( -- 1290
					r, -- 1290
					6, -- 1290
					toColor(PALETTE.panelBgDeep, 235), -- 1290
					1.6, -- 1290
					toColor(PALETTE.amber, 225) -- 1290
				) -- 1290
				self.texts:put( -- 1291
					"xs", -- 1291
					(tostring(idx + 1) .. " · ") .. tName, -- 1291
					cx, -- 1291
					cy, -- 1291
					toColor(PALETTE.amberCore), -- 1291
					0.5, -- 1291
					0.5, -- 1291
					"Center", -- 1291
					0.6, -- 1291
					0.98, -- 1291
					0.08 -- 1291
				) -- 1291
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1291
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1293
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1294
				self.padDraw:drawRoundedRect( -- 1295
					r, -- 1295
					6, -- 1295
					toColor(PALETTE.panelBgDeep, 235), -- 1295
					1.5, -- 1295
					toColor(border, 220) -- 1295
				) -- 1295
				self.texts:put( -- 1296
					"sm", -- 1296
					label, -- 1296
					cx, -- 1296
					cy, -- 1296
					toColor(PALETTE.textBright), -- 1296
					0.5, -- 1296
					0.5, -- 1296
					"Center", -- 1296
					1, -- 1296
					0.98, -- 1296
					0.08 -- 1296
				) -- 1296
			end -- 1296
			i = i + 1 -- 1279
		end -- 1279
	end -- 1279
end -- 1276
return ____exports -- 1276