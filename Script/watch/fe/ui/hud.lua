-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
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
	local y = h - (touchMode and 122 or 108) - safeTop -- 138
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
	drawSilkVeil( -- 181
		uiDraw, -- 181
		uiArt, -- 181
		"hud_soldier_veil", -- 181
		bx + 150, -- 181
		by + 24, -- 181
		340, -- 181
		56, -- 181
		PALETTE.inkWash, -- 181
		0.62 * alpha, -- 181
		-1 -- 181
	) -- 181
	texts:put( -- 182
		"md", -- 182
		"戍", -- 182
		bx + 16, -- 182
		by + 25, -- 182
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 182
		0.5, -- 182
		0.5, -- 182
		"Center", -- 182
		0, -- 182
		alpha, -- 182
		0.1 -- 182
	) -- 182
	uiInkDraw:drawSegment( -- 183
		Vec2(bx + 32, by + 9), -- 183
		Vec2(bx + 32, by + 40), -- 183
		0.8, -- 183
		toColor(PALETTE.silkDim, 130 * alpha) -- 183
	) -- 183
	texts:put( -- 184
		"xs", -- 184
		"周戍 · 体力", -- 184
		bx + 44, -- 184
		by + 36, -- 184
		toColor(PALETTE.textMid), -- 184
		0, -- 184
		0.5, -- 184
		"Left", -- 184
		1.4, -- 184
		alpha, -- 184
		0.08 -- 184
	) -- 184
	local segCount = math.max(1, p.maxHp) -- 186
	local barX = bx + 44 -- 187
	local barY = by + 16 -- 188
	local segW = 54 -- 189
	local segH = 9 -- 190
	local gap = 8 -- 191
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < segCount do -- 194
			local sx = barX + i * (segW + gap) -- 195
			local scx = sx + segW * 0.5 -- 196
			if not uiArt:tryPlace( -- 196
				"ink_bamboo_slot", -- 197
				"hp_slot_" .. tostring(i), -- 197
				scx, -- 197
				barY, -- 197
				segW, -- 197
				segH, -- 197
				{ -- 197
					color = toColor(PALETTE.silkDim), -- 198
					opacity = 0.72 * alpha, -- 198
					layer = 1 -- 198
				} -- 198
			) then -- 198
				uiInkDraw:drawRect( -- 200
					Rect(sx, barY - 3, segW, 6), -- 200
					Color(0, 0, 0, 0), -- 200
					0.8, -- 200
					toColor(PALETTE.silkDim, 145 * alpha) -- 200
				) -- 200
			end -- 200
			if self.ghostHp > i and self.ghostHp > p.hp then -- 200
				local frac = math.min(1, self.ghostHp - i) -- 203
				uiInkDraw:drawRect( -- 204
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 204
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 204
				) -- 204
			end -- 204
			if p.hp > i then -- 204
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 207
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 208
				if not uiArt:tryPlace( -- 208
					"ink_bamboo_slip", -- 209
					"hp_fill_" .. tostring(i), -- 209
					scx, -- 209
					barY, -- 209
					segW, -- 209
					segH, -- 209
					{ -- 209
						color = toColor(fillCol), -- 210
						opacity = 0.94 * alpha * pulse, -- 210
						layer = 2 -- 210
					} -- 210
				) then -- 210
					uiInkDraw:drawRect( -- 212
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 212
						toColor(fillCol, 230 * alpha * pulse) -- 212
					) -- 212
				end -- 212
			end -- 212
			i = i + 1 -- 194
		end -- 194
	end -- 194
	local covX = barX + segCount * (segW + gap) + 6 -- 217
	local hasAliveEnemy = false -- 218
	do -- 218
		i = 0 -- 219
		while i < #p.enemies do -- 219
			if p.enemies[i + 1].alive then -- 219
				hasAliveEnemy = true -- 221
				break -- 222
			end -- 222
			i = i + 1 -- 219
		end -- 219
	end -- 219
	if p.coverHug then -- 219
		if hasAliveEnemy and not p.coverBlocking then -- 219
			uiInkDraw:drawRect( -- 227
				Rect(covX, barY - 9, 72, 18), -- 227
				toColor(PALETTE.inkWarm, 185 * alpha), -- 227
				0.8, -- 227
				toColor(PALETTE.amber, 200 * alpha) -- 227
			) -- 227
			texts:put( -- 228
				"xs", -- 228
				"背向掩体", -- 228
				covX + 36, -- 228
				barY, -- 228
				toColor(PALETTE.amberCore), -- 228
				0.5, -- 228
				0.5, -- 228
				"Center", -- 228
				0.6, -- 228
				alpha, -- 228
				0 -- 228
			) -- 228
		else -- 228
			uiInkDraw:drawRect( -- 230
				Rect(covX, barY - 9, 54, 18), -- 230
				toColor(PALETTE.cyanDim, 165 * alpha), -- 230
				0.8, -- 230
				toColor(PALETTE.cyanCore, 180 * alpha) -- 230
			) -- 230
			texts:put( -- 231
				"xs", -- 231
				"掩体中", -- 231
				covX + 27, -- 231
				barY, -- 231
				toColor(PALETTE.textBright), -- 231
				0.5, -- 231
				0.5, -- 231
				"Center", -- 231
				0.6, -- 231
				alpha, -- 231
				0 -- 231
			) -- 231
		end -- 231
	elseif p.coverNear then -- 231
		uiInkDraw:drawRect( -- 234
			Rect(covX, barY - 9, 54, 18), -- 234
			Color( -- 234
				14, -- 234
				17, -- 234
				25, -- 234
				math.floor(150 * alpha + 0.5) -- 234
			), -- 234
			0.8, -- 234
			toColor(PALETTE.silkLine, 165 * alpha) -- 234
		) -- 234
		texts:put( -- 235
			"xs", -- 235
			"可贴靠", -- 235
			covX + 27, -- 235
			barY, -- 235
			toColor(PALETTE.textMid), -- 235
			0.5, -- 235
			0.5, -- 235
			"Center", -- 235
			0.6, -- 235
			alpha, -- 235
			0.08 -- 235
		) -- 235
	end -- 235
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 235
		local subY = by - 24 -- 239
		local frozen = p.escort.state == "frozen" -- 240
		local calming = p.escort.state == "calming" -- 241
		drawSilkVeil( -- 243
			uiDraw, -- 243
			uiArt, -- 243
			"hud_fear_veil", -- 243
			bx + 126, -- 243
			subY + 6, -- 243
			260, -- 243
			30, -- 243
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 243
			0.64 * alpha, -- 243
			-1 -- 243
		) -- 243
		texts:put( -- 244
			"xs", -- 244
			"小满 · 惊惧", -- 244
			bx + 14, -- 244
			subY + 6, -- 244
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 244
			0, -- 244
			0.5, -- 244
			"Left", -- 244
			1, -- 244
			alpha, -- 244
			0.08 -- 244
		) -- 244
		local k = 0 -- 246
		do -- 246
			k = 0 -- 247
			while k < FEAR_MAX do -- 247
				local dx = bx + 114 + k * 20 -- 248
				local dy = subY + 6 -- 249
				local lit = k < p.escort.fear -- 250
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 251
				uiArt:tryPlace( -- 252
					"ink_enso_fine", -- 252
					"fear_ring_" .. tostring(k), -- 252
					dx, -- 252
					dy, -- 252
					14, -- 252
					14, -- 252
					{ -- 252
						color = toColor(lit and dc or PALETTE.silkLine), -- 253
						opacity = (lit and 0.92 or 0.64) * alpha, -- 253
						layer = 2 -- 253
					} -- 253
				) -- 253
				if lit then -- 253
					drawBlossomDot( -- 256
						uiInkDraw, -- 256
						uiArt, -- 256
						"fear_dot_" .. tostring(k), -- 256
						dx, -- 256
						dy, -- 256
						10, -- 256
						dc, -- 256
						0.96 * alpha, -- 256
						3 -- 256
					) -- 256
				end -- 256
				k = k + 1 -- 247
			end -- 247
		end -- 247
		if frozen then -- 247
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 261
			if assistHintsEnabled then -- 261
				local calmKey = adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 263
				local keyW = math.max( -- 264
					22, -- 264
					visualTextWidth(calmKey, 15) + 10 -- 264
				) -- 264
				drawSilkKeycap( -- 265
					uiInkDraw, -- 265
					texts, -- 265
					bx + 170, -- 265
					subY - 5, -- 265
					keyW, -- 265
					22, -- 265
					calmKey, -- 265
					PALETTE.rouge, -- 265
					alpha * pulse, -- 265
					true -- 265
				) -- 265
				texts:put( -- 266
					"xs", -- 266
					"轻敲安抚", -- 266
					bx + 176 + keyW, -- 266
					subY + 6, -- 266
					toColor(PALETTE.crimsonCore), -- 266
					0, -- 266
					0.5, -- 266
					"Left", -- 266
					0.8, -- 266
					alpha * pulse, -- 266
					0.08 -- 266
				) -- 266
			else -- 266
				texts:put( -- 268
					"xs", -- 268
					"受惊停步", -- 268
					bx + 172, -- 268
					subY + 6, -- 268
					toColor(PALETTE.crimsonCore), -- 268
					0, -- 268
					0.5, -- 268
					"Left", -- 268
					0.8, -- 268
					alpha * pulse, -- 268
					0.08 -- 268
				) -- 268
			end -- 268
		elseif calming then -- 268
			texts:put( -- 271
				"xs", -- 271
				"轻敲安抚中", -- 271
				bx + 172, -- 271
				subY + 6, -- 271
				toColor(PALETTE.emerald), -- 271
				0, -- 271
				0.5, -- 271
				"Left", -- 271
				0.8, -- 271
				alpha, -- 271
				0.08 -- 271
			) -- 271
		end -- 271
	end -- 271
	local ranks = p:getStoryTalentRanks() -- 275
	if ranks ~= nil then -- 275
		local parts = {} -- 277
		if ranks.vitality > 0 then -- 277
			parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 278
		end -- 278
		if ranks.reload > 0 then -- 278
			parts[#parts + 1] = "熟铳" .. tostring(ranks.reload) -- 279
		end -- 279
		if ranks.guard > 0 then -- 279
			parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 280
		end -- 280
		if ranks.craft > 0 then -- 280
			parts[#parts + 1] = "巧手" .. tostring(ranks.craft) -- 281
		end -- 281
		if #parts > 0 then -- 281
			local subY = by - 22 -- 283
			local txt = "本领 · " .. table.concat(parts, " · ") -- 284
			drawSilkVeil( -- 285
				uiDraw, -- 285
				uiArt, -- 285
				"hud_talent_ranks_veil", -- 285
				bx + 126, -- 285
				subY + 6, -- 285
				260, -- 285
				26, -- 285
				PALETTE.inkWash, -- 285
				0.56 * alpha, -- 285
				-1 -- 285
			) -- 285
			texts:put( -- 286
				"xs", -- 286
				txt, -- 286
				bx + 14, -- 286
				subY + 6, -- 286
				toColor(PALETTE.amberCore), -- 286
				0, -- 286
				0.5, -- 286
				"Left", -- 286
				0.8, -- 286
				alpha, -- 286
				0.08 -- 286
			) -- 286
		end -- 286
	elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 286
		local inv = p.run.inventory -- 289
		local items = {} -- 290
		if inv.shield > 0 then -- 290
			items[#items + 1] = "残盾" .. tostring(inv.shield) -- 291
		end -- 291
		if inv.wedge > 0 then -- 291
			items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 292
		end -- 292
		if inv.ammo > 0 then -- 292
			items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 293
		end -- 293
		if inv.scrap > 0 then -- 293
			items[#items + 1] = "木料" .. tostring(inv.scrap) -- 294
		end -- 294
		local companionText = p.run.joined and "小满同行" or "小满等待" -- 295
		local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 296
		local subY = by - 22 -- 297
		drawSilkVeil( -- 298
			uiDraw, -- 298
			uiArt, -- 298
			"hud_camp_veil", -- 298
			bx + 126, -- 298
			subY + 6, -- 298
			260, -- 298
			26, -- 298
			PALETTE.inkWash, -- 298
			0.54 * alpha, -- 298
			-1 -- 298
		) -- 298
		texts:put( -- 299
			"xs", -- 299
			summary, -- 299
			bx + 14, -- 299
			subY + 6, -- 299
			toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 299
			0, -- 299
			0.5, -- 299
			"Left", -- 299
			0.8, -- 299
			alpha, -- 299
			0.08 -- 299
		) -- 299
	end -- 299
end -- 164
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 303
	local bx = 28 + safe.left -- 316
	local by = h - 68 - safe.top -- 317
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 318
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 319
	drawSilkVeil( -- 321
		uiDraw, -- 321
		uiArt, -- 321
		"hud_child_veil", -- 321
		bx + 144, -- 321
		by + 22, -- 321
		316, -- 321
		48, -- 321
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 321
		0.58 * alpha, -- 321
		-1 -- 321
	) -- 321
	texts:put( -- 322
		"md", -- 322
		alert and "危" or "满", -- 322
		bx + 16, -- 322
		by + 22, -- 322
		toColor(leadCol), -- 322
		0.5, -- 322
		0.5, -- 322
		"Center", -- 322
		0, -- 322
		alpha, -- 322
		0.1 -- 322
	) -- 322
	uiInkDraw:drawSegment( -- 323
		Vec2(bx + 32, by + 7), -- 323
		Vec2(bx + 32, by + 37), -- 323
		0.8, -- 323
		toColor(PALETTE.silkDim, 130 * alpha) -- 323
	) -- 323
	texts:put( -- 324
		"xs", -- 324
		"小满 · 潜行", -- 324
		bx + 44, -- 324
		by + 33, -- 324
		toColor(PALETTE.amberCore), -- 324
		0, -- 324
		0.5, -- 324
		"Left", -- 324
		1.4, -- 324
		alpha, -- 324
		0.08 -- 324
	) -- 324
	local posture = "轻步前行 · 保持隐蔽" -- 326
	local col = PALETTE.textMid -- 327
	if alert then -- 327
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 329
		col = PALETTE.crimsonCore -- 330
	elseif p.player.crouch then -- 330
		posture = "低姿伏行 · 匿迹于影" -- 332
		col = PALETTE.emerald -- 333
	elseif p.hasBottle then -- 333
		posture = assistHintsEnabled and adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 335
		col = PALETTE.amberCore -- 338
	end -- 338
	texts:put( -- 340
		"xs", -- 340
		posture, -- 340
		bx + 44, -- 340
		by + 12, -- 340
		toColor(col), -- 340
		0, -- 340
		0.5, -- 340
		"Left", -- 340
		0.6, -- 340
		alpha, -- 340
		0.08 -- 340
	) -- 340
end -- 303
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible) -- 343
	local theme = themeOf(p.room.key) -- 355
	local rx = w - 32 - safe.right - (touchOverlayVisible and 104 or 0) -- 356
	local cy = h - 44 - safe.top -- 357
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc 暂歇" -- 358
	drawSilkVeil( -- 360
		uiDraw, -- 360
		uiArt, -- 360
		"hud_chap_veil", -- 360
		rx - 82, -- 360
		cy, -- 360
		240, -- 360
		44, -- 360
		PALETTE.inkWash, -- 360
		0.44 * alpha, -- 360
		-1 -- 360
	) -- 360
	texts:put( -- 361
		"xs", -- 361
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 361
		rx, -- 361
		touchOverlayVisible and cy or cy + 9, -- 361
		toColor(PALETTE.textBright), -- 361
		1, -- 361
		0.5, -- 361
		"Right", -- 361
		1.2, -- 361
		alpha, -- 361
		0.08 -- 361
	) -- 361
	if not touchOverlayVisible then -- 361
		texts:put( -- 363
			"xs", -- 363
			pauseTip, -- 363
			rx, -- 363
			cy - 11, -- 363
			toColor(PALETTE.textDim), -- 363
			1, -- 363
			0.5, -- 363
			"Right", -- 363
			1, -- 363
			0.78 * alpha, -- 363
			0.08 -- 363
		) -- 363
	end -- 363
end -- 343
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 367
	local touchMode = inputMode == "touch" -- 381
	local talentOffers = p:getStoryTalentOffers() -- 382
	if #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 382
		local boxes = self:talentCardRects( -- 384
			w, -- 384
			h, -- 384
			#talentOffers, -- 384
			touchMode, -- 384
			safe.top -- 384
		) -- 384
		local cx = w * 0.5 -- 385
		local titleY = h - 54 - safe.top -- 386
		local talentHint = inputMode == "gamepad" and "护送本领三选一 · LB/RB 择项 · L3 确认或点选" or (touchMode and "护送本领三选一 · 轻触卡面习得" or "护送本领三选一 · 按 1 / 2 / 3 或点击习得") -- 387
		drawSilkVeil( -- 392
			uiDraw, -- 392
			uiArt, -- 392
			"hud_talent_head_veil", -- 392
			cx, -- 392
			titleY, -- 392
			410, -- 392
			26, -- 392
			PALETTE.inkWash, -- 392
			0.72 * alpha, -- 392
			-1 -- 392
		) -- 392
		drawHairline( -- 393
			uiInkDraw, -- 393
			uiArt, -- 393
			"hud_talent_head_line", -- 393
			cx, -- 393
			titleY + 13, -- 393
			330, -- 393
			PALETTE.amber, -- 393
			0.52 * alpha, -- 393
			true, -- 393
			2 -- 393
		) -- 393
		texts:put( -- 394
			"xs", -- 394
			talentHint, -- 394
			cx, -- 394
			titleY, -- 394
			toColor(PALETTE.amberCore), -- 394
			0.5, -- 394
			0.5, -- 394
			"Center", -- 394
			1.2, -- 394
			alpha, -- 394
			0.08 -- 394
		) -- 394
		local ti = 0 -- 396
		do -- 396
			ti = 0 -- 397
			while ti < #talentOffers do -- 397
				local box = boxes[ti + 1] -- 398
				local bx = box.x -- 399
				local by = box.y -- 400
				local bh = box.height -- 401
				local cy = by + bh * 0.5 -- 402
				local gpFocus = inputMode == "gamepad" and ti == self.talentSelected -- 403
				local borderCol = gpFocus and PALETTE.rouge or PALETTE.amber -- 404
				uiDraw:drawRect( -- 405
					box, -- 406
					toColor( -- 407
						gpFocus and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 407
						math.floor((gpFocus and 235 or 215) * alpha + 0.5) -- 407
					), -- 407
					gpFocus and 1.5 or 0.9, -- 408
					toColor( -- 409
						borderCol, -- 409
						math.floor((gpFocus and 235 or 185) * alpha + 0.5) -- 409
					) -- 409
				) -- 409
				drawSilkKeycap( -- 411
					uiInkDraw, -- 411
					texts, -- 411
					bx + 8, -- 411
					cy - 11, -- 411
					22, -- 411
					22, -- 411
					"" .. tostring(ti + 1), -- 411
					borderCol, -- 411
					alpha, -- 411
					true -- 411
				) -- 411
				texts:put( -- 412
					"xs", -- 412
					talentNames[talentOffers[ti + 1]], -- 412
					bx + 38, -- 412
					cy, -- 412
					toColor(PALETTE.textBright), -- 412
					0, -- 412
					0.5, -- 412
					"Left", -- 412
					0.6, -- 412
					alpha, -- 412
					0.08 -- 412
				) -- 412
				ti = ti + 1 -- 397
			end -- 397
		end -- 397
	end -- 397
	if p.craftBench.active then -- 397
		local bw = 470 -- 417
		local cx = w * 0.5 -- 418
		local top = h * 0.32 -- 419
		drawSilkVeil( -- 420
			uiDraw, -- 420
			uiArt, -- 420
			"hud_bench_veil", -- 420
			cx, -- 420
			top + 118, -- 420
			bw + 64, -- 420
			208, -- 420
			PALETTE.inkWash, -- 420
			0.86 * alpha, -- 420
			-1 -- 420
		) -- 420
		texts:put( -- 421
			"xs", -- 421
			"工台 · 放她下来做一件", -- 421
			cx, -- 421
			top - 6, -- 421
			toColor(PALETTE.textBright), -- 421
			0.5, -- 421
			0.5, -- 421
			"Center", -- 421
			1.7, -- 421
			alpha, -- 421
			0.08 -- 421
		) -- 421
		local inv = p.craftBench.inventory -- 422
		local wood = inv.wood or 0 -- 423
		local bell = inv.bell or 0 -- 424
		local scrap = inv.scrap or 0 -- 425
		texts:put( -- 426
			"xs", -- 426
			(((("木纹筹 " .. tostring(wood)) .. " · 铃纹筹 ") .. tostring(bell)) .. " · 碎片 ") .. tostring(scrap), -- 426
			cx, -- 426
			top + 24, -- 426
			toColor(PALETTE.silkDim), -- 427
			0.5, -- 427
			0.5, -- 427
			"Center", -- 427
			1.5, -- 427
			alpha, -- 427
			0.08 -- 427
		) -- 427
		local recipes = p.craftBench.recipes -- 428
		do -- 428
			local i = 0 -- 429
			while i < #recipes do -- 429
				local r = recipes[i + 1] -- 430
				local costText = "" -- 431
				local afford = true -- 432
				local costWood = r.cost.wood or 0 -- 433
				local costBell = r.cost.bell or 0 -- 434
				if costWood > 0 then -- 434
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "木 ") .. tostring(costWood) -- 436
					if wood < costWood then -- 436
						afford = false -- 437
					end -- 437
				end -- 437
				if costBell > 0 then -- 437
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "铃 ") .. tostring(costBell) -- 440
					if bell < costBell then -- 440
						afford = false -- 441
					end -- 441
				end -- 441
				local equipped = p.craftBench.equippedWeapon == r.id -- 443
				local state = r.crafted and "已做成" or (afford and "可制作" or "缺料") -- 444
				local mark = equipped and " ◈" or "" -- 445
				texts:put( -- 446
					"xs", -- 446
					((((r.name .. " · ") .. costText) .. " · ") .. state) .. mark, -- 446
					cx, -- 446
					top + 56 + i * 26, -- 446
					toColor(equipped and PALETTE.cyanCore or (r.crafted and PALETTE.silkDim or PALETTE.textBright)), -- 447
					0.5, -- 448
					0.5, -- 448
					"Center", -- 448
					1.6, -- 448
					alpha, -- 448
					0.08 -- 448
				) -- 448
				i = i + 1 -- 429
			end -- 429
		end -- 429
		local firstMade = p.craftBench.firstCraftDone and " · 首制完成" or "" -- 450
		texts:put( -- 451
			"xs", -- 451
			"E 制作 · Q 装备 · Esc 离开" .. firstMade, -- 451
			cx, -- 451
			top + 128, -- 451
			toColor(PALETTE.amber), -- 452
			0.5, -- 452
			0.5, -- 452
			"Center", -- 452
			1.5, -- 452
			alpha, -- 452
			0.06 -- 452
		) -- 452
	end -- 452
	if p.reloadOpen then -- 452
		local bw = 400 -- 456
		local cx = w * 0.5 -- 457
		local by = h - 64 - safe.top -- 458
		local ratio = math.max( -- 459
			0, -- 459
			math.min(1, p.reloadAnswerTicks / 240) -- 459
		) -- 459
		local effect = p.reloadPendingEffect -- 460
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 461
		drawSilkVeil( -- 464
			uiDraw, -- 464
			uiArt, -- 464
			"hud_reload_veil", -- 464
			cx, -- 464
			by + 18, -- 464
			bw + 90, -- 464
			48, -- 464
			PALETTE.inkWash, -- 464
			0.76 * alpha, -- 464
			-1 -- 464
		) -- 464
		drawHairline( -- 465
			uiInkDraw, -- 465
			uiArt, -- 465
			"hud_reload_top", -- 465
			cx, -- 465
			by + 39, -- 465
			bw - 20, -- 465
			PALETTE.cyan, -- 465
			0.55 * alpha, -- 465
			false, -- 465
			2 -- 465
		) -- 465
		texts:put( -- 466
			"xs", -- 466
			label, -- 466
			cx, -- 466
			by + 26, -- 466
			toColor(PALETTE.textBright), -- 466
			0.5, -- 466
			0.5, -- 466
			"Center", -- 466
			1.8, -- 466
			alpha, -- 466
			0.08 -- 466
		) -- 466
		do -- 466
			local n = 0 -- 468
			while n < 9 do -- 468
				local col = n % 3 -- 469
				local row = math.floor(n / 3) -- 470
				local nx = cx + (col - 1) * 13 -- 471
				local ny = by + 50 + row * 12 -- 472
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 473
				local isEnd = n == 8 -- 474
				uiArt:tryPlace( -- 475
					"ink_enso_fine", -- 475
					"reload_node_" .. tostring(n), -- 475
					nx, -- 475
					ny, -- 475
					isEnd and 10 or 6, -- 475
					isEnd and 10 or 6, -- 475
					{ -- 475
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 476
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 477
						layer = 3 -- 477
					} -- 477
				) -- 477
				n = n + 1 -- 468
			end -- 468
		end -- 468
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
				toColor(PALETTE.cyan, 220 * alpha) -- 486
			) -- 486
			uiInkDraw:drawSegment( -- 487
				Vec2(pbx, pby), -- 487
				Vec2(pbx + pbw * ratio, pby), -- 487
				1, -- 487
				toColor(PALETTE.cyanCore, 160 * alpha) -- 487
			) -- 487
		end -- 487
	end -- 487
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 487
		local g = p.room.story.gate -- 492
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 492
			local bw = 400 -- 494
			local cx = w * 0.5 -- 495
			local by = h - 64 - safe.top -- 496
			local tied = p.phase == "gate-hand" -- 497
			local ratio = tied and 1 or math.max( -- 498
				0, -- 498
				math.min( -- 498
					1, -- 498
					p.handTicks / math.max(1, p.handNeedTicks) -- 498
				) -- 498
			) -- 498
			local holdInteractKey = adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 499
			local reholdInteractKey = adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 500
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 501
			drawSilkVeil( -- 505
				uiDraw, -- 505
				uiArt, -- 505
				"hud_hand_veil", -- 505
				cx, -- 505
				by + 18, -- 505
				bw + 90, -- 505
				48, -- 505
				PALETTE.inkWash, -- 505
				0.76 * alpha, -- 505
				-1 -- 505
			) -- 505
			drawHairline( -- 506
				uiInkDraw, -- 506
				uiArt, -- 506
				"hud_hand_top", -- 506
				cx, -- 506
				by + 39, -- 506
				bw - 20, -- 506
				PALETTE.amber, -- 506
				0.55 * alpha, -- 506
				false, -- 506
				2 -- 506
			) -- 506
			texts:put( -- 507
				"xs", -- 507
				label, -- 507
				cx, -- 507
				by + 26, -- 507
				toColor(PALETTE.textBright), -- 507
				0.5, -- 507
				0.5, -- 507
				"Center", -- 507
				1.8, -- 507
				alpha, -- 507
				0.08 -- 507
			) -- 507
			local pbw = bw - 80 -- 509
			local pbx = cx - pbw * 0.5 -- 510
			local pby = by + 9 -- 511
			uiInkDraw:drawSegment( -- 512
				Vec2(pbx, pby), -- 512
				Vec2(pbx + pbw, pby), -- 512
				1.4, -- 512
				toColor(PALETTE.silkDim, 115 * alpha) -- 512
			) -- 512
			if ratio > 0.002 then -- 512
				uiInkDraw:drawSegment( -- 514
					Vec2(pbx, pby), -- 514
					Vec2(pbx + pbw * ratio, pby), -- 514
					2.8, -- 514
					toColor(PALETTE.amber, 230 * alpha) -- 514
				) -- 514
				uiInkDraw:drawSegment( -- 515
					Vec2(pbx, pby), -- 515
					Vec2(pbx + pbw * ratio, pby), -- 515
					1, -- 515
					toColor(PALETTE.amberCore, 165 * alpha) -- 515
				) -- 515
			end -- 515
			uiArt:tryPlace( -- 517
				"ink_enso_fine", -- 517
				"hand_knock_1", -- 517
				pbx + pbw * 0.62, -- 517
				pby, -- 517
				11, -- 517
				11, -- 517
				{ -- 517
					color = toColor(PALETTE.amber), -- 518
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 518
					layer = 3 -- 518
				} -- 518
			) -- 518
			uiArt:tryPlace( -- 520
				"ink_enso_fine", -- 520
				"hand_knock_2", -- 520
				pbx + pbw * 0.72, -- 520
				pby, -- 520
				11, -- 520
				11, -- 520
				{ -- 520
					color = toColor(PALETTE.amber), -- 521
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 521
					layer = 3 -- 521
				} -- 521
			) -- 521
		end -- 521
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 521
			local bw = 400 -- 525
			local cx = w * 0.5 -- 526
			local by = h - 64 - safe.top -- 527
			local ratio = math.max( -- 528
				0, -- 528
				math.min( -- 528
					1, -- 528
					p.gateTick / math.max(1, g.holdTicks) -- 528
				) -- 528
			) -- 528
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 529
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 530
			drawSilkVeil( -- 532
				uiDraw, -- 532
				uiArt, -- 532
				"hud_gate_veil", -- 532
				cx, -- 532
				by + 18, -- 532
				bw + 90, -- 532
				48, -- 532
				PALETTE.inkWash, -- 532
				0.76 * alpha, -- 532
				-1 -- 532
			) -- 532
			drawHairline( -- 533
				uiInkDraw, -- 533
				uiArt, -- 533
				"hud_gate_top", -- 533
				cx, -- 533
				by + 39, -- 533
				bw - 20, -- 533
				PALETTE.rougeSoft, -- 533
				0.55 * alpha, -- 533
				false, -- 533
				2 -- 533
			) -- 533
			local idleNeedConfirmLabel = assistHintsEnabled and adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 535
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 538
			texts:put( -- 541
				"xs", -- 541
				label, -- 541
				cx, -- 541
				by + 26, -- 541
				toColor(PALETTE.textBright), -- 541
				0.5, -- 541
				0.5, -- 541
				"Center", -- 541
				1.8, -- 541
				alpha, -- 541
				0.08 -- 541
			) -- 541
			local pbw = bw - 80 -- 543
			local pbx = cx - pbw * 0.5 -- 544
			local pby = by + 9 -- 545
			uiInkDraw:drawSegment( -- 546
				Vec2(pbx, pby), -- 546
				Vec2(pbx + pbw, pby), -- 546
				1.4, -- 546
				toColor(PALETTE.silkDim, 115 * alpha) -- 546
			) -- 546
			if ratio > 0.002 then -- 546
				uiInkDraw:drawSegment( -- 548
					Vec2(pbx, pby), -- 548
					Vec2(pbx + pbw * ratio, pby), -- 548
					2.8, -- 548
					toColor(PALETTE.rouge, 230 * alpha) -- 548
				) -- 548
				uiInkDraw:drawSegment( -- 549
					Vec2(pbx, pby), -- 549
					Vec2(pbx + pbw * ratio, pby), -- 549
					1, -- 549
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 549
				) -- 549
			end -- 549
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 551
			local k = 0 -- 552
			do -- 552
				k = 0 -- 553
				while k < #waves do -- 553
					local wx = pbx + pbw * waves[k + 1] -- 554
					local passed = p.gateSpawned > k -- 555
					if passed then -- 555
						drawBlossomDot( -- 557
							uiInkDraw, -- 557
							uiArt, -- 557
							"gate_wave_" .. tostring(k), -- 557
							wx, -- 557
							pby, -- 557
							10, -- 557
							PALETTE.moonPale, -- 557
							0.92 * alpha, -- 557
							3 -- 557
						) -- 557
					else -- 557
						uiArt:tryPlace( -- 559
							"ink_enso_fine", -- 559
							"gate_wave_" .. tostring(k), -- 559
							wx, -- 559
							pby, -- 559
							11, -- 559
							11, -- 559
							{ -- 559
								color = toColor(PALETTE.rouge), -- 560
								opacity = 0.84 * alpha, -- 560
								layer = 3 -- 560
							} -- 560
						) -- 560
					end -- 560
					k = k + 1 -- 553
				end -- 553
			end -- 553
		end -- 553
		return -- 565
	end -- 565
	if not assistHintsEnabled then -- 565
		return -- 569
	end -- 569
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 569
		local cx = w * 0.5 -- 572
		local by = h - 44 - safe.top -- 573
		local step1 = p.cartDocked -- 574
		local ____temp_0 -- 575
		if p.room.key == "checkpoint" then -- 575
			____temp_0 = p.gateOpen -- 575
		else -- 575
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 575
		end -- 575
		local step2 = ____temp_0 -- 575
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 576
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 577
		drawSilkVeil( -- 579
			uiDraw, -- 579
			uiArt, -- 579
			"hud_obj_veil", -- 579
			cx, -- 579
			by, -- 579
			380, -- 579
			34, -- 579
			PALETTE.inkWash, -- 579
			0.58 * alpha, -- 579
			-1 -- 579
		) -- 579
		local x1 = cx - 134 -- 581
		if step1 then -- 581
			drawBlossomDot( -- 583
				uiInkDraw, -- 583
				uiArt, -- 583
				"obj_m1", -- 583
				x1, -- 583
				by, -- 583
				11, -- 583
				PALETTE.emerald, -- 583
				0.94 * alpha, -- 583
				3 -- 583
			) -- 583
		else -- 583
			uiArt:tryPlace( -- 585
				"ink_enso_fine", -- 585
				"obj_m1", -- 585
				x1, -- 585
				by, -- 585
				11, -- 585
				11, -- 585
				{ -- 585
					color = toColor(PALETTE.silkLine), -- 585
					opacity = 0.72 * alpha, -- 585
					layer = 3 -- 585
				} -- 585
			) -- 585
		end -- 585
		texts:put( -- 587
			"xs", -- 587
			t1, -- 587
			x1 + 13, -- 587
			by, -- 587
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 587
			0, -- 587
			0.5, -- 587
			"Left", -- 587
			1, -- 587
			alpha, -- 587
			0.08 -- 587
		) -- 587
		local x2 = cx + 18 -- 589
		if step2 then -- 589
			drawBlossomDot( -- 591
				uiInkDraw, -- 591
				uiArt, -- 591
				"obj_m2", -- 591
				x2, -- 591
				by, -- 591
				11, -- 591
				PALETTE.emerald, -- 591
				0.94 * alpha, -- 591
				3 -- 591
			) -- 591
		else -- 591
			uiArt:tryPlace( -- 593
				"ink_enso_fine", -- 593
				"obj_m2", -- 593
				x2, -- 593
				by, -- 593
				11, -- 593
				11, -- 593
				{ -- 593
					color = toColor(PALETTE.silkDim), -- 593
					opacity = 0.62 * alpha, -- 593
					layer = 3 -- 593
				} -- 593
			) -- 593
		end -- 593
		texts:put( -- 595
			"xs", -- 595
			t2, -- 595
			x2 + 13, -- 595
			by, -- 595
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 595
			0, -- 595
			0.5, -- 595
			"Left", -- 595
			1, -- 595
			alpha, -- 595
			0.08 -- 595
		) -- 595
	end -- 595
end -- 367
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 599
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
			local sx = math.max( -- 620
				padX + safe.left, -- 620
				math.min( -- 620
					viewW - padX - safe.right, -- 620
					cam:sx(pr.x) / uiScale -- 620
				) -- 620
			) -- 620
			local sy = math.max( -- 621
				96 + safe.bottom, -- 621
				math.min( -- 621
					viewH - 110 - safe.top, -- 621
					cam:sy(pr.y) / uiScale + bob -- 621
				) -- 621
			) -- 621
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 622
			uiInkDraw:drawSegment( -- 624
				Vec2(sx, sy - 14), -- 624
				Vec2(sx, sy - 27), -- 624
				0.8, -- 624
				toColor(accent, 135 * alpha) -- 624
			) -- 624
			drawBlossomDot( -- 625
				uiInkDraw, -- 625
				uiArt, -- 625
				"wp_anchor_" .. tostring(i), -- 625
				sx, -- 625
				sy - 28, -- 625
				7, -- 625
				accent, -- 625
				0.85 * alpha, -- 625
				3 -- 625
			) -- 625
			local px = sx - pillW * 0.5 -- 627
			local py = sy - 12 -- 628
			drawSilkVeil( -- 630
				uiDraw, -- 630
				uiArt, -- 630
				"wp_bg_" .. tostring(i), -- 630
				sx, -- 630
				py + 12, -- 630
				pillW + 40, -- 630
				32, -- 630
				PALETTE.inkWash, -- 630
				0.78 * alpha, -- 630
				0 -- 630
			) -- 630
			drawHairline( -- 631
				uiInkDraw, -- 631
				uiArt, -- 631
				"wp_line_" .. tostring(i), -- 631
				sx, -- 631
				py + 24, -- 631
				pillW + 4, -- 631
				accent, -- 631
				0.45 * alpha, -- 631
				false, -- 631
				2 -- 631
			) -- 631
			drawSilkKeycap( -- 632
				uiInkDraw, -- 632
				texts, -- 632
				px + 2, -- 632
				py + 2, -- 632
				keyW, -- 632
				20, -- 632
				pr.keyTag, -- 632
				accent, -- 632
				alpha, -- 632
				pr.urgent -- 632
			) -- 632
			texts:put( -- 633
				"xs", -- 633
				pr.label, -- 633
				px + keyW + 12, -- 633
				py + 12, -- 633
				toColor(PALETTE.textBright), -- 633
				0, -- 633
				0.5, -- 633
				"Left", -- 633
				0.8, -- 633
				alpha, -- 633
				0.08 -- 633
			) -- 633
			i = i + 1 -- 614
		end -- 614
	end -- 614
end -- 599
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 637
	local mx = p.aimX / uiScale -- 647
	local my = p.aimY / uiScale -- 648
	if mx <= 0 and my <= 0 then -- 648
		return -- 650
	end -- 650
	if p.childMode then -- 650
		local aiming = p.room.key == "village" and p.hasBottle -- 654
		if touchMode and (not aiming or p.aimHold <= 0) then -- 654
			return -- 656
		end -- 656
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 658
		uiInkDraw:drawDot( -- 659
			Vec2(mx, my), -- 659
			aiming and 2 or 1.6, -- 659
			toColor(col, aiming and 215 or 120) -- 659
		) -- 659
		if aiming then -- 659
			local sz = p.aimHold > 0 and 32 or 24 -- 661
			uiArt:tryPlace( -- 662
				"ink_enso_fine", -- 662
				"reticle_child", -- 662
				mx, -- 662
				my, -- 662
				sz, -- 662
				sz, -- 662
				{ -- 662
					color = toColor(PALETTE.amberCore), -- 663
					opacity = 0.82, -- 663
					angle = self.time * 24, -- 663
					layer = 5 -- 663
				} -- 663
			) -- 663
		end -- 663
		return -- 666
	end -- 666
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 669
	local onEnemy = false -- 670
	local i = 0 -- 671
	do -- 671
		i = 0 -- 672
		while i < #p.enemies do -- 672
			local e = p.enemies[i + 1] -- 673
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 674
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 674
				onEnemy = true -- 676
			end -- 676
			i = i + 1 -- 672
		end -- 672
	end -- 672
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 680
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 681
	local arm = onEnemy and 8.5 or 9.5 -- 682
	local bg = Color(10, 12, 18, 160) -- 683
	uiInkDraw:drawSegment( -- 685
		Vec2(mx - gap - arm, my), -- 685
		Vec2(mx - gap, my), -- 685
		2.1, -- 685
		bg -- 685
	) -- 685
	uiInkDraw:drawSegment( -- 686
		Vec2(mx + gap, my), -- 686
		Vec2(mx + gap + arm, my), -- 686
		2.1, -- 686
		bg -- 686
	) -- 686
	uiInkDraw:drawSegment( -- 687
		Vec2(mx, my - gap - arm), -- 687
		Vec2(mx, my - gap), -- 687
		2.1, -- 687
		bg -- 687
	) -- 687
	uiInkDraw:drawSegment( -- 688
		Vec2(mx, my + gap), -- 688
		Vec2(mx, my + gap + arm), -- 688
		2.1, -- 688
		bg -- 688
	) -- 688
	uiInkDraw:drawSegment( -- 690
		Vec2(mx - gap - arm, my), -- 690
		Vec2(mx - gap, my), -- 690
		1.1, -- 690
		toColor(col, 230) -- 690
	) -- 690
	uiInkDraw:drawSegment( -- 691
		Vec2(mx + gap, my), -- 691
		Vec2(mx + gap + arm, my), -- 691
		1.1, -- 691
		toColor(col, 230) -- 691
	) -- 691
	uiInkDraw:drawSegment( -- 692
		Vec2(mx, my - gap - arm), -- 692
		Vec2(mx, my - gap), -- 692
		1.1, -- 692
		toColor(col, 230) -- 692
	) -- 692
	uiInkDraw:drawSegment( -- 693
		Vec2(mx, my + gap), -- 693
		Vec2(mx, my + gap + arm), -- 693
		1.1, -- 693
		toColor(col, 230) -- 693
	) -- 693
	uiInkDraw:drawDot( -- 694
		Vec2(mx, my), -- 694
		1.8, -- 694
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 694
	) -- 694
	if onEnemy then -- 694
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 697
		uiArt:tryPlace( -- 698
			"ink_enso_fine", -- 698
			"reticle_lock", -- 698
			mx, -- 698
			my, -- 698
			sz, -- 698
			sz, -- 698
			{ -- 698
				color = toColor(PALETTE.rouge), -- 699
				opacity = 0.88, -- 699
				angle = self.time * 38, -- 699
				layer = 5 -- 699
			} -- 699
		) -- 699
		fillRadialGlow( -- 701
			uiGlow, -- 701
			mx, -- 701
			my, -- 701
			16, -- 701
			16, -- 701
			toColor(PALETTE.rouge, 30), -- 701
			Color(182, 58, 56, 0), -- 701
			10 -- 701
		) -- 701
	end -- 701
end -- 637
return ____exports -- 637