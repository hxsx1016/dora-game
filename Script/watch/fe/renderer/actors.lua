-- [ts]: actors.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____escort = require("Script.watch.escort") -- 5
local FEAR_MAX = ____escort.FEAR_MAX -- 5
local ____clock = require("Script.watch.clock") -- 6
local STEP = ____clock.STEP -- 6
local ____depth = require("Script.watch.depth") -- 7
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 7
local overlapsDepth = ____depth.overlapsDepth -- 7
local ____occlusion = require("Script.watch.fe.occlusion") -- 8
local depthOrder = ____occlusion.depthOrder -- 8
local ____anim_controller = require("Script.watch.fe.renderer.anim_controller") -- 12
local ActorAnimController = ____anim_controller.ActorAnimController -- 12
local ____theme = require("Script.watch.fe.theme") -- 13
local PALETTE = ____theme.PALETTE -- 13
local drawDiamond = ____theme.drawDiamond -- 13
local fillRadialGlow = ____theme.fillRadialGlow -- 13
local toColor = ____theme.toColor -- 13
local function strideAt(actor) -- 34
	return { -- 35
		actor = actor, -- 35
		x = actor.x, -- 35
		depth = actor.depth, -- 35
		speed = 0, -- 35
		cycle = 0, -- 35
		sampledCycle = 0, -- 35
		sinceSample = 0, -- 35
		effort = 0 -- 35
	} -- 35
end -- 34
local RUN_START_T = 0.1 -- 38
local RUN_STOP_T = 0.13 -- 39
local function advanceStride(stride, steps, dt) -- 41
	local a = stride.actor -- 42
	local distance = 0 -- 43
	if steps > 0 then -- 43
		local dx = a.x - stride.x -- 45
		local depth = a.depth - stride.depth -- 46
		distance = math.sqrt(dx * dx + depth * depth) -- 47
		local speed = distance / (steps * STEP) -- 48
		stride.speed = speed <= 380 and speed or 0 -- 49
		stride.x = a.x -- 50
		stride.depth = a.depth -- 51
		stride.sinceSample = 0 -- 52
	else -- 52
		stride.sinceSample = math.min(STEP, stride.sinceSample + dt) -- 54
	end -- 54
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 54
		stride.effort = 0 -- 57
		return -- 58
	end -- 58
	if stride.speed > 8 then -- 58
		stride.effort = math.min(1, stride.effort + dt / RUN_START_T) -- 61
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 62
		stride.sampledCycle = (stride.sampledCycle + distance / strideLength) % 1 -- 63
		stride.cycle = (stride.sampledCycle + stride.speed * stride.sinceSample / strideLength) % 1 -- 65
	else -- 65
		stride.effort = math.max(0, stride.effort - dt / RUN_STOP_T) -- 67
	end -- 67
end -- 41
local DUST_LIFE = 0.23 -- 71
local ZS_IDLE_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_idle_0", "assets/art/actors_zhoushu_anim.clip|zs_idle_1", "assets/art/actors_zhoushu_anim.clip|zs_idle_2", "assets/art/actors_zhoushu_anim.clip|zs_idle_3"} -- 73
local ZS_JUMP_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_jump_0", "assets/art/actors_zhoushu_anim.clip|zs_jump_1", "assets/art/actors_zhoushu_anim.clip|zs_jump_2", "assets/art/actors_zhoushu_anim.clip|zs_jump_3"} -- 79
local ZS_FIRE_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_fire_0", "assets/art/actors_zhoushu_anim.clip|zs_fire_1", "assets/art/actors_zhoushu_anim.clip|zs_fire_2", "assets/art/actors_zhoushu_anim.clip|zs_fire_3"} -- 85
local ZS_COVER_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_cover_0", "assets/art/actors_zhoushu_anim.clip|zs_cover_1"} -- 91
local ZS_HIT_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_hit_0", "assets/art/actors_zhoushu_anim.clip|zs_hit_1"} -- 95
local ZS_PUSH_CLIPS = {"assets/art/actors_zhoushu_anim.clip|zs_push_0", "assets/art/actors_zhoushu_anim.clip|zs_push_1", "assets/art/actors_zhoushu_anim.clip|zs_push_2", "assets/art/actors_zhoushu_anim.clip|zs_push_3"} -- 99
local XM_IDLE_CLIPS = {"assets/art/actors_xiaoman_anim.clip|xm_idle_0", "assets/art/actors_xiaoman_anim.clip|xm_idle_1", "assets/art/actors_xiaoman_anim.clip|xm_idle_2", "assets/art/actors_xiaoman_anim.clip|xm_idle_3"} -- 106
local XM_JUMP_CLIPS = {"assets/art/actors_xiaoman_anim.clip|xm_jump_0", "assets/art/actors_xiaoman_anim.clip|xm_jump_1", "assets/art/actors_xiaoman_anim.clip|xm_jump_2", "assets/art/actors_xiaoman_anim.clip|xm_jump_3"} -- 112
local XM_CRAWL_CLIPS = {"assets/art/actors_xiaoman_anim.clip|xm_crawl_0", "assets/art/actors_xiaoman_anim.clip|xm_crawl_1", "assets/art/actors_xiaoman_anim.clip|xm_crawl_2", "assets/art/actors_xiaoman_anim.clip|xm_crawl_3"} -- 118
local XM_PULL_MID_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_pull_mid" -- 124
local XM_THROW_REL_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_throw_rel" -- 125
local XM_FEAR_B_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_fear_b" -- 126
local XM_PEEK_B_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_peek_b" -- 127
local EN_GUN_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_idle_0" -- 129
local EN_GUN_WALK_CLIPS = {"assets/art/actors_enemies_anim.clip|en_gun_walk_0", "assets/art/actors_enemies_anim.clip|en_gun_walk_1"} -- 130
local EN_GUN_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_aim" -- 134
local EN_GUN_FIRE_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_fire" -- 135
local EN_GUN_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_hit" -- 136
local EN_GUN_DOWN_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_down" -- 137
local EN_SHD_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_idle" -- 139
local EN_SHD_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_walk_0" -- 140
local EN_SHD_BASH_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_bash" -- 141
local EN_SHD_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_hit" -- 142
local EN_BRK_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_walk" -- 144
local EN_BRK_WINDUP_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_windup" -- 145
local EN_BRK_CLEAVE_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_cleave" -- 146
local EN_BRK_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_hit" -- 147
local EN_LDR_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_idle" -- 149
local EN_LDR_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_walk" -- 150
local EN_LDR_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_aim" -- 151
local EN_LDR_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_hit" -- 152
local SCAV_WALK_CLIPS = {"assets/art/actors_enemies_anim.clip|scav_walk_0", "assets/art/actors_enemies_anim.clip|scav_walk_1"} -- 154
local SCAV_TURN_CLIP = "assets/art/actors_enemies_anim.clip|scav_turn" -- 158
local SCAV_RUN_CLIP = "assets/art/actors_enemies_anim.clip|scav_run" -- 159
local DOG_WALK_CLIP = "assets/art/actors_enemies_anim.clip|dog_walk" -- 161
local DOG_ALERT_CLIP = "assets/art/actors_enemies_anim.clip|dog_alert" -- 162
local DOG_RUN_CLIPS = {"assets/art/actors_enemies_anim.clip|dog_run_0", "assets/art/actors_enemies_anim.clip|dog_run_1"} -- 163
local SLIDE_DUST_CLIPS = {"assets/art/vfx_ming_fx.clip|dust_0", "assets/art/vfx_ming_fx.clip|dust_1"} -- 168
local IDLE_PING_PONG = { -- 173
	-1, -- 173
	0, -- 173
	1, -- 173
	2, -- 173
	3, -- 173
	2, -- 173
	1, -- 173
	0 -- 173
} -- 173
____exports.ActorsRenderer = __TS__Class() -- 175
local ActorsRenderer = ____exports.ActorsRenderer -- 175
ActorsRenderer.name = "ActorsRenderer" -- 175
function ActorsRenderer.prototype.____constructor(self) -- 175
	self.slideDust = {} -- 176
	self.dustCooldown = 0 -- 177
	self.slideDuration = 0 -- 178
	self.slideRemainder = 0 -- 179
	self.strideTick = 0 -- 180
	self.anim = __TS__New(ActorAnimController) -- 183
	self.animTime = 0 -- 184
	self.previousHp = 3 -- 185
	self.previousAxle = 0 -- 186
	self.cartMoving = false -- 187
	self.previousBottle = false -- 188
	self.hitStartTick = 0 -- 190
	self.hitUntil = -1 -- 191
	self.throwStartTick = 0 -- 192
	self.throwUntil = -1 -- 193
	self.shotStartTick = 0 -- 194
	self.shotUntil = -1 -- 195
end -- 175
function ActorsRenderer.prototype.drainFootsteps(self) -- 197
	return self.anim:drainFootsteps() -- 198
end -- 197
function ActorsRenderer.prototype.reset(self, p) -- 201
	self.slideDust = {} -- 202
	self.dustCooldown = 0 -- 203
	self.slideDuration = 0 -- 204
	self.slideRemainder = 0 -- 205
	self.strideTick = p.ticks -- 206
	self.playerStride = strideAt(p.player) -- 207
	self.partnerStride = strideAt(p.partner) -- 208
	self.anim:reset(p) -- 209
	self.animTime = 0 -- 210
	self.previousHp = p.hp -- 211
	self.previousAxle = p.cartAxle -- 212
	self.cartMoving = false -- 213
	self.previousBottle = p.hasBottle -- 214
	self.previousTrace = p.trace -- 215
	self.hitStartTick = 0 -- 216
	self.hitUntil = -1 -- 217
	self.throwStartTick = 0 -- 218
	self.throwUntil = -1 -- 219
	self.shotStartTick = 0 -- 220
	self.shotUntil = -1 -- 221
end -- 201
function ActorsRenderer.prototype.update(self, dt, p) -- 225
	self.animTime = self.animTime + dt -- 226
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 226
		self.hitStartTick = p.ticks -- 228
		self.hitUntil = p.ticks + 16 -- 229
		self.anim.player:triggerHit(p.player.facing) -- 230
	end -- 230
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 230
		self.throwStartTick = p.ticks -- 233
		self.throwUntil = p.ticks + 16 -- 234
	end -- 234
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 234
		self.shotStartTick = p.ticks -- 237
		self.shotUntil = p.ticks + 16 -- 238
		local shotDir = p.trace.x1 < p.trace.x0 and -1 or 1 -- 239
		self.anim.player:triggerRecoil(shotDir) -- 240
	end -- 240
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 242
	self.previousAxle = p.cartAxle -- 243
	self.previousHp = p.hp -- 244
	self.previousBottle = p.hasBottle -- 245
	self.previousTrace = p.trace -- 246
	local ____opt_0 = self.playerStride -- 246
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 246
		self.playerStride = strideAt(p.player) -- 248
	end -- 248
	local ____opt_2 = self.partnerStride -- 248
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 248
		self.partnerStride = strideAt(p.partner) -- 251
	end -- 251
	local steps = math.max(0, p.ticks - self.strideTick) -- 253
	advanceStride(self.playerStride, steps, dt) -- 254
	advanceStride(self.partnerStride, steps, dt) -- 255
	self.strideTick = p.ticks -- 256
	self:updateSlide(dt, steps, p, self.playerStride.speed) -- 257
	self.anim.player:update( -- 259
		dt, -- 260
		p.player, -- 261
		self.playerStride.cycle, -- 262
		self.playerStride.speed, -- 263
		self.playerStride.effort, -- 264
		p.player.covered or p.coverHug, -- 265
		self.anim.footstepCues -- 266
	) -- 266
	self.anim.partner:update( -- 268
		dt, -- 269
		p.partner, -- 270
		self.partnerStride.cycle, -- 271
		self.partnerStride.speed, -- 272
		self.partnerStride.effort, -- 273
		p.partner.covered, -- 274
		self.anim.footstepCues -- 275
	) -- 275
	self.anim:updateEnemiesAndNpcs(dt, p) -- 277
end -- 225
function ActorsRenderer.prototype.slidePhase(self, a) -- 280
	local remaining = math.max(0, a.rollT - self.slideRemainder) -- 281
	return self.slideDuration > 0 and 1 - remaining / self.slideDuration or 0 -- 282
end -- 280
function ActorsRenderer.prototype.updateSlide(self, dt, steps, p, speed) -- 285
	local a = p.player -- 286
	if not p.childMode and a.rollT > 0 then -- 286
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 289
			0, -- 290
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 290
		) -- 290
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 291
		local progress = self:slidePhase(a) -- 292
		self.dustCooldown = self.dustCooldown - dt -- 293
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 293
			local ____self_slideDust_4 = self.slideDust -- 293
			____self_slideDust_4[#____self_slideDust_4 + 1] = { -- 295
				x = a.x + a.facing * a.h * 0.34, -- 296
				y = a.y, -- 297
				depth = a.depth, -- 298
				facing = a.facing, -- 299
				life = DUST_LIFE -- 300
			} -- 300
			self.dustCooldown = 0.038 -- 302
		end -- 302
	else -- 302
		self.slideDuration = 0 -- 305
		self.slideRemainder = 0 -- 306
		self.dustCooldown = 0 -- 307
	end -- 307
	local write = 0 -- 309
	for ____, dust in ipairs(self.slideDust) do -- 310
		dust.life = dust.life - dt -- 311
		if dust.life > 0 then -- 311
			self.slideDust[write + 1] = dust -- 313
			write = write + 1 -- 314
		end -- 314
	end -- 314
	__TS__ArraySetLength(self.slideDust, write) -- 314
end -- 285
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, pose) -- 320
	self:drawSlideDust(fgGlow, assets, p, cam) -- 328
	local i = 0 -- 331
	do -- 331
		i = 0 -- 332
		while i < #p.enemies do -- 332
			self:drawEnemy( -- 333
				fgDraw, -- 333
				fgGlow, -- 333
				assets, -- 333
				p.enemies[i + 1], -- 333
				i, -- 333
				p, -- 333
				cam -- 333
			) -- 333
			i = i + 1 -- 332
		end -- 332
	end -- 332
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 332
		self:drawScavenger( -- 338
			fgDraw, -- 338
			fgGlow, -- 338
			assets, -- 338
			p, -- 338
			cam -- 338
		) -- 338
	end -- 338
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 338
		self:drawDog( -- 343
			fgDraw, -- 343
			fgGlow, -- 343
			assets, -- 343
			p, -- 343
			cam -- 343
		) -- 343
	end -- 343
	if p.partner.alive and not (pose and pose.partner) then -- 343
		local partnerIsChild = p.partner.w <= 28 -- 348
		if partnerIsChild then -- 348
			self:drawXiaoman( -- 350
				fgDraw, -- 350
				fgGlow, -- 350
				assets, -- 350
				p.partner, -- 350
				p, -- 350
				cam, -- 350
				false -- 350
			) -- 350
		else -- 350
			self:drawZhouShu( -- 352
				fgDraw, -- 352
				fgGlow, -- 352
				assets, -- 352
				p.partner, -- 352
				p, -- 352
				cam, -- 352
				false -- 352
			) -- 352
		end -- 352
	end -- 352
	if p.player.alive then -- 352
		if p.childMode then -- 352
			self:drawXiaoman( -- 359
				fgDraw, -- 359
				fgGlow, -- 359
				assets, -- 359
				p.player, -- 359
				p, -- 359
				cam, -- 359
				true -- 359
			) -- 359
		else -- 359
			self:drawZhouShu( -- 361
				fgDraw, -- 361
				fgGlow, -- 361
				assets, -- 361
				p.player, -- 361
				p, -- 361
				cam, -- 361
				true, -- 361
				pose and pose.player -- 361
			) -- 361
		end -- 361
	end -- 361
end -- 320
function ActorsRenderer.prototype.drawSlideDust(self, draw, assets, p, cam) -- 366
	local depthEnabled = p.room.depth ~= nil -- 367
	do -- 367
		local i = 0 -- 368
		while i < #self.slideDust do -- 368
			local dust = self.slideDust[i + 1] -- 369
			local alpha = dust.life / DUST_LIFE -- 370
			local spread = 1 - alpha -- 371
			local dScale = cam:depthScale(dust.depth, depthEnabled) -- 372
			local x = cam:sx(dust.x - dust.facing * spread * 17) -- 373
			local y = cam:sy(dust.y + 1.5 + spread * 2, dust.depth) -- 374
			local dustSz = cam:len(14 + spread * 16) * dScale -- 375
			local clip = SLIDE_DUST_CLIPS[(spread < 0.45 and 0 or 1) + 1] -- 376
			if not assets:tryPlacePath( -- 376
				clip, -- 377
				"slide_dust_" .. tostring(i), -- 377
				x, -- 377
				y, -- 377
				dustSz * 1.25, -- 377
				dustSz, -- 377
				{ -- 377
					anchorX = 0.5, -- 378
					anchorY = 0, -- 379
					preserveAspect = true, -- 380
					facing = dust.facing, -- 381
					opacity = alpha * 0.85, -- 382
					layer = depthEnabled and depthOrder(dust.depth, 5) or 6 -- 383
				} -- 383
			) then -- 383
				draw:drawEllipse( -- 385
					Vec2(x, y), -- 385
					cam:len(5 + spread * 7), -- 385
					cam:len(1.5 + spread * 2), -- 385
					Color(166, 147, 124, 170 * alpha) -- 386
				) -- 386
				draw:drawDot( -- 387
					Vec2( -- 387
						x - dust.facing * cam:len(3), -- 387
						y + cam:len(4) -- 387
					), -- 387
					cam:len(1.1), -- 388
					Color(195, 174, 148, 135 * alpha) -- 388
				) -- 388
			end -- 388
			i = i + 1 -- 368
		end -- 368
	end -- 368
end -- 366
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 394
	local half = a.w * 0.5 -- 395
	local g = 0 -- 396
	local i = 0 -- 397
	do -- 397
		i = 0 -- 398
		while i < #p.room.floors do -- 398
			local f = p.room.floors[i + 1] -- 399
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 399
				g = f.y -- 401
			end -- 401
			i = i + 1 -- 398
		end -- 398
	end -- 398
	do -- 398
		i = 0 -- 404
		while i < #p.boxes do -- 404
			do -- 404
				local b = p.boxes[i + 1] -- 405
				if b.broken == true or b.hidden == true or b.soft == true then -- 405
					goto __continue46 -- 407
				end -- 407
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 407
					g = b.y1 -- 411
				end -- 411
			end -- 411
			::__continue46:: -- 411
			i = i + 1 -- 404
		end -- 404
	end -- 404
	return g -- 414
end -- 394
function ActorsRenderer.prototype.drawGroundedShadow(self, overlayDraw, assets, shadowKey, cx, by, shadowY, wPx, airHeightWorld, actorLayer, depthScale, isControlled) -- 418
	local airborne = airHeightWorld > 1.5 -- 431
	local heightShrink = airborne and math.max(0.54, 1 / (1 + airHeightWorld / 82)) or 1 -- 432
	local shW = math.max(16, wPx * 1.48 * heightShrink) -- 433
	local shH = math.max(6, wPx * 0.42 * heightShrink) -- 434
	assets:tryPlace( -- 435
		airborne and "dp_shadow_air" or "dp_shadow_contact", -- 435
		shadowKey, -- 435
		cx, -- 435
		shadowY + 1, -- 435
		shW, -- 435
		shH, -- 435
		{layer = actorLayer - 1, opacity = airborne and 0.88 or (isControlled and 0.92 or 0.82)} -- 435
	) -- 435
	if airborne then -- 435
		local tickTop = math.min( -- 441
			by - 2, -- 441
			shadowY + math.max(6, (by - shadowY) * 0.35) -- 441
		) -- 441
		if tickTop > shadowY + 3 then -- 441
			overlayDraw:drawSegment( -- 443
				Vec2(cx, shadowY + 2), -- 443
				Vec2(cx, tickTop), -- 443
				1.1, -- 443
				Color(148, 178, 202, 118) -- 443
			) -- 443
		end -- 443
	elseif isControlled then -- 443
		local rx = shW * 0.38 -- 447
		local ry = math.max(2.2, shH * 0.32) -- 448
		local ring = {} -- 449
		do -- 449
			local i = 0 -- 450
			while i < 12 do -- 450
				local ang = i / 12 * math.pi * 2 -- 451
				ring[#ring + 1] = Vec2( -- 452
					cx + math.cos(ang) * rx, -- 452
					shadowY + 1 + math.sin(ang) * ry -- 452
				) -- 452
				i = i + 1 -- 450
			end -- 450
		end -- 450
		overlayDraw:drawPolygon( -- 454
			ring, -- 454
			Color(0, 0, 0, 0), -- 454
			0.9, -- 454
			Color( -- 454
				146, -- 454
				178, -- 454
				200, -- 454
				math.floor(74 * depthScale + 0.5) -- 454
			) -- 454
		) -- 454
	end -- 454
end -- 418
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 459
	if bodyPlaced == nil then -- 459
		bodyPlaced = false -- 467
	end -- 467
	local cx = cam:sx(a.x) -- 469
	local by = cam:sy(a.y, a.depth) -- 470
	local depthEnabled = p.room.depth ~= nil -- 471
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 472
	local shadowY = not a.onGround and cam:sy(groundY, a.depth) or by -- 473
	local airH = math.max(0, a.y - groundY) -- 474
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 475
	local H = cam:len(a.h) * dScale -- 476
	local W = cam:len(a.w) * dScale -- 477
	local f = a.facing -- 478
	local speed = math.max( -- 479
		math.abs(a.vx), -- 479
		math.abs(a.depthSpeed) -- 479
	) -- 479
	local motion = isControlled and self.anim.player or self.anim.partner -- 480
	local juice = motion:sampleJuice(cam.ppu) -- 481
	local drawX = cx + juice.offsetX * dScale -- 482
	local actorLayer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 483
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 484
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 485
	local depthTint = depthEnabled and a.depth > 6 and Color( -- 486
		tone, -- 486
		tone, -- 486
		math.min(255, tone + 8), -- 486
		255 -- 486
	) or nil -- 486
	local hitTint = juice.hitFlash > 0.12 and Color( -- 487
		255, -- 488
		math.floor(230 - 38 * juice.hitFlash + 0.5), -- 488
		math.floor(212 - 44 * juice.hitFlash + 0.5), -- 488
		255 -- 488
	) or depthTint -- 488
	self:drawGroundedShadow( -- 491
		fgDraw, -- 491
		assets, -- 491
		"shadow_soldier", -- 491
		cx, -- 491
		by, -- 491
		shadowY, -- 491
		W, -- 491
		airH, -- 491
		actorLayer, -- 491
		dScale, -- 491
		isControlled -- 491
	) -- 491
	if bodyPlaced then -- 491
		return -- 493
	end -- 493
	local slot = "soldier_idle" -- 496
	local animClip = "" -- 497
	local height = H -- 498
	local frame = 0 -- 499
	local facing = f -- 500
	local extraScaleY = 1 -- 501
	local step = math.floor(self.animTime * 10) -- 502
	local ____isControlled_9 -- 503
	if isControlled then -- 503
		____isControlled_9 = self.playerStride -- 503
	else -- 503
		____isControlled_9 = self.partnerStride -- 503
	end -- 503
	local gait = ____isControlled_9 -- 503
	if isControlled and p.ticks < self.hitUntil then -- 503
		slot = "soldier_hit" -- 506
		local elapsed = math.max(0, p.ticks - self.hitStartTick) -- 507
		animClip = ZS_HIT_CLIPS[(elapsed < 7 and 0 or 1) + 1] -- 508
	elseif a.rollT > 0 then -- 508
		slot = "soldier_slide" -- 510
		local progress = self:slidePhase(a) -- 511
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 512
	elseif p.phase == "prologue-give" then -- 512
		slot = "soldier_offer" -- 514
		height = height * 0.75 -- 515
		facing = p.partner.x >= a.x and 1 or -1 -- 516
	elseif isControlled and p.gripping then -- 516
		slot = "soldier_push" -- 518
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 519
		local pushIdx = self.cartMoving and math.floor(motion.pushCycle * 4) % 4 or 0 -- 520
		animClip = ZS_PUSH_CLIPS[pushIdx + 1] -- 521
		frame = self.cartMoving and step or 0 -- 522
		height = height * 0.91 -- 523
	elseif isControlled and p.escort.state == "calming" then -- 523
		slot = "soldier_knock" -- 525
		local calm = p.escort.calmTick -- 526
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 527
		height = height * 0.76 -- 528
	else -- 528
		local ____temp_12 = p.phase == "gate-send" -- 529
		if ____temp_12 then -- 529
			local ____opt_10 = p.room.story -- 529
			____temp_12 = (____opt_10 and ____opt_10.gate) ~= nil -- 529
		end -- 529
		if ____temp_12 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 529
			slot = "soldier_hold" -- 531
		elseif isControlled and p.ticks < self.shotUntil then -- 531
			local running = speed > 8 -- 533
			slot = running and "soldier_fire_move" or "soldier_fire" -- 534
			frame = running and step or 0 -- 535
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 536
			if not running then -- 536
				local elapsed = math.max(0, p.ticks - self.shotStartTick) -- 538
				local fIdx = elapsed < 2 and 0 or (elapsed < 5 and 1 or (elapsed < 11 and 2 or 3)) -- 539
				animClip = ZS_FIRE_CLIPS[fIdx + 1] -- 540
			end -- 540
		elseif a.covered or isControlled and p.coverHug then -- 540
			slot = "soldier_cover" -- 543
			animClip = ZS_COVER_CLIPS[math.floor(motion.coverTime * 2.2) % 2 + 1] -- 544
			extraScaleY = 1 + math.sin(motion.coverTime * 3.1) * 0.012 -- 545
			height = height * 0.77 -- 546
		elseif not a.onGround then -- 546
			local jIdx = a.vy > 110 and 0 or (a.vy > -35 and 1 or 2) -- 548
			animClip = ZS_JUMP_CLIPS[jIdx + 1] -- 549
		elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 549
			animClip = ZS_JUMP_CLIPS[4] -- 551
		elseif (gait and gait.speed or 0) > 8 then -- 551
			slot = "soldier_run" -- 553
			frame = step -- 554
		elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 554
			local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.4) % #IDLE_PING_PONG + 1] -- 556
			if beat >= 0 then -- 556
				animClip = ZS_IDLE_CLIPS[beat + 1] -- 558
			end -- 558
			extraScaleY = 1 + math.sin(motion.idleTime * 2.4) * 0.008 -- 560
		end -- 560
	end -- 560
	local pose = { -- 562
		facing = facing, -- 563
		frame = frame, -- 564
		layer = actorLayer, -- 565
		angle = juice.angleOffset, -- 566
		scaleXMul = juice.scaleXMul, -- 567
		scaleYMul = juice.scaleYMul * extraScaleY, -- 568
		color = hitTint -- 569
	} -- 569
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 571
		"actor_soldier", -- 572
		cx, -- 572
		by, -- 572
		W, -- 572
		height, -- 572
		self:slidePhase(a), -- 572
		{facing = facing, layer = actorLayer, color = hitTint} -- 572
	) -- 572
	local running = animClip == "" and (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 573
		"soldier", -- 575
		"actor_soldier", -- 575
		cx, -- 575
		by, -- 575
		W, -- 575
		height, -- 575
		gait.cycle, -- 575
		pose, -- 575
		gait.effort -- 575
	) -- 575
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 576
		animClip, -- 576
		"actor_soldier", -- 576
		drawX, -- 576
		by, -- 576
		H, -- 576
		H, -- 576
		{ -- 576
			anchorX = 0.5, -- 577
			anchorY = 0, -- 578
			preserveAspect = true, -- 579
			facing = facing, -- 580
			angle = juice.angleOffset, -- 581
			scaleXMul = juice.scaleXMul, -- 582
			scaleYMul = juice.scaleYMul * extraScaleY, -- 583
			color = hitTint, -- 584
			layer = actorLayer -- 585
		} -- 585
	) -- 585
	if sliding or running or placedAnim or assets:tryPlace( -- 585
		slot, -- 587
		"actor_soldier", -- 587
		drawX, -- 587
		by, -- 587
		W, -- 587
		height, -- 587
		pose -- 587
	) then -- 587
		if juice.hitFlash > 0.35 then -- 587
			fillRadialGlow( -- 589
				fgGlow, -- 589
				drawX, -- 589
				by + H * 0.56, -- 589
				H * 0.38, -- 589
				H * 0.44, -- 589
				Color( -- 590
					255, -- 590
					224, -- 590
					198, -- 590
					math.floor(74 * juice.hitFlash + 0.5) -- 590
				), -- 590
				Color(214, 72, 56, 0), -- 590
				12 -- 590
			) -- 590
		end -- 590
		return -- 592
	end -- 592
	fgDraw:drawRect( -- 595
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 595
		Color(32, 46, 66, 220) -- 595
	) -- 595
end -- 459
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 599
	local cx = cam:sx(a.x) -- 608
	local by = cam:sy(a.y, a.depth) -- 609
	local depthEnabled = p.room.depth ~= nil -- 610
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 611
	local shadowY = not a.onGround and cam:sy(groundY, a.depth) or by -- 612
	local airH = math.max(0, a.y - groundY) -- 613
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 614
	local H = cam:len(a.h) * dScale -- 615
	local W = cam:len(a.w) * dScale -- 616
	local f = a.facing -- 617
	local speed = math.max( -- 618
		math.abs(a.vx), -- 618
		math.abs(a.depthSpeed) -- 618
	) -- 618
	local ____isControlled_19 -- 619
	if isControlled then -- 619
		____isControlled_19 = self.playerStride -- 619
	else -- 619
		____isControlled_19 = self.partnerStride -- 619
	end -- 619
	local gait = ____isControlled_19 -- 619
	local motion = isControlled and self.anim.player or self.anim.partner -- 620
	local juice = motion:sampleJuice(cam.ppu) -- 621
	local actorLayer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 622
	local afraid = not isControlled and p.escort.fear > 0 -- 624
	local slot = "child_idle" -- 625
	local animClip = "" -- 626
	local height = H -- 627
	local frame = 0 -- 628
	local extraScaleY = 1 -- 629
	local shiverX = 0 -- 630
	local step = math.floor(self.animTime * 10) -- 631
	local nearCover = __TS__ArraySome( -- 632
		p.room.solids, -- 632
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 632
			math.abs(a.x - solid.x), -- 635
			math.abs(a.x - solid.x - solid.w) -- 635
		) <= 30 end -- 635
	) -- 635
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 635
		slot = "child_knock" -- 638
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 638
		slot = "child_offer" -- 641
	elseif isControlled and p.ticks < self.throwUntil then -- 641
		slot = "child_throw" -- 643
		if p.ticks - self.throwStartTick < 7 then -- 643
			animClip = XM_THROW_REL_CLIP -- 645
		end -- 645
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 645
		slot = "child_aim" -- 648
	elseif isControlled and p.gripping then -- 648
		slot = "child_pull" -- 650
		if self.cartMoving then -- 650
			local pBeat = math.floor(motion.pushCycle * 4) % 4 -- 652
			if pBeat == 1 or pBeat == 3 then -- 652
				animClip = XM_PULL_MID_CLIP -- 654
			else -- 654
				frame = pBeat == 2 and 1 or 0 -- 656
			end -- 656
		end -- 656
	elseif afraid and p.escort.state == "frozen" then -- 656
		slot = "child_fear" -- 660
		height = height * 0.74 -- 661
		shiverX = math.sin(self.animTime * 42) * 1.4 -- 662
		if math.floor(self.animTime * 7) % 2 == 1 then -- 662
			animClip = XM_FEAR_B_CLIP -- 664
		end -- 664
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 664
		slot = "child_peek" -- 668
		height = height * 0.83 -- 669
		if math.floor(self.animTime * 2.2) % 2 == 1 then -- 669
			animClip = XM_PEEK_B_CLIP -- 671
		end -- 671
	elseif a.crouch then -- 671
		slot = "child_crouch" -- 674
		local crawlIdx = speed > 6 and math.floor(motion.crouchCycle * 4) % 4 or 0 -- 675
		animClip = XM_CRAWL_CLIPS[crawlIdx + 1] -- 676
		frame = speed > 8 and step or 0 -- 677
	elseif not a.onGround then -- 677
		local jIdx = a.vy > 100 and 0 or (a.vy > -30 and 1 or 2) -- 679
		animClip = XM_JUMP_CLIPS[jIdx + 1] -- 680
	elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 680
		animClip = XM_JUMP_CLIPS[4] -- 682
	elseif (gait and gait.speed or 0) > 8 then -- 682
		slot = "child_run" -- 684
		frame = step -- 685
	elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 685
		local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.2) % #IDLE_PING_PONG + 1] -- 687
		if beat >= 0 then -- 687
			animClip = XM_IDLE_CLIPS[beat + 1] -- 689
		end -- 689
		extraScaleY = 1 + math.sin(motion.idleTime * 2.8) * 0.01 -- 691
	end -- 691
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 694
	local drawX = cx + (juice.offsetX + shiverX) * dScale -- 695
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 696
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 697
	local depthTint = depthEnabled and a.depth > 6 and Color( -- 698
		tone, -- 698
		tone, -- 698
		math.min(255, tone + 6), -- 698
		255 -- 698
	) or nil -- 698
	local pose = { -- 699
		facing = facing, -- 700
		frame = frame, -- 701
		layer = actorLayer, -- 702
		angle = juice.angleOffset, -- 703
		scaleXMul = juice.scaleXMul, -- 704
		scaleYMul = juice.scaleYMul * extraScaleY, -- 705
		color = depthTint -- 706
	} -- 706
	self:drawGroundedShadow( -- 708
		fgDraw, -- 708
		assets, -- 708
		"shadow_child", -- 708
		cx, -- 708
		by, -- 708
		shadowY, -- 708
		W, -- 708
		airH, -- 708
		actorLayer, -- 708
		dScale, -- 708
		isControlled -- 708
	) -- 708
	local running = animClip == "" and (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 709
		"child", -- 711
		"actor_child", -- 711
		cx, -- 711
		by, -- 711
		W, -- 711
		height, -- 711
		gait.cycle, -- 711
		pose, -- 711
		gait.effort -- 711
	) -- 711
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 712
		animClip, -- 712
		"actor_child", -- 712
		drawX, -- 712
		by, -- 712
		H, -- 712
		H, -- 712
		{ -- 712
			anchorX = 0.5, -- 713
			anchorY = 0, -- 714
			preserveAspect = true, -- 715
			facing = facing, -- 716
			angle = juice.angleOffset, -- 717
			scaleXMul = juice.scaleXMul, -- 718
			scaleYMul = juice.scaleYMul * extraScaleY, -- 719
			color = depthTint, -- 720
			layer = actorLayer -- 721
		} -- 721
	) -- 721
	if running or placedAnim or assets:tryPlace( -- 721
		slot, -- 723
		"actor_child", -- 723
		drawX, -- 723
		by, -- 723
		W, -- 723
		height, -- 723
		pose -- 723
	) then -- 723
		if afraid then -- 723
			self:drawFear(fgGlow, p, cx, by + H + 14) -- 725
		end -- 725
		return -- 727
	end -- 727
	fgDraw:drawRect( -- 729
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 729
		Color(168, 126, 72, 220) -- 729
	) -- 729
	if afraid then -- 729
		self:drawFear(fgGlow, p, cx, by + H + 16) -- 731
	end -- 731
end -- 599
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 735
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 736
	do -- 736
		local i = 0 -- 737
		while i < FEAR_MAX do -- 737
			local lit = i < p.escort.fear -- 738
			drawDiamond( -- 739
				fgGlow, -- 739
				x + (i - 1) * 13, -- 739
				y, -- 739
				4, -- 739
				5, -- 739
				toColor(lit and tint or PALETTE.steelDark, 215), -- 740
				1, -- 740
				toColor(tint, lit and 235 or 100) -- 740
			) -- 740
			i = i + 1 -- 737
		end -- 737
	end -- 737
end -- 735
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 744
	local x = cam:sx(e.x + f * 20) -- 745
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 746
	local dx = cam:sx(p.player.x) - x -- 747
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 748
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 749
	do -- 749
		local i = 0 -- 750
		while i < 8 do -- 750
			local a = length * i / 8 -- 751
			local b = length * (i + 1) / 8 -- 752
			fgGlow:drawSegment( -- 753
				Vec2(x + dx * a, y + dy * a), -- 753
				Vec2(x + dx * b, y + dy * b), -- 753
				1.3, -- 754
				Color(220, 120, 88, 210) -- 754
			) -- 754
			i = i + 2 -- 750
		end -- 750
	end -- 750
end -- 744
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 759
	local cx = cam:sx(e.x) -- 768
	local depth = e.depth or 0 -- 769
	local depthEnabled = p.room.depth ~= nil -- 770
	local dScale = cam:depthScale(depth, depthEnabled) -- 771
	local by = cam:sy(e.y, depth) -- 772
	local H = cam:len(e.h) * dScale -- 773
	local W = cam:len(e.w) * dScale -- 774
	local f = p.player.x >= e.x and 1 or -1 -- 775
	if e.kind == "target" then -- 775
		local targetLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 779
		self:drawGroundedShadow( -- 780
			fgDraw, -- 780
			assets, -- 780
			"shadow_target_" .. tostring(index), -- 780
			cx, -- 780
			by, -- 780
			by, -- 780
			W * 1.1, -- 780
			0, -- 780
			targetLayer, -- 780
			dScale, -- 780
			false -- 780
		) -- 780
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 781
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 782
		assets:tryPlacePath( -- 783
			"assets/art/props_ming.clip|target_dummy", -- 783
			"actor_target_" .. tostring(index), -- 783
			cx, -- 783
			by, -- 783
			H * 0.82, -- 783
			H * 0.96, -- 783
			{ -- 783
				anchorX = 0.5, -- 784
				anchorY = 0, -- 785
				preserveAspect = true, -- 786
				angle = angle, -- 787
				color = tint, -- 788
				opacity = e.alive and 1 or 0.76, -- 789
				layer = targetLayer -- 790
			} -- 790
		) -- 790
		return -- 792
	end -- 792
	local enemyLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 795
	if e.alive then -- 795
		self:drawGroundedShadow( -- 797
			fgDraw, -- 797
			assets, -- 797
			"shadow_enemy_" .. tostring(index), -- 797
			cx, -- 797
			by, -- 797
			by, -- 797
			W * 1.05, -- 797
			0, -- 797
			enemyLayer, -- 797
			dScale, -- 797
			false -- 797
		) -- 797
	else -- 797
		assets:tryPlace( -- 799
			"dp_shadow_contact", -- 799
			"shadow_enemy_" .. tostring(index), -- 799
			cx, -- 799
			by + 1, -- 799
			math.max(18, W * 1.65), -- 799
			math.max(6, W * 0.42), -- 799
			{layer = enemyLayer - 1, opacity = 0.56} -- 799
		) -- 799
	end -- 799
	local es = index < #self.anim.enemies and self.anim.enemies[index + 1] or nil -- 804
	local moving = (es and es.speed or 0) > 6 -- 805
	local walkStep = math.floor((es and es.walkCycle or 0) * 4) % 2 -- 806
	local hitFlash = es ~= nil and es.hitFlash or 0 -- 807
	local dying = not e.alive and (es and es.deathTime or 1) < 0.15 -- 808
	local breathY = e.alive and not moving and e.hitT <= 0 and 1 + math.sin(self.animTime * 2.4 + (es and es.idlePhase or index)) * 0.014 or 1 -- 809
	local knockX = (e.hitT > 0 or dying) and -f * cam:len(3.5 * math.max(0.3, hitFlash)) * dScale or 0 -- 812
	local hitAngle = (e.hitT > 0 or dying) and -f * 5.5 or 0 -- 813
	local dShade = cam:depthShade(depth, depthEnabled) -- 814
	local shadeMul = depthEnabled and depth > 6 and math.min(1, dShade + 0.06) or 1 -- 815
	local baseTone = math.floor(255 * shadeMul + 0.5) -- 816
	local enemyClip = "" -- 817
	local enemyTint = hitFlash > 0.12 and Color( -- 818
		255, -- 819
		math.floor(220 - 42 * hitFlash + 0.5), -- 819
		math.floor(196 - 52 * hitFlash + 0.5), -- 819
		255 -- 819
	) or Color( -- 819
		baseTone, -- 820
		baseTone, -- 820
		math.min(255, baseTone + (depthEnabled and depth > 6 and 8 or 0)), -- 820
		255 -- 820
	) -- 820
	local drawHeight = H * 1.01 -- 821
	local cleaving = false -- 822
	if e.kind == "shield" and ((e.shieldHp or 0) > 0 or not e.alive or e.hitT > 0) then -- 822
		if not e.alive then -- 822
			enemyClip = dying and EN_SHD_HIT_CLIP or EN_GUN_DOWN_CLIP -- 826
		elseif e.hitT > 0 then -- 826
			enemyClip = EN_SHD_HIT_CLIP -- 828
		elseif e.warnT > 0 then -- 828
			enemyClip = EN_SHD_BASH_CLIP -- 830
		elseif moving then -- 830
			enemyClip = walkStep == 0 and EN_SHD_WALK_CLIP or EN_SHD_IDLE_CLIP -- 832
		else -- 832
			enemyClip = EN_SHD_IDLE_CLIP -- 834
		end -- 834
		if e.alive and (e.shieldHp or 2) <= 1 and hitFlash <= 0.12 then -- 834
			enemyTint = Color( -- 837
				math.floor(238 * shadeMul + 0.5), -- 837
				math.floor(198 * shadeMul + 0.5), -- 837
				math.floor(174 * shadeMul + 0.5), -- 837
				255 -- 837
			) -- 837
		end -- 837
	elseif e.kind == "breaker" then -- 837
		drawHeight = H * 1.03 -- 840
		if not e.alive then -- 840
			enemyClip = dying and EN_BRK_HIT_CLIP or EN_GUN_DOWN_CLIP -- 842
		elseif e.hitT > 0 then -- 842
			enemyClip = EN_BRK_HIT_CLIP -- 844
		elseif (e.swingT or 0) > 0 then -- 844
			cleaving = (es and es.swingTime or 0) >= 0.12 -- 846
			enemyClip = cleaving and EN_BRK_CLEAVE_CLIP or EN_BRK_WINDUP_CLIP -- 847
		elseif e.warnT > 0 then -- 847
			enemyClip = EN_BRK_WINDUP_CLIP -- 849
		else -- 849
			enemyClip = EN_BRK_WALK_CLIP -- 851
		end -- 851
	elseif e.kind == "leader" then -- 851
		drawHeight = H * 1.04 -- 854
		if not e.alive then -- 854
			enemyClip = dying and EN_LDR_HIT_CLIP or EN_GUN_DOWN_CLIP -- 856
		elseif e.hitT > 0 then -- 856
			enemyClip = EN_LDR_HIT_CLIP -- 858
		elseif e.warnT > 0 then -- 858
			enemyClip = EN_LDR_AIM_CLIP -- 860
		elseif moving then -- 860
			enemyClip = walkStep == 0 and EN_LDR_WALK_CLIP or EN_LDR_IDLE_CLIP -- 862
		else -- 862
			enemyClip = EN_LDR_IDLE_CLIP -- 864
		end -- 864
	else -- 864
		if not e.alive then -- 864
			enemyClip = dying and EN_GUN_HIT_CLIP or EN_GUN_DOWN_CLIP -- 869
		elseif e.hitT > 0 then -- 869
			enemyClip = EN_GUN_HIT_CLIP -- 871
		elseif e.warnT > 0 then -- 871
			enemyClip = e.warnT <= 6 and EN_GUN_FIRE_CLIP or EN_GUN_AIM_CLIP -- 873
		elseif moving then -- 873
			enemyClip = EN_GUN_WALK_CLIPS[walkStep + 1] -- 875
		else -- 875
			enemyClip = EN_GUN_IDLE_CLIP -- 877
		end -- 877
	end -- 877
	if enemyClip ~= "" and assets:tryPlacePath( -- 877
		enemyClip, -- 882
		"actor_enemy_" .. tostring(index), -- 883
		cx + knockX, -- 884
		by, -- 885
		drawHeight, -- 886
		drawHeight, -- 887
		{ -- 888
			anchorX = 0.5, -- 889
			anchorY = 0, -- 890
			preserveAspect = true, -- 891
			facing = f, -- 892
			angle = hitAngle, -- 893
			scaleYMul = breathY, -- 894
			color = enemyTint, -- 895
			opacity = e.alive and 1 or 0.78, -- 896
			layer = enemyLayer -- 897
		} -- 897
	) then -- 897
		if hitFlash > 0.35 then -- 897
			fillRadialGlow( -- 901
				fgGlow, -- 901
				cx + knockX, -- 901
				by + H * 0.54, -- 901
				H * 0.34, -- 901
				H * 0.38, -- 901
				Color( -- 902
					255, -- 902
					224, -- 902
					186, -- 902
					math.floor(78 * hitFlash + 0.5) -- 902
				), -- 902
				Color(214, 72, 52, 0), -- 902
				12 -- 902
			) -- 902
		end -- 902
		if cleaving then -- 902
			fgGlow:drawArc( -- 905
				Vec2( -- 905
					cx + f * cam:len(12), -- 905
					by + H * 0.56 -- 905
				), -- 905
				cam:len(22), -- 905
				f > 0 and -48 or 132, -- 905
				f > 0 and 54 or 234, -- 905
				2.4, -- 905
				toColor(PALETTE.sealRedBright, 215) -- 905
			) -- 905
			fgGlow:drawArc( -- 906
				Vec2( -- 906
					cx + f * cam:len(12), -- 906
					by + H * 0.56 -- 906
				), -- 906
				cam:len(18), -- 906
				f > 0 and -40 or 140, -- 906
				f > 0 and 48 or 228, -- 906
				1.4, -- 906
				toColor(PALETTE.amberCore, 185) -- 906
			) -- 906
		end -- 906
		if e.alive and e.warnT > 0 then -- 906
			self:drawEnemyWarning( -- 909
				fgGlow, -- 909
				e, -- 909
				p, -- 909
				cam, -- 909
				f -- 909
			) -- 909
		end -- 909
		return -- 911
	end -- 911
	local slot = "enemy_idle" -- 914
	if not e.alive then -- 914
		slot = "enemy_down" -- 916
	elseif e.hitT > 0 then -- 916
		slot = "enemy_hit" -- 918
	elseif e.warnT > 0 then -- 918
		slot = "enemy_aim" -- 920
	end -- 920
	local height = e.alive and H or H * 0.24 -- 922
	if assets:tryPlace( -- 922
		slot, -- 923
		"actor_enemy_" .. tostring(index), -- 923
		cx, -- 923
		by, -- 923
		W, -- 923
		height, -- 923
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 923
	) then -- 923
		if e.alive then -- 923
			self:drawEnemyArchetypeGear( -- 927
				fgDraw, -- 927
				fgGlow, -- 927
				assets, -- 927
				e, -- 927
				index, -- 927
				cx, -- 927
				by, -- 927
				H, -- 927
				f, -- 927
				cam, -- 927
				enemyLayer + 1 -- 927
			) -- 927
			if e.warnT > 0 then -- 927
				self:drawEnemyWarning( -- 929
					fgGlow, -- 929
					e, -- 929
					p, -- 929
					cam, -- 929
					f -- 929
				) -- 929
			end -- 929
		end -- 929
		return -- 932
	end -- 932
	if e.alive then -- 932
		fgDraw:drawRect( -- 935
			Rect(cx - W * 0.4, by, W * 0.8, height), -- 935
			Color(96, 56, 48, 220) -- 935
		) -- 935
	end -- 935
end -- 759
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 940
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 940
		local shX = cx + f * cam:len(13) -- 954
		local cracked = (e.shieldHp or 2) <= 1 -- 955
		if not assets:tryPlace( -- 955
			"fe_gear_rattan_shield", -- 956
			"enemy_shield_" .. tostring(index), -- 956
			shX, -- 956
			by + H * 0.44, -- 956
			cam:len(22), -- 956
			H * 0.64, -- 956
			{ -- 956
				facing = f, -- 957
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 958
				layer = layer -- 959
			} -- 959
		) then -- 959
			local shW = math.max( -- 961
				5, -- 961
				cam:len(8) -- 961
			) -- 961
			fgDraw:drawRect( -- 962
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 962
				Color(96, 66, 42, 250), -- 962
				1.3, -- 962
				Color(168, 174, 180, 230) -- 962
			) -- 962
		end -- 962
		if cracked then -- 962
			fgDraw:drawSegment( -- 965
				Vec2( -- 965
					shX - cam:len(4), -- 965
					by + H * 0.3 -- 965
				), -- 965
				Vec2( -- 965
					shX + cam:len(4), -- 965
					by + H * 0.56 -- 965
				), -- 965
				1.4, -- 965
				Color(24, 18, 16, 235) -- 965
			) -- 965
		end -- 965
	elseif e.kind == "breaker" then -- 965
		local swing = (e.swingT or 0) > 0 -- 968
		local handleX0 = cx - f * cam:len(4) -- 969
		local handleY0 = by + H * 0.44 -- 970
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 971
		local tipY = by + H * (swing and 0.46 or 0.78) -- 972
		fgDraw:drawSegment( -- 973
			Vec2(handleX0, handleY0), -- 973
			Vec2(tipX, tipY), -- 973
			math.max( -- 973
				2.2, -- 973
				cam:len(3) -- 973
			), -- 973
			Color(98, 66, 44, 255) -- 973
		) -- 973
		fgDraw:drawPolygon( -- 974
			{ -- 974
				Vec2( -- 975
					tipX - f * cam:len(3), -- 975
					tipY - cam:len(4) -- 975
				), -- 975
				Vec2( -- 976
					tipX + f * cam:len(9), -- 976
					tipY - cam:len(1) -- 976
				), -- 976
				Vec2( -- 977
					tipX + f * cam:len(7), -- 977
					tipY + cam:len(9) -- 977
				), -- 977
				Vec2( -- 978
					tipX - f * cam:len(2), -- 978
					tipY + cam:len(6) -- 978
				) -- 978
			}, -- 978
			Color(148, 154, 162, 250), -- 979
			1, -- 979
			Color(224, 228, 232, 220) -- 979
		) -- 979
		if swing then -- 979
			fgGlow:drawArc( -- 981
				Vec2( -- 981
					cx + f * cam:len(10), -- 981
					by + H * 0.56 -- 981
				), -- 981
				cam:len(18), -- 981
				f > 0 and -40 or 140, -- 981
				f > 0 and 50 or 230, -- 981
				1.8, -- 981
				toColor(PALETTE.rouge, 195) -- 981
			) -- 981
		end -- 981
	elseif e.kind == "leader" then -- 981
		local topY = by + H * 1.02 -- 985
		fgDraw:drawSegment( -- 986
			Vec2(cx, topY), -- 986
			Vec2( -- 986
				cx - f * cam:len(10), -- 986
				topY + cam:len(9) -- 986
			), -- 986
			2.2, -- 986
			toColor(PALETTE.rouge, 240) -- 986
		) -- 986
		fgDraw:drawDot( -- 987
			Vec2( -- 987
				cx - f * cam:len(10), -- 987
				topY + cam:len(9) -- 987
			), -- 987
			2.6, -- 987
			toColor(PALETTE.crimsonCore, 235) -- 987
		) -- 987
	end -- 987
end -- 940
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 992
	local s = p.room.scavenger -- 999
	if s == nil then -- 999
		return -- 1001
	end -- 1001
	local cx = cam:sx(p.scavX) -- 1003
	local by = cam:sy(s.y) -- 1004
	local H = cam:len(s.h) -- 1005
	local W = cam:len(26) -- 1006
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 1007
	local alert = p.scavChase or p.scavSee > 0 -- 1010
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 1011
	local eyeY = by + H * 0.8 -- 1012
	local coneLen = cam:len(alert and 155 or 115) -- 1013
	fgGlow:drawVertices({ -- 1014
		{ -- 1015
			Vec2(cx + f * 6, eyeY), -- 1015
			toColor(coneCol, alert and 78 or 34) -- 1015
		}, -- 1015
		{ -- 1016
			Vec2(cx + f * coneLen, by + H * 1.05), -- 1016
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1016
		}, -- 1016
		{ -- 1017
			Vec2(cx + f * coneLen, by + 4), -- 1017
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1017
		} -- 1017
	}) -- 1017
	local scavClip = SCAV_WALK_CLIPS[1] -- 1020
	local frame = 0 -- 1021
	if p.scavState == "turn" then -- 1021
		scavClip = SCAV_TURN_CLIP -- 1023
		frame = 2 -- 1024
	elseif p.scavState == "chase" then -- 1024
		local runBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1026
		scavClip = runBeat == 0 and SCAV_RUN_CLIP or SCAV_WALK_CLIPS[2] -- 1027
		frame = runBeat == 0 and 3 or 1 -- 1028
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 1028
		local walkBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1030
		scavClip = SCAV_WALK_CLIPS[walkBeat + 1] -- 1031
		frame = walkBeat -- 1032
	end -- 1032
	local scavBreath = (p.scavState == "stall" or p.scavState == "turn") and 1 + math.sin(self.animTime * 2.5) * 0.012 or 1 -- 1034
	self:drawGroundedShadow( -- 1037
		fgDraw, -- 1037
		assets, -- 1037
		"shadow_scav", -- 1037
		cx, -- 1037
		by, -- 1037
		by, -- 1037
		W * 0.96, -- 1037
		0, -- 1037
		3, -- 1037
		1, -- 1037
		false -- 1037
	) -- 1037
	if assets:tryPlacePath( -- 1037
		scavClip, -- 1038
		"actor_scav", -- 1038
		cx, -- 1038
		by, -- 1038
		H, -- 1038
		H, -- 1038
		{ -- 1038
			anchorX = 0.5, -- 1039
			anchorY = 0, -- 1040
			preserveAspect = true, -- 1041
			facing = f, -- 1042
			scaleYMul = scavBreath, -- 1043
			layer = 3 -- 1044
		} -- 1044
	) or assets:tryPlace( -- 1044
		"scavenger", -- 1045
		"actor_scav", -- 1045
		cx, -- 1045
		by, -- 1045
		W, -- 1045
		H, -- 1045
		{facing = f, frame = frame, layer = 3} -- 1045
	) then -- 1045
		local indY = by + H + 16 -- 1046
		if p.scavChase then -- 1046
			drawDiamond( -- 1048
				fgGlow, -- 1048
				cx, -- 1048
				indY, -- 1048
				8, -- 1048
				11, -- 1048
				toColor(PALETTE.crimson, 240), -- 1048
				1.4, -- 1048
				toColor(PALETTE.crimsonCore) -- 1048
			) -- 1048
		elseif p.scavSee > 0 then -- 1048
			local frac = math.min(1, p.scavSee / 24) -- 1050
			fgGlow:drawArc( -- 1051
				Vec2(cx, indY), -- 1051
				10, -- 1051
				90, -- 1051
				90 - 360 * frac, -- 1051
				2.2, -- 1051
				toColor(PALETTE.crimson, 235) -- 1051
			) -- 1051
			fgGlow:drawDot( -- 1052
				Vec2(cx, indY), -- 1052
				2.8, -- 1052
				toColor(PALETTE.amber) -- 1052
			) -- 1052
		elseif p.scavState == "turn" then -- 1052
			drawDiamond( -- 1054
				fgGlow, -- 1054
				cx, -- 1054
				indY, -- 1054
				5.5, -- 1054
				7.5, -- 1054
				toColor(PALETTE.amber, 220) -- 1054
			) -- 1054
		end -- 1054
		return -- 1056
	end -- 1056
	fgDraw:drawEllipse( -- 1059
		Vec2(cx, by + 1), -- 1059
		W * 0.62, -- 1059
		4, -- 1059
		Color(4, 6, 10, 155) -- 1059
	) -- 1059
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1060
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 1061
	fgDraw:drawSegment( -- 1063
		Vec2(cx - 4, by + H * 0.4), -- 1063
		Vec2(cx - stride, by + 2), -- 1063
		W * 0.16, -- 1063
		Color(32, 30, 28, 255) -- 1063
	) -- 1063
	fgDraw:drawSegment( -- 1064
		Vec2(cx + 4, by + H * 0.4), -- 1064
		Vec2(cx + stride, by + 2), -- 1064
		W * 0.16, -- 1064
		Color(44, 40, 36, 255) -- 1064
	) -- 1064
	fgDraw:drawPolygon( -- 1066
		{ -- 1066
			Vec2(cx - W * 0.45, by + H * 0.25), -- 1067
			Vec2(cx + W * 0.42, by + H * 0.25), -- 1068
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 1069
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 1070
		}, -- 1070
		Color(56, 52, 46, 255), -- 1071
		1.2, -- 1071
		Color(128, 118, 100, 180) -- 1071
	) -- 1071
	local headX = cx + f * 5 -- 1073
	local headY = by + H * 0.88 -- 1074
	fgDraw:drawCircle( -- 1075
		Vec2(headX, headY), -- 1075
		W * 0.3, -- 1075
		Color(42, 38, 34, 255) -- 1075
	) -- 1075
	fgGlow:drawDot( -- 1076
		Vec2(headX + f * 6, headY), -- 1076
		3, -- 1076
		toColor(coneCol, 245) -- 1076
	) -- 1076
	local indY = by + H + 18 -- 1079
	if p.scavChase then -- 1079
		drawDiamond( -- 1081
			fgGlow, -- 1081
			cx, -- 1081
			indY, -- 1081
			9, -- 1081
			12, -- 1081
			toColor(PALETTE.crimson, 240), -- 1081
			1.5, -- 1081
			toColor(PALETTE.crimsonCore) -- 1081
		) -- 1081
	elseif p.scavSee > 0 then -- 1081
		local frac = math.min(1, p.scavSee / 24) -- 1083
		fgGlow:drawArc( -- 1084
			Vec2(cx, indY), -- 1084
			11, -- 1084
			90, -- 1084
			90 - 360 * frac, -- 1084
			2.4, -- 1084
			toColor(PALETTE.crimson, 235) -- 1084
		) -- 1084
		fgGlow:drawDot( -- 1085
			Vec2(cx, indY), -- 1085
			3, -- 1085
			toColor(PALETTE.amber) -- 1085
		) -- 1085
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 1085
		drawDiamond( -- 1087
			fgGlow, -- 1087
			cx, -- 1087
			indY, -- 1087
			6, -- 1087
			8, -- 1087
			toColor(PALETTE.amber, 220) -- 1087
		) -- 1087
	end -- 1087
end -- 992
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 1092
	local cx = cam:sx(p.dogX) -- 1099
	local by = cam:sy(0) -- 1100
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 1101
	local W = cam:len(34) -- 1102
	local H = cam:len(28) -- 1103
	local dogClip = DOG_WALK_CLIP -- 1105
	local frame = 0 -- 1106
	if p.dogState == "ear" then -- 1106
		dogClip = DOG_ALERT_CLIP -- 1108
		frame = 1 -- 1109
	elseif p.dogState == "sniff" then -- 1109
		dogClip = DOG_WALK_CLIP -- 1111
		frame = 3 -- 1112
	elseif p.dogState == "chase" then -- 1112
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1114
		dogClip = DOG_RUN_CLIPS[beat + 1] -- 1115
		frame = beat == 0 and 0 or 2 -- 1116
	elseif p.dogState == "patrol" or p.dogState == "back" then -- 1116
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1118
		dogClip = beat == 0 and DOG_WALK_CLIP or DOG_RUN_CLIPS[2] -- 1119
		frame = beat == 0 and 0 or 2 -- 1120
	end -- 1120
	local dogH = H * 1.12 -- 1122
	self:drawGroundedShadow( -- 1123
		fgDraw, -- 1123
		assets, -- 1123
		"shadow_dog", -- 1123
		cx, -- 1123
		by, -- 1123
		by, -- 1123
		W * 0.92, -- 1123
		0, -- 1123
		3, -- 1123
		1, -- 1123
		false -- 1123
	) -- 1123
	if assets:tryPlacePath( -- 1123
		dogClip, -- 1124
		"actor_dog", -- 1124
		cx, -- 1124
		by, -- 1124
		dogH, -- 1124
		dogH, -- 1124
		{ -- 1124
			anchorX = 0.5, -- 1125
			anchorY = 0, -- 1126
			preserveAspect = true, -- 1127
			facing = f, -- 1128
			layer = 3 -- 1129
		} -- 1129
	) or assets:tryPlace( -- 1129
		"dog", -- 1130
		"actor_dog", -- 1130
		cx, -- 1130
		by, -- 1130
		W, -- 1130
		H, -- 1130
		{facing = f, frame = frame, layer = 3} -- 1130
	) then -- 1130
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 1131
		if alert then -- 1131
			local hx = cx + f * W * 0.34 -- 1133
			local hy = by + H * 0.86 -- 1134
			local r = 10 + self.animTime * 40 % 22 -- 1135
			fgGlow:drawArc( -- 1136
				Vec2(hx, hy + 8), -- 1136
				r, -- 1136
				35, -- 1136
				145, -- 1136
				1.6, -- 1136
				toColor(PALETTE.crimson, 200 * (1 - r / 34)) -- 1136
			) -- 1136
		end -- 1136
		return -- 1138
	end -- 1138
	fgDraw:drawEllipse( -- 1141
		Vec2(cx, by + 1), -- 1141
		W * 0.56, -- 1141
		3.5, -- 1141
		Color(4, 8, 10, 155) -- 1141
	) -- 1141
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 1142
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 1143
	fgDraw:drawSegment( -- 1146
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 1146
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 1146
		2.8, -- 1146
		Color(26, 30, 34, 255) -- 1146
	) -- 1146
	fgDraw:drawSegment( -- 1147
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 1147
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 1147
		2.8, -- 1147
		Color(36, 40, 44, 255) -- 1147
	) -- 1147
	fgDraw:drawPolygon( -- 1149
		{ -- 1149
			Vec2(cx - W * 0.42, by + H * 0.36), -- 1150
			Vec2(cx + W * 0.38, by + H * 0.42), -- 1151
			Vec2(cx + W * 0.34, by + H * 0.78), -- 1152
			Vec2(cx - W * 0.38, by + H * 0.72) -- 1153
		}, -- 1153
		Color(38, 42, 48, 255), -- 1154
		1.2, -- 1154
		Color(102, 118, 126, 175) -- 1154
	) -- 1154
	local hx = cx + f * W * 0.42 -- 1155
	local hy = by + H * 0.84 -- 1156
	fgDraw:drawPolygon( -- 1157
		{ -- 1157
			Vec2(hx - f * 8, hy - 6), -- 1158
			Vec2(hx + f * 12, hy - 2), -- 1159
			Vec2(hx + f * 4, hy + 8), -- 1160
			Vec2(hx - f * 6, hy + 14) -- 1161
		}, -- 1161
		Color(44, 48, 54, 255) -- 1162
	) -- 1162
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 1164
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 1165
	fgGlow:drawDot( -- 1166
		Vec2(hx + f * 4, hy + 2), -- 1166
		2.8, -- 1166
		toColor(eyeCol, 250) -- 1166
	) -- 1166
	fillRadialGlow( -- 1167
		fgGlow, -- 1167
		hx + f * 4, -- 1167
		hy + 2, -- 1167
		16, -- 1167
		16, -- 1167
		toColor(eyeCol, alert and 135 or 70), -- 1167
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 1167
		12 -- 1167
	) -- 1167
	if alert then -- 1167
		local r = 12 + self.animTime * 42 % 24 -- 1170
		fgGlow:drawArc( -- 1171
			Vec2(hx, hy + 12), -- 1171
			r, -- 1171
			35, -- 1171
			145, -- 1171
			1.8, -- 1171
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 1171
		) -- 1171
	end -- 1171
end -- 1092
return ____exports -- 1092