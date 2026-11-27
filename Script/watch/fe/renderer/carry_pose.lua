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
end -- 51
function CarryPosePlugin.prototype.getPoseState(self) -- 65
	return { -- 66
		mode = self.mode, -- 67
		smoothedFacing = self.smoothedFacing, -- 68
		mountT = self.mountT, -- 69
		benchDropT = self.benchDropT, -- 70
		reachT = self.reachT, -- 71
		childAnchorX = self.childAnchorX, -- 72
		childAnchorY = self.childAnchorY, -- 73
		handoverActive = self.handoverActive -- 74
	} -- 74
end -- 65
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 78
	self.animTime = 0 -- 79
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 80
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 81
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 82
	self.reachT = 0 -- 83
	self.mode = self:resolveMode(view) -- 84
	self.childAnchorX = p.player.x -- 85
	self.childAnchorY = p.player.y -- 86
	self.handoverActive = false -- 87
	self.carryAudioRoomSession = -1 -- 88
end -- 78
function CarryPosePlugin.prototype.resolveMode(self, view) -- 91
	local bc = view.backCarry -- 92
	if bc.atBench or view.craftBench.active then -- 92
		return "atBench" -- 94
	end -- 94
	if bc.mounting then -- 94
		return "mounting" -- 97
	end -- 97
	if bc.active then -- 97
		return "carrying" -- 100
	end -- 100
	if bc.handInHand then -- 100
		return "handInHand" -- 103
	end -- 103
	return "none" -- 105
end -- 91
function CarryPosePlugin.prototype.update(self, ctx) -- 108
	local view = ctx.view -- 109
	local p = ctx.p -- 110
	self.mode = self:resolveMode(view) -- 111
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 112
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 112
		return -- 115
	end -- 115
	if ctx.paused then -- 115
		return -- 118
	end -- 118
	local wdt = math.max(0, ctx.worldDt) -- 121
	local udt = math.max(0, ctx.uiDt) -- 122
	if wdt > 0 then -- 122
		self.animTime = self.animTime + wdt -- 125
		local targetF = p.player.facing >= 0 and 1 or -1 -- 128
		local turnK = math.min(1, wdt * 15) -- 129
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 130
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 130
			self.smoothedFacing = targetF -- 132
		end -- 132
		if self.mode == "mounting" then -- 132
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 137
		elseif self.mode == "carrying" then -- 137
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 139
		elseif self.mode == "handInHand" or self.mode == "none" then -- 139
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 141
		end -- 141
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 145
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 146
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 146
			self.benchDropT = dropTarget -- 148
		end -- 148
	end -- 148
	if udt > 0 then -- 148
		local reachTarget = view.reloadSession.active and 1 or 0 -- 154
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 155
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 158
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 158
			self.reachT = reachTarget -- 160
		end -- 160
	end -- 160
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 160
		local hasBackendEvent = false -- 167
		local i = 0 -- 168
		do -- 168
			i = 0 -- 169
			while i < #ctx.events.rawEvents do -- 169
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 169
					hasBackendEvent = true -- 171
					break -- 172
				end -- 172
				i = i + 1 -- 169
			end -- 169
		end -- 169
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 175
		if not hasBackendEvent then -- 175
			ctx.audio:playOnce( -- 177
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 178
				"sfx", -- 179
				"assets/audio/combat/carry_start.wav", -- 180
				0.82, -- 181
				"combat:carry_start", -- 182
				p.ticks -- 183
			) -- 183
		end -- 183
	end -- 183
end -- 108
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 189
	local view = ctx.view -- 195
	local p = ctx.p -- 196
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 196
		return -- 198
	end -- 198
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 198
		return -- 201
	end -- 201
	if self.mode == "handInHand" then -- 201
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 205
		return -- 206
	end -- 206
	worldArt:hideInstance("actor_child") -- 210
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 210
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 213
		return -- 214
	end -- 214
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 217
end -- 189
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 221
	local p = ctx.p -- 227
	local cam = ctx.cam -- 228
	local soldier = p.player -- 229
	local partner = p.partner -- 230
	local depthEnabled = p.room.depth ~= nil -- 231
	local f = soldier.facing >= 0 and 1 or -1 -- 232
	local speed = math.max( -- 233
		math.abs(soldier.vx), -- 233
		math.abs(soldier.depthSpeed) -- 233
	) -- 233
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 236
	local childWX = partner.x -- 237
	local childWY = partner.y -- 238
	local childDepth = partner.depth -- 239
	if not nearPartner then -- 239
		worldArt:hideInstance("actor_child") -- 242
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 244
		childWX = soldier.x - f * 26 + lag -- 245
		childWY = soldier.y -- 246
		childDepth = soldier.depth -- 247
		local scx = cam:sx(childWX) -- 249
		local scy = cam:sy(childWY, childDepth) -- 250
		local cW = cam:len(22) -- 251
		local cH = cam:len(64) -- 252
		local pose = { -- 253
			facing = f, -- 253
			layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 253
		} -- 253
		if speed <= 8 or not worldArt:tryPlaceRun( -- 253
			"child", -- 255
			"carry_child_walk", -- 255
			scx, -- 255
			scy, -- 255
			cW, -- 255
			cH, -- 255
			self.animTime * 1.8, -- 255
			pose -- 255
		) then -- 255
			worldArt:tryPlace( -- 256
				"child_idle", -- 256
				"carry_child_walk", -- 256
				scx, -- 256
				scy, -- 256
				cW, -- 256
				cH, -- 256
				pose -- 256
			) -- 256
		end -- 256
		fgDraw:drawEllipse( -- 258
			Vec2(scx, scy + 1), -- 258
			cW * 0.46, -- 258
			3.2, -- 258
			Color(10, 10, 12, 130) -- 258
		) -- 258
	end -- 258
	self.childAnchorX = childWX -- 261
	self.childAnchorY = childWY -- 262
	local sHandX = cam:sx(soldier.x - f * 8) -- 265
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 266
	local cHandX = cam:sx(childWX + f * 7) -- 267
	local cHandY = cam:sy(childWY + 36, childDepth) -- 268
	local swayY = speed > 8 and math.sin(self.animTime * 10.5) * cam:len(2.4) or math.sin(self.animTime * 2.2) * cam:len(0.8) -- 269
	local claspX = (sHandX + cHandX) * 0.5 -- 270
	local claspY = (sHandY + cHandY) * 0.5 + swayY -- 271
	fgDraw:drawSegment( -- 274
		Vec2( -- 274
			sHandX, -- 274
			sHandY + cam:len(5) -- 274
		), -- 274
		Vec2(claspX, claspY), -- 274
		math.max( -- 274
			2.6, -- 274
			cam:len(3) -- 274
		), -- 274
		CUFF_CLOTH -- 274
	) -- 274
	local mendX = sHandX + (claspX - sHandX) * 0.72 -- 275
	local mendY = sHandY + cam:len(5) + (claspY - (sHandY + cam:len(5))) * 0.72 -- 276
	fgDraw:drawSegment( -- 277
		Vec2(mendX - f * 2, mendY - 1.5), -- 277
		Vec2(mendX + f * 2, mendY + 1.5), -- 277
		1.3, -- 277
		CUFF_MEND -- 277
	) -- 277
	fgDraw:drawSegment( -- 280
		Vec2(cHandX, cHandY), -- 280
		Vec2(claspX, claspY), -- 280
		math.max( -- 280
			2, -- 280
			cam:len(2.2) -- 280
		), -- 280
		CHILD_SLEEVE -- 280
	) -- 280
	fgDraw:drawDot( -- 281
		Vec2(claspX - f * 2.5, claspY + 1), -- 281
		math.max( -- 281
			1.8, -- 281
			cam:len(1.4) -- 281
		), -- 281
		NEEDLE_CORD -- 281
	) -- 281
	fgDraw:drawCircle( -- 284
		Vec2(claspX, claspY), -- 284
		math.max( -- 284
			2.8, -- 284
			cam:len(2.4) -- 284
		), -- 284
		CHILD_SKIN -- 284
	) -- 284
	fgGlow:drawDot( -- 285
		Vec2(claspX, claspY), -- 285
		math.max( -- 285
			2.2, -- 285
			cam:len(1.8) -- 285
		), -- 285
		toColor(PALETTE.amberCore, 155) -- 285
	) -- 285
end -- 221
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 289
	local p = ctx.p -- 295
	local cam = ctx.cam -- 296
	local soldier = p.player -- 297
	local depthEnabled = p.room.depth ~= nil -- 298
	local sf = self.smoothedFacing -- 299
	local faceSign = sf >= 0 and 1 or -1 -- 300
	local speed = math.max( -- 301
		math.abs(soldier.vx), -- 301
		math.abs(soldier.depthSpeed) -- 301
	) -- 301
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 304
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 305
	local walking = speed > 8 and soldier.onGround -- 310
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2.3 or math.sin(self.animTime * 2.5) * 0.9 -- 311
	local targetBackX = soldier.x - sf * 13 -- 316
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 317
	local startGroundX = soldier.x - sf * 24 -- 320
	local startGroundY = soldier.y -- 321
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 322
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 324
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 325
	self.childAnchorX = childWX -- 326
	self.childAnchorY = childWY -- 327
	local cx = cam:sx(childWX) -- 329
	local cy = cam:sy(childWY, soldier.depth) -- 330
	local childW = cam:len(22) -- 331
	local childH = cam:len(42 + (1 - kMount) * 18) -- 332
	if self.mode == "mounting" and kMount < 0.72 then -- 332
		local scx = cam:sx(soldier.x) -- 336
		local scy = cam:sy(soldier.y, soldier.depth) -- 337
		fgDraw:drawEllipse( -- 338
			Vec2( -- 338
				scx - sf * cam:len(6), -- 338
				scy + 1 -- 338
			), -- 338
			cam:len(22), -- 338
			4.2, -- 338
			Color(10, 10, 12, 110) -- 338
		) -- 338
	end -- 338
	local backSlot = kMount < 0.45 and "child_crouch" or "child_peek" -- 342
	local tilt = -sf * (walking and 5.5 or 2.2) -- 343
	local childLayer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 344
	local placed = worldArt:tryPlace( -- 345
		backSlot, -- 345
		"carry_child", -- 345
		cx, -- 345
		cy, -- 345
		childW, -- 345
		childH, -- 345
		{facing = faceSign, angle = tilt, layer = childLayer} -- 345
	) -- 345
	if not placed then -- 345
		fgDraw:drawPolygon( -- 353
			{ -- 353
				Vec2(cx - childW * 0.4, cy + childH * 0.1), -- 354
				Vec2(cx + childW * 0.4, cy + childH * 0.1), -- 355
				Vec2(cx + childW * 0.3, cy + childH * 0.72), -- 356
				Vec2(cx - childW * 0.35, cy + childH * 0.72) -- 357
			}, -- 357
			CHILD_VEST, -- 358
			1, -- 358
			toColor(PALETTE.amberCore, 165) -- 358
		) -- 358
		fgDraw:drawCircle( -- 359
			Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), -- 359
			childW * 0.32, -- 359
			CHILD_SKIN -- 359
		) -- 359
	end -- 359
	local shoulderX = cam:sx(soldier.x + sf * 3) -- 363
	local shoulderY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth) -- 364
	local childShoulderX = cam:sx(childWX + sf * 5) -- 365
	local childShoulderY = cam:sy(childWY + 26, soldier.depth) -- 366
	local hipSupportX = cam:sx(soldier.x - sf * 10) -- 369
	local hipSupportY = cam:sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth) -- 370
	fgDraw:drawSegment( -- 371
		Vec2( -- 372
			cam:sx(soldier.x - sf * 2), -- 372
			cam:sy(soldier.y + 42 - crouchDip, soldier.depth) -- 372
		), -- 372
		Vec2(hipSupportX, hipSupportY), -- 373
		math.max( -- 374
			2.4, -- 374
			cam:len(2.8) -- 374
		), -- 374
		CUFF_CLOTH -- 375
	) -- 375
	fgDraw:drawSegment( -- 377
		Vec2(hipSupportX - sf * 2, hipSupportY + 1), -- 378
		Vec2(hipSupportX + sf * 3, hipSupportY + 1), -- 379
		1.2, -- 380
		CUFF_MEND -- 381
	) -- 381
	if self.reachT > 0.05 and kMount > 0.7 then -- 381
		local reachFrac = smoothStep(self.reachT) -- 386
		local elbowX = shoulderX + sf * cam:len(4 + reachFrac * 5) -- 387
		local elbowY = shoulderY + cam:len(1 + reachFrac * 3) -- 388
		local handEndX = elbowX + sf * cam:len(5 + reachFrac * 11) -- 389
		local handEndY = elbowY + cam:len(2 + reachFrac * 5) -- 390
		fgDraw:drawSegment( -- 391
			Vec2(childShoulderX, childShoulderY), -- 391
			Vec2(elbowX, elbowY), -- 391
			math.max( -- 391
				2, -- 391
				cam:len(2.1) -- 391
			), -- 391
			CHILD_SLEEVE -- 391
		) -- 391
		fgDraw:drawSegment( -- 392
			Vec2(elbowX, elbowY), -- 392
			Vec2( -- 392
				handEndX - sf * cam:len(3), -- 392
				handEndY - cam:len(1) -- 392
			), -- 392
			math.max( -- 392
				1.7, -- 392
				cam:len(1.8) -- 392
			), -- 392
			CHILD_SLEEVE -- 392
		) -- 392
		fgDraw:drawDot( -- 394
			Vec2( -- 394
				handEndX - sf * cam:len(3.2), -- 394
				handEndY - cam:len(0.8) -- 394
			), -- 394
			math.max( -- 394
				1.5, -- 394
				cam:len(1.2) -- 394
			), -- 394
			NEEDLE_CORD -- 394
		) -- 394
		fgDraw:drawCircle( -- 395
			Vec2(handEndX, handEndY), -- 395
			math.max( -- 395
				2.1, -- 395
				cam:len(1.8) -- 395
			), -- 395
			CHILD_SKIN -- 395
		) -- 395
		fgDraw:drawSegment( -- 396
			Vec2(handEndX, handEndY), -- 396
			Vec2( -- 396
				handEndX + sf * cam:len(3.5), -- 396
				handEndY + cam:len(1.2) -- 396
			), -- 396
			math.max( -- 396
				1.1, -- 396
				cam:len(1) -- 396
			), -- 396
			CHILD_SKIN -- 396
		) -- 396
		fillRadialGlow( -- 397
			fgGlow, -- 398
			handEndX + sf * cam:len(3), -- 399
			handEndY + cam:len(1), -- 400
			cam:len(7 * reachFrac), -- 401
			cam:len(7 * reachFrac), -- 402
			toColor(PALETTE.amberCore, 72 * reachFrac), -- 403
			Color(244, 234, 214, 0), -- 404
			10 -- 405
		) -- 405
	elseif kMount > 0.35 then -- 405
		local armAlpha = clamp01((kMount - 0.35) / 0.65) -- 408
		local gripX = shoulderX + sf * cam:len(4) -- 409
		local gripY = shoulderY - cam:len(2) -- 410
		fgDraw:drawSegment( -- 411
			Vec2(childShoulderX, childShoulderY), -- 412
			Vec2(gripX, gripY), -- 413
			math.max( -- 414
				1.8, -- 414
				cam:len(2) -- 414
			), -- 414
			Color( -- 415
				164, -- 415
				78, -- 415
				54, -- 415
				math.floor(255 * armAlpha + 0.5) -- 415
			) -- 415
		) -- 415
		fgDraw:drawDot( -- 417
			Vec2(gripX - sf * 2, gripY), -- 417
			math.max( -- 417
				1.5, -- 417
				cam:len(1.2) -- 417
			), -- 417
			Color( -- 417
				198, -- 417
				166, -- 417
				114, -- 417
				math.floor(235 * armAlpha + 0.5) -- 417
			) -- 417
		) -- 417
		fgDraw:drawCircle( -- 418
			Vec2(gripX, gripY), -- 418
			math.max( -- 418
				2, -- 418
				cam:len(1.7) -- 418
			), -- 418
			Color( -- 418
				236, -- 418
				210, -- 418
				182, -- 418
				math.floor(255 * armAlpha + 0.5) -- 418
			) -- 418
		) -- 418
	end -- 418
end -- 289
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 423
	local p = ctx.p -- 429
	local cam = ctx.cam -- 430
	local soldier = p.player -- 431
	local depthEnabled = p.room.depth ~= nil -- 432
	local f = soldier.facing >= 0 and 1 or -1 -- 433
	local dropK = smoothStep(self.benchDropT) -- 434
	local startX = soldier.x - f * 12 -- 437
	local startY = soldier.y + 26 -- 438
	local standX = soldier.x + f * 30 -- 439
	local standY = soldier.y -- 440
	local childWX = startX + (standX - startX) * dropK -- 441
	local childWY = startY + (standY - startY) * dropK -- 442
	self.childAnchorX = childWX -- 443
	self.childAnchorY = childWY -- 444
	local cx = cam:sx(childWX) -- 446
	local cy = cam:sy(childWY, soldier.depth) -- 447
	local cW = cam:len(22) -- 448
	local cH = cam:len(64) -- 449
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 451
	local slot = handing and "child_offer" or "child_idle" -- 452
	worldArt:tryPlace( -- 454
		slot, -- 454
		"carry_child_bench", -- 454
		cx, -- 454
		cy, -- 454
		cW, -- 454
		cH, -- 454
		{ -- 454
			facing = -f, -- 455
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 456
		} -- 456
	) -- 456
	fgDraw:drawEllipse( -- 458
		Vec2( -- 458
			cx, -- 458
			cam:sy(soldier.y, soldier.depth) + 1 -- 458
		), -- 458
		cW * 0.48 * dropK, -- 458
		3.2, -- 458
		Color(10, 10, 12, 130) -- 458
	) -- 458
	if handing then -- 458
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 462
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 463
		local midY = cam:sy( -- 464
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 464
			soldier.depth -- 464
		) -- 464
		local gunLen = cam:len(22) -- 465
		fgDraw:drawSegment( -- 466
			Vec2(midX - f * gunLen * 0.4, midY - 2), -- 466
			Vec2(midX + f * gunLen * 0.25, midY + 1), -- 466
			3.2, -- 466
			Color(108, 74, 52, 255) -- 466
		) -- 466
		fgDraw:drawSegment( -- 467
			Vec2(midX + f * gunLen * 0.1, midY + 1), -- 467
			Vec2(midX + f * gunLen * 0.65, midY + 3), -- 467
			1.8, -- 467
			Color(148, 144, 134, 245) -- 467
		) -- 467
		fillRadialGlow( -- 468
			fgGlow, -- 468
			midX, -- 468
			midY, -- 468
			cam:len(14), -- 468
			cam:len(10), -- 468
			toColor(PALETTE.amberCore, 72), -- 468
			Color(244, 234, 214, 0), -- 468
			10 -- 468
		) -- 468
	end -- 468
end -- 423
function ____exports.createCarryPosePlugin() -- 473
	return __TS__New(____exports.CarryPosePlugin) -- 474
end -- 473
return ____exports -- 473