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
local ____platform = require("Script.watch.platform") -- 19
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 19
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 21
local keyTagFor = ____control_prompts.keyTagFor -- 21
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 30
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 31
local drawSlideFrameChrome = ____slideshow.drawSlideFrameChrome -- 32
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 34
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 35
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 36
local ____theme = require("Script.watch.fe.theme") -- 38
local PALETTE = ____theme.PALETTE -- 39
local drawBlossomDot = ____theme.drawBlossomDot -- 41
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 42
local drawHairline = ____theme.drawHairline -- 43
local drawSilkRibbon = ____theme.drawSilkRibbon -- 44
local drawSilkVeil = ____theme.drawSilkVeil -- 45
local fillRadialGlow = ____theme.fillRadialGlow -- 46
local fillVGradRect = ____theme.fillVGradRect -- 47
local toColor = ____theme.toColor -- 48
local MATERIAL_NAMES = { -- 51
	wood = "木纹筹", -- 52
	bell = "铃纹筹", -- 53
	wood_tally = "木纹筹", -- 54
	bell_tally = "铃纹筹", -- 55
	scrap = "旧木料", -- 56
	wedge = "木楔", -- 57
	ammo = "备用弹" -- 58
} -- 58
local WOOD_TOP = Color(98, 68, 48, 252) -- 61
local WOOD_BODY = Color(58, 40, 30, 250) -- 62
local WOOD_EDGE = Color(152, 114, 82, 235) -- 63
local WOOD_DARK = Color(30, 21, 17, 248) -- 64
local function materialLabel(key) -- 91
	return MATERIAL_NAMES[key] or key -- 92
end -- 91
local function resolveRuntimeContract(injected) -- 95
	if injected ~= nil then -- 95
		return injected -- 97
	end -- 97
	local g = _G -- 99
	local ____temp_0 -- 100
	if g.package ~= nil then -- 100
		____temp_0 = g.package.loaded -- 100
	else -- 100
		____temp_0 = nil -- 100
	end -- 100
	local loaded = ____temp_0 -- 100
	if loaded == nil then -- 100
		return nil -- 102
	end -- 102
	local feHook = loaded["watch.fe"] -- 104
	if feHook ~= nil and type(feHook) == "table" then -- 104
		local c = feHook.contract -- 106
		if c ~= nil and type(c) == "table" then -- 106
			return c -- 108
		end -- 108
	end -- 108
	return nil -- 111
end -- 95
local function dispatchIntentFallback(p, intent) -- 114
	local rec = p -- 115
	local handler = rec.submitFeIntent -- 116
	if type(handler) == "function" then -- 116
		return handler(p, intent) ~= false -- 118
	end -- 118
	return false -- 120
end -- 114
local function collectMissingMaterials(recipe, inventory) -- 123
	local missing = {} -- 127
	for mat in pairs(recipe.cost) do -- 128
		local need = recipe.cost[mat] -- 129
		local have = inventory[mat] or 0 -- 130
		if have < need then -- 130
			missing[#missing + 1] = mat -- 132
		end -- 132
	end -- 132
	return missing -- 135
end -- 123
local function sortedMaterialKeys(inventory, recipes) -- 138
	local seen = {} -- 142
	local out = {} -- 143
	local prefer = {"wood", "bell", "wood_tally", "bell_tally"} -- 145
	local hasBackendKeys = inventory.wood ~= nil or inventory.bell ~= nil -- 146
	local i = 0 -- 147
	do -- 147
		i = 0 -- 148
		while i < #recipes do -- 148
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 148
				hasBackendKeys = true -- 150
			end -- 150
			i = i + 1 -- 148
		end -- 148
	end -- 148
	local primary = hasBackendKeys and ({"wood", "bell"}) or ({"wood_tally", "bell_tally"}) -- 153
	do -- 153
		i = 0 -- 154
		while i < #primary do -- 154
			seen[primary[i + 1]] = true -- 155
			out[#out + 1] = primary[i + 1] -- 156
			i = i + 1 -- 154
		end -- 154
	end -- 154
	do -- 154
		i = 0 -- 158
		while i < #recipes do -- 158
			local cost = recipes[i + 1].cost -- 159
			for k in pairs(cost) do -- 160
				if not seen[k] then -- 160
					seen[k] = true -- 162
					out[#out + 1] = k -- 163
				end -- 163
			end -- 163
			i = i + 1 -- 158
		end -- 158
	end -- 158
	do -- 158
		i = 0 -- 167
		while i < #prefer do -- 167
			local k = prefer[i + 1] -- 168
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 168
				seen[k] = true -- 170
				out[#out + 1] = k -- 171
			end -- 171
			i = i + 1 -- 167
		end -- 167
	end -- 167
	return out -- 174
end -- 138
____exports.CraftBenchPlugin = __TS__Class() -- 177
local CraftBenchPlugin = ____exports.CraftBenchPlugin -- 177
CraftBenchPlugin.name = "CraftBenchPlugin" -- 177
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 219
	self.id = "fe-02-craft-bench" -- 178
	self.wasActive = false -- 182
	self.selectedIdx = 0 -- 183
	self.animTime = 0 -- 184
	self.openAnimT = 0 -- 185
	self.requestSeq = 0 -- 188
	self.pendingRecipeId = "" -- 189
	self.pendingFirstCraftAtSubmit = true -- 190
	self.prevCraftedMap = {} -- 191
	self.missingFlashT = 0 -- 194
	self.missingList = {} -- 195
	self.handoverRemaining = 0 -- 198
	self.handoverDuration = 1 -- 199
	self.handoverWeaponId = "" -- 200
	self.handoverWeaponName = "" -- 201
	self.handoverEffect = "light" -- 202
	self.prevLeft = false -- 205
	self.prevRight = false -- 206
	self.prevLeftKey = false -- 207
	self.prevRightKey = false -- 208
	self.prevConfirm = false -- 209
	self.prevCancel = false -- 210
	self.pointerActive = false -- 211
	self.cardBoxes = {} -- 214
	self.closeBox = Rect(0, 0, 0, 0) -- 215
	self.injectedContract = contract -- 220
end -- 219
function CraftBenchPlugin.prototype.injectInputForTest(self, sim) -- 224
	self.pendingSimInput = sim -- 225
end -- 224
function CraftBenchPlugin.prototype.getState(self) -- 228
	local inv = {} -- 229
	local craftedIds = {} -- 230
	local equipped = "standard_gun" -- 231
	if self.lastSnapshotBench ~= nil then -- 231
		for k in pairs(self.lastSnapshotBench.inventory) do -- 233
			inv[k] = self.lastSnapshotBench.inventory[k] -- 234
		end -- 234
		local i = 0 -- 236
		do -- 236
			i = 0 -- 237
			while i < #self.lastSnapshotBench.recipes do -- 237
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 237
					craftedIds[#craftedIds + 1] = self.lastSnapshotBench.recipes[i + 1].id -- 239
				end -- 239
				i = i + 1 -- 237
			end -- 237
		end -- 237
		equipped = self.lastSnapshotBench.equippedWeapon -- 242
	end -- 242
	return { -- 244
		active = self.wasActive, -- 245
		selectedIndex = self.selectedIdx, -- 246
		pendingRecipeId = self.pendingRecipeId, -- 247
		missingFlashT = self.missingFlashT, -- 248
		missingMaterials = __TS__ArraySlice(self.missingList), -- 249
		handoverActive = self.handoverRemaining > 0, -- 250
		handoverDuration = self.handoverDuration, -- 251
		handoverRemaining = self.handoverRemaining, -- 252
		handoverWeaponId = self.handoverWeaponId, -- 253
		equippedWeapon = equipped, -- 254
		inventory = inv, -- 255
		craftedIds = craftedIds -- 256
	} -- 256
end -- 228
function CraftBenchPlugin.prototype.onBindPlay(self, _p, view) -- 260
	self.wasActive = view.craftBench.active -- 262
	self.selectedIdx = 0 -- 263
	self.animTime = 0 -- 264
	self.openAnimT = view.craftBench.active and 1 or 0 -- 265
	self.pendingRecipeId = "" -- 266
	self.pendingFirstCraftAtSubmit = not view.craftBench.firstCraftDone -- 267
	self.missingFlashT = 0 -- 268
	self.missingList = {} -- 269
	self.handoverRemaining = 0 -- 270
	self.handoverDuration = 1 -- 271
	self.handoverWeaponId = "" -- 272
	self.handoverWeaponName = "" -- 273
	self.pendingSimInput = nil -- 274
	self:syncCraftedSnapshot(view.craftBench) -- 275
	self.lastSnapshotBench = view.craftBench -- 276
	self:resetInputEdges() -- 277
end -- 260
function CraftBenchPlugin.prototype.syncCraftedSnapshot(self, bench) -- 280
	self.prevCraftedMap = {} -- 281
	local i = 0 -- 282
	do -- 282
		i = 0 -- 283
		while i < #bench.recipes do -- 283
			self.prevCraftedMap[bench.recipes[i + 1].id] = bench.recipes[i + 1].crafted -- 284
			i = i + 1 -- 283
		end -- 283
	end -- 283
end -- 280
function CraftBenchPlugin.prototype.resetInputEdges(self, touchMode) -- 288
	if touchMode == nil then -- 288
		touchMode = false -- 288
	end -- 288
	local ____temp_1 -- 289
	if not touchMode and type(Mouse) ~= "nil" then -- 289
		____temp_1 = Mouse.leftButtonPressed -- 289
	else -- 289
		____temp_1 = false -- 289
	end -- 289
	self.prevLeft = ____temp_1 -- 289
	local ____temp_2 -- 290
	if not touchMode and type(Mouse) ~= "nil" then -- 290
		____temp_2 = Mouse.rightButtonPressed -- 290
	else -- 290
		____temp_2 = false -- 290
	end -- 290
	self.prevRight = ____temp_2 -- 290
	if type(Keyboard) ~= "nil" then -- 290
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 292
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 293
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 294
		self.prevCancel = Keyboard:isKeyPressed("Escape") or Keyboard:isKeyPressed("BackSpace") -- 295
	end -- 295
end -- 288
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 299
	local contract = resolveRuntimeContract(self.injectedContract) -- 300
	if contract ~= nil then -- 300
		return contract:submitIntent(p, intent) -- 302
	end -- 302
	return dispatchIntentFallback(p, intent) -- 304
end -- 299
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 307
	local uiW = ctx.uiW -- 314
	local uiH = ctx.uiH -- 315
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 316
	local touchMode = ctx.input:isTouchMode() -- 317
	local count = math.max(1, recipeCount) -- 318
	local wantW = count >= 3 and 840 or 692 -- 319
	local benchW = math.min(uiW - 44 - safe.left - safe.right, wantW) -- 320
	local benchH = 290 -- 321
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 323
	local minX = 24 + safe.left -- 324
	local maxX = math.max(minX, uiW - benchW - 24 - safe.right) -- 325
	local benchX = count >= 3 and math.max(minX, (uiW - benchW) * 0.5) or (soldierUiX < uiW * 0.52 and maxX or minX) -- 326
	local benchY = math.max( -- 329
		46 + safe.bottom, -- 329
		math.min(uiH * 0.1 + safe.bottom, 66 + safe.bottom) -- 329
	) -- 329
	local matW = count >= 3 and 168 or 196 -- 330
	local cardsAreaX = benchX + matW + 16 -- 332
	local cardsAreaW = benchW - matW - 30 -- 333
	local gap = count >= 3 and 10 or 14 -- 334
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 335
	local cardH = benchH - 72 -- 336
	local cardY = benchY + 20 -- 337
	self.cardBoxes = {} -- 339
	local i = 0 -- 340
	do -- 340
		i = 0 -- 341
		while i < count do -- 341
			local ____self_cardBoxes_3 = self.cardBoxes -- 341
			____self_cardBoxes_3[#____self_cardBoxes_3 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 342
			i = i + 1 -- 341
		end -- 341
	end -- 341
	local closeW = touchMode and 88 or 76 -- 344
	local closeH = touchMode and 32 or 26 -- 345
	self.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH) -- 346
	return { -- 347
		benchX = benchX, -- 347
		benchY = benchY, -- 347
		benchW = benchW, -- 347
		benchH = benchH, -- 347
		matW = matW -- 347
	} -- 347
end -- 307
function CraftBenchPlugin.prototype.update(self, ctx) -- 350
	local bench = ctx.view.craftBench -- 351
	self.lastSnapshotBench = bench -- 352
	if ctx.paused then -- 352
		self:resetInputEdges(ctx.input:isTouchMode()) -- 356
		return -- 357
	end -- 357
	local udt = math.max(0, ctx.uiDt) -- 360
	self.animTime = self.animTime + udt -- 361
	if self.missingFlashT > 0 then -- 361
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 364
	end -- 364
	if self.handoverRemaining > 0 then -- 364
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 367
	end -- 367
	self:detectCraftCompletion(ctx, bench) -- 371
	if bench.active and not self.wasActive then -- 371
		self.openAnimT = 0 -- 374
		self.pendingRecipeId = "" -- 375
		self.missingFlashT = 0 -- 376
		self.missingList = {} -- 377
		self.selectedIdx = math.max( -- 378
			0, -- 378
			math.min( -- 378
				math.max(0, #bench.recipes - 1), -- 378
				self.selectedIdx -- 378
			) -- 378
		) -- 378
		self:resetInputEdges(ctx.input:isTouchMode()) -- 379
	elseif not bench.active and self.wasActive then -- 379
		self.pendingRecipeId = "" -- 381
		self.missingFlashT = 0 -- 382
	end -- 382
	self.wasActive = bench.active -- 384
	if not bench.active then -- 384
		self.pendingSimInput = nil -- 387
		return -- 388
	end -- 388
	self.openAnimT = math.min(1, self.openAnimT + udt / 0.22) -- 391
	self:computeLayout(ctx, #bench.recipes) -- 392
	self:processInputs(ctx, bench) -- 395
end -- 350
function CraftBenchPlugin.prototype.detectCraftCompletion(self, ctx, bench) -- 398
	local newlyCrafted -- 399
	local i = 0 -- 400
	do -- 400
		i = 0 -- 401
		while i < #bench.recipes do -- 401
			local r = bench.recipes[i + 1] -- 402
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 402
				newlyCrafted = r -- 404
			end -- 404
			self.prevCraftedMap[r.id] = r.crafted -- 406
			i = i + 1 -- 401
		end -- 401
	end -- 401
	do -- 401
		i = 0 -- 410
		while i < #ctx.events.rawEvents do -- 410
			local ename = ctx.events.rawEvents[i + 1].name -- 411
			if ename == "benchRejected" then -- 411
				self.pendingRecipeId = "" -- 413
				self.missingFlashT = 0.45 -- 414
			end -- 414
			i = i + 1 -- 410
		end -- 410
	end -- 410
	if newlyCrafted ~= nil then -- 410
		local ____temp_4 -- 419
		if self.pendingRecipeId == newlyCrafted.id then -- 419
			____temp_4 = self.pendingFirstCraftAtSubmit -- 420
		else -- 420
			____temp_4 = bench.justCraftedTimer >= 0.72 -- 421
		end -- 421
		local isFirst = ____temp_4 -- 419
		self.pendingRecipeId = "" -- 422
		self.handoverWeaponId = newlyCrafted.id -- 423
		self.handoverWeaponName = newlyCrafted.name -- 424
		self.handoverEffect = newlyCrafted.enhancedEffect -- 425
		self.handoverDuration = isFirst and 1 or 0.45 -- 426
		self.handoverRemaining = self.handoverDuration -- 427
		local hasBackendDone = false -- 429
		do -- 429
			i = 0 -- 430
			while i < #ctx.events.rawEvents do -- 430
				local ename = ctx.events.rawEvents[i + 1].name -- 431
				if ename == "craftDone" or ename == "benchCraft" then -- 431
					hasBackendDone = true -- 433
					break -- 434
				end -- 434
				i = i + 1 -- 430
			end -- 430
		end -- 430
		if not hasBackendDone then -- 430
			ctx.audio:playOnce( -- 438
				(("fe02:craft_done:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. newlyCrafted.id, -- 439
				"sfx", -- 440
				"assets/audio/combat/craft_done.wav", -- 441
				0.88, -- 442
				"craft:done:" .. newlyCrafted.id, -- 443
				ctx.p.ticks -- 444
			) -- 444
		end -- 444
	end -- 444
end -- 398
function CraftBenchPlugin.prototype.processInputs(self, ctx, bench) -- 450
	local sim = self.pendingSimInput -- 451
	self.pendingSimInput = nil -- 452
	local touchMode = ctx.input:isTouchMode() -- 454
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 455
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 457
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 460
	local ____temp_14 -- 463
	if (sim and sim.pointerX) ~= nil then -- 463
		____temp_14 = true -- 464
	else -- 464
		local ____useUiPtr_13 -- 465
		if useUiPtr then -- 465
			____useUiPtr_13 = ctx.input.uiInside -- 465
		else -- 465
			____useUiPtr_13 = ctx.input.inside -- 465
		end -- 465
		____temp_14 = ____useUiPtr_13 -- 465
	end -- 465
	local inside = ____temp_14 -- 463
	local kbmMode = ctx.input.inputMode == "kbm" -- 466
	local ____temp_17 -- 467
	if (sim and sim.click) ~= nil then -- 467
		____temp_17 = sim.click -- 468
	else -- 468
		____temp_17 = ctx.input.uiHeld or ctx.input.fire.held or kbmMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 469
	end -- 469
	local leftHeld = ____temp_17 -- 467
	local ____temp_20 -- 470
	if (sim and sim.rightClick) ~= nil then -- 470
		____temp_20 = sim.rightClick -- 471
	else -- 471
		____temp_20 = ctx.input.uiRightPressed or kbmMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 472
	end -- 472
	local rightHeld = ____temp_20 -- 470
	local ____temp_23 -- 474
	if (sim and sim.click) ~= nil then -- 474
		____temp_23 = sim.click -- 475
	else -- 475
		____temp_23 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 476
	end -- 476
	local click = ____temp_23 -- 474
	local ____temp_26 -- 477
	if (sim and sim.rightClick) ~= nil then -- 477
		____temp_26 = sim.rightClick -- 478
	else -- 478
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 479
	end -- 479
	local rightClick = ____temp_26 -- 477
	self.prevLeft = leftHeld -- 480
	self.prevRight = rightHeld -- 481
	local move = 0 -- 483
	local confirm = false -- 484
	local cancel = false -- 485
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 485
		move = sim.move or 0 -- 488
		confirm = sim.confirm == true -- 489
		cancel = sim.cancel == true -- 490
	else -- 490
		if type(Keyboard) ~= "nil" then -- 490
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 493
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 494
			local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 495
			local cc = Keyboard:isKeyPressed("BackSpace") -- 496
			if lk and not self.prevLeftKey then -- 496
				move = move - 1 -- 497
			end -- 497
			if rk and not self.prevRightKey then -- 497
				move = move + 1 -- 498
			end -- 498
			confirm = cf and not self.prevConfirm -- 499
			cancel = cc and not self.prevCancel -- 500
			self.prevLeftKey = lk -- 501
			self.prevRightKey = rk -- 502
			self.prevConfirm = cf -- 503
			self.prevCancel = cc -- 504
		end -- 504
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 504
			move = move - 1 -- 506
		end -- 506
		if ctx.input.navRight or ctx.input.navNextTab then -- 506
			move = move + 1 -- 507
		end -- 507
		if ctx.input.navConfirm then -- 507
			confirm = true -- 508
		end -- 508
		if ctx.input.navBack then -- 508
			cancel = true -- 509
		end -- 509
	end -- 509
	local ptr = Vec2(ptrX, ptrY) -- 513
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 514
	if cancel or rightClick or click and hitClose then -- 514
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 516
		return -- 517
	end -- 517
	local count = #bench.recipes -- 520
	if count == 0 then -- 520
		return -- 522
	end -- 522
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 525
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 526
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 527
	local hitCard = -1 -- 529
	if inside then -- 529
		local i = 0 -- 531
		do -- 531
			i = 0 -- 532
			while i < #self.cardBoxes do -- 532
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 532
					hitCard = i -- 534
					break -- 535
				end -- 535
				i = i + 1 -- 532
			end -- 532
		end -- 532
	end -- 532
	if move ~= 0 then -- 532
		self.pointerActive = false -- 541
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 542
	elseif pointerMoved and hitCard >= 0 then -- 542
		self.pointerActive = true -- 544
		self.selectedIdx = hitCard -- 545
	end -- 545
	local triggerConfirm = confirm or click and hitCard >= 0 -- 548
	if not triggerConfirm then -- 548
		return -- 550
	end -- 550
	if click and hitCard >= 0 then -- 550
		self.selectedIdx = hitCard -- 553
	end -- 553
	if self.handoverRemaining > 0.05 then -- 553
		return -- 558
	end -- 558
	local recipe = bench.recipes[self.selectedIdx + 1] -- 561
	if recipe == nil then -- 561
		return -- 563
	end -- 563
	if recipe.crafted then -- 563
		if bench.equippedWeapon ~= recipe.id then -- 563
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 568
		end -- 568
		return -- 570
	end -- 570
	if self.pendingRecipeId == recipe.id then -- 570
		return -- 575
	end -- 575
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 579
	if #missing > 0 then -- 579
		self.missingList = missing -- 581
		self.missingFlashT = 0.55 -- 582
		ctx.audio:playOnce( -- 583
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 584
			"sfx", -- 585
			"assets/audio/combat/craft_insufficient.wav", -- 586
			0.76, -- 587
			"craft:insufficient:" .. recipe.id, -- 588
			ctx.p.ticks -- 589
		) -- 589
		return -- 591
	end -- 591
	self.missingList = {} -- 594
	self.missingFlashT = 0 -- 595
	self.pendingRecipeId = recipe.id -- 596
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 597
	self.requestSeq = self.requestSeq + 1 -- 598
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 599
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 600
	if not accepted then -- 600
		self.pendingRecipeId = "" -- 606
	end -- 606
end -- 450
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 610
	local bench = ctx.view.craftBench -- 617
	if not bench.active and self.handoverRemaining <= 0.01 then -- 617
		return false -- 619
	end -- 619
	if not bench.active then -- 619
		self:drawHandoverOverlay( -- 624
			uiDraw, -- 624
			uiInkDraw, -- 624
			uiArt, -- 624
			uiGlow, -- 624
			ctx -- 624
		) -- 624
		return false -- 625
	end -- 625
	local appear = math.min(1, self.openAnimT) -- 628
	local layout = self:computeLayout(ctx, #bench.recipes) -- 629
	local bx = layout.benchX -- 630
	local by = layout.benchY -- 631
	local bw = layout.benchW -- 632
	local bh = layout.benchH -- 633
	fillVGradRect( -- 636
		uiDraw, -- 637
		0, -- 638
		0, -- 639
		ctx.uiW, -- 640
		by + bh + 64, -- 641
		Color( -- 642
			12, -- 642
			10, -- 642
			10, -- 642
			math.floor(168 * appear + 0.5) -- 642
		), -- 642
		Color(12, 10, 10, 0) -- 643
	) -- 643
	self:drawWoodenBenchBody( -- 647
		uiDraw, -- 647
		uiInkDraw, -- 647
		uiArt, -- 647
		uiGlow, -- 647
		bx, -- 647
		by, -- 647
		bw, -- 647
		bh, -- 647
		appear -- 647
	) -- 647
	ctx.texts:put( -- 650
		"md", -- 650
		"安全工台 · 改制鸟铳", -- 650
		bx + 54, -- 650
		by + bh - 26, -- 650
		toColor(PALETTE.amberCore), -- 650
		0, -- 650
		0.5, -- 650
		"Left", -- 650
		2, -- 650
		0.96 * appear, -- 650
		0.08 -- 650
	) -- 650
	drawHairline( -- 651
		uiInkDraw, -- 651
		uiArt, -- 651
		"cb_head_line", -- 651
		bx + bw * 0.5, -- 651
		by + bh - 46, -- 651
		bw - 36, -- 651
		PALETTE.amberDim, -- 651
		0.55 * appear, -- 651
		false, -- 651
		2 -- 651
	) -- 651
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 653
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 654
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 655
	uiInkDraw:drawRect( -- 656
		self.closeBox, -- 657
		Color( -- 658
			24, -- 658
			18, -- 658
			16, -- 658
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 658
		), -- 658
		0.9, -- 659
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 660
	) -- 660
	local closeText = ctx.input:isGamepadMode() and keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 662
	ctx.texts:put( -- 665
		"xs", -- 666
		closeText, -- 667
		self.closeBox.x + self.closeBox.width * 0.5, -- 668
		self.closeBox.y + self.closeBox.height * 0.5, -- 669
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 670
		0.5, -- 671
		0.5, -- 672
		"Center", -- 673
		1.4, -- 674
		0.95 * appear, -- 675
		0.06 -- 676
	) -- 676
	self:drawTableMaterials( -- 680
		uiDraw, -- 680
		uiInkDraw, -- 680
		uiArt, -- 680
		ctx, -- 680
		bench, -- 680
		bx + 18, -- 680
		by + 22, -- 680
		layout.matW - 14, -- 680
		bh - 76, -- 680
		appear -- 680
	) -- 680
	local i = 0 -- 683
	do -- 683
		i = 0 -- 684
		while i < #bench.recipes and i < #self.cardBoxes do -- 684
			self:drawRecipeCard( -- 685
				uiDraw, -- 686
				uiInkDraw, -- 687
				uiArt, -- 688
				uiGlow, -- 689
				ctx, -- 690
				bench, -- 691
				bench.recipes[i + 1], -- 692
				self.cardBoxes[i + 1], -- 693
				i == self.selectedIdx, -- 694
				appear -- 695
			) -- 695
			i = i + 1 -- 684
		end -- 684
	end -- 684
	if self.handoverRemaining > 0.01 then -- 684
		self:drawHandoverOverlay( -- 701
			uiDraw, -- 701
			uiInkDraw, -- 701
			uiArt, -- 701
			uiGlow, -- 701
			ctx -- 701
		) -- 701
	end -- 701
	return true -- 704
end -- 610
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 707
	uiDraw:drawRect( -- 719
		Rect(bx, by, bw, bh), -- 719
		Color( -- 719
			WOOD_BODY.r, -- 719
			WOOD_BODY.g, -- 719
			WOOD_BODY.b, -- 719
			math.floor(230 * appear + 0.5) -- 719
		), -- 719
		1.2, -- 719
		toColor(PALETTE.amberDim, 175 * appear) -- 719
	) -- 719
	uiArt:tryPlace( -- 720
		"fe_workbench", -- 720
		"cb_bench_wood", -- 720
		bx + bw * 0.5, -- 720
		by - 4, -- 720
		bw + 18, -- 720
		bh + 16, -- 720
		{ -- 720
			color = Color(216, 198, 180, 255), -- 721
			opacity = 0.92 * appear, -- 722
			layer = 0 -- 723
		} -- 723
	) -- 723
	uiInkDraw:drawSegment( -- 725
		Vec2(bx - 6, by + bh + 2), -- 725
		Vec2(bx + bw + 6, by + bh + 2), -- 725
		1.2, -- 725
		toColor(PALETTE.amberCore, 115 * appear) -- 725
	) -- 725
	local lx = bx + 28 -- 728
	local ly = by + bh - 24 -- 729
	uiArt:tryPlace( -- 730
		"prop_lantern", -- 730
		"cb_lantern", -- 730
		lx, -- 730
		ly, -- 730
		20, -- 730
		26, -- 730
		{opacity = 0.94 * appear, layer = 4} -- 730
	) -- 730
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 731
	fillRadialGlow( -- 732
		uiGlow, -- 733
		lx + 10, -- 734
		ly - 10, -- 735
		260 * pulse, -- 736
		180 * pulse, -- 737
		Color( -- 738
			238, -- 738
			198, -- 738
			128, -- 738
			math.floor(38 * appear + 0.5) -- 738
		), -- 738
		Color(238, 180, 92, 0), -- 739
		16 -- 740
	) -- 740
end -- 707
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 744
	uiDraw:drawRect( -- 756
		Rect(x, y, w, h), -- 756
		Color( -- 756
			26, -- 756
			20, -- 756
			17, -- 756
			math.floor(188 * appear + 0.5) -- 756
		), -- 756
		0.9, -- 756
		toColor(PALETTE.amberDim, 130 * appear) -- 756
	) -- 756
	drawFiligreeCorners( -- 757
		uiInkDraw, -- 757
		uiArt, -- 757
		"cb_mat_frame", -- 757
		x + 3, -- 757
		y + 3, -- 757
		w - 6, -- 757
		h - 6, -- 757
		PALETTE.amberDim, -- 757
		0.48 * appear, -- 757
		16, -- 757
		false, -- 757
		2 -- 757
	) -- 757
	ctx.texts:put( -- 759
		"xs", -- 759
		"案边持有", -- 759
		x + 12, -- 759
		y + h - 18, -- 759
		toColor(PALETTE.amberCore), -- 759
		0, -- 759
		0.5, -- 759
		"Left", -- 759
		1.4, -- 759
		0.92 * appear, -- 759
		0.06 -- 759
	) -- 759
	uiInkDraw:drawSegment( -- 760
		Vec2(x + 10, y + h - 32), -- 760
		Vec2(x + w - 10, y + h - 32), -- 760
		0.75, -- 760
		toColor(PALETTE.amberDim, 115 * appear) -- 760
	) -- 760
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 762
	local i = 0 -- 763
	do -- 763
		i = 0 -- 764
		while i < #keys and i < 4 do -- 764
			local mat = keys[i + 1] -- 765
			local count = bench.inventory[mat] or 0 -- 766
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 767
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 768
			local rowY = y + h - 62 - i * 48 -- 769
			if isMissing then -- 769
				uiDraw:drawRect( -- 772
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 772
					toColor(PALETTE.rougeSoft, 145 * appear), -- 772
					1, -- 772
					toColor(PALETTE.crimsonCore, 220 * appear) -- 772
				) -- 772
			end -- 772
			local shown = math.max( -- 776
				1, -- 776
				math.min(4, count) -- 776
			) -- 776
			local t = 0 -- 777
			do -- 777
				t = 0 -- 778
				while t < shown do -- 778
					local tx = x + 22 + t * 15 + shake -- 779
					local filled = t < count -- 780
					local isBell = mat == "bell_tally" or mat == "bell" -- 781
					local iconSlot = isBell and "fe_icon_bell_tally" or "fe_icon_wood_tally" -- 782
					if not uiArt:tryPlace( -- 782
						iconSlot, -- 783
						(("cb_mat_" .. mat) .. "_") .. tostring(t), -- 783
						math.floor(tx + 0.5), -- 783
						math.floor(rowY + 0.5), -- 783
						18, -- 783
						22, -- 783
						{ -- 783
							color = filled and Color(255, 255, 255, 255) or Color(142, 138, 132, 255), -- 784
							opacity = (filled and 0.98 or 0.34) * appear, -- 785
							layer = 3 -- 786
						} -- 786
					) then -- 786
						drawReloadPatternGlyph( -- 788
							uiInkDraw, -- 788
							tx, -- 788
							rowY, -- 788
							7.5, -- 788
							isBell and "echo" or "knockback", -- 788
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 788
							(filled and 0.96 or 0.38) * appear -- 788
						) -- 788
					end -- 788
					t = t + 1 -- 778
				end -- 778
			end -- 778
			ctx.texts:put( -- 792
				"xs", -- 793
				materialLabel(mat), -- 794
				x + 86 + shake, -- 795
				rowY + 5, -- 796
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 797
				0, -- 798
				0.5, -- 799
				"Left", -- 800
				0.8, -- 801
				0.95 * appear, -- 802
				0.06 -- 803
			) -- 803
			ctx.texts:put( -- 805
				"xs", -- 806
				"存 " .. tostring(count), -- 807
				x + 86 + shake, -- 808
				rowY - 11, -- 809
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 810
				0, -- 811
				0.5, -- 812
				"Left", -- 813
				0.8, -- 814
				0.88 * appear, -- 815
				0.06 -- 816
			) -- 816
			i = i + 1 -- 764
		end -- 764
	end -- 764
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 821
	uiInkDraw:drawSegment( -- 822
		Vec2(x + 10, y + 32), -- 822
		Vec2(x + w - 10, y + 32), -- 822
		0.75, -- 822
		toColor(PALETTE.amberDim, 105 * appear) -- 822
	) -- 822
	ctx.texts:put( -- 823
		"xs", -- 823
		"现佩：" .. eqName, -- 823
		x + 12, -- 823
		y + 16, -- 823
		toColor(PALETTE.textMid), -- 823
		0, -- 823
		0.5, -- 823
		"Left", -- 823
		0.8, -- 823
		0.9 * appear, -- 823
		0.06 -- 823
	) -- 823
end -- 744
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 826
	local i = 0 -- 827
	do -- 827
		i = 0 -- 828
		while i < #bench.recipes do -- 828
			if bench.recipes[i + 1].id == weaponId then -- 828
				return bench.recipes[i + 1].name -- 830
			end -- 830
			i = i + 1 -- 828
		end -- 828
	end -- 828
	return "旧制鸟铳" -- 833
end -- 826
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 836
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 848
	local canCraft = not recipe.crafted and #missing == 0 -- 849
	local equipped = bench.equippedWeapon == recipe.id -- 850
	local isPending = self.pendingRecipeId == recipe.id -- 851
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 852
	if not uiArt:tryPlace( -- 852
		"ink_song_paper", -- 855
		"cb_card_" .. recipe.id, -- 855
		box.x + box.width * 0.5, -- 855
		box.y + box.height * 0.5, -- 855
		box.width, -- 855
		box.height, -- 855
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 855
	) then -- 855
		uiDraw:drawRect( -- 856
			box, -- 856
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 856
		) -- 856
	end -- 856
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 859
	drawFiligreeCorners( -- 862
		uiInkDraw, -- 862
		uiArt, -- 862
		"cb_cf_" .. recipe.id, -- 862
		box.x + 5, -- 862
		box.y + 5, -- 862
		box.width - 10, -- 862
		box.height - 10, -- 862
		borderCol, -- 862
		(selected and 0.88 or 0.46) * appear, -- 862
		18, -- 862
		true, -- 862
		2 -- 862
	) -- 862
	if selected then -- 862
		drawSilkRibbon( -- 865
			uiDraw, -- 865
			uiArt, -- 865
			"cb_sel_rib_" .. recipe.id, -- 865
			box.x + box.width * 0.5, -- 865
			box.y + box.height - 26, -- 865
			box.width - 14, -- 865
			30, -- 865
			PALETTE.amberDim, -- 865
			0.24 * appear, -- 865
			2 -- 865
		) -- 865
	end -- 865
	local topY = box.y + box.height - 26 -- 869
	drawBlossomDot( -- 870
		uiInkDraw, -- 870
		uiArt, -- 870
		"cb_dot_" .. recipe.id, -- 870
		box.x + 18, -- 870
		topY, -- 870
		selected and 11 or 7, -- 870
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 870
		0.92 * appear, -- 870
		3 -- 870
	) -- 870
	ctx.texts:put( -- 871
		"md", -- 871
		recipe.name, -- 871
		box.x + 30, -- 871
		topY, -- 871
		toColor(PALETTE.xuanInk), -- 871
		0, -- 871
		0.5, -- 871
		"Left", -- 871
		1.6, -- 871
		0.98 * appear, -- 871
		0 -- 871
	) -- 871
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 873
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 874
	ctx.texts:put( -- 875
		"xs", -- 875
		badge, -- 875
		box.x + box.width - 14, -- 875
		topY, -- 875
		toColor(badgeCol), -- 875
		1, -- 875
		0.5, -- 875
		"Right", -- 875
		1, -- 875
		0.94 * appear, -- 875
		0 -- 875
	) -- 875
	local narrow = box.width < 195 -- 878
	local miniCx = box.x + (narrow and 36 or 46) -- 879
	local miniCy = box.y + box.height - 96 -- 880
	self:drawMiniReloadPreview( -- 881
		uiInkDraw, -- 881
		uiArt, -- 881
		uiGlow, -- 881
		recipe.id, -- 881
		miniCx, -- 881
		miniCy, -- 881
		recipe.enhancedEffect, -- 881
		appear -- 881
	) -- 881
	local infoX = box.x + (narrow and 72 or 90) -- 884
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 885
	ctx.texts:put( -- 886
		"xs", -- 886
		effTitle, -- 886
		infoX, -- 886
		box.y + box.height - 64, -- 886
		toColor(PALETTE.rouge), -- 886
		0, -- 886
		0.5, -- 886
		"Left", -- 886
		narrow and 0.3 or 0.8, -- 886
		0.95 * appear, -- 886
		0 -- 886
	) -- 886
	local row = 0 -- 888
	for mat in pairs(recipe.cost) do -- 889
		local need = recipe.cost[mat] -- 890
		local have = bench.inventory[mat] or 0 -- 891
		local lack = not recipe.crafted and have < need -- 892
		local ry = box.y + box.height - 90 - row * 22 -- 893
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 894
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 895
		ctx.texts:put( -- 896
			"xs", -- 896
			text, -- 896
			infoX, -- 896
			ry, -- 896
			toColor(col), -- 896
			0, -- 896
			0.5, -- 896
			"Left", -- 896
			0.6, -- 896
			0.94 * appear, -- 896
			0 -- 896
		) -- 896
		row = row + 1 -- 897
	end -- 897
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 901
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 902
	local btnBg = equipped and Color( -- 905
		168, -- 906
		46, -- 906
		44, -- 906
		math.floor(32 * appear + 0.5) -- 906
	) or (selected and (canCraft or recipe.crafted) and Color( -- 906
		32, -- 908
		30, -- 908
		32, -- 908
		math.floor(218 * appear + 0.5) -- 908
	) or Color( -- 908
		32, -- 909
		30, -- 909
		32, -- 909
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 909
	)) -- 909
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 910
	uiInkDraw:drawRect( -- 913
		btnRect, -- 913
		btnBg, -- 913
		0.9, -- 913
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 913
	) -- 913
	ctx.texts:put( -- 914
		"sm", -- 915
		btnLabel, -- 916
		btnRect.x + btnRect.width * 0.5, -- 917
		btnRect.y + btnRect.height * 0.5, -- 918
		toColor(btnTextCol), -- 919
		0.5, -- 920
		0.5, -- 921
		"Center", -- 922
		1.6, -- 923
		0.96 * appear, -- 924
		0 -- 925
	) -- 925
end -- 836
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiArt, uiGlow, recipeId, cx, cy, effect, appear) -- 930
	local step = 20 -- 940
	local samplePath = effect == "light" and ({ -- 941
		0, -- 941
		1, -- 941
		2, -- 941
		5, -- 941
		8 -- 941
	}) or (effect == "echo" and ({ -- 941
		0, -- 941
		1, -- 941
		4, -- 941
		5, -- 941
		8 -- 941
	}) or ({ -- 941
		0, -- 941
		3, -- 941
		6, -- 941
		7, -- 941
		8 -- 941
	})) -- 941
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 942
	uiInkDraw:drawRect( -- 945
		Rect(cx - 32, cy - 32, 64, 64), -- 945
		Color( -- 945
			224, -- 945
			218, -- 945
			206, -- 945
			math.floor(145 * appear + 0.5) -- 945
		), -- 945
		0.8, -- 945
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 945
	) -- 945
	local i = 0 -- 946
	do -- 946
		i = 0 -- 947
		while i < #RELOAD_GRID do -- 947
			local g = RELOAD_GRID[i + 1] -- 948
			local nx = cx + (g.col - 1) * step -- 949
			local ny = cy + (g.row - 1) * step -- 950
			uiInkDraw:drawDot( -- 951
				Vec2(nx, ny), -- 951
				1.8, -- 951
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 951
			) -- 951
			i = i + 1 -- 947
		end -- 947
	end -- 947
	do -- 947
		i = 0 -- 955
		while i < #samplePath - 1 do -- 955
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 956
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 957
			uiInkDraw:drawSegment( -- 958
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 959
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 960
				1.8, -- 961
				toColor(accent, 220 * appear) -- 962
			) -- 962
			i = i + 1 -- 955
		end -- 955
	end -- 955
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 967
	local kx = cx + (keyNode.col - 1) * step -- 968
	local ky = cy + (keyNode.row - 1) * step -- 969
	drawReloadPatternGlyph( -- 970
		uiInkDraw, -- 970
		kx, -- 970
		ky, -- 970
		8, -- 970
		effect, -- 970
		accent, -- 970
		appear, -- 970
		uiArt, -- 970
		"cb_mini_" .. recipeId, -- 970
		4 -- 970
	) -- 970
	fillRadialGlow( -- 971
		uiGlow, -- 971
		kx, -- 971
		ky, -- 971
		14, -- 971
		14, -- 971
		toColor(PALETTE.amberCore, 45 * appear), -- 971
		Color(244, 234, 214, 0), -- 971
		10 -- 971
	) -- 971
end -- 930
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 975
	local prog = math.max( -- 982
		0, -- 982
		math.min( -- 982
			1, -- 982
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 982
		) -- 982
	) -- 982
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 983
	local cx = math.floor(ctx.uiW * 0.5 + 0.5) -- 984
	local cy = math.floor(ctx.uiH * 0.6 + 0.5) -- 985
	local cardW = math.min( -- 986
		448, -- 986
		math.floor(ctx.uiW - 120 + 0.5) -- 986
	) -- 986
	local cardH = math.floor(cardW * 9 / 16 + 0.5) -- 987
	local gripLift = prog >= 0.32 and prog < 0.78 and math.sin((prog - 0.32) / 0.46 * math.pi) * 5 or 0 -- 988
	local rect = { -- 989
		x = math.floor(cx - cardW * 0.5 + 0.5), -- 990
		y = math.floor(cy - cardH * 0.5 + gripLift + 0.5), -- 991
		w = cardW, -- 992
		h = cardH -- 993
	} -- 993
	local slideSlot = self.handoverEffect == "echo" and "slide_m02_echo_gun" or "slide_m02_lantern_gun" -- 996
	fillRadialGlow( -- 997
		uiGlow, -- 997
		cx, -- 997
		cy, -- 997
		cardW * 0.72, -- 997
		cardH * 0.88, -- 997
		toColor(PALETTE.amberCore, 58 * fade), -- 997
		Color(244, 234, 214, 0), -- 997
		16 -- 997
	) -- 997
	drawPixelSlidePlate( -- 998
		uiDraw, -- 998
		uiInkDraw, -- 998
		uiArt, -- 998
		slideSlot, -- 998
		"cb_handover_slide", -- 998
		rect, -- 998
		0.98 * fade, -- 998
		5, -- 998
		0, -- 998
		0, -- 998
		1 + prog * 0.032 -- 998
	) -- 998
	drawSlideFrameChrome( -- 999
		uiDraw, -- 999
		uiInkDraw, -- 999
		uiArt, -- 999
		rect, -- 999
		ctx.uiW, -- 999
		ctx.uiH, -- 999
		{ -- 999
			frameOpacity = 0.9, -- 1000
			letterboxH = 0, -- 1001
			opacity = fade, -- 1002
			layer = 5, -- 1003
			instancePrefix = "cb_ho" -- 1004
		} -- 1004
	) -- 1004
	local capY = rect.y - 24 -- 1007
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1008
	drawSilkVeil( -- 1011
		uiDraw, -- 1011
		uiArt, -- 1011
		"cb_handover_cap_veil", -- 1011
		cx, -- 1011
		capY, -- 1011
		310, -- 1011
		32, -- 1011
		PALETTE.inkWash, -- 1011
		0.82 * fade, -- 1011
		6 -- 1011
	) -- 1011
	ctx.texts:put( -- 1012
		"xs", -- 1012
		caption, -- 1012
		cx, -- 1012
		capY, -- 1012
		toColor(PALETTE.amberCore), -- 1012
		0.5, -- 1012
		0.5, -- 1012
		"Center", -- 1012
		1.4, -- 1012
		0.96 * fade, -- 1012
		0.08 -- 1012
	) -- 1012
end -- 975
function ____exports.createCraftBenchPlugin(contract) -- 1016
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1017
end -- 1016
return ____exports -- 1016