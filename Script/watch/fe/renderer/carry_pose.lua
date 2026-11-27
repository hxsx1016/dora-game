-- [ts]: carry_pose.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 16
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 16
local ____occlusion = require("Script.watch.fe.occlusion") -- 17
local depthOrder = ____occlusion.depthOrder -- 17
local ____theme = require("Script.watch.fe.theme") -- 19
local PALETTE = ____theme.PALETTE -- 19
local fillRadialGlow = ____theme.fillRadialGlow -- 19
local toColor = ____theme.toColor -- 19
--- 同一道青布补线袖口（同源 cuff_shots.CUFF_PALETTE）与明初小满红褐短袄色板
local CUFF_CLOTH = toColor(CUFF_PALETTE.indigoBase) -- 35
local CUFF_MEND = toColor(CUFF_PALETTE.stitchThread) -- 36
local CHILD_SLEEVE = Color(164, 78, 54, 255) -- 37
local CHILD_SKIN = Color(236, 210, 182, 255) -- 38
local CHILD_VEST = Color(146, 68, 48, 255) -- 39
local NEEDLE_CORD = Color(198, 166, 114, 240) -- 40
local function clamp01(v) -- 42
	return math.max( -- 43
		0, -- 43
		math.min(1, v) -- 43
	) -- 43
end -- 42
local function smoothStep(t) -- 46
	local k = clamp01(t) -- 47
	return k * k * (3 - 2 * k) -- 48
end -- 46
____exports.CarryPosePlugin = __TS__Class() -- 51
local CarryPosePlugin = ____exports.CarryPosePlugin -- 51
CarryPosePlugin.name = "CarryPosePlugin" -- 51
function CarryPosePlugin.prototype.____constructor(self) -- 51
	self.id = "fe-02-carry-pose" -- 52
	self.animTime = 0 -- 54
	self.smoothedFacing = 1 -- 55
	self.mountT = 0 -- 56
	self.benchDropT = 0 -- 57
	self.reachT = 0 -- 58
	self.mode = "none" -- 59
	self.childAnchorX = 0 -- 60
	self.childAnchorY = 0 -- 61
	self.handoverActive = false -- 62
	self.carryAudioRoomSession = -1 -- 63
	self.shotUntil = -1 -- 64
	self.shotFacing = 1 -- 65
end -- 51
function CarryPosePlugin.prototype.getPoseState(self) -- 67
	return { -- 68
		mode = self.mode, -- 69
		smoothedFacing = self.smoothedFacing, -- 70
		mountT = self.mountT, -- 71
		benchDropT = self.benchDropT, -- 72
		reachT = self.reachT, -- 73
		childAnchorX = self.childAnchorX, -- 74
		childAnchorY = self.childAnchorY, -- 75
		handoverActive = self.handoverActive -- 76
	} -- 76
end -- 67
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 80
	self.animTime = 0 -- 81
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 82
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 83
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 84
	self.reachT = 0 -- 85
	self.mode = self:resolveMode(view) -- 86
	self.childAnchorX = p.player.x -- 87
	self.childAnchorY = p.player.y -- 88
	self.handoverActive = false -- 89
	self.carryAudioRoomSession = -1 -- 90
	self.shotUntil = -1 -- 91
	self.shotFacing = self.smoothedFacing -- 92
end -- 80
function CarryPosePlugin.prototype.resolveMode(self, view) -- 95
	local bc = view.backCarry -- 96
	if bc.atBench or view.craftBench.active then -- 96
		return "atBench" -- 98
	end -- 98
	if bc.mounting then -- 98
		return "mounting" -- 101
	end -- 101
	if bc.active then -- 101
		return "carrying" -- 104
	end -- 104
	if bc.handInHand then -- 104
		return "handInHand" -- 107
	end -- 107
	return "none" -- 109
end -- 95
function CarryPosePlugin.prototype.update(self, ctx) -- 112
	local view = ctx.view -- 113
	local p = ctx.p -- 114
	self.mode = self:resolveMode(view) -- 115
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 116
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 116
		return -- 119
	end -- 119
	if ctx.paused then -- 119
		return -- 122
	end -- 122
	local wdt = math.max(0, ctx.worldDt) -- 125
	local udt = math.max(0, ctx.uiDt) -- 126
	if ctx.events.shotFired then -- 126
		self.shotUntil = p.ticks + 10 -- 129
		if ctx.events.shotTrace ~= nil then -- 129
			self.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 and -1 or 1 -- 131
		else -- 131
			self.shotFacing = p.player.facing >= 0 and 1 or -1 -- 133
		end -- 133
	end -- 133
	if wdt > 0 then -- 133
		self.animTime = self.animTime + wdt -- 138
		local targetF = p.player.facing >= 0 and 1 or -1 -- 141
		local turnK = math.min(1, wdt * 15) -- 142
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 143
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 143
			self.smoothedFacing = targetF -- 145
		end -- 145
		if self.mode == "mounting" then -- 145
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 150
		elseif self.mode == "carrying" then -- 150
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 152
		elseif self.mode == "handInHand" or self.mode == "none" then -- 152
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 154
		end -- 154
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 158
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 159
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 159
			self.benchDropT = dropTarget -- 161
		end -- 161
	end -- 161
	if udt > 0 then -- 161
		local reachTarget = view.reloadSession.active and 1 or 0 -- 167
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 168
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 171
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 171
			self.reachT = reachTarget -- 173
		end -- 173
	end -- 173
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 173
		local hasBackendEvent = false -- 180
		local i = 0 -- 181
		do -- 181
			i = 0 -- 182
			while i < #ctx.events.rawEvents do -- 182
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 182
					hasBackendEvent = true -- 184
					break -- 185
				end -- 185
				i = i + 1 -- 182
			end -- 182
		end -- 182
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 188
		if not hasBackendEvent then -- 188
			ctx.audio:playOnce( -- 190
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 191
				"sfx", -- 192
				"assets/audio/combat/carry_start.wav", -- 193
				0.82, -- 194
				"combat:carry_start", -- 195
				p.ticks -- 196
			) -- 196
		end -- 196
	end -- 196
end -- 112
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 202
	local view = ctx.view -- 208
	local p = ctx.p -- 209
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 209
		return -- 211
	end -- 211
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 211
		return -- 214
	end -- 214
	if self.mode == "handInHand" then -- 214
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 218
		return -- 219
	end -- 219
	worldArt:hideLastPlacement("actor_child") -- 223
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 223
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 226
		return -- 227
	end -- 227
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 230
end -- 202
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 234
	local p = ctx.p -- 240
	local cam = ctx.cam -- 241
	local soldier = p.player -- 242
	local partner = p.partner -- 243
	local depthEnabled = p.room.depth ~= nil -- 244
	local f = soldier.facing >= 0 and 1 or -1 -- 245
	local speed = math.max( -- 246
		math.abs(soldier.vx), -- 246
		math.abs(soldier.depthSpeed) -- 246
	) -- 246
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 249
	local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2 or 0 -- 250
	local childWX = nearPartner and partner.x or soldier.x + f * 30 + lag -- 251
	local childWY = nearPartner and partner.y or soldier.y -- 252
	local childDepth = nearPartner and partner.depth or soldier.depth -- 253
	self.childAnchorX = childWX -- 254
	self.childAnchorY = childWY -- 255
	if soldier.rollT <= 0 and not p.gripping then -- 255
		local sx = cam:sx(soldier.x) -- 259
		local sy = cam:sy(soldier.y, soldier.depth) -- 260
		local bob = speed > 8 and math.abs(math.sin(self.animTime * 10.5)) * cam:len(2.2) or math.sin(self.animTime * 2.2) * cam:len(0.6) -- 261
		local duoH = cam:len(soldier.h * 1.03) -- 262
		if worldArt:tryPlacePath( -- 262
			"assets/art/actors_extra.clip|duo_hand_walk", -- 263
			"carry_duo_hand", -- 263
			sx, -- 263
			sy + bob, -- 263
			duoH, -- 263
			duoH, -- 263
			{ -- 263
				anchorX = 0.28, -- 264
				anchorY = 0, -- 265
				preserveAspect = true, -- 266
				facing = f, -- 267
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 268
			} -- 268
		) then -- 268
			worldArt:hideLastPlacement("actor_child") -- 270
			worldArt:hideLastPlacement("actor_soldier") -- 271
			fgDraw:drawEllipse( -- 272
				Vec2( -- 272
					sx + f * cam:len(24), -- 272
					sy + 1 -- 272
				), -- 272
				cam:len(12), -- 272
				3, -- 272
				Color(10, 10, 12, 125) -- 272
			) -- 272
			return -- 273
		end -- 273
	end -- 273
	if not nearPartner then -- 273
		worldArt:hideLastPlacement("actor_child") -- 278
		local childStep = math.floor(self.animTime * 13) -- 279
		local slot = speed > 8 and "child_run" or "child_idle" -- 280
		local scx = cam:sx(childWX) -- 281
		local scy = cam:sy(childWY, childDepth) -- 282
		local cW = cam:len(22) -- 283
		local cH = cam:len(64) -- 284
		worldArt:tryPlace( -- 285
			slot, -- 285
			"carry_child_walk", -- 285
			scx, -- 285
			scy, -- 285
			cW, -- 285
			cH, -- 285
			{ -- 285
				facing = f, -- 286
				frame = speed > 8 and childStep or 0, -- 287
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 288
			} -- 288
		) -- 288
		fgDraw:drawEllipse( -- 290
			Vec2(scx, scy + 1), -- 290
			cW * 0.46, -- 290
			3.2, -- 290
			Color(10, 10, 12, 130) -- 290
		) -- 290
	end -- 290
	local sHandX = cam:sx(soldier.x - f * 8) -- 293
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 294
	local cHandX = cam:sx(childWX + f * 7) -- 295
	local cHandY = cam:sy(childWY + 36, childDepth) -- 296
	local swayY = speed > 8 and math.sin(self.animTime * 10.5) * cam:len(2.4) or math.sin(self.animTime * 2.2) * cam:len(0.8) -- 297
	local claspX = (sHandX + cHandX) * 0.5 -- 298
	local claspY = (sHandY + cHandY) * 0.5 + swayY -- 299
	fgDraw:drawSegment( -- 301
		Vec2( -- 301
			sHandX, -- 301
			sHandY + cam:len(5) -- 301
		), -- 301
		Vec2(claspX, claspY), -- 301
		math.max( -- 301
			2.6, -- 301
			cam:len(3) -- 301
		), -- 301
		CUFF_CLOTH -- 301
	) -- 301
	local mendX = sHandX + (claspX - sHandX) * 0.72 -- 302
	local mendY = sHandY + cam:len(5) + (claspY - (sHandY + cam:len(5))) * 0.72 -- 303
	fgDraw:drawSegment( -- 304
		Vec2(mendX - f * 2, mendY - 1.5), -- 304
		Vec2(mendX + f * 2, mendY + 1.5), -- 304
		1.3, -- 304
		CUFF_MEND -- 304
	) -- 304
	fgDraw:drawSegment( -- 305
		Vec2(cHandX, cHandY), -- 305
		Vec2(claspX, claspY), -- 305
		math.max( -- 305
			2, -- 305
			cam:len(2.2) -- 305
		), -- 305
		CHILD_SLEEVE -- 305
	) -- 305
	fgDraw:drawDot( -- 306
		Vec2(claspX - f * 2.5, claspY + 1), -- 306
		math.max( -- 306
			1.8, -- 306
			cam:len(1.4) -- 306
		), -- 306
		NEEDLE_CORD -- 306
	) -- 306
	fgDraw:drawCircle( -- 307
		Vec2(claspX, claspY), -- 307
		math.max( -- 307
			2.8, -- 307
			cam:len(2.4) -- 307
		), -- 307
		CHILD_SKIN -- 307
	) -- 307
	fgGlow:drawDot( -- 308
		Vec2(claspX, claspY), -- 308
		math.max( -- 308
			2.2, -- 308
			cam:len(1.8) -- 308
		), -- 308
		toColor(PALETTE.amberCore, 155) -- 308
	) -- 308
end -- 234
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 312
	local p = ctx.p -- 318
	local cam = ctx.cam -- 319
	local soldier = p.player -- 320
	local depthEnabled = p.room.depth ~= nil -- 321
	local sf = self.smoothedFacing -- 322
	local faceSign = sf >= 0 and 1 or -1 -- 323
	local speed = math.max( -- 324
		math.abs(soldier.vx), -- 324
		math.abs(soldier.depthSpeed) -- 324
	) -- 324
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 327
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 328
	local walking = speed > 8 and soldier.onGround -- 333
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2.3 or math.sin(self.animTime * 2.5) * 0.9 -- 334
	local targetBackX = soldier.x - sf * 13 -- 339
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 340
	local startGroundX = soldier.x - sf * 24 -- 343
	local startGroundY = soldier.y -- 344
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 345
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 347
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 348
	self.childAnchorX = childWX -- 349
	self.childAnchorY = childWY -- 350
	local cx = cam:sx(childWX) -- 352
	local cy = cam:sy(childWY, soldier.depth) -- 353
	local childW = cam:len(22) -- 354
	local childH = cam:len(42 + (1 - kMount) * 18) -- 355
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 355
		local firing = p.ticks < self.shotUntil -- 359
		local duoClip = firing and "duo_carry_fire" or (walking and "duo_carry_run" or "duo_carry_idle") -- 360
		local duoAnchorX = firing and 0.36 or 0.54 -- 361
		local duoFacing = firing and self.shotFacing or faceSign -- 362
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 363
		local crouchScale = (soldier.covered or p.coverHug) and 0.86 or 1.05 -- 364
		local duoH = cam:len(soldier.h * crouchScale) -- 365
		local sx = cam:sx(soldier.x) -- 366
		local sy = cam:sy(soldier.y, soldier.depth) + cam:len(bob * 0.7) -- 367
		if worldArt:tryPlacePath( -- 367
			"assets/art/actors_extra.clip|" .. duoClip, -- 368
			"carry_duo_sprite", -- 368
			sx, -- 368
			sy, -- 368
			duoH, -- 368
			duoH, -- 368
			{ -- 368
				anchorX = duoAnchorX, -- 369
				anchorY = 0, -- 370
				preserveAspect = true, -- 371
				facing = duoFacing, -- 372
				layer = duoLayer -- 373
			} -- 373
		) then -- 373
			worldArt:hideLastPlacement("actor_soldier") -- 375
			if self.reachT > 0.05 then -- 375
				local reachFrac = smoothStep(self.reachT) -- 378
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 379
				local gy = sy + duoH * 0.72 -- 380
				fillRadialGlow( -- 381
					fgGlow, -- 382
					gx, -- 383
					gy, -- 384
					cam:len(10 * reachFrac), -- 385
					cam:len(10 * reachFrac), -- 386
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 387
					Color(244, 234, 214, 0), -- 388
					10 -- 389
				) -- 389
			end -- 389
			return -- 392
		end -- 392
	end -- 392
	if self.mode == "mounting" and kMount < 0.72 then -- 392
		local scx = cam:sx(soldier.x) -- 398
		local scy = cam:sy(soldier.y, soldier.depth) -- 399
		fgDraw:drawEllipse( -- 400
			Vec2( -- 400
				scx - sf * cam:len(6), -- 400
				scy + 1 -- 400
			), -- 400
			cam:len(22), -- 400
			4.2, -- 400
			Color(10, 10, 12, 110) -- 400
		) -- 400
	end -- 400
	local backSlot = kMount < 0.45 and "child_crouch" or "child_peek" -- 404
	local tilt = -sf * (walking and 5.5 or 2.2) -- 405
	local childLayer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 406
	local placed = worldArt:tryPlace( -- 407
		backSlot, -- 407
		"carry_child", -- 407
		cx, -- 407
		cy, -- 407
		childW, -- 407
		childH, -- 407
		{facing = faceSign, angle = tilt, layer = childLayer} -- 407
	) -- 407
	if not placed then -- 407
		fgDraw:drawPolygon( -- 415
			{ -- 415
				Vec2(cx - childW * 0.4, cy + childH * 0.1), -- 416
				Vec2(cx + childW * 0.4, cy + childH * 0.1), -- 417
				Vec2(cx + childW * 0.3, cy + childH * 0.72), -- 418
				Vec2(cx - childW * 0.35, cy + childH * 0.72) -- 419
			}, -- 419
			CHILD_VEST, -- 420
			1, -- 420
			toColor(PALETTE.amberCore, 165) -- 420
		) -- 420
		fgDraw:drawCircle( -- 421
			Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), -- 421
			childW * 0.32, -- 421
			CHILD_SKIN -- 421
		) -- 421
	end -- 421
	local shoulderX = cam:sx(soldier.x + sf * 3) -- 425
	local shoulderY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth) -- 426
	local childShoulderX = cam:sx(childWX + sf * 5) -- 427
	local childShoulderY = cam:sy(childWY + 26, soldier.depth) -- 428
	local hipSupportX = cam:sx(soldier.x - sf * 10) -- 431
	local hipSupportY = cam:sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth) -- 432
	fgDraw:drawSegment( -- 433
		Vec2( -- 434
			cam:sx(soldier.x - sf * 2), -- 434
			cam:sy(soldier.y + 42 - crouchDip, soldier.depth) -- 434
		), -- 434
		Vec2(hipSupportX, hipSupportY), -- 435
		math.max( -- 436
			2.4, -- 436
			cam:len(2.8) -- 436
		), -- 436
		CUFF_CLOTH -- 437
	) -- 437
	fgDraw:drawSegment( -- 439
		Vec2(hipSupportX - sf * 2, hipSupportY + 1), -- 440
		Vec2(hipSupportX + sf * 3, hipSupportY + 1), -- 441
		1.2, -- 442
		CUFF_MEND -- 443
	) -- 443
	if self.reachT > 0.05 and kMount > 0.7 then -- 443
		local reachFrac = smoothStep(self.reachT) -- 448
		local elbowX = shoulderX + sf * cam:len(4 + reachFrac * 5) -- 449
		local elbowY = shoulderY + cam:len(1 + reachFrac * 3) -- 450
		local handEndX = elbowX + sf * cam:len(5 + reachFrac * 11) -- 451
		local handEndY = elbowY + cam:len(2 + reachFrac * 5) -- 452
		fgDraw:drawSegment( -- 453
			Vec2(childShoulderX, childShoulderY), -- 453
			Vec2(elbowX, elbowY), -- 453
			math.max( -- 453
				2, -- 453
				cam:len(2.1) -- 453
			), -- 453
			CHILD_SLEEVE -- 453
		) -- 453
		fgDraw:drawSegment( -- 454
			Vec2(elbowX, elbowY), -- 454
			Vec2( -- 454
				handEndX - sf * cam:len(3), -- 454
				handEndY - cam:len(1) -- 454
			), -- 454
			math.max( -- 454
				1.7, -- 454
				cam:len(1.8) -- 454
			), -- 454
			CHILD_SLEEVE -- 454
		) -- 454
		fgDraw:drawDot( -- 456
			Vec2( -- 456
				handEndX - sf * cam:len(3.2), -- 456
				handEndY - cam:len(0.8) -- 456
			), -- 456
			math.max( -- 456
				1.5, -- 456
				cam:len(1.2) -- 456
			), -- 456
			NEEDLE_CORD -- 456
		) -- 456
		fgDraw:drawCircle( -- 457
			Vec2(handEndX, handEndY), -- 457
			math.max( -- 457
				2.1, -- 457
				cam:len(1.8) -- 457
			), -- 457
			CHILD_SKIN -- 457
		) -- 457
		fgDraw:drawSegment( -- 458
			Vec2(handEndX, handEndY), -- 458
			Vec2( -- 458
				handEndX + sf * cam:len(3.5), -- 458
				handEndY + cam:len(1.2) -- 458
			), -- 458
			math.max( -- 458
				1.1, -- 458
				cam:len(1) -- 458
			), -- 458
			CHILD_SKIN -- 458
		) -- 458
		fillRadialGlow( -- 459
			fgGlow, -- 460
			handEndX + sf * cam:len(3), -- 461
			handEndY + cam:len(1), -- 462
			cam:len(7 * reachFrac), -- 463
			cam:len(7 * reachFrac), -- 464
			toColor(PALETTE.amberCore, 72 * reachFrac), -- 465
			Color(244, 234, 214, 0), -- 466
			10 -- 467
		) -- 467
	elseif kMount > 0.35 then -- 467
		local armAlpha = clamp01((kMount - 0.35) / 0.65) -- 470
		local gripX = shoulderX + sf * cam:len(4) -- 471
		local gripY = shoulderY - cam:len(2) -- 472
		fgDraw:drawSegment( -- 473
			Vec2(childShoulderX, childShoulderY), -- 474
			Vec2(gripX, gripY), -- 475
			math.max( -- 476
				1.8, -- 476
				cam:len(2) -- 476
			), -- 476
			Color( -- 477
				164, -- 477
				78, -- 477
				54, -- 477
				math.floor(255 * armAlpha + 0.5) -- 477
			) -- 477
		) -- 477
		fgDraw:drawDot( -- 479
			Vec2(gripX - sf * 2, gripY), -- 479
			math.max( -- 479
				1.5, -- 479
				cam:len(1.2) -- 479
			), -- 479
			Color( -- 479
				198, -- 479
				166, -- 479
				114, -- 479
				math.floor(235 * armAlpha + 0.5) -- 479
			) -- 479
		) -- 479
		fgDraw:drawCircle( -- 480
			Vec2(gripX, gripY), -- 480
			math.max( -- 480
				2, -- 480
				cam:len(1.7) -- 480
			), -- 480
			Color( -- 480
				236, -- 480
				210, -- 480
				182, -- 480
				math.floor(255 * armAlpha + 0.5) -- 480
			) -- 480
		) -- 480
	end -- 480
end -- 312
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 485
	local p = ctx.p -- 491
	local cam = ctx.cam -- 492
	local soldier = p.player -- 493
	local depthEnabled = p.room.depth ~= nil -- 494
	local f = soldier.facing >= 0 and 1 or -1 -- 495
	local dropK = smoothStep(self.benchDropT) -- 496
	local startX = soldier.x - f * 12 -- 499
	local startY = soldier.y + 26 -- 500
	local standX = soldier.x + f * 30 -- 501
	local standY = soldier.y -- 502
	local childWX = startX + (standX - startX) * dropK -- 503
	local childWY = startY + (standY - startY) * dropK -- 504
	self.childAnchorX = childWX -- 505
	self.childAnchorY = childWY -- 506
	local cx = cam:sx(childWX) -- 508
	local cy = cam:sy(childWY, soldier.depth) -- 509
	local cW = cam:len(22) -- 510
	local cH = cam:len(64) -- 511
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 513
	local slot = handing and "child_offer" or "child_idle" -- 514
	worldArt:tryPlace( -- 516
		slot, -- 516
		"carry_child_bench", -- 516
		cx, -- 516
		cy, -- 516
		cW, -- 516
		cH, -- 516
		{ -- 516
			facing = -f, -- 517
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 518
		} -- 518
	) -- 518
	fgDraw:drawEllipse( -- 520
		Vec2( -- 520
			cx, -- 520
			cam:sy(soldier.y, soldier.depth) + 1 -- 520
		), -- 520
		cW * 0.48 * dropK, -- 520
		3.2, -- 520
		Color(10, 10, 12, 130) -- 520
	) -- 520
	if handing then -- 520
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 524
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 525
		local midY = cam:sy( -- 526
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 526
			soldier.depth -- 526
		) -- 526
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 527
		local gunW = cam:len(38) -- 528
		local gunH = cam:len(14) -- 529
		if not worldArt:tryPlacePath( -- 529
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 530
			"carry_bench_gun", -- 530
			midX, -- 530
			midY, -- 530
			gunW, -- 530
			gunH, -- 530
			{ -- 530
				anchorX = 0.5, -- 531
				anchorY = 0.5, -- 532
				preserveAspect = true, -- 533
				facing = f, -- 534
				smooth = true, -- 535
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 536
			} -- 536
		) then -- 536
			local gunLen = cam:len(22) -- 538
			fgDraw:drawSegment( -- 539
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 539
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 539
				3.2, -- 539
				Color(108, 74, 52, 255) -- 539
			) -- 539
			fgDraw:drawSegment( -- 540
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 540
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 540
				1.8, -- 540
				Color(148, 144, 134, 245) -- 540
			) -- 540
		end -- 540
		fillRadialGlow( -- 542
			fgGlow, -- 542
			midX, -- 542
			midY, -- 542
			cam:len(14), -- 542
			cam:len(10), -- 542
			toColor(PALETTE.amberCore, 72), -- 542
			Color(244, 234, 214, 0), -- 542
			10 -- 542
		) -- 542
	end -- 542
end -- 485
function ____exports.createCarryPosePlugin() -- 547
	return __TS__New(____exports.CarryPosePlugin) -- 548
end -- 547
return ____exports -- 547