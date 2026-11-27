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
local ____target = require("Script.watch.target") -- 16
local getActiveTarget = ____target.getActiveTarget -- 16
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
	self.roguelikeUiHandled = false -- 42
end -- 35
function HudRenderer.prototype.reset(self, p) -- 46
	self.ghostHp = p ~= nil and p.hp or 3 -- 47
	self.talentSelected = 0 -- 48
end -- 46
function HudRenderer.prototype.update(self, dt, p) -- 51
	self.time = self.time + dt -- 52
	if self.ghostHp > p.hp then -- 53
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 54
	else -- 54
		self.ghostHp = p.hp -- 56
	end -- 56
end -- 51
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle, inputMode, gamepadLayout, safe, retryHoldProgress, touchOverlayVisible) -- 60
	if assistHintsEnabled == nil then -- 71
		assistHintsEnabled = false -- 71
	end -- 71
	if suppressReticle == nil then -- 72
		suppressReticle = false -- 72
	end -- 72
	if inputMode == nil then -- 73
		inputMode = "kbm" -- 73
	end -- 73
	if gamepadLayout == nil then -- 74
		gamepadLayout = "xbox" -- 74
	end -- 74
	if safe == nil then -- 75
		safe = ZERO_SAFE_INSETS -- 75
	end -- 75
	if retryHoldProgress == nil then -- 76
		retryHoldProgress = 0 -- 76
	end -- 76
	if touchOverlayVisible == nil then -- 77
		touchOverlayVisible = false -- 77
	end -- 77
	local w = cam.viewW / uiScale -- 79
	local h = cam.viewH / uiScale -- 80
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 81
	if hudAlpha > 0.05 then -- 83
		if p.childMode then -- 84
			self:drawChildStatus( -- 85
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
		else -- 85
			self:drawSoldierStatus( -- 87
				uiDraw, -- 87
				uiInkDraw, -- 87
				uiArt, -- 87
				texts, -- 87
				p, -- 87
				h, -- 87
				hudAlpha, -- 87
				assistHintsEnabled, -- 87
				inputMode, -- 87
				gamepadLayout, -- 87
				safe -- 87
			) -- 87
		end -- 87
		self:drawChapterBadge( -- 90
			uiDraw, -- 90
			uiArt, -- 90
			texts, -- 90
			p, -- 90
			w, -- 90
			h, -- 90
			hudAlpha, -- 90
			inputMode, -- 90
			safe, -- 90
			touchOverlayVisible -- 90
		) -- 90
		self:drawContextualObjective( -- 91
			uiDraw, -- 91
			uiInkDraw, -- 91
			uiArt, -- 91
			texts, -- 91
			p, -- 91
			w, -- 91
			h, -- 91
			hudAlpha, -- 91
			assistHintsEnabled, -- 91
			inputMode, -- 91
			gamepadLayout, -- 91
			safe -- 91
		) -- 91
		if assistHintsEnabled then -- 93
			local prompt = deriveWorldPrompt(p) -- 94
			if prompt ~= nil then -- 95
				local adapted = { -- 96
					x = prompt.x, -- 97
					y = prompt.y, -- 98
					keyTag = getActiveTarget():adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout), -- 99
					label = prompt.label, -- 100
					urgent = prompt.urgent, -- 101
					progress = prompt.progress -- 102
				} -- 102
				self:drawWorldPrompts( -- 104
					uiDraw, -- 104
					uiInkDraw, -- 104
					uiArt, -- 104
					texts, -- 104
					{adapted}, -- 104
					cam, -- 104
					hudAlpha, -- 104
					uiScale, -- 104
					safe -- 104
				) -- 104
			end -- 104
		end -- 104
		if vfx.deflectFlash > 0.25 then -- 108
			local dx = cam:sx(vfx.deflectX) / uiScale -- 109
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 110
			texts:put( -- 111
				"sm", -- 111
				"掩体挡下", -- 111
				dx, -- 111
				dy, -- 111
				toColor(PALETTE.textBright), -- 111
				0.5, -- 111
				0.5, -- 111
				"Center", -- 111
				2, -- 111
				vfx.deflectFlash, -- 111
				0.1 -- 111
			) -- 111
		end -- 111
	end -- 111
	if retryHoldProgress > 0.02 then -- 116
		local cx = w * 0.5 -- 117
		local cy = h - 32 - safe.top -- 118
		local bw = 220 -- 119
		drawSilkVeil( -- 120
			uiDraw, -- 120
			uiArt, -- 120
			"hud_retry_hold_veil", -- 120
			cx, -- 120
			cy, -- 120
			bw + 60, -- 120
			34, -- 120
			PALETTE.inkWarm, -- 120
			0.84, -- 120
			2 -- 120
		) -- 120
		texts:put( -- 121
			"xs", -- 121
			"长按 BACK 重试检查点", -- 121
			cx, -- 121
			cy + 7, -- 121
			toColor(PALETTE.amberCore), -- 121
			0.5, -- 121
			0.5, -- 121
			"Center", -- 121
			1, -- 121
			0.96, -- 121
			0.08 -- 121
		) -- 121
		local x0 = cx - bw * 0.44 -- 122
		local x1 = cx + bw * 0.44 -- 123
		uiInkDraw:drawSegment( -- 124
			Vec2(x0, cy - 8), -- 124
			Vec2(x1, cy - 8), -- 124
			1.4, -- 124
			toColor(PALETTE.silkDim, 120) -- 124
		) -- 124
		uiInkDraw:drawSegment( -- 125
			Vec2(x0, cy - 8), -- 125
			Vec2( -- 125
				x0 + (x1 - x0) * math.min(1, retryHoldProgress), -- 125
				cy - 8 -- 125
			), -- 125
			2.8, -- 125
			toColor(PALETTE.rouge, 235) -- 125
		) -- 125
	end -- 125
	if not suppressReticle then -- 128
		self:drawReticleOverlay( -- 129
			uiInkDraw, -- 129
			uiArt, -- 129
			uiGlow, -- 129
			p, -- 129
			cam, -- 129
			vfx, -- 129
			letterboxFrac, -- 129
			uiScale, -- 129
			inputMode == "touch" -- 129
		) -- 129
	end -- 129
end -- 60
function HudRenderer.prototype.talentCardRects(self, w, h, count, touchMode, safeTop) -- 134
	if touchMode == nil then -- 134
		touchMode = false -- 134
	end -- 134
	if safeTop == nil then -- 134
		safeTop = 0 -- 134
	end -- 134
	if self.talentRectProvider ~= nil then -- 135
		return self:talentRectProvider( -- 136
			w, -- 136
			h, -- 136
			count, -- 136
			touchMode, -- 136
			safeTop -- 136
		) -- 136
	end -- 136
	return computeTalentSlipRects( -- 138
		w, -- 138
		h, -- 138
		count, -- 138
		touchMode, -- 138
		safeTop -- 138
	) -- 138
end -- 134
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, touchMode) -- 142
	if touchMode == nil then -- 151
		touchMode = false -- 151
	end -- 151
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 153
		self:drawReticle( -- 155
			uiInkDraw, -- 155
			uiArt, -- 155
			uiGlow, -- 155
			p, -- 155
			cam, -- 155
			vfx, -- 155
			uiScale, -- 155
			touchMode -- 155
		) -- 155
	end -- 155
end -- 142
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 159
	local bx = 28 + safe.left -- 172
	local by = h - 72 - safe.top -- 173
	local lowHp = p.hp <= 1 -- 174
	local segCount = math.max(1, p.maxHp) -- 176
	local segW = segCount >= 5 and 42 or 54 -- 177
	local segH = 9 -- 178
	local gap = segCount >= 5 and 6 or 8 -- 179
	local veilW = math.max(340, 124 + segCount * (segW + gap)) -- 180
	drawSilkVeil( -- 181
		uiDraw, -- 181
		uiArt, -- 181
		"hud_soldier_veil", -- 181
		bx + veilW * 0.44, -- 181
		by + 24, -- 181
		veilW, -- 181
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
	local barX = bx + 44 -- 186
	local barY = by + 16 -- 187
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < segCount do -- 190
			local sx = barX + i * (segW + gap) -- 191
			local scx = sx + segW * 0.5 -- 192
			if not uiArt:tryPlace( -- 193
				"ink_bamboo_slot", -- 193
				"hp_slot_" .. tostring(i), -- 193
				scx, -- 193
				barY, -- 193
				segW, -- 193
				segH, -- 193
				{ -- 193
					color = toColor(PALETTE.silkDim), -- 194
					opacity = 0.72 * alpha, -- 194
					layer = 1 -- 194
				} -- 194
			) then -- 194
				uiInkDraw:drawRect( -- 196
					Rect(sx, barY - 3, segW, 6), -- 196
					Color(0, 0, 0, 0), -- 196
					0.8, -- 196
					toColor(PALETTE.silkDim, 145 * alpha) -- 196
				) -- 196
			end -- 196
			if self.ghostHp > i and self.ghostHp > p.hp then -- 198
				local frac = math.min(1, self.ghostHp - i) -- 199
				uiInkDraw:drawRect( -- 200
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 200
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 200
				) -- 200
			end -- 200
			if p.hp > i then -- 202
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 203
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 204
				if not uiArt:tryPlace( -- 205
					"ink_bamboo_slip", -- 205
					"hp_fill_" .. tostring(i), -- 205
					scx, -- 205
					barY, -- 205
					segW, -- 205
					segH, -- 205
					{ -- 205
						color = toColor(fillCol), -- 206
						opacity = 0.94 * alpha * pulse, -- 206
						layer = 2 -- 206
					} -- 206
				) then -- 206
					uiInkDraw:drawRect( -- 208
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 208
						toColor(fillCol, 230 * alpha * pulse) -- 208
					) -- 208
				end -- 208
			end -- 208
			i = i + 1 -- 190
		end -- 190
	end -- 190
	local covX = barX + segCount * (segW + gap) + 6 -- 213
	local hasAliveEnemy = false -- 214
	do -- 214
		i = 0 -- 215
		while i < #p.enemies do -- 215
			if p.enemies[i + 1].alive then -- 216
				hasAliveEnemy = true -- 217
				break -- 218
			end -- 218
			i = i + 1 -- 215
		end -- 215
	end -- 215
	if p.coverHug then -- 221
		if hasAliveEnemy and not p.coverBlocking then -- 222
			uiInkDraw:drawRect( -- 223
				Rect(covX, barY - 9, 72, 18), -- 223
				toColor(PALETTE.inkWarm, 185 * alpha), -- 223
				0.8, -- 223
				toColor(PALETTE.amber, 200 * alpha) -- 223
			) -- 223
			texts:put( -- 224
				"xs", -- 224
				"背向掩体", -- 224
				covX + 36, -- 224
				barY, -- 224
				toColor(PALETTE.amberCore), -- 224
				0.5, -- 224
				0.5, -- 224
				"Center", -- 224
				0.6, -- 224
				alpha, -- 224
				0 -- 224
			) -- 224
		else -- 224
			uiInkDraw:drawRect( -- 226
				Rect(covX, barY - 9, 54, 18), -- 226
				toColor(PALETTE.cyanDim, 165 * alpha), -- 226
				0.8, -- 226
				toColor(PALETTE.cyanCore, 180 * alpha) -- 226
			) -- 226
			texts:put( -- 227
				"xs", -- 227
				"掩体中", -- 227
				covX + 27, -- 227
				barY, -- 227
				toColor(PALETTE.textBright), -- 227
				0.5, -- 227
				0.5, -- 227
				"Center", -- 227
				0.6, -- 227
				alpha, -- 227
				0 -- 227
			) -- 227
		end -- 227
	elseif assistHintsEnabled and p.coverNear then -- 229
		uiInkDraw:drawRect( -- 230
			Rect(covX, barY - 9, 54, 18), -- 230
			Color( -- 230
				14, -- 230
				17, -- 230
				25, -- 230
				math.floor(150 * alpha + 0.5) -- 230
			), -- 230
			0.8, -- 230
			toColor(PALETTE.silkLine, 165 * alpha) -- 230
		) -- 230
		texts:put( -- 231
			"xs", -- 231
			"可贴靠", -- 231
			covX + 27, -- 231
			barY, -- 231
			toColor(PALETTE.textMid), -- 231
			0.5, -- 231
			0.5, -- 231
			"Center", -- 231
			0.6, -- 231
			alpha, -- 231
			0.08 -- 231
		) -- 231
	end -- 231
	local ____p_isCampaign_5 = p.isCampaign -- 234
	if ____p_isCampaign_5 then -- 234
		local ____opt_0 = p.room.campaign -- 234
		local ____temp_4 = (____opt_0 and ____opt_0.chapter) == "S" -- 234
		if not ____temp_4 then -- 234
			local ____opt_2 = p.room.campaign -- 234
			____temp_4 = (____opt_2 and ____opt_2.chapter) == "C" -- 234
		end -- 234
		____p_isCampaign_5 = ____temp_4 -- 234
	end -- 234
	local showCampaignFear = ____p_isCampaign_5 and (p.escort.fear > 0 or p.escort.state == "frozen" or p.escort.state == "calming") -- 234
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" or showCampaignFear then -- 236
		local subY = by - 24 -- 237
		local frozen = p.escort.state == "frozen" -- 238
		local calming = p.escort.state == "calming" -- 239
		drawSilkVeil( -- 241
			uiDraw, -- 241
			uiArt, -- 241
			"hud_fear_veil", -- 241
			bx + 126, -- 241
			subY + 6, -- 241
			260, -- 241
			30, -- 241
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 241
			0.64 * alpha, -- 241
			-1 -- 241
		) -- 241
		texts:put( -- 242
			"xs", -- 242
			"小满 · 惊惧", -- 242
			bx + 14, -- 242
			subY + 6, -- 242
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 242
			0, -- 242
			0.5, -- 242
			"Left", -- 242
			1, -- 242
			alpha, -- 242
			0.08 -- 242
		) -- 242
		local k = 0 -- 244
		do -- 244
			k = 0 -- 245
			while k < FEAR_MAX do -- 245
				local dx = bx + 114 + k * 20 -- 246
				local dy = subY + 6 -- 247
				local lit = k < p.escort.fear -- 248
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 249
				uiArt:tryPlace( -- 250
					"ink_enso_fine", -- 250
					"fear_ring_" .. tostring(k), -- 250
					dx, -- 250
					dy, -- 250
					14, -- 250
					14, -- 250
					{ -- 250
						color = toColor(lit and dc or PALETTE.silkLine), -- 251
						opacity = (lit and 0.92 or 0.64) * alpha, -- 251
						layer = 2 -- 251
					} -- 251
				) -- 251
				if lit then -- 253
					drawBlossomDot( -- 254
						uiInkDraw, -- 254
						uiArt, -- 254
						"fear_dot_" .. tostring(k), -- 254
						dx, -- 254
						dy, -- 254
						10, -- 254
						dc, -- 254
						0.96 * alpha, -- 254
						3 -- 254
					) -- 254
				end -- 254
				k = k + 1 -- 245
			end -- 245
		end -- 245
		if frozen then -- 258
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 259
			if assistHintsEnabled then -- 260
				local calmKey = getActiveTarget():adaptWorldKeyTag("E", inputMode, gamepadLayout) -- 261
				local keyW = math.max( -- 262
					22, -- 262
					visualTextWidth(calmKey, 15) + 10 -- 262
				) -- 262
				drawSilkKeycap( -- 263
					uiInkDraw, -- 263
					texts, -- 263
					bx + 170, -- 263
					subY - 5, -- 263
					keyW, -- 263
					22, -- 263
					calmKey, -- 263
					PALETTE.rouge, -- 263
					alpha * pulse, -- 263
					true -- 263
				) -- 263
				texts:put( -- 264
					"xs", -- 264
					"轻敲安抚", -- 264
					bx + 176 + keyW, -- 264
					subY + 6, -- 264
					toColor(PALETTE.crimsonCore), -- 264
					0, -- 264
					0.5, -- 264
					"Left", -- 264
					0.8, -- 264
					alpha * pulse, -- 264
					0.08 -- 264
				) -- 264
			else -- 264
				texts:put( -- 266
					"xs", -- 266
					"受惊停步", -- 266
					bx + 172, -- 266
					subY + 6, -- 266
					toColor(PALETTE.crimsonCore), -- 266
					0, -- 266
					0.5, -- 266
					"Left", -- 266
					0.8, -- 266
					alpha * pulse, -- 266
					0.08 -- 266
				) -- 266
			end -- 266
		elseif calming then -- 268
			texts:put( -- 269
				"xs", -- 269
				"轻敲安抚中", -- 269
				bx + 172, -- 269
				subY + 6, -- 269
				toColor(PALETTE.emerald), -- 269
				0, -- 269
				0.5, -- 269
				"Left", -- 269
				0.8, -- 269
				alpha, -- 269
				0.08 -- 269
			) -- 269
		end -- 269
	end -- 269
	if not self.roguelikeUiHandled then -- 273
		local ranks = p:getStoryTalentRanks() -- 274
		if p:isEscortRoom() then -- 275
			local inv = p.run.inventory -- 276
			local sup = {} -- 277
			sup[#sup + 1] = weaponNameOf(p.equippedWeapon) -- 278
			local attempt = p:getEscortAttempt() -- 279
			if attempt > 1 then -- 280
				sup[#sup + 1] = ("第" .. tostring(attempt)) .. "轮" -- 280
			end -- 280
			if inv.wood > 0 then -- 281
				sup[#sup + 1] = "木筹" .. tostring(inv.wood) -- 281
			end -- 281
			if inv.bell > 0 then -- 282
				sup[#sup + 1] = "铃筹" .. tostring(inv.bell) -- 282
			end -- 282
			if inv.shield > 0 then -- 283
				sup[#sup + 1] = "残盾" .. tostring(inv.shield) -- 283
			end -- 283
			if inv.wedge > 0 then -- 284
				sup[#sup + 1] = "木楔" .. tostring(inv.wedge) -- 284
			end -- 284
			if inv.ammo > 0 then -- 285
				sup[#sup + 1] = "弹包" .. tostring(inv.ammo) -- 285
			end -- 285
			local row1Y = by - 22 -- 286
			local supTxt = table.concat(sup, " · ") -- 287
			local supW = math.max( -- 288
				240, -- 288
				visualTextWidth(supTxt, 15) + 34 -- 288
			) -- 288
			drawSilkVeil( -- 289
				uiDraw, -- 289
				uiArt, -- 289
				"hud_escort_sup_veil", -- 289
				bx + supW * 0.48, -- 289
				row1Y + 6, -- 289
				supW, -- 289
				24, -- 289
				PALETTE.inkWash, -- 289
				0.54 * alpha, -- 289
				-1 -- 289
			) -- 289
			texts:put( -- 290
				"xs", -- 290
				supTxt, -- 290
				bx + 14, -- 290
				row1Y + 6, -- 290
				toColor(PALETTE.cyanCore), -- 290
				0, -- 290
				0.5, -- 290
				"Left", -- 290
				0.6, -- 290
				alpha, -- 290
				0.08 -- 290
			) -- 290
			if ranks ~= nil then -- 292
				local parts = {} -- 293
				local ti = 0 -- 294
				do -- 294
					ti = 0 -- 295
					while ti < #ALL_TALENTS do -- 295
						local tid = ALL_TALENTS[ti + 1] -- 296
						local rk = ranks[tid] or 0 -- 297
						if rk > 0 then -- 298
							parts[#parts + 1] = TALENT_CATALOG[tid].title .. tostring(rk) -- 299
						end -- 299
						ti = ti + 1 -- 295
					end -- 295
				end -- 295
				if #parts > 0 then -- 302
					local row2Y = row1Y - 26 -- 303
					local txt = "本领 · " .. table.concat(parts, " · ") -- 304
					local talW = math.max( -- 305
						240, -- 305
						visualTextWidth(txt, 15) + 34 -- 305
					) -- 305
					drawSilkVeil( -- 306
						uiDraw, -- 306
						uiArt, -- 306
						"hud_talent_ranks_veil", -- 306
						bx + talW * 0.48, -- 306
						row2Y + 6, -- 306
						talW, -- 306
						24, -- 306
						PALETTE.inkWash, -- 306
						0.56 * alpha, -- 306
						-1 -- 306
					) -- 306
					texts:put( -- 307
						"xs", -- 307
						txt, -- 307
						bx + 14, -- 307
						row2Y + 6, -- 307
						toColor(PALETTE.amberCore), -- 307
						0, -- 307
						0.5, -- 307
						"Left", -- 307
						0.8, -- 307
						alpha, -- 307
						0.08 -- 307
					) -- 307
				end -- 307
			end -- 307
		elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 310
			local inv = p.run.inventory -- 311
			local items = {} -- 312
			if inv.shield > 0 then -- 313
				items[#items + 1] = "残盾" .. tostring(inv.shield) -- 313
			end -- 313
			if inv.wedge > 0 then -- 314
				items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 314
			end -- 314
			if inv.ammo > 0 then -- 315
				items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 315
			end -- 315
			if inv.scrap > 0 then -- 316
				items[#items + 1] = "木料" .. tostring(inv.scrap) -- 316
			end -- 316
			local companionText = p.run.joined and "小满同行" or "小满等待" -- 317
			local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 318
			local subY = by - 22 -- 319
			drawSilkVeil( -- 320
				uiDraw, -- 320
				uiArt, -- 320
				"hud_camp_veil", -- 320
				bx + 126, -- 320
				subY + 6, -- 320
				260, -- 320
				26, -- 320
				PALETTE.inkWash, -- 320
				0.54 * alpha, -- 320
				-1 -- 320
			) -- 320
			texts:put( -- 321
				"xs", -- 321
				summary, -- 321
				bx + 14, -- 321
				subY + 6, -- 321
				toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 321
				0, -- 321
				0.5, -- 321
				"Left", -- 321
				0.8, -- 321
				alpha, -- 321
				0.08 -- 321
			) -- 321
		end -- 321
	end -- 321
end -- 159
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 326
	local bx = 28 + safe.left -- 339
	local by = h - 68 - safe.top -- 340
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 341
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 342
	drawSilkVeil( -- 344
		uiDraw, -- 344
		uiArt, -- 344
		"hud_child_veil", -- 344
		bx + 144, -- 344
		by + 22, -- 344
		316, -- 344
		48, -- 344
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 344
		0.58 * alpha, -- 344
		-1 -- 344
	) -- 344
	texts:put( -- 345
		"md", -- 345
		alert and "危" or "满", -- 345
		bx + 16, -- 345
		by + 22, -- 345
		toColor(leadCol), -- 345
		0.5, -- 345
		0.5, -- 345
		"Center", -- 345
		0, -- 345
		alpha, -- 345
		0.1 -- 345
	) -- 345
	uiInkDraw:drawSegment( -- 346
		Vec2(bx + 32, by + 7), -- 346
		Vec2(bx + 32, by + 37), -- 346
		0.8, -- 346
		toColor(PALETTE.silkDim, 130 * alpha) -- 346
	) -- 346
	texts:put( -- 347
		"xs", -- 347
		"小满 · 潜行", -- 347
		bx + 44, -- 347
		by + 33, -- 347
		toColor(PALETTE.amberCore), -- 347
		0, -- 347
		0.5, -- 347
		"Left", -- 347
		1.4, -- 347
		alpha, -- 347
		0.08 -- 347
	) -- 347
	local posture = assistHintsEnabled and "轻步前行 · 保持隐蔽" or "轻步前行" -- 349
	local col = PALETTE.textMid -- 350
	if alert then -- 351
		posture = (p.scavChase or p.dogState == "chase") and (assistHintsEnabled and "已被发现 · 速寻隐蔽" or "已被发现") or (assistHintsEnabled and "引起警觉 · 停步蹲伏" or "引起警觉") -- 352
		col = PALETTE.crimsonCore -- 355
	elseif p.player.crouch then -- 356
		posture = assistHintsEnabled and "低姿伏行 · 匿迹于影" or "低姿伏行" -- 357
		col = PALETTE.emerald -- 358
	elseif p.hasBottle then -- 359
		posture = assistHintsEnabled and getActiveTarget():adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout) or "手持陶瓶" -- 360
		col = PALETTE.amberCore -- 363
	end -- 363
	texts:put( -- 365
		"xs", -- 365
		posture, -- 365
		bx + 44, -- 365
		by + 12, -- 365
		toColor(col), -- 365
		0, -- 365
		0.5, -- 365
		"Left", -- 365
		0.6, -- 365
		alpha, -- 365
		0.08 -- 365
	) -- 365
end -- 326
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha, inputMode, safe, touchOverlayVisible) -- 368
	local theme = themeOf(p.room.key) -- 380
	local rx = w - 32 - safe.right - (touchOverlayVisible and 208 or 0) -- 381
	local cy = h - 44 - safe.top -- 382
	local pauseTip = inputMode == "gamepad" and "START 暂歇" or "Esc 暂歇" -- 383
	drawSilkVeil( -- 385
		uiDraw, -- 385
		uiArt, -- 385
		"hud_chap_veil", -- 385
		rx - 82, -- 385
		cy, -- 385
		240, -- 385
		44, -- 385
		PALETTE.inkWash, -- 385
		0.44 * alpha, -- 385
		-1 -- 385
	) -- 385
	texts:put( -- 386
		"xs", -- 386
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 386
		rx, -- 386
		touchOverlayVisible and cy or cy + 9, -- 386
		toColor(PALETTE.textBright), -- 386
		1, -- 386
		0.5, -- 386
		"Right", -- 386
		1.2, -- 386
		alpha, -- 386
		0.08 -- 386
	) -- 386
	if not touchOverlayVisible then -- 387
		texts:put( -- 388
			"xs", -- 388
			pauseTip, -- 388
			rx, -- 388
			cy - 11, -- 388
			toColor(PALETTE.textDim), -- 388
			1, -- 388
			0.5, -- 388
			"Right", -- 388
			1, -- 388
			0.78 * alpha, -- 388
			0.08 -- 388
		) -- 388
	end -- 388
end -- 368
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 392
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 409
		local g = p.room.story.gate -- 410
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 411
			local bw = 400 -- 412
			local cx = w * 0.5 -- 413
			local by = h - 64 - safe.top -- 414
			local tied = p.phase == "gate-hand" -- 415
			local ratio = tied and 1 or math.max( -- 416
				0, -- 416
				math.min( -- 416
					1, -- 416
					p.handTicks / math.max(1, p.handNeedTicks) -- 416
				) -- 416
			) -- 416
			local holdInteractKey = getActiveTarget():adaptWorldKeyTag("按住 E", inputMode, gamepadLayout) -- 417
			local reholdInteractKey = getActiveTarget():adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout) -- 418
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and holdInteractKey .. " · 把手伸给她" or reholdInteractKey .. " · 把手伸给她")) -- 419
			drawSilkVeil( -- 423
				uiDraw, -- 423
				uiArt, -- 423
				"hud_hand_veil", -- 423
				cx, -- 423
				by + 18, -- 423
				bw + 90, -- 423
				48, -- 423
				PALETTE.inkWash, -- 423
				0.76 * alpha, -- 423
				-1 -- 423
			) -- 423
			drawHairline( -- 424
				uiInkDraw, -- 424
				uiArt, -- 424
				"hud_hand_top", -- 424
				cx, -- 424
				by + 39, -- 424
				bw - 20, -- 424
				PALETTE.amber, -- 424
				0.55 * alpha, -- 424
				false, -- 424
				2 -- 424
			) -- 424
			texts:put( -- 425
				"xs", -- 425
				label, -- 425
				cx, -- 425
				by + 26, -- 425
				toColor(PALETTE.textBright), -- 425
				0.5, -- 425
				0.5, -- 425
				"Center", -- 425
				1.8, -- 425
				alpha, -- 425
				0.08 -- 425
			) -- 425
			local pbw = bw - 80 -- 427
			local pbx = cx - pbw * 0.5 -- 428
			local pby = by + 9 -- 429
			uiInkDraw:drawSegment( -- 430
				Vec2(pbx, pby), -- 430
				Vec2(pbx + pbw, pby), -- 430
				1.4, -- 430
				toColor(PALETTE.silkDim, 115 * alpha) -- 430
			) -- 430
			if ratio > 0.002 then -- 431
				uiInkDraw:drawSegment( -- 432
					Vec2(pbx, pby), -- 432
					Vec2(pbx + pbw * ratio, pby), -- 432
					2.8, -- 432
					toColor(PALETTE.amber, 230 * alpha) -- 432
				) -- 432
				uiInkDraw:drawSegment( -- 433
					Vec2(pbx, pby), -- 433
					Vec2(pbx + pbw * ratio, pby), -- 433
					1, -- 433
					toColor(PALETTE.amberCore, 165 * alpha) -- 433
				) -- 433
			end -- 433
			uiArt:tryPlace( -- 435
				"ink_enso_fine", -- 435
				"hand_knock_1", -- 435
				pbx + pbw * 0.62, -- 435
				pby, -- 435
				11, -- 435
				11, -- 435
				{ -- 435
					color = toColor(PALETTE.amber), -- 436
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 436
					layer = 3 -- 436
				} -- 436
			) -- 436
			uiArt:tryPlace( -- 438
				"ink_enso_fine", -- 438
				"hand_knock_2", -- 438
				pbx + pbw * 0.72, -- 438
				pby, -- 438
				11, -- 438
				11, -- 438
				{ -- 438
					color = toColor(PALETTE.amber), -- 439
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 439
					layer = 3 -- 439
				} -- 439
			) -- 439
		end -- 439
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 442
			local bw = 400 -- 443
			local cx = w * 0.5 -- 444
			local by = h - 64 - safe.top -- 445
			local ratio = math.max( -- 446
				0, -- 446
				math.min( -- 446
					1, -- 446
					p.gateTick / math.max(1, g.holdTicks) -- 446
				) -- 446
			) -- 446
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 447
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 448
			drawSilkVeil( -- 450
				uiDraw, -- 450
				uiArt, -- 450
				"hud_gate_veil", -- 450
				cx, -- 450
				by + 18, -- 450
				bw + 90, -- 450
				48, -- 450
				PALETTE.inkWash, -- 450
				0.76 * alpha, -- 450
				-1 -- 450
			) -- 450
			drawHairline( -- 451
				uiInkDraw, -- 451
				uiArt, -- 451
				"hud_gate_top", -- 451
				cx, -- 451
				by + 39, -- 451
				bw - 20, -- 451
				PALETTE.rougeSoft, -- 451
				0.55 * alpha, -- 451
				false, -- 451
				2 -- 451
			) -- 451
			local idleNeedConfirmLabel = assistHintsEnabled and getActiveTarget():adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout) or "绞盘待命" -- 453
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 456
			texts:put( -- 459
				"xs", -- 459
				label, -- 459
				cx, -- 459
				by + 26, -- 459
				toColor(PALETTE.textBright), -- 459
				0.5, -- 459
				0.5, -- 459
				"Center", -- 459
				1.8, -- 459
				alpha, -- 459
				0.08 -- 459
			) -- 459
			local pbw = bw - 80 -- 461
			local pbx = cx - pbw * 0.5 -- 462
			local pby = by + 9 -- 463
			uiInkDraw:drawSegment( -- 464
				Vec2(pbx, pby), -- 464
				Vec2(pbx + pbw, pby), -- 464
				1.4, -- 464
				toColor(PALETTE.silkDim, 115 * alpha) -- 464
			) -- 464
			if ratio > 0.002 then -- 465
				uiInkDraw:drawSegment( -- 466
					Vec2(pbx, pby), -- 466
					Vec2(pbx + pbw * ratio, pby), -- 466
					2.8, -- 466
					toColor(PALETTE.rouge, 230 * alpha) -- 466
				) -- 466
				uiInkDraw:drawSegment( -- 467
					Vec2(pbx, pby), -- 467
					Vec2(pbx + pbw * ratio, pby), -- 467
					1, -- 467
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 467
				) -- 467
			end -- 467
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 469
			local k = 0 -- 470
			do -- 470
				k = 0 -- 471
				while k < #waves do -- 471
					local wx = pbx + pbw * waves[k + 1] -- 472
					local passed = p.gateSpawned > k -- 473
					if passed then -- 474
						drawBlossomDot( -- 475
							uiInkDraw, -- 475
							uiArt, -- 475
							"gate_wave_" .. tostring(k), -- 475
							wx, -- 475
							pby, -- 475
							10, -- 475
							PALETTE.moonPale, -- 475
							0.92 * alpha, -- 475
							3 -- 475
						) -- 475
					else -- 475
						uiArt:tryPlace( -- 477
							"ink_enso_fine", -- 477
							"gate_wave_" .. tostring(k), -- 477
							wx, -- 477
							pby, -- 477
							11, -- 477
							11, -- 477
							{ -- 477
								color = toColor(PALETTE.rouge), -- 478
								opacity = 0.84 * alpha, -- 478
								layer = 3 -- 478
							} -- 478
						) -- 478
					end -- 478
					k = k + 1 -- 471
				end -- 471
			end -- 471
		end -- 471
		return -- 483
	end -- 483
	if not assistHintsEnabled then -- 486
		return -- 487
	end -- 487
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 489
		local cx = w * 0.5 -- 490
		local by = h - 44 - safe.top -- 491
		local step1 = p.cartDocked -- 492
		local ____temp_6 -- 493
		if p.room.key == "checkpoint" then -- 493
			____temp_6 = p.gateOpen -- 493
		else -- 493
			____temp_6 = p.checkpoint >= p.room.arch.x1 -- 493
		end -- 493
		local step2 = ____temp_6 -- 493
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 494
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 495
		drawSilkVeil( -- 497
			uiDraw, -- 497
			uiArt, -- 497
			"hud_obj_veil", -- 497
			cx, -- 497
			by, -- 497
			380, -- 497
			34, -- 497
			PALETTE.inkWash, -- 497
			0.58 * alpha, -- 497
			-1 -- 497
		) -- 497
		local x1 = cx - 134 -- 499
		if step1 then -- 500
			drawBlossomDot( -- 501
				uiInkDraw, -- 501
				uiArt, -- 501
				"obj_m1", -- 501
				x1, -- 501
				by, -- 501
				11, -- 501
				PALETTE.emerald, -- 501
				0.94 * alpha, -- 501
				3 -- 501
			) -- 501
		else -- 501
			uiArt:tryPlace( -- 503
				"ink_enso_fine", -- 503
				"obj_m1", -- 503
				x1, -- 503
				by, -- 503
				11, -- 503
				11, -- 503
				{ -- 503
					color = toColor(PALETTE.silkLine), -- 503
					opacity = 0.72 * alpha, -- 503
					layer = 3 -- 503
				} -- 503
			) -- 503
		end -- 503
		texts:put( -- 505
			"xs", -- 505
			t1, -- 505
			x1 + 13, -- 505
			by, -- 505
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 505
			0, -- 505
			0.5, -- 505
			"Left", -- 505
			1, -- 505
			alpha, -- 505
			0.08 -- 505
		) -- 505
		local x2 = cx + 18 -- 507
		if step2 then -- 508
			drawBlossomDot( -- 509
				uiInkDraw, -- 509
				uiArt, -- 509
				"obj_m2", -- 509
				x2, -- 509
				by, -- 509
				11, -- 509
				PALETTE.emerald, -- 509
				0.94 * alpha, -- 509
				3 -- 509
			) -- 509
		else -- 509
			uiArt:tryPlace( -- 511
				"ink_enso_fine", -- 511
				"obj_m2", -- 511
				x2, -- 511
				by, -- 511
				11, -- 511
				11, -- 511
				{ -- 511
					color = toColor(PALETTE.silkDim), -- 511
					opacity = 0.62 * alpha, -- 511
					layer = 3 -- 511
				} -- 511
			) -- 511
		end -- 511
		texts:put( -- 513
			"xs", -- 513
			t2, -- 513
			x2 + 13, -- 513
			by, -- 513
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 513
			0, -- 513
			0.5, -- 513
			"Left", -- 513
			1, -- 513
			alpha, -- 513
			0.08 -- 513
		) -- 513
	end -- 513
end -- 392
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale, safe) -- 517
	local bob = math.sin(self.time * 3.4) * 2.8 -- 528
	local viewW = cam.viewW / uiScale -- 529
	local viewH = cam.viewH / uiScale -- 530
	local i = 0 -- 531
	do -- 531
		i = 0 -- 532
		while i < #prompts do -- 532
			local pr = prompts[i + 1] -- 533
			local keyW = math.max( -- 534
				24, -- 534
				visualTextWidth(pr.keyTag, 15) + 16 -- 534
			) -- 534
			local labelW = visualTextWidth(pr.label, 15) -- 535
			local pillW = keyW + labelW + 24 -- 536
			local padX = math.max(115, pillW * 0.5 + 24) -- 537
			local sx = math.max( -- 538
				padX + safe.left, -- 538
				math.min( -- 538
					viewW - padX - safe.right, -- 538
					cam:sx(pr.x) / uiScale -- 538
				) -- 538
			) -- 538
			local sy = math.max( -- 539
				96 + safe.bottom, -- 539
				math.min( -- 539
					viewH - 110 - safe.top, -- 539
					cam:sy(pr.y) / uiScale + bob -- 539
				) -- 539
			) -- 539
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 540
			uiInkDraw:drawSegment( -- 542
				Vec2(sx, sy - 14), -- 542
				Vec2(sx, sy - 27), -- 542
				0.8, -- 542
				toColor(accent, 135 * alpha) -- 542
			) -- 542
			drawBlossomDot( -- 543
				uiInkDraw, -- 543
				uiArt, -- 543
				"wp_anchor_" .. tostring(i), -- 543
				sx, -- 543
				sy - 28, -- 543
				7, -- 543
				accent, -- 543
				0.85 * alpha, -- 543
				3 -- 543
			) -- 543
			local px = sx - pillW * 0.5 -- 545
			local py = sy - 12 -- 546
			drawSilkVeil( -- 548
				uiDraw, -- 548
				uiArt, -- 548
				"wp_bg_" .. tostring(i), -- 548
				sx, -- 548
				py + 12, -- 548
				pillW + 40, -- 548
				32, -- 548
				PALETTE.inkWash, -- 548
				0.78 * alpha, -- 548
				0 -- 548
			) -- 548
			drawHairline( -- 549
				uiInkDraw, -- 549
				uiArt, -- 549
				"wp_line_" .. tostring(i), -- 549
				sx, -- 549
				py + 24, -- 549
				pillW + 4, -- 549
				accent, -- 549
				0.45 * alpha, -- 549
				false, -- 549
				2 -- 549
			) -- 549
			drawSilkKeycap( -- 550
				uiInkDraw, -- 550
				texts, -- 550
				px + 2, -- 550
				py + 2, -- 550
				keyW, -- 550
				20, -- 550
				pr.keyTag, -- 550
				accent, -- 550
				alpha, -- 550
				pr.urgent -- 550
			) -- 550
			texts:put( -- 551
				"xs", -- 551
				pr.label, -- 551
				px + keyW + 12, -- 551
				py + 12, -- 551
				toColor(PALETTE.textBright), -- 551
				0, -- 551
				0.5, -- 551
				"Left", -- 551
				0.8, -- 551
				alpha, -- 551
				0.08 -- 551
			) -- 551
			i = i + 1 -- 532
		end -- 532
	end -- 532
end -- 517
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode) -- 555
	local mx = p.aimX / uiScale -- 565
	local my = p.aimY / uiScale -- 566
	if mx <= 0 and my <= 0 then -- 567
		return -- 568
	end -- 568
	if p.childMode then -- 571
		local aiming = p.room.key == "village" and p.hasBottle -- 572
		if touchMode and (not aiming or p.aimHold <= 0) then -- 573
			return -- 574
		end -- 574
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 576
		uiInkDraw:drawDot( -- 577
			Vec2(mx, my), -- 577
			aiming and 2 or 1.6, -- 577
			toColor(col, aiming and 215 or 120) -- 577
		) -- 577
		if aiming then -- 578
			local sz = p.aimHold > 0 and 32 or 24 -- 579
			uiArt:tryPlace( -- 580
				"ink_enso_fine", -- 580
				"reticle_child", -- 580
				mx, -- 580
				my, -- 580
				sz, -- 580
				sz, -- 580
				{ -- 580
					color = toColor(PALETTE.amberCore), -- 581
					opacity = 0.82, -- 581
					angle = self.time * 24, -- 581
					layer = 5 -- 581
				} -- 581
			) -- 581
		end -- 581
		return -- 584
	end -- 584
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 587
	local onEnemy = false -- 588
	local i = 0 -- 589
	do -- 589
		i = 0 -- 590
		while i < #p.enemies do -- 590
			local e = p.enemies[i + 1] -- 591
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 592
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 593
				onEnemy = true -- 594
			end -- 594
			i = i + 1 -- 590
		end -- 590
	end -- 590
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 598
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 599
	local arm = onEnemy and 8.5 or 9.5 -- 600
	local bg = Color(10, 12, 18, 160) -- 601
	uiInkDraw:drawSegment( -- 603
		Vec2(mx - gap - arm, my), -- 603
		Vec2(mx - gap, my), -- 603
		2.1, -- 603
		bg -- 603
	) -- 603
	uiInkDraw:drawSegment( -- 604
		Vec2(mx + gap, my), -- 604
		Vec2(mx + gap + arm, my), -- 604
		2.1, -- 604
		bg -- 604
	) -- 604
	uiInkDraw:drawSegment( -- 605
		Vec2(mx, my - gap - arm), -- 605
		Vec2(mx, my - gap), -- 605
		2.1, -- 605
		bg -- 605
	) -- 605
	uiInkDraw:drawSegment( -- 606
		Vec2(mx, my + gap), -- 606
		Vec2(mx, my + gap + arm), -- 606
		2.1, -- 606
		bg -- 606
	) -- 606
	uiInkDraw:drawSegment( -- 608
		Vec2(mx - gap - arm, my), -- 608
		Vec2(mx - gap, my), -- 608
		1.1, -- 608
		toColor(col, 230) -- 608
	) -- 608
	uiInkDraw:drawSegment( -- 609
		Vec2(mx + gap, my), -- 609
		Vec2(mx + gap + arm, my), -- 609
		1.1, -- 609
		toColor(col, 230) -- 609
	) -- 609
	uiInkDraw:drawSegment( -- 610
		Vec2(mx, my - gap - arm), -- 610
		Vec2(mx, my - gap), -- 610
		1.1, -- 610
		toColor(col, 230) -- 610
	) -- 610
	uiInkDraw:drawSegment( -- 611
		Vec2(mx, my + gap), -- 611
		Vec2(mx, my + gap + arm), -- 611
		1.1, -- 611
		toColor(col, 230) -- 611
	) -- 611
	uiInkDraw:drawDot( -- 612
		Vec2(mx, my), -- 612
		1.8, -- 612
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 612
	) -- 612
	if onEnemy then -- 614
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 615
		uiArt:tryPlace( -- 616
			"ink_enso_fine", -- 616
			"reticle_lock", -- 616
			mx, -- 616
			my, -- 616
			sz, -- 616
			sz, -- 616
			{ -- 616
				color = toColor(PALETTE.rouge), -- 617
				opacity = 0.88, -- 617
				angle = self.time * 38, -- 617
				layer = 5 -- 617
			} -- 617
		) -- 617
		fillRadialGlow( -- 619
			uiGlow, -- 619
			mx, -- 619
			my, -- 619
			16, -- 619
			16, -- 619
			toColor(PALETTE.rouge, 30), -- 619
			Color(182, 58, 56, 0), -- 619
			10 -- 619
		) -- 619
	end -- 619
end -- 555
return ____exports -- 555
