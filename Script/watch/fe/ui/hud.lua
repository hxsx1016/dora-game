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
	if not p.paused and letterboxFrac < 0.5 then -- 82
		self:drawReticle( -- 87
			uiInkDraw, -- 87
			uiArt, -- 87
			uiGlow, -- 87
			p, -- 87
			cam, -- 87
			vfx, -- 87
			uiScale -- 87
		) -- 87
	end -- 87
end -- 47
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 91
	local bx = 28 -- 100
	local by = h - 72 -- 101
	local lowHp = p.hp <= 1 -- 102
	drawSilkVeil( -- 105
		uiDraw, -- 105
		uiArt, -- 105
		"hud_soldier_veil", -- 105
		bx + 150, -- 105
		by + 24, -- 105
		340, -- 105
		56, -- 105
		PALETTE.inkWash, -- 105
		0.62 * alpha, -- 105
		-1 -- 105
	) -- 105
	texts:put( -- 108
		"md", -- 108
		"戍", -- 108
		bx + 16, -- 108
		by + 25, -- 108
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 108
		0.5, -- 108
		0.5, -- 108
		"Center", -- 108
		0, -- 108
		alpha, -- 108
		0.1 -- 108
	) -- 108
	uiInkDraw:drawSegment( -- 109
		Vec2(bx + 32, by + 9), -- 109
		Vec2(bx + 32, by + 40), -- 109
		0.8, -- 109
		toColor(PALETTE.silkDim, 130 * alpha) -- 109
	) -- 109
	texts:put( -- 111
		"xs", -- 111
		"周戍 · 体力", -- 111
		bx + 44, -- 111
		by + 36, -- 111
		toColor(PALETTE.textMid), -- 111
		0, -- 111
		0.5, -- 111
		"Left", -- 111
		1.4, -- 111
		alpha, -- 111
		0.08 -- 111
	) -- 111
	local segCount = math.max(1, p.maxHp) -- 114
	local barX = bx + 44 -- 115
	local barY = by + 16 -- 116
	local segW = 54 -- 117
	local segH = 9 -- 118
	local gap = 8 -- 119
	local i = 0 -- 121
	do -- 121
		i = 0 -- 122
		while i < segCount do -- 122
			local sx = barX + i * (segW + gap) -- 123
			local scx = sx + segW * 0.5 -- 124
			if not uiArt:tryPlace( -- 124
				"ink_bamboo_slot", -- 125
				"hp_slot_" .. tostring(i), -- 125
				scx, -- 125
				barY, -- 125
				segW, -- 125
				segH, -- 125
				{ -- 125
					color = toColor(PALETTE.silkDim), -- 126
					opacity = 0.72 * alpha, -- 126
					layer = 1 -- 126
				} -- 126
			) then -- 126
				uiInkDraw:drawRect( -- 128
					Rect(sx, barY - 3, segW, 6), -- 128
					Color(0, 0, 0, 0), -- 128
					0.8, -- 128
					toColor(PALETTE.silkDim, 145 * alpha) -- 128
				) -- 128
			end -- 128
			if self.ghostHp > i and self.ghostHp > p.hp then -- 128
				local frac = math.min(1, self.ghostHp - i) -- 131
				uiInkDraw:drawRect( -- 132
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 132
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 132
				) -- 132
			end -- 132
			if p.hp > i then -- 132
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 135
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 136
				if not uiArt:tryPlace( -- 136
					"ink_bamboo_slip", -- 137
					"hp_fill_" .. tostring(i), -- 137
					scx, -- 137
					barY, -- 137
					segW, -- 137
					segH, -- 137
					{ -- 137
						color = toColor(fillCol), -- 138
						opacity = 0.94 * alpha * pulse, -- 138
						layer = 2 -- 138
					} -- 138
				) then -- 138
					uiInkDraw:drawRect( -- 140
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 140
						toColor(fillCol, 230 * alpha * pulse) -- 140
					) -- 140
				end -- 140
			end -- 140
			i = i + 1 -- 122
		end -- 122
	end -- 122
	local covX = barX + segCount * (segW + gap) + 6 -- 146
	if p.coverHug then -- 146
		uiInkDraw:drawRect( -- 148
			Rect(covX, barY - 9, 54, 18), -- 148
			toColor(PALETTE.cyanDim, 165 * alpha), -- 148
			0.8, -- 148
			toColor(PALETTE.cyanCore, 180 * alpha) -- 148
		) -- 148
		texts:put( -- 149
			"xs", -- 149
			"掩体中", -- 149
			covX + 27, -- 149
			barY, -- 149
			toColor(PALETTE.textBright), -- 149
			0.5, -- 149
			0.5, -- 149
			"Center", -- 149
			0.6, -- 149
			alpha, -- 149
			0 -- 149
		) -- 149
	elseif p.coverNear then -- 149
		uiInkDraw:drawRect( -- 151
			Rect(covX, barY - 9, 54, 18), -- 151
			Color( -- 151
				14, -- 151
				17, -- 151
				25, -- 151
				math.floor(150 * alpha + 0.5) -- 151
			), -- 151
			0.8, -- 151
			toColor(PALETTE.silkLine, 165 * alpha) -- 151
		) -- 151
		texts:put( -- 152
			"xs", -- 152
			"可贴靠", -- 152
			covX + 27, -- 152
			barY, -- 152
			toColor(PALETTE.textMid), -- 152
			0.5, -- 152
			0.5, -- 152
			"Center", -- 152
			0.6, -- 152
			alpha, -- 152
			0.08 -- 152
		) -- 152
	end -- 152
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 152
		local subY = by - 24 -- 157
		local frozen = p.escort.state == "frozen" -- 158
		local calming = p.escort.state == "calming" -- 159
		drawSilkVeil( -- 161
			uiDraw, -- 161
			uiArt, -- 161
			"hud_fear_veil", -- 161
			bx + 126, -- 161
			subY + 6, -- 161
			260, -- 161
			30, -- 161
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 161
			0.64 * alpha, -- 161
			-1 -- 161
		) -- 161
		texts:put( -- 162
			"xs", -- 162
			"小满 · 惊惧", -- 162
			bx + 14, -- 162
			subY + 6, -- 162
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 162
			0, -- 162
			0.5, -- 162
			"Left", -- 162
			1, -- 162
			alpha, -- 162
			0.08 -- 162
		) -- 162
		local k = 0 -- 164
		do -- 164
			k = 0 -- 165
			while k < FEAR_MAX do -- 165
				local dx = bx + 114 + k * 20 -- 166
				local dy = subY + 6 -- 167
				local lit = k < p.escort.fear -- 168
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 169
				uiArt:tryPlace( -- 170
					"ink_enso_fine", -- 170
					"fear_ring_" .. tostring(k), -- 170
					dx, -- 170
					dy, -- 170
					14, -- 170
					14, -- 170
					{ -- 170
						color = toColor(lit and dc or PALETTE.silkLine), -- 171
						opacity = (lit and 0.92 or 0.64) * alpha, -- 171
						layer = 2 -- 171
					} -- 171
				) -- 171
				if lit then -- 171
					drawBlossomDot( -- 174
						uiInkDraw, -- 174
						uiArt, -- 174
						"fear_dot_" .. tostring(k), -- 174
						dx, -- 174
						dy, -- 174
						10, -- 174
						dc, -- 174
						0.96 * alpha, -- 174
						3 -- 174
					) -- 174
				end -- 174
				k = k + 1 -- 165
			end -- 165
		end -- 165
		if frozen then -- 165
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 179
			drawSilkKeycap( -- 180
				uiInkDraw, -- 180
				texts, -- 180
				bx + 170, -- 180
				subY - 5, -- 180
				22, -- 180
				22, -- 180
				"E", -- 180
				PALETTE.rouge, -- 180
				alpha * pulse, -- 180
				true -- 180
			) -- 180
			texts:put( -- 181
				"xs", -- 181
				"轻敲安抚", -- 181
				bx + 198, -- 181
				subY + 6, -- 181
				toColor(PALETTE.crimsonCore), -- 181
				0, -- 181
				0.5, -- 181
				"Left", -- 181
				0.8, -- 181
				alpha * pulse, -- 181
				0.08 -- 181
			) -- 181
		elseif calming then -- 181
			texts:put( -- 183
				"xs", -- 183
				"轻敲安抚中", -- 183
				bx + 172, -- 183
				subY + 6, -- 183
				toColor(PALETTE.emerald), -- 183
				0, -- 183
				0.5, -- 183
				"Left", -- 183
				0.8, -- 183
				alpha, -- 183
				0.08 -- 183
			) -- 183
		end -- 183
	end -- 183
end -- 91
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 188
	local bx = 28 -- 197
	local by = h - 68 -- 198
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 199
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 200
	drawSilkVeil( -- 202
		uiDraw, -- 202
		uiArt, -- 202
		"hud_child_veil", -- 202
		bx + 144, -- 202
		by + 22, -- 202
		316, -- 202
		48, -- 202
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 202
		0.58 * alpha, -- 202
		-1 -- 202
	) -- 202
	texts:put( -- 203
		"md", -- 203
		alert and "危" or "满", -- 203
		bx + 16, -- 203
		by + 22, -- 203
		toColor(leadCol), -- 203
		0.5, -- 203
		0.5, -- 203
		"Center", -- 203
		0, -- 203
		alpha, -- 203
		0.1 -- 203
	) -- 203
	uiInkDraw:drawSegment( -- 204
		Vec2(bx + 32, by + 7), -- 204
		Vec2(bx + 32, by + 37), -- 204
		0.8, -- 204
		toColor(PALETTE.silkDim, 130 * alpha) -- 204
	) -- 204
	texts:put( -- 206
		"xs", -- 206
		"小满 · 潜行", -- 206
		bx + 44, -- 206
		by + 33, -- 206
		toColor(PALETTE.amberCore), -- 206
		0, -- 206
		0.5, -- 206
		"Left", -- 206
		1.4, -- 206
		alpha, -- 206
		0.08 -- 206
	) -- 206
	local posture = "轻步前行 · 保持隐蔽" -- 208
	local col = PALETTE.textMid -- 209
	if alert then -- 209
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 211
		col = PALETTE.crimsonCore -- 212
	elseif p.player.crouch then -- 212
		posture = "低姿伏行 · 匿迹于影" -- 214
		col = PALETTE.emerald -- 215
	elseif p.hasBottle then -- 215
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 217
		col = PALETTE.amberCore -- 218
	end -- 218
	texts:put( -- 220
		"xs", -- 220
		posture, -- 220
		bx + 44, -- 220
		by + 12, -- 220
		toColor(col), -- 220
		0, -- 220
		0.5, -- 220
		"Left", -- 220
		0.6, -- 220
		alpha, -- 220
		0.08 -- 220
	) -- 220
end -- 188
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 223
	local theme = themeOf(p.room.key) -- 232
	local rx = w - 32 -- 233
	local cy = h - 44 -- 234
	drawSilkVeil( -- 236
		uiDraw, -- 236
		uiArt, -- 236
		"hud_chap_veil", -- 236
		rx - 82, -- 236
		cy, -- 236
		240, -- 236
		44, -- 236
		PALETTE.inkWash, -- 236
		0.44 * alpha, -- 236
		-1 -- 236
	) -- 236
	texts:put( -- 237
		"xs", -- 237
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 237
		rx, -- 237
		cy + 9, -- 237
		toColor(PALETTE.textBright), -- 237
		1, -- 237
		0.5, -- 237
		"Right", -- 237
		1.2, -- 237
		alpha, -- 237
		0.08 -- 237
	) -- 237
	texts:put( -- 238
		"xs", -- 238
		"Esc 暂歇", -- 238
		rx, -- 238
		cy - 11, -- 238
		toColor(PALETTE.textDim), -- 238
		1, -- 238
		0.5, -- 238
		"Right", -- 238
		1, -- 238
		0.78 * alpha, -- 238
		0.08 -- 238
	) -- 238
end -- 223
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 241
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 241
		local g = p.room.story.gate -- 253
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 253
			local bw = 400 -- 255
			local cx = w * 0.5 -- 256
			local by = h - 64 -- 257
			local ratio = math.max( -- 258
				0, -- 258
				math.min( -- 258
					1, -- 258
					p.gateTick / math.max(1, g.holdTicks) -- 258
				) -- 258
			) -- 258
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 259
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 260
			drawSilkVeil( -- 262
				uiDraw, -- 262
				uiArt, -- 262
				"hud_gate_veil", -- 262
				cx, -- 262
				by + 18, -- 262
				bw + 90, -- 262
				48, -- 262
				PALETTE.inkWash, -- 262
				0.76 * alpha, -- 262
				-1 -- 262
			) -- 262
			drawHairline( -- 263
				uiInkDraw, -- 263
				uiArt, -- 263
				"hud_gate_top", -- 263
				cx, -- 263
				by + 39, -- 263
				bw - 20, -- 263
				PALETTE.rougeSoft, -- 263
				0.55 * alpha, -- 263
				false, -- 263
				2 -- 263
			) -- 263
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 265
			texts:put( -- 268
				"xs", -- 268
				label, -- 268
				cx, -- 268
				by + 26, -- 268
				toColor(PALETTE.textBright), -- 268
				0.5, -- 268
				0.5, -- 268
				"Center", -- 268
				1.8, -- 268
				alpha, -- 268
				0.08 -- 268
			) -- 268
			local pbw = bw - 80 -- 271
			local pbx = cx - pbw * 0.5 -- 272
			local pby = by + 9 -- 273
			uiInkDraw:drawSegment( -- 274
				Vec2(pbx, pby), -- 274
				Vec2(pbx + pbw, pby), -- 274
				1.4, -- 274
				toColor(PALETTE.silkDim, 115 * alpha) -- 274
			) -- 274
			if ratio > 0.002 then -- 274
				uiInkDraw:drawSegment( -- 276
					Vec2(pbx, pby), -- 276
					Vec2(pbx + pbw * ratio, pby), -- 276
					2.8, -- 276
					toColor(PALETTE.rouge, 230 * alpha) -- 276
				) -- 276
				uiInkDraw:drawSegment( -- 277
					Vec2(pbx, pby), -- 277
					Vec2(pbx + pbw * ratio, pby), -- 277
					1, -- 277
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 277
				) -- 277
			end -- 277
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 279
			local k = 0 -- 280
			do -- 280
				k = 0 -- 281
				while k < #waves do -- 281
					local wx = pbx + pbw * waves[k + 1] -- 282
					local passed = p.gateSpawned > k -- 283
					if passed then -- 283
						drawBlossomDot( -- 285
							uiInkDraw, -- 285
							uiArt, -- 285
							"gate_wave_" .. tostring(k), -- 285
							wx, -- 285
							pby, -- 285
							10, -- 285
							PALETTE.moonPale, -- 285
							0.92 * alpha, -- 285
							3 -- 285
						) -- 285
					else -- 285
						uiArt:tryPlace( -- 287
							"ink_enso_fine", -- 287
							"gate_wave_" .. tostring(k), -- 287
							wx, -- 287
							pby, -- 287
							11, -- 287
							11, -- 287
							{ -- 287
								color = toColor(PALETTE.rouge), -- 288
								opacity = 0.84 * alpha, -- 288
								layer = 3 -- 288
							} -- 288
						) -- 288
					end -- 288
					k = k + 1 -- 281
				end -- 281
			end -- 281
		end -- 281
		return -- 293
	end -- 293
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 293
		local cx = w * 0.5 -- 298
		local by = h - 44 -- 299
		local step1 = p.cartDocked -- 300
		local ____temp_0 -- 301
		if p.room.key == "checkpoint" then -- 301
			____temp_0 = p.gateOpen -- 301
		else -- 301
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 301
		end -- 301
		local step2 = ____temp_0 -- 301
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 302
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 303
		drawSilkVeil( -- 305
			uiDraw, -- 305
			uiArt, -- 305
			"hud_obj_veil", -- 305
			cx, -- 305
			by, -- 305
			380, -- 305
			34, -- 305
			PALETTE.inkWash, -- 305
			0.58 * alpha, -- 305
			-1 -- 305
		) -- 305
		local x1 = cx - 134 -- 307
		if step1 then -- 307
			drawBlossomDot( -- 309
				uiInkDraw, -- 309
				uiArt, -- 309
				"obj_m1", -- 309
				x1, -- 309
				by, -- 309
				11, -- 309
				PALETTE.emerald, -- 309
				0.94 * alpha, -- 309
				3 -- 309
			) -- 309
		else -- 309
			uiArt:tryPlace( -- 311
				"ink_enso_fine", -- 311
				"obj_m1", -- 311
				x1, -- 311
				by, -- 311
				11, -- 311
				11, -- 311
				{ -- 311
					color = toColor(PALETTE.silkLine), -- 311
					opacity = 0.72 * alpha, -- 311
					layer = 3 -- 311
				} -- 311
			) -- 311
		end -- 311
		texts:put( -- 313
			"xs", -- 313
			t1, -- 313
			x1 + 13, -- 313
			by, -- 313
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 313
			0, -- 313
			0.5, -- 313
			"Left", -- 313
			1, -- 313
			alpha, -- 313
			0.08 -- 313
		) -- 313
		local x2 = cx + 18 -- 315
		if step2 then -- 315
			drawBlossomDot( -- 317
				uiInkDraw, -- 317
				uiArt, -- 317
				"obj_m2", -- 317
				x2, -- 317
				by, -- 317
				11, -- 317
				PALETTE.emerald, -- 317
				0.94 * alpha, -- 317
				3 -- 317
			) -- 317
		else -- 317
			uiArt:tryPlace( -- 319
				"ink_enso_fine", -- 319
				"obj_m2", -- 319
				x2, -- 319
				by, -- 319
				11, -- 319
				11, -- 319
				{ -- 319
					color = toColor(PALETTE.silkDim), -- 319
					opacity = 0.62 * alpha, -- 319
					layer = 3 -- 319
				} -- 319
			) -- 319
		end -- 319
		texts:put( -- 321
			"xs", -- 321
			t2, -- 321
			x2 + 13, -- 321
			by, -- 321
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 321
			0, -- 321
			0.5, -- 321
			"Left", -- 321
			1, -- 321
			alpha, -- 321
			0.08 -- 321
		) -- 321
	end -- 321
end -- 241
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 325
	local bob = math.sin(self.time * 3.4) * 2.8 -- 335
	local viewW = cam.viewW / uiScale -- 336
	local viewH = cam.viewH / uiScale -- 337
	local i = 0 -- 338
	do -- 338
		i = 0 -- 339
		while i < #prompts do -- 339
			local pr = prompts[i + 1] -- 340
			local keyW = math.max( -- 341
				24, -- 341
				visualTextWidth(pr.keyTag, 15) + 16 -- 341
			) -- 341
			local labelW = visualTextWidth(pr.label, 15) -- 342
			local pillW = keyW + labelW + 24 -- 343
			local padX = math.max(115, pillW * 0.5 + 24) -- 344
			local sx = math.max( -- 345
				padX, -- 345
				math.min( -- 345
					viewW - padX, -- 345
					cam:sx(pr.x) / uiScale -- 345
				) -- 345
			) -- 345
			local sy = math.max( -- 346
				96, -- 346
				math.min( -- 346
					viewH - 110, -- 346
					cam:sy(pr.y) / uiScale + bob -- 346
				) -- 346
			) -- 346
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 347
			uiInkDraw:drawSegment( -- 350
				Vec2(sx, sy - 14), -- 350
				Vec2(sx, sy - 27), -- 350
				0.8, -- 350
				toColor(accent, 135 * alpha) -- 350
			) -- 350
			drawBlossomDot( -- 351
				uiInkDraw, -- 351
				uiArt, -- 351
				"wp_anchor_" .. tostring(i), -- 351
				sx, -- 351
				sy - 28, -- 351
				7, -- 351
				accent, -- 351
				0.85 * alpha, -- 351
				3 -- 351
			) -- 351
			local px = sx - pillW * 0.5 -- 353
			local py = sy - 12 -- 354
			drawSilkVeil( -- 356
				uiDraw, -- 356
				uiArt, -- 356
				"wp_bg_" .. tostring(i), -- 356
				sx, -- 356
				py + 12, -- 356
				pillW + 40, -- 356
				32, -- 356
				PALETTE.inkWash, -- 356
				0.78 * alpha, -- 356
				0 -- 356
			) -- 356
			drawHairline( -- 357
				uiInkDraw, -- 357
				uiArt, -- 357
				"wp_line_" .. tostring(i), -- 357
				sx, -- 357
				py + 24, -- 357
				pillW + 4, -- 357
				accent, -- 357
				0.45 * alpha, -- 357
				false, -- 357
				2 -- 357
			) -- 357
			drawSilkKeycap( -- 358
				uiInkDraw, -- 358
				texts, -- 358
				px + 2, -- 358
				py + 2, -- 358
				keyW, -- 358
				20, -- 358
				pr.keyTag, -- 358
				accent, -- 358
				alpha, -- 358
				pr.urgent -- 358
			) -- 358
			texts:put( -- 359
				"xs", -- 359
				pr.label, -- 359
				px + keyW + 12, -- 359
				py + 12, -- 359
				toColor(PALETTE.textBright), -- 359
				0, -- 359
				0.5, -- 359
				"Left", -- 359
				0.8, -- 359
				alpha, -- 359
				0.08 -- 359
			) -- 359
			i = i + 1 -- 339
		end -- 339
	end -- 339
end -- 325
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 363
	local mx = p.aimX / uiScale -- 372
	local my = p.aimY / uiScale -- 373
	if mx <= 0 and my <= 0 then -- 373
		return -- 375
	end -- 375
	if p.childMode then -- 375
		local aiming = p.room.key == "village" and p.hasBottle -- 379
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 380
		uiInkDraw:drawDot( -- 381
			Vec2(mx, my), -- 381
			aiming and 2 or 1.6, -- 381
			toColor(col, aiming and 215 or 120) -- 381
		) -- 381
		if aiming then -- 381
			local sz = p.aimHold > 0 and 32 or 24 -- 383
			uiArt:tryPlace( -- 384
				"ink_enso_fine", -- 384
				"reticle_child", -- 384
				mx, -- 384
				my, -- 384
				sz, -- 384
				sz, -- 384
				{ -- 384
					color = toColor(PALETTE.amberCore), -- 385
					opacity = 0.82, -- 385
					angle = self.time * 24, -- 385
					layer = 5 -- 385
				} -- 385
			) -- 385
		end -- 385
		return -- 388
	end -- 388
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 391
	local onEnemy = false -- 392
	local i = 0 -- 393
	do -- 393
		i = 0 -- 394
		while i < #p.enemies do -- 394
			local e = p.enemies[i + 1] -- 395
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 395
				onEnemy = true -- 397
			end -- 397
			i = i + 1 -- 394
		end -- 394
	end -- 394
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 401
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 402
	local arm = onEnemy and 8.5 or 9.5 -- 403
	local bg = Color(10, 12, 18, 160) -- 404
	uiInkDraw:drawSegment( -- 406
		Vec2(mx - gap - arm, my), -- 406
		Vec2(mx - gap, my), -- 406
		2.1, -- 406
		bg -- 406
	) -- 406
	uiInkDraw:drawSegment( -- 407
		Vec2(mx + gap, my), -- 407
		Vec2(mx + gap + arm, my), -- 407
		2.1, -- 407
		bg -- 407
	) -- 407
	uiInkDraw:drawSegment( -- 408
		Vec2(mx, my - gap - arm), -- 408
		Vec2(mx, my - gap), -- 408
		2.1, -- 408
		bg -- 408
	) -- 408
	uiInkDraw:drawSegment( -- 409
		Vec2(mx, my + gap), -- 409
		Vec2(mx, my + gap + arm), -- 409
		2.1, -- 409
		bg -- 409
	) -- 409
	uiInkDraw:drawSegment( -- 411
		Vec2(mx - gap - arm, my), -- 411
		Vec2(mx - gap, my), -- 411
		1.1, -- 411
		toColor(col, 230) -- 411
	) -- 411
	uiInkDraw:drawSegment( -- 412
		Vec2(mx + gap, my), -- 412
		Vec2(mx + gap + arm, my), -- 412
		1.1, -- 412
		toColor(col, 230) -- 412
	) -- 412
	uiInkDraw:drawSegment( -- 413
		Vec2(mx, my - gap - arm), -- 413
		Vec2(mx, my - gap), -- 413
		1.1, -- 413
		toColor(col, 230) -- 413
	) -- 413
	uiInkDraw:drawSegment( -- 414
		Vec2(mx, my + gap), -- 414
		Vec2(mx, my + gap + arm), -- 414
		1.1, -- 414
		toColor(col, 230) -- 414
	) -- 414
	uiInkDraw:drawDot( -- 415
		Vec2(mx, my), -- 415
		1.8, -- 415
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 415
	) -- 415
	if onEnemy then -- 415
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 418
		uiArt:tryPlace( -- 419
			"ink_enso_fine", -- 419
			"reticle_lock", -- 419
			mx, -- 419
			my, -- 419
			sz, -- 419
			sz, -- 419
			{ -- 419
				color = toColor(PALETTE.rouge), -- 420
				opacity = 0.88, -- 420
				angle = self.time * 38, -- 420
				layer = 5 -- 420
			} -- 420
		) -- 420
		fillRadialGlow( -- 422
			uiGlow, -- 422
			mx, -- 422
			my, -- 422
			16, -- 422
			16, -- 422
			toColor(PALETTE.rouge, 30), -- 422
			Color(182, 58, 56, 0), -- 422
			10 -- 422
		) -- 422
	end -- 422
end -- 363
return ____exports -- 363