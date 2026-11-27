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
		local sx = cam:sx(soldier.x) -- 241
		local sy = cam:sy(soldier.y, soldier.depth) -- 242
		local bob = speed > 8 and math.abs(math.sin(self.animTime * 10.5)) * cam:len(2.2) or math.sin(self.animTime * 2.2) * cam:len(0.6) -- 243
		local duoH = cam:len(soldier.h * 1.03) -- 244
		if worldArt:tryPlacePath( -- 244
			"assets/art/actors_extra.clip|duo_hand_walk", -- 245
			"carry_duo_hand", -- 245
			sx, -- 245
			sy + bob, -- 245
			duoH, -- 245
			duoH, -- 245
			{ -- 245
				anchorX = 0.28, -- 246
				anchorY = 0, -- 247
				preserveAspect = true, -- 248
				facing = f, -- 249
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 250
			} -- 250
		) then -- 250
			fgDraw:drawEllipse( -- 252
				Vec2( -- 252
					sx + f * cam:len(24), -- 252
					sy + 1 -- 252
				), -- 252
				cam:len(12), -- 252
				3, -- 252
				Color(10, 10, 12, 125) -- 252
			) -- 252
			self.childAnchorX = childWX -- 253
			self.childAnchorY = childWY -- 254
			return {player = true, partner = true} -- 255
		end -- 255
	end -- 255
	local partnerPlaced = false -- 259
	if not nearPartner then -- 259
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 262
		childWX = soldier.x - f * 26 + lag -- 263
		childWY = soldier.y -- 264
		childDepth = soldier.depth -- 265
		local childStep = math.floor(self.animTime * 13) -- 267
		local slot = speed > 8 and "child_run" or "child_idle" -- 268
		local scx = cam:sx(childWX) -- 269
		local scy = cam:sy(childWY, childDepth) -- 270
		local cW = cam:len(22) -- 271
		local cH = cam:len(64) -- 272
		partnerPlaced = worldArt:tryPlace( -- 273
			slot, -- 273
			"carry_child_walk", -- 273
			scx, -- 273
			scy, -- 273
			cW, -- 273
			cH, -- 273
			{ -- 273
				facing = f, -- 274
				frame = speed > 8 and childStep or 0, -- 275
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 276
			} -- 276
		) -- 276
		fgDraw:drawEllipse( -- 278
			Vec2(scx, scy + 1), -- 278
			cW * 0.46, -- 278
			3.2, -- 278
			Color(10, 10, 12, 130) -- 278
		) -- 278
	end -- 278
	self.childAnchorX = childWX -- 281
	self.childAnchorY = childWY -- 282
	local playerPlaced = false -- 285
	if speed <= 8 and soldier.rollT <= 0 then -- 285
		playerPlaced = worldArt:tryPlace( -- 287
			"fe_soldier_hand_hold", -- 288
			"carry_soldier_hold", -- 289
			cam:sx(soldier.x), -- 290
			cam:sy(soldier.y, soldier.depth), -- 291
			cam:len(36), -- 292
			cam:len(soldier.h), -- 293
			{ -- 294
				facing = f, -- 295
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 296
			} -- 296
		) -- 296
	end -- 296
	local sHandX = cam:sx(soldier.x - f * 8) -- 300
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 301
	local cHandX = cam:sx(childWX + f * 7) -- 302
	local cHandY = cam:sy(childWY + 36, childDepth) -- 303
	local claspX = (sHandX + cHandX) * 0.5 -- 304
	local claspY = (sHandY + cHandY) * 0.5 -- 305
	fillRadialGlow( -- 306
		fgGlow, -- 306
		claspX, -- 306
		claspY, -- 306
		cam:len(10), -- 306
		cam:len(8), -- 306
		toColor(PALETTE.amberCore, 76), -- 306
		Color(244, 234, 214, 0), -- 306
		10 -- 306
	) -- 306
	return {player = playerPlaced, partner = partnerPlaced} -- 307
end -- 219
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 311
	local p = ctx.p -- 316
	local cam = ctx.cam -- 317
	local soldier = p.player -- 318
	local depthEnabled = p.room.depth ~= nil -- 319
	local sf = self.smoothedFacing -- 320
	local faceSign = sf >= 0 and 1 or -1 -- 321
	local speed = math.max( -- 322
		math.abs(soldier.vx), -- 322
		math.abs(soldier.depthSpeed) -- 322
	) -- 322
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 325
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 326
	local walking = speed > 8 and soldier.onGround -- 330
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 331
	local targetBackX = soldier.x - sf * 13 -- 336
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 337
	local startGroundX = soldier.x - sf * 24 -- 338
	local startGroundY = soldier.y -- 339
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 340
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 342
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 343
	self.childAnchorX = childWX -- 344
	self.childAnchorY = childWY -- 345
	local scx = cam:sx(soldier.x) -- 347
	local scy = cam:sy(soldier.y, soldier.depth) -- 348
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 349
	if self.mode == "mounting" and kMount < 0.72 then -- 349
		local playerPlaced = worldArt:tryPlace( -- 353
			"fe_soldier_kneel_mount", -- 353
			"carry_soldier_kneel", -- 353
			scx, -- 353
			scy, -- 353
			cam:len(42), -- 353
			cam:len(soldier.h * 0.9), -- 353
			{facing = faceSign, layer = baseLayer} -- 353
		) -- 353
		local cx = cam:sx(childWX) -- 357
		local cy = cam:sy(childWY, soldier.depth) -- 358
		local partnerPlaced = worldArt:tryPlace( -- 359
			kMount < 0.45 and "child_crouch" or "child_peek", -- 359
			"carry_child", -- 359
			cx, -- 359
			cy, -- 359
			cam:len(22), -- 359
			cam:len(42 + (1 - kMount) * 18), -- 359
			{facing = faceSign, layer = baseLayer + 1} -- 359
		) -- 359
		return {player = playerPlaced, partner = partnerPlaced} -- 363
	end -- 363
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 363
		local firing = p.ticks < self.shotUntil -- 368
		local duoClip = firing and "duo_carry_fire" or (walking and "duo_carry_run" or "duo_carry_idle") -- 369
		local duoAnchorX = firing and 0.36 or 0.54 -- 370
		local duoFacing = firing and self.shotFacing or faceSign -- 371
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 372
		local crouchScale = (soldier.covered or p.coverHug) and 0.86 or 1.05 -- 373
		local duoH = cam:len(soldier.h * crouchScale) -- 374
		local sx = cam:sx(soldier.x) -- 375
		local sy = cam:sy(soldier.y, soldier.depth) + cam:len(bob * 0.7) -- 376
		if worldArt:tryPlacePath( -- 376
			"assets/art/actors_extra.clip|" .. duoClip, -- 377
			"carry_duo_sprite", -- 377
			sx, -- 377
			sy, -- 377
			duoH, -- 377
			duoH, -- 377
			{ -- 377
				anchorX = duoAnchorX, -- 378
				anchorY = 0, -- 379
				preserveAspect = true, -- 380
				facing = duoFacing, -- 381
				layer = duoLayer -- 382
			} -- 382
		) then -- 382
			if self.reachT > 0.05 then -- 382
				local reachFrac = smoothStep(self.reachT) -- 386
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 387
				local gy = sy + duoH * 0.72 -- 388
				fillRadialGlow( -- 389
					fgGlow, -- 390
					gx, -- 391
					gy, -- 392
					cam:len(10 * reachFrac), -- 393
					cam:len(10 * reachFrac), -- 394
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 395
					Color(244, 234, 214, 0), -- 396
					10 -- 397
				) -- 397
			end -- 397
			return {player = true, partner = true} -- 400
		end -- 400
	end -- 400
	local cx = cam:sx(childWX) -- 405
	local cy = cam:sy(childWY, soldier.depth) -- 406
	local partnerPlaced = worldArt:tryPlace( -- 407
		"child_peek", -- 407
		"carry_child", -- 407
		cx, -- 407
		cy, -- 407
		cam:len(22), -- 407
		cam:len(40), -- 407
		{ -- 407
			facing = faceSign, -- 408
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 409
		} -- 409
	) -- 409
	return {player = false, partner = partnerPlaced} -- 411
end -- 311
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 415
	local p = ctx.p -- 421
	local cam = ctx.cam -- 422
	local soldier = p.player -- 423
	local depthEnabled = p.room.depth ~= nil -- 424
	local f = soldier.facing >= 0 and 1 or -1 -- 425
	local dropK = smoothStep(self.benchDropT) -- 426
	local startX = soldier.x - f * 12 -- 429
	local startY = soldier.y + 26 -- 430
	local standX = soldier.x + f * 30 -- 431
	local standY = soldier.y -- 432
	local childWX = startX + (standX - startX) * dropK -- 433
	local childWY = startY + (standY - startY) * dropK -- 434
	self.childAnchorX = childWX -- 435
	self.childAnchorY = childWY -- 436
	local cx = cam:sx(childWX) -- 438
	local cy = cam:sy(childWY, soldier.depth) -- 439
	local cW = cam:len(22) -- 440
	local cH = cam:len(64) -- 441
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 443
	local slot = handing and "child_offer" or "child_idle" -- 444
	local partnerPlaced = worldArt:tryPlace( -- 445
		slot, -- 445
		"carry_child_bench", -- 445
		cx, -- 445
		cy, -- 445
		cW, -- 445
		cH, -- 445
		{ -- 445
			facing = -f, -- 446
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 447
		} -- 447
	) -- 447
	fgDraw:drawEllipse( -- 449
		Vec2( -- 449
			cx, -- 449
			cam:sy(soldier.y, soldier.depth) + 1 -- 449
		), -- 449
		cW * 0.48 * dropK, -- 449
		3.2, -- 449
		Color(10, 10, 12, 130) -- 449
	) -- 449
	if handing then -- 449
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 453
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 454
		local midY = cam:sy( -- 455
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 455
			soldier.depth -- 455
		) -- 455
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 456
		local gunW = cam:len(38) -- 457
		local gunH = cam:len(14) -- 458
		if not worldArt:tryPlacePath( -- 458
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 459
			"carry_bench_gun", -- 459
			midX, -- 459
			midY, -- 459
			gunW, -- 459
			gunH, -- 459
			{ -- 459
				anchorX = 0.5, -- 460
				anchorY = 0.5, -- 461
				preserveAspect = true, -- 462
				facing = f, -- 463
				smooth = true, -- 464
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 465
			} -- 465
		) then -- 465
			local gunLen = cam:len(22) -- 467
			fgDraw:drawSegment( -- 468
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 468
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 468
				3.2, -- 468
				Color(108, 74, 52, 255) -- 468
			) -- 468
			fgDraw:drawSegment( -- 469
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 469
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 469
				1.8, -- 469
				Color(148, 144, 134, 245) -- 469
			) -- 469
		end -- 469
		fillRadialGlow( -- 471
			fgGlow, -- 471
			midX, -- 471
			midY, -- 471
			cam:len(15), -- 471
			cam:len(11), -- 471
			toColor(PALETTE.amberCore, 72), -- 471
			Color(244, 234, 214, 0), -- 471
			10 -- 471
		) -- 471
	end -- 471
	return partnerPlaced -- 473
end -- 415
function ____exports.createCarryPosePlugin() -- 477
	return __TS__New(____exports.CarryPosePlugin) -- 478
end -- 477
return ____exports -- 477