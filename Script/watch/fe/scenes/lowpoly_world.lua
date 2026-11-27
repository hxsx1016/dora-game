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
	local redBox = __TS__ArrayFind( -- 518
		p.boxes, -- 518
		function(____, b) return b.id == "outside_red_cart" end -- 518
	) -- 518
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 518
		scene:addBox({ -- 520
			x0 = redBox.x0 + 2, -- 521
			x1 = redBox.x1 - 2, -- 522
			y0 = redBox.y0 + 10, -- 523
			y1 = redBox.y1, -- 524
			z0 = -10, -- 525
			z1 = 12, -- 526
			material = MING_MATERIALS.mingTimber, -- 527
			bucket = LP_BUCKET.PROP, -- 528
			highlightTopEdge = true, -- 529
			edgeWidth = 0.9 -- 530
		}) -- 530
		scene:addWavingQuad3D( -- 533
			vec3(redBox.x0 - 4, redBox.y0 + 10, -12), -- 534
			vec3(redBox.x0 + 14, redBox.y0 + 12, -11), -- 535
			vec3(redBox.x0 + 18, redBox.y1, -10), -- 536
			vec3(redBox.x0 + 4, redBox.y1, -11), -- 537
			MING_MATERIALS.mingRedCloth, -- 538
			{ -- 539
				ampX = 4.5, -- 539
				ampY = 1.8, -- 539
				phase = self.animTime * 2.9, -- 539
				freqU = 1.8, -- 539
				freqV = 2.4, -- 539
				pin = "top" -- 539
			}, -- 539
			{bucket = LP_BUCKET.PROP, sortBias = 0.26, subdivX = 3, subdivY = 3} -- 540
		) -- 540
	end -- 540
	local c = p.room.cart -- 545
	if c.bodyW > 0 then -- 545
		scene:addBox({ -- 548
			x0 = c.endX - 18, -- 549
			x1 = c.endX + 18, -- 550
			y0 = c.baseY - 4, -- 551
			y1 = c.baseY + 2, -- 552
			z0 = -12, -- 553
			z1 = 14, -- 554
			material = MING_MATERIALS.mingIron, -- 555
			bucket = LP_BUCKET.WALK_DECK, -- 556
			sortBias = 0.35, -- 557
			highlightTopEdge = true -- 558
		}) -- 558
		scene:addBox({ -- 561
			x0 = ox + 258, -- 562
			x1 = ox + 474, -- 563
			y0 = c.baseY - 1.5, -- 564
			y1 = c.baseY + 0.4, -- 565
			z0 = -11, -- 566
			z1 = -7, -- 567
			material = MING_MATERIALS.mingTimberDark, -- 568
			bucket = LP_BUCKET.WALK_DECK, -- 569
			sortBias = 0.3, -- 570
			edgeWidth = 0 -- 571
		}) -- 571
		scene:addBox({ -- 573
			x0 = ox + 258, -- 574
			x1 = ox + 474, -- 575
			y0 = c.baseY - 1.5, -- 576
			y1 = c.baseY + 0.4, -- 577
			z0 = 7, -- 578
			z1 = 11, -- 579
			material = MING_MATERIALS.mingTimberDark, -- 580
			bucket = LP_BUCKET.WALK_DECK, -- 581
			sortBias = 0.3, -- 582
			edgeWidth = 0 -- 583
		}) -- 583
	end -- 583
	if not p.cartDocked and p.room.arch.h > 0 then -- 583
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 590
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 591
		if bx1 > bx0 + 4 then -- 591
			scene:addBox({ -- 593
				x0 = bx0, -- 594
				x1 = bx1, -- 595
				y0 = 2, -- 596
				y1 = p.room.arch.h, -- 597
				z0 = -6, -- 598
				z1 = 8, -- 599
				material = MING_MATERIALS.mingTimberDark, -- 600
				bucket = LP_BUCKET.PROP, -- 601
				highlightTopEdge = true, -- 602
				edgeWidth = 0.9 -- 603
			}) -- 603
			scene:addBox({ -- 606
				x0 = (bx0 + bx1) * 0.5 - 3, -- 607
				x1 = (bx0 + bx1) * 0.5 + 3, -- 608
				y0 = p.room.arch.h, -- 609
				y1 = p.room.cart.baseY, -- 610
				z0 = -3, -- 611
				z1 = 5, -- 612
				material = MING_MATERIALS.mingIron, -- 613
				bucket = LP_BUCKET.PROP, -- 614
				edgeWidth = 0.6 -- 615
			}) -- 615
		end -- 615
	end -- 615
	scene:addBox({ -- 621
		x0 = ox + 128, -- 622
		x1 = ox + 598, -- 623
		y0 = 0, -- 624
		y1 = 92, -- 625
		z0 = 44, -- 626
		z1 = 72, -- 627
		material = MING_MATERIALS.mingBrickDark, -- 628
		bucket = LP_BUCKET.MIDGROUND, -- 629
		sortBias = -0.2, -- 630
		edgeWidth = 0.5 -- 631
	}) -- 631
	scene:addQuad3D( -- 634
		vec3(ox + 132, 26, 43), -- 635
		vec3(ox + 592, 26, 43), -- 636
		vec3(ox + 592, 31, 43), -- 637
		vec3(ox + 132, 31, 43), -- 638
		{base = rgba(138, 148, 158, 92)}, -- 639
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 640
	) -- 640
	scene:addLightShaft( -- 644
		ox + 1110, -- 645
		ox + 1180, -- 645
		170, -- 645
		ox + 1040, -- 646
		ox + 1140, -- 646
		0, -- 646
		34, -- 647
		rgba(234, 198, 138, 255), -- 648
		0.14, -- 649
		0.03 -- 650
	) -- 650
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 653
	local gi = 0 -- 656
	do -- 656
		gi = 0 -- 657
		while gi < 6 do -- 657
			local gx = ox + 165 + gi * 56 -- 658
			local p0 = projectWorld3D( -- 659
				gx, -- 659
				0.5, -- 659
				-14, -- 659
				cam, -- 659
				self.outsideProj -- 659
			) -- 659
			local p1 = projectWorld3D( -- 660
				gx + 10, -- 660
				0.5, -- 660
				22, -- 660
				cam, -- 660
				self.outsideProj -- 660
			) -- 660
			fgDraw:drawSegment( -- 661
				Vec2(p0.x, p0.y), -- 661
				Vec2(p1.x, p1.y), -- 661
				3, -- 661
				Color(8, 12, 18, 76) -- 661
			) -- 661
			gi = gi + 1 -- 657
		end -- 657
	end -- 657
	return true -- 664
end -- 508
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 667
	local p = ctx.p -- 668
	local cam = ctx.cam -- 669
	local ox = p.ox -- 670
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 671
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 676
	scene:addBox({ -- 679
		x0 = ox - 40, -- 680
		x1 = ox + 760, -- 681
		y0 = -52, -- 682
		y1 = 0, -- 683
		z0 = -26, -- 684
		z1 = 96, -- 685
		material = MING_MATERIALS.mingBrickDark, -- 686
		bucket = LP_BUCKET.WALK_DECK, -- 687
		highlightTopEdge = true -- 688
	}) -- 688
	scene:addBox({ -- 691
		x0 = ox + 398, -- 692
		x1 = ox + 492, -- 693
		y0 = -4, -- 694
		y1 = 2.5, -- 695
		z0 = -16, -- 696
		z1 = 26, -- 697
		material = MING_MATERIALS.mingStoneStep, -- 698
		bucket = LP_BUCKET.WALK_DECK, -- 699
		sortBias = 0.15, -- 700
		highlightTopEdge = true -- 701
	}) -- 701
	scene:addBox({ -- 705
		x0 = ox + 180, -- 706
		x1 = ox + 400, -- 707
		y0 = 0, -- 708
		y1 = 215, -- 709
		z0 = -8, -- 710
		z1 = 96, -- 711
		material = MING_MATERIALS.mingBrick, -- 712
		bucket = LP_BUCKET.MIDGROUND, -- 713
		highlightTopEdge = true -- 714
	}) -- 714
	scene:addBox({ -- 716
		x0 = ox + 490, -- 717
		x1 = ox + 720, -- 718
		y0 = 0, -- 719
		y1 = 215, -- 720
		z0 = -8, -- 721
		z1 = 96, -- 722
		material = MING_MATERIALS.mingBrick, -- 723
		bucket = LP_BUCKET.MIDGROUND, -- 724
		highlightTopEdge = true -- 725
	}) -- 725
	scene:addBeveledFrame( -- 729
		ox + 400, -- 729
		ox + 490, -- 729
		0, -- 729
		110, -- 729
		14, -- 729
		34, -- 729
		-8, -- 729
		68, -- 729
		MING_MATERIALS.mingStoneStep, -- 729
		{ -- 729
			bucket = LP_BUCKET.MIDGROUND, -- 730
			innerRimLight = rgba(244, 206, 140, 255), -- 731
			innerRimStrength = opened and 0.78 or 0.32 -- 732
		} -- 732
	) -- 732
	scene:addCutout3D( -- 736
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 736
		ox + 445, -- 736
		206, -- 736
		18, -- 736
		240, -- 736
		142, -- 736
		{ -- 736
			bucket = LP_BUCKET.MIDGROUND, -- 737
			anchorX = 0.5, -- 738
			anchorY = 0, -- 739
			color = rgba(154, 168, 184, 255), -- 740
			opacity = 0.92, -- 741
			sortBias = 0.08 -- 742
		} -- 742
	) -- 742
	if not opened then -- 742
		scene:addCutout3D( -- 747
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 747
			ox + 445, -- 747
			2, -- 747
			14, -- 747
			84, -- 747
			108, -- 747
			{ -- 747
				bucket = LP_BUCKET.MIDGROUND, -- 748
				anchorX = 0.5, -- 749
				anchorY = 0, -- 750
				color = rgba(186, 182, 176, 255), -- 751
				opacity = 0.98, -- 752
				sortBias = 0.14 -- 753
			} -- 753
		) -- 753
	else -- 753
		scene:addQuad3D( -- 756
			vec3(ox + 404, 2, 24), -- 757
			vec3(ox + 486, 2, 24), -- 758
			vec3(ox + 486, 109, 24), -- 759
			vec3(ox + 404, 109, 24), -- 760
			{base = rgba(112, 78, 42, 255)}, -- 761
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 762
		) -- 762
	end -- 762
	scene:addQuad3D( -- 767
		vec3(ox + 286, 118, -9), -- 768
		vec3(ox + 306, 118, -9), -- 769
		vec3(ox + 306, 158, -9), -- 770
		vec3(ox + 286, 158, -9), -- 771
		{base = rgba(244, 204, 134, 255)}, -- 772
		{ -- 773
			bucket = LP_BUCKET.PROP, -- 773
			unlit = true, -- 773
			edgeColor = rgba(82, 68, 52, 255), -- 773
			edgeWidth = 1.4 -- 773
		} -- 773
	) -- 773
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 777
	scene:addLightShaft( -- 778
		ox + 412, -- 779
		ox + 478, -- 779
		106, -- 779
		ox + 382, -- 780
		ox + 506, -- 780
		0, -- 780
		6, -- 781
		rgba(246, 208, 138, 255), -- 782
		(opened and 0.34 or 0.08) * pulse, -- 783
		(opened and 0.16 or 0.04) * pulse -- 784
	) -- 784
	scene:addContactShadow( -- 788
		p.player.x, -- 788
		p.player.y, -- 788
		15, -- 788
		11, -- 788
		0.78, -- 788
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 788
	) -- 788
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 790
	local lampP = projectWorld3D( -- 793
		ox + 445, -- 793
		102, -- 793
		2, -- 793
		cam, -- 793
		self.towerProj -- 793
	) -- 793
	fillRadialGlow( -- 794
		fgGlow, -- 795
		lampP.x, -- 796
		lampP.y, -- 797
		cam:len(opened and 64 or 34) * pulse, -- 798
		cam:len(opened and 64 or 34) * pulse, -- 799
		Color( -- 800
			248, -- 800
			214, -- 800
			146, -- 800
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 800
		), -- 800
		Color(232, 174, 82, 0), -- 801
		16 -- 802
	) -- 802
	fgDraw:drawCircle( -- 804
		Vec2(lampP.x, lampP.y), -- 804
		4.2, -- 804
		Color(255, 240, 202, 245) -- 804
	) -- 804
	local winP = projectWorld3D( -- 806
		ox + 296, -- 806
		138, -- 806
		-9, -- 806
		cam, -- 806
		self.towerProj -- 806
	) -- 806
	fillRadialGlow( -- 807
		fgGlow, -- 807
		winP.x, -- 807
		winP.y, -- 807
		cam:len(38), -- 807
		cam:len(42), -- 807
		Color( -- 807
			246, -- 807
			206, -- 807
			132, -- 807
			math.floor(78 * pulse + 0.5) -- 807
		), -- 807
		Color(232, 174, 82, 0), -- 807
		14 -- 807
	) -- 807
	local wBL = projectWorld3D( -- 809
		ox + 286, -- 809
		118, -- 809
		-9, -- 809
		cam, -- 809
		self.towerProj -- 809
	) -- 809
	local wTR = projectWorld3D( -- 810
		ox + 306, -- 810
		158, -- 810
		-9, -- 810
		cam, -- 810
		self.towerProj -- 810
	) -- 810
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 811
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 812
	fgDraw:drawSegment( -- 813
		Vec2(wMidX, wBL.y), -- 813
		Vec2(wMidX, wTR.y), -- 813
		1.4, -- 813
		Color(68, 52, 38, 225) -- 813
	) -- 813
	fgDraw:drawSegment( -- 814
		Vec2(wBL.x, wMidY), -- 814
		Vec2(wTR.x, wMidY), -- 814
		1.4, -- 814
		Color(68, 52, 38, 225) -- 814
	) -- 814
	return true -- 816
end -- 667
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 819
	if not self.active then -- 819
		return false -- 826
	end -- 826
	local key = ctx.p.room.key -- 828
	if key == "village" then -- 828
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 830
	end -- 830
	if key == "forest" then -- 830
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 833
	end -- 833
	if key == "outside" then -- 833
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 836
	end -- 836
	if key == "tower" then -- 836
		local p = ctx.p -- 839
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 840
		if opened then -- 840
			local cam = ctx.cam -- 842
			local deskCx = cam:sx(p.ox + 605) -- 843
			local groundY = cam:sy(0) -- 844
			local deskW = cam:len(84) -- 845
			local deskH = cam:len(34) -- 846
			local deskTop = groundY + deskH -- 847
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 848
			fillRadialGlow( -- 849
				fgGlow, -- 849
				deskCx, -- 849
				deskTop + cam:len(28), -- 849
				cam:len(120), -- 849
				cam:len(88), -- 849
				Color( -- 850
					255, -- 850
					198, -- 850
					114, -- 850
					math.floor(74 * pulse + 0.5) -- 850
				), -- 850
				Color(255, 168, 72, 0), -- 850
				16 -- 850
			) -- 850
			local guardX = deskCx + cam:len(26) -- 852
			local writing = p.deskHold >= 24 or p.towerHanded -- 853
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 854
			if not worldArt:tryPlacePath( -- 854
				guardClip, -- 857
				"fe04_tower_guard_npc", -- 857
				guardX, -- 857
				groundY, -- 857
				cam:len(54), -- 857
				cam:len(82), -- 857
				{ -- 857
					anchorX = 0.44, -- 858
					anchorY = 0, -- 859
					preserveAspect = true, -- 860
					facing = -1, -- 861
					opacity = 0.96, -- 862
					layer = 3600 -- 863
				} -- 863
			) then -- 863
				fgDraw:drawRect( -- 865
					Rect( -- 865
						guardX - cam:len(11), -- 865
						groundY, -- 865
						cam:len(22), -- 865
						cam:len(68) -- 865
					), -- 865
					Color(28, 34, 44, 240) -- 865
				) -- 865
			end -- 865
			worldArt:tryPlace( -- 867
				"prop_table", -- 867
				"fe04_tower_desk_prop", -- 867
				deskCx, -- 867
				groundY, -- 867
				deskW * 1.06, -- 867
				deskH * 1.04, -- 867
				{ -- 867
					color = Color(206, 180, 150, 255), -- 868
					opacity = 0.98, -- 869
					layer = 3650 -- 870
				} -- 870
			) -- 870
			if writing then -- 870
				worldArt:tryPlace( -- 873
					"prop_lantern", -- 873
					"fe04_tower_desk_lamp", -- 873
					deskCx + cam:len(34), -- 873
					deskTop + cam:len(10), -- 873
					cam:len(14), -- 873
					cam:len(20), -- 873
					{opacity = 0.96, layer = 3700} -- 873
				) -- 873
				fillRadialGlow( -- 877
					fgGlow, -- 877
					deskCx + cam:len(34), -- 877
					deskTop + cam:len(12), -- 877
					cam:len(24), -- 877
					cam:len(22), -- 877
					Color( -- 877
						255, -- 877
						214, -- 877
						134, -- 877
						math.floor(84 * pulse + 0.5) -- 877
					), -- 877
					Color(255, 180, 86, 0), -- 877
					12 -- 877
				) -- 877
			else -- 877
				fillRadialGlow( -- 879
					fgGlow, -- 879
					deskCx + cam:len(3), -- 879
					deskTop + cam:len(18), -- 879
					cam:len(28), -- 879
					cam:len(26), -- 879
					Color( -- 879
						255, -- 879
						214, -- 879
						134, -- 879
						math.floor(74 * pulse + 0.5) -- 879
					), -- 879
					Color(255, 180, 86, 0), -- 879
					12 -- 879
				) -- 879
			end -- 879
			fgDraw:drawRect( -- 881
				Rect( -- 881
					deskCx + cam:len(2), -- 881
					deskTop + cam:len(1), -- 881
					cam:len(22), -- 881
					cam:len(4) -- 881
				), -- 881
				Color(230, 220, 196, 235) -- 881
			) -- 881
			if p.deskHold >= 12 or p.towerHanded then -- 881
				worldArt:tryPlacePath( -- 883
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 883
					"fe04_tower_desk_pouch", -- 883
					deskCx - cam:len(18), -- 883
					deskTop + cam:len(8), -- 883
					cam:len(18), -- 883
					cam:len(18), -- 883
					{ -- 883
						anchorX = 0.5, -- 884
						anchorY = 0.5, -- 885
						opacity = 0.95, -- 886
						smooth = true, -- 887
						layer = 3710 -- 888
					} -- 888
				) -- 888
			end -- 888
			if p.deskHold >= 24 or p.towerHanded then -- 888
				fgDraw:drawRect( -- 892
					Rect( -- 892
						deskCx - cam:len(4), -- 892
						deskTop + cam:len(1), -- 892
						cam:len(10), -- 892
						cam:len(3) -- 892
					), -- 892
					Color(236, 228, 206, 240) -- 892
				) -- 892
			end -- 892
		end -- 892
		return true -- 895
	end -- 895
	return false -- 897
end -- 819
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 901
	local p = ctx.p -- 907
	local cam = ctx.cam -- 908
	local c = p.room.cart -- 909
	if c.bodyW <= 0 then -- 909
		return true -- 911
	end -- 911
	local halfW = c.bodyW * 0.5 -- 913
	local axleX = p.cartAxle -- 914
	local baseY = cam:sy(c.baseY) -- 915
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 916
	local cx = cam:sx(axleX) -- 917
	local artW = cam:len(c.bodyW * 1.38) -- 918
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 919
	fgDraw:drawEllipse( -- 921
		Vec2(cx, baseY + 1), -- 921
		cam:len(c.bodyW * 0.62), -- 921
		4, -- 921
		Color(6, 10, 16, 155) -- 921
	) -- 921
	worldArt:tryPlace( -- 922
		"prop_cart", -- 922
		"fe04_outside_cart", -- 922
		cx, -- 922
		baseY, -- 922
		artW, -- 922
		artH, -- 922
		{ -- 922
			color = Color(196, 210, 228, 255), -- 923
			layer = 5 -- 924
		} -- 924
	) -- 924
	local clothX = axleX - halfW -- 928
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 929
	worldArt:tryPlace( -- 930
		"fe_red_cloth", -- 930
		"fe04_outside_cart_cloth", -- 930
		cam:sx(clothX + 2), -- 930
		bodyTopY - cam:len(2), -- 930
		cam:len(24), -- 930
		cam:len(24), -- 930
		{frame = clothFrame, layer = 6} -- 930
	) -- 930
	return true -- 935
end -- 901
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 938
	if not self.active then -- 938
		return -- 945
	end -- 945
	local key = ctx.p.room.key -- 947
	if key == "village" then -- 947
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 949
	elseif key == "forest" then -- 949
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 951
	end -- 951
end -- 938
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 959
	if not self.active then -- 959
		return false -- 967
	end -- 967
	local key = ctx.p.room.key -- 969
	if key == "village" then -- 969
		return self.village:drawForegroundOverlay( -- 971
			uiDraw, -- 971
			uiInkDraw, -- 971
			uiArt, -- 971
			uiGlow, -- 971
			ctx -- 971
		) -- 971
	end -- 971
	if key == "forest" then -- 971
		return self.forest:drawForegroundOverlay( -- 974
			uiDraw, -- 974
			uiInkDraw, -- 974
			uiArt, -- 974
			uiGlow, -- 974
			ctx -- 974
		) -- 974
	end -- 974
	if key == "outside" then -- 974
		self:drawOutsideSewingMemoryOverlay( -- 977
			uiDraw, -- 977
			uiInkDraw, -- 977
			uiArt, -- 977
			uiGlow, -- 977
			ctx -- 977
		) -- 977
		return false -- 978
	end -- 978
	return false -- 980
end -- 959
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 987
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 987
		return -- 995
	end -- 995
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 997
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 998
	if alpha <= 0.01 then -- 998
		return -- 1000
	end -- 1000
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1002
	local handPt = projectWorld3D( -- 1003
		self.memoryAnchorWorldX, -- 1003
		self.memoryAnchorWorldY, -- 1003
		0, -- 1003
		ctx.cam, -- 1003
		self.outsideProj -- 1003
	) -- 1003
	local cx = math.max( -- 1004
		190, -- 1004
		math.min(ctx.uiW - 190, handPt.x * inv - 20) -- 1004
	) -- 1004
	local cy = math.max( -- 1005
		170, -- 1005
		math.min(ctx.uiH - 150, handPt.y * inv + 104) -- 1005
	) -- 1005
	local pullT = smoothstep(0.14, 0.82, prog) -- 1006
	local zoom = 0.94 + pullT * 0.09 -- 1007
	fillRadialGlow( -- 1010
		uiGlow, -- 1010
		cx, -- 1010
		cy, -- 1010
		215 * zoom, -- 1010
		152 * zoom, -- 1010
		Color( -- 1010
			238, -- 1010
			186, -- 1010
			114, -- 1010
			math.floor(88 * alpha + 0.5) -- 1010
		), -- 1010
		Color(214, 152, 82, 0), -- 1010
		22 -- 1010
	) -- 1010
	uiArt:tryPlace( -- 1011
		"ink_petal_mist", -- 1011
		"fe04_f01_memory_mist", -- 1011
		cx, -- 1011
		cy, -- 1011
		380 * zoom, -- 1011
		260 * zoom, -- 1011
		{ -- 1011
			color = Color(36, 24, 18, 255), -- 1012
			opacity = 0.72 * alpha, -- 1013
			layer = 3 -- 1014
		} -- 1014
	) -- 1014
	if not uiArt:tryPlacePath( -- 1014
		"assets/art/cutscene_story_parts.clip|f01_mother_stitch", -- 1017
		"fe04_f01_mother_stitch", -- 1018
		cx + pullT * 6, -- 1019
		cy + pullT * 4, -- 1020
		296 * zoom, -- 1021
		218 * zoom, -- 1022
		{ -- 1023
			anchorX = 0.5, -- 1024
			anchorY = 0.5, -- 1025
			color = Color(246, 224, 196, 255), -- 1026
			opacity = 0.96 * alpha, -- 1027
			smooth = true, -- 1028
			layer = 4 -- 1029
		} -- 1029
	) then -- 1029
		uiDraw:drawEllipse( -- 1032
			Vec2(cx, cy), -- 1032
			116, -- 1032
			70, -- 1032
			Color( -- 1032
				32, -- 1032
				22, -- 1032
				16, -- 1032
				math.floor(196 * alpha + 0.5) -- 1032
			) -- 1032
		) -- 1032
	end -- 1032
end -- 987
function ____exports.createLowpolyWorldPlugin() -- 1037
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1038
end -- 1037
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1042
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1045
	fe:registerPlugin(lowpolyWorld) -- 1046
	return {lowpolyWorld = lowpolyWorld} -- 1047
end -- 1042
return ____exports -- 1042