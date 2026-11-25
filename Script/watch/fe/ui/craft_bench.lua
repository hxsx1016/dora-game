-- [ts]: craft_bench.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Keyboard = ____Dora.Keyboard -- 17
local Mouse = ____Dora.Mouse -- 17
local Rect = ____Dora.Rect -- 17
local Vec2 = ____Dora.Vec2 -- 17
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 28
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 29
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 30
local ____theme = require("Script.watch.fe.theme") -- 32
local PALETTE = ____theme.PALETTE -- 33
local drawBlossomDot = ____theme.drawBlossomDot -- 35
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 36
local drawHairline = ____theme.drawHairline -- 37
local drawSilkRibbon = ____theme.drawSilkRibbon -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 39
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local fillVGradRect = ____theme.fillVGradRect -- 41
local toColor = ____theme.toColor -- 42
local MATERIAL_NAMES = { -- 45
	wood = "木纹筹", -- 46
	bell = "铃纹筹", -- 47
	wood_tally = "木纹筹", -- 48
	bell_tally = "铃纹筹", -- 49
	scrap = "旧木料", -- 50
	wedge = "木楔", -- 51
	ammo = "备用弹" -- 52
} -- 52
local WOOD_TOP = Color(98, 68, 48, 252) -- 55
local WOOD_BODY = Color(58, 40, 30, 250) -- 56
local WOOD_EDGE = Color(152, 114, 82, 235) -- 57
local WOOD_DARK = Color(30, 21, 17, 248) -- 58
local function materialLabel(key) -- 85
	return MATERIAL_NAMES[key] or key -- 86
end -- 85
local function resolveRuntimeContract(injected) -- 89
	if injected ~= nil then -- 89
		return injected -- 91
	end -- 91
	local g = _G -- 93
	local ____temp_0 -- 94
	if g.package ~= nil then -- 94
		____temp_0 = g.package.loaded -- 94
	else -- 94
		____temp_0 = nil -- 94
	end -- 94
	local loaded = ____temp_0 -- 94
	if loaded == nil then -- 94
		return nil -- 96
	end -- 96
	local feHook = loaded["watch.fe"] -- 98
	if feHook ~= nil and type(feHook) == "table" then -- 98
		local c = feHook.contract -- 100
		if c ~= nil and type(c) == "table" then -- 100
			return c -- 102
		end -- 102
	end -- 102
	return nil -- 105
end -- 89
local function dispatchIntentFallback(p, intent) -- 108
	local rec = p -- 109
	local handler = rec.submitFeIntent -- 110
	if type(handler) == "function" then -- 110
		return handler(p, intent) ~= false -- 112
	end -- 112
	return false -- 114
end -- 108
local function collectMissingMaterials(recipe, inventory) -- 117
	local missing = {} -- 121
	for mat in pairs(recipe.cost) do -- 122
		local need = recipe.cost[mat] -- 123
		local have = inventory[mat] or 0 -- 124
		if have < need then -- 124
			missing[#missing + 1] = mat -- 126
		end -- 126
	end -- 126
	return missing -- 129
end -- 117
local function sortedMaterialKeys(inventory, recipes) -- 132
	local seen = {} -- 136
	local out = {} -- 137
	local prefer = {"wood", "bell", "wood_tally", "bell_tally"} -- 139
	local hasBackendKeys = inventory.wood ~= nil or inventory.bell ~= nil -- 140
	local i = 0 -- 141
	do -- 141
		i = 0 -- 142
		while i < #recipes do -- 142
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 142
				hasBackendKeys = true -- 144
			end -- 144
			i = i + 1 -- 142
		end -- 142
	end -- 142
	local primary = hasBackendKeys and ({"wood", "bell"}) or ({"wood_tally", "bell_tally"}) -- 147
	do -- 147
		i = 0 -- 148
		while i < #primary do -- 148
			seen[primary[i + 1]] = true -- 149
			out[#out + 1] = primary[i + 1] -- 150
			i = i + 1 -- 148
		end -- 148
	end -- 148
	do -- 148
		i = 0 -- 152
		while i < #recipes do -- 152
			local cost = recipes[i + 1].cost -- 153
			for k in pairs(cost) do -- 154
				if not seen[k] then -- 154
					seen[k] = true -- 156
					out[#out + 1] = k -- 157
				end -- 157
			end -- 157
			i = i + 1 -- 152
		end -- 152
	end -- 152
	do -- 152
		i = 0 -- 161
		while i < #prefer do -- 161
			local k = prefer[i + 1] -- 162
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 162
				seen[k] = true -- 164
				out[#out + 1] = k -- 165
			end -- 165
			i = i + 1 -- 161
		end -- 161
	end -- 161
	return out -- 168
end -- 132
____exports.CraftBenchPlugin = __TS__Class() -- 171
local CraftBenchPlugin = ____exports.CraftBenchPlugin -- 171
CraftBenchPlugin.name = "CraftBenchPlugin" -- 171
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 213
	self.id = "fe-02-craft-bench" -- 172
	self.wasActive = false -- 176
	self.selectedIdx = 0 -- 177
	self.animTime = 0 -- 178
	self.openAnimT = 0 -- 179
	self.requestSeq = 0 -- 182
	self.pendingRecipeId = "" -- 183
	self.pendingFirstCraftAtSubmit = true -- 184
	self.prevCraftedMap = {} -- 185
	self.missingFlashT = 0 -- 188
	self.missingList = {} -- 189
	self.handoverRemaining = 0 -- 192
	self.handoverDuration = 1 -- 193
	self.handoverWeaponId = "" -- 194
	self.handoverWeaponName = "" -- 195
	self.handoverEffect = "light" -- 196
	self.prevLeft = false -- 199
	self.prevRight = false -- 200
	self.prevLeftKey = false -- 201
	self.prevRightKey = false -- 202
	self.prevConfirm = false -- 203
	self.prevCancel = false -- 204
	self.pointerActive = false -- 205
	self.cardBoxes = {} -- 208
	self.closeBox = Rect(0, 0, 0, 0) -- 209
	self.injectedContract = contract -- 214
end -- 213
function CraftBenchPlugin.prototype.injectInputForTest(self, sim) -- 218
	self.pendingSimInput = sim -- 219
end -- 218
function CraftBenchPlugin.prototype.getState(self) -- 222
	local inv = {} -- 223
	local craftedIds = {} -- 224
	local equipped = "standard_gun" -- 225
	if self.lastSnapshotBench ~= nil then -- 225
		for k in pairs(self.lastSnapshotBench.inventory) do -- 227
			inv[k] = self.lastSnapshotBench.inventory[k] -- 228
		end -- 228
		local i = 0 -- 230
		do -- 230
			i = 0 -- 231
			while i < #self.lastSnapshotBench.recipes do -- 231
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 231
					craftedIds[#craftedIds + 1] = self.lastSnapshotBench.recipes[i + 1].id -- 233
				end -- 233
				i = i + 1 -- 231
			end -- 231
		end -- 231
		equipped = self.lastSnapshotBench.equippedWeapon -- 236
	end -- 236
	return { -- 238
		active = self.wasActive, -- 239
		selectedIndex = self.selectedIdx, -- 240
		pendingRecipeId = self.pendingRecipeId, -- 241
		missingFlashT = self.missingFlashT, -- 242
		missingMaterials = __TS__ArraySlice(self.missingList), -- 243
		handoverActive = self.handoverRemaining > 0, -- 244
		handoverDuration = self.handoverDuration, -- 245
		handoverRemaining = self.handoverRemaining, -- 246
		handoverWeaponId = self.handoverWeaponId, -- 247
		equippedWeapon = equipped, -- 248
		inventory = inv, -- 249
		craftedIds = craftedIds -- 250
	} -- 250
end -- 222
function CraftBenchPlugin.prototype.onBindPlay(self, _p, view) -- 254
	self.wasActive = view.craftBench.active -- 256
	self.selectedIdx = 0 -- 257
	self.animTime = 0 -- 258
	self.openAnimT = view.craftBench.active and 1 or 0 -- 259
	self.pendingRecipeId = "" -- 260
	self.pendingFirstCraftAtSubmit = not view.craftBench.firstCraftDone -- 261
	self.missingFlashT = 0 -- 262
	self.missingList = {} -- 263
	self.handoverRemaining = 0 -- 264
	self.handoverDuration = 1 -- 265
	self.handoverWeaponId = "" -- 266
	self.handoverWeaponName = "" -- 267
	self.pendingSimInput = nil -- 268
	self:syncCraftedSnapshot(view.craftBench) -- 269
	self.lastSnapshotBench = view.craftBench -- 270
	self:resetInputEdges() -- 271
end -- 254
function CraftBenchPlugin.prototype.syncCraftedSnapshot(self, bench) -- 274
	self.prevCraftedMap = {} -- 275
	local i = 0 -- 276
	do -- 276
		i = 0 -- 277
		while i < #bench.recipes do -- 277
			self.prevCraftedMap[bench.recipes[i + 1].id] = bench.recipes[i + 1].crafted -- 278
			i = i + 1 -- 277
		end -- 277
	end -- 277
end -- 274
function CraftBenchPlugin.prototype.resetInputEdges(self) -- 282
	local ____temp_1 -- 283
	if type(Mouse) ~= "nil" then -- 283
		____temp_1 = Mouse.leftButtonPressed -- 283
	else -- 283
		____temp_1 = false -- 283
	end -- 283
	self.prevLeft = ____temp_1 -- 283
	local ____temp_2 -- 284
	if type(Mouse) ~= "nil" then -- 284
		____temp_2 = Mouse.rightButtonPressed -- 284
	else -- 284
		____temp_2 = false -- 284
	end -- 284
	self.prevRight = ____temp_2 -- 284
	if type(Keyboard) ~= "nil" then -- 284
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 286
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 287
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 288
		self.prevCancel = Keyboard:isKeyPressed("Escape") or Keyboard:isKeyPressed("BackSpace") -- 289
	end -- 289
end -- 282
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 293
	local contract = resolveRuntimeContract(self.injectedContract) -- 294
	if contract ~= nil then -- 294
		return contract:submitIntent(p, intent) -- 296
	end -- 296
	return dispatchIntentFallback(p, intent) -- 298
end -- 293
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 301
	local uiW = ctx.uiW -- 308
	local uiH = ctx.uiH -- 309
	local benchW = math.min(uiW - 88, 692) -- 310
	local benchH = 290 -- 311
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 313
	local benchX = soldierUiX < uiW * 0.52 and math.max(36, uiW - benchW - 44) or 44 -- 314
	local benchY = math.max( -- 317
		46, -- 317
		math.min(uiH * 0.1, 66) -- 317
	) -- 317
	local matW = 196 -- 318
	local cardsAreaX = benchX + matW + 18 -- 320
	local cardsAreaW = benchW - matW - 34 -- 321
	local count = math.max(1, recipeCount) -- 322
	local gap = 14 -- 323
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 324
	local cardH = benchH - 72 -- 325
	local cardY = benchY + 20 -- 326
	self.cardBoxes = {} -- 328
	local i = 0 -- 329
	do -- 329
		i = 0 -- 330
		while i < count do -- 330
			local ____self_cardBoxes_3 = self.cardBoxes -- 330
			____self_cardBoxes_3[#____self_cardBoxes_3 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 331
			i = i + 1 -- 330
		end -- 330
	end -- 330
	self.closeBox = Rect(benchX + benchW - 88, benchY + benchH - 40, 72, 26) -- 333
	return { -- 334
		benchX = benchX, -- 334
		benchY = benchY, -- 334
		benchW = benchW, -- 334
		benchH = benchH, -- 334
		matW = matW -- 334
	} -- 334
end -- 301
function CraftBenchPlugin.prototype.update(self, ctx) -- 337
	local bench = ctx.view.craftBench -- 338
	self.lastSnapshotBench = bench -- 339
	if ctx.paused then -- 339
		self:resetInputEdges() -- 343
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
		self:resetInputEdges() -- 366
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
		local ____temp_4 -- 406
		if self.pendingRecipeId == newlyCrafted.id then -- 406
			____temp_4 = self.pendingFirstCraftAtSubmit -- 407
		else -- 407
			____temp_4 = bench.justCraftedTimer >= 0.72 -- 408
		end -- 408
		local isFirst = ____temp_4 -- 406
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
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or ctx.input.mx / ctx.uiScale -- 441
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or ctx.input.my / ctx.uiScale -- 442
	local ____temp_11 -- 443
	if (sim and sim.pointerX) ~= nil then -- 443
		____temp_11 = true -- 443
	else -- 443
		____temp_11 = ctx.input.inside -- 443
	end -- 443
	local inside = ____temp_11 -- 443
	local ____temp_14 -- 444
	if (sim and sim.click) ~= nil then -- 444
		____temp_14 = sim.click -- 444
	else -- 444
		____temp_14 = ctx.input.fire.held or type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 444
	end -- 444
	local leftHeld = ____temp_14 -- 444
	local ____temp_17 -- 445
	if (sim and sim.rightClick) ~= nil then -- 445
		____temp_17 = sim.rightClick -- 445
	else -- 445
		____temp_17 = type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 445
	end -- 445
	local rightHeld = ____temp_17 -- 445
	local ____temp_20 -- 447
	if (sim and sim.click) ~= nil then -- 447
		____temp_20 = sim.click -- 447
	else -- 447
		____temp_20 = leftHeld and not self.prevLeft -- 447
	end -- 447
	local click = ____temp_20 -- 447
	local ____temp_23 -- 448
	if (sim and sim.rightClick) ~= nil then -- 448
		____temp_23 = sim.rightClick -- 448
	else -- 448
		____temp_23 = rightHeld and not self.prevRight -- 448
	end -- 448
	local rightClick = ____temp_23 -- 448
	self.prevLeft = leftHeld -- 449
	self.prevRight = rightHeld -- 450
	local move = 0 -- 452
	local confirm = false -- 453
	local cancel = false -- 454
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 454
		move = sim.move or 0 -- 457
		confirm = sim.confirm == true -- 458
		cancel = sim.cancel == true -- 459
	elseif type(Keyboard) ~= "nil" then -- 459
		local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 461
		local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 462
		local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 463
		local cc = Keyboard:isKeyPressed("BackSpace") -- 464
		if lk and not self.prevLeftKey then -- 464
			move = move - 1 -- 465
		end -- 465
		if rk and not self.prevRightKey then -- 465
			move = move + 1 -- 466
		end -- 466
		confirm = cf and not self.prevConfirm -- 467
		cancel = cc and not self.prevCancel -- 468
		self.prevLeftKey = lk -- 469
		self.prevRightKey = rk -- 470
		self.prevConfirm = cf -- 471
		self.prevCancel = cc -- 472
	end -- 472
	local ptr = Vec2(ptrX, ptrY) -- 476
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 477
	if cancel or rightClick or click and hitClose then -- 477
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 479
		return -- 480
	end -- 480
	local count = #bench.recipes -- 483
	if count == 0 then -- 483
		return -- 485
	end -- 485
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(ctx.input.mdx) + math.abs(ctx.input.mdy) >= ctx.uiScale -- 488
	local hitCard = -1 -- 490
	if inside then -- 490
		local i = 0 -- 492
		do -- 492
			i = 0 -- 493
			while i < #self.cardBoxes do -- 493
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 493
					hitCard = i -- 495
					break -- 496
				end -- 496
				i = i + 1 -- 493
			end -- 493
		end -- 493
	end -- 493
	if move ~= 0 then -- 493
		self.pointerActive = false -- 502
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 503
	elseif pointerMoved and hitCard >= 0 then -- 503
		self.pointerActive = true -- 505
		self.selectedIdx = hitCard -- 506
	end -- 506
	local triggerConfirm = confirm or click and hitCard >= 0 -- 509
	if not triggerConfirm then -- 509
		return -- 511
	end -- 511
	if click and hitCard >= 0 then -- 511
		self.selectedIdx = hitCard -- 514
	end -- 514
	if self.handoverRemaining > 0.05 then -- 514
		return -- 519
	end -- 519
	local recipe = bench.recipes[self.selectedIdx + 1] -- 522
	if recipe == nil then -- 522
		return -- 524
	end -- 524
	if recipe.crafted then -- 524
		if bench.equippedWeapon ~= recipe.id then -- 524
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 529
		end -- 529
		return -- 531
	end -- 531
	if self.pendingRecipeId == recipe.id then -- 531
		return -- 536
	end -- 536
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 540
	if #missing > 0 then -- 540
		self.missingList = missing -- 542
		self.missingFlashT = 0.55 -- 543
		ctx.audio:playOnce( -- 544
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 545
			"sfx", -- 546
			"assets/audio/combat/craft_insufficient.wav", -- 547
			0.76, -- 548
			"craft:insufficient:" .. recipe.id, -- 549
			ctx.p.ticks -- 550
		) -- 550
		return -- 552
	end -- 552
	self.missingList = {} -- 555
	self.missingFlashT = 0 -- 556
	self.pendingRecipeId = recipe.id -- 557
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 558
	self.requestSeq = self.requestSeq + 1 -- 559
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 560
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 561
	if not accepted then -- 561
		self.pendingRecipeId = "" -- 567
	end -- 567
end -- 437
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 571
	local bench = ctx.view.craftBench -- 578
	if not bench.active and self.handoverRemaining <= 0.01 then -- 578
		return false -- 580
	end -- 580
	if not bench.active then -- 580
		self:drawHandoverOverlay( -- 585
			uiDraw, -- 585
			uiInkDraw, -- 585
			uiArt, -- 585
			uiGlow, -- 585
			ctx -- 585
		) -- 585
		return false -- 586
	end -- 586
	local appear = math.min(1, self.openAnimT) -- 589
	local layout = self:computeLayout(ctx, #bench.recipes) -- 590
	local bx = layout.benchX -- 591
	local by = layout.benchY -- 592
	local bw = layout.benchW -- 593
	local bh = layout.benchH -- 594
	fillVGradRect( -- 597
		uiDraw, -- 598
		0, -- 599
		0, -- 600
		ctx.uiW, -- 601
		by + bh + 64, -- 602
		Color( -- 603
			12, -- 603
			10, -- 603
			10, -- 603
			math.floor(168 * appear + 0.5) -- 603
		), -- 603
		Color(12, 10, 10, 0) -- 604
	) -- 604
	self:drawWoodenBenchBody( -- 608
		uiDraw, -- 608
		uiInkDraw, -- 608
		uiArt, -- 608
		uiGlow, -- 608
		bx, -- 608
		by, -- 608
		bw, -- 608
		bh, -- 608
		appear -- 608
	) -- 608
	ctx.texts:put( -- 611
		"md", -- 611
		"安全工台 · 改制鸟铳", -- 611
		bx + 54, -- 611
		by + bh - 26, -- 611
		toColor(PALETTE.amberCore), -- 611
		0, -- 611
		0.5, -- 611
		"Left", -- 611
		2, -- 611
		0.96 * appear, -- 611
		0.08 -- 611
	) -- 611
	drawHairline( -- 612
		uiInkDraw, -- 612
		uiArt, -- 612
		"cb_head_line", -- 612
		bx + bw * 0.5, -- 612
		by + bh - 46, -- 612
		bw - 36, -- 612
		PALETTE.amberDim, -- 612
		0.55 * appear, -- 612
		false, -- 612
		2 -- 612
	) -- 612
	local closeHover = ctx.input.inside and self.closeBox:containsPoint(Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale)) -- 614
	uiInkDraw:drawRect( -- 615
		self.closeBox, -- 616
		Color( -- 617
			24, -- 617
			18, -- 617
			16, -- 617
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 617
		), -- 617
		0.9, -- 618
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 619
	) -- 619
	ctx.texts:put( -- 621
		"xs", -- 622
		"收起", -- 623
		self.closeBox.x + self.closeBox.width * 0.5, -- 624
		self.closeBox.y + self.closeBox.height * 0.5, -- 625
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 626
		0.5, -- 627
		0.5, -- 628
		"Center", -- 629
		1.4, -- 630
		0.95 * appear, -- 631
		0.06 -- 632
	) -- 632
	self:drawTableMaterials( -- 636
		uiDraw, -- 636
		uiInkDraw, -- 636
		uiArt, -- 636
		ctx, -- 636
		bench, -- 636
		bx + 18, -- 636
		by + 22, -- 636
		layout.matW - 14, -- 636
		bh - 76, -- 636
		appear -- 636
	) -- 636
	local i = 0 -- 639
	do -- 639
		i = 0 -- 640
		while i < #bench.recipes and i < #self.cardBoxes do -- 640
			self:drawRecipeCard( -- 641
				uiDraw, -- 642
				uiInkDraw, -- 643
				uiArt, -- 644
				uiGlow, -- 645
				ctx, -- 646
				bench, -- 647
				bench.recipes[i + 1], -- 648
				self.cardBoxes[i + 1], -- 649
				i == self.selectedIdx, -- 650
				appear -- 651
			) -- 651
			i = i + 1 -- 640
		end -- 640
	end -- 640
	if self.handoverRemaining > 0.01 then -- 640
		self:drawHandoverOverlay( -- 657
			uiDraw, -- 657
			uiInkDraw, -- 657
			uiArt, -- 657
			uiGlow, -- 657
			ctx -- 657
		) -- 657
	end -- 657
	return true -- 660
end -- 571
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 663
	uiDraw:drawRect( -- 675
		Rect(bx, by, bw, bh), -- 675
		Color( -- 675
			WOOD_BODY.r, -- 675
			WOOD_BODY.g, -- 675
			WOOD_BODY.b, -- 675
			math.floor(244 * appear + 0.5) -- 675
		), -- 675
		1.4, -- 675
		toColor(PALETTE.amberDim, 190 * appear) -- 675
	) -- 675
	uiDraw:drawRect( -- 677
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 677
		Color( -- 677
			WOOD_TOP.r, -- 677
			WOOD_TOP.g, -- 677
			WOOD_TOP.b, -- 677
			math.floor(250 * appear + 0.5) -- 677
		), -- 677
		1, -- 677
		WOOD_EDGE -- 677
	) -- 677
	uiInkDraw:drawSegment( -- 678
		Vec2(bx - 6, by + bh + 3), -- 678
		Vec2(bx + bw + 6, by + bh + 3), -- 678
		1.2, -- 678
		toColor(PALETTE.amberCore, 115 * appear) -- 678
	) -- 678
	uiDraw:drawRect( -- 680
		Rect(bx + 18, by - 26, 22, 26), -- 680
		Color( -- 680
			WOOD_DARK.r, -- 680
			WOOD_DARK.g, -- 680
			WOOD_DARK.b, -- 680
			math.floor(235 * appear + 0.5) -- 680
		) -- 680
	) -- 680
	uiDraw:drawRect( -- 681
		Rect(bx + bw - 40, by - 26, 22, 26), -- 681
		Color( -- 681
			WOOD_DARK.r, -- 681
			WOOD_DARK.g, -- 681
			WOOD_DARK.b, -- 681
			math.floor(235 * appear + 0.5) -- 681
		) -- 681
	) -- 681
	local g = 1 -- 684
	do -- 684
		g = 1 -- 685
		while g <= 4 do -- 685
			local gy = by + (bh - 50) * (g / 5) -- 686
			uiDraw:drawSegment( -- 687
				Vec2(bx + 10, gy), -- 687
				Vec2(bx + bw - 10, gy), -- 687
				0.75, -- 687
				Color( -- 687
					34, -- 687
					23, -- 687
					18, -- 687
					math.floor(110 * appear + 0.5) -- 687
				) -- 687
			) -- 687
			g = g + 1 -- 685
		end -- 685
	end -- 685
	local lx = bx + 28 -- 691
	local ly = by + bh - 24 -- 692
	uiArt:tryPlace( -- 693
		"prop_lantern", -- 693
		"cb_lantern", -- 693
		lx, -- 693
		ly, -- 693
		20, -- 693
		26, -- 693
		{opacity = 0.94 * appear, layer = 4} -- 693
	) -- 693
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 694
	fillRadialGlow( -- 695
		uiGlow, -- 696
		lx + 10, -- 697
		ly - 10, -- 698
		260 * pulse, -- 699
		180 * pulse, -- 700
		Color( -- 701
			238, -- 701
			198, -- 701
			128, -- 701
			math.floor(38 * appear + 0.5) -- 701
		), -- 701
		Color(238, 180, 92, 0), -- 702
		16 -- 703
	) -- 703
end -- 663
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 707
	uiDraw:drawRect( -- 719
		Rect(x, y, w, h), -- 719
		Color( -- 719
			26, -- 719
			20, -- 719
			17, -- 719
			math.floor(188 * appear + 0.5) -- 719
		), -- 719
		0.9, -- 719
		toColor(PALETTE.amberDim, 130 * appear) -- 719
	) -- 719
	drawFiligreeCorners( -- 720
		uiInkDraw, -- 720
		uiArt, -- 720
		"cb_mat_frame", -- 720
		x + 3, -- 720
		y + 3, -- 720
		w - 6, -- 720
		h - 6, -- 720
		PALETTE.amberDim, -- 720
		0.48 * appear, -- 720
		16, -- 720
		false, -- 720
		2 -- 720
	) -- 720
	ctx.texts:put( -- 722
		"xs", -- 722
		"案边持有", -- 722
		x + 12, -- 722
		y + h - 18, -- 722
		toColor(PALETTE.amberCore), -- 722
		0, -- 722
		0.5, -- 722
		"Left", -- 722
		1.4, -- 722
		0.92 * appear, -- 722
		0.06 -- 722
	) -- 722
	uiInkDraw:drawSegment( -- 723
		Vec2(x + 10, y + h - 32), -- 723
		Vec2(x + w - 10, y + h - 32), -- 723
		0.75, -- 723
		toColor(PALETTE.amberDim, 115 * appear) -- 723
	) -- 723
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 725
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #keys and i < 4 do -- 727
			local mat = keys[i + 1] -- 728
			local count = bench.inventory[mat] or 0 -- 729
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 730
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 731
			local rowY = y + h - 62 - i * 48 -- 732
			if isMissing then -- 732
				uiDraw:drawRect( -- 735
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 735
					toColor(PALETTE.rougeSoft, 145 * appear), -- 735
					1, -- 735
					toColor(PALETTE.crimsonCore, 220 * appear) -- 735
				) -- 735
			end -- 735
			local shown = math.max( -- 739
				1, -- 739
				math.min(4, count) -- 739
			) -- 739
			local t = 0 -- 740
			do -- 740
				t = 0 -- 741
				while t < shown do -- 741
					local tx = x + 22 + t * 14 + shake -- 742
					local filled = t < count -- 743
					if mat == "bell_tally" or mat == "bell" then -- 743
						drawReloadPatternGlyph( -- 745
							uiInkDraw, -- 746
							tx, -- 747
							rowY, -- 748
							7.5, -- 749
							"echo", -- 750
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 751
							(filled and 0.96 or 0.38) * appear -- 752
						) -- 752
					else -- 752
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 755
						uiInkDraw:drawRect( -- 756
							Rect(tx - 4, rowY - 10, 8, 20), -- 757
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 758
							1, -- 759
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 760
						) -- 760
						if filled then -- 760
							uiInkDraw:drawSegment( -- 763
								Vec2(tx - 2, rowY + 3), -- 763
								Vec2(tx + 2, rowY + 3), -- 763
								0.9, -- 763
								toColor(PALETTE.xuanInk, 185 * appear) -- 763
							) -- 763
							uiInkDraw:drawSegment( -- 764
								Vec2(tx - 2, rowY - 3), -- 764
								Vec2(tx + 2, rowY - 3), -- 764
								0.9, -- 764
								toColor(PALETTE.xuanInk, 185 * appear) -- 764
							) -- 764
						end -- 764
					end -- 764
					t = t + 1 -- 741
				end -- 741
			end -- 741
			ctx.texts:put( -- 769
				"xs", -- 770
				materialLabel(mat), -- 771
				x + 86 + shake, -- 772
				rowY + 5, -- 773
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 774
				0, -- 775
				0.5, -- 776
				"Left", -- 777
				0.8, -- 778
				0.95 * appear, -- 779
				0.06 -- 780
			) -- 780
			ctx.texts:put( -- 782
				"xs", -- 783
				"存 " .. tostring(count), -- 784
				x + 86 + shake, -- 785
				rowY - 11, -- 786
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 787
				0, -- 788
				0.5, -- 789
				"Left", -- 790
				0.8, -- 791
				0.88 * appear, -- 792
				0.06 -- 793
			) -- 793
			i = i + 1 -- 727
		end -- 727
	end -- 727
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 798
	uiInkDraw:drawSegment( -- 799
		Vec2(x + 10, y + 32), -- 799
		Vec2(x + w - 10, y + 32), -- 799
		0.75, -- 799
		toColor(PALETTE.amberDim, 105 * appear) -- 799
	) -- 799
	ctx.texts:put( -- 800
		"xs", -- 800
		"现佩：" .. eqName, -- 800
		x + 12, -- 800
		y + 16, -- 800
		toColor(PALETTE.textMid), -- 800
		0, -- 800
		0.5, -- 800
		"Left", -- 800
		0.8, -- 800
		0.9 * appear, -- 800
		0.06 -- 800
	) -- 800
end -- 707
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 803
	local i = 0 -- 804
	do -- 804
		i = 0 -- 805
		while i < #bench.recipes do -- 805
			if bench.recipes[i + 1].id == weaponId then -- 805
				return bench.recipes[i + 1].name -- 807
			end -- 807
			i = i + 1 -- 805
		end -- 805
	end -- 805
	return "旧制鸟铳" -- 810
end -- 803
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 813
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 825
	local canCraft = not recipe.crafted and #missing == 0 -- 826
	local equipped = bench.equippedWeapon == recipe.id -- 827
	local isPending = self.pendingRecipeId == recipe.id -- 828
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 829
	if not uiArt:tryPlace( -- 829
		"ink_song_paper", -- 832
		"cb_card_" .. recipe.id, -- 832
		box.x + box.width * 0.5, -- 832
		box.y + box.height * 0.5, -- 832
		box.width, -- 832
		box.height, -- 832
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 832
	) then -- 832
		uiDraw:drawRect( -- 833
			box, -- 833
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 833
		) -- 833
	end -- 833
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 836
	drawFiligreeCorners( -- 839
		uiInkDraw, -- 839
		uiArt, -- 839
		"cb_cf_" .. recipe.id, -- 839
		box.x + 5, -- 839
		box.y + 5, -- 839
		box.width - 10, -- 839
		box.height - 10, -- 839
		borderCol, -- 839
		(selected and 0.88 or 0.46) * appear, -- 839
		18, -- 839
		true, -- 839
		2 -- 839
	) -- 839
	if selected then -- 839
		drawSilkRibbon( -- 842
			uiDraw, -- 842
			uiArt, -- 842
			"cb_sel_rib_" .. recipe.id, -- 842
			box.x + box.width * 0.5, -- 842
			box.y + box.height - 26, -- 842
			box.width - 14, -- 842
			30, -- 842
			PALETTE.amberDim, -- 842
			0.24 * appear, -- 842
			2 -- 842
		) -- 842
	end -- 842
	local topY = box.y + box.height - 26 -- 846
	drawBlossomDot( -- 847
		uiInkDraw, -- 847
		uiArt, -- 847
		"cb_dot_" .. recipe.id, -- 847
		box.x + 18, -- 847
		topY, -- 847
		selected and 11 or 7, -- 847
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 847
		0.92 * appear, -- 847
		3 -- 847
	) -- 847
	ctx.texts:put( -- 848
		"md", -- 848
		recipe.name, -- 848
		box.x + 30, -- 848
		topY, -- 848
		toColor(PALETTE.xuanInk), -- 848
		0, -- 848
		0.5, -- 848
		"Left", -- 848
		1.6, -- 848
		0.98 * appear, -- 848
		0 -- 848
	) -- 848
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 850
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 851
	ctx.texts:put( -- 852
		"xs", -- 852
		badge, -- 852
		box.x + box.width - 14, -- 852
		topY, -- 852
		toColor(badgeCol), -- 852
		1, -- 852
		0.5, -- 852
		"Right", -- 852
		1, -- 852
		0.94 * appear, -- 852
		0 -- 852
	) -- 852
	local miniCx = box.x + 46 -- 855
	local miniCy = box.y + box.height - 96 -- 856
	self:drawMiniReloadPreview( -- 857
		uiInkDraw, -- 857
		uiGlow, -- 857
		miniCx, -- 857
		miniCy, -- 857
		recipe.enhancedEffect, -- 857
		appear -- 857
	) -- 857
	local infoX = box.x + 90 -- 860
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 861
	ctx.texts:put( -- 862
		"xs", -- 862
		effTitle, -- 862
		infoX, -- 862
		box.y + box.height - 64, -- 862
		toColor(PALETTE.rouge), -- 862
		0, -- 862
		0.5, -- 862
		"Left", -- 862
		0.8, -- 862
		0.95 * appear, -- 862
		0 -- 862
	) -- 862
	local row = 0 -- 864
	for mat in pairs(recipe.cost) do -- 865
		local need = recipe.cost[mat] -- 866
		local have = bench.inventory[mat] or 0 -- 867
		local lack = not recipe.crafted and have < need -- 868
		local ry = box.y + box.height - 90 - row * 22 -- 869
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 870
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 871
		ctx.texts:put( -- 872
			"xs", -- 872
			text, -- 872
			infoX, -- 872
			ry, -- 872
			toColor(col), -- 872
			0, -- 872
			0.5, -- 872
			"Left", -- 872
			0.6, -- 872
			0.94 * appear, -- 872
			0 -- 872
		) -- 872
		row = row + 1 -- 873
	end -- 873
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 877
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 878
	local btnBg = equipped and Color( -- 881
		168, -- 882
		46, -- 882
		44, -- 882
		math.floor(32 * appear + 0.5) -- 882
	) or (selected and (canCraft or recipe.crafted) and Color( -- 882
		32, -- 884
		30, -- 884
		32, -- 884
		math.floor(218 * appear + 0.5) -- 884
	) or Color( -- 884
		32, -- 885
		30, -- 885
		32, -- 885
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 885
	)) -- 885
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 886
	uiInkDraw:drawRect( -- 889
		btnRect, -- 889
		btnBg, -- 889
		0.9, -- 889
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 889
	) -- 889
	ctx.texts:put( -- 890
		"sm", -- 891
		btnLabel, -- 892
		btnRect.x + btnRect.width * 0.5, -- 893
		btnRect.y + btnRect.height * 0.5, -- 894
		toColor(btnTextCol), -- 895
		0.5, -- 896
		0.5, -- 897
		"Center", -- 898
		1.6, -- 899
		0.96 * appear, -- 900
		0 -- 901
	) -- 901
end -- 813
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 906
	local step = 20 -- 914
	local samplePath = effect == "light" and ({ -- 915
		0, -- 915
		1, -- 915
		2, -- 915
		5, -- 915
		8 -- 915
	}) or (effect == "echo" and ({ -- 915
		0, -- 915
		1, -- 915
		4, -- 915
		5, -- 915
		8 -- 915
	}) or ({ -- 915
		0, -- 915
		3, -- 915
		6, -- 915
		7, -- 915
		8 -- 915
	})) -- 915
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 916
	uiInkDraw:drawRect( -- 919
		Rect(cx - 32, cy - 32, 64, 64), -- 919
		Color( -- 919
			224, -- 919
			218, -- 919
			206, -- 919
			math.floor(145 * appear + 0.5) -- 919
		), -- 919
		0.8, -- 919
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 919
	) -- 919
	local i = 0 -- 920
	do -- 920
		i = 0 -- 921
		while i < #RELOAD_GRID do -- 921
			local g = RELOAD_GRID[i + 1] -- 922
			local nx = cx + (g.col - 1) * step -- 923
			local ny = cy + (g.row - 1) * step -- 924
			uiInkDraw:drawDot( -- 925
				Vec2(nx, ny), -- 925
				1.8, -- 925
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 925
			) -- 925
			i = i + 1 -- 921
		end -- 921
	end -- 921
	do -- 921
		i = 0 -- 929
		while i < #samplePath - 1 do -- 929
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 930
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 931
			uiInkDraw:drawSegment( -- 932
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 933
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 934
				1.8, -- 935
				toColor(accent, 220 * appear) -- 936
			) -- 936
			i = i + 1 -- 929
		end -- 929
	end -- 929
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 941
	local kx = cx + (keyNode.col - 1) * step -- 942
	local ky = cy + (keyNode.row - 1) * step -- 943
	drawReloadPatternGlyph( -- 944
		uiInkDraw, -- 944
		kx, -- 944
		ky, -- 944
		7.5, -- 944
		effect, -- 944
		accent, -- 944
		appear -- 944
	) -- 944
	fillRadialGlow( -- 945
		uiGlow, -- 945
		kx, -- 945
		ky, -- 945
		14, -- 945
		14, -- 945
		toColor(PALETTE.amberCore, 45 * appear), -- 945
		Color(244, 234, 214, 0), -- 945
		10 -- 945
	) -- 945
end -- 906
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 949
	local prog = math.max( -- 956
		0, -- 956
		math.min( -- 956
			1, -- 956
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 956
		) -- 956
	) -- 956
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 957
	local cx = ctx.uiW * 0.5 -- 958
	local cy = ctx.uiH * 0.68 -- 959
	local w = 440 -- 960
	local h = 112 -- 961
	drawSilkVeil( -- 963
		uiDraw, -- 963
		uiArt, -- 963
		"cb_handover_veil", -- 963
		cx, -- 963
		cy, -- 963
		w + 80, -- 963
		h + 28, -- 963
		PALETTE.inkWash, -- 963
		0.84 * fade, -- 963
		0 -- 963
	) -- 963
	drawHairline( -- 964
		uiInkDraw, -- 964
		uiArt, -- 964
		"cb_handover_top", -- 964
		cx, -- 964
		cy + h * 0.48, -- 964
		w - 30, -- 964
		PALETTE.amber, -- 964
		0.58 * fade, -- 964
		true, -- 964
		2 -- 964
	) -- 964
	local passK = math.min(1, prog / 0.38) -- 967
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 968
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 969
	local a245 = math.floor(245 * fade + 0.5) -- 970
	local a235 = math.floor(235 * fade + 0.5) -- 971
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 974
	local childHandY = cy - 4 + gripLift * 0.2 -- 975
	uiInkDraw:drawPolygon( -- 976
		{ -- 976
			Vec2(cx - 148, cy - 22), -- 977
			Vec2(cx - 146, cy - 8), -- 978
			Vec2(childHandX - 10, childHandY + 4), -- 979
			Vec2(childHandX - 10, childHandY - 6) -- 980
		}, -- 980
		Color(164, 78, 54, a235), -- 981
		1, -- 981
		Color(52, 28, 22, a235) -- 981
	) -- 981
	uiInkDraw:drawSegment( -- 982
		Vec2(childHandX - 11, childHandY + 4), -- 982
		Vec2(childHandX - 11, childHandY - 6), -- 982
		2, -- 982
		Color(204, 174, 122, a245) -- 982
	) -- 982
	uiInkDraw:drawEllipse( -- 983
		Vec2(childHandX, childHandY - 1), -- 983
		6.2, -- 983
		4.4, -- 983
		Color(238, 212, 182, a245) -- 983
	) -- 983
	local solHandX = cx + 82 - math.min( -- 986
		1, -- 986
		math.max(0, (prog - 0.18) / 0.28) -- 986
	) * 42 -- 986
	local solHandY = cy - 4 + gripLift -- 987
	uiInkDraw:drawPolygon( -- 988
		{ -- 988
			Vec2(cx + 154, cy - 18), -- 989
			Vec2(cx + 154, cy - 1), -- 990
			Vec2(solHandX + 12, solHandY + 6), -- 991
			Vec2(solHandX + 12, solHandY - 7) -- 992
		}, -- 992
		Color(44, 62, 78, a245), -- 993
		1, -- 993
		Color(22, 30, 42, a245) -- 993
	) -- 993
	uiInkDraw:drawSegment( -- 995
		Vec2(solHandX + 17, solHandY - 5), -- 995
		Vec2(solHandX + 20, solHandY + 5), -- 995
		1.6, -- 995
		Color(220, 210, 190, a245) -- 995
	) -- 995
	uiInkDraw:drawEllipse( -- 996
		Vec2(solHandX, solHandY), -- 996
		6.8, -- 996
		5, -- 996
		Color(206, 168, 136, a245) -- 996
	) -- 996
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 999
	local gunY = cy + 3 + gripLift -- 1000
	uiInkDraw:drawPolygon( -- 1002
		{ -- 1002
			Vec2(gunX - 42, gunY - 8), -- 1003
			Vec2(gunX - 12, gunY - 3), -- 1004
			Vec2(gunX + 16, gunY + 1), -- 1005
			Vec2(gunX + 16, gunY + 6), -- 1006
			Vec2(gunX - 16, gunY + 3), -- 1007
			Vec2(gunX - 40, gunY + 1) -- 1008
		}, -- 1008
		Color(108, 72, 48, a245), -- 1009
		1, -- 1009
		Color(46, 30, 20, a245) -- 1009
	) -- 1009
	uiInkDraw:drawSegment( -- 1011
		Vec2(gunX - 6, gunY + 4), -- 1011
		Vec2(gunX + 56, gunY + 8), -- 1011
		2.8, -- 1011
		Color(152, 148, 138, a245) -- 1011
	) -- 1011
	uiInkDraw:drawSegment( -- 1012
		Vec2(gunX + 14, gunY + 1), -- 1012
		Vec2(gunX + 14, gunY + 8), -- 1012
		2, -- 1012
		Color(198, 166, 112, a245) -- 1012
	) -- 1012
	uiInkDraw:drawSegment( -- 1013
		Vec2(gunX + 36, gunY + 3), -- 1013
		Vec2(gunX + 36, gunY + 9), -- 1013
		1.6, -- 1013
		Color(198, 166, 112, a245) -- 1013
	) -- 1013
	drawReloadPatternGlyph( -- 1014
		uiInkDraw, -- 1014
		gunX + 2, -- 1014
		gunY + 21, -- 1014
		8.5, -- 1014
		self.handoverEffect, -- 1014
		PALETTE.amberCore, -- 1014
		fade -- 1014
	) -- 1014
	fillRadialGlow( -- 1015
		uiGlow, -- 1015
		gunX + 4, -- 1015
		gunY + 4, -- 1015
		48, -- 1015
		22, -- 1015
		toColor(PALETTE.amberCore, 52 * fade), -- 1015
		Color(244, 234, 214, 0), -- 1015
		12 -- 1015
	) -- 1015
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1017
	ctx.texts:put( -- 1020
		"xs", -- 1020
		caption, -- 1020
		cx, -- 1020
		cy - 34, -- 1020
		toColor(PALETTE.amberCore), -- 1020
		0.5, -- 1020
		0.5, -- 1020
		"Center", -- 1020
		1.4, -- 1020
		0.94 * fade, -- 1020
		0.08 -- 1020
	) -- 1020
end -- 949
function ____exports.createCraftBenchPlugin(contract) -- 1024
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1025
end -- 1024
return ____exports -- 1024