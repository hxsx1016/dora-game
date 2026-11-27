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
		local scx = cam:sx(childWX) -- 267
		local scy = cam:sy(childWY, childDepth) -- 268
		local cW = cam:len(22) -- 269
		local cH = cam:len(64) -- 270
		local pose = { -- 271
			facing = f, -- 271
			layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 271
		} -- 271
		partnerPlaced = speed > 8 and worldArt:tryPlaceRun( -- 272
			"child", -- 272
			"carry_child_walk", -- 272
			scx, -- 272
			scy, -- 272
			cW, -- 272
			cH, -- 272
			self.animTime * 1.8, -- 272
			pose -- 272
		) or worldArt:tryPlace( -- 272
			"child_idle", -- 273
			"carry_child_walk", -- 273
			scx, -- 273
			scy, -- 273
			cW, -- 273
			cH, -- 273
			pose -- 273
		) -- 273
		fgDraw:drawEllipse( -- 274
			Vec2(scx, scy + 1), -- 274
			cW * 0.46, -- 274
			3.2, -- 274
			Color(10, 10, 12, 130) -- 274
		) -- 274
	end -- 274
	self.childAnchorX = childWX -- 277
	self.childAnchorY = childWY -- 278
	local playerPlaced = false -- 281
	if speed <= 8 and soldier.rollT <= 0 then -- 281
		playerPlaced = worldArt:tryPlace( -- 283
			"fe_soldier_hand_hold", -- 284
			"carry_soldier_hold", -- 285
			cam:sx(soldier.x), -- 286
			cam:sy(soldier.y, soldier.depth), -- 287
			cam:len(36), -- 288
			cam:len(soldier.h), -- 289
			{ -- 290
				facing = f, -- 291
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 292
			} -- 292
		) -- 292
	end -- 292
	local sHandX = cam:sx(soldier.x - f * 8) -- 296
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 297
	local cHandX = cam:sx(childWX + f * 7) -- 298
	local cHandY = cam:sy(childWY + 36, childDepth) -- 299
	local claspX = (sHandX + cHandX) * 0.5 -- 300
	local claspY = (sHandY + cHandY) * 0.5 -- 301
	fillRadialGlow( -- 302
		fgGlow, -- 302
		claspX, -- 302
		claspY, -- 302
		cam:len(10), -- 302
		cam:len(8), -- 302
		toColor(PALETTE.amberCore, 76), -- 302
		Color(244, 234, 214, 0), -- 302
		10 -- 302
	) -- 302
	return {player = playerPlaced, partner = partnerPlaced} -- 303
end -- 219
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 307
	local p = ctx.p -- 312
	local cam = ctx.cam -- 313
	local soldier = p.player -- 314
	local depthEnabled = p.room.depth ~= nil -- 315
	local sf = self.smoothedFacing -- 316
	local faceSign = sf >= 0 and 1 or -1 -- 317
	local speed = math.max( -- 318
		math.abs(soldier.vx), -- 318
		math.abs(soldier.depthSpeed) -- 318
	) -- 318
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 321
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 322
	local walking = speed > 8 and soldier.onGround -- 326
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 327
	local targetBackX = soldier.x - sf * 13 -- 332
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 333
	local startGroundX = soldier.x - sf * 24 -- 334
	local startGroundY = soldier.y -- 335
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 336
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 338
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 339
	self.childAnchorX = childWX -- 340
	self.childAnchorY = childWY -- 341
	local scx = cam:sx(soldier.x) -- 343
	local scy = cam:sy(soldier.y, soldier.depth) -- 344
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 345
	if self.mode == "mounting" and kMount < 0.72 then -- 345
		local playerPlaced = worldArt:tryPlace( -- 349
			"fe_soldier_kneel_mount", -- 349
			"carry_soldier_kneel", -- 349
			scx, -- 349
			scy, -- 349
			cam:len(42), -- 349
			cam:len(soldier.h * 0.9), -- 349
			{facing = faceSign, layer = baseLayer} -- 349
		) -- 349
		local cx = cam:sx(childWX) -- 353
		local cy = cam:sy(childWY, soldier.depth) -- 354
		local partnerPlaced = worldArt:tryPlace( -- 355
			kMount < 0.45 and "child_crouch" or "child_peek", -- 355
			"carry_child", -- 355
			cx, -- 355
			cy, -- 355
			cam:len(22), -- 355
			cam:len(42 + (1 - kMount) * 18), -- 355
			{facing = faceSign, layer = baseLayer + 1} -- 355
		) -- 355
		return {player = playerPlaced, partner = partnerPlaced} -- 359
	end -- 359
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 359
		local firing = p.ticks < self.shotUntil -- 364
		local duoClip = firing and "duo_carry_fire" or (walking and "duo_carry_run" or "duo_carry_idle") -- 365
		local duoAnchorX = firing and 0.36 or 0.54 -- 366
		local duoFacing = firing and self.shotFacing or faceSign -- 367
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 368
		local crouchScale = (soldier.covered or p.coverHug) and 0.86 or 1.05 -- 369
		local duoH = cam:len(soldier.h * crouchScale) -- 370
		local sx = cam:sx(soldier.x) -- 371
		local sy = cam:sy(soldier.y, soldier.depth) + cam:len(bob * 0.7) -- 372
		if worldArt:tryPlacePath( -- 372
			"assets/art/actors_extra.clip|" .. duoClip, -- 373
			"carry_duo_sprite", -- 373
			sx, -- 373
			sy, -- 373
			duoH, -- 373
			duoH, -- 373
			{ -- 373
				anchorX = duoAnchorX, -- 374
				anchorY = 0, -- 375
				preserveAspect = true, -- 376
				facing = duoFacing, -- 377
				layer = duoLayer -- 378
			} -- 378
		) then -- 378
			if self.reachT > 0.05 then -- 378
				local reachFrac = smoothStep(self.reachT) -- 382
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 383
				local gy = sy + duoH * 0.72 -- 384
				fillRadialGlow( -- 385
					fgGlow, -- 386
					gx, -- 387
					gy, -- 388
					cam:len(10 * reachFrac), -- 389
					cam:len(10 * reachFrac), -- 390
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 391
					Color(244, 234, 214, 0), -- 392
					10 -- 393
				) -- 393
			end -- 393
			return {player = true, partner = true} -- 396
		end -- 396
	end -- 396
	local cx = cam:sx(childWX) -- 401
	local cy = cam:sy(childWY, soldier.depth) -- 402
	local partnerPlaced = worldArt:tryPlace( -- 403
		"child_peek", -- 403
		"carry_child", -- 403
		cx, -- 403
		cy, -- 403
		cam:len(22), -- 403
		cam:len(40), -- 403
		{ -- 403
			facing = faceSign, -- 404
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 405
		} -- 405
	) -- 405
	return {player = false, partner = partnerPlaced} -- 407
end -- 307
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 411
	local p = ctx.p -- 417
	local cam = ctx.cam -- 418
	local soldier = p.player -- 419
	local depthEnabled = p.room.depth ~= nil -- 420
	local f = soldier.facing >= 0 and 1 or -1 -- 421
	local dropK = smoothStep(self.benchDropT) -- 422
	local startX = soldier.x - f * 12 -- 425
	local startY = soldier.y + 26 -- 426
	local standX = soldier.x + f * 30 -- 427
	local standY = soldier.y -- 428
	local childWX = startX + (standX - startX) * dropK -- 429
	local childWY = startY + (standY - startY) * dropK -- 430
	self.childAnchorX = childWX -- 431
	self.childAnchorY = childWY -- 432
	local cx = cam:sx(childWX) -- 434
	local cy = cam:sy(childWY, soldier.depth) -- 435
	local cW = cam:len(22) -- 436
	local cH = cam:len(64) -- 437
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 439
	local slot = handing and "child_offer" or "child_idle" -- 440
	local partnerPlaced = worldArt:tryPlace( -- 441
		slot, -- 441
		"carry_child_bench", -- 441
		cx, -- 441
		cy, -- 441
		cW, -- 441
		cH, -- 441
		{ -- 441
			facing = -f, -- 442
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 443
		} -- 443
	) -- 443
	fgDraw:drawEllipse( -- 445
		Vec2( -- 445
			cx, -- 445
			cam:sy(soldier.y, soldier.depth) + 1 -- 445
		), -- 445
		cW * 0.48 * dropK, -- 445
		3.2, -- 445
		Color(10, 10, 12, 130) -- 445
	) -- 445
	if handing then -- 445
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 449
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 450
		local midY = cam:sy( -- 451
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 451
			soldier.depth -- 451
		) -- 451
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 452
		local gunW = cam:len(38) -- 453
		local gunH = cam:len(14) -- 454
		if not worldArt:tryPlacePath( -- 454
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 455
			"carry_bench_gun", -- 455
			midX, -- 455
			midY, -- 455
			gunW, -- 455
			gunH, -- 455
			{ -- 455
				anchorX = 0.5, -- 456
				anchorY = 0.5, -- 457
				preserveAspect = true, -- 458
				facing = f, -- 459
				smooth = true, -- 460
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 461
			} -- 461
		) then -- 461
			local gunLen = cam:len(22) -- 463
			fgDraw:drawSegment( -- 464
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 464
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 464
				3.2, -- 464
				Color(108, 74, 52, 255) -- 464
			) -- 464
			fgDraw:drawSegment( -- 465
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 465
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 465
				1.8, -- 465
				Color(148, 144, 134, 245) -- 465
			) -- 465
		end -- 465
		fillRadialGlow( -- 467
			fgGlow, -- 467
			midX, -- 467
			midY, -- 467
			cam:len(15), -- 467
			cam:len(11), -- 467
			toColor(PALETTE.amberCore, 72), -- 467
			Color(244, 234, 214, 0), -- 467
			10 -- 467
		) -- 467
	end -- 467
	return partnerPlaced -- 469
end -- 411
function ____exports.createCarryPosePlugin() -- 473
	return __TS__New(____exports.CarryPosePlugin) -- 474
end -- 473
return ____exports -- 473