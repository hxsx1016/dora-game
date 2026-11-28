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
	scene:addCutout3D( -- 405
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 405
		ox + 280, -- 405
		96, -- 405
		224, -- 405
		152, -- 405
		100, -- 405
		{ -- 405
			bucket = LP_BUCKET.BACKDROP, -- 406
			anchorX = 0.5, -- 407
			anchorY = 0, -- 408
			color = rgba(114, 134, 156, 255), -- 409
			opacity = 0.84, -- 410
			sortBias = 0.05 -- 411
		} -- 411
	) -- 411
	scene:addCutout3D( -- 413
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 413
		ox + 810, -- 413
		96, -- 413
		226, -- 413
		148, -- 413
		98, -- 413
		{ -- 413
			bucket = LP_BUCKET.BACKDROP, -- 414
			facing = -1, -- 415
			anchorX = 0.5, -- 416
			anchorY = 0, -- 417
			color = rgba(108, 128, 152, 255), -- 418
			opacity = 0.8, -- 419
			sortBias = 0.05 -- 420
		} -- 420
	) -- 420
	scene:addCutout3D( -- 422
		"assets/art/diorama_cutouts.clip|north_tower_distant", -- 422
		ox + 1140, -- 422
		48, -- 422
		405, -- 422
		118, -- 422
		150, -- 422
		{ -- 422
			bucket = LP_BUCKET.BACKDROP, -- 423
			anchorX = 0.5, -- 424
			anchorY = 0, -- 425
			color = rgba(136, 156, 178, 255), -- 426
			opacity = 0.9, -- 427
			sortBias = 0.08 -- 428
		} -- 428
	) -- 428
	scene:addFogBand( -- 430
		ox - 180, -- 430
		ox + 1420, -- 430
		-34, -- 430
		152, -- 430
		180, -- 430
		rgba(28, 42, 60, 255), -- 430
		0.58, -- 430
		0.06, -- 430
		{bucket = LP_BUCKET.BACKDROP} -- 430
	) -- 430
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 433
	local moonX = w * 0.76 -- 436
	local moonY = h * 0.83 -- 437
	fillRadialGlow( -- 438
		bgGlow, -- 438
		moonX, -- 438
		moonY, -- 438
		82, -- 438
		82, -- 438
		Color(172, 206, 232, 28), -- 438
		Color(24, 42, 68, 0), -- 438
		16 -- 438
	) -- 438
	bgDraw:drawCircle( -- 439
		Vec2(moonX, moonY), -- 439
		14, -- 439
		Color(218, 232, 246, 165) -- 439
	) -- 439
	local beaconP = projectWorld3D( -- 441
		ox + 1140, -- 441
		154, -- 441
		410, -- 441
		cam, -- 441
		self.outsideProj -- 441
	) -- 441
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 442
	fillRadialGlow( -- 443
		bgGlow, -- 443
		beaconP.x, -- 443
		beaconP.y, -- 443
		32 * pulse, -- 443
		32 * pulse, -- 443
		Color( -- 443
			246, -- 443
			208, -- 443
			138, -- 443
			math.floor(92 * pulse + 0.5) -- 443
		), -- 443
		Color(232, 176, 86, 0), -- 443
		14 -- 443
	) -- 443
	bgGlow:drawDot( -- 444
		Vec2(beaconP.x, beaconP.y), -- 444
		2.5, -- 444
		Color(255, 244, 212, 235) -- 444
	) -- 444
	return true -- 446
end -- 362
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, ctx) -- 449
	local cam = ctx.cam -- 450
	local p = ctx.p -- 451
	local ox = p.ox -- 452
	local w = cam.viewW -- 453
	local h = cam.viewH -- 454
	local splitY = h * 0.46 -- 457
	fillVGradRect( -- 458
		bgDraw, -- 458
		0, -- 458
		splitY, -- 458
		w, -- 458
		h - splitY, -- 458
		Color(24, 34, 52, 255), -- 458
		Color(12, 18, 30, 255) -- 458
	) -- 458
	fillVGradRect( -- 459
		bgDraw, -- 459
		0, -- 459
		0, -- 459
		w, -- 459
		splitY, -- 459
		Color(46, 54, 70, 255), -- 459
		Color(24, 34, 52, 255) -- 459
	) -- 459
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 461
	scene:addDistantRidge( -- 462
		{ -- 463
			{x = ox - 180, y = 118}, -- 464
			{x = ox + 90, y = 172}, -- 465
			{x = ox + 360, y = 146}, -- 466
			{x = ox + 640, y = 184}, -- 467
			{x = ox + 920, y = 132} -- 468
		}, -- 468
		-40, -- 468
		420, -- 471
		MING_MATERIALS.distantHill, -- 472
		{bucket = LP_BUCKET.BACKDROP} -- 473
	) -- 473
	scene:addFogBand( -- 475
		ox - 160, -- 475
		ox + 900, -- 475
		-24, -- 475
		150, -- 475
		260, -- 475
		rgba(36, 42, 58, 255), -- 475
		0.56, -- 475
		0.06, -- 475
		{bucket = LP_BUCKET.BACKDROP} -- 475
	) -- 475
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 478
	return true -- 480
end -- 449
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 483
	if not self.active then -- 483
		return false -- 490
	end -- 490
	local key = ctx.p.room.key -- 492
	if key == "village" then -- 492
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 494
	end -- 494
	if key == "forest" then -- 494
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 497
	end -- 497
	if key == "outside" then -- 497
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 500
	end -- 500
	if key == "tower" then -- 500
		return self:drawTowerWorld(fgDraw, fgGlow, ctx) -- 503
	end -- 503
	return false -- 505
end -- 483
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, ctx) -- 508
	local p = ctx.p -- 509
	local cam = ctx.cam -- 510
	local ox = p.ox -- 511
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 512
	buildOutsideJettyLowpoly( -- 515
		scene, -- 515
		p.room, -- 515
		p.player.x, -- 515
		p.player.y, -- 515
		p.cartAxle, -- 515
		self.animTime -- 515
	) -- 515
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
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 626
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
	return true -- 637
end -- 508
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 640
	local p = ctx.p -- 641
	local cam = ctx.cam -- 642
	local ox = p.ox -- 643
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 644
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 649
	scene:addBox({ -- 652
		x0 = ox - 40, -- 653
		x1 = ox + 760, -- 654
		y0 = -52, -- 655
		y1 = 0, -- 656
		z0 = -26, -- 657
		z1 = 96, -- 658
		material = MING_MATERIALS.mingBrickDark, -- 659
		bucket = LP_BUCKET.WALK_DECK, -- 660
		highlightTopEdge = true -- 661
	}) -- 661
	scene:addBox({ -- 664
		x0 = ox + 398, -- 665
		x1 = ox + 492, -- 666
		y0 = -4, -- 667
		y1 = 2.5, -- 668
		z0 = -16, -- 669
		z1 = 26, -- 670
		material = MING_MATERIALS.mingStoneStep, -- 671
		bucket = LP_BUCKET.WALK_DECK, -- 672
		sortBias = 0.15, -- 673
		highlightTopEdge = true -- 674
	}) -- 674
	scene:addBox({ -- 678
		x0 = ox + 180, -- 679
		x1 = ox + 400, -- 680
		y0 = 0, -- 681
		y1 = 215, -- 682
		z0 = -8, -- 683
		z1 = 96, -- 684
		material = MING_MATERIALS.mingBrick, -- 685
		bucket = LP_BUCKET.MIDGROUND, -- 686
		highlightTopEdge = true -- 687
	}) -- 687
	if not opened then -- 687
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
	else -- 699
		scene:addBox({ -- 703
			x0 = ox + 490, -- 704
			x1 = ox + 706, -- 705
			y0 = 0, -- 706
			y1 = 146, -- 707
			z0 = 46, -- 708
			z1 = 96, -- 709
			material = MING_MATERIALS.mingTimberDark, -- 710
			bucket = LP_BUCKET.BACKDROP, -- 711
			edgeWidth = 0.8 -- 712
		}) -- 712
		scene:addBox({ -- 714
			x0 = ox + 490, -- 715
			x1 = ox + 706, -- 716
			y0 = -3, -- 717
			y1 = 2, -- 718
			z0 = -18, -- 719
			z1 = 48, -- 720
			material = MING_MATERIALS.mingTimber, -- 721
			bucket = LP_BUCKET.WALK_DECK, -- 722
			sortBias = 0.12, -- 723
			highlightTopEdge = true -- 724
		}) -- 724
		scene:addBox({ -- 727
			x0 = ox + 490, -- 728
			x1 = ox + 720, -- 729
			y0 = 144, -- 730
			y1 = 215, -- 731
			z0 = -8, -- 732
			z1 = 96, -- 733
			material = MING_MATERIALS.mingBrick, -- 734
			bucket = LP_BUCKET.MIDGROUND, -- 735
			highlightTopEdge = true -- 736
		}) -- 736
		scene:addBox({ -- 738
			x0 = ox + 490, -- 739
			x1 = ox + 704, -- 740
			y0 = 132, -- 741
			y1 = 145, -- 742
			z0 = -4, -- 743
			z1 = 48, -- 744
			material = MING_MATERIALS.mingTimberDark, -- 745
			bucket = LP_BUCKET.MIDGROUND, -- 746
			sortBias = 0.08 -- 747
		}) -- 747
		scene:addBox({ -- 750
			x0 = ox + 702, -- 751
			x1 = ox + 724, -- 752
			y0 = 0, -- 753
			y1 = 146, -- 754
			z0 = -8, -- 755
			z1 = 96, -- 756
			material = MING_MATERIALS.mingBrickDark, -- 757
			bucket = LP_BUCKET.MIDGROUND, -- 758
			highlightTopEdge = true -- 759
		}) -- 759
		scene:addQuad3D( -- 762
			vec3(ox + 544, 52, 45), -- 763
			vec3(ox + 662, 52, 45), -- 764
			vec3(ox + 662, 118, 45), -- 765
			vec3(ox + 544, 118, 45), -- 766
			{base = rgba(88, 62, 38, 255)}, -- 767
			{ -- 768
				bucket = LP_BUCKET.BACKDROP, -- 768
				unlit = true, -- 768
				sortBias = 0.12, -- 768
				edgeColor = rgba(132, 98, 62, 210), -- 768
				edgeWidth = 1 -- 768
			} -- 768
		) -- 768
		scene:addBox({ -- 771
			x0 = ox + 564, -- 772
			x1 = ox + 646, -- 773
			y0 = 28, -- 774
			y1 = 35, -- 775
			z0 = 10, -- 776
			z1 = 36, -- 777
			material = MING_MATERIALS.mingTimber, -- 778
			bucket = LP_BUCKET.PROP, -- 779
			sortBias = 0.12, -- 780
			highlightTopEdge = true -- 781
		}) -- 781
		scene:addBox({ -- 783
			x0 = ox + 568, -- 784
			x1 = ox + 576, -- 785
			y0 = 0, -- 786
			y1 = 28, -- 787
			z0 = 12, -- 788
			z1 = 32, -- 789
			material = MING_MATERIALS.mingTimberDark, -- 790
			bucket = LP_BUCKET.PROP, -- 791
			sortBias = 0.06 -- 792
		}) -- 792
		scene:addBox({ -- 794
			x0 = ox + 634, -- 795
			x1 = ox + 642, -- 796
			y0 = 0, -- 797
			y1 = 28, -- 798
			z0 = 12, -- 799
			z1 = 32, -- 800
			material = MING_MATERIALS.mingTimberDark, -- 801
			bucket = LP_BUCKET.PROP, -- 802
			sortBias = 0.06 -- 803
		}) -- 803
	end -- 803
	scene:addBeveledFrame( -- 808
		ox + 400, -- 808
		ox + 490, -- 808
		0, -- 808
		110, -- 808
		14, -- 808
		34, -- 808
		-8, -- 808
		68, -- 808
		MING_MATERIALS.mingStoneStep, -- 808
		{ -- 808
			bucket = LP_BUCKET.MIDGROUND, -- 809
			innerRimLight = rgba(244, 206, 140, 255), -- 810
			innerRimStrength = opened and 0.78 or 0.32 -- 811
		} -- 811
	) -- 811
	scene:addCutout3D( -- 815
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 815
		ox + 445, -- 815
		206, -- 815
		18, -- 815
		240, -- 815
		142, -- 815
		{ -- 815
			bucket = LP_BUCKET.MIDGROUND, -- 816
			anchorX = 0.5, -- 817
			anchorY = 0, -- 818
			color = rgba(154, 168, 184, 255), -- 819
			opacity = 0.92, -- 820
			sortBias = 0.08 -- 821
		} -- 821
	) -- 821
	if not opened then -- 821
		scene:addCutout3D( -- 826
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 826
			ox + 445, -- 826
			2, -- 826
			14, -- 826
			84, -- 826
			108, -- 826
			{ -- 826
				bucket = LP_BUCKET.MIDGROUND, -- 827
				anchorX = 0.5, -- 828
				anchorY = 0, -- 829
				color = rgba(186, 182, 176, 255), -- 830
				opacity = 0.98, -- 831
				sortBias = 0.14 -- 832
			} -- 832
		) -- 832
	else -- 832
		scene:addQuad3D( -- 835
			vec3(ox + 404, 2, 24), -- 836
			vec3(ox + 486, 2, 24), -- 837
			vec3(ox + 486, 109, 24), -- 838
			vec3(ox + 404, 109, 24), -- 839
			{base = rgba(112, 78, 42, 255)}, -- 840
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 841
		) -- 841
	end -- 841
	scene:addQuad3D( -- 846
		vec3(ox + 286, 118, -9), -- 847
		vec3(ox + 306, 118, -9), -- 848
		vec3(ox + 306, 158, -9), -- 849
		vec3(ox + 286, 158, -9), -- 850
		{base = rgba(244, 204, 134, 255)}, -- 851
		{ -- 852
			bucket = LP_BUCKET.PROP, -- 852
			unlit = true, -- 852
			edgeColor = rgba(82, 68, 52, 255), -- 852
			edgeWidth = 1.4 -- 852
		} -- 852
	) -- 852
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 856
	scene:addLightShaft( -- 857
		ox + 412, -- 858
		ox + 478, -- 858
		106, -- 858
		ox + 382, -- 859
		ox + 506, -- 859
		0, -- 859
		6, -- 860
		rgba(246, 208, 138, 255), -- 861
		(opened and 0.34 or 0.08) * pulse, -- 862
		(opened and 0.16 or 0.04) * pulse -- 863
	) -- 863
	scene:addContactShadow( -- 867
		p.player.x, -- 867
		p.player.y, -- 867
		15, -- 867
		11, -- 867
		0.78, -- 867
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 867
	) -- 867
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 869
	local lampP = projectWorld3D( -- 872
		ox + 445, -- 872
		102, -- 872
		2, -- 872
		cam, -- 872
		self.towerProj -- 872
	) -- 872
	fillRadialGlow( -- 873
		fgGlow, -- 874
		lampP.x, -- 875
		lampP.y, -- 876
		cam:len(opened and 64 or 34) * pulse, -- 877
		cam:len(opened and 64 or 34) * pulse, -- 878
		Color( -- 879
			248, -- 879
			214, -- 879
			146, -- 879
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 879
		), -- 879
		Color(232, 174, 82, 0), -- 880
		16 -- 881
	) -- 881
	fgDraw:drawCircle( -- 883
		Vec2(lampP.x, lampP.y), -- 883
		4.2, -- 883
		Color(255, 240, 202, 245) -- 883
	) -- 883
	local winP = projectWorld3D( -- 885
		ox + 296, -- 885
		138, -- 885
		-9, -- 885
		cam, -- 885
		self.towerProj -- 885
	) -- 885
	fillRadialGlow( -- 886
		fgGlow, -- 886
		winP.x, -- 886
		winP.y, -- 886
		cam:len(38), -- 886
		cam:len(42), -- 886
		Color( -- 886
			246, -- 886
			206, -- 886
			132, -- 886
			math.floor(78 * pulse + 0.5) -- 886
		), -- 886
		Color(232, 174, 82, 0), -- 886
		14 -- 886
	) -- 886
	local wBL = projectWorld3D( -- 888
		ox + 286, -- 888
		118, -- 888
		-9, -- 888
		cam, -- 888
		self.towerProj -- 888
	) -- 888
	local wTR = projectWorld3D( -- 889
		ox + 306, -- 889
		158, -- 889
		-9, -- 889
		cam, -- 889
		self.towerProj -- 889
	) -- 889
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 890
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 891
	fgDraw:drawSegment( -- 892
		Vec2(wMidX, wBL.y), -- 892
		Vec2(wMidX, wTR.y), -- 892
		1.4, -- 892
		Color(68, 52, 38, 225) -- 892
	) -- 892
	fgDraw:drawSegment( -- 893
		Vec2(wBL.x, wMidY), -- 893
		Vec2(wTR.x, wMidY), -- 893
		1.4, -- 893
		Color(68, 52, 38, 225) -- 893
	) -- 893
	return true -- 895
end -- 640
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 898
	if not self.active then -- 898
		return false -- 905
	end -- 905
	local key = ctx.p.room.key -- 907
	if key == "village" then -- 907
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 909
	end -- 909
	if key == "forest" then -- 909
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 912
	end -- 912
	if key == "outside" then -- 912
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 915
	end -- 915
	if key == "tower" then -- 915
		local p = ctx.p -- 918
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 919
		if opened then -- 919
			local cam = ctx.cam -- 921
			local deskTopP = projectWorld3D( -- 922
				p.ox + 605, -- 922
				35, -- 922
				22, -- 922
				cam, -- 922
				self.towerProj -- 922
			) -- 922
			local guardBaseP = projectWorld3D( -- 923
				p.ox + 626, -- 923
				0, -- 923
				38, -- 923
				cam, -- 923
				self.towerProj -- 923
			) -- 923
			local deskCx = deskTopP.x -- 924
			local deskTop = deskTopP.y -- 925
			local s = deskTopP.scale -- 926
			local gs = guardBaseP.scale -- 927
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 928
			fillRadialGlow( -- 929
				fgGlow, -- 929
				deskCx, -- 929
				deskTop + cam:len(26) * s, -- 929
				cam:len(132) * s, -- 929
				cam:len(96) * s, -- 929
				Color( -- 930
					255, -- 930
					198, -- 930
					114, -- 930
					math.floor(82 * pulse + 0.5) -- 930
				), -- 930
				Color(255, 168, 72, 0), -- 930
				16 -- 930
			) -- 930
			local writing = p.deskHold >= 24 or p.towerHanded -- 932
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 933
			if not worldArt:tryPlacePath( -- 933
				guardClip, -- 936
				"fe04_tower_guard_npc", -- 936
				guardBaseP.x, -- 936
				guardBaseP.y, -- 936
				cam:len(54) * gs, -- 936
				cam:len(82) * gs, -- 936
				{ -- 936
					anchorX = 0.44, -- 937
					anchorY = 0, -- 938
					preserveAspect = true, -- 939
					facing = -1, -- 940
					opacity = 0.96, -- 941
					layer = 3600 -- 942
				} -- 942
			) then -- 942
				fgDraw:drawRect( -- 944
					Rect( -- 944
						guardBaseP.x - cam:len(11) * gs, -- 944
						guardBaseP.y, -- 944
						cam:len(22) * gs, -- 944
						cam:len(68) * gs -- 944
					), -- 944
					Color(28, 34, 44, 242) -- 944
				) -- 944
				fgDraw:drawCircle( -- 945
					Vec2( -- 945
						guardBaseP.x, -- 945
						guardBaseP.y + cam:len(76) * gs -- 945
					), -- 945
					cam:len(9.5) * gs, -- 945
					Color(36, 44, 56, 248) -- 945
				) -- 945
			end -- 945
			fgDraw:drawRect( -- 948
				Rect( -- 948
					deskCx + cam:len(4) * s, -- 948
					deskTop + cam:len(1) * s, -- 948
					cam:len(24) * s, -- 948
					cam:len(5) * s -- 948
				), -- 948
				Color(230, 220, 196, 245) -- 948
			) -- 948
			if writing then -- 948
				if not worldArt:tryPlace( -- 948
					"prop_lantern", -- 950
					"fe04_tower_desk_lamp", -- 950
					deskCx + cam:len(34) * s, -- 950
					deskTop + cam:len(10) * s, -- 950
					cam:len(14) * s, -- 950
					cam:len(20) * s, -- 950
					{opacity = 0.96, layer = 3700} -- 950
				) then -- 950
					fgDraw:drawRect( -- 954
						Rect( -- 954
							deskCx + cam:len(30) * s, -- 954
							deskTop + cam:len(1) * s, -- 954
							cam:len(8) * s, -- 954
							cam:len(12) * s -- 954
						), -- 954
						Color(166, 126, 62, 245) -- 954
					) -- 954
				end -- 954
				fillRadialGlow( -- 956
					fgGlow, -- 956
					deskCx + cam:len(34) * s, -- 956
					deskTop + cam:len(14) * s, -- 956
					cam:len(26) * s, -- 956
					cam:len(22) * s, -- 956
					Color( -- 956
						255, -- 956
						214, -- 956
						134, -- 956
						math.floor(92 * pulse + 0.5) -- 956
					), -- 956
					Color(255, 180, 86, 0), -- 956
					12 -- 956
				) -- 956
			else -- 956
				fillRadialGlow( -- 958
					fgGlow, -- 958
					deskCx + cam:len(6) * s, -- 958
					deskTop + cam:len(18) * s, -- 958
					cam:len(28) * s, -- 958
					cam:len(26) * s, -- 958
					Color( -- 958
						255, -- 958
						214, -- 958
						134, -- 958
						math.floor(78 * pulse + 0.5) -- 958
					), -- 958
					Color(255, 180, 86, 0), -- 958
					12 -- 958
				) -- 958
			end -- 958
			if p.deskHold >= 12 or p.towerHanded then -- 958
				if not worldArt:tryPlacePath( -- 958
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 961
					"fe04_tower_desk_pouch", -- 961
					deskCx - cam:len(18) * s, -- 961
					deskTop + cam:len(8) * s, -- 961
					cam:len(18) * s, -- 961
					cam:len(18) * s, -- 961
					{ -- 961
						anchorX = 0.5, -- 962
						anchorY = 0.5, -- 963
						opacity = 0.95, -- 964
						smooth = true, -- 965
						layer = 3710 -- 966
					} -- 966
				) then -- 966
					fgDraw:drawRect( -- 968
						Rect( -- 968
							deskCx - cam:len(26) * s, -- 968
							deskTop + cam:len(1) * s, -- 968
							cam:len(14) * s, -- 968
							cam:len(6) * s -- 968
						), -- 968
						Color(156, 62, 48, 245) -- 968
					) -- 968
				end -- 968
			end -- 968
			if p.deskHold >= 24 or p.towerHanded then -- 968
				fgDraw:drawRect( -- 972
					Rect( -- 972
						deskCx - cam:len(4) * s, -- 972
						deskTop + cam:len(1) * s, -- 972
						cam:len(10) * s, -- 972
						cam:len(3) * s -- 972
					), -- 972
					Color(236, 228, 206, 240) -- 972
				) -- 972
			end -- 972
		end -- 972
		return true -- 975
	end -- 975
	return false -- 977
end -- 898
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 981
	local p = ctx.p -- 987
	local cam = ctx.cam -- 988
	local c = p.room.cart -- 989
	if c.bodyW <= 0 then -- 989
		return true -- 991
	end -- 991
	local halfW = c.bodyW * 0.5 -- 993
	local axleX = p.cartAxle -- 994
	local baseY = cam:sy(c.baseY) -- 995
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 996
	local cx = cam:sx(axleX) -- 997
	local artW = cam:len(c.bodyW * 1.38) -- 998
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 999
	fgDraw:drawEllipse( -- 1001
		Vec2(cx, baseY + 1), -- 1001
		cam:len(c.bodyW * 0.62), -- 1001
		4, -- 1001
		Color(6, 10, 16, 155) -- 1001
	) -- 1001
	worldArt:tryPlace( -- 1002
		"prop_cart", -- 1002
		"fe04_outside_cart", -- 1002
		cx, -- 1002
		baseY, -- 1002
		artW, -- 1002
		artH, -- 1002
		{ -- 1002
			color = Color(196, 210, 228, 255), -- 1003
			layer = 5 -- 1004
		} -- 1004
	) -- 1004
	local clothX = axleX - halfW -- 1008
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 1009
	worldArt:tryPlace( -- 1010
		"fe_red_cloth", -- 1010
		"fe04_outside_cart_cloth", -- 1010
		cam:sx(clothX + 2), -- 1010
		bodyTopY - cam:len(2), -- 1010
		cam:len(24), -- 1010
		cam:len(24), -- 1010
		{frame = clothFrame, layer = 6} -- 1010
	) -- 1010
	return true -- 1015
end -- 981
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1018
	if not self.active then -- 1018
		return -- 1025
	end -- 1025
	local key = ctx.p.room.key -- 1027
	if key == "village" then -- 1027
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1029
	elseif key == "forest" then -- 1029
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1031
	end -- 1031
end -- 1018
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1039
	if not self.active then -- 1039
		return false -- 1047
	end -- 1047
	local key = ctx.p.room.key -- 1049
	if key == "village" and ctx.cam.projection == nil then -- 1049
		return self.village:drawForegroundOverlay( -- 1051
			uiDraw, -- 1051
			uiInkDraw, -- 1051
			uiArt, -- 1051
			uiGlow, -- 1051
			ctx -- 1051
		) -- 1051
	end -- 1051
	if key == "forest" and ctx.cam.projection == nil then -- 1051
		return self.forest:drawForegroundOverlay( -- 1054
			uiDraw, -- 1054
			uiInkDraw, -- 1054
			uiArt, -- 1054
			uiGlow, -- 1054
			ctx -- 1054
		) -- 1054
	end -- 1054
	if key == "outside" then -- 1054
		self:drawOutsideSewingMemoryOverlay( -- 1057
			uiDraw, -- 1057
			uiInkDraw, -- 1057
			uiArt, -- 1057
			uiGlow, -- 1057
			ctx -- 1057
		) -- 1057
		return false -- 1058
	end -- 1058
	return false -- 1060
end -- 1039
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 1067
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1067
		return -- 1075
	end -- 1075
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1077
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1078
	if alpha <= 0.01 then -- 1078
		return -- 1080
	end -- 1080
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1082
	local handPt = ctx.cam.projection ~= nil and ctx.cam:worldToScreen(self.memoryAnchorWorldX, self.memoryAnchorWorldY) or projectWorld3D( -- 1083
		self.memoryAnchorWorldX, -- 1085
		self.memoryAnchorWorldY, -- 1085
		0, -- 1085
		ctx.cam, -- 1085
		self.outsideProj -- 1085
	) -- 1085
	local cx = math.max( -- 1086
		190, -- 1086
		math.min(ctx.uiW - 190, handPt.x * inv - 20) -- 1086
	) -- 1086
	local cy = math.max( -- 1087
		170, -- 1087
		math.min(ctx.uiH - 150, handPt.y * inv + 104) -- 1087
	) -- 1087
	local pullT = smoothstep(0.14, 0.82, prog) -- 1088
	local zoom = 0.94 + pullT * 0.09 -- 1089
	fillRadialGlow( -- 1092
		uiGlow, -- 1092
		cx, -- 1092
		cy, -- 1092
		215 * zoom, -- 1092
		152 * zoom, -- 1092
		Color( -- 1092
			238, -- 1092
			186, -- 1092
			114, -- 1092
			math.floor(88 * alpha + 0.5) -- 1092
		), -- 1092
		Color(214, 152, 82, 0), -- 1092
		22 -- 1092
	) -- 1092
	uiArt:tryPlace( -- 1093
		"ink_petal_mist", -- 1093
		"fe04_f01_memory_mist", -- 1093
		cx, -- 1093
		cy, -- 1093
		380 * zoom, -- 1093
		260 * zoom, -- 1093
		{ -- 1093
			color = Color(36, 24, 18, 255), -- 1094
			opacity = 0.72 * alpha, -- 1095
			layer = 3 -- 1096
		} -- 1096
	) -- 1096
	if not uiArt:tryPlacePath( -- 1096
		"assets/art/cutscene_story_parts.clip|f01_mother_stitch", -- 1099
		"fe04_f01_mother_stitch", -- 1100
		cx + pullT * 6, -- 1101
		cy + pullT * 4, -- 1102
		296 * zoom, -- 1103
		218 * zoom, -- 1104
		{ -- 1105
			anchorX = 0.5, -- 1106
			anchorY = 0.5, -- 1107
			color = Color(246, 224, 196, 255), -- 1108
			opacity = 0.96 * alpha, -- 1109
			smooth = true, -- 1110
			layer = 4 -- 1111
		} -- 1111
	) then -- 1111
		uiDraw:drawEllipse( -- 1114
			Vec2(cx, cy), -- 1114
			116, -- 1114
			70, -- 1114
			Color( -- 1114
				32, -- 1114
				22, -- 1114
				16, -- 1114
				math.floor(196 * alpha + 0.5) -- 1114
			) -- 1114
		) -- 1114
	end -- 1114
end -- 1067
function ____exports.createLowpolyWorldPlugin() -- 1119
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1120
end -- 1119
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1124
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1127
	fe:registerPlugin(lowpolyWorld) -- 1128
	return {lowpolyWorld = lowpolyWorld} -- 1129
end -- 1124
return ____exports -- 1124