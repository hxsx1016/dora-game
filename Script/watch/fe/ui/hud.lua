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
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 15
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 15
local adaptWorldKeyTag = ____control_prompts.adaptWorldKeyTag -- 15
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
end -- 33
function HudRenderer.prototype.reset(self, p) -- 44
	self.ghostHp = p ~= nil and p.hp or 3 -- 45
	self.talentSelected = 0 -- 46
end -- 44
function HudRenderer.prototype.update(self, dt, p) -- 49
	self.time = self.time + dt -- 50
	if self.ghostHp > p.hp then -- 51
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 52
	else -- 52
		self.ghostHp = p.hp -- 54
	end -- 54
end -- 49
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible) -- 58
	if assistHintsEnabled == nil then -- 69
		assistHintsEnabled = false -- 69
	end -- 69
	if suppressReticle == nil then -- 70
		suppressReticle = false -- 70
	end -- 70
	if inputMode == nil then -- 71
		inputMode = "kbm" -- 71
	end -- 71
	if gamepadLayout == nil then -- 72
		gamepadLayout = "xbox" -- 72
	end -- 72
	if safe == nil then -- 73
		safe = ZERO_SAFE_INSETS -- 73
	end -- 73
	if retryHoldProgress == nil then -- 74
		retryHoldProgress = 0 -- 74
	end -- 74
	if touchOverlayVisible == nil then -- 75
		touchOverlayVisible = false -- 75
	end -- 75
	local w = cam.viewW / uiScale -- 77
	local h = cam.viewH / uiScale -- 78
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 79
	if hudAlpha > 0.05 then -- 81
		if p.childMode then -- 82
			self:drawChildStatus( -- 83
				uiDraw, -- 83
				uiInkDraw, -- 83
				uiArt, -- 83
				texts, -- 83
				p, -- 83
				h, -- 83
				hudAlpha, -- 83
				assistHintsEnabled, -- 83
				inputMode, -- 83
				gamepadLayout, -- 83
				safe -- 83
			) -- 83
		else -- 83
			self:drawSoldierStatus( -- 85
				uiDraw, -- 85
				uiInkDraw, -- 85
				uiArt, -- 85
				texts, -- 85
				p, -- 85
				h, -- 85
				hudAlpha, -- 85
				assistHintsEnabled, -- 85
				inputMode, -- 85
				gamepadLayout, -- 85
				safe -- 85
			) -- 85
		end -- 85
		self:drawChapterBadge( -- 88
			uiDraw, -- 88
			uiArt, -- 88
			texts, -- 88
			p, -- 88
			w, -- 88
			h, -- 88
			hudAlpha, -- 88
			inputMode, -- 88
			safe, -- 88
			touchOverlayVisible -- 88
		) -- 88
		self:drawContextualObjective( -- 89
			uiDraw, -- 89
			uiInkDraw, -- 89
			uiArt, -- 89
			texts, -- 89
			p, -- 89
			w, -- 89
			h, -- 89
			hudAlpha, -- 89
			assistHintsEnabled, -- 89
			inputMode, -- 89
			gamepadLayout, -- 89
			safe -- 89
		) -- 89
		if assistHintsEnabled then -- 91
			local prompt = deriveWorldPrompt(p) -- 92
			if prompt ~= nil then -- 93
				local adapted = { -- 94
					x = prompt.x, -- 95
					y = prompt.y, -- 96
					keyTag = adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout), -- 97
					label = prompt.label, -- 98
					urgent = prompt.urgent, -- 99
					progress = prompt.progress -- 100
				} -- 100
				self:drawWorldPrompts( -- 102
					uiDraw, -- 102
					uiInkDraw, -- 102
					uiArt, -- 102
					texts, -- 102
					{adapted}, -- 102
					cam, -- 102
					hudAlpha, -- 102
					uiScale, -- 102
					safe -- 102
				) -- 102
			end -- 102
		end -- 102
		if vfx.deflectFlash > 0.25 then -- 106
			local dx = cam:sx(vfx.deflectX) / uiScale -- 107
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 108
			texts:put( -- 109
				"sm", -- 109
				"掩体挡下", -- 109
				dx, -- 109
				dy, -- 109
				toColor(PALETTE.textBright), -- 109
				0.5, -- 109
				0.5, -- 109
				"Center", -- 109
				2, -- 109
				vfx.deflectFlash, -- 109
				0.1 -- 109
			) -- 109
		end -- 109
	end -- 109
	if retryHoldProgress > 0.02 then -- 114
		local cx = w * 0.5 -- 115
		local cy = h - 32 - safe.top -- 116
		local bw = 220 -- 117
		drawSilkVeil( -- 118
			uiDraw, -- 118
			uiArt, -- 118
			"hud_retry_hold_veil", -- 118
			cx, -- 118
			cy, -- 118
			bw + 60, -- 118
			34, -- 118
			PALETTE.inkWarm, -- 118
			0.84, -- 118
			2 -- 118
		) -- 118
		texts:put( -- 119
			"xs", -- 119
			"长按 BACK 重试检查点", -- 119
			cx, -- 119
			cy + 7, -- 119
			toColor(PALETTE.amberCore), -- 119
			0.5, -- 119
			0.5, -- 119
			"Center", -- 119
			1, -- 119
			0.96, -- 119
			0.08 -- 119
		) -- 119
		local x0 = cx - bw * 0.44 -- 120
		local x1 = cx + bw * 0.44 -- 121
		uiInkDraw:drawSegment( -- 122
			Vec2(x0, cy - 8), -- 122
			Vec2(x1, cy - 8), -- 122
			1.4, -- 122
			toColor(PALETTE.silkDim, 120) -- 122
		) -- 122
		uiInkDraw:drawSegment( -- 123
			Vec2(x0, cy - 8), -- 123
			Vec2( -- 123
				x0 + (x1 - x0) * math.min(1, retryHoldProgress), -- 123
				cy - 8 -- 123
			), -- 123
			2.8, -- 123
			toColor(PALETTE.rouge, 235) -- 123
		) -- 123
	end -- 123
	if not suppressReticle then -- 126
		self:drawReticleOverlay( -- 127
			uiInkDraw, -- 127
			uiArt, -- 127
			uiGlow, -- 127
			p, -- 127
			cam, -- 127
			vfx, -- 127
			letterboxFrac, -- 127
			uiScale, -- 127
			inputMode == "touch" -- 127
		) -- 127
	end -- 127
end -- 58
function HudRenderer.prototype.talentCardRects(self, w, h, count, touchMode, safeTop) -- 132
	if touchMode == nil then -- 132
		touchMode = false -- 132
	end -- 132
	if safeTop == nil then -- 132
		safeTop = 0 -- 132
	end -- 132
	if self.talentRectProvider ~= nil then -- 133
		return self:talentRectProvider( -- 134
			w, -- 134
			h, -- 134
			count, -- 134
			touchMode, -- 134
			safeTop -- 134
		) -- 134
	end -- 134
	local out = {} -- 136
	if count <= 0 then -- 137
		return out -- 138
	end -- 138
	local cardW = touchMode and 212 or 204 -- 140
	local cardH = touchMode and 50 or 38 -- 141
	local gap = 14 -- 142
	local totalW = count * cardW + (count - 1) * gap -- 143
	local startX = (w - totalW) * 0.5 -- 144
	local y = h - (touchMode and 132 or 120) - safeTop -- 145
	local i = 0 -- 146
	do -- 146
		i = 0 -- 147
		while i < count do -- 147
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 148
			i = i + 1 -- 147
		end -- 147
	end -- 147
	return out -- 150
end -- 132
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, touchMode) -- 154
	if touchMode == nil then -- 163
		touchMode = false -- 163
	end -- 163
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 165
		self:drawReticle( -- 167
			uiInkDraw, -- 167
			uiArt, -- 167
			uiGlow, -- 167
			p, -- 167
			cam, -- 167
			vfx, -- 167
			uiScale, -- 167
			touchMode -- 167
		) -- 167
	end -- 167
end -- 154
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 171
	local bx = 28 + safe.left -- 184
	local by = h - 72 - safe.top -- 185
	local lowHp = p.hp <= 1 -- 186
	local segCount = math.max(1, p.maxHp) -- 188
	local segW = segCount >= 5 and 42 or 54 -- 189
	local segH = 9 -- 190
	local gap = segCount >= 5 and 6 or 8 -- 191
	local veilW = math.max(340, 124 + segCount * (segW + gap)) -- 192
	drawSilkVeil( -- 193
		uiDraw, -- 193
		uiArt, -- 193
		"hud_soldier_veil", -- 193
		bx + veilW * 0.44, -- 193
		by + 24, -- 193
		veilW, -- 193
		56, -- 193
		PALETTE.inkWash, -- 193
		0.62 * alpha, -- 193
		-1 -- 193
	) -- 193
	texts:put( -- 194
		"md", -- 194
		"戍", -- 194
		bx + 16, -- 194
		by + 25, -- 194
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 194
		0.5, -- 194
		0.5, -- 194
		"Center", -- 194
		0, -- 194
		alpha, -- 194
		0.1 -- 194
	) -- 194
	uiInkDraw:drawSegment( -- 195
		Vec2(bx + 32, by + 9), -- 195
		Vec2(bx + 32, by + 40), -- 195
		0.8, -- 195
		toColor(PALETTE.silkDim, 130 * alpha) -- 195
	) -- 195
	texts:put( -- 196
		"xs", -- 196
		"周戍 · 体力", -- 196
		bx + 44, -- 196
		by + 36, -- 196
		toColor(PALETTE.textMid), -- 196
		0, -- 196
		0.5, -- 196
		"Left", -- 196
		1.4, -- 196
		alpha, -- 196
		0.08 -- 196
	) -- 196
	local barX = bx + 44 -- 198
	local barY = by + 16 -- 199
	local i = 0 -- 201
	do -- 201
		i = 0 -- 202
		while i < segCount do -- 202
			local sx = barX + i * (segW + gap) -- 203
			local scx = sx + segW * 0.5 -- 204
			if not uiArt:tryPlace( -- 205
				"ink_bamboo_slot", -- 205
				"hp_slot_" .. tostring(i), -- 205
				scx, -- 205
				barY, -- 205
				segW, -- 205
				segH, -- 205
				{ -- 205
					color = toColor(PALETTE.silkDim), -- 206
					opacity = 0.72 * alpha, -- 206
					layer = 1 -- 206
				} -- 206
			) then -- 206
				uiInkDraw:drawRect( -- 208
					Rect(sx, barY - 3, segW, 6), -- 208
					Color(0, 0, 0, 0), -- 208
					0.8, -- 208
					toColor(PALETTE.silkDim, 145 * alpha) -- 208
				) -- 208
			end -- 208
			if self.ghostHp > i and self.ghostHp > p.hp then -- 210
				local frac = math.min(1, self.ghostHp - i) -- 211
				uiInkDraw:drawRect( -- 212
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 212
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 212
				) -- 212
			end -- 212
			if p.hp > i then -- 214
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 215
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 216
				if not uiArt:tryPlace( -- 217
					"ink_bamboo_slip", -- 217
					"hp_fill_" .. tostring(i), -- 217
					scx, -- 217
					barY, -- 217
					segW, -- 217
					segH, -- 217
					{ -- 217
						color = toColor(fillCol), -- 218
						opacity = 0.94 * alpha * pulse, -- 218
						layer = 2 -- 218
					} -- 218
				) then -- 218
					uiInkDraw:drawRect( -- 220
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 220
						toColor(fillCol, 230 * alpha * pulse) -- 220
					) -- 220
				end -- 220
			end -- 220
			i = i + 1 -- 202
		end -- 202
	end -- 202
	local covX = barX + segCount * (segW + gap) + 6 -- 225
	local hasAliveEnemy = false -- 226
	do -- 226
		i = 0 -- 227
		while i < #p.enemies do -- 227
			if p.enemies[i + 1].alive then -- 228
				hasAliveEnemy = true -- 229
				break -- 230
			end -- 230
			i = i + 1 -- 227
		end -- 227
	end -- 227
	if p.coverHug then -- 233
		if hasAliveEnemy and not p.coverBlocking then -- 234
			uiInkDraw:drawRect( -- 235
				Rect(covX, barY - 9, 72, 18), -- 235
				toColor(PALETTE.inkWarm, 185 * alpha), -- 235
				0.8, -- 235
				toColor(PALETTE.amber, 200 * alpha) -- 235
			) -- 235
			texts:put( -- 236
				"xs", -- 236
				"背向掩体", -- 236
				covX + 36, -- 236
				barY, -- 236
				toColor(PALETTE.amberCore), -- 236
				0.5, -- 236
				0.5, -- 236
				"Center", -- 236
				0.6, -- 236
				alpha, -- 236
				0 -- 236
			) -- 236
		else -- 236
			uiInkDraw:drawRect( -- 238
				Rect(covX, barY - 9, 54, 18), -- 238
				toColor(PALETTE.cyanDim, 165 * alpha), -- 238
				0.8, -- 238
				toColor(PALETTE.cyanCore, 180 * alpha) -- 238
			) -- 238
			texts:put( -- 239
				"xs", -- 239
				"掩体中", -- 239
				covX + 27, -- 239
				barY, -- 239
				toColor(PALETTE.textBright), -- 239
				0.5, -- 239
				0.5, -- 239
				"Center", -- 239
				0.6, -- 239
				alpha, -- 239
				0 -- 239
			) -- 239
		end -- 239
	elseif assistHintsEnabled and p.coverNear then -- 241
		uiInkDraw:drawRect( -- 242
			Rect(covX, barY - 9, 54, 18), -- 242
			Color( -- 242
				14, -- 242
				17, -- 242
				25, -- 242
				math.floor(150 * alpha + 0.5) -- 242
			), -- 242
			0.8, -- 242
			toColor(PALETTE.silkLine, 165 * alpha) -- 242
		) -- 242
		texts:put( -- 243
			"xs", -- 243
			"可贴靠", -- 243
			covX + 27, -- 243
			barY, -- 243
			toColor(PALETTE.textMid), -- 243
			0.5, -- 243
			0.5, -- 243
			"Center", -- 243
			0.6, -- 243
			alpha, -- 243
			0.08 -- 243
		) -- 243
	end -- 243
	local ____p_isCampaign_5 = p.isCampaign -- 246
	if ____p_isCampaign_5 then -- 246
		local ____opt_0 = p.room.campaign -- 246
		local ____temp_4 = (____opt_0 and ____opt_0.chapter) == "S" -- 246
		if not ____temp_4 then -- 246
			local ____opt_2 = p.room.campaign -- 246
			____temp_4 = (____opt_2 and ____opt_2.chapter) == "C" -- 246
		end -- 246
		____p_isCampaign_5 = ____temp_4 -- 246
	end -- 246
	local showCampaignFear = ____p_isCampaign_5 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 246
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" or showCampaignFear then -- 248
		local subY = by - 24 -- 249
		local frozen = p.escort.state == "frozen" -- 250
		local calming = p.escort.state == "calming" -- 251
		drawSilkVeil( -- 253
			uiDraw, -- 253
			uiArt, -- 253
			"hud_fear_veil", -- 253
			bx + 126, -- 253
			subY + 6, -- 253
			260, -- 253
			30, -- 253
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 253
			0.64 * alpha, -- 253
			-1 -- 253
		) -- 253
		texts:put( -- 254
			"xs", -- 254
			"小满 · 惊惧", -- 254
			bx + 14, -- 254
			subY + 6, -- 254
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 254
			0, -- 254
			0.5, -- 254
			"Left", -- 254
			1, -- 254
			alpha, -- 254
			0.08 -- 254
		) -- 254
		local k = 0 -- 256
		do -- 256
			k = 0 -- 257
			while k < FEAR_MAX do -- 257
				local dx = bx + 114 + k * 20 -- 258
				local dy = subY + 6 -- 259
				local lit = k < p.escort.fear -- 260
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 261
				uiArt:tryPlace( -- 262
					"ink_enso_fine", -- 262
					"fear_ring_" .. tostring(k), -- 262
					dx, -- 262
					dy, -- 262
					14, -- 262
					14, -- 262
					{ -- 262
						color = toColor(lit and dc or PALETTE.silkLine), -- 263
						opacity = (lit and 0.92 or 0.64) * alpha, -- 263
						layer = 2 -- 263
					} -- 263
				) -- 263
				if lit then -- 265
					drawBlossomDot( -- 266
						uiInkDraw, -- 266
						uiArt, -- 266
						"fear_dot_" .. tostring(k), -- 266
						dx, -- 266
						dy, -- 266
						10, -- 266
						dc, -- 266
						0.96 * alpha, -- 266
						3 -- 266
					) -- 266
				end -- 266
				k = k + 1 -- 257
			end -- 257
		end -- 257
		if frozen then -- 270
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 271
			if assistHintsEnabled then -- 272
				local calmKey = adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 273
				local keyW = math.max( -- 274
					22, -- 274
					visualTextWidth(calmKey, 15) + 10 -- 274
				) -- 274
				drawSilkKeycap( -- 275
					uiInkDraw, -- 275
					texts, -- 275
					bx + 170, -- 275
					subY - 5, -- 275
					keyW, -- 275
					22, -- 275
					calmKey, -- 275
					PALETTE.rouge, -- 275
					alpha * pulse, -- 275
					true -- 275
				) -- 275
				texts:put( -- 276
					"xs", -- 276
					"轻敲安抚", -- 276
					bx + 176 + keyW, -- 276
					subY + 6, -- 276
					toColor(PALETTE.crimsonCore), -- 276
					0, -- 276
					0.5, -- 276
					"Left", -- 276
					0.8, -- 276
					alpha * pulse, -- 276
					0.08 -- 276
				) -- 276
			else -- 276
				texts:put( -- 278
					"xs", -- 278
					"受惊停步", -- 278
					bx + 172, -- 278
					subY + 6, -- 278
					toColor(PALETTE.crimsonCore), -- 278
					0, -- 278
					0.5, -- 278
					"Left", -- 278
					0.8, -- 278
					alpha * pulse, -- 278
					0.08 -- 278
				) -- 278
			end -- 278
		elseif calming then -- 280
			texts:put( -- 281
				"xs", -- 281
				"轻敲安抚中", -- 281
				bx + 172, -- 281
				subY + 6, -- 281
				toColor(PALETTE.emerald), -- 281
				0, -- 281
				0.5, -- 281
				"Left", -- 281
				0.8, -- 281
				alpha, -- 281
				0.08 -- 281
			) -- 281
		end -- 281
	end -- 281
	if not self.roguelikeUiHandled then -- 285
		local ranks = p:getStoryTalentRanks() -- 286
		if ranks ~= nil then -- 287
			local parts = {} -- 288
			if ranks.vitality > 0 then -- 289
				parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 289
			end -- 289
			if ranks.reload > 0 then -- 290
				parts[#parts + 1] = "熟铳" .. tostring(ranks.reload) -- 290
			end -- 290
			if ranks.guard > 0 then -- 291
				parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 291
			end -- 291
			if ranks.craft > 0 then -- 292
				parts[#parts + 1] = "巧手" .. tostring(ranks.craft) -- 292
			end -- 292
			if #parts > 0 then -- 293
				local subY = by - 22 -- 294
				local txt = "本领 · " .. table.concat(parts, " · ") -- 295
				drawSilkVeil( -- 296
					uiDraw, -- 296
					uiArt, -- 296
					"hud_talent_ranks_veil", -- 296
					bx + 126, -- 296
					subY + 6, -- 296
					260, -- 296
					26, -- 296
					PALETTE.inkWash, -- 296
					0.56 * alpha, -- 296
					-1 -- 296
				) -- 296
				texts:put( -- 297
					"xs", -- 297
					txt, -- 297
					bx + 14, -- 297
					subY + 6, -- 297
					toColor(PALETTE.amberCore), -- 297
					0, -- 297
					0.5, -- 297
					"Left", -- 297
					0.8, -- 297
					alpha, -- 297
					0.08 -- 297
				) -- 297
			end -- 297
		elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 299
			local inv = p.run.inventory -- 300
			local items = {} -- 301
			if inv.shield > 0 then -- 302
				items[#items + 1] = "残盾" .. tostring(inv.shield) -- 302
			end -- 302
			if inv.wedge > 0 then -- 303
				items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 303
			end -- 303
			if inv.ammo > 0 then -- 304
				items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 304
			end -- 304
			if inv.scrap > 0 then -- 305
				items[#items + 1] = "木料" .. tostring(inv.scrap) -- 305
			end -- 305
			local companionText = p.run.joined and "小满同行" or "小满等待" -- 306
			local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 307
			local subY = by - 22 -- 308
			drawSilkVeil( -- 309
				uiDraw, -- 309
				uiArt, -- 309
				"hud_camp_veil", -- 309
				bx + 126, -- 309
				subY + 6, -- 309
				260, -- 309
				26, -- 309
				PALETTE.inkWash, -- 309
				0.54 * alpha, -- 309
				-1 -- 309
			) -- 309
			texts:put( -- 310
				"xs", -- 310
				summary, -- 310
				bx + 14, -- 310
				subY + 6, -- 310
				toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 310
				0, -- 310
				0.5, -- 310
				"Left", -- 310
				0.8, -- 310
				alpha, -- 310
				0.08 -- 310
			) -- 310
		end -- 310
	end -- 310
end -- 171
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 315
	local bx = 28 + safe.left -- 328
	local by = h - 68 - safe.top -- 329
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 330
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 331
	drawSilkVeil( -- 333
		uiDraw, -- 333
		uiArt, -- 333
		"hud_child_veil", -- 333
		bx + 144, -- 333
		by + 22, -- 333
		316, -- 333
		48, -- 333
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 333
		0.58 * alpha, -- 333
		-1 -- 333
	) -- 333
	texts:put( -- 334
		"md", -- 334
		alert and "危" or "满", -- 334
		bx + 16, -- 334
		by + 22, -- 334
		toColor(leadCol), -- 334
		0.5, -- 334
		0.5, -- 334
		"Center", -- 334
		0, -- 334
		alpha, -- 334
		0.1 -- 334
	) -- 334
	uiInkDraw:drawSegment( -- 335
		Vec2(bx + 32, by + 7), -- 335
		Vec2(bx + 32, by + 37), -- 335
		0.8, -- 335
		toColor(PALETTE.silkDim, 130 * alpha) -- 335
	) -- 335
	texts:put( -- 336
		"xs", -- 336
		"小满 · 潜行", -- 336
		bx + 44, -- 336
		by + 33, -- 336
		toColor(PALETTE.amberCore), -- 336
		0, -- 336
		0.5, -- 336
		"Left", -- 336
		1.4, -- 336
		alpha, -- 336
		0.08 -- 336
	) -- 336
	local posture = assistHintsEnabled and "轻步前行 · 保持隐蔽" or "轻步前行" -- 338
	local col = PALETTE.textMid -- 339
	if alert then -- 340
		posture = (p.scavChase or p.dogState == "chase") and (assistHintsEnabled and "已被发现 · 速寻隐蔽" or "已被发现") or (assistHintsEnabled and "引起警觉 · 停步蹲伏" or "引起警觉") -- 341
		col = PALETTE.crimsonCore -- 344
	elseif p.player.crouch then -- 345
		posture = assistHintsEnabled and "低姿伏行 · 匿迹于影" or "低姿伏行" -- 346
		col = PALETTE.emerald -- 347
	elseif p.hasBottle then -- 348
		posture = assistHintsEnabled and adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 349
		col = PALETTE.amberCore -- 352
	end -- 352
	texts:put( -- 354
		"xs", -- 354
		posture, -- 354
		bx + 44, -- 354
		by + 12, -- 354
		toColor(col), -- 354
		0, -- 354
		0.5, -- 354
		"Left", -- 354
		0.6, -- 354
		alpha, -- 354
		0.08 -- 354
	) -- 354
end -- 315
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible) -- 357
	local theme = themeOf(p.room.key) -- 369
	local rx = w - 32 - safe.right - (touchOverlayVisible and 208 or 0) -- 370
	local cy = h - 44 - safe.top -- 371
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc 暂歇" -- 372
	drawSilkVeil( -- 374
		uiDraw, -- 374
		uiArt, -- 374
		"hud_chap_veil", -- 374
		rx - 82, -- 374
		cy, -- 374
		240, -- 374
		44, -- 374
		PALETTE.inkWash, -- 374
		0.44 * alpha, -- 374
		-1 -- 374
	) -- 374
	texts:put( -- 375
		"xs", -- 375
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 375
		rx, -- 375
		touchOverlayVisible and cy or cy + 9, -- 375
		toColor(PALETTE.textBright), -- 375
		1, -- 375
		0.5, -- 375
		"Right", -- 375
		1.2, -- 375
		alpha, -- 375
		0.08 -- 375
	) -- 375
	if not touchOverlayVisible then -- 376
		texts:put( -- 377
			"xs", -- 377
			pauseTip, -- 377
			rx, -- 377
			cy - 11, -- 377
			toColor(PALETTE.textDim), -- 377
			1, -- 377
			0.5, -- 377
			"Right", -- 377
			1, -- 377
			0.78 * alpha, -- 377
			0.08 -- 377
		) -- 377
	end -- 377
end -- 357
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 381
	local touchMode = inputMode == "touch" -- 395
	local talentOffers = p:getStoryTalentOffers() -- 396
	if not self.roguelikeUiHandled and #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 397
		local boxes = self:talentCardRects( -- 398
			w, -- 398
			h, -- 398
			#talentOffers, -- 398
			touchMode, -- 398
			safe.top -- 398
		) -- 398
		local cx = w * 0.5 -- 399
		local titleY = h - 54 - safe.top -- 400
		local talentHint = inputMode == "gamepad" and "护送本领三选一 · LB/RB 择项 · L3 确认或点选" or (touchMode and "护送本领三选一 · 轻触卡面习得" or "护送本领三选一 · 按 1 / 2 / 3 或点击习得") -- 401
		drawSilkVeil( -- 406
			uiDraw, -- 406
			uiArt, -- 406
			"hud_talent_head_veil", -- 406
			cx, -- 406
			titleY, -- 406
			410, -- 406
			26, -- 406
			PALETTE.inkWash, -- 406
			0.72 * alpha, -- 406
			-1 -- 406
		) -- 406
		drawHairline( -- 407
			uiInkDraw, -- 407
			uiArt, -- 407
			"hud_talent_head_line", -- 407
			cx, -- 407
			titleY + 13, -- 407
			330, -- 407
			PALETTE.amber, -- 407
			0.52 * alpha, -- 407
			true, -- 407
			2 -- 407
		) -- 407
		texts:put( -- 408
			"xs", -- 408
			talentHint, -- 408
			cx, -- 408
			titleY, -- 408
			toColor(PALETTE.amberCore), -- 408
			0.5, -- 408
			0.5, -- 408
			"Center", -- 408
			1.2, -- 408
			alpha, -- 408
			0.08 -- 408
		) -- 408
		local ti = 0 -- 410
		do -- 410
			ti = 0 -- 411
			while ti < #talentOffers do -- 411
				local box = boxes[ti + 1] -- 412
				local bx = box.x -- 413
				local by = box.y -- 414
				local bh = box.height -- 415
				local cy = by + bh * 0.5 -- 416
				local gpFocus = inputMode == "gamepad" and ti == self.talentSelected -- 417
				local borderCol = gpFocus and PALETTE.rouge or PALETTE.amber -- 418
				uiDraw:drawRect( -- 419
					box, -- 420
					toColor( -- 421
						gpFocus and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 421
						math.floor((gpFocus and 235 or 215) * alpha + 0.5) -- 421
					), -- 421
					gpFocus and 1.5 or 0.9, -- 422
					toColor( -- 423
						borderCol, -- 423
						math.floor((gpFocus and 235 or 185) * alpha + 0.5) -- 423
					) -- 423
				) -- 423
				if inputMode == "kbm" then -- 425
					drawSilkKeycap( -- 426
						uiInkDraw, -- 426
						texts, -- 426
						bx + 8, -- 426
						cy - 11, -- 426
						22, -- 426
						22, -- 426
						"" .. tostring(ti + 1), -- 426
						borderCol, -- 426
						alpha, -- 426
						true -- 426
					) -- 426
					texts:put( -- 427
						"xs", -- 427
						talentNames[talentOffers[ti + 1]], -- 427
						bx + 38, -- 427
						cy, -- 427
						toColor(PALETTE.textBright), -- 427
						0, -- 427
						0.5, -- 427
						"Left", -- 427
						0.6, -- 427
						alpha, -- 427
						0.08 -- 427
					) -- 427
				else -- 427
					drawBlossomDot( -- 429
						uiInkDraw, -- 429
						uiArt, -- 429
						"hud_talent_dot_" .. tostring(ti), -- 429
						bx + 18, -- 429
						cy, -- 429
						gpFocus and 12 or 8, -- 429
						borderCol, -- 429
						alpha, -- 429
						4 -- 429
					) -- 429
					texts:put( -- 430
						"xs", -- 430
						talentNames[talentOffers[ti + 1]], -- 430
						bx + 34, -- 430
						cy, -- 430
						toColor(PALETTE.textBright), -- 430
						0, -- 430
						0.5, -- 430
						"Left", -- 430
						0.6, -- 430
						alpha, -- 430
						0.08 -- 430
					) -- 430
				end -- 430
				ti = ti + 1 -- 411
			end -- 411
		end -- 411
	end -- 411
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 438
		local g = p.room.story.gate -- 439
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 440
			local bw = 400 -- 441
			local cx = w * 0.5 -- 442
			local by = h - 64 - safe.top -- 443
			local tied = p.phase == "gate-hand" -- 444
			local ratio = tied and 1 or math.max( -- 445
				0, -- 445
				math.min( -- 445
					1, -- 445
					p.handTicks / math.max(1, p.handNeedTicks) -- 445
				) -- 445
			) -- 445
			local holdInteractKey = adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 446
			local reholdInteractKey = adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 447
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 448
			drawSilkVeil( -- 452
				uiDraw, -- 452
				uiArt, -- 452
				"hud_hand_veil", -- 452
				cx, -- 452
				by + 18, -- 452
				bw + 90, -- 452
				48, -- 452
				PALETTE.inkWash, -- 452
				0.76 * alpha, -- 452
				-1 -- 452
			) -- 452
			drawHairline( -- 453
				uiInkDraw, -- 453
				uiArt, -- 453
				"hud_hand_top", -- 453
				cx, -- 453
				by + 39, -- 453
				bw - 20, -- 453
				PALETTE.amber, -- 453
				0.55 * alpha, -- 453
				false, -- 453
				2 -- 453
			) -- 453
			texts:put( -- 454
				"xs", -- 454
				label, -- 454
				cx, -- 454
				by + 26, -- 454
				toColor(PALETTE.textBright), -- 454
				0.5, -- 454
				0.5, -- 454
				"Center", -- 454
				1.8, -- 454
				alpha, -- 454
				0.08 -- 454
			) -- 454
			local pbw = bw - 80 -- 456
			local pbx = cx - pbw * 0.5 -- 457
			local pby = by + 9 -- 458
			uiInkDraw:drawSegment( -- 459
				Vec2(pbx, pby), -- 459
				Vec2(pbx + pbw, pby), -- 459
				1.4, -- 459
				toColor(PALETTE.silkDim, 115 * alpha) -- 459
			) -- 459
			if ratio > 0.002 then -- 460
				uiInkDraw:drawSegment( -- 461
					Vec2(pbx, pby), -- 461
					Vec2(pbx + pbw * ratio, pby), -- 461
					2.8, -- 461
					toColor(PALETTE.amber, 230 * alpha) -- 461
				) -- 461
				uiInkDraw:drawSegment( -- 462
					Vec2(pbx, pby), -- 462
					Vec2(pbx + pbw * ratio, pby), -- 462
					1, -- 462
					toColor(PALETTE.amberCore, 165 * alpha) -- 462
				) -- 462
			end -- 462
			uiArt:tryPlace( -- 464
				"ink_enso_fine", -- 464
				"hand_knock_1", -- 464
				pbx + pbw * 0.62, -- 464
				pby, -- 464
				11, -- 464
				11, -- 464
				{ -- 464
					color = toColor(PALETTE.amber), -- 465
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 465
					layer = 3 -- 465
				} -- 465
			) -- 465
			uiArt:tryPlace( -- 467
				"ink_enso_fine", -- 467
				"hand_knock_2", -- 467
				pbx + pbw * 0.72, -- 467
				pby, -- 467
				11, -- 467
				11, -- 467
				{ -- 467
					color = toColor(PALETTE.amber), -- 468
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 468
					layer = 3 -- 468
				} -- 468
			) -- 468
		end -- 468
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 471
			local bw = 400 -- 472
			local cx = w * 0.5 -- 473
			local by = h - 64 - safe.top -- 474
			local ratio = math.max( -- 475
				0, -- 475
				math.min( -- 475
					1, -- 475
					p.gateTick / math.max(1, g.holdTicks) -- 475
				) -- 475
			) -- 475
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 476
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 477
			drawSilkVeil( -- 479
				uiDraw, -- 479
				uiArt, -- 479
				"hud_gate_veil", -- 479
				cx, -- 479
				by + 18, -- 479
				bw + 90, -- 479
				48, -- 479
				PALETTE.inkWash, -- 479
				0.76 * alpha, -- 479
				-1 -- 479
			) -- 479
			drawHairline( -- 480
				uiInkDraw, -- 480
				uiArt, -- 480
				"hud_gate_top", -- 480
				cx, -- 480
				by + 39, -- 480
				bw - 20, -- 480
				PALETTE.rougeSoft, -- 480
				0.55 * alpha, -- 480
				false, -- 480
				2 -- 480
			) -- 480
			local idleNeedConfirmLabel = assistHintsEnabled and adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 482
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 485
			texts:put( -- 488
				"xs", -- 488
				label, -- 488
				cx, -- 488
				by + 26, -- 488
				toColor(PALETTE.textBright), -- 488
				0.5, -- 488
				0.5, -- 488
				"Center", -- 488
				1.8, -- 488
				alpha, -- 488
				0.08 -- 488
			) -- 488
			local pbw = bw - 80 -- 490
			local pbx = cx - pbw * 0.5 -- 491
			local pby = by + 9 -- 492
			uiInkDraw:drawSegment( -- 493
				Vec2(pbx, pby), -- 493
				Vec2(pbx + pbw, pby), -- 493
				1.4, -- 493
				toColor(PALETTE.silkDim, 115 * alpha) -- 493
			) -- 493
			if ratio > 0.002 then -- 494
				uiInkDraw:drawSegment( -- 495
					Vec2(pbx, pby), -- 495
					Vec2(pbx + pbw * ratio, pby), -- 495
					2.8, -- 495
					toColor(PALETTE.rouge, 230 * alpha) -- 495
				) -- 495
				uiInkDraw:drawSegment( -- 496
					Vec2(pbx, pby), -- 496
					Vec2(pbx + pbw * ratio, pby), -- 496
					1, -- 496
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 496
				) -- 496
			end -- 496
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 498
			local k = 0 -- 499
			do -- 499
				k = 0 -- 500
				while k < #waves do -- 500
					local wx = pbx + pbw * waves[k + 1] -- 501
					local passed = p.gateSpawned > k -- 502
					if passed then -- 503
						drawBlossomDot( -- 504
							uiInkDraw, -- 504
							uiArt, -- 504
							"gate_wave_" .. tostring(k), -- 504
							wx, -- 504
							pby, -- 504
							10, -- 504
							PALETTE.moonPale, -- 504
							0.92 * alpha, -- 504
							3 -- 504
						) -- 504
					else -- 504
						uiArt:tryPlace( -- 506
							"ink_enso_fine", -- 506
							"gate_wave_" .. tostring(k), -- 506
							wx, -- 506
							pby, -- 506
							11, -- 506
							11, -- 506
							{ -- 506
								color = toColor(PALETTE.rouge), -- 507
								opacity = 0.84 * alpha, -- 507
								layer = 3 -- 507
							} -- 507
						) -- 507
					end -- 507
					k = k + 1 -- 500
				end -- 500
			end -- 500
		end -- 500
		return -- 512
	end -- 512
	if not assistHintsEnabled then -- 515
		return -- 516
	end -- 516
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 518
		local cx = w * 0.5 -- 519
		local by = h - 44 - safe.top -- 520
		local step1 = p.cartDocked -- 521
		local ____temp_6 -- 522
		if p.room.key == "checkpoint" then -- 522
			____temp_6 = p.gateOpen -- 522
		else -- 522
			____temp_6 = p.checkpoint >= p.room.arch.x1 -- 522
		end -- 522
		local step2 = ____temp_6 -- 522
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 523
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 524
		drawSilkVeil( -- 526
			uiDraw, -- 526
			uiArt, -- 526
			"hud_obj_veil", -- 526
			cx, -- 526
			by, -- 526
			380, -- 526
			34, -- 526
			PALETTE.inkWash, -- 526
			0.58 * alpha, -- 526
			-1 -- 526
		) -- 526
		local x1 = cx - 134 -- 528
		if step1 then -- 529
			drawBlossomDot( -- 530
				uiInkDraw, -- 530
				uiArt, -- 530
				"obj_m1", -- 530
				x1, -- 530
				by, -- 530
				11, -- 530
				PALETTE.emerald, -- 530
				0.94 * alpha, -- 530
				3 -- 530
			) -- 530
		else -- 530
			uiArt:tryPlace( -- 532
				"ink_enso_fine", -- 532
				"obj_m1", -- 532
				x1, -- 532
				by, -- 532
				11, -- 532
				11, -- 532
				{ -- 532
					color = toColor(PALETTE.silkLine), -- 532
					opacity = 0.72 * alpha, -- 532
					layer = 3 -- 532
				} -- 532
			) -- 532
		end -- 532
		texts:put( -- 534
			"xs", -- 534
			t1, -- 534
			x1 + 13, -- 534
			by, -- 534
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 534
			0, -- 534
			0.5, -- 534
			"Left", -- 534
			1, -- 534
			alpha, -- 534
			0.08 -- 534
		) -- 534
		local x2 = cx + 18 -- 536
		if step2 then -- 537
			drawBlossomDot( -- 538
				uiInkDraw, -- 538
				uiArt, -- 538
				"obj_m2", -- 538
				x2, -- 538
				by, -- 538
				11, -- 538
				PALETTE.emerald, -- 538
				0.94 * alpha, -- 538
				3 -- 538
			) -- 538
		else -- 538
			uiArt:tryPlace( -- 540
				"ink_enso_fine", -- 540
				"obj_m2", -- 540
				x2, -- 540
				by, -- 540
				11, -- 540
				11, -- 540
				{ -- 540
					color = toColor(PALETTE.silkDim), -- 540
					opacity = 0.62 * alpha, -- 540
					layer = 3 -- 540
				} -- 540
			) -- 540
		end -- 540
		texts:put( -- 542
			"xs", -- 542
			t2, -- 542
			x2 + 13, -- 542
			by, -- 542
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 542
			0, -- 542
			0.5, -- 542
			"Left", -- 542
			1, -- 542
			alpha, -- 542
			0.08 -- 542
		) -- 542
	end -- 542
end -- 381
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 546
	local bob = math.sin(self.time * 3.4) * 2.8 -- 557
	local viewW = cam.viewW / uiScale -- 558
	local viewH = cam.viewH / uiScale -- 559
	local i = 0 -- 560
	do -- 560
		i = 0 -- 561
		while i < #prompts do -- 561
			local pr = prompts[i + 1] -- 562
			local keyW = math.max( -- 563
				24, -- 563
				visualTextWidth(pr.keyTag, 15) + 16 -- 563
			) -- 563
			local labelW = visualTextWidth(pr.label, 15) -- 564
			local pillW = keyW + labelW + 24 -- 565
			local padX = math.max(115, pillW * 0.5 + 24) -- 566
			local sx = math.max( -- 567
				padX + safe.left, -- 567
				math.min( -- 567
					viewW - padX - safe.right, -- 567
					cam:sx(pr.x) / uiScale -- 567
				) -- 567
			) -- 567
			local sy = math.max( -- 568
				96 + safe.bottom, -- 568
				math.min( -- 568
					viewH - 110 - safe.top, -- 568
					cam:sy(pr.y) / uiScale + bob -- 568
				) -- 568
			) -- 568
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 569
			uiInkDraw:drawSegment( -- 571
				Vec2(sx, sy - 14), -- 571
				Vec2(sx, sy - 27), -- 571
				0.8, -- 571
				toColor(accent, 135 * alpha) -- 571
			) -- 571
			drawBlossomDot( -- 572
				uiInkDraw, -- 572
				uiArt, -- 572
				"wp_anchor_" .. tostring(i), -- 572
				sx, -- 572
				sy - 28, -- 572
				7, -- 572
				accent, -- 572
				0.85 * alpha, -- 572
				3 -- 572
			) -- 572
			local px = sx - pillW * 0.5 -- 574
			local py = sy - 12 -- 575
			drawSilkVeil( -- 577
				uiDraw, -- 577
				uiArt, -- 577
				"wp_bg_" .. tostring(i), -- 577
				sx, -- 577
				py + 12, -- 577
				pillW + 40, -- 577
				32, -- 577
				PALETTE.inkWash, -- 577
				0.78 * alpha, -- 577
				0 -- 577
			) -- 577
			drawHairline( -- 578
				uiInkDraw, -- 578
				uiArt, -- 578
				"wp_line_" .. tostring(i), -- 578
				sx, -- 578
				py + 24, -- 578
				pillW + 4, -- 578
				accent, -- 578
				0.45 * alpha, -- 578
				false, -- 578
				2 -- 578
			) -- 578
			drawSilkKeycap( -- 579
				uiInkDraw, -- 579
				texts, -- 579
				px + 2, -- 579
				py + 2, -- 579
				keyW, -- 579
				20, -- 579
				pr.keyTag, -- 579
				accent, -- 579
				alpha, -- 579
				pr.urgent -- 579
			) -- 579
			texts:put( -- 580
				"xs", -- 580
				pr.label, -- 580
				px + keyW + 12, -- 580
				py + 12, -- 580
				toColor(PALETTE.textBright), -- 580
				0, -- 580
				0.5, -- 580
				"Left", -- 580
				0.8, -- 580
				alpha, -- 580
				0.08 -- 580
			) -- 580
			i = i + 1 -- 561
		end -- 561
	end -- 561
end -- 546
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 584
	local mx = p.aimX / uiScale -- 594
	local my = p.aimY / uiScale -- 595
	if mx <= 0 and my <= 0 then -- 596
		return -- 597
	end -- 597
	if p.childMode then -- 600
		local aiming = p.room.key == "village" and p.hasBottle -- 601
		if touchMode and (not aiming or p.aimHold <= 0) then -- 602
			return -- 603
		end -- 603
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 605
		uiInkDraw:drawDot( -- 606
			Vec2(mx, my), -- 606
			aiming and 2 or 1.6, -- 606
			toColor(col, aiming and 215 or 120) -- 606
		) -- 606
		if aiming then -- 607
			local sz = p.aimHold > 0 and 32 or 24 -- 608
			uiArt:tryPlace( -- 609
				"ink_enso_fine", -- 609
				"reticle_child", -- 609
				mx, -- 609
				my, -- 609
				sz, -- 609
				sz, -- 609
				{ -- 609
					color = toColor(PALETTE.amberCore), -- 610
					opacity = 0.82, -- 610
					angle = self.time * 24, -- 610
					layer = 5 -- 610
				} -- 610
			) -- 610
		end -- 610
		return -- 613
	end -- 613
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 616
	local onEnemy = false -- 617
	local i = 0 -- 618
	do -- 618
		i = 0 -- 619
		while i < #p.enemies do -- 619
			local e = p.enemies[i + 1] -- 620
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 621
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 622
				onEnemy = true -- 623
			end -- 623
			i = i + 1 -- 619
		end -- 619
	end -- 619
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 627
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 628
	local arm = onEnemy and 8.5 or 9.5 -- 629
	local bg = Color(10, 12, 18, 160) -- 630
	uiInkDraw:drawSegment( -- 632
		Vec2(mx - gap - arm, my), -- 632
		Vec2(mx - gap, my), -- 632
		2.1, -- 632
		bg -- 632
	) -- 632
	uiInkDraw:drawSegment( -- 633
		Vec2(mx + gap, my), -- 633
		Vec2(mx + gap + arm, my), -- 633
		2.1, -- 633
		bg -- 633
	) -- 633
	uiInkDraw:drawSegment( -- 634
		Vec2(mx, my - gap - arm), -- 634
		Vec2(mx, my - gap), -- 634
		2.1, -- 634
		bg -- 634
	) -- 634
	uiInkDraw:drawSegment( -- 635
		Vec2(mx, my + gap), -- 635
		Vec2(mx, my + gap + arm), -- 635
		2.1, -- 635
		bg -- 635
	) -- 635
	uiInkDraw:drawSegment( -- 637
		Vec2(mx - gap - arm, my), -- 637
		Vec2(mx - gap, my), -- 637
		1.1, -- 637
		toColor(col, 230) -- 637
	) -- 637
	uiInkDraw:drawSegment( -- 638
		Vec2(mx + gap, my), -- 638
		Vec2(mx + gap + arm, my), -- 638
		1.1, -- 638
		toColor(col, 230) -- 638
	) -- 638
	uiInkDraw:drawSegment( -- 639
		Vec2(mx, my - gap - arm), -- 639
		Vec2(mx, my - gap), -- 639
		1.1, -- 639
		toColor(col, 230) -- 639
	) -- 639
	uiInkDraw:drawSegment( -- 640
		Vec2(mx, my + gap), -- 640
		Vec2(mx, my + gap + arm), -- 640
		1.1, -- 640
		toColor(col, 230) -- 640
	) -- 640
	uiInkDraw:drawDot( -- 641
		Vec2(mx, my), -- 641
		1.8, -- 641
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 641
	) -- 641
	if onEnemy then -- 643
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 644
		uiArt:tryPlace( -- 645
			"ink_enso_fine", -- 645
			"reticle_lock", -- 645
			mx, -- 645
			my, -- 645
			sz, -- 645
			sz, -- 645
			{ -- 645
				color = toColor(PALETTE.rouge), -- 646
				opacity = 0.88, -- 646
				angle = self.time * 38, -- 646
				layer = 5 -- 646
			} -- 646
		) -- 646
		fillRadialGlow( -- 648
			uiGlow, -- 648
			mx, -- 648
			my, -- 648
			16, -- 648
			16, -- 648
			toColor(PALETTE.rouge, 30), -- 648
			Color(182, 58, 56, 0), -- 648
			10 -- 648
		) -- 648
	end -- 648
end -- 584
return ____exports -- 584
