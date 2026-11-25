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
--- 同一道青布补线袖口（同源 cuff_shots.CUFF_PALETTE）与明初小满红褐短袄色板
local CUFF_CLOTH = toColor(CUFF_PALETTE.indigoBase) -- 48
local CUFF_MEND = toColor(CUFF_PALETTE.stitchThread) -- 49
local CHILD_SLEEVE = Color(164, 78, 54, 255) -- 50
local CHILD_SKIN = Color(236, 210, 182, 255) -- 51
local CHILD_VEST = Color(146, 68, 48, 255) -- 52
local NEEDLE_CORD = Color(198, 166, 114, 240) -- 53
local function clamp01(v) -- 55
	return math.max( -- 56
		0, -- 56
		math.min(1, v) -- 56
	) -- 56
end -- 55
local function smoothStep(t) -- 59
	local k = clamp01(t) -- 60
	return k * k * (3 - 2 * k) -- 61
end -- 59
local function suppressOriginalChild(worldArt) -- 64
	local i = 0 -- 65
	do -- 65
		i = 0 -- 66
		while i < #CHILD_SPRITE_PATHS do -- 66
			worldArt:tryPlacePath( -- 67
				CHILD_SPRITE_PATHS[i + 1], -- 68
				"actor_child", -- 69
				-9999, -- 69
				-9999, -- 69
				1, -- 72
				1, -- 73
				{anchorY = 0, preserveAspect = true, opacity = 0, layer = -99} -- 74
			) -- 74
			i = i + 1 -- 66
		end -- 66
	end -- 66
end -- 64
____exports.CarryPosePlugin = __TS__Class() -- 79
local CarryPosePlugin = ____exports.CarryPosePlugin -- 79
CarryPosePlugin.name = "CarryPosePlugin" -- 79
function CarryPosePlugin.prototype.____constructor(self) -- 79
	self.id = "fe-02-carry-pose" -- 80
	self.animTime = 0 -- 82
	self.smoothedFacing = 1 -- 83
	self.mountT = 0 -- 84
	self.benchDropT = 0 -- 85
	self.reachT = 0 -- 86
	self.mode = "none" -- 87
	self.childAnchorX = 0 -- 88
	self.childAnchorY = 0 -- 89
	self.handoverActive = false -- 90
	self.carryAudioRoomSession = -1 -- 91
end -- 79
function CarryPosePlugin.prototype.getPoseState(self) -- 93
	return { -- 94
		mode = self.mode, -- 95
		smoothedFacing = self.smoothedFacing, -- 96
		mountT = self.mountT, -- 97
		benchDropT = self.benchDropT, -- 98
		reachT = self.reachT, -- 99
		childAnchorX = self.childAnchorX, -- 100
		childAnchorY = self.childAnchorY, -- 101
		handoverActive = self.handoverActive -- 102
	} -- 102
end -- 93
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 106
	self.animTime = 0 -- 107
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 108
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 109
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 110
	self.reachT = 0 -- 111
	self.mode = self:resolveMode(view) -- 112
	self.childAnchorX = p.player.x -- 113
	self.childAnchorY = p.player.y -- 114
	self.handoverActive = false -- 115
	self.carryAudioRoomSession = -1 -- 116
end -- 106
function CarryPosePlugin.prototype.resolveMode(self, view) -- 119
	local bc = view.backCarry -- 120
	if bc.atBench or view.craftBench.active then -- 120
		return "atBench" -- 122
	end -- 122
	if bc.mounting then -- 122
		return "mounting" -- 125
	end -- 125
	if bc.active then -- 125
		return "carrying" -- 128
	end -- 128
	if bc.handInHand then -- 128
		return "handInHand" -- 131
	end -- 131
	return "none" -- 133
end -- 119
function CarryPosePlugin.prototype.update(self, ctx) -- 136
	local view = ctx.view -- 137
	local p = ctx.p -- 138
	self.mode = self:resolveMode(view) -- 139
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 140
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 140
		return -- 143
	end -- 143
	if ctx.paused then -- 143
		return -- 146
	end -- 146
	local wdt = math.max(0, ctx.worldDt) -- 149
	local udt = math.max(0, ctx.uiDt) -- 150
	if wdt > 0 then -- 150
		self.animTime = self.animTime + wdt -- 153
		local targetF = p.player.facing >= 0 and 1 or -1 -- 156
		local turnK = math.min(1, wdt * 15) -- 157
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 158
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 158
			self.smoothedFacing = targetF -- 160
		end -- 160
		if self.mode == "mounting" then -- 160
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 165
		elseif self.mode == "carrying" then -- 165
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 167
		elseif self.mode == "handInHand" or self.mode == "none" then -- 167
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 169
		end -- 169
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 173
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 174
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 174
			self.benchDropT = dropTarget -- 176
		end -- 176
	end -- 176
	if udt > 0 then -- 176
		local reachTarget = view.reloadSession.active and 1 or 0 -- 182
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 183
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 186
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 186
			self.reachT = reachTarget -- 188
		end -- 188
	end -- 188
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 188
		local hasBackendEvent = false -- 195
		local i = 0 -- 196
		do -- 196
			i = 0 -- 197
			while i < #ctx.events.rawEvents do -- 197
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 197
					hasBackendEvent = true -- 199
					break -- 200
				end -- 200
				i = i + 1 -- 197
			end -- 197
		end -- 197
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 203
		if not hasBackendEvent then -- 203
			ctx.audio:playOnce( -- 205
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 206
				"sfx", -- 207
				"assets/audio/combat/carry_start.wav", -- 208
				0.82, -- 209
				"combat:carry_start", -- 210
				p.ticks -- 211
			) -- 211
		end -- 211
	end -- 211
end -- 136
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 217
	local view = ctx.view -- 223
	local p = ctx.p -- 224
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 224
		return -- 226
	end -- 226
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 226
		return -- 229
	end -- 229
	if self.mode == "handInHand" then -- 229
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 233
		return -- 234
	end -- 234
	suppressOriginalChild(worldArt) -- 238
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 238
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 241
		return -- 242
	end -- 242
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 245
end -- 217
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 249
	local p = ctx.p -- 255
	local cam = ctx.cam -- 256
	local soldier = p.player -- 257
	local partner = p.partner -- 258
	local depthEnabled = p.room.depth ~= nil -- 259
	local f = soldier.facing >= 0 and 1 or -1 -- 260
	local speed = math.max( -- 261
		math.abs(soldier.vx), -- 261
		math.abs(soldier.depthSpeed) -- 261
	) -- 261
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 264
	local childWX = partner.x -- 265
	local childWY = partner.y -- 266
	local childDepth = partner.depth -- 267
	if not nearPartner then -- 267
		suppressOriginalChild(worldArt) -- 270
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 272
		childWX = soldier.x - f * 26 + lag -- 273
		childWY = soldier.y -- 274
		childDepth = soldier.depth -- 275
		local childStep = math.floor(self.animTime * 13) -- 277
		local slot = speed > 8 and "child_run" or "child_idle" -- 278
		local scx = cam:sx(childWX) -- 279
		local scy = cam:sy(childWY, childDepth) -- 280
		local cW = cam:len(22) -- 281
		local cH = cam:len(64) -- 282
		worldArt:tryPlace( -- 283
			slot, -- 283
			"carry_child_walk", -- 283
			scx, -- 283
			scy, -- 283
			cW, -- 283
			cH, -- 283
			{ -- 283
				facing = f, -- 284
				frame = speed > 8 and childStep or 0, -- 285
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 286
			} -- 286
		) -- 286
		fgDraw:drawEllipse( -- 288
			Vec2(scx, scy + 1), -- 288
			cW * 0.46, -- 288
			3.2, -- 288
			Color(10, 10, 12, 130) -- 288
		) -- 288
	end -- 288
	self.childAnchorX = childWX -- 291
	self.childAnchorY = childWY -- 292
	local sHandX = cam:sx(soldier.x - f * 8) -- 295
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 296
	local cHandX = cam:sx(childWX + f * 7) -- 297
	local cHandY = cam:sy(childWY + 36, childDepth) -- 298
	local swayY = speed > 8 and math.sin(self.animTime * 10.5) * cam:len(2.4) or math.sin(self.animTime * 2.2) * cam:len(0.8) -- 299
	local claspX = (sHandX + cHandX) * 0.5 -- 300
	local claspY = (sHandY + cHandY) * 0.5 + swayY -- 301
	fgDraw:drawSegment( -- 304
		Vec2( -- 304
			sHandX, -- 304
			sHandY + cam:len(5) -- 304
		), -- 304
		Vec2(claspX, claspY), -- 304
		math.max( -- 304
			2.6, -- 304
			cam:len(3) -- 304
		), -- 304
		CUFF_CLOTH -- 304
	) -- 304
	local mendX = sHandX + (claspX - sHandX) * 0.72 -- 305
	local mendY = sHandY + cam:len(5) + (claspY - (sHandY + cam:len(5))) * 0.72 -- 306
	fgDraw:drawSegment( -- 307
		Vec2(mendX - f * 2, mendY - 1.5), -- 307
		Vec2(mendX + f * 2, mendY + 1.5), -- 307
		1.3, -- 307
		CUFF_MEND -- 307
	) -- 307
	fgDraw:drawSegment( -- 310
		Vec2(cHandX, cHandY), -- 310
		Vec2(claspX, claspY), -- 310
		math.max( -- 310
			2, -- 310
			cam:len(2.2) -- 310
		), -- 310
		CHILD_SLEEVE -- 310
	) -- 310
	fgDraw:drawDot( -- 311
		Vec2(claspX - f * 2.5, claspY + 1), -- 311
		math.max( -- 311
			1.8, -- 311
			cam:len(1.4) -- 311
		), -- 311
		NEEDLE_CORD -- 311
	) -- 311
	fgDraw:drawCircle( -- 314
		Vec2(claspX, claspY), -- 314
		math.max( -- 314
			2.8, -- 314
			cam:len(2.4) -- 314
		), -- 314
		CHILD_SKIN -- 314
	) -- 314
	fgGlow:drawDot( -- 315
		Vec2(claspX, claspY), -- 315
		math.max( -- 315
			2.2, -- 315
			cam:len(1.8) -- 315
		), -- 315
		toColor(PALETTE.amberCore, 155) -- 315
	) -- 315
end -- 249
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 319
	local p = ctx.p -- 325
	local cam = ctx.cam -- 326
	local soldier = p.player -- 327
	local depthEnabled = p.room.depth ~= nil -- 328
	local sf = self.smoothedFacing -- 329
	local faceSign = sf >= 0 and 1 or -1 -- 330
	local speed = math.max( -- 331
		math.abs(soldier.vx), -- 331
		math.abs(soldier.depthSpeed) -- 331
	) -- 331
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 334
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 335
	local walking = speed > 8 and soldier.onGround -- 340
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2.3 or math.sin(self.animTime * 2.5) * 0.9 -- 341
	local targetBackX = soldier.x - sf * 13 -- 346
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 347
	local startGroundX = soldier.x - sf * 24 -- 350
	local startGroundY = soldier.y -- 351
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 352
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 354
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 355
	self.childAnchorX = childWX -- 356
	self.childAnchorY = childWY -- 357
	local cx = cam:sx(childWX) -- 359
	local cy = cam:sy(childWY, soldier.depth) -- 360
	local childW = cam:len(22) -- 361
	local childH = cam:len(42 + (1 - kMount) * 18) -- 362
	if self.mode == "mounting" and kMount < 0.72 then -- 362
		local scx = cam:sx(soldier.x) -- 366
		local scy = cam:sy(soldier.y, soldier.depth) -- 367
		fgDraw:drawEllipse( -- 368
			Vec2( -- 368
				scx - sf * cam:len(6), -- 368
				scy + 1 -- 368
			), -- 368
			cam:len(22), -- 368
			4.2, -- 368
			Color(10, 10, 12, 110) -- 368
		) -- 368
	end -- 368
	local backSlot = kMount < 0.45 and "child_crouch" or "child_peek" -- 372
	local tilt = -sf * (walking and 5.5 or 2.2) -- 373
	local childLayer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 374
	local placed = worldArt:tryPlace( -- 375
		backSlot, -- 375
		"carry_child", -- 375
		cx, -- 375
		cy, -- 375
		childW, -- 375
		childH, -- 375
		{facing = faceSign, angle = tilt, layer = childLayer} -- 375
	) -- 375
	if not placed then -- 375
		fgDraw:drawPolygon( -- 383
			{ -- 383
				Vec2(cx - childW * 0.4, cy + childH * 0.1), -- 384
				Vec2(cx + childW * 0.4, cy + childH * 0.1), -- 385
				Vec2(cx + childW * 0.3, cy + childH * 0.72), -- 386
				Vec2(cx - childW * 0.35, cy + childH * 0.72) -- 387
			}, -- 387
			CHILD_VEST, -- 388
			1, -- 388
			toColor(PALETTE.amberCore, 165) -- 388
		) -- 388
		fgDraw:drawCircle( -- 389
			Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), -- 389
			childW * 0.32, -- 389
			CHILD_SKIN -- 389
		) -- 389
	end -- 389
	local shoulderX = cam:sx(soldier.x + sf * 3) -- 393
	local shoulderY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth) -- 394
	local childShoulderX = cam:sx(childWX + sf * 5) -- 395
	local childShoulderY = cam:sy(childWY + 26, soldier.depth) -- 396
	local hipSupportX = cam:sx(soldier.x - sf * 10) -- 399
	local hipSupportY = cam:sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth) -- 400
	fgDraw:drawSegment( -- 401
		Vec2( -- 402
			cam:sx(soldier.x - sf * 2), -- 402
			cam:sy(soldier.y + 42 - crouchDip, soldier.depth) -- 402
		), -- 402
		Vec2(hipSupportX, hipSupportY), -- 403
		math.max( -- 404
			2.4, -- 404
			cam:len(2.8) -- 404
		), -- 404
		CUFF_CLOTH -- 405
	) -- 405
	fgDraw:drawSegment( -- 407
		Vec2(hipSupportX - sf * 2, hipSupportY + 1), -- 408
		Vec2(hipSupportX + sf * 3, hipSupportY + 1), -- 409
		1.2, -- 410
		CUFF_MEND -- 411
	) -- 411
	if self.reachT > 0.05 and kMount > 0.7 then -- 411
		local reachFrac = smoothStep(self.reachT) -- 416
		local elbowX = shoulderX + sf * cam:len(4 + reachFrac * 5) -- 417
		local elbowY = shoulderY + cam:len(1 + reachFrac * 3) -- 418
		local handEndX = elbowX + sf * cam:len(5 + reachFrac * 11) -- 419
		local handEndY = elbowY + cam:len(2 + reachFrac * 5) -- 420
		fgDraw:drawSegment( -- 421
			Vec2(childShoulderX, childShoulderY), -- 421
			Vec2(elbowX, elbowY), -- 421
			math.max( -- 421
				2, -- 421
				cam:len(2.1) -- 421
			), -- 421
			CHILD_SLEEVE -- 421
		) -- 421
		fgDraw:drawSegment( -- 422
			Vec2(elbowX, elbowY), -- 422
			Vec2( -- 422
				handEndX - sf * cam:len(3), -- 422
				handEndY - cam:len(1) -- 422
			), -- 422
			math.max( -- 422
				1.7, -- 422
				cam:len(1.8) -- 422
			), -- 422
			CHILD_SLEEVE -- 422
		) -- 422
		fgDraw:drawDot( -- 424
			Vec2( -- 424
				handEndX - sf * cam:len(3.2), -- 424
				handEndY - cam:len(0.8) -- 424
			), -- 424
			math.max( -- 424
				1.5, -- 424
				cam:len(1.2) -- 424
			), -- 424
			NEEDLE_CORD -- 424
		) -- 424
		fgDraw:drawCircle( -- 425
			Vec2(handEndX, handEndY), -- 425
			math.max( -- 425
				2.1, -- 425
				cam:len(1.8) -- 425
			), -- 425
			CHILD_SKIN -- 425
		) -- 425
		fgDraw:drawSegment( -- 426
			Vec2(handEndX, handEndY), -- 426
			Vec2( -- 426
				handEndX + sf * cam:len(3.5), -- 426
				handEndY + cam:len(1.2) -- 426
			), -- 426
			math.max( -- 426
				1.1, -- 426
				cam:len(1) -- 426
			), -- 426
			CHILD_SKIN -- 426
		) -- 426
		fillRadialGlow( -- 427
			fgGlow, -- 428
			handEndX + sf * cam:len(3), -- 429
			handEndY + cam:len(1), -- 430
			cam:len(7 * reachFrac), -- 431
			cam:len(7 * reachFrac), -- 432
			toColor(PALETTE.amberCore, 72 * reachFrac), -- 433
			Color(244, 234, 214, 0), -- 434
			10 -- 435
		) -- 435
	elseif kMount > 0.35 then -- 435
		local armAlpha = clamp01((kMount - 0.35) / 0.65) -- 438
		local gripX = shoulderX + sf * cam:len(4) -- 439
		local gripY = shoulderY - cam:len(2) -- 440
		fgDraw:drawSegment( -- 441
			Vec2(childShoulderX, childShoulderY), -- 442
			Vec2(gripX, gripY), -- 443
			math.max( -- 444
				1.8, -- 444
				cam:len(2) -- 444
			), -- 444
			Color( -- 445
				164, -- 445
				78, -- 445
				54, -- 445
				math.floor(255 * armAlpha + 0.5) -- 445
			) -- 445
		) -- 445
		fgDraw:drawDot( -- 447
			Vec2(gripX - sf * 2, gripY), -- 447
			math.max( -- 447
				1.5, -- 447
				cam:len(1.2) -- 447
			), -- 447
			Color( -- 447
				198, -- 447
				166, -- 447
				114, -- 447
				math.floor(235 * armAlpha + 0.5) -- 447
			) -- 447
		) -- 447
		fgDraw:drawCircle( -- 448
			Vec2(gripX, gripY), -- 448
			math.max( -- 448
				2, -- 448
				cam:len(1.7) -- 448
			), -- 448
			Color( -- 448
				236, -- 448
				210, -- 448
				182, -- 448
				math.floor(255 * armAlpha + 0.5) -- 448
			) -- 448
		) -- 448
	end -- 448
end -- 319
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 453
	local p = ctx.p -- 459
	local cam = ctx.cam -- 460
	local soldier = p.player -- 461
	local depthEnabled = p.room.depth ~= nil -- 462
	local f = soldier.facing >= 0 and 1 or -1 -- 463
	local dropK = smoothStep(self.benchDropT) -- 464
	local startX = soldier.x - f * 12 -- 467
	local startY = soldier.y + 26 -- 468
	local standX = soldier.x + f * 30 -- 469
	local standY = soldier.y -- 470
	local childWX = startX + (standX - startX) * dropK -- 471
	local childWY = startY + (standY - startY) * dropK -- 472
	self.childAnchorX = childWX -- 473
	self.childAnchorY = childWY -- 474
	local cx = cam:sx(childWX) -- 476
	local cy = cam:sy(childWY, soldier.depth) -- 477
	local cW = cam:len(22) -- 478
	local cH = cam:len(64) -- 479
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 481
	local slot = handing and "child_offer" or "child_idle" -- 482
	worldArt:tryPlace( -- 484
		slot, -- 484
		"carry_child_bench", -- 484
		cx, -- 484
		cy, -- 484
		cW, -- 484
		cH, -- 484
		{ -- 484
			facing = -f, -- 485
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 486
		} -- 486
	) -- 486
	fgDraw:drawEllipse( -- 488
		Vec2( -- 488
			cx, -- 488
			cam:sy(soldier.y, soldier.depth) + 1 -- 488
		), -- 488
		cW * 0.48 * dropK, -- 488
		3.2, -- 488
		Color(10, 10, 12, 130) -- 488
	) -- 488
	if handing then -- 488
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 492
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 493
		local midY = cam:sy( -- 494
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 494
			soldier.depth -- 494
		) -- 494
		local gunLen = cam:len(22) -- 495
		fgDraw:drawSegment( -- 496
			Vec2(midX - f * gunLen * 0.4, midY - 2), -- 496
			Vec2(midX + f * gunLen * 0.25, midY + 1), -- 496
			3.2, -- 496
			Color(108, 74, 52, 255) -- 496
		) -- 496
		fgDraw:drawSegment( -- 497
			Vec2(midX + f * gunLen * 0.1, midY + 1), -- 497
			Vec2(midX + f * gunLen * 0.65, midY + 3), -- 497
			1.8, -- 497
			Color(148, 144, 134, 245) -- 497
		) -- 497
		fillRadialGlow( -- 498
			fgGlow, -- 498
			midX, -- 498
			midY, -- 498
			cam:len(14), -- 498
			cam:len(10), -- 498
			toColor(PALETTE.amberCore, 72), -- 498
			Color(244, 234, 214, 0), -- 498
			10 -- 498
		) -- 498
	end -- 498
end -- 453
function ____exports.createCarryPosePlugin() -- 503
	return __TS__New(____exports.CarryPosePlugin) -- 504
end -- 503
return ____exports -- 503