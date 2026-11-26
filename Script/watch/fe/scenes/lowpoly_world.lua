-- [ts]: lowpoly_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
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
	if loaded == nil then -- 145
		return -- 147
	end -- 147
	local rawFe = loaded["watch.fe"] -- 149
	if rawFe ~= nil and type(rawFe) == "table" then -- 149
		local watchFe = rawFe -- 151
		if watchFe.lowpolyWorld ~= self then -- 151
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
	if key == "village" then -- 167
		return self.village:getProjection() -- 169
	end -- 169
	if key == "forest" then -- 169
		return self.forest:getProjection() -- 172
	end -- 172
	if key == "tower" then -- 172
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
	if not want then -- 222
		if self.wasActive then -- 222
			ctx.cam:setAnchorLock(nil) -- 225
			self:stopAllAudioLoops(ctx) -- 226
			self.wasActive = false -- 227
		end -- 227
		self.active = false -- 229
		return -- 230
	end -- 230
	local p = ctx.p -- 233
	if self.activeRoomKey ~= "" and self.activeRoomKey ~= p.room.key then -- 233
		ctx.cam:setAnchorLock(nil) -- 235
		self:stopAllAudioLoops(ctx) -- 236
		self:resetRoomState(p) -- 237
	end -- 237
	self.active = true -- 240
	self.wasActive = true -- 241
	self.activeRoomKey = p.room.key -- 242
	if not ctx.paused and ctx.worldDt > 0 then -- 242
		self.animTime = self.animTime + ctx.worldDt -- 245
	end -- 245
	if p.room.key == "outside" then -- 245
		self:updateOutside(ctx) -- 249
	elseif p.room.key == "village" then -- 249
		self.village:update(ctx) -- 251
	elseif p.room.key == "forest" then -- 251
		self.forest:update(ctx) -- 253
	elseif p.room.key == "tower" then -- 253
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
	if c.bodyW > 0 then -- 272
		self.lastCartAxle = p.cartAxle -- 275
		self.lastCartClothX = p.cartAxle - c.bodyW * 0.5 -- 276
		if self.lastCartClothX >= self.lastCartAxle or c.clothSide >= 0 then -- 276
			self.cartClothLeftInvariantOk = false -- 278
		end -- 278
		self.memoryAnchorWorldX = p.cartAxle + c.handleOffset -- 280
		self.memoryAnchorWorldY = c.baseY + c.wheelR + c.bodyH * 0.72 -- 281
	end -- 281
	if not ctx.paused and ctx.worldDt > 0 then -- 281
		local dt = ctx.worldDt -- 285
		if p.gripping and not self.prevGripping and not self.memoryPlayed then -- 285
			self.memoryPlayed = true -- 289
			self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 290
			self.memoryTimer = 0 -- 291
			ctx.audio:playOnce( -- 292
				"fe04:outside:sewing:" .. tostring(ctx.events.roomSessionId), -- 293
				"ambience", -- 294
				CHILD_AUDIO_ROOT .. "sewing_memory.wav", -- 295
				0.68, -- 296
				"fe04:outside:sewing_memory", -- 297
				p.ticks -- 298
			) -- 298
		end -- 298
		self.prevGripping = p.gripping -- 301
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 301
			self.memoryTimer = math.min(SEWING_MEMORY_DURATION, self.memoryTimer + dt) -- 304
		end -- 304
		local cartSpeed = math.abs(p.cartAxle - self.prevCartAxle) / math.max(0.001, dt) -- 308
		self.prevCartAxle = p.cartAxle -- 309
		local targetWheelVol = cartSpeed > 4 and math.min(0.54, 0.22 + cartSpeed / 64 * 0.32) or 0 -- 310
		self.cartWheelVol = self.cartWheelVol + (targetWheelVol - self.cartWheelVol) * math.min(1, dt * 10) -- 311
		ctx.audio:playLoop( -- 313
			"fe04_outside_wind", -- 313
			"wind", -- 313
			CHILD_AUDIO_ROOT .. "wind_outside_loop.wav", -- 313
			0.36, -- 313
			p.ticks -- 313
		) -- 313
		if self.cartWheelVol > 0.03 then -- 313
			ctx.audio:playLoop( -- 315
				"fe04_cart_wheel", -- 315
				"ambience", -- 315
				CHILD_AUDIO_ROOT .. "cart_wheel_loop.wav", -- 315
				self.cartWheelVol, -- 315
				p.ticks -- 315
			) -- 315
		else -- 315
			ctx.audio:stopLoop("fe04_cart_wheel", 0.12) -- 317
		end -- 317
	end -- 317
	self.outsideProj = { -- 321
		morph = 1, -- 322
		focal = 410, -- 323
		vpFracX = 0.54, -- 324
		vpFracY = 0.52, -- 325
		vpOffsetX = math.sin(self.animTime * 0.52) * 1.5, -- 326
		vpOffsetY = math.cos(self.animTime * 0.68) * 1, -- 327
		baseDepth = 0 -- 328
	} -- 328
end -- 268
function LowpolyWorldPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 332
	if not self.active then -- 332
		return false -- 339
	end -- 339
	local key = ctx.p.room.key -- 341
	if key == "village" then -- 341
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 343
	end -- 343
	if key == "forest" then -- 343
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 346
	end -- 346
	if key == "outside" then -- 346
		return self:drawOutsideBackdrop(bgDraw, bgGlow, ctx) -- 349
	end -- 349
	if key == "tower" then -- 349
		return self:drawTowerBackdrop(bgDraw, bgGlow, ctx) -- 352
	end -- 352
	return false -- 354
end -- 332
function LowpolyWorldPlugin.prototype.drawOutsideBackdrop(self, bgDraw, bgGlow, ctx) -- 357
	local p = ctx.p -- 358
	local cam = ctx.cam -- 359
	local w = cam.viewW -- 360
	local h = cam.viewH -- 361
	local ox = p.ox -- 362
	local splitY = h * 0.48 -- 365
	fillVGradRect( -- 366
		bgDraw, -- 366
		0, -- 366
		splitY, -- 366
		w, -- 366
		h - splitY, -- 366
		Color(16, 25, 38, 255), -- 366
		Color(8, 13, 22, 255) -- 366
	) -- 366
	fillVGradRect( -- 367
		bgDraw, -- 367
		0, -- 367
		0, -- 367
		w, -- 367
		splitY, -- 367
		Color(30, 44, 62, 255), -- 367
		Color(16, 25, 38, 255) -- 367
	) -- 367
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 369
	scene:addBox({ -- 371
		x0 = ox - 160, -- 372
		x1 = ox + 1360, -- 373
		y0 = -48, -- 374
		y1 = 112, -- 375
		z0 = 230, -- 376
		z1 = 274, -- 377
		material = MING_MATERIALS.distantWall, -- 378
		bucket = LP_BUCKET.BACKDROP, -- 379
		edgeWidth = 0 -- 380
	}) -- 380
	local mx = ox - 80 -- 382
	local mi = 0 -- 383
	do -- 383
		mi = 0 -- 384
		while mi < 18 do -- 384
			scene:addBox({ -- 385
				x0 = mx, -- 386
				x1 = mx + 32, -- 387
				y0 = 112, -- 388
				y1 = 128, -- 389
				z0 = 230, -- 390
				z1 = 256, -- 391
				material = MING_MATERIALS.distantWall, -- 392
				bucket = LP_BUCKET.BACKDROP, -- 393
				sortBias = 0.04, -- 394
				edgeWidth = 0 -- 395
			}) -- 395
			mx = mx + 78 -- 397
			mi = mi + 1 -- 384
		end -- 384
	end -- 384
	scene:addFogBand( -- 399
		ox - 180, -- 399
		ox + 1420, -- 399
		-34, -- 399
		152, -- 399
		180, -- 399
		rgba(28, 42, 60, 255), -- 399
		0.58, -- 399
		0.06, -- 399
		{bucket = LP_BUCKET.BACKDROP} -- 399
	) -- 399
	scene:flush(bgDraw, bgGlow) -- 402
	local moonX = w * 0.76 -- 405
	local moonY = h * 0.83 -- 406
	fillRadialGlow( -- 407
		bgGlow, -- 407
		moonX, -- 407
		moonY, -- 407
		82, -- 407
		82, -- 407
		Color(172, 206, 232, 28), -- 407
		Color(24, 42, 68, 0), -- 407
		16 -- 407
	) -- 407
	bgDraw:drawCircle( -- 408
		Vec2(moonX, moonY), -- 408
		14, -- 408
		Color(218, 232, 246, 165) -- 408
	) -- 408
	local beaconP = projectWorld3D( -- 410
		ox + 1140, -- 410
		154, -- 410
		410, -- 410
		cam, -- 410
		self.outsideProj -- 410
	) -- 410
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 411
	fillRadialGlow( -- 412
		bgGlow, -- 412
		beaconP.x, -- 412
		beaconP.y, -- 412
		32 * pulse, -- 412
		32 * pulse, -- 412
		Color( -- 412
			246, -- 412
			208, -- 412
			138, -- 412
			math.floor(92 * pulse + 0.5) -- 412
		), -- 412
		Color(232, 176, 86, 0), -- 412
		14 -- 412
	) -- 412
	bgGlow:drawDot( -- 413
		Vec2(beaconP.x, beaconP.y), -- 413
		2.5, -- 413
		Color(255, 244, 212, 235) -- 413
	) -- 413
	return true -- 415
end -- 357
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, ctx) -- 418
	local cam = ctx.cam -- 419
	local p = ctx.p -- 420
	local ox = p.ox -- 421
	local w = cam.viewW -- 422
	local h = cam.viewH -- 423
	local splitY = h * 0.46 -- 426
	fillVGradRect( -- 427
		bgDraw, -- 427
		0, -- 427
		splitY, -- 427
		w, -- 427
		h - splitY, -- 427
		Color(24, 34, 52, 255), -- 427
		Color(12, 18, 30, 255) -- 427
	) -- 427
	fillVGradRect( -- 428
		bgDraw, -- 428
		0, -- 428
		0, -- 428
		w, -- 428
		splitY, -- 428
		Color(46, 54, 70, 255), -- 428
		Color(24, 34, 52, 255) -- 428
	) -- 428
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 430
	scene:addDistantRidge( -- 431
		{ -- 432
			{x = ox - 180, y = 118}, -- 433
			{x = ox + 90, y = 172}, -- 434
			{x = ox + 360, y = 146}, -- 435
			{x = ox + 640, y = 184}, -- 436
			{x = ox + 920, y = 132} -- 437
		}, -- 437
		-40, -- 437
		420, -- 440
		MING_MATERIALS.distantHill, -- 441
		{bucket = LP_BUCKET.BACKDROP} -- 442
	) -- 442
	scene:addFogBand( -- 444
		ox - 160, -- 444
		ox + 900, -- 444
		-24, -- 444
		150, -- 444
		260, -- 444
		rgba(36, 42, 58, 255), -- 444
		0.56, -- 444
		0.06, -- 444
		{bucket = LP_BUCKET.BACKDROP} -- 444
	) -- 444
	scene:flush(bgDraw, bgGlow) -- 447
	return true -- 449
end -- 418
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 452
	if not self.active then -- 452
		return false -- 459
	end -- 459
	local key = ctx.p.room.key -- 461
	if key == "village" then -- 461
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 463
	end -- 463
	if key == "forest" then -- 463
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 466
	end -- 466
	if key == "outside" then -- 466
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 469
	end -- 469
	if key == "tower" then -- 469
		return self:drawTowerWorld(fgDraw, fgGlow, ctx) -- 472
	end -- 472
	return false -- 474
end -- 452
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, ctx) -- 477
	local p = ctx.p -- 478
	local cam = ctx.cam -- 479
	local ox = p.ox -- 480
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 481
	buildOutsideJettyLowpoly( -- 484
		scene, -- 484
		p.room, -- 484
		p.player.x, -- 484
		p.player.y, -- 484
		p.cartAxle, -- 484
		self.animTime -- 484
	) -- 484
	local c = p.room.cart -- 487
	if c.bodyW > 0 then -- 487
		scene:addBox({ -- 490
			x0 = c.endX - 18, -- 491
			x1 = c.endX + 18, -- 492
			y0 = c.baseY - 4, -- 493
			y1 = c.baseY + 2, -- 494
			z0 = -12, -- 495
			z1 = 14, -- 496
			material = MING_MATERIALS.mingIron, -- 497
			bucket = LP_BUCKET.WALK_DECK, -- 498
			sortBias = 0.35, -- 499
			highlightTopEdge = true -- 500
		}) -- 500
		scene:addBox({ -- 503
			x0 = ox + 258, -- 504
			x1 = ox + 474, -- 505
			y0 = c.baseY - 1.5, -- 506
			y1 = c.baseY + 0.4, -- 507
			z0 = -11, -- 508
			z1 = -7, -- 509
			material = MING_MATERIALS.mingTimberDark, -- 510
			bucket = LP_BUCKET.WALK_DECK, -- 511
			sortBias = 0.3, -- 512
			edgeWidth = 0 -- 513
		}) -- 513
		scene:addBox({ -- 515
			x0 = ox + 258, -- 516
			x1 = ox + 474, -- 517
			y0 = c.baseY - 1.5, -- 518
			y1 = c.baseY + 0.4, -- 519
			z0 = 7, -- 520
			z1 = 11, -- 521
			material = MING_MATERIALS.mingTimberDark, -- 522
			bucket = LP_BUCKET.WALK_DECK, -- 523
			sortBias = 0.3, -- 524
			edgeWidth = 0 -- 525
		}) -- 525
	end -- 525
	scene:addBox({ -- 530
		x0 = ox + 128, -- 531
		x1 = ox + 598, -- 532
		y0 = 0, -- 533
		y1 = 92, -- 534
		z0 = 44, -- 535
		z1 = 72, -- 536
		material = MING_MATERIALS.mingBrickDark, -- 537
		bucket = LP_BUCKET.MIDGROUND, -- 538
		sortBias = -0.2, -- 539
		edgeWidth = 0.5 -- 540
	}) -- 540
	scene:addQuad3D( -- 543
		vec3(ox + 132, 26, 43), -- 544
		vec3(ox + 592, 26, 43), -- 545
		vec3(ox + 592, 31, 43), -- 546
		vec3(ox + 132, 31, 43), -- 547
		{base = rgba(138, 148, 158, 92)}, -- 548
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 549
	) -- 549
	scene:addLightShaft( -- 553
		ox + 1110, -- 554
		ox + 1180, -- 554
		170, -- 554
		ox + 1040, -- 555
		ox + 1140, -- 555
		0, -- 555
		34, -- 556
		rgba(234, 198, 138, 255), -- 557
		0.14, -- 558
		0.03 -- 559
	) -- 559
	scene:flush(fgDraw, fgGlow) -- 562
	local gi = 0 -- 565
	do -- 565
		gi = 0 -- 566
		while gi < 6 do -- 566
			local gx = ox + 165 + gi * 56 -- 567
			local p0 = projectWorld3D( -- 568
				gx, -- 568
				0.5, -- 568
				-14, -- 568
				cam, -- 568
				self.outsideProj -- 568
			) -- 568
			local p1 = projectWorld3D( -- 569
				gx + 10, -- 569
				0.5, -- 569
				22, -- 569
				cam, -- 569
				self.outsideProj -- 569
			) -- 569
			fgDraw:drawSegment( -- 570
				Vec2(p0.x, p0.y), -- 570
				Vec2(p1.x, p1.y), -- 570
				3, -- 570
				Color(8, 12, 18, 76) -- 570
			) -- 570
			gi = gi + 1 -- 566
		end -- 566
	end -- 566
	local row = 0 -- 574
	do -- 574
		row = 1 -- 575
		while row <= 6 do -- 575
			local wy = 96 + row * 19 -- 576
			local bL = projectWorld3D( -- 577
				ox + 513, -- 577
				wy, -- 577
				-8, -- 577
				cam, -- 577
				self.outsideProj -- 577
			) -- 577
			local bR = projectWorld3D( -- 578
				ox + 599, -- 578
				wy, -- 578
				-8, -- 578
				cam, -- 578
				self.outsideProj -- 578
			) -- 578
			fgDraw:drawSegment( -- 579
				Vec2(bL.x, bL.y), -- 579
				Vec2(bR.x, bR.y), -- 579
				0.9, -- 579
				Color(34, 40, 50, 185) -- 579
			) -- 579
			local off = row % 2 * 18 -- 580
			local colX = ox + 528 + off -- 581
			while colX < ox + 594 do -- 581
				local v0 = projectWorld3D( -- 583
					colX, -- 583
					wy - 19, -- 583
					-8, -- 583
					cam, -- 583
					self.outsideProj -- 583
				) -- 583
				local v1 = projectWorld3D( -- 584
					colX, -- 584
					wy, -- 584
					-8, -- 584
					cam, -- 584
					self.outsideProj -- 584
				) -- 584
				fgDraw:drawSegment( -- 585
					Vec2(v0.x, v0.y), -- 585
					Vec2(v1.x, v1.y), -- 585
					0.8, -- 585
					Color(32, 38, 48, 150) -- 585
				) -- 585
				colX = colX + 34 -- 586
			end -- 586
			row = row + 1 -- 575
		end -- 575
	end -- 575
	return true -- 590
end -- 477
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 593
	local p = ctx.p -- 594
	local cam = ctx.cam -- 595
	local ox = p.ox -- 596
	local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 597
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 598
	scene:addBox({ -- 601
		x0 = ox - 40, -- 602
		x1 = ox + 760, -- 603
		y0 = -52, -- 604
		y1 = 0, -- 605
		z0 = -26, -- 606
		z1 = 96, -- 607
		material = MING_MATERIALS.mingBrickDark, -- 608
		bucket = LP_BUCKET.WALK_DECK, -- 609
		highlightTopEdge = true -- 610
	}) -- 610
	scene:addBox({ -- 613
		x0 = ox + 398, -- 614
		x1 = ox + 492, -- 615
		y0 = -4, -- 616
		y1 = 2.5, -- 617
		z0 = -16, -- 618
		z1 = 26, -- 619
		material = MING_MATERIALS.mingStoneStep, -- 620
		bucket = LP_BUCKET.WALK_DECK, -- 621
		sortBias = 0.15, -- 622
		highlightTopEdge = true -- 623
	}) -- 623
	scene:addBox({ -- 627
		x0 = ox + 180, -- 628
		x1 = ox + 400, -- 629
		y0 = 0, -- 630
		y1 = 215, -- 631
		z0 = 8, -- 632
		z1 = 96, -- 633
		material = MING_MATERIALS.mingBrick, -- 634
		bucket = LP_BUCKET.MIDGROUND, -- 635
		highlightTopEdge = true -- 636
	}) -- 636
	scene:addBox({ -- 638
		x0 = ox + 490, -- 639
		x1 = ox + 720, -- 640
		y0 = 0, -- 641
		y1 = 215, -- 642
		z0 = 8, -- 643
		z1 = 96, -- 644
		material = MING_MATERIALS.mingBrick, -- 645
		bucket = LP_BUCKET.MIDGROUND, -- 646
		highlightTopEdge = true -- 647
	}) -- 647
	scene:addBeveledFrame( -- 651
		ox + 400, -- 651
		ox + 490, -- 651
		0, -- 651
		110, -- 651
		14, -- 651
		34, -- 651
		-8, -- 651
		68, -- 651
		MING_MATERIALS.mingStoneStep, -- 651
		{ -- 651
			bucket = LP_BUCKET.MIDGROUND, -- 652
			innerRimLight = rgba(244, 206, 140, 255), -- 653
			innerRimStrength = opened and 0.78 or 0.32 -- 654
		} -- 654
	) -- 654
	if not opened then -- 654
		scene:addBox({ -- 659
			x0 = ox + 404, -- 660
			x1 = ox + 486, -- 661
			y0 = 4, -- 662
			y1 = 109, -- 663
			z0 = 14, -- 664
			z1 = 26, -- 665
			material = MING_MATERIALS.mingTimberDark, -- 666
			bucket = LP_BUCKET.MIDGROUND, -- 667
			sortBias = 0.1, -- 668
			edgeWidth = 0.9 -- 669
		}) -- 669
	else -- 669
		scene:addQuad3D( -- 672
			vec3(ox + 404, 2, 24), -- 673
			vec3(ox + 486, 2, 24), -- 674
			vec3(ox + 486, 109, 24), -- 675
			vec3(ox + 404, 109, 24), -- 676
			{base = rgba(112, 78, 42, 255)}, -- 677
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 678
		) -- 678
	end -- 678
	scene:addQuad3D( -- 683
		vec3(ox + 286, 118, 6), -- 684
		vec3(ox + 306, 118, 6), -- 685
		vec3(ox + 306, 158, 6), -- 686
		vec3(ox + 286, 158, 6), -- 687
		{base = rgba(244, 204, 134, 255)}, -- 688
		{ -- 689
			bucket = LP_BUCKET.PROP, -- 689
			unlit = true, -- 689
			edgeColor = rgba(82, 68, 52, 255), -- 689
			edgeWidth = 1.4 -- 689
		} -- 689
	) -- 689
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 693
	scene:addLightShaft( -- 694
		ox + 412, -- 695
		ox + 478, -- 695
		106, -- 695
		ox + 382, -- 696
		ox + 506, -- 696
		0, -- 696
		6, -- 697
		rgba(246, 208, 138, 255), -- 698
		(opened and 0.34 or 0.08) * pulse, -- 699
		(opened and 0.16 or 0.04) * pulse -- 700
	) -- 700
	scene:addContactShadow( -- 704
		p.player.x, -- 704
		p.player.y, -- 704
		15, -- 704
		11, -- 704
		0.78, -- 704
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 704
	) -- 704
	scene:flush(fgDraw, fgGlow) -- 706
	local lampP = projectWorld3D( -- 709
		ox + 445, -- 709
		102, -- 709
		2, -- 709
		cam, -- 709
		self.towerProj -- 709
	) -- 709
	fillRadialGlow( -- 710
		fgGlow, -- 711
		lampP.x, -- 712
		lampP.y, -- 713
		cam:len(opened and 64 or 34) * pulse, -- 714
		cam:len(opened and 64 or 34) * pulse, -- 715
		Color( -- 716
			248, -- 716
			214, -- 716
			146, -- 716
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 716
		), -- 716
		Color(232, 174, 82, 0), -- 717
		16 -- 718
	) -- 718
	fgDraw:drawCircle( -- 720
		Vec2(lampP.x, lampP.y), -- 720
		4.2, -- 720
		Color(255, 240, 202, 245) -- 720
	) -- 720
	local winP = projectWorld3D( -- 722
		ox + 296, -- 722
		138, -- 722
		6, -- 722
		cam, -- 722
		self.towerProj -- 722
	) -- 722
	fillRadialGlow( -- 723
		fgGlow, -- 723
		winP.x, -- 723
		winP.y, -- 723
		cam:len(38), -- 723
		cam:len(42), -- 723
		Color( -- 723
			246, -- 723
			206, -- 723
			132, -- 723
			math.floor(78 * pulse + 0.5) -- 723
		), -- 723
		Color(232, 174, 82, 0), -- 723
		14 -- 723
	) -- 723
	local wBL = projectWorld3D( -- 725
		ox + 286, -- 725
		118, -- 725
		6, -- 725
		cam, -- 725
		self.towerProj -- 725
	) -- 725
	local wTR = projectWorld3D( -- 726
		ox + 306, -- 726
		158, -- 726
		6, -- 726
		cam, -- 726
		self.towerProj -- 726
	) -- 726
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 727
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 728
	fgDraw:drawSegment( -- 729
		Vec2(wMidX, wBL.y), -- 729
		Vec2(wMidX, wTR.y), -- 729
		1.4, -- 729
		Color(68, 52, 38, 225) -- 729
	) -- 729
	fgDraw:drawSegment( -- 730
		Vec2(wBL.x, wMidY), -- 730
		Vec2(wTR.x, wMidY), -- 730
		1.4, -- 730
		Color(68, 52, 38, 225) -- 730
	) -- 730
	local tr = 1 -- 731
	do -- 731
		tr = 1 -- 732
		while tr <= 6 do -- 732
			local ty = tr * 30 -- 733
			local tl0 = projectWorld3D( -- 734
				ox + 182, -- 734
				ty, -- 734
				8, -- 734
				cam, -- 734
				self.towerProj -- 734
			) -- 734
			local tl1 = projectWorld3D( -- 735
				ox + 398, -- 735
				ty, -- 735
				8, -- 735
				cam, -- 735
				self.towerProj -- 735
			) -- 735
			fgDraw:drawSegment( -- 736
				Vec2(tl0.x, tl0.y), -- 736
				Vec2(tl1.x, tl1.y), -- 736
				0.8, -- 736
				Color(34, 38, 48, 135) -- 736
			) -- 736
			local tr0 = projectWorld3D( -- 737
				ox + 492, -- 737
				ty, -- 737
				8, -- 737
				cam, -- 737
				self.towerProj -- 737
			) -- 737
			local tr1 = projectWorld3D( -- 738
				ox + 718, -- 738
				ty, -- 738
				8, -- 738
				cam, -- 738
				self.towerProj -- 738
			) -- 738
			fgDraw:drawSegment( -- 739
				Vec2(tr0.x, tr0.y), -- 739
				Vec2(tr1.x, tr1.y), -- 739
				0.8, -- 739
				Color(34, 38, 48, 135) -- 739
			) -- 739
			tr = tr + 1 -- 732
		end -- 732
	end -- 732
	return true -- 742
end -- 593
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 745
	if not self.active then -- 745
		return false -- 752
	end -- 752
	local key = ctx.p.room.key -- 754
	if key == "village" then -- 754
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 756
	end -- 756
	if key == "forest" then -- 756
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 759
	end -- 759
	if key == "outside" then -- 759
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 762
	end -- 762
	if key == "tower" then -- 762
		return true -- 765
	end -- 765
	return false -- 767
end -- 745
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 771
	local p = ctx.p -- 772
	local cam = ctx.cam -- 773
	local c = p.room.cart -- 774
	if c.bodyW <= 0 then -- 774
		return true -- 776
	end -- 776
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 778
	local halfW = c.bodyW * 0.5 -- 779
	local axleX = p.cartAxle -- 780
	local axleY = c.baseY + c.wheelR -- 781
	local bodyBot = axleY + 2 -- 782
	local bodyTop = bodyBot + c.bodyH -- 783
	scene:addBox({ -- 786
		x0 = axleX - halfW, -- 787
		x1 = axleX + halfW, -- 788
		y0 = bodyBot, -- 789
		y1 = bodyTop, -- 790
		z0 = -12, -- 791
		z1 = 14, -- 792
		material = MING_MATERIALS.mingTimber, -- 793
		bucket = LP_BUCKET.PROP, -- 794
		highlightTopEdge = true, -- 795
		edgeWidth = 1 -- 796
	}) -- 796
	scene:addBox({ -- 799
		x0 = axleX - halfW - 1, -- 800
		x1 = axleX + halfW + 1, -- 801
		y0 = bodyBot + 4, -- 802
		y1 = bodyBot + 8, -- 803
		z0 = -13, -- 804
		z1 = 15, -- 805
		material = MING_MATERIALS.mingIron, -- 806
		bucket = LP_BUCKET.PROP, -- 807
		sortBias = 0.08 -- 808
	}) -- 808
	local handleX = axleX + c.handleOffset -- 811
	scene:addBox({ -- 812
		x0 = axleX + halfW - 2, -- 813
		x1 = handleX, -- 814
		y0 = bodyTop - 6, -- 815
		y1 = bodyTop - 1, -- 816
		z0 = -10, -- 817
		z1 = -4, -- 818
		material = MING_MATERIALS.mingTimber, -- 819
		bucket = LP_BUCKET.PROP, -- 820
		sortBias = 0.12, -- 821
		highlightTopEdge = true -- 822
	}) -- 822
	scene:addBox({ -- 824
		x0 = handleX - 3, -- 825
		x1 = handleX + 3, -- 826
		y0 = bodyTop - 8, -- 827
		y1 = bodyTop + 2, -- 828
		z0 = -11, -- 829
		z1 = 9, -- 830
		material = MING_MATERIALS.mingTimber, -- 831
		bucket = LP_BUCKET.PROP, -- 832
		sortBias = 0.14, -- 833
		highlightTopEdge = true -- 834
	}) -- 834
	local clothX = axleX - halfW -- 838
	local clothTop = bodyTop + 1 -- 839
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 840
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 841
	scene:addTri3D( -- 842
		vec3(clothX - 2, clothTop + 1, -12), -- 843
		vec3(clothX + 11, clothTop, -11), -- 844
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 845
		MING_MATERIALS.mingRedCloth, -- 846
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 847
	) -- 847
	scene:addTri3D( -- 849
		vec3(clothX + 11, clothTop, -11), -- 850
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 851
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 852
		MING_MATERIALS.mingRedCloth, -- 853
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 854
	) -- 854
	scene:flush(fgDraw, fgGlow) -- 857
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 860
	local wheelR = cam:len(c.wheelR) -- 861
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 862
	local wi = 0 -- 863
	do -- 863
		wi = 0 -- 864
		while wi < #wheelXs do -- 864
			local wp = projectWorld3D( -- 865
				wheelXs[wi + 1], -- 865
				axleY, -- 865
				-10, -- 865
				cam, -- 865
				self.outsideProj -- 865
			) -- 865
			fgDraw:drawCircle( -- 866
				Vec2(wp.x, wp.y), -- 866
				wheelR, -- 866
				Color(52, 40, 32, 255) -- 866
			) -- 866
			fgDraw:drawRing( -- 867
				Vec2(wp.x, wp.y), -- 867
				math.max(1, wheelR - 2.6), -- 867
				wheelR, -- 867
				Color(0, 0, 0, 0), -- 867
				1.4, -- 867
				Color(148, 126, 102, 220) -- 867
			) -- 867
			local sp = 0 -- 868
			do -- 868
				sp = 0 -- 869
				while sp < 4 do -- 869
					local a = rollAngle + sp * math.pi / 4 -- 870
					local dx = math.cos(a) * (wheelR - 2) -- 871
					local dy = math.sin(a) * (wheelR - 2) -- 872
					fgDraw:drawSegment( -- 873
						Vec2(wp.x - dx, wp.y - dy), -- 873
						Vec2(wp.x + dx, wp.y + dy), -- 873
						1, -- 873
						Color(118, 92, 70, 210) -- 873
					) -- 873
					sp = sp + 1 -- 869
				end -- 869
			end -- 869
			fgDraw:drawDot( -- 875
				Vec2(wp.x, wp.y), -- 875
				2.4, -- 875
				Color(172, 160, 144, 230) -- 875
			) -- 875
			wi = wi + 1 -- 864
		end -- 864
	end -- 864
	local patchP = projectWorld3D( -- 879
		clothX + 1, -- 879
		clothTop - 7, -- 879
		-13, -- 879
		cam, -- 879
		self.outsideProj -- 879
	) -- 879
	fgDraw:drawSegment( -- 880
		Vec2(patchP.x - 3, patchP.y), -- 880
		Vec2(patchP.x + 3, patchP.y - 2), -- 880
		1, -- 880
		Color(224, 212, 188, 215) -- 880
	) -- 880
	fgDraw:drawSegment( -- 881
		Vec2(patchP.x - 2, patchP.y - 4), -- 881
		Vec2(patchP.x + 2, patchP.y - 5), -- 881
		0.9, -- 881
		Color(224, 212, 188, 195) -- 881
	) -- 881
	return true -- 883
end -- 771
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 886
	if not self.active then -- 886
		return -- 893
	end -- 893
	local key = ctx.p.room.key -- 895
	if key == "village" then -- 895
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 897
	elseif key == "forest" then -- 897
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 899
	end -- 899
end -- 886
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 907
	if not self.active then -- 907
		return false -- 915
	end -- 915
	local key = ctx.p.room.key -- 917
	if key == "village" then -- 917
		return self.village:drawForegroundOverlay( -- 919
			uiDraw, -- 919
			uiInkDraw, -- 919
			uiArt, -- 919
			uiGlow, -- 919
			ctx -- 919
		) -- 919
	end -- 919
	if key == "forest" then -- 919
		return self.forest:drawForegroundOverlay( -- 922
			uiDraw, -- 922
			uiInkDraw, -- 922
			uiArt, -- 922
			uiGlow, -- 922
			ctx -- 922
		) -- 922
	end -- 922
	if key == "outside" then -- 922
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 925
		return false -- 926
	end -- 926
	return false -- 928
end -- 907
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 935
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 935
		return -- 942
	end -- 942
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 944
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 946
	if alpha <= 0.01 then -- 946
		return -- 948
	end -- 948
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 950
	local handPt = projectWorld3D( -- 951
		self.memoryAnchorWorldX, -- 951
		self.memoryAnchorWorldY, -- 951
		0, -- 951
		ctx.cam, -- 951
		self.outsideProj -- 951
	) -- 951
	local cx = math.max( -- 953
		160, -- 953
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 953
	) -- 953
	local cy = math.max( -- 954
		150, -- 954
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 954
	) -- 954
	local rx = 122 -- 955
	local ry = 74 -- 956
	fillRadialGlow( -- 959
		uiGlow, -- 959
		cx, -- 959
		cy, -- 959
		rx * 1.55, -- 959
		ry * 1.55, -- 959
		Color( -- 959
			238, -- 959
			190, -- 959
			122, -- 959
			math.floor(92 * alpha + 0.5) -- 959
		), -- 959
		Color(218, 162, 92, 0), -- 959
		22 -- 959
	) -- 959
	uiDraw:drawEllipse( -- 960
		Vec2(cx, cy), -- 960
		rx * 1.12, -- 960
		ry * 1.12, -- 960
		Color( -- 960
			36, -- 960
			26, -- 960
			20, -- 960
			math.floor(128 * alpha + 0.5) -- 960
		) -- 960
	) -- 960
	uiDraw:drawEllipse( -- 961
		Vec2(cx, cy), -- 961
		rx * 0.96, -- 961
		ry * 0.96, -- 961
		Color( -- 961
			32, -- 961
			22, -- 961
			16, -- 961
			math.floor(206 * alpha + 0.5) -- 961
		) -- 961
	) -- 961
	uiDraw:drawPolygon( -- 964
		{ -- 964
			Vec2(cx - 72, cy - 34), -- 965
			Vec2(cx + 62, cy - 28), -- 966
			Vec2(cx + 70, cy + 32), -- 967
			Vec2(cx - 64, cy + 28) -- 968
		}, -- 968
		Color( -- 969
			148, -- 969
			44, -- 969
			40, -- 969
			math.floor(230 * alpha + 0.5) -- 969
		) -- 969
	) -- 969
	uiDraw:drawPolygon( -- 970
		{ -- 970
			Vec2(cx - 28, cy - 18), -- 971
			Vec2(cx + 26, cy - 14), -- 972
			Vec2(cx + 22, cy + 20), -- 973
			Vec2(cx - 24, cy + 16) -- 974
		}, -- 974
		Color( -- 975
			172, -- 975
			62, -- 975
			54, -- 975
			math.floor(238 * alpha + 0.5) -- 975
		), -- 975
		1, -- 975
		Color( -- 975
			224, -- 975
			210, -- 975
			184, -- 975
			math.floor(170 * alpha + 0.5) -- 975
		) -- 975
	) -- 975
	local si = 0 -- 978
	do -- 978
		si = 0 -- 979
		while si < 4 do -- 979
			local sx = cx - 18 + si * 11 -- 980
			uiInkDraw:drawSegment( -- 981
				Vec2(sx, cy - 15), -- 981
				Vec2(sx + 4, cy - 9), -- 981
				1.3, -- 981
				Color( -- 981
					236, -- 981
					224, -- 981
					198, -- 981
					math.floor(235 * alpha + 0.5) -- 981
				) -- 981
			) -- 981
			si = si + 1 -- 979
		end -- 979
	end -- 979
	local pullT = smoothstep(0.14, 0.82, prog) -- 985
	local stitchAnchorX = cx + 22 -- 986
	local stitchAnchorY = cy - 12 -- 987
	local handX = cx + 32 + pullT * 34 -- 988
	local handY = cy + 6 + pullT * 26 -- 989
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 992
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 993
	uiInkDraw:drawSegment( -- 994
		Vec2(stitchAnchorX, stitchAnchorY), -- 994
		Vec2(midX, midY), -- 994
		1.2, -- 994
		Color( -- 994
			242, -- 994
			234, -- 994
			214, -- 994
			math.floor(240 * alpha + 0.5) -- 994
		) -- 994
	) -- 994
	uiInkDraw:drawSegment( -- 995
		Vec2(midX, midY), -- 995
		Vec2(handX - 6, handY - 2), -- 995
		1.2, -- 995
		Color( -- 995
			242, -- 995
			234, -- 995
			214, -- 995
			math.floor(240 * alpha + 0.5) -- 995
		) -- 995
	) -- 995
	uiInkDraw:drawSegment( -- 998
		Vec2(handX - 16, handY - 8), -- 998
		Vec2(handX + 2, handY + 4), -- 998
		1.1, -- 998
		Color( -- 998
			230, -- 998
			236, -- 998
			242, -- 998
			math.floor(225 * alpha + 0.5) -- 998
		) -- 998
	) -- 998
	uiDraw:drawPolygon( -- 1001
		{ -- 1001
			Vec2(handX - 8, handY - 6), -- 1002
			Vec2(handX + 18, handY + 2), -- 1003
			Vec2(handX + 24, handY + 14), -- 1004
			Vec2(handX + 4, handY + 14), -- 1005
			Vec2(handX - 10, handY + 4) -- 1006
		}, -- 1006
		Color( -- 1007
			214, -- 1007
			174, -- 1007
			142, -- 1007
			math.floor(225 * alpha + 0.5) -- 1007
		), -- 1007
		1, -- 1007
		Color( -- 1007
			142, -- 1007
			102, -- 1007
			78, -- 1007
			math.floor(180 * alpha + 0.5) -- 1007
		) -- 1007
	) -- 1007
	uiDraw:drawEllipse( -- 1009
		Vec2(cx - 20, cy + 4), -- 1009
		16, -- 1009
		9, -- 1009
		Color( -- 1009
			204, -- 1009
			164, -- 1009
			134, -- 1009
			math.floor(220 * alpha + 0.5) -- 1009
		) -- 1009
	) -- 1009
end -- 935
function ____exports.createLowpolyWorldPlugin() -- 1013
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1014
end -- 1013
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1018
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1021
	fe:registerPlugin(lowpolyWorld) -- 1022
	return {lowpolyWorld = lowpolyWorld} -- 1023
end -- 1018
return ____exports -- 1018