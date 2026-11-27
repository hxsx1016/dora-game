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
	if bc.atBench or view.craftBench.active then -- 129
		return "atBench" -- 131
	end -- 131
	if bc.mounting then -- 131
		return "mounting" -- 134
	end -- 134
	if bc.active then -- 134
		return "carrying" -- 137
	end -- 137
	if bc.handInHand then -- 137
		return "handInHand" -- 140
	end -- 140
	return "none" -- 142
end -- 128
function CarryPosePlugin.prototype.update(self, ctx) -- 145
	local view = ctx.view -- 146
	local p = ctx.p -- 147
	self.mode = self:resolveMode(view) -- 148
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 149
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 149
		return -- 152
	end -- 152
	if ctx.paused then -- 152
		return -- 155
	end -- 155
	local wdt = math.max(0, ctx.worldDt) -- 158
	local udt = math.max(0, ctx.uiDt) -- 159
	if ctx.events.shotFired then -- 159
		self.shotStartTick = p.ticks -- 162
		self.shotUntil = p.ticks + 18 -- 163
		if ctx.events.shotTrace ~= nil then -- 163
			self.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 and -1 or 1 -- 165
		else -- 165
			self.shotFacing = p.player.facing >= 0 and 1 or -1 -- 167
		end -- 167
	end -- 167
	if wdt > 0 then -- 167
		self.animTime = self.animTime + wdt -- 172
		local dx = p.player.x - self.prevSoldierX -- 173
		local dd = p.player.depth - self.prevSoldierDepth -- 174
		local stepDist = math.sqrt(dx * dx + dd * dd) -- 175
		self.prevSoldierX = p.player.x -- 176
		self.prevSoldierDepth = p.player.depth -- 177
		if stepDist > 0.05 and stepDist < 80 then -- 177
			self.carryStride = (self.carryStride + stepDist / math.max(40, p.player.h * 1.28)) % 1 -- 179
		end -- 179
		local targetF = p.player.facing >= 0 and 1 or -1 -- 183
		local turnK = math.min(1, wdt * 15) -- 184
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 185
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 185
			self.smoothedFacing = targetF -- 187
		end -- 187
		if self.mode == "mounting" then -- 187
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 192
		elseif self.mode == "carrying" then -- 192
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 194
		elseif self.mode == "handInHand" or self.mode == "none" then -- 194
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 196
		end -- 196
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 200
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 201
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 201
			self.benchDropT = dropTarget -- 203
		end -- 203
	end -- 203
	if udt > 0 then -- 203
		local reachTarget = view.reloadSession.active and 1 or 0 -- 209
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 210
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 213
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 213
			self.reachT = reachTarget -- 215
		end -- 215
	end -- 215
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 215
		local hasBackendEvent = false -- 222
		local i = 0 -- 223
		do -- 223
			i = 0 -- 224
			while i < #ctx.events.rawEvents do -- 224
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 224
					hasBackendEvent = true -- 226
					break -- 227
				end -- 227
				i = i + 1 -- 224
			end -- 224
		end -- 224
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 230
		if not hasBackendEvent then -- 230
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
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 251
		return -- 253
	end -- 253
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 253
		return -- 256
	end -- 256
	if self.mode == "handInHand" then -- 256
		return self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 260
	end -- 260
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 260
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
	if soldier.rollT <= 0 and not p.gripping then -- 289
		local sx = cam:sx(soldier.x) -- 293
		local sy = cam:sy(soldier.y, soldier.depth) -- 294
		local duoH = cam:len(soldier.h * 1.03) -- 295
		local walking = speed > 8 and soldier.onGround -- 296
		local handFrame = walking and math.floor(self.carryStride * 8) % 4 or 0 -- 297
		local breathSquash = walking and 1 or 1 + math.sin(self.animTime * 2.4) * 0.012 -- 298
		if worldArt:tryPlacePath( -- 298
			DUO_HAND_CLIPS[handFrame + 1], -- 299
			"carry_duo_hand", -- 299
			sx, -- 299
			sy, -- 299
			duoH, -- 299
			duoH, -- 299
			{ -- 299
				anchorX = 0.5, -- 300
				anchorY = 0, -- 301
				preserveAspect = true, -- 302
				facing = f, -- 303
				scaleYMul = breathSquash, -- 304
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 305
			} -- 305
		) then -- 305
			fgDraw:drawEllipse( -- 307
				Vec2(sx, sy + 1), -- 307
				cam:len(16), -- 307
				3.4, -- 307
				Color(10, 10, 12, 135) -- 307
			) -- 307
			fgDraw:drawEllipse( -- 308
				Vec2( -- 308
					sx + f * cam:len(26), -- 308
					sy + 1 -- 308
				), -- 308
				cam:len(11), -- 308
				2.8, -- 308
				Color(10, 10, 12, 120) -- 308
			) -- 308
			self.childAnchorX = childWX -- 309
			self.childAnchorY = childWY -- 310
			return {player = true, partner = true} -- 311
		end -- 311
	end -- 311
	local partnerPlaced = false -- 315
	if not nearPartner then -- 315
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 318
		childWX = soldier.x - f * 26 + lag -- 319
		childWY = soldier.y -- 320
		childDepth = soldier.depth -- 321
		local scx = cam:sx(childWX) -- 323
		local scy = cam:sy(childWY, childDepth) -- 324
		local cW = cam:len(22) -- 325
		local cH = cam:len(64) -- 326
		local pose = { -- 327
			facing = f, -- 327
			layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 327
		} -- 327
		partnerPlaced = speed > 8 and worldArt:tryPlaceRun( -- 328
			"child", -- 328
			"carry_child_walk", -- 328
			scx, -- 328
			scy, -- 328
			cW, -- 328
			cH, -- 328
			self.animTime * 1.8, -- 328
			pose -- 328
		) or worldArt:tryPlace( -- 328
			"child_idle", -- 329
			"carry_child_walk", -- 329
			scx, -- 329
			scy, -- 329
			cW, -- 329
			cH, -- 329
			pose -- 329
		) -- 329
		fgDraw:drawEllipse( -- 330
			Vec2(scx, scy + 1), -- 330
			cW * 0.46, -- 330
			3.2, -- 330
			Color(10, 10, 12, 130) -- 330
		) -- 330
	end -- 330
	self.childAnchorX = childWX -- 333
	self.childAnchorY = childWY -- 334
	local playerPlaced = false -- 337
	if speed <= 8 and soldier.rollT <= 0 then -- 337
		playerPlaced = worldArt:tryPlace( -- 339
			"fe_soldier_hand_hold", -- 340
			"carry_soldier_hold", -- 341
			cam:sx(soldier.x), -- 342
			cam:sy(soldier.y, soldier.depth), -- 343
			cam:len(36), -- 344
			cam:len(soldier.h), -- 345
			{ -- 346
				facing = f, -- 347
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 348
			} -- 348
		) -- 348
	end -- 348
	local sHandX = cam:sx(soldier.x - f * 8) -- 352
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 353
	local cHandX = cam:sx(childWX + f * 7) -- 354
	local cHandY = cam:sy(childWY + 36, childDepth) -- 355
	local claspX = (sHandX + cHandX) * 0.5 -- 356
	local claspY = (sHandY + cHandY) * 0.5 -- 357
	fillRadialGlow( -- 358
		fgGlow, -- 358
		claspX, -- 358
		claspY, -- 358
		cam:len(10), -- 358
		cam:len(8), -- 358
		toColor(PALETTE.amberCore, 76), -- 358
		Color(244, 234, 214, 0), -- 358
		10 -- 358
	) -- 358
	return {player = playerPlaced, partner = partnerPlaced} -- 359
end -- 271
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 363
	local p = ctx.p -- 368
	local cam = ctx.cam -- 369
	local soldier = p.player -- 370
	local depthEnabled = p.room.depth ~= nil -- 371
	local sf = self.smoothedFacing -- 372
	local faceSign = sf >= 0 and 1 or -1 -- 373
	local speed = math.max( -- 374
		math.abs(soldier.vx), -- 374
		math.abs(soldier.depthSpeed) -- 374
	) -- 374
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 377
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 378
	local walking = speed > 8 and soldier.onGround -- 382
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 383
	local targetBackX = soldier.x - sf * 13 -- 388
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 389
	local startGroundX = soldier.x - sf * 24 -- 390
	local startGroundY = soldier.y -- 391
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 392
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 394
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 395
	self.childAnchorX = childWX -- 396
	self.childAnchorY = childWY -- 397
	local scx = cam:sx(soldier.x) -- 399
	local scy = cam:sy(soldier.y, soldier.depth) -- 400
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 401
	if self.mode == "mounting" and kMount < 0.96 then -- 401
		local mountFrame = kMount < 0.28 and 0 or (kMount < 0.56 and 1 or (kMount < 0.8 and 2 or 3)) -- 405
		local mountH = cam:len(soldier.h * 1.06) -- 406
		if worldArt:tryPlacePath( -- 406
			DUO_MOUNT_CLIPS[mountFrame + 1], -- 407
			"carry_duo_mount", -- 407
			scx, -- 407
			scy, -- 407
			mountH, -- 407
			mountH, -- 407
			{ -- 407
				anchorX = 0.5, -- 408
				anchorY = 0, -- 409
				preserveAspect = true, -- 410
				facing = faceSign, -- 411
				layer = baseLayer -- 412
			} -- 412
		) then -- 412
			return {player = true, partner = true} -- 414
		end -- 414
		local playerPlaced = worldArt:tryPlace( -- 416
			"fe_soldier_kneel_mount", -- 416
			"carry_soldier_kneel", -- 416
			scx, -- 416
			scy, -- 416
			cam:len(42), -- 416
			cam:len(soldier.h * 0.9), -- 416
			{facing = faceSign, layer = baseLayer} -- 416
		) -- 416
		local cx = cam:sx(childWX) -- 420
		local cy = cam:sy(childWY, soldier.depth) -- 421
		local partnerPlaced = worldArt:tryPlace( -- 422
			kMount < 0.45 and "child_crouch" or "child_peek", -- 422
			"carry_child", -- 422
			cx, -- 422
			cy, -- 422
			cam:len(22), -- 422
			cam:len(42 + (1 - kMount) * 18), -- 422
			{facing = faceSign, layer = baseLayer + 1} -- 422
		) -- 422
		return {player = playerPlaced, partner = partnerPlaced} -- 426
	end -- 426
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 426
		local firing = p.ticks < self.shotUntil -- 431
		local duoPath = DUO_CARRY_IDLE_CLIPS[1] -- 432
		local duoFacing = faceSign -- 433
		local recoilOffsetX = 0 -- 434
		local turnScaleX = 1 - math.abs(math.abs(sf) - 1) * 0.24 -- 435
		if firing then -- 435
			local elapsed = math.max(0, p.ticks - self.shotStartTick) -- 437
			local fIdx = elapsed < 2 and 0 or (elapsed < 5 and 1 or (elapsed < 12 and 2 or 3)) -- 438
			duoPath = DUO_CARRY_FIRE_CLIPS[fIdx + 1] -- 439
			duoFacing = self.shotFacing -- 440
			if fIdx == 2 then -- 440
				recoilOffsetX = -duoFacing * cam:len(3.2) -- 442
			end -- 442
		elseif walking then -- 442
			local runIdx = math.floor(self.carryStride * 8) % 8 -- 445
			duoPath = DUO_CARRY_RUN_CLIPS[runIdx + 1] -- 446
		else -- 446
			local ping = { -- 448
				0, -- 448
				1, -- 448
				2, -- 448
				3, -- 448
				2, -- 448
				1 -- 448
			} -- 448
			local idleIdx = ping[math.floor(self.animTime * 5.2) % #ping + 1] -- 449
			duoPath = DUO_CARRY_IDLE_CLIPS[idleIdx + 1] -- 450
		end -- 450
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 452
		local crouchScale = (soldier.covered or p.coverHug) and 0.88 or 1.06 -- 453
		local duoH = cam:len(soldier.h * crouchScale) -- 454
		local sx = cam:sx(soldier.x) + recoilOffsetX -- 455
		local sy = cam:sy(soldier.y, soldier.depth) -- 456
		if worldArt:tryPlacePath( -- 456
			duoPath, -- 457
			"carry_duo_sprite", -- 457
			sx, -- 457
			sy, -- 457
			duoH, -- 457
			duoH, -- 457
			{ -- 457
				anchorX = 0.5, -- 458
				anchorY = 0, -- 459
				preserveAspect = true, -- 460
				facing = duoFacing, -- 461
				scaleXMul = math.max(0.76, turnScaleX), -- 462
				layer = duoLayer -- 463
			} -- 463
		) then -- 463
			if self.reachT > 0.05 then -- 463
				local reachFrac = smoothStep(self.reachT) -- 467
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 468
				local gy = sy + duoH * 0.72 -- 469
				fillRadialGlow( -- 470
					fgGlow, -- 471
					gx, -- 472
					gy, -- 473
					cam:len(10 * reachFrac), -- 474
					cam:len(10 * reachFrac), -- 475
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 476
					Color(244, 234, 214, 0), -- 477
					10 -- 478
				) -- 478
			end -- 478
			return {player = true, partner = true} -- 481
		end -- 481
	end -- 481
	local cx = cam:sx(childWX) -- 486
	local cy = cam:sy(childWY, soldier.depth) -- 487
	local partnerPlaced = worldArt:tryPlace( -- 488
		"child_peek", -- 488
		"carry_child", -- 488
		cx, -- 488
		cy, -- 488
		cam:len(22), -- 488
		cam:len(40), -- 488
		{ -- 488
			facing = faceSign, -- 489
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 490
		} -- 490
	) -- 490
	return {player = false, partner = partnerPlaced} -- 492
end -- 363
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 496
	local p = ctx.p -- 502
	local cam = ctx.cam -- 503
	local soldier = p.player -- 504
	local depthEnabled = p.room.depth ~= nil -- 505
	local f = soldier.facing >= 0 and 1 or -1 -- 506
	local dropK = smoothStep(self.benchDropT) -- 507
	local startX = soldier.x - f * 12 -- 510
	local startY = soldier.y + 26 -- 511
	local standX = soldier.x + f * 30 -- 512
	local standY = soldier.y -- 513
	local childWX = startX + (standX - startX) * dropK -- 514
	local childWY = startY + (standY - startY) * dropK -- 515
	self.childAnchorX = childWX -- 516
	self.childAnchorY = childWY -- 517
	local cx = cam:sx(childWX) -- 519
	local cy = cam:sy(childWY, soldier.depth) -- 520
	local cW = cam:len(22) -- 521
	local cH = cam:len(64) -- 522
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 524
	local slot = handing and "child_offer" or "child_idle" -- 525
	local partnerPlaced = worldArt:tryPlace( -- 526
		slot, -- 526
		"carry_child_bench", -- 526
		cx, -- 526
		cy, -- 526
		cW, -- 526
		cH, -- 526
		{ -- 526
			facing = -f, -- 527
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 528
		} -- 528
	) -- 528
	fgDraw:drawEllipse( -- 530
		Vec2( -- 530
			cx, -- 530
			cam:sy(soldier.y, soldier.depth) + 1 -- 530
		), -- 530
		cW * 0.48 * dropK, -- 530
		3.2, -- 530
		Color(10, 10, 12, 130) -- 530
	) -- 530
	if handing then -- 530
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 534
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 535
		local midY = cam:sy( -- 536
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 536
			soldier.depth -- 536
		) -- 536
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 537
		local gunW = cam:len(38) -- 538
		local gunH = cam:len(14) -- 539
		if not worldArt:tryPlacePath( -- 539
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 540
			"carry_bench_gun", -- 540
			midX, -- 540
			midY, -- 540
			gunW, -- 540
			gunH, -- 540
			{ -- 540
				anchorX = 0.5, -- 541
				anchorY = 0.5, -- 542
				preserveAspect = true, -- 543
				facing = f, -- 544
				smooth = true, -- 545
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 546
			} -- 546
		) then -- 546
			local gunLen = cam:len(22) -- 548
			fgDraw:drawSegment( -- 549
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 549
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 549
				3.2, -- 549
				Color(108, 74, 52, 255) -- 549
			) -- 549
			fgDraw:drawSegment( -- 550
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 550
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 550
				1.8, -- 550
				Color(148, 144, 134, 245) -- 550
			) -- 550
		end -- 550
		fillRadialGlow( -- 552
			fgGlow, -- 552
			midX, -- 552
			midY, -- 552
			cam:len(15), -- 552
			cam:len(11), -- 552
			toColor(PALETTE.amberCore, 72), -- 552
			Color(244, 234, 214, 0), -- 552
			10 -- 552
		) -- 552
	end -- 552
	return partnerPlaced -- 554
end -- 496
function ____exports.createCarryPosePlugin() -- 558
	return __TS__New(____exports.CarryPosePlugin) -- 559
end -- 558
return ____exports -- 558