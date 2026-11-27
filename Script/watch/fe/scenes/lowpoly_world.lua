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
	if not opened then -- 714
		scene:addBox({ -- 717
			x0 = ox + 490, -- 718
			x1 = ox + 720, -- 719
			y0 = 0, -- 720
			y1 = 215, -- 721
			z0 = -8, -- 722
			z1 = 96, -- 723
			material = MING_MATERIALS.mingBrick, -- 724
			bucket = LP_BUCKET.MIDGROUND, -- 725
			highlightTopEdge = true -- 726
		}) -- 726
	else -- 726
		scene:addBox({ -- 730
			x0 = ox + 490, -- 731
			x1 = ox + 706, -- 732
			y0 = 0, -- 733
			y1 = 146, -- 734
			z0 = 46, -- 735
			z1 = 96, -- 736
			material = MING_MATERIALS.mingTimberDark, -- 737
			bucket = LP_BUCKET.BACKDROP, -- 738
			edgeWidth = 0.8 -- 739
		}) -- 739
		scene:addBox({ -- 741
			x0 = ox + 490, -- 742
			x1 = ox + 706, -- 743
			y0 = -3, -- 744
			y1 = 2, -- 745
			z0 = -18, -- 746
			z1 = 48, -- 747
			material = MING_MATERIALS.mingTimber, -- 748
			bucket = LP_BUCKET.WALK_DECK, -- 749
			sortBias = 0.12, -- 750
			highlightTopEdge = true -- 751
		}) -- 751
		scene:addBox({ -- 754
			x0 = ox + 490, -- 755
			x1 = ox + 720, -- 756
			y0 = 144, -- 757
			y1 = 215, -- 758
			z0 = -8, -- 759
			z1 = 96, -- 760
			material = MING_MATERIALS.mingBrick, -- 761
			bucket = LP_BUCKET.MIDGROUND, -- 762
			highlightTopEdge = true -- 763
		}) -- 763
		scene:addBox({ -- 765
			x0 = ox + 490, -- 766
			x1 = ox + 704, -- 767
			y0 = 132, -- 768
			y1 = 145, -- 769
			z0 = -4, -- 770
			z1 = 48, -- 771
			material = MING_MATERIALS.mingTimberDark, -- 772
			bucket = LP_BUCKET.MIDGROUND, -- 773
			sortBias = 0.08 -- 774
		}) -- 774
		scene:addBox({ -- 777
			x0 = ox + 702, -- 778
			x1 = ox + 724, -- 779
			y0 = 0, -- 780
			y1 = 146, -- 781
			z0 = -8, -- 782
			z1 = 96, -- 783
			material = MING_MATERIALS.mingBrickDark, -- 784
			bucket = LP_BUCKET.MIDGROUND, -- 785
			highlightTopEdge = true -- 786
		}) -- 786
		scene:addQuad3D( -- 789
			vec3(ox + 544, 52, 45), -- 790
			vec3(ox + 662, 52, 45), -- 791
			vec3(ox + 662, 118, 45), -- 792
			vec3(ox + 544, 118, 45), -- 793
			{base = rgba(88, 62, 38, 255)}, -- 794
			{ -- 795
				bucket = LP_BUCKET.BACKDROP, -- 795
				unlit = true, -- 795
				sortBias = 0.12, -- 795
				edgeColor = rgba(132, 98, 62, 210), -- 795
				edgeWidth = 1 -- 795
			} -- 795
		) -- 795
		scene:addBox({ -- 798
			x0 = ox + 564, -- 799
			x1 = ox + 646, -- 800
			y0 = 28, -- 801
			y1 = 35, -- 802
			z0 = 10, -- 803
			z1 = 36, -- 804
			material = MING_MATERIALS.mingTimber, -- 805
			bucket = LP_BUCKET.PROP, -- 806
			sortBias = 0.12, -- 807
			highlightTopEdge = true -- 808
		}) -- 808
		scene:addBox({ -- 810
			x0 = ox + 568, -- 811
			x1 = ox + 576, -- 812
			y0 = 0, -- 813
			y1 = 28, -- 814
			z0 = 12, -- 815
			z1 = 32, -- 816
			material = MING_MATERIALS.mingTimberDark, -- 817
			bucket = LP_BUCKET.PROP, -- 818
			sortBias = 0.06 -- 819
		}) -- 819
		scene:addBox({ -- 821
			x0 = ox + 634, -- 822
			x1 = ox + 642, -- 823
			y0 = 0, -- 824
			y1 = 28, -- 825
			z0 = 12, -- 826
			z1 = 32, -- 827
			material = MING_MATERIALS.mingTimberDark, -- 828
			bucket = LP_BUCKET.PROP, -- 829
			sortBias = 0.06 -- 830
		}) -- 830
	end -- 830
	scene:addBeveledFrame( -- 835
		ox + 400, -- 835
		ox + 490, -- 835
		0, -- 835
		110, -- 835
		14, -- 835
		34, -- 835
		-8, -- 835
		68, -- 835
		MING_MATERIALS.mingStoneStep, -- 835
		{ -- 835
			bucket = LP_BUCKET.MIDGROUND, -- 836
			innerRimLight = rgba(244, 206, 140, 255), -- 837
			innerRimStrength = opened and 0.78 or 0.32 -- 838
		} -- 838
	) -- 838
	scene:addCutout3D( -- 842
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 842
		ox + 445, -- 842
		206, -- 842
		18, -- 842
		240, -- 842
		142, -- 842
		{ -- 842
			bucket = LP_BUCKET.MIDGROUND, -- 843
			anchorX = 0.5, -- 844
			anchorY = 0, -- 845
			color = rgba(154, 168, 184, 255), -- 846
			opacity = 0.92, -- 847
			sortBias = 0.08 -- 848
		} -- 848
	) -- 848
	if not opened then -- 848
		scene:addCutout3D( -- 853
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 853
			ox + 445, -- 853
			2, -- 853
			14, -- 853
			84, -- 853
			108, -- 853
			{ -- 853
				bucket = LP_BUCKET.MIDGROUND, -- 854
				anchorX = 0.5, -- 855
				anchorY = 0, -- 856
				color = rgba(186, 182, 176, 255), -- 857
				opacity = 0.98, -- 858
				sortBias = 0.14 -- 859
			} -- 859
		) -- 859
	else -- 859
		scene:addQuad3D( -- 862
			vec3(ox + 404, 2, 24), -- 863
			vec3(ox + 486, 2, 24), -- 864
			vec3(ox + 486, 109, 24), -- 865
			vec3(ox + 404, 109, 24), -- 866
			{base = rgba(112, 78, 42, 255)}, -- 867
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 868
		) -- 868
	end -- 868
	scene:addQuad3D( -- 873
		vec3(ox + 286, 118, -9), -- 874
		vec3(ox + 306, 118, -9), -- 875
		vec3(ox + 306, 158, -9), -- 876
		vec3(ox + 286, 158, -9), -- 877
		{base = rgba(244, 204, 134, 255)}, -- 878
		{ -- 879
			bucket = LP_BUCKET.PROP, -- 879
			unlit = true, -- 879
			edgeColor = rgba(82, 68, 52, 255), -- 879
			edgeWidth = 1.4 -- 879
		} -- 879
	) -- 879
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 883
	scene:addLightShaft( -- 884
		ox + 412, -- 885
		ox + 478, -- 885
		106, -- 885
		ox + 382, -- 886
		ox + 506, -- 886
		0, -- 886
		6, -- 887
		rgba(246, 208, 138, 255), -- 888
		(opened and 0.34 or 0.08) * pulse, -- 889
		(opened and 0.16 or 0.04) * pulse -- 890
	) -- 890
	scene:addContactShadow( -- 894
		p.player.x, -- 894
		p.player.y, -- 894
		15, -- 894
		11, -- 894
		0.78, -- 894
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 894
	) -- 894
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 896
	local lampP = projectWorld3D( -- 899
		ox + 445, -- 899
		102, -- 899
		2, -- 899
		cam, -- 899
		self.towerProj -- 899
	) -- 899
	fillRadialGlow( -- 900
		fgGlow, -- 901
		lampP.x, -- 902
		lampP.y, -- 903
		cam:len(opened and 64 or 34) * pulse, -- 904
		cam:len(opened and 64 or 34) * pulse, -- 905
		Color( -- 906
			248, -- 906
			214, -- 906
			146, -- 906
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 906
		), -- 906
		Color(232, 174, 82, 0), -- 907
		16 -- 908
	) -- 908
	fgDraw:drawCircle( -- 910
		Vec2(lampP.x, lampP.y), -- 910
		4.2, -- 910
		Color(255, 240, 202, 245) -- 910
	) -- 910
	local winP = projectWorld3D( -- 912
		ox + 296, -- 912
		138, -- 912
		-9, -- 912
		cam, -- 912
		self.towerProj -- 912
	) -- 912
	fillRadialGlow( -- 913
		fgGlow, -- 913
		winP.x, -- 913
		winP.y, -- 913
		cam:len(38), -- 913
		cam:len(42), -- 913
		Color( -- 913
			246, -- 913
			206, -- 913
			132, -- 913
			math.floor(78 * pulse + 0.5) -- 913
		), -- 913
		Color(232, 174, 82, 0), -- 913
		14 -- 913
	) -- 913
	local wBL = projectWorld3D( -- 915
		ox + 286, -- 915
		118, -- 915
		-9, -- 915
		cam, -- 915
		self.towerProj -- 915
	) -- 915
	local wTR = projectWorld3D( -- 916
		ox + 306, -- 916
		158, -- 916
		-9, -- 916
		cam, -- 916
		self.towerProj -- 916
	) -- 916
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 917
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 918
	fgDraw:drawSegment( -- 919
		Vec2(wMidX, wBL.y), -- 919
		Vec2(wMidX, wTR.y), -- 919
		1.4, -- 919
		Color(68, 52, 38, 225) -- 919
	) -- 919
	fgDraw:drawSegment( -- 920
		Vec2(wBL.x, wMidY), -- 920
		Vec2(wTR.x, wMidY), -- 920
		1.4, -- 920
		Color(68, 52, 38, 225) -- 920
	) -- 920
	return true -- 922
end -- 667
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 925
	if not self.active then -- 925
		return false -- 932
	end -- 932
	local key = ctx.p.room.key -- 934
	if key == "village" then -- 934
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 936
	end -- 936
	if key == "forest" then -- 936
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 939
	end -- 939
	if key == "outside" then -- 939
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 942
	end -- 942
	if key == "tower" then -- 942
		local p = ctx.p -- 945
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 946
		if opened then -- 946
			local cam = ctx.cam -- 948
			local deskTopP = projectWorld3D( -- 949
				p.ox + 605, -- 949
				35, -- 949
				22, -- 949
				cam, -- 949
				self.towerProj -- 949
			) -- 949
			local guardBaseP = projectWorld3D( -- 950
				p.ox + 626, -- 950
				0, -- 950
				38, -- 950
				cam, -- 950
				self.towerProj -- 950
			) -- 950
			local deskCx = deskTopP.x -- 951
			local deskTop = deskTopP.y -- 952
			local s = deskTopP.scale -- 953
			local gs = guardBaseP.scale -- 954
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 955
			fillRadialGlow( -- 956
				fgGlow, -- 956
				deskCx, -- 956
				deskTop + cam:len(26) * s, -- 956
				cam:len(132) * s, -- 956
				cam:len(96) * s, -- 956
				Color( -- 957
					255, -- 957
					198, -- 957
					114, -- 957
					math.floor(82 * pulse + 0.5) -- 957
				), -- 957
				Color(255, 168, 72, 0), -- 957
				16 -- 957
			) -- 957
			local writing = p.deskHold >= 24 or p.towerHanded -- 959
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 960
			if not worldArt:tryPlacePath( -- 960
				guardClip, -- 963
				"fe04_tower_guard_npc", -- 963
				guardBaseP.x, -- 963
				guardBaseP.y, -- 963
				cam:len(54) * gs, -- 963
				cam:len(82) * gs, -- 963
				{ -- 963
					anchorX = 0.44, -- 964
					anchorY = 0, -- 965
					preserveAspect = true, -- 966
					facing = -1, -- 967
					opacity = 0.96, -- 968
					layer = 3600 -- 969
				} -- 969
			) then -- 969
				fgDraw:drawRect( -- 971
					Rect( -- 971
						guardBaseP.x - cam:len(11) * gs, -- 971
						guardBaseP.y, -- 971
						cam:len(22) * gs, -- 971
						cam:len(68) * gs -- 971
					), -- 971
					Color(28, 34, 44, 242) -- 971
				) -- 971
				fgDraw:drawCircle( -- 972
					Vec2( -- 972
						guardBaseP.x, -- 972
						guardBaseP.y + cam:len(76) * gs -- 972
					), -- 972
					cam:len(9.5) * gs, -- 972
					Color(36, 44, 56, 248) -- 972
				) -- 972
			end -- 972
			fgDraw:drawRect( -- 975
				Rect( -- 975
					deskCx + cam:len(4) * s, -- 975
					deskTop + cam:len(1) * s, -- 975
					cam:len(24) * s, -- 975
					cam:len(5) * s -- 975
				), -- 975
				Color(230, 220, 196, 245) -- 975
			) -- 975
			if writing then -- 975
				if not worldArt:tryPlace( -- 975
					"prop_lantern", -- 977
					"fe04_tower_desk_lamp", -- 977
					deskCx + cam:len(34) * s, -- 977
					deskTop + cam:len(10) * s, -- 977
					cam:len(14) * s, -- 977
					cam:len(20) * s, -- 977
					{opacity = 0.96, layer = 3700} -- 977
				) then -- 977
					fgDraw:drawRect( -- 981
						Rect( -- 981
							deskCx + cam:len(30) * s, -- 981
							deskTop + cam:len(1) * s, -- 981
							cam:len(8) * s, -- 981
							cam:len(12) * s -- 981
						), -- 981
						Color(166, 126, 62, 245) -- 981
					) -- 981
				end -- 981
				fillRadialGlow( -- 983
					fgGlow, -- 983
					deskCx + cam:len(34) * s, -- 983
					deskTop + cam:len(14) * s, -- 983
					cam:len(26) * s, -- 983
					cam:len(22) * s, -- 983
					Color( -- 983
						255, -- 983
						214, -- 983
						134, -- 983
						math.floor(92 * pulse + 0.5) -- 983
					), -- 983
					Color(255, 180, 86, 0), -- 983
					12 -- 983
				) -- 983
			else -- 983
				fillRadialGlow( -- 985
					fgGlow, -- 985
					deskCx + cam:len(6) * s, -- 985
					deskTop + cam:len(18) * s, -- 985
					cam:len(28) * s, -- 985
					cam:len(26) * s, -- 985
					Color( -- 985
						255, -- 985
						214, -- 985
						134, -- 985
						math.floor(78 * pulse + 0.5) -- 985
					), -- 985
					Color(255, 180, 86, 0), -- 985
					12 -- 985
				) -- 985
			end -- 985
			if p.deskHold >= 12 or p.towerHanded then -- 985
				if not worldArt:tryPlacePath( -- 985
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 988
					"fe04_tower_desk_pouch", -- 988
					deskCx - cam:len(18) * s, -- 988
					deskTop + cam:len(8) * s, -- 988
					cam:len(18) * s, -- 988
					cam:len(18) * s, -- 988
					{ -- 988
						anchorX = 0.5, -- 989
						anchorY = 0.5, -- 990
						opacity = 0.95, -- 991
						smooth = true, -- 992
						layer = 3710 -- 993
					} -- 993
				) then -- 993
					fgDraw:drawRect( -- 995
						Rect( -- 995
							deskCx - cam:len(26) * s, -- 995
							deskTop + cam:len(1) * s, -- 995
							cam:len(14) * s, -- 995
							cam:len(6) * s -- 995
						), -- 995
						Color(156, 62, 48, 245) -- 995
					) -- 995
				end -- 995
			end -- 995
			if p.deskHold >= 24 or p.towerHanded then -- 995
				fgDraw:drawRect( -- 999
					Rect( -- 999
						deskCx - cam:len(4) * s, -- 999
						deskTop + cam:len(1) * s, -- 999
						cam:len(10) * s, -- 999
						cam:len(3) * s -- 999
					), -- 999
					Color(236, 228, 206, 240) -- 999
				) -- 999
			end -- 999
		end -- 999
		return true -- 1002
	end -- 1002
	return false -- 1004
end -- 925
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 1008
	local p = ctx.p -- 1014
	local cam = ctx.cam -- 1015
	local c = p.room.cart -- 1016
	if c.bodyW <= 0 then -- 1016
		return true -- 1018
	end -- 1018
	local halfW = c.bodyW * 0.5 -- 1020
	local axleX = p.cartAxle -- 1021
	local baseY = cam:sy(c.baseY) -- 1022
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 1023
	local cx = cam:sx(axleX) -- 1024
	local artW = cam:len(c.bodyW * 1.38) -- 1025
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 1026
	fgDraw:drawEllipse( -- 1028
		Vec2(cx, baseY + 1), -- 1028
		cam:len(c.bodyW * 0.62), -- 1028
		4, -- 1028
		Color(6, 10, 16, 155) -- 1028
	) -- 1028
	worldArt:tryPlace( -- 1029
		"prop_cart", -- 1029
		"fe04_outside_cart", -- 1029
		cx, -- 1029
		baseY, -- 1029
		artW, -- 1029
		artH, -- 1029
		{ -- 1029
			color = Color(196, 210, 228, 255), -- 1030
			layer = 5 -- 1031
		} -- 1031
	) -- 1031
	local clothX = axleX - halfW -- 1035
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 1036
	worldArt:tryPlace( -- 1037
		"fe_red_cloth", -- 1037
		"fe04_outside_cart_cloth", -- 1037
		cam:sx(clothX + 2), -- 1037
		bodyTopY - cam:len(2), -- 1037
		cam:len(24), -- 1037
		cam:len(24), -- 1037
		{frame = clothFrame, layer = 6} -- 1037
	) -- 1037
	return true -- 1042
end -- 1008
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1045
	if not self.active then -- 1045
		return -- 1052
	end -- 1052
	local key = ctx.p.room.key -- 1054
	if key == "village" then -- 1054
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1056
	elseif key == "forest" then -- 1056
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1058
	end -- 1058
end -- 1045
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1066
	if not self.active then -- 1066
		return false -- 1074
	end -- 1074
	local key = ctx.p.room.key -- 1076
	if key == "village" then -- 1076
		return self.village:drawForegroundOverlay( -- 1078
			uiDraw, -- 1078
			uiInkDraw, -- 1078
			uiArt, -- 1078
			uiGlow, -- 1078
			ctx -- 1078
		) -- 1078
	end -- 1078
	if key == "forest" then -- 1078
		return self.forest:drawForegroundOverlay( -- 1081
			uiDraw, -- 1081
			uiInkDraw, -- 1081
			uiArt, -- 1081
			uiGlow, -- 1081
			ctx -- 1081
		) -- 1081
	end -- 1081
	if key == "outside" then -- 1081
		self:drawOutsideSewingMemoryOverlay( -- 1084
			uiDraw, -- 1084
			uiInkDraw, -- 1084
			uiArt, -- 1084
			uiGlow, -- 1084
			ctx -- 1084
		) -- 1084
		return false -- 1085
	end -- 1085
	return false -- 1087
end -- 1066
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 1094
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1094
		return -- 1102
	end -- 1102
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1104
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1105
	if alpha <= 0.01 then -- 1105
		return -- 1107
	end -- 1107
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1109
	local handPt = projectWorld3D( -- 1110
		self.memoryAnchorWorldX, -- 1110
		self.memoryAnchorWorldY, -- 1110
		0, -- 1110
		ctx.cam, -- 1110
		self.outsideProj -- 1110
	) -- 1110
	local cx = math.max( -- 1111
		190, -- 1111
		math.min(ctx.uiW - 190, handPt.x * inv - 20) -- 1111
	) -- 1111
	local cy = math.max( -- 1112
		170, -- 1112
		math.min(ctx.uiH - 150, handPt.y * inv + 104) -- 1112
	) -- 1112
	local pullT = smoothstep(0.14, 0.82, prog) -- 1113
	local zoom = 0.94 + pullT * 0.09 -- 1114
	fillRadialGlow( -- 1117
		uiGlow, -- 1117
		cx, -- 1117
		cy, -- 1117
		215 * zoom, -- 1117
		152 * zoom, -- 1117
		Color( -- 1117
			238, -- 1117
			186, -- 1117
			114, -- 1117
			math.floor(88 * alpha + 0.5) -- 1117
		), -- 1117
		Color(214, 152, 82, 0), -- 1117
		22 -- 1117
	) -- 1117
	uiArt:tryPlace( -- 1118
		"ink_petal_mist", -- 1118
		"fe04_f01_memory_mist", -- 1118
		cx, -- 1118
		cy, -- 1118
		380 * zoom, -- 1118
		260 * zoom, -- 1118
		{ -- 1118
			color = Color(36, 24, 18, 255), -- 1119
			opacity = 0.72 * alpha, -- 1120
			layer = 3 -- 1121
		} -- 1121
	) -- 1121
	if not uiArt:tryPlacePath( -- 1121
		"assets/art/cutscene_story_parts.clip|f01_mother_stitch", -- 1124
		"fe04_f01_mother_stitch", -- 1125
		cx + pullT * 6, -- 1126
		cy + pullT * 4, -- 1127
		296 * zoom, -- 1128
		218 * zoom, -- 1129
		{ -- 1130
			anchorX = 0.5, -- 1131
			anchorY = 0.5, -- 1132
			color = Color(246, 224, 196, 255), -- 1133
			opacity = 0.96 * alpha, -- 1134
			smooth = true, -- 1135
			layer = 4 -- 1136
		} -- 1136
	) then -- 1136
		uiDraw:drawEllipse( -- 1139
			Vec2(cx, cy), -- 1139
			116, -- 1139
			70, -- 1139
			Color( -- 1139
				32, -- 1139
				22, -- 1139
				16, -- 1139
				math.floor(196 * alpha + 0.5) -- 1139
			) -- 1139
		) -- 1139
	end -- 1139
end -- 1094
function ____exports.createLowpolyWorldPlugin() -- 1144
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1145
end -- 1144
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1149
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1152
	fe:registerPlugin(lowpolyWorld) -- 1153
	return {lowpolyWorld = lowpolyWorld} -- 1154
end -- 1149
return ____exports -- 1149