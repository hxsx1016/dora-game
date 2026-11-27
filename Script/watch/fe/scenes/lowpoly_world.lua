-- [ts]: lowpoly_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
local Rect = ____Dora.Rect -- 18
local Vec2 = ____Dora.Vec2 -- 18
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 24
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 25
local LowpolyScene = ____lowpoly.LowpolyScene -- 27
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 28
local OUTSIDE_JETTY_LIGHT = ____lowpoly.OUTSIDE_JETTY_LIGHT -- 29
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 30
local buildOutsideJettyLowpoly = ____lowpoly.buildOutsideJettyLowpoly -- 31
local clamp01 = ____lowpoly.clamp01 -- 32
local projectWorld3D = ____lowpoly.projectWorld3D -- 33
local smoothstep = ____lowpoly.smoothstep -- 34
local vec3 = ____lowpoly.vec3 -- 35
local ____village_undertable = require("Script.watch.fe.scenes.village_undertable") -- 37
local VillageUndertableScene = ____village_undertable.VillageUndertableScene -- 40
local ____forest_creek = require("Script.watch.fe.scenes.forest_creek") -- 42
local ForestCreekScene = ____forest_creek.ForestCreekScene -- 44
local ____theme = require("Script.watch.fe.theme") -- 46
local fillRadialGlow = ____theme.fillRadialGlow -- 47
local fillVGradRect = ____theme.fillVGradRect -- 48
local rgba = ____theme.rgba -- 49
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 53
--- 首次握车柄家人缝布回忆总时长（秒）：约半秒叠画再落回车柄，拉车输入全程不断档
local SEWING_MEMORY_DURATION = 0.54 -- 55
____exports.LowpolyWorldPlugin = __TS__Class() -- 76
local LowpolyWorldPlugin = ____exports.LowpolyWorldPlugin -- 76
LowpolyWorldPlugin.name = "LowpolyWorldPlugin" -- 76
function LowpolyWorldPlugin.prototype.____constructor(self) -- 76
	self.id = "fe-04-child-lowpoly" -- 77
	self.village = __TS__New(VillageUndertableScene) -- 79
	self.forest = __TS__New(ForestCreekScene) -- 80
	self.active = false -- 82
	self.wasActive = false -- 83
	self.activeRoomKey = "" -- 84
	self.animTime = 0 -- 85
	self.prevGripping = false -- 88
	self.prevCartAxle = 0 -- 89
	self.cartWheelVol = 0 -- 90
	self.cartClothLeftInvariantOk = true -- 91
	self.lastCartClothX = 0 -- 92
	self.lastCartAxle = 0 -- 93
	self.memoryPlayed = false -- 94
	self.memoryTriggeredCount = 0 -- 95
	self.memoryTimer = -1 -- 96
	self.memoryAnchorWorldX = 344 -- 97
	self.memoryAnchorWorldY = 122 -- 98
	self.outsideProj = { -- 100
		morph = 1, -- 101
		focal = 410, -- 102
		vpFracX = 0.54, -- 103
		vpFracY = 0.52, -- 104
		vpOffsetX = 0, -- 105
		vpOffsetY = 0, -- 106
		baseDepth = 0 -- 107
	} -- 107
	self.towerProj = { -- 110
		morph = 1, -- 111
		focal = 415, -- 112
		vpFracX = 0.52, -- 113
		vpFracY = 0.5, -- 114
		vpOffsetX = 0, -- 115
		vpOffsetY = 0, -- 116
		baseDepth = 0 -- 117
	} -- 117
end -- 76
function LowpolyWorldPlugin.prototype.onBindPlay(self, p, _view) -- 120
	self:resetRoomState(p) -- 121
	self:syncRuntimeHook() -- 122
end -- 120
function LowpolyWorldPlugin.prototype.resetRoomState(self, p) -- 125
	self.active = false -- 126
	self.wasActive = false -- 127
	self.activeRoomKey = p ~= nil and p.room.key or "" -- 128
	self.animTime = 0 -- 129
	self.prevGripping = false -- 130
	self.prevCartAxle = p ~= nil and p.cartAxle or 0 -- 131
	self.cartWheelVol = 0 -- 132
	self.cartClothLeftInvariantOk = true -- 133
	self.lastCartAxle = self.prevCartAxle -- 134
	self.lastCartClothX = p ~= nil and p.room.cart.bodyW > 0 and p.cartAxle - p.room.cart.bodyW * 0.5 or 0 -- 135
	self.memoryPlayed = false -- 136
	self.memoryTriggeredCount = 0 -- 137
	self.memoryTimer = -1 -- 138
	self.village:reset() -- 139
	self.forest:reset() -- 140
end -- 125
function LowpolyWorldPlugin.prototype.syncRuntimeHook(self) -- 143
	local g = _G -- 144
	local ____temp_0 -- 145
	if g.package ~= nil then -- 145
		____temp_0 = g.package.loaded -- 145
	else -- 145
		____temp_0 = nil -- 145
	end -- 145
	local loaded = ____temp_0 -- 145
	if loaded == nil then -- 146
		return -- 147
	end -- 147
	local rawFe = loaded["watch.fe"] -- 149
	if rawFe ~= nil and type(rawFe) == "table" then -- 150
		local watchFe = rawFe -- 151
		if watchFe.lowpolyWorld ~= self then -- 152
			watchFe.lowpolyWorld = self -- 153
		end -- 153
	end -- 153
end -- 143
function LowpolyWorldPlugin.prototype.isLowpolyChildRoom(self, roomKey) -- 158
	return roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" -- 159
end -- 158
function LowpolyWorldPlugin.prototype.shouldActivate(self, ctx) -- 162
	return ctx.view.visualMode == "lowpoly" and self:isLowpolyChildRoom(ctx.p.room.key) -- 163
end -- 162
function LowpolyWorldPlugin.prototype.getActiveProjection(self, roomKey) -- 166
	local key = roomKey or self.activeRoomKey -- 167
	if key == "village" then -- 168
		return self.village:getProjection() -- 169
	end -- 169
	if key == "forest" then -- 171
		return self.forest:getProjection() -- 172
	end -- 172
	if key == "tower" then -- 174
		return self.towerProj -- 175
	end -- 175
	return self.outsideProj -- 177
end -- 166
function LowpolyWorldPlugin.prototype.getDebugState(self, p) -- 180
	local memActive = self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION -- 181
	return { -- 182
		active = self.active, -- 183
		roomKey = self.activeRoomKey, -- 184
		outside = { -- 185
			active = self.active and self.activeRoomKey == "outside", -- 186
			cartClothLeftInvariantOk = self.cartClothLeftInvariantOk, -- 187
			cartClothWorldX = self.lastCartClothX, -- 188
			cartAxleWorldX = self.lastCartAxle, -- 189
			memoryTriggeredCount = self.memoryTriggeredCount, -- 190
			memoryActive = memActive, -- 191
			memoryProgress = memActive and clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) or (self.memoryPlayed and 1 or 0), -- 192
			cartWheelVol = self.cartWheelVol -- 193
		}, -- 193
		village = self.village:getDebugState(p), -- 195
		forest = self.forest:getDebugState(p) -- 196
	} -- 196
end -- 180
function LowpolyWorldPlugin.prototype.rehearseOutsideSewingMemory(self, progress) -- 201
	self.memoryPlayed = true -- 202
	self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 203
	self.memoryTimer = progress ~= nil and clamp01(progress) * SEWING_MEMORY_DURATION or 0 -- 204
end -- 201
function LowpolyWorldPlugin.prototype.rehearseVillageImpact(self, ctx, surface) -- 208
	self.village:triggerRehearsalImpact(ctx, surface) -- 209
end -- 208
function LowpolyWorldPlugin.prototype.stopAllAudioLoops(self, ctx) -- 212
	ctx.audio:stopLoop("fe04_outside_wind", 0.2) -- 213
	ctx.audio:stopLoop("fe04_cart_wheel", 0.15) -- 214
	ctx.audio:stopLoop("fe04_village_night", 0.2) -- 215
	ctx.audio:stopLoop("fe04_forest_wind", 0.2) -- 216
	ctx.audio:stopLoop("fe04_creek_water", 0.2) -- 217
end -- 212
function LowpolyWorldPlugin.prototype.update(self, ctx) -- 220
	self:syncRuntimeHook() -- 221
	local want = self:shouldActivate(ctx) -- 222
	if not want then -- 223
		if self.wasActive then -- 224
			ctx.cam:setAnchorLock(nil) -- 225
			self:stopAllAudioLoops(ctx) -- 226
			self.wasActive = false -- 227
		end -- 227
		self.active = false -- 229
		return -- 230
	end -- 230
	local p = ctx.p -- 233
	if self.activeRoomKey ~= "" and self.activeRoomKey ~= p.room.key then -- 234
		ctx.cam:setAnchorLock(nil) -- 235
		self:stopAllAudioLoops(ctx) -- 236
		self:resetRoomState(p) -- 237
	end -- 237
	self.active = true -- 240
	self.wasActive = true -- 241
	self.activeRoomKey = p.room.key -- 242
	if not ctx.paused and ctx.worldDt > 0 then -- 244
		self.animTime = self.animTime + ctx.worldDt -- 245
	end -- 245
	if p.room.key == "outside" then -- 248
		self:updateOutside(ctx) -- 249
	elseif p.room.key == "village" then -- 250
		self.village:update(ctx) -- 251
	elseif p.room.key == "forest" then -- 252
		self.forest:update(ctx) -- 253
	elseif p.room.key == "tower" then -- 254
		ctx.cam:setAnchorLock(nil) -- 255
		self.towerProj = { -- 256
			morph = 1, -- 257
			focal = 415, -- 258
			vpFracX = 0.52, -- 259
			vpFracY = 0.5, -- 260
			vpOffsetX = math.sin(self.animTime * 0.45) * 1.2, -- 261
			vpOffsetY = math.cos(self.animTime * 0.6) * 0.8, -- 262
			baseDepth = 0 -- 263
		} -- 263
	end -- 263
end -- 220
function LowpolyWorldPlugin.prototype.updateOutside(self, ctx) -- 268
	local p = ctx.p -- 269
	ctx.cam:setAnchorLock(nil) -- 270
	local c = p.room.cart -- 272
	if c.bodyW > 0 then -- 273
		self.lastCartAxle = p.cartAxle -- 275
		self.lastCartClothX = p.cartAxle - c.bodyW * 0.5 -- 276
		if self.lastCartClothX >= self.lastCartAxle or c.clothSide >= 0 then -- 277
			self.cartClothLeftInvariantOk = false -- 278
		end -- 278
		self.memoryAnchorWorldX = p.cartAxle + c.handleOffset -- 280
		self.memoryAnchorWorldY = c.baseY + c.wheelR + c.bodyH * 0.72 -- 281
	end -- 281
	if not ctx.paused and ctx.worldDt > 0 then -- 284
		local dt = ctx.worldDt -- 285
		local redCartMemTrigger = p.redCartMemoryT > 0 and not self.memoryPlayed -- 288
		if (p.gripping and not self.prevGripping or redCartMemTrigger) and not self.memoryPlayed then -- 289
			self.memoryPlayed = true -- 290
			self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 291
			self.memoryTimer = 0 -- 292
			if redCartMemTrigger then -- 293
				self.memoryAnchorWorldX = p.player.x -- 294
				self.memoryAnchorWorldY = p.player.y + 36 -- 295
			end -- 295
			ctx.audio:playOnce( -- 297
				"fe04:outside:sewing:" .. tostring(ctx.events.roomSessionId), -- 298
				"ambience", -- 299
				CHILD_AUDIO_ROOT .. "sewing_memory.wav", -- 300
				0.68, -- 301
				"fe04:outside:sewing_memory", -- 302
				p.ticks -- 303
			) -- 303
		end -- 303
		self.prevGripping = p.gripping -- 306
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 308
			self.memoryTimer = math.min(SEWING_MEMORY_DURATION, self.memoryTimer + dt) -- 309
		end -- 309
		local cartSpeed = math.abs(p.cartAxle - self.prevCartAxle) / math.max(0.001, dt) -- 313
		self.prevCartAxle = p.cartAxle -- 314
		local targetWheelVol = cartSpeed > 4 and math.min(0.54, 0.22 + cartSpeed / 64 * 0.32) or 0 -- 315
		self.cartWheelVol = self.cartWheelVol + (targetWheelVol - self.cartWheelVol) * math.min(1, dt * 10) -- 316
		ctx.audio:playLoop( -- 318
			"fe04_outside_wind", -- 318
			"wind", -- 318
			CHILD_AUDIO_ROOT .. "wind_outside_loop.wav", -- 318
			0.36, -- 318
			p.ticks -- 318
		) -- 318
		if self.cartWheelVol > 0.03 then -- 319
			ctx.audio:playLoop( -- 320
				"fe04_cart_wheel", -- 320
				"ambience", -- 320
				CHILD_AUDIO_ROOT .. "cart_wheel_loop.wav", -- 320
				self.cartWheelVol, -- 320
				p.ticks -- 320
			) -- 320
		else -- 320
			ctx.audio:stopLoop("fe04_cart_wheel", 0.12) -- 322
		end -- 322
	end -- 322
	self.outsideProj = { -- 326
		morph = 1, -- 327
		focal = 410, -- 328
		vpFracX = 0.54, -- 329
		vpFracY = 0.52, -- 330
		vpOffsetX = math.sin(self.animTime * 0.52) * 1.5, -- 331
		vpOffsetY = math.cos(self.animTime * 0.68) * 1, -- 332
		baseDepth = 0 -- 333
	} -- 333
end -- 268
function LowpolyWorldPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 337
	if not self.active then -- 343
		return false -- 344
	end -- 344
	local key = ctx.p.room.key -- 346
	if key == "village" then -- 347
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 348
	end -- 348
	if key == "forest" then -- 350
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 351
	end -- 351
	if key == "outside" then -- 353
		return self:drawOutsideBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 354
	end -- 354
	if key == "tower" then -- 356
		return self:drawTowerBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 357
	end -- 357
	return false -- 359
end -- 337
function LowpolyWorldPlugin.prototype.drawOutsideBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 362
	local p = ctx.p -- 368
	local cam = ctx.cam -- 369
	local w = cam.viewW -- 370
	local h = cam.viewH -- 371
	local ox = p.ox -- 372
	local span = math.max(1, p.room.maxX - p.room.minX) -- 375
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 376
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 377
	local artH = artW * 9 / 16 -- 378
	local artY = math.min( -- 379
		0, -- 379
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 379
	) -- 379
	local hasPainted = backdropArt:tryPlace( -- 380
		"bgFar_outside", -- 380
		"lp_bg_outside", -- 380
		w * (0.5 - progress * 0.08), -- 380
		artY, -- 380
		artW, -- 380
		artH, -- 380
		{ -- 380
			color = Color(156, 172, 198, 255), -- 381
			opacity = 0.9, -- 382
			layer = 0 -- 383
		} -- 383
	) -- 383
	local splitY = h * 0.48 -- 387
	fillVGradRect( -- 388
		bgDraw, -- 388
		0, -- 388
		splitY, -- 388
		w, -- 388
		h - splitY, -- 388
		Color(16, 25, 38, 255), -- 388
		Color(8, 13, 22, 255) -- 388
	) -- 388
	fillVGradRect( -- 389
		bgDraw, -- 389
		0, -- 389
		0, -- 389
		w, -- 389
		splitY, -- 389
		Color(28, 42, 60, 255), -- 389
		Color(16, 25, 38, 255) -- 389
	) -- 389
	if not hasPainted then -- 391
		local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 392
		scene:addBox({ -- 393
			x0 = ox - 160, -- 394
			x1 = ox + 1360, -- 395
			y0 = -48, -- 396
			y1 = 112, -- 397
			z0 = 230, -- 398
			z1 = 274, -- 399
			material = MING_MATERIALS.distantWall, -- 400
			bucket = LP_BUCKET.BACKDROP, -- 401
			edgeWidth = 0 -- 402
		}) -- 402
		scene:addFogBand( -- 404
			ox - 180, -- 404
			ox + 1420, -- 404
			-34, -- 404
			152, -- 404
			180, -- 404
			rgba(28, 42, 60, 255), -- 404
			0.58, -- 404
			0.06, -- 404
			{bucket = LP_BUCKET.BACKDROP} -- 404
		) -- 404
		scene:flush(bgDraw, bgGlow) -- 407
	end -- 407
	local mistShift = (self.animTime * 11 + cam.x * 0.14) % (w + 460) - 230 -- 411
	backdropArt:tryPlace( -- 412
		"ink_mist_curve", -- 412
		"lp_outside_mist_a", -- 412
		mistShift, -- 412
		h * 0.32, -- 412
		640, -- 412
		128, -- 412
		{ -- 412
			color = Color(148, 174, 198, 255), -- 413
			opacity = 0.22, -- 414
			layer = 4 -- 415
		} -- 415
	) -- 415
	backdropArt:tryPlace( -- 417
		"ink_mist_curve", -- 417
		"lp_outside_mist_b", -- 417
		(mistShift + w * 0.54) % (w + 460) - 230, -- 417
		h * 0.44, -- 417
		540, -- 417
		108, -- 417
		{ -- 417
			color = Color(118, 146, 176, 255), -- 418
			opacity = 0.16, -- 419
			layer = 4, -- 420
			facing = -1 -- 421
		} -- 421
	) -- 421
	local moonX = w * 0.8 -- 425
	local moonY = h * 0.84 -- 426
	fillRadialGlow( -- 427
		bgGlow, -- 427
		moonX, -- 427
		moonY, -- 427
		88, -- 427
		88, -- 427
		Color(172, 206, 232, 30), -- 427
		Color(24, 42, 68, 0), -- 427
		16 -- 427
	) -- 427
	local beaconP = projectWorld3D( -- 429
		ox + 1140, -- 429
		154, -- 429
		410, -- 429
		cam, -- 429
		self.outsideProj -- 429
	) -- 429
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 430
	fillRadialGlow( -- 431
		bgGlow, -- 431
		beaconP.x, -- 431
		beaconP.y, -- 431
		38 * pulse, -- 431
		38 * pulse, -- 431
		Color( -- 431
			246, -- 431
			208, -- 431
			138, -- 431
			math.floor(108 * pulse + 0.5) -- 431
		), -- 431
		Color(232, 176, 86, 0), -- 431
		14 -- 431
	) -- 431
	bgGlow:drawDot( -- 432
		Vec2(beaconP.x, beaconP.y), -- 432
		2.8, -- 432
		Color(255, 244, 212, 245) -- 432
	) -- 432
	return true -- 434
end -- 362
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 437
	local cam = ctx.cam -- 443
	local p = ctx.p -- 444
	local ox = p.ox -- 445
	local w = cam.viewW -- 446
	local h = cam.viewH -- 447
	local span = math.max(1, p.room.maxX - p.room.minX) -- 450
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 451
	local artW = math.max(w, h * 16 / 9) * 1.22 -- 452
	local artH = artW * 9 / 16 -- 453
	local artY = math.min( -- 454
		0, -- 454
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 454
	) -- 454
	local hasPainted = backdropArt:tryPlace( -- 455
		"bgFar_tower", -- 455
		"lp_bg_tower", -- 455
		w * (0.5 - progress * 0.06), -- 455
		artY, -- 455
		artW, -- 455
		artH, -- 455
		{ -- 455
			color = Color(182, 190, 208, 255), -- 456
			opacity = 0.92, -- 457
			layer = 0 -- 458
		} -- 458
	) -- 458
	local splitY = h * 0.46 -- 461
	fillVGradRect( -- 462
		bgDraw, -- 462
		0, -- 462
		splitY, -- 462
		w, -- 462
		h - splitY, -- 462
		Color(24, 34, 52, 255), -- 462
		Color(12, 18, 30, 255) -- 462
	) -- 462
	fillVGradRect( -- 463
		bgDraw, -- 463
		0, -- 463
		0, -- 463
		w, -- 463
		splitY, -- 463
		Color(46, 54, 70, 255), -- 463
		Color(24, 34, 52, 255) -- 463
	) -- 463
	if not hasPainted then -- 465
		local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 466
		scene:addDistantRidge( -- 467
			{ -- 468
				{x = ox - 180, y = 118}, -- 469
				{x = ox + 90, y = 172}, -- 470
				{x = ox + 360, y = 146}, -- 471
				{x = ox + 640, y = 184}, -- 472
				{x = ox + 920, y = 132} -- 473
			}, -- 473
			-40, -- 475
			420, -- 476
			MING_MATERIALS.distantHill, -- 477
			{bucket = LP_BUCKET.BACKDROP} -- 478
		) -- 478
		scene:flush(bgDraw, bgGlow) -- 480
	end -- 480
	local mistX = self.animTime * 8 % (w + 420) - 210 -- 484
	backdropArt:tryPlace( -- 485
		"ink_mist_curve", -- 485
		"lp_tower_mist", -- 485
		mistX, -- 485
		h * 0.28, -- 485
		600, -- 485
		120, -- 485
		{ -- 485
			color = Color(168, 178, 198, 255), -- 486
			opacity = 0.2, -- 487
			layer = 4 -- 488
		} -- 488
	) -- 488
	local dawnPulse = 0.9 + 0.1 * math.sin(self.animTime * 1.6) -- 490
	fillRadialGlow( -- 491
		bgGlow, -- 491
		w * 0.42, -- 491
		h * 0.62, -- 491
		w * 0.36, -- 491
		h * 0.22, -- 491
		Color( -- 492
			232, -- 492
			192, -- 492
			138, -- 492
			math.floor(34 * dawnPulse + 0.5) -- 492
		), -- 492
		Color(232, 192, 138, 0), -- 492
		16 -- 492
	) -- 492
	return true -- 494
end -- 437
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 497
	if not self.active then -- 503
		return false -- 504
	end -- 504
	local key = ctx.p.room.key -- 506
	if key == "village" then -- 507
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 508
	end -- 508
	if key == "forest" then -- 510
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 511
	end -- 511
	if key == "outside" then -- 513
		return self:drawOutsideWorld(fgDraw, fgGlow, worldArt, ctx) -- 514
	end -- 514
	if key == "tower" then -- 516
		return self:drawTowerWorld(fgDraw, fgGlow, worldArt, ctx) -- 517
	end -- 517
	return false -- 519
end -- 497
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 522
	local p = ctx.p -- 528
	local cam = ctx.cam -- 529
	local ox = p.ox -- 530
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 531
	buildOutsideJettyLowpoly( -- 534
		scene, -- 534
		p.room, -- 534
		p.player.x, -- 534
		p.player.y, -- 534
		p.cartAxle, -- 534
		self.animTime, -- 534
		true -- 534
	) -- 534
	local redBox = __TS__ArrayFind( -- 537
		p.boxes, -- 537
		function(____, b) return b.id == "outside_red_cart" end -- 537
	) -- 537
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 538
		local rcx = cam:sx((redBox.x0 + redBox.x1) * 0.5) -- 539
		local rby = cam:sy(redBox.y0) -- 540
		local rw = cam:len(math.max(46, (redBox.x1 - redBox.x0) * 1.25)) -- 541
		local rh = cam:len(math.max(26, (redBox.y1 - redBox.y0) * 0.95)) -- 542
		if not worldArt:tryPlace( -- 543
			"prop_cart", -- 543
			"lp_outside_red_cart_prop", -- 543
			rcx, -- 543
			rby, -- 543
			rw, -- 543
			rh, -- 543
			{layer = 4} -- 543
		) then -- 543
			scene:addBox({ -- 544
				x0 = redBox.x0 + 2, -- 545
				x1 = redBox.x1 - 2, -- 546
				y0 = redBox.y0 + 10, -- 547
				y1 = redBox.y1, -- 548
				z0 = -10, -- 549
				z1 = 12, -- 550
				material = MING_MATERIALS.mingTimber, -- 551
				bucket = LP_BUCKET.PROP, -- 552
				highlightTopEdge = true, -- 553
				edgeWidth = 0.7 -- 554
			}) -- 554
		end -- 554
	end -- 554
	local c = p.room.cart -- 560
	if c.bodyW > 0 then -- 561
		scene:addBox({ -- 563
			x0 = c.endX - 18, -- 564
			x1 = c.endX + 18, -- 565
			y0 = c.baseY - 4, -- 566
			y1 = c.baseY + 2, -- 567
			z0 = -12, -- 568
			z1 = 14, -- 569
			material = MING_MATERIALS.mingIron, -- 570
			bucket = LP_BUCKET.WALK_DECK, -- 571
			sortBias = 0.35, -- 572
			highlightTopEdge = true -- 573
		}) -- 573
		scene:addBox({ -- 576
			x0 = ox + 258, -- 577
			x1 = ox + 474, -- 578
			y0 = c.baseY - 1.5, -- 579
			y1 = c.baseY + 0.4, -- 580
			z0 = -11, -- 581
			z1 = -7, -- 582
			material = MING_MATERIALS.mingTimberDark, -- 583
			bucket = LP_BUCKET.WALK_DECK, -- 584
			sortBias = 0.3, -- 585
			edgeWidth = 0 -- 586
		}) -- 586
		scene:addBox({ -- 588
			x0 = ox + 258, -- 589
			x1 = ox + 474, -- 590
			y0 = c.baseY - 1.5, -- 591
			y1 = c.baseY + 0.4, -- 592
			z0 = 7, -- 593
			z1 = 11, -- 594
			material = MING_MATERIALS.mingTimberDark, -- 595
			bucket = LP_BUCKET.WALK_DECK, -- 596
			sortBias = 0.3, -- 597
			edgeWidth = 0 -- 598
		}) -- 598
	end -- 598
	if not p.cartDocked and p.room.arch.h > 0 then -- 604
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 605
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 606
		if bx1 > bx0 + 4 then -- 607
			scene:addBox({ -- 608
				x0 = bx0, -- 609
				x1 = bx1, -- 610
				y0 = 2, -- 611
				y1 = p.room.arch.h, -- 612
				z0 = -6, -- 613
				z1 = 8, -- 614
				material = MING_MATERIALS.mingTimberDark, -- 615
				bucket = LP_BUCKET.PROP, -- 616
				highlightTopEdge = true, -- 617
				edgeWidth = 0.9 -- 618
			}) -- 618
			scene:addBox({ -- 621
				x0 = (bx0 + bx1) * 0.5 - 3, -- 622
				x1 = (bx0 + bx1) * 0.5 + 3, -- 623
				y0 = p.room.arch.h, -- 624
				y1 = p.room.cart.baseY, -- 625
				z0 = -3, -- 626
				z1 = 5, -- 627
				material = MING_MATERIALS.mingIron, -- 628
				bucket = LP_BUCKET.PROP, -- 629
				edgeWidth = 0.6 -- 630
			}) -- 630
		end -- 630
	end -- 630
	scene:addBox({ -- 636
		x0 = ox + 128, -- 637
		x1 = ox + 598, -- 638
		y0 = 0, -- 639
		y1 = 92, -- 640
		z0 = 44, -- 641
		z1 = 72, -- 642
		material = MING_MATERIALS.mingBrickDark, -- 643
		bucket = LP_BUCKET.MIDGROUND, -- 644
		sortBias = -0.2, -- 645
		edgeWidth = 0.5 -- 646
	}) -- 646
	scene:addQuad3D( -- 649
		vec3(ox + 132, 26, 43), -- 650
		vec3(ox + 592, 26, 43), -- 651
		vec3(ox + 592, 31, 43), -- 652
		vec3(ox + 132, 31, 43), -- 653
		{base = rgba(138, 148, 158, 92)}, -- 654
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 655
	) -- 655
	scene:addQuad3D( -- 659
		vec3(ox + 635, -1.5, 22), -- 660
		vec3(ox + 1150, -1.5, 22), -- 661
		vec3(ox + 1150, 1.5, 92), -- 662
		vec3(ox + 635, 1.5, 92), -- 663
		{base = rgba(24, 38, 56, 210)}, -- 664
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 0} -- 665
	) -- 665
	scene:flush(fgDraw, fgGlow) -- 668
	local hutX = cam:sx(ox + 1025) -- 671
	local hutY = cam:sy(0) -- 672
	worldArt:tryPlace( -- 673
		"sh_salt_hut", -- 673
		"lp_outside_salt_hut", -- 673
		hutX, -- 673
		hutY - cam:len(2), -- 673
		cam:len(128), -- 673
		cam:len(96), -- 673
		{layer = 1, opacity = 0.94} -- 673
	) -- 673
	local endGlowPulse = 0.85 + 0.15 * math.sin(self.animTime * 2.1) -- 678
	fillRadialGlow( -- 679
		fgGlow, -- 679
		cam:sx(ox + 1135), -- 679
		cam:sy(68), -- 679
		cam:len(96), -- 679
		cam:len(88), -- 679
		Color( -- 680
			238, -- 680
			200, -- 680
			138, -- 680
			math.floor(44 * endGlowPulse + 0.5) -- 680
		), -- 680
		Color(238, 200, 138, 0), -- 680
		16 -- 680
	) -- 680
	local chimePulse = 0.65 + 0.35 * math.sin(self.animTime * 2.8) -- 682
	fillRadialGlow( -- 683
		fgGlow, -- 683
		hutX - cam:len(42), -- 683
		hutY + cam:len(48), -- 683
		cam:len(16), -- 683
		cam:len(16), -- 683
		Color( -- 684
			218, -- 684
			232, -- 684
			244, -- 684
			math.floor(52 * chimePulse + 0.5) -- 684
		), -- 684
		Color(218, 232, 244, 0), -- 684
		10 -- 684
	) -- 684
	do -- 684
		local sr = 0 -- 686
		while sr < 7 do -- 686
			local wx = ox + 680 + sr * 64 + math.sin(self.animTime * 1.4 + sr * 1.3) * 10 -- 687
			local pL = projectWorld3D( -- 688
				wx - 22, -- 688
				-0.5, -- 688
				42 + sr % 2 * 18, -- 688
				cam, -- 688
				self.outsideProj -- 688
			) -- 688
			local pR = projectWorld3D( -- 689
				wx + 22, -- 689
				-0.5, -- 689
				42 + sr % 2 * 18, -- 689
				cam, -- 689
				self.outsideProj -- 689
			) -- 689
			fgGlow:drawSegment( -- 690
				Vec2(pL.x, pL.y), -- 690
				Vec2(pR.x, pR.y), -- 690
				1.2, -- 690
				Color(172, 204, 228, 66) -- 690
			) -- 690
			sr = sr + 1 -- 686
		end -- 686
	end -- 686
	local reedXs = {655, 765, 955, 1145} -- 693
	do -- 693
		local ri = 0 -- 694
		while ri < #reedXs do -- 694
			worldArt:tryPlace( -- 695
				"grass_low", -- 695
				"lp_outside_reed_" .. tostring(ri), -- 695
				cam:sx(ox + reedXs[ri + 1]), -- 695
				hutY - cam:len(2), -- 695
				cam:len(54), -- 695
				cam:len(18), -- 695
				{ -- 695
					layer = 3, -- 696
					color = Color(128, 152, 168, 255), -- 697
					opacity = 0.82 -- 698
				} -- 698
			) -- 698
			ri = ri + 1 -- 694
		end -- 694
	end -- 694
	local gi = 0 -- 703
	do -- 703
		gi = 0 -- 704
		while gi < 6 do -- 704
			local gx = ox + 165 + gi * 56 -- 705
			local p0 = projectWorld3D( -- 706
				gx, -- 706
				0.5, -- 706
				-14, -- 706
				cam, -- 706
				self.outsideProj -- 706
			) -- 706
			local p1 = projectWorld3D( -- 707
				gx + 10, -- 707
				0.5, -- 707
				22, -- 707
				cam, -- 707
				self.outsideProj -- 707
			) -- 707
			fgDraw:drawSegment( -- 708
				Vec2(p0.x, p0.y), -- 708
				Vec2(p1.x, p1.y), -- 708
				3, -- 708
				Color(8, 12, 18, 76) -- 708
			) -- 708
			gi = gi + 1 -- 704
		end -- 704
	end -- 704
	local row = 0 -- 712
	do -- 712
		row = 1 -- 713
		while row <= 6 do -- 713
			local wy = 96 + row * 19 -- 714
			local bL = projectWorld3D( -- 715
				ox + 513, -- 715
				wy, -- 715
				-8, -- 715
				cam, -- 715
				self.outsideProj -- 715
			) -- 715
			local bR = projectWorld3D( -- 716
				ox + 599, -- 716
				wy, -- 716
				-8, -- 716
				cam, -- 716
				self.outsideProj -- 716
			) -- 716
			fgDraw:drawSegment( -- 717
				Vec2(bL.x, bL.y), -- 717
				Vec2(bR.x, bR.y), -- 717
				0.9, -- 717
				Color(34, 40, 50, 185) -- 717
			) -- 717
			local off = row % 2 * 18 -- 718
			local colX = ox + 528 + off -- 719
			while colX < ox + 594 do -- 720
				local v0 = projectWorld3D( -- 721
					colX, -- 721
					wy - 19, -- 721
					-8, -- 721
					cam, -- 721
					self.outsideProj -- 721
				) -- 721
				local v1 = projectWorld3D( -- 722
					colX, -- 722
					wy, -- 722
					-8, -- 722
					cam, -- 722
					self.outsideProj -- 722
				) -- 722
				fgDraw:drawSegment( -- 723
					Vec2(v0.x, v0.y), -- 723
					Vec2(v1.x, v1.y), -- 723
					0.8, -- 723
					Color(32, 38, 48, 150) -- 723
				) -- 723
				colX = colX + 34 -- 724
			end -- 724
			row = row + 1 -- 713
		end -- 713
	end -- 713
	return true -- 728
end -- 522
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 731
	local p = ctx.p -- 737
	local cam = ctx.cam -- 738
	local ox = p.ox -- 739
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 740
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 745
	scene:addBox({ -- 748
		x0 = ox - 40, -- 749
		x1 = ox + 760, -- 750
		y0 = -52, -- 751
		y1 = 0, -- 752
		z0 = -26, -- 753
		z1 = 96, -- 754
		material = MING_MATERIALS.mingBrickDark, -- 755
		bucket = LP_BUCKET.WALK_DECK, -- 756
		highlightTopEdge = true -- 757
	}) -- 757
	scene:addBox({ -- 760
		x0 = ox + 398, -- 761
		x1 = ox + 492, -- 762
		y0 = -4, -- 763
		y1 = 2.5, -- 764
		z0 = -16, -- 765
		z1 = 26, -- 766
		material = MING_MATERIALS.mingStoneStep, -- 767
		bucket = LP_BUCKET.WALK_DECK, -- 768
		sortBias = 0.15, -- 769
		highlightTopEdge = true -- 770
	}) -- 770
	scene:addBox({ -- 774
		x0 = ox + 180, -- 775
		x1 = ox + 400, -- 776
		y0 = 0, -- 777
		y1 = 215, -- 778
		z0 = -8, -- 779
		z1 = 96, -- 780
		material = MING_MATERIALS.mingBrick, -- 781
		bucket = LP_BUCKET.MIDGROUND, -- 782
		highlightTopEdge = true -- 783
	}) -- 783
	if not opened then -- 789
		scene:addBox({ -- 790
			x0 = ox + 490, -- 791
			x1 = ox + 720, -- 792
			y0 = 0, -- 793
			y1 = 215, -- 794
			z0 = -8, -- 795
			z1 = 96, -- 796
			material = MING_MATERIALS.mingBrick, -- 797
			bucket = LP_BUCKET.MIDGROUND, -- 798
			highlightTopEdge = true -- 799
		}) -- 799
	else -- 799
		scene:addBox({ -- 803
			x0 = ox + 490, -- 804
			x1 = ox + 704, -- 805
			y0 = 0, -- 806
			y1 = 158, -- 807
			z0 = 36, -- 808
			z1 = 88, -- 809
			material = MING_MATERIALS.mingTimberDark, -- 810
			bucket = LP_BUCKET.MIDGROUND, -- 811
			sortBias = -0.15, -- 812
			edgeWidth = 0.5 -- 813
		}) -- 813
		scene:addBox({ -- 816
			x0 = ox + 490, -- 817
			x1 = ox + 726, -- 818
			y0 = 158, -- 819
			y1 = 215, -- 820
			z0 = -8, -- 821
			z1 = 96, -- 822
			material = MING_MATERIALS.mingBrick, -- 823
			bucket = LP_BUCKET.MIDGROUND, -- 824
			highlightTopEdge = true -- 825
		}) -- 825
		scene:addBox({ -- 827
			x0 = ox + 704, -- 828
			x1 = ox + 726, -- 829
			y0 = 0, -- 830
			y1 = 158, -- 831
			z0 = -8, -- 832
			z1 = 96, -- 833
			material = MING_MATERIALS.mingBrick, -- 834
			bucket = LP_BUCKET.MIDGROUND, -- 835
			edgeWidth = 0.7 -- 836
		}) -- 836
		scene:addBox({ -- 839
			x0 = ox + 490, -- 840
			x1 = ox + 704, -- 841
			y0 = -4, -- 842
			y1 = 1.5, -- 843
			z0 = -12, -- 844
			z1 = 36, -- 845
			material = MING_MATERIALS.mingTimber, -- 846
			bucket = LP_BUCKET.WALK_DECK, -- 847
			sortBias = 0.12, -- 848
			edgeWidth = 0.4 -- 849
		}) -- 849
	end -- 849
	scene:addBeveledFrame( -- 854
		ox + 400, -- 854
		ox + 490, -- 854
		0, -- 854
		110, -- 854
		14, -- 854
		34, -- 854
		-8, -- 854
		68, -- 854
		MING_MATERIALS.mingStoneStep, -- 854
		{ -- 854
			bucket = LP_BUCKET.MIDGROUND, -- 855
			innerRimLight = rgba(244, 206, 140, 255), -- 856
			innerRimStrength = opened and 0.78 or 0.32 -- 857
		} -- 857
	) -- 857
	if not opened then -- 861
		scene:addBox({ -- 862
			x0 = ox + 404, -- 863
			x1 = ox + 486, -- 864
			y0 = 4, -- 865
			y1 = 109, -- 866
			z0 = 14, -- 867
			z1 = 26, -- 868
			material = MING_MATERIALS.mingTimberDark, -- 869
			bucket = LP_BUCKET.MIDGROUND, -- 870
			sortBias = 0.1, -- 871
			edgeWidth = 0.7 -- 872
		}) -- 872
	else -- 872
		scene:addQuad3D( -- 875
			vec3(ox + 404, 2, 24), -- 876
			vec3(ox + 486, 2, 24), -- 877
			vec3(ox + 486, 109, 24), -- 878
			vec3(ox + 404, 109, 24), -- 879
			{base = rgba(74, 50, 30, 220)}, -- 880
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 881
		) -- 881
	end -- 881
	scene:addQuad3D( -- 886
		vec3(ox + 286, 118, -9), -- 887
		vec3(ox + 306, 118, -9), -- 888
		vec3(ox + 306, 158, -9), -- 889
		vec3(ox + 286, 158, -9), -- 890
		{base = rgba(244, 204, 134, 255)}, -- 891
		{ -- 892
			bucket = LP_BUCKET.PROP, -- 892
			unlit = true, -- 892
			edgeColor = rgba(82, 68, 52, 255), -- 892
			edgeWidth = 1.4 -- 892
		} -- 892
	) -- 892
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 896
	scene:addLightShaft( -- 897
		ox + 412, -- 898
		ox + 478, -- 898
		106, -- 898
		ox + 382, -- 899
		ox + 506, -- 899
		0, -- 899
		6, -- 900
		rgba(246, 208, 138, 255), -- 901
		(opened and 0.32 or 0.08) * pulse, -- 902
		(opened and 0.14 or 0.04) * pulse -- 903
	) -- 903
	scene:addContactShadow( -- 907
		p.player.x, -- 907
		p.player.y, -- 907
		15, -- 907
		11, -- 907
		0.78, -- 907
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 907
	) -- 907
	scene:flush(fgDraw, fgGlow) -- 909
	local lampP = projectWorld3D( -- 912
		ox + 445, -- 912
		102, -- 912
		2, -- 912
		cam, -- 912
		self.towerProj -- 912
	) -- 912
	worldArt:tryPlace( -- 913
		"prop_lantern", -- 913
		"lp_tower_porch_lantern", -- 913
		lampP.x, -- 913
		lampP.y, -- 913
		cam:len(18), -- 913
		cam:len(22), -- 913
		{layer = 4} -- 913
	) -- 913
	fillRadialGlow( -- 914
		fgGlow, -- 915
		lampP.x, -- 916
		lampP.y, -- 917
		cam:len(opened and 64 or 38) * pulse, -- 918
		cam:len(opened and 64 or 38) * pulse, -- 919
		Color( -- 920
			248, -- 920
			214, -- 920
			146, -- 920
			math.floor((opened and 128 or 82) * pulse + 0.5) -- 920
		), -- 920
		Color(232, 174, 82, 0), -- 921
		16 -- 922
	) -- 922
	local winP = projectWorld3D( -- 925
		ox + 296, -- 925
		138, -- 925
		-9, -- 925
		cam, -- 925
		self.towerProj -- 925
	) -- 925
	fillRadialGlow( -- 926
		fgGlow, -- 926
		winP.x, -- 926
		winP.y, -- 926
		cam:len(42), -- 926
		cam:len(46), -- 926
		Color( -- 926
			246, -- 926
			206, -- 926
			132, -- 926
			math.floor(84 * pulse + 0.5) -- 926
		), -- 926
		Color(232, 174, 82, 0), -- 926
		14 -- 926
	) -- 926
	local wBL = projectWorld3D( -- 928
		ox + 286, -- 928
		118, -- 928
		-9, -- 928
		cam, -- 928
		self.towerProj -- 928
	) -- 928
	local wTR = projectWorld3D( -- 929
		ox + 306, -- 929
		158, -- 929
		-9, -- 929
		cam, -- 929
		self.towerProj -- 929
	) -- 929
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 930
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 931
	fgDraw:drawSegment( -- 932
		Vec2(wMidX, wBL.y), -- 932
		Vec2(wMidX, wTR.y), -- 932
		1.4, -- 932
		Color(68, 52, 38, 225) -- 932
	) -- 932
	fgDraw:drawSegment( -- 933
		Vec2(wBL.x, wMidY), -- 933
		Vec2(wTR.x, wMidY), -- 933
		1.4, -- 933
		Color(68, 52, 38, 225) -- 933
	) -- 933
	do -- 933
		local tr = 1 -- 934
		while tr <= 6 do -- 934
			local ty = tr * 30 -- 935
			local tl0 = projectWorld3D( -- 936
				ox + 182, -- 936
				ty, -- 936
				-8, -- 936
				cam, -- 936
				self.towerProj -- 936
			) -- 936
			local tl1 = projectWorld3D( -- 937
				ox + 398, -- 937
				ty, -- 937
				-8, -- 937
				cam, -- 937
				self.towerProj -- 937
			) -- 937
			fgDraw:drawSegment( -- 938
				Vec2(tl0.x, tl0.y), -- 938
				Vec2(tl1.x, tl1.y), -- 938
				0.8, -- 938
				Color(34, 38, 48, 135) -- 938
			) -- 938
			if not opened then -- 939
				local tr0 = projectWorld3D( -- 940
					ox + 492, -- 940
					ty, -- 940
					-8, -- 940
					cam, -- 940
					self.towerProj -- 940
				) -- 940
				local tr1 = projectWorld3D( -- 941
					ox + 718, -- 941
					ty, -- 941
					-8, -- 941
					cam, -- 941
					self.towerProj -- 941
				) -- 941
				fgDraw:drawSegment( -- 942
					Vec2(tr0.x, tr0.y), -- 942
					Vec2(tr1.x, tr1.y), -- 942
					0.8, -- 942
					Color(34, 38, 48, 135) -- 942
				) -- 942
			end -- 942
			tr = tr + 1 -- 934
		end -- 934
	end -- 934
	if opened then -- 947
		local roomL = cam:sx(ox + 492) -- 948
		local roomR = cam:sx(ox + 702) -- 949
		local groundY = cam:sy(0) -- 950
		local ceilY = cam:sy(152) -- 951
		do -- 951
			local b = 1 -- 952
			while b <= 5 do -- 952
				local bx = roomL + (roomR - roomL) * b / 6 -- 953
				fgDraw:drawSegment( -- 954
					Vec2(bx, groundY), -- 954
					Vec2(bx, ceilY), -- 954
					0.9, -- 954
					Color(26, 18, 14, 145) -- 954
				) -- 954
				b = b + 1 -- 952
			end -- 952
		end -- 952
		local inWinL = cam:sx(ox + 648) -- 956
		local inWinY = cam:sy(76) -- 957
		local inWinW = cam:len(42) -- 958
		local inWinH = cam:len(48) -- 959
		fillVGradRect( -- 960
			fgDraw, -- 960
			inWinL, -- 960
			inWinY, -- 960
			inWinW, -- 960
			inWinH, -- 960
			Color(36, 48, 70, 245), -- 960
			Color(74, 86, 108, 245) -- 960
		) -- 960
		fgDraw:drawRect( -- 961
			Rect(inWinL, inWinY, inWinW, inWinH), -- 961
			Color(0, 0, 0, 0), -- 961
			2, -- 961
			Color(82, 58, 38, 255) -- 961
		) -- 961
		fgDraw:drawSegment( -- 962
			Vec2(inWinL + inWinW * 0.5, inWinY), -- 962
			Vec2(inWinL + inWinW * 0.5, inWinY + inWinH), -- 962
			1.4, -- 962
			Color(82, 58, 38, 245) -- 962
		) -- 962
		fgDraw:drawSegment( -- 963
			Vec2(inWinL, inWinY + inWinH * 0.5), -- 963
			Vec2(inWinL + inWinW, inWinY + inWinH * 0.5), -- 963
			1.4, -- 963
			Color(82, 58, 38, 245) -- 963
		) -- 963
		fillRadialGlow( -- 965
			fgGlow, -- 965
			inWinL + inWinW * 0.35, -- 965
			inWinY + cam:len(10), -- 965
			cam:len(38), -- 965
			cam:len(34), -- 965
			Color( -- 966
				255, -- 966
				206, -- 966
				126, -- 966
				math.floor(92 * pulse + 0.5) -- 966
			), -- 966
			Color(255, 178, 86, 0), -- 966
			14 -- 966
		) -- 966
	end -- 966
	return true -- 969
end -- 731
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 972
	if not self.active then -- 978
		return false -- 979
	end -- 979
	local key = ctx.p.room.key -- 981
	if key == "village" then -- 982
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 983
	end -- 983
	if key == "forest" then -- 985
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 986
	end -- 986
	if key == "outside" then -- 988
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 989
	end -- 989
	if key == "tower" then -- 991
		local p = ctx.p -- 992
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 993
		if opened then -- 994
			local cam = ctx.cam -- 995
			local deskCx = cam:sx(p.ox + 605) -- 996
			local groundY = cam:sy(0) -- 997
			local deskTop = groundY + cam:len(34) -- 998
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 999
			fillRadialGlow( -- 1000
				fgGlow, -- 1000
				deskCx, -- 1000
				deskTop + cam:len(26), -- 1000
				cam:len(138), -- 1000
				cam:len(98), -- 1000
				Color( -- 1001
					255, -- 1001
					198, -- 1001
					114, -- 1001
					math.floor(86 * pulse + 0.5) -- 1001
				), -- 1001
				Color(255, 168, 72, 0), -- 1001
				16 -- 1001
			) -- 1001
			local guardX = deskCx + cam:len(30) -- 1003
			fgDraw:drawEllipse( -- 1004
				Vec2( -- 1004
					deskCx, -- 1004
					groundY + cam:len(1) -- 1004
				), -- 1004
				cam:len(48), -- 1004
				cam:len(5), -- 1004
				Color(10, 8, 6, 138) -- 1004
			) -- 1004
			if not worldArt:tryPlace( -- 1005
				"sh_old_watchman", -- 1005
				"lp_tower_guard_man", -- 1005
				guardX, -- 1005
				groundY + cam:len(6), -- 1005
				cam:len(48), -- 1005
				cam:len(84), -- 1005
				{layer = 2} -- 1005
			) then -- 1005
				fgDraw:drawRect( -- 1006
					Rect( -- 1006
						guardX - cam:len(11), -- 1006
						groundY, -- 1006
						cam:len(22), -- 1006
						cam:len(68) -- 1006
					), -- 1006
					Color(28, 34, 44, 240) -- 1006
				) -- 1006
				fgDraw:drawCircle( -- 1007
					Vec2( -- 1007
						guardX, -- 1007
						groundY + cam:len(76) -- 1007
					), -- 1007
					cam:len(9.5), -- 1007
					Color(36, 44, 56, 245) -- 1007
				) -- 1007
			end -- 1007
			if not worldArt:tryPlace( -- 1010
				"sh_guard_desk", -- 1010
				"lp_tower_guard_desk", -- 1010
				deskCx, -- 1010
				groundY - cam:len(4), -- 1010
				cam:len(98), -- 1010
				cam:len(56), -- 1010
				{layer = 4} -- 1010
			) then -- 1010
				local deskW = cam:len(84) -- 1011
				local deskH = cam:len(34) -- 1012
				fgDraw:drawRect( -- 1013
					Rect( -- 1013
						deskCx - deskW * 0.5, -- 1013
						groundY, -- 1013
						cam:len(6), -- 1013
						deskH -- 1013
					), -- 1013
					Color(74, 48, 30, 255) -- 1013
				) -- 1013
				fgDraw:drawRect( -- 1014
					Rect( -- 1014
						deskCx + deskW * 0.5 - cam:len(6), -- 1014
						groundY, -- 1014
						cam:len(6), -- 1014
						deskH -- 1014
					), -- 1014
					Color(74, 48, 30, 255) -- 1014
				) -- 1014
				fgDraw:drawRect( -- 1015
					Rect( -- 1015
						deskCx - deskW * 0.52, -- 1015
						deskTop - cam:len(6), -- 1015
						deskW * 1.04, -- 1015
						cam:len(8) -- 1015
					), -- 1015
					Color(102, 68, 42, 255) -- 1015
				) -- 1015
			end -- 1015
			if p.deskHold >= 12 or p.towerHanded then -- 1017
				fgDraw:drawRect( -- 1018
					Rect( -- 1018
						deskCx - cam:len(26), -- 1018
						deskTop + cam:len(4), -- 1018
						cam:len(14), -- 1018
						cam:len(6) -- 1018
					), -- 1018
					Color(156, 62, 48, 245) -- 1018
				) -- 1018
			end -- 1018
			if p.deskHold >= 24 or p.towerHanded then -- 1020
				fgDraw:drawCircle( -- 1021
					Vec2( -- 1021
						deskCx - cam:len(8), -- 1021
						deskTop + cam:len(7) -- 1021
					), -- 1021
					cam:len(4.5), -- 1021
					Color(224, 186, 98, 255) -- 1021
				) -- 1021
				fgDraw:drawRect( -- 1022
					Rect( -- 1022
						deskCx - cam:len(16), -- 1022
						deskTop + cam:len(4), -- 1022
						cam:len(10), -- 1022
						cam:len(3) -- 1022
					), -- 1022
					Color(236, 228, 206, 240) -- 1022
				) -- 1022
			end -- 1022
		end -- 1022
		return true -- 1025
	end -- 1025
	return false -- 1027
end -- 972
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 1031
	local p = ctx.p -- 1032
	local cam = ctx.cam -- 1033
	local c = p.room.cart -- 1034
	if c.bodyW <= 0 then -- 1035
		return true -- 1036
	end -- 1036
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 1038
	local halfW = c.bodyW * 0.5 -- 1039
	local axleX = p.cartAxle -- 1040
	local axleY = c.baseY + c.wheelR -- 1041
	local bodyBot = axleY + 2 -- 1042
	local bodyTop = bodyBot + c.bodyH -- 1043
	scene:addBox({ -- 1046
		x0 = axleX - halfW, -- 1047
		x1 = axleX + halfW, -- 1048
		y0 = bodyBot, -- 1049
		y1 = bodyTop, -- 1050
		z0 = -12, -- 1051
		z1 = 14, -- 1052
		material = MING_MATERIALS.mingTimber, -- 1053
		bucket = LP_BUCKET.PROP, -- 1054
		highlightTopEdge = true, -- 1055
		edgeWidth = 1 -- 1056
	}) -- 1056
	scene:addBox({ -- 1059
		x0 = axleX - halfW - 1, -- 1060
		x1 = axleX + halfW + 1, -- 1061
		y0 = bodyBot + 4, -- 1062
		y1 = bodyBot + 8, -- 1063
		z0 = -13, -- 1064
		z1 = 15, -- 1065
		material = MING_MATERIALS.mingIron, -- 1066
		bucket = LP_BUCKET.PROP, -- 1067
		sortBias = 0.08 -- 1068
	}) -- 1068
	local handleX = axleX + c.handleOffset -- 1071
	scene:addBox({ -- 1072
		x0 = axleX + halfW - 2, -- 1073
		x1 = handleX, -- 1074
		y0 = bodyTop - 6, -- 1075
		y1 = bodyTop - 1, -- 1076
		z0 = -10, -- 1077
		z1 = -4, -- 1078
		material = MING_MATERIALS.mingTimber, -- 1079
		bucket = LP_BUCKET.PROP, -- 1080
		sortBias = 0.12, -- 1081
		highlightTopEdge = true -- 1082
	}) -- 1082
	scene:addBox({ -- 1084
		x0 = handleX - 3, -- 1085
		x1 = handleX + 3, -- 1086
		y0 = bodyTop - 8, -- 1087
		y1 = bodyTop + 2, -- 1088
		z0 = -11, -- 1089
		z1 = 9, -- 1090
		material = MING_MATERIALS.mingTimber, -- 1091
		bucket = LP_BUCKET.PROP, -- 1092
		sortBias = 0.14, -- 1093
		highlightTopEdge = true -- 1094
	}) -- 1094
	local clothX = axleX - halfW -- 1098
	local clothTop = bodyTop + 1 -- 1099
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 1100
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 1101
	scene:addTri3D( -- 1102
		vec3(clothX - 2, clothTop + 1, -12), -- 1103
		vec3(clothX + 11, clothTop, -11), -- 1104
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 1105
		MING_MATERIALS.mingRedCloth, -- 1106
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 1107
	) -- 1107
	scene:addTri3D( -- 1109
		vec3(clothX + 11, clothTop, -11), -- 1110
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 1111
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 1112
		MING_MATERIALS.mingRedCloth, -- 1113
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 1114
	) -- 1114
	scene:flush(fgDraw, fgGlow) -- 1117
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 1120
	local wheelR = cam:len(c.wheelR) -- 1121
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 1122
	local wi = 0 -- 1123
	do -- 1123
		wi = 0 -- 1124
		while wi < #wheelXs do -- 1124
			local wp = projectWorld3D( -- 1125
				wheelXs[wi + 1], -- 1125
				axleY, -- 1125
				-10, -- 1125
				cam, -- 1125
				self.outsideProj -- 1125
			) -- 1125
			fgDraw:drawCircle( -- 1126
				Vec2(wp.x, wp.y), -- 1126
				wheelR, -- 1126
				Color(52, 40, 32, 255) -- 1126
			) -- 1126
			fgDraw:drawRing( -- 1127
				Vec2(wp.x, wp.y), -- 1127
				math.max(1, wheelR - 2.6), -- 1127
				wheelR, -- 1127
				Color(0, 0, 0, 0), -- 1127
				1.4, -- 1127
				Color(148, 126, 102, 220) -- 1127
			) -- 1127
			local sp = 0 -- 1128
			do -- 1128
				sp = 0 -- 1129
				while sp < 4 do -- 1129
					local a = rollAngle + sp * math.pi / 4 -- 1130
					local dx = math.cos(a) * (wheelR - 2) -- 1131
					local dy = math.sin(a) * (wheelR - 2) -- 1132
					fgDraw:drawSegment( -- 1133
						Vec2(wp.x - dx, wp.y - dy), -- 1133
						Vec2(wp.x + dx, wp.y + dy), -- 1133
						1, -- 1133
						Color(118, 92, 70, 210) -- 1133
					) -- 1133
					sp = sp + 1 -- 1129
				end -- 1129
			end -- 1129
			fgDraw:drawDot( -- 1135
				Vec2(wp.x, wp.y), -- 1135
				2.4, -- 1135
				Color(172, 160, 144, 230) -- 1135
			) -- 1135
			wi = wi + 1 -- 1124
		end -- 1124
	end -- 1124
	local patchP = projectWorld3D( -- 1139
		clothX + 1, -- 1139
		clothTop - 7, -- 1139
		-13, -- 1139
		cam, -- 1139
		self.outsideProj -- 1139
	) -- 1139
	fgDraw:drawSegment( -- 1140
		Vec2(patchP.x - 3, patchP.y), -- 1140
		Vec2(patchP.x + 3, patchP.y - 2), -- 1140
		1, -- 1140
		Color(224, 212, 188, 215) -- 1140
	) -- 1140
	fgDraw:drawSegment( -- 1141
		Vec2(patchP.x - 2, patchP.y - 4), -- 1141
		Vec2(patchP.x + 2, patchP.y - 5), -- 1141
		0.9, -- 1141
		Color(224, 212, 188, 195) -- 1141
	) -- 1141
	return true -- 1143
end -- 1031
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1146
	if not self.active then -- 1152
		return -- 1153
	end -- 1153
	local key = ctx.p.room.key -- 1155
	if key == "village" then -- 1156
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1157
	elseif key == "forest" then -- 1158
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1159
	end -- 1159
end -- 1146
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1167
	if not self.active then -- 1174
		return false -- 1175
	end -- 1175
	local key = ctx.p.room.key -- 1177
	if key == "village" then -- 1178
		return self.village:drawForegroundOverlay( -- 1179
			uiDraw, -- 1179
			uiInkDraw, -- 1179
			uiArt, -- 1179
			uiGlow, -- 1179
			ctx -- 1179
		) -- 1179
	end -- 1179
	if key == "forest" then -- 1181
		return self.forest:drawForegroundOverlay( -- 1182
			uiDraw, -- 1182
			uiInkDraw, -- 1182
			uiArt, -- 1182
			uiGlow, -- 1182
			ctx -- 1182
		) -- 1182
	end -- 1182
	if key == "outside" then -- 1184
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 1185
		return false -- 1186
	end -- 1186
	return false -- 1188
end -- 1167
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1195
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1201
		return -- 1202
	end -- 1202
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1204
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1206
	if alpha <= 0.01 then -- 1207
		return -- 1208
	end -- 1208
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1210
	local handPt = projectWorld3D( -- 1211
		self.memoryAnchorWorldX, -- 1211
		self.memoryAnchorWorldY, -- 1211
		0, -- 1211
		ctx.cam, -- 1211
		self.outsideProj -- 1211
	) -- 1211
	local cx = math.max( -- 1213
		160, -- 1213
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 1213
	) -- 1213
	local cy = math.max( -- 1214
		150, -- 1214
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 1214
	) -- 1214
	local rx = 122 -- 1215
	local ry = 74 -- 1216
	fillRadialGlow( -- 1219
		uiGlow, -- 1219
		cx, -- 1219
		cy, -- 1219
		rx * 1.55, -- 1219
		ry * 1.55, -- 1219
		Color( -- 1219
			238, -- 1219
			190, -- 1219
			122, -- 1219
			math.floor(92 * alpha + 0.5) -- 1219
		), -- 1219
		Color(218, 162, 92, 0), -- 1219
		22 -- 1219
	) -- 1219
	uiDraw:drawEllipse( -- 1220
		Vec2(cx, cy), -- 1220
		rx * 1.12, -- 1220
		ry * 1.12, -- 1220
		Color( -- 1220
			36, -- 1220
			26, -- 1220
			20, -- 1220
			math.floor(128 * alpha + 0.5) -- 1220
		) -- 1220
	) -- 1220
	uiDraw:drawEllipse( -- 1221
		Vec2(cx, cy), -- 1221
		rx * 0.96, -- 1221
		ry * 0.96, -- 1221
		Color( -- 1221
			32, -- 1221
			22, -- 1221
			16, -- 1221
			math.floor(206 * alpha + 0.5) -- 1221
		) -- 1221
	) -- 1221
	uiDraw:drawPolygon( -- 1224
		{ -- 1224
			Vec2(cx - 72, cy - 34), -- 1225
			Vec2(cx + 62, cy - 28), -- 1226
			Vec2(cx + 70, cy + 32), -- 1227
			Vec2(cx - 64, cy + 28) -- 1228
		}, -- 1228
		Color( -- 1229
			148, -- 1229
			44, -- 1229
			40, -- 1229
			math.floor(230 * alpha + 0.5) -- 1229
		) -- 1229
	) -- 1229
	uiDraw:drawPolygon( -- 1230
		{ -- 1230
			Vec2(cx - 28, cy - 18), -- 1231
			Vec2(cx + 26, cy - 14), -- 1232
			Vec2(cx + 22, cy + 20), -- 1233
			Vec2(cx - 24, cy + 16) -- 1234
		}, -- 1234
		Color( -- 1235
			172, -- 1235
			62, -- 1235
			54, -- 1235
			math.floor(238 * alpha + 0.5) -- 1235
		), -- 1235
		1, -- 1235
		Color( -- 1235
			224, -- 1235
			210, -- 1235
			184, -- 1235
			math.floor(170 * alpha + 0.5) -- 1235
		) -- 1235
	) -- 1235
	local si = 0 -- 1238
	do -- 1238
		si = 0 -- 1239
		while si < 4 do -- 1239
			local sx = cx - 18 + si * 11 -- 1240
			uiInkDraw:drawSegment( -- 1241
				Vec2(sx, cy - 15), -- 1241
				Vec2(sx + 4, cy - 9), -- 1241
				1.3, -- 1241
				Color( -- 1241
					236, -- 1241
					224, -- 1241
					198, -- 1241
					math.floor(235 * alpha + 0.5) -- 1241
				) -- 1241
			) -- 1241
			si = si + 1 -- 1239
		end -- 1239
	end -- 1239
	local pullT = smoothstep(0.14, 0.82, prog) -- 1245
	local stitchAnchorX = cx + 22 -- 1246
	local stitchAnchorY = cy - 12 -- 1247
	local handX = cx + 32 + pullT * 34 -- 1248
	local handY = cy + 6 + pullT * 26 -- 1249
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1252
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1253
	uiInkDraw:drawSegment( -- 1254
		Vec2(stitchAnchorX, stitchAnchorY), -- 1254
		Vec2(midX, midY), -- 1254
		1.2, -- 1254
		Color( -- 1254
			242, -- 1254
			234, -- 1254
			214, -- 1254
			math.floor(240 * alpha + 0.5) -- 1254
		) -- 1254
	) -- 1254
	uiInkDraw:drawSegment( -- 1255
		Vec2(midX, midY), -- 1255
		Vec2(handX - 6, handY - 2), -- 1255
		1.2, -- 1255
		Color( -- 1255
			242, -- 1255
			234, -- 1255
			214, -- 1255
			math.floor(240 * alpha + 0.5) -- 1255
		) -- 1255
	) -- 1255
	uiInkDraw:drawSegment( -- 1258
		Vec2(handX - 16, handY - 8), -- 1258
		Vec2(handX + 2, handY + 4), -- 1258
		1.1, -- 1258
		Color( -- 1258
			230, -- 1258
			236, -- 1258
			242, -- 1258
			math.floor(225 * alpha + 0.5) -- 1258
		) -- 1258
	) -- 1258
	uiDraw:drawPolygon( -- 1261
		{ -- 1261
			Vec2(handX - 8, handY - 6), -- 1262
			Vec2(handX + 18, handY + 2), -- 1263
			Vec2(handX + 24, handY + 14), -- 1264
			Vec2(handX + 4, handY + 14), -- 1265
			Vec2(handX - 10, handY + 4) -- 1266
		}, -- 1266
		Color( -- 1267
			214, -- 1267
			174, -- 1267
			142, -- 1267
			math.floor(225 * alpha + 0.5) -- 1267
		), -- 1267
		1, -- 1267
		Color( -- 1267
			142, -- 1267
			102, -- 1267
			78, -- 1267
			math.floor(180 * alpha + 0.5) -- 1267
		) -- 1267
	) -- 1267
	uiDraw:drawEllipse( -- 1269
		Vec2(cx - 20, cy + 4), -- 1269
		16, -- 1269
		9, -- 1269
		Color( -- 1269
			204, -- 1269
			164, -- 1269
			134, -- 1269
			math.floor(220 * alpha + 0.5) -- 1269
		) -- 1269
	) -- 1269
end -- 1195
function ____exports.createLowpolyWorldPlugin() -- 1273
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1274
end -- 1273
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1278
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1281
	fe:registerPlugin(lowpolyWorld) -- 1282
	return {lowpolyWorld = lowpolyWorld} -- 1283
end -- 1278
return ____exports -- 1278
