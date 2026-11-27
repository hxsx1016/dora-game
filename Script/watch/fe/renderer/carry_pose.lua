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
end -- 40
function CarryPosePlugin.prototype.getPoseState(self) -- 54
	return { -- 55
		mode = self.mode, -- 56
		smoothedFacing = self.smoothedFacing, -- 57
		mountT = self.mountT, -- 58
		benchDropT = self.benchDropT, -- 59
		reachT = self.reachT, -- 60
		childAnchorX = self.childAnchorX, -- 61
		childAnchorY = self.childAnchorY, -- 62
		handoverActive = self.handoverActive -- 63
	} -- 63
end -- 54
function CarryPosePlugin.prototype.onBindPlay(self, p, view) -- 67
	self.animTime = 0 -- 68
	self.smoothedFacing = p.player.facing >= 0 and 1 or -1 -- 69
	self.mountT = view.backCarry.active and not view.backCarry.mounting and 1 or 0 -- 70
	self.benchDropT = view.backCarry.atBench and 1 or 0 -- 71
	self.reachT = 0 -- 72
	self.mode = self:resolveMode(view) -- 73
	self.childAnchorX = p.player.x -- 74
	self.childAnchorY = p.player.y -- 75
	self.handoverActive = false -- 76
	self.carryAudioRoomSession = -1 -- 77
end -- 67
function CarryPosePlugin.prototype.resolveMode(self, view) -- 80
	local bc = view.backCarry -- 81
	if bc.atBench or view.craftBench.active then -- 81
		return "atBench" -- 83
	end -- 83
	if bc.mounting then -- 83
		return "mounting" -- 86
	end -- 86
	if bc.active then -- 86
		return "carrying" -- 89
	end -- 89
	if bc.handInHand then -- 89
		return "handInHand" -- 92
	end -- 92
	return "none" -- 94
end -- 80
function CarryPosePlugin.prototype.update(self, ctx) -- 97
	local view = ctx.view -- 98
	local p = ctx.p -- 99
	self.mode = self:resolveMode(view) -- 100
	self.handoverActive = view.craftBench.justCraftedTimer > 0 -- 101
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 101
		return -- 104
	end -- 104
	if ctx.paused then -- 104
		return -- 107
	end -- 107
	local wdt = math.max(0, ctx.worldDt) -- 110
	local udt = math.max(0, ctx.uiDt) -- 111
	if wdt > 0 then -- 111
		self.animTime = self.animTime + wdt -- 114
		local targetF = p.player.facing >= 0 and 1 or -1 -- 117
		local turnK = math.min(1, wdt * 15) -- 118
		self.smoothedFacing = self.smoothedFacing + (targetF - self.smoothedFacing) * turnK -- 119
		if math.abs(targetF - self.smoothedFacing) < 0.005 then -- 119
			self.smoothedFacing = targetF -- 121
		end -- 121
		if self.mode == "mounting" then -- 121
			self.mountT = clamp01(self.mountT + wdt / 0.45) -- 126
		elseif self.mode == "carrying" then -- 126
			self.mountT = clamp01(self.mountT + wdt / 0.22) -- 128
		elseif self.mode == "handInHand" or self.mode == "none" then -- 128
			self.mountT = clamp01(self.mountT - wdt / 0.28) -- 130
		end -- 130
		local dropTarget = self.mode == "atBench" and 1 or 0 -- 134
		self.benchDropT = self.benchDropT + (dropTarget - self.benchDropT) * math.min(1, wdt * 11) -- 135
		if math.abs(dropTarget - self.benchDropT) < 0.005 then -- 135
			self.benchDropT = dropTarget -- 137
		end -- 137
	end -- 137
	if udt > 0 then -- 137
		local reachTarget = view.reloadSession.active and 1 or 0 -- 143
		local speed = view.reloadSession.active and (view.reloadSession.firstTime and 4.4 or 9.2) or 5.5 -- 144
		self.reachT = self.reachT + (reachTarget - self.reachT) * math.min(1, udt * speed) -- 147
		if math.abs(reachTarget - self.reachT) < 0.005 then -- 147
			self.reachT = reachTarget -- 149
		end -- 149
	end -- 149
	if (self.mode == "mounting" or self.mode == "carrying") and self.carryAudioRoomSession ~= ctx.events.roomSessionId then -- 149
		local hasBackendEvent = false -- 156
		local i = 0 -- 157
		do -- 157
			i = 0 -- 158
			while i < #ctx.events.rawEvents do -- 158
				if ctx.events.rawEvents[i + 1].name == "carryStart" then -- 158
					hasBackendEvent = true -- 160
					break -- 161
				end -- 161
				i = i + 1 -- 158
			end -- 158
		end -- 158
		self.carryAudioRoomSession = ctx.events.roomSessionId -- 164
		if not hasBackendEvent then -- 164
			ctx.audio:playOnce( -- 166
				"fe02:carry_start:r" .. tostring(ctx.events.roomSessionId), -- 167
				"sfx", -- 168
				"assets/audio/combat/carry_start.wav", -- 169
				0.82, -- 170
				"combat:carry_start", -- 171
				p.ticks -- 172
			) -- 172
		end -- 172
	end -- 172
end -- 97
function CarryPosePlugin.prototype.drawPartyPose(self, fgDraw, fgGlow, worldArt, ctx) -- 178
	local view = ctx.view -- 184
	local p = ctx.p -- 185
	if view.visualMode ~= "pixel" or p.childMode or not p.player.alive then -- 185
		return -- 187
	end -- 187
	if self.mode == "none" and self.mountT <= 0.01 and self.benchDropT <= 0.01 then -- 187
		return -- 190
	end -- 190
	if self.mode == "handInHand" then -- 190
		return self:drawHandInHand(fgDraw, fgGlow, worldArt, ctx) -- 194
	end -- 194
	if self.mode == "atBench" or self.benchDropT > 0.5 then -- 194
		return { -- 198
			player = false, -- 198
			partner = self:drawAtBench(fgDraw, fgGlow, worldArt, ctx) -- 198
		} -- 198
	end -- 198
	return self:drawCarriedOrMounting(fgGlow, worldArt, ctx) -- 201
end -- 178
function CarryPosePlugin.prototype.drawHandInHand(self, fgDraw, fgGlow, worldArt, ctx) -- 205
	local p = ctx.p -- 211
	local cam = ctx.cam -- 212
	local soldier = p.player -- 213
	local partner = p.partner -- 214
	local depthEnabled = p.room.depth ~= nil -- 215
	local f = soldier.facing >= 0 and 1 or -1 -- 216
	local speed = math.max( -- 217
		math.abs(soldier.vx), -- 217
		math.abs(soldier.depthSpeed) -- 217
	) -- 217
	local nearPartner = partner.alive and math.abs(partner.x - soldier.x) <= 56 and math.abs(partner.y - soldier.y) <= 24 -- 220
	local childWX = partner.x -- 221
	local childWY = partner.y -- 222
	local childDepth = partner.depth -- 223
	local partnerPlaced = false -- 225
	if not nearPartner then -- 225
		local lag = speed > 8 and math.sin(self.animTime * 13.5) * 2.4 or 0 -- 228
		childWX = soldier.x - f * 26 + lag -- 229
		childWY = soldier.y -- 230
		childDepth = soldier.depth -- 231
		local childStep = math.floor(self.animTime * 13) -- 233
		local slot = speed > 8 and "child_run" or "child_idle" -- 234
		local scx = cam:sx(childWX) -- 235
		local scy = cam:sy(childWY, childDepth) -- 236
		local cW = cam:len(22) -- 237
		local cH = cam:len(64) -- 238
		partnerPlaced = worldArt:tryPlace( -- 239
			slot, -- 239
			"carry_child_walk", -- 239
			scx, -- 239
			scy, -- 239
			cW, -- 239
			cH, -- 239
			{ -- 239
				facing = f, -- 240
				frame = speed > 8 and childStep or 0, -- 241
				layer = depthEnabled and depthOrder(childDepth, 4) or 4 -- 242
			} -- 242
		) -- 242
		fgDraw:drawEllipse( -- 244
			Vec2(scx, scy + 1), -- 244
			cW * 0.46, -- 244
			3.2, -- 244
			Color(10, 10, 12, 130) -- 244
		) -- 244
	end -- 244
	self.childAnchorX = childWX -- 247
	self.childAnchorY = childWY -- 248
	local playerPlaced = false -- 251
	if speed <= 8 and soldier.rollT <= 0 then -- 251
		playerPlaced = worldArt:tryPlace( -- 253
			"fe_soldier_hand_hold", -- 254
			"carry_soldier_hold", -- 255
			cam:sx(soldier.x), -- 256
			cam:sy(soldier.y, soldier.depth), -- 257
			cam:len(36), -- 258
			cam:len(soldier.h), -- 259
			{ -- 260
				facing = f, -- 261
				layer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 262
			} -- 262
		) -- 262
	end -- 262
	local sHandX = cam:sx(soldier.x - f * 8) -- 266
	local sHandY = cam:sy(soldier.y + soldier.h * 0.46, soldier.depth) -- 267
	local cHandX = cam:sx(childWX + f * 7) -- 268
	local cHandY = cam:sy(childWY + 36, childDepth) -- 269
	local claspX = (sHandX + cHandX) * 0.5 -- 270
	local claspY = (sHandY + cHandY) * 0.5 -- 271
	fillRadialGlow( -- 272
		fgGlow, -- 272
		claspX, -- 272
		claspY, -- 272
		cam:len(10), -- 272
		cam:len(8), -- 272
		toColor(PALETTE.amberCore, 76), -- 272
		Color(244, 234, 214, 0), -- 272
		10 -- 272
	) -- 272
	return {player = playerPlaced, partner = partnerPlaced} -- 273
end -- 205
function CarryPosePlugin.prototype.drawCarriedOrMounting(self, fgGlow, worldArt, ctx) -- 277
	local p = ctx.p -- 282
	local cam = ctx.cam -- 283
	local soldier = p.player -- 284
	local depthEnabled = p.room.depth ~= nil -- 285
	local sf = self.smoothedFacing -- 286
	local faceSign = sf >= 0 and 1 or -1 -- 287
	local speed = math.max( -- 288
		math.abs(soldier.vx), -- 288
		math.abs(soldier.depthSpeed) -- 288
	) -- 288
	local kMount = self.mode == "mounting" and smoothStep(self.mountT) or 1 -- 291
	local crouchDip = self.mode == "mounting" and math.sin(kMount * math.pi) * 14 or ((soldier.covered or p.coverHug) and 10 or (soldier.rollT > 0 and 18 or 0)) -- 292
	local walking = speed > 8 and soldier.onGround -- 296
	local bob = walking and math.abs(math.sin(self.animTime * 10.5)) * 2 or math.sin(self.animTime * 2.5) * 0.8 -- 297
	local targetBackX = soldier.x - sf * 13 -- 302
	local targetBackY = soldier.y + 30 - crouchDip + bob -- 303
	local startGroundX = soldier.x - sf * 24 -- 304
	local startGroundY = soldier.y -- 305
	local arcLift = self.mode == "mounting" and math.sin(kMount * math.pi) * 8 or 0 -- 306
	local childWX = startGroundX + (targetBackX - startGroundX) * kMount -- 308
	local childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift -- 309
	self.childAnchorX = childWX -- 310
	self.childAnchorY = childWY -- 311
	local scx = cam:sx(soldier.x) -- 313
	local scy = cam:sy(soldier.y, soldier.depth) -- 314
	local baseLayer = depthEnabled and depthOrder(soldier.depth, 4) or 4 -- 315
	if self.mode == "mounting" and kMount < 0.72 then -- 315
		local playerPlaced = worldArt:tryPlace( -- 319
			"fe_soldier_kneel_mount", -- 319
			"carry_soldier_kneel", -- 319
			scx, -- 319
			scy, -- 319
			cam:len(42), -- 319
			cam:len(soldier.h * 0.9), -- 319
			{facing = faceSign, layer = baseLayer} -- 319
		) -- 319
		local cx = cam:sx(childWX) -- 323
		local cy = cam:sy(childWY, soldier.depth) -- 324
		local partnerPlaced = worldArt:tryPlace( -- 325
			kMount < 0.45 and "child_crouch" or "child_peek", -- 325
			"carry_child", -- 325
			cx, -- 325
			cy, -- 325
			cam:len(22), -- 325
			cam:len(42 + (1 - kMount) * 18), -- 325
			{facing = faceSign, layer = baseLayer + 1} -- 325
		) -- 325
		return {player = playerPlaced, partner = partnerPlaced} -- 329
	end -- 329
	if soldier.rollT <= 0 then -- 329
		local carrySlot = self.reachT > 0.08 and "fe_carry_reload" or (walking and "fe_carry_walk" or "fe_carry_idle") -- 334
		local frame = carrySlot == "fe_carry_walk" and math.floor(self.animTime * 10) or 0 -- 337
		local carryH = cam:len(soldier.h * (crouchDip > 4 and 0.88 or 1.04)) -- 338
		if worldArt:tryPlace( -- 338
			carrySlot, -- 339
			"carry_pair_sprite", -- 339
			scx, -- 339
			scy, -- 339
			cam:len(48), -- 339
			carryH, -- 339
			{facing = faceSign, frame = frame, layer = baseLayer} -- 339
		) then -- 339
			if self.reachT > 0.12 then -- 339
				local reachFrac = smoothStep(self.reachT) -- 345
				local handGlowX = cam:sx(soldier.x + sf * (14 + reachFrac * 10)) -- 346
				local handGlowY = cam:sy(soldier.y + soldier.h * 0.72 - crouchDip, soldier.depth) -- 347
				fillRadialGlow( -- 348
					fgGlow, -- 348
					handGlowX, -- 348
					handGlowY, -- 348
					cam:len(9 * reachFrac), -- 348
					cam:len(9 * reachFrac), -- 348
					toColor(PALETTE.amberCore, 72 * reachFrac), -- 348
					Color(244, 234, 214, 0), -- 348
					10 -- 348
				) -- 348
			end -- 348
			return {player = true, partner = true} -- 350
		end -- 350
	end -- 350
	local cx = cam:sx(childWX) -- 355
	local cy = cam:sy(childWY, soldier.depth) -- 356
	local partnerPlaced = worldArt:tryPlace( -- 357
		"child_peek", -- 357
		"carry_child", -- 357
		cx, -- 357
		cy, -- 357
		cam:len(22), -- 357
		cam:len(40), -- 357
		{ -- 357
			facing = faceSign, -- 358
			layer = depthEnabled and depthOrder(soldier.depth, 3) or 3 -- 359
		} -- 359
	) -- 359
	return {player = false, partner = partnerPlaced} -- 361
end -- 277
function CarryPosePlugin.prototype.drawAtBench(self, fgDraw, fgGlow, worldArt, ctx) -- 365
	local p = ctx.p -- 371
	local cam = ctx.cam -- 372
	local soldier = p.player -- 373
	local depthEnabled = p.room.depth ~= nil -- 374
	local f = soldier.facing >= 0 and 1 or -1 -- 375
	local dropK = smoothStep(self.benchDropT) -- 376
	local startX = soldier.x - f * 12 -- 379
	local startY = soldier.y + 26 -- 380
	local standX = soldier.x + f * 30 -- 381
	local standY = soldier.y -- 382
	local childWX = startX + (standX - startX) * dropK -- 383
	local childWY = startY + (standY - startY) * dropK -- 384
	self.childAnchorX = childWX -- 385
	self.childAnchorY = childWY -- 386
	local cx = cam:sx(childWX) -- 388
	local cy = cam:sy(childWY, soldier.depth) -- 389
	local cW = cam:len(22) -- 390
	local cH = cam:len(64) -- 391
	local handing = ctx.view.craftBench.justCraftedTimer > 0 -- 393
	local slot = handing and "child_offer" or "child_idle" -- 394
	local partnerPlaced = worldArt:tryPlace( -- 395
		slot, -- 395
		"carry_child_bench", -- 395
		cx, -- 395
		cy, -- 395
		cW, -- 395
		cH, -- 395
		{ -- 395
			facing = -f, -- 396
			layer = depthEnabled and depthOrder(soldier.depth, 5) or 5 -- 397
		} -- 397
	) -- 397
	fgDraw:drawEllipse( -- 399
		Vec2( -- 399
			cx, -- 399
			cam:sy(soldier.y, soldier.depth) + 1 -- 399
		), -- 399
		cW * 0.48 * dropK, -- 399
		3.2, -- 399
		Color(10, 10, 12, 130) -- 399
	) -- 399
	if handing then -- 399
		local prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer) -- 403
		local midX = cam:sx(soldier.x + f * (22 - prog * 10)) -- 404
		local midY = cam:sy( -- 405
			soldier.y + 44 + math.sin(prog * math.pi) * 5, -- 405
			soldier.depth -- 405
		) -- 405
		local isEcho = (string.find(ctx.view.craftBench.equippedWeapon, "echo", nil, true) or 0) - 1 >= 0 -- 406
		worldArt:tryPlace( -- 407
			isEcho and "fe_weapon_echo_gun" or "fe_weapon_lantern_gun", -- 407
			"carry_bench_gun", -- 407
			midX, -- 407
			midY, -- 407
			cam:len(34), -- 407
			cam:len(16), -- 407
			{ -- 407
				facing = f, -- 408
				layer = depthEnabled and depthOrder(soldier.depth, 6) or 6 -- 409
			} -- 409
		) -- 409
		fillRadialGlow( -- 411
			fgGlow, -- 411
			midX, -- 411
			midY, -- 411
			cam:len(15), -- 411
			cam:len(11), -- 411
			toColor(PALETTE.amberCore, 72), -- 411
			Color(244, 234, 214, 0), -- 411
			10 -- 411
		) -- 411
	end -- 411
	return partnerPlaced -- 413
end -- 365
function ____exports.createCarryPosePlugin() -- 417
	return __TS__New(____exports.CarryPosePlugin) -- 418
end -- 417
return ____exports -- 417