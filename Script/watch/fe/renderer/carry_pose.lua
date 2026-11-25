-- [ts]: carry_pose.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____occlusion = require("Script.watch.fe.occlusion") -- 16
local depthOrder = ____occlusion.depthOrder -- 16
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 18
local toColor = ____theme.toColor -- 18
--- 原生 actors.ts 在护送/背负模式下可能激活的 actor_child 精灵帧（同 instanceKey 原地压隐防重影）
local CHILD_SPRITE_PATHS = { -- 34
	"assets/art/sprites.clip|child_idle", -- 35
	"assets/art/sprites.clip|child_run", -- 36
	"assets/art/sprites.clip|child_step", -- 37
	"assets/art/sprites.clip|child_crouch", -- 38
	"assets/art/sprites.clip|child_crouch_step", -- 39
	"assets/art/sprites.clip|child_fear", -- 40
	"assets/art/sprites.clip|child_peek", -- 41
	"assets/art/sprites.clip|child_offer", -- 42
	"assets/art/sprites.clip|child_knock" -- 43
} -- 43
--- 同一道青布补线袖口与明初小满红褐短袄色板（严格对齐 sprites.png 真实像素配色）
local CUFF_CLOTH = Color(44, 62, 78, 255) -- 47
local CUFF_MEND = Color(218, 208, 188, 255) -- 48
local CHILD_SLEEVE = Color(164, 78, 54, 255) -- 49
local CHILD_SKIN = Color(236, 210, 182, 255) -- 50
local CHILD_VEST = Color(146, 68, 48, 255) -- 51
local NEEDLE_CORD = Color(198, 166, 114, 240) -- 52
local function clamp01(v) -- 54
	return math.max( -- 55
		0, -- 55
		math.min(1, v) -- 55
	) -- 55
end -- 54
local function smoothStep(t) -- 58
	local k = clamp01(t) -- 59
	return k * k * (3 - 2 * k) -- 60
end -- 58
local function suppressOriginalChild(worldArt) -- 63
	local i = 0 -- 64
	do -- 64
		i = 0 -- 65
		while i < #CHILD_SPRITE_PATHS do -- 65
			worldArt:tryPlacePath( -- 66
				CHILD_SPRITE_PATHS[i + 1], -- 67
				"actor_child", -- 68
				-9999, -- 68
				-9999, -- 68
				1, -- 71
				1, -- 72
				{anchorY = 0, preserveAspect = true, opacity = 0, layer = -99} -- 73
			) -- 73
			i = i + 1 -- 65
		end -- 65
	end -- 65
end -- 63
____exports.CarryPosePlugin = __TS__Class() -- 78
local CarryPosePlugin = ____exports.CarryPosePlugin -- 78
CarryPosePlugin.name = "CarryPosePlugin" -- 78
function CarryPosePlugin.prototype.____constructor(self) -- 78
	self.id = "fe-02-carry-pose" -- 79
	self.animTime = 0 -- 81
	self.smoothedFacing = 1 -- 82
	self.mountT = 0 -- 83
	self.benchDropT = 0 -- 84
	self.reachT = 0 -- 85
	self.mode = "none" -- 86
	self.childAnchorX = 0 -- 87
	self.childAnchorY = 0 -- 88
	self.handoverActive = false -- 89
	self.carryAudioRoomSession = -1 -- 90
end -- 78
function CarryPosePlugin.prototype.getPoseState(self) -- 92
	return { -- 93
		mode = self.mode, -- 94
		smoothedFacing = self.smoothedFacing, -- 95
		mountT = self.mountT, -- 96
		benchDropT = self.benchDropT, -- 97
		reachT = self.reachT, -- 98
		childAnchorX = self.childAnchorX, -- 99
		childAnchorY = self.childAnchorY, -- 100
		handoverActive = self.handoverActive -- 101
	} -- 101
end -- 92
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 105
	self.animTime = 0 -- 106
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 107
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 108
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 109
	self.reachT = 0 -- 110
	self.mode = self:resolveMode(view) -- 111
	self.childAnchorX = p.player.x -- 112
	self.childAnchorY = p.player.y -- 113
	self.handoverActive = false -- 114
	self.carryAudioRoomSession = -1 -- 115
end -- 105
function CarryPosePlugin.prototype.resolveMode(self, view) -- 118
	local bc = view.backCarry -- 119
	if bc.atBench or view.craftBench.active then -- 119
		return "atBench" -- 121
	end -- 121
	if bc.mounting then -- 121
		return "mounting" -- 124
	end -- 124
	if bc.active then -- 124
		return "carrying" -- 127
	end -- 127
	if bc.handInHand then -- 127
		return "handInHand" -- 130
	end -- 130
	return "none" -- 132
end -- 118
function CarryPosePlugin.prototype.update(self, ctx) -- 135
	local view = ctx.view -- 136
	local p = ctx.p -- 137
	self.mode = self:resolveMode(view) -- 138
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 139
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 139
		return -- 142
	end -- 142
	if ctx.paused then -- 142
		return -- 145
	end -- 145
	local wdt = math.max(0, ctx.worldDt) -- 148
	local udt = math.max(0, ctx.uiDt) -- 149
	if wdt > 0 then -- 149
		self.animTime = self.animTime + wdt -- 152
		local targetF = p.player.facing >= 0 and 1 or -1 -- 155
		local turnK = math.min(1, wdt * 15) -- 156
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 157
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 157
			self.smoothedFacing = targetF -- 159
		end -- 159
		if self.mode == "mounting" then -- 159
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 164
		elseif self.mode == "carrying" then -- 164
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 166
		elseif self.mode == "handInHand" or self.mode == "none" then -- 166
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 168
		end -- 168
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 172
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 173
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 173
			self.benchDropT = dropTarget -- 175
		end -- 175
	end -- 175
	if udt > 0 then -- 175
		local reachTarget = view.reloadSession.active and 1 or 0 -- 181
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 182
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 185
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 185
			self.reachT = reachTarget -- 187
		end -- 187
	end -- 187
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 187
		local hasBackendEvent = false -- 194
		local i = 0 -- 195
		do -- 195
			i = 0 -- 196
			while i < #ctx.events.rawEvents do -- 196
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 196
					hasBackendEvent = true -- 198
					break -- 199
				end -- 199
				i = i + 1 -- 196
			end -- 196
		end -- 196
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 202
		if not hasBackendEvent then -- 202
			ctx.audio:playOnce( -- 204
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 205
				"sfx", -- 206
				"assets/audio/combat/carry_start.wav", -- 207
				0.82, -- 208
				"combat:carry_start", -- 209
				p.ticks -- 210
			) -- 210
		end -- 210
	end -- 210
end -- 135
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 216
	local view = ctx.view -- 222
	local p = ctx.p -- 223
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 223
		return -- 225
	end -- 225
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 225
		return -- 228
	end -- 228
	if self.mode == "handInHand" then -- 228
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 232
		return -- 233
	end -- 233
	suppressOriginalChild(worldArt) -- 237
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 237
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 240
		return -- 241
	end -- 241
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 244
end -- 216
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 248
	local p = ctx.p -- 254
	local cam = ctx.cam -- 255
	local soldier = p.player -- 256
	local partner = p.partner -- 257
	local depthEnabled = p.room.depth ~= nil -- 258
	local f = soldier.facing >= 0 and 1 or -1 -- 259
	local speed = math.max( -- 260
		math.abs(soldier.vx), -- 260
		math.abs(soldier.depthSpeed) -- 260
	) -- 260
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 263
	local childWX = partner.x -- 264
	local childWY = partner.y -- 265
	local childDepth = partner.depth -- 266
	if not nearPartner then -- 266
		suppressOriginalChild(worldArt) -- 269
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 271
		childWX = soldier.x - f * 26 + lag -- 272
		childWY = soldier.y -- 273
		childDepth = soldier.depth -- 274
		local childStep = math.floor(self.animTime * 13) -- 276
		local slot = speed > 8 and "child_run" or "child_idle" -- 277
		local scx = cam:sx(childWX) -- 278
		local scy = cam:sy(childWY, childDepth) -- 279
		local cW = cam:len(22) -- 280
		local cH = cam:len(64) -- 281
		worldArt:tryPlace( -- 282
			slot, -- 282
			"carry_child_walk", -- 282
			scx, -- 282
			scy, -- 282
			cW, -- 282
			cH, -- 282
			{ -- 282
				facing = f, -- 283
				frame = speed > 8 and childStep or 0, -- 284
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 285
			} -- 285
		) -- 285
		fgDraw:drawEllipse( -- 287
			Vec2(scx, scy + 1), -- 287
			cW * 0.46, -- 287
			3.2, -- 287
			Color(10, 10, 12, 130) -- 287
		) -- 287
	end -- 287
	self.childAnchorX = childWX -- 290
	self.childAnchorY = childWY -- 291
	local sHandX = cam:sx(soldier.x - f * 8) -- 294
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 295
	local cHandX = cam:sx(childWX + f * 7) -- 296
	local cHandY = cam:sy(childWY + 36, childDepth) -- 297
	local swayY = speed > 8 and math.sin(self.animTime * 10.5) * cam:len(2.4) or math.sin(self.animTime * 2.2) * cam:len(0.8) -- 298
	local claspX = (sHandX + cHandX) * 0.5 -- 299
	local claspY = (sHandY + cHandY) * 0.5 + swayY -- 300
	fgDraw:drawSegment( -- 303
		Vec2( -- 303
			sHandX, -- 303
			sHandY + cam:len(5) -- 303
		), -- 303
		Vec2(claspX, claspY), -- 303
		math.max( -- 303
			2.6, -- 303
			cam:len(3) -- 303
		), -- 303
		CUFF_CLOTH -- 303
	) -- 303
	local mendX = sHandX + (claspX - sHandX) * 0.72 -- 304
	local mendY = sHandY + cam:len(5) + (claspY - (sHandY + cam:len(5))) * 0.72 -- 305
	fgDraw:drawSegment( -- 306
		Vec2(mendX - f * 2, mendY - 1.5), -- 306
		Vec2(mendX + f * 2, mendY + 1.5), -- 306
		1.3, -- 306
		CUFF_MEND -- 306
	) -- 306
	fgDraw:drawSegment( -- 309
		Vec2(cHandX, cHandY), -- 309
		Vec2(claspX, claspY), -- 309
		math.max( -- 309
			2, -- 309
			cam:len(2.2) -- 309
		), -- 309
		CHILD_SLEEVE -- 309
	) -- 309
	fgDraw:drawDot( -- 310
		Vec2(claspX - f * 2.5, claspY + 1), -- 310
		math.max( -- 310
			1.8, -- 310
			cam:len(1.4) -- 310
		), -- 310
		NEEDLE_CORD -- 310
	) -- 310
	fgDraw:drawCircle( -- 313
		Vec2(claspX, claspY), -- 313
		math.max( -- 313
			2.8, -- 313
			cam:len(2.4) -- 313
		), -- 313
		CHILD_SKIN -- 313
	) -- 313
	fgGlow:drawDot( -- 314
		Vec2(claspX, claspY), -- 314
		math.max( -- 314
			2.2, -- 314
			cam:len(1.8) -- 314
		), -- 314
		toColor(PALETTE.amberCore, 155) -- 314
	) -- 314
end -- 248
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 318
	local p = ctx.p -- 324
	local cam = ctx.cam -- 325
	local soldier = p.player -- 326
	local depthEnabled = p.room.depth ~= nil -- 327
	local sf = self.smoothedFacing -- 328
	local faceSign = sf >= 0 and 1 or -1 -- 329
	local speed = math.max( -- 330
		math.abs(soldier.vx), -- 330
		math.abs(soldier.depthSpeed) -- 330
	) -- 330
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 333
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 334
	local walking = speed > 8 and soldier.onGround -- 339
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2.3 or math.sin(self.animTime * 2.5) * 0.9 -- 340
	local targetBackX = soldier.x - sf * 13 -- 345
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 346
	local startGroundX = soldier.x - sf * 24 -- 349
	local startGroundY = soldier.y -- 350
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 351
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 353
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 354
	self.childAnchorX = childWX -- 355
	self.childAnchorY = childWY -- 356
	local cx = cam:sx(childWX) -- 358
	local cy = cam:sy(childWY, soldier.depth) -- 359
	local childW = cam:len(22) -- 360
	local childH = cam:len(42 + (1 - kMount) * 18) -- 361
	if self.mode == "mounting" and kMount < 0.72 then -- 361
		local scx = cam:sx(soldier.x) -- 365
		local scy = cam:sy(soldier.y, soldier.depth) -- 366
		fgDraw:drawEllipse( -- 367
			Vec2( -- 367
				scx - sf * cam:len(6), -- 367
				scy + 1 -- 367
			), -- 367
			cam:len(22), -- 367
			4.2, -- 367
			Color(10, 10, 12, 110) -- 367
		) -- 367
	end -- 367
	local backSlot = kMount < 0.45 and "child_crouch" or "child_peek" -- 371
	local tilt = -sf * (walking and 5.5 or 2.2) -- 372
	local childLayer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 373
	local placed = worldArt:tryPlace( -- 374
		backSlot, -- 374
		"carry_child", -- 374
		cx, -- 374
		cy, -- 374
		childW, -- 374
		childH, -- 374
		{facing = faceSign, angle = tilt, layer = childLayer} -- 374
	) -- 374
	if not placed then -- 374
		fgDraw:drawPolygon( -- 382
			{ -- 382
				Vec2(cx - childW * 0.4, cy + childH * 0.1), -- 383
				Vec2(cx + childW * 0.4, cy + childH * 0.1), -- 384
				Vec2(cx + childW * 0.3, cy + childH * 0.72), -- 385
				Vec2(cx - childW * 0.35, cy + childH * 0.72) -- 386
			}, -- 386
			CHILD_VEST, -- 387
			1, -- 387
			toColor(PALETTE.amberCore, 165) -- 387
		) -- 387
		fgDraw:drawCircle( -- 388
			Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), -- 388
			childW * 0.32, -- 388
			CHILD_SKIN -- 388
		) -- 388
	end -- 388
	local shoulderX = cam:sx(soldier.x + sf * 3) -- 392
	local shoulderY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth) -- 393
	local childShoulderX = cam:sx(childWX + sf * 5) -- 394
	local childShoulderY = cam:sy(childWY + 26, soldier.depth) -- 395
	local hipSupportX = cam:sx(soldier.x - sf * 10) -- 398
	local hipSupportY = cam:sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth) -- 399
	fgDraw:drawSegment( -- 400
		Vec2( -- 401
			cam:sx(soldier.x - sf * 2), -- 401
			cam:sy(soldier.y + 42 - crouchDip, soldier.depth) -- 401
		), -- 401
		Vec2(hipSupportX, hipSupportY), -- 402
		math.max( -- 403
			2.4, -- 403
			cam:len(2.8) -- 403
		), -- 403
		CUFF_CLOTH -- 404
	) -- 404
	fgDraw:drawSegment( -- 406
		Vec2(hipSupportX - sf * 2, hipSupportY + 1), -- 407
		Vec2(hipSupportX + sf * 3, hipSupportY + 1), -- 408
		1.2, -- 409
		CUFF_MEND -- 410
	) -- 410
	if self.reachT > 0.05 and kMount > 0.7 then -- 410
		local reachFrac = smoothStep(self.reachT) -- 415
		local elbowX = shoulderX + sf * cam:len(4 + reachFrac * 5) -- 416
		local elbowY = shoulderY + cam:len(1 + reachFrac * 3) -- 417
		local handEndX = elbowX + sf * cam:len(5 + reachFrac * 11) -- 418
		local handEndY = elbowY + cam:len(2 + reachFrac * 5) -- 419
		fgDraw:drawSegment( -- 420
			Vec2(childShoulderX, childShoulderY), -- 420
			Vec2(elbowX, elbowY), -- 420
			math.max( -- 420
				2, -- 420
				cam:len(2.1) -- 420
			), -- 420
			CHILD_SLEEVE -- 420
		) -- 420
		fgDraw:drawSegment( -- 421
			Vec2(elbowX, elbowY), -- 421
			Vec2( -- 421
				handEndX - sf * cam:len(3), -- 421
				handEndY - cam:len(1) -- 421
			), -- 421
			math.max( -- 421
				1.7, -- 421
				cam:len(1.8) -- 421
			), -- 421
			CHILD_SLEEVE -- 421
		) -- 421
		fgDraw:drawDot( -- 423
			Vec2( -- 423
				handEndX - sf * cam:len(3.2), -- 423
				handEndY - cam:len(0.8) -- 423
			), -- 423
			math.max( -- 423
				1.5, -- 423
				cam:len(1.2) -- 423
			), -- 423
			NEEDLE_CORD -- 423
		) -- 423
		fgDraw:drawCircle( -- 424
			Vec2(handEndX, handEndY), -- 424
			math.max( -- 424
				2.1, -- 424
				cam:len(1.8) -- 424
			), -- 424
			CHILD_SKIN -- 424
		) -- 424
		fgDraw:drawSegment( -- 425
			Vec2(handEndX, handEndY), -- 425
			Vec2( -- 425
				handEndX + sf * cam:len(3.5), -- 425
				handEndY + cam:len(1.2) -- 425
			), -- 425
			math.max( -- 425
				1.1, -- 425
				cam:len(1) -- 425
			), -- 425
			CHILD_SKIN -- 425
		) -- 425
		fillRadialGlow( -- 426
			fgGlow, -- 427
			handEndX + sf * cam:len(3), -- 428
			handEndY + cam:len(1), -- 429
			cam:len(7 * reachFrac), -- 430
			cam:len(7 * reachFrac), -- 431
			toColor(PALETTE.amberCore, 72 * reachFrac), -- 432
			Color(244, 234, 214, 0), -- 433
			10 -- 434
		) -- 434
	elseif kMount > 0.35 then -- 434
		local armAlpha = clamp01((kMount - 0.35) / 0.65) -- 437
		local gripX = shoulderX + sf * cam:len(4) -- 438
		local gripY = shoulderY - cam:len(2) -- 439
		fgDraw:drawSegment( -- 440
			Vec2(childShoulderX, childShoulderY), -- 441
			Vec2(gripX, gripY), -- 442
			math.max( -- 443
				1.8, -- 443
				cam:len(2) -- 443
			), -- 443
			Color( -- 444
				164, -- 444
				78, -- 444
				54, -- 444
				math.floor(255 * armAlpha + 0.5) -- 444
			) -- 444
		) -- 444
		fgDraw:drawDot( -- 446
			Vec2(gripX - sf * 2, gripY), -- 446
			math.max( -- 446
				1.5, -- 446
				cam:len(1.2) -- 446
			), -- 446
			Color( -- 446
				198, -- 446
				166, -- 446
				114, -- 446
				math.floor(235 * armAlpha + 0.5) -- 446
			) -- 446
		) -- 446
		fgDraw:drawCircle( -- 447
			Vec2(gripX, gripY), -- 447
			math.max( -- 447
				2, -- 447
				cam:len(1.7) -- 447
			), -- 447
			Color( -- 447
				236, -- 447
				210, -- 447
				182, -- 447
				math.floor(255 * armAlpha + 0.5) -- 447
			) -- 447
		) -- 447
	end -- 447
end -- 318
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 452
	local p = ctx.p -- 458
	local cam = ctx.cam -- 459
	local soldier = p.player -- 460
	local depthEnabled = p.room.depth ~= nil -- 461
	local f = soldier.facing >= 0 and 1 or -1 -- 462
	local dropK = smoothStep(self.benchDropT) -- 463
	local startX = soldier.x - f * 12 -- 466
	local startY = soldier.y + 26 -- 467
	local standX = soldier.x + f * 30 -- 468
	local standY = soldier.y -- 469
	local childWX = startX + (standX - startX) * dropK -- 470
	local childWY = startY + (standY - startY) * dropK -- 471
	self.childAnchorX = childWX -- 472
	self.childAnchorY = childWY -- 473
	local cx = cam:sx(childWX) -- 475
	local cy = cam:sy(childWY, soldier.depth) -- 476
	local cW = cam:len(22) -- 477
	local cH = cam:len(64) -- 478
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 480
	local slot = handing and "child_offer" or "child_idle" -- 481
	worldArt:tryPlace( -- 483
		slot, -- 483
		"carry_child_bench", -- 483
		cx, -- 483
		cy, -- 483
		cW, -- 483
		cH, -- 483
		{ -- 483
			facing = -f, -- 484
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 485
		} -- 485
	) -- 485
	fgDraw:drawEllipse( -- 487
		Vec2( -- 487
			cx, -- 487
			cam:sy(soldier.y, soldier.depth) + 1 -- 487
		), -- 487
		cW * 0.48 * dropK, -- 487
		3.2, -- 487
		Color(10, 10, 12, 130) -- 487
	) -- 487
	if handing then -- 487
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 491
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 492
		local midY = cam:sy( -- 493
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 493
			soldier.depth -- 493
		) -- 493
		local gunLen = cam:len(22) -- 494
		fgDraw:drawSegment( -- 495
			Vec2(midX - f * gunLen * 0.4, midY - 2), -- 495
			Vec2(midX + f * gunLen * 0.25, midY + 1), -- 495
			3.2, -- 495
			Color(108, 74, 52, 255) -- 495
		) -- 495
		fgDraw:drawSegment( -- 496
			Vec2(midX + f * gunLen * 0.1, midY + 1), -- 496
			Vec2(midX + f * gunLen * 0.65, midY + 3), -- 496
			1.8, -- 496
			Color(148, 144, 134, 245) -- 496
		) -- 496
		fillRadialGlow( -- 497
			fgGlow, -- 497
			midX, -- 497
			midY, -- 497
			cam:len(14), -- 497
			cam:len(10), -- 497
			toColor(PALETTE.amberCore, 72), -- 497
			Color(244, 234, 214, 0), -- 497
			10 -- 497
		) -- 497
	end -- 497
end -- 452
function ____exports.createCarryPosePlugin() -- 502
	return __TS__New(____exports.CarryPosePlugin) -- 503
end -- 502
return ____exports -- 502