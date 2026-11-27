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
end -- 33
function HudRenderer.prototype.reset(self, p) -- 40
	self.ghostHp = p ~= nil and p.hp or 3 -- 41
	self.talentSelected = 0 -- 42
end -- 40
function HudRenderer.prototype.update(self, dt, p) -- 45
	self.time = self.time + dt -- 46
	if self.ghostHp > p.hp then -- 46
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 48
	else -- 48
		self.ghostHp = p.hp -- 50
	end -- 50
end -- 45
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible) -- 54
	if assistHintsEnabled == nil then -- 54
		assistHintsEnabled = false -- 65
	end -- 65
	if suppressReticle == nil then -- 65
		suppressReticle = false -- 66
	end -- 66
	if inputMode == nil then -- 66
		inputMode = "kbm" -- 67
	end -- 67
	if gamepadLayout == nil then -- 67
		gamepadLayout = "xbox" -- 68
	end -- 68
	if safe == nil then -- 68
		safe = ZERO_SAFE_INSETS -- 69
	end -- 69
	if retryHoldProgress == nil then -- 69
		retryHoldProgress = 0 -- 70
	end -- 70
	if touchOverlayVisible == nil then -- 70
		touchOverlayVisible = false -- 71
	end -- 71
	local w = cam.viewW / uiScale -- 73
	local h = cam.viewH / uiScale -- 74
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 75
	if hudAlpha > 0.05 then -- 75
		if p.childMode then -- 75
			self:drawChildStatus( -- 79
				uiDraw, -- 79
				uiInkDraw, -- 79
				uiArt, -- 79
				texts, -- 79
				p, -- 79
				h, -- 79
				hudAlpha, -- 79
				assistHintsEnabled, -- 79
				inputMode, -- 79
				gamepadLayout, -- 79
				safe -- 79
			) -- 79
		else -- 79
			self:drawSoldierStatus( -- 81
				uiDraw, -- 81
				uiInkDraw, -- 81
				uiArt, -- 81
				texts, -- 81
				p, -- 81
				h, -- 81
				hudAlpha, -- 81
				assistHintsEnabled, -- 81
				inputMode, -- 81
				gamepadLayout, -- 81
				safe -- 81
			) -- 81
		end -- 81
		self:drawChapterBadge( -- 84
			uiDraw, -- 84
			uiArt, -- 84
			texts, -- 84
			p, -- 84
			w, -- 84
			h, -- 84
			hudAlpha, -- 84
			inputMode, -- 84
			safe, -- 84
			touchOverlayVisible -- 84
		) -- 84
		self:drawContextualObjective( -- 85
			uiDraw, -- 85
			uiInkDraw, -- 85
			uiArt, -- 85
			texts, -- 85
			p, -- 85
			w, -- 85
			h, -- 85
			hudAlpha, -- 85
			assistHintsEnabled, -- 85
			inputMode, -- 85
			gamepadLayout, -- 85
			safe -- 85
		) -- 85
		if assistHintsEnabled then -- 85
			local prompt = deriveWorldPrompt(p) -- 88
			if prompt ~= nil then -- 88
				local adapted = { -- 90
					x = prompt.x, -- 91
					y = prompt.y, -- 92
					keyTag = adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout), -- 93
					label = prompt.label, -- 94
					urgent = prompt.urgent, -- 95
					progress = prompt.progress -- 96
				} -- 96
				self:drawWorldPrompts( -- 98
					uiDraw, -- 98
					uiInkDraw, -- 98
					uiArt, -- 98
					texts, -- 98
					{adapted}, -- 98
					cam, -- 98
					hudAlpha, -- 98
					uiScale, -- 98
					safe -- 98
				) -- 98
			end -- 98
		end -- 98
		if vfx.deflectFlash > 0.25 then -- 98
			local dx = cam:sx(vfx.deflectX) / uiScale -- 103
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 104
			texts:put( -- 105
				"sm", -- 105
				"掩体挡下", -- 105
				dx, -- 105
				dy, -- 105
				toColor(PALETTE.textBright), -- 105
				0.5, -- 105
				0.5, -- 105
				"Center", -- 105
				2, -- 105
				vfx.deflectFlash, -- 105
				0.1 -- 105
			) -- 105
		end -- 105
	end -- 105
	if retryHoldProgress > 0.02 then -- 105
		local cx = w * 0.5 -- 111
		local cy = h - 32 - safe.top -- 112
		local bw = 220 -- 113
		drawSilkVeil( -- 114
			uiDraw, -- 114
			uiArt, -- 114
			"hud_retry_hold_veil", -- 114
			cx, -- 114
			cy, -- 114
			bw + 60, -- 114
			34, -- 114
			PALETTE.inkWarm, -- 114
			0.84, -- 114
			2 -- 114
		) -- 114
		texts:put( -- 115
			"xs", -- 115
			"长按 BACK 重试检查点", -- 115
			cx, -- 115
			cy + 7, -- 115
			toColor(PALETTE.amberCore), -- 115
			0.5, -- 115
			0.5, -- 115
			"Center", -- 115
			1, -- 115
			0.96, -- 115
			0.08 -- 115
		) -- 115
		local x0 = cx - bw * 0.44 -- 116
		local x1 = cx + bw * 0.44 -- 117
		uiInkDraw:drawSegment( -- 118
			Vec2(x0, cy - 8), -- 118
			Vec2(x1, cy - 8), -- 118
			1.4, -- 118
			toColor(PALETTE.silkDim, 120) -- 118
		) -- 118
		uiInkDraw:drawSegment( -- 119
			Vec2(x0, cy - 8), -- 119
			Vec2( -- 119
				x0 + (x1 - x0) * math.min(1, retryHoldProgress), -- 119
				cy - 8 -- 119
			), -- 119
			2.8, -- 119
			toColor(PALETTE.rouge, 235) -- 119
		) -- 119
	end -- 119
	if not suppressReticle then -- 119
		self:drawReticleOverlay( -- 123
			uiInkDraw, -- 123
			uiArt, -- 123
			uiGlow, -- 123
			p, -- 123
			cam, -- 123
			vfx, -- 123
			letterboxFrac, -- 123
			uiScale, -- 123
			inputMode == "touch" -- 123
		) -- 123
	end -- 123
end -- 54
function HudRenderer.prototype.talentCardRects(self, w, h, count, touchMode, safeTop) -- 128
	if touchMode == nil then -- 128
		touchMode = false -- 128
	end -- 128
	if safeTop == nil then -- 128
		safeTop = 0 -- 128
	end -- 128
	local out = {} -- 129
	if count <= 0 then -- 129
		return out -- 131
	end -- 131
	local cardW = touchMode and 212 or 204 -- 133
	local cardH = touchMode and 50 or 38 -- 134
	local gap = 14 -- 135
	local totalW = count * cardW + (count - 1) * gap -- 136
	local startX = (w - totalW) * 0.5 -- 137
	local y = h - (touchMode and 132 or 120) - safeTop -- 138
	local i = 0 -- 139
	do -- 139
		i = 0 -- 140
		while i < count do -- 140
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 141
			i = i + 1 -- 140
		end -- 140
	end -- 140
	return out -- 143
end -- 128
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, touchMode) -- 147
	if touchMode == nil then -- 147
		touchMode = false -- 156
	end -- 156
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 156
		self:drawReticle( -- 160
			uiInkDraw, -- 160
			uiArt, -- 160
			uiGlow, -- 160
			p, -- 160
			cam, -- 160
			vfx, -- 160
			uiScale, -- 160
			touchMode -- 160
		) -- 160
	end -- 160
end -- 147
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 164
	local bx = 28 + safe.left -- 177
	local by = h - 72 - safe.top -- 178
	local lowHp = p.hp <= 1 -- 179
	local segCount = math.max(1, p.maxHp) -- 181
	local segW = segCount >= 5 and 42 or 54 -- 182
	local segH = 9 -- 183
	local gap = segCount >= 5 and 6 or 8 -- 184
	local veilW = math.max(340, 124 + segCount * (segW + gap)) -- 185
	drawSilkVeil( -- 186
		uiDraw, -- 186
		uiArt, -- 186
		"hud_soldier_veil", -- 186
		bx + veilW * 0.44, -- 186
		by + 24, -- 186
		veilW, -- 186
		56, -- 186
		PALETTE.inkWash, -- 186
		0.62 * alpha, -- 186
		-1 -- 186
	) -- 186
	texts:put( -- 187
		"md", -- 187
		"戍", -- 187
		bx + 16, -- 187
		by + 25, -- 187
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 187
		0.5, -- 187
		0.5, -- 187
		"Center", -- 187
		0, -- 187
		alpha, -- 187
		0.1 -- 187
	) -- 187
	uiInkDraw:drawSegment( -- 188
		Vec2(bx + 32, by + 9), -- 188
		Vec2(bx + 32, by + 40), -- 188
		0.8, -- 188
		toColor(PALETTE.silkDim, 130 * alpha) -- 188
	) -- 188
	texts:put( -- 189
		"xs", -- 189
		"周戍 · 体力", -- 189
		bx + 44, -- 189
		by + 36, -- 189
		toColor(PALETTE.textMid), -- 189
		0, -- 189
		0.5, -- 189
		"Left", -- 189
		1.4, -- 189
		alpha, -- 189
		0.08 -- 189
	) -- 189
	local barX = bx + 44 -- 191
	local barY = by + 16 -- 192
	local i = 0 -- 194
	do -- 194
		i = 0 -- 195
		while i < segCount do -- 195
			local sx = barX + i * (segW + gap) -- 196
			local scx = sx + segW * 0.5 -- 197
			if not uiArt:tryPlace( -- 197
				"ink_bamboo_slot", -- 198
				"hp_slot_" .. tostring(i), -- 198
				scx, -- 198
				barY, -- 198
				segW, -- 198
				segH, -- 198
				{ -- 198
					color = toColor(PALETTE.silkDim), -- 199
					opacity = 0.72 * alpha, -- 199
					layer = 1 -- 199
				} -- 199
			) then -- 199
				uiInkDraw:drawRect( -- 201
					Rect(sx, barY - 3, segW, 6), -- 201
					Color(0, 0, 0, 0), -- 201
					0.8, -- 201
					toColor(PALETTE.silkDim, 145 * alpha) -- 201
				) -- 201
			end -- 201
			if self.ghostHp > i and self.ghostHp > p.hp then -- 201
				local frac = math.min(1, self.ghostHp - i) -- 204
				uiInkDraw:drawRect( -- 205
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 205
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 205
				) -- 205
			end -- 205
			if p.hp > i then -- 205
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 208
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 209
				if not uiArt:tryPlace( -- 209
					"ink_bamboo_slip", -- 210
					"hp_fill_" .. tostring(i), -- 210
					scx, -- 210
					barY, -- 210
					segW, -- 210
					segH, -- 210
					{ -- 210
						color = toColor(fillCol), -- 211
						opacity = 0.94 * alpha * pulse, -- 211
						layer = 2 -- 211
					} -- 211
				) then -- 211
					uiInkDraw:drawRect( -- 213
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 213
						toColor(fillCol, 230 * alpha * pulse) -- 213
					) -- 213
				end -- 213
			end -- 213
			i = i + 1 -- 195
		end -- 195
	end -- 195
	local covX = barX + segCount * (segW + gap) + 6 -- 218
	local hasAliveEnemy = false -- 219
	do -- 219
		i = 0 -- 220
		while i < #p.enemies do -- 220
			if p.enemies[i + 1].alive then -- 220
				hasAliveEnemy = true -- 222
				break -- 223
			end -- 223
			i = i + 1 -- 220
		end -- 220
	end -- 220
	if p.coverHug then -- 220
		if hasAliveEnemy and not p.coverBlocking then -- 220
			uiInkDraw:drawRect( -- 228
				Rect(covX, barY - 9, 72, 18), -- 228
				toColor(PALETTE.inkWarm, 185 * alpha), -- 228
				0.8, -- 228
				toColor(PALETTE.amber, 200 * alpha) -- 228
			) -- 228
			texts:put( -- 229
				"xs", -- 229
				"背向掩体", -- 229
				covX + 36, -- 229
				barY, -- 229
				toColor(PALETTE.amberCore), -- 229
				0.5, -- 229
				0.5, -- 229
				"Center", -- 229
				0.6, -- 229
				alpha, -- 229
				0 -- 229
			) -- 229
		else -- 229
			uiInkDraw:drawRect( -- 231
				Rect(covX, barY - 9, 54, 18), -- 231
				toColor(PALETTE.cyanDim, 165 * alpha), -- 231
				0.8, -- 231
				toColor(PALETTE.cyanCore, 180 * alpha) -- 231
			) -- 231
			texts:put( -- 232
				"xs", -- 232
				"掩体中", -- 232
				covX + 27, -- 232
				barY, -- 232
				toColor(PALETTE.textBright), -- 232
				0.5, -- 232
				0.5, -- 232
				"Center", -- 232
				0.6, -- 232
				alpha, -- 232
				0 -- 232
			) -- 232
		end -- 232
	elseif assistHintsEnabled and p.coverNear then -- 232
		uiInkDraw:drawRect( -- 235
			Rect(covX, barY - 9, 54, 18), -- 235
			Color( -- 235
				14, -- 235
				17, -- 235
				25, -- 235
				math.floor(150 * alpha + 0.5) -- 235
			), -- 235
			0.8, -- 235
			toColor(PALETTE.silkLine, 165 * alpha) -- 235
		) -- 235
		texts:put( -- 236
			"xs", -- 236
			"可贴靠", -- 236
			covX + 27, -- 236
			barY, -- 236
			toColor(PALETTE.textMid), -- 236
			0.5, -- 236
			0.5, -- 236
			"Center", -- 236
			0.6, -- 236
			alpha, -- 236
			0.08 -- 236
		) -- 236
	end -- 236
	local ____p_isCampaign_5 = p.isCampaign -- 239
	if ____p_isCampaign_5 then -- 239
		local ____opt_0 = p.room.campaign -- 239
		local ____temp_4 = (____opt_0 and ____opt_0.chapter) == "S" -- 239
		if not ____temp_4 then -- 239
			local ____opt_2 = p.room.campaign -- 239
			____temp_4 = (____opt_2 and ____opt_2.chapter) == "C" -- 239
		end -- 239
		____p_isCampaign_5 = ____temp_4 -- 239
	end -- 239
	local showCampaignFear = ____p_isCampaign_5 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 239
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" or showCampaignFear then -- 239
		local subY = by - 24 -- 242
		local frozen = p.escort.state == "frozen" -- 243
		local calming = p.escort.state == "calming" -- 244
		drawSilkVeil( -- 246
			uiDraw, -- 246
			uiArt, -- 246
			"hud_fear_veil", -- 246
			bx + 126, -- 246
			subY + 6, -- 246
			260, -- 246
			30, -- 246
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 246
			0.64 * alpha, -- 246
			-1 -- 246
		) -- 246
		texts:put( -- 247
			"xs", -- 247
			"小满 · 惊惧", -- 247
			bx + 14, -- 247
			subY + 6, -- 247
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 247
			0, -- 247
			0.5, -- 247
			"Left", -- 247
			1, -- 247
			alpha, -- 247
			0.08 -- 247
		) -- 247
		local k = 0 -- 249
		do -- 249
			k = 0 -- 250
			while k < FEAR_MAX do -- 250
				local dx = bx + 114 + k * 20 -- 251
				local dy = subY + 6 -- 252
				local lit = k < p.escort.fear -- 253
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 254
				uiArt:tryPlace( -- 255
					"ink_enso_fine", -- 255
					"fear_ring_" .. tostring(k), -- 255
					dx, -- 255
					dy, -- 255
					14, -- 255
					14, -- 255
					{ -- 255
						color = toColor(lit and dc or PALETTE.silkLine), -- 256
						opacity = (lit and 0.92 or 0.64) * alpha, -- 256
						layer = 2 -- 256
					} -- 256
				) -- 256
				if lit then -- 256
					drawBlossomDot( -- 259
						uiInkDraw, -- 259
						uiArt, -- 259
						"fear_dot_" .. tostring(k), -- 259
						dx, -- 259
						dy, -- 259
						10, -- 259
						dc, -- 259
						0.96 * alpha, -- 259
						3 -- 259
					) -- 259
				end -- 259
				k = k + 1 -- 250
			end -- 250
		end -- 250
		if frozen then -- 250
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 264
			if assistHintsEnabled then -- 264
				local calmKey = adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 266
				local keyW = math.max( -- 267
					22, -- 267
					visualTextWidth(calmKey, 15) + 10 -- 267
				) -- 267
				drawSilkKeycap( -- 268
					uiInkDraw, -- 268
					texts, -- 268
					bx + 170, -- 268
					subY - 5, -- 268
					keyW, -- 268
					22, -- 268
					calmKey, -- 268
					PALETTE.rouge, -- 268
					alpha * pulse, -- 268
					true -- 268
				) -- 268
				texts:put( -- 269
					"xs", -- 269
					"轻敲安抚", -- 269
					bx + 176 + keyW, -- 269
					subY + 6, -- 269
					toColor(PALETTE.crimsonCore), -- 269
					0, -- 269
					0.5, -- 269
					"Left", -- 269
					0.8, -- 269
					alpha * pulse, -- 269
					0.08 -- 269
				) -- 269
			else -- 269
				texts:put( -- 271
					"xs", -- 271
					"受惊停步", -- 271
					bx + 172, -- 271
					subY + 6, -- 271
					toColor(PALETTE.crimsonCore), -- 271
					0, -- 271
					0.5, -- 271
					"Left", -- 271
					0.8, -- 271
					alpha * pulse, -- 271
					0.08 -- 271
				) -- 271
			end -- 271
		elseif calming then -- 271
			texts:put( -- 274
				"xs", -- 274
				"轻敲安抚中", -- 274
				bx + 172, -- 274
				subY + 6, -- 274
				toColor(PALETTE.emerald), -- 274
				0, -- 274
				0.5, -- 274
				"Left", -- 274
				0.8, -- 274
				alpha, -- 274
				0.08 -- 274
			) -- 274
		end -- 274
	end -- 274
	local ranks = p:getStoryTalentRanks() -- 278
	if ranks ~= nil then -- 278
		local parts = {} -- 280
		if ranks.vitality > 0 then -- 280
			parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 281
		end -- 281
		if ranks.reload > 0 then -- 281
			parts[#parts + 1] = "熟铳" .. tostring(ranks.reload) -- 282
		end -- 282
		if ranks.guard > 0 then -- 282
			parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 283
		end -- 283
		if ranks.craft > 0 then -- 283
			parts[#parts + 1] = "巧手" .. tostring(ranks.craft) -- 284
		end -- 284
		if #parts > 0 then -- 284
			local subY = by - 22 -- 286
			local txt = "本领 · " .. table.concat(parts, " · ") -- 287
			drawSilkVeil( -- 288
				uiDraw, -- 288
				uiArt, -- 288
				"hud_talent_ranks_veil", -- 288
				bx + 126, -- 288
				subY + 6, -- 288
				260, -- 288
				26, -- 288
				PALETTE.inkWash, -- 288
				0.56 * alpha, -- 288
				-1 -- 288
			) -- 288
			texts:put( -- 289
				"xs", -- 289
				txt, -- 289
				bx + 14, -- 289
				subY + 6, -- 289
				toColor(PALETTE.amberCore), -- 289
				0, -- 289
				0.5, -- 289
				"Left", -- 289
				0.8, -- 289
				alpha, -- 289
				0.08 -- 289
			) -- 289
		end -- 289
	elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 289
		local inv = p.run.inventory -- 292
		local items = {} -- 293
		if inv.shield > 0 then -- 293
			items[#items + 1] = "残盾" .. tostring(inv.shield) -- 294
		end -- 294
		if inv.wedge > 0 then -- 294
			items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 295
		end -- 295
		if inv.ammo > 0 then -- 295
			items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 296
		end -- 296
		if inv.scrap > 0 then -- 296
			items[#items + 1] = "木料" .. tostring(inv.scrap) -- 297
		end -- 297
		local companionText = p.run.joined and "小满同行" or "小满等待" -- 298
		local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 299
		local subY = by - 22 -- 300
		drawSilkVeil( -- 301
			uiDraw, -- 301
			uiArt, -- 301
			"hud_camp_veil", -- 301
			bx + 126, -- 301
			subY + 6, -- 301
			260, -- 301
			26, -- 301
			PALETTE.inkWash, -- 301
			0.54 * alpha, -- 301
			-1 -- 301
		) -- 301
		texts:put( -- 302
			"xs", -- 302
			summary, -- 302
			bx + 14, -- 302
			subY + 6, -- 302
			toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 302
			0, -- 302
			0.5, -- 302
			"Left", -- 302
			0.8, -- 302
			alpha, -- 302
			0.08 -- 302
		) -- 302
	end -- 302
end -- 164
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 306
	local bx = 28 + safe.left -- 319
	local by = h - 68 - safe.top -- 320
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 321
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 322
	drawSilkVeil( -- 324
		uiDraw, -- 324
		uiArt, -- 324
		"hud_child_veil", -- 324
		bx + 144, -- 324
		by + 22, -- 324
		316, -- 324
		48, -- 324
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 324
		0.58 * alpha, -- 324
		-1 -- 324
	) -- 324
	texts:put( -- 325
		"md", -- 325
		alert and "危" or "满", -- 325
		bx + 16, -- 325
		by + 22, -- 325
		toColor(leadCol), -- 325
		0.5, -- 325
		0.5, -- 325
		"Center", -- 325
		0, -- 325
		alpha, -- 325
		0.1 -- 325
	) -- 325
	uiInkDraw:drawSegment( -- 326
		Vec2(bx + 32, by + 7), -- 326
		Vec2(bx + 32, by + 37), -- 326
		0.8, -- 326
		toColor(PALETTE.silkDim, 130 * alpha) -- 326
	) -- 326
	texts:put( -- 327
		"xs", -- 327
		"小满 · 潜行", -- 327
		bx + 44, -- 327
		by + 33, -- 327
		toColor(PALETTE.amberCore), -- 327
		0, -- 327
		0.5, -- 327
		"Left", -- 327
		1.4, -- 327
		alpha, -- 327
		0.08 -- 327
	) -- 327
	local posture = assistHintsEnabled and "轻步前行 · 保持隐蔽" or "轻步前行" -- 329
	local col = PALETTE.textMid -- 330
	if alert then -- 330
		posture = (p.scavChase or p.dogState == "chase") and (assistHintsEnabled and "已被发现 · 速寻隐蔽" or "已被发现") or (assistHintsEnabled and "引起警觉 · 停步蹲伏" or "引起警觉") -- 332
		col = PALETTE.crimsonCore -- 335
	elseif p.player.crouch then -- 335
		posture = assistHintsEnabled and "低姿伏行 · 匿迹于影" or "低姿伏行" -- 337
		col = PALETTE.emerald -- 338
	elseif p.hasBottle then -- 338
		posture = assistHintsEnabled and adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 340
		col = PALETTE.amberCore -- 343
	end -- 343
	texts:put( -- 345
		"xs", -- 345
		posture, -- 345
		bx + 44, -- 345
		by + 12, -- 345
		toColor(col), -- 345
		0, -- 345
		0.5, -- 345
		"Left", -- 345
		0.6, -- 345
		alpha, -- 345
		0.08 -- 345
	) -- 345
end -- 306
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible) -- 348
	local theme = themeOf(p.room.key) -- 360
	local rx = w - 32 - safe.right - (touchOverlayVisible and 208 or 0) -- 361
	local cy = h - 44 - safe.top -- 362
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc 暂歇" -- 363
	drawSilkVeil( -- 365
		uiDraw, -- 365
		uiArt, -- 365
		"hud_chap_veil", -- 365
		rx - 82, -- 365
		cy, -- 365
		240, -- 365
		44, -- 365
		PALETTE.inkWash, -- 365
		0.44 * alpha, -- 365
		-1 -- 365
	) -- 365
	texts:put( -- 366
		"xs", -- 366
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 366
		rx, -- 366
		touchOverlayVisible and cy or cy + 9, -- 366
		toColor(PALETTE.textBright), -- 366
		1, -- 366
		0.5, -- 366
		"Right", -- 366
		1.2, -- 366
		alpha, -- 366
		0.08 -- 366
	) -- 366
	if not touchOverlayVisible then -- 366
		texts:put( -- 368
			"xs", -- 368
			pauseTip, -- 368
			rx, -- 368
			cy - 11, -- 368
			toColor(PALETTE.textDim), -- 368
			1, -- 368
			0.5, -- 368
			"Right", -- 368
			1, -- 368
			0.78 * alpha, -- 368
			0.08 -- 368
		) -- 368
	end -- 368
end -- 348
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 372
	local touchMode = inputMode == "touch" -- 386
	local talentOffers = p:getStoryTalentOffers() -- 387
	if #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 387
		local boxes = self:talentCardRects( -- 389
			w, -- 389
			h, -- 389
			#talentOffers, -- 389
			touchMode, -- 389
			safe.top -- 389
		) -- 389
		local cx = w * 0.5 -- 390
		local titleY = h - 54 - safe.top -- 391
		local talentHint = inputMode == "gamepad" and "护送本领三选一 · LB/RB 择项 · L3 确认或点选" or (touchMode and "护送本领三选一 · 轻触卡面习得" or "护送本领三选一 · 按 1 / 2 / 3 或点击习得") -- 392
		drawSilkVeil( -- 397
			uiDraw, -- 397
			uiArt, -- 397
			"hud_talent_head_veil", -- 397
			cx, -- 397
			titleY, -- 397
			410, -- 397
			26, -- 397
			PALETTE.inkWash, -- 397
			0.72 * alpha, -- 397
			-1 -- 397
		) -- 397
		drawHairline( -- 398
			uiInkDraw, -- 398
			uiArt, -- 398
			"hud_talent_head_line", -- 398
			cx, -- 398
			titleY + 13, -- 398
			330, -- 398
			PALETTE.amber, -- 398
			0.52 * alpha, -- 398
			true, -- 398
			2 -- 398
		) -- 398
		texts:put( -- 399
			"xs", -- 399
			talentHint, -- 399
			cx, -- 399
			titleY, -- 399
			toColor(PALETTE.amberCore), -- 399
			0.5, -- 399
			0.5, -- 399
			"Center", -- 399
			1.2, -- 399
			alpha, -- 399
			0.08 -- 399
		) -- 399
		local ti = 0 -- 401
		do -- 401
			ti = 0 -- 402
			while ti < #talentOffers do -- 402
				local box = boxes[ti + 1] -- 403
				local bx = box.x -- 404
				local by = box.y -- 405
				local bh = box.height -- 406
				local cy = by + bh * 0.5 -- 407
				local gpFocus = inputMode == "gamepad" and ti == self.talentSelected -- 408
				local borderCol = gpFocus and PALETTE.rouge or PALETTE.amber -- 409
				uiDraw:drawRect( -- 410
					box, -- 411
					toColor( -- 412
						gpFocus and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 412
						math.floor((gpFocus and 235 or 215) * alpha + 0.5) -- 412
					), -- 412
					gpFocus and 1.5 or 0.9, -- 413
					toColor( -- 414
						borderCol, -- 414
						math.floor((gpFocus and 235 or 185) * alpha + 0.5) -- 414
					) -- 414
				) -- 414
				if inputMode == "kbm" then -- 414
					drawSilkKeycap( -- 417
						uiInkDraw, -- 417
						texts, -- 417
						bx + 8, -- 417
						cy - 11, -- 417
						22, -- 417
						22, -- 417
						"" .. tostring(ti + 1), -- 417
						borderCol, -- 417
						alpha, -- 417
						true -- 417
					) -- 417
					texts:put( -- 418
						"xs", -- 418
						talentNames[talentOffers[ti + 1]], -- 418
						bx + 38, -- 418
						cy, -- 418
						toColor(PALETTE.textBright), -- 418
						0, -- 418
						0.5, -- 418
						"Left", -- 418
						0.6, -- 418
						alpha, -- 418
						0.08 -- 418
					) -- 418
				else -- 418
					drawBlossomDot( -- 420
						uiInkDraw, -- 420
						uiArt, -- 420
						"hud_talent_dot_" .. tostring(ti), -- 420
						bx + 18, -- 420
						cy, -- 420
						gpFocus and 12 or 8, -- 420
						borderCol, -- 420
						alpha, -- 420
						4 -- 420
					) -- 420
					texts:put( -- 421
						"xs", -- 421
						talentNames[talentOffers[ti + 1]], -- 421
						bx + 34, -- 421
						cy, -- 421
						toColor(PALETTE.textBright), -- 421
						0, -- 421
						0.5, -- 421
						"Left", -- 421
						0.6, -- 421
						alpha, -- 421
						0.08 -- 421
					) -- 421
				end -- 421
				ti = ti + 1 -- 402
			end -- 402
		end -- 402
	end -- 402
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 402
		local g = p.room.story.gate -- 430
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 430
			local bw = 400 -- 432
			local cx = w * 0.5 -- 433
			local by = h - 64 - safe.top -- 434
			local tied = p.phase == "gate-hand" -- 435
			local ratio = tied and 1 or math.max( -- 436
				0, -- 436
				math.min( -- 436
					1, -- 436
					p.handTicks / math.max(1, p.handNeedTicks) -- 436
				) -- 436
			) -- 436
			local holdInteractKey = adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 437
			local reholdInteractKey = adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 438
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 439
			drawSilkVeil( -- 443
				uiDraw, -- 443
				uiArt, -- 443
				"hud_hand_veil", -- 443
				cx, -- 443
				by + 18, -- 443
				bw + 90, -- 443
				48, -- 443
				PALETTE.inkWash, -- 443
				0.76 * alpha, -- 443
				-1 -- 443
			) -- 443
			drawHairline( -- 444
				uiInkDraw, -- 444
				uiArt, -- 444
				"hud_hand_top", -- 444
				cx, -- 444
				by + 39, -- 444
				bw - 20, -- 444
				PALETTE.amber, -- 444
				0.55 * alpha, -- 444
				false, -- 444
				2 -- 444
			) -- 444
			texts:put( -- 445
				"xs", -- 445
				label, -- 445
				cx, -- 445
				by + 26, -- 445
				toColor(PALETTE.textBright), -- 445
				0.5, -- 445
				0.5, -- 445
				"Center", -- 445
				1.8, -- 445
				alpha, -- 445
				0.08 -- 445
			) -- 445
			local pbw = bw - 80 -- 447
			local pbx = cx - pbw * 0.5 -- 448
			local pby = by + 9 -- 449
			uiInkDraw:drawSegment( -- 450
				Vec2(pbx, pby), -- 450
				Vec2(pbx + pbw, pby), -- 450
				1.4, -- 450
				toColor(PALETTE.silkDim, 115 * alpha) -- 450
			) -- 450
			if ratio > 0.002 then -- 450
				uiInkDraw:drawSegment( -- 452
					Vec2(pbx, pby), -- 452
					Vec2(pbx + pbw * ratio, pby), -- 452
					2.8, -- 452
					toColor(PALETTE.amber, 230 * alpha) -- 452
				) -- 452
				uiInkDraw:drawSegment( -- 453
					Vec2(pbx, pby), -- 453
					Vec2(pbx + pbw * ratio, pby), -- 453
					1, -- 453
					toColor(PALETTE.amberCore, 165 * alpha) -- 453
				) -- 453
			end -- 453
			uiArt:tryPlace( -- 455
				"ink_enso_fine", -- 455
				"hand_knock_1", -- 455
				pbx + pbw * 0.62, -- 455
				pby, -- 455
				11, -- 455
				11, -- 455
				{ -- 455
					color = toColor(PALETTE.amber), -- 456
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 456
					layer = 3 -- 456
				} -- 456
			) -- 456
			uiArt:tryPlace( -- 458
				"ink_enso_fine", -- 458
				"hand_knock_2", -- 458
				pbx + pbw * 0.72, -- 458
				pby, -- 458
				11, -- 458
				11, -- 458
				{ -- 458
					color = toColor(PALETTE.amber), -- 459
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 459
					layer = 3 -- 459
				} -- 459
			) -- 459
		end -- 459
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 459
			local bw = 400 -- 463
			local cx = w * 0.5 -- 464
			local by = h - 64 - safe.top -- 465
			local ratio = math.max( -- 466
				0, -- 466
				math.min( -- 466
					1, -- 466
					p.gateTick / math.max(1, g.holdTicks) -- 466
				) -- 466
			) -- 466
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 467
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 468
			drawSilkVeil( -- 470
				uiDraw, -- 470
				uiArt, -- 470
				"hud_gate_veil", -- 470
				cx, -- 470
				by + 18, -- 470
				bw + 90, -- 470
				48, -- 470
				PALETTE.inkWash, -- 470
				0.76 * alpha, -- 470
				-1 -- 470
			) -- 470
			drawHairline( -- 471
				uiInkDraw, -- 471
				uiArt, -- 471
				"hud_gate_top", -- 471
				cx, -- 471
				by + 39, -- 471
				bw - 20, -- 471
				PALETTE.rougeSoft, -- 471
				0.55 * alpha, -- 471
				false, -- 471
				2 -- 471
			) -- 471
			local idleNeedConfirmLabel = assistHintsEnabled and adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 473
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 476
			texts:put( -- 479
				"xs", -- 479
				label, -- 479
				cx, -- 479
				by + 26, -- 479
				toColor(PALETTE.textBright), -- 479
				0.5, -- 479
				0.5, -- 479
				"Center", -- 479
				1.8, -- 479
				alpha, -- 479
				0.08 -- 479
			) -- 479
			local pbw = bw - 80 -- 481
			local pbx = cx - pbw * 0.5 -- 482
			local pby = by + 9 -- 483
			uiInkDraw:drawSegment( -- 484
				Vec2(pbx, pby), -- 484
				Vec2(pbx + pbw, pby), -- 484
				1.4, -- 484
				toColor(PALETTE.silkDim, 115 * alpha) -- 484
			) -- 484
			if ratio > 0.002 then -- 484
				uiInkDraw:drawSegment( -- 486
					Vec2(pbx, pby), -- 486
					Vec2(pbx + pbw * ratio, pby), -- 486
					2.8, -- 486
					toColor(PALETTE.rouge, 230 * alpha) -- 486
				) -- 486
				uiInkDraw:drawSegment( -- 487
					Vec2(pbx, pby), -- 487
					Vec2(pbx + pbw * ratio, pby), -- 487
					1, -- 487
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 487
				) -- 487
			end -- 487
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 489
			local k = 0 -- 490
			do -- 490
				k = 0 -- 491
				while k < #waves do -- 491
					local wx = pbx + pbw * waves[k + 1] -- 492
					local passed = p.gateSpawned > k -- 493
					if passed then -- 493
						drawBlossomDot( -- 495
							uiInkDraw, -- 495
							uiArt, -- 495
							"gate_wave_" .. tostring(k), -- 495
							wx, -- 495
							pby, -- 495
							10, -- 495
							PALETTE.moonPale, -- 495
							0.92 * alpha, -- 495
							3 -- 495
						) -- 495
					else -- 495
						uiArt:tryPlace( -- 497
							"ink_enso_fine", -- 497
							"gate_wave_" .. tostring(k), -- 497
							wx, -- 497
							pby, -- 497
							11, -- 497
							11, -- 497
							{ -- 497
								color = toColor(PALETTE.rouge), -- 498
								opacity = 0.84 * alpha, -- 498
								layer = 3 -- 498
							} -- 498
						) -- 498
					end -- 498
					k = k + 1 -- 491
				end -- 491
			end -- 491
		end -- 491
		return -- 503
	end -- 503
	if not assistHintsEnabled then -- 503
		return -- 507
	end -- 507
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 507
		local cx = w * 0.5 -- 510
		local by = h - 44 - safe.top -- 511
		local step1 = p.cartDocked -- 512
		local ____temp_6 -- 513
		if p.room.key == "checkpoint" then -- 513
			____temp_6 = p.gateOpen -- 513
		else -- 513
			____temp_6 = p.checkpoint >= p.room.arch.x1 -- 513
		end -- 513
		local step2 = ____temp_6 -- 513
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 514
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 515
		drawSilkVeil( -- 517
			uiDraw, -- 517
			uiArt, -- 517
			"hud_obj_veil", -- 517
			cx, -- 517
			by, -- 517
			380, -- 517
			34, -- 517
			PALETTE.inkWash, -- 517
			0.58 * alpha, -- 517
			-1 -- 517
		) -- 517
		local x1 = cx - 134 -- 519
		if step1 then -- 519
			drawBlossomDot( -- 521
				uiInkDraw, -- 521
				uiArt, -- 521
				"obj_m1", -- 521
				x1, -- 521
				by, -- 521
				11, -- 521
				PALETTE.emerald, -- 521
				0.94 * alpha, -- 521
				3 -- 521
			) -- 521
		else -- 521
			uiArt:tryPlace( -- 523
				"ink_enso_fine", -- 523
				"obj_m1", -- 523
				x1, -- 523
				by, -- 523
				11, -- 523
				11, -- 523
				{ -- 523
					color = toColor(PALETTE.silkLine), -- 523
					opacity = 0.72 * alpha, -- 523
					layer = 3 -- 523
				} -- 523
			) -- 523
		end -- 523
		texts:put( -- 525
			"xs", -- 525
			t1, -- 525
			x1 + 13, -- 525
			by, -- 525
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 525
			0, -- 525
			0.5, -- 525
			"Left", -- 525
			1, -- 525
			alpha, -- 525
			0.08 -- 525
		) -- 525
		local x2 = cx + 18 -- 527
		if step2 then -- 527
			drawBlossomDot( -- 529
				uiInkDraw, -- 529
				uiArt, -- 529
				"obj_m2", -- 529
				x2, -- 529
				by, -- 529
				11, -- 529
				PALETTE.emerald, -- 529
				0.94 * alpha, -- 529
				3 -- 529
			) -- 529
		else -- 529
			uiArt:tryPlace( -- 531
				"ink_enso_fine", -- 531
				"obj_m2", -- 531
				x2, -- 531
				by, -- 531
				11, -- 531
				11, -- 531
				{ -- 531
					color = toColor(PALETTE.silkDim), -- 531
					opacity = 0.62 * alpha, -- 531
					layer = 3 -- 531
				} -- 531
			) -- 531
		end -- 531
		texts:put( -- 533
			"xs", -- 533
			t2, -- 533
			x2 + 13, -- 533
			by, -- 533
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 533
			0, -- 533
			0.5, -- 533
			"Left", -- 533
			1, -- 533
			alpha, -- 533
			0.08 -- 533
		) -- 533
	end -- 533
end -- 372
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 537
	local bob = math.sin(self.time * 3.4) * 2.8 -- 548
	local viewW = cam.viewW / uiScale -- 549
	local viewH = cam.viewH / uiScale -- 550
	local i = 0 -- 551
	do -- 551
		i = 0 -- 552
		while i < #prompts do -- 552
			local pr = prompts[i + 1] -- 553
			local keyW = math.max( -- 554
				24, -- 554
				visualTextWidth(pr.keyTag, 15) + 16 -- 554
			) -- 554
			local labelW = visualTextWidth(pr.label, 15) -- 555
			local pillW = keyW + labelW + 24 -- 556
			local padX = math.max(115, pillW * 0.5 + 24) -- 557
			local sx = math.max( -- 558
				padX + safe.left, -- 558
				math.min( -- 558
					viewW - padX - safe.right, -- 558
					cam:sx(pr.x) / uiScale -- 558
				) -- 558
			) -- 558
			local sy = math.max( -- 559
				96 + safe.bottom, -- 559
				math.min( -- 559
					viewH - 110 - safe.top, -- 559
					cam:sy(pr.y) / uiScale + bob -- 559
				) -- 559
			) -- 559
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 560
			uiInkDraw:drawSegment( -- 562
				Vec2(sx, sy - 14), -- 562
				Vec2(sx, sy - 27), -- 562
				0.8, -- 562
				toColor(accent, 135 * alpha) -- 562
			) -- 562
			drawBlossomDot( -- 563
				uiInkDraw, -- 563
				uiArt, -- 563
				"wp_anchor_" .. tostring(i), -- 563
				sx, -- 563
				sy - 28, -- 563
				7, -- 563
				accent, -- 563
				0.85 * alpha, -- 563
				3 -- 563
			) -- 563
			local px = sx - pillW * 0.5 -- 565
			local py = sy - 12 -- 566
			drawSilkVeil( -- 568
				uiDraw, -- 568
				uiArt, -- 568
				"wp_bg_" .. tostring(i), -- 568
				sx, -- 568
				py + 12, -- 568
				pillW + 40, -- 568
				32, -- 568
				PALETTE.inkWash, -- 568
				0.78 * alpha, -- 568
				0 -- 568
			) -- 568
			drawHairline( -- 569
				uiInkDraw, -- 569
				uiArt, -- 569
				"wp_line_" .. tostring(i), -- 569
				sx, -- 569
				py + 24, -- 569
				pillW + 4, -- 569
				accent, -- 569
				0.45 * alpha, -- 569
				false, -- 569
				2 -- 569
			) -- 569
			drawSilkKeycap( -- 570
				uiInkDraw, -- 570
				texts, -- 570
				px + 2, -- 570
				py + 2, -- 570
				keyW, -- 570
				20, -- 570
				pr.keyTag, -- 570
				accent, -- 570
				alpha, -- 570
				pr.urgent -- 570
			) -- 570
			texts:put( -- 571
				"xs", -- 571
				pr.label, -- 571
				px + keyW + 12, -- 571
				py + 12, -- 571
				toColor(PALETTE.textBright), -- 571
				0, -- 571
				0.5, -- 571
				"Left", -- 571
				0.8, -- 571
				alpha, -- 571
				0.08 -- 571
			) -- 571
			i = i + 1 -- 552
		end -- 552
	end -- 552
end -- 537
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 575
	local mx = p.aimX / uiScale -- 585
	local my = p.aimY / uiScale -- 586
	if mx <= 0 and my <= 0 then -- 586
		return -- 588
	end -- 588
	if p.childMode then -- 588
		local aiming = p.room.key == "village" and p.hasBottle -- 592
		if touchMode and (not aiming or p.aimHold <= 0) then -- 592
			return -- 594
		end -- 594
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 596
		uiInkDraw:drawDot( -- 597
			Vec2(mx, my), -- 597
			aiming and 2 or 1.6, -- 597
			toColor(col, aiming and 215 or 120) -- 597
		) -- 597
		if aiming then -- 597
			local sz = p.aimHold > 0 and 32 or 24 -- 599
			uiArt:tryPlace( -- 600
				"ink_enso_fine", -- 600
				"reticle_child", -- 600
				mx, -- 600
				my, -- 600
				sz, -- 600
				sz, -- 600
				{ -- 600
					color = toColor(PALETTE.amberCore), -- 601
					opacity = 0.82, -- 601
					angle = self.time * 24, -- 601
					layer = 5 -- 601
				} -- 601
			) -- 601
		end -- 601
		return -- 604
	end -- 604
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 607
	local onEnemy = false -- 608
	local i = 0 -- 609
	do -- 609
		i = 0 -- 610
		while i < #p.enemies do -- 610
			local e = p.enemies[i + 1] -- 611
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 612
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 612
				onEnemy = true -- 614
			end -- 614
			i = i + 1 -- 610
		end -- 610
	end -- 610
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 618
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 619
	local arm = onEnemy and 8.5 or 9.5 -- 620
	local bg = Color(10, 12, 18, 160) -- 621
	uiInkDraw:drawSegment( -- 623
		Vec2(mx - gap - arm, my), -- 623
		Vec2(mx - gap, my), -- 623
		2.1, -- 623
		bg -- 623
	) -- 623
	uiInkDraw:drawSegment( -- 624
		Vec2(mx + gap, my), -- 624
		Vec2(mx + gap + arm, my), -- 624
		2.1, -- 624
		bg -- 624
	) -- 624
	uiInkDraw:drawSegment( -- 625
		Vec2(mx, my - gap - arm), -- 625
		Vec2(mx, my - gap), -- 625
		2.1, -- 625
		bg -- 625
	) -- 625
	uiInkDraw:drawSegment( -- 626
		Vec2(mx, my + gap), -- 626
		Vec2(mx, my + gap + arm), -- 626
		2.1, -- 626
		bg -- 626
	) -- 626
	uiInkDraw:drawSegment( -- 628
		Vec2(mx - gap - arm, my), -- 628
		Vec2(mx - gap, my), -- 628
		1.1, -- 628
		toColor(col, 230) -- 628
	) -- 628
	uiInkDraw:drawSegment( -- 629
		Vec2(mx + gap, my), -- 629
		Vec2(mx + gap + arm, my), -- 629
		1.1, -- 629
		toColor(col, 230) -- 629
	) -- 629
	uiInkDraw:drawSegment( -- 630
		Vec2(mx, my - gap - arm), -- 630
		Vec2(mx, my - gap), -- 630
		1.1, -- 630
		toColor(col, 230) -- 630
	) -- 630
	uiInkDraw:drawSegment( -- 631
		Vec2(mx, my + gap), -- 631
		Vec2(mx, my + gap + arm), -- 631
		1.1, -- 631
		toColor(col, 230) -- 631
	) -- 631
	uiInkDraw:drawDot( -- 632
		Vec2(mx, my), -- 632
		1.8, -- 632
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 632
	) -- 632
	if onEnemy then -- 632
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 635
		uiArt:tryPlace( -- 636
			"ink_enso_fine", -- 636
			"reticle_lock", -- 636
			mx, -- 636
			my, -- 636
			sz, -- 636
			sz, -- 636
			{ -- 636
				color = toColor(PALETTE.rouge), -- 637
				opacity = 0.88, -- 637
				angle = self.time * 38, -- 637
				layer = 5 -- 637
			} -- 637
		) -- 637
		fillRadialGlow( -- 639
			uiGlow, -- 639
			mx, -- 639
			my, -- 639
			16, -- 639
			16, -- 639
			toColor(PALETTE.rouge, 30), -- 639
			Color(182, 58, 56, 0), -- 639
			10 -- 639
		) -- 639
	end -- 639
end -- 575
return ____exports -- 575