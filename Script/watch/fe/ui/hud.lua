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
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 266
			local bw = 400 -- 269
			local cx = w * 0.5 -- 270
			local by = h - 64 -- 271
			local tied = p.phase == "gate-hand" -- 272
			local ratio = tied and 1 or math.max( -- 273
				0, -- 273
				math.min( -- 273
					1, -- 273
					p.handTicks / math.max(1, p.handNeedTicks) -- 273
				) -- 273
			) -- 273
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 274
			drawSilkVeil( -- 278
				uiDraw, -- 278
				uiArt, -- 278
				"hud_hand_veil", -- 278
				cx, -- 278
				by + 18, -- 278
				bw + 90, -- 278
				48, -- 278
				PALETTE.inkWash, -- 278
				0.76 * alpha, -- 278
				-1 -- 278
			) -- 278
			drawHairline( -- 279
				uiInkDraw, -- 279
				uiArt, -- 279
				"hud_hand_top", -- 279
				cx, -- 279
				by + 39, -- 279
				bw - 20, -- 279
				PALETTE.amber, -- 279
				0.55 * alpha, -- 279
				false, -- 279
				2 -- 279
			) -- 279
			texts:put( -- 280
				"xs", -- 280
				label, -- 280
				cx, -- 280
				by + 26, -- 280
				toColor(PALETTE.textBright), -- 280
				0.5, -- 280
				0.5, -- 280
				"Center", -- 280
				1.8, -- 280
				alpha, -- 280
				0.08 -- 280
			) -- 280
			local pbw = bw - 80 -- 282
			local pbx = cx - pbw * 0.5 -- 283
			local pby = by + 9 -- 284
			uiInkDraw:drawSegment( -- 285
				Vec2(pbx, pby), -- 285
				Vec2(pbx + pbw, pby), -- 285
				1.4, -- 285
				toColor(PALETTE.silkDim, 115 * alpha) -- 285
			) -- 285
			if ratio > 0.002 then -- 285
				uiInkDraw:drawSegment( -- 287
					Vec2(pbx, pby), -- 287
					Vec2(pbx + pbw * ratio, pby), -- 287
					2.8, -- 287
					toColor(PALETTE.amber, 230 * alpha) -- 287
				) -- 287
				uiInkDraw:drawSegment( -- 288
					Vec2(pbx, pby), -- 288
					Vec2(pbx + pbw * ratio, pby), -- 288
					1, -- 288
					toColor(PALETTE.amberCore, 165 * alpha) -- 288
				) -- 288
			end -- 288
			uiArt:tryPlace( -- 291
				"ink_enso_fine", -- 291
				"hand_knock_1", -- 291
				pbx + pbw * 0.62, -- 291
				pby, -- 291
				11, -- 291
				11, -- 291
				{ -- 291
					color = toColor(PALETTE.amber), -- 292
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 292
					layer = 3 -- 292
				} -- 292
			) -- 292
			uiArt:tryPlace( -- 294
				"ink_enso_fine", -- 294
				"hand_knock_2", -- 294
				pbx + pbw * 0.72, -- 294
				pby, -- 294
				11, -- 294
				11, -- 294
				{ -- 294
					color = toColor(PALETTE.amber), -- 295
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 295
					layer = 3 -- 295
				} -- 295
			) -- 295
		end -- 295
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 295
			local bw = 400 -- 299
			local cx = w * 0.5 -- 300
			local by = h - 64 -- 301
			local ratio = math.max( -- 302
				0, -- 302
				math.min( -- 302
					1, -- 302
					p.gateTick / math.max(1, g.holdTicks) -- 302
				) -- 302
			) -- 302
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 303
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 304
			drawSilkVeil( -- 306
				uiDraw, -- 306
				uiArt, -- 306
				"hud_gate_veil", -- 306
				cx, -- 306
				by + 18, -- 306
				bw + 90, -- 306
				48, -- 306
				PALETTE.inkWash, -- 306
				0.76 * alpha, -- 306
				-1 -- 306
			) -- 306
			drawHairline( -- 307
				uiInkDraw, -- 307
				uiArt, -- 307
				"hud_gate_top", -- 307
				cx, -- 307
				by + 39, -- 307
				bw - 20, -- 307
				PALETTE.rougeSoft, -- 307
				0.55 * alpha, -- 307
				false, -- 307
				2 -- 307
			) -- 307
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 309
			texts:put( -- 312
				"xs", -- 312
				label, -- 312
				cx, -- 312
				by + 26, -- 312
				toColor(PALETTE.textBright), -- 312
				0.5, -- 312
				0.5, -- 312
				"Center", -- 312
				1.8, -- 312
				alpha, -- 312
				0.08 -- 312
			) -- 312
			local pbw = bw - 80 -- 315
			local pbx = cx - pbw * 0.5 -- 316
			local pby = by + 9 -- 317
			uiInkDraw:drawSegment( -- 318
				Vec2(pbx, pby), -- 318
				Vec2(pbx + pbw, pby), -- 318
				1.4, -- 318
				toColor(PALETTE.silkDim, 115 * alpha) -- 318
			) -- 318
			if ratio > 0.002 then -- 318
				uiInkDraw:drawSegment( -- 320
					Vec2(pbx, pby), -- 320
					Vec2(pbx + pbw * ratio, pby), -- 320
					2.8, -- 320
					toColor(PALETTE.rouge, 230 * alpha) -- 320
				) -- 320
				uiInkDraw:drawSegment( -- 321
					Vec2(pbx, pby), -- 321
					Vec2(pbx + pbw * ratio, pby), -- 321
					1, -- 321
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 321
				) -- 321
			end -- 321
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 323
			local k = 0 -- 324
			do -- 324
				k = 0 -- 325
				while k < #waves do -- 325
					local wx = pbx + pbw * waves[k + 1] -- 326
					local passed = p.gateSpawned > k -- 327
					if passed then -- 327
						drawBlossomDot( -- 329
							uiInkDraw, -- 329
							uiArt, -- 329
							"gate_wave_" .. tostring(k), -- 329
							wx, -- 329
							pby, -- 329
							10, -- 329
							PALETTE.moonPale, -- 329
							0.92 * alpha, -- 329
							3 -- 329
						) -- 329
					else -- 329
						uiArt:tryPlace( -- 331
							"ink_enso_fine", -- 331
							"gate_wave_" .. tostring(k), -- 331
							wx, -- 331
							pby, -- 331
							11, -- 331
							11, -- 331
							{ -- 331
								color = toColor(PALETTE.rouge), -- 332
								opacity = 0.84 * alpha, -- 332
								layer = 3 -- 332
							} -- 332
						) -- 332
					end -- 332
					k = k + 1 -- 325
				end -- 325
			end -- 325
		end -- 325
		return -- 337
	end -- 337
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 337
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
end -- 254
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