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
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 23
local clamp01 = ____lowpoly.clamp01 -- 25
local projectWorld3D = ____lowpoly.projectWorld3D -- 26
local smoothstep = ____lowpoly.smoothstep -- 27
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 29
local drawChildColdMoonGrade = ____slideshow.drawChildColdMoonGrade -- 30
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 31
local drawSlideFrameChrome = ____slideshow.drawSlideFrameChrome -- 32
local ____village_undertable = require("Script.watch.fe.scenes.village_undertable") -- 34
local VillageUndertableScene = ____village_undertable.VillageUndertableScene -- 37
local ____forest_creek = require("Script.watch.fe.scenes.forest_creek") -- 39
local ForestCreekScene = ____forest_creek.ForestCreekScene -- 41
local ____theme = require("Script.watch.fe.theme") -- 43
local fillRadialGlow = ____theme.fillRadialGlow -- 44
local fillVGradRect = ____theme.fillVGradRect -- 45
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 48
--- 首次握车柄家人缝布回忆总时长（秒）：约半秒叠画再落回车柄，拉车输入全程不断档
local SEWING_MEMORY_DURATION = 0.54 -- 50
____exports.LowpolyWorldPlugin = __TS__Class() -- 71
local LowpolyWorldPlugin = ____exports.LowpolyWorldPlugin -- 71
LowpolyWorldPlugin.name = "LowpolyWorldPlugin" -- 71
function LowpolyWorldPlugin.prototype.____constructor(self) -- 71
	self.id = "fe-04-child-lowpoly" -- 72
	self.village = __TS__New(VillageUndertableScene) -- 74
	self.forest = __TS__New(ForestCreekScene) -- 75
	self.active = false -- 77
	self.wasActive = false -- 78
	self.activeRoomKey = "" -- 79
	self.animTime = 0 -- 80
	self.prevGripping = false -- 83
	self.prevCartAxle = 0 -- 84
	self.cartWheelVol = 0 -- 85
	self.cartClothLeftInvariantOk = true -- 86
	self.lastCartClothX = 0 -- 87
	self.lastCartAxle = 0 -- 88
	self.memoryPlayed = false -- 89
	self.memoryTriggeredCount = 0 -- 90
	self.memoryTimer = -1 -- 91
	self.memoryAnchorWorldX = 344 -- 92
	self.memoryAnchorWorldY = 122 -- 93
	self.outsideProj = { -- 95
		morph = 1, -- 96
		focal = 410, -- 97
		vpFracX = 0.54, -- 98
		vpFracY = 0.52, -- 99
		vpOffsetX = 0, -- 100
		vpOffsetY = 0, -- 101
		baseDepth = 0 -- 102
	} -- 102
	self.towerProj = { -- 105
		morph = 1, -- 106
		focal = 415, -- 107
		vpFracX = 0.52, -- 108
		vpFracY = 0.5, -- 109
		vpOffsetX = 0, -- 110
		vpOffsetY = 0, -- 111
		baseDepth = 0 -- 112
	} -- 112
end -- 71
function LowpolyWorldPlugin.prototype.onBindPlay(self, p, _view) -- 115
	self:resetRoomState(p) -- 116
	self:syncRuntimeHook() -- 117
end -- 115
function LowpolyWorldPlugin.prototype.resetRoomState(self, p) -- 120
	self.active = false -- 121
	self.wasActive = false -- 122
	self.activeRoomKey = p ~= nil and p.room.key or "" -- 123
	self.animTime = 0 -- 124
	self.prevGripping = false -- 125
	self.prevCartAxle = p ~= nil and p.cartAxle or 0 -- 126
	self.cartWheelVol = 0 -- 127
	self.cartClothLeftInvariantOk = true -- 128
	self.lastCartAxle = self.prevCartAxle -- 129
	self.lastCartClothX = p ~= nil and p.room.cart.bodyW > 0 and p.cartAxle - p.room.cart.bodyW * 0.5 or 0 -- 130
	self.memoryPlayed = false -- 131
	self.memoryTriggeredCount = 0 -- 132
	self.memoryTimer = -1 -- 133
	self.village:reset() -- 134
	self.forest:reset() -- 135
end -- 120
function LowpolyWorldPlugin.prototype.syncRuntimeHook(self) -- 138
	local g = _G -- 139
	local ____temp_0 -- 140
	if g.package ~= nil then -- 140
		____temp_0 = g.package.loaded -- 140
	else -- 140
		____temp_0 = nil -- 140
	end -- 140
	local loaded = ____temp_0 -- 140
	if loaded == nil then -- 140
		return -- 142
	end -- 142
	local rawFe = loaded["watch.fe"] -- 144
	if rawFe ~= nil and type(rawFe) == "table" then -- 144
		local watchFe = rawFe -- 146
		if watchFe.lowpolyWorld ~= self then -- 146
			watchFe.lowpolyWorld = self -- 148
		end -- 148
	end -- 148
end -- 138
function LowpolyWorldPlugin.prototype.isLowpolyChildRoom(self, roomKey) -- 153
	return roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" -- 154
end -- 153
function LowpolyWorldPlugin.prototype.shouldActivate(self, ctx) -- 157
	return ctx.view.visualMode == "lowpoly" and self:isLowpolyChildRoom(ctx.p.room.key) -- 158
end -- 157
function LowpolyWorldPlugin.prototype.getActiveProjection(self, roomKey) -- 161
	local key = roomKey or self.activeRoomKey -- 162
	if key == "village" then -- 162
		return self.village:getProjection() -- 164
	end -- 164
	if key == "forest" then -- 164
		return self.forest:getProjection() -- 167
	end -- 167
	if key == "tower" then -- 167
		return self.towerProj -- 170
	end -- 170
	return self.outsideProj -- 172
end -- 161
function LowpolyWorldPlugin.prototype.getDebugState(self, p) -- 175
	local memActive = self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION -- 176
	return { -- 177
		active = self.active, -- 178
		roomKey = self.activeRoomKey, -- 179
		outside = { -- 180
			active = self.active and self.activeRoomKey == "outside", -- 181
			cartClothLeftInvariantOk = self.cartClothLeftInvariantOk, -- 182
			cartClothWorldX = self.lastCartClothX, -- 183
			cartAxleWorldX = self.lastCartAxle, -- 184
			memoryTriggeredCount = self.memoryTriggeredCount, -- 185
			memoryActive = memActive, -- 186
			memoryProgress = memActive and clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) or (self.memoryPlayed and 1 or 0), -- 187
			cartWheelVol = self.cartWheelVol -- 188
		}, -- 188
		village = self.village:getDebugState(p), -- 190
		forest = self.forest:getDebugState(p) -- 191
	} -- 191
end -- 175
function LowpolyWorldPlugin.prototype.rehearseOutsideSewingMemory(self, progress) -- 196
	self.memoryPlayed = true -- 197
	self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 198
	self.memoryTimer = progress ~= nil and clamp01(progress) * SEWING_MEMORY_DURATION or 0 -- 199
end -- 196
function LowpolyWorldPlugin.prototype.rehearseVillageImpact(self, ctx, surface) -- 203
	self.village:triggerRehearsalImpact(ctx, surface) -- 204
end -- 203
function LowpolyWorldPlugin.prototype.stopAllAudioLoops(self, ctx) -- 207
	ctx.audio:stopLoop("fe04_outside_wind", 0.2) -- 208
	ctx.audio:stopLoop("fe04_cart_wheel", 0.15) -- 209
	ctx.audio:stopLoop("fe04_village_night", 0.2) -- 210
	ctx.audio:stopLoop("fe04_forest_wind", 0.2) -- 211
	ctx.audio:stopLoop("fe04_creek_water", 0.2) -- 212
end -- 207
function LowpolyWorldPlugin.prototype.update(self, ctx) -- 215
	self:syncRuntimeHook() -- 216
	local want = self:shouldActivate(ctx) -- 217
	if not want then -- 217
		if self.wasActive then -- 217
			ctx.cam:setAnchorLock(nil) -- 220
			self:stopAllAudioLoops(ctx) -- 221
			self.wasActive = false -- 222
		end -- 222
		self.active = false -- 224
		return -- 225
	end -- 225
	local p = ctx.p -- 228
	if self.activeRoomKey ~= "" and self.activeRoomKey ~= p.room.key then -- 228
		ctx.cam:setAnchorLock(nil) -- 230
		self:stopAllAudioLoops(ctx) -- 231
		self:resetRoomState(p) -- 232
	end -- 232
	self.active = true -- 235
	self.wasActive = true -- 236
	self.activeRoomKey = p.room.key -- 237
	if not ctx.paused and ctx.worldDt > 0 then -- 237
		self.animTime = self.animTime + ctx.worldDt -- 240
	end -- 240
	if p.room.key == "outside" then -- 240
		self:updateOutside(ctx) -- 244
	elseif p.room.key == "village" then -- 244
		self.village:update(ctx) -- 246
	elseif p.room.key == "forest" then -- 246
		self.forest:update(ctx) -- 248
	elseif p.room.key == "tower" then -- 248
		ctx.cam:setAnchorLock(nil) -- 250
		self.towerProj = { -- 251
			morph = 1, -- 252
			focal = 415, -- 253
			vpFracX = 0.52, -- 254
			vpFracY = 0.5, -- 255
			vpOffsetX = math.sin(self.animTime * 0.45) * 1.2, -- 256
			vpOffsetY = math.cos(self.animTime * 0.6) * 0.8, -- 257
			baseDepth = 0 -- 258
		} -- 258
	end -- 258
end -- 215
function LowpolyWorldPlugin.prototype.updateOutside(self, ctx) -- 263
	local p = ctx.p -- 264
	ctx.cam:setAnchorLock(nil) -- 265
	local c = p.room.cart -- 267
	if c.bodyW > 0 then -- 267
		self.lastCartAxle = p.cartAxle -- 270
		self.lastCartClothX = p.cartAxle - c.bodyW * 0.5 -- 271
		if self.lastCartClothX >= self.lastCartAxle or c.clothSide >= 0 then -- 271
			self.cartClothLeftInvariantOk = false -- 273
		end -- 273
		self.memoryAnchorWorldX = p.cartAxle + c.handleOffset -- 275
		self.memoryAnchorWorldY = c.baseY + c.wheelR + c.bodyH * 0.72 -- 276
	end -- 276
	if not ctx.paused and ctx.worldDt > 0 then -- 276
		local dt = ctx.worldDt -- 280
		local redCartMemTrigger = p.redCartMemoryT > 0 and not self.memoryPlayed -- 283
		if (p.gripping and not self.prevGripping or redCartMemTrigger) and not self.memoryPlayed then -- 283
			self.memoryPlayed = true -- 285
			self.memoryTriggeredCount = self.memoryTriggeredCount + 1 -- 286
			self.memoryTimer = 0 -- 287
			if redCartMemTrigger then -- 287
				self.memoryAnchorWorldX = p.player.x -- 289
				self.memoryAnchorWorldY = p.player.y + 36 -- 290
			end -- 290
			ctx.audio:playOnce( -- 292
				"fe04:outside:sewing:" .. tostring(ctx.events.roomSessionId), -- 293
				"ambience", -- 294
				CHILD_AUDIO_ROOT .. "sewing_memory.wav", -- 295
				0.68, -- 296
				"fe04:outside:sewing_memory", -- 297
				p.ticks -- 298
			) -- 298
		end -- 298
		self.prevGripping = p.gripping -- 301
		if self.memoryTimer >= 0 and self.memoryTimer < SEWING_MEMORY_DURATION then -- 301
			self.memoryTimer = math.min(SEWING_MEMORY_DURATION, self.memoryTimer + dt) -- 304
		end -- 304
		local cartSpeed = math.abs(p.cartAxle - self.prevCartAxle) / math.max(0.001, dt) -- 308
		self.prevCartAxle = p.cartAxle -- 309
		local targetWheelVol = cartSpeed > 4 and math.min(0.54, 0.22 + cartSpeed / 64 * 0.32) or 0 -- 310
		self.cartWheelVol = self.cartWheelVol + (targetWheelVol - self.cartWheelVol) * math.min(1, dt * 10) -- 311
		ctx.audio:playLoop( -- 313
			"fe04_outside_wind", -- 313
			"wind", -- 313
			CHILD_AUDIO_ROOT .. "wind_outside_loop.wav", -- 313
			0.36, -- 313
			p.ticks -- 313
		) -- 313
		if self.cartWheelVol > 0.03 then -- 313
			ctx.audio:playLoop( -- 315
				"fe04_cart_wheel", -- 315
				"ambience", -- 315
				CHILD_AUDIO_ROOT .. "cart_wheel_loop.wav", -- 315
				self.cartWheelVol, -- 315
				p.ticks -- 315
			) -- 315
		else -- 315
			ctx.audio:stopLoop("fe04_cart_wheel", 0.12) -- 317
		end -- 317
	end -- 317
	self.outsideProj = { -- 321
		morph = 1, -- 322
		focal = 410, -- 323
		vpFracX = 0.54, -- 324
		vpFracY = 0.52, -- 325
		vpOffsetX = math.sin(self.animTime * 0.52) * 1.5, -- 326
		vpOffsetY = math.cos(self.animTime * 0.68) * 1, -- 327
		baseDepth = 0 -- 328
	} -- 328
end -- 263
function LowpolyWorldPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 332
	if not self.active then -- 332
		return false -- 339
	end -- 339
	local key = ctx.p.room.key -- 341
	if key == "village" then -- 341
		return self.village:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 343
	end -- 343
	if key == "forest" then -- 343
		return self.forest:drawBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 346
	end -- 346
	if key == "outside" then -- 346
		return self:drawOutsideBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 349
	end -- 349
	if key == "tower" then -- 349
		return self:drawTowerBackdrop(bgDraw, bgGlow, backdropArt, ctx) -- 352
	end -- 352
	return false -- 354
end -- 332
function LowpolyWorldPlugin.prototype.drawOutsideBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 357
	local p = ctx.p -- 363
	local cam = ctx.cam -- 364
	local w = cam.viewW -- 365
	local h = cam.viewH -- 366
	local ox = p.ox -- 367
	fillVGradRect( -- 370
		bgDraw, -- 370
		0, -- 370
		0, -- 370
		w, -- 370
		h, -- 370
		Color(24, 34, 52, 255), -- 370
		Color(8, 13, 22, 255) -- 370
	) -- 370
	local span = math.max(1, p.room.maxX - p.room.minX) -- 372
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 373
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 374
	local artH = artW * 9 / 16 -- 375
	local artY = math.min( -- 376
		0, -- 376
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 376
	) -- 376
	backdropArt:tryPlace( -- 377
		"bgFar_outside", -- 377
		"fe04_bg_outside", -- 377
		w * (0.5 - progress * 0.08), -- 377
		artY, -- 377
		artW, -- 377
		artH, -- 377
		{ -- 377
			color = Color(172, 194, 224, 255), -- 378
			layer = 0 -- 379
		} -- 379
	) -- 379
	local y = cam.groundScreenY -- 383
	fillVGradRect( -- 384
		bgGlow, -- 384
		0, -- 384
		y - 2, -- 384
		w, -- 384
		h * 0.16, -- 384
		Color(34, 48, 70, 26), -- 384
		Color(16, 26, 42, 0) -- 384
	) -- 384
	local beaconP = projectWorld3D( -- 386
		ox + 1140, -- 386
		154, -- 386
		410, -- 386
		cam, -- 386
		self.outsideProj -- 386
	) -- 386
	local pulse = 0.84 + 0.16 * math.sin(self.animTime * 2.2) -- 387
	fillRadialGlow( -- 388
		bgGlow, -- 388
		beaconP.x, -- 388
		beaconP.y, -- 388
		30 * pulse, -- 388
		30 * pulse, -- 388
		Color( -- 388
			246, -- 388
			208, -- 388
			138, -- 388
			math.floor(84 * pulse + 0.5) -- 388
		), -- 388
		Color(232, 176, 86, 0), -- 388
		14 -- 388
	) -- 388
	bgGlow:drawDot( -- 389
		Vec2(beaconP.x, beaconP.y), -- 389
		2.3, -- 389
		Color(255, 244, 212, 230) -- 389
	) -- 389
	return true -- 391
end -- 357
function LowpolyWorldPlugin.prototype.drawTowerBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 394
	local cam = ctx.cam -- 400
	local p = ctx.p -- 401
	local w = cam.viewW -- 402
	local h = cam.viewH -- 403
	fillVGradRect( -- 405
		bgDraw, -- 405
		0, -- 405
		0, -- 405
		w, -- 405
		h, -- 405
		Color(34, 42, 58, 255), -- 405
		Color(12, 18, 30, 255) -- 405
	) -- 405
	local span = math.max(1, p.room.maxX - p.room.minX) -- 406
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 407
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 408
	local artH = artW * 9 / 16 -- 409
	local artY = math.min( -- 410
		0, -- 410
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 410
	) -- 410
	backdropArt:tryPlace( -- 411
		"bgFar_tower", -- 411
		"fe04_bg_tower", -- 411
		w * (0.5 - progress * 0.08), -- 411
		artY, -- 411
		artW, -- 411
		artH, -- 411
		{ -- 411
			color = Color(184, 198, 222, 255), -- 412
			layer = 0 -- 413
		} -- 413
	) -- 413
	fillVGradRect( -- 415
		bgGlow, -- 415
		0, -- 415
		cam.groundScreenY - 2, -- 415
		w, -- 415
		h * 0.14, -- 415
		Color(44, 50, 66, 20), -- 415
		Color(20, 26, 38, 0) -- 415
	) -- 415
	return true -- 417
end -- 394
function LowpolyWorldPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 420
	if not self.active then -- 420
		return false -- 427
	end -- 427
	local key = ctx.p.room.key -- 429
	if key == "village" then -- 429
		return self.village:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 431
	end -- 431
	if key == "forest" then -- 431
		return self.forest:drawWorld(fgDraw, fgGlow, worldArt, ctx) -- 434
	end -- 434
	if key == "outside" then -- 434
		return self:drawOutsideWorld(fgDraw, fgGlow, worldArt, ctx) -- 437
	end -- 437
	if key == "tower" then -- 437
		return self:drawTowerWorld(fgDraw, fgGlow, worldArt, ctx) -- 440
	end -- 440
	return false -- 442
end -- 420
function LowpolyWorldPlugin.prototype.drawOutsideWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 445
	local p = ctx.p -- 451
	local cam = ctx.cam -- 452
	local ox = p.ox -- 453
	local coldStone = Color(168, 186, 210, 255) -- 454
	local coldWall = Color(156, 174, 198, 255) -- 455
	local fi = 0 -- 458
	do -- 458
		fi = 0 -- 459
		while fi < #p.room.floors do -- 459
			local fl = p.room.floors[fi + 1] -- 460
			local left = cam:sx(fl.x0) -- 461
			local right = cam:sx(fl.x1) -- 462
			local top = cam:sy(fl.y) -- 463
			local isMain = fl.y <= 0.1 -- 464
			local deckH = cam:len(isMain and 26 or 14) -- 465
			local bot = top - deckH -- 466
			if isMain and bot > 0 then -- 466
				fillVGradRect( -- 468
					fgDraw, -- 468
					left, -- 468
					0, -- 468
					right - left, -- 468
					bot + 1, -- 468
					Color(10, 14, 22, 255), -- 468
					Color(24, 32, 46, 255) -- 468
				) -- 468
			end -- 468
			local step = math.max( -- 470
				24, -- 470
				cam:len(76) -- 470
			) -- 470
			local start = math.max( -- 471
				0, -- 471
				math.floor(-left / step) -- 471
			) -- 471
			local j = start -- 472
			do -- 472
				j = start -- 473
				while left + j * step < math.min(right, cam.viewW + 40) do -- 473
					do -- 473
						local tx = left + j * step -- 474
						local tw = math.min(step, right - tx) -- 475
						if tw <= 2 then -- 475
							goto __continue56 -- 477
						end -- 477
						worldArt:tryPlace( -- 479
							isMain and "fe_road_stone" or "slab", -- 479
							(("fe04_out_fl_" .. tostring(fi)) .. "_") .. tostring(j), -- 479
							tx + tw * 0.5, -- 479
							bot, -- 479
							tw + 0.5, -- 479
							deckH, -- 479
							{color = coldStone, layer = 1} -- 479
						) -- 479
					end -- 479
					::__continue56:: -- 479
					j = j + 1 -- 473
				end -- 473
			end -- 473
			fgDraw:drawSegment( -- 484
				Vec2(left, top), -- 484
				Vec2(right, top), -- 484
				1.1, -- 484
				Color(142, 166, 192, 125) -- 484
			) -- 484
			fi = fi + 1 -- 459
		end -- 459
	end -- 459
	local a = p.room.arch -- 488
	if a.h > 0 and a.x1 > a.x0 then -- 488
		local ax0 = cam:sx(a.x0) -- 490
		local ax1 = cam:sx(a.x1) -- 491
		local ay0 = cam:sy(a.y) -- 492
		local ay1 = cam:sy(a.y + a.h) -- 493
		local aw = ax1 - ax0 -- 494
		local ah = ay1 - ay0 -- 495
		fgDraw:drawRect( -- 496
			Rect( -- 496
				ax0, -- 496
				ay0, -- 496
				aw, -- 496
				ah + cam:len(10) -- 496
			), -- 496
			Color(10, 14, 22, 232) -- 496
		) -- 496
		worldArt:tryPlace( -- 497
			"fe_outside_arch", -- 497
			"fe04_out_arch", -- 497
			(ax0 + ax1) * 0.5, -- 497
			ay0, -- 497
			aw + cam:len(26), -- 497
			ah + cam:len(24), -- 497
			{color = coldStone, layer = 2} -- 497
		) -- 497
		if not p.cartDocked then -- 497
			local bx0 = math.max(a.x0 + 4, p.cartAxle - 18) -- 503
			local bx1 = math.min(a.x1 - 4, p.cartAxle + 18) -- 504
			if bx1 > bx0 + 4 then -- 504
				local sbx0 = cam:sx(bx0) -- 506
				local sbx1 = cam:sx(bx1) -- 507
				local deckY = cam:sy(p.room.cart.baseY) -- 508
				worldArt:tryPlace( -- 509
					"fe_pillar_wood", -- 509
					"fe04_arch_bolt", -- 509
					(sbx0 + sbx1) * 0.5, -- 509
					ay0 + 2, -- 509
					sbx1 - sbx0, -- 509
					ah - 2, -- 509
					{ -- 509
						color = Color(172, 182, 198, 255), -- 510
						layer = 3 -- 511
					} -- 511
				) -- 511
				fgDraw:drawSegment( -- 513
					Vec2((sbx0 + sbx1) * 0.5, ay1), -- 513
					Vec2((sbx0 + sbx1) * 0.5, deckY), -- 513
					math.max( -- 513
						2, -- 513
						cam:len(2.4) -- 513
					), -- 513
					Color(96, 108, 124, 225) -- 513
				) -- 513
			end -- 513
		end -- 513
	end -- 513
	local si = 0 -- 519
	do -- 519
		si = 0 -- 520
		while si < #p.room.stairs do -- 520
			local st = p.room.stairs[si + 1] -- 521
			local n = math.max(1, st.steps + 1) -- 522
			local stepW = (st.x1 - st.x0) / n -- 523
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 524
			local baseWY = flatTop and 0 or math.max(0, st.y0) -- 525
			local k = 0 -- 526
			do -- 526
				k = 0 -- 527
				while k < n do -- 527
					do -- 527
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 528
						local x0 = cam:sx(st.x0 + stepW * k) -- 529
						local x1 = cam:sx(st.x0 + stepW * (k + 1)) -- 530
						if x1 < -20 or x0 > cam.viewW + 20 then -- 530
							goto __continue64 -- 532
						end -- 532
						local y0 = cam:sy(baseWY) -- 534
						local y1 = cam:sy(wy) -- 535
						if y1 > y0 + 2 then -- 535
							worldArt:tryPlace( -- 537
								"wall", -- 537
								(("fe04_st_" .. tostring(si)) .. "_") .. tostring(k), -- 537
								(x0 + x1) * 0.5, -- 537
								y0, -- 537
								x1 - x0 + 0.5, -- 537
								y1 - y0, -- 537
								{color = coldWall, opacity = 0.9, layer = 1} -- 537
							) -- 537
							worldArt:tryPlace( -- 542
								"slab", -- 542
								(("fe04_st_top_" .. tostring(si)) .. "_") .. tostring(k), -- 542
								(x0 + x1) * 0.5, -- 542
								y1 - cam:len(4), -- 542
								x1 - x0 + 0.5, -- 542
								cam:len(4.5), -- 542
								{color = coldStone, layer = 2} -- 542
							) -- 542
						end -- 542
					end -- 542
					::__continue64:: -- 542
					k = k + 1 -- 527
				end -- 527
			end -- 527
			si = si + 1 -- 520
		end -- 520
	end -- 520
	do -- 520
		si = 0 -- 551
		while si < #p.room.solids do -- 551
			do -- 551
				local s = p.room.solids[si + 1] -- 552
				if s.decorative == true or s.id == "outside_red_cart" then -- 552
					goto __continue68 -- 554
				end -- 554
				local x0 = cam:sx(s.x) -- 556
				local x1 = cam:sx(s.x + s.w) -- 557
				local y0 = cam:sy(s.y) -- 558
				local y1 = cam:sy(s.y + s.h) -- 559
				local sw = x1 - x0 -- 560
				local sh = y1 - y0 -- 561
				if sw <= 1 or sh <= 1 or x1 < -20 or x0 > cam.viewW + 20 then -- 561
					goto __continue68 -- 563
				end -- 563
				if s.y > 10 then -- 563
					local gy = cam:sy(0) -- 566
					local pierW = cam:len(18) -- 567
					worldArt:tryPlace( -- 568
						"wall", -- 568
						"fe04_pier_l_" .. tostring(si), -- 568
						x0 + pierW * 0.5, -- 568
						gy, -- 568
						pierW, -- 568
						y0 - gy, -- 568
						{ -- 568
							color = Color(122, 138, 162, 255), -- 568
							layer = 1 -- 568
						} -- 568
					) -- 568
					worldArt:tryPlace( -- 569
						"wall", -- 569
						"fe04_pier_r_" .. tostring(si), -- 569
						x1 - pierW * 0.5, -- 569
						gy, -- 569
						pierW, -- 569
						y0 - gy, -- 569
						{ -- 569
							color = Color(122, 138, 162, 255), -- 569
							layer = 1 -- 569
						} -- 569
					) -- 569
				end -- 569
				local cols = math.max( -- 571
					1, -- 571
					math.min( -- 571
						8, -- 571
						math.floor(s.w / 58 + 0.5) -- 571
					) -- 571
				) -- 571
				local rows = math.max( -- 572
					1, -- 572
					math.min( -- 572
						8, -- 572
						math.floor(s.h / 38 + 0.5) -- 572
					) -- 572
				) -- 572
				local tw = sw / cols -- 573
				local th = sh / rows -- 574
				local r = 0 -- 575
				local col = 0 -- 576
				do -- 576
					r = 0 -- 577
					while r < rows do -- 577
						do -- 577
							col = 0 -- 578
							while col < cols do -- 578
								worldArt:tryPlace( -- 579
									"wall", -- 579
									(((("fe04_wall_" .. tostring(si)) .. "_") .. tostring(r)) .. "_") .. tostring(col), -- 579
									x0 + (col + 0.5) * tw, -- 579
									y0 + r * th, -- 579
									tw + 0.5, -- 579
									th + 0.5, -- 579
									{color = coldWall, facing = (r + col) % 2 == 0 and 1 or -1, layer = 2} -- 579
								) -- 579
								col = col + 1 -- 578
							end -- 578
						end -- 578
						r = r + 1 -- 577
					end -- 577
				end -- 577
			end -- 577
			::__continue68:: -- 577
			si = si + 1 -- 551
		end -- 551
	end -- 551
	local redBox = __TS__ArrayFind( -- 589
		p.boxes, -- 589
		function(____, b) return b.id == "outside_red_cart" end -- 589
	) -- 589
	if redBox ~= nil and redBox.broken ~= true and redBox.hidden ~= true then -- 589
		local rx0 = cam:sx(redBox.x0) -- 591
		local rx1 = cam:sx(redBox.x1) -- 592
		local ry0 = cam:sy(redBox.y0) -- 593
		local ry1 = cam:sy(redBox.y1) -- 594
		local rw = rx1 - rx0 -- 595
		local rh = ry1 - ry0 -- 596
		worldArt:tryPlace( -- 597
			"prop_cart", -- 597
			"fe04_out_red_box", -- 597
			(rx0 + rx1) * 0.5, -- 597
			ry0, -- 597
			rw * 1.15, -- 597
			rh * 1.05, -- 597
			{ -- 597
				color = Color(192, 206, 224, 255), -- 598
				layer = 3 -- 599
			} -- 599
		) -- 599
		local clothFrame = math.floor(self.animTime * 4.2) % 3 -- 601
		worldArt:tryPlace( -- 602
			"fe_red_cloth", -- 602
			"fe04_out_red_box_cloth", -- 602
			rx0 + cam:len(6), -- 602
			ry1 - cam:len(4), -- 602
			cam:len(20), -- 602
			cam:len(20), -- 602
			{frame = clothFrame, layer = 4} -- 602
		) -- 602
	end -- 602
	local c = p.room.cart -- 609
	if c.bodyW > 0 then -- 609
		local deckY = cam:sy(c.baseY) -- 611
		fgDraw:drawSegment( -- 612
			Vec2( -- 612
				cam:sx(ox + 258), -- 612
				deckY + 1 -- 612
			), -- 612
			Vec2( -- 612
				cam:sx(ox + 474), -- 612
				deckY + 1 -- 612
			), -- 612
			1.4, -- 612
			Color(62, 74, 92, 165) -- 612
		) -- 612
		local dockX = cam:sx(c.endX) -- 613
		worldArt:tryPlace( -- 614
			"slab", -- 614
			"fe04_cart_dock", -- 614
			dockX, -- 614
			deckY - cam:len(4), -- 614
			cam:len(34), -- 614
			cam:len(6), -- 614
			{ -- 614
				color = Color(86, 98, 118, 255), -- 615
				layer = 2 -- 616
			} -- 616
		) -- 616
	end -- 616
	local endGlowX = cam:sx(ox + 1120) -- 621
	local endGlowY = cam:sy(76) -- 622
	fillRadialGlow( -- 623
		fgGlow, -- 623
		endGlowX, -- 623
		endGlowY, -- 623
		cam:len(96), -- 623
		cam:len(118), -- 623
		Color(234, 198, 138, 34), -- 623
		Color(234, 198, 138, 0), -- 623
		14 -- 623
	) -- 623
	fgDraw:drawEllipse( -- 624
		Vec2( -- 624
			cam:sx(p.player.x), -- 624
			cam:sy(p.player.y) + 1 -- 624
		), -- 624
		cam:len(14), -- 624
		3.4, -- 624
		Color(8, 12, 18, 150) -- 624
	) -- 624
	return true -- 626
end -- 445
function LowpolyWorldPlugin.prototype.drawTowerWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 629
	local p = ctx.p -- 635
	local cam = ctx.cam -- 636
	local ox = p.ox -- 637
	local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 638
	local towerTint = Color(172, 188, 210, 255) -- 643
	local groundY = cam:sy(0) -- 644
	local gLeft = cam:sx(ox - 40) -- 647
	local gRight = cam:sx(ox + 760) -- 648
	local deckH = cam:len(26) -- 649
	if groundY - deckH > 0 then -- 649
		fillVGradRect( -- 651
			fgDraw, -- 651
			gLeft, -- 651
			0, -- 651
			gRight - gLeft, -- 651
			groundY - deckH + 1, -- 651
			Color(10, 14, 22, 255), -- 651
			Color(24, 30, 42, 255) -- 651
		) -- 651
	end -- 651
	local step = math.max( -- 653
		24, -- 653
		cam:len(76) -- 653
	) -- 653
	local j = 0 -- 654
	do -- 654
		j = 0 -- 655
		while gLeft + j * step < gRight do -- 655
			local tx = gLeft + j * step -- 656
			local tw = math.min(step, gRight - tx) -- 657
			worldArt:tryPlace( -- 658
				"fe_road_stone", -- 658
				"fe04_tw_floor_" .. tostring(j), -- 658
				tx + tw * 0.5, -- 658
				groundY - deckH, -- 658
				tw + 0.5, -- 658
				deckH, -- 658
				{color = towerTint, layer = 1} -- 658
			) -- 658
			j = j + 1 -- 655
		end -- 655
	end -- 655
	worldArt:tryPlace( -- 663
		"slab", -- 663
		"fe04_tw_sill", -- 663
		cam:sx(ox + 445), -- 663
		groundY - cam:len(3), -- 663
		cam:len(94), -- 663
		cam:len(6), -- 663
		{ -- 663
			color = Color(196, 206, 220, 255), -- 664
			layer = 2 -- 665
		} -- 665
	) -- 665
	local function tileWallBlock(prefix, wx0, wx1, wy0, wy1) -- 669
		local x0 = cam:sx(wx0) -- 670
		local x1 = cam:sx(wx1) -- 671
		local y0 = cam:sy(wy0) -- 672
		local y1 = cam:sy(wy1) -- 673
		local cols = math.max( -- 674
			1, -- 674
			math.floor((wx1 - wx0) / 56 + 0.5) -- 674
		) -- 674
		local rows = math.max( -- 675
			1, -- 675
			math.floor((wy1 - wy0) / 38 + 0.5) -- 675
		) -- 675
		local tw = (x1 - x0) / cols -- 676
		local th = (y1 - y0) / rows -- 677
		local r = 0 -- 678
		local c = 0 -- 679
		do -- 679
			r = 0 -- 680
			while r < rows do -- 680
				do -- 680
					c = 0 -- 681
					while c < cols do -- 681
						worldArt:tryPlace( -- 682
							"wall", -- 682
							(((prefix .. "_") .. tostring(r)) .. "_") .. tostring(c), -- 682
							x0 + (c + 0.5) * tw, -- 682
							y0 + r * th, -- 682
							tw + 0.5, -- 682
							th + 0.5, -- 682
							{color = towerTint, facing = (r + c) % 2 == 0 and 1 or -1, layer = 1} -- 682
						) -- 682
						c = c + 1 -- 681
					end -- 681
				end -- 681
				r = r + 1 -- 680
			end -- 680
		end -- 680
	end -- 669
	tileWallBlock( -- 690
		"fe04_tw_wl", -- 690
		ox + 180, -- 690
		ox + 400, -- 690
		0, -- 690
		215 -- 690
	) -- 690
	tileWallBlock( -- 691
		"fe04_tw_wr", -- 691
		ox + 490, -- 691
		ox + 720, -- 691
		0, -- 691
		215 -- 691
	) -- 691
	tileWallBlock( -- 693
		"fe04_tw_lintel", -- 693
		ox + 398, -- 693
		ox + 492, -- 693
		110, -- 693
		152 -- 693
	) -- 693
	local doorCx = cam:sx(ox + 445) -- 696
	local doorW = cam:len(90) -- 697
	local doorH = cam:len(110) -- 698
	local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 699
	if not opened then -- 699
		worldArt:tryPlace( -- 701
			"prop_tower_door", -- 701
			"fe04_tw_door", -- 701
			doorCx, -- 701
			groundY, -- 701
			doorW, -- 701
			doorH, -- 701
			{ -- 701
				color = Color(204, 212, 224, 255), -- 702
				layer = 2 -- 703
			} -- 703
		) -- 703
	else -- 703
		fillVGradRect( -- 706
			fgGlow, -- 706
			doorCx - doorW * 0.46, -- 706
			groundY, -- 706
			doorW * 0.92, -- 706
			doorH, -- 706
			Color( -- 706
				246, -- 706
				204, -- 706
				132, -- 706
				math.floor(92 * pulse + 0.5) -- 706
			), -- 706
			Color(255, 226, 166, 155) -- 706
		) -- 706
		local roomX0 = cam:sx(ox + 492) -- 707
		local roomX1 = cam:sx(ox + 724) -- 708
		worldArt:tryPlace( -- 709
			"slide_tower_interior_live", -- 709
			"fe04_tw_room_live", -- 709
			(roomX0 + roomX1) * 0.5, -- 709
			groundY, -- 709
			roomX1 - roomX0, -- 709
			cam:len(172), -- 709
			{layer = 2} -- 709
		) -- 709
	end -- 709
	local lampX = doorCx -- 715
	local lampY = cam:sy(102) -- 716
	worldArt:tryPlace( -- 717
		"prop_lantern", -- 717
		"fe04_tw_lamp", -- 717
		lampX, -- 717
		lampY, -- 717
		cam:len(16), -- 717
		cam:len(22), -- 717
		{layer = 3} -- 717
	) -- 717
	fillRadialGlow( -- 718
		fgGlow, -- 719
		lampX, -- 720
		lampY, -- 721
		cam:len(opened and 68 or 38) * pulse, -- 722
		cam:len(opened and 68 or 38) * pulse, -- 723
		Color( -- 724
			248, -- 724
			214, -- 724
			146, -- 724
			math.floor((opened and 132 or 78) * pulse + 0.5) -- 724
		), -- 724
		Color(232, 174, 82, 0), -- 725
		16 -- 726
	) -- 726
	local winX = cam:sx(ox + 296) -- 729
	local winY = cam:sy(138) -- 730
	fgDraw:drawRect( -- 731
		Rect( -- 731
			winX - cam:len(10), -- 731
			winY - cam:len(18), -- 731
			cam:len(20), -- 731
			cam:len(36) -- 731
		), -- 731
		Color(242, 198, 126, 235), -- 731
		1.4, -- 731
		Color(68, 52, 38, 235) -- 731
	) -- 731
	fgDraw:drawSegment( -- 732
		Vec2( -- 732
			winX, -- 732
			winY - cam:len(18) -- 732
		), -- 732
		Vec2( -- 732
			winX, -- 732
			winY + cam:len(18) -- 732
		), -- 732
		1.3, -- 732
		Color(68, 52, 38, 225) -- 732
	) -- 732
	fgDraw:drawSegment( -- 733
		Vec2( -- 733
			winX - cam:len(10), -- 733
			winY -- 733
		), -- 733
		Vec2( -- 733
			winX + cam:len(10), -- 733
			winY -- 733
		), -- 733
		1.3, -- 733
		Color(68, 52, 38, 225) -- 733
	) -- 733
	fillRadialGlow( -- 734
		fgGlow, -- 734
		winX, -- 734
		winY, -- 734
		cam:len(40), -- 734
		cam:len(44), -- 734
		Color( -- 734
			246, -- 734
			206, -- 734
			132, -- 734
			math.floor(78 * pulse + 0.5) -- 734
		), -- 734
		Color(232, 174, 82, 0), -- 734
		14 -- 734
	) -- 734
	fgDraw:drawEllipse( -- 737
		Vec2( -- 737
			cam:sx(p.player.x), -- 737
			cam:sy(p.player.y) + 1 -- 737
		), -- 737
		cam:len(14), -- 737
		3.4, -- 737
		Color(8, 12, 18, 145) -- 737
	) -- 737
	return true -- 739
end -- 629
function LowpolyWorldPlugin.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 742
	if not self.active then -- 742
		return false -- 749
	end -- 749
	local key = ctx.p.room.key -- 751
	if key == "village" then -- 751
		return self.village:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 753
	end -- 753
	if key == "forest" then -- 753
		return self.forest:drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 756
	end -- 756
	if key == "outside" then -- 756
		return self:drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx) -- 759
	end -- 759
	if key == "tower" then -- 759
		local p = ctx.p -- 762
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" -- 763
		if opened then -- 763
			local cam = ctx.cam -- 765
			local deskCx = cam:sx(p.ox + 605) -- 766
			local groundY = cam:sy(0) -- 767
			local deskW = cam:len(88) -- 768
			local deskH = cam:len(38) -- 769
			local deskTop = groundY + deskH -- 770
			local pulse = 0.88 + 0.12 * math.sin(self.animTime * 2.8) -- 771
			fillRadialGlow( -- 772
				fgGlow, -- 772
				deskCx, -- 772
				deskTop + cam:len(28), -- 772
				cam:len(124), -- 772
				cam:len(90), -- 772
				Color( -- 773
					255, -- 773
					198, -- 773
					114, -- 773
					math.floor(74 * pulse + 0.5) -- 773
				), -- 773
				Color(255, 168, 72, 0), -- 773
				16 -- 773
			) -- 773
			worldArt:tryPlace( -- 775
				"fe_tower_guard_lantern", -- 775
				"fe04_tw_guard", -- 775
				deskCx + cam:len(32), -- 775
				groundY, -- 775
				cam:len(54), -- 775
				cam:len(82), -- 775
				{layer = 4} -- 775
			) -- 775
			worldArt:tryPlace( -- 778
				"fe_workbench", -- 778
				"fe04_tw_desk", -- 778
				deskCx, -- 778
				groundY, -- 778
				deskW, -- 778
				deskH, -- 778
				{ -- 778
					color = Color(238, 218, 196, 255), -- 779
					layer = 5 -- 780
				} -- 780
			) -- 780
			worldArt:tryPlace( -- 782
				"fe_tower_lantern_detail", -- 782
				"fe04_tw_desk_lamp", -- 782
				deskCx + cam:len(30), -- 782
				deskTop - cam:len(2), -- 782
				cam:len(18), -- 782
				cam:len(24), -- 782
				{layer = 6} -- 782
			) -- 782
			if p.deskHold >= 12 or p.towerHanded then -- 782
				worldArt:tryPlace( -- 786
					"fe_tower_pouch_note", -- 786
					"fe04_tw_handover", -- 786
					deskCx - cam:len(14), -- 786
					deskTop + cam:len(6), -- 786
					cam:len(30), -- 786
					cam:len(18), -- 786
					{layer = 6} -- 786
				) -- 786
			end -- 786
		end -- 786
		return true -- 791
	end -- 791
	return false -- 793
end -- 742
function LowpolyWorldPlugin.prototype.drawOutsideCartLowpoly(self, fgDraw, _fgGlow, worldArt, ctx) -- 797
	local p = ctx.p -- 803
	local cam = ctx.cam -- 804
	local c = p.room.cart -- 805
	if c.bodyW <= 0 then -- 805
		return true -- 807
	end -- 807
	local halfW = c.bodyW * 0.5 -- 809
	local axleX = p.cartAxle -- 810
	local baseY = cam:sy(c.baseY) -- 811
	local bodyTopY = cam:sy(c.baseY + c.wheelR + c.bodyH) -- 812
	local cx = cam:sx(axleX) -- 813
	local artW = cam:len(c.bodyW * 1.38) -- 814
	local artH = cam:len((c.wheelR * 2 + c.bodyH) * 0.94) -- 815
	fgDraw:drawEllipse( -- 817
		Vec2(cx, baseY + 1), -- 817
		cam:len(c.bodyW * 0.62), -- 817
		4, -- 817
		Color(6, 10, 16, 155) -- 817
	) -- 817
	worldArt:tryPlace( -- 818
		"prop_cart", -- 818
		"fe04_outside_cart", -- 818
		cx, -- 818
		baseY, -- 818
		artW, -- 818
		artH, -- 818
		{ -- 818
			color = Color(196, 210, 228, 255), -- 819
			layer = 5 -- 820
		} -- 820
	) -- 820
	local clothX = axleX - halfW -- 824
	local clothFrame = math.floor(self.animTime * (self.cartWheelVol > 0.05 and 6.5 or 3.8)) % 3 -- 825
	worldArt:tryPlace( -- 826
		"fe_red_cloth", -- 826
		"fe04_outside_cart_cloth", -- 826
		cam:sx(clothX + 2), -- 826
		bodyTopY - cam:len(2), -- 826
		cam:len(24), -- 826
		cam:len(24), -- 826
		{frame = clothFrame, layer = 6} -- 826
	) -- 826
	return true -- 831
end -- 797
function LowpolyWorldPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 834
	if not self.active then -- 834
		return -- 841
	end -- 841
	local key = ctx.p.room.key -- 843
	if key == "village" then -- 843
		self.village:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 845
	elseif key == "forest" then -- 845
		self.forest:drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx) -- 847
	end -- 847
end -- 834
function LowpolyWorldPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 855
	if not self.active then -- 855
		return false -- 863
	end -- 863
	local key = ctx.p.room.key -- 865
	if key == "village" then -- 865
		return self.village:drawForegroundOverlay( -- 867
			uiDraw, -- 867
			uiInkDraw, -- 867
			uiArt, -- 867
			uiGlow, -- 867
			ctx -- 867
		) -- 867
	end -- 867
	if key == "forest" then -- 867
		return self.forest:drawForegroundOverlay( -- 870
			uiDraw, -- 870
			uiInkDraw, -- 870
			uiArt, -- 870
			uiGlow, -- 870
			ctx -- 870
		) -- 870
	end -- 870
	if key == "outside" then -- 870
		drawChildColdMoonGrade( -- 873
			uiDraw, -- 873
			uiGlow, -- 873
			ctx.uiW, -- 873
			ctx.uiH, -- 873
			0.72, -- 873
			0 -- 873
		) -- 873
		self:drawOutsideSewingMemoryOverlay( -- 874
			uiDraw, -- 874
			uiInkDraw, -- 874
			uiArt, -- 874
			uiGlow, -- 874
			ctx -- 874
		) -- 874
		return false -- 875
	end -- 875
	if key == "tower" then -- 875
		drawChildColdMoonGrade( -- 878
			uiDraw, -- 878
			uiGlow, -- 878
			ctx.uiW, -- 878
			ctx.uiH, -- 878
			0.44, -- 878
			0.45 -- 878
		) -- 878
	end -- 878
	return false -- 880
end -- 855
function LowpolyWorldPlugin.prototype.drawOutsideSewingMemoryOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 887
	if self.memoryTimer < 0 or self.memoryTimer >= SEWING_MEMORY_DURATION then -- 887
		return -- 895
	end -- 895
	local prog = clamp01(self.memoryTimer / SEWING_MEMORY_DURATION) -- 897
	local alpha = smoothstep(0, 0.2, prog) * (1 - smoothstep(0.72, 1, prog)) -- 899
	if alpha <= 0.01 then -- 899
		return -- 901
	end -- 901
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 903
	local handPt = projectWorld3D( -- 904
		self.memoryAnchorWorldX, -- 904
		self.memoryAnchorWorldY, -- 904
		0, -- 904
		ctx.cam, -- 904
		self.outsideProj -- 904
	) -- 904
	local cardW = 264 -- 905
	local cardH = 148 -- 906
	local cx = math.max( -- 907
		cardW * 0.5 + 24, -- 907
		math.min(ctx.uiW - cardW * 0.5 - 24, handPt.x * inv - 16) -- 907
	) -- 907
	local cy = math.max( -- 908
		cardH * 0.5 + 32, -- 908
		math.min(ctx.uiH - cardH * 0.5 - 32, handPt.y * inv + 102) -- 908
	) -- 908
	local rect = { -- 909
		x = math.floor(cx - cardW * 0.5 + 0.5), -- 909
		y = math.floor(cy - cardH * 0.5 + 0.5), -- 909
		w = cardW, -- 909
		h = cardH -- 909
	} -- 909
	fillRadialGlow( -- 911
		uiGlow, -- 911
		cx, -- 911
		cy, -- 911
		cardW * 0.82, -- 911
		cardH * 0.92, -- 911
		Color( -- 911
			238, -- 911
			190, -- 911
			122, -- 911
			math.floor(88 * alpha + 0.5) -- 911
		), -- 911
		Color(218, 162, 92, 0), -- 911
		20 -- 911
	) -- 911
	local zoom = 1 + prog * 0.036 -- 912
	drawPixelSlidePlate( -- 913
		uiDraw, -- 913
		uiInkDraw, -- 913
		uiArt, -- 913
		"slide_f01_sewing", -- 913
		"fe04_sewing_mem", -- 913
		rect, -- 913
		alpha * 0.96, -- 913
		3, -- 913
		0, -- 913
		0, -- 913
		zoom -- 913
	) -- 913
	drawSlideFrameChrome( -- 914
		uiDraw, -- 914
		uiInkDraw, -- 914
		uiArt, -- 914
		rect, -- 914
		ctx.uiW, -- 914
		ctx.uiH, -- 914
		{ -- 914
			frameOpacity = 0.78, -- 915
			letterboxH = 0, -- 916
			opacity = alpha, -- 917
			layer = 3, -- 918
			instancePrefix = "fe04_sew" -- 919
		} -- 919
	) -- 919
end -- 887
function ____exports.createLowpolyWorldPlugin() -- 924
	return __TS__New(____exports.LowpolyWorldPlugin) -- 925
end -- 924
--- 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require）
function ____exports.registerFe04Plugins(fe) -- 929
	local lowpolyWorld = __TS__New(____exports.LowpolyWorldPlugin) -- 932
	fe:registerPlugin(lowpolyWorld) -- 933
	return {lowpolyWorld = lowpolyWorld} -- 934
end -- 929
return ____exports -- 929