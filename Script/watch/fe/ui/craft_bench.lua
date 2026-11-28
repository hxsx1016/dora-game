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
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 31
local drawComicInsertPanel = ____slideshow.drawComicInsertPanel -- 31
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 32
local RELOAD_GRID = ____reload_wheel.RELOAD_GRID -- 33
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 34
local ____theme = require("Script.watch.fe.theme") -- 36
local PALETTE = ____theme.PALETTE -- 37
local drawBlossomDot = ____theme.drawBlossomDot -- 39
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 40
local drawHairline = ____theme.drawHairline -- 41
local drawSilkRibbon = ____theme.drawSilkRibbon -- 42
local drawSilkVeil = ____theme.drawSilkVeil -- 43
local fillRadialGlow = ____theme.fillRadialGlow -- 44
local fillVGradRect = ____theme.fillVGradRect -- 45
local toColor = ____theme.toColor -- 46
local MATERIAL_NAMES = { -- 49
	wood = "木纹筹", -- 50
	bell = "铃纹筹", -- 51
	wood_tally = "木纹筹", -- 52
	bell_tally = "铃纹筹", -- 53
	scrap = "旧木料", -- 54
	wedge = "木楔", -- 55
	ammo = "备用弹" -- 56
} -- 56
local WOOD_TOP = Color(98, 68, 48, 252) -- 59
local WOOD_BODY = Color(58, 40, 30, 250) -- 60
local WOOD_EDGE = Color(152, 114, 82, 235) -- 61
local WOOD_DARK = Color(30, 21, 17, 248) -- 62
local function materialLabel(key) -- 89
	return MATERIAL_NAMES[key] or key -- 90
end -- 89
local function resolveRuntimeContract(injected) -- 93
	if injected ~= nil then -- 93
		return injected -- 95
	end -- 95
	local g = _G -- 97
	local ____temp_0 -- 98
	if g.package ~= nil then -- 98
		____temp_0 = g.package.loaded -- 98
	else -- 98
		____temp_0 = nil -- 98
	end -- 98
	local loaded = ____temp_0 -- 98
	if loaded == nil then -- 98
		return nil -- 100
	end -- 100
	local feHook = loaded["watch.fe"] -- 102
	if feHook ~= nil and type(feHook) == "table" then -- 102
		local c = feHook.contract -- 104
		if c ~= nil and type(c) == "table" then -- 104
			return c -- 106
		end -- 106
	end -- 106
	return nil -- 109
end -- 93
local function dispatchIntentFallback(p, intent) -- 112
	local rec = p -- 113
	local handler = rec.submitFeIntent -- 114
	if type(handler) == "function" then -- 114
		return handler(p, intent) ~= false -- 116
	end -- 116
	return false -- 118
end -- 112
local function collectMissingMaterials(recipe, inventory) -- 121
	local missing = {} -- 125
	for mat in pairs(recipe.cost) do -- 126
		local need = recipe.cost[mat] -- 127
		local have = inventory[mat] or 0 -- 128
		if have < need then -- 128
			missing[#missing + 1] = mat -- 130
		end -- 130
	end -- 130
	return missing -- 133
end -- 121
local function sortedMaterialKeys(inventory, recipes) -- 136
	local seen = {} -- 140
	local out = {} -- 141
	local prefer = {"wood", "bell", "wood_tally", "bell_tally"} -- 143
	local hasBackendKeys = inventory.wood ~= nil or inventory.bell ~= nil -- 144
	local i = 0 -- 145
	do -- 145
		i = 0 -- 146
		while i < #recipes do -- 146
			if recipes[i + 1].cost.wood ~= nil or recipes[i + 1].cost.bell ~= nil then -- 146
				hasBackendKeys = true -- 148
			end -- 148
			i = i + 1 -- 146
		end -- 146
	end -- 146
	local primary = hasBackendKeys and ({"wood", "bell"}) or ({"wood_tally", "bell_tally"}) -- 151
	do -- 151
		i = 0 -- 152
		while i < #primary do -- 152
			seen[primary[i + 1]] = true -- 153
			out[#out + 1] = primary[i + 1] -- 154
			i = i + 1 -- 152
		end -- 152
	end -- 152
	do -- 152
		i = 0 -- 156
		while i < #recipes do -- 156
			local cost = recipes[i + 1].cost -- 157
			for k in pairs(cost) do -- 158
				if not seen[k] then -- 158
					seen[k] = true -- 160
					out[#out + 1] = k -- 161
				end -- 161
			end -- 161
			i = i + 1 -- 156
		end -- 156
	end -- 156
	do -- 156
		i = 0 -- 165
		while i < #prefer do -- 165
			local k = prefer[i + 1] -- 166
			if not seen[k] and inventory[k] ~= nil and inventory[k] > 0 then -- 166
				seen[k] = true -- 168
				out[#out + 1] = k -- 169
			end -- 169
			i = i + 1 -- 165
		end -- 165
	end -- 165
	return out -- 172
end -- 136
____exports.CraftBenchPlugin = __TS__Class() -- 175
local CraftBenchPlugin = ____exports.CraftBenchPlugin -- 175
CraftBenchPlugin.name = "CraftBenchPlugin" -- 175
function CraftBenchPlugin.prototype.____constructor(self, contract) -- 213
	self.id = "fe-02-craft-bench" -- 176
	self.wasActive = false -- 180
	self.selectedIdx = 0 -- 181
	self.animTime = 0 -- 182
	self.openAnimT = 0 -- 183
	self.requestSeq = 0 -- 186
	self.pendingRecipeId = "" -- 187
	self.pendingFirstCraftAtSubmit = true -- 188
	self.prevCraftedMap = {} -- 189
	self.missingFlashT = 0 -- 192
	self.missingList = {} -- 193
	self.handoverRemaining = 0 -- 196
	self.handoverDuration = 1 -- 197
	self.handoverWeaponId = "" -- 198
	self.handoverWeaponName = "" -- 199
	self.handoverEffect = "light" -- 200
	self.prevLeft = false -- 203
	self.prevRight = false -- 204
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
function CraftBenchPlugin.prototype.resetInputEdges(self, _touchMode) -- 282
	if _touchMode == nil then -- 282
		_touchMode = false -- 282
	end -- 282
	self.prevLeft = false -- 283
	self.prevRight = false -- 284
end -- 282
function CraftBenchPlugin.prototype.submitIntent(self, p, intent) -- 287
	local contract = resolveRuntimeContract(self.injectedContract) -- 288
	if contract ~= nil then -- 288
		return contract:submitIntent(p, intent) -- 290
	end -- 290
	return dispatchIntentFallback(p, intent) -- 292
end -- 287
function CraftBenchPlugin.prototype.computeLayout(self, ctx, recipeCount) -- 295
	local uiW = ctx.uiW -- 302
	local uiH = ctx.uiH -- 303
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 304
	local touchMode = ctx.input:isTouchMode() -- 305
	local count = math.max(1, recipeCount) -- 306
	local wantW = count >= 3 and 840 or 692 -- 307
	local benchW = math.min(uiW - 44 - safe.left - safe.right, wantW) -- 308
	local benchH = 290 -- 309
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 311
	local minX = 24 + safe.left -- 312
	local maxX = math.max(minX, uiW - benchW - 24 - safe.right) -- 313
	local benchX = count >= 3 and math.max(minX, (uiW - benchW) * 0.5) or (soldierUiX < uiW * 0.52 and maxX or minX) -- 314
	local benchY = math.max( -- 317
		46 + safe.bottom, -- 317
		math.min(uiH * 0.1 + safe.bottom, 66 + safe.bottom) -- 317
	) -- 317
	local matW = count >= 3 and 168 or 196 -- 318
	local cardsAreaX = benchX + matW + 16 -- 320
	local cardsAreaW = benchW - matW - 30 -- 321
	local gap = count >= 3 and 10 or 14 -- 322
	local cardW = (cardsAreaW - gap * (count - 1)) / count -- 323
	local cardH = benchH - 72 -- 324
	local cardY = benchY + 20 -- 325
	self.cardBoxes = {} -- 327
	local i = 0 -- 328
	do -- 328
		i = 0 -- 329
		while i < count do -- 329
			local ____self_cardBoxes_1 = self.cardBoxes -- 329
			____self_cardBoxes_1[#____self_cardBoxes_1 + 1] = Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH) -- 330
			i = i + 1 -- 329
		end -- 329
	end -- 329
	local closeW = touchMode and 88 or 76 -- 332
	local closeH = touchMode and 32 or 26 -- 333
	self.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH) -- 334
	return { -- 335
		benchX = benchX, -- 335
		benchY = benchY, -- 335
		benchW = benchW, -- 335
		benchH = benchH, -- 335
		matW = matW -- 335
	} -- 335
end -- 295
function CraftBenchPlugin.prototype.update(self, ctx) -- 338
	local bench = ctx.view.craftBench -- 339
	self.lastSnapshotBench = bench -- 340
	if ctx.paused then -- 340
		self:resetInputEdges(ctx.input:isTouchMode()) -- 344
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
		self:resetInputEdges(ctx.input:isTouchMode()) -- 367
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
		local ____temp_2 -- 407
		if self.pendingRecipeId == newlyCrafted.id then -- 407
			____temp_2 = self.pendingFirstCraftAtSubmit -- 408
		else -- 408
			____temp_2 = bench.justCraftedTimer >= 0.72 -- 409
		end -- 409
		local isFirst = ____temp_2 -- 407
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
	local touchMode = ctx.input:isTouchMode() -- 442
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 443
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 445
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 448
	local ____temp_12 -- 451
	if (sim and sim.pointerX) ~= nil then -- 451
		____temp_12 = true -- 452
	else -- 452
		local ____useUiPtr_11 -- 453
		if useUiPtr then -- 453
			____useUiPtr_11 = ctx.input.uiInside -- 453
		else -- 453
			____useUiPtr_11 = ctx.input.inside -- 453
		end -- 453
		____temp_12 = ____useUiPtr_11 -- 453
	end -- 453
	local inside = ____temp_12 -- 451
	local ____temp_15 -- 454
	if (sim and sim.click) ~= nil then -- 454
		____temp_15 = sim.click -- 455
	else -- 455
		____temp_15 = ctx.input.uiHeld or ctx.input.fire.held -- 456
	end -- 456
	local leftHeld = ____temp_15 -- 454
	local ____temp_18 -- 457
	if (sim and sim.rightClick) ~= nil then -- 457
		____temp_18 = sim.rightClick -- 458
	else -- 458
		____temp_18 = ctx.input.uiRightPressed -- 459
	end -- 459
	local rightHeld = ____temp_18 -- 457
	local ____temp_21 -- 461
	if (sim and sim.click) ~= nil then -- 461
		____temp_21 = sim.click -- 462
	else -- 462
		____temp_21 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 463
	end -- 463
	local click = ____temp_21 -- 461
	local ____temp_24 -- 464
	if (sim and sim.rightClick) ~= nil then -- 464
		____temp_24 = sim.rightClick -- 465
	else -- 465
		____temp_24 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 466
	end -- 466
	local rightClick = ____temp_24 -- 464
	self.prevLeft = leftHeld -- 467
	self.prevRight = rightHeld -- 468
	local move = 0 -- 470
	local confirm = false -- 471
	local cancel = false -- 472
	if sim ~= nil and (sim.move ~= nil or sim.confirm ~= nil or sim.cancel ~= nil) then -- 472
		move = sim.move or 0 -- 475
		confirm = sim.confirm == true -- 476
		cancel = sim.cancel == true -- 477
	else -- 477
		if ctx.input.navLeft or ctx.input.navPrevTab then -- 477
			move = move - 1 -- 479
		end -- 479
		if ctx.input.navRight or ctx.input.navNextTab then -- 479
			move = move + 1 -- 480
		end -- 480
		if ctx.input.craftConfirm or ctx.input.navConfirm then -- 480
			confirm = true -- 481
		end -- 481
		if ctx.input.craftCancel or ctx.input.navBack then -- 481
			cancel = true -- 482
		end -- 482
	end -- 482
	local ptr = Vec2(ptrX, ptrY) -- 486
	local hitClose = inside and self.closeBox:containsPoint(ptr) -- 487
	if cancel or rightClick or click and hitClose then -- 487
		self:submitIntent(ctx.p, {kind = "craftClose"}) -- 489
		return -- 490
	end -- 490
	local count = #bench.recipes -- 493
	if count == 0 then -- 493
		return -- 495
	end -- 495
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 498
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 499
	local pointerMoved = (sim and sim.pointerX) ~= nil or not touchMode and inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 500
	local hitCard = -1 -- 502
	if inside then -- 502
		local i = 0 -- 504
		do -- 504
			i = 0 -- 505
			while i < #self.cardBoxes do -- 505
				if self.cardBoxes[i + 1]:containsPoint(ptr) then -- 505
					hitCard = i -- 507
					break -- 508
				end -- 508
				i = i + 1 -- 505
			end -- 505
		end -- 505
	end -- 505
	if move ~= 0 then -- 505
		self.pointerActive = false -- 514
		self.selectedIdx = (self.selectedIdx + move + count) % count -- 515
	elseif pointerMoved and hitCard >= 0 then -- 515
		self.pointerActive = true -- 517
		self.selectedIdx = hitCard -- 518
	end -- 518
	local triggerConfirm = confirm or click and hitCard >= 0 -- 521
	if not triggerConfirm then -- 521
		return -- 523
	end -- 523
	if click and hitCard >= 0 then -- 523
		self.selectedIdx = hitCard -- 526
	end -- 526
	if self.handoverRemaining > 0.05 then -- 526
		return -- 531
	end -- 531
	local recipe = bench.recipes[self.selectedIdx + 1] -- 534
	if recipe == nil then -- 534
		return -- 536
	end -- 536
	if recipe.crafted then -- 536
		if bench.equippedWeapon ~= recipe.id then -- 536
			self:submitIntent(ctx.p, {kind = "craftEquip", weaponId = recipe.id}) -- 541
		end -- 541
		return -- 543
	end -- 543
	if self.pendingRecipeId == recipe.id then -- 543
		return -- 548
	end -- 548
	local missing = collectMissingMaterials(recipe, bench.inventory) -- 552
	if #missing > 0 then -- 552
		self.missingList = missing -- 554
		self.missingFlashT = 0.55 -- 555
		ctx.audio:playOnce( -- 556
			(((("fe02:craft_lack:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(ctx.p.ticks), -- 557
			"sfx", -- 558
			"assets/audio/combat/craft_insufficient.wav", -- 559
			0.76, -- 560
			"craft:insufficient:" .. recipe.id, -- 561
			ctx.p.ticks -- 562
		) -- 562
		return -- 564
	end -- 564
	self.missingList = {} -- 567
	self.missingFlashT = 0 -- 568
	self.pendingRecipeId = recipe.id -- 569
	self.pendingFirstCraftAtSubmit = not bench.firstCraftDone -- 570
	self.requestSeq = self.requestSeq + 1 -- 571
	local requestId = (((("craft:r" .. tostring(ctx.events.roomSessionId)) .. ":") .. recipe.id) .. ":") .. tostring(self.requestSeq) -- 572
	local accepted = self:submitIntent(ctx.p, {kind = "craftSubmit", requestId = requestId, recipeId = recipe.id}) -- 573
	if not accepted then -- 573
		self.pendingRecipeId = "" -- 579
	end -- 579
end -- 438
function CraftBenchPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 583
	local bench = ctx.view.craftBench -- 590
	if not bench.active and self.handoverRemaining <= 0.01 then -- 590
		return false -- 592
	end -- 592
	if not bench.active then -- 592
		self:drawHandoverOverlay( -- 597
			uiDraw, -- 597
			uiInkDraw, -- 597
			uiArt, -- 597
			uiGlow, -- 597
			ctx -- 597
		) -- 597
		return false -- 598
	end -- 598
	local appear = math.min(1, self.openAnimT) -- 601
	local layout = self:computeLayout(ctx, #bench.recipes) -- 602
	local bx = layout.benchX -- 603
	local by = layout.benchY -- 604
	local bw = layout.benchW -- 605
	local bh = layout.benchH -- 606
	fillVGradRect( -- 609
		uiDraw, -- 610
		0, -- 611
		0, -- 612
		ctx.uiW, -- 613
		by + bh + 64, -- 614
		Color( -- 615
			12, -- 615
			10, -- 615
			10, -- 615
			math.floor(168 * appear + 0.5) -- 615
		), -- 615
		Color(12, 10, 10, 0) -- 616
	) -- 616
	self:drawWoodenBenchBody( -- 620
		uiDraw, -- 620
		uiInkDraw, -- 620
		uiArt, -- 620
		uiGlow, -- 620
		bx, -- 620
		by, -- 620
		bw, -- 620
		bh, -- 620
		appear -- 620
	) -- 620
	ctx.texts:put( -- 623
		"md", -- 623
		"安全工台 · 改制鸟铳", -- 623
		bx + 54, -- 623
		by + bh - 26, -- 623
		toColor(PALETTE.amberCore), -- 623
		0, -- 623
		0.5, -- 623
		"Left", -- 623
		2, -- 623
		0.96 * appear, -- 623
		0.08 -- 623
	) -- 623
	drawHairline( -- 624
		uiInkDraw, -- 624
		uiArt, -- 624
		"cb_head_line", -- 624
		bx + bw * 0.5, -- 624
		by + bh - 46, -- 624
		bw - 36, -- 624
		PALETTE.amberDim, -- 624
		0.55 * appear, -- 624
		false, -- 624
		2 -- 624
	) -- 624
	local hoverX = (ctx.input.uiInside and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 626
	local hoverY = (ctx.input.uiInside and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 627
	local closeHover = (ctx.input.uiInside or ctx.input.inside) and self.closeBox:containsPoint(Vec2(hoverX, hoverY)) -- 628
	uiInkDraw:drawRect( -- 629
		self.closeBox, -- 630
		Color( -- 631
			24, -- 631
			18, -- 631
			16, -- 631
			math.floor((closeHover and 215 or 155) * appear + 0.5) -- 631
		), -- 631
		0.9, -- 632
		toColor(closeHover and PALETTE.amberCore or PALETTE.silkDim, 185 * appear) -- 633
	) -- 633
	local closeText = ctx.input:isGamepadMode() and getActiveTarget():keyTagFor("back", "gamepad", ctx.input.gamepadLayout) .. " 收起" or "收起" -- 635
	ctx.texts:put( -- 638
		"xs", -- 639
		closeText, -- 640
		self.closeBox.x + self.closeBox.width * 0.5, -- 641
		self.closeBox.y + self.closeBox.height * 0.5, -- 642
		toColor(closeHover and PALETTE.textBright or PALETTE.textMid), -- 643
		0.5, -- 644
		0.5, -- 645
		"Center", -- 646
		1.4, -- 647
		0.95 * appear, -- 648
		0.06 -- 649
	) -- 649
	self:drawTableMaterials( -- 653
		uiDraw, -- 653
		uiInkDraw, -- 653
		uiArt, -- 653
		ctx, -- 653
		bench, -- 653
		bx + 18, -- 653
		by + 22, -- 653
		layout.matW - 14, -- 653
		bh - 76, -- 653
		appear -- 653
	) -- 653
	local i = 0 -- 656
	do -- 656
		i = 0 -- 657
		while i < #bench.recipes and i < #self.cardBoxes do -- 657
			self:drawRecipeCard( -- 658
				uiDraw, -- 659
				uiInkDraw, -- 660
				uiArt, -- 661
				uiGlow, -- 662
				ctx, -- 663
				bench, -- 664
				bench.recipes[i + 1], -- 665
				self.cardBoxes[i + 1], -- 666
				i == self.selectedIdx, -- 667
				appear -- 668
			) -- 668
			i = i + 1 -- 657
		end -- 657
	end -- 657
	if self.handoverRemaining > 0.01 then -- 657
		self:drawHandoverOverlay( -- 674
			uiDraw, -- 674
			uiInkDraw, -- 674
			uiArt, -- 674
			uiGlow, -- 674
			ctx -- 674
		) -- 674
	end -- 674
	return true -- 677
end -- 583
function CraftBenchPlugin.prototype.drawWoodenBenchBody(self, uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear) -- 680
	uiDraw:drawRect( -- 692
		Rect(bx, by, bw, bh), -- 692
		Color( -- 692
			WOOD_BODY.r, -- 692
			WOOD_BODY.g, -- 692
			WOOD_BODY.b, -- 692
			math.floor(244 * appear + 0.5) -- 692
		), -- 692
		1.4, -- 692
		toColor(PALETTE.amberDim, 190 * appear) -- 692
	) -- 692
	uiArt:tryPlacePath( -- 693
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 693
		"cb_wood_tex", -- 693
		bx + bw * 0.5, -- 693
		by + bh * 0.5, -- 693
		bw - 4, -- 693
		bh - 12, -- 693
		{ -- 693
			anchorX = 0.5, -- 694
			anchorY = 0.5, -- 695
			color = Color(172, 132, 98, 255), -- 696
			opacity = 0.34 * appear, -- 697
			smooth = true, -- 698
			layer = 0 -- 699
		} -- 699
	) -- 699
	uiDraw:drawRect( -- 702
		Rect(bx - 8, by + bh - 10, bw + 16, 14), -- 702
		Color( -- 702
			WOOD_TOP.r, -- 702
			WOOD_TOP.g, -- 702
			WOOD_TOP.b, -- 702
			math.floor(250 * appear + 0.5) -- 702
		), -- 702
		1, -- 702
		WOOD_EDGE -- 702
	) -- 702
	uiInkDraw:drawSegment( -- 703
		Vec2(bx - 6, by + bh + 3), -- 703
		Vec2(bx + bw + 6, by + bh + 3), -- 703
		1.2, -- 703
		toColor(PALETTE.amberCore, 115 * appear) -- 703
	) -- 703
	uiDraw:drawRect( -- 705
		Rect(bx + 18, by - 26, 22, 26), -- 705
		Color( -- 705
			WOOD_DARK.r, -- 705
			WOOD_DARK.g, -- 705
			WOOD_DARK.b, -- 705
			math.floor(235 * appear + 0.5) -- 705
		) -- 705
	) -- 705
	uiDraw:drawRect( -- 706
		Rect(bx + bw - 40, by - 26, 22, 26), -- 706
		Color( -- 706
			WOOD_DARK.r, -- 706
			WOOD_DARK.g, -- 706
			WOOD_DARK.b, -- 706
			math.floor(235 * appear + 0.5) -- 706
		) -- 706
	) -- 706
	local g = 1 -- 709
	do -- 709
		g = 1 -- 710
		while g <= 4 do -- 710
			local gy = by + (bh - 50) * (g / 5) -- 711
			uiDraw:drawSegment( -- 712
				Vec2(bx + 10, gy), -- 712
				Vec2(bx + bw - 10, gy), -- 712
				0.75, -- 712
				Color( -- 712
					34, -- 712
					23, -- 712
					18, -- 712
					math.floor(92 * appear + 0.5) -- 712
				) -- 712
			) -- 712
			g = g + 1 -- 710
		end -- 710
	end -- 710
	local lx = bx + 28 -- 716
	local ly = by + bh - 24 -- 717
	uiArt:tryPlace( -- 718
		"prop_lantern", -- 718
		"cb_lantern", -- 718
		lx, -- 718
		ly, -- 718
		20, -- 718
		26, -- 718
		{opacity = 0.94 * appear, layer = 4} -- 718
	) -- 718
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 719
	fillRadialGlow( -- 720
		uiGlow, -- 721
		lx + 10, -- 722
		ly - 10, -- 723
		260 * pulse, -- 724
		180 * pulse, -- 725
		Color( -- 726
			238, -- 726
			198, -- 726
			128, -- 726
			math.floor(38 * appear + 0.5) -- 726
		), -- 726
		Color(238, 180, 92, 0), -- 727
		16 -- 728
	) -- 728
end -- 680
function CraftBenchPlugin.prototype.drawTableMaterials(self, uiDraw, uiInkDraw, uiArt, ctx, bench, x, y, w, h, appear) -- 732
	uiDraw:drawRect( -- 744
		Rect(x, y, w, h), -- 744
		Color( -- 744
			26, -- 744
			20, -- 744
			17, -- 744
			math.floor(188 * appear + 0.5) -- 744
		), -- 744
		0.9, -- 744
		toColor(PALETTE.amberDim, 130 * appear) -- 744
	) -- 744
	drawFiligreeCorners( -- 745
		uiInkDraw, -- 745
		uiArt, -- 745
		"cb_mat_frame", -- 745
		x + 3, -- 745
		y + 3, -- 745
		w - 6, -- 745
		h - 6, -- 745
		PALETTE.amberDim, -- 745
		0.48 * appear, -- 745
		16, -- 745
		false, -- 745
		2 -- 745
	) -- 745
	ctx.texts:put( -- 747
		"xs", -- 747
		"案边持有", -- 747
		x + 12, -- 747
		y + h - 18, -- 747
		toColor(PALETTE.amberCore), -- 747
		0, -- 747
		0.5, -- 747
		"Left", -- 747
		1.4, -- 747
		0.92 * appear, -- 747
		0.06 -- 747
	) -- 747
	uiInkDraw:drawSegment( -- 748
		Vec2(x + 10, y + h - 32), -- 748
		Vec2(x + w - 10, y + h - 32), -- 748
		0.75, -- 748
		toColor(PALETTE.amberDim, 115 * appear) -- 748
	) -- 748
	local keys = sortedMaterialKeys(bench.inventory, bench.recipes) -- 750
	local i = 0 -- 751
	do -- 751
		i = 0 -- 752
		while i < #keys and i < 4 do -- 752
			local mat = keys[i + 1] -- 753
			local count = bench.inventory[mat] or 0 -- 754
			local isMissing = self.missingFlashT > 0.02 and __TS__ArrayIndexOf(self.missingList, mat) >= 0 -- 755
			local shake = isMissing and math.sin(self.animTime * 54) * 3.5 or 0 -- 756
			local rowY = y + h - 62 - i * 48 -- 757
			if isMissing then -- 757
				uiDraw:drawRect( -- 760
					Rect(x + 6 + shake, rowY - 18, w - 12, 38), -- 760
					toColor(PALETTE.rougeSoft, 145 * appear), -- 760
					1, -- 760
					toColor(PALETTE.crimsonCore, 220 * appear) -- 760
				) -- 760
			end -- 760
			local matClip = (mat == "bell_tally" or mat == "bell") and "pickup_bell" or (mat == "scrap" and "pickup_scrap" or (mat == "wedge" and "pickup_wedge" or (mat == "ammo" and "pickup_ammo" or "pickup_wood"))) -- 764
			local shown = math.max( -- 769
				1, -- 769
				math.min(3, count) -- 769
			) -- 769
			local t = 0 -- 770
			do -- 770
				t = 0 -- 771
				while t < shown do -- 771
					do -- 771
						local tx = x + 22 + t * 19 + shake -- 772
						local filled = t < count -- 773
						if uiArt:tryPlacePath( -- 773
							"assets/art/props_ming.clip|" .. matClip, -- 774
							(("cb_mat_" .. mat) .. "_") .. tostring(t), -- 774
							tx, -- 774
							rowY, -- 774
							20, -- 774
							20, -- 774
							{ -- 774
								anchorX = 0.5, -- 775
								anchorY = 0.5, -- 776
								preserveAspect = true, -- 777
								color = filled and Color(255, 255, 255, 255) or Color(138, 134, 128, 255), -- 778
								opacity = (filled and 0.96 or 0.34) * appear, -- 779
								layer = 3 -- 780
							} -- 780
						) then -- 780
							goto __continue104 -- 782
						end -- 782
						if mat == "bell_tally" or mat == "bell" then -- 782
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
							if filled then -- 800
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
					end -- 804
					::__continue104:: -- 804
					t = t + 1 -- 771
				end -- 771
			end -- 771
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
			i = i + 1 -- 752
		end -- 752
	end -- 752
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
end -- 732
function CraftBenchPlugin.prototype.resolveWeaponName(self, bench, weaponId) -- 843
	local i = 0 -- 844
	do -- 844
		i = 0 -- 845
		while i < #bench.recipes do -- 845
			if bench.recipes[i + 1].id == weaponId then -- 845
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
	if not uiArt:tryPlace( -- 869
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
	if selected then -- 879
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
	local weaponArtPath = recipe.enhancedEffect == "echo" and "assets/art/vfx_craft_art.clip|craft_echo_gun" or (recipe.enhancedEffect == "light" and "assets/art/vfx_craft_art.clip|craft_lantern_gun" or "assets/art/props_ming.clip|pickup_quickbelt") -- 918
	uiArt:tryPlacePath( -- 923
		weaponArtPath, -- 923
		"cb_wpn_art_" .. recipe.id, -- 923
		box.x + box.width * 0.5, -- 923
		box.y + 68, -- 923
		math.min(box.width - 36, 126), -- 923
		34, -- 923
		{ -- 923
			anchorX = 0.5, -- 924
			anchorY = 0.5, -- 925
			preserveAspect = true, -- 926
			smooth = true, -- 927
			opacity = (selected and 0.96 or 0.78) * appear, -- 928
			layer = 3 -- 929
		} -- 929
	) -- 929
	local btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34) -- 933
	local btnLabel = equipped and "已佩此铳" or (recipe.crafted and "改佩此铳" or (isPending and "制器中……" or (canCraft and "制成并试握" or "材料不足"))) -- 934
	local btnBg = equipped and Color( -- 937
		168, -- 938
		46, -- 938
		44, -- 938
		math.floor(32 * appear + 0.5) -- 938
	) or (selected and (canCraft or recipe.crafted) and Color( -- 938
		32, -- 940
		30, -- 940
		32, -- 940
		math.floor(218 * appear + 0.5) -- 940
	) or Color( -- 940
		32, -- 941
		30, -- 941
		32, -- 941
		math.floor((highlightMissing and 42 or 24) * appear + 0.5) -- 941
	)) -- 941
	local btnTextCol = selected and (canCraft or recipe.crafted) and not equipped and PALETTE.xuanPaper or (highlightMissing and PALETTE.rouge or PALETTE.xuanInk) -- 942
	uiInkDraw:drawRect( -- 945
		btnRect, -- 945
		btnBg, -- 945
		0.9, -- 945
		toColor(highlightMissing and PALETTE.rouge or PALETTE.xuanInkSub, 175 * appear) -- 945
	) -- 945
	ctx.texts:put( -- 946
		"sm", -- 947
		btnLabel, -- 948
		btnRect.x + btnRect.width * 0.5, -- 949
		btnRect.y + btnRect.height * 0.5, -- 950
		toColor(btnTextCol), -- 951
		0.5, -- 952
		0.5, -- 953
		"Center", -- 954
		1.6, -- 955
		0.96 * appear, -- 956
		0 -- 957
	) -- 957
end -- 853
function CraftBenchPlugin.prototype.drawMiniReloadPreview(self, uiInkDraw, uiGlow, cx, cy, effect, appear) -- 962
	local step = 20 -- 970
	local samplePath = effect == "light" and ({ -- 971
		0, -- 971
		1, -- 971
		2, -- 971
		5, -- 971
		8 -- 971
	}) or (effect == "echo" and ({ -- 971
		0, -- 971
		1, -- 971
		4, -- 971
		5, -- 971
		8 -- 971
	}) or ({ -- 971
		0, -- 971
		3, -- 971
		6, -- 971
		7, -- 971
		8 -- 971
	})) -- 971
	local accent = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberDim or PALETTE.xuanInk) -- 972
	uiInkDraw:drawRect( -- 975
		Rect(cx - 32, cy - 32, 64, 64), -- 975
		Color( -- 975
			224, -- 975
			218, -- 975
			206, -- 975
			math.floor(145 * appear + 0.5) -- 975
		), -- 975
		0.8, -- 975
		toColor(PALETTE.xuanInkSub, 120 * appear) -- 975
	) -- 975
	local i = 0 -- 976
	do -- 976
		i = 0 -- 977
		while i < #RELOAD_GRID do -- 977
			local g = RELOAD_GRID[i + 1] -- 978
			local nx = cx + (g.col - 1) * step -- 979
			local ny = cy + (g.row - 1) * step -- 980
			uiInkDraw:drawDot( -- 981
				Vec2(nx, ny), -- 981
				1.8, -- 981
				toColor(PALETTE.xuanInkSub, 130 * appear) -- 981
			) -- 981
			i = i + 1 -- 977
		end -- 977
	end -- 977
	do -- 977
		i = 0 -- 985
		while i < #samplePath - 1 do -- 985
			local a = RELOAD_GRID[samplePath[i + 1] + 1] -- 986
			local b = RELOAD_GRID[samplePath[i + 1 + 1] + 1] -- 987
			uiInkDraw:drawSegment( -- 988
				Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step), -- 989
				Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step), -- 990
				1.8, -- 991
				toColor(accent, 220 * appear) -- 992
			) -- 992
			i = i + 1 -- 985
		end -- 985
	end -- 985
	local keyNode = effect == "light" and RELOAD_GRID[3] or (effect == "echo" and RELOAD_GRID[5] or RELOAD_GRID[9]) -- 997
	local kx = cx + (keyNode.col - 1) * step -- 998
	local ky = cy + (keyNode.row - 1) * step -- 999
	drawReloadPatternGlyph( -- 1000
		uiInkDraw, -- 1000
		kx, -- 1000
		ky, -- 1000
		7.5, -- 1000
		effect, -- 1000
		accent, -- 1000
		appear -- 1000
	) -- 1000
	fillRadialGlow( -- 1001
		uiGlow, -- 1001
		kx, -- 1001
		ky, -- 1001
		14, -- 1001
		14, -- 1001
		toColor(PALETTE.amberCore, 45 * appear), -- 1001
		Color(244, 234, 214, 0), -- 1001
		10 -- 1001
	) -- 1001
end -- 962
function CraftBenchPlugin.prototype.drawHandoverOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1005
	local prog = math.max( -- 1012
		0, -- 1012
		math.min( -- 1012
			1, -- 1012
			1 - self.handoverRemaining / math.max(0.01, self.handoverDuration) -- 1012
		) -- 1012
	) -- 1012
	local fade = prog < 0.14 and prog / 0.14 or (prog > 0.84 and (1 - prog) / 0.16 or 1) -- 1013
	local cx = ctx.uiW * 0.5 -- 1014
	local cy = ctx.uiH * 0.64 -- 1015
	local panelW = math.min( -- 1016
		416, -- 1016
		math.floor(ctx.uiW * 0.34 + 0.5) -- 1016
	) -- 1016
	local panelH = math.floor(panelW * 9 / 16 + 0.5) -- 1017
	local isEcho = self.handoverEffect == "echo" -- 1018
	local isFullFirstCraft = self.handoverDuration >= 0.8 -- 1019
	local seq = isFullFirstCraft and (isEcho and ({ -- 1020
		{slot = "comic_m02_echo_f01", start = 0, ["end"] = 0.095, transition = "cut"}, -- 1023
		{slot = "comic_m02_echo_f02", start = 0.095, ["end"] = 0.185, transition = "cut"}, -- 1024
		{slot = "comic_m02_echo_f03", start = 0.185, ["end"] = 0.275, transition = "cut"}, -- 1025
		{slot = "comic_m02_echo_f04", start = 0.275, ["end"] = 0.365, transition = "cut"}, -- 1026
		{slot = "comic_m02_echo_f05", start = 0.365, ["end"] = 0.45, transition = "cut"}, -- 1027
		{slot = "comic_m02_echo_f06", start = 0.45, ["end"] = 0.53, transition = "cut"}, -- 1028
		{slot = "comic_m02_echo_f07", start = 0.53, ["end"] = 0.61, transition = "cut"}, -- 1029
		{slot = "comic_m02_echo_f08", start = 0.61, ["end"] = 0.695, transition = "cut"}, -- 1030
		{slot = "comic_m02_echo_f09", start = 0.695, ["end"] = 0.785, transition = "cut"}, -- 1031
		{slot = "comic_m02_echo_f10", start = 0.785, ["end"] = 0.885, transition = "cut"}, -- 1032
		{slot = "comic_m02_echo_f11", start = 0.885, ["end"] = 1, transition = "cut"} -- 1033
	}) or ({ -- 1033
		{slot = "comic_m02_lantern_f01", start = 0, ["end"] = 0.083, transition = "cut"}, -- 1036
		{slot = "comic_m02_lantern_f02", start = 0.083, ["end"] = 0.166, transition = "cut"}, -- 1037
		{slot = "comic_m02_lantern_f03", start = 0.166, ["end"] = 0.25, transition = "cut"}, -- 1038
		{slot = "comic_m02_lantern_f04", start = 0.25, ["end"] = 0.333, transition = "cut"}, -- 1039
		{slot = "comic_m02_lantern_f05", start = 0.333, ["end"] = 0.416, transition = "cut"}, -- 1040
		{slot = "comic_m02_lantern_f06", start = 0.416, ["end"] = 0.5, transition = "cut"}, -- 1041
		{slot = "comic_m02_lantern_f07", start = 0.5, ["end"] = 0.583, transition = "cut"}, -- 1042
		{slot = "comic_m02_lantern_f08", start = 0.583, ["end"] = 0.666, transition = "cut"}, -- 1043
		{slot = "comic_m02_lantern_f09", start = 0.666, ["end"] = 0.75, transition = "cut"}, -- 1044
		{slot = "comic_m02_lantern_f10", start = 0.75, ["end"] = 0.833, transition = "cut"}, -- 1045
		{slot = "comic_m02_lantern_f11", start = 0.833, ["end"] = 0.916, transition = "cut"}, -- 1046
		{slot = "comic_m02_lantern_f12", start = 0.916, ["end"] = 1, transition = "cut"} -- 1047
	})) or (isEcho and ({{slot = "comic_m02_echo_f05", start = 0, ["end"] = 0.24, transition = "cut"}, {slot = "comic_m02_echo_f07", start = 0.24, ["end"] = 0.5, transition = "cut"}, {slot = "comic_m02_echo_f08", start = 0.5, ["end"] = 0.76, transition = "cut"}, {slot = "comic_m02_echo_f11", start = 0.76, ["end"] = 1, transition = "cut"}}) or ({{slot = "comic_m02_lantern_f06", start = 0, ["end"] = 0.24, transition = "cut"}, {slot = "comic_m02_lantern_f08", start = 0.24, ["end"] = 0.5, transition = "cut"}, {slot = "comic_m02_lantern_f10", start = 0.5, ["end"] = 0.76, transition = "cut"}, {slot = "comic_m02_lantern_f12", start = 0.76, ["end"] = 1, transition = "cut"}})) -- 1047
	fillRadialGlow( -- 1063
		uiGlow, -- 1064
		cx, -- 1065
		cy, -- 1066
		panelW * 0.68, -- 1067
		panelH * 0.72, -- 1068
		toColor( -- 1069
			isEcho and PALETTE.jadeMist or PALETTE.amberCore, -- 1069
			math.floor(58 * fade + 0.5) -- 1069
		), -- 1069
		Color(24, 22, 18, 0), -- 1070
		16 -- 1071
	) -- 1071
	drawComicInsertPanel( -- 1073
		uiDraw, -- 1074
		uiInkDraw, -- 1075
		uiArt, -- 1076
		seq, -- 1077
		prog, -- 1078
		{x = cx - panelW * 0.5, y = cy - panelH * 0.5, w = panelW, h = panelH}, -- 1079
		fade, -- 1080
		isEcho and "cb_m02_echo" or "cb_m02_lantern", -- 1081
		4 -- 1082
	) -- 1082
	local capY = cy - panelH * 0.5 - 24 -- 1085
	drawSilkVeil( -- 1086
		uiDraw, -- 1086
		uiArt, -- 1086
		"cb_handover_veil", -- 1086
		cx, -- 1086
		capY, -- 1086
		panelW + 24, -- 1086
		30, -- 1086
		PALETTE.inkWash, -- 1086
		0.86 * fade, -- 1086
		5 -- 1086
	) -- 1086
	drawReloadPatternGlyph( -- 1087
		uiInkDraw, -- 1087
		cx - panelW * 0.42, -- 1087
		capY, -- 1087
		7.5, -- 1087
		self.handoverEffect, -- 1087
		PALETTE.amberCore, -- 1087
		fade -- 1087
	) -- 1087
	local caption = isFullFirstCraft and self.handoverWeaponName .. " 已成 · 周戍试握上手" or self.handoverWeaponName .. " 已交接佩用" -- 1088
	ctx.texts:put( -- 1091
		"xs", -- 1091
		caption, -- 1091
		cx + 8, -- 1091
		capY, -- 1091
		toColor(PALETTE.amberCore), -- 1091
		0.5, -- 1091
		0.5, -- 1091
		"Center", -- 1091
		1.4, -- 1091
		0.96 * fade, -- 1091
		0.08 -- 1091
	) -- 1091
end -- 1005
function ____exports.createCraftBenchPlugin(contract) -- 1095
	return __TS__New(____exports.CraftBenchPlugin, contract) -- 1096
end -- 1095
return ____exports -- 1095