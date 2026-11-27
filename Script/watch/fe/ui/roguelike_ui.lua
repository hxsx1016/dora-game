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
function RoguelikeUiPlugin.prototype.____constructor(self, contract, getHudSelected, setHudSelected) -- 286
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
	self.prevKeyV = false -- 261
	self.prevKeyEsc = false -- 262
	self.prevKeyBack = false -- 263
	self.prevLeftDown = false -- 264
	self.pickupBounceMap = {} -- 267
	self.pickupShakeMap = {} -- 268
	self.pickupPops = {} -- 269
	self.lastSuppliesShown = {} -- 270
	self.segmentBannerT = 0 -- 273
	self.segmentBannerHeadline = "" -- 274
	self.segmentBannerSub = "" -- 275
	self.deathSelected = 0 -- 276
	self.deathRecapT = 0 -- 277
	self.lastMarchTitle = "初启北行" -- 281
	self.lastGuardArcActive = false -- 282
	self.lastReloadArcActive = false -- 283
	self.lastCraftRingActive = false -- 284
	self.contract = contract -- 291
	self.getHudSelected = getHudSelected -- 292
	self.setHudSelected = setHudSelected -- 293
end -- 286
function RoguelikeUiPlugin.prototype.canPickTalent(self) -- 296
	return not self.ledgerOpen and self.deathRecapT <= 0.15 and (self.drawerState == "expanded" or self.drawerState == "compact") -- 297
end -- 296
function RoguelikeUiPlugin.prototype.isExpanded(self) -- 301
	return self.drawerState == "expanded" -- 302
end -- 301
function RoguelikeUiPlugin.prototype.isLedgerOpen(self) -- 305
	return self.ledgerOpen -- 306
end -- 305
function RoguelikeUiPlugin.prototype.isModalOverlayActive(self) -- 310
	return self.ledgerOpen or self.deathRecapT > 0.05 -- 311
end -- 310
function RoguelikeUiPlugin.prototype.isSuppressingRoomBanner(self) -- 315
	return self.ledgerOpen or self.deathRecapT > 0.05 or self.drawerState == "expanded" or self.drawerState == "sealing" or self.segmentBannerT > 0.05 -- 316
end -- 315
function RoguelikeUiPlugin.prototype.openLedger(self) -- 323
	self.ledgerOpen = true -- 324
	self.ledgerAnimT = 0 -- 325
end -- 323
function RoguelikeUiPlugin.prototype.closeLedger(self) -- 328
	self.ledgerOpen = false -- 329
end -- 328
function RoguelikeUiPlugin.prototype.toggleLedger(self) -- 332
	if self.ledgerOpen then -- 332
		self:closeLedger() -- 334
	else -- 334
		self:openLedger() -- 336
	end -- 336
end -- 332
function RoguelikeUiPlugin.prototype.setCompact(self, compact) -- 340
	self.manualCompact = compact -- 341
	if #self.lastOffers > 0 and self.sealAnim == nil then -- 341
		self.drawerState = compact and "compact" or "expanded" -- 343
		if not compact then -- 343
			self.expandAnimT = 0 -- 345
			self.staggerTime = 0 -- 346
		end -- 346
	end -- 346
end -- 340
function RoguelikeUiPlugin.prototype.triggerTestDeathRecap(self, roomKey, ranks, weapon) -- 352
	if weapon == nil then -- 352
		weapon = "standard_gun" -- 352
	end -- 352
	self:showDeathRecap(roomKey, ranks, weapon, 0) -- 353
end -- 352
function RoguelikeUiPlugin.prototype.showDeathRecap(self, roomKey, ranks, weapon, seed) -- 356
	local total = 0 -- 357
	local copy = {} -- 358
	for k in pairs(ranks) do -- 359
		if ranks[k] > 0 then -- 359
			copy[k] = ranks[k] -- 361
			total = total + ranks[k] -- 362
		end -- 362
	end -- 362
	self.deathRecapSnap = { -- 365
		roomKey = roomKey, -- 366
		stageName = stageReadableName(roomKey), -- 367
		ranks = copy, -- 368
		totalRanks = total, -- 369
		weaponId = weapon, -- 370
		seed = seed -- 371
	} -- 371
	self.deathRecapT = DEATH_RECAP_DURATION -- 373
end -- 356
function RoguelikeUiPlugin.prototype.triggerTestSegmentBanner(self, roomKey, nextKey) -- 377
	if nextKey == nil then -- 377
		nextKey = "" -- 377
	end -- 377
	self.segmentBannerHeadline = stageOrderNumeral(roomKey) .. "程告破" -- 378
	self.segmentBannerSub = nextKey ~= "" and "渐近北塔 · 前往" .. themeOf(nextKey).shortNameZh or "渐近北塔 · 筹策犹在" -- 379
	self.segmentBannerT = SEGMENT_BANNER_DURATION -- 380
end -- 377
function RoguelikeUiPlugin.prototype.getTalentCardRects(self, uiW, uiH, count, touchMode, safeTop) -- 384
	if touchMode == nil then -- 384
		touchMode = false -- 388
	end -- 388
	if safeTop == nil then -- 388
		safeTop = 0 -- 389
	end -- 389
	if not self:canPickTalent() then -- 389
		return {} -- 391
	end -- 391
	local useExpanded = self.drawerState ~= "compact" -- 392
	return ____exports.computeRoguelikeCardRects( -- 393
		uiW, -- 393
		uiH, -- 393
		count, -- 393
		useExpanded, -- 393
		touchMode, -- 393
		safeTop -- 393
	) -- 393
end -- 384
function RoguelikeUiPlugin.prototype.getLedgerButtonRect(self) -- 396
	return self.ledgerButtonBox -- 397
end -- 396
function RoguelikeUiPlugin.prototype.getExpandToggleRect(self) -- 400
	return self.expandToggleBox -- 401
end -- 400
function RoguelikeUiPlugin.prototype.getState(self) -- 404
	return { -- 405
		drawerState = self.drawerState, -- 406
		offers = __TS__ArraySlice(self.lastOffers), -- 407
		focusedSlot = self.focusedSlot, -- 408
		focusTimeScale = self.focusScale, -- 409
		ledgerOpen = self.ledgerOpen, -- 410
		sealingActive = self.drawerState == "sealing", -- 411
		absorbingActive = self.drawerState == "absorbing", -- 412
		segmentBannerActive = self.segmentBannerT > 0.01, -- 413
		deathRecapActive = self.deathRecapT > 0.01, -- 414
		deathRecapRoom = self.deathRecapSnap ~= nil and self.deathRecapSnap.roomKey or "", -- 415
		deathRecapCount = self.deathRecapSnap ~= nil and self.deathRecapSnap.totalRanks or 0, -- 416
		marchTitle = self.lastMarchTitle, -- 417
		suppliesShown = __TS__ArraySlice(self.lastSuppliesShown), -- 418
		activeGuardArc = self.lastGuardArcActive, -- 419
		activeReloadArc = self.lastReloadArcActive, -- 420
		activeCraftRing = self.lastCraftRingActive, -- 421
		lastCardBoxes = __TS__ArraySlice(self.lastCardBoxes), -- 422
		ledgerButtonBox = self.ledgerButtonBox, -- 423
		expandToggleBox = self.expandToggleBox -- 424
	} -- 424
end -- 404
function RoguelikeUiPlugin.prototype.onBindPlay(self, _p, view) -- 428
	self.deathRecapSnap = nil -- 429
	self.deathRecapT = 0 -- 430
	self.deathSelected = 0 -- 431
	local rg = view.roguelike -- 432
	self.manualCompact = false -- 433
	self.expandAnimT = 0 -- 434
	self.staggerTime = 0 -- 435
	self.idleSinceMove = 0 -- 436
	self.hoverSlot = -1 -- 437
	self.focusedSlot = 0 -- 438
	self.cardLiftT = {0, 0, 0} -- 439
	self.sealAnim = nil -- 440
	self.ledgerOpen = false -- 441
	self.ledgerAnimT = 0 -- 442
	self.pickupBounceMap = {} -- 443
	self.pickupShakeMap = {} -- 444
	self.pickupPops = {} -- 445
	self.crestPulseMap = {} -- 446
	self.hpBarPulseT = 0 -- 447
	self.xiaomanRippleT = 0 -- 448
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 449
	self.lastRanks = {} -- 450
	for k in pairs(rg.ranks) do -- 451
		self.lastRanks[k] = rg.ranks[k] -- 452
	end -- 452
	self.drawerState = #rg.offers > 0 and "expanded" or "hidden" -- 454
	self.focusScale = 1 -- 455
	if self.contract ~= nil then -- 455
		self.contract:setFocusTimeScale(1) -- 457
	end -- 457
	self:resetInputEdges() -- 459
end -- 428
function RoguelikeUiPlugin.prototype.resetInputEdges(self) -- 463
	if getActiveTarget().supportsKbm and type(Keyboard) ~= "nil" then -- 463
		self.prevKeyV = Keyboard:isKeyPressed("V") -- 465
		self.prevKeyEsc = Keyboard:isKeyPressed("Escape") -- 466
		self.prevKeyBack = Keyboard:isKeyPressed("BackSpace") -- 467
	end -- 467
	local ____temp_0 -- 469
	if getActiveTarget().supportsKbm and type(Mouse) ~= "nil" then -- 469
		____temp_0 = Mouse.leftButtonPressed -- 469
	else -- 469
		____temp_0 = false -- 469
	end -- 469
	self.prevLeftDown = ____temp_0 -- 469
end -- 463
function RoguelikeUiPlugin.prototype.startSealAnimation(self, talentId, ctx) -- 472
	local pickedSlot = __TS__ArrayIndexOf(self.lastOffers, talentId) -- 473
	if pickedSlot < 0 then -- 473
		pickedSlot = clamp( -- 475
			self.focusedSlot, -- 475
			0, -- 475
			math.max(0, #self.lastOffers - 1) -- 475
		) -- 475
	end -- 475
	local boxes = #self.lastCardBoxes > 0 and __TS__ArraySlice(self.lastCardBoxes) or ____exports.computeRoguelikeCardRects( -- 477
		ctx.uiW, -- 480
		ctx.uiH, -- 481
		math.max(1, #self.lastOffers), -- 482
		self.drawerState ~= "compact", -- 483
		ctx.input:isTouchMode(), -- 484
		(ctx.safeUi or ZERO_SAFE_INSETS).top -- 485
	) -- 485
	local pickedBox = boxes[pickedSlot + 1] or Rect(ctx.uiW * 0.5 - 100, ctx.uiH * 0.5 - 60, 200, 120) -- 487
	local meta = resolveTalentVisual(talentId, ctx.view.roguelike) -- 488
	self.sealAnim = { -- 489
		talentId = talentId, -- 490
		pickedSlot = pickedSlot, -- 491
		pickedBox = pickedBox, -- 492
		allBoxes = boxes, -- 493
		allOffers = __TS__ArraySlice(self.lastOffers), -- 494
		elapsed = 0, -- 495
		sealDuration = SEAL_DURATION, -- 496
		absorbDuration = ABSORB_DURATION, -- 497
		targetKind = meta.absorbTarget, -- 498
		fromExpanded = self.drawerState ~= "compact", -- 499
		arrivedPulsed = false -- 500
	} -- 500
	self.drawerState = "sealing" -- 502
	self.hoverSlot = -1 -- 503
	ctx.input:vibrate(0.024) -- 504
	if ctx.view.backCarry.active then -- 504
		self.xiaomanRippleT = 0.78 -- 506
	end -- 506
end -- 472
function RoguelikeUiPlugin.prototype.detectPickedTalentFromRankDiff(self, nowRanks) -- 510
	for k in pairs(nowRanks) do -- 511
		if (nowRanks[k] or 0) > (self.lastRanks[k] or 0) then -- 511
			return k -- 513
		end -- 513
	end -- 513
	return self.lastOffers[clamp( -- 516
		self.focusedSlot, -- 516
		0, -- 516
		math.max(0, #self.lastOffers - 1) -- 516
	) + 1] or "" -- 516
end -- 510
function RoguelikeUiPlugin.prototype.update(self, ctx) -- 519
	local rg = ctx.view.roguelike -- 520
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 521
	local touchMode = ctx.input:isTouchMode() -- 522
	self.lastUiW = ctx.uiW -- 523
	self.lastUiH = ctx.uiH -- 524
	self.lastTouchMode = touchMode -- 525
	self.lastSafeTop = safe.top -- 526
	self.lastMarchTitle = deriveMarchTitle(rg).title -- 527
	if ctx.paused then -- 527
		self:resetInputEdges() -- 531
		return -- 532
	end -- 532
	local udt = math.max(0, ctx.uiDt) -- 535
	self.animTime = self.animTime + udt -- 536
	if ctx.events.segmentDone and ctx.events.segmentKey ~= "" then -- 536
		self.segmentBannerHeadline = stageOrderNumeral(ctx.events.segmentKey) .. "程告破" -- 540
		self.segmentBannerSub = ctx.events.segmentNext ~= "" and "渐近北塔 · 前往" .. themeOf(ctx.events.segmentNext).shortNameZh or "渐近北塔 · 筹策犹在" -- 541
		self.segmentBannerT = SEGMENT_BANNER_DURATION -- 544
	end -- 544
	local summary = ctx.p.escortSummary -- 547
	if ctx.p.escortFailed and summary and self.deathRecapSnap == nil then -- 547
		self:showDeathRecap(summary.roomKey, summary.ranks, summary.equippedWeapon, summary.seed) -- 549
		self:closeLedger() -- 550
	end -- 550
	local fallen = ctx.events.fallenBuild -- 552
	if ctx.events.campaignFailedReset and fallen ~= nil then -- 552
		self:showDeathRecap(ctx.events.campaignFailedRoom, fallen.ranks, fallen.weaponId, fallen.seed) -- 554
		self:closeLedger() -- 555
	end -- 555
	if ctx.events.pickupTaken and ctx.events.pickupKind ~= "" then -- 555
		self.pickupBounceMap[ctx.events.pickupKind] = 0.52 -- 559
		local ____self_pickupPops_1 = self.pickupPops -- 559
		____self_pickupPops_1[#____self_pickupPops_1 + 1] = {kind = ctx.events.pickupKind, timer = 0.72, maxTimer = 0.72} -- 560
		if #self.pickupPops > 6 then -- 560
			table.remove(self.pickupPops, 1) -- 562
		end -- 562
	end -- 562
	if ctx.events.pickupRejected and ctx.events.pickupRejectedKind ~= "" then -- 562
		self.pickupShakeMap[ctx.events.pickupRejectedKind] = 0.42 -- 566
	end -- 566
	if self.segmentBannerT > 0 then -- 566
		self.segmentBannerT = math.max(0, self.segmentBannerT - udt) -- 571
	end -- 571
	if self.hpBarPulseT > 0 then -- 571
		self.hpBarPulseT = math.max(0, self.hpBarPulseT - udt) -- 574
	end -- 574
	if self.xiaomanRippleT > 0 then -- 574
		self.xiaomanRippleT = math.max(0, self.xiaomanRippleT - udt) -- 577
	end -- 577
	for k in pairs(self.crestPulseMap) do -- 579
		if self.crestPulseMap[k] > 0 then -- 579
			self.crestPulseMap[k] = math.max(0, self.crestPulseMap[k] - udt) -- 581
		end -- 581
	end -- 581
	for k in pairs(self.pickupBounceMap) do -- 584
		if self.pickupBounceMap[k] > 0 then -- 584
			self.pickupBounceMap[k] = math.max(0, self.pickupBounceMap[k] - udt) -- 586
		end -- 586
	end -- 586
	for k in pairs(self.pickupShakeMap) do -- 589
		if self.pickupShakeMap[k] > 0 then -- 589
			self.pickupShakeMap[k] = math.max(0, self.pickupShakeMap[k] - udt) -- 591
		end -- 591
	end -- 591
	local pi = 0 -- 594
	local pw = 0 -- 595
	do -- 595
		pi = 0 -- 596
		while pi < #self.pickupPops do -- 596
			local pop = self.pickupPops[pi + 1] -- 597
			pop.timer = pop.timer - udt -- 598
			if pop.timer > 0 then -- 598
				self.pickupPops[pw + 1] = pop -- 600
				pw = pw + 1 -- 601
			end -- 601
			pi = pi + 1 -- 596
		end -- 596
	end -- 596
	__TS__ArraySetLength(self.pickupPops, pw) -- 596
	if self.deathRecapT > 0 then -- 596
		local elapsedRecap = DEATH_RECAP_DURATION - self.deathRecapT -- 608
		local wantSkip = elapsedRecap > 0.25 and (math.abs(ctx.input.moveX) > 0.2 or ctx.input.uiPressed or ctx.input.fire.pressed or ctx.input.interact.pressed or ctx.input.navConfirm) -- 609
		self.deathRecapT = math.max(ctx.p.escortFailed and 0.5 or 0, self.deathRecapT - udt * (wantSkip and 4.2 or 1)) -- 616
	end -- 616
	local hadOffers = #self.lastOffers > 0 -- 620
	local hasOffers = #rg.offers > 0 -- 621
	if ctx.events.talentPicked and ctx.events.talentPickedId ~= "" then -- 621
		self:startSealAnimation(ctx.events.talentPickedId, ctx) -- 623
	elseif hadOffers and not hasOffers and self.sealAnim == nil then -- 623
		local diffId = self:detectPickedTalentFromRankDiff(rg.ranks) -- 625
		if diffId ~= "" then -- 625
			self:startSealAnimation(diffId, ctx) -- 627
		end -- 627
	elseif not hadOffers and hasOffers then -- 627
		self.sealAnim = nil -- 631
		self.drawerState = "expanded" -- 632
		self.manualCompact = false -- 633
		self.expandAnimT = 0 -- 634
		self.staggerTime = 0 -- 635
		self.idleSinceMove = 0 -- 636
		self.hoverSlot = -1 -- 637
		self.cardLiftT = {} -- 638
		local ci = 0 -- 639
		do -- 639
			ci = 0 -- 640
			while ci < #rg.offers do -- 640
				local ____self_cardLiftT_2 = self.cardLiftT -- 640
				____self_cardLiftT_2[#____self_cardLiftT_2 + 1] = 0 -- 641
				ci = ci + 1 -- 640
			end -- 640
		end -- 640
		ctx.audio:playUi("ui:talent_appear", "assets/audio/ui/talent_appear.wav", 0.68, 0.25) -- 643
	end -- 643
	if self.sealAnim ~= nil then -- 643
		local ____self_sealAnim_3, ____elapsed_4 = self.sealAnim, "elapsed" -- 643
		____self_sealAnim_3[____elapsed_4] = ____self_sealAnim_3[____elapsed_4] + udt -- 648
		local totalDur = self.sealAnim.sealDuration + self.sealAnim.absorbDuration -- 649
		if self.sealAnim.elapsed < self.sealAnim.sealDuration then -- 649
			self.drawerState = "sealing" -- 651
		elseif self.sealAnim.elapsed < totalDur then -- 651
			self.drawerState = "absorbing" -- 653
		else -- 653
			if not self.sealAnim.arrivedPulsed then -- 653
				self.sealAnim.arrivedPulsed = true -- 656
				self.crestPulseMap[self.sealAnim.talentId] = 0.72 -- 657
				if self.sealAnim.targetKind == "hp" then -- 657
					self.hpBarPulseT = 0.7 -- 659
				end -- 659
			end -- 659
			self.sealAnim = nil -- 662
			self.drawerState = hasOffers and (self.manualCompact and "compact" or "expanded") or "hidden" -- 663
		end -- 663
	elseif not hasOffers then -- 663
		self.drawerState = "hidden" -- 666
	end -- 666
	local modalBlocking = ctx.p.escortFailed or ctx.view.reloadSession.active or ctx.view.craftBench.active -- 670
	self:processLedgerAndCardInputs(ctx, rg, modalBlocking) -- 671
	if self.sealAnim == nil and hasOffers then -- 671
		local movingOrActing = math.abs(ctx.input.moveX) > 0.15 or math.abs(ctx.input.moveY) > 0.15 or ctx.input.jump.pressed or ctx.input.fire.pressed and self.hoverSlot < 0 or modalBlocking -- 674
		if self.drawerState == "expanded" then -- 674
			self.expandAnimT = math.min(1, self.expandAnimT + udt / 0.22) -- 680
			self.staggerTime = self.staggerTime + udt -- 681
			if movingOrActing then -- 681
				self.drawerState = "compact" -- 683
				self.idleSinceMove = 0 -- 684
			end -- 684
		elseif self.drawerState == "compact" then -- 684
			if movingOrActing or ctx.input.fire.held or self.ledgerOpen or self.deathRecapT > 0.05 then -- 684
				self.idleSinceMove = 0 -- 688
			elseif not self.manualCompact then -- 688
				self.idleSinceMove = self.idleSinceMove + udt -- 690
				if self.idleSinceMove >= AUTO_REEXPAND_IDLE_SEC then -- 690
					self.drawerState = "expanded" -- 692
					self.expandAnimT = 0 -- 693
					self.staggerTime = 0 -- 694
					self.idleSinceMove = 0 -- 695
				end -- 695
			end -- 695
		end -- 695
	end -- 695
	while #self.cardLiftT < #rg.offers do -- 695
		local ____self_cardLiftT_5 = self.cardLiftT -- 695
		____self_cardLiftT_5[#____self_cardLiftT_5 + 1] = 0 -- 703
	end -- 703
	local li = 0 -- 705
	do -- 705
		li = 0 -- 706
		while li < #rg.offers do -- 706
			local isHot = ctx.input.inputMode == "gamepad" and li == self.focusedSlot or ctx.input.inputMode ~= "gamepad" and li == self.hoverSlot -- 707
			local target = isHot and 1 or 0 -- 709
			local ____self_cardLiftT_6, ____temp_7 = self.cardLiftT, li + 1 -- 709
			____self_cardLiftT_6[____temp_7] = ____self_cardLiftT_6[____temp_7] + (target - self.cardLiftT[li + 1]) * math.min(1, udt * 14) -- 710
			li = li + 1 -- 706
		end -- 706
	end -- 706
	local wantSlowFocus = not modalBlocking and self.deathRecapT <= 0.05 and (self.ledgerOpen or self.drawerState == "expanded" and hasOffers) -- 714
	local targetScale = wantSlowFocus and EXPANDED_FOCUS_SCALE or 1 -- 717
	local speed = wantSlowFocus and 5.2 or 6 -- 718
	if self.focusScale < targetScale then -- 718
		self.focusScale = math.min(targetScale, self.focusScale + udt * speed) -- 720
	elseif self.focusScale > targetScale then -- 720
		self.focusScale = math.max(targetScale, self.focusScale - udt * speed) -- 722
	end -- 722
	if self.contract ~= nil then -- 722
		self.contract:setFocusTimeScale(self.focusScale) -- 725
	end -- 725
	if not ctx.view.reloadSession.active then -- 725
		ctx.audio:setWorldPlaySpeed(math.max( -- 728
			0.25, -- 728
			math.min(1, self.focusScale) -- 728
		)) -- 728
	end -- 728
	if self.ledgerOpen then -- 728
		self.ledgerAnimT = math.min(1, self.ledgerAnimT + udt / 0.2) -- 732
	end -- 732
	self.lastOffers = __TS__ArraySlice(rg.offers) -- 736
	self.lastRanks = {} -- 737
	for k in pairs(rg.ranks) do -- 738
		self.lastRanks[k] = rg.ranks[k] -- 739
	end -- 739
	if hasOffers then -- 739
		self.lastCardBoxes = self:getTalentCardRects( -- 742
			ctx.uiW, -- 742
			ctx.uiH, -- 742
			#rg.offers, -- 742
			touchMode, -- 742
			safe.top -- 742
		) -- 742
	else -- 742
		self.lastCardBoxes = {} -- 744
	end -- 744
end -- 519
function RoguelikeUiPlugin.prototype.processLedgerAndCardInputs(self, ctx, rg, modalBlocking) -- 748
	local touchMode = ctx.input:isTouchMode() -- 753
	local useUiPtr = ctx.input.uiInside or ctx.input.uiPressed or ctx.input.uiHeld -- 754
	local ptrX = (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 755
	local ptrY = (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 756
	local ____useUiPtr_8 -- 757
	if useUiPtr then -- 757
		____useUiPtr_8 = ctx.input.uiInside -- 757
	else -- 757
		____useUiPtr_8 = ctx.input.inside -- 757
	end -- 757
	local inside = ____useUiPtr_8 -- 757
	local ptr = Vec2(ptrX, ptrY) -- 758
	local mouseLeftDown = ctx.input.inputMode == "kbm" and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 760
	local leftClick = ctx.input.uiPressed or mouseLeftDown and not self.prevLeftDown -- 761
	self.prevLeftDown = mouseLeftDown -- 762
	local vPressed = false -- 764
	local escPressed = false -- 765
	local backPressed = false -- 766
	if getActiveTarget().supportsKbm and type(Keyboard) ~= "nil" then -- 766
		local vDown = Keyboard:isKeyPressed("V") -- 768
		local escDown = Keyboard:isKeyPressed("Escape") -- 769
		local backDown = Keyboard:isKeyPressed("BackSpace") -- 770
		vPressed = vDown and not self.prevKeyV -- 771
		escPressed = escDown and not self.prevKeyEsc -- 772
		backPressed = backDown and not self.prevKeyBack -- 773
		self.prevKeyV = vDown -- 774
		self.prevKeyEsc = escDown -- 775
		self.prevKeyBack = backDown -- 776
	end -- 776
	if ctx.input.touchZoneTap == "ledger:toggle" and rg.active and not modalBlocking then -- 776
		ctx.input.touchZoneTap = "" -- 781
		self:toggleLedgerWithSound(ctx) -- 782
		return -- 783
	end -- 783
	if vPressed and rg.active and not modalBlocking then -- 783
		self:toggleLedgerWithSound(ctx) -- 788
		return -- 789
	end -- 789
	if self.ledgerOpen then -- 789
		if modalBlocking or escPressed or backPressed or ctx.input.navBack then -- 789
			self.ledgerOpen = false -- 794
			ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 795
			return -- 796
		end -- 796
		if leftClick and inside then -- 796
			if self.ledgerCloseBox:containsPoint(ptr) or not self.ledgerPanelBox:containsPoint(ptr) then -- 796
				self.ledgerOpen = false -- 800
				ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 801
			end -- 801
		end -- 801
		return -- 804
	end -- 804
	if rg.active and not modalBlocking and leftClick and inside and self.ledgerButtonBox.width > 0 and self.ledgerButtonBox:containsPoint(ptr) then -- 804
		self:toggleLedgerWithSound(ctx) -- 810
		return -- 811
	end -- 811
	if #rg.offers > 0 and not modalBlocking and leftClick and inside and self.expandToggleBox.width > 0 and self.expandToggleBox:containsPoint(ptr) then -- 811
		local nextCompact = self.drawerState == "expanded" -- 817
		self:setCompact(nextCompact) -- 818
		ctx.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 819
		return -- 820
	end -- 820
	if #rg.offers > 0 and not modalBlocking and self.sealAnim == nil then -- 820
		if ctx.input.inputMode == "gamepad" then -- 820
			local hudSel = self.getHudSelected ~= nil and self.getHudSelected() or self.focusedSlot -- 826
			local clamped = clamp(hudSel, 0, #rg.offers - 1) -- 827
			if clamped ~= self.focusedSlot then -- 827
				self.focusedSlot = clamped -- 829
				ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 830
			end -- 830
			self.hoverSlot = -1 -- 832
		elseif not touchMode and inside then -- 832
			local boxes = self:getTalentCardRects( -- 834
				ctx.uiW, -- 834
				ctx.uiH, -- 834
				#rg.offers, -- 834
				false, -- 834
				(ctx.safeUi or ZERO_SAFE_INSETS).top -- 834
			) -- 834
			local hit = -1 -- 835
			local i = 0 -- 836
			do -- 836
				i = 0 -- 837
				while i < #boxes do -- 837
					if boxes[i + 1]:containsPoint(ptr) then -- 837
						hit = i -- 839
						break -- 840
					end -- 840
					i = i + 1 -- 837
				end -- 837
			end -- 837
			if hit ~= self.hoverSlot then -- 837
				self.hoverSlot = hit -- 844
				if hit >= 0 then -- 844
					self.focusedSlot = hit -- 846
					if self.setHudSelected ~= nil then -- 846
						self.setHudSelected(hit) -- 848
					end -- 848
					ctx.audio:playUi("ui:talent_hover", "assets/audio/ui/menu_hover.wav", 0.44, 0.045) -- 850
				end -- 850
			end -- 850
		else -- 850
			self.hoverSlot = -1 -- 854
		end -- 854
	else -- 854
		self.hoverSlot = -1 -- 857
	end -- 857
end -- 748
function RoguelikeUiPlugin.prototype.toggleLedgerWithSound(self, ctx) -- 861
	if self.ledgerOpen then -- 861
		self.ledgerOpen = false -- 863
		ctx.audio:playUi("ui:ledger_close", "assets/audio/ui/pause_close.wav", 0.54, 0.08) -- 864
	else -- 864
		self.ledgerOpen = true -- 866
		self.ledgerAnimT = 0 -- 867
		ctx.audio:playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08) -- 868
	end -- 868
end -- 861
function RoguelikeUiPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 874
	local p = ctx.p -- 880
	local rg = ctx.view.roguelike -- 881
	local cam = ctx.cam -- 882
	self.lastGuardArcActive = false -- 884
	self.lastReloadArcActive = false -- 885
	self.lastCraftRingActive = false -- 886
	if ctx.view.visualMode == "museum" then -- 886
		return -- 889
	end -- 889
	local bi = 0 -- 893
	do -- 893
		bi = 0 -- 894
		while bi < #p.boxes do -- 894
			do -- 894
				local b = p.boxes[bi + 1] -- 895
				if b.broken == true or b.hidden == true or b.id == nil then -- 895
					goto __continue147 -- 897
				end -- 897
				local ps = p.run.props[b.id] -- 899
				if ps == nil then -- 899
					goto __continue147 -- 901
				end -- 901
				local depth = b.depth ~= nil and (b.depth.min + b.depth.max) * 0.5 or 0 -- 903
				local x0 = cam:sx(b.x0) -- 904
				local x1 = cam:sx(b.x1) -- 905
				local y0 = cam:sy(b.y0, depth) -- 906
				local y1 = cam:sy(b.y1, depth) -- 907
				local bw = x1 - x0 -- 908
				local bh = y1 - y0 -- 909
				if bw <= 2 or bh <= 2 then -- 909
					goto __continue147 -- 911
				end -- 911
				if ps.wedge == true then -- 911
					local ww = math.max( -- 915
						6, -- 915
						cam:len(6.5) -- 915
					) -- 915
					local wh = math.max( -- 916
						7, -- 916
						cam:len(8) -- 916
					) -- 916
					fgDraw:drawPolygon( -- 917
						{ -- 917
							Vec2(x0 - ww * 0.7, y0), -- 918
							Vec2(x0 + ww * 0.45, y0), -- 919
							Vec2(x0 + ww * 0.2, y0 + wh), -- 920
							Vec2(x0 - ww * 0.25, y0 + wh * 0.55) -- 921
						}, -- 921
						toColor(PALETTE.emerald, 220), -- 922
						1.1, -- 922
						toColor(PALETTE.moonPale, 220) -- 922
					) -- 922
					fgDraw:drawPolygon( -- 923
						{ -- 923
							Vec2(x1 + ww * 0.7, y0), -- 924
							Vec2(x1 - ww * 0.45, y0), -- 925
							Vec2(x1 - ww * 0.2, y0 + wh), -- 926
							Vec2(x1 + ww * 0.25, y0 + wh * 0.55) -- 927
						}, -- 927
						toColor(PALETTE.emerald, 220), -- 928
						1.1, -- 928
						toColor(PALETTE.moonPale, 220) -- 928
					) -- 928
					fgDraw:drawSegment( -- 929
						Vec2(x0 + 2, y1 - 1), -- 929
						Vec2(x1 - 2, y1 - 1), -- 929
						1.6, -- 929
						toColor(PALETTE.emerald, 210) -- 929
					) -- 929
				end -- 929
				if ps.hp == 1 and not ps.broken then -- 929
					local mx = (x0 + x1) * 0.5 -- 933
					fgDraw:drawSegment( -- 934
						Vec2(mx - bw * 0.14, y1 - bh * 0.08), -- 934
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 934
						1.4, -- 934
						Color(14, 12, 16, 220) -- 934
					) -- 934
					fgDraw:drawSegment( -- 935
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 935
						Vec2(mx - bw * 0.08, y0 + bh * 0.14), -- 935
						1.3, -- 935
						Color(14, 12, 16, 220) -- 935
					) -- 935
					fgDraw:drawSegment( -- 936
						Vec2(mx + bw * 0.06, y0 + bh * 0.52), -- 936
						Vec2(mx + bw * 0.22, y0 + bh * 0.34), -- 936
						1, -- 936
						Color(214, 186, 146, 150) -- 936
					) -- 936
				end -- 936
			end -- 936
			::__continue147:: -- 936
			bi = bi + 1 -- 894
		end -- 894
	end -- 894
	if p.childMode or not p.player.alive then -- 894
		return -- 941
	end -- 941
	local pl = p.player -- 944
	local px = cam:sx(pl.x) -- 945
	local pyCenter = cam:sy(pl.y + pl.h * 0.56, pl.depth) -- 946
	local headY = cam:sy(pl.y + pl.h + 10, pl.depth) -- 947
	local facing = pl.facing >= 0 and 1 or -1 -- 948
	local guardRank = rg.ranks.guard or 0 -- 951
	if rg.activeInvulnTicks > 0 and guardRank > 0 then -- 951
		self.lastGuardArcActive = true -- 953
		local frac = clamp( -- 954
			rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 954
			0, -- 954
			1 -- 954
		) -- 954
		local arcR = math.max( -- 955
			18, -- 955
			cam:len(20) -- 955
		) -- 955
		local halfSpan = (0.35 + 0.85 * frac) * math.pi * 0.55 -- 956
		local baseAngle = facing > 0 and 0 or math.pi -- 957
		drawBrushArc( -- 958
			fgDraw, -- 959
			px + facing * cam:len(4), -- 960
			pyCenter, -- 961
			arcR, -- 962
			arcR * 1.18, -- 963
			baseAngle - halfSpan, -- 964
			baseAngle + halfSpan, -- 965
			2.4, -- 966
			toColor( -- 967
				PALETTE.emerald, -- 967
				math.floor(140 + 95 * frac + 0.5) -- 967
			), -- 967
			14 -- 968
		) -- 968
		drawBrushArc( -- 970
			fgGlow, -- 971
			px + facing * cam:len(4), -- 972
			pyCenter, -- 973
			arcR * 1.12, -- 974
			arcR * 1.28, -- 975
			baseAngle - halfSpan * 0.82, -- 976
			baseAngle + halfSpan * 0.82, -- 977
			1.3, -- 978
			toColor( -- 979
				PALETTE.moonPale, -- 979
				math.floor(90 * frac + 0.5) -- 979
			), -- 979
			12 -- 980
		) -- 980
	end -- 980
	if rg.activeReloadTicks > 0 and not ctx.view.reloadSession.active then -- 980
		self.lastReloadArcActive = true -- 986
		local totalRel = math.max(1, rg.reloadTicksNow) -- 987
		local prog = clamp(1 - rg.activeReloadTicks / totalRel, 0, 1) -- 988
		local rx = px + facing * cam:len(14) -- 989
		local ry = headY + cam:len(4) -- 990
		local rr = math.max( -- 991
			9, -- 991
			cam:len(10) -- 991
		) -- 991
		local hasReloadRank = (rg.ranks.focus or 0) > 0 -- 992
		local arcCol = hasReloadRank and PALETTE.amberCore or PALETTE.silkLine -- 993
		drawBrushArc( -- 994
			fgDraw, -- 994
			rx, -- 994
			ry, -- 994
			rr, -- 994
			rr, -- 994
			math.pi * 0.15, -- 994
			math.pi * 0.85, -- 994
			1.4, -- 994
			toColor(PALETTE.inkWash, 160), -- 994
			10 -- 994
		) -- 994
		local endA = math.pi * 0.85 - math.pi * 0.7 * prog -- 995
		drawBrushArc( -- 996
			fgDraw, -- 996
			rx, -- 996
			ry, -- 996
			rr, -- 996
			rr, -- 996
			endA, -- 996
			math.pi * 0.85, -- 996
			2.1, -- 996
			toColor(arcCol, 230), -- 996
			10 -- 996
		) -- 996
		if hasReloadRank then -- 996
			local sparkX = rx + math.cos(endA) * rr -- 998
			local sparkY = ry + math.sin(endA) * rr -- 999
			fgGlow:drawDot( -- 1000
				Vec2(sparkX, sparkY), -- 1000
				2.8, -- 1000
				toColor(PALETTE.amberCore, 240) -- 1000
			) -- 1000
			fillRadialGlow( -- 1001
				fgGlow, -- 1001
				sparkX, -- 1001
				sparkY, -- 1001
				9, -- 1001
				9, -- 1001
				toColor(PALETTE.amber, 70), -- 1001
				Color(214, 186, 146, 0), -- 1001
				10 -- 1001
			) -- 1001
		end -- 1001
	end -- 1001
	if rg.activeCraftTicks > 0 then -- 1001
		self.lastCraftRingActive = true -- 1007
		local totalCraft = math.max(1, rg.craftTicksNow) -- 1008
		local prog = clamp(rg.activeCraftTicks / totalCraft, 0, 1) -- 1009
		local cx = px + facing * cam:len(12) -- 1010
		local cy = headY + cam:len(8) -- 1011
		local cr = math.max( -- 1012
			11, -- 1012
			cam:len(12) -- 1012
		) -- 1012
		drawBrushArc( -- 1013
			fgDraw, -- 1013
			cx, -- 1013
			cy, -- 1013
			cr, -- 1013
			cr, -- 1013
			0, -- 1013
			TWO_PI, -- 1013
			1.5, -- 1013
			Color(14, 17, 25, 160), -- 1013
			16 -- 1013
		) -- 1013
		drawBrushArc( -- 1014
			fgDraw, -- 1014
			cx, -- 1014
			cy, -- 1014
			cr, -- 1014
			cr, -- 1014
			math.pi * 0.5, -- 1014
			math.pi * 0.5 - TWO_PI * prog, -- 1014
			2.4, -- 1014
			toColor(PALETTE.amberCore, 240), -- 1014
			16 -- 1014
		) -- 1014
		local k = 0 -- 1015
		do -- 1015
			k = 0 -- 1016
			while k < 4 do -- 1016
				local ph = (self.animTime * 4.6 + k * 0.25) % 1 -- 1017
				local ang = k * 1.57 + ph * 1.4 -- 1018
				local sx = cx + math.cos(ang) * (cr + ph * 10) -- 1019
				local sy = cy + math.sin(ang) * (cr + ph * 8) - ph * 6 -- 1020
				fgDraw:drawSegment( -- 1021
					Vec2(sx - 2, sy), -- 1021
					Vec2(sx + 2, sy + 1.5), -- 1021
					1.3, -- 1021
					toColor( -- 1021
						PALETTE.amber, -- 1021
						math.floor(215 * (1 - ph) + 0.5) -- 1021
					) -- 1021
				) -- 1021
				k = k + 1 -- 1016
			end -- 1016
		end -- 1016
	end -- 1016
	if self.xiaomanRippleT > 0.01 and ctx.view.backCarry.active then -- 1016
		local p01 = 1 - self.xiaomanRippleT / 0.78 -- 1027
		local bx = px - facing * cam:len(8) -- 1028
		local by = cam:sy(pl.y + pl.h * 0.68, pl.depth) -- 1029
		local rr = cam:len(8) + easeOutCubic(p01) * cam:len(22) -- 1030
		local alpha = (1 - p01) * 0.85 -- 1031
		drawBrushArc( -- 1032
			fgGlow, -- 1032
			bx, -- 1032
			by, -- 1032
			rr, -- 1032
			rr, -- 1032
			0, -- 1032
			TWO_PI, -- 1032
			1.5, -- 1032
			toColor( -- 1032
				PALETTE.amberCore, -- 1032
				math.floor(180 * alpha + 0.5) -- 1032
			), -- 1032
			18 -- 1032
		) -- 1032
		fillRadialGlow( -- 1033
			fgGlow, -- 1033
			bx, -- 1033
			by, -- 1033
			rr * 0.8, -- 1033
			rr * 0.8, -- 1033
			toColor( -- 1033
				PALETTE.amber, -- 1033
				math.floor(48 * alpha + 0.5) -- 1033
			), -- 1033
			Color(214, 186, 146, 0), -- 1033
			12 -- 1033
		) -- 1033
	end -- 1033
end -- 874
function RoguelikeUiPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1039
	local rg = ctx.view.roguelike -- 1046
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1047
	local modalBlocking = ctx.p.escortFailed or ctx.view.reloadSession.active or ctx.view.craftBench.active -- 1048
	if rg.active and not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1048
		if rg.showRouteTrack and #rg.stages > 0 then -- 1048
			self:drawNorthwardTrack( -- 1053
				uiDraw, -- 1053
				uiInkDraw, -- 1053
				uiArt, -- 1053
				uiGlow, -- 1053
				ctx, -- 1053
				rg.stages, -- 1053
				safe -- 1053
			) -- 1053
		end -- 1053
		self:drawCrestAndSatchelHud( -- 1055
			uiDraw, -- 1055
			uiInkDraw, -- 1055
			uiArt, -- 1055
			uiGlow, -- 1055
			ctx, -- 1055
			rg, -- 1055
			safe -- 1055
		) -- 1055
	else -- 1055
		self.ledgerButtonBox = Rect(0, 0, 0, 0) -- 1057
	end -- 1057
	if not modalBlocking and not self.ledgerOpen and self.deathRecapT <= 0.15 then -- 1057
		if self.sealAnim ~= nil then -- 1057
			self:drawSealAndAbsorb( -- 1063
				uiDraw, -- 1063
				uiInkDraw, -- 1063
				uiArt, -- 1063
				uiGlow, -- 1063
				ctx, -- 1063
				rg, -- 1063
				self.sealAnim -- 1063
			) -- 1063
		elseif #rg.offers > 0 then -- 1063
			if self.drawerState == "expanded" then -- 1063
				self:drawExpandedTalentCards( -- 1066
					uiDraw, -- 1066
					uiInkDraw, -- 1066
					uiArt, -- 1066
					uiGlow, -- 1066
					ctx, -- 1066
					rg, -- 1066
					safe -- 1066
				) -- 1066
			elseif self.drawerState == "compact" then -- 1066
				self:drawCompactTalentTallies( -- 1068
					uiDraw, -- 1068
					uiInkDraw, -- 1068
					uiArt, -- 1068
					ctx, -- 1068
					rg, -- 1068
					safe -- 1068
				) -- 1068
			end -- 1068
		else -- 1068
			self.expandToggleBox = Rect(0, 0, 0, 0) -- 1071
		end -- 1071
	else -- 1071
		self.expandToggleBox = Rect(0, 0, 0, 0) -- 1074
	end -- 1074
	if self.segmentBannerT > 0.01 then -- 1074
		self:drawSegmentClearRibbon( -- 1079
			uiDraw, -- 1079
			uiInkDraw, -- 1079
			uiArt, -- 1079
			uiGlow, -- 1079
			ctx, -- 1079
			safe -- 1079
		) -- 1079
	end -- 1079
	if self.deathRecapT > 0.01 and self.deathRecapSnap ~= nil then -- 1079
		self:drawDeathRecapOverlay( -- 1084
			uiDraw, -- 1084
			uiInkDraw, -- 1084
			uiArt, -- 1084
			uiGlow, -- 1084
			ctx, -- 1084
			self.deathRecapSnap -- 1084
		) -- 1084
	end -- 1084
	if self.ledgerOpen and rg.active and not modalBlocking then -- 1084
		self:drawBuildLedger( -- 1089
			uiDraw, -- 1089
			uiInkDraw, -- 1089
			uiArt, -- 1089
			uiGlow, -- 1089
			ctx, -- 1089
			rg, -- 1089
			safe -- 1089
		) -- 1089
		return true -- 1090
	end -- 1090
	return self.drawerState == "expanded" and self.hoverSlot >= 0 -- 1093
end -- 1039
function RoguelikeUiPlugin.prototype.drawNorthwardTrack(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, stages, safe) -- 1098
	local cx = ctx.uiW * 0.5 -- 1107
	local y = ctx.uiH - (ctx.view.isRehearsal and 50 or 24) - safe.top -- 1108
	local spanW = math.min(360, ctx.uiW * 0.34) -- 1109
	local x0 = cx - spanW * 0.5 -- 1110
	local step = #stages > 1 and spanW / (#stages - 1) or 0 -- 1111
	drawSilkVeil( -- 1113
		uiDraw, -- 1113
		uiArt, -- 1113
		"rg_track_veil", -- 1113
		cx, -- 1113
		y, -- 1113
		spanW + 108, -- 1113
		28, -- 1113
		PALETTE.inkWash, -- 1113
		0.56, -- 1113
		-1 -- 1113
	) -- 1113
	uiInkDraw:drawSegment( -- 1114
		Vec2(x0, y + 3), -- 1114
		Vec2(x0 + spanW, y + 3), -- 1114
		0.9, -- 1114
		toColor(PALETTE.silkDim, 130) -- 1114
	) -- 1114
	local curIdx = 0 -- 1117
	local i = 0 -- 1118
	do -- 1118
		i = 0 -- 1119
		while i < #stages do -- 1119
			if stages[i + 1].current then -- 1119
				curIdx = i -- 1121
				break -- 1122
			end -- 1122
			i = i + 1 -- 1119
		end -- 1119
	end -- 1119
	if curIdx > 0 then -- 1119
		uiInkDraw:drawSegment( -- 1126
			Vec2(x0, y + 3), -- 1126
			Vec2(x0 + step * curIdx, y + 3), -- 1126
			1.4, -- 1126
			toColor(PALETTE.moonPale, 195) -- 1126
		) -- 1126
	end -- 1126
	do -- 1126
		i = 0 -- 1129
		while i < #stages do -- 1129
			local st = stages[i + 1] -- 1130
			local nx = x0 + step * i -- 1131
			local ny = y + 3 -- 1132
			if st.current then -- 1132
				local breathe = 0.82 + 0.18 * math.sin(self.animTime * 4.2) -- 1134
				fillRadialGlow( -- 1135
					uiGlow, -- 1135
					nx, -- 1135
					ny, -- 1135
					14, -- 1135
					14, -- 1135
					toColor(PALETTE.rouge, 46 * breathe), -- 1135
					Color(182, 58, 56, 0), -- 1135
					10 -- 1135
				) -- 1135
				drawBlossomDot( -- 1136
					uiInkDraw, -- 1136
					uiArt, -- 1136
					"rg_st_cur_" .. tostring(i), -- 1136
					nx, -- 1136
					ny, -- 1136
					13, -- 1136
					PALETTE.rouge, -- 1136
					0.96, -- 1136
					4 -- 1136
				) -- 1136
			elseif st.cleared then -- 1136
				drawDiamond( -- 1138
					uiInkDraw, -- 1138
					nx, -- 1138
					ny, -- 1138
					4.2, -- 1138
					4.2, -- 1138
					toColor(PALETTE.moonPale, 225), -- 1138
					0.8, -- 1138
					toColor(PALETTE.cyan, 180) -- 1138
				) -- 1138
			elseif st.isBench or st.isFinal then -- 1138
				fillRadialGlow( -- 1140
					uiGlow, -- 1140
					nx, -- 1140
					ny, -- 1140
					10, -- 1140
					10, -- 1140
					toColor(PALETTE.amber, 26), -- 1140
					Color(214, 186, 146, 0), -- 1140
					8 -- 1140
				) -- 1140
				drawDiamond( -- 1141
					uiInkDraw, -- 1141
					nx, -- 1141
					ny, -- 1141
					4, -- 1141
					4, -- 1141
					Color(20, 22, 30, 210), -- 1141
					1.1, -- 1141
					toColor(PALETTE.amberCore, 215) -- 1141
				) -- 1141
			else -- 1141
				drawDiamond( -- 1143
					uiInkDraw, -- 1143
					nx, -- 1143
					ny, -- 1143
					3.3, -- 1143
					3.3, -- 1143
					Color(16, 19, 27, 210), -- 1143
					0.9, -- 1143
					toColor(PALETTE.silkDim, 155) -- 1143
				) -- 1143
			end -- 1143
			local labelCol = st.current and PALETTE.textBright or ((st.isBench or st.isFinal) and PALETTE.amberCore or (st.cleared and PALETTE.textMid or PALETTE.textDim)) -- 1145
			ctx.texts:put( -- 1148
				"xs", -- 1149
				st.label, -- 1150
				nx, -- 1151
				ny - 14, -- 1152
				toColor(labelCol), -- 1153
				0.5, -- 1154
				0.5, -- 1155
				"Center", -- 1156
				0.4, -- 1157
				st.current and 0.96 or 0.72, -- 1158
				0.08 -- 1159
			) -- 1159
			i = i + 1 -- 1129
		end -- 1129
	end -- 1129
end -- 1098
function RoguelikeUiPlugin.prototype.drawCrestAndSatchelHud(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1166
	local bx = 28 + safe.left -- 1175
	local hpBaseY = ctx.uiH - 72 - safe.top -- 1176
	local p = ctx.p -- 1177
	if self.hpBarPulseT > 0.01 then -- 1177
		local pA = clamp(self.hpBarPulseT / 0.7, 0, 1) -- 1181
		fillRadialGlow( -- 1182
			uiGlow, -- 1182
			bx + 130, -- 1182
			hpBaseY + 16, -- 1182
			140, -- 1182
			28, -- 1182
			toColor(PALETTE.moonPale, 44 * pA), -- 1182
			Color(232, 236, 234, 0), -- 1182
			12 -- 1182
		) -- 1182
	end -- 1182
	local ____p_isCampaign_14 = p.isCampaign -- 1186
	if ____p_isCampaign_14 then -- 1186
		local ____opt_9 = p.room.campaign -- 1186
		local ____temp_13 = (____opt_9 and ____opt_9.chapter) == "S" -- 1187
		if not ____temp_13 then -- 1187
			local ____opt_11 = p.room.campaign -- 1187
			____temp_13 = (____opt_11 and ____opt_11.chapter) == "C" -- 1187
		end -- 1187
		____p_isCampaign_14 = ____temp_13 -- 1186
	end -- 1186
	local fearVisible = ____p_isCampaign_14 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 1186
	local row1Y = hpBaseY - (fearVisible and 52 or 24) -- 1189
	local learnedIds = {} -- 1192
	local baseOrder = { -- 1193
		"vitality", -- 1193
		"guard", -- 1193
		"stride", -- 1193
		"focus", -- 1193
		"push_force", -- 1193
		"echo_wide", -- 1193
		"lantern_pierce", -- 1193
		"salvage" -- 1193
	} -- 1193
	local i = 0 -- 1194
	do -- 1194
		i = 0 -- 1195
		while i < #baseOrder do -- 1195
			if (rg.ranks[baseOrder[i + 1]] or 0) > 0 then -- 1195
				learnedIds[#learnedIds + 1] = baseOrder[i + 1] -- 1197
			end -- 1197
			i = i + 1 -- 1195
		end -- 1195
	end -- 1195
	for k in pairs(rg.ranks) do -- 1200
		if (rg.ranks[k] or 0) > 0 and __TS__ArrayIndexOf(learnedIds, k) < 0 then -- 1200
			learnedIds[#learnedIds + 1] = k -- 1202
		end -- 1202
	end -- 1202
	local cursorX = bx -- 1207
	local badgeH = 26 -- 1208
	local rowCenterY = row1Y + 6 -- 1209
	do -- 1209
		i = 0 -- 1210
		while i < #learnedIds do -- 1210
			local tid = learnedIds[i + 1] -- 1211
			local rank = rg.ranks[tid] or 1 -- 1212
			local meta = resolveTalentVisual(tid, rg) -- 1213
			local badgeW = 62 -- 1214
			local pulse = self.crestPulseMap[tid] or 0 -- 1215
			local activeNow = tid == "guard" and rg.activeInvulnTicks > 0 or tid == "focus" and rg.activeReloadTicks > 0 or tid == "salvage" and rg.activeCraftTicks > 0 -- 1216
			local glowBoost = math.max( -- 1219
				pulse, -- 1219
				activeNow and 0.55 + 0.35 * math.sin(self.animTime * 8) or 0 -- 1219
			) -- 1219
			if glowBoost > 0.02 then -- 1219
				fillRadialGlow( -- 1222
					uiGlow, -- 1222
					cursorX + badgeW * 0.5, -- 1222
					rowCenterY, -- 1222
					badgeW * 0.72, -- 1222
					20, -- 1222
					toColor(meta.accentCore, 46 * glowBoost), -- 1222
					Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1222
					10 -- 1222
				) -- 1222
			end -- 1222
			uiDraw:drawRoundedRect( -- 1224
				Rect(cursorX, rowCenterY - badgeH * 0.5, badgeW, badgeH), -- 1225
				4, -- 1226
				toColor(activeNow and PALETTE.inkWarm or PALETTE.inkWash, activeNow and 225 or 196), -- 1227
				(activeNow or pulse > 0.05) and 1.3 or 0.85, -- 1228
				toColor((activeNow or pulse > 0.05) and meta.accentCore or meta.accent, activeNow and 235 or 168) -- 1229
			) -- 1229
			drawTalentGlyph( -- 1231
				uiInkDraw, -- 1231
				cursorX + 15, -- 1231
				rowCenterY, -- 1231
				8.2, -- 1231
				tid, -- 1231
				meta.accent, -- 1231
				0.96, -- 1231
				meta.accentCore -- 1231
			) -- 1231
			ctx.texts:put( -- 1232
				"xs", -- 1233
				rankChinese(rank), -- 1234
				cursorX + 41, -- 1235
				rowCenterY, -- 1236
				toColor(meta.accentCore), -- 1237
				0.5, -- 1238
				0.5, -- 1239
				"Center", -- 1240
				0, -- 1241
				0.96, -- 1242
				0.08 -- 1243
			) -- 1243
			if tid == "guard" and rg.activeInvulnTicks > 0 then -- 1243
				local frac = clamp( -- 1247
					rg.activeInvulnTicks / math.max(1, rg.invulnTicksNow), -- 1247
					0, -- 1247
					1 -- 1247
				) -- 1247
				uiInkDraw:drawSegment( -- 1248
					Vec2(cursorX + 4, rowCenterY - badgeH * 0.5 + 2), -- 1249
					Vec2(cursorX + 4 + (badgeW - 8) * frac, rowCenterY - badgeH * 0.5 + 2), -- 1250
					2, -- 1251
					toColor(PALETTE.emerald, 240) -- 1252
				) -- 1252
			end -- 1252
			cursorX = cursorX + (badgeW + 6) -- 1255
			i = i + 1 -- 1210
		end -- 1210
	end -- 1210
	local ledgerLabel = ctx.input.inputMode == "kbm" and "札记 V" or "札记" -- 1259
	local ledgerW = ctx.input.inputMode == "kbm" and 64 or 48 -- 1260
	local ledgerRect = Rect(cursorX, rowCenterY - badgeH * 0.5, ledgerW, badgeH) -- 1261
	self.ledgerButtonBox = ledgerRect -- 1262
	local ptrX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 1263
	local ptrY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 1264
	local ledgerHover = not ctx.input:isTouchMode() and (ctx.input.uiInside or ctx.input.inside) and ledgerRect:containsPoint(Vec2(ptrX, ptrY)) -- 1265
	uiDraw:drawRoundedRect( -- 1266
		ledgerRect, -- 1267
		4, -- 1268
		toColor(ledgerHover and PALETTE.rougeSoft or PALETTE.inkWash, ledgerHover and 205 or 176), -- 1269
		0.9, -- 1270
		toColor(ledgerHover and PALETTE.amberCore or PALETTE.silkDim, ledgerHover and 225 or 155) -- 1271
	) -- 1271
	ctx.texts:put( -- 1273
		"xs", -- 1274
		ledgerLabel, -- 1275
		ledgerRect.x + ledgerRect.width * 0.5, -- 1276
		rowCenterY, -- 1277
		toColor(ledgerHover and PALETTE.textBright or PALETTE.amberCore), -- 1278
		0.5, -- 1279
		0.5, -- 1280
		"Center", -- 1281
		0.6, -- 1282
		0.92, -- 1283
		0.08 -- 1284
	) -- 1284
	local touchLandscape = ctx.input:shouldShowTouchControls() and ctx.uiW > ctx.uiH -- 1290
	local row2Y = touchLandscape and rowCenterY - 30 or 28 + safe.bottom -- 1291
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1292
	local shownItems = {} -- 1293
	local shownKinds = {} -- 1294
	do -- 1294
		i = 0 -- 1295
		while i < #PICKUP_ORDER do -- 1295
			local k = PICKUP_ORDER[i + 1] -- 1296
			local cnt = rg.supplies[k] or 0 -- 1297
			if cnt > 0 then -- 1297
				shownItems[#shownItems + 1] = {kind = k, count = cnt} -- 1299
				shownKinds[#shownKinds + 1] = k -- 1300
			end -- 1300
			i = i + 1 -- 1295
		end -- 1295
	end -- 1295
	self.lastSuppliesShown = shownKinds -- 1303
	if touchLandscape and self.drawerState == "expanded" then -- 1303
		return -- 1305
	end -- 1305
	local woodCnt = rg.supplies.wood or 0 -- 1308
	local bellCnt = rg.supplies.bell or 0 -- 1309
	local craftReady = (rg.roomKey == "escort2" or rg.roomKey == "escort3") and (woodCnt >= 2 or woodCnt >= 1 and bellCnt >= 1) and rg.equippedWeapon == "standard_gun" -- 1310
	local sx = bx -- 1315
	local weaponW = 86 -- 1316
	local pillH = 24 -- 1317
	if not touchLandscape then -- 1317
		local stripW = weaponW + 6 + #shownItems * 59 + (craftReady and 68 or 0) + 28 -- 1319
		drawSilkVeil( -- 1320
			uiDraw, -- 1320
			uiArt, -- 1320
			"rg_satchel_veil", -- 1320
			bx + stripW * 0.45, -- 1320
			row2Y, -- 1320
			stripW + 32, -- 1320
			34, -- 1320
			PALETTE.inkWash, -- 1320
			0.56, -- 1320
			-1 -- 1320
		) -- 1320
	end -- 1320
	uiDraw:drawRoundedRect( -- 1322
		Rect(sx, row2Y - pillH * 0.5, weaponW, pillH), -- 1323
		4, -- 1324
		toColor(PALETTE.inkWash, 185), -- 1325
		0.85, -- 1326
		toColor(wMeta.accent, 160) -- 1327
	) -- 1327
	drawReloadPatternGlyph( -- 1329
		uiInkDraw, -- 1329
		sx + 14, -- 1329
		row2Y, -- 1329
		7.2, -- 1329
		wMeta.effect, -- 1329
		wMeta.accent, -- 1329
		0.94 -- 1329
	) -- 1329
	ctx.texts:put( -- 1330
		"xs", -- 1330
		wMeta.shortName, -- 1330
		sx + 26, -- 1330
		row2Y, -- 1330
		toColor(wMeta.accent), -- 1330
		0, -- 1330
		0.5, -- 1330
		"Left", -- 1330
		0.5, -- 1330
		0.94, -- 1330
		0.08 -- 1330
	) -- 1330
	sx = sx + (weaponW + 6) -- 1331
	do -- 1331
		i = 0 -- 1333
		while i < #shownItems do -- 1333
			local it = shownItems[i + 1] -- 1334
			local pm = pickupMetaOf(it.kind) -- 1335
			local bounce = self.pickupBounceMap[it.kind] or 0 -- 1336
			local shake = self.pickupShakeMap[it.kind] or 0 -- 1337
			local shakeX = shake > 0 and math.sin(self.animTime * 56) * 3.2 * (shake / 0.42) or 0 -- 1338
			local liftY = bounce > 0 and math.sin(bounce / 0.52 * math.pi) * 5 or 0 -- 1339
			local itemW = 54 -- 1340
			local rx = sx + shakeX -- 1341
			local ry = row2Y + liftY -- 1342
			local isHot = bounce > 0.02 or craftReady and (it.kind == "wood" or it.kind == "bell") -- 1343
			local bdCol = shake > 0.02 and PALETTE.rouge or (isHot and PALETTE.amberCore or pm.accent) -- 1344
			if isHot then -- 1344
				local ga = bounce > 0.02 and 48 * (bounce / 0.52) or 24 + 12 * math.sin(self.animTime * 4.5) -- 1347
				fillRadialGlow( -- 1348
					uiGlow, -- 1348
					rx + itemW * 0.5, -- 1348
					ry, -- 1348
					34, -- 1348
					16, -- 1348
					toColor(PALETTE.amberCore, ga), -- 1348
					Color(214, 186, 146, 0), -- 1348
					10 -- 1348
				) -- 1348
			end -- 1348
			uiDraw:drawRoundedRect( -- 1350
				Rect(rx, ry - pillH * 0.5, itemW, pillH), -- 1351
				4, -- 1352
				toColor(shake > 0.02 and PALETTE.inkWarm or PALETTE.inkWash, 192), -- 1353
				(isHot or shake > 0.02) and 1.2 or 0.8, -- 1354
				toColor(bdCol, (isHot or shake > 0.02) and 225 or 148) -- 1355
			) -- 1355
			drawPickupGlyph( -- 1357
				uiInkDraw, -- 1357
				rx + 14, -- 1357
				ry, -- 1357
				7.2, -- 1357
				it.kind, -- 1357
				0.96 -- 1357
			) -- 1357
			ctx.texts:put( -- 1358
				"xs", -- 1359
				"×" .. tostring(it.count), -- 1360
				rx + 37, -- 1361
				ry, -- 1362
				toColor(pm.accentCore), -- 1363
				0.5, -- 1364
				0.5, -- 1365
				"Center", -- 1366
				0, -- 1367
				0.96, -- 1368
				0.08 -- 1369
			) -- 1369
			local popIdx = 0 -- 1372
			do -- 1372
				popIdx = 0 -- 1373
				while popIdx < #self.pickupPops do -- 1373
					local pop = self.pickupPops[popIdx + 1] -- 1374
					if pop.kind == it.kind then -- 1374
						local prog = 1 - pop.timer / pop.maxTimer -- 1376
						ctx.texts:put( -- 1377
							"xs", -- 1378
							"+1", -- 1379
							rx + itemW * 0.5, -- 1380
							ry + 16 + prog * 14, -- 1381
							toColor(PALETTE.amberCore), -- 1382
							0.5, -- 1383
							0.5, -- 1384
							"Center", -- 1385
							0, -- 1386
							1 - prog, -- 1387
							0.08 -- 1388
						) -- 1388
						break -- 1390
					end -- 1390
					popIdx = popIdx + 1 -- 1373
				end -- 1373
			end -- 1373
			sx = sx + (itemW + 5) -- 1393
			i = i + 1 -- 1333
		end -- 1333
	end -- 1333
	if craftReady then -- 1333
		local breathe = 0.72 + 0.28 * math.sin(self.animTime * 4.2) -- 1397
		uiDraw:drawRoundedRect( -- 1398
			Rect(sx, row2Y - pillH * 0.5, 62, pillH), -- 1398
			4, -- 1398
			toColor(PALETTE.inkWarm, 185), -- 1398
			0.95, -- 1398
			toColor(PALETTE.amberCore, 210 * breathe) -- 1398
		) -- 1398
		ctx.texts:put( -- 1399
			"xs", -- 1399
			"足改制", -- 1399
			sx + 31, -- 1399
			row2Y, -- 1399
			toColor(PALETTE.amberCore), -- 1399
			0.5, -- 1399
			0.5, -- 1399
			"Center", -- 1399
			0.6, -- 1399
			0.94 * breathe, -- 1399
			0.08 -- 1399
		) -- 1399
	end -- 1399
end -- 1166
function RoguelikeUiPlugin.prototype.drawExpandedTalentCards(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1405
	local offers = rg.offers -- 1414
	local touchMode = ctx.input:isTouchMode() -- 1415
	local mode = ctx.input.inputMode -- 1416
	local boxes = ____exports.computeRoguelikeCardRects( -- 1417
		ctx.uiW, -- 1417
		ctx.uiH, -- 1417
		#offers, -- 1417
		true, -- 1417
		touchMode, -- 1417
		safe.top -- 1417
	) -- 1417
	self.lastCardBoxes = boxes -- 1418
	local appear = easeOutCubic(self.expandAnimT) -- 1419
	local slowFrac = clamp((1 - self.focusScale) / (1 - EXPANDED_FOCUS_SCALE), 0, 1) -- 1420
	fillVGradRect( -- 1423
		uiDraw, -- 1424
		0, -- 1425
		ctx.uiH * 0.36, -- 1426
		ctx.uiW, -- 1427
		ctx.uiH * 0.64, -- 1428
		Color(9, 12, 19, 0), -- 1429
		Color( -- 1430
			9, -- 1430
			12, -- 1430
			19, -- 1430
			math.floor((138 + 42 * slowFrac) * appear + 0.5) -- 1430
		) -- 1430
	) -- 1430
	local firstBox = boxes[1] -- 1434
	local headY = firstBox.y + firstBox.height + 28 -- 1435
	local cx = ctx.uiW * 0.5 -- 1436
	drawSilkVeil( -- 1437
		uiDraw, -- 1437
		uiArt, -- 1437
		"rg_exp_head_veil", -- 1437
		cx, -- 1437
		headY, -- 1437
		440, -- 1437
		30, -- 1437
		PALETTE.inkWash, -- 1437
		0.78 * appear, -- 1437
		-1 -- 1437
	) -- 1437
	drawHairline( -- 1438
		uiInkDraw, -- 1438
		uiArt, -- 1438
		"rg_exp_head_line", -- 1438
		cx, -- 1438
		headY + 15, -- 1438
		360, -- 1438
		PALETTE.amber, -- 1438
		0.54 * appear, -- 1438
		true, -- 1438
		2 -- 1438
	) -- 1438
	local headText = mode == "gamepad" and ("途中整备 · 择一军筹（LB/RB 择项 · " .. getActiveTarget():keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " / L3 落印）" or (touchMode and "途中整备 · 择一军筹 · 轻触卡面直接落印" or "途中整备 · 择一军筹 · 按 1 / 2 / 3 或点击落印") -- 1439
	ctx.texts:put( -- 1444
		"xs", -- 1444
		headText, -- 1444
		cx, -- 1444
		headY, -- 1444
		toColor(PALETTE.amberCore), -- 1444
		0.5, -- 1444
		0.5, -- 1444
		"Center", -- 1444
		1, -- 1444
		0.96 * appear, -- 1444
		0.08 -- 1444
	) -- 1444
	local lastBox = boxes[#boxes] -- 1447
	local togX = math.min(ctx.uiW - 86 - safe.right, lastBox.x + lastBox.width - 52) -- 1448
	local togRect = Rect(togX, headY - 12, 54, 24) -- 1449
	self.expandToggleBox = togRect -- 1450
	uiDraw:drawRoundedRect( -- 1451
		togRect, -- 1451
		4, -- 1451
		toColor(PALETTE.inkWash, 185 * appear), -- 1451
		0.85, -- 1451
		toColor(PALETTE.silkDim, 165 * appear) -- 1451
	) -- 1451
	ctx.texts:put( -- 1452
		"xs", -- 1452
		"收束", -- 1452
		togRect.x + 27, -- 1452
		headY, -- 1452
		toColor(PALETTE.textMid), -- 1452
		0.5, -- 1452
		0.5, -- 1452
		"Center", -- 1452
		0.6, -- 1452
		0.88 * appear, -- 1452
		0.08 -- 1452
	) -- 1452
	local i = 0 -- 1455
	do -- 1455
		i = 0 -- 1456
		while i < #offers do -- 1456
			do -- 1456
				local tid = offers[i + 1] -- 1457
				local baseBox = boxes[i + 1] -- 1458
				local cardStagger = easeOutCubic(clamp((self.staggerTime - i * 0.055) / 0.24, 0, 1)) -- 1459
				local alpha = cardStagger * appear -- 1460
				if alpha <= 0.01 then -- 1460
					goto __continue212 -- 1462
				end -- 1462
				local lift = (self.cardLiftT[i + 1] or 0) * 10 -- 1464
				local slideY = (1 - cardStagger) * -22 -- 1465
				local x = baseBox.x -- 1466
				local y = baseBox.y + slideY + lift -- 1467
				local w = baseBox.width -- 1468
				local h = baseBox.height -- 1469
				local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1470
				self:drawSingleTalentCard( -- 1472
					uiDraw, -- 1472
					uiInkDraw, -- 1472
					uiArt, -- 1472
					uiGlow, -- 1472
					ctx, -- 1472
					rg, -- 1472
					tid, -- 1472
					i, -- 1472
					x, -- 1472
					y, -- 1472
					w, -- 1472
					h, -- 1472
					isHot, -- 1472
					alpha, -- 1472
					mode -- 1472
				) -- 1472
			end -- 1472
			::__continue212:: -- 1472
			i = i + 1 -- 1456
		end -- 1456
	end -- 1456
end -- 1405
function RoguelikeUiPlugin.prototype.drawSingleTalentCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, tid, slotIdx, x, y, w, h, isHot, alpha, mode) -- 1476
	local meta = resolveTalentVisual(tid, rg) -- 1493
	local curRank = rg.ranks[tid] or 0 -- 1494
	local cx = x + w * 0.5 -- 1495
	local cy = y + h * 0.5 -- 1496
	local accent = isHot and PALETTE.rouge or meta.accent -- 1497
	uiArt:tryPlace( -- 1500
		"ink_frame_mask", -- 1500
		"rg_card_sh_" .. tostring(slotIdx), -- 1500
		cx, -- 1500
		cy - 4, -- 1500
		w + 26, -- 1500
		h + 24, -- 1500
		{ -- 1500
			color = toColor(PALETTE.voidDark), -- 1501
			opacity = 0.72 * alpha, -- 1501
			layer = -1 -- 1501
		} -- 1501
	) -- 1501
	if isHot then -- 1501
		local breathe = 0.86 + 0.14 * math.sin(self.animTime * 4) -- 1504
		fillRadialGlow( -- 1505
			uiGlow, -- 1505
			cx, -- 1505
			cy, -- 1505
			w * 0.74, -- 1505
			h * 0.64, -- 1505
			toColor(PALETTE.rouge, 34 * breathe * alpha), -- 1505
			Color(182, 58, 56, 0), -- 1505
			14 -- 1505
		) -- 1505
	end -- 1505
	local bgCol = isHot and Color( -- 1509
		28, -- 1509
		22, -- 1509
		27, -- 1509
		math.floor(244 * alpha + 0.5) -- 1509
	) or Color( -- 1509
		15, -- 1509
		18, -- 1509
		26, -- 1509
		math.floor(234 * alpha + 0.5) -- 1509
	) -- 1509
	local bdCol = toColor(isHot and PALETTE.rouge or meta.accent, (isHot and 235 or 155) * alpha) -- 1510
	uiDraw:drawRoundedRect( -- 1511
		Rect(x, y, w, h), -- 1511
		5, -- 1511
		bgCol, -- 1511
		isHot and 1.55 or 0.95, -- 1511
		bdCol -- 1511
	) -- 1511
	uiDraw:drawRect( -- 1513
		Rect(x + 5, y + 5, w - 10, h - 10), -- 1513
		Color(0, 0, 0, 0), -- 1513
		0.65, -- 1513
		toColor(isHot and PALETTE.amberCore or PALETTE.silkDim, (isHot and 115 or 68) * alpha) -- 1513
	) -- 1513
	drawFiligreeCorners( -- 1515
		uiInkDraw, -- 1515
		uiArt, -- 1515
		"rg_card_cn_" .. tostring(slotIdx), -- 1515
		x + 2, -- 1515
		y + 2, -- 1515
		w - 4, -- 1515
		h - 4, -- 1515
		accent, -- 1515
		(isHot and 0.94 or 0.62) * alpha, -- 1515
		22, -- 1515
		false, -- 1515
		3 -- 1515
	) -- 1515
	local topY = y + h - 22 -- 1518
	ctx.texts:put( -- 1519
		"xs", -- 1519
		meta.category, -- 1519
		x + 16, -- 1519
		topY, -- 1519
		toColor(meta.accentCore), -- 1519
		0, -- 1519
		0.5, -- 1519
		"Left", -- 1519
		1.2, -- 1519
		0.88 * alpha, -- 1519
		0.08 -- 1519
	) -- 1519
	local maxPips = math.max(curRank + 1, 3) -- 1522
	local pipStartX = x + w - 16 - (maxPips - 1) * 12 -- 1523
	local k = 0 -- 1524
	do -- 1524
		k = 0 -- 1525
		while k < maxPips do -- 1525
			local px = pipStartX + k * 12 -- 1526
			if k < curRank then -- 1526
				drawDiamond( -- 1528
					uiInkDraw, -- 1528
					px, -- 1528
					topY, -- 1528
					4, -- 1528
					4, -- 1528
					toColor(meta.accentCore, 230 * alpha) -- 1528
				) -- 1528
			elseif k == curRank then -- 1528
				drawDiamond( -- 1530
					uiInkDraw, -- 1530
					px, -- 1530
					topY, -- 1530
					4.4, -- 1530
					4.4, -- 1530
					toColor(isHot and PALETTE.rouge or PALETTE.amber, 220 * alpha), -- 1530
					1, -- 1530
					toColor(PALETTE.textBright, 220 * alpha) -- 1530
				) -- 1530
			else -- 1530
				drawDiamond( -- 1532
					uiInkDraw, -- 1532
					px, -- 1532
					topY, -- 1532
					3.2, -- 1532
					3.2, -- 1532
					Color(0, 0, 0, 0), -- 1532
					0.85, -- 1532
					toColor(PALETTE.silkDim, 130 * alpha) -- 1532
				) -- 1532
			end -- 1532
			k = k + 1 -- 1525
		end -- 1525
	end -- 1525
	drawHairline( -- 1536
		uiInkDraw, -- 1536
		uiArt, -- 1536
		"rg_card_hl_" .. tostring(slotIdx), -- 1536
		cx, -- 1536
		topY - 14, -- 1536
		w - 28, -- 1536
		accent, -- 1536
		0.45 * alpha, -- 1536
		false, -- 1536
		2 -- 1536
	) -- 1536
	local iconY = y + h - 76 -- 1539
	uiArt:tryPlace( -- 1540
		"ink_enso_fine", -- 1540
		"rg_card_enso_" .. tostring(slotIdx), -- 1540
		cx, -- 1540
		iconY, -- 1540
		62, -- 1540
		62, -- 1540
		{ -- 1540
			color = toColor(isHot and PALETTE.amberCore or meta.accent), -- 1541
			opacity = (isHot and 0.64 or 0.36) * alpha, -- 1541
			angle = self.animTime * (isHot and 16 or 6), -- 1541
			layer = 2 -- 1541
		} -- 1541
	) -- 1541
	fillRadialGlow( -- 1543
		uiGlow, -- 1543
		cx, -- 1543
		iconY, -- 1543
		34, -- 1543
		34, -- 1543
		toColor(meta.accent, (isHot and 42 or 20) * alpha), -- 1543
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1543
		12 -- 1543
	) -- 1543
	drawTalentGlyph( -- 1544
		uiInkDraw, -- 1544
		cx, -- 1544
		iconY, -- 1544
		22, -- 1544
		tid, -- 1544
		isHot and meta.accentCore or meta.accent, -- 1544
		alpha, -- 1544
		isHot and PALETTE.textBright or meta.accentCore -- 1544
	) -- 1544
	local titleY = y + 114 -- 1547
	ctx.texts:put( -- 1548
		"md", -- 1549
		meta.title, -- 1550
		cx, -- 1551
		titleY, -- 1552
		toColor(isHot and PALETTE.textBright or meta.accentCore), -- 1553
		0.5, -- 1554
		0.5, -- 1555
		"Center", -- 1556
		5, -- 1557
		0.98 * alpha, -- 1558
		0.1 -- 1559
	) -- 1559
	ctx.texts:put( -- 1563
		"xs", -- 1564
		meta:shortEffect(rg, curRank), -- 1565
		cx, -- 1566
		titleY - 26, -- 1567
		toColor(isHot and PALETTE.amberCore or PALETTE.textBright), -- 1568
		0.5, -- 1569
		0.5, -- 1570
		"Center", -- 1571
		0.6, -- 1572
		0.96 * alpha, -- 1573
		0.08 -- 1574
	) -- 1574
	ctx.texts:put( -- 1576
		"xs", -- 1577
		meta:subEffect(rg, curRank), -- 1578
		cx, -- 1579
		titleY - 46, -- 1580
		toColor(PALETTE.textMid), -- 1581
		0.5, -- 1582
		0.5, -- 1583
		"Center", -- 1584
		0.4, -- 1585
		0.86 * alpha, -- 1586
		0.08 -- 1587
	) -- 1587
	local whisperAlpha = (isHot and 0.9 or (mode == "touch" and 0.62 or 0.36)) * alpha -- 1591
	ctx.texts:put( -- 1592
		"xs", -- 1593
		meta.whisper, -- 1594
		cx, -- 1595
		y + 44, -- 1596
		toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1597
		0.5, -- 1598
		0.5, -- 1599
		"Center", -- 1600
		0.2, -- 1601
		whisperAlpha, -- 1602
		0.06 -- 1603
	) -- 1603
	local footY = y + 18 -- 1607
	if isHot then -- 1607
		drawSilkRibbon( -- 1609
			uiDraw, -- 1609
			uiArt, -- 1609
			"rg_card_rib_" .. tostring(slotIdx), -- 1609
			cx, -- 1609
			footY, -- 1609
			w - 18, -- 1609
			24, -- 1609
			PALETTE.rougeSoft, -- 1609
			0.56 * alpha, -- 1609
			1 -- 1609
		) -- 1609
	end -- 1609
	if mode == "kbm" then -- 1609
		drawSilkKeycap( -- 1612
			uiInkDraw, -- 1612
			ctx.texts, -- 1612
			cx - 42, -- 1612
			footY - 10, -- 1612
			22, -- 1612
			20, -- 1612
			"" .. tostring(slotIdx + 1), -- 1612
			accent, -- 1612
			alpha, -- 1612
			isHot -- 1612
		) -- 1612
		ctx.texts:put( -- 1613
			"xs", -- 1613
			isHot and "落印习得" or "习得", -- 1613
			cx - 12, -- 1613
			footY, -- 1613
			toColor(isHot and PALETTE.textBright or PALETTE.textMid), -- 1613
			0, -- 1613
			0.5, -- 1613
			"Left", -- 1613
			1, -- 1613
			0.94 * alpha, -- 1613
			0.08 -- 1613
		) -- 1613
	elseif mode == "gamepad" then -- 1613
		local label = isHot and "◆ L3 落印 ◆" or ("第" .. rankChinese(slotIdx + 1)) .. "筹" -- 1615
		ctx.texts:put( -- 1616
			"xs", -- 1616
			label, -- 1616
			cx, -- 1616
			footY, -- 1616
			toColor(isHot and PALETTE.amberCore or PALETTE.textDim), -- 1616
			0.5, -- 1616
			0.5, -- 1616
			"Center", -- 1616
			1, -- 1616
			0.94 * alpha, -- 1616
			0.08 -- 1616
		) -- 1616
	else -- 1616
		ctx.texts:put( -- 1618
			"xs", -- 1618
			"轻触落印", -- 1618
			cx, -- 1618
			footY, -- 1618
			toColor(PALETTE.amberCore), -- 1618
			0.5, -- 1618
			0.5, -- 1618
			"Center", -- 1618
			1.2, -- 1618
			0.95 * alpha, -- 1618
			0.08 -- 1618
		) -- 1618
	end -- 1618
end -- 1476
function RoguelikeUiPlugin.prototype.drawCompactTalentTallies(self, uiDraw, uiInkDraw, uiArt, ctx, rg, safe) -- 1624
	local offers = rg.offers -- 1632
	local touchMode = ctx.input:isTouchMode() -- 1633
	local mode = ctx.input.inputMode -- 1634
	local boxes = ____exports.computeRoguelikeCardRects( -- 1635
		ctx.uiW, -- 1635
		ctx.uiH, -- 1635
		#offers, -- 1635
		false, -- 1635
		touchMode, -- 1635
		safe.top -- 1635
	) -- 1635
	self.lastCardBoxes = boxes -- 1636
	local i = 0 -- 1638
	do -- 1638
		i = 0 -- 1639
		while i < #offers do -- 1639
			local tid = offers[i + 1] -- 1640
			local box = boxes[i + 1] -- 1641
			local meta = resolveTalentVisual(tid, rg) -- 1642
			local isHot = mode == "gamepad" and i == self.focusedSlot or mode ~= "gamepad" and i == self.hoverSlot -- 1643
			local cy = box.y + box.height * 0.5 -- 1645
			local bdCol = isHot and PALETTE.rouge or meta.accent -- 1646
			uiDraw:drawRoundedRect( -- 1648
				box, -- 1649
				4, -- 1650
				toColor(isHot and PALETTE.inkWarm or PALETTE.panelBgDeep, isHot and 236 or 210), -- 1651
				isHot and 1.4 or 0.9, -- 1652
				toColor(bdCol, isHot and 235 or 178) -- 1653
			) -- 1653
			drawTalentGlyph( -- 1655
				uiInkDraw, -- 1655
				box.x + 20, -- 1655
				cy, -- 1655
				10.5, -- 1655
				tid, -- 1655
				meta.accent, -- 1655
				0.96, -- 1655
				meta.accentCore -- 1655
			) -- 1655
			if mode == "kbm" then -- 1655
				drawSilkKeycap( -- 1657
					uiInkDraw, -- 1657
					ctx.texts, -- 1657
					box.x + 36, -- 1657
					cy - 10, -- 1657
					20, -- 1657
					20, -- 1657
					"" .. tostring(i + 1), -- 1657
					bdCol, -- 1657
					0.95, -- 1657
					isHot -- 1657
				) -- 1657
				ctx.texts:put( -- 1658
					"xs", -- 1658
					meta.title, -- 1658
					box.x + 62, -- 1658
					cy + 7, -- 1658
					toColor(PALETTE.textBright), -- 1658
					0, -- 1658
					0.5, -- 1658
					"Left", -- 1658
					0.8, -- 1658
					0.96, -- 1658
					0.08 -- 1658
				) -- 1658
				ctx.texts:put( -- 1659
					"xs", -- 1659
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1659
					box.x + 62, -- 1659
					cy - 8, -- 1659
					toColor(meta.accentCore), -- 1659
					0, -- 1659
					0.5, -- 1659
					"Left", -- 1659
					0.2, -- 1659
					0.82, -- 1659
					0.06 -- 1659
				) -- 1659
			else -- 1659
				drawBlossomDot( -- 1661
					uiInkDraw, -- 1661
					uiArt, -- 1661
					"rg_cmp_dot_" .. tostring(i), -- 1661
					box.x + 38, -- 1661
					cy, -- 1661
					isHot and 11 or 7, -- 1661
					bdCol, -- 1661
					0.95, -- 1661
					4 -- 1661
				) -- 1661
				ctx.texts:put( -- 1662
					"xs", -- 1662
					(meta.title .. " · ") .. meta.category, -- 1662
					box.x + 50, -- 1662
					cy + 7, -- 1662
					toColor(PALETTE.textBright), -- 1662
					0, -- 1662
					0.5, -- 1662
					"Left", -- 1662
					0.6, -- 1662
					0.96, -- 1662
					0.08 -- 1662
				) -- 1662
				ctx.texts:put( -- 1663
					"xs", -- 1663
					meta:shortEffect(rg, rg.ranks[tid] or 0), -- 1663
					box.x + 50, -- 1663
					cy - 8, -- 1663
					toColor(meta.accentCore), -- 1663
					0, -- 1663
					0.5, -- 1663
					"Left", -- 1663
					0.2, -- 1663
					0.82, -- 1663
					0.06 -- 1663
				) -- 1663
			end -- 1663
			i = i + 1 -- 1639
		end -- 1639
	end -- 1639
	local last = boxes[#boxes] -- 1668
	local togRect = Rect(last.x + last.width + 8, last.y + (last.height - 26) * 0.5, 50, 26) -- 1669
	self.expandToggleBox = togRect -- 1670
	uiDraw:drawRoundedRect( -- 1671
		togRect, -- 1671
		4, -- 1671
		toColor(PALETTE.inkWash, 190), -- 1671
		0.9, -- 1671
		toColor(PALETTE.amber, 175) -- 1671
	) -- 1671
	ctx.texts:put( -- 1672
		"xs", -- 1672
		"展开", -- 1672
		togRect.x + 25, -- 1672
		togRect.y + 13, -- 1672
		toColor(PALETTE.amberCore), -- 1672
		0.5, -- 1672
		0.5, -- 1672
		"Center", -- 1672
		0.6, -- 1672
		0.92, -- 1672
		0.08 -- 1672
	) -- 1672
end -- 1624
function RoguelikeUiPlugin.prototype.drawSealAndAbsorb(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, anim) -- 1677
	local meta = resolveTalentVisual(anim.talentId, rg) -- 1686
	local pb = anim.pickedBox -- 1687
	local pcx = pb.x + pb.width * 0.5 -- 1688
	local pcy = pb.y + pb.height * 0.5 -- 1689
	if anim.elapsed < anim.sealDuration then -- 1689
		local t = clamp(anim.elapsed / anim.sealDuration, 0, 1) -- 1692
		local i = 0 -- 1694
		do -- 1694
			i = 0 -- 1695
			while i < #anim.allBoxes do -- 1695
				do -- 1695
					if i == anim.pickedSlot then -- 1695
						goto __continue233 -- 1697
					end -- 1697
					local ob = anim.allBoxes[i + 1] -- 1699
					local dir = i < anim.pickedSlot and -1 or 1 -- 1700
					local drift = dir * easeOutCubic(t) * 26 -- 1701
					local oa = (1 - t) * 0.55 -- 1702
					uiDraw:drawRoundedRect( -- 1703
						Rect( -- 1703
							ob.x + drift, -- 1703
							ob.y - easeOutCubic(t) * 8, -- 1703
							ob.width, -- 1703
							ob.height -- 1703
						), -- 1703
						5, -- 1703
						Color( -- 1703
							15, -- 1703
							18, -- 1703
							26, -- 1703
							math.floor(180 * oa + 0.5) -- 1703
						), -- 1703
						0.8, -- 1703
						toColor(PALETTE.silkDim, 110 * oa) -- 1703
					) -- 1703
				end -- 1703
				::__continue233:: -- 1703
				i = i + 1 -- 1695
			end -- 1695
		end -- 1695
		local pop = 1 + (1 - easeOutCubic(t)) * 0.04 -- 1707
		local sw = pb.width * pop -- 1708
		local sh = pb.height * pop -- 1709
		local sx = pcx - sw * 0.5 -- 1710
		local sy = pcy - sh * 0.5 -- 1711
		fillRadialGlow( -- 1712
			uiGlow, -- 1712
			pcx, -- 1712
			pcy, -- 1712
			sw * 0.72, -- 1712
			sh * 0.62, -- 1712
			toColor(PALETTE.rouge, 56 * (1 - t * 0.4)), -- 1712
			Color(182, 58, 56, 0), -- 1712
			14 -- 1712
		) -- 1712
		uiDraw:drawRoundedRect( -- 1713
			Rect(sx, sy, sw, sh), -- 1713
			5, -- 1713
			Color(34, 22, 27, 245), -- 1713
			1.8, -- 1713
			toColor(PALETTE.rouge, 245) -- 1713
		) -- 1713
		drawTalentGlyph( -- 1714
			uiInkDraw, -- 1714
			pcx, -- 1714
			pcy + (anim.fromExpanded and 24 or 0), -- 1714
			anim.fromExpanded and 22 or 12, -- 1714
			anim.talentId, -- 1714
			meta.accentCore, -- 1714
			0.96, -- 1714
			PALETTE.textBright -- 1714
		) -- 1714
		ctx.texts:put( -- 1715
			"md", -- 1715
			meta.title, -- 1715
			pcx, -- 1715
			pcy - (anim.fromExpanded and 22 or 0), -- 1715
			toColor(PALETTE.textBright), -- 1715
			0.5, -- 1715
			0.5, -- 1715
			"Center", -- 1715
			4, -- 1715
			0.98, -- 1715
			0.1 -- 1715
		) -- 1715
		local slam = 1 + (1 - t) ^ 2 * 0.55 -- 1718
		drawLoneSeal( -- 1719
			uiInkDraw, -- 1720
			uiArt, -- 1721
			ctx.texts, -- 1722
			"rg_pick_seal", -- 1723
			pcx + (anim.fromExpanded and pb.width * 0.26 or pb.width * 0.34), -- 1724
			pcy - (anim.fromExpanded and pb.height * 0.22 or 0), -- 1725
			26 * slam, -- 1726
			50 * slam, -- 1727
			"契", -- 1728
			"印", -- 1729
			PALETTE.sealRedBright, -- 1730
			PALETTE.sealText, -- 1731
			0.96, -- 1732
			6 -- 1733
		) -- 1733
		return -- 1735
	end -- 1735
	local t = clamp( -- 1739
		(anim.elapsed - anim.sealDuration) / math.max(0.01, anim.absorbDuration), -- 1739
		0, -- 1739
		1 -- 1739
	) -- 1739
	local dest = self:computeAbsorbTargetUi(ctx, rg, anim.targetKind) -- 1740
	local ctrlX = (pcx + dest.x) * 0.5 -- 1741
	local ctrlY = math.max(pcy, dest.y) + 76 -- 1742
	local headT = easeInOutQuad(t) -- 1745
	local samples = 10 -- 1746
	local s = 0 -- 1747
	local prevPt -- 1748
	do -- 1748
		s = 0 -- 1749
		while s <= samples do -- 1749
			local u = math.max(0, headT - (samples - s) * 0.032) -- 1750
			local inv = 1 - u -- 1751
			local bx = inv * inv * pcx + 2 * inv * u * ctrlX + u * u * dest.x -- 1752
			local by = inv * inv * pcy + 2 * inv * u * ctrlY + u * u * dest.y -- 1753
			local pt = Vec2(bx, by) -- 1754
			if prevPt ~= nil then -- 1754
				local segA = s / samples * (1 - t * 0.35) -- 1756
				uiGlow:drawSegment( -- 1757
					prevPt, -- 1757
					pt, -- 1757
					1.6 + s / samples * 2.4, -- 1757
					toColor( -- 1757
						meta.accentCore, -- 1757
						math.floor(210 * segA + 0.5) -- 1757
					) -- 1757
				) -- 1757
			end -- 1757
			if s % 2 == 1 then -- 1757
				uiGlow:drawDot( -- 1760
					pt, -- 1760
					2 + s / samples * 2.2, -- 1760
					toColor( -- 1760
						PALETTE.amberCore, -- 1760
						math.floor(180 * (s / samples) * (1 - t * 0.3) + 0.5) -- 1760
					) -- 1760
				) -- 1760
			end -- 1760
			prevPt = pt -- 1762
			s = s + 1 -- 1749
		end -- 1749
	end -- 1749
	local invH = 1 - headT -- 1764
	local hx = invH * invH * pcx + 2 * invH * headT * ctrlX + headT * headT * dest.x -- 1765
	local hy = invH * invH * pcy + 2 * invH * headT * ctrlY + headT * headT * dest.y -- 1766
	fillRadialGlow( -- 1767
		uiGlow, -- 1767
		hx, -- 1767
		hy, -- 1767
		22, -- 1767
		22, -- 1767
		toColor(meta.accentCore, 96 * (1 - t * 0.3)), -- 1767
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 1767
		12 -- 1767
	) -- 1767
	drawDiamond( -- 1768
		uiInkDraw, -- 1768
		hx, -- 1768
		hy, -- 1768
		5.5, -- 1768
		5.5, -- 1768
		toColor(PALETTE.textBright, 240) -- 1768
	) -- 1768
end -- 1677
function RoguelikeUiPlugin.prototype.computeAbsorbTargetUi(self, ctx, rg, target) -- 1771
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1772
	local bx = 28 + safe.left -- 1773
	local hpY = ctx.uiH - 56 - safe.top -- 1774
	if target == "hp" then -- 1774
		return { -- 1776
			x = bx + 44 + math.min(5, rg.maxHp) * 52, -- 1776
			y = hpY -- 1776
		} -- 1776
	end -- 1776
	if target == "gun" then -- 1776
		local p = ctx.p -- 1779
		return { -- 1780
			x = clamp( -- 1781
				ctx.cam:sx(p.player.x + p.player.facing * 14) / ctx.uiScale, -- 1781
				80, -- 1781
				ctx.uiW - 80 -- 1781
			), -- 1781
			y = clamp( -- 1782
				ctx.cam:sy(p.player.y + p.player.h * 0.62, p.player.depth) / ctx.uiScale, -- 1782
				80, -- 1782
				ctx.uiH - 80 -- 1782
			) -- 1782
		} -- 1782
	end -- 1782
	if target == "shoulder" then -- 1782
		local p = ctx.p -- 1786
		return { -- 1787
			x = clamp( -- 1788
				ctx.cam:sx(p.player.x) / ctx.uiScale, -- 1788
				80, -- 1788
				ctx.uiW - 80 -- 1788
			), -- 1788
			y = clamp( -- 1789
				ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) / ctx.uiScale, -- 1789
				80, -- 1789
				ctx.uiH - 80 -- 1789
			) -- 1789
		} -- 1789
	end -- 1789
	if target == "satchel" then -- 1789
		return {x = bx + 86, y = hpY - 68} -- 1793
	end -- 1793
	return {x = bx + 64, y = hpY - 36} -- 1795
end -- 1771
function RoguelikeUiPlugin.prototype.drawSegmentClearRibbon(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, safe) -- 1800
	local elapsed = SEGMENT_BANNER_DURATION - self.segmentBannerT -- 1808
	local fadeIn = clamp(elapsed / 0.24, 0, 1) -- 1809
	local fadeOut = clamp(self.segmentBannerT / 0.36, 0, 1) -- 1810
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1811
	if alpha <= 0.01 then -- 1811
		return -- 1813
	end -- 1813
	local cx = ctx.uiW * 0.5 -- 1815
	local cy = ctx.uiH - 134 - safe.top -- 1816
	drawSilkVeil( -- 1817
		uiDraw, -- 1817
		uiArt, -- 1817
		"rg_seg_veil", -- 1817
		cx, -- 1817
		cy, -- 1817
		460, -- 1817
		74, -- 1817
		PALETTE.inkWash, -- 1817
		0.78 * alpha, -- 1817
		2 -- 1817
	) -- 1817
	drawMistCurve( -- 1818
		uiArt, -- 1818
		"rg_seg_mist", -- 1818
		cx, -- 1818
		cy, -- 1818
		420, -- 1818
		66, -- 1818
		PALETTE.amber, -- 1818
		0.24 * alpha, -- 1818
		2 -- 1818
	) -- 1818
	drawHairline( -- 1819
		uiInkDraw, -- 1819
		uiArt, -- 1819
		"rg_seg_top", -- 1819
		cx, -- 1819
		cy + 32, -- 1819
		320, -- 1819
		PALETTE.amberCore, -- 1819
		0.58 * alpha, -- 1819
		true, -- 1819
		4 -- 1819
	) -- 1819
	drawHairline( -- 1820
		uiInkDraw, -- 1820
		uiArt, -- 1820
		"rg_seg_bot", -- 1820
		cx, -- 1820
		cy - 32, -- 1820
		280, -- 1820
		PALETTE.silkDim, -- 1820
		0.44 * alpha, -- 1820
		false, -- 1820
		4 -- 1820
	) -- 1820
	fillRadialGlow( -- 1821
		uiGlow, -- 1821
		cx, -- 1821
		cy + 6, -- 1821
		130, -- 1821
		34, -- 1821
		toColor(PALETTE.amber, 26 * alpha), -- 1821
		Color(214, 186, 146, 0), -- 1821
		12 -- 1821
	) -- 1821
	ctx.texts:put( -- 1823
		"banner", -- 1823
		self.segmentBannerHeadline, -- 1823
		cx, -- 1823
		cy + 9, -- 1823
		toColor(PALETTE.textBright), -- 1823
		0.5, -- 1823
		0.5, -- 1823
		"Center", -- 1823
		8, -- 1823
		0.96 * alpha, -- 1823
		0.12 -- 1823
	) -- 1823
	ctx.texts:put( -- 1824
		"xs", -- 1824
		self.segmentBannerSub, -- 1824
		cx, -- 1824
		cy - 18, -- 1824
		toColor(PALETTE.amberCore), -- 1824
		0.5, -- 1824
		0.5, -- 1824
		"Center", -- 1824
		1.6, -- 1824
		0.92 * alpha, -- 1824
		0.08 -- 1824
	) -- 1824
end -- 1800
function RoguelikeUiPlugin.prototype.drawDeathRecapOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, snap) -- 1829
	local elapsed = DEATH_RECAP_DURATION - self.deathRecapT -- 1837
	local fadeIn = clamp(elapsed / 0.26, 0, 1) -- 1838
	local fadeOut = clamp(self.deathRecapT / 0.44, 0, 1) -- 1839
	local alpha = easeOutCubic(fadeIn) * fadeOut -- 1840
	if alpha <= 0.01 then -- 1840
		return -- 1842
	end -- 1842
	local cx = ctx.uiW * 0.5 -- 1844
	local cy = ctx.uiH * 0.52 -- 1845
	uiDraw:drawRect( -- 1848
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1848
		Color( -- 1848
			8, -- 1848
			10, -- 1848
			16, -- 1848
			math.floor(168 * alpha + 0.5) -- 1848
		) -- 1848
	) -- 1848
	drawMistCurve( -- 1849
		uiArt, -- 1849
		"rg_recap_mist", -- 1849
		cx, -- 1849
		cy, -- 1849
		640, -- 1849
		140, -- 1849
		PALETTE.rougeSoft, -- 1849
		0.24 * alpha, -- 1849
		1 -- 1849
	) -- 1849
	fillRadialGlow( -- 1850
		uiGlow, -- 1850
		cx, -- 1850
		cy + 20, -- 1850
		220, -- 1850
		110, -- 1850
		toColor(PALETTE.rouge, 26 * alpha), -- 1850
		Color(182, 58, 56, 0), -- 1850
		14 -- 1850
	) -- 1850
	ctx.texts:put( -- 1853
		"banner", -- 1853
		"折筹重整", -- 1853
		cx, -- 1853
		cy + 88, -- 1853
		toColor(PALETTE.textBright), -- 1853
		0.5, -- 1853
		0.5, -- 1853
		"Center", -- 1853
		10, -- 1853
		0.96 * alpha, -- 1853
		0.12 -- 1853
	) -- 1853
	drawHairline( -- 1854
		uiInkDraw, -- 1854
		uiArt, -- 1854
		"rg_recap_line", -- 1854
		cx, -- 1854
		cy + 48, -- 1854
		360, -- 1854
		PALETTE.rouge, -- 1854
		0.62 * alpha, -- 1854
		true, -- 1854
		3 -- 1854
	) -- 1854
	local scatterT = clamp((elapsed - 0.22) / 1.15, 0, 1) -- 1857
	local ids = {} -- 1858
	for k in pairs(snap.ranks) do -- 1859
		if snap.ranks[k] > 0 then -- 1859
			ids[#ids + 1] = k -- 1861
		end -- 1861
	end -- 1861
	if #ids > 0 then -- 1861
		local step = 76 -- 1865
		local startX = cx - (#ids - 1) * step * 0.5 -- 1866
		local i = 0 -- 1867
		do -- 1867
			i = 0 -- 1868
			while i < #ids do -- 1868
				local tid = ids[i + 1] -- 1869
				local meta = resolveTalentVisual(tid) -- 1870
				local dir = #ids == 1 and 0 or i - (#ids - 1) * 0.5 -- 1871
				local dx = dir * easeOutCubic(scatterT) * 28 -- 1872
				local dy = easeOutCubic(scatterT) * 24 -- 1873
				local chipA = alpha * (1 - scatterT * 0.85) -- 1874
				local ix = startX + i * step + dx -- 1875
				local iy = cy + 6 + dy -- 1876
				uiDraw:drawRoundedRect( -- 1877
					Rect(ix - 24, iy - 18, 48, 36), -- 1877
					4, -- 1877
					toColor(PALETTE.inkWash, 180 * chipA), -- 1877
					0.9, -- 1877
					toColor(meta.accent, 150 * chipA) -- 1877
				) -- 1877
				drawTalentGlyph( -- 1878
					uiInkDraw, -- 1878
					ix, -- 1878
					iy, -- 1878
					12, -- 1878
					tid, -- 1878
					meta.accent, -- 1878
					chipA, -- 1878
					meta.accentCore -- 1878
				) -- 1878
				if scatterT > 0.08 then -- 1878
					uiGlow:drawDot( -- 1881
						Vec2(ix + dir * 10, iy + 14 + scatterT * 14), -- 1881
						2, -- 1881
						toColor(PALETTE.silkDim, 140 * chipA) -- 1881
					) -- 1881
					uiGlow:drawDot( -- 1882
						Vec2(ix - dir * 8, iy + 8 + scatterT * 20), -- 1882
						1.6, -- 1882
						toColor(PALETTE.rouge, 130 * chipA) -- 1882
					) -- 1882
				end -- 1882
				i = i + 1 -- 1868
			end -- 1868
		end -- 1868
	end -- 1868
	local countText = snap.totalRanks > 0 and ("曾习" .. toChineseUpper(snap.totalRanks)) .. "筹" or "尚未择筹" -- 1887
	local summary = ((((("止步于「" .. snap.stageName) .. "」 · ") .. countText) .. " · ") .. weaponMetaOf(snap.weaponId).name) .. " · 筹散人安，重整再护" -- 1888
	ctx.texts:put( -- 1889
		"sm", -- 1889
		summary, -- 1889
		cx, -- 1889
		cy - 48, -- 1889
		toColor(PALETTE.amberCore), -- 1889
		0.5, -- 1889
		0.5, -- 1889
		"Center", -- 1889
		1, -- 1889
		0.94 * alpha, -- 1889
		0.08 -- 1889
	) -- 1889
	ctx.texts:put( -- 1890
		"xs", -- 1890
		"新一轮护送将自城外巷路再启", -- 1890
		cx, -- 1890
		cy - 82, -- 1890
		toColor(PALETTE.textDim), -- 1890
		0.5, -- 1890
		0.5, -- 1890
		"Center", -- 1890
		1.2, -- 1890
		0.78 * alpha, -- 1890
		0.06 -- 1890
	) -- 1890
	if ctx.p.escortFailed then -- 1890
		local btns = ____exports.computeEscortDeathButtons(ctx.uiW, ctx.uiH) -- 1892
		local boxes = {btns.retry, btns.title} -- 1893
		do -- 1893
			local i = 0 -- 1894
			while i < #boxes do -- 1894
				local box = boxes[i + 1] -- 1895
				local color = i == self.deathSelected and PALETTE.amberCore or PALETTE.silkLine -- 1896
				uiDraw:drawRoundedRect( -- 1897
					box, -- 1897
					4, -- 1897
					toColor(PALETTE.inkWash, 220), -- 1897
					1.2, -- 1897
					toColor(color) -- 1897
				) -- 1897
				ctx.texts:put( -- 1898
					"sm", -- 1898
					i == 0 and "重整再赴" or "返回标题", -- 1898
					box.x + box.width / 2, -- 1898
					box.y + box.height / 2, -- 1899
					toColor(color), -- 1899
					0.5, -- 1899
					0.5, -- 1899
					"Center" -- 1899
				) -- 1899
				i = i + 1 -- 1894
			end -- 1894
		end -- 1894
	end -- 1894
end -- 1829
function RoguelikeUiPlugin.prototype.drawBuildLedger(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, rg, safe) -- 1906
	local appear = easeOutCubic(self.ledgerAnimT) -- 1915
	local cx = ctx.uiW * 0.5 -- 1916
	local pageW = math.min(ctx.uiW - 96 - safe.left - safe.right, 880) -- 1917
	local pageH = math.min(ctx.uiH - 116 - safe.top - safe.bottom, 504) -- 1918
	local px = cx - pageW * 0.5 -- 1919
	local py = (ctx.uiH - pageH) * 0.5 + (1 - appear) * -14 -- 1920
	local midY = py + pageH * 0.5 -- 1921
	self.ledgerPanelBox = Rect(px, py, pageW, pageH) -- 1922
	uiDraw:drawRect( -- 1925
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1925
		Color( -- 1925
			7, -- 1925
			9, -- 1925
			15, -- 1925
			math.floor(188 * appear + 0.5) -- 1925
		) -- 1925
	) -- 1925
	uiArt:tryPlace( -- 1926
		"ink_frame_mask", -- 1926
		"rg_led_sh", -- 1926
		cx, -- 1926
		midY - 6, -- 1926
		pageW + 52, -- 1926
		pageH + 46, -- 1926
		{ -- 1926
			color = toColor(PALETTE.voidDark), -- 1927
			opacity = 0.84 * appear, -- 1927
			layer = -1 -- 1927
		} -- 1927
	) -- 1927
	if not uiArt:tryPlace( -- 1927
		"ink_song_paper", -- 1929
		"rg_led_paper", -- 1929
		cx, -- 1929
		midY, -- 1929
		pageW, -- 1929
		pageH, -- 1929
		{opacity = 0.98 * appear, layer = 1} -- 1929
	) then -- 1929
		uiDraw:drawRect( -- 1930
			Rect(px, py, pageW, pageH), -- 1930
			toColor(PALETTE.xuanPaper, 248 * appear), -- 1930
			1, -- 1930
			toColor(PALETTE.silkDim, 180 * appear) -- 1930
		) -- 1930
	end -- 1930
	fillRadialGlow( -- 1932
		uiGlow, -- 1932
		cx, -- 1932
		midY + 36, -- 1932
		260, -- 1932
		140, -- 1932
		Color( -- 1932
			236, -- 1932
			224, -- 1932
			202, -- 1932
			math.floor(16 * appear + 0.5) -- 1932
		), -- 1932
		Color(236, 224, 202, 0), -- 1932
		14 -- 1932
	) -- 1932
	local inX = px + 36 -- 1935
	local inY = py + 28 -- 1936
	local inW = pageW - 72 -- 1937
	local inH = pageH - 56 -- 1938
	local redSilk = toColor(PALETTE.rouge, 118 * appear) -- 1939
	local redFaint = toColor(PALETTE.rouge, 56 * appear) -- 1940
	uiInkDraw:drawRect( -- 1941
		Rect(inX, inY, inW, inH), -- 1941
		Color(0, 0, 0, 0), -- 1941
		0.95, -- 1941
		redSilk -- 1941
	) -- 1941
	uiInkDraw:drawRect( -- 1942
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1942
		Color(0, 0, 0, 0), -- 1942
		0.55, -- 1942
		redFaint -- 1942
	) -- 1942
	local headY = inY + inH - 26 -- 1945
	local routeZh = rg.routeTag == "drygoods" and " · 布行暗渡" or (rg.routeTag == "outer" and " · 外檐强行" or "") -- 1946
	ctx.texts:put( -- 1947
		"lg", -- 1947
		"行军札记", -- 1947
		inX + 18, -- 1947
		headY, -- 1947
		toColor(PALETTE.xuanInk), -- 1947
		0, -- 1947
		0.5, -- 1947
		"Left", -- 1947
		3, -- 1947
		0.96 * appear, -- 1947
		0 -- 1947
	) -- 1947
	local metaInfo = ((("筹号 " .. tostring(rg.seed)) .. "  ·  用时 ") .. mmss(rg.ticks)) .. routeZh -- 1948
	ctx.texts:put( -- 1949
		"xs", -- 1949
		metaInfo, -- 1949
		inX + 158, -- 1949
		headY - 2, -- 1949
		toColor(PALETTE.xuanInkSub), -- 1949
		0, -- 1949
		0.5, -- 1949
		"Left", -- 1949
		1, -- 1949
		0.88 * appear, -- 1949
		0 -- 1949
	) -- 1949
	local closeW = 76 -- 1952
	local closeH = 26 -- 1953
	local closeRect = Rect(inX + inW - closeW - 14, headY - closeH * 0.5, closeW, closeH) -- 1954
	self.ledgerCloseBox = closeRect -- 1955
	uiInkDraw:drawRect( -- 1956
		closeRect, -- 1956
		Color( -- 1956
			168, -- 1956
			46, -- 1956
			44, -- 1956
			math.floor(28 * appear + 0.5) -- 1956
		), -- 1956
		0.9, -- 1956
		toColor(PALETTE.rouge, 185 * appear) -- 1956
	) -- 1956
	ctx.texts:put( -- 1957
		"xs", -- 1957
		"合卷", -- 1957
		closeRect.x + closeW * 0.5, -- 1957
		headY, -- 1957
		toColor(PALETTE.rouge), -- 1957
		0.5, -- 1957
		0.5, -- 1957
		"Center", -- 1957
		1.4, -- 1957
		0.95 * appear, -- 1957
		0 -- 1957
	) -- 1957
	uiInkDraw:drawSegment( -- 1958
		Vec2(inX + 12, headY - 20), -- 1958
		Vec2(inX + inW - 12, headY - 20), -- 1958
		0.85, -- 1958
		redSilk -- 1958
	) -- 1958
	local foldX = inX + inW * 0.48 -- 1961
	uiInkDraw:drawSegment( -- 1962
		Vec2(foldX - 3, inY + 12), -- 1962
		Vec2(foldX - 3, headY - 26), -- 1962
		0.65, -- 1962
		redFaint -- 1962
	) -- 1962
	uiInkDraw:drawSegment( -- 1963
		Vec2(foldX + 3, inY + 12), -- 1963
		Vec2(foldX + 3, headY - 26), -- 1963
		0.65, -- 1963
		redFaint -- 1963
	) -- 1963
	local leftX = inX + 18 -- 1966
	local leftW = foldX - leftX - 18 -- 1967
	local secTopY = headY - 40 -- 1968
	ctx.texts:put( -- 1969
		"sm", -- 1969
		"此行舆图与兵备", -- 1969
		leftX, -- 1969
		secTopY, -- 1969
		toColor(PALETTE.rouge), -- 1969
		0, -- 1969
		0.5, -- 1969
		"Left", -- 1969
		1.6, -- 1969
		0.92 * appear, -- 1969
		0 -- 1969
	) -- 1969
	local stY = secTopY - 34 -- 1972
	local stages = rg.stages -- 1973
	if #stages > 0 then -- 1973
		local sx0 = leftX + 14 -- 1975
		local sx1 = leftX + leftW - 14 -- 1976
		local step = #stages > 1 and (sx1 - sx0) / (#stages - 1) or 0 -- 1977
		uiInkDraw:drawSegment( -- 1978
			Vec2(sx0, stY), -- 1978
			Vec2(sx1, stY), -- 1978
			0.9, -- 1978
			toColor(PALETTE.xuanInkSub, 130 * appear) -- 1978
		) -- 1978
		local si = 0 -- 1979
		do -- 1979
			si = 0 -- 1980
			while si < #stages do -- 1980
				local st = stages[si + 1] -- 1981
				local nx = sx0 + si * step -- 1982
				if st.current then -- 1982
					drawDiamond( -- 1984
						uiInkDraw, -- 1984
						nx, -- 1984
						stY, -- 1984
						5.5, -- 1984
						5.5, -- 1984
						toColor(PALETTE.rouge, 235 * appear) -- 1984
					) -- 1984
				elseif st.cleared then -- 1984
					drawDiamond( -- 1986
						uiInkDraw, -- 1986
						nx, -- 1986
						stY, -- 1986
						4.5, -- 1986
						4.5, -- 1986
						toColor(PALETTE.xuanInk, 210 * appear) -- 1986
					) -- 1986
				else -- 1986
					drawDiamond( -- 1988
						uiInkDraw, -- 1988
						nx, -- 1988
						stY, -- 1988
						4, -- 1988
						4, -- 1988
						Color(232, 227, 216, 255), -- 1988
						0.9, -- 1988
						toColor(PALETTE.xuanInkSub, 150 * appear) -- 1988
					) -- 1988
				end -- 1988
				ctx.texts:put( -- 1990
					"xs", -- 1990
					st.label, -- 1990
					nx, -- 1990
					stY - 18, -- 1990
					toColor(st.current and PALETTE.rouge or PALETTE.xuanInk), -- 1990
					0.5, -- 1990
					0.5, -- 1990
					"Center", -- 1990
					0.2, -- 1990
					(st.current and 0.98 or 0.78) * appear, -- 1990
					0 -- 1990
				) -- 1990
				si = si + 1 -- 1980
			end -- 1980
		end -- 1980
	end -- 1980
	local gunBoxY = stY - 142 -- 1995
	local gunBoxH = 104 -- 1996
	local wMeta = weaponMetaOf(rg.equippedWeapon) -- 1997
	uiInkDraw:drawRect( -- 1998
		Rect(leftX, gunBoxY, leftW, gunBoxH), -- 1998
		Color( -- 1998
			32, -- 1998
			30, -- 1998
			32, -- 1998
			math.floor(14 * appear + 0.5) -- 1998
		), -- 1998
		0.85, -- 1998
		redFaint -- 1998
	) -- 1998
	ctx.texts:put( -- 1999
		"sm", -- 1999
		wMeta.name, -- 1999
		leftX + 12, -- 1999
		gunBoxY + gunBoxH - 20, -- 1999
		toColor(PALETTE.xuanInk), -- 1999
		0, -- 1999
		0.5, -- 1999
		"Left", -- 1999
		1.2, -- 1999
		0.96 * appear, -- 1999
		0 -- 1999
	) -- 1999
	ctx.texts:put( -- 2000
		"xs", -- 2000
		(((("装填 " .. tostring(rg.reloadTicksNow)) .. " 拍  ·  体力 ") .. tostring(rg.hp)) .. "/") .. tostring(rg.maxHp), -- 2000
		leftX + 12, -- 2000
		gunBoxY + gunBoxH - 44, -- 2000
		toColor(PALETTE.xuanInkSub), -- 2000
		0, -- 2000
		0.5, -- 2000
		"Left", -- 2000
		0.4, -- 2000
		0.88 * appear, -- 2000
		0 -- 2000
	) -- 2000
	ctx.texts:put( -- 2001
		"xs", -- 2001
		wMeta.desc, -- 2001
		leftX + 12, -- 2001
		gunBoxY + 26, -- 2001
		toColor(PALETTE.xuanInkSub), -- 2001
		0, -- 2001
		0.5, -- 2001
		"Left", -- 2001
		0.2, -- 2001
		0.82 * appear, -- 2001
		0 -- 2001
	) -- 2001
	local gridCx = leftX + leftW - 44 -- 2004
	local gridCy = gunBoxY + gunBoxH * 0.5 -- 2005
	local gStep = 22 -- 2006
	local gi = 0 -- 2007
	do -- 2007
		gi = 0 -- 2008
		while gi < #RELOAD_GRID do -- 2008
			local node = RELOAD_GRID[gi + 1] -- 2009
			local gx = gridCx + (node.col - 1) * gStep -- 2010
			local gy = gridCy + (node.row - 1) * gStep -- 2011
			local isEnhanced = wMeta.effect == "light" and node.kind == "lamp" or wMeta.effect == "echo" and node.kind == "bell" -- 2012
			if node.kind == "lamp" or node.kind == "bell" then -- 2012
				drawReloadPatternGlyph( -- 2015
					uiInkDraw, -- 2016
					gx, -- 2017
					gy, -- 2018
					isEnhanced and 8 or 6.2, -- 2019
					node.kind == "lamp" and "light" or "echo", -- 2020
					isEnhanced and PALETTE.rouge or PALETTE.xuanInkSub, -- 2021
					(isEnhanced and 0.96 or 0.55) * appear -- 2022
				) -- 2022
			else -- 2022
				uiInkDraw:drawDot( -- 2025
					Vec2(gx, gy), -- 2025
					(node.kind == "start" or node.kind == "target") and 3 or 2, -- 2025
					toColor(PALETTE.xuanInkSub, 150 * appear) -- 2025
				) -- 2025
			end -- 2025
			gi = gi + 1 -- 2008
		end -- 2008
	end -- 2008
	local invTitleY = gunBoxY - 22 -- 2030
	ctx.texts:put( -- 2031
		"xs", -- 2031
		"随身战备清点", -- 2031
		leftX, -- 2031
		invTitleY, -- 2031
		toColor(PALETTE.rouge), -- 2031
		0, -- 2031
		0.5, -- 2031
		"Left", -- 2031
		1.2, -- 2031
		0.88 * appear, -- 2031
		0 -- 2031
	) -- 2031
	local drawnInv = 0 -- 2032
	local ii = 0 -- 2033
	do -- 2033
		ii = 0 -- 2034
		while ii < #PICKUP_ORDER do -- 2034
			do -- 2034
				local k = PICKUP_ORDER[ii + 1] -- 2035
				local cnt = rg.supplies[k] or 0 -- 2036
				if cnt <= 0 then -- 2036
					goto __continue271 -- 2038
				end -- 2038
				local col = drawnInv % 2 -- 2040
				local row = math.floor(drawnInv / 2) -- 2041
				if row >= 3 then -- 2041
					break -- 2043
				end -- 2043
				local ix = leftX + col * (leftW * 0.5) -- 2045
				local iy = invTitleY - 26 - row * 28 -- 2046
				local pm = pickupMetaOf(k) -- 2047
				drawPickupGlyph( -- 2048
					uiInkDraw, -- 2048
					ix + 10, -- 2048
					iy, -- 2048
					7.2, -- 2048
					k, -- 2048
					0.92 * appear, -- 2048
					PALETTE.xuanInk -- 2048
				) -- 2048
				ctx.texts:put( -- 2049
					"xs", -- 2049
					(pm.name .. " ×") .. tostring(cnt), -- 2049
					ix + 24, -- 2049
					iy, -- 2049
					toColor(PALETTE.xuanInk), -- 2049
					0, -- 2049
					0.5, -- 2049
					"Left", -- 2049
					0.4, -- 2049
					0.9 * appear, -- 2049
					0 -- 2049
				) -- 2049
				drawnInv = drawnInv + 1 -- 2050
			end -- 2050
			::__continue271:: -- 2050
			ii = ii + 1 -- 2034
		end -- 2034
	end -- 2034
	if drawnInv == 0 then -- 2034
		ctx.texts:put( -- 2053
			"xs", -- 2053
			"行囊尚空，沿途可拾筹材与战备。", -- 2053
			leftX, -- 2053
			invTitleY - 28, -- 2053
			toColor(PALETTE.xuanInkSub), -- 2053
			0, -- 2053
			0.5, -- 2053
			"Left", -- 2053
			0.6, -- 2053
			0.78 * appear, -- 2053
			0 -- 2053
		) -- 2053
	end -- 2053
	local rightX = foldX + 20 -- 2057
	local rightW = inX + inW - rightX - 18 -- 2058
	ctx.texts:put( -- 2059
		"sm", -- 2059
		"已习本领谱", -- 2059
		rightX, -- 2059
		secTopY, -- 2059
		toColor(PALETTE.rouge), -- 2059
		0, -- 2059
		0.5, -- 2059
		"Left", -- 2059
		1.6, -- 2059
		0.92 * appear, -- 2059
		0 -- 2059
	) -- 2059
	local learned = {} -- 2061
	for k in pairs(rg.ranks) do -- 2062
		if (rg.ranks[k] or 0) > 0 then -- 2062
			learned[#learned + 1] = k -- 2064
		end -- 2064
	end -- 2064
	if #learned == 0 then -- 2064
		ctx.texts:put( -- 2068
			"sm", -- 2068
			"尚未择筹 · 途中整备可习军筹", -- 2068
			rightX, -- 2068
			secTopY - 56, -- 2068
			toColor(PALETTE.xuanInkSub), -- 2068
			0, -- 2068
			0.5, -- 2068
			"Left", -- 2068
			0.8, -- 2068
			0.82 * appear, -- 2068
			0 -- 2068
		) -- 2068
	else -- 2068
		local li = 0 -- 2070
		do -- 2070
			li = 0 -- 2071
			while li < #learned and li < 5 do -- 2071
				local tid = learned[li + 1] -- 2072
				local rank = rg.ranks[tid] or 1 -- 2073
				local meta = resolveTalentVisual(tid, rg) -- 2074
				local rowY = secTopY - 46 - li * 56 -- 2075
				uiInkDraw:drawRect( -- 2076
					Rect(rightX, rowY - 22, rightW, 46), -- 2076
					Color( -- 2076
						32, -- 2076
						30, -- 2076
						32, -- 2076
						math.floor(12 * appear + 0.5) -- 2076
					), -- 2076
					0.75, -- 2076
					redFaint -- 2076
				) -- 2076
				drawTalentGlyph( -- 2077
					uiInkDraw, -- 2077
					rightX + 24, -- 2077
					rowY + 1, -- 2077
					13, -- 2077
					tid, -- 2077
					PALETTE.xuanInk, -- 2077
					0.92 * appear, -- 2077
					PALETTE.rouge -- 2077
				) -- 2077
				ctx.texts:put( -- 2078
					"sm", -- 2078
					((meta.title .. " · ") .. rankChinese(rank)) .. "阶", -- 2078
					rightX + 48, -- 2078
					rowY + 10, -- 2078
					toColor(PALETTE.xuanInk), -- 2078
					0, -- 2078
					0.5, -- 2078
					"Left", -- 2078
					1, -- 2078
					0.96 * appear, -- 2078
					0 -- 2078
				) -- 2078
				ctx.texts:put( -- 2079
					"xs", -- 2079
					meta:ledgerLine(rg, rank), -- 2079
					rightX + 48, -- 2079
					rowY - 10, -- 2079
					toColor(PALETTE.xuanInkSub), -- 2079
					0, -- 2079
					0.5, -- 2079
					"Left", -- 2079
					0.4, -- 2079
					0.88 * appear, -- 2079
					0 -- 2079
				) -- 2079
				li = li + 1 -- 2071
			end -- 2071
		end -- 2071
	end -- 2071
	local march = deriveMarchTitle(rg) -- 2084
	local footY = inY + 46 -- 2085
	uiInkDraw:drawSegment( -- 2086
		Vec2(rightX, footY + 36), -- 2086
		Vec2(rightX + rightW, footY + 36), -- 2086
		0.7, -- 2086
		redFaint -- 2086
	) -- 2086
	ctx.texts:put( -- 2087
		"xs", -- 2087
		"此行雅号", -- 2087
		rightX, -- 2087
		footY + 20, -- 2087
		toColor(PALETTE.xuanInkSub), -- 2087
		0, -- 2087
		0.5, -- 2087
		"Left", -- 2087
		1.4, -- 2087
		0.82 * appear, -- 2087
		0 -- 2087
	) -- 2087
	ctx.texts:put( -- 2088
		"md", -- 2088
		("「" .. march.title) .. "」", -- 2088
		rightX - 4, -- 2088
		footY - 2, -- 2088
		toColor(PALETTE.xuanInk), -- 2088
		0, -- 2088
		0.5, -- 2088
		"Left", -- 2088
		2.2, -- 2088
		0.96 * appear, -- 2088
		0 -- 2088
	) -- 2088
	ctx.texts:put( -- 2089
		"xs", -- 2089
		march.subtitle, -- 2089
		rightX + 4, -- 2089
		footY - 24, -- 2089
		toColor(PALETTE.xuanInkSub), -- 2089
		0, -- 2089
		0.5, -- 2089
		"Left", -- 2089
		0.8, -- 2089
		0.86 * appear, -- 2089
		0 -- 2089
	) -- 2089
	drawLoneSeal( -- 2090
		uiInkDraw, -- 2091
		uiArt, -- 2092
		ctx.texts, -- 2093
		"rg_ledger_seal", -- 2094
		rightX + rightW - 22, -- 2095
		footY + 2, -- 2096
		24, -- 2097
		46, -- 2098
		march.sealTop, -- 2099
		march.sealBot, -- 2100
		PALETTE.sealRed, -- 2101
		PALETTE.sealText, -- 2102
		0.94 * appear, -- 2103
		5 -- 2104
	) -- 2104
end -- 1906
return ____exports -- 1906