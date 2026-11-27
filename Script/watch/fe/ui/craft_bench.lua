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
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 216
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
	self.prevLeftKey = false -- 204
	self.prevRightKey = false -- 205
	self.prevConfirm = false -- 206
	self.prevCancel = false -- 207
	self.pointerActive = false -- 208
	self.cardBoxes = {} -- 211
	self.closeBox = Rect(0, 0, 0, 0) -- 212
	self.injectedContract = contract -- 217
end -- 216
function CraftBenchPlugin.prototype.injectInputForTest(self, sim) -- 221
	self.pendingSimInput = sim -- 222
end -- 221
function CraftBenchPlugin.prototype.getState(self) -- 225
	local inv = {} -- 226
	local craftedIds = {} -- 227
	local equipped = "standard_gun" -- 228
	if self.lastSnapshotBench ~= nil then -- 228
		for k in pairs(self.lastSnapshotBench.inventory) do -- 230
			inv[k] = self.lastSnapshotBench.inventory[k] -- 231
		end -- 231
		local i = 0 -- 233
		do -- 233
			i = 0 -- 234
			while i < #self.lastSnapshotBench.recipes do -- 234
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 234
					craftedIds[#craftedIds + 1] = self.lastSnapshotBench.recipes[i + 1].id -- 236
				end -- 236
				i = i + 1 -- 234
			end -- 234
		end -- 234
		equipped = self.lastSnapshotBench.equippedWeapon -- 239
	end -- 239
	return { -- 241
		active = self.wasActive, -- 242
		selectedIndex = self.selectedIdx, -- 243
		pendingRecipeId = self.pendingRecipeId, -- 244
		missingFlashT = self.missingFlashT, -- 245
		missingMaterials = __TS__ArraySlice(self.missingList), -- 246
		handoverActive = self.handoverRemaining > 0, -- 247
		handoverDuration = self.handoverDuration, -- 248
		handoverRemaining = self.handoverRemaining, -- 249
		handoverWeaponId = self.handoverWeaponId, -- 250
		equippedWeapon = equipped, -- 251
		inventory = inv, -- 252
		craftedIds = craftedIds -- 253
	} -- 253
end -- 225
function CraftBenchPlugin.prototype.onBindPlay(self, _p, view) -- 257
	self.wasActive = view.craftBench.active -- 259
	self.selectedIdx = 0 -- 260
	self.animTime = 0 -- 261
	self.openAnimT = view.craftBench.active and 1 or 0 -- 262
	self.pendingRecipeId = "" -- 263
	self.pendingFirstCraftAtSubmit = not view.craftBench.firstCraftDone -- 264
	self.missingFlashT = 0 -- 265
	self.missingList = {} -- 266
	self.handoverRemaining = 0 -- 267
	self.handoverDuration = 1 -- 268
	self.handoverWeaponId = "" -- 269
	self.handoverWeaponName = "" -- 270
	self.pendingSimInput = nil -- 271
	self:syncCraftedSnapshot(view.craftBench) -- 272
	self.lastSnapshotBench = view.craftBench -- 273
	self:resetInputEdges() -- 274
end -- 257
function CraftBenchPlugin.prototype.syncCraftedSnapshot(self, bench) -- 277
	self.prevCraftedMap = {} -- 278
	local i = 0 -- 279
	do -- 279
		i = 0 -- 280
		while i < #bench.recipes do -- 280
			self.prevCraftedMap[bench.recipes[i + 1].id] = bench.recipes[i + 1].crafted -- 281
			i = i + 1 -- 280
		end -- 280
	end -- 280
end -- 277
function CraftBenchPlugin.prototype.resetInputEdges(self, touchMode) -- 285
	if touchMode == nil then -- 285
		touchMode = false -- 285
	end -- 285
	local ____temp_1 -- 286
	if not touchMode and type(Mouse) ~= "nil" then -- 286
		____temp_1 = Mouse.leftButtonPressed -- 286
	else -- 286
		____temp_1 = false -- 286
	end -- 286
	self.prevLeft = ____temp_1 -- 286
	local ____temp_2 -- 287
	if not touchMode and type(Mouse) ~= "nil" then -- 287
		____temp_2 = Mouse.rightButtonPressed -- 287
	else -- 287
		____temp_2 = false -- 287
	end -- 287
	self.prevRight = ____temp_2 -- 287
	if type(Keyboard) ~= "nil" then -- 287
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 289
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 290
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 291
		self.prevCancel = Keyboard:isKeyPressed("Escape") or Keyboard:isKeyPressed("BackSpace") -- 292
	end -- 292
end -- 285
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 296
	local contract = resolveRuntimeContract(self.injectedContract) -- 297
	if contract ~= nil then -- 297
		return contract:submitIntent(p, intent) -- 299
	end -- 299
	return dispatchIntentFallback(p, intent) -- 301
end -- 296
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 304
	local uiW = ctx.uiW -- 311
	local uiH = ctx.uiH -- 312
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 313
	local touchMode = ctx.input:isTouchMode() -- 314
	local benchW = math.min(uiW - 88 - safe.left - safe.right, 692) -- 315
	local benchH = 290 -- 316
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 318
	local minX = 36 + safe.left -- 319
	local maxX = math.max(minX, uiW - benchW - 44 - safe.right) -- 320
	local benchX = soldierUiX < uiW * 0.52 and maxX or minX -- 321
	local benchY = math.max( -- 322
		46 + safe.bottom, -- 322
		math.min(uiH * 0.1 + safe.bottom, 66 + safe.bottom) -- 322
	) -- 322
	local matW = 196 -- 323
	local cardsAreaX = benchX + matW + 18 -- 325
	local cardsAreaW = benchW - matW - 34 -- 326
	local count = math.max(1, recipeCount) -- 327
	local gap = 14 -- 328
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 329
	local cardH = benchH - 72 -- 330
	local cardY = benchY + 20 -- 331
	self.cardBoxes = {} -- 333
	local i = 0 -- 334
	do -- 334
		i = 0 -- 335
		while i < count do -- 335
			local ____self_cardBoxes_3 = self.cardBoxes -- 335
			____self_cardBoxes_3[#____self_cardBoxes_3 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 336
			i = i + 1 -- 335
		end -- 335
	end -- 335
	local closeW = touchMode and 88 or 76 -- 338
	local closeH = touchMode and 32 or 26 -- 339
	self.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH) -- 340
	return { -- 341
		benchX = benchX, -- 341
		benchY = benchY, -- 341
		benchW = benchW, -- 341
		benchH = benchH, -- 341
		matW = matW -- 341
	} -- 341
end -- 304
function CraftBenchPlugin.prototype.update(self, ctx) -- 344
	local bench = ctx.view.craftBench -- 345
	self.lastSnapshotBench = bench -- 346
	if ctx.paused then -- 346
		self:resetInputEdges(ctx.input:isTouchMode()) -- 350
		return -- 351
	end -- 351
	local udt = math.max(0, ctx.uiDt) -- 354
	self.animTime = self.animTime + udt -- 355
	if self.missingFlashT > 0 then -- 355
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 358
	end -- 358
	if self.handoverRemaining > 0 then -- 358
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 361
	end -- 361
	self:detectCraftCompletion(ctx, bench) -- 365
	if bench.active and not self.wasActive then -- 365
		self.openAnimT = 0 -- 368
		self.pendingRecipeId = "" -- 369
		self.missingFlashT = 0 -- 370
		self.missingList = {} -- 371
		self.selectedIdx = math.max( -- 372
			0, -- 372
			math.min( -- 372
				math.max(0, #bench.recipes - 1), -- 372
				self.selectedIdx -- 372
			) -- 372
		) -- 372
		self:resetInputEdges(ctx.input:isTouchMode()) -- 373
	elseif not bench.active and self.wasActive then -- 373
		self.pendingRecipeId = "" -- 375
		self.missingFlashT = 0 -- 376
	end -- 376
	self.wasActive = bench.active -- 378
	if not bench.active then -- 378
		self.pendingSimInput = nil -- 381
		return -- 382
	end -- 382
	self.openAnimT = math.min(1, self.openAnimT + udt / 0.22) -- 385
	self:computeLayout(ctx, #bench.recipes) -- 386
	self:processInputs(ctx, bench) -- 389
end -- 344
function CraftBenchPlugin.prototype.detectCraftCompletion(self, ctx, bench) -- 392
	local newlyCrafted -- 393
	local i = 0 -- 394
	do -- 394
		i = 0 -- 395
		while i < #bench.recipes do -- 395
			local r = bench.recipes[i + 1] -- 396
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 396
				newlyCrafted = r -- 398
			end -- 398
			self.prevCraftedMap[r.id] = r.crafted -- 400
			i = i + 1 -- 395
		end -- 395
	end -- 395
	do -- 395
		i = 0 -- 404
		while i < #ctx.events.rawEvents do -- 404
			local ename = ctx.events.rawEvents[i + 1].name -- 405
			if ename == "benchRejected" then -- 405
				self.pendingRecipeId = "" -- 407
				self.missingFlashT = 0.45 -- 408
			end -- 408
			i = i + 1 -- 404
		end -- 404
	end -- 404
	if newlyCrafted ~= nil then -- 404
		local ____temp_4 -- 413
		if self.pendingRecipeId == newlyCrafted.id then -- 413
			____temp_4 = self.pendingFirstCraftAtSubmit -- 414
		else -- 414
			____temp_4 = bench.justCraftedTimer >= 0.72 -- 415
		end -- 415
		local isFirst = ____temp_4 -- 413
		self.pendingRecipeId = "" -- 416
		self.handoverWeaponId = newlyCrafted.id -- 417
		self.handoverWeaponName = newlyCrafted.name -- 418
		self.handoverEffect = newlyCrafted.enhancedEffect -- 419
		self.handoverDuration = isFirst and 1 or 0.45 -- 420
		self.handoverRemaining = self.handoverDuration -- 421
		local hasBackendDone = false -- 423
		do -- 423
			i = 0 -- 424
			while i < #ctx.events.rawEvents do -- 424
				local ename = ctx.events.rawEvents[i + 1].name -- 425
				if ename == "craftDone" or ename == "benchCraft" then -- 425
					hasBackendDone = true -- 427
					break -- 428
				end -- 428
				i = i + 1 -- 424
			end -- 424
		end -- 424
		if not hasBackendDone then -- 424
			ctx.audio:playOnce( -- 432
				(("fe02:craft_done:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. newlyCrafted.id, -- 433
				"sfx", -- 434
				"assets/audio/combat/craft_done.wav", -- 435
				0.88, -- 436
				"craft:done:" .. newlyCrafted.id, -- 437
				ctx.p.ticks -- 438
			) -- 438
		end -- 438
	end -- 438
end -- 392
function CraftBenchPlugin.prototype.processInputs(self, ctx, bench) -- 444
	local sim = self.pendingSimInput -- 445
	self.pendingSimInput = nil -- 446
	local touchMode = ctx.input:isTouchMode() -- 448
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 449
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 451
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 454
	local ____temp_14 -- 457
	if (sim and sim.pointerX) ~= nil then -- 457
		____temp_14 = true -- 458
	else -- 458
		local ____useUiPtr_13 -- 459
		if useUiPtr then -- 459
			____useUiPtr_13 = ctx.input.uiInside -- 459
		else -- 459
			____useUiPtr_13 = ctx.input.inside -- 459
		end -- 459
		____temp_14 = ____useUiPtr_13 -- 459
	end -- 459
	local inside = ____temp_14 -- 457
	local ____temp_17 -- 460
	if (sim and sim.click) ~= nil then -- 460
		____temp_17 = sim.click -- 461
	else -- 461
		____temp_17 = ctx.input.uiHeld or ctx.input.fire.held or not touchMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 462
	end -- 462
	local leftHeld = ____temp_17 -- 460
	local ____temp_20 -- 463
	if (sim and sim.rightClick) ~= nil then -- 463
		____temp_20 = sim.rightClick -- 464
	else -- 464
		____temp_20 = ctx.input.uiRightPressed or not touchMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 465
	end -- 465
	local rightHeld = ____temp_20 -- 463
	local ____temp_23 -- 467
	if (sim and sim.click) ~= nil then -- 467
		____temp_23 = sim.click -- 468
	else -- 468
		____temp_23 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 469
	end -- 469
	local click = ____temp_23 -- 467
	local ____temp_26 -- 470
	if (sim and sim.rightClick) ~= nil then -- 470
		____temp_26 = sim.rightClick -- 471
	else -- 471
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 472
	end -- 472
	local rightClick = ____temp_26 -- 470
	self.prevLeft = leftHeld -- 473
	self.prevRight = rightHeld -- 474
	local move = 0 -- 476
	local confirm = false -- 477
	local cancel = false -- 478
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 478
		move = sim.move or 0 -- 481
		confirm = sim.confirm == true -- 482
		cancel = sim.cancel == true -- 483
	else -- 483
		if type(Keyboard) ~= "nil" then -- 483
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 486
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 487
			local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 488
			local cc = Keyboard:isKeyPressed("BackSpace") -- 489
			if lk and not self.prevLeftKey then -- 489
				move = move - 1 -- 490
			end -- 490
			if rk and not self.prevRightKey then -- 490
				move = move + 1 -- 491
			end -- 491
			confirm = cf and not self.prevConfirm -- 492
			cancel = cc and not self.prevCancel -- 493
			self.prevLeftKey = lk -- 494
			self.prevRightKey = rk -- 495
			self.prevConfirm = cf -- 496
			self.prevCancel = cc -- 497
		end -- 497
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 497
			move = move - 1 -- 499
		end -- 499
		if ctx.input.navRight or ctx.input.navNextTab then -- 499
			move = move + 1 -- 500
		end -- 500
		if ctx.input.navConfirm then -- 500
			confirm = true -- 501
		end -- 501
		if ctx.input.navBack then -- 501
			cancel = true -- 502
		end -- 502
	end -- 502
	local ptr = Vec2(ptrX, ptrY) -- 506
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 507
	if cancel or rightClick or click and hitClose then -- 507
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 509
		return -- 510
	end -- 510
	local count = #bench.recipes -- 513
	if count == 0 then -- 513
		return -- 515
	end -- 515
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 518
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 519
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 520
	local hitCard = -1 -- 522
	if inside then -- 522
		local i = 0 -- 524
		do -- 524
			i = 0 -- 525
			while i < #self.cardBoxes do -- 525
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 525
					hitCard = i -- 527
					break -- 528
				end -- 528
				i = i + 1 -- 525
			end -- 525
		end -- 525
	end -- 525
	if move ~= 0 then -- 525
		self.pointerActive = false -- 534
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 535
	elseif pointerMoved and hitCard >= 0 then -- 535
		self.pointerActive = true -- 537
		self.selectedIdx = hitCard -- 538
	end -- 538
	local triggerConfirm = confirm or click and hitCard >= 0 -- 541
	if not triggerConfirm then -- 541
		return -- 543
	end -- 543
	if click and hitCard >= 0 then -- 543
		self.selectedIdx = hitCard -- 546
	end -- 546
	if self.handoverRemaining > 0.05 then -- 546
		return -- 551
	end -- 551
	local recipe = bench.recipes[self.selectedIdx + 1] -- 554
	if recipe == nil then -- 554
		return -- 556
	end -- 556
	if recipe.crafted then -- 556
		if bench.equippedWeapon ~= recipe.id then -- 556
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 561
		end -- 561
		return -- 563
	end -- 563
	if self.pendingRecipeId == recipe.id then -- 563
		return -- 568
	end -- 568
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 572
	if #missing > 0 then -- 572
		self.missingList = missing -- 574
		self.missingFlashT = 0.55 -- 575
		ctx.audio:playOnce( -- 576
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 577
			"sfx", -- 578
			"assets/audio/combat/craft_insufficient.wav", -- 579
			0.76, -- 580
			"craft:insufficient:" .. recipe.id, -- 581
			ctx.p.ticks -- 582
		) -- 582
		return -- 584
	end -- 584
	self.missingList = {} -- 587
	self.missingFlashT = 0 -- 588
	self.pendingRecipeId = recipe.id -- 589
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 590
	self.requestSeq = self.requestSeq + 1 -- 591
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 592
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 593
	if not accepted then -- 593
		self.pendingRecipeId = "" -- 599
	end -- 599
end -- 444
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 603
	local bench = ctx.view.craftBench -- 610
	if not bench.active and self.handoverRemaining <= 0.01 then -- 610
		return false -- 612
	end -- 612
	if not bench.active then -- 612
		self:drawHandoverOverlay( -- 617
			uiDraw, -- 617
			uiInkDraw, -- 617
			uiArt, -- 617
			uiGlow, -- 617
			ctx -- 617
		) -- 617
		return false -- 618
	end -- 618
	local appear = math.min(1, self.openAnimT) -- 621
	local layout = self:computeLayout(ctx, #bench.recipes) -- 622
	local bx = layout.benchX -- 623
	local by = layout.benchY -- 624
	local bw = layout.benchW -- 625
	local bh = layout.benchH -- 626
	fillVGradRect( -- 629
		uiDraw, -- 630
		0, -- 631
		0, -- 632
		ctx.uiW, -- 633
		by + bh + 64, -- 634
		Color( -- 635
			12, -- 635
			10, -- 635
			10, -- 635
			math.floor(168 * appear + 0.5) -- 635
		), -- 635
		Color(12, 10, 10, 0) -- 636
	) -- 636
	self:drawWoodenBenchBody( -- 640
		uiDraw, -- 640
		uiInkDraw, -- 640
		uiArt, -- 640
		uiGlow, -- 640
		bx, -- 640
		by, -- 640
		bw, -- 640
		bh, -- 640
		appear -- 640
	) -- 640
	ctx.texts:put( -- 643
		"md", -- 643
		"安全工台 · 改制鸟铳", -- 643
		bx + 54, -- 643
		by + bh - 26, -- 643
		toColor(PALETTE.amberCore), -- 643
		0, -- 643
		0.5, -- 643
		"Left", -- 643
		2, -- 643
		0.96 * appear, -- 643
		0.08 -- 643
	) -- 643
	drawHairline( -- 644
		uiInkDraw, -- 644
		uiArt, -- 644
		"cb_head_line", -- 644
		bx + bw * 0.5, -- 644
		by + bh - 46, -- 644
		bw - 36, -- 644
		PALETTE.amberDim, -- 644
		0.55 * appear, -- 644
		false, -- 644
		2 -- 644
	) -- 644
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 646
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 647
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 648
	uiInkDraw:drawRect( -- 649
		self.closeBox, -- 650
		Color( -- 651
			24, -- 651
			18, -- 651
			16, -- 651
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 651
		), -- 651
		0.9, -- 652
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 653
	) -- 653
	local closeText = ctx.input:isGamepadMode() and keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 655
	ctx.texts:put( -- 658
		"xs", -- 659
		closeText, -- 660
		self.closeBox.x + self.closeBox.width * 0.5, -- 661
		self.closeBox.y + self.closeBox.height * 0.5, -- 662
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 663
		0.5, -- 664
		0.5, -- 665
		"Center", -- 666
		1.4, -- 667
		0.95 * appear, -- 668
		0.06 -- 669
	) -- 669
	self:drawTableMaterials( -- 673
		uiDraw, -- 673
		uiInkDraw, -- 673
		uiArt, -- 673
		ctx, -- 673
		bench, -- 673
		bx + 18, -- 673
		by + 22, -- 673
		layout.matW - 14, -- 673
		bh - 76, -- 673
		appear -- 673
	) -- 673
	local i = 0 -- 676
	do -- 676
		i = 0 -- 677
		while i < #bench.recipes and i < #self.cardBoxes do -- 677
			self:drawRecipeCard( -- 678
				uiDraw, -- 679
				uiInkDraw, -- 680
				uiArt, -- 681
				uiGlow, -- 682
				ctx, -- 683
				bench, -- 684
				bench.recipes[i + 1], -- 685
				self.cardBoxes[i + 1], -- 686
				i == self.selectedIdx, -- 687
				appear -- 688
			) -- 688
			i = i + 1 -- 677
		end -- 677
	end -- 677
	if self.handoverRemaining > 0.01 then -- 677
		self:drawHandoverOverlay( -- 694
			uiDraw, -- 694
			uiInkDraw, -- 694
			uiArt, -- 694
			uiGlow, -- 694
			ctx -- 694
		) -- 694
	end -- 694
	return true -- 697
end -- 603
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 700
	uiDraw:drawRect( -- 712
		Rect(bx, by, bw, bh), -- 712
		Color( -- 712
			WOOD_BODY.r, -- 712
			WOOD_BODY.g, -- 712
			WOOD_BODY.b, -- 712
			math.floor(244 * appear + 0.5) -- 712
		), -- 712
		1.4, -- 712
		toColor(PALETTE.amberDim, 190 * appear) -- 712
	) -- 712
	uiDraw:drawRect( -- 714
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 714
		Color( -- 714
			WOOD_TOP.r, -- 714
			WOOD_TOP.g, -- 714
			WOOD_TOP.b, -- 714
			math.floor(250 * appear + 0.5) -- 714
		), -- 714
		1, -- 714
		WOOD_EDGE -- 714
	) -- 714
	uiInkDraw:drawSegment( -- 715
		Vec2(bx - 6, by + bh + 3), -- 715
		Vec2(bx + bw + 6, by + bh + 3), -- 715
		1.2, -- 715
		toColor(PALETTE.amberCore, 115 * appear) -- 715
	) -- 715
	uiDraw:drawRect( -- 717
		Rect(bx + 18, by - 26, 22, 26), -- 717
		Color( -- 717
			WOOD_DARK.r, -- 717
			WOOD_DARK.g, -- 717
			WOOD_DARK.b, -- 717
			math.floor(235 * appear + 0.5) -- 717
		) -- 717
	) -- 717
	uiDraw:drawRect( -- 718
		Rect(bx + bw - 40, by - 26, 22, 26), -- 718
		Color( -- 718
			WOOD_DARK.r, -- 718
			WOOD_DARK.g, -- 718
			WOOD_DARK.b, -- 718
			math.floor(235 * appear + 0.5) -- 718
		) -- 718
	) -- 718
	local g = 1 -- 721
	do -- 721
		g = 1 -- 722
		while g <= 4 do -- 722
			local gy = by + (bh - 50) * (g / 5) -- 723
			uiDraw:drawSegment( -- 724
				Vec2(bx + 10, gy), -- 724
				Vec2(bx + bw - 10, gy), -- 724
				0.75, -- 724
				Color( -- 724
					34, -- 724
					23, -- 724
					18, -- 724
					math.floor(110 * appear + 0.5) -- 724
				) -- 724
			) -- 724
			g = g + 1 -- 722
		end -- 722
	end -- 722
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
end -- 700
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
					local tx = x + 22 + t * 14 + shake -- 779
					local filled = t < count -- 780
					if mat == "bell_tally" or mat == "bell" then -- 780
						drawReloadPatternGlyph( -- 782
							uiInkDraw, -- 783
							tx, -- 784
							rowY, -- 785
							7.5, -- 786
							"echo", -- 787
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 788
							(filled and 0.96 or 0.38) * appear -- 789
						) -- 789
					else -- 789
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 792
						uiInkDraw:drawRect( -- 793
							Rect(tx - 4, rowY - 10, 8, 20), -- 794
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 795
							1, -- 796
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 797
						) -- 797
						if filled then -- 797
							uiInkDraw:drawSegment( -- 800
								Vec2(tx - 2, rowY + 3), -- 800
								Vec2(tx + 2, rowY + 3), -- 800
								0.9, -- 800
								toColor(PALETTE.xuanInk, 185 * appear) -- 800
							) -- 800
							uiInkDraw:drawSegment( -- 801
								Vec2(tx - 2, rowY - 3), -- 801
								Vec2(tx + 2, rowY - 3), -- 801
								0.9, -- 801
								toColor(PALETTE.xuanInk, 185 * appear) -- 801
							) -- 801
						end -- 801
					end -- 801
					t = t + 1 -- 778
				end -- 778
			end -- 778
			ctx.texts:put( -- 806
				"xs", -- 807
				materialLabel(mat), -- 808
				x + 86 + shake, -- 809
				rowY + 5, -- 810
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 811
				0, -- 812
				0.5, -- 813
				"Left", -- 814
				0.8, -- 815
				0.95 * appear, -- 816
				0.06 -- 817
			) -- 817
			ctx.texts:put( -- 819
				"xs", -- 820
				"存 " .. tostring(count), -- 821
				x + 86 + shake, -- 822
				rowY - 11, -- 823
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 824
				0, -- 825
				0.5, -- 826
				"Left", -- 827
				0.8, -- 828
				0.88 * appear, -- 829
				0.06 -- 830
			) -- 830
			i = i + 1 -- 764
		end -- 764
	end -- 764
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 835
	uiInkDraw:drawSegment( -- 836
		Vec2(x + 10, y + 32), -- 836
		Vec2(x + w - 10, y + 32), -- 836
		0.75, -- 836
		toColor(PALETTE.amberDim, 105 * appear) -- 836
	) -- 836
	ctx.texts:put( -- 837
		"xs", -- 837
		"现佩：" .. eqName, -- 837
		x + 12, -- 837
		y + 16, -- 837
		toColor(PALETTE.textMid), -- 837
		0, -- 837
		0.5, -- 837
		"Left", -- 837
		0.8, -- 837
		0.9 * appear, -- 837
		0.06 -- 837
	) -- 837
end -- 744
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 840
	local i = 0 -- 841
	do -- 841
		i = 0 -- 842
		while i < #bench.recipes do -- 842
			if bench.recipes[i + 1].id == weaponId then -- 842
				return bench.recipes[i + 1].name -- 844
			end -- 844
			i = i + 1 -- 842
		end -- 842
	end -- 842
	return "旧制鸟铳" -- 847
end -- 840
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 850
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 862
	local canCraft = not recipe.crafted and #missing == 0 -- 863
	local equipped = bench.equippedWeapon == recipe.id -- 864
	local isPending = self.pendingRecipeId == recipe.id -- 865
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 866
	if not uiArt:tryPlace( -- 866
		"ink_song_paper", -- 869
		"cb_card_" .. recipe.id, -- 869
		box.x + box.width * 0.5, -- 869
		box.y + box.height * 0.5, -- 869
		box.width, -- 869
		box.height, -- 869
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 869
	) then -- 869
		uiDraw:drawRect( -- 870
			box, -- 870
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 870
		) -- 870
	end -- 870
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 873
	drawFiligreeCorners( -- 876
		uiInkDraw, -- 876
		uiArt, -- 876
		"cb_cf_" .. recipe.id, -- 876
		box.x + 5, -- 876
		box.y + 5, -- 876
		box.width - 10, -- 876
		box.height - 10, -- 876
		borderCol, -- 876
		(selected and 0.88 or 0.46) * appear, -- 876
		18, -- 876
		true, -- 876
		2 -- 876
	) -- 876
	if selected then -- 876
		drawSilkRibbon( -- 879
			uiDraw, -- 879
			uiArt, -- 879
			"cb_sel_rib_" .. recipe.id, -- 879
			box.x + box.width * 0.5, -- 879
			box.y + box.height - 26, -- 879
			box.width - 14, -- 879
			30, -- 879
			PALETTE.amberDim, -- 879
			0.24 * appear, -- 879
			2 -- 879
		) -- 879
	end -- 879
	local topY = box.y + box.height - 26 -- 883
	drawBlossomDot( -- 884
		uiInkDraw, -- 884
		uiArt, -- 884
		"cb_dot_" .. recipe.id, -- 884
		box.x + 18, -- 884
		topY, -- 884
		selected and 11 or 7, -- 884
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 884
		0.92 * appear, -- 884
		3 -- 884
	) -- 884
	ctx.texts:put( -- 885
		"md", -- 885
		recipe.name, -- 885
		box.x + 30, -- 885
		topY, -- 885
		toColor(PALETTE.xuanInk), -- 885
		0, -- 885
		0.5, -- 885
		"Left", -- 885
		1.6, -- 885
		0.98 * appear, -- 885
		0 -- 885
	) -- 885
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 887
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 888
	ctx.texts:put( -- 889
		"xs", -- 889
		badge, -- 889
		box.x + box.width - 14, -- 889
		topY, -- 889
		toColor(badgeCol), -- 889
		1, -- 889
		0.5, -- 889
		"Right", -- 889
		1, -- 889
		0.94 * appear, -- 889
		0 -- 889
	) -- 889
	local miniCx = box.x + 46 -- 892
	local miniCy = box.y + box.height - 96 -- 893
	self:drawMiniReloadPreview( -- 894
		uiInkDraw, -- 894
		uiGlow, -- 894
		miniCx, -- 894
		miniCy, -- 894
		recipe.enhancedEffect, -- 894
		appear -- 894
	) -- 894
	local infoX = box.x + 90 -- 897
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 898
	ctx.texts:put( -- 899
		"xs", -- 899
		effTitle, -- 899
		infoX, -- 899
		box.y + box.height - 64, -- 899
		toColor(PALETTE.rouge), -- 899
		0, -- 899
		0.5, -- 899
		"Left", -- 899
		0.8, -- 899
		0.95 * appear, -- 899
		0 -- 899
	) -- 899
	local row = 0 -- 901
	for mat in pairs(recipe.cost) do -- 902
		local need = recipe.cost[mat] -- 903
		local have = bench.inventory[mat] or 0 -- 904
		local lack = not recipe.crafted and have < need -- 905
		local ry = box.y + box.height - 90 - row * 22 -- 906
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 907
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 908
		ctx.texts:put( -- 909
			"xs", -- 909
			text, -- 909
			infoX, -- 909
			ry, -- 909
			toColor(col), -- 909
			0, -- 909
			0.5, -- 909
			"Left", -- 909
			0.6, -- 909
			0.94 * appear, -- 909
			0 -- 909
		) -- 909
		row = row + 1 -- 910
	end -- 910
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 914
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 915
	local btnBg = equipped and Color( -- 918
		168, -- 919
		46, -- 919
		44, -- 919
		math.floor(32 * appear + 0.5) -- 919
	) or (selected and (canCraft or recipe.crafted) and Color( -- 919
		32, -- 921
		30, -- 921
		32, -- 921
		math.floor(218 * appear + 0.5) -- 921
	) or Color( -- 921
		32, -- 922
		30, -- 922
		32, -- 922
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 922
	)) -- 922
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 923
	uiInkDraw:drawRect( -- 926
		btnRect, -- 926
		btnBg, -- 926
		0.9, -- 926
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 926
	) -- 926
	ctx.texts:put( -- 927
		"sm", -- 928
		btnLabel, -- 929
		btnRect.x + btnRect.width * 0.5, -- 930
		btnRect.y + btnRect.height * 0.5, -- 931
		toColor(btnTextCol), -- 932
		0.5, -- 933
		0.5, -- 934
		"Center", -- 935
		1.6, -- 936
		0.96 * appear, -- 937
		0 -- 938
	) -- 938
end -- 850
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 943
	local step = 20 -- 951
	local samplePath = effect == "light" and ({ -- 952
		0, -- 952
		1, -- 952
		2, -- 952
		5, -- 952
		8 -- 952
	}) or (effect == "echo" and ({ -- 952
		0, -- 952
		1, -- 952
		4, -- 952
		5, -- 952
		8 -- 952
	}) or ({ -- 952
		0, -- 952
		3, -- 952
		6, -- 952
		7, -- 952
		8 -- 952
	})) -- 952
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 953
	uiInkDraw:drawRect( -- 956
		Rect(cx - 32, cy - 32, 64, 64), -- 956
		Color( -- 956
			224, -- 956
			218, -- 956
			206, -- 956
			math.floor(145 * appear + 0.5) -- 956
		), -- 956
		0.8, -- 956
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 956
	) -- 956
	local i = 0 -- 957
	do -- 957
		i = 0 -- 958
		while i < #RELOAD_GRID do -- 958
			local g = RELOAD_GRID[i + 1] -- 959
			local nx = cx + (g.col - 1) * step -- 960
			local ny = cy + (g.row - 1) * step -- 961
			uiInkDraw:drawDot( -- 962
				Vec2(nx, ny), -- 962
				1.8, -- 962
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 962
			) -- 962
			i = i + 1 -- 958
		end -- 958
	end -- 958
	do -- 958
		i = 0 -- 966
		while i < #samplePath - 1 do -- 966
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 967
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 968
			uiInkDraw:drawSegment( -- 969
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 970
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 971
				1.8, -- 972
				toColor(accent, 220 * appear) -- 973
			) -- 973
			i = i + 1 -- 966
		end -- 966
	end -- 966
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 978
	local kx = cx + (keyNode.col - 1) * step -- 979
	local ky = cy + (keyNode.row - 1) * step -- 980
	drawReloadPatternGlyph( -- 981
		uiInkDraw, -- 981
		kx, -- 981
		ky, -- 981
		7.5, -- 981
		effect, -- 981
		accent, -- 981
		appear -- 981
	) -- 981
	fillRadialGlow( -- 982
		uiGlow, -- 982
		kx, -- 982
		ky, -- 982
		14, -- 982
		14, -- 982
		toColor(PALETTE.amberCore, 45 * appear), -- 982
		Color(244, 234, 214, 0), -- 982
		10 -- 982
	) -- 982
end -- 943
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 986
	local prog = math.max( -- 993
		0, -- 993
		math.min( -- 993
			1, -- 993
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 993
		) -- 993
	) -- 993
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 994
	local cx = ctx.uiW * 0.5 -- 995
	local cy = ctx.uiH * 0.68 -- 996
	local w = 440 -- 997
	local h = 112 -- 998
	drawSilkVeil( -- 1000
		uiDraw, -- 1000
		uiArt, -- 1000
		"cb_handover_veil", -- 1000
		cx, -- 1000
		cy, -- 1000
		w + 80, -- 1000
		h + 28, -- 1000
		PALETTE.inkWash, -- 1000
		0.84 * fade, -- 1000
		0 -- 1000
	) -- 1000
	drawHairline( -- 1001
		uiInkDraw, -- 1001
		uiArt, -- 1001
		"cb_handover_top", -- 1001
		cx, -- 1001
		cy + h * 0.48, -- 1001
		w - 30, -- 1001
		PALETTE.amber, -- 1001
		0.58 * fade, -- 1001
		true, -- 1001
		2 -- 1001
	) -- 1001
	local passK = math.min(1, prog / 0.38) -- 1004
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 1005
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 1006
	local a245 = math.floor(245 * fade + 0.5) -- 1007
	local a235 = math.floor(235 * fade + 0.5) -- 1008
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 1011
	local childHandY = cy - 4 + gripLift * 0.2 -- 1012
	uiInkDraw:drawPolygon( -- 1013
		{ -- 1013
			Vec2(cx - 148, cy - 22), -- 1014
			Vec2(cx - 146, cy - 8), -- 1015
			Vec2(childHandX - 10, childHandY + 4), -- 1016
			Vec2(childHandX - 10, childHandY - 6) -- 1017
		}, -- 1017
		Color(164, 78, 54, a235), -- 1018
		1, -- 1018
		Color(52, 28, 22, a235) -- 1018
	) -- 1018
	uiInkDraw:drawSegment( -- 1019
		Vec2(childHandX - 11, childHandY + 4), -- 1019
		Vec2(childHandX - 11, childHandY - 6), -- 1019
		2, -- 1019
		Color(204, 174, 122, a245) -- 1019
	) -- 1019
	uiInkDraw:drawEllipse( -- 1020
		Vec2(childHandX, childHandY - 1), -- 1020
		6.2, -- 1020
		4.4, -- 1020
		Color(238, 212, 182, a245) -- 1020
	) -- 1020
	local solHandX = cx + 82 - math.min( -- 1023
		1, -- 1023
		math.max(0, (prog - 0.18) / 0.28) -- 1023
	) * 42 -- 1023
	local solHandY = cy - 4 + gripLift -- 1024
	uiInkDraw:drawPolygon( -- 1025
		{ -- 1025
			Vec2(cx + 154, cy - 18), -- 1026
			Vec2(cx + 154, cy - 1), -- 1027
			Vec2(solHandX + 12, solHandY + 6), -- 1028
			Vec2(solHandX + 12, solHandY - 7) -- 1029
		}, -- 1029
		toColor(CUFF_PALETTE.indigoBase, a245), -- 1030
		1, -- 1030
		toColor(CUFF_PALETTE.indigoShadow, a245) -- 1030
	) -- 1030
	local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1032
	uiInkDraw:drawSegment( -- 1033
		Vec2(solHandX + 16, solHandY - 5), -- 1033
		Vec2(solHandX + 19, solHandY + 4), -- 1033
		1.5, -- 1033
		mendCol -- 1033
	) -- 1033
	uiInkDraw:drawSegment( -- 1034
		Vec2(solHandX + 21, solHandY - 5), -- 1034
		Vec2(solHandX + 24, solHandY + 4), -- 1034
		1.5, -- 1034
		mendCol -- 1034
	) -- 1034
	uiInkDraw:drawSegment( -- 1035
		Vec2(solHandX + 26, solHandY - 5), -- 1035
		Vec2(solHandX + 29, solHandY + 4), -- 1035
		1.5, -- 1035
		mendCol -- 1035
	) -- 1035
	uiInkDraw:drawEllipse( -- 1036
		Vec2(solHandX, solHandY), -- 1036
		6.8, -- 1036
		5, -- 1036
		toColor(CUFF_PALETTE.skinBase, a245) -- 1036
	) -- 1036
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1039
	local gunY = cy + 3 + gripLift -- 1040
	uiInkDraw:drawPolygon( -- 1042
		{ -- 1042
			Vec2(gunX - 42, gunY - 8), -- 1043
			Vec2(gunX - 12, gunY - 3), -- 1044
			Vec2(gunX + 16, gunY + 1), -- 1045
			Vec2(gunX + 16, gunY + 6), -- 1046
			Vec2(gunX - 16, gunY + 3), -- 1047
			Vec2(gunX - 40, gunY + 1) -- 1048
		}, -- 1048
		Color(108, 72, 48, a245), -- 1049
		1, -- 1049
		Color(46, 30, 20, a245) -- 1049
	) -- 1049
	uiInkDraw:drawSegment( -- 1051
		Vec2(gunX - 6, gunY + 4), -- 1051
		Vec2(gunX + 56, gunY + 8), -- 1051
		2.8, -- 1051
		Color(152, 148, 138, a245) -- 1051
	) -- 1051
	uiInkDraw:drawSegment( -- 1052
		Vec2(gunX + 14, gunY + 1), -- 1052
		Vec2(gunX + 14, gunY + 8), -- 1052
		2, -- 1052
		Color(198, 166, 112, a245) -- 1052
	) -- 1052
	uiInkDraw:drawSegment( -- 1053
		Vec2(gunX + 36, gunY + 3), -- 1053
		Vec2(gunX + 36, gunY + 9), -- 1053
		1.6, -- 1053
		Color(198, 166, 112, a245) -- 1053
	) -- 1053
	drawReloadPatternGlyph( -- 1054
		uiInkDraw, -- 1054
		gunX + 2, -- 1054
		gunY + 21, -- 1054
		8.5, -- 1054
		self.handoverEffect, -- 1054
		PALETTE.amberCore, -- 1054
		fade -- 1054
	) -- 1054
	fillRadialGlow( -- 1055
		uiGlow, -- 1055
		gunX + 4, -- 1055
		gunY + 4, -- 1055
		48, -- 1055
		22, -- 1055
		toColor(PALETTE.amberCore, 52 * fade), -- 1055
		Color(244, 234, 214, 0), -- 1055
		12 -- 1055
	) -- 1055
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1057
	ctx.texts:put( -- 1060
		"xs", -- 1060
		caption, -- 1060
		cx, -- 1060
		cy - 34, -- 1060
		toColor(PALETTE.amberCore), -- 1060
		0.5, -- 1060
		0.5, -- 1060
		"Center", -- 1060
		1.4, -- 1060
		0.94 * fade, -- 1060
		0.08 -- 1060
	) -- 1060
end -- 986
function ____exports.createCraftBenchPlugin(contract) -- 1064
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1065
end -- 1064
return ____exports -- 1064