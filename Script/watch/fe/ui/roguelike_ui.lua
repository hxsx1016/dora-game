-- [ts]: roguelike_ui.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Rect = ____Dora.Rect -- 17
local Vec2 = ____Dora.Vec2 -- 17
local ____run = require("Script.watch.run") -- 19
local mmss = ____run.mmss -- 19
local ____platform = require("Script.watch.platform") -- 22
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 22
local ____target = require("Script.watch.target") -- 23
local getActiveTarget = ____target.getActiveTarget -- 23
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 32
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 32
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 32
local ____talent_draft = require("Script.watch.fe.ui.talent_draft") -- 33
local computeTalentSlipRects = ____talent_draft.computeTalentSlipRects -- 33
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 34
local PICKUP_ORDER = ____talent_catalog.PICKUP_ORDER -- 35
local deriveMarchTitle = ____talent_catalog.deriveMarchTitle -- 37
local drawBrushArc = ____talent_catalog.drawBrushArc -- 38
local drawPickupGlyph = ____talent_catalog.drawPickupGlyph -- 39
local drawTalentGlyph = ____talent_catalog.drawTalentGlyph -- 40
local pickupMetaOf = ____talent_catalog.pickupMetaOf -- 41
local rankChinese = ____talent_catalog.rankChinese -- 42
local resolveTalentVisual = ____talent_catalog.resolveTalentVisual -- 43
local weaponMetaOf = ____talent_catalog.weaponMetaOf -- 44
local ____theme = require("Script.watch.fe.theme") -- 46
local PALETTE = ____theme.PALETTE -- 47
local drawBlossomDot = ____theme.drawBlossomDot -- 49
local drawDiamond = ____theme.drawDiamond -- 50
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 51
local drawHairline = ____theme.drawHairline -- 52
local drawLoneSeal = ____theme.drawLoneSeal -- 53
local drawMistCurve = ____theme.drawMistCurve -- 54
local drawSilkKeycap = ____theme.drawSilkKeycap -- 55
local drawSilkRibbon = ____theme.drawSilkRibbon -- 56
local drawSilkVeil = ____theme.drawSilkVeil -- 57
local fillRadialGlow = ____theme.fillRadialGlow -- 59
local fillVGradRect = ____theme.fillVGradRect -- 60
local themeOf = ____theme.themeOf -- 61
local toChineseUpper = ____theme.toChineseUpper -- 62
local toColor = ____theme.toColor -- 63
local SEAL_DURATION = 0.24 -- 120
local ABSORB_DURATION = 0.32 -- 121
local SEGMENT_BANNER_DURATION = 1.45 -- 122
local DEATH_RECAP_DURATION = 1.85 -- 123
local AUTO_REEXPAND_IDLE_SEC = 1.25 -- 124
local EXPANDED_FOCUS_SCALE = 0.25 -- 125
local TWO_PI = math.pi * 2 -- 126
local function clamp(v, lo, hi) -- 128
	return v < lo and lo or (v > hi and hi or v) -- 129
end -- 128
local function easeOutCubic(t) -- 132
	local u = 1 - clamp(t, 0, 1) -- 133
	return 1 - u * u * u -- 134
end -- 132
local function easeInOutQuad(t) -- 137
	local x = clamp(t, 0, 1) -- 138
	return x < 0.5 and 2 * x * x or 1 - (-2 * x + 2) ^ 2 * 0.5 -- 139
end -- 137
--- 计算三选一筹签卡的 UI 坐标矩形（展卷态与收束态单一布局真源，
-- 同时服务于渲染、鼠标点击、触屏直点热区与 verify-story-roguelike.lua 回归校验）。
function ____exports.computeRoguelikeCardRects(uiW, uiH, count, expanded, touchMode, safeTop) -- 146
	if touchMode == nil then -- 151
		touchMode = false -- 151
	end -- 151
	if safeTop == nil then -- 152
		safeTop = 0 -- 152
	end -- 152
	local out = {} -- 154
	if count <= 0 then -- 155
		return out -- 156
	end -- 156
	if expanded then -- 158
		local cardW = touchMode and 220 or 210 -- 159
		local cardH = touchMode and 248 or 244 -- 160
		local gap = math.min( -- 161
			18, -- 161
			math.max( -- 161
				10, -- 161
				(uiW - 80 - count * cardW) / math.max(1, count - 1) -- 161
			) -- 161
		) -- 161
		local actualW = math.min(cardW, (uiW - 64 - gap * (count - 1)) / count) -- 162
		local totalW = count * actualW + (count - 1) * gap -- 163
		local startX = (uiW - totalW) * 0.5 -- 164
		local y = math.max(138, uiH - 122 - safeTop - cardH) -- 166
		local i = 0 -- 167
		do -- 167
			i = 0 -- 168
			while i < count do -- 168
				out[#out + 1] = Rect(startX + i * (actualW + gap), y, actualW, cardH) -- 169
				i = i + 1 -- 168
			end -- 168
		end -- 168
		return out -- 171
	end -- 171
	local cardW = touchMode and 202 or 188 -- 173
	local cardH = touchMode and 48 or 40 -- 174
	local gap = 12 -- 175
	local totalW = count * cardW + (count - 1) * gap -- 176
	local startX = (uiW - totalW) * 0.5 -- 177
	local y = uiH - (touchMode and 116 or 106) - safeTop -- 178
	local i = 0 -- 179
	do -- 179
		i = 0 -- 180
		while i < count do -- 180
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 181
			i = i + 1 -- 180
		end -- 180
	end -- 180
	return out -- 183
end -- 146
local function stageOrderNumeral(roomKey) -- 186
	if roomKey == "escort1" or roomKey == "s1-crossroad" then -- 187
		return "壹" -- 187
	end -- 187
	if roomKey == "escort2" or roomKey == "s2-drygoods" then -- 188
		return "贰" -- 188
	end -- 188
	if roomKey == "escort3" or roomKey == "s3-archway" then -- 189
		return "叁" -- 189
	end -- 189
	if roomKey == "escort4" or roomKey == "c1-yard" then -- 190
		return "肆" -- 190
	end -- 190
	if roomKey == "escort5" or roomKey == "c2-granary" then -- 191
		return "伍" -- 191
	end -- 191
	return "壹" -- 192
end -- 186
local function stageReadableName(roomKey) -- 195
	if roomKey == "escort1" then -- 196
		return "城外巷路 · 第一段" -- 196
	end -- 196
	if roomKey == "escort2" then -- 197
		return "粮棚取材 · 第二段" -- 197
	end -- 197
	if roomKey == "escort3" then -- 198
		return "山腰工台 · 第三段" -- 198
	end -- 198
	if roomKey == "escort4" then -- 199
		return "夜山窄道 · 第四段" -- 199
	end -- 199
	if roomKey == "escort5" then -- 200
		return "塔前山道 · 第五段" -- 200
	end -- 200
	return themeOf(roomKey).titleZh -- 201
end -- 195
____exports.RoguelikeUiPlugin = __TS__Class() -- 204
local RoguelikeUiPlugin = ____exports.RoguelikeUiPlugin -- 204
RoguelikeUiPlugin.name = "RoguelikeUiPlugin" -- 204
function RoguelikeUiPlugin.prototype.____constructor(self, contract, getHudSelected, setHudSelected) -- 267
	self.id = "fe-roguelike-ui" -- 205
	self.drawerState = "hidden" -- 212
	self.manualCompact = false -- 213
	self.expandAnimT = 0 -- 214
	self.staggerTime = 0 -- 215
	self.idleSinceMove = 0 -- 216
	self.hoverSlot = -1 -- 217
	self.focusedSlot = 0 -- 218
	self.cardLiftT = {0, 0, 0} -- 219
	self.focusScale = 1 -- 220
	self.animTime = 0 -- 221
	self.lastOffers = {} -- 224
	self.lastRanks = {} -- 225
	self.lastCardBoxes = {} -- 226
	self.lastUiW = 1280 -- 227
	self.lastUiH = 720 -- 228
	self.lastTouchMode = false -- 229
	self.lastSafeTop = 0 -- 230
	self.expandToggleBox = Rect(0, 0, 0, 0) -- 231
	self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 232
	self.ledgerCloseBox = Rect(0, 0, 0, 0) -- 233
	self.ledgerPanelBox = Rect(0, 0, 0, 0) -- 234
	self.crestPulseMap = {} -- 238
	self.hpBarPulseT = 0 -- 239
	self.xiaomanRippleT = 0 -- 240
	self.ledgerOpen = false -- 243
	self.ledgerAnimT = 0 -- 244
	self.pendingToggleLedger = false -- 245
	self.pendingCloseLedger = false -- 246
	self.pickupBounceMap = {} -- 249
	self.pickupShakeMap = {} -- 250
	self.pickupPops = {} -- 251
	self.lastSuppliesShown = {} -- 252
	self.segmentBannerT = 0 -- 255
	self.segmentBannerHeadline = "" -- 256
	self.segmentBannerSub = "" -- 257
	self.deathRecapT = 0 -- 258
	self.lastMarchTitle = "初启北行" -- 262
	self.lastGuardArcActive = false -- 263
	self.lastReloadArcActive = false -- 264
	self.lastCraftRingActive = false -- 265
	self.contract = contract -- 272
	self.getHudSelected = getHudSelected -- 273
	self.setHudSelected = setHudSelected -- 274
end -- 267
function RoguelikeUiPlugin.prototype.canPickTalent(self) -- 277
	return not self.ledgerOpen and self.deathRecapT <= 0.15 and (self.drawerState == "expanded" or self.drawerState == "compact") -- 278
end -- 277
function RoguelikeUiPlugin.prototype.isExpanded(self) -- 282
	return self.drawerState == "expanded" -- 283
end -- 282
function RoguelikeUiPlugin.prototype.isLedgerOpen(self) -- 286
	return self.ledgerOpen -- 287
end -- 286
function RoguelikeUiPlugin.prototype.isModalOverlayActive(self) -- 291
	return self.ledgerOpen or self.deathRecapT > 0.05 -- 292
end -- 291
function RoguelikeUiPlugin.prototype.isSuppressingRoomBanner(self) -- 296
	return self.ledgerOpen or self.deathRecapT > 0.05 or self.drawerState == "expanded" or self.drawerState == "sealing" or self.segmentBannerT > 0.05 -- 297
end -- 296
function RoguelikeUiPlugin.prototype.openLedger(self) -- 304
	self.ledgerOpen = true -- 305
	self.ledgerAnimT = 0 -- 306
end -- 304
function RoguelikeUiPlugin.prototype.closeLedger(self) -- 309
	self.ledgerOpen = false -- 310
end -- 309
function RoguelikeUiPlugin.prototype.toggleLedger(self) -- 313
	if self.ledgerOpen then -- 314
		self:closeLedger() -- 315
	else -- 315
		self:openLedger() -- 317
	end -- 317
end -- 313
function RoguelikeUiPlugin.prototype.setCompact(self, compact) -- 321
	self.manualCompact = compact -- 322
	if #self.lastOffers > 0 and self.sealAnim == nil then -- 323
		self.drawerState = compact and "compact" or "expanded" -- 324
		if not compact then -- 325
			self.expandAnimT = 0 -- 326
			self.staggerTime = 0 -- 327
		end -- 327
	end -- 327
end -- 321
function RoguelikeUiPlugin.prototype.triggerTestDeathRecap(self, roomKey, ranks, weapon) -- 333
	if weapon == nil then -- 333
		weapon = "standard_gun" -- 333
	end -- 333
	self:showDeathRecap(roomKey, ranks, weapon, 0) -- 334
end -- 333
function RoguelikeUiPlugin.prototype.showDeathRecap(self, roomKey, ranks, weapon, seed) -- 337
	local total = 0 -- 338
	local copy = {} -- 339
	for k in pairs(ranks) do -- 340
		if ranks[k] > 0 then -- 341
			copy[k] = ranks[k] -- 342
			total = total + ranks[k] -- 343
		end -- 343
	end -- 343
	self.deathRecapSnap = { -- 346
		roomKey = roomKey, -- 347
		stageName = stageReadableName(roomKey), -- 348
		ranks = copy, -- 349
		totalRanks = total, -- 350
		weaponId = weapon, -- 351
		seed = seed -- 352
	} -- 352
	self.deathRecapT = DEATH_RECAP_DURATION -- 354
end -- 337
function RoguelikeUiPlugin.prototype.triggerTestSegmentBanner(self, roomKey, nextKey) -- 358
	if nextKey == nil then -- 358
		nextKey = "" -- 358
	end -- 358
	self.segmentBannerHeadline = stageOrderNumeral(roomKey) .. "程告破" -- 359
	self.segmentBannerSub = nextKey ~= "" and "渐近北塔 · 前往" .. themeOf(nextKey).shortNameZh or "渐近北塔 · 筹策犹在" -- 360
	self.segmentBannerT = SEGMENT_BANNER_DURATION -- 361
end -- 358
function RoguelikeUiPlugin.prototype.getTalentCardRects(self, uiW, uiH, count, touchMode, safeTop) -- 365
	if touchMode == nil then -- 369
		touchMode = false -- 369
	end -- 369
	if safeTop == nil then -- 370
		safeTop = 0 -- 370
	end -- 370
	if not self:canPickTalent() then -- 372
		return {} -- 372
	end -- 372
	local useExpanded = self.drawerState ~= "compact" -- 373
	return ____exports.computeRoguelikeCardRects( -- 374
		uiW, -- 374
		uiH, -- 374
		count, -- 374
		useExpanded, -- 374
		touchMode, -- 374
		safeTop -- 374
	) -- 374
end -- 365
function RoguelikeUiPlugin.prototype.getLedgerButtonRect(self) -- 377
	return self.ledgerButtonBox -- 378
end -- 377
function RoguelikeUiPlugin.prototype.getExpandToggleRect(self) -- 381
	return self.expandToggleBox -- 382
end -- 381
function RoguelikeUiPlugin.prototype.getState(self) -- 385
	return { -- 386
		drawerState = self.drawerState, -- 387
		offers = __TS__ArraySlice(self.lastOffers), -- 388
		focusedSlot = self.focusedSlot, -- 389
		focusTimeScale = self.focusScale, -- 390
		ledgerOpen = self.ledgerOpen, -- 391
		sealingActive = self.drawerState == "sealing", -- 392
		absorbingActive = self.drawerState == "absorbing", -- 393
		segmentBannerActive = self.segmentBannerT > 0.01, -- 394
		deathRecapActive = self.deathRecapT > 0.01, -- 395
		deathRecapRoom = self.deathRecapSnap ~= nil and self.deathRecapSnap.roomKey or "", -- 396
		deathRecapCount = self.deathRecapSnap ~= nil and self.deathRecapSnap.totalRanks or 0, -- 397
		marchTitle = self.lastMarchTitle, -- 398
		suppliesShown = __TS__ArraySlice(self.lastSuppliesShown), -- 399
		activeGuardArc = self.lastGuardArcActive, -- 400
		activeReloadArc = self.lastReloadArcActive, -- 401
		activeCraftRing = self.lastCraftRingActive, -- 402
		lastCardBoxes = __TS__ArraySlice(self.lastCardBoxes), -- 403
		ledgerButtonBox = self.ledgerButtonBox, -- 404
		expandToggleBox = self.expandToggleBox -- 405
	} -- 405
end -- 385
function RoguelikeUiPlugin.prototype.onBindPlay(self, _p, view) -- 409
	local rg = view.roguelike -- 410
	self.manualCompact = false -- 411
	self.expandAnimT = 0 -- 412
	self.staggerTime = 0 -- 413
	self.idleSinceMove = 0 -- 414
	self.hoverSlot = -1 -- 415
	self.focusedSlot = 0 -- 416
	self.cardLiftT = {0, 0, 0} -- 417
	self.sealAnim = nil -- 418
	self.ledgerOpen = false -- 419
	self.ledgerAnimT = 0 -- 420
	self.pickupBounceMap = {} -- 421
	self.pickupShakeMap = {} -- 422
	self.pickupPops = {} -- 423
	self.crestPulseMap = {} -- 424
	self.hpBarPulseT = 0 -- 425
	self.xiaomanRippleT = 0 -- 426
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 427
	self.lastRanks = {} -- 428
	for k in pairs(rg.ranks) do -- 429
		self.lastRanks[k] = rg.ranks[k] -- 430
	end -- 430
	self.drawerState = #rg.offers > 0 and "expanded" or "hidden" -- 432
	self.focusScale = 1 -- 433
	if self.contract ~= nil then -- 434
		self.contract:setFocusTimeScale(1) -- 435
	end -- 435
	self:resetInputEdges() -- 437
end -- 409
function RoguelikeUiPlugin.prototype.requestToggleLedger(self) -- 441
	self.pendingToggleLedger = true -- 442
end -- 441
function RoguelikeUiPlugin.prototype.requestCloseLedger(self) -- 445
	self.pendingCloseLedger = true -- 446
end -- 445
function RoguelikeUiPlugin.prototype.resetInputEdges(self) -- 449
	self.pendingToggleLedger = false -- 450
	self.pendingCloseLedger = false -- 451
end -- 449
function RoguelikeUiPlugin.prototype.startSealAnimation(self, talentId, ctx) -- 454
	local pickedSlot = __TS__ArrayIndexOf(self.lastOffers, talentId) -- 455
	if pickedSlot < 0 then -- 456
		pickedSlot = clamp( -- 457
			self.focusedSlot, -- 457
			0, -- 457
			math.max(0, #self.lastOffers - 1) -- 457
		) -- 457
	end -- 457
	local boxes = #self.lastCardBoxes > 0 and __TS__ArraySlice(self.lastCardBoxes) or ____exports.computeRoguelikeCardRects( -- 459
		ctx.uiW, -- 462
		ctx.uiH, -- 463
		math.max(1, #self.lastOffers), -- 464
		self.drawerState ~= "compact", -- 465
		ctx.input:isTouchMode(), -- 466
		(ctx.safeUi or ZERO_SAFE_INSETS).top -- 467
	) -- 467
	local pickedBox = boxes[pickedSlot + 1] or Rect(ctx.uiW * 0.5 - 100, ctx.uiH * 0.5 - 60, 200, 120) -- 469
	local meta = resolveTalentVisual(talentId, ctx.view.roguelike) -- 470
	self.sealAnim = { -- 471
		talentId = talentId, -- 472
		pickedSlot = pickedSlot, -- 473
		pickedBox = pickedBox, -- 474
		allBoxes = boxes, -- 475
		allOffers = __TS__ArraySlice(self.lastOffers), -- 476
		elapsed = 0, -- 477
		sealDuration = SEAL_DURATION, -- 478
		absorbDuration = ABSORB_DURATION, -- 479
		targetKind = meta.absorbTarget, -- 480
		fromExpanded = self.drawerState ~= "compact", -- 481
		arrivedPulsed = false -- 482
	} -- 482
	self.drawerState = "sealing" -- 484
	self.hoverSlot = -1 -- 485
	ctx.input:vibrate(0.024) -- 486
	if ctx.view.backCarry.active then -- 487
		self.xiaomanRippleT = 0.78 -- 488
	end -- 488
end -- 454
function RoguelikeUiPlugin.prototype.detectPickedTalentFromRankDiff(self, nowRanks) -- 492
	for k in pairs(nowRanks) do -- 493
		if (nowRanks[k] or 0) > (self.lastRanks[k] or 0) then -- 494
			return k -- 495
		end -- 495
	end -- 495
	return self.lastOffers[clamp( -- 498
		self.focusedSlot, -- 498
		0, -- 498
		math.max(0, #self.lastOffers - 1) -- 498
	) + 1] or "" -- 498
end -- 492
function RoguelikeUiPlugin.prototype.update(self, ctx) -- 501
	local rg = ctx.view.roguelike -- 502
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 503
	local touchMode = ctx.input:isTouchMode() -- 504
	self.lastUiW = ctx.uiW -- 505
	self.lastUiH = ctx.uiH -- 506
	self.lastTouchMode = touchMode -- 507
	self.lastSafeTop = safe.top -- 508
	self.lastMarchTitle = deriveMarchTitle(rg).title -- 509
	if ctx.paused then -- 512
		self:resetInputEdges() -- 513
		return -- 514
	end -- 514
	local udt = math.max(0, ctx.uiDt) -- 517
	self.animTime = self.animTime + udt -- 518
	if ctx.events.segmentDone and ctx.events.segmentKey ~= "" then -- 521
		self.segmentBannerHeadline = stageOrderNumeral(ctx.events.segmentKey) .. "程告破" -- 522
		self.segmentBannerSub = ctx.events.segmentNext ~= "" and "渐近北塔 · 前往" .. themeOf(ctx.events.segmentNext).shortNameZh or "渐近北塔 · 筹策犹在" -- 523
		self.segmentBannerT = SEGMENT_BANNER_DURATION -- 526
	end -- 526
	local fallen = ctx.events.fallenBuild -- 529
	if ctx.events.campaignFailedReset and fallen ~= nil then -- 530
		self:showDeathRecap(ctx.events.campaignFailedRoom, fallen.ranks, fallen.weaponId, fallen.seed) -- 531
		self:closeLedger() -- 532
	end -- 532
	if ctx.events.pickupTaken and ctx.events.pickupKind ~= "" then -- 535
		self.pickupBounceMap[ctx.events.pickupKind] = 0.52 -- 536
		local ____self_pickupPops_0 = self.pickupPops -- 537
		____self_pickupPops_0[#____self_pickupPops_0 + 1] = {kind = ctx.events.pickupKind, timer = 0.72, maxTimer = 0.72} -- 537
		if #self.pickupPops > 6 then -- 538
			table.remove(self.pickupPops, 1) -- 539
		end -- 539
	end -- 539
	if ctx.events.pickupRejected and ctx.events.pickupRejectedKind ~= "" then -- 542
		self.pickupShakeMap[ctx.events.pickupRejectedKind] = 0.42 -- 543
	end -- 543
	if self.segmentBannerT > 0 then -- 547
		self.segmentBannerT = math.max(0, self.segmentBannerT - udt) -- 548
	end -- 548
	if self.hpBarPulseT > 0 then -- 550
		self.hpBarPulseT = math.max(0, self.hpBarPulseT - udt) -- 551
	end -- 551
	if self.xiaomanRippleT > 0 then -- 553
		self.xiaomanRippleT = math.max(0, self.xiaomanRippleT - udt) -- 554
	end -- 554
	for k in pairs(self.crestPulseMap) do -- 556
		if self.crestPulseMap[k] > 0 then -- 557
			self.crestPulseMap[k] = math.max(0, self.crestPulseMap[k] - udt) -- 558
		end -- 558
	end -- 558
	for k in pairs(self.pickupBounceMap) do -- 561
		if self.pickupBounceMap[k] > 0 then -- 562
			self.pickupBounceMap[k] = math.max(0, self.pickupBounceMap[k] - udt) -- 563
		end -- 563
	end -- 563
	for k in pairs(self.pickupShakeMap) do -- 566
		if self.pickupShakeMap[k] > 0 then -- 567
			self.pickupShakeMap[k] = math.max(0, self.pickupShakeMap[k] - udt) -- 568
		end -- 568
	end -- 568
	local pi = 0 -- 571
	local pw = 0 -- 572
	do -- 572
		pi = 0 -- 573
		while pi < #self.pickupPops do -- 573
			local pop = self.pickupPops[pi + 1] -- 574
			pop.timer = pop.timer - udt -- 575
			if pop.timer > 0 then -- 576
				self.pickupPops[pw + 1] = pop -- 577
				pw = pw + 1 -- 578
			end -- 578
			pi = pi + 1 -- 573
		end -- 573
	end -- 573
	__TS__ArraySetLength(self.pickupPops, pw) -- 581
	if self.deathRecapT > 0 then -- 584
		local elapsedRecap = DEATH_RECAP_DURATION - self.deathRecapT -- 585
		local wantSkip = elapsedRecap > 0.25 and (math.abs(ctx.input.moveX) > 0.2 or ctx.input.uiPressed or ctx.input.fire.pressed or ctx.input.interact.pressed or ctx.input.navConfirm) -- 586
		self.deathRecapT = math.max(0, self.deathRecapT - udt * (wantSkip and 4.2 or 1)) -- 593
	end -- 593
	local hadOffers = #self.lastOffers > 0 -- 597
	local hasOffers = #rg.offers > 0 -- 598
	if ctx.events.talentPicked and ctx.events.talentPickedId ~= "" then -- 599
		self:startSealAnimation(ctx.events.talentPickedId, ctx) -- 600
	elseif hadOffers and not hasOffers and self.sealAnim == nil then -- 601
		local diffId = self:detectPickedTalentFromRankDiff(rg.ranks) -- 602
		if diffId ~= "" then -- 603
			self:startSealAnimation(diffId, ctx) -- 604
		end -- 604
	elseif not hadOffers and hasOffers then -- 606
		self.sealAnim = nil -- 608
		self.drawerState = "expanded" -- 609
		self.manualCompact = false -- 610
		self.expandAnimT = 0 -- 611
		self.staggerTime = 0 -- 612
		self.idleSinceMove = 0 -- 613
		self.hoverSlot = -1 -- 614
		self.cardLiftT = {} -- 615
		local ci = 0 -- 616
		do -- 616
			ci = 0 -- 617
			while ci < #rg.offers do -- 617
				local ____self_cardLiftT_1 = self.cardLiftT -- 618
				____self_cardLiftT_1[#____self_cardLiftT_1 + 1] = 0 -- 618
				ci = ci + 1 -- 617
			end -- 617
		end -- 617
		ctx.audio:playUi("ui:talent_appear", "assets/audio/ui/talent_appear.wav", 0.68, 0.25) -- 620
	end -- 620
	if self.sealAnim ~= nil then -- 624
		local ____self_sealAnim_2, ____elapsed_3 = self.sealAnim, "elapsed" -- 625
		____self_sealAnim_2[____elapsed_3] = ____self_sealAnim_2[____elapsed_3] + udt -- 625
		local totalDur = self.sealAnim.sealDuration + self.sealAnim.absorbDuration -- 626
		if self.sealAnim.elapsed < self.sealAnim.sealDuration then -- 627
			self.drawerState = "sealing" -- 628
		elseif self.sealAnim.elapsed < totalDur then -- 629
			self.drawerState = "absorbing" -- 630
		else -- 630
			if not self.sealAnim.arrivedPulsed then -- 632
				self.sealAnim.arrivedPulsed = true -- 633
				self.crestPulseMap[self.sealAnim.talentId] = 0.72 -- 634
				if self.sealAnim.targetKind == "hp" then -- 635
					self.hpBarPulseT = 0.7 -- 636
				end -- 636
			end -- 636
			self.sealAnim = nil -- 639
			self.drawerState = hasOffers and (self.manualCompact and "compact" or "expanded") or "hidden" -- 640
		end -- 640
	elseif not hasOffers then -- 642
		self.drawerState = "hidden" -- 643
	end -- 643
	local modalBlocking = ctx.view.reloadSession.active or ctx.view.craftBench.active -- 647
	self:processLedgerAndCardInputs(ctx, rg, modalBlocking) -- 648
	if self.sealAnim == nil and hasOffers then -- 650
		local movingOrActing = math.abs(ctx.input.moveX) > 0.15 or math.abs(ctx.input.moveY) > 0.15 or ctx.input.jump.pressed or ctx.input.fire.pressed and self.hoverSlot < 0 or modalBlocking -- 651
		if self.drawerState == "expanded" then -- 656
			self.expandAnimT = math.min(1, self.expandAnimT + udt / 0.22) -- 657
			self.staggerTime = self.staggerTime + udt -- 658
			if movingOrActing then -- 659
				self.drawerState = "compact" -- 660
				self.idleSinceMove = 0 -- 661
			end -- 661
		elseif self.drawerState == "compact" then -- 663
			if movingOrActing or ctx.input.fire.held or self.ledgerOpen or self.deathRecapT > 0.05 then -- 664
				self.idleSinceMove = 0 -- 665
			elseif not self.manualCompact then -- 666
				self.idleSinceMove = self.idleSinceMove + udt -- 667
				if self.idleSinceMove >= AUTO_REEXPAND_IDLE_SEC then -- 668
					self.drawerState = "expanded" -- 669
					self.expandAnimT = 0 -- 670
					self.staggerTime = 0 -- 671
					self.idleSinceMove = 0 -- 672
				end -- 672
			end -- 672
		end -- 672
	end -- 672
	while #self.cardLiftT < #rg.offers do -- 679
		local ____self_cardLiftT_4 = self.cardLiftT -- 680
		____self_cardLiftT_4[#____self_cardLiftT_4 + 1] = 0 -- 680
	end -- 680
	local li = 0 -- 682
	do -- 682
		li = 0 -- 683
		while li < #rg.offers do -- 683
			local isHot = ctx.input.inputMode == "gamepad" and li == self.focusedSlot or ctx.input.inputMode ~= "gamepad" and li == self.hoverSlot -- 684
			local target = isHot and 1 or 0 -- 686
			local ____self_cardLiftT_5, ____temp_6 = self.cardLiftT, li + 1 -- 687
			____self_cardLiftT_5[____temp_6] = ____self_cardLiftT_5[____temp_6] + (target - self.cardLiftT[li + 1]) * math.min(1, udt * 14) -- 687
			li = li + 1 -- 683
		end -- 683
	end -- 683
	local wantSlowFocus = not modalBlocking and not ctx.p.escortFailed and self.deathRecapT <= 0.05 and (self.ledgerOpen or not ctx.p.talentModalActive and self.drawerState == "expanded" and hasOffers) -- 692
	local targetScale = wantSlowFocus and EXPANDED_FOCUS_SCALE or 1 -- 696
	local speed = wantSlowFocus and 5.2 or 6 -- 697
	if self.focusScale < targetScale then -- 698
		self.focusScale = math.min(targetScale, self.focusScale + udt * speed) -- 699
	elseif self.focusScale > targetScale then -- 700
		self.focusScale = math.max(targetScale, self.focusScale - udt * speed) -- 701
	end -- 701
	if self.contract ~= nil then -- 703
		self.contract:setFocusTimeScale(self.focusScale) -- 704
	end -- 704
	if not ctx.view.reloadSession.active then -- 706
		ctx.audio:setWorldPlaySpeed(math.max( -- 707
			0.25, -- 707
			math.min(1, self.focusScale) -- 707
		)) -- 707
	end -- 707
	if self.ledgerOpen then -- 710
		self.ledgerAnimT = math.min(1, self.ledgerAnimT + udt / 0.2) -- 711
	end -- 711
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 715
	self.lastRanks = {} -- 716
	for k in pairs(rg.ranks) do -- 717
		self.lastRanks[k] = rg.ranks[k] -- 718
	end -- 718
	if hasOffers then -- 720
		self.lastCardBoxes = ctx.p.talentModalActive and computeTalentSlipRects( -- 721
			ctx.uiW, -- 722
			ctx.uiH, -- 722
			#rg.offers, -- 722
			touchMode, -- 722
			safe.top -- 722
		) or self:getTalentCardRects( -- 723
			ctx.uiW, -- 723
			ctx.uiH, -- 723
			#rg.offers, -- 723
			touchMode, -- 723
			safe.top -- 723
		) -- 723
	else -- 723
		self.lastCardBoxes = {} -- 725
	end -- 725
end -- 501
function RoguelikeUiPlugin.prototype.processLedgerAndCardInputs(self, ctx, rg, modalBlocking) -- 729
	local touchMode = ctx.input:isTouchMode() -- 734
	local useUiPtr = ctx.input.uiInside or ctx.input.uiPressed or ctx.input.uiHeld -- 735
	local ptrX = (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 736
	local ptrY = (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 737
	local ____useUiPtr_7 -- 738
	if useUiPtr then -- 738
		____useUiPtr_7 = ctx.input.uiInside -- 738
	else -- 738
		____useUiPtr_7 = ctx.input.inside -- 738
	end -- 738
	local inside = ____useUiPtr_7 -- 738
	local ptr = Vec2(ptrX, ptrY) -- 739
	local leftClick = ctx.input.uiPressed or ctx.input.inputMode == "kbm" and ctx.input.fire.pressed -- 741
	local vPressed = self.pendingToggleLedger -- 743
	local closeRequested = self.pendingCloseLedger -- 744
	self.pendingToggleLedger = false -- 745
	self.pendingCloseLedger = false -- 746
	if ctx.input.touchZoneTap == "ledger:toggle" and rg.active and not modalBlocking and not ctx.p.escortFailed then -- 749
		ctx.input.touchZoneTap = "" -- 750
		self:toggleLedgerWithSound(ctx) -- 751
		return -- 752
	end -- 752
	if vPressed and rg.active and not modalBlocking and not ctx.p.escortFailed then -- 756
		self:toggleLedgerWithSound(ctx) -- 757
		return -- 758
	end -- 758
	if self.ledgerOpen then -- 761
		if modalBlocking or ctx.p.escortFailed or closeRequested or ctx.input.navBack then -- 762
			self.ledgerOpen = false -- 763
			ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 764
			return -- 765
		end -- 765
		if leftClick and inside then -- 767
			if self.ledgerCloseBox:containsPoint(ptr) or not self.ledgerPanelBox:containsPoint(ptr) then -- 768
				self.ledgerOpen = false -- 769
				ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 770
			end -- 770
		end -- 770
		return -- 773
	end -- 773
	if rg.active and not modalBlocking and leftClick and inside and self.ledgerButtonBox.width > 0 and self.ledgerButtonBox:containsPoint(ptr) then -- 777
		self:toggleLedgerWithSound(ctx) -- 779
		return -- 780
	end -- 780
	if #rg.offers > 0 and not modalBlocking and leftClick and inside and self.expandToggleBox.width > 0 and self.expandToggleBox:containsPoint(ptr) then -- 784
		local nextCompact = self.drawerState == "expanded" -- 786
		self:setCompact(nextCompact) -- 787
		ctx.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 788
		return -- 789
	end -- 789
	if #rg.offers > 0 and not modalBlocking and self.sealAnim == nil then -- 793
		if ctx.input.inputMode == "gamepad" then -- 794
			local hudSel = self.getHudSelected ~= nil and self.getHudSelected() or self.focusedSlot -- 795
			local clamped = clamp(hudSel, 0, #rg.offers - 1) -- 796
			if clamped ~= self.focusedSlot then -- 797
				self.focusedSlot = clamped -- 798
				ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 799
			end -- 799
			self.hoverSlot = -1 -- 801
		elseif not touchMode and inside then -- 802
			local boxes = self:getTalentCardRects( -- 803
				ctx.uiW, -- 803
				ctx.uiH, -- 803
				#rg.offers, -- 803
				false, -- 803
				(ctx.safeUi or ZERO_SAFE_INSETS).top -- 803
			) -- 803
			local hit = -1 -- 804
			local i = 0 -- 805
			do -- 805
				i = 0 -- 806
				while i < #boxes do -- 806
					if boxes[i + 1]:containsPoint(ptr) then -- 807
						hit = i -- 808
						break -- 809
					end -- 809
					i = i + 1 -- 806
				end -- 806
			end -- 806
			if hit ~= self.hoverSlot then -- 812
				self.hoverSlot = hit -- 813
				if hit >= 0 then -- 814
					self.focusedSlot = hit -- 815
					if self.setHudSelected ~= nil then -- 816
						self.setHudSelected(hit) -- 817
					end -- 817
					ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045) -- 819
				end -- 819
			end -- 819
		else -- 819
			self.hoverSlot = -1 -- 823
		end -- 823
	else -- 823
		self.hoverSlot = -1 -- 826
	end -- 826
end -- 729
function RoguelikeUiPlugin.prototype.toggleLedgerWithSound(self, ctx) -- 830
	if self.ledgerOpen then -- 831
		self.ledgerOpen = false -- 832
		ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 833
	else -- 833
		self.ledgerOpen = true -- 835
		self.ledgerAnimT = 0 -- 836
		ctx.audio:playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08) -- 837
	end -- 837
end -- 830
function RoguelikeUiPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 843
	local p = ctx.p -- 849
	local rg = ctx.view.roguelike -- 850
	local cam = ctx.cam -- 851
	self.lastGuardArcActive = false -- 853
	self.lastReloadArcActive = false -- 854
	self.lastCraftRingActive = false -- 855
	if ctx.view.visualMode == "museum" then -- 857
		return -- 858
	end -- 858
	local bi = 0 -- 862
	do -- 862
		bi = 0 -- 863
		while bi < #p.boxes do -- 863
			do -- 863
				local b = p.boxes[bi + 1] -- 864
				if b.broken == true or b.hidden == true or b.id == nil then -- 865
					goto __continue145 -- 866
				end -- 866
				local ps = p.run.props[b.id] -- 868
				if ps == nil then -- 869
					goto __continue145 -- 870
				end -- 870
				local depth = b.depth ~= nil and (b.depth.min + b.depth.max) * 0.5 or 0 -- 872
				local x0 = cam:sx(b.x0) -- 873
				local x1 = cam:sx(b.x1) -- 874
				local y0 = cam:sy(b.y0, depth) -- 875
				local y1 = cam:sy(b.y1, depth) -- 876
				local bw = x1 - x0 -- 877
				local bh = y1 - y0 -- 878
				if bw <= 2 or bh <= 2 then -- 879
					goto __continue145 -- 880
				end -- 880
				if ps.wedge == true then -- 882
					local ww = math.max( -- 884
						6, -- 884
						cam:len(6.5) -- 884
					) -- 884
					local wh = math.max( -- 885
						7, -- 885
						cam:len(8) -- 885
					) -- 885
					fgDraw:drawPolygon( -- 886
						{ -- 886
							Vec2(x0 - ww * 0.7, y0), -- 887
							Vec2(x0 + ww * 0.45, y0), -- 888
							Vec2(x0 + ww * 0.2, y0 + wh), -- 889
							Vec2(x0 - ww * 0.25, y0 + wh * 0.55) -- 890
						}, -- 890
						toColor(PALETTE.emerald, 220), -- 891
						1.1, -- 891
						toColor(PALETTE.moonPale, 220) -- 891
					) -- 891
					fgDraw:drawPolygon( -- 892
						{ -- 892
							Vec2(x1 + ww * 0.7, y0), -- 893
							Vec2(x1 - ww * 0.45, y0), -- 894
							Vec2(x1 - ww * 0.2, y0 + wh), -- 895
							Vec2(x1 + ww * 0.25, y0 + wh * 0.55) -- 896
						}, -- 896
						toColor(PALETTE.emerald, 220), -- 897
						1.1, -- 897
						toColor(PALETTE.moonPale, 220) -- 897
					) -- 897
					fgDraw:drawSegment( -- 898
						Vec2(x0 + 2, y1 - 1), -- 898
						Vec2(x1 - 2, y1 - 1), -- 898
						1.6, -- 898
						toColor(PALETTE.emerald, 210) -- 898
					) -- 898
				end -- 898
				if ps.hp == 1 and not ps.broken then -- 900
					local mx = (x0 + x1) * 0.5 -- 902
					fgDraw:drawSegment( -- 903
						Vec2(mx - bw * 0.14, y1 - bh * 0.08), -- 903
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 903
						1.4, -- 903
						Color(14, 12, 16, 220) -- 903
					) -- 903
					fgDraw:drawSegment( -- 904
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 904
						Vec2(mx - bw * 0.08, y0 + bh * 0.14), -- 904
						1.3, -- 904
						Color(14, 12, 16, 220) -- 904
					) -- 904
					fgDraw:drawSegment( -- 905
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 905
						Vec2(mx + bw * 0.22, y0 + bh * 0.34), -- 905
						1, -- 905
						Color(214, 186, 146, 150) -- 905
					) -- 905
				end -- 905
			end -- 905
			::__continue145:: -- 905
			bi = bi + 1 -- 863
		end -- 863
	end -- 863
	if p.childMode or not p.player.alive then -- 909
		return -- 910
	end -- 910
	local pl = p.player -- 913
	local px = cam:sx(pl.x) -- 914
	local pyCenter = cam:sy(pl.y + pl.h * 0.56, pl.depth) -- 915
	local headY = cam:sy(pl.y + pl.h + 10, pl.depth) -- 916
	local facing = pl.facing >= 0 and 1 or -1 -- 917
	local guardRank = rg.ranks.guard or 0 -- 920
	if rg.activeInvulnTicks > 0 and guardRank > 0 then -- 921
		self.lastGuardArcActive = true -- 922
		local frac = clamp( -- 923
			rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 923
			0, -- 923
			1 -- 923
		) -- 923
		local arcR = math.max( -- 924
			18, -- 924
			cam:len(20) -- 924
		) -- 924
		local halfSpan = (0.35 + 0.85 * frac) * math.pi * 0.55 -- 925
		local baseAngle = facing > 0 and 0 or math.pi -- 926
		drawBrushArc( -- 927
			fgDraw, -- 928
			px + facing * cam:len(4), -- 929
			pyCenter, -- 930
			arcR, -- 931
			arcR * 1.18, -- 932
			baseAngle - halfSpan, -- 933
			baseAngle + halfSpan, -- 934
			2.4, -- 935
			toColor( -- 936
				PALETTE.emerald, -- 936
				math.floor(140 + 95 * frac + 0.5) -- 936
			), -- 936
			14 -- 937
		) -- 937
		drawBrushArc( -- 939
			fgGlow, -- 940
			px + facing * cam:len(4), -- 941
			pyCenter, -- 942
			arcR * 1.12, -- 943
			arcR * 1.28, -- 944
			baseAngle - halfSpan * 0.82, -- 945
			baseAngle + halfSpan * 0.82, -- 946
			1.3, -- 947
			toColor( -- 948
				PALETTE.moonPale, -- 948
				math.floor(90 * frac + 0.5) -- 948
			), -- 948
			12 -- 949
		) -- 949
	end -- 949
	if rg.activeReloadTicks > 0 and not ctx.view.reloadSession.active then -- 954
		self.lastReloadArcActive = true -- 955
		local totalRel = math.max(1, rg.reloadTicksNow) -- 956
		local prog = clamp(1 - rg.activeReloadTicks / totalRel, 0, 1) -- 957
		local rx = px + facing * cam:len(14) -- 958
		local ry = headY + cam:len(4) -- 959
		local rr = math.max( -- 960
			9, -- 960
			cam:len(10) -- 960
		) -- 960
		local hasReloadRank = (rg.ranks.reload or 0) > 0 -- 961
		local arcCol = hasReloadRank and PALETTE.amberCore or PALETTE.silkLine -- 962
		drawBrushArc( -- 963
			fgDraw, -- 963
			rx, -- 963
			ry, -- 963
			rr, -- 963
			rr, -- 963
			math.pi * 0.15, -- 963
			math.pi * 0.85, -- 963
			1.4, -- 963
			toColor(PALETTE.inkWash, 160), -- 963
			10 -- 963
		) -- 963
		local endA = math.pi * 0.85 - math.pi * 0.7 * prog -- 964
		drawBrushArc( -- 965
			fgDraw, -- 965
			rx, -- 965
			ry, -- 965
			rr, -- 965
			rr, -- 965
			endA, -- 965
			math.pi * 0.85, -- 965
			2.1, -- 965
			toColor(arcCol, 230), -- 965
			10 -- 965
		) -- 965
		if hasReloadRank then -- 966
			local sparkX = rx + math.cos(endA) * rr -- 967
			local sparkY = ry + math.sin(endA) * rr -- 968
			fgGlow:drawDot( -- 969
				Vec2(sparkX, sparkY), -- 969
				2.8, -- 969
				toColor(PALETTE.amberCore, 240) -- 969
			) -- 969
			fillRadialGlow( -- 970
				fgGlow, -- 970
				sparkX, -- 970
				sparkY, -- 970
				9, -- 970
				9, -- 970
				toColor(PALETTE.amber, 70), -- 970
				Color(214, 186, 146, 0), -- 970
				10 -- 970
			) -- 970
		end -- 970
	end -- 970
	if rg.activeCraftTicks > 0 then -- 975
		self.lastCraftRingActive = true -- 976
		local totalCraft = math.max(1, rg.craftTicksNow) -- 977
		local prog = clamp(rg.activeCraftTicks / totalCraft, 0, 1) -- 978
		local cx = px + facing * cam:len(12) -- 979
		local cy = headY + cam:len(8) -- 980
		local cr = math.max( -- 981
			11, -- 981
			cam:len(12) -- 981
		) -- 981
		drawBrushArc( -- 982
			fgDraw, -- 982
			cx, -- 982
			cy, -- 982
			cr, -- 982
			cr, -- 982
			0, -- 982
			TWO_PI, -- 982
			1.5, -- 982
			Color(14, 17, 25, 160), -- 982
			16 -- 982
		) -- 982
		drawBrushArc( -- 983
			fgDraw, -- 983
			cx, -- 983
			cy, -- 983
			cr, -- 983
			cr, -- 983
			math.pi * 0.5, -- 983
			math.pi * 0.5 - TWO_PI * prog, -- 983
			2.4, -- 983
			toColor(PALETTE.amberCore, 240), -- 983
			16 -- 983
		) -- 983
		local k = 0 -- 984
		do -- 984
			k = 0 -- 985
			while k < 4 do -- 985
				local ph = (self.animTime * 4.6 + k * 0.25) % 1 -- 986
				local ang = k * 1.57 + ph * 1.4 -- 987
				local sx = cx + math.cos(ang) * (cr + ph * 10) -- 988
				local sy = cy + math.sin(ang) * (cr + ph * 8) - ph * 6 -- 989
				fgDraw:drawSegment( -- 990
					Vec2(sx - 2, sy), -- 990
					Vec2(sx + 2, sy + 1.5), -- 990
					1.3, -- 990
					toColor( -- 990
						PALETTE.amber, -- 990
						math.floor(215 * (1 - ph) + 0.5) -- 990
					) -- 990
				) -- 990
				k = k + 1 -- 985
			end -- 985
		end -- 985
	end -- 985
	if self.xiaomanRippleT > 0.01 and ctx.view.backCarry.active then -- 995
		local p01 = 1 - self.xiaomanRippleT / 0.78 -- 996
		local bx = px - facing * cam:len(8) -- 997
		local by = cam:sy(pl.y + pl.h * 0.68, pl.depth) -- 998
		local rr = cam:len(8) + easeOutCubic(p01) * cam:len(22) -- 999
		local alpha = (1 - p01) * 0.85 -- 1000
		drawBrushArc( -- 1001
			fgGlow, -- 1001
			bx, -- 1001
			by, -- 1001
			rr, -- 1001
			rr, -- 1001
			0, -- 1001
			TWO_PI, -- 1001
			1.5, -- 1001
			toColor( -- 1001
				PALETTE.amberCore, -- 1001
				math.floor(180 * alpha + 0.5) -- 1001
			), -- 1001
			18 -- 1001
		) -- 1001
		fillRadialGlow( -- 1002
			fgGlow, -- 1002
			bx, -- 1002
			by, -- 1002
			rr * 0.8, -- 1002
			rr * 0.8, -- 1002
			toColor( -- 1002
				PALETTE.amber, -- 1002
				math.floor(48 * alpha + 0.5) -- 1002
			), -- 1002
			Color(214, 186, 146, 0), -- 1002
			12 -- 1002
		) -- 1002
	end -- 1002
end -- 843
function RoguelikeUiPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1008
	local rg = ctx.view.roguelike -- 1015
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1016
	local modalBlocking = ctx.view.reloadSession.active or ctx.view.craftBench.active -- 1017
	if rg.active and not modalBlocking and not self.ledgerOpen and not ctx.p.escortFailed and self.deathRecapT <= 0.15 then -- 1020
		if rg.showRouteTrack and #rg.stages > 0 then -- 1021
			self:drawNorthwardTrack( -- 1022
				uiDraw, -- 1022
				uiInkDraw, -- 1022
				uiArt, -- 1022
				uiGlow, -- 1022
				ctx, -- 1022
				rg.stages, -- 1022
				safe -- 1022
			) -- 1022
		end -- 1022
		self:drawCrestAndSatchelHud( -- 1024
			uiDraw, -- 1024
			uiInkDraw, -- 1024
			uiArt, -- 1024
			uiGlow, -- 1024
			ctx, -- 1024
			rg, -- 1024
			safe -- 1024
		) -- 1024
	else -- 1024
		self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 1026
	end -- 1026
	if not modalBlocking and not self.ledgerOpen and not ctx.p.escortFailed and self.deathRecapT <= 0.15 then -- 1031
		if self.sealAnim ~= nil then -- 1032
			self:drawSealAndAbsorb( -- 1033
				uiDraw, -- 1033
				uiInkDraw, -- 1033
				uiArt, -- 1033
				uiGlow, -- 1033
				ctx, -- 1033
				rg, -- 1033
				self.sealAnim -- 1033
			) -- 1033
		elseif #rg.offers > 0 and not ctx.p.talentModalActive then -- 1034
			if self.drawerState == "expanded" then -- 1035
				self:drawExpandedTalentCards( -- 1036
					uiDraw, -- 1036
					uiInkDraw, -- 1036
					uiArt, -- 1036
					uiGlow, -- 1036
					ctx, -- 1036
					rg, -- 1036
					safe -- 1036
				) -- 1036
			elseif self.drawerState == "compact" then -- 1037
				self:drawCompactTalentTallies( -- 1038
					uiDraw, -- 1038
					uiInkDraw, -- 1038
					uiArt, -- 1038
					ctx, -- 1038
					rg, -- 1038
					safe -- 1038
				) -- 1038
			end -- 1038
		else -- 1038
			self.expandToggleBox = Rect(0, 0, 0, 0) -- 1041
		end -- 1041
	else -- 1041
		self.expandToggleBox = Rect(0, 0, 0, 0) -- 1044
	end -- 1044
	if self.segmentBannerT > 0.01 then -- 1048
		self:drawSegmentClearRibbon( -- 1049
			uiDraw, -- 1049
			uiInkDraw, -- 1049
			uiArt, -- 1049
			uiGlow, -- 1049
			ctx, -- 1049
			safe -- 1049
		) -- 1049
	end -- 1049
	if not ctx.p.escortFailed and self.deathRecapT > 0.01 and self.deathRecapSnap ~= nil then -- 1053
		self:drawDeathRecapOverlay( -- 1054
			uiDraw, -- 1054
			uiInkDraw, -- 1054
			uiArt, -- 1054
			uiGlow, -- 1054
			ctx, -- 1054
			self.deathRecapSnap -- 1054
		) -- 1054
	end -- 1054
	if self.ledgerOpen and rg.active and not modalBlocking then -- 1058
		self:drawBuildLedger( -- 1059
			uiDraw, -- 1059
			uiInkDraw, -- 1059
			uiArt, -- 1059
			uiGlow, -- 1059
			ctx, -- 1059
			rg, -- 1059
			safe -- 1059
		) -- 1059
		return true -- 1060
	end -- 1060
	return self.drawerState == "expanded" and self.hoverSlot >= 0 -- 1063
end -- 1008
function RoguelikeUiPlugin.prototype.drawNorthwardTrack(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, stages, safe) -- 1068
	local cx = ctx.uiW * 0.5 -- 1077
	local y = ctx.uiH - (ctx.view.isRehearsal and 50 or 24) - safe.top -- 1078
	local spanW = math.min(360, ctx.uiW * 0.34) -- 1079
	local x0 = cx - spanW * 0.5 -- 1080
	local step = #stages > 1 and spanW / (#stages - 1) or 0 -- 1081
	drawSilkVeil( -- 1083
		uiDraw, -- 1083
		uiArt, -- 1083
		"rg_track_veil", -- 1083
		cx, -- 1083
		y, -- 1083
		spanW + 108, -- 1083
		28, -- 1083
		PALETTE.inkWash, -- 1083
		0.56, -- 1083
		-1 -- 1083
	) -- 1083
	uiInkDraw:drawSegment( -- 1084
		Vec2(x0, y + 3), -- 1084
		Vec2(x0 + spanW, y + 3), -- 1084
		0.9, -- 1084
		toColor(PALETTE.silkDim, 130) -- 1084
	) -- 1084
	local curIdx = 0 -- 1087
	local i = 0 -- 1088
	do -- 1088
		i = 0 -- 1089
		while i < #stages do -- 1089
			if stages[i + 1].current then -- 1090
				curIdx = i -- 1091
				break -- 1092
			end -- 1092
			i = i + 1 -- 1089
		end -- 1089
	end -- 1089
	if curIdx > 0 then -- 1095
		uiInkDraw:drawSegment( -- 1096
			Vec2(x0, y + 3), -- 1096
			Vec2(x0 + step * curIdx, y + 3), -- 1096
			1.4, -- 1096
			toColor(PALETTE.moonPale, 195) -- 1096
		) -- 1096
	end -- 1096
	do -- 1096
		i = 0 -- 1099
		while i < #stages do -- 1099
			local st = stages[i + 1] -- 1100
			local nx = x0 + step * i -- 1101
			local ny = y + 3 -- 1102
			if st.current then -- 1103
				local breathe = 0.82 + 0.18 * math.sin(self.animTime * 4.2) -- 1104
				fillRadialGlow( -- 1105
					uiGlow, -- 1105
					nx, -- 1105
					ny, -- 1105
					14, -- 1105
					14, -- 1105
					toColor(PALETTE.rouge, 46 * breathe), -- 1105
					Color(182, 58, 56, 0), -- 1105
					10 -- 1105
				) -- 1105
				drawBlossomDot( -- 1106
					uiInkDraw, -- 1106
					uiArt, -- 1106
					"rg_st_cur_" .. tostring(i), -- 1106
					nx, -- 1106
					ny, -- 1106
					13, -- 1106
					PALETTE.rouge, -- 1106
					0.96, -- 1106
					4 -- 1106
				) -- 1106
			elseif st.cleared then -- 1107
				drawDiamond( -- 1108
					uiInkDraw, -- 1108
					nx, -- 1108
					ny, -- 1108
					4.2, -- 1108
					4.2, -- 1108
					toColor(PALETTE.moonPale, 225), -- 1108
					0.8, -- 1108
					toColor(PALETTE.cyan, 180) -- 1108
				) -- 1108
			elseif st.isBench or st.isFinal then -- 1109
				fillRadialGlow( -- 1110
					uiGlow, -- 1110
					nx, -- 1110
					ny, -- 1110
					10, -- 1110
					10, -- 1110
					toColor(PALETTE.amber, 26), -- 1110
					Color(214, 186, 146, 0), -- 1110
					8 -- 1110
				) -- 1110
				drawDiamond( -- 1111
					uiInkDraw, -- 1111
					nx, -- 1111
					ny, -- 1111
					4, -- 1111
					4, -- 1111
					Color(20, 22, 30, 210), -- 1111
					1.1, -- 1111
					toColor(PALETTE.amberCore, 215) -- 1111
				) -- 1111
			else -- 1111
				drawDiamond( -- 1113
					uiInkDraw, -- 1113
					nx, -- 1113
					ny, -- 1113
					3.3, -- 1113
					3.3, -- 1113
					Color(16, 19, 27, 210), -- 1113
					0.9, -- 1113
					toColor(PALETTE.silkDim, 155) -- 1113
				) -- 1113
			end -- 1113
			local labelCol = st.current and PALETTE.textBright or ((st.isBench or st.isFinal) and PALETTE.amberCore or (st.cleared and PALETTE.textMid or PALETTE.textDim)) -- 1115
			ctx.texts:put( -- 1118
				"xs", -- 1119
				st.label, -- 1120
				nx, -- 1121
				ny - 14, -- 1122
				toColor(labelCol), -- 1123
				0.5, -- 1124
				0.5, -- 1125
				"Center", -- 1126
				0.4, -- 1127
				st.current and 0.96 or 0.72, -- 1128
				0.08 -- 1129
			) -- 1129
			i = i + 1 -- 1099
		end -- 1099
	end -- 1099
end -- 1068
function RoguelikeUiPlugin.prototype.drawCrestAndSatchelHud(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1136
	local bx = 28 + safe.left -- 1145
	local hpBaseY = ctx.uiH - 72 - safe.top -- 1146
	local p = ctx.p -- 1147
	if self.hpBarPulseT > 0.01 then -- 1150
		local pA = clamp(self.hpBarPulseT / 0.7, 0, 1) -- 1151
		fillRadialGlow( -- 1152
			uiGlow, -- 1152
			bx + 130, -- 1152
			hpBaseY + 16, -- 1152
			140, -- 1152
			28, -- 1152
			toColor(PALETTE.moonPale, 44 * pA), -- 1152
			Color(232, 236, 234, 0), -- 1152
			12 -- 1152
		) -- 1152
	end -- 1152
	local ____p_isCampaign_13 = p.isCampaign -- 1156
	if ____p_isCampaign_13 then -- 1156
		local ____opt_8 = p.room.campaign -- 1157
		local ____temp_12 = (____opt_8 and ____opt_8.chapter) == "S" -- 1157
		if not ____temp_12 then -- 1157
			local ____opt_10 = p.room.campaign -- 1157
			____temp_12 = (____opt_10 and ____opt_10.chapter) == "C" -- 1157
		end -- 1157
		____p_isCampaign_13 = ____temp_12 -- 1156
	end -- 1156
	local fearVisible = ____p_isCampaign_13 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 1156
	local row1Y = hpBaseY - (fearVisible and 52 or 24) -- 1159
	local learnedIds = {} -- 1162
	local baseOrder = { -- 1163
		"vitality", -- 1164
		"guard", -- 1164
		"stride", -- 1164
		"focus", -- 1164
		"push_force", -- 1165
		"echo_wide", -- 1165
		"lantern_pierce", -- 1165
		"salvage", -- 1165
		"reload", -- 1166
		"craft" -- 1166
	} -- 1166
	local i = 0 -- 1168
	do -- 1168
		i = 0 -- 1169
		while i < #baseOrder do -- 1169
			if (rg.ranks[baseOrder[i + 1]] or 0) > 0 then -- 1170
				learnedIds[#learnedIds + 1] = baseOrder[i + 1] -- 1171
			end -- 1171
			i = i + 1 -- 1169
		end -- 1169
	end -- 1169
	for k in pairs(rg.ranks) do -- 1174
		if (rg.ranks[k] or 0) > 0 and __TS__ArrayIndexOf(learnedIds, k) < 0 then -- 1175
			learnedIds[#learnedIds + 1] = k -- 1176
		end -- 1176
	end -- 1176
	local cursorX = bx -- 1181
	local badgeH = 26 -- 1182
	local rowCenterY = row1Y + 6 -- 1183
	do -- 1183
		i = 0 -- 1184
		while i < #learnedIds do -- 1184
			local tid = learnedIds[i + 1] -- 1185
			local rank = rg.ranks[tid] or 1 -- 1186
			local meta = resolveTalentVisual(tid, rg) -- 1187
			local badgeW = 62 -- 1188
			local pulse = self.crestPulseMap[tid] or 0 -- 1189
			local activeNow = tid == "guard" and rg.activeInvulnTicks > 0 or (tid == "reload" or tid == "focus") and rg.activeReloadTicks > 0 or (tid == "craft" or tid == "salvage") and rg.activeCraftTicks > 0 -- 1190
			local glowBoost = math.max( -- 1193
				pulse, -- 1193
				activeNow and 0.55 + 0.35 * math.sin(self.animTime * 8) or 0 -- 1193
			) -- 1193
			if glowBoost > 0.02 then -- 1195
				fillRadialGlow( -- 1196
					uiGlow, -- 1196
					cursorX + badgeW * 0.5, -- 1196
					rowCenterY, -- 1196
					badgeW * 0.72, -- 1196
					20, -- 1196
					toColor(meta.accentCore, 46 * glowBoost), -- 1196
					Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1196
					10 -- 1196
				) -- 1196
			end -- 1196
			uiDraw:drawRoundedRect( -- 1198
				Rect(cursorX, rowCenterY - badgeH * 0.5, badgeW, badgeH), -- 1199
				4, -- 1200
				toColor(activeNow and PALETTE.inkWarm or PALETTE.inkWash, activeNow and 225 or 196), -- 1201
				(activeNow or pulse > 0.05) and 1.3 or 0.85, -- 1202
				toColor((activeNow or pulse > 0.05) and meta.accentCore or meta.accent, activeNow and 235 or 168) -- 1203
			) -- 1203
			drawTalentGlyph( -- 1205
				uiInkDraw, -- 1205
				cursorX + 15, -- 1205
				rowCenterY, -- 1205
				8.2, -- 1205
				tid, -- 1205
				meta.accent, -- 1205
				0.96, -- 1205
				meta.accentCore -- 1205
			) -- 1205
			ctx.texts:put( -- 1206
				"xs", -- 1207
				rankChinese(rank), -- 1208
				cursorX + 41, -- 1209
				rowCenterY, -- 1210
				toColor(meta.accentCore), -- 1211
				0.5, -- 1212
				0.5, -- 1213
				"Center", -- 1214
				0, -- 1215
				0.96, -- 1216
				0.08 -- 1217
			) -- 1217
			if tid == "guard" and rg.activeInvulnTicks > 0 then -- 1220
				local frac = clamp( -- 1221
					rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 1221
					0, -- 1221
					1 -- 1221
				) -- 1221
				uiInkDraw:drawSegment( -- 1222
					Vec2(cursorX + 4, rowCenterY - badgeH * 0.5 + 2), -- 1223
					Vec2(cursorX + 4 + (badgeW - 8) * frac, rowCenterY - badgeH * 0.5 + 2), -- 1224
					2, -- 1225
					toColor(PALETTE.emerald, 240) -- 1226
				) -- 1226
			end -- 1226
			cursorX = cursorX + (badgeW + 6) -- 1229
			i = i + 1 -- 1184
		end -- 1184
	end -- 1184
	local ledgerLabel = ctx.input.inputMode == "kbm" and "札记 V" or "札记" -- 1233
	local ledgerW = ctx.input.inputMode == "kbm" and 64 or 48 -- 1234
	local ledgerRect = Rect(cursorX, rowCenterY - badgeH * 0.5, ledgerW, badgeH) -- 1235
	self.ledgerButtonBox = ledgerRect -- 1236
	local ptrX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 1237
	local ptrY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 1238
	local ledgerHover = not ctx.input:isTouchMode() and (ctx.input.uiInside or ctx.input.inside) and ledgerRect:containsPoint(Vec2(ptrX, ptrY)) -- 1239
	uiDraw:drawRoundedRect( -- 1240
		ledgerRect, -- 1241
		4, -- 1242
		toColor(ledgerHover and PALETTE.rougeSoft or PALETTE.inkWash, ledgerHover and 205 or 176), -- 1243
		0.9, -- 1244
		toColor(ledgerHover and PALETTE.amberCore or PALETTE.silkDim, ledgerHover and 225 or 155) -- 1245
	) -- 1245
	ctx.texts:put( -- 1247
		"xs", -- 1248
		ledgerLabel, -- 1249
		ledgerRect.x + ledgerRect.width * 0.5, -- 1250
		rowCenterY, -- 1251
		toColor(ledgerHover and PALETTE.textBright or PALETTE.amberCore), -- 1252
		0.5, -- 1253
		0.5, -- 1254
		"Center", -- 1255
		0.6, -- 1256
		0.92, -- 1257
		0.08 -- 1258
	) -- 1258
	local touchLandscape = ctx.input:shouldShowTouchControls() and ctx.uiW > ctx.uiH -- 1264
	local row2Y = touchLandscape and rowCenterY - 30 or 28 + safe.bottom -- 1265
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1266
	local shownItems = {} -- 1267
	local shownKinds = {} -- 1268
	do -- 1268
		i = 0 -- 1269
		while i < #PICKUP_ORDER do -- 1269
			local k = PICKUP_ORDER[i + 1] -- 1270
			local cnt = rg.supplies[k] or 0 -- 1271
			if cnt > 0 then -- 1272
				shownItems[#shownItems + 1] = {kind = k, count = cnt} -- 1273
				shownKinds[#shownKinds + 1] = k -- 1274
			end -- 1274
			i = i + 1 -- 1269
		end -- 1269
	end -- 1269
	self.lastSuppliesShown = shownKinds -- 1277
	if touchLandscape and self.drawerState == "expanded" then -- 1278
		return -- 1279
	end -- 1279
	local woodCnt = rg.supplies.wood or 0 -- 1282
	local bellCnt = rg.supplies.bell or 0 -- 1283
	local craftReady = (rg.roomKey == "escort2" or rg.roomKey == "escort3") and (woodCnt >= 2 or woodCnt >= 1 and bellCnt >= 1) and rg.equippedWeapon == "standard_gun" -- 1284
	local sx = bx -- 1289
	local weaponW = 86 -- 1290
	local pillH = 24 -- 1291
	if not touchLandscape then -- 1292
		local stripW = weaponW + 6 + #shownItems * 59 + (craftReady and 68 or 0) + 28 -- 1293
		drawSilkVeil( -- 1294
			uiDraw, -- 1294
			uiArt, -- 1294
			"rg_satchel_veil", -- 1294
			bx + stripW * 0.45, -- 1294
			row2Y, -- 1294
			stripW + 32, -- 1294
			34, -- 1294
			PALETTE.inkWash, -- 1294
			0.56, -- 1294
			-1 -- 1294
		) -- 1294
	end -- 1294
	uiDraw:drawRoundedRect( -- 1296
		Rect(sx, row2Y - pillH * 0.5, weaponW, pillH), -- 1297
		4, -- 1298
		toColor(PALETTE.inkWash, 185), -- 1299
		0.85, -- 1300
		toColor(wMeta.accent, 160) -- 1301
	) -- 1301
	drawReloadPatternGlyph( -- 1303
		uiInkDraw, -- 1303
		sx + 14, -- 1303
		row2Y, -- 1303
		7.2, -- 1303
		wMeta.effect, -- 1303
		wMeta.accent, -- 1303
		0.94 -- 1303
	) -- 1303
	ctx.texts:put( -- 1304
		"xs", -- 1304
		wMeta.shortName, -- 1304
		sx + 26, -- 1304
		row2Y, -- 1304
		toColor(wMeta.accent), -- 1304
		0, -- 1304
		0.5, -- 1304
		"Left", -- 1304
		0.5, -- 1304
		0.94, -- 1304
		0.08 -- 1304
	) -- 1304
	sx = sx + (weaponW + 6) -- 1305
	do -- 1305
		i = 0 -- 1307
		while i < #shownItems do -- 1307
			local it = shownItems[i + 1] -- 1308
			local pm = pickupMetaOf(it.kind) -- 1309
			local bounce = self.pickupBounceMap[it.kind] or 0 -- 1310
			local shake = self.pickupShakeMap[it.kind] or 0 -- 1311
			local shakeX = shake > 0 and math.sin(self.animTime * 56) * 3.2 * (shake / 0.42) or 0 -- 1312
			local liftY = bounce > 0 and math.sin(bounce / 0.52 * math.pi) * 5 or 0 -- 1313
			local itemW = 54 -- 1314
			local rx = sx + shakeX -- 1315
			local ry = row2Y + liftY -- 1316
			local isHot = bounce > 0.02 or craftReady and (it.kind == "wood" or it.kind == "bell") -- 1317
			local bdCol = shake > 0.02 and PALETTE.rouge or (isHot and PALETTE.amberCore or pm.accent) -- 1318
			if isHot then -- 1320
				local ga = bounce > 0.02 and 48 * (bounce / 0.52) or 24 + 12 * math.sin(self.animTime * 4.5) -- 1321
				fillRadialGlow( -- 1322
					uiGlow, -- 1322
					rx + itemW * 0.5, -- 1322
					ry, -- 1322
					34, -- 1322
					16, -- 1322
					toColor(PALETTE.amberCore, ga), -- 1322
					Color(214, 186, 146, 0), -- 1322
					10 -- 1322
				) -- 1322
			end -- 1322
			uiDraw:drawRoundedRect( -- 1324
				Rect(rx, ry - pillH * 0.5, itemW, pillH), -- 1325
				4, -- 1326
				toColor(shake > 0.02 and PALETTE.inkWarm or PALETTE.inkWash, 192), -- 1327
				(isHot or shake > 0.02) and 1.2 or 0.8, -- 1328
				toColor(bdCol, (isHot or shake > 0.02) and 225 or 148) -- 1329
			) -- 1329
			drawPickupGlyph( -- 1331
				uiInkDraw, -- 1331
				rx + 14, -- 1331
				ry, -- 1331
				7.2, -- 1331
				it.kind, -- 1331
				0.96 -- 1331
			) -- 1331
			ctx.texts:put( -- 1332
				"xs", -- 1333
				"×" .. tostring(it.count), -- 1334
				rx + 37, -- 1335
				ry, -- 1336
				toColor(pm.accentCore), -- 1337
				0.5, -- 1338
				0.5, -- 1339
				"Center", -- 1340
				0, -- 1341
				0.96, -- 1342
				0.08 -- 1343
			) -- 1343
			local popIdx = 0 -- 1346
			do -- 1346
				popIdx = 0 -- 1347
				while popIdx < #self.pickupPops do -- 1347
					local pop = self.pickupPops[popIdx + 1] -- 1348
					if pop.kind == it.kind then -- 1349
						local prog = 1 - pop.timer / pop.maxTimer -- 1350
						ctx.texts:put( -- 1351
							"xs", -- 1352
							"+1", -- 1353
							rx + itemW * 0.5, -- 1354
							ry + 16 + prog * 14, -- 1355
							toColor(PALETTE.amberCore), -- 1356
							0.5, -- 1357
							0.5, -- 1358
							"Center", -- 1359
							0, -- 1360
							1 - prog, -- 1361
							0.08 -- 1362
						) -- 1362
						break -- 1364
					end -- 1364
					popIdx = popIdx + 1 -- 1347
				end -- 1347
			end -- 1347
			sx = sx + (itemW + 5) -- 1367
			i = i + 1 -- 1307
		end -- 1307
	end -- 1307
	if craftReady then -- 1370
		local breathe = 0.72 + 0.28 * math.sin(self.animTime * 4.2) -- 1371
		uiDraw:drawRoundedRect( -- 1372
			Rect(sx, row2Y - pillH * 0.5, 62, pillH), -- 1372
			4, -- 1372
			toColor(PALETTE.inkWarm, 185), -- 1372
			0.95, -- 1372
			toColor(PALETTE.amberCore, 210 * breathe) -- 1372
		) -- 1372
		ctx.texts:put( -- 1373
			"xs", -- 1373
			"足改制", -- 1373
			sx + 31, -- 1373
			row2Y, -- 1373
			toColor(PALETTE.amberCore), -- 1373
			0.5, -- 1373
			0.5, -- 1373
			"Center", -- 1373
			0.6, -- 1373
			0.94 * breathe, -- 1373
			0.08 -- 1373
		) -- 1373
	end -- 1373
end -- 1136
function RoguelikeUiPlugin.prototype.drawExpandedTalentCards(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1379
	local offers = rg.offers -- 1388
	local touchMode = ctx.input:isTouchMode() -- 1389
	local mode = ctx.input.inputMode -- 1390
	local boxes = ____exports.computeRoguelikeCardRects( -- 1391
		ctx.uiW, -- 1391
		ctx.uiH, -- 1391
		#offers, -- 1391
		true, -- 1391
		touchMode, -- 1391
		safe.top -- 1391
	) -- 1391
	self.lastCardBoxes = boxes -- 1392
	local appear = easeOutCubic(self.expandAnimT) -- 1393
	local slowFrac = clamp((1 - self.focusScale) / (1 - EXPANDED_FOCUS_SCALE), 0, 1) -- 1394
	fillVGradRect( -- 1397
		uiDraw, -- 1398
		0, -- 1399
		ctx.uiH * 0.36, -- 1400
		ctx.uiW, -- 1401
		ctx.uiH * 0.64, -- 1402
		Color(9, 12, 19, 0), -- 1403
		Color( -- 1404
			9, -- 1404
			12, -- 1404
			19, -- 1404
			math.floor((138 + 42 * slowFrac) * appear + 0.5) -- 1404
		) -- 1404
	) -- 1404
	local firstBox = boxes[1] -- 1408
	local headY = firstBox.y + firstBox.height + 28 -- 1409
	local cx = ctx.uiW * 0.5 -- 1410
	drawSilkVeil( -- 1411
		uiDraw, -- 1411
		uiArt, -- 1411
		"rg_exp_head_veil", -- 1411
		cx, -- 1411
		headY, -- 1411
		440, -- 1411
		30, -- 1411
		PALETTE.inkWash, -- 1411
		0.78 * appear, -- 1411
		-1 -- 1411
	) -- 1411
	drawHairline( -- 1412
		uiInkDraw, -- 1412
		uiArt, -- 1412
		"rg_exp_head_line", -- 1412
		cx, -- 1412
		headY + 15, -- 1412
		360, -- 1412
		PALETTE.amber, -- 1412
		0.54 * appear, -- 1412
		true, -- 1412
		2 -- 1412
	) -- 1412
	local headText = mode == "gamepad" and ("途中整备 · 择一军筹（LB/RB 择项 · " .. getActiveTarget():keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " / L3 落印）" or (touchMode and "途中整备 · 择一军筹 · 轻触卡面直接落印" or "途中整备 · 择一军筹 · 按 1 / 2 / 3 或点击落印") -- 1413
	ctx.texts:put( -- 1418
		"xs", -- 1418
		headText, -- 1418
		cx, -- 1418
		headY, -- 1418
		toColor(PALETTE.amberCore), -- 1418
		0.5, -- 1418
		0.5, -- 1418
		"Center", -- 1418
		1, -- 1418
		0.96 * appear, -- 1418
		0.08 -- 1418
	) -- 1418
	local lastBox = boxes[#boxes] -- 1421
	local togX = math.min(ctx.uiW - 86 - safe.right, lastBox.x + lastBox.width - 52) -- 1422
	local togRect = Rect(togX, headY - 12, 54, 24) -- 1423
	self.expandToggleBox = togRect -- 1424
	uiDraw:drawRoundedRect( -- 1425
		togRect, -- 1425
		4, -- 1425
		toColor(PALETTE.inkWash, 185 * appear), -- 1425
		0.85, -- 1425
		toColor(PALETTE.silkDim, 165 * appear) -- 1425
	) -- 1425
	ctx.texts:put( -- 1426
		"xs", -- 1426
		"收束", -- 1426
		togRect.x + 27, -- 1426
		headY, -- 1426
		toColor(PALETTE.textMid), -- 1426
		0.5, -- 1426
		0.5, -- 1426
		"Center", -- 1426
		0.6, -- 1426
		0.88 * appear, -- 1426
		0.08 -- 1426
	) -- 1426
	local i = 0 -- 1429
	do -- 1429
		i = 0 -- 1430
		while i < #offers do -- 1430
			do -- 1430
				local tid = offers[i + 1] -- 1431
				local baseBox = boxes[i + 1] -- 1432
				local cardStagger = easeOutCubic(clamp((self.staggerTime - i * 0.055) / 0.24, 0, 1)) -- 1433
				local alpha = cardStagger * appear -- 1434
				if alpha <= 0.01 then -- 1435
					goto __continue210 -- 1436
				end -- 1436
				local lift = (self.cardLiftT[i + 1] or 0) * 10 -- 1438
				local slideY = (1 - cardStagger) * -22 -- 1439
				local x = baseBox.x -- 1440
				local y = baseBox.y + slideY + lift -- 1441
				local w = baseBox.width -- 1442
				local h = baseBox.height -- 1443
				local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1444
				self:drawSingleTalentCard( -- 1446
					uiDraw, -- 1446
					uiInkDraw, -- 1446
					uiArt, -- 1446
					uiGlow, -- 1446
					ctx, -- 1446
					rg, -- 1446
					tid, -- 1446
					i, -- 1446
					x, -- 1446
					y, -- 1446
					w, -- 1446
					h, -- 1446
					isHot, -- 1446
					alpha, -- 1446
					mode -- 1446
				) -- 1446
			end -- 1446
			::__continue210:: -- 1446
			i = i + 1 -- 1430
		end -- 1430
	end -- 1430
end -- 1379
function RoguelikeUiPlugin.prototype.drawSingleTalentCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, tid, slotIdx, x, y, w, h, isHot, alpha, mode) -- 1450
	local meta = resolveTalentVisual(tid, rg) -- 1467
	local curRank = rg.ranks[tid] or 0 -- 1468
	local cx = x + w * 0.5 -- 1469
	local cy = y + h * 0.5 -- 1470
	local accent = isHot and PALETTE.rouge or meta.accent -- 1471
	uiArt:tryPlace( -- 1474
		"ink_frame_mask", -- 1474
		"rg_card_sh_" .. tostring(slotIdx), -- 1474
		cx, -- 1474
		cy - 4, -- 1474
		w + 26, -- 1474
		h + 24, -- 1474
		{ -- 1474
			color = toColor(PALETTE.voidDark), -- 1475
			opacity = 0.72 * alpha, -- 1475
			layer = -1 -- 1475
		} -- 1475
	) -- 1475
	if isHot then -- 1477
		local breathe = 0.86 + 0.14 * math.sin(self.animTime * 4) -- 1478
		fillRadialGlow( -- 1479
			uiGlow, -- 1479
			cx, -- 1479
			cy, -- 1479
			w * 0.74, -- 1479
			h * 0.64, -- 1479
			toColor(PALETTE.rouge, 34 * breathe * alpha), -- 1479
			Color(182, 58, 56, 0), -- 1479
			14 -- 1479
		) -- 1479
	end -- 1479
	local bgCol = isHot and Color( -- 1483
		28, -- 1483
		22, -- 1483
		27, -- 1483
		math.floor(244 * alpha + 0.5) -- 1483
	) or Color( -- 1483
		15, -- 1483
		18, -- 1483
		26, -- 1483
		math.floor(234 * alpha + 0.5) -- 1483
	) -- 1483
	local bdCol = toColor(isHot and PALETTE.rouge or meta.accent, (isHot and 235 or 155) * alpha) -- 1484
	uiDraw:drawRoundedRect( -- 1485
		Rect(x, y, w, h), -- 1485
		5, -- 1485
		bgCol, -- 1485
		isHot and 1.55 or 0.95, -- 1485
		bdCol -- 1485
	) -- 1485
	uiDraw:drawRect( -- 1487
		Rect(x + 5, y + 5, w - 10, h - 10), -- 1487
		Color(0, 0, 0, 0), -- 1487
		0.65, -- 1487
		toColor(isHot and PALETTE.amberCore or PALETTE.silkDim, (isHot and 115 or 68) * alpha) -- 1487
	) -- 1487
	drawFiligreeCorners( -- 1489
		uiInkDraw, -- 1489
		uiArt, -- 1489
		"rg_card_cn_" .. tostring(slotIdx), -- 1489
		x + 2, -- 1489
		y + 2, -- 1489
		w - 4, -- 1489
		h - 4, -- 1489
		accent, -- 1489
		(isHot and 0.94 or 0.62) * alpha, -- 1489
		22, -- 1489
		false, -- 1489
		3 -- 1489
	) -- 1489
	local topY = y + h - 22 -- 1492
	ctx.texts:put( -- 1493
		"xs", -- 1493
		meta.category, -- 1493
		x + 16, -- 1493
		topY, -- 1493
		toColor(meta.accentCore), -- 1493
		0, -- 1493
		0.5, -- 1493
		"Left", -- 1493
		1.2, -- 1493
		0.88 * alpha, -- 1493
		0.08 -- 1493
	) -- 1493
	local maxPips = math.max(curRank + 1, 3) -- 1496
	local pipStartX = x + w - 16 - (maxPips - 1) * 12 -- 1497
	local k = 0 -- 1498
	do -- 1498
		k = 0 -- 1499
		while k < maxPips do -- 1499
			local px = pipStartX + k * 12 -- 1500
			if k < curRank then -- 1501
				drawDiamond( -- 1502
					uiInkDraw, -- 1502
					px, -- 1502
					topY, -- 1502
					4, -- 1502
					4, -- 1502
					toColor(meta.accentCore, 230 * alpha) -- 1502
				) -- 1502
			elseif k == curRank then -- 1503
				drawDiamond( -- 1504
					uiInkDraw, -- 1504
					px, -- 1504
					topY, -- 1504
					4.4, -- 1504
					4.4, -- 1504
					toColor(isHot and PALETTE.rouge or PALETTE.amber, 220 * alpha), -- 1504
					1, -- 1504
					toColor(PALETTE.textBright, 220 * alpha) -- 1504
				) -- 1504
			else -- 1504
				drawDiamond( -- 1506
					uiInkDraw, -- 1506
					px, -- 1506
					topY, -- 1506
					3.2, -- 1506
					3.2, -- 1506
					Color(0, 0, 0, 0), -- 1506
					0.85, -- 1506
					toColor(PALETTE.silkDim, 130 * alpha) -- 1506
				) -- 1506
			end -- 1506
			k = k + 1 -- 1499
		end -- 1499
	end -- 1499
	drawHairline( -- 1510
		uiInkDraw, -- 1510
		uiArt, -- 1510
		"rg_card_hl_" .. tostring(slotIdx), -- 1510
		cx, -- 1510
		topY - 14, -- 1510
		w - 28, -- 1510
		accent, -- 1510
		0.45 * alpha, -- 1510
		false, -- 1510
		2 -- 1510
	) -- 1510
	local iconY = y + h - 76 -- 1513
	uiArt:tryPlace( -- 1514
		"ink_enso_fine", -- 1514
		"rg_card_enso_" .. tostring(slotIdx), -- 1514
		cx, -- 1514
		iconY, -- 1514
		62, -- 1514
		62, -- 1514
		{ -- 1514
			color = toColor(isHot and PALETTE.amberCore or meta.accent), -- 1515
			opacity = (isHot and 0.64 or 0.36) * alpha, -- 1515
			angle = self.animTime * (isHot and 16 or 6), -- 1515
			layer = 2 -- 1515
		} -- 1515
	) -- 1515
	fillRadialGlow( -- 1517
		uiGlow, -- 1517
		cx, -- 1517
		iconY, -- 1517
		34, -- 1517
		34, -- 1517
		toColor(meta.accent, (isHot and 42 or 20) * alpha), -- 1517
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1517
		12 -- 1517
	) -- 1517
	drawTalentGlyph( -- 1518
		uiInkDraw, -- 1518
		cx, -- 1518
		iconY, -- 1518
		22, -- 1518
		tid, -- 1518
		isHot and meta.accentCore or meta.accent, -- 1518
		alpha, -- 1518
		isHot and PALETTE.textBright or meta.accentCore -- 1518
	) -- 1518
	local titleY = y + 114 -- 1521
	ctx.texts:put( -- 1522
		"md", -- 1523
		meta.title, -- 1524
		cx, -- 1525
		titleY, -- 1526
		toColor(isHot and PALETTE.textBright or meta.accentCore), -- 1527
		0.5, -- 1528
		0.5, -- 1529
		"Center", -- 1530
		5, -- 1531
		0.98 * alpha, -- 1532
		0.1 -- 1533
	) -- 1533
	ctx.texts:put( -- 1537
		"xs", -- 1538
		meta:shortEffect(rg, curRank), -- 1539
		cx, -- 1540
		titleY - 26, -- 1541
		toColor(isHot and PALETTE.amberCore or PALETTE.textBright), -- 1542
		0.5, -- 1543
		0.5, -- 1544
		"Center", -- 1545
		0.6, -- 1546
		0.96 * alpha, -- 1547
		0.08 -- 1548
	) -- 1548
	ctx.texts:put( -- 1550
		"xs", -- 1551
		meta:subEffect(rg, curRank), -- 1552
		cx, -- 1553
		titleY - 46, -- 1554
		toColor(PALETTE.textMid), -- 1555
		0.5, -- 1556
		0.5, -- 1557
		"Center", -- 1558
		0.4, -- 1559
		0.86 * alpha, -- 1560
		0.08 -- 1561
	) -- 1561
	local whisperAlpha = (isHot and 0.9 or (mode == "touch" and 0.62 or 0.36)) * alpha -- 1565
	ctx.texts:put( -- 1566
		"xs", -- 1567
		meta.whisper, -- 1568
		cx, -- 1569
		y + 44, -- 1570
		toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1571
		0.5, -- 1572
		0.5, -- 1573
		"Center", -- 1574
		0.2, -- 1575
		whisperAlpha, -- 1576
		0.06 -- 1577
	) -- 1577
	local footY = y + 18 -- 1581
	if isHot then -- 1582
		drawSilkRibbon( -- 1583
			uiDraw, -- 1583
			uiArt, -- 1583
			"rg_card_rib_" .. tostring(slotIdx), -- 1583
			cx, -- 1583
			footY, -- 1583
			w - 18, -- 1583
			24, -- 1583
			PALETTE.rougeSoft, -- 1583
			0.56 * alpha, -- 1583
			1 -- 1583
		) -- 1583
	end -- 1583
	if mode == "kbm" then -- 1585
		drawSilkKeycap( -- 1586
			uiInkDraw, -- 1586
			ctx.texts, -- 1586
			cx - 42, -- 1586
			footY - 10, -- 1586
			22, -- 1586
			20, -- 1586
			"" .. tostring(slotIdx + 1), -- 1586
			accent, -- 1586
			alpha, -- 1586
			isHot -- 1586
		) -- 1586
		ctx.texts:put( -- 1587
			"xs", -- 1587
			isHot and "落印习得" or "习得", -- 1587
			cx - 12, -- 1587
			footY, -- 1587
			toColor(isHot and PALETTE.textBright or PALETTE.textMid), -- 1587
			0, -- 1587
			0.5, -- 1587
			"Left", -- 1587
			1, -- 1587
			0.94 * alpha, -- 1587
			0.08 -- 1587
		) -- 1587
	elseif mode == "gamepad" then -- 1588
		local label = isHot and "◆ L3 落印 ◆" or ("第" .. rankChinese(slotIdx + 1)) .. "筹" -- 1589
		ctx.texts:put( -- 1590
			"xs", -- 1590
			label, -- 1590
			cx, -- 1590
			footY, -- 1590
			toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1590
			0.5, -- 1590
			0.5, -- 1590
			"Center", -- 1590
			1, -- 1590
			0.94 * alpha, -- 1590
			0.08 -- 1590
		) -- 1590
	else -- 1590
		ctx.texts:put( -- 1592
			"xs", -- 1592
			"轻触落印", -- 1592
			cx, -- 1592
			footY, -- 1592
			toColor(PALETTE.amberCore), -- 1592
			0.5, -- 1592
			0.5, -- 1592
			"Center", -- 1592
			1.2, -- 1592
			0.95 * alpha, -- 1592
			0.08 -- 1592
		) -- 1592
	end -- 1592
end -- 1450
function RoguelikeUiPlugin.prototype.drawCompactTalentTallies(self, uiDraw, uiInkDraw, uiArt, ctx, rg, safe) -- 1598
	local offers = rg.offers -- 1606
	local touchMode = ctx.input:isTouchMode() -- 1607
	local mode = ctx.input.inputMode -- 1608
	local boxes = ____exports.computeRoguelikeCardRects( -- 1609
		ctx.uiW, -- 1609
		ctx.uiH, -- 1609
		#offers, -- 1609
		false, -- 1609
		touchMode, -- 1609
		safe.top -- 1609
	) -- 1609
	self.lastCardBoxes = boxes -- 1610
	local i = 0 -- 1612
	do -- 1612
		i = 0 -- 1613
		while i < #offers do -- 1613
			local tid = offers[i + 1] -- 1614
			local box = boxes[i + 1] -- 1615
			local meta = resolveTalentVisual(tid, rg) -- 1616
			local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1617
			local cy = box.y + box.height * 0.5 -- 1619
			local bdCol = isHot and PALETTE.rouge or meta.accent -- 1620
			uiDraw:drawRoundedRect( -- 1622
				box, -- 1623
				4, -- 1624
				toColor(isHot and PALETTE.inkWarm or PALETTE.panelBgDeep, isHot and 236 or 210), -- 1625
				isHot and 1.4 or 0.9, -- 1626
				toColor(bdCol, isHot and 235 or 178) -- 1627
			) -- 1627
			drawTalentGlyph( -- 1629
				uiInkDraw, -- 1629
				box.x + 20, -- 1629
				cy, -- 1629
				10.5, -- 1629
				tid, -- 1629
				meta.accent, -- 1629
				0.96, -- 1629
				meta.accentCore -- 1629
			) -- 1629
			if mode == "kbm" then -- 1630
				drawSilkKeycap( -- 1631
					uiInkDraw, -- 1631
					ctx.texts, -- 1631
					box.x + 36, -- 1631
					cy - 10, -- 1631
					20, -- 1631
					20, -- 1631
					"" .. tostring(i + 1), -- 1631
					bdCol, -- 1631
					0.95, -- 1631
					isHot -- 1631
				) -- 1631
				ctx.texts:put( -- 1632
					"xs", -- 1632
					meta.title, -- 1632
					box.x + 62, -- 1632
					cy + 7, -- 1632
					toColor(PALETTE.textBright), -- 1632
					0, -- 1632
					0.5, -- 1632
					"Left", -- 1632
					0.8, -- 1632
					0.96, -- 1632
					0.08 -- 1632
				) -- 1632
				ctx.texts:put( -- 1633
					"xs", -- 1633
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1633
					box.x + 62, -- 1633
					cy - 8, -- 1633
					toColor(meta.accentCore), -- 1633
					0, -- 1633
					0.5, -- 1633
					"Left", -- 1633
					0.2, -- 1633
					0.82, -- 1633
					0.06 -- 1633
				) -- 1633
			else -- 1633
				drawBlossomDot( -- 1635
					uiInkDraw, -- 1635
					uiArt, -- 1635
					"rg_cmp_dot_" .. tostring(i), -- 1635
					box.x + 38, -- 1635
					cy, -- 1635
					isHot and 11 or 7, -- 1635
					bdCol, -- 1635
					0.95, -- 1635
					4 -- 1635
				) -- 1635
				ctx.texts:put( -- 1636
					"xs", -- 1636
					(meta.title .. " · ") .. meta.category, -- 1636
					box.x + 50, -- 1636
					cy + 7, -- 1636
					toColor(PALETTE.textBright), -- 1636
					0, -- 1636
					0.5, -- 1636
					"Left", -- 1636
					0.6, -- 1636
					0.96, -- 1636
					0.08 -- 1636
				) -- 1636
				ctx.texts:put( -- 1637
					"xs", -- 1637
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1637
					box.x + 50, -- 1637
					cy - 8, -- 1637
					toColor(meta.accentCore), -- 1637
					0, -- 1637
					0.5, -- 1637
					"Left", -- 1637
					0.2, -- 1637
					0.82, -- 1637
					0.06 -- 1637
				) -- 1637
			end -- 1637
			i = i + 1 -- 1613
		end -- 1613
	end -- 1613
	local last = boxes[#boxes] -- 1642
	local togRect = Rect(last.x + last.width + 8, last.y + (last.height - 26) * 0.5, 50, 26) -- 1643
	self.expandToggleBox = togRect -- 1644
	uiDraw:drawRoundedRect( -- 1645
		togRect, -- 1645
		4, -- 1645
		toColor(PALETTE.inkWash, 190), -- 1645
		0.9, -- 1645
		toColor(PALETTE.amber, 175) -- 1645
	) -- 1645
	ctx.texts:put( -- 1646
		"xs", -- 1646
		"展开", -- 1646
		togRect.x + 25, -- 1646
		togRect.y + 13, -- 1646
		toColor(PALETTE.amberCore), -- 1646
		0.5, -- 1646
		0.5, -- 1646
		"Center", -- 1646
		0.6, -- 1646
		0.92, -- 1646
		0.08 -- 1646
	) -- 1646
end -- 1598
function RoguelikeUiPlugin.prototype.drawSealAndAbsorb(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, anim) -- 1651
	local meta = resolveTalentVisual(anim.talentId, rg) -- 1660
	local pb = anim.pickedBox -- 1661
	local pcx = pb.x + pb.width * 0.5 -- 1662
	local pcy = pb.y + pb.height * 0.5 -- 1663
	if anim.elapsed < anim.sealDuration then -- 1665
		local t = clamp(anim.elapsed / anim.sealDuration, 0, 1) -- 1666
		local i = 0 -- 1668
		do -- 1668
			i = 0 -- 1669
			while i < #anim.allBoxes do -- 1669
				do -- 1669
					if i == anim.pickedSlot then -- 1670
						goto __continue231 -- 1671
					end -- 1671
					local ob = anim.allBoxes[i + 1] -- 1673
					local dir = i < anim.pickedSlot and -1 or 1 -- 1674
					local drift = dir * easeOutCubic(t) * 26 -- 1675
					local oa = (1 - t) * 0.55 -- 1676
					uiDraw:drawRoundedRect( -- 1677
						Rect( -- 1677
							ob.x + drift, -- 1677
							ob.y - easeOutCubic(t) * 8, -- 1677
							ob.width, -- 1677
							ob.height -- 1677
						), -- 1677
						5, -- 1677
						Color( -- 1677
							15, -- 1677
							18, -- 1677
							26, -- 1677
							math.floor(180 * oa + 0.5) -- 1677
						), -- 1677
						0.8, -- 1677
						toColor(PALETTE.silkDim, 110 * oa) -- 1677
					) -- 1677
				end -- 1677
				::__continue231:: -- 1677
				i = i + 1 -- 1669
			end -- 1669
		end -- 1669
		local pop = 1 + (1 - easeOutCubic(t)) * 0.04 -- 1681
		local sw = pb.width * pop -- 1682
		local sh = pb.height * pop -- 1683
		local sx = pcx - sw * 0.5 -- 1684
		local sy = pcy - sh * 0.5 -- 1685
		fillRadialGlow( -- 1686
			uiGlow, -- 1686
			pcx, -- 1686
			pcy, -- 1686
			sw * 0.72, -- 1686
			sh * 0.62, -- 1686
			toColor(PALETTE.rouge, 56 * (1 - t * 0.4)), -- 1686
			Color(182, 58, 56, 0), -- 1686
			14 -- 1686
		) -- 1686
		uiDraw:drawRoundedRect( -- 1687
			Rect(sx, sy, sw, sh), -- 1687
			5, -- 1687
			Color(34, 22, 27, 245), -- 1687
			1.8, -- 1687
			toColor(PALETTE.rouge, 245) -- 1687
		) -- 1687
		drawTalentGlyph( -- 1688
			uiInkDraw, -- 1688
			pcx, -- 1688
			pcy + (anim.fromExpanded and 24 or 0), -- 1688
			anim.fromExpanded and 22 or 12, -- 1688
			anim.talentId, -- 1688
			meta.accentCore, -- 1688
			0.96, -- 1688
			PALETTE.textBright -- 1688
		) -- 1688
		ctx.texts:put( -- 1689
			"md", -- 1689
			meta.title, -- 1689
			pcx, -- 1689
			pcy - (anim.fromExpanded and 22 or 0), -- 1689
			toColor(PALETTE.textBright), -- 1689
			0.5, -- 1689
			0.5, -- 1689
			"Center", -- 1689
			4, -- 1689
			0.98, -- 1689
			0.1 -- 1689
		) -- 1689
		local slam = 1 + (1 - t) ^ 2 * 0.55 -- 1692
		drawLoneSeal( -- 1693
			uiInkDraw, -- 1694
			uiArt, -- 1695
			ctx.texts, -- 1696
			"rg_pick_seal", -- 1697
			pcx + (anim.fromExpanded and pb.width * 0.26 or pb.width * 0.34), -- 1698
			pcy - (anim.fromExpanded and pb.height * 0.22 or 0), -- 1699
			26 * slam, -- 1700
			50 * slam, -- 1701
			"契", -- 1702
			"印", -- 1703
			PALETTE.sealRedBright, -- 1704
			PALETTE.sealText, -- 1705
			0.96, -- 1706
			6 -- 1707
		) -- 1707
		return -- 1709
	end -- 1709
	local t = clamp( -- 1713
		(anim.elapsed - anim.sealDuration) / math.max(0.01, anim.absorbDuration), -- 1713
		0, -- 1713
		1 -- 1713
	) -- 1713
	local dest = self:computeAbsorbTargetUi(ctx, rg, anim.targetKind) -- 1714
	local ctrlX = (pcx + dest.x) * 0.5 -- 1715
	local ctrlY = math.max(pcy, dest.y) + 76 -- 1716
	local headT = easeInOutQuad(t) -- 1719
	local samples = 10 -- 1720
	local s = 0 -- 1721
	local prevPt -- 1722
	do -- 1722
		s = 0 -- 1723
		while s <= samples do -- 1723
			local u = math.max(0, headT - (samples - s) * 0.032) -- 1724
			local inv = 1 - u -- 1725
			local bx = inv * inv * pcx + 2 * inv * u * ctrlX + u * u * dest.x -- 1726
			local by = inv * inv * pcy + 2 * inv * u * ctrlY + u * u * dest.y -- 1727
			local pt = Vec2(bx, by) -- 1728
			if prevPt ~= nil then -- 1729
				local segA = s / samples * (1 - t * 0.35) -- 1730
				uiGlow:drawSegment( -- 1731
					prevPt, -- 1731
					pt, -- 1731
					1.6 + s / samples * 2.4, -- 1731
					toColor( -- 1731
						meta.accentCore, -- 1731
						math.floor(210 * segA + 0.5) -- 1731
					) -- 1731
				) -- 1731
			end -- 1731
			if s % 2 == 1 then -- 1733
				uiGlow:drawDot( -- 1734
					pt, -- 1734
					2 + s / samples * 2.2, -- 1734
					toColor( -- 1734
						PALETTE.amberCore, -- 1734
						math.floor(180 * (s / samples) * (1 - t * 0.3) + 0.5) -- 1734
					) -- 1734
				) -- 1734
			end -- 1734
			prevPt = pt -- 1736
			s = s + 1 -- 1723
		end -- 1723
	end -- 1723
	local invH = 1 - headT -- 1738
	local hx = invH * invH * pcx + 2 * invH * headT * ctrlX + headT * headT * dest.x -- 1739
	local hy = invH * invH * pcy + 2 * invH * headT * ctrlY + headT * headT * dest.y -- 1740
	fillRadialGlow( -- 1741
		uiGlow, -- 1741
		hx, -- 1741
		hy, -- 1741
		22, -- 1741
		22, -- 1741
		toColor(meta.accentCore, 96 * (1 - t * 0.3)), -- 1741
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1741
		12 -- 1741
	) -- 1741
	drawDiamond( -- 1742
		uiInkDraw, -- 1742
		hx, -- 1742
		hy, -- 1742
		5.5, -- 1742
		5.5, -- 1742
		toColor(PALETTE.textBright, 240) -- 1742
	) -- 1742
end -- 1651
function RoguelikeUiPlugin.prototype.computeAbsorbTargetUi(self, ctx, rg, target) -- 1745
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1746
	local bx = 28 + safe.left -- 1747
	local hpY = ctx.uiH - 56 - safe.top -- 1748
	if target == "hp" then -- 1749
		return { -- 1750
			x = bx + 44 + math.min(5, rg.maxHp) * 52, -- 1750
			y = hpY -- 1750
		} -- 1750
	end -- 1750
	if target == "gun" then -- 1752
		local p = ctx.p -- 1753
		return { -- 1754
			x = clamp( -- 1755
				ctx.cam:sx(p.player.x + p.player.facing * 14) / ctx.uiScale, -- 1755
				80, -- 1755
				ctx.uiW - 80 -- 1755
			), -- 1755
			y = clamp( -- 1756
				ctx.cam:sy(p.player.y + p.player.h * 0.62, p.player.depth) / ctx.uiScale, -- 1756
				80, -- 1756
				ctx.uiH - 80 -- 1756
			) -- 1756
		} -- 1756
	end -- 1756
	if target == "shoulder" then -- 1759
		local p = ctx.p -- 1760
		return { -- 1761
			x = clamp( -- 1762
				ctx.cam:sx(p.player.x) / ctx.uiScale, -- 1762
				80, -- 1762
				ctx.uiW - 80 -- 1762
			), -- 1762
			y = clamp( -- 1763
				ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) / ctx.uiScale, -- 1763
				80, -- 1763
				ctx.uiH - 80 -- 1763
			) -- 1763
		} -- 1763
	end -- 1763
	if target == "satchel" then -- 1766
		return {x = bx + 86, y = hpY - 68} -- 1767
	end -- 1767
	return {x = bx + 64, y = hpY - 36} -- 1769
end -- 1745
function RoguelikeUiPlugin.prototype.drawSegmentClearRibbon(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, safe) -- 1774
	local elapsed = SEGMENT_BANNER_DURATION - self.segmentBannerT -- 1782
	local fadeIn = clamp(elapsed / 0.24, 0, 1) -- 1783
	local fadeOut = clamp(self.segmentBannerT / 0.36, 0, 1) -- 1784
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1785
	if alpha <= 0.01 then -- 1786
		return -- 1787
	end -- 1787
	local cx = ctx.uiW * 0.5 -- 1789
	local cy = ctx.uiH - 134 - safe.top -- 1790
	drawSilkVeil( -- 1791
		uiDraw, -- 1791
		uiArt, -- 1791
		"rg_seg_veil", -- 1791
		cx, -- 1791
		cy, -- 1791
		460, -- 1791
		74, -- 1791
		PALETTE.inkWash, -- 1791
		0.78 * alpha, -- 1791
		2 -- 1791
	) -- 1791
	drawMistCurve( -- 1792
		uiArt, -- 1792
		"rg_seg_mist", -- 1792
		cx, -- 1792
		cy, -- 1792
		420, -- 1792
		66, -- 1792
		PALETTE.amber, -- 1792
		0.24 * alpha, -- 1792
		2 -- 1792
	) -- 1792
	drawHairline( -- 1793
		uiInkDraw, -- 1793
		uiArt, -- 1793
		"rg_seg_top", -- 1793
		cx, -- 1793
		cy + 32, -- 1793
		320, -- 1793
		PALETTE.amberCore, -- 1793
		0.58 * alpha, -- 1793
		true, -- 1793
		4 -- 1793
	) -- 1793
	drawHairline( -- 1794
		uiInkDraw, -- 1794
		uiArt, -- 1794
		"rg_seg_bot", -- 1794
		cx, -- 1794
		cy - 32, -- 1794
		280, -- 1794
		PALETTE.silkDim, -- 1794
		0.44 * alpha, -- 1794
		false, -- 1794
		4 -- 1794
	) -- 1794
	fillRadialGlow( -- 1795
		uiGlow, -- 1795
		cx, -- 1795
		cy + 6, -- 1795
		130, -- 1795
		34, -- 1795
		toColor(PALETTE.amber, 26 * alpha), -- 1795
		Color(214, 186, 146, 0), -- 1795
		12 -- 1795
	) -- 1795
	ctx.texts:put( -- 1797
		"banner", -- 1797
		self.segmentBannerHeadline, -- 1797
		cx, -- 1797
		cy + 9, -- 1797
		toColor(PALETTE.textBright), -- 1797
		0.5, -- 1797
		0.5, -- 1797
		"Center", -- 1797
		8, -- 1797
		0.96 * alpha, -- 1797
		0.12 -- 1797
	) -- 1797
	ctx.texts:put( -- 1798
		"xs", -- 1798
		self.segmentBannerSub, -- 1798
		cx, -- 1798
		cy - 18, -- 1798
		toColor(PALETTE.amberCore), -- 1798
		0.5, -- 1798
		0.5, -- 1798
		"Center", -- 1798
		1.6, -- 1798
		0.92 * alpha, -- 1798
		0.08 -- 1798
	) -- 1798
end -- 1774
function RoguelikeUiPlugin.prototype.drawDeathRecapOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, snap) -- 1803
	local elapsed = DEATH_RECAP_DURATION - self.deathRecapT -- 1811
	local fadeIn = clamp(elapsed / 0.26, 0, 1) -- 1812
	local fadeOut = clamp(self.deathRecapT / 0.44, 0, 1) -- 1813
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1814
	if alpha <= 0.01 then -- 1815
		return -- 1816
	end -- 1816
	local cx = ctx.uiW * 0.5 -- 1818
	local cy = ctx.uiH * 0.52 -- 1819
	uiDraw:drawRect( -- 1822
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1822
		Color( -- 1822
			8, -- 1822
			10, -- 1822
			16, -- 1822
			math.floor(168 * alpha + 0.5) -- 1822
		) -- 1822
	) -- 1822
	drawMistCurve( -- 1823
		uiArt, -- 1823
		"rg_recap_mist", -- 1823
		cx, -- 1823
		cy, -- 1823
		640, -- 1823
		140, -- 1823
		PALETTE.rougeSoft, -- 1823
		0.24 * alpha, -- 1823
		1 -- 1823
	) -- 1823
	fillRadialGlow( -- 1824
		uiGlow, -- 1824
		cx, -- 1824
		cy + 20, -- 1824
		220, -- 1824
		110, -- 1824
		toColor(PALETTE.rouge, 26 * alpha), -- 1824
		Color(182, 58, 56, 0), -- 1824
		14 -- 1824
	) -- 1824
	ctx.texts:put( -- 1827
		"banner", -- 1827
		"折筹重整", -- 1827
		cx, -- 1827
		cy + 88, -- 1827
		toColor(PALETTE.textBright), -- 1827
		0.5, -- 1827
		0.5, -- 1827
		"Center", -- 1827
		10, -- 1827
		0.96 * alpha, -- 1827
		0.12 -- 1827
	) -- 1827
	drawHairline( -- 1828
		uiInkDraw, -- 1828
		uiArt, -- 1828
		"rg_recap_line", -- 1828
		cx, -- 1828
		cy + 48, -- 1828
		360, -- 1828
		PALETTE.rouge, -- 1828
		0.62 * alpha, -- 1828
		true, -- 1828
		3 -- 1828
	) -- 1828
	local scatterT = clamp((elapsed - 0.22) / 1.15, 0, 1) -- 1831
	local ids = {} -- 1832
	for k in pairs(snap.ranks) do -- 1833
		if snap.ranks[k] > 0 then -- 1834
			ids[#ids + 1] = k -- 1835
		end -- 1835
	end -- 1835
	if #ids > 0 then -- 1838
		local step = 76 -- 1839
		local startX = cx - (#ids - 1) * step * 0.5 -- 1840
		local i = 0 -- 1841
		do -- 1841
			i = 0 -- 1842
			while i < #ids do -- 1842
				local tid = ids[i + 1] -- 1843
				local meta = resolveTalentVisual(tid) -- 1844
				local dir = #ids == 1 and 0 or i - (#ids - 1) * 0.5 -- 1845
				local dx = dir * easeOutCubic(scatterT) * 28 -- 1846
				local dy = easeOutCubic(scatterT) * 24 -- 1847
				local chipA = alpha * (1 - scatterT * 0.85) -- 1848
				local ix = startX + i * step + dx -- 1849
				local iy = cy + 6 + dy -- 1850
				uiDraw:drawRoundedRect( -- 1851
					Rect(ix - 24, iy - 18, 48, 36), -- 1851
					4, -- 1851
					toColor(PALETTE.inkWash, 180 * chipA), -- 1851
					0.9, -- 1851
					toColor(meta.accent, 150 * chipA) -- 1851
				) -- 1851
				drawTalentGlyph( -- 1852
					uiInkDraw, -- 1852
					ix, -- 1852
					iy, -- 1852
					12, -- 1852
					tid, -- 1852
					meta.accent, -- 1852
					chipA, -- 1852
					meta.accentCore -- 1852
				) -- 1852
				if scatterT > 0.08 then -- 1854
					uiGlow:drawDot( -- 1855
						Vec2(ix + dir * 10, iy + 14 + scatterT * 14), -- 1855
						2, -- 1855
						toColor(PALETTE.silkDim, 140 * chipA) -- 1855
					) -- 1855
					uiGlow:drawDot( -- 1856
						Vec2(ix - dir * 8, iy + 8 + scatterT * 20), -- 1856
						1.6, -- 1856
						toColor(PALETTE.rouge, 130 * chipA) -- 1856
					) -- 1856
				end -- 1856
				i = i + 1 -- 1842
			end -- 1842
		end -- 1842
	end -- 1842
	local countText = snap.totalRanks > 0 and ("曾习" .. toChineseUpper(snap.totalRanks)) .. "筹" or "尚未择筹" -- 1861
	local summary = ((((("止步于「" .. snap.stageName) .. "」 · ") .. countText) .. " · ") .. weaponMetaOf(snap.weaponId).name) .. " · 筹散人安，重整再护" -- 1862
	ctx.texts:put( -- 1863
		"sm", -- 1863
		summary, -- 1863
		cx, -- 1863
		cy - 48, -- 1863
		toColor(PALETTE.amberCore), -- 1863
		0.5, -- 1863
		0.5, -- 1863
		"Center", -- 1863
		1, -- 1863
		0.94 * alpha, -- 1863
		0.08 -- 1863
	) -- 1863
	ctx.texts:put( -- 1864
		"xs", -- 1864
		"新一轮护送将自城外巷路再启", -- 1864
		cx, -- 1864
		cy - 82, -- 1864
		toColor(PALETTE.textDim), -- 1864
		0.5, -- 1864
		0.5, -- 1864
		"Center", -- 1864
		1.2, -- 1864
		0.78 * alpha, -- 1864
		0.06 -- 1864
	) -- 1864
end -- 1803
function RoguelikeUiPlugin.prototype.drawBuildLedger(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1869
	local appear = easeOutCubic(self.ledgerAnimT) -- 1878
	local cx = ctx.uiW * 0.5 -- 1879
	local pageW = math.min(ctx.uiW - 96 - safe.left - safe.right, 880) -- 1880
	local pageH = math.min(ctx.uiH - 116 - safe.top - safe.bottom, 504) -- 1881
	local px = cx - pageW * 0.5 -- 1882
	local py = (ctx.uiH - pageH) * 0.5 + (1 - appear) * -14 -- 1883
	local midY = py + pageH * 0.5 -- 1884
	self.ledgerPanelBox = Rect(px, py, pageW, pageH) -- 1885
	uiDraw:drawRect( -- 1888
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1888
		Color( -- 1888
			7, -- 1888
			9, -- 1888
			15, -- 1888
			math.floor(188 * appear + 0.5) -- 1888
		) -- 1888
	) -- 1888
	uiArt:tryPlace( -- 1889
		"ink_frame_mask", -- 1889
		"rg_led_sh", -- 1889
		cx, -- 1889
		midY - 6, -- 1889
		pageW + 52, -- 1889
		pageH + 46, -- 1889
		{ -- 1889
			color = toColor(PALETTE.voidDark), -- 1890
			opacity = 0.84 * appear, -- 1890
			layer = -1 -- 1890
		} -- 1890
	) -- 1890
	if not uiArt:tryPlace( -- 1892
		"ink_song_paper", -- 1892
		"rg_led_paper", -- 1892
		cx, -- 1892
		midY, -- 1892
		pageW, -- 1892
		pageH, -- 1892
		{opacity = 0.98 * appear, layer = 1} -- 1892
	) then -- 1892
		uiDraw:drawRect( -- 1893
			Rect(px, py, pageW, pageH), -- 1893
			toColor(PALETTE.xuanPaper, 248 * appear), -- 1893
			1, -- 1893
			toColor(PALETTE.silkDim, 180 * appear) -- 1893
		) -- 1893
	end -- 1893
	fillRadialGlow( -- 1895
		uiGlow, -- 1895
		cx, -- 1895
		midY + 36, -- 1895
		260, -- 1895
		140, -- 1895
		Color( -- 1895
			236, -- 1895
			224, -- 1895
			202, -- 1895
			math.floor(16 * appear + 0.5) -- 1895
		), -- 1895
		Color(236, 224, 202, 0), -- 1895
		14 -- 1895
	) -- 1895
	local inX = px + 36 -- 1898
	local inY = py + 28 -- 1899
	local inW = pageW - 72 -- 1900
	local inH = pageH - 56 -- 1901
	local redSilk = toColor(PALETTE.rouge, 118 * appear) -- 1902
	local redFaint = toColor(PALETTE.rouge, 56 * appear) -- 1903
	uiInkDraw:drawRect( -- 1904
		Rect(inX, inY, inW, inH), -- 1904
		Color(0, 0, 0, 0), -- 1904
		0.95, -- 1904
		redSilk -- 1904
	) -- 1904
	uiInkDraw:drawRect( -- 1905
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1905
		Color(0, 0, 0, 0), -- 1905
		0.55, -- 1905
		redFaint -- 1905
	) -- 1905
	local headY = inY + inH - 26 -- 1908
	local routeZh = rg.routeTag == "drygoods" and " · 布行暗渡" or (rg.routeTag == "outer" and " · 外檐强行" or "") -- 1909
	ctx.texts:put( -- 1910
		"lg", -- 1910
		"行军札记", -- 1910
		inX + 18, -- 1910
		headY, -- 1910
		toColor(PALETTE.xuanInk), -- 1910
		0, -- 1910
		0.5, -- 1910
		"Left", -- 1910
		3, -- 1910
		0.96 * appear, -- 1910
		0 -- 1910
	) -- 1910
	local metaInfo = ((("筹号 " .. tostring(rg.seed)) .. "  ·  用时 ") .. mmss(rg.ticks)) .. routeZh -- 1911
	ctx.texts:put( -- 1912
		"xs", -- 1912
		metaInfo, -- 1912
		inX + 158, -- 1912
		headY - 2, -- 1912
		toColor(PALETTE.xuanInkSub), -- 1912
		0, -- 1912
		0.5, -- 1912
		"Left", -- 1912
		1, -- 1912
		0.88 * appear, -- 1912
		0 -- 1912
	) -- 1912
	local closeW = 76 -- 1915
	local closeH = 26 -- 1916
	local closeRect = Rect(inX + inW - closeW - 14, headY - closeH * 0.5, closeW, closeH) -- 1917
	self.ledgerCloseBox = closeRect -- 1918
	uiInkDraw:drawRect( -- 1919
		closeRect, -- 1919
		Color( -- 1919
			168, -- 1919
			46, -- 1919
			44, -- 1919
			math.floor(28 * appear + 0.5) -- 1919
		), -- 1919
		0.9, -- 1919
		toColor(PALETTE.rouge, 185 * appear) -- 1919
	) -- 1919
	ctx.texts:put( -- 1920
		"xs", -- 1920
		"合卷", -- 1920
		closeRect.x + closeW * 0.5, -- 1920
		headY, -- 1920
		toColor(PALETTE.rouge), -- 1920
		0.5, -- 1920
		0.5, -- 1920
		"Center", -- 1920
		1.4, -- 1920
		0.95 * appear, -- 1920
		0 -- 1920
	) -- 1920
	uiInkDraw:drawSegment( -- 1921
		Vec2(inX + 12, headY - 20), -- 1921
		Vec2(inX + inW - 12, headY - 20), -- 1921
		0.85, -- 1921
		redSilk -- 1921
	) -- 1921
	local foldX = inX + inW * 0.48 -- 1924
	uiInkDraw:drawSegment( -- 1925
		Vec2(foldX - 3, inY + 12), -- 1925
		Vec2(foldX - 3, headY - 26), -- 1925
		0.65, -- 1925
		redFaint -- 1925
	) -- 1925
	uiInkDraw:drawSegment( -- 1926
		Vec2(foldX + 3, inY + 12), -- 1926
		Vec2(foldX + 3, headY - 26), -- 1926
		0.65, -- 1926
		redFaint -- 1926
	) -- 1926
	local leftX = inX + 18 -- 1929
	local leftW = foldX - leftX - 18 -- 1930
	local secTopY = headY - 40 -- 1931
	ctx.texts:put( -- 1932
		"sm", -- 1932
		"此行舆图与兵备", -- 1932
		leftX, -- 1932
		secTopY, -- 1932
		toColor(PALETTE.rouge), -- 1932
		0, -- 1932
		0.5, -- 1932
		"Left", -- 1932
		1.6, -- 1932
		0.92 * appear, -- 1932
		0 -- 1932
	) -- 1932
	local stY = secTopY - 34 -- 1935
	local stages = rg.stages -- 1936
	if #stages > 0 then -- 1937
		local sx0 = leftX + 14 -- 1938
		local sx1 = leftX + leftW - 14 -- 1939
		local step = #stages > 1 and (sx1 - sx0) / (#stages - 1) or 0 -- 1940
		uiInkDraw:drawSegment( -- 1941
			Vec2(sx0, stY), -- 1941
			Vec2(sx1, stY), -- 1941
			0.9, -- 1941
			toColor(PALETTE.xuanInkSub, 130 * appear) -- 1941
		) -- 1941
		local si = 0 -- 1942
		do -- 1942
			si = 0 -- 1943
			while si < #stages do -- 1943
				local st = stages[si + 1] -- 1944
				local nx = sx0 + si * step -- 1945
				if st.current then -- 1946
					drawDiamond( -- 1947
						uiInkDraw, -- 1947
						nx, -- 1947
						stY, -- 1947
						5.5, -- 1947
						5.5, -- 1947
						toColor(PALETTE.rouge, 235 * appear) -- 1947
					) -- 1947
				elseif st.cleared then -- 1948
					drawDiamond( -- 1949
						uiInkDraw, -- 1949
						nx, -- 1949
						stY, -- 1949
						4.5, -- 1949
						4.5, -- 1949
						toColor(PALETTE.xuanInk, 210 * appear) -- 1949
					) -- 1949
				else -- 1949
					drawDiamond( -- 1951
						uiInkDraw, -- 1951
						nx, -- 1951
						stY, -- 1951
						4, -- 1951
						4, -- 1951
						Color(232, 227, 216, 255), -- 1951
						0.9, -- 1951
						toColor(PALETTE.xuanInkSub, 150 * appear) -- 1951
					) -- 1951
				end -- 1951
				ctx.texts:put( -- 1953
					"xs", -- 1953
					st.label, -- 1953
					nx, -- 1953
					stY - 18, -- 1953
					toColor(st.current and PALETTE.rouge or PALETTE.xuanInk), -- 1953
					0.5, -- 1953
					0.5, -- 1953
					"Center", -- 1953
					0.2, -- 1953
					(st.current and 0.98 or 0.78) * appear, -- 1953
					0 -- 1953
				) -- 1953
				si = si + 1 -- 1943
			end -- 1943
		end -- 1943
	end -- 1943
	local gunBoxY = stY - 142 -- 1958
	local gunBoxH = 104 -- 1959
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1960
	uiInkDraw:drawRect( -- 1961
		Rect(leftX, gunBoxY, leftW, gunBoxH), -- 1961
		Color( -- 1961
			32, -- 1961
			30, -- 1961
			32, -- 1961
			math.floor(14 * appear + 0.5) -- 1961
		), -- 1961
		0.85, -- 1961
		redFaint -- 1961
	) -- 1961
	ctx.texts:put( -- 1962
		"sm", -- 1962
		wMeta.name, -- 1962
		leftX + 12, -- 1962
		gunBoxY + gunBoxH - 20, -- 1962
		toColor(PALETTE.xuanInk), -- 1962
		0, -- 1962
		0.5, -- 1962
		"Left", -- 1962
		1.2, -- 1962
		0.96 * appear, -- 1962
		0 -- 1962
	) -- 1962
	ctx.texts:put( -- 1963
		"xs", -- 1963
		(((("装填 " .. tostring(rg.reloadTicksNow)) .. " 拍  ·  体力 ") .. tostring(rg.hp)) .. "/") .. tostring(rg.maxHp), -- 1963
		leftX + 12, -- 1963
		gunBoxY + gunBoxH - 44, -- 1963
		toColor(PALETTE.xuanInkSub), -- 1963
		0, -- 1963
		0.5, -- 1963
		"Left", -- 1963
		0.4, -- 1963
		0.88 * appear, -- 1963
		0 -- 1963
	) -- 1963
	ctx.texts:put( -- 1964
		"xs", -- 1964
		wMeta.desc, -- 1964
		leftX + 12, -- 1964
		gunBoxY + 26, -- 1964
		toColor(PALETTE.xuanInkSub), -- 1964
		0, -- 1964
		0.5, -- 1964
		"Left", -- 1964
		0.2, -- 1964
		0.82 * appear, -- 1964
		0 -- 1964
	) -- 1964
	local gridCx = leftX + leftW - 44 -- 1967
	local gridCy = gunBoxY + gunBoxH * 0.5 -- 1968
	local gStep = 22 -- 1969
	local gi = 0 -- 1970
	do -- 1970
		gi = 0 -- 1971
		while gi < #RELOAD_GRID do -- 1971
			local node = RELOAD_GRID[gi + 1] -- 1972
			local gx = gridCx + (node.col - 1) * gStep -- 1973
			local gy = gridCy + (node.row - 1) * gStep -- 1974
			local isEnhanced = wMeta.effect == "light" and node.kind == "lamp" or wMeta.effect == "echo" and node.kind == "bell" -- 1975
			if node.kind == "lamp" or node.kind == "bell" then -- 1977
				drawReloadPatternGlyph( -- 1978
					uiInkDraw, -- 1979
					gx, -- 1980
					gy, -- 1981
					isEnhanced and 8 or 6.2, -- 1982
					node.kind == "lamp" and "light" or "echo", -- 1983
					isEnhanced and PALETTE.rouge or PALETTE.xuanInkSub, -- 1984
					(isEnhanced and 0.96 or 0.55) * appear -- 1985
				) -- 1985
			else -- 1985
				uiInkDraw:drawDot( -- 1988
					Vec2(gx, gy), -- 1988
					(node.kind == "start" or node.kind == "target") and 3 or 2, -- 1988
					toColor(PALETTE.xuanInkSub, 150 * appear) -- 1988
				) -- 1988
			end -- 1988
			gi = gi + 1 -- 1971
		end -- 1971
	end -- 1971
	local invTitleY = gunBoxY - 22 -- 1993
	ctx.texts:put( -- 1994
		"xs", -- 1994
		"随身战备清点", -- 1994
		leftX, -- 1994
		invTitleY, -- 1994
		toColor(PALETTE.rouge), -- 1994
		0, -- 1994
		0.5, -- 1994
		"Left", -- 1994
		1.2, -- 1994
		0.88 * appear, -- 1994
		0 -- 1994
	) -- 1994
	local drawnInv = 0 -- 1995
	local ii = 0 -- 1996
	do -- 1996
		ii = 0 -- 1997
		while ii < #PICKUP_ORDER do -- 1997
			do -- 1997
				local k = PICKUP_ORDER[ii + 1] -- 1998
				local cnt = rg.supplies[k] or 0 -- 1999
				if cnt <= 0 then -- 2000
					goto __continue266 -- 2001
				end -- 2001
				local col = drawnInv % 2 -- 2003
				local row = math.floor(drawnInv / 2) -- 2004
				if row >= 3 then -- 2005
					break -- 2006
				end -- 2006
				local ix = leftX + col * (leftW * 0.5) -- 2008
				local iy = invTitleY - 26 - row * 28 -- 2009
				local pm = pickupMetaOf(k) -- 2010
				drawPickupGlyph( -- 2011
					uiInkDraw, -- 2011
					ix + 10, -- 2011
					iy, -- 2011
					7.2, -- 2011
					k, -- 2011
					0.92 * appear, -- 2011
					PALETTE.xuanInk -- 2011
				) -- 2011
				ctx.texts:put( -- 2012
					"xs", -- 2012
					(pm.name .. " ×") .. tostring(cnt), -- 2012
					ix + 24, -- 2012
					iy, -- 2012
					toColor(PALETTE.xuanInk), -- 2012
					0, -- 2012
					0.5, -- 2012
					"Left", -- 2012
					0.4, -- 2012
					0.9 * appear, -- 2012
					0 -- 2012
				) -- 2012
				drawnInv = drawnInv + 1 -- 2013
			end -- 2013
			::__continue266:: -- 2013
			ii = ii + 1 -- 1997
		end -- 1997
	end -- 1997
	if drawnInv == 0 then -- 2015
		ctx.texts:put( -- 2016
			"xs", -- 2016
			"行囊尚空，沿途可拾筹材与战备。", -- 2016
			leftX, -- 2016
			invTitleY - 28, -- 2016
			toColor(PALETTE.xuanInkSub), -- 2016
			0, -- 2016
			0.5, -- 2016
			"Left", -- 2016
			0.6, -- 2016
			0.78 * appear, -- 2016
			0 -- 2016
		) -- 2016
	end -- 2016
	local rightX = foldX + 20 -- 2020
	local rightW = inX + inW - rightX - 18 -- 2021
	ctx.texts:put( -- 2022
		"sm", -- 2022
		"已习本领谱", -- 2022
		rightX, -- 2022
		secTopY, -- 2022
		toColor(PALETTE.rouge), -- 2022
		0, -- 2022
		0.5, -- 2022
		"Left", -- 2022
		1.6, -- 2022
		0.92 * appear, -- 2022
		0 -- 2022
	) -- 2022
	local learned = {} -- 2024
	for k in pairs(rg.ranks) do -- 2025
		if (rg.ranks[k] or 0) > 0 then -- 2026
			learned[#learned + 1] = k -- 2027
		end -- 2027
	end -- 2027
	if #learned == 0 then -- 2030
		ctx.texts:put( -- 2031
			"sm", -- 2031
			"尚未择筹 · 途中整备可习军筹", -- 2031
			rightX, -- 2031
			secTopY - 56, -- 2031
			toColor(PALETTE.xuanInkSub), -- 2031
			0, -- 2031
			0.5, -- 2031
			"Left", -- 2031
			0.8, -- 2031
			0.82 * appear, -- 2031
			0 -- 2031
		) -- 2031
	else -- 2031
		local maxRows = math.min(8, #learned) -- 2033
		local dense = maxRows > 5 -- 2034
		local rowStep = dense and 36 or 56 -- 2035
		local rowH = dense and 32 or 46 -- 2036
		local startOff = dense and 36 or 46 -- 2037
		local li = 0 -- 2038
		do -- 2038
			li = 0 -- 2039
			while li < maxRows do -- 2039
				local tid = learned[li + 1] -- 2040
				local rank = rg.ranks[tid] or 1 -- 2041
				local meta = resolveTalentVisual(tid, rg) -- 2042
				local rowY = secTopY - startOff - li * rowStep -- 2043
				uiInkDraw:drawRect( -- 2044
					Rect(rightX, rowY - rowH * 0.5, rightW, rowH), -- 2044
					Color( -- 2044
						32, -- 2044
						30, -- 2044
						32, -- 2044
						math.floor(12 * appear + 0.5) -- 2044
					), -- 2044
					0.75, -- 2044
					redFaint -- 2044
				) -- 2044
				drawTalentGlyph( -- 2045
					uiInkDraw, -- 2045
					rightX + 22, -- 2045
					rowY + 1, -- 2045
					dense and 10 or 13, -- 2045
					tid, -- 2045
					PALETTE.xuanInk, -- 2045
					0.92 * appear, -- 2045
					PALETTE.rouge -- 2045
				) -- 2045
				ctx.texts:put( -- 2046
					dense and "xs" or "sm", -- 2046
					((meta.title .. " · ") .. rankChinese(rank)) .. "阶", -- 2046
					rightX + 44, -- 2046
					rowY + (dense and 7 or 10), -- 2046
					toColor(PALETTE.xuanInk), -- 2046
					0, -- 2046
					0.5, -- 2046
					"Left", -- 2046
					dense and 0.6 or 1, -- 2046
					0.96 * appear, -- 2046
					0 -- 2046
				) -- 2046
				ctx.texts:put( -- 2047
					"xs", -- 2047
					meta:ledgerLine(rg, rank), -- 2047
					rightX + 44, -- 2047
					rowY - (dense and 7 or 10), -- 2047
					toColor(PALETTE.xuanInkSub), -- 2047
					0, -- 2047
					0.5, -- 2047
					"Left", -- 2047
					0.3, -- 2047
					0.88 * appear, -- 2047
					0 -- 2047
				) -- 2047
				li = li + 1 -- 2039
			end -- 2039
		end -- 2039
	end -- 2039
	local march = deriveMarchTitle(rg) -- 2052
	local footY = inY + 46 -- 2053
	uiInkDraw:drawSegment( -- 2054
		Vec2(rightX, footY + 36), -- 2054
		Vec2(rightX + rightW, footY + 36), -- 2054
		0.7, -- 2054
		redFaint -- 2054
	) -- 2054
	ctx.texts:put( -- 2055
		"xs", -- 2055
		"此行雅号", -- 2055
		rightX, -- 2055
		footY + 20, -- 2055
		toColor(PALETTE.xuanInkSub), -- 2055
		0, -- 2055
		0.5, -- 2055
		"Left", -- 2055
		1.4, -- 2055
		0.82 * appear, -- 2055
		0 -- 2055
	) -- 2055
	ctx.texts:put( -- 2056
		"md", -- 2056
		("「" .. march.title) .. "」", -- 2056
		rightX - 4, -- 2056
		footY - 2, -- 2056
		toColor(PALETTE.xuanInk), -- 2056
		0, -- 2056
		0.5, -- 2056
		"Left", -- 2056
		2.2, -- 2056
		0.96 * appear, -- 2056
		0 -- 2056
	) -- 2056
	ctx.texts:put( -- 2057
		"xs", -- 2057
		march.subtitle, -- 2057
		rightX + 4, -- 2057
		footY - 24, -- 2057
		toColor(PALETTE.xuanInkSub), -- 2057
		0, -- 2057
		0.5, -- 2057
		"Left", -- 2057
		0.8, -- 2057
		0.86 * appear, -- 2057
		0 -- 2057
	) -- 2057
	drawLoneSeal( -- 2058
		uiInkDraw, -- 2059
		uiArt, -- 2060
		ctx.texts, -- 2061
		"rg_ledger_seal", -- 2062
		rightX + rightW - 22, -- 2063
		footY + 2, -- 2064
		24, -- 2065
		46, -- 2066
		march.sealTop, -- 2067
		march.sealBot, -- 2068
		PALETTE.sealRed, -- 2069
		PALETTE.sealText, -- 2070
		0.94 * appear, -- 2071
		5 -- 2072
	) -- 2072
end -- 1869
return ____exports -- 1869
