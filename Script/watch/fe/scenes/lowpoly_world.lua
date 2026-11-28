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
	local latch = p:cartLatchBounds() -- 562
	if latch ~= nil then -- 562
		local bx0 = latch.x -- 564
		local bx1 = latch.x + latch.width -- 565
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
	scene:addBox({ -- 593
		x0 = ox + 128, -- 594
		x1 = ox + 598, -- 595
		y0 = 0, -- 596
		y1 = 92, -- 597
		z0 = 44, -- 598
		z1 = 72, -- 599
		material = MING_MATERIALS.mingBrickDark, -- 600
		bucket = LP_BUCKET.MIDGROUND, -- 601
		sortBias = -0.2, -- 602
		edgeWidth = 0.5 -- 603
	}) -- 603
	scene:addQuad3D( -- 606
		vec3(ox + 132, 26, 43), -- 607
		vec3(ox + 592, 26, 43), -- 608
		vec3(ox + 592, 31, 43), -- 609
		vec3(ox + 132, 31, 43), -- 610
		{base = rgba(138, 148, 158, 92)}, -- 611
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 612
	) -- 612
	scene:addLightShaft( -- 616
		ox + 1110, -- 617
		ox + 1180, -- 617
		170, -- 617
		ox + 1040, -- 618
		ox + 1140, -- 618
		0, -- 618
		34, -- 619
		rgba(234, 198, 138, 255), -- 620
		0.14, -- 621
		0.03 -- 622
	) -- 622
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 625
	local gi = 0 -- 628
	do -- 628
		gi = 0 -- 629
		while gi < 6 do -- 629
			local gx = ox + 165 + gi * 56 -- 630
			local p0 = projectWorld3D( -- 631
				gx, -- 631
				0.5, -- 631
				-14, -- 631
				cam, -- 631
				self.outsideProj -- 631
			) -- 631
			local p1 = projectWorld3D( -- 632
				gx + 10, -- 632
				0.5, -- 632
				22, -- 632
				cam, -- 632
				self.outsideProj -- 632
			) -- 632
			fgDraw:drawSegment( -- 633
				Vec2(p0.x, p0.y), -- 633
				Vec2(p1.x, p1.y), -- 633
				3, -- 633
				Color(8, 12, 18, 76) -- 633
			) -- 633
			gi = gi + 1 -- 629
		end -- 629
	end -- 629
	return true -- 636
end -- 508
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 639
	local p = ctx.p -- 640
	local cam = ctx.cam -- 641
	local ox = p.ox -- 642
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 643
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 648
	scene:addBox({ -- 651
		x0 = ox - 40, -- 652
		x1 = ox + 760, -- 653
		y0 = -52, -- 654
		y1 = 0, -- 655
		z0 = -26, -- 656
		z1 = 96, -- 657
		material = MING_MATERIALS.mingBrickDark, -- 658
		bucket = LP_BUCKET.WALK_DECK, -- 659
		highlightTopEdge = true -- 660
	}) -- 660
	scene:addBox({ -- 663
		x0 = ox + 398, -- 664
		x1 = ox + 492, -- 665
		y0 = -4, -- 666
		y1 = 2.5, -- 667
		z0 = -16, -- 668
		z1 = 26, -- 669
		material = MING_MATERIALS.mingStoneStep, -- 670
		bucket = LP_BUCKET.WALK_DECK, -- 671
		sortBias = 0.15, -- 672
		highlightTopEdge = true -- 673
	}) -- 673
	scene:addBox({ -- 677
		x0 = ox + 180, -- 678
		x1 = ox + 400, -- 679
		y0 = 0, -- 680
		y1 = 215, -- 681
		z0 = -8, -- 682
		z1 = 96, -- 683
		material = MING_MATERIALS.mingBrick, -- 684
		bucket = LP_BUCKET.MIDGROUND, -- 685
		highlightTopEdge = true -- 686
	}) -- 686
	if not opened then -- 686
		scene:addBox({ -- 689
			x0 = ox + 490, -- 690
			x1 = ox + 720, -- 691
			y0 = 0, -- 692
			y1 = 215, -- 693
			z0 = -8, -- 694
			z1 = 96, -- 695
			material = MING_MATERIALS.mingBrick, -- 696
			bucket = LP_BUCKET.MIDGROUND, -- 697
			highlightTopEdge = true -- 698
		}) -- 698
	else -- 698
		scene:addBox({ -- 702
			x0 = ox + 490, -- 703
			x1 = ox + 706, -- 704
			y0 = 0, -- 705
			y1 = 146, -- 706
			z0 = 46, -- 707
			z1 = 96, -- 708
			material = MING_MATERIALS.mingTimberDark, -- 709
			bucket = LP_BUCKET.BACKDROP, -- 710
			edgeWidth = 0.8 -- 711
		}) -- 711
		scene:addBox({ -- 713
			x0 = ox + 490, -- 714
			x1 = ox + 706, -- 715
			y0 = -3, -- 716
			y1 = 2, -- 717
			z0 = -18, -- 718
			z1 = 48, -- 719
			material = MING_MATERIALS.mingTimber, -- 720
			bucket = LP_BUCKET.WALK_DECK, -- 721
			sortBias = 0.12, -- 722
			highlightTopEdge = true -- 723
		}) -- 723
		scene:addBox({ -- 726
			x0 = ox + 490, -- 727
			x1 = ox + 720, -- 728
			y0 = 144, -- 729
			y1 = 215, -- 730
			z0 = -8, -- 731
			z1 = 96, -- 732
			material = MING_MATERIALS.mingBrick, -- 733
			bucket = LP_BUCKET.MIDGROUND, -- 734
			highlightTopEdge = true -- 735
		}) -- 735
		scene:addBox({ -- 737
			x0 = ox + 490, -- 738
			x1 = ox + 704, -- 739
			y0 = 132, -- 740
			y1 = 145, -- 741
			z0 = -4, -- 742
			z1 = 48, -- 743
			material = MING_MATERIALS.mingTimberDark, -- 744
			bucket = LP_BUCKET.MIDGROUND, -- 745
			sortBias = 0.08 -- 746
		}) -- 746
		scene:addBox({ -- 749
			x0 = ox + 702, -- 750
			x1 = ox + 724, -- 751
			y0 = 0, -- 752
			y1 = 146, -- 753
			z0 = -8, -- 754
			z1 = 96, -- 755
			material = MING_MATERIALS.mingBrickDark, -- 756
			bucket = LP_BUCKET.MIDGROUND, -- 757
			highlightTopEdge = true -- 758
		}) -- 758
		scene:addQuad3D( -- 761
			vec3(ox + 544, 52, 45), -- 762
			vec3(ox + 662, 52, 45), -- 763
			vec3(ox + 662, 118, 45), -- 764
			vec3(ox + 544, 118, 45), -- 765
			{base = rgba(88, 62, 38, 255)}, -- 766
			{ -- 767
				bucket = LP_BUCKET.BACKDROP, -- 767
				unlit = true, -- 767
				sortBias = 0.12, -- 767
				edgeColor = rgba(132, 98, 62, 210), -- 767
				edgeWidth = 1 -- 767
			} -- 767
		) -- 767
		scene:addBox({ -- 770
			x0 = ox + 564, -- 771
			x1 = ox + 646, -- 772
			y0 = 28, -- 773
			y1 = 35, -- 774
			z0 = 10, -- 775
			z1 = 36, -- 776
			material = MING_MATERIALS.mingTimber, -- 777
			bucket = LP_BUCKET.PROP, -- 778
			sortBias = 0.12, -- 779
			highlightTopEdge = true -- 780
		}) -- 780
		scene:addBox({ -- 782
			x0 = ox + 568, -- 783
			x1 = ox + 576, -- 784
			y0 = 0, -- 785
			y1 = 28, -- 786
			z0 = 12, -- 787
			z1 = 32, -- 788
			material = MING_MATERIALS.mingTimberDark, -- 789
			bucket = LP_BUCKET.PROP, -- 790
			sortBias = 0.06 -- 791
		}) -- 791
		scene:addBox({ -- 793
			x0 = ox + 634, -- 794
			x1 = ox + 642, -- 795
			y0 = 0, -- 796
			y1 = 28, -- 797
			z0 = 12, -- 798
			z1 = 32, -- 799
			material = MING_MATERIALS.mingTimberDark, -- 800
			bucket = LP_BUCKET.PROP, -- 801
			sortBias = 0.06 -- 802
		}) -- 802
	end -- 802
	scene:addBeveledFrame( -- 807
		ox + 400, -- 807
		ox + 490, -- 807
		0, -- 807
		110, -- 807
		14, -- 807
		34, -- 807
		-8, -- 807
		68, -- 807
		MING_MATERIALS.mingStoneStep, -- 807
		{ -- 807
			bucket = LP_BUCKET.MIDGROUND, -- 808
			innerRimLight = rgba(244, 206, 140, 255), -- 809
			innerRimStrength = opened and 0.78 or 0.32 -- 810
		} -- 810
	) -- 810
	scene:addCutout3D( -- 814
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 814
		ox + 445, -- 814
		206, -- 814
		18, -- 814
		240, -- 814
		142, -- 814
		{ -- 814
			bucket = LP_BUCKET.MIDGROUND, -- 815
			anchorX = 0.5, -- 816
			anchorY = 0, -- 817
			color = rgba(154, 168, 184, 255), -- 818
			opacity = 0.92, -- 819
			sortBias = 0.08 -- 820
		} -- 820
	) -- 820
	if not opened then -- 820
		scene:addCutout3D( -- 825
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 825
			ox + 445, -- 825
			2, -- 825
			14, -- 825
			84, -- 825
			108, -- 825
			{ -- 825
				bucket = LP_BUCKET.MIDGROUND, -- 826
				anchorX = 0.5, -- 827
				anchorY = 0, -- 828
				color = rgba(186, 182, 176, 255), -- 829
				opacity = 0.98, -- 830
				sortBias = 0.14 -- 831
			} -- 831
		) -- 831
	else -- 831
		scene:addQuad3D( -- 834
			vec3(ox + 404, 2, 24), -- 835
			vec3(ox + 486, 2, 24), -- 836
			vec3(ox + 486, 109, 24), -- 837
			vec3(ox + 404, 109, 24), -- 838
			{base = rgba(112, 78, 42, 255)}, -- 839
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 840
		) -- 840
	end -- 840
	scene:addQuad3D( -- 845
		vec3(ox + 286, 118, -9), -- 846
		vec3(ox + 306, 118, -9), -- 847
		vec3(ox + 306, 158, -9), -- 848
		vec3(ox + 286, 158, -9), -- 849
		{base = rgba(244, 204, 134, 255)}, -- 850
		{ -- 851
			bucket = LP_BUCKET.PROP, -- 851
			unlit = true, -- 851
			edgeColor = rgba(82, 68, 52, 255), -- 851
			edgeWidth = 1.4 -- 851
		} -- 851
	) -- 851
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 855
	scene:addLightShaft( -- 856
		ox + 412, -- 857
		ox + 478, -- 857
		106, -- 857
		ox + 382, -- 858
		ox + 506, -- 858
		0, -- 858
		6, -- 859
		rgba(246, 208, 138, 255), -- 860
		(opened and 0.34 or 0.08) * pulse, -- 861
		(opened and 0.16 or 0.04) * pulse -- 862
	) -- 862
	scene:addContactShadow( -- 866
		p.player.x, -- 866
		p.player.y, -- 866
		15, -- 866
		11, -- 866
		0.78, -- 866
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 866
	) -- 866
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 868
	local lampP = projectWorld3D( -- 871
		ox + 445, -- 871
		102, -- 871
		2, -- 871
		cam, -- 871
		self.towerProj -- 871
	) -- 871
	fillRadialGlow( -- 872
		fgGlow, -- 873
		lampP.x, -- 874
		lampP.y, -- 875
		cam:len(opened and 64 or 34) * pulse, -- 876
		cam:len(opened and 64 or 34) * pulse, -- 877
		Color( -- 878
			248, -- 878
			214, -- 878
			146, -- 878
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 878
		), -- 878
		Color(232, 174, 82, 0), -- 879
		16 -- 880
	) -- 880
	fgDraw:drawCircle( -- 882
		Vec2(lampP.x, lampP.y), -- 882
		4.2, -- 882
		Color(255, 240, 202, 245) -- 882
	) -- 882
	local winP = projectWorld3D( -- 884
		ox + 296, -- 884
		138, -- 884
		-9, -- 884
		cam, -- 884
		self.towerProj -- 884
	) -- 884
	fillRadialGlow( -- 885
		fgGlow, -- 885
		winP.x, -- 885
		winP.y, -- 885
		cam:len(38), -- 885
		cam:len(42), -- 885
		Color( -- 885
			246, -- 885
			206, -- 885
			132, -- 885
			math.floor(78 * pulse + 0.5) -- 885
		), -- 885
		Color(232, 174, 82, 0), -- 885
		14 -- 885
	) -- 885
	local wBL = projectWorld3D( -- 887
		ox + 286, -- 887
		118, -- 887
		-9, -- 887
		cam, -- 887
		self.towerProj -- 887
	) -- 887
	local wTR = projectWorld3D( -- 888
		ox + 306, -- 888
		158, -- 888
		-9, -- 888
		cam, -- 888
		self.towerProj -- 888
	) -- 888
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 889
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 890
	fgDraw:drawSegment( -- 891
		Vec2(wMidX, wBL.y), -- 891
		Vec2(wMidX, wTR.y), -- 891
		1.4, -- 891
		Color(68, 52, 38, 225) -- 891
	) -- 891
	fgDraw:drawSegment( -- 892
		Vec2(wBL.x, wMidY), -- 892
		Vec2(wTR.x, wMidY), -- 892
		1.4, -- 892
		Color(68, 52, 38, 225) -- 892
	) -- 892
	return true -- 894
end -- 639
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 897
	if not self.active then -- 897
		return false -- 904
	end -- 904
	local key = ctx.p.room.key -- 906
	if key == "village" then -- 906
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 908
	end -- 908
	if key == "forest" then -- 908
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 911
	end -- 911
	if key == "outside" then -- 911
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 914
	end -- 914
	if key == "tower" then -- 914
		local p = ctx.p -- 917
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 918
		if opened then -- 918
			local cam = ctx.cam -- 920
			local deskTopP = projectWorld3D( -- 921
				p.ox + 605, -- 921
				35, -- 921
				22, -- 921
				cam, -- 921
				self.towerProj -- 921
			) -- 921
			local guardBaseP = projectWorld3D( -- 922
				p.ox + 626, -- 922
				0, -- 922
				38, -- 922
				cam, -- 922
				self.towerProj -- 922
			) -- 922
			local deskCx = deskTopP.x -- 923
			local deskTop = deskTopP.y -- 924
			local s = deskTopP.scale -- 925
			local gs = guardBaseP.scale -- 926
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 927
			fillRadialGlow( -- 928
				fgGlow, -- 928
				deskCx, -- 928
				deskTop + cam:len(26) * s, -- 928
				cam:len(132) * s, -- 928
				cam:len(96) * s, -- 928
				Color( -- 929
					255, -- 929
					198, -- 929
					114, -- 929
					math.floor(82 * pulse + 0.5) -- 929
				), -- 929
				Color(255, 168, 72, 0), -- 929
				16 -- 929
			) -- 929
			local writing = p.deskHold >= 24 or p.towerHanded -- 931
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 932
			if not worldArt:tryPlacePath( -- 932
				guardClip, -- 935
				"fe04_tower_guard_npc", -- 935
				guardBaseP.x, -- 935
				guardBaseP.y, -- 935
				cam:len(54) * gs, -- 935
				cam:len(82) * gs, -- 935
				{ -- 935
					anchorX = 0.44, -- 936
					anchorY = 0, -- 937
					preserveAspect = true, -- 938
					facing = -1, -- 939
					opacity = 0.96, -- 940
					layer = 3600 -- 941
				} -- 941
			) then -- 941
				fgDraw:drawRect( -- 943
					Rect( -- 943
						guardBaseP.x - cam:len(11) * gs, -- 943
						guardBaseP.y, -- 943
						cam:len(22) * gs, -- 943
						cam:len(68) * gs -- 943
					), -- 943
					Color(28, 34, 44, 242) -- 943
				) -- 943
				fgDraw:drawCircle( -- 944
					Vec2( -- 944
						guardBaseP.x, -- 944
						guardBaseP.y + cam:len(76) * gs -- 944
					), -- 944
					cam:len(9.5) * gs, -- 944
					Color(36, 44, 56, 248) -- 944
				) -- 944
			end -- 944
			fgDraw:drawRect( -- 947
				Rect( -- 947
					deskCx + cam:len(4) * s, -- 947
					deskTop + cam:len(1) * s, -- 947
					cam:len(24) * s, -- 947
					cam:len(5) * s -- 947
				), -- 947
				Color(230, 220, 196, 245) -- 947
			) -- 947
			if writing then -- 947
				if not worldArt:tryPlace( -- 947
					"prop_lantern", -- 949
					"fe04_tower_desk_lamp", -- 949
					deskCx + cam:len(34) * s, -- 949
					deskTop + cam:len(10) * s, -- 949
					cam:len(14) * s, -- 949
					cam:len(20) * s, -- 949
					{opacity = 0.96, layer = 3700} -- 949
				) then -- 949
					fgDraw:drawRect( -- 953
						Rect( -- 953
							deskCx + cam:len(30) * s, -- 953
							deskTop + cam:len(1) * s, -- 953
							cam:len(8) * s, -- 953
							cam:len(12) * s -- 953
						), -- 953
						Color(166, 126, 62, 245) -- 953
					) -- 953
				end -- 953
				fillRadialGlow( -- 955
					fgGlow, -- 955
					deskCx + cam:len(34) * s, -- 955
					deskTop + cam:len(14) * s, -- 955
					cam:len(26) * s, -- 955
					cam:len(22) * s, -- 955
					Color( -- 955
						255, -- 955
						214, -- 955
						134, -- 955
						math.floor(92 * pulse + 0.5) -- 955
					), -- 955
					Color(255, 180, 86, 0), -- 955
					12 -- 955
				) -- 955
			else -- 955
				fillRadialGlow( -- 957
					fgGlow, -- 957
					deskCx + cam:len(6) * s, -- 957
					deskTop + cam:len(18) * s, -- 957
					cam:len(28) * s, -- 957
					cam:len(26) * s, -- 957
					Color( -- 957
						255, -- 957
						214, -- 957
						134, -- 957
						math.floor(78 * pulse + 0.5) -- 957
					), -- 957
					Color(255, 180, 86, 0), -- 957
					12 -- 957
				) -- 957
			end -- 957
			if p.deskHold >= 12 or p.towerHanded then -- 957
				if not worldArt:tryPlacePath( -- 957
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 960
					"fe04_tower_desk_pouch", -- 960
					deskCx - cam:len(18) * s, -- 960
					deskTop + cam:len(8) * s, -- 960
					cam:len(18) * s, -- 960
					cam:len(18) * s, -- 960
					{ -- 960
						anchorX = 0.5, -- 961
						anchorY = 0.5, -- 962
						opacity = 0.95, -- 963
						smooth = true, -- 964
						layer = 3710 -- 965
					} -- 965
				) then -- 965
					fgDraw:drawRect( -- 967
						Rect( -- 967
							deskCx - cam:len(26) * s, -- 967
							deskTop + cam:len(1) * s, -- 967
							cam:len(14) * s, -- 967
							cam:len(6) * s -- 967
						), -- 967
						Color(156, 62, 48, 245) -- 967
					) -- 967
				end -- 967
			end -- 967
			if p.deskHold >= 24 or p.towerHanded then -- 967
				fgDraw:drawRect( -- 971
					Rect( -- 971
						deskCx - cam:len(4) * s, -- 971
						deskTop + cam:len(1) * s, -- 971
						cam:len(10) * s, -- 971
						cam:len(3) * s -- 971
					), -- 971
					Color(236, 228, 206, 240) -- 971
				) -- 971
			end -- 971
		end -- 971
		return true -- 974
	end -- 974
	return false -- 976
end -- 897
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 980
	local p = ctx.p -- 986
	local cam = ctx.cam -- 987
	local c = p.room.cart -- 988
	if c.bodyW <= 0 then -- 988
		return true -- 990
	end -- 990
	local halfW = c.bodyW * 0.5 -- 992
	local axleX = p.cartAxle -- 993
	local baseY = cam:sy(c.baseY) -- 994
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 995
	local cx = cam:sx(axleX) -- 996
	local artW = cam:len(c.bodyW * 1.38) -- 997
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 998
	fgDraw:drawEllipse( -- 1000
		Vec2(cx, baseY + 1), -- 1000
		cam:len(c.bodyW * 0.62), -- 1000
		4, -- 1000
		Color(6, 10, 16, 155) -- 1000
	) -- 1000
	worldArt:tryPlace( -- 1001
		"prop_cart", -- 1001
		"fe04_outside_cart", -- 1001
		cx, -- 1001
		baseY, -- 1001
		artW, -- 1001
		artH, -- 1001
		{ -- 1001
			color = Color(196, 210, 228, 255), -- 1002
			layer = 5 -- 1003
		} -- 1003
	) -- 1003
	local clothX = axleX - halfW -- 1007
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 1008
	worldArt:tryPlace( -- 1009
		"fe_red_cloth", -- 1009
		"fe04_outside_cart_cloth", -- 1009
		cam:sx(clothX + 2), -- 1009
		bodyTopY - cam:len(2), -- 1009
		cam:len(24), -- 1009
		cam:len(24), -- 1009
		{frame = clothFrame, layer = 6} -- 1009
	) -- 1009
	return true -- 1014
end -- 980
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1017
	if not self.active then -- 1017
		return -- 1024
	end -- 1024
	local key = ctx.p.room.key -- 1026
	if key == "village" then -- 1026
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1028
	elseif key == "forest" then -- 1028
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1030
	end -- 1030
end -- 1017
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1038
	if not self.active then -- 1038
		return false -- 1046
	end -- 1046
	local key = ctx.p.room.key -- 1048
	if key == "village" and ctx.cam.projection == nil then -- 1048
		return self.village:drawForegroundOverlay( -- 1050
			uiDraw, -- 1050
			uiInkDraw, -- 1050
			uiArt, -- 1050
			uiGlow, -- 1050
			ctx -- 1050
		) -- 1050
	end -- 1050
	if key == "forest" and ctx.cam.projection == nil then -- 1050
		return self.forest:drawForegroundOverlay( -- 1053
			uiDraw, -- 1053
			uiInkDraw, -- 1053
			uiArt, -- 1053
			uiGlow, -- 1053
			ctx -- 1053
		) -- 1053
	end -- 1053
	if key == "outside" then -- 1053
		self:drawOutsideSewingMemoryOverlay( -- 1056
			uiDraw, -- 1056
			uiInkDraw, -- 1056
			uiArt, -- 1056
			uiGlow, -- 1056
			ctx -- 1056
		) -- 1056
		return false -- 1057
	end -- 1057
	return false -- 1059
end -- 1038
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 1066
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1066
		return -- 1074
	end -- 1074
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1076
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1077
	if alpha <= 0.01 then -- 1077
		return -- 1079
	end -- 1079
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1081
	local handPt = ctx.cam.projection ~= nil and ctx.cam:worldToScreen(self.memoryAnchorWorldX, self.memoryAnchorWorldY) or projectWorld3D( -- 1082
		self.memoryAnchorWorldX, -- 1084
		self.memoryAnchorWorldY, -- 1084
		0, -- 1084
		ctx.cam, -- 1084
		self.outsideProj -- 1084
	) -- 1084
	local cx = math.max( -- 1085
		190, -- 1085
		math.min(ctx.uiW - 190, handPt.x * inv - 20) -- 1085
	) -- 1085
	local cy = math.max( -- 1086
		170, -- 1086
		math.min(ctx.uiH - 150, handPt.y * inv + 104) -- 1086
	) -- 1086
	local pullT = smoothstep(0.14, 0.82, prog) -- 1087
	local zoom = 0.94 + pullT * 0.09 -- 1088
	fillRadialGlow( -- 1091
		uiGlow, -- 1091
		cx, -- 1091
		cy, -- 1091
		215 * zoom, -- 1091
		152 * zoom, -- 1091
		Color( -- 1091
			238, -- 1091
			186, -- 1091
			114, -- 1091
			math.floor(88 * alpha + 0.5) -- 1091
		), -- 1091
		Color(214, 152, 82, 0), -- 1091
		22 -- 1091
	) -- 1091
	uiArt:tryPlace( -- 1092
		"ink_petal_mist", -- 1092
		"fe04_f01_memory_mist", -- 1092
		cx, -- 1092
		cy, -- 1092
		380 * zoom, -- 1092
		260 * zoom, -- 1092
		{ -- 1092
			color = Color(36, 24, 18, 255), -- 1093
			opacity = 0.72 * alpha, -- 1094
			layer = 3 -- 1095
		} -- 1095
	) -- 1095
	if not uiArt:tryPlacePath( -- 1095
		"assets/art/cutscene_story_parts.clip|f01_mother_stitch", -- 1098
		"fe04_f01_mother_stitch", -- 1099
		cx + pullT * 6, -- 1100
		cy + pullT * 4, -- 1101
		296 * zoom, -- 1102
		218 * zoom, -- 1103
		{ -- 1104
			anchorX = 0.5, -- 1105
			anchorY = 0.5, -- 1106
			color = Color(246, 224, 196, 255), -- 1107
			opacity = 0.96 * alpha, -- 1108
			smooth = true, -- 1109
			layer = 4 -- 1110
		} -- 1110
	) then -- 1110
		uiDraw:drawEllipse( -- 1113
			Vec2(cx, cy), -- 1113
			116, -- 1113
			70, -- 1113
			Color( -- 1113
				32, -- 1113
				22, -- 1113
				16, -- 1113
				math.floor(196 * alpha + 0.5) -- 1113
			) -- 1113
		) -- 1113
	end -- 1113
end -- 1066
function ____exports.createLowpolyWorldPlugin() -- 1118
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1119
end -- 1118
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1123
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1126
	fe:registerPlugin(lowpolyWorld) -- 1127
	return {lowpolyWorld = lowpolyWorld} -- 1128
end -- 1123
return ____exports -- 1123