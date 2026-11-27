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
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 229
		self.hitStartTick = p.ticks -- 231
		self.hitUntil = p.ticks + 16 -- 232
		self.anim.player:triggerHit(p.player.facing) -- 233
	end -- 233
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 233
		self.throwStartTick = p.ticks -- 236
		self.throwUntil = p.ticks + 16 -- 237
	end -- 237
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 237
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
	local ____opt_0 = self.playerStride -- 249
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 249
		self.playerStride = strideAt(p.player) -- 251
	end -- 251
	local ____opt_2 = self.partnerStride -- 251
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 251
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
	if not p.childMode and a.rollT > 0 then -- 289
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 292
			0, -- 293
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 293
		) -- 293
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 294
		local progress = self:slidePhase(a) -- 295
		self.dustCooldown = self.dustCooldown - dt -- 296
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 296
			local ____self_slideDust_4 = self.slideDust -- 296
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
		if dust.life > 0 then -- 314
			self.slideDust[write + 1] = dust -- 316
			write = write + 1 -- 317
		end -- 317
	end -- 317
	__TS__ArraySetLength(self.slideDust, write) -- 317
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
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 335
		self:drawScavenger( -- 341
			fgDraw, -- 341
			fgGlow, -- 341
			assets, -- 341
			p, -- 341
			cam -- 341
		) -- 341
	end -- 341
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 341
		self:drawDog( -- 346
			fgDraw, -- 346
			fgGlow, -- 346
			assets, -- 346
			p, -- 346
			cam -- 346
		) -- 346
	end -- 346
	if p.partner.alive and not (pose and pose.partner) then -- 346
		local partnerIsChild = p.partner.w <= 28 -- 351
		if partnerIsChild then -- 351
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
	if p.player.alive then -- 355
		if p.childMode then -- 355
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
			local x = cam:sx(dust.x - dust.facing * spread * 17) -- 375
			local y = cam:sy(dust.y + 1.5 + spread * 2, dust.depth) -- 376
			local dustSz = cam:len(14 + spread * 16) -- 377
			local clip = SLIDE_DUST_CLIPS[(spread < 0.45 and 0 or 1) + 1] -- 378
			if not assets:tryPlacePath( -- 378
				clip, -- 379
				"slide_dust_" .. tostring(i), -- 379
				x, -- 379
				y, -- 379
				dustSz * 1.25, -- 379
				dustSz, -- 379
				{ -- 379
					anchorX = 0.5, -- 380
					anchorY = 0, -- 381
					preserveAspect = true, -- 382
					facing = dust.facing, -- 383
					opacity = alpha * 0.85, -- 384
					layer = depthEnabled and depthOrder(dust.depth, 5) or 6 -- 385
				} -- 385
			) then -- 385
				draw:drawEllipse( -- 387
					Vec2(x, y), -- 387
					cam:len(5 + spread * 7), -- 387
					cam:len(1.5 + spread * 2), -- 387
					Color(166, 147, 124, 170 * alpha) -- 388
				) -- 388
				draw:drawDot( -- 389
					Vec2( -- 389
						x - dust.facing * cam:len(3), -- 389
						y + cam:len(4) -- 389
					), -- 389
					cam:len(1.1), -- 390
					Color(195, 174, 148, 135 * alpha) -- 390
				) -- 390
			end -- 390
			i = i + 1 -- 371
		end -- 371
	end -- 371
end -- 369
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 396
	local half = a.w * 0.5 -- 397
	local g = 0 -- 398
	local i = 0 -- 399
	do -- 399
		i = 0 -- 400
		while i < #p.room.floors do -- 400
			local f = p.room.floors[i + 1] -- 401
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 401
				g = f.y -- 403
			end -- 403
			i = i + 1 -- 400
		end -- 400
	end -- 400
	do -- 400
		i = 0 -- 406
		while i < #p.boxes do -- 406
			do -- 406
				local b = p.boxes[i + 1] -- 407
				if b.broken == true or b.hidden == true or b.soft == true then -- 407
					goto __continue46 -- 409
				end -- 409
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 409
					g = b.y1 -- 413
				end -- 413
			end -- 413
			::__continue46:: -- 413
			i = i + 1 -- 406
		end -- 406
	end -- 406
	return g -- 416
end -- 396
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 420
	if bodyPlaced == nil then -- 420
		bodyPlaced = false -- 428
	end -- 428
	local cx = cam:sx(a.x) -- 430
	local by = cam:sy(a.y, a.depth) -- 431
	local depthEnabled = p.room.depth ~= nil -- 432
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 433
	local shadowY = depthEnabled and not a.onGround and cam:sy(groundY, a.depth) or by -- 434
	local airScale = not a.onGround and math.max( -- 435
		0.45, -- 435
		1 - math.max(0, a.y - groundY) / 140 -- 435
	) or 1 -- 435
	local H = cam:len(a.h) -- 436
	local W = cam:len(a.w) -- 437
	local f = a.facing -- 438
	local speed = math.max( -- 439
		math.abs(a.vx), -- 439
		math.abs(a.depthSpeed) -- 439
	) -- 439
	local motion = isControlled and self.anim.player or self.anim.partner -- 440
	local juice = motion:sampleJuice(cam.ppu) -- 441
	local drawX = cx + juice.offsetX -- 442
	local layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 443
	local hitTint = juice.hitFlash > 0.12 and Color( -- 444
		255, -- 445
		math.floor(230 - 38 * juice.hitFlash + 0.5), -- 445
		math.floor(212 - 44 * juice.hitFlash + 0.5), -- 445
		255 -- 445
	) or nil -- 445
	if bodyPlaced then -- 445
		fgDraw:drawEllipse( -- 449
			Vec2(cx, shadowY + 1), -- 449
			W * 0.54 * airScale, -- 449
			4 * airScale, -- 449
			Color(12, 11, 13, 145 * airScale) -- 449
		) -- 449
		return -- 450
	end -- 450
	local slot = "soldier_idle" -- 453
	local animClip = "" -- 454
	local height = H -- 455
	local frame = 0 -- 456
	local facing = f -- 457
	local extraScaleY = 1 -- 458
	local step = math.floor(self.animTime * 10) -- 459
	local ____isControlled_9 -- 460
	if isControlled then -- 460
		____isControlled_9 = self.playerStride -- 460
	else -- 460
		____isControlled_9 = self.partnerStride -- 460
	end -- 460
	local gait = ____isControlled_9 -- 460
	if isControlled and p.ticks < self.hitUntil then -- 460
		slot = "soldier_hit" -- 463
		local elapsed = math.max(0, p.ticks - self.hitStartTick) -- 464
		animClip = ZS_HIT_CLIPS[(elapsed < 7 and 0 or 1) + 1] -- 465
	elseif a.rollT > 0 then -- 465
		slot = "soldier_slide" -- 467
		local progress = self:slidePhase(a) -- 468
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 469
	elseif p.phase == "prologue-give" then -- 469
		slot = "soldier_offer" -- 471
		height = height * 0.75 -- 472
		facing = p.partner.x >= a.x and 1 or -1 -- 473
	elseif isControlled and p.gripping then -- 473
		slot = "soldier_push" -- 475
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 476
		local pushIdx = self.cartMoving and math.floor(motion.pushCycle * 4) % 4 or 0 -- 477
		animClip = ZS_PUSH_CLIPS[pushIdx + 1] -- 478
		frame = self.cartMoving and step or 0 -- 479
		height = height * 0.91 -- 480
	elseif isControlled and p.escort.state == "calming" then -- 480
		slot = "soldier_knock" -- 482
		local calm = p.escort.calmTick -- 483
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 484
		height = height * 0.76 -- 485
	else -- 485
		local ____temp_12 = p.phase == "gate-send" -- 486
		if ____temp_12 then -- 486
			local ____opt_10 = p.room.story -- 486
			____temp_12 = (____opt_10 and ____opt_10.gate) ~= nil -- 486
		end -- 486
		if ____temp_12 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 486
			slot = "soldier_hold" -- 488
			height = height * 1.11 -- 489
		elseif isControlled and p.ticks < self.shotUntil then -- 489
			local running = speed > 8 -- 491
			slot = running and "soldier_fire_move" or "soldier_fire" -- 492
			frame = running and step or 0 -- 493
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 494
			if not running then -- 494
				local elapsed = math.max(0, p.ticks - self.shotStartTick) -- 496
				local fIdx = elapsed < 2 and 0 or (elapsed < 5 and 1 or (elapsed < 11 and 2 or 3)) -- 497
				animClip = ZS_FIRE_CLIPS[fIdx + 1] -- 498
			end -- 498
		elseif a.covered or isControlled and p.coverHug then -- 498
			slot = "soldier_cover" -- 501
			animClip = ZS_COVER_CLIPS[math.floor(motion.coverTime * 2.2) % 2 + 1] -- 502
			extraScaleY = 1 + math.sin(motion.coverTime * 3.1) * 0.012 -- 503
			height = height * 0.77 -- 504
		elseif not a.onGround then -- 504
			local jIdx = a.vy > 110 and 0 or (a.vy > -35 and 1 or 2) -- 506
			animClip = ZS_JUMP_CLIPS[jIdx + 1] -- 507
		elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 507
			animClip = ZS_JUMP_CLIPS[4] -- 509
		elseif (gait and gait.speed or 0) > 8 then -- 509
			slot = "soldier_run" -- 511
			frame = step -- 512
		elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 512
			local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.4) % #IDLE_PING_PONG + 1] -- 514
			if beat >= 0 then -- 514
				animClip = ZS_IDLE_CLIPS[beat + 1] -- 516
			end -- 516
			extraScaleY = 1 + math.sin(motion.idleTime * 2.4) * 0.008 -- 518
		end -- 518
	end -- 518
	local pose = { -- 521
		facing = facing, -- 522
		frame = frame, -- 523
		layer = layer, -- 524
		angle = juice.angleOffset, -- 525
		scaleXMul = juice.scaleXMul, -- 526
		scaleYMul = juice.scaleYMul * extraScaleY, -- 527
		color = hitTint -- 528
	} -- 528
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 530
		"actor_soldier", -- 531
		cx, -- 531
		by, -- 531
		W, -- 531
		height, -- 531
		self:slidePhase(a), -- 531
		{facing = facing, layer = layer} -- 531
	) -- 531
	local running = animClip == "" and (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 532
		"soldier", -- 534
		"actor_soldier", -- 534
		cx, -- 534
		by, -- 534
		W, -- 534
		height, -- 534
		gait.cycle, -- 534
		pose, -- 534
		gait.effort -- 534
	) -- 534
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 535
		animClip, -- 535
		"actor_soldier", -- 535
		drawX, -- 535
		by, -- 535
		H, -- 535
		H, -- 535
		{ -- 535
			anchorX = 0.5, -- 536
			anchorY = 0, -- 537
			preserveAspect = true, -- 538
			facing = facing, -- 539
			angle = juice.angleOffset, -- 540
			scaleXMul = juice.scaleXMul, -- 541
			scaleYMul = juice.scaleYMul * extraScaleY, -- 542
			color = hitTint, -- 543
			layer = layer -- 544
		} -- 544
	) -- 544
	if sliding or running or placedAnim or assets:tryPlace( -- 544
		slot, -- 546
		"actor_soldier", -- 546
		drawX, -- 546
		by, -- 546
		W, -- 546
		height, -- 546
		pose -- 546
	) then -- 546
		fgDraw:drawEllipse( -- 547
			Vec2(cx, shadowY + 1), -- 547
			W * 0.54 * airScale, -- 547
			4 * airScale, -- 547
			Color(12, 11, 13, 145 * airScale) -- 547
		) -- 547
		if juice.hitFlash > 0.35 then -- 547
			fillRadialGlow( -- 549
				fgGlow, -- 549
				drawX, -- 549
				by + H * 0.56, -- 549
				H * 0.38, -- 549
				H * 0.44, -- 549
				Color( -- 550
					255, -- 550
					224, -- 550
					198, -- 550
					math.floor(74 * juice.hitFlash + 0.5) -- 550
				), -- 550
				Color(214, 72, 56, 0), -- 550
				12 -- 550
			) -- 550
		end -- 550
		return -- 552
	end -- 552
	fgDraw:drawEllipse( -- 556
		Vec2(cx, shadowY + 1), -- 556
		H * 0.24, -- 556
		4.5, -- 556
		Color(3, 5, 10, 175) -- 556
	) -- 556
	local walking = speed > 10 and a.onGround -- 558
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 559
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 560
	local calming = not p.childMode and p.escort.state == "calming" -- 561
	local rolling = a.rollT > 0 -- 562
	local crouching = a.covered or calming or rolling -- 563
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 566
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 567
	local sw = H * 0.115 -- 568
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 571
	local kneeY = by + bodyH * 0.23 -- 572
	local stepX = stride * H * 0.15 -- 573
	local legDark = Color(14, 21, 34, 255) -- 574
	local legFront = Color(26, 38, 58, 255) -- 575
	local bkX = cx - f * 4 - stepX * 0.5 -- 577
	local bfX = cx - f * 8 - stepX -- 578
	fgDraw:drawSegment( -- 579
		Vec2(cx - f * 3, hipY), -- 579
		Vec2(bkX, kneeY), -- 579
		H * 0.044, -- 579
		legDark -- 579
	) -- 579
	fgDraw:drawSegment( -- 580
		Vec2(bkX, kneeY), -- 580
		Vec2(bfX, by + 3), -- 580
		H * 0.038, -- 580
		legDark -- 580
	) -- 580
	local fkX = cx + f * 6 + stepX * 0.55 -- 582
	local ffX = cx + f * 7 + stepX -- 583
	fgDraw:drawSegment( -- 584
		Vec2(cx + f * 3, hipY), -- 584
		Vec2(fkX, kneeY), -- 584
		H * 0.048, -- 584
		legFront -- 584
	) -- 584
	fgDraw:drawSegment( -- 585
		Vec2(fkX, kneeY), -- 585
		Vec2(ffX, by + 3), -- 585
		H * 0.042, -- 585
		legFront -- 585
	) -- 585
	fgDraw:drawSegment( -- 587
		Vec2(ffX - f * 2, by + 3), -- 587
		Vec2(ffX + f * 9, by + 3), -- 587
		3.4, -- 587
		Color(42, 60, 86, 255) -- 587
	) -- 587
	local shY = by + bodyH * 0.8 + bob -- 590
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 591
	fgDraw:drawPolygon( -- 592
		{ -- 592
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 593
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 594
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 595
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 596
		}, -- 596
		Color(16, 26, 42, 248), -- 597
		1.2, -- 597
		Color(64, 118, 164, 195) -- 597
	) -- 597
	fgDraw:drawPolygon( -- 600
		{ -- 600
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 601
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 602
			Vec2(cx + sw * 1.05 + lean, shY), -- 603
			Vec2(cx - sw * 0.98 + lean, shY) -- 604
		}, -- 604
		Color(24, 38, 60, 255), -- 605
		1.3, -- 605
		toColor(PALETTE.rimSilver, 190) -- 605
	) -- 605
	fgDraw:drawSegment( -- 607
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 608
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 609
		2.4, -- 610
		Color(173, 155, 125, 225) -- 611
	) -- 611
	fgDraw:drawPolygon( -- 613
		{ -- 613
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 614
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 615
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 616
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 617
		}, -- 617
		Color(99, 105, 103, 248) -- 618
	) -- 618
	local headR = H * 0.088 -- 621
	local headX = cx + lean + f * 3 -- 622
	local headY = shY + headR * 1.35 -- 623
	fgDraw:drawCircle( -- 624
		Vec2(headX, headY - headR * 0.12), -- 624
		headR * 0.86, -- 624
		Color(181, 139, 106, 255) -- 624
	) -- 624
	fgDraw:drawEllipse( -- 625
		Vec2(headX, headY + headR * 0.5), -- 625
		headR * 1.12, -- 625
		headR * 0.72, -- 625
		Color(66, 73, 76, 255) -- 625
	) -- 625
	fgDraw:drawSegment( -- 626
		Vec2(headX - headR, headY + 1), -- 626
		Vec2(headX + headR, headY + 1), -- 626
		1.6, -- 627
		Color(97, 103, 101, 255) -- 627
	) -- 627
	fgDraw:drawSegment( -- 628
		Vec2(headX, headY + headR), -- 628
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 628
		1.6, -- 629
		Color(177, 78, 51, 255) -- 629
	) -- 629
	if isControlled and not calming and not rolling and not p.gripping then -- 629
		local gunPivotX = cx + lean + f * sw * 0.35 -- 633
		local gunPivotY = shY - bodyH * 0.1 -- 634
		local aimDx = f -- 635
		local aimDy = 0 -- 636
		if p.aimX > 0 or p.aimY > 0 then -- 636
			aimDx = p.aimX - gunPivotX -- 638
			aimDy = p.aimY - gunPivotY -- 639
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 640
			if dLen > 4 then -- 640
				aimDx = aimDx / dLen -- 642
				aimDy = aimDy / dLen -- 643
			end -- 643
		end -- 643
		local barrelLen = H * 0.34 -- 646
		local tipX = gunPivotX + aimDx * barrelLen -- 647
		local tipY = gunPivotY + aimDy * barrelLen -- 648
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 649
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 650
		fgDraw:drawSegment( -- 652
			Vec2(cx + lean, shY - 5), -- 652
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 652
			3.6, -- 652
			Color(26, 40, 62, 255) -- 652
		) -- 652
		fgDraw:drawSegment( -- 653
			Vec2(stockX, stockY), -- 653
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 653
			3.8, -- 653
			Color(105, 71, 50, 255) -- 653
		) -- 653
		fgDraw:drawSegment( -- 654
			Vec2(gunPivotX, gunPivotY), -- 654
			Vec2(tipX, tipY), -- 654
			1.8, -- 654
			Color(145, 140, 128, 245) -- 654
		) -- 654
	elseif calming then -- 654
		fgDraw:drawSegment( -- 656
			Vec2(cx + lean, shY - 6), -- 656
			Vec2(cx + f * sw * 2.1, shY - 14), -- 656
			3, -- 656
			Color(196, 222, 240, 235) -- 656
		) -- 656
		fgGlow:drawDot( -- 657
			Vec2(cx + f * sw * 2.15, shY - 14), -- 657
			3.6, -- 657
			toColor(PALETTE.amber, 225) -- 657
		) -- 657
	end -- 657
end -- 420
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 663
	local cx = cam:sx(a.x) -- 672
	local by = cam:sy(a.y, a.depth) -- 673
	local depthEnabled = p.room.depth ~= nil -- 674
	local groundY = not a.onGround and self:supportGroundY(p, a) or a.y -- 675
	local shadowY = depthEnabled and not a.onGround and cam:sy(groundY, a.depth) or by -- 676
	local airScale = not a.onGround and math.max( -- 677
		0.45, -- 677
		1 - math.max(0, a.y - groundY) / 140 -- 677
	) or 1 -- 677
	local H = cam:len(a.h) -- 678
	local W = cam:len(a.w) -- 679
	local f = a.facing -- 680
	local speed = math.max( -- 681
		math.abs(a.vx), -- 681
		math.abs(a.depthSpeed) -- 681
	) -- 681
	local ____isControlled_19 -- 682
	if isControlled then -- 682
		____isControlled_19 = self.playerStride -- 682
	else -- 682
		____isControlled_19 = self.partnerStride -- 682
	end -- 682
	local gait = ____isControlled_19 -- 682
	local motion = isControlled and self.anim.player or self.anim.partner -- 683
	local juice = motion:sampleJuice(cam.ppu) -- 684
	local layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 685
	local afraid = not isControlled and p.escort.fear > 0 -- 687
	local slot = "child_idle" -- 688
	local animClip = "" -- 689
	local height = H -- 690
	local frame = 0 -- 691
	local extraScaleY = 1 -- 692
	local shiverX = 0 -- 693
	local step = math.floor(self.animTime * 10) -- 694
	local nearCover = __TS__ArraySome( -- 695
		p.room.solids, -- 695
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 695
			math.abs(a.x - solid.x), -- 698
			math.abs(a.x - solid.x - solid.w) -- 698
		) <= 30 end -- 698
	) -- 698
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 698
		slot = "child_knock" -- 701
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 701
		slot = "child_offer" -- 704
	elseif isControlled and p.ticks < self.throwUntil then -- 704
		slot = "child_throw" -- 706
		if p.ticks - self.throwStartTick < 7 then -- 706
			animClip = XM_THROW_REL_CLIP -- 708
		end -- 708
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 708
		slot = "child_aim" -- 711
	elseif isControlled and p.gripping then -- 711
		slot = "child_pull" -- 713
		if self.cartMoving then -- 713
			local pBeat = math.floor(motion.pushCycle * 4) % 4 -- 715
			if pBeat == 1 or pBeat == 3 then -- 715
				animClip = XM_PULL_MID_CLIP -- 717
			else -- 717
				frame = pBeat == 2 and 1 or 0 -- 719
			end -- 719
		end -- 719
	elseif afraid and p.escort.state == "frozen" then -- 719
		slot = "child_fear" -- 723
		height = height * 0.74 -- 724
		shiverX = math.sin(self.animTime * 42) * 1.4 -- 725
		if math.floor(self.animTime * 7) % 2 == 1 then -- 725
			animClip = XM_FEAR_B_CLIP -- 727
		end -- 727
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 727
		slot = "child_peek" -- 731
		height = height * 0.83 -- 732
		if math.floor(self.animTime * 2.2) % 2 == 1 then -- 732
			animClip = XM_PEEK_B_CLIP -- 734
		end -- 734
	elseif a.crouch then -- 734
		slot = "child_crouch" -- 737
		local crawlIdx = speed > 6 and math.floor(motion.crouchCycle * 4) % 4 or 0 -- 738
		animClip = XM_CRAWL_CLIPS[crawlIdx + 1] -- 739
		frame = speed > 8 and step or 0 -- 740
	elseif not a.onGround then -- 740
		local jIdx = a.vy > 100 and 0 or (a.vy > -30 and 1 or 2) -- 742
		animClip = XM_JUMP_CLIPS[jIdx + 1] -- 743
	elseif motion.landTimer > 0.05 and (gait and gait.speed or 0) <= 8 then -- 743
		animClip = XM_JUMP_CLIPS[4] -- 745
	elseif (gait and gait.speed or 0) > 8 then -- 745
		slot = "child_run" -- 747
		frame = step -- 748
	elseif motion.idleTime >= 0.14 and (gait and gait.effort or 0) <= 0.001 then -- 748
		local beat = IDLE_PING_PONG[math.floor((motion.idleTime - 0.14) * 3.2) % #IDLE_PING_PONG + 1] -- 750
		if beat >= 0 then -- 750
			animClip = XM_IDLE_CLIPS[beat + 1] -- 752
		end -- 752
		extraScaleY = 1 + math.sin(motion.idleTime * 2.8) * 0.01 -- 754
	end -- 754
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 757
	local drawX = cx + juice.offsetX + shiverX -- 758
	local pose = { -- 759
		facing = facing, -- 760
		frame = frame, -- 761
		layer = layer, -- 762
		angle = juice.angleOffset, -- 763
		scaleXMul = juice.scaleXMul, -- 764
		scaleYMul = juice.scaleYMul * extraScaleY -- 765
	} -- 765
	local running = animClip == "" and (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 767
		"child", -- 769
		"actor_child", -- 769
		cx, -- 769
		by, -- 769
		W, -- 769
		height, -- 769
		gait.cycle, -- 769
		pose, -- 769
		gait.effort -- 769
	) -- 769
	local placedAnim = animClip ~= "" and assets:tryPlacePath( -- 770
		animClip, -- 770
		"actor_child", -- 770
		drawX, -- 770
		by, -- 770
		H, -- 770
		H, -- 770
		{ -- 770
			anchorX = 0.5, -- 771
			anchorY = 0, -- 772
			preserveAspect = true, -- 773
			facing = facing, -- 774
			angle = juice.angleOffset, -- 775
			scaleXMul = juice.scaleXMul, -- 776
			scaleYMul = juice.scaleYMul * extraScaleY, -- 777
			layer = layer -- 778
		} -- 778
	) -- 778
	if running or placedAnim or assets:tryPlace( -- 778
		slot, -- 780
		"actor_child", -- 780
		drawX, -- 780
		by, -- 780
		W, -- 780
		height, -- 780
		pose -- 780
	) then -- 780
		fgDraw:drawEllipse( -- 781
			Vec2(cx, shadowY + 1), -- 781
			W * 0.48 * airScale, -- 781
			3 * airScale, -- 781
			Color(12, 11, 13, 125 * airScale) -- 781
		) -- 781
		if afraid then -- 781
			self:drawFear(fgGlow, p, cx, by + H + 14) -- 783
		end -- 783
		return -- 785
	end -- 785
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 788
	local x = cx + jitter -- 789
	local fullRef = a.crouch and H * 1.35 or H -- 791
	local cw = fullRef * 0.16 -- 792
	fgDraw:drawEllipse( -- 795
		Vec2(x, shadowY + 1), -- 795
		cw * 1.15, -- 795
		3.6, -- 795
		Color(4, 6, 10, 155) -- 795
	) -- 795
	local walking = speed > 6 and a.onGround -- 797
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 798
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 799
	local hipY = by + H * 0.3 -- 802
	local legSwing = stride * cw * 0.85 -- 803
	fgDraw:drawSegment( -- 804
		Vec2(x - 2, hipY), -- 804
		Vec2(x - legSwing, by + 2), -- 804
		math.max(2.6, cw * 0.22), -- 804
		Color(34, 30, 38, 255) -- 804
	) -- 804
	fgDraw:drawSegment( -- 805
		Vec2(x + 2, hipY), -- 805
		Vec2(x + legSwing, by + 2), -- 805
		math.max(2.8, cw * 0.24), -- 805
		Color(52, 46, 56, 255) -- 805
	) -- 805
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 808
	local cloakBotY = by + H * 0.2 -- 809
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 810
	fgDraw:drawPolygon( -- 811
		{ -- 811
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 812
			Vec2(x + cw * 0.92, cloakBotY), -- 813
			Vec2(x + cw * 0.62, cloakTopY), -- 814
			Vec2(x - cw * 0.68, cloakTopY) -- 815
		}, -- 815
		Color(214, 166, 94, 255), -- 816
		1.3, -- 816
		Color(252, 232, 192, 225) -- 816
	) -- 816
	fgDraw:drawPolygon( -- 817
		{ -- 817
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 818
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 819
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 820
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 821
		}, -- 821
		Color(148, 108, 56, 215) -- 822
	) -- 822
	fgDraw:drawSegment( -- 823
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 823
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 823
		1.8, -- 823
		toColor(PALETTE.amberCore, 200) -- 823
	) -- 823
	local scarfY = cloakTopY - 2 -- 826
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 827
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 828
	local sendX = x - f * cw * 1.65 + cloakDrag -- 829
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 830
	fgDraw:drawQuadraticBezier( -- 831
		Vec2(x - f * cw * 0.3, scarfY), -- 831
		Vec2(smidX, smidY), -- 831
		Vec2(sendX, sendY), -- 831
		2.8, -- 831
		toColor(PALETTE.amberCore, 235) -- 831
	) -- 831
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 834
	local headX = x + f * (a.crouch and 5 or 2) -- 835
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 836
	fgDraw:drawCircle( -- 837
		Vec2(headX, headY), -- 837
		headR, -- 837
		Color(240, 222, 198, 255) -- 837
	) -- 837
	fgDraw:drawPolygon( -- 839
		{ -- 839
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 840
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 841
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 842
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 843
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 844
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 845
		}, -- 845
		Color(156, 114, 62, 248), -- 846
		1.1, -- 846
		Color(244, 214, 162, 200) -- 846
	) -- 846
	fgGlow:drawDot( -- 848
		Vec2(headX + f * headR * 0.45, headY + 1), -- 848
		2.2, -- 848
		toColor(PALETTE.amberCore) -- 848
	) -- 848
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 851
	if hasCompass then -- 851
		local compX = x + f * cw * 0.65 -- 853
		local compY = by + H * 0.48 -- 854
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 855
		fgGlow:drawDot( -- 856
			Vec2(compX, compY), -- 856
			2.6, -- 856
			toColor(PALETTE.amberCore, 250) -- 856
		) -- 856
		fillRadialGlow( -- 857
			fgGlow, -- 857
			compX, -- 857
			compY, -- 857
			26 * glowPulse, -- 857
			26 * glowPulse, -- 857
			Color(248, 206, 120, 78 * glowPulse), -- 857
			Color(248, 180, 72, 0), -- 857
			14 -- 857
		) -- 857
	end -- 857
	if afraid then -- 857
		self:drawFear(fgGlow, p, x, by + H + 16) -- 861
	end -- 861
	if isControlled and walking and not a.crouch and speed > 100 then -- 861
		local r = 10 + self.animTime * 32 % 24 -- 866
		fgGlow:drawRing( -- 867
			Vec2(x, by + 3), -- 867
			r, -- 867
			r + 1.5, -- 867
			Color(0, 0, 0, 0), -- 867
			1.1, -- 867
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 867
		) -- 867
	end -- 867
end -- 663
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 871
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 872
	do -- 872
		local i = 0 -- 873
		while i < FEAR_MAX do -- 873
			local lit = i < p.escort.fear -- 874
			drawDiamond( -- 875
				fgGlow, -- 875
				x + (i - 1) * 13, -- 875
				y, -- 875
				4, -- 875
				5, -- 875
				toColor(lit and tint or PALETTE.steelDark, 215), -- 876
				1, -- 876
				toColor(tint, lit and 235 or 100) -- 876
			) -- 876
			i = i + 1 -- 873
		end -- 873
	end -- 873
end -- 871
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 880
	local x = cam:sx(e.x + f * 20) -- 881
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 882
	local dx = cam:sx(p.player.x) - x -- 883
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 884
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 885
	do -- 885
		local i = 0 -- 886
		while i < 8 do -- 886
			local a = length * i / 8 -- 887
			local b = length * (i + 1) / 8 -- 888
			fgGlow:drawSegment( -- 889
				Vec2(x + dx * a, y + dy * a), -- 889
				Vec2(x + dx * b, y + dy * b), -- 889
				1.3, -- 890
				Color(220, 120, 88, 210) -- 890
			) -- 890
			i = i + 2 -- 886
		end -- 886
	end -- 886
end -- 880
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 895
	local cx = cam:sx(e.x) -- 904
	local depth = e.depth or 0 -- 905
	local by = cam:sy(e.y, depth) -- 906
	local H = cam:len(e.h) -- 907
	local W = cam:len(e.w) -- 908
	local f = p.player.x >= e.x and 1 or -1 -- 909
	if e.kind == "target" then -- 909
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 913
		fgDraw:drawEllipse( -- 914
			Vec2(cx, by + 1), -- 914
			W * 0.56, -- 914
			3.6, -- 914
			Color(12, 11, 13, 140) -- 914
		) -- 914
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 915
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 916
		if assets:tryPlacePath( -- 916
			"assets/art/props_ming.clip|target_dummy", -- 917
			"actor_target_" .. tostring(index), -- 917
			cx, -- 917
			by, -- 917
			H * 0.82, -- 917
			H * 0.96, -- 917
			{ -- 917
				anchorX = 0.5, -- 918
				anchorY = 0, -- 919
				preserveAspect = true, -- 920
				angle = angle, -- 921
				color = tint, -- 922
				opacity = e.alive and 1 or 0.76, -- 923
				layer = targetLayer -- 924
			} -- 924
		) then -- 924
			return -- 926
		end -- 926
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 928
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 929
		fgDraw:drawSegment( -- 930
			Vec2( -- 930
				cx - cam:len(9), -- 930
				by -- 930
			), -- 930
			Vec2(cx + lean * 0.4, postTopY), -- 930
			math.max( -- 930
				2, -- 930
				cam:len(3.2) -- 930
			), -- 930
			Color(92, 64, 42, 255) -- 930
		) -- 930
		fgDraw:drawSegment( -- 931
			Vec2( -- 931
				cx + cam:len(9), -- 931
				by -- 931
			), -- 931
			Vec2(cx + lean * 0.4, postTopY), -- 931
			math.max( -- 931
				2, -- 931
				cam:len(3.2) -- 931
			), -- 931
			Color(76, 52, 34, 255) -- 931
		) -- 931
		local discX = cx + lean -- 932
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 933
		local discR = math.max( -- 934
			7, -- 934
			cam:len(13) -- 934
		) -- 934
		local hitTint = e.hitT > 0 or not e.alive -- 935
		fgDraw:drawCircle( -- 936
			Vec2(discX, discY), -- 936
			discR, -- 936
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 936
		) -- 936
		fgDraw:drawRing( -- 937
			Vec2(discX, discY), -- 937
			discR * 0.62, -- 937
			discR * 0.76, -- 937
			Color(0, 0, 0, 0), -- 937
			1.4, -- 937
			Color(62, 46, 34, 230) -- 937
		) -- 937
		fgDraw:drawCircle( -- 938
			Vec2(discX, discY), -- 938
			discR * 0.3, -- 938
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 938
		) -- 938
		return -- 939
	end -- 939
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 942
	local es = index < #self.anim.enemies and self.anim.enemies[index + 1] or nil -- 943
	local moving = (es and es.speed or 0) > 6 -- 944
	local walkStep = math.floor((es and es.walkCycle or 0) * 4) % 2 -- 945
	local hitFlash = es ~= nil and es.hitFlash or 0 -- 946
	local dying = not e.alive and (es and es.deathTime or 1) < 0.15 -- 947
	local breathY = e.alive and not moving and e.hitT <= 0 and 1 + math.sin(self.animTime * 2.4 + (es and es.idlePhase or index)) * 0.014 or 1 -- 948
	local knockX = (e.hitT > 0 or dying) and -f * cam:len(3.5 * math.max(0.3, hitFlash)) or 0 -- 951
	local hitAngle = (e.hitT > 0 or dying) and -f * 5.5 or 0 -- 952
	local enemyClip = "" -- 953
	local enemyTint = hitFlash > 0.12 and Color( -- 954
		255, -- 955
		math.floor(220 - 42 * hitFlash + 0.5), -- 955
		math.floor(196 - 52 * hitFlash + 0.5), -- 955
		255 -- 955
	) or Color(255, 255, 255, 255) -- 955
	local drawHeight = H * 1.01 -- 957
	local cleaving = false -- 958
	if e.kind == "shield" and ((e.shieldHp or 0) > 0 or not e.alive or e.hitT > 0) then -- 958
		if not e.alive then -- 958
			enemyClip = dying and EN_SHD_HIT_CLIP or EN_GUN_DOWN_CLIP -- 962
		elseif e.hitT > 0 then -- 962
			enemyClip = EN_SHD_HIT_CLIP -- 964
		elseif e.warnT > 0 then -- 964
			enemyClip = EN_SHD_BASH_CLIP -- 966
		elseif moving then -- 966
			enemyClip = walkStep == 0 and EN_SHD_WALK_CLIP or EN_SHD_IDLE_CLIP -- 968
		else -- 968
			enemyClip = EN_SHD_IDLE_CLIP -- 970
		end -- 970
		if e.alive and (e.shieldHp or 2) <= 1 and hitFlash <= 0.12 then -- 970
			enemyTint = Color(238, 198, 174, 255) -- 973
		end -- 973
	elseif e.kind == "breaker" then -- 973
		drawHeight = H * 1.03 -- 976
		if not e.alive then -- 976
			enemyClip = dying and EN_BRK_HIT_CLIP or EN_GUN_DOWN_CLIP -- 978
		elseif e.hitT > 0 then -- 978
			enemyClip = EN_BRK_HIT_CLIP -- 980
		elseif (e.swingT or 0) > 0 then -- 980
			cleaving = (es and es.swingTime or 0) >= 0.12 -- 982
			enemyClip = cleaving and EN_BRK_CLEAVE_CLIP or EN_BRK_WINDUP_CLIP -- 983
		elseif e.warnT > 0 then -- 983
			enemyClip = EN_BRK_WINDUP_CLIP -- 985
		else -- 985
			enemyClip = EN_BRK_WALK_CLIP -- 987
		end -- 987
	elseif e.kind == "leader" then -- 987
		drawHeight = H * 1.04 -- 990
		if not e.alive then -- 990
			enemyClip = dying and EN_LDR_HIT_CLIP or EN_GUN_DOWN_CLIP -- 992
		elseif e.hitT > 0 then -- 992
			enemyClip = EN_LDR_HIT_CLIP -- 994
		elseif e.warnT > 0 then -- 994
			enemyClip = EN_LDR_AIM_CLIP -- 996
		elseif moving then -- 996
			enemyClip = walkStep == 0 and EN_LDR_WALK_CLIP or EN_LDR_IDLE_CLIP -- 998
		else -- 998
			enemyClip = EN_LDR_IDLE_CLIP -- 1000
		end -- 1000
	else -- 1000
		if not e.alive then -- 1000
			enemyClip = dying and EN_GUN_HIT_CLIP or EN_GUN_DOWN_CLIP -- 1005
		elseif e.hitT > 0 then -- 1005
			enemyClip = EN_GUN_HIT_CLIP -- 1007
		elseif e.warnT > 0 then -- 1007
			enemyClip = e.warnT <= 6 and EN_GUN_FIRE_CLIP or EN_GUN_AIM_CLIP -- 1009
		elseif moving then -- 1009
			enemyClip = EN_GUN_WALK_CLIPS[walkStep + 1] -- 1011
		else -- 1011
			enemyClip = EN_GUN_IDLE_CLIPS[math.floor((self.animTime + (es and es.idlePhase or index)) * 2.1) % 2 + 1] -- 1013
		end -- 1013
	end -- 1013
	if enemyClip ~= "" and assets:tryPlacePath( -- 1013
		enemyClip, -- 1018
		"actor_enemy_" .. tostring(index), -- 1019
		cx + knockX, -- 1020
		by, -- 1021
		drawHeight, -- 1022
		drawHeight, -- 1023
		{ -- 1024
			anchorX = 0.5, -- 1025
			anchorY = 0, -- 1026
			preserveAspect = true, -- 1027
			facing = f, -- 1028
			angle = hitAngle, -- 1029
			scaleYMul = breathY, -- 1030
			color = enemyTint, -- 1031
			opacity = e.alive and 1 or 0.78, -- 1032
			layer = enemyLayer -- 1033
		} -- 1033
	) then -- 1033
		fgDraw:drawEllipse( -- 1036
			Vec2(cx, by + 1), -- 1036
			W * (e.alive and 0.58 or 0.78), -- 1036
			3.6, -- 1036
			Color(12, 11, 13, e.alive and 145 or 105) -- 1036
		) -- 1036
		if hitFlash > 0.35 then -- 1036
			fillRadialGlow( -- 1038
				fgGlow, -- 1038
				cx + knockX, -- 1038
				by + H * 0.54, -- 1038
				H * 0.34, -- 1038
				H * 0.38, -- 1038
				Color( -- 1039
					255, -- 1039
					224, -- 1039
					186, -- 1039
					math.floor(78 * hitFlash + 0.5) -- 1039
				), -- 1039
				Color(214, 72, 52, 0), -- 1039
				12 -- 1039
			) -- 1039
		end -- 1039
		if cleaving then -- 1039
			fgGlow:drawArc( -- 1042
				Vec2( -- 1042
					cx + f * cam:len(12), -- 1042
					by + H * 0.56 -- 1042
				), -- 1042
				cam:len(22), -- 1042
				f > 0 and -48 or 132, -- 1042
				f > 0 and 54 or 234, -- 1042
				2.4, -- 1042
				toColor(PALETTE.sealRedBright, 215) -- 1042
			) -- 1042
			fgGlow:drawArc( -- 1043
				Vec2( -- 1043
					cx + f * cam:len(12), -- 1043
					by + H * 0.56 -- 1043
				), -- 1043
				cam:len(18), -- 1043
				f > 0 and -40 or 140, -- 1043
				f > 0 and 48 or 228, -- 1043
				1.4, -- 1043
				toColor(PALETTE.amberCore, 185) -- 1043
			) -- 1043
		end -- 1043
		if e.alive and e.warnT > 0 then -- 1043
			self:drawEnemyWarning( -- 1046
				fgGlow, -- 1046
				e, -- 1046
				p, -- 1046
				cam, -- 1046
				f -- 1046
			) -- 1046
		end -- 1046
		return -- 1048
	end -- 1048
	local slot = "enemy_idle" -- 1051
	if not e.alive then -- 1051
		slot = "enemy_down" -- 1053
	elseif e.hitT > 0 then -- 1053
		slot = "enemy_hit" -- 1055
	elseif e.warnT > 0 then -- 1055
		slot = "enemy_aim" -- 1057
	end -- 1057
	local height = e.alive and H or H * 0.24 -- 1059
	if assets:tryPlace( -- 1059
		slot, -- 1060
		"actor_enemy_" .. tostring(index), -- 1060
		cx, -- 1060
		by, -- 1060
		W, -- 1060
		height, -- 1060
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 1060
	) then -- 1060
		if e.alive then -- 1060
			self:drawEnemyArchetypeGear( -- 1064
				fgDraw, -- 1064
				fgGlow, -- 1064
				assets, -- 1064
				e, -- 1064
				index, -- 1064
				cx, -- 1064
				by, -- 1064
				H, -- 1064
				f, -- 1064
				cam, -- 1064
				enemyLayer + 1 -- 1064
			) -- 1064
			if e.warnT > 0 then -- 1064
				self:drawEnemyWarning( -- 1066
					fgGlow, -- 1066
					e, -- 1066
					p, -- 1066
					cam, -- 1066
					f -- 1066
				) -- 1066
			end -- 1066
		end -- 1066
		return -- 1069
	end -- 1069
	if not e.alive then -- 1069
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 1073
		fgDraw:drawPolygon( -- 1074
			{ -- 1074
				Vec2(cx - H * 0.3, by), -- 1075
				Vec2(cx + H * 0.28, by), -- 1076
				Vec2(cx + H * 0.2, by + H * 0.14), -- 1077
				Vec2(cx - H * 0.24, by + H * 0.11) -- 1078
			}, -- 1078
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 1079
		) -- 1079
		if flash > 0 then -- 1079
			fillRadialGlow( -- 1081
				fgGlow, -- 1081
				cx, -- 1081
				by + 12, -- 1081
				34 * flash, -- 1081
				18 * flash, -- 1081
				toColor(PALETTE.crimson, 180 * flash), -- 1081
				Color(255, 48, 82, 0), -- 1081
				12 -- 1081
			) -- 1081
		end -- 1081
		return -- 1083
	end -- 1083
	local sw = H * 0.112 -- 1086
	fgDraw:drawEllipse( -- 1087
		Vec2(cx, by + 1), -- 1087
		sw * 1.9, -- 1087
		4, -- 1087
		Color(4, 6, 10, 165) -- 1087
	) -- 1087
	local hipY = by + H * 0.44 -- 1090
	local kneeY = by + H * 0.23 -- 1091
	local shY = by + H * 0.79 -- 1092
	fgDraw:drawSegment( -- 1093
		Vec2(cx - 5, hipY), -- 1093
		Vec2(cx - 7, kneeY), -- 1093
		H * 0.044, -- 1093
		Color(20, 16, 26, 255) -- 1093
	) -- 1093
	fgDraw:drawSegment( -- 1094
		Vec2(cx - 7, kneeY), -- 1094
		Vec2(cx - 8, by + 2), -- 1094
		H * 0.038, -- 1094
		Color(20, 16, 26, 255) -- 1094
	) -- 1094
	fgDraw:drawSegment( -- 1095
		Vec2(cx + 5, hipY), -- 1095
		Vec2(cx + 7, kneeY), -- 1095
		H * 0.046, -- 1095
		Color(28, 22, 36, 255) -- 1095
	) -- 1095
	fgDraw:drawSegment( -- 1096
		Vec2(cx + 7, kneeY), -- 1096
		Vec2(cx + 8, by + 2), -- 1096
		H * 0.04, -- 1096
		Color(28, 22, 36, 255) -- 1096
	) -- 1096
	fgDraw:drawPolygon( -- 1098
		{ -- 1098
			Vec2(cx - sw * 0.68, hipY), -- 1099
			Vec2(cx + sw * 0.68, hipY), -- 1100
			Vec2(cx + sw * 1.12, shY), -- 1101
			Vec2(cx - sw * 1.12, shY) -- 1102
		}, -- 1102
		Color(111, 68, 55, 255), -- 1103
		1.3, -- 1103
		Color(143, 101, 66, 220) -- 1103
	) -- 1103
	fgDraw:drawPolygon( -- 1104
		{ -- 1104
			Vec2(cx - sw * 1.26, shY - 6), -- 1105
			Vec2(cx + sw * 1.26, shY - 6), -- 1106
			Vec2(cx + sw * 0.96, shY + 5), -- 1107
			Vec2(cx - sw * 0.96, shY + 5) -- 1108
		}, -- 1108
		Color(98, 82, 62, 255) -- 1109
	) -- 1109
	local headR = H * 0.086 -- 1111
	local headY = shY + headR * 1.32 -- 1112
	fgDraw:drawCircle( -- 1113
		Vec2(cx, headY), -- 1113
		headR * 0.82, -- 1113
		Color(187, 142, 103, 255) -- 1113
	) -- 1113
	fgDraw:drawPolygon( -- 1114
		{ -- 1114
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 1115
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 1116
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 1117
		}, -- 1117
		Color(136, 105, 65, 255), -- 1118
		1.1, -- 1118
		Color(177, 145, 91, 220) -- 1118
	) -- 1118
	local gunX = cx + f * H * 0.34 -- 1120
	local gunY = by + H * 0.69 -- 1121
	fgDraw:drawSegment( -- 1122
		Vec2(cx - f * 6, gunY - 2), -- 1122
		Vec2(gunX, gunY), -- 1122
		2.8, -- 1122
		Color(118, 87, 61, 255) -- 1122
	) -- 1122
	self:drawEnemyArchetypeGear( -- 1123
		fgDraw, -- 1123
		fgGlow, -- 1123
		assets, -- 1123
		e, -- 1123
		index, -- 1123
		cx, -- 1123
		by, -- 1123
		H, -- 1123
		f, -- 1123
		cam, -- 1123
		enemyLayer + 1 -- 1123
	) -- 1123
	if e.warnT > 0 then -- 1123
		self:drawEnemyWarning( -- 1125
			fgGlow, -- 1125
			e, -- 1125
			p, -- 1125
			cam, -- 1125
			f -- 1125
		) -- 1125
	end -- 1125
end -- 895
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 1130
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 1130
		local shX = cx + f * cam:len(13) -- 1144
		local cracked = (e.shieldHp or 2) <= 1 -- 1145
		if not assets:tryPlace( -- 1145
			"fe_gear_rattan_shield", -- 1146
			"enemy_shield_" .. tostring(index), -- 1146
			shX, -- 1146
			by + H * 0.44, -- 1146
			cam:len(22), -- 1146
			H * 0.64, -- 1146
			{ -- 1146
				facing = f, -- 1147
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 1148
				layer = layer -- 1149
			} -- 1149
		) then -- 1149
			local shW = math.max( -- 1151
				5, -- 1151
				cam:len(8) -- 1151
			) -- 1151
			fgDraw:drawRect( -- 1152
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 1152
				Color(96, 66, 42, 250), -- 1152
				1.3, -- 1152
				Color(168, 174, 180, 230) -- 1152
			) -- 1152
		end -- 1152
		if cracked then -- 1152
			fgDraw:drawSegment( -- 1155
				Vec2( -- 1155
					shX - cam:len(4), -- 1155
					by + H * 0.3 -- 1155
				), -- 1155
				Vec2( -- 1155
					shX + cam:len(4), -- 1155
					by + H * 0.56 -- 1155
				), -- 1155
				1.4, -- 1155
				Color(24, 18, 16, 235) -- 1155
			) -- 1155
		end -- 1155
	elseif e.kind == "breaker" then -- 1155
		local swing = (e.swingT or 0) > 0 -- 1158
		local handleX0 = cx - f * cam:len(4) -- 1159
		local handleY0 = by + H * 0.44 -- 1160
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 1161
		local tipY = by + H * (swing and 0.46 or 0.78) -- 1162
		fgDraw:drawSegment( -- 1163
			Vec2(handleX0, handleY0), -- 1163
			Vec2(tipX, tipY), -- 1163
			math.max( -- 1163
				2.2, -- 1163
				cam:len(3) -- 1163
			), -- 1163
			Color(98, 66, 44, 255) -- 1163
		) -- 1163
		fgDraw:drawPolygon( -- 1164
			{ -- 1164
				Vec2( -- 1165
					tipX - f * cam:len(3), -- 1165
					tipY - cam:len(4) -- 1165
				), -- 1165
				Vec2( -- 1166
					tipX + f * cam:len(9), -- 1166
					tipY - cam:len(1) -- 1166
				), -- 1166
				Vec2( -- 1167
					tipX + f * cam:len(7), -- 1167
					tipY + cam:len(9) -- 1167
				), -- 1167
				Vec2( -- 1168
					tipX - f * cam:len(2), -- 1168
					tipY + cam:len(6) -- 1168
				) -- 1168
			}, -- 1168
			Color(148, 154, 162, 250), -- 1169
			1, -- 1169
			Color(224, 228, 232, 220) -- 1169
		) -- 1169
		if swing then -- 1169
			fgGlow:drawArc( -- 1171
				Vec2( -- 1171
					cx + f * cam:len(10), -- 1171
					by + H * 0.56 -- 1171
				), -- 1171
				cam:len(18), -- 1171
				f > 0 and -40 or 140, -- 1171
				f > 0 and 50 or 230, -- 1171
				1.8, -- 1171
				toColor(PALETTE.rouge, 195) -- 1171
			) -- 1171
		end -- 1171
	elseif e.kind == "leader" then -- 1171
		local topY = by + H * 1.02 -- 1175
		fgDraw:drawSegment( -- 1176
			Vec2(cx, topY), -- 1176
			Vec2( -- 1176
				cx - f * cam:len(10), -- 1176
				topY + cam:len(9) -- 1176
			), -- 1176
			2.2, -- 1176
			toColor(PALETTE.rouge, 240) -- 1176
		) -- 1176
		fgDraw:drawDot( -- 1177
			Vec2( -- 1177
				cx - f * cam:len(10), -- 1177
				topY + cam:len(9) -- 1177
			), -- 1177
			2.6, -- 1177
			toColor(PALETTE.crimsonCore, 235) -- 1177
		) -- 1177
	end -- 1177
end -- 1130
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 1182
	local s = p.room.scavenger -- 1189
	if s == nil then -- 1189
		return -- 1191
	end -- 1191
	local cx = cam:sx(p.scavX) -- 1193
	local by = cam:sy(s.y) -- 1194
	local H = cam:len(s.h) -- 1195
	local W = cam:len(26) -- 1196
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 1197
	local alert = p.scavChase or p.scavSee > 0 -- 1200
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 1201
	local eyeY = by + H * 0.8 -- 1202
	local coneLen = cam:len(alert and 155 or 115) -- 1203
	fgGlow:drawVertices({ -- 1204
		{ -- 1205
			Vec2(cx + f * 6, eyeY), -- 1205
			toColor(coneCol, alert and 78 or 34) -- 1205
		}, -- 1205
		{ -- 1206
			Vec2(cx + f * coneLen, by + H * 1.05), -- 1206
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1206
		}, -- 1206
		{ -- 1207
			Vec2(cx + f * coneLen, by + 4), -- 1207
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 1207
		} -- 1207
	}) -- 1207
	local scavClip = SCAV_WALK_CLIPS[1] -- 1210
	local frame = 0 -- 1211
	if p.scavState == "turn" then -- 1211
		scavClip = SCAV_TURN_CLIP -- 1213
		frame = 2 -- 1214
	elseif p.scavState == "chase" then -- 1214
		local runBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1216
		scavClip = runBeat == 0 and SCAV_RUN_CLIP or SCAV_WALK_CLIPS[2] -- 1217
		frame = runBeat == 0 and 3 or 1 -- 1218
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 1218
		local walkBeat = math.floor(self.anim.scavCycle * 4) % 2 -- 1220
		scavClip = SCAV_WALK_CLIPS[walkBeat + 1] -- 1221
		frame = walkBeat -- 1222
	end -- 1222
	local scavBreath = (p.scavState == "stall" or p.scavState == "turn") and 1 + math.sin(self.animTime * 2.5) * 0.012 or 1 -- 1224
	if assets:tryPlacePath( -- 1224
		scavClip, -- 1227
		"actor_scav", -- 1227
		cx, -- 1227
		by, -- 1227
		H, -- 1227
		H, -- 1227
		{ -- 1227
			anchorX = 0.5, -- 1228
			anchorY = 0, -- 1229
			preserveAspect = true, -- 1230
			facing = f, -- 1231
			scaleYMul = scavBreath, -- 1232
			layer = 3 -- 1233
		} -- 1233
	) or assets:tryPlace( -- 1233
		"scavenger", -- 1234
		"actor_scav", -- 1234
		cx, -- 1234
		by, -- 1234
		W, -- 1234
		H, -- 1234
		{facing = f, frame = frame, layer = 3} -- 1234
	) then -- 1234
		fgDraw:drawEllipse( -- 1235
			Vec2(cx, by + 1), -- 1235
			W * 0.62, -- 1235
			3.6, -- 1235
			Color(10, 10, 14, 140) -- 1235
		) -- 1235
		local indY = by + H + 16 -- 1236
		if p.scavChase then -- 1236
			drawDiamond( -- 1238
				fgGlow, -- 1238
				cx, -- 1238
				indY, -- 1238
				8, -- 1238
				11, -- 1238
				toColor(PALETTE.crimson, 240), -- 1238
				1.4, -- 1238
				toColor(PALETTE.crimsonCore) -- 1238
			) -- 1238
		elseif p.scavSee > 0 then -- 1238
			local frac = math.min(1, p.scavSee / 24) -- 1240
			fgGlow:drawArc( -- 1241
				Vec2(cx, indY), -- 1241
				10, -- 1241
				90, -- 1241
				90 - 360 * frac, -- 1241
				2.2, -- 1241
				toColor(PALETTE.crimson, 235) -- 1241
			) -- 1241
			fgGlow:drawDot( -- 1242
				Vec2(cx, indY), -- 1242
				2.8, -- 1242
				toColor(PALETTE.amber) -- 1242
			) -- 1242
		elseif p.scavState == "turn" then -- 1242
			drawDiamond( -- 1244
				fgGlow, -- 1244
				cx, -- 1244
				indY, -- 1244
				5.5, -- 1244
				7.5, -- 1244
				toColor(PALETTE.amber, 220) -- 1244
			) -- 1244
		end -- 1244
		return -- 1246
	end -- 1246
	fgDraw:drawEllipse( -- 1249
		Vec2(cx, by + 1), -- 1249
		W * 0.62, -- 1249
		4, -- 1249
		Color(4, 6, 10, 155) -- 1249
	) -- 1249
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1250
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 1251
	fgDraw:drawSegment( -- 1253
		Vec2(cx - 4, by + H * 0.4), -- 1253
		Vec2(cx - stride, by + 2), -- 1253
		W * 0.16, -- 1253
		Color(32, 30, 28, 255) -- 1253
	) -- 1253
	fgDraw:drawSegment( -- 1254
		Vec2(cx + 4, by + H * 0.4), -- 1254
		Vec2(cx + stride, by + 2), -- 1254
		W * 0.16, -- 1254
		Color(44, 40, 36, 255) -- 1254
	) -- 1254
	fgDraw:drawPolygon( -- 1256
		{ -- 1256
			Vec2(cx - W * 0.45, by + H * 0.25), -- 1257
			Vec2(cx + W * 0.42, by + H * 0.25), -- 1258
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 1259
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 1260
		}, -- 1260
		Color(56, 52, 46, 255), -- 1261
		1.2, -- 1261
		Color(128, 118, 100, 180) -- 1261
	) -- 1261
	local headX = cx + f * 5 -- 1263
	local headY = by + H * 0.88 -- 1264
	fgDraw:drawCircle( -- 1265
		Vec2(headX, headY), -- 1265
		W * 0.3, -- 1265
		Color(42, 38, 34, 255) -- 1265
	) -- 1265
	fgGlow:drawDot( -- 1266
		Vec2(headX + f * 6, headY), -- 1266
		3, -- 1266
		toColor(coneCol, 245) -- 1266
	) -- 1266
	local indY = by + H + 18 -- 1269
	if p.scavChase then -- 1269
		drawDiamond( -- 1271
			fgGlow, -- 1271
			cx, -- 1271
			indY, -- 1271
			9, -- 1271
			12, -- 1271
			toColor(PALETTE.crimson, 240), -- 1271
			1.5, -- 1271
			toColor(PALETTE.crimsonCore) -- 1271
		) -- 1271
	elseif p.scavSee > 0 then -- 1271
		local frac = math.min(1, p.scavSee / 24) -- 1273
		fgGlow:drawArc( -- 1274
			Vec2(cx, indY), -- 1274
			11, -- 1274
			90, -- 1274
			90 - 360 * frac, -- 1274
			2.4, -- 1274
			toColor(PALETTE.crimson, 235) -- 1274
		) -- 1274
		fgGlow:drawDot( -- 1275
			Vec2(cx, indY), -- 1275
			3, -- 1275
			toColor(PALETTE.amber) -- 1275
		) -- 1275
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 1275
		drawDiamond( -- 1277
			fgGlow, -- 1277
			cx, -- 1277
			indY, -- 1277
			6, -- 1277
			8, -- 1277
			toColor(PALETTE.amber, 220) -- 1277
		) -- 1277
	end -- 1277
end -- 1182
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 1282
	local cx = cam:sx(p.dogX) -- 1289
	local by = cam:sy(0) -- 1290
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 1291
	local W = cam:len(34) -- 1292
	local H = cam:len(28) -- 1293
	local dogClip = DOG_WALK_CLIP -- 1295
	local frame = 0 -- 1296
	if p.dogState == "ear" then -- 1296
		dogClip = DOG_ALERT_CLIP -- 1298
		frame = 1 -- 1299
	elseif p.dogState == "sniff" then -- 1299
		dogClip = DOG_WALK_CLIP -- 1301
		frame = 3 -- 1302
	elseif p.dogState == "chase" then -- 1302
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1304
		dogClip = DOG_RUN_CLIPS[beat + 1] -- 1305
		frame = beat == 0 and 0 or 2 -- 1306
	elseif p.dogState == "patrol" or p.dogState == "back" then -- 1306
		local beat = math.floor(self.anim.dogCycle * 4) % 2 -- 1308
		dogClip = beat == 0 and DOG_WALK_CLIP or DOG_RUN_CLIPS[2] -- 1309
		frame = beat == 0 and 0 or 2 -- 1310
	end -- 1310
	local dogH = H * 1.12 -- 1312
	if assets:tryPlacePath( -- 1312
		dogClip, -- 1313
		"actor_dog", -- 1313
		cx, -- 1313
		by, -- 1313
		dogH, -- 1313
		dogH, -- 1313
		{ -- 1313
			anchorX = 0.5, -- 1314
			anchorY = 0, -- 1315
			preserveAspect = true, -- 1316
			facing = f, -- 1317
			layer = 3 -- 1318
		} -- 1318
	) or assets:tryPlace( -- 1318
		"dog", -- 1319
		"actor_dog", -- 1319
		cx, -- 1319
		by, -- 1319
		W, -- 1319
		H, -- 1319
		{facing = f, frame = frame, layer = 3} -- 1319
	) then -- 1319
		fgDraw:drawEllipse( -- 1320
			Vec2(cx, by + 1), -- 1320
			W * 0.56, -- 1320
			3.2, -- 1320
			Color(10, 10, 14, 140) -- 1320
		) -- 1320
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 1321
		if alert then -- 1321
			local hx = cx + f * W * 0.34 -- 1323
			local hy = by + H * 0.86 -- 1324
			local r = 10 + self.animTime * 40 % 22 -- 1325
			fgGlow:drawArc( -- 1326
				Vec2(hx, hy + 8), -- 1326
				r, -- 1326
				35, -- 1326
				145, -- 1326
				1.6, -- 1326
				toColor(PALETTE.crimson, 200 * (1 - r / 34)) -- 1326
			) -- 1326
		end -- 1326
		return -- 1328
	end -- 1328
	fgDraw:drawEllipse( -- 1331
		Vec2(cx, by + 1), -- 1331
		W * 0.56, -- 1331
		3.5, -- 1331
		Color(4, 8, 10, 155) -- 1331
	) -- 1331
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 1332
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 1333
	fgDraw:drawSegment( -- 1336
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 1336
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 1336
		2.8, -- 1336
		Color(26, 30, 34, 255) -- 1336
	) -- 1336
	fgDraw:drawSegment( -- 1337
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 1337
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 1337
		2.8, -- 1337
		Color(36, 40, 44, 255) -- 1337
	) -- 1337
	fgDraw:drawPolygon( -- 1339
		{ -- 1339
			Vec2(cx - W * 0.42, by + H * 0.36), -- 1340
			Vec2(cx + W * 0.38, by + H * 0.42), -- 1341
			Vec2(cx + W * 0.34, by + H * 0.78), -- 1342
			Vec2(cx - W * 0.38, by + H * 0.72) -- 1343
		}, -- 1343
		Color(38, 42, 48, 255), -- 1344
		1.2, -- 1344
		Color(102, 118, 126, 175) -- 1344
	) -- 1344
	local hx = cx + f * W * 0.42 -- 1345
	local hy = by + H * 0.84 -- 1346
	fgDraw:drawPolygon( -- 1347
		{ -- 1347
			Vec2(hx - f * 8, hy - 6), -- 1348
			Vec2(hx + f * 12, hy - 2), -- 1349
			Vec2(hx + f * 4, hy + 8), -- 1350
			Vec2(hx - f * 6, hy + 14) -- 1351
		}, -- 1351
		Color(44, 48, 54, 255) -- 1352
	) -- 1352
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 1354
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 1355
	fgGlow:drawDot( -- 1356
		Vec2(hx + f * 4, hy + 2), -- 1356
		2.8, -- 1356
		toColor(eyeCol, 250) -- 1356
	) -- 1356
	fillRadialGlow( -- 1357
		fgGlow, -- 1357
		hx + f * 4, -- 1357
		hy + 2, -- 1357
		16, -- 1357
		16, -- 1357
		toColor(eyeCol, alert and 135 or 70), -- 1357
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 1357
		12 -- 1357
	) -- 1357
	if alert then -- 1357
		local r = 12 + self.animTime * 42 % 24 -- 1360
		fgGlow:drawArc( -- 1361
			Vec2(hx, hy + 12), -- 1361
			r, -- 1361
			35, -- 1361
			145, -- 1361
			1.8, -- 1361
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 1361
		) -- 1361
	end -- 1361
end -- 1282
return ____exports -- 1282