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
	if steps > 0 then -- 44
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
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 56
		stride.effort = 0 -- 57
		return -- 58
	end -- 58
	if stride.speed > 8 then -- 60
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
local EN_GUN_IDLE_CLIPS = {"assets/art/actors_enemies_anim.clip|en_gun_idle_0", "assets/art/actors_enemies_anim.clip|en_gun_idle_1"} -- 129
local EN_GUN_WALK_CLIPS = {"assets/art/actors_enemies_anim.clip|en_gun_walk_0", "assets/art/actors_enemies_anim.clip|en_gun_walk_1"} -- 133
local EN_GUN_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_aim" -- 137
local EN_GUN_FIRE_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_fire" -- 138
local EN_GUN_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_hit" -- 139
local EN_GUN_DOWN_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_down" -- 140
local EN_SHD_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_idle" -- 142
local EN_SHD_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_walk_0" -- 143
local EN_SHD_BASH_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_bash" -- 144
local EN_SHD_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_hit" -- 145
local EN_BRK_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_walk" -- 147
local EN_BRK_WINDUP_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_windup" -- 148
local EN_BRK_CLEAVE_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_cleave" -- 149
local EN_BRK_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_hit" -- 150
local EN_LDR_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_idle" -- 152
local EN_LDR_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_walk" -- 153
local EN_LDR_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_aim" -- 154
local EN_LDR_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_hit" -- 155
local SCAV_WALK_CLIPS = {"assets/art/actors_enemies_anim.clip|scav_walk_0", "assets/art/actors_enemies_anim.clip|scav_walk_1"} -- 157
local SCAV_TURN_CLIP = "assets/art/actors_enemies_anim.clip|scav_turn" -- 161
local SCAV_RUN_CLIP = "assets/art/actors_enemies_anim.clip|scav_run" -- 162
local DOG_WALK_CLIP = "assets/art/actors_enemies_anim.clip|dog_walk" -- 164
local DOG_ALERT_CLIP = "assets/art/actors_enemies_anim.clip|dog_alert" -- 165
local DOG_RUN_CLIPS = {"assets/art/actors_enemies_anim.clip|dog_run_0", "assets/art/actors_enemies_anim.clip|dog_run_1"} -- 166
local SLIDE_DUST_CLIPS = {"assets/art/vfx_ming_fx.clip|dust_0", "assets/art/vfx_ming_fx.clip|dust_1"} -- 171
local IDLE_PING_PONG = { -- 176
	-1, -- 176
	0, -- 176
	1, -- 176
	2, -- 176
	3, -- 176
	2, -- 176
	1, -- 176
	0 -- 176
} -- 176
____exports.ActorsRenderer = __TS__Class() -- 178
local ActorsRenderer = ____exports.ActorsRenderer -- 178
ActorsRenderer.name = "ActorsRenderer" -- 178
function ActorsRenderer.prototype.____constructor(self) -- 178
	self.slideDust = {} -- 179
	self.dustCooldown = 0 -- 180
	self.slideDuration = 0 -- 181
	self.slideRemainder = 0 -- 182
	self.strideTick = 0 -- 183
	self.anim = __TS__New(ActorAnimController) -- 186
	self.animTime = 0 -- 187
	self.previousHp = 3 -- 188
	self.previousAxle = 0 -- 189
	self.cartMoving = false -- 190
	self.previousBottle = false -- 191
	self.hitStartTick = 0 -- 193
	self.hitUntil = -1 -- 194
	self.throwStartTick = 0 -- 195
	self.throwUntil = -1 -- 196
	self.shotStartTick = 0 -- 197
	self.shotUntil = -1 -- 198
end -- 178
function ActorsRenderer.prototype.drainFootsteps(self) -- 200
	return self.anim:drainFootsteps() -- 201
end -- 200
function ActorsRenderer.prototype.reset(self, p) -- 204
	self.slideDust = {} -- 205
	self.dustCooldown = 0 -- 206
	self.slideDuration = 0 -- 207
	self.slideRemainder = 0 -- 208
	self.strideTick = p.ticks -- 209
	self.playerStride = strideAt(p.player) -- 210
	self.partnerStride = strideAt(p.partner) -- 211
	self.anim:reset(p) -- 212
	self.animTime = 0 -- 213
	self.previousHp = p.hp -- 214
	self.previousAxle = p.cartAxle -- 215
	self.cartMoving = false -- 216
	self.previousBottle = p.hasBottle -- 217
	self.previousTrace = p.trace -- 218
	self.hitStartTick = 0 -- 219
	self.hitUntil = -1 -- 220
	self.throwStartTick = 0 -- 221
	self.throwUntil = -1 -- 222
	self.shotStartTick = 0 -- 223
	self.shotUntil = -1 -- 224
end -- 204
function ActorsRenderer.prototype.update(self, dt, p) -- 228
	self.animTime = self.animTime + dt -- 229
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 230
		self.hitStartTick = p.ticks -- 231
		self.hitUntil = p.ticks + 16 -- 232
		self.anim.player:triggerHit(p.player.facing) -- 233
	end -- 233
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 235
		self.throwStartTick = p.ticks -- 236
		self.throwUntil = p.ticks + 16 -- 237
	end -- 237
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 239
		self.shotStartTick = p.ticks -- 240
		self.shotUntil = p.ticks + 16 -- 241
		local shotDir = p.trace.x1 < p.trace.x0 and -1 or 1 -- 242
		self.anim.player:triggerRecoil(shotDir) -- 243
	end -- 243
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 245
	self.previousAxle = p.cartAxle -- 246
	self.previousHp = p.hp -- 247
	self.previousBottle = p.hasBottle -- 248
	self.previousTrace = p.trace -- 249
	local ____opt_0 = self.playerStride -- 250
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 250
		self.playerStride = strideAt(p.player) -- 251
	end -- 251
	local ____opt_2 = self.partnerStride -- 253
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 253
		self.partnerStride = strideAt(p.partner) -- 254
	end -- 254
	local steps = math.max(0, p.ticks - self.strideTick) -- 256
	advanceStride(self.playerStride, steps, dt) -- 257
	advanceStride(self.partnerStride, steps, dt) -- 258
	self.strideTick = p.ticks -- 259
	self:updateSlide(dt, steps, p, self.playerStride.speed) -- 260
	self.anim.player:update( -- 262
		dt, -- 263
		p.player, -- 264
		self.playerStride.cycle, -- 265
		self.playerStride.speed, -- 266
		self.playerStride.effort, -- 267
		p.player.covered or p.coverHug, -- 268
		self.anim.footstepCues -- 269
	) -- 269
	self.anim.partner:update( -- 271
		dt, -- 272
		p.partner, -- 273
		self.partnerStride.cycle, -- 274
		self.partnerStride.speed, -- 275
		self.partnerStride.effort, -- 276
		p.partner.covered, -- 277
		self.anim.footstepCues -- 278
	) -- 278
	self.anim:updateEnemiesAndNpcs(dt, p) -- 280
end -- 228
function ActorsRenderer.prototype.slidePhase(self, a) -- 283
	local remaining = math.max(0, a.rollT - self.slideRemainder) -- 284
	return self.slideDuration > 0 and 1 - remaining / self.slideDuration or 0 -- 285
end -- 283
function ActorsRenderer.prototype.updateSlide(self, dt, steps, p, speed) -- 288
	local a = p.player -- 289
	if not p.childMode and a.rollT > 0 then -- 290
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 292
			0, -- 293
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 293
		) -- 293
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 294
		local progress = self:slidePhase(a) -- 295
		self.dustCooldown = self.dustCooldown - dt -- 296
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 297
			local ____self_slideDust_4 = self.slideDust -- 298
			____self_slideDust_4[#____self_slideDust_4 + 1] = { -- 298
				x = a.x + a.facing * a.h * 0.34, -- 299
				y = a.y, -- 300
				depth = a.depth, -- 301
				facing = a.facing, -- 302
				life = DUST_LIFE -- 303
			} -- 303
			self.dustCooldown = 0.038 -- 305
		end -- 305
	else -- 305
		self.slideDuration = 0 -- 308
		self.slideRemainder = 0 -- 309
		self.dustCooldown = 0 -- 310
	end -- 310
	local write = 0 -- 312
	for ____, dust in ipairs(self.slideDust) do -- 313
		dust.life = dust.life - dt -- 314
		if dust.life > 0 then -- 315
			self.slideDust[write + 1] = dust -- 316
			write = write + 1 -- 317
		end -- 317
	end -- 317
	__TS__ArraySetLength(self.slideDust, write) -- 320
end -- 288
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, pose) -- 323
	self:drawSlideDust(fgGlow, assets, p, cam) -- 331
	local i = 0 -- 334
	do -- 334
		i = 0 -- 335
		while i < #p.enemies do -- 335
			self:drawEnemy( -- 336
				fgDraw, -- 336
				fgGlow, -- 336
				assets, -- 336
				p.enemies[i + 1], -- 336
				i, -- 336
				p, -- 336
				cam -- 336
			) -- 336
			i = i + 1 -- 335
		end -- 335
	end -- 335
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 340
		self:drawScavenger( -- 341
			fgDraw, -- 341
			fgGlow, -- 341
			assets, -- 341
			p, -- 341
			cam -- 341
		) -- 341
	end -- 341
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 345
		self:drawDog( -- 346
			fgDraw, -- 346
			fgGlow, -- 346
			assets, -- 346
			p, -- 346
			cam -- 346
		) -- 346
	end -- 346
	if p.partner.alive and not (pose and pose.partner) then -- 350
		local partnerIsChild = p.partner.w <= 28 -- 351
		if partnerIsChild then -- 352
			self:drawXiaoman( -- 353
				fgDraw, -- 353
				fgGlow, -- 353
				assets, -- 353
				p.partner, -- 353
				p, -- 353
				cam, -- 353
				false -- 353
			) -- 353
		else -- 353
			self:drawZhouShu( -- 355
				fgDraw, -- 355
				fgGlow, -- 355
				assets, -- 355
				p.partner, -- 355
				p, -- 355
				cam, -- 355
				false -- 355
			) -- 355
		end -- 355
	end -- 355
	if p.player.alive then -- 360
		if p.childMode then -- 361
			self:drawXiaoman( -- 362
				fgDraw, -- 362
				fgGlow, -- 362
				assets, -- 362
				p.player, -- 362
				p, -- 362
				cam, -- 362
				true -- 362
			) -- 362
		else -- 362
			self:drawZhouShu( -- 364
				fgDraw, -- 364
				fgGlow, -- 364
				assets, -- 364
				p.player, -- 364
				p, -- 364
				cam, -- 364
				true, -- 364
				pose and pose.player -- 364
			) -- 364
		end -- 364
	end -- 364
end -- 323
function ActorsRenderer.prototype.drawSlideDust(self, draw, assets, p, cam) -- 369
	local depthEnabled = p.room.depth ~= nil -- 370
	do -- 370
		local i = 0 -- 371
		while i < #self.slideDust do -- 371
			local dust = self.slideDust[i + 1] -- 372
			local alpha = dust.life / DUST_LIFE -- 373
			local spread = 1 - alpha -- 374
			local dScale = cam:depthScale(dust.depth, depthEnabled) -- 375
			local x = cam:sx(dust.x - dust.facing * spread * 17) -- 376
			local y = cam:sy(dust.y + 1.5 + spread * 2, dust.depth) -- 377
			local dustSz = cam:len(14 + spread * 16) * dScale -- 378
			local clip = SLIDE_DUST_CLIPS[(spread < 0.45 and 0 or 1) + 1] -- 379
			if not assets:tryPlacePath( -- 380
				clip, -- 380
				"slide_dust_" .. tostring(i), -- 380
				x, -- 380
				y, -- 380
				dustSz * 1.25, -- 380
				dustSz, -- 380
				{ -- 380
					anchorX = 0.5, -- 381
					anchorY = 0, -- 382
					preserveAspect = true, -- 383
					facing = dust.facing, -- 384
					opacity = alpha * 0.85, -- 385
					layer = depthEnabled and depthOrder(dust.depth, 5) or 6 -- 386
				} -- 386
			) then -- 386
				draw:drawEllipse( -- 388
					Vec2(x, y), -- 388
					cam:len(5 + spread * 7), -- 388
					cam:len(1.5 + spread * 2), -- 388
					Color(166, 147, 124, 170 * alpha) -- 389
				) -- 389
				draw:drawDot( -- 390
					Vec2( -- 390
						x - dust.facing * cam:len(3), -- 390
						y + cam:len(4) -- 390
					), -- 390
					cam:len(1.1), -- 391
					Color(195, 174, 148, 135 * alpha) -- 391
				) -- 391
			end -- 391
			i = i + 1 -- 371
		end -- 371
	end -- 371
end -- 369
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 397
	local half = a.w * 0.5 -- 398
	local g = 0 -- 399
	local i = 0 -- 400
	do -- 400
		i = 0 -- 401
		while i < #p.room.floors do -- 401
			local f = p.room.floors[i + 1] -- 402
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 403
				g = f.y -- 404
			end -- 404
			i = i + 1 -- 401
		end -- 401
	end -- 401
	do -- 401
		i = 0 -- 407
		while i < #p.boxes do -- 407
			do -- 407
				local b = p.boxes[i + 1] -- 408
				if b.broken == true or b.hidden == true or b.soft == true then -- 409
					goto __continue46 -- 410
				end -- 410
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 412
					g = b.y1 -- 414
				end -- 414
			end -- 414
			::__continue46:: -- 414
			i = i + 1 -- 407
		end -- 407
	end -- 407
	return g -- 417
end -- 397
function ActorsRenderer.prototype.drawGroundedShadow(self, overlayDraw, assets, shadowKey, cx, by, shadowY, wPx, airHeightWorld, actorLayer, depthScale, isControlled) -- 421
	local airborne = airHeightWorld > 1.5 -- 434
	local heightShrink = airborne and math.max(0.54, 1 / (1 + airHeightWorld / 82)) or 1 -- 435
	local shW = math.max(16, wPx * 1.48 * heightShrink) -- 436
	local shH = math.max(6, wPx * 0.42 * heightShrink) -- 437
	assets:tryPlace( -- 438
		airborne and "dp_shadow_air" or "dp_shadow_contact", -- 438
		shadowKey, -- 438
		cx, -- 438
		shadowY + 1, -- 438
		shW, -- 438
		shH, -- 438
		{layer = actorLayer - 1, opacity = airborne and 0.88 or (isControlled and 0.92 or 0.82)} -- 438
	) -- 438
	if airborne then -- 442
		local tickTop = math.min( -- 444
			by - 2, -- 444
			shadowY + math.max(6, (by - shadowY) * 0.35) -- 444
		) -- 444
		if tickTop > shadowY + 3 then -- 445
			overlayDraw:drawSegment( -- 446
				Vec2(cx, shadowY + 2), -- 446
				Vec2(cx, tickTop), -- 446
				1.1, -- 446
				Color(148, 178, 202, 118) -- 446
			) -- 446
		end -- 446
	elseif isControlled then -- 448
		local rx = shW * 0.38 -- 450
		local ry = math.max(2.2, shH * 0.32) -- 451
		local ring = {} -- 452
		do -- 452
			local i = 0 -- 453
			while i < 12 do -- 453
				local ang = i / 12 * math.pi * 2 -- 454
				ring[#ring + 1] = Vec2( -- 455
					cx + math.cos(ang) * rx, -- 455
					shadowY + 1 + math.sin(ang) * ry -- 455
				) -- 455
				i = i + 1 -- 453
			end -- 453
		end -- 453
		overlayDraw:drawPolygon( -- 457
			ring, -- 457
			Color(0, 0, 0, 0), -- 457
			0.9, -- 457
			Color( -- 457
				146, -- 457
				178, -- 457
				200, -- 457
				math.floor(74 * depthScale + 0.5) -- 457
			) -- 457
		) -- 457
	end -- 457
end -- 421
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 462
	if bodyPlaced == nil then -- 470
		bodyPlaced = false -- 470
	end -- 470
	local cx = cam:sx(a.x) -- 472
	local by = cam:sy(a.y, a.depth) -- 473
	local depthEnabled = p.room.depth ~= nil -- 474
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 475
	local shadowY = not a.onGround and cam:sy(groundY, a.depth) or by -- 476
	local airH = math.max(0, a.y - groundY) -- 477
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 478
	local H = cam:len(a.h) * dScale -- 479
	local W = cam:len(a.w) * dScale -- 480
	local f = a.facing -- 481
	local speed = math.max( -- 482
		math.abs(a.vx), -- 482
		math.abs(a.depthSpeed) -- 482
	) -- 482
	local motion = isControlled and self.anim.player or self.anim.partner -- 483
	local juice = motion:sampleJuice(cam.ppu) -- 484
	local drawX = cx + juice.offsetX * dScale -- 485
	local actorLayer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 486
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 487
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 488
	local depthTint = depthEnabled and a.depth > 6 and Color( -- 489
		tone, -- 489
		tone, -- 489
		math.min(255, tone + 8), -- 489
		255 -- 489
	) or nil -- 489
	local hitTint = juice.hitFlash > 0.12 and Color( -- 490
		255, -- 491
		math.floor(230 - 38 * juice.hitFlash + 0.5), -- 491
		math.floor(212 - 44 * juice.hitFlash + 0.5), -- 491
		255 -- 491
	) or depthTint -- 492
	self:drawGroundedShadow( -- 494
		fgDraw, -- 494
		assets, -- 494
		"shadow_soldier", -- 494
		cx, -- 494
		by, -- 494
		shadowY, -- 494
		W, -- 494
		airH, -- 494
		actorLayer, -- 494
		dScale, -- 494
		isControlled -- 494
	) -- 494
	if bodyPlaced then -- 495
		return -- 496
	end -- 496
	local slot = "soldier_idle" -- 499
	local animClip = "" -- 500
	local height = H -- 501
	local frame = 0 -- 502
	local facing = f -- 503
	local extraScaleY = 1 -- 504
	local step = math.floor(self.animTime * 10) -- 505
	local ____isControlled_9 -- 506
	if isControlled then -- 506
		____isControlled_9 = self.playerStride -- 506
	else -- 506
		____isControlled_9 = self.partnerStride -- 506
	end -- 506
	local gait = ____isControlled_9 -- 506
	if isControlled and p.ticks < self.hitUntil then -- 508
		slot = "soldier_hit" -- 509
		local elapsed = math.max(0, p.ticks - self.hitStartTick) -- 510
		animClip = ZS_HIT_CLIPS[(elapsed < 7 and 0 or 1) + 1] -- 511
	elseif a.rollT > 0 then -- 512
		slot = "soldier_slide" -- 513
		local progress = self:slidePhase(a) -- 514
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 515
	elseif p.phase == "prologue-give" then -- 516
		slot = "soldier_offer" -- 517
		height = height * 0.75 -- 518
		facing = p.partner.x >= a.x and 1 or -1 -- 519
	elseif isControlled and p.gripping then -- 520
		slot = "soldier_push" -- 521
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 522
		local pushIdx = self.cartMoving and math.floor(motion.pushCycle * 4) % 4 or 0 -- 523
		animClip = ZS_PUSH_CLIPS[pushIdx + 1] -- 524
		frame = self.cartMoving and step or 0 -- 525
		height = height * 0.91 -- 526
	elseif isControlled and p.escort.state == "calming" then -- 527
		slot = "soldier_knock" -- 528
		local calm = p.escort.calmTick -- 529
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 530
		height = height * 0.76 -- 531
	else -- 531
		local ____temp_12 = p.phase == "gate-send" -- 532
		if ____temp_12 then -- 532
			local ____opt_10 = p.room.story -- 532
			____temp_12 = (____opt_10 and ____opt_10.gate) ~= nil -- 532
		end -- 532
		if ____temp_12 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 532
			slot = "soldier_hold" -- 534
			height = height * 1.11 -- 535
		elseif isControlled and p.ticks < self.shotUntil then -- 536
			local running = speed > 8 -- 537
			slot = running and "soldier_fire_move" or "soldier_fire" -- 538
			frame = running and step or 0 -- 539
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 540
			if not running then -- 541
				local elapsed = math.max(0, p.ticks - self.shotStartTick) -- 542
				local fIdx = elapsed < 2 and 0 or (elapsed < 5 and 1 or (elapsed < 11 and 2 or 3)) -- 543
				animClip = ZS_FIRE_CLIPS[fIdx + 1] -- 544
			end -- 544
		elseif a.covered or isControlled and p.coverHug then -- 546
			slot = "soldier_cover" -- 547
			animClip = ZS_COVER_CLIPS[math.floor(motion.coverTime * 2.2) % 2 + 1] -- 548
			extraScaleY = 1 + math.sin(motion.coverTime * 3.1) * 0.012 -- 549
			height = height * 0.77 -- 550
		elseif not a.onGround then -- 551
			local jIdx = a.vy > 110 and 0 or (a.vy > -35 and 1 or 2) -- 552
			animClip = ZS_JUMP_CLIPS[jIdx + 1] -- 553
		elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 554
			animClip = ZS_JUMP_CLIPS[4] -- 555
		elseif (gait and gait.speed or 0) > 8 then -- 556
			slot = "soldier_run" -- 557
			frame = step -- 558
		elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 559
			local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.4) % #IDLE_PING_PONG + 1] -- 560
			if beat >= 0 then -- 561
				animClip = ZS_IDLE_CLIPS[beat + 1] -- 562
			end -- 562
			extraScaleY = 1 + math.sin(motion.idleTime * 2.4) * 0.008 -- 564
		end -- 564
	end -- 564
	local pose = { -- 566
		facing = facing, -- 567
		frame = frame, -- 568
		layer = actorLayer, -- 569
		angle = juice.angleOffset, -- 570
		scaleXMul = juice.scaleXMul, -- 571
		scaleYMul = juice.scaleYMul * extraScaleY, -- 572
		color = hitTint -- 573
	} -- 573
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 575
		"actor_soldier", -- 576
		cx, -- 576
		by, -- 576
		W, -- 576
		height, -- 576
		self:slidePhase(a), -- 576
		{facing = facing, layer = actorLayer, color = hitTint} -- 576
	) -- 576
	local running = animClip == "" and (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 577
		"soldier", -- 579
		"actor_soldier", -- 579
		cx, -- 579
		by, -- 579
		W, -- 579
		height, -- 579
		gait.cycle, -- 579
		pose, -- 579
		gait.effort -- 579
	) -- 579
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 580
		animClip, -- 580
		"actor_soldier", -- 580
		drawX, -- 580
		by, -- 580
		H, -- 580
		H, -- 580
		{ -- 580
			anchorX = 0.5, -- 581
			anchorY = 0, -- 582
			preserveAspect = true, -- 583
			facing = facing, -- 584
			angle = juice.angleOffset, -- 585
			scaleXMul = juice.scaleXMul, -- 586
			scaleYMul = juice.scaleYMul * extraScaleY, -- 587
			color = hitTint, -- 588
			layer = actorLayer -- 589
		} -- 589
	) -- 589
	if sliding or running or placedAnim or assets:tryPlace( -- 591
		slot, -- 591
		"actor_soldier", -- 591
		drawX, -- 591
		by, -- 591
		W, -- 591
		height, -- 591
		pose -- 591
	) then -- 591
		if juice.hitFlash > 0.35 then -- 592
			fillRadialGlow( -- 593
				fgGlow, -- 593
				drawX, -- 593
				by + H * 0.56, -- 593
				H * 0.38, -- 593
				H * 0.44, -- 593
				Color( -- 594
					255, -- 594
					224, -- 594
					198, -- 594
					math.floor(74 * juice.hitFlash + 0.5) -- 594
				), -- 594
				Color(214, 72, 56, 0), -- 594
				12 -- 594
			) -- 594
		end -- 594
		return -- 596
	end -- 596
	fgDraw:drawRect( -- 599
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 599
		Color(32, 46, 66, 220) -- 599
	) -- 599
end -- 462
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 603
	local cx = cam:sx(a.x) -- 612
	local by = cam:sy(a.y, a.depth) -- 613
	local depthEnabled = p.room.depth ~= nil -- 614
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 615
	local shadowY = not a.onGround and cam:sy(groundY, a.depth) or by -- 616
	local airH = math.max(0, a.y - groundY) -- 617
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 618
	local H = cam:len(a.h) * dScale -- 619
	local W = cam:len(a.w) * dScale -- 620
	local f = a.facing -- 621
	local speed = math.max( -- 622
		math.abs(a.vx), -- 622
		math.abs(a.depthSpeed) -- 622
	) -- 622
	local ____isControlled_19 -- 623
	if isControlled then -- 623
		____isControlled_19 = self.playerStride -- 623
	else -- 623
		____isControlled_19 = self.partnerStride -- 623
	end -- 623
	local gait = ____isControlled_19 -- 623
	local motion = isControlled and self.anim.player or self.anim.partner -- 624
	local juice = motion:sampleJuice(cam.ppu) -- 625
	local actorLayer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 626
	local afraid = not isControlled and p.escort.fear > 0 -- 628
	local slot = "child_idle" -- 629
	local animClip = "" -- 630
	local height = H -- 631
	local frame = 0 -- 632
	local extraScaleY = 1 -- 633
	local shiverX = 0 -- 634
	local step = math.floor(self.animTime * 10) -- 635
	local nearCover = __TS__ArraySome( -- 636
		p.room.solids, -- 636
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 636
			math.abs(a.x - solid.x), -- 639
			math.abs(a.x - solid.x - solid.w) -- 639
		) <= 30 end -- 639
	) -- 639
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 641
		slot = "child_knock" -- 642
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 643
		slot = "child_offer" -- 645
	elseif isControlled and p.ticks < self.throwUntil then -- 646
		slot = "child_throw" -- 647
		if p.ticks - self.throwStartTick < 7 then -- 648
			animClip = XM_THROW_REL_CLIP -- 649
		end -- 649
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 651
		slot = "child_aim" -- 652
	elseif isControlled and p.gripping then -- 653
		slot = "child_pull" -- 654
		if self.cartMoving then -- 655
			local pBeat = math.floor(motion.pushCycle * 4) % 4 -- 656
			if pBeat == 1 or pBeat == 3 then -- 657
				animClip = XM_PULL_MID_CLIP -- 658
			else -- 658
				frame = pBeat == 2 and 1 or 0 -- 660
			end -- 660
		end -- 660
	elseif afraid and p.escort.state == "frozen" then -- 663
		slot = "child_fear" -- 664
		height = height * 0.74 -- 665
		shiverX = math.sin(self.animTime * 42) * 1.4 -- 666
		if math.floor(self.animTime * 7) % 2 == 1 then -- 667
			animClip = XM_FEAR_B_CLIP -- 668
		end -- 668
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 670
		slot = "child_peek" -- 672
		height = height * 0.83 -- 673
		if math.floor(self.animTime * 2.2) % 2 == 1 then -- 674
			animClip = XM_PEEK_B_CLIP -- 675
		end -- 675
	elseif a.crouch then -- 677
		slot = "child_crouch" -- 678
		local crawlIdx = speed > 6 and math.floor(motion.crouchCycle * 4) % 4 or 0 -- 679
		animClip = XM_CRAWL_CLIPS[crawlIdx + 1] -- 680
		frame = speed > 8 and step or 0 -- 681
	elseif not a.onGround then -- 682
		local jIdx = a.vy > 100 and 0 or (a.vy > -30 and 1 or 2) -- 683
		animClip = XM_JUMP_CLIPS[jIdx + 1] -- 684
	elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 685
		animClip = XM_JUMP_CLIPS[4] -- 686
	elseif (gait and gait.speed or 0) > 8 then -- 687
		slot = "child_run" -- 688
		frame = step -- 689
	elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 690
		local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.2) % #IDLE_PING_PONG + 1] -- 691
		if beat >= 0 then -- 692
			animClip = XM_IDLE_CLIPS[beat + 1] -- 693
		end -- 693
		extraScaleY = 1 + math.sin(motion.idleTime * 2.8) * 0.01 -- 695
	end -- 695
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 698
	local drawX = cx + (juice.offsetX + shiverX) * dScale -- 699
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 700
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 701
	local depthTint = depthEnabled and a.depth > 6 and Color( -- 702
		tone, -- 702
		tone, -- 702
		math.min(255, tone + 6), -- 702
		255 -- 702
	) or nil -- 702
	local pose = { -- 703
		facing = facing, -- 704
		frame = frame, -- 705
		layer = actorLayer, -- 706
		angle = juice.angleOffset, -- 707
		scaleXMul = juice.scaleXMul, -- 708
		scaleYMul = juice.scaleYMul * extraScaleY, -- 709
		color = depthTint -- 710
	} -- 710
	self:drawGroundedShadow( -- 712
		fgDraw, -- 712
		assets, -- 712
		"shadow_child", -- 712
		cx, -- 712
		by, -- 712
		shadowY, -- 712
		W, -- 712
		airH, -- 712
		actorLayer, -- 712
		dScale, -- 712
		isControlled -- 712
	) -- 712
	local running = animClip == "" and (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 713
		"child", -- 715
		"actor_child", -- 715
		cx, -- 715
		by, -- 715
		W, -- 715
		height, -- 715
		gait.cycle, -- 715
		pose, -- 715
		gait.effort -- 715
	) -- 715
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 716
		animClip, -- 716
		"actor_child", -- 716
		drawX, -- 716
		by, -- 716
		H, -- 716
		H, -- 716
		{ -- 716
			anchorX = 0.5, -- 717
			anchorY = 0, -- 718
			preserveAspect = true, -- 719
			facing = facing, -- 720
			angle = juice.angleOffset, -- 721
			scaleXMul = juice.scaleXMul, -- 722
			scaleYMul = juice.scaleYMul * extraScaleY, -- 723
			color = depthTint, -- 724
			layer = actorLayer -- 725
		} -- 725
	) -- 725
	if running or placedAnim or assets:tryPlace( -- 727
		slot, -- 727
		"actor_child", -- 727
		drawX, -- 727
		by, -- 727
		W, -- 727
		height, -- 727
		pose -- 727
	) then -- 727
		if afraid then -- 728
			self:drawFear(fgGlow, p, cx, by + H + 14) -- 729
		end -- 729
		return -- 731
	end -- 731
	fgDraw:drawRect( -- 733
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 733
		Color(168, 126, 72, 220) -- 733
	) -- 733
	if afraid then -- 734
		self:drawFear(fgGlow, p, cx, by + H + 16) -- 735
	end -- 735
end -- 603
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 739
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 740
	do -- 740
		local i = 0 -- 741
		while i < FEAR_MAX do -- 741
			local lit = i < p.escort.fear -- 742
			drawDiamond( -- 743
				fgGlow, -- 743
				x + (i - 1) * 13, -- 743
				y, -- 743
				4, -- 743
				5, -- 743
				toColor(lit and tint or PALETTE.steelDark, 215), -- 744
				1, -- 744
				toColor(tint, lit and 235 or 100) -- 744
			) -- 744
			i = i + 1 -- 741
		end -- 741
	end -- 741
end -- 739
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 748
	local x = cam:sx(e.x + f * 20) -- 749
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 750
	local dx = cam:sx(p.player.x) - x -- 751
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 752
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 753
	do -- 753
		local i = 0 -- 754
		while i < 8 do -- 754
			local a = length * i / 8 -- 755
			local b = length * (i + 1) / 8 -- 756
			fgGlow:drawSegment( -- 757
				Vec2(x + dx * a, y + dy * a), -- 757
				Vec2(x + dx * b, y + dy * b), -- 757
				1.3, -- 758
				Color(220, 120, 88, 210) -- 758
			) -- 758
			i = i + 2 -- 754
		end -- 754
	end -- 754
end -- 748
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 763
	local cx = cam:sx(e.x) -- 772
	local depth = e.depth or 0 -- 773
	local depthEnabled = p.room.depth ~= nil -- 774
	local dScale = cam:depthScale(depth, depthEnabled) -- 775
	local by = cam:sy(e.y, depth) -- 776
	local H = cam:len(e.h) * dScale -- 777
	local W = cam:len(e.w) * dScale -- 778
	local f = p.player.x >= e.x and 1 or -1 -- 779
	if e.kind == "target" then -- 782
		local targetLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 783
		self:drawGroundedShadow( -- 784
			fgDraw, -- 784
			assets, -- 784
			"shadow_target_" .. tostring(index), -- 784
			cx, -- 784
			by, -- 784
			by, -- 784
			W * 1.1, -- 784
			0, -- 784
			targetLayer, -- 784
			dScale, -- 784
			false -- 784
		) -- 784
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 785
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 786
		assets:tryPlacePath( -- 787
			"assets/art/props_ming.clip|target_dummy", -- 787
			"actor_target_" .. tostring(index), -- 787
			cx, -- 787
			by, -- 787
			H * 0.82, -- 787
			H * 0.96, -- 787
			{ -- 787
				anchorX = 0.5, -- 788
				anchorY = 0, -- 789
				preserveAspect = true, -- 790
				angle = angle, -- 791
				color = tint, -- 792
				opacity = e.alive and 1 or 0.76, -- 793
				layer = targetLayer -- 794
			} -- 794
		) -- 794
		return -- 796
	end -- 796
	local enemyLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 799
	if e.alive then -- 800
		self:drawGroundedShadow( -- 801
			fgDraw, -- 801
			assets, -- 801
			"shadow_enemy_" .. tostring(index), -- 801
			cx, -- 801
			by, -- 801
			by, -- 801
			W * 1.05, -- 801
			0, -- 801
			enemyLayer, -- 801
			dScale, -- 801
			false -- 801
		) -- 801
	else -- 801
		assets:tryPlace( -- 803
			"dp_shadow_contact", -- 803
			"shadow_enemy_" .. tostring(index), -- 803
			cx, -- 803
			by + 1, -- 803
			math.max(18, W * 1.65), -- 803
			math.max(6, W * 0.42), -- 803
			{layer = enemyLayer - 1, opacity = 0.56} -- 803
		) -- 803
	end -- 803
	local es = index < #self.anim.enemies and self.anim.enemies[index + 1] or nil -- 808
	local moving = (es and es.speed or 0) > 6 -- 809
	local walkStep = math.floor((es and es.walkCycle or 0) * 4) % 2 -- 810
	local hitFlash = es ~= nil and es.hitFlash or 0 -- 811
	local dying = not e.alive and (es and es.deathTime or 1) < 0.15 -- 812
	local breathY = e.alive and not moving and e.hitT <= 0 and 1 + math.sin(self.animTime * 2.4 + (es and es.idlePhase or index)) * 0.014 or 1 -- 813
	local knockX = (e.hitT > 0 or dying) and -f * cam:len(3.5 * math.max(0.3, hitFlash)) * dScale or 0 -- 816
	local hitAngle = (e.hitT > 0 or dying) and -f * 5.5 or 0 -- 817
	local dShade = cam:depthShade(depth, depthEnabled) -- 818
	local shadeMul = depthEnabled and depth > 6 and math.min(1, dShade + 0.06) or 1 -- 819
	local baseTone = math.floor(255 * shadeMul + 0.5) -- 820
	local enemyClip = "" -- 821
	local enemyTint = hitFlash > 0.12 and Color( -- 822
		255, -- 823
		math.floor(220 - 42 * hitFlash + 0.5), -- 823
		math.floor(196 - 52 * hitFlash + 0.5), -- 823
		255 -- 823
	) or Color( -- 824
		baseTone, -- 824
		baseTone, -- 824
		math.min(255, baseTone + (depthEnabled and depth > 6 and 8 or 0)), -- 824
		255 -- 824
	) -- 824
	local drawHeight = H * 1.01 -- 825
	local cleaving = false -- 826
	if e.kind == "shield" and ((e.shieldHp or 0) > 0 or not e.alive or e.hitT > 0) then -- 828
		if not e.alive then -- 829
			enemyClip = dying and EN_SHD_HIT_CLIP or EN_GUN_DOWN_CLIP -- 830
		elseif e.hitT > 0 then -- 831
			enemyClip = EN_SHD_HIT_CLIP -- 832
		elseif e.warnT > 0 then -- 833
			enemyClip = EN_SHD_BASH_CLIP -- 834
		elseif moving then -- 835
			enemyClip = walkStep == 0 and EN_SHD_WALK_CLIP or EN_SHD_IDLE_CLIP -- 836
		else -- 836
			enemyClip = EN_SHD_IDLE_CLIP -- 838
		end -- 838
		if e.alive and (e.shieldHp or 2) <= 1 and hitFlash <= 0.12 then -- 840
			enemyTint = Color( -- 841
				math.floor(238 * shadeMul + 0.5), -- 841
				math.floor(198 * shadeMul + 0.5), -- 841
				math.floor(174 * shadeMul + 0.5), -- 841
				255 -- 841
			) -- 841
		end -- 841
	elseif e.kind == "breaker" then -- 843
		drawHeight = H * 1.03 -- 844
		if not e.alive then -- 845
			enemyClip = dying and EN_BRK_HIT_CLIP or EN_GUN_DOWN_CLIP -- 846
		elseif e.hitT > 0 then -- 847
			enemyClip = EN_BRK_HIT_CLIP -- 848
		elseif (e.swingT or 0) > 0 then -- 849
			cleaving = (es and es.swingTime or 0) >= 0.12 -- 850
			enemyClip = cleaving and EN_BRK_CLEAVE_CLIP or EN_BRK_WINDUP_CLIP -- 851
		elseif e.warnT > 0 then -- 852
			enemyClip = EN_BRK_WINDUP_CLIP -- 853
		else -- 853
			enemyClip = EN_BRK_WALK_CLIP -- 855
		end -- 855
	elseif e.kind == "leader" then -- 857
		drawHeight = H * 1.04 -- 858
		if not e.alive then -- 859
			enemyClip = dying and EN_LDR_HIT_CLIP or EN_GUN_DOWN_CLIP -- 860
		elseif e.hitT > 0 then -- 861
			enemyClip = EN_LDR_HIT_CLIP -- 862
		elseif e.warnT > 0 then -- 863
			enemyClip = EN_LDR_AIM_CLIP -- 864
		elseif moving then -- 865
			enemyClip = walkStep == 0 and EN_LDR_WALK_CLIP or EN_LDR_IDLE_CLIP -- 866
		else -- 866
			enemyClip = EN_LDR_IDLE_CLIP -- 868
		end -- 868
	else -- 868
		if not e.alive then -- 872
			enemyClip = dying and EN_GUN_HIT_CLIP or EN_GUN_DOWN_CLIP -- 873
		elseif e.hitT > 0 then -- 874
			enemyClip = EN_GUN_HIT_CLIP -- 875
		elseif e.warnT > 0 then -- 876
			enemyClip = e.warnT <= 6 and EN_GUN_FIRE_CLIP or EN_GUN_AIM_CLIP -- 877
		elseif moving then -- 878
			enemyClip = EN_GUN_WALK_CLIPS[walkStep + 1] -- 879
		else -- 879
			enemyClip = EN_GUN_IDLE_CLIPS[math.floor((self.animTime + (es and es.idlePhase or index)) * 2.1) % 2 + 1] -- 881
		end -- 881
	end -- 881
	if enemyClip ~= "" and assets:tryPlacePath( -- 885
		enemyClip, -- 886
		"actor_enemy_" .. tostring(index), -- 887
		cx + knockX, -- 888
		by, -- 889
		drawHeight, -- 890
		drawHeight, -- 891
		{ -- 892
			anchorX = 0.5, -- 893
			anchorY = 0, -- 894
			preserveAspect = true, -- 895
			facing = f, -- 896
			angle = hitAngle, -- 897
			scaleYMul = breathY, -- 898
			color = enemyTint, -- 899
			opacity = e.alive and 1 or 0.78, -- 900
			layer = enemyLayer -- 901
		} -- 901
	) then -- 901
		if hitFlash > 0.35 then -- 904
			fillRadialGlow( -- 905
				fgGlow, -- 905
				cx + knockX, -- 905
				by + H * 0.54, -- 905
				H * 0.34, -- 905
				H * 0.38, -- 905
				Color( -- 906
					255, -- 906
					224, -- 906
					186, -- 906
					math.floor(78 * hitFlash + 0.5) -- 906
				), -- 906
				Color(214, 72, 52, 0), -- 906
				12 -- 906
			) -- 906
		end -- 906
		if cleaving then -- 908
			fgGlow:drawArc( -- 909
				Vec2( -- 909
					cx + f * cam:len(12), -- 909
					by + H * 0.56 -- 909
				), -- 909
				cam:len(22), -- 909
				f > 0 and -48 or 132, -- 909
				f > 0 and 54 or 234, -- 909
				2.4, -- 909
				toColor(PALETTE.sealRedBright, 215) -- 909
			) -- 909
			fgGlow:drawArc( -- 910
				Vec2( -- 910
					cx + f * cam:len(12), -- 910
					by + H * 0.56 -- 910
				), -- 910
				cam:len(18), -- 910
				f > 0 and -40 or 140, -- 910
				f > 0 and 48 or 228, -- 910
				1.4, -- 910
				toColor(PALETTE.amberCore, 185) -- 910
			) -- 910
		end -- 910
		if e.alive and e.warnT > 0 then -- 912
			self:drawEnemyWarning( -- 913
				fgGlow, -- 913
				e, -- 913
				p, -- 913
				cam, -- 913
				f -- 913
			) -- 913
		end -- 913
		return -- 915
	end -- 915
	local slot = "enemy_idle" -- 918
	if not e.alive then -- 919
		slot = "enemy_down" -- 920
	elseif e.hitT > 0 then -- 921
		slot = "enemy_hit" -- 922
	elseif e.warnT > 0 then -- 923
		slot = "enemy_aim" -- 924
	end -- 924
	local height = e.alive and H or H * 0.24 -- 926
	if assets:tryPlace( -- 927
		slot, -- 927
		"actor_enemy_" .. tostring(index), -- 927
		cx, -- 927
		by, -- 927
		W, -- 927
		height, -- 927
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 927
	) then -- 927
		if e.alive then -- 930
			self:drawEnemyArchetypeGear( -- 931
				fgDraw, -- 931
				fgGlow, -- 931
				assets, -- 931
				e, -- 931
				index, -- 931
				cx, -- 931
				by, -- 931
				H, -- 931
				f, -- 931
				cam, -- 931
				enemyLayer + 1 -- 931
			) -- 931
			if e.warnT > 0 then -- 932
				self:drawEnemyWarning( -- 933
					fgGlow, -- 933
					e, -- 933
					p, -- 933
					cam, -- 933
					f -- 933
				) -- 933
			end -- 933
		end -- 933
		return -- 936
	end -- 936
	if e.alive then -- 938
		fgDraw:drawRect( -- 939
			Rect(cx - W * 0.4, by, W * 0.8, height), -- 939
			Color(96, 56, 48, 220) -- 939
		) -- 939
	end -- 939
end -- 763
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 944
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 957
		local shX = cx + f * cam:len(13) -- 958
		local cracked = (e.shieldHp or 2) <= 1 -- 959
		if not assets:tryPlace( -- 960
			"fe_gear_rattan_shield", -- 960
			"enemy_shield_" .. tostring(index), -- 960
			shX, -- 960
			by + H * 0.44, -- 960
			cam:len(22), -- 960
			H * 0.64, -- 960
			{ -- 960
				facing = f, -- 961
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 962
				layer = layer -- 963
			} -- 963
		) then -- 963
			local shW = math.max( -- 965
				5, -- 965
				cam:len(8) -- 965
			) -- 965
			fgDraw:drawRect( -- 966
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 966
				Color(96, 66, 42, 250), -- 966
				1.3, -- 966
				Color(168, 174, 180, 230) -- 966
			) -- 966
		end -- 966
		if cracked then -- 968
			fgDraw:drawSegment( -- 969
				Vec2( -- 969
					shX - cam:len(4), -- 969
					by + H * 0.3 -- 969
				), -- 969
				Vec2( -- 969
					shX + cam:len(4), -- 969
					by + H * 0.56 -- 969
				), -- 969
				1.4, -- 969
				Color(24, 18, 16, 235) -- 969
			) -- 969
		end -- 969
	elseif e.kind == "breaker" then -- 971
		local swing = (e.swingT or 0) > 0 -- 972
		local handleX0 = cx - f * cam:len(4) -- 973
		local handleY0 = by + H * 0.44 -- 974
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 975
		local tipY = by + H * (swing and 0.46 or 0.78) -- 976
		fgDraw:drawSegment( -- 977
			Vec2(handleX0, handleY0), -- 977
			Vec2(tipX, tipY), -- 977
			math.max( -- 977
				2.2, -- 977
				cam:len(3) -- 977
			), -- 977
			Color(98, 66, 44, 255) -- 977
		) -- 977
		fgDraw:drawPolygon( -- 978
			{ -- 978
				Vec2( -- 979
					tipX - f * cam:len(3), -- 979
					tipY - cam:len(4) -- 979
				), -- 979
				Vec2( -- 980
					tipX + f * cam:len(9), -- 980
					tipY - cam:len(1) -- 980
				), -- 980
				Vec2( -- 981
					tipX + f * cam:len(7), -- 981
					tipY + cam:len(9) -- 981
				), -- 981
				Vec2( -- 982
					tipX - f * cam:len(2), -- 982
					tipY + cam:len(6) -- 982
				) -- 982
			}, -- 982
			Color(148, 154, 162, 250), -- 983
			1, -- 983
			Color(224, 228, 232, 220) -- 983
		) -- 983
		if swing then -- 984
			fgGlow:drawArc( -- 985
				Vec2( -- 985
					cx + f * cam:len(10), -- 985
					by + H * 0.56 -- 985
				), -- 985
				cam:len(18), -- 985
				f > 0 and -40 or 140, -- 985
				f > 0 and 50 or 230, -- 985
				1.8, -- 985
				toColor(PALETTE.rouge, 195) -- 985
			) -- 985
		end -- 985
	elseif e.kind == "leader" then -- 987
		local topY = by + H * 1.02 -- 989
		fgDraw:drawSegment( -- 990
			Vec2(cx, topY), -- 990
			Vec2( -- 990
				cx - f * cam:len(10), -- 990
				topY + cam:len(9) -- 990
			), -- 990
			2.2, -- 990
			toColor(PALETTE.rouge, 240) -- 990
		) -- 990
		fgDraw:drawDot( -- 991
			Vec2( -- 991
				cx - f * cam:len(10), -- 991
				topY + cam:len(9) -- 991
			), -- 991
			2.6, -- 991
			toColor(PALETTE.crimsonCore, 235) -- 991
		) -- 991
	end -- 991
end -- 944
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 996
	local s = p.room.scavenger -- 1003
	if s == nil then -- 1004
		return -- 1005
	end -- 1005
	local cx = cam:sx(p.scavX) -- 1007
	local by = cam:sy(s.y) -- 1008
	local H = cam:len(s.h) -- 1009
	local W = cam:len(26) -- 1010
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 1011
	local alert = p.scavChase or p.scavSee > 0 -- 1014
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 1015
	local eyeY = by + H * 0.8 -- 1016
	local coneLen = cam:len(alert and 155 or 115) -- 1017
	fgGlow:drawVertices({ -- 1018
		{ -- 1019
			Vec2(cx + f * 6, eyeY), -- 1019
			toColor(coneCol, alert and 78 or 34) -- 1019
		}, -- 1019
		{ -- 1020
			Vec2(cx + f * coneLen, by + H * 1.05), -- 1020
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1020
		}, -- 1020
		{ -- 1021
			Vec2(cx + f * coneLen, by + 4), -- 1021
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1021
		} -- 1021
	}) -- 1021
	local scavClip = SCAV_WALK_CLIPS[1] -- 1024
	local frame = 0 -- 1025
	if p.scavState == "turn" then -- 1026
		scavClip = SCAV_TURN_CLIP -- 1027
		frame = 2 -- 1028
	elseif p.scavState == "chase" then -- 1029
		local runBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1030
		scavClip = runBeat == 0 and SCAV_RUN_CLIP or SCAV_WALK_CLIPS[2] -- 1031
		frame = runBeat == 0 and 3 or 1 -- 1032
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 1033
		local walkBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1034
		scavClip = SCAV_WALK_CLIPS[walkBeat + 1] -- 1035
		frame = walkBeat -- 1036
	end -- 1036
	local scavBreath = (p.scavState == "stall" or p.scavState == "turn") and 1 + math.sin(self.animTime * 2.5) * 0.012 or 1 -- 1038
	self:drawGroundedShadow( -- 1041
		fgDraw, -- 1041
		assets, -- 1041
		"shadow_scav", -- 1041
		cx, -- 1041
		by, -- 1041
		by, -- 1041
		W * 0.96, -- 1041
		0, -- 1041
		3, -- 1041
		1, -- 1041
		false -- 1041
	) -- 1041
	if assets:tryPlacePath( -- 1042
		scavClip, -- 1042
		"actor_scav", -- 1042
		cx, -- 1042
		by, -- 1042
		H, -- 1042
		H, -- 1042
		{ -- 1042
			anchorX = 0.5, -- 1043
			anchorY = 0, -- 1044
			preserveAspect = true, -- 1045
			facing = f, -- 1046
			scaleYMul = scavBreath, -- 1047
			layer = 3 -- 1048
		} -- 1048
	) or assets:tryPlace( -- 1049
		"scavenger", -- 1049
		"actor_scav", -- 1049
		cx, -- 1049
		by, -- 1049
		W, -- 1049
		H, -- 1049
		{facing = f, frame = frame, layer = 3} -- 1049
	) then -- 1049
		local indY = by + H + 16 -- 1050
		if p.scavChase then -- 1051
			drawDiamond( -- 1052
				fgGlow, -- 1052
				cx, -- 1052
				indY, -- 1052
				8, -- 1052
				11, -- 1052
				toColor(PALETTE.crimson, 240), -- 1052
				1.4, -- 1052
				toColor(PALETTE.crimsonCore) -- 1052
			) -- 1052
		elseif p.scavSee > 0 then -- 1053
			local frac = math.min(1, p.scavSee / 24) -- 1054
			fgGlow:drawArc( -- 1055
				Vec2(cx, indY), -- 1055
				10, -- 1055
				90, -- 1055
				90 - 360 * frac, -- 1055
				2.2, -- 1055
				toColor(PALETTE.crimson, 235) -- 1055
			) -- 1055
			fgGlow:drawDot( -- 1056
				Vec2(cx, indY), -- 1056
				2.8, -- 1056
				toColor(PALETTE.amber) -- 1056
			) -- 1056
		elseif p.scavState == "turn" then -- 1057
			drawDiamond( -- 1058
				fgGlow, -- 1058
				cx, -- 1058
				indY, -- 1058
				5.5, -- 1058
				7.5, -- 1058
				toColor(PALETTE.amber, 220) -- 1058
			) -- 1058
		end -- 1058
		return -- 1060
	end -- 1060
	fgDraw:drawEllipse( -- 1063
		Vec2(cx, by + 1), -- 1063
		W * 0.62, -- 1063
		4, -- 1063
		Color(4, 6, 10, 155) -- 1063
	) -- 1063
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1064
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 1065
	fgDraw:drawSegment( -- 1067
		Vec2(cx - 4, by + H * 0.4), -- 1067
		Vec2(cx - stride, by + 2), -- 1067
		W * 0.16, -- 1067
		Color(32, 30, 28, 255) -- 1067
	) -- 1067
	fgDraw:drawSegment( -- 1068
		Vec2(cx + 4, by + H * 0.4), -- 1068
		Vec2(cx + stride, by + 2), -- 1068
		W * 0.16, -- 1068
		Color(44, 40, 36, 255) -- 1068
	) -- 1068
	fgDraw:drawPolygon( -- 1070
		{ -- 1070
			Vec2(cx - W * 0.45, by + H * 0.25), -- 1071
			Vec2(cx + W * 0.42, by + H * 0.25), -- 1072
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 1073
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 1074
		}, -- 1074
		Color(56, 52, 46, 255), -- 1075
		1.2, -- 1075
		Color(128, 118, 100, 180) -- 1075
	) -- 1075
	local headX = cx + f * 5 -- 1077
	local headY = by + H * 0.88 -- 1078
	fgDraw:drawCircle( -- 1079
		Vec2(headX, headY), -- 1079
		W * 0.3, -- 1079
		Color(42, 38, 34, 255) -- 1079
	) -- 1079
	fgGlow:drawDot( -- 1080
		Vec2(headX + f * 6, headY), -- 1080
		3, -- 1080
		toColor(coneCol, 245) -- 1080
	) -- 1080
	local indY = by + H + 18 -- 1083
	if p.scavChase then -- 1084
		drawDiamond( -- 1085
			fgGlow, -- 1085
			cx, -- 1085
			indY, -- 1085
			9, -- 1085
			12, -- 1085
			toColor(PALETTE.crimson, 240), -- 1085
			1.5, -- 1085
			toColor(PALETTE.crimsonCore) -- 1085
		) -- 1085
	elseif p.scavSee > 0 then -- 1086
		local frac = math.min(1, p.scavSee / 24) -- 1087
		fgGlow:drawArc( -- 1088
			Vec2(cx, indY), -- 1088
			11, -- 1088
			90, -- 1088
			90 - 360 * frac, -- 1088
			2.4, -- 1088
			toColor(PALETTE.crimson, 235) -- 1088
		) -- 1088
		fgGlow:drawDot( -- 1089
			Vec2(cx, indY), -- 1089
			3, -- 1089
			toColor(PALETTE.amber) -- 1089
		) -- 1089
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 1090
		drawDiamond( -- 1091
			fgGlow, -- 1091
			cx, -- 1091
			indY, -- 1091
			6, -- 1091
			8, -- 1091
			toColor(PALETTE.amber, 220) -- 1091
		) -- 1091
	end -- 1091
end -- 996
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 1096
	local cx = cam:sx(p.dogX) -- 1103
	local by = cam:sy(0) -- 1104
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 1105
	local W = cam:len(34) -- 1106
	local H = cam:len(28) -- 1107
	local dogClip = DOG_WALK_CLIP -- 1109
	local frame = 0 -- 1110
	if p.dogState == "ear" then -- 1111
		dogClip = DOG_ALERT_CLIP -- 1112
		frame = 1 -- 1113
	elseif p.dogState == "sniff" then -- 1114
		dogClip = DOG_WALK_CLIP -- 1115
		frame = 3 -- 1116
	elseif p.dogState == "chase" then -- 1117
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1118
		dogClip = DOG_RUN_CLIPS[beat + 1] -- 1119
		frame = beat == 0 and 0 or 2 -- 1120
	elseif p.dogState == "patrol" or p.dogState == "back" then -- 1121
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1122
		dogClip = beat == 0 and DOG_WALK_CLIP or DOG_RUN_CLIPS[2] -- 1123
		frame = beat == 0 and 0 or 2 -- 1124
	end -- 1124
	local dogH = H * 1.12 -- 1126
	self:drawGroundedShadow( -- 1127
		fgDraw, -- 1127
		assets, -- 1127
		"shadow_dog", -- 1127
		cx, -- 1127
		by, -- 1127
		by, -- 1127
		W * 0.92, -- 1127
		0, -- 1127
		3, -- 1127
		1, -- 1127
		false -- 1127
	) -- 1127
	if assets:tryPlacePath( -- 1128
		dogClip, -- 1128
		"actor_dog", -- 1128
		cx, -- 1128
		by, -- 1128
		dogH, -- 1128
		dogH, -- 1128
		{ -- 1128
			anchorX = 0.5, -- 1129
			anchorY = 0, -- 1130
			preserveAspect = true, -- 1131
			facing = f, -- 1132
			layer = 3 -- 1133
		} -- 1133
	) or assets:tryPlace( -- 1134
		"dog", -- 1134
		"actor_dog", -- 1134
		cx, -- 1134
		by, -- 1134
		W, -- 1134
		H, -- 1134
		{facing = f, frame = frame, layer = 3} -- 1134
	) then -- 1134
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 1135
		if alert then -- 1136
			local hx = cx + f * W * 0.34 -- 1137
			local hy = by + H * 0.86 -- 1138
			local r = 10 + self.animTime * 40 % 22 -- 1139
			fgGlow:drawArc( -- 1140
				Vec2(hx, hy + 8), -- 1140
				r, -- 1140
				35, -- 1140
				145, -- 1140
				1.6, -- 1140
				toColor(PALETTE.crimson, 200 * (1 - r / 34)) -- 1140
			) -- 1140
		end -- 1140
		return -- 1142
	end -- 1142
	fgDraw:drawEllipse( -- 1145
		Vec2(cx, by + 1), -- 1145
		W * 0.56, -- 1145
		3.5, -- 1145
		Color(4, 8, 10, 155) -- 1145
	) -- 1145
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 1146
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 1147
	fgDraw:drawSegment( -- 1150
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 1150
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 1150
		2.8, -- 1150
		Color(26, 30, 34, 255) -- 1150
	) -- 1150
	fgDraw:drawSegment( -- 1151
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 1151
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 1151
		2.8, -- 1151
		Color(36, 40, 44, 255) -- 1151
	) -- 1151
	fgDraw:drawPolygon( -- 1153
		{ -- 1153
			Vec2(cx - W * 0.42, by + H * 0.36), -- 1154
			Vec2(cx + W * 0.38, by + H * 0.42), -- 1155
			Vec2(cx + W * 0.34, by + H * 0.78), -- 1156
			Vec2(cx - W * 0.38, by + H * 0.72) -- 1157
		}, -- 1157
		Color(38, 42, 48, 255), -- 1158
		1.2, -- 1158
		Color(102, 118, 126, 175) -- 1158
	) -- 1158
	local hx = cx + f * W * 0.42 -- 1159
	local hy = by + H * 0.84 -- 1160
	fgDraw:drawPolygon( -- 1161
		{ -- 1161
			Vec2(hx - f * 8, hy - 6), -- 1162
			Vec2(hx + f * 12, hy - 2), -- 1163
			Vec2(hx + f * 4, hy + 8), -- 1164
			Vec2(hx - f * 6, hy + 14) -- 1165
		}, -- 1165
		Color(44, 48, 54, 255) -- 1166
	) -- 1166
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 1168
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 1169
	fgGlow:drawDot( -- 1170
		Vec2(hx + f * 4, hy + 2), -- 1170
		2.8, -- 1170
		toColor(eyeCol, 250) -- 1170
	) -- 1170
	fillRadialGlow( -- 1171
		fgGlow, -- 1171
		hx + f * 4, -- 1171
		hy + 2, -- 1171
		16, -- 1171
		16, -- 1171
		toColor(eyeCol, alert and 135 or 70), -- 1171
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 1171
		12 -- 1171
	) -- 1171
	if alert then -- 1173
		local r = 12 + self.animTime * 42 % 24 -- 1174
		fgGlow:drawArc( -- 1175
			Vec2(hx, hy + 12), -- 1175
			r, -- 1175
			35, -- 1175
			145, -- 1175
			1.8, -- 1175
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 1175
		) -- 1175
	end -- 1175
end -- 1096
return ____exports -- 1096
