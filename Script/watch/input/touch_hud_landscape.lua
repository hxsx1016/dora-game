-- [ts]: touch_hud_landscape.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 1
local drawTalentGlyph = ____talent_catalog.drawTalentGlyph -- 1
local resolveTalentVisual = ____talent_catalog.resolveTalentVisual -- 1
local ____Dora = require("Dora") -- 14
local BlendFunc = ____Dora.BlendFunc -- 14
local Color = ____Dora.Color -- 14
local DrawNode = ____Dora.DrawNode -- 14
local Node = ____Dora.Node -- 14
local Rect = ____Dora.Rect -- 14
local Vec2 = ____Dora.Vec2 -- 14
local ____aim_assist = require("Script.watch.input.aim_assist") -- 17
local collectAimTargets = ____aim_assist.collectAimTargets -- 17
local projectMuzzle = ____aim_assist.projectMuzzle -- 17
local ____touch_interact_meta = require("Script.watch.input.touch_interact_meta") -- 25
local deriveInteractActionMeta = ____touch_interact_meta.deriveInteractActionMeta -- 25
local ____adapter = require("Script.watch.fe.adapter") -- 27
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 27
local ____assets = require("Script.watch.fe.assets") -- 28
local AssetSlotHost = ____assets.AssetSlotHost -- 28
local ____textpool = require("Script.watch.fe.ui.textpool") -- 30
local TextPool = ____textpool.TextPool -- 30
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 32
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 32
local ____theme = require("Script.watch.fe.theme") -- 34
local PALETTE = ____theme.PALETTE -- 35
local drawBlossomDot = ____theme.drawBlossomDot -- 37
local drawDiamond = ____theme.drawDiamond -- 38
local drawHairline = ____theme.drawHairline -- 39
local drawSilkVeil = ____theme.drawSilkVeil -- 40
local fillRadialGlow = ____theme.fillRadialGlow -- 41
local toColor = ____theme.toColor -- 42
local visualTextWidth = ____theme.visualTextWidth -- 43
local TWO_PI = math.pi * 2 -- 46
local HALF_PI = math.pi * 0.5 -- 47
local STICK_BASE_R_LANDSCAPE = 64 -- 48
local function accentPalette(accent) -- 74
	if accent == "cyan" then -- 74
		return PALETTE.cyan -- 75
	end -- 75
	if accent == "amber" then -- 75
		return PALETTE.amber -- 76
	end -- 76
	if accent == "rouge" then -- 76
		return PALETTE.rouge -- 77
	end -- 77
	if accent == "emerald" then -- 77
		return PALETTE.emerald -- 78
	end -- 78
	return PALETTE.silkLine -- 79
end -- 74
local function accentCore(accent) -- 82
	if accent == "cyan" then -- 82
		return PALETTE.cyanCore -- 83
	end -- 83
	if accent == "amber" then -- 83
		return PALETTE.amberCore -- 84
	end -- 84
	if accent == "rouge" then -- 84
		return PALETTE.crimsonCore -- 85
	end -- 85
	if accent == "emerald" then -- 85
		return PALETTE.emerald -- 86
	end -- 86
	return PALETTE.textBright -- 87
end -- 82
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 90
	if segments == nil then -- 90
		segments = 28 -- 99
	end -- 99
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 99
		return -- 101
	end -- 101
	local n = math.max( -- 102
		4, -- 102
		math.ceil(segments * math.min( -- 102
			1, -- 102
			math.abs(sweepRad) / TWO_PI -- 102
		)) -- 102
	) -- 102
	local prevX = cx + math.cos(startRad) * r -- 103
	local prevY = cy + math.sin(startRad) * r -- 104
	local i = 1 -- 105
	do -- 105
		i = 1 -- 106
		while i <= n do -- 106
			local a = startRad + sweepRad * i / n -- 107
			local nx = cx + math.cos(a) * r -- 108
			local ny = cy + math.sin(a) * r -- 109
			draw:drawSegment( -- 110
				Vec2(prevX, prevY), -- 110
				Vec2(nx, ny), -- 110
				thickness, -- 110
				color -- 110
			) -- 110
			prevX = nx -- 111
			prevY = ny -- 112
			i = i + 1 -- 106
		end -- 106
	end -- 106
end -- 90
local function fillCirclePoly(draw, cx, cy, r, fill, borderWidth, borderColor, segments) -- 116
	if borderWidth == nil then -- 116
		borderWidth = 0 -- 122
	end -- 122
	if segments == nil then -- 122
		segments = 26 -- 124
	end -- 124
	local pts = {} -- 126
	local i = 0 -- 127
	do -- 127
		i = 0 -- 128
		while i < segments do -- 128
			local a = TWO_PI * i / segments -- 129
			pts[#pts + 1] = Vec2( -- 130
				cx + math.cos(a) * r, -- 130
				cy + math.sin(a) * r -- 130
			) -- 130
			i = i + 1 -- 128
		end -- 128
	end -- 128
	if borderWidth > 0 and borderColor ~= nil then -- 128
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 133
	else -- 133
		draw:drawPolygon(pts, fill) -- 135
	end -- 135
end -- 116
local function isNearLowLedgeForButton(p) -- 139
	if p.childMode then -- 139
		return false -- 140
	end -- 140
	local a = p.player -- 141
	local probeX = a.x + a.facing * 26 -- 142
	local i = 0 -- 143
	do -- 143
		i = 0 -- 144
		while i < #p.boxes do -- 144
			do -- 144
				local b = p.boxes[i + 1] -- 145
				if b.broken == true or b.hidden == true then -- 145
					goto __continue24 -- 146
				end -- 146
				local h = b.y1 - b.y0 -- 147
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 147
					return true -- 150
				end -- 150
			end -- 150
			::__continue24:: -- 150
			i = i + 1 -- 144
		end -- 144
	end -- 144
	return false -- 153
end -- 139
local function isInLowArch(p) -- 156
	local arch = p.room.arch -- 157
	if arch.h <= 0 then -- 157
		return false -- 158
	end -- 158
	return p.player.x >= arch.x0 - 10 and p.player.x <= arch.x1 + 10 and p.player.y <= arch.y + arch.h -- 159
end -- 156
____exports.TouchControls = __TS__Class() -- 162
local TouchControls = ____exports.TouchControls -- 162
TouchControls.name = "TouchControls" -- 162
function TouchControls.prototype.____constructor(self, parent, portraitDelegate) -- 179
	self.portraitTalentCards = {} -- 173
	self.lastScreen = "title" -- 174
	self.time = 0 -- 176
	self.hasDrawn = false -- 177
	self.portraitDelegate = portraitDelegate -- 180
	self.overlayRoot = Node() -- 182
	self.overlayRoot.order = 60 -- 183
	self.overlayRoot:addTo(parent) -- 184
	if portraitDelegate ~= nil then -- 184
		local deck = DrawNode() -- 187
		deck.order = 0 -- 188
		deck:addTo(self.overlayRoot) -- 189
		self.deckDraw = deck -- 190
	end -- 190
	self.padDraw = DrawNode() -- 193
	self.padDraw.order = 2 -- 194
	self.padDraw:addTo(self.overlayRoot) -- 195
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 197
	self.padInkDraw = DrawNode() -- 199
	self.padInkDraw.order = 5 -- 200
	self.padInkDraw:addTo(self.overlayRoot) -- 201
	local additive = BlendFunc("SrcAlpha", "One") -- 203
	self.padGlow = DrawNode() -- 204
	self.padGlow.order = 7 -- 205
	self.padGlow.blendFunc = additive -- 206
	self.padGlow:addTo(self.overlayRoot) -- 207
	self.texts = __TS__New(TextPool, self.overlayRoot, 10, {xs = 24, sm = 12}) -- 210
end -- 179
function TouchControls.prototype.getAllocatedLabelCount(self) -- 213
	return self.texts.totalAllocated -- 214
end -- 213
function TouchControls.prototype.getLayoutSummary(self, router) -- 217
	local buttonIds = {} -- 227
	local zoneIds = {} -- 228
	if self.lastContext ~= nil then -- 228
		local i = 0 -- 230
		do -- 230
			i = 0 -- 231
			while i < #self.lastContext.buttons do -- 231
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 232
				i = i + 1 -- 231
			end -- 231
		end -- 231
		do -- 231
			i = 0 -- 234
			while i < #self.lastContext.rectZones do -- 234
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 235
				i = i + 1 -- 234
			end -- 234
		end -- 234
	end -- 234
	local ____buttonIds_6 = buttonIds -- 239
	local ____zoneIds_7 = zoneIds -- 240
	local ____temp_0 -- 241
	if self.lastContext ~= nil then -- 241
		____temp_0 = self.lastContext.viewport.isPortrait -- 241
	else -- 241
		____temp_0 = false -- 241
	end -- 241
	local ____temp_1 -- 242
	if self.lastContext ~= nil then -- 242
		____temp_1 = self.lastContext.overlayActive -- 242
	else -- 242
		____temp_1 = false -- 242
	end -- 242
	local ____temp_2 -- 243
	if router ~= nil then -- 243
		____temp_2 = router.crouchToggled -- 243
	else -- 243
		____temp_2 = false -- 243
	end -- 243
	local ____temp_3 -- 244
	if router ~= nil then -- 244
		____temp_3 = router.slowToggled -- 244
	else -- 244
		____temp_3 = false -- 244
	end -- 244
	local ____temp_4 -- 245
	if router ~= nil then -- 245
		____temp_4 = router.coverToggled -- 245
	else -- 245
		____temp_4 = false -- 245
	end -- 245
	local ____temp_5 -- 246
	if router ~= nil then -- 246
		____temp_5 = router.cartGripLatched -- 246
	else -- 246
		____temp_5 = false -- 246
	end -- 246
	return { -- 238
		buttonIds = ____buttonIds_6, -- 239
		zoneIds = ____zoneIds_7, -- 240
		isPortrait = ____temp_0, -- 241
		overlayActive = ____temp_1, -- 242
		crouchToggled = ____temp_2, -- 243
		slowToggled = ____temp_3, -- 244
		coverToggled = ____temp_4, -- 245
		cartGripLatch = ____temp_5 -- 246
	} -- 246
end -- 217
function TouchControls.prototype.syncContext(self, params) -- 250
	self.time = self.time + math.min( -- 251
		0.05, -- 251
		math.max(0, params.dt) -- 251
	) -- 251
	self.portraitTalentCards = {} -- 252
	self.lastScreen = params.screen -- 253
	self.lastPlay = params.play -- 254
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
	local modal = not isPlayMode or p == nil or p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or p.talentModalActive or params.ledgerOpen == true -- 274
	local cutsceneBlocking = isPlayMode and p ~= nil and isCutsceneBlockingPlay(p) -- 276
	local allowDepth = p ~= nil and p.room.depth ~= nil -- 278
	local cart = p ~= nil and p.room.cart or nil -- 279
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 280
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 282
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 283
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 284
	local buttons = {} -- 287
	local rectZones = {} -- 288
	local pGeom = isPortrait and pDel ~= nil and pDel:computeStickGeom( -- 290
		vp, -- 291
		ovW, -- 291
		safeL, -- 291
		safeB, -- 291
		sc -- 291
	) or nil -- 291
	local stickMaxR = pGeom ~= nil and pGeom.stickMaxR or STICK_BASE_R_LANDSCAPE * sc -- 293
	local stickDefaultX = pGeom ~= nil and pGeom.stickDefaultX or safeL + 126 * sc -- 294
	local stickDefaultY = pGeom ~= nil and pGeom.stickDefaultY or safeB + 126 * sc -- 295
	local stickZoneMaxX = pGeom ~= nil and pGeom.stickZoneMaxX or ovW * 0.46 -- 296
	local stickZoneMaxY = pGeom ~= nil and pGeom.stickZoneMaxY or ovH - 110 -- 297
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 299
	if overlayActive then -- 299
		if isPortrait and pDel ~= nil then -- 299
			pDel:pushTopButtons( -- 304
				buttons, -- 305
				vp, -- 305
				ovW, -- 305
				ovH, -- 305
				safeR, -- 305
				gameplayActive, -- 305
				p, -- 305
				params.isMuted, -- 306
				params.isFullscreen, -- 306
				params.canToggleFullscreen -- 306
			) -- 306
		elseif isPlayMode and not modal then -- 306
			local px = ovW - safeR - 112 -- 309
			local py = ovH - safeT - 66 -- 310
			buttons[#buttons + 1] = { -- 311
				id = "pause", -- 312
				x = px + 46, -- 313
				y = py + 21, -- 314
				r = 28, -- 315
				shape = "pill", -- 316
				rect = Rect(px, py, 94, 42), -- 317
				label = "暂歇", -- 318
				accent = "silk", -- 319
				active = false, -- 320
				highlighted = false, -- 321
				progress = 0, -- 322
				dimmed = false -- 323
			} -- 323
			if params.showWebTopPills then -- 323
				local mw = 58 -- 326
				local mx = px - mw - 10 -- 327
				buttons[#buttons + 1] = { -- 328
					id = "mute", -- 329
					x = mx + mw * 0.5, -- 330
					y = py + 21, -- 331
					r = 22, -- 332
					shape = "pill", -- 333
					rect = Rect(mx, py + 4, mw, 34), -- 334
					label = params.isMuted and "静音" or "有声", -- 335
					accent = params.isMuted and "rouge" or "cyan", -- 336
					active = params.isMuted, -- 337
					highlighted = false, -- 338
					progress = 0, -- 339
					dimmed = false -- 340
				} -- 340
				if params.canToggleFullscreen then -- 340
					local fw = 58 -- 343
					local fx = mx - fw - 8 -- 344
					buttons[#buttons + 1] = { -- 345
						id = "fullscreen", -- 346
						x = fx + fw * 0.5, -- 347
						y = py + 21, -- 348
						r = 22, -- 349
						shape = "pill", -- 350
						rect = Rect(fx, py + 4, fw, 34), -- 351
						label = params.isFullscreen and "窗口" or "全屏", -- 352
						accent = "silk", -- 353
						active = params.isFullscreen, -- 354
						highlighted = false, -- 355
						progress = 0, -- 356
						dimmed = false -- 357
					} -- 357
				end -- 357
			end -- 357
		end -- 357
	end -- 357
	if isPortrait and pDel ~= nil and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 357
		pDel:pushMenuNavButtons( -- 367
			buttons, -- 367
			vp, -- 367
			ovW, -- 367
			safeL, -- 367
			safeR, -- 367
			safeB -- 367
		) -- 367
	end -- 367
	local prompt -- 371
	if isPlayMode and p ~= nil and not p.paused and not p.reloadOpen and not p.craftBench.active and not cutsceneBlocking then -- 371
		local function addZone(id, b) -- 373
			rectZones[#rectZones + 1] = { -- 374
				id = id, -- 374
				rect = Rect((vp.stageX + b.x * vp.uiScale) / overlayScale, (vp.stageY + b.y * vp.uiScale) / overlayScale, b.width * vp.uiScale / overlayScale, b.height * vp.uiScale / overlayScale) -- 374
			} -- 374
		end -- 373
		if not p.escortFailed and not params.ledgerOpen and params.ledgerBox and params.ledgerBox.width > 0 then -- 373
			addZone("ledger:toggle", params.ledgerBox) -- 379
		end -- 379
		if params.escortDeathBoxes then -- 379
			addZone("escort:retry", params.escortDeathBoxes.retry) -- 382
			addZone("escort:title", params.escortDeathBoxes.title) -- 383
		end -- 383
		do -- 383
			local i = 0 -- 385
			while i < #params.storyTalentBoxes do -- 385
				addZone( -- 386
					"talent:" .. tostring(i), -- 386
					params.storyTalentBoxes[i + 1] -- 386
				) -- 386
				i = i + 1 -- 385
			end -- 385
		end -- 385
		if isPortrait and overlayActive and vp.deckH >= 220 then -- 385
			local offers = p:getStoryTalentOffers() -- 389
			local count = math.min(#offers, #params.storyTalentBoxes) -- 390
			if count > 0 then -- 390
				local padX = math.max(12, safeL + 10) -- 392
				local gap = 8 -- 393
				local availW = ovW - padX * 2 -- 394
				local cardW = (availW - gap * (count - 1)) / count -- 395
				local cardH = 34 -- 396
				local cardY = vp.deckH - cardH - 8 -- 397
				do -- 397
					local ti = 0 -- 398
					while ti < count do -- 398
						local r = Rect(padX + ti * (cardW + gap), cardY, cardW, cardH) -- 399
						rectZones[#rectZones + 1] = { -- 400
							id = "talent:" .. tostring(ti), -- 400
							rect = r -- 400
						} -- 400
						local ____self_portraitTalentCards_8 = self.portraitTalentCards -- 400
						____self_portraitTalentCards_8[#____self_portraitTalentCards_8 + 1] = {slot = ti, id = offers[ti + 1], rect = r} -- 401
						ti = ti + 1 -- 398
					end -- 398
				end -- 398
			end -- 398
		end -- 398
	end -- 398
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 398
		prompt = deriveWorldPrompt(p) -- 407
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 407
			local keyW = math.max( -- 410
				24, -- 410
				visualTextWidth(prompt.keyTag, 15) + 16 -- 410
			) -- 410
			local labelW = visualTextWidth(prompt.label, 15) -- 411
			local pillW = keyW + labelW + 24 -- 412
			local padX = math.max(115, pillW * 0.5 + 24) -- 413
			local point = params.cam:worldToScreen(prompt.x, prompt.y) -- 414
			local sxUi = math.max( -- 415
				padX + vp.safeUi.left, -- 415
				math.min(vp.uiW - padX - vp.safeUi.right, point.x / vp.uiScale) -- 415
			) -- 415
			local syUi = math.max( -- 416
				96 + vp.safeUi.bottom, -- 416
				math.min(vp.uiH - 110 - vp.safeUi.top, point.y / vp.uiScale) -- 416
			) -- 416
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 417
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 418
			rectZones[#rectZones + 1] = { -- 419
				id = "worldPrompt", -- 420
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 421
			} -- 421
		end -- 421
	end -- 421
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 421
		local cx = ovW * 0.5 -- 433
		local cy = safeB + 46 -- 434
		buttons[#buttons + 1] = { -- 435
			id = "nav_confirm", -- 436
			x = cx, -- 437
			y = cy, -- 438
			r = 26, -- 439
			shape = "pill", -- 440
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 441
			label = "继续 · 归程", -- 442
			accent = "amber", -- 443
			active = false, -- 444
			highlighted = true, -- 445
			progress = 0, -- 446
			dimmed = false -- 447
		} -- 447
	end -- 447
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 447
		local interactMeta = deriveInteractActionMeta( -- 453
			p, -- 453
			prompt or deriveWorldPrompt(p), -- 453
			cartNearby, -- 453
			router.cartGripLatched -- 453
		) -- 453
		local nearLedge = isNearLowLedgeForButton(p) -- 454
		if isPortrait and pDel ~= nil and pGeom ~= nil then -- 454
			bottleCancelCenter = pDel:pushActionButtons( -- 457
				buttons, -- 458
				vp, -- 458
				ovW, -- 458
				safeR, -- 458
				safeB, -- 458
				pGeom, -- 458
				sc, -- 458
				p, -- 459
				isPlayMode, -- 459
				canBottleAim, -- 459
				nearLedge, -- 459
				interactMeta, -- 459
				router -- 459
			) -- 459
		else -- 459
			local rightX = ovW - safeR - 92 * sc -- 462
			local bottomY = safeB + 110 * sc -- 463
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 464
			if not p.childMode then -- 464
				buttons[#buttons + 1] = { -- 467
					id = "fire", -- 468
					x = rightX, -- 469
					y = bottomY + 12 * sc, -- 470
					r = 45 * sc, -- 471
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 472
					subLabel = "拖瞄", -- 473
					accent = "rouge", -- 474
					active = router:isButtonHeld("fire"), -- 475
					highlighted = p.reloadPendingEffect ~= "", -- 476
					progress = 0, -- 477
					dimmed = p.gripping -- 478
				} -- 478
				buttons[#buttons + 1] = { -- 480
					id = "jump", -- 481
					x = rightX - 116 * sc, -- 482
					y = bottomY - 8 * sc, -- 483
					r = 34 * sc, -- 484
					label = nearLedge and "翻越" or "翻滚", -- 485
					accent = "cyan", -- 486
					active = router:isButtonHeld("jump"), -- 487
					highlighted = nearLedge, -- 488
					progress = 0, -- 489
					dimmed = p.gripping -- 490
				} -- 490
				buttons[#buttons + 1] = { -- 492
					id = "cover", -- 493
					x = rightX - 120 * sc, -- 494
					y = bottomY + 94 * sc, -- 495
					r = 32 * sc, -- 496
					label = router.coverToggled and "离掩" or "掩体", -- 497
					accent = "cyan", -- 498
					active = router.coverToggled, -- 499
					highlighted = p.coverNear and not router.coverToggled, -- 500
					progress = 0, -- 501
					dimmed = not p.coverNear and not router.coverToggled -- 502
				} -- 502
				buttons[#buttons + 1] = { -- 504
					id = "interact", -- 505
					x = rightX - 10 * sc, -- 506
					y = bottomY + 122 * sc, -- 507
					r = 36 * sc, -- 508
					label = interactMeta.label, -- 509
					subLabel = interactMeta.subLabel, -- 510
					accent = interactMeta.urgent and "rouge" or "amber", -- 511
					active = router:isButtonHeld("interact"), -- 512
					highlighted = interactMeta.available, -- 513
					progress = interactMeta.progress, -- 514
					dimmed = not interactMeta.available -- 515
				} -- 515
				if isPlayMode and p.archive.artifactOwned then -- 515
					local eq = p.equippedWeapon == "time_shuttler" -- 518
					buttons[#buttons + 1] = { -- 519
						id = "artifact", -- 520
						x = rightX - 112 * sc, -- 521
						y = bottomY + 184 * sc, -- 522
						r = 27 * sc, -- 523
						label = eq and "收器" or "穿梭", -- 524
						accent = "amber", -- 525
						active = eq, -- 526
						highlighted = eq, -- 527
						progress = 0, -- 528
						dimmed = false -- 529
					} -- 529
				end -- 529
			else -- 529
				buttons[#buttons + 1] = { -- 533
					id = "jump", -- 534
					x = rightX, -- 535
					y = bottomY + 12 * sc, -- 536
					r = 38 * sc, -- 537
					label = "跳跃", -- 538
					accent = "amber", -- 539
					active = router:isButtonHeld("jump"), -- 540
					highlighted = false, -- 541
					progress = 0, -- 542
					dimmed = p.gripping -- 543
				} -- 543
				buttons[#buttons + 1] = { -- 545
					id = "crouch", -- 546
					x = rightX - 106 * sc, -- 547
					y = bottomY - 6 * sc, -- 548
					r = 34 * sc, -- 549
					label = router.crouchToggled and "起身" or "蹲伏", -- 550
					accent = "emerald", -- 551
					active = router.crouchToggled or p.player.crouch, -- 552
					highlighted = p.scavChase and not p.player.crouch, -- 553
					progress = 0, -- 554
					dimmed = false -- 555
				} -- 555
				buttons[#buttons + 1] = { -- 557
					id = "cover", -- 558
					x = rightX - 196 * sc, -- 559
					y = bottomY - 16 * sc, -- 560
					r = 29 * sc, -- 561
					label = router.slowToggled and "常步" or "轻步", -- 562
					accent = "silk", -- 563
					active = router.slowToggled, -- 564
					highlighted = false, -- 565
					progress = 0, -- 566
					dimmed = false -- 567
				} -- 567
				buttons[#buttons + 1] = { -- 569
					id = "interact", -- 570
					x = rightX - 12 * sc, -- 571
					y = bottomY + 114 * sc, -- 572
					r = 36 * sc, -- 573
					label = interactMeta.label, -- 574
					subLabel = interactMeta.subLabel, -- 575
					accent = interactMeta.urgent and "rouge" or "amber", -- 576
					active = router:isButtonHeld("interact"), -- 577
					highlighted = interactMeta.available, -- 578
					progress = interactMeta.progress, -- 579
					dimmed = not interactMeta.available -- 580
				} -- 580
				if canBottleAim then -- 580
					buttons[#buttons + 1] = { -- 583
						id = "bottle", -- 584
						x = rightX - 114 * sc, -- 585
						y = bottomY + 98 * sc, -- 586
						r = 38 * sc, -- 587
						label = "投瓶", -- 588
						subLabel = "拖瞄", -- 589
						accent = "amber", -- 590
						active = router:isButtonHeld("bottle"), -- 591
						highlighted = true, -- 592
						progress = math.min(1, p.aimHold / 0.12), -- 593
						dimmed = false -- 594
					} -- 594
				end -- 594
			end -- 594
		end -- 594
	end -- 594
	local enemyTargets -- 602
	if params.enemyTargets ~= nil then -- 602
		enemyTargets = params.enemyTargets -- 604
	elseif canShoot and router.settings.aimAssist and p ~= nil then -- 604
		enemyTargets = collectAimTargets(p, params.cam, vp.stageW, vp.stageH) -- 606
	else -- 606
		enemyTargets = {} -- 608
	end -- 608
	local muzzle = p ~= nil and projectMuzzle(p, params.cam) or nil -- 611
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 612
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 613
	local ctx = { -- 615
		viewport = vp, -- 616
		overlayScale = overlayScale, -- 617
		overlayActive = overlayActive, -- 618
		allowAutoGameplayTouch = params.allowAutoGameplayTouch, -- 619
		allowMouseOnOverlay = params.allowMouseOnOverlay, -- 620
		modal = modal, -- 621
		gameplayActive = gameplayActive, -- 622
		cutsceneBlocking = cutsceneBlocking, -- 623
		childMode = p ~= nil and p.childMode, -- 624
		allowDepth = allowDepth, -- 625
		canShoot = canShoot, -- 626
		canBottleAim = canBottleAim, -- 627
		cartNearby = cartNearby, -- 628
		cartGripping = p ~= nil and p.gripping, -- 629
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 630
		coverNear = p ~= nil and p.coverNear, -- 631
		playerRolling = p ~= nil and p.player.rollT > 0, -- 632
		inLowArch = p ~= nil and isInLowArch(p), -- 633
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 634
		playerFacing = p ~= nil and p.player.facing or 1, -- 635
		playerScreenX = playerScreenX, -- 636
		playerScreenY = playerScreenY, -- 637
		enemyTargets = enemyTargets, -- 638
		stickZoneMaxX = stickZoneMaxX, -- 639
		stickZoneMaxY = stickZoneMaxY, -- 640
		stickDefaultX = stickDefaultX, -- 641
		stickDefaultY = stickDefaultY, -- 642
		stickMaxR = stickMaxR, -- 643
		stickFixedOrigin = isPortrait, -- 644
		buttons = buttons, -- 645
		rectZones = rectZones, -- 646
		bottleCancelCenter = bottleCancelCenter -- 647
	} -- 647
	self.lastContext = ctx -- 650
	router:setFrameContext(ctx, params.dt) -- 651
	return ctx -- 652
end -- 250
function TouchControls.prototype.render(self, router) -- 655
	local ctx = self.lastContext -- 656
	local pDel = self.portraitDelegate -- 657
	local portraitVisible = pDel ~= nil and ctx ~= nil and ctx.viewport.isPortrait -- 658
	local visible = ctx ~= nil and (ctx.overlayActive or portraitVisible) -- 659
	if not visible then -- 659
		if not self.hasDrawn then -- 659
			return -- 663
		end -- 663
		local ____opt_13 = self.deckDraw -- 663
		if ____opt_13 ~= nil then -- 663
			____opt_13:clear() -- 665
		end -- 665
		self.padDraw:clear() -- 666
		self.padInkDraw:clear() -- 667
		self.padGlow:clear() -- 668
		self.padArt:beginFrame() -- 669
		self.padArt:endFrame() -- 670
		self.texts:hideAll() -- 671
		self.hasDrawn = false -- 672
		return -- 673
	end -- 673
	self.hasDrawn = true -- 676
	local ____opt_15 = self.deckDraw -- 676
	if ____opt_15 ~= nil then -- 676
		____opt_15:clear() -- 677
	end -- 677
	self.padDraw:clear() -- 678
	self.padInkDraw:clear() -- 679
	self.padGlow:clear() -- 680
	self.padArt:beginFrame() -- 681
	self.texts:beginFrame() -- 682
	local vp = ctx.viewport -- 684
	local sc = math.max(0.25, ctx.overlayScale) -- 685
	self.overlayRoot.scaleX = sc -- 686
	self.overlayRoot.scaleY = sc -- 687
	local ovW = vp.fullW / sc -- 689
	local ovH = vp.fullH / sc -- 690
	local baseAlpha = router.settings.touchOpacity -- 691
	if portraitVisible and pDel ~= nil and self.deckDraw ~= nil then -- 691
		pDel:drawFrame( -- 694
			self.deckDraw, -- 694
			self.padInkDraw, -- 694
			self.texts, -- 694
			ctx, -- 694
			self.lastPlay, -- 694
			ovW, -- 694
			ovH -- 694
		) -- 694
	end -- 694
	if not ctx.overlayActive then -- 694
		self.padArt:endFrame() -- 698
		self.texts:endFrame() -- 699
		return -- 700
	end -- 700
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 700
		local rx = ovW * 0.5 -- 704
		local ry = portraitVisible and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 705
		drawSilkVeil( -- 706
			self.padDraw, -- 706
			self.padArt, -- 706
			"touch_restart_veil", -- 706
			rx, -- 706
			ry, -- 706
			230, -- 706
			36, -- 706
			PALETTE.inkWash, -- 706
			0.78 * baseAlpha, -- 706
			1 -- 706
		) -- 706
		drawHairline( -- 707
			self.padInkDraw, -- 707
			self.padArt, -- 707
			"touch_restart_line", -- 707
			rx, -- 707
			ry + 16, -- 707
			180, -- 707
			PALETTE.amber, -- 707
			0.52 * baseAlpha, -- 707
			true, -- 707
			2 -- 707
		) -- 707
		self.texts:put( -- 708
			"xs", -- 708
			"轻触屏幕再次启程", -- 708
			rx, -- 708
			ry, -- 708
			toColor(PALETTE.amberCore), -- 708
			0.5, -- 708
			0.5, -- 708
			"Center", -- 708
			1.6, -- 708
			0.94, -- 708
			0.08 -- 708
		) -- 708
	end -- 708
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 708
		self:drawStick(router, ctx, baseAlpha) -- 712
	end -- 712
	self:drawPortraitStoryTalentCards(baseAlpha) -- 715
	self:drawButtons(router, ctx, baseAlpha) -- 716
	local bottleDrag = router:getBottleDragVisual() -- 718
	if bottleDrag.active then -- 718
		local cx = bottleDrag.cancelX -- 720
		local cy = bottleDrag.cancelY -- 721
		local cr = bottleDrag.cancelR -- 722
		local hot = bottleDrag.cancelHover -- 723
		fillCirclePoly( -- 724
			self.padDraw, -- 725
			cx, -- 726
			cy, -- 727
			cr, -- 728
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 729
			0, -- 730
			nil, -- 731
			22 -- 732
		) -- 732
		drawRingArc( -- 734
			self.padInkDraw, -- 734
			cx, -- 734
			cy, -- 734
			cr, -- 734
			0, -- 734
			TWO_PI, -- 734
			hot and 2.2 or 1.3, -- 734
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 734
			22 -- 734
		) -- 734
		self.texts:put( -- 735
			"xs", -- 735
			hot and "松手取消" or "拖此取消", -- 735
			cx, -- 735
			cy, -- 735
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 735
			0.5, -- 735
			0.5, -- 735
			"Center", -- 735
			0.8, -- 735
			0.96, -- 735
			0.08 -- 735
		) -- 735
	end -- 735
	self.padArt:endFrame() -- 738
	self.texts:endFrame() -- 739
end -- 655
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 742
	local stick = router:getStickVisual() -- 743
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 744
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 747
	fillCirclePoly( -- 749
		self.padDraw, -- 750
		stick.originX, -- 751
		stick.originY, -- 752
		stick.radius, -- 753
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 754
		0, -- 755
		nil, -- 756
		28 -- 757
	) -- 757
	drawRingArc( -- 759
		self.padInkDraw, -- 759
		stick.originX, -- 759
		stick.originY, -- 759
		stick.radius, -- 759
		0, -- 759
		TWO_PI, -- 759
		stick.active and 1.5 or 1, -- 759
		toColor(ringCol, 168 * stickAlpha), -- 759
		28 -- 759
	) -- 759
	if stick.allowDepth then -- 759
		local dOff = stick.radius - 10 -- 762
		self.padInkDraw:drawDot( -- 763
			Vec2(stick.originX, stick.originY + dOff), -- 763
			2.1, -- 763
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 763
		) -- 763
		self.padInkDraw:drawDot( -- 764
			Vec2(stick.originX, stick.originY - dOff), -- 764
			2.1, -- 764
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 764
		) -- 764
		self.padInkDraw:drawDot( -- 765
			Vec2(stick.originX - dOff, stick.originY), -- 765
			2.1, -- 765
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 765
		) -- 765
		self.padInkDraw:drawDot( -- 766
			Vec2(stick.originX + dOff, stick.originY), -- 766
			2.1, -- 766
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 766
		) -- 766
	elseif ctx.childMode then -- 766
		drawRingArc( -- 768
			self.padInkDraw, -- 769
			stick.originX, -- 770
			stick.originY, -- 771
			stick.radius * 0.56, -- 772
			0, -- 773
			TWO_PI, -- 774
			0.9, -- 775
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 776
			20 -- 777
		) -- 777
	end -- 777
	local knobR = math.max(16, stick.radius * 0.36) -- 781
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 782
	if stick.active then -- 782
		fillRadialGlow( -- 784
			self.padGlow, -- 784
			stick.knobX, -- 784
			stick.knobY, -- 784
			knobR * 1.45, -- 784
			knobR * 1.45, -- 784
			toColor(knobAccent, 48 * stickAlpha), -- 784
			Color(0, 0, 0, 0), -- 784
			12 -- 784
		) -- 784
	end -- 784
	fillCirclePoly( -- 786
		self.padDraw, -- 787
		stick.knobX, -- 788
		stick.knobY, -- 789
		knobR, -- 790
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 791
		1.3, -- 792
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 793
		22 -- 794
	) -- 794
	drawBlossomDot( -- 796
		self.padInkDraw, -- 796
		self.padArt, -- 796
		"touch_stick_dot", -- 796
		stick.knobX, -- 796
		stick.knobY, -- 796
		stick.active and 11 or 7, -- 796
		knobAccent, -- 796
		0.85 * stickAlpha, -- 796
		4 -- 796
	) -- 796
	if stick.slowZone then -- 796
		self.texts:put( -- 798
			"xs", -- 798
			"轻步", -- 798
			stick.originX, -- 798
			stick.originY + stick.radius + 14, -- 798
			toColor(PALETTE.emerald), -- 798
			0.5, -- 798
			0.5, -- 798
			"Center", -- 798
			1, -- 798
			0.9, -- 798
			0.08 -- 798
		) -- 798
	end -- 798
end -- 742
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 802
	local bottleDrag = router:getBottleDragVisual() -- 803
	local fireStick = router:getFireStickVisual() -- 804
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 805
	local i = 0 -- 807
	do -- 807
		i = 0 -- 808
		while i < #ctx.buttons do -- 808
			do -- 808
				local b = ctx.buttons[i + 1] -- 809
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 810
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 810
					bAlpha = bAlpha * 0.25 -- 812
				end -- 812
				local col = accentPalette(b.accent) -- 814
				local core = accentCore(b.accent) -- 815
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 816
				if b.shape == "pill" and b.rect ~= nil then -- 816
					local r = b.rect -- 819
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 820
					self.padDraw:drawRoundedRect( -- 823
						r, -- 824
						6, -- 825
						fillCol, -- 826
						b.active and 1.4 or 1, -- 827
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 828
					) -- 828
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 828
						local icX = r.x + 22 -- 831
						local icY = r.y + r.height * 0.5 -- 832
						drawRingArc( -- 833
							self.padInkDraw, -- 833
							icX, -- 833
							icY, -- 833
							9, -- 833
							0, -- 833
							TWO_PI, -- 833
							1, -- 833
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 833
							16 -- 833
						) -- 833
						self.padInkDraw:drawSegment( -- 834
							Vec2(icX - 2.6, icY - 3.6), -- 834
							Vec2(icX - 2.6, icY + 3.6), -- 834
							1.5, -- 834
							toColor(PALETTE.textBright, 225 * bAlpha) -- 834
						) -- 834
						self.padInkDraw:drawSegment( -- 835
							Vec2(icX + 2.6, icY - 3.6), -- 835
							Vec2(icX + 2.6, icY + 3.6), -- 835
							1.5, -- 835
							toColor(PALETTE.textBright, 225 * bAlpha) -- 835
						) -- 835
						self.texts:put( -- 836
							"xs", -- 836
							b.label, -- 836
							r.x + r.width * 0.5 + 10, -- 836
							icY, -- 836
							toColor(PALETTE.textBright), -- 836
							0.5, -- 836
							0.5, -- 836
							"Center", -- 836
							1, -- 836
							0.94 * bAlpha, -- 836
							0.08 -- 836
						) -- 836
					else -- 836
						if b.toggle and b.active then -- 836
							drawDiamond( -- 839
								self.padInkDraw, -- 839
								r.x + 11, -- 839
								r.y + r.height * 0.5, -- 839
								3.8, -- 839
								3.8, -- 839
								toColor(col, 235) -- 839
							) -- 839
						end -- 839
						self.texts:put( -- 841
							"xs", -- 842
							b.label, -- 843
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 844
							r.y + r.height * 0.5, -- 845
							toColor(b.active and core or PALETTE.textBright), -- 846
							0.5, -- 847
							0.5, -- 848
							"Center", -- 849
							0.6, -- 850
							math.min(1, bAlpha + 0.08), -- 851
							0.08 -- 852
						) -- 852
					end -- 852
					goto __continue83 -- 855
				end -- 855
				if b.active or b.highlighted then -- 855
					fillRadialGlow( -- 859
						self.padGlow, -- 860
						b.x, -- 861
						b.y, -- 862
						b.r * 1.38, -- 863
						b.r * 1.38, -- 864
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 865
						Color(col.r, col.g, col.b, 0), -- 866
						12 -- 867
					) -- 867
				end -- 867
				fillCirclePoly( -- 871
					self.padDraw, -- 872
					b.x, -- 873
					b.y, -- 874
					b.r, -- 875
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 876
					0, -- 877
					nil, -- 878
					24 -- 879
				) -- 879
				drawRingArc( -- 881
					self.padInkDraw, -- 882
					b.x, -- 883
					b.y, -- 884
					b.r, -- 885
					0, -- 886
					TWO_PI, -- 887
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 888
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 889
					24 -- 890
				) -- 890
				drawRingArc( -- 892
					self.padInkDraw, -- 893
					b.x, -- 894
					b.y, -- 895
					b.r - 4.2, -- 896
					0, -- 897
					TWO_PI, -- 898
					0.7, -- 899
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 900
					20 -- 901
				) -- 901
				if b.progress > 0.02 then -- 901
					drawRingArc( -- 905
						self.padInkDraw, -- 906
						b.x, -- 907
						b.y, -- 908
						b.r + 4, -- 909
						HALF_PI, -- 910
						-TWO_PI * math.min(1, b.progress), -- 911
						2.6, -- 912
						toColor(PALETTE.amberCore, 240), -- 913
						28 -- 914
					) -- 914
				end -- 914
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 918
				self.texts:put( -- 919
					fontKind, -- 920
					b.label, -- 921
					b.x, -- 922
					hasSub and b.y + 6 or b.y, -- 923
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 924
					0.5, -- 925
					0.5, -- 926
					"Center", -- 927
					0.6, -- 928
					bAlpha, -- 929
					0.08 -- 930
				) -- 930
				if hasSub and b.subLabel ~= nil then -- 930
					self.texts:put( -- 933
						"xs", -- 934
						b.subLabel, -- 935
						b.x, -- 936
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 937
						toColor(b.active and core or PALETTE.textDim), -- 938
						0.5, -- 939
						0.5, -- 940
						"Center", -- 941
						0.4, -- 942
						bAlpha * 0.85, -- 943
						0.06 -- 944
					) -- 944
				end -- 944
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 944
					self.padInkDraw:drawSegment( -- 949
						Vec2(fireStick.originX, fireStick.originY), -- 949
						Vec2(fireStick.knobX, fireStick.knobY), -- 949
						1.4, -- 949
						toColor(PALETTE.rouge, 190) -- 949
					) -- 949
					fillCirclePoly( -- 950
						self.padDraw, -- 950
						fireStick.knobX, -- 950
						fireStick.knobY, -- 950
						12, -- 950
						toColor(PALETTE.rouge, 210), -- 950
						1.2, -- 950
						toColor(PALETTE.crimsonCore, 240), -- 950
						16 -- 950
					) -- 950
				end -- 950
			end -- 950
			::__continue83:: -- 950
			i = i + 1 -- 808
		end -- 808
	end -- 808
end -- 802
function TouchControls.prototype.drawPortraitStoryTalentCards(self, alpha) -- 955
	local i = 0 -- 956
	do -- 956
		i = 0 -- 957
		while i < #self.portraitTalentCards do -- 957
			local card = self.portraitTalentCards[i + 1] -- 958
			local meta = resolveTalentVisual(card.id) -- 959
			local r = card.rect -- 960
			local cy = r.y + r.height * 0.5 -- 961
			self.padDraw:drawRoundedRect( -- 962
				r, -- 963
				5, -- 964
				toColor( -- 965
					PALETTE.panelBgDeep, -- 965
					math.floor(228 * alpha + 0.5) -- 965
				), -- 965
				1.2, -- 966
				toColor( -- 967
					meta.accent, -- 967
					math.floor(215 * alpha + 0.5) -- 967
				) -- 967
			) -- 967
			drawTalentGlyph( -- 969
				self.padInkDraw, -- 969
				r.x + 17, -- 969
				cy, -- 969
				8.5, -- 969
				card.id, -- 969
				meta.accent, -- 969
				math.min(1, alpha + 0.1), -- 969
				meta.accentCore -- 969
			) -- 969
			self.texts:put( -- 970
				"xs", -- 971
				meta.title .. " · 落印", -- 972
				r.x + 31, -- 973
				cy, -- 974
				toColor(meta.accentCore), -- 975
				0, -- 976
				0.5, -- 977
				"Left", -- 978
				0.4, -- 979
				math.min(1, alpha + 0.12), -- 980
				0.08 -- 981
			) -- 981
			i = i + 1 -- 957
		end -- 957
	end -- 957
end -- 955
return ____exports -- 955