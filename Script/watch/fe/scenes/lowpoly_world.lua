-- [ts]: lowpoly_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local ____exports = {} -- 1
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 1
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 1
local drawSlideFrameChrome = ____slideshow.drawSlideFrameChrome -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 25
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 26
local LowpolyScene = ____lowpoly.LowpolyScene -- 28
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 29
local OUTSIDE_JETTY_LIGHT = ____lowpoly.OUTSIDE_JETTY_LIGHT -- 30
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 31
local buildOutsideJettyLowpoly = ____lowpoly.buildOutsideJettyLowpoly -- 32
local clamp01 = ____lowpoly.clamp01 -- 33
local projectWorld3D = ____lowpoly.projectWorld3D -- 34
local smoothstep = ____lowpoly.smoothstep -- 35
local vec3 = ____lowpoly.vec3 -- 36
local ____village_undertable = require("Script.watch.fe.scenes.village_undertable") -- 38
local VillageUndertableScene = ____village_undertable.VillageUndertableScene -- 41
local ____forest_creek = require("Script.watch.fe.scenes.forest_creek") -- 43
local ForestCreekScene = ____forest_creek.ForestCreekScene -- 45
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
	local redBox = __TS__ArrayFind( -- 519
		p.boxes, -- 519
		function(____, b) return b.id == "outside_red_cart" end -- 519
	) -- 519
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 519
		scene:addBox({ -- 521
			x0 = redBox.x0 + 2, -- 522
			x1 = redBox.x1 - 2, -- 523
			y0 = redBox.y0 + 10, -- 524
			y1 = redBox.y1, -- 525
			z0 = -10, -- 526
			z1 = 12, -- 527
			material = MING_MATERIALS.mingTimber, -- 528
			bucket = LP_BUCKET.PROP, -- 529
			highlightTopEdge = true, -- 530
			edgeWidth = 0.9 -- 531
		}) -- 531
		scene:addWavingQuad3D( -- 534
			vec3(redBox.x0 - 4, redBox.y0 + 10, -12), -- 535
			vec3(redBox.x0 + 14, redBox.y0 + 12, -11), -- 536
			vec3(redBox.x0 + 18, redBox.y1, -10), -- 537
			vec3(redBox.x0 + 4, redBox.y1, -11), -- 538
			MING_MATERIALS.mingRedCloth, -- 539
			{ -- 540
				ampX = 4.5, -- 540
				ampY = 1.8, -- 540
				phase = self.animTime * 2.9, -- 540
				freqU = 1.8, -- 540
				freqV = 2.4, -- 540
				pin = "top" -- 540
			}, -- 540
			{bucket = LP_BUCKET.PROP, sortBias = 0.26, subdivX = 3, subdivY = 3} -- 541
		) -- 541
	end -- 541
	local c = p.room.cart -- 546
	if c.bodyW > 0 then -- 546
		scene:addBox({ -- 549
			x0 = c.endX - 18, -- 550
			x1 = c.endX + 18, -- 551
			y0 = c.baseY - 4, -- 552
			y1 = c.baseY + 2, -- 553
			z0 = -12, -- 554
			z1 = 14, -- 555
			material = MING_MATERIALS.mingIron, -- 556
			bucket = LP_BUCKET.WALK_DECK, -- 557
			sortBias = 0.35, -- 558
			highlightTopEdge = true -- 559
		}) -- 559
		scene:addBox({ -- 562
			x0 = ox + 258, -- 563
			x1 = ox + 474, -- 564
			y0 = c.baseY - 1.5, -- 565
			y1 = c.baseY + 0.4, -- 566
			z0 = -11, -- 567
			z1 = -7, -- 568
			material = MING_MATERIALS.mingTimberDark, -- 569
			bucket = LP_BUCKET.WALK_DECK, -- 570
			sortBias = 0.3, -- 571
			edgeWidth = 0 -- 572
		}) -- 572
		scene:addBox({ -- 574
			x0 = ox + 258, -- 575
			x1 = ox + 474, -- 576
			y0 = c.baseY - 1.5, -- 577
			y1 = c.baseY + 0.4, -- 578
			z0 = 7, -- 579
			z1 = 11, -- 580
			material = MING_MATERIALS.mingTimberDark, -- 581
			bucket = LP_BUCKET.WALK_DECK, -- 582
			sortBias = 0.3, -- 583
			edgeWidth = 0 -- 584
		}) -- 584
	end -- 584
	if not p.cartDocked and p.room.arch.h > 0 then -- 584
		local bx0 = math.max(p.room.arch.x0 + 4, p.cartAxle - 18) -- 591
		local bx1 = math.min(p.room.arch.x1 - 4, p.cartAxle + 18) -- 592
		if bx1 > bx0 + 4 then -- 592
			scene:addBox({ -- 594
				x0 = bx0, -- 595
				x1 = bx1, -- 596
				y0 = 2, -- 597
				y1 = p.room.arch.h, -- 598
				z0 = -6, -- 599
				z1 = 8, -- 600
				material = MING_MATERIALS.mingTimberDark, -- 601
				bucket = LP_BUCKET.PROP, -- 602
				highlightTopEdge = true, -- 603
				edgeWidth = 0.9 -- 604
			}) -- 604
			scene:addBox({ -- 607
				x0 = (bx0 + bx1) * 0.5 - 3, -- 608
				x1 = (bx0 + bx1) * 0.5 + 3, -- 609
				y0 = p.room.arch.h, -- 610
				y1 = p.room.cart.baseY, -- 611
				z0 = -3, -- 612
				z1 = 5, -- 613
				material = MING_MATERIALS.mingIron, -- 614
				bucket = LP_BUCKET.PROP, -- 615
				edgeWidth = 0.6 -- 616
			}) -- 616
		end -- 616
	end -- 616
	scene:addBox({ -- 622
		x0 = ox + 128, -- 623
		x1 = ox + 598, -- 624
		y0 = 0, -- 625
		y1 = 92, -- 626
		z0 = 44, -- 627
		z1 = 72, -- 628
		material = MING_MATERIALS.mingBrickDark, -- 629
		bucket = LP_BUCKET.MIDGROUND, -- 630
		sortBias = -0.2, -- 631
		edgeWidth = 0.5 -- 632
	}) -- 632
	scene:addQuad3D( -- 635
		vec3(ox + 132, 26, 43), -- 636
		vec3(ox + 592, 26, 43), -- 637
		vec3(ox + 592, 31, 43), -- 638
		vec3(ox + 132, 31, 43), -- 639
		{base = rgba(138, 148, 158, 92)}, -- 640
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.1} -- 641
	) -- 641
	scene:addLightShaft( -- 645
		ox + 1110, -- 646
		ox + 1180, -- 646
		170, -- 646
		ox + 1040, -- 647
		ox + 1140, -- 647
		0, -- 647
		34, -- 648
		rgba(234, 198, 138, 255), -- 649
		0.14, -- 650
		0.03 -- 651
	) -- 651
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 654
	local gi = 0 -- 657
	do -- 657
		gi = 0 -- 658
		while gi < 6 do -- 658
			local gx = ox + 165 + gi * 56 -- 659
			local p0 = projectWorld3D( -- 660
				gx, -- 660
				0.5, -- 660
				-14, -- 660
				cam, -- 660
				self.outsideProj -- 660
			) -- 660
			local p1 = projectWorld3D( -- 661
				gx + 10, -- 661
				0.5, -- 661
				22, -- 661
				cam, -- 661
				self.outsideProj -- 661
			) -- 661
			fgDraw:drawSegment( -- 662
				Vec2(p0.x, p0.y), -- 662
				Vec2(p1.x, p1.y), -- 662
				3, -- 662
				Color(8, 12, 18, 76) -- 662
			) -- 662
			gi = gi + 1 -- 658
		end -- 658
	end -- 658
	return true -- 665
end -- 509
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, ctx) -- 668
	local p = ctx.p -- 669
	local cam = ctx.cam -- 670
	local ox = p.ox -- 671
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 672
	local scene = __TS__New(LowpolyScene, cam, self.towerProj, TOWER_WEST_LAMP_LIGHT) -- 677
	scene:addBox({ -- 680
		x0 = ox - 40, -- 681
		x1 = ox + 760, -- 682
		y0 = -52, -- 683
		y1 = 0, -- 684
		z0 = -26, -- 685
		z1 = 96, -- 686
		material = MING_MATERIALS.mingBrickDark, -- 687
		bucket = LP_BUCKET.WALK_DECK, -- 688
		highlightTopEdge = true -- 689
	}) -- 689
	scene:addBox({ -- 692
		x0 = ox + 398, -- 693
		x1 = ox + 492, -- 694
		y0 = -4, -- 695
		y1 = 2.5, -- 696
		z0 = -16, -- 697
		z1 = 26, -- 698
		material = MING_MATERIALS.mingStoneStep, -- 699
		bucket = LP_BUCKET.WALK_DECK, -- 700
		sortBias = 0.15, -- 701
		highlightTopEdge = true -- 702
	}) -- 702
	scene:addBox({ -- 706
		x0 = ox + 180, -- 707
		x1 = ox + 400, -- 708
		y0 = 0, -- 709
		y1 = 215, -- 710
		z0 = -8, -- 711
		z1 = 96, -- 712
		material = MING_MATERIALS.mingBrick, -- 713
		bucket = LP_BUCKET.MIDGROUND, -- 714
		highlightTopEdge = true -- 715
	}) -- 715
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
	scene:addBeveledFrame( -- 730
		ox + 400, -- 730
		ox + 490, -- 730
		0, -- 730
		110, -- 730
		14, -- 730
		34, -- 730
		-8, -- 730
		68, -- 730
		MING_MATERIALS.mingStoneStep, -- 730
		{ -- 730
			bucket = LP_BUCKET.MIDGROUND, -- 731
			innerRimLight = rgba(244, 206, 140, 255), -- 732
			innerRimStrength = opened and 0.78 or 0.32 -- 733
		} -- 733
	) -- 733
	scene:addCutout3D( -- 737
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 737
		ox + 445, -- 737
		206, -- 737
		18, -- 737
		240, -- 737
		142, -- 737
		{ -- 737
			bucket = LP_BUCKET.MIDGROUND, -- 738
			anchorX = 0.5, -- 739
			anchorY = 0, -- 740
			color = rgba(154, 168, 184, 255), -- 741
			opacity = 0.92, -- 742
			sortBias = 0.08 -- 743
		} -- 743
	) -- 743
	if not opened then -- 743
		scene:addCutout3D( -- 748
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 748
			ox + 445, -- 748
			2, -- 748
			14, -- 748
			84, -- 748
			108, -- 748
			{ -- 748
				bucket = LP_BUCKET.MIDGROUND, -- 749
				anchorX = 0.5, -- 750
				anchorY = 0, -- 751
				color = rgba(186, 182, 176, 255), -- 752
				opacity = 0.98, -- 753
				sortBias = 0.14 -- 754
			} -- 754
		) -- 754
	else -- 754
		scene:addQuad3D( -- 757
			vec3(ox + 404, 2, 24), -- 758
			vec3(ox + 486, 2, 24), -- 759
			vec3(ox + 486, 109, 24), -- 760
			vec3(ox + 404, 109, 24), -- 761
			{base = rgba(112, 78, 42, 255)}, -- 762
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 763
		) -- 763
	end -- 763
	scene:addQuad3D( -- 768
		vec3(ox + 286, 118, -9), -- 769
		vec3(ox + 306, 118, -9), -- 770
		vec3(ox + 306, 158, -9), -- 771
		vec3(ox + 286, 158, -9), -- 772
		{base = rgba(244, 204, 134, 255)}, -- 773
		{ -- 774
			bucket = LP_BUCKET.PROP, -- 774
			unlit = true, -- 774
			edgeColor = rgba(82, 68, 52, 255), -- 774
			edgeWidth = 1.4 -- 774
		} -- 774
	) -- 774
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 778
	scene:addLightShaft( -- 779
		ox + 412, -- 780
		ox + 478, -- 780
		106, -- 780
		ox + 382, -- 781
		ox + 506, -- 781
		0, -- 781
		6, -- 782
		rgba(246, 208, 138, 255), -- 783
		(opened and 0.34 or 0.08) * pulse, -- 784
		(opened and 0.16 or 0.04) * pulse -- 785
	) -- 785
	scene:addContactShadow( -- 789
		p.player.x, -- 789
		p.player.y, -- 789
		15, -- 789
		11, -- 789
		0.78, -- 789
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 789
	) -- 789
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 791
	local lampP = projectWorld3D( -- 794
		ox + 445, -- 794
		102, -- 794
		2, -- 794
		cam, -- 794
		self.towerProj -- 794
	) -- 794
	fillRadialGlow( -- 795
		fgGlow, -- 796
		lampP.x, -- 797
		lampP.y, -- 798
		cam:len(opened and 64 or 34) * pulse, -- 799
		cam:len(opened and 64 or 34) * pulse, -- 800
		Color( -- 801
			248, -- 801
			214, -- 801
			146, -- 801
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 801
		), -- 801
		Color(232, 174, 82, 0), -- 802
		16 -- 803
	) -- 803
	fgDraw:drawCircle( -- 805
		Vec2(lampP.x, lampP.y), -- 805
		4.2, -- 805
		Color(255, 240, 202, 245) -- 805
	) -- 805
	local winP = projectWorld3D( -- 807
		ox + 296, -- 807
		138, -- 807
		-9, -- 807
		cam, -- 807
		self.towerProj -- 807
	) -- 807
	fillRadialGlow( -- 808
		fgGlow, -- 808
		winP.x, -- 808
		winP.y, -- 808
		cam:len(38), -- 808
		cam:len(42), -- 808
		Color( -- 808
			246, -- 808
			206, -- 808
			132, -- 808
			math.floor(78 * pulse + 0.5) -- 808
		), -- 808
		Color(232, 174, 82, 0), -- 808
		14 -- 808
	) -- 808
	local wBL = projectWorld3D( -- 810
		ox + 286, -- 810
		118, -- 810
		-9, -- 810
		cam, -- 810
		self.towerProj -- 810
	) -- 810
	local wTR = projectWorld3D( -- 811
		ox + 306, -- 811
		158, -- 811
		-9, -- 811
		cam, -- 811
		self.towerProj -- 811
	) -- 811
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 812
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 813
	fgDraw:drawSegment( -- 814
		Vec2(wMidX, wBL.y), -- 814
		Vec2(wMidX, wTR.y), -- 814
		1.4, -- 814
		Color(68, 52, 38, 225) -- 814
	) -- 814
	fgDraw:drawSegment( -- 815
		Vec2(wBL.x, wMidY), -- 815
		Vec2(wTR.x, wMidY), -- 815
		1.4, -- 815
		Color(68, 52, 38, 225) -- 815
	) -- 815
	return true -- 817
end -- 668
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 820
	if not self.active then -- 820
		return false -- 827
	end -- 827
	local key = ctx.p.room.key -- 829
	if key == "village" then -- 829
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 831
	end -- 831
	if key == "forest" then -- 831
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 834
	end -- 834
	if key == "outside" then -- 834
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, ctx) -- 837
	end -- 837
	if key == "tower" then -- 837
		local p = ctx.p -- 840
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 841
		if opened then -- 841
			local cam = ctx.cam -- 843
			local deskCx = cam:sx(p.ox + 605) -- 844
			local groundY = cam:sy(0) -- 845
			local deskW = cam:len(84) -- 846
			local deskH = cam:len(34) -- 847
			local deskTop = groundY + deskH -- 848
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 849
			fillRadialGlow( -- 850
				fgGlow, -- 850
				deskCx, -- 850
				deskTop + cam:len(28), -- 850
				cam:len(120), -- 850
				cam:len(88), -- 850
				Color( -- 851
					255, -- 851
					198, -- 851
					114, -- 851
					math.floor(74 * pulse + 0.5) -- 851
				), -- 851
				Color(255, 168, 72, 0), -- 851
				16 -- 851
			) -- 851
			local guardX = deskCx + cam:len(26) -- 853
			local writing = p.deskHold >= 24 or p.towerHanded -- 854
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 855
			if not worldArt:tryPlacePath( -- 855
				guardClip, -- 858
				"fe04_tower_guard_npc", -- 858
				guardX, -- 858
				groundY, -- 858
				cam:len(54), -- 858
				cam:len(82), -- 858
				{ -- 858
					anchorX = 0.44, -- 859
					anchorY = 0, -- 860
					preserveAspect = true, -- 861
					facing = -1, -- 862
					opacity = 0.96, -- 863
					layer = 3600 -- 864
				} -- 864
			) then -- 864
				fgDraw:drawRect( -- 866
					Rect( -- 866
						guardX - cam:len(11), -- 866
						groundY, -- 866
						cam:len(22), -- 866
						cam:len(68) -- 866
					), -- 866
					Color(28, 34, 44, 240) -- 866
				) -- 866
			end -- 866
			worldArt:tryPlace( -- 868
				"prop_table", -- 868
				"fe04_tower_desk_prop", -- 868
				deskCx, -- 868
				groundY, -- 868
				deskW * 1.06, -- 868
				deskH * 1.04, -- 868
				{ -- 868
					color = Color(206, 180, 150, 255), -- 869
					opacity = 0.98, -- 870
					layer = 3650 -- 871
				} -- 871
			) -- 871
			if writing then -- 871
				worldArt:tryPlace( -- 874
					"prop_lantern", -- 874
					"fe04_tower_desk_lamp", -- 874
					deskCx + cam:len(34), -- 874
					deskTop + cam:len(10), -- 874
					cam:len(14), -- 874
					cam:len(20), -- 874
					{opacity = 0.96, layer = 3700} -- 874
				) -- 874
				fillRadialGlow( -- 878
					fgGlow, -- 878
					deskCx + cam:len(34), -- 878
					deskTop + cam:len(12), -- 878
					cam:len(24), -- 878
					cam:len(22), -- 878
					Color( -- 878
						255, -- 878
						214, -- 878
						134, -- 878
						math.floor(84 * pulse + 0.5) -- 878
					), -- 878
					Color(255, 180, 86, 0), -- 878
					12 -- 878
				) -- 878
			else -- 878
				fillRadialGlow( -- 880
					fgGlow, -- 880
					deskCx + cam:len(3), -- 880
					deskTop + cam:len(18), -- 880
					cam:len(28), -- 880
					cam:len(26), -- 880
					Color( -- 880
						255, -- 880
						214, -- 880
						134, -- 880
						math.floor(74 * pulse + 0.5) -- 880
					), -- 880
					Color(255, 180, 86, 0), -- 880
					12 -- 880
				) -- 880
			end -- 880
			fgDraw:drawRect( -- 882
				Rect( -- 882
					deskCx + cam:len(2), -- 882
					deskTop + cam:len(1), -- 882
					cam:len(22), -- 882
					cam:len(4) -- 882
				), -- 882
				Color(230, 220, 196, 235) -- 882
			) -- 882
			if p.deskHold >= 12 or p.towerHanded then -- 882
				worldArt:tryPlacePath( -- 884
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 884
					"fe04_tower_desk_pouch", -- 884
					deskCx - cam:len(18), -- 884
					deskTop + cam:len(8), -- 884
					cam:len(18), -- 884
					cam:len(18), -- 884
					{ -- 884
						anchorX = 0.5, -- 885
						anchorY = 0.5, -- 886
						opacity = 0.95, -- 887
						smooth = true, -- 888
						layer = 3710 -- 889
					} -- 889
				) -- 889
			end -- 889
			if p.deskHold >= 24 or p.towerHanded then -- 889
				fgDraw:drawRect( -- 893
					Rect( -- 893
						deskCx - cam:len(4), -- 893
						deskTop + cam:len(1), -- 893
						cam:len(10), -- 893
						cam:len(3) -- 893
					), -- 893
					Color(236, 228, 206, 240) -- 893
				) -- 893
			end -- 893
		end -- 893
		return true -- 896
	end -- 896
	return false -- 898
end -- 820
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, fgGlow, ctx) -- 902
	local p = ctx.p -- 903
	local cam = ctx.cam -- 904
	local c = p.room.cart -- 905
	if c.bodyW <= 0 then -- 905
		return true -- 907
	end -- 907
	local scene = __TS__New(LowpolyScene, cam, self.outsideProj, OUTSIDE_JETTY_LIGHT) -- 909
	local halfW = c.bodyW * 0.5 -- 910
	local axleX = p.cartAxle -- 911
	local axleY = c.baseY + c.wheelR -- 912
	local bodyBot = axleY + 2 -- 913
	local bodyTop = bodyBot + c.bodyH -- 914
	scene:addBox({ -- 917
		x0 = axleX - halfW, -- 918
		x1 = axleX + halfW, -- 919
		y0 = bodyBot, -- 920
		y1 = bodyTop, -- 921
		z0 = -12, -- 922
		z1 = 14, -- 923
		material = MING_MATERIALS.mingTimber, -- 924
		bucket = LP_BUCKET.PROP, -- 925
		highlightTopEdge = true, -- 926
		edgeWidth = 1 -- 927
	}) -- 927
	scene:addBox({ -- 930
		x0 = axleX - halfW - 1, -- 931
		x1 = axleX + halfW + 1, -- 932
		y0 = bodyBot + 4, -- 933
		y1 = bodyBot + 8, -- 934
		z0 = -13, -- 935
		z1 = 15, -- 936
		material = MING_MATERIALS.mingIron, -- 937
		bucket = LP_BUCKET.PROP, -- 938
		sortBias = 0.08 -- 939
	}) -- 939
	local handleX = axleX + c.handleOffset -- 942
	scene:addBox({ -- 943
		x0 = axleX + halfW - 2, -- 944
		x1 = handleX, -- 945
		y0 = bodyTop - 6, -- 946
		y1 = bodyTop - 1, -- 947
		z0 = -10, -- 948
		z1 = -4, -- 949
		material = MING_MATERIALS.mingTimber, -- 950
		bucket = LP_BUCKET.PROP, -- 951
		sortBias = 0.12, -- 952
		highlightTopEdge = true -- 953
	}) -- 953
	scene:addBox({ -- 955
		x0 = handleX - 3, -- 956
		x1 = handleX + 3, -- 957
		y0 = bodyTop - 8, -- 958
		y1 = bodyTop + 2, -- 959
		z0 = -11, -- 960
		z1 = 9, -- 961
		material = MING_MATERIALS.mingTimber, -- 962
		bucket = LP_BUCKET.PROP, -- 963
		sortBias = 0.14, -- 964
		highlightTopEdge = true -- 965
	}) -- 965
	local clothX = axleX - halfW -- 969
	local clothTop = bodyTop + 1 -- 970
	scene:addWavingQuad3D( -- 971
		vec3(clothX - 15, clothTop - 23, -14), -- 972
		vec3(clothX + 2, clothTop - 21, -12), -- 973
		vec3(clothX + 11, clothTop, -11), -- 974
		vec3(clothX - 2, clothTop + 1, -12), -- 975
		MING_MATERIALS.mingRedCloth, -- 976
		{ -- 977
			ampX = 6.2, -- 977
			ampY = 2.4, -- 977
			phase = self.animTime * 3.1, -- 977
			freqU = 1.7, -- 977
			freqV = 2.6, -- 977
			pin = "top" -- 977
		}, -- 977
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, subdivX = 3, subdivY = 4} -- 978
	) -- 978
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 981
	local wheelXs = {axleX - halfW * 0.56, axleX + halfW * 0.56} -- 984
	local wheelR = cam:len(c.wheelR) -- 985
	local rollAngle = -axleX / math.max(1, c.wheelR) -- 986
	local wi = 0 -- 987
	do -- 987
		wi = 0 -- 988
		while wi < #wheelXs do -- 988
			local wp = projectWorld3D( -- 989
				wheelXs[wi + 1], -- 989
				axleY, -- 989
				-10, -- 989
				cam, -- 989
				self.outsideProj -- 989
			) -- 989
			fgDraw:drawCircle( -- 990
				Vec2(wp.x, wp.y), -- 990
				wheelR, -- 990
				Color(52, 40, 32, 255) -- 990
			) -- 990
			fgDraw:drawRing( -- 991
				Vec2(wp.x, wp.y), -- 991
				math.max(1, wheelR - 2.6), -- 991
				wheelR, -- 991
				Color(0, 0, 0, 0), -- 991
				1.4, -- 991
				Color(148, 126, 102, 220) -- 991
			) -- 991
			local sp = 0 -- 992
			do -- 992
				sp = 0 -- 993
				while sp < 4 do -- 993
					local a = rollAngle + sp * math.pi / 4 -- 994
					local dx = math.cos(a) * (wheelR - 2) -- 995
					local dy = math.sin(a) * (wheelR - 2) -- 996
					fgDraw:drawSegment( -- 997
						Vec2(wp.x - dx, wp.y - dy), -- 997
						Vec2(wp.x + dx, wp.y + dy), -- 997
						1, -- 997
						Color(118, 92, 70, 210) -- 997
					) -- 997
					sp = sp + 1 -- 993
				end -- 993
			end -- 993
			fgDraw:drawDot( -- 999
				Vec2(wp.x, wp.y), -- 999
				2.4, -- 999
				Color(172, 160, 144, 230) -- 999
			) -- 999
			wi = wi + 1 -- 988
		end -- 988
	end -- 988
	local patchP = projectWorld3D( -- 1003
		clothX + 1, -- 1003
		clothTop - 7, -- 1003
		-13, -- 1003
		cam, -- 1003
		self.outsideProj -- 1003
	) -- 1003
	fgDraw:drawSegment( -- 1004
		Vec2(patchP.x - 3, patchP.y), -- 1004
		Vec2(patchP.x + 3, patchP.y - 2), -- 1004
		1, -- 1004
		Color(224, 212, 188, 215) -- 1004
	) -- 1004
	fgDraw:drawSegment( -- 1005
		Vec2(patchP.x - 2, patchP.y - 4), -- 1005
		Vec2(patchP.x + 2, patchP.y - 5), -- 1005
		0.9, -- 1005
		Color(224, 212, 188, 195) -- 1005
	) -- 1005
	return true -- 1007
end -- 902
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1010
	if not self.active then -- 1010
		return -- 1017
	end -- 1017
	local key = ctx.p.room.key -- 1019
	if key == "village" then -- 1019
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1021
	elseif key == "forest" then -- 1021
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1023
	end -- 1023
end -- 1010
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1031
	if not self.active then -- 1031
		return false -- 1039
	end -- 1039
	local key = ctx.p.room.key -- 1041
	if key == "village" then -- 1041
		return self.village:drawForegroundOverlay( -- 1043
			uiDraw, -- 1043
			uiInkDraw, -- 1043
			uiArt, -- 1043
			uiGlow, -- 1043
			ctx -- 1043
		) -- 1043
	end -- 1043
	if key == "forest" then -- 1043
		return self.forest:drawForegroundOverlay( -- 1046
			uiDraw, -- 1046
			uiInkDraw, -- 1046
			uiArt, -- 1046
			uiGlow, -- 1046
			ctx -- 1046
		) -- 1046
	end -- 1046
	if key == "outside" then -- 1046
		self:drawOutsideSewingMemoryOverlay( -- 1049
			uiDraw, -- 1049
			uiInkDraw, -- 1049
			uiArt, -- 1049
			uiGlow, -- 1049
			ctx -- 1049
		) -- 1049
		return false -- 1050
	end -- 1050
	return false -- 1052
end -- 1031
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1059
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1059
		return -- 1067
	end -- 1067
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1069
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 1071
	if alpha <= 0.01 then -- 1071
		return -- 1073
	end -- 1073
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1075
	local handPt = projectWorld3D( -- 1076
		self.memoryAnchorWorldX, -- 1076
		self.memoryAnchorWorldY, -- 1076
		0, -- 1076
		ctx.cam, -- 1076
		self.outsideProj -- 1076
	) -- 1076
	local cardW = 264 -- 1077
	local cardH = 148 -- 1078
	local cx = math.max( -- 1079
		cardW * 0.5 + 24, -- 1079
		math.min(ctx.uiW - cardW * 0.5 - 24, handPt.x * inv - 16) -- 1079
	) -- 1079
	local cy = math.max( -- 1080
		cardH * 0.5 + 32, -- 1080
		math.min(ctx.uiH - cardH * 0.5 - 32, handPt.y * inv + 102) -- 1080
	) -- 1080
	local rect = { -- 1081
		x = math.floor(cx - cardW * 0.5 + 0.5), -- 1081
		y = math.floor(cy - cardH * 0.5 + 0.5), -- 1081
		w = cardW, -- 1081
		h = cardH -- 1081
	} -- 1081
	fillRadialGlow( -- 1083
		uiGlow, -- 1083
		cx, -- 1083
		cy, -- 1083
		cardW * 0.82, -- 1083
		cardH * 0.92, -- 1083
		Color( -- 1083
			238, -- 1083
			190, -- 1083
			122, -- 1083
			math.floor(88 * alpha + 0.5) -- 1083
		), -- 1083
		Color(218, 162, 92, 0), -- 1083
		20 -- 1083
	) -- 1083
	local zoom = 1 + prog * 0.036 -- 1084
	drawPixelSlidePlate( -- 1085
		uiDraw, -- 1085
		uiInkDraw, -- 1085
		uiArt, -- 1085
		"slide_f01_sewing", -- 1085
		"fe04_sewing_mem", -- 1085
		rect, -- 1085
		alpha * 0.96, -- 1085
		3, -- 1085
		0, -- 1085
		0, -- 1085
		zoom -- 1085
	) -- 1085
	drawSlideFrameChrome( -- 1086
		uiDraw, -- 1086
		uiInkDraw, -- 1086
		uiArt, -- 1086
		rect, -- 1086
		ctx.uiW, -- 1086
		ctx.uiH, -- 1086
		{ -- 1086
			frameOpacity = 0.78, -- 1087
			letterboxH = 0, -- 1088
			opacity = alpha, -- 1089
			layer = 3, -- 1090
			instancePrefix = "fe04_sew" -- 1091
		} -- 1091
	) -- 1091
end -- 1059
function ____exports.createLowpolyWorldPlugin() -- 1096
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1097
end -- 1096
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1101
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1104
	fe:registerPlugin(lowpolyWorld) -- 1105
	return {lowpolyWorld = lowpolyWorld} -- 1106
end -- 1101
return ____exports -- 1101