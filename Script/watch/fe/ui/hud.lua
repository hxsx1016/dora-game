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
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale) -- 47
	local w = cam.viewW / uiScale -- 59
	local h = cam.viewH / uiScale -- 60
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 62
	if hudAlpha > 0.05 then -- 62
		if p.childMode then -- 62
			self:drawChildStatus( -- 66
				uiDraw, -- 66
				uiInkDraw, -- 66
				uiArt, -- 66
				texts, -- 66
				p, -- 66
				h, -- 66
				hudAlpha -- 66
			) -- 66
		else -- 66
			self:drawSoldierStatus( -- 68
				uiDraw, -- 68
				uiInkDraw, -- 68
				uiArt, -- 68
				texts, -- 68
				p, -- 68
				h, -- 68
				hudAlpha -- 68
			) -- 68
		end -- 68
		self:drawChapterBadge( -- 71
			uiDraw, -- 71
			uiArt, -- 71
			texts, -- 71
			p, -- 71
			w, -- 71
			h, -- 71
			hudAlpha -- 71
		) -- 71
		self:drawContextualObjective( -- 72
			uiDraw, -- 72
			uiInkDraw, -- 72
			uiArt, -- 72
			texts, -- 72
			p, -- 72
			w, -- 72
			h, -- 72
			hudAlpha -- 72
		) -- 72
		local prompt = deriveWorldPrompt(p) -- 74
		if prompt ~= nil then -- 74
			self:drawWorldPrompts( -- 76
				uiDraw, -- 76
				uiInkDraw, -- 76
				uiArt, -- 76
				texts, -- 76
				{prompt}, -- 76
				cam, -- 76
				hudAlpha, -- 76
				uiScale -- 76
			) -- 76
		end -- 76
		if vfx.deflectFlash > 0.25 then -- 76
			local dx = cam:sx(vfx.deflectX) / uiScale -- 80
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 81
			texts:put( -- 82
				"sm", -- 82
				"掩体挡下", -- 82
				dx, -- 82
				dy, -- 82
				toColor(PALETTE.textBright), -- 82
				0.5, -- 82
				0.5, -- 82
				"Center", -- 82
				2, -- 82
				vfx.deflectFlash, -- 82
				0.1 -- 82
			) -- 82
		end -- 82
	end -- 82
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 82
		self:drawReticle( -- 88
			uiInkDraw, -- 88
			uiArt, -- 88
			uiGlow, -- 88
			p, -- 88
			cam, -- 88
			vfx, -- 88
			uiScale -- 88
		) -- 88
	end -- 88
end -- 47
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 92
	local bx = 28 -- 101
	local by = h - 72 -- 102
	local lowHp = p.hp <= 1 -- 103
	drawSilkVeil( -- 106
		uiDraw, -- 106
		uiArt, -- 106
		"hud_soldier_veil", -- 106
		bx + 150, -- 106
		by + 24, -- 106
		340, -- 106
		56, -- 106
		PALETTE.inkWash, -- 106
		0.62 * alpha, -- 106
		-1 -- 106
	) -- 106
	texts:put( -- 109
		"md", -- 109
		"戍", -- 109
		bx + 16, -- 109
		by + 25, -- 109
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 109
		0.5, -- 109
		0.5, -- 109
		"Center", -- 109
		0, -- 109
		alpha, -- 109
		0.1 -- 109
	) -- 109
	uiInkDraw:drawSegment( -- 110
		Vec2(bx + 32, by + 9), -- 110
		Vec2(bx + 32, by + 40), -- 110
		0.8, -- 110
		toColor(PALETTE.silkDim, 130 * alpha) -- 110
	) -- 110
	texts:put( -- 112
		"xs", -- 112
		"周戍 · 体力", -- 112
		bx + 44, -- 112
		by + 36, -- 112
		toColor(PALETTE.textMid), -- 112
		0, -- 112
		0.5, -- 112
		"Left", -- 112
		1.4, -- 112
		alpha, -- 112
		0.08 -- 112
	) -- 112
	local segCount = math.max(1, p.maxHp) -- 115
	local barX = bx + 44 -- 116
	local barY = by + 16 -- 117
	local segW = 54 -- 118
	local segH = 9 -- 119
	local gap = 8 -- 120
	local i = 0 -- 122
	do -- 122
		i = 0 -- 123
		while i < segCount do -- 123
			local sx = barX + i * (segW + gap) -- 124
			local scx = sx + segW * 0.5 -- 125
			if not uiArt:tryPlace( -- 125
				"ink_bamboo_slot", -- 126
				"hp_slot_" .. tostring(i), -- 126
				scx, -- 126
				barY, -- 126
				segW, -- 126
				segH, -- 126
				{ -- 126
					color = toColor(PALETTE.silkDim), -- 127
					opacity = 0.72 * alpha, -- 127
					layer = 1 -- 127
				} -- 127
			) then -- 127
				uiInkDraw:drawRect( -- 129
					Rect(sx, barY - 3, segW, 6), -- 129
					Color(0, 0, 0, 0), -- 129
					0.8, -- 129
					toColor(PALETTE.silkDim, 145 * alpha) -- 129
				) -- 129
			end -- 129
			if self.ghostHp > i and self.ghostHp > p.hp then -- 129
				local frac = math.min(1, self.ghostHp - i) -- 132
				uiInkDraw:drawRect( -- 133
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 133
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 133
				) -- 133
			end -- 133
			if p.hp > i then -- 133
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 136
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 137
				if not uiArt:tryPlace( -- 137
					"ink_bamboo_slip", -- 138
					"hp_fill_" .. tostring(i), -- 138
					scx, -- 138
					barY, -- 138
					segW, -- 138
					segH, -- 138
					{ -- 138
						color = toColor(fillCol), -- 139
						opacity = 0.94 * alpha * pulse, -- 139
						layer = 2 -- 139
					} -- 139
				) then -- 139
					uiInkDraw:drawRect( -- 141
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 141
						toColor(fillCol, 230 * alpha * pulse) -- 141
					) -- 141
				end -- 141
			end -- 141
			i = i + 1 -- 123
		end -- 123
	end -- 123
	local covX = barX + segCount * (segW + gap) + 6 -- 147
	local hasAliveEnemy = false -- 148
	do -- 148
		i = 0 -- 149
		while i < #p.enemies do -- 149
			if p.enemies[i + 1].alive then -- 149
				hasAliveEnemy = true -- 151
				break -- 152
			end -- 152
			i = i + 1 -- 149
		end -- 149
	end -- 149
	if p.coverHug then -- 149
		if hasAliveEnemy and not p.coverBlocking then -- 149
			uiInkDraw:drawRect( -- 157
				Rect(covX, barY - 9, 72, 18), -- 157
				toColor(PALETTE.inkWarm, 185 * alpha), -- 157
				0.8, -- 157
				toColor(PALETTE.amber, 200 * alpha) -- 157
			) -- 157
			texts:put( -- 158
				"xs", -- 158
				"背向掩体", -- 158
				covX + 36, -- 158
				barY, -- 158
				toColor(PALETTE.amberCore), -- 158
				0.5, -- 158
				0.5, -- 158
				"Center", -- 158
				0.6, -- 158
				alpha, -- 158
				0 -- 158
			) -- 158
		else -- 158
			uiInkDraw:drawRect( -- 160
				Rect(covX, barY - 9, 54, 18), -- 160
				toColor(PALETTE.cyanDim, 165 * alpha), -- 160
				0.8, -- 160
				toColor(PALETTE.cyanCore, 180 * alpha) -- 160
			) -- 160
			texts:put( -- 161
				"xs", -- 161
				"掩体中", -- 161
				covX + 27, -- 161
				barY, -- 161
				toColor(PALETTE.textBright), -- 161
				0.5, -- 161
				0.5, -- 161
				"Center", -- 161
				0.6, -- 161
				alpha, -- 161
				0 -- 161
			) -- 161
		end -- 161
	elseif p.coverNear then -- 161
		uiInkDraw:drawRect( -- 164
			Rect(covX, barY - 9, 54, 18), -- 164
			Color( -- 164
				14, -- 164
				17, -- 164
				25, -- 164
				math.floor(150 * alpha + 0.5) -- 164
			), -- 164
			0.8, -- 164
			toColor(PALETTE.silkLine, 165 * alpha) -- 164
		) -- 164
		texts:put( -- 165
			"xs", -- 165
			"可贴靠", -- 165
			covX + 27, -- 165
			barY, -- 165
			toColor(PALETTE.textMid), -- 165
			0.5, -- 165
			0.5, -- 165
			"Center", -- 165
			0.6, -- 165
			alpha, -- 165
			0.08 -- 165
		) -- 165
	end -- 165
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 165
		local subY = by - 24 -- 170
		local frozen = p.escort.state == "frozen" -- 171
		local calming = p.escort.state == "calming" -- 172
		drawSilkVeil( -- 174
			uiDraw, -- 174
			uiArt, -- 174
			"hud_fear_veil", -- 174
			bx + 126, -- 174
			subY + 6, -- 174
			260, -- 174
			30, -- 174
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 174
			0.64 * alpha, -- 174
			-1 -- 174
		) -- 174
		texts:put( -- 175
			"xs", -- 175
			"小满 · 惊惧", -- 175
			bx + 14, -- 175
			subY + 6, -- 175
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 175
			0, -- 175
			0.5, -- 175
			"Left", -- 175
			1, -- 175
			alpha, -- 175
			0.08 -- 175
		) -- 175
		local k = 0 -- 177
		do -- 177
			k = 0 -- 178
			while k < FEAR_MAX do -- 178
				local dx = bx + 114 + k * 20 -- 179
				local dy = subY + 6 -- 180
				local lit = k < p.escort.fear -- 181
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 182
				uiArt:tryPlace( -- 183
					"ink_enso_fine", -- 183
					"fear_ring_" .. tostring(k), -- 183
					dx, -- 183
					dy, -- 183
					14, -- 183
					14, -- 183
					{ -- 183
						color = toColor(lit and dc or PALETTE.silkLine), -- 184
						opacity = (lit and 0.92 or 0.64) * alpha, -- 184
						layer = 2 -- 184
					} -- 184
				) -- 184
				if lit then -- 184
					drawBlossomDot( -- 187
						uiInkDraw, -- 187
						uiArt, -- 187
						"fear_dot_" .. tostring(k), -- 187
						dx, -- 187
						dy, -- 187
						10, -- 187
						dc, -- 187
						0.96 * alpha, -- 187
						3 -- 187
					) -- 187
				end -- 187
				k = k + 1 -- 178
			end -- 178
		end -- 178
		if frozen then -- 178
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 192
			drawSilkKeycap( -- 193
				uiInkDraw, -- 193
				texts, -- 193
				bx + 170, -- 193
				subY - 5, -- 193
				22, -- 193
				22, -- 193
				"E", -- 193
				PALETTE.rouge, -- 193
				alpha * pulse, -- 193
				true -- 193
			) -- 193
			texts:put( -- 194
				"xs", -- 194
				"轻敲安抚", -- 194
				bx + 198, -- 194
				subY + 6, -- 194
				toColor(PALETTE.crimsonCore), -- 194
				0, -- 194
				0.5, -- 194
				"Left", -- 194
				0.8, -- 194
				alpha * pulse, -- 194
				0.08 -- 194
			) -- 194
		elseif calming then -- 194
			texts:put( -- 196
				"xs", -- 196
				"轻敲安抚中", -- 196
				bx + 172, -- 196
				subY + 6, -- 196
				toColor(PALETTE.emerald), -- 196
				0, -- 196
				0.5, -- 196
				"Left", -- 196
				0.8, -- 196
				alpha, -- 196
				0.08 -- 196
			) -- 196
		end -- 196
	end -- 196
end -- 92
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 201
	local bx = 28 -- 210
	local by = h - 68 -- 211
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 212
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 213
	drawSilkVeil( -- 215
		uiDraw, -- 215
		uiArt, -- 215
		"hud_child_veil", -- 215
		bx + 144, -- 215
		by + 22, -- 215
		316, -- 215
		48, -- 215
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 215
		0.58 * alpha, -- 215
		-1 -- 215
	) -- 215
	texts:put( -- 216
		"md", -- 216
		alert and "危" or "满", -- 216
		bx + 16, -- 216
		by + 22, -- 216
		toColor(leadCol), -- 216
		0.5, -- 216
		0.5, -- 216
		"Center", -- 216
		0, -- 216
		alpha, -- 216
		0.1 -- 216
	) -- 216
	uiInkDraw:drawSegment( -- 217
		Vec2(bx + 32, by + 7), -- 217
		Vec2(bx + 32, by + 37), -- 217
		0.8, -- 217
		toColor(PALETTE.silkDim, 130 * alpha) -- 217
	) -- 217
	texts:put( -- 219
		"xs", -- 219
		"小满 · 潜行", -- 219
		bx + 44, -- 219
		by + 33, -- 219
		toColor(PALETTE.amberCore), -- 219
		0, -- 219
		0.5, -- 219
		"Left", -- 219
		1.4, -- 219
		alpha, -- 219
		0.08 -- 219
	) -- 219
	local posture = "轻步前行 · 保持隐蔽" -- 221
	local col = PALETTE.textMid -- 222
	if alert then -- 222
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 224
		col = PALETTE.crimsonCore -- 225
	elseif p.player.crouch then -- 225
		posture = "低姿伏行 · 匿迹于影" -- 227
		col = PALETTE.emerald -- 228
	elseif p.hasBottle then -- 228
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 230
		col = PALETTE.amberCore -- 231
	end -- 231
	texts:put( -- 233
		"xs", -- 233
		posture, -- 233
		bx + 44, -- 233
		by + 12, -- 233
		toColor(col), -- 233
		0, -- 233
		0.5, -- 233
		"Left", -- 233
		0.6, -- 233
		alpha, -- 233
		0.08 -- 233
	) -- 233
end -- 201
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 236
	local theme = themeOf(p.room.key) -- 245
	local rx = w - 32 -- 246
	local cy = h - 44 -- 247
	drawSilkVeil( -- 249
		uiDraw, -- 249
		uiArt, -- 249
		"hud_chap_veil", -- 249
		rx - 82, -- 249
		cy, -- 249
		240, -- 249
		44, -- 249
		PALETTE.inkWash, -- 249
		0.44 * alpha, -- 249
		-1 -- 249
	) -- 249
	texts:put( -- 250
		"xs", -- 250
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 250
		rx, -- 250
		cy + 9, -- 250
		toColor(PALETTE.textBright), -- 250
		1, -- 250
		0.5, -- 250
		"Right", -- 250
		1.2, -- 250
		alpha, -- 250
		0.08 -- 250
	) -- 250
	texts:put( -- 251
		"xs", -- 251
		"Esc 暂歇", -- 251
		rx, -- 251
		cy - 11, -- 251
		toColor(PALETTE.textDim), -- 251
		1, -- 251
		0.5, -- 251
		"Right", -- 251
		1, -- 251
		0.78 * alpha, -- 251
		0.08 -- 251
	) -- 251
end -- 236
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 254
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 254
		local g = p.room.story.gate -- 266
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 266
			local bw = 400 -- 268
			local cx = w * 0.5 -- 269
			local by = h - 64 -- 270
			local ratio = math.max( -- 271
				0, -- 271
				math.min( -- 271
					1, -- 271
					p.gateTick / math.max(1, g.holdTicks) -- 271
				) -- 271
			) -- 271
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 272
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 273
			drawSilkVeil( -- 275
				uiDraw, -- 275
				uiArt, -- 275
				"hud_gate_veil", -- 275
				cx, -- 275
				by + 18, -- 275
				bw + 90, -- 275
				48, -- 275
				PALETTE.inkWash, -- 275
				0.76 * alpha, -- 275
				-1 -- 275
			) -- 275
			drawHairline( -- 276
				uiInkDraw, -- 276
				uiArt, -- 276
				"hud_gate_top", -- 276
				cx, -- 276
				by + 39, -- 276
				bw - 20, -- 276
				PALETTE.rougeSoft, -- 276
				0.55 * alpha, -- 276
				false, -- 276
				2 -- 276
			) -- 276
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 278
			texts:put( -- 281
				"xs", -- 281
				label, -- 281
				cx, -- 281
				by + 26, -- 281
				toColor(PALETTE.textBright), -- 281
				0.5, -- 281
				0.5, -- 281
				"Center", -- 281
				1.8, -- 281
				alpha, -- 281
				0.08 -- 281
			) -- 281
			local pbw = bw - 80 -- 284
			local pbx = cx - pbw * 0.5 -- 285
			local pby = by + 9 -- 286
			uiInkDraw:drawSegment( -- 287
				Vec2(pbx, pby), -- 287
				Vec2(pbx + pbw, pby), -- 287
				1.4, -- 287
				toColor(PALETTE.silkDim, 115 * alpha) -- 287
			) -- 287
			if ratio > 0.002 then -- 287
				uiInkDraw:drawSegment( -- 289
					Vec2(pbx, pby), -- 289
					Vec2(pbx + pbw * ratio, pby), -- 289
					2.8, -- 289
					toColor(PALETTE.rouge, 230 * alpha) -- 289
				) -- 289
				uiInkDraw:drawSegment( -- 290
					Vec2(pbx, pby), -- 290
					Vec2(pbx + pbw * ratio, pby), -- 290
					1, -- 290
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 290
				) -- 290
			end -- 290
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 292
			local k = 0 -- 293
			do -- 293
				k = 0 -- 294
				while k < #waves do -- 294
					local wx = pbx + pbw * waves[k + 1] -- 295
					local passed = p.gateSpawned > k -- 296
					if passed then -- 296
						drawBlossomDot( -- 298
							uiInkDraw, -- 298
							uiArt, -- 298
							"gate_wave_" .. tostring(k), -- 298
							wx, -- 298
							pby, -- 298
							10, -- 298
							PALETTE.moonPale, -- 298
							0.92 * alpha, -- 298
							3 -- 298
						) -- 298
					else -- 298
						uiArt:tryPlace( -- 300
							"ink_enso_fine", -- 300
							"gate_wave_" .. tostring(k), -- 300
							wx, -- 300
							pby, -- 300
							11, -- 300
							11, -- 300
							{ -- 300
								color = toColor(PALETTE.rouge), -- 301
								opacity = 0.84 * alpha, -- 301
								layer = 3 -- 301
							} -- 301
						) -- 301
					end -- 301
					k = k + 1 -- 294
				end -- 294
			end -- 294
		end -- 294
		return -- 306
	end -- 306
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 306
		local cx = w * 0.5 -- 311
		local by = h - 44 -- 312
		local step1 = p.cartDocked -- 313
		local ____temp_0 -- 314
		if p.room.key == "checkpoint" then -- 314
			____temp_0 = p.gateOpen -- 314
		else -- 314
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 314
		end -- 314
		local step2 = ____temp_0 -- 314
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 315
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 316
		drawSilkVeil( -- 318
			uiDraw, -- 318
			uiArt, -- 318
			"hud_obj_veil", -- 318
			cx, -- 318
			by, -- 318
			380, -- 318
			34, -- 318
			PALETTE.inkWash, -- 318
			0.58 * alpha, -- 318
			-1 -- 318
		) -- 318
		local x1 = cx - 134 -- 320
		if step1 then -- 320
			drawBlossomDot( -- 322
				uiInkDraw, -- 322
				uiArt, -- 322
				"obj_m1", -- 322
				x1, -- 322
				by, -- 322
				11, -- 322
				PALETTE.emerald, -- 322
				0.94 * alpha, -- 322
				3 -- 322
			) -- 322
		else -- 322
			uiArt:tryPlace( -- 324
				"ink_enso_fine", -- 324
				"obj_m1", -- 324
				x1, -- 324
				by, -- 324
				11, -- 324
				11, -- 324
				{ -- 324
					color = toColor(PALETTE.silkLine), -- 324
					opacity = 0.72 * alpha, -- 324
					layer = 3 -- 324
				} -- 324
			) -- 324
		end -- 324
		texts:put( -- 326
			"xs", -- 326
			t1, -- 326
			x1 + 13, -- 326
			by, -- 326
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 326
			0, -- 326
			0.5, -- 326
			"Left", -- 326
			1, -- 326
			alpha, -- 326
			0.08 -- 326
		) -- 326
		local x2 = cx + 18 -- 328
		if step2 then -- 328
			drawBlossomDot( -- 330
				uiInkDraw, -- 330
				uiArt, -- 330
				"obj_m2", -- 330
				x2, -- 330
				by, -- 330
				11, -- 330
				PALETTE.emerald, -- 330
				0.94 * alpha, -- 330
				3 -- 330
			) -- 330
		else -- 330
			uiArt:tryPlace( -- 332
				"ink_enso_fine", -- 332
				"obj_m2", -- 332
				x2, -- 332
				by, -- 332
				11, -- 332
				11, -- 332
				{ -- 332
					color = toColor(PALETTE.silkDim), -- 332
					opacity = 0.62 * alpha, -- 332
					layer = 3 -- 332
				} -- 332
			) -- 332
		end -- 332
		texts:put( -- 334
			"xs", -- 334
			t2, -- 334
			x2 + 13, -- 334
			by, -- 334
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 334
			0, -- 334
			0.5, -- 334
			"Left", -- 334
			1, -- 334
			alpha, -- 334
			0.08 -- 334
		) -- 334
	end -- 334
end -- 254
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 338
	local bob = math.sin(self.time * 3.4) * 2.8 -- 348
	local viewW = cam.viewW / uiScale -- 349
	local viewH = cam.viewH / uiScale -- 350
	local i = 0 -- 351
	do -- 351
		i = 0 -- 352
		while i < #prompts do -- 352
			local pr = prompts[i + 1] -- 353
			local keyW = math.max( -- 354
				24, -- 354
				visualTextWidth(pr.keyTag, 15) + 16 -- 354
			) -- 354
			local labelW = visualTextWidth(pr.label, 15) -- 355
			local pillW = keyW + labelW + 24 -- 356
			local padX = math.max(115, pillW * 0.5 + 24) -- 357
			local sx = math.max( -- 358
				padX, -- 358
				math.min( -- 358
					viewW - padX, -- 358
					cam:sx(pr.x) / uiScale -- 358
				) -- 358
			) -- 358
			local sy = math.max( -- 359
				96, -- 359
				math.min( -- 359
					viewH - 110, -- 359
					cam:sy(pr.y) / uiScale + bob -- 359
				) -- 359
			) -- 359
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 360
			uiInkDraw:drawSegment( -- 363
				Vec2(sx, sy - 14), -- 363
				Vec2(sx, sy - 27), -- 363
				0.8, -- 363
				toColor(accent, 135 * alpha) -- 363
			) -- 363
			drawBlossomDot( -- 364
				uiInkDraw, -- 364
				uiArt, -- 364
				"wp_anchor_" .. tostring(i), -- 364
				sx, -- 364
				sy - 28, -- 364
				7, -- 364
				accent, -- 364
				0.85 * alpha, -- 364
				3 -- 364
			) -- 364
			local px = sx - pillW * 0.5 -- 366
			local py = sy - 12 -- 367
			drawSilkVeil( -- 369
				uiDraw, -- 369
				uiArt, -- 369
				"wp_bg_" .. tostring(i), -- 369
				sx, -- 369
				py + 12, -- 369
				pillW + 40, -- 369
				32, -- 369
				PALETTE.inkWash, -- 369
				0.78 * alpha, -- 369
				0 -- 369
			) -- 369
			drawHairline( -- 370
				uiInkDraw, -- 370
				uiArt, -- 370
				"wp_line_" .. tostring(i), -- 370
				sx, -- 370
				py + 24, -- 370
				pillW + 4, -- 370
				accent, -- 370
				0.45 * alpha, -- 370
				false, -- 370
				2 -- 370
			) -- 370
			drawSilkKeycap( -- 371
				uiInkDraw, -- 371
				texts, -- 371
				px + 2, -- 371
				py + 2, -- 371
				keyW, -- 371
				20, -- 371
				pr.keyTag, -- 371
				accent, -- 371
				alpha, -- 371
				pr.urgent -- 371
			) -- 371
			texts:put( -- 372
				"xs", -- 372
				pr.label, -- 372
				px + keyW + 12, -- 372
				py + 12, -- 372
				toColor(PALETTE.textBright), -- 372
				0, -- 372
				0.5, -- 372
				"Left", -- 372
				0.8, -- 372
				alpha, -- 372
				0.08 -- 372
			) -- 372
			i = i + 1 -- 352
		end -- 352
	end -- 352
end -- 338
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 376
	local mx = p.aimX / uiScale -- 385
	local my = p.aimY / uiScale -- 386
	if mx <= 0 and my <= 0 then -- 386
		return -- 388
	end -- 388
	if p.childMode then -- 388
		local aiming = p.room.key == "village" and p.hasBottle -- 392
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 393
		uiInkDraw:drawDot( -- 394
			Vec2(mx, my), -- 394
			aiming and 2 or 1.6, -- 394
			toColor(col, aiming and 215 or 120) -- 394
		) -- 394
		if aiming then -- 394
			local sz = p.aimHold > 0 and 32 or 24 -- 396
			uiArt:tryPlace( -- 397
				"ink_enso_fine", -- 397
				"reticle_child", -- 397
				mx, -- 397
				my, -- 397
				sz, -- 397
				sz, -- 397
				{ -- 397
					color = toColor(PALETTE.amberCore), -- 398
					opacity = 0.82, -- 398
					angle = self.time * 24, -- 398
					layer = 5 -- 398
				} -- 398
			) -- 398
		end -- 398
		return -- 401
	end -- 401
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 404
	local onEnemy = false -- 405
	local i = 0 -- 406
	do -- 406
		i = 0 -- 407
		while i < #p.enemies do -- 407
			local e = p.enemies[i + 1] -- 408
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 408
				onEnemy = true -- 410
			end -- 410
			i = i + 1 -- 407
		end -- 407
	end -- 407
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 414
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 415
	local arm = onEnemy and 8.5 or 9.5 -- 416
	local bg = Color(10, 12, 18, 160) -- 417
	uiInkDraw:drawSegment( -- 419
		Vec2(mx - gap - arm, my), -- 419
		Vec2(mx - gap, my), -- 419
		2.1, -- 419
		bg -- 419
	) -- 419
	uiInkDraw:drawSegment( -- 420
		Vec2(mx + gap, my), -- 420
		Vec2(mx + gap + arm, my), -- 420
		2.1, -- 420
		bg -- 420
	) -- 420
	uiInkDraw:drawSegment( -- 421
		Vec2(mx, my - gap - arm), -- 421
		Vec2(mx, my - gap), -- 421
		2.1, -- 421
		bg -- 421
	) -- 421
	uiInkDraw:drawSegment( -- 422
		Vec2(mx, my + gap), -- 422
		Vec2(mx, my + gap + arm), -- 422
		2.1, -- 422
		bg -- 422
	) -- 422
	uiInkDraw:drawSegment( -- 424
		Vec2(mx - gap - arm, my), -- 424
		Vec2(mx - gap, my), -- 424
		1.1, -- 424
		toColor(col, 230) -- 424
	) -- 424
	uiInkDraw:drawSegment( -- 425
		Vec2(mx + gap, my), -- 425
		Vec2(mx + gap + arm, my), -- 425
		1.1, -- 425
		toColor(col, 230) -- 425
	) -- 425
	uiInkDraw:drawSegment( -- 426
		Vec2(mx, my - gap - arm), -- 426
		Vec2(mx, my - gap), -- 426
		1.1, -- 426
		toColor(col, 230) -- 426
	) -- 426
	uiInkDraw:drawSegment( -- 427
		Vec2(mx, my + gap), -- 427
		Vec2(mx, my + gap + arm), -- 427
		1.1, -- 427
		toColor(col, 230) -- 427
	) -- 427
	uiInkDraw:drawDot( -- 428
		Vec2(mx, my), -- 428
		1.8, -- 428
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 428
	) -- 428
	if onEnemy then -- 428
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 431
		uiArt:tryPlace( -- 432
			"ink_enso_fine", -- 432
			"reticle_lock", -- 432
			mx, -- 432
			my, -- 432
			sz, -- 432
			sz, -- 432
			{ -- 432
				color = toColor(PALETTE.rouge), -- 433
				opacity = 0.88, -- 433
				angle = self.time * 38, -- 433
				layer = 5 -- 433
			} -- 433
		) -- 433
		fillRadialGlow( -- 435
			uiGlow, -- 435
			mx, -- 435
			my, -- 435
			16, -- 435
			16, -- 435
			toColor(PALETTE.rouge, 30), -- 435
			Color(182, 58, 56, 0), -- 435
			10 -- 435
		) -- 435
	end -- 435
end -- 376
return ____exports -- 376