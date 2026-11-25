-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
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
	if p.reloadOpen then -- 254
		local bw = 400 -- 266
		local cx = w * 0.5 -- 267
		local by = h - 64 -- 268
		local ratio = math.max( -- 269
			0, -- 269
			math.min(1, p.reloadAnswerTicks / 240) -- 269
		) -- 269
		local effect = p.reloadPendingEffect -- 270
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 271
		drawSilkVeil( -- 274
			uiDraw, -- 274
			uiArt, -- 274
			"hud_reload_veil", -- 274
			cx, -- 274
			by + 18, -- 274
			bw + 90, -- 274
			48, -- 274
			PALETTE.inkWash, -- 274
			0.76 * alpha, -- 274
			-1 -- 274
		) -- 274
		drawHairline( -- 275
			uiInkDraw, -- 275
			uiArt, -- 275
			"hud_reload_top", -- 275
			cx, -- 275
			by + 39, -- 275
			bw - 20, -- 275
			PALETTE.cyan, -- 275
			0.55 * alpha, -- 275
			false, -- 275
			2 -- 275
		) -- 275
		texts:put( -- 276
			"xs", -- 276
			label, -- 276
			cx, -- 276
			by + 26, -- 276
			toColor(PALETTE.textBright), -- 276
			0.5, -- 276
			0.5, -- 276
			"Center", -- 276
			1.8, -- 276
			alpha, -- 276
			0.08 -- 276
		) -- 276
		do -- 276
			local n = 0 -- 279
			while n < 9 do -- 279
				local col = n % 3 -- 280
				local row = math.floor(n / 3) -- 281
				local nx = cx + (col - 1) * 13 -- 282
				local ny = by + 50 + row * 12 -- 283
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 284
				local isEnd = n == 8 -- 285
				uiArt:tryPlace( -- 286
					"ink_enso_fine", -- 286
					"reload_node_" .. tostring(n), -- 286
					nx, -- 286
					ny, -- 286
					isEnd and 10 or 6, -- 286
					isEnd and 10 or 6, -- 286
					{ -- 286
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 287
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 288
						layer = 3 -- 288
					} -- 288
				) -- 288
				n = n + 1 -- 279
			end -- 279
		end -- 279
		local pbw = bw - 80 -- 292
		local pbx = cx - pbw * 0.5 -- 293
		local pby = by + 9 -- 294
		uiInkDraw:drawSegment( -- 295
			Vec2(pbx, pby), -- 295
			Vec2(pbx + pbw, pby), -- 295
			1.4, -- 295
			toColor(PALETTE.silkDim, 115 * alpha) -- 295
		) -- 295
		if ratio > 0.002 then -- 295
			uiInkDraw:drawSegment( -- 297
				Vec2(pbx, pby), -- 297
				Vec2(pbx + pbw * ratio, pby), -- 297
				2.8, -- 297
				toColor(PALETTE.cyan, 220 * alpha) -- 297
			) -- 297
			uiInkDraw:drawSegment( -- 298
				Vec2(pbx, pby), -- 298
				Vec2(pbx + pbw * ratio, pby), -- 298
				1, -- 298
				toColor(PALETTE.cyanCore, 160 * alpha) -- 298
			) -- 298
		end -- 298
	end -- 298
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 298
		local g = p.room.story.gate -- 304
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 304
			local bw = 400 -- 307
			local cx = w * 0.5 -- 308
			local by = h - 64 -- 309
			local tied = p.phase == "gate-hand" -- 310
			local ratio = tied and 1 or math.max( -- 311
				0, -- 311
				math.min( -- 311
					1, -- 311
					p.handTicks / math.max(1, p.handNeedTicks) -- 311
				) -- 311
			) -- 311
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 312
			drawSilkVeil( -- 316
				uiDraw, -- 316
				uiArt, -- 316
				"hud_hand_veil", -- 316
				cx, -- 316
				by + 18, -- 316
				bw + 90, -- 316
				48, -- 316
				PALETTE.inkWash, -- 316
				0.76 * alpha, -- 316
				-1 -- 316
			) -- 316
			drawHairline( -- 317
				uiInkDraw, -- 317
				uiArt, -- 317
				"hud_hand_top", -- 317
				cx, -- 317
				by + 39, -- 317
				bw - 20, -- 317
				PALETTE.amber, -- 317
				0.55 * alpha, -- 317
				false, -- 317
				2 -- 317
			) -- 317
			texts:put( -- 318
				"xs", -- 318
				label, -- 318
				cx, -- 318
				by + 26, -- 318
				toColor(PALETTE.textBright), -- 318
				0.5, -- 318
				0.5, -- 318
				"Center", -- 318
				1.8, -- 318
				alpha, -- 318
				0.08 -- 318
			) -- 318
			local pbw = bw - 80 -- 320
			local pbx = cx - pbw * 0.5 -- 321
			local pby = by + 9 -- 322
			uiInkDraw:drawSegment( -- 323
				Vec2(pbx, pby), -- 323
				Vec2(pbx + pbw, pby), -- 323
				1.4, -- 323
				toColor(PALETTE.silkDim, 115 * alpha) -- 323
			) -- 323
			if ratio > 0.002 then -- 323
				uiInkDraw:drawSegment( -- 325
					Vec2(pbx, pby), -- 325
					Vec2(pbx + pbw * ratio, pby), -- 325
					2.8, -- 325
					toColor(PALETTE.amber, 230 * alpha) -- 325
				) -- 325
				uiInkDraw:drawSegment( -- 326
					Vec2(pbx, pby), -- 326
					Vec2(pbx + pbw * ratio, pby), -- 326
					1, -- 326
					toColor(PALETTE.amberCore, 165 * alpha) -- 326
				) -- 326
			end -- 326
			uiArt:tryPlace( -- 329
				"ink_enso_fine", -- 329
				"hand_knock_1", -- 329
				pbx + pbw * 0.62, -- 329
				pby, -- 329
				11, -- 329
				11, -- 329
				{ -- 329
					color = toColor(PALETTE.amber), -- 330
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 330
					layer = 3 -- 330
				} -- 330
			) -- 330
			uiArt:tryPlace( -- 332
				"ink_enso_fine", -- 332
				"hand_knock_2", -- 332
				pbx + pbw * 0.72, -- 332
				pby, -- 332
				11, -- 332
				11, -- 332
				{ -- 332
					color = toColor(PALETTE.amber), -- 333
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 333
					layer = 3 -- 333
				} -- 333
			) -- 333
		end -- 333
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 333
			local bw = 400 -- 337
			local cx = w * 0.5 -- 338
			local by = h - 64 -- 339
			local ratio = math.max( -- 340
				0, -- 340
				math.min( -- 340
					1, -- 340
					p.gateTick / math.max(1, g.holdTicks) -- 340
				) -- 340
			) -- 340
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 341
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 342
			drawSilkVeil( -- 344
				uiDraw, -- 344
				uiArt, -- 344
				"hud_gate_veil", -- 344
				cx, -- 344
				by + 18, -- 344
				bw + 90, -- 344
				48, -- 344
				PALETTE.inkWash, -- 344
				0.76 * alpha, -- 344
				-1 -- 344
			) -- 344
			drawHairline( -- 345
				uiInkDraw, -- 345
				uiArt, -- 345
				"hud_gate_top", -- 345
				cx, -- 345
				by + 39, -- 345
				bw - 20, -- 345
				PALETTE.rougeSoft, -- 345
				0.55 * alpha, -- 345
				false, -- 345
				2 -- 345
			) -- 345
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 347
			texts:put( -- 350
				"xs", -- 350
				label, -- 350
				cx, -- 350
				by + 26, -- 350
				toColor(PALETTE.textBright), -- 350
				0.5, -- 350
				0.5, -- 350
				"Center", -- 350
				1.8, -- 350
				alpha, -- 350
				0.08 -- 350
			) -- 350
			local pbw = bw - 80 -- 353
			local pbx = cx - pbw * 0.5 -- 354
			local pby = by + 9 -- 355
			uiInkDraw:drawSegment( -- 356
				Vec2(pbx, pby), -- 356
				Vec2(pbx + pbw, pby), -- 356
				1.4, -- 356
				toColor(PALETTE.silkDim, 115 * alpha) -- 356
			) -- 356
			if ratio > 0.002 then -- 356
				uiInkDraw:drawSegment( -- 358
					Vec2(pbx, pby), -- 358
					Vec2(pbx + pbw * ratio, pby), -- 358
					2.8, -- 358
					toColor(PALETTE.rouge, 230 * alpha) -- 358
				) -- 358
				uiInkDraw:drawSegment( -- 359
					Vec2(pbx, pby), -- 359
					Vec2(pbx + pbw * ratio, pby), -- 359
					1, -- 359
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 359
				) -- 359
			end -- 359
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 361
			local k = 0 -- 362
			do -- 362
				k = 0 -- 363
				while k < #waves do -- 363
					local wx = pbx + pbw * waves[k + 1] -- 364
					local passed = p.gateSpawned > k -- 365
					if passed then -- 365
						drawBlossomDot( -- 367
							uiInkDraw, -- 367
							uiArt, -- 367
							"gate_wave_" .. tostring(k), -- 367
							wx, -- 367
							pby, -- 367
							10, -- 367
							PALETTE.moonPale, -- 367
							0.92 * alpha, -- 367
							3 -- 367
						) -- 367
					else -- 367
						uiArt:tryPlace( -- 369
							"ink_enso_fine", -- 369
							"gate_wave_" .. tostring(k), -- 369
							wx, -- 369
							pby, -- 369
							11, -- 369
							11, -- 369
							{ -- 369
								color = toColor(PALETTE.rouge), -- 370
								opacity = 0.84 * alpha, -- 370
								layer = 3 -- 370
							} -- 370
						) -- 370
					end -- 370
					k = k + 1 -- 363
				end -- 363
			end -- 363
		end -- 363
		return -- 375
	end -- 375
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 375
		local cx = w * 0.5 -- 380
		local by = h - 44 -- 381
		local step1 = p.cartDocked -- 382
		local ____temp_0 -- 383
		if p.room.key == "checkpoint" then -- 383
			____temp_0 = p.gateOpen -- 383
		else -- 383
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 383
		end -- 383
		local step2 = ____temp_0 -- 383
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 384
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 385
		drawSilkVeil( -- 387
			uiDraw, -- 387
			uiArt, -- 387
			"hud_obj_veil", -- 387
			cx, -- 387
			by, -- 387
			380, -- 387
			34, -- 387
			PALETTE.inkWash, -- 387
			0.58 * alpha, -- 387
			-1 -- 387
		) -- 387
		local x1 = cx - 134 -- 389
		if step1 then -- 389
			drawBlossomDot( -- 391
				uiInkDraw, -- 391
				uiArt, -- 391
				"obj_m1", -- 391
				x1, -- 391
				by, -- 391
				11, -- 391
				PALETTE.emerald, -- 391
				0.94 * alpha, -- 391
				3 -- 391
			) -- 391
		else -- 391
			uiArt:tryPlace( -- 393
				"ink_enso_fine", -- 393
				"obj_m1", -- 393
				x1, -- 393
				by, -- 393
				11, -- 393
				11, -- 393
				{ -- 393
					color = toColor(PALETTE.silkLine), -- 393
					opacity = 0.72 * alpha, -- 393
					layer = 3 -- 393
				} -- 393
			) -- 393
		end -- 393
		texts:put( -- 395
			"xs", -- 395
			t1, -- 395
			x1 + 13, -- 395
			by, -- 395
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 395
			0, -- 395
			0.5, -- 395
			"Left", -- 395
			1, -- 395
			alpha, -- 395
			0.08 -- 395
		) -- 395
		local x2 = cx + 18 -- 397
		if step2 then -- 397
			drawBlossomDot( -- 399
				uiInkDraw, -- 399
				uiArt, -- 399
				"obj_m2", -- 399
				x2, -- 399
				by, -- 399
				11, -- 399
				PALETTE.emerald, -- 399
				0.94 * alpha, -- 399
				3 -- 399
			) -- 399
		else -- 399
			uiArt:tryPlace( -- 401
				"ink_enso_fine", -- 401
				"obj_m2", -- 401
				x2, -- 401
				by, -- 401
				11, -- 401
				11, -- 401
				{ -- 401
					color = toColor(PALETTE.silkDim), -- 401
					opacity = 0.62 * alpha, -- 401
					layer = 3 -- 401
				} -- 401
			) -- 401
		end -- 401
		texts:put( -- 403
			"xs", -- 403
			t2, -- 403
			x2 + 13, -- 403
			by, -- 403
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 403
			0, -- 403
			0.5, -- 403
			"Left", -- 403
			1, -- 403
			alpha, -- 403
			0.08 -- 403
		) -- 403
	end -- 403
end -- 254
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 407
	local bob = math.sin(self.time * 3.4) * 2.8 -- 417
	local viewW = cam.viewW / uiScale -- 418
	local viewH = cam.viewH / uiScale -- 419
	local i = 0 -- 420
	do -- 420
		i = 0 -- 421
		while i < #prompts do -- 421
			local pr = prompts[i + 1] -- 422
			local keyW = math.max( -- 423
				24, -- 423
				visualTextWidth(pr.keyTag, 15) + 16 -- 423
			) -- 423
			local labelW = visualTextWidth(pr.label, 15) -- 424
			local pillW = keyW + labelW + 24 -- 425
			local padX = math.max(115, pillW * 0.5 + 24) -- 426
			local sx = math.max( -- 427
				padX, -- 427
				math.min( -- 427
					viewW - padX, -- 427
					cam:sx(pr.x) / uiScale -- 427
				) -- 427
			) -- 427
			local sy = math.max( -- 428
				96, -- 428
				math.min( -- 428
					viewH - 110, -- 428
					cam:sy(pr.y) / uiScale + bob -- 428
				) -- 428
			) -- 428
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 429
			uiInkDraw:drawSegment( -- 432
				Vec2(sx, sy - 14), -- 432
				Vec2(sx, sy - 27), -- 432
				0.8, -- 432
				toColor(accent, 135 * alpha) -- 432
			) -- 432
			drawBlossomDot( -- 433
				uiInkDraw, -- 433
				uiArt, -- 433
				"wp_anchor_" .. tostring(i), -- 433
				sx, -- 433
				sy - 28, -- 433
				7, -- 433
				accent, -- 433
				0.85 * alpha, -- 433
				3 -- 433
			) -- 433
			local px = sx - pillW * 0.5 -- 435
			local py = sy - 12 -- 436
			drawSilkVeil( -- 438
				uiDraw, -- 438
				uiArt, -- 438
				"wp_bg_" .. tostring(i), -- 438
				sx, -- 438
				py + 12, -- 438
				pillW + 40, -- 438
				32, -- 438
				PALETTE.inkWash, -- 438
				0.78 * alpha, -- 438
				0 -- 438
			) -- 438
			drawHairline( -- 439
				uiInkDraw, -- 439
				uiArt, -- 439
				"wp_line_" .. tostring(i), -- 439
				sx, -- 439
				py + 24, -- 439
				pillW + 4, -- 439
				accent, -- 439
				0.45 * alpha, -- 439
				false, -- 439
				2 -- 439
			) -- 439
			drawSilkKeycap( -- 440
				uiInkDraw, -- 440
				texts, -- 440
				px + 2, -- 440
				py + 2, -- 440
				keyW, -- 440
				20, -- 440
				pr.keyTag, -- 440
				accent, -- 440
				alpha, -- 440
				pr.urgent -- 440
			) -- 440
			texts:put( -- 441
				"xs", -- 441
				pr.label, -- 441
				px + keyW + 12, -- 441
				py + 12, -- 441
				toColor(PALETTE.textBright), -- 441
				0, -- 441
				0.5, -- 441
				"Left", -- 441
				0.8, -- 441
				alpha, -- 441
				0.08 -- 441
			) -- 441
			i = i + 1 -- 421
		end -- 421
	end -- 421
end -- 407
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 445
	local mx = p.aimX / uiScale -- 454
	local my = p.aimY / uiScale -- 455
	if mx <= 0 and my <= 0 then -- 455
		return -- 457
	end -- 457
	if p.childMode then -- 457
		local aiming = p.room.key == "village" and p.hasBottle -- 461
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 462
		uiInkDraw:drawDot( -- 463
			Vec2(mx, my), -- 463
			aiming and 2 or 1.6, -- 463
			toColor(col, aiming and 215 or 120) -- 463
		) -- 463
		if aiming then -- 463
			local sz = p.aimHold > 0 and 32 or 24 -- 465
			uiArt:tryPlace( -- 466
				"ink_enso_fine", -- 466
				"reticle_child", -- 466
				mx, -- 466
				my, -- 466
				sz, -- 466
				sz, -- 466
				{ -- 466
					color = toColor(PALETTE.amberCore), -- 467
					opacity = 0.82, -- 467
					angle = self.time * 24, -- 467
					layer = 5 -- 467
				} -- 467
			) -- 467
		end -- 467
		return -- 470
	end -- 470
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 473
	local onEnemy = false -- 474
	local i = 0 -- 475
	do -- 475
		i = 0 -- 476
		while i < #p.enemies do -- 476
			local e = p.enemies[i + 1] -- 477
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 477
				onEnemy = true -- 479
			end -- 479
			i = i + 1 -- 476
		end -- 476
	end -- 476
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 483
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 484
	local arm = onEnemy and 8.5 or 9.5 -- 485
	local bg = Color(10, 12, 18, 160) -- 486
	uiInkDraw:drawSegment( -- 488
		Vec2(mx - gap - arm, my), -- 488
		Vec2(mx - gap, my), -- 488
		2.1, -- 488
		bg -- 488
	) -- 488
	uiInkDraw:drawSegment( -- 489
		Vec2(mx + gap, my), -- 489
		Vec2(mx + gap + arm, my), -- 489
		2.1, -- 489
		bg -- 489
	) -- 489
	uiInkDraw:drawSegment( -- 490
		Vec2(mx, my - gap - arm), -- 490
		Vec2(mx, my - gap), -- 490
		2.1, -- 490
		bg -- 490
	) -- 490
	uiInkDraw:drawSegment( -- 491
		Vec2(mx, my + gap), -- 491
		Vec2(mx, my + gap + arm), -- 491
		2.1, -- 491
		bg -- 491
	) -- 491
	uiInkDraw:drawSegment( -- 493
		Vec2(mx - gap - arm, my), -- 493
		Vec2(mx - gap, my), -- 493
		1.1, -- 493
		toColor(col, 230) -- 493
	) -- 493
	uiInkDraw:drawSegment( -- 494
		Vec2(mx + gap, my), -- 494
		Vec2(mx + gap + arm, my), -- 494
		1.1, -- 494
		toColor(col, 230) -- 494
	) -- 494
	uiInkDraw:drawSegment( -- 495
		Vec2(mx, my - gap - arm), -- 495
		Vec2(mx, my - gap), -- 495
		1.1, -- 495
		toColor(col, 230) -- 495
	) -- 495
	uiInkDraw:drawSegment( -- 496
		Vec2(mx, my + gap), -- 496
		Vec2(mx, my + gap + arm), -- 496
		1.1, -- 496
		toColor(col, 230) -- 496
	) -- 496
	uiInkDraw:drawDot( -- 497
		Vec2(mx, my), -- 497
		1.8, -- 497
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 497
	) -- 497
	if onEnemy then -- 497
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 500
		uiArt:tryPlace( -- 501
			"ink_enso_fine", -- 501
			"reticle_lock", -- 501
			mx, -- 501
			my, -- 501
			sz, -- 501
			sz, -- 501
			{ -- 501
				color = toColor(PALETTE.rouge), -- 502
				opacity = 0.88, -- 502
				angle = self.time * 38, -- 502
				layer = 5 -- 502
			} -- 502
		) -- 502
		fillRadialGlow( -- 504
			uiGlow, -- 504
			mx, -- 504
			my, -- 504
			16, -- 504
			16, -- 504
			toColor(PALETTE.rouge, 30), -- 504
			Color(182, 58, 56, 0), -- 504
			10 -- 504
		) -- 504
	end -- 504
end -- 445
return ____exports -- 445