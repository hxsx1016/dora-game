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
	if self.ghostHp > p.hp then -- 47
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 48
	else -- 48
		self.ghostHp = p.hp -- 50
	end -- 50
end -- 45
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible) -- 54
	if assistHintsEnabled == nil then -- 65
		assistHintsEnabled = false -- 65
	end -- 65
	if suppressReticle == nil then -- 66
		suppressReticle = false -- 66
	end -- 66
	if inputMode == nil then -- 67
		inputMode = "kbm" -- 67
	end -- 67
	if gamepadLayout == nil then -- 68
		gamepadLayout = "xbox" -- 68
	end -- 68
	if safe == nil then -- 69
		safe = ZERO_SAFE_INSETS -- 69
	end -- 69
	if retryHoldProgress == nil then -- 70
		retryHoldProgress = 0 -- 70
	end -- 70
	if touchOverlayVisible == nil then -- 71
		touchOverlayVisible = false -- 71
	end -- 71
	local w = cam.viewW / uiScale -- 73
	local h = cam.viewH / uiScale -- 74
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 75
	if hudAlpha > 0.05 then -- 77
		if p.childMode then -- 78
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
		if assistHintsEnabled then -- 87
			local prompt = deriveWorldPrompt(p) -- 88
			if prompt ~= nil then -- 89
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
		if vfx.deflectFlash > 0.25 then -- 102
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
	if retryHoldProgress > 0.02 then -- 110
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
	if not suppressReticle then -- 122
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
	if count <= 0 then -- 130
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
	if touchMode == nil then -- 156
		touchMode = false -- 156
	end -- 156
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 158
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
			if not uiArt:tryPlace( -- 197
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
			if self.ghostHp > i and self.ghostHp > p.hp then -- 202
				local frac = math.min(1, self.ghostHp - i) -- 203
				uiInkDraw:drawRect( -- 204
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 204
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 204
				) -- 204
			end -- 204
			if p.hp > i then -- 206
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 207
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 208
				if not uiArt:tryPlace( -- 209
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
			if p.enemies[i + 1].alive then -- 220
				hasAliveEnemy = true -- 221
				break -- 222
			end -- 222
			i = i + 1 -- 219
		end -- 219
	end -- 219
	if p.coverHug then -- 225
		if hasAliveEnemy and not p.coverBlocking then -- 226
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
	elseif p.coverNear then -- 233
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
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 238
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
				if lit then -- 255
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
		if frozen then -- 260
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 261
			if assistHintsEnabled then -- 262
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
		elseif calming then -- 270
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
	if ranks ~= nil then -- 276
		local parts = {} -- 277
		if ranks.vitality > 0 then -- 278
			parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 278
		end -- 278
		if ranks.reload > 0 then -- 279
			parts[#parts + 1] = "熟铳" .. tostring(ranks.reload) -- 279
		end -- 279
		if ranks.guard > 0 then -- 280
			parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 280
		end -- 280
		if ranks.craft > 0 then -- 281
			parts[#parts + 1] = "巧手" .. tostring(ranks.craft) -- 281
		end -- 281
		if #parts > 0 then -- 282
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
	elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 288
		local inv = p.run.inventory -- 289
		local items = {} -- 290
		if inv.shield > 0 then -- 291
			items[#items + 1] = "残盾" .. tostring(inv.shield) -- 291
		end -- 291
		if inv.wedge > 0 then -- 292
			items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 292
		end -- 292
		if inv.ammo > 0 then -- 293
			items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 293
		end -- 293
		if inv.scrap > 0 then -- 294
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
	if alert then -- 328
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 329
		col = PALETTE.crimsonCore -- 330
	elseif p.player.crouch then -- 331
		posture = "低姿伏行 · 匿迹于影" -- 332
		col = PALETTE.emerald -- 333
	elseif p.hasBottle then -- 334
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
	if not touchOverlayVisible then -- 362
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
	if #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 383
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
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 419
		local g = p.room.story.gate -- 420
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 421
			local bw = 400 -- 422
			local cx = w * 0.5 -- 423
			local by = h - 64 - safe.top -- 424
			local tied = p.phase == "gate-hand" -- 425
			local ratio = tied and 1 or math.max( -- 426
				0, -- 426
				math.min( -- 426
					1, -- 426
					p.handTicks / math.max(1, p.handNeedTicks) -- 426
				) -- 426
			) -- 426
			local holdInteractKey = adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 427
			local reholdInteractKey = adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 428
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 429
			drawSilkVeil( -- 433
				uiDraw, -- 433
				uiArt, -- 433
				"hud_hand_veil", -- 433
				cx, -- 433
				by + 18, -- 433
				bw + 90, -- 433
				48, -- 433
				PALETTE.inkWash, -- 433
				0.76 * alpha, -- 433
				-1 -- 433
			) -- 433
			drawHairline( -- 434
				uiInkDraw, -- 434
				uiArt, -- 434
				"hud_hand_top", -- 434
				cx, -- 434
				by + 39, -- 434
				bw - 20, -- 434
				PALETTE.amber, -- 434
				0.55 * alpha, -- 434
				false, -- 434
				2 -- 434
			) -- 434
			texts:put( -- 435
				"xs", -- 435
				label, -- 435
				cx, -- 435
				by + 26, -- 435
				toColor(PALETTE.textBright), -- 435
				0.5, -- 435
				0.5, -- 435
				"Center", -- 435
				1.8, -- 435
				alpha, -- 435
				0.08 -- 435
			) -- 435
			local pbw = bw - 80 -- 437
			local pbx = cx - pbw * 0.5 -- 438
			local pby = by + 9 -- 439
			uiInkDraw:drawSegment( -- 440
				Vec2(pbx, pby), -- 440
				Vec2(pbx + pbw, pby), -- 440
				1.4, -- 440
				toColor(PALETTE.silkDim, 115 * alpha) -- 440
			) -- 440
			if ratio > 0.002 then -- 441
				uiInkDraw:drawSegment( -- 442
					Vec2(pbx, pby), -- 442
					Vec2(pbx + pbw * ratio, pby), -- 442
					2.8, -- 442
					toColor(PALETTE.amber, 230 * alpha) -- 442
				) -- 442
				uiInkDraw:drawSegment( -- 443
					Vec2(pbx, pby), -- 443
					Vec2(pbx + pbw * ratio, pby), -- 443
					1, -- 443
					toColor(PALETTE.amberCore, 165 * alpha) -- 443
				) -- 443
			end -- 443
			uiArt:tryPlace( -- 445
				"ink_enso_fine", -- 445
				"hand_knock_1", -- 445
				pbx + pbw * 0.62, -- 445
				pby, -- 445
				11, -- 445
				11, -- 445
				{ -- 445
					color = toColor(PALETTE.amber), -- 446
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 446
					layer = 3 -- 446
				} -- 446
			) -- 446
			uiArt:tryPlace( -- 448
				"ink_enso_fine", -- 448
				"hand_knock_2", -- 448
				pbx + pbw * 0.72, -- 448
				pby, -- 448
				11, -- 448
				11, -- 448
				{ -- 448
					color = toColor(PALETTE.amber), -- 449
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 449
					layer = 3 -- 449
				} -- 449
			) -- 449
		end -- 449
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 452
			local bw = 400 -- 453
			local cx = w * 0.5 -- 454
			local by = h - 64 - safe.top -- 455
			local ratio = math.max( -- 456
				0, -- 456
				math.min( -- 456
					1, -- 456
					p.gateTick / math.max(1, g.holdTicks) -- 456
				) -- 456
			) -- 456
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 457
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 458
			drawSilkVeil( -- 460
				uiDraw, -- 460
				uiArt, -- 460
				"hud_gate_veil", -- 460
				cx, -- 460
				by + 18, -- 460
				bw + 90, -- 460
				48, -- 460
				PALETTE.inkWash, -- 460
				0.76 * alpha, -- 460
				-1 -- 460
			) -- 460
			drawHairline( -- 461
				uiInkDraw, -- 461
				uiArt, -- 461
				"hud_gate_top", -- 461
				cx, -- 461
				by + 39, -- 461
				bw - 20, -- 461
				PALETTE.rougeSoft, -- 461
				0.55 * alpha, -- 461
				false, -- 461
				2 -- 461
			) -- 461
			local idleNeedConfirmLabel = assistHintsEnabled and adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 463
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 466
			texts:put( -- 469
				"xs", -- 469
				label, -- 469
				cx, -- 469
				by + 26, -- 469
				toColor(PALETTE.textBright), -- 469
				0.5, -- 469
				0.5, -- 469
				"Center", -- 469
				1.8, -- 469
				alpha, -- 469
				0.08 -- 469
			) -- 469
			local pbw = bw - 80 -- 471
			local pbx = cx - pbw * 0.5 -- 472
			local pby = by + 9 -- 473
			uiInkDraw:drawSegment( -- 474
				Vec2(pbx, pby), -- 474
				Vec2(pbx + pbw, pby), -- 474
				1.4, -- 474
				toColor(PALETTE.silkDim, 115 * alpha) -- 474
			) -- 474
			if ratio > 0.002 then -- 475
				uiInkDraw:drawSegment( -- 476
					Vec2(pbx, pby), -- 476
					Vec2(pbx + pbw * ratio, pby), -- 476
					2.8, -- 476
					toColor(PALETTE.rouge, 230 * alpha) -- 476
				) -- 476
				uiInkDraw:drawSegment( -- 477
					Vec2(pbx, pby), -- 477
					Vec2(pbx + pbw * ratio, pby), -- 477
					1, -- 477
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 477
				) -- 477
			end -- 477
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 479
			local k = 0 -- 480
			do -- 480
				k = 0 -- 481
				while k < #waves do -- 481
					local wx = pbx + pbw * waves[k + 1] -- 482
					local passed = p.gateSpawned > k -- 483
					if passed then -- 484
						drawBlossomDot( -- 485
							uiInkDraw, -- 485
							uiArt, -- 485
							"gate_wave_" .. tostring(k), -- 485
							wx, -- 485
							pby, -- 485
							10, -- 485
							PALETTE.moonPale, -- 485
							0.92 * alpha, -- 485
							3 -- 485
						) -- 485
					else -- 485
						uiArt:tryPlace( -- 487
							"ink_enso_fine", -- 487
							"gate_wave_" .. tostring(k), -- 487
							wx, -- 487
							pby, -- 487
							11, -- 487
							11, -- 487
							{ -- 487
								color = toColor(PALETTE.rouge), -- 488
								opacity = 0.84 * alpha, -- 488
								layer = 3 -- 488
							} -- 488
						) -- 488
					end -- 488
					k = k + 1 -- 481
				end -- 481
			end -- 481
		end -- 481
		return -- 493
	end -- 493
	if not assistHintsEnabled then -- 496
		return -- 497
	end -- 497
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 499
		local cx = w * 0.5 -- 500
		local by = h - 44 - safe.top -- 501
		local step1 = p.cartDocked -- 502
		local ____temp_0 -- 503
		if p.room.key == "checkpoint" then -- 503
			____temp_0 = p.gateOpen -- 503
		else -- 503
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 503
		end -- 503
		local step2 = ____temp_0 -- 503
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 504
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 505
		drawSilkVeil( -- 507
			uiDraw, -- 507
			uiArt, -- 507
			"hud_obj_veil", -- 507
			cx, -- 507
			by, -- 507
			380, -- 507
			34, -- 507
			PALETTE.inkWash, -- 507
			0.58 * alpha, -- 507
			-1 -- 507
		) -- 507
		local x1 = cx - 134 -- 509
		if step1 then -- 510
			drawBlossomDot( -- 511
				uiInkDraw, -- 511
				uiArt, -- 511
				"obj_m1", -- 511
				x1, -- 511
				by, -- 511
				11, -- 511
				PALETTE.emerald, -- 511
				0.94 * alpha, -- 511
				3 -- 511
			) -- 511
		else -- 511
			uiArt:tryPlace( -- 513
				"ink_enso_fine", -- 513
				"obj_m1", -- 513
				x1, -- 513
				by, -- 513
				11, -- 513
				11, -- 513
				{ -- 513
					color = toColor(PALETTE.silkLine), -- 513
					opacity = 0.72 * alpha, -- 513
					layer = 3 -- 513
				} -- 513
			) -- 513
		end -- 513
		texts:put( -- 515
			"xs", -- 515
			t1, -- 515
			x1 + 13, -- 515
			by, -- 515
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 515
			0, -- 515
			0.5, -- 515
			"Left", -- 515
			1, -- 515
			alpha, -- 515
			0.08 -- 515
		) -- 515
		local x2 = cx + 18 -- 517
		if step2 then -- 518
			drawBlossomDot( -- 519
				uiInkDraw, -- 519
				uiArt, -- 519
				"obj_m2", -- 519
				x2, -- 519
				by, -- 519
				11, -- 519
				PALETTE.emerald, -- 519
				0.94 * alpha, -- 519
				3 -- 519
			) -- 519
		else -- 519
			uiArt:tryPlace( -- 521
				"ink_enso_fine", -- 521
				"obj_m2", -- 521
				x2, -- 521
				by, -- 521
				11, -- 521
				11, -- 521
				{ -- 521
					color = toColor(PALETTE.silkDim), -- 521
					opacity = 0.62 * alpha, -- 521
					layer = 3 -- 521
				} -- 521
			) -- 521
		end -- 521
		texts:put( -- 523
			"xs", -- 523
			t2, -- 523
			x2 + 13, -- 523
			by, -- 523
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 523
			0, -- 523
			0.5, -- 523
			"Left", -- 523
			1, -- 523
			alpha, -- 523
			0.08 -- 523
		) -- 523
	end -- 523
end -- 367
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 527
	local bob = math.sin(self.time * 3.4) * 2.8 -- 538
	local viewW = cam.viewW / uiScale -- 539
	local viewH = cam.viewH / uiScale -- 540
	local i = 0 -- 541
	do -- 541
		i = 0 -- 542
		while i < #prompts do -- 542
			local pr = prompts[i + 1] -- 543
			local keyW = math.max( -- 544
				24, -- 544
				visualTextWidth(pr.keyTag, 15) + 16 -- 544
			) -- 544
			local labelW = visualTextWidth(pr.label, 15) -- 545
			local pillW = keyW + labelW + 24 -- 546
			local padX = math.max(115, pillW * 0.5 + 24) -- 547
			local sx = math.max( -- 548
				padX + safe.left, -- 548
				math.min( -- 548
					viewW - padX - safe.right, -- 548
					cam:sx(pr.x) / uiScale -- 548
				) -- 548
			) -- 548
			local sy = math.max( -- 549
				96 + safe.bottom, -- 549
				math.min( -- 549
					viewH - 110 - safe.top, -- 549
					cam:sy(pr.y) / uiScale + bob -- 549
				) -- 549
			) -- 549
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 550
			uiInkDraw:drawSegment( -- 552
				Vec2(sx, sy - 14), -- 552
				Vec2(sx, sy - 27), -- 552
				0.8, -- 552
				toColor(accent, 135 * alpha) -- 552
			) -- 552
			drawBlossomDot( -- 553
				uiInkDraw, -- 553
				uiArt, -- 553
				"wp_anchor_" .. tostring(i), -- 553
				sx, -- 553
				sy - 28, -- 553
				7, -- 553
				accent, -- 553
				0.85 * alpha, -- 553
				3 -- 553
			) -- 553
			local px = sx - pillW * 0.5 -- 555
			local py = sy - 12 -- 556
			drawSilkVeil( -- 558
				uiDraw, -- 558
				uiArt, -- 558
				"wp_bg_" .. tostring(i), -- 558
				sx, -- 558
				py + 12, -- 558
				pillW + 40, -- 558
				32, -- 558
				PALETTE.inkWash, -- 558
				0.78 * alpha, -- 558
				0 -- 558
			) -- 558
			drawHairline( -- 559
				uiInkDraw, -- 559
				uiArt, -- 559
				"wp_line_" .. tostring(i), -- 559
				sx, -- 559
				py + 24, -- 559
				pillW + 4, -- 559
				accent, -- 559
				0.45 * alpha, -- 559
				false, -- 559
				2 -- 559
			) -- 559
			drawSilkKeycap( -- 560
				uiInkDraw, -- 560
				texts, -- 560
				px + 2, -- 560
				py + 2, -- 560
				keyW, -- 560
				20, -- 560
				pr.keyTag, -- 560
				accent, -- 560
				alpha, -- 560
				pr.urgent -- 560
			) -- 560
			texts:put( -- 561
				"xs", -- 561
				pr.label, -- 561
				px + keyW + 12, -- 561
				py + 12, -- 561
				toColor(PALETTE.textBright), -- 561
				0, -- 561
				0.5, -- 561
				"Left", -- 561
				0.8, -- 561
				alpha, -- 561
				0.08 -- 561
			) -- 561
			i = i + 1 -- 542
		end -- 542
	end -- 542
end -- 527
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 565
	local mx = p.aimX / uiScale -- 575
	local my = p.aimY / uiScale -- 576
	if mx <= 0 and my <= 0 then -- 577
		return -- 578
	end -- 578
	if p.childMode then -- 581
		local aiming = p.room.key == "village" and p.hasBottle -- 582
		if touchMode and (not aiming or p.aimHold <= 0) then -- 583
			return -- 584
		end -- 584
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 586
		uiInkDraw:drawDot( -- 587
			Vec2(mx, my), -- 587
			aiming and 2 or 1.6, -- 587
			toColor(col, aiming and 215 or 120) -- 587
		) -- 587
		if aiming then -- 588
			local sz = p.aimHold > 0 and 32 or 24 -- 589
			uiArt:tryPlace( -- 590
				"ink_enso_fine", -- 590
				"reticle_child", -- 590
				mx, -- 590
				my, -- 590
				sz, -- 590
				sz, -- 590
				{ -- 590
					color = toColor(PALETTE.amberCore), -- 591
					opacity = 0.82, -- 591
					angle = self.time * 24, -- 591
					layer = 5 -- 591
				} -- 591
			) -- 591
		end -- 591
		return -- 594
	end -- 594
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 597
	local onEnemy = false -- 598
	local i = 0 -- 599
	do -- 599
		i = 0 -- 600
		while i < #p.enemies do -- 600
			local e = p.enemies[i + 1] -- 601
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 602
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 603
				onEnemy = true -- 604
			end -- 604
			i = i + 1 -- 600
		end -- 600
	end -- 600
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 608
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 609
	local arm = onEnemy and 8.5 or 9.5 -- 610
	local bg = Color(10, 12, 18, 160) -- 611
	uiInkDraw:drawSegment( -- 613
		Vec2(mx - gap - arm, my), -- 613
		Vec2(mx - gap, my), -- 613
		2.1, -- 613
		bg -- 613
	) -- 613
	uiInkDraw:drawSegment( -- 614
		Vec2(mx + gap, my), -- 614
		Vec2(mx + gap + arm, my), -- 614
		2.1, -- 614
		bg -- 614
	) -- 614
	uiInkDraw:drawSegment( -- 615
		Vec2(mx, my - gap - arm), -- 615
		Vec2(mx, my - gap), -- 615
		2.1, -- 615
		bg -- 615
	) -- 615
	uiInkDraw:drawSegment( -- 616
		Vec2(mx, my + gap), -- 616
		Vec2(mx, my + gap + arm), -- 616
		2.1, -- 616
		bg -- 616
	) -- 616
	uiInkDraw:drawSegment( -- 618
		Vec2(mx - gap - arm, my), -- 618
		Vec2(mx - gap, my), -- 618
		1.1, -- 618
		toColor(col, 230) -- 618
	) -- 618
	uiInkDraw:drawSegment( -- 619
		Vec2(mx + gap, my), -- 619
		Vec2(mx + gap + arm, my), -- 619
		1.1, -- 619
		toColor(col, 230) -- 619
	) -- 619
	uiInkDraw:drawSegment( -- 620
		Vec2(mx, my - gap - arm), -- 620
		Vec2(mx, my - gap), -- 620
		1.1, -- 620
		toColor(col, 230) -- 620
	) -- 620
	uiInkDraw:drawSegment( -- 621
		Vec2(mx, my + gap), -- 621
		Vec2(mx, my + gap + arm), -- 621
		1.1, -- 621
		toColor(col, 230) -- 621
	) -- 621
	uiInkDraw:drawDot( -- 622
		Vec2(mx, my), -- 622
		1.8, -- 622
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 622
	) -- 622
	if onEnemy then -- 624
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 625
		uiArt:tryPlace( -- 626
			"ink_enso_fine", -- 626
			"reticle_lock", -- 626
			mx, -- 626
			my, -- 626
			sz, -- 626
			sz, -- 626
			{ -- 626
				color = toColor(PALETTE.rouge), -- 627
				opacity = 0.88, -- 627
				angle = self.time * 38, -- 627
				layer = 5 -- 627
			} -- 627
		) -- 627
		fillRadialGlow( -- 629
			uiGlow, -- 629
			mx, -- 629
			my, -- 629
			16, -- 629
			16, -- 629
			toColor(PALETTE.rouge, 30), -- 629
			Color(182, 58, 56, 0), -- 629
			10 -- 629
		) -- 629
	end -- 629
end -- 565
return ____exports -- 565
