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
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 28
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 28
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 29
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 30
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 31
local ____theme = require("Script.watch.fe.theme") -- 33
local PALETTE = ____theme.PALETTE -- 34
local drawBlossomDot = ____theme.drawBlossomDot -- 36
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 37
local drawHairline = ____theme.drawHairline -- 38
local drawSilkRibbon = ____theme.drawSilkRibbon -- 39
local drawSilkVeil = ____theme.drawSilkVeil -- 40
local fillRadialGlow = ____theme.fillRadialGlow -- 41
local fillVGradRect = ____theme.fillVGradRect -- 42
local toColor = ____theme.toColor -- 43
local MATERIAL_NAMES = { -- 46
	wood = "木纹筹", -- 47
	bell = "铃纹筹", -- 48
	wood_tally = "木纹筹", -- 49
	bell_tally = "铃纹筹", -- 50
	scrap = "旧木料", -- 51
	wedge = "木楔", -- 52
	ammo = "备用弹" -- 53
} -- 53
local WOOD_TOP = Color(98, 68, 48, 252) -- 56
local WOOD_BODY = Color(58, 40, 30, 250) -- 57
local WOOD_EDGE = Color(152, 114, 82, 235) -- 58
local WOOD_DARK = Color(30, 21, 17, 248) -- 59
local function materialLabel(key) -- 86
	return MATERIAL_NAMES[key] or key -- 87
end -- 86
local function resolveRuntimeContract(injected) -- 90
	if injected ~= nil then -- 90
		return injected -- 92
	end -- 92
	local g = _G -- 94
	local ____temp_0 -- 95
	if g.package ~= nil then -- 95
		____temp_0 = g.package.loaded -- 95
	else -- 95
		____temp_0 = nil -- 95
	end -- 95
	local loaded = ____temp_0 -- 95
	if loaded == nil then -- 95
		return nil -- 97
	end -- 97
	local feHook = loaded["watch.fe"] -- 99
	if feHook ~= nil and type(feHook) == "table" then -- 99
		local c = feHook.contract -- 101
		if c ~= nil and type(c) == "table" then -- 101
			return c -- 103
		end -- 103
	end -- 103
	return nil -- 106
end -- 90
local function dispatchIntentFallback(p, intent) -- 109
	local rec = p -- 110
	local handler = rec.submitFeIntent -- 111
	if type(handler) == "function" then -- 111
		return handler(p, intent) ~= false -- 113
	end -- 113
	return false -- 115
end -- 109
local function collectMissingMaterials(recipe, inventory) -- 118
	local missing = {} -- 122
	for mat in pairs(recipe.cost) do -- 123
		local need = recipe.cost[mat] -- 124
		local have = inventory[mat] or 0 -- 125
		if have < need then -- 125
			missing[#missing + 1] = mat -- 127
		end -- 127
	end -- 127
	return missing -- 130
end -- 118
local function sortedMaterialKeys(inventory, recipes) -- 133
	local seen = {} -- 137
	local out = {} -- 138
	local prefer = {"wood", "bell", "wood_tally", "bell_tally"} -- 140
	local hasBackendKeys = inventory.wood ~= nil or inventory.bell ~= nil -- 141
	local i = 0 -- 142
	do -- 142
		i = 0 -- 143
		while i < #recipes do -- 143
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 143
				hasBackendKeys = true -- 145
			end -- 145
			i = i + 1 -- 143
		end -- 143
	end -- 143
	local primary = hasBackendKeys and ({"wood", "bell"}) or ({"wood_tally", "bell_tally"}) -- 148
	do -- 148
		i = 0 -- 149
		while i < #primary do -- 149
			seen[primary[i + 1]] = true -- 150
			out[#out + 1] = primary[i + 1] -- 151
			i = i + 1 -- 149
		end -- 149
	end -- 149
	do -- 149
		i = 0 -- 153
		while i < #recipes do -- 153
			local cost = recipes[i + 1].cost -- 154
			for k in pairs(cost) do -- 155
				if not seen[k] then -- 155
					seen[k] = true -- 157
					out[#out + 1] = k -- 158
				end -- 158
			end -- 158
			i = i + 1 -- 153
		end -- 153
	end -- 153
	do -- 153
		i = 0 -- 162
		while i < #prefer do -- 162
			local k = prefer[i + 1] -- 163
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 163
				seen[k] = true -- 165
				out[#out + 1] = k -- 166
			end -- 166
			i = i + 1 -- 162
		end -- 162
	end -- 162
	return out -- 169
end -- 133
____exports.CraftBenchPlugin = __TS__Class() -- 172
local CraftBenchPlugin = ____exports.CraftBenchPlugin -- 172
CraftBenchPlugin.name = "CraftBenchPlugin" -- 172
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 214
	self.id = "fe-02-craft-bench" -- 173
	self.wasActive = false -- 177
	self.selectedIdx = 0 -- 178
	self.animTime = 0 -- 179
	self.openAnimT = 0 -- 180
	self.requestSeq = 0 -- 183
	self.pendingRecipeId = "" -- 184
	self.pendingFirstCraftAtSubmit = true -- 185
	self.prevCraftedMap = {} -- 186
	self.missingFlashT = 0 -- 189
	self.missingList = {} -- 190
	self.handoverRemaining = 0 -- 193
	self.handoverDuration = 1 -- 194
	self.handoverWeaponId = "" -- 195
	self.handoverWeaponName = "" -- 196
	self.handoverEffect = "light" -- 197
	self.prevLeft = false -- 200
	self.prevRight = false -- 201
	self.prevLeftKey = false -- 202
	self.prevRightKey = false -- 203
	self.prevConfirm = false -- 204
	self.prevCancel = false -- 205
	self.pointerActive = false -- 206
	self.cardBoxes = {} -- 209
	self.closeBox = Rect(0, 0, 0, 0) -- 210
	self.injectedContract = contract -- 215
end -- 214
function CraftBenchPlugin.prototype.injectInputForTest(self, sim) -- 219
	self.pendingSimInput = sim -- 220
end -- 219
function CraftBenchPlugin.prototype.getState(self) -- 223
	local inv = {} -- 224
	local craftedIds = {} -- 225
	local equipped = "standard_gun" -- 226
	if self.lastSnapshotBench ~= nil then -- 226
		for k in pairs(self.lastSnapshotBench.inventory) do -- 228
			inv[k] = self.lastSnapshotBench.inventory[k] -- 229
		end -- 229
		local i = 0 -- 231
		do -- 231
			i = 0 -- 232
			while i < #self.lastSnapshotBench.recipes do -- 232
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 232
					craftedIds[#craftedIds + 1] = self.lastSnapshotBench.recipes[i + 1].id -- 234
				end -- 234
				i = i + 1 -- 232
			end -- 232
		end -- 232
		equipped = self.lastSnapshotBench.equippedWeapon -- 237
	end -- 237
	return { -- 239
		active = self.wasActive, -- 240
		selectedIndex = self.selectedIdx, -- 241
		pendingRecipeId = self.pendingRecipeId, -- 242
		missingFlashT = self.missingFlashT, -- 243
		missingMaterials = __TS__ArraySlice(self.missingList), -- 244
		handoverActive = self.handoverRemaining > 0, -- 245
		handoverDuration = self.handoverDuration, -- 246
		handoverRemaining = self.handoverRemaining, -- 247
		handoverWeaponId = self.handoverWeaponId, -- 248
		equippedWeapon = equipped, -- 249
		inventory = inv, -- 250
		craftedIds = craftedIds -- 251
	} -- 251
end -- 223
function CraftBenchPlugin.prototype.onBindPlay(self, _p, view) -- 255
	self.wasActive = view.craftBench.active -- 257
	self.selectedIdx = 0 -- 258
	self.animTime = 0 -- 259
	self.openAnimT = view.craftBench.active and 1 or 0 -- 260
	self.pendingRecipeId = "" -- 261
	self.pendingFirstCraftAtSubmit = not view.craftBench.firstCraftDone -- 262
	self.missingFlashT = 0 -- 263
	self.missingList = {} -- 264
	self.handoverRemaining = 0 -- 265
	self.handoverDuration = 1 -- 266
	self.handoverWeaponId = "" -- 267
	self.handoverWeaponName = "" -- 268
	self.pendingSimInput = nil -- 269
	self:syncCraftedSnapshot(view.craftBench) -- 270
	self.lastSnapshotBench = view.craftBench -- 271
	self:resetInputEdges() -- 272
end -- 255
function CraftBenchPlugin.prototype.syncCraftedSnapshot(self, bench) -- 275
	self.prevCraftedMap = {} -- 276
	local i = 0 -- 277
	do -- 277
		i = 0 -- 278
		while i < #bench.recipes do -- 278
			self.prevCraftedMap[bench.recipes[i + 1].id] = bench.recipes[i + 1].crafted -- 279
			i = i + 1 -- 278
		end -- 278
	end -- 278
end -- 275
function CraftBenchPlugin.prototype.resetInputEdges(self) -- 283
	local ____temp_1 -- 284
	if type(Mouse) ~= "nil" then -- 284
		____temp_1 = Mouse.leftButtonPressed -- 284
	else -- 284
		____temp_1 = false -- 284
	end -- 284
	self.prevLeft = ____temp_1 -- 284
	local ____temp_2 -- 285
	if type(Mouse) ~= "nil" then -- 285
		____temp_2 = Mouse.rightButtonPressed -- 285
	else -- 285
		____temp_2 = false -- 285
	end -- 285
	self.prevRight = ____temp_2 -- 285
	if type(Keyboard) ~= "nil" then -- 285
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 287
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 288
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 289
		self.prevCancel = Keyboard:isKeyPressed("Escape") or Keyboard:isKeyPressed("BackSpace") -- 290
	end -- 290
end -- 283
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 294
	local contract = resolveRuntimeContract(self.injectedContract) -- 295
	if contract ~= nil then -- 295
		return contract:submitIntent(p, intent) -- 297
	end -- 297
	return dispatchIntentFallback(p, intent) -- 299
end -- 294
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 302
	local uiW = ctx.uiW -- 309
	local uiH = ctx.uiH -- 310
	local benchW = math.min(uiW - 88, 692) -- 311
	local benchH = 290 -- 312
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 314
	local benchX = soldierUiX < uiW * 0.52 and math.max(36, uiW - benchW - 44) or 44 -- 315
	local benchY = math.max( -- 318
		46, -- 318
		math.min(uiH * 0.1, 66) -- 318
	) -- 318
	local matW = 196 -- 319
	local cardsAreaX = benchX + matW + 18 -- 321
	local cardsAreaW = benchW - matW - 34 -- 322
	local count = math.max(1, recipeCount) -- 323
	local gap = 14 -- 324
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 325
	local cardH = benchH - 72 -- 326
	local cardY = benchY + 20 -- 327
	self.cardBoxes = {} -- 329
	local i = 0 -- 330
	do -- 330
		i = 0 -- 331
		while i < count do -- 331
			local ____self_cardBoxes_3 = self.cardBoxes -- 331
			____self_cardBoxes_3[#____self_cardBoxes_3 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 332
			i = i + 1 -- 331
		end -- 331
	end -- 331
	self.closeBox = Rect(benchX + benchW - 88, benchY + benchH - 40, 72, 26) -- 334
	return { -- 335
		benchX = benchX, -- 335
		benchY = benchY, -- 335
		benchW = benchW, -- 335
		benchH = benchH, -- 335
		matW = matW -- 335
	} -- 335
end -- 302
function CraftBenchPlugin.prototype.update(self, ctx) -- 338
	local bench = ctx.view.craftBench -- 339
	self.lastSnapshotBench = bench -- 340
	if ctx.paused then -- 340
		self:resetInputEdges() -- 344
		return -- 345
	end -- 345
	local udt = math.max(0, ctx.uiDt) -- 348
	self.animTime = self.animTime + udt -- 349
	if self.missingFlashT > 0 then -- 349
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 352
	end -- 352
	if self.handoverRemaining > 0 then -- 352
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 355
	end -- 355
	self:detectCraftCompletion(ctx, bench) -- 359
	if bench.active and not self.wasActive then -- 359
		self.openAnimT = 0 -- 362
		self.pendingRecipeId = "" -- 363
		self.missingFlashT = 0 -- 364
		self.missingList = {} -- 365
		self.selectedIdx = math.max( -- 366
			0, -- 366
			math.min( -- 366
				math.max(0, #bench.recipes - 1), -- 366
				self.selectedIdx -- 366
			) -- 366
		) -- 366
		self:resetInputEdges() -- 367
	elseif not bench.active and self.wasActive then -- 367
		self.pendingRecipeId = "" -- 369
		self.missingFlashT = 0 -- 370
	end -- 370
	self.wasActive = bench.active -- 372
	if not bench.active then -- 372
		self.pendingSimInput = nil -- 375
		return -- 376
	end -- 376
	self.openAnimT = math.min(1, self.openAnimT + udt / 0.22) -- 379
	self:computeLayout(ctx, #bench.recipes) -- 380
	self:processInputs(ctx, bench) -- 383
end -- 338
function CraftBenchPlugin.prototype.detectCraftCompletion(self, ctx, bench) -- 386
	local newlyCrafted -- 387
	local i = 0 -- 388
	do -- 388
		i = 0 -- 389
		while i < #bench.recipes do -- 389
			local r = bench.recipes[i + 1] -- 390
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 390
				newlyCrafted = r -- 392
			end -- 392
			self.prevCraftedMap[r.id] = r.crafted -- 394
			i = i + 1 -- 389
		end -- 389
	end -- 389
	do -- 389
		i = 0 -- 398
		while i < #ctx.events.rawEvents do -- 398
			local ename = ctx.events.rawEvents[i + 1].name -- 399
			if ename == "benchRejected" then -- 399
				self.pendingRecipeId = "" -- 401
				self.missingFlashT = 0.45 -- 402
			end -- 402
			i = i + 1 -- 398
		end -- 398
	end -- 398
	if newlyCrafted ~= nil then -- 398
		local ____temp_4 -- 407
		if self.pendingRecipeId == newlyCrafted.id then -- 407
			____temp_4 = self.pendingFirstCraftAtSubmit -- 408
		else -- 408
			____temp_4 = bench.justCraftedTimer >= 0.72 -- 409
		end -- 409
		local isFirst = ____temp_4 -- 407
		self.pendingRecipeId = "" -- 410
		self.handoverWeaponId = newlyCrafted.id -- 411
		self.handoverWeaponName = newlyCrafted.name -- 412
		self.handoverEffect = newlyCrafted.enhancedEffect -- 413
		self.handoverDuration = isFirst and 1 or 0.45 -- 414
		self.handoverRemaining = self.handoverDuration -- 415
		local hasBackendDone = false -- 417
		do -- 417
			i = 0 -- 418
			while i < #ctx.events.rawEvents do -- 418
				local ename = ctx.events.rawEvents[i + 1].name -- 419
				if ename == "craftDone" or ename == "benchCraft" then -- 419
					hasBackendDone = true -- 421
					break -- 422
				end -- 422
				i = i + 1 -- 418
			end -- 418
		end -- 418
		if not hasBackendDone then -- 418
			ctx.audio:playOnce( -- 426
				(("fe02:craft_done:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. newlyCrafted.id, -- 427
				"sfx", -- 428
				"assets/audio/combat/craft_done.wav", -- 429
				0.88, -- 430
				"craft:done:" .. newlyCrafted.id, -- 431
				ctx.p.ticks -- 432
			) -- 432
		end -- 432
	end -- 432
end -- 386
function CraftBenchPlugin.prototype.processInputs(self, ctx, bench) -- 438
	local sim = self.pendingSimInput -- 439
	self.pendingSimInput = nil -- 440
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or ctx.input.mx / ctx.uiScale -- 442
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or ctx.input.my / ctx.uiScale -- 443
	local ____temp_11 -- 444
	if (sim and sim.pointerX) ~= nil then -- 444
		____temp_11 = true -- 444
	else -- 444
		____temp_11 = ctx.input.inside -- 444
	end -- 444
	local inside = ____temp_11 -- 444
	local ____temp_14 -- 445
	if (sim and sim.click) ~= nil then -- 445
		____temp_14 = sim.click -- 445
	else -- 445
		____temp_14 = ctx.input.fire.held or type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 445
	end -- 445
	local leftHeld = ____temp_14 -- 445
	local ____temp_17 -- 446
	if (sim and sim.rightClick) ~= nil then -- 446
		____temp_17 = sim.rightClick -- 446
	else -- 446
		____temp_17 = type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 446
	end -- 446
	local rightHeld = ____temp_17 -- 446
	local ____temp_20 -- 448
	if (sim and sim.click) ~= nil then -- 448
		____temp_20 = sim.click -- 448
	else -- 448
		____temp_20 = leftHeld and not self.prevLeft -- 448
	end -- 448
	local click = ____temp_20 -- 448
	local ____temp_23 -- 449
	if (sim and sim.rightClick) ~= nil then -- 449
		____temp_23 = sim.rightClick -- 449
	else -- 449
		____temp_23 = rightHeld and not self.prevRight -- 449
	end -- 449
	local rightClick = ____temp_23 -- 449
	self.prevLeft = leftHeld -- 450
	self.prevRight = rightHeld -- 451
	local move = 0 -- 453
	local confirm = false -- 454
	local cancel = false -- 455
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 455
		move = sim.move or 0 -- 458
		confirm = sim.confirm == true -- 459
		cancel = sim.cancel == true -- 460
	elseif type(Keyboard) ~= "nil" then -- 460
		local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 462
		local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 463
		local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 464
		local cc = Keyboard:isKeyPressed("BackSpace") -- 465
		if lk and not self.prevLeftKey then -- 465
			move = move - 1 -- 466
		end -- 466
		if rk and not self.prevRightKey then -- 466
			move = move + 1 -- 467
		end -- 467
		confirm = cf and not self.prevConfirm -- 468
		cancel = cc and not self.prevCancel -- 469
		self.prevLeftKey = lk -- 470
		self.prevRightKey = rk -- 471
		self.prevConfirm = cf -- 472
		self.prevCancel = cc -- 473
	end -- 473
	local ptr = Vec2(ptrX, ptrY) -- 477
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 478
	if cancel or rightClick or click and hitClose then -- 478
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 480
		return -- 481
	end -- 481
	local count = #bench.recipes -- 484
	if count == 0 then -- 484
		return -- 486
	end -- 486
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(ctx.input.mdx) + math.abs(ctx.input.mdy) >= ctx.uiScale -- 489
	local hitCard = -1 -- 491
	if inside then -- 491
		local i = 0 -- 493
		do -- 493
			i = 0 -- 494
			while i < #self.cardBoxes do -- 494
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 494
					hitCard = i -- 496
					break -- 497
				end -- 497
				i = i + 1 -- 494
			end -- 494
		end -- 494
	end -- 494
	if move ~= 0 then -- 494
		self.pointerActive = false -- 503
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 504
	elseif pointerMoved and hitCard >= 0 then -- 504
		self.pointerActive = true -- 506
		self.selectedIdx = hitCard -- 507
	end -- 507
	local triggerConfirm = confirm or click and hitCard >= 0 -- 510
	if not triggerConfirm then -- 510
		return -- 512
	end -- 512
	if click and hitCard >= 0 then -- 512
		self.selectedIdx = hitCard -- 515
	end -- 515
	if self.handoverRemaining > 0.05 then -- 515
		return -- 520
	end -- 520
	local recipe = bench.recipes[self.selectedIdx + 1] -- 523
	if recipe == nil then -- 523
		return -- 525
	end -- 525
	if recipe.crafted then -- 525
		if bench.equippedWeapon ~= recipe.id then -- 525
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 530
		end -- 530
		return -- 532
	end -- 532
	if self.pendingRecipeId == recipe.id then -- 532
		return -- 537
	end -- 537
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 541
	if #missing > 0 then -- 541
		self.missingList = missing -- 543
		self.missingFlashT = 0.55 -- 544
		ctx.audio:playOnce( -- 545
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 546
			"sfx", -- 547
			"assets/audio/combat/craft_insufficient.wav", -- 548
			0.76, -- 549
			"craft:insufficient:" .. recipe.id, -- 550
			ctx.p.ticks -- 551
		) -- 551
		return -- 553
	end -- 553
	self.missingList = {} -- 556
	self.missingFlashT = 0 -- 557
	self.pendingRecipeId = recipe.id -- 558
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 559
	self.requestSeq = self.requestSeq + 1 -- 560
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 561
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 562
	if not accepted then -- 562
		self.pendingRecipeId = "" -- 568
	end -- 568
end -- 438
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 572
	local bench = ctx.view.craftBench -- 579
	if not bench.active and self.handoverRemaining <= 0.01 then -- 579
		return false -- 581
	end -- 581
	if not bench.active then -- 581
		self:drawHandoverOverlay( -- 586
			uiDraw, -- 586
			uiInkDraw, -- 586
			uiArt, -- 586
			uiGlow, -- 586
			ctx -- 586
		) -- 586
		return false -- 587
	end -- 587
	local appear = math.min(1, self.openAnimT) -- 590
	local layout = self:computeLayout(ctx, #bench.recipes) -- 591
	local bx = layout.benchX -- 592
	local by = layout.benchY -- 593
	local bw = layout.benchW -- 594
	local bh = layout.benchH -- 595
	fillVGradRect( -- 598
		uiDraw, -- 599
		0, -- 600
		0, -- 601
		ctx.uiW, -- 602
		by + bh + 64, -- 603
		Color( -- 604
			12, -- 604
			10, -- 604
			10, -- 604
			math.floor(168 * appear + 0.5) -- 604
		), -- 604
		Color(12, 10, 10, 0) -- 605
	) -- 605
	self:drawWoodenBenchBody( -- 609
		uiDraw, -- 609
		uiInkDraw, -- 609
		uiArt, -- 609
		uiGlow, -- 609
		bx, -- 609
		by, -- 609
		bw, -- 609
		bh, -- 609
		appear -- 609
	) -- 609
	ctx.texts:put( -- 612
		"md", -- 612
		"安全工台 · 改制鸟铳", -- 612
		bx + 54, -- 612
		by + bh - 26, -- 612
		toColor(PALETTE.amberCore), -- 612
		0, -- 612
		0.5, -- 612
		"Left", -- 612
		2, -- 612
		0.96 * appear, -- 612
		0.08 -- 612
	) -- 612
	drawHairline( -- 613
		uiInkDraw, -- 613
		uiArt, -- 613
		"cb_head_line", -- 613
		bx + bw * 0.5, -- 613
		by + bh - 46, -- 613
		bw - 36, -- 613
		PALETTE.amberDim, -- 613
		0.55 * appear, -- 613
		false, -- 613
		2 -- 613
	) -- 613
	local closeHover = ctx.input.inside and self.closeBox:containsPoint(Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale)) -- 615
	uiInkDraw:drawRect( -- 616
		self.closeBox, -- 617
		Color( -- 618
			24, -- 618
			18, -- 618
			16, -- 618
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 618
		), -- 618
		0.9, -- 619
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 620
	) -- 620
	ctx.texts:put( -- 622
		"xs", -- 623
		"收起", -- 624
		self.closeBox.x + self.closeBox.width * 0.5, -- 625
		self.closeBox.y + self.closeBox.height * 0.5, -- 626
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 627
		0.5, -- 628
		0.5, -- 629
		"Center", -- 630
		1.4, -- 631
		0.95 * appear, -- 632
		0.06 -- 633
	) -- 633
	self:drawTableMaterials( -- 637
		uiDraw, -- 637
		uiInkDraw, -- 637
		uiArt, -- 637
		ctx, -- 637
		bench, -- 637
		bx + 18, -- 637
		by + 22, -- 637
		layout.matW - 14, -- 637
		bh - 76, -- 637
		appear -- 637
	) -- 637
	local i = 0 -- 640
	do -- 640
		i = 0 -- 641
		while i < #bench.recipes and i < #self.cardBoxes do -- 641
			self:drawRecipeCard( -- 642
				uiDraw, -- 643
				uiInkDraw, -- 644
				uiArt, -- 645
				uiGlow, -- 646
				ctx, -- 647
				bench, -- 648
				bench.recipes[i + 1], -- 649
				self.cardBoxes[i + 1], -- 650
				i == self.selectedIdx, -- 651
				appear -- 652
			) -- 652
			i = i + 1 -- 641
		end -- 641
	end -- 641
	if self.handoverRemaining > 0.01 then -- 641
		self:drawHandoverOverlay( -- 658
			uiDraw, -- 658
			uiInkDraw, -- 658
			uiArt, -- 658
			uiGlow, -- 658
			ctx -- 658
		) -- 658
	end -- 658
	return true -- 661
end -- 572
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 664
	uiDraw:drawRect( -- 676
		Rect(bx, by, bw, bh), -- 676
		Color( -- 676
			WOOD_BODY.r, -- 676
			WOOD_BODY.g, -- 676
			WOOD_BODY.b, -- 676
			math.floor(244 * appear + 0.5) -- 676
		), -- 676
		1.4, -- 676
		toColor(PALETTE.amberDim, 190 * appear) -- 676
	) -- 676
	uiDraw:drawRect( -- 678
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 678
		Color( -- 678
			WOOD_TOP.r, -- 678
			WOOD_TOP.g, -- 678
			WOOD_TOP.b, -- 678
			math.floor(250 * appear + 0.5) -- 678
		), -- 678
		1, -- 678
		WOOD_EDGE -- 678
	) -- 678
	uiInkDraw:drawSegment( -- 679
		Vec2(bx - 6, by + bh + 3), -- 679
		Vec2(bx + bw + 6, by + bh + 3), -- 679
		1.2, -- 679
		toColor(PALETTE.amberCore, 115 * appear) -- 679
	) -- 679
	uiDraw:drawRect( -- 681
		Rect(bx + 18, by - 26, 22, 26), -- 681
		Color( -- 681
			WOOD_DARK.r, -- 681
			WOOD_DARK.g, -- 681
			WOOD_DARK.b, -- 681
			math.floor(235 * appear + 0.5) -- 681
		) -- 681
	) -- 681
	uiDraw:drawRect( -- 682
		Rect(bx + bw - 40, by - 26, 22, 26), -- 682
		Color( -- 682
			WOOD_DARK.r, -- 682
			WOOD_DARK.g, -- 682
			WOOD_DARK.b, -- 682
			math.floor(235 * appear + 0.5) -- 682
		) -- 682
	) -- 682
	local g = 1 -- 685
	do -- 685
		g = 1 -- 686
		while g <= 4 do -- 686
			local gy = by + (bh - 50) * (g / 5) -- 687
			uiDraw:drawSegment( -- 688
				Vec2(bx + 10, gy), -- 688
				Vec2(bx + bw - 10, gy), -- 688
				0.75, -- 688
				Color( -- 688
					34, -- 688
					23, -- 688
					18, -- 688
					math.floor(110 * appear + 0.5) -- 688
				) -- 688
			) -- 688
			g = g + 1 -- 686
		end -- 686
	end -- 686
	local lx = bx + 28 -- 692
	local ly = by + bh - 24 -- 693
	uiArt:tryPlace( -- 694
		"prop_lantern", -- 694
		"cb_lantern", -- 694
		lx, -- 694
		ly, -- 694
		20, -- 694
		26, -- 694
		{opacity = 0.94 * appear, layer = 4} -- 694
	) -- 694
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 695
	fillRadialGlow( -- 696
		uiGlow, -- 697
		lx + 10, -- 698
		ly - 10, -- 699
		260 * pulse, -- 700
		180 * pulse, -- 701
		Color( -- 702
			238, -- 702
			198, -- 702
			128, -- 702
			math.floor(38 * appear + 0.5) -- 702
		), -- 702
		Color(238, 180, 92, 0), -- 703
		16 -- 704
	) -- 704
end -- 664
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 708
	uiDraw:drawRect( -- 720
		Rect(x, y, w, h), -- 720
		Color( -- 720
			26, -- 720
			20, -- 720
			17, -- 720
			math.floor(188 * appear + 0.5) -- 720
		), -- 720
		0.9, -- 720
		toColor(PALETTE.amberDim, 130 * appear) -- 720
	) -- 720
	drawFiligreeCorners( -- 721
		uiInkDraw, -- 721
		uiArt, -- 721
		"cb_mat_frame", -- 721
		x + 3, -- 721
		y + 3, -- 721
		w - 6, -- 721
		h - 6, -- 721
		PALETTE.amberDim, -- 721
		0.48 * appear, -- 721
		16, -- 721
		false, -- 721
		2 -- 721
	) -- 721
	ctx.texts:put( -- 723
		"xs", -- 723
		"案边持有", -- 723
		x + 12, -- 723
		y + h - 18, -- 723
		toColor(PALETTE.amberCore), -- 723
		0, -- 723
		0.5, -- 723
		"Left", -- 723
		1.4, -- 723
		0.92 * appear, -- 723
		0.06 -- 723
	) -- 723
	uiInkDraw:drawSegment( -- 724
		Vec2(x + 10, y + h - 32), -- 724
		Vec2(x + w - 10, y + h - 32), -- 724
		0.75, -- 724
		toColor(PALETTE.amberDim, 115 * appear) -- 724
	) -- 724
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 726
	local i = 0 -- 727
	do -- 727
		i = 0 -- 728
		while i < #keys and i < 4 do -- 728
			local mat = keys[i + 1] -- 729
			local count = bench.inventory[mat] or 0 -- 730
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 731
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 732
			local rowY = y + h - 62 - i * 48 -- 733
			if isMissing then -- 733
				uiDraw:drawRect( -- 736
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 736
					toColor(PALETTE.rougeSoft, 145 * appear), -- 736
					1, -- 736
					toColor(PALETTE.crimsonCore, 220 * appear) -- 736
				) -- 736
			end -- 736
			local shown = math.max( -- 740
				1, -- 740
				math.min(4, count) -- 740
			) -- 740
			local t = 0 -- 741
			do -- 741
				t = 0 -- 742
				while t < shown do -- 742
					local tx = x + 22 + t * 14 + shake -- 743
					local filled = t < count -- 744
					if mat == "bell_tally" or mat == "bell" then -- 744
						drawReloadPatternGlyph( -- 746
							uiInkDraw, -- 747
							tx, -- 748
							rowY, -- 749
							7.5, -- 750
							"echo", -- 751
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 752
							(filled and 0.96 or 0.38) * appear -- 753
						) -- 753
					else -- 753
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 756
						uiInkDraw:drawRect( -- 757
							Rect(tx - 4, rowY - 10, 8, 20), -- 758
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 759
							1, -- 760
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 761
						) -- 761
						if filled then -- 761
							uiInkDraw:drawSegment( -- 764
								Vec2(tx - 2, rowY + 3), -- 764
								Vec2(tx + 2, rowY + 3), -- 764
								0.9, -- 764
								toColor(PALETTE.xuanInk, 185 * appear) -- 764
							) -- 764
							uiInkDraw:drawSegment( -- 765
								Vec2(tx - 2, rowY - 3), -- 765
								Vec2(tx + 2, rowY - 3), -- 765
								0.9, -- 765
								toColor(PALETTE.xuanInk, 185 * appear) -- 765
							) -- 765
						end -- 765
					end -- 765
					t = t + 1 -- 742
				end -- 742
			end -- 742
			ctx.texts:put( -- 770
				"xs", -- 771
				materialLabel(mat), -- 772
				x + 86 + shake, -- 773
				rowY + 5, -- 774
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 775
				0, -- 776
				0.5, -- 777
				"Left", -- 778
				0.8, -- 779
				0.95 * appear, -- 780
				0.06 -- 781
			) -- 781
			ctx.texts:put( -- 783
				"xs", -- 784
				"存 " .. tostring(count), -- 785
				x + 86 + shake, -- 786
				rowY - 11, -- 787
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 788
				0, -- 789
				0.5, -- 790
				"Left", -- 791
				0.8, -- 792
				0.88 * appear, -- 793
				0.06 -- 794
			) -- 794
			i = i + 1 -- 728
		end -- 728
	end -- 728
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 799
	uiInkDraw:drawSegment( -- 800
		Vec2(x + 10, y + 32), -- 800
		Vec2(x + w - 10, y + 32), -- 800
		0.75, -- 800
		toColor(PALETTE.amberDim, 105 * appear) -- 800
	) -- 800
	ctx.texts:put( -- 801
		"xs", -- 801
		"现佩：" .. eqName, -- 801
		x + 12, -- 801
		y + 16, -- 801
		toColor(PALETTE.textMid), -- 801
		0, -- 801
		0.5, -- 801
		"Left", -- 801
		0.8, -- 801
		0.9 * appear, -- 801
		0.06 -- 801
	) -- 801
end -- 708
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 804
	local i = 0 -- 805
	do -- 805
		i = 0 -- 806
		while i < #bench.recipes do -- 806
			if bench.recipes[i + 1].id == weaponId then -- 806
				return bench.recipes[i + 1].name -- 808
			end -- 808
			i = i + 1 -- 806
		end -- 806
	end -- 806
	return "旧制鸟铳" -- 811
end -- 804
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 814
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 826
	local canCraft = not recipe.crafted and #missing == 0 -- 827
	local equipped = bench.equippedWeapon == recipe.id -- 828
	local isPending = self.pendingRecipeId == recipe.id -- 829
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 830
	if not uiArt:tryPlace( -- 830
		"ink_song_paper", -- 833
		"cb_card_" .. recipe.id, -- 833
		box.x + box.width * 0.5, -- 833
		box.y + box.height * 0.5, -- 833
		box.width, -- 833
		box.height, -- 833
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 833
	) then -- 833
		uiDraw:drawRect( -- 834
			box, -- 834
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 834
		) -- 834
	end -- 834
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 837
	drawFiligreeCorners( -- 840
		uiInkDraw, -- 840
		uiArt, -- 840
		"cb_cf_" .. recipe.id, -- 840
		box.x + 5, -- 840
		box.y + 5, -- 840
		box.width - 10, -- 840
		box.height - 10, -- 840
		borderCol, -- 840
		(selected and 0.88 or 0.46) * appear, -- 840
		18, -- 840
		true, -- 840
		2 -- 840
	) -- 840
	if selected then -- 840
		drawSilkRibbon( -- 843
			uiDraw, -- 843
			uiArt, -- 843
			"cb_sel_rib_" .. recipe.id, -- 843
			box.x + box.width * 0.5, -- 843
			box.y + box.height - 26, -- 843
			box.width - 14, -- 843
			30, -- 843
			PALETTE.amberDim, -- 843
			0.24 * appear, -- 843
			2 -- 843
		) -- 843
	end -- 843
	local topY = box.y + box.height - 26 -- 847
	drawBlossomDot( -- 848
		uiInkDraw, -- 848
		uiArt, -- 848
		"cb_dot_" .. recipe.id, -- 848
		box.x + 18, -- 848
		topY, -- 848
		selected and 11 or 7, -- 848
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 848
		0.92 * appear, -- 848
		3 -- 848
	) -- 848
	ctx.texts:put( -- 849
		"md", -- 849
		recipe.name, -- 849
		box.x + 30, -- 849
		topY, -- 849
		toColor(PALETTE.xuanInk), -- 849
		0, -- 849
		0.5, -- 849
		"Left", -- 849
		1.6, -- 849
		0.98 * appear, -- 849
		0 -- 849
	) -- 849
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 851
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 852
	ctx.texts:put( -- 853
		"xs", -- 853
		badge, -- 853
		box.x + box.width - 14, -- 853
		topY, -- 853
		toColor(badgeCol), -- 853
		1, -- 853
		0.5, -- 853
		"Right", -- 853
		1, -- 853
		0.94 * appear, -- 853
		0 -- 853
	) -- 853
	local miniCx = box.x + 46 -- 856
	local miniCy = box.y + box.height - 96 -- 857
	self:drawMiniReloadPreview( -- 858
		uiInkDraw, -- 858
		uiGlow, -- 858
		miniCx, -- 858
		miniCy, -- 858
		recipe.enhancedEffect, -- 858
		appear -- 858
	) -- 858
	local infoX = box.x + 90 -- 861
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 862
	ctx.texts:put( -- 863
		"xs", -- 863
		effTitle, -- 863
		infoX, -- 863
		box.y + box.height - 64, -- 863
		toColor(PALETTE.rouge), -- 863
		0, -- 863
		0.5, -- 863
		"Left", -- 863
		0.8, -- 863
		0.95 * appear, -- 863
		0 -- 863
	) -- 863
	local row = 0 -- 865
	for mat in pairs(recipe.cost) do -- 866
		local need = recipe.cost[mat] -- 867
		local have = bench.inventory[mat] or 0 -- 868
		local lack = not recipe.crafted and have < need -- 869
		local ry = box.y + box.height - 90 - row * 22 -- 870
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 871
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 872
		ctx.texts:put( -- 873
			"xs", -- 873
			text, -- 873
			infoX, -- 873
			ry, -- 873
			toColor(col), -- 873
			0, -- 873
			0.5, -- 873
			"Left", -- 873
			0.6, -- 873
			0.94 * appear, -- 873
			0 -- 873
		) -- 873
		row = row + 1 -- 874
	end -- 874
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 878
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 879
	local btnBg = equipped and Color( -- 882
		168, -- 883
		46, -- 883
		44, -- 883
		math.floor(32 * appear + 0.5) -- 883
	) or (selected and (canCraft or recipe.crafted) and Color( -- 883
		32, -- 885
		30, -- 885
		32, -- 885
		math.floor(218 * appear + 0.5) -- 885
	) or Color( -- 885
		32, -- 886
		30, -- 886
		32, -- 886
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 886
	)) -- 886
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 887
	uiInkDraw:drawRect( -- 890
		btnRect, -- 890
		btnBg, -- 890
		0.9, -- 890
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 890
	) -- 890
	ctx.texts:put( -- 891
		"sm", -- 892
		btnLabel, -- 893
		btnRect.x + btnRect.width * 0.5, -- 894
		btnRect.y + btnRect.height * 0.5, -- 895
		toColor(btnTextCol), -- 896
		0.5, -- 897
		0.5, -- 898
		"Center", -- 899
		1.6, -- 900
		0.96 * appear, -- 901
		0 -- 902
	) -- 902
end -- 814
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 907
	local step = 20 -- 915
	local samplePath = effect == "light" and ({ -- 916
		0, -- 916
		1, -- 916
		2, -- 916
		5, -- 916
		8 -- 916
	}) or (effect == "echo" and ({ -- 916
		0, -- 916
		1, -- 916
		4, -- 916
		5, -- 916
		8 -- 916
	}) or ({ -- 916
		0, -- 916
		3, -- 916
		6, -- 916
		7, -- 916
		8 -- 916
	})) -- 916
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 917
	uiInkDraw:drawRect( -- 920
		Rect(cx - 32, cy - 32, 64, 64), -- 920
		Color( -- 920
			224, -- 920
			218, -- 920
			206, -- 920
			math.floor(145 * appear + 0.5) -- 920
		), -- 920
		0.8, -- 920
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 920
	) -- 920
	local i = 0 -- 921
	do -- 921
		i = 0 -- 922
		while i < #RELOAD_GRID do -- 922
			local g = RELOAD_GRID[i + 1] -- 923
			local nx = cx + (g.col - 1) * step -- 924
			local ny = cy + (g.row - 1) * step -- 925
			uiInkDraw:drawDot( -- 926
				Vec2(nx, ny), -- 926
				1.8, -- 926
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 926
			) -- 926
			i = i + 1 -- 922
		end -- 922
	end -- 922
	do -- 922
		i = 0 -- 930
		while i < #samplePath - 1 do -- 930
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 931
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 932
			uiInkDraw:drawSegment( -- 933
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 934
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 935
				1.8, -- 936
				toColor(accent, 220 * appear) -- 937
			) -- 937
			i = i + 1 -- 930
		end -- 930
	end -- 930
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 942
	local kx = cx + (keyNode.col - 1) * step -- 943
	local ky = cy + (keyNode.row - 1) * step -- 944
	drawReloadPatternGlyph( -- 945
		uiInkDraw, -- 945
		kx, -- 945
		ky, -- 945
		7.5, -- 945
		effect, -- 945
		accent, -- 945
		appear -- 945
	) -- 945
	fillRadialGlow( -- 946
		uiGlow, -- 946
		kx, -- 946
		ky, -- 946
		14, -- 946
		14, -- 946
		toColor(PALETTE.amberCore, 45 * appear), -- 946
		Color(244, 234, 214, 0), -- 946
		10 -- 946
	) -- 946
end -- 907
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 950
	local prog = math.max( -- 957
		0, -- 957
		math.min( -- 957
			1, -- 957
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 957
		) -- 957
	) -- 957
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 958
	local cx = ctx.uiW * 0.5 -- 959
	local cy = ctx.uiH * 0.68 -- 960
	local w = 440 -- 961
	local h = 112 -- 962
	drawSilkVeil( -- 964
		uiDraw, -- 964
		uiArt, -- 964
		"cb_handover_veil", -- 964
		cx, -- 964
		cy, -- 964
		w + 80, -- 964
		h + 28, -- 964
		PALETTE.inkWash, -- 964
		0.84 * fade, -- 964
		0 -- 964
	) -- 964
	drawHairline( -- 965
		uiInkDraw, -- 965
		uiArt, -- 965
		"cb_handover_top", -- 965
		cx, -- 965
		cy + h * 0.48, -- 965
		w - 30, -- 965
		PALETTE.amber, -- 965
		0.58 * fade, -- 965
		true, -- 965
		2 -- 965
	) -- 965
	local passK = math.min(1, prog / 0.38) -- 968
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 969
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 970
	local a245 = math.floor(245 * fade + 0.5) -- 971
	local a235 = math.floor(235 * fade + 0.5) -- 972
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 975
	local childHandY = cy - 4 + gripLift * 0.2 -- 976
	uiInkDraw:drawPolygon( -- 977
		{ -- 977
			Vec2(cx - 148, cy - 22), -- 978
			Vec2(cx - 146, cy - 8), -- 979
			Vec2(childHandX - 10, childHandY + 4), -- 980
			Vec2(childHandX - 10, childHandY - 6) -- 981
		}, -- 981
		Color(164, 78, 54, a235), -- 982
		1, -- 982
		Color(52, 28, 22, a235) -- 982
	) -- 982
	uiInkDraw:drawSegment( -- 983
		Vec2(childHandX - 11, childHandY + 4), -- 983
		Vec2(childHandX - 11, childHandY - 6), -- 983
		2, -- 983
		Color(204, 174, 122, a245) -- 983
	) -- 983
	uiInkDraw:drawEllipse( -- 984
		Vec2(childHandX, childHandY - 1), -- 984
		6.2, -- 984
		4.4, -- 984
		Color(238, 212, 182, a245) -- 984
	) -- 984
	local solHandX = cx + 82 - math.min( -- 987
		1, -- 987
		math.max(0, (prog - 0.18) / 0.28) -- 987
	) * 42 -- 987
	local solHandY = cy - 4 + gripLift -- 988
	uiInkDraw:drawPolygon( -- 989
		{ -- 989
			Vec2(cx + 154, cy - 18), -- 990
			Vec2(cx + 154, cy - 1), -- 991
			Vec2(solHandX + 12, solHandY + 6), -- 992
			Vec2(solHandX + 12, solHandY - 7) -- 993
		}, -- 993
		toColor(CUFF_PALETTE.indigoBase, a245), -- 994
		1, -- 994
		toColor(CUFF_PALETTE.indigoShadow, a245) -- 994
	) -- 994
	local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 996
	uiInkDraw:drawSegment( -- 997
		Vec2(solHandX + 16, solHandY - 5), -- 997
		Vec2(solHandX + 19, solHandY + 4), -- 997
		1.5, -- 997
		mendCol -- 997
	) -- 997
	uiInkDraw:drawSegment( -- 998
		Vec2(solHandX + 21, solHandY - 5), -- 998
		Vec2(solHandX + 24, solHandY + 4), -- 998
		1.5, -- 998
		mendCol -- 998
	) -- 998
	uiInkDraw:drawSegment( -- 999
		Vec2(solHandX + 26, solHandY - 5), -- 999
		Vec2(solHandX + 29, solHandY + 4), -- 999
		1.5, -- 999
		mendCol -- 999
	) -- 999
	uiInkDraw:drawEllipse( -- 1000
		Vec2(solHandX, solHandY), -- 1000
		6.8, -- 1000
		5, -- 1000
		toColor(CUFF_PALETTE.skinBase, a245) -- 1000
	) -- 1000
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1003
	local gunY = cy + 3 + gripLift -- 1004
	uiInkDraw:drawPolygon( -- 1006
		{ -- 1006
			Vec2(gunX - 42, gunY - 8), -- 1007
			Vec2(gunX - 12, gunY - 3), -- 1008
			Vec2(gunX + 16, gunY + 1), -- 1009
			Vec2(gunX + 16, gunY + 6), -- 1010
			Vec2(gunX - 16, gunY + 3), -- 1011
			Vec2(gunX - 40, gunY + 1) -- 1012
		}, -- 1012
		Color(108, 72, 48, a245), -- 1013
		1, -- 1013
		Color(46, 30, 20, a245) -- 1013
	) -- 1013
	uiInkDraw:drawSegment( -- 1015
		Vec2(gunX - 6, gunY + 4), -- 1015
		Vec2(gunX + 56, gunY + 8), -- 1015
		2.8, -- 1015
		Color(152, 148, 138, a245) -- 1015
	) -- 1015
	uiInkDraw:drawSegment( -- 1016
		Vec2(gunX + 14, gunY + 1), -- 1016
		Vec2(gunX + 14, gunY + 8), -- 1016
		2, -- 1016
		Color(198, 166, 112, a245) -- 1016
	) -- 1016
	uiInkDraw:drawSegment( -- 1017
		Vec2(gunX + 36, gunY + 3), -- 1017
		Vec2(gunX + 36, gunY + 9), -- 1017
		1.6, -- 1017
		Color(198, 166, 112, a245) -- 1017
	) -- 1017
	drawReloadPatternGlyph( -- 1018
		uiInkDraw, -- 1018
		gunX + 2, -- 1018
		gunY + 21, -- 1018
		8.5, -- 1018
		self.handoverEffect, -- 1018
		PALETTE.amberCore, -- 1018
		fade -- 1018
	) -- 1018
	fillRadialGlow( -- 1019
		uiGlow, -- 1019
		gunX + 4, -- 1019
		gunY + 4, -- 1019
		48, -- 1019
		22, -- 1019
		toColor(PALETTE.amberCore, 52 * fade), -- 1019
		Color(244, 234, 214, 0), -- 1019
		12 -- 1019
	) -- 1019
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1021
	ctx.texts:put( -- 1024
		"xs", -- 1024
		caption, -- 1024
		cx, -- 1024
		cy - 34, -- 1024
		toColor(PALETTE.amberCore), -- 1024
		0.5, -- 1024
		0.5, -- 1024
		"Center", -- 1024
		1.4, -- 1024
		0.94 * fade, -- 1024
		0.08 -- 1024
	) -- 1024
end -- 950
function ____exports.createCraftBenchPlugin(contract) -- 1028
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1029
end -- 1028
return ____exports -- 1028