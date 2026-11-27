-- [ts]: craft_bench.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Rect = ____Dora.Rect -- 17
local Vec2 = ____Dora.Vec2 -- 17
local ____platform = require("Script.watch.platform") -- 19
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 19
local ____target = require("Script.watch.target") -- 20
local getActiveTarget = ____target.getActiveTarget -- 20
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 30
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 30
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 31
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 32
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 33
local ____theme = require("Script.watch.fe.theme") -- 35
local PALETTE = ____theme.PALETTE -- 36
local drawBlossomDot = ____theme.drawBlossomDot -- 38
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 39
local drawHairline = ____theme.drawHairline -- 40
local drawSilkRibbon = ____theme.drawSilkRibbon -- 41
local drawSilkVeil = ____theme.drawSilkVeil -- 42
local fillRadialGlow = ____theme.fillRadialGlow -- 43
local fillVGradRect = ____theme.fillVGradRect -- 44
local toColor = ____theme.toColor -- 45
local MATERIAL_NAMES = { -- 48
	wood = "木纹筹", -- 49
	bell = "铃纹筹", -- 50
	wood_tally = "木纹筹", -- 51
	bell_tally = "铃纹筹", -- 52
	scrap = "旧木料", -- 53
	wedge = "木楔", -- 54
	ammo = "备用弹" -- 55
} -- 55
local WOOD_TOP = Color(98, 68, 48, 252) -- 58
local WOOD_BODY = Color(58, 40, 30, 250) -- 59
local WOOD_EDGE = Color(152, 114, 82, 235) -- 60
local WOOD_DARK = Color(30, 21, 17, 248) -- 61
local function materialLabel(key) -- 88
	return MATERIAL_NAMES[key] or key -- 89
end -- 88
local function resolveRuntimeContract(injected) -- 92
	if injected ~= nil then -- 93
		return injected -- 94
	end -- 94
	local g = _G -- 96
	local ____temp_0 -- 97
	if g.package ~= nil then -- 97
		____temp_0 = g.package.loaded -- 97
	else -- 97
		____temp_0 = nil -- 97
	end -- 97
	local loaded = ____temp_0 -- 97
	if loaded == nil then -- 98
		return nil -- 99
	end -- 99
	local feHook = loaded["watch.fe"] -- 101
	if feHook ~= nil and type(feHook) == "table" then -- 102
		local c = feHook.contract -- 103
		if c ~= nil and type(c) == "table" then -- 104
			return c -- 105
		end -- 105
	end -- 105
	return nil -- 108
end -- 92
local function dispatchIntentFallback(p, intent) -- 111
	local rec = p -- 112
	local handler = rec.submitFeIntent -- 113
	if type(handler) == "function" then -- 114
		return handler(p, intent) ~= false -- 115
	end -- 115
	return false -- 117
end -- 111
local function collectMissingMaterials(recipe, inventory) -- 120
	local missing = {} -- 124
	for mat in pairs(recipe.cost) do -- 125
		local need = recipe.cost[mat] -- 126
		local have = inventory[mat] or 0 -- 127
		if have < need then -- 128
			missing[#missing + 1] = mat -- 129
		end -- 129
	end -- 129
	return missing -- 132
end -- 120
local function sortedMaterialKeys(inventory, recipes) -- 135
	local seen = {} -- 139
	local out = {} -- 140
	local prefer = {"wood", "bell", "wood_tally", "bell_tally"} -- 142
	local hasBackendKeys = inventory.wood ~= nil or inventory.bell ~= nil -- 143
	local i = 0 -- 144
	do -- 144
		i = 0 -- 145
		while i < #recipes do -- 145
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 146
				hasBackendKeys = true -- 147
			end -- 147
			i = i + 1 -- 145
		end -- 145
	end -- 145
	local primary = hasBackendKeys and ({"wood", "bell"}) or ({"wood_tally", "bell_tally"}) -- 150
	do -- 150
		i = 0 -- 151
		while i < #primary do -- 151
			seen[primary[i + 1]] = true -- 152
			out[#out + 1] = primary[i + 1] -- 153
			i = i + 1 -- 151
		end -- 151
	end -- 151
	do -- 151
		i = 0 -- 155
		while i < #recipes do -- 155
			local cost = recipes[i + 1].cost -- 156
			for k in pairs(cost) do -- 157
				if not seen[k] then -- 158
					seen[k] = true -- 159
					out[#out + 1] = k -- 160
				end -- 160
			end -- 160
			i = i + 1 -- 155
		end -- 155
	end -- 155
	do -- 155
		i = 0 -- 164
		while i < #prefer do -- 164
			local k = prefer[i + 1] -- 165
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 166
				seen[k] = true -- 167
				out[#out + 1] = k -- 168
			end -- 168
			i = i + 1 -- 164
		end -- 164
	end -- 164
	return out -- 171
end -- 135
____exports.CraftBenchPlugin = __TS__Class() -- 174
local CraftBenchPlugin = ____exports.CraftBenchPlugin -- 174
CraftBenchPlugin.name = "CraftBenchPlugin" -- 174
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 212
	self.id = "fe-02-craft-bench" -- 175
	self.wasActive = false -- 179
	self.selectedIdx = 0 -- 180
	self.animTime = 0 -- 181
	self.openAnimT = 0 -- 182
	self.requestSeq = 0 -- 185
	self.pendingRecipeId = "" -- 186
	self.pendingFirstCraftAtSubmit = true -- 187
	self.prevCraftedMap = {} -- 188
	self.missingFlashT = 0 -- 191
	self.missingList = {} -- 192
	self.handoverRemaining = 0 -- 195
	self.handoverDuration = 1 -- 196
	self.handoverWeaponId = "" -- 197
	self.handoverWeaponName = "" -- 198
	self.handoverEffect = "light" -- 199
	self.prevLeft = false -- 202
	self.prevRight = false -- 203
	self.pointerActive = false -- 204
	self.cardBoxes = {} -- 207
	self.closeBox = Rect(0, 0, 0, 0) -- 208
	self.injectedContract = contract -- 213
end -- 212
function CraftBenchPlugin.prototype.injectInputForTest(self, sim) -- 217
	self.pendingSimInput = sim -- 218
end -- 217
function CraftBenchPlugin.prototype.getState(self) -- 221
	local inv = {} -- 222
	local craftedIds = {} -- 223
	local equipped = "standard_gun" -- 224
	if self.lastSnapshotBench ~= nil then -- 225
		for k in pairs(self.lastSnapshotBench.inventory) do -- 226
			inv[k] = self.lastSnapshotBench.inventory[k] -- 227
		end -- 227
		local i = 0 -- 229
		do -- 229
			i = 0 -- 230
			while i < #self.lastSnapshotBench.recipes do -- 230
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 231
					craftedIds[#craftedIds + 1] = self.lastSnapshotBench.recipes[i + 1].id -- 232
				end -- 232
				i = i + 1 -- 230
			end -- 230
		end -- 230
		equipped = self.lastSnapshotBench.equippedWeapon -- 235
	end -- 235
	return { -- 237
		active = self.wasActive, -- 238
		selectedIndex = self.selectedIdx, -- 239
		pendingRecipeId = self.pendingRecipeId, -- 240
		missingFlashT = self.missingFlashT, -- 241
		missingMaterials = __TS__ArraySlice(self.missingList), -- 242
		handoverActive = self.handoverRemaining > 0, -- 243
		handoverDuration = self.handoverDuration, -- 244
		handoverRemaining = self.handoverRemaining, -- 245
		handoverWeaponId = self.handoverWeaponId, -- 246
		equippedWeapon = equipped, -- 247
		inventory = inv, -- 248
		craftedIds = craftedIds -- 249
	} -- 249
end -- 221
function CraftBenchPlugin.prototype.onBindPlay(self, _p, view) -- 253
	self.wasActive = view.craftBench.active -- 255
	self.selectedIdx = 0 -- 256
	self.animTime = 0 -- 257
	self.openAnimT = view.craftBench.active and 1 or 0 -- 258
	self.pendingRecipeId = "" -- 259
	self.pendingFirstCraftAtSubmit = not view.craftBench.firstCraftDone -- 260
	self.missingFlashT = 0 -- 261
	self.missingList = {} -- 262
	self.handoverRemaining = 0 -- 263
	self.handoverDuration = 1 -- 264
	self.handoverWeaponId = "" -- 265
	self.handoverWeaponName = "" -- 266
	self.pendingSimInput = nil -- 267
	self:syncCraftedSnapshot(view.craftBench) -- 268
	self.lastSnapshotBench = view.craftBench -- 269
	self:resetInputEdges() -- 270
end -- 253
function CraftBenchPlugin.prototype.syncCraftedSnapshot(self, bench) -- 273
	self.prevCraftedMap = {} -- 274
	local i = 0 -- 275
	do -- 275
		i = 0 -- 276
		while i < #bench.recipes do -- 276
			self.prevCraftedMap[bench.recipes[i + 1].id] = bench.recipes[i + 1].crafted -- 277
			i = i + 1 -- 276
		end -- 276
	end -- 276
end -- 273
function CraftBenchPlugin.prototype.resetInputEdges(self, _touchMode) -- 281
	if _touchMode == nil then -- 281
		_touchMode = false -- 281
	end -- 281
	self.prevLeft = false -- 282
	self.prevRight = false -- 283
end -- 281
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 286
	local contract = resolveRuntimeContract(self.injectedContract) -- 287
	if contract ~= nil then -- 288
		return contract:submitIntent(p, intent) -- 289
	end -- 289
	return dispatchIntentFallback(p, intent) -- 291
end -- 286
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 294
	local uiW = ctx.uiW -- 301
	local uiH = ctx.uiH -- 302
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 303
	local touchMode = ctx.input:isTouchMode() -- 304
	local count = math.max(1, recipeCount) -- 305
	local wantW = count >= 3 and 840 or 692 -- 306
	local benchW = math.min(uiW - 44 - safe.left - safe.right, wantW) -- 307
	local benchH = 290 -- 308
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 310
	local minX = 24 + safe.left -- 311
	local maxX = math.max(minX, uiW - benchW - 24 - safe.right) -- 312
	local benchX = count >= 3 and math.max(minX, (uiW - benchW) * 0.5) or (soldierUiX < uiW * 0.52 and maxX or minX) -- 313
	local benchY = math.max( -- 316
		46 + safe.bottom, -- 316
		math.min(uiH * 0.1 + safe.bottom, 66 + safe.bottom) -- 316
	) -- 316
	local matW = count >= 3 and 168 or 196 -- 317
	local cardsAreaX = benchX + matW + 16 -- 319
	local cardsAreaW = benchW - matW - 30 -- 320
	local gap = count >= 3 and 10 or 14 -- 321
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 322
	local cardH = benchH - 72 -- 323
	local cardY = benchY + 20 -- 324
	self.cardBoxes = {} -- 326
	local i = 0 -- 327
	do -- 327
		i = 0 -- 328
		while i < count do -- 328
			local ____self_cardBoxes_1 = self.cardBoxes -- 329
			____self_cardBoxes_1[#____self_cardBoxes_1 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 329
			i = i + 1 -- 328
		end -- 328
	end -- 328
	local closeW = touchMode and 88 or 76 -- 331
	local closeH = touchMode and 32 or 26 -- 332
	self.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH) -- 333
	return { -- 334
		benchX = benchX, -- 334
		benchY = benchY, -- 334
		benchW = benchW, -- 334
		benchH = benchH, -- 334
		matW = matW -- 334
	} -- 334
end -- 294
function CraftBenchPlugin.prototype.update(self, ctx) -- 337
	local bench = ctx.view.craftBench -- 338
	self.lastSnapshotBench = bench -- 339
	if ctx.paused then -- 342
		self:resetInputEdges(ctx.input:isTouchMode()) -- 343
		return -- 344
	end -- 344
	local udt = math.max(0, ctx.uiDt) -- 347
	self.animTime = self.animTime + udt -- 348
	if self.missingFlashT > 0 then -- 350
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 351
	end -- 351
	if self.handoverRemaining > 0 then -- 353
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 354
	end -- 354
	self:detectCraftCompletion(ctx, bench) -- 358
	if bench.active and not self.wasActive then -- 360
		self.openAnimT = 0 -- 361
		self.pendingRecipeId = "" -- 362
		self.missingFlashT = 0 -- 363
		self.missingList = {} -- 364
		self.selectedIdx = math.max( -- 365
			0, -- 365
			math.min( -- 365
				math.max(0, #bench.recipes - 1), -- 365
				self.selectedIdx -- 365
			) -- 365
		) -- 365
		self:resetInputEdges(ctx.input:isTouchMode()) -- 366
	elseif not bench.active and self.wasActive then -- 367
		self.pendingRecipeId = "" -- 368
		self.missingFlashT = 0 -- 369
	end -- 369
	self.wasActive = bench.active -- 371
	if not bench.active then -- 373
		self.pendingSimInput = nil -- 374
		return -- 375
	end -- 375
	self.openAnimT = math.min(1, self.openAnimT + udt / 0.22) -- 378
	self:computeLayout(ctx, #bench.recipes) -- 379
	self:processInputs(ctx, bench) -- 382
end -- 337
function CraftBenchPlugin.prototype.detectCraftCompletion(self, ctx, bench) -- 385
	local newlyCrafted -- 386
	local i = 0 -- 387
	do -- 387
		i = 0 -- 388
		while i < #bench.recipes do -- 388
			local r = bench.recipes[i + 1] -- 389
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 390
				newlyCrafted = r -- 391
			end -- 391
			self.prevCraftedMap[r.id] = r.crafted -- 393
			i = i + 1 -- 388
		end -- 388
	end -- 388
	do -- 388
		i = 0 -- 397
		while i < #ctx.events.rawEvents do -- 397
			local ename = ctx.events.rawEvents[i + 1].name -- 398
			if ename == "benchRejected" then -- 399
				self.pendingRecipeId = "" -- 400
				self.missingFlashT = 0.45 -- 401
			end -- 401
			i = i + 1 -- 397
		end -- 397
	end -- 397
	if newlyCrafted ~= nil then -- 405
		local ____temp_2 -- 406
		if self.pendingRecipeId == newlyCrafted.id then -- 406
			____temp_2 = self.pendingFirstCraftAtSubmit -- 407
		else -- 407
			____temp_2 = bench.justCraftedTimer >= 0.72 -- 408
		end -- 408
		local isFirst = ____temp_2 -- 406
		self.pendingRecipeId = "" -- 409
		self.handoverWeaponId = newlyCrafted.id -- 410
		self.handoverWeaponName = newlyCrafted.name -- 411
		self.handoverEffect = newlyCrafted.enhancedEffect -- 412
		self.handoverDuration = isFirst and 1 or 0.45 -- 413
		self.handoverRemaining = self.handoverDuration -- 414
		local hasBackendDone = false -- 416
		do -- 416
			i = 0 -- 417
			while i < #ctx.events.rawEvents do -- 417
				local ename = ctx.events.rawEvents[i + 1].name -- 418
				if ename == "craftDone" or ename == "benchCraft" then -- 419
					hasBackendDone = true -- 420
					break -- 421
				end -- 421
				i = i + 1 -- 417
			end -- 417
		end -- 417
		if not hasBackendDone then -- 424
			ctx.audio:playOnce( -- 425
				(("fe02:craft_done:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. newlyCrafted.id, -- 426
				"sfx", -- 427
				"assets/audio/combat/craft_done.wav", -- 428
				0.88, -- 429
				"craft:done:" .. newlyCrafted.id, -- 430
				ctx.p.ticks -- 431
			) -- 431
		end -- 431
	end -- 431
end -- 385
function CraftBenchPlugin.prototype.processInputs(self, ctx, bench) -- 437
	local sim = self.pendingSimInput -- 438
	self.pendingSimInput = nil -- 439
	local touchMode = ctx.input:isTouchMode() -- 441
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 442
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 444
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 447
	local ____temp_12 -- 450
	if (sim and sim.pointerX) ~= nil then -- 450
		____temp_12 = true -- 451
	else -- 451
		local ____useUiPtr_11 -- 452
		if useUiPtr then -- 452
			____useUiPtr_11 = ctx.input.uiInside -- 452
		else -- 452
			____useUiPtr_11 = ctx.input.inside -- 452
		end -- 452
		____temp_12 = ____useUiPtr_11 -- 452
	end -- 452
	local inside = ____temp_12 -- 450
	local ____temp_15 -- 453
	if (sim and sim.click) ~= nil then -- 453
		____temp_15 = sim.click -- 454
	else -- 454
		____temp_15 = ctx.input.uiHeld or ctx.input.fire.held -- 455
	end -- 455
	local leftHeld = ____temp_15 -- 453
	local ____temp_18 -- 456
	if (sim and sim.rightClick) ~= nil then -- 456
		____temp_18 = sim.rightClick -- 457
	else -- 457
		____temp_18 = ctx.input.uiRightPressed -- 458
	end -- 458
	local rightHeld = ____temp_18 -- 456
	local ____temp_21 -- 460
	if (sim and sim.click) ~= nil then -- 460
		____temp_21 = sim.click -- 461
	else -- 461
		____temp_21 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 462
	end -- 462
	local click = ____temp_21 -- 460
	local ____temp_24 -- 463
	if (sim and sim.rightClick) ~= nil then -- 463
		____temp_24 = sim.rightClick -- 464
	else -- 464
		____temp_24 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 465
	end -- 465
	local rightClick = ____temp_24 -- 463
	self.prevLeft = leftHeld -- 466
	self.prevRight = rightHeld -- 467
	local move = 0 -- 469
	local confirm = false -- 470
	local cancel = false -- 471
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 473
		move = sim.move or 0 -- 474
		confirm = sim.confirm == true -- 475
		cancel = sim.cancel == true -- 476
	else -- 476
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 478
			move = move - 1 -- 478
		end -- 478
		if ctx.input.navRight or ctx.input.navNextTab then -- 479
			move = move + 1 -- 479
		end -- 479
		if ctx.input.craftConfirm or ctx.input.navConfirm then -- 480
			confirm = true -- 480
		end -- 480
		if ctx.input.craftCancel or ctx.input.navBack then -- 481
			cancel = true -- 481
		end -- 481
	end -- 481
	local ptr = Vec2(ptrX, ptrY) -- 485
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 486
	if cancel or rightClick or click and hitClose then -- 487
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 488
		return -- 489
	end -- 489
	local count = #bench.recipes -- 492
	if count == 0 then -- 493
		return -- 494
	end -- 494
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 497
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 498
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 499
	local hitCard = -1 -- 501
	if inside then -- 502
		local i = 0 -- 503
		do -- 503
			i = 0 -- 504
			while i < #self.cardBoxes do -- 504
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 505
					hitCard = i -- 506
					break -- 507
				end -- 507
				i = i + 1 -- 504
			end -- 504
		end -- 504
	end -- 504
	if move ~= 0 then -- 512
		self.pointerActive = false -- 513
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 514
	elseif pointerMoved and hitCard >= 0 then -- 515
		self.pointerActive = true -- 516
		self.selectedIdx = hitCard -- 517
	end -- 517
	local triggerConfirm = confirm or click and hitCard >= 0 -- 520
	if not triggerConfirm then -- 521
		return -- 522
	end -- 522
	if click and hitCard >= 0 then -- 524
		self.selectedIdx = hitCard -- 525
	end -- 525
	if self.handoverRemaining > 0.05 then -- 529
		return -- 530
	end -- 530
	local recipe = bench.recipes[self.selectedIdx + 1] -- 533
	if recipe == nil then -- 534
		return -- 535
	end -- 535
	if recipe.crafted then -- 538
		if bench.equippedWeapon ~= recipe.id then -- 539
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 540
		end -- 540
		return -- 542
	end -- 542
	if self.pendingRecipeId == recipe.id then -- 546
		return -- 547
	end -- 547
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 551
	if #missing > 0 then -- 552
		self.missingList = missing -- 553
		self.missingFlashT = 0.55 -- 554
		ctx.audio:playOnce( -- 555
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 556
			"sfx", -- 557
			"assets/audio/combat/craft_insufficient.wav", -- 558
			0.76, -- 559
			"craft:insufficient:" .. recipe.id, -- 560
			ctx.p.ticks -- 561
		) -- 561
		return -- 563
	end -- 563
	self.missingList = {} -- 566
	self.missingFlashT = 0 -- 567
	self.pendingRecipeId = recipe.id -- 568
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 569
	self.requestSeq = self.requestSeq + 1 -- 570
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 571
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 572
	if not accepted then -- 577
		self.pendingRecipeId = "" -- 578
	end -- 578
end -- 437
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 582
	local bench = ctx.view.craftBench -- 589
	if not bench.active and self.handoverRemaining <= 0.01 then -- 590
		return false -- 591
	end -- 591
	if not bench.active then -- 595
		self:drawHandoverOverlay( -- 596
			uiDraw, -- 596
			uiInkDraw, -- 596
			uiArt, -- 596
			uiGlow, -- 596
			ctx -- 596
		) -- 596
		return false -- 597
	end -- 597
	local appear = math.min(1, self.openAnimT) -- 600
	local layout = self:computeLayout(ctx, #bench.recipes) -- 601
	local bx = layout.benchX -- 602
	local by = layout.benchY -- 603
	local bw = layout.benchW -- 604
	local bh = layout.benchH -- 605
	fillVGradRect( -- 608
		uiDraw, -- 609
		0, -- 610
		0, -- 611
		ctx.uiW, -- 612
		by + bh + 64, -- 613
		Color( -- 614
			12, -- 614
			10, -- 614
			10, -- 614
			math.floor(168 * appear + 0.5) -- 614
		), -- 614
		Color(12, 10, 10, 0) -- 615
	) -- 615
	self:drawWoodenBenchBody( -- 619
		uiDraw, -- 619
		uiInkDraw, -- 619
		uiArt, -- 619
		uiGlow, -- 619
		bx, -- 619
		by, -- 619
		bw, -- 619
		bh, -- 619
		appear -- 619
	) -- 619
	ctx.texts:put( -- 622
		"md", -- 622
		"安全工台 · 改制鸟铳", -- 622
		bx + 54, -- 622
		by + bh - 26, -- 622
		toColor(PALETTE.amberCore), -- 622
		0, -- 622
		0.5, -- 622
		"Left", -- 622
		2, -- 622
		0.96 * appear, -- 622
		0.08 -- 622
	) -- 622
	drawHairline( -- 623
		uiInkDraw, -- 623
		uiArt, -- 623
		"cb_head_line", -- 623
		bx + bw * 0.5, -- 623
		by + bh - 46, -- 623
		bw - 36, -- 623
		PALETTE.amberDim, -- 623
		0.55 * appear, -- 623
		false, -- 623
		2 -- 623
	) -- 623
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 625
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 626
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 627
	uiInkDraw:drawRect( -- 628
		self.closeBox, -- 629
		Color( -- 630
			24, -- 630
			18, -- 630
			16, -- 630
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 630
		), -- 630
		0.9, -- 631
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 632
	) -- 632
	local closeText = ctx.input:isGamepadMode() and getActiveTarget():keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 634
	ctx.texts:put( -- 637
		"xs", -- 638
		closeText, -- 639
		self.closeBox.x + self.closeBox.width * 0.5, -- 640
		self.closeBox.y + self.closeBox.height * 0.5, -- 641
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 642
		0.5, -- 643
		0.5, -- 644
		"Center", -- 645
		1.4, -- 646
		0.95 * appear, -- 647
		0.06 -- 648
	) -- 648
	self:drawTableMaterials( -- 652
		uiDraw, -- 652
		uiInkDraw, -- 652
		uiArt, -- 652
		ctx, -- 652
		bench, -- 652
		bx + 18, -- 652
		by + 22, -- 652
		layout.matW - 14, -- 652
		bh - 76, -- 652
		appear -- 652
	) -- 652
	local i = 0 -- 655
	do -- 655
		i = 0 -- 656
		while i < #bench.recipes and i < #self.cardBoxes do -- 656
			self:drawRecipeCard( -- 657
				uiDraw, -- 658
				uiInkDraw, -- 659
				uiArt, -- 660
				uiGlow, -- 661
				ctx, -- 662
				bench, -- 663
				bench.recipes[i + 1], -- 664
				self.cardBoxes[i + 1], -- 665
				i == self.selectedIdx, -- 666
				appear -- 667
			) -- 667
			i = i + 1 -- 656
		end -- 656
	end -- 656
	if self.handoverRemaining > 0.01 then -- 672
		self:drawHandoverOverlay( -- 673
			uiDraw, -- 673
			uiInkDraw, -- 673
			uiArt, -- 673
			uiGlow, -- 673
			ctx -- 673
		) -- 673
	end -- 673
	return true -- 676
end -- 582
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 679
	uiDraw:drawRect( -- 691
		Rect(bx, by, bw, bh), -- 691
		Color( -- 691
			WOOD_BODY.r, -- 691
			WOOD_BODY.g, -- 691
			WOOD_BODY.b, -- 691
			math.floor(244 * appear + 0.5) -- 691
		), -- 691
		1.4, -- 691
		toColor(PALETTE.amberDim, 190 * appear) -- 691
	) -- 691
	uiDraw:drawRect( -- 693
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 693
		Color( -- 693
			WOOD_TOP.r, -- 693
			WOOD_TOP.g, -- 693
			WOOD_TOP.b, -- 693
			math.floor(250 * appear + 0.5) -- 693
		), -- 693
		1, -- 693
		WOOD_EDGE -- 693
	) -- 693
	uiInkDraw:drawSegment( -- 694
		Vec2(bx - 6, by + bh + 3), -- 694
		Vec2(bx + bw + 6, by + bh + 3), -- 694
		1.2, -- 694
		toColor(PALETTE.amberCore, 115 * appear) -- 694
	) -- 694
	uiDraw:drawRect( -- 696
		Rect(bx + 18, by - 26, 22, 26), -- 696
		Color( -- 696
			WOOD_DARK.r, -- 696
			WOOD_DARK.g, -- 696
			WOOD_DARK.b, -- 696
			math.floor(235 * appear + 0.5) -- 696
		) -- 696
	) -- 696
	uiDraw:drawRect( -- 697
		Rect(bx + bw - 40, by - 26, 22, 26), -- 697
		Color( -- 697
			WOOD_DARK.r, -- 697
			WOOD_DARK.g, -- 697
			WOOD_DARK.b, -- 697
			math.floor(235 * appear + 0.5) -- 697
		) -- 697
	) -- 697
	local g = 1 -- 700
	do -- 700
		g = 1 -- 701
		while g <= 4 do -- 701
			local gy = by + (bh - 50) * (g / 5) -- 702
			uiDraw:drawSegment( -- 703
				Vec2(bx + 10, gy), -- 703
				Vec2(bx + bw - 10, gy), -- 703
				0.75, -- 703
				Color( -- 703
					34, -- 703
					23, -- 703
					18, -- 703
					math.floor(110 * appear + 0.5) -- 703
				) -- 703
			) -- 703
			g = g + 1 -- 701
		end -- 701
	end -- 701
	local lx = bx + 28 -- 707
	local ly = by + bh - 24 -- 708
	uiArt:tryPlace( -- 709
		"prop_lantern", -- 709
		"cb_lantern", -- 709
		lx, -- 709
		ly, -- 709
		20, -- 709
		26, -- 709
		{opacity = 0.94 * appear, layer = 4} -- 709
	) -- 709
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 710
	fillRadialGlow( -- 711
		uiGlow, -- 712
		lx + 10, -- 713
		ly - 10, -- 714
		260 * pulse, -- 715
		180 * pulse, -- 716
		Color( -- 717
			238, -- 717
			198, -- 717
			128, -- 717
			math.floor(38 * appear + 0.5) -- 717
		), -- 717
		Color(238, 180, 92, 0), -- 718
		16 -- 719
	) -- 719
end -- 679
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 723
	uiDraw:drawRect( -- 735
		Rect(x, y, w, h), -- 735
		Color( -- 735
			26, -- 735
			20, -- 735
			17, -- 735
			math.floor(188 * appear + 0.5) -- 735
		), -- 735
		0.9, -- 735
		toColor(PALETTE.amberDim, 130 * appear) -- 735
	) -- 735
	drawFiligreeCorners( -- 736
		uiInkDraw, -- 736
		uiArt, -- 736
		"cb_mat_frame", -- 736
		x + 3, -- 736
		y + 3, -- 736
		w - 6, -- 736
		h - 6, -- 736
		PALETTE.amberDim, -- 736
		0.48 * appear, -- 736
		16, -- 736
		false, -- 736
		2 -- 736
	) -- 736
	ctx.texts:put( -- 738
		"xs", -- 738
		"案边持有", -- 738
		x + 12, -- 738
		y + h - 18, -- 738
		toColor(PALETTE.amberCore), -- 738
		0, -- 738
		0.5, -- 738
		"Left", -- 738
		1.4, -- 738
		0.92 * appear, -- 738
		0.06 -- 738
	) -- 738
	uiInkDraw:drawSegment( -- 739
		Vec2(x + 10, y + h - 32), -- 739
		Vec2(x + w - 10, y + h - 32), -- 739
		0.75, -- 739
		toColor(PALETTE.amberDim, 115 * appear) -- 739
	) -- 739
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 741
	local i = 0 -- 742
	do -- 742
		i = 0 -- 743
		while i < #keys and i < 4 do -- 743
			local mat = keys[i + 1] -- 744
			local count = bench.inventory[mat] or 0 -- 745
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 746
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 747
			local rowY = y + h - 62 - i * 48 -- 748
			if isMissing then -- 750
				uiDraw:drawRect( -- 751
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 751
					toColor(PALETTE.rougeSoft, 145 * appear), -- 751
					1, -- 751
					toColor(PALETTE.crimsonCore, 220 * appear) -- 751
				) -- 751
			end -- 751
			local shown = math.max( -- 755
				1, -- 755
				math.min(4, count) -- 755
			) -- 755
			local t = 0 -- 756
			do -- 756
				t = 0 -- 757
				while t < shown do -- 757
					local tx = x + 22 + t * 14 + shake -- 758
					local filled = t < count -- 759
					if mat == "bell_tally" or mat == "bell" then -- 760
						drawReloadPatternGlyph( -- 761
							uiInkDraw, -- 762
							tx, -- 763
							rowY, -- 764
							7.5, -- 765
							"echo", -- 766
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 767
							(filled and 0.96 or 0.38) * appear -- 768
						) -- 768
					else -- 768
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 771
						uiInkDraw:drawRect( -- 772
							Rect(tx - 4, rowY - 10, 8, 20), -- 773
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 774
							1, -- 775
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 776
						) -- 776
						if filled then -- 778
							uiInkDraw:drawSegment( -- 779
								Vec2(tx - 2, rowY + 3), -- 779
								Vec2(tx + 2, rowY + 3), -- 779
								0.9, -- 779
								toColor(PALETTE.xuanInk, 185 * appear) -- 779
							) -- 779
							uiInkDraw:drawSegment( -- 780
								Vec2(tx - 2, rowY - 3), -- 780
								Vec2(tx + 2, rowY - 3), -- 780
								0.9, -- 780
								toColor(PALETTE.xuanInk, 185 * appear) -- 780
							) -- 780
						end -- 780
					end -- 780
					t = t + 1 -- 757
				end -- 757
			end -- 757
			ctx.texts:put( -- 785
				"xs", -- 786
				materialLabel(mat), -- 787
				x + 86 + shake, -- 788
				rowY + 5, -- 789
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 790
				0, -- 791
				0.5, -- 792
				"Left", -- 793
				0.8, -- 794
				0.95 * appear, -- 795
				0.06 -- 796
			) -- 796
			ctx.texts:put( -- 798
				"xs", -- 799
				"存 " .. tostring(count), -- 800
				x + 86 + shake, -- 801
				rowY - 11, -- 802
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 803
				0, -- 804
				0.5, -- 805
				"Left", -- 806
				0.8, -- 807
				0.88 * appear, -- 808
				0.06 -- 809
			) -- 809
			i = i + 1 -- 743
		end -- 743
	end -- 743
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 814
	uiInkDraw:drawSegment( -- 815
		Vec2(x + 10, y + 32), -- 815
		Vec2(x + w - 10, y + 32), -- 815
		0.75, -- 815
		toColor(PALETTE.amberDim, 105 * appear) -- 815
	) -- 815
	ctx.texts:put( -- 816
		"xs", -- 816
		"现佩：" .. eqName, -- 816
		x + 12, -- 816
		y + 16, -- 816
		toColor(PALETTE.textMid), -- 816
		0, -- 816
		0.5, -- 816
		"Left", -- 816
		0.8, -- 816
		0.9 * appear, -- 816
		0.06 -- 816
	) -- 816
end -- 723
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 819
	local i = 0 -- 820
	do -- 820
		i = 0 -- 821
		while i < #bench.recipes do -- 821
			if bench.recipes[i + 1].id == weaponId then -- 822
				return bench.recipes[i + 1].name -- 823
			end -- 823
			i = i + 1 -- 821
		end -- 821
	end -- 821
	return "旧制鸟铳" -- 826
end -- 819
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 829
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 841
	local canCraft = not recipe.crafted and #missing == 0 -- 842
	local equipped = bench.equippedWeapon == recipe.id -- 843
	local isPending = self.pendingRecipeId == recipe.id -- 844
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 845
	if not uiArt:tryPlace( -- 848
		"ink_song_paper", -- 848
		"cb_card_" .. recipe.id, -- 848
		box.x + box.width * 0.5, -- 848
		box.y + box.height * 0.5, -- 848
		box.width, -- 848
		box.height, -- 848
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 848
	) then -- 848
		uiDraw:drawRect( -- 849
			box, -- 849
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 849
		) -- 849
	end -- 849
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 852
	drawFiligreeCorners( -- 855
		uiInkDraw, -- 855
		uiArt, -- 855
		"cb_cf_" .. recipe.id, -- 855
		box.x + 5, -- 855
		box.y + 5, -- 855
		box.width - 10, -- 855
		box.height - 10, -- 855
		borderCol, -- 855
		(selected and 0.88 or 0.46) * appear, -- 855
		18, -- 855
		true, -- 855
		2 -- 855
	) -- 855
	if selected then -- 857
		drawSilkRibbon( -- 858
			uiDraw, -- 858
			uiArt, -- 858
			"cb_sel_rib_" .. recipe.id, -- 858
			box.x + box.width * 0.5, -- 858
			box.y + box.height - 26, -- 858
			box.width - 14, -- 858
			30, -- 858
			PALETTE.amberDim, -- 858
			0.24 * appear, -- 858
			2 -- 858
		) -- 858
	end -- 858
	local topY = box.y + box.height - 26 -- 862
	drawBlossomDot( -- 863
		uiInkDraw, -- 863
		uiArt, -- 863
		"cb_dot_" .. recipe.id, -- 863
		box.x + 18, -- 863
		topY, -- 863
		selected and 11 or 7, -- 863
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 863
		0.92 * appear, -- 863
		3 -- 863
	) -- 863
	ctx.texts:put( -- 864
		"md", -- 864
		recipe.name, -- 864
		box.x + 30, -- 864
		topY, -- 864
		toColor(PALETTE.xuanInk), -- 864
		0, -- 864
		0.5, -- 864
		"Left", -- 864
		1.6, -- 864
		0.98 * appear, -- 864
		0 -- 864
	) -- 864
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 866
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 867
	ctx.texts:put( -- 868
		"xs", -- 868
		badge, -- 868
		box.x + box.width - 14, -- 868
		topY, -- 868
		toColor(badgeCol), -- 868
		1, -- 868
		0.5, -- 868
		"Right", -- 868
		1, -- 868
		0.94 * appear, -- 868
		0 -- 868
	) -- 868
	local narrow = box.width < 195 -- 871
	local miniCx = box.x + (narrow and 36 or 46) -- 872
	local miniCy = box.y + box.height - 96 -- 873
	self:drawMiniReloadPreview( -- 874
		uiInkDraw, -- 874
		uiGlow, -- 874
		miniCx, -- 874
		miniCy, -- 874
		recipe.enhancedEffect, -- 874
		appear -- 874
	) -- 874
	local infoX = box.x + (narrow and 72 or 90) -- 877
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 878
	ctx.texts:put( -- 879
		"xs", -- 879
		effTitle, -- 879
		infoX, -- 879
		box.y + box.height - 64, -- 879
		toColor(PALETTE.rouge), -- 879
		0, -- 879
		0.5, -- 879
		"Left", -- 879
		narrow and 0.3 or 0.8, -- 879
		0.95 * appear, -- 879
		0 -- 879
	) -- 879
	local row = 0 -- 881
	for mat in pairs(recipe.cost) do -- 882
		local need = recipe.cost[mat] -- 883
		local have = bench.inventory[mat] or 0 -- 884
		local lack = not recipe.crafted and have < need -- 885
		local ry = box.y + box.height - 90 - row * 22 -- 886
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 887
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 888
		ctx.texts:put( -- 889
			"xs", -- 889
			text, -- 889
			infoX, -- 889
			ry, -- 889
			toColor(col), -- 889
			0, -- 889
			0.5, -- 889
			"Left", -- 889
			0.6, -- 889
			0.94 * appear, -- 889
			0 -- 889
		) -- 889
		row = row + 1 -- 890
	end -- 890
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 894
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 895
	local btnBg = equipped and Color( -- 898
		168, -- 899
		46, -- 899
		44, -- 899
		math.floor(32 * appear + 0.5) -- 899
	) or (selected and (canCraft or recipe.crafted) and Color( -- 900
		32, -- 901
		30, -- 901
		32, -- 901
		math.floor(218 * appear + 0.5) -- 901
	) or Color( -- 902
		32, -- 902
		30, -- 902
		32, -- 902
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 902
	)) -- 902
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 903
	uiInkDraw:drawRect( -- 906
		btnRect, -- 906
		btnBg, -- 906
		0.9, -- 906
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 906
	) -- 906
	ctx.texts:put( -- 907
		"sm", -- 908
		btnLabel, -- 909
		btnRect.x + btnRect.width * 0.5, -- 910
		btnRect.y + btnRect.height * 0.5, -- 911
		toColor(btnTextCol), -- 912
		0.5, -- 913
		0.5, -- 914
		"Center", -- 915
		1.6, -- 916
		0.96 * appear, -- 917
		0 -- 918
	) -- 918
end -- 829
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 923
	local step = 20 -- 931
	local samplePath = effect == "light" and ({ -- 932
		0, -- 932
		1, -- 932
		2, -- 932
		5, -- 932
		8 -- 932
	}) or (effect == "echo" and ({ -- 932
		0, -- 932
		1, -- 932
		4, -- 932
		5, -- 932
		8 -- 932
	}) or ({ -- 932
		0, -- 932
		3, -- 932
		6, -- 932
		7, -- 932
		8 -- 932
	})) -- 932
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 933
	uiInkDraw:drawRect( -- 936
		Rect(cx - 32, cy - 32, 64, 64), -- 936
		Color( -- 936
			224, -- 936
			218, -- 936
			206, -- 936
			math.floor(145 * appear + 0.5) -- 936
		), -- 936
		0.8, -- 936
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 936
	) -- 936
	local i = 0 -- 937
	do -- 937
		i = 0 -- 938
		while i < #RELOAD_GRID do -- 938
			local g = RELOAD_GRID[i + 1] -- 939
			local nx = cx + (g.col - 1) * step -- 940
			local ny = cy + (g.row - 1) * step -- 941
			uiInkDraw:drawDot( -- 942
				Vec2(nx, ny), -- 942
				1.8, -- 942
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 942
			) -- 942
			i = i + 1 -- 938
		end -- 938
	end -- 938
	do -- 938
		i = 0 -- 946
		while i < #samplePath - 1 do -- 946
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 947
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 948
			uiInkDraw:drawSegment( -- 949
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 950
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 951
				1.8, -- 952
				toColor(accent, 220 * appear) -- 953
			) -- 953
			i = i + 1 -- 946
		end -- 946
	end -- 946
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 958
	local kx = cx + (keyNode.col - 1) * step -- 959
	local ky = cy + (keyNode.row - 1) * step -- 960
	drawReloadPatternGlyph( -- 961
		uiInkDraw, -- 961
		kx, -- 961
		ky, -- 961
		7.5, -- 961
		effect, -- 961
		accent, -- 961
		appear -- 961
	) -- 961
	fillRadialGlow( -- 962
		uiGlow, -- 962
		kx, -- 962
		ky, -- 962
		14, -- 962
		14, -- 962
		toColor(PALETTE.amberCore, 45 * appear), -- 962
		Color(244, 234, 214, 0), -- 962
		10 -- 962
	) -- 962
end -- 923
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 966
	local prog = math.max( -- 973
		0, -- 973
		math.min( -- 973
			1, -- 973
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 973
		) -- 973
	) -- 973
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 974
	local cx = ctx.uiW * 0.5 -- 975
	local cy = ctx.uiH * 0.68 -- 976
	local w = 440 -- 977
	local h = 112 -- 978
	drawSilkVeil( -- 980
		uiDraw, -- 980
		uiArt, -- 980
		"cb_handover_veil", -- 980
		cx, -- 980
		cy, -- 980
		w + 80, -- 980
		h + 28, -- 980
		PALETTE.inkWash, -- 980
		0.84 * fade, -- 980
		0 -- 980
	) -- 980
	drawHairline( -- 981
		uiInkDraw, -- 981
		uiArt, -- 981
		"cb_handover_top", -- 981
		cx, -- 981
		cy + h * 0.48, -- 981
		w - 30, -- 981
		PALETTE.amber, -- 981
		0.58 * fade, -- 981
		true, -- 981
		2 -- 981
	) -- 981
	local passK = math.min(1, prog / 0.38) -- 984
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 985
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 986
	local a245 = math.floor(245 * fade + 0.5) -- 987
	local a235 = math.floor(235 * fade + 0.5) -- 988
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 991
	local childHandY = cy - 4 + gripLift * 0.2 -- 992
	uiInkDraw:drawPolygon( -- 993
		{ -- 993
			Vec2(cx - 148, cy - 22), -- 994
			Vec2(cx - 146, cy - 8), -- 995
			Vec2(childHandX - 10, childHandY + 4), -- 996
			Vec2(childHandX - 10, childHandY - 6) -- 997
		}, -- 997
		Color(164, 78, 54, a235), -- 998
		1, -- 998
		Color(52, 28, 22, a235) -- 998
	) -- 998
	uiInkDraw:drawSegment( -- 999
		Vec2(childHandX - 11, childHandY + 4), -- 999
		Vec2(childHandX - 11, childHandY - 6), -- 999
		2, -- 999
		Color(204, 174, 122, a245) -- 999
	) -- 999
	uiInkDraw:drawEllipse( -- 1000
		Vec2(childHandX, childHandY - 1), -- 1000
		6.2, -- 1000
		4.4, -- 1000
		Color(238, 212, 182, a245) -- 1000
	) -- 1000
	local solHandX = cx + 82 - math.min( -- 1003
		1, -- 1003
		math.max(0, (prog - 0.18) / 0.28) -- 1003
	) * 42 -- 1003
	local solHandY = cy - 4 + gripLift -- 1004
	uiInkDraw:drawPolygon( -- 1005
		{ -- 1005
			Vec2(cx + 154, cy - 18), -- 1006
			Vec2(cx + 154, cy - 1), -- 1007
			Vec2(solHandX + 12, solHandY + 6), -- 1008
			Vec2(solHandX + 12, solHandY - 7) -- 1009
		}, -- 1009
		toColor(CUFF_PALETTE.indigoBase, a245), -- 1010
		1, -- 1010
		toColor(CUFF_PALETTE.indigoShadow, a245) -- 1010
	) -- 1010
	local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1012
	uiInkDraw:drawSegment( -- 1013
		Vec2(solHandX + 16, solHandY - 5), -- 1013
		Vec2(solHandX + 19, solHandY + 4), -- 1013
		1.5, -- 1013
		mendCol -- 1013
	) -- 1013
	uiInkDraw:drawSegment( -- 1014
		Vec2(solHandX + 21, solHandY - 5), -- 1014
		Vec2(solHandX + 24, solHandY + 4), -- 1014
		1.5, -- 1014
		mendCol -- 1014
	) -- 1014
	uiInkDraw:drawSegment( -- 1015
		Vec2(solHandX + 26, solHandY - 5), -- 1015
		Vec2(solHandX + 29, solHandY + 4), -- 1015
		1.5, -- 1015
		mendCol -- 1015
	) -- 1015
	uiInkDraw:drawEllipse( -- 1016
		Vec2(solHandX, solHandY), -- 1016
		6.8, -- 1016
		5, -- 1016
		toColor(CUFF_PALETTE.skinBase, a245) -- 1016
	) -- 1016
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1019
	local gunY = cy + 3 + gripLift -- 1020
	uiInkDraw:drawPolygon( -- 1022
		{ -- 1022
			Vec2(gunX - 42, gunY - 8), -- 1023
			Vec2(gunX - 12, gunY - 3), -- 1024
			Vec2(gunX + 16, gunY + 1), -- 1025
			Vec2(gunX + 16, gunY + 6), -- 1026
			Vec2(gunX - 16, gunY + 3), -- 1027
			Vec2(gunX - 40, gunY + 1) -- 1028
		}, -- 1028
		Color(108, 72, 48, a245), -- 1029
		1, -- 1029
		Color(46, 30, 20, a245) -- 1029
	) -- 1029
	uiInkDraw:drawSegment( -- 1031
		Vec2(gunX - 6, gunY + 4), -- 1031
		Vec2(gunX + 56, gunY + 8), -- 1031
		2.8, -- 1031
		Color(152, 148, 138, a245) -- 1031
	) -- 1031
	uiInkDraw:drawSegment( -- 1032
		Vec2(gunX + 14, gunY + 1), -- 1032
		Vec2(gunX + 14, gunY + 8), -- 1032
		2, -- 1032
		Color(198, 166, 112, a245) -- 1032
	) -- 1032
	uiInkDraw:drawSegment( -- 1033
		Vec2(gunX + 36, gunY + 3), -- 1033
		Vec2(gunX + 36, gunY + 9), -- 1033
		1.6, -- 1033
		Color(198, 166, 112, a245) -- 1033
	) -- 1033
	drawReloadPatternGlyph( -- 1034
		uiInkDraw, -- 1034
		gunX + 2, -- 1034
		gunY + 21, -- 1034
		8.5, -- 1034
		self.handoverEffect, -- 1034
		PALETTE.amberCore, -- 1034
		fade -- 1034
	) -- 1034
	fillRadialGlow( -- 1035
		uiGlow, -- 1035
		gunX + 4, -- 1035
		gunY + 4, -- 1035
		48, -- 1035
		22, -- 1035
		toColor(PALETTE.amberCore, 52 * fade), -- 1035
		Color(244, 234, 214, 0), -- 1035
		12 -- 1035
	) -- 1035
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1037
	ctx.texts:put( -- 1040
		"xs", -- 1040
		caption, -- 1040
		cx, -- 1040
		cy - 34, -- 1040
		toColor(PALETTE.amberCore), -- 1040
		0.5, -- 1040
		0.5, -- 1040
		"Center", -- 1040
		1.4, -- 1040
		0.94 * fade, -- 1040
		0.08 -- 1040
	) -- 1040
end -- 966
function ____exports.createCraftBenchPlugin(contract) -- 1044
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1045
end -- 1044
return ____exports -- 1044
