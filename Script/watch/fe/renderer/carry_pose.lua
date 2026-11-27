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
local DUO_HAND_CLIPS = {"assets/art/actors_duo_anim.clip|duo_hand_walk_0", "assets/art/actors_duo_anim.clip|duo_hand_walk_1", "assets/art/actors_duo_anim.clip|duo_hand_walk_2", "assets/art/actors_duo_anim.clip|duo_hand_walk_3"} -- 20
local DUO_MOUNT_CLIPS = {"assets/art/actors_duo_anim.clip|duo_mount_0", "assets/art/actors_duo_anim.clip|duo_mount_1", "assets/art/actors_duo_anim.clip|duo_mount_2", "assets/art/actors_duo_anim.clip|duo_mount_3"} -- 26
local DUO_CARRY_RUN_CLIPS = { -- 32
	"assets/art/actors_duo_anim.clip|duo_carry_run_0", -- 33
	"assets/art/actors_duo_anim.clip|duo_carry_run_1", -- 34
	"assets/art/actors_duo_anim.clip|duo_carry_run_2", -- 35
	"assets/art/actors_duo_anim.clip|duo_carry_run_3", -- 36
	"assets/art/actors_duo_anim.clip|duo_carry_run_4", -- 37
	"assets/art/actors_duo_anim.clip|duo_carry_run_5", -- 38
	"assets/art/actors_duo_anim.clip|duo_carry_run_6", -- 39
	"assets/art/actors_duo_anim.clip|duo_carry_run_7" -- 40
} -- 40
local DUO_CARRY_IDLE_CLIPS = {"assets/art/actors_duo_anim.clip|duo_carry_idle_0", "assets/art/actors_duo_anim.clip|duo_carry_idle_1", "assets/art/actors_duo_anim.clip|duo_carry_idle_2", "assets/art/actors_duo_anim.clip|duo_carry_idle_3"} -- 42
local DUO_CARRY_FIRE_CLIPS = {"assets/art/actors_duo_anim.clip|duo_carry_fire_0", "assets/art/actors_duo_anim.clip|duo_carry_fire_1", "assets/art/actors_duo_anim.clip|duo_carry_fire_2", "assets/art/actors_duo_anim.clip|duo_carry_fire_3"} -- 48
local function clamp01(v) -- 66
	return math.max( -- 67
		0, -- 67
		math.min(1, v) -- 67
	) -- 67
end -- 66
local function smoothStep(t) -- 70
	local k = clamp01(t) -- 71
	return k * k * (3 - 2 * k) -- 72
end -- 70
____exports.CarryPosePlugin = __TS__Class() -- 75
local CarryPosePlugin = ____exports.CarryPosePlugin -- 75
CarryPosePlugin.name = "CarryPosePlugin" -- 75
function CarryPosePlugin.prototype.____constructor(self) -- 75
	self.id = "fe-02-carry-pose" -- 76
	self.animTime = 0 -- 78
	self.smoothedFacing = 1 -- 79
	self.mountT = 0 -- 80
	self.benchDropT = 0 -- 81
	self.reachT = 0 -- 82
	self.mode = "none" -- 83
	self.childAnchorX = 0 -- 84
	self.childAnchorY = 0 -- 85
	self.handoverActive = false -- 86
	self.carryAudioRoomSession = -1 -- 87
	self.shotUntil = -1 -- 89
	self.shotStartTick = 0 -- 90
	self.shotFacing = 1 -- 91
	self.carryStride = 0 -- 92
	self.prevSoldierX = 0 -- 93
	self.prevSoldierDepth = 0 -- 94
end -- 75
function CarryPosePlugin.prototype.getPoseState(self) -- 96
	return { -- 97
		mode = self.mode, -- 98
		smoothedFacing = self.smoothedFacing, -- 99
		mountT = self.mountT, -- 100
		benchDropT = self.benchDropT, -- 101
		reachT = self.reachT, -- 102
		childAnchorX = self.childAnchorX, -- 103
		childAnchorY = self.childAnchorY, -- 104
		handoverActive = self.handoverActive -- 105
	} -- 105
end -- 96
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 109
	self.animTime = 0 -- 110
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 111
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 112
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 113
	self.reachT = 0 -- 114
	self.mode = self:resolveMode(view) -- 115
	self.childAnchorX = p.player.x -- 116
	self.childAnchorY = p.player.y -- 117
	self.handoverActive = false -- 118
	self.carryAudioRoomSession = -1 -- 119
	self.shotUntil = -1 -- 120
	self.shotStartTick = 0 -- 121
	self.shotFacing = self.smoothedFacing -- 122
	self.carryStride = 0 -- 123
	self.prevSoldierX = p.player.x -- 124
	self.prevSoldierDepth = p.player.depth -- 125
end -- 109
function CarryPosePlugin.prototype.resolveMode(self, view) -- 128
	local bc = view.backCarry -- 129
	if bc.atBench or view.craftBench.active then -- 130
		return "atBench" -- 131
	end -- 131
	if bc.mounting then -- 133
		return "mounting" -- 134
	end -- 134
	if bc.active then -- 136
		return "carrying" -- 137
	end -- 137
	if bc.handInHand then -- 139
		return "handInHand" -- 140
	end -- 140
	return "none" -- 142
end -- 128
function CarryPosePlugin.prototype.update(self, ctx) -- 145
	local view = ctx.view -- 146
	local p = ctx.p -- 147
	self.mode = self:resolveMode(view) -- 148
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 149
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 151
		return -- 152
	end -- 152
	if ctx.paused then -- 154
		return -- 155
	end -- 155
	local wdt = math.max(0, ctx.worldDt) -- 158
	local udt = math.max(0, ctx.uiDt) -- 159
	if ctx.events.shotFired then -- 161
		self.shotStartTick = p.ticks -- 162
		self.shotUntil = p.ticks + 18 -- 163
		if ctx.events.shotTrace ~= nil then -- 164
			self.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 and -1 or 1 -- 165
		else -- 165
			self.shotFacing = p.player.facing >= 0 and 1 or -1 -- 167
		end -- 167
	end -- 167
	if wdt > 0 then -- 171
		self.animTime = self.animTime + wdt -- 172
		local dx = p.player.x - self.prevSoldierX -- 173
		local dd = p.player.depth - self.prevSoldierDepth -- 174
		local stepDist = math.sqrt(dx * dx + dd * dd) -- 175
		self.prevSoldierX = p.player.x -- 176
		self.prevSoldierDepth = p.player.depth -- 177
		if stepDist > 0.05 and stepDist < 80 then -- 178
			self.carryStride = (self.carryStride + stepDist / math.max(40, p.player.h * 1.28)) % 1 -- 179
		end -- 179
		local targetF = p.player.facing >= 0 and 1 or -1 -- 183
		local turnK = math.min(1, wdt * 15) -- 184
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 185
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 186
			self.smoothedFacing = targetF -- 187
		end -- 187
		if self.mode == "mounting" then -- 191
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 192
		elseif self.mode == "carrying" then -- 193
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 194
		elseif self.mode == "handInHand" or self.mode == "none" then -- 195
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 196
		end -- 196
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 200
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 201
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 202
			self.benchDropT = dropTarget -- 203
		end -- 203
	end -- 203
	if udt > 0 then -- 208
		local reachTarget = view.reloadSession.active and 1 or 0 -- 209
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 210
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 213
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 214
			self.reachT = reachTarget -- 215
		end -- 215
	end -- 215
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 220
		local hasBackendEvent = false -- 222
		local i = 0 -- 223
		do -- 223
			i = 0 -- 224
			while i < #ctx.events.rawEvents do -- 224
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 225
					hasBackendEvent = true -- 226
					break -- 227
				end -- 227
				i = i + 1 -- 224
			end -- 224
		end -- 224
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 230
		if not hasBackendEvent then -- 231
			ctx.audio:playOnce( -- 232
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 233
				"sfx", -- 234
				"assets/audio/combat/carry_start.wav", -- 235
				0.82, -- 236
				"combat:carry_start", -- 237
				p.ticks -- 238
			) -- 238
		end -- 238
	end -- 238
end -- 145
function CarryPosePlugin.prototype.drawPartyPose(self, fgDraw, fgGlow, worldArt, ctx) -- 244
	local view = ctx.view -- 250
	local p = ctx.p -- 251
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 252
		return -- 253
	end -- 253
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 255
		return -- 256
	end -- 256
	if self.mode == "handInHand" then -- 259
		return self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 260
	end -- 260
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 263
		return { -- 264
			player = false, -- 264
			partner = self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 264
		} -- 264
	end -- 264
	return self:drawCarriedOrMounting(fgGlow, worldArt, ctx) -- 267
end -- 244
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 271
	local p = ctx.p -- 277
	local cam = ctx.cam -- 278
	local soldier = p.player -- 279
	local partner = p.partner -- 280
	local depthEnabled = p.room.depth ~= nil -- 281
	local f = soldier.facing >= 0 and 1 or -1 -- 282
	local speed = math.max( -- 283
		math.abs(soldier.vx), -- 283
		math.abs(soldier.depthSpeed) -- 283
	) -- 283
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 286
	local childWX = partner.x -- 287
	local childWY = partner.y -- 288
	local childDepth = partner.depth -- 289
	if soldier.rollT <= 0 and not p.gripping then -- 292
		local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 293
		local dShade = cam:depthShade(soldier.depth, depthEnabled) -- 294
		local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 295
		local duoTint = depthEnabled and soldier.depth > 6 and Color( -- 296
			tone, -- 296
			tone, -- 296
			math.min(255, tone + 8), -- 296
			255 -- 296
		) or nil -- 296
		local sx = cam:sx(soldier.x) -- 297
		local sy = cam:sy(soldier.y, soldier.depth) -- 298
		local duoH = cam:len(soldier.h * 1.03) * dScale -- 299
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 300
		local walking = speed > 8 and soldier.onGround -- 301
		local handFrame = walking and math.floor(self.carryStride * 8) % 4 or 0 -- 302
		local breathSquash = walking and 1 or 1 + math.sin(self.animTime * 2.4) * 0.012 -- 303
		if worldArt:tryPlacePath( -- 304
			DUO_HAND_CLIPS[handFrame + 1], -- 304
			"carry_duo_hand", -- 304
			sx, -- 304
			sy, -- 304
			duoH, -- 304
			duoH, -- 304
			{ -- 304
				anchorX = 0.5, -- 305
				anchorY = 0, -- 306
				preserveAspect = true, -- 307
				facing = f, -- 308
				scaleYMul = breathSquash, -- 309
				color = duoTint, -- 310
				layer = duoLayer -- 311
			} -- 311
		) then -- 311
			worldArt:tryPlace( -- 314
				"dp_shadow_contact", -- 314
				"carry_duo_hand_sh", -- 314
				sx + f * cam:len(26) * dScale, -- 314
				sy + 1, -- 314
				cam:len(28) * dScale, -- 314
				cam:len(8.5) * dScale, -- 314
				{layer = duoLayer - 1, opacity = 0.78} -- 314
			) -- 314
			self.childAnchorX = childWX -- 317
			self.childAnchorY = childWY -- 318
			return {player = true, partner = true} -- 319
		end -- 319
	end -- 319
	local partnerPlaced = false -- 323
	if not nearPartner then -- 324
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 326
		childWX = soldier.x - f * 26 + lag -- 327
		childWY = soldier.y -- 328
		childDepth = soldier.depth -- 329
		local dScale = cam:depthScale(childDepth, depthEnabled) -- 331
		local scx = cam:sx(childWX) -- 332
		local scy = cam:sy(childWY, childDepth) -- 333
		local cW = cam:len(22) * dScale -- 334
		local cH = cam:len(64) * dScale -- 335
		local cLayer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 336
		local pose = {facing = f, layer = cLayer} -- 337
		partnerPlaced = speed > 8 and worldArt:tryPlaceRun( -- 338
			"child", -- 338
			"carry_child_walk", -- 338
			scx, -- 338
			scy, -- 338
			cW, -- 338
			cH, -- 338
			self.animTime * 1.8, -- 338
			pose -- 338
		) or worldArt:tryPlace( -- 339
			"child_idle", -- 339
			"carry_child_walk", -- 339
			scx, -- 339
			scy, -- 339
			cW, -- 339
			cH, -- 339
			pose -- 339
		) -- 339
		worldArt:tryPlace( -- 340
			"dp_shadow_contact", -- 340
			"carry_child_walk_sh", -- 340
			scx, -- 340
			scy + 1, -- 340
			cW * 1.4, -- 340
			cam:len(8) * dScale, -- 340
			{layer = cLayer - 1, opacity = 0.8} -- 340
		) -- 340
	end -- 340
	self.childAnchorX = childWX -- 345
	self.childAnchorY = childWY -- 346
	local playerPlaced = false -- 349
	if speed <= 8 and soldier.rollT <= 0 then -- 350
		playerPlaced = worldArt:tryPlace( -- 351
			"fe_soldier_hand_hold", -- 352
			"carry_soldier_hold", -- 353
			cam:sx(soldier.x), -- 354
			cam:sy(soldier.y, soldier.depth), -- 355
			cam:len(36), -- 356
			cam:len(soldier.h), -- 357
			{ -- 358
				facing = f, -- 359
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 360
			} -- 360
		) -- 360
	end -- 360
	local sHandX = cam:sx(soldier.x - f * 8) -- 364
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 365
	local cHandX = cam:sx(childWX + f * 7) -- 366
	local cHandY = cam:sy(childWY + 36, childDepth) -- 367
	local claspX = (sHandX + cHandX) * 0.5 -- 368
	local claspY = (sHandY + cHandY) * 0.5 -- 369
	fillRadialGlow( -- 370
		fgGlow, -- 370
		claspX, -- 370
		claspY, -- 370
		cam:len(10), -- 370
		cam:len(8), -- 370
		toColor(PALETTE.amberCore, 76), -- 370
		Color(244, 234, 214, 0), -- 370
		10 -- 370
	) -- 370
	return {player = playerPlaced, partner = partnerPlaced} -- 371
end -- 271
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 375
	local p = ctx.p -- 380
	local cam = ctx.cam -- 381
	local soldier = p.player -- 382
	local depthEnabled = p.room.depth ~= nil -- 383
	local sf = self.smoothedFacing -- 384
	local faceSign = sf >= 0 and 1 or -1 -- 385
	local speed = math.max( -- 386
		math.abs(soldier.vx), -- 386
		math.abs(soldier.depthSpeed) -- 386
	) -- 386
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 389
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 390
	local walking = speed > 8 and soldier.onGround -- 394
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 395
	local targetBackX = soldier.x - sf * 13 -- 400
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 401
	local startGroundX = soldier.x - sf * 24 -- 402
	local startGroundY = soldier.y -- 403
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 404
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 406
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 407
	self.childAnchorX = childWX -- 408
	self.childAnchorY = childWY -- 409
	local scx = cam:sx(soldier.x) -- 411
	local scy = cam:sy(soldier.y, soldier.depth) -- 412
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 413
	local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 414
	local dShade = cam:depthShade(soldier.depth, depthEnabled) -- 415
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 416
	local duoTint = depthEnabled and soldier.depth > 6 and Color( -- 417
		tone, -- 417
		tone, -- 417
		math.min(255, tone + 8), -- 417
		255 -- 417
	) or nil -- 417
	if self.mode == "mounting" and kMount < 0.96 then -- 420
		local mountFrame = kMount < 0.28 and 0 or (kMount < 0.56 and 1 or (kMount < 0.8 and 2 or 3)) -- 421
		local mountH = cam:len(soldier.h * 1.06) * dScale -- 422
		if worldArt:tryPlacePath( -- 423
			DUO_MOUNT_CLIPS[mountFrame + 1], -- 423
			"carry_duo_mount", -- 423
			scx, -- 423
			scy, -- 423
			mountH, -- 423
			mountH, -- 423
			{ -- 423
				anchorX = 0.5, -- 424
				anchorY = 0, -- 425
				preserveAspect = true, -- 426
				facing = faceSign, -- 427
				color = duoTint, -- 428
				layer = baseLayer -- 429
			} -- 429
		) then -- 429
			return {player = true, partner = true} -- 431
		end -- 431
		local playerPlaced = worldArt:tryPlace( -- 433
			"fe_soldier_kneel_mount", -- 433
			"carry_soldier_kneel", -- 433
			scx, -- 433
			scy, -- 433
			cam:len(42) * dScale, -- 433
			cam:len(soldier.h * 0.9) * dScale, -- 433
			{facing = faceSign, color = duoTint, layer = baseLayer} -- 433
		) -- 433
		local cx = cam:sx(childWX) -- 438
		local cy = cam:sy(childWY, soldier.depth) -- 439
		local partnerPlaced = worldArt:tryPlace( -- 440
			kMount < 0.45 and "child_crouch" or "child_peek", -- 440
			"carry_child", -- 440
			cx, -- 440
			cy, -- 440
			cam:len(22) * dScale, -- 440
			cam:len(42 + (1 - kMount) * 18) * dScale, -- 440
			{facing = faceSign, color = duoTint, layer = baseLayer + 1} -- 440
		) -- 440
		return {player = playerPlaced, partner = partnerPlaced} -- 445
	end -- 445
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 449
		local firing = p.ticks < self.shotUntil -- 450
		local duoPath = DUO_CARRY_IDLE_CLIPS[1] -- 451
		local duoFacing = faceSign -- 452
		local recoilOffsetX = 0 -- 453
		local turnScaleX = 1 - math.abs(math.abs(sf) - 1) * 0.24 -- 454
		if firing then -- 455
			local elapsed = math.max(0, p.ticks - self.shotStartTick) -- 456
			local fIdx = elapsed < 2 and 0 or (elapsed < 5 and 1 or (elapsed < 12 and 2 or 3)) -- 457
			duoPath = DUO_CARRY_FIRE_CLIPS[fIdx + 1] -- 458
			duoFacing = self.shotFacing -- 459
			if fIdx == 2 then -- 460
				recoilOffsetX = -duoFacing * cam:len(3.2) * dScale -- 461
			end -- 461
		elseif walking then -- 463
			local runIdx = math.floor(self.carryStride * 8) % 8 -- 464
			duoPath = DUO_CARRY_RUN_CLIPS[runIdx + 1] -- 465
		else -- 465
			local ping = { -- 467
				0, -- 467
				1, -- 467
				2, -- 467
				3, -- 467
				2, -- 467
				1 -- 467
			} -- 467
			local idleIdx = ping[math.floor(self.animTime * 5.2) % #ping + 1] -- 468
			duoPath = DUO_CARRY_IDLE_CLIPS[idleIdx + 1] -- 469
		end -- 469
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 471
		local crouchScale = (soldier.covered or p.coverHug) and 0.88 or 1.06 -- 472
		local duoH = cam:len(soldier.h * crouchScale) * dScale -- 473
		local sx = cam:sx(soldier.x) + recoilOffsetX -- 474
		local sy = cam:sy(soldier.y, soldier.depth) -- 475
		if worldArt:tryPlacePath( -- 476
			duoPath, -- 476
			"carry_duo_sprite", -- 476
			sx, -- 476
			sy, -- 476
			duoH, -- 476
			duoH, -- 476
			{ -- 476
				anchorX = 0.5, -- 477
				anchorY = 0, -- 478
				preserveAspect = true, -- 479
				facing = duoFacing, -- 480
				scaleXMul = math.max(0.76, turnScaleX), -- 481
				color = duoTint, -- 482
				layer = duoLayer -- 483
			} -- 483
		) then -- 483
			if self.reachT > 0.05 then -- 486
				local reachFrac = smoothStep(self.reachT) -- 487
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 488
				local gy = sy + duoH * 0.72 -- 489
				fillRadialGlow( -- 490
					fgGlow, -- 491
					gx, -- 492
					gy, -- 493
					cam:len(10 * reachFrac), -- 494
					cam:len(10 * reachFrac), -- 495
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 496
					Color(244, 234, 214, 0), -- 497
					10 -- 498
				) -- 498
			end -- 498
			return {player = true, partner = true} -- 501
		end -- 501
	end -- 501
	local cx = cam:sx(childWX) -- 506
	local cy = cam:sy(childWY, soldier.depth) -- 507
	local partnerPlaced = worldArt:tryPlace( -- 508
		"child_peek", -- 508
		"carry_child", -- 508
		cx, -- 508
		cy, -- 508
		cam:len(22), -- 508
		cam:len(40), -- 508
		{ -- 508
			facing = faceSign, -- 509
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 510
		} -- 510
	) -- 510
	return {player = false, partner = partnerPlaced} -- 512
end -- 375
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 516
	local p = ctx.p -- 522
	local cam = ctx.cam -- 523
	local soldier = p.player -- 524
	local depthEnabled = p.room.depth ~= nil -- 525
	local f = soldier.facing >= 0 and 1 or -1 -- 526
	local dropK = smoothStep(self.benchDropT) -- 527
	local startX = soldier.x - f * 12 -- 530
	local startY = soldier.y + 26 -- 531
	local standX = soldier.x + f * 30 -- 532
	local standY = soldier.y -- 533
	local childWX = startX + (standX - startX) * dropK -- 534
	local childWY = startY + (standY - startY) * dropK -- 535
	self.childAnchorX = childWX -- 536
	self.childAnchorY = childWY -- 537
	local dScale = cam:depthScale(soldier.depth, depthEnabled) -- 539
	local dShade = cam:depthShade(soldier.depth, depthEnabled) -- 540
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 541
	local depthTint = depthEnabled and soldier.depth > 6 and Color( -- 542
		tone, -- 542
		tone, -- 542
		math.min(255, tone + 6), -- 542
		255 -- 542
	) or nil -- 542
	local cx = cam:sx(childWX) -- 543
	local cy = cam:sy(childWY, soldier.depth) -- 544
	local cW = cam:len(22) * dScale -- 545
	local cH = cam:len(64) * dScale -- 546
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 548
	local slot = handing and "child_offer" or "child_idle" -- 549
	local benchLayer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 550
	local partnerPlaced = worldArt:tryPlace( -- 551
		slot, -- 551
		"carry_child_bench", -- 551
		cx, -- 551
		cy, -- 551
		cW, -- 551
		cH, -- 551
		{facing = -f, color = depthTint, layer = benchLayer} -- 551
	) -- 551
	worldArt:tryPlace( -- 556
		"dp_shadow_contact", -- 556
		"carry_child_bench_sh", -- 556
		cx, -- 556
		cam:sy(soldier.y, soldier.depth) + 1, -- 556
		cW * 1.45 * math.max(0.3, dropK), -- 556
		cam:len(8) * dScale, -- 556
		{layer = benchLayer - 1, opacity = 0.8} -- 556
	) -- 556
	if handing then -- 561
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 562
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 563
		local midY = cam:sy( -- 564
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 564
			soldier.depth -- 564
		) -- 564
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 565
		local gunW = cam:len(38) -- 566
		local gunH = cam:len(14) -- 567
		if not worldArt:tryPlacePath( -- 568
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 568
			"carry_bench_gun", -- 568
			midX, -- 568
			midY, -- 568
			gunW, -- 568
			gunH, -- 568
			{ -- 568
				anchorX = 0.5, -- 569
				anchorY = 0.5, -- 570
				preserveAspect = true, -- 571
				facing = f, -- 572
				smooth = true, -- 573
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 574
			} -- 574
		) then -- 574
			local gunLen = cam:len(22) -- 576
			fgDraw:drawSegment( -- 577
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 577
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 577
				3.2, -- 577
				Color(108, 74, 52, 255) -- 577
			) -- 577
			fgDraw:drawSegment( -- 578
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 578
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 578
				1.8, -- 578
				Color(148, 144, 134, 245) -- 578
			) -- 578
		end -- 578
		fillRadialGlow( -- 580
			fgGlow, -- 580
			midX, -- 580
			midY, -- 580
			cam:len(15), -- 580
			cam:len(11), -- 580
			toColor(PALETTE.amberCore, 72), -- 580
			Color(244, 234, 214, 0), -- 580
			10 -- 580
		) -- 580
	end -- 580
	return partnerPlaced -- 582
end -- 516
function ____exports.createCarryPosePlugin() -- 586
	return __TS__New(____exports.CarryPosePlugin) -- 587
end -- 586
return ____exports -- 586
