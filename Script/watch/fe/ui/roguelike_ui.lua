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
local ____target = require("Script.watch.target") -- 31
local getActiveTarget = ____target.getActiveTarget -- 31
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
	if touchMode == nil then -- 145
		touchMode = false -- 150
	end -- 150
	if safeTop == nil then -- 150
		safeTop = 0 -- 151
	end -- 151
	local out = {} -- 153
	if count <= 0 then -- 153
		return out -- 155
	end -- 155
	if expanded then -- 155
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
	if roomKey == "escort1" or roomKey == "s1-crossroad" then -- 185
		return "壹" -- 186
	end -- 186
	if roomKey == "escort2" or roomKey == "s2-drygoods" then -- 186
		return "贰" -- 187
	end -- 187
	if roomKey == "escort3" or roomKey == "s3-archway" then -- 187
		return "叁" -- 188
	end -- 188
	if roomKey == "escort4" or roomKey == "c1-yard" then -- 188
		return "肆" -- 189
	end -- 189
	if roomKey == "escort5" or roomKey == "c2-granary" then -- 189
		return "伍" -- 190
	end -- 190
	return "壹" -- 191
end -- 185
local function stageReadableName(roomKey) -- 194
	if roomKey == "escort1" then -- 194
		return "城外巷路 · 第一段" -- 195
	end -- 195
	if roomKey == "escort2" then -- 195
		return "粮棚取材 · 第二段" -- 196
	end -- 196
	if roomKey == "escort3" then -- 196
		return "山腰工台 · 第三段" -- 197
	end -- 197
	if roomKey == "escort4" then -- 197
		return "夜山窄道 · 第四段" -- 198
	end -- 198
	if roomKey == "escort5" then -- 198
		return "塔前山道 · 第五段" -- 199
	end -- 199
	return themeOf(roomKey).titleZh -- 200
end -- 194
function ____exports.computeEscortDeathButtons(uiW, uiH) -- 203
	local cx = uiW * 0.5 -- 207
	local panelH = math.min( -- 208
		390, -- 208
		math.max(320, uiH - 170) -- 208
	) -- 208
	local py = (uiH - panelH) * 0.5 -- 209
	local btnW = 216 -- 210
	local btnH = 44 -- 211
	local btnY = py + 34 -- 212
	local gap = 28 -- 213
	return { -- 214
		retry = Rect(cx - btnW - gap * 0.5, btnY, btnW, btnH), -- 215
		title = Rect(cx + gap * 0.5, btnY, btnW, btnH) -- 216
	} -- 216
end -- 203
____exports.RoguelikeUiPlugin = __TS__Class() -- 220
local RoguelikeUiPlugin = ____exports.RoguelikeUiPlugin -- 220
RoguelikeUiPlugin.name = "RoguelikeUiPlugin" -- 220
function RoguelikeUiPlugin.prototype.____constructor(self, contract, getHudSelected, setHudSelected) -- 282
	self.id = "fe-roguelike-ui" -- 221
	self.drawerState = "hidden" -- 228
	self.manualCompact = false -- 229
	self.expandAnimT = 0 -- 230
	self.staggerTime = 0 -- 231
	self.idleSinceMove = 0 -- 232
	self.hoverSlot = -1 -- 233
	self.focusedSlot = 0 -- 234
	self.cardLiftT = {0, 0, 0} -- 235
	self.focusScale = 1 -- 236
	self.animTime = 0 -- 237
	self.lastOffers = {} -- 240
	self.lastRanks = {} -- 241
	self.lastCardBoxes = {} -- 242
	self.lastUiW = 1280 -- 243
	self.lastUiH = 720 -- 244
	self.lastTouchMode = false -- 245
	self.lastSafeTop = 0 -- 246
	self.expandToggleBox = Rect(0, 0, 0, 0) -- 247
	self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 248
	self.ledgerCloseBox = Rect(0, 0, 0, 0) -- 249
	self.ledgerPanelBox = Rect(0, 0, 0, 0) -- 250
	self.crestPulseMap = {} -- 254
	self.hpBarPulseT = 0 -- 255
	self.xiaomanRippleT = 0 -- 256
	self.ledgerOpen = false -- 259
	self.ledgerAnimT = 0 -- 260
	self.pickupBounceMap = {} -- 263
	self.pickupShakeMap = {} -- 264
	self.pickupPops = {} -- 265
	self.lastSuppliesShown = {} -- 266
	self.segmentBannerT = 0 -- 269
	self.segmentBannerHeadline = "" -- 270
	self.segmentBannerSub = "" -- 271
	self.deathSelected = 0 -- 272
	self.deathRecapT = 0 -- 273
	self.lastMarchTitle = "初启北行" -- 277
	self.lastGuardArcActive = false -- 278
	self.lastReloadArcActive = false -- 279
	self.lastCraftRingActive = false -- 280
	self.contract = contract -- 287
	self.getHudSelected = getHudSelected -- 288
	self.setHudSelected = setHudSelected -- 289
end -- 282
function RoguelikeUiPlugin.prototype.canPickTalent(self) -- 292
	return not self.ledgerOpen and self.deathRecapT <= 0.15 and (self.drawerState == "expanded" or self.drawerState == "compact") -- 293
end -- 292
function RoguelikeUiPlugin.prototype.isExpanded(self) -- 297
	return self.drawerState == "expanded" -- 298
end -- 297
function RoguelikeUiPlugin.prototype.isLedgerOpen(self) -- 301
	return self.ledgerOpen -- 302
end -- 301
function RoguelikeUiPlugin.prototype.isModalOverlayActive(self) -- 306
	return self.ledgerOpen or self.deathRecapT > 0.05 -- 307
end -- 306
function RoguelikeUiPlugin.prototype.isSuppressingRoomBanner(self) -- 311
	return self.ledgerOpen or self.deathRecapT > 0.05 or self.drawerState == "expanded" or self.drawerState == "sealing" or self.segmentBannerT > 0.05 -- 312
end -- 311
function RoguelikeUiPlugin.prototype.openLedger(self) -- 319
	self.ledgerOpen = true -- 320
	self.ledgerAnimT = 0 -- 321
end -- 319
function RoguelikeUiPlugin.prototype.closeLedger(self) -- 324
	self.ledgerOpen = false -- 325
end -- 324
function RoguelikeUiPlugin.prototype.toggleLedger(self) -- 328
	if self.ledgerOpen then -- 328
		self:closeLedger() -- 330
	else -- 330
		self:openLedger() -- 332
	end -- 332
end -- 328
function RoguelikeUiPlugin.prototype.setCompact(self, compact) -- 336
	self.manualCompact = compact -- 337
	if #self.lastOffers > 0 and self.sealAnim == nil then -- 337
		self.drawerState = compact and "compact" or "expanded" -- 339
		if not compact then -- 339
			self.expandAnimT = 0 -- 341
			self.staggerTime = 0 -- 342
		end -- 342
	end -- 342
end -- 336
function RoguelikeUiPlugin.prototype.triggerTestDeathRecap(self, roomKey, ranks, weapon) -- 348
	if weapon == nil then -- 348
		weapon = "standard_gun" -- 348
	end -- 348
	self:showDeathRecap(roomKey, ranks, weapon, 0) -- 349
end -- 348
function RoguelikeUiPlugin.prototype.showDeathRecap(self, roomKey, ranks, weapon, seed) -- 352
	local total = 0 -- 353
	local copy = {} -- 354
	for k in pairs(ranks) do -- 355
		if ranks[k] > 0 then -- 355
			copy[k] = ranks[k] -- 357
			total = total + ranks[k] -- 358
		end -- 358
	end -- 358
	self.deathRecapSnap = { -- 361
		roomKey = roomKey, -- 362
		stageName = stageReadableName(roomKey), -- 363
		ranks = copy, -- 364
		totalRanks = total, -- 365
		weaponId = weapon, -- 366
		seed = seed -- 367
	} -- 367
	self.deathRecapT = DEATH_RECAP_DURATION -- 369
end -- 352
function RoguelikeUiPlugin.prototype.triggerTestSegmentBanner(self, roomKey, nextKey) -- 373
	if nextKey == nil then -- 373
		nextKey = "" -- 373
	end -- 373
	self.segmentBannerHeadline = stageOrderNumeral(roomKey) .. "程告破" -- 374
	self.segmentBannerSub = nextKey ~= "" and "渐近北塔 · 前往" .. themeOf(nextKey).shortNameZh or "渐近北塔 · 筹策犹在" -- 375
	self.segmentBannerT = SEGMENT_BANNER_DURATION -- 376
end -- 373
function RoguelikeUiPlugin.prototype.getTalentCardRects(self, uiW, uiH, count, touchMode, safeTop) -- 380
	if touchMode == nil then -- 380
		touchMode = false -- 384
	end -- 384
	if safeTop == nil then -- 384
		safeTop = 0 -- 385
	end -- 385
	if not self:canPickTalent() then -- 385
		return {} -- 387
	end -- 387
	local useExpanded = self.drawerState ~= "compact" -- 388
	return ____exports.computeRoguelikeCardRects( -- 389
		uiW, -- 389
		uiH, -- 389
		count, -- 389
		useExpanded, -- 389
		touchMode, -- 389
		safeTop -- 389
	) -- 389
end -- 380
function RoguelikeUiPlugin.prototype.getLedgerButtonRect(self) -- 392
	return self.ledgerButtonBox -- 393
end -- 392
function RoguelikeUiPlugin.prototype.getExpandToggleRect(self) -- 396
	return self.expandToggleBox -- 397
end -- 396
function RoguelikeUiPlugin.prototype.getState(self) -- 400
	return { -- 401
		drawerState = self.drawerState, -- 402
		offers = __TS__ArraySlice(self.lastOffers), -- 403
		focusedSlot = self.focusedSlot, -- 404
		focusTimeScale = self.focusScale, -- 405
		ledgerOpen = self.ledgerOpen, -- 406
		sealingActive = self.drawerState == "sealing", -- 407
		absorbingActive = self.drawerState == "absorbing", -- 408
		segmentBannerActive = self.segmentBannerT > 0.01, -- 409
		deathRecapActive = self.deathRecapT > 0.01, -- 410
		deathRecapRoom = self.deathRecapSnap ~= nil and self.deathRecapSnap.roomKey or "", -- 411
		deathRecapCount = self.deathRecapSnap ~= nil and self.deathRecapSnap.totalRanks or 0, -- 412
		marchTitle = self.lastMarchTitle, -- 413
		suppliesShown = __TS__ArraySlice(self.lastSuppliesShown), -- 414
		activeGuardArc = self.lastGuardArcActive, -- 415
		activeReloadArc = self.lastReloadArcActive, -- 416
		activeCraftRing = self.lastCraftRingActive, -- 417
		lastCardBoxes = __TS__ArraySlice(self.lastCardBoxes), -- 418
		ledgerButtonBox = self.ledgerButtonBox, -- 419
		expandToggleBox = self.expandToggleBox -- 420
	} -- 420
end -- 400
function RoguelikeUiPlugin.prototype.onBindPlay(self, _p, view) -- 424
	self.deathRecapSnap = nil -- 425
	self.deathRecapT = 0 -- 426
	self.deathSelected = 0 -- 427
	local rg = view.roguelike -- 428
	self.manualCompact = false -- 429
	self.expandAnimT = 0 -- 430
	self.staggerTime = 0 -- 431
	self.idleSinceMove = 0 -- 432
	self.hoverSlot = -1 -- 433
	self.focusedSlot = 0 -- 434
	self.cardLiftT = {0, 0, 0} -- 435
	self.sealAnim = nil -- 436
	self.ledgerOpen = false -- 437
	self.ledgerAnimT = 0 -- 438
	self.pickupBounceMap = {} -- 439
	self.pickupShakeMap = {} -- 440
	self.pickupPops = {} -- 441
	self.crestPulseMap = {} -- 442
	self.hpBarPulseT = 0 -- 443
	self.xiaomanRippleT = 0 -- 444
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 445
	self.lastRanks = {} -- 446
	for k in pairs(rg.ranks) do -- 447
		self.lastRanks[k] = rg.ranks[k] -- 448
	end -- 448
	self.drawerState = #rg.offers > 0 and "expanded" or "hidden" -- 450
	self.focusScale = 1 -- 451
	if self.contract ~= nil then -- 451
		self.contract:setFocusTimeScale(1) -- 453
	end -- 453
	self:resetInputEdges() -- 455
end -- 424
function RoguelikeUiPlugin.prototype.resetInputEdges(self) -- 459
end -- 459
function RoguelikeUiPlugin.prototype.startSealAnimation(self, talentId, ctx) -- 463
	local pickedSlot = __TS__ArrayIndexOf(self.lastOffers, talentId) -- 464
	if pickedSlot < 0 then -- 464
		pickedSlot = clamp( -- 466
			self.focusedSlot, -- 466
			0, -- 466
			math.max(0, #self.lastOffers - 1) -- 466
		) -- 466
	end -- 466
	local boxes = #self.lastCardBoxes > 0 and __TS__ArraySlice(self.lastCardBoxes) or ____exports.computeRoguelikeCardRects( -- 468
		ctx.uiW, -- 471
		ctx.uiH, -- 472
		math.max(1, #self.lastOffers), -- 473
		self.drawerState ~= "compact", -- 474
		ctx.input:isTouchMode(), -- 475
		(ctx.safeUi or ZERO_SAFE_INSETS).top -- 476
	) -- 476
	local pickedBox = boxes[pickedSlot + 1] or Rect(ctx.uiW * 0.5 - 100, ctx.uiH * 0.5 - 60, 200, 120) -- 478
	local meta = resolveTalentVisual(talentId, ctx.view.roguelike) -- 479
	self.sealAnim = { -- 480
		talentId = talentId, -- 481
		pickedSlot = pickedSlot, -- 482
		pickedBox = pickedBox, -- 483
		allBoxes = boxes, -- 484
		allOffers = __TS__ArraySlice(self.lastOffers), -- 485
		elapsed = 0, -- 486
		sealDuration = SEAL_DURATION, -- 487
		absorbDuration = ABSORB_DURATION, -- 488
		targetKind = meta.absorbTarget, -- 489
		fromExpanded = self.drawerState ~= "compact", -- 490
		arrivedPulsed = false -- 491
	} -- 491
	self.drawerState = "sealing" -- 493
	self.hoverSlot = -1 -- 494
	ctx.input:vibrate(0.024) -- 495
	if ctx.view.backCarry.active then -- 495
		self.xiaomanRippleT = 0.78 -- 497
	end -- 497
end -- 463
function RoguelikeUiPlugin.prototype.detectPickedTalentFromRankDiff(self, nowRanks) -- 501
	for k in pairs(nowRanks) do -- 502
		if (nowRanks[k] or 0) > (self.lastRanks[k] or 0) then -- 502
			return k -- 504
		end -- 504
	end -- 504
	return self.lastOffers[clamp( -- 507
		self.focusedSlot, -- 507
		0, -- 507
		math.max(0, #self.lastOffers - 1) -- 507
	) + 1] or "" -- 507
end -- 501
function RoguelikeUiPlugin.prototype.update(self, ctx) -- 510
	local rg = ctx.view.roguelike -- 511
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 512
	local touchMode = ctx.input:isTouchMode() -- 513
	self.lastUiW = ctx.uiW -- 514
	self.lastUiH = ctx.uiH -- 515
	self.lastTouchMode = touchMode -- 516
	self.lastSafeTop = safe.top -- 517
	self.lastMarchTitle = deriveMarchTitle(rg).title -- 518
	if ctx.paused then -- 518
		self:resetInputEdges() -- 522
		return -- 523
	end -- 523
	local udt = math.max(0, ctx.uiDt) -- 526
	self.animTime = self.animTime + udt -- 527
	if ctx.events.segmentDone and ctx.events.segmentKey ~= "" then -- 527
		self.segmentBannerHeadline = stageOrderNumeral(ctx.events.segmentKey) .. "程告破" -- 531
		self.segmentBannerSub = ctx.events.segmentNext ~= "" and "渐近北塔 · 前往" .. themeOf(ctx.events.segmentNext).shortNameZh or "渐近北塔 · 筹策犹在" -- 532
		self.segmentBannerT = SEGMENT_BANNER_DURATION -- 535
	end -- 535
	local summary = ctx.p.escortSummary -- 538
	if ctx.p.escortFailed and summary and self.deathRecapSnap == nil then -- 538
		self:showDeathRecap(summary.roomKey, summary.ranks, summary.equippedWeapon, summary.seed) -- 540
		self:closeLedger() -- 541
	end -- 541
	local fallen = ctx.events.fallenBuild -- 543
	if ctx.events.campaignFailedReset and fallen ~= nil then -- 543
		self:showDeathRecap(ctx.events.campaignFailedRoom, fallen.ranks, fallen.weaponId, fallen.seed) -- 545
		self:closeLedger() -- 546
	end -- 546
	if ctx.events.pickupTaken and ctx.events.pickupKind ~= "" then -- 546
		self.pickupBounceMap[ctx.events.pickupKind] = 0.52 -- 550
		local ____self_pickupPops_0 = self.pickupPops -- 550
		____self_pickupPops_0[#____self_pickupPops_0 + 1] = {kind = ctx.events.pickupKind, timer = 0.72, maxTimer = 0.72} -- 551
		if #self.pickupPops > 6 then -- 551
			table.remove(self.pickupPops, 1) -- 553
		end -- 553
	end -- 553
	if ctx.events.pickupRejected and ctx.events.pickupRejectedKind ~= "" then -- 553
		self.pickupShakeMap[ctx.events.pickupRejectedKind] = 0.42 -- 557
	end -- 557
	if self.segmentBannerT > 0 then -- 557
		self.segmentBannerT = math.max(0, self.segmentBannerT - udt) -- 562
	end -- 562
	if self.hpBarPulseT > 0 then -- 562
		self.hpBarPulseT = math.max(0, self.hpBarPulseT - udt) -- 565
	end -- 565
	if self.xiaomanRippleT > 0 then -- 565
		self.xiaomanRippleT = math.max(0, self.xiaomanRippleT - udt) -- 568
	end -- 568
	for k in pairs(self.crestPulseMap) do -- 570
		if self.crestPulseMap[k] > 0 then -- 570
			self.crestPulseMap[k] = math.max(0, self.crestPulseMap[k] - udt) -- 572
		end -- 572
	end -- 572
	for k in pairs(self.pickupBounceMap) do -- 575
		if self.pickupBounceMap[k] > 0 then -- 575
			self.pickupBounceMap[k] = math.max(0, self.pickupBounceMap[k] - udt) -- 577
		end -- 577
	end -- 577
	for k in pairs(self.pickupShakeMap) do -- 580
		if self.pickupShakeMap[k] > 0 then -- 580
			self.pickupShakeMap[k] = math.max(0, self.pickupShakeMap[k] - udt) -- 582
		end -- 582
	end -- 582
	local pi = 0 -- 585
	local pw = 0 -- 586
	do -- 586
		pi = 0 -- 587
		while pi < #self.pickupPops do -- 587
			local pop = self.pickupPops[pi + 1] -- 588
			pop.timer = pop.timer - udt -- 589
			if pop.timer > 0 then -- 589
				self.pickupPops[pw + 1] = pop -- 591
				pw = pw + 1 -- 592
			end -- 592
			pi = pi + 1 -- 587
		end -- 587
	end -- 587
	__TS__ArraySetLength(self.pickupPops, pw) -- 587
	if self.deathRecapT > 0 then -- 587
		local elapsedRecap = DEATH_RECAP_DURATION - self.deathRecapT -- 599
		local wantSkip = elapsedRecap > 0.25 and (math.abs(ctx.input.moveX) > 0.2 or ctx.input.uiPressed or ctx.input.fire.pressed or ctx.input.interact.pressed or ctx.input.navConfirm) -- 600
		self.deathRecapT = math.max(ctx.p.escortFailed and 0.5 or 0, self.deathRecapT - udt * (wantSkip and 4.2 or 1)) -- 607
	end -- 607
	local hadOffers = #self.lastOffers > 0 -- 611
	local hasOffers = #rg.offers > 0 -- 612
	if ctx.events.talentPicked and ctx.events.talentPickedId ~= "" then -- 612
		self:startSealAnimation(ctx.events.talentPickedId, ctx) -- 614
	elseif hadOffers and not hasOffers and self.sealAnim == nil then -- 614
		local diffId = self:detectPickedTalentFromRankDiff(rg.ranks) -- 616
		if diffId ~= "" then -- 616
			self:startSealAnimation(diffId, ctx) -- 618
		end -- 618
	elseif not hadOffers and hasOffers then -- 618
		self.sealAnim = nil -- 622
		self.drawerState = "expanded" -- 623
		self.manualCompact = false -- 624
		self.expandAnimT = 0 -- 625
		self.staggerTime = 0 -- 626
		self.idleSinceMove = 0 -- 627
		self.hoverSlot = -1 -- 628
		self.cardLiftT = {} -- 629
		local ci = 0 -- 630
		do -- 630
			ci = 0 -- 631
			while ci < #rg.offers do -- 631
				local ____self_cardLiftT_1 = self.cardLiftT -- 631
				____self_cardLiftT_1[#____self_cardLiftT_1 + 1] = 0 -- 632
				ci = ci + 1 -- 631
			end -- 631
		end -- 631
		ctx.audio:playUi("ui:talent_appear", "assets/audio/ui/talent_appear.wav", 0.68, 0.25) -- 634
	end -- 634
	if self.sealAnim ~= nil then -- 634
		local ____self_sealAnim_2, ____elapsed_3 = self.sealAnim, "elapsed" -- 634
		____self_sealAnim_2[____elapsed_3] = ____self_sealAnim_2[____elapsed_3] + udt -- 639
		local totalDur = self.sealAnim.sealDuration + self.sealAnim.absorbDuration -- 640
		if self.sealAnim.elapsed < self.sealAnim.sealDuration then -- 640
			self.drawerState = "sealing" -- 642
		elseif self.sealAnim.elapsed < totalDur then -- 642
			self.drawerState = "absorbing" -- 644
		else -- 644
			if not self.sealAnim.arrivedPulsed then -- 644
				self.sealAnim.arrivedPulsed = true -- 647
				self.crestPulseMap[self.sealAnim.talentId] = 0.72 -- 648
				if self.sealAnim.targetKind == "hp" then -- 648
					self.hpBarPulseT = 0.7 -- 650
				end -- 650
			end -- 650
			self.sealAnim = nil -- 653
			self.drawerState = hasOffers and (self.manualCompact and "compact" or "expanded") or "hidden" -- 654
		end -- 654
	elseif not hasOffers then -- 654
		self.drawerState = "hidden" -- 657
	end -- 657
	local modalBlocking = ctx.p.escortFailed or ctx.view.reloadSession.active or ctx.view.craftBench.active -- 661
	self:processLedgerAndCardInputs(ctx, rg, modalBlocking) -- 662
	if self.sealAnim == nil and hasOffers then -- 662
		local movingOrActing = math.abs(ctx.input.moveX) > 0.15 or math.abs(ctx.input.moveY) > 0.15 or ctx.input.jump.pressed or ctx.input.fire.pressed and self.hoverSlot < 0 or modalBlocking -- 665
		if self.drawerState == "expanded" then -- 665
			self.expandAnimT = math.min(1, self.expandAnimT + udt / 0.22) -- 671
			self.staggerTime = self.staggerTime + udt -- 672
			if movingOrActing then -- 672
				self.drawerState = "compact" -- 674
				self.idleSinceMove = 0 -- 675
			end -- 675
		elseif self.drawerState == "compact" then -- 675
			if movingOrActing or ctx.input.fire.held or self.ledgerOpen or self.deathRecapT > 0.05 then -- 675
				self.idleSinceMove = 0 -- 679
			elseif not self.manualCompact then -- 679
				self.idleSinceMove = self.idleSinceMove + udt -- 681
				if self.idleSinceMove >= AUTO_REEXPAND_IDLE_SEC then -- 681
					self.drawerState = "expanded" -- 683
					self.expandAnimT = 0 -- 684
					self.staggerTime = 0 -- 685
					self.idleSinceMove = 0 -- 686
				end -- 686
			end -- 686
		end -- 686
	end -- 686
	while #self.cardLiftT < #rg.offers do -- 686
		local ____self_cardLiftT_4 = self.cardLiftT -- 686
		____self_cardLiftT_4[#____self_cardLiftT_4 + 1] = 0 -- 694
	end -- 694
	local li = 0 -- 696
	do -- 696
		li = 0 -- 697
		while li < #rg.offers do -- 697
			local isHot = ctx.input.inputMode == "gamepad" and li == self.focusedSlot or ctx.input.inputMode ~= "gamepad" and li == self.hoverSlot -- 698
			local target = isHot and 1 or 0 -- 700
			local ____self_cardLiftT_5, ____temp_6 = self.cardLiftT, li + 1 -- 700
			____self_cardLiftT_5[____temp_6] = ____self_cardLiftT_5[____temp_6] + (target - self.cardLiftT[li + 1]) * math.min(1, udt * 14) -- 701
			li = li + 1 -- 697
		end -- 697
	end -- 697
	local wantSlowFocus = not modalBlocking and self.deathRecapT <= 0.05 and (self.ledgerOpen or self.drawerState == "expanded" and hasOffers) -- 705
	local targetScale = wantSlowFocus and EXPANDED_FOCUS_SCALE or 1 -- 708
	local speed = wantSlowFocus and 5.2 or 6 -- 709
	if self.focusScale < targetScale then -- 709
		self.focusScale = math.min(targetScale, self.focusScale + udt * speed) -- 711
	elseif self.focusScale > targetScale then -- 711
		self.focusScale = math.max(targetScale, self.focusScale - udt * speed) -- 713
	end -- 713
	if self.contract ~= nil then -- 713
		self.contract:setFocusTimeScale(self.focusScale) -- 716
	end -- 716
	if not ctx.view.reloadSession.active then -- 716
		ctx.audio:setWorldPlaySpeed(math.max( -- 719
			0.25, -- 719
			math.min(1, self.focusScale) -- 719
		)) -- 719
	end -- 719
	if self.ledgerOpen then -- 719
		self.ledgerAnimT = math.min(1, self.ledgerAnimT + udt / 0.2) -- 723
	end -- 723
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 727
	self.lastRanks = {} -- 728
	for k in pairs(rg.ranks) do -- 729
		self.lastRanks[k] = rg.ranks[k] -- 730
	end -- 730
	if hasOffers then -- 730
		self.lastCardBoxes = self:getTalentCardRects( -- 733
			ctx.uiW, -- 733
			ctx.uiH, -- 733
			#rg.offers, -- 733
			touchMode, -- 733
			safe.top -- 733
		) -- 733
	else -- 733
		self.lastCardBoxes = {} -- 735
	end -- 735
end -- 510
function RoguelikeUiPlugin.prototype.processLedgerAndCardInputs(self, ctx, rg, modalBlocking) -- 739
	local touchMode = ctx.input:isTouchMode() -- 744
	local useUiPtr = ctx.input.uiInside or ctx.input.uiPressed or ctx.input.uiHeld -- 745
	local ptrX = (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 746
	local ptrY = (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 747
	local ____useUiPtr_7 -- 748
	if useUiPtr then -- 748
		____useUiPtr_7 = ctx.input.uiInside -- 748
	else -- 748
		____useUiPtr_7 = ctx.input.inside -- 748
	end -- 748
	local inside = ____useUiPtr_7 -- 748
	local ptr = Vec2(ptrX, ptrY) -- 749
	local leftClick = ctx.input.uiPressed or not touchMode and ctx.input.inputMode == "kbm" and ctx.input.fire.pressed -- 751
	local vPressed = ctx.input.ledgerTogglePressed -- 752
	local escPressed = ctx.input.pause.pressed -- 753
	local backPressed = ctx.input.craftCancel or ctx.input.navBack or not touchMode and ctx.input.uiRightPressed -- 754
	if ctx.input.touchZoneTap == "ledger:toggle" and rg.active and not modalBlocking then -- 754
		ctx.input.touchZoneTap = "" -- 758
		self:toggleLedgerWithSound(ctx) -- 759
		return -- 760
	end -- 760
	if vPressed and rg.active and not modalBlocking then -- 760
		self:toggleLedgerWithSound(ctx) -- 765
		return -- 766
	end -- 766
	if self.ledgerOpen then -- 766
		if modalBlocking or escPressed or backPressed then -- 766
			self.ledgerOpen = false -- 771
			ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 772
			return -- 773
		end -- 773
		if leftClick and inside then -- 773
			if self.ledgerCloseBox:containsPoint(ptr) or not self.ledgerPanelBox:containsPoint(ptr) then -- 773
				self.ledgerOpen = false -- 777
				ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 778
			end -- 778
		end -- 778
		return -- 781
	end -- 781
	if rg.active and not modalBlocking and leftClick and inside and self.ledgerButtonBox.width > 0 and self.ledgerButtonBox:containsPoint(ptr) then -- 781
		self:toggleLedgerWithSound(ctx) -- 787
		return -- 788
	end -- 788
	if #rg.offers > 0 and not modalBlocking and leftClick and inside and self.expandToggleBox.width > 0 and self.expandToggleBox:containsPoint(ptr) then -- 788
		local nextCompact = self.drawerState == "expanded" -- 794
		self:setCompact(nextCompact) -- 795
		ctx.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 796
		return -- 797
	end -- 797
	if #rg.offers > 0 and not modalBlocking and self.sealAnim == nil then -- 797
		if ctx.input.inputMode == "gamepad" then -- 797
			local hudSel = self.getHudSelected ~= nil and self.getHudSelected() or self.focusedSlot -- 803
			local clamped = clamp(hudSel, 0, #rg.offers - 1) -- 804
			if clamped ~= self.focusedSlot then -- 804
				self.focusedSlot = clamped -- 806
				ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 807
			end -- 807
			self.hoverSlot = -1 -- 809
		elseif not touchMode and inside then -- 809
			local boxes = self:getTalentCardRects( -- 811
				ctx.uiW, -- 811
				ctx.uiH, -- 811
				#rg.offers, -- 811
				false, -- 811
				(ctx.safeUi or ZERO_SAFE_INSETS).top -- 811
			) -- 811
			local hit = -1 -- 812
			local i = 0 -- 813
			do -- 813
				i = 0 -- 814
				while i < #boxes do -- 814
					if boxes[i + 1]:containsPoint(ptr) then -- 814
						hit = i -- 816
						break -- 817
					end -- 817
					i = i + 1 -- 814
				end -- 814
			end -- 814
			if hit ~= self.hoverSlot then -- 814
				self.hoverSlot = hit -- 821
				if hit >= 0 then -- 821
					self.focusedSlot = hit -- 823
					if self.setHudSelected ~= nil then -- 823
						self.setHudSelected(hit) -- 825
					end -- 825
					ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045) -- 827
				end -- 827
			end -- 827
		else -- 827
			self.hoverSlot = -1 -- 831
		end -- 831
	else -- 831
		self.hoverSlot = -1 -- 834
	end -- 834
end -- 739
function RoguelikeUiPlugin.prototype.toggleLedgerWithSound(self, ctx) -- 838
	if self.ledgerOpen then -- 838
		self.ledgerOpen = false -- 840
		ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 841
	else -- 841
		self.ledgerOpen = true -- 843
		self.ledgerAnimT = 0 -- 844
		ctx.audio:playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08) -- 845
	end -- 845
end -- 838
function RoguelikeUiPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 851
	local p = ctx.p -- 857
	local rg = ctx.view.roguelike -- 858
	local cam = ctx.cam -- 859
	self.lastGuardArcActive = false -- 861
	self.lastReloadArcActive = false -- 862
	self.lastCraftRingActive = false -- 863
	if ctx.view.visualMode == "museum" then -- 863
		return -- 866
	end -- 866
	local bi = 0 -- 870
	do -- 870
		bi = 0 -- 871
		while bi < #p.boxes do -- 871
			do -- 871
				local b = p.boxes[bi + 1] -- 872
				if b.broken == true or b.hidden == true or b.id == nil then -- 872
					goto __continue145 -- 874
				end -- 874
				local ps = p.run.props[b.id] -- 876
				if ps == nil then -- 876
					goto __continue145 -- 878
				end -- 878
				local depth = b.depth ~= nil and (b.depth.min + b.depth.max) * 0.5 or 0 -- 880
				local x0 = cam:sx(b.x0) -- 881
				local x1 = cam:sx(b.x1) -- 882
				local y0 = cam:sy(b.y0, depth) -- 883
				local y1 = cam:sy(b.y1, depth) -- 884
				local bw = x1 - x0 -- 885
				local bh = y1 - y0 -- 886
				if bw <= 2 or bh <= 2 then -- 886
					goto __continue145 -- 888
				end -- 888
				if ps.wedge == true then -- 888
					local ww = math.max( -- 892
						6, -- 892
						cam:len(6.5) -- 892
					) -- 892
					local wh = math.max( -- 893
						7, -- 893
						cam:len(8) -- 893
					) -- 893
					fgDraw:drawPolygon( -- 894
						{ -- 894
							Vec2(x0 - ww * 0.7, y0), -- 895
							Vec2(x0 + ww * 0.45, y0), -- 896
							Vec2(x0 + ww * 0.2, y0 + wh), -- 897
							Vec2(x0 - ww * 0.25, y0 + wh * 0.55) -- 898
						}, -- 898
						toColor(PALETTE.emerald, 220), -- 899
						1.1, -- 899
						toColor(PALETTE.moonPale, 220) -- 899
					) -- 899
					fgDraw:drawPolygon( -- 900
						{ -- 900
							Vec2(x1 + ww * 0.7, y0), -- 901
							Vec2(x1 - ww * 0.45, y0), -- 902
							Vec2(x1 - ww * 0.2, y0 + wh), -- 903
							Vec2(x1 + ww * 0.25, y0 + wh * 0.55) -- 904
						}, -- 904
						toColor(PALETTE.emerald, 220), -- 905
						1.1, -- 905
						toColor(PALETTE.moonPale, 220) -- 905
					) -- 905
					fgDraw:drawSegment( -- 906
						Vec2(x0 + 2, y1 - 1), -- 906
						Vec2(x1 - 2, y1 - 1), -- 906
						1.6, -- 906
						toColor(PALETTE.emerald, 210) -- 906
					) -- 906
				end -- 906
				if ps.hp == 1 and not ps.broken then -- 906
					local mx = (x0 + x1) * 0.5 -- 910
					fgDraw:drawSegment( -- 911
						Vec2(mx - bw * 0.14, y1 - bh * 0.08), -- 911
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 911
						1.4, -- 911
						Color(14, 12, 16, 220) -- 911
					) -- 911
					fgDraw:drawSegment( -- 912
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 912
						Vec2(mx - bw * 0.08, y0 + bh * 0.14), -- 912
						1.3, -- 912
						Color(14, 12, 16, 220) -- 912
					) -- 912
					fgDraw:drawSegment( -- 913
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 913
						Vec2(mx + bw * 0.22, y0 + bh * 0.34), -- 913
						1, -- 913
						Color(214, 186, 146, 150) -- 913
					) -- 913
				end -- 913
			end -- 913
			::__continue145:: -- 913
			bi = bi + 1 -- 871
		end -- 871
	end -- 871
	if p.childMode or not p.player.alive then -- 871
		return -- 918
	end -- 918
	local pl = p.player -- 921
	local px = cam:sx(pl.x) -- 922
	local pyCenter = cam:sy(pl.y + pl.h * 0.56, pl.depth) -- 923
	local headY = cam:sy(pl.y + pl.h + 10, pl.depth) -- 924
	local facing = pl.facing >= 0 and 1 or -1 -- 925
	local guardRank = rg.ranks.guard or 0 -- 928
	if rg.activeInvulnTicks > 0 and guardRank > 0 then -- 928
		self.lastGuardArcActive = true -- 930
		local frac = clamp( -- 931
			rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 931
			0, -- 931
			1 -- 931
		) -- 931
		local arcR = math.max( -- 932
			18, -- 932
			cam:len(20) -- 932
		) -- 932
		local halfSpan = (0.35 + 0.85 * frac) * math.pi * 0.55 -- 933
		local baseAngle = facing > 0 and 0 or math.pi -- 934
		drawBrushArc( -- 935
			fgDraw, -- 936
			px + facing * cam:len(4), -- 937
			pyCenter, -- 938
			arcR, -- 939
			arcR * 1.18, -- 940
			baseAngle - halfSpan, -- 941
			baseAngle + halfSpan, -- 942
			2.4, -- 943
			toColor( -- 944
				PALETTE.emerald, -- 944
				math.floor(140 + 95 * frac + 0.5) -- 944
			), -- 944
			14 -- 945
		) -- 945
		drawBrushArc( -- 947
			fgGlow, -- 948
			px + facing * cam:len(4), -- 949
			pyCenter, -- 950
			arcR * 1.12, -- 951
			arcR * 1.28, -- 952
			baseAngle - halfSpan * 0.82, -- 953
			baseAngle + halfSpan * 0.82, -- 954
			1.3, -- 955
			toColor( -- 956
				PALETTE.moonPale, -- 956
				math.floor(90 * frac + 0.5) -- 956
			), -- 956
			12 -- 957
		) -- 957
	end -- 957
	if rg.activeReloadTicks > 0 and not ctx.view.reloadSession.active then -- 957
		self.lastReloadArcActive = true -- 963
		local totalRel = math.max(1, rg.reloadTicksNow) -- 964
		local prog = clamp(1 - rg.activeReloadTicks / totalRel, 0, 1) -- 965
		local rx = px + facing * cam:len(14) -- 966
		local ry = headY + cam:len(4) -- 967
		local rr = math.max( -- 968
			9, -- 968
			cam:len(10) -- 968
		) -- 968
		local hasReloadRank = (rg.ranks.focus or 0) > 0 -- 969
		local arcCol = hasReloadRank and PALETTE.amberCore or PALETTE.silkLine -- 970
		drawBrushArc( -- 971
			fgDraw, -- 971
			rx, -- 971
			ry, -- 971
			rr, -- 971
			rr, -- 971
			math.pi * 0.15, -- 971
			math.pi * 0.85, -- 971
			1.4, -- 971
			toColor(PALETTE.inkWash, 160), -- 971
			10 -- 971
		) -- 971
		local endA = math.pi * 0.85 - math.pi * 0.7 * prog -- 972
		drawBrushArc( -- 973
			fgDraw, -- 973
			rx, -- 973
			ry, -- 973
			rr, -- 973
			rr, -- 973
			endA, -- 973
			math.pi * 0.85, -- 973
			2.1, -- 973
			toColor(arcCol, 230), -- 973
			10 -- 973
		) -- 973
		if hasReloadRank then -- 973
			local sparkX = rx + math.cos(endA) * rr -- 975
			local sparkY = ry + math.sin(endA) * rr -- 976
			fgGlow:drawDot( -- 977
				Vec2(sparkX, sparkY), -- 977
				2.8, -- 977
				toColor(PALETTE.amberCore, 240) -- 977
			) -- 977
			fillRadialGlow( -- 978
				fgGlow, -- 978
				sparkX, -- 978
				sparkY, -- 978
				9, -- 978
				9, -- 978
				toColor(PALETTE.amber, 70), -- 978
				Color(214, 186, 146, 0), -- 978
				10 -- 978
			) -- 978
		end -- 978
	end -- 978
	if rg.activeCraftTicks > 0 then -- 978
		self.lastCraftRingActive = true -- 984
		local totalCraft = math.max(1, rg.craftTicksNow) -- 985
		local prog = clamp(rg.activeCraftTicks / totalCraft, 0, 1) -- 986
		local cx = px + facing * cam:len(12) -- 987
		local cy = headY + cam:len(8) -- 988
		local cr = math.max( -- 989
			11, -- 989
			cam:len(12) -- 989
		) -- 989
		drawBrushArc( -- 990
			fgDraw, -- 990
			cx, -- 990
			cy, -- 990
			cr, -- 990
			cr, -- 990
			0, -- 990
			TWO_PI, -- 990
			1.5, -- 990
			Color(14, 17, 25, 160), -- 990
			16 -- 990
		) -- 990
		drawBrushArc( -- 991
			fgDraw, -- 991
			cx, -- 991
			cy, -- 991
			cr, -- 991
			cr, -- 991
			math.pi * 0.5, -- 991
			math.pi * 0.5 - TWO_PI * prog, -- 991
			2.4, -- 991
			toColor(PALETTE.amberCore, 240), -- 991
			16 -- 991
		) -- 991
		local k = 0 -- 992
		do -- 992
			k = 0 -- 993
			while k < 4 do -- 993
				local ph = (self.animTime * 4.6 + k * 0.25) % 1 -- 994
				local ang = k * 1.57 + ph * 1.4 -- 995
				local sx = cx + math.cos(ang) * (cr + ph * 10) -- 996
				local sy = cy + math.sin(ang) * (cr + ph * 8) - ph * 6 -- 997
				fgDraw:drawSegment( -- 998
					Vec2(sx - 2, sy), -- 998
					Vec2(sx + 2, sy + 1.5), -- 998
					1.3, -- 998
					toColor( -- 998
						PALETTE.amber, -- 998
						math.floor(215 * (1 - ph) + 0.5) -- 998
					) -- 998
				) -- 998
				k = k + 1 -- 993
			end -- 993
		end -- 993
	end -- 993
	if self.xiaomanRippleT > 0.01 and ctx.view.backCarry.active then -- 993
		local p01 = 1 - self.xiaomanRippleT / 0.78 -- 1004
		local bx = px - facing * cam:len(8) -- 1005
		local by = cam:sy(pl.y + pl.h * 0.68, pl.depth) -- 1006
		local rr = cam:len(8) + easeOutCubic(p01) * cam:len(22) -- 1007
		local alpha = (1 - p01) * 0.85 -- 1008
		drawBrushArc( -- 1009
			fgGlow, -- 1009
			bx, -- 1009
			by, -- 1009
			rr, -- 1009
			rr, -- 1009
			0, -- 1009
			TWO_PI, -- 1009
			1.5, -- 1009
			toColor( -- 1009
				PALETTE.amberCore, -- 1009
				math.floor(180 * alpha + 0.5) -- 1009
			), -- 1009
			18 -- 1009
		) -- 1009
		fillRadialGlow( -- 1010
			fgGlow, -- 1010
			bx, -- 1010
			by, -- 1010
			rr * 0.8, -- 1010
			rr * 0.8, -- 1010
			toColor( -- 1010
				PALETTE.amber, -- 1010
				math.floor(48 * alpha + 0.5) -- 1010
			), -- 1010
			Color(214, 186, 146, 0), -- 1010
			12 -- 1010
		) -- 1010
	end -- 1010
end -- 851
function RoguelikeUiPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1016
	local rg = ctx.view.roguelike -- 1023
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1024
	local modalBlocking = ctx.p.escortFailed or ctx.view.reloadSession.active or ctx.view.craftBench.active -- 1025
	if rg.active and not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1025
		if rg.showRouteTrack and #rg.stages > 0 then -- 1025
			self:drawNorthwardTrack( -- 1030
				uiDraw, -- 1030
				uiInkDraw, -- 1030
				uiArt, -- 1030
				uiGlow, -- 1030
				ctx, -- 1030
				rg.stages, -- 1030
				safe -- 1030
			) -- 1030
		end -- 1030
		self:drawCrestAndSatchelHud( -- 1032
			uiDraw, -- 1032
			uiInkDraw, -- 1032
			uiArt, -- 1032
			uiGlow, -- 1032
			ctx, -- 1032
			rg, -- 1032
			safe -- 1032
		) -- 1032
	else -- 1032
		self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 1034
	end -- 1034
	if not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1034
		if self.sealAnim ~= nil then -- 1034
			self:drawSealAndAbsorb( -- 1040
				uiDraw, -- 1040
				uiInkDraw, -- 1040
				uiArt, -- 1040
				uiGlow, -- 1040
				ctx, -- 1040
				rg, -- 1040
				self.sealAnim -- 1040
			) -- 1040
		elseif #rg.offers > 0 then -- 1040
			if self.drawerState == "expanded" then -- 1040
				self:drawExpandedTalentCards( -- 1043
					uiDraw, -- 1043
					uiInkDraw, -- 1043
					uiArt, -- 1043
					uiGlow, -- 1043
					ctx, -- 1043
					rg, -- 1043
					safe -- 1043
				) -- 1043
			elseif self.drawerState == "compact" then -- 1043
				self:drawCompactTalentTallies( -- 1045
					uiDraw, -- 1045
					uiInkDraw, -- 1045
					uiArt, -- 1045
					ctx, -- 1045
					rg, -- 1045
					safe -- 1045
				) -- 1045
			end -- 1045
		else -- 1045
			self.expandToggleBox = Rect(0, 0, 0, 0) -- 1048
		end -- 1048
	else -- 1048
		self.expandToggleBox = Rect(0, 0, 0, 0) -- 1051
	end -- 1051
	if self.segmentBannerT > 0.01 then -- 1051
		self:drawSegmentClearRibbon( -- 1056
			uiDraw, -- 1056
			uiInkDraw, -- 1056
			uiArt, -- 1056
			uiGlow, -- 1056
			ctx, -- 1056
			safe -- 1056
		) -- 1056
	end -- 1056
	if self.deathRecapT > 0.01 and self.deathRecapSnap ~= nil then -- 1056
		self:drawDeathRecapOverlay( -- 1061
			uiDraw, -- 1061
			uiInkDraw, -- 1061
			uiArt, -- 1061
			uiGlow, -- 1061
			ctx, -- 1061
			self.deathRecapSnap -- 1061
		) -- 1061
	end -- 1061
	if self.ledgerOpen and rg.active and not modalBlocking then -- 1061
		self:drawBuildLedger( -- 1066
			uiDraw, -- 1066
			uiInkDraw, -- 1066
			uiArt, -- 1066
			uiGlow, -- 1066
			ctx, -- 1066
			rg, -- 1066
			safe -- 1066
		) -- 1066
		return true -- 1067
	end -- 1067
	return self.drawerState == "expanded" and self.hoverSlot >= 0 -- 1070
end -- 1016
function RoguelikeUiPlugin.prototype.drawNorthwardTrack(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, stages, safe) -- 1075
	local cx = ctx.uiW * 0.5 -- 1084
	local y = ctx.uiH - (ctx.view.isRehearsal and 50 or 24) - safe.top -- 1085
	local spanW = math.min(360, ctx.uiW * 0.34) -- 1086
	local x0 = cx - spanW * 0.5 -- 1087
	local step = #stages > 1 and spanW / (#stages - 1) or 0 -- 1088
	drawSilkVeil( -- 1090
		uiDraw, -- 1090
		uiArt, -- 1090
		"rg_track_veil", -- 1090
		cx, -- 1090
		y, -- 1090
		spanW + 108, -- 1090
		28, -- 1090
		PALETTE.inkWash, -- 1090
		0.56, -- 1090
		-1 -- 1090
	) -- 1090
	uiInkDraw:drawSegment( -- 1091
		Vec2(x0, y + 3), -- 1091
		Vec2(x0 + spanW, y + 3), -- 1091
		0.9, -- 1091
		toColor(PALETTE.silkDim, 130) -- 1091
	) -- 1091
	local curIdx = 0 -- 1094
	local i = 0 -- 1095
	do -- 1095
		i = 0 -- 1096
		while i < #stages do -- 1096
			if stages[i + 1].current then -- 1096
				curIdx = i -- 1098
				break -- 1099
			end -- 1099
			i = i + 1 -- 1096
		end -- 1096
	end -- 1096
	if curIdx > 0 then -- 1096
		uiInkDraw:drawSegment( -- 1103
			Vec2(x0, y + 3), -- 1103
			Vec2(x0 + step * curIdx, y + 3), -- 1103
			1.4, -- 1103
			toColor(PALETTE.moonPale, 195) -- 1103
		) -- 1103
	end -- 1103
	do -- 1103
		i = 0 -- 1106
		while i < #stages do -- 1106
			local st = stages[i + 1] -- 1107
			local nx = x0 + step * i -- 1108
			local ny = y + 3 -- 1109
			if st.current then -- 1109
				local breathe = 0.82 + 0.18 * math.sin(self.animTime * 4.2) -- 1111
				fillRadialGlow( -- 1112
					uiGlow, -- 1112
					nx, -- 1112
					ny, -- 1112
					14, -- 1112
					14, -- 1112
					toColor(PALETTE.rouge, 46 * breathe), -- 1112
					Color(182, 58, 56, 0), -- 1112
					10 -- 1112
				) -- 1112
				drawBlossomDot( -- 1113
					uiInkDraw, -- 1113
					uiArt, -- 1113
					"rg_st_cur_" .. tostring(i), -- 1113
					nx, -- 1113
					ny, -- 1113
					13, -- 1113
					PALETTE.rouge, -- 1113
					0.96, -- 1113
					4 -- 1113
				) -- 1113
			elseif st.cleared then -- 1113
				drawDiamond( -- 1115
					uiInkDraw, -- 1115
					nx, -- 1115
					ny, -- 1115
					4.2, -- 1115
					4.2, -- 1115
					toColor(PALETTE.moonPale, 225), -- 1115
					0.8, -- 1115
					toColor(PALETTE.cyan, 180) -- 1115
				) -- 1115
			elseif st.isBench or st.isFinal then -- 1115
				fillRadialGlow( -- 1117
					uiGlow, -- 1117
					nx, -- 1117
					ny, -- 1117
					10, -- 1117
					10, -- 1117
					toColor(PALETTE.amber, 26), -- 1117
					Color(214, 186, 146, 0), -- 1117
					8 -- 1117
				) -- 1117
				drawDiamond( -- 1118
					uiInkDraw, -- 1118
					nx, -- 1118
					ny, -- 1118
					4, -- 1118
					4, -- 1118
					Color(20, 22, 30, 210), -- 1118
					1.1, -- 1118
					toColor(PALETTE.amberCore, 215) -- 1118
				) -- 1118
			else -- 1118
				drawDiamond( -- 1120
					uiInkDraw, -- 1120
					nx, -- 1120
					ny, -- 1120
					3.3, -- 1120
					3.3, -- 1120
					Color(16, 19, 27, 210), -- 1120
					0.9, -- 1120
					toColor(PALETTE.silkDim, 155) -- 1120
				) -- 1120
			end -- 1120
			local labelCol = st.current and PALETTE.textBright or ((st.isBench or st.isFinal) and PALETTE.amberCore or (st.cleared and PALETTE.textMid or PALETTE.textDim)) -- 1122
			ctx.texts:put( -- 1125
				"xs", -- 1126
				st.label, -- 1127
				nx, -- 1128
				ny - 14, -- 1129
				toColor(labelCol), -- 1130
				0.5, -- 1131
				0.5, -- 1132
				"Center", -- 1133
				0.4, -- 1134
				st.current and 0.96 or 0.72, -- 1135
				0.08 -- 1136
			) -- 1136
			i = i + 1 -- 1106
		end -- 1106
	end -- 1106
end -- 1075
function RoguelikeUiPlugin.prototype.drawCrestAndSatchelHud(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1143
	local bx = 28 + safe.left -- 1152
	local hpBaseY = ctx.uiH - 72 - safe.top -- 1153
	local p = ctx.p -- 1154
	if self.hpBarPulseT > 0.01 then -- 1154
		local pA = clamp(self.hpBarPulseT / 0.7, 0, 1) -- 1158
		fillRadialGlow( -- 1159
			uiGlow, -- 1159
			bx + 130, -- 1159
			hpBaseY + 16, -- 1159
			140, -- 1159
			28, -- 1159
			toColor(PALETTE.moonPale, 44 * pA), -- 1159
			Color(232, 236, 234, 0), -- 1159
			12 -- 1159
		) -- 1159
	end -- 1159
	local ____p_isCampaign_13 = p.isCampaign -- 1163
	if ____p_isCampaign_13 then -- 1163
		local ____opt_8 = p.room.campaign -- 1163
		local ____temp_12 = (____opt_8 and ____opt_8.chapter) == "S" -- 1164
		if not ____temp_12 then -- 1164
			local ____opt_10 = p.room.campaign -- 1164
			____temp_12 = (____opt_10 and ____opt_10.chapter) == "C" -- 1164
		end -- 1164
		____p_isCampaign_13 = ____temp_12 -- 1163
	end -- 1163
	local fearVisible = ____p_isCampaign_13 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 1163
	local row1Y = hpBaseY - (fearVisible and 52 or 24) -- 1166
	local learnedIds = {} -- 1169
	local baseOrder = { -- 1170
		"vitality", -- 1170
		"guard", -- 1170
		"stride", -- 1170
		"focus", -- 1170
		"push_force", -- 1170
		"echo_wide", -- 1170
		"lantern_pierce", -- 1170
		"salvage" -- 1170
	} -- 1170
	local i = 0 -- 1171
	do -- 1171
		i = 0 -- 1172
		while i < #baseOrder do -- 1172
			if (rg.ranks[baseOrder[i + 1]] or 0) > 0 then -- 1172
				learnedIds[#learnedIds + 1] = baseOrder[i + 1] -- 1174
			end -- 1174
			i = i + 1 -- 1172
		end -- 1172
	end -- 1172
	for k in pairs(rg.ranks) do -- 1177
		if (rg.ranks[k] or 0) > 0 and __TS__ArrayIndexOf(learnedIds, k) < 0 then -- 1177
			learnedIds[#learnedIds + 1] = k -- 1179
		end -- 1179
	end -- 1179
	local cursorX = bx -- 1184
	local badgeH = 26 -- 1185
	local rowCenterY = row1Y + 6 -- 1186
	do -- 1186
		i = 0 -- 1187
		while i < #learnedIds do -- 1187
			local tid = learnedIds[i + 1] -- 1188
			local rank = rg.ranks[tid] or 1 -- 1189
			local meta = resolveTalentVisual(tid, rg) -- 1190
			local badgeW = 62 -- 1191
			local pulse = self.crestPulseMap[tid] or 0 -- 1192
			local activeNow = tid == "guard" and rg.activeInvulnTicks > 0 or tid == "focus" and rg.activeReloadTicks > 0 or tid == "salvage" and rg.activeCraftTicks > 0 -- 1193
			local glowBoost = math.max( -- 1196
				pulse, -- 1196
				activeNow and 0.55 + 0.35 * math.sin(self.animTime * 8) or 0 -- 1196
			) -- 1196
			if glowBoost > 0.02 then -- 1196
				fillRadialGlow( -- 1199
					uiGlow, -- 1199
					cursorX + badgeW * 0.5, -- 1199
					rowCenterY, -- 1199
					badgeW * 0.72, -- 1199
					20, -- 1199
					toColor(meta.accentCore, 46 * glowBoost), -- 1199
					Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1199
					10 -- 1199
				) -- 1199
			end -- 1199
			uiDraw:drawRoundedRect( -- 1201
				Rect(cursorX, rowCenterY - badgeH * 0.5, badgeW, badgeH), -- 1202
				4, -- 1203
				toColor(activeNow and PALETTE.inkWarm or PALETTE.inkWash, activeNow and 225 or 196), -- 1204
				(activeNow or pulse > 0.05) and 1.3 or 0.85, -- 1205
				toColor((activeNow or pulse > 0.05) and meta.accentCore or meta.accent, activeNow and 235 or 168) -- 1206
			) -- 1206
			drawTalentGlyph( -- 1208
				uiInkDraw, -- 1208
				cursorX + 15, -- 1208
				rowCenterY, -- 1208
				8.2, -- 1208
				tid, -- 1208
				meta.accent, -- 1208
				0.96, -- 1208
				meta.accentCore -- 1208
			) -- 1208
			ctx.texts:put( -- 1209
				"xs", -- 1210
				rankChinese(rank), -- 1211
				cursorX + 41, -- 1212
				rowCenterY, -- 1213
				toColor(meta.accentCore), -- 1214
				0.5, -- 1215
				0.5, -- 1216
				"Center", -- 1217
				0, -- 1218
				0.96, -- 1219
				0.08 -- 1220
			) -- 1220
			if tid == "guard" and rg.activeInvulnTicks > 0 then -- 1220
				local frac = clamp( -- 1224
					rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 1224
					0, -- 1224
					1 -- 1224
				) -- 1224
				uiInkDraw:drawSegment( -- 1225
					Vec2(cursorX + 4, rowCenterY - badgeH * 0.5 + 2), -- 1226
					Vec2(cursorX + 4 + (badgeW - 8) * frac, rowCenterY - badgeH * 0.5 + 2), -- 1227
					2, -- 1228
					toColor(PALETTE.emerald, 240) -- 1229
				) -- 1229
			end -- 1229
			cursorX = cursorX + (badgeW + 6) -- 1232
			i = i + 1 -- 1187
		end -- 1187
	end -- 1187
	local ledgerLabel = ctx.input.inputMode == "kbm" and "札记 V" or "札记" -- 1236
	local ledgerW = ctx.input.inputMode == "kbm" and 64 or 48 -- 1237
	local ledgerRect = Rect(cursorX, rowCenterY - badgeH * 0.5, ledgerW, badgeH) -- 1238
	self.ledgerButtonBox = ledgerRect -- 1239
	local ptrX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 1240
	local ptrY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 1241
	local ledgerHover = not ctx.input:isTouchMode() and (ctx.input.uiInside or ctx.input.inside) and ledgerRect:containsPoint(Vec2(ptrX, ptrY)) -- 1242
	uiDraw:drawRoundedRect( -- 1243
		ledgerRect, -- 1244
		4, -- 1245
		toColor(ledgerHover and PALETTE.rougeSoft or PALETTE.inkWash, ledgerHover and 205 or 176), -- 1246
		0.9, -- 1247
		toColor(ledgerHover and PALETTE.amberCore or PALETTE.silkDim, ledgerHover and 225 or 155) -- 1248
	) -- 1248
	ctx.texts:put( -- 1250
		"xs", -- 1251
		ledgerLabel, -- 1252
		ledgerRect.x + ledgerRect.width * 0.5, -- 1253
		rowCenterY, -- 1254
		toColor(ledgerHover and PALETTE.textBright or PALETTE.amberCore), -- 1255
		0.5, -- 1256
		0.5, -- 1257
		"Center", -- 1258
		0.6, -- 1259
		0.92, -- 1260
		0.08 -- 1261
	) -- 1261
	local touchLandscape = ctx.input:shouldShowTouchControls() and ctx.uiW > ctx.uiH -- 1267
	local row2Y = touchLandscape and rowCenterY - 30 or 28 + safe.bottom -- 1268
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1269
	local shownItems = {} -- 1270
	local shownKinds = {} -- 1271
	do -- 1271
		i = 0 -- 1272
		while i < #PICKUP_ORDER do -- 1272
			local k = PICKUP_ORDER[i + 1] -- 1273
			local cnt = rg.supplies[k] or 0 -- 1274
			if cnt > 0 then -- 1274
				shownItems[#shownItems + 1] = {kind = k, count = cnt} -- 1276
				shownKinds[#shownKinds + 1] = k -- 1277
			end -- 1277
			i = i + 1 -- 1272
		end -- 1272
	end -- 1272
	self.lastSuppliesShown = shownKinds -- 1280
	if touchLandscape and self.drawerState == "expanded" then -- 1280
		return -- 1282
	end -- 1282
	local woodCnt = rg.supplies.wood or 0 -- 1285
	local bellCnt = rg.supplies.bell or 0 -- 1286
	local craftReady = (rg.roomKey == "escort2" or rg.roomKey == "escort3") and (woodCnt >= 2 or woodCnt >= 1 and bellCnt >= 1) and rg.equippedWeapon == "standard_gun" -- 1287
	local sx = bx -- 1292
	local weaponW = 86 -- 1293
	local pillH = 24 -- 1294
	if not touchLandscape then -- 1294
		local stripW = weaponW + 6 + #shownItems * 59 + (craftReady and 68 or 0) + 28 -- 1296
		drawSilkVeil( -- 1297
			uiDraw, -- 1297
			uiArt, -- 1297
			"rg_satchel_veil", -- 1297
			bx + stripW * 0.45, -- 1297
			row2Y, -- 1297
			stripW + 32, -- 1297
			34, -- 1297
			PALETTE.inkWash, -- 1297
			0.56, -- 1297
			-1 -- 1297
		) -- 1297
	end -- 1297
	uiDraw:drawRoundedRect( -- 1299
		Rect(sx, row2Y - pillH * 0.5, weaponW, pillH), -- 1300
		4, -- 1301
		toColor(PALETTE.inkWash, 185), -- 1302
		0.85, -- 1303
		toColor(wMeta.accent, 160) -- 1304
	) -- 1304
	drawReloadPatternGlyph( -- 1306
		uiInkDraw, -- 1306
		sx + 14, -- 1306
		row2Y, -- 1306
		7.2, -- 1306
		wMeta.effect, -- 1306
		wMeta.accent, -- 1306
		0.94 -- 1306
	) -- 1306
	ctx.texts:put( -- 1307
		"xs", -- 1307
		wMeta.shortName, -- 1307
		sx + 26, -- 1307
		row2Y, -- 1307
		toColor(wMeta.accent), -- 1307
		0, -- 1307
		0.5, -- 1307
		"Left", -- 1307
		0.5, -- 1307
		0.94, -- 1307
		0.08 -- 1307
	) -- 1307
	sx = sx + (weaponW + 6) -- 1308
	do -- 1308
		i = 0 -- 1310
		while i < #shownItems do -- 1310
			local it = shownItems[i + 1] -- 1311
			local pm = pickupMetaOf(it.kind) -- 1312
			local bounce = self.pickupBounceMap[it.kind] or 0 -- 1313
			local shake = self.pickupShakeMap[it.kind] or 0 -- 1314
			local shakeX = shake > 0 and math.sin(self.animTime * 56) * 3.2 * (shake / 0.42) or 0 -- 1315
			local liftY = bounce > 0 and math.sin(bounce / 0.52 * math.pi) * 5 or 0 -- 1316
			local itemW = 54 -- 1317
			local rx = sx + shakeX -- 1318
			local ry = row2Y + liftY -- 1319
			local isHot = bounce > 0.02 or craftReady and (it.kind == "wood" or it.kind == "bell") -- 1320
			local bdCol = shake > 0.02 and PALETTE.rouge or (isHot and PALETTE.amberCore or pm.accent) -- 1321
			if isHot then -- 1321
				local ga = bounce > 0.02 and 48 * (bounce / 0.52) or 24 + 12 * math.sin(self.animTime * 4.5) -- 1324
				fillRadialGlow( -- 1325
					uiGlow, -- 1325
					rx + itemW * 0.5, -- 1325
					ry, -- 1325
					34, -- 1325
					16, -- 1325
					toColor(PALETTE.amberCore, ga), -- 1325
					Color(214, 186, 146, 0), -- 1325
					10 -- 1325
				) -- 1325
			end -- 1325
			uiDraw:drawRoundedRect( -- 1327
				Rect(rx, ry - pillH * 0.5, itemW, pillH), -- 1328
				4, -- 1329
				toColor(shake > 0.02 and PALETTE.inkWarm or PALETTE.inkWash, 192), -- 1330
				(isHot or shake > 0.02) and 1.2 or 0.8, -- 1331
				toColor(bdCol, (isHot or shake > 0.02) and 225 or 148) -- 1332
			) -- 1332
			drawPickupGlyph( -- 1334
				uiInkDraw, -- 1334
				rx + 14, -- 1334
				ry, -- 1334
				7.2, -- 1334
				it.kind, -- 1334
				0.96 -- 1334
			) -- 1334
			ctx.texts:put( -- 1335
				"xs", -- 1336
				"×" .. tostring(it.count), -- 1337
				rx + 37, -- 1338
				ry, -- 1339
				toColor(pm.accentCore), -- 1340
				0.5, -- 1341
				0.5, -- 1342
				"Center", -- 1343
				0, -- 1344
				0.96, -- 1345
				0.08 -- 1346
			) -- 1346
			local popIdx = 0 -- 1349
			do -- 1349
				popIdx = 0 -- 1350
				while popIdx < #self.pickupPops do -- 1350
					local pop = self.pickupPops[popIdx + 1] -- 1351
					if pop.kind == it.kind then -- 1351
						local prog = 1 - pop.timer / pop.maxTimer -- 1353
						ctx.texts:put( -- 1354
							"xs", -- 1355
							"+1", -- 1356
							rx + itemW * 0.5, -- 1357
							ry + 16 + prog * 14, -- 1358
							toColor(PALETTE.amberCore), -- 1359
							0.5, -- 1360
							0.5, -- 1361
							"Center", -- 1362
							0, -- 1363
							1 - prog, -- 1364
							0.08 -- 1365
						) -- 1365
						break -- 1367
					end -- 1367
					popIdx = popIdx + 1 -- 1350
				end -- 1350
			end -- 1350
			sx = sx + (itemW + 5) -- 1370
			i = i + 1 -- 1310
		end -- 1310
	end -- 1310
	if craftReady then -- 1310
		local breathe = 0.72 + 0.28 * math.sin(self.animTime * 4.2) -- 1374
		uiDraw:drawRoundedRect( -- 1375
			Rect(sx, row2Y - pillH * 0.5, 62, pillH), -- 1375
			4, -- 1375
			toColor(PALETTE.inkWarm, 185), -- 1375
			0.95, -- 1375
			toColor(PALETTE.amberCore, 210 * breathe) -- 1375
		) -- 1375
		ctx.texts:put( -- 1376
			"xs", -- 1376
			"足改制", -- 1376
			sx + 31, -- 1376
			row2Y, -- 1376
			toColor(PALETTE.amberCore), -- 1376
			0.5, -- 1376
			0.5, -- 1376
			"Center", -- 1376
			0.6, -- 1376
			0.94 * breathe, -- 1376
			0.08 -- 1376
		) -- 1376
	end -- 1376
end -- 1143
function RoguelikeUiPlugin.prototype.drawExpandedTalentCards(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1382
	local offers = rg.offers -- 1391
	local touchMode = ctx.input:isTouchMode() -- 1392
	local mode = ctx.input.inputMode -- 1393
	local boxes = ____exports.computeRoguelikeCardRects( -- 1394
		ctx.uiW, -- 1394
		ctx.uiH, -- 1394
		#offers, -- 1394
		true, -- 1394
		touchMode, -- 1394
		safe.top -- 1394
	) -- 1394
	self.lastCardBoxes = boxes -- 1395
	local appear = easeOutCubic(self.expandAnimT) -- 1396
	local slowFrac = clamp((1 - self.focusScale) / (1 - EXPANDED_FOCUS_SCALE), 0, 1) -- 1397
	fillVGradRect( -- 1400
		uiDraw, -- 1401
		0, -- 1402
		ctx.uiH * 0.36, -- 1403
		ctx.uiW, -- 1404
		ctx.uiH * 0.64, -- 1405
		Color(9, 12, 19, 0), -- 1406
		Color( -- 1407
			9, -- 1407
			12, -- 1407
			19, -- 1407
			math.floor((138 + 42 * slowFrac) * appear + 0.5) -- 1407
		) -- 1407
	) -- 1407
	local firstBox = boxes[1] -- 1411
	local headY = firstBox.y + firstBox.height + 28 -- 1412
	local cx = ctx.uiW * 0.5 -- 1413
	drawSilkVeil( -- 1414
		uiDraw, -- 1414
		uiArt, -- 1414
		"rg_exp_head_veil", -- 1414
		cx, -- 1414
		headY, -- 1414
		440, -- 1414
		30, -- 1414
		PALETTE.inkWash, -- 1414
		0.78 * appear, -- 1414
		-1 -- 1414
	) -- 1414
	drawHairline( -- 1415
		uiInkDraw, -- 1415
		uiArt, -- 1415
		"rg_exp_head_line", -- 1415
		cx, -- 1415
		headY + 15, -- 1415
		360, -- 1415
		PALETTE.amber, -- 1415
		0.54 * appear, -- 1415
		true, -- 1415
		2 -- 1415
	) -- 1415
	local headText = mode == "gamepad" and ("途中整备 · 择一军筹（LB/RB 择项 · " .. getActiveTarget():keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " / L3 落印）" or (touchMode and "途中整备 · 择一军筹 · 轻触卡面直接落印" or "途中整备 · 择一军筹 · 按 1 / 2 / 3 或点击落印") -- 1416
	ctx.texts:put( -- 1421
		"xs", -- 1421
		headText, -- 1421
		cx, -- 1421
		headY, -- 1421
		toColor(PALETTE.amberCore), -- 1421
		0.5, -- 1421
		0.5, -- 1421
		"Center", -- 1421
		1, -- 1421
		0.96 * appear, -- 1421
		0.08 -- 1421
	) -- 1421
	local lastBox = boxes[#boxes] -- 1424
	local togX = math.min(ctx.uiW - 86 - safe.right, lastBox.x + lastBox.width - 52) -- 1425
	local togRect = Rect(togX, headY - 12, 54, 24) -- 1426
	self.expandToggleBox = togRect -- 1427
	local expPtr = Vec2((ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale, (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale) -- 1428
	local expTogHot = not touchMode and (ctx.input.uiInside or ctx.input.inside) and togRect:containsPoint(expPtr) -- 1429
	uiDraw:drawRoundedRect( -- 1430
		togRect, -- 1430
		4, -- 1430
		toColor(expTogHot and PALETTE.inkWarm or PALETTE.inkWash, (expTogHot and 225 or 185) * appear), -- 1430
		expTogHot and 1.15 or 0.85, -- 1430
		toColor(expTogHot and PALETTE.amberCore or PALETTE.silkDim, (expTogHot and 225 or 165) * appear) -- 1430
	) -- 1430
	ctx.texts:put( -- 1431
		"xs", -- 1431
		"收束", -- 1431
		togRect.x + 27, -- 1431
		headY, -- 1431
		toColor(expTogHot and PALETTE.amberCore or PALETTE.textMid), -- 1431
		0.5, -- 1431
		0.5, -- 1431
		"Center", -- 1431
		0.6, -- 1431
		(expTogHot and 0.98 or 0.88) * appear, -- 1431
		0.08 -- 1431
	) -- 1431
	local i = 0 -- 1434
	do -- 1434
		i = 0 -- 1435
		while i < #offers do -- 1435
			do -- 1435
				local tid = offers[i + 1] -- 1436
				local baseBox = boxes[i + 1] -- 1437
				local cardStagger = easeOutCubic(clamp((self.staggerTime - i * 0.055) / 0.24, 0, 1)) -- 1438
				local alpha = cardStagger * appear -- 1439
				if alpha <= 0.01 then -- 1439
					goto __continue210 -- 1441
				end -- 1441
				local lift = (self.cardLiftT[i + 1] or 0) * 10 -- 1443
				local slideY = (1 - cardStagger) * -22 -- 1444
				local x = baseBox.x -- 1445
				local y = baseBox.y + slideY + lift -- 1446
				local w = baseBox.width -- 1447
				local h = baseBox.height -- 1448
				local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1449
				self:drawSingleTalentCard( -- 1451
					uiDraw, -- 1451
					uiInkDraw, -- 1451
					uiArt, -- 1451
					uiGlow, -- 1451
					ctx, -- 1451
					rg, -- 1451
					tid, -- 1451
					i, -- 1451
					x, -- 1451
					y, -- 1451
					w, -- 1451
					h, -- 1451
					isHot, -- 1451
					alpha, -- 1451
					mode -- 1451
				) -- 1451
			end -- 1451
			::__continue210:: -- 1451
			i = i + 1 -- 1435
		end -- 1435
	end -- 1435
end -- 1382
function RoguelikeUiPlugin.prototype.drawSingleTalentCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, tid, slotIdx, x, y, w, h, isHot, alpha, mode) -- 1455
	local meta = resolveTalentVisual(tid, rg) -- 1472
	local curRank = rg.ranks[tid] or 0 -- 1473
	local cx = x + w * 0.5 -- 1474
	local cy = y + h * 0.5 -- 1475
	local accent = isHot and PALETTE.rouge or meta.accent -- 1476
	uiArt:tryPlace( -- 1479
		"ink_frame_mask", -- 1479
		"rg_card_sh_" .. tostring(slotIdx), -- 1479
		cx, -- 1479
		cy - 4, -- 1479
		w + 26, -- 1479
		h + 24, -- 1479
		{ -- 1479
			color = toColor(PALETTE.voidDark), -- 1480
			opacity = 0.72 * alpha, -- 1480
			layer = -1 -- 1480
		} -- 1480
	) -- 1480
	if isHot then -- 1480
		local breathe = 0.86 + 0.14 * math.sin(self.animTime * 4) -- 1483
		fillRadialGlow( -- 1484
			uiGlow, -- 1484
			cx, -- 1484
			cy, -- 1484
			w * 0.74, -- 1484
			h * 0.64, -- 1484
			toColor(PALETTE.rouge, 34 * breathe * alpha), -- 1484
			Color(182, 58, 56, 0), -- 1484
			14 -- 1484
		) -- 1484
	end -- 1484
	local bgCol = isHot and Color( -- 1488
		28, -- 1488
		22, -- 1488
		27, -- 1488
		math.floor(244 * alpha + 0.5) -- 1488
	) or Color( -- 1488
		15, -- 1488
		18, -- 1488
		26, -- 1488
		math.floor(234 * alpha + 0.5) -- 1488
	) -- 1488
	local bdCol = toColor(isHot and PALETTE.rouge or meta.accent, (isHot and 235 or 155) * alpha) -- 1489
	uiDraw:drawRoundedRect( -- 1490
		Rect(x, y, w, h), -- 1490
		5, -- 1490
		bgCol, -- 1490
		isHot and 1.55 or 0.95, -- 1490
		bdCol -- 1490
	) -- 1490
	uiDraw:drawRect( -- 1492
		Rect(x + 5, y + 5, w - 10, h - 10), -- 1492
		Color(0, 0, 0, 0), -- 1492
		0.65, -- 1492
		toColor(isHot and PALETTE.amberCore or PALETTE.silkDim, (isHot and 115 or 68) * alpha) -- 1492
	) -- 1492
	drawFiligreeCorners( -- 1494
		uiInkDraw, -- 1494
		uiArt, -- 1494
		"rg_card_cn_" .. tostring(slotIdx), -- 1494
		x + 2, -- 1494
		y + 2, -- 1494
		w - 4, -- 1494
		h - 4, -- 1494
		accent, -- 1494
		(isHot and 0.94 or 0.62) * alpha, -- 1494
		22, -- 1494
		false, -- 1494
		3 -- 1494
	) -- 1494
	local topY = y + h - 22 -- 1497
	ctx.texts:put( -- 1498
		"xs", -- 1498
		meta.category, -- 1498
		x + 16, -- 1498
		topY, -- 1498
		toColor(meta.accentCore), -- 1498
		0, -- 1498
		0.5, -- 1498
		"Left", -- 1498
		1.2, -- 1498
		0.88 * alpha, -- 1498
		0.08 -- 1498
	) -- 1498
	local maxPips = math.max(curRank + 1, 3) -- 1501
	local pipStartX = x + w - 16 - (maxPips - 1) * 12 -- 1502
	local k = 0 -- 1503
	do -- 1503
		k = 0 -- 1504
		while k < maxPips do -- 1504
			local px = pipStartX + k * 12 -- 1505
			if k < curRank then -- 1505
				drawDiamond( -- 1507
					uiInkDraw, -- 1507
					px, -- 1507
					topY, -- 1507
					4, -- 1507
					4, -- 1507
					toColor(meta.accentCore, 230 * alpha) -- 1507
				) -- 1507
			elseif k == curRank then -- 1507
				drawDiamond( -- 1509
					uiInkDraw, -- 1509
					px, -- 1509
					topY, -- 1509
					4.4, -- 1509
					4.4, -- 1509
					toColor(isHot and PALETTE.rouge or PALETTE.amber, 220 * alpha), -- 1509
					1, -- 1509
					toColor(PALETTE.textBright, 220 * alpha) -- 1509
				) -- 1509
			else -- 1509
				drawDiamond( -- 1511
					uiInkDraw, -- 1511
					px, -- 1511
					topY, -- 1511
					3.2, -- 1511
					3.2, -- 1511
					Color(0, 0, 0, 0), -- 1511
					0.85, -- 1511
					toColor(PALETTE.silkDim, 130 * alpha) -- 1511
				) -- 1511
			end -- 1511
			k = k + 1 -- 1504
		end -- 1504
	end -- 1504
	drawHairline( -- 1515
		uiInkDraw, -- 1515
		uiArt, -- 1515
		"rg_card_hl_" .. tostring(slotIdx), -- 1515
		cx, -- 1515
		topY - 14, -- 1515
		w - 28, -- 1515
		accent, -- 1515
		0.45 * alpha, -- 1515
		false, -- 1515
		2 -- 1515
	) -- 1515
	local iconY = y + h - 76 -- 1518
	uiArt:tryPlace( -- 1519
		"ink_enso_fine", -- 1519
		"rg_card_enso_" .. tostring(slotIdx), -- 1519
		cx, -- 1519
		iconY, -- 1519
		62, -- 1519
		62, -- 1519
		{ -- 1519
			color = toColor(isHot and PALETTE.amberCore or meta.accent), -- 1520
			opacity = (isHot and 0.64 or 0.36) * alpha, -- 1520
			angle = self.animTime * (isHot and 16 or 6), -- 1520
			layer = 2 -- 1520
		} -- 1520
	) -- 1520
	fillRadialGlow( -- 1522
		uiGlow, -- 1522
		cx, -- 1522
		iconY, -- 1522
		34, -- 1522
		34, -- 1522
		toColor(meta.accent, (isHot and 42 or 20) * alpha), -- 1522
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1522
		12 -- 1522
	) -- 1522
	drawTalentGlyph( -- 1523
		uiInkDraw, -- 1523
		cx, -- 1523
		iconY, -- 1523
		22, -- 1523
		tid, -- 1523
		isHot and meta.accentCore or meta.accent, -- 1523
		alpha, -- 1523
		isHot and PALETTE.textBright or meta.accentCore -- 1523
	) -- 1523
	local titleY = y + 114 -- 1526
	ctx.texts:put( -- 1527
		"md", -- 1528
		meta.title, -- 1529
		cx, -- 1530
		titleY, -- 1531
		toColor(isHot and PALETTE.textBright or meta.accentCore), -- 1532
		0.5, -- 1533
		0.5, -- 1534
		"Center", -- 1535
		5, -- 1536
		0.98 * alpha, -- 1537
		0.1 -- 1538
	) -- 1538
	ctx.texts:put( -- 1542
		"xs", -- 1543
		meta:shortEffect(rg, curRank), -- 1544
		cx, -- 1545
		titleY - 26, -- 1546
		toColor(isHot and PALETTE.amberCore or PALETTE.textBright), -- 1547
		0.5, -- 1548
		0.5, -- 1549
		"Center", -- 1550
		0.6, -- 1551
		0.96 * alpha, -- 1552
		0.08 -- 1553
	) -- 1553
	ctx.texts:put( -- 1555
		"xs", -- 1556
		meta:subEffect(rg, curRank), -- 1557
		cx, -- 1558
		titleY - 46, -- 1559
		toColor(PALETTE.textMid), -- 1560
		0.5, -- 1561
		0.5, -- 1562
		"Center", -- 1563
		0.4, -- 1564
		0.86 * alpha, -- 1565
		0.08 -- 1566
	) -- 1566
	local whisperAlpha = (isHot and 0.9 or (mode == "touch" and 0.62 or 0.36)) * alpha -- 1570
	ctx.texts:put( -- 1571
		"xs", -- 1572
		meta.whisper, -- 1573
		cx, -- 1574
		y + 44, -- 1575
		toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1576
		0.5, -- 1577
		0.5, -- 1578
		"Center", -- 1579
		0.2, -- 1580
		whisperAlpha, -- 1581
		0.06 -- 1582
	) -- 1582
	local footY = y + 18 -- 1586
	if isHot then -- 1586
		drawSilkRibbon( -- 1588
			uiDraw, -- 1588
			uiArt, -- 1588
			"rg_card_rib_" .. tostring(slotIdx), -- 1588
			cx, -- 1588
			footY, -- 1588
			w - 18, -- 1588
			24, -- 1588
			PALETTE.rougeSoft, -- 1588
			0.56 * alpha, -- 1588
			1 -- 1588
		) -- 1588
	end -- 1588
	if mode == "kbm" then -- 1588
		drawSilkKeycap( -- 1591
			uiInkDraw, -- 1591
			ctx.texts, -- 1591
			cx - 42, -- 1591
			footY - 10, -- 1591
			22, -- 1591
			20, -- 1591
			"" .. tostring(slotIdx + 1), -- 1591
			accent, -- 1591
			alpha, -- 1591
			isHot -- 1591
		) -- 1591
		ctx.texts:put( -- 1592
			"xs", -- 1592
			isHot and "落印习得" or "习得", -- 1592
			cx - 12, -- 1592
			footY, -- 1592
			toColor(isHot and PALETTE.textBright or PALETTE.textMid), -- 1592
			0, -- 1592
			0.5, -- 1592
			"Left", -- 1592
			1, -- 1592
			0.94 * alpha, -- 1592
			0.08 -- 1592
		) -- 1592
	elseif mode == "gamepad" then -- 1592
		local label = isHot and "◆ L3 落印 ◆" or ("第" .. rankChinese(slotIdx + 1)) .. "筹" -- 1594
		ctx.texts:put( -- 1595
			"xs", -- 1595
			label, -- 1595
			cx, -- 1595
			footY, -- 1595
			toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1595
			0.5, -- 1595
			0.5, -- 1595
			"Center", -- 1595
			1, -- 1595
			0.94 * alpha, -- 1595
			0.08 -- 1595
		) -- 1595
	else -- 1595
		ctx.texts:put( -- 1597
			"xs", -- 1597
			"轻触落印", -- 1597
			cx, -- 1597
			footY, -- 1597
			toColor(PALETTE.amberCore), -- 1597
			0.5, -- 1597
			0.5, -- 1597
			"Center", -- 1597
			1.2, -- 1597
			0.95 * alpha, -- 1597
			0.08 -- 1597
		) -- 1597
	end -- 1597
end -- 1455
function RoguelikeUiPlugin.prototype.drawCompactTalentTallies(self, uiDraw, uiInkDraw, uiArt, ctx, rg, safe) -- 1603
	local offers = rg.offers -- 1611
	local touchMode = ctx.input:isTouchMode() -- 1612
	local mode = ctx.input.inputMode -- 1613
	local boxes = ____exports.computeRoguelikeCardRects( -- 1614
		ctx.uiW, -- 1614
		ctx.uiH, -- 1614
		#offers, -- 1614
		false, -- 1614
		touchMode, -- 1614
		safe.top -- 1614
	) -- 1614
	self.lastCardBoxes = boxes -- 1615
	local i = 0 -- 1617
	do -- 1617
		i = 0 -- 1618
		while i < #offers do -- 1618
			local tid = offers[i + 1] -- 1619
			local box = boxes[i + 1] -- 1620
			local meta = resolveTalentVisual(tid, rg) -- 1621
			local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1622
			local cy = box.y + box.height * 0.5 -- 1624
			local bdCol = isHot and PALETTE.rouge or meta.accent -- 1625
			uiDraw:drawRoundedRect( -- 1627
				box, -- 1628
				4, -- 1629
				toColor(isHot and PALETTE.inkWarm or PALETTE.panelBgDeep, isHot and 236 or 210), -- 1630
				isHot and 1.4 or 0.9, -- 1631
				toColor(bdCol, isHot and 235 or 178) -- 1632
			) -- 1632
			drawTalentGlyph( -- 1634
				uiInkDraw, -- 1634
				box.x + 20, -- 1634
				cy, -- 1634
				10.5, -- 1634
				tid, -- 1634
				meta.accent, -- 1634
				0.96, -- 1634
				meta.accentCore -- 1634
			) -- 1634
			if mode == "kbm" then -- 1634
				drawSilkKeycap( -- 1636
					uiInkDraw, -- 1636
					ctx.texts, -- 1636
					box.x + 36, -- 1636
					cy - 10, -- 1636
					20, -- 1636
					20, -- 1636
					"" .. tostring(i + 1), -- 1636
					bdCol, -- 1636
					0.95, -- 1636
					isHot -- 1636
				) -- 1636
				ctx.texts:put( -- 1637
					"xs", -- 1637
					meta.title, -- 1637
					box.x + 62, -- 1637
					cy + 7, -- 1637
					toColor(PALETTE.textBright), -- 1637
					0, -- 1637
					0.5, -- 1637
					"Left", -- 1637
					0.8, -- 1637
					0.96, -- 1637
					0.08 -- 1637
				) -- 1637
				ctx.texts:put( -- 1638
					"xs", -- 1638
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1638
					box.x + 62, -- 1638
					cy - 8, -- 1638
					toColor(meta.accentCore), -- 1638
					0, -- 1638
					0.5, -- 1638
					"Left", -- 1638
					0.2, -- 1638
					0.82, -- 1638
					0.06 -- 1638
				) -- 1638
			else -- 1638
				drawBlossomDot( -- 1640
					uiInkDraw, -- 1640
					uiArt, -- 1640
					"rg_cmp_dot_" .. tostring(i), -- 1640
					box.x + 38, -- 1640
					cy, -- 1640
					isHot and 11 or 7, -- 1640
					bdCol, -- 1640
					0.95, -- 1640
					4 -- 1640
				) -- 1640
				ctx.texts:put( -- 1641
					"xs", -- 1641
					(meta.title .. " · ") .. meta.category, -- 1641
					box.x + 50, -- 1641
					cy + 7, -- 1641
					toColor(PALETTE.textBright), -- 1641
					0, -- 1641
					0.5, -- 1641
					"Left", -- 1641
					0.6, -- 1641
					0.96, -- 1641
					0.08 -- 1641
				) -- 1641
				ctx.texts:put( -- 1642
					"xs", -- 1642
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1642
					box.x + 50, -- 1642
					cy - 8, -- 1642
					toColor(meta.accentCore), -- 1642
					0, -- 1642
					0.5, -- 1642
					"Left", -- 1642
					0.2, -- 1642
					0.82, -- 1642
					0.06 -- 1642
				) -- 1642
			end -- 1642
			i = i + 1 -- 1618
		end -- 1618
	end -- 1618
	local last = boxes[#boxes] -- 1647
	local togRect = Rect(last.x + last.width + 8, last.y + (last.height - 26) * 0.5, 50, 26) -- 1648
	self.expandToggleBox = togRect -- 1649
	local cmpPtr = Vec2((ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale, (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale) -- 1650
	local cmpTogHot = not touchMode and (ctx.input.uiInside or ctx.input.inside) and togRect:containsPoint(cmpPtr) -- 1651
	uiDraw:drawRoundedRect( -- 1652
		togRect, -- 1652
		4, -- 1652
		toColor(cmpTogHot and PALETTE.rougeSoft or PALETTE.inkWash, cmpTogHot and 225 or 190), -- 1652
		cmpTogHot and 1.2 or 0.9, -- 1652
		toColor(cmpTogHot and PALETTE.amberCore or PALETTE.amber, cmpTogHot and 235 or 175) -- 1652
	) -- 1652
	ctx.texts:put( -- 1653
		"xs", -- 1653
		"展开", -- 1653
		togRect.x + 25, -- 1653
		togRect.y + 13, -- 1653
		toColor(cmpTogHot and PALETTE.textBright or PALETTE.amberCore), -- 1653
		0.5, -- 1653
		0.5, -- 1653
		"Center", -- 1653
		0.6, -- 1653
		cmpTogHot and 0.98 or 0.92, -- 1653
		0.08 -- 1653
	) -- 1653
end -- 1603
function RoguelikeUiPlugin.prototype.drawSealAndAbsorb(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, anim) -- 1658
	local meta = resolveTalentVisual(anim.talentId, rg) -- 1667
	local pb = anim.pickedBox -- 1668
	local pcx = pb.x + pb.width * 0.5 -- 1669
	local pcy = pb.y + pb.height * 0.5 -- 1670
	if anim.elapsed < anim.sealDuration then -- 1670
		local t = clamp(anim.elapsed / anim.sealDuration, 0, 1) -- 1673
		local i = 0 -- 1675
		do -- 1675
			i = 0 -- 1676
			while i < #anim.allBoxes do -- 1676
				do -- 1676
					if i == anim.pickedSlot then -- 1676
						goto __continue231 -- 1678
					end -- 1678
					local ob = anim.allBoxes[i + 1] -- 1680
					local dir = i < anim.pickedSlot and -1 or 1 -- 1681
					local drift = dir * easeOutCubic(t) * 26 -- 1682
					local oa = (1 - t) * 0.55 -- 1683
					uiDraw:drawRoundedRect( -- 1684
						Rect( -- 1684
							ob.x + drift, -- 1684
							ob.y - easeOutCubic(t) * 8, -- 1684
							ob.width, -- 1684
							ob.height -- 1684
						), -- 1684
						5, -- 1684
						Color( -- 1684
							15, -- 1684
							18, -- 1684
							26, -- 1684
							math.floor(180 * oa + 0.5) -- 1684
						), -- 1684
						0.8, -- 1684
						toColor(PALETTE.silkDim, 110 * oa) -- 1684
					) -- 1684
				end -- 1684
				::__continue231:: -- 1684
				i = i + 1 -- 1676
			end -- 1676
		end -- 1676
		local pop = 1 + (1 - easeOutCubic(t)) * 0.04 -- 1688
		local sw = pb.width * pop -- 1689
		local sh = pb.height * pop -- 1690
		local sx = pcx - sw * 0.5 -- 1691
		local sy = pcy - sh * 0.5 -- 1692
		fillRadialGlow( -- 1693
			uiGlow, -- 1693
			pcx, -- 1693
			pcy, -- 1693
			sw * 0.72, -- 1693
			sh * 0.62, -- 1693
			toColor(PALETTE.rouge, 56 * (1 - t * 0.4)), -- 1693
			Color(182, 58, 56, 0), -- 1693
			14 -- 1693
		) -- 1693
		uiDraw:drawRoundedRect( -- 1694
			Rect(sx, sy, sw, sh), -- 1694
			5, -- 1694
			Color(34, 22, 27, 245), -- 1694
			1.8, -- 1694
			toColor(PALETTE.rouge, 245) -- 1694
		) -- 1694
		drawTalentGlyph( -- 1695
			uiInkDraw, -- 1695
			pcx, -- 1695
			pcy + (anim.fromExpanded and 24 or 0), -- 1695
			anim.fromExpanded and 22 or 12, -- 1695
			anim.talentId, -- 1695
			meta.accentCore, -- 1695
			0.96, -- 1695
			PALETTE.textBright -- 1695
		) -- 1695
		ctx.texts:put( -- 1696
			"md", -- 1696
			meta.title, -- 1696
			pcx, -- 1696
			pcy - (anim.fromExpanded and 22 or 0), -- 1696
			toColor(PALETTE.textBright), -- 1696
			0.5, -- 1696
			0.5, -- 1696
			"Center", -- 1696
			4, -- 1696
			0.98, -- 1696
			0.1 -- 1696
		) -- 1696
		local slam = 1 + (1 - t) ^ 2 * 0.55 -- 1699
		drawLoneSeal( -- 1700
			uiInkDraw, -- 1701
			uiArt, -- 1702
			ctx.texts, -- 1703
			"rg_pick_seal", -- 1704
			pcx + (anim.fromExpanded and pb.width * 0.26 or pb.width * 0.34), -- 1705
			pcy - (anim.fromExpanded and pb.height * 0.22 or 0), -- 1706
			26 * slam, -- 1707
			50 * slam, -- 1708
			"契", -- 1709
			"印", -- 1710
			PALETTE.sealRedBright, -- 1711
			PALETTE.sealText, -- 1712
			0.96, -- 1713
			6 -- 1714
		) -- 1714
		return -- 1716
	end -- 1716
	local t = clamp( -- 1720
		(anim.elapsed - anim.sealDuration) / math.max(0.01, anim.absorbDuration), -- 1720
		0, -- 1720
		1 -- 1720
	) -- 1720
	local dest = self:computeAbsorbTargetUi(ctx, rg, anim.targetKind) -- 1721
	local ctrlX = (pcx + dest.x) * 0.5 -- 1722
	local ctrlY = math.max(pcy, dest.y) + 76 -- 1723
	local headT = easeInOutQuad(t) -- 1726
	local samples = 10 -- 1727
	local s = 0 -- 1728
	local prevPt -- 1729
	do -- 1729
		s = 0 -- 1730
		while s <= samples do -- 1730
			local u = math.max(0, headT - (samples - s) * 0.032) -- 1731
			local inv = 1 - u -- 1732
			local bx = inv * inv * pcx + 2 * inv * u * ctrlX + u * u * dest.x -- 1733
			local by = inv * inv * pcy + 2 * inv * u * ctrlY + u * u * dest.y -- 1734
			local pt = Vec2(bx, by) -- 1735
			if prevPt ~= nil then -- 1735
				local segA = s / samples * (1 - t * 0.35) -- 1737
				uiGlow:drawSegment( -- 1738
					prevPt, -- 1738
					pt, -- 1738
					1.6 + s / samples * 2.4, -- 1738
					toColor( -- 1738
						meta.accentCore, -- 1738
						math.floor(210 * segA + 0.5) -- 1738
					) -- 1738
				) -- 1738
			end -- 1738
			if s % 2 == 1 then -- 1738
				uiGlow:drawDot( -- 1741
					pt, -- 1741
					2 + s / samples * 2.2, -- 1741
					toColor( -- 1741
						PALETTE.amberCore, -- 1741
						math.floor(180 * (s / samples) * (1 - t * 0.3) + 0.5) -- 1741
					) -- 1741
				) -- 1741
			end -- 1741
			prevPt = pt -- 1743
			s = s + 1 -- 1730
		end -- 1730
	end -- 1730
	local invH = 1 - headT -- 1745
	local hx = invH * invH * pcx + 2 * invH * headT * ctrlX + headT * headT * dest.x -- 1746
	local hy = invH * invH * pcy + 2 * invH * headT * ctrlY + headT * headT * dest.y -- 1747
	fillRadialGlow( -- 1748
		uiGlow, -- 1748
		hx, -- 1748
		hy, -- 1748
		22, -- 1748
		22, -- 1748
		toColor(meta.accentCore, 96 * (1 - t * 0.3)), -- 1748
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1748
		12 -- 1748
	) -- 1748
	drawDiamond( -- 1749
		uiInkDraw, -- 1749
		hx, -- 1749
		hy, -- 1749
		5.5, -- 1749
		5.5, -- 1749
		toColor(PALETTE.textBright, 240) -- 1749
	) -- 1749
end -- 1658
function RoguelikeUiPlugin.prototype.computeAbsorbTargetUi(self, ctx, rg, target) -- 1752
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1753
	local bx = 28 + safe.left -- 1754
	local hpY = ctx.uiH - 56 - safe.top -- 1755
	if target == "hp" then -- 1755
		return { -- 1757
			x = bx + 44 + math.min(5, rg.maxHp) * 52, -- 1757
			y = hpY -- 1757
		} -- 1757
	end -- 1757
	if target == "gun" then -- 1757
		local p = ctx.p -- 1760
		return { -- 1761
			x = clamp( -- 1762
				ctx.cam:sx(p.player.x + p.player.facing * 14) / ctx.uiScale, -- 1762
				80, -- 1762
				ctx.uiW - 80 -- 1762
			), -- 1762
			y = clamp( -- 1763
				ctx.cam:sy(p.player.y + p.player.h * 0.62, p.player.depth) / ctx.uiScale, -- 1763
				80, -- 1763
				ctx.uiH - 80 -- 1763
			) -- 1763
		} -- 1763
	end -- 1763
	if target == "shoulder" then -- 1763
		local p = ctx.p -- 1767
		return { -- 1768
			x = clamp( -- 1769
				ctx.cam:sx(p.player.x) / ctx.uiScale, -- 1769
				80, -- 1769
				ctx.uiW - 80 -- 1769
			), -- 1769
			y = clamp( -- 1770
				ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) / ctx.uiScale, -- 1770
				80, -- 1770
				ctx.uiH - 80 -- 1770
			) -- 1770
		} -- 1770
	end -- 1770
	if target == "satchel" then -- 1770
		return {x = bx + 86, y = hpY - 68} -- 1774
	end -- 1774
	return {x = bx + 64, y = hpY - 36} -- 1776
end -- 1752
function RoguelikeUiPlugin.prototype.drawSegmentClearRibbon(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, safe) -- 1781
	local elapsed = SEGMENT_BANNER_DURATION - self.segmentBannerT -- 1789
	local fadeIn = clamp(elapsed / 0.24, 0, 1) -- 1790
	local fadeOut = clamp(self.segmentBannerT / 0.36, 0, 1) -- 1791
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1792
	if alpha <= 0.01 then -- 1792
		return -- 1794
	end -- 1794
	local cx = ctx.uiW * 0.5 -- 1796
	local cy = ctx.uiH - 134 - safe.top -- 1797
	drawSilkVeil( -- 1798
		uiDraw, -- 1798
		uiArt, -- 1798
		"rg_seg_veil", -- 1798
		cx, -- 1798
		cy, -- 1798
		460, -- 1798
		74, -- 1798
		PALETTE.inkWash, -- 1798
		0.78 * alpha, -- 1798
		2 -- 1798
	) -- 1798
	drawMistCurve( -- 1799
		uiArt, -- 1799
		"rg_seg_mist", -- 1799
		cx, -- 1799
		cy, -- 1799
		420, -- 1799
		66, -- 1799
		PALETTE.amber, -- 1799
		0.24 * alpha, -- 1799
		2 -- 1799
	) -- 1799
	drawHairline( -- 1800
		uiInkDraw, -- 1800
		uiArt, -- 1800
		"rg_seg_top", -- 1800
		cx, -- 1800
		cy + 32, -- 1800
		320, -- 1800
		PALETTE.amberCore, -- 1800
		0.58 * alpha, -- 1800
		true, -- 1800
		4 -- 1800
	) -- 1800
	drawHairline( -- 1801
		uiInkDraw, -- 1801
		uiArt, -- 1801
		"rg_seg_bot", -- 1801
		cx, -- 1801
		cy - 32, -- 1801
		280, -- 1801
		PALETTE.silkDim, -- 1801
		0.44 * alpha, -- 1801
		false, -- 1801
		4 -- 1801
	) -- 1801
	fillRadialGlow( -- 1802
		uiGlow, -- 1802
		cx, -- 1802
		cy + 6, -- 1802
		130, -- 1802
		34, -- 1802
		toColor(PALETTE.amber, 26 * alpha), -- 1802
		Color(214, 186, 146, 0), -- 1802
		12 -- 1802
	) -- 1802
	ctx.texts:put( -- 1804
		"banner", -- 1804
		self.segmentBannerHeadline, -- 1804
		cx, -- 1804
		cy + 9, -- 1804
		toColor(PALETTE.textBright), -- 1804
		0.5, -- 1804
		0.5, -- 1804
		"Center", -- 1804
		8, -- 1804
		0.96 * alpha, -- 1804
		0.12 -- 1804
	) -- 1804
	ctx.texts:put( -- 1805
		"xs", -- 1805
		self.segmentBannerSub, -- 1805
		cx, -- 1805
		cy - 18, -- 1805
		toColor(PALETTE.amberCore), -- 1805
		0.5, -- 1805
		0.5, -- 1805
		"Center", -- 1805
		1.6, -- 1805
		0.92 * alpha, -- 1805
		0.08 -- 1805
	) -- 1805
end -- 1781
function RoguelikeUiPlugin.prototype.drawDeathRecapOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, snap) -- 1810
	local elapsed = DEATH_RECAP_DURATION - self.deathRecapT -- 1818
	local fadeIn = clamp(elapsed / 0.26, 0, 1) -- 1819
	local fadeOut = clamp(self.deathRecapT / 0.44, 0, 1) -- 1820
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1821
	if alpha <= 0.01 then -- 1821
		return -- 1823
	end -- 1823
	local cx = ctx.uiW * 0.5 -- 1825
	local cy = ctx.uiH * 0.52 -- 1826
	uiDraw:drawRect( -- 1829
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1829
		Color( -- 1829
			8, -- 1829
			10, -- 1829
			16, -- 1829
			math.floor(168 * alpha + 0.5) -- 1829
		) -- 1829
	) -- 1829
	drawMistCurve( -- 1830
		uiArt, -- 1830
		"rg_recap_mist", -- 1830
		cx, -- 1830
		cy, -- 1830
		640, -- 1830
		140, -- 1830
		PALETTE.rougeSoft, -- 1830
		0.24 * alpha, -- 1830
		1 -- 1830
	) -- 1830
	fillRadialGlow( -- 1831
		uiGlow, -- 1831
		cx, -- 1831
		cy + 20, -- 1831
		220, -- 1831
		110, -- 1831
		toColor(PALETTE.rouge, 26 * alpha), -- 1831
		Color(182, 58, 56, 0), -- 1831
		14 -- 1831
	) -- 1831
	ctx.texts:put( -- 1834
		"banner", -- 1834
		"折筹重整", -- 1834
		cx, -- 1834
		cy + 88, -- 1834
		toColor(PALETTE.textBright), -- 1834
		0.5, -- 1834
		0.5, -- 1834
		"Center", -- 1834
		10, -- 1834
		0.96 * alpha, -- 1834
		0.12 -- 1834
	) -- 1834
	drawHairline( -- 1835
		uiInkDraw, -- 1835
		uiArt, -- 1835
		"rg_recap_line", -- 1835
		cx, -- 1835
		cy + 48, -- 1835
		360, -- 1835
		PALETTE.rouge, -- 1835
		0.62 * alpha, -- 1835
		true, -- 1835
		3 -- 1835
	) -- 1835
	local scatterT = clamp((elapsed - 0.22) / 1.15, 0, 1) -- 1838
	local ids = {} -- 1839
	for k in pairs(snap.ranks) do -- 1840
		if snap.ranks[k] > 0 then -- 1840
			ids[#ids + 1] = k -- 1842
		end -- 1842
	end -- 1842
	if #ids > 0 then -- 1842
		local step = 76 -- 1846
		local startX = cx - (#ids - 1) * step * 0.5 -- 1847
		local i = 0 -- 1848
		do -- 1848
			i = 0 -- 1849
			while i < #ids do -- 1849
				local tid = ids[i + 1] -- 1850
				local meta = resolveTalentVisual(tid) -- 1851
				local dir = #ids == 1 and 0 or i - (#ids - 1) * 0.5 -- 1852
				local dx = dir * easeOutCubic(scatterT) * 28 -- 1853
				local dy = easeOutCubic(scatterT) * 24 -- 1854
				local chipA = alpha * (1 - scatterT * 0.85) -- 1855
				local ix = startX + i * step + dx -- 1856
				local iy = cy + 6 + dy -- 1857
				uiDraw:drawRoundedRect( -- 1858
					Rect(ix - 24, iy - 18, 48, 36), -- 1858
					4, -- 1858
					toColor(PALETTE.inkWash, 180 * chipA), -- 1858
					0.9, -- 1858
					toColor(meta.accent, 150 * chipA) -- 1858
				) -- 1858
				drawTalentGlyph( -- 1859
					uiInkDraw, -- 1859
					ix, -- 1859
					iy, -- 1859
					12, -- 1859
					tid, -- 1859
					meta.accent, -- 1859
					chipA, -- 1859
					meta.accentCore -- 1859
				) -- 1859
				if scatterT > 0.08 then -- 1859
					uiGlow:drawDot( -- 1862
						Vec2(ix + dir * 10, iy + 14 + scatterT * 14), -- 1862
						2, -- 1862
						toColor(PALETTE.silkDim, 140 * chipA) -- 1862
					) -- 1862
					uiGlow:drawDot( -- 1863
						Vec2(ix - dir * 8, iy + 8 + scatterT * 20), -- 1863
						1.6, -- 1863
						toColor(PALETTE.rouge, 130 * chipA) -- 1863
					) -- 1863
				end -- 1863
				i = i + 1 -- 1849
			end -- 1849
		end -- 1849
	end -- 1849
	local countText = snap.totalRanks > 0 and ("曾习" .. toChineseUpper(snap.totalRanks)) .. "筹" or "尚未择筹" -- 1868
	local summary = ((((("止步于「" .. snap.stageName) .. "」 · ") .. countText) .. " · ") .. weaponMetaOf(snap.weaponId).name) .. " · 筹散人安，重整再护" -- 1869
	ctx.texts:put( -- 1870
		"sm", -- 1870
		summary, -- 1870
		cx, -- 1870
		cy - 48, -- 1870
		toColor(PALETTE.amberCore), -- 1870
		0.5, -- 1870
		0.5, -- 1870
		"Center", -- 1870
		1, -- 1870
		0.94 * alpha, -- 1870
		0.08 -- 1870
	) -- 1870
	ctx.texts:put( -- 1871
		"xs", -- 1871
		"新一轮护送将自城外巷路再启", -- 1871
		cx, -- 1871
		cy - 82, -- 1871
		toColor(PALETTE.textDim), -- 1871
		0.5, -- 1871
		0.5, -- 1871
		"Center", -- 1871
		1.2, -- 1871
		0.78 * alpha, -- 1871
		0.06 -- 1871
	) -- 1871
	if ctx.p.escortFailed then -- 1871
		local btns = ____exports.computeEscortDeathButtons(ctx.uiW, ctx.uiH) -- 1873
		local boxes = {btns.retry, btns.title} -- 1874
		local dPtr = Vec2((ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale, (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale) -- 1875
		local dInside = not ctx.input:isTouchMode() and ctx.input.inputMode == "kbm" and (ctx.input.uiInside or ctx.input.inside) -- 1876
		local moved = math.abs(ctx.input.uiDx) + math.abs(ctx.input.uiDy) >= ctx.uiScale -- 1877
		do -- 1877
			local i = 0 -- 1878
			while i < #boxes do -- 1878
				local box = boxes[i + 1] -- 1879
				local hovered = dInside and box:containsPoint(dPtr) -- 1880
				if hovered and moved and self.deathSelected ~= i then -- 1880
					self.deathSelected = i -- 1882
					ctx.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045) -- 1883
				end -- 1883
				local active = i == self.deathSelected or hovered -- 1885
				local color = active and PALETTE.amberCore or PALETTE.silkLine -- 1886
				uiDraw:drawRoundedRect( -- 1887
					box, -- 1887
					4, -- 1887
					toColor(active and PALETTE.inkWarm or PALETTE.inkWash, active and 236 or 210), -- 1887
					active and 1.45 or 1, -- 1887
					toColor(color) -- 1887
				) -- 1887
				ctx.texts:put( -- 1888
					"sm", -- 1888
					i == 0 and "重整再赴" or "返回标题", -- 1888
					box.x + box.width / 2, -- 1888
					box.y + box.height / 2, -- 1889
					toColor(active and PALETTE.textBright or color), -- 1889
					0.5, -- 1889
					0.5, -- 1889
					"Center" -- 1889
				) -- 1889
				i = i + 1 -- 1878
			end -- 1878
		end -- 1878
	end -- 1878
end -- 1810
function RoguelikeUiPlugin.prototype.drawBuildLedger(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1896
	local appear = easeOutCubic(self.ledgerAnimT) -- 1905
	local cx = ctx.uiW * 0.5 -- 1906
	local pageW = math.min(ctx.uiW - 96 - safe.left - safe.right, 880) -- 1907
	local pageH = math.min(ctx.uiH - 116 - safe.top - safe.bottom, 504) -- 1908
	local px = cx - pageW * 0.5 -- 1909
	local py = (ctx.uiH - pageH) * 0.5 + (1 - appear) * -14 -- 1910
	local midY = py + pageH * 0.5 -- 1911
	self.ledgerPanelBox = Rect(px, py, pageW, pageH) -- 1912
	uiDraw:drawRect( -- 1915
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1915
		Color( -- 1915
			7, -- 1915
			9, -- 1915
			15, -- 1915
			math.floor(188 * appear + 0.5) -- 1915
		) -- 1915
	) -- 1915
	uiArt:tryPlace( -- 1916
		"ink_frame_mask", -- 1916
		"rg_led_sh", -- 1916
		cx, -- 1916
		midY - 6, -- 1916
		pageW + 52, -- 1916
		pageH + 46, -- 1916
		{ -- 1916
			color = toColor(PALETTE.voidDark), -- 1917
			opacity = 0.84 * appear, -- 1917
			layer = -1 -- 1917
		} -- 1917
	) -- 1917
	if not uiArt:tryPlace( -- 1917
		"ink_song_paper", -- 1919
		"rg_led_paper", -- 1919
		cx, -- 1919
		midY, -- 1919
		pageW, -- 1919
		pageH, -- 1919
		{opacity = 0.98 * appear, layer = 1} -- 1919
	) then -- 1919
		uiDraw:drawRect( -- 1920
			Rect(px, py, pageW, pageH), -- 1920
			toColor(PALETTE.xuanPaper, 248 * appear), -- 1920
			1, -- 1920
			toColor(PALETTE.silkDim, 180 * appear) -- 1920
		) -- 1920
	end -- 1920
	fillRadialGlow( -- 1922
		uiGlow, -- 1922
		cx, -- 1922
		midY + 36, -- 1922
		260, -- 1922
		140, -- 1922
		Color( -- 1922
			236, -- 1922
			224, -- 1922
			202, -- 1922
			math.floor(16 * appear + 0.5) -- 1922
		), -- 1922
		Color(236, 224, 202, 0), -- 1922
		14 -- 1922
	) -- 1922
	local inX = px + 36 -- 1925
	local inY = py + 28 -- 1926
	local inW = pageW - 72 -- 1927
	local inH = pageH - 56 -- 1928
	local redSilk = toColor(PALETTE.rouge, 118 * appear) -- 1929
	local redFaint = toColor(PALETTE.rouge, 56 * appear) -- 1930
	uiInkDraw:drawRect( -- 1931
		Rect(inX, inY, inW, inH), -- 1931
		Color(0, 0, 0, 0), -- 1931
		0.95, -- 1931
		redSilk -- 1931
	) -- 1931
	uiInkDraw:drawRect( -- 1932
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1932
		Color(0, 0, 0, 0), -- 1932
		0.55, -- 1932
		redFaint -- 1932
	) -- 1932
	local headY = inY + inH - 26 -- 1935
	local routeZh = rg.routeTag == "drygoods" and " · 布行暗渡" or (rg.routeTag == "outer" and " · 外檐强行" or "") -- 1936
	ctx.texts:put( -- 1937
		"lg", -- 1937
		"行军札记", -- 1937
		inX + 18, -- 1937
		headY, -- 1937
		toColor(PALETTE.xuanInk), -- 1937
		0, -- 1937
		0.5, -- 1937
		"Left", -- 1937
		3, -- 1937
		0.96 * appear, -- 1937
		0 -- 1937
	) -- 1937
	local metaInfo = ((("筹号 " .. tostring(rg.seed)) .. "  ·  用时 ") .. mmss(rg.ticks)) .. routeZh -- 1938
	ctx.texts:put( -- 1939
		"xs", -- 1939
		metaInfo, -- 1939
		inX + 158, -- 1939
		headY - 2, -- 1939
		toColor(PALETTE.xuanInkSub), -- 1939
		0, -- 1939
		0.5, -- 1939
		"Left", -- 1939
		1, -- 1939
		0.88 * appear, -- 1939
		0 -- 1939
	) -- 1939
	local closeW = 76 -- 1942
	local closeH = 26 -- 1943
	local closeRect = Rect(inX + inW - closeW - 14, headY - closeH * 0.5, closeW, closeH) -- 1944
	self.ledgerCloseBox = closeRect -- 1945
	local ledPtr = Vec2((ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale, (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale) -- 1946
	local closeHot = not ctx.input:isTouchMode() and (ctx.input.uiInside or ctx.input.inside) and closeRect:containsPoint(ledPtr) -- 1947
	uiInkDraw:drawRect( -- 1948
		closeRect, -- 1948
		Color( -- 1948
			168, -- 1948
			46, -- 1948
			44, -- 1948
			math.floor((closeHot and 64 or 28) * appear + 0.5) -- 1948
		), -- 1948
		closeHot and 1.3 or 0.9, -- 1948
		toColor(PALETTE.rouge, (closeHot and 235 or 185) * appear) -- 1948
	) -- 1948
	ctx.texts:put( -- 1949
		"xs", -- 1949
		"合卷", -- 1949
		closeRect.x + closeW * 0.5, -- 1949
		headY, -- 1949
		toColor(PALETTE.rouge), -- 1949
		0.5, -- 1949
		0.5, -- 1949
		"Center", -- 1949
		1.4, -- 1949
		(closeHot and 1 or 0.92) * appear, -- 1949
		0 -- 1949
	) -- 1949
	uiInkDraw:drawSegment( -- 1950
		Vec2(inX + 12, headY - 20), -- 1950
		Vec2(inX + inW - 12, headY - 20), -- 1950
		0.85, -- 1950
		redSilk -- 1950
	) -- 1950
	local foldX = inX + inW * 0.48 -- 1953
	uiInkDraw:drawSegment( -- 1954
		Vec2(foldX - 3, inY + 12), -- 1954
		Vec2(foldX - 3, headY - 26), -- 1954
		0.65, -- 1954
		redFaint -- 1954
	) -- 1954
	uiInkDraw:drawSegment( -- 1955
		Vec2(foldX + 3, inY + 12), -- 1955
		Vec2(foldX + 3, headY - 26), -- 1955
		0.65, -- 1955
		redFaint -- 1955
	) -- 1955
	local leftX = inX + 18 -- 1958
	local leftW = foldX - leftX - 18 -- 1959
	local secTopY = headY - 40 -- 1960
	ctx.texts:put( -- 1961
		"sm", -- 1961
		"此行舆图与兵备", -- 1961
		leftX, -- 1961
		secTopY, -- 1961
		toColor(PALETTE.rouge), -- 1961
		0, -- 1961
		0.5, -- 1961
		"Left", -- 1961
		1.6, -- 1961
		0.92 * appear, -- 1961
		0 -- 1961
	) -- 1961
	local stY = secTopY - 34 -- 1964
	local stages = rg.stages -- 1965
	if #stages > 0 then -- 1965
		local sx0 = leftX + 14 -- 1967
		local sx1 = leftX + leftW - 14 -- 1968
		local step = #stages > 1 and (sx1 - sx0) / (#stages - 1) or 0 -- 1969
		uiInkDraw:drawSegment( -- 1970
			Vec2(sx0, stY), -- 1970
			Vec2(sx1, stY), -- 1970
			0.9, -- 1970
			toColor(PALETTE.xuanInkSub, 130 * appear) -- 1970
		) -- 1970
		local si = 0 -- 1971
		do -- 1971
			si = 0 -- 1972
			while si < #stages do -- 1972
				local st = stages[si + 1] -- 1973
				local nx = sx0 + si * step -- 1974
				if st.current then -- 1974
					drawDiamond( -- 1976
						uiInkDraw, -- 1976
						nx, -- 1976
						stY, -- 1976
						5.5, -- 1976
						5.5, -- 1976
						toColor(PALETTE.rouge, 235 * appear) -- 1976
					) -- 1976
				elseif st.cleared then -- 1976
					drawDiamond( -- 1978
						uiInkDraw, -- 1978
						nx, -- 1978
						stY, -- 1978
						4.5, -- 1978
						4.5, -- 1978
						toColor(PALETTE.xuanInk, 210 * appear) -- 1978
					) -- 1978
				else -- 1978
					drawDiamond( -- 1980
						uiInkDraw, -- 1980
						nx, -- 1980
						stY, -- 1980
						4, -- 1980
						4, -- 1980
						Color(232, 227, 216, 255), -- 1980
						0.9, -- 1980
						toColor(PALETTE.xuanInkSub, 150 * appear) -- 1980
					) -- 1980
				end -- 1980
				ctx.texts:put( -- 1982
					"xs", -- 1982
					st.label, -- 1982
					nx, -- 1982
					stY - 18, -- 1982
					toColor(st.current and PALETTE.rouge or PALETTE.xuanInk), -- 1982
					0.5, -- 1982
					0.5, -- 1982
					"Center", -- 1982
					0.2, -- 1982
					(st.current and 0.98 or 0.78) * appear, -- 1982
					0 -- 1982
				) -- 1982
				si = si + 1 -- 1972
			end -- 1972
		end -- 1972
	end -- 1972
	local gunBoxY = stY - 142 -- 1987
	local gunBoxH = 104 -- 1988
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1989
	uiInkDraw:drawRect( -- 1990
		Rect(leftX, gunBoxY, leftW, gunBoxH), -- 1990
		Color( -- 1990
			32, -- 1990
			30, -- 1990
			32, -- 1990
			math.floor(14 * appear + 0.5) -- 1990
		), -- 1990
		0.85, -- 1990
		redFaint -- 1990
	) -- 1990
	ctx.texts:put( -- 1991
		"sm", -- 1991
		wMeta.name, -- 1991
		leftX + 12, -- 1991
		gunBoxY + gunBoxH - 20, -- 1991
		toColor(PALETTE.xuanInk), -- 1991
		0, -- 1991
		0.5, -- 1991
		"Left", -- 1991
		1.2, -- 1991
		0.96 * appear, -- 1991
		0 -- 1991
	) -- 1991
	ctx.texts:put( -- 1992
		"xs", -- 1992
		(((("装填 " .. tostring(rg.reloadTicksNow)) .. " 拍  ·  体力 ") .. tostring(rg.hp)) .. "/") .. tostring(rg.maxHp), -- 1992
		leftX + 12, -- 1992
		gunBoxY + gunBoxH - 44, -- 1992
		toColor(PALETTE.xuanInkSub), -- 1992
		0, -- 1992
		0.5, -- 1992
		"Left", -- 1992
		0.4, -- 1992
		0.88 * appear, -- 1992
		0 -- 1992
	) -- 1992
	ctx.texts:put( -- 1993
		"xs", -- 1993
		wMeta.desc, -- 1993
		leftX + 12, -- 1993
		gunBoxY + 26, -- 1993
		toColor(PALETTE.xuanInkSub), -- 1993
		0, -- 1993
		0.5, -- 1993
		"Left", -- 1993
		0.2, -- 1993
		0.82 * appear, -- 1993
		0 -- 1993
	) -- 1993
	local gridCx = leftX + leftW - 44 -- 1996
	local gridCy = gunBoxY + gunBoxH * 0.5 -- 1997
	local gStep = 22 -- 1998
	local gi = 0 -- 1999
	do -- 1999
		gi = 0 -- 2000
		while gi < #RELOAD_GRID do -- 2000
			local node = RELOAD_GRID[gi + 1] -- 2001
			local gx = gridCx + (node.col - 1) * gStep -- 2002
			local gy = gridCy + (node.row - 1) * gStep -- 2003
			local isEnhanced = wMeta.effect == "light" and node.kind == "lamp" or wMeta.effect == "echo" and node.kind == "bell" -- 2004
			if node.kind == "lamp" or node.kind == "bell" then -- 2004
				drawReloadPatternGlyph( -- 2007
					uiInkDraw, -- 2008
					gx, -- 2009
					gy, -- 2010
					isEnhanced and 8 or 6.2, -- 2011
					node.kind == "lamp" and "light" or "echo", -- 2012
					isEnhanced and PALETTE.rouge or PALETTE.xuanInkSub, -- 2013
					(isEnhanced and 0.96 or 0.55) * appear -- 2014
				) -- 2014
			else -- 2014
				uiInkDraw:drawDot( -- 2017
					Vec2(gx, gy), -- 2017
					(node.kind == "start" or node.kind == "target") and 3 or 2, -- 2017
					toColor(PALETTE.xuanInkSub, 150 * appear) -- 2017
				) -- 2017
			end -- 2017
			gi = gi + 1 -- 2000
		end -- 2000
	end -- 2000
	local invTitleY = gunBoxY - 22 -- 2022
	ctx.texts:put( -- 2023
		"xs", -- 2023
		"随身战备清点", -- 2023
		leftX, -- 2023
		invTitleY, -- 2023
		toColor(PALETTE.rouge), -- 2023
		0, -- 2023
		0.5, -- 2023
		"Left", -- 2023
		1.2, -- 2023
		0.88 * appear, -- 2023
		0 -- 2023
	) -- 2023
	local drawnInv = 0 -- 2024
	local ii = 0 -- 2025
	do -- 2025
		ii = 0 -- 2026
		while ii < #PICKUP_ORDER do -- 2026
			do -- 2026
				local k = PICKUP_ORDER[ii + 1] -- 2027
				local cnt = rg.supplies[k] or 0 -- 2028
				if cnt <= 0 then -- 2028
					goto __continue270 -- 2030
				end -- 2030
				local col = drawnInv % 2 -- 2032
				local row = math.floor(drawnInv / 2) -- 2033
				if row >= 3 then -- 2033
					break -- 2035
				end -- 2035
				local ix = leftX + col * (leftW * 0.5) -- 2037
				local iy = invTitleY - 26 - row * 28 -- 2038
				local pm = pickupMetaOf(k) -- 2039
				drawPickupGlyph( -- 2040
					uiInkDraw, -- 2040
					ix + 10, -- 2040
					iy, -- 2040
					7.2, -- 2040
					k, -- 2040
					0.92 * appear, -- 2040
					PALETTE.xuanInk -- 2040
				) -- 2040
				ctx.texts:put( -- 2041
					"xs", -- 2041
					(pm.name .. " ×") .. tostring(cnt), -- 2041
					ix + 24, -- 2041
					iy, -- 2041
					toColor(PALETTE.xuanInk), -- 2041
					0, -- 2041
					0.5, -- 2041
					"Left", -- 2041
					0.4, -- 2041
					0.9 * appear, -- 2041
					0 -- 2041
				) -- 2041
				drawnInv = drawnInv + 1 -- 2042
			end -- 2042
			::__continue270:: -- 2042
			ii = ii + 1 -- 2026
		end -- 2026
	end -- 2026
	if drawnInv == 0 then -- 2026
		ctx.texts:put( -- 2045
			"xs", -- 2045
			"行囊尚空，沿途可拾筹材与战备。", -- 2045
			leftX, -- 2045
			invTitleY - 28, -- 2045
			toColor(PALETTE.xuanInkSub), -- 2045
			0, -- 2045
			0.5, -- 2045
			"Left", -- 2045
			0.6, -- 2045
			0.78 * appear, -- 2045
			0 -- 2045
		) -- 2045
	end -- 2045
	local rightX = foldX + 20 -- 2049
	local rightW = inX + inW - rightX - 18 -- 2050
	ctx.texts:put( -- 2051
		"sm", -- 2051
		"已习本领谱", -- 2051
		rightX, -- 2051
		secTopY, -- 2051
		toColor(PALETTE.rouge), -- 2051
		0, -- 2051
		0.5, -- 2051
		"Left", -- 2051
		1.6, -- 2051
		0.92 * appear, -- 2051
		0 -- 2051
	) -- 2051
	local learned = {} -- 2053
	for k in pairs(rg.ranks) do -- 2054
		if (rg.ranks[k] or 0) > 0 then -- 2054
			learned[#learned + 1] = k -- 2056
		end -- 2056
	end -- 2056
	if #learned == 0 then -- 2056
		ctx.texts:put( -- 2060
			"sm", -- 2060
			"尚未择筹 · 途中整备可习军筹", -- 2060
			rightX, -- 2060
			secTopY - 56, -- 2060
			toColor(PALETTE.xuanInkSub), -- 2060
			0, -- 2060
			0.5, -- 2060
			"Left", -- 2060
			0.8, -- 2060
			0.82 * appear, -- 2060
			0 -- 2060
		) -- 2060
	else -- 2060
		local li = 0 -- 2062
		do -- 2062
			li = 0 -- 2063
			while li < #learned and li < 5 do -- 2063
				local tid = learned[li + 1] -- 2064
				local rank = rg.ranks[tid] or 1 -- 2065
				local meta = resolveTalentVisual(tid, rg) -- 2066
				local rowY = secTopY - 46 - li * 56 -- 2067
				uiInkDraw:drawRect( -- 2068
					Rect(rightX, rowY - 22, rightW, 46), -- 2068
					Color( -- 2068
						32, -- 2068
						30, -- 2068
						32, -- 2068
						math.floor(12 * appear + 0.5) -- 2068
					), -- 2068
					0.75, -- 2068
					redFaint -- 2068
				) -- 2068
				drawTalentGlyph( -- 2069
					uiInkDraw, -- 2069
					rightX + 24, -- 2069
					rowY + 1, -- 2069
					13, -- 2069
					tid, -- 2069
					PALETTE.xuanInk, -- 2069
					0.92 * appear, -- 2069
					PALETTE.rouge -- 2069
				) -- 2069
				ctx.texts:put( -- 2070
					"sm", -- 2070
					((meta.title .. " · ") .. rankChinese(rank)) .. "阶", -- 2070
					rightX + 48, -- 2070
					rowY + 10, -- 2070
					toColor(PALETTE.xuanInk), -- 2070
					0, -- 2070
					0.5, -- 2070
					"Left", -- 2070
					1, -- 2070
					0.96 * appear, -- 2070
					0 -- 2070
				) -- 2070
				ctx.texts:put( -- 2071
					"xs", -- 2071
					meta:ledgerLine(rg, rank), -- 2071
					rightX + 48, -- 2071
					rowY - 10, -- 2071
					toColor(PALETTE.xuanInkSub), -- 2071
					0, -- 2071
					0.5, -- 2071
					"Left", -- 2071
					0.4, -- 2071
					0.88 * appear, -- 2071
					0 -- 2071
				) -- 2071
				li = li + 1 -- 2063
			end -- 2063
		end -- 2063
	end -- 2063
	local march = deriveMarchTitle(rg) -- 2076
	local footY = inY + 46 -- 2077
	uiInkDraw:drawSegment( -- 2078
		Vec2(rightX, footY + 36), -- 2078
		Vec2(rightX + rightW, footY + 36), -- 2078
		0.7, -- 2078
		redFaint -- 2078
	) -- 2078
	ctx.texts:put( -- 2079
		"xs", -- 2079
		"此行雅号", -- 2079
		rightX, -- 2079
		footY + 20, -- 2079
		toColor(PALETTE.xuanInkSub), -- 2079
		0, -- 2079
		0.5, -- 2079
		"Left", -- 2079
		1.4, -- 2079
		0.82 * appear, -- 2079
		0 -- 2079
	) -- 2079
	ctx.texts:put( -- 2080
		"md", -- 2080
		("「" .. march.title) .. "」", -- 2080
		rightX - 4, -- 2080
		footY - 2, -- 2080
		toColor(PALETTE.xuanInk), -- 2080
		0, -- 2080
		0.5, -- 2080
		"Left", -- 2080
		2.2, -- 2080
		0.96 * appear, -- 2080
		0 -- 2080
	) -- 2080
	ctx.texts:put( -- 2081
		"xs", -- 2081
		march.subtitle, -- 2081
		rightX + 4, -- 2081
		footY - 24, -- 2081
		toColor(PALETTE.xuanInkSub), -- 2081
		0, -- 2081
		0.5, -- 2081
		"Left", -- 2081
		0.8, -- 2081
		0.86 * appear, -- 2081
		0 -- 2081
	) -- 2081
	drawLoneSeal( -- 2082
		uiInkDraw, -- 2083
		uiArt, -- 2084
		ctx.texts, -- 2085
		"rg_ledger_seal", -- 2086
		rightX + rightW - 22, -- 2087
		footY + 2, -- 2088
		24, -- 2089
		46, -- 2090
		march.sealTop, -- 2091
		march.sealBot, -- 2092
		PALETTE.sealRed, -- 2093
		PALETTE.sealText, -- 2094
		0.94 * appear, -- 2095
		5 -- 2096
	) -- 2096
end -- 1896
return ____exports -- 1896