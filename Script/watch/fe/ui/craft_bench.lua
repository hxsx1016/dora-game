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
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 484
		move = sim.move or 0 -- 485
		confirm = sim.confirm == true -- 486
		cancel = sim.cancel == true -- 487
	else -- 487
		if type(Keyboard) ~= "nil" then -- 489
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 490
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 491
			local cf = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 492
			local cc = Keyboard:isKeyPressed("BackSpace") -- 493
			if lk and not self.prevLeftKey then -- 494
				move = move - 1 -- 494
			end -- 494
			if rk and not self.prevRightKey then -- 495
				move = move + 1 -- 495
			end -- 495
			confirm = cf and not self.prevConfirm -- 496
			cancel = cc and not self.prevCancel -- 497
			self.prevLeftKey = lk -- 498
			self.prevRightKey = rk -- 499
			self.prevConfirm = cf -- 500
			self.prevCancel = cc -- 501
		end -- 501
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 503
			move = move - 1 -- 503
		end -- 503
		if ctx.input.navRight or ctx.input.navNextTab then -- 504
			move = move + 1 -- 504
		end -- 504
		if ctx.input.navConfirm then -- 505
			confirm = true -- 505
		end -- 505
		if ctx.input.navBack then -- 506
			cancel = true -- 506
		end -- 506
	end -- 506
	local ptr = Vec2(ptrX, ptrY) -- 510
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 511
	if cancel or rightClick or click and hitClose then -- 512
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 513
		return -- 514
	end -- 514
	local count = #bench.recipes -- 517
	if count == 0 then -- 518
		return -- 519
	end -- 519
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 522
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 523
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 524
	local hitCard = -1 -- 526
	if inside then -- 527
		local i = 0 -- 528
		do -- 528
			i = 0 -- 529
			while i < #self.cardBoxes do -- 529
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 530
					hitCard = i -- 531
					break -- 532
				end -- 532
				i = i + 1 -- 529
			end -- 529
		end -- 529
	end -- 529
	if move ~= 0 then -- 537
		self.pointerActive = false -- 538
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 539
	elseif pointerMoved and hitCard >= 0 then -- 540
		self.pointerActive = true -- 541
		self.selectedIdx = hitCard -- 542
	end -- 542
	local triggerConfirm = confirm or click and hitCard >= 0 -- 545
	if not triggerConfirm then -- 546
		return -- 547
	end -- 547
	if click and hitCard >= 0 then -- 549
		self.selectedIdx = hitCard -- 550
	end -- 550
	if self.handoverRemaining > 0.05 then -- 554
		return -- 555
	end -- 555
	local recipe = bench.recipes[self.selectedIdx + 1] -- 558
	if recipe == nil then -- 559
		return -- 560
	end -- 560
	if recipe.crafted then -- 563
		if bench.equippedWeapon ~= recipe.id then -- 564
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 565
		end -- 565
		return -- 567
	end -- 567
	if self.pendingRecipeId == recipe.id then -- 571
		return -- 572
	end -- 572
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 576
	if #missing > 0 then -- 577
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
	if not accepted then -- 602
		self.pendingRecipeId = "" -- 603
	end -- 603
end -- 447
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 607
	local bench = ctx.view.craftBench -- 614
	if not bench.active and self.handoverRemaining <= 0.01 then -- 615
		return false -- 616
	end -- 616
	if not bench.active then -- 620
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
	if self.handoverRemaining > 0.01 then -- 697
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
	uiDraw:drawRect( -- 718
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 718
		Color( -- 718
			WOOD_TOP.r, -- 718
			WOOD_TOP.g, -- 718
			WOOD_TOP.b, -- 718
			math.floor(250 * appear + 0.5) -- 718
		), -- 718
		1, -- 718
		WOOD_EDGE -- 718
	) -- 718
	uiInkDraw:drawSegment( -- 719
		Vec2(bx - 6, by + bh + 3), -- 719
		Vec2(bx + bw + 6, by + bh + 3), -- 719
		1.2, -- 719
		toColor(PALETTE.amberCore, 115 * appear) -- 719
	) -- 719
	uiDraw:drawRect( -- 721
		Rect(bx + 18, by - 26, 22, 26), -- 721
		Color( -- 721
			WOOD_DARK.r, -- 721
			WOOD_DARK.g, -- 721
			WOOD_DARK.b, -- 721
			math.floor(235 * appear + 0.5) -- 721
		) -- 721
	) -- 721
	uiDraw:drawRect( -- 722
		Rect(bx + bw - 40, by - 26, 22, 26), -- 722
		Color( -- 722
			WOOD_DARK.r, -- 722
			WOOD_DARK.g, -- 722
			WOOD_DARK.b, -- 722
			math.floor(235 * appear + 0.5) -- 722
		) -- 722
	) -- 722
	local g = 1 -- 725
	do -- 725
		g = 1 -- 726
		while g <= 4 do -- 726
			local gy = by + (bh - 50) * (g / 5) -- 727
			uiDraw:drawSegment( -- 728
				Vec2(bx + 10, gy), -- 728
				Vec2(bx + bw - 10, gy), -- 728
				0.75, -- 728
				Color( -- 728
					34, -- 728
					23, -- 728
					18, -- 728
					math.floor(110 * appear + 0.5) -- 728
				) -- 728
			) -- 728
			g = g + 1 -- 726
		end -- 726
	end -- 726
	local lx = bx + 28 -- 732
	local ly = by + bh - 24 -- 733
	uiArt:tryPlace( -- 734
		"prop_lantern", -- 734
		"cb_lantern", -- 734
		lx, -- 734
		ly, -- 734
		20, -- 734
		26, -- 734
		{opacity = 0.94 * appear, layer = 4} -- 734
	) -- 734
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 735
	fillRadialGlow( -- 736
		uiGlow, -- 737
		lx + 10, -- 738
		ly - 10, -- 739
		260 * pulse, -- 740
		180 * pulse, -- 741
		Color( -- 742
			238, -- 742
			198, -- 742
			128, -- 742
			math.floor(38 * appear + 0.5) -- 742
		), -- 742
		Color(238, 180, 92, 0), -- 743
		16 -- 744
	) -- 744
end -- 704
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 748
	uiDraw:drawRect( -- 760
		Rect(x, y, w, h), -- 760
		Color( -- 760
			26, -- 760
			20, -- 760
			17, -- 760
			math.floor(188 * appear + 0.5) -- 760
		), -- 760
		0.9, -- 760
		toColor(PALETTE.amberDim, 130 * appear) -- 760
	) -- 760
	drawFiligreeCorners( -- 761
		uiInkDraw, -- 761
		uiArt, -- 761
		"cb_mat_frame", -- 761
		x + 3, -- 761
		y + 3, -- 761
		w - 6, -- 761
		h - 6, -- 761
		PALETTE.amberDim, -- 761
		0.48 * appear, -- 761
		16, -- 761
		false, -- 761
		2 -- 761
	) -- 761
	ctx.texts:put( -- 763
		"xs", -- 763
		"案边持有", -- 763
		x + 12, -- 763
		y + h - 18, -- 763
		toColor(PALETTE.amberCore), -- 763
		0, -- 763
		0.5, -- 763
		"Left", -- 763
		1.4, -- 763
		0.92 * appear, -- 763
		0.06 -- 763
	) -- 763
	uiInkDraw:drawSegment( -- 764
		Vec2(x + 10, y + h - 32), -- 764
		Vec2(x + w - 10, y + h - 32), -- 764
		0.75, -- 764
		toColor(PALETTE.amberDim, 115 * appear) -- 764
	) -- 764
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 766
	local i = 0 -- 767
	do -- 767
		i = 0 -- 768
		while i < #keys and i < 4 do -- 768
			local mat = keys[i + 1] -- 769
			local count = bench.inventory[mat] or 0 -- 770
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 771
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 772
			local rowY = y + h - 62 - i * 48 -- 773
			if isMissing then -- 775
				uiDraw:drawRect( -- 776
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 776
					toColor(PALETTE.rougeSoft, 145 * appear), -- 776
					1, -- 776
					toColor(PALETTE.crimsonCore, 220 * appear) -- 776
				) -- 776
			end -- 776
			local shown = math.max( -- 780
				1, -- 780
				math.min(4, count) -- 780
			) -- 780
			local t = 0 -- 781
			do -- 781
				t = 0 -- 782
				while t < shown do -- 782
					local tx = x + 22 + t * 14 + shake -- 783
					local filled = t < count -- 784
					if mat == "bell_tally" or mat == "bell" then -- 785
						drawReloadPatternGlyph( -- 786
							uiInkDraw, -- 787
							tx, -- 788
							rowY, -- 789
							7.5, -- 790
							"echo", -- 791
							filled and PALETTE.amberCore or PALETTE.silkDim, -- 792
							(filled and 0.96 or 0.38) * appear -- 793
						) -- 793
					else -- 793
						local col = filled and PALETTE.amber or PALETTE.silkDim -- 796
						uiInkDraw:drawRect( -- 797
							Rect(tx - 4, rowY - 10, 8, 20), -- 798
							filled and toColor(col, 195 * appear) or Color(0, 0, 0, 0), -- 799
							1, -- 800
							toColor(filled and PALETTE.amberCore or PALETTE.silkDim, (filled and 230 or 120) * appear) -- 801
						) -- 801
						if filled then -- 803
							uiInkDraw:drawSegment( -- 804
								Vec2(tx - 2, rowY + 3), -- 804
								Vec2(tx + 2, rowY + 3), -- 804
								0.9, -- 804
								toColor(PALETTE.xuanInk, 185 * appear) -- 804
							) -- 804
							uiInkDraw:drawSegment( -- 805
								Vec2(tx - 2, rowY - 3), -- 805
								Vec2(tx + 2, rowY - 3), -- 805
								0.9, -- 805
								toColor(PALETTE.xuanInk, 185 * appear) -- 805
							) -- 805
						end -- 805
					end -- 805
					t = t + 1 -- 782
				end -- 782
			end -- 782
			ctx.texts:put( -- 810
				"xs", -- 811
				materialLabel(mat), -- 812
				x + 86 + shake, -- 813
				rowY + 5, -- 814
				toColor(isMissing and PALETTE.crimsonCore or PALETTE.textBright), -- 815
				0, -- 816
				0.5, -- 817
				"Left", -- 818
				0.8, -- 819
				0.95 * appear, -- 820
				0.06 -- 821
			) -- 821
			ctx.texts:put( -- 823
				"xs", -- 824
				"存 " .. tostring(count), -- 825
				x + 86 + shake, -- 826
				rowY - 11, -- 827
				toColor(isMissing and PALETTE.crimsonCore or (count > 0 and PALETTE.amberCore or PALETTE.textDim)), -- 828
				0, -- 829
				0.5, -- 830
				"Left", -- 831
				0.8, -- 832
				0.88 * appear, -- 833
				0.06 -- 834
			) -- 834
			i = i + 1 -- 768
		end -- 768
	end -- 768
	local eqName = self:resolveWeaponName(bench, bench.equippedWeapon) -- 839
	uiInkDraw:drawSegment( -- 840
		Vec2(x + 10, y + 32), -- 840
		Vec2(x + w - 10, y + 32), -- 840
		0.75, -- 840
		toColor(PALETTE.amberDim, 105 * appear) -- 840
	) -- 840
	ctx.texts:put( -- 841
		"xs", -- 841
		"现佩：" .. eqName, -- 841
		x + 12, -- 841
		y + 16, -- 841
		toColor(PALETTE.textMid), -- 841
		0, -- 841
		0.5, -- 841
		"Left", -- 841
		0.8, -- 841
		0.9 * appear, -- 841
		0.06 -- 841
	) -- 841
end -- 748
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 844
	local i = 0 -- 845
	do -- 845
		i = 0 -- 846
		while i < #bench.recipes do -- 846
			if bench.recipes[i + 1].id == weaponId then -- 847
				return bench.recipes[i + 1].name -- 848
			end -- 848
			i = i + 1 -- 846
		end -- 846
	end -- 846
	return "旧制鸟铳" -- 851
end -- 844
function CraftBenchPlugin.prototype.drawRecipeCard(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, bench, recipe, box, selected, appear) -- 854
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 866
	local canCraft = not recipe.crafted and #missing == 0 -- 867
	local equipped = bench.equippedWeapon == recipe.id -- 868
	local isPending = self.pendingRecipeId == recipe.id -- 869
	local highlightMissing = selected and self.missingFlashT > 0.02 and #missing > 0 -- 870
	if not uiArt:tryPlace( -- 873
		"ink_song_paper", -- 873
		"cb_card_" .. recipe.id, -- 873
		box.x + box.width * 0.5, -- 873
		box.y + box.height * 0.5, -- 873
		box.width, -- 873
		box.height, -- 873
		{opacity = (selected and 0.96 or 0.84) * appear, layer = 1} -- 873
	) then -- 873
		uiDraw:drawRect( -- 874
			box, -- 874
			toColor(PALETTE.xuanPaper, (selected and 242 or 212) * appear) -- 874
		) -- 874
	end -- 874
	local borderCol = highlightMissing and PALETTE.rouge or (selected and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 877
	drawFiligreeCorners( -- 880
		uiInkDraw, -- 880
		uiArt, -- 880
		"cb_cf_" .. recipe.id, -- 880
		box.x + 5, -- 880
		box.y + 5, -- 880
		box.width - 10, -- 880
		box.height - 10, -- 880
		borderCol, -- 880
		(selected and 0.88 or 0.46) * appear, -- 880
		18, -- 880
		true, -- 880
		2 -- 880
	) -- 880
	if selected then -- 882
		drawSilkRibbon( -- 883
			uiDraw, -- 883
			uiArt, -- 883
			"cb_sel_rib_" .. recipe.id, -- 883
			box.x + box.width * 0.5, -- 883
			box.y + box.height - 26, -- 883
			box.width - 14, -- 883
			30, -- 883
			PALETTE.amberDim, -- 883
			0.24 * appear, -- 883
			2 -- 883
		) -- 883
	end -- 883
	local topY = box.y + box.height - 26 -- 887
	drawBlossomDot( -- 888
		uiInkDraw, -- 888
		uiArt, -- 888
		"cb_dot_" .. recipe.id, -- 888
		box.x + 18, -- 888
		topY, -- 888
		selected and 11 or 7, -- 888
		selected and PALETTE.rouge or PALETTE.xuanInkSub, -- 888
		0.92 * appear, -- 888
		3 -- 888
	) -- 888
	ctx.texts:put( -- 889
		"md", -- 889
		recipe.name, -- 889
		box.x + 30, -- 889
		topY, -- 889
		toColor(PALETTE.xuanInk), -- 889
		0, -- 889
		0.5, -- 889
		"Left", -- 889
		1.6, -- 889
		0.98 * appear, -- 889
		0 -- 889
	) -- 889
	local badge = equipped and "已携" or (recipe.crafted and "已制" or (canCraft and "可制" or "缺料")) -- 891
	local badgeCol = equipped and PALETTE.rouge or (canCraft and PALETTE.xuanInk or PALETTE.rougeSoft) -- 892
	ctx.texts:put( -- 893
		"xs", -- 893
		badge, -- 893
		box.x + box.width - 14, -- 893
		topY, -- 893
		toColor(badgeCol), -- 893
		1, -- 893
		0.5, -- 893
		"Right", -- 893
		1, -- 893
		0.94 * appear, -- 893
		0 -- 893
	) -- 893
	local narrow = box.width < 195 -- 896
	local miniCx = box.x + (narrow and 36 or 46) -- 897
	local miniCy = box.y + box.height - 96 -- 898
	self:drawMiniReloadPreview( -- 899
		uiInkDraw, -- 899
		uiGlow, -- 899
		miniCx, -- 899
		miniCy, -- 899
		recipe.enhancedEffect, -- 899
		appear -- 899
	) -- 899
	local infoX = box.x + (narrow and 72 or 90) -- 902
	local effTitle = recipe.enhancedEffect == "light" and "增强 · 灯纹照亮" or (recipe.enhancedEffect == "echo" and "增强 · 铃纹回声" or "增强 · 推退") -- 903
	ctx.texts:put( -- 904
		"xs", -- 904
		effTitle, -- 904
		infoX, -- 904
		box.y + box.height - 64, -- 904
		toColor(PALETTE.rouge), -- 904
		0, -- 904
		0.5, -- 904
		"Left", -- 904
		narrow and 0.3 or 0.8, -- 904
		0.95 * appear, -- 904
		0 -- 904
	) -- 904
	local row = 0 -- 906
	for mat in pairs(recipe.cost) do -- 907
		local need = recipe.cost[mat] -- 908
		local have = bench.inventory[mat] or 0 -- 909
		local lack = not recipe.crafted and have < need -- 910
		local ry = box.y + box.height - 90 - row * 22 -- 911
		local col = lack and PALETTE.rouge or PALETTE.xuanInkSub -- 912
		local text = ((((materialLabel(mat) .. " ") .. tostring(have)) .. "/") .. tostring(need)) .. (lack and "（缺）" or "") -- 913
		ctx.texts:put( -- 914
			"xs", -- 914
			text, -- 914
			infoX, -- 914
			ry, -- 914
			toColor(col), -- 914
			0, -- 914
			0.5, -- 914
			"Left", -- 914
			0.6, -- 914
			0.94 * appear, -- 914
			0 -- 914
		) -- 914
		row = row + 1 -- 915
	end -- 915
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 919
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 920
	local btnBg = equipped and Color( -- 923
		168, -- 924
		46, -- 924
		44, -- 924
		math.floor(32 * appear + 0.5) -- 924
	) or (selected and (canCraft or recipe.crafted) and Color( -- 925
		32, -- 926
		30, -- 926
		32, -- 926
		math.floor(218 * appear + 0.5) -- 926
	) or Color( -- 927
		32, -- 927
		30, -- 927
		32, -- 927
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 927
	)) -- 927
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 928
	uiInkDraw:drawRect( -- 931
		btnRect, -- 931
		btnBg, -- 931
		0.9, -- 931
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 931
	) -- 931
	ctx.texts:put( -- 932
		"sm", -- 933
		btnLabel, -- 934
		btnRect.x + btnRect.width * 0.5, -- 935
		btnRect.y + btnRect.height * 0.5, -- 936
		toColor(btnTextCol), -- 937
		0.5, -- 938
		0.5, -- 939
		"Center", -- 940
		1.6, -- 941
		0.96 * appear, -- 942
		0 -- 943
	) -- 943
end -- 854
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 948
	local step = 20 -- 956
	local samplePath = effect == "light" and ({ -- 957
		0, -- 957
		1, -- 957
		2, -- 957
		5, -- 957
		8 -- 957
	}) or (effect == "echo" and ({ -- 957
		0, -- 957
		1, -- 957
		4, -- 957
		5, -- 957
		8 -- 957
	}) or ({ -- 957
		0, -- 957
		3, -- 957
		6, -- 957
		7, -- 957
		8 -- 957
	})) -- 957
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 958
	uiInkDraw:drawRect( -- 961
		Rect(cx - 32, cy - 32, 64, 64), -- 961
		Color( -- 961
			224, -- 961
			218, -- 961
			206, -- 961
			math.floor(145 * appear + 0.5) -- 961
		), -- 961
		0.8, -- 961
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 961
	) -- 961
	local i = 0 -- 962
	do -- 962
		i = 0 -- 963
		while i < #RELOAD_GRID do -- 963
			local g = RELOAD_GRID[i + 1] -- 964
			local nx = cx + (g.col - 1) * step -- 965
			local ny = cy + (g.row - 1) * step -- 966
			uiInkDraw:drawDot( -- 967
				Vec2(nx, ny), -- 967
				1.8, -- 967
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 967
			) -- 967
			i = i + 1 -- 963
		end -- 963
	end -- 963
	do -- 963
		i = 0 -- 971
		while i < #samplePath - 1 do -- 971
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 972
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 973
			uiInkDraw:drawSegment( -- 974
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 975
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 976
				1.8, -- 977
				toColor(accent, 220 * appear) -- 978
			) -- 978
			i = i + 1 -- 971
		end -- 971
	end -- 971
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 983
	local kx = cx + (keyNode.col - 1) * step -- 984
	local ky = cy + (keyNode.row - 1) * step -- 985
	drawReloadPatternGlyph( -- 986
		uiInkDraw, -- 986
		kx, -- 986
		ky, -- 986
		7.5, -- 986
		effect, -- 986
		accent, -- 986
		appear -- 986
	) -- 986
	fillRadialGlow( -- 987
		uiGlow, -- 987
		kx, -- 987
		ky, -- 987
		14, -- 987
		14, -- 987
		toColor(PALETTE.amberCore, 45 * appear), -- 987
		Color(244, 234, 214, 0), -- 987
		10 -- 987
	) -- 987
end -- 948
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 991
	local prog = math.max( -- 998
		0, -- 998
		math.min( -- 998
			1, -- 998
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 998
		) -- 998
	) -- 998
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 999
	local cx = ctx.uiW * 0.5 -- 1000
	local cy = ctx.uiH * 0.68 -- 1001
	local w = 440 -- 1002
	local h = 112 -- 1003
	drawSilkVeil( -- 1005
		uiDraw, -- 1005
		uiArt, -- 1005
		"cb_handover_veil", -- 1005
		cx, -- 1005
		cy, -- 1005
		w + 80, -- 1005
		h + 28, -- 1005
		PALETTE.inkWash, -- 1005
		0.84 * fade, -- 1005
		0 -- 1005
	) -- 1005
	drawHairline( -- 1006
		uiInkDraw, -- 1006
		uiArt, -- 1006
		"cb_handover_top", -- 1006
		cx, -- 1006
		cy + h * 0.48, -- 1006
		w - 30, -- 1006
		PALETTE.amber, -- 1006
		0.58 * fade, -- 1006
		true, -- 1006
		2 -- 1006
	) -- 1006
	local passK = math.min(1, prog / 0.38) -- 1009
	local gripLift = prog >= 0.38 and prog < 0.74 and math.sin((prog - 0.38) / 0.36 * math.pi) * 9 or 0 -- 1010
	local releaseK = prog >= 0.74 and (prog - 0.74) / 0.26 or 0 -- 1011
	local a245 = math.floor(245 * fade + 0.5) -- 1012
	local a235 = math.floor(235 * fade + 0.5) -- 1013
	local childHandX = cx - 78 + passK * 42 - releaseK * 38 -- 1016
	local childHandY = cy - 4 + gripLift * 0.2 -- 1017
	uiInkDraw:drawPolygon( -- 1018
		{ -- 1018
			Vec2(cx - 148, cy - 22), -- 1019
			Vec2(cx - 146, cy - 8), -- 1020
			Vec2(childHandX - 10, childHandY + 4), -- 1021
			Vec2(childHandX - 10, childHandY - 6) -- 1022
		}, -- 1022
		Color(164, 78, 54, a235), -- 1023
		1, -- 1023
		Color(52, 28, 22, a235) -- 1023
	) -- 1023
	uiInkDraw:drawSegment( -- 1024
		Vec2(childHandX - 11, childHandY + 4), -- 1024
		Vec2(childHandX - 11, childHandY - 6), -- 1024
		2, -- 1024
		Color(204, 174, 122, a245) -- 1024
	) -- 1024
	uiInkDraw:drawEllipse( -- 1025
		Vec2(childHandX, childHandY - 1), -- 1025
		6.2, -- 1025
		4.4, -- 1025
		Color(238, 212, 182, a245) -- 1025
	) -- 1025
	local solHandX = cx + 82 - math.min( -- 1028
		1, -- 1028
		math.max(0, (prog - 0.18) / 0.28) -- 1028
	) * 42 -- 1028
	local solHandY = cy - 4 + gripLift -- 1029
	uiInkDraw:drawPolygon( -- 1030
		{ -- 1030
			Vec2(cx + 154, cy - 18), -- 1031
			Vec2(cx + 154, cy - 1), -- 1032
			Vec2(solHandX + 12, solHandY + 6), -- 1033
			Vec2(solHandX + 12, solHandY - 7) -- 1034
		}, -- 1034
		toColor(CUFF_PALETTE.indigoBase, a245), -- 1035
		1, -- 1035
		toColor(CUFF_PALETTE.indigoShadow, a245) -- 1035
	) -- 1035
	local mendCol = toColor(CUFF_PALETTE.stitchThread, a245) -- 1037
	uiInkDraw:drawSegment( -- 1038
		Vec2(solHandX + 16, solHandY - 5), -- 1038
		Vec2(solHandX + 19, solHandY + 4), -- 1038
		1.5, -- 1038
		mendCol -- 1038
	) -- 1038
	uiInkDraw:drawSegment( -- 1039
		Vec2(solHandX + 21, solHandY - 5), -- 1039
		Vec2(solHandX + 24, solHandY + 4), -- 1039
		1.5, -- 1039
		mendCol -- 1039
	) -- 1039
	uiInkDraw:drawSegment( -- 1040
		Vec2(solHandX + 26, solHandY - 5), -- 1040
		Vec2(solHandX + 29, solHandY + 4), -- 1040
		1.5, -- 1040
		mendCol -- 1040
	) -- 1040
	uiInkDraw:drawEllipse( -- 1041
		Vec2(solHandX, solHandY), -- 1041
		6.8, -- 1041
		5, -- 1041
		toColor(CUFF_PALETTE.skinBase, a245) -- 1041
	) -- 1041
	local gunX = prog < 0.38 and childHandX + 14 or solHandX - 8 -- 1044
	local gunY = cy + 3 + gripLift -- 1045
	uiInkDraw:drawPolygon( -- 1047
		{ -- 1047
			Vec2(gunX - 42, gunY - 8), -- 1048
			Vec2(gunX - 12, gunY - 3), -- 1049
			Vec2(gunX + 16, gunY + 1), -- 1050
			Vec2(gunX + 16, gunY + 6), -- 1051
			Vec2(gunX - 16, gunY + 3), -- 1052
			Vec2(gunX - 40, gunY + 1) -- 1053
		}, -- 1053
		Color(108, 72, 48, a245), -- 1054
		1, -- 1054
		Color(46, 30, 20, a245) -- 1054
	) -- 1054
	uiInkDraw:drawSegment( -- 1056
		Vec2(gunX - 6, gunY + 4), -- 1056
		Vec2(gunX + 56, gunY + 8), -- 1056
		2.8, -- 1056
		Color(152, 148, 138, a245) -- 1056
	) -- 1056
	uiInkDraw:drawSegment( -- 1057
		Vec2(gunX + 14, gunY + 1), -- 1057
		Vec2(gunX + 14, gunY + 8), -- 1057
		2, -- 1057
		Color(198, 166, 112, a245) -- 1057
	) -- 1057
	uiInkDraw:drawSegment( -- 1058
		Vec2(gunX + 36, gunY + 3), -- 1058
		Vec2(gunX + 36, gunY + 9), -- 1058
		1.6, -- 1058
		Color(198, 166, 112, a245) -- 1058
	) -- 1058
	drawReloadPatternGlyph( -- 1059
		uiInkDraw, -- 1059
		gunX + 2, -- 1059
		gunY + 21, -- 1059
		8.5, -- 1059
		self.handoverEffect, -- 1059
		PALETTE.amberCore, -- 1059
		fade -- 1059
	) -- 1059
	fillRadialGlow( -- 1060
		uiGlow, -- 1060
		gunX + 4, -- 1060
		gunY + 4, -- 1060
		48, -- 1060
		22, -- 1060
		toColor(PALETTE.amberCore, 52 * fade), -- 1060
		Color(244, 234, 214, 0), -- 1060
		12 -- 1060
	) -- 1060
	local caption = self.handoverDuration >= 0.8 and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1062
	ctx.texts:put( -- 1065
		"xs", -- 1065
		caption, -- 1065
		cx, -- 1065
		cy - 34, -- 1065
		toColor(PALETTE.amberCore), -- 1065
		0.5, -- 1065
		0.5, -- 1065
		"Center", -- 1065
		1.4, -- 1065
		0.94 * fade, -- 1065
		0.08 -- 1065
	) -- 1065
end -- 991
function ____exports.createCraftBenchPlugin(contract) -- 1069
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1070
end -- 1069
return ____exports -- 1069
