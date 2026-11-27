-- [ts]: carry_pose.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Vec2 = ____Dora.Vec2 -- 10
local ____occlusion = require("Script.watch.fe.occlusion") -- 14
local depthOrder = ____occlusion.depthOrder -- 14
local ____theme = require("Script.watch.fe.theme") -- 16
local PALETTE = ____theme.PALETTE -- 16
local fillRadialGlow = ____theme.fillRadialGlow -- 16
local toColor = ____theme.toColor -- 16
local function clamp01(v) -- 31
	return math.max( -- 32
		0, -- 32
		math.min(1, v) -- 32
	) -- 32
end -- 31
local function smoothStep(t) -- 35
	local k = clamp01(t) -- 36
	return k * k * (3 - 2 * k) -- 37
end -- 35
____exports.CarryPosePlugin = __TS__Class() -- 40
local CarryPosePlugin = ____exports.CarryPosePlugin -- 40
CarryPosePlugin.name = "CarryPosePlugin" -- 40
function CarryPosePlugin.prototype.____constructor(self) -- 40
	self.id = "fe-02-carry-pose" -- 41
	self.animTime = 0 -- 43
	self.smoothedFacing = 1 -- 44
	self.mountT = 0 -- 45
	self.benchDropT = 0 -- 46
	self.reachT = 0 -- 47
	self.mode = "none" -- 48
	self.childAnchorX = 0 -- 49
	self.childAnchorY = 0 -- 50
	self.handoverActive = false -- 51
	self.carryAudioRoomSession = -1 -- 52
	self.shotUntil = -1 -- 54
	self.shotFacing = 1 -- 55
end -- 40
function CarryPosePlugin.prototype.getPoseState(self) -- 57
	return { -- 58
		mode = self.mode, -- 59
		smoothedFacing = self.smoothedFacing, -- 60
		mountT = self.mountT, -- 61
		benchDropT = self.benchDropT, -- 62
		reachT = self.reachT, -- 63
		childAnchorX = self.childAnchorX, -- 64
		childAnchorY = self.childAnchorY, -- 65
		handoverActive = self.handoverActive -- 66
	} -- 66
end -- 57
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 70
	self.animTime = 0 -- 71
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 72
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 73
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 74
	self.reachT = 0 -- 75
	self.mode = self:resolveMode(view) -- 76
	self.childAnchorX = p.player.x -- 77
	self.childAnchorY = p.player.y -- 78
	self.handoverActive = false -- 79
	self.carryAudioRoomSession = -1 -- 80
	self.shotUntil = -1 -- 81
	self.shotFacing = self.smoothedFacing -- 82
end -- 70
function CarryPosePlugin.prototype.resolveMode(self, view) -- 85
	local bc = view.backCarry -- 86
	if bc.atBench or view.craftBench.active then -- 86
		return "atBench" -- 88
	end -- 88
	if bc.mounting then -- 88
		return "mounting" -- 91
	end -- 91
	if bc.active then -- 91
		return "carrying" -- 94
	end -- 94
	if bc.handInHand then -- 94
		return "handInHand" -- 97
	end -- 97
	return "none" -- 99
end -- 85
function CarryPosePlugin.prototype.update(self, ctx) -- 102
	local view = ctx.view -- 103
	local p = ctx.p -- 104
	self.mode = self:resolveMode(view) -- 105
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 106
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 106
		return -- 109
	end -- 109
	if ctx.paused then -- 109
		return -- 112
	end -- 112
	local wdt = math.max(0, ctx.worldDt) -- 115
	local udt = math.max(0, ctx.uiDt) -- 116
	if ctx.events.shotFired then -- 116
		self.shotUntil = p.ticks + 10 -- 119
		if ctx.events.shotTrace ~= nil then -- 119
			self.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 and -1 or 1 -- 121
		else -- 121
			self.shotFacing = p.player.facing >= 0 and 1 or -1 -- 123
		end -- 123
	end -- 123
	if wdt > 0 then -- 123
		self.animTime = self.animTime + wdt -- 128
		local targetF = p.player.facing >= 0 and 1 or -1 -- 131
		local turnK = math.min(1, wdt * 15) -- 132
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 133
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 133
			self.smoothedFacing = targetF -- 135
		end -- 135
		if self.mode == "mounting" then -- 135
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 140
		elseif self.mode == "carrying" then -- 140
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 142
		elseif self.mode == "handInHand" or self.mode == "none" then -- 142
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 144
		end -- 144
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 148
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 149
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 149
			self.benchDropT = dropTarget -- 151
		end -- 151
	end -- 151
	if udt > 0 then -- 151
		local reachTarget = view.reloadSession.active and 1 or 0 -- 157
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 158
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 161
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 161
			self.reachT = reachTarget -- 163
		end -- 163
	end -- 163
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 163
		local hasBackendEvent = false -- 170
		local i = 0 -- 171
		do -- 171
			i = 0 -- 172
			while i < #ctx.events.rawEvents do -- 172
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 172
					hasBackendEvent = true -- 174
					break -- 175
				end -- 175
				i = i + 1 -- 172
			end -- 172
		end -- 172
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 178
		if not hasBackendEvent then -- 178
			ctx.audio:playOnce( -- 180
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 181
				"sfx", -- 182
				"assets/audio/combat/carry_start.wav", -- 183
				0.82, -- 184
				"combat:carry_start", -- 185
				p.ticks -- 186
			) -- 186
		end -- 186
	end -- 186
end -- 102
function CarryPosePlugin.prototype.drawPartyPose(self, fgDraw, fgGlow, worldArt, ctx) -- 192
	local view = ctx.view -- 198
	local p = ctx.p -- 199
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 199
		return -- 201
	end -- 201
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 201
		return -- 204
	end -- 204
	if self.mode == "handInHand" then -- 204
		return self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 208
	end -- 208
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 208
		return { -- 212
			player = false, -- 212
			partner = self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 212
		} -- 212
	end -- 212
	return self:drawCarriedOrMounting(fgGlow, worldArt, ctx) -- 215
end -- 192
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 219
	local p = ctx.p -- 225
	local cam = ctx.cam -- 226
	local soldier = p.player -- 227
	local partner = p.partner -- 228
	local depthEnabled = p.room.depth ~= nil -- 229
	local f = soldier.facing >= 0 and 1 or -1 -- 230
	local speed = math.max( -- 231
		math.abs(soldier.vx), -- 231
		math.abs(soldier.depthSpeed) -- 231
	) -- 231
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 234
	local childWX = partner.x -- 235
	local childWY = partner.y -- 236
	local childDepth = partner.depth -- 237
	if soldier.rollT <= 0 and not p.gripping then -- 237
		local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 241
		local sx = cam:sx(soldier.x) -- 242
		local sy = cam:sy(soldier.y, soldier.depth) -- 243
		local bob = speed > 8 and math.abs(math.sin(self.animTime * 10.5)) * cam:len(2.2) or math.sin(self.animTime * 2.2) * cam:len(0.6) -- 244
		local duoH = cam:len(soldier.h * 1.03) * dScale -- 245
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 246
		if worldArt:tryPlacePath( -- 246
			"assets/art/actors_extra.clip|duo_hand_walk", -- 247
			"carry_duo_hand", -- 247
			sx, -- 247
			sy + bob, -- 247
			duoH, -- 247
			duoH, -- 247
			{ -- 247
				anchorX = 0.28, -- 248
				anchorY = 0, -- 249
				preserveAspect = true, -- 250
				facing = f, -- 251
				layer = duoLayer -- 252
			} -- 252
		) then -- 252
			worldArt:tryPlace( -- 254
				"dp_shadow_contact", -- 254
				"carry_duo_hand_sh", -- 254
				sx + f * cam:len(24) * dScale, -- 254
				sy + 1, -- 254
				cam:len(30) * dScale, -- 254
				cam:len(9) * dScale, -- 254
				{layer = duoLayer - 1, opacity = 0.82} -- 254
			) -- 254
			self.childAnchorX = childWX -- 257
			self.childAnchorY = childWY -- 258
			return {player = true, partner = true} -- 259
		end -- 259
	end -- 259
	local partnerPlaced = false -- 263
	if not nearPartner then -- 263
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 266
		childWX = soldier.x - f * 26 + lag -- 267
		childWY = soldier.y -- 268
		childDepth = soldier.depth -- 269
		local dScale = cam:depthScale(childDepth, depthEnabled) -- 271
		local scx = cam:sx(childWX) -- 272
		local scy = cam:sy(childWY, childDepth) -- 273
		local cW = cam:len(22) * dScale -- 274
		local cH = cam:len(64) * dScale -- 275
		local cLayer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 276
		local pose = {facing = f, layer = cLayer} -- 277
		partnerPlaced = speed > 8 and worldArt:tryPlaceRun( -- 278
			"child", -- 278
			"carry_child_walk", -- 278
			scx, -- 278
			scy, -- 278
			cW, -- 278
			cH, -- 278
			self.animTime * 1.8, -- 278
			pose -- 278
		) or worldArt:tryPlace( -- 278
			"child_idle", -- 279
			"carry_child_walk", -- 279
			scx, -- 279
			scy, -- 279
			cW, -- 279
			cH, -- 279
			pose -- 279
		) -- 279
		worldArt:tryPlace( -- 280
			"dp_shadow_contact", -- 280
			"carry_child_walk_sh", -- 280
			scx, -- 280
			scy + 1, -- 280
			cW * 1.4, -- 280
			cam:len(8) * dScale, -- 280
			{layer = cLayer - 1, opacity = 0.8} -- 280
		) -- 280
	end -- 280
	self.childAnchorX = childWX -- 285
	self.childAnchorY = childWY -- 286
	local playerPlaced = false -- 289
	if speed <= 8 and soldier.rollT <= 0 then -- 289
		playerPlaced = worldArt:tryPlace( -- 291
			"fe_soldier_hand_hold", -- 292
			"carry_soldier_hold", -- 293
			cam:sx(soldier.x), -- 294
			cam:sy(soldier.y, soldier.depth), -- 295
			cam:len(36), -- 296
			cam:len(soldier.h), -- 297
			{ -- 298
				facing = f, -- 299
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 300
			} -- 300
		) -- 300
	end -- 300
	local sHandX = cam:sx(soldier.x - f * 8) -- 304
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 305
	local cHandX = cam:sx(childWX + f * 7) -- 306
	local cHandY = cam:sy(childWY + 36, childDepth) -- 307
	local claspX = (sHandX + cHandX) * 0.5 -- 308
	local claspY = (sHandY + cHandY) * 0.5 -- 309
	fillRadialGlow( -- 310
		fgGlow, -- 310
		claspX, -- 310
		claspY, -- 310
		cam:len(10), -- 310
		cam:len(8), -- 310
		toColor(PALETTE.amberCore, 76), -- 310
		Color(244, 234, 214, 0), -- 310
		10 -- 310
	) -- 310
	return {player = playerPlaced, partner = partnerPlaced} -- 311
end -- 219
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 315
	local p = ctx.p -- 320
	local cam = ctx.cam -- 321
	local soldier = p.player -- 322
	local depthEnabled = p.room.depth ~= nil -- 323
	local sf = self.smoothedFacing -- 324
	local faceSign = sf >= 0 and 1 or -1 -- 325
	local speed = math.max( -- 326
		math.abs(soldier.vx), -- 326
		math.abs(soldier.depthSpeed) -- 326
	) -- 326
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 329
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 330
	local walking = speed > 8 and soldier.onGround -- 334
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 335
	local targetBackX = soldier.x - sf * 13 -- 340
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 341
	local startGroundX = soldier.x - sf * 24 -- 342
	local startGroundY = soldier.y -- 343
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 344
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 346
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 347
	self.childAnchorX = childWX -- 348
	self.childAnchorY = childWY -- 349
	local scx = cam:sx(soldier.x) -- 351
	local scy = cam:sy(soldier.y, soldier.depth) -- 352
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 353
	if self.mode == "mounting" and kMount < 0.72 then -- 353
		local playerPlaced = worldArt:tryPlace( -- 357
			"fe_soldier_kneel_mount", -- 357
			"carry_soldier_kneel", -- 357
			scx, -- 357
			scy, -- 357
			cam:len(42), -- 357
			cam:len(soldier.h * 0.9), -- 357
			{facing = faceSign, layer = baseLayer} -- 357
		) -- 357
		local cx = cam:sx(childWX) -- 361
		local cy = cam:sy(childWY, soldier.depth) -- 362
		local partnerPlaced = worldArt:tryPlace( -- 363
			kMount < 0.45 and "child_crouch" or "child_peek", -- 363
			"carry_child", -- 363
			cx, -- 363
			cy, -- 363
			cam:len(22), -- 363
			cam:len(42 + (1 - kMount) * 18), -- 363
			{facing = faceSign, layer = baseLayer + 1} -- 363
		) -- 363
		return {player = playerPlaced, partner = partnerPlaced} -- 367
	end -- 367
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 367
		local firing = p.ticks < self.shotUntil -- 372
		local duoClip = firing and "duo_carry_fire" or (walking and "duo_carry_run" or "duo_carry_idle") -- 373
		local duoAnchorX = firing and 0.36 or 0.54 -- 374
		local duoFacing = firing and self.shotFacing or faceSign -- 375
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 376
		local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 377
		local crouchScale = (soldier.covered or p.coverHug) and 0.86 or 1.05 -- 378
		local duoH = cam:len(soldier.h * crouchScale) * dScale -- 379
		local sx = cam:sx(soldier.x) -- 380
		local sy = cam:sy(soldier.y, soldier.depth) + cam:len(bob * 0.7) -- 381
		if worldArt:tryPlacePath( -- 381
			"assets/art/actors_extra.clip|" .. duoClip, -- 382
			"carry_duo_sprite", -- 382
			sx, -- 382
			sy, -- 382
			duoH, -- 382
			duoH, -- 382
			{ -- 382
				anchorX = duoAnchorX, -- 383
				anchorY = 0, -- 384
				preserveAspect = true, -- 385
				facing = duoFacing, -- 386
				layer = duoLayer -- 387
			} -- 387
		) then -- 387
			if self.reachT > 0.05 then -- 387
				local reachFrac = smoothStep(self.reachT) -- 391
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 392
				local gy = sy + duoH * 0.72 -- 393
				fillRadialGlow( -- 394
					fgGlow, -- 395
					gx, -- 396
					gy, -- 397
					cam:len(10 * reachFrac), -- 398
					cam:len(10 * reachFrac), -- 399
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 400
					Color(244, 234, 214, 0), -- 401
					10 -- 402
				) -- 402
			end -- 402
			return {player = true, partner = true} -- 405
		end -- 405
	end -- 405
	local cx = cam:sx(childWX) -- 410
	local cy = cam:sy(childWY, soldier.depth) -- 411
	local partnerPlaced = worldArt:tryPlace( -- 412
		"child_peek", -- 412
		"carry_child", -- 412
		cx, -- 412
		cy, -- 412
		cam:len(22), -- 412
		cam:len(40), -- 412
		{ -- 412
			facing = faceSign, -- 413
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 414
		} -- 414
	) -- 414
	return {player = false, partner = partnerPlaced} -- 416
end -- 315
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 420
	local p = ctx.p -- 426
	local cam = ctx.cam -- 427
	local soldier = p.player -- 428
	local depthEnabled = p.room.depth ~= nil -- 429
	local f = soldier.facing >= 0 and 1 or -1 -- 430
	local dropK = smoothStep(self.benchDropT) -- 431
	local startX = soldier.x - f * 12 -- 434
	local startY = soldier.y + 26 -- 435
	local standX = soldier.x + f * 30 -- 436
	local standY = soldier.y -- 437
	local childWX = startX + (standX - startX) * dropK -- 438
	local childWY = startY + (standY - startY) * dropK -- 439
	self.childAnchorX = childWX -- 440
	self.childAnchorY = childWY -- 441
	local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 443
	local cx = cam:sx(childWX) -- 444
	local cy = cam:sy(childWY, soldier.depth) -- 445
	local cW = cam:len(22) * dScale -- 446
	local cH = cam:len(64) * dScale -- 447
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 449
	local slot = handing and "child_offer" or "child_idle" -- 450
	local benchLayer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 451
	local partnerPlaced = worldArt:tryPlace( -- 452
		slot, -- 452
		"carry_child_bench", -- 452
		cx, -- 452
		cy, -- 452
		cW, -- 452
		cH, -- 452
		{facing = -f, layer = benchLayer} -- 452
	) -- 452
	worldArt:tryPlace( -- 456
		"dp_shadow_contact", -- 456
		"carry_child_bench_sh", -- 456
		cx, -- 456
		cam:sy(soldier.y, soldier.depth) + 1, -- 456
		cW * 1.45 * math.max(0.3, dropK), -- 456
		cam:len(8) * dScale, -- 456
		{layer = benchLayer - 1, opacity = 0.8} -- 456
	) -- 456
	if handing then -- 456
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 462
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 463
		local midY = cam:sy( -- 464
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 464
			soldier.depth -- 464
		) -- 464
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 465
		local gunW = cam:len(38) -- 466
		local gunH = cam:len(14) -- 467
		if not worldArt:tryPlacePath( -- 467
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 468
			"carry_bench_gun", -- 468
			midX, -- 468
			midY, -- 468
			gunW, -- 468
			gunH, -- 468
			{ -- 468
				anchorX = 0.5, -- 469
				anchorY = 0.5, -- 470
				preserveAspect = true, -- 471
				facing = f, -- 472
				smooth = true, -- 473
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 474
			} -- 474
		) then -- 474
			local gunLen = cam:len(22) -- 476
			fgDraw:drawSegment( -- 477
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 477
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 477
				3.2, -- 477
				Color(108, 74, 52, 255) -- 477
			) -- 477
			fgDraw:drawSegment( -- 478
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 478
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 478
				1.8, -- 478
				Color(148, 144, 134, 245) -- 478
			) -- 478
		end -- 478
		fillRadialGlow( -- 480
			fgGlow, -- 480
			midX, -- 480
			midY, -- 480
			cam:len(15), -- 480
			cam:len(11), -- 480
			toColor(PALETTE.amberCore, 72), -- 480
			Color(244, 234, 214, 0), -- 480
			10 -- 480
		) -- 480
	end -- 480
	return partnerPlaced -- 482
end -- 420
function ____exports.createCarryPosePlugin() -- 486
	return __TS__New(____exports.CarryPosePlugin) -- 487
end -- 486
return ____exports -- 486