-- [ts]: roguelike_ui.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Keyboard = ____Dora.Keyboard -- 17
local Mouse = ____Dora.Mouse -- 17
local Rect = ____Dora.Rect -- 17
local Vec2 = ____Dora.Vec2 -- 17
local ____run = require("Script.watch.run") -- 19
local mmss = ____run.mmss -- 19
local ____platform = require("Script.watch.platform") -- 22
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 22
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 31
local keyTagFor = ____control_prompts.keyTagFor -- 31
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 32
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 32
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 32
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 33
local PICKUP_ORDER = ____talent_catalog.PICKUP_ORDER -- 34
local deriveMarchTitle = ____talent_catalog.deriveMarchTitle -- 36
local drawBrushArc = ____talent_catalog.drawBrushArc -- 37
local drawPickupGlyph = ____talent_catalog.drawPickupGlyph -- 38
local drawTalentGlyph = ____talent_catalog.drawTalentGlyph -- 39
local pickupMetaOf = ____talent_catalog.pickupMetaOf -- 40
local rankChinese = ____talent_catalog.rankChinese -- 41
local resolveTalentVisual = ____talent_catalog.resolveTalentVisual -- 42
local weaponMetaOf = ____talent_catalog.weaponMetaOf -- 43
local ____theme = require("Script.watch.fe.theme") -- 45
local PALETTE = ____theme.PALETTE -- 46
local drawBlossomDot = ____theme.drawBlossomDot -- 48
local drawDiamond = ____theme.drawDiamond -- 49
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 50
local drawHairline = ____theme.drawHairline -- 51
local drawLoneSeal = ____theme.drawLoneSeal -- 52
local drawMistCurve = ____theme.drawMistCurve -- 53
local drawSilkKeycap = ____theme.drawSilkKeycap -- 54
local drawSilkRibbon = ____theme.drawSilkRibbon -- 55
local drawSilkVeil = ____theme.drawSilkVeil -- 56
local fillRadialGlow = ____theme.fillRadialGlow -- 58
local fillVGradRect = ____theme.fillVGradRect -- 59
local themeOf = ____theme.themeOf -- 60
local toChineseUpper = ____theme.toChineseUpper -- 61
local toColor = ____theme.toColor -- 62
local SEAL_DURATION = 0.24 -- 119
local ABSORB_DURATION = 0.32 -- 120
local SEGMENT_BANNER_DURATION = 1.45 -- 121
local DEATH_RECAP_DURATION = 1.85 -- 122
local AUTO_REEXPAND_IDLE_SEC = 1.25 -- 123
local EXPANDED_FOCUS_SCALE = 0.25 -- 124
local TWO_PI = math.pi * 2 -- 125
local function clamp(v, lo, hi) -- 127
	return v < lo and lo or (v > hi and hi or v) -- 128
end -- 127
local function easeOutCubic(t) -- 131
	local u = 1 - clamp(t, 0, 1) -- 132
	return 1 - u * u * u -- 133
end -- 131
local function easeInOutQuad(t) -- 136
	local x = clamp(t, 0, 1) -- 137
	return x < 0.5 and 2 * x * x or 1 - (-2 * x + 2) ^ 2 * 0.5 -- 138
end -- 136
--- 计算三选一筹签卡的 UI 坐标矩形（展卷态与收束态单一布局真源，
-- 同时服务于渲染、鼠标点击、触屏直点热区与 verify-story-roguelike.lua 回归校验）。
function ____exports.computeRoguelikeCardRects(uiW, uiH, count, expanded, touchMode, safeTop) -- 145
	if touchMode == nil then -- 150
		touchMode = false -- 150
	end -- 150
	if safeTop == nil then -- 151
		safeTop = 0 -- 151
	end -- 151
	local out = {} -- 153
	if count <= 0 then -- 154
		return out -- 155
	end -- 155
	if expanded then -- 157
		local cardW = touchMode and 220 or 210 -- 158
		local cardH = touchMode and 248 or 244 -- 159
		local gap = math.min( -- 160
			18, -- 160
			math.max( -- 160
				10, -- 160
				(uiW - 80 - count * cardW) / math.max(1, count - 1) -- 160
			) -- 160
		) -- 160
		local actualW = math.min(cardW, (uiW - 64 - gap * (count - 1)) / count) -- 161
		local totalW = count * actualW + (count - 1) * gap -- 162
		local startX = (uiW - totalW) * 0.5 -- 163
		local y = math.max(138, uiH - 122 - safeTop - cardH) -- 165
		local i = 0 -- 166
		do -- 166
			i = 0 -- 167
			while i < count do -- 167
				out[#out + 1] = Rect(startX + i * (actualW + gap), y, actualW, cardH) -- 168
				i = i + 1 -- 167
			end -- 167
		end -- 167
		return out -- 170
	end -- 170
	local cardW = touchMode and 202 or 188 -- 172
	local cardH = touchMode and 48 or 40 -- 173
	local gap = 12 -- 174
	local totalW = count * cardW + (count - 1) * gap -- 175
	local startX = (uiW - totalW) * 0.5 -- 176
	local y = uiH - (touchMode and 116 or 106) - safeTop -- 177
	local i = 0 -- 178
	do -- 178
		i = 0 -- 179
		while i < count do -- 179
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 180
			i = i + 1 -- 179
		end -- 179
	end -- 179
	return out -- 182
end -- 145
local function stageOrderNumeral(roomKey) -- 185
	if roomKey == "escort1" or roomKey == "s1-crossroad" then -- 186
		return "壹" -- 186
	end -- 186
	if roomKey == "escort2" or roomKey == "s2-drygoods" then -- 187
		return "贰" -- 187
	end -- 187
	if roomKey == "escort3" or roomKey == "s3-archway" then -- 188
		return "叁" -- 188
	end -- 188
	if roomKey == "escort4" or roomKey == "c1-yard" then -- 189
		return "肆" -- 189
	end -- 189
	if roomKey == "escort5" or roomKey == "c2-granary" then -- 190
		return "伍" -- 190
	end -- 190
	return "壹" -- 191
end -- 185
local function stageReadableName(roomKey) -- 194
	if roomKey == "escort1" then -- 195
		return "城外巷路 · 第一段" -- 195
	end -- 195
	if roomKey == "escort2" then -- 196
		return "粮棚取材 · 第二段" -- 196
	end -- 196
	if roomKey == "escort3" then -- 197
		return "山腰工台 · 第三段" -- 197
	end -- 197
	if roomKey == "escort4" then -- 198
		return "夜山窄道 · 第四段" -- 198
	end -- 198
	if roomKey == "escort5" then -- 199
		return "塔前山道 · 第五段" -- 199
	end -- 199
	return themeOf(roomKey).titleZh -- 200
end -- 194
____exports.RoguelikeUiPlugin = __TS__Class() -- 203
local RoguelikeUiPlugin = ____exports.RoguelikeUiPlugin -- 203
RoguelikeUiPlugin.name = "RoguelikeUiPlugin" -- 203
function RoguelikeUiPlugin.prototype.____constructor(self, contract, getHudSelected, setHudSelected) -- 275
	self.id = "fe-roguelike-ui" -- 204
	self.drawerState = "hidden" -- 211
	self.manualCompact = false -- 212
	self.expandAnimT = 0 -- 213
	self.staggerTime = 0 -- 214
	self.idleSinceMove = 0 -- 215
	self.hoverSlot = -1 -- 216
	self.focusedSlot = 0 -- 217
	self.cardLiftT = {0, 0, 0} -- 218
	self.focusScale = 1 -- 219
	self.animTime = 0 -- 220
	self.lastOffers = {} -- 223
	self.lastRanks = {} -- 224
	self.lastCardBoxes = {} -- 225
	self.lastUiW = 1280 -- 226
	self.lastUiH = 720 -- 227
	self.lastTouchMode = false -- 228
	self.lastSafeTop = 0 -- 229
	self.expandToggleBox = Rect(0, 0, 0, 0) -- 230
	self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 231
	self.ledgerCloseBox = Rect(0, 0, 0, 0) -- 232
	self.ledgerPanelBox = Rect(0, 0, 0, 0) -- 233
	self.crestPulseMap = {} -- 237
	self.hpBarPulseT = 0 -- 238
	self.xiaomanRippleT = 0 -- 239
	self.ledgerOpen = false -- 242
	self.ledgerAnimT = 0 -- 243
	self.prevKeyV = false -- 244
	self.prevKeyEsc = false -- 245
	self.prevKeyBack = false -- 246
	self.prevLeftDown = false -- 247
	self.pickupBounceMap = {} -- 250
	self.pickupShakeMap = {} -- 251
	self.pickupPops = {} -- 252
	self.lastSuppliesShown = {} -- 253
	self.segmentBannerT = 0 -- 256
	self.segmentBannerHeadline = "" -- 257
	self.segmentBannerSub = "" -- 258
	self.deathRecapT = 0 -- 259
	self.lastAliveRoomKey = "" -- 263
	self.lastAliveRanks = {} -- 264
	self.lastAliveTotalRanks = 0 -- 265
	self.lastAliveWeapon = "standard_gun" -- 266
	self.lastAliveSeed = 0 -- 267
	self.lastMarchTitle = "初启北行" -- 270
	self.lastGuardArcActive = false -- 271
	self.lastReloadArcActive = false -- 272
	self.lastCraftRingActive = false -- 273
	self.contract = contract -- 280
	self.getHudSelected = getHudSelected -- 281
	self.setHudSelected = setHudSelected -- 282
end -- 275
function RoguelikeUiPlugin.prototype.isExpanded(self) -- 285
	return self.drawerState == "expanded" -- 286
end -- 285
function RoguelikeUiPlugin.prototype.isLedgerOpen(self) -- 289
	return self.ledgerOpen -- 290
end -- 289
function RoguelikeUiPlugin.prototype.isModalOverlayActive(self) -- 294
	return self.ledgerOpen or self.deathRecapT > 0.05 -- 295
end -- 294
function RoguelikeUiPlugin.prototype.isSuppressingRoomBanner(self) -- 299
	return self.ledgerOpen or self.deathRecapT > 0.05 or self.drawerState == "expanded" or self.drawerState == "sealing" or self.segmentBannerT > 0.05 -- 300
end -- 299
function RoguelikeUiPlugin.prototype.openLedger(self) -- 307
	self.ledgerOpen = true -- 308
	self.ledgerAnimT = 0 -- 309
end -- 307
function RoguelikeUiPlugin.prototype.closeLedger(self) -- 312
	self.ledgerOpen = false -- 313
end -- 312
function RoguelikeUiPlugin.prototype.toggleLedger(self) -- 316
	if self.ledgerOpen then -- 317
		self:closeLedger() -- 318
	else -- 318
		self:openLedger() -- 320
	end -- 320
end -- 316
function RoguelikeUiPlugin.prototype.setCompact(self, compact) -- 324
	self.manualCompact = compact -- 325
	if #self.lastOffers > 0 and self.sealAnim == nil then -- 326
		self.drawerState = compact and "compact" or "expanded" -- 327
		if not compact then -- 328
			self.expandAnimT = 0 -- 329
			self.staggerTime = 0 -- 330
		end -- 330
	end -- 330
end -- 324
function RoguelikeUiPlugin.prototype.triggerTestDeathRecap(self, roomKey, ranks, weapon) -- 336
	if weapon == nil then -- 336
		weapon = "standard_gun" -- 336
	end -- 336
	local total = 0 -- 337
	local copy = {} -- 338
	for k in pairs(ranks) do -- 339
		if ranks[k] > 0 then -- 340
			copy[k] = ranks[k] -- 341
			total = total + ranks[k] -- 342
		end -- 342
	end -- 342
	self.deathRecapSnap = { -- 345
		roomKey = roomKey, -- 346
		stageName = stageReadableName(roomKey), -- 347
		ranks = copy, -- 348
		totalRanks = total, -- 349
		weaponId = weapon, -- 350
		seed = self.lastAliveSeed -- 351
	} -- 351
	self.deathRecapT = DEATH_RECAP_DURATION -- 353
end -- 336
function RoguelikeUiPlugin.prototype.triggerTestSegmentBanner(self, roomKey, nextKey) -- 357
	if nextKey == nil then -- 357
		nextKey = "" -- 357
	end -- 357
	self.segmentBannerHeadline = stageOrderNumeral(roomKey) .. "程告破" -- 358
	self.segmentBannerSub = nextKey ~= "" and "渐近北塔 · 前往" .. themeOf(nextKey).shortNameZh or "渐近北塔 · 筹策犹在" -- 359
	self.segmentBannerT = SEGMENT_BANNER_DURATION -- 360
end -- 357
function RoguelikeUiPlugin.prototype.getTalentCardRects(self, uiW, uiH, count, touchMode, safeTop) -- 364
	if touchMode == nil then -- 368
		touchMode = false -- 368
	end -- 368
	if safeTop == nil then -- 369
		safeTop = 0 -- 369
	end -- 369
	local useExpanded = self.drawerState ~= "compact" -- 371
	return ____exports.computeRoguelikeCardRects( -- 372
		uiW, -- 372
		uiH, -- 372
		count, -- 372
		useExpanded, -- 372
		touchMode, -- 372
		safeTop -- 372
	) -- 372
end -- 364
function RoguelikeUiPlugin.prototype.getLedgerButtonRect(self) -- 375
	return self.ledgerButtonBox -- 376
end -- 375
function RoguelikeUiPlugin.prototype.getExpandToggleRect(self) -- 379
	return self.expandToggleBox -- 380
end -- 379
function RoguelikeUiPlugin.prototype.getState(self) -- 383
	return { -- 384
		drawerState = self.drawerState, -- 385
		offers = __TS__ArraySlice(self.lastOffers), -- 386
		focusedSlot = self.focusedSlot, -- 387
		focusTimeScale = self.focusScale, -- 388
		ledgerOpen = self.ledgerOpen, -- 389
		sealingActive = self.drawerState == "sealing", -- 390
		absorbingActive = self.drawerState == "absorbing", -- 391
		segmentBannerActive = self.segmentBannerT > 0.01, -- 392
		deathRecapActive = self.deathRecapT > 0.01, -- 393
		deathRecapRoom = self.deathRecapSnap ~= nil and self.deathRecapSnap.roomKey or "", -- 394
		deathRecapCount = self.deathRecapSnap ~= nil and self.deathRecapSnap.totalRanks or 0, -- 395
		marchTitle = self.lastMarchTitle, -- 396
		suppliesShown = __TS__ArraySlice(self.lastSuppliesShown), -- 397
		activeGuardArc = self.lastGuardArcActive, -- 398
		activeReloadArc = self.lastReloadArcActive, -- 399
		activeCraftRing = self.lastCraftRingActive, -- 400
		lastCardBoxes = __TS__ArraySlice(self.lastCardBoxes), -- 401
		ledgerButtonBox = self.ledgerButtonBox, -- 402
		expandToggleBox = self.expandToggleBox -- 403
	} -- 403
end -- 383
function RoguelikeUiPlugin.prototype.onBindPlay(self, _p, view) -- 407
	local rg = view.roguelike -- 408
	self.manualCompact = false -- 409
	self.expandAnimT = 0 -- 410
	self.staggerTime = 0 -- 411
	self.idleSinceMove = 0 -- 412
	self.hoverSlot = -1 -- 413
	self.focusedSlot = 0 -- 414
	self.cardLiftT = {0, 0, 0} -- 415
	self.sealAnim = nil -- 416
	self.ledgerOpen = false -- 417
	self.ledgerAnimT = 0 -- 418
	self.pickupBounceMap = {} -- 419
	self.pickupShakeMap = {} -- 420
	self.pickupPops = {} -- 421
	self.crestPulseMap = {} -- 422
	self.hpBarPulseT = 0 -- 423
	self.xiaomanRippleT = 0 -- 424
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 425
	self.lastRanks = {} -- 426
	for k in pairs(rg.ranks) do -- 427
		self.lastRanks[k] = rg.ranks[k] -- 428
	end -- 428
	if rg.active then -- 430
		self.lastAliveRoomKey = rg.roomKey -- 431
		self.lastAliveRanks = {} -- 432
		for k in pairs(rg.ranks) do -- 433
			if rg.ranks[k] > 0 then -- 434
				self.lastAliveRanks[k] = rg.ranks[k] -- 435
			end -- 435
		end -- 435
		self.lastAliveTotalRanks = rg.totalRanks -- 438
		self.lastAliveWeapon = rg.equippedWeapon -- 439
		self.lastAliveSeed = rg.seed -- 440
	end -- 440
	self.drawerState = #rg.offers > 0 and "expanded" or "hidden" -- 442
	self.focusScale = 1 -- 443
	if self.contract ~= nil then -- 444
		self.contract:setFocusTimeScale(1) -- 445
	end -- 445
	self:resetInputEdges() -- 447
end -- 407
function RoguelikeUiPlugin.prototype.resetInputEdges(self) -- 451
	if type(Keyboard) ~= "nil" then -- 452
		self.prevKeyV = Keyboard:isKeyPressed("V") -- 453
		self.prevKeyEsc = Keyboard:isKeyPressed("Escape") -- 454
		self.prevKeyBack = Keyboard:isKeyPressed("BackSpace") -- 455
	end -- 455
	local ____temp_0 -- 457
	if type(Mouse) ~= "nil" then -- 457
		____temp_0 = Mouse.leftButtonPressed -- 457
	else -- 457
		____temp_0 = false -- 457
	end -- 457
	self.prevLeftDown = ____temp_0 -- 457
end -- 451
function RoguelikeUiPlugin.prototype.startSealAnimation(self, talentId, ctx) -- 460
	local pickedSlot = __TS__ArrayIndexOf(self.lastOffers, talentId) -- 461
	if pickedSlot < 0 then -- 462
		pickedSlot = clamp( -- 463
			self.focusedSlot, -- 463
			0, -- 463
			math.max(0, #self.lastOffers - 1) -- 463
		) -- 463
	end -- 463
	local boxes = #self.lastCardBoxes > 0 and __TS__ArraySlice(self.lastCardBoxes) or ____exports.computeRoguelikeCardRects( -- 465
		ctx.uiW, -- 468
		ctx.uiH, -- 469
		math.max(1, #self.lastOffers), -- 470
		self.drawerState ~= "compact", -- 471
		ctx.input:isTouchMode(), -- 472
		(ctx.safeUi or ZERO_SAFE_INSETS).top -- 473
	) -- 473
	local pickedBox = boxes[pickedSlot + 1] or Rect(ctx.uiW * 0.5 - 100, ctx.uiH * 0.5 - 60, 200, 120) -- 475
	local meta = resolveTalentVisual(talentId, ctx.view.roguelike) -- 476
	self.sealAnim = { -- 477
		talentId = talentId, -- 478
		pickedSlot = pickedSlot, -- 479
		pickedBox = pickedBox, -- 480
		allBoxes = boxes, -- 481
		allOffers = __TS__ArraySlice(self.lastOffers), -- 482
		elapsed = 0, -- 483
		sealDuration = SEAL_DURATION, -- 484
		absorbDuration = ABSORB_DURATION, -- 485
		targetKind = meta.absorbTarget, -- 486
		fromExpanded = self.drawerState ~= "compact", -- 487
		arrivedPulsed = false -- 488
	} -- 488
	self.drawerState = "sealing" -- 490
	self.hoverSlot = -1 -- 491
	local ____opt_1 = ctx.input:getTouch() -- 492
	if ____opt_1 ~= nil then -- 492
		____opt_1:vibrate(0.024) -- 492
	end -- 492
	if ctx.view.backCarry.active then -- 493
		self.xiaomanRippleT = 0.78 -- 494
	end -- 494
end -- 460
function RoguelikeUiPlugin.prototype.detectPickedTalentFromRankDiff(self, nowRanks) -- 498
	for k in pairs(nowRanks) do -- 499
		if (nowRanks[k] or 0) > (self.lastRanks[k] or 0) then -- 500
			return k -- 501
		end -- 501
	end -- 501
	return self.lastOffers[clamp( -- 504
		self.focusedSlot, -- 504
		0, -- 504
		math.max(0, #self.lastOffers - 1) -- 504
	) + 1] or "" -- 504
end -- 498
function RoguelikeUiPlugin.prototype.update(self, ctx) -- 507
	local rg = ctx.view.roguelike -- 508
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 509
	local touchMode = ctx.input:isTouchMode() -- 510
	self.lastUiW = ctx.uiW -- 511
	self.lastUiH = ctx.uiH -- 512
	self.lastTouchMode = touchMode -- 513
	self.lastSafeTop = safe.top -- 514
	self.lastMarchTitle = deriveMarchTitle(rg).title -- 515
	if ctx.paused then -- 518
		self:resetInputEdges() -- 519
		return -- 520
	end -- 520
	local udt = math.max(0, ctx.uiDt) -- 523
	self.animTime = self.animTime + udt -- 524
	if ctx.events.segmentDone and ctx.events.segmentKey ~= "" then -- 528
		self.segmentBannerHeadline = stageOrderNumeral(ctx.events.segmentKey) .. "程告破" -- 529
		self.segmentBannerSub = ctx.events.segmentNext ~= "" and "渐近北塔 · 前往" .. themeOf(ctx.events.segmentNext).shortNameZh or "渐近北塔 · 筹策犹在" -- 530
		self.segmentBannerT = SEGMENT_BANNER_DURATION -- 533
	end -- 533
	if ctx.events.campaignFailedReset then -- 536
		local fallenRoom = ctx.events.campaignFailedRoom ~= "" and ctx.events.campaignFailedRoom or self.lastAliveRoomKey -- 537
		local copyRanks = {} -- 538
		for k in pairs(self.lastAliveRanks) do -- 539
			copyRanks[k] = self.lastAliveRanks[k] -- 540
		end -- 540
		self.deathRecapSnap = { -- 542
			roomKey = fallenRoom ~= "" and fallenRoom or "escort1", -- 543
			stageName = stageReadableName(fallenRoom ~= "" and fallenRoom or "escort1"), -- 544
			ranks = copyRanks, -- 545
			totalRanks = self.lastAliveTotalRanks, -- 546
			weaponId = self.lastAliveWeapon, -- 547
			seed = self.lastAliveSeed -- 548
		} -- 548
		self.deathRecapT = DEATH_RECAP_DURATION -- 550
		self.ledgerOpen = false -- 551
	elseif rg.active and ctx.p.player.alive and ctx.p.hp > 0 then -- 552
		self.lastAliveRoomKey = rg.roomKey -- 554
		self.lastAliveRanks = {} -- 555
		for k in pairs(rg.ranks) do -- 556
			if rg.ranks[k] > 0 then -- 557
				self.lastAliveRanks[k] = rg.ranks[k] -- 558
			end -- 558
		end -- 558
		self.lastAliveTotalRanks = rg.totalRanks -- 561
		self.lastAliveWeapon = rg.equippedWeapon -- 562
		self.lastAliveSeed = rg.seed -- 563
	end -- 563
	if ctx.events.pickupTaken and ctx.events.pickupKind ~= "" then -- 566
		self.pickupBounceMap[ctx.events.pickupKind] = 0.52 -- 567
		local ____self_pickupPops_3 = self.pickupPops -- 568
		____self_pickupPops_3[#____self_pickupPops_3 + 1] = {kind = ctx.events.pickupKind, timer = 0.72, maxTimer = 0.72} -- 568
		if #self.pickupPops > 6 then -- 569
			table.remove(self.pickupPops, 1) -- 570
		end -- 570
	end -- 570
	if ctx.events.pickupRejected and ctx.events.pickupRejectedKind ~= "" then -- 573
		self.pickupShakeMap[ctx.events.pickupRejectedKind] = 0.42 -- 574
	end -- 574
	if self.segmentBannerT > 0 then -- 578
		self.segmentBannerT = math.max(0, self.segmentBannerT - udt) -- 579
	end -- 579
	if self.hpBarPulseT > 0 then -- 581
		self.hpBarPulseT = math.max(0, self.hpBarPulseT - udt) -- 582
	end -- 582
	if self.xiaomanRippleT > 0 then -- 584
		self.xiaomanRippleT = math.max(0, self.xiaomanRippleT - udt) -- 585
	end -- 585
	for k in pairs(self.crestPulseMap) do -- 587
		if self.crestPulseMap[k] > 0 then -- 588
			self.crestPulseMap[k] = math.max(0, self.crestPulseMap[k] - udt) -- 589
		end -- 589
	end -- 589
	for k in pairs(self.pickupBounceMap) do -- 592
		if self.pickupBounceMap[k] > 0 then -- 593
			self.pickupBounceMap[k] = math.max(0, self.pickupBounceMap[k] - udt) -- 594
		end -- 594
	end -- 594
	for k in pairs(self.pickupShakeMap) do -- 597
		if self.pickupShakeMap[k] > 0 then -- 598
			self.pickupShakeMap[k] = math.max(0, self.pickupShakeMap[k] - udt) -- 599
		end -- 599
	end -- 599
	local pi = 0 -- 602
	local pw = 0 -- 603
	do -- 603
		pi = 0 -- 604
		while pi < #self.pickupPops do -- 604
			local pop = self.pickupPops[pi + 1] -- 605
			pop.timer = pop.timer - udt -- 606
			if pop.timer > 0 then -- 607
				self.pickupPops[pw + 1] = pop -- 608
				pw = pw + 1 -- 609
			end -- 609
			pi = pi + 1 -- 604
		end -- 604
	end -- 604
	__TS__ArraySetLength(self.pickupPops, pw) -- 612
	if self.deathRecapT > 0 then -- 615
		local elapsedRecap = DEATH_RECAP_DURATION - self.deathRecapT -- 616
		local wantSkip = elapsedRecap > 0.25 and (math.abs(ctx.input.moveX) > 0.2 or ctx.input.uiPressed or ctx.input.fire.pressed or ctx.input.interact.pressed or ctx.input.navConfirm) -- 617
		self.deathRecapT = math.max(0, self.deathRecapT - udt * (wantSkip and 4.2 or 1)) -- 624
	end -- 624
	local hadOffers = #self.lastOffers > 0 -- 628
	local hasOffers = #rg.offers > 0 -- 629
	if ctx.events.talentPicked and ctx.events.talentPickedId ~= "" then -- 630
		self:startSealAnimation(ctx.events.talentPickedId, ctx) -- 631
	elseif hadOffers and not hasOffers and self.sealAnim == nil then -- 632
		local diffId = self:detectPickedTalentFromRankDiff(rg.ranks) -- 633
		if diffId ~= "" then -- 634
			self:startSealAnimation(diffId, ctx) -- 635
		end -- 635
	elseif not hadOffers and hasOffers then -- 637
		self.sealAnim = nil -- 639
		self.drawerState = "expanded" -- 640
		self.manualCompact = false -- 641
		self.expandAnimT = 0 -- 642
		self.staggerTime = 0 -- 643
		self.idleSinceMove = 0 -- 644
		self.hoverSlot = -1 -- 645
		self.cardLiftT = {} -- 646
		local ci = 0 -- 647
		do -- 647
			ci = 0 -- 648
			while ci < #rg.offers do -- 648
				local ____self_cardLiftT_4 = self.cardLiftT -- 649
				____self_cardLiftT_4[#____self_cardLiftT_4 + 1] = 0 -- 649
				ci = ci + 1 -- 648
			end -- 648
		end -- 648
		ctx.audio:playUi("ui:talent_appear", "assets/audio/ui/talent_appear.wav", 0.68, 0.25) -- 651
	end -- 651
	if self.sealAnim ~= nil then -- 655
		local ____self_sealAnim_5, ____elapsed_6 = self.sealAnim, "elapsed" -- 656
		____self_sealAnim_5[____elapsed_6] = ____self_sealAnim_5[____elapsed_6] + udt -- 656
		local totalDur = self.sealAnim.sealDuration + self.sealAnim.absorbDuration -- 657
		if self.sealAnim.elapsed < self.sealAnim.sealDuration then -- 658
			self.drawerState = "sealing" -- 659
		elseif self.sealAnim.elapsed < totalDur then -- 660
			self.drawerState = "absorbing" -- 661
		else -- 661
			if not self.sealAnim.arrivedPulsed then -- 663
				self.sealAnim.arrivedPulsed = true -- 664
				self.crestPulseMap[self.sealAnim.talentId] = 0.72 -- 665
				if self.sealAnim.targetKind == "hp" then -- 666
					self.hpBarPulseT = 0.7 -- 667
				end -- 667
			end -- 667
			self.sealAnim = nil -- 670
			self.drawerState = hasOffers and (self.manualCompact and "compact" or "expanded") or "hidden" -- 671
		end -- 671
	elseif not hasOffers then -- 673
		self.drawerState = "hidden" -- 674
	end -- 674
	local modalBlocking = ctx.view.reloadSession.active or ctx.view.craftBench.active -- 678
	self:processLedgerAndCardInputs(ctx, rg, modalBlocking) -- 679
	if self.sealAnim == nil and hasOffers then -- 681
		local movingOrActing = math.abs(ctx.input.moveX) > 0.15 or math.abs(ctx.input.moveY) > 0.15 or ctx.input.jump.pressed or ctx.input.fire.pressed and self.hoverSlot < 0 or modalBlocking -- 682
		if self.drawerState == "expanded" then -- 687
			self.expandAnimT = math.min(1, self.expandAnimT + udt / 0.22) -- 688
			self.staggerTime = self.staggerTime + udt -- 689
			if movingOrActing then -- 690
				self.drawerState = "compact" -- 691
				self.idleSinceMove = 0 -- 692
			end -- 692
		elseif self.drawerState == "compact" then -- 694
			if movingOrActing or ctx.input.fire.held or self.ledgerOpen or self.deathRecapT > 0.05 then -- 695
				self.idleSinceMove = 0 -- 696
			elseif not self.manualCompact then -- 697
				self.idleSinceMove = self.idleSinceMove + udt -- 698
				if self.idleSinceMove >= AUTO_REEXPAND_IDLE_SEC then -- 699
					self.drawerState = "expanded" -- 700
					self.expandAnimT = 0 -- 701
					self.staggerTime = 0 -- 702
					self.idleSinceMove = 0 -- 703
				end -- 703
			end -- 703
		end -- 703
	end -- 703
	while #self.cardLiftT < #rg.offers do -- 710
		local ____self_cardLiftT_7 = self.cardLiftT -- 711
		____self_cardLiftT_7[#____self_cardLiftT_7 + 1] = 0 -- 711
	end -- 711
	local li = 0 -- 713
	do -- 713
		li = 0 -- 714
		while li < #rg.offers do -- 714
			local isHot = ctx.input.inputMode == "gamepad" and li == self.focusedSlot or ctx.input.inputMode ~= "gamepad" and li == self.hoverSlot -- 715
			local target = isHot and 1 or 0 -- 717
			local ____self_cardLiftT_8, ____temp_9 = self.cardLiftT, li + 1 -- 718
			____self_cardLiftT_8[____temp_9] = ____self_cardLiftT_8[____temp_9] + (target - self.cardLiftT[li + 1]) * math.min(1, udt * 14) -- 718
			li = li + 1 -- 714
		end -- 714
	end -- 714
	local wantSlowFocus = not modalBlocking and self.deathRecapT <= 0.05 and (self.ledgerOpen or self.drawerState == "expanded" and hasOffers) -- 722
	local targetScale = wantSlowFocus and EXPANDED_FOCUS_SCALE or 1 -- 725
	local speed = wantSlowFocus and 5.2 or 6 -- 726
	if self.focusScale < targetScale then -- 727
		self.focusScale = math.min(targetScale, self.focusScale + udt * speed) -- 728
	elseif self.focusScale > targetScale then -- 729
		self.focusScale = math.max(targetScale, self.focusScale - udt * speed) -- 730
	end -- 730
	if self.contract ~= nil then -- 732
		self.contract:setFocusTimeScale(self.focusScale) -- 733
	end -- 733
	if not ctx.view.reloadSession.active then -- 735
		ctx.audio:setWorldPlaySpeed(math.max( -- 736
			0.25, -- 736
			math.min(1, self.focusScale) -- 736
		)) -- 736
	end -- 736
	if self.ledgerOpen then -- 739
		self.ledgerAnimT = math.min(1, self.ledgerAnimT + udt / 0.2) -- 740
	end -- 740
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 744
	self.lastRanks = {} -- 745
	for k in pairs(rg.ranks) do -- 746
		self.lastRanks[k] = rg.ranks[k] -- 747
	end -- 747
	if hasOffers then -- 749
		self.lastCardBoxes = self:getTalentCardRects( -- 750
			ctx.uiW, -- 750
			ctx.uiH, -- 750
			#rg.offers, -- 750
			touchMode, -- 750
			safe.top -- 750
		) -- 750
	else -- 750
		self.lastCardBoxes = {} -- 752
	end -- 752
end -- 507
function RoguelikeUiPlugin.prototype.processLedgerAndCardInputs(self, ctx, rg, modalBlocking) -- 756
	local touchMode = ctx.input:isTouchMode() -- 761
	local useUiPtr = ctx.input.uiInside or ctx.input.uiPressed or ctx.input.uiHeld -- 762
	local ptrX = (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 763
	local ptrY = (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 764
	local ____useUiPtr_10 -- 765
	if useUiPtr then -- 765
		____useUiPtr_10 = ctx.input.uiInside -- 765
	else -- 765
		____useUiPtr_10 = ctx.input.inside -- 765
	end -- 765
	local inside = ____useUiPtr_10 -- 765
	local ptr = Vec2(ptrX, ptrY) -- 766
	local mouseLeftDown = ctx.input.inputMode == "kbm" and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 768
	local leftClick = ctx.input.uiPressed or mouseLeftDown and not self.prevLeftDown -- 769
	self.prevLeftDown = mouseLeftDown -- 770
	local vPressed = false -- 772
	local escPressed = false -- 773
	local backPressed = false -- 774
	if type(Keyboard) ~= "nil" then -- 775
		local vDown = Keyboard:isKeyPressed("V") -- 776
		local escDown = Keyboard:isKeyPressed("Escape") -- 777
		local backDown = Keyboard:isKeyPressed("BackSpace") -- 778
		vPressed = vDown and not self.prevKeyV -- 779
		escPressed = escDown and not self.prevKeyEsc -- 780
		backPressed = backDown and not self.prevKeyBack -- 781
		self.prevKeyV = vDown -- 782
		self.prevKeyEsc = escDown -- 783
		self.prevKeyBack = backDown -- 784
	end -- 784
	if ctx.input.touchZoneTap == "ledger:toggle" and rg.active and not modalBlocking then -- 788
		ctx.input.touchZoneTap = "" -- 789
		self:toggleLedgerWithSound(ctx) -- 790
		return -- 791
	end -- 791
	if vPressed and rg.active and not modalBlocking then -- 795
		self:toggleLedgerWithSound(ctx) -- 796
		return -- 797
	end -- 797
	if self.ledgerOpen then -- 800
		if modalBlocking or escPressed or backPressed or ctx.input.navBack then -- 801
			self.ledgerOpen = false -- 802
			ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 803
			return -- 804
		end -- 804
		if leftClick and inside then -- 806
			if self.ledgerCloseBox:containsPoint(ptr) or not self.ledgerPanelBox:containsPoint(ptr) then -- 807
				self.ledgerOpen = false -- 808
				ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 809
			end -- 809
		end -- 809
		return -- 812
	end -- 812
	if rg.active and not modalBlocking and leftClick and inside and self.ledgerButtonBox.width > 0 and self.ledgerButtonBox:containsPoint(ptr) then -- 816
		self:toggleLedgerWithSound(ctx) -- 818
		return -- 819
	end -- 819
	if #rg.offers > 0 and not modalBlocking and leftClick and inside and self.expandToggleBox.width > 0 and self.expandToggleBox:containsPoint(ptr) then -- 823
		local nextCompact = self.drawerState == "expanded" -- 825
		self:setCompact(nextCompact) -- 826
		ctx.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 827
		return -- 828
	end -- 828
	if #rg.offers > 0 and not modalBlocking and self.sealAnim == nil then -- 832
		if ctx.input.inputMode == "gamepad" then -- 833
			local hudSel = self.getHudSelected ~= nil and self.getHudSelected() or self.focusedSlot -- 834
			local clamped = clamp(hudSel, 0, #rg.offers - 1) -- 835
			if clamped ~= self.focusedSlot then -- 836
				self.focusedSlot = clamped -- 837
				ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 838
			end -- 838
			self.hoverSlot = -1 -- 840
		elseif not touchMode and inside then -- 841
			local boxes = self:getTalentCardRects( -- 842
				ctx.uiW, -- 842
				ctx.uiH, -- 842
				#rg.offers, -- 842
				false, -- 842
				(ctx.safeUi or ZERO_SAFE_INSETS).top -- 842
			) -- 842
			local hit = -1 -- 843
			local i = 0 -- 844
			do -- 844
				i = 0 -- 845
				while i < #boxes do -- 845
					if boxes[i + 1]:containsPoint(ptr) then -- 846
						hit = i -- 847
						break -- 848
					end -- 848
					i = i + 1 -- 845
				end -- 845
			end -- 845
			if hit ~= self.hoverSlot then -- 851
				self.hoverSlot = hit -- 852
				if hit >= 0 then -- 853
					self.focusedSlot = hit -- 854
					if self.setHudSelected ~= nil then -- 855
						self.setHudSelected(hit) -- 856
					end -- 856
					ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045) -- 858
				end -- 858
			end -- 858
		else -- 858
			self.hoverSlot = -1 -- 862
		end -- 862
	else -- 862
		self.hoverSlot = -1 -- 865
	end -- 865
end -- 756
function RoguelikeUiPlugin.prototype.toggleLedgerWithSound(self, ctx) -- 869
	if self.ledgerOpen then -- 870
		self.ledgerOpen = false -- 871
		ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 872
	else -- 872
		self.ledgerOpen = true -- 874
		self.ledgerAnimT = 0 -- 875
		ctx.audio:playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08) -- 876
	end -- 876
end -- 869
function RoguelikeUiPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 882
	local p = ctx.p -- 888
	local rg = ctx.view.roguelike -- 889
	local cam = ctx.cam -- 890
	self.lastGuardArcActive = false -- 892
	self.lastReloadArcActive = false -- 893
	self.lastCraftRingActive = false -- 894
	if ctx.view.visualMode == "museum" then -- 896
		return -- 897
	end -- 897
	local bi = 0 -- 901
	do -- 901
		bi = 0 -- 902
		while bi < #p.boxes do -- 902
			do -- 902
				local b = p.boxes[bi + 1] -- 903
				if b.broken == true or b.hidden == true or b.id == nil then -- 904
					goto __continue152 -- 905
				end -- 905
				local ps = p.run.props[b.id] -- 907
				if ps == nil then -- 908
					goto __continue152 -- 909
				end -- 909
				local depth = b.depth ~= nil and (b.depth.min + b.depth.max) * 0.5 or 0 -- 911
				local x0 = cam:sx(b.x0) -- 912
				local x1 = cam:sx(b.x1) -- 913
				local y0 = cam:sy(b.y0, depth) -- 914
				local y1 = cam:sy(b.y1, depth) -- 915
				local bw = x1 - x0 -- 916
				local bh = y1 - y0 -- 917
				if bw <= 2 or bh <= 2 then -- 918
					goto __continue152 -- 919
				end -- 919
				if ps.wedge == true then -- 921
					local ww = math.max( -- 923
						6, -- 923
						cam:len(6.5) -- 923
					) -- 923
					local wh = math.max( -- 924
						7, -- 924
						cam:len(8) -- 924
					) -- 924
					fgDraw:drawPolygon( -- 925
						{ -- 925
							Vec2(x0 - ww * 0.7, y0), -- 926
							Vec2(x0 + ww * 0.45, y0), -- 927
							Vec2(x0 + ww * 0.2, y0 + wh), -- 928
							Vec2(x0 - ww * 0.25, y0 + wh * 0.55) -- 929
						}, -- 929
						toColor(PALETTE.emerald, 220), -- 930
						1.1, -- 930
						toColor(PALETTE.moonPale, 220) -- 930
					) -- 930
					fgDraw:drawPolygon( -- 931
						{ -- 931
							Vec2(x1 + ww * 0.7, y0), -- 932
							Vec2(x1 - ww * 0.45, y0), -- 933
							Vec2(x1 - ww * 0.2, y0 + wh), -- 934
							Vec2(x1 + ww * 0.25, y0 + wh * 0.55) -- 935
						}, -- 935
						toColor(PALETTE.emerald, 220), -- 936
						1.1, -- 936
						toColor(PALETTE.moonPale, 220) -- 936
					) -- 936
					fgDraw:drawSegment( -- 937
						Vec2(x0 + 2, y1 - 1), -- 937
						Vec2(x1 - 2, y1 - 1), -- 937
						1.6, -- 937
						toColor(PALETTE.emerald, 210) -- 937
					) -- 937
				end -- 937
				if ps.hp == 1 and not ps.broken then -- 939
					local mx = (x0 + x1) * 0.5 -- 941
					fgDraw:drawSegment( -- 942
						Vec2(mx - bw * 0.14, y1 - bh * 0.08), -- 942
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 942
						1.4, -- 942
						Color(14, 12, 16, 220) -- 942
					) -- 942
					fgDraw:drawSegment( -- 943
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 943
						Vec2(mx - bw * 0.08, y0 + bh * 0.14), -- 943
						1.3, -- 943
						Color(14, 12, 16, 220) -- 943
					) -- 943
					fgDraw:drawSegment( -- 944
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 944
						Vec2(mx + bw * 0.22, y0 + bh * 0.34), -- 944
						1, -- 944
						Color(214, 186, 146, 150) -- 944
					) -- 944
				end -- 944
			end -- 944
			::__continue152:: -- 944
			bi = bi + 1 -- 902
		end -- 902
	end -- 902
	if p.childMode or not p.player.alive then -- 948
		return -- 949
	end -- 949
	local pl = p.player -- 952
	local px = cam:sx(pl.x) -- 953
	local pyCenter = cam:sy(pl.y + pl.h * 0.56, pl.depth) -- 954
	local headY = cam:sy(pl.y + pl.h + 10, pl.depth) -- 955
	local facing = pl.facing >= 0 and 1 or -1 -- 956
	local guardRank = rg.ranks.guard or 0 -- 959
	if rg.activeInvulnTicks > 0 and guardRank > 0 then -- 960
		self.lastGuardArcActive = true -- 961
		local frac = clamp( -- 962
			rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 962
			0, -- 962
			1 -- 962
		) -- 962
		local arcR = math.max( -- 963
			18, -- 963
			cam:len(20) -- 963
		) -- 963
		local halfSpan = (0.35 + 0.85 * frac) * math.pi * 0.55 -- 964
		local baseAngle = facing > 0 and 0 or math.pi -- 965
		drawBrushArc( -- 966
			fgDraw, -- 967
			px + facing * cam:len(4), -- 968
			pyCenter, -- 969
			arcR, -- 970
			arcR * 1.18, -- 971
			baseAngle - halfSpan, -- 972
			baseAngle + halfSpan, -- 973
			2.4, -- 974
			toColor( -- 975
				PALETTE.emerald, -- 975
				math.floor(140 + 95 * frac + 0.5) -- 975
			), -- 975
			14 -- 976
		) -- 976
		drawBrushArc( -- 978
			fgGlow, -- 979
			px + facing * cam:len(4), -- 980
			pyCenter, -- 981
			arcR * 1.12, -- 982
			arcR * 1.28, -- 983
			baseAngle - halfSpan * 0.82, -- 984
			baseAngle + halfSpan * 0.82, -- 985
			1.3, -- 986
			toColor( -- 987
				PALETTE.moonPale, -- 987
				math.floor(90 * frac + 0.5) -- 987
			), -- 987
			12 -- 988
		) -- 988
	end -- 988
	if rg.activeReloadTicks > 0 and not ctx.view.reloadSession.active then -- 993
		self.lastReloadArcActive = true -- 994
		local totalRel = math.max(1, rg.reloadTicksNow) -- 995
		local prog = clamp(1 - rg.activeReloadTicks / totalRel, 0, 1) -- 996
		local rx = px + facing * cam:len(14) -- 997
		local ry = headY + cam:len(4) -- 998
		local rr = math.max( -- 999
			9, -- 999
			cam:len(10) -- 999
		) -- 999
		local hasReloadRank = (rg.ranks.reload or 0) > 0 -- 1000
		local arcCol = hasReloadRank and PALETTE.amberCore or PALETTE.silkLine -- 1001
		drawBrushArc( -- 1002
			fgDraw, -- 1002
			rx, -- 1002
			ry, -- 1002
			rr, -- 1002
			rr, -- 1002
			math.pi * 0.15, -- 1002
			math.pi * 0.85, -- 1002
			1.4, -- 1002
			toColor(PALETTE.inkWash, 160), -- 1002
			10 -- 1002
		) -- 1002
		local endA = math.pi * 0.85 - math.pi * 0.7 * prog -- 1003
		drawBrushArc( -- 1004
			fgDraw, -- 1004
			rx, -- 1004
			ry, -- 1004
			rr, -- 1004
			rr, -- 1004
			endA, -- 1004
			math.pi * 0.85, -- 1004
			2.1, -- 1004
			toColor(arcCol, 230), -- 1004
			10 -- 1004
		) -- 1004
		if hasReloadRank then -- 1005
			local sparkX = rx + math.cos(endA) * rr -- 1006
			local sparkY = ry + math.sin(endA) * rr -- 1007
			fgGlow:drawDot( -- 1008
				Vec2(sparkX, sparkY), -- 1008
				2.8, -- 1008
				toColor(PALETTE.amberCore, 240) -- 1008
			) -- 1008
			fillRadialGlow( -- 1009
				fgGlow, -- 1009
				sparkX, -- 1009
				sparkY, -- 1009
				9, -- 1009
				9, -- 1009
				toColor(PALETTE.amber, 70), -- 1009
				Color(214, 186, 146, 0), -- 1009
				10 -- 1009
			) -- 1009
		end -- 1009
	end -- 1009
	if rg.activeCraftTicks > 0 then -- 1014
		self.lastCraftRingActive = true -- 1015
		local totalCraft = math.max(1, rg.craftTicksNow) -- 1016
		local prog = clamp(rg.activeCraftTicks / totalCraft, 0, 1) -- 1017
		local cx = px + facing * cam:len(12) -- 1018
		local cy = headY + cam:len(8) -- 1019
		local cr = math.max( -- 1020
			11, -- 1020
			cam:len(12) -- 1020
		) -- 1020
		drawBrushArc( -- 1021
			fgDraw, -- 1021
			cx, -- 1021
			cy, -- 1021
			cr, -- 1021
			cr, -- 1021
			0, -- 1021
			TWO_PI, -- 1021
			1.5, -- 1021
			Color(14, 17, 25, 160), -- 1021
			16 -- 1021
		) -- 1021
		drawBrushArc( -- 1022
			fgDraw, -- 1022
			cx, -- 1022
			cy, -- 1022
			cr, -- 1022
			cr, -- 1022
			math.pi * 0.5, -- 1022
			math.pi * 0.5 - TWO_PI * prog, -- 1022
			2.4, -- 1022
			toColor(PALETTE.amberCore, 240), -- 1022
			16 -- 1022
		) -- 1022
		local k = 0 -- 1023
		do -- 1023
			k = 0 -- 1024
			while k < 4 do -- 1024
				local ph = (self.animTime * 4.6 + k * 0.25) % 1 -- 1025
				local ang = k * 1.57 + ph * 1.4 -- 1026
				local sx = cx + math.cos(ang) * (cr + ph * 10) -- 1027
				local sy = cy + math.sin(ang) * (cr + ph * 8) - ph * 6 -- 1028
				fgDraw:drawSegment( -- 1029
					Vec2(sx - 2, sy), -- 1029
					Vec2(sx + 2, sy + 1.5), -- 1029
					1.3, -- 1029
					toColor( -- 1029
						PALETTE.amber, -- 1029
						math.floor(215 * (1 - ph) + 0.5) -- 1029
					) -- 1029
				) -- 1029
				k = k + 1 -- 1024
			end -- 1024
		end -- 1024
	end -- 1024
	if self.xiaomanRippleT > 0.01 and ctx.view.backCarry.active then -- 1034
		local p01 = 1 - self.xiaomanRippleT / 0.78 -- 1035
		local bx = px - facing * cam:len(8) -- 1036
		local by = cam:sy(pl.y + pl.h * 0.68, pl.depth) -- 1037
		local rr = cam:len(8) + easeOutCubic(p01) * cam:len(22) -- 1038
		local alpha = (1 - p01) * 0.85 -- 1039
		drawBrushArc( -- 1040
			fgGlow, -- 1040
			bx, -- 1040
			by, -- 1040
			rr, -- 1040
			rr, -- 1040
			0, -- 1040
			TWO_PI, -- 1040
			1.5, -- 1040
			toColor( -- 1040
				PALETTE.amberCore, -- 1040
				math.floor(180 * alpha + 0.5) -- 1040
			), -- 1040
			18 -- 1040
		) -- 1040
		fillRadialGlow( -- 1041
			fgGlow, -- 1041
			bx, -- 1041
			by, -- 1041
			rr * 0.8, -- 1041
			rr * 0.8, -- 1041
			toColor( -- 1041
				PALETTE.amber, -- 1041
				math.floor(48 * alpha + 0.5) -- 1041
			), -- 1041
			Color(214, 186, 146, 0), -- 1041
			12 -- 1041
		) -- 1041
	end -- 1041
end -- 882
function RoguelikeUiPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1047
	local rg = ctx.view.roguelike -- 1054
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1055
	local modalBlocking = ctx.view.reloadSession.active or ctx.view.craftBench.active -- 1056
	if rg.active and not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1059
		if rg.showRouteTrack and #rg.stages > 0 then -- 1060
			self:drawNorthwardTrack( -- 1061
				uiDraw, -- 1061
				uiInkDraw, -- 1061
				uiArt, -- 1061
				uiGlow, -- 1061
				ctx, -- 1061
				rg.stages, -- 1061
				safe -- 1061
			) -- 1061
		end -- 1061
		self:drawCrestAndSatchelHud( -- 1063
			uiDraw, -- 1063
			uiInkDraw, -- 1063
			uiArt, -- 1063
			uiGlow, -- 1063
			ctx, -- 1063
			rg, -- 1063
			safe -- 1063
		) -- 1063
	else -- 1063
		self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 1065
	end -- 1065
	if not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1069
		if self.sealAnim ~= nil then -- 1070
			self:drawSealAndAbsorb( -- 1071
				uiDraw, -- 1071
				uiInkDraw, -- 1071
				uiArt, -- 1071
				uiGlow, -- 1071
				ctx, -- 1071
				rg, -- 1071
				self.sealAnim -- 1071
			) -- 1071
		elseif #rg.offers > 0 then -- 1072
			if self.drawerState == "expanded" then -- 1073
				self:drawExpandedTalentCards( -- 1074
					uiDraw, -- 1074
					uiInkDraw, -- 1074
					uiArt, -- 1074
					uiGlow, -- 1074
					ctx, -- 1074
					rg, -- 1074
					safe -- 1074
				) -- 1074
			elseif self.drawerState == "compact" then -- 1075
				self:drawCompactTalentTallies( -- 1076
					uiDraw, -- 1076
					uiInkDraw, -- 1076
					uiArt, -- 1076
					ctx, -- 1076
					rg, -- 1076
					safe -- 1076
				) -- 1076
			end -- 1076
		else -- 1076
			self.expandToggleBox = Rect(0, 0, 0, 0) -- 1079
		end -- 1079
	else -- 1079
		self.expandToggleBox = Rect(0, 0, 0, 0) -- 1082
	end -- 1082
	if self.segmentBannerT > 0.01 then -- 1086
		self:drawSegmentClearRibbon( -- 1087
			uiDraw, -- 1087
			uiInkDraw, -- 1087
			uiArt, -- 1087
			uiGlow, -- 1087
			ctx, -- 1087
			safe -- 1087
		) -- 1087
	end -- 1087
	if self.deathRecapT > 0.01 and self.deathRecapSnap ~= nil then -- 1091
		self:drawDeathRecapOverlay( -- 1092
			uiDraw, -- 1092
			uiInkDraw, -- 1092
			uiArt, -- 1092
			uiGlow, -- 1092
			ctx, -- 1092
			self.deathRecapSnap -- 1092
		) -- 1092
	end -- 1092
	if self.ledgerOpen and rg.active and not modalBlocking then -- 1096
		self:drawBuildLedger( -- 1097
			uiDraw, -- 1097
			uiInkDraw, -- 1097
			uiArt, -- 1097
			uiGlow, -- 1097
			ctx, -- 1097
			rg, -- 1097
			safe -- 1097
		) -- 1097
		return true -- 1098
	end -- 1098
	return self.drawerState == "expanded" and self.hoverSlot >= 0 -- 1101
end -- 1047
function RoguelikeUiPlugin.prototype.drawNorthwardTrack(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, stages, safe) -- 1106
	local cx = ctx.uiW * 0.5 -- 1115
	local y = ctx.uiH - (ctx.view.isRehearsal and 50 or 24) - safe.top -- 1116
	local spanW = math.min(360, ctx.uiW * 0.34) -- 1117
	local x0 = cx - spanW * 0.5 -- 1118
	local step = #stages > 1 and spanW / (#stages - 1) or 0 -- 1119
	drawSilkVeil( -- 1121
		uiDraw, -- 1121
		uiArt, -- 1121
		"rg_track_veil", -- 1121
		cx, -- 1121
		y, -- 1121
		spanW + 108, -- 1121
		28, -- 1121
		PALETTE.inkWash, -- 1121
		0.56, -- 1121
		-1 -- 1121
	) -- 1121
	uiInkDraw:drawSegment( -- 1122
		Vec2(x0, y + 3), -- 1122
		Vec2(x0 + spanW, y + 3), -- 1122
		0.9, -- 1122
		toColor(PALETTE.silkDim, 130) -- 1122
	) -- 1122
	local curIdx = 0 -- 1125
	local i = 0 -- 1126
	do -- 1126
		i = 0 -- 1127
		while i < #stages do -- 1127
			if stages[i + 1].current then -- 1128
				curIdx = i -- 1129
				break -- 1130
			end -- 1130
			i = i + 1 -- 1127
		end -- 1127
	end -- 1127
	if curIdx > 0 then -- 1133
		uiInkDraw:drawSegment( -- 1134
			Vec2(x0, y + 3), -- 1134
			Vec2(x0 + step * curIdx, y + 3), -- 1134
			1.4, -- 1134
			toColor(PALETTE.moonPale, 195) -- 1134
		) -- 1134
	end -- 1134
	do -- 1134
		i = 0 -- 1137
		while i < #stages do -- 1137
			local st = stages[i + 1] -- 1138
			local nx = x0 + step * i -- 1139
			local ny = y + 3 -- 1140
			if st.current then -- 1141
				local breathe = 0.82 + 0.18 * math.sin(self.animTime * 4.2) -- 1142
				fillRadialGlow( -- 1143
					uiGlow, -- 1143
					nx, -- 1143
					ny, -- 1143
					14, -- 1143
					14, -- 1143
					toColor(PALETTE.rouge, 46 * breathe), -- 1143
					Color(182, 58, 56, 0), -- 1143
					10 -- 1143
				) -- 1143
				drawBlossomDot( -- 1144
					uiInkDraw, -- 1144
					uiArt, -- 1144
					"rg_st_cur_" .. tostring(i), -- 1144
					nx, -- 1144
					ny, -- 1144
					13, -- 1144
					PALETTE.rouge, -- 1144
					0.96, -- 1144
					4 -- 1144
				) -- 1144
			elseif st.cleared then -- 1145
				drawDiamond( -- 1146
					uiInkDraw, -- 1146
					nx, -- 1146
					ny, -- 1146
					4.2, -- 1146
					4.2, -- 1146
					toColor(PALETTE.moonPale, 225), -- 1146
					0.8, -- 1146
					toColor(PALETTE.cyan, 180) -- 1146
				) -- 1146
			elseif st.isBench or st.isFinal then -- 1147
				fillRadialGlow( -- 1148
					uiGlow, -- 1148
					nx, -- 1148
					ny, -- 1148
					10, -- 1148
					10, -- 1148
					toColor(PALETTE.amber, 26), -- 1148
					Color(214, 186, 146, 0), -- 1148
					8 -- 1148
				) -- 1148
				drawDiamond( -- 1149
					uiInkDraw, -- 1149
					nx, -- 1149
					ny, -- 1149
					4, -- 1149
					4, -- 1149
					Color(20, 22, 30, 210), -- 1149
					1.1, -- 1149
					toColor(PALETTE.amberCore, 215) -- 1149
				) -- 1149
			else -- 1149
				drawDiamond( -- 1151
					uiInkDraw, -- 1151
					nx, -- 1151
					ny, -- 1151
					3.3, -- 1151
					3.3, -- 1151
					Color(16, 19, 27, 210), -- 1151
					0.9, -- 1151
					toColor(PALETTE.silkDim, 155) -- 1151
				) -- 1151
			end -- 1151
			local labelCol = st.current and PALETTE.textBright or ((st.isBench or st.isFinal) and PALETTE.amberCore or (st.cleared and PALETTE.textMid or PALETTE.textDim)) -- 1153
			ctx.texts:put( -- 1156
				"xs", -- 1157
				st.label, -- 1158
				nx, -- 1159
				ny - 14, -- 1160
				toColor(labelCol), -- 1161
				0.5, -- 1162
				0.5, -- 1163
				"Center", -- 1164
				0.4, -- 1165
				st.current and 0.96 or 0.72, -- 1166
				0.08 -- 1167
			) -- 1167
			i = i + 1 -- 1137
		end -- 1137
	end -- 1137
end -- 1106
function RoguelikeUiPlugin.prototype.drawCrestAndSatchelHud(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1174
	local bx = 28 + safe.left -- 1183
	local hpBaseY = ctx.uiH - 72 - safe.top -- 1184
	local p = ctx.p -- 1185
	if self.hpBarPulseT > 0.01 then -- 1188
		local pA = clamp(self.hpBarPulseT / 0.7, 0, 1) -- 1189
		fillRadialGlow( -- 1190
			uiGlow, -- 1190
			bx + 130, -- 1190
			hpBaseY + 16, -- 1190
			140, -- 1190
			28, -- 1190
			toColor(PALETTE.moonPale, 44 * pA), -- 1190
			Color(232, 236, 234, 0), -- 1190
			12 -- 1190
		) -- 1190
	end -- 1190
	local ____p_isCampaign_16 = p.isCampaign -- 1194
	if ____p_isCampaign_16 then -- 1194
		local ____opt_11 = p.room.campaign -- 1195
		local ____temp_15 = (____opt_11 and ____opt_11.chapter) == "S" -- 1195
		if not ____temp_15 then -- 1195
			local ____opt_13 = p.room.campaign -- 1195
			____temp_15 = (____opt_13 and ____opt_13.chapter) == "C" -- 1195
		end -- 1195
		____p_isCampaign_16 = ____temp_15 -- 1194
	end -- 1194
	local fearVisible = ____p_isCampaign_16 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 1194
	local row1Y = hpBaseY - (fearVisible and 52 or 24) -- 1197
	local learnedIds = {} -- 1200
	local baseOrder = {"vitality", "reload", "guard", "craft"} -- 1201
	local i = 0 -- 1202
	do -- 1202
		i = 0 -- 1203
		while i < #baseOrder do -- 1203
			if (rg.ranks[baseOrder[i + 1]] or 0) > 0 then -- 1204
				learnedIds[#learnedIds + 1] = baseOrder[i + 1] -- 1205
			end -- 1205
			i = i + 1 -- 1203
		end -- 1203
	end -- 1203
	for k in pairs(rg.ranks) do -- 1208
		if (rg.ranks[k] or 0) > 0 and __TS__ArrayIndexOf(learnedIds, k) < 0 then -- 1209
			learnedIds[#learnedIds + 1] = k -- 1210
		end -- 1210
	end -- 1210
	local cursorX = bx -- 1215
	local badgeH = 26 -- 1216
	local rowCenterY = row1Y + 6 -- 1217
	do -- 1217
		i = 0 -- 1218
		while i < #learnedIds do -- 1218
			local tid = learnedIds[i + 1] -- 1219
			local rank = rg.ranks[tid] or 1 -- 1220
			local meta = resolveTalentVisual(tid, rg) -- 1221
			local badgeW = 62 -- 1222
			local pulse = self.crestPulseMap[tid] or 0 -- 1223
			local activeNow = tid == "guard" and rg.activeInvulnTicks > 0 or tid == "reload" and rg.activeReloadTicks > 0 or tid == "craft" and rg.activeCraftTicks > 0 -- 1224
			local glowBoost = math.max( -- 1227
				pulse, -- 1227
				activeNow and 0.55 + 0.35 * math.sin(self.animTime * 8) or 0 -- 1227
			) -- 1227
			if glowBoost > 0.02 then -- 1229
				fillRadialGlow( -- 1230
					uiGlow, -- 1230
					cursorX + badgeW * 0.5, -- 1230
					rowCenterY, -- 1230
					badgeW * 0.72, -- 1230
					20, -- 1230
					toColor(meta.accentCore, 46 * glowBoost), -- 1230
					Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1230
					10 -- 1230
				) -- 1230
			end -- 1230
			uiDraw:drawRoundedRect( -- 1232
				Rect(cursorX, rowCenterY - badgeH * 0.5, badgeW, badgeH), -- 1233
				4, -- 1234
				toColor(activeNow and PALETTE.inkWarm or PALETTE.inkWash, activeNow and 225 or 196), -- 1235
				(activeNow or pulse > 0.05) and 1.3 or 0.85, -- 1236
				toColor((activeNow or pulse > 0.05) and meta.accentCore or meta.accent, activeNow and 235 or 168) -- 1237
			) -- 1237
			drawTalentGlyph( -- 1239
				uiInkDraw, -- 1239
				cursorX + 15, -- 1239
				rowCenterY, -- 1239
				8.2, -- 1239
				tid, -- 1239
				meta.accent, -- 1239
				0.96, -- 1239
				meta.accentCore -- 1239
			) -- 1239
			ctx.texts:put( -- 1240
				"xs", -- 1241
				rankChinese(rank), -- 1242
				cursorX + 41, -- 1243
				rowCenterY, -- 1244
				toColor(meta.accentCore), -- 1245
				0.5, -- 1246
				0.5, -- 1247
				"Center", -- 1248
				0, -- 1249
				0.96, -- 1250
				0.08 -- 1251
			) -- 1251
			if tid == "guard" and rg.activeInvulnTicks > 0 then -- 1254
				local frac = clamp( -- 1255
					rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 1255
					0, -- 1255
					1 -- 1255
				) -- 1255
				uiInkDraw:drawSegment( -- 1256
					Vec2(cursorX + 4, rowCenterY - badgeH * 0.5 + 2), -- 1257
					Vec2(cursorX + 4 + (badgeW - 8) * frac, rowCenterY - badgeH * 0.5 + 2), -- 1258
					2, -- 1259
					toColor(PALETTE.emerald, 240) -- 1260
				) -- 1260
			end -- 1260
			cursorX = cursorX + (badgeW + 6) -- 1263
			i = i + 1 -- 1218
		end -- 1218
	end -- 1218
	local ledgerLabel = ctx.input.inputMode == "kbm" and "札记 V" or "札记" -- 1267
	local ledgerW = ctx.input.inputMode == "kbm" and 64 or 48 -- 1268
	local ledgerRect = Rect(cursorX, rowCenterY - badgeH * 0.5, ledgerW, badgeH) -- 1269
	self.ledgerButtonBox = ledgerRect -- 1270
	local ptrX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 1271
	local ptrY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 1272
	local ledgerHover = not ctx.input:isTouchMode() and (ctx.input.uiInside or ctx.input.inside) and ledgerRect:containsPoint(Vec2(ptrX, ptrY)) -- 1273
	uiDraw:drawRoundedRect( -- 1274
		ledgerRect, -- 1275
		4, -- 1276
		toColor(ledgerHover and PALETTE.rougeSoft or PALETTE.inkWash, ledgerHover and 205 or 176), -- 1277
		0.9, -- 1278
		toColor(ledgerHover and PALETTE.amberCore or PALETTE.silkDim, ledgerHover and 225 or 155) -- 1279
	) -- 1279
	ctx.texts:put( -- 1281
		"xs", -- 1282
		ledgerLabel, -- 1283
		ledgerRect.x + ledgerRect.width * 0.5, -- 1284
		rowCenterY, -- 1285
		toColor(ledgerHover and PALETTE.textBright or PALETTE.amberCore), -- 1286
		0.5, -- 1287
		0.5, -- 1288
		"Center", -- 1289
		0.6, -- 1290
		0.92, -- 1291
		0.08 -- 1292
	) -- 1292
	local touchLandscape = ctx.input:shouldShowTouchControls() and ctx.uiW > ctx.uiH -- 1298
	local row2Y = touchLandscape and rowCenterY - 30 or 28 + safe.bottom -- 1299
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1300
	local shownItems = {} -- 1301
	local shownKinds = {} -- 1302
	do -- 1302
		i = 0 -- 1303
		while i < #PICKUP_ORDER do -- 1303
			local k = PICKUP_ORDER[i + 1] -- 1304
			local cnt = rg.supplies[k] or 0 -- 1305
			if cnt > 0 then -- 1306
				shownItems[#shownItems + 1] = {kind = k, count = cnt} -- 1307
				shownKinds[#shownKinds + 1] = k -- 1308
			end -- 1308
			i = i + 1 -- 1303
		end -- 1303
	end -- 1303
	self.lastSuppliesShown = shownKinds -- 1311
	if touchLandscape and self.drawerState == "expanded" then -- 1312
		return -- 1313
	end -- 1313
	local woodCnt = rg.supplies.wood or 0 -- 1316
	local bellCnt = rg.supplies.bell or 0 -- 1317
	local craftReady = (rg.roomKey == "escort2" or rg.roomKey == "escort3") and (woodCnt >= 2 or woodCnt >= 1 and bellCnt >= 1) and rg.equippedWeapon == "standard_gun" -- 1318
	local sx = bx -- 1323
	local weaponW = 86 -- 1324
	local pillH = 24 -- 1325
	if not touchLandscape then -- 1326
		local stripW = weaponW + 6 + #shownItems * 59 + (craftReady and 68 or 0) + 28 -- 1327
		drawSilkVeil( -- 1328
			uiDraw, -- 1328
			uiArt, -- 1328
			"rg_satchel_veil", -- 1328
			bx + stripW * 0.45, -- 1328
			row2Y, -- 1328
			stripW + 32, -- 1328
			34, -- 1328
			PALETTE.inkWash, -- 1328
			0.56, -- 1328
			-1 -- 1328
		) -- 1328
	end -- 1328
	uiDraw:drawRoundedRect( -- 1330
		Rect(sx, row2Y - pillH * 0.5, weaponW, pillH), -- 1331
		4, -- 1332
		toColor(PALETTE.inkWash, 185), -- 1333
		0.85, -- 1334
		toColor(wMeta.accent, 160) -- 1335
	) -- 1335
	drawReloadPatternGlyph( -- 1337
		uiInkDraw, -- 1337
		sx + 14, -- 1337
		row2Y, -- 1337
		7.2, -- 1337
		wMeta.effect, -- 1337
		wMeta.accent, -- 1337
		0.94 -- 1337
	) -- 1337
	ctx.texts:put( -- 1338
		"xs", -- 1338
		wMeta.shortName, -- 1338
		sx + 26, -- 1338
		row2Y, -- 1338
		toColor(wMeta.accent), -- 1338
		0, -- 1338
		0.5, -- 1338
		"Left", -- 1338
		0.5, -- 1338
		0.94, -- 1338
		0.08 -- 1338
	) -- 1338
	sx = sx + (weaponW + 6) -- 1339
	do -- 1339
		i = 0 -- 1341
		while i < #shownItems do -- 1341
			local it = shownItems[i + 1] -- 1342
			local pm = pickupMetaOf(it.kind) -- 1343
			local bounce = self.pickupBounceMap[it.kind] or 0 -- 1344
			local shake = self.pickupShakeMap[it.kind] or 0 -- 1345
			local shakeX = shake > 0 and math.sin(self.animTime * 56) * 3.2 * (shake / 0.42) or 0 -- 1346
			local liftY = bounce > 0 and math.sin(bounce / 0.52 * math.pi) * 5 or 0 -- 1347
			local itemW = 54 -- 1348
			local rx = sx + shakeX -- 1349
			local ry = row2Y + liftY -- 1350
			local isHot = bounce > 0.02 or craftReady and (it.kind == "wood" or it.kind == "bell") -- 1351
			local bdCol = shake > 0.02 and PALETTE.rouge or (isHot and PALETTE.amberCore or pm.accent) -- 1352
			if isHot then -- 1354
				local ga = bounce > 0.02 and 48 * (bounce / 0.52) or 24 + 12 * math.sin(self.animTime * 4.5) -- 1355
				fillRadialGlow( -- 1356
					uiGlow, -- 1356
					rx + itemW * 0.5, -- 1356
					ry, -- 1356
					34, -- 1356
					16, -- 1356
					toColor(PALETTE.amberCore, ga), -- 1356
					Color(214, 186, 146, 0), -- 1356
					10 -- 1356
				) -- 1356
			end -- 1356
			uiDraw:drawRoundedRect( -- 1358
				Rect(rx, ry - pillH * 0.5, itemW, pillH), -- 1359
				4, -- 1360
				toColor(shake > 0.02 and PALETTE.inkWarm or PALETTE.inkWash, 192), -- 1361
				(isHot or shake > 0.02) and 1.2 or 0.8, -- 1362
				toColor(bdCol, (isHot or shake > 0.02) and 225 or 148) -- 1363
			) -- 1363
			drawPickupGlyph( -- 1365
				uiInkDraw, -- 1365
				rx + 14, -- 1365
				ry, -- 1365
				7.2, -- 1365
				it.kind, -- 1365
				0.96 -- 1365
			) -- 1365
			ctx.texts:put( -- 1366
				"xs", -- 1367
				"×" .. tostring(it.count), -- 1368
				rx + 37, -- 1369
				ry, -- 1370
				toColor(pm.accentCore), -- 1371
				0.5, -- 1372
				0.5, -- 1373
				"Center", -- 1374
				0, -- 1375
				0.96, -- 1376
				0.08 -- 1377
			) -- 1377
			local popIdx = 0 -- 1380
			do -- 1380
				popIdx = 0 -- 1381
				while popIdx < #self.pickupPops do -- 1381
					local pop = self.pickupPops[popIdx + 1] -- 1382
					if pop.kind == it.kind then -- 1383
						local prog = 1 - pop.timer / pop.maxTimer -- 1384
						ctx.texts:put( -- 1385
							"xs", -- 1386
							"+1", -- 1387
							rx + itemW * 0.5, -- 1388
							ry + 16 + prog * 14, -- 1389
							toColor(PALETTE.amberCore), -- 1390
							0.5, -- 1391
							0.5, -- 1392
							"Center", -- 1393
							0, -- 1394
							1 - prog, -- 1395
							0.08 -- 1396
						) -- 1396
						break -- 1398
					end -- 1398
					popIdx = popIdx + 1 -- 1381
				end -- 1381
			end -- 1381
			sx = sx + (itemW + 5) -- 1401
			i = i + 1 -- 1341
		end -- 1341
	end -- 1341
	if craftReady then -- 1404
		local breathe = 0.72 + 0.28 * math.sin(self.animTime * 4.2) -- 1405
		uiDraw:drawRoundedRect( -- 1406
			Rect(sx, row2Y - pillH * 0.5, 62, pillH), -- 1406
			4, -- 1406
			toColor(PALETTE.inkWarm, 185), -- 1406
			0.95, -- 1406
			toColor(PALETTE.amberCore, 210 * breathe) -- 1406
		) -- 1406
		ctx.texts:put( -- 1407
			"xs", -- 1407
			"足改制", -- 1407
			sx + 31, -- 1407
			row2Y, -- 1407
			toColor(PALETTE.amberCore), -- 1407
			0.5, -- 1407
			0.5, -- 1407
			"Center", -- 1407
			0.6, -- 1407
			0.94 * breathe, -- 1407
			0.08 -- 1407
		) -- 1407
	end -- 1407
end -- 1174
function RoguelikeUiPlugin.prototype.drawExpandedTalentCards(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1413
	local offers = rg.offers -- 1422
	local touchMode = ctx.input:isTouchMode() -- 1423
	local mode = ctx.input.inputMode -- 1424
	local boxes = ____exports.computeRoguelikeCardRects( -- 1425
		ctx.uiW, -- 1425
		ctx.uiH, -- 1425
		#offers, -- 1425
		true, -- 1425
		touchMode, -- 1425
		safe.top -- 1425
	) -- 1425
	self.lastCardBoxes = boxes -- 1426
	local appear = easeOutCubic(self.expandAnimT) -- 1427
	local slowFrac = clamp((1 - self.focusScale) / (1 - EXPANDED_FOCUS_SCALE), 0, 1) -- 1428
	fillVGradRect( -- 1431
		uiDraw, -- 1432
		0, -- 1433
		ctx.uiH * 0.36, -- 1434
		ctx.uiW, -- 1435
		ctx.uiH * 0.64, -- 1436
		Color(9, 12, 19, 0), -- 1437
		Color( -- 1438
			9, -- 1438
			12, -- 1438
			19, -- 1438
			math.floor((138 + 42 * slowFrac) * appear + 0.5) -- 1438
		) -- 1438
	) -- 1438
	local firstBox = boxes[1] -- 1442
	local headY = firstBox.y + firstBox.height + 28 -- 1443
	local cx = ctx.uiW * 0.5 -- 1444
	drawSilkVeil( -- 1445
		uiDraw, -- 1445
		uiArt, -- 1445
		"rg_exp_head_veil", -- 1445
		cx, -- 1445
		headY, -- 1445
		440, -- 1445
		30, -- 1445
		PALETTE.inkWash, -- 1445
		0.78 * appear, -- 1445
		-1 -- 1445
	) -- 1445
	drawHairline( -- 1446
		uiInkDraw, -- 1446
		uiArt, -- 1446
		"rg_exp_head_line", -- 1446
		cx, -- 1446
		headY + 15, -- 1446
		360, -- 1446
		PALETTE.amber, -- 1446
		0.54 * appear, -- 1446
		true, -- 1446
		2 -- 1446
	) -- 1446
	local headText = mode == "gamepad" and ("途中整备 · 择一军筹（LB/RB 择项 · " .. keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " / L3 落印）" or (touchMode and "途中整备 · 择一军筹 · 轻触卡面直接落印" or "途中整备 · 择一军筹 · 按 1 / 2 / 3 或点击落印") -- 1447
	ctx.texts:put( -- 1452
		"xs", -- 1452
		headText, -- 1452
		cx, -- 1452
		headY, -- 1452
		toColor(PALETTE.amberCore), -- 1452
		0.5, -- 1452
		0.5, -- 1452
		"Center", -- 1452
		1, -- 1452
		0.96 * appear, -- 1452
		0.08 -- 1452
	) -- 1452
	local lastBox = boxes[#boxes] -- 1455
	local togX = math.min(ctx.uiW - 86 - safe.right, lastBox.x + lastBox.width - 52) -- 1456
	local togRect = Rect(togX, headY - 12, 54, 24) -- 1457
	self.expandToggleBox = togRect -- 1458
	uiDraw:drawRoundedRect( -- 1459
		togRect, -- 1459
		4, -- 1459
		toColor(PALETTE.inkWash, 185 * appear), -- 1459
		0.85, -- 1459
		toColor(PALETTE.silkDim, 165 * appear) -- 1459
	) -- 1459
	ctx.texts:put( -- 1460
		"xs", -- 1460
		"收束", -- 1460
		togRect.x + 27, -- 1460
		headY, -- 1460
		toColor(PALETTE.textMid), -- 1460
		0.5, -- 1460
		0.5, -- 1460
		"Center", -- 1460
		0.6, -- 1460
		0.88 * appear, -- 1460
		0.08 -- 1460
	) -- 1460
	local i = 0 -- 1463
	do -- 1463
		i = 0 -- 1464
		while i < #offers do -- 1464
			do -- 1464
				local tid = offers[i + 1] -- 1465
				local baseBox = boxes[i + 1] -- 1466
				local cardStagger = easeOutCubic(clamp((self.staggerTime - i * 0.055) / 0.24, 0, 1)) -- 1467
				local alpha = cardStagger * appear -- 1468
				if alpha <= 0.01 then -- 1469
					goto __continue217 -- 1470
				end -- 1470
				local lift = (self.cardLiftT[i + 1] or 0) * 10 -- 1472
				local slideY = (1 - cardStagger) * -22 -- 1473
				local x = baseBox.x -- 1474
				local y = baseBox.y + slideY + lift -- 1475
				local w = baseBox.width -- 1476
				local h = baseBox.height -- 1477
				local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1478
				self:drawSingleTalentCard( -- 1480
					uiDraw, -- 1480
					uiInkDraw, -- 1480
					uiArt, -- 1480
					uiGlow, -- 1480
					ctx, -- 1480
					rg, -- 1480
					tid, -- 1480
					i, -- 1480
					x, -- 1480
					y, -- 1480
					w, -- 1480
					h, -- 1480
					isHot, -- 1480
					alpha, -- 1480
					mode -- 1480
				) -- 1480
			end -- 1480
			::__continue217:: -- 1480
			i = i + 1 -- 1464
		end -- 1464
	end -- 1464
end -- 1413
function RoguelikeUiPlugin.prototype.drawSingleTalentCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, tid, slotIdx, x, y, w, h, isHot, alpha, mode) -- 1484
	local meta = resolveTalentVisual(tid, rg) -- 1501
	local curRank = rg.ranks[tid] or 0 -- 1502
	local cx = x + w * 0.5 -- 1503
	local cy = y + h * 0.5 -- 1504
	local accent = isHot and PALETTE.rouge or meta.accent -- 1505
	uiArt:tryPlace( -- 1508
		"ink_frame_mask", -- 1508
		"rg_card_sh_" .. tostring(slotIdx), -- 1508
		cx, -- 1508
		cy - 4, -- 1508
		w + 26, -- 1508
		h + 24, -- 1508
		{ -- 1508
			color = toColor(PALETTE.voidDark), -- 1509
			opacity = 0.72 * alpha, -- 1509
			layer = -1 -- 1509
		} -- 1509
	) -- 1509
	if isHot then -- 1511
		local breathe = 0.86 + 0.14 * math.sin(self.animTime * 4) -- 1512
		fillRadialGlow( -- 1513
			uiGlow, -- 1513
			cx, -- 1513
			cy, -- 1513
			w * 0.74, -- 1513
			h * 0.64, -- 1513
			toColor(PALETTE.rouge, 34 * breathe * alpha), -- 1513
			Color(182, 58, 56, 0), -- 1513
			14 -- 1513
		) -- 1513
	end -- 1513
	local bgCol = isHot and Color( -- 1517
		28, -- 1517
		22, -- 1517
		27, -- 1517
		math.floor(244 * alpha + 0.5) -- 1517
	) or Color( -- 1517
		15, -- 1517
		18, -- 1517
		26, -- 1517
		math.floor(234 * alpha + 0.5) -- 1517
	) -- 1517
	local bdCol = toColor(isHot and PALETTE.rouge or meta.accent, (isHot and 235 or 155) * alpha) -- 1518
	uiDraw:drawRoundedRect( -- 1519
		Rect(x, y, w, h), -- 1519
		5, -- 1519
		bgCol, -- 1519
		isHot and 1.55 or 0.95, -- 1519
		bdCol -- 1519
	) -- 1519
	uiDraw:drawRect( -- 1521
		Rect(x + 5, y + 5, w - 10, h - 10), -- 1521
		Color(0, 0, 0, 0), -- 1521
		0.65, -- 1521
		toColor(isHot and PALETTE.amberCore or PALETTE.silkDim, (isHot and 115 or 68) * alpha) -- 1521
	) -- 1521
	drawFiligreeCorners( -- 1523
		uiInkDraw, -- 1523
		uiArt, -- 1523
		"rg_card_cn_" .. tostring(slotIdx), -- 1523
		x + 2, -- 1523
		y + 2, -- 1523
		w - 4, -- 1523
		h - 4, -- 1523
		accent, -- 1523
		(isHot and 0.94 or 0.62) * alpha, -- 1523
		22, -- 1523
		false, -- 1523
		3 -- 1523
	) -- 1523
	local topY = y + h - 22 -- 1526
	ctx.texts:put( -- 1527
		"xs", -- 1527
		meta.category, -- 1527
		x + 16, -- 1527
		topY, -- 1527
		toColor(meta.accentCore), -- 1527
		0, -- 1527
		0.5, -- 1527
		"Left", -- 1527
		1.2, -- 1527
		0.88 * alpha, -- 1527
		0.08 -- 1527
	) -- 1527
	local maxPips = math.max(curRank + 1, 3) -- 1530
	local pipStartX = x + w - 16 - (maxPips - 1) * 12 -- 1531
	local k = 0 -- 1532
	do -- 1532
		k = 0 -- 1533
		while k < maxPips do -- 1533
			local px = pipStartX + k * 12 -- 1534
			if k < curRank then -- 1535
				drawDiamond( -- 1536
					uiInkDraw, -- 1536
					px, -- 1536
					topY, -- 1536
					4, -- 1536
					4, -- 1536
					toColor(meta.accentCore, 230 * alpha) -- 1536
				) -- 1536
			elseif k == curRank then -- 1537
				drawDiamond( -- 1538
					uiInkDraw, -- 1538
					px, -- 1538
					topY, -- 1538
					4.4, -- 1538
					4.4, -- 1538
					toColor(isHot and PALETTE.rouge or PALETTE.amber, 220 * alpha), -- 1538
					1, -- 1538
					toColor(PALETTE.textBright, 220 * alpha) -- 1538
				) -- 1538
			else -- 1538
				drawDiamond( -- 1540
					uiInkDraw, -- 1540
					px, -- 1540
					topY, -- 1540
					3.2, -- 1540
					3.2, -- 1540
					Color(0, 0, 0, 0), -- 1540
					0.85, -- 1540
					toColor(PALETTE.silkDim, 130 * alpha) -- 1540
				) -- 1540
			end -- 1540
			k = k + 1 -- 1533
		end -- 1533
	end -- 1533
	drawHairline( -- 1544
		uiInkDraw, -- 1544
		uiArt, -- 1544
		"rg_card_hl_" .. tostring(slotIdx), -- 1544
		cx, -- 1544
		topY - 14, -- 1544
		w - 28, -- 1544
		accent, -- 1544
		0.45 * alpha, -- 1544
		false, -- 1544
		2 -- 1544
	) -- 1544
	local iconY = y + h - 76 -- 1547
	uiArt:tryPlace( -- 1548
		"ink_enso_fine", -- 1548
		"rg_card_enso_" .. tostring(slotIdx), -- 1548
		cx, -- 1548
		iconY, -- 1548
		62, -- 1548
		62, -- 1548
		{ -- 1548
			color = toColor(isHot and PALETTE.amberCore or meta.accent), -- 1549
			opacity = (isHot and 0.64 or 0.36) * alpha, -- 1549
			angle = self.animTime * (isHot and 16 or 6), -- 1549
			layer = 2 -- 1549
		} -- 1549
	) -- 1549
	fillRadialGlow( -- 1551
		uiGlow, -- 1551
		cx, -- 1551
		iconY, -- 1551
		34, -- 1551
		34, -- 1551
		toColor(meta.accent, (isHot and 42 or 20) * alpha), -- 1551
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1551
		12 -- 1551
	) -- 1551
	drawTalentGlyph( -- 1552
		uiInkDraw, -- 1552
		cx, -- 1552
		iconY, -- 1552
		22, -- 1552
		tid, -- 1552
		isHot and meta.accentCore or meta.accent, -- 1552
		alpha, -- 1552
		isHot and PALETTE.textBright or meta.accentCore -- 1552
	) -- 1552
	local titleY = y + 114 -- 1555
	ctx.texts:put( -- 1556
		"md", -- 1557
		meta.title, -- 1558
		cx, -- 1559
		titleY, -- 1560
		toColor(isHot and PALETTE.textBright or meta.accentCore), -- 1561
		0.5, -- 1562
		0.5, -- 1563
		"Center", -- 1564
		5, -- 1565
		0.98 * alpha, -- 1566
		0.1 -- 1567
	) -- 1567
	ctx.texts:put( -- 1571
		"xs", -- 1572
		meta:shortEffect(rg, curRank), -- 1573
		cx, -- 1574
		titleY - 26, -- 1575
		toColor(isHot and PALETTE.amberCore or PALETTE.textBright), -- 1576
		0.5, -- 1577
		0.5, -- 1578
		"Center", -- 1579
		0.6, -- 1580
		0.96 * alpha, -- 1581
		0.08 -- 1582
	) -- 1582
	ctx.texts:put( -- 1584
		"xs", -- 1585
		meta:subEffect(rg, curRank), -- 1586
		cx, -- 1587
		titleY - 46, -- 1588
		toColor(PALETTE.textMid), -- 1589
		0.5, -- 1590
		0.5, -- 1591
		"Center", -- 1592
		0.4, -- 1593
		0.86 * alpha, -- 1594
		0.08 -- 1595
	) -- 1595
	local whisperAlpha = (isHot and 0.9 or (mode == "touch" and 0.62 or 0.36)) * alpha -- 1599
	ctx.texts:put( -- 1600
		"xs", -- 1601
		meta.whisper, -- 1602
		cx, -- 1603
		y + 44, -- 1604
		toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1605
		0.5, -- 1606
		0.5, -- 1607
		"Center", -- 1608
		0.2, -- 1609
		whisperAlpha, -- 1610
		0.06 -- 1611
	) -- 1611
	local footY = y + 18 -- 1615
	if isHot then -- 1616
		drawSilkRibbon( -- 1617
			uiDraw, -- 1617
			uiArt, -- 1617
			"rg_card_rib_" .. tostring(slotIdx), -- 1617
			cx, -- 1617
			footY, -- 1617
			w - 18, -- 1617
			24, -- 1617
			PALETTE.rougeSoft, -- 1617
			0.56 * alpha, -- 1617
			1 -- 1617
		) -- 1617
	end -- 1617
	if mode == "kbm" then -- 1619
		drawSilkKeycap( -- 1620
			uiInkDraw, -- 1620
			ctx.texts, -- 1620
			cx - 42, -- 1620
			footY - 10, -- 1620
			22, -- 1620
			20, -- 1620
			"" .. tostring(slotIdx + 1), -- 1620
			accent, -- 1620
			alpha, -- 1620
			isHot -- 1620
		) -- 1620
		ctx.texts:put( -- 1621
			"xs", -- 1621
			isHot and "落印习得" or "习得", -- 1621
			cx - 12, -- 1621
			footY, -- 1621
			toColor(isHot and PALETTE.textBright or PALETTE.textMid), -- 1621
			0, -- 1621
			0.5, -- 1621
			"Left", -- 1621
			1, -- 1621
			0.94 * alpha, -- 1621
			0.08 -- 1621
		) -- 1621
	elseif mode == "gamepad" then -- 1622
		local label = isHot and "◆ L3 落印 ◆" or ("第" .. rankChinese(slotIdx + 1)) .. "筹" -- 1623
		ctx.texts:put( -- 1624
			"xs", -- 1624
			label, -- 1624
			cx, -- 1624
			footY, -- 1624
			toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1624
			0.5, -- 1624
			0.5, -- 1624
			"Center", -- 1624
			1, -- 1624
			0.94 * alpha, -- 1624
			0.08 -- 1624
		) -- 1624
	else -- 1624
		ctx.texts:put( -- 1626
			"xs", -- 1626
			"轻触落印", -- 1626
			cx, -- 1626
			footY, -- 1626
			toColor(PALETTE.amberCore), -- 1626
			0.5, -- 1626
			0.5, -- 1626
			"Center", -- 1626
			1.2, -- 1626
			0.95 * alpha, -- 1626
			0.08 -- 1626
		) -- 1626
	end -- 1626
end -- 1484
function RoguelikeUiPlugin.prototype.drawCompactTalentTallies(self, uiDraw, uiInkDraw, uiArt, ctx, rg, safe) -- 1632
	local offers = rg.offers -- 1640
	local touchMode = ctx.input:isTouchMode() -- 1641
	local mode = ctx.input.inputMode -- 1642
	local boxes = ____exports.computeRoguelikeCardRects( -- 1643
		ctx.uiW, -- 1643
		ctx.uiH, -- 1643
		#offers, -- 1643
		false, -- 1643
		touchMode, -- 1643
		safe.top -- 1643
	) -- 1643
	self.lastCardBoxes = boxes -- 1644
	local i = 0 -- 1646
	do -- 1646
		i = 0 -- 1647
		while i < #offers do -- 1647
			local tid = offers[i + 1] -- 1648
			local box = boxes[i + 1] -- 1649
			local meta = resolveTalentVisual(tid, rg) -- 1650
			local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1651
			local cy = box.y + box.height * 0.5 -- 1653
			local bdCol = isHot and PALETTE.rouge or meta.accent -- 1654
			uiDraw:drawRoundedRect( -- 1656
				box, -- 1657
				4, -- 1658
				toColor(isHot and PALETTE.inkWarm or PALETTE.panelBgDeep, isHot and 236 or 210), -- 1659
				isHot and 1.4 or 0.9, -- 1660
				toColor(bdCol, isHot and 235 or 178) -- 1661
			) -- 1661
			drawTalentGlyph( -- 1663
				uiInkDraw, -- 1663
				box.x + 20, -- 1663
				cy, -- 1663
				10.5, -- 1663
				tid, -- 1663
				meta.accent, -- 1663
				0.96, -- 1663
				meta.accentCore -- 1663
			) -- 1663
			if mode == "kbm" then -- 1664
				drawSilkKeycap( -- 1665
					uiInkDraw, -- 1665
					ctx.texts, -- 1665
					box.x + 36, -- 1665
					cy - 10, -- 1665
					20, -- 1665
					20, -- 1665
					"" .. tostring(i + 1), -- 1665
					bdCol, -- 1665
					0.95, -- 1665
					isHot -- 1665
				) -- 1665
				ctx.texts:put( -- 1666
					"xs", -- 1666
					meta.title, -- 1666
					box.x + 62, -- 1666
					cy + 7, -- 1666
					toColor(PALETTE.textBright), -- 1666
					0, -- 1666
					0.5, -- 1666
					"Left", -- 1666
					0.8, -- 1666
					0.96, -- 1666
					0.08 -- 1666
				) -- 1666
				ctx.texts:put( -- 1667
					"xs", -- 1667
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1667
					box.x + 62, -- 1667
					cy - 8, -- 1667
					toColor(meta.accentCore), -- 1667
					0, -- 1667
					0.5, -- 1667
					"Left", -- 1667
					0.2, -- 1667
					0.82, -- 1667
					0.06 -- 1667
				) -- 1667
			else -- 1667
				drawBlossomDot( -- 1669
					uiInkDraw, -- 1669
					uiArt, -- 1669
					"rg_cmp_dot_" .. tostring(i), -- 1669
					box.x + 38, -- 1669
					cy, -- 1669
					isHot and 11 or 7, -- 1669
					bdCol, -- 1669
					0.95, -- 1669
					4 -- 1669
				) -- 1669
				ctx.texts:put( -- 1670
					"xs", -- 1670
					(meta.title .. " · ") .. meta.category, -- 1670
					box.x + 50, -- 1670
					cy + 7, -- 1670
					toColor(PALETTE.textBright), -- 1670
					0, -- 1670
					0.5, -- 1670
					"Left", -- 1670
					0.6, -- 1670
					0.96, -- 1670
					0.08 -- 1670
				) -- 1670
				ctx.texts:put( -- 1671
					"xs", -- 1671
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1671
					box.x + 50, -- 1671
					cy - 8, -- 1671
					toColor(meta.accentCore), -- 1671
					0, -- 1671
					0.5, -- 1671
					"Left", -- 1671
					0.2, -- 1671
					0.82, -- 1671
					0.06 -- 1671
				) -- 1671
			end -- 1671
			i = i + 1 -- 1647
		end -- 1647
	end -- 1647
	local last = boxes[#boxes] -- 1676
	local togRect = Rect(last.x + last.width + 8, last.y + (last.height - 26) * 0.5, 50, 26) -- 1677
	self.expandToggleBox = togRect -- 1678
	uiDraw:drawRoundedRect( -- 1679
		togRect, -- 1679
		4, -- 1679
		toColor(PALETTE.inkWash, 190), -- 1679
		0.9, -- 1679
		toColor(PALETTE.amber, 175) -- 1679
	) -- 1679
	ctx.texts:put( -- 1680
		"xs", -- 1680
		"展开", -- 1680
		togRect.x + 25, -- 1680
		togRect.y + 13, -- 1680
		toColor(PALETTE.amberCore), -- 1680
		0.5, -- 1680
		0.5, -- 1680
		"Center", -- 1680
		0.6, -- 1680
		0.92, -- 1680
		0.08 -- 1680
	) -- 1680
end -- 1632
function RoguelikeUiPlugin.prototype.drawSealAndAbsorb(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, anim) -- 1685
	local meta = resolveTalentVisual(anim.talentId, rg) -- 1694
	local pb = anim.pickedBox -- 1695
	local pcx = pb.x + pb.width * 0.5 -- 1696
	local pcy = pb.y + pb.height * 0.5 -- 1697
	if anim.elapsed < anim.sealDuration then -- 1699
		local t = clamp(anim.elapsed / anim.sealDuration, 0, 1) -- 1700
		local i = 0 -- 1702
		do -- 1702
			i = 0 -- 1703
			while i < #anim.allBoxes do -- 1703
				do -- 1703
					if i == anim.pickedSlot then -- 1704
						goto __continue238 -- 1705
					end -- 1705
					local ob = anim.allBoxes[i + 1] -- 1707
					local dir = i < anim.pickedSlot and -1 or 1 -- 1708
					local drift = dir * easeOutCubic(t) * 26 -- 1709
					local oa = (1 - t) * 0.55 -- 1710
					uiDraw:drawRoundedRect( -- 1711
						Rect( -- 1711
							ob.x + drift, -- 1711
							ob.y - easeOutCubic(t) * 8, -- 1711
							ob.width, -- 1711
							ob.height -- 1711
						), -- 1711
						5, -- 1711
						Color( -- 1711
							15, -- 1711
							18, -- 1711
							26, -- 1711
							math.floor(180 * oa + 0.5) -- 1711
						), -- 1711
						0.8, -- 1711
						toColor(PALETTE.silkDim, 110 * oa) -- 1711
					) -- 1711
				end -- 1711
				::__continue238:: -- 1711
				i = i + 1 -- 1703
			end -- 1703
		end -- 1703
		local pop = 1 + (1 - easeOutCubic(t)) * 0.04 -- 1715
		local sw = pb.width * pop -- 1716
		local sh = pb.height * pop -- 1717
		local sx = pcx - sw * 0.5 -- 1718
		local sy = pcy - sh * 0.5 -- 1719
		fillRadialGlow( -- 1720
			uiGlow, -- 1720
			pcx, -- 1720
			pcy, -- 1720
			sw * 0.72, -- 1720
			sh * 0.62, -- 1720
			toColor(PALETTE.rouge, 56 * (1 - t * 0.4)), -- 1720
			Color(182, 58, 56, 0), -- 1720
			14 -- 1720
		) -- 1720
		uiDraw:drawRoundedRect( -- 1721
			Rect(sx, sy, sw, sh), -- 1721
			5, -- 1721
			Color(34, 22, 27, 245), -- 1721
			1.8, -- 1721
			toColor(PALETTE.rouge, 245) -- 1721
		) -- 1721
		drawTalentGlyph( -- 1722
			uiInkDraw, -- 1722
			pcx, -- 1722
			pcy + (anim.fromExpanded and 24 or 0), -- 1722
			anim.fromExpanded and 22 or 12, -- 1722
			anim.talentId, -- 1722
			meta.accentCore, -- 1722
			0.96, -- 1722
			PALETTE.textBright -- 1722
		) -- 1722
		ctx.texts:put( -- 1723
			"md", -- 1723
			meta.title, -- 1723
			pcx, -- 1723
			pcy - (anim.fromExpanded and 22 or 0), -- 1723
			toColor(PALETTE.textBright), -- 1723
			0.5, -- 1723
			0.5, -- 1723
			"Center", -- 1723
			4, -- 1723
			0.98, -- 1723
			0.1 -- 1723
		) -- 1723
		local slam = 1 + (1 - t) ^ 2 * 0.55 -- 1726
		drawLoneSeal( -- 1727
			uiInkDraw, -- 1728
			uiArt, -- 1729
			ctx.texts, -- 1730
			"rg_pick_seal", -- 1731
			pcx + (anim.fromExpanded and pb.width * 0.26 or pb.width * 0.34), -- 1732
			pcy - (anim.fromExpanded and pb.height * 0.22 or 0), -- 1733
			26 * slam, -- 1734
			50 * slam, -- 1735
			"契", -- 1736
			"印", -- 1737
			PALETTE.sealRedBright, -- 1738
			PALETTE.sealText, -- 1739
			0.96, -- 1740
			6 -- 1741
		) -- 1741
		return -- 1743
	end -- 1743
	local t = clamp( -- 1747
		(anim.elapsed - anim.sealDuration) / math.max(0.01, anim.absorbDuration), -- 1747
		0, -- 1747
		1 -- 1747
	) -- 1747
	local dest = self:computeAbsorbTargetUi(ctx, rg, anim.targetKind) -- 1748
	local ctrlX = (pcx + dest.x) * 0.5 -- 1749
	local ctrlY = math.max(pcy, dest.y) + 76 -- 1750
	local headT = easeInOutQuad(t) -- 1753
	local samples = 10 -- 1754
	local s = 0 -- 1755
	local prevPt -- 1756
	do -- 1756
		s = 0 -- 1757
		while s <= samples do -- 1757
			local u = math.max(0, headT - (samples - s) * 0.032) -- 1758
			local inv = 1 - u -- 1759
			local bx = inv * inv * pcx + 2 * inv * u * ctrlX + u * u * dest.x -- 1760
			local by = inv * inv * pcy + 2 * inv * u * ctrlY + u * u * dest.y -- 1761
			local pt = Vec2(bx, by) -- 1762
			if prevPt ~= nil then -- 1763
				local segA = s / samples * (1 - t * 0.35) -- 1764
				uiGlow:drawSegment( -- 1765
					prevPt, -- 1765
					pt, -- 1765
					1.6 + s / samples * 2.4, -- 1765
					toColor( -- 1765
						meta.accentCore, -- 1765
						math.floor(210 * segA + 0.5) -- 1765
					) -- 1765
				) -- 1765
			end -- 1765
			if s % 2 == 1 then -- 1767
				uiGlow:drawDot( -- 1768
					pt, -- 1768
					2 + s / samples * 2.2, -- 1768
					toColor( -- 1768
						PALETTE.amberCore, -- 1768
						math.floor(180 * (s / samples) * (1 - t * 0.3) + 0.5) -- 1768
					) -- 1768
				) -- 1768
			end -- 1768
			prevPt = pt -- 1770
			s = s + 1 -- 1757
		end -- 1757
	end -- 1757
	local invH = 1 - headT -- 1772
	local hx = invH * invH * pcx + 2 * invH * headT * ctrlX + headT * headT * dest.x -- 1773
	local hy = invH * invH * pcy + 2 * invH * headT * ctrlY + headT * headT * dest.y -- 1774
	fillRadialGlow( -- 1775
		uiGlow, -- 1775
		hx, -- 1775
		hy, -- 1775
		22, -- 1775
		22, -- 1775
		toColor(meta.accentCore, 96 * (1 - t * 0.3)), -- 1775
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1775
		12 -- 1775
	) -- 1775
	drawDiamond( -- 1776
		uiInkDraw, -- 1776
		hx, -- 1776
		hy, -- 1776
		5.5, -- 1776
		5.5, -- 1776
		toColor(PALETTE.textBright, 240) -- 1776
	) -- 1776
end -- 1685
function RoguelikeUiPlugin.prototype.computeAbsorbTargetUi(self, ctx, rg, target) -- 1779
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1780
	local bx = 28 + safe.left -- 1781
	local hpY = ctx.uiH - 56 - safe.top -- 1782
	if target == "hp" then -- 1783
		return { -- 1784
			x = bx + 44 + math.min(5, rg.maxHp) * 52, -- 1784
			y = hpY -- 1784
		} -- 1784
	end -- 1784
	if target == "gun" then -- 1786
		local p = ctx.p -- 1787
		return { -- 1788
			x = clamp( -- 1789
				ctx.cam:sx(p.player.x + p.player.facing * 14) / ctx.uiScale, -- 1789
				80, -- 1789
				ctx.uiW - 80 -- 1789
			), -- 1789
			y = clamp( -- 1790
				ctx.cam:sy(p.player.y + p.player.h * 0.62, p.player.depth) / ctx.uiScale, -- 1790
				80, -- 1790
				ctx.uiH - 80 -- 1790
			) -- 1790
		} -- 1790
	end -- 1790
	if target == "shoulder" then -- 1793
		local p = ctx.p -- 1794
		return { -- 1795
			x = clamp( -- 1796
				ctx.cam:sx(p.player.x) / ctx.uiScale, -- 1796
				80, -- 1796
				ctx.uiW - 80 -- 1796
			), -- 1796
			y = clamp( -- 1797
				ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) / ctx.uiScale, -- 1797
				80, -- 1797
				ctx.uiH - 80 -- 1797
			) -- 1797
		} -- 1797
	end -- 1797
	if target == "satchel" then -- 1800
		return {x = bx + 86, y = hpY - 68} -- 1801
	end -- 1801
	return {x = bx + 64, y = hpY - 36} -- 1803
end -- 1779
function RoguelikeUiPlugin.prototype.drawSegmentClearRibbon(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, safe) -- 1808
	local elapsed = SEGMENT_BANNER_DURATION - self.segmentBannerT -- 1816
	local fadeIn = clamp(elapsed / 0.24, 0, 1) -- 1817
	local fadeOut = clamp(self.segmentBannerT / 0.36, 0, 1) -- 1818
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1819
	if alpha <= 0.01 then -- 1820
		return -- 1821
	end -- 1821
	local cx = ctx.uiW * 0.5 -- 1823
	local cy = ctx.uiH - 134 - safe.top -- 1824
	drawSilkVeil( -- 1825
		uiDraw, -- 1825
		uiArt, -- 1825
		"rg_seg_veil", -- 1825
		cx, -- 1825
		cy, -- 1825
		460, -- 1825
		74, -- 1825
		PALETTE.inkWash, -- 1825
		0.78 * alpha, -- 1825
		2 -- 1825
	) -- 1825
	drawMistCurve( -- 1826
		uiArt, -- 1826
		"rg_seg_mist", -- 1826
		cx, -- 1826
		cy, -- 1826
		420, -- 1826
		66, -- 1826
		PALETTE.amber, -- 1826
		0.24 * alpha, -- 1826
		2 -- 1826
	) -- 1826
	drawHairline( -- 1827
		uiInkDraw, -- 1827
		uiArt, -- 1827
		"rg_seg_top", -- 1827
		cx, -- 1827
		cy + 32, -- 1827
		320, -- 1827
		PALETTE.amberCore, -- 1827
		0.58 * alpha, -- 1827
		true, -- 1827
		4 -- 1827
	) -- 1827
	drawHairline( -- 1828
		uiInkDraw, -- 1828
		uiArt, -- 1828
		"rg_seg_bot", -- 1828
		cx, -- 1828
		cy - 32, -- 1828
		280, -- 1828
		PALETTE.silkDim, -- 1828
		0.44 * alpha, -- 1828
		false, -- 1828
		4 -- 1828
	) -- 1828
	fillRadialGlow( -- 1829
		uiGlow, -- 1829
		cx, -- 1829
		cy + 6, -- 1829
		130, -- 1829
		34, -- 1829
		toColor(PALETTE.amber, 26 * alpha), -- 1829
		Color(214, 186, 146, 0), -- 1829
		12 -- 1829
	) -- 1829
	ctx.texts:put( -- 1831
		"banner", -- 1831
		self.segmentBannerHeadline, -- 1831
		cx, -- 1831
		cy + 9, -- 1831
		toColor(PALETTE.textBright), -- 1831
		0.5, -- 1831
		0.5, -- 1831
		"Center", -- 1831
		8, -- 1831
		0.96 * alpha, -- 1831
		0.12 -- 1831
	) -- 1831
	ctx.texts:put( -- 1832
		"xs", -- 1832
		self.segmentBannerSub, -- 1832
		cx, -- 1832
		cy - 18, -- 1832
		toColor(PALETTE.amberCore), -- 1832
		0.5, -- 1832
		0.5, -- 1832
		"Center", -- 1832
		1.6, -- 1832
		0.92 * alpha, -- 1832
		0.08 -- 1832
	) -- 1832
end -- 1808
function RoguelikeUiPlugin.prototype.drawDeathRecapOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, snap) -- 1837
	local elapsed = DEATH_RECAP_DURATION - self.deathRecapT -- 1845
	local fadeIn = clamp(elapsed / 0.26, 0, 1) -- 1846
	local fadeOut = clamp(self.deathRecapT / 0.44, 0, 1) -- 1847
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1848
	if alpha <= 0.01 then -- 1849
		return -- 1850
	end -- 1850
	local cx = ctx.uiW * 0.5 -- 1852
	local cy = ctx.uiH * 0.52 -- 1853
	uiDraw:drawRect( -- 1856
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1856
		Color( -- 1856
			8, -- 1856
			10, -- 1856
			16, -- 1856
			math.floor(168 * alpha + 0.5) -- 1856
		) -- 1856
	) -- 1856
	drawMistCurve( -- 1857
		uiArt, -- 1857
		"rg_recap_mist", -- 1857
		cx, -- 1857
		cy, -- 1857
		640, -- 1857
		140, -- 1857
		PALETTE.rougeSoft, -- 1857
		0.24 * alpha, -- 1857
		1 -- 1857
	) -- 1857
	fillRadialGlow( -- 1858
		uiGlow, -- 1858
		cx, -- 1858
		cy + 20, -- 1858
		220, -- 1858
		110, -- 1858
		toColor(PALETTE.rouge, 26 * alpha), -- 1858
		Color(182, 58, 56, 0), -- 1858
		14 -- 1858
	) -- 1858
	ctx.texts:put( -- 1861
		"banner", -- 1861
		"折筹重整", -- 1861
		cx, -- 1861
		cy + 88, -- 1861
		toColor(PALETTE.textBright), -- 1861
		0.5, -- 1861
		0.5, -- 1861
		"Center", -- 1861
		10, -- 1861
		0.96 * alpha, -- 1861
		0.12 -- 1861
	) -- 1861
	drawHairline( -- 1862
		uiInkDraw, -- 1862
		uiArt, -- 1862
		"rg_recap_line", -- 1862
		cx, -- 1862
		cy + 48, -- 1862
		360, -- 1862
		PALETTE.rouge, -- 1862
		0.62 * alpha, -- 1862
		true, -- 1862
		3 -- 1862
	) -- 1862
	local scatterT = clamp((elapsed - 0.22) / 1.15, 0, 1) -- 1865
	local ids = {} -- 1866
	for k in pairs(snap.ranks) do -- 1867
		if snap.ranks[k] > 0 then -- 1868
			ids[#ids + 1] = k -- 1869
		end -- 1869
	end -- 1869
	if #ids > 0 then -- 1872
		local step = 76 -- 1873
		local startX = cx - (#ids - 1) * step * 0.5 -- 1874
		local i = 0 -- 1875
		do -- 1875
			i = 0 -- 1876
			while i < #ids do -- 1876
				local tid = ids[i + 1] -- 1877
				local meta = resolveTalentVisual(tid) -- 1878
				local dir = #ids == 1 and 0 or i - (#ids - 1) * 0.5 -- 1879
				local dx = dir * easeOutCubic(scatterT) * 28 -- 1880
				local dy = easeOutCubic(scatterT) * 24 -- 1881
				local chipA = alpha * (1 - scatterT * 0.85) -- 1882
				local ix = startX + i * step + dx -- 1883
				local iy = cy + 6 + dy -- 1884
				uiDraw:drawRoundedRect( -- 1885
					Rect(ix - 24, iy - 18, 48, 36), -- 1885
					4, -- 1885
					toColor(PALETTE.inkWash, 180 * chipA), -- 1885
					0.9, -- 1885
					toColor(meta.accent, 150 * chipA) -- 1885
				) -- 1885
				drawTalentGlyph( -- 1886
					uiInkDraw, -- 1886
					ix, -- 1886
					iy, -- 1886
					12, -- 1886
					tid, -- 1886
					meta.accent, -- 1886
					chipA, -- 1886
					meta.accentCore -- 1886
				) -- 1886
				if scatterT > 0.08 then -- 1888
					uiGlow:drawDot( -- 1889
						Vec2(ix + dir * 10, iy + 14 + scatterT * 14), -- 1889
						2, -- 1889
						toColor(PALETTE.silkDim, 140 * chipA) -- 1889
					) -- 1889
					uiGlow:drawDot( -- 1890
						Vec2(ix - dir * 8, iy + 8 + scatterT * 20), -- 1890
						1.6, -- 1890
						toColor(PALETTE.rouge, 130 * chipA) -- 1890
					) -- 1890
				end -- 1890
				i = i + 1 -- 1876
			end -- 1876
		end -- 1876
	end -- 1876
	local countText = snap.totalRanks > 0 and ("曾习" .. toChineseUpper(snap.totalRanks)) .. "筹" or "尚未择筹" -- 1895
	local summary = ((("止步于「" .. snap.stageName) .. "」 · ") .. countText) .. " · 筹散人安，重整再护" -- 1896
	ctx.texts:put( -- 1897
		"sm", -- 1897
		summary, -- 1897
		cx, -- 1897
		cy - 48, -- 1897
		toColor(PALETTE.amberCore), -- 1897
		0.5, -- 1897
		0.5, -- 1897
		"Center", -- 1897
		1, -- 1897
		0.94 * alpha, -- 1897
		0.08 -- 1897
	) -- 1897
	ctx.texts:put( -- 1898
		"xs", -- 1898
		"新一轮护送将自城外巷路再启", -- 1898
		cx, -- 1898
		cy - 82, -- 1898
		toColor(PALETTE.textDim), -- 1898
		0.5, -- 1898
		0.5, -- 1898
		"Center", -- 1898
		1.2, -- 1898
		0.78 * alpha, -- 1898
		0.06 -- 1898
	) -- 1898
end -- 1837
function RoguelikeUiPlugin.prototype.drawBuildLedger(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1903
	local appear = easeOutCubic(self.ledgerAnimT) -- 1912
	local cx = ctx.uiW * 0.5 -- 1913
	local pageW = math.min(ctx.uiW - 96 - safe.left - safe.right, 880) -- 1914
	local pageH = math.min(ctx.uiH - 116 - safe.top - safe.bottom, 504) -- 1915
	local px = cx - pageW * 0.5 -- 1916
	local py = (ctx.uiH - pageH) * 0.5 + (1 - appear) * -14 -- 1917
	local midY = py + pageH * 0.5 -- 1918
	self.ledgerPanelBox = Rect(px, py, pageW, pageH) -- 1919
	uiDraw:drawRect( -- 1922
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1922
		Color( -- 1922
			7, -- 1922
			9, -- 1922
			15, -- 1922
			math.floor(188 * appear + 0.5) -- 1922
		) -- 1922
	) -- 1922
	uiArt:tryPlace( -- 1923
		"ink_frame_mask", -- 1923
		"rg_led_sh", -- 1923
		cx, -- 1923
		midY - 6, -- 1923
		pageW + 52, -- 1923
		pageH + 46, -- 1923
		{ -- 1923
			color = toColor(PALETTE.voidDark), -- 1924
			opacity = 0.84 * appear, -- 1924
			layer = -1 -- 1924
		} -- 1924
	) -- 1924
	if not uiArt:tryPlace( -- 1926
		"ink_song_paper", -- 1926
		"rg_led_paper", -- 1926
		cx, -- 1926
		midY, -- 1926
		pageW, -- 1926
		pageH, -- 1926
		{opacity = 0.98 * appear, layer = 1} -- 1926
	) then -- 1926
		uiDraw:drawRect( -- 1927
			Rect(px, py, pageW, pageH), -- 1927
			toColor(PALETTE.xuanPaper, 248 * appear), -- 1927
			1, -- 1927
			toColor(PALETTE.silkDim, 180 * appear) -- 1927
		) -- 1927
	end -- 1927
	fillRadialGlow( -- 1929
		uiGlow, -- 1929
		cx, -- 1929
		midY + 36, -- 1929
		260, -- 1929
		140, -- 1929
		Color( -- 1929
			236, -- 1929
			224, -- 1929
			202, -- 1929
			math.floor(16 * appear + 0.5) -- 1929
		), -- 1929
		Color(236, 224, 202, 0), -- 1929
		14 -- 1929
	) -- 1929
	local inX = px + 36 -- 1932
	local inY = py + 28 -- 1933
	local inW = pageW - 72 -- 1934
	local inH = pageH - 56 -- 1935
	local redSilk = toColor(PALETTE.rouge, 118 * appear) -- 1936
	local redFaint = toColor(PALETTE.rouge, 56 * appear) -- 1937
	uiInkDraw:drawRect( -- 1938
		Rect(inX, inY, inW, inH), -- 1938
		Color(0, 0, 0, 0), -- 1938
		0.95, -- 1938
		redSilk -- 1938
	) -- 1938
	uiInkDraw:drawRect( -- 1939
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1939
		Color(0, 0, 0, 0), -- 1939
		0.55, -- 1939
		redFaint -- 1939
	) -- 1939
	local headY = inY + inH - 26 -- 1942
	local routeZh = rg.routeTag == "drygoods" and " · 布行暗渡" or (rg.routeTag == "outer" and " · 外檐强行" or "") -- 1943
	ctx.texts:put( -- 1944
		"lg", -- 1944
		"行军札记", -- 1944
		inX + 18, -- 1944
		headY, -- 1944
		toColor(PALETTE.xuanInk), -- 1944
		0, -- 1944
		0.5, -- 1944
		"Left", -- 1944
		3, -- 1944
		0.96 * appear, -- 1944
		0 -- 1944
	) -- 1944
	local metaInfo = ((("筹号 " .. tostring(rg.seed)) .. "  ·  用时 ") .. mmss(rg.ticks)) .. routeZh -- 1945
	ctx.texts:put( -- 1946
		"xs", -- 1946
		metaInfo, -- 1946
		inX + 158, -- 1946
		headY - 2, -- 1946
		toColor(PALETTE.xuanInkSub), -- 1946
		0, -- 1946
		0.5, -- 1946
		"Left", -- 1946
		1, -- 1946
		0.88 * appear, -- 1946
		0 -- 1946
	) -- 1946
	local closeW = 76 -- 1949
	local closeH = 26 -- 1950
	local closeRect = Rect(inX + inW - closeW - 14, headY - closeH * 0.5, closeW, closeH) -- 1951
	self.ledgerCloseBox = closeRect -- 1952
	uiInkDraw:drawRect( -- 1953
		closeRect, -- 1953
		Color( -- 1953
			168, -- 1953
			46, -- 1953
			44, -- 1953
			math.floor(28 * appear + 0.5) -- 1953
		), -- 1953
		0.9, -- 1953
		toColor(PALETTE.rouge, 185 * appear) -- 1953
	) -- 1953
	ctx.texts:put( -- 1954
		"xs", -- 1954
		"合卷", -- 1954
		closeRect.x + closeW * 0.5, -- 1954
		headY, -- 1954
		toColor(PALETTE.rouge), -- 1954
		0.5, -- 1954
		0.5, -- 1954
		"Center", -- 1954
		1.4, -- 1954
		0.95 * appear, -- 1954
		0 -- 1954
	) -- 1954
	uiInkDraw:drawSegment( -- 1955
		Vec2(inX + 12, headY - 20), -- 1955
		Vec2(inX + inW - 12, headY - 20), -- 1955
		0.85, -- 1955
		redSilk -- 1955
	) -- 1955
	local foldX = inX + inW * 0.48 -- 1958
	uiInkDraw:drawSegment( -- 1959
		Vec2(foldX - 3, inY + 12), -- 1959
		Vec2(foldX - 3, headY - 26), -- 1959
		0.65, -- 1959
		redFaint -- 1959
	) -- 1959
	uiInkDraw:drawSegment( -- 1960
		Vec2(foldX + 3, inY + 12), -- 1960
		Vec2(foldX + 3, headY - 26), -- 1960
		0.65, -- 1960
		redFaint -- 1960
	) -- 1960
	local leftX = inX + 18 -- 1963
	local leftW = foldX - leftX - 18 -- 1964
	local secTopY = headY - 40 -- 1965
	ctx.texts:put( -- 1966
		"sm", -- 1966
		"此行舆图与兵备", -- 1966
		leftX, -- 1966
		secTopY, -- 1966
		toColor(PALETTE.rouge), -- 1966
		0, -- 1966
		0.5, -- 1966
		"Left", -- 1966
		1.6, -- 1966
		0.92 * appear, -- 1966
		0 -- 1966
	) -- 1966
	local stY = secTopY - 34 -- 1969
	local stages = rg.stages -- 1970
	if #stages > 0 then -- 1971
		local sx0 = leftX + 14 -- 1972
		local sx1 = leftX + leftW - 14 -- 1973
		local step = #stages > 1 and (sx1 - sx0) / (#stages - 1) or 0 -- 1974
		uiInkDraw:drawSegment( -- 1975
			Vec2(sx0, stY), -- 1975
			Vec2(sx1, stY), -- 1975
			0.9, -- 1975
			toColor(PALETTE.xuanInkSub, 130 * appear) -- 1975
		) -- 1975
		local si = 0 -- 1976
		do -- 1976
			si = 0 -- 1977
			while si < #stages do -- 1977
				local st = stages[si + 1] -- 1978
				local nx = sx0 + si * step -- 1979
				if st.current then -- 1980
					drawDiamond( -- 1981
						uiInkDraw, -- 1981
						nx, -- 1981
						stY, -- 1981
						5.5, -- 1981
						5.5, -- 1981
						toColor(PALETTE.rouge, 235 * appear) -- 1981
					) -- 1981
				elseif st.cleared then -- 1982
					drawDiamond( -- 1983
						uiInkDraw, -- 1983
						nx, -- 1983
						stY, -- 1983
						4.5, -- 1983
						4.5, -- 1983
						toColor(PALETTE.xuanInk, 210 * appear) -- 1983
					) -- 1983
				else -- 1983
					drawDiamond( -- 1985
						uiInkDraw, -- 1985
						nx, -- 1985
						stY, -- 1985
						4, -- 1985
						4, -- 1985
						Color(232, 227, 216, 255), -- 1985
						0.9, -- 1985
						toColor(PALETTE.xuanInkSub, 150 * appear) -- 1985
					) -- 1985
				end -- 1985
				ctx.texts:put( -- 1987
					"xs", -- 1987
					st.label, -- 1987
					nx, -- 1987
					stY - 18, -- 1987
					toColor(st.current and PALETTE.rouge or PALETTE.xuanInk), -- 1987
					0.5, -- 1987
					0.5, -- 1987
					"Center", -- 1987
					0.2, -- 1987
					(st.current and 0.98 or 0.78) * appear, -- 1987
					0 -- 1987
				) -- 1987
				si = si + 1 -- 1977
			end -- 1977
		end -- 1977
	end -- 1977
	local gunBoxY = stY - 142 -- 1992
	local gunBoxH = 104 -- 1993
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1994
	uiInkDraw:drawRect( -- 1995
		Rect(leftX, gunBoxY, leftW, gunBoxH), -- 1995
		Color( -- 1995
			32, -- 1995
			30, -- 1995
			32, -- 1995
			math.floor(14 * appear + 0.5) -- 1995
		), -- 1995
		0.85, -- 1995
		redFaint -- 1995
	) -- 1995
	ctx.texts:put( -- 1996
		"sm", -- 1996
		wMeta.name, -- 1996
		leftX + 12, -- 1996
		gunBoxY + gunBoxH - 20, -- 1996
		toColor(PALETTE.xuanInk), -- 1996
		0, -- 1996
		0.5, -- 1996
		"Left", -- 1996
		1.2, -- 1996
		0.96 * appear, -- 1996
		0 -- 1996
	) -- 1996
	ctx.texts:put( -- 1997
		"xs", -- 1997
		(((("装填 " .. tostring(rg.reloadTicksNow)) .. " 拍  ·  体力 ") .. tostring(rg.hp)) .. "/") .. tostring(rg.maxHp), -- 1997
		leftX + 12, -- 1997
		gunBoxY + gunBoxH - 44, -- 1997
		toColor(PALETTE.xuanInkSub), -- 1997
		0, -- 1997
		0.5, -- 1997
		"Left", -- 1997
		0.4, -- 1997
		0.88 * appear, -- 1997
		0 -- 1997
	) -- 1997
	ctx.texts:put( -- 1998
		"xs", -- 1998
		wMeta.desc, -- 1998
		leftX + 12, -- 1998
		gunBoxY + 26, -- 1998
		toColor(PALETTE.xuanInkSub), -- 1998
		0, -- 1998
		0.5, -- 1998
		"Left", -- 1998
		0.2, -- 1998
		0.82 * appear, -- 1998
		0 -- 1998
	) -- 1998
	local gridCx = leftX + leftW - 44 -- 2001
	local gridCy = gunBoxY + gunBoxH * 0.5 -- 2002
	local gStep = 22 -- 2003
	local gi = 0 -- 2004
	do -- 2004
		gi = 0 -- 2005
		while gi < #RELOAD_GRID do -- 2005
			local node = RELOAD_GRID[gi + 1] -- 2006
			local gx = gridCx + (node.col - 1) * gStep -- 2007
			local gy = gridCy + (node.row - 1) * gStep -- 2008
			local isEnhanced = wMeta.effect == "light" and node.kind == "lamp" or wMeta.effect == "echo" and node.kind == "bell" -- 2009
			if node.kind == "lamp" or node.kind == "bell" then -- 2011
				drawReloadPatternGlyph( -- 2012
					uiInkDraw, -- 2013
					gx, -- 2014
					gy, -- 2015
					isEnhanced and 8 or 6.2, -- 2016
					node.kind == "lamp" and "light" or "echo", -- 2017
					isEnhanced and PALETTE.rouge or PALETTE.xuanInkSub, -- 2018
					(isEnhanced and 0.96 or 0.55) * appear -- 2019
				) -- 2019
			else -- 2019
				uiInkDraw:drawDot( -- 2022
					Vec2(gx, gy), -- 2022
					(node.kind == "start" or node.kind == "target") and 3 or 2, -- 2022
					toColor(PALETTE.xuanInkSub, 150 * appear) -- 2022
				) -- 2022
			end -- 2022
			gi = gi + 1 -- 2005
		end -- 2005
	end -- 2005
	local invTitleY = gunBoxY - 22 -- 2027
	ctx.texts:put( -- 2028
		"xs", -- 2028
		"随身战备清点", -- 2028
		leftX, -- 2028
		invTitleY, -- 2028
		toColor(PALETTE.rouge), -- 2028
		0, -- 2028
		0.5, -- 2028
		"Left", -- 2028
		1.2, -- 2028
		0.88 * appear, -- 2028
		0 -- 2028
	) -- 2028
	local drawnInv = 0 -- 2029
	local ii = 0 -- 2030
	do -- 2030
		ii = 0 -- 2031
		while ii < #PICKUP_ORDER do -- 2031
			do -- 2031
				local k = PICKUP_ORDER[ii + 1] -- 2032
				local cnt = rg.supplies[k] or 0 -- 2033
				if cnt <= 0 then -- 2034
					goto __continue273 -- 2035
				end -- 2035
				local col = drawnInv % 2 -- 2037
				local row = math.floor(drawnInv / 2) -- 2038
				if row >= 3 then -- 2039
					break -- 2040
				end -- 2040
				local ix = leftX + col * (leftW * 0.5) -- 2042
				local iy = invTitleY - 26 - row * 28 -- 2043
				local pm = pickupMetaOf(k) -- 2044
				drawPickupGlyph( -- 2045
					uiInkDraw, -- 2045
					ix + 10, -- 2045
					iy, -- 2045
					7.2, -- 2045
					k, -- 2045
					0.92 * appear, -- 2045
					PALETTE.xuanInk -- 2045
				) -- 2045
				ctx.texts:put( -- 2046
					"xs", -- 2046
					(pm.name .. " ×") .. tostring(cnt), -- 2046
					ix + 24, -- 2046
					iy, -- 2046
					toColor(PALETTE.xuanInk), -- 2046
					0, -- 2046
					0.5, -- 2046
					"Left", -- 2046
					0.4, -- 2046
					0.9 * appear, -- 2046
					0 -- 2046
				) -- 2046
				drawnInv = drawnInv + 1 -- 2047
			end -- 2047
			::__continue273:: -- 2047
			ii = ii + 1 -- 2031
		end -- 2031
	end -- 2031
	if drawnInv == 0 then -- 2049
		ctx.texts:put( -- 2050
			"xs", -- 2050
			"行囊尚空，沿途可拾筹材与战备。", -- 2050
			leftX, -- 2050
			invTitleY - 28, -- 2050
			toColor(PALETTE.xuanInkSub), -- 2050
			0, -- 2050
			0.5, -- 2050
			"Left", -- 2050
			0.6, -- 2050
			0.78 * appear, -- 2050
			0 -- 2050
		) -- 2050
	end -- 2050
	local rightX = foldX + 20 -- 2054
	local rightW = inX + inW - rightX - 18 -- 2055
	ctx.texts:put( -- 2056
		"sm", -- 2056
		"已习本领谱", -- 2056
		rightX, -- 2056
		secTopY, -- 2056
		toColor(PALETTE.rouge), -- 2056
		0, -- 2056
		0.5, -- 2056
		"Left", -- 2056
		1.6, -- 2056
		0.92 * appear, -- 2056
		0 -- 2056
	) -- 2056
	local learned = {} -- 2058
	for k in pairs(rg.ranks) do -- 2059
		if (rg.ranks[k] or 0) > 0 then -- 2060
			learned[#learned + 1] = k -- 2061
		end -- 2061
	end -- 2061
	if #learned == 0 then -- 2064
		ctx.texts:put( -- 2065
			"sm", -- 2065
			"尚未择筹 · 途中整备可习军筹", -- 2065
			rightX, -- 2065
			secTopY - 56, -- 2065
			toColor(PALETTE.xuanInkSub), -- 2065
			0, -- 2065
			0.5, -- 2065
			"Left", -- 2065
			0.8, -- 2065
			0.82 * appear, -- 2065
			0 -- 2065
		) -- 2065
	else -- 2065
		local li = 0 -- 2067
		do -- 2067
			li = 0 -- 2068
			while li < #learned and li < 5 do -- 2068
				local tid = learned[li + 1] -- 2069
				local rank = rg.ranks[tid] or 1 -- 2070
				local meta = resolveTalentVisual(tid, rg) -- 2071
				local rowY = secTopY - 46 - li * 56 -- 2072
				uiInkDraw:drawRect( -- 2073
					Rect(rightX, rowY - 22, rightW, 46), -- 2073
					Color( -- 2073
						32, -- 2073
						30, -- 2073
						32, -- 2073
						math.floor(12 * appear + 0.5) -- 2073
					), -- 2073
					0.75, -- 2073
					redFaint -- 2073
				) -- 2073
				drawTalentGlyph( -- 2074
					uiInkDraw, -- 2074
					rightX + 24, -- 2074
					rowY + 1, -- 2074
					13, -- 2074
					tid, -- 2074
					PALETTE.xuanInk, -- 2074
					0.92 * appear, -- 2074
					PALETTE.rouge -- 2074
				) -- 2074
				ctx.texts:put( -- 2075
					"sm", -- 2075
					((meta.title .. " · ") .. rankChinese(rank)) .. "阶", -- 2075
					rightX + 48, -- 2075
					rowY + 10, -- 2075
					toColor(PALETTE.xuanInk), -- 2075
					0, -- 2075
					0.5, -- 2075
					"Left", -- 2075
					1, -- 2075
					0.96 * appear, -- 2075
					0 -- 2075
				) -- 2075
				ctx.texts:put( -- 2076
					"xs", -- 2076
					meta:ledgerLine(rg, rank), -- 2076
					rightX + 48, -- 2076
					rowY - 10, -- 2076
					toColor(PALETTE.xuanInkSub), -- 2076
					0, -- 2076
					0.5, -- 2076
					"Left", -- 2076
					0.4, -- 2076
					0.88 * appear, -- 2076
					0 -- 2076
				) -- 2076
				li = li + 1 -- 2068
			end -- 2068
		end -- 2068
	end -- 2068
	local march = deriveMarchTitle(rg) -- 2081
	local footY = inY + 46 -- 2082
	uiInkDraw:drawSegment( -- 2083
		Vec2(rightX, footY + 36), -- 2083
		Vec2(rightX + rightW, footY + 36), -- 2083
		0.7, -- 2083
		redFaint -- 2083
	) -- 2083
	ctx.texts:put( -- 2084
		"xs", -- 2084
		"此行雅号", -- 2084
		rightX, -- 2084
		footY + 20, -- 2084
		toColor(PALETTE.xuanInkSub), -- 2084
		0, -- 2084
		0.5, -- 2084
		"Left", -- 2084
		1.4, -- 2084
		0.82 * appear, -- 2084
		0 -- 2084
	) -- 2084
	ctx.texts:put( -- 2085
		"md", -- 2085
		("「" .. march.title) .. "」", -- 2085
		rightX - 4, -- 2085
		footY - 2, -- 2085
		toColor(PALETTE.xuanInk), -- 2085
		0, -- 2085
		0.5, -- 2085
		"Left", -- 2085
		2.2, -- 2085
		0.96 * appear, -- 2085
		0 -- 2085
	) -- 2085
	ctx.texts:put( -- 2086
		"xs", -- 2086
		march.subtitle, -- 2086
		rightX + 4, -- 2086
		footY - 24, -- 2086
		toColor(PALETTE.xuanInkSub), -- 2086
		0, -- 2086
		0.5, -- 2086
		"Left", -- 2086
		0.8, -- 2086
		0.86 * appear, -- 2086
		0 -- 2086
	) -- 2086
	drawLoneSeal( -- 2087
		uiInkDraw, -- 2088
		uiArt, -- 2089
		ctx.texts, -- 2090
		"rg_ledger_seal", -- 2091
		rightX + rightW - 22, -- 2092
		footY + 2, -- 2093
		24, -- 2094
		46, -- 2095
		march.sealTop, -- 2096
		march.sealBot, -- 2097
		PALETTE.sealRed, -- 2098
		PALETTE.sealText, -- 2099
		0.94 * appear, -- 2100
		5 -- 2101
	) -- 2101
end -- 1903
return ____exports -- 1903
