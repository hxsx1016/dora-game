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
	if self.lastSnapshotBench ~= nil then -- 229
		for k in pairs(self.lastSnapshotBench.inventory) do -- 230
			inv[k] = self.lastSnapshotBench.inventory[k] -- 231
		end -- 231
		local i = 0 -- 233
		do -- 233
			i = 0 -- 234
			while i < #self.lastSnapshotBench.recipes do -- 234
				if self.lastSnapshotBench.recipes[i + 1].crafted then -- 235
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
	if type(Keyboard) ~= "nil" then -- 288
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 289
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 290
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 291
		self.prevCancel = Keyboard:isKeyPressed("Escape") or Keyboard:isKeyPressed("BackSpace") -- 292
	end -- 292
end -- 285
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 296
	local contract = resolveRuntimeContract(self.injectedContract) -- 297
	if contract ~= nil then -- 298
		return contract:submitIntent(p, intent) -- 299
	end -- 299
	return dispatchIntentFallback(p, intent) -- 301
end -- 296
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 304
	local uiW = ctx.uiW -- 311
	local uiH = ctx.uiH -- 312
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 313
	local touchMode = ctx.input:isTouchMode() -- 314
	local count = math.max(1, recipeCount) -- 315
	local wantW = count >= 3 and 840 or 692 -- 316
	local benchW = math.min(uiW - 44 - safe.left - safe.right, wantW) -- 317
	local benchH = 290 -- 318
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 320
	local minX = 24 + safe.left -- 321
	local maxX = math.max(minX, uiW - benchW - 24 - safe.right) -- 322
	local benchX = count >= 3 and math.max(minX, (uiW - benchW) * 0.5) or (soldierUiX < uiW * 0.52 and maxX or minX) -- 323
	local benchY = math.max( -- 326
		46 + safe.bottom, -- 326
		math.min(uiH * 0.1 + safe.bottom, 66 + safe.bottom) -- 326
	) -- 326
	local matW = count >= 3 and 168 or 196 -- 327
	local cardsAreaX = benchX + matW + 16 -- 329
	local cardsAreaW = benchW - matW - 30 -- 330
	local gap = count >= 3 and 10 or 14 -- 331
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 332
	local cardH = benchH - 72 -- 333
	local cardY = benchY + 20 -- 334
	self.cardBoxes = {} -- 336
	local i = 0 -- 337
	do -- 337
		i = 0 -- 338
		while i < count do -- 338
			local ____self_cardBoxes_3 = self.cardBoxes -- 339
			____self_cardBoxes_3[#____self_cardBoxes_3 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 339
			i = i + 1 -- 338
		end -- 338
	end -- 338
	local closeW = touchMode and 88 or 76 -- 341
	local closeH = touchMode and 32 or 26 -- 342
	self.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH) -- 343
	return { -- 344
		benchX = benchX, -- 344
		benchY = benchY, -- 344
		benchW = benchW, -- 344
		benchH = benchH, -- 344
		matW = matW -- 344
	} -- 344
end -- 304
function CraftBenchPlugin.prototype.update(self, ctx) -- 347
	local bench = ctx.view.craftBench -- 348
	self.lastSnapshotBench = bench -- 349
	if ctx.paused then -- 352
		self:resetInputEdges(ctx.input:isTouchMode()) -- 353
		return -- 354
	end -- 354
	local udt = math.max(0, ctx.uiDt) -- 357
	self.animTime = self.animTime + udt -- 358
	if self.missingFlashT > 0 then -- 360
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 361
	end -- 361
	if self.handoverRemaining > 0 then -- 363
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 364
	end -- 364
	self:detectCraftCompletion(ctx, bench) -- 368
	if bench.active and not self.wasActive then -- 370
		self.openAnimT = 0 -- 371
		self.pendingRecipeId = "" -- 372
		self.missingFlashT = 0 -- 373
		self.missingList = {} -- 374
		self.selectedIdx = math.max( -- 375
			0, -- 375
			math.min( -- 375
				math.max(0, #bench.recipes - 1), -- 375
				self.selectedIdx -- 375
			) -- 375
		) -- 375
		self:resetInputEdges(ctx.input:isTouchMode()) -- 376
	elseif not bench.active and self.wasActive then -- 377
		self.pendingRecipeId = "" -- 378
		self.missingFlashT = 0 -- 379
	end -- 379
	self.wasActive = bench.active -- 381
	if not bench.active then -- 383
		self.pendingSimInput = nil -- 384
		return -- 385
	end -- 385
	self.openAnimT = math.min(1, self.openAnimT + udt / 0.22) -- 388
	self:computeLayout(ctx, #bench.recipes) -- 389
	self:processInputs(ctx, bench) -- 392
end -- 347
function CraftBenchPlugin.prototype.detectCraftCompletion(self, ctx, bench) -- 395
	local newlyCrafted -- 396
	local i = 0 -- 397
	do -- 397
		i = 0 -- 398
		while i < #bench.recipes do -- 398
			local r = bench.recipes[i + 1] -- 399
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 400
				newlyCrafted = r -- 401
			end -- 401
			self.prevCraftedMap[r.id] = r.crafted -- 403
			i = i + 1 -- 398
		end -- 398
	end -- 398
	do -- 398
		i = 0 -- 407
		while i < #ctx.events.rawEvents do -- 407
			local ename = ctx.events.rawEvents[i + 1].name -- 408
			if ename == "benchRejected" then -- 409
				self.pendingRecipeId = "" -- 410
				self.missingFlashT = 0.45 -- 411
			end -- 411
			i = i + 1 -- 407
		end -- 407
	end -- 407
	if newlyCrafted ~= nil then -- 415
		local ____temp_4 -- 416
		if self.pendingRecipeId == newlyCrafted.id then -- 416
			____temp_4 = self.pendingFirstCraftAtSubmit -- 417
		else -- 417
			____temp_4 = bench.justCraftedTimer >= 0.72 -- 418
		end -- 418
		local isFirst = ____temp_4 -- 416
		self.pendingRecipeId = "" -- 419
		self.handoverWeaponId = newlyCrafted.id -- 420
		self.handoverWeaponName = newlyCrafted.name -- 421
		self.handoverEffect = newlyCrafted.enhancedEffect -- 422
		self.handoverDuration = isFirst and 1 or 0.45 -- 423
		self.handoverRemaining = self.handoverDuration -- 424
		local hasBackendDone = false -- 426
		do -- 426
			i = 0 -- 427
			while i < #ctx.events.rawEvents do -- 427
				local ename = ctx.events.rawEvents[i + 1].name -- 428
				if ename == "craftDone" or ename == "benchCraft" then -- 429
					hasBackendDone = true -- 430
					break -- 431
				end -- 431
				i = i + 1 -- 427
			end -- 427
		end -- 427
		if not hasBackendDone then -- 434
			ctx.audio:playOnce( -- 435
				(("fe02:craft_done:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. newlyCrafted.id, -- 436
				"sfx", -- 437
				"assets/audio/combat/craft_done.wav", -- 438
				0.88, -- 439
				"craft:done:" .. newlyCrafted.id, -- 440
				ctx.p.ticks -- 441
			) -- 441
		end -- 441
	end -- 441
end -- 395
function CraftBenchPlugin.prototype.processInputs(self, ctx, bench) -- 447
	local sim = self.pendingSimInput -- 448
	self.pendingSimInput = nil -- 449
	local touchMode = ctx.input:isTouchMode() -- 451
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 452
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 454
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 457
	local ____temp_14 -- 460
	if (sim and sim.pointerX) ~= nil then -- 460
		____temp_14 = true -- 461
	else -- 461
		local ____useUiPtr_13 -- 462
		if useUiPtr then -- 462
			____useUiPtr_13 = ctx.input.uiInside -- 462
		else -- 462
			____useUiPtr_13 = ctx.input.inside -- 462
		end -- 462
		____temp_14 = ____useUiPtr_13 -- 462
	end -- 462
	local inside = ____temp_14 -- 460
	local ____temp_17 -- 463
	if (sim and sim.click) ~= nil then -- 463
		____temp_17 = sim.click -- 464
	else -- 464
		____temp_17 = ctx.input.uiHeld or ctx.input.fire.held or not touchMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 465
	end -- 465
	local leftHeld = ____temp_17 -- 463
	local ____temp_20 -- 466
	if (sim and sim.rightClick) ~= nil then -- 466
		____temp_20 = sim.rightClick -- 467
	else -- 467
		____temp_20 = ctx.input.uiRightPressed or not touchMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 468
	end -- 468
	local rightHeld = ____temp_20 -- 466
	local ____temp_23 -- 470
	if (sim and sim.click) ~= nil then -- 470
		____temp_23 = sim.click -- 471
	else -- 471
		____temp_23 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 472
	end -- 472
	local click = ____temp_23 -- 470
	local ____temp_26 -- 473
	if (sim and sim.rightClick) ~= nil then -- 473
		____temp_26 = sim.rightClick -- 474
	else -- 474
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 475
	end -- 475
	local rightClick = ____temp_26 -- 473
	self.prevLeft = leftHeld -- 476
	self.prevRight = rightHeld -- 477
	local move = 0 -- 479
	local confirm = false -- 480
	local cancel = false -- 481
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 483
		move = sim.move or 0 -- 484
		confirm = sim.confirm == true -- 485
		cancel = sim.cancel == true -- 486
	else -- 486
		if type(Keyboard) ~= "nil" then -- 488
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 489
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 490
			local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 491
			local cc = Keyboard:isKeyPressed("BackSpace") -- 492
			if lk and not self.prevLeftKey then -- 493
				move = move - 1 -- 493
			end -- 493
			if rk and not self.prevRightKey then -- 494
				move = move + 1 -- 494
			end -- 494
			confirm = cf and not self.prevConfirm -- 495
			cancel = cc and not self.prevCancel -- 496
			self.prevLeftKey = lk -- 497
			self.prevRightKey = rk -- 498
			self.prevConfirm = cf -- 499
			self.prevCancel = cc -- 500
		end -- 500
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 502
			move = move - 1 -- 502
		end -- 502
		if ctx.input.navRight or ctx.input.navNextTab then -- 503
			move = move + 1 -- 503
		end -- 503
		if ctx.input.navConfirm then -- 504
			confirm = true -- 504
		end -- 504
		if ctx.input.navBack then -- 505
			cancel = true -- 505
		end -- 505
	end -- 505
	local ptr = Vec2(ptrX, ptrY) -- 509
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 510
	if cancel or rightClick or click and hitClose then -- 511
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 512
		return -- 513
	end -- 513
	local count = #bench.recipes -- 516
	if count == 0 then -- 517
		return -- 518
	end -- 518
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 521
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 522
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 523
	local hitCard = -1 -- 525
	if inside then -- 526
		local i = 0 -- 527
		do -- 527
			i = 0 -- 528
			while i < #self.cardBoxes do -- 528
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 529
					hitCard = i -- 530
					break -- 531
				end -- 531
				i = i + 1 -- 528
			end -- 528
		end -- 528
	end -- 528
	if move ~= 0 then -- 536
		self.pointerActive = false -- 537
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 538
	elseif pointerMoved and hitCard >= 0 then -- 539
		self.pointerActive = true -- 540
		self.selectedIdx = hitCard -- 541
	end -- 541
	local triggerConfirm = confirm or click and hitCard >= 0 -- 544
	if not triggerConfirm then -- 545
		return -- 546
	end -- 546
	if click and hitCard >= 0 then -- 548
		self.selectedIdx = hitCard -- 549
	end -- 549
	if self.handoverRemaining > 0.05 then -- 553
		return -- 554
	end -- 554
	local recipe = bench.recipes[self.selectedIdx + 1] -- 557
	if recipe == nil then -- 558
		return -- 559
	end -- 559
	if recipe.crafted then -- 562
		if bench.equippedWeapon ~= recipe.id then -- 563
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 564
		end -- 564
		return -- 566
	end -- 566
	if self.pendingRecipeId == recipe.id then -- 570
		return -- 571
	end -- 571
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 575
	if #missing > 0 then -- 576
		self.missingList = missing -- 577
		self.missingFlashT = 0.55 -- 578
		ctx.audio:playOnce( -- 579
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 580
			"sfx", -- 581
			"assets/audio/combat/craft_insufficient.wav", -- 582
			0.76, -- 583
			"craft:insufficient:" .. recipe.id, -- 584
			ctx.p.ticks -- 585
		) -- 585
		return -- 587
	end -- 587
	self.missingList = {} -- 590
	self.missingFlashT = 0 -- 591
	self.pendingRecipeId = recipe.id -- 592
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 593
	self.requestSeq = self.requestSeq + 1 -- 594
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 595
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 596
	if not accepted then -- 601
		self.pendingRecipeId = "" -- 602
	end -- 602
end -- 447
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 606
	local bench = ctx.view.craftBench -- 613
	if not bench.active and self.handoverRemaining <= 0.01 then -- 614
		return false -- 615
	end -- 615
	if not bench.active then -- 619
		self:drawHandoverOverlay( -- 620
			uiDraw, -- 620
			uiInkDraw, -- 620
			uiArt, -- 620
			uiGlow, -- 620
			ctx -- 620
		) -- 620
		return false -- 621
	end -- 621
	local appear = math.min(1, self.openAnimT) -- 624
	local layout = self:computeLayout(ctx, #bench.recipes) -- 625
	local bx = layout.benchX -- 626
	local by = layout.benchY -- 627
	local bw = layout.benchW -- 628
	local bh = layout.benchH -- 629
	fillVGradRect( -- 632
		uiDraw, -- 633
		0, -- 634
		0, -- 635
		ctx.uiW, -- 636
		by + bh + 64, -- 637
		Color( -- 638
			12, -- 638
			10, -- 638
			10, -- 638
			math.floor(168 * appear + 0.5) -- 638
		), -- 638
		Color(12, 10, 10, 0) -- 639
	) -- 639
	self:drawWoodenBenchBody( -- 643
		uiDraw, -- 643
		uiInkDraw, -- 643
		uiArt, -- 643
		uiGlow, -- 643
		bx, -- 643
		by, -- 643
		bw, -- 643
		bh, -- 643
		appear -- 643
	) -- 643
	ctx.texts:put( -- 646
		"md", -- 646
		"安全工台 · 改制鸟铳", -- 646
		bx + 54, -- 646
		by + bh - 26, -- 646
		toColor(PALETTE.amberCore), -- 646
		0, -- 646
		0.5, -- 646
		"Left", -- 646
		2, -- 646
		0.96 * appear, -- 646
		0.08 -- 646
	) -- 646
	drawHairline( -- 647
		uiInkDraw, -- 647
		uiArt, -- 647
		"cb_head_line", -- 647
		bx + bw * 0.5, -- 647
		by + bh - 46, -- 647
		bw - 36, -- 647
		PALETTE.amberDim, -- 647
		0.55 * appear, -- 647
		false, -- 647
		2 -- 647
	) -- 647
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 649
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 650
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 651
	uiInkDraw:drawRect( -- 652
		self.closeBox, -- 653
		Color( -- 654
			24, -- 654
			18, -- 654
			16, -- 654
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 654
		), -- 654
		0.9, -- 655
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 656
	) -- 656
	local closeText = ctx.input:isGamepadMode() and keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 658
	ctx.texts:put( -- 661
		"xs", -- 662
		closeText, -- 663
		self.closeBox.x + self.closeBox.width * 0.5, -- 664
		self.closeBox.y + self.closeBox.height * 0.5, -- 665
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 666
		0.5, -- 667
		0.5, -- 668
		"Center", -- 669
		1.4, -- 670
		0.95 * appear, -- 671
		0.06 -- 672
	) -- 672
	self:drawTableMaterials( -- 676
		uiDraw, -- 676
		uiInkDraw, -- 676
		uiArt, -- 676
		ctx, -- 676
		bench, -- 676
		bx + 18, -- 676
		by + 22, -- 676
		layout.matW - 14, -- 676
		bh - 76, -- 676
		appear -- 676
	) -- 676
	local i = 0 -- 679
	do -- 679
		i = 0 -- 680
		while i < #bench.recipes and i < #self.cardBoxes do -- 680
			self:drawRecipeCard( -- 681
				uiDraw, -- 682
				uiInkDraw, -- 683
				uiArt, -- 684
				uiGlow, -- 685
				ctx, -- 686
				bench, -- 687
				bench.recipes[i + 1], -- 688
				self.cardBoxes[i + 1], -- 689
				i == self.selectedIdx, -- 690
				appear -- 691
			) -- 691
			i = i + 1 -- 680
		end -- 680
	end -- 680
	if self.handoverRemaining > 0.01 then -- 696
		self:drawHandoverOverlay( -- 697
			uiDraw, -- 697
			uiInkDraw, -- 697
			uiArt, -- 697
			uiGlow, -- 697
			ctx -- 697
		) -- 697
	end -- 697
	return true -- 700
end -- 606
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 703
	uiDraw:drawRect( -- 715
		Rect(bx, by, bw, bh), -- 715
		Color( -- 715
			WOOD_BODY.r, -- 715
			WOOD_BODY.g, -- 715
			WOOD_BODY.b, -- 715
			math.floor(244 * appear + 0.5) -- 715
		), -- 715
		1.4, -- 715
		toColor(PALETTE.amberDim, 190 * appear) -- 715
	) -- 715
	uiDraw:drawRect( -- 717
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 717
		Color( -- 717
			WOOD_TOP.r, -- 717
			WOOD_TOP.g, -- 717
			WOOD_TOP.b, -- 717
			math.floor(250 * appear + 0.5) -- 717
		), -- 717
		1, -- 717
		WOOD_EDGE -- 717
	) -- 717
	uiInkDraw:drawSegment( -- 718
		Vec2(bx - 6, by + bh + 3), -- 718
		Vec2(bx + bw + 6, by + bh + 3), -- 718
		1.2, -- 718
		toColor(PALETTE.amberCore, 115 * appear) -- 718
	) -- 718
	uiDraw:drawRect( -- 720
		Rect(bx + 18, by - 26, 22, 26), -- 720
		Color( -- 720
			WOOD_DARK.r, -- 720
			WOOD_DARK.g, -- 720
			WOOD_DARK.b, -- 720
			math.floor(235 * appear + 0.5) -- 720
		) -- 720
	) -- 720
	uiDraw:drawRect( -- 721
		Rect(bx + bw - 40, by - 26, 22, 26), -- 721
		Color( -- 721
			WOOD_DARK.r, -- 721
			WOOD_DARK.g, -- 721
			WOOD_DARK.b, -- 721
			math.floor(235 * appear + 0.5) -- 721
		) -- 721
	) -- 721
	local g = 1 -- 724
	do -- 724
		g = 1 -- 725
		while g <= 4 do -- 725
			local gy = by + (bh - 50) * (g / 5) -- 726
			uiDraw:drawSegment( -- 727
				Vec2(bx + 10, gy), -- 727
				Vec2(bx + bw - 10, gy), -- 727
				0.75, -- 727
				Color( -- 727
					34, -- 727
					23, -- 727
					18, -- 727
					math.floor(110 * appear + 0.5) -- 727
				) -- 727
			) -- 727
			g = g + 1 -- 725
		end -- 725
	end -- 725
	local lx = bx + 28 -- 731
	local ly = by + bh - 24 -- 732
	uiArt:tryPlace( -- 733
		"prop_lantern", -- 733
		"cb_lantern", -- 733
		lx, -- 733
		ly, -- 733
		20, -- 733
		26, -- 733
		{opacity = 0.94 * appear, layer = 4} -- 733
	) -- 733
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 734
	fillRadialGlow( -- 735
		uiGlow, -- 736
		lx + 10, -- 737
		ly - 10, -- 738
		260 * pulse, -- 739
		180 * pulse, -- 740
		Color( -- 741
			238, -- 741
			198, -- 741
			128, -- 741
			math.floor(38 * appear + 0.5) -- 741
		), -- 741
		Color(238, 180, 92, 0), -- 742
		16 -- 743
	) -- 743
end -- 703
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 747
	uiDraw:drawRect( -- 759
		Rect(x, y, w, h), -- 759
		Color( -- 759
			26, -- 759
			20, -- 759
			17, -- 759
			math.floor(188 * appear + 0.5) -- 759
		), -- 759
		0.9, -- 759
		toColor(PALETTE.amberDim, 130 * appear) -- 759
	) -- 759
	drawFiligreeCorners( -- 760
		uiInkDraw, -- 760
		uiArt, -- 760
		"cb_mat_frame", -- 760
		x + 3, -- 760
		y + 3, -- 760
		w - 6, -- 760
		h - 6, -- 760
		PALETTE.amberDim, -- 760
		0.48 * appear, -- 760
		16, -- 760
		false, -- 760
		2 -- 760
	) -- 760
	ctx.texts:put( -- 762
		"xs", -- 762
		"案边持有", -- 762
		x + 12, -- 762
		y + h - 18, -- 762
		toColor(PALETTE.amberCore), -- 762
		0, -- 762
		0.5, -- 762
		"Left", -- 762
		1.4, -- 762
		0.92 * appear, -- 762
		0.06 -- 762
	) -- 762
	uiInkDraw:drawSegment( -- 763
		Vec2(x + 10, y + h - 32), -- 763
		Vec2(x + w - 10, y + h - 32), -- 763
		0.75, -- 763
		toColor(PALETTE.amberDim, 115 * appear) -- 763
	) -- 763
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 765
	local i = 0 -- 766
	do -- 766
		i = 0 -- 767
		while i < #keys and i < 4 do -- 767
			local mat = keys[i + 1] -- 768
			local count = bench.inventory[mat] or 0 -- 769
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 770
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 771
			local rowY = y + h - 62 - i * 48 -- 772
			if isMissing then -- 774
				uiDraw:drawRect( -- 775
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 775
					toColor(PALETTE.rougeSoft, 145 * appear), -- 775
					1, -- 775
					toColor(PALETTE.crimsonCore, 220 * appear) -- 775
				) -- 775
			end -- 775
			local shown = math.max( -- 779
				1, -- 779
				math.min(4, count) -- 779
			) -- 779
			local t = 0 -- 780
			do -- 780
				t = 0 -- 781
				while t < shown do -- 781
					local tx = x + 22 + t * 14 + shake -- 782
					local filled = t < count -- 783
					if mat == "bell_tally" or mat == "bell" then -- 784
						drawReloadPatternGlyph( -- 785
							uiInkDraw, -- 786
							tx, -- 787
							rowY, -- 788
							7.5, -- 789
							"echo", -- 790
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 791
							(filled and 0.96 or 0.38) * appear -- 792
						) -- 792
					else -- 792
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 795
						uiInkDraw:drawRect( -- 796
							Rect(tx - 4, rowY - 10, 8, 20), -- 797
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 798
							1, -- 799
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 800
						) -- 800
						if filled then -- 802
							uiInkDraw:drawSegment( -- 803
								Vec2(tx - 2, rowY + 3), -- 803
								Vec2(tx + 2, rowY + 3), -- 803
								0.9, -- 803
								toColor(PALETTE.xuanInk, 185 * appear) -- 803
							) -- 803
							uiInkDraw:drawSegment( -- 804
								Vec2(tx - 2, rowY - 3), -- 804
								Vec2(tx + 2, rowY - 3), -- 804
								0.9, -- 804
								toColor(PALETTE.xuanInk, 185 * appear) -- 804
							) -- 804
						end -- 804
					end -- 804
					t = t + 1 -- 781
				end -- 781
			end -- 781
			ctx.texts:put( -- 809
				"xs", -- 810
				materialLabel(mat), -- 811
				x + 86 + shake, -- 812
				rowY + 5, -- 813
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 814
				0, -- 815
				0.5, -- 816
				"Left", -- 817
				0.8, -- 818
				0.95 * appear, -- 819
				0.06 -- 820
			) -- 820
			ctx.texts:put( -- 822
				"xs", -- 823
				"存 " .. tostring(count), -- 824
				x + 86 + shake, -- 825
				rowY - 11, -- 826
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 827
				0, -- 828
				0.5, -- 829
				"Left", -- 830
				0.8, -- 831
				0.88 * appear, -- 832
				0.06 -- 833
			) -- 833
			i = i + 1 -- 767
		end -- 767
	end -- 767
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 838
	uiInkDraw:drawSegment( -- 839
		Vec2(x + 10, y + 32), -- 839
		Vec2(x + w - 10, y + 32), -- 839
		0.75, -- 839
		toColor(PALETTE.amberDim, 105 * appear) -- 839
	) -- 839
	ctx.texts:put( -- 840
		"xs", -- 840
		"现佩：" .. eqName, -- 840
		x + 12, -- 840
		y + 16, -- 840
		toColor(PALETTE.textMid), -- 840
		0, -- 840
		0.5, -- 840
		"Left", -- 840
		0.8, -- 840
		0.9 * appear, -- 840
		0.06 -- 840
	) -- 840
end -- 747
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 843
	local i = 0 -- 844
	do -- 844
		i = 0 -- 845
		while i < #bench.recipes do -- 845
			if bench.recipes[i + 1].id == weaponId then -- 846
				return bench.recipes[i + 1].name -- 847
			end -- 847
			i = i + 1 -- 845
		end -- 845
	end -- 845
	return "旧制鸟铳" -- 850
end -- 843
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 853
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 865
	local canCraft = not recipe.crafted and #missing == 0 -- 866
	local equipped = bench.equippedWeapon == recipe.id -- 867
	local isPending = self.pendingRecipeId == recipe.id -- 868
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 869
	if not uiArt:tryPlace( -- 872
		"ink_song_paper", -- 872
		"cb_card_" .. recipe.id, -- 872
		box.x + box.width * 0.5, -- 872
		box.y + box.height * 0.5, -- 872
		box.width, -- 872
		box.height, -- 872
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 872
	) then -- 872
		uiDraw:drawRect( -- 873
			box, -- 873
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 873
		) -- 873
	end -- 873
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 876
	drawFiligreeCorners( -- 879
		uiInkDraw, -- 879
		uiArt, -- 879
		"cb_cf_" .. recipe.id, -- 879
		box.x + 5, -- 879
		box.y + 5, -- 879
		box.width - 10, -- 879
		box.height - 10, -- 879
		borderCol, -- 879
		(selected and 0.88 or 0.46) * appear, -- 879
		18, -- 879
		true, -- 879
		2 -- 879
	) -- 879
	if selected then -- 881
		drawSilkRibbon( -- 882
			uiDraw, -- 882
			uiArt, -- 882
			"cb_sel_rib_" .. recipe.id, -- 882
			box.x + box.width * 0.5, -- 882
			box.y + box.height - 26, -- 882
			box.width - 14, -- 882
			30, -- 882
			PALETTE.amberDim, -- 882
			0.24 * appear, -- 882
			2 -- 882
		) -- 882
	end -- 882
	local topY = box.y + box.height - 26 -- 886
	drawBlossomDot( -- 887
		uiInkDraw, -- 887
		uiArt, -- 887
		"cb_dot_" .. recipe.id, -- 887
		box.x + 18, -- 887
		topY, -- 887
		selected and 11 or 7, -- 887
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 887
		0.92 * appear, -- 887
		3 -- 887
	) -- 887
	ctx.texts:put( -- 888
		"md", -- 888
		recipe.name, -- 888
		box.x + 30, -- 888
		topY, -- 888
		toColor(PALETTE.xuanInk), -- 888
		0, -- 888
		0.5, -- 888
		"Left", -- 888
		1.6, -- 888
		0.98 * appear, -- 888
		0 -- 888
	) -- 888
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 890
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 891
	ctx.texts:put( -- 892
		"xs", -- 892
		badge, -- 892
		box.x + box.width - 14, -- 892
		topY, -- 892
		toColor(badgeCol), -- 892
		1, -- 892
		0.5, -- 892
		"Right", -- 892
		1, -- 892
		0.94 * appear, -- 892
		0 -- 892
	) -- 892
	local narrow = box.width < 195 -- 895
	local miniCx = box.x + (narrow and 36 or 46) -- 896
	local miniCy = box.y + box.height - 96 -- 897
	self:drawMiniReloadPreview( -- 898
		uiInkDraw, -- 898
		uiGlow, -- 898
		miniCx, -- 898
		miniCy, -- 898
		recipe.enhancedEffect, -- 898
		appear -- 898
	) -- 898
	local infoX = box.x + (narrow and 72 or 90) -- 901
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 902
	ctx.texts:put( -- 903
		"xs", -- 903
		effTitle, -- 903
		infoX, -- 903
		box.y + box.height - 64, -- 903
		toColor(PALETTE.rouge), -- 903
		0, -- 903
		0.5, -- 903
		"Left", -- 903
		narrow and 0.3 or 0.8, -- 903
		0.95 * appear, -- 903
		0 -- 903
	) -- 903
	local row = 0 -- 905
	for mat in pairs(recipe.cost) do -- 906
		local need = recipe.cost[mat] -- 907
		local have = bench.inventory[mat] or 0 -- 908
		local lack = not recipe.crafted and have < need -- 909
		local ry = box.y + box.height - 90 - row * 22 -- 910
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 911
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 912
		ctx.texts:put( -- 913
			"xs", -- 913
			text, -- 913
			infoX, -- 913
			ry, -- 913
			toColor(col), -- 913
			0, -- 913
			0.5, -- 913
			"Left", -- 913
			0.6, -- 913
			0.94 * appear, -- 913
			0 -- 913
		) -- 913
		row = row + 1 -- 914
	end -- 914
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 918
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 919
	local btnBg = equipped and Color( -- 922
		168, -- 923
		46, -- 923
		44, -- 923
		math.floor(32 * appear + 0.5) -- 923
	) or (selected and (canCraft or recipe.crafted) and Color( -- 924
		32, -- 925
		30, -- 925
		32, -- 925
		math.floor(218 * appear + 0.5) -- 925
	) or Color( -- 926
		32, -- 926
		30, -- 926
		32, -- 926
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 926
	)) -- 926
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 927
	uiInkDraw:drawRect( -- 930
		btnRect, -- 930
		btnBg, -- 930
		0.9, -- 930
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 930
	) -- 930
	ctx.texts:put( -- 931
		"sm", -- 932
		btnLabel, -- 933
		btnRect.x + btnRect.width * 0.5, -- 934
		btnRect.y + btnRect.height * 0.5, -- 935
		toColor(btnTextCol), -- 936
		0.5, -- 937
		0.5, -- 938
		"Center", -- 939
		1.6, -- 940
		0.96 * appear, -- 941
		0 -- 942
	) -- 942
end -- 853
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 947
	local step = 20 -- 955
	local samplePath = effect == "light" and ({ -- 956
		0, -- 956
		1, -- 956
		2, -- 956
		5, -- 956
		8 -- 956
	}) or (effect == "echo" and ({ -- 956
		0, -- 956
		1, -- 956
		4, -- 956
		5, -- 956
		8 -- 956
	}) or ({ -- 956
		0, -- 956
		3, -- 956
		6, -- 956
		7, -- 956
		8 -- 956
	})) -- 956
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 957
	uiInkDraw:drawRect( -- 960
		Rect(cx - 32, cy - 32, 64, 64), -- 960
		Color( -- 960
			224, -- 960
			218, -- 960
			206, -- 960
			math.floor(145 * appear + 0.5) -- 960
		), -- 960
		0.8, -- 960
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 960
	) -- 960
	local i = 0 -- 961
	do -- 961
		i = 0 -- 962
		while i < #RELOAD_GRID do -- 962
			local g = RELOAD_GRID[i + 1] -- 963
			local nx = cx + (g.col - 1) * step -- 964
			local ny = cy + (g.row - 1) * step -- 965
			uiInkDraw:drawDot( -- 966
				Vec2(nx, ny), -- 966
				1.8, -- 966
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 966
			) -- 966
			i = i + 1 -- 962
		end -- 962
	end -- 962
	do -- 962
		i = 0 -- 970
		while i < #samplePath - 1 do -- 970
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 971
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 972
			uiInkDraw:drawSegment( -- 973
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 974
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 975
				1.8, -- 976
				toColor(accent, 220 * appear) -- 977
			) -- 977
			i = i + 1 -- 970
		end -- 970
	end -- 970
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 982
	local kx = cx + (keyNode.col - 1) * step -- 983
	local ky = cy + (keyNode.row - 1) * step -- 984
	drawReloadPatternGlyph( -- 985
		uiInkDraw, -- 985
		kx, -- 985
		ky, -- 985
		7.5, -- 985
		effect, -- 985
		accent, -- 985
		appear -- 985
	) -- 985
	fillRadialGlow( -- 986
		uiGlow, -- 986
		kx, -- 986
		ky, -- 986
		14, -- 986
		14, -- 986
		toColor(PALETTE.amberCore, 45 * appear), -- 986
		Color(244, 234, 214, 0), -- 986
		10 -- 986
	) -- 986
end -- 947
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 990
	local prog = math.max( -- 997
		0, -- 997
		math.min( -- 997
			1, -- 997
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 997
		) -- 997
	) -- 997
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 998
	local cx = ctx.uiW * 0.5 -- 999
	local cy = ctx.uiH * 0.68 -- 1000
	local w = 440 -- 1001
	local h = 112 -- 1002
	drawSilkVeil( -- 1004
		uiDraw, -- 1004
		uiArt, -- 1004
		"cb_handover_veil", -- 1004
		cx, -- 1004
		cy, -- 1004
		w + 80, -- 1004
		h + 28, -- 1004
		PALETTE.inkWash, -- 1004
		0.84 * fade, -- 1004
		0 -- 1004
	) -- 1004
	drawHairline( -- 1005
		uiInkDraw, -- 1005
		uiArt, -- 1005
		"cb_handover_top", -- 1005
		cx, -- 1005
		cy + h * 0.48, -- 1005
		w - 30, -- 1005
		PALETTE.amber, -- 1005
		0.58 * fade, -- 1005
		true, -- 1005
		2 -- 1005
	) -- 1005
	local passK = math.min(1, prog / 0.38) -- 1008
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 1009
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 1010
	local a245 = math.floor(245 * fade + 0.5) -- 1011
	local a235 = math.floor(235 * fade + 0.5) -- 1012
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 1015
	local childHandY = cy - 4 + gripLift * 0.2 -- 1016
	uiInkDraw:drawPolygon( -- 1017
		{ -- 1017
			Vec2(cx - 148, cy - 22), -- 1018
			Vec2(cx - 146, cy - 8), -- 1019
			Vec2(childHandX - 10, childHandY + 4), -- 1020
			Vec2(childHandX - 10, childHandY - 6) -- 1021
		}, -- 1021
		Color(164, 78, 54, a235), -- 1022
		1, -- 1022
		Color(52, 28, 22, a235) -- 1022
	) -- 1022
	uiInkDraw:drawSegment( -- 1023
		Vec2(childHandX - 11, childHandY + 4), -- 1023
		Vec2(childHandX - 11, childHandY - 6), -- 1023
		2, -- 1023
		Color(204, 174, 122, a245) -- 1023
	) -- 1023
	uiInkDraw:drawEllipse( -- 1024
		Vec2(childHandX, childHandY - 1), -- 1024
		6.2, -- 1024
		4.4, -- 1024
		Color(238, 212, 182, a245) -- 1024
	) -- 1024
	local solHandX = cx + 82 - math.min( -- 1027
		1, -- 1027
		math.max(0, (prog - 0.18) / 0.28) -- 1027
	) * 42 -- 1027
	local solHandY = cy - 4 + gripLift -- 1028
	uiInkDraw:drawPolygon( -- 1029
		{ -- 1029
			Vec2(cx + 154, cy - 18), -- 1030
			Vec2(cx + 154, cy - 1), -- 1031
			Vec2(solHandX + 12, solHandY + 6), -- 1032
			Vec2(solHandX + 12, solHandY - 7) -- 1033
		}, -- 1033
		toColor(CUFF_PALETTE.indigoBase, a245), -- 1034
		1, -- 1034
		toColor(CUFF_PALETTE.indigoShadow, a245) -- 1034
	) -- 1034
	local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1036
	uiInkDraw:drawSegment( -- 1037
		Vec2(solHandX + 16, solHandY - 5), -- 1037
		Vec2(solHandX + 19, solHandY + 4), -- 1037
		1.5, -- 1037
		mendCol -- 1037
	) -- 1037
	uiInkDraw:drawSegment( -- 1038
		Vec2(solHandX + 21, solHandY - 5), -- 1038
		Vec2(solHandX + 24, solHandY + 4), -- 1038
		1.5, -- 1038
		mendCol -- 1038
	) -- 1038
	uiInkDraw:drawSegment( -- 1039
		Vec2(solHandX + 26, solHandY - 5), -- 1039
		Vec2(solHandX + 29, solHandY + 4), -- 1039
		1.5, -- 1039
		mendCol -- 1039
	) -- 1039
	uiInkDraw:drawEllipse( -- 1040
		Vec2(solHandX, solHandY), -- 1040
		6.8, -- 1040
		5, -- 1040
		toColor(CUFF_PALETTE.skinBase, a245) -- 1040
	) -- 1040
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1043
	local gunY = cy + 3 + gripLift -- 1044
	uiInkDraw:drawPolygon( -- 1046
		{ -- 1046
			Vec2(gunX - 42, gunY - 8), -- 1047
			Vec2(gunX - 12, gunY - 3), -- 1048
			Vec2(gunX + 16, gunY + 1), -- 1049
			Vec2(gunX + 16, gunY + 6), -- 1050
			Vec2(gunX - 16, gunY + 3), -- 1051
			Vec2(gunX - 40, gunY + 1) -- 1052
		}, -- 1052
		Color(108, 72, 48, a245), -- 1053
		1, -- 1053
		Color(46, 30, 20, a245) -- 1053
	) -- 1053
	uiInkDraw:drawSegment( -- 1055
		Vec2(gunX - 6, gunY + 4), -- 1055
		Vec2(gunX + 56, gunY + 8), -- 1055
		2.8, -- 1055
		Color(152, 148, 138, a245) -- 1055
	) -- 1055
	uiInkDraw:drawSegment( -- 1056
		Vec2(gunX + 14, gunY + 1), -- 1056
		Vec2(gunX + 14, gunY + 8), -- 1056
		2, -- 1056
		Color(198, 166, 112, a245) -- 1056
	) -- 1056
	uiInkDraw:drawSegment( -- 1057
		Vec2(gunX + 36, gunY + 3), -- 1057
		Vec2(gunX + 36, gunY + 9), -- 1057
		1.6, -- 1057
		Color(198, 166, 112, a245) -- 1057
	) -- 1057
	drawReloadPatternGlyph( -- 1058
		uiInkDraw, -- 1058
		gunX + 2, -- 1058
		gunY + 21, -- 1058
		8.5, -- 1058
		self.handoverEffect, -- 1058
		PALETTE.amberCore, -- 1058
		fade -- 1058
	) -- 1058
	fillRadialGlow( -- 1059
		uiGlow, -- 1059
		gunX + 4, -- 1059
		gunY + 4, -- 1059
		48, -- 1059
		22, -- 1059
		toColor(PALETTE.amberCore, 52 * fade), -- 1059
		Color(244, 234, 214, 0), -- 1059
		12 -- 1059
	) -- 1059
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1061
	ctx.texts:put( -- 1064
		"xs", -- 1064
		caption, -- 1064
		cx, -- 1064
		cy - 34, -- 1064
		toColor(PALETTE.amberCore), -- 1064
		0.5, -- 1064
		0.5, -- 1064
		"Center", -- 1064
		1.4, -- 1064
		0.94 * fade, -- 1064
		0.08 -- 1064
	) -- 1064
end -- 990
function ____exports.createCraftBenchPlugin(contract) -- 1068
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1069
end -- 1068
return ____exports -- 1068
