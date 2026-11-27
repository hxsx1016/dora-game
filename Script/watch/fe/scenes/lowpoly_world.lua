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
		local redCartMemTrigger = p.redCartMemoryT > 0 and not self.memoryPlayed -- 288
		if (p.gripping and not self.prevGripping or redCartMemTrigger) and not self.memoryPlayed then -- 288
			self.memoryPlayed = true -- 290
			self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 291
			self.memoryTimer = 0 -- 292
			if redCartMemTrigger then -- 292
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
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 306
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
		if self.cartWheelVol > 0.03 then -- 318
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
	if not self.active then -- 337
		return false -- 344
	end -- 344
	local key = ctx.p.room.key -- 346
	if key == "village" then -- 346
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 348
	end -- 348
	if key == "forest" then -- 348
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 351
	end -- 351
	if key == "outside" then -- 351
		return self:drawOutsideBackdrop(bgDraw, bgGlow, ctx) -- 354
	end -- 354
	if key == "tower" then -- 354
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
		-40, -- 442
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
	if not self.active then -- 457
		return false -- 464
	end -- 464
	local key = ctx.p.room.key -- 466
	if key == "village" then -- 466
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 468
	end -- 468
	if key == "forest" then -- 468
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 471
	end -- 471
	if key == "outside" then -- 471
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 474
	end -- 474
	if key == "tower" then -- 474
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
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 492
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
	if c.bodyW > 0 then -- 518
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
	if not p.cartDocked and p.room.arch.h > 0 then -- 556
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 563
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 564
		if bx1 > bx0 + 4 then -- 564
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
			while colX < ox + 594 do -- 645
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
	scene:addBox({ -- 706
		x0 = ox + 490, -- 707
		x1 = ox + 720, -- 708
		y0 = 0, -- 709
		y1 = 215, -- 710
		z0 = -8, -- 711
		z1 = 96, -- 712
		material = MING_MATERIALS.mingBrick, -- 713
		bucket = LP_BUCKET.MIDGROUND, -- 714
		highlightTopEdge = true -- 715
	}) -- 715
	scene:addBeveledFrame( -- 719
		ox + 400, -- 719
		ox + 490, -- 719
		0, -- 719
		110, -- 719
		14, -- 719
		34, -- 719
		-8, -- 719
		68, -- 719
		MING_MATERIALS.mingStoneStep, -- 719
		{ -- 719
			bucket = LP_BUCKET.MIDGROUND, -- 720
			innerRimLight = rgba(244, 206, 140, 255), -- 721
			innerRimStrength = opened and 0.78 or 0.32 -- 722
		} -- 722
	) -- 722
	if not opened then -- 722
		scene:addBox({ -- 727
			x0 = ox + 404, -- 728
			x1 = ox + 486, -- 729
			y0 = 4, -- 730
			y1 = 109, -- 731
			z0 = 14, -- 732
			z1 = 26, -- 733
			material = MING_MATERIALS.mingTimberDark, -- 734
			bucket = LP_BUCKET.MIDGROUND, -- 735
			sortBias = 0.1, -- 736
			edgeWidth = 0.9 -- 737
		}) -- 737
	else -- 737
		scene:addQuad3D( -- 740
			vec3(ox + 404, 2, 24), -- 741
			vec3(ox + 486, 2, 24), -- 742
			vec3(ox + 486, 109, 24), -- 743
			vec3(ox + 404, 109, 24), -- 744
			{base = rgba(112, 78, 42, 255)}, -- 745
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 746
		) -- 746
	end -- 746
	scene:addQuad3D( -- 751
		vec3(ox + 286, 118, -9), -- 752
		vec3(ox + 306, 118, -9), -- 753
		vec3(ox + 306, 158, -9), -- 754
		vec3(ox + 286, 158, -9), -- 755
		{base = rgba(244, 204, 134, 255)}, -- 756
		{ -- 757
			bucket = LP_BUCKET.PROP, -- 757
			unlit = true, -- 757
			edgeColor = rgba(82, 68, 52, 255), -- 757
			edgeWidth = 1.4 -- 757
		} -- 757
	) -- 757
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 761
	scene:addLightShaft( -- 762
		ox + 412, -- 763
		ox + 478, -- 763
		106, -- 763
		ox + 382, -- 764
		ox + 506, -- 764
		0, -- 764
		6, -- 765
		rgba(246, 208, 138, 255), -- 766
		(opened and 0.34 or 0.08) * pulse, -- 767
		(opened and 0.16 or 0.04) * pulse -- 768
	) -- 768
	scene:addContactShadow( -- 772
		p.player.x, -- 772
		p.player.y, -- 772
		15, -- 772
		11, -- 772
		0.78, -- 772
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 772
	) -- 772
	scene:flush(fgDraw, fgGlow) -- 774
	local lampP = projectWorld3D( -- 777
		ox + 445, -- 777
		102, -- 777
		2, -- 777
		cam, -- 777
		self.towerProj -- 777
	) -- 777
	fillRadialGlow( -- 778
		fgGlow, -- 779
		lampP.x, -- 780
		lampP.y, -- 781
		cam:len(opened and 64 or 34) * pulse, -- 782
		cam:len(opened and 64 or 34) * pulse, -- 783
		Color( -- 784
			248, -- 784
			214, -- 784
			146, -- 784
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 784
		), -- 784
		Color(232, 174, 82, 0), -- 785
		16 -- 786
	) -- 786
	fgDraw:drawCircle( -- 788
		Vec2(lampP.x, lampP.y), -- 788
		4.2, -- 788
		Color(255, 240, 202, 245) -- 788
	) -- 788
	local winP = projectWorld3D( -- 790
		ox + 296, -- 790
		138, -- 790
		-9, -- 790
		cam, -- 790
		self.towerProj -- 790
	) -- 790
	fillRadialGlow( -- 791
		fgGlow, -- 791
		winP.x, -- 791
		winP.y, -- 791
		cam:len(38), -- 791
		cam:len(42), -- 791
		Color( -- 791
			246, -- 791
			206, -- 791
			132, -- 791
			math.floor(78 * pulse + 0.5) -- 791
		), -- 791
		Color(232, 174, 82, 0), -- 791
		14 -- 791
	) -- 791
	local wBL = projectWorld3D( -- 793
		ox + 286, -- 793
		118, -- 793
		-9, -- 793
		cam, -- 793
		self.towerProj -- 793
	) -- 793
	local wTR = projectWorld3D( -- 794
		ox + 306, -- 794
		158, -- 794
		-9, -- 794
		cam, -- 794
		self.towerProj -- 794
	) -- 794
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 795
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 796
	fgDraw:drawSegment( -- 797
		Vec2(wMidX, wBL.y), -- 797
		Vec2(wMidX, wTR.y), -- 797
		1.4, -- 797
		Color(68, 52, 38, 225) -- 797
	) -- 797
	fgDraw:drawSegment( -- 798
		Vec2(wBL.x, wMidY), -- 798
		Vec2(wTR.x, wMidY), -- 798
		1.4, -- 798
		Color(68, 52, 38, 225) -- 798
	) -- 798
	local tr = 1 -- 799
	do -- 799
		tr = 1 -- 800
		while tr <= 6 do -- 800
			local ty = tr * 30 -- 801
			local tl0 = projectWorld3D( -- 802
				ox + 182, -- 802
				ty, -- 802
				-8, -- 802
				cam, -- 802
				self.towerProj -- 802
			) -- 802
			local tl1 = projectWorld3D( -- 803
				ox + 398, -- 803
				ty, -- 803
				-8, -- 803
				cam, -- 803
				self.towerProj -- 803
			) -- 803
			fgDraw:drawSegment( -- 804
				Vec2(tl0.x, tl0.y), -- 804
				Vec2(tl1.x, tl1.y), -- 804
				0.8, -- 804
				Color(34, 38, 48, 135) -- 804
			) -- 804
			local tr0 = projectWorld3D( -- 805
				ox + 492, -- 805
				ty, -- 805
				-8, -- 805
				cam, -- 805
				self.towerProj -- 805
			) -- 805
			local tr1 = projectWorld3D( -- 806
				ox + 718, -- 806
				ty, -- 806
				-8, -- 806
				cam, -- 806
				self.towerProj -- 806
			) -- 806
			fgDraw:drawSegment( -- 807
				Vec2(tr0.x, tr0.y), -- 807
				Vec2(tr1.x, tr1.y), -- 807
				0.8, -- 807
				Color(34, 38, 48, 135) -- 807
			) -- 807
			tr = tr + 1 -- 800
		end -- 800
	end -- 800
	return true -- 810
end -- 657
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 813
	if not self.active then -- 813
		return false -- 820
	end -- 820
	local key = ctx.p.room.key -- 822
	if key == "village" then -- 822
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 824
	end -- 824
	if key == "forest" then -- 824
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 827
	end -- 827
	if key == "outside" then -- 827
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 830
	end -- 830
	if key == "tower" then -- 830
		local p = ctx.p -- 833
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 834
		if opened then -- 834
			local cam = ctx.cam -- 836
			local deskCx = cam:sx(p.ox + 605) -- 837
			local groundY = cam:sy(0) -- 838
			local deskW = cam:len(84) -- 839
			local deskH = cam:len(34) -- 840
			local deskTop = groundY + deskH -- 841
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 842
			fillRadialGlow( -- 843
				fgGlow, -- 843
				deskCx, -- 843
				deskTop + cam:len(28), -- 843
				cam:len(120), -- 843
				cam:len(88), -- 843
				Color( -- 844
					255, -- 844
					198, -- 844
					114, -- 844
					math.floor(74 * pulse + 0.5) -- 844
				), -- 844
				Color(255, 168, 72, 0), -- 844
				16 -- 844
			) -- 844
			local guardX = deskCx + cam:len(26) -- 846
			fgDraw:drawRect( -- 847
				Rect( -- 847
					guardX - cam:len(11), -- 847
					groundY, -- 847
					cam:len(22), -- 847
					cam:len(68) -- 847
				), -- 847
				Color(28, 34, 44, 240) -- 847
			) -- 847
			fgDraw:drawCircle( -- 848
				Vec2( -- 848
					guardX, -- 848
					groundY + cam:len(76) -- 848
				), -- 848
				cam:len(9.5), -- 848
				Color(36, 44, 56, 245) -- 848
			) -- 848
			fgDraw:drawRect( -- 849
				Rect( -- 849
					deskCx - deskW * 0.5, -- 849
					groundY, -- 849
					cam:len(6), -- 849
					deskH -- 849
				), -- 849
				Color(74, 48, 30, 255) -- 849
			) -- 849
			fgDraw:drawRect( -- 850
				Rect( -- 850
					deskCx + deskW * 0.5 - cam:len(6), -- 850
					groundY, -- 850
					cam:len(6), -- 850
					deskH -- 850
				), -- 850
				Color(74, 48, 30, 255) -- 850
			) -- 850
			fgDraw:drawRect( -- 851
				Rect( -- 851
					deskCx - deskW * 0.52, -- 851
					deskTop - cam:len(6), -- 851
					deskW * 1.04, -- 851
					cam:len(8) -- 851
				), -- 851
				Color(102, 68, 42, 255), -- 851
				1, -- 851
				Color(146, 106, 66, 220) -- 851
			) -- 851
			fgDraw:drawRect( -- 852
				Rect( -- 852
					deskCx + cam:len(4), -- 852
					deskTop + cam:len(2), -- 852
					cam:len(24), -- 852
					cam:len(5) -- 852
				), -- 852
				Color(230, 220, 196, 245) -- 852
			) -- 852
			fgDraw:drawRect( -- 853
				Rect( -- 853
					deskCx + cam:len(32), -- 853
					deskTop + cam:len(2), -- 853
					cam:len(8), -- 853
					cam:len(12) -- 853
				), -- 853
				Color(166, 126, 62, 245) -- 853
			) -- 853
			fgGlow:drawCircle( -- 854
				Vec2( -- 854
					deskCx + cam:len(36), -- 854
					deskTop + cam:len(16) -- 854
				), -- 854
				cam:len(5.5), -- 854
				Color( -- 854
					255, -- 854
					224, -- 854
					152, -- 854
					math.floor(220 * pulse + 0.5) -- 854
				) -- 854
			) -- 854
			if p.deskHold >= 12 or p.towerHanded then -- 854
				fgDraw:drawRect( -- 856
					Rect( -- 856
						deskCx - cam:len(28), -- 856
						deskTop + cam:len(2), -- 856
						cam:len(14), -- 856
						cam:len(6) -- 856
					), -- 856
					Color(156, 62, 48, 245) -- 856
				) -- 856
			end -- 856
			if p.deskHold >= 24 or p.towerHanded then -- 856
				fgDraw:drawCircle( -- 859
					Vec2( -- 859
						deskCx - cam:len(8), -- 859
						deskTop + cam:len(5) -- 859
					), -- 859
					cam:len(4.5), -- 859
					Color(224, 186, 98, 255) -- 859
				) -- 859
				fgDraw:drawRect( -- 860
					Rect( -- 860
						deskCx - cam:len(16), -- 860
						deskTop + cam:len(2), -- 860
						cam:len(10), -- 860
						cam:len(3) -- 860
					), -- 860
					Color(236, 228, 206, 240) -- 860
				) -- 860
			end -- 860
		end -- 860
		return true -- 863
	end -- 863
	return false -- 865
end -- 813
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 869
	local p = ctx.p -- 870
	local cam = ctx.cam -- 871
	local c = p.room.cart -- 872
	if c.bodyW <= 0 then -- 872
		return true -- 874
	end -- 874
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 876
	local halfW = c.bodyW * 0.5 -- 877
	local axleX = p.cartAxle -- 878
	local axleY = c.baseY + c.wheelR -- 879
	local bodyBot = axleY + 2 -- 880
	local bodyTop = bodyBot + c.bodyH -- 881
	scene:addBox({ -- 884
		x0 = axleX - halfW, -- 885
		x1 = axleX + halfW, -- 886
		y0 = bodyBot, -- 887
		y1 = bodyTop, -- 888
		z0 = -12, -- 889
		z1 = 14, -- 890
		material = MING_MATERIALS.mingTimber, -- 891
		bucket = LP_BUCKET.PROP, -- 892
		highlightTopEdge = true, -- 893
		edgeWidth = 1 -- 894
	}) -- 894
	scene:addBox({ -- 897
		x0 = axleX - halfW - 1, -- 898
		x1 = axleX + halfW + 1, -- 899
		y0 = bodyBot + 4, -- 900
		y1 = bodyBot + 8, -- 901
		z0 = -13, -- 902
		z1 = 15, -- 903
		material = MING_MATERIALS.mingIron, -- 904
		bucket = LP_BUCKET.PROP, -- 905
		sortBias = 0.08 -- 906
	}) -- 906
	local handleX = axleX + c.handleOffset -- 909
	scene:addBox({ -- 910
		x0 = axleX + halfW - 2, -- 911
		x1 = handleX, -- 912
		y0 = bodyTop - 6, -- 913
		y1 = bodyTop - 1, -- 914
		z0 = -10, -- 915
		z1 = -4, -- 916
		material = MING_MATERIALS.mingTimber, -- 917
		bucket = LP_BUCKET.PROP, -- 918
		sortBias = 0.12, -- 919
		highlightTopEdge = true -- 920
	}) -- 920
	scene:addBox({ -- 922
		x0 = handleX - 3, -- 923
		x1 = handleX + 3, -- 924
		y0 = bodyTop - 8, -- 925
		y1 = bodyTop + 2, -- 926
		z0 = -11, -- 927
		z1 = 9, -- 928
		material = MING_MATERIALS.mingTimber, -- 929
		bucket = LP_BUCKET.PROP, -- 930
		sortBias = 0.14, -- 931
		highlightTopEdge = true -- 932
	}) -- 932
	local clothX = axleX - halfW -- 936
	local clothTop = bodyTop + 1 -- 937
	local sway = math.sin(self.animTime * 3.1) * 5.8 -- 938
	local sway2 = math.cos(self.animTime * 2.6) * 3.6 -- 939
	scene:addTri3D( -- 940
		vec3(clothX - 2, clothTop + 1, -12), -- 941
		vec3(clothX + 11, clothTop, -11), -- 942
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 943
		MING_MATERIALS.mingRedCloth, -- 944
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 0.9} -- 945
	) -- 945
	scene:addTri3D( -- 947
		vec3(clothX + 11, clothTop, -11), -- 948
		vec3(clothX - 16 + sway, clothTop - 22, -14), -- 949
		vec3(clothX - 1 + sway2, clothTop - 24, -12), -- 950
		MING_MATERIALS.mingRedCloth, -- 951
		{bucket = LP_BUCKET.PROP, sortBias = 0.29, edgeWidth = 0.6} -- 952
	) -- 952
	scene:flush(fgDraw, fgGlow) -- 955
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 958
	local wheelR = cam:len(c.wheelR) -- 959
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 960
	local wi = 0 -- 961
	do -- 961
		wi = 0 -- 962
		while wi < #wheelXs do -- 962
			local wp = projectWorld3D( -- 963
				wheelXs[wi + 1], -- 963
				axleY, -- 963
				-10, -- 963
				cam, -- 963
				self.outsideProj -- 963
			) -- 963
			fgDraw:drawCircle( -- 964
				Vec2(wp.x, wp.y), -- 964
				wheelR, -- 964
				Color(52, 40, 32, 255) -- 964
			) -- 964
			fgDraw:drawRing( -- 965
				Vec2(wp.x, wp.y), -- 965
				math.max(1, wheelR - 2.6), -- 965
				wheelR, -- 965
				Color(0, 0, 0, 0), -- 965
				1.4, -- 965
				Color(148, 126, 102, 220) -- 965
			) -- 965
			local sp = 0 -- 966
			do -- 966
				sp = 0 -- 967
				while sp < 4 do -- 967
					local a = rollAngle + sp * math.pi / 4 -- 968
					local dx = math.cos(a) * (wheelR - 2) -- 969
					local dy = math.sin(a) * (wheelR - 2) -- 970
					fgDraw:drawSegment( -- 971
						Vec2(wp.x - dx, wp.y - dy), -- 971
						Vec2(wp.x + dx, wp.y + dy), -- 971
						1, -- 971
						Color(118, 92, 70, 210) -- 971
					) -- 971
					sp = sp + 1 -- 967
				end -- 967
			end -- 967
			fgDraw:drawDot( -- 973
				Vec2(wp.x, wp.y), -- 973
				2.4, -- 973
				Color(172, 160, 144, 230) -- 973
			) -- 973
			wi = wi + 1 -- 962
		end -- 962
	end -- 962
	local patchP = projectWorld3D( -- 977
		clothX + 1, -- 977
		clothTop - 7, -- 977
		-13, -- 977
		cam, -- 977
		self.outsideProj -- 977
	) -- 977
	fgDraw:drawSegment( -- 978
		Vec2(patchP.x - 3, patchP.y), -- 978
		Vec2(patchP.x + 3, patchP.y - 2), -- 978
		1, -- 978
		Color(224, 212, 188, 215) -- 978
	) -- 978
	fgDraw:drawSegment( -- 979
		Vec2(patchP.x - 2, patchP.y - 4), -- 979
		Vec2(patchP.x + 2, patchP.y - 5), -- 979
		0.9, -- 979
		Color(224, 212, 188, 195) -- 979
	) -- 979
	return true -- 981
end -- 869
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 984
	if not self.active then -- 984
		return -- 991
	end -- 991
	local key = ctx.p.room.key -- 993
	if key == "village" then -- 993
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 995
	elseif key == "forest" then -- 995
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 997
	end -- 997
end -- 984
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1005
	if not self.active then -- 1005
		return false -- 1013
	end -- 1013
	local key = ctx.p.room.key -- 1015
	if key == "village" then -- 1015
		return self.village:drawForegroundOverlay( -- 1017
			uiDraw, -- 1017
			uiInkDraw, -- 1017
			uiArt, -- 1017
			uiGlow, -- 1017
			ctx -- 1017
		) -- 1017
	end -- 1017
	if key == "forest" then -- 1017
		return self.forest:drawForegroundOverlay( -- 1020
			uiDraw, -- 1020
			uiInkDraw, -- 1020
			uiArt, -- 1020
			uiGlow, -- 1020
			ctx -- 1020
		) -- 1020
	end -- 1020
	if key == "outside" then -- 1020
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 1023
		return false -- 1024
	end -- 1024
	return false -- 1026
end -- 1005
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1033
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1033
		return -- 1040
	end -- 1040
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1042
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1044
	if alpha <= 0.01 then -- 1044
		return -- 1046
	end -- 1046
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1048
	local handPt = projectWorld3D( -- 1049
		self.memoryAnchorWorldX, -- 1049
		self.memoryAnchorWorldY, -- 1049
		0, -- 1049
		ctx.cam, -- 1049
		self.outsideProj -- 1049
	) -- 1049
	local cx = math.max( -- 1051
		160, -- 1051
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 1051
	) -- 1051
	local cy = math.max( -- 1052
		150, -- 1052
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 1052
	) -- 1052
	local rx = 122 -- 1053
	local ry = 74 -- 1054
	fillRadialGlow( -- 1057
		uiGlow, -- 1057
		cx, -- 1057
		cy, -- 1057
		rx * 1.55, -- 1057
		ry * 1.55, -- 1057
		Color( -- 1057
			238, -- 1057
			190, -- 1057
			122, -- 1057
			math.floor(92 * alpha + 0.5) -- 1057
		), -- 1057
		Color(218, 162, 92, 0), -- 1057
		22 -- 1057
	) -- 1057
	uiDraw:drawEllipse( -- 1058
		Vec2(cx, cy), -- 1058
		rx * 1.12, -- 1058
		ry * 1.12, -- 1058
		Color( -- 1058
			36, -- 1058
			26, -- 1058
			20, -- 1058
			math.floor(128 * alpha + 0.5) -- 1058
		) -- 1058
	) -- 1058
	uiDraw:drawEllipse( -- 1059
		Vec2(cx, cy), -- 1059
		rx * 0.96, -- 1059
		ry * 0.96, -- 1059
		Color( -- 1059
			32, -- 1059
			22, -- 1059
			16, -- 1059
			math.floor(206 * alpha + 0.5) -- 1059
		) -- 1059
	) -- 1059
	uiDraw:drawPolygon( -- 1062
		{ -- 1062
			Vec2(cx - 72, cy - 34), -- 1063
			Vec2(cx + 62, cy - 28), -- 1064
			Vec2(cx + 70, cy + 32), -- 1065
			Vec2(cx - 64, cy + 28) -- 1066
		}, -- 1066
		Color( -- 1067
			148, -- 1067
			44, -- 1067
			40, -- 1067
			math.floor(230 * alpha + 0.5) -- 1067
		) -- 1067
	) -- 1067
	uiDraw:drawPolygon( -- 1068
		{ -- 1068
			Vec2(cx - 28, cy - 18), -- 1069
			Vec2(cx + 26, cy - 14), -- 1070
			Vec2(cx + 22, cy + 20), -- 1071
			Vec2(cx - 24, cy + 16) -- 1072
		}, -- 1072
		Color( -- 1073
			172, -- 1073
			62, -- 1073
			54, -- 1073
			math.floor(238 * alpha + 0.5) -- 1073
		), -- 1073
		1, -- 1073
		Color( -- 1073
			224, -- 1073
			210, -- 1073
			184, -- 1073
			math.floor(170 * alpha + 0.5) -- 1073
		) -- 1073
	) -- 1073
	local si = 0 -- 1076
	do -- 1076
		si = 0 -- 1077
		while si < 4 do -- 1077
			local sx = cx - 18 + si * 11 -- 1078
			uiInkDraw:drawSegment( -- 1079
				Vec2(sx, cy - 15), -- 1079
				Vec2(sx + 4, cy - 9), -- 1079
				1.3, -- 1079
				Color( -- 1079
					236, -- 1079
					224, -- 1079
					198, -- 1079
					math.floor(235 * alpha + 0.5) -- 1079
				) -- 1079
			) -- 1079
			si = si + 1 -- 1077
		end -- 1077
	end -- 1077
	local pullT = smoothstep(0.14, 0.82, prog) -- 1083
	local stitchAnchorX = cx + 22 -- 1084
	local stitchAnchorY = cy - 12 -- 1085
	local handX = cx + 32 + pullT * 34 -- 1086
	local handY = cy + 6 + pullT * 26 -- 1087
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1090
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1091
	uiInkDraw:drawSegment( -- 1092
		Vec2(stitchAnchorX, stitchAnchorY), -- 1092
		Vec2(midX, midY), -- 1092
		1.2, -- 1092
		Color( -- 1092
			242, -- 1092
			234, -- 1092
			214, -- 1092
			math.floor(240 * alpha + 0.5) -- 1092
		) -- 1092
	) -- 1092
	uiInkDraw:drawSegment( -- 1093
		Vec2(midX, midY), -- 1093
		Vec2(handX - 6, handY - 2), -- 1093
		1.2, -- 1093
		Color( -- 1093
			242, -- 1093
			234, -- 1093
			214, -- 1093
			math.floor(240 * alpha + 0.5) -- 1093
		) -- 1093
	) -- 1093
	uiInkDraw:drawSegment( -- 1096
		Vec2(handX - 16, handY - 8), -- 1096
		Vec2(handX + 2, handY + 4), -- 1096
		1.1, -- 1096
		Color( -- 1096
			230, -- 1096
			236, -- 1096
			242, -- 1096
			math.floor(225 * alpha + 0.5) -- 1096
		) -- 1096
	) -- 1096
	uiDraw:drawPolygon( -- 1099
		{ -- 1099
			Vec2(handX - 8, handY - 6), -- 1100
			Vec2(handX + 18, handY + 2), -- 1101
			Vec2(handX + 24, handY + 14), -- 1102
			Vec2(handX + 4, handY + 14), -- 1103
			Vec2(handX - 10, handY + 4) -- 1104
		}, -- 1104
		Color( -- 1105
			214, -- 1105
			174, -- 1105
			142, -- 1105
			math.floor(225 * alpha + 0.5) -- 1105
		), -- 1105
		1, -- 1105
		Color( -- 1105
			142, -- 1105
			102, -- 1105
			78, -- 1105
			math.floor(180 * alpha + 0.5) -- 1105
		) -- 1105
	) -- 1105
	uiDraw:drawEllipse( -- 1107
		Vec2(cx - 20, cy + 4), -- 1107
		16, -- 1107
		9, -- 1107
		Color( -- 1107
			204, -- 1107
			164, -- 1107
			134, -- 1107
			math.floor(220 * alpha + 0.5) -- 1107
		) -- 1107
	) -- 1107
end -- 1033
function ____exports.createLowpolyWorldPlugin() -- 1111
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1112
end -- 1111
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1116
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1119
	fe:registerPlugin(lowpolyWorld) -- 1120
	return {lowpolyWorld = lowpolyWorld} -- 1121
end -- 1116
return ____exports -- 1116