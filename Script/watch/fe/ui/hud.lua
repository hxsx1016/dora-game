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
local ALL_TALENTS = ____run.ALL_TALENTS -- 10
local TALENT_CATALOG = ____run.TALENT_CATALOG -- 10
local ____craft = require("Script.watch.craft") -- 11
local weaponNameOf = ____craft.weaponNameOf -- 11
local ____depth = require("Script.watch.depth") -- 12
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 12
local ____escort = require("Script.watch.escort") -- 13
local FEAR_MAX = ____escort.FEAR_MAX -- 13
local ____platform = require("Script.watch.platform") -- 15
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 15
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 16
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 16
local adaptWorldKeyTag = ____control_prompts.adaptWorldKeyTag -- 16
local ____talent_draft = require("Script.watch.fe.ui.talent_draft") -- 17
local computeTalentSlipRects = ____talent_draft.computeTalentSlipRects -- 17
local ____adapter = require("Script.watch.fe.adapter") -- 18
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 18
local ____theme = require("Script.watch.fe.theme") -- 23
local PALETTE = ____theme.PALETTE -- 24
local drawBlossomDot = ____theme.drawBlossomDot -- 25
local drawHairline = ____theme.drawHairline -- 26
local drawSilkKeycap = ____theme.drawSilkKeycap -- 27
local drawSilkVeil = ____theme.drawSilkVeil -- 28
local fillRadialGlow = ____theme.fillRadialGlow -- 29
local themeOf = ____theme.themeOf -- 30
local toColor = ____theme.toColor -- 31
local visualTextWidth = ____theme.visualTextWidth -- 32
____exports.HudRenderer = __TS__Class() -- 35
local HudRenderer = ____exports.HudRenderer -- 35
HudRenderer.name = "HudRenderer" -- 35
function HudRenderer.prototype.____constructor(self) -- 35
	self.ghostHp = 3 -- 37
	self.time = 0 -- 38
	self.talentSelected = 0 -- 40
end -- 35
function HudRenderer.prototype.reset(self, p) -- 42
	self.ghostHp = p ~= nil and p.hp or 3 -- 43
	self.talentSelected = 0 -- 44
end -- 42
function HudRenderer.prototype.update(self, dt, p) -- 47
	self.time = self.time + dt -- 48
	if self.ghostHp > p.hp then -- 49
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 50
	else -- 50
		self.ghostHp = p.hp -- 52
	end -- 52
end -- 47
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible) -- 56
	if assistHintsEnabled == nil then -- 67
		assistHintsEnabled = false -- 67
	end -- 67
	if suppressReticle == nil then -- 68
		suppressReticle = false -- 68
	end -- 68
	if inputMode == nil then -- 69
		inputMode = "kbm" -- 69
	end -- 69
	if gamepadLayout == nil then -- 70
		gamepadLayout = "xbox" -- 70
	end -- 70
	if safe == nil then -- 71
		safe = ZERO_SAFE_INSETS -- 71
	end -- 71
	if retryHoldProgress == nil then -- 72
		retryHoldProgress = 0 -- 72
	end -- 72
	if touchOverlayVisible == nil then -- 73
		touchOverlayVisible = false -- 73
	end -- 73
	local w = cam.viewW / uiScale -- 75
	local h = cam.viewH / uiScale -- 76
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 77
	if hudAlpha > 0.05 then -- 79
		if p.childMode then -- 80
			self:drawChildStatus( -- 81
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
		else -- 81
			self:drawSoldierStatus( -- 83
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
		end -- 83
		self:drawChapterBadge( -- 86
			uiDraw, -- 86
			uiArt, -- 86
			texts, -- 86
			p, -- 86
			w, -- 86
			h, -- 86
			hudAlpha, -- 86
			inputMode, -- 86
			safe, -- 86
			touchOverlayVisible -- 86
		) -- 86
		self:drawContextualObjective( -- 87
			uiDraw, -- 87
			uiInkDraw, -- 87
			uiArt, -- 87
			texts, -- 87
			p, -- 87
			w, -- 87
			h, -- 87
			hudAlpha, -- 87
			assistHintsEnabled, -- 87
			inputMode, -- 87
			gamepadLayout, -- 87
			safe -- 87
		) -- 87
		if assistHintsEnabled then -- 89
			local prompt = deriveWorldPrompt(p) -- 90
			if prompt ~= nil then -- 91
				local adapted = { -- 92
					x = prompt.x, -- 93
					y = prompt.y, -- 94
					keyTag = adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout), -- 95
					label = prompt.label, -- 96
					urgent = prompt.urgent, -- 97
					progress = prompt.progress -- 98
				} -- 98
				self:drawWorldPrompts( -- 100
					uiDraw, -- 100
					uiInkDraw, -- 100
					uiArt, -- 100
					texts, -- 100
					{adapted}, -- 100
					cam, -- 100
					hudAlpha, -- 100
					uiScale, -- 100
					safe -- 100
				) -- 100
			end -- 100
		end -- 100
		if vfx.deflectFlash > 0.25 then -- 104
			local dx = cam:sx(vfx.deflectX) / uiScale -- 105
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 106
			texts:put( -- 107
				"sm", -- 107
				"掩体挡下", -- 107
				dx, -- 107
				dy, -- 107
				toColor(PALETTE.textBright), -- 107
				0.5, -- 107
				0.5, -- 107
				"Center", -- 107
				2, -- 107
				vfx.deflectFlash, -- 107
				0.1 -- 107
			) -- 107
		end -- 107
	end -- 107
	if retryHoldProgress > 0.02 then -- 112
		local cx = w * 0.5 -- 113
		local cy = h - 32 - safe.top -- 114
		local bw = 220 -- 115
		drawSilkVeil( -- 116
			uiDraw, -- 116
			uiArt, -- 116
			"hud_retry_hold_veil", -- 116
			cx, -- 116
			cy, -- 116
			bw + 60, -- 116
			34, -- 116
			PALETTE.inkWarm, -- 116
			0.84, -- 116
			2 -- 116
		) -- 116
		texts:put( -- 117
			"xs", -- 117
			"长按 BACK 重试检查点", -- 117
			cx, -- 117
			cy + 7, -- 117
			toColor(PALETTE.amberCore), -- 117
			0.5, -- 117
			0.5, -- 117
			"Center", -- 117
			1, -- 117
			0.96, -- 117
			0.08 -- 117
		) -- 117
		local x0 = cx - bw * 0.44 -- 118
		local x1 = cx + bw * 0.44 -- 119
		uiInkDraw:drawSegment( -- 120
			Vec2(x0, cy - 8), -- 120
			Vec2(x1, cy - 8), -- 120
			1.4, -- 120
			toColor(PALETTE.silkDim, 120) -- 120
		) -- 120
		uiInkDraw:drawSegment( -- 121
			Vec2(x0, cy - 8), -- 121
			Vec2( -- 121
				x0 + (x1 - x0) * math.min(1, retryHoldProgress), -- 121
				cy - 8 -- 121
			), -- 121
			2.8, -- 121
			toColor(PALETTE.rouge, 235) -- 121
		) -- 121
	end -- 121
	if not suppressReticle then -- 124
		self:drawReticleOverlay( -- 125
			uiInkDraw, -- 125
			uiArt, -- 125
			uiGlow, -- 125
			p, -- 125
			cam, -- 125
			vfx, -- 125
			letterboxFrac, -- 125
			uiScale, -- 125
			inputMode == "touch" -- 125
		) -- 125
	end -- 125
end -- 56
function HudRenderer.prototype.talentCardRects(self, w, h, count, touchMode, safeTop) -- 130
	if touchMode == nil then -- 130
		touchMode = false -- 130
	end -- 130
	if safeTop == nil then -- 130
		safeTop = 0 -- 130
	end -- 130
	return computeTalentSlipRects( -- 131
		w, -- 131
		h, -- 131
		count, -- 131
		touchMode, -- 131
		safeTop -- 131
	) -- 131
end -- 130
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, touchMode) -- 135
	if touchMode == nil then -- 144
		touchMode = false -- 144
	end -- 144
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 146
		self:drawReticle( -- 148
			uiInkDraw, -- 148
			uiArt, -- 148
			uiGlow, -- 148
			p, -- 148
			cam, -- 148
			vfx, -- 148
			uiScale, -- 148
			touchMode -- 148
		) -- 148
	end -- 148
end -- 135
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 152
	local bx = 28 + safe.left -- 165
	local by = h - 72 - safe.top -- 166
	local lowHp = p.hp <= 1 -- 167
	local segCount = math.max(1, p.maxHp) -- 169
	local segW = segCount >= 5 and 42 or 54 -- 170
	local segH = 9 -- 171
	local gap = segCount >= 5 and 6 or 8 -- 172
	local veilW = math.max(340, 124 + segCount * (segW + gap)) -- 173
	drawSilkVeil( -- 174
		uiDraw, -- 174
		uiArt, -- 174
		"hud_soldier_veil", -- 174
		bx + veilW * 0.44, -- 174
		by + 24, -- 174
		veilW, -- 174
		56, -- 174
		PALETTE.inkWash, -- 174
		0.62 * alpha, -- 174
		-1 -- 174
	) -- 174
	texts:put( -- 175
		"md", -- 175
		"戍", -- 175
		bx + 16, -- 175
		by + 25, -- 175
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 175
		0.5, -- 175
		0.5, -- 175
		"Center", -- 175
		0, -- 175
		alpha, -- 175
		0.1 -- 175
	) -- 175
	uiInkDraw:drawSegment( -- 176
		Vec2(bx + 32, by + 9), -- 176
		Vec2(bx + 32, by + 40), -- 176
		0.8, -- 176
		toColor(PALETTE.silkDim, 130 * alpha) -- 176
	) -- 176
	texts:put( -- 177
		"xs", -- 177
		"周戍 · 体力", -- 177
		bx + 44, -- 177
		by + 36, -- 177
		toColor(PALETTE.textMid), -- 177
		0, -- 177
		0.5, -- 177
		"Left", -- 177
		1.4, -- 177
		alpha, -- 177
		0.08 -- 177
	) -- 177
	local barX = bx + 44 -- 179
	local barY = by + 16 -- 180
	local i = 0 -- 182
	do -- 182
		i = 0 -- 183
		while i < segCount do -- 183
			local sx = barX + i * (segW + gap) -- 184
			local scx = sx + segW * 0.5 -- 185
			if not uiArt:tryPlace( -- 186
				"ink_bamboo_slot", -- 186
				"hp_slot_" .. tostring(i), -- 186
				scx, -- 186
				barY, -- 186
				segW, -- 186
				segH, -- 186
				{ -- 186
					color = toColor(PALETTE.silkDim), -- 187
					opacity = 0.72 * alpha, -- 187
					layer = 1 -- 187
				} -- 187
			) then -- 187
				uiInkDraw:drawRect( -- 189
					Rect(sx, barY - 3, segW, 6), -- 189
					Color(0, 0, 0, 0), -- 189
					0.8, -- 189
					toColor(PALETTE.silkDim, 145 * alpha) -- 189
				) -- 189
			end -- 189
			if self.ghostHp > i and self.ghostHp > p.hp then -- 191
				local frac = math.min(1, self.ghostHp - i) -- 192
				uiInkDraw:drawRect( -- 193
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 193
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 193
				) -- 193
			end -- 193
			if p.hp > i then -- 195
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 196
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 197
				if not uiArt:tryPlace( -- 198
					"ink_bamboo_slip", -- 198
					"hp_fill_" .. tostring(i), -- 198
					scx, -- 198
					barY, -- 198
					segW, -- 198
					segH, -- 198
					{ -- 198
						color = toColor(fillCol), -- 199
						opacity = 0.94 * alpha * pulse, -- 199
						layer = 2 -- 199
					} -- 199
				) then -- 199
					uiInkDraw:drawRect( -- 201
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 201
						toColor(fillCol, 230 * alpha * pulse) -- 201
					) -- 201
				end -- 201
			end -- 201
			i = i + 1 -- 183
		end -- 183
	end -- 183
	local covX = barX + segCount * (segW + gap) + 6 -- 206
	local hasAliveEnemy = false -- 207
	do -- 207
		i = 0 -- 208
		while i < #p.enemies do -- 208
			if p.enemies[i + 1].alive then -- 209
				hasAliveEnemy = true -- 210
				break -- 211
			end -- 211
			i = i + 1 -- 208
		end -- 208
	end -- 208
	if p.coverHug then -- 214
		if hasAliveEnemy and not p.coverBlocking then -- 215
			uiInkDraw:drawRect( -- 216
				Rect(covX, barY - 9, 72, 18), -- 216
				toColor(PALETTE.inkWarm, 185 * alpha), -- 216
				0.8, -- 216
				toColor(PALETTE.amber, 200 * alpha) -- 216
			) -- 216
			texts:put( -- 217
				"xs", -- 217
				"背向掩体", -- 217
				covX + 36, -- 217
				barY, -- 217
				toColor(PALETTE.amberCore), -- 217
				0.5, -- 217
				0.5, -- 217
				"Center", -- 217
				0.6, -- 217
				alpha, -- 217
				0 -- 217
			) -- 217
		else -- 217
			uiInkDraw:drawRect( -- 219
				Rect(covX, barY - 9, 54, 18), -- 219
				toColor(PALETTE.cyanDim, 165 * alpha), -- 219
				0.8, -- 219
				toColor(PALETTE.cyanCore, 180 * alpha) -- 219
			) -- 219
			texts:put( -- 220
				"xs", -- 220
				"掩体中", -- 220
				covX + 27, -- 220
				barY, -- 220
				toColor(PALETTE.textBright), -- 220
				0.5, -- 220
				0.5, -- 220
				"Center", -- 220
				0.6, -- 220
				alpha, -- 220
				0 -- 220
			) -- 220
		end -- 220
	elseif assistHintsEnabled and p.coverNear then -- 222
		uiInkDraw:drawRect( -- 223
			Rect(covX, barY - 9, 54, 18), -- 223
			Color( -- 223
				14, -- 223
				17, -- 223
				25, -- 223
				math.floor(150 * alpha + 0.5) -- 223
			), -- 223
			0.8, -- 223
			toColor(PALETTE.silkLine, 165 * alpha) -- 223
		) -- 223
		texts:put( -- 224
			"xs", -- 224
			"可贴靠", -- 224
			covX + 27, -- 224
			barY, -- 224
			toColor(PALETTE.textMid), -- 224
			0.5, -- 224
			0.5, -- 224
			"Center", -- 224
			0.6, -- 224
			alpha, -- 224
			0.08 -- 224
		) -- 224
	end -- 224
	local ____p_isCampaign_5 = p.isCampaign -- 227
	if ____p_isCampaign_5 then -- 227
		local ____opt_0 = p.room.campaign -- 227
		local ____temp_4 = (____opt_0 and ____opt_0.chapter) == "S" -- 227
		if not ____temp_4 then -- 227
			local ____opt_2 = p.room.campaign -- 227
			____temp_4 = (____opt_2 and ____opt_2.chapter) == "C" -- 227
		end -- 227
		____p_isCampaign_5 = ____temp_4 -- 227
	end -- 227
	local showCampaignFear = ____p_isCampaign_5 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 227
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" or showCampaignFear then -- 229
		local subY = by - 24 -- 230
		local frozen = p.escort.state == "frozen" -- 231
		local calming = p.escort.state == "calming" -- 232
		drawSilkVeil( -- 234
			uiDraw, -- 234
			uiArt, -- 234
			"hud_fear_veil", -- 234
			bx + 126, -- 234
			subY + 6, -- 234
			260, -- 234
			30, -- 234
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 234
			0.64 * alpha, -- 234
			-1 -- 234
		) -- 234
		texts:put( -- 235
			"xs", -- 235
			"小满 · 惊惧", -- 235
			bx + 14, -- 235
			subY + 6, -- 235
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 235
			0, -- 235
			0.5, -- 235
			"Left", -- 235
			1, -- 235
			alpha, -- 235
			0.08 -- 235
		) -- 235
		local k = 0 -- 237
		do -- 237
			k = 0 -- 238
			while k < FEAR_MAX do -- 238
				local dx = bx + 114 + k * 20 -- 239
				local dy = subY + 6 -- 240
				local lit = k < p.escort.fear -- 241
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 242
				uiArt:tryPlace( -- 243
					"ink_enso_fine", -- 243
					"fear_ring_" .. tostring(k), -- 243
					dx, -- 243
					dy, -- 243
					14, -- 243
					14, -- 243
					{ -- 243
						color = toColor(lit and dc or PALETTE.silkLine), -- 244
						opacity = (lit and 0.92 or 0.64) * alpha, -- 244
						layer = 2 -- 244
					} -- 244
				) -- 244
				if lit then -- 246
					drawBlossomDot( -- 247
						uiInkDraw, -- 247
						uiArt, -- 247
						"fear_dot_" .. tostring(k), -- 247
						dx, -- 247
						dy, -- 247
						10, -- 247
						dc, -- 247
						0.96 * alpha, -- 247
						3 -- 247
					) -- 247
				end -- 247
				k = k + 1 -- 238
			end -- 238
		end -- 238
		if frozen then -- 251
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 252
			if assistHintsEnabled then -- 253
				local calmKey = adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 254
				local keyW = math.max( -- 255
					22, -- 255
					visualTextWidth(calmKey, 15) + 10 -- 255
				) -- 255
				drawSilkKeycap( -- 256
					uiInkDraw, -- 256
					texts, -- 256
					bx + 170, -- 256
					subY - 5, -- 256
					keyW, -- 256
					22, -- 256
					calmKey, -- 256
					PALETTE.rouge, -- 256
					alpha * pulse, -- 256
					true -- 256
				) -- 256
				texts:put( -- 257
					"xs", -- 257
					"轻敲安抚", -- 257
					bx + 176 + keyW, -- 257
					subY + 6, -- 257
					toColor(PALETTE.crimsonCore), -- 257
					0, -- 257
					0.5, -- 257
					"Left", -- 257
					0.8, -- 257
					alpha * pulse, -- 257
					0.08 -- 257
				) -- 257
			else -- 257
				texts:put( -- 259
					"xs", -- 259
					"受惊停步", -- 259
					bx + 172, -- 259
					subY + 6, -- 259
					toColor(PALETTE.crimsonCore), -- 259
					0, -- 259
					0.5, -- 259
					"Left", -- 259
					0.8, -- 259
					alpha * pulse, -- 259
					0.08 -- 259
				) -- 259
			end -- 259
		elseif calming then -- 261
			texts:put( -- 262
				"xs", -- 262
				"轻敲安抚中", -- 262
				bx + 172, -- 262
				subY + 6, -- 262
				toColor(PALETTE.emerald), -- 262
				0, -- 262
				0.5, -- 262
				"Left", -- 262
				0.8, -- 262
				alpha, -- 262
				0.08 -- 262
			) -- 262
		end -- 262
	end -- 262
	local ranks = p:getStoryTalentRanks() -- 266
	if p:isEscortRoom() then -- 267
		local inv = p.run.inventory -- 268
		local sup = {} -- 269
		sup[#sup + 1] = weaponNameOf(p.equippedWeapon) -- 270
		local attempt = p:getEscortAttempt() -- 271
		if attempt > 1 then -- 272
			sup[#sup + 1] = ("第" .. tostring(attempt)) .. "轮" -- 272
		end -- 272
		if inv.wood > 0 then -- 273
			sup[#sup + 1] = "木筹" .. tostring(inv.wood) -- 273
		end -- 273
		if inv.bell > 0 then -- 274
			sup[#sup + 1] = "铃筹" .. tostring(inv.bell) -- 274
		end -- 274
		if inv.shield > 0 then -- 275
			sup[#sup + 1] = "残盾" .. tostring(inv.shield) -- 275
		end -- 275
		if inv.wedge > 0 then -- 276
			sup[#sup + 1] = "木楔" .. tostring(inv.wedge) -- 276
		end -- 276
		if inv.ammo > 0 then -- 277
			sup[#sup + 1] = "弹包" .. tostring(inv.ammo) -- 277
		end -- 277
		local row1Y = by - 22 -- 278
		local supTxt = table.concat(sup, " · ") -- 279
		local supW = math.max( -- 280
			240, -- 280
			visualTextWidth(supTxt, 15) + 34 -- 280
		) -- 280
		drawSilkVeil( -- 281
			uiDraw, -- 281
			uiArt, -- 281
			"hud_escort_sup_veil", -- 281
			bx + supW * 0.48, -- 281
			row1Y + 6, -- 281
			supW, -- 281
			24, -- 281
			PALETTE.inkWash, -- 281
			0.54 * alpha, -- 281
			-1 -- 281
		) -- 281
		texts:put( -- 282
			"xs", -- 282
			supTxt, -- 282
			bx + 14, -- 282
			row1Y + 6, -- 282
			toColor(PALETTE.cyanCore), -- 282
			0, -- 282
			0.5, -- 282
			"Left", -- 282
			0.6, -- 282
			alpha, -- 282
			0.08 -- 282
		) -- 282
		if ranks ~= nil then -- 284
			local parts = {} -- 285
			local ti = 0 -- 286
			do -- 286
				ti = 0 -- 287
				while ti < #ALL_TALENTS do -- 287
					local tid = ALL_TALENTS[ti + 1] -- 288
					local rk = ranks[tid] or 0 -- 289
					if rk > 0 then -- 290
						parts[#parts + 1] = TALENT_CATALOG[tid].title .. tostring(rk) -- 291
					end -- 291
					ti = ti + 1 -- 287
				end -- 287
			end -- 287
			if #parts > 0 then -- 294
				local row2Y = row1Y - 26 -- 295
				local txt = "本领 · " .. table.concat(parts, " · ") -- 296
				local talW = math.max( -- 297
					240, -- 297
					visualTextWidth(txt, 15) + 34 -- 297
				) -- 297
				drawSilkVeil( -- 298
					uiDraw, -- 298
					uiArt, -- 298
					"hud_talent_ranks_veil", -- 298
					bx + talW * 0.48, -- 298
					row2Y + 6, -- 298
					talW, -- 298
					24, -- 298
					PALETTE.inkWash, -- 298
					0.56 * alpha, -- 298
					-1 -- 298
				) -- 298
				texts:put( -- 299
					"xs", -- 299
					txt, -- 299
					bx + 14, -- 299
					row2Y + 6, -- 299
					toColor(PALETTE.amberCore), -- 299
					0, -- 299
					0.5, -- 299
					"Left", -- 299
					0.8, -- 299
					alpha, -- 299
					0.08 -- 299
				) -- 299
			end -- 299
		end -- 299
	elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 302
		local inv = p.run.inventory -- 303
		local items = {} -- 304
		if inv.shield > 0 then -- 305
			items[#items + 1] = "残盾" .. tostring(inv.shield) -- 305
		end -- 305
		if inv.wedge > 0 then -- 306
			items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 306
		end -- 306
		if inv.ammo > 0 then -- 307
			items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 307
		end -- 307
		if inv.scrap > 0 then -- 308
			items[#items + 1] = "木料" .. tostring(inv.scrap) -- 308
		end -- 308
		local companionText = p.run.joined and "小满同行" or "小满等待" -- 309
		local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 310
		local subY = by - 22 -- 311
		drawSilkVeil( -- 312
			uiDraw, -- 312
			uiArt, -- 312
			"hud_camp_veil", -- 312
			bx + 126, -- 312
			subY + 6, -- 312
			260, -- 312
			26, -- 312
			PALETTE.inkWash, -- 312
			0.54 * alpha, -- 312
			-1 -- 312
		) -- 312
		texts:put( -- 313
			"xs", -- 313
			summary, -- 313
			bx + 14, -- 313
			subY + 6, -- 313
			toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 313
			0, -- 313
			0.5, -- 313
			"Left", -- 313
			0.8, -- 313
			alpha, -- 313
			0.08 -- 313
		) -- 313
	end -- 313
end -- 152
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 317
	local bx = 28 + safe.left -- 330
	local by = h - 68 - safe.top -- 331
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 332
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 333
	drawSilkVeil( -- 335
		uiDraw, -- 335
		uiArt, -- 335
		"hud_child_veil", -- 335
		bx + 144, -- 335
		by + 22, -- 335
		316, -- 335
		48, -- 335
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 335
		0.58 * alpha, -- 335
		-1 -- 335
	) -- 335
	texts:put( -- 336
		"md", -- 336
		alert and "危" or "满", -- 336
		bx + 16, -- 336
		by + 22, -- 336
		toColor(leadCol), -- 336
		0.5, -- 336
		0.5, -- 336
		"Center", -- 336
		0, -- 336
		alpha, -- 336
		0.1 -- 336
	) -- 336
	uiInkDraw:drawSegment( -- 337
		Vec2(bx + 32, by + 7), -- 337
		Vec2(bx + 32, by + 37), -- 337
		0.8, -- 337
		toColor(PALETTE.silkDim, 130 * alpha) -- 337
	) -- 337
	texts:put( -- 338
		"xs", -- 338
		"小满 · 潜行", -- 338
		bx + 44, -- 338
		by + 33, -- 338
		toColor(PALETTE.amberCore), -- 338
		0, -- 338
		0.5, -- 338
		"Left", -- 338
		1.4, -- 338
		alpha, -- 338
		0.08 -- 338
	) -- 338
	local posture = assistHintsEnabled and "轻步前行 · 保持隐蔽" or "轻步前行" -- 340
	local col = PALETTE.textMid -- 341
	if alert then -- 342
		posture = (p.scavChase or p.dogState == "chase") and (assistHintsEnabled and "已被发现 · 速寻隐蔽" or "已被发现") or (assistHintsEnabled and "引起警觉 · 停步蹲伏" or "引起警觉") -- 343
		col = PALETTE.crimsonCore -- 346
	elseif p.player.crouch then -- 347
		posture = assistHintsEnabled and "低姿伏行 · 匿迹于影" or "低姿伏行" -- 348
		col = PALETTE.emerald -- 349
	elseif p.hasBottle then -- 350
		posture = assistHintsEnabled and adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 351
		col = PALETTE.amberCore -- 354
	end -- 354
	texts:put( -- 356
		"xs", -- 356
		posture, -- 356
		bx + 44, -- 356
		by + 12, -- 356
		toColor(col), -- 356
		0, -- 356
		0.5, -- 356
		"Left", -- 356
		0.6, -- 356
		alpha, -- 356
		0.08 -- 356
	) -- 356
end -- 317
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible) -- 359
	local theme = themeOf(p.room.key) -- 371
	local rx = w - 32 - safe.right - (touchOverlayVisible and 208 or 0) -- 372
	local cy = h - 44 - safe.top -- 373
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc 暂歇" -- 374
	drawSilkVeil( -- 376
		uiDraw, -- 376
		uiArt, -- 376
		"hud_chap_veil", -- 376
		rx - 82, -- 376
		cy, -- 376
		240, -- 376
		44, -- 376
		PALETTE.inkWash, -- 376
		0.44 * alpha, -- 376
		-1 -- 376
	) -- 376
	texts:put( -- 377
		"xs", -- 377
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 377
		rx, -- 377
		touchOverlayVisible and cy or cy + 9, -- 377
		toColor(PALETTE.textBright), -- 377
		1, -- 377
		0.5, -- 377
		"Right", -- 377
		1.2, -- 377
		alpha, -- 377
		0.08 -- 377
	) -- 377
	if not touchOverlayVisible then -- 378
		texts:put( -- 379
			"xs", -- 379
			pauseTip, -- 379
			rx, -- 379
			cy - 11, -- 379
			toColor(PALETTE.textDim), -- 379
			1, -- 379
			0.5, -- 379
			"Right", -- 379
			1, -- 379
			0.78 * alpha, -- 379
			0.08 -- 379
		) -- 379
	end -- 379
end -- 359
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 383
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 400
		local g = p.room.story.gate -- 401
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 402
			local bw = 400 -- 403
			local cx = w * 0.5 -- 404
			local by = h - 64 - safe.top -- 405
			local tied = p.phase == "gate-hand" -- 406
			local ratio = tied and 1 or math.max( -- 407
				0, -- 407
				math.min( -- 407
					1, -- 407
					p.handTicks / math.max(1, p.handNeedTicks) -- 407
				) -- 407
			) -- 407
			local holdInteractKey = adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 408
			local reholdInteractKey = adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 409
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 410
			drawSilkVeil( -- 414
				uiDraw, -- 414
				uiArt, -- 414
				"hud_hand_veil", -- 414
				cx, -- 414
				by + 18, -- 414
				bw + 90, -- 414
				48, -- 414
				PALETTE.inkWash, -- 414
				0.76 * alpha, -- 414
				-1 -- 414
			) -- 414
			drawHairline( -- 415
				uiInkDraw, -- 415
				uiArt, -- 415
				"hud_hand_top", -- 415
				cx, -- 415
				by + 39, -- 415
				bw - 20, -- 415
				PALETTE.amber, -- 415
				0.55 * alpha, -- 415
				false, -- 415
				2 -- 415
			) -- 415
			texts:put( -- 416
				"xs", -- 416
				label, -- 416
				cx, -- 416
				by + 26, -- 416
				toColor(PALETTE.textBright), -- 416
				0.5, -- 416
				0.5, -- 416
				"Center", -- 416
				1.8, -- 416
				alpha, -- 416
				0.08 -- 416
			) -- 416
			local pbw = bw - 80 -- 418
			local pbx = cx - pbw * 0.5 -- 419
			local pby = by + 9 -- 420
			uiInkDraw:drawSegment( -- 421
				Vec2(pbx, pby), -- 421
				Vec2(pbx + pbw, pby), -- 421
				1.4, -- 421
				toColor(PALETTE.silkDim, 115 * alpha) -- 421
			) -- 421
			if ratio > 0.002 then -- 422
				uiInkDraw:drawSegment( -- 423
					Vec2(pbx, pby), -- 423
					Vec2(pbx + pbw * ratio, pby), -- 423
					2.8, -- 423
					toColor(PALETTE.amber, 230 * alpha) -- 423
				) -- 423
				uiInkDraw:drawSegment( -- 424
					Vec2(pbx, pby), -- 424
					Vec2(pbx + pbw * ratio, pby), -- 424
					1, -- 424
					toColor(PALETTE.amberCore, 165 * alpha) -- 424
				) -- 424
			end -- 424
			uiArt:tryPlace( -- 426
				"ink_enso_fine", -- 426
				"hand_knock_1", -- 426
				pbx + pbw * 0.62, -- 426
				pby, -- 426
				11, -- 426
				11, -- 426
				{ -- 426
					color = toColor(PALETTE.amber), -- 427
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 427
					layer = 3 -- 427
				} -- 427
			) -- 427
			uiArt:tryPlace( -- 429
				"ink_enso_fine", -- 429
				"hand_knock_2", -- 429
				pbx + pbw * 0.72, -- 429
				pby, -- 429
				11, -- 429
				11, -- 429
				{ -- 429
					color = toColor(PALETTE.amber), -- 430
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 430
					layer = 3 -- 430
				} -- 430
			) -- 430
		end -- 430
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 433
			local bw = 400 -- 434
			local cx = w * 0.5 -- 435
			local by = h - 64 - safe.top -- 436
			local ratio = math.max( -- 437
				0, -- 437
				math.min( -- 437
					1, -- 437
					p.gateTick / math.max(1, g.holdTicks) -- 437
				) -- 437
			) -- 437
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 438
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 439
			drawSilkVeil( -- 441
				uiDraw, -- 441
				uiArt, -- 441
				"hud_gate_veil", -- 441
				cx, -- 441
				by + 18, -- 441
				bw + 90, -- 441
				48, -- 441
				PALETTE.inkWash, -- 441
				0.76 * alpha, -- 441
				-1 -- 441
			) -- 441
			drawHairline( -- 442
				uiInkDraw, -- 442
				uiArt, -- 442
				"hud_gate_top", -- 442
				cx, -- 442
				by + 39, -- 442
				bw - 20, -- 442
				PALETTE.rougeSoft, -- 442
				0.55 * alpha, -- 442
				false, -- 442
				2 -- 442
			) -- 442
			local idleNeedConfirmLabel = assistHintsEnabled and adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 444
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 447
			texts:put( -- 450
				"xs", -- 450
				label, -- 450
				cx, -- 450
				by + 26, -- 450
				toColor(PALETTE.textBright), -- 450
				0.5, -- 450
				0.5, -- 450
				"Center", -- 450
				1.8, -- 450
				alpha, -- 450
				0.08 -- 450
			) -- 450
			local pbw = bw - 80 -- 452
			local pbx = cx - pbw * 0.5 -- 453
			local pby = by + 9 -- 454
			uiInkDraw:drawSegment( -- 455
				Vec2(pbx, pby), -- 455
				Vec2(pbx + pbw, pby), -- 455
				1.4, -- 455
				toColor(PALETTE.silkDim, 115 * alpha) -- 455
			) -- 455
			if ratio > 0.002 then -- 456
				uiInkDraw:drawSegment( -- 457
					Vec2(pbx, pby), -- 457
					Vec2(pbx + pbw * ratio, pby), -- 457
					2.8, -- 457
					toColor(PALETTE.rouge, 230 * alpha) -- 457
				) -- 457
				uiInkDraw:drawSegment( -- 458
					Vec2(pbx, pby), -- 458
					Vec2(pbx + pbw * ratio, pby), -- 458
					1, -- 458
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 458
				) -- 458
			end -- 458
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 460
			local k = 0 -- 461
			do -- 461
				k = 0 -- 462
				while k < #waves do -- 462
					local wx = pbx + pbw * waves[k + 1] -- 463
					local passed = p.gateSpawned > k -- 464
					if passed then -- 465
						drawBlossomDot( -- 466
							uiInkDraw, -- 466
							uiArt, -- 466
							"gate_wave_" .. tostring(k), -- 466
							wx, -- 466
							pby, -- 466
							10, -- 466
							PALETTE.moonPale, -- 466
							0.92 * alpha, -- 466
							3 -- 466
						) -- 466
					else -- 466
						uiArt:tryPlace( -- 468
							"ink_enso_fine", -- 468
							"gate_wave_" .. tostring(k), -- 468
							wx, -- 468
							pby, -- 468
							11, -- 468
							11, -- 468
							{ -- 468
								color = toColor(PALETTE.rouge), -- 469
								opacity = 0.84 * alpha, -- 469
								layer = 3 -- 469
							} -- 469
						) -- 469
					end -- 469
					k = k + 1 -- 462
				end -- 462
			end -- 462
		end -- 462
		return -- 474
	end -- 474
	if not assistHintsEnabled then -- 477
		return -- 478
	end -- 478
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 480
		local cx = w * 0.5 -- 481
		local by = h - 44 - safe.top -- 482
		local step1 = p.cartDocked -- 483
		local ____temp_6 -- 484
		if p.room.key == "checkpoint" then -- 484
			____temp_6 = p.gateOpen -- 484
		else -- 484
			____temp_6 = p.checkpoint >= p.room.arch.x1 -- 484
		end -- 484
		local step2 = ____temp_6 -- 484
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 485
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 486
		drawSilkVeil( -- 488
			uiDraw, -- 488
			uiArt, -- 488
			"hud_obj_veil", -- 488
			cx, -- 488
			by, -- 488
			380, -- 488
			34, -- 488
			PALETTE.inkWash, -- 488
			0.58 * alpha, -- 488
			-1 -- 488
		) -- 488
		local x1 = cx - 134 -- 490
		if step1 then -- 491
			drawBlossomDot( -- 492
				uiInkDraw, -- 492
				uiArt, -- 492
				"obj_m1", -- 492
				x1, -- 492
				by, -- 492
				11, -- 492
				PALETTE.emerald, -- 492
				0.94 * alpha, -- 492
				3 -- 492
			) -- 492
		else -- 492
			uiArt:tryPlace( -- 494
				"ink_enso_fine", -- 494
				"obj_m1", -- 494
				x1, -- 494
				by, -- 494
				11, -- 494
				11, -- 494
				{ -- 494
					color = toColor(PALETTE.silkLine), -- 494
					opacity = 0.72 * alpha, -- 494
					layer = 3 -- 494
				} -- 494
			) -- 494
		end -- 494
		texts:put( -- 496
			"xs", -- 496
			t1, -- 496
			x1 + 13, -- 496
			by, -- 496
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 496
			0, -- 496
			0.5, -- 496
			"Left", -- 496
			1, -- 496
			alpha, -- 496
			0.08 -- 496
		) -- 496
		local x2 = cx + 18 -- 498
		if step2 then -- 499
			drawBlossomDot( -- 500
				uiInkDraw, -- 500
				uiArt, -- 500
				"obj_m2", -- 500
				x2, -- 500
				by, -- 500
				11, -- 500
				PALETTE.emerald, -- 500
				0.94 * alpha, -- 500
				3 -- 500
			) -- 500
		else -- 500
			uiArt:tryPlace( -- 502
				"ink_enso_fine", -- 502
				"obj_m2", -- 502
				x2, -- 502
				by, -- 502
				11, -- 502
				11, -- 502
				{ -- 502
					color = toColor(PALETTE.silkDim), -- 502
					opacity = 0.62 * alpha, -- 502
					layer = 3 -- 502
				} -- 502
			) -- 502
		end -- 502
		texts:put( -- 504
			"xs", -- 504
			t2, -- 504
			x2 + 13, -- 504
			by, -- 504
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 504
			0, -- 504
			0.5, -- 504
			"Left", -- 504
			1, -- 504
			alpha, -- 504
			0.08 -- 504
		) -- 504
	end -- 504
end -- 383
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 508
	local bob = math.sin(self.time * 3.4) * 2.8 -- 519
	local viewW = cam.viewW / uiScale -- 520
	local viewH = cam.viewH / uiScale -- 521
	local i = 0 -- 522
	do -- 522
		i = 0 -- 523
		while i < #prompts do -- 523
			local pr = prompts[i + 1] -- 524
			local keyW = math.max( -- 525
				24, -- 525
				visualTextWidth(pr.keyTag, 15) + 16 -- 525
			) -- 525
			local labelW = visualTextWidth(pr.label, 15) -- 526
			local pillW = keyW + labelW + 24 -- 527
			local padX = math.max(115, pillW * 0.5 + 24) -- 528
			local sx = math.max( -- 529
				padX + safe.left, -- 529
				math.min( -- 529
					viewW - padX - safe.right, -- 529
					cam:sx(pr.x) / uiScale -- 529
				) -- 529
			) -- 529
			local sy = math.max( -- 530
				96 + safe.bottom, -- 530
				math.min( -- 530
					viewH - 110 - safe.top, -- 530
					cam:sy(pr.y) / uiScale + bob -- 530
				) -- 530
			) -- 530
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 531
			uiInkDraw:drawSegment( -- 533
				Vec2(sx, sy - 14), -- 533
				Vec2(sx, sy - 27), -- 533
				0.8, -- 533
				toColor(accent, 135 * alpha) -- 533
			) -- 533
			drawBlossomDot( -- 534
				uiInkDraw, -- 534
				uiArt, -- 534
				"wp_anchor_" .. tostring(i), -- 534
				sx, -- 534
				sy - 28, -- 534
				7, -- 534
				accent, -- 534
				0.85 * alpha, -- 534
				3 -- 534
			) -- 534
			local px = sx - pillW * 0.5 -- 536
			local py = sy - 12 -- 537
			drawSilkVeil( -- 539
				uiDraw, -- 539
				uiArt, -- 539
				"wp_bg_" .. tostring(i), -- 539
				sx, -- 539
				py + 12, -- 539
				pillW + 40, -- 539
				32, -- 539
				PALETTE.inkWash, -- 539
				0.78 * alpha, -- 539
				0 -- 539
			) -- 539
			drawHairline( -- 540
				uiInkDraw, -- 540
				uiArt, -- 540
				"wp_line_" .. tostring(i), -- 540
				sx, -- 540
				py + 24, -- 540
				pillW + 4, -- 540
				accent, -- 540
				0.45 * alpha, -- 540
				false, -- 540
				2 -- 540
			) -- 540
			drawSilkKeycap( -- 541
				uiInkDraw, -- 541
				texts, -- 541
				px + 2, -- 541
				py + 2, -- 541
				keyW, -- 541
				20, -- 541
				pr.keyTag, -- 541
				accent, -- 541
				alpha, -- 541
				pr.urgent -- 541
			) -- 541
			texts:put( -- 542
				"xs", -- 542
				pr.label, -- 542
				px + keyW + 12, -- 542
				py + 12, -- 542
				toColor(PALETTE.textBright), -- 542
				0, -- 542
				0.5, -- 542
				"Left", -- 542
				0.8, -- 542
				alpha, -- 542
				0.08 -- 542
			) -- 542
			i = i + 1 -- 523
		end -- 523
	end -- 523
end -- 508
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 546
	local mx = p.aimX / uiScale -- 556
	local my = p.aimY / uiScale -- 557
	if mx <= 0 and my <= 0 then -- 558
		return -- 559
	end -- 559
	if p.childMode then -- 562
		local aiming = p.room.key == "village" and p.hasBottle -- 563
		if touchMode and (not aiming or p.aimHold <= 0) then -- 564
			return -- 565
		end -- 565
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 567
		uiInkDraw:drawDot( -- 568
			Vec2(mx, my), -- 568
			aiming and 2 or 1.6, -- 568
			toColor(col, aiming and 215 or 120) -- 568
		) -- 568
		if aiming then -- 569
			local sz = p.aimHold > 0 and 32 or 24 -- 570
			uiArt:tryPlace( -- 571
				"ink_enso_fine", -- 571
				"reticle_child", -- 571
				mx, -- 571
				my, -- 571
				sz, -- 571
				sz, -- 571
				{ -- 571
					color = toColor(PALETTE.amberCore), -- 572
					opacity = 0.82, -- 572
					angle = self.time * 24, -- 572
					layer = 5 -- 572
				} -- 572
			) -- 572
		end -- 572
		return -- 575
	end -- 575
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 578
	local onEnemy = false -- 579
	local i = 0 -- 580
	do -- 580
		i = 0 -- 581
		while i < #p.enemies do -- 581
			local e = p.enemies[i + 1] -- 582
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 583
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 584
				onEnemy = true -- 585
			end -- 585
			i = i + 1 -- 581
		end -- 581
	end -- 581
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 589
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 590
	local arm = onEnemy and 8.5 or 9.5 -- 591
	local bg = Color(10, 12, 18, 160) -- 592
	uiInkDraw:drawSegment( -- 594
		Vec2(mx - gap - arm, my), -- 594
		Vec2(mx - gap, my), -- 594
		2.1, -- 594
		bg -- 594
	) -- 594
	uiInkDraw:drawSegment( -- 595
		Vec2(mx + gap, my), -- 595
		Vec2(mx + gap + arm, my), -- 595
		2.1, -- 595
		bg -- 595
	) -- 595
	uiInkDraw:drawSegment( -- 596
		Vec2(mx, my - gap - arm), -- 596
		Vec2(mx, my - gap), -- 596
		2.1, -- 596
		bg -- 596
	) -- 596
	uiInkDraw:drawSegment( -- 597
		Vec2(mx, my + gap), -- 597
		Vec2(mx, my + gap + arm), -- 597
		2.1, -- 597
		bg -- 597
	) -- 597
	uiInkDraw:drawSegment( -- 599
		Vec2(mx - gap - arm, my), -- 599
		Vec2(mx - gap, my), -- 599
		1.1, -- 599
		toColor(col, 230) -- 599
	) -- 599
	uiInkDraw:drawSegment( -- 600
		Vec2(mx + gap, my), -- 600
		Vec2(mx + gap + arm, my), -- 600
		1.1, -- 600
		toColor(col, 230) -- 600
	) -- 600
	uiInkDraw:drawSegment( -- 601
		Vec2(mx, my - gap - arm), -- 601
		Vec2(mx, my - gap), -- 601
		1.1, -- 601
		toColor(col, 230) -- 601
	) -- 601
	uiInkDraw:drawSegment( -- 602
		Vec2(mx, my + gap), -- 602
		Vec2(mx, my + gap + arm), -- 602
		1.1, -- 602
		toColor(col, 230) -- 602
	) -- 602
	uiInkDraw:drawDot( -- 603
		Vec2(mx, my), -- 603
		1.8, -- 603
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 603
	) -- 603
	if onEnemy then -- 605
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 606
		uiArt:tryPlace( -- 607
			"ink_enso_fine", -- 607
			"reticle_lock", -- 607
			mx, -- 607
			my, -- 607
			sz, -- 607
			sz, -- 607
			{ -- 607
				color = toColor(PALETTE.rouge), -- 608
				opacity = 0.88, -- 608
				angle = self.time * 38, -- 608
				layer = 5 -- 608
			} -- 608
		) -- 608
		fillRadialGlow( -- 610
			uiGlow, -- 610
			mx, -- 610
			my, -- 610
			16, -- 610
			16, -- 610
			toColor(PALETTE.rouge, 30), -- 610
			Color(182, 58, 56, 0), -- 610
			10 -- 610
		) -- 610
	end -- 610
end -- 546
return ____exports -- 546
