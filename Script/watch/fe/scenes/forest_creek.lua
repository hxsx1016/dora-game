-- [ts]: forest_creek.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
local Content = ____Dora.Content -- 18
local Rect = ____Dora.Rect -- 18
local Vec2 = ____Dora.Vec2 -- 18
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 23
local clamp01 = ____lowpoly.clamp01 -- 25
local projectWorld3D = ____lowpoly.projectWorld3D -- 26
local smoothstep = ____lowpoly.smoothstep -- 27
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 29
local drawChildColdMoonGrade = ____slideshow.drawChildColdMoonGrade -- 29
local ____theme = require("Script.watch.fe.theme") -- 30
local fillRadialGlow = ____theme.fillRadialGlow -- 31
local fillVGradRect = ____theme.fillVGradRect -- 32
local lerpRGBA = ____theme.lerpRGBA -- 33
local rgba = ____theme.rgba -- 34
local toColor = ____theme.toColor -- 35
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 38
--- 林径枯枝集群位置（段内 X）
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 41
____exports.ForestCreekScene = __TS__Class() -- 66
local ForestCreekScene = ____exports.ForestCreekScene -- 66
ForestCreekScene.name = "ForestCreekScene" -- 66
function ForestCreekScene.prototype.____constructor(self) -- 66
	self.animTime = 0 -- 67
	self.active = false -- 68
	self.ripplePhase = 0 -- 69
	self.creekReveal = 0 -- 70
	self.creekWaterVol = 0 -- 71
	self.twigSnapCount = 0 -- 73
	self.twigTriggered = {} -- 74
	self.xiaomanListenTimer = 0 -- 75
	self.xiaomanListenDir = 1 -- 76
	self.prevDogState = "patrol" -- 78
	self.dogAlertCount = 0 -- 79
	self.dogStepCount = 0 -- 80
	self.dogStepAccum = 0 -- 81
	self.prevDogX = 0 -- 82
	self.splinters = {} -- 84
	self.rng = 9417 -- 85
	self.proj = { -- 87
		morph = 1, -- 88
		focal = 405, -- 89
		vpFracX = 0.54, -- 90
		vpFracY = 0.5, -- 91
		vpOffsetX = 0, -- 92
		vpOffsetY = 0, -- 93
		baseDepth = 0 -- 94
	} -- 94
end -- 66
function ForestCreekScene.prototype.reset(self) -- 97
	self.animTime = 0 -- 98
	self.active = false -- 99
	self.ripplePhase = 0 -- 100
	self.creekReveal = 0 -- 101
	self.creekWaterVol = 0 -- 102
	self.twigSnapCount = 0 -- 103
	self.twigTriggered = {} -- 104
	self.xiaomanListenTimer = 0 -- 105
	self.xiaomanListenDir = 1 -- 106
	self.prevDogState = "patrol" -- 107
	self.dogAlertCount = 0 -- 108
	self.dogStepCount = 0 -- 109
	self.dogStepAccum = 0 -- 110
	self.prevDogX = 0 -- 111
	self.splinters = {} -- 112
end -- 97
function ForestCreekScene.prototype.rand(self) -- 115
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 116
	return self.rng / 4294967296 -- 117
end -- 115
function ForestCreekScene.prototype.getProjection(self) -- 120
	return self.proj -- 121
end -- 120
function ForestCreekScene.prototype.getDebugState(self, p) -- 124
	local px = p ~= nil and p.player.x or 0 -- 125
	local ox = p ~= nil and p.ox or 0 -- 126
	local reflectionVisible = self.active and px >= ox + 1140 -- 127
	local trueLampVisible = self.active and self.creekReveal >= 0.35 -- 128
	return { -- 129
		active = self.active, -- 130
		twigSnapCount = self.twigSnapCount, -- 131
		xiaomanListenTimer = self.xiaomanListenTimer, -- 132
		dogAlertCount = self.dogAlertCount, -- 133
		dogStepCount = self.dogStepCount, -- 134
		creekReveal = self.creekReveal, -- 135
		ripplePhase = self.ripplePhase, -- 136
		trueLampVisible = trueLampVisible, -- 137
		reflectionVisible = reflectionVisible, -- 138
		creekWaterVol = self.creekWaterVol -- 139
	} -- 139
end -- 124
function ForestCreekScene.prototype.update(self, ctx) -- 143
	local p = ctx.p -- 144
	self.active = true -- 145
	local ox = p.ox -- 146
	ctx.cam:setAnchorLock(nil) -- 149
	self.creekReveal = smoothstep(ox + 1310, ox + 1435, p.player.x) -- 152
	if not ctx.paused and ctx.worldDt > 0 then -- 152
		local dt = ctx.worldDt -- 155
		self.animTime = self.animTime + dt -- 156
		self.ripplePhase = self.ripplePhase + dt * 2.4 -- 158
		if self.xiaomanListenTimer > 0 then -- 158
			self.xiaomanListenTimer = math.max(0, self.xiaomanListenTimer - dt) -- 161
		end -- 161
		local movingFast = not p.player.crouch and (math.abs(p.player.vx) > 10 or not p.player.onGround) -- 165
		local i = 0 -- 166
		do -- 166
			i = 0 -- 167
			while i < #TWIG_OFFSETS do -- 167
				local tx = ox + TWIG_OFFSETS[i + 1] -- 168
				local lastSnapAt = self.twigTriggered[i] or -99 -- 169
				if movingFast and math.abs(p.player.x - tx) <= 18 and p.player.y <= 8 and self.animTime - lastSnapAt > 2.4 then -- 169
					self.twigTriggered[i] = self.animTime -- 171
					self:triggerTwigSnap(ctx, tx, p.dogX >= p.player.x and 1 or -1) -- 172
				end -- 172
				i = i + 1 -- 167
			end -- 167
		end -- 167
		if p.room.story ~= nil and p.room.story.dog ~= nil then -- 167
			if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 167
				self.dogAlertCount = self.dogAlertCount + 1 -- 179
				self:triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x and 1 or -1) -- 180
				ctx.audio:playOnce( -- 181
					(("fe04:forest:dog_alert:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 182
					"sfx", -- 183
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 184
					0.82, -- 185
					"fe04:forest:dog_alert", -- 186
					p.ticks, -- 187
					-1, -- 187
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 189
				) -- 189
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 189
				self.dogAlertCount = self.dogAlertCount + 1 -- 192
				local chasePath = Content:exist("assets/audio/foley/dog_chase_bark.wav") and "assets/audio/foley/dog_chase_bark.wav" or CHILD_AUDIO_ROOT .. "dog_alert.wav" -- 193
				ctx.audio:playOnce( -- 196
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 197
					"sfx", -- 198
					chasePath, -- 199
					0.9, -- 200
					"fe04:forest:dog_chase", -- 201
					p.ticks, -- 202
					-1, -- 202
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 204
				) -- 204
			end -- 204
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 208
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 208
				self.dogStepAccum = self.dogStepAccum + dogDx -- 210
				local stepStride = p.dogState == "chase" and 28 or 42 -- 211
				if self.dogStepAccum >= stepStride then -- 211
					self.dogStepAccum = 0 -- 213
					local dist = math.abs(p.player.x - p.dogX) -- 214
					if dist < 420 then -- 214
						self.dogStepCount = self.dogStepCount + 1 -- 216
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 217
						ctx.audio:playOnce( -- 218
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 219
							"sfx", -- 220
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 221
							vol, -- 222
							"fe04:forest:dog_step", -- 223
							p.ticks, -- 224
							-1, -- 224
							{pan = ctx.audio:panForWorldX(p.dogX)} -- 226
						) -- 226
					end -- 226
				end -- 226
			end -- 226
			self.prevDogX = p.dogX -- 231
			self.prevDogState = p.dogState -- 232
		end -- 232
		local w = 0 -- 236
		do -- 236
			i = 0 -- 237
			while i < #self.splinters do -- 237
				local sp = self.splinters[i + 1] -- 238
				sp.life = sp.life - dt -- 239
				if sp.life > 0 then -- 239
					sp.vy = sp.vy - 320 * dt -- 241
					sp.x = sp.x + sp.vx * dt -- 242
					sp.y = sp.y + sp.vy * dt -- 243
					if sp.y < 0 then -- 243
						sp.y = 0 -- 245
						sp.vy = 0 -- 246
						sp.vx = sp.vx * 0.4 -- 247
					end -- 247
					self.splinters[w + 1] = sp -- 249
					w = w + 1 -- 250
				end -- 250
				i = i + 1 -- 237
			end -- 237
		end -- 237
		__TS__ArraySetLength(self.splinters, w) -- 237
		local creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x) -- 256
		local windVol = 0.34 * (1 - creekApproach * 0.42) -- 257
		self.creekWaterVol = 0.02 + 0.54 * creekApproach -- 258
		ctx.audio:playLoop( -- 259
			"fe04_forest_wind", -- 259
			"wind", -- 259
			CHILD_AUDIO_ROOT .. "forest_wind_loop.wav", -- 259
			windVol, -- 259
			p.ticks -- 259
		) -- 259
		if creekApproach > 0.02 then -- 259
			ctx.audio:playLoop( -- 261
				"fe04_creek_water", -- 261
				"water", -- 261
				CHILD_AUDIO_ROOT .. "creek_loop.wav", -- 261
				self.creekWaterVol, -- 261
				p.ticks -- 261
			) -- 261
		else -- 261
			ctx.audio:stopLoop("fe04_creek_water", 0.25) -- 263
		end -- 263
	end -- 263
	self.proj = { -- 267
		morph = 1, -- 268
		focal = 405, -- 269
		vpFracX = 0.54, -- 270
		vpFracY = 0.5, -- 271
		vpOffsetX = math.sin(self.animTime * 0.55) * 1.8, -- 272
		vpOffsetY = math.cos(self.animTime * 0.72) * 1.2, -- 273
		baseDepth = 0 -- 274
	} -- 274
end -- 143
function ForestCreekScene.prototype.triggerTwigSnap(self, ctx, worldX, listenDir) -- 278
	self.twigSnapCount = self.twigSnapCount + 1 -- 279
	self.xiaomanListenTimer = 0.52 -- 280
	self.xiaomanListenDir = listenDir >= 0 and 1 or -1 -- 281
	ctx.audio:playOnce( -- 282
		(("fe04:forest:twig:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.twigSnapCount), -- 283
		"sfx", -- 284
		CHILD_AUDIO_ROOT .. "twig_snap.wav", -- 285
		0.84, -- 286
		"fe04:forest:twig_snap", -- 287
		ctx.p.ticks, -- 288
		-1, -- 288
		{pan = ctx.audio:panForWorldX(worldX)} -- 290
	) -- 290
	local i = 0 -- 292
	do -- 292
		i = 0 -- 293
		while i < 6 do -- 293
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 294
			local spd = 45 + self:rand() * 75 -- 295
			local ____self_splinters_0 = self.splinters -- 295
			____self_splinters_0[#____self_splinters_0 + 1] = { -- 296
				x = worldX + (self:rand() - 0.5) * 10, -- 297
				y = 2, -- 298
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 299
				vy = math.sin(ang) * spd, -- 300
				len = 3.5 + self:rand() * 3.5, -- 301
				life = 0.38 + self:rand() * 0.22, -- 302
				maxLife = 0.6 -- 303
			} -- 303
			i = i + 1 -- 293
		end -- 293
	end -- 293
end -- 278
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 308
	local p = ctx.p -- 314
	local cam = ctx.cam -- 315
	local ox = p.ox -- 316
	local w = cam.viewW -- 317
	local h = cam.viewH -- 318
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 321
	local skyTop = lerpRGBA( -- 322
		rgba(8, 14, 18, 255), -- 322
		rgba(16, 26, 38, 255), -- 322
		dawn -- 322
	) -- 322
	local skyHor = lerpRGBA( -- 323
		rgba(22, 36, 40, 255), -- 323
		rgba(52, 68, 86, 255), -- 323
		dawn -- 323
	) -- 323
	fillVGradRect( -- 324
		bgDraw, -- 324
		0, -- 324
		0, -- 324
		w, -- 324
		h, -- 324
		toColor(skyHor), -- 324
		toColor(skyTop) -- 324
	) -- 324
	local span = math.max(1, p.room.maxX - p.room.minX) -- 326
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 327
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 328
	local artH = artW * 9 / 16 -- 329
	local artY = math.min( -- 330
		0, -- 330
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 330
	) -- 330
	local bgTint = toColor(lerpRGBA( -- 331
		rgba(138, 170, 180, 255), -- 331
		rgba(194, 210, 232, 255), -- 331
		dawn -- 331
	)) -- 331
	backdropArt:tryPlace( -- 332
		"bgFar_forest", -- 332
		"fe04_bg_forest", -- 332
		w * (0.5 - progress * 0.08), -- 332
		artY, -- 332
		artW, -- 332
		artH, -- 332
		{color = bgTint, layer = 0} -- 332
	) -- 332
	fillVGradRect( -- 336
		bgGlow, -- 336
		0, -- 336
		cam.groundScreenY - 2, -- 336
		w, -- 336
		h * 0.16, -- 336
		Color(24, 40, 44, 26), -- 336
		Color(12, 20, 24, 0) -- 336
	) -- 336
	local towerX = ox + 1525 -- 339
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 340
	local lampPt = projectWorld3D( -- 341
		towerX - 4, -- 341
		146, -- 341
		330, -- 341
		cam, -- 341
		self.proj -- 341
	) -- 341
	fillRadialGlow( -- 342
		bgGlow, -- 343
		lampPt.x, -- 344
		lampPt.y, -- 345
		42 * lampPulse, -- 346
		42 * lampPulse, -- 347
		Color( -- 348
			246, -- 348
			208, -- 348
			134, -- 348
			math.floor(115 * lampPulse + 0.5) -- 348
		), -- 348
		Color(232, 176, 86, 0), -- 349
		16 -- 350
	) -- 350
	bgDraw:drawRect( -- 352
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 352
		Color(255, 232, 174, 240) -- 352
	) -- 352
	bgGlow:drawDot( -- 353
		Vec2(lampPt.x, lampPt.y), -- 353
		3.4, -- 353
		Color(255, 246, 218, 250) -- 353
	) -- 353
	return true -- 355
end -- 308
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 358
	local p = ctx.p -- 364
	local cam = ctx.cam -- 365
	local ox = p.ox -- 366
	local groundY = cam:sy(0) -- 367
	local deckH = cam:len(26) -- 368
	local xForest0 = cam:sx(ox - 40) -- 371
	local xCreek0 = cam:sx(ox + 1185) -- 372
	local xCreek1 = cam:sx(ox + 1640) -- 373
	if groundY - deckH > 0 then -- 373
		fillVGradRect( -- 375
			fgDraw, -- 375
			xForest0, -- 375
			0, -- 375
			xCreek0 - xForest0, -- 375
			groundY - deckH + 1, -- 375
			Color(8, 14, 14, 255), -- 375
			Color(18, 28, 26, 255) -- 375
		) -- 375
		fillVGradRect( -- 377
			fgDraw, -- 377
			xCreek0, -- 377
			0, -- 377
			xCreek1 - xCreek0, -- 377
			groundY - cam:len(6), -- 377
			Color(12, 22, 32, 255), -- 377
			Color(24, 42, 54, 255) -- 377
		) -- 377
	end -- 377
	local tileSpan = math.max( -- 379
		24, -- 379
		cam:len(74) -- 379
	) -- 379
	local j = 0 -- 380
	do -- 380
		j = 0 -- 381
		while xForest0 + j * tileSpan < math.min(xCreek0, cam.viewW + 40) do -- 381
			do -- 381
				local tx = xForest0 + j * tileSpan -- 382
				local tw = math.min(tileSpan, xCreek0 - tx) -- 383
				if tx + tw < -40 then -- 383
					goto __continue32 -- 385
				end -- 385
				worldArt:tryPlace( -- 387
					"fe_ground_soft", -- 387
					"fe04_for_moss_" .. tostring(j), -- 387
					tx + tw * 0.5, -- 387
					groundY - deckH, -- 387
					tw + 2, -- 387
					deckH, -- 387
					{ -- 387
						color = Color(118, 148, 134, 255), -- 388
						layer = 1 -- 389
					} -- 389
				) -- 389
			end -- 389
			::__continue32:: -- 389
			j = j + 1 -- 381
		end -- 381
	end -- 381
	do -- 381
		j = 0 -- 392
		while xCreek0 + j * tileSpan < math.min(xCreek1, cam.viewW + 40) do -- 392
			do -- 392
				local tx = xCreek0 + j * tileSpan -- 393
				local tw = math.min(tileSpan, xCreek1 - tx) -- 394
				if tx + tw < -40 then -- 394
					goto __continue35 -- 396
				end -- 396
				worldArt:tryPlace( -- 398
					"fe_road_stone", -- 398
					"fe04_for_bank_" .. tostring(j), -- 398
					tx + tw * 0.5, -- 398
					groundY - cam:len(14), -- 398
					tw + 0.5, -- 398
					cam:len(14), -- 398
					{ -- 398
						color = Color(162, 184, 204, 255), -- 399
						layer = 2 -- 400
					} -- 400
				) -- 400
			end -- 400
			::__continue35:: -- 400
			j = j + 1 -- 392
		end -- 392
	end -- 392
	local midTrunks = { -- 405
		150, -- 405
		415, -- 405
		650, -- 405
		910, -- 405
		1255 -- 405
	} -- 405
	local i = 0 -- 406
	do -- 406
		i = 0 -- 407
		while i < #midTrunks do -- 407
			do -- 407
				local sx = cam:sx(ox + midTrunks[i + 1]) -- 408
				if sx < -160 or sx > cam.viewW + 160 then -- 408
					goto __continue38 -- 410
				end -- 410
				worldArt:tryPlace( -- 412
					"pine", -- 412
					"fe04_for_pine_" .. tostring(i), -- 412
					sx, -- 412
					groundY - cam:len(4), -- 412
					cam:len(122 + i % 2 * 18), -- 412
					cam:len(196 + i % 2 * 24), -- 412
					{ -- 412
						color = Color(108, 136, 134, 255), -- 413
						opacity = 0.78, -- 414
						facing = i % 2 == 0 and 1 or -1, -- 415
						layer = 0 -- 416
					} -- 416
				) -- 416
			end -- 416
			::__continue38:: -- 416
			i = i + 1 -- 407
		end -- 407
	end -- 407
	do -- 407
		i = 0 -- 421
		while i < #p.room.stairs do -- 421
			local st = p.room.stairs[i + 1] -- 422
			local sx0 = cam:sx(st.x0) -- 423
			local sx1 = cam:sx(st.x1) -- 424
			local sy1 = cam:sy(st.y1) -- 425
			worldArt:tryPlace( -- 426
				i == 1 and "cover_wood" or "cover_stone", -- 426
				"fe04_for_ledge_" .. tostring(i), -- 426
				(sx0 + sx1) * 0.5, -- 426
				groundY, -- 426
				sx1 - sx0, -- 426
				sy1 - groundY, -- 426
				{ -- 426
					color = Color(148, 168, 174, 255), -- 427
					layer = 2 -- 428
				} -- 428
			) -- 428
			worldArt:tryPlace( -- 430
				"slab", -- 430
				"fe04_for_ledge_top_" .. tostring(i), -- 430
				(sx0 + sx1) * 0.5, -- 430
				sy1 - cam:len(4), -- 430
				sx1 - sx0, -- 430
				cam:len(4.5), -- 430
				{ -- 430
					color = Color(172, 192, 202, 255), -- 431
					layer = 2 -- 432
				} -- 432
			) -- 432
			i = i + 1 -- 421
		end -- 421
	end -- 421
	worldArt:tryPlace( -- 438
		"fe_root_arch", -- 438
		"fe04_for_root_arch", -- 438
		cam:sx(ox + 348), -- 438
		groundY, -- 438
		cam:len(134), -- 438
		cam:len(92), -- 438
		{ -- 438
			color = Color(176, 194, 198, 255), -- 439
			layer = 3 -- 440
		} -- 440
	) -- 440
	worldArt:tryPlace( -- 443
		"fe_ground_brick", -- 443
		"fe04_for_canal_a", -- 443
		cam:sx(ox + 720), -- 443
		groundY - cam:len(4), -- 443
		cam:len(62), -- 443
		cam:len(18), -- 443
		{ -- 443
			color = Color(176, 198, 214, 255), -- 444
			layer = 2 -- 445
		} -- 445
	) -- 445
	worldArt:tryPlace( -- 447
		"fe_ground_brick", -- 447
		"fe04_for_canal_b", -- 447
		cam:sx(ox + 780), -- 447
		groundY - cam:len(4), -- 447
		cam:len(62), -- 447
		cam:len(18), -- 447
		{ -- 447
			color = Color(176, 198, 214, 255), -- 448
			facing = -1, -- 449
			layer = 2 -- 450
		} -- 450
	) -- 450
	do -- 450
		i = 0 -- 454
		while i < #p.room.solids do -- 454
			do -- 454
				local s = p.room.solids[i + 1] -- 455
				local sx0 = cam:sx(s.x) -- 456
				local sx1 = cam:sx(s.x + s.w) -- 457
				if sx1 < -40 or sx0 > cam.viewW + 40 then -- 457
					goto __continue43 -- 459
				end -- 459
				if s.passable == true then -- 459
					worldArt:tryPlace( -- 462
						"grass", -- 462
						"fe04_for_grass_bg_" .. tostring(i), -- 462
						(sx0 + sx1) * 0.5, -- 462
						cam:sy(s.y), -- 462
						sx1 - sx0, -- 462
						cam:len(s.h * 1.15), -- 462
						{ -- 462
							color = Color(128, 162, 152, 255), -- 463
							opacity = 0.88, -- 464
							layer = 2 -- 465
						} -- 465
					) -- 465
				elseif s.x >= ox + 1500 then -- 465
					local bw = sx1 - sx0 -- 468
					local bh = cam:len(s.h) -- 469
					local rows = math.max( -- 470
						1, -- 470
						math.min( -- 470
							8, -- 470
							math.floor(s.h / 36 + 0.5) -- 470
						) -- 470
					) -- 470
					local rowH = bh / rows -- 471
					local r = 0 -- 472
					do -- 472
						r = 0 -- 473
						while r < rows do -- 473
							worldArt:tryPlace( -- 474
								"wall", -- 474
								(("fe04_for_bound_" .. tostring(i)) .. "_") .. tostring(r), -- 474
								(sx0 + sx1) * 0.5, -- 474
								cam:sy(s.y) + r * rowH, -- 474
								bw + 0.5, -- 474
								rowH + 0.5, -- 474
								{ -- 474
									color = Color(128, 146, 162, 255), -- 475
									facing = r % 2 == 0 and 1 or -1, -- 476
									layer = 2 -- 477
								} -- 477
							) -- 477
							r = r + 1 -- 473
						end -- 473
					end -- 473
				end -- 473
			end -- 473
			::__continue43:: -- 473
			i = i + 1 -- 454
		end -- 454
	end -- 454
	do -- 454
		i = 0 -- 484
		while i < #TWIG_OFFSETS do -- 484
			local tx = cam:sx(ox + TWIG_OFFSETS[i + 1]) -- 485
			worldArt:tryPlace( -- 486
				"stone_chips", -- 486
				"fe04_for_twig_" .. tostring(i), -- 486
				tx, -- 486
				groundY + cam:len(4), -- 486
				cam:len(22), -- 486
				cam:len(12), -- 486
				{ -- 486
					color = Color(188, 154, 114, 255), -- 487
					layer = 3 -- 488
				} -- 488
			) -- 488
			i = i + 1 -- 484
		end -- 484
	end -- 484
	fgDraw:drawEllipse( -- 493
		Vec2( -- 493
			cam:sx(p.player.x), -- 493
			cam:sy(p.player.y) + 1 -- 493
		), -- 493
		cam:len(14), -- 493
		3.4, -- 493
		Color(8, 12, 14, 155) -- 493
	) -- 493
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 493
		fgDraw:drawEllipse( -- 495
			Vec2( -- 495
				cam:sx(p.dogX), -- 495
				groundY + 1 -- 495
			), -- 495
			cam:len(18), -- 495
			3.8, -- 495
			Color(8, 12, 14, 165) -- 495
		) -- 495
	end -- 495
	self:drawCreekWaterReflection( -- 499
		fgDraw, -- 499
		fgGlow, -- 499
		worldArt, -- 499
		p, -- 499
		cam -- 499
	) -- 499
	do -- 499
		i = 0 -- 502
		while i < #self.splinters do -- 502
			local sp = self.splinters[i + 1] -- 503
			local a = clamp01(sp.life / sp.maxLife) -- 504
			local sx = cam:sx(sp.x) -- 505
			local sy = cam:sy(sp.y) -- 506
			fgDraw:drawSegment( -- 507
				Vec2(sx - sp.len, sy - 1), -- 507
				Vec2(sx + sp.len, sy + 2), -- 507
				1.3, -- 507
				Color( -- 507
					204, -- 507
					182, -- 507
					146, -- 507
					math.floor(235 * a + 0.5) -- 507
				) -- 507
			) -- 507
			i = i + 1 -- 502
		end -- 502
	end -- 502
	return true -- 510
end -- 358
function ForestCreekScene.prototype.drawCreekWaterReflection(self, _fgDraw, fgGlow, worldArt, p, cam) -- 513
	local ox = p.ox -- 520
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 520
		return -- 522
	end -- 522
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 524
	local reflCenterX = ox + 1438 -- 525
	local groundY = cam:sy(0) -- 526
	local frameA = math.floor(self.ripplePhase * 2.2) % 3 -- 529
	local frameB = (frameA + 1) % 3 -- 530
	local driftA = math.sin(self.ripplePhase * 1.15) * cam:len(8) -- 531
	local driftB = math.cos(self.ripplePhase * 1.45) * cam:len(6) -- 532
	local rx = cam:sx(reflCenterX) -- 533
	worldArt:tryPlace( -- 535
		"fe_vfx_creek_reflect", -- 535
		"fe04_creek_refl_near", -- 535
		rx + driftA, -- 535
		groundY - cam:len(18), -- 535
		cam:len(96), -- 535
		cam:len(24), -- 535
		{frame = frameA, opacity = 0.88 * lampPulse, layer = 3} -- 535
	) -- 535
	worldArt:tryPlace( -- 540
		"fe_vfx_creek_reflect", -- 540
		"fe04_creek_refl_far", -- 540
		rx + cam:len(22) + driftB, -- 540
		groundY - cam:len(34), -- 540
		cam:len(78), -- 540
		cam:len(18), -- 540
		{frame = frameB, opacity = 0.72 * lampPulse, facing = -1, layer = 3} -- 540
	) -- 540
	fillRadialGlow( -- 547
		fgGlow, -- 548
		rx + cam:len(8), -- 549
		groundY - cam:len(22), -- 550
		cam:len(62) * lampPulse, -- 551
		cam:len(22) * lampPulse, -- 552
		Color( -- 553
			246, -- 553
			206, -- 553
			128, -- 553
			math.floor(92 * lampPulse + 0.5) -- 553
		), -- 553
		Color(232, 174, 88, 0), -- 554
		16 -- 555
	) -- 555
end -- 513
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 560
	return true -- 566
end -- 560
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 570
	local p = ctx.p -- 576
	local cam = ctx.cam -- 577
	local px = cam:sx(p.player.x) -- 579
	local pTopY = cam:sy(p.player.y + p.player.h) -- 580
	if self.xiaomanListenTimer > 0 then -- 580
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 584
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 585
		local earY = pTopY - cam:len(10) -- 586
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 587
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 588
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 589
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 590
		fgDraw:drawArc( -- 591
			Vec2(earX, earY), -- 591
			r1, -- 591
			startAng, -- 591
			endAng, -- 591
			1.3, -- 591
			Color( -- 591
				224, -- 591
				218, -- 591
				198, -- 591
				math.floor(185 * k + 0.5) -- 591
			) -- 591
		) -- 591
		fgGlow:drawArc( -- 592
			Vec2(earX, earY), -- 592
			r2, -- 592
			startAng, -- 592
			endAng, -- 592
			1.1, -- 592
			Color( -- 592
				204, -- 592
				218, -- 592
				224, -- 592
				math.floor(135 * k + 0.5) -- 592
			) -- 592
		) -- 592
	end -- 592
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 592
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 597
		if alert then -- 597
			local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 599
			local headX = cam:sx(p.dogX + f * 11) -- 600
			local headY = cam:sy(29) -- 601
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 602
			fgGlow:drawArc( -- 603
				Vec2(headX, headY), -- 603
				waveR, -- 603
				42, -- 603
				138, -- 603
				1.2, -- 603
				Color(226, 208, 174, 155) -- 603
			) -- 603
		end -- 603
	end -- 603
	if ctx.paused then -- 603
		local pX = cam.viewW * (0.98 + self.creekReveal * 0.24) -- 609
		worldArt:tryPlace( -- 610
			"fe_fg_pine_bough", -- 610
			"fe04_pause_creek_branch", -- 610
			pX, -- 610
			cam.viewH, -- 610
			cam.viewW * 0.56, -- 610
			cam.viewH * 0.48, -- 610
			{opacity = 0.9 * (1 - self.creekReveal * 0.65), layer = 5300} -- 610
		) -- 610
	end -- 610
end -- 570
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 621
	local p = ctx.p -- 628
	local cam = ctx.cam -- 629
	local ox = p.ox -- 630
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 631
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 632
	local i = 0 -- 635
	do -- 635
		i = 0 -- 636
		while i < #p.room.solids do -- 636
			do -- 636
				local s = p.room.solids[i + 1] -- 637
				if s.passable ~= true then -- 637
					goto __continue64 -- 639
				end -- 639
				local sx0 = cam:sx(s.x) * inv -- 641
				local sx1 = cam:sx(s.x + s.w) * inv -- 642
				if sx1 < -20 or sx0 > ctx.uiW + 20 then -- 642
					goto __continue64 -- 644
				end -- 644
				local sy = cam:sy(s.y - 2) * inv -- 646
				uiArt:tryPlace( -- 647
					"grass_low", -- 647
					"fe04_fg_grass_" .. tostring(i), -- 647
					(sx0 + sx1) * 0.5, -- 647
					sy, -- 647
					sx1 - sx0 + 8, -- 647
					math.max( -- 647
						10, -- 647
						cam:len(17) * inv -- 647
					), -- 647
					{ -- 647
						color = Color(76, 108, 98, 255), -- 648
						opacity = 0.92, -- 649
						layer = 2 -- 650
					} -- 650
				) -- 650
			end -- 650
			::__continue64:: -- 650
			i = i + 1 -- 636
		end -- 636
	end -- 636
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 655
	if nearCreek > 0.02 then -- 655
		local uiW = ctx.uiW -- 657
		local uiH = ctx.uiH -- 658
		local partShift = self.creekReveal * uiW * 0.4 -- 659
		local liftShift = self.creekReveal * uiH * 0.16 -- 660
		local sway = math.sin(self.animTime * 1.45) * 5 -- 661
		local canopyOp = nearCreek * (1 - self.creekReveal * 0.28) -- 662
		uiArt:tryPlace( -- 665
			"fe_fg_pine_bough", -- 665
			"fe04_fg_creek_r1", -- 665
			uiW + 18 + partShift + sway * 0.5, -- 665
			uiH + 14 + liftShift, -- 665
			uiW * 0.58, -- 665
			uiH * 0.44, -- 665
			{opacity = 0.96 * canopyOp, layer = 4} -- 665
		) -- 665
		uiArt:tryPlace( -- 669
			"fe_fg_pine_bough", -- 669
			"fe04_fg_creek_r2", -- 669
			uiW * 0.86 + partShift + sway * 0.8, -- 669
			uiH + 18 + liftShift * 0.8, -- 669
			uiW * 0.44, -- 669
			uiH * 0.36, -- 669
			{ -- 669
				color = Color(196, 212, 208, 255), -- 670
				opacity = 0.88 * canopyOp, -- 671
				layer = 3 -- 672
			} -- 672
		) -- 672
		local lShift = self.creekReveal * uiW * 0.24 -- 675
		uiArt:tryPlace( -- 676
			"fe_fg_pine_bough", -- 676
			"fe04_fg_creek_l", -- 676
			-14 - lShift - sway * 0.4, -- 676
			uiH + 12 + liftShift * 0.5, -- 676
			uiW * 0.36, -- 676
			uiH * 0.32, -- 676
			{facing = -1, opacity = 0.9 * canopyOp, layer = 4} -- 676
		) -- 676
	end -- 676
	drawChildColdMoonGrade( -- 684
		uiDraw, -- 684
		uiGlow, -- 684
		ctx.uiW, -- 684
		ctx.uiH, -- 684
		0.78 * (1 - dawn * 0.24), -- 684
		dawn * 0.55 -- 684
	) -- 684
	return false -- 686
end -- 621
return ____exports -- 621