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
	if not p.cartDocked and p.room.arch.h > 0 then -- 525
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 532
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 533
		if bx1 > bx0 + 4 then -- 533
			scene:addBox({ -- 535
				x0 = bx0, -- 536
				x1 = bx1, -- 537
				y0 = 2, -- 538
				y1 = p.room.arch.h, -- 539
				z0 = -6, -- 540
				z1 = 8, -- 541
				material = MING_MATERIALS.mingTimberDark, -- 542
				bucket = LP_BUCKET.PROP, -- 543
				highlightTopEdge = true, -- 544
				edgeWidth = 0.9 -- 545
			}) -- 545
			scene:addBox({ -- 548
				x0 = (bx0 + bx1) * 0.5 - 3, -- 549
				x1 = (bx0 + bx1) * 0.5 + 3, -- 550
				y0 = p.room.arch.h, -- 551
				y1 = p.room.cart.baseY, -- 552
				z0 = -3, -- 553
				z1 = 5, -- 554
				material = MING_MATERIALS.mingIron, -- 555
				bucket = LP_BUCKET.PROP, -- 556
				edgeWidth = 0.6 -- 557
			}) -- 557
		end -- 557
	end -- 557
	scene:addBox({ -- 563
		x0 = ox + 128, -- 564
		x1 = ox + 598, -- 565
		y0 = 0, -- 566
		y1 = 92, -- 567
		z0 = 44, -- 568
		z1 = 72, -- 569
		material = MING_MATERIALS.mingBrickDark, -- 570
		bucket = LP_BUCKET.MIDGROUND, -- 571
		sortBias = -0.2, -- 572
		edgeWidth = 0.5 -- 573
	}) -- 573
	scene:addQuad3D( -- 576
		vec3(ox + 132, 26, 43), -- 577
		vec3(ox + 592, 26, 43), -- 578
		vec3(ox + 592, 31, 43), -- 579
		vec3(ox + 132, 31, 43), -- 580
		{base = rgba(138, 148, 158, 92)}, -- 581
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 582
	) -- 582
	scene:addLightShaft( -- 586
		ox + 1110, -- 587
		ox + 1180, -- 587
		170, -- 587
		ox + 1040, -- 588
		ox + 1140, -- 588
		0, -- 588
		34, -- 589
		rgba(234, 198, 138, 255), -- 590
		0.14, -- 591
		0.03 -- 592
	) -- 592
	scene:flush(fgDraw, fgGlow) -- 595
	local gi = 0 -- 598
	do -- 598
		gi = 0 -- 599
		while gi < 6 do -- 599
			local gx = ox + 165 + gi * 56 -- 600
			local p0 = projectWorld3D( -- 601
				gx, -- 601
				0.5, -- 601
				-14, -- 601
				cam, -- 601
				self.outsideProj -- 601
			) -- 601
			local p1 = projectWorld3D( -- 602
				gx + 10, -- 602
				0.5, -- 602
				22, -- 602
				cam, -- 602
				self.outsideProj -- 602
			) -- 602
			fgDraw:drawSegment( -- 603
				Vec2(p0.x, p0.y), -- 603
				Vec2(p1.x, p1.y), -- 603
				3, -- 603
				Color(8, 12, 18, 76) -- 603
			) -- 603
			gi = gi + 1 -- 599
		end -- 599
	end -- 599
	local row = 0 -- 607
	do -- 607
		row = 1 -- 608
		while row <= 6 do -- 608
			local wy = 96 + row * 19 -- 609
			local bL = projectWorld3D( -- 610
				ox + 513, -- 610
				wy, -- 610
				-8, -- 610
				cam, -- 610
				self.outsideProj -- 610
			) -- 610
			local bR = projectWorld3D( -- 611
				ox + 599, -- 611
				wy, -- 611
				-8, -- 611
				cam, -- 611
				self.outsideProj -- 611
			) -- 611
			fgDraw:drawSegment( -- 612
				Vec2(bL.x, bL.y), -- 612
				Vec2(bR.x, bR.y), -- 612
				0.9, -- 612
				Color(34, 40, 50, 185) -- 612
			) -- 612
			local off = row % 2 * 18 -- 613
			local colX = ox + 528 + off -- 614
			while colX < ox + 594 do -- 614
				local v0 = projectWorld3D( -- 616
					colX, -- 616
					wy - 19, -- 616
					-8, -- 616
					cam, -- 616
					self.outsideProj -- 616
				) -- 616
				local v1 = projectWorld3D( -- 617
					colX, -- 617
					wy, -- 617
					-8, -- 617
					cam, -- 617
					self.outsideProj -- 617
				) -- 617
				fgDraw:drawSegment( -- 618
					Vec2(v0.x, v0.y), -- 618
					Vec2(v1.x, v1.y), -- 618
					0.8, -- 618
					Color(32, 38, 48, 150) -- 618
				) -- 618
				colX = colX + 34 -- 619
			end -- 619
			row = row + 1 -- 608
		end -- 608
	end -- 608
	return true -- 623
end -- 477
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 626
	local p = ctx.p -- 627
	local cam = ctx.cam -- 628
	local ox = p.ox -- 629
	local opened = p.phase == "tower-given" or p.phase == "tower-end" -- 630
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 631
	scene:addBox({ -- 634
		x0 = ox - 40, -- 635
		x1 = ox + 760, -- 636
		y0 = -52, -- 637
		y1 = 0, -- 638
		z0 = -26, -- 639
		z1 = 96, -- 640
		material = MING_MATERIALS.mingBrickDark, -- 641
		bucket = LP_BUCKET.WALK_DECK, -- 642
		highlightTopEdge = true -- 643
	}) -- 643
	scene:addBox({ -- 646
		x0 = ox + 398, -- 647
		x1 = ox + 492, -- 648
		y0 = -4, -- 649
		y1 = 2.5, -- 650
		z0 = -16, -- 651
		z1 = 26, -- 652
		material = MING_MATERIALS.mingStoneStep, -- 653
		bucket = LP_BUCKET.WALK_DECK, -- 654
		sortBias = 0.15, -- 655
		highlightTopEdge = true -- 656
	}) -- 656
	scene:addBox({ -- 660
		x0 = ox + 180, -- 661
		x1 = ox + 400, -- 662
		y0 = 0, -- 663
		y1 = 215, -- 664
		z0 = -8, -- 665
		z1 = 96, -- 666
		material = MING_MATERIALS.mingBrick, -- 667
		bucket = LP_BUCKET.MIDGROUND, -- 668
		highlightTopEdge = true -- 669
	}) -- 669
	scene:addBox({ -- 671
		x0 = ox + 490, -- 672
		x1 = ox + 720, -- 673
		y0 = 0, -- 674
		y1 = 215, -- 675
		z0 = -8, -- 676
		z1 = 96, -- 677
		material = MING_MATERIALS.mingBrick, -- 678
		bucket = LP_BUCKET.MIDGROUND, -- 679
		highlightTopEdge = true -- 680
	}) -- 680
	scene:addBeveledFrame( -- 684
		ox + 400, -- 684
		ox + 490, -- 684
		0, -- 684
		110, -- 684
		14, -- 684
		34, -- 684
		-8, -- 684
		68, -- 684
		MING_MATERIALS.mingStoneStep, -- 684
		{ -- 684
			bucket = LP_BUCKET.MIDGROUND, -- 685
			innerRimLight = rgba(244, 206, 140, 255), -- 686
			innerRimStrength = opened and 0.78 or 0.32 -- 687
		} -- 687
	) -- 687
	if not opened then -- 687
		scene:addBox({ -- 692
			x0 = ox + 404, -- 693
			x1 = ox + 486, -- 694
			y0 = 4, -- 695
			y1 = 109, -- 696
			z0 = 14, -- 697
			z1 = 26, -- 698
			material = MING_MATERIALS.mingTimberDark, -- 699
			bucket = LP_BUCKET.MIDGROUND, -- 700
			sortBias = 0.1, -- 701
			edgeWidth = 0.9 -- 702
		}) -- 702
	else -- 702
		scene:addQuad3D( -- 705
			vec3(ox + 404, 2, 24), -- 706
			vec3(ox + 486, 2, 24), -- 707
			vec3(ox + 486, 109, 24), -- 708
			vec3(ox + 404, 109, 24), -- 709
			{base = rgba(112, 78, 42, 255)}, -- 710
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 711
		) -- 711
	end -- 711
	scene:addQuad3D( -- 716
		vec3(ox + 286, 118, -9), -- 717
		vec3(ox + 306, 118, -9), -- 718
		vec3(ox + 306, 158, -9), -- 719
		vec3(ox + 286, 158, -9), -- 720
		{base = rgba(244, 204, 134, 255)}, -- 721
		{ -- 722
			bucket = LP_BUCKET.PROP, -- 722
			unlit = true, -- 722
			edgeColor = rgba(82, 68, 52, 255), -- 722
			edgeWidth = 1.4 -- 722
		} -- 722
	) -- 722
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 726
	scene:addLightShaft( -- 727
		ox + 412, -- 728
		ox + 478, -- 728
		106, -- 728
		ox + 382, -- 729
		ox + 506, -- 729
		0, -- 729
		6, -- 730
		rgba(246, 208, 138, 255), -- 731
		(opened and 0.34 or 0.08) * pulse, -- 732
		(opened and 0.16 or 0.04) * pulse -- 733
	) -- 733
	scene:addContactShadow( -- 737
		p.player.x, -- 737
		p.player.y, -- 737
		15, -- 737
		11, -- 737
		0.78, -- 737
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 737
	) -- 737
	scene:flush(fgDraw, fgGlow) -- 739
	local lampP = projectWorld3D( -- 742
		ox + 445, -- 742
		102, -- 742
		2, -- 742
		cam, -- 742
		self.towerProj -- 742
	) -- 742
	fillRadialGlow( -- 743
		fgGlow, -- 744
		lampP.x, -- 745
		lampP.y, -- 746
		cam:len(opened and 64 or 34) * pulse, -- 747
		cam:len(opened and 64 or 34) * pulse, -- 748
		Color( -- 749
			248, -- 749
			214, -- 749
			146, -- 749
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 749
		), -- 749
		Color(232, 174, 82, 0), -- 750
		16 -- 751
	) -- 751
	fgDraw:drawCircle( -- 753
		Vec2(lampP.x, lampP.y), -- 753
		4.2, -- 753
		Color(255, 240, 202, 245) -- 753
	) -- 753
	local winP = projectWorld3D( -- 755
		ox + 296, -- 755
		138, -- 755
		-9, -- 755
		cam, -- 755
		self.towerProj -- 755
	) -- 755
	fillRadialGlow( -- 756
		fgGlow, -- 756
		winP.x, -- 756
		winP.y, -- 756
		cam:len(38), -- 756
		cam:len(42), -- 756
		Color( -- 756
			246, -- 756
			206, -- 756
			132, -- 756
			math.floor(78 * pulse + 0.5) -- 756
		), -- 756
		Color(232, 174, 82, 0), -- 756
		14 -- 756
	) -- 756
	local wBL = projectWorld3D( -- 758
		ox + 286, -- 758
		118, -- 758
		-9, -- 758
		cam, -- 758
		self.towerProj -- 758
	) -- 758
	local wTR = projectWorld3D( -- 759
		ox + 306, -- 759
		158, -- 759
		-9, -- 759
		cam, -- 759
		self.towerProj -- 759
	) -- 759
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 760
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 761
	fgDraw:drawSegment( -- 762
		Vec2(wMidX, wBL.y), -- 762
		Vec2(wMidX, wTR.y), -- 762
		1.4, -- 762
		Color(68, 52, 38, 225) -- 762
	) -- 762
	fgDraw:drawSegment( -- 763
		Vec2(wBL.x, wMidY), -- 763
		Vec2(wTR.x, wMidY), -- 763
		1.4, -- 763
		Color(68, 52, 38, 225) -- 763
	) -- 763
	local tr = 1 -- 764
	do -- 764
		tr = 1 -- 765
		while tr <= 6 do -- 765
			local ty = tr * 30 -- 766
			local tl0 = projectWorld3D( -- 767
				ox + 182, -- 767
				ty, -- 767
				-8, -- 767
				cam, -- 767
				self.towerProj -- 767
			) -- 767
			local tl1 = projectWorld3D( -- 768
				ox + 398, -- 768
				ty, -- 768
				-8, -- 768
				cam, -- 768
				self.towerProj -- 768
			) -- 768
			fgDraw:drawSegment( -- 769
				Vec2(tl0.x, tl0.y), -- 769
				Vec2(tl1.x, tl1.y), -- 769
				0.8, -- 769
				Color(34, 38, 48, 135) -- 769
			) -- 769
			local tr0 = projectWorld3D( -- 770
				ox + 492, -- 770
				ty, -- 770
				-8, -- 770
				cam, -- 770
				self.towerProj -- 770
			) -- 770
			local tr1 = projectWorld3D( -- 771
				ox + 718, -- 771
				ty, -- 771
				-8, -- 771
				cam, -- 771
				self.towerProj -- 771
			) -- 771
			fgDraw:drawSegment( -- 772
				Vec2(tr0.x, tr0.y), -- 772
				Vec2(tr1.x, tr1.y), -- 772
				0.8, -- 772
				Color(34, 38, 48, 135) -- 772
			) -- 772
			tr = tr + 1 -- 765
		end -- 765
	end -- 765
	return true -- 775
end -- 626
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 778
	if not self.active then -- 778
		return false -- 785
	end -- 785
	local key = ctx.p.room.key -- 787
	if key == "village" then -- 787
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 789
	end -- 789
	if key == "forest" then -- 789
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 792
	end -- 792
	if key == "outside" then -- 792
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 795
	end -- 795
	if key == "tower" then -- 795
		return true -- 798
	end -- 798
	return false -- 800
end -- 778
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 804
	local p = ctx.p -- 805
	local cam = ctx.cam -- 806
	local c = p.room.cart -- 807
	if c.bodyW <= 0 then -- 807
		return true -- 809
	end -- 809
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 811
	local halfW = c.bodyW * 0.5 -- 812
	local axleX = p.cartAxle -- 813
	local axleY = c.baseY + c.wheelR -- 814
	local bodyBot = axleY + 2 -- 815
	local bodyTop = bodyBot + c.bodyH -- 816
	scene:addBox({ -- 819
		x0 = axleX - halfW, -- 820
		x1 = axleX + halfW, -- 821
		y0 = bodyBot, -- 822
		y1 = bodyTop, -- 823
		z0 = -12, -- 824
		z1 = 14, -- 825
		material = MING_MATERIALS.mingTimber, -- 826
		bucket = LP_BUCKET.PROP, -- 827
		highlightTopEdge = true, -- 828
		edgeWidth = 1 -- 829
	}) -- 829
	scene:addBox({ -- 832
		x0 = axleX - halfW - 1, -- 833
		x1 = axleX + halfW + 1, -- 834
		y0 = bodyBot + 4, -- 835
		y1 = bodyBot + 8, -- 836
		z0 = -13, -- 837
		z1 = 15, -- 838
		material = MING_MATERIALS.mingIron, -- 839
		bucket = LP_BUCKET.PROP, -- 840
		sortBias = 0.08 -- 841
	}) -- 841
	local handleX = axleX + c.handleOffset -- 844
	scene:addBox({ -- 845
		x0 = axleX + halfW - 2, -- 846
		x1 = handleX, -- 847
		y0 = bodyTop - 6, -- 848
		y1 = bodyTop - 1, -- 849
		z0 = -10, -- 850
		z1 = -4, -- 851
		material = MING_MATERIALS.mingTimber, -- 852
		bucket = LP_BUCKET.PROP, -- 853
		sortBias = 0.12, -- 854
		highlightTopEdge = true -- 855
	}) -- 855
	scene:addBox({ -- 857
		x0 = handleX - 3, -- 858
		x1 = handleX + 3, -- 859
		y0 = bodyTop - 8, -- 860
		y1 = bodyTop + 2, -- 861
		z0 = -11, -- 862
		z1 = 9, -- 863
		material = MING_MATERIALS.mingTimber, -- 864
		bucket = LP_BUCKET.PROP, -- 865
		sortBias = 0.14, -- 866
		highlightTopEdge = true -- 867
	}) -- 867
	local clothX = axleX - halfW -- 871
	local clothTop = bodyTop + 1 -- 872
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 873
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 874
	scene:addTri3D( -- 875
		vec3(clothX - 2, clothTop + 1, -12), -- 876
		vec3(clothX + 11, clothTop, -11), -- 877
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 878
		MING_MATERIALS.mingRedCloth, -- 879
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 880
	) -- 880
	scene:addTri3D( -- 882
		vec3(clothX + 11, clothTop, -11), -- 883
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 884
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 885
		MING_MATERIALS.mingRedCloth, -- 886
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 887
	) -- 887
	scene:flush(fgDraw, fgGlow) -- 890
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 893
	local wheelR = cam:len(c.wheelR) -- 894
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 895
	local wi = 0 -- 896
	do -- 896
		wi = 0 -- 897
		while wi < #wheelXs do -- 897
			local wp = projectWorld3D( -- 898
				wheelXs[wi + 1], -- 898
				axleY, -- 898
				-10, -- 898
				cam, -- 898
				self.outsideProj -- 898
			) -- 898
			fgDraw:drawCircle( -- 899
				Vec2(wp.x, wp.y), -- 899
				wheelR, -- 899
				Color(52, 40, 32, 255) -- 899
			) -- 899
			fgDraw:drawRing( -- 900
				Vec2(wp.x, wp.y), -- 900
				math.max(1, wheelR - 2.6), -- 900
				wheelR, -- 900
				Color(0, 0, 0, 0), -- 900
				1.4, -- 900
				Color(148, 126, 102, 220) -- 900
			) -- 900
			local sp = 0 -- 901
			do -- 901
				sp = 0 -- 902
				while sp < 4 do -- 902
					local a = rollAngle + sp * math.pi / 4 -- 903
					local dx = math.cos(a) * (wheelR - 2) -- 904
					local dy = math.sin(a) * (wheelR - 2) -- 905
					fgDraw:drawSegment( -- 906
						Vec2(wp.x - dx, wp.y - dy), -- 906
						Vec2(wp.x + dx, wp.y + dy), -- 906
						1, -- 906
						Color(118, 92, 70, 210) -- 906
					) -- 906
					sp = sp + 1 -- 902
				end -- 902
			end -- 902
			fgDraw:drawDot( -- 908
				Vec2(wp.x, wp.y), -- 908
				2.4, -- 908
				Color(172, 160, 144, 230) -- 908
			) -- 908
			wi = wi + 1 -- 897
		end -- 897
	end -- 897
	local patchP = projectWorld3D( -- 912
		clothX + 1, -- 912
		clothTop - 7, -- 912
		-13, -- 912
		cam, -- 912
		self.outsideProj -- 912
	) -- 912
	fgDraw:drawSegment( -- 913
		Vec2(patchP.x - 3, patchP.y), -- 913
		Vec2(patchP.x + 3, patchP.y - 2), -- 913
		1, -- 913
		Color(224, 212, 188, 215) -- 913
	) -- 913
	fgDraw:drawSegment( -- 914
		Vec2(patchP.x - 2, patchP.y - 4), -- 914
		Vec2(patchP.x + 2, patchP.y - 5), -- 914
		0.9, -- 914
		Color(224, 212, 188, 195) -- 914
	) -- 914
	return true -- 916
end -- 804
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 919
	if not self.active then -- 919
		return -- 926
	end -- 926
	local key = ctx.p.room.key -- 928
	if key == "village" then -- 928
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 930
	elseif key == "forest" then -- 930
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 932
	end -- 932
end -- 919
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 940
	if not self.active then -- 940
		return false -- 948
	end -- 948
	local key = ctx.p.room.key -- 950
	if key == "village" then -- 950
		return self.village:drawForegroundOverlay( -- 952
			uiDraw, -- 952
			uiInkDraw, -- 952
			uiArt, -- 952
			uiGlow, -- 952
			ctx -- 952
		) -- 952
	end -- 952
	if key == "forest" then -- 952
		return self.forest:drawForegroundOverlay( -- 955
			uiDraw, -- 955
			uiInkDraw, -- 955
			uiArt, -- 955
			uiGlow, -- 955
			ctx -- 955
		) -- 955
	end -- 955
	if key == "outside" then -- 955
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 958
		return false -- 959
	end -- 959
	return false -- 961
end -- 940
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 968
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 968
		return -- 975
	end -- 975
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 977
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 979
	if alpha <= 0.01 then -- 979
		return -- 981
	end -- 981
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 983
	local handPt = projectWorld3D( -- 984
		self.memoryAnchorWorldX, -- 984
		self.memoryAnchorWorldY, -- 984
		0, -- 984
		ctx.cam, -- 984
		self.outsideProj -- 984
	) -- 984
	local cx = math.max( -- 986
		160, -- 986
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 986
	) -- 986
	local cy = math.max( -- 987
		150, -- 987
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 987
	) -- 987
	local rx = 122 -- 988
	local ry = 74 -- 989
	fillRadialGlow( -- 992
		uiGlow, -- 992
		cx, -- 992
		cy, -- 992
		rx * 1.55, -- 992
		ry * 1.55, -- 992
		Color( -- 992
			238, -- 992
			190, -- 992
			122, -- 992
			math.floor(92 * alpha + 0.5) -- 992
		), -- 992
		Color(218, 162, 92, 0), -- 992
		22 -- 992
	) -- 992
	uiDraw:drawEllipse( -- 993
		Vec2(cx, cy), -- 993
		rx * 1.12, -- 993
		ry * 1.12, -- 993
		Color( -- 993
			36, -- 993
			26, -- 993
			20, -- 993
			math.floor(128 * alpha + 0.5) -- 993
		) -- 993
	) -- 993
	uiDraw:drawEllipse( -- 994
		Vec2(cx, cy), -- 994
		rx * 0.96, -- 994
		ry * 0.96, -- 994
		Color( -- 994
			32, -- 994
			22, -- 994
			16, -- 994
			math.floor(206 * alpha + 0.5) -- 994
		) -- 994
	) -- 994
	uiDraw:drawPolygon( -- 997
		{ -- 997
			Vec2(cx - 72, cy - 34), -- 998
			Vec2(cx + 62, cy - 28), -- 999
			Vec2(cx + 70, cy + 32), -- 1000
			Vec2(cx - 64, cy + 28) -- 1001
		}, -- 1001
		Color( -- 1002
			148, -- 1002
			44, -- 1002
			40, -- 1002
			math.floor(230 * alpha + 0.5) -- 1002
		) -- 1002
	) -- 1002
	uiDraw:drawPolygon( -- 1003
		{ -- 1003
			Vec2(cx - 28, cy - 18), -- 1004
			Vec2(cx + 26, cy - 14), -- 1005
			Vec2(cx + 22, cy + 20), -- 1006
			Vec2(cx - 24, cy + 16) -- 1007
		}, -- 1007
		Color( -- 1008
			172, -- 1008
			62, -- 1008
			54, -- 1008
			math.floor(238 * alpha + 0.5) -- 1008
		), -- 1008
		1, -- 1008
		Color( -- 1008
			224, -- 1008
			210, -- 1008
			184, -- 1008
			math.floor(170 * alpha + 0.5) -- 1008
		) -- 1008
	) -- 1008
	local si = 0 -- 1011
	do -- 1011
		si = 0 -- 1012
		while si < 4 do -- 1012
			local sx = cx - 18 + si * 11 -- 1013
			uiInkDraw:drawSegment( -- 1014
				Vec2(sx, cy - 15), -- 1014
				Vec2(sx + 4, cy - 9), -- 1014
				1.3, -- 1014
				Color( -- 1014
					236, -- 1014
					224, -- 1014
					198, -- 1014
					math.floor(235 * alpha + 0.5) -- 1014
				) -- 1014
			) -- 1014
			si = si + 1 -- 1012
		end -- 1012
	end -- 1012
	local pullT = smoothstep(0.14, 0.82, prog) -- 1018
	local stitchAnchorX = cx + 22 -- 1019
	local stitchAnchorY = cy - 12 -- 1020
	local handX = cx + 32 + pullT * 34 -- 1021
	local handY = cy + 6 + pullT * 26 -- 1022
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1025
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1026
	uiInkDraw:drawSegment( -- 1027
		Vec2(stitchAnchorX, stitchAnchorY), -- 1027
		Vec2(midX, midY), -- 1027
		1.2, -- 1027
		Color( -- 1027
			242, -- 1027
			234, -- 1027
			214, -- 1027
			math.floor(240 * alpha + 0.5) -- 1027
		) -- 1027
	) -- 1027
	uiInkDraw:drawSegment( -- 1028
		Vec2(midX, midY), -- 1028
		Vec2(handX - 6, handY - 2), -- 1028
		1.2, -- 1028
		Color( -- 1028
			242, -- 1028
			234, -- 1028
			214, -- 1028
			math.floor(240 * alpha + 0.5) -- 1028
		) -- 1028
	) -- 1028
	uiInkDraw:drawSegment( -- 1031
		Vec2(handX - 16, handY - 8), -- 1031
		Vec2(handX + 2, handY + 4), -- 1031
		1.1, -- 1031
		Color( -- 1031
			230, -- 1031
			236, -- 1031
			242, -- 1031
			math.floor(225 * alpha + 0.5) -- 1031
		) -- 1031
	) -- 1031
	uiDraw:drawPolygon( -- 1034
		{ -- 1034
			Vec2(handX - 8, handY - 6), -- 1035
			Vec2(handX + 18, handY + 2), -- 1036
			Vec2(handX + 24, handY + 14), -- 1037
			Vec2(handX + 4, handY + 14), -- 1038
			Vec2(handX - 10, handY + 4) -- 1039
		}, -- 1039
		Color( -- 1040
			214, -- 1040
			174, -- 1040
			142, -- 1040
			math.floor(225 * alpha + 0.5) -- 1040
		), -- 1040
		1, -- 1040
		Color( -- 1040
			142, -- 1040
			102, -- 1040
			78, -- 1040
			math.floor(180 * alpha + 0.5) -- 1040
		) -- 1040
	) -- 1040
	uiDraw:drawEllipse( -- 1042
		Vec2(cx - 20, cy + 4), -- 1042
		16, -- 1042
		9, -- 1042
		Color( -- 1042
			204, -- 1042
			164, -- 1042
			134, -- 1042
			math.floor(220 * alpha + 0.5) -- 1042
		) -- 1042
	) -- 1042
end -- 968
function ____exports.createLowpolyWorldPlugin() -- 1046
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1047
end -- 1046
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1051
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1054
	fe:registerPlugin(lowpolyWorld) -- 1055
	return {lowpolyWorld = lowpolyWorld} -- 1056
end -- 1051
return ____exports -- 1051