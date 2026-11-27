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
	if injected ~= nil then -- 92
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
	if loaded == nil then -- 97
		return nil -- 99
	end -- 99
	local feHook = loaded["watch.fe"] -- 101
	if feHook ~= nil and type(feHook) == "table" then -- 101
		local c = feHook.contract -- 103
		if c ~= nil and type(c) == "table" then -- 103
			return c -- 105
		end -- 105
	end -- 105
	return nil -- 108
end -- 92
local function dispatchIntentFallback(p, intent) -- 111
	local rec = p -- 112
	local handler = rec.submitFeIntent -- 113
	if type(handler) == "function" then -- 113
		return handler(p, intent) ~= false -- 115
	end -- 115
	return false -- 117
end -- 111
local function collectMissingMaterials(recipe, inventory) -- 120
	local missing = {} -- 124
	for mat in pairs(recipe.cost) do -- 125
		local need = recipe.cost[mat] -- 126
		local have = inventory[mat] or 0 -- 127
		if have < need then -- 127
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
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 145
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
				if not seen[k] then -- 157
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
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 165
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
	if self.lastSnapshotBench ~= nil then -- 224
		for k in pairs(self.lastSnapshotBench.inventory) do -- 226
			inv[k] = self.lastSnapshotBench.inventory[k] -- 227
		end -- 227
		local i = 0 -- 229
		do -- 229
			i = 0 -- 230
			while i < #self.lastSnapshotBench.recipes do -- 230
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 230
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
	if contract ~= nil then -- 287
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
			local ____self_cardBoxes_1 = self.cardBoxes -- 328
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
	if ctx.paused then -- 339
		self:resetInputEdges(ctx.input:isTouchMode()) -- 343
		return -- 344
	end -- 344
	local udt = math.max(0, ctx.uiDt) -- 347
	self.animTime = self.animTime + udt -- 348
	if self.missingFlashT > 0 then -- 348
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 351
	end -- 351
	if self.handoverRemaining > 0 then -- 351
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 354
	end -- 354
	self:detectCraftCompletion(ctx, bench) -- 358
	if bench.active and not self.wasActive then -- 358
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
	elseif not bench.active and self.wasActive then -- 366
		self.pendingRecipeId = "" -- 368
		self.missingFlashT = 0 -- 369
	end -- 369
	self.wasActive = bench.active -- 371
	if not bench.active then -- 371
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
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 389
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
			if ename == "benchRejected" then -- 398
				self.pendingRecipeId = "" -- 400
				self.missingFlashT = 0.45 -- 401
			end -- 401
			i = i + 1 -- 397
		end -- 397
	end -- 397
	if newlyCrafted ~= nil then -- 397
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
				if ename == "craftDone" or ename == "benchCraft" then -- 418
					hasBackendDone = true -- 420
					break -- 421
				end -- 421
				i = i + 1 -- 417
			end -- 417
		end -- 417
		if not hasBackendDone then -- 417
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
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 471
		move = sim.move or 0 -- 474
		confirm = sim.confirm == true -- 475
		cancel = sim.cancel == true -- 476
	else -- 476
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 476
			move = move - 1 -- 478
		end -- 478
		if ctx.input.navRight or ctx.input.navNextTab then -- 478
			move = move + 1 -- 479
		end -- 479
		if ctx.input.craftConfirm or ctx.input.navConfirm then -- 479
			confirm = true -- 480
		end -- 480
		if ctx.input.craftCancel or ctx.input.navBack then -- 480
			cancel = true -- 481
		end -- 481
	end -- 481
	local ptr = Vec2(ptrX, ptrY) -- 485
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 486
	if cancel or rightClick or click and hitClose then -- 486
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 488
		return -- 489
	end -- 489
	local count = #bench.recipes -- 492
	if count == 0 then -- 492
		return -- 494
	end -- 494
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 497
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 498
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 499
	local hitCard = -1 -- 501
	if inside then -- 501
		local i = 0 -- 503
		do -- 503
			i = 0 -- 504
			while i < #self.cardBoxes do -- 504
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 504
					hitCard = i -- 506
					break -- 507
				end -- 507
				i = i + 1 -- 504
			end -- 504
		end -- 504
	end -- 504
	if move ~= 0 then -- 504
		self.pointerActive = false -- 513
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 514
	elseif pointerMoved and hitCard >= 0 then -- 514
		self.pointerActive = true -- 516
		self.selectedIdx = hitCard -- 517
	end -- 517
	local triggerConfirm = confirm or click and hitCard >= 0 -- 520
	if not triggerConfirm then -- 520
		return -- 522
	end -- 522
	if click and hitCard >= 0 then -- 522
		self.selectedIdx = hitCard -- 525
	end -- 525
	if self.handoverRemaining > 0.05 then -- 525
		return -- 530
	end -- 530
	local recipe = bench.recipes[self.selectedIdx + 1] -- 533
	if recipe == nil then -- 533
		return -- 535
	end -- 535
	if recipe.crafted then -- 535
		if bench.equippedWeapon ~= recipe.id then -- 535
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 540
		end -- 540
		return -- 542
	end -- 542
	if self.pendingRecipeId == recipe.id then -- 542
		return -- 547
	end -- 547
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 551
	if #missing > 0 then -- 551
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
	if not accepted then -- 572
		self.pendingRecipeId = "" -- 578
	end -- 578
end -- 437
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 582
	local bench = ctx.view.craftBench -- 589
	if not bench.active and self.handoverRemaining <= 0.01 then -- 589
		return false -- 591
	end -- 591
	if not bench.active then -- 591
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
	if self.handoverRemaining > 0.01 then -- 656
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
	uiArt:tryPlacePath( -- 692
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 692
		"cb_wood_tex", -- 692
		bx + bw * 0.5, -- 692
		by + bh * 0.5, -- 692
		bw - 4, -- 692
		bh - 12, -- 692
		{ -- 692
			anchorX = 0.5, -- 693
			anchorY = 0.5, -- 694
			color = Color(172, 132, 98, 255), -- 695
			opacity = 0.34 * appear, -- 696
			smooth = true, -- 697
			layer = 0 -- 698
		} -- 698
	) -- 698
	uiDraw:drawRect( -- 701
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 701
		Color( -- 701
			WOOD_TOP.r, -- 701
			WOOD_TOP.g, -- 701
			WOOD_TOP.b, -- 701
			math.floor(250 * appear + 0.5) -- 701
		), -- 701
		1, -- 701
		WOOD_EDGE -- 701
	) -- 701
	uiInkDraw:drawSegment( -- 702
		Vec2(bx - 6, by + bh + 3), -- 702
		Vec2(bx + bw + 6, by + bh + 3), -- 702
		1.2, -- 702
		toColor(PALETTE.amberCore, 115 * appear) -- 702
	) -- 702
	uiDraw:drawRect( -- 704
		Rect(bx + 18, by - 26, 22, 26), -- 704
		Color( -- 704
			WOOD_DARK.r, -- 704
			WOOD_DARK.g, -- 704
			WOOD_DARK.b, -- 704
			math.floor(235 * appear + 0.5) -- 704
		) -- 704
	) -- 704
	uiDraw:drawRect( -- 705
		Rect(bx + bw - 40, by - 26, 22, 26), -- 705
		Color( -- 705
			WOOD_DARK.r, -- 705
			WOOD_DARK.g, -- 705
			WOOD_DARK.b, -- 705
			math.floor(235 * appear + 0.5) -- 705
		) -- 705
	) -- 705
	local g = 1 -- 708
	do -- 708
		g = 1 -- 709
		while g <= 4 do -- 709
			local gy = by + (bh - 50) * (g / 5) -- 710
			uiDraw:drawSegment( -- 711
				Vec2(bx + 10, gy), -- 711
				Vec2(bx + bw - 10, gy), -- 711
				0.75, -- 711
				Color( -- 711
					34, -- 711
					23, -- 711
					18, -- 711
					math.floor(92 * appear + 0.5) -- 711
				) -- 711
			) -- 711
			g = g + 1 -- 709
		end -- 709
	end -- 709
	local lx = bx + 28 -- 715
	local ly = by + bh - 24 -- 716
	uiArt:tryPlace( -- 717
		"prop_lantern", -- 717
		"cb_lantern", -- 717
		lx, -- 717
		ly, -- 717
		20, -- 717
		26, -- 717
		{opacity = 0.94 * appear, layer = 4} -- 717
	) -- 717
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 718
	fillRadialGlow( -- 719
		uiGlow, -- 720
		lx + 10, -- 721
		ly - 10, -- 722
		260 * pulse, -- 723
		180 * pulse, -- 724
		Color( -- 725
			238, -- 725
			198, -- 725
			128, -- 725
			math.floor(38 * appear + 0.5) -- 725
		), -- 725
		Color(238, 180, 92, 0), -- 726
		16 -- 727
	) -- 727
end -- 679
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 731
	uiDraw:drawRect( -- 743
		Rect(x, y, w, h), -- 743
		Color( -- 743
			26, -- 743
			20, -- 743
			17, -- 743
			math.floor(188 * appear + 0.5) -- 743
		), -- 743
		0.9, -- 743
		toColor(PALETTE.amberDim, 130 * appear) -- 743
	) -- 743
	drawFiligreeCorners( -- 744
		uiInkDraw, -- 744
		uiArt, -- 744
		"cb_mat_frame", -- 744
		x + 3, -- 744
		y + 3, -- 744
		w - 6, -- 744
		h - 6, -- 744
		PALETTE.amberDim, -- 744
		0.48 * appear, -- 744
		16, -- 744
		false, -- 744
		2 -- 744
	) -- 744
	ctx.texts:put( -- 746
		"xs", -- 746
		"案边持有", -- 746
		x + 12, -- 746
		y + h - 18, -- 746
		toColor(PALETTE.amberCore), -- 746
		0, -- 746
		0.5, -- 746
		"Left", -- 746
		1.4, -- 746
		0.92 * appear, -- 746
		0.06 -- 746
	) -- 746
	uiInkDraw:drawSegment( -- 747
		Vec2(x + 10, y + h - 32), -- 747
		Vec2(x + w - 10, y + h - 32), -- 747
		0.75, -- 747
		toColor(PALETTE.amberDim, 115 * appear) -- 747
	) -- 747
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 749
	local i = 0 -- 750
	do -- 750
		i = 0 -- 751
		while i < #keys and i < 4 do -- 751
			local mat = keys[i + 1] -- 752
			local count = bench.inventory[mat] or 0 -- 753
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 754
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 755
			local rowY = y + h - 62 - i * 48 -- 756
			if isMissing then -- 756
				uiDraw:drawRect( -- 759
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 759
					toColor(PALETTE.rougeSoft, 145 * appear), -- 759
					1, -- 759
					toColor(PALETTE.crimsonCore, 220 * appear) -- 759
				) -- 759
			end -- 759
			local matClip = (mat == "bell_tally" or mat == "bell") and "pickup_bell" or (mat == "scrap" and "pickup_scrap" or (mat == "wedge" and "pickup_wedge" or (mat == "ammo" and "pickup_ammo" or "pickup_wood"))) -- 763
			local shown = math.max( -- 768
				1, -- 768
				math.min(3, count) -- 768
			) -- 768
			local t = 0 -- 769
			do -- 769
				t = 0 -- 770
				while t < shown do -- 770
					do -- 770
						local tx = x + 22 + t * 19 + shake -- 771
						local filled = t < count -- 772
						if uiArt:tryPlacePath( -- 772
							"assets/art/props_ming.clip|" .. matClip, -- 773
							(("cb_mat_" .. mat) .. "_") .. tostring(t), -- 773
							tx, -- 773
							rowY, -- 773
							20, -- 773
							20, -- 773
							{ -- 773
								anchorX = 0.5, -- 774
								anchorY = 0.5, -- 775
								preserveAspect = true, -- 776
								color = filled and Color(255, 255, 255, 255) or Color(138, 134, 128, 255), -- 777
								opacity = (filled and 0.96 or 0.34) * appear, -- 778
								layer = 3 -- 779
							} -- 779
						) then -- 779
							goto __continue104 -- 781
						end -- 781
						if mat == "bell_tally" or mat == "bell" then -- 781
							drawReloadPatternGlyph( -- 784
								uiInkDraw, -- 785
								tx, -- 786
								rowY, -- 787
								7.5, -- 788
								"echo", -- 789
								filled and PALETTE.amberCore or PALETTE.silkDim, -- 790
								(filled and 0.96 or 0.38) * appear -- 791
							) -- 791
						else -- 791
							local col = filled and PALETTE.amber or PALETTE.silkDim -- 794
							uiInkDraw:drawRect( -- 795
								Rect(tx - 4, rowY - 10, 8, 20), -- 796
								filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 797
								1, -- 798
								toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 799
							) -- 799
							if filled then -- 799
								uiInkDraw:drawSegment( -- 802
									Vec2(tx - 2, rowY + 3), -- 802
									Vec2(tx + 2, rowY + 3), -- 802
									0.9, -- 802
									toColor(PALETTE.xuanInk, 185 * appear) -- 802
								) -- 802
								uiInkDraw:drawSegment( -- 803
									Vec2(tx - 2, rowY - 3), -- 803
									Vec2(tx + 2, rowY - 3), -- 803
									0.9, -- 803
									toColor(PALETTE.xuanInk, 185 * appear) -- 803
								) -- 803
							end -- 803
						end -- 803
					end -- 803
					::__continue104:: -- 803
					t = t + 1 -- 770
				end -- 770
			end -- 770
			ctx.texts:put( -- 808
				"xs", -- 809
				materialLabel(mat), -- 810
				x + 86 + shake, -- 811
				rowY + 5, -- 812
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 813
				0, -- 814
				0.5, -- 815
				"Left", -- 816
				0.8, -- 817
				0.95 * appear, -- 818
				0.06 -- 819
			) -- 819
			ctx.texts:put( -- 821
				"xs", -- 822
				"存 " .. tostring(count), -- 823
				x + 86 + shake, -- 824
				rowY - 11, -- 825
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 826
				0, -- 827
				0.5, -- 828
				"Left", -- 829
				0.8, -- 830
				0.88 * appear, -- 831
				0.06 -- 832
			) -- 832
			i = i + 1 -- 751
		end -- 751
	end -- 751
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 837
	uiInkDraw:drawSegment( -- 838
		Vec2(x + 10, y + 32), -- 838
		Vec2(x + w - 10, y + 32), -- 838
		0.75, -- 838
		toColor(PALETTE.amberDim, 105 * appear) -- 838
	) -- 838
	ctx.texts:put( -- 839
		"xs", -- 839
		"现佩：" .. eqName, -- 839
		x + 12, -- 839
		y + 16, -- 839
		toColor(PALETTE.textMid), -- 839
		0, -- 839
		0.5, -- 839
		"Left", -- 839
		0.8, -- 839
		0.9 * appear, -- 839
		0.06 -- 839
	) -- 839
end -- 731
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 842
	local i = 0 -- 843
	do -- 843
		i = 0 -- 844
		while i < #bench.recipes do -- 844
			if bench.recipes[i + 1].id == weaponId then -- 844
				return bench.recipes[i + 1].name -- 846
			end -- 846
			i = i + 1 -- 844
		end -- 844
	end -- 844
	return "旧制鸟铳" -- 849
end -- 842
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 852
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 864
	local canCraft = not recipe.crafted and #missing == 0 -- 865
	local equipped = bench.equippedWeapon == recipe.id -- 866
	local isPending = self.pendingRecipeId == recipe.id -- 867
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 868
	if not uiArt:tryPlace( -- 868
		"ink_song_paper", -- 871
		"cb_card_" .. recipe.id, -- 871
		box.x + box.width * 0.5, -- 871
		box.y + box.height * 0.5, -- 871
		box.width, -- 871
		box.height, -- 871
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 871
	) then -- 871
		uiDraw:drawRect( -- 872
			box, -- 872
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 872
		) -- 872
	end -- 872
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 875
	drawFiligreeCorners( -- 878
		uiInkDraw, -- 878
		uiArt, -- 878
		"cb_cf_" .. recipe.id, -- 878
		box.x + 5, -- 878
		box.y + 5, -- 878
		box.width - 10, -- 878
		box.height - 10, -- 878
		borderCol, -- 878
		(selected and 0.88 or 0.46) * appear, -- 878
		18, -- 878
		true, -- 878
		2 -- 878
	) -- 878
	if selected then -- 878
		drawSilkRibbon( -- 881
			uiDraw, -- 881
			uiArt, -- 881
			"cb_sel_rib_" .. recipe.id, -- 881
			box.x + box.width * 0.5, -- 881
			box.y + box.height - 26, -- 881
			box.width - 14, -- 881
			30, -- 881
			PALETTE.amberDim, -- 881
			0.24 * appear, -- 881
			2 -- 881
		) -- 881
	end -- 881
	local topY = box.y + box.height - 26 -- 885
	drawBlossomDot( -- 886
		uiInkDraw, -- 886
		uiArt, -- 886
		"cb_dot_" .. recipe.id, -- 886
		box.x + 18, -- 886
		topY, -- 886
		selected and 11 or 7, -- 886
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 886
		0.92 * appear, -- 886
		3 -- 886
	) -- 886
	ctx.texts:put( -- 887
		"md", -- 887
		recipe.name, -- 887
		box.x + 30, -- 887
		topY, -- 887
		toColor(PALETTE.xuanInk), -- 887
		0, -- 887
		0.5, -- 887
		"Left", -- 887
		1.6, -- 887
		0.98 * appear, -- 887
		0 -- 887
	) -- 887
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 889
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 890
	ctx.texts:put( -- 891
		"xs", -- 891
		badge, -- 891
		box.x + box.width - 14, -- 891
		topY, -- 891
		toColor(badgeCol), -- 891
		1, -- 891
		0.5, -- 891
		"Right", -- 891
		1, -- 891
		0.94 * appear, -- 891
		0 -- 891
	) -- 891
	local narrow = box.width < 195 -- 894
	local miniCx = box.x + (narrow and 36 or 46) -- 895
	local miniCy = box.y + box.height - 96 -- 896
	self:drawMiniReloadPreview( -- 897
		uiInkDraw, -- 897
		uiGlow, -- 897
		miniCx, -- 897
		miniCy, -- 897
		recipe.enhancedEffect, -- 897
		appear -- 897
	) -- 897
	local infoX = box.x + (narrow and 72 or 90) -- 900
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 901
	ctx.texts:put( -- 902
		"xs", -- 902
		effTitle, -- 902
		infoX, -- 902
		box.y + box.height - 64, -- 902
		toColor(PALETTE.rouge), -- 902
		0, -- 902
		0.5, -- 902
		"Left", -- 902
		narrow and 0.3 or 0.8, -- 902
		0.95 * appear, -- 902
		0 -- 902
	) -- 902
	local row = 0 -- 904
	for mat in pairs(recipe.cost) do -- 905
		local need = recipe.cost[mat] -- 906
		local have = bench.inventory[mat] or 0 -- 907
		local lack = not recipe.crafted and have < need -- 908
		local ry = box.y + box.height - 90 - row * 22 -- 909
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 910
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 911
		ctx.texts:put( -- 912
			"xs", -- 912
			text, -- 912
			infoX, -- 912
			ry, -- 912
			toColor(col), -- 912
			0, -- 912
			0.5, -- 912
			"Left", -- 912
			0.6, -- 912
			0.94 * appear, -- 912
			0 -- 912
		) -- 912
		row = row + 1 -- 913
	end -- 913
	local weaponArtPath = recipe.enhancedEffect == "echo" and "assets/art/vfx_craft_art.clip|craft_echo_gun" or (recipe.enhancedEffect == "light" and "assets/art/vfx_craft_art.clip|craft_lantern_gun" or "assets/art/props_ming.clip|pickup_quickbelt") -- 917
	uiArt:tryPlacePath( -- 922
		weaponArtPath, -- 922
		"cb_wpn_art_" .. recipe.id, -- 922
		box.x + box.width * 0.5, -- 922
		box.y + 68, -- 922
		math.min(box.width - 36, 126), -- 922
		34, -- 922
		{ -- 922
			anchorX = 0.5, -- 923
			anchorY = 0.5, -- 924
			preserveAspect = true, -- 925
			smooth = true, -- 926
			opacity = (selected and 0.96 or 0.78) * appear, -- 927
			layer = 3 -- 928
		} -- 928
	) -- 928
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 932
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 933
	local btnBg = equipped and Color( -- 936
		168, -- 937
		46, -- 937
		44, -- 937
		math.floor(32 * appear + 0.5) -- 937
	) or (selected and (canCraft or recipe.crafted) and Color( -- 937
		32, -- 939
		30, -- 939
		32, -- 939
		math.floor(218 * appear + 0.5) -- 939
	) or Color( -- 939
		32, -- 940
		30, -- 940
		32, -- 940
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 940
	)) -- 940
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 941
	uiInkDraw:drawRect( -- 944
		btnRect, -- 944
		btnBg, -- 944
		0.9, -- 944
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 944
	) -- 944
	ctx.texts:put( -- 945
		"sm", -- 946
		btnLabel, -- 947
		btnRect.x + btnRect.width * 0.5, -- 948
		btnRect.y + btnRect.height * 0.5, -- 949
		toColor(btnTextCol), -- 950
		0.5, -- 951
		0.5, -- 952
		"Center", -- 953
		1.6, -- 954
		0.96 * appear, -- 955
		0 -- 956
	) -- 956
end -- 852
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 961
	local step = 20 -- 969
	local samplePath = effect == "light" and ({ -- 970
		0, -- 970
		1, -- 970
		2, -- 970
		5, -- 970
		8 -- 970
	}) or (effect == "echo" and ({ -- 970
		0, -- 970
		1, -- 970
		4, -- 970
		5, -- 970
		8 -- 970
	}) or ({ -- 970
		0, -- 970
		3, -- 970
		6, -- 970
		7, -- 970
		8 -- 970
	})) -- 970
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 971
	uiInkDraw:drawRect( -- 974
		Rect(cx - 32, cy - 32, 64, 64), -- 974
		Color( -- 974
			224, -- 974
			218, -- 974
			206, -- 974
			math.floor(145 * appear + 0.5) -- 974
		), -- 974
		0.8, -- 974
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 974
	) -- 974
	local i = 0 -- 975
	do -- 975
		i = 0 -- 976
		while i < #RELOAD_GRID do -- 976
			local g = RELOAD_GRID[i + 1] -- 977
			local nx = cx + (g.col - 1) * step -- 978
			local ny = cy + (g.row - 1) * step -- 979
			uiInkDraw:drawDot( -- 980
				Vec2(nx, ny), -- 980
				1.8, -- 980
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 980
			) -- 980
			i = i + 1 -- 976
		end -- 976
	end -- 976
	do -- 976
		i = 0 -- 984
		while i < #samplePath - 1 do -- 984
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 985
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 986
			uiInkDraw:drawSegment( -- 987
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 988
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 989
				1.8, -- 990
				toColor(accent, 220 * appear) -- 991
			) -- 991
			i = i + 1 -- 984
		end -- 984
	end -- 984
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 996
	local kx = cx + (keyNode.col - 1) * step -- 997
	local ky = cy + (keyNode.row - 1) * step -- 998
	drawReloadPatternGlyph( -- 999
		uiInkDraw, -- 999
		kx, -- 999
		ky, -- 999
		7.5, -- 999
		effect, -- 999
		accent, -- 999
		appear -- 999
	) -- 999
	fillRadialGlow( -- 1000
		uiGlow, -- 1000
		kx, -- 1000
		ky, -- 1000
		14, -- 1000
		14, -- 1000
		toColor(PALETTE.amberCore, 45 * appear), -- 1000
		Color(244, 234, 214, 0), -- 1000
		10 -- 1000
	) -- 1000
end -- 961
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1004
	local prog = math.max( -- 1011
		0, -- 1011
		math.min( -- 1011
			1, -- 1011
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 1011
		) -- 1011
	) -- 1011
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 1012
	local cx = ctx.uiW * 0.5 -- 1013
	local cy = ctx.uiH * 0.68 -- 1014
	local w = 440 -- 1015
	local h = 112 -- 1016
	drawSilkVeil( -- 1018
		uiDraw, -- 1018
		uiArt, -- 1018
		"cb_handover_veil", -- 1018
		cx, -- 1018
		cy, -- 1018
		w + 80, -- 1018
		h + 28, -- 1018
		PALETTE.inkWash, -- 1018
		0.84 * fade, -- 1018
		0 -- 1018
	) -- 1018
	drawHairline( -- 1019
		uiInkDraw, -- 1019
		uiArt, -- 1019
		"cb_handover_top", -- 1019
		cx, -- 1019
		cy + h * 0.48, -- 1019
		w - 30, -- 1019
		PALETTE.amber, -- 1019
		0.58 * fade, -- 1019
		true, -- 1019
		2 -- 1019
	) -- 1019
	local passK = math.min(1, prog / 0.38) -- 1022
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 1023
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 1024
	local a245 = math.floor(245 * fade + 0.5) -- 1025
	local a235 = math.floor(235 * fade + 0.5) -- 1026
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 1029
	local childHandY = cy - 4 + gripLift * 0.2 -- 1030
	local solHandX = cx + 82 - math.min( -- 1031
		1, -- 1031
		math.max(0, (prog - 0.18) / 0.28) -- 1031
	) * 42 -- 1031
	local solHandY = cy - 4 + gripLift -- 1032
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1033
	local gunY = cy + 6 + gripLift -- 1034
	local childPlaced = uiArt:tryPlacePath( -- 1036
		"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 1036
		"cb_ho_child", -- 1036
		childHandX, -- 1036
		childHandY - 6, -- 1036
		154, -- 1036
		68, -- 1036
		{ -- 1036
			anchorX = 0.43, -- 1037
			anchorY = 0.52, -- 1038
			facing = -1, -- 1039
			smooth = true, -- 1040
			opacity = 0.94 * fade, -- 1041
			layer = 3 -- 1042
		} -- 1042
	) -- 1042
	if not childPlaced then -- 1042
		uiInkDraw:drawPolygon( -- 1045
			{ -- 1045
				Vec2(cx - 148, cy - 22), -- 1046
				Vec2(cx - 146, cy - 8), -- 1047
				Vec2(childHandX - 10, childHandY + 4), -- 1048
				Vec2(childHandX - 10, childHandY - 6) -- 1049
			}, -- 1049
			Color(164, 78, 54, a235), -- 1050
			1, -- 1050
			Color(52, 28, 22, a235) -- 1050
		) -- 1050
		uiInkDraw:drawSegment( -- 1051
			Vec2(childHandX - 11, childHandY + 4), -- 1051
			Vec2(childHandX - 11, childHandY - 6), -- 1051
			2, -- 1051
			Color(204, 174, 122, a245) -- 1051
		) -- 1051
		uiInkDraw:drawEllipse( -- 1052
			Vec2(childHandX, childHandY - 1), -- 1052
			6.2, -- 1052
			4.4, -- 1052
			Color(238, 212, 182, a245) -- 1052
		) -- 1052
	end -- 1052
	local solPlaced = uiArt:tryPlacePath( -- 1055
		"assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp", -- 1055
		"cb_ho_zhou", -- 1055
		solHandX, -- 1055
		solHandY - 4, -- 1055
		168, -- 1055
		78, -- 1055
		{ -- 1055
			anchorX = 0.57, -- 1056
			anchorY = 0.5, -- 1057
			facing = -1, -- 1058
			smooth = true, -- 1059
			opacity = 0.96 * fade, -- 1060
			layer = 4 -- 1061
		} -- 1061
	) -- 1061
	if not solPlaced then -- 1061
		uiInkDraw:drawPolygon( -- 1064
			{ -- 1064
				Vec2(cx + 154, cy - 18), -- 1065
				Vec2(cx + 154, cy - 1), -- 1066
				Vec2(solHandX + 12, solHandY + 6), -- 1067
				Vec2(solHandX + 12, solHandY - 7) -- 1068
			}, -- 1068
			toColor(CUFF_PALETTE.indigoBase, a245), -- 1069
			1, -- 1069
			toColor(CUFF_PALETTE.indigoShadow, a245) -- 1069
		) -- 1069
		local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1070
		uiInkDraw:drawSegment( -- 1071
			Vec2(solHandX + 16, solHandY - 5), -- 1071
			Vec2(solHandX + 19, solHandY + 4), -- 1071
			1.5, -- 1071
			mendCol -- 1071
		) -- 1071
		uiInkDraw:drawSegment( -- 1072
			Vec2(solHandX + 21, solHandY - 5), -- 1072
			Vec2(solHandX + 24, solHandY + 4), -- 1072
			1.5, -- 1072
			mendCol -- 1072
		) -- 1072
		uiInkDraw:drawSegment( -- 1073
			Vec2(solHandX + 26, solHandY - 5), -- 1073
			Vec2(solHandX + 29, solHandY + 4), -- 1073
			1.5, -- 1073
			mendCol -- 1073
		) -- 1073
		uiInkDraw:drawEllipse( -- 1074
			Vec2(solHandX, solHandY), -- 1074
			6.8, -- 1074
			5, -- 1074
			toColor(CUFF_PALETTE.skinBase, a245) -- 1074
		) -- 1074
	end -- 1074
	local gunClip = self.handoverEffect == "echo" and "craft_echo_gun" or "craft_lantern_gun" -- 1077
	if not uiArt:tryPlacePath( -- 1077
		"assets/art/vfx_craft_art.clip|" .. gunClip, -- 1078
		"cb_ho_gun", -- 1078
		gunX, -- 1078
		gunY, -- 1078
		170, -- 1078
		52, -- 1078
		{ -- 1078
			anchorX = 0.5, -- 1079
			anchorY = 0.5, -- 1080
			preserveAspect = true, -- 1081
			smooth = true, -- 1082
			opacity = 0.98 * fade, -- 1083
			layer = 5 -- 1084
		} -- 1084
	) then -- 1084
		uiInkDraw:drawPolygon( -- 1086
			{ -- 1086
				Vec2(gunX - 42, gunY - 8), -- 1087
				Vec2(gunX - 12, gunY - 3), -- 1088
				Vec2(gunX + 16, gunY + 1), -- 1089
				Vec2(gunX + 16, gunY + 6), -- 1090
				Vec2(gunX - 16, gunY + 3), -- 1091
				Vec2(gunX - 40, gunY + 1) -- 1092
			}, -- 1092
			Color(108, 72, 48, a245), -- 1093
			1, -- 1093
			Color(46, 30, 20, a245) -- 1093
		) -- 1093
		uiInkDraw:drawSegment( -- 1094
			Vec2(gunX - 6, gunY + 4), -- 1094
			Vec2(gunX + 56, gunY + 8), -- 1094
			2.8, -- 1094
			Color(152, 148, 138, a245) -- 1094
		) -- 1094
		uiInkDraw:drawSegment( -- 1095
			Vec2(gunX + 14, gunY + 1), -- 1095
			Vec2(gunX + 14, gunY + 8), -- 1095
			2, -- 1095
			Color(198, 166, 112, a245) -- 1095
		) -- 1095
		uiInkDraw:drawSegment( -- 1096
			Vec2(gunX + 36, gunY + 3), -- 1096
			Vec2(gunX + 36, gunY + 9), -- 1096
			1.6, -- 1096
			Color(198, 166, 112, a245) -- 1096
		) -- 1096
	end -- 1096
	drawReloadPatternGlyph( -- 1098
		uiInkDraw, -- 1098
		gunX + 2, -- 1098
		gunY + 26, -- 1098
		8.5, -- 1098
		self.handoverEffect, -- 1098
		PALETTE.amberCore, -- 1098
		fade -- 1098
	) -- 1098
	fillRadialGlow( -- 1099
		uiGlow, -- 1099
		gunX + 4, -- 1099
		gunY + 4, -- 1099
		48, -- 1099
		22, -- 1099
		toColor(PALETTE.amberCore, 52 * fade), -- 1099
		Color(244, 234, 214, 0), -- 1099
		12 -- 1099
	) -- 1099
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1101
	ctx.texts:put( -- 1104
		"xs", -- 1104
		caption, -- 1104
		cx, -- 1104
		cy - 34, -- 1104
		toColor(PALETTE.amberCore), -- 1104
		0.5, -- 1104
		0.5, -- 1104
		"Center", -- 1104
		1.4, -- 1104
		0.94 * fade, -- 1104
		0.08 -- 1104
	) -- 1104
end -- 1004
function ____exports.createCraftBenchPlugin(contract) -- 1108
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1109
end -- 1108
return ____exports -- 1108