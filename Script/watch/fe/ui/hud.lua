-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Rect = ____Dora.Rect -- 8
local Vec2 = ____Dora.Vec2 -- 8
local ____run = require("Script.watch.run") -- 10
local talentNames = ____run.talentNames -- 10
local ____depth = require("Script.watch.depth") -- 11
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 11
local ____escort = require("Script.watch.escort") -- 12
local FEAR_MAX = ____escort.FEAR_MAX -- 12
local ____platform = require("Script.watch.platform") -- 14
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 14
local ____target = require("Script.watch.target") -- 15
local getActiveTarget = ____target.getActiveTarget -- 15
local ____adapter = require("Script.watch.fe.adapter") -- 16
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 16
local ____theme = require("Script.watch.fe.theme") -- 21
local PALETTE = ____theme.PALETTE -- 22
local drawBlossomDot = ____theme.drawBlossomDot -- 23
local drawHairline = ____theme.drawHairline -- 24
local drawSilkKeycap = ____theme.drawSilkKeycap -- 25
local drawSilkVeil = ____theme.drawSilkVeil -- 26
local fillRadialGlow = ____theme.fillRadialGlow -- 27
local themeOf = ____theme.themeOf -- 28
local toColor = ____theme.toColor -- 29
local visualTextWidth = ____theme.visualTextWidth -- 30
____exports.HudRenderer = __TS__Class() -- 33
local HudRenderer = ____exports.HudRenderer -- 33
HudRenderer.name = "HudRenderer" -- 33
function HudRenderer.prototype.____constructor(self) -- 33
	self.ghostHp = 3 -- 35
	self.time = 0 -- 36
	self.talentSelected = 0 -- 38
	self.roguelikeUiHandled = false -- 40
	self.lastInteractPromptMode = "none" -- 45
end -- 33
function HudRenderer.prototype.reset(self, p) -- 47
	self.ghostHp = p ~= nil and p.hp or 3 -- 48
	self.talentSelected = 0 -- 49
	self.lastInteractPromptRect = nil -- 50
	self.lastInteractPromptMode = "none" -- 51
end -- 47
function HudRenderer.prototype.getChapterPauseRect(self, w, h, safe, touchOverlayVisible) -- 55
	if safe == nil then -- 55
		safe = ZERO_SAFE_INSETS -- 55
	end -- 55
	if touchOverlayVisible == nil then -- 55
		touchOverlayVisible = false -- 55
	end -- 55
	if touchOverlayVisible then -- 55
		return Rect(0, 0, 0, 0) -- 57
	end -- 57
	local rx = w - 32 - safe.right -- 59
	local cy = h - 44 - safe.top -- 60
	return Rect(rx - 202, cy - 22, 210, 44) -- 61
end -- 55
function HudRenderer.prototype.getInteractPromptHit(self) -- 64
	if self.lastInteractPromptRect == nil or self.lastInteractPromptMode == "none" then -- 64
		return nil -- 66
	end -- 66
	return {rect = self.lastInteractPromptRect, mode = self.lastInteractPromptMode} -- 68
end -- 64
function HudRenderer.prototype.update(self, dt, p) -- 71
	self.time = self.time + dt -- 72
	if self.ghostHp > p.hp then -- 72
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 74
	else -- 74
		self.ghostHp = p.hp -- 76
	end -- 76
end -- 71
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible, pointerUi, pointerInside) -- 80
	if assistHintsEnabled == nil then -- 80
		assistHintsEnabled = true -- 91
	end -- 91
	if suppressReticle == nil then -- 91
		suppressReticle = false -- 92
	end -- 92
	if inputMode == nil then -- 92
		inputMode = "kbm" -- 93
	end -- 93
	if gamepadLayout == nil then -- 93
		gamepadLayout = "xbox" -- 94
	end -- 94
	if safe == nil then -- 94
		safe = ZERO_SAFE_INSETS -- 95
	end -- 95
	if retryHoldProgress == nil then -- 95
		retryHoldProgress = 0 -- 96
	end -- 96
	if touchOverlayVisible == nil then -- 96
		touchOverlayVisible = false -- 97
	end -- 97
	if pointerInside == nil then -- 97
		pointerInside = false -- 99
	end -- 99
	local w = cam.viewW / uiScale -- 101
	local h = cam.viewH / uiScale -- 102
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 103
	self.lastInteractPromptRect = nil -- 104
	self.lastInteractPromptMode = "none" -- 105
	if hudAlpha > 0.05 then -- 105
		if p.childMode then -- 105
			self:drawChildStatus( -- 109
				uiDraw, -- 109
				uiInkDraw, -- 109
				uiArt, -- 109
				texts, -- 109
				p, -- 109
				h, -- 109
				hudAlpha, -- 109
				assistHintsEnabled, -- 109
				inputMode, -- 109
				gamepadLayout, -- 109
				safe -- 109
			) -- 109
		else -- 109
			self:drawSoldierStatus( -- 111
				uiDraw, -- 111
				uiInkDraw, -- 111
				uiArt, -- 111
				texts, -- 111
				p, -- 111
				h, -- 111
				hudAlpha, -- 111
				assistHintsEnabled, -- 111
				inputMode, -- 111
				gamepadLayout, -- 111
				safe -- 111
			) -- 111
		end -- 111
		self:drawChapterBadge( -- 114
			uiDraw, -- 114
			uiInkDraw, -- 114
			uiArt, -- 114
			texts, -- 114
			p, -- 114
			w, -- 114
			h, -- 114
			hudAlpha, -- 114
			inputMode, -- 114
			safe, -- 114
			touchOverlayVisible, -- 114
			pointerUi, -- 114
			pointerInside -- 114
		) -- 114
		self:drawContextualObjective( -- 115
			uiDraw, -- 115
			uiInkDraw, -- 115
			uiArt, -- 115
			texts, -- 115
			p, -- 115
			w, -- 115
			h, -- 115
			hudAlpha, -- 115
			assistHintsEnabled, -- 115
			inputMode, -- 115
			gamepadLayout, -- 115
			safe -- 115
		) -- 115
		if assistHintsEnabled then -- 115
			local prompt = deriveWorldPrompt(p) -- 118
			if prompt ~= nil then -- 118
				local clickMode = prompt.keyTag == "E" and "tap" or ((prompt.keyTag == "按住 E" or prompt.keyTag == "松开再按住 E") and "hold" or "none") -- 120
				local adapted = { -- 123
					x = prompt.x, -- 124
					y = prompt.y, -- 125
					keyTag = getActiveTarget():adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout), -- 126
					label = prompt.label, -- 127
					urgent = prompt.urgent, -- 128
					progress = prompt.progress -- 129
				} -- 129
				self:drawWorldPrompts( -- 131
					uiDraw, -- 131
					uiInkDraw, -- 131
					uiArt, -- 131
					texts, -- 131
					{adapted}, -- 131
					cam, -- 131
					hudAlpha, -- 131
					uiScale, -- 131
					safe, -- 131
					clickMode, -- 131
					inputMode, -- 131
					pointerUi, -- 131
					pointerInside -- 131
				) -- 131
			end -- 131
		end -- 131
		if vfx.deflectFlash > 0.25 then -- 131
			local dx = cam:sx(vfx.deflectX) / uiScale -- 136
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 137
			texts:put( -- 138
				"sm", -- 138
				"掩体挡下", -- 138
				dx, -- 138
				dy, -- 138
				toColor(PALETTE.textBright), -- 138
				0.5, -- 138
				0.5, -- 138
				"Center", -- 138
				2, -- 138
				vfx.deflectFlash, -- 138
				0.1 -- 138
			) -- 138
		end -- 138
	end -- 138
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 143
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 144
	local canRetryNow = not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive -- 146
	if retryHoldProgress > 0.02 and canRetryNow then -- 146
		local cx = w * 0.5 -- 148
		local cy = h - 32 - safe.top -- 149
		local bw = 240 -- 150
		local isMaleRoguelike = p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() -- 151
		local holdKey = inputMode == "gamepad" and "BACK" or "R" -- 152
		local holdLabel = isMaleRoguelike and ("长按 " .. holdKey) .. " 重开本轮护送" or ("长按 " .. holdKey) .. " 重试检查点" -- 153
		drawSilkVeil( -- 154
			uiDraw, -- 154
			uiArt, -- 154
			"hud_retry_hold_veil", -- 154
			cx, -- 154
			cy, -- 154
			bw + 60, -- 154
			34, -- 154
			PALETTE.inkWarm, -- 154
			0.84, -- 154
			2 -- 154
		) -- 154
		texts:put( -- 155
			"xs", -- 155
			holdLabel, -- 155
			cx, -- 155
			cy + 7, -- 155
			toColor(PALETTE.amberCore), -- 155
			0.5, -- 155
			0.5, -- 155
			"Center", -- 155
			1, -- 155
			0.96, -- 155
			0.08 -- 155
		) -- 155
		local x0 = cx - bw * 0.44 -- 156
		local x1 = cx + bw * 0.44 -- 157
		uiInkDraw:drawSegment( -- 158
			Vec2(x0, cy - 8), -- 158
			Vec2(x1, cy - 8), -- 158
			1.4, -- 158
			toColor(PALETTE.silkDim, 120) -- 158
		) -- 158
		uiInkDraw:drawSegment( -- 159
			Vec2(x0, cy - 8), -- 159
			Vec2( -- 159
				x0 + (x1 - x0) * math.min(1, retryHoldProgress), -- 159
				cy - 8 -- 159
			), -- 159
			2.8, -- 159
			toColor(PALETTE.rouge, 235) -- 159
		) -- 159
	end -- 159
	if not suppressReticle then -- 159
		self:drawReticleOverlay( -- 163
			uiInkDraw, -- 163
			uiArt, -- 163
			uiGlow, -- 163
			p, -- 163
			cam, -- 163
			vfx, -- 163
			letterboxFrac, -- 163
			uiScale, -- 163
			inputMode == "touch" -- 163
		) -- 163
	end -- 163
end -- 80
function HudRenderer.prototype.talentCardRects(self, w, h, count, touchMode, safeTop) -- 168
	if touchMode == nil then -- 168
		touchMode = false -- 168
	end -- 168
	if safeTop == nil then -- 168
		safeTop = 0 -- 168
	end -- 168
	if self.talentRectProvider ~= nil then -- 168
		return self:talentRectProvider( -- 170
			w, -- 170
			h, -- 170
			count, -- 170
			touchMode, -- 170
			safeTop -- 170
		) -- 170
	end -- 170
	local out = {} -- 172
	if count <= 0 then -- 172
		return out -- 174
	end -- 174
	local cardW = touchMode and 212 or 204 -- 176
	local cardH = touchMode and 50 or 38 -- 177
	local gap = 14 -- 178
	local totalW = count * cardW + (count - 1) * gap -- 179
	local startX = (w - totalW) * 0.5 -- 180
	local y = h - (touchMode and 132 or 120) - safeTop -- 181
	local i = 0 -- 182
	do -- 182
		i = 0 -- 183
		while i < count do -- 183
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 184
			i = i + 1 -- 183
		end -- 183
	end -- 183
	return out -- 186
end -- 168
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, touchMode) -- 190
	if touchMode == nil then -- 190
		touchMode = false -- 199
	end -- 199
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 199
		self:drawReticle( -- 203
			uiInkDraw, -- 203
			uiArt, -- 203
			uiGlow, -- 203
			p, -- 203
			cam, -- 203
			vfx, -- 203
			uiScale, -- 203
			touchMode -- 203
		) -- 203
	end -- 203
end -- 190
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 207
	local bx = 28 + safe.left -- 220
	local by = h - 72 - safe.top -- 221
	local lowHp = p.hp <= 1 -- 222
	local segCount = math.max(1, p.maxHp) -- 224
	local segW = segCount >= 5 and 42 or 54 -- 225
	local segH = 9 -- 226
	local gap = segCount >= 5 and 6 or 8 -- 227
	local veilW = math.max(340, 124 + segCount * (segW + gap)) -- 228
	drawSilkVeil( -- 229
		uiDraw, -- 229
		uiArt, -- 229
		"hud_soldier_veil", -- 229
		bx + veilW * 0.44, -- 229
		by + 24, -- 229
		veilW, -- 229
		56, -- 229
		PALETTE.inkWash, -- 229
		0.62 * alpha, -- 229
		-1 -- 229
	) -- 229
	texts:put( -- 230
		"md", -- 230
		"戍", -- 230
		bx + 16, -- 230
		by + 25, -- 230
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 230
		0.5, -- 230
		0.5, -- 230
		"Center", -- 230
		0, -- 230
		alpha, -- 230
		0.1 -- 230
	) -- 230
	uiInkDraw:drawSegment( -- 231
		Vec2(bx + 32, by + 9), -- 231
		Vec2(bx + 32, by + 40), -- 231
		0.8, -- 231
		toColor(PALETTE.silkDim, 130 * alpha) -- 231
	) -- 231
	texts:put( -- 232
		"xs", -- 232
		"周戍 · 体力", -- 232
		bx + 44, -- 232
		by + 36, -- 232
		toColor(PALETTE.textMid), -- 232
		0, -- 232
		0.5, -- 232
		"Left", -- 232
		1.4, -- 232
		alpha, -- 232
		0.08 -- 232
	) -- 232
	local barX = bx + 44 -- 234
	local barY = by + 16 -- 235
	local i = 0 -- 237
	do -- 237
		i = 0 -- 238
		while i < segCount do -- 238
			local sx = barX + i * (segW + gap) -- 239
			local scx = sx + segW * 0.5 -- 240
			if not uiArt:tryPlace( -- 240
				"ink_bamboo_slot", -- 241
				"hp_slot_" .. tostring(i), -- 241
				scx, -- 241
				barY, -- 241
				segW, -- 241
				segH, -- 241
				{ -- 241
					color = toColor(PALETTE.silkDim), -- 242
					opacity = 0.72 * alpha, -- 242
					layer = 1 -- 242
				} -- 242
			) then -- 242
				uiInkDraw:drawRect( -- 244
					Rect(sx, barY - 3, segW, 6), -- 244
					Color(0, 0, 0, 0), -- 244
					0.8, -- 244
					toColor(PALETTE.silkDim, 145 * alpha) -- 244
				) -- 244
			end -- 244
			if self.ghostHp > i and self.ghostHp > p.hp then -- 244
				local frac = math.min(1, self.ghostHp - i) -- 247
				uiInkDraw:drawRect( -- 248
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 248
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 248
				) -- 248
			end -- 248
			if p.hp > i then -- 248
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 251
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 252
				if not uiArt:tryPlace( -- 252
					"ink_bamboo_slip", -- 253
					"hp_fill_" .. tostring(i), -- 253
					scx, -- 253
					barY, -- 253
					segW, -- 253
					segH, -- 253
					{ -- 253
						color = toColor(fillCol), -- 254
						opacity = 0.94 * alpha * pulse, -- 254
						layer = 2 -- 254
					} -- 254
				) then -- 254
					uiInkDraw:drawRect( -- 256
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 256
						toColor(fillCol, 230 * alpha * pulse) -- 256
					) -- 256
				end -- 256
			end -- 256
			i = i + 1 -- 238
		end -- 238
	end -- 238
	local covX = barX + segCount * (segW + gap) + 6 -- 261
	local hasAliveEnemy = false -- 262
	do -- 262
		i = 0 -- 263
		while i < #p.enemies do -- 263
			if p.enemies[i + 1].alive then -- 263
				hasAliveEnemy = true -- 265
				break -- 266
			end -- 266
			i = i + 1 -- 263
		end -- 263
	end -- 263
	if p.coverHug then -- 263
		if hasAliveEnemy and not p.coverBlocking then -- 263
			uiInkDraw:drawRect( -- 271
				Rect(covX, barY - 9, 72, 18), -- 271
				toColor(PALETTE.inkWarm, 185 * alpha), -- 271
				0.8, -- 271
				toColor(PALETTE.amber, 200 * alpha) -- 271
			) -- 271
			texts:put( -- 272
				"xs", -- 272
				"背向掩体", -- 272
				covX + 36, -- 272
				barY, -- 272
				toColor(PALETTE.amberCore), -- 272
				0.5, -- 272
				0.5, -- 272
				"Center", -- 272
				0.6, -- 272
				alpha, -- 272
				0 -- 272
			) -- 272
		else -- 272
			uiInkDraw:drawRect( -- 274
				Rect(covX, barY - 9, 54, 18), -- 274
				toColor(PALETTE.cyanDim, 165 * alpha), -- 274
				0.8, -- 274
				toColor(PALETTE.cyanCore, 180 * alpha) -- 274
			) -- 274
			texts:put( -- 275
				"xs", -- 275
				"掩体中", -- 275
				covX + 27, -- 275
				barY, -- 275
				toColor(PALETTE.textBright), -- 275
				0.5, -- 275
				0.5, -- 275
				"Center", -- 275
				0.6, -- 275
				alpha, -- 275
				0 -- 275
			) -- 275
		end -- 275
	elseif assistHintsEnabled and p.coverNear then -- 275
		uiInkDraw:drawRect( -- 278
			Rect(covX, barY - 9, 54, 18), -- 278
			Color( -- 278
				14, -- 278
				17, -- 278
				25, -- 278
				math.floor(150 * alpha + 0.5) -- 278
			), -- 278
			0.8, -- 278
			toColor(PALETTE.silkLine, 165 * alpha) -- 278
		) -- 278
		texts:put( -- 279
			"xs", -- 279
			"可贴靠", -- 279
			covX + 27, -- 279
			barY, -- 279
			toColor(PALETTE.textMid), -- 279
			0.5, -- 279
			0.5, -- 279
			"Center", -- 279
			0.6, -- 279
			alpha, -- 279
			0.08 -- 279
		) -- 279
	end -- 279
	local ____p_isCampaign_5 = p.isCampaign -- 282
	if ____p_isCampaign_5 then -- 282
		local ____opt_0 = p.room.campaign -- 282
		local ____temp_4 = (____opt_0 and ____opt_0.chapter) == "S" -- 282
		if not ____temp_4 then -- 282
			local ____opt_2 = p.room.campaign -- 282
			____temp_4 = (____opt_2 and ____opt_2.chapter) == "C" -- 282
		end -- 282
		____p_isCampaign_5 = ____temp_4 -- 282
	end -- 282
	local showCampaignFear = ____p_isCampaign_5 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 282
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" or showCampaignFear then -- 282
		local subY = by - 24 -- 285
		local frozen = p.escort.state == "frozen" -- 286
		local calming = p.escort.state == "calming" -- 287
		drawSilkVeil( -- 289
			uiDraw, -- 289
			uiArt, -- 289
			"hud_fear_veil", -- 289
			bx + 126, -- 289
			subY + 6, -- 289
			260, -- 289
			30, -- 289
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 289
			0.64 * alpha, -- 289
			-1 -- 289
		) -- 289
		texts:put( -- 290
			"xs", -- 290
			"小满 · 惊惧", -- 290
			bx + 14, -- 290
			subY + 6, -- 290
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 290
			0, -- 290
			0.5, -- 290
			"Left", -- 290
			1, -- 290
			alpha, -- 290
			0.08 -- 290
		) -- 290
		local k = 0 -- 292
		do -- 292
			k = 0 -- 293
			while k < FEAR_MAX do -- 293
				local dx = bx + 114 + k * 20 -- 294
				local dy = subY + 6 -- 295
				local lit = k < p.escort.fear -- 296
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 297
				uiArt:tryPlace( -- 298
					"ink_enso_fine", -- 298
					"fear_ring_" .. tostring(k), -- 298
					dx, -- 298
					dy, -- 298
					14, -- 298
					14, -- 298
					{ -- 298
						color = toColor(lit and dc or PALETTE.silkLine), -- 299
						opacity = (lit and 0.92 or 0.64) * alpha, -- 299
						layer = 2 -- 299
					} -- 299
				) -- 299
				if lit then -- 299
					drawBlossomDot( -- 302
						uiInkDraw, -- 302
						uiArt, -- 302
						"fear_dot_" .. tostring(k), -- 302
						dx, -- 302
						dy, -- 302
						10, -- 302
						dc, -- 302
						0.96 * alpha, -- 302
						3 -- 302
					) -- 302
				end -- 302
				k = k + 1 -- 293
			end -- 293
		end -- 293
		if frozen then -- 293
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 307
			if assistHintsEnabled then -- 307
				local calmKey = getActiveTarget():adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 309
				local keyW = math.max( -- 310
					22, -- 310
					visualTextWidth(calmKey, 15) + 10 -- 310
				) -- 310
				drawSilkKeycap( -- 311
					uiInkDraw, -- 311
					texts, -- 311
					bx + 170, -- 311
					subY - 5, -- 311
					keyW, -- 311
					22, -- 311
					calmKey, -- 311
					PALETTE.rouge, -- 311
					alpha * pulse, -- 311
					true -- 311
				) -- 311
				texts:put( -- 312
					"xs", -- 312
					"轻敲安抚", -- 312
					bx + 176 + keyW, -- 312
					subY + 6, -- 312
					toColor(PALETTE.crimsonCore), -- 312
					0, -- 312
					0.5, -- 312
					"Left", -- 312
					0.8, -- 312
					alpha * pulse, -- 312
					0.08 -- 312
				) -- 312
			else -- 312
				texts:put( -- 314
					"xs", -- 314
					"受惊停步", -- 314
					bx + 172, -- 314
					subY + 6, -- 314
					toColor(PALETTE.crimsonCore), -- 314
					0, -- 314
					0.5, -- 314
					"Left", -- 314
					0.8, -- 314
					alpha * pulse, -- 314
					0.08 -- 314
				) -- 314
			end -- 314
		elseif calming then -- 314
			texts:put( -- 317
				"xs", -- 317
				"轻敲安抚中", -- 317
				bx + 172, -- 317
				subY + 6, -- 317
				toColor(PALETTE.emerald), -- 317
				0, -- 317
				0.5, -- 317
				"Left", -- 317
				0.8, -- 317
				alpha, -- 317
				0.08 -- 317
			) -- 317
		end -- 317
	end -- 317
	if not self.roguelikeUiHandled then -- 317
		local ranks = p:getStoryTalentRanks() -- 322
		if ranks ~= nil then -- 322
			local parts = {} -- 324
			if ranks.vitality > 0 then -- 324
				parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 325
			end -- 325
			if ranks.focus > 0 then -- 325
				parts[#parts + 1] = "凝神" .. tostring(ranks.focus) -- 326
			end -- 326
			if ranks.guard > 0 then -- 326
				parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 327
			end -- 327
			if ranks.salvage > 0 then -- 327
				parts[#parts + 1] = "拾料" .. tostring(ranks.salvage) -- 328
			end -- 328
			if #parts > 0 then -- 328
				local subY = by - 22 -- 330
				local txt = "本领 · " .. table.concat(parts, " · ") -- 331
				drawSilkVeil( -- 332
					uiDraw, -- 332
					uiArt, -- 332
					"hud_talent_ranks_veil", -- 332
					bx + 126, -- 332
					subY + 6, -- 332
					260, -- 332
					26, -- 332
					PALETTE.inkWash, -- 332
					0.56 * alpha, -- 332
					-1 -- 332
				) -- 332
				texts:put( -- 333
					"xs", -- 333
					txt, -- 333
					bx + 14, -- 333
					subY + 6, -- 333
					toColor(PALETTE.amberCore), -- 333
					0, -- 333
					0.5, -- 333
					"Left", -- 333
					0.8, -- 333
					alpha, -- 333
					0.08 -- 333
				) -- 333
			end -- 333
		elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 333
			local inv = p.run.inventory -- 336
			local items = {} -- 337
			if inv.shield > 0 then -- 337
				items[#items + 1] = "残盾" .. tostring(inv.shield) -- 338
			end -- 338
			if inv.wedge > 0 then -- 338
				items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 339
			end -- 339
			if inv.ammo > 0 then -- 339
				items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 340
			end -- 340
			if inv.scrap > 0 then -- 340
				items[#items + 1] = "木料" .. tostring(inv.scrap) -- 341
			end -- 341
			local companionText = p.run.joined and "小满同行" or "小满等待" -- 342
			local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 343
			local subY = by - 22 -- 344
			drawSilkVeil( -- 345
				uiDraw, -- 345
				uiArt, -- 345
				"hud_camp_veil", -- 345
				bx + 126, -- 345
				subY + 6, -- 345
				260, -- 345
				26, -- 345
				PALETTE.inkWash, -- 345
				0.54 * alpha, -- 345
				-1 -- 345
			) -- 345
			texts:put( -- 346
				"xs", -- 346
				summary, -- 346
				bx + 14, -- 346
				subY + 6, -- 346
				toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 346
				0, -- 346
				0.5, -- 346
				"Left", -- 346
				0.8, -- 346
				alpha, -- 346
				0.08 -- 346
			) -- 346
		end -- 346
	end -- 346
end -- 207
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 351
	local bx = 28 + safe.left -- 364
	local by = h - 68 - safe.top -- 365
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 366
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 367
	drawSilkVeil( -- 369
		uiDraw, -- 369
		uiArt, -- 369
		"hud_child_veil", -- 369
		bx + 144, -- 369
		by + 22, -- 369
		316, -- 369
		48, -- 369
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 369
		0.58 * alpha, -- 369
		-1 -- 369
	) -- 369
	texts:put( -- 370
		"md", -- 370
		alert and "危" or "满", -- 370
		bx + 16, -- 370
		by + 22, -- 370
		toColor(leadCol), -- 370
		0.5, -- 370
		0.5, -- 370
		"Center", -- 370
		0, -- 370
		alpha, -- 370
		0.1 -- 370
	) -- 370
	uiInkDraw:drawSegment( -- 371
		Vec2(bx + 32, by + 7), -- 371
		Vec2(bx + 32, by + 37), -- 371
		0.8, -- 371
		toColor(PALETTE.silkDim, 130 * alpha) -- 371
	) -- 371
	texts:put( -- 372
		"xs", -- 372
		"小满 · 潜行", -- 372
		bx + 44, -- 372
		by + 33, -- 372
		toColor(PALETTE.amberCore), -- 372
		0, -- 372
		0.5, -- 372
		"Left", -- 372
		1.4, -- 372
		alpha, -- 372
		0.08 -- 372
	) -- 372
	local posture = assistHintsEnabled and "轻步前行 · 保持隐蔽" or "轻步前行" -- 374
	local col = PALETTE.textMid -- 375
	if alert then -- 375
		posture = (p.scavChase or p.dogState == "chase") and (assistHintsEnabled and "已被发现 · 速寻隐蔽" or "已被发现") or (assistHintsEnabled and "引起警觉 · 停步蹲伏" or "引起警觉") -- 377
		col = PALETTE.crimsonCore -- 380
	elseif p.player.crouch then -- 380
		posture = assistHintsEnabled and "低姿伏行 · 匿迹于影" or "低姿伏行" -- 382
		col = PALETTE.emerald -- 383
	elseif p.hasBottle then -- 383
		posture = assistHintsEnabled and getActiveTarget():adaptHintSentence(inputMode == "kbm" and "手持陶瓶 · 按住 [F] 或左键瞄投" or "手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 385
		col = PALETTE.amberCore -- 392
	end -- 392
	texts:put( -- 394
		"xs", -- 394
		posture, -- 394
		bx + 44, -- 394
		by + 12, -- 394
		toColor(col), -- 394
		0, -- 394
		0.5, -- 394
		"Left", -- 394
		0.6, -- 394
		alpha, -- 394
		0.08 -- 394
	) -- 394
end -- 351
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible, pointerUi, pointerInside) -- 397
	if pointerInside == nil then -- 397
		pointerInside = false -- 410
	end -- 410
	local theme = themeOf(p.room.key) -- 412
	local rx = w - 32 - safe.right - (touchOverlayVisible and 208 or 0) -- 413
	local cy = h - 44 - safe.top -- 414
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc / 点击 暂歇" -- 415
	local box = self:getChapterPauseRect(w, h, safe, touchOverlayVisible) -- 416
	local hover = inputMode == "kbm" and not touchOverlayVisible and pointerInside and pointerUi ~= nil and box.width > 0 and box:containsPoint(pointerUi) -- 417
	drawSilkVeil( -- 420
		uiDraw, -- 420
		uiArt, -- 420
		"hud_chap_veil", -- 420
		rx - 82, -- 420
		cy, -- 420
		240, -- 420
		44, -- 420
		hover and PALETTE.inkWarm or PALETTE.inkWash, -- 420
		(hover and 0.72 or 0.44) * alpha, -- 420
		-1 -- 420
	) -- 420
	if hover then -- 420
		uiInkDraw:drawRect( -- 422
			box, -- 422
			Color(0, 0, 0, 0), -- 422
			0.9, -- 422
			toColor(PALETTE.amber, 175 * alpha) -- 422
		) -- 422
	end -- 422
	texts:put( -- 424
		"xs", -- 424
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 424
		rx, -- 424
		touchOverlayVisible and cy or cy + 9, -- 424
		toColor(PALETTE.textBright), -- 424
		1, -- 424
		0.5, -- 424
		"Right", -- 424
		1.2, -- 424
		alpha, -- 424
		0.08 -- 424
	) -- 424
	if not touchOverlayVisible then -- 424
		texts:put( -- 426
			"xs", -- 426
			pauseTip, -- 426
			rx, -- 426
			cy - 11, -- 426
			toColor(hover and PALETTE.amberCore or PALETTE.textDim), -- 426
			1, -- 426
			0.5, -- 426
			"Right", -- 426
			1, -- 426
			(hover and 0.98 or 0.78) * alpha, -- 426
			0.08 -- 426
		) -- 426
	end -- 426
end -- 397
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 430
	local touchMode = inputMode == "touch" -- 444
	local talentOffers = p:getStoryTalentOffers() -- 445
	if not self.roguelikeUiHandled and #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 445
		local boxes = self:talentCardRects( -- 447
			w, -- 447
			h, -- 447
			#talentOffers, -- 447
			touchMode, -- 447
			safe.top -- 447
		) -- 447
		local cx = w * 0.5 -- 448
		local titleY = h - 54 - safe.top -- 449
		local talentHint = inputMode == "gamepad" and "护送本领三选一 · LB/RB 择项 · L3 确认或点选" or (touchMode and "护送本领三选一 · 轻触卡面习得" or "护送本领三选一 · 按 1 / 2 / 3 或点击习得") -- 450
		drawSilkVeil( -- 455
			uiDraw, -- 455
			uiArt, -- 455
			"hud_talent_head_veil", -- 455
			cx, -- 455
			titleY, -- 455
			410, -- 455
			26, -- 455
			PALETTE.inkWash, -- 455
			0.72 * alpha, -- 455
			-1 -- 455
		) -- 455
		drawHairline( -- 456
			uiInkDraw, -- 456
			uiArt, -- 456
			"hud_talent_head_line", -- 456
			cx, -- 456
			titleY + 13, -- 456
			330, -- 456
			PALETTE.amber, -- 456
			0.52 * alpha, -- 456
			true, -- 456
			2 -- 456
		) -- 456
		texts:put( -- 457
			"xs", -- 457
			talentHint, -- 457
			cx, -- 457
			titleY, -- 457
			toColor(PALETTE.amberCore), -- 457
			0.5, -- 457
			0.5, -- 457
			"Center", -- 457
			1.2, -- 457
			alpha, -- 457
			0.08 -- 457
		) -- 457
		local ti = 0 -- 459
		do -- 459
			ti = 0 -- 460
			while ti < #talentOffers do -- 460
				local box = boxes[ti + 1] -- 461
				local bx = box.x -- 462
				local by = box.y -- 463
				local bh = box.height -- 464
				local cy = by + bh * 0.5 -- 465
				local gpFocus = inputMode == "gamepad" and ti == self.talentSelected -- 466
				local borderCol = gpFocus and PALETTE.rouge or PALETTE.amber -- 467
				uiDraw:drawRect( -- 468
					box, -- 469
					toColor( -- 470
						gpFocus and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 470
						math.floor((gpFocus and 235 or 215) * alpha + 0.5) -- 470
					), -- 470
					gpFocus and 1.5 or 0.9, -- 471
					toColor( -- 472
						borderCol, -- 472
						math.floor((gpFocus and 235 or 185) * alpha + 0.5) -- 472
					) -- 472
				) -- 472
				if inputMode == "kbm" then -- 472
					drawSilkKeycap( -- 475
						uiInkDraw, -- 475
						texts, -- 475
						bx + 8, -- 475
						cy - 11, -- 475
						22, -- 475
						22, -- 475
						"" .. tostring(ti + 1), -- 475
						borderCol, -- 475
						alpha, -- 475
						true -- 475
					) -- 475
					texts:put( -- 476
						"xs", -- 476
						talentNames[talentOffers[ti + 1]], -- 476
						bx + 38, -- 476
						cy, -- 476
						toColor(PALETTE.textBright), -- 476
						0, -- 476
						0.5, -- 476
						"Left", -- 476
						0.6, -- 476
						alpha, -- 476
						0.08 -- 476
					) -- 476
				else -- 476
					drawBlossomDot( -- 478
						uiInkDraw, -- 478
						uiArt, -- 478
						"hud_talent_dot_" .. tostring(ti), -- 478
						bx + 18, -- 478
						cy, -- 478
						gpFocus and 12 or 8, -- 478
						borderCol, -- 478
						alpha, -- 478
						4 -- 478
					) -- 478
					texts:put( -- 479
						"xs", -- 479
						talentNames[talentOffers[ti + 1]], -- 479
						bx + 34, -- 479
						cy, -- 479
						toColor(PALETTE.textBright), -- 479
						0, -- 479
						0.5, -- 479
						"Left", -- 479
						0.6, -- 479
						alpha, -- 479
						0.08 -- 479
					) -- 479
				end -- 479
				ti = ti + 1 -- 460
			end -- 460
		end -- 460
	end -- 460
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 460
		local g = p.room.story.gate -- 488
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 488
			local bw = 400 -- 490
			local cx = w * 0.5 -- 491
			local by = h - 64 - safe.top -- 492
			local tied = p.phase == "gate-hand" -- 493
			local ratio = tied and 1 or math.max( -- 494
				0, -- 494
				math.min( -- 494
					1, -- 494
					p.handTicks / math.max(1, p.handNeedTicks) -- 494
				) -- 494
			) -- 494
			local holdInteractKey = getActiveTarget():adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 495
			local reholdInteractKey = getActiveTarget():adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 496
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 497
			drawSilkVeil( -- 501
				uiDraw, -- 501
				uiArt, -- 501
				"hud_hand_veil", -- 501
				cx, -- 501
				by + 18, -- 501
				bw + 90, -- 501
				48, -- 501
				PALETTE.inkWash, -- 501
				0.76 * alpha, -- 501
				-1 -- 501
			) -- 501
			drawHairline( -- 502
				uiInkDraw, -- 502
				uiArt, -- 502
				"hud_hand_top", -- 502
				cx, -- 502
				by + 39, -- 502
				bw - 20, -- 502
				PALETTE.amber, -- 502
				0.55 * alpha, -- 502
				false, -- 502
				2 -- 502
			) -- 502
			texts:put( -- 503
				"xs", -- 503
				label, -- 503
				cx, -- 503
				by + 26, -- 503
				toColor(PALETTE.textBright), -- 503
				0.5, -- 503
				0.5, -- 503
				"Center", -- 503
				1.8, -- 503
				alpha, -- 503
				0.08 -- 503
			) -- 503
			local pbw = bw - 80 -- 505
			local pbx = cx - pbw * 0.5 -- 506
			local pby = by + 9 -- 507
			uiInkDraw:drawSegment( -- 508
				Vec2(pbx, pby), -- 508
				Vec2(pbx + pbw, pby), -- 508
				1.4, -- 508
				toColor(PALETTE.silkDim, 115 * alpha) -- 508
			) -- 508
			if ratio > 0.002 then -- 508
				uiInkDraw:drawSegment( -- 510
					Vec2(pbx, pby), -- 510
					Vec2(pbx + pbw * ratio, pby), -- 510
					2.8, -- 510
					toColor(PALETTE.amber, 230 * alpha) -- 510
				) -- 510
				uiInkDraw:drawSegment( -- 511
					Vec2(pbx, pby), -- 511
					Vec2(pbx + pbw * ratio, pby), -- 511
					1, -- 511
					toColor(PALETTE.amberCore, 165 * alpha) -- 511
				) -- 511
			end -- 511
			uiArt:tryPlace( -- 513
				"ink_enso_fine", -- 513
				"hand_knock_1", -- 513
				pbx + pbw * 0.62, -- 513
				pby, -- 513
				11, -- 513
				11, -- 513
				{ -- 513
					color = toColor(PALETTE.amber), -- 514
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 514
					layer = 3 -- 514
				} -- 514
			) -- 514
			uiArt:tryPlace( -- 516
				"ink_enso_fine", -- 516
				"hand_knock_2", -- 516
				pbx + pbw * 0.72, -- 516
				pby, -- 516
				11, -- 516
				11, -- 516
				{ -- 516
					color = toColor(PALETTE.amber), -- 517
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 517
					layer = 3 -- 517
				} -- 517
			) -- 517
		end -- 517
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 517
			local bw = 400 -- 521
			local cx = w * 0.5 -- 522
			local by = h - 64 - safe.top -- 523
			local ratio = math.max( -- 524
				0, -- 524
				math.min( -- 524
					1, -- 524
					p.gateTick / math.max(1, g.holdTicks) -- 524
				) -- 524
			) -- 524
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 525
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 526
			drawSilkVeil( -- 528
				uiDraw, -- 528
				uiArt, -- 528
				"hud_gate_veil", -- 528
				cx, -- 528
				by + 18, -- 528
				bw + 90, -- 528
				48, -- 528
				PALETTE.inkWash, -- 528
				0.76 * alpha, -- 528
				-1 -- 528
			) -- 528
			drawHairline( -- 529
				uiInkDraw, -- 529
				uiArt, -- 529
				"hud_gate_top", -- 529
				cx, -- 529
				by + 39, -- 529
				bw - 20, -- 529
				PALETTE.rougeSoft, -- 529
				0.55 * alpha, -- 529
				false, -- 529
				2 -- 529
			) -- 529
			local idleNeedConfirmLabel = assistHintsEnabled and getActiveTarget():adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 531
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 534
			texts:put( -- 537
				"xs", -- 537
				label, -- 537
				cx, -- 537
				by + 26, -- 537
				toColor(PALETTE.textBright), -- 537
				0.5, -- 537
				0.5, -- 537
				"Center", -- 537
				1.8, -- 537
				alpha, -- 537
				0.08 -- 537
			) -- 537
			local pbw = bw - 80 -- 539
			local pbx = cx - pbw * 0.5 -- 540
			local pby = by + 9 -- 541
			uiInkDraw:drawSegment( -- 542
				Vec2(pbx, pby), -- 542
				Vec2(pbx + pbw, pby), -- 542
				1.4, -- 542
				toColor(PALETTE.silkDim, 115 * alpha) -- 542
			) -- 542
			if ratio > 0.002 then -- 542
				uiInkDraw:drawSegment( -- 544
					Vec2(pbx, pby), -- 544
					Vec2(pbx + pbw * ratio, pby), -- 544
					2.8, -- 544
					toColor(PALETTE.rouge, 230 * alpha) -- 544
				) -- 544
				uiInkDraw:drawSegment( -- 545
					Vec2(pbx, pby), -- 545
					Vec2(pbx + pbw * ratio, pby), -- 545
					1, -- 545
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 545
				) -- 545
			end -- 545
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 547
			local k = 0 -- 548
			do -- 548
				k = 0 -- 549
				while k < #waves do -- 549
					local wx = pbx + pbw * waves[k + 1] -- 550
					local passed = p.gateSpawned > k -- 551
					if passed then -- 551
						drawBlossomDot( -- 553
							uiInkDraw, -- 553
							uiArt, -- 553
							"gate_wave_" .. tostring(k), -- 553
							wx, -- 553
							pby, -- 553
							10, -- 553
							PALETTE.moonPale, -- 553
							0.92 * alpha, -- 553
							3 -- 553
						) -- 553
					else -- 553
						uiArt:tryPlace( -- 555
							"ink_enso_fine", -- 555
							"gate_wave_" .. tostring(k), -- 555
							wx, -- 555
							pby, -- 555
							11, -- 555
							11, -- 555
							{ -- 555
								color = toColor(PALETTE.rouge), -- 556
								opacity = 0.84 * alpha, -- 556
								layer = 3 -- 556
							} -- 556
						) -- 556
					end -- 556
					k = k + 1 -- 549
				end -- 549
			end -- 549
		end -- 549
		return -- 561
	end -- 561
	if not assistHintsEnabled then -- 561
		return -- 565
	end -- 565
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 565
		local cx = w * 0.5 -- 568
		local by = h - 44 - safe.top -- 569
		local step1 = p.cartDocked -- 570
		local ____temp_6 -- 571
		if p.room.key == "checkpoint" then -- 571
			____temp_6 = p.gateOpen -- 571
		else -- 571
			____temp_6 = p.checkpoint >= p.room.arch.x1 -- 571
		end -- 571
		local step2 = ____temp_6 -- 571
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 572
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 573
		drawSilkVeil( -- 575
			uiDraw, -- 575
			uiArt, -- 575
			"hud_obj_veil", -- 575
			cx, -- 575
			by, -- 575
			380, -- 575
			34, -- 575
			PALETTE.inkWash, -- 575
			0.58 * alpha, -- 575
			-1 -- 575
		) -- 575
		local x1 = cx - 134 -- 577
		if step1 then -- 577
			drawBlossomDot( -- 579
				uiInkDraw, -- 579
				uiArt, -- 579
				"obj_m1", -- 579
				x1, -- 579
				by, -- 579
				11, -- 579
				PALETTE.emerald, -- 579
				0.94 * alpha, -- 579
				3 -- 579
			) -- 579
		else -- 579
			uiArt:tryPlace( -- 581
				"ink_enso_fine", -- 581
				"obj_m1", -- 581
				x1, -- 581
				by, -- 581
				11, -- 581
				11, -- 581
				{ -- 581
					color = toColor(PALETTE.silkLine), -- 581
					opacity = 0.72 * alpha, -- 581
					layer = 3 -- 581
				} -- 581
			) -- 581
		end -- 581
		texts:put( -- 583
			"xs", -- 583
			t1, -- 583
			x1 + 13, -- 583
			by, -- 583
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 583
			0, -- 583
			0.5, -- 583
			"Left", -- 583
			1, -- 583
			alpha, -- 583
			0.08 -- 583
		) -- 583
		local x2 = cx + 18 -- 585
		if step2 then -- 585
			drawBlossomDot( -- 587
				uiInkDraw, -- 587
				uiArt, -- 587
				"obj_m2", -- 587
				x2, -- 587
				by, -- 587
				11, -- 587
				PALETTE.emerald, -- 587
				0.94 * alpha, -- 587
				3 -- 587
			) -- 587
		else -- 587
			uiArt:tryPlace( -- 589
				"ink_enso_fine", -- 589
				"obj_m2", -- 589
				x2, -- 589
				by, -- 589
				11, -- 589
				11, -- 589
				{ -- 589
					color = toColor(PALETTE.silkDim), -- 589
					opacity = 0.62 * alpha, -- 589
					layer = 3 -- 589
				} -- 589
			) -- 589
		end -- 589
		texts:put( -- 591
			"xs", -- 591
			t2, -- 591
			x2 + 13, -- 591
			by, -- 591
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 591
			0, -- 591
			0.5, -- 591
			"Left", -- 591
			1, -- 591
			alpha, -- 591
			0.08 -- 591
		) -- 591
	end -- 591
end -- 430
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe, clickMode, inputMode, pointerUi, pointerInside) -- 595
	if clickMode == nil then -- 595
		clickMode = "none" -- 605
	end -- 605
	if inputMode == nil then -- 605
		inputMode = "kbm" -- 606
	end -- 606
	if pointerInside == nil then -- 606
		pointerInside = false -- 608
	end -- 608
	local bob = math.sin(self.time * 3.4) * 2.8 -- 610
	local viewW = cam.viewW / uiScale -- 611
	local viewH = cam.viewH / uiScale -- 612
	local i = 0 -- 613
	do -- 613
		i = 0 -- 614
		while i < #prompts do -- 614
			local pr = prompts[i + 1] -- 615
			local keyW = math.max( -- 616
				24, -- 616
				visualTextWidth(pr.keyTag, 15) + 16 -- 616
			) -- 616
			local labelW = visualTextWidth(pr.label, 15) -- 617
			local pillW = keyW + labelW + 24 -- 618
			local padX = math.max(115, pillW * 0.5 + 24) -- 619
			local point = cam:worldToScreen(pr.x, pr.y) -- 620
			local sx = math.max( -- 621
				padX + safe.left, -- 621
				math.min(viewW - padX - safe.right, point.x / uiScale) -- 621
			) -- 621
			local sy = math.max( -- 622
				96 + safe.bottom, -- 622
				math.min(viewH - 110 - safe.top, point.y / uiScale + bob) -- 622
			) -- 622
			local px = sx - pillW * 0.5 -- 624
			local py = sy - 12 -- 625
			local pillRect = Rect(px - 10, py - 5, pillW + 20, 34) -- 626
			local hover = i == 0 and clickMode ~= "none" and inputMode == "kbm" and pointerInside and pointerUi ~= nil and pillRect:containsPoint(pointerUi) -- 627
			if i == 0 and clickMode ~= "none" then -- 627
				self.lastInteractPromptRect = pillRect -- 630
				self.lastInteractPromptMode = clickMode -- 631
			end -- 631
			local accent = hover and PALETTE.amberCore or (pr.urgent and PALETTE.rouge or PALETTE.silkLine) -- 633
			uiInkDraw:drawSegment( -- 635
				Vec2(sx, sy - 14), -- 635
				Vec2(sx, sy - 27), -- 635
				0.8, -- 635
				toColor(accent, 135 * alpha) -- 635
			) -- 635
			drawBlossomDot( -- 636
				uiInkDraw, -- 636
				uiArt, -- 636
				"wp_anchor_" .. tostring(i), -- 636
				sx, -- 636
				sy - 28, -- 636
				7, -- 636
				accent, -- 636
				0.85 * alpha, -- 636
				3 -- 636
			) -- 636
			drawSilkVeil( -- 638
				uiDraw, -- 638
				uiArt, -- 638
				"wp_bg_" .. tostring(i), -- 638
				sx, -- 638
				py + 12, -- 638
				pillW + 40, -- 638
				32, -- 638
				hover and PALETTE.inkWarm or PALETTE.inkWash, -- 638
				(hover and 0.9 or 0.78) * alpha, -- 638
				0 -- 638
			) -- 638
			if hover then -- 638
				uiInkDraw:drawRect( -- 640
					pillRect, -- 640
					Color(0, 0, 0, 0), -- 640
					1, -- 640
					toColor(PALETTE.amberCore, 210 * alpha) -- 640
				) -- 640
			end -- 640
			drawHairline( -- 642
				uiInkDraw, -- 642
				uiArt, -- 642
				"wp_line_" .. tostring(i), -- 642
				sx, -- 642
				py + 24, -- 642
				pillW + 4, -- 642
				accent, -- 642
				(hover and 0.78 or 0.45) * alpha, -- 642
				false, -- 642
				2 -- 642
			) -- 642
			drawSilkKeycap( -- 643
				uiInkDraw, -- 643
				texts, -- 643
				px + 2, -- 643
				py + 2, -- 643
				keyW, -- 643
				20, -- 643
				pr.keyTag, -- 643
				accent, -- 643
				alpha, -- 643
				pr.urgent or hover -- 643
			) -- 643
			texts:put( -- 644
				"xs", -- 644
				pr.label, -- 644
				px + keyW + 12, -- 644
				py + 12, -- 644
				toColor(hover and PALETTE.amberCore or PALETTE.textBright), -- 644
				0, -- 644
				0.5, -- 644
				"Left", -- 644
				0.8, -- 644
				alpha, -- 644
				0.08 -- 644
			) -- 644
			i = i + 1 -- 614
		end -- 614
	end -- 614
end -- 595
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 648
	local mx = p.aimX / uiScale -- 658
	local my = p.aimY / uiScale -- 659
	if mx <= 0 and my <= 0 then -- 659
		return -- 661
	end -- 661
	if p.childMode then -- 661
		local aiming = p.room.key == "village" and p.hasBottle -- 665
		if touchMode and (not aiming or p.aimHold <= 0) then -- 665
			return -- 667
		end -- 667
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 669
		uiInkDraw:drawDot( -- 670
			Vec2(mx, my), -- 670
			aiming and 2 or 1.6, -- 670
			toColor(col, aiming and 215 or 120) -- 670
		) -- 670
		if aiming then -- 670
			local sz = p.aimHold > 0 and 32 or 24 -- 672
			uiArt:tryPlace( -- 673
				"ink_enso_fine", -- 673
				"reticle_child", -- 673
				mx, -- 673
				my, -- 673
				sz, -- 673
				sz, -- 673
				{ -- 673
					color = toColor(PALETTE.amberCore), -- 674
					opacity = 0.82, -- 674
					angle = self.time * 24, -- 674
					layer = 5 -- 674
				} -- 674
			) -- 674
		end -- 674
		return -- 677
	end -- 677
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 680
	local onEnemy = false -- 681
	local i = 0 -- 682
	do -- 682
		i = 0 -- 683
		while i < #p.enemies do -- 683
			local e = p.enemies[i + 1] -- 684
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 685
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 685
				onEnemy = true -- 687
			end -- 687
			i = i + 1 -- 683
		end -- 683
	end -- 683
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 691
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 692
	local arm = onEnemy and 8.5 or 9.5 -- 693
	local bg = Color(10, 12, 18, 160) -- 694
	uiInkDraw:drawSegment( -- 696
		Vec2(mx - gap - arm, my), -- 696
		Vec2(mx - gap, my), -- 696
		2.1, -- 696
		bg -- 696
	) -- 696
	uiInkDraw:drawSegment( -- 697
		Vec2(mx + gap, my), -- 697
		Vec2(mx + gap + arm, my), -- 697
		2.1, -- 697
		bg -- 697
	) -- 697
	uiInkDraw:drawSegment( -- 698
		Vec2(mx, my - gap - arm), -- 698
		Vec2(mx, my - gap), -- 698
		2.1, -- 698
		bg -- 698
	) -- 698
	uiInkDraw:drawSegment( -- 699
		Vec2(mx, my + gap), -- 699
		Vec2(mx, my + gap + arm), -- 699
		2.1, -- 699
		bg -- 699
	) -- 699
	uiInkDraw:drawSegment( -- 701
		Vec2(mx - gap - arm, my), -- 701
		Vec2(mx - gap, my), -- 701
		1.1, -- 701
		toColor(col, 230) -- 701
	) -- 701
	uiInkDraw:drawSegment( -- 702
		Vec2(mx + gap, my), -- 702
		Vec2(mx + gap + arm, my), -- 702
		1.1, -- 702
		toColor(col, 230) -- 702
	) -- 702
	uiInkDraw:drawSegment( -- 703
		Vec2(mx, my - gap - arm), -- 703
		Vec2(mx, my - gap), -- 703
		1.1, -- 703
		toColor(col, 230) -- 703
	) -- 703
	uiInkDraw:drawSegment( -- 704
		Vec2(mx, my + gap), -- 704
		Vec2(mx, my + gap + arm), -- 704
		1.1, -- 704
		toColor(col, 230) -- 704
	) -- 704
	uiInkDraw:drawDot( -- 705
		Vec2(mx, my), -- 705
		1.8, -- 705
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 705
	) -- 705
	if onEnemy then -- 705
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 708
		uiArt:tryPlace( -- 709
			"ink_enso_fine", -- 709
			"reticle_lock", -- 709
			mx, -- 709
			my, -- 709
			sz, -- 709
			sz, -- 709
			{ -- 709
				color = toColor(PALETTE.rouge), -- 710
				opacity = 0.88, -- 710
				angle = self.time * 38, -- 710
				layer = 5 -- 710
			} -- 710
		) -- 710
		fillRadialGlow( -- 712
			uiGlow, -- 712
			mx, -- 712
			my, -- 712
			16, -- 712
			16, -- 712
			toColor(PALETTE.rouge, 30), -- 712
			Color(182, 58, 56, 0), -- 712
			10 -- 712
		) -- 712
	end -- 712
end -- 648
return ____exports -- 648