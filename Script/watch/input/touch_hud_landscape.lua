-- [ts]: touch_hud_landscape.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local BlendFunc = ____Dora.BlendFunc -- 13
local Color = ____Dora.Color -- 13
local DrawNode = ____Dora.DrawNode -- 13
local Node = ____Dora.Node -- 13
local Rect = ____Dora.Rect -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____aim_assist = require("Script.watch.input.aim_assist") -- 16
local collectAimTargets = ____aim_assist.collectAimTargets -- 16
local projectMuzzle = ____aim_assist.projectMuzzle -- 16
local ____touch_interact_meta = require("Script.watch.input.touch_interact_meta") -- 24
local deriveInteractActionMeta = ____touch_interact_meta.deriveInteractActionMeta -- 24
local ____adapter = require("Script.watch.fe.adapter") -- 26
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 26
local ____assets = require("Script.watch.fe.assets") -- 27
local AssetSlotHost = ____assets.AssetSlotHost -- 27
local ____textpool = require("Script.watch.fe.ui.textpool") -- 29
local TextPool = ____textpool.TextPool -- 29
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 31
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 31
local ____theme = require("Script.watch.fe.theme") -- 33
local PALETTE = ____theme.PALETTE -- 34
local drawBlossomDot = ____theme.drawBlossomDot -- 36
local drawDiamond = ____theme.drawDiamond -- 37
local drawHairline = ____theme.drawHairline -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 39
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local toColor = ____theme.toColor -- 41
local visualTextWidth = ____theme.visualTextWidth -- 42
local TWO_PI = math.pi * 2 -- 45
local HALF_PI = math.pi * 0.5 -- 46
local STICK_BASE_R_LANDSCAPE = 64 -- 47
local function accentPalette(accent) -- 72
	if accent == "cyan" then -- 73
		return PALETTE.cyan -- 73
	end -- 73
	if accent == "amber" then -- 74
		return PALETTE.amber -- 74
	end -- 74
	if accent == "rouge" then -- 75
		return PALETTE.rouge -- 75
	end -- 75
	if accent == "emerald" then -- 76
		return PALETTE.emerald -- 76
	end -- 76
	return PALETTE.silkLine -- 77
end -- 72
local function accentCore(accent) -- 80
	if accent == "cyan" then -- 81
		return PALETTE.cyanCore -- 81
	end -- 81
	if accent == "amber" then -- 82
		return PALETTE.amberCore -- 82
	end -- 82
	if accent == "rouge" then -- 83
		return PALETTE.crimsonCore -- 83
	end -- 83
	if accent == "emerald" then -- 84
		return PALETTE.emerald -- 84
	end -- 84
	return PALETTE.textBright -- 85
end -- 80
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 88
	if segments == nil then -- 97
		segments = 28 -- 97
	end -- 97
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 99
		return -- 99
	end -- 99
	local n = math.max( -- 100
		4, -- 100
		math.ceil(segments * math.min( -- 100
			1, -- 100
			math.abs(sweepRad) / TWO_PI -- 100
		)) -- 100
	) -- 100
	local prevX = cx + math.cos(startRad) * r -- 101
	local prevY = cy + math.sin(startRad) * r -- 102
	local i = 1 -- 103
	do -- 103
		i = 1 -- 104
		while i <= n do -- 104
			local a = startRad + sweepRad * i / n -- 105
			local nx = cx + math.cos(a) * r -- 106
			local ny = cy + math.sin(a) * r -- 107
			draw:drawSegment( -- 108
				Vec2(prevX, prevY), -- 108
				Vec2(nx, ny), -- 108
				thickness, -- 108
				color -- 108
			) -- 108
			prevX = nx -- 109
			prevY = ny -- 110
			i = i + 1 -- 104
		end -- 104
	end -- 104
end -- 88
local function fillCirclePoly(draw, cx, cy, r, fill, borderWidth, borderColor, segments) -- 114
	if borderWidth == nil then -- 120
		borderWidth = 0 -- 120
	end -- 120
	if segments == nil then -- 122
		segments = 26 -- 122
	end -- 122
	local pts = {} -- 124
	local i = 0 -- 125
	do -- 125
		i = 0 -- 126
		while i < segments do -- 126
			local a = TWO_PI * i / segments -- 127
			pts[#pts + 1] = Vec2( -- 128
				cx + math.cos(a) * r, -- 128
				cy + math.sin(a) * r -- 128
			) -- 128
			i = i + 1 -- 126
		end -- 126
	end -- 126
	if borderWidth > 0 and borderColor ~= nil then -- 130
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 131
	else -- 131
		draw:drawPolygon(pts, fill) -- 133
	end -- 133
end -- 114
local function isNearLowLedgeForButton(p) -- 137
	if p.childMode then -- 138
		return false -- 138
	end -- 138
	local a = p.player -- 139
	local probeX = a.x + a.facing * 26 -- 140
	local i = 0 -- 141
	do -- 141
		i = 0 -- 142
		while i < #p.boxes do -- 142
			do -- 142
				local b = p.boxes[i + 1] -- 143
				if b.broken == true or b.hidden == true then -- 144
					goto __continue24 -- 144
				end -- 144
				local h = b.y1 - b.y0 -- 145
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 146
					return true -- 148
				end -- 148
			end -- 148
			::__continue24:: -- 148
			i = i + 1 -- 142
		end -- 142
	end -- 142
	return false -- 151
end -- 137
local function isInLowArch(p) -- 154
	local arch = p.room.arch -- 155
	if arch.h <= 0 then -- 156
		return false -- 156
	end -- 156
	return p.player.x >= arch.x0 - 10 and p.player.x <= arch.x1 + 10 and p.player.y <= arch.y + arch.h -- 157
end -- 154
____exports.TouchControls = __TS__Class() -- 160
local TouchControls = ____exports.TouchControls -- 160
TouchControls.name = "TouchControls" -- 160
function TouchControls.prototype.____constructor(self, parent, portraitDelegate) -- 178
	self.lastMode = 1 -- 171
	self.lastScreen = "title" -- 172
	self.time = 0 -- 175
	self.hasDrawn = false -- 176
	self.portraitDelegate = portraitDelegate -- 179
	self.overlayRoot = Node() -- 181
	self.overlayRoot.order = 60 -- 182
	self.overlayRoot:addTo(parent) -- 183
	if portraitDelegate ~= nil then -- 185
		local deck = DrawNode() -- 186
		deck.order = 0 -- 187
		deck:addTo(self.overlayRoot) -- 188
		self.deckDraw = deck -- 189
	end -- 189
	self.padDraw = DrawNode() -- 192
	self.padDraw.order = 2 -- 193
	self.padDraw:addTo(self.overlayRoot) -- 194
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 196
	self.padInkDraw = DrawNode() -- 198
	self.padInkDraw.order = 5 -- 199
	self.padInkDraw:addTo(self.overlayRoot) -- 200
	local additive = BlendFunc("SrcAlpha", "One") -- 202
	self.padGlow = DrawNode() -- 203
	self.padGlow.order = 7 -- 204
	self.padGlow.blendFunc = additive -- 205
	self.padGlow:addTo(self.overlayRoot) -- 206
	self.texts = __TS__New(TextPool, self.overlayRoot, 10, {xs = 24, sm = 12}) -- 209
end -- 178
function TouchControls.prototype.getAllocatedLabelCount(self) -- 212
	return self.texts.totalAllocated -- 213
end -- 212
function TouchControls.prototype.getLayoutSummary(self, router) -- 216
	local buttonIds = {} -- 226
	local zoneIds = {} -- 227
	if self.lastContext ~= nil then -- 228
		local i = 0 -- 229
		do -- 229
			i = 0 -- 230
			while i < #self.lastContext.buttons do -- 230
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 231
				i = i + 1 -- 230
			end -- 230
		end -- 230
		do -- 230
			i = 0 -- 233
			while i < #self.lastContext.rectZones do -- 233
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 234
				i = i + 1 -- 233
			end -- 233
		end -- 233
	end -- 233
	local ____buttonIds_6 = buttonIds -- 238
	local ____zoneIds_7 = zoneIds -- 239
	local ____temp_0 -- 240
	if self.lastContext ~= nil then -- 240
		____temp_0 = self.lastContext.viewport.isPortrait -- 240
	else -- 240
		____temp_0 = false -- 240
	end -- 240
	local ____temp_1 -- 241
	if self.lastContext ~= nil then -- 241
		____temp_1 = self.lastContext.overlayActive -- 241
	else -- 241
		____temp_1 = false -- 241
	end -- 241
	local ____temp_2 -- 242
	if router ~= nil then -- 242
		____temp_2 = router.crouchToggled -- 242
	else -- 242
		____temp_2 = false -- 242
	end -- 242
	local ____temp_3 -- 243
	if router ~= nil then -- 243
		____temp_3 = router.slowToggled -- 243
	else -- 243
		____temp_3 = false -- 243
	end -- 243
	local ____temp_4 -- 244
	if router ~= nil then -- 244
		____temp_4 = router.coverToggled -- 244
	else -- 244
		____temp_4 = false -- 244
	end -- 244
	local ____temp_5 -- 245
	if router ~= nil then -- 245
		____temp_5 = router.cartGripLatched -- 245
	else -- 245
		____temp_5 = false -- 245
	end -- 245
	return { -- 237
		buttonIds = ____buttonIds_6, -- 238
		zoneIds = ____zoneIds_7, -- 239
		isPortrait = ____temp_0, -- 240
		overlayActive = ____temp_1, -- 241
		crouchToggled = ____temp_2, -- 242
		slowToggled = ____temp_3, -- 243
		coverToggled = ____temp_4, -- 244
		cartGripLatch = ____temp_5 -- 245
	} -- 245
end -- 216
function TouchControls.prototype.syncContext(self, params) -- 249
	self.time = self.time + math.min( -- 250
		0.05, -- 250
		math.max(0, params.dt) -- 250
	) -- 250
	self.lastMode = params.mode -- 251
	self.lastScreen = params.screen -- 252
	self.lastPlay = params.play -- 253
	self.lastRun = params.run -- 254
	local vp = params.viewport -- 256
	local p = params.play -- 257
	local router = params.router -- 258
	local pDel = self.portraitDelegate -- 259
	local isPortrait = pDel ~= nil and vp.isPortrait -- 260
	local overlayScale = isPortrait and 1 or vp.uiScale -- 261
	local ovW = vp.fullW / math.max(0.25, overlayScale) -- 262
	local ovH = vp.fullH / math.max(0.25, overlayScale) -- 263
	local safeL = vp.safe.left / math.max(0.25, overlayScale) -- 264
	local safeR = vp.safe.right / math.max(0.25, overlayScale) -- 265
	local safeT = vp.safe.top / math.max(0.25, overlayScale) -- 266
	local safeB = vp.safe.bottom / math.max(0.25, overlayScale) -- 267
	local overlayActive = params.overlayActive -- 269
	local sc = router.settings.touchScale -- 270
	local isPlayMode = params.mode == 1 and params.screen == "play" and p ~= nil -- 272
	local gameplayActive = isPlayMode -- 273
	local talentModalOpen = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and p.talentModalActive and #p:getStoryTalentOffers() > 0 -- 274
	local escortSummaryOpen = isPlayMode and p ~= nil and not p.paused and p.escortFailed -- 276
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or talentModalOpen or escortSummaryOpen) -- 278
	local ____temp_8 -- 280
	if isPlayMode and p ~= nil then -- 280
		____temp_8 = isCutsceneBlockingPlay(p) -- 281
	else -- 281
		____temp_8 = false -- 282
	end -- 282
	local cutsceneBlocking = ____temp_8 -- 280
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 284
	local cart = p ~= nil and p.room.cart or nil -- 286
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 287
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 289
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 290
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 291
	local buttons = {} -- 294
	local rectZones = {} -- 295
	local pGeom = isPortrait and pDel ~= nil and pDel:computeStickGeom( -- 297
		vp, -- 298
		ovW, -- 298
		safeL, -- 298
		safeB, -- 298
		sc -- 298
	) or nil -- 299
	local stickMaxR = pGeom ~= nil and pGeom.stickMaxR or STICK_BASE_R_LANDSCAPE * sc -- 300
	local stickDefaultX = pGeom ~= nil and pGeom.stickDefaultX or safeL + 126 * sc -- 301
	local stickDefaultY = pGeom ~= nil and pGeom.stickDefaultY or safeB + 126 * sc -- 302
	local stickZoneMaxX = pGeom ~= nil and pGeom.stickZoneMaxX or ovW * 0.46 -- 303
	local stickZoneMaxY = pGeom ~= nil and pGeom.stickZoneMaxY or ovH - 110 -- 304
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 306
	if overlayActive then -- 309
		if isPortrait and pDel ~= nil then -- 310
			pDel:pushTopButtons( -- 311
				buttons, -- 312
				vp, -- 312
				ovW, -- 312
				ovH, -- 312
				safeR, -- 312
				gameplayActive, -- 312
				p, -- 312
				params.isMuted, -- 313
				params.isFullscreen, -- 313
				params.canToggleFullscreen -- 313
			) -- 313
		elseif isPlayMode and not modal then -- 315
			local px = ovW - safeR - 112 -- 316
			local py = ovH - safeT - 66 -- 317
			buttons[#buttons + 1] = { -- 318
				id = "pause", -- 319
				x = px + 46, -- 320
				y = py + 21, -- 321
				r = 28, -- 322
				shape = "pill", -- 323
				rect = Rect(px, py, 94, 42), -- 324
				label = "暂歇", -- 325
				accent = "silk", -- 326
				active = false, -- 327
				highlighted = false, -- 328
				progress = 0, -- 329
				dimmed = false -- 330
			} -- 330
			if params.showWebTopPills then -- 332
				local mw = 58 -- 333
				local mx = px - mw - 10 -- 334
				buttons[#buttons + 1] = { -- 335
					id = "mute", -- 336
					x = mx + mw * 0.5, -- 337
					y = py + 21, -- 338
					r = 22, -- 339
					shape = "pill", -- 340
					rect = Rect(mx, py + 4, mw, 34), -- 341
					label = params.isMuted and "静音" or "有声", -- 342
					accent = params.isMuted and "rouge" or "cyan", -- 343
					active = params.isMuted, -- 344
					highlighted = false, -- 345
					progress = 0, -- 346
					dimmed = false -- 347
				} -- 347
				if params.canToggleFullscreen then -- 349
					local fw = 58 -- 350
					local fx = mx - fw - 8 -- 351
					buttons[#buttons + 1] = { -- 352
						id = "fullscreen", -- 353
						x = fx + fw * 0.5, -- 354
						y = py + 21, -- 355
						r = 22, -- 356
						shape = "pill", -- 357
						rect = Rect(fx, py + 4, fw, 34), -- 358
						label = params.isFullscreen and "窗口" or "全屏", -- 359
						accent = "silk", -- 360
						active = params.isFullscreen, -- 361
						highlighted = false, -- 362
						progress = 0, -- 363
						dimmed = false -- 364
					} -- 364
				end -- 364
			end -- 364
		end -- 364
	end -- 364
	if isPortrait and pDel ~= nil and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and (p.paused or talentModalOpen or escortSummaryOpen)) then -- 372
		pDel:pushMenuNavButtons( -- 374
			buttons, -- 374
			vp, -- 374
			ovW, -- 374
			safeL, -- 374
			safeR, -- 374
			safeB -- 374
		) -- 374
	end -- 374
	local prompt -- 378
	local function pushStageRect(zoneId, b) -- 379
		local vx = vp.stageX + b.x * vp.uiScale -- 380
		local vy = vp.stageY + b.y * vp.uiScale -- 381
		local vw = b.width * vp.uiScale -- 382
		local vh = b.height * vp.uiScale -- 383
		rectZones[#rectZones + 1] = { -- 384
			id = zoneId, -- 385
			rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 386
		} -- 386
	end -- 379
	if isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not cutsceneBlocking then -- 394
		if p.escortFailed and params.escortDeathBoxes ~= nil then -- 395
			pushStageRect("escort:retry", params.escortDeathBoxes.retry) -- 396
			pushStageRect("escort:title", params.escortDeathBoxes.title) -- 397
		else -- 397
			if params.ledgerButtonBox ~= nil and params.ledgerButtonBox.width > 0 then -- 399
				pushStageRect("ledger:toggle", params.ledgerButtonBox) -- 400
			end -- 400
			if #params.storyTalentBoxes > 0 then -- 402
				local ti = 0 -- 404
				do -- 404
					ti = 0 -- 405
					while ti < #params.storyTalentBoxes do -- 405
						pushStageRect( -- 406
							"talent:" .. tostring(ti), -- 406
							params.storyTalentBoxes[ti + 1] -- 406
						) -- 406
						ti = ti + 1 -- 405
					end -- 405
				end -- 405
				if isPortrait and pDel ~= nil and overlayActive and vp.deckH >= 150 then -- 409
					local cnt = math.min(3, #params.storyTalentBoxes) -- 410
					local padX = math.max(10, safeL + 10) -- 411
					local gap = 8 -- 412
					local bw = math.floor((ovW - padX * 2 - gap * (cnt - 1)) / cnt) -- 413
					local bh = 32 -- 414
					local by = vp.deckH - bh - 10 -- 415
					local di = 0 -- 416
					do -- 416
						di = 0 -- 417
						while di < cnt do -- 417
							local bx = padX + di * (bw + gap) -- 418
							rectZones[#rectZones + 1] = { -- 419
								id = "talent:" .. tostring(di), -- 420
								rect = Rect(bx, by, bw, bh) -- 421
							} -- 421
							di = di + 1 -- 417
						end -- 417
					end -- 417
				end -- 417
			end -- 417
		end -- 417
	end -- 417
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 428
		prompt = deriveWorldPrompt(p) -- 429
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 430
			local keyW = math.max( -- 432
				24, -- 432
				visualTextWidth(prompt.keyTag, 15) + 16 -- 432
			) -- 432
			local labelW = visualTextWidth(prompt.label, 15) -- 433
			local pillW = keyW + labelW + 24 -- 434
			local padX = math.max(115, pillW * 0.5 + 24) -- 435
			local sxUi = math.max( -- 436
				padX + vp.safeUi.left, -- 436
				math.min( -- 436
					vp.uiW - padX - vp.safeUi.right, -- 436
					params.cam:sx(prompt.x) / vp.uiScale -- 436
				) -- 436
			) -- 436
			local syUi = math.max( -- 437
				96 + vp.safeUi.bottom, -- 437
				math.min( -- 437
					vp.uiH - 110 - vp.safeUi.top, -- 437
					params.cam:sy(prompt.y) / vp.uiScale -- 437
				) -- 437
			) -- 437
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 438
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 439
			rectZones[#rectZones + 1] = { -- 440
				id = "worldPrompt", -- 441
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 442
			} -- 442
		end -- 442
	end -- 442
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 452
		local cx = ovW * 0.5 -- 454
		local cy = safeB + 46 -- 455
		buttons[#buttons + 1] = { -- 456
			id = "nav_confirm", -- 457
			x = cx, -- 458
			y = cy, -- 459
			r = 26, -- 460
			shape = "pill", -- 461
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 462
			label = "继续 · 归程", -- 463
			accent = "amber", -- 464
			active = false, -- 465
			highlighted = true, -- 466
			progress = 0, -- 467
			dimmed = false -- 468
		} -- 468
	end -- 468
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 473
		local interactMeta = deriveInteractActionMeta( -- 474
			p, -- 474
			prompt or deriveWorldPrompt(p), -- 474
			cartNearby, -- 474
			router.cartGripLatched -- 474
		) -- 474
		local nearLedge = isNearLowLedgeForButton(p) -- 475
		if isPortrait and pDel ~= nil and pGeom ~= nil then -- 477
			bottleCancelCenter = pDel:pushActionButtons( -- 478
				buttons, -- 479
				vp, -- 479
				ovW, -- 479
				safeR, -- 479
				safeB, -- 479
				pGeom, -- 479
				sc, -- 479
				p, -- 480
				isPlayMode, -- 480
				canBottleAim, -- 480
				nearLedge, -- 480
				interactMeta, -- 480
				router -- 480
			) -- 480
		else -- 480
			local rightX = ovW - safeR - 92 * sc -- 483
			local bottomY = safeB + 110 * sc -- 484
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 485
			if not p.childMode then -- 487
				buttons[#buttons + 1] = { -- 488
					id = "fire", -- 489
					x = rightX, -- 490
					y = bottomY + 12 * sc, -- 491
					r = 45 * sc, -- 492
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 493
					subLabel = "拖瞄", -- 494
					accent = "rouge", -- 495
					active = router:isButtonHeld("fire"), -- 496
					highlighted = p.reloadPendingEffect ~= "", -- 497
					progress = 0, -- 498
					dimmed = p.gripping -- 499
				} -- 499
				buttons[#buttons + 1] = { -- 501
					id = "jump", -- 502
					x = rightX - 116 * sc, -- 503
					y = bottomY - 8 * sc, -- 504
					r = 34 * sc, -- 505
					label = nearLedge and "翻越" or "翻滚", -- 506
					accent = "cyan", -- 507
					active = router:isButtonHeld("jump"), -- 508
					highlighted = nearLedge, -- 509
					progress = 0, -- 510
					dimmed = p.gripping -- 511
				} -- 511
				buttons[#buttons + 1] = { -- 513
					id = "cover", -- 514
					x = rightX - 120 * sc, -- 515
					y = bottomY + 94 * sc, -- 516
					r = 32 * sc, -- 517
					label = router.coverToggled and "离掩" or "掩体", -- 518
					accent = "cyan", -- 519
					active = router.coverToggled, -- 520
					highlighted = p.coverNear and not router.coverToggled, -- 521
					progress = 0, -- 522
					dimmed = not p.coverNear and not router.coverToggled -- 523
				} -- 523
				buttons[#buttons + 1] = { -- 525
					id = "interact", -- 526
					x = rightX - 10 * sc, -- 527
					y = bottomY + 122 * sc, -- 528
					r = 36 * sc, -- 529
					label = interactMeta.label, -- 530
					subLabel = interactMeta.subLabel, -- 531
					accent = interactMeta.urgent and "rouge" or "amber", -- 532
					active = router:isButtonHeld("interact"), -- 533
					highlighted = interactMeta.available, -- 534
					progress = interactMeta.progress, -- 535
					dimmed = not interactMeta.available -- 536
				} -- 536
				if isPlayMode and p.archive.artifactOwned then -- 538
					local eq = p.equippedWeapon == "time_shuttler" -- 539
					buttons[#buttons + 1] = { -- 540
						id = "artifact", -- 541
						x = rightX - 112 * sc, -- 542
						y = bottomY + 184 * sc, -- 543
						r = 27 * sc, -- 544
						label = eq and "收器" or "穿梭", -- 545
						accent = "amber", -- 546
						active = eq, -- 547
						highlighted = eq, -- 548
						progress = 0, -- 549
						dimmed = false -- 550
					} -- 550
				end -- 550
			else -- 550
				buttons[#buttons + 1] = { -- 554
					id = "jump", -- 555
					x = rightX, -- 556
					y = bottomY + 12 * sc, -- 557
					r = 38 * sc, -- 558
					label = "跳跃", -- 559
					accent = "amber", -- 560
					active = router:isButtonHeld("jump"), -- 561
					highlighted = false, -- 562
					progress = 0, -- 563
					dimmed = p.gripping -- 564
				} -- 564
				buttons[#buttons + 1] = { -- 566
					id = "crouch", -- 567
					x = rightX - 106 * sc, -- 568
					y = bottomY - 6 * sc, -- 569
					r = 34 * sc, -- 570
					label = router.crouchToggled and "起身" or "蹲伏", -- 571
					accent = "emerald", -- 572
					active = router.crouchToggled or p.player.crouch, -- 573
					highlighted = p.scavChase and not p.player.crouch, -- 574
					progress = 0, -- 575
					dimmed = false -- 576
				} -- 576
				buttons[#buttons + 1] = { -- 578
					id = "cover", -- 579
					x = rightX - 196 * sc, -- 580
					y = bottomY - 16 * sc, -- 581
					r = 29 * sc, -- 582
					label = router.slowToggled and "常步" or "轻步", -- 583
					accent = "silk", -- 584
					active = router.slowToggled, -- 585
					highlighted = false, -- 586
					progress = 0, -- 587
					dimmed = false -- 588
				} -- 588
				buttons[#buttons + 1] = { -- 590
					id = "interact", -- 591
					x = rightX - 12 * sc, -- 592
					y = bottomY + 114 * sc, -- 593
					r = 36 * sc, -- 594
					label = interactMeta.label, -- 595
					subLabel = interactMeta.subLabel, -- 596
					accent = interactMeta.urgent and "rouge" or "amber", -- 597
					active = router:isButtonHeld("interact"), -- 598
					highlighted = interactMeta.available, -- 599
					progress = interactMeta.progress, -- 600
					dimmed = not interactMeta.available -- 601
				} -- 601
				if canBottleAim then -- 603
					buttons[#buttons + 1] = { -- 604
						id = "bottle", -- 605
						x = rightX - 114 * sc, -- 606
						y = bottomY + 98 * sc, -- 607
						r = 38 * sc, -- 608
						label = "投瓶", -- 609
						subLabel = "拖瞄", -- 610
						accent = "amber", -- 611
						active = router:isButtonHeld("bottle"), -- 612
						highlighted = true, -- 613
						progress = math.min(1, p.aimHold / 0.12), -- 614
						dimmed = false -- 615
					} -- 615
				end -- 615
			end -- 615
		end -- 615
	end -- 615
	local enemyTargets -- 623
	if params.enemyTargets ~= nil then -- 624
		enemyTargets = params.enemyTargets -- 625
	elseif canShoot and router.settings.aimAssist and p ~= nil then -- 626
		enemyTargets = collectAimTargets(p, params.cam, vp.stageW, vp.stageH) -- 627
	else -- 627
		enemyTargets = {} -- 629
	end -- 629
	local muzzle = p ~= nil and projectMuzzle(p, params.cam) or nil -- 632
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 633
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 634
	local ctx = { -- 636
		viewport = vp, -- 637
		overlayScale = overlayScale, -- 638
		overlayActive = overlayActive, -- 639
		allowAutoGameplayTouch = params.allowAutoGameplayTouch, -- 640
		allowMouseOnOverlay = params.allowMouseOnOverlay, -- 641
		modal = modal, -- 642
		gameplayActive = gameplayActive, -- 643
		cutsceneBlocking = cutsceneBlocking, -- 644
		childMode = p ~= nil and p.childMode, -- 645
		allowDepth = allowDepth, -- 646
		canShoot = canShoot, -- 647
		canBottleAim = canBottleAim, -- 648
		cartNearby = cartNearby, -- 649
		cartGripping = p ~= nil and p.gripping, -- 650
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 651
		coverNear = p ~= nil and p.coverNear, -- 652
		playerRolling = p ~= nil and p.player.rollT > 0, -- 653
		inLowArch = p ~= nil and isInLowArch(p), -- 654
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 655
		playerFacing = p ~= nil and p.player.facing or 1, -- 656
		playerScreenX = playerScreenX, -- 657
		playerScreenY = playerScreenY, -- 658
		enemyTargets = enemyTargets, -- 659
		stickZoneMaxX = stickZoneMaxX, -- 660
		stickZoneMaxY = stickZoneMaxY, -- 661
		stickDefaultX = stickDefaultX, -- 662
		stickDefaultY = stickDefaultY, -- 663
		stickMaxR = stickMaxR, -- 664
		stickFixedOrigin = isPortrait, -- 665
		buttons = buttons, -- 666
		rectZones = rectZones, -- 667
		bottleCancelCenter = bottleCancelCenter -- 668
	} -- 668
	self.lastContext = ctx -- 671
	router:setFrameContext(ctx, params.dt) -- 672
	return ctx -- 673
end -- 249
function TouchControls.prototype.render(self, router) -- 676
	local ctx = self.lastContext -- 677
	local pDel = self.portraitDelegate -- 678
	local portraitVisible = pDel ~= nil and ctx ~= nil and ctx.viewport.isPortrait -- 679
	local visible = ctx ~= nil and (ctx.overlayActive or portraitVisible) -- 680
	if not visible then -- 682
		if not self.hasDrawn then -- 683
			return -- 684
		end -- 684
		local ____opt_13 = self.deckDraw -- 686
		if ____opt_13 ~= nil then -- 686
			____opt_13:clear() -- 686
		end -- 686
		self.padDraw:clear() -- 687
		self.padInkDraw:clear() -- 688
		self.padGlow:clear() -- 689
		self.padArt:beginFrame() -- 690
		self.padArt:endFrame() -- 691
		self.texts:hideAll() -- 692
		self.hasDrawn = false -- 693
		return -- 694
	end -- 694
	self.hasDrawn = true -- 697
	local ____opt_15 = self.deckDraw -- 698
	if ____opt_15 ~= nil then -- 698
		____opt_15:clear() -- 698
	end -- 698
	self.padDraw:clear() -- 699
	self.padInkDraw:clear() -- 700
	self.padGlow:clear() -- 701
	self.padArt:beginFrame() -- 702
	self.texts:beginFrame() -- 703
	local vp = ctx.viewport -- 705
	local sc = math.max(0.25, ctx.overlayScale) -- 706
	self.overlayRoot.scaleX = sc -- 707
	self.overlayRoot.scaleY = sc -- 708
	local ovW = vp.fullW / sc -- 710
	local ovH = vp.fullH / sc -- 711
	local baseAlpha = router.settings.touchOpacity -- 712
	if portraitVisible and pDel ~= nil and self.deckDraw ~= nil then -- 714
		pDel:drawFrame( -- 715
			self.deckDraw, -- 715
			self.padInkDraw, -- 715
			self.texts, -- 715
			ctx, -- 715
			self.lastPlay, -- 715
			ovW, -- 715
			ovH -- 715
		) -- 715
	end -- 715
	if not ctx.overlayActive then -- 718
		self.padArt:endFrame() -- 719
		self.texts:endFrame() -- 720
		return -- 721
	end -- 721
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 724
		local rx = ovW * 0.5 -- 725
		local ry = portraitVisible and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 726
		drawSilkVeil( -- 727
			self.padDraw, -- 727
			self.padArt, -- 727
			"touch_restart_veil", -- 727
			rx, -- 727
			ry, -- 727
			230, -- 727
			36, -- 727
			PALETTE.inkWash, -- 727
			0.78 * baseAlpha, -- 727
			1 -- 727
		) -- 727
		drawHairline( -- 728
			self.padInkDraw, -- 728
			self.padArt, -- 728
			"touch_restart_line", -- 728
			rx, -- 728
			ry + 16, -- 728
			180, -- 728
			PALETTE.amber, -- 728
			0.52 * baseAlpha, -- 728
			true, -- 728
			2 -- 728
		) -- 728
		self.texts:put( -- 729
			"xs", -- 729
			"轻触屏幕再次启程", -- 729
			rx, -- 729
			ry, -- 729
			toColor(PALETTE.amberCore), -- 729
			0.5, -- 729
			0.5, -- 729
			"Center", -- 729
			1.6, -- 729
			0.94, -- 729
			0.08 -- 729
		) -- 729
	end -- 729
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 733
		self:drawStick(router, ctx, baseAlpha) -- 734
	end -- 734
	self:drawButtons(router, ctx, baseAlpha) -- 737
	local bottleDrag = router:getBottleDragVisual() -- 739
	if bottleDrag.active then -- 740
		local cx = bottleDrag.cancelX -- 741
		local cy = bottleDrag.cancelY -- 742
		local cr = bottleDrag.cancelR -- 743
		local hot = bottleDrag.cancelHover -- 744
		fillCirclePoly( -- 745
			self.padDraw, -- 746
			cx, -- 747
			cy, -- 748
			cr, -- 749
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 750
			0, -- 751
			nil, -- 752
			22 -- 753
		) -- 753
		drawRingArc( -- 755
			self.padInkDraw, -- 755
			cx, -- 755
			cy, -- 755
			cr, -- 755
			0, -- 755
			TWO_PI, -- 755
			hot and 2.2 or 1.3, -- 755
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 755
			22 -- 755
		) -- 755
		self.texts:put( -- 756
			"xs", -- 756
			hot and "松手取消" or "拖此取消", -- 756
			cx, -- 756
			cy, -- 756
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 756
			0.5, -- 756
			0.5, -- 756
			"Center", -- 756
			0.8, -- 756
			0.96, -- 756
			0.08 -- 756
		) -- 756
	end -- 756
	self.padArt:endFrame() -- 759
	self.texts:endFrame() -- 760
end -- 676
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 763
	local stick = router:getStickVisual() -- 764
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 765
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 768
	fillCirclePoly( -- 770
		self.padDraw, -- 771
		stick.originX, -- 772
		stick.originY, -- 773
		stick.radius, -- 774
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 775
		0, -- 776
		nil, -- 777
		28 -- 778
	) -- 778
	drawRingArc( -- 780
		self.padInkDraw, -- 780
		stick.originX, -- 780
		stick.originY, -- 780
		stick.radius, -- 780
		0, -- 780
		TWO_PI, -- 780
		stick.active and 1.5 or 1, -- 780
		toColor(ringCol, 168 * stickAlpha), -- 780
		28 -- 780
	) -- 780
	if stick.allowDepth then -- 782
		local dOff = stick.radius - 10 -- 783
		self.padInkDraw:drawDot( -- 784
			Vec2(stick.originX, stick.originY + dOff), -- 784
			2.1, -- 784
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 784
		) -- 784
		self.padInkDraw:drawDot( -- 785
			Vec2(stick.originX, stick.originY - dOff), -- 785
			2.1, -- 785
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 785
		) -- 785
		self.padInkDraw:drawDot( -- 786
			Vec2(stick.originX - dOff, stick.originY), -- 786
			2.1, -- 786
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 786
		) -- 786
		self.padInkDraw:drawDot( -- 787
			Vec2(stick.originX + dOff, stick.originY), -- 787
			2.1, -- 787
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 787
		) -- 787
	elseif ctx.childMode then -- 788
		drawRingArc( -- 789
			self.padInkDraw, -- 790
			stick.originX, -- 791
			stick.originY, -- 792
			stick.radius * 0.56, -- 793
			0, -- 794
			TWO_PI, -- 795
			0.9, -- 796
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 797
			20 -- 798
		) -- 798
	end -- 798
	local knobR = math.max(16, stick.radius * 0.36) -- 802
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 803
	if stick.active then -- 804
		fillRadialGlow( -- 805
			self.padGlow, -- 805
			stick.knobX, -- 805
			stick.knobY, -- 805
			knobR * 1.45, -- 805
			knobR * 1.45, -- 805
			toColor(knobAccent, 48 * stickAlpha), -- 805
			Color(0, 0, 0, 0), -- 805
			12 -- 805
		) -- 805
	end -- 805
	fillCirclePoly( -- 807
		self.padDraw, -- 808
		stick.knobX, -- 809
		stick.knobY, -- 810
		knobR, -- 811
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 812
		1.3, -- 813
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 814
		22 -- 815
	) -- 815
	drawBlossomDot( -- 817
		self.padInkDraw, -- 817
		self.padArt, -- 817
		"touch_stick_dot", -- 817
		stick.knobX, -- 817
		stick.knobY, -- 817
		stick.active and 11 or 7, -- 817
		knobAccent, -- 817
		0.85 * stickAlpha, -- 817
		4 -- 817
	) -- 817
	if stick.slowZone then -- 818
		self.texts:put( -- 819
			"xs", -- 819
			"轻步", -- 819
			stick.originX, -- 819
			stick.originY + stick.radius + 14, -- 819
			toColor(PALETTE.emerald), -- 819
			0.5, -- 819
			0.5, -- 819
			"Center", -- 819
			1, -- 819
			0.9, -- 819
			0.08 -- 819
		) -- 819
	end -- 819
end -- 763
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 823
	local bottleDrag = router:getBottleDragVisual() -- 824
	local fireStick = router:getFireStickVisual() -- 825
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 826
	local i = 0 -- 828
	do -- 828
		i = 0 -- 829
		while i < #ctx.buttons do -- 829
			do -- 829
				local b = ctx.buttons[i + 1] -- 830
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 831
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 832
					bAlpha = bAlpha * 0.25 -- 833
				end -- 833
				local col = accentPalette(b.accent) -- 835
				local core = accentCore(b.accent) -- 836
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 837
				if b.shape == "pill" and b.rect ~= nil then -- 839
					local r = b.rect -- 840
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 841
					self.padDraw:drawRoundedRect( -- 844
						r, -- 845
						6, -- 846
						fillCol, -- 847
						b.active and 1.4 or 1, -- 848
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 849
					) -- 849
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 851
						local icX = r.x + 22 -- 852
						local icY = r.y + r.height * 0.5 -- 853
						drawRingArc( -- 854
							self.padInkDraw, -- 854
							icX, -- 854
							icY, -- 854
							9, -- 854
							0, -- 854
							TWO_PI, -- 854
							1, -- 854
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 854
							16 -- 854
						) -- 854
						self.padInkDraw:drawSegment( -- 855
							Vec2(icX - 2.6, icY - 3.6), -- 855
							Vec2(icX - 2.6, icY + 3.6), -- 855
							1.5, -- 855
							toColor(PALETTE.textBright, 225 * bAlpha) -- 855
						) -- 855
						self.padInkDraw:drawSegment( -- 856
							Vec2(icX + 2.6, icY - 3.6), -- 856
							Vec2(icX + 2.6, icY + 3.6), -- 856
							1.5, -- 856
							toColor(PALETTE.textBright, 225 * bAlpha) -- 856
						) -- 856
						self.texts:put( -- 857
							"xs", -- 857
							b.label, -- 857
							r.x + r.width * 0.5 + 10, -- 857
							icY, -- 857
							toColor(PALETTE.textBright), -- 857
							0.5, -- 857
							0.5, -- 857
							"Center", -- 857
							1, -- 857
							0.94 * bAlpha, -- 857
							0.08 -- 857
						) -- 857
					else -- 857
						if b.toggle and b.active then -- 859
							drawDiamond( -- 860
								self.padInkDraw, -- 860
								r.x + 11, -- 860
								r.y + r.height * 0.5, -- 860
								3.8, -- 860
								3.8, -- 860
								toColor(col, 235) -- 860
							) -- 860
						end -- 860
						self.texts:put( -- 862
							"xs", -- 863
							b.label, -- 864
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 865
							r.y + r.height * 0.5, -- 866
							toColor(b.active and core or PALETTE.textBright), -- 867
							0.5, -- 868
							0.5, -- 869
							"Center", -- 870
							0.6, -- 871
							math.min(1, bAlpha + 0.08), -- 872
							0.08 -- 873
						) -- 873
					end -- 873
					goto __continue84 -- 876
				end -- 876
				if b.active or b.highlighted then -- 879
					fillRadialGlow( -- 880
						self.padGlow, -- 881
						b.x, -- 882
						b.y, -- 883
						b.r * 1.38, -- 884
						b.r * 1.38, -- 885
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 886
						Color(col.r, col.g, col.b, 0), -- 887
						12 -- 888
					) -- 888
				end -- 888
				fillCirclePoly( -- 892
					self.padDraw, -- 893
					b.x, -- 894
					b.y, -- 895
					b.r, -- 896
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 897
					0, -- 898
					nil, -- 899
					24 -- 900
				) -- 900
				drawRingArc( -- 902
					self.padInkDraw, -- 903
					b.x, -- 904
					b.y, -- 905
					b.r, -- 906
					0, -- 907
					TWO_PI, -- 908
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 909
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 910
					24 -- 911
				) -- 911
				drawRingArc( -- 913
					self.padInkDraw, -- 914
					b.x, -- 915
					b.y, -- 916
					b.r - 4.2, -- 917
					0, -- 918
					TWO_PI, -- 919
					0.7, -- 920
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 921
					20 -- 922
				) -- 922
				if b.progress > 0.02 then -- 925
					drawRingArc( -- 926
						self.padInkDraw, -- 927
						b.x, -- 928
						b.y, -- 929
						b.r + 4, -- 930
						HALF_PI, -- 931
						-TWO_PI * math.min(1, b.progress), -- 932
						2.6, -- 933
						toColor(PALETTE.amberCore, 240), -- 934
						28 -- 935
					) -- 935
				end -- 935
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 939
				self.texts:put( -- 940
					fontKind, -- 941
					b.label, -- 942
					b.x, -- 943
					hasSub and b.y + 6 or b.y, -- 944
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 945
					0.5, -- 946
					0.5, -- 947
					"Center", -- 948
					0.6, -- 949
					bAlpha, -- 950
					0.08 -- 951
				) -- 951
				if hasSub and b.subLabel ~= nil then -- 953
					self.texts:put( -- 954
						"xs", -- 955
						b.subLabel, -- 956
						b.x, -- 957
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 958
						toColor(b.active and core or PALETTE.textDim), -- 959
						0.5, -- 960
						0.5, -- 961
						"Center", -- 962
						0.4, -- 963
						bAlpha * 0.85, -- 964
						0.06 -- 965
					) -- 965
				end -- 965
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 969
					self.padInkDraw:drawSegment( -- 970
						Vec2(fireStick.originX, fireStick.originY), -- 970
						Vec2(fireStick.knobX, fireStick.knobY), -- 970
						1.4, -- 970
						toColor(PALETTE.rouge, 190) -- 970
					) -- 970
					fillCirclePoly( -- 971
						self.padDraw, -- 971
						fireStick.knobX, -- 971
						fireStick.knobY, -- 971
						12, -- 971
						toColor(PALETTE.rouge, 210), -- 971
						1.2, -- 971
						toColor(PALETTE.crimsonCore, 240), -- 971
						16 -- 971
					) -- 971
				end -- 971
			end -- 971
			::__continue84:: -- 971
			i = i + 1 -- 829
		end -- 829
	end -- 829
end -- 823
return ____exports -- 823
