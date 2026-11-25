-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____escort = require("Script.watch.escort") -- 11
local FEAR_MAX = ____escort.FEAR_MAX -- 11
local ____adapter = require("Script.watch.fe.adapter") -- 12
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 12
local ____theme = require("Script.watch.fe.theme") -- 17
local PALETTE = ____theme.PALETTE -- 18
local drawBlossomDot = ____theme.drawBlossomDot -- 19
local drawHairline = ____theme.drawHairline -- 20
local drawSilkKeycap = ____theme.drawSilkKeycap -- 21
local drawSilkVeil = ____theme.drawSilkVeil -- 22
local fillRadialGlow = ____theme.fillRadialGlow -- 23
local themeOf = ____theme.themeOf -- 24
local toColor = ____theme.toColor -- 25
local visualTextWidth = ____theme.visualTextWidth -- 26
____exports.HudRenderer = __TS__Class() -- 29
local HudRenderer = ____exports.HudRenderer -- 29
HudRenderer.name = "HudRenderer" -- 29
function HudRenderer.prototype.____constructor(self) -- 29
	self.ghostHp = 3 -- 31
	self.time = 0 -- 32
end -- 29
function HudRenderer.prototype.reset(self, p) -- 34
	self.ghostHp = p ~= nil and p.hp or 3 -- 35
end -- 34
function HudRenderer.prototype.update(self, dt, p) -- 38
	self.time = self.time + dt -- 39
	if self.ghostHp > p.hp then -- 39
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 41
	else -- 41
		self.ghostHp = p.hp -- 43
	end -- 43
end -- 38
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle) -- 47
	if assistHintsEnabled == nil then -- 47
		assistHintsEnabled = false -- 58
	end -- 58
	if suppressReticle == nil then -- 58
		suppressReticle = false -- 59
	end -- 59
	local w = cam.viewW / uiScale -- 61
	local h = cam.viewH / uiScale -- 62
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 64
	if hudAlpha > 0.05 then -- 64
		if p.childMode then -- 64
			self:drawChildStatus( -- 68
				uiDraw, -- 68
				uiInkDraw, -- 68
				uiArt, -- 68
				texts, -- 68
				p, -- 68
				h, -- 68
				hudAlpha, -- 68
				assistHintsEnabled -- 68
			) -- 68
		else -- 68
			self:drawSoldierStatus( -- 70
				uiDraw, -- 70
				uiInkDraw, -- 70
				uiArt, -- 70
				texts, -- 70
				p, -- 70
				h, -- 70
				hudAlpha, -- 70
				assistHintsEnabled -- 70
			) -- 70
		end -- 70
		self:drawChapterBadge( -- 73
			uiDraw, -- 73
			uiArt, -- 73
			texts, -- 73
			p, -- 73
			w, -- 73
			h, -- 73
			hudAlpha -- 73
		) -- 73
		self:drawContextualObjective( -- 74
			uiDraw, -- 74
			uiInkDraw, -- 74
			uiArt, -- 74
			texts, -- 74
			p, -- 74
			w, -- 74
			h, -- 74
			hudAlpha, -- 74
			assistHintsEnabled -- 74
		) -- 74
		if assistHintsEnabled then -- 74
			local prompt = deriveWorldPrompt(p) -- 77
			if prompt ~= nil then -- 77
				self:drawWorldPrompts( -- 79
					uiDraw, -- 79
					uiInkDraw, -- 79
					uiArt, -- 79
					texts, -- 79
					{prompt}, -- 79
					cam, -- 79
					hudAlpha, -- 79
					uiScale -- 79
				) -- 79
			end -- 79
		end -- 79
		if vfx.deflectFlash > 0.25 then -- 79
			local dx = cam:sx(vfx.deflectX) / uiScale -- 84
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 85
			texts:put( -- 86
				"sm", -- 86
				"掩体挡下", -- 86
				dx, -- 86
				dy, -- 86
				toColor(PALETTE.textBright), -- 86
				0.5, -- 86
				0.5, -- 86
				"Center", -- 86
				2, -- 86
				vfx.deflectFlash, -- 86
				0.1 -- 86
			) -- 86
		end -- 86
	end -- 86
	if not suppressReticle then -- 86
		self:drawReticleOverlay( -- 91
			uiInkDraw, -- 91
			uiArt, -- 91
			uiGlow, -- 91
			p, -- 91
			cam, -- 91
			vfx, -- 91
			letterboxFrac, -- 91
			uiScale -- 91
		) -- 91
	end -- 91
end -- 47
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale) -- 96
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 96
		self:drawReticle( -- 108
			uiInkDraw, -- 108
			uiArt, -- 108
			uiGlow, -- 108
			p, -- 108
			cam, -- 108
			vfx, -- 108
			uiScale -- 108
		) -- 108
	end -- 108
end -- 96
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 112
	local bx = 28 -- 122
	local by = h - 72 -- 123
	local lowHp = p.hp <= 1 -- 124
	drawSilkVeil( -- 127
		uiDraw, -- 127
		uiArt, -- 127
		"hud_soldier_veil", -- 127
		bx + 150, -- 127
		by + 24, -- 127
		340, -- 127
		56, -- 127
		PALETTE.inkWash, -- 127
		0.62 * alpha, -- 127
		-1 -- 127
	) -- 127
	texts:put( -- 130
		"md", -- 130
		"戍", -- 130
		bx + 16, -- 130
		by + 25, -- 130
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 130
		0.5, -- 130
		0.5, -- 130
		"Center", -- 130
		0, -- 130
		alpha, -- 130
		0.1 -- 130
	) -- 130
	uiInkDraw:drawSegment( -- 131
		Vec2(bx + 32, by + 9), -- 131
		Vec2(bx + 32, by + 40), -- 131
		0.8, -- 131
		toColor(PALETTE.silkDim, 130 * alpha) -- 131
	) -- 131
	texts:put( -- 133
		"xs", -- 133
		"周戍 · 体力", -- 133
		bx + 44, -- 133
		by + 36, -- 133
		toColor(PALETTE.textMid), -- 133
		0, -- 133
		0.5, -- 133
		"Left", -- 133
		1.4, -- 133
		alpha, -- 133
		0.08 -- 133
	) -- 133
	local segCount = math.max(1, p.maxHp) -- 136
	local barX = bx + 44 -- 137
	local barY = by + 16 -- 138
	local segW = 54 -- 139
	local segH = 9 -- 140
	local gap = 8 -- 141
	local i = 0 -- 143
	do -- 143
		i = 0 -- 144
		while i < segCount do -- 144
			local sx = barX + i * (segW + gap) -- 145
			local scx = sx + segW * 0.5 -- 146
			if not uiArt:tryPlace( -- 146
				"ink_bamboo_slot", -- 147
				"hp_slot_" .. tostring(i), -- 147
				scx, -- 147
				barY, -- 147
				segW, -- 147
				segH, -- 147
				{ -- 147
					color = toColor(PALETTE.silkDim), -- 148
					opacity = 0.72 * alpha, -- 148
					layer = 1 -- 148
				} -- 148
			) then -- 148
				uiInkDraw:drawRect( -- 150
					Rect(sx, barY - 3, segW, 6), -- 150
					Color(0, 0, 0, 0), -- 150
					0.8, -- 150
					toColor(PALETTE.silkDim, 145 * alpha) -- 150
				) -- 150
			end -- 150
			if self.ghostHp > i and self.ghostHp > p.hp then -- 150
				local frac = math.min(1, self.ghostHp - i) -- 153
				uiInkDraw:drawRect( -- 154
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 154
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 154
				) -- 154
			end -- 154
			if p.hp > i then -- 154
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 157
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 158
				if not uiArt:tryPlace( -- 158
					"ink_bamboo_slip", -- 159
					"hp_fill_" .. tostring(i), -- 159
					scx, -- 159
					barY, -- 159
					segW, -- 159
					segH, -- 159
					{ -- 159
						color = toColor(fillCol), -- 160
						opacity = 0.94 * alpha * pulse, -- 160
						layer = 2 -- 160
					} -- 160
				) then -- 160
					uiInkDraw:drawRect( -- 162
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 162
						toColor(fillCol, 230 * alpha * pulse) -- 162
					) -- 162
				end -- 162
			end -- 162
			i = i + 1 -- 144
		end -- 144
	end -- 144
	local covX = barX + segCount * (segW + gap) + 6 -- 168
	local hasAliveEnemy = false -- 169
	do -- 169
		i = 0 -- 170
		while i < #p.enemies do -- 170
			if p.enemies[i + 1].alive then -- 170
				hasAliveEnemy = true -- 172
				break -- 173
			end -- 173
			i = i + 1 -- 170
		end -- 170
	end -- 170
	if p.coverHug then -- 170
		if hasAliveEnemy and not p.coverBlocking then -- 170
			uiInkDraw:drawRect( -- 178
				Rect(covX, barY - 9, 72, 18), -- 178
				toColor(PALETTE.inkWarm, 185 * alpha), -- 178
				0.8, -- 178
				toColor(PALETTE.amber, 200 * alpha) -- 178
			) -- 178
			texts:put( -- 179
				"xs", -- 179
				"背向掩体", -- 179
				covX + 36, -- 179
				barY, -- 179
				toColor(PALETTE.amberCore), -- 179
				0.5, -- 179
				0.5, -- 179
				"Center", -- 179
				0.6, -- 179
				alpha, -- 179
				0 -- 179
			) -- 179
		else -- 179
			uiInkDraw:drawRect( -- 181
				Rect(covX, barY - 9, 54, 18), -- 181
				toColor(PALETTE.cyanDim, 165 * alpha), -- 181
				0.8, -- 181
				toColor(PALETTE.cyanCore, 180 * alpha) -- 181
			) -- 181
			texts:put( -- 182
				"xs", -- 182
				"掩体中", -- 182
				covX + 27, -- 182
				barY, -- 182
				toColor(PALETTE.textBright), -- 182
				0.5, -- 182
				0.5, -- 182
				"Center", -- 182
				0.6, -- 182
				alpha, -- 182
				0 -- 182
			) -- 182
		end -- 182
	elseif p.coverNear then -- 182
		uiInkDraw:drawRect( -- 185
			Rect(covX, barY - 9, 54, 18), -- 185
			Color( -- 185
				14, -- 185
				17, -- 185
				25, -- 185
				math.floor(150 * alpha + 0.5) -- 185
			), -- 185
			0.8, -- 185
			toColor(PALETTE.silkLine, 165 * alpha) -- 185
		) -- 185
		texts:put( -- 186
			"xs", -- 186
			"可贴靠", -- 186
			covX + 27, -- 186
			barY, -- 186
			toColor(PALETTE.textMid), -- 186
			0.5, -- 186
			0.5, -- 186
			"Center", -- 186
			0.6, -- 186
			alpha, -- 186
			0.08 -- 186
		) -- 186
	end -- 186
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 186
		local subY = by - 24 -- 191
		local frozen = p.escort.state == "frozen" -- 192
		local calming = p.escort.state == "calming" -- 193
		drawSilkVeil( -- 195
			uiDraw, -- 195
			uiArt, -- 195
			"hud_fear_veil", -- 195
			bx + 126, -- 195
			subY + 6, -- 195
			260, -- 195
			30, -- 195
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 195
			0.64 * alpha, -- 195
			-1 -- 195
		) -- 195
		texts:put( -- 196
			"xs", -- 196
			"小满 · 惊惧", -- 196
			bx + 14, -- 196
			subY + 6, -- 196
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 196
			0, -- 196
			0.5, -- 196
			"Left", -- 196
			1, -- 196
			alpha, -- 196
			0.08 -- 196
		) -- 196
		local k = 0 -- 198
		do -- 198
			k = 0 -- 199
			while k < FEAR_MAX do -- 199
				local dx = bx + 114 + k * 20 -- 200
				local dy = subY + 6 -- 201
				local lit = k < p.escort.fear -- 202
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 203
				uiArt:tryPlace( -- 204
					"ink_enso_fine", -- 204
					"fear_ring_" .. tostring(k), -- 204
					dx, -- 204
					dy, -- 204
					14, -- 204
					14, -- 204
					{ -- 204
						color = toColor(lit and dc or PALETTE.silkLine), -- 205
						opacity = (lit and 0.92 or 0.64) * alpha, -- 205
						layer = 2 -- 205
					} -- 205
				) -- 205
				if lit then -- 205
					drawBlossomDot( -- 208
						uiInkDraw, -- 208
						uiArt, -- 208
						"fear_dot_" .. tostring(k), -- 208
						dx, -- 208
						dy, -- 208
						10, -- 208
						dc, -- 208
						0.96 * alpha, -- 208
						3 -- 208
					) -- 208
				end -- 208
				k = k + 1 -- 199
			end -- 199
		end -- 199
		if frozen then -- 199
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 213
			if assistHintsEnabled then -- 213
				drawSilkKeycap( -- 215
					uiInkDraw, -- 215
					texts, -- 215
					bx + 170, -- 215
					subY - 5, -- 215
					22, -- 215
					22, -- 215
					"E", -- 215
					PALETTE.rouge, -- 215
					alpha * pulse, -- 215
					true -- 215
				) -- 215
				texts:put( -- 216
					"xs", -- 216
					"轻敲安抚", -- 216
					bx + 198, -- 216
					subY + 6, -- 216
					toColor(PALETTE.crimsonCore), -- 216
					0, -- 216
					0.5, -- 216
					"Left", -- 216
					0.8, -- 216
					alpha * pulse, -- 216
					0.08 -- 216
				) -- 216
			else -- 216
				texts:put( -- 218
					"xs", -- 218
					"受惊停步", -- 218
					bx + 172, -- 218
					subY + 6, -- 218
					toColor(PALETTE.crimsonCore), -- 218
					0, -- 218
					0.5, -- 218
					"Left", -- 218
					0.8, -- 218
					alpha * pulse, -- 218
					0.08 -- 218
				) -- 218
			end -- 218
		elseif calming then -- 218
			texts:put( -- 221
				"xs", -- 221
				"轻敲安抚中", -- 221
				bx + 172, -- 221
				subY + 6, -- 221
				toColor(PALETTE.emerald), -- 221
				0, -- 221
				0.5, -- 221
				"Left", -- 221
				0.8, -- 221
				alpha, -- 221
				0.08 -- 221
			) -- 221
		end -- 221
	end -- 221
end -- 112
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 226
	local bx = 28 -- 236
	local by = h - 68 -- 237
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 238
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 239
	drawSilkVeil( -- 241
		uiDraw, -- 241
		uiArt, -- 241
		"hud_child_veil", -- 241
		bx + 144, -- 241
		by + 22, -- 241
		316, -- 241
		48, -- 241
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 241
		0.58 * alpha, -- 241
		-1 -- 241
	) -- 241
	texts:put( -- 242
		"md", -- 242
		alert and "危" or "满", -- 242
		bx + 16, -- 242
		by + 22, -- 242
		toColor(leadCol), -- 242
		0.5, -- 242
		0.5, -- 242
		"Center", -- 242
		0, -- 242
		alpha, -- 242
		0.1 -- 242
	) -- 242
	uiInkDraw:drawSegment( -- 243
		Vec2(bx + 32, by + 7), -- 243
		Vec2(bx + 32, by + 37), -- 243
		0.8, -- 243
		toColor(PALETTE.silkDim, 130 * alpha) -- 243
	) -- 243
	texts:put( -- 245
		"xs", -- 245
		"小满 · 潜行", -- 245
		bx + 44, -- 245
		by + 33, -- 245
		toColor(PALETTE.amberCore), -- 245
		0, -- 245
		0.5, -- 245
		"Left", -- 245
		1.4, -- 245
		alpha, -- 245
		0.08 -- 245
	) -- 245
	local posture = "轻步前行 · 保持隐蔽" -- 247
	local col = PALETTE.textMid -- 248
	if alert then -- 248
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 250
		col = PALETTE.crimsonCore -- 251
	elseif p.player.crouch then -- 251
		posture = "低姿伏行 · 匿迹于影" -- 253
		col = PALETTE.emerald -- 254
	elseif p.hasBottle then -- 254
		posture = assistHintsEnabled and "手持陶瓶 · 按住 [F] 瞄投" or "手持陶瓶" -- 256
		col = PALETTE.amberCore -- 257
	end -- 257
	texts:put( -- 259
		"xs", -- 259
		posture, -- 259
		bx + 44, -- 259
		by + 12, -- 259
		toColor(col), -- 259
		0, -- 259
		0.5, -- 259
		"Left", -- 259
		0.6, -- 259
		alpha, -- 259
		0.08 -- 259
	) -- 259
end -- 226
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 262
	local theme = themeOf(p.room.key) -- 271
	local rx = w - 32 -- 272
	local cy = h - 44 -- 273
	drawSilkVeil( -- 275
		uiDraw, -- 275
		uiArt, -- 275
		"hud_chap_veil", -- 275
		rx - 82, -- 275
		cy, -- 275
		240, -- 275
		44, -- 275
		PALETTE.inkWash, -- 275
		0.44 * alpha, -- 275
		-1 -- 275
	) -- 275
	texts:put( -- 276
		"xs", -- 276
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 276
		rx, -- 276
		cy + 9, -- 276
		toColor(PALETTE.textBright), -- 276
		1, -- 276
		0.5, -- 276
		"Right", -- 276
		1.2, -- 276
		alpha, -- 276
		0.08 -- 276
	) -- 276
	texts:put( -- 277
		"xs", -- 277
		"Esc 暂歇", -- 277
		rx, -- 277
		cy - 11, -- 277
		toColor(PALETTE.textDim), -- 277
		1, -- 277
		0.5, -- 277
		"Right", -- 277
		1, -- 277
		0.78 * alpha, -- 277
		0.08 -- 277
	) -- 277
end -- 262
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled) -- 280
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 280
		local g = p.room.story.gate -- 293
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 293
			local bw = 400 -- 295
			local cx = w * 0.5 -- 296
			local by = h - 64 -- 297
			local ratio = math.max( -- 298
				0, -- 298
				math.min( -- 298
					1, -- 298
					p.gateTick / math.max(1, g.holdTicks) -- 298
				) -- 298
			) -- 298
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 299
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 300
			drawSilkVeil( -- 302
				uiDraw, -- 302
				uiArt, -- 302
				"hud_gate_veil", -- 302
				cx, -- 302
				by + 18, -- 302
				bw + 90, -- 302
				48, -- 302
				PALETTE.inkWash, -- 302
				0.76 * alpha, -- 302
				-1 -- 302
			) -- 302
			drawHairline( -- 303
				uiInkDraw, -- 303
				uiArt, -- 303
				"hud_gate_top", -- 303
				cx, -- 303
				by + 39, -- 303
				bw - 20, -- 303
				PALETTE.rougeSoft, -- 303
				0.55 * alpha, -- 303
				false, -- 303
				2 -- 303
			) -- 303
			local idleNeedConfirmLabel = assistHintsEnabled and "绞盘待命 · 按 [E] 重新守门" or "绞盘待命" -- 305
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 306
			texts:put( -- 309
				"xs", -- 309
				label, -- 309
				cx, -- 309
				by + 26, -- 309
				toColor(PALETTE.textBright), -- 309
				0.5, -- 309
				0.5, -- 309
				"Center", -- 309
				1.8, -- 309
				alpha, -- 309
				0.08 -- 309
			) -- 309
			local pbw = bw - 80 -- 312
			local pbx = cx - pbw * 0.5 -- 313
			local pby = by + 9 -- 314
			uiInkDraw:drawSegment( -- 315
				Vec2(pbx, pby), -- 315
				Vec2(pbx + pbw, pby), -- 315
				1.4, -- 315
				toColor(PALETTE.silkDim, 115 * alpha) -- 315
			) -- 315
			if ratio > 0.002 then -- 315
				uiInkDraw:drawSegment( -- 317
					Vec2(pbx, pby), -- 317
					Vec2(pbx + pbw * ratio, pby), -- 317
					2.8, -- 317
					toColor(PALETTE.rouge, 230 * alpha) -- 317
				) -- 317
				uiInkDraw:drawSegment( -- 318
					Vec2(pbx, pby), -- 318
					Vec2(pbx + pbw * ratio, pby), -- 318
					1, -- 318
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 318
				) -- 318
			end -- 318
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 320
			local k = 0 -- 321
			do -- 321
				k = 0 -- 322
				while k < #waves do -- 322
					local wx = pbx + pbw * waves[k + 1] -- 323
					local passed = p.gateSpawned > k -- 324
					if passed then -- 324
						drawBlossomDot( -- 326
							uiInkDraw, -- 326
							uiArt, -- 326
							"gate_wave_" .. tostring(k), -- 326
							wx, -- 326
							pby, -- 326
							10, -- 326
							PALETTE.moonPale, -- 326
							0.92 * alpha, -- 326
							3 -- 326
						) -- 326
					else -- 326
						uiArt:tryPlace( -- 328
							"ink_enso_fine", -- 328
							"gate_wave_" .. tostring(k), -- 328
							wx, -- 328
							pby, -- 328
							11, -- 328
							11, -- 328
							{ -- 328
								color = toColor(PALETTE.rouge), -- 329
								opacity = 0.84 * alpha, -- 329
								layer = 3 -- 329
							} -- 329
						) -- 329
					end -- 329
					k = k + 1 -- 322
				end -- 322
			end -- 322
		end -- 322
		return -- 334
	end -- 334
	if not assistHintsEnabled then -- 334
		return -- 339
	end -- 339
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 339
		local cx = w * 0.5 -- 342
		local by = h - 44 -- 343
		local step1 = p.cartDocked -- 344
		local ____temp_0 -- 345
		if p.room.key == "checkpoint" then -- 345
			____temp_0 = p.gateOpen -- 345
		else -- 345
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 345
		end -- 345
		local step2 = ____temp_0 -- 345
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 346
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 347
		drawSilkVeil( -- 349
			uiDraw, -- 349
			uiArt, -- 349
			"hud_obj_veil", -- 349
			cx, -- 349
			by, -- 349
			380, -- 349
			34, -- 349
			PALETTE.inkWash, -- 349
			0.58 * alpha, -- 349
			-1 -- 349
		) -- 349
		local x1 = cx - 134 -- 351
		if step1 then -- 351
			drawBlossomDot( -- 353
				uiInkDraw, -- 353
				uiArt, -- 353
				"obj_m1", -- 353
				x1, -- 353
				by, -- 353
				11, -- 353
				PALETTE.emerald, -- 353
				0.94 * alpha, -- 353
				3 -- 353
			) -- 353
		else -- 353
			uiArt:tryPlace( -- 355
				"ink_enso_fine", -- 355
				"obj_m1", -- 355
				x1, -- 355
				by, -- 355
				11, -- 355
				11, -- 355
				{ -- 355
					color = toColor(PALETTE.silkLine), -- 355
					opacity = 0.72 * alpha, -- 355
					layer = 3 -- 355
				} -- 355
			) -- 355
		end -- 355
		texts:put( -- 357
			"xs", -- 357
			t1, -- 357
			x1 + 13, -- 357
			by, -- 357
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 357
			0, -- 357
			0.5, -- 357
			"Left", -- 357
			1, -- 357
			alpha, -- 357
			0.08 -- 357
		) -- 357
		local x2 = cx + 18 -- 359
		if step2 then -- 359
			drawBlossomDot( -- 361
				uiInkDraw, -- 361
				uiArt, -- 361
				"obj_m2", -- 361
				x2, -- 361
				by, -- 361
				11, -- 361
				PALETTE.emerald, -- 361
				0.94 * alpha, -- 361
				3 -- 361
			) -- 361
		else -- 361
			uiArt:tryPlace( -- 363
				"ink_enso_fine", -- 363
				"obj_m2", -- 363
				x2, -- 363
				by, -- 363
				11, -- 363
				11, -- 363
				{ -- 363
					color = toColor(PALETTE.silkDim), -- 363
					opacity = 0.62 * alpha, -- 363
					layer = 3 -- 363
				} -- 363
			) -- 363
		end -- 363
		texts:put( -- 365
			"xs", -- 365
			t2, -- 365
			x2 + 13, -- 365
			by, -- 365
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 365
			0, -- 365
			0.5, -- 365
			"Left", -- 365
			1, -- 365
			alpha, -- 365
			0.08 -- 365
		) -- 365
	end -- 365
end -- 280
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 369
	local bob = math.sin(self.time * 3.4) * 2.8 -- 379
	local viewW = cam.viewW / uiScale -- 380
	local viewH = cam.viewH / uiScale -- 381
	local i = 0 -- 382
	do -- 382
		i = 0 -- 383
		while i < #prompts do -- 383
			local pr = prompts[i + 1] -- 384
			local keyW = math.max( -- 385
				24, -- 385
				visualTextWidth(pr.keyTag, 15) + 16 -- 385
			) -- 385
			local labelW = visualTextWidth(pr.label, 15) -- 386
			local pillW = keyW + labelW + 24 -- 387
			local padX = math.max(115, pillW * 0.5 + 24) -- 388
			local sx = math.max( -- 389
				padX, -- 389
				math.min( -- 389
					viewW - padX, -- 389
					cam:sx(pr.x) / uiScale -- 389
				) -- 389
			) -- 389
			local sy = math.max( -- 390
				96, -- 390
				math.min( -- 390
					viewH - 110, -- 390
					cam:sy(pr.y) / uiScale + bob -- 390
				) -- 390
			) -- 390
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 391
			uiInkDraw:drawSegment( -- 394
				Vec2(sx, sy - 14), -- 394
				Vec2(sx, sy - 27), -- 394
				0.8, -- 394
				toColor(accent, 135 * alpha) -- 394
			) -- 394
			drawBlossomDot( -- 395
				uiInkDraw, -- 395
				uiArt, -- 395
				"wp_anchor_" .. tostring(i), -- 395
				sx, -- 395
				sy - 28, -- 395
				7, -- 395
				accent, -- 395
				0.85 * alpha, -- 395
				3 -- 395
			) -- 395
			local px = sx - pillW * 0.5 -- 397
			local py = sy - 12 -- 398
			drawSilkVeil( -- 400
				uiDraw, -- 400
				uiArt, -- 400
				"wp_bg_" .. tostring(i), -- 400
				sx, -- 400
				py + 12, -- 400
				pillW + 40, -- 400
				32, -- 400
				PALETTE.inkWash, -- 400
				0.78 * alpha, -- 400
				0 -- 400
			) -- 400
			drawHairline( -- 401
				uiInkDraw, -- 401
				uiArt, -- 401
				"wp_line_" .. tostring(i), -- 401
				sx, -- 401
				py + 24, -- 401
				pillW + 4, -- 401
				accent, -- 401
				0.45 * alpha, -- 401
				false, -- 401
				2 -- 401
			) -- 401
			drawSilkKeycap( -- 402
				uiInkDraw, -- 402
				texts, -- 402
				px + 2, -- 402
				py + 2, -- 402
				keyW, -- 402
				20, -- 402
				pr.keyTag, -- 402
				accent, -- 402
				alpha, -- 402
				pr.urgent -- 402
			) -- 402
			texts:put( -- 403
				"xs", -- 403
				pr.label, -- 403
				px + keyW + 12, -- 403
				py + 12, -- 403
				toColor(PALETTE.textBright), -- 403
				0, -- 403
				0.5, -- 403
				"Left", -- 403
				0.8, -- 403
				alpha, -- 403
				0.08 -- 403
			) -- 403
			i = i + 1 -- 383
		end -- 383
	end -- 383
end -- 369
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 407
	local mx = p.aimX / uiScale -- 416
	local my = p.aimY / uiScale -- 417
	if mx <= 0 and my <= 0 then -- 417
		return -- 419
	end -- 419
	if p.childMode then -- 419
		local aiming = p.room.key == "village" and p.hasBottle -- 423
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 424
		uiInkDraw:drawDot( -- 425
			Vec2(mx, my), -- 425
			aiming and 2 or 1.6, -- 425
			toColor(col, aiming and 215 or 120) -- 425
		) -- 425
		if aiming then -- 425
			local sz = p.aimHold > 0 and 32 or 24 -- 427
			uiArt:tryPlace( -- 428
				"ink_enso_fine", -- 428
				"reticle_child", -- 428
				mx, -- 428
				my, -- 428
				sz, -- 428
				sz, -- 428
				{ -- 428
					color = toColor(PALETTE.amberCore), -- 429
					opacity = 0.82, -- 429
					angle = self.time * 24, -- 429
					layer = 5 -- 429
				} -- 429
			) -- 429
		end -- 429
		return -- 432
	end -- 432
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 435
	local onEnemy = false -- 436
	local i = 0 -- 437
	do -- 437
		i = 0 -- 438
		while i < #p.enemies do -- 438
			local e = p.enemies[i + 1] -- 439
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 439
				onEnemy = true -- 441
			end -- 441
			i = i + 1 -- 438
		end -- 438
	end -- 438
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 445
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 446
	local arm = onEnemy and 8.5 or 9.5 -- 447
	local bg = Color(10, 12, 18, 160) -- 448
	uiInkDraw:drawSegment( -- 450
		Vec2(mx - gap - arm, my), -- 450
		Vec2(mx - gap, my), -- 450
		2.1, -- 450
		bg -- 450
	) -- 450
	uiInkDraw:drawSegment( -- 451
		Vec2(mx + gap, my), -- 451
		Vec2(mx + gap + arm, my), -- 451
		2.1, -- 451
		bg -- 451
	) -- 451
	uiInkDraw:drawSegment( -- 452
		Vec2(mx, my - gap - arm), -- 452
		Vec2(mx, my - gap), -- 452
		2.1, -- 452
		bg -- 452
	) -- 452
	uiInkDraw:drawSegment( -- 453
		Vec2(mx, my + gap), -- 453
		Vec2(mx, my + gap + arm), -- 453
		2.1, -- 453
		bg -- 453
	) -- 453
	uiInkDraw:drawSegment( -- 455
		Vec2(mx - gap - arm, my), -- 455
		Vec2(mx - gap, my), -- 455
		1.1, -- 455
		toColor(col, 230) -- 455
	) -- 455
	uiInkDraw:drawSegment( -- 456
		Vec2(mx + gap, my), -- 456
		Vec2(mx + gap + arm, my), -- 456
		1.1, -- 456
		toColor(col, 230) -- 456
	) -- 456
	uiInkDraw:drawSegment( -- 457
		Vec2(mx, my - gap - arm), -- 457
		Vec2(mx, my - gap), -- 457
		1.1, -- 457
		toColor(col, 230) -- 457
	) -- 457
	uiInkDraw:drawSegment( -- 458
		Vec2(mx, my + gap), -- 458
		Vec2(mx, my + gap + arm), -- 458
		1.1, -- 458
		toColor(col, 230) -- 458
	) -- 458
	uiInkDraw:drawDot( -- 459
		Vec2(mx, my), -- 459
		1.8, -- 459
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 459
	) -- 459
	if onEnemy then -- 459
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 462
		uiArt:tryPlace( -- 463
			"ink_enso_fine", -- 463
			"reticle_lock", -- 463
			mx, -- 463
			my, -- 463
			sz, -- 463
			sz, -- 463
			{ -- 463
				color = toColor(PALETTE.rouge), -- 464
				opacity = 0.88, -- 464
				angle = self.time * 38, -- 464
				layer = 5 -- 464
			} -- 464
		) -- 464
		fillRadialGlow( -- 466
			uiGlow, -- 466
			mx, -- 466
			my, -- 466
			16, -- 466
			16, -- 466
			toColor(PALETTE.rouge, 30), -- 466
			Color(182, 58, 56, 0), -- 466
			10 -- 466
		) -- 466
	end -- 466
end -- 407
return ____exports -- 407