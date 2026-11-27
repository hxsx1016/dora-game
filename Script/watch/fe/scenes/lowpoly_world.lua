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
	if not opened then -- 715
		scene:addBox({ -- 718
			x0 = ox + 490, -- 719
			x1 = ox + 720, -- 720
			y0 = 0, -- 721
			y1 = 215, -- 722
			z0 = -8, -- 723
			z1 = 96, -- 724
			material = MING_MATERIALS.mingBrick, -- 725
			bucket = LP_BUCKET.MIDGROUND, -- 726
			highlightTopEdge = true -- 727
		}) -- 727
	else -- 727
		scene:addBox({ -- 731
			x0 = ox + 490, -- 732
			x1 = ox + 706, -- 733
			y0 = 0, -- 734
			y1 = 146, -- 735
			z0 = 46, -- 736
			z1 = 96, -- 737
			material = MING_MATERIALS.mingTimberDark, -- 738
			bucket = LP_BUCKET.BACKDROP, -- 739
			edgeWidth = 0.8 -- 740
		}) -- 740
		scene:addBox({ -- 742
			x0 = ox + 490, -- 743
			x1 = ox + 706, -- 744
			y0 = -3, -- 745
			y1 = 2, -- 746
			z0 = -18, -- 747
			z1 = 48, -- 748
			material = MING_MATERIALS.mingTimber, -- 749
			bucket = LP_BUCKET.WALK_DECK, -- 750
			sortBias = 0.12, -- 751
			highlightTopEdge = true -- 752
		}) -- 752
		scene:addBox({ -- 755
			x0 = ox + 490, -- 756
			x1 = ox + 720, -- 757
			y0 = 144, -- 758
			y1 = 215, -- 759
			z0 = -8, -- 760
			z1 = 96, -- 761
			material = MING_MATERIALS.mingBrick, -- 762
			bucket = LP_BUCKET.MIDGROUND, -- 763
			highlightTopEdge = true -- 764
		}) -- 764
		scene:addBox({ -- 766
			x0 = ox + 490, -- 767
			x1 = ox + 704, -- 768
			y0 = 132, -- 769
			y1 = 145, -- 770
			z0 = -4, -- 771
			z1 = 48, -- 772
			material = MING_MATERIALS.mingTimberDark, -- 773
			bucket = LP_BUCKET.MIDGROUND, -- 774
			sortBias = 0.08 -- 775
		}) -- 775
		scene:addBox({ -- 778
			x0 = ox + 702, -- 779
			x1 = ox + 724, -- 780
			y0 = 0, -- 781
			y1 = 146, -- 782
			z0 = -8, -- 783
			z1 = 96, -- 784
			material = MING_MATERIALS.mingBrickDark, -- 785
			bucket = LP_BUCKET.MIDGROUND, -- 786
			highlightTopEdge = true -- 787
		}) -- 787
		scene:addQuad3D( -- 790
			vec3(ox + 544, 52, 45), -- 791
			vec3(ox + 662, 52, 45), -- 792
			vec3(ox + 662, 118, 45), -- 793
			vec3(ox + 544, 118, 45), -- 794
			{base = rgba(88, 62, 38, 255)}, -- 795
			{ -- 796
				bucket = LP_BUCKET.BACKDROP, -- 796
				unlit = true, -- 796
				sortBias = 0.12, -- 796
				edgeColor = rgba(132, 98, 62, 210), -- 796
				edgeWidth = 1 -- 796
			} -- 796
		) -- 796
		scene:addBox({ -- 799
			x0 = ox + 564, -- 800
			x1 = ox + 646, -- 801
			y0 = 28, -- 802
			y1 = 35, -- 803
			z0 = 10, -- 804
			z1 = 36, -- 805
			material = MING_MATERIALS.mingTimber, -- 806
			bucket = LP_BUCKET.PROP, -- 807
			sortBias = 0.12, -- 808
			highlightTopEdge = true -- 809
		}) -- 809
		scene:addBox({ -- 811
			x0 = ox + 568, -- 812
			x1 = ox + 576, -- 813
			y0 = 0, -- 814
			y1 = 28, -- 815
			z0 = 12, -- 816
			z1 = 32, -- 817
			material = MING_MATERIALS.mingTimberDark, -- 818
			bucket = LP_BUCKET.PROP, -- 819
			sortBias = 0.06 -- 820
		}) -- 820
		scene:addBox({ -- 822
			x0 = ox + 634, -- 823
			x1 = ox + 642, -- 824
			y0 = 0, -- 825
			y1 = 28, -- 826
			z0 = 12, -- 827
			z1 = 32, -- 828
			material = MING_MATERIALS.mingTimberDark, -- 829
			bucket = LP_BUCKET.PROP, -- 830
			sortBias = 0.06 -- 831
		}) -- 831
	end -- 831
	scene:addBeveledFrame( -- 836
		ox + 400, -- 836
		ox + 490, -- 836
		0, -- 836
		110, -- 836
		14, -- 836
		34, -- 836
		-8, -- 836
		68, -- 836
		MING_MATERIALS.mingStoneStep, -- 836
		{ -- 836
			bucket = LP_BUCKET.MIDGROUND, -- 837
			innerRimLight = rgba(244, 206, 140, 255), -- 838
			innerRimStrength = opened and 0.78 or 0.32 -- 839
		} -- 839
	) -- 839
	scene:addCutout3D( -- 843
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 843
		ox + 445, -- 843
		206, -- 843
		18, -- 843
		240, -- 843
		142, -- 843
		{ -- 843
			bucket = LP_BUCKET.MIDGROUND, -- 844
			anchorX = 0.5, -- 845
			anchorY = 0, -- 846
			color = rgba(154, 168, 184, 255), -- 847
			opacity = 0.92, -- 848
			sortBias = 0.08 -- 849
		} -- 849
	) -- 849
	if not opened then -- 849
		scene:addCutout3D( -- 854
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 854
			ox + 445, -- 854
			2, -- 854
			14, -- 854
			84, -- 854
			108, -- 854
			{ -- 854
				bucket = LP_BUCKET.MIDGROUND, -- 855
				anchorX = 0.5, -- 856
				anchorY = 0, -- 857
				color = rgba(186, 182, 176, 255), -- 858
				opacity = 0.98, -- 859
				sortBias = 0.14 -- 860
			} -- 860
		) -- 860
	else -- 860
		scene:addQuad3D( -- 863
			vec3(ox + 404, 2, 24), -- 864
			vec3(ox + 486, 2, 24), -- 865
			vec3(ox + 486, 109, 24), -- 866
			vec3(ox + 404, 109, 24), -- 867
			{base = rgba(112, 78, 42, 255)}, -- 868
			{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = 0.08} -- 869
		) -- 869
	end -- 869
	scene:addQuad3D( -- 874
		vec3(ox + 286, 118, -9), -- 875
		vec3(ox + 306, 118, -9), -- 876
		vec3(ox + 306, 158, -9), -- 877
		vec3(ox + 286, 158, -9), -- 878
		{base = rgba(244, 204, 134, 255)}, -- 879
		{ -- 880
			bucket = LP_BUCKET.PROP, -- 880
			unlit = true, -- 880
			edgeColor = rgba(82, 68, 52, 255), -- 880
			edgeWidth = 1.4 -- 880
		} -- 880
	) -- 880
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 884
	scene:addLightShaft( -- 885
		ox + 412, -- 886
		ox + 478, -- 886
		106, -- 886
		ox + 382, -- 887
		ox + 506, -- 887
		0, -- 887
		6, -- 888
		rgba(246, 208, 138, 255), -- 889
		(opened and 0.34 or 0.08) * pulse, -- 890
		(opened and 0.16 or 0.04) * pulse -- 891
	) -- 891
	scene:addContactShadow( -- 895
		p.player.x, -- 895
		p.player.y, -- 895
		15, -- 895
		11, -- 895
		0.78, -- 895
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 895
	) -- 895
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 897
	local lampP = projectWorld3D( -- 900
		ox + 445, -- 900
		102, -- 900
		2, -- 900
		cam, -- 900
		self.towerProj -- 900
	) -- 900
	fillRadialGlow( -- 901
		fgGlow, -- 902
		lampP.x, -- 903
		lampP.y, -- 904
		cam:len(opened and 64 or 34) * pulse, -- 905
		cam:len(opened and 64 or 34) * pulse, -- 906
		Color( -- 907
			248, -- 907
			214, -- 907
			146, -- 907
			math.floor((opened and 132 or 76) * pulse + 0.5) -- 907
		), -- 907
		Color(232, 174, 82, 0), -- 908
		16 -- 909
	) -- 909
	fgDraw:drawCircle( -- 911
		Vec2(lampP.x, lampP.y), -- 911
		4.2, -- 911
		Color(255, 240, 202, 245) -- 911
	) -- 911
	local winP = projectWorld3D( -- 913
		ox + 296, -- 913
		138, -- 913
		-9, -- 913
		cam, -- 913
		self.towerProj -- 913
	) -- 913
	fillRadialGlow( -- 914
		fgGlow, -- 914
		winP.x, -- 914
		winP.y, -- 914
		cam:len(38), -- 914
		cam:len(42), -- 914
		Color( -- 914
			246, -- 914
			206, -- 914
			132, -- 914
			math.floor(78 * pulse + 0.5) -- 914
		), -- 914
		Color(232, 174, 82, 0), -- 914
		14 -- 914
	) -- 914
	local wBL = projectWorld3D( -- 916
		ox + 286, -- 916
		118, -- 916
		-9, -- 916
		cam, -- 916
		self.towerProj -- 916
	) -- 916
	local wTR = projectWorld3D( -- 917
		ox + 306, -- 917
		158, -- 917
		-9, -- 917
		cam, -- 917
		self.towerProj -- 917
	) -- 917
	local wMidX = (wBL.x + wTR.x) * 0.5 -- 918
	local wMidY = (wBL.y + wTR.y) * 0.5 -- 919
	fgDraw:drawSegment( -- 920
		Vec2(wMidX, wBL.y), -- 920
		Vec2(wMidX, wTR.y), -- 920
		1.4, -- 920
		Color(68, 52, 38, 225) -- 920
	) -- 920
	fgDraw:drawSegment( -- 921
		Vec2(wBL.x, wMidY), -- 921
		Vec2(wTR.x, wMidY), -- 921
		1.4, -- 921
		Color(68, 52, 38, 225) -- 921
	) -- 921
	return true -- 923
end -- 668
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 926
	if not self.active then -- 926
		return false -- 933
	end -- 933
	local key = ctx.p.room.key -- 935
	if key == "village" then -- 935
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 937
	end -- 937
	if key == "forest" then -- 937
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 940
	end -- 940
	if key == "outside" then -- 940
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 943
	end -- 943
	if key == "tower" then -- 943
		local p = ctx.p -- 946
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 947
		if opened then -- 947
			local cam = ctx.cam -- 949
			local deskTopP = projectWorld3D( -- 950
				p.ox + 605, -- 950
				35, -- 950
				22, -- 950
				cam, -- 950
				self.towerProj -- 950
			) -- 950
			local guardBaseP = projectWorld3D( -- 951
				p.ox + 626, -- 951
				0, -- 951
				38, -- 951
				cam, -- 951
				self.towerProj -- 951
			) -- 951
			local deskCx = deskTopP.x -- 952
			local deskTop = deskTopP.y -- 953
			local s = deskTopP.scale -- 954
			local gs = guardBaseP.scale -- 955
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 956
			fillRadialGlow( -- 957
				fgGlow, -- 957
				deskCx, -- 957
				deskTop + cam:len(26) * s, -- 957
				cam:len(132) * s, -- 957
				cam:len(96) * s, -- 957
				Color( -- 958
					255, -- 958
					198, -- 958
					114, -- 958
					math.floor(82 * pulse + 0.5) -- 958
				), -- 958
				Color(255, 168, 72, 0), -- 958
				16 -- 958
			) -- 958
			local writing = p.deskHold >= 24 or p.towerHanded -- 960
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 961
			if not worldArt:tryPlacePath( -- 961
				guardClip, -- 964
				"fe04_tower_guard_npc", -- 964
				guardBaseP.x, -- 964
				guardBaseP.y, -- 964
				cam:len(54) * gs, -- 964
				cam:len(82) * gs, -- 964
				{ -- 964
					anchorX = 0.44, -- 965
					anchorY = 0, -- 966
					preserveAspect = true, -- 967
					facing = -1, -- 968
					opacity = 0.96, -- 969
					layer = 3600 -- 970
				} -- 970
			) then -- 970
				fgDraw:drawRect( -- 972
					Rect( -- 972
						guardBaseP.x - cam:len(11) * gs, -- 972
						guardBaseP.y, -- 972
						cam:len(22) * gs, -- 972
						cam:len(68) * gs -- 972
					), -- 972
					Color(28, 34, 44, 242) -- 972
				) -- 972
				fgDraw:drawCircle( -- 973
					Vec2( -- 973
						guardBaseP.x, -- 973
						guardBaseP.y + cam:len(76) * gs -- 973
					), -- 973
					cam:len(9.5) * gs, -- 973
					Color(36, 44, 56, 248) -- 973
				) -- 973
			end -- 973
			fgDraw:drawRect( -- 976
				Rect( -- 976
					deskCx + cam:len(4) * s, -- 976
					deskTop + cam:len(1) * s, -- 976
					cam:len(24) * s, -- 976
					cam:len(5) * s -- 976
				), -- 976
				Color(230, 220, 196, 245) -- 976
			) -- 976
			if writing then -- 976
				if not worldArt:tryPlace( -- 976
					"prop_lantern", -- 978
					"fe04_tower_desk_lamp", -- 978
					deskCx + cam:len(34) * s, -- 978
					deskTop + cam:len(10) * s, -- 978
					cam:len(14) * s, -- 978
					cam:len(20) * s, -- 978
					{opacity = 0.96, layer = 3700} -- 978
				) then -- 978
					fgDraw:drawRect( -- 982
						Rect( -- 982
							deskCx + cam:len(30) * s, -- 982
							deskTop + cam:len(1) * s, -- 982
							cam:len(8) * s, -- 982
							cam:len(12) * s -- 982
						), -- 982
						Color(166, 126, 62, 245) -- 982
					) -- 982
				end -- 982
				fillRadialGlow( -- 984
					fgGlow, -- 984
					deskCx + cam:len(34) * s, -- 984
					deskTop + cam:len(14) * s, -- 984
					cam:len(26) * s, -- 984
					cam:len(22) * s, -- 984
					Color( -- 984
						255, -- 984
						214, -- 984
						134, -- 984
						math.floor(92 * pulse + 0.5) -- 984
					), -- 984
					Color(255, 180, 86, 0), -- 984
					12 -- 984
				) -- 984
			else -- 984
				fillRadialGlow( -- 986
					fgGlow, -- 986
					deskCx + cam:len(6) * s, -- 986
					deskTop + cam:len(18) * s, -- 986
					cam:len(28) * s, -- 986
					cam:len(26) * s, -- 986
					Color( -- 986
						255, -- 986
						214, -- 986
						134, -- 986
						math.floor(78 * pulse + 0.5) -- 986
					), -- 986
					Color(255, 180, 86, 0), -- 986
					12 -- 986
				) -- 986
			end -- 986
			if p.deskHold >= 12 or p.towerHanded then -- 986
				if not worldArt:tryPlacePath( -- 986
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 989
					"fe04_tower_desk_pouch", -- 989
					deskCx - cam:len(18) * s, -- 989
					deskTop + cam:len(8) * s, -- 989
					cam:len(18) * s, -- 989
					cam:len(18) * s, -- 989
					{ -- 989
						anchorX = 0.5, -- 990
						anchorY = 0.5, -- 991
						opacity = 0.95, -- 992
						smooth = true, -- 993
						layer = 3710 -- 994
					} -- 994
				) then -- 994
					fgDraw:drawRect( -- 996
						Rect( -- 996
							deskCx - cam:len(26) * s, -- 996
							deskTop + cam:len(1) * s, -- 996
							cam:len(14) * s, -- 996
							cam:len(6) * s -- 996
						), -- 996
						Color(156, 62, 48, 245) -- 996
					) -- 996
				end -- 996
			end -- 996
			if p.deskHold >= 24 or p.towerHanded then -- 996
				fgDraw:drawRect( -- 1000
					Rect( -- 1000
						deskCx - cam:len(4) * s, -- 1000
						deskTop + cam:len(1) * s, -- 1000
						cam:len(10) * s, -- 1000
						cam:len(3) * s -- 1000
					), -- 1000
					Color(236, 228, 206, 240) -- 1000
				) -- 1000
			end -- 1000
		end -- 1000
		return true -- 1003
	end -- 1003
	return false -- 1005
end -- 926
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 1009
	local p = ctx.p -- 1015
	local cam = ctx.cam -- 1016
	local c = p.room.cart -- 1017
	if c.bodyW <= 0 then -- 1017
		return true -- 1019
	end -- 1019
	local halfW = c.bodyW * 0.5 -- 1021
	local axleX = p.cartAxle -- 1022
	local baseY = cam:sy(c.baseY) -- 1023
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 1024
	local cx = cam:sx(axleX) -- 1025
	local artW = cam:len(c.bodyW * 1.38) -- 1026
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 1027
	fgDraw:drawEllipse( -- 1029
		Vec2(cx, baseY + 1), -- 1029
		cam:len(c.bodyW * 0.62), -- 1029
		4, -- 1029
		Color(6, 10, 16, 155) -- 1029
	) -- 1029
	worldArt:tryPlace( -- 1030
		"prop_cart", -- 1030
		"fe04_outside_cart", -- 1030
		cx, -- 1030
		baseY, -- 1030
		artW, -- 1030
		artH, -- 1030
		{ -- 1030
			color = Color(196, 210, 228, 255), -- 1031
			layer = 5 -- 1032
		} -- 1032
	) -- 1032
	local clothX = axleX - halfW -- 1036
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 1037
	worldArt:tryPlace( -- 1038
		"fe_red_cloth", -- 1038
		"fe04_outside_cart_cloth", -- 1038
		cam:sx(clothX + 2), -- 1038
		bodyTopY - cam:len(2), -- 1038
		cam:len(24), -- 1038
		cam:len(24), -- 1038
		{frame = clothFrame, layer = 6} -- 1038
	) -- 1038
	return true -- 1043
end -- 1009
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1046
	if not self.active then -- 1046
		return -- 1053
	end -- 1053
	local key = ctx.p.room.key -- 1055
	if key == "village" then -- 1055
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1057
	elseif key == "forest" then -- 1057
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 1059
	end -- 1059
end -- 1046
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1067
	if not self.active then -- 1067
		return false -- 1075
	end -- 1075
	local key = ctx.p.room.key -- 1077
	if key == "village" then -- 1077
		return self.village:drawForegroundOverlay( -- 1079
			uiDraw, -- 1079
			uiInkDraw, -- 1079
			uiArt, -- 1079
			uiGlow, -- 1079
			ctx -- 1079
		) -- 1079
	end -- 1079
	if key == "forest" then -- 1079
		return self.forest:drawForegroundOverlay( -- 1082
			uiDraw, -- 1082
			uiInkDraw, -- 1082
			uiArt, -- 1082
			uiGlow, -- 1082
			ctx -- 1082
		) -- 1082
	end -- 1082
	if key == "outside" then -- 1082
		self:drawOutsideSewingMemoryOverlay( -- 1085
			uiDraw, -- 1085
			uiInkDraw, -- 1085
			uiArt, -- 1085
			uiGlow, -- 1085
			ctx -- 1085
		) -- 1085
		return false -- 1086
	end -- 1086
	return false -- 1088
end -- 1067
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1095
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 1095
		return -- 1103
	end -- 1103
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 1105
	local alpha = smoothstep(0, 0.16, prog) * (1 - smoothstep(0.76, 1, prog)) -- 1106
	if alpha <= 0.01 then -- 1106
		return -- 1108
	end -- 1108
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1110
	local handPt = projectWorld3D( -- 1111
		self.memoryAnchorWorldX, -- 1111
		self.memoryAnchorWorldY, -- 1111
		0, -- 1111
		ctx.cam, -- 1111
		self.outsideProj -- 1111
	) -- 1111
	local panelW = math.min( -- 1112
		352, -- 1112
		math.floor(ctx.uiW * 0.28 + 0.5) -- 1112
	) -- 1112
	local panelH = math.floor(panelW * 9 / 16 + 0.5) -- 1113
	local cx = math.max( -- 1114
		panelW * 0.5 + 24, -- 1114
		math.min(ctx.uiW - panelW * 0.5 - 24, handPt.x * inv - 16) -- 1114
	) -- 1114
	local cy = math.max( -- 1115
		panelH * 0.5 + 28, -- 1115
		math.min(ctx.uiH - panelH * 0.5 - 28, handPt.y * inv + 112) -- 1115
	) -- 1115
	local seq = {{ -- 1116
		slot = "comic_f01_01_thumb_cloth", -- 1117
		start = 0, -- 1117
		["end"] = 0.22, -- 1117
		zoomFrom = 1, -- 1117
		zoomTo = 1.015 -- 1117
	}, { -- 1117
		slot = "comic_f01_02_needle_pierce", -- 1118
		start = 0.22, -- 1118
		["end"] = 0.48, -- 1118
		zoomFrom = 1.005, -- 1118
		zoomTo = 1.018 -- 1118
	}, { -- 1118
		slot = "comic_f01_03_thread_pull", -- 1119
		start = 0.48, -- 1119
		["end"] = 0.76, -- 1119
		zoomFrom = 1.01, -- 1119
		zoomTo = 1.022 -- 1119
	}, { -- 1119
		slot = "comic_f01_04_stitch_smooth", -- 1120
		start = 0.76, -- 1120
		["end"] = 1, -- 1120
		zoomFrom = 1.01, -- 1120
		zoomTo = 1 -- 1120
	}} -- 1120
	fillRadialGlow( -- 1124
		uiGlow, -- 1124
		cx, -- 1124
		cy, -- 1124
		panelW * 0.68, -- 1124
		panelH * 0.76, -- 1124
		Color( -- 1124
			238, -- 1124
			186, -- 1124
			114, -- 1124
			math.floor(74 * alpha + 0.5) -- 1124
		), -- 1124
		Color(214, 152, 82, 0), -- 1124
		20 -- 1124
	) -- 1124
	drawComicInsertPanel( -- 1125
		uiDraw, -- 1126
		uiInkDraw, -- 1127
		uiArt, -- 1128
		seq, -- 1129
		prog, -- 1130
		{x = cx - panelW * 0.5, y = cy - panelH * 0.5, w = panelW, h = panelH}, -- 1131
		alpha, -- 1132
		"fe04_f01_comic", -- 1133
		4 -- 1134
	) -- 1134
end -- 1095
function ____exports.createLowpolyWorldPlugin() -- 1139
	return __TS__New(____exports.LowpolyWorldPlugin) -- 1140
end -- 1139
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 1144
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 1147
	fe:registerPlugin(lowpolyWorld) -- 1148
	return {lowpolyWorld = lowpolyWorld} -- 1149
end -- 1144
return ____exports -- 1144