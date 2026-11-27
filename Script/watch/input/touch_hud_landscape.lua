-- [ts]: touch_hud_landscape.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local BlendFunc = ____Dora.BlendFunc -- 13
local Color = ____Dora.Color -- 13
local DrawNode = ____Dora.DrawNode -- 13
local Node = ____Dora.Node -- 13
local Rect = ____Dora.Rect -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____run = require("Script.watch.run") -- 15
local talentNames = ____run.talentNames -- 15
local ____aim_assist = require("Script.watch.input.aim_assist") -- 16
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 16
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 16
local ____touch_interact_meta = require("Script.watch.input.touch_interact_meta") -- 24
local deriveInteractActionMeta = ____touch_interact_meta.deriveInteractActionMeta -- 24
local ____adapter = require("Script.watch.fe.adapter") -- 26
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 26
local ____assets = require("Script.watch.fe.assets") -- 27
local AssetSlotHost = ____assets.AssetSlotHost -- 27
local ____textpool = require("Script.watch.fe.ui.textpool") -- 29
local TextPool = ____textpool.TextPool -- 29
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 31
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 31
local ____theme = require("Script.watch.fe.theme") -- 33
local PALETTE = ____theme.PALETTE -- 34
local drawBlossomDot = ____theme.drawBlossomDot -- 36
local drawDiamond = ____theme.drawDiamond -- 37
local drawHairline = ____theme.drawHairline -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 39
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local toColor = ____theme.toColor -- 41
local visualTextWidth = ____theme.visualTextWidth -- 42
local TWO_PI = math.pi * 2 -- 45
local HALF_PI = math.pi * 0.5 -- 46
local STICK_BASE_R_LANDSCAPE = 64 -- 47
local function accentPalette(accent) -- 70
	if accent == "cyan" then -- 71
		return PALETTE.cyan -- 71
	end -- 71
	if accent == "amber" then -- 72
		return PALETTE.amber -- 72
	end -- 72
	if accent == "rouge" then -- 73
		return PALETTE.rouge -- 73
	end -- 73
	if accent == "emerald" then -- 74
		return PALETTE.emerald -- 74
	end -- 74
	return PALETTE.silkLine -- 75
end -- 70
local function accentCore(accent) -- 78
	if accent == "cyan" then -- 79
		return PALETTE.cyanCore -- 79
	end -- 79
	if accent == "amber" then -- 80
		return PALETTE.amberCore -- 80
	end -- 80
	if accent == "rouge" then -- 81
		return PALETTE.crimsonCore -- 81
	end -- 81
	if accent == "emerald" then -- 82
		return PALETTE.emerald -- 82
	end -- 82
	return PALETTE.textBright -- 83
end -- 78
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 86
	if segments == nil then -- 95
		segments = 28 -- 95
	end -- 95
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 97
		return -- 97
	end -- 97
	local n = math.max( -- 98
		4, -- 98
		math.ceil(segments * math.min( -- 98
			1, -- 98
			math.abs(sweepRad) / TWO_PI -- 98
		)) -- 98
	) -- 98
	local prevX = cx + math.cos(startRad) * r -- 99
	local prevY = cy + math.sin(startRad) * r -- 100
	local i = 1 -- 101
	do -- 101
		i = 1 -- 102
		while i <= n do -- 102
			local a = startRad + sweepRad * i / n -- 103
			local nx = cx + math.cos(a) * r -- 104
			local ny = cy + math.sin(a) * r -- 105
			draw:drawSegment( -- 106
				Vec2(prevX, prevY), -- 106
				Vec2(nx, ny), -- 106
				thickness, -- 106
				color -- 106
			) -- 106
			prevX = nx -- 107
			prevY = ny -- 108
			i = i + 1 -- 102
		end -- 102
	end -- 102
end -- 86
local function fillCirclePoly(draw, cx, cy, r, fill, borderWidth, borderColor, segments) -- 112
	if borderWidth == nil then -- 118
		borderWidth = 0 -- 118
	end -- 118
	if segments == nil then -- 120
		segments = 26 -- 120
	end -- 120
	local pts = {} -- 122
	local i = 0 -- 123
	do -- 123
		i = 0 -- 124
		while i < segments do -- 124
			local a = TWO_PI * i / segments -- 125
			pts[#pts + 1] = Vec2( -- 126
				cx + math.cos(a) * r, -- 126
				cy + math.sin(a) * r -- 126
			) -- 126
			i = i + 1 -- 124
		end -- 124
	end -- 124
	if borderWidth > 0 and borderColor ~= nil then -- 128
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 129
	else -- 129
		draw:drawPolygon(pts, fill) -- 131
	end -- 131
end -- 112
local function isNearLowLedgeForButton(p) -- 135
	if p.childMode then -- 136
		return false -- 136
	end -- 136
	local a = p.player -- 137
	local probeX = a.x + a.facing * 26 -- 138
	local i = 0 -- 139
	do -- 139
		i = 0 -- 140
		while i < #p.boxes do -- 140
			do -- 140
				local b = p.boxes[i + 1] -- 141
				if b.broken == true or b.hidden == true then -- 142
					goto __continue24 -- 142
				end -- 142
				local h = b.y1 - b.y0 -- 143
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 144
					return true -- 146
				end -- 146
			end -- 146
			::__continue24:: -- 146
			i = i + 1 -- 140
		end -- 140
	end -- 140
	return false -- 149
end -- 135
local function isInLowArch(p) -- 152
	local arch = p.room.arch -- 153
	if arch.h <= 0 then -- 154
		return false -- 154
	end -- 154
	return p.player.x >= arch.x0 - 10 and p.player.x <= arch.x1 + 10 and p.player.y <= arch.y + arch.h -- 155
end -- 152
____exports.TouchControls = __TS__Class() -- 158
local TouchControls = ____exports.TouchControls -- 158
TouchControls.name = "TouchControls" -- 158
function TouchControls.prototype.____constructor(self, parent, portraitDelegate) -- 176
	self.lastMode = 1 -- 169
	self.lastScreen = "title" -- 170
	self.time = 0 -- 173
	self.hasDrawn = false -- 174
	self.portraitDelegate = portraitDelegate -- 177
	self.overlayRoot = Node() -- 179
	self.overlayRoot.order = 60 -- 180
	self.overlayRoot:addTo(parent) -- 181
	if portraitDelegate ~= nil then -- 183
		local deck = DrawNode() -- 184
		deck.order = 0 -- 185
		deck:addTo(self.overlayRoot) -- 186
		self.deckDraw = deck -- 187
	end -- 187
	self.padDraw = DrawNode() -- 190
	self.padDraw.order = 2 -- 191
	self.padDraw:addTo(self.overlayRoot) -- 192
	self.padArt = __TS__New(AssetSlotHost, self.overlayRoot, 3) -- 194
	self.padInkDraw = DrawNode() -- 196
	self.padInkDraw.order = 5 -- 197
	self.padInkDraw:addTo(self.overlayRoot) -- 198
	local additive = BlendFunc("SrcAlpha", "One") -- 200
	self.padGlow = DrawNode() -- 201
	self.padGlow.order = 7 -- 202
	self.padGlow.blendFunc = additive -- 203
	self.padGlow:addTo(self.overlayRoot) -- 204
	self.texts = __TS__New(TextPool, self.overlayRoot, 10, {xs = 24, sm = 12}) -- 207
end -- 176
function TouchControls.prototype.getAllocatedLabelCount(self) -- 210
	return self.texts.totalAllocated -- 211
end -- 210
function TouchControls.prototype.getLayoutSummary(self, router) -- 214
	local buttonIds = {} -- 224
	local zoneIds = {} -- 225
	if self.lastContext ~= nil then -- 226
		local i = 0 -- 227
		do -- 227
			i = 0 -- 228
			while i < #self.lastContext.buttons do -- 228
				buttonIds[#buttonIds + 1] = self.lastContext.buttons[i + 1].id -- 229
				i = i + 1 -- 228
			end -- 228
		end -- 228
		do -- 228
			i = 0 -- 231
			while i < #self.lastContext.rectZones do -- 231
				zoneIds[#zoneIds + 1] = self.lastContext.rectZones[i + 1].id -- 232
				i = i + 1 -- 231
			end -- 231
		end -- 231
	end -- 231
	local ____buttonIds_6 = buttonIds -- 236
	local ____zoneIds_7 = zoneIds -- 237
	local ____temp_0 -- 238
	if self.lastContext ~= nil then -- 238
		____temp_0 = self.lastContext.viewport.isPortrait -- 238
	else -- 238
		____temp_0 = false -- 238
	end -- 238
	local ____temp_1 -- 239
	if self.lastContext ~= nil then -- 239
		____temp_1 = self.lastContext.overlayActive -- 239
	else -- 239
		____temp_1 = false -- 239
	end -- 239
	local ____temp_2 -- 240
	if router ~= nil then -- 240
		____temp_2 = router.crouchToggled -- 240
	else -- 240
		____temp_2 = false -- 240
	end -- 240
	local ____temp_3 -- 241
	if router ~= nil then -- 241
		____temp_3 = router.slowToggled -- 241
	else -- 241
		____temp_3 = false -- 241
	end -- 241
	local ____temp_4 -- 242
	if router ~= nil then -- 242
		____temp_4 = router.coverToggled -- 242
	else -- 242
		____temp_4 = false -- 242
	end -- 242
	local ____temp_5 -- 243
	if router ~= nil then -- 243
		____temp_5 = router.cartGripLatched -- 243
	else -- 243
		____temp_5 = false -- 243
	end -- 243
	return { -- 235
		buttonIds = ____buttonIds_6, -- 236
		zoneIds = ____zoneIds_7, -- 237
		isPortrait = ____temp_0, -- 238
		overlayActive = ____temp_1, -- 239
		crouchToggled = ____temp_2, -- 240
		slowToggled = ____temp_3, -- 241
		coverToggled = ____temp_4, -- 242
		cartGripLatch = ____temp_5 -- 243
	} -- 243
end -- 214
function TouchControls.prototype.syncContext(self, params) -- 247
	self.time = self.time + math.min( -- 248
		0.05, -- 248
		math.max(0, params.dt) -- 248
	) -- 248
	self.lastMode = params.mode -- 249
	self.lastScreen = params.screen -- 250
	self.lastPlay = params.play -- 251
	self.lastRun = params.run -- 252
	local vp = params.viewport -- 254
	local p = params.play -- 255
	local router = params.router -- 256
	local pDel = self.portraitDelegate -- 257
	local isPortrait = pDel ~= nil and vp.isPortrait -- 258
	local overlayScale = isPortrait and 1 or vp.uiScale -- 259
	local ovW = vp.fullW / math.max(0.25, overlayScale) -- 260
	local ovH = vp.fullH / math.max(0.25, overlayScale) -- 261
	local safeL = vp.safe.left / math.max(0.25, overlayScale) -- 262
	local safeR = vp.safe.right / math.max(0.25, overlayScale) -- 263
	local safeT = vp.safe.top / math.max(0.25, overlayScale) -- 264
	local safeB = vp.safe.bottom / math.max(0.25, overlayScale) -- 265
	local overlayActive = params.overlayActive -- 267
	local sc = router.settings.touchScale -- 268
	local isPlayMode = params.mode == 1 and params.screen == "play" and p ~= nil -- 270
	local isTrialMode = params.mode == 2 and p ~= nil -- 271
	local gameplayActive = isPlayMode or isTrialMode -- 272
	local ____opt_8 = params.run -- 274
	local trial = ____opt_8 and ____opt_8.trial -- 274
	local ____temp_13 = isTrialMode and trial ~= nil -- 275
	if ____temp_13 then -- 275
		local ____trial_lost_12 = trial.lost -- 275
		if not ____trial_lost_12 then -- 275
			local ____opt_10 = params.run -- 275
			____trial_lost_12 = (____opt_10 and ____opt_10.finished) == true -- 275
		end -- 275
		____temp_13 = ____trial_lost_12 -- 275
	end -- 275
	local trialEnded = ____temp_13 -- 275
	local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 276
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) -- 278
	local ____temp_14 -- 280
	if isPlayMode and p ~= nil then -- 280
		____temp_14 = isCutsceneBlockingPlay(p) -- 281
	else -- 281
		____temp_14 = isTrialMode and p ~= nil and (p.paused or trialEnded or trialHasOffers) -- 282
	end -- 282
	local cutsceneBlocking = ____temp_14 -- 280
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 284
	local cart = p ~= nil and p.room.cart or nil -- 286
	local cartNearby = p ~= nil and cart ~= nil and not p.cartDocked and cart.bodyW > 0 and (p.gripping or p:cartHandleInReach()) -- 287
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed -- 289
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 290
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not cutsceneBlocking and not modal and p.escort.state ~= "calming" -- 291
	local buttons = {} -- 294
	local rectZones = {} -- 295
	local pGeom = isPortrait and pDel ~= nil and pDel:computeStickGeom( -- 297
		vp, -- 298
		ovW, -- 298
		safeL, -- 298
		safeB, -- 298
		sc -- 298
	) or nil -- 299
	local stickMaxR = pGeom ~= nil and pGeom.stickMaxR or STICK_BASE_R_LANDSCAPE * sc -- 300
	local stickDefaultX = pGeom ~= nil and pGeom.stickDefaultX or safeL + 126 * sc -- 301
	local stickDefaultY = pGeom ~= nil and pGeom.stickDefaultY or safeB + 126 * sc -- 302
	local stickZoneMaxX = pGeom ~= nil and pGeom.stickZoneMaxX or ovW * 0.46 -- 303
	local stickZoneMaxY = pGeom ~= nil and pGeom.stickZoneMaxY or ovH - 110 -- 304
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 306
	if overlayActive then -- 309
		if isPortrait and pDel ~= nil then -- 310
			pDel:pushTopButtons( -- 311
				buttons, -- 312
				vp, -- 312
				ovW, -- 312
				ovH, -- 312
				safeR, -- 312
				gameplayActive, -- 312
				p, -- 312
				params.isMuted, -- 313
				params.isFullscreen, -- 313
				params.canToggleFullscreen -- 313
			) -- 313
		elseif isPlayMode and not modal then -- 315
			local px = ovW - safeR - 112 -- 316
			local py = ovH - safeT - 66 -- 317
			buttons[#buttons + 1] = { -- 318
				id = "pause", -- 319
				x = px + 46, -- 320
				y = py + 21, -- 321
				r = 28, -- 322
				shape = "pill", -- 323
				rect = Rect(px, py, 94, 42), -- 324
				label = "暂歇", -- 325
				accent = "silk", -- 326
				active = false, -- 327
				highlighted = false, -- 328
				progress = 0, -- 329
				dimmed = false -- 330
			} -- 330
			if params.showWebTopPills then -- 332
				local mw = 58 -- 333
				local mx = px - mw - 10 -- 334
				buttons[#buttons + 1] = { -- 335
					id = "mute", -- 336
					x = mx + mw * 0.5, -- 337
					y = py + 21, -- 338
					r = 22, -- 339
					shape = "pill", -- 340
					rect = Rect(mx, py + 4, mw, 34), -- 341
					label = params.isMuted and "静音" or "有声", -- 342
					accent = params.isMuted and "rouge" or "cyan", -- 343
					active = params.isMuted, -- 344
					highlighted = false, -- 345
					progress = 0, -- 346
					dimmed = false -- 347
				} -- 347
				if params.canToggleFullscreen then -- 349
					local fw = 58 -- 350
					local fx = mx - fw - 8 -- 351
					buttons[#buttons + 1] = { -- 352
						id = "fullscreen", -- 353
						x = fx + fw * 0.5, -- 354
						y = py + 21, -- 355
						r = 22, -- 356
						shape = "pill", -- 357
						rect = Rect(fx, py + 4, fw, 34), -- 358
						label = params.isFullscreen and "窗口" or "全屏", -- 359
						accent = "silk", -- 360
						active = params.isFullscreen, -- 361
						highlighted = false, -- 362
						progress = 0, -- 363
						dimmed = false -- 364
					} -- 364
				end -- 364
			end -- 364
		end -- 364
	end -- 364
	if isPortrait and pDel ~= nil and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 372
		pDel:pushMenuNavButtons( -- 374
			buttons, -- 374
			vp, -- 374
			ovW, -- 374
			safeL, -- 374
			safeR, -- 374
			safeB -- 374
		) -- 374
	end -- 374
	local prompt -- 378
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 379
		if #params.storyTalentBoxes > 0 then -- 380
			local ti = 0 -- 381
			do -- 381
				ti = 0 -- 382
				while ti < #params.storyTalentBoxes do -- 382
					local b = params.storyTalentBoxes[ti + 1] -- 383
					local vx = vp.stageX + b.x * vp.uiScale -- 384
					local vy = vp.stageY + b.y * vp.uiScale -- 385
					local vw = b.width * vp.uiScale -- 386
					local vh = b.height * vp.uiScale -- 387
					rectZones[#rectZones + 1] = { -- 388
						id = "talent:" .. tostring(ti), -- 389
						rect = Rect((vx - 4) / overlayScale, (vy - 6) / overlayScale, (vw + 8) / overlayScale, (vh + 12) / overlayScale) -- 390
					} -- 390
					ti = ti + 1 -- 382
				end -- 382
			end -- 382
		end -- 382
		prompt = deriveWorldPrompt(p) -- 400
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 401
			local keyW = math.max( -- 403
				24, -- 403
				visualTextWidth(prompt.keyTag, 15) + 16 -- 403
			) -- 403
			local labelW = visualTextWidth(prompt.label, 15) -- 404
			local pillW = keyW + labelW + 24 -- 405
			local padX = math.max(115, pillW * 0.5 + 24) -- 406
			local sxUi = math.max( -- 407
				padX + vp.safeUi.left, -- 407
				math.min( -- 407
					vp.uiW - padX - vp.safeUi.right, -- 407
					params.cam:sx(prompt.x) / vp.uiScale -- 407
				) -- 407
			) -- 407
			local syUi = math.max( -- 408
				96 + vp.safeUi.bottom, -- 408
				math.min( -- 408
					vp.uiH - 110 - vp.safeUi.top, -- 408
					params.cam:sy(prompt.y) / vp.uiScale -- 408
				) -- 408
			) -- 408
			local vx = vp.stageX + (sxUi - pillW * 0.5 - 12) * vp.uiScale -- 409
			local vy = vp.stageY + (syUi - 22) * vp.uiScale -- 410
			rectZones[#rectZones + 1] = { -- 411
				id = "worldPrompt", -- 412
				rect = Rect(vx / overlayScale, vy / overlayScale, (pillW + 24) * vp.uiScale / overlayScale, 44 * vp.uiScale / overlayScale) -- 413
			} -- 413
		end -- 413
	end -- 413
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 423
		local cx = ovW * 0.5 -- 425
		local cy = safeB + 46 -- 426
		buttons[#buttons + 1] = { -- 427
			id = "nav_confirm", -- 428
			x = cx, -- 429
			y = cy, -- 430
			r = 26, -- 431
			shape = "pill", -- 432
			rect = Rect(cx - 88, cy - 22, 176, 44), -- 433
			label = "继续 · 归程", -- 434
			accent = "amber", -- 435
			active = false, -- 436
			highlighted = true, -- 437
			progress = 0, -- 438
			dimmed = false -- 439
		} -- 439
	end -- 439
	if isTrialMode and p ~= nil and overlayActive then -- 443
		if p.paused or trialEnded then -- 444
			local cx = ovW * 0.5 -- 445
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 446
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 447
			local bh = isPortrait and 44 or 50 -- 448
			local step = bh + 14 -- 449
			if p.paused and not trialEnded then -- 450
				rectZones[#rectZones + 1] = { -- 451
					id = "trial:resume", -- 451
					rect = Rect(cx - bw * 0.5, cy + step * 0.8, bw, bh) -- 451
				} -- 451
			end -- 451
			rectZones[#rectZones + 1] = { -- 453
				id = "trial:retry", -- 453
				rect = Rect(cx - bw * 0.5, cy - bh * 0.2, bw, bh) -- 453
			} -- 453
			rectZones[#rectZones + 1] = { -- 454
				id = "trial:title", -- 454
				rect = Rect(cx - bw * 0.5, cy - step * 1.2, bw, bh) -- 454
			} -- 454
		elseif trialHasOffers and trial ~= nil then -- 455
			local count = #trial.offers -- 456
			local cardW = isPortrait and math.min( -- 457
				114, -- 457
				math.floor((ovW - 44) / math.max(1, count) - 10) -- 457
			) or 216 -- 457
			local cardH = isPortrait and 52 or 62 -- 458
			local gap = isPortrait and 10 or 18 -- 459
			local totalW = count * cardW + (count - 1) * gap -- 460
			local startX = (ovW - totalW) * 0.5 -- 461
			local y = (isPortrait and vp.deckH * 0.52 or ovH * 0.48) - cardH * 0.5 -- 462
			local i = 0 -- 463
			do -- 463
				i = 0 -- 464
				while i < count do -- 464
					rectZones[#rectZones + 1] = { -- 465
						id = "talent:" .. tostring(i), -- 466
						rect = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 467
					} -- 467
					i = i + 1 -- 464
				end -- 464
			end -- 464
			if not isPortrait then -- 470
				rectZones[#rectZones + 1] = { -- 471
					id = "pause", -- 471
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 471
				} -- 471
			end -- 471
		elseif not isPortrait then -- 473
			rectZones[#rectZones + 1] = { -- 474
				id = "pause", -- 474
				rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 474
			} -- 474
			rectZones[#rectZones + 1] = { -- 475
				id = "retry", -- 475
				rect = Rect(ovW - safeR - 210, ovH - safeT - 64, 92, 46) -- 475
			} -- 475
		end -- 475
	end -- 475
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 480
		local interactMeta = deriveInteractActionMeta( -- 481
			p, -- 481
			prompt or deriveWorldPrompt(p), -- 481
			cartNearby, -- 481
			router.cartGripLatched -- 481
		) -- 481
		local nearLedge = isNearLowLedgeForButton(p) -- 482
		if isPortrait and pDel ~= nil and pGeom ~= nil then -- 484
			bottleCancelCenter = pDel:pushActionButtons( -- 485
				buttons, -- 486
				vp, -- 486
				ovW, -- 486
				safeR, -- 486
				safeB, -- 486
				pGeom, -- 486
				sc, -- 486
				p, -- 487
				isPlayMode, -- 487
				canBottleAim, -- 487
				nearLedge, -- 487
				interactMeta, -- 487
				router -- 487
			) -- 487
		else -- 487
			local rightX = ovW - safeR - 92 * sc -- 490
			local bottomY = safeB + 110 * sc -- 491
			bottleCancelCenter = {x = rightX - 186 * sc, y = bottomY + 126 * sc, r = 42 * sc} -- 492
			if not p.childMode then -- 494
				buttons[#buttons + 1] = { -- 495
					id = "fire", -- 496
					x = rightX, -- 497
					y = bottomY + 12 * sc, -- 498
					r = 45 * sc, -- 499
					label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 500
					subLabel = "拖瞄", -- 501
					accent = "rouge", -- 502
					active = router:isButtonHeld("fire"), -- 503
					highlighted = p.reloadPendingEffect ~= "", -- 504
					progress = 0, -- 505
					dimmed = p.gripping -- 506
				} -- 506
				buttons[#buttons + 1] = { -- 508
					id = "jump", -- 509
					x = rightX - 116 * sc, -- 510
					y = bottomY - 8 * sc, -- 511
					r = 34 * sc, -- 512
					label = nearLedge and "翻越" or "翻滚", -- 513
					accent = "cyan", -- 514
					active = router:isButtonHeld("jump"), -- 515
					highlighted = nearLedge, -- 516
					progress = 0, -- 517
					dimmed = p.gripping -- 518
				} -- 518
				buttons[#buttons + 1] = { -- 520
					id = "cover", -- 521
					x = rightX - 120 * sc, -- 522
					y = bottomY + 94 * sc, -- 523
					r = 32 * sc, -- 524
					label = router.coverToggled and "离掩" or "掩体", -- 525
					accent = "cyan", -- 526
					active = router.coverToggled, -- 527
					highlighted = p.coverNear and not router.coverToggled, -- 528
					progress = 0, -- 529
					dimmed = not p.coverNear and not router.coverToggled -- 530
				} -- 530
				buttons[#buttons + 1] = { -- 532
					id = "interact", -- 533
					x = rightX - 10 * sc, -- 534
					y = bottomY + 122 * sc, -- 535
					r = 36 * sc, -- 536
					label = interactMeta.label, -- 537
					subLabel = interactMeta.subLabel, -- 538
					accent = interactMeta.urgent and "rouge" or "amber", -- 539
					active = router:isButtonHeld("interact"), -- 540
					highlighted = interactMeta.available, -- 541
					progress = interactMeta.progress, -- 542
					dimmed = not interactMeta.available -- 543
				} -- 543
				if isPlayMode and p.archive.artifactOwned then -- 545
					local eq = p.equippedWeapon == "time_shuttler" -- 546
					buttons[#buttons + 1] = { -- 547
						id = "artifact", -- 548
						x = rightX - 112 * sc, -- 549
						y = bottomY + 184 * sc, -- 550
						r = 27 * sc, -- 551
						label = eq and "收器" or "穿梭", -- 552
						accent = "amber", -- 553
						active = eq, -- 554
						highlighted = eq, -- 555
						progress = 0, -- 556
						dimmed = false -- 557
					} -- 557
				end -- 557
			else -- 557
				buttons[#buttons + 1] = { -- 561
					id = "jump", -- 562
					x = rightX, -- 563
					y = bottomY + 12 * sc, -- 564
					r = 38 * sc, -- 565
					label = "跳跃", -- 566
					accent = "amber", -- 567
					active = router:isButtonHeld("jump"), -- 568
					highlighted = false, -- 569
					progress = 0, -- 570
					dimmed = p.gripping -- 571
				} -- 571
				buttons[#buttons + 1] = { -- 573
					id = "crouch", -- 574
					x = rightX - 106 * sc, -- 575
					y = bottomY - 6 * sc, -- 576
					r = 34 * sc, -- 577
					label = router.crouchToggled and "起身" or "蹲伏", -- 578
					accent = "emerald", -- 579
					active = router.crouchToggled or p.player.crouch, -- 580
					highlighted = p.scavChase and not p.player.crouch, -- 581
					progress = 0, -- 582
					dimmed = false -- 583
				} -- 583
				buttons[#buttons + 1] = { -- 585
					id = "cover", -- 586
					x = rightX - 196 * sc, -- 587
					y = bottomY - 16 * sc, -- 588
					r = 29 * sc, -- 589
					label = router.slowToggled and "常步" or "轻步", -- 590
					accent = "silk", -- 591
					active = router.slowToggled, -- 592
					highlighted = false, -- 593
					progress = 0, -- 594
					dimmed = false -- 595
				} -- 595
				buttons[#buttons + 1] = { -- 597
					id = "interact", -- 598
					x = rightX - 12 * sc, -- 599
					y = bottomY + 114 * sc, -- 600
					r = 36 * sc, -- 601
					label = interactMeta.label, -- 602
					subLabel = interactMeta.subLabel, -- 603
					accent = interactMeta.urgent and "rouge" or "amber", -- 604
					active = router:isButtonHeld("interact"), -- 605
					highlighted = interactMeta.available, -- 606
					progress = interactMeta.progress, -- 607
					dimmed = not interactMeta.available -- 608
				} -- 608
				if canBottleAim then -- 610
					buttons[#buttons + 1] = { -- 611
						id = "bottle", -- 612
						x = rightX - 114 * sc, -- 613
						y = bottomY + 98 * sc, -- 614
						r = 38 * sc, -- 615
						label = "投瓶", -- 616
						subLabel = "拖瞄", -- 617
						accent = "amber", -- 618
						active = router:isButtonHeld("bottle"), -- 619
						highlighted = true, -- 620
						progress = math.min(1, p.aimHold / 0.12), -- 621
						dimmed = false -- 622
					} -- 622
				end -- 622
			end -- 622
		end -- 622
	end -- 622
	local enemyTargets -- 630
	if params.enemyTargets ~= nil then -- 631
		enemyTargets = params.enemyTargets -- 632
	elseif canShoot and router.settings.aimAssist and p ~= nil then -- 633
		enemyTargets = isPlayMode and params.cam ~= nil and collectPlayAimTargets(p, params.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH) -- 634
	else -- 634
		enemyTargets = {} -- 638
	end -- 638
	local playerScreenX = vp.stageW * 0.5 -- 641
	local playerScreenY = vp.stageH * 0.38 -- 642
	if p ~= nil then -- 643
		if isPlayMode and params.cam ~= nil then -- 644
			playerScreenX = params.cam:sx(p.player.x + p.player.facing * 8) -- 645
			playerScreenY = params.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 646
		else -- 646
			playerScreenX = vp.stageW * 0.45 -- 648
			playerScreenY = vp.stageH * 0.36 -- 649
		end -- 649
	end -- 649
	local ctx = { -- 653
		viewport = vp, -- 654
		overlayScale = overlayScale, -- 655
		overlayActive = overlayActive, -- 656
		allowAutoGameplayTouch = params.allowAutoGameplayTouch, -- 657
		allowMouseOnOverlay = params.allowMouseOnOverlay, -- 658
		modal = modal, -- 659
		gameplayActive = gameplayActive, -- 660
		cutsceneBlocking = cutsceneBlocking, -- 661
		childMode = p ~= nil and p.childMode, -- 662
		allowDepth = allowDepth, -- 663
		canShoot = canShoot, -- 664
		canBottleAim = canBottleAim, -- 665
		cartNearby = cartNearby, -- 666
		cartGripping = p ~= nil and p.gripping, -- 667
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 668
		coverNear = p ~= nil and p.coverNear, -- 669
		playerRolling = p ~= nil and p.player.rollT > 0, -- 670
		inLowArch = p ~= nil and isInLowArch(p), -- 671
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 672
		playerFacing = p ~= nil and p.player.facing or 1, -- 673
		playerScreenX = playerScreenX, -- 674
		playerScreenY = playerScreenY, -- 675
		enemyTargets = enemyTargets, -- 676
		stickZoneMaxX = stickZoneMaxX, -- 677
		stickZoneMaxY = stickZoneMaxY, -- 678
		stickDefaultX = stickDefaultX, -- 679
		stickDefaultY = stickDefaultY, -- 680
		stickMaxR = stickMaxR, -- 681
		stickFixedOrigin = isPortrait, -- 682
		buttons = buttons, -- 683
		rectZones = rectZones, -- 684
		bottleCancelCenter = bottleCancelCenter -- 685
	} -- 685
	self.lastContext = ctx -- 688
	router:setFrameContext(ctx, params.dt) -- 689
	return ctx -- 690
end -- 247
function TouchControls.prototype.render(self, router) -- 693
	local ctx = self.lastContext -- 694
	local pDel = self.portraitDelegate -- 695
	local portraitVisible = pDel ~= nil and ctx ~= nil and ctx.viewport.isPortrait -- 696
	local visible = ctx ~= nil and (ctx.overlayActive or portraitVisible) -- 697
	if not visible then -- 699
		if not self.hasDrawn then -- 700
			return -- 701
		end -- 701
		local ____opt_15 = self.deckDraw -- 703
		if ____opt_15 ~= nil then -- 703
			____opt_15:clear() -- 703
		end -- 703
		self.padDraw:clear() -- 704
		self.padInkDraw:clear() -- 705
		self.padGlow:clear() -- 706
		self.padArt:beginFrame() -- 707
		self.padArt:endFrame() -- 708
		self.texts:hideAll() -- 709
		self.hasDrawn = false -- 710
		return -- 711
	end -- 711
	self.hasDrawn = true -- 714
	local ____opt_17 = self.deckDraw -- 715
	if ____opt_17 ~= nil then -- 715
		____opt_17:clear() -- 715
	end -- 715
	self.padDraw:clear() -- 716
	self.padInkDraw:clear() -- 717
	self.padGlow:clear() -- 718
	self.padArt:beginFrame() -- 719
	self.texts:beginFrame() -- 720
	local vp = ctx.viewport -- 722
	local sc = math.max(0.25, ctx.overlayScale) -- 723
	self.overlayRoot.scaleX = sc -- 724
	self.overlayRoot.scaleY = sc -- 725
	local ovW = vp.fullW / sc -- 727
	local ovH = vp.fullH / sc -- 728
	local baseAlpha = router.settings.touchOpacity -- 729
	if portraitVisible and pDel ~= nil and self.deckDraw ~= nil then -- 731
		pDel:drawFrame( -- 732
			self.deckDraw, -- 732
			self.padInkDraw, -- 732
			self.texts, -- 732
			ctx, -- 732
			self.lastPlay, -- 732
			ovW, -- 732
			ovH -- 732
		) -- 732
	end -- 732
	if not ctx.overlayActive then -- 735
		self.padArt:endFrame() -- 736
		self.texts:endFrame() -- 737
		return -- 738
	end -- 738
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 741
		local rx = ovW * 0.5 -- 742
		local ry = portraitVisible and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 743
		drawSilkVeil( -- 744
			self.padDraw, -- 744
			self.padArt, -- 744
			"touch_restart_veil", -- 744
			rx, -- 744
			ry, -- 744
			230, -- 744
			36, -- 744
			PALETTE.inkWash, -- 744
			0.78 * baseAlpha, -- 744
			1 -- 744
		) -- 744
		drawHairline( -- 745
			self.padInkDraw, -- 745
			self.padArt, -- 745
			"touch_restart_line", -- 745
			rx, -- 745
			ry + 16, -- 745
			180, -- 745
			PALETTE.amber, -- 745
			0.52 * baseAlpha, -- 745
			true, -- 745
			2 -- 745
		) -- 745
		self.texts:put( -- 746
			"xs", -- 746
			"轻触屏幕再次启程", -- 746
			rx, -- 746
			ry, -- 746
			toColor(PALETTE.amberCore), -- 746
			0.5, -- 746
			0.5, -- 746
			"Center", -- 746
			1.6, -- 746
			0.94, -- 746
			0.08 -- 746
		) -- 746
	end -- 746
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 749
		self:drawTrialZones(ctx, baseAlpha) -- 750
	end -- 750
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 753
		self:drawStick(router, ctx, baseAlpha) -- 754
	end -- 754
	self:drawButtons(router, ctx, baseAlpha) -- 757
	local bottleDrag = router:getBottleDragVisual() -- 759
	if bottleDrag.active then -- 760
		local cx = bottleDrag.cancelX -- 761
		local cy = bottleDrag.cancelY -- 762
		local cr = bottleDrag.cancelR -- 763
		local hot = bottleDrag.cancelHover -- 764
		fillCirclePoly( -- 765
			self.padDraw, -- 766
			cx, -- 767
			cy, -- 768
			cr, -- 769
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 770
			0, -- 771
			nil, -- 772
			22 -- 773
		) -- 773
		drawRingArc( -- 775
			self.padInkDraw, -- 775
			cx, -- 775
			cy, -- 775
			cr, -- 775
			0, -- 775
			TWO_PI, -- 775
			hot and 2.2 or 1.3, -- 775
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 775
			22 -- 775
		) -- 775
		self.texts:put( -- 776
			"xs", -- 776
			hot and "松手取消" or "拖此取消", -- 776
			cx, -- 776
			cy, -- 776
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 776
			0.5, -- 776
			0.5, -- 776
			"Center", -- 776
			0.8, -- 776
			0.96, -- 776
			0.08 -- 776
		) -- 776
	end -- 776
	self.padArt:endFrame() -- 779
	self.texts:endFrame() -- 780
end -- 693
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 783
	local stick = router:getStickVisual() -- 784
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 785
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 788
	fillCirclePoly( -- 790
		self.padDraw, -- 791
		stick.originX, -- 792
		stick.originY, -- 793
		stick.radius, -- 794
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 795
		0, -- 796
		nil, -- 797
		28 -- 798
	) -- 798
	drawRingArc( -- 800
		self.padInkDraw, -- 800
		stick.originX, -- 800
		stick.originY, -- 800
		stick.radius, -- 800
		0, -- 800
		TWO_PI, -- 800
		stick.active and 1.5 or 1, -- 800
		toColor(ringCol, 168 * stickAlpha), -- 800
		28 -- 800
	) -- 800
	if stick.allowDepth then -- 802
		local dOff = stick.radius - 10 -- 803
		self.padInkDraw:drawDot( -- 804
			Vec2(stick.originX, stick.originY + dOff), -- 804
			2.1, -- 804
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 804
		) -- 804
		self.padInkDraw:drawDot( -- 805
			Vec2(stick.originX, stick.originY - dOff), -- 805
			2.1, -- 805
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 805
		) -- 805
		self.padInkDraw:drawDot( -- 806
			Vec2(stick.originX - dOff, stick.originY), -- 806
			2.1, -- 806
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 806
		) -- 806
		self.padInkDraw:drawDot( -- 807
			Vec2(stick.originX + dOff, stick.originY), -- 807
			2.1, -- 807
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 807
		) -- 807
	elseif ctx.childMode then -- 808
		drawRingArc( -- 809
			self.padInkDraw, -- 810
			stick.originX, -- 811
			stick.originY, -- 812
			stick.radius * 0.56, -- 813
			0, -- 814
			TWO_PI, -- 815
			0.9, -- 816
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 817
			20 -- 818
		) -- 818
	end -- 818
	local knobR = math.max(16, stick.radius * 0.36) -- 822
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 823
	if stick.active then -- 824
		fillRadialGlow( -- 825
			self.padGlow, -- 825
			stick.knobX, -- 825
			stick.knobY, -- 825
			knobR * 1.45, -- 825
			knobR * 1.45, -- 825
			toColor(knobAccent, 48 * stickAlpha), -- 825
			Color(0, 0, 0, 0), -- 825
			12 -- 825
		) -- 825
	end -- 825
	fillCirclePoly( -- 827
		self.padDraw, -- 828
		stick.knobX, -- 829
		stick.knobY, -- 830
		knobR, -- 831
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 832
		1.3, -- 833
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 834
		22 -- 835
	) -- 835
	drawBlossomDot( -- 837
		self.padInkDraw, -- 837
		self.padArt, -- 837
		"touch_stick_dot", -- 837
		stick.knobX, -- 837
		stick.knobY, -- 837
		stick.active and 11 or 7, -- 837
		knobAccent, -- 837
		0.85 * stickAlpha, -- 837
		4 -- 837
	) -- 837
	if stick.slowZone then -- 838
		self.texts:put( -- 839
			"xs", -- 839
			"轻步", -- 839
			stick.originX, -- 839
			stick.originY + stick.radius + 14, -- 839
			toColor(PALETTE.emerald), -- 839
			0.5, -- 839
			0.5, -- 839
			"Center", -- 839
			1, -- 839
			0.9, -- 839
			0.08 -- 839
		) -- 839
	end -- 839
end -- 783
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 843
	local bottleDrag = router:getBottleDragVisual() -- 844
	local fireStick = router:getFireStickVisual() -- 845
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 846
	local i = 0 -- 848
	do -- 848
		i = 0 -- 849
		while i < #ctx.buttons do -- 849
			do -- 849
				local b = ctx.buttons[i + 1] -- 850
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 851
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 852
					bAlpha = bAlpha * 0.25 -- 853
				end -- 853
				local col = accentPalette(b.accent) -- 855
				local core = accentCore(b.accent) -- 856
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 857
				if b.shape == "pill" and b.rect ~= nil then -- 859
					local r = b.rect -- 860
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 861
					self.padDraw:drawRoundedRect( -- 864
						r, -- 865
						6, -- 866
						fillCol, -- 867
						b.active and 1.4 or 1, -- 868
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 869
					) -- 869
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 871
						local icX = r.x + 22 -- 872
						local icY = r.y + r.height * 0.5 -- 873
						drawRingArc( -- 874
							self.padInkDraw, -- 874
							icX, -- 874
							icY, -- 874
							9, -- 874
							0, -- 874
							TWO_PI, -- 874
							1, -- 874
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 874
							16 -- 874
						) -- 874
						self.padInkDraw:drawSegment( -- 875
							Vec2(icX - 2.6, icY - 3.6), -- 875
							Vec2(icX - 2.6, icY + 3.6), -- 875
							1.5, -- 875
							toColor(PALETTE.textBright, 225 * bAlpha) -- 875
						) -- 875
						self.padInkDraw:drawSegment( -- 876
							Vec2(icX + 2.6, icY - 3.6), -- 876
							Vec2(icX + 2.6, icY + 3.6), -- 876
							1.5, -- 876
							toColor(PALETTE.textBright, 225 * bAlpha) -- 876
						) -- 876
						self.texts:put( -- 877
							"xs", -- 877
							b.label, -- 877
							r.x + r.width * 0.5 + 10, -- 877
							icY, -- 877
							toColor(PALETTE.textBright), -- 877
							0.5, -- 877
							0.5, -- 877
							"Center", -- 877
							1, -- 877
							0.94 * bAlpha, -- 877
							0.08 -- 877
						) -- 877
					else -- 877
						if b.toggle and b.active then -- 879
							drawDiamond( -- 880
								self.padInkDraw, -- 880
								r.x + 11, -- 880
								r.y + r.height * 0.5, -- 880
								3.8, -- 880
								3.8, -- 880
								toColor(col, 235) -- 880
							) -- 880
						end -- 880
						self.texts:put( -- 882
							"xs", -- 883
							b.label, -- 884
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 885
							r.y + r.height * 0.5, -- 886
							toColor(b.active and core or PALETTE.textBright), -- 887
							0.5, -- 888
							0.5, -- 889
							"Center", -- 890
							0.6, -- 891
							math.min(1, bAlpha + 0.08), -- 892
							0.08 -- 893
						) -- 893
					end -- 893
					goto __continue88 -- 896
				end -- 896
				if b.active or b.highlighted then -- 899
					fillRadialGlow( -- 900
						self.padGlow, -- 901
						b.x, -- 902
						b.y, -- 903
						b.r * 1.38, -- 904
						b.r * 1.38, -- 905
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 906
						Color(col.r, col.g, col.b, 0), -- 907
						12 -- 908
					) -- 908
				end -- 908
				fillCirclePoly( -- 912
					self.padDraw, -- 913
					b.x, -- 914
					b.y, -- 915
					b.r, -- 916
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 917
					0, -- 918
					nil, -- 919
					24 -- 920
				) -- 920
				drawRingArc( -- 922
					self.padInkDraw, -- 923
					b.x, -- 924
					b.y, -- 925
					b.r, -- 926
					0, -- 927
					TWO_PI, -- 928
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 929
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 930
					24 -- 931
				) -- 931
				drawRingArc( -- 933
					self.padInkDraw, -- 934
					b.x, -- 935
					b.y, -- 936
					b.r - 4.2, -- 937
					0, -- 938
					TWO_PI, -- 939
					0.7, -- 940
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 941
					20 -- 942
				) -- 942
				if b.progress > 0.02 then -- 945
					drawRingArc( -- 946
						self.padInkDraw, -- 947
						b.x, -- 948
						b.y, -- 949
						b.r + 4, -- 950
						HALF_PI, -- 951
						-TWO_PI * math.min(1, b.progress), -- 952
						2.6, -- 953
						toColor(PALETTE.amberCore, 240), -- 954
						28 -- 955
					) -- 955
				end -- 955
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 959
				self.texts:put( -- 960
					fontKind, -- 961
					b.label, -- 962
					b.x, -- 963
					hasSub and b.y + 6 or b.y, -- 964
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 965
					0.5, -- 966
					0.5, -- 967
					"Center", -- 968
					0.6, -- 969
					bAlpha, -- 970
					0.08 -- 971
				) -- 971
				if hasSub and b.subLabel ~= nil then -- 973
					self.texts:put( -- 974
						"xs", -- 975
						b.subLabel, -- 976
						b.x, -- 977
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 978
						toColor(b.active and core or PALETTE.textDim), -- 979
						0.5, -- 980
						0.5, -- 981
						"Center", -- 982
						0.4, -- 983
						bAlpha * 0.85, -- 984
						0.06 -- 985
					) -- 985
				end -- 985
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 989
					self.padInkDraw:drawSegment( -- 990
						Vec2(fireStick.originX, fireStick.originY), -- 990
						Vec2(fireStick.knobX, fireStick.knobY), -- 990
						1.4, -- 990
						toColor(PALETTE.rouge, 190) -- 990
					) -- 990
					fillCirclePoly( -- 991
						self.padDraw, -- 991
						fireStick.knobX, -- 991
						fireStick.knobY, -- 991
						12, -- 991
						toColor(PALETTE.rouge, 210), -- 991
						1.2, -- 991
						toColor(PALETTE.crimsonCore, 240), -- 991
						16 -- 991
					) -- 991
				end -- 991
			end -- 991
			::__continue88:: -- 991
			i = i + 1 -- 849
		end -- 849
	end -- 849
end -- 843
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 996
	local ____opt_19 = self.lastRun -- 997
	local trial = ____opt_19 and ____opt_19.trial -- 997
	local i = 0 -- 998
	do -- 998
		i = 0 -- 999
		while i < #ctx.rectZones do -- 999
			local z = ctx.rectZones[i + 1] -- 1000
			local r = z.rect -- 1001
			local cx = r.x + r.width * 0.5 -- 1002
			local cy = r.y + r.height * 0.5 -- 1003
			if z.id == "pause" or z.id == "retry" then -- 1004
				self.padDraw:drawRoundedRect( -- 1005
					r, -- 1005
					6, -- 1005
					toColor(PALETTE.inkWash, 185 * alpha), -- 1005
					1.2, -- 1005
					toColor(PALETTE.silkLine, 175 * alpha) -- 1005
				) -- 1005
				self.texts:put( -- 1006
					"xs", -- 1006
					z.id == "pause" and "暂停" or "重开", -- 1006
					cx, -- 1006
					cy, -- 1006
					toColor(PALETTE.textBright), -- 1006
					0.5, -- 1006
					0.5, -- 1006
					"Center", -- 1006
					0.8, -- 1006
					0.94, -- 1006
					0.08 -- 1006
				) -- 1006
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 1007
				local idx = __TS__Number(string.sub(z.id, 8)) -- 1008
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 1009
				self.padDraw:drawRoundedRect( -- 1010
					r, -- 1010
					6, -- 1010
					toColor(PALETTE.panelBgDeep, 235), -- 1010
					1.6, -- 1010
					toColor(PALETTE.amber, 225) -- 1010
				) -- 1010
				self.texts:put( -- 1011
					"xs", -- 1011
					(tostring(idx + 1) .. " · ") .. tName, -- 1011
					cx, -- 1011
					cy, -- 1011
					toColor(PALETTE.amberCore), -- 1011
					0.5, -- 1011
					0.5, -- 1011
					"Center", -- 1011
					0.6, -- 1011
					0.98, -- 1011
					0.08 -- 1011
				) -- 1011
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1012
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1013
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1014
				self.padDraw:drawRoundedRect( -- 1015
					r, -- 1015
					6, -- 1015
					toColor(PALETTE.panelBgDeep, 235), -- 1015
					1.5, -- 1015
					toColor(border, 220) -- 1015
				) -- 1015
				self.texts:put( -- 1016
					"sm", -- 1016
					label, -- 1016
					cx, -- 1016
					cy, -- 1016
					toColor(PALETTE.textBright), -- 1016
					0.5, -- 1016
					0.5, -- 1016
					"Center", -- 1016
					1, -- 1016
					0.98, -- 1016
					0.08 -- 1016
				) -- 1016
			end -- 1016
			i = i + 1 -- 999
		end -- 999
	end -- 999
end -- 996
return ____exports -- 996
