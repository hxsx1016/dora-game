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
--- 原生 actors.ts 在护送/背负模式下可能激活的 actor_child 精灵帧（同 instanceKey 原地压隐防重影）
local CHILD_SPRITE_PATHS = { -- 35
	"assets/art/sprites.clip|child_idle", -- 36
	"assets/art/sprites.clip|child_run", -- 37
	"assets/art/sprites.clip|child_step", -- 38
	"assets/art/sprites.clip|child_crouch", -- 39
	"assets/art/sprites.clip|child_crouch_step", -- 40
	"assets/art/sprites.clip|child_fear", -- 41
	"assets/art/sprites.clip|child_peek", -- 42
	"assets/art/sprites.clip|child_offer", -- 43
	"assets/art/sprites.clip|child_knock" -- 44
} -- 44
--- 原生 actors.ts 在合体牵手/背负模式下可能激活的 actor_soldier 精灵帧（使用 actors_extra.clip 合体帧时原地压隐防重影）
local SOLDIER_SPRITE_PATHS = { -- 48
	"assets/art/sprites.clip|soldier_idle", -- 49
	"assets/art/sprites.clip|soldier_run", -- 50
	"assets/art/sprites.clip|soldier_step", -- 51
	"assets/art/sprites.clip|soldier_cover", -- 52
	"assets/art/sprites.clip|soldier_fire", -- 53
	"assets/art/sprites.clip|soldier_fire_run", -- 54
	"assets/art/sprites.clip|soldier_fire_run_step", -- 55
	"assets/art/sprites.clip|soldier_hit", -- 56
	"assets/art/sprites.clip|soldier_knock", -- 57
	"assets/art/sprites.clip|soldier_hold", -- 58
	"assets/art/sprites.clip|soldier_offer" -- 59
} -- 59
--- 同一道青布补线袖口（同源 cuff_shots.CUFF_PALETTE）与明初小满红褐短袄色板
local CUFF_CLOTH = toColor(CUFF_PALETTE.indigoBase) -- 63
local CUFF_MEND = toColor(CUFF_PALETTE.stitchThread) -- 64
local CHILD_SLEEVE = Color(164, 78, 54, 255) -- 65
local CHILD_SKIN = Color(236, 210, 182, 255) -- 66
local CHILD_VEST = Color(146, 68, 48, 255) -- 67
local NEEDLE_CORD = Color(198, 166, 114, 240) -- 68
local function clamp01(v) -- 70
	return math.max( -- 71
		0, -- 71
		math.min(1, v) -- 71
	) -- 71
end -- 70
local function smoothStep(t) -- 74
	local k = clamp01(t) -- 75
	return k * k * (3 - 2 * k) -- 76
end -- 74
local function suppressOriginalChild(worldArt) -- 79
	local i = 0 -- 80
	do -- 80
		i = 0 -- 81
		while i < #CHILD_SPRITE_PATHS do -- 81
			worldArt:tryPlacePath( -- 82
				CHILD_SPRITE_PATHS[i + 1], -- 83
				"actor_child", -- 84
				-9999, -- 84
				-9999, -- 84
				1, -- 87
				1, -- 88
				{anchorY = 0, preserveAspect = true, opacity = 0, layer = -99} -- 89
			) -- 89
			i = i + 1 -- 81
		end -- 81
	end -- 81
end -- 79
local function suppressOriginalSoldier(worldArt) -- 94
	local i = 0 -- 95
	do -- 95
		i = 0 -- 96
		while i < #SOLDIER_SPRITE_PATHS do -- 96
			worldArt:tryPlacePath( -- 97
				SOLDIER_SPRITE_PATHS[i + 1], -- 98
				"actor_soldier", -- 99
				-9999, -- 99
				-9999, -- 99
				1, -- 102
				1, -- 103
				{anchorY = 0, preserveAspect = true, opacity = 0, layer = -99} -- 104
			) -- 104
			i = i + 1 -- 96
		end -- 96
	end -- 96
end -- 94
____exports.CarryPosePlugin = __TS__Class() -- 109
local CarryPosePlugin = ____exports.CarryPosePlugin -- 109
CarryPosePlugin.name = "CarryPosePlugin" -- 109
function CarryPosePlugin.prototype.____constructor(self) -- 109
	self.id = "fe-02-carry-pose" -- 110
	self.animTime = 0 -- 112
	self.smoothedFacing = 1 -- 113
	self.mountT = 0 -- 114
	self.benchDropT = 0 -- 115
	self.reachT = 0 -- 116
	self.mode = "none" -- 117
	self.childAnchorX = 0 -- 118
	self.childAnchorY = 0 -- 119
	self.handoverActive = false -- 120
	self.carryAudioRoomSession = -1 -- 121
	self.shotUntil = -1 -- 122
	self.shotFacing = 1 -- 123
end -- 109
function CarryPosePlugin.prototype.getPoseState(self) -- 125
	return { -- 126
		mode = self.mode, -- 127
		smoothedFacing = self.smoothedFacing, -- 128
		mountT = self.mountT, -- 129
		benchDropT = self.benchDropT, -- 130
		reachT = self.reachT, -- 131
		childAnchorX = self.childAnchorX, -- 132
		childAnchorY = self.childAnchorY, -- 133
		handoverActive = self.handoverActive -- 134
	} -- 134
end -- 125
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 138
	self.animTime = 0 -- 139
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 140
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 141
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 142
	self.reachT = 0 -- 143
	self.mode = self:resolveMode(view) -- 144
	self.childAnchorX = p.player.x -- 145
	self.childAnchorY = p.player.y -- 146
	self.handoverActive = false -- 147
	self.carryAudioRoomSession = -1 -- 148
	self.shotUntil = -1 -- 149
	self.shotFacing = self.smoothedFacing -- 150
end -- 138
function CarryPosePlugin.prototype.resolveMode(self, view) -- 153
	local bc = view.backCarry -- 154
	if bc.atBench or view.craftBench.active then -- 154
		return "atBench" -- 156
	end -- 156
	if bc.mounting then -- 156
		return "mounting" -- 159
	end -- 159
	if bc.active then -- 159
		return "carrying" -- 162
	end -- 162
	if bc.handInHand then -- 162
		return "handInHand" -- 165
	end -- 165
	return "none" -- 167
end -- 153
function CarryPosePlugin.prototype.update(self, ctx) -- 170
	local view = ctx.view -- 171
	local p = ctx.p -- 172
	self.mode = self:resolveMode(view) -- 173
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 174
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 174
		return -- 177
	end -- 177
	if ctx.paused then -- 177
		return -- 180
	end -- 180
	local wdt = math.max(0, ctx.worldDt) -- 183
	local udt = math.max(0, ctx.uiDt) -- 184
	if ctx.events.shotFired then -- 184
		self.shotUntil = p.ticks + 10 -- 187
		if ctx.events.shotTrace ~= nil then -- 187
			self.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 and -1 or 1 -- 189
		else -- 189
			self.shotFacing = p.player.facing >= 0 and 1 or -1 -- 191
		end -- 191
	end -- 191
	if wdt > 0 then -- 191
		self.animTime = self.animTime + wdt -- 196
		local targetF = p.player.facing >= 0 and 1 or -1 -- 199
		local turnK = math.min(1, wdt * 15) -- 200
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 201
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 201
			self.smoothedFacing = targetF -- 203
		end -- 203
		if self.mode == "mounting" then -- 203
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 208
		elseif self.mode == "carrying" then -- 208
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 210
		elseif self.mode == "handInHand" or self.mode == "none" then -- 210
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 212
		end -- 212
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 216
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 217
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 217
			self.benchDropT = dropTarget -- 219
		end -- 219
	end -- 219
	if udt > 0 then -- 219
		local reachTarget = view.reloadSession.active and 1 or 0 -- 225
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 226
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 229
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 229
			self.reachT = reachTarget -- 231
		end -- 231
	end -- 231
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 231
		local hasBackendEvent = false -- 238
		local i = 0 -- 239
		do -- 239
			i = 0 -- 240
			while i < #ctx.events.rawEvents do -- 240
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 240
					hasBackendEvent = true -- 242
					break -- 243
				end -- 243
				i = i + 1 -- 240
			end -- 240
		end -- 240
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 246
		if not hasBackendEvent then -- 246
			ctx.audio:playOnce( -- 248
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 249
				"sfx", -- 250
				"assets/audio/combat/carry_start.wav", -- 251
				0.82, -- 252
				"combat:carry_start", -- 253
				p.ticks -- 254
			) -- 254
		end -- 254
	end -- 254
end -- 170
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 260
	local view = ctx.view -- 266
	local p = ctx.p -- 267
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 267
		return -- 269
	end -- 269
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 269
		return -- 272
	end -- 272
	if self.mode == "handInHand" then -- 272
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 276
		return -- 277
	end -- 277
	suppressOriginalChild(worldArt) -- 281
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 281
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 284
		return -- 285
	end -- 285
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 288
end -- 260
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 292
	local p = ctx.p -- 298
	local cam = ctx.cam -- 299
	local soldier = p.player -- 300
	local partner = p.partner -- 301
	local depthEnabled = p.room.depth ~= nil -- 302
	local f = soldier.facing >= 0 and 1 or -1 -- 303
	local speed = math.max( -- 304
		math.abs(soldier.vx), -- 304
		math.abs(soldier.depthSpeed) -- 304
	) -- 304
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 307
	local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2 or 0 -- 308
	local childWX = nearPartner and partner.x or soldier.x + f * 30 + lag -- 309
	local childWY = nearPartner and partner.y or soldier.y -- 310
	local childDepth = nearPartner and partner.depth or soldier.depth -- 311
	self.childAnchorX = childWX -- 312
	self.childAnchorY = childWY -- 313
	if soldier.rollT <= 0 and not p.gripping then -- 313
		local sx = cam:sx(soldier.x) -- 317
		local sy = cam:sy(soldier.y, soldier.depth) -- 318
		local bob = speed > 8 and math.abs(math.sin(self.animTime * 10.5)) * cam:len(2.2) or math.sin(self.animTime * 2.2) * cam:len(0.6) -- 319
		local duoH = cam:len(soldier.h * 1.03) -- 320
		if worldArt:tryPlacePath( -- 320
			"assets/art/actors_extra.clip|duo_hand_walk", -- 321
			"carry_duo_hand", -- 321
			sx, -- 321
			sy + bob, -- 321
			duoH, -- 321
			duoH, -- 321
			{ -- 321
				anchorX = 0.28, -- 322
				anchorY = 0, -- 323
				preserveAspect = true, -- 324
				facing = f, -- 325
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 326
			} -- 326
		) then -- 326
			suppressOriginalChild(worldArt) -- 328
			suppressOriginalSoldier(worldArt) -- 329
			fgDraw:drawEllipse( -- 330
				Vec2( -- 330
					sx + f * cam:len(24), -- 330
					sy + 1 -- 330
				), -- 330
				cam:len(12), -- 330
				3, -- 330
				Color(10, 10, 12, 125) -- 330
			) -- 330
			return -- 331
		end -- 331
	end -- 331
	if not nearPartner then -- 331
		suppressOriginalChild(worldArt) -- 336
		local childStep = math.floor(self.animTime * 13) -- 337
		local slot = speed > 8 and "child_run" or "child_idle" -- 338
		local scx = cam:sx(childWX) -- 339
		local scy = cam:sy(childWY, childDepth) -- 340
		local cW = cam:len(22) -- 341
		local cH = cam:len(64) -- 342
		worldArt:tryPlace( -- 343
			slot, -- 343
			"carry_child_walk", -- 343
			scx, -- 343
			scy, -- 343
			cW, -- 343
			cH, -- 343
			{ -- 343
				facing = f, -- 344
				frame = speed > 8 and childStep or 0, -- 345
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 346
			} -- 346
		) -- 346
		fgDraw:drawEllipse( -- 348
			Vec2(scx, scy + 1), -- 348
			cW * 0.46, -- 348
			3.2, -- 348
			Color(10, 10, 12, 130) -- 348
		) -- 348
	end -- 348
	local sHandX = cam:sx(soldier.x - f * 8) -- 351
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 352
	local cHandX = cam:sx(childWX + f * 7) -- 353
	local cHandY = cam:sy(childWY + 36, childDepth) -- 354
	local swayY = speed > 8 and math.sin(self.animTime * 10.5) * cam:len(2.4) or math.sin(self.animTime * 2.2) * cam:len(0.8) -- 355
	local claspX = (sHandX + cHandX) * 0.5 -- 356
	local claspY = (sHandY + cHandY) * 0.5 + swayY -- 357
	fgDraw:drawSegment( -- 359
		Vec2( -- 359
			sHandX, -- 359
			sHandY + cam:len(5) -- 359
		), -- 359
		Vec2(claspX, claspY), -- 359
		math.max( -- 359
			2.6, -- 359
			cam:len(3) -- 359
		), -- 359
		CUFF_CLOTH -- 359
	) -- 359
	local mendX = sHandX + (claspX - sHandX) * 0.72 -- 360
	local mendY = sHandY + cam:len(5) + (claspY - (sHandY + cam:len(5))) * 0.72 -- 361
	fgDraw:drawSegment( -- 362
		Vec2(mendX - f * 2, mendY - 1.5), -- 362
		Vec2(mendX + f * 2, mendY + 1.5), -- 362
		1.3, -- 362
		CUFF_MEND -- 362
	) -- 362
	fgDraw:drawSegment( -- 363
		Vec2(cHandX, cHandY), -- 363
		Vec2(claspX, claspY), -- 363
		math.max( -- 363
			2, -- 363
			cam:len(2.2) -- 363
		), -- 363
		CHILD_SLEEVE -- 363
	) -- 363
	fgDraw:drawDot( -- 364
		Vec2(claspX - f * 2.5, claspY + 1), -- 364
		math.max( -- 364
			1.8, -- 364
			cam:len(1.4) -- 364
		), -- 364
		NEEDLE_CORD -- 364
	) -- 364
	fgDraw:drawCircle( -- 365
		Vec2(claspX, claspY), -- 365
		math.max( -- 365
			2.8, -- 365
			cam:len(2.4) -- 365
		), -- 365
		CHILD_SKIN -- 365
	) -- 365
	fgGlow:drawDot( -- 366
		Vec2(claspX, claspY), -- 366
		math.max( -- 366
			2.2, -- 366
			cam:len(1.8) -- 366
		), -- 366
		toColor(PALETTE.amberCore, 155) -- 366
	) -- 366
end -- 292
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 370
	local p = ctx.p -- 376
	local cam = ctx.cam -- 377
	local soldier = p.player -- 378
	local depthEnabled = p.room.depth ~= nil -- 379
	local sf = self.smoothedFacing -- 380
	local faceSign = sf >= 0 and 1 or -1 -- 381
	local speed = math.max( -- 382
		math.abs(soldier.vx), -- 382
		math.abs(soldier.depthSpeed) -- 382
	) -- 382
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 385
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 386
	local walking = speed > 8 and soldier.onGround -- 391
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2.3 or math.sin(self.animTime * 2.5) * 0.9 -- 392
	local targetBackX = soldier.x - sf * 13 -- 397
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 398
	local startGroundX = soldier.x - sf * 24 -- 401
	local startGroundY = soldier.y -- 402
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 403
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 405
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 406
	self.childAnchorX = childWX -- 407
	self.childAnchorY = childWY -- 408
	local cx = cam:sx(childWX) -- 410
	local cy = cam:sy(childWY, soldier.depth) -- 411
	local childW = cam:len(22) -- 412
	local childH = cam:len(42 + (1 - kMount) * 18) -- 413
	if kMount >= 0.72 and soldier.rollT <= 0 and not p.gripping then -- 413
		local firing = p.ticks < self.shotUntil -- 417
		local duoClip = firing and "duo_carry_fire" or (walking and "duo_carry_run" or "duo_carry_idle") -- 418
		local duoAnchorX = firing and 0.36 or 0.54 -- 419
		local duoFacing = firing and self.shotFacing or faceSign -- 420
		local duoLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 421
		local crouchScale = (soldier.covered or p.coverHug) and 0.86 or 1.05 -- 422
		local duoH = cam:len(soldier.h * crouchScale) -- 423
		local sx = cam:sx(soldier.x) -- 424
		local sy = cam:sy(soldier.y, soldier.depth) + cam:len(bob * 0.7) -- 425
		if worldArt:tryPlacePath( -- 425
			"assets/art/actors_extra.clip|" .. duoClip, -- 426
			"carry_duo_sprite", -- 426
			sx, -- 426
			sy, -- 426
			duoH, -- 426
			duoH, -- 426
			{ -- 426
				anchorX = duoAnchorX, -- 427
				anchorY = 0, -- 428
				preserveAspect = true, -- 429
				facing = duoFacing, -- 430
				layer = duoLayer -- 431
			} -- 431
		) then -- 431
			suppressOriginalSoldier(worldArt) -- 433
			if self.reachT > 0.05 then -- 433
				local reachFrac = smoothStep(self.reachT) -- 436
				local gx = sx + sf * cam:len(14 + reachFrac * 8) -- 437
				local gy = sy + duoH * 0.72 -- 438
				fillRadialGlow( -- 439
					fgGlow, -- 440
					gx, -- 441
					gy, -- 442
					cam:len(10 * reachFrac), -- 443
					cam:len(10 * reachFrac), -- 444
					toColor(PALETTE.amberCore, 82 * reachFrac), -- 445
					Color(244, 234, 214, 0), -- 446
					10 -- 447
				) -- 447
			end -- 447
			return -- 450
		end -- 450
	end -- 450
	if self.mode == "mounting" and kMount < 0.72 then -- 450
		local scx = cam:sx(soldier.x) -- 456
		local scy = cam:sy(soldier.y, soldier.depth) -- 457
		fgDraw:drawEllipse( -- 458
			Vec2( -- 458
				scx - sf * cam:len(6), -- 458
				scy + 1 -- 458
			), -- 458
			cam:len(22), -- 458
			4.2, -- 458
			Color(10, 10, 12, 110) -- 458
		) -- 458
	end -- 458
	local backSlot = kMount < 0.45 and "child_crouch" or "child_peek" -- 462
	local tilt = -sf * (walking and 5.5 or 2.2) -- 463
	local childLayer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 464
	local placed = worldArt:tryPlace( -- 465
		backSlot, -- 465
		"carry_child", -- 465
		cx, -- 465
		cy, -- 465
		childW, -- 465
		childH, -- 465
		{facing = faceSign, angle = tilt, layer = childLayer} -- 465
	) -- 465
	if not placed then -- 465
		fgDraw:drawPolygon( -- 473
			{ -- 473
				Vec2(cx - childW * 0.4, cy + childH * 0.1), -- 474
				Vec2(cx + childW * 0.4, cy + childH * 0.1), -- 475
				Vec2(cx + childW * 0.3, cy + childH * 0.72), -- 476
				Vec2(cx - childW * 0.35, cy + childH * 0.72) -- 477
			}, -- 477
			CHILD_VEST, -- 478
			1, -- 478
			toColor(PALETTE.amberCore, 165) -- 478
		) -- 478
		fgDraw:drawCircle( -- 479
			Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), -- 479
			childW * 0.32, -- 479
			CHILD_SKIN -- 479
		) -- 479
	end -- 479
	local shoulderX = cam:sx(soldier.x + sf * 3) -- 483
	local shoulderY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth) -- 484
	local childShoulderX = cam:sx(childWX + sf * 5) -- 485
	local childShoulderY = cam:sy(childWY + 26, soldier.depth) -- 486
	local hipSupportX = cam:sx(soldier.x - sf * 10) -- 489
	local hipSupportY = cam:sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth) -- 490
	fgDraw:drawSegment( -- 491
		Vec2( -- 492
			cam:sx(soldier.x - sf * 2), -- 492
			cam:sy(soldier.y + 42 - crouchDip, soldier.depth) -- 492
		), -- 492
		Vec2(hipSupportX, hipSupportY), -- 493
		math.max( -- 494
			2.4, -- 494
			cam:len(2.8) -- 494
		), -- 494
		CUFF_CLOTH -- 495
	) -- 495
	fgDraw:drawSegment( -- 497
		Vec2(hipSupportX - sf * 2, hipSupportY + 1), -- 498
		Vec2(hipSupportX + sf * 3, hipSupportY + 1), -- 499
		1.2, -- 500
		CUFF_MEND -- 501
	) -- 501
	if self.reachT > 0.05 and kMount > 0.7 then -- 501
		local reachFrac = smoothStep(self.reachT) -- 506
		local elbowX = shoulderX + sf * cam:len(4 + reachFrac * 5) -- 507
		local elbowY = shoulderY + cam:len(1 + reachFrac * 3) -- 508
		local handEndX = elbowX + sf * cam:len(5 + reachFrac * 11) -- 509
		local handEndY = elbowY + cam:len(2 + reachFrac * 5) -- 510
		fgDraw:drawSegment( -- 511
			Vec2(childShoulderX, childShoulderY), -- 511
			Vec2(elbowX, elbowY), -- 511
			math.max( -- 511
				2, -- 511
				cam:len(2.1) -- 511
			), -- 511
			CHILD_SLEEVE -- 511
		) -- 511
		fgDraw:drawSegment( -- 512
			Vec2(elbowX, elbowY), -- 512
			Vec2( -- 512
				handEndX - sf * cam:len(3), -- 512
				handEndY - cam:len(1) -- 512
			), -- 512
			math.max( -- 512
				1.7, -- 512
				cam:len(1.8) -- 512
			), -- 512
			CHILD_SLEEVE -- 512
		) -- 512
		fgDraw:drawDot( -- 514
			Vec2( -- 514
				handEndX - sf * cam:len(3.2), -- 514
				handEndY - cam:len(0.8) -- 514
			), -- 514
			math.max( -- 514
				1.5, -- 514
				cam:len(1.2) -- 514
			), -- 514
			NEEDLE_CORD -- 514
		) -- 514
		fgDraw:drawCircle( -- 515
			Vec2(handEndX, handEndY), -- 515
			math.max( -- 515
				2.1, -- 515
				cam:len(1.8) -- 515
			), -- 515
			CHILD_SKIN -- 515
		) -- 515
		fgDraw:drawSegment( -- 516
			Vec2(handEndX, handEndY), -- 516
			Vec2( -- 516
				handEndX + sf * cam:len(3.5), -- 516
				handEndY + cam:len(1.2) -- 516
			), -- 516
			math.max( -- 516
				1.1, -- 516
				cam:len(1) -- 516
			), -- 516
			CHILD_SKIN -- 516
		) -- 516
		fillRadialGlow( -- 517
			fgGlow, -- 518
			handEndX + sf * cam:len(3), -- 519
			handEndY + cam:len(1), -- 520
			cam:len(7 * reachFrac), -- 521
			cam:len(7 * reachFrac), -- 522
			toColor(PALETTE.amberCore, 72 * reachFrac), -- 523
			Color(244, 234, 214, 0), -- 524
			10 -- 525
		) -- 525
	elseif kMount > 0.35 then -- 525
		local armAlpha = clamp01((kMount - 0.35) / 0.65) -- 528
		local gripX = shoulderX + sf * cam:len(4) -- 529
		local gripY = shoulderY - cam:len(2) -- 530
		fgDraw:drawSegment( -- 531
			Vec2(childShoulderX, childShoulderY), -- 532
			Vec2(gripX, gripY), -- 533
			math.max( -- 534
				1.8, -- 534
				cam:len(2) -- 534
			), -- 534
			Color( -- 535
				164, -- 535
				78, -- 535
				54, -- 535
				math.floor(255 * armAlpha + 0.5) -- 535
			) -- 535
		) -- 535
		fgDraw:drawDot( -- 537
			Vec2(gripX - sf * 2, gripY), -- 537
			math.max( -- 537
				1.5, -- 537
				cam:len(1.2) -- 537
			), -- 537
			Color( -- 537
				198, -- 537
				166, -- 537
				114, -- 537
				math.floor(235 * armAlpha + 0.5) -- 537
			) -- 537
		) -- 537
		fgDraw:drawCircle( -- 538
			Vec2(gripX, gripY), -- 538
			math.max( -- 538
				2, -- 538
				cam:len(1.7) -- 538
			), -- 538
			Color( -- 538
				236, -- 538
				210, -- 538
				182, -- 538
				math.floor(255 * armAlpha + 0.5) -- 538
			) -- 538
		) -- 538
	end -- 538
end -- 370
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 543
	local p = ctx.p -- 549
	local cam = ctx.cam -- 550
	local soldier = p.player -- 551
	local depthEnabled = p.room.depth ~= nil -- 552
	local f = soldier.facing >= 0 and 1 or -1 -- 553
	local dropK = smoothStep(self.benchDropT) -- 554
	local startX = soldier.x - f * 12 -- 557
	local startY = soldier.y + 26 -- 558
	local standX = soldier.x + f * 30 -- 559
	local standY = soldier.y -- 560
	local childWX = startX + (standX - startX) * dropK -- 561
	local childWY = startY + (standY - startY) * dropK -- 562
	self.childAnchorX = childWX -- 563
	self.childAnchorY = childWY -- 564
	local cx = cam:sx(childWX) -- 566
	local cy = cam:sy(childWY, soldier.depth) -- 567
	local cW = cam:len(22) -- 568
	local cH = cam:len(64) -- 569
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 571
	local slot = handing and "child_offer" or "child_idle" -- 572
	worldArt:tryPlace( -- 574
		slot, -- 574
		"carry_child_bench", -- 574
		cx, -- 574
		cy, -- 574
		cW, -- 574
		cH, -- 574
		{ -- 574
			facing = -f, -- 575
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 576
		} -- 576
	) -- 576
	fgDraw:drawEllipse( -- 578
		Vec2( -- 578
			cx, -- 578
			cam:sy(soldier.y, soldier.depth) + 1 -- 578
		), -- 578
		cW * 0.48 * dropK, -- 578
		3.2, -- 578
		Color(10, 10, 12, 130) -- 578
	) -- 578
	if handing then -- 578
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 582
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 583
		local midY = cam:sy( -- 584
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 584
			soldier.depth -- 584
		) -- 584
		local gunClip = ctx.view.craftBench.equippedWeapon == "echo_gun" and "craft_echo_gun" or "craft_lantern_gun" -- 585
		local gunW = cam:len(38) -- 586
		local gunH = cam:len(14) -- 587
		if not worldArt:tryPlacePath( -- 587
			"assets/art/vfx_craft_art.clip|" .. gunClip, -- 588
			"carry_bench_gun", -- 588
			midX, -- 588
			midY, -- 588
			gunW, -- 588
			gunH, -- 588
			{ -- 588
				anchorX = 0.5, -- 589
				anchorY = 0.5, -- 590
				preserveAspect = true, -- 591
				facing = f, -- 592
				smooth = true, -- 593
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 594
			} -- 594
		) then -- 594
			local gunLen = cam:len(22) -- 596
			fgDraw:drawSegment( -- 597
				Vec2(midX - f * gunLen * 0.4, midY - 2), -- 597
				Vec2(midX + f * gunLen * 0.25, midY + 1), -- 597
				3.2, -- 597
				Color(108, 74, 52, 255) -- 597
			) -- 597
			fgDraw:drawSegment( -- 598
				Vec2(midX + f * gunLen * 0.1, midY + 1), -- 598
				Vec2(midX + f * gunLen * 0.65, midY + 3), -- 598
				1.8, -- 598
				Color(148, 144, 134, 245) -- 598
			) -- 598
		end -- 598
		fillRadialGlow( -- 600
			fgGlow, -- 600
			midX, -- 600
			midY, -- 600
			cam:len(14), -- 600
			cam:len(10), -- 600
			toColor(PALETTE.amberCore, 72), -- 600
			Color(244, 234, 214, 0), -- 600
			10 -- 600
		) -- 600
	end -- 600
end -- 543
function ____exports.createCarryPosePlugin() -- 605
	return __TS__New(____exports.CarryPosePlugin) -- 606
end -- 605
return ____exports -- 605