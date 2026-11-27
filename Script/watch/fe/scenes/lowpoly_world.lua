-- [ts]: lowpoly_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
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
		if p.gripping and not self.prevGripping and not self.memoryPlayed then -- 288
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
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 303
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
		if self.cartWheelVol > 0.03 then -- 314
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
	if not self.active then -- 338
		return false -- 339
	end -- 339
	local key = ctx.p.room.key -- 341
	if key == "village" then -- 342
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 343
	end -- 343
	if key == "forest" then -- 345
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 346
	end -- 346
	if key == "outside" then -- 348
		return self:drawOutsideBackdrop(bgDraw, bgGlow, ctx) -- 349
	end -- 349
	if key == "tower" then -- 351
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
		-40, -- 439
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
	if not self.active then -- 458
		return false -- 459
	end -- 459
	local key = ctx.p.room.key -- 461
	if key == "village" then -- 462
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 463
	end -- 463
	if key == "forest" then -- 465
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 466
	end -- 466
	if key == "outside" then -- 468
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 469
	end -- 469
	if key == "tower" then -- 471
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
	if c.bodyW > 0 then -- 488
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
	if not p.cartDocked and p.room.arch.h > 0 then -- 531
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 532
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 533
		if bx1 > bx0 + 4 then -- 534
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
			while colX < ox + 594 do -- 615
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
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 630
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 635
	scene:addBox({ -- 638
		x0 = ox - 40, -- 639
		x1 = ox + 760, -- 640
		y0 = -52, -- 641
		y1 = 0, -- 642
		z0 = -26, -- 643
		z1 = 96, -- 644
		material = MING_MATERIALS.mingBrickDark, -- 645
		bucket = LP_BUCKET.WALK_DECK, -- 646
		highlightTopEdge = true -- 647
	}) -- 647
	scene:addBox({ -- 650
		x0 = ox + 398, -- 651
		x1 = ox + 492, -- 652
		y0 = -4, -- 653
		y1 = 2.5, -- 654
		z0 = -16, -- 655
		z1 = 26, -- 656
		material = MING_MATERIALS.mingStoneStep, -- 657
		bucket = LP_BUCKET.WALK_DECK, -- 658
		sortBias = 0.15, -- 659
		highlightTopEdge = true -- 660
	}) -- 660
	scene:addBox({ -- 664
		x0 = ox + 180, -- 665
		x1 = ox + 400, -- 666
		y0 = 0, -- 667
		y1 = 215, -- 668
		z0 = -8, -- 669
		z1 = 96, -- 670
		material = MING_MATERIALS.mingBrick, -- 671
		bucket = LP_BUCKET.MIDGROUND, -- 672
		highlightTopEdge = true -- 673
	}) -- 673
	scene:addBox({ -- 675
		x0 = ox + 490, -- 676
		x1 = ox + 720, -- 677
		y0 = 0, -- 678
		y1 = 215, -- 679
		z0 = -8, -- 680
		z1 = 96, -- 681
		material = MING_MATERIALS.mingBrick, -- 682
		bucket = LP_BUCKET.MIDGROUND, -- 683
		highlightTopEdge = true -- 684
	}) -- 684
	scene:addBeveledFrame( -- 688
		ox + 400, -- 688
		ox + 490, -- 688
		0, -- 688
		110, -- 688
		14, -- 688
		34, -- 688
		-8, -- 688
		68, -- 688
		MING_MATERIALS.mingStoneStep, -- 688
		{ -- 688
			bucket = LP_BUCKET.MIDGROUND, -- 689
			innerRimLight = rgba(244, 206, 140, 255), -- 690
			innerRimStrength = opened and 0.78 or 0.32 -- 691
		} -- 691
	) -- 691
	if not opened then -- 695
		scene:addBox({ -- 696
			x0 = ox + 404, -- 697
			x1 = ox + 486, -- 698
			y0 = 4, -- 699
			y1 = 109, -- 700
			z0 = 14, -- 701
			z1 = 26, -- 702
			material = MING_MATERIALS.mingTimberDark, -- 703
			bucket = LP_BUCKET.MIDGROUND, -- 704
			sortBias = 0.1, -- 705
			edgeWidth = 0.9 -- 706
		}) -- 706
	else -- 706
		scene:addQuad3D( -- 709
			vec3(ox + 404, 2, 24), -- 710
			vec3(ox + 486, 2, 24), -- 711
			vec3(ox + 486, 109, 24), -- 712
			vec3(ox + 404, 109, 24), -- 713
			{base = rgba(112, 78, 42, 255)}, -- 714
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 715
		) -- 715
	end -- 715
	scene:addQuad3D( -- 720
		vec3(ox + 286, 118, -9), -- 721
		vec3(ox + 306, 118, -9), -- 722
		vec3(ox + 306, 158, -9), -- 723
		vec3(ox + 286, 158, -9), -- 724
		{base = rgba(244, 204, 134, 255)}, -- 725
		{ -- 726
			bucket = LP_BUCKET.PROP, -- 726
			unlit = true, -- 726
			edgeColor = rgba(82, 68, 52, 255), -- 726
			edgeWidth = 1.4 -- 726
		} -- 726
	) -- 726
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 730
	scene:addLightShaft( -- 731
		ox + 412, -- 732
		ox + 478, -- 732
		106, -- 732
		ox + 382, -- 733
		ox + 506, -- 733
		0, -- 733
		6, -- 734
		rgba(246, 208, 138, 255), -- 735
		(opened and 0.34 or 0.08) * pulse, -- 736
		(opened and 0.16 or 0.04) * pulse -- 737
	) -- 737
	scene:addContactShadow( -- 741
		p.player.x, -- 741
		p.player.y, -- 741
		15, -- 741
		11, -- 741
		0.78, -- 741
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 741
	) -- 741
	scene:flush(fgDraw, fgGlow) -- 743
	local lampP = projectWorld3D( -- 746
		ox + 445, -- 746
		102, -- 746
		2, -- 746
		cam, -- 746
		self.towerProj -- 746
	) -- 746
	fillRadialGlow( -- 747
		fgGlow, -- 748
		lampP.x, -- 749
		lampP.y, -- 750
		cam:len(opened and 64 or 34) * pulse, -- 751
		cam:len(opened and 64 or 34) * pulse, -- 752
		Color( -- 753
			248, -- 753
			214, -- 753
			146, -- 753
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 753
		), -- 753
		Color(232, 174, 82, 0), -- 754
		16 -- 755
	) -- 755
	fgDraw:drawCircle( -- 757
		Vec2(lampP.x, lampP.y), -- 757
		4.2, -- 757
		Color(255, 240, 202, 245) -- 757
	) -- 757
	local winP = projectWorld3D( -- 759
		ox + 296, -- 759
		138, -- 759
		-9, -- 759
		cam, -- 759
		self.towerProj -- 759
	) -- 759
	fillRadialGlow( -- 760
		fgGlow, -- 760
		winP.x, -- 760
		winP.y, -- 760
		cam:len(38), -- 760
		cam:len(42), -- 760
		Color( -- 760
			246, -- 760
			206, -- 760
			132, -- 760
			math.floor(78 * pulse + 0.5) -- 760
		), -- 760
		Color(232, 174, 82, 0), -- 760
		14 -- 760
	) -- 760
	local wBL = projectWorld3D( -- 762
		ox + 286, -- 762
		118, -- 762
		-9, -- 762
		cam, -- 762
		self.towerProj -- 762
	) -- 762
	local wTR = projectWorld3D( -- 763
		ox + 306, -- 763
		158, -- 763
		-9, -- 763
		cam, -- 763
		self.towerProj -- 763
	) -- 763
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 764
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 765
	fgDraw:drawSegment( -- 766
		Vec2(wMidX, wBL.y), -- 766
		Vec2(wMidX, wTR.y), -- 766
		1.4, -- 766
		Color(68, 52, 38, 225) -- 766
	) -- 766
	fgDraw:drawSegment( -- 767
		Vec2(wBL.x, wMidY), -- 767
		Vec2(wTR.x, wMidY), -- 767
		1.4, -- 767
		Color(68, 52, 38, 225) -- 767
	) -- 767
	local tr = 1 -- 768
	do -- 768
		tr = 1 -- 769
		while tr <= 6 do -- 769
			local ty = tr * 30 -- 770
			local tl0 = projectWorld3D( -- 771
				ox + 182, -- 771
				ty, -- 771
				-8, -- 771
				cam, -- 771
				self.towerProj -- 771
			) -- 771
			local tl1 = projectWorld3D( -- 772
				ox + 398, -- 772
				ty, -- 772
				-8, -- 772
				cam, -- 772
				self.towerProj -- 772
			) -- 772
			fgDraw:drawSegment( -- 773
				Vec2(tl0.x, tl0.y), -- 773
				Vec2(tl1.x, tl1.y), -- 773
				0.8, -- 773
				Color(34, 38, 48, 135) -- 773
			) -- 773
			local tr0 = projectWorld3D( -- 774
				ox + 492, -- 774
				ty, -- 774
				-8, -- 774
				cam, -- 774
				self.towerProj -- 774
			) -- 774
			local tr1 = projectWorld3D( -- 775
				ox + 718, -- 775
				ty, -- 775
				-8, -- 775
				cam, -- 775
				self.towerProj -- 775
			) -- 775
			fgDraw:drawSegment( -- 776
				Vec2(tr0.x, tr0.y), -- 776
				Vec2(tr1.x, tr1.y), -- 776
				0.8, -- 776
				Color(34, 38, 48, 135) -- 776
			) -- 776
			tr = tr + 1 -- 769
		end -- 769
	end -- 769
	return true -- 779
end -- 626
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 782
	if not self.active then -- 788
		return false -- 789
	end -- 789
	local key = ctx.p.room.key -- 791
	if key == "village" then -- 792
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 793
	end -- 793
	if key == "forest" then -- 795
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 796
	end -- 796
	if key == "outside" then -- 798
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 799
	end -- 799
	if key == "tower" then -- 801
		local p = ctx.p -- 802
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 803
		if opened then -- 804
			local cam = ctx.cam -- 805
			local deskCx = cam:sx(p.ox + 605) -- 806
			local groundY = cam:sy(0) -- 807
			local deskW = cam:len(84) -- 808
			local deskH = cam:len(34) -- 809
			local deskTop = groundY + deskH -- 810
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 811
			fillRadialGlow( -- 812
				fgGlow, -- 812
				deskCx, -- 812
				deskTop + cam:len(28), -- 812
				cam:len(120), -- 812
				cam:len(88), -- 812
				Color( -- 813
					255, -- 813
					198, -- 813
					114, -- 813
					math.floor(74 * pulse + 0.5) -- 813
				), -- 813
				Color(255, 168, 72, 0), -- 813
				16 -- 813
			) -- 813
			local guardX = deskCx + cam:len(26) -- 815
			fgDraw:drawRect( -- 816
				Rect( -- 816
					guardX - cam:len(11), -- 816
					groundY, -- 816
					cam:len(22), -- 816
					cam:len(68) -- 816
				), -- 816
				Color(28, 34, 44, 240) -- 816
			) -- 816
			fgDraw:drawCircle( -- 817
				Vec2( -- 817
					guardX, -- 817
					groundY + cam:len(76) -- 817
				), -- 817
				cam:len(9.5), -- 817
				Color(36, 44, 56, 245) -- 817
			) -- 817
			fgDraw:drawRect( -- 818
				Rect( -- 818
					deskCx - deskW * 0.5, -- 818
					groundY, -- 818
					cam:len(6), -- 818
					deskH -- 818
				), -- 818
				Color(74, 48, 30, 255) -- 818
			) -- 818
			fgDraw:drawRect( -- 819
				Rect( -- 819
					deskCx + deskW * 0.5 - cam:len(6), -- 819
					groundY, -- 819
					cam:len(6), -- 819
					deskH -- 819
				), -- 819
				Color(74, 48, 30, 255) -- 819
			) -- 819
			fgDraw:drawRect( -- 820
				Rect( -- 820
					deskCx - deskW * 0.52, -- 820
					deskTop - cam:len(6), -- 820
					deskW * 1.04, -- 820
					cam:len(8) -- 820
				), -- 820
				Color(102, 68, 42, 255), -- 820
				1, -- 820
				Color(146, 106, 66, 220) -- 820
			) -- 820
			fgDraw:drawRect( -- 821
				Rect( -- 821
					deskCx + cam:len(4), -- 821
					deskTop + cam:len(2), -- 821
					cam:len(24), -- 821
					cam:len(5) -- 821
				), -- 821
				Color(230, 220, 196, 245) -- 821
			) -- 821
			fgDraw:drawRect( -- 822
				Rect( -- 822
					deskCx + cam:len(32), -- 822
					deskTop + cam:len(2), -- 822
					cam:len(8), -- 822
					cam:len(12) -- 822
				), -- 822
				Color(166, 126, 62, 245) -- 822
			) -- 822
			fgGlow:drawCircle( -- 823
				Vec2( -- 823
					deskCx + cam:len(36), -- 823
					deskTop + cam:len(16) -- 823
				), -- 823
				cam:len(5.5), -- 823
				Color( -- 823
					255, -- 823
					224, -- 823
					152, -- 823
					math.floor(220 * pulse + 0.5) -- 823
				) -- 823
			) -- 823
			if p.deskHold >= 12 or p.towerHanded then -- 824
				fgDraw:drawRect( -- 825
					Rect( -- 825
						deskCx - cam:len(28), -- 825
						deskTop + cam:len(2), -- 825
						cam:len(14), -- 825
						cam:len(6) -- 825
					), -- 825
					Color(156, 62, 48, 245) -- 825
				) -- 825
			end -- 825
			if p.deskHold >= 24 or p.towerHanded then -- 827
				fgDraw:drawCircle( -- 828
					Vec2( -- 828
						deskCx - cam:len(8), -- 828
						deskTop + cam:len(5) -- 828
					), -- 828
					cam:len(4.5), -- 828
					Color(224, 186, 98, 255) -- 828
				) -- 828
				fgDraw:drawRect( -- 829
					Rect( -- 829
						deskCx - cam:len(16), -- 829
						deskTop + cam:len(2), -- 829
						cam:len(10), -- 829
						cam:len(3) -- 829
					), -- 829
					Color(236, 228, 206, 240) -- 829
				) -- 829
			end -- 829
		end -- 829
		return true -- 832
	end -- 832
	return false -- 834
end -- 782
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 838
	local p = ctx.p -- 839
	local cam = ctx.cam -- 840
	local c = p.room.cart -- 841
	if c.bodyW <= 0 then -- 842
		return true -- 843
	end -- 843
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 845
	local halfW = c.bodyW * 0.5 -- 846
	local axleX = p.cartAxle -- 847
	local axleY = c.baseY + c.wheelR -- 848
	local bodyBot = axleY + 2 -- 849
	local bodyTop = bodyBot + c.bodyH -- 850
	scene:addBox({ -- 853
		x0 = axleX - halfW, -- 854
		x1 = axleX + halfW, -- 855
		y0 = bodyBot, -- 856
		y1 = bodyTop, -- 857
		z0 = -12, -- 858
		z1 = 14, -- 859
		material = MING_MATERIALS.mingTimber, -- 860
		bucket = LP_BUCKET.PROP, -- 861
		highlightTopEdge = true, -- 862
		edgeWidth = 1 -- 863
	}) -- 863
	scene:addBox({ -- 866
		x0 = axleX - halfW - 1, -- 867
		x1 = axleX + halfW + 1, -- 868
		y0 = bodyBot + 4, -- 869
		y1 = bodyBot + 8, -- 870
		z0 = -13, -- 871
		z1 = 15, -- 872
		material = MING_MATERIALS.mingIron, -- 873
		bucket = LP_BUCKET.PROP, -- 874
		sortBias = 0.08 -- 875
	}) -- 875
	local handleX = axleX + c.handleOffset -- 878
	scene:addBox({ -- 879
		x0 = axleX + halfW - 2, -- 880
		x1 = handleX, -- 881
		y0 = bodyTop - 6, -- 882
		y1 = bodyTop - 1, -- 883
		z0 = -10, -- 884
		z1 = -4, -- 885
		material = MING_MATERIALS.mingTimber, -- 886
		bucket = LP_BUCKET.PROP, -- 887
		sortBias = 0.12, -- 888
		highlightTopEdge = true -- 889
	}) -- 889
	scene:addBox({ -- 891
		x0 = handleX - 3, -- 892
		x1 = handleX + 3, -- 893
		y0 = bodyTop - 8, -- 894
		y1 = bodyTop + 2, -- 895
		z0 = -11, -- 896
		z1 = 9, -- 897
		material = MING_MATERIALS.mingTimber, -- 898
		bucket = LP_BUCKET.PROP, -- 899
		sortBias = 0.14, -- 900
		highlightTopEdge = true -- 901
	}) -- 901
	local clothX = axleX - halfW -- 905
	local clothTop = bodyTop + 1 -- 906
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 907
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 908
	scene:addTri3D( -- 909
		vec3(clothX - 2, clothTop + 1, -12), -- 910
		vec3(clothX + 11, clothTop, -11), -- 911
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 912
		MING_MATERIALS.mingRedCloth, -- 913
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 914
	) -- 914
	scene:addTri3D( -- 916
		vec3(clothX + 11, clothTop, -11), -- 917
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 918
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 919
		MING_MATERIALS.mingRedCloth, -- 920
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 921
	) -- 921
	scene:flush(fgDraw, fgGlow) -- 924
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 927
	local wheelR = cam:len(c.wheelR) -- 928
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 929
	local wi = 0 -- 930
	do -- 930
		wi = 0 -- 931
		while wi < #wheelXs do -- 931
			local wp = projectWorld3D( -- 932
				wheelXs[wi + 1], -- 932
				axleY, -- 932
				-10, -- 932
				cam, -- 932
				self.outsideProj -- 932
			) -- 932
			fgDraw:drawCircle( -- 933
				Vec2(wp.x, wp.y), -- 933
				wheelR, -- 933
				Color(52, 40, 32, 255) -- 933
			) -- 933
			fgDraw:drawRing( -- 934
				Vec2(wp.x, wp.y), -- 934
				math.max(1, wheelR - 2.6), -- 934
				wheelR, -- 934
				Color(0, 0, 0, 0), -- 934
				1.4, -- 934
				Color(148, 126, 102, 220) -- 934
			) -- 934
			local sp = 0 -- 935
			do -- 935
				sp = 0 -- 936
				while sp < 4 do -- 936
					local a = rollAngle + sp * math.pi / 4 -- 937
					local dx = math.cos(a) * (wheelR - 2) -- 938
					local dy = math.sin(a) * (wheelR - 2) -- 939
					fgDraw:drawSegment( -- 940
						Vec2(wp.x - dx, wp.y - dy), -- 940
						Vec2(wp.x + dx, wp.y + dy), -- 940
						1, -- 940
						Color(118, 92, 70, 210) -- 940
					) -- 940
					sp = sp + 1 -- 936
				end -- 936
			end -- 936
			fgDraw:drawDot( -- 942
				Vec2(wp.x, wp.y), -- 942
				2.4, -- 942
				Color(172, 160, 144, 230) -- 942
			) -- 942
			wi = wi + 1 -- 931
		end -- 931
	end -- 931
	local patchP = projectWorld3D( -- 946
		clothX + 1, -- 946
		clothTop - 7, -- 946
		-13, -- 946
		cam, -- 946
		self.outsideProj -- 946
	) -- 946
	fgDraw:drawSegment( -- 947
		Vec2(patchP.x - 3, patchP.y), -- 947
		Vec2(patchP.x + 3, patchP.y - 2), -- 947
		1, -- 947
		Color(224, 212, 188, 215) -- 947
	) -- 947
	fgDraw:drawSegment( -- 948
		Vec2(patchP.x - 2, patchP.y - 4), -- 948
		Vec2(patchP.x + 2, patchP.y - 5), -- 948
		0.9, -- 948
		Color(224, 212, 188, 195) -- 948
	) -- 948
	return true -- 950
end -- 838
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 953
	if not self.active then -- 959
		return -- 960
	end -- 960
	local key = ctx.p.room.key -- 962
	if key == "village" then -- 963
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 964
	elseif key == "forest" then -- 965
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 966
	end -- 966
end -- 953
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 974
	if not self.active then -- 981
		return false -- 982
	end -- 982
	local key = ctx.p.room.key -- 984
	if key == "village" then -- 985
		return self.village:drawForegroundOverlay( -- 986
			uiDraw, -- 986
			uiInkDraw, -- 986
			uiArt, -- 986
			uiGlow, -- 986
			ctx -- 986
		) -- 986
	end -- 986
	if key == "forest" then -- 988
		return self.forest:drawForegroundOverlay( -- 989
			uiDraw, -- 989
			uiInkDraw, -- 989
			uiArt, -- 989
			uiGlow, -- 989
			ctx -- 989
		) -- 989
	end -- 989
	if key == "outside" then -- 991
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 992
		return false -- 993
	end -- 993
	return false -- 995
end -- 974
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1002
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1008
		return -- 1009
	end -- 1009
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1011
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1013
	if alpha <= 0.01 then -- 1014
		return -- 1015
	end -- 1015
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1017
	local handPt = projectWorld3D( -- 1018
		self.memoryAnchorWorldX, -- 1018
		self.memoryAnchorWorldY, -- 1018
		0, -- 1018
		ctx.cam, -- 1018
		self.outsideProj -- 1018
	) -- 1018
	local cx = math.max( -- 1020
		160, -- 1020
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 1020
	) -- 1020
	local cy = math.max( -- 1021
		150, -- 1021
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 1021
	) -- 1021
	local rx = 122 -- 1022
	local ry = 74 -- 1023
	fillRadialGlow( -- 1026
		uiGlow, -- 1026
		cx, -- 1026
		cy, -- 1026
		rx * 1.55, -- 1026
		ry * 1.55, -- 1026
		Color( -- 1026
			238, -- 1026
			190, -- 1026
			122, -- 1026
			math.floor(92 * alpha + 0.5) -- 1026
		), -- 1026
		Color(218, 162, 92, 0), -- 1026
		22 -- 1026
	) -- 1026
	uiDraw:drawEllipse( -- 1027
		Vec2(cx, cy), -- 1027
		rx * 1.12, -- 1027
		ry * 1.12, -- 1027
		Color( -- 1027
			36, -- 1027
			26, -- 1027
			20, -- 1027
			math.floor(128 * alpha + 0.5) -- 1027
		) -- 1027
	) -- 1027
	uiDraw:drawEllipse( -- 1028
		Vec2(cx, cy), -- 1028
		rx * 0.96, -- 1028
		ry * 0.96, -- 1028
		Color( -- 1028
			32, -- 1028
			22, -- 1028
			16, -- 1028
			math.floor(206 * alpha + 0.5) -- 1028
		) -- 1028
	) -- 1028
	uiDraw:drawPolygon( -- 1031
		{ -- 1031
			Vec2(cx - 72, cy - 34), -- 1032
			Vec2(cx + 62, cy - 28), -- 1033
			Vec2(cx + 70, cy + 32), -- 1034
			Vec2(cx - 64, cy + 28) -- 1035
		}, -- 1035
		Color( -- 1036
			148, -- 1036
			44, -- 1036
			40, -- 1036
			math.floor(230 * alpha + 0.5) -- 1036
		) -- 1036
	) -- 1036
	uiDraw:drawPolygon( -- 1037
		{ -- 1037
			Vec2(cx - 28, cy - 18), -- 1038
			Vec2(cx + 26, cy - 14), -- 1039
			Vec2(cx + 22, cy + 20), -- 1040
			Vec2(cx - 24, cy + 16) -- 1041
		}, -- 1041
		Color( -- 1042
			172, -- 1042
			62, -- 1042
			54, -- 1042
			math.floor(238 * alpha + 0.5) -- 1042
		), -- 1042
		1, -- 1042
		Color( -- 1042
			224, -- 1042
			210, -- 1042
			184, -- 1042
			math.floor(170 * alpha + 0.5) -- 1042
		) -- 1042
	) -- 1042
	local si = 0 -- 1045
	do -- 1045
		si = 0 -- 1046
		while si < 4 do -- 1046
			local sx = cx - 18 + si * 11 -- 1047
			uiInkDraw:drawSegment( -- 1048
				Vec2(sx, cy - 15), -- 1048
				Vec2(sx + 4, cy - 9), -- 1048
				1.3, -- 1048
				Color( -- 1048
					236, -- 1048
					224, -- 1048
					198, -- 1048
					math.floor(235 * alpha + 0.5) -- 1048
				) -- 1048
			) -- 1048
			si = si + 1 -- 1046
		end -- 1046
	end -- 1046
	local pullT = smoothstep(0.14, 0.82, prog) -- 1052
	local stitchAnchorX = cx + 22 -- 1053
	local stitchAnchorY = cy - 12 -- 1054
	local handX = cx + 32 + pullT * 34 -- 1055
	local handY = cy + 6 + pullT * 26 -- 1056
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1059
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1060
	uiInkDraw:drawSegment( -- 1061
		Vec2(stitchAnchorX, stitchAnchorY), -- 1061
		Vec2(midX, midY), -- 1061
		1.2, -- 1061
		Color( -- 1061
			242, -- 1061
			234, -- 1061
			214, -- 1061
			math.floor(240 * alpha + 0.5) -- 1061
		) -- 1061
	) -- 1061
	uiInkDraw:drawSegment( -- 1062
		Vec2(midX, midY), -- 1062
		Vec2(handX - 6, handY - 2), -- 1062
		1.2, -- 1062
		Color( -- 1062
			242, -- 1062
			234, -- 1062
			214, -- 1062
			math.floor(240 * alpha + 0.5) -- 1062
		) -- 1062
	) -- 1062
	uiInkDraw:drawSegment( -- 1065
		Vec2(handX - 16, handY - 8), -- 1065
		Vec2(handX + 2, handY + 4), -- 1065
		1.1, -- 1065
		Color( -- 1065
			230, -- 1065
			236, -- 1065
			242, -- 1065
			math.floor(225 * alpha + 0.5) -- 1065
		) -- 1065
	) -- 1065
	uiDraw:drawPolygon( -- 1068
		{ -- 1068
			Vec2(handX - 8, handY - 6), -- 1069
			Vec2(handX + 18, handY + 2), -- 1070
			Vec2(handX + 24, handY + 14), -- 1071
			Vec2(handX + 4, handY + 14), -- 1072
			Vec2(handX - 10, handY + 4) -- 1073
		}, -- 1073
		Color( -- 1074
			214, -- 1074
			174, -- 1074
			142, -- 1074
			math.floor(225 * alpha + 0.5) -- 1074
		), -- 1074
		1, -- 1074
		Color( -- 1074
			142, -- 1074
			102, -- 1074
			78, -- 1074
			math.floor(180 * alpha + 0.5) -- 1074
		) -- 1074
	) -- 1074
	uiDraw:drawEllipse( -- 1076
		Vec2(cx - 20, cy + 4), -- 1076
		16, -- 1076
		9, -- 1076
		Color( -- 1076
			204, -- 1076
			164, -- 1076
			134, -- 1076
			math.floor(220 * alpha + 0.5) -- 1076
		) -- 1076
	) -- 1076
end -- 1002
function ____exports.createLowpolyWorldPlugin() -- 1080
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1081
end -- 1080
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1085
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1088
	fe:registerPlugin(lowpolyWorld) -- 1089
	return {lowpolyWorld = lowpolyWorld} -- 1090
end -- 1085
return ____exports -- 1085
