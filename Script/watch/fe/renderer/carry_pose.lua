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
--- 原生 actors.ts 在护送/背负模式下可能激活的 actor_child / actor_soldier 精灵帧（原地压隐防重影）
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
local SOLDIER_SPRITE_PATHS = { -- 46
	"assets/art/sprites.clip|soldier_idle", -- 47
	"assets/art/sprites.clip|soldier_run", -- 48
	"assets/art/sprites.clip|soldier_step", -- 49
	"assets/art/sprites.clip|soldier_cover", -- 50
	"assets/art/sprites.clip|soldier_hold", -- 51
	"assets/art/sprites.clip|soldier_offer" -- 52
} -- 52
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
local function suppressOriginalSoldier(worldArt) -- 79
	local i = 0 -- 80
	do -- 80
		i = 0 -- 81
		while i < #SOLDIER_SPRITE_PATHS do -- 81
			worldArt:tryPlacePath( -- 82
				SOLDIER_SPRITE_PATHS[i + 1], -- 83
				"actor_soldier", -- 84
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
____exports.CarryPosePlugin = __TS__Class() -- 94
local CarryPosePlugin = ____exports.CarryPosePlugin -- 94
CarryPosePlugin.name = "CarryPosePlugin" -- 94
function CarryPosePlugin.prototype.____constructor(self) -- 94
	self.id = "fe-02-carry-pose" -- 95
	self.animTime = 0 -- 97
	self.smoothedFacing = 1 -- 98
	self.mountT = 0 -- 99
	self.benchDropT = 0 -- 100
	self.reachT = 0 -- 101
	self.mode = "none" -- 102
	self.childAnchorX = 0 -- 103
	self.childAnchorY = 0 -- 104
	self.handoverActive = false -- 105
	self.carryAudioRoomSession = -1 -- 106
end -- 94
function CarryPosePlugin.prototype.getPoseState(self) -- 108
	return { -- 109
		mode = self.mode, -- 110
		smoothedFacing = self.smoothedFacing, -- 111
		mountT = self.mountT, -- 112
		benchDropT = self.benchDropT, -- 113
		reachT = self.reachT, -- 114
		childAnchorX = self.childAnchorX, -- 115
		childAnchorY = self.childAnchorY, -- 116
		handoverActive = self.handoverActive -- 117
	} -- 117
end -- 108
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 121
	self.animTime = 0 -- 122
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 123
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 124
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 125
	self.reachT = 0 -- 126
	self.mode = self:resolveMode(view) -- 127
	self.childAnchorX = p.player.x -- 128
	self.childAnchorY = p.player.y -- 129
	self.handoverActive = false -- 130
	self.carryAudioRoomSession = -1 -- 131
end -- 121
function CarryPosePlugin.prototype.resolveMode(self, view) -- 134
	local bc = view.backCarry -- 135
	if bc.atBench or view.craftBench.active then -- 135
		return "atBench" -- 137
	end -- 137
	if bc.mounting then -- 137
		return "mounting" -- 140
	end -- 140
	if bc.active then -- 140
		return "carrying" -- 143
	end -- 143
	if bc.handInHand then -- 143
		return "handInHand" -- 146
	end -- 146
	return "none" -- 148
end -- 134
function CarryPosePlugin.prototype.update(self, ctx) -- 151
	local view = ctx.view -- 152
	local p = ctx.p -- 153
	self.mode = self:resolveMode(view) -- 154
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 155
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 155
		return -- 158
	end -- 158
	if ctx.paused then -- 158
		return -- 161
	end -- 161
	local wdt = math.max(0, ctx.worldDt) -- 164
	local udt = math.max(0, ctx.uiDt) -- 165
	if wdt > 0 then -- 165
		self.animTime = self.animTime + wdt -- 168
		local targetF = p.player.facing >= 0 and 1 or -1 -- 171
		local turnK = math.min(1, wdt * 15) -- 172
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 173
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 173
			self.smoothedFacing = targetF -- 175
		end -- 175
		if self.mode == "mounting" then -- 175
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 180
		elseif self.mode == "carrying" then -- 180
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 182
		elseif self.mode == "handInHand" or self.mode == "none" then -- 182
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 184
		end -- 184
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 188
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 189
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 189
			self.benchDropT = dropTarget -- 191
		end -- 191
	end -- 191
	if udt > 0 then -- 191
		local reachTarget = view.reloadSession.active and 1 or 0 -- 197
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 198
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 201
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 201
			self.reachT = reachTarget -- 203
		end -- 203
	end -- 203
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 203
		local hasBackendEvent = false -- 210
		local i = 0 -- 211
		do -- 211
			i = 0 -- 212
			while i < #ctx.events.rawEvents do -- 212
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 212
					hasBackendEvent = true -- 214
					break -- 215
				end -- 215
				i = i + 1 -- 212
			end -- 212
		end -- 212
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 218
		if not hasBackendEvent then -- 218
			ctx.audio:playOnce( -- 220
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 221
				"sfx", -- 222
				"assets/audio/combat/carry_start.wav", -- 223
				0.82, -- 224
				"combat:carry_start", -- 225
				p.ticks -- 226
			) -- 226
		end -- 226
	end -- 226
end -- 151
function CarryPosePlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 232
	local view = ctx.view -- 238
	local p = ctx.p -- 239
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 239
		return -- 241
	end -- 241
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 241
		return -- 244
	end -- 244
	if self.mode == "handInHand" then -- 244
		self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 248
		return -- 249
	end -- 249
	suppressOriginalChild(worldArt) -- 253
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 253
		self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 256
		return -- 257
	end -- 257
	self:drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx) -- 260
end -- 232
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 264
	local p = ctx.p -- 270
	local cam = ctx.cam -- 271
	local soldier = p.player -- 272
	local partner = p.partner -- 273
	local depthEnabled = p.room.depth ~= nil -- 274
	local f = soldier.facing >= 0 and 1 or -1 -- 275
	local speed = math.max( -- 276
		math.abs(soldier.vx), -- 276
		math.abs(soldier.depthSpeed) -- 276
	) -- 276
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 279
	local childWX = partner.x -- 280
	local childWY = partner.y -- 281
	local childDepth = partner.depth -- 282
	if not nearPartner then -- 282
		suppressOriginalChild(worldArt) -- 285
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 287
		childWX = soldier.x - f * 26 + lag -- 288
		childWY = soldier.y -- 289
		childDepth = soldier.depth -- 290
		local childStep = math.floor(self.animTime * 13) -- 292
		local slot = speed > 8 and "child_run" or "child_idle" -- 293
		local scx = cam:sx(childWX) -- 294
		local scy = cam:sy(childWY, childDepth) -- 295
		local cW = cam:len(22) -- 296
		local cH = cam:len(64) -- 297
		worldArt:tryPlace( -- 298
			slot, -- 298
			"carry_child_walk", -- 298
			scx, -- 298
			scy, -- 298
			cW, -- 298
			cH, -- 298
			{ -- 298
				facing = f, -- 299
				frame = speed > 8 and childStep or 0, -- 300
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 301
			} -- 301
		) -- 301
		fgDraw:drawEllipse( -- 303
			Vec2(scx, scy + 1), -- 303
			cW * 0.46, -- 303
			3.2, -- 303
			Color(10, 10, 12, 130) -- 303
		) -- 303
	end -- 303
	self.childAnchorX = childWX -- 306
	self.childAnchorY = childWY -- 307
	if speed <= 8 and soldier.rollT <= 0 then -- 307
		suppressOriginalSoldier(worldArt) -- 311
		worldArt:tryPlace( -- 312
			"fe_soldier_hand_hold", -- 313
			"carry_soldier_hold", -- 314
			cam:sx(soldier.x), -- 315
			cam:sy(soldier.y, soldier.depth), -- 316
			cam:len(36), -- 317
			cam:len(soldier.h), -- 318
			{ -- 319
				facing = f, -- 320
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 321
			} -- 321
		) -- 321
	end -- 321
	local sHandX = cam:sx(soldier.x - f * 8) -- 325
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 326
	local cHandX = cam:sx(childWX + f * 7) -- 327
	local cHandY = cam:sy(childWY + 36, childDepth) -- 328
	local claspX = (sHandX + cHandX) * 0.5 -- 329
	local claspY = (sHandY + cHandY) * 0.5 -- 330
	fillRadialGlow( -- 331
		fgGlow, -- 331
		claspX, -- 331
		claspY, -- 331
		cam:len(10), -- 331
		cam:len(8), -- 331
		toColor(PALETTE.amberCore, 76), -- 331
		Color(244, 234, 214, 0), -- 331
		10 -- 331
	) -- 331
end -- 264
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgDraw, fgGlow, worldArt, ctx) -- 335
	local p = ctx.p -- 341
	local cam = ctx.cam -- 342
	local soldier = p.player -- 343
	local depthEnabled = p.room.depth ~= nil -- 344
	local sf = self.smoothedFacing -- 345
	local faceSign = sf >= 0 and 1 or -1 -- 346
	local speed = math.max( -- 347
		math.abs(soldier.vx), -- 347
		math.abs(soldier.depthSpeed) -- 347
	) -- 347
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 350
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 351
	local walking = speed > 8 and soldier.onGround -- 355
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 356
	local targetBackX = soldier.x - sf * 13 -- 361
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 362
	local startGroundX = soldier.x - sf * 24 -- 363
	local startGroundY = soldier.y -- 364
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 365
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 367
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 368
	self.childAnchorX = childWX -- 369
	self.childAnchorY = childWY -- 370
	local scx = cam:sx(soldier.x) -- 372
	local scy = cam:sy(soldier.y, soldier.depth) -- 373
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 374
	if self.mode == "mounting" and kMount < 0.72 then -- 374
		suppressOriginalSoldier(worldArt) -- 378
		fgDraw:drawEllipse( -- 379
			Vec2( -- 379
				scx - sf * cam:len(4), -- 379
				scy + 1 -- 379
			), -- 379
			cam:len(22), -- 379
			4, -- 379
			Color(10, 10, 12, 118) -- 379
		) -- 379
		worldArt:tryPlace( -- 380
			"fe_soldier_kneel_mount", -- 380
			"carry_soldier_kneel", -- 380
			scx, -- 380
			scy, -- 380
			cam:len(42), -- 380
			cam:len(soldier.h * 0.9), -- 380
			{facing = faceSign, layer = baseLayer} -- 380
		) -- 380
		local cx = cam:sx(childWX) -- 384
		local cy = cam:sy(childWY, soldier.depth) -- 385
		worldArt:tryPlace( -- 386
			kMount < 0.45 and "child_crouch" or "child_peek", -- 386
			"carry_child", -- 386
			cx, -- 386
			cy, -- 386
			cam:len(22), -- 386
			cam:len(42 + (1 - kMount) * 18), -- 386
			{facing = faceSign, layer = baseLayer + 1} -- 386
		) -- 386
		return -- 390
	end -- 390
	if soldier.rollT <= 0 then -- 390
		local carrySlot = self.reachT > 0.08 and "fe_carry_reload" or (walking and "fe_carry_walk" or "fe_carry_idle") -- 395
		local frame = carrySlot == "fe_carry_walk" and math.floor(self.animTime * 10) or 0 -- 398
		local carryH = cam:len(soldier.h * (crouchDip > 4 and 0.88 or 1.04)) -- 399
		if worldArt:tryPlace( -- 399
			carrySlot, -- 400
			"carry_pair_sprite", -- 400
			scx, -- 400
			scy, -- 400
			cam:len(48), -- 400
			carryH, -- 400
			{facing = faceSign, frame = frame, layer = baseLayer} -- 400
		) then -- 400
			suppressOriginalSoldier(worldArt) -- 405
			if self.reachT > 0.12 then -- 405
				local reachFrac = smoothStep(self.reachT) -- 407
				local handGlowX = cam:sx(soldier.x + sf * (14 + reachFrac * 10)) -- 408
				local handGlowY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip, soldier.depth) -- 409
				fillRadialGlow( -- 410
					fgGlow, -- 410
					handGlowX, -- 410
					handGlowY, -- 410
					cam:len(9 * reachFrac), -- 410
					cam:len(9 * reachFrac), -- 410
					toColor(PALETTE.amberCore, 72 * reachFrac), -- 410
					Color(244, 234, 214, 0), -- 410
					10 -- 410
				) -- 410
			end -- 410
			return -- 412
		end -- 412
	end -- 412
	local cx = cam:sx(childWX) -- 417
	local cy = cam:sy(childWY, soldier.depth) -- 418
	worldArt:tryPlace( -- 419
		"child_peek", -- 419
		"carry_child", -- 419
		cx, -- 419
		cy, -- 419
		cam:len(22), -- 419
		cam:len(40), -- 419
		{ -- 419
			facing = faceSign, -- 420
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 421
		} -- 421
	) -- 421
end -- 335
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 426
	local p = ctx.p -- 432
	local cam = ctx.cam -- 433
	local soldier = p.player -- 434
	local depthEnabled = p.room.depth ~= nil -- 435
	local f = soldier.facing >= 0 and 1 or -1 -- 436
	local dropK = smoothStep(self.benchDropT) -- 437
	local startX = soldier.x - f * 12 -- 440
	local startY = soldier.y + 26 -- 441
	local standX = soldier.x + f * 30 -- 442
	local standY = soldier.y -- 443
	local childWX = startX + (standX - startX) * dropK -- 444
	local childWY = startY + (standY - startY) * dropK -- 445
	self.childAnchorX = childWX -- 446
	self.childAnchorY = childWY -- 447
	local cx = cam:sx(childWX) -- 449
	local cy = cam:sy(childWY, soldier.depth) -- 450
	local cW = cam:len(22) -- 451
	local cH = cam:len(64) -- 452
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 454
	local slot = handing and "child_offer" or "child_idle" -- 455
	worldArt:tryPlace( -- 456
		slot, -- 456
		"carry_child_bench", -- 456
		cx, -- 456
		cy, -- 456
		cW, -- 456
		cH, -- 456
		{ -- 456
			facing = -f, -- 457
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 458
		} -- 458
	) -- 458
	fgDraw:drawEllipse( -- 460
		Vec2( -- 460
			cx, -- 460
			cam:sy(soldier.y, soldier.depth) + 1 -- 460
		), -- 460
		cW * 0.48 * dropK, -- 460
		3.2, -- 460
		Color(10, 10, 12, 130) -- 460
	) -- 460
	if handing then -- 460
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 464
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 465
		local midY = cam:sy( -- 466
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 466
			soldier.depth -- 466
		) -- 466
		local isEcho = (string.find(ctx.view.craftBench.equippedWeapon, "echo", nil, true) or 0) - 1 >= 0 -- 467
		worldArt:tryPlace( -- 468
			isEcho and "fe_weapon_echo_gun" or "fe_weapon_lantern_gun", -- 468
			"carry_bench_gun", -- 468
			midX, -- 468
			midY, -- 468
			cam:len(34), -- 468
			cam:len(16), -- 468
			{ -- 468
				facing = f, -- 469
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 470
			} -- 470
		) -- 470
		fillRadialGlow( -- 472
			fgGlow, -- 472
			midX, -- 472
			midY, -- 472
			cam:len(15), -- 472
			cam:len(11), -- 472
			toColor(PALETTE.amberCore, 72), -- 472
			Color(244, 234, 214, 0), -- 472
			10 -- 472
		) -- 472
	end -- 472
end -- 426
function ____exports.createCarryPosePlugin() -- 477
	return __TS__New(____exports.CarryPosePlugin) -- 478
end -- 477
return ____exports -- 477