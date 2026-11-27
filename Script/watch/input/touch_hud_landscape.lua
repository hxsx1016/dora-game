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
local collectAimTargets = ____aim_assist.collectAimTargets -- 16
local projectMuzzle = ____aim_assist.projectMuzzle -- 16
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
	if accent == "cyan" then -- 70
		return PALETTE.cyan -- 71
	end -- 71
	if accent == "amber" then -- 71
		return PALETTE.amber -- 72
	end -- 72
	if accent == "rouge" then -- 72
		return PALETTE.rouge -- 73
	end -- 73
	if accent == "emerald" then -- 73
		return PALETTE.emerald -- 74
	end -- 74
	return PALETTE.silkLine -- 75
end -- 70
local function accentCore(accent) -- 78
	if accent == "cyan" then -- 78
		return PALETTE.cyanCore -- 79
	end -- 79
	if accent == "amber" then -- 79
		return PALETTE.amberCore -- 80
	end -- 80
	if accent == "rouge" then -- 80
		return PALETTE.crimsonCore -- 81
	end -- 81
	if accent == "emerald" then -- 81
		return PALETTE.emerald -- 82
	end -- 82
	return PALETTE.textBright -- 83
end -- 78
local function drawRingArc(draw, cx, cy, r, startRad, sweepRad, thickness, color, segments) -- 86
	if segments == nil then -- 86
		segments = 28 -- 95
	end -- 95
	if r <= 1 or math.abs(sweepRad) <= 0.001 then -- 95
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
	if borderWidth == nil then -- 112
		borderWidth = 0 -- 118
	end -- 118
	if segments == nil then -- 118
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
	if borderWidth > 0 and borderColor ~= nil then -- 124
		draw:drawPolygon(pts, fill, borderWidth, borderColor) -- 129
	else -- 129
		draw:drawPolygon(pts, fill) -- 131
	end -- 131
end -- 112
local function isNearLowLedgeForButton(p) -- 135
	if p.childMode then -- 135
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
				if b.broken == true or b.hidden == true then -- 141
					goto __continue24 -- 142
				end -- 142
				local h = b.y1 - b.y0 -- 143
				if h >= 24 and h <= 62 and probeX >= b.x0 - 16 and probeX <= b.x1 + 16 and math.abs(a.y - b.y0) <= 14 then -- 143
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
	if arch.h <= 0 then -- 153
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
	if portraitDelegate ~= nil then -- 181
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
	if self.lastContext ~= nil then -- 225
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
	local ____opt_8 = params.run -- 272
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
	) or nil -- 298
	local stickMaxR = pGeom ~= nil and pGeom.stickMaxR or STICK_BASE_R_LANDSCAPE * sc -- 300
	local stickDefaultX = pGeom ~= nil and pGeom.stickDefaultX or safeL + 126 * sc -- 301
	local stickDefaultY = pGeom ~= nil and pGeom.stickDefaultY or safeB + 126 * sc -- 302
	local stickZoneMaxX = pGeom ~= nil and pGeom.stickZoneMaxX or ovW * 0.46 -- 303
	local stickZoneMaxY = pGeom ~= nil and pGeom.stickZoneMaxY or ovH - 110 -- 304
	local bottleCancelCenter = {x = ovW - safeR - 106 * sc, y = safeB + 124 * sc, r = 44 * sc} -- 306
	if overlayActive then -- 306
		if isPortrait and pDel ~= nil then -- 306
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
		elseif isPlayMode and not modal then -- 313
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
			if params.showWebTopPills then -- 330
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
				if params.canToggleFullscreen then -- 347
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
	if isPortrait and pDel ~= nil and overlayActive and params.screen ~= "splash" and (not gameplayActive or isPlayMode and p ~= nil and p.paused) then -- 364
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
	if isPlayMode and p ~= nil and not modal and not cutsceneBlocking then -- 378
		if #params.storyTalentBoxes > 0 then -- 378
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
		if prompt ~= nil and (string.find(prompt.keyTag, "E", nil, true) or 0) - 1 >= 0 and params.cam ~= nil and params.assistHintsEnabled then -- 400
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
	if isPlayMode and p ~= nil and not p.paused and overlayActive and not isPortrait and p.room.key == "tower" and p.phase == "tower-end" and p:towerEndReady() then -- 413
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
	if isTrialMode and p ~= nil and overlayActive then -- 439
		if p.paused or trialEnded then -- 439
			local cx = ovW * 0.5 -- 445
			local cy = isPortrait and math.max(safeB + 110, vp.deckH * 0.52) or ovH * 0.48 -- 446
			local bw = isPortrait and math.min(220, ovW * 0.62) or 240 -- 447
			local bh = isPortrait and 44 or 50 -- 448
			local step = bh + 14 -- 449
			if p.paused and not trialEnded then -- 449
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
		elseif trialHasOffers and trial ~= nil then -- 454
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
			if not isPortrait then -- 464
				rectZones[#rectZones + 1] = { -- 471
					id = "pause", -- 471
					rect = Rect(ovW - safeR - 108, ovH - safeT - 64, 92, 46) -- 471
				} -- 471
			end -- 471
		elseif not isPortrait then -- 471
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
	if overlayActive and gameplayActive and p ~= nil and not modal and not cutsceneBlocking then -- 475
		local interactMeta = deriveInteractActionMeta( -- 481
			p, -- 481
			prompt or deriveWorldPrompt(p), -- 481
			cartNearby, -- 481
			router.cartGripLatched -- 481
		) -- 481
		local nearLedge = isNearLowLedgeForButton(p) -- 482
		if isPortrait and pDel ~= nil and pGeom ~= nil then -- 482
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
			if not p.childMode then -- 492
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
				if isPlayMode and p.archive.artifactOwned then -- 543
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
				if canBottleAim then -- 608
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
	if params.enemyTargets ~= nil then -- 630
		enemyTargets = params.enemyTargets -- 632
	elseif canShoot and router.settings.aimAssist and p ~= nil then -- 632
		enemyTargets = collectAimTargets(p, params.cam, vp.stageW, vp.stageH) -- 634
	else -- 634
		enemyTargets = {} -- 636
	end -- 636
	local muzzle = p ~= nil and projectMuzzle(p, params.cam) or nil -- 639
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 640
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 641
	local ctx = { -- 643
		viewport = vp, -- 644
		overlayScale = overlayScale, -- 645
		overlayActive = overlayActive, -- 646
		allowAutoGameplayTouch = params.allowAutoGameplayTouch, -- 647
		allowMouseOnOverlay = params.allowMouseOnOverlay, -- 648
		modal = modal, -- 649
		gameplayActive = gameplayActive, -- 650
		cutsceneBlocking = cutsceneBlocking, -- 651
		childMode = p ~= nil and p.childMode, -- 652
		allowDepth = allowDepth, -- 653
		canShoot = canShoot, -- 654
		canBottleAim = canBottleAim, -- 655
		cartNearby = cartNearby, -- 656
		cartGripping = p ~= nil and p.gripping, -- 657
		cartUsesToggle = p ~= nil and p.room.key == "c2-granary", -- 658
		coverNear = p ~= nil and p.coverNear, -- 659
		playerRolling = p ~= nil and p.player.rollT > 0, -- 660
		inLowArch = p ~= nil and isInLowArch(p), -- 661
		inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end", -- 662
		playerFacing = p ~= nil and p.player.facing or 1, -- 663
		playerScreenX = playerScreenX, -- 664
		playerScreenY = playerScreenY, -- 665
		enemyTargets = enemyTargets, -- 666
		stickZoneMaxX = stickZoneMaxX, -- 667
		stickZoneMaxY = stickZoneMaxY, -- 668
		stickDefaultX = stickDefaultX, -- 669
		stickDefaultY = stickDefaultY, -- 670
		stickMaxR = stickMaxR, -- 671
		stickFixedOrigin = isPortrait, -- 672
		buttons = buttons, -- 673
		rectZones = rectZones, -- 674
		bottleCancelCenter = bottleCancelCenter -- 675
	} -- 675
	self.lastContext = ctx -- 678
	router:setFrameContext(ctx, params.dt) -- 679
	return ctx -- 680
end -- 247
function TouchControls.prototype.render(self, router) -- 683
	local ctx = self.lastContext -- 684
	local pDel = self.portraitDelegate -- 685
	local portraitVisible = pDel ~= nil and ctx ~= nil and ctx.viewport.isPortrait -- 686
	local visible = ctx ~= nil and (ctx.overlayActive or portraitVisible) -- 687
	if not visible then -- 687
		if not self.hasDrawn then -- 687
			return -- 691
		end -- 691
		local ____opt_19 = self.deckDraw -- 691
		if ____opt_19 ~= nil then -- 691
			____opt_19:clear() -- 693
		end -- 693
		self.padDraw:clear() -- 694
		self.padInkDraw:clear() -- 695
		self.padGlow:clear() -- 696
		self.padArt:beginFrame() -- 697
		self.padArt:endFrame() -- 698
		self.texts:hideAll() -- 699
		self.hasDrawn = false -- 700
		return -- 701
	end -- 701
	self.hasDrawn = true -- 704
	local ____opt_21 = self.deckDraw -- 704
	if ____opt_21 ~= nil then -- 704
		____opt_21:clear() -- 705
	end -- 705
	self.padDraw:clear() -- 706
	self.padInkDraw:clear() -- 707
	self.padGlow:clear() -- 708
	self.padArt:beginFrame() -- 709
	self.texts:beginFrame() -- 710
	local vp = ctx.viewport -- 712
	local sc = math.max(0.25, ctx.overlayScale) -- 713
	self.overlayRoot.scaleX = sc -- 714
	self.overlayRoot.scaleY = sc -- 715
	local ovW = vp.fullW / sc -- 717
	local ovH = vp.fullH / sc -- 718
	local baseAlpha = router.settings.touchOpacity -- 719
	if portraitVisible and pDel ~= nil and self.deckDraw ~= nil then -- 719
		pDel:drawFrame( -- 722
			self.deckDraw, -- 722
			self.padInkDraw, -- 722
			self.texts, -- 722
			ctx, -- 722
			self.lastPlay, -- 722
			ovW, -- 722
			ovH -- 722
		) -- 722
	end -- 722
	if not ctx.overlayActive then -- 722
		self.padArt:endFrame() -- 726
		self.texts:endFrame() -- 727
		return -- 728
	end -- 728
	if ctx.cutsceneBlocking and ctx.inTowerEnd and not ctx.modal then -- 728
		local rx = ovW * 0.5 -- 732
		local ry = portraitVisible and math.max(vp.safe.bottom + 54, vp.deckH * 0.5) or vp.safe.bottom / sc + 54 -- 733
		drawSilkVeil( -- 734
			self.padDraw, -- 734
			self.padArt, -- 734
			"touch_restart_veil", -- 734
			rx, -- 734
			ry, -- 734
			230, -- 734
			36, -- 734
			PALETTE.inkWash, -- 734
			0.78 * baseAlpha, -- 734
			1 -- 734
		) -- 734
		drawHairline( -- 735
			self.padInkDraw, -- 735
			self.padArt, -- 735
			"touch_restart_line", -- 735
			rx, -- 735
			ry + 16, -- 735
			180, -- 735
			PALETTE.amber, -- 735
			0.52 * baseAlpha, -- 735
			true, -- 735
			2 -- 735
		) -- 735
		self.texts:put( -- 736
			"xs", -- 736
			"轻触屏幕再次启程", -- 736
			rx, -- 736
			ry, -- 736
			toColor(PALETTE.amberCore), -- 736
			0.5, -- 736
			0.5, -- 736
			"Center", -- 736
			1.6, -- 736
			0.94, -- 736
			0.08 -- 736
		) -- 736
	end -- 736
	if self.lastMode == 2 and self.lastPlay ~= nil then -- 736
		self:drawTrialZones(ctx, baseAlpha) -- 740
	end -- 740
	if ctx.gameplayActive and not ctx.modal and not ctx.cutsceneBlocking then -- 740
		self:drawStick(router, ctx, baseAlpha) -- 744
	end -- 744
	self:drawButtons(router, ctx, baseAlpha) -- 747
	local bottleDrag = router:getBottleDragVisual() -- 749
	if bottleDrag.active then -- 749
		local cx = bottleDrag.cancelX -- 751
		local cy = bottleDrag.cancelY -- 752
		local cr = bottleDrag.cancelR -- 753
		local hot = bottleDrag.cancelHover -- 754
		fillCirclePoly( -- 755
			self.padDraw, -- 756
			cx, -- 757
			cy, -- 758
			cr, -- 759
			toColor(hot and PALETTE.crimsonDeep or PALETTE.inkWash, hot and 225 or 175), -- 760
			0, -- 761
			nil, -- 762
			22 -- 763
		) -- 763
		drawRingArc( -- 765
			self.padInkDraw, -- 765
			cx, -- 765
			cy, -- 765
			cr, -- 765
			0, -- 765
			TWO_PI, -- 765
			hot and 2.2 or 1.3, -- 765
			toColor(hot and PALETTE.crimsonCore or PALETTE.rouge, hot and 245 or 185), -- 765
			22 -- 765
		) -- 765
		self.texts:put( -- 766
			"xs", -- 766
			hot and "松手取消" or "拖此取消", -- 766
			cx, -- 766
			cy, -- 766
			toColor(hot and PALETTE.crimsonCore or PALETTE.textBright), -- 766
			0.5, -- 766
			0.5, -- 766
			"Center", -- 766
			0.8, -- 766
			0.96, -- 766
			0.08 -- 766
		) -- 766
	end -- 766
	self.padArt:endFrame() -- 769
	self.texts:endFrame() -- 770
end -- 683
function TouchControls.prototype.drawStick(self, router, ctx, baseAlpha) -- 773
	local stick = router:getStickVisual() -- 774
	local stickAlpha = stick.active and math.min(1, baseAlpha + 0.16) or (ctx.viewport.isPortrait and math.min(0.95, baseAlpha * 0.92) or baseAlpha * 0.72) -- 775
	local ringCol = stick.active and PALETTE.textBright or PALETTE.silkDim -- 778
	fillCirclePoly( -- 780
		self.padDraw, -- 781
		stick.originX, -- 782
		stick.originY, -- 783
		stick.radius, -- 784
		toColor(PALETTE.inkWash, (stick.active and 118 or 78) * stickAlpha), -- 785
		0, -- 786
		nil, -- 787
		28 -- 788
	) -- 788
	drawRingArc( -- 790
		self.padInkDraw, -- 790
		stick.originX, -- 790
		stick.originY, -- 790
		stick.radius, -- 790
		0, -- 790
		TWO_PI, -- 790
		stick.active and 1.5 or 1, -- 790
		toColor(ringCol, 168 * stickAlpha), -- 790
		28 -- 790
	) -- 790
	if stick.allowDepth then -- 790
		local dOff = stick.radius - 10 -- 793
		self.padInkDraw:drawDot( -- 794
			Vec2(stick.originX, stick.originY + dOff), -- 794
			2.1, -- 794
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 794
		) -- 794
		self.padInkDraw:drawDot( -- 795
			Vec2(stick.originX, stick.originY - dOff), -- 795
			2.1, -- 795
			toColor(PALETTE.cyan, 155 * stickAlpha) -- 795
		) -- 795
		self.padInkDraw:drawDot( -- 796
			Vec2(stick.originX - dOff, stick.originY), -- 796
			2.1, -- 796
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 796
		) -- 796
		self.padInkDraw:drawDot( -- 797
			Vec2(stick.originX + dOff, stick.originY), -- 797
			2.1, -- 797
			toColor(PALETTE.silkLine, 145 * stickAlpha) -- 797
		) -- 797
	elseif ctx.childMode then -- 797
		drawRingArc( -- 799
			self.padInkDraw, -- 800
			stick.originX, -- 801
			stick.originY, -- 802
			stick.radius * 0.56, -- 803
			0, -- 804
			TWO_PI, -- 805
			0.9, -- 806
			toColor(stick.slowZone and PALETTE.emerald or PALETTE.silkDim, (stick.slowZone and 210 or 95) * stickAlpha), -- 807
			20 -- 808
		) -- 808
	end -- 808
	local knobR = math.max(16, stick.radius * 0.36) -- 812
	local knobAccent = stick.slowZone and PALETTE.emerald or (ctx.childMode and PALETTE.amber or PALETTE.cyan) -- 813
	if stick.active then -- 813
		fillRadialGlow( -- 815
			self.padGlow, -- 815
			stick.knobX, -- 815
			stick.knobY, -- 815
			knobR * 1.45, -- 815
			knobR * 1.45, -- 815
			toColor(knobAccent, 48 * stickAlpha), -- 815
			Color(0, 0, 0, 0), -- 815
			12 -- 815
		) -- 815
	end -- 815
	fillCirclePoly( -- 817
		self.padDraw, -- 818
		stick.knobX, -- 819
		stick.knobY, -- 820
		knobR, -- 821
		toColor(PALETTE.panelBgDeep, (stick.active and 215 or 155) * stickAlpha), -- 822
		1.3, -- 823
		toColor(stick.active and knobAccent or PALETTE.silkLine, 210 * stickAlpha), -- 824
		22 -- 825
	) -- 825
	drawBlossomDot( -- 827
		self.padInkDraw, -- 827
		self.padArt, -- 827
		"touch_stick_dot", -- 827
		stick.knobX, -- 827
		stick.knobY, -- 827
		stick.active and 11 or 7, -- 827
		knobAccent, -- 827
		0.85 * stickAlpha, -- 827
		4 -- 827
	) -- 827
	if stick.slowZone then -- 827
		self.texts:put( -- 829
			"xs", -- 829
			"轻步", -- 829
			stick.originX, -- 829
			stick.originY + stick.radius + 14, -- 829
			toColor(PALETTE.emerald), -- 829
			0.5, -- 829
			0.5, -- 829
			"Center", -- 829
			1, -- 829
			0.9, -- 829
			0.08 -- 829
		) -- 829
	end -- 829
end -- 773
function TouchControls.prototype.drawButtons(self, router, ctx, baseAlpha) -- 833
	local bottleDrag = router:getBottleDragVisual() -- 834
	local fireStick = router:getFireStickVisual() -- 835
	local fontKind = ctx.viewport.isPortrait and "xs" or "sm" -- 836
	local i = 0 -- 838
	do -- 838
		i = 0 -- 839
		while i < #ctx.buttons do -- 839
			do -- 839
				local b = ctx.buttons[i + 1] -- 840
				local bAlpha = baseAlpha * (b.dimmed and 0.42 or ((b.active or b.highlighted) and 1 or 0.84)) -- 841
				if bottleDrag.active and b.id ~= "bottle" and b.shape ~= "pill" then -- 841
					bAlpha = bAlpha * 0.25 -- 843
				end -- 843
				local col = accentPalette(b.accent) -- 845
				local core = accentCore(b.accent) -- 846
				local breathe = b.highlighted and 0.86 + 0.14 * math.sin(self.time * 4.2) or 1 -- 847
				if b.shape == "pill" and b.rect ~= nil then -- 847
					local r = b.rect -- 850
					local fillCol = b.active and toColor(col, 110 * bAlpha) or toColor(PALETTE.inkWash, 175 * bAlpha) -- 851
					self.padDraw:drawRoundedRect( -- 854
						r, -- 855
						6, -- 856
						fillCol, -- 857
						b.active and 1.4 or 1, -- 858
						toColor((b.active or b.highlighted) and col or PALETTE.silkLine, 200 * bAlpha) -- 859
					) -- 859
					if b.id == "pause" and not ctx.viewport.isPortrait then -- 859
						local icX = r.x + 22 -- 862
						local icY = r.y + r.height * 0.5 -- 863
						drawRingArc( -- 864
							self.padInkDraw, -- 864
							icX, -- 864
							icY, -- 864
							9, -- 864
							0, -- 864
							TWO_PI, -- 864
							1, -- 864
							toColor(PALETTE.silkLine, 175 * bAlpha), -- 864
							16 -- 864
						) -- 864
						self.padInkDraw:drawSegment( -- 865
							Vec2(icX - 2.6, icY - 3.6), -- 865
							Vec2(icX - 2.6, icY + 3.6), -- 865
							1.5, -- 865
							toColor(PALETTE.textBright, 225 * bAlpha) -- 865
						) -- 865
						self.padInkDraw:drawSegment( -- 866
							Vec2(icX + 2.6, icY - 3.6), -- 866
							Vec2(icX + 2.6, icY + 3.6), -- 866
							1.5, -- 866
							toColor(PALETTE.textBright, 225 * bAlpha) -- 866
						) -- 866
						self.texts:put( -- 867
							"xs", -- 867
							b.label, -- 867
							r.x + r.width * 0.5 + 10, -- 867
							icY, -- 867
							toColor(PALETTE.textBright), -- 867
							0.5, -- 867
							0.5, -- 867
							"Center", -- 867
							1, -- 867
							0.94 * bAlpha, -- 867
							0.08 -- 867
						) -- 867
					else -- 867
						if b.toggle and b.active then -- 867
							drawDiamond( -- 870
								self.padInkDraw, -- 870
								r.x + 11, -- 870
								r.y + r.height * 0.5, -- 870
								3.8, -- 870
								3.8, -- 870
								toColor(col, 235) -- 870
							) -- 870
						end -- 870
						self.texts:put( -- 872
							"xs", -- 873
							b.label, -- 874
							r.x + r.width * 0.5 + (b.toggle and b.active and 4 or 0), -- 875
							r.y + r.height * 0.5, -- 876
							toColor(b.active and core or PALETTE.textBright), -- 877
							0.5, -- 878
							0.5, -- 879
							"Center", -- 880
							0.6, -- 881
							math.min(1, bAlpha + 0.08), -- 882
							0.08 -- 883
						) -- 883
					end -- 883
					goto __continue85 -- 886
				end -- 886
				if b.active or b.highlighted then -- 886
					fillRadialGlow( -- 890
						self.padGlow, -- 891
						b.x, -- 892
						b.y, -- 893
						b.r * 1.38, -- 894
						b.r * 1.38, -- 895
						toColor(col, (b.active and 64 or 36) * bAlpha * breathe), -- 896
						Color(col.r, col.g, col.b, 0), -- 897
						12 -- 898
					) -- 898
				end -- 898
				fillCirclePoly( -- 902
					self.padDraw, -- 903
					b.x, -- 904
					b.y, -- 905
					b.r, -- 906
					toColor(b.active and PALETTE.inkWarm or PALETTE.inkWash, (b.active and 195 or 142) * bAlpha), -- 907
					0, -- 908
					nil, -- 909
					24 -- 910
				) -- 910
				drawRingArc( -- 912
					self.padInkDraw, -- 913
					b.x, -- 914
					b.y, -- 915
					b.r, -- 916
					0, -- 917
					TWO_PI, -- 918
					b.active and 2 or (b.highlighted and 1.5 or 1.05), -- 919
					toColor((b.active or b.highlighted) and col or PALETTE.silkDim, (b.active and 235 or 185) * bAlpha), -- 920
					24 -- 921
				) -- 921
				drawRingArc( -- 923
					self.padInkDraw, -- 924
					b.x, -- 925
					b.y, -- 926
					b.r - 4.2, -- 927
					0, -- 928
					TWO_PI, -- 929
					0.7, -- 930
					toColor(PALETTE.silkLine, (b.active and 110 or 52) * bAlpha), -- 931
					20 -- 932
				) -- 932
				if b.progress > 0.02 then -- 932
					drawRingArc( -- 936
						self.padInkDraw, -- 937
						b.x, -- 938
						b.y, -- 939
						b.r + 4, -- 940
						HALF_PI, -- 941
						-TWO_PI * math.min(1, b.progress), -- 942
						2.6, -- 943
						toColor(PALETTE.amberCore, 240), -- 944
						28 -- 945
					) -- 945
				end -- 945
				local hasSub = b.subLabel ~= nil and b.subLabel ~= "" -- 949
				self.texts:put( -- 950
					fontKind, -- 951
					b.label, -- 952
					b.x, -- 953
					hasSub and b.y + 6 or b.y, -- 954
					toColor(b.active and core or (b.dimmed and PALETTE.textDim or PALETTE.textBright)), -- 955
					0.5, -- 956
					0.5, -- 957
					"Center", -- 958
					0.6, -- 959
					bAlpha, -- 960
					0.08 -- 961
				) -- 961
				if hasSub and b.subLabel ~= nil then -- 961
					self.texts:put( -- 964
						"xs", -- 965
						b.subLabel, -- 966
						b.x, -- 967
						b.y - (ctx.viewport.isPortrait and 11 or 14), -- 968
						toColor(b.active and core or PALETTE.textDim), -- 969
						0.5, -- 970
						0.5, -- 971
						"Center", -- 972
						0.4, -- 973
						bAlpha * 0.85, -- 974
						0.06 -- 975
					) -- 975
				end -- 975
				if b.id == "fire" and fireStick.active and fireStick.dragging then -- 975
					self.padInkDraw:drawSegment( -- 980
						Vec2(fireStick.originX, fireStick.originY), -- 980
						Vec2(fireStick.knobX, fireStick.knobY), -- 980
						1.4, -- 980
						toColor(PALETTE.rouge, 190) -- 980
					) -- 980
					fillCirclePoly( -- 981
						self.padDraw, -- 981
						fireStick.knobX, -- 981
						fireStick.knobY, -- 981
						12, -- 981
						toColor(PALETTE.rouge, 210), -- 981
						1.2, -- 981
						toColor(PALETTE.crimsonCore, 240), -- 981
						16 -- 981
					) -- 981
				end -- 981
			end -- 981
			::__continue85:: -- 981
			i = i + 1 -- 839
		end -- 839
	end -- 839
end -- 833
function TouchControls.prototype.drawTrialZones(self, ctx, alpha) -- 986
	local ____opt_23 = self.lastRun -- 986
	local trial = ____opt_23 and ____opt_23.trial -- 987
	local i = 0 -- 988
	do -- 988
		i = 0 -- 989
		while i < #ctx.rectZones do -- 989
			local z = ctx.rectZones[i + 1] -- 990
			local r = z.rect -- 991
			local cx = r.x + r.width * 0.5 -- 992
			local cy = r.y + r.height * 0.5 -- 993
			if z.id == "pause" or z.id == "retry" then -- 993
				self.padDraw:drawRoundedRect( -- 995
					r, -- 995
					6, -- 995
					toColor(PALETTE.inkWash, 185 * alpha), -- 995
					1.2, -- 995
					toColor(PALETTE.silkLine, 175 * alpha) -- 995
				) -- 995
				self.texts:put( -- 996
					"xs", -- 996
					z.id == "pause" and "暂停" or "重开", -- 996
					cx, -- 996
					cy, -- 996
					toColor(PALETTE.textBright), -- 996
					0.5, -- 996
					0.5, -- 996
					"Center", -- 996
					0.8, -- 996
					0.94, -- 996
					0.08 -- 996
				) -- 996
			elseif (string.find(z.id, "talent:", nil, true) or 0) - 1 == 0 and trial ~= nil then -- 996
				local idx = __TS__Number(string.sub(z.id, 8)) -- 998
				local tName = idx >= 0 and idx < #trial.offers and talentNames[trial.offers[idx + 1]] or "" -- 999
				self.padDraw:drawRoundedRect( -- 1000
					r, -- 1000
					6, -- 1000
					toColor(PALETTE.panelBgDeep, 235), -- 1000
					1.6, -- 1000
					toColor(PALETTE.amber, 225) -- 1000
				) -- 1000
				self.texts:put( -- 1001
					"xs", -- 1001
					(tostring(idx + 1) .. " · ") .. tName, -- 1001
					cx, -- 1001
					cy, -- 1001
					toColor(PALETTE.amberCore), -- 1001
					0.5, -- 1001
					0.5, -- 1001
					"Center", -- 1001
					0.6, -- 1001
					0.98, -- 1001
					0.08 -- 1001
				) -- 1001
			elseif z.id == "trial:resume" or z.id == "trial:retry" or z.id == "trial:title" then -- 1001
				local label = z.id == "trial:resume" and "继续试炼" or (z.id == "trial:retry" and "再开一局" or "返回标题") -- 1003
				local border = z.id == "trial:resume" and PALETTE.amber or PALETTE.silkLine -- 1004
				self.padDraw:drawRoundedRect( -- 1005
					r, -- 1005
					6, -- 1005
					toColor(PALETTE.panelBgDeep, 235), -- 1005
					1.5, -- 1005
					toColor(border, 220) -- 1005
				) -- 1005
				self.texts:put( -- 1006
					"sm", -- 1006
					label, -- 1006
					cx, -- 1006
					cy, -- 1006
					toColor(PALETTE.textBright), -- 1006
					0.5, -- 1006
					0.5, -- 1006
					"Center", -- 1006
					1, -- 1006
					0.98, -- 1006
					0.08 -- 1006
				) -- 1006
			end -- 1006
			i = i + 1 -- 989
		end -- 989
	end -- 989
end -- 986
return ____exports -- 986