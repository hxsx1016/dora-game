-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local Rect = ____Dora.Rect -- 8
local Vec2 = ____Dora.Vec2 -- 8
local ____escort = require("Script.watch.escort") -- 10
local FEAR_MAX = ____escort.FEAR_MAX -- 10
local ____adapter = require("Script.watch.fe.adapter") -- 11
local deriveWorldPrompts = ____adapter.deriveWorldPrompts -- 11
local ____theme = require("Script.watch.fe.theme") -- 16
local PALETTE = ____theme.PALETTE -- 17
local drawBlossomDot = ____theme.drawBlossomDot -- 18
local drawHairline = ____theme.drawHairline -- 19
local drawSilkKeycap = ____theme.drawSilkKeycap -- 20
local drawSilkVeil = ____theme.drawSilkVeil -- 21
local fillRadialGlow = ____theme.fillRadialGlow -- 22
local themeOf = ____theme.themeOf -- 23
local toColor = ____theme.toColor -- 24
local visualTextWidth = ____theme.visualTextWidth -- 25
____exports.HudRenderer = __TS__Class() -- 28
local HudRenderer = ____exports.HudRenderer -- 28
HudRenderer.name = "HudRenderer" -- 28
function HudRenderer.prototype.____constructor(self) -- 28
	self.ghostHp = 3 -- 30
	self.time = 0 -- 31
end -- 28
function HudRenderer.prototype.reset(self, p) -- 33
	self.ghostHp = p ~= nil and p.hp or 3 -- 34
end -- 33
function HudRenderer.prototype.update(self, dt, p) -- 37
	self.time = self.time + dt -- 38
	if self.ghostHp > p.hp then -- 38
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 40
	else -- 40
		self.ghostHp = p.hp -- 42
	end -- 42
end -- 37
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale) -- 46
	local w = cam.viewW / uiScale -- 58
	local h = cam.viewH / uiScale -- 59
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 61
	if hudAlpha > 0.05 then -- 61
		if p.childMode then -- 61
			self:drawChildStatus( -- 65
				uiDraw, -- 65
				uiInkDraw, -- 65
				uiArt, -- 65
				texts, -- 65
				p, -- 65
				h, -- 65
				hudAlpha -- 65
			) -- 65
		else -- 65
			self:drawSoldierStatus( -- 67
				uiDraw, -- 67
				uiInkDraw, -- 67
				uiArt, -- 67
				texts, -- 67
				p, -- 67
				h, -- 67
				hudAlpha -- 67
			) -- 67
		end -- 67
		self:drawChapterBadge( -- 70
			uiDraw, -- 70
			uiArt, -- 70
			texts, -- 70
			p, -- 70
			w, -- 70
			h, -- 70
			hudAlpha -- 70
		) -- 70
		self:drawContextualObjective( -- 71
			uiDraw, -- 71
			uiInkDraw, -- 71
			uiArt, -- 71
			texts, -- 71
			p, -- 71
			w, -- 71
			h, -- 71
			hudAlpha -- 71
		) -- 71
		local prompts = deriveWorldPrompts(p) -- 73
		self:drawWorldPrompts( -- 74
			uiDraw, -- 74
			uiInkDraw, -- 74
			uiArt, -- 74
			texts, -- 74
			prompts, -- 74
			cam, -- 74
			hudAlpha, -- 74
			uiScale -- 74
		) -- 74
		if vfx.deflectFlash > 0.25 then -- 74
			local dx = cam:sx(vfx.deflectX) / uiScale -- 77
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 78
			texts:put( -- 79
				"sm", -- 79
				"掩体挡下", -- 79
				dx, -- 79
				dy, -- 79
				toColor(PALETTE.textBright), -- 79
				0.5, -- 79
				0.5, -- 79
				"Center", -- 79
				2, -- 79
				vfx.deflectFlash, -- 79
				0.1 -- 79
			) -- 79
		end -- 79
	end -- 79
	if not p.paused and letterboxFrac < 0.5 then -- 79
		self:drawReticle( -- 84
			uiInkDraw, -- 84
			uiArt, -- 84
			uiGlow, -- 84
			p, -- 84
			cam, -- 84
			vfx, -- 84
			uiScale -- 84
		) -- 84
	end -- 84
end -- 46
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 88
	local bx = 28 -- 97
	local by = h - 72 -- 98
	local lowHp = p.hp <= 1 -- 99
	drawSilkVeil( -- 102
		uiDraw, -- 102
		uiArt, -- 102
		"hud_soldier_veil", -- 102
		bx + 150, -- 102
		by + 24, -- 102
		340, -- 102
		56, -- 102
		PALETTE.inkWash, -- 102
		0.62 * alpha, -- 102
		-1 -- 102
	) -- 102
	texts:put( -- 105
		"md", -- 105
		"戍", -- 105
		bx + 16, -- 105
		by + 25, -- 105
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 105
		0.5, -- 105
		0.5, -- 105
		"Center", -- 105
		0, -- 105
		alpha, -- 105
		0.1 -- 105
	) -- 105
	uiInkDraw:drawSegment( -- 106
		Vec2(bx + 32, by + 9), -- 106
		Vec2(bx + 32, by + 40), -- 106
		0.8, -- 106
		toColor(PALETTE.silkDim, 130 * alpha) -- 106
	) -- 106
	texts:put( -- 108
		"xs", -- 108
		"周戍 · 体力", -- 108
		bx + 44, -- 108
		by + 36, -- 108
		toColor(PALETTE.textMid), -- 108
		0, -- 108
		0.5, -- 108
		"Left", -- 108
		1.4, -- 108
		alpha, -- 108
		0.08 -- 108
	) -- 108
	local segCount = math.max(1, p.maxHp) -- 111
	local barX = bx + 44 -- 112
	local barY = by + 16 -- 113
	local segW = 54 -- 114
	local segH = 9 -- 115
	local gap = 8 -- 116
	local i = 0 -- 118
	do -- 118
		i = 0 -- 119
		while i < segCount do -- 119
			local sx = barX + i * (segW + gap) -- 120
			local scx = sx + segW * 0.5 -- 121
			if not uiArt:tryPlace( -- 121
				"ink_bamboo_slot", -- 122
				"hp_slot_" .. tostring(i), -- 122
				scx, -- 122
				barY, -- 122
				segW, -- 122
				segH, -- 122
				{ -- 122
					color = toColor(PALETTE.silkDim), -- 123
					opacity = 0.72 * alpha, -- 123
					layer = 1 -- 123
				} -- 123
			) then -- 123
				uiInkDraw:drawRect( -- 125
					Rect(sx, barY - 3, segW, 6), -- 125
					Color(0, 0, 0, 0), -- 125
					0.8, -- 125
					toColor(PALETTE.silkDim, 145 * alpha) -- 125
				) -- 125
			end -- 125
			if self.ghostHp > i and self.ghostHp > p.hp then -- 125
				local frac = math.min(1, self.ghostHp - i) -- 128
				uiInkDraw:drawRect( -- 129
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 129
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 129
				) -- 129
			end -- 129
			if p.hp > i then -- 129
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 132
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 133
				if not uiArt:tryPlace( -- 133
					"ink_bamboo_slip", -- 134
					"hp_fill_" .. tostring(i), -- 134
					scx, -- 134
					barY, -- 134
					segW, -- 134
					segH, -- 134
					{ -- 134
						color = toColor(fillCol), -- 135
						opacity = 0.94 * alpha * pulse, -- 135
						layer = 2 -- 135
					} -- 135
				) then -- 135
					uiInkDraw:drawRect( -- 137
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 137
						toColor(fillCol, 230 * alpha * pulse) -- 137
					) -- 137
				end -- 137
			end -- 137
			i = i + 1 -- 119
		end -- 119
	end -- 119
	local covX = barX + segCount * (segW + gap) + 6 -- 143
	if p.coverHug then -- 143
		uiInkDraw:drawRect( -- 145
			Rect(covX, barY - 9, 54, 18), -- 145
			toColor(PALETTE.cyanDim, 165 * alpha), -- 145
			0.8, -- 145
			toColor(PALETTE.cyanCore, 180 * alpha) -- 145
		) -- 145
		texts:put( -- 146
			"xs", -- 146
			"掩体中", -- 146
			covX + 27, -- 146
			barY, -- 146
			toColor(PALETTE.textBright), -- 146
			0.5, -- 146
			0.5, -- 146
			"Center", -- 146
			0.6, -- 146
			alpha, -- 146
			0 -- 146
		) -- 146
	elseif p.coverNear then -- 146
		uiInkDraw:drawRect( -- 148
			Rect(covX, barY - 9, 54, 18), -- 148
			Color( -- 148
				14, -- 148
				17, -- 148
				25, -- 148
				math.floor(150 * alpha + 0.5) -- 148
			), -- 148
			0.8, -- 148
			toColor(PALETTE.silkLine, 165 * alpha) -- 148
		) -- 148
		texts:put( -- 149
			"xs", -- 149
			"可贴靠", -- 149
			covX + 27, -- 149
			barY, -- 149
			toColor(PALETTE.textMid), -- 149
			0.5, -- 149
			0.5, -- 149
			"Center", -- 149
			0.6, -- 149
			alpha, -- 149
			0.08 -- 149
		) -- 149
	end -- 149
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 149
		local subY = by - 24 -- 154
		local frozen = p.escort.state == "frozen" -- 155
		local calming = p.escort.state == "calming" -- 156
		drawSilkVeil( -- 158
			uiDraw, -- 158
			uiArt, -- 158
			"hud_fear_veil", -- 158
			bx + 126, -- 158
			subY + 6, -- 158
			260, -- 158
			30, -- 158
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 158
			0.64 * alpha, -- 158
			-1 -- 158
		) -- 158
		texts:put( -- 159
			"xs", -- 159
			"小满 · 惊惧", -- 159
			bx + 14, -- 159
			subY + 6, -- 159
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 159
			0, -- 159
			0.5, -- 159
			"Left", -- 159
			1, -- 159
			alpha, -- 159
			0.08 -- 159
		) -- 159
		local k = 0 -- 161
		do -- 161
			k = 0 -- 162
			while k < FEAR_MAX do -- 162
				local dx = bx + 114 + k * 20 -- 163
				local dy = subY + 6 -- 164
				local lit = k < p.escort.fear -- 165
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 166
				uiArt:tryPlace( -- 167
					"ink_enso_fine", -- 167
					"fear_ring_" .. tostring(k), -- 167
					dx, -- 167
					dy, -- 167
					14, -- 167
					14, -- 167
					{ -- 167
						color = toColor(lit and dc or PALETTE.silkLine), -- 168
						opacity = (lit and 0.92 or 0.64) * alpha, -- 168
						layer = 2 -- 168
					} -- 168
				) -- 168
				if lit then -- 168
					drawBlossomDot( -- 171
						uiInkDraw, -- 171
						uiArt, -- 171
						"fear_dot_" .. tostring(k), -- 171
						dx, -- 171
						dy, -- 171
						10, -- 171
						dc, -- 171
						0.96 * alpha, -- 171
						3 -- 171
					) -- 171
				end -- 171
				k = k + 1 -- 162
			end -- 162
		end -- 162
		if frozen then -- 162
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 176
			drawSilkKeycap( -- 177
				uiInkDraw, -- 177
				texts, -- 177
				bx + 170, -- 177
				subY - 5, -- 177
				22, -- 177
				22, -- 177
				"E", -- 177
				PALETTE.rouge, -- 177
				alpha * pulse, -- 177
				true -- 177
			) -- 177
			texts:put( -- 178
				"xs", -- 178
				"轻敲安抚", -- 178
				bx + 198, -- 178
				subY + 6, -- 178
				toColor(PALETTE.crimsonCore), -- 178
				0, -- 178
				0.5, -- 178
				"Left", -- 178
				0.8, -- 178
				alpha * pulse, -- 178
				0.08 -- 178
			) -- 178
		elseif calming then -- 178
			texts:put( -- 180
				"xs", -- 180
				"轻敲安抚中", -- 180
				bx + 172, -- 180
				subY + 6, -- 180
				toColor(PALETTE.emerald), -- 180
				0, -- 180
				0.5, -- 180
				"Left", -- 180
				0.8, -- 180
				alpha, -- 180
				0.08 -- 180
			) -- 180
		end -- 180
	end -- 180
end -- 88
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 185
	local bx = 28 -- 194
	local by = h - 68 -- 195
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 196
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 197
	drawSilkVeil( -- 199
		uiDraw, -- 199
		uiArt, -- 199
		"hud_child_veil", -- 199
		bx + 144, -- 199
		by + 22, -- 199
		316, -- 199
		48, -- 199
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 199
		0.58 * alpha, -- 199
		-1 -- 199
	) -- 199
	texts:put( -- 200
		"md", -- 200
		alert and "危" or "满", -- 200
		bx + 16, -- 200
		by + 22, -- 200
		toColor(leadCol), -- 200
		0.5, -- 200
		0.5, -- 200
		"Center", -- 200
		0, -- 200
		alpha, -- 200
		0.1 -- 200
	) -- 200
	uiInkDraw:drawSegment( -- 201
		Vec2(bx + 32, by + 7), -- 201
		Vec2(bx + 32, by + 37), -- 201
		0.8, -- 201
		toColor(PALETTE.silkDim, 130 * alpha) -- 201
	) -- 201
	texts:put( -- 203
		"xs", -- 203
		"小满 · 潜行", -- 203
		bx + 44, -- 203
		by + 33, -- 203
		toColor(PALETTE.amberCore), -- 203
		0, -- 203
		0.5, -- 203
		"Left", -- 203
		1.4, -- 203
		alpha, -- 203
		0.08 -- 203
	) -- 203
	local posture = "轻步前行 · 保持隐蔽" -- 205
	local col = PALETTE.textMid -- 206
	if alert then -- 206
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 208
		col = PALETTE.crimsonCore -- 209
	elseif p.player.crouch then -- 209
		posture = "低姿伏行 · 匿迹于影" -- 211
		col = PALETTE.emerald -- 212
	elseif p.hasBottle then -- 212
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 214
		col = PALETTE.amberCore -- 215
	end -- 215
	texts:put( -- 217
		"xs", -- 217
		posture, -- 217
		bx + 44, -- 217
		by + 12, -- 217
		toColor(col), -- 217
		0, -- 217
		0.5, -- 217
		"Left", -- 217
		0.6, -- 217
		alpha, -- 217
		0.08 -- 217
	) -- 217
end -- 185
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 220
	local theme = themeOf(p.room.key) -- 229
	local rx = w - 32 -- 230
	local cy = h - 44 -- 231
	drawSilkVeil( -- 233
		uiDraw, -- 233
		uiArt, -- 233
		"hud_chap_veil", -- 233
		rx - 82, -- 233
		cy, -- 233
		240, -- 233
		44, -- 233
		PALETTE.inkWash, -- 233
		0.44 * alpha, -- 233
		-1 -- 233
	) -- 233
	texts:put( -- 234
		"xs", -- 234
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 234
		rx, -- 234
		cy + 9, -- 234
		toColor(PALETTE.textBright), -- 234
		1, -- 234
		0.5, -- 234
		"Right", -- 234
		1.2, -- 234
		alpha, -- 234
		0.08 -- 234
	) -- 234
	texts:put( -- 235
		"xs", -- 235
		"Esc 暂歇", -- 235
		rx, -- 235
		cy - 11, -- 235
		toColor(PALETTE.textDim), -- 235
		1, -- 235
		0.5, -- 235
		"Right", -- 235
		1, -- 235
		0.78 * alpha, -- 235
		0.08 -- 235
	) -- 235
end -- 220
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 238
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 238
		local g = p.room.story.gate -- 250
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 250
			local bw = 400 -- 252
			local cx = w * 0.5 -- 253
			local by = h - 64 -- 254
			local ratio = math.max( -- 255
				0, -- 255
				math.min( -- 255
					1, -- 255
					p.gateTick / math.max(1, g.holdTicks) -- 255
				) -- 255
			) -- 255
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 256
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 257
			drawSilkVeil( -- 259
				uiDraw, -- 259
				uiArt, -- 259
				"hud_gate_veil", -- 259
				cx, -- 259
				by + 18, -- 259
				bw + 90, -- 259
				48, -- 259
				PALETTE.inkWash, -- 259
				0.76 * alpha, -- 259
				-1 -- 259
			) -- 259
			drawHairline( -- 260
				uiInkDraw, -- 260
				uiArt, -- 260
				"hud_gate_top", -- 260
				cx, -- 260
				by + 39, -- 260
				bw - 20, -- 260
				PALETTE.rougeSoft, -- 260
				0.55 * alpha, -- 260
				false, -- 260
				2 -- 260
			) -- 260
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 262
			texts:put( -- 265
				"xs", -- 265
				label, -- 265
				cx, -- 265
				by + 26, -- 265
				toColor(PALETTE.textBright), -- 265
				0.5, -- 265
				0.5, -- 265
				"Center", -- 265
				1.8, -- 265
				alpha, -- 265
				0.08 -- 265
			) -- 265
			local pbw = bw - 80 -- 268
			local pbx = cx - pbw * 0.5 -- 269
			local pby = by + 9 -- 270
			uiInkDraw:drawSegment( -- 271
				Vec2(pbx, pby), -- 271
				Vec2(pbx + pbw, pby), -- 271
				1.4, -- 271
				toColor(PALETTE.silkDim, 115 * alpha) -- 271
			) -- 271
			if ratio > 0.002 then -- 271
				uiInkDraw:drawSegment( -- 273
					Vec2(pbx, pby), -- 273
					Vec2(pbx + pbw * ratio, pby), -- 273
					2.8, -- 273
					toColor(PALETTE.rouge, 230 * alpha) -- 273
				) -- 273
				uiInkDraw:drawSegment( -- 274
					Vec2(pbx, pby), -- 274
					Vec2(pbx + pbw * ratio, pby), -- 274
					1, -- 274
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 274
				) -- 274
			end -- 274
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 276
			local k = 0 -- 277
			do -- 277
				k = 0 -- 278
				while k < #waves do -- 278
					local wx = pbx + pbw * waves[k + 1] -- 279
					local passed = p.gateSpawned > k -- 280
					if passed then -- 280
						drawBlossomDot( -- 282
							uiInkDraw, -- 282
							uiArt, -- 282
							"gate_wave_" .. tostring(k), -- 282
							wx, -- 282
							pby, -- 282
							10, -- 282
							PALETTE.moonPale, -- 282
							0.92 * alpha, -- 282
							3 -- 282
						) -- 282
					else -- 282
						uiArt:tryPlace( -- 284
							"ink_enso_fine", -- 284
							"gate_wave_" .. tostring(k), -- 284
							wx, -- 284
							pby, -- 284
							11, -- 284
							11, -- 284
							{ -- 284
								color = toColor(PALETTE.rouge), -- 285
								opacity = 0.84 * alpha, -- 285
								layer = 3 -- 285
							} -- 285
						) -- 285
					end -- 285
					k = k + 1 -- 278
				end -- 278
			end -- 278
		end -- 278
		return -- 290
	end -- 290
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 290
		local cx = w * 0.5 -- 295
		local by = h - 44 -- 296
		local step1 = p.cartDocked -- 297
		local ____temp_0 -- 298
		if p.room.key == "checkpoint" then -- 298
			____temp_0 = p.gateOpen -- 298
		else -- 298
			____temp_0 = p.checkpoint >= 380 -- 298
		end -- 298
		local step2 = ____temp_0 -- 298
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 299
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 300
		drawSilkVeil( -- 302
			uiDraw, -- 302
			uiArt, -- 302
			"hud_obj_veil", -- 302
			cx, -- 302
			by, -- 302
			380, -- 302
			34, -- 302
			PALETTE.inkWash, -- 302
			0.58 * alpha, -- 302
			-1 -- 302
		) -- 302
		local x1 = cx - 134 -- 304
		if step1 then -- 304
			drawBlossomDot( -- 306
				uiInkDraw, -- 306
				uiArt, -- 306
				"obj_m1", -- 306
				x1, -- 306
				by, -- 306
				11, -- 306
				PALETTE.emerald, -- 306
				0.94 * alpha, -- 306
				3 -- 306
			) -- 306
		else -- 306
			uiArt:tryPlace( -- 308
				"ink_enso_fine", -- 308
				"obj_m1", -- 308
				x1, -- 308
				by, -- 308
				11, -- 308
				11, -- 308
				{ -- 308
					color = toColor(PALETTE.silkLine), -- 308
					opacity = 0.72 * alpha, -- 308
					layer = 3 -- 308
				} -- 308
			) -- 308
		end -- 308
		texts:put( -- 310
			"xs", -- 310
			t1, -- 310
			x1 + 13, -- 310
			by, -- 310
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 310
			0, -- 310
			0.5, -- 310
			"Left", -- 310
			1, -- 310
			alpha, -- 310
			0.08 -- 310
		) -- 310
		local x2 = cx + 18 -- 312
		if step2 then -- 312
			drawBlossomDot( -- 314
				uiInkDraw, -- 314
				uiArt, -- 314
				"obj_m2", -- 314
				x2, -- 314
				by, -- 314
				11, -- 314
				PALETTE.emerald, -- 314
				0.94 * alpha, -- 314
				3 -- 314
			) -- 314
		else -- 314
			uiArt:tryPlace( -- 316
				"ink_enso_fine", -- 316
				"obj_m2", -- 316
				x2, -- 316
				by, -- 316
				11, -- 316
				11, -- 316
				{ -- 316
					color = toColor(PALETTE.silkDim), -- 316
					opacity = 0.62 * alpha, -- 316
					layer = 3 -- 316
				} -- 316
			) -- 316
		end -- 316
		texts:put( -- 318
			"xs", -- 318
			t2, -- 318
			x2 + 13, -- 318
			by, -- 318
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 318
			0, -- 318
			0.5, -- 318
			"Left", -- 318
			1, -- 318
			alpha, -- 318
			0.08 -- 318
		) -- 318
	end -- 318
end -- 238
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 322
	local bob = math.sin(self.time * 3.4) * 2.8 -- 332
	local i = 0 -- 333
	do -- 333
		i = 0 -- 334
		while i < #prompts do -- 334
			local pr = prompts[i + 1] -- 335
			local sx = math.max( -- 336
				115, -- 336
				math.min( -- 336
					cam.viewW / uiScale - 115, -- 336
					cam:sx(pr.x) / uiScale -- 336
				) -- 336
			) -- 336
			local sy = math.max( -- 337
				96, -- 337
				math.min( -- 337
					cam.viewH / uiScale - 110, -- 337
					cam:sy(pr.y) / uiScale + bob -- 337
				) -- 337
			) -- 337
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 338
			uiInkDraw:drawSegment( -- 341
				Vec2(sx, sy - 14), -- 341
				Vec2(sx, sy - 27), -- 341
				0.8, -- 341
				toColor(accent, 135 * alpha) -- 341
			) -- 341
			drawBlossomDot( -- 342
				uiInkDraw, -- 342
				uiArt, -- 342
				"wp_anchor_" .. tostring(i), -- 342
				sx, -- 342
				sy - 28, -- 342
				7, -- 342
				accent, -- 342
				0.85 * alpha, -- 342
				3 -- 342
			) -- 342
			local keyW = math.max( -- 344
				24, -- 344
				visualTextWidth(pr.keyTag, 15) + 14 -- 344
			) -- 344
			local labelW = visualTextWidth(pr.label, 15) -- 345
			local pillW = keyW + labelW + 24 -- 346
			local px = sx - pillW * 0.5 -- 347
			local py = sy - 12 -- 348
			drawSilkVeil( -- 350
				uiDraw, -- 350
				uiArt, -- 350
				"wp_bg_" .. tostring(i), -- 350
				sx, -- 350
				py + 12, -- 350
				pillW + 40, -- 350
				32, -- 350
				PALETTE.inkWash, -- 350
				0.78 * alpha, -- 350
				0 -- 350
			) -- 350
			drawHairline( -- 351
				uiInkDraw, -- 351
				uiArt, -- 351
				"wp_line_" .. tostring(i), -- 351
				sx, -- 351
				py + 24, -- 351
				pillW + 4, -- 351
				accent, -- 351
				0.45 * alpha, -- 351
				false, -- 351
				2 -- 351
			) -- 351
			drawSilkKeycap( -- 352
				uiInkDraw, -- 352
				texts, -- 352
				px + 2, -- 352
				py + 2, -- 352
				keyW, -- 352
				20, -- 352
				pr.keyTag, -- 352
				accent, -- 352
				alpha, -- 352
				pr.urgent -- 352
			) -- 352
			texts:put( -- 353
				"xs", -- 353
				pr.label, -- 353
				px + keyW + 12, -- 353
				py + 12, -- 353
				toColor(PALETTE.textBright), -- 353
				0, -- 353
				0.5, -- 353
				"Left", -- 353
				0.8, -- 353
				alpha, -- 353
				0.08 -- 353
			) -- 353
			i = i + 1 -- 334
		end -- 334
	end -- 334
end -- 322
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 357
	local mx = p.aimX / uiScale -- 366
	local my = p.aimY / uiScale -- 367
	if mx <= 0 and my <= 0 then -- 367
		return -- 369
	end -- 369
	if p.childMode then -- 369
		local aiming = p.room.key == "village" and p.hasBottle -- 373
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 374
		uiInkDraw:drawDot( -- 375
			Vec2(mx, my), -- 375
			aiming and 2 or 1.6, -- 375
			toColor(col, aiming and 215 or 120) -- 375
		) -- 375
		if aiming then -- 375
			local sz = p.aimHold > 0 and 32 or 24 -- 377
			uiArt:tryPlace( -- 378
				"ink_enso_fine", -- 378
				"reticle_child", -- 378
				mx, -- 378
				my, -- 378
				sz, -- 378
				sz, -- 378
				{ -- 378
					color = toColor(PALETTE.amberCore), -- 379
					opacity = 0.82, -- 379
					angle = self.time * 24, -- 379
					layer = 5 -- 379
				} -- 379
			) -- 379
		end -- 379
		return -- 382
	end -- 382
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 385
	local onEnemy = false -- 386
	local i = 0 -- 387
	do -- 387
		i = 0 -- 388
		while i < #p.enemies do -- 388
			local e = p.enemies[i + 1] -- 389
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 389
				onEnemy = true -- 391
			end -- 391
			i = i + 1 -- 388
		end -- 388
	end -- 388
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 395
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 396
	local arm = onEnemy and 8.5 or 9.5 -- 397
	local bg = Color(10, 12, 18, 160) -- 398
	uiInkDraw:drawSegment( -- 400
		Vec2(mx - gap - arm, my), -- 400
		Vec2(mx - gap, my), -- 400
		2.1, -- 400
		bg -- 400
	) -- 400
	uiInkDraw:drawSegment( -- 401
		Vec2(mx + gap, my), -- 401
		Vec2(mx + gap + arm, my), -- 401
		2.1, -- 401
		bg -- 401
	) -- 401
	uiInkDraw:drawSegment( -- 402
		Vec2(mx, my - gap - arm), -- 402
		Vec2(mx, my - gap), -- 402
		2.1, -- 402
		bg -- 402
	) -- 402
	uiInkDraw:drawSegment( -- 403
		Vec2(mx, my + gap), -- 403
		Vec2(mx, my + gap + arm), -- 403
		2.1, -- 403
		bg -- 403
	) -- 403
	uiInkDraw:drawSegment( -- 405
		Vec2(mx - gap - arm, my), -- 405
		Vec2(mx - gap, my), -- 405
		1.1, -- 405
		toColor(col, 230) -- 405
	) -- 405
	uiInkDraw:drawSegment( -- 406
		Vec2(mx + gap, my), -- 406
		Vec2(mx + gap + arm, my), -- 406
		1.1, -- 406
		toColor(col, 230) -- 406
	) -- 406
	uiInkDraw:drawSegment( -- 407
		Vec2(mx, my - gap - arm), -- 407
		Vec2(mx, my - gap), -- 407
		1.1, -- 407
		toColor(col, 230) -- 407
	) -- 407
	uiInkDraw:drawSegment( -- 408
		Vec2(mx, my + gap), -- 408
		Vec2(mx, my + gap + arm), -- 408
		1.1, -- 408
		toColor(col, 230) -- 408
	) -- 408
	uiInkDraw:drawDot( -- 409
		Vec2(mx, my), -- 409
		1.8, -- 409
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 409
	) -- 409
	if onEnemy then -- 409
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 412
		uiArt:tryPlace( -- 413
			"ink_enso_fine", -- 413
			"reticle_lock", -- 413
			mx, -- 413
			my, -- 413
			sz, -- 413
			sz, -- 413
			{ -- 413
				color = toColor(PALETTE.rouge), -- 414
				opacity = 0.88, -- 414
				angle = self.time * 38, -- 414
				layer = 5 -- 414
			} -- 414
		) -- 414
		fillRadialGlow( -- 416
			uiGlow, -- 416
			mx, -- 416
			my, -- 416
			16, -- 416
			16, -- 416
			toColor(PALETTE.rouge, 30), -- 416
			Color(182, 58, 56, 0), -- 416
			10 -- 416
		) -- 416
	end -- 416
end -- 357
return ____exports -- 357