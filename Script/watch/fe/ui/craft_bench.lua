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
			local ____self_cardBoxes_3 = self.cardBoxes -- 338
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
	if ctx.paused then -- 349
		self:resetInputEdges(ctx.input:isTouchMode()) -- 353
		return -- 354
	end -- 354
	local udt = math.max(0, ctx.uiDt) -- 357
	self.animTime = self.animTime + udt -- 358
	if self.missingFlashT > 0 then -- 358
		self.missingFlashT = math.max(0, self.missingFlashT - udt) -- 361
	end -- 361
	if self.handoverRemaining > 0 then -- 361
		self.handoverRemaining = math.max(0, self.handoverRemaining - udt) -- 364
	end -- 364
	self:detectCraftCompletion(ctx, bench) -- 368
	if bench.active and not self.wasActive then -- 368
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
	elseif not bench.active and self.wasActive then -- 376
		self.pendingRecipeId = "" -- 378
		self.missingFlashT = 0 -- 379
	end -- 379
	self.wasActive = bench.active -- 381
	if not bench.active then -- 381
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
			if r.crafted and self.prevCraftedMap[r.id] ~= true then -- 399
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
			if ename == "benchRejected" then -- 408
				self.pendingRecipeId = "" -- 410
				self.missingFlashT = 0.45 -- 411
			end -- 411
			i = i + 1 -- 407
		end -- 407
	end -- 407
	if newlyCrafted ~= nil then -- 407
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
				if ename == "craftDone" or ename == "benchCraft" then -- 428
					hasBackendDone = true -- 430
					break -- 431
				end -- 431
				i = i + 1 -- 427
			end -- 427
		end -- 427
		if not hasBackendDone then -- 427
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
	local kbmMode = ctx.input.inputMode == "kbm" -- 463
	local ____temp_17 -- 464
	if (sim and sim.click) ~= nil then -- 464
		____temp_17 = sim.click -- 465
	else -- 465
		____temp_17 = ctx.input.uiHeld or ctx.input.fire.held or kbmMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 466
	end -- 466
	local leftHeld = ____temp_17 -- 464
	local ____temp_20 -- 467
	if (sim and sim.rightClick) ~= nil then -- 467
		____temp_20 = sim.rightClick -- 468
	else -- 468
		____temp_20 = ctx.input.uiRightPressed or kbmMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 469
	end -- 469
	local rightHeld = ____temp_20 -- 467
	local ____temp_23 -- 471
	if (sim and sim.click) ~= nil then -- 471
		____temp_23 = sim.click -- 472
	else -- 472
		____temp_23 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 473
	end -- 473
	local click = ____temp_23 -- 471
	local ____temp_26 -- 474
	if (sim and sim.rightClick) ~= nil then -- 474
		____temp_26 = sim.rightClick -- 475
	else -- 475
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 476
	end -- 476
	local rightClick = ____temp_26 -- 474
	self.prevLeft = leftHeld -- 477
	self.prevRight = rightHeld -- 478
	local move = 0 -- 480
	local confirm = false -- 481
	local cancel = false -- 482
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 482
		move = sim.move or 0 -- 485
		confirm = sim.confirm == true -- 486
		cancel = sim.cancel == true -- 487
	else -- 487
		if type(Keyboard) ~= "nil" then -- 487
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 490
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 491
			local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 492
			local cc = Keyboard:isKeyPressed("BackSpace") -- 493
			if lk and not self.prevLeftKey then -- 493
				move = move - 1 -- 494
			end -- 494
			if rk and not self.prevRightKey then -- 494
				move = move + 1 -- 495
			end -- 495
			confirm = cf and not self.prevConfirm -- 496
			cancel = cc and not self.prevCancel -- 497
			self.prevLeftKey = lk -- 498
			self.prevRightKey = rk -- 499
			self.prevConfirm = cf -- 500
			self.prevCancel = cc -- 501
		end -- 501
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 501
			move = move - 1 -- 503
		end -- 503
		if ctx.input.navRight or ctx.input.navNextTab then -- 503
			move = move + 1 -- 504
		end -- 504
		if ctx.input.navConfirm then -- 504
			confirm = true -- 505
		end -- 505
		if ctx.input.navBack then -- 505
			cancel = true -- 506
		end -- 506
	end -- 506
	local ptr = Vec2(ptrX, ptrY) -- 510
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 511
	if cancel or rightClick or click and hitClose then -- 511
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 513
		return -- 514
	end -- 514
	local count = #bench.recipes -- 517
	if count == 0 then -- 517
		return -- 519
	end -- 519
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 522
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 523
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 524
	local hitCard = -1 -- 526
	if inside then -- 526
		local i = 0 -- 528
		do -- 528
			i = 0 -- 529
			while i < #self.cardBoxes do -- 529
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 529
					hitCard = i -- 531
					break -- 532
				end -- 532
				i = i + 1 -- 529
			end -- 529
		end -- 529
	end -- 529
	if move ~= 0 then -- 529
		self.pointerActive = false -- 538
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 539
	elseif pointerMoved and hitCard >= 0 then -- 539
		self.pointerActive = true -- 541
		self.selectedIdx = hitCard -- 542
	end -- 542
	local triggerConfirm = confirm or click and hitCard >= 0 -- 545
	if not triggerConfirm then -- 545
		return -- 547
	end -- 547
	if click and hitCard >= 0 then -- 547
		self.selectedIdx = hitCard -- 550
	end -- 550
	if self.handoverRemaining > 0.05 then -- 550
		return -- 555
	end -- 555
	local recipe = bench.recipes[self.selectedIdx + 1] -- 558
	if recipe == nil then -- 558
		return -- 560
	end -- 560
	if recipe.crafted then -- 560
		if bench.equippedWeapon ~= recipe.id then -- 560
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 565
		end -- 565
		return -- 567
	end -- 567
	if self.pendingRecipeId == recipe.id then -- 567
		return -- 572
	end -- 572
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 576
	if #missing > 0 then -- 576
		self.missingList = missing -- 578
		self.missingFlashT = 0.55 -- 579
		ctx.audio:playOnce( -- 580
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 581
			"sfx", -- 582
			"assets/audio/combat/craft_insufficient.wav", -- 583
			0.76, -- 584
			"craft:insufficient:" .. recipe.id, -- 585
			ctx.p.ticks -- 586
		) -- 586
		return -- 588
	end -- 588
	self.missingList = {} -- 591
	self.missingFlashT = 0 -- 592
	self.pendingRecipeId = recipe.id -- 593
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 594
	self.requestSeq = self.requestSeq + 1 -- 595
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 596
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 597
	if not accepted then -- 597
		self.pendingRecipeId = "" -- 603
	end -- 603
end -- 447
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 607
	local bench = ctx.view.craftBench -- 614
	if not bench.active and self.handoverRemaining <= 0.01 then -- 614
		return false -- 616
	end -- 616
	if not bench.active then -- 616
		self:drawHandoverOverlay( -- 621
			uiDraw, -- 621
			uiInkDraw, -- 621
			uiArt, -- 621
			uiGlow, -- 621
			ctx -- 621
		) -- 621
		return false -- 622
	end -- 622
	local appear = math.min(1, self.openAnimT) -- 625
	local layout = self:computeLayout(ctx, #bench.recipes) -- 626
	local bx = layout.benchX -- 627
	local by = layout.benchY -- 628
	local bw = layout.benchW -- 629
	local bh = layout.benchH -- 630
	fillVGradRect( -- 633
		uiDraw, -- 634
		0, -- 635
		0, -- 636
		ctx.uiW, -- 637
		by + bh + 64, -- 638
		Color( -- 639
			12, -- 639
			10, -- 639
			10, -- 639
			math.floor(168 * appear + 0.5) -- 639
		), -- 639
		Color(12, 10, 10, 0) -- 640
	) -- 640
	self:drawWoodenBenchBody( -- 644
		uiDraw, -- 644
		uiInkDraw, -- 644
		uiArt, -- 644
		uiGlow, -- 644
		bx, -- 644
		by, -- 644
		bw, -- 644
		bh, -- 644
		appear -- 644
	) -- 644
	ctx.texts:put( -- 647
		"md", -- 647
		"安全工台 · 改制鸟铳", -- 647
		bx + 54, -- 647
		by + bh - 26, -- 647
		toColor(PALETTE.amberCore), -- 647
		0, -- 647
		0.5, -- 647
		"Left", -- 647
		2, -- 647
		0.96 * appear, -- 647
		0.08 -- 647
	) -- 647
	drawHairline( -- 648
		uiInkDraw, -- 648
		uiArt, -- 648
		"cb_head_line", -- 648
		bx + bw * 0.5, -- 648
		by + bh - 46, -- 648
		bw - 36, -- 648
		PALETTE.amberDim, -- 648
		0.55 * appear, -- 648
		false, -- 648
		2 -- 648
	) -- 648
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 650
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 651
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 652
	uiInkDraw:drawRect( -- 653
		self.closeBox, -- 654
		Color( -- 655
			24, -- 655
			18, -- 655
			16, -- 655
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 655
		), -- 655
		0.9, -- 656
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 657
	) -- 657
	local closeText = ctx.input:isGamepadMode() and keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 659
	ctx.texts:put( -- 662
		"xs", -- 663
		closeText, -- 664
		self.closeBox.x + self.closeBox.width * 0.5, -- 665
		self.closeBox.y + self.closeBox.height * 0.5, -- 666
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 667
		0.5, -- 668
		0.5, -- 669
		"Center", -- 670
		1.4, -- 671
		0.95 * appear, -- 672
		0.06 -- 673
	) -- 673
	self:drawTableMaterials( -- 677
		uiDraw, -- 677
		uiInkDraw, -- 677
		uiArt, -- 677
		ctx, -- 677
		bench, -- 677
		bx + 18, -- 677
		by + 22, -- 677
		layout.matW - 14, -- 677
		bh - 76, -- 677
		appear -- 677
	) -- 677
	local i = 0 -- 680
	do -- 680
		i = 0 -- 681
		while i < #bench.recipes and i < #self.cardBoxes do -- 681
			self:drawRecipeCard( -- 682
				uiDraw, -- 683
				uiInkDraw, -- 684
				uiArt, -- 685
				uiGlow, -- 686
				ctx, -- 687
				bench, -- 688
				bench.recipes[i + 1], -- 689
				self.cardBoxes[i + 1], -- 690
				i == self.selectedIdx, -- 691
				appear -- 692
			) -- 692
			i = i + 1 -- 681
		end -- 681
	end -- 681
	if self.handoverRemaining > 0.01 then -- 681
		self:drawHandoverOverlay( -- 698
			uiDraw, -- 698
			uiInkDraw, -- 698
			uiArt, -- 698
			uiGlow, -- 698
			ctx -- 698
		) -- 698
	end -- 698
	return true -- 701
end -- 607
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 704
	uiDraw:drawRect( -- 716
		Rect(bx, by, bw, bh), -- 716
		Color( -- 716
			WOOD_BODY.r, -- 716
			WOOD_BODY.g, -- 716
			WOOD_BODY.b, -- 716
			math.floor(244 * appear + 0.5) -- 716
		), -- 716
		1.4, -- 716
		toColor(PALETTE.amberDim, 190 * appear) -- 716
	) -- 716
	uiArt:tryPlacePath( -- 717
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 717
		"cb_wood_tex", -- 717
		bx + bw * 0.5, -- 717
		by + bh * 0.5, -- 717
		bw - 4, -- 717
		bh - 12, -- 717
		{ -- 717
			anchorX = 0.5, -- 718
			anchorY = 0.5, -- 719
			color = Color(172, 132, 98, 255), -- 720
			opacity = 0.34 * appear, -- 721
			smooth = true, -- 722
			layer = 0 -- 723
		} -- 723
	) -- 723
	uiDraw:drawRect( -- 726
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 726
		Color( -- 726
			WOOD_TOP.r, -- 726
			WOOD_TOP.g, -- 726
			WOOD_TOP.b, -- 726
			math.floor(250 * appear + 0.5) -- 726
		), -- 726
		1, -- 726
		WOOD_EDGE -- 726
	) -- 726
	uiInkDraw:drawSegment( -- 727
		Vec2(bx - 6, by + bh + 3), -- 727
		Vec2(bx + bw + 6, by + bh + 3), -- 727
		1.2, -- 727
		toColor(PALETTE.amberCore, 115 * appear) -- 727
	) -- 727
	uiDraw:drawRect( -- 729
		Rect(bx + 18, by - 26, 22, 26), -- 729
		Color( -- 729
			WOOD_DARK.r, -- 729
			WOOD_DARK.g, -- 729
			WOOD_DARK.b, -- 729
			math.floor(235 * appear + 0.5) -- 729
		) -- 729
	) -- 729
	uiDraw:drawRect( -- 730
		Rect(bx + bw - 40, by - 26, 22, 26), -- 730
		Color( -- 730
			WOOD_DARK.r, -- 730
			WOOD_DARK.g, -- 730
			WOOD_DARK.b, -- 730
			math.floor(235 * appear + 0.5) -- 730
		) -- 730
	) -- 730
	local g = 1 -- 733
	do -- 733
		g = 1 -- 734
		while g <= 4 do -- 734
			local gy = by + (bh - 50) * (g / 5) -- 735
			uiDraw:drawSegment( -- 736
				Vec2(bx + 10, gy), -- 736
				Vec2(bx + bw - 10, gy), -- 736
				0.75, -- 736
				Color( -- 736
					34, -- 736
					23, -- 736
					18, -- 736
					math.floor(92 * appear + 0.5) -- 736
				) -- 736
			) -- 736
			g = g + 1 -- 734
		end -- 734
	end -- 734
	local lx = bx + 28 -- 740
	local ly = by + bh - 24 -- 741
	uiArt:tryPlace( -- 742
		"prop_lantern", -- 742
		"cb_lantern", -- 742
		lx, -- 742
		ly, -- 742
		20, -- 742
		26, -- 742
		{opacity = 0.94 * appear, layer = 4} -- 742
	) -- 742
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 743
	fillRadialGlow( -- 744
		uiGlow, -- 745
		lx + 10, -- 746
		ly - 10, -- 747
		260 * pulse, -- 748
		180 * pulse, -- 749
		Color( -- 750
			238, -- 750
			198, -- 750
			128, -- 750
			math.floor(38 * appear + 0.5) -- 750
		), -- 750
		Color(238, 180, 92, 0), -- 751
		16 -- 752
	) -- 752
end -- 704
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 756
	uiDraw:drawRect( -- 768
		Rect(x, y, w, h), -- 768
		Color( -- 768
			26, -- 768
			20, -- 768
			17, -- 768
			math.floor(188 * appear + 0.5) -- 768
		), -- 768
		0.9, -- 768
		toColor(PALETTE.amberDim, 130 * appear) -- 768
	) -- 768
	drawFiligreeCorners( -- 769
		uiInkDraw, -- 769
		uiArt, -- 769
		"cb_mat_frame", -- 769
		x + 3, -- 769
		y + 3, -- 769
		w - 6, -- 769
		h - 6, -- 769
		PALETTE.amberDim, -- 769
		0.48 * appear, -- 769
		16, -- 769
		false, -- 769
		2 -- 769
	) -- 769
	ctx.texts:put( -- 771
		"xs", -- 771
		"案边持有", -- 771
		x + 12, -- 771
		y + h - 18, -- 771
		toColor(PALETTE.amberCore), -- 771
		0, -- 771
		0.5, -- 771
		"Left", -- 771
		1.4, -- 771
		0.92 * appear, -- 771
		0.06 -- 771
	) -- 771
	uiInkDraw:drawSegment( -- 772
		Vec2(x + 10, y + h - 32), -- 772
		Vec2(x + w - 10, y + h - 32), -- 772
		0.75, -- 772
		toColor(PALETTE.amberDim, 115 * appear) -- 772
	) -- 772
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 774
	local i = 0 -- 775
	do -- 775
		i = 0 -- 776
		while i < #keys and i < 4 do -- 776
			local mat = keys[i + 1] -- 777
			local count = bench.inventory[mat] or 0 -- 778
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 779
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 780
			local rowY = y + h - 62 - i * 48 -- 781
			if isMissing then -- 781
				uiDraw:drawRect( -- 784
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 784
					toColor(PALETTE.rougeSoft, 145 * appear), -- 784
					1, -- 784
					toColor(PALETTE.crimsonCore, 220 * appear) -- 784
				) -- 784
			end -- 784
			local matClip = (mat == "bell_tally" or mat == "bell") and "pickup_bell" or (mat == "scrap" and "pickup_scrap" or (mat == "wedge" and "pickup_wedge" or (mat == "ammo" and "pickup_ammo" or "pickup_wood"))) -- 788
			local shown = math.max( -- 793
				1, -- 793
				math.min(3, count) -- 793
			) -- 793
			local t = 0 -- 794
			do -- 794
				t = 0 -- 795
				while t < shown do -- 795
					do -- 795
						local tx = x + 22 + t * 19 + shake -- 796
						local filled = t < count -- 797
						if uiArt:tryPlacePath( -- 797
							"assets/art/props_ming.clip|" .. matClip, -- 798
							(("cb_mat_" .. mat) .. "_") .. tostring(t), -- 798
							tx, -- 798
							rowY, -- 798
							20, -- 798
							20, -- 798
							{ -- 798
								anchorX = 0.5, -- 799
								anchorY = 0.5, -- 800
								preserveAspect = true, -- 801
								color = filled and Color(255, 255, 255, 255) or Color(138, 134, 128, 255), -- 802
								opacity = (filled and 0.96 or 0.34) * appear, -- 803
								layer = 3 -- 804
							} -- 804
						) then -- 804
							goto __continue108 -- 806
						end -- 806
						if mat == "bell_tally" or mat == "bell" then -- 806
							drawReloadPatternGlyph( -- 809
								uiInkDraw, -- 810
								tx, -- 811
								rowY, -- 812
								7.5, -- 813
								"echo", -- 814
								filled and PALETTE.amberCore or PALETTE.silkDim, -- 815
								(filled and 0.96 or 0.38) * appear -- 816
							) -- 816
						else -- 816
							local col = filled and PALETTE.amber or PALETTE.silkDim -- 819
							uiInkDraw:drawRect( -- 820
								Rect(tx - 4, rowY - 10, 8, 20), -- 821
								filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 822
								1, -- 823
								toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 824
							) -- 824
							if filled then -- 824
								uiInkDraw:drawSegment( -- 827
									Vec2(tx - 2, rowY + 3), -- 827
									Vec2(tx + 2, rowY + 3), -- 827
									0.9, -- 827
									toColor(PALETTE.xuanInk, 185 * appear) -- 827
								) -- 827
								uiInkDraw:drawSegment( -- 828
									Vec2(tx - 2, rowY - 3), -- 828
									Vec2(tx + 2, rowY - 3), -- 828
									0.9, -- 828
									toColor(PALETTE.xuanInk, 185 * appear) -- 828
								) -- 828
							end -- 828
						end -- 828
					end -- 828
					::__continue108:: -- 828
					t = t + 1 -- 795
				end -- 795
			end -- 795
			ctx.texts:put( -- 833
				"xs", -- 834
				materialLabel(mat), -- 835
				x + 86 + shake, -- 836
				rowY + 5, -- 837
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 838
				0, -- 839
				0.5, -- 840
				"Left", -- 841
				0.8, -- 842
				0.95 * appear, -- 843
				0.06 -- 844
			) -- 844
			ctx.texts:put( -- 846
				"xs", -- 847
				"存 " .. tostring(count), -- 848
				x + 86 + shake, -- 849
				rowY - 11, -- 850
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 851
				0, -- 852
				0.5, -- 853
				"Left", -- 854
				0.8, -- 855
				0.88 * appear, -- 856
				0.06 -- 857
			) -- 857
			i = i + 1 -- 776
		end -- 776
	end -- 776
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 862
	uiInkDraw:drawSegment( -- 863
		Vec2(x + 10, y + 32), -- 863
		Vec2(x + w - 10, y + 32), -- 863
		0.75, -- 863
		toColor(PALETTE.amberDim, 105 * appear) -- 863
	) -- 863
	ctx.texts:put( -- 864
		"xs", -- 864
		"现佩：" .. eqName, -- 864
		x + 12, -- 864
		y + 16, -- 864
		toColor(PALETTE.textMid), -- 864
		0, -- 864
		0.5, -- 864
		"Left", -- 864
		0.8, -- 864
		0.9 * appear, -- 864
		0.06 -- 864
	) -- 864
end -- 756
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 867
	local i = 0 -- 868
	do -- 868
		i = 0 -- 869
		while i < #bench.recipes do -- 869
			if bench.recipes[i + 1].id == weaponId then -- 869
				return bench.recipes[i + 1].name -- 871
			end -- 871
			i = i + 1 -- 869
		end -- 869
	end -- 869
	return "旧制鸟铳" -- 874
end -- 867
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 877
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 889
	local canCraft = not recipe.crafted and #missing == 0 -- 890
	local equipped = bench.equippedWeapon == recipe.id -- 891
	local isPending = self.pendingRecipeId == recipe.id -- 892
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 893
	if not uiArt:tryPlace( -- 893
		"ink_song_paper", -- 896
		"cb_card_" .. recipe.id, -- 896
		box.x + box.width * 0.5, -- 896
		box.y + box.height * 0.5, -- 896
		box.width, -- 896
		box.height, -- 896
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 896
	) then -- 896
		uiDraw:drawRect( -- 897
			box, -- 897
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 897
		) -- 897
	end -- 897
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 900
	drawFiligreeCorners( -- 903
		uiInkDraw, -- 903
		uiArt, -- 903
		"cb_cf_" .. recipe.id, -- 903
		box.x + 5, -- 903
		box.y + 5, -- 903
		box.width - 10, -- 903
		box.height - 10, -- 903
		borderCol, -- 903
		(selected and 0.88 or 0.46) * appear, -- 903
		18, -- 903
		true, -- 903
		2 -- 903
	) -- 903
	if selected then -- 903
		drawSilkRibbon( -- 906
			uiDraw, -- 906
			uiArt, -- 906
			"cb_sel_rib_" .. recipe.id, -- 906
			box.x + box.width * 0.5, -- 906
			box.y + box.height - 26, -- 906
			box.width - 14, -- 906
			30, -- 906
			PALETTE.amberDim, -- 906
			0.24 * appear, -- 906
			2 -- 906
		) -- 906
	end -- 906
	local topY = box.y + box.height - 26 -- 910
	drawBlossomDot( -- 911
		uiInkDraw, -- 911
		uiArt, -- 911
		"cb_dot_" .. recipe.id, -- 911
		box.x + 18, -- 911
		topY, -- 911
		selected and 11 or 7, -- 911
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 911
		0.92 * appear, -- 911
		3 -- 911
	) -- 911
	ctx.texts:put( -- 912
		"md", -- 912
		recipe.name, -- 912
		box.x + 30, -- 912
		topY, -- 912
		toColor(PALETTE.xuanInk), -- 912
		0, -- 912
		0.5, -- 912
		"Left", -- 912
		1.6, -- 912
		0.98 * appear, -- 912
		0 -- 912
	) -- 912
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 914
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 915
	ctx.texts:put( -- 916
		"xs", -- 916
		badge, -- 916
		box.x + box.width - 14, -- 916
		topY, -- 916
		toColor(badgeCol), -- 916
		1, -- 916
		0.5, -- 916
		"Right", -- 916
		1, -- 916
		0.94 * appear, -- 916
		0 -- 916
	) -- 916
	local narrow = box.width < 195 -- 919
	local miniCx = box.x + (narrow and 36 or 46) -- 920
	local miniCy = box.y + box.height - 96 -- 921
	self:drawMiniReloadPreview( -- 922
		uiInkDraw, -- 922
		uiGlow, -- 922
		miniCx, -- 922
		miniCy, -- 922
		recipe.enhancedEffect, -- 922
		appear -- 922
	) -- 922
	local infoX = box.x + (narrow and 72 or 90) -- 925
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 926
	ctx.texts:put( -- 927
		"xs", -- 927
		effTitle, -- 927
		infoX, -- 927
		box.y + box.height - 64, -- 927
		toColor(PALETTE.rouge), -- 927
		0, -- 927
		0.5, -- 927
		"Left", -- 927
		narrow and 0.3 or 0.8, -- 927
		0.95 * appear, -- 927
		0 -- 927
	) -- 927
	local row = 0 -- 929
	for mat in pairs(recipe.cost) do -- 930
		local need = recipe.cost[mat] -- 931
		local have = bench.inventory[mat] or 0 -- 932
		local lack = not recipe.crafted and have < need -- 933
		local ry = box.y + box.height - 90 - row * 22 -- 934
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 935
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 936
		ctx.texts:put( -- 937
			"xs", -- 937
			text, -- 937
			infoX, -- 937
			ry, -- 937
			toColor(col), -- 937
			0, -- 937
			0.5, -- 937
			"Left", -- 937
			0.6, -- 937
			0.94 * appear, -- 937
			0 -- 937
		) -- 937
		row = row + 1 -- 938
	end -- 938
	local weaponArtPath = recipe.enhancedEffect == "echo" and "assets/art/vfx_craft_art.clip|craft_echo_gun" or (recipe.enhancedEffect == "light" and "assets/art/vfx_craft_art.clip|craft_lantern_gun" or "assets/art/props_ming.clip|pickup_quickbelt") -- 942
	uiArt:tryPlacePath( -- 947
		weaponArtPath, -- 947
		"cb_wpn_art_" .. recipe.id, -- 947
		box.x + box.width * 0.5, -- 947
		box.y + 68, -- 947
		math.min(box.width - 36, 126), -- 947
		34, -- 947
		{ -- 947
			anchorX = 0.5, -- 948
			anchorY = 0.5, -- 949
			preserveAspect = true, -- 950
			smooth = true, -- 951
			opacity = (selected and 0.96 or 0.78) * appear, -- 952
			layer = 3 -- 953
		} -- 953
	) -- 953
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 957
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 958
	local btnBg = equipped and Color( -- 961
		168, -- 962
		46, -- 962
		44, -- 962
		math.floor(32 * appear + 0.5) -- 962
	) or (selected and (canCraft or recipe.crafted) and Color( -- 962
		32, -- 964
		30, -- 964
		32, -- 964
		math.floor(218 * appear + 0.5) -- 964
	) or Color( -- 964
		32, -- 965
		30, -- 965
		32, -- 965
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 965
	)) -- 965
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 966
	uiInkDraw:drawRect( -- 969
		btnRect, -- 969
		btnBg, -- 969
		0.9, -- 969
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 969
	) -- 969
	ctx.texts:put( -- 970
		"sm", -- 971
		btnLabel, -- 972
		btnRect.x + btnRect.width * 0.5, -- 973
		btnRect.y + btnRect.height * 0.5, -- 974
		toColor(btnTextCol), -- 975
		0.5, -- 976
		0.5, -- 977
		"Center", -- 978
		1.6, -- 979
		0.96 * appear, -- 980
		0 -- 981
	) -- 981
end -- 877
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 986
	local step = 20 -- 994
	local samplePath = effect == "light" and ({ -- 995
		0, -- 995
		1, -- 995
		2, -- 995
		5, -- 995
		8 -- 995
	}) or (effect == "echo" and ({ -- 995
		0, -- 995
		1, -- 995
		4, -- 995
		5, -- 995
		8 -- 995
	}) or ({ -- 995
		0, -- 995
		3, -- 995
		6, -- 995
		7, -- 995
		8 -- 995
	})) -- 995
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 996
	uiInkDraw:drawRect( -- 999
		Rect(cx - 32, cy - 32, 64, 64), -- 999
		Color( -- 999
			224, -- 999
			218, -- 999
			206, -- 999
			math.floor(145 * appear + 0.5) -- 999
		), -- 999
		0.8, -- 999
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 999
	) -- 999
	local i = 0 -- 1000
	do -- 1000
		i = 0 -- 1001
		while i < #RELOAD_GRID do -- 1001
			local g = RELOAD_GRID[i + 1] -- 1002
			local nx = cx + (g.col - 1) * step -- 1003
			local ny = cy + (g.row - 1) * step -- 1004
			uiInkDraw:drawDot( -- 1005
				Vec2(nx, ny), -- 1005
				1.8, -- 1005
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 1005
			) -- 1005
			i = i + 1 -- 1001
		end -- 1001
	end -- 1001
	do -- 1001
		i = 0 -- 1009
		while i < #samplePath - 1 do -- 1009
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 1010
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 1011
			uiInkDraw:drawSegment( -- 1012
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 1013
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 1014
				1.8, -- 1015
				toColor(accent, 220 * appear) -- 1016
			) -- 1016
			i = i + 1 -- 1009
		end -- 1009
	end -- 1009
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 1021
	local kx = cx + (keyNode.col - 1) * step -- 1022
	local ky = cy + (keyNode.row - 1) * step -- 1023
	drawReloadPatternGlyph( -- 1024
		uiInkDraw, -- 1024
		kx, -- 1024
		ky, -- 1024
		7.5, -- 1024
		effect, -- 1024
		accent, -- 1024
		appear -- 1024
	) -- 1024
	fillRadialGlow( -- 1025
		uiGlow, -- 1025
		kx, -- 1025
		ky, -- 1025
		14, -- 1025
		14, -- 1025
		toColor(PALETTE.amberCore, 45 * appear), -- 1025
		Color(244, 234, 214, 0), -- 1025
		10 -- 1025
	) -- 1025
end -- 986
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1029
	local prog = math.max( -- 1036
		0, -- 1036
		math.min( -- 1036
			1, -- 1036
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 1036
		) -- 1036
	) -- 1036
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 1037
	local cx = ctx.uiW * 0.5 -- 1038
	local cy = ctx.uiH * 0.68 -- 1039
	local w = 440 -- 1040
	local h = 112 -- 1041
	drawSilkVeil( -- 1043
		uiDraw, -- 1043
		uiArt, -- 1043
		"cb_handover_veil", -- 1043
		cx, -- 1043
		cy, -- 1043
		w + 80, -- 1043
		h + 28, -- 1043
		PALETTE.inkWash, -- 1043
		0.84 * fade, -- 1043
		0 -- 1043
	) -- 1043
	drawHairline( -- 1044
		uiInkDraw, -- 1044
		uiArt, -- 1044
		"cb_handover_top", -- 1044
		cx, -- 1044
		cy + h * 0.48, -- 1044
		w - 30, -- 1044
		PALETTE.amber, -- 1044
		0.58 * fade, -- 1044
		true, -- 1044
		2 -- 1044
	) -- 1044
	local passK = math.min(1, prog / 0.38) -- 1047
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 1048
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 1049
	local a245 = math.floor(245 * fade + 0.5) -- 1050
	local a235 = math.floor(235 * fade + 0.5) -- 1051
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 1054
	local childHandY = cy - 4 + gripLift * 0.2 -- 1055
	local solHandX = cx + 82 - math.min( -- 1056
		1, -- 1056
		math.max(0, (prog - 0.18) / 0.28) -- 1056
	) * 42 -- 1056
	local solHandY = cy - 4 + gripLift -- 1057
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1058
	local gunY = cy + 6 + gripLift -- 1059
	local childPlaced = uiArt:tryPlacePath( -- 1061
		"assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", -- 1061
		"cb_ho_child", -- 1061
		childHandX, -- 1061
		childHandY - 6, -- 1061
		154, -- 1061
		68, -- 1061
		{ -- 1061
			anchorX = 0.43, -- 1062
			anchorY = 0.52, -- 1063
			facing = -1, -- 1064
			smooth = true, -- 1065
			opacity = 0.94 * fade, -- 1066
			layer = 3 -- 1067
		} -- 1067
	) -- 1067
	if not childPlaced then -- 1067
		uiInkDraw:drawPolygon( -- 1070
			{ -- 1070
				Vec2(cx - 148, cy - 22), -- 1071
				Vec2(cx - 146, cy - 8), -- 1072
				Vec2(childHandX - 10, childHandY + 4), -- 1073
				Vec2(childHandX - 10, childHandY - 6) -- 1074
			}, -- 1074
			Color(164, 78, 54, a235), -- 1075
			1, -- 1075
			Color(52, 28, 22, a235) -- 1075
		) -- 1075
		uiInkDraw:drawSegment( -- 1076
			Vec2(childHandX - 11, childHandY + 4), -- 1076
			Vec2(childHandX - 11, childHandY - 6), -- 1076
			2, -- 1076
			Color(204, 174, 122, a245) -- 1076
		) -- 1076
		uiInkDraw:drawEllipse( -- 1077
			Vec2(childHandX, childHandY - 1), -- 1077
			6.2, -- 1077
			4.4, -- 1077
			Color(238, 212, 182, a245) -- 1077
		) -- 1077
	end -- 1077
	local solPlaced = uiArt:tryPlacePath( -- 1080
		"assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp", -- 1080
		"cb_ho_zhou", -- 1080
		solHandX, -- 1080
		solHandY - 4, -- 1080
		168, -- 1080
		78, -- 1080
		{ -- 1080
			anchorX = 0.57, -- 1081
			anchorY = 0.5, -- 1082
			facing = -1, -- 1083
			smooth = true, -- 1084
			opacity = 0.96 * fade, -- 1085
			layer = 4 -- 1086
		} -- 1086
	) -- 1086
	if not solPlaced then -- 1086
		uiInkDraw:drawPolygon( -- 1089
			{ -- 1089
				Vec2(cx + 154, cy - 18), -- 1090
				Vec2(cx + 154, cy - 1), -- 1091
				Vec2(solHandX + 12, solHandY + 6), -- 1092
				Vec2(solHandX + 12, solHandY - 7) -- 1093
			}, -- 1093
			toColor(CUFF_PALETTE.indigoBase, a245), -- 1094
			1, -- 1094
			toColor(CUFF_PALETTE.indigoShadow, a245) -- 1094
		) -- 1094
		local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1095
		uiInkDraw:drawSegment( -- 1096
			Vec2(solHandX + 16, solHandY - 5), -- 1096
			Vec2(solHandX + 19, solHandY + 4), -- 1096
			1.5, -- 1096
			mendCol -- 1096
		) -- 1096
		uiInkDraw:drawSegment( -- 1097
			Vec2(solHandX + 21, solHandY - 5), -- 1097
			Vec2(solHandX + 24, solHandY + 4), -- 1097
			1.5, -- 1097
			mendCol -- 1097
		) -- 1097
		uiInkDraw:drawSegment( -- 1098
			Vec2(solHandX + 26, solHandY - 5), -- 1098
			Vec2(solHandX + 29, solHandY + 4), -- 1098
			1.5, -- 1098
			mendCol -- 1098
		) -- 1098
		uiInkDraw:drawEllipse( -- 1099
			Vec2(solHandX, solHandY), -- 1099
			6.8, -- 1099
			5, -- 1099
			toColor(CUFF_PALETTE.skinBase, a245) -- 1099
		) -- 1099
	end -- 1099
	local gunClip = self.handoverEffect == "echo" and "craft_echo_gun" or "craft_lantern_gun" -- 1102
	if not uiArt:tryPlacePath( -- 1102
		"assets/art/vfx_craft_art.clip|" .. gunClip, -- 1103
		"cb_ho_gun", -- 1103
		gunX, -- 1103
		gunY, -- 1103
		170, -- 1103
		52, -- 1103
		{ -- 1103
			anchorX = 0.5, -- 1104
			anchorY = 0.5, -- 1105
			preserveAspect = true, -- 1106
			smooth = true, -- 1107
			opacity = 0.98 * fade, -- 1108
			layer = 5 -- 1109
		} -- 1109
	) then -- 1109
		uiInkDraw:drawPolygon( -- 1111
			{ -- 1111
				Vec2(gunX - 42, gunY - 8), -- 1112
				Vec2(gunX - 12, gunY - 3), -- 1113
				Vec2(gunX + 16, gunY + 1), -- 1114
				Vec2(gunX + 16, gunY + 6), -- 1115
				Vec2(gunX - 16, gunY + 3), -- 1116
				Vec2(gunX - 40, gunY + 1) -- 1117
			}, -- 1117
			Color(108, 72, 48, a245), -- 1118
			1, -- 1118
			Color(46, 30, 20, a245) -- 1118
		) -- 1118
		uiInkDraw:drawSegment( -- 1119
			Vec2(gunX - 6, gunY + 4), -- 1119
			Vec2(gunX + 56, gunY + 8), -- 1119
			2.8, -- 1119
			Color(152, 148, 138, a245) -- 1119
		) -- 1119
		uiInkDraw:drawSegment( -- 1120
			Vec2(gunX + 14, gunY + 1), -- 1120
			Vec2(gunX + 14, gunY + 8), -- 1120
			2, -- 1120
			Color(198, 166, 112, a245) -- 1120
		) -- 1120
		uiInkDraw:drawSegment( -- 1121
			Vec2(gunX + 36, gunY + 3), -- 1121
			Vec2(gunX + 36, gunY + 9), -- 1121
			1.6, -- 1121
			Color(198, 166, 112, a245) -- 1121
		) -- 1121
	end -- 1121
	drawReloadPatternGlyph( -- 1123
		uiInkDraw, -- 1123
		gunX + 2, -- 1123
		gunY + 26, -- 1123
		8.5, -- 1123
		self.handoverEffect, -- 1123
		PALETTE.amberCore, -- 1123
		fade -- 1123
	) -- 1123
	fillRadialGlow( -- 1124
		uiGlow, -- 1124
		gunX + 4, -- 1124
		gunY + 4, -- 1124
		48, -- 1124
		22, -- 1124
		toColor(PALETTE.amberCore, 52 * fade), -- 1124
		Color(244, 234, 214, 0), -- 1124
		12 -- 1124
	) -- 1124
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1126
	ctx.texts:put( -- 1129
		"xs", -- 1129
		caption, -- 1129
		cx, -- 1129
		cy - 34, -- 1129
		toColor(PALETTE.amberCore), -- 1129
		0.5, -- 1129
		0.5, -- 1129
		"Center", -- 1129
		1.4, -- 1129
		0.94 * fade, -- 1129
		0.08 -- 1129
	) -- 1129
end -- 1029
function ____exports.createCraftBenchPlugin(contract) -- 1133
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1134
end -- 1133
return ____exports -- 1133