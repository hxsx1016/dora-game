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
		return self:drawOutsideBackdrop(bgDraw, bgGlow, ctx) -- 354
	end -- 354
	if key == "tower" then -- 356
		return self:drawTowerBackdrop(bgDraw, bgGlow, ctx) -- 357
	end -- 357
	return false -- 359
end -- 337
function LowpolyWorldPlugin.prototype.drawOutsideBackdrop(self, bgDraw, bgGlow, ctx) -- 362
	local p = ctx.p -- 363
	local cam = ctx.cam -- 364
	local w = cam.viewW -- 365
	local h = cam.viewH -- 366
	local ox = p.ox -- 367
	local splitY = h * 0.48 -- 370
	fillVGradRect( -- 371
		bgDraw, -- 371
		0, -- 371
		splitY, -- 371
		w, -- 371
		h - splitY, -- 371
		Color(16, 25, 38, 255), -- 371
		Color(8, 13, 22, 255) -- 371
	) -- 371
	fillVGradRect( -- 372
		bgDraw, -- 372
		0, -- 372
		0, -- 372
		w, -- 372
		splitY, -- 372
		Color(30, 44, 62, 255), -- 372
		Color(16, 25, 38, 255) -- 372
	) -- 372
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 374
	scene:addBox({ -- 376
		x0 = ox - 160, -- 377
		x1 = ox + 1360, -- 378
		y0 = -48, -- 379
		y1 = 112, -- 380
		z0 = 230, -- 381
		z1 = 274, -- 382
		material = MING_MATERIALS.distantWall, -- 383
		bucket = LP_BUCKET.BACKDROP, -- 384
		edgeWidth = 0 -- 385
	}) -- 385
	local mx = ox - 80 -- 387
	local mi = 0 -- 388
	do -- 388
		mi = 0 -- 389
		while mi < 18 do -- 389
			scene:addBox({ -- 390
				x0 = mx, -- 391
				x1 = mx + 32, -- 392
				y0 = 112, -- 393
				y1 = 128, -- 394
				z0 = 230, -- 395
				z1 = 256, -- 396
				material = MING_MATERIALS.distantWall, -- 397
				bucket = LP_BUCKET.BACKDROP, -- 398
				sortBias = 0.04, -- 399
				edgeWidth = 0 -- 400
			}) -- 400
			mx = mx + 78 -- 402
			mi = mi + 1 -- 389
		end -- 389
	end -- 389
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
	local moonX = w * 0.76 -- 410
	local moonY = h * 0.83 -- 411
	fillRadialGlow( -- 412
		bgGlow, -- 412
		moonX, -- 412
		moonY, -- 412
		82, -- 412
		82, -- 412
		Color(172, 206, 232, 28), -- 412
		Color(24, 42, 68, 0), -- 412
		16 -- 412
	) -- 412
	bgDraw:drawCircle( -- 413
		Vec2(moonX, moonY), -- 413
		14, -- 413
		Color(218, 232, 246, 165) -- 413
	) -- 413
	local beaconP = projectWorld3D( -- 415
		ox + 1140, -- 415
		154, -- 415
		410, -- 415
		cam, -- 415
		self.outsideProj -- 415
	) -- 415
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 416
	fillRadialGlow( -- 417
		bgGlow, -- 417
		beaconP.x, -- 417
		beaconP.y, -- 417
		32 * pulse, -- 417
		32 * pulse, -- 417
		Color( -- 417
			246, -- 417
			208, -- 417
			138, -- 417
			math.floor(92 * pulse + 0.5) -- 417
		), -- 417
		Color(232, 176, 86, 0), -- 417
		14 -- 417
	) -- 417
	bgGlow:drawDot( -- 418
		Vec2(beaconP.x, beaconP.y), -- 418
		2.5, -- 418
		Color(255, 244, 212, 235) -- 418
	) -- 418
	return true -- 420
end -- 362
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, ctx) -- 423
	local cam = ctx.cam -- 424
	local p = ctx.p -- 425
	local ox = p.ox -- 426
	local w = cam.viewW -- 427
	local h = cam.viewH -- 428
	local splitY = h * 0.46 -- 431
	fillVGradRect( -- 432
		bgDraw, -- 432
		0, -- 432
		splitY, -- 432
		w, -- 432
		h - splitY, -- 432
		Color(24, 34, 52, 255), -- 432
		Color(12, 18, 30, 255) -- 432
	) -- 432
	fillVGradRect( -- 433
		bgDraw, -- 433
		0, -- 433
		0, -- 433
		w, -- 433
		splitY, -- 433
		Color(46, 54, 70, 255), -- 433
		Color(24, 34, 52, 255) -- 433
	) -- 433
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 435
	scene:addDistantRidge( -- 436
		{ -- 437
			{x = ox - 180, y = 118}, -- 438
			{x = ox + 90, y = 172}, -- 439
			{x = ox + 360, y = 146}, -- 440
			{x = ox + 640, y = 184}, -- 441
			{x = ox + 920, y = 132} -- 442
		}, -- 442
		-40, -- 444
		420, -- 445
		MING_MATERIALS.distantHill, -- 446
		{bucket = LP_BUCKET.BACKDROP} -- 447
	) -- 447
	scene:addFogBand( -- 449
		ox - 160, -- 449
		ox + 900, -- 449
		-24, -- 449
		150, -- 449
		260, -- 449
		rgba(36, 42, 58, 255), -- 449
		0.56, -- 449
		0.06, -- 449
		{bucket = LP_BUCKET.BACKDROP} -- 449
	) -- 449
	scene:flush(bgDraw, bgGlow) -- 452
	return true -- 454
end -- 423
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 457
	if not self.active then -- 463
		return false -- 464
	end -- 464
	local key = ctx.p.room.key -- 466
	if key == "village" then -- 467
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 468
	end -- 468
	if key == "forest" then -- 470
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 471
	end -- 471
	if key == "outside" then -- 473
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 474
	end -- 474
	if key == "tower" then -- 476
		return self:drawTowerWorld(fgDraw, fgGlow, ctx) -- 477
	end -- 477
	return false -- 479
end -- 457
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, ctx) -- 482
	local p = ctx.p -- 483
	local cam = ctx.cam -- 484
	local ox = p.ox -- 485
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 486
	buildOutsideJettyLowpoly( -- 489
		scene, -- 489
		p.room, -- 489
		p.player.x, -- 489
		p.player.y, -- 489
		p.cartAxle, -- 489
		self.animTime -- 489
	) -- 489
	local redBox = __TS__ArrayFind( -- 492
		p.boxes, -- 492
		function(____, b) return b.id == "outside_red_cart" end -- 492
	) -- 492
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 493
		scene:addBox({ -- 494
			x0 = redBox.x0 + 2, -- 495
			x1 = redBox.x1 - 2, -- 496
			y0 = redBox.y0 + 10, -- 497
			y1 = redBox.y1, -- 498
			z0 = -10, -- 499
			z1 = 12, -- 500
			material = MING_MATERIALS.mingTimber, -- 501
			bucket = LP_BUCKET.PROP, -- 502
			highlightTopEdge = true, -- 503
			edgeWidth = 0.9 -- 504
		}) -- 504
		local rSway = math.sin(self.animTime * 2.9) * 4.5 -- 507
		scene:addTri3D( -- 508
			vec3(redBox.x0 + 4, redBox.y1, -11), -- 509
			vec3(redBox.x0 + 18, redBox.y1, -10), -- 510
			vec3(redBox.x0 - 2 + rSway, redBox.y0 + 10, -12), -- 511
			MING_MATERIALS.mingRedCloth, -- 512
			{bucket = LP_BUCKET.PROP, sortBias = 0.26, edgeWidth = 0.8} -- 513
		) -- 513
	end -- 513
	local c = p.room.cart -- 518
	if c.bodyW > 0 then -- 519
		scene:addBox({ -- 521
			x0 = c.endX - 18, -- 522
			x1 = c.endX + 18, -- 523
			y0 = c.baseY - 4, -- 524
			y1 = c.baseY + 2, -- 525
			z0 = -12, -- 526
			z1 = 14, -- 527
			material = MING_MATERIALS.mingIron, -- 528
			bucket = LP_BUCKET.WALK_DECK, -- 529
			sortBias = 0.35, -- 530
			highlightTopEdge = true -- 531
		}) -- 531
		scene:addBox({ -- 534
			x0 = ox + 258, -- 535
			x1 = ox + 474, -- 536
			y0 = c.baseY - 1.5, -- 537
			y1 = c.baseY + 0.4, -- 538
			z0 = -11, -- 539
			z1 = -7, -- 540
			material = MING_MATERIALS.mingTimberDark, -- 541
			bucket = LP_BUCKET.WALK_DECK, -- 542
			sortBias = 0.3, -- 543
			edgeWidth = 0 -- 544
		}) -- 544
		scene:addBox({ -- 546
			x0 = ox + 258, -- 547
			x1 = ox + 474, -- 548
			y0 = c.baseY - 1.5, -- 549
			y1 = c.baseY + 0.4, -- 550
			z0 = 7, -- 551
			z1 = 11, -- 552
			material = MING_MATERIALS.mingTimberDark, -- 553
			bucket = LP_BUCKET.WALK_DECK, -- 554
			sortBias = 0.3, -- 555
			edgeWidth = 0 -- 556
		}) -- 556
	end -- 556
	if not p.cartDocked and p.room.arch.h > 0 then -- 562
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 563
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 564
		if bx1 > bx0 + 4 then -- 565
			scene:addBox({ -- 566
				x0 = bx0, -- 567
				x1 = bx1, -- 568
				y0 = 2, -- 569
				y1 = p.room.arch.h, -- 570
				z0 = -6, -- 571
				z1 = 8, -- 572
				material = MING_MATERIALS.mingTimberDark, -- 573
				bucket = LP_BUCKET.PROP, -- 574
				highlightTopEdge = true, -- 575
				edgeWidth = 0.9 -- 576
			}) -- 576
			scene:addBox({ -- 579
				x0 = (bx0 + bx1) * 0.5 - 3, -- 580
				x1 = (bx0 + bx1) * 0.5 + 3, -- 581
				y0 = p.room.arch.h, -- 582
				y1 = p.room.cart.baseY, -- 583
				z0 = -3, -- 584
				z1 = 5, -- 585
				material = MING_MATERIALS.mingIron, -- 586
				bucket = LP_BUCKET.PROP, -- 587
				edgeWidth = 0.6 -- 588
			}) -- 588
		end -- 588
	end -- 588
	scene:addBox({ -- 594
		x0 = ox + 128, -- 595
		x1 = ox + 598, -- 596
		y0 = 0, -- 597
		y1 = 92, -- 598
		z0 = 44, -- 599
		z1 = 72, -- 600
		material = MING_MATERIALS.mingBrickDark, -- 601
		bucket = LP_BUCKET.MIDGROUND, -- 602
		sortBias = -0.2, -- 603
		edgeWidth = 0.5 -- 604
	}) -- 604
	scene:addQuad3D( -- 607
		vec3(ox + 132, 26, 43), -- 608
		vec3(ox + 592, 26, 43), -- 609
		vec3(ox + 592, 31, 43), -- 610
		vec3(ox + 132, 31, 43), -- 611
		{base = rgba(138, 148, 158, 92)}, -- 612
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 613
	) -- 613
	scene:addLightShaft( -- 617
		ox + 1110, -- 618
		ox + 1180, -- 618
		170, -- 618
		ox + 1040, -- 619
		ox + 1140, -- 619
		0, -- 619
		34, -- 620
		rgba(234, 198, 138, 255), -- 621
		0.14, -- 622
		0.03 -- 623
	) -- 623
	scene:flush(fgDraw, fgGlow) -- 626
	local gi = 0 -- 629
	do -- 629
		gi = 0 -- 630
		while gi < 6 do -- 630
			local gx = ox + 165 + gi * 56 -- 631
			local p0 = projectWorld3D( -- 632
				gx, -- 632
				0.5, -- 632
				-14, -- 632
				cam, -- 632
				self.outsideProj -- 632
			) -- 632
			local p1 = projectWorld3D( -- 633
				gx + 10, -- 633
				0.5, -- 633
				22, -- 633
				cam, -- 633
				self.outsideProj -- 633
			) -- 633
			fgDraw:drawSegment( -- 634
				Vec2(p0.x, p0.y), -- 634
				Vec2(p1.x, p1.y), -- 634
				3, -- 634
				Color(8, 12, 18, 76) -- 634
			) -- 634
			gi = gi + 1 -- 630
		end -- 630
	end -- 630
	local row = 0 -- 638
	do -- 638
		row = 1 -- 639
		while row <= 6 do -- 639
			local wy = 96 + row * 19 -- 640
			local bL = projectWorld3D( -- 641
				ox + 513, -- 641
				wy, -- 641
				-8, -- 641
				cam, -- 641
				self.outsideProj -- 641
			) -- 641
			local bR = projectWorld3D( -- 642
				ox + 599, -- 642
				wy, -- 642
				-8, -- 642
				cam, -- 642
				self.outsideProj -- 642
			) -- 642
			fgDraw:drawSegment( -- 643
				Vec2(bL.x, bL.y), -- 643
				Vec2(bR.x, bR.y), -- 643
				0.9, -- 643
				Color(34, 40, 50, 185) -- 643
			) -- 643
			local off = row % 2 * 18 -- 644
			local colX = ox + 528 + off -- 645
			while colX < ox + 594 do -- 646
				local v0 = projectWorld3D( -- 647
					colX, -- 647
					wy - 19, -- 647
					-8, -- 647
					cam, -- 647
					self.outsideProj -- 647
				) -- 647
				local v1 = projectWorld3D( -- 648
					colX, -- 648
					wy, -- 648
					-8, -- 648
					cam, -- 648
					self.outsideProj -- 648
				) -- 648
				fgDraw:drawSegment( -- 649
					Vec2(v0.x, v0.y), -- 649
					Vec2(v1.x, v1.y), -- 649
					0.8, -- 649
					Color(32, 38, 48, 150) -- 649
				) -- 649
				colX = colX + 34 -- 650
			end -- 650
			row = row + 1 -- 639
		end -- 639
	end -- 639
	return true -- 654
end -- 482
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 657
	local p = ctx.p -- 658
	local cam = ctx.cam -- 659
	local ox = p.ox -- 660
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 661
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 666
	scene:addBox({ -- 669
		x0 = ox - 40, -- 670
		x1 = ox + 760, -- 671
		y0 = -52, -- 672
		y1 = 0, -- 673
		z0 = -26, -- 674
		z1 = 96, -- 675
		material = MING_MATERIALS.mingBrickDark, -- 676
		bucket = LP_BUCKET.WALK_DECK, -- 677
		highlightTopEdge = true -- 678
	}) -- 678
	scene:addBox({ -- 681
		x0 = ox + 398, -- 682
		x1 = ox + 492, -- 683
		y0 = -4, -- 684
		y1 = 2.5, -- 685
		z0 = -16, -- 686
		z1 = 26, -- 687
		material = MING_MATERIALS.mingStoneStep, -- 688
		bucket = LP_BUCKET.WALK_DECK, -- 689
		sortBias = 0.15, -- 690
		highlightTopEdge = true -- 691
	}) -- 691
	scene:addBox({ -- 695
		x0 = ox + 180, -- 696
		x1 = ox + 400, -- 697
		y0 = 0, -- 698
		y1 = 215, -- 699
		z0 = -8, -- 700
		z1 = 96, -- 701
		material = MING_MATERIALS.mingBrick, -- 702
		bucket = LP_BUCKET.MIDGROUND, -- 703
		highlightTopEdge = true -- 704
	}) -- 704
	if not opened then -- 706
		scene:addBox({ -- 707
			x0 = ox + 490, -- 708
			x1 = ox + 720, -- 709
			y0 = 0, -- 710
			y1 = 215, -- 711
			z0 = -8, -- 712
			z1 = 96, -- 713
			material = MING_MATERIALS.mingBrick, -- 714
			bucket = LP_BUCKET.MIDGROUND, -- 715
			highlightTopEdge = true -- 716
		}) -- 716
	else -- 716
		scene:addBox({ -- 720
			x0 = ox + 490, -- 721
			x1 = ox + 706, -- 722
			y0 = 0, -- 723
			y1 = 146, -- 724
			z0 = 46, -- 725
			z1 = 96, -- 726
			material = MING_MATERIALS.mingTimberDark, -- 727
			bucket = LP_BUCKET.BACKDROP, -- 728
			edgeWidth = 0.8 -- 729
		}) -- 729
		scene:addBox({ -- 731
			x0 = ox + 490, -- 732
			x1 = ox + 706, -- 733
			y0 = -3, -- 734
			y1 = 2, -- 735
			z0 = -18, -- 736
			z1 = 48, -- 737
			material = MING_MATERIALS.mingTimber, -- 738
			bucket = LP_BUCKET.WALK_DECK, -- 739
			sortBias = 0.12, -- 740
			highlightTopEdge = true -- 741
		}) -- 741
		scene:addBox({ -- 744
			x0 = ox + 490, -- 745
			x1 = ox + 720, -- 746
			y0 = 144, -- 747
			y1 = 215, -- 748
			z0 = -8, -- 749
			z1 = 96, -- 750
			material = MING_MATERIALS.mingBrick, -- 751
			bucket = LP_BUCKET.MIDGROUND, -- 752
			highlightTopEdge = true -- 753
		}) -- 753
		scene:addBox({ -- 755
			x0 = ox + 490, -- 756
			x1 = ox + 704, -- 757
			y0 = 132, -- 758
			y1 = 145, -- 759
			z0 = -4, -- 760
			z1 = 48, -- 761
			material = MING_MATERIALS.mingTimberDark, -- 762
			bucket = LP_BUCKET.MIDGROUND, -- 763
			sortBias = 0.08 -- 764
		}) -- 764
		scene:addBox({ -- 767
			x0 = ox + 702, -- 768
			x1 = ox + 724, -- 769
			y0 = 0, -- 770
			y1 = 146, -- 771
			z0 = -8, -- 772
			z1 = 96, -- 773
			material = MING_MATERIALS.mingBrickDark, -- 774
			bucket = LP_BUCKET.MIDGROUND, -- 775
			highlightTopEdge = true -- 776
		}) -- 776
		scene:addQuad3D( -- 779
			vec3(ox + 544, 52, 45), -- 780
			vec3(ox + 662, 52, 45), -- 781
			vec3(ox + 662, 118, 45), -- 782
			vec3(ox + 544, 118, 45), -- 783
			{base = rgba(88, 62, 38, 255)}, -- 784
			{ -- 785
				bucket = LP_BUCKET.BACKDROP, -- 785
				unlit = true, -- 785
				sortBias = 0.12, -- 785
				edgeColor = rgba(132, 98, 62, 210), -- 785
				edgeWidth = 1 -- 785
			} -- 785
		) -- 785
		scene:addBox({ -- 788
			x0 = ox + 564, -- 789
			x1 = ox + 646, -- 790
			y0 = 28, -- 791
			y1 = 35, -- 792
			z0 = 10, -- 793
			z1 = 36, -- 794
			material = MING_MATERIALS.mingTimber, -- 795
			bucket = LP_BUCKET.PROP, -- 796
			sortBias = 0.12, -- 797
			highlightTopEdge = true -- 798
		}) -- 798
		scene:addBox({ -- 800
			x0 = ox + 568, -- 801
			x1 = ox + 576, -- 802
			y0 = 0, -- 803
			y1 = 28, -- 804
			z0 = 12, -- 805
			z1 = 32, -- 806
			material = MING_MATERIALS.mingTimberDark, -- 807
			bucket = LP_BUCKET.PROP, -- 808
			sortBias = 0.06 -- 809
		}) -- 809
		scene:addBox({ -- 811
			x0 = ox + 634, -- 812
			x1 = ox + 642, -- 813
			y0 = 0, -- 814
			y1 = 28, -- 815
			z0 = 12, -- 816
			z1 = 32, -- 817
			material = MING_MATERIALS.mingTimberDark, -- 818
			bucket = LP_BUCKET.PROP, -- 819
			sortBias = 0.06 -- 820
		}) -- 820
	end -- 820
	scene:addBeveledFrame( -- 825
		ox + 400, -- 825
		ox + 490, -- 825
		0, -- 825
		110, -- 825
		14, -- 825
		34, -- 825
		-8, -- 825
		68, -- 825
		MING_MATERIALS.mingStoneStep, -- 825
		{ -- 825
			bucket = LP_BUCKET.MIDGROUND, -- 826
			innerRimLight = rgba(244, 206, 140, 255), -- 827
			innerRimStrength = opened and 0.78 or 0.32 -- 828
		} -- 828
	) -- 828
	if not opened then -- 832
		scene:addBox({ -- 833
			x0 = ox + 404, -- 834
			x1 = ox + 486, -- 835
			y0 = 4, -- 836
			y1 = 109, -- 837
			z0 = 14, -- 838
			z1 = 26, -- 839
			material = MING_MATERIALS.mingTimberDark, -- 840
			bucket = LP_BUCKET.MIDGROUND, -- 841
			sortBias = 0.1, -- 842
			edgeWidth = 0.9 -- 843
		}) -- 843
	else -- 843
		scene:addQuad3D( -- 846
			vec3(ox + 404, 2, 24), -- 847
			vec3(ox + 486, 2, 24), -- 848
			vec3(ox + 486, 109, 24), -- 849
			vec3(ox + 404, 109, 24), -- 850
			{base = rgba(112, 78, 42, 255)}, -- 851
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 852
		) -- 852
	end -- 852
	scene:addQuad3D( -- 857
		vec3(ox + 286, 118, -9), -- 858
		vec3(ox + 306, 118, -9), -- 859
		vec3(ox + 306, 158, -9), -- 860
		vec3(ox + 286, 158, -9), -- 861
		{base = rgba(244, 204, 134, 255)}, -- 862
		{ -- 863
			bucket = LP_BUCKET.PROP, -- 863
			unlit = true, -- 863
			edgeColor = rgba(82, 68, 52, 255), -- 863
			edgeWidth = 1.4 -- 863
		} -- 863
	) -- 863
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 867
	scene:addLightShaft( -- 868
		ox + 412, -- 869
		ox + 478, -- 869
		106, -- 869
		ox + 382, -- 870
		ox + 506, -- 870
		0, -- 870
		6, -- 871
		rgba(246, 208, 138, 255), -- 872
		(opened and 0.34 or 0.08) * pulse, -- 873
		(opened and 0.16 or 0.04) * pulse -- 874
	) -- 874
	scene:addContactShadow( -- 878
		p.player.x, -- 878
		p.player.y, -- 878
		15, -- 878
		11, -- 878
		0.78, -- 878
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 878
	) -- 878
	scene:flush(fgDraw, fgGlow) -- 880
	local lampP = projectWorld3D( -- 883
		ox + 445, -- 883
		102, -- 883
		2, -- 883
		cam, -- 883
		self.towerProj -- 883
	) -- 883
	fillRadialGlow( -- 884
		fgGlow, -- 885
		lampP.x, -- 886
		lampP.y, -- 887
		cam:len(opened and 64 or 34) * pulse, -- 888
		cam:len(opened and 64 or 34) * pulse, -- 889
		Color( -- 890
			248, -- 890
			214, -- 890
			146, -- 890
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 890
		), -- 890
		Color(232, 174, 82, 0), -- 891
		16 -- 892
	) -- 892
	fgDraw:drawCircle( -- 894
		Vec2(lampP.x, lampP.y), -- 894
		4.2, -- 894
		Color(255, 240, 202, 245) -- 894
	) -- 894
	local winP = projectWorld3D( -- 896
		ox + 296, -- 896
		138, -- 896
		-9, -- 896
		cam, -- 896
		self.towerProj -- 896
	) -- 896
	fillRadialGlow( -- 897
		fgGlow, -- 897
		winP.x, -- 897
		winP.y, -- 897
		cam:len(38), -- 897
		cam:len(42), -- 897
		Color( -- 897
			246, -- 897
			206, -- 897
			132, -- 897
			math.floor(78 * pulse + 0.5) -- 897
		), -- 897
		Color(232, 174, 82, 0), -- 897
		14 -- 897
	) -- 897
	local wBL = projectWorld3D( -- 899
		ox + 286, -- 899
		118, -- 899
		-9, -- 899
		cam, -- 899
		self.towerProj -- 899
	) -- 899
	local wTR = projectWorld3D( -- 900
		ox + 306, -- 900
		158, -- 900
		-9, -- 900
		cam, -- 900
		self.towerProj -- 900
	) -- 900
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 901
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 902
	fgDraw:drawSegment( -- 903
		Vec2(wMidX, wBL.y), -- 903
		Vec2(wMidX, wTR.y), -- 903
		1.4, -- 903
		Color(68, 52, 38, 225) -- 903
	) -- 903
	fgDraw:drawSegment( -- 904
		Vec2(wBL.x, wMidY), -- 904
		Vec2(wTR.x, wMidY), -- 904
		1.4, -- 904
		Color(68, 52, 38, 225) -- 904
	) -- 904
	local tr = 1 -- 905
	do -- 905
		tr = 1 -- 906
		while tr <= 6 do -- 906
			local ty = tr * 30 -- 907
			local tl0 = projectWorld3D( -- 908
				ox + 182, -- 908
				ty, -- 908
				-8, -- 908
				cam, -- 908
				self.towerProj -- 908
			) -- 908
			local tl1 = projectWorld3D( -- 909
				ox + 398, -- 909
				ty, -- 909
				-8, -- 909
				cam, -- 909
				self.towerProj -- 909
			) -- 909
			fgDraw:drawSegment( -- 910
				Vec2(tl0.x, tl0.y), -- 910
				Vec2(tl1.x, tl1.y), -- 910
				0.8, -- 910
				Color(34, 38, 48, 135) -- 910
			) -- 910
			if not opened or ty >= 150 then -- 911
				local tr0 = projectWorld3D( -- 912
					ox + 492, -- 912
					ty, -- 912
					-8, -- 912
					cam, -- 912
					self.towerProj -- 912
				) -- 912
				local tr1 = projectWorld3D( -- 913
					ox + 718, -- 913
					ty, -- 913
					-8, -- 913
					cam, -- 913
					self.towerProj -- 913
				) -- 913
				fgDraw:drawSegment( -- 914
					Vec2(tr0.x, tr0.y), -- 914
					Vec2(tr1.x, tr1.y), -- 914
					0.8, -- 914
					Color(34, 38, 48, 135) -- 914
				) -- 914
			end -- 914
			tr = tr + 1 -- 906
		end -- 906
	end -- 906
	return true -- 918
end -- 657
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 921
	if not self.active then -- 927
		return false -- 928
	end -- 928
	local key = ctx.p.room.key -- 930
	if key == "village" then -- 931
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 932
	end -- 932
	if key == "forest" then -- 934
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 935
	end -- 935
	if key == "outside" then -- 937
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 938
	end -- 938
	if key == "tower" then -- 940
		local p = ctx.p -- 941
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 942
		if opened then -- 943
			local cam = ctx.cam -- 944
			local deskTopP = projectWorld3D( -- 945
				p.ox + 605, -- 945
				35, -- 945
				22, -- 945
				cam, -- 945
				self.towerProj -- 945
			) -- 945
			local guardBaseP = projectWorld3D( -- 946
				p.ox + 626, -- 946
				0, -- 946
				38, -- 946
				cam, -- 946
				self.towerProj -- 946
			) -- 946
			local deskCx = deskTopP.x -- 947
			local deskTop = deskTopP.y -- 948
			local s = deskTopP.scale -- 949
			local gs = guardBaseP.scale -- 950
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 951
			fillRadialGlow( -- 952
				fgGlow, -- 952
				deskCx, -- 952
				deskTop + cam:len(26) * s, -- 952
				cam:len(132) * s, -- 952
				cam:len(96) * s, -- 952
				Color( -- 953
					255, -- 953
					198, -- 953
					114, -- 953
					math.floor(82 * pulse + 0.5) -- 953
				), -- 953
				Color(255, 168, 72, 0), -- 953
				16 -- 953
			) -- 953
			fgDraw:drawRect( -- 955
				Rect( -- 955
					guardBaseP.x - cam:len(11) * gs, -- 955
					guardBaseP.y, -- 955
					cam:len(22) * gs, -- 955
					cam:len(68) * gs -- 955
				), -- 955
				Color(28, 34, 44, 242) -- 955
			) -- 955
			fgDraw:drawCircle( -- 956
				Vec2( -- 956
					guardBaseP.x, -- 956
					guardBaseP.y + cam:len(76) * gs -- 956
				), -- 956
				cam:len(9.5) * gs, -- 956
				Color(36, 44, 56, 248) -- 956
			) -- 956
			fgDraw:drawRect( -- 958
				Rect( -- 958
					deskCx + cam:len(4) * s, -- 958
					deskTop + cam:len(1) * s, -- 958
					cam:len(24) * s, -- 958
					cam:len(5) * s -- 958
				), -- 958
				Color(230, 220, 196, 245) -- 958
			) -- 958
			fgDraw:drawRect( -- 959
				Rect( -- 959
					deskCx + cam:len(30) * s, -- 959
					deskTop + cam:len(1) * s, -- 959
					cam:len(8) * s, -- 959
					cam:len(12) * s -- 959
				), -- 959
				Color(166, 126, 62, 245) -- 959
			) -- 959
			fgGlow:drawCircle( -- 960
				Vec2( -- 960
					deskCx + cam:len(34) * s, -- 960
					deskTop + cam:len(15) * s -- 960
				), -- 960
				cam:len(5.5) * s, -- 960
				Color( -- 960
					255, -- 960
					224, -- 960
					152, -- 960
					math.floor(220 * pulse + 0.5) -- 960
				) -- 960
			) -- 960
			if p.deskHold >= 12 or p.towerHanded then -- 961
				fgDraw:drawRect( -- 962
					Rect( -- 962
						deskCx - cam:len(26) * s, -- 962
						deskTop + cam:len(1) * s, -- 962
						cam:len(14) * s, -- 962
						cam:len(6) * s -- 962
					), -- 962
					Color(156, 62, 48, 245) -- 962
				) -- 962
			end -- 962
			if p.deskHold >= 24 or p.towerHanded then -- 964
				fgDraw:drawCircle( -- 965
					Vec2( -- 965
						deskCx - cam:len(7) * s, -- 965
						deskTop + cam:len(4) * s -- 965
					), -- 965
					cam:len(4.5) * s, -- 965
					Color(224, 186, 98, 255) -- 965
				) -- 965
				fgDraw:drawRect( -- 966
					Rect( -- 966
						deskCx - cam:len(15) * s, -- 966
						deskTop + cam:len(1) * s, -- 966
						cam:len(10) * s, -- 966
						cam:len(3) * s -- 966
					), -- 966
					Color(236, 228, 206, 240) -- 966
				) -- 966
			end -- 966
		end -- 966
		return true -- 969
	end -- 969
	return false -- 971
end -- 921
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 975
	local p = ctx.p -- 976
	local cam = ctx.cam -- 977
	local c = p.room.cart -- 978
	if c.bodyW <= 0 then -- 979
		return true -- 980
	end -- 980
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 982
	local halfW = c.bodyW * 0.5 -- 983
	local axleX = p.cartAxle -- 984
	local axleY = c.baseY + c.wheelR -- 985
	local bodyBot = axleY + 2 -- 986
	local bodyTop = bodyBot + c.bodyH -- 987
	scene:addBox({ -- 990
		x0 = axleX - halfW, -- 991
		x1 = axleX + halfW, -- 992
		y0 = bodyBot, -- 993
		y1 = bodyTop, -- 994
		z0 = -12, -- 995
		z1 = 14, -- 996
		material = MING_MATERIALS.mingTimber, -- 997
		bucket = LP_BUCKET.PROP, -- 998
		highlightTopEdge = true, -- 999
		edgeWidth = 1 -- 1000
	}) -- 1000
	scene:addBox({ -- 1003
		x0 = axleX - halfW - 1, -- 1004
		x1 = axleX + halfW + 1, -- 1005
		y0 = bodyBot + 4, -- 1006
		y1 = bodyBot + 8, -- 1007
		z0 = -13, -- 1008
		z1 = 15, -- 1009
		material = MING_MATERIALS.mingIron, -- 1010
		bucket = LP_BUCKET.PROP, -- 1011
		sortBias = 0.08 -- 1012
	}) -- 1012
	local handleX = axleX + c.handleOffset -- 1015
	scene:addBox({ -- 1016
		x0 = axleX + halfW - 2, -- 1017
		x1 = handleX, -- 1018
		y0 = bodyTop - 6, -- 1019
		y1 = bodyTop - 1, -- 1020
		z0 = -10, -- 1021
		z1 = -4, -- 1022
		material = MING_MATERIALS.mingTimber, -- 1023
		bucket = LP_BUCKET.PROP, -- 1024
		sortBias = 0.12, -- 1025
		highlightTopEdge = true -- 1026
	}) -- 1026
	scene:addBox({ -- 1028
		x0 = handleX - 3, -- 1029
		x1 = handleX + 3, -- 1030
		y0 = bodyTop - 8, -- 1031
		y1 = bodyTop + 2, -- 1032
		z0 = -11, -- 1033
		z1 = 9, -- 1034
		material = MING_MATERIALS.mingTimber, -- 1035
		bucket = LP_BUCKET.PROP, -- 1036
		sortBias = 0.14, -- 1037
		highlightTopEdge = true -- 1038
	}) -- 1038
	local clothX = axleX - halfW -- 1042
	local clothTop = bodyTop + 1 -- 1043
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 1044
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 1045
	scene:addTri3D( -- 1046
		vec3(clothX - 2, clothTop + 1, -12), -- 1047
		vec3(clothX + 11, clothTop, -11), -- 1048
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 1049
		MING_MATERIALS.mingRedCloth, -- 1050
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 1051
	) -- 1051
	scene:addTri3D( -- 1053
		vec3(clothX + 11, clothTop, -11), -- 1054
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 1055
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 1056
		MING_MATERIALS.mingRedCloth, -- 1057
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 1058
	) -- 1058
	scene:flush(fgDraw, fgGlow) -- 1061
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 1064
	local wheelR = cam:len(c.wheelR) -- 1065
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 1066
	local wi = 0 -- 1067
	do -- 1067
		wi = 0 -- 1068
		while wi < #wheelXs do -- 1068
			local wp = projectWorld3D( -- 1069
				wheelXs[wi + 1], -- 1069
				axleY, -- 1069
				-10, -- 1069
				cam, -- 1069
				self.outsideProj -- 1069
			) -- 1069
			fgDraw:drawCircle( -- 1070
				Vec2(wp.x, wp.y), -- 1070
				wheelR, -- 1070
				Color(52, 40, 32, 255) -- 1070
			) -- 1070
			fgDraw:drawRing( -- 1071
				Vec2(wp.x, wp.y), -- 1071
				math.max(1, wheelR - 2.6), -- 1071
				wheelR, -- 1071
				Color(0, 0, 0, 0), -- 1071
				1.4, -- 1071
				Color(148, 126, 102, 220) -- 1071
			) -- 1071
			local sp = 0 -- 1072
			do -- 1072
				sp = 0 -- 1073
				while sp < 4 do -- 1073
					local a = rollAngle + sp * math.pi / 4 -- 1074
					local dx = math.cos(a) * (wheelR - 2) -- 1075
					local dy = math.sin(a) * (wheelR - 2) -- 1076
					fgDraw:drawSegment( -- 1077
						Vec2(wp.x - dx, wp.y - dy), -- 1077
						Vec2(wp.x + dx, wp.y + dy), -- 1077
						1, -- 1077
						Color(118, 92, 70, 210) -- 1077
					) -- 1077
					sp = sp + 1 -- 1073
				end -- 1073
			end -- 1073
			fgDraw:drawDot( -- 1079
				Vec2(wp.x, wp.y), -- 1079
				2.4, -- 1079
				Color(172, 160, 144, 230) -- 1079
			) -- 1079
			wi = wi + 1 -- 1068
		end -- 1068
	end -- 1068
	local patchP = projectWorld3D( -- 1083
		clothX + 1, -- 1083
		clothTop - 7, -- 1083
		-13, -- 1083
		cam, -- 1083
		self.outsideProj -- 1083
	) -- 1083
	fgDraw:drawSegment( -- 1084
		Vec2(patchP.x - 3, patchP.y), -- 1084
		Vec2(patchP.x + 3, patchP.y - 2), -- 1084
		1, -- 1084
		Color(224, 212, 188, 215) -- 1084
	) -- 1084
	fgDraw:drawSegment( -- 1085
		Vec2(patchP.x - 2, patchP.y - 4), -- 1085
		Vec2(patchP.x + 2, patchP.y - 5), -- 1085
		0.9, -- 1085
		Color(224, 212, 188, 195) -- 1085
	) -- 1085
	return true -- 1087
end -- 975
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1090
	if not self.active then -- 1096
		return -- 1097
	end -- 1097
	local key = ctx.p.room.key -- 1099
	if key == "village" then -- 1100
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1101
	elseif key == "forest" then -- 1102
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1103
	end -- 1103
end -- 1090
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1111
	if not self.active then -- 1118
		return false -- 1119
	end -- 1119
	local key = ctx.p.room.key -- 1121
	if key == "village" then -- 1122
		return self.village:drawForegroundOverlay( -- 1123
			uiDraw, -- 1123
			uiInkDraw, -- 1123
			uiArt, -- 1123
			uiGlow, -- 1123
			ctx -- 1123
		) -- 1123
	end -- 1123
	if key == "forest" then -- 1125
		return self.forest:drawForegroundOverlay( -- 1126
			uiDraw, -- 1126
			uiInkDraw, -- 1126
			uiArt, -- 1126
			uiGlow, -- 1126
			ctx -- 1126
		) -- 1126
	end -- 1126
	if key == "outside" then -- 1128
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 1129
		return false -- 1130
	end -- 1130
	return false -- 1132
end -- 1111
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1139
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1145
		return -- 1146
	end -- 1146
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1148
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1150
	if alpha <= 0.01 then -- 1151
		return -- 1152
	end -- 1152
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1154
	local handPt = projectWorld3D( -- 1155
		self.memoryAnchorWorldX, -- 1155
		self.memoryAnchorWorldY, -- 1155
		0, -- 1155
		ctx.cam, -- 1155
		self.outsideProj -- 1155
	) -- 1155
	local cx = math.max( -- 1157
		160, -- 1157
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 1157
	) -- 1157
	local cy = math.max( -- 1158
		150, -- 1158
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 1158
	) -- 1158
	local rx = 122 -- 1159
	local ry = 74 -- 1160
	fillRadialGlow( -- 1163
		uiGlow, -- 1163
		cx, -- 1163
		cy, -- 1163
		rx * 1.55, -- 1163
		ry * 1.55, -- 1163
		Color( -- 1163
			238, -- 1163
			190, -- 1163
			122, -- 1163
			math.floor(92 * alpha + 0.5) -- 1163
		), -- 1163
		Color(218, 162, 92, 0), -- 1163
		22 -- 1163
	) -- 1163
	uiDraw:drawEllipse( -- 1164
		Vec2(cx, cy), -- 1164
		rx * 1.12, -- 1164
		ry * 1.12, -- 1164
		Color( -- 1164
			36, -- 1164
			26, -- 1164
			20, -- 1164
			math.floor(128 * alpha + 0.5) -- 1164
		) -- 1164
	) -- 1164
	uiDraw:drawEllipse( -- 1165
		Vec2(cx, cy), -- 1165
		rx * 0.96, -- 1165
		ry * 0.96, -- 1165
		Color( -- 1165
			32, -- 1165
			22, -- 1165
			16, -- 1165
			math.floor(206 * alpha + 0.5) -- 1165
		) -- 1165
	) -- 1165
	uiDraw:drawPolygon( -- 1168
		{ -- 1168
			Vec2(cx - 72, cy - 34), -- 1169
			Vec2(cx + 62, cy - 28), -- 1170
			Vec2(cx + 70, cy + 32), -- 1171
			Vec2(cx - 64, cy + 28) -- 1172
		}, -- 1172
		Color( -- 1173
			148, -- 1173
			44, -- 1173
			40, -- 1173
			math.floor(230 * alpha + 0.5) -- 1173
		) -- 1173
	) -- 1173
	uiDraw:drawPolygon( -- 1174
		{ -- 1174
			Vec2(cx - 28, cy - 18), -- 1175
			Vec2(cx + 26, cy - 14), -- 1176
			Vec2(cx + 22, cy + 20), -- 1177
			Vec2(cx - 24, cy + 16) -- 1178
		}, -- 1178
		Color( -- 1179
			172, -- 1179
			62, -- 1179
			54, -- 1179
			math.floor(238 * alpha + 0.5) -- 1179
		), -- 1179
		1, -- 1179
		Color( -- 1179
			224, -- 1179
			210, -- 1179
			184, -- 1179
			math.floor(170 * alpha + 0.5) -- 1179
		) -- 1179
	) -- 1179
	local si = 0 -- 1182
	do -- 1182
		si = 0 -- 1183
		while si < 4 do -- 1183
			local sx = cx - 18 + si * 11 -- 1184
			uiInkDraw:drawSegment( -- 1185
				Vec2(sx, cy - 15), -- 1185
				Vec2(sx + 4, cy - 9), -- 1185
				1.3, -- 1185
				Color( -- 1185
					236, -- 1185
					224, -- 1185
					198, -- 1185
					math.floor(235 * alpha + 0.5) -- 1185
				) -- 1185
			) -- 1185
			si = si + 1 -- 1183
		end -- 1183
	end -- 1183
	local pullT = smoothstep(0.14, 0.82, prog) -- 1189
	local stitchAnchorX = cx + 22 -- 1190
	local stitchAnchorY = cy - 12 -- 1191
	local handX = cx + 32 + pullT * 34 -- 1192
	local handY = cy + 6 + pullT * 26 -- 1193
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1196
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1197
	uiInkDraw:drawSegment( -- 1198
		Vec2(stitchAnchorX, stitchAnchorY), -- 1198
		Vec2(midX, midY), -- 1198
		1.2, -- 1198
		Color( -- 1198
			242, -- 1198
			234, -- 1198
			214, -- 1198
			math.floor(240 * alpha + 0.5) -- 1198
		) -- 1198
	) -- 1198
	uiInkDraw:drawSegment( -- 1199
		Vec2(midX, midY), -- 1199
		Vec2(handX - 6, handY - 2), -- 1199
		1.2, -- 1199
		Color( -- 1199
			242, -- 1199
			234, -- 1199
			214, -- 1199
			math.floor(240 * alpha + 0.5) -- 1199
		) -- 1199
	) -- 1199
	uiInkDraw:drawSegment( -- 1202
		Vec2(handX - 16, handY - 8), -- 1202
		Vec2(handX + 2, handY + 4), -- 1202
		1.1, -- 1202
		Color( -- 1202
			230, -- 1202
			236, -- 1202
			242, -- 1202
			math.floor(225 * alpha + 0.5) -- 1202
		) -- 1202
	) -- 1202
	uiDraw:drawPolygon( -- 1205
		{ -- 1205
			Vec2(handX - 8, handY - 6), -- 1206
			Vec2(handX + 18, handY + 2), -- 1207
			Vec2(handX + 24, handY + 14), -- 1208
			Vec2(handX + 4, handY + 14), -- 1209
			Vec2(handX - 10, handY + 4) -- 1210
		}, -- 1210
		Color( -- 1211
			214, -- 1211
			174, -- 1211
			142, -- 1211
			math.floor(225 * alpha + 0.5) -- 1211
		), -- 1211
		1, -- 1211
		Color( -- 1211
			142, -- 1211
			102, -- 1211
			78, -- 1211
			math.floor(180 * alpha + 0.5) -- 1211
		) -- 1211
	) -- 1211
	uiDraw:drawEllipse( -- 1213
		Vec2(cx - 20, cy + 4), -- 1213
		16, -- 1213
		9, -- 1213
		Color( -- 1213
			204, -- 1213
			164, -- 1213
			134, -- 1213
			math.floor(220 * alpha + 0.5) -- 1213
		) -- 1213
	) -- 1213
end -- 1139
function ____exports.createLowpolyWorldPlugin() -- 1217
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1218
end -- 1217
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1222
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1225
	fe:registerPlugin(lowpolyWorld) -- 1226
	return {lowpolyWorld = lowpolyWorld} -- 1227
end -- 1222
return ____exports -- 1222
