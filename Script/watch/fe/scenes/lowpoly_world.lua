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
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 407
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
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 452
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
		scene:addWavingQuad3D( -- 507
			vec3(redBox.x0 - 4, redBox.y0 + 10, -12), -- 508
			vec3(redBox.x0 + 14, redBox.y0 + 12, -11), -- 509
			vec3(redBox.x0 + 18, redBox.y1, -10), -- 510
			vec3(redBox.x0 + 4, redBox.y1, -11), -- 511
			MING_MATERIALS.mingRedCloth, -- 512
			{ -- 513
				ampX = 4.5, -- 513
				ampY = 1.8, -- 513
				phase = self.animTime * 2.9, -- 513
				freqU = 1.8, -- 513
				freqV = 2.4, -- 513
				pin = "top" -- 513
			}, -- 513
			{bucket = LP_BUCKET.PROP, sortBias = 0.26, subdivX = 3, subdivY = 3} -- 514
		) -- 514
	end -- 514
	local c = p.room.cart -- 519
	if c.bodyW > 0 then -- 519
		scene:addBox({ -- 522
			x0 = c.endX - 18, -- 523
			x1 = c.endX + 18, -- 524
			y0 = c.baseY - 4, -- 525
			y1 = c.baseY + 2, -- 526
			z0 = -12, -- 527
			z1 = 14, -- 528
			material = MING_MATERIALS.mingIron, -- 529
			bucket = LP_BUCKET.WALK_DECK, -- 530
			sortBias = 0.35, -- 531
			highlightTopEdge = true -- 532
		}) -- 532
		scene:addBox({ -- 535
			x0 = ox + 258, -- 536
			x1 = ox + 474, -- 537
			y0 = c.baseY - 1.5, -- 538
			y1 = c.baseY + 0.4, -- 539
			z0 = -11, -- 540
			z1 = -7, -- 541
			material = MING_MATERIALS.mingTimberDark, -- 542
			bucket = LP_BUCKET.WALK_DECK, -- 543
			sortBias = 0.3, -- 544
			edgeWidth = 0 -- 545
		}) -- 545
		scene:addBox({ -- 547
			x0 = ox + 258, -- 548
			x1 = ox + 474, -- 549
			y0 = c.baseY - 1.5, -- 550
			y1 = c.baseY + 0.4, -- 551
			z0 = 7, -- 552
			z1 = 11, -- 553
			material = MING_MATERIALS.mingTimberDark, -- 554
			bucket = LP_BUCKET.WALK_DECK, -- 555
			sortBias = 0.3, -- 556
			edgeWidth = 0 -- 557
		}) -- 557
	end -- 557
	if not p.cartDocked and p.room.arch.h > 0 then -- 557
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 564
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 565
		if bx1 > bx0 + 4 then -- 565
			scene:addBox({ -- 567
				x0 = bx0, -- 568
				x1 = bx1, -- 569
				y0 = 2, -- 570
				y1 = p.room.arch.h, -- 571
				z0 = -6, -- 572
				z1 = 8, -- 573
				material = MING_MATERIALS.mingTimberDark, -- 574
				bucket = LP_BUCKET.PROP, -- 575
				highlightTopEdge = true, -- 576
				edgeWidth = 0.9 -- 577
			}) -- 577
			scene:addBox({ -- 580
				x0 = (bx0 + bx1) * 0.5 - 3, -- 581
				x1 = (bx0 + bx1) * 0.5 + 3, -- 582
				y0 = p.room.arch.h, -- 583
				y1 = p.room.cart.baseY, -- 584
				z0 = -3, -- 585
				z1 = 5, -- 586
				material = MING_MATERIALS.mingIron, -- 587
				bucket = LP_BUCKET.PROP, -- 588
				edgeWidth = 0.6 -- 589
			}) -- 589
		end -- 589
	end -- 589
	scene:addBox({ -- 595
		x0 = ox + 128, -- 596
		x1 = ox + 598, -- 597
		y0 = 0, -- 598
		y1 = 92, -- 599
		z0 = 44, -- 600
		z1 = 72, -- 601
		material = MING_MATERIALS.mingBrickDark, -- 602
		bucket = LP_BUCKET.MIDGROUND, -- 603
		sortBias = -0.2, -- 604
		edgeWidth = 0.5 -- 605
	}) -- 605
	scene:addQuad3D( -- 608
		vec3(ox + 132, 26, 43), -- 609
		vec3(ox + 592, 26, 43), -- 610
		vec3(ox + 592, 31, 43), -- 611
		vec3(ox + 132, 31, 43), -- 612
		{base = rgba(138, 148, 158, 92)}, -- 613
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 614
	) -- 614
	scene:addLightShaft( -- 618
		ox + 1110, -- 619
		ox + 1180, -- 619
		170, -- 619
		ox + 1040, -- 620
		ox + 1140, -- 620
		0, -- 620
		34, -- 621
		rgba(234, 198, 138, 255), -- 622
		0.14, -- 623
		0.03 -- 624
	) -- 624
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 627
	local gi = 0 -- 630
	do -- 630
		gi = 0 -- 631
		while gi < 6 do -- 631
			local gx = ox + 165 + gi * 56 -- 632
			local p0 = projectWorld3D( -- 633
				gx, -- 633
				0.5, -- 633
				-14, -- 633
				cam, -- 633
				self.outsideProj -- 633
			) -- 633
			local p1 = projectWorld3D( -- 634
				gx + 10, -- 634
				0.5, -- 634
				22, -- 634
				cam, -- 634
				self.outsideProj -- 634
			) -- 634
			fgDraw:drawSegment( -- 635
				Vec2(p0.x, p0.y), -- 635
				Vec2(p1.x, p1.y), -- 635
				3, -- 635
				Color(8, 12, 18, 76) -- 635
			) -- 635
			gi = gi + 1 -- 631
		end -- 631
	end -- 631
	return true -- 638
end -- 482
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 641
	local p = ctx.p -- 642
	local cam = ctx.cam -- 643
	local ox = p.ox -- 644
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 645
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 650
	scene:addBox({ -- 653
		x0 = ox - 40, -- 654
		x1 = ox + 760, -- 655
		y0 = -52, -- 656
		y1 = 0, -- 657
		z0 = -26, -- 658
		z1 = 96, -- 659
		material = MING_MATERIALS.mingBrickDark, -- 660
		bucket = LP_BUCKET.WALK_DECK, -- 661
		highlightTopEdge = true -- 662
	}) -- 662
	scene:addBox({ -- 665
		x0 = ox + 398, -- 666
		x1 = ox + 492, -- 667
		y0 = -4, -- 668
		y1 = 2.5, -- 669
		z0 = -16, -- 670
		z1 = 26, -- 671
		material = MING_MATERIALS.mingStoneStep, -- 672
		bucket = LP_BUCKET.WALK_DECK, -- 673
		sortBias = 0.15, -- 674
		highlightTopEdge = true -- 675
	}) -- 675
	scene:addBox({ -- 679
		x0 = ox + 180, -- 680
		x1 = ox + 400, -- 681
		y0 = 0, -- 682
		y1 = 215, -- 683
		z0 = -8, -- 684
		z1 = 96, -- 685
		material = MING_MATERIALS.mingBrick, -- 686
		bucket = LP_BUCKET.MIDGROUND, -- 687
		highlightTopEdge = true -- 688
	}) -- 688
	scene:addBox({ -- 690
		x0 = ox + 490, -- 691
		x1 = ox + 720, -- 692
		y0 = 0, -- 693
		y1 = 215, -- 694
		z0 = -8, -- 695
		z1 = 96, -- 696
		material = MING_MATERIALS.mingBrick, -- 697
		bucket = LP_BUCKET.MIDGROUND, -- 698
		highlightTopEdge = true -- 699
	}) -- 699
	scene:addBeveledFrame( -- 703
		ox + 400, -- 703
		ox + 490, -- 703
		0, -- 703
		110, -- 703
		14, -- 703
		34, -- 703
		-8, -- 703
		68, -- 703
		MING_MATERIALS.mingStoneStep, -- 703
		{ -- 703
			bucket = LP_BUCKET.MIDGROUND, -- 704
			innerRimLight = rgba(244, 206, 140, 255), -- 705
			innerRimStrength = opened and 0.78 or 0.32 -- 706
		} -- 706
	) -- 706
	if not opened then -- 706
		scene:addBox({ -- 711
			x0 = ox + 404, -- 712
			x1 = ox + 486, -- 713
			y0 = 4, -- 714
			y1 = 109, -- 715
			z0 = 14, -- 716
			z1 = 26, -- 717
			material = MING_MATERIALS.mingTimberDark, -- 718
			bucket = LP_BUCKET.MIDGROUND, -- 719
			sortBias = 0.1, -- 720
			edgeWidth = 0.9 -- 721
		}) -- 721
	else -- 721
		scene:addQuad3D( -- 724
			vec3(ox + 404, 2, 24), -- 725
			vec3(ox + 486, 2, 24), -- 726
			vec3(ox + 486, 109, 24), -- 727
			vec3(ox + 404, 109, 24), -- 728
			{base = rgba(112, 78, 42, 255)}, -- 729
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 730
		) -- 730
	end -- 730
	scene:addQuad3D( -- 735
		vec3(ox + 286, 118, -9), -- 736
		vec3(ox + 306, 118, -9), -- 737
		vec3(ox + 306, 158, -9), -- 738
		vec3(ox + 286, 158, -9), -- 739
		{base = rgba(244, 204, 134, 255)}, -- 740
		{ -- 741
			bucket = LP_BUCKET.PROP, -- 741
			unlit = true, -- 741
			edgeColor = rgba(82, 68, 52, 255), -- 741
			edgeWidth = 1.4 -- 741
		} -- 741
	) -- 741
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 745
	scene:addLightShaft( -- 746
		ox + 412, -- 747
		ox + 478, -- 747
		106, -- 747
		ox + 382, -- 748
		ox + 506, -- 748
		0, -- 748
		6, -- 749
		rgba(246, 208, 138, 255), -- 750
		(opened and 0.34 or 0.08) * pulse, -- 751
		(opened and 0.16 or 0.04) * pulse -- 752
	) -- 752
	scene:addContactShadow( -- 756
		p.player.x, -- 756
		p.player.y, -- 756
		15, -- 756
		11, -- 756
		0.78, -- 756
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 756
	) -- 756
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 758
	local lampP = projectWorld3D( -- 761
		ox + 445, -- 761
		102, -- 761
		2, -- 761
		cam, -- 761
		self.towerProj -- 761
	) -- 761
	fillRadialGlow( -- 762
		fgGlow, -- 763
		lampP.x, -- 764
		lampP.y, -- 765
		cam:len(opened and 64 or 34) * pulse, -- 766
		cam:len(opened and 64 or 34) * pulse, -- 767
		Color( -- 768
			248, -- 768
			214, -- 768
			146, -- 768
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 768
		), -- 768
		Color(232, 174, 82, 0), -- 769
		16 -- 770
	) -- 770
	fgDraw:drawCircle( -- 772
		Vec2(lampP.x, lampP.y), -- 772
		4.2, -- 772
		Color(255, 240, 202, 245) -- 772
	) -- 772
	local winP = projectWorld3D( -- 774
		ox + 296, -- 774
		138, -- 774
		-9, -- 774
		cam, -- 774
		self.towerProj -- 774
	) -- 774
	fillRadialGlow( -- 775
		fgGlow, -- 775
		winP.x, -- 775
		winP.y, -- 775
		cam:len(38), -- 775
		cam:len(42), -- 775
		Color( -- 775
			246, -- 775
			206, -- 775
			132, -- 775
			math.floor(78 * pulse + 0.5) -- 775
		), -- 775
		Color(232, 174, 82, 0), -- 775
		14 -- 775
	) -- 775
	local wBL = projectWorld3D( -- 777
		ox + 286, -- 777
		118, -- 777
		-9, -- 777
		cam, -- 777
		self.towerProj -- 777
	) -- 777
	local wTR = projectWorld3D( -- 778
		ox + 306, -- 778
		158, -- 778
		-9, -- 778
		cam, -- 778
		self.towerProj -- 778
	) -- 778
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 779
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 780
	fgDraw:drawSegment( -- 781
		Vec2(wMidX, wBL.y), -- 781
		Vec2(wMidX, wTR.y), -- 781
		1.4, -- 781
		Color(68, 52, 38, 225) -- 781
	) -- 781
	fgDraw:drawSegment( -- 782
		Vec2(wBL.x, wMidY), -- 782
		Vec2(wTR.x, wMidY), -- 782
		1.4, -- 782
		Color(68, 52, 38, 225) -- 782
	) -- 782
	return true -- 784
end -- 641
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 787
	if not self.active then -- 787
		return false -- 794
	end -- 794
	local key = ctx.p.room.key -- 796
	if key == "village" then -- 796
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 798
	end -- 798
	if key == "forest" then -- 798
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 801
	end -- 801
	if key == "outside" then -- 801
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 804
	end -- 804
	if key == "tower" then -- 804
		local p = ctx.p -- 807
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 808
		if opened then -- 808
			local cam = ctx.cam -- 810
			local deskCx = cam:sx(p.ox + 605) -- 811
			local groundY = cam:sy(0) -- 812
			local deskW = cam:len(84) -- 813
			local deskH = cam:len(34) -- 814
			local deskTop = groundY + deskH -- 815
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 816
			fillRadialGlow( -- 817
				fgGlow, -- 817
				deskCx, -- 817
				deskTop + cam:len(28), -- 817
				cam:len(120), -- 817
				cam:len(88), -- 817
				Color( -- 818
					255, -- 818
					198, -- 818
					114, -- 818
					math.floor(74 * pulse + 0.5) -- 818
				), -- 818
				Color(255, 168, 72, 0), -- 818
				16 -- 818
			) -- 818
			local guardX = deskCx + cam:len(26) -- 820
			fgDraw:drawRect( -- 821
				Rect( -- 821
					guardX - cam:len(11), -- 821
					groundY, -- 821
					cam:len(22), -- 821
					cam:len(68) -- 821
				), -- 821
				Color(28, 34, 44, 240) -- 821
			) -- 821
			fgDraw:drawCircle( -- 822
				Vec2( -- 822
					guardX, -- 822
					groundY + cam:len(76) -- 822
				), -- 822
				cam:len(9.5), -- 822
				Color(36, 44, 56, 245) -- 822
			) -- 822
			fgDraw:drawRect( -- 823
				Rect( -- 823
					deskCx - deskW * 0.5, -- 823
					groundY, -- 823
					cam:len(6), -- 823
					deskH -- 823
				), -- 823
				Color(74, 48, 30, 255) -- 823
			) -- 823
			fgDraw:drawRect( -- 824
				Rect( -- 824
					deskCx + deskW * 0.5 - cam:len(6), -- 824
					groundY, -- 824
					cam:len(6), -- 824
					deskH -- 824
				), -- 824
				Color(74, 48, 30, 255) -- 824
			) -- 824
			fgDraw:drawRect( -- 825
				Rect( -- 825
					deskCx - deskW * 0.52, -- 825
					deskTop - cam:len(6), -- 825
					deskW * 1.04, -- 825
					cam:len(8) -- 825
				), -- 825
				Color(102, 68, 42, 255), -- 825
				1, -- 825
				Color(146, 106, 66, 220) -- 825
			) -- 825
			fgDraw:drawRect( -- 826
				Rect( -- 826
					deskCx + cam:len(4), -- 826
					deskTop + cam:len(2), -- 826
					cam:len(24), -- 826
					cam:len(5) -- 826
				), -- 826
				Color(230, 220, 196, 245) -- 826
			) -- 826
			fgDraw:drawRect( -- 827
				Rect( -- 827
					deskCx + cam:len(32), -- 827
					deskTop + cam:len(2), -- 827
					cam:len(8), -- 827
					cam:len(12) -- 827
				), -- 827
				Color(166, 126, 62, 245) -- 827
			) -- 827
			fgGlow:drawCircle( -- 828
				Vec2( -- 828
					deskCx + cam:len(36), -- 828
					deskTop + cam:len(16) -- 828
				), -- 828
				cam:len(5.5), -- 828
				Color( -- 828
					255, -- 828
					224, -- 828
					152, -- 828
					math.floor(220 * pulse + 0.5) -- 828
				) -- 828
			) -- 828
			if p.deskHold >= 12 or p.towerHanded then -- 828
				fgDraw:drawRect( -- 830
					Rect( -- 830
						deskCx - cam:len(28), -- 830
						deskTop + cam:len(2), -- 830
						cam:len(14), -- 830
						cam:len(6) -- 830
					), -- 830
					Color(156, 62, 48, 245) -- 830
				) -- 830
			end -- 830
			if p.deskHold >= 24 or p.towerHanded then -- 830
				fgDraw:drawCircle( -- 833
					Vec2( -- 833
						deskCx - cam:len(8), -- 833
						deskTop + cam:len(5) -- 833
					), -- 833
					cam:len(4.5), -- 833
					Color(224, 186, 98, 255) -- 833
				) -- 833
				fgDraw:drawRect( -- 834
					Rect( -- 834
						deskCx - cam:len(16), -- 834
						deskTop + cam:len(2), -- 834
						cam:len(10), -- 834
						cam:len(3) -- 834
					), -- 834
					Color(236, 228, 206, 240) -- 834
				) -- 834
			end -- 834
		end -- 834
		return true -- 837
	end -- 837
	return false -- 839
end -- 787
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 843
	local p = ctx.p -- 844
	local cam = ctx.cam -- 845
	local c = p.room.cart -- 846
	if c.bodyW <= 0 then -- 846
		return true -- 848
	end -- 848
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 850
	local halfW = c.bodyW * 0.5 -- 851
	local axleX = p.cartAxle -- 852
	local axleY = c.baseY + c.wheelR -- 853
	local bodyBot = axleY + 2 -- 854
	local bodyTop = bodyBot + c.bodyH -- 855
	scene:addBox({ -- 858
		x0 = axleX - halfW, -- 859
		x1 = axleX + halfW, -- 860
		y0 = bodyBot, -- 861
		y1 = bodyTop, -- 862
		z0 = -12, -- 863
		z1 = 14, -- 864
		material = MING_MATERIALS.mingTimber, -- 865
		bucket = LP_BUCKET.PROP, -- 866
		highlightTopEdge = true, -- 867
		edgeWidth = 1 -- 868
	}) -- 868
	scene:addBox({ -- 871
		x0 = axleX - halfW - 1, -- 872
		x1 = axleX + halfW + 1, -- 873
		y0 = bodyBot + 4, -- 874
		y1 = bodyBot + 8, -- 875
		z0 = -13, -- 876
		z1 = 15, -- 877
		material = MING_MATERIALS.mingIron, -- 878
		bucket = LP_BUCKET.PROP, -- 879
		sortBias = 0.08 -- 880
	}) -- 880
	local handleX = axleX + c.handleOffset -- 883
	scene:addBox({ -- 884
		x0 = axleX + halfW - 2, -- 885
		x1 = handleX, -- 886
		y0 = bodyTop - 6, -- 887
		y1 = bodyTop - 1, -- 888
		z0 = -10, -- 889
		z1 = -4, -- 890
		material = MING_MATERIALS.mingTimber, -- 891
		bucket = LP_BUCKET.PROP, -- 892
		sortBias = 0.12, -- 893
		highlightTopEdge = true -- 894
	}) -- 894
	scene:addBox({ -- 896
		x0 = handleX - 3, -- 897
		x1 = handleX + 3, -- 898
		y0 = bodyTop - 8, -- 899
		y1 = bodyTop + 2, -- 900
		z0 = -11, -- 901
		z1 = 9, -- 902
		material = MING_MATERIALS.mingTimber, -- 903
		bucket = LP_BUCKET.PROP, -- 904
		sortBias = 0.14, -- 905
		highlightTopEdge = true -- 906
	}) -- 906
	local clothX = axleX - halfW -- 910
	local clothTop = bodyTop + 1 -- 911
	scene:addWavingQuad3D( -- 912
		vec3(clothX - 15, clothTop - 23, -14), -- 913
		vec3(clothX + 2, clothTop - 21, -12), -- 914
		vec3(clothX + 11, clothTop, -11), -- 915
		vec3(clothX - 2, clothTop + 1, -12), -- 916
		MING_MATERIALS.mingRedCloth, -- 917
		{ -- 918
			ampX = 6.2, -- 918
			ampY = 2.4, -- 918
			phase = self.animTime * 3.1, -- 918
			freqU = 1.7, -- 918
			freqV = 2.6, -- 918
			pin = "top" -- 918
		}, -- 918
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, subdivX = 3, subdivY = 4} -- 919
	) -- 919
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 922
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 925
	local wheelR = cam:len(c.wheelR) -- 926
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 927
	local wi = 0 -- 928
	do -- 928
		wi = 0 -- 929
		while wi < #wheelXs do -- 929
			local wp = projectWorld3D( -- 930
				wheelXs[wi + 1], -- 930
				axleY, -- 930
				-10, -- 930
				cam, -- 930
				self.outsideProj -- 930
			) -- 930
			fgDraw:drawCircle( -- 931
				Vec2(wp.x, wp.y), -- 931
				wheelR, -- 931
				Color(52, 40, 32, 255) -- 931
			) -- 931
			fgDraw:drawRing( -- 932
				Vec2(wp.x, wp.y), -- 932
				math.max(1, wheelR - 2.6), -- 932
				wheelR, -- 932
				Color(0, 0, 0, 0), -- 932
				1.4, -- 932
				Color(148, 126, 102, 220) -- 932
			) -- 932
			local sp = 0 -- 933
			do -- 933
				sp = 0 -- 934
				while sp < 4 do -- 934
					local a = rollAngle + sp * math.pi / 4 -- 935
					local dx = math.cos(a) * (wheelR - 2) -- 936
					local dy = math.sin(a) * (wheelR - 2) -- 937
					fgDraw:drawSegment( -- 938
						Vec2(wp.x - dx, wp.y - dy), -- 938
						Vec2(wp.x + dx, wp.y + dy), -- 938
						1, -- 938
						Color(118, 92, 70, 210) -- 938
					) -- 938
					sp = sp + 1 -- 934
				end -- 934
			end -- 934
			fgDraw:drawDot( -- 940
				Vec2(wp.x, wp.y), -- 940
				2.4, -- 940
				Color(172, 160, 144, 230) -- 940
			) -- 940
			wi = wi + 1 -- 929
		end -- 929
	end -- 929
	local patchP = projectWorld3D( -- 944
		clothX + 1, -- 944
		clothTop - 7, -- 944
		-13, -- 944
		cam, -- 944
		self.outsideProj -- 944
	) -- 944
	fgDraw:drawSegment( -- 945
		Vec2(patchP.x - 3, patchP.y), -- 945
		Vec2(patchP.x + 3, patchP.y - 2), -- 945
		1, -- 945
		Color(224, 212, 188, 215) -- 945
	) -- 945
	fgDraw:drawSegment( -- 946
		Vec2(patchP.x - 2, patchP.y - 4), -- 946
		Vec2(patchP.x + 2, patchP.y - 5), -- 946
		0.9, -- 946
		Color(224, 212, 188, 195) -- 946
	) -- 946
	return true -- 948
end -- 843
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 951
	if not self.active then -- 951
		return -- 958
	end -- 958
	local key = ctx.p.room.key -- 960
	if key == "village" then -- 960
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 962
	elseif key == "forest" then -- 962
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 964
	end -- 964
end -- 951
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 972
	if not self.active then -- 972
		return false -- 980
	end -- 980
	local key = ctx.p.room.key -- 982
	if key == "village" then -- 982
		return self.village:drawForegroundOverlay( -- 984
			uiDraw, -- 984
			uiInkDraw, -- 984
			uiArt, -- 984
			uiGlow, -- 984
			ctx -- 984
		) -- 984
	end -- 984
	if key == "forest" then -- 984
		return self.forest:drawForegroundOverlay( -- 987
			uiDraw, -- 987
			uiInkDraw, -- 987
			uiArt, -- 987
			uiGlow, -- 987
			ctx -- 987
		) -- 987
	end -- 987
	if key == "outside" then -- 987
		self:drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiGlow, ctx) -- 990
		return false -- 991
	end -- 991
	return false -- 993
end -- 972
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1000
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1000
		return -- 1007
	end -- 1007
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1009
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1011
	if alpha <= 0.01 then -- 1011
		return -- 1013
	end -- 1013
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1015
	local handPt = projectWorld3D( -- 1016
		self.memoryAnchorWorldX, -- 1016
		self.memoryAnchorWorldY, -- 1016
		0, -- 1016
		ctx.cam, -- 1016
		self.outsideProj -- 1016
	) -- 1016
	local cx = math.max( -- 1018
		160, -- 1018
		math.min(ctx.uiW - 160, handPt.x * inv - 24) -- 1018
	) -- 1018
	local cy = math.max( -- 1019
		150, -- 1019
		math.min(ctx.uiH - 130, handPt.y * inv + 96) -- 1019
	) -- 1019
	local rx = 122 -- 1020
	local ry = 74 -- 1021
	fillRadialGlow( -- 1024
		uiGlow, -- 1024
		cx, -- 1024
		cy, -- 1024
		rx * 1.55, -- 1024
		ry * 1.55, -- 1024
		Color( -- 1024
			238, -- 1024
			190, -- 1024
			122, -- 1024
			math.floor(92 * alpha + 0.5) -- 1024
		), -- 1024
		Color(218, 162, 92, 0), -- 1024
		22 -- 1024
	) -- 1024
	uiDraw:drawEllipse( -- 1025
		Vec2(cx, cy), -- 1025
		rx * 1.12, -- 1025
		ry * 1.12, -- 1025
		Color( -- 1025
			36, -- 1025
			26, -- 1025
			20, -- 1025
			math.floor(128 * alpha + 0.5) -- 1025
		) -- 1025
	) -- 1025
	uiDraw:drawEllipse( -- 1026
		Vec2(cx, cy), -- 1026
		rx * 0.96, -- 1026
		ry * 0.96, -- 1026
		Color( -- 1026
			32, -- 1026
			22, -- 1026
			16, -- 1026
			math.floor(206 * alpha + 0.5) -- 1026
		) -- 1026
	) -- 1026
	uiDraw:drawPolygon( -- 1029
		{ -- 1029
			Vec2(cx - 72, cy - 34), -- 1030
			Vec2(cx + 62, cy - 28), -- 1031
			Vec2(cx + 70, cy + 32), -- 1032
			Vec2(cx - 64, cy + 28) -- 1033
		}, -- 1033
		Color( -- 1034
			148, -- 1034
			44, -- 1034
			40, -- 1034
			math.floor(230 * alpha + 0.5) -- 1034
		) -- 1034
	) -- 1034
	uiDraw:drawPolygon( -- 1035
		{ -- 1035
			Vec2(cx - 28, cy - 18), -- 1036
			Vec2(cx + 26, cy - 14), -- 1037
			Vec2(cx + 22, cy + 20), -- 1038
			Vec2(cx - 24, cy + 16) -- 1039
		}, -- 1039
		Color( -- 1040
			172, -- 1040
			62, -- 1040
			54, -- 1040
			math.floor(238 * alpha + 0.5) -- 1040
		), -- 1040
		1, -- 1040
		Color( -- 1040
			224, -- 1040
			210, -- 1040
			184, -- 1040
			math.floor(170 * alpha + 0.5) -- 1040
		) -- 1040
	) -- 1040
	local si = 0 -- 1043
	do -- 1043
		si = 0 -- 1044
		while si < 4 do -- 1044
			local sx = cx - 18 + si * 11 -- 1045
			uiInkDraw:drawSegment( -- 1046
				Vec2(sx, cy - 15), -- 1046
				Vec2(sx + 4, cy - 9), -- 1046
				1.3, -- 1046
				Color( -- 1046
					236, -- 1046
					224, -- 1046
					198, -- 1046
					math.floor(235 * alpha + 0.5) -- 1046
				) -- 1046
			) -- 1046
			si = si + 1 -- 1044
		end -- 1044
	end -- 1044
	local pullT = smoothstep(0.14, 0.82, prog) -- 1050
	local stitchAnchorX = cx + 22 -- 1051
	local stitchAnchorY = cy - 12 -- 1052
	local handX = cx + 32 + pullT * 34 -- 1053
	local handY = cy + 6 + pullT * 26 -- 1054
	local midX = (stitchAnchorX + handX) * 0.5 + (1 - pullT) * 10 -- 1057
	local midY = (stitchAnchorY + handY) * 0.5 - (1 - pullT) * 12 -- 1058
	uiInkDraw:drawSegment( -- 1059
		Vec2(stitchAnchorX, stitchAnchorY), -- 1059
		Vec2(midX, midY), -- 1059
		1.2, -- 1059
		Color( -- 1059
			242, -- 1059
			234, -- 1059
			214, -- 1059
			math.floor(240 * alpha + 0.5) -- 1059
		) -- 1059
	) -- 1059
	uiInkDraw:drawSegment( -- 1060
		Vec2(midX, midY), -- 1060
		Vec2(handX - 6, handY - 2), -- 1060
		1.2, -- 1060
		Color( -- 1060
			242, -- 1060
			234, -- 1060
			214, -- 1060
			math.floor(240 * alpha + 0.5) -- 1060
		) -- 1060
	) -- 1060
	uiInkDraw:drawSegment( -- 1063
		Vec2(handX - 16, handY - 8), -- 1063
		Vec2(handX + 2, handY + 4), -- 1063
		1.1, -- 1063
		Color( -- 1063
			230, -- 1063
			236, -- 1063
			242, -- 1063
			math.floor(225 * alpha + 0.5) -- 1063
		) -- 1063
	) -- 1063
	uiDraw:drawPolygon( -- 1066
		{ -- 1066
			Vec2(handX - 8, handY - 6), -- 1067
			Vec2(handX + 18, handY + 2), -- 1068
			Vec2(handX + 24, handY + 14), -- 1069
			Vec2(handX + 4, handY + 14), -- 1070
			Vec2(handX - 10, handY + 4) -- 1071
		}, -- 1071
		Color( -- 1072
			214, -- 1072
			174, -- 1072
			142, -- 1072
			math.floor(225 * alpha + 0.5) -- 1072
		), -- 1072
		1, -- 1072
		Color( -- 1072
			142, -- 1072
			102, -- 1072
			78, -- 1072
			math.floor(180 * alpha + 0.5) -- 1072
		) -- 1072
	) -- 1072
	uiDraw:drawEllipse( -- 1074
		Vec2(cx - 20, cy + 4), -- 1074
		16, -- 1074
		9, -- 1074
		Color( -- 1074
			204, -- 1074
			164, -- 1074
			134, -- 1074
			math.floor(220 * alpha + 0.5) -- 1074
		) -- 1074
	) -- 1074
end -- 1000
function ____exports.createLowpolyWorldPlugin() -- 1078
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1079
end -- 1078
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1083
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1086
	fe:registerPlugin(lowpolyWorld) -- 1087
	return {lowpolyWorld = lowpolyWorld} -- 1088
end -- 1083
return ____exports -- 1083