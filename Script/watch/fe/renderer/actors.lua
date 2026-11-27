-- [ts]: actors.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____play = require("Script.watch.play") -- 4
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 4
local ____clock = require("Script.watch.clock") -- 5
local STEP = ____clock.STEP -- 5
local ____escort = require("Script.watch.escort") -- 6
local FEAR_MAX = ____escort.FEAR_MAX -- 6
local ____depth = require("Script.watch.depth") -- 7
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 7
local overlapsDepth = ____depth.overlapsDepth -- 7
local ____occlusion = require("Script.watch.fe.occlusion") -- 8
local depthOrder = ____occlusion.depthOrder -- 8
local ____theme = require("Script.watch.fe.theme") -- 11
local PALETTE = ____theme.PALETTE -- 11
local drawDiamond = ____theme.drawDiamond -- 11
local fillRadialGlow = ____theme.fillRadialGlow -- 11
local toColor = ____theme.toColor -- 11
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 12
local smoothstep = ____lowpoly.smoothstep -- 12
local function strideAt(actor) -- 34
	return { -- 35
		actor = actor, -- 35
		x = actor.x, -- 35
		depth = actor.depth, -- 35
		speed = 0, -- 35
		cycle = 0, -- 35
		effort = 0 -- 35
	} -- 35
end -- 34
local RUN_START_T = 0.1 -- 38
local RUN_STOP_T = 0.13 -- 39
local function advanceStride(stride, steps, dt) -- 41
	local a = stride.actor -- 42
	if steps > 0 then -- 42
		local dx = a.x - stride.x -- 44
		local depth = a.depth - stride.depth -- 45
		local speed = math.sqrt(dx * dx + depth * depth) / (steps * STEP) -- 46
		stride.speed = speed <= 380 and speed or 0 -- 47
		stride.x = a.x -- 48
		stride.depth = a.depth -- 49
	end -- 49
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 49
		stride.effort = 0 -- 52
		return -- 53
	end -- 53
	if stride.speed > 8 then -- 53
		stride.effort = math.min(1, stride.effort + dt / RUN_START_T) -- 56
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 57
		stride.cycle = (stride.cycle + stride.speed * dt / strideLength) % 1 -- 58
	else -- 58
		stride.effort = math.max(0, stride.effort - dt / RUN_STOP_T) -- 60
	end -- 60
end -- 41
____exports.ActorsRenderer = __TS__Class() -- 64
local ActorsRenderer = ____exports.ActorsRenderer -- 64
ActorsRenderer.name = "ActorsRenderer" -- 64
function ActorsRenderer.prototype.____constructor(self) -- 64
	self.ghosts = {} -- 65
	self.ghostCooldown = 0 -- 66
	self.animTime = 0 -- 67
	self.strideTick = 0 -- 68
	self.previousHp = 3 -- 71
	self.previousAxle = 0 -- 72
	self.cartMoving = false -- 73
	self.previousBottle = false -- 74
	self.hitUntil = -1 -- 76
	self.throwUntil = -1 -- 77
	self.shotUntil = -1 -- 78
end -- 64
function ActorsRenderer.prototype.reset(self, p) -- 80
	self.ghosts = {} -- 81
	self.ghostCooldown = 0 -- 82
	self.animTime = 0 -- 83
	self.strideTick = p.ticks -- 84
	self.playerStride = strideAt(p.player) -- 85
	self.partnerStride = strideAt(p.partner) -- 86
	self.previousHp = p.hp -- 87
	self.previousAxle = p.cartAxle -- 88
	self.cartMoving = false -- 89
	self.previousBottle = p.hasBottle -- 90
	self.previousTrace = p.trace -- 91
	self.hitUntil = -1 -- 92
	self.throwUntil = -1 -- 93
	self.shotUntil = -1 -- 94
end -- 80
function ActorsRenderer.prototype.update(self, dt, p) -- 98
	self.animTime = self.animTime + dt -- 99
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 99
		self.hitUntil = p.ticks + 14 -- 101
	end -- 101
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 101
		self.throwUntil = p.ticks + 12 -- 104
	end -- 104
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 104
		self.shotUntil = p.ticks + 7 -- 107
	end -- 107
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 109
	self.previousAxle = p.cartAxle -- 110
	self.previousHp = p.hp -- 111
	self.previousBottle = p.hasBottle -- 112
	self.previousTrace = p.trace -- 113
	local ____opt_0 = self.playerStride -- 113
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 113
		self.playerStride = strideAt(p.player) -- 115
	end -- 115
	local ____opt_2 = self.partnerStride -- 115
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 115
		self.partnerStride = strideAt(p.partner) -- 118
	end -- 118
	local steps = math.max(0, p.ticks - self.strideTick) -- 120
	advanceStride(self.playerStride, steps, dt) -- 121
	advanceStride(self.partnerStride, steps, dt) -- 122
	self.strideTick = p.ticks -- 123
	if not p.childMode and p.player.rollT > 0 then -- 123
		self.ghostCooldown = self.ghostCooldown - dt -- 126
		if self.ghostCooldown <= 0 then -- 126
			local ____self_ghosts_4 = self.ghosts -- 126
			____self_ghosts_4[#____self_ghosts_4 + 1] = { -- 128
				x = p.player.x, -- 129
				y = p.player.y, -- 130
				depth = p.player.depth, -- 131
				h = p.player.h, -- 132
				facing = p.player.facing, -- 133
				life = 0.28, -- 134
				maxLife = 0.28, -- 135
				isRoll = true -- 136
			} -- 136
			self.ghostCooldown = 0.036 -- 138
		end -- 138
	else -- 138
		self.ghostCooldown = 0 -- 141
	end -- 141
	local write = 0 -- 145
	local i = 0 -- 146
	do -- 146
		i = 0 -- 147
		while i < #self.ghosts do -- 147
			local g = self.ghosts[i + 1] -- 148
			g.life = g.life - dt -- 149
			if g.life > 0 then -- 149
				self.ghosts[write + 1] = g -- 151
				write = write + 1 -- 152
			end -- 152
			i = i + 1 -- 147
		end -- 147
	end -- 147
	__TS__ArraySetLength(self.ghosts, write) -- 147
end -- 98
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 158
	if suppressPartner == nil then -- 158
		suppressPartner = false -- 164
	end -- 164
	self:drawAfterimages(fgGlow, cam) -- 167
	local i = 0 -- 170
	do -- 170
		i = 0 -- 171
		while i < #p.enemies do -- 171
			self:drawEnemy( -- 172
				fgDraw, -- 172
				fgGlow, -- 172
				assets, -- 172
				p.enemies[i + 1], -- 172
				i, -- 172
				p, -- 172
				cam -- 172
			) -- 172
			i = i + 1 -- 171
		end -- 171
	end -- 171
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 171
		self:drawScavenger( -- 177
			fgDraw, -- 177
			fgGlow, -- 177
			assets, -- 177
			p, -- 177
			cam -- 177
		) -- 177
	end -- 177
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 177
		self:drawDog( -- 182
			fgDraw, -- 182
			fgGlow, -- 182
			assets, -- 182
			p, -- 182
			cam -- 182
		) -- 182
	end -- 182
	local gateCloseUp = p.room.key == "gate" and p.phase == "gate-hand" and p.phaseTick >= 22 -- 186
	local partnerInsideGate = p.childMode and p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-walk") -- 187
	if p.partner.alive and not suppressPartner and not partnerInsideGate and not gateCloseUp then -- 187
		local partnerIsChild = p.partner.w <= 28 -- 190
		if partnerIsChild then -- 190
			self:drawXiaoman( -- 192
				fgDraw, -- 192
				fgGlow, -- 192
				assets, -- 192
				p.partner, -- 192
				p, -- 192
				cam, -- 192
				false -- 192
			) -- 192
		else -- 192
			self:drawZhouShu( -- 194
				fgDraw, -- 194
				fgGlow, -- 194
				assets, -- 194
				p.partner, -- 194
				p, -- 194
				cam, -- 194
				false -- 194
			) -- 194
		end -- 194
	end -- 194
	if p.player.alive and not gateCloseUp then -- 194
		if p.childMode then -- 194
			self:drawXiaoman( -- 201
				fgDraw, -- 201
				fgGlow, -- 201
				assets, -- 201
				p.player, -- 201
				p, -- 201
				cam, -- 201
				true -- 201
			) -- 201
		else -- 201
			self:drawZhouShu( -- 203
				fgDraw, -- 203
				fgGlow, -- 203
				assets, -- 203
				p.player, -- 203
				p, -- 203
				cam, -- 203
				true -- 203
			) -- 203
		end -- 203
	end -- 203
end -- 158
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 209
	local i = 0 -- 210
	do -- 210
		i = 0 -- 211
		while i < #self.ghosts do -- 211
			local g = self.ghosts[i + 1] -- 212
			local k = math.max( -- 213
				0, -- 213
				math.min(1, g.life / g.maxLife) -- 213
			) -- 213
			local spread = 1 - k -- 214
			local cx = cam:sx(g.x) -- 215
			local by = cam:sy(g.y, g.depth) -- 216
			local f = g.facing -- 217
			local rBase = cam:len(6 + spread * 9) -- 218
			fgGlow:drawCircle( -- 220
				Vec2( -- 221
					cx - f * cam:len(6 + spread * 10), -- 221
					by + cam:len(4 + spread * 5) -- 221
				), -- 221
				rBase, -- 222
				Color( -- 223
					156, -- 223
					144, -- 223
					124, -- 223
					math.floor(78 * k + 0.5) -- 223
				) -- 223
			) -- 223
			fgGlow:drawCircle( -- 225
				Vec2( -- 226
					cx - f * cam:len(14 + spread * 14), -- 226
					by + cam:len(8 + spread * 8) -- 226
				), -- 226
				rBase * 0.72, -- 227
				Color( -- 228
					186, -- 228
					174, -- 228
					152, -- 228
					math.floor(54 * k + 0.5) -- 228
				) -- 228
			) -- 228
			i = i + 1 -- 211
		end -- 211
	end -- 211
end -- 209
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 234
	local half = a.w * 0.5 -- 235
	local g = 0 -- 236
	local i = 0 -- 237
	do -- 237
		i = 0 -- 238
		while i < #p.room.floors do -- 238
			local f = p.room.floors[i + 1] -- 239
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 239
				g = f.y -- 241
			end -- 241
			i = i + 1 -- 238
		end -- 238
	end -- 238
	do -- 238
		i = 0 -- 244
		while i < #p.boxes do -- 244
			do -- 244
				local b = p.boxes[i + 1] -- 245
				if b.broken == true or b.hidden == true or b.soft == true then -- 245
					goto __continue41 -- 247
				end -- 247
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 247
					g = b.y1 -- 251
				end -- 251
			end -- 251
			::__continue41:: -- 251
			i = i + 1 -- 244
		end -- 244
	end -- 244
	return g -- 254
end -- 234
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 258
	local cx = cam:sx(a.x) -- 267
	local by = cam:sy(a.y, a.depth) -- 268
	local depthEnabled = p.room.depth ~= nil -- 269
	local shadowY = not a.onGround and cam:sy( -- 270
		self:supportGroundY(p, a), -- 270
		a.depth -- 270
	) or by -- 270
	local H = cam:len(a.h) -- 271
	local W = cam:len(a.w) -- 272
	local f = a.facing -- 273
	local speed = math.max( -- 274
		math.abs(a.vx), -- 274
		math.abs(a.depthSpeed) -- 274
	) -- 274
	local slot = "soldier_idle" -- 276
	local height = H -- 277
	local frame = 0 -- 278
	local facing = f -- 279
	local step = math.floor(self.animTime * 10) -- 280
	if isControlled and p.ticks < self.hitUntil then -- 280
		slot = "soldier_hit" -- 282
	elseif a.rollT > 0 then -- 282
		slot = "soldier_roll" -- 284
		height = height * 0.59 -- 285
	elseif p.phase == "prologue-give" then -- 285
		slot = "soldier_offer" -- 287
		height = height * 0.75 -- 288
		facing = p.partner.x >= a.x and 1 or -1 -- 289
	elseif isControlled and p.gripping then -- 289
		slot = "soldier_push" -- 291
		frame = self.cartMoving and step or 0 -- 292
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 293
		height = height * 0.91 -- 294
	elseif isControlled and p.escort.state == "calming" then -- 294
		slot = "soldier_knock" -- 296
		local calm = p.escort.calmTick -- 297
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 298
		height = height * 0.76 -- 299
	else -- 299
		local ____temp_7 = p.phase == "gate-send" -- 300
		if ____temp_7 then -- 300
			local ____opt_5 = p.room.story -- 300
			____temp_7 = (____opt_5 and ____opt_5.gate) ~= nil -- 300
		end -- 300
		if ____temp_7 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 300
			slot = "soldier_hold" -- 302
			height = height * 1.11 -- 303
		elseif isControlled and p.ticks < self.shotUntil then -- 303
			local running = speed > 8 -- 305
			slot = running and "soldier_fire_move" or "soldier_fire" -- 306
			frame = running and step or 0 -- 307
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 308
		elseif a.covered or isControlled and p.coverHug then -- 308
			slot = "soldier_cover" -- 310
			height = height * 0.77 -- 311
		elseif speed > 8 then -- 311
			slot = "soldier_run" -- 313
			frame = step -- 314
		end -- 314
	end -- 314
	local pose = { -- 316
		facing = facing, -- 316
		frame = frame, -- 316
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 316
	} -- 316
	local ____isControlled_8 -- 317
	if isControlled then -- 317
		____isControlled_8 = self.playerStride -- 317
	else -- 317
		____isControlled_8 = self.partnerStride -- 317
	end -- 317
	local gait = ____isControlled_8 -- 317
	local running = (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 318
		"soldier", -- 320
		"actor_soldier", -- 320
		cx, -- 320
		by, -- 320
		W, -- 320
		height, -- 320
		gait.cycle, -- 320
		pose, -- 320
		gait.effort -- 320
	) -- 320
	if running or assets:tryPlace( -- 320
		slot, -- 321
		"actor_soldier", -- 321
		cx, -- 321
		by, -- 321
		W, -- 321
		height, -- 321
		pose -- 321
	) then -- 321
		fgDraw:drawEllipse( -- 322
			Vec2(cx, shadowY + 1), -- 322
			W * 0.54, -- 322
			4, -- 322
			Color(12, 11, 13, 145) -- 322
		) -- 322
		return -- 323
	end -- 323
	fgDraw:drawEllipse( -- 327
		Vec2(cx, shadowY + 1), -- 327
		H * 0.24, -- 327
		4.5, -- 327
		Color(3, 5, 10, 175) -- 327
	) -- 327
	local walking = speed > 10 and a.onGround -- 329
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 330
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 331
	local calming = not p.childMode and p.escort.state == "calming" -- 332
	local rolling = a.rollT > 0 -- 333
	local crouching = a.covered or calming or rolling -- 334
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 337
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 338
	local sw = H * 0.115 -- 339
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 342
	local kneeY = by + bodyH * 0.23 -- 343
	local stepX = stride * H * 0.15 -- 344
	local legDark = Color(14, 21, 34, 255) -- 345
	local legFront = Color(26, 38, 58, 255) -- 346
	local bkX = cx - f * 4 - stepX * 0.5 -- 348
	local bfX = cx - f * 8 - stepX -- 349
	fgDraw:drawSegment( -- 350
		Vec2(cx - f * 3, hipY), -- 350
		Vec2(bkX, kneeY), -- 350
		H * 0.044, -- 350
		legDark -- 350
	) -- 350
	fgDraw:drawSegment( -- 351
		Vec2(bkX, kneeY), -- 351
		Vec2(bfX, by + 3), -- 351
		H * 0.038, -- 351
		legDark -- 351
	) -- 351
	local fkX = cx + f * 6 + stepX * 0.55 -- 353
	local ffX = cx + f * 7 + stepX -- 354
	fgDraw:drawSegment( -- 355
		Vec2(cx + f * 3, hipY), -- 355
		Vec2(fkX, kneeY), -- 355
		H * 0.048, -- 355
		legFront -- 355
	) -- 355
	fgDraw:drawSegment( -- 356
		Vec2(fkX, kneeY), -- 356
		Vec2(ffX, by + 3), -- 356
		H * 0.042, -- 356
		legFront -- 356
	) -- 356
	fgDraw:drawSegment( -- 358
		Vec2(ffX - f * 2, by + 3), -- 358
		Vec2(ffX + f * 9, by + 3), -- 358
		3.4, -- 358
		Color(42, 60, 86, 255) -- 358
	) -- 358
	local shY = by + bodyH * 0.8 + bob -- 361
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 362
	fgDraw:drawPolygon( -- 363
		{ -- 363
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 364
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 365
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 366
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 367
		}, -- 367
		Color(16, 26, 42, 248), -- 368
		1.2, -- 368
		Color(64, 118, 164, 195) -- 368
	) -- 368
	fgDraw:drawPolygon( -- 371
		{ -- 371
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 372
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 373
			Vec2(cx + sw * 1.05 + lean, shY), -- 374
			Vec2(cx - sw * 0.98 + lean, shY) -- 375
		}, -- 375
		Color(24, 38, 60, 255), -- 376
		1.3, -- 376
		toColor(PALETTE.rimSilver, 190) -- 376
	) -- 376
	fgDraw:drawSegment( -- 378
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 379
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 380
		2.4, -- 381
		Color(173, 155, 125, 225) -- 382
	) -- 382
	fgDraw:drawPolygon( -- 384
		{ -- 384
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 385
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 386
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 387
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 388
		}, -- 388
		Color(99, 105, 103, 248) -- 389
	) -- 389
	local headR = H * 0.088 -- 392
	local headX = cx + lean + f * 3 -- 393
	local headY = shY + headR * 1.35 -- 394
	fgDraw:drawCircle( -- 395
		Vec2(headX, headY - headR * 0.12), -- 395
		headR * 0.86, -- 395
		Color(181, 139, 106, 255) -- 395
	) -- 395
	fgDraw:drawEllipse( -- 396
		Vec2(headX, headY + headR * 0.5), -- 396
		headR * 1.12, -- 396
		headR * 0.72, -- 396
		Color(66, 73, 76, 255) -- 396
	) -- 396
	fgDraw:drawSegment( -- 397
		Vec2(headX - headR, headY + 1), -- 397
		Vec2(headX + headR, headY + 1), -- 397
		1.6, -- 398
		Color(97, 103, 101, 255) -- 398
	) -- 398
	fgDraw:drawSegment( -- 399
		Vec2(headX, headY + headR), -- 399
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 399
		1.6, -- 400
		Color(177, 78, 51, 255) -- 400
	) -- 400
	if isControlled and not calming and not rolling and not p.gripping then -- 400
		local gunPivotX = cx + lean + f * sw * 0.35 -- 404
		local gunPivotY = shY - bodyH * 0.1 -- 405
		local aimDx = f -- 406
		local aimDy = 0 -- 407
		if p.aimX > 0 or p.aimY > 0 then -- 407
			aimDx = p.aimX - gunPivotX -- 409
			aimDy = p.aimY - gunPivotY -- 410
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 411
			if dLen > 4 then -- 411
				aimDx = aimDx / dLen -- 413
				aimDy = aimDy / dLen -- 414
			end -- 414
		end -- 414
		local barrelLen = H * 0.34 -- 417
		local tipX = gunPivotX + aimDx * barrelLen -- 418
		local tipY = gunPivotY + aimDy * barrelLen -- 419
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 420
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 421
		fgDraw:drawSegment( -- 423
			Vec2(cx + lean, shY - 5), -- 423
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 423
			3.6, -- 423
			Color(26, 40, 62, 255) -- 423
		) -- 423
		fgDraw:drawSegment( -- 424
			Vec2(stockX, stockY), -- 424
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 424
			3.8, -- 424
			Color(105, 71, 50, 255) -- 424
		) -- 424
		fgDraw:drawSegment( -- 425
			Vec2(gunPivotX, gunPivotY), -- 425
			Vec2(tipX, tipY), -- 425
			1.8, -- 425
			Color(145, 140, 128, 245) -- 425
		) -- 425
	elseif calming then -- 425
		fgDraw:drawSegment( -- 427
			Vec2(cx + lean, shY - 6), -- 427
			Vec2(cx + f * sw * 2.1, shY - 14), -- 427
			3, -- 427
			Color(196, 222, 240, 235) -- 427
		) -- 427
		fgGlow:drawDot( -- 428
			Vec2(cx + f * sw * 2.15, shY - 14), -- 428
			3.6, -- 428
			toColor(PALETTE.amber, 225) -- 428
		) -- 428
	end -- 428
end -- 258
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 434
	local cx = cam:sx(a.x) -- 443
	local by = cam:sy(a.y, a.depth) -- 444
	local depthEnabled = p.room.depth ~= nil -- 445
	local shadowY = not a.onGround and cam:sy( -- 446
		self:supportGroundY(p, a), -- 446
		a.depth -- 446
	) or by -- 446
	local H = cam:len(a.h) -- 447
	local W = cam:len(a.w) -- 448
	local f = a.facing -- 449
	local speed = math.max( -- 450
		math.abs(a.vx), -- 450
		math.abs(a.depthSpeed) -- 450
	) -- 450
	local afraid = not isControlled and p.escort.fear > 0 -- 452
	local slot = "child_idle" -- 453
	local height = H -- 454
	local frame = 0 -- 455
	local step = math.floor(self.animTime * 10) -- 456
	local nearCover = __TS__ArraySome( -- 457
		p.room.solids, -- 457
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 457
			math.abs(a.x - solid.x), -- 460
			math.abs(a.x - solid.x - solid.w) -- 460
		) <= 30 end -- 460
	) -- 460
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 460
		slot = "child_knock" -- 463
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 463
		slot = "child_offer" -- 466
	elseif isControlled and p.ticks < self.throwUntil then -- 466
		slot = "child_throw" -- 468
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 468
		slot = "child_aim" -- 470
	elseif isControlled and p.gripping then -- 470
		slot = "child_pull" -- 472
		frame = self.cartMoving and step or 0 -- 473
	elseif afraid and p.escort.state == "frozen" then -- 473
		slot = "child_fear" -- 475
		height = height * 0.74 -- 476
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 476
		slot = "child_peek" -- 479
		height = height * 0.83 -- 480
	elseif a.crouch then -- 480
		slot = "child_crouch" -- 482
		frame = speed > 8 and step or 0 -- 483
	elseif speed > 8 then -- 483
		slot = "child_run" -- 485
		frame = step -- 486
	end -- 486
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 488
	local angle = 0 -- 489
	if isControlled and p.room.key == "gate" then -- 489
		if p.phase == "gate-count" then -- 489
			local tick = p.countTick -- 492
			local lean = smoothstep(1080, 1140, tick) * (1 - smoothstep(1432, 1462, tick)) -- 493
			local settle = smoothstep(GATE_COUNT_END, GATE_COUNT_END + 18, tick) * (1 - smoothstep(GATE_COUNT_END + 23, GATE_COUNT_END + 46, tick)) -- 494
			facing = tick < GATE_COUNT_END + 36 and -1 or 1 -- 496
			angle = -12 * lean + 5 * settle -- 497
			height = height * (1 - 0.035 * lean - 0.048 * settle + 0.009 * math.sin(self.animTime * 2.6)) -- 498
		elseif p.phase == "gate-wait" then -- 498
			facing = -1 -- 500
			if p.knocks >= 2 then -- 500
				slot = "child_knock" -- 502
				angle = -4 * smoothstep(12, 25, p.phaseTick) -- 503
			end -- 503
		end -- 503
	end -- 503
	local pose = { -- 507
		facing = facing, -- 507
		frame = frame, -- 507
		angle = angle, -- 507
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 507
	} -- 507
	local ____isControlled_9 -- 508
	if isControlled then -- 508
		____isControlled_9 = self.playerStride -- 508
	else -- 508
		____isControlled_9 = self.partnerStride -- 508
	end -- 508
	local gait = ____isControlled_9 -- 508
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 509
		"child", -- 511
		"actor_child", -- 511
		cx, -- 511
		by, -- 511
		W, -- 511
		height, -- 511
		gait.cycle, -- 511
		pose, -- 511
		gait.effort -- 511
	) -- 511
	if running or assets:tryPlace( -- 511
		slot, -- 512
		"actor_child", -- 512
		cx, -- 512
		by, -- 512
		W, -- 512
		height, -- 512
		pose -- 512
	) then -- 512
		fgDraw:drawEllipse( -- 513
			Vec2(cx, shadowY + 1), -- 513
			W * 0.48, -- 513
			3, -- 513
			Color(12, 11, 13, 125) -- 513
		) -- 513
		if afraid then -- 513
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 515
		end -- 515
		return -- 517
	end -- 517
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 520
	local x = cx + jitter -- 521
	local fullRef = a.crouch and H * 1.35 or H -- 523
	local cw = fullRef * 0.16 -- 524
	fgDraw:drawEllipse( -- 527
		Vec2(x, shadowY + 1), -- 527
		cw * 1.15, -- 527
		3.6, -- 527
		Color(4, 6, 10, 155) -- 527
	) -- 527
	local walking = speed > 6 and a.onGround -- 529
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 530
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 531
	local hipY = by + H * 0.3 -- 534
	local legSwing = stride * cw * 0.85 -- 535
	fgDraw:drawSegment( -- 536
		Vec2(x - 2, hipY), -- 536
		Vec2(x - legSwing, by + 2), -- 536
		math.max(2.6, cw * 0.22), -- 536
		Color(34, 30, 38, 255) -- 536
	) -- 536
	fgDraw:drawSegment( -- 537
		Vec2(x + 2, hipY), -- 537
		Vec2(x + legSwing, by + 2), -- 537
		math.max(2.8, cw * 0.24), -- 537
		Color(52, 46, 56, 255) -- 537
	) -- 537
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 540
	local cloakBotY = by + H * 0.2 -- 541
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 542
	fgDraw:drawPolygon( -- 543
		{ -- 543
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 544
			Vec2(x + cw * 0.92, cloakBotY), -- 545
			Vec2(x + cw * 0.62, cloakTopY), -- 546
			Vec2(x - cw * 0.68, cloakTopY) -- 547
		}, -- 547
		Color(214, 166, 94, 255), -- 548
		1.3, -- 548
		Color(252, 232, 192, 225) -- 548
	) -- 548
	fgDraw:drawPolygon( -- 549
		{ -- 549
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 550
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 551
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 552
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 553
		}, -- 553
		Color(148, 108, 56, 215) -- 554
	) -- 554
	fgDraw:drawSegment( -- 555
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 555
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 555
		1.8, -- 555
		toColor(PALETTE.amberCore, 200) -- 555
	) -- 555
	local scarfY = cloakTopY - 2 -- 558
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 559
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 560
	local sendX = x - f * cw * 1.65 + cloakDrag -- 561
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 562
	fgDraw:drawQuadraticBezier( -- 563
		Vec2(x - f * cw * 0.3, scarfY), -- 563
		Vec2(smidX, smidY), -- 563
		Vec2(sendX, sendY), -- 563
		2.8, -- 563
		toColor(PALETTE.amberCore, 235) -- 563
	) -- 563
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 566
	local headX = x + f * (a.crouch and 5 or 2) -- 567
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 568
	fgDraw:drawCircle( -- 569
		Vec2(headX, headY), -- 569
		headR, -- 569
		Color(240, 222, 198, 255) -- 569
	) -- 569
	fgDraw:drawPolygon( -- 571
		{ -- 571
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 572
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 573
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 574
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 575
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 576
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 577
		}, -- 577
		Color(156, 114, 62, 248), -- 578
		1.1, -- 578
		Color(244, 214, 162, 200) -- 578
	) -- 578
	fgGlow:drawDot( -- 580
		Vec2(headX + f * headR * 0.45, headY + 1), -- 580
		2.2, -- 580
		toColor(PALETTE.amberCore) -- 580
	) -- 580
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 583
	if hasCompass then -- 583
		local compX = x + f * cw * 0.65 -- 585
		local compY = by + H * 0.48 -- 586
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 587
		fgGlow:drawDot( -- 588
			Vec2(compX, compY), -- 588
			2.6, -- 588
			toColor(PALETTE.amberCore, 250) -- 588
		) -- 588
		fillRadialGlow( -- 589
			fgGlow, -- 589
			compX, -- 589
			compY, -- 589
			26 * glowPulse, -- 589
			26 * glowPulse, -- 589
			Color(248, 206, 120, 78 * glowPulse), -- 589
			Color(248, 180, 72, 0), -- 589
			14 -- 589
		) -- 589
	end -- 589
	if afraid then -- 589
		self:drawFear(fgGlow, p, x, by + H + 16) -- 593
	end -- 593
	if isControlled and walking and not a.crouch and speed > 100 then -- 593
		local r = 10 + self.animTime * 32 % 24 -- 598
		fgGlow:drawRing( -- 599
			Vec2(x, by + 3), -- 599
			r, -- 599
			r + 1.5, -- 599
			Color(0, 0, 0, 0), -- 599
			1.1, -- 599
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 599
		) -- 599
	end -- 599
end -- 434
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 603
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 604
	do -- 604
		local i = 0 -- 605
		while i < FEAR_MAX do -- 605
			local lit = i < p.escort.fear -- 606
			drawDiamond( -- 607
				fgGlow, -- 607
				x + (i - 1) * 13, -- 607
				y, -- 607
				4, -- 607
				5, -- 607
				toColor(lit and tint or PALETTE.steelDark, 215), -- 608
				1, -- 608
				toColor(tint, lit and 235 or 100) -- 608
			) -- 608
			i = i + 1 -- 605
		end -- 605
	end -- 605
end -- 603
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 612
	local x = cam:sx(e.x + f * 20) -- 613
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 614
	local dx = cam:sx(p.player.x) - x -- 615
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 616
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 617
	do -- 617
		local i = 0 -- 618
		while i < 8 do -- 618
			local a = length * i / 8 -- 619
			local b = length * (i + 1) / 8 -- 620
			fgGlow:drawSegment( -- 621
				Vec2(x + dx * a, y + dy * a), -- 621
				Vec2(x + dx * b, y + dy * b), -- 621
				1.3, -- 622
				Color(220, 120, 88, 210) -- 622
			) -- 622
			i = i + 2 -- 618
		end -- 618
	end -- 618
end -- 612
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 627
	local cx = cam:sx(e.x) -- 636
	local depth = e.depth or 0 -- 637
	local by = cam:sy(e.y, depth) -- 638
	local H = cam:len(e.h) -- 639
	local W = cam:len(e.w) -- 640
	local f = p.player.x >= e.x and 1 or -1 -- 641
	if e.kind == "target" then -- 641
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 645
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 646
		fgDraw:drawEllipse( -- 647
			Vec2(cx, by + 1), -- 647
			W * 0.52, -- 647
			3.6, -- 647
			Color(12, 11, 13, 140) -- 647
		) -- 647
		fgDraw:drawSegment( -- 649
			Vec2( -- 649
				cx - cam:len(9), -- 649
				by -- 649
			), -- 649
			Vec2(cx + lean * 0.4, postTopY), -- 649
			math.max( -- 649
				2, -- 649
				cam:len(3.2) -- 649
			), -- 649
			Color(92, 64, 42, 255) -- 649
		) -- 649
		fgDraw:drawSegment( -- 650
			Vec2( -- 650
				cx + cam:len(9), -- 650
				by -- 650
			), -- 650
			Vec2(cx + lean * 0.4, postTopY), -- 650
			math.max( -- 650
				2, -- 650
				cam:len(3.2) -- 650
			), -- 650
			Color(76, 52, 34, 255) -- 650
		) -- 650
		local discX = cx + lean -- 652
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 653
		local discR = math.max( -- 654
			7, -- 654
			cam:len(13) -- 654
		) -- 654
		local hitTint = e.hitT > 0 or not e.alive -- 655
		fgDraw:drawCircle( -- 656
			Vec2(discX, discY), -- 656
			discR, -- 656
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 656
		) -- 656
		fgDraw:drawRing( -- 657
			Vec2(discX, discY), -- 657
			discR * 0.62, -- 657
			discR * 0.76, -- 657
			Color(0, 0, 0, 0), -- 657
			1.4, -- 657
			Color(62, 46, 34, 230) -- 657
		) -- 657
		fgDraw:drawCircle( -- 658
			Vec2(discX, discY), -- 658
			discR * 0.3, -- 658
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 658
		) -- 658
		return -- 659
	end -- 659
	local slot = "enemy_idle" -- 662
	if not e.alive then -- 662
		slot = "enemy_down" -- 664
	elseif e.hitT > 0 then -- 664
		slot = "enemy_hit" -- 666
	elseif e.warnT > 0 then -- 666
		slot = "enemy_aim" -- 668
	end -- 668
	local height = e.alive and H or H * 0.24 -- 670
	if assets:tryPlace( -- 670
		slot, -- 671
		"actor_enemy_" .. tostring(index), -- 671
		cx, -- 671
		by, -- 671
		W, -- 671
		height, -- 671
		{ -- 671
			facing = f, -- 672
			opacity = e.alive and 1 or 0.78, -- 672
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 672
		} -- 672
	) then -- 672
		if e.alive then -- 672
			self:drawEnemyArchetypeGear( -- 675
				fgDraw, -- 675
				fgGlow, -- 675
				e, -- 675
				cx, -- 675
				by, -- 675
				H, -- 675
				f, -- 675
				cam -- 675
			) -- 675
			if e.warnT > 0 then -- 675
				self:drawEnemyWarning( -- 677
					fgGlow, -- 677
					e, -- 677
					p, -- 677
					cam, -- 677
					f -- 677
				) -- 677
			end -- 677
		end -- 677
		return -- 680
	end -- 680
	if not e.alive then -- 680
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 684
		fgDraw:drawPolygon( -- 685
			{ -- 685
				Vec2(cx - H * 0.3, by), -- 686
				Vec2(cx + H * 0.28, by), -- 687
				Vec2(cx + H * 0.2, by + H * 0.14), -- 688
				Vec2(cx - H * 0.24, by + H * 0.11) -- 689
			}, -- 689
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 690
		) -- 690
		if flash > 0 then -- 690
			fillRadialGlow( -- 692
				fgGlow, -- 692
				cx, -- 692
				by + 12, -- 692
				34 * flash, -- 692
				18 * flash, -- 692
				toColor(PALETTE.crimson, 180 * flash), -- 692
				Color(255, 48, 82, 0), -- 692
				12 -- 692
			) -- 692
		end -- 692
		return -- 694
	end -- 694
	local sw = H * 0.112 -- 697
	fgDraw:drawEllipse( -- 698
		Vec2(cx, by + 1), -- 698
		sw * 1.9, -- 698
		4, -- 698
		Color(4, 6, 10, 165) -- 698
	) -- 698
	local hipY = by + H * 0.44 -- 701
	local kneeY = by + H * 0.23 -- 702
	local shY = by + H * 0.79 -- 703
	fgDraw:drawSegment( -- 704
		Vec2(cx - 5, hipY), -- 704
		Vec2(cx - 7, kneeY), -- 704
		H * 0.044, -- 704
		Color(20, 16, 26, 255) -- 704
	) -- 704
	fgDraw:drawSegment( -- 705
		Vec2(cx - 7, kneeY), -- 705
		Vec2(cx - 8, by + 2), -- 705
		H * 0.038, -- 705
		Color(20, 16, 26, 255) -- 705
	) -- 705
	fgDraw:drawSegment( -- 706
		Vec2(cx + 5, hipY), -- 706
		Vec2(cx + 7, kneeY), -- 706
		H * 0.046, -- 706
		Color(28, 22, 36, 255) -- 706
	) -- 706
	fgDraw:drawSegment( -- 707
		Vec2(cx + 7, kneeY), -- 707
		Vec2(cx + 8, by + 2), -- 707
		H * 0.04, -- 707
		Color(28, 22, 36, 255) -- 707
	) -- 707
	fgDraw:drawPolygon( -- 709
		{ -- 709
			Vec2(cx - sw * 0.68, hipY), -- 710
			Vec2(cx + sw * 0.68, hipY), -- 711
			Vec2(cx + sw * 1.12, shY), -- 712
			Vec2(cx - sw * 1.12, shY) -- 713
		}, -- 713
		Color(111, 68, 55, 255), -- 714
		1.3, -- 714
		Color(143, 101, 66, 220) -- 714
	) -- 714
	fgDraw:drawPolygon( -- 715
		{ -- 715
			Vec2(cx - sw * 1.26, shY - 6), -- 716
			Vec2(cx + sw * 1.26, shY - 6), -- 717
			Vec2(cx + sw * 0.96, shY + 5), -- 718
			Vec2(cx - sw * 0.96, shY + 5) -- 719
		}, -- 719
		Color(98, 82, 62, 255) -- 720
	) -- 720
	local headR = H * 0.086 -- 722
	local headY = shY + headR * 1.32 -- 723
	fgDraw:drawCircle( -- 724
		Vec2(cx, headY), -- 724
		headR * 0.82, -- 724
		Color(187, 142, 103, 255) -- 724
	) -- 724
	fgDraw:drawPolygon( -- 725
		{ -- 725
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 726
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 727
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 728
		}, -- 728
		Color(136, 105, 65, 255), -- 729
		1.1, -- 729
		Color(177, 145, 91, 220) -- 729
	) -- 729
	local gunX = cx + f * H * 0.34 -- 731
	local gunY = by + H * 0.69 -- 732
	fgDraw:drawSegment( -- 733
		Vec2(cx - f * 6, gunY - 2), -- 733
		Vec2(gunX, gunY), -- 733
		2.8, -- 733
		Color(118, 87, 61, 255) -- 733
	) -- 733
	self:drawEnemyArchetypeGear( -- 734
		fgDraw, -- 734
		fgGlow, -- 734
		e, -- 734
		cx, -- 734
		by, -- 734
		H, -- 734
		f, -- 734
		cam -- 734
	) -- 734
	if e.warnT > 0 then -- 734
		self:drawEnemyWarning( -- 736
			fgGlow, -- 736
			e, -- 736
			p, -- 736
			cam, -- 736
			f -- 736
		) -- 736
	end -- 736
end -- 627
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, e, cx, by, H, f, cam) -- 741
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 741
		local shX = cx + f * cam:len(13) -- 752
		local shW = math.max( -- 753
			5, -- 753
			cam:len(8) -- 753
		) -- 753
		local shH = H * 0.72 -- 754
		local cracked = (e.shieldHp or 2) <= 1 -- 755
		fgDraw:drawRect( -- 756
			Rect(shX - shW * 0.5, by + H * 0.08, shW, shH), -- 757
			cracked and Color(122, 82, 52, 245) or Color(96, 66, 42, 250), -- 758
			1.3, -- 759
			Color(168, 174, 180, 230) -- 760
		) -- 760
		fgDraw:drawCircle( -- 762
			Vec2(shX, by + H * 0.44), -- 762
			math.max( -- 762
				2.2, -- 762
				cam:len(3.5) -- 762
			), -- 762
			Color(142, 148, 154, 240) -- 762
		) -- 762
		if cracked then -- 762
			fgDraw:drawSegment( -- 764
				Vec2(shX - shW * 0.4, by + H * 0.28), -- 764
				Vec2(shX + shW * 0.4, by + H * 0.58), -- 764
				1.4, -- 764
				Color(24, 18, 16, 235) -- 764
			) -- 764
		end -- 764
	elseif e.kind == "breaker" then -- 764
		local swing = (e.swingT or 0) > 0 -- 767
		local handleX0 = cx - f * cam:len(4) -- 768
		local handleY0 = by + H * 0.44 -- 769
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 770
		local tipY = by + H * (swing and 0.46 or 0.78) -- 771
		fgDraw:drawSegment( -- 772
			Vec2(handleX0, handleY0), -- 772
			Vec2(tipX, tipY), -- 772
			math.max( -- 772
				2.2, -- 772
				cam:len(3) -- 772
			), -- 772
			Color(98, 66, 44, 255) -- 772
		) -- 772
		fgDraw:drawPolygon( -- 773
			{ -- 773
				Vec2( -- 774
					tipX - f * cam:len(3), -- 774
					tipY - cam:len(4) -- 774
				), -- 774
				Vec2( -- 775
					tipX + f * cam:len(9), -- 775
					tipY - cam:len(1) -- 775
				), -- 775
				Vec2( -- 776
					tipX + f * cam:len(7), -- 776
					tipY + cam:len(9) -- 776
				), -- 776
				Vec2( -- 777
					tipX - f * cam:len(2), -- 777
					tipY + cam:len(6) -- 777
				) -- 777
			}, -- 777
			Color(148, 154, 162, 250), -- 778
			1, -- 778
			Color(224, 228, 232, 220) -- 778
		) -- 778
		if swing then -- 778
			fgGlow:drawArc( -- 780
				Vec2( -- 780
					cx + f * cam:len(10), -- 780
					by + H * 0.56 -- 780
				), -- 780
				cam:len(18), -- 780
				f > 0 and -40 or 140, -- 780
				f > 0 and 50 or 230, -- 780
				1.8, -- 780
				toColor(PALETTE.rouge, 195) -- 780
			) -- 780
		end -- 780
	elseif e.kind == "leader" then -- 780
		local topY = by + H * 1.02 -- 784
		fgDraw:drawSegment( -- 785
			Vec2(cx, topY), -- 785
			Vec2( -- 785
				cx - f * cam:len(10), -- 785
				topY + cam:len(9) -- 785
			), -- 785
			2.2, -- 785
			toColor(PALETTE.rouge, 240) -- 785
		) -- 785
		fgDraw:drawDot( -- 786
			Vec2( -- 786
				cx - f * cam:len(10), -- 786
				topY + cam:len(9) -- 786
			), -- 786
			2.6, -- 786
			toColor(PALETTE.crimsonCore, 235) -- 786
		) -- 786
	end -- 786
end -- 741
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 791
	local s = p.room.scavenger -- 798
	if s == nil then -- 798
		return -- 800
	end -- 800
	local cx = cam:sx(p.scavX) -- 802
	local by = cam:sy(s.y) -- 803
	local H = cam:len(s.h) -- 804
	local W = cam:len(26) -- 805
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 806
	local alert = p.scavChase or p.scavSee > 0 -- 809
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 810
	local eyeY = by + H * 0.8 -- 811
	local coneLen = cam:len(alert and 155 or 115) -- 812
	fgGlow:drawVertices({ -- 813
		{ -- 814
			Vec2(cx + f * 6, eyeY), -- 814
			toColor(coneCol, alert and 78 or 34) -- 814
		}, -- 814
		{ -- 815
			Vec2(cx + f * coneLen, by + H * 1.05), -- 815
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 815
		}, -- 815
		{ -- 816
			Vec2(cx + f * coneLen, by + 4), -- 816
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 816
		} -- 816
	}) -- 816
	local frame = 0 -- 819
	if p.scavState == "turn" then -- 819
		frame = 2 -- 821
	elseif p.scavState == "chase" then -- 821
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 823
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 823
		frame = math.floor(self.animTime * 8) % 2 -- 825
	end -- 825
	if assets:tryPlace( -- 825
		"scavenger", -- 827
		"actor_scav", -- 827
		cx, -- 827
		by, -- 827
		W, -- 827
		H, -- 827
		{facing = f, frame = frame, layer = 3} -- 827
	) then -- 827
		return -- 828
	end -- 828
	fgDraw:drawEllipse( -- 831
		Vec2(cx, by + 1), -- 831
		W * 0.62, -- 831
		4, -- 831
		Color(4, 6, 10, 155) -- 831
	) -- 831
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 832
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 833
	fgDraw:drawSegment( -- 835
		Vec2(cx - 4, by + H * 0.4), -- 835
		Vec2(cx - stride, by + 2), -- 835
		W * 0.16, -- 835
		Color(32, 30, 28, 255) -- 835
	) -- 835
	fgDraw:drawSegment( -- 836
		Vec2(cx + 4, by + H * 0.4), -- 836
		Vec2(cx + stride, by + 2), -- 836
		W * 0.16, -- 836
		Color(44, 40, 36, 255) -- 836
	) -- 836
	fgDraw:drawPolygon( -- 838
		{ -- 838
			Vec2(cx - W * 0.45, by + H * 0.25), -- 839
			Vec2(cx + W * 0.42, by + H * 0.25), -- 840
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 841
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 842
		}, -- 842
		Color(56, 52, 46, 255), -- 843
		1.2, -- 843
		Color(128, 118, 100, 180) -- 843
	) -- 843
	local headX = cx + f * 5 -- 845
	local headY = by + H * 0.88 -- 846
	fgDraw:drawCircle( -- 847
		Vec2(headX, headY), -- 847
		W * 0.3, -- 847
		Color(42, 38, 34, 255) -- 847
	) -- 847
	fgGlow:drawDot( -- 848
		Vec2(headX + f * 6, headY), -- 848
		3, -- 848
		toColor(coneCol, 245) -- 848
	) -- 848
	local indY = by + H + 18 -- 851
	if p.scavChase then -- 851
		drawDiamond( -- 853
			fgGlow, -- 853
			cx, -- 853
			indY, -- 853
			9, -- 853
			12, -- 853
			toColor(PALETTE.crimson, 240), -- 853
			1.5, -- 853
			toColor(PALETTE.crimsonCore) -- 853
		) -- 853
	elseif p.scavSee > 0 then -- 853
		local frac = math.min(1, p.scavSee / 24) -- 855
		fgGlow:drawArc( -- 856
			Vec2(cx, indY), -- 856
			11, -- 856
			90, -- 856
			90 - 360 * frac, -- 856
			2.4, -- 856
			toColor(PALETTE.crimson, 235) -- 856
		) -- 856
		fgGlow:drawDot( -- 857
			Vec2(cx, indY), -- 857
			3, -- 857
			toColor(PALETTE.amber) -- 857
		) -- 857
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 857
		drawDiamond( -- 859
			fgGlow, -- 859
			cx, -- 859
			indY, -- 859
			6, -- 859
			8, -- 859
			toColor(PALETTE.amber, 220) -- 859
		) -- 859
	end -- 859
end -- 791
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 864
	local cx = cam:sx(p.dogX) -- 871
	local by = cam:sy(0) -- 872
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 873
	local W = cam:len(42) -- 874
	local H = cam:len(34) -- 875
	local frame = 0 -- 877
	if p.dogState == "ear" then -- 877
		frame = 1 -- 879
	elseif p.dogState == "sniff" then -- 879
		frame = 3 -- 881
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 881
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 883
	end -- 883
	if assets:tryPlace( -- 883
		"dog", -- 885
		"actor_dog", -- 885
		cx, -- 885
		by, -- 885
		W, -- 885
		H, -- 885
		{facing = f, frame = frame, layer = 3} -- 885
	) then -- 885
		return -- 886
	end -- 886
	fgDraw:drawEllipse( -- 889
		Vec2(cx, by + 1), -- 889
		W * 0.56, -- 889
		3.5, -- 889
		Color(4, 8, 10, 155) -- 889
	) -- 889
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 890
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 891
	fgDraw:drawSegment( -- 894
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 894
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 894
		2.8, -- 894
		Color(26, 30, 34, 255) -- 894
	) -- 894
	fgDraw:drawSegment( -- 895
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 895
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 895
		2.8, -- 895
		Color(36, 40, 44, 255) -- 895
	) -- 895
	fgDraw:drawPolygon( -- 897
		{ -- 897
			Vec2(cx - W * 0.42, by + H * 0.36), -- 898
			Vec2(cx + W * 0.38, by + H * 0.42), -- 899
			Vec2(cx + W * 0.34, by + H * 0.78), -- 900
			Vec2(cx - W * 0.38, by + H * 0.72) -- 901
		}, -- 901
		Color(38, 42, 48, 255), -- 902
		1.2, -- 902
		Color(102, 118, 126, 175) -- 902
	) -- 902
	local hx = cx + f * W * 0.42 -- 903
	local hy = by + H * 0.84 -- 904
	fgDraw:drawPolygon( -- 905
		{ -- 905
			Vec2(hx - f * 8, hy - 6), -- 906
			Vec2(hx + f * 12, hy - 2), -- 907
			Vec2(hx + f * 4, hy + 8), -- 908
			Vec2(hx - f * 6, hy + 14) -- 909
		}, -- 909
		Color(44, 48, 54, 255) -- 910
	) -- 910
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 912
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 913
	fgGlow:drawDot( -- 914
		Vec2(hx + f * 4, hy + 2), -- 914
		2.8, -- 914
		toColor(eyeCol, 250) -- 914
	) -- 914
	fillRadialGlow( -- 915
		fgGlow, -- 915
		hx + f * 4, -- 915
		hy + 2, -- 915
		16, -- 915
		16, -- 915
		toColor(eyeCol, alert and 135 or 70), -- 915
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 915
		12 -- 915
	) -- 915
	if alert then -- 915
		local r = 12 + self.animTime * 42 % 24 -- 918
		fgGlow:drawArc( -- 919
			Vec2(hx, hy + 12), -- 919
			r, -- 919
			35, -- 919
			145, -- 919
			1.8, -- 919
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 919
		) -- 919
	end -- 919
end -- 864
return ____exports -- 864