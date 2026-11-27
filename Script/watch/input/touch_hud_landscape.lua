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
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 278
	local cart = p ~= nil and p.room.cart or nil -- 280
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 281
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 283
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 284
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 285
	local buttons = {} -- 288
	local rectZones = {} -- 289
	local pGeom = isPortrait and pDel ~= nil and pDel:computeStickGeom( -- 291
		vp, -- 292
		ovW, -- 292
		safeL, -- 292
		safeB, -- 292
		sc -- 292
	) or nil -- 292
	local stickMaxR = pGeom ~= nil and pGeom.stickMaxR or STICK_BASE_R_LANDSCAPE * sc -- 294
	local stickDefaultX = pGeom ~= nil and pGeom.stickDefaultX or safeL + 126 * sc -- 295
	local stickDefaultY = pGeom ~= nil and pGeom.stickDefaultY or safeB + 126 * sc -- 296
	local stickZoneMaxX = pGeom ~= nil and pGeom.stickZoneMaxX or ovW * 0.46 -- 297
	local stickZoneMaxY = pGeom ~= nil and pGeom.stickZoneMaxY or ovH - 110 -- 298
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 300
	if overlayActive then -- 300
		if isPortrait and pDel ~= nil then -- 300
			pDel:pushTopButtons( -- 305
				buttons, -- 306
				vp, -- 306
				ovW, -- 306
				ovH, -- 306
				safeR, -- 306
				gameplayActive, -- 306
				p, -- 306
				params.isMuted, -- 307
				params.isFullscreen, -- 307
				params.canToggleFullscreen -- 307
			) -- 307
		elseif isPlayMode and not modal then -- 307
			local px = ovW - safeR - 112 -- 310
			local py = ovH - safeT - 66 -- 311
			buttons[#buttons + 1] = { -- 312
				id = "pause", -- 313
				x = px + 46, -- 314
				y = py + 21, -- 315
				r = 28, -- 316
				shape = "pill", -- 317
				rect = Rect(px, py, 94, 42), -- 318
				label = "暂歇", -- 319
				accent = "silk", -- 320
				active = false, -- 321
				highlighted = false, -- 322
				progress = 0, -- 323
				dimmed = false -- 324
			} -- 324
			if params.showWebTopPills then -- 324
				local mw = 58 -- 327
				local mx = px - mw - 10 -- 328
				buttons[#buttons + 1] = { -- 329
					id = "mute", -- 330
					x = mx + mw * 0.5, -- 331
					y = py + 21, -- 332
					r = 22, -- 333
					shape = "pill", -- 334
					rect = Rect(mx, py + 4, mw, 34), -- 335
					label = params.isMuted and "静音" or "有声", -- 336
					accent = params.isMuted and "rouge" or "cyan", -- 337
					active = params.isMuted, -- 338
					highlighted = false, -- 339
					progress = 0, -- 340
					dimmed = false -- 341
				} -- 341
				if params.canToggleFullscreen then -- 341
					local fw = 58 -- 344
					local fx = mx - fw - 8 -- 345
					buttons[#buttons + 1] = { -- 346
						id = "fullscreen", -- 347
						x = fx + fw * 0.5, -- 348
						y = py + 21, -- 349
						r = 22, -- 350
						shape = "pill", -- 351
						rect = Rect(fx, py + 4, fw, 34), -- 352
						label = params.isFullscreen and "窗口" or "全屏", -- 353
						accent = "silk", -- 354
						active = params.isFullscreen, -- 355
						highlighted = false, -- 356
						progress = 0, -- 357
						dimmed = false -- 358
					} -- 358
				end -- 358
			end -- 358
		end -- 358
	end -- 358
	if isPortrait and pDel ~= nil and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 358
		pDel:pushMenuNavButtons( -- 368
			buttons, -- 368
			vp, -- 368
			ovW, -- 368
			safeL, -- 368
			safeR, -- 368
			safeB -- 368
		) -- 368
	end -- 368
	local prompt -- 372
	if isPlayMode and p ~= nil and not p.paused and not p.reloadOpen and not p.craftBench.active and not cutsceneBlocking then -- 372
		local function addZone(id, b) -- 374
			rectZones[#rectZones + 1] = { -- 375
				id = id, -- 375
				rect = Rect((vp.stageX + b.x * vp.uiScale) / overlayScale, (vp.stageY + b.y * vp.uiScale) / overlayScale, b.width * vp.uiScale / overlayScale, b.height * vp.uiScale / overlayScale) -- 375
			} -- 375
		end -- 374
		if not p.escortFailed and not params.ledgerOpen and params.ledgerBox and params.ledgerBox.width > 0 then -- 374
			addZone("ledger:toggle", params.ledgerBox) -- 380
		end -- 380
		if params.escortDeathBoxes then -- 380
			addZone("escort:retry", params.escortDeathBoxes.retry) -- 383
			addZone("escort:title", params.escortDeathBoxes.title) -- 384
		end -- 384
		do -- 384
			local i = 0 -- 386
			while i < #params.storyTalentBoxes do -- 386
				addZone( -- 387
					"talent:" .. tostring(i), -- 387
					params.storyTalentBoxes[i + 1] -- 387
				) -- 387
				i = i + 1 -- 386
			end -- 386
		end -- 386
		if isPortrait and overlayActive and vp.deckH >= 220 then -- 386
			local offers = p:getStoryTalentOffers() -- 390
			local count = math.min(#offers, #params.storyTalentBoxes) -- 391
			if count > 0 then -- 391
				local padX = math.max(12, safeL + 10) -- 393
				local gap = 8 -- 394
				local availW = ovW - padX * 2 -- 395
				local cardW = (availW - gap * (count - 1)) / count -- 396
				local cardH = 34 -- 397
				local cardY = vp.deckH - cardH - 8 -- 398
				do -- 398
					local ti = 0 -- 399
					while ti < count do -- 399
						local r = Rect(padX + ti * (cardW + gap), cardY, cardW, cardH) -- 400
						rectZones[#rectZones + 1] = { -- 401
							id = "talent:" .. tostring(ti), -- 401
							rect = r -- 401
						} -- 401
						local ____self_portraitTalentCards_8 = self.portraitTalentCards -- 401
						____self_portraitTalentCards_8[#____self_portraitTalentCards_8 + 1] = {slot = ti, id = offers[ti + 1], rect = r} -- 402
						ti = ti + 1 -- 399
					end -- 399
				end -- 399
			end -- 399
		end -- 399
	end -- 399
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 399
		prompt = deriveWorldPrompt(p) -- 408
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 408
			local keyW = math.max( -- 411
				24, -- 411
				visualTextWidth(prompt.keyTag, 15) + 16 -- 411
			) -- 411
			local labelW = visualTextWidth(prompt.label, 15) -- 412
			local pillW = keyW + labelW + 24 -- 413
			local padX = math.max(115, pillW * 0.5 + 24) -- 414
			local point = params.cam:worldToScreen(prompt.x, prompt.y) -- 415
			local sxUi = math.max( -- 416
				padX + vp.safeUi.left, -- 416
				math.min(vp.uiW - padX - vp.safeUi.right, point.x / vp.uiScale) -- 416
			) -- 416
			local syUi = math.max( -- 417
				96 + vp.safeUi.bottom, -- 417
				math.min(vp.uiH - 110 - vp.safeUi.top, point.y / vp.uiScale) -- 417
			) -- 417
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 418
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 419
			rectZones[#rectZones + 1] = { -- 420
				id = "worldPrompt", -- 421
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 422
			} -- 422
		end -- 422
	end -- 422
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 422
		local cx = ovW * 0.5 -- 434
		local cy = safeB + 46 -- 435
		buttons[#buttons + 1] = { -- 436
			id = "nav_confirm", -- 437
			x = cx, -- 438
			y = cy, -- 439
			r = 26, -- 440
			shape = "pill", -- 441
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 442
			label = "继续 · 归程", -- 443
			accent = "amber", -- 444
			active = false, -- 445
			highlighted = true, -- 446
			progress = 0, -- 447
			dimmed = false -- 448
		} -- 448
	end -- 448
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 448
		local interactMeta = deriveInteractActionMeta( -- 454
			p, -- 454
			prompt or deriveWorldPrompt(p), -- 454
			cartNearby, -- 454
			router.cartGripLatched -- 454
		) -- 454
		local nearLedge = isNearLowLedgeForButton(p) -- 455
		if isPortrait and pDel ~= nil and pGeom ~= nil then -- 455
			bottleCancelCenter = pDel:pushActionButtons( -- 458
				buttons, -- 459
				vp, -- 459
				ovW, -- 459
				safeR, -- 459
				safeB, -- 459
				pGeom, -- 459
				sc, -- 459
				p, -- 460
				isPlayMode, -- 460
				canBottleAim, -- 460
				nearLedge, -- 460
				interactMeta, -- 460
				router -- 460
			) -- 460
		else -- 460
			local rightX = ovW - safeR - 92 * sc -- 463
			local bottomY = safeB + 110 * sc -- 464
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 465
			if not p.childMode then -- 465
				buttons[#buttons + 1] = { -- 468
					id = "fire", -- 469
					x = rightX, -- 470
					y = bottomY + 12 * sc, -- 471
					r = 45 * sc, -- 472
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 473
					subLabel = "拖瞄", -- 474
					accent = "rouge", -- 475
					active = router:isButtonHeld("fire"), -- 476
					highlighted = p.reloadPendingEffect ~= "", -- 477
					progress = 0, -- 478
					dimmed = p.gripping -- 479
				} -- 479
				buttons[#buttons + 1] = { -- 481
					id = "jump", -- 482
					x = rightX - 116 * sc, -- 483
					y = bottomY - 8 * sc, -- 484
					r = 34 * sc, -- 485
					label = nearLedge and "翻越" or "翻滚", -- 486
					accent = "cyan", -- 487
					active = router:isButtonHeld("jump"), -- 488
					highlighted = nearLedge, -- 489
					progress = 0, -- 490
					dimmed = p.gripping -- 491
				} -- 491
				buttons[#buttons + 1] = { -- 493
					id = "cover", -- 494
					x = rightX - 120 * sc, -- 495
					y = bottomY + 94 * sc, -- 496
					r = 32 * sc, -- 497
					label = router.coverToggled and "离掩" or "掩体", -- 498
					accent = "cyan", -- 499
					active = router.coverToggled, -- 500
					highlighted = p.coverNear and not router.coverToggled, -- 501
					progress = 0, -- 502
					dimmed = not p.coverNear and not router.coverToggled -- 503
				} -- 503
				buttons[#buttons + 1] = { -- 505
					id = "interact", -- 506
					x = rightX - 10 * sc, -- 507
					y = bottomY + 122 * sc, -- 508
					r = 36 * sc, -- 509
					label = interactMeta.label, -- 510
					subLabel = interactMeta.subLabel, -- 511
					accent = interactMeta.urgent and "rouge" or "amber", -- 512
					active = router:isButtonHeld("interact"), -- 513
					highlighted = interactMeta.available, -- 514
					progress = interactMeta.progress, -- 515
					dimmed = not interactMeta.available -- 516
				} -- 516
				if isPlayMode and p.archive.artifactOwned then -- 516
					local eq = p.equippedWeapon == "time_shuttler" -- 519
					buttons[#buttons + 1] = { -- 520
						id = "artifact", -- 521
						x = rightX - 112 * sc, -- 522
						y = bottomY + 184 * sc, -- 523
						r = 27 * sc, -- 524
						label = eq and "收器" or "穿梭", -- 525
						accent = "amber", -- 526
						active = eq, -- 527
						highlighted = eq, -- 528
						progress = 0, -- 529
						dimmed = false -- 530
					} -- 530
				end -- 530
			else -- 530
				buttons[#buttons + 1] = { -- 534
					id = "jump", -- 535
					x = rightX, -- 536
					y = bottomY + 12 * sc, -- 537
					r = 38 * sc, -- 538
					label = "跳跃", -- 539
					accent = "amber", -- 540
					active = router:isButtonHeld("jump"), -- 541
					highlighted = false, -- 542
					progress = 0, -- 543
					dimmed = p.gripping -- 544
				} -- 544
				buttons[#buttons + 1] = { -- 546
					id = "crouch", -- 547
					x = rightX - 106 * sc, -- 548
					y = bottomY - 6 * sc, -- 549
					r = 34 * sc, -- 550
					label = router.crouchToggled and "起身" or "蹲伏", -- 551
					accent = "emerald", -- 552
					active = router.crouchToggled or p.player.crouch, -- 553
					highlighted = p.scavChase and not p.player.crouch, -- 554
					progress = 0, -- 555
					dimmed = false -- 556
				} -- 556
				buttons[#buttons + 1] = { -- 558
					id = "cover", -- 559
					x = rightX - 196 * sc, -- 560
					y = bottomY - 16 * sc, -- 561
					r = 29 * sc, -- 562
					label = router.slowToggled and "常步" or "轻步", -- 563
					accent = "silk", -- 564
					active = router.slowToggled, -- 565
					highlighted = false, -- 566
					progress = 0, -- 567
					dimmed = false -- 568
				} -- 568
				buttons[#buttons + 1] = { -- 570
					id = "interact", -- 571
					x = rightX - 12 * sc, -- 572
					y = bottomY + 114 * sc, -- 573
					r = 36 * sc, -- 574
					label = interactMeta.label, -- 575
					subLabel = interactMeta.subLabel, -- 576
					accent = interactMeta.urgent and "rouge" or "amber", -- 577
					active = router:isButtonHeld("interact"), -- 578
					highlighted = interactMeta.available, -- 579
					progress = interactMeta.progress, -- 580
					dimmed = not interactMeta.available -- 581
				} -- 581
				if canBottleAim then -- 581
					buttons[#buttons + 1] = { -- 584
						id = "bottle", -- 585
						x = rightX - 114 * sc, -- 586
						y = bottomY + 98 * sc, -- 587
						r = 38 * sc, -- 588
						label = "投瓶", -- 589
						subLabel = "拖瞄", -- 590
						accent = "amber", -- 591
						active = router:isButtonHeld("bottle"), -- 592
						highlighted = true, -- 593
						progress = math.min(1, p.aimHold / 0.12), -- 594
						dimmed = false -- 595
					} -- 595
				end -- 595
			end -- 595
		end -- 595
	end -- 595
	local enemyTargets -- 603
	if params.enemyTargets ~= nil then -- 603
		enemyTargets = params.enemyTargets -- 605
	elseif canShoot and router.settings.aimAssist and p ~= nil then -- 605
		enemyTargets = collectAimTargets(p, params.cam, vp.stageW, vp.stageH) -- 607
	else -- 607
		enemyTargets = {} -- 609
	end -- 609
	local muzzle = p ~= nil and projectMuzzle(p, params.cam) or nil -- 612
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 613
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 614
	local ctx = { -- 616
		viewport = vp, -- 617
		overlayScale = overlayScale, -- 618
		overlayActive = overlayActive, -- 619
		allowAutoGameplayTouch = params.allowAutoGameplayTouch, -- 620
		allowMouseOnOverlay = params.allowMouseOnOverlay, -- 621
		modal = modal, -- 622
		gameplayActive = gameplayActive, -- 623
		cutsceneBlocking = cutsceneBlocking, -- 624
		childMode = p ~= nil and p.childMode, -- 625
		allowDepth = allowDepth, -- 626
		canShoot = canShoot, -- 627
		canBottleAim = canBottleAim, -- 628
		cartNearby = cartNearby, -- 629
		cartGripping = p ~= nil and p.gripping, -- 630
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 631
		coverNear = p ~= nil and p.coverNear, -- 632
		playerRolling = p ~= nil and p.player.rollT > 0, -- 633
		inLowArch = p ~= nil and isInLowArch(p), -- 634
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 635
		playerFacing = p ~= nil and p.player.facing or 1, -- 636
		playerScreenX = playerScreenX, -- 637
		playerScreenY = playerScreenY, -- 638
		enemyTargets = enemyTargets, -- 639
		stickZoneMaxX = stickZoneMaxX, -- 640
		stickZoneMaxY = stickZoneMaxY, -- 641
		stickDefaultX = stickDefaultX, -- 642
		stickDefaultY = stickDefaultY, -- 643
		stickMaxR = stickMaxR, -- 644
		stickFixedOrigin = isPortrait, -- 645
		buttons = buttons, -- 646
		rectZones = rectZones, -- 647
		bottleCancelCenter = bottleCancelCenter -- 648
	} -- 648
	self.lastContext = ctx -- 651
	router:setFrameContext(ctx, params.dt) -- 652
	return ctx -- 653
end -- 250
function TouchControls.prototype.render(self, router) -- 656
	local ctx = self.lastContext -- 657
	local pDel = self.portraitDelegate -- 658
	local portraitVisible = pDel ~= nil and ctx ~= nil and ctx.viewport.isPortrait -- 659
	local visible = ctx ~= nil and (ctx.overlayActive or portraitVisible) -- 660
	if not visible then -- 660
		if not self.hasDrawn then -- 660
			return -- 664
		end -- 664
		local ____opt_13 = self.deckDraw -- 664
		if ____opt_13 ~= nil then -- 664
			____opt_13:clear() -- 666
		end -- 666
		self.padDraw:clear() -- 667
		self.padInkDraw:clear() -- 668
		self.padGlow:clear() -- 669
		self.padArt:beginFrame() -- 670
		self.padArt:endFrame() -- 671
		self.texts:hideAll() -- 672
		self.hasDrawn = false -- 673
		return -- 674
	end -- 674
	self.hasDrawn = true -- 677
	local ____opt_15 = self.deckDraw -- 677
	if ____opt_15 ~= nil then -- 677
		____opt_15:clear() -- 678
	end -- 678
	self.padDraw:clear() -- 679
	self.padInkDraw:clear() -- 680
	self.padGlow:clear() -- 681
	self.padArt:beginFrame() -- 682
	self.texts:beginFrame() -- 683
	local vp = ctx.viewport -- 685
	local sc = math.max(0.25, ctx.overlayScale) -- 686
	self.overlayRoot.scaleX = sc -- 687
	self.overlayRoot.scaleY = sc -- 688
	local ovW = vp.fullW / sc -- 690
	local ovH = vp.fullH / sc -- 691
	local baseAlpha = router.settings.touchOpacity -- 692
	if portraitVisible and pDel ~= nil and self.deckDraw ~= nil then -- 692
		pDel:drawFrame( -- 695
			self.deckDraw, -- 695
			self.padInkDraw, -- 695
			self.texts, -- 695
			ctx, -- 695
			self.lastPlay, -- 695
			ovW, -- 695
			ovH -- 695
		) -- 695
	end -- 695
	if not ctx.overlayActive then -- 695
		self.padArt:endFrame() -- 699
		self.texts:endFrame() -- 700
		return -- 701
	end -- 701
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 701
		local rx = ovW * 0.5 -- 705
		local ry = portraitVisible and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 706
		drawSilkVeil( -- 707
			self.padDraw, -- 707
			self.padArt, -- 707
			"touch_restart_veil", -- 707
			rx, -- 707
			ry, -- 707
			230, -- 707
			36, -- 707
			PALETTE.inkWash, -- 707
			0.78 * baseAlpha, -- 707
			1 -- 707
		) -- 707
		drawHairline( -- 708
			self.padInkDraw, -- 708
			self.padArt, -- 708
			"touch_restart_line", -- 708
			rx, -- 708
			ry + 16, -- 708
			180, -- 708
			PALETTE.amber, -- 708
			0.52 * baseAlpha, -- 708
			true, -- 708
			2 -- 708
		) -- 708
		self.texts:put( -- 709
			"xs", -- 709
			"轻触屏幕再次启程", -- 709
			rx, -- 709
			ry, -- 709
			toColor(PALETTE.amberCore), -- 709
			0.5, -- 709
			0.5, -- 709
			"Center", -- 709
			1.6, -- 709
			0.94, -- 709
			0.08 -- 709
		) -- 709
	end -- 709
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 709
		self:drawStick(router, ctx, baseAlpha) -- 713
	end -- 713
	self:drawPortraitStoryTalentCards(baseAlpha) -- 716
	self:drawButtons(router, ctx, baseAlpha) -- 717
	local bottleDrag = router:getBottleDragVisual() -- 719
	if bottleDrag.active then -- 719
		local cx = bottleDrag.cancelX -- 721
		local cy = bottleDrag.cancelY -- 722
		local cr = bottleDrag.cancelR -- 723
		local hot = bottleDrag.cancelHover -- 724
		fillCirclePoly( -- 725
			self.padDraw, -- 726
			cx, -- 727
			cy, -- 728
			cr, -- 729
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 730
			0, -- 731
			nil, -- 732
			22 -- 733
		) -- 733
		drawRingArc( -- 735
			self.padInkDraw, -- 735
			cx, -- 735
			cy, -- 735
			cr, -- 735
			0, -- 735
			TWO_PI, -- 735
			hot and 2.2 or 1.3, -- 735
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 735
			22 -- 735
		) -- 735
		self.texts:put( -- 736
			"xs", -- 736
			hot and "松手取消" or "拖此取消", -- 736
			cx, -- 736
			cy, -- 736
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 736
			0.5, -- 736
			0.5, -- 736
			"Center", -- 736
			0.8, -- 736
			0.96, -- 736
			0.08 -- 736
		) -- 736
	end -- 736
	self.padArt:endFrame() -- 739
	self.texts:endFrame() -- 740
end -- 656
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 743
	local stick = router:getStickVisual() -- 744
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 745
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 748
	fillCirclePoly( -- 750
		self.padDraw, -- 751
		stick.originX, -- 752
		stick.originY, -- 753
		stick.radius, -- 754
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 755
		0, -- 756
		nil, -- 757
		28 -- 758
	) -- 758
	drawRingArc( -- 760
		self.padInkDraw, -- 760
		stick.originX, -- 760
		stick.originY, -- 760
		stick.radius, -- 760
		0, -- 760
		TWO_PI, -- 760
		stick.active and 1.5 or 1, -- 760
		toColor(ringCol, 168 * stickAlpha), -- 760
		28 -- 760
	) -- 760
	if stick.allowDepth then -- 760
		local dOff = stick.radius - 10 -- 763
		self.padInkDraw:drawDot( -- 764
			Vec2(stick.originX, stick.originY + dOff), -- 764
			2.1, -- 764
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 764
		) -- 764
		self.padInkDraw:drawDot( -- 765
			Vec2(stick.originX, stick.originY - dOff), -- 765
			2.1, -- 765
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 765
		) -- 765
		self.padInkDraw:drawDot( -- 766
			Vec2(stick.originX - dOff, stick.originY), -- 766
			2.1, -- 766
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 766
		) -- 766
		self.padInkDraw:drawDot( -- 767
			Vec2(stick.originX + dOff, stick.originY), -- 767
			2.1, -- 767
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 767
		) -- 767
	elseif ctx.childMode then -- 767
		drawRingArc( -- 769
			self.padInkDraw, -- 770
			stick.originX, -- 771
			stick.originY, -- 772
			stick.radius * 0.56, -- 773
			0, -- 774
			TWO_PI, -- 775
			0.9, -- 776
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 777
			20 -- 778
		) -- 778
	end -- 778
	local knobR = math.max(16, stick.radius * 0.36) -- 782
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 783
	if stick.active then -- 783
		fillRadialGlow( -- 785
			self.padGlow, -- 785
			stick.knobX, -- 785
			stick.knobY, -- 785
			knobR * 1.45, -- 785
			knobR * 1.45, -- 785
			toColor(knobAccent, 48 * stickAlpha), -- 785
			Color(0, 0, 0, 0), -- 785
			12 -- 785
		) -- 785
	end -- 785
	fillCirclePoly( -- 787
		self.padDraw, -- 788
		stick.knobX, -- 789
		stick.knobY, -- 790
		knobR, -- 791
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 792
		1.3, -- 793
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 794
		22 -- 795
	) -- 795
	drawBlossomDot( -- 797
		self.padInkDraw, -- 797
		self.padArt, -- 797
		"touch_stick_dot", -- 797
		stick.knobX, -- 797
		stick.knobY, -- 797
		stick.active and 11 or 7, -- 797
		knobAccent, -- 797
		0.85 * stickAlpha, -- 797
		4 -- 797
	) -- 797
	if stick.slowZone then -- 797
		self.texts:put( -- 799
			"xs", -- 799
			"轻步", -- 799
			stick.originX, -- 799
			stick.originY + stick.radius + 14, -- 799
			toColor(PALETTE.emerald), -- 799
			0.5, -- 799
			0.5, -- 799
			"Center", -- 799
			1, -- 799
			0.9, -- 799
			0.08 -- 799
		) -- 799
	end -- 799
end -- 743
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 803
	local bottleDrag = router:getBottleDragVisual() -- 804
	local fireStick = router:getFireStickVisual() -- 805
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 806
	local i = 0 -- 808
	do -- 808
		i = 0 -- 809
		while i < #ctx.buttons do -- 809
			do -- 809
				local b = ctx.buttons[i + 1] -- 810
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 811
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 811
					bAlpha = bAlpha * 0.25 -- 813
				end -- 813
				local col = accentPalette(b.accent) -- 815
				local core = accentCore(b.accent) -- 816
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 817
				if b.shape == "pill" and b.rect ~= nil then -- 817
					local r = b.rect -- 820
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 821
					self.padDraw:drawRoundedRect( -- 824
						r, -- 825
						6, -- 826
						fillCol, -- 827
						b.active and 1.4 or 1, -- 828
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 829
					) -- 829
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 829
						local icX = r.x + 22 -- 832
						local icY = r.y + r.height * 0.5 -- 833
						drawRingArc( -- 834
							self.padInkDraw, -- 834
							icX, -- 834
							icY, -- 834
							9, -- 834
							0, -- 834
							TWO_PI, -- 834
							1, -- 834
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 834
							16 -- 834
						) -- 834
						self.padInkDraw:drawSegment( -- 835
							Vec2(icX - 2.6, icY - 3.6), -- 835
							Vec2(icX - 2.6, icY + 3.6), -- 835
							1.5, -- 835
							toColor(PALETTE.textBright, 225 * bAlpha) -- 835
						) -- 835
						self.padInkDraw:drawSegment( -- 836
							Vec2(icX + 2.6, icY - 3.6), -- 836
							Vec2(icX + 2.6, icY + 3.6), -- 836
							1.5, -- 836
							toColor(PALETTE.textBright, 225 * bAlpha) -- 836
						) -- 836
						self.texts:put( -- 837
							"xs", -- 837
							b.label, -- 837
							r.x + r.width * 0.5 + 10, -- 837
							icY, -- 837
							toColor(PALETTE.textBright), -- 837
							0.5, -- 837
							0.5, -- 837
							"Center", -- 837
							1, -- 837
							0.94 * bAlpha, -- 837
							0.08 -- 837
						) -- 837
					else -- 837
						if b.toggle and b.active then -- 837
							drawDiamond( -- 840
								self.padInkDraw, -- 840
								r.x + 11, -- 840
								r.y + r.height * 0.5, -- 840
								3.8, -- 840
								3.8, -- 840
								toColor(col, 235) -- 840
							) -- 840
						end -- 840
						self.texts:put( -- 842
							"xs", -- 843
							b.label, -- 844
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 845
							r.y + r.height * 0.5, -- 846
							toColor(b.active and core or PALETTE.textBright), -- 847
							0.5, -- 848
							0.5, -- 849
							"Center", -- 850
							0.6, -- 851
							math.min(1, bAlpha + 0.08), -- 852
							0.08 -- 853
						) -- 853
					end -- 853
					goto __continue83 -- 856
				end -- 856
				if b.active or b.highlighted then -- 856
					fillRadialGlow( -- 860
						self.padGlow, -- 861
						b.x, -- 862
						b.y, -- 863
						b.r * 1.38, -- 864
						b.r * 1.38, -- 865
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 866
						Color(col.r, col.g, col.b, 0), -- 867
						12 -- 868
					) -- 868
				end -- 868
				fillCirclePoly( -- 872
					self.padDraw, -- 873
					b.x, -- 874
					b.y, -- 875
					b.r, -- 876
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 877
					0, -- 878
					nil, -- 879
					24 -- 880
				) -- 880
				drawRingArc( -- 882
					self.padInkDraw, -- 883
					b.x, -- 884
					b.y, -- 885
					b.r, -- 886
					0, -- 887
					TWO_PI, -- 888
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 889
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 890
					24 -- 891
				) -- 891
				drawRingArc( -- 893
					self.padInkDraw, -- 894
					b.x, -- 895
					b.y, -- 896
					b.r - 4.2, -- 897
					0, -- 898
					TWO_PI, -- 899
					0.7, -- 900
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 901
					20 -- 902
				) -- 902
				if b.progress > 0.02 then -- 902
					drawRingArc( -- 906
						self.padInkDraw, -- 907
						b.x, -- 908
						b.y, -- 909
						b.r + 4, -- 910
						HALF_PI, -- 911
						-TWO_PI * math.min(1, b.progress), -- 912
						2.6, -- 913
						toColor(PALETTE.amberCore, 240), -- 914
						28 -- 915
					) -- 915
				end -- 915
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 919
				self.texts:put( -- 920
					fontKind, -- 921
					b.label, -- 922
					b.x, -- 923
					hasSub and b.y + 6 or b.y, -- 924
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 925
					0.5, -- 926
					0.5, -- 927
					"Center", -- 928
					0.6, -- 929
					bAlpha, -- 930
					0.08 -- 931
				) -- 931
				if hasSub and b.subLabel ~= nil then -- 931
					self.texts:put( -- 934
						"xs", -- 935
						b.subLabel, -- 936
						b.x, -- 937
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 938
						toColor(b.active and core or PALETTE.textDim), -- 939
						0.5, -- 940
						0.5, -- 941
						"Center", -- 942
						0.4, -- 943
						bAlpha * 0.85, -- 944
						0.06 -- 945
					) -- 945
				end -- 945
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 945
					self.padInkDraw:drawSegment( -- 950
						Vec2(fireStick.originX, fireStick.originY), -- 950
						Vec2(fireStick.knobX, fireStick.knobY), -- 950
						1.4, -- 950
						toColor(PALETTE.rouge, 190) -- 950
					) -- 950
					fillCirclePoly( -- 951
						self.padDraw, -- 951
						fireStick.knobX, -- 951
						fireStick.knobY, -- 951
						12, -- 951
						toColor(PALETTE.rouge, 210), -- 951
						1.2, -- 951
						toColor(PALETTE.crimsonCore, 240), -- 951
						16 -- 951
					) -- 951
				end -- 951
			end -- 951
			::__continue83:: -- 951
			i = i + 1 -- 809
		end -- 809
	end -- 809
end -- 803
function TouchControls.prototype.drawPortraitStoryTalentCards(self, alpha) -- 956
	local i = 0 -- 957
	do -- 957
		i = 0 -- 958
		while i < #self.portraitTalentCards do -- 958
			local card = self.portraitTalentCards[i + 1] -- 959
			local meta = resolveTalentVisual(card.id) -- 960
			local r = card.rect -- 961
			local cy = r.y + r.height * 0.5 -- 962
			self.padDraw:drawRoundedRect( -- 963
				r, -- 964
				5, -- 965
				toColor( -- 966
					PALETTE.panelBgDeep, -- 966
					math.floor(228 * alpha + 0.5) -- 966
				), -- 966
				1.2, -- 967
				toColor( -- 968
					meta.accent, -- 968
					math.floor(215 * alpha + 0.5) -- 968
				) -- 968
			) -- 968
			drawTalentGlyph( -- 970
				self.padInkDraw, -- 970
				r.x + 17, -- 970
				cy, -- 970
				8.5, -- 970
				card.id, -- 970
				meta.accent, -- 970
				math.min(1, alpha + 0.1), -- 970
				meta.accentCore -- 970
			) -- 970
			self.texts:put( -- 971
				"xs", -- 972
				meta.title .. " · 落印", -- 973
				r.x + 31, -- 974
				cy, -- 975
				toColor(meta.accentCore), -- 976
				0, -- 977
				0.5, -- 978
				"Left", -- 979
				0.4, -- 980
				math.min(1, alpha + 0.12), -- 981
				0.08 -- 982
			) -- 982
			i = i + 1 -- 958
		end -- 958
	end -- 958
end -- 956
return ____exports -- 956