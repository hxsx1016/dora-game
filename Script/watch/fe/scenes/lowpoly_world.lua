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
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 46
local drawComicInsertPanel = ____slideshow.drawComicInsertPanel -- 46
local ____theme = require("Script.watch.fe.theme") -- 47
local fillRadialGlow = ____theme.fillRadialGlow -- 48
local fillVGradRect = ____theme.fillVGradRect -- 49
local rgba = ____theme.rgba -- 50
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 54
--- 首次握车柄家人缝布回忆总时长（秒）：约半秒叠画再落回车柄，拉车输入全程不断档
local SEWING_MEMORY_DURATION = 0.54 -- 56
____exports.LowpolyWorldPlugin = __TS__Class() -- 77
local LowpolyWorldPlugin = ____exports.LowpolyWorldPlugin -- 77
LowpolyWorldPlugin.name = "LowpolyWorldPlugin" -- 77
function LowpolyWorldPlugin.prototype.____constructor(self) -- 77
	self.id = "fe-04-child-lowpoly" -- 78
	self.village = __TS__New(VillageUndertableScene) -- 80
	self.forest = __TS__New(ForestCreekScene) -- 81
	self.active = false -- 83
	self.wasActive = false -- 84
	self.activeRoomKey = "" -- 85
	self.animTime = 0 -- 86
	self.prevGripping = false -- 89
	self.prevCartAxle = 0 -- 90
	self.cartWheelVol = 0 -- 91
	self.cartClothLeftInvariantOk = true -- 92
	self.lastCartClothX = 0 -- 93
	self.lastCartAxle = 0 -- 94
	self.memoryPlayed = false -- 95
	self.memoryTriggeredCount = 0 -- 96
	self.memoryTimer = -1 -- 97
	self.memoryAnchorWorldX = 344 -- 98
	self.memoryAnchorWorldY = 122 -- 99
	self.outsideProj = { -- 101
		morph = 1, -- 102
		focal = 410, -- 103
		vpFracX = 0.54, -- 104
		vpFracY = 0.52, -- 105
		vpOffsetX = 0, -- 106
		vpOffsetY = 0, -- 107
		baseDepth = 0 -- 108
	} -- 108
	self.towerProj = { -- 111
		morph = 1, -- 112
		focal = 415, -- 113
		vpFracX = 0.52, -- 114
		vpFracY = 0.5, -- 115
		vpOffsetX = 0, -- 116
		vpOffsetY = 0, -- 117
		baseDepth = 0 -- 118
	} -- 118
end -- 77
function LowpolyWorldPlugin.prototype.onBindPlay(self, p, _view) -- 121
	self:resetRoomState(p) -- 122
	self:syncRuntimeHook() -- 123
end -- 121
function LowpolyWorldPlugin.prototype.resetRoomState(self, p) -- 126
	self.active = false -- 127
	self.wasActive = false -- 128
	self.activeRoomKey = p ~= nil and p.room.key or "" -- 129
	self.animTime = 0 -- 130
	self.prevGripping = false -- 131
	self.prevCartAxle = p ~= nil and p.cartAxle or 0 -- 132
	self.cartWheelVol = 0 -- 133
	self.cartClothLeftInvariantOk = true -- 134
	self.lastCartAxle = self.prevCartAxle -- 135
	self.lastCartClothX = p ~= nil and p.room.cart.bodyW > 0 and p.cartAxle - p.room.cart.bodyW * 0.5 or 0 -- 136
	self.memoryPlayed = false -- 137
	self.memoryTriggeredCount = 0 -- 138
	self.memoryTimer = -1 -- 139
	self.village:reset() -- 140
	self.forest:reset() -- 141
end -- 126
function LowpolyWorldPlugin.prototype.syncRuntimeHook(self) -- 144
	local g = _G -- 145
	local ____temp_0 -- 146
	if g.package ~= nil then -- 146
		____temp_0 = g.package.loaded -- 146
	else -- 146
		____temp_0 = nil -- 146
	end -- 146
	local loaded = ____temp_0 -- 146
	if loaded == nil then -- 146
		return -- 148
	end -- 148
	local rawFe = loaded["watch.fe"] -- 150
	if rawFe ~= nil and type(rawFe) == "table" then -- 150
		local watchFe = rawFe -- 152
		if watchFe.lowpolyWorld ~= self then -- 152
			watchFe.lowpolyWorld = self -- 154
		end -- 154
	end -- 154
end -- 144
function LowpolyWorldPlugin.prototype.isLowpolyChildRoom(self, roomKey) -- 159
	return roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" -- 160
end -- 159
function LowpolyWorldPlugin.prototype.shouldActivate(self, ctx) -- 163
	return ctx.view.visualMode == "lowpoly" and self:isLowpolyChildRoom(ctx.p.room.key) -- 164
end -- 163
function LowpolyWorldPlugin.prototype.getActiveProjection(self, roomKey) -- 167
	local key = roomKey or self.activeRoomKey -- 168
	if key == "village" then -- 168
		return self.village:getProjection() -- 170
	end -- 170
	if key == "forest" then -- 170
		return self.forest:getProjection() -- 173
	end -- 173
	if key == "tower" then -- 173
		return self.towerProj -- 176
	end -- 176
	return self.outsideProj -- 178
end -- 167
function LowpolyWorldPlugin.prototype.getDebugState(self, p) -- 181
	local memActive = self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION -- 182
	return { -- 183
		active = self.active, -- 184
		roomKey = self.activeRoomKey, -- 185
		outside = { -- 186
			active = self.active and self.activeRoomKey == "outside", -- 187
			cartClothLeftInvariantOk = self.cartClothLeftInvariantOk, -- 188
			cartClothWorldX = self.lastCartClothX, -- 189
			cartAxleWorldX = self.lastCartAxle, -- 190
			memoryTriggeredCount = self.memoryTriggeredCount, -- 191
			memoryActive = memActive, -- 192
			memoryProgress = memActive and clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) or (self.memoryPlayed and 1 or 0), -- 193
			cartWheelVol = self.cartWheelVol -- 194
		}, -- 194
		village = self.village:getDebugState(p), -- 196
		forest = self.forest:getDebugState(p) -- 197
	} -- 197
end -- 181
function LowpolyWorldPlugin.prototype.rehearseOutsideSewingMemory(self, progress) -- 202
	self.memoryPlayed = true -- 203
	self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 204
	self.memoryTimer = progress ~= nil and clamp01(progress) * SEWING_MEMORY_DURATION or 0 -- 205
end -- 202
function LowpolyWorldPlugin.prototype.rehearseVillageImpact(self, ctx, surface) -- 209
	self.village:triggerRehearsalImpact(ctx, surface) -- 210
end -- 209
function LowpolyWorldPlugin.prototype.stopAllAudioLoops(self, ctx) -- 213
	ctx.audio:stopLoop("fe04_outside_wind", 0.2) -- 214
	ctx.audio:stopLoop("fe04_cart_wheel", 0.15) -- 215
	ctx.audio:stopLoop("fe04_village_night", 0.2) -- 216
	ctx.audio:stopLoop("fe04_forest_wind", 0.2) -- 217
	ctx.audio:stopLoop("fe04_creek_water", 0.2) -- 218
end -- 213
function LowpolyWorldPlugin.prototype.update(self, ctx) -- 221
	self:syncRuntimeHook() -- 222
	local want = self:shouldActivate(ctx) -- 223
	if not want then -- 223
		if self.wasActive then -- 223
			ctx.cam:setAnchorLock(nil) -- 226
			self:stopAllAudioLoops(ctx) -- 227
			self.wasActive = false -- 228
		end -- 228
		self.active = false -- 230
		return -- 231
	end -- 231
	local p = ctx.p -- 234
	if self.activeRoomKey ~= "" and self.activeRoomKey ~= p.room.key then -- 234
		ctx.cam:setAnchorLock(nil) -- 236
		self:stopAllAudioLoops(ctx) -- 237
		self:resetRoomState(p) -- 238
	end -- 238
	self.active = true -- 241
	self.wasActive = true -- 242
	self.activeRoomKey = p.room.key -- 243
	if not ctx.paused and ctx.worldDt > 0 then -- 243
		self.animTime = self.animTime + ctx.worldDt -- 246
	end -- 246
	if p.room.key == "outside" then -- 246
		self:updateOutside(ctx) -- 250
	elseif p.room.key == "village" then -- 250
		self.village:update(ctx) -- 252
	elseif p.room.key == "forest" then -- 252
		self.forest:update(ctx) -- 254
	elseif p.room.key == "tower" then -- 254
		ctx.cam:setAnchorLock(nil) -- 256
		self.towerProj = { -- 257
			morph = 1, -- 258
			focal = 415, -- 259
			vpFracX = 0.52, -- 260
			vpFracY = 0.5, -- 261
			vpOffsetX = math.sin(self.animTime * 0.45) * 1.2, -- 262
			vpOffsetY = math.cos(self.animTime * 0.6) * 0.8, -- 263
			baseDepth = 0 -- 264
		} -- 264
	end -- 264
end -- 221
function LowpolyWorldPlugin.prototype.updateOutside(self, ctx) -- 269
	local p = ctx.p -- 270
	ctx.cam:setAnchorLock(nil) -- 271
	local c = p.room.cart -- 273
	if c.bodyW > 0 then -- 273
		self.lastCartAxle = p.cartAxle -- 276
		self.lastCartClothX = p.cartAxle - c.bodyW * 0.5 -- 277
		if self.lastCartClothX >= self.lastCartAxle or c.clothSide >= 0 then -- 277
			self.cartClothLeftInvariantOk = false -- 279
		end -- 279
		self.memoryAnchorWorldX = p.cartAxle + c.handleOffset -- 281
		self.memoryAnchorWorldY = c.baseY + c.wheelR + c.bodyH * 0.72 -- 282
	end -- 282
	if not ctx.paused and ctx.worldDt > 0 then -- 282
		local dt = ctx.worldDt -- 286
		local redCartMemTrigger = p.redCartMemoryT > 0 and not self.memoryPlayed -- 289
		if (p.gripping and not self.prevGripping or redCartMemTrigger) and not self.memoryPlayed then -- 289
			self.memoryPlayed = true -- 291
			self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 292
			self.memoryTimer = 0 -- 293
			if redCartMemTrigger then -- 293
				self.memoryAnchorWorldX = p.player.x -- 295
				self.memoryAnchorWorldY = p.player.y + 36 -- 296
			end -- 296
			ctx.audio:playOnce( -- 298
				"fe04:outside:sewing:" .. tostring(ctx.events.roomSessionId), -- 299
				"ambience", -- 300
				CHILD_AUDIO_ROOT .. "sewing_memory.wav", -- 301
				0.68, -- 302
				"fe04:outside:sewing_memory", -- 303
				p.ticks -- 304
			) -- 304
		end -- 304
		self.prevGripping = p.gripping -- 307
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 307
			self.memoryTimer = math.min(SEWING_MEMORY_DURATION, self.memoryTimer + dt) -- 310
		end -- 310
		local cartSpeed = math.abs(p.cartAxle - self.prevCartAxle) / math.max(0.001, dt) -- 314
		self.prevCartAxle = p.cartAxle -- 315
		local targetWheelVol = cartSpeed > 4 and math.min(0.54, 0.22 + cartSpeed / 64 * 0.32) or 0 -- 316
		self.cartWheelVol = self.cartWheelVol + (targetWheelVol - self.cartWheelVol) * math.min(1, dt * 10) -- 317
		ctx.audio:playLoop( -- 319
			"fe04_outside_wind", -- 319
			"wind", -- 319
			CHILD_AUDIO_ROOT .. "wind_outside_loop.wav", -- 319
			0.36, -- 319
			p.ticks -- 319
		) -- 319
		if self.cartWheelVol > 0.03 then -- 319
			ctx.audio:playLoop( -- 321
				"fe04_cart_wheel", -- 321
				"ambience", -- 321
				CHILD_AUDIO_ROOT .. "cart_wheel_loop.wav", -- 321
				self.cartWheelVol, -- 321
				p.ticks -- 321
			) -- 321
		else -- 321
			ctx.audio:stopLoop("fe04_cart_wheel", 0.12) -- 323
		end -- 323
	end -- 323
	self.outsideProj = { -- 327
		morph = 1, -- 328
		focal = 410, -- 329
		vpFracX = 0.54, -- 330
		vpFracY = 0.52, -- 331
		vpOffsetX = math.sin(self.animTime * 0.52) * 1.5, -- 332
		vpOffsetY = math.cos(self.animTime * 0.68) * 1, -- 333
		baseDepth = 0 -- 334
	} -- 334
end -- 269
function LowpolyWorldPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 338
	if not self.active then -- 338
		return false -- 345
	end -- 345
	local key = ctx.p.room.key -- 347
	if key == "village" then -- 347
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 349
	end -- 349
	if key == "forest" then -- 349
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 352
	end -- 352
	if key == "outside" then -- 352
		return self:drawOutsideBackdrop(bgDraw, bgGlow, ctx) -- 355
	end -- 355
	if key == "tower" then -- 355
		return self:drawTowerBackdrop(bgDraw, bgGlow, ctx) -- 358
	end -- 358
	return false -- 360
end -- 338
function LowpolyWorldPlugin.prototype.drawOutsideBackdrop(self, bgDraw, bgGlow, ctx) -- 363
	local p = ctx.p -- 364
	local cam = ctx.cam -- 365
	local w = cam.viewW -- 366
	local h = cam.viewH -- 367
	local ox = p.ox -- 368
	local splitY = h * 0.48 -- 371
	fillVGradRect( -- 372
		bgDraw, -- 372
		0, -- 372
		splitY, -- 372
		w, -- 372
		h - splitY, -- 372
		Color(16, 25, 38, 255), -- 372
		Color(8, 13, 22, 255) -- 372
	) -- 372
	fillVGradRect( -- 373
		bgDraw, -- 373
		0, -- 373
		0, -- 373
		w, -- 373
		splitY, -- 373
		Color(30, 44, 62, 255), -- 373
		Color(16, 25, 38, 255) -- 373
	) -- 373
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 375
	scene:addBox({ -- 377
		x0 = ox - 160, -- 378
		x1 = ox + 1360, -- 379
		y0 = -48, -- 380
		y1 = 112, -- 381
		z0 = 230, -- 382
		z1 = 274, -- 383
		material = MING_MATERIALS.distantWall, -- 384
		bucket = LP_BUCKET.BACKDROP, -- 385
		edgeWidth = 0 -- 386
	}) -- 386
	local mx = ox - 80 -- 388
	local mi = 0 -- 389
	do -- 389
		mi = 0 -- 390
		while mi < 18 do -- 390
			scene:addBox({ -- 391
				x0 = mx, -- 392
				x1 = mx + 32, -- 393
				y0 = 112, -- 394
				y1 = 128, -- 395
				z0 = 230, -- 396
				z1 = 256, -- 397
				material = MING_MATERIALS.distantWall, -- 398
				bucket = LP_BUCKET.BACKDROP, -- 399
				sortBias = 0.04, -- 400
				edgeWidth = 0 -- 401
			}) -- 401
			mx = mx + 78 -- 403
			mi = mi + 1 -- 390
		end -- 390
	end -- 390
	scene:addCutout3D( -- 406
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 406
		ox + 280, -- 406
		96, -- 406
		224, -- 406
		152, -- 406
		100, -- 406
		{ -- 406
			bucket = LP_BUCKET.BACKDROP, -- 407
			anchorX = 0.5, -- 408
			anchorY = 0, -- 409
			color = rgba(114, 134, 156, 255), -- 410
			opacity = 0.84, -- 411
			sortBias = 0.05 -- 412
		} -- 412
	) -- 412
	scene:addCutout3D( -- 414
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 414
		ox + 810, -- 414
		96, -- 414
		226, -- 414
		148, -- 414
		98, -- 414
		{ -- 414
			bucket = LP_BUCKET.BACKDROP, -- 415
			facing = -1, -- 416
			anchorX = 0.5, -- 417
			anchorY = 0, -- 418
			color = rgba(108, 128, 152, 255), -- 419
			opacity = 0.8, -- 420
			sortBias = 0.05 -- 421
		} -- 421
	) -- 421
	scene:addCutout3D( -- 423
		"assets/art/diorama_cutouts.clip|north_tower_distant", -- 423
		ox + 1140, -- 423
		48, -- 423
		405, -- 423
		118, -- 423
		150, -- 423
		{ -- 423
			bucket = LP_BUCKET.BACKDROP, -- 424
			anchorX = 0.5, -- 425
			anchorY = 0, -- 426
			color = rgba(136, 156, 178, 255), -- 427
			opacity = 0.9, -- 428
			sortBias = 0.08 -- 429
		} -- 429
	) -- 429
	scene:addFogBand( -- 431
		ox - 180, -- 431
		ox + 1420, -- 431
		-34, -- 431
		152, -- 431
		180, -- 431
		rgba(28, 42, 60, 255), -- 431
		0.58, -- 431
		0.06, -- 431
		{bucket = LP_BUCKET.BACKDROP} -- 431
	) -- 431
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 434
	local moonX = w * 0.76 -- 437
	local moonY = h * 0.83 -- 438
	fillRadialGlow( -- 439
		bgGlow, -- 439
		moonX, -- 439
		moonY, -- 439
		82, -- 439
		82, -- 439
		Color(172, 206, 232, 28), -- 439
		Color(24, 42, 68, 0), -- 439
		16 -- 439
	) -- 439
	bgDraw:drawCircle( -- 440
		Vec2(moonX, moonY), -- 440
		14, -- 440
		Color(218, 232, 246, 165) -- 440
	) -- 440
	local beaconP = projectWorld3D( -- 442
		ox + 1140, -- 442
		154, -- 442
		410, -- 442
		cam, -- 442
		self.outsideProj -- 442
	) -- 442
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 443
	fillRadialGlow( -- 444
		bgGlow, -- 444
		beaconP.x, -- 444
		beaconP.y, -- 444
		32 * pulse, -- 444
		32 * pulse, -- 444
		Color( -- 444
			246, -- 444
			208, -- 444
			138, -- 444
			math.floor(92 * pulse + 0.5) -- 444
		), -- 444
		Color(232, 176, 86, 0), -- 444
		14 -- 444
	) -- 444
	bgGlow:drawDot( -- 445
		Vec2(beaconP.x, beaconP.y), -- 445
		2.5, -- 445
		Color(255, 244, 212, 235) -- 445
	) -- 445
	return true -- 447
end -- 363
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, ctx) -- 450
	local cam = ctx.cam -- 451
	local p = ctx.p -- 452
	local ox = p.ox -- 453
	local w = cam.viewW -- 454
	local h = cam.viewH -- 455
	local splitY = h * 0.46 -- 458
	fillVGradRect( -- 459
		bgDraw, -- 459
		0, -- 459
		splitY, -- 459
		w, -- 459
		h - splitY, -- 459
		Color(24, 34, 52, 255), -- 459
		Color(12, 18, 30, 255) -- 459
	) -- 459
	fillVGradRect( -- 460
		bgDraw, -- 460
		0, -- 460
		0, -- 460
		w, -- 460
		splitY, -- 460
		Color(46, 54, 70, 255), -- 460
		Color(24, 34, 52, 255) -- 460
	) -- 460
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 462
	scene:addDistantRidge( -- 463
		{ -- 464
			{x = ox - 180, y = 118}, -- 465
			{x = ox + 90, y = 172}, -- 466
			{x = ox + 360, y = 146}, -- 467
			{x = ox + 640, y = 184}, -- 468
			{x = ox + 920, y = 132} -- 469
		}, -- 469
		-40, -- 469
		420, -- 472
		MING_MATERIALS.distantHill, -- 473
		{bucket = LP_BUCKET.BACKDROP} -- 474
	) -- 474
	scene:addFogBand( -- 476
		ox - 160, -- 476
		ox + 900, -- 476
		-24, -- 476
		150, -- 476
		260, -- 476
		rgba(36, 42, 58, 255), -- 476
		0.56, -- 476
		0.06, -- 476
		{bucket = LP_BUCKET.BACKDROP} -- 476
	) -- 476
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 479
	return true -- 481
end -- 450
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 484
	if not self.active then -- 484
		return false -- 491
	end -- 491
	local key = ctx.p.room.key -- 493
	if key == "village" then -- 493
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 495
	end -- 495
	if key == "forest" then -- 495
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 498
	end -- 498
	if key == "outside" then -- 498
		return self:drawOutsideWorld(fgDraw, fgGlow, ctx) -- 501
	end -- 501
	if key == "tower" then -- 501
		return self:drawTowerWorld(fgDraw, fgGlow, ctx) -- 504
	end -- 504
	return false -- 506
end -- 484
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, ctx) -- 509
	local p = ctx.p -- 510
	local cam = ctx.cam -- 511
	local ox = p.ox -- 512
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 513
	buildOutsideJettyLowpoly( -- 516
		scene, -- 516
		p.room, -- 516
		p.player.x, -- 516
		p.player.y, -- 516
		p.cartAxle, -- 516
		self.animTime -- 516
	) -- 516
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
	local latch = p:cartLatchBounds() -- 563
	if latch ~= nil then -- 563
		local bx0 = latch.x -- 565
		local bx1 = latch.x + latch.width -- 566
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
end -- 509
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
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1067
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1067
		return -- 1075
	end -- 1075
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1077
	local alpha = smoothstep(0, 0.16, prog) * (1 - smoothstep(0.76, 1, prog)) -- 1078
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
	local panelW = math.min( -- 1086
		352, -- 1086
		math.floor(ctx.uiW * 0.28 + 0.5) -- 1086
	) -- 1086
	local panelH = math.floor(panelW * 9 / 16 + 0.5) -- 1087
	local cx = math.max( -- 1088
		panelW * 0.5 + 24, -- 1088
		math.min(ctx.uiW - panelW * 0.5 - 24, handPt.x * inv - 16) -- 1088
	) -- 1088
	local cy = math.max( -- 1089
		panelH * 0.5 + 28, -- 1089
		math.min(ctx.uiH - panelH * 0.5 - 28, handPt.y * inv + 112) -- 1089
	) -- 1089
	local seq = { -- 1090
		{slot = "comic_f01_f01", start = 0, ["end"] = 0.083, transition = "cut"}, -- 1091
		{slot = "comic_f01_f02", start = 0.083, ["end"] = 0.166, transition = "cut"}, -- 1092
		{slot = "comic_f01_f03", start = 0.166, ["end"] = 0.25, transition = "cut"}, -- 1093
		{slot = "comic_f01_f04", start = 0.25, ["end"] = 0.333, transition = "cut"}, -- 1094
		{slot = "comic_f01_f05", start = 0.333, ["end"] = 0.416, transition = "cut"}, -- 1095
		{slot = "comic_f01_f06", start = 0.416, ["end"] = 0.5, transition = "cut"}, -- 1096
		{slot = "comic_f01_f07", start = 0.5, ["end"] = 0.583, transition = "cut"}, -- 1097
		{slot = "comic_f01_f08", start = 0.583, ["end"] = 0.666, transition = "cut"}, -- 1098
		{slot = "comic_f01_f09", start = 0.666, ["end"] = 0.75, transition = "cut"}, -- 1099
		{slot = "comic_f01_f10", start = 0.75, ["end"] = 0.833, transition = "cut"}, -- 1100
		{slot = "comic_f01_f11", start = 0.833, ["end"] = 0.916, transition = "cut"}, -- 1101
		{slot = "comic_f01_f12", start = 0.916, ["end"] = 1, transition = "cut"} -- 1102
	} -- 1102
	fillRadialGlow( -- 1106
		uiGlow, -- 1106
		cx, -- 1106
		cy, -- 1106
		panelW * 0.68, -- 1106
		panelH * 0.76, -- 1106
		Color( -- 1106
			238, -- 1106
			186, -- 1106
			114, -- 1106
			math.floor(74 * alpha + 0.5) -- 1106
		), -- 1106
		Color(214, 152, 82, 0), -- 1106
		20 -- 1106
	) -- 1106
	drawComicInsertPanel( -- 1107
		uiDraw, -- 1108
		uiInkDraw, -- 1109
		uiArt, -- 1110
		seq, -- 1111
		prog, -- 1112
		{x = cx - panelW * 0.5, y = cy - panelH * 0.5, w = panelW, h = panelH}, -- 1113
		alpha, -- 1114
		"fe04_f01_comic", -- 1115
		4 -- 1116
	) -- 1116
end -- 1067
function ____exports.createLowpolyWorldPlugin() -- 1121
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1122
end -- 1121
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1126
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1129
	fe:registerPlugin(lowpolyWorld) -- 1130
	return {lowpolyWorld = lowpolyWorld} -- 1131
end -- 1126
return ____exports -- 1126