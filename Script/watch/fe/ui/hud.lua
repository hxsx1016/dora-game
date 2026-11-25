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
	if p.craftBench.active then -- 254
		local bw = 470 -- 267
		local cx = w * 0.5 -- 268
		local top = h * 0.32 -- 269
		drawSilkVeil( -- 270
			uiDraw, -- 270
			uiArt, -- 270
			"hud_bench_veil", -- 270
			cx, -- 270
			top + 118, -- 270
			bw + 64, -- 270
			208, -- 270
			PALETTE.inkWash, -- 270
			0.86 * alpha, -- 270
			-1 -- 270
		) -- 270
		texts:put( -- 271
			"xs", -- 271
			"工台 · 放她下来做一件", -- 271
			cx, -- 271
			top - 6, -- 271
			toColor(PALETTE.textBright), -- 271
			0.5, -- 271
			0.5, -- 271
			"Center", -- 271
			1.7, -- 271
			alpha, -- 271
			0.08 -- 271
		) -- 271
		local inv = p.craftBench.inventory -- 272
		local wood = inv.wood or 0 -- 273
		local bell = inv.bell or 0 -- 274
		local scrap = inv.scrap or 0 -- 275
		texts:put( -- 276
			"xs", -- 276
			(((("木纹筹 " .. tostring(wood)) .. " · 铃纹筹 ") .. tostring(bell)) .. " · 碎片 ") .. tostring(scrap), -- 276
			cx, -- 276
			top + 24, -- 276
			toColor(PALETTE.silkDim), -- 277
			0.5, -- 277
			0.5, -- 277
			"Center", -- 277
			1.5, -- 277
			alpha, -- 277
			0.08 -- 277
		) -- 277
		local recipes = p.craftBench.recipes -- 278
		do -- 278
			local i = 0 -- 279
			while i < #recipes do -- 279
				local r = recipes[i + 1] -- 280
				local costText = "" -- 281
				local afford = true -- 282
				local costWood = r.cost.wood or 0 -- 283
				local costBell = r.cost.bell or 0 -- 284
				if costWood > 0 then -- 284
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "木 ") .. tostring(costWood) -- 286
					if wood < costWood then -- 286
						afford = false -- 288
					end -- 288
				end -- 288
				if costBell > 0 then -- 288
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "铃 ") .. tostring(costBell) -- 292
					if bell < costBell then -- 292
						afford = false -- 294
					end -- 294
				end -- 294
				local equipped = p.craftBench.equippedWeapon == r.id -- 297
				local state = r.crafted and "已做成" or (afford and "可制作" or "缺料") -- 298
				local mark = equipped and " ◈" or "" -- 299
				texts:put( -- 300
					"xs", -- 300
					((((r.name .. " · ") .. costText) .. " · ") .. state) .. mark, -- 300
					cx, -- 300
					top + 56 + i * 26, -- 300
					toColor(equipped and PALETTE.cyanCore or (r.crafted and PALETTE.silkDim or PALETTE.textBright)), -- 301
					0.5, -- 302
					0.5, -- 302
					"Center", -- 302
					1.6, -- 302
					alpha, -- 302
					0.08 -- 302
				) -- 302
				i = i + 1 -- 279
			end -- 279
		end -- 279
		local firstMade = p.craftBench.firstCraftDone and " · 首制完成" or "" -- 304
		texts:put( -- 305
			"xs", -- 305
			"E 制作 · Q 装备 · Esc 离开" .. firstMade, -- 305
			cx, -- 305
			top + 128, -- 305
			toColor(PALETTE.amber), -- 306
			0.5, -- 306
			0.5, -- 306
			"Center", -- 306
			1.5, -- 306
			alpha, -- 306
			0.06 -- 306
		) -- 306
	end -- 306
	if p.reloadOpen then -- 306
		local bw = 400 -- 310
		local cx = w * 0.5 -- 311
		local by = h - 64 -- 312
		local ratio = math.max( -- 313
			0, -- 313
			math.min(1, p.reloadAnswerTicks / 240) -- 313
		) -- 313
		local effect = p.reloadPendingEffect -- 314
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 315
		drawSilkVeil( -- 318
			uiDraw, -- 318
			uiArt, -- 318
			"hud_reload_veil", -- 318
			cx, -- 318
			by + 18, -- 318
			bw + 90, -- 318
			48, -- 318
			PALETTE.inkWash, -- 318
			0.76 * alpha, -- 318
			-1 -- 318
		) -- 318
		drawHairline( -- 319
			uiInkDraw, -- 319
			uiArt, -- 319
			"hud_reload_top", -- 319
			cx, -- 319
			by + 39, -- 319
			bw - 20, -- 319
			PALETTE.cyan, -- 319
			0.55 * alpha, -- 319
			false, -- 319
			2 -- 319
		) -- 319
		texts:put( -- 320
			"xs", -- 320
			label, -- 320
			cx, -- 320
			by + 26, -- 320
			toColor(PALETTE.textBright), -- 320
			0.5, -- 320
			0.5, -- 320
			"Center", -- 320
			1.8, -- 320
			alpha, -- 320
			0.08 -- 320
		) -- 320
		do -- 320
			local n = 0 -- 323
			while n < 9 do -- 323
				local col = n % 3 -- 324
				local row = math.floor(n / 3) -- 325
				local nx = cx + (col - 1) * 13 -- 326
				local ny = by + 50 + row * 12 -- 327
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 328
				local isEnd = n == 8 -- 329
				uiArt:tryPlace( -- 330
					"ink_enso_fine", -- 330
					"reload_node_" .. tostring(n), -- 330
					nx, -- 330
					ny, -- 330
					isEnd and 10 or 6, -- 330
					isEnd and 10 or 6, -- 330
					{ -- 330
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 331
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 332
						layer = 3 -- 332
					} -- 332
				) -- 332
				n = n + 1 -- 323
			end -- 323
		end -- 323
		local pbw = bw - 80 -- 336
		local pbx = cx - pbw * 0.5 -- 337
		local pby = by + 9 -- 338
		uiInkDraw:drawSegment( -- 339
			Vec2(pbx, pby), -- 339
			Vec2(pbx + pbw, pby), -- 339
			1.4, -- 339
			toColor(PALETTE.silkDim, 115 * alpha) -- 339
		) -- 339
		if ratio > 0.002 then -- 339
			uiInkDraw:drawSegment( -- 341
				Vec2(pbx, pby), -- 341
				Vec2(pbx + pbw * ratio, pby), -- 341
				2.8, -- 341
				toColor(PALETTE.cyan, 220 * alpha) -- 341
			) -- 341
			uiInkDraw:drawSegment( -- 342
				Vec2(pbx, pby), -- 342
				Vec2(pbx + pbw * ratio, pby), -- 342
				1, -- 342
				toColor(PALETTE.cyanCore, 160 * alpha) -- 342
			) -- 342
		end -- 342
	end -- 342
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 342
		local g = p.room.story.gate -- 348
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 348
			local bw = 400 -- 351
			local cx = w * 0.5 -- 352
			local by = h - 64 -- 353
			local tied = p.phase == "gate-hand" -- 354
			local ratio = tied and 1 or math.max( -- 355
				0, -- 355
				math.min( -- 355
					1, -- 355
					p.handTicks / math.max(1, p.handNeedTicks) -- 355
				) -- 355
			) -- 355
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 356
			drawSilkVeil( -- 360
				uiDraw, -- 360
				uiArt, -- 360
				"hud_hand_veil", -- 360
				cx, -- 360
				by + 18, -- 360
				bw + 90, -- 360
				48, -- 360
				PALETTE.inkWash, -- 360
				0.76 * alpha, -- 360
				-1 -- 360
			) -- 360
			drawHairline( -- 361
				uiInkDraw, -- 361
				uiArt, -- 361
				"hud_hand_top", -- 361
				cx, -- 361
				by + 39, -- 361
				bw - 20, -- 361
				PALETTE.amber, -- 361
				0.55 * alpha, -- 361
				false, -- 361
				2 -- 361
			) -- 361
			texts:put( -- 362
				"xs", -- 362
				label, -- 362
				cx, -- 362
				by + 26, -- 362
				toColor(PALETTE.textBright), -- 362
				0.5, -- 362
				0.5, -- 362
				"Center", -- 362
				1.8, -- 362
				alpha, -- 362
				0.08 -- 362
			) -- 362
			local pbw = bw - 80 -- 364
			local pbx = cx - pbw * 0.5 -- 365
			local pby = by + 9 -- 366
			uiInkDraw:drawSegment( -- 367
				Vec2(pbx, pby), -- 367
				Vec2(pbx + pbw, pby), -- 367
				1.4, -- 367
				toColor(PALETTE.silkDim, 115 * alpha) -- 367
			) -- 367
			if ratio > 0.002 then -- 367
				uiInkDraw:drawSegment( -- 369
					Vec2(pbx, pby), -- 369
					Vec2(pbx + pbw * ratio, pby), -- 369
					2.8, -- 369
					toColor(PALETTE.amber, 230 * alpha) -- 369
				) -- 369
				uiInkDraw:drawSegment( -- 370
					Vec2(pbx, pby), -- 370
					Vec2(pbx + pbw * ratio, pby), -- 370
					1, -- 370
					toColor(PALETTE.amberCore, 165 * alpha) -- 370
				) -- 370
			end -- 370
			uiArt:tryPlace( -- 373
				"ink_enso_fine", -- 373
				"hand_knock_1", -- 373
				pbx + pbw * 0.62, -- 373
				pby, -- 373
				11, -- 373
				11, -- 373
				{ -- 373
					color = toColor(PALETTE.amber), -- 374
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 374
					layer = 3 -- 374
				} -- 374
			) -- 374
			uiArt:tryPlace( -- 376
				"ink_enso_fine", -- 376
				"hand_knock_2", -- 376
				pbx + pbw * 0.72, -- 376
				pby, -- 376
				11, -- 376
				11, -- 376
				{ -- 376
					color = toColor(PALETTE.amber), -- 377
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 377
					layer = 3 -- 377
				} -- 377
			) -- 377
		end -- 377
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 377
			local bw = 400 -- 381
			local cx = w * 0.5 -- 382
			local by = h - 64 -- 383
			local ratio = math.max( -- 384
				0, -- 384
				math.min( -- 384
					1, -- 384
					p.gateTick / math.max(1, g.holdTicks) -- 384
				) -- 384
			) -- 384
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 385
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 386
			drawSilkVeil( -- 388
				uiDraw, -- 388
				uiArt, -- 388
				"hud_gate_veil", -- 388
				cx, -- 388
				by + 18, -- 388
				bw + 90, -- 388
				48, -- 388
				PALETTE.inkWash, -- 388
				0.76 * alpha, -- 388
				-1 -- 388
			) -- 388
			drawHairline( -- 389
				uiInkDraw, -- 389
				uiArt, -- 389
				"hud_gate_top", -- 389
				cx, -- 389
				by + 39, -- 389
				bw - 20, -- 389
				PALETTE.rougeSoft, -- 389
				0.55 * alpha, -- 389
				false, -- 389
				2 -- 389
			) -- 389
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 391
			texts:put( -- 394
				"xs", -- 394
				label, -- 394
				cx, -- 394
				by + 26, -- 394
				toColor(PALETTE.textBright), -- 394
				0.5, -- 394
				0.5, -- 394
				"Center", -- 394
				1.8, -- 394
				alpha, -- 394
				0.08 -- 394
			) -- 394
			local pbw = bw - 80 -- 397
			local pbx = cx - pbw * 0.5 -- 398
			local pby = by + 9 -- 399
			uiInkDraw:drawSegment( -- 400
				Vec2(pbx, pby), -- 400
				Vec2(pbx + pbw, pby), -- 400
				1.4, -- 400
				toColor(PALETTE.silkDim, 115 * alpha) -- 400
			) -- 400
			if ratio > 0.002 then -- 400
				uiInkDraw:drawSegment( -- 402
					Vec2(pbx, pby), -- 402
					Vec2(pbx + pbw * ratio, pby), -- 402
					2.8, -- 402
					toColor(PALETTE.rouge, 230 * alpha) -- 402
				) -- 402
				uiInkDraw:drawSegment( -- 403
					Vec2(pbx, pby), -- 403
					Vec2(pbx + pbw * ratio, pby), -- 403
					1, -- 403
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 403
				) -- 403
			end -- 403
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 405
			local k = 0 -- 406
			do -- 406
				k = 0 -- 407
				while k < #waves do -- 407
					local wx = pbx + pbw * waves[k + 1] -- 408
					local passed = p.gateSpawned > k -- 409
					if passed then -- 409
						drawBlossomDot( -- 411
							uiInkDraw, -- 411
							uiArt, -- 411
							"gate_wave_" .. tostring(k), -- 411
							wx, -- 411
							pby, -- 411
							10, -- 411
							PALETTE.moonPale, -- 411
							0.92 * alpha, -- 411
							3 -- 411
						) -- 411
					else -- 411
						uiArt:tryPlace( -- 413
							"ink_enso_fine", -- 413
							"gate_wave_" .. tostring(k), -- 413
							wx, -- 413
							pby, -- 413
							11, -- 413
							11, -- 413
							{ -- 413
								color = toColor(PALETTE.rouge), -- 414
								opacity = 0.84 * alpha, -- 414
								layer = 3 -- 414
							} -- 414
						) -- 414
					end -- 414
					k = k + 1 -- 407
				end -- 407
			end -- 407
		end -- 407
		return -- 419
	end -- 419
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 419
		local cx = w * 0.5 -- 424
		local by = h - 44 -- 425
		local step1 = p.cartDocked -- 426
		local ____temp_0 -- 427
		if p.room.key == "checkpoint" then -- 427
			____temp_0 = p.gateOpen -- 427
		else -- 427
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 427
		end -- 427
		local step2 = ____temp_0 -- 427
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 428
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 429
		drawSilkVeil( -- 431
			uiDraw, -- 431
			uiArt, -- 431
			"hud_obj_veil", -- 431
			cx, -- 431
			by, -- 431
			380, -- 431
			34, -- 431
			PALETTE.inkWash, -- 431
			0.58 * alpha, -- 431
			-1 -- 431
		) -- 431
		local x1 = cx - 134 -- 433
		if step1 then -- 433
			drawBlossomDot( -- 435
				uiInkDraw, -- 435
				uiArt, -- 435
				"obj_m1", -- 435
				x1, -- 435
				by, -- 435
				11, -- 435
				PALETTE.emerald, -- 435
				0.94 * alpha, -- 435
				3 -- 435
			) -- 435
		else -- 435
			uiArt:tryPlace( -- 437
				"ink_enso_fine", -- 437
				"obj_m1", -- 437
				x1, -- 437
				by, -- 437
				11, -- 437
				11, -- 437
				{ -- 437
					color = toColor(PALETTE.silkLine), -- 437
					opacity = 0.72 * alpha, -- 437
					layer = 3 -- 437
				} -- 437
			) -- 437
		end -- 437
		texts:put( -- 439
			"xs", -- 439
			t1, -- 439
			x1 + 13, -- 439
			by, -- 439
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 439
			0, -- 439
			0.5, -- 439
			"Left", -- 439
			1, -- 439
			alpha, -- 439
			0.08 -- 439
		) -- 439
		local x2 = cx + 18 -- 441
		if step2 then -- 441
			drawBlossomDot( -- 443
				uiInkDraw, -- 443
				uiArt, -- 443
				"obj_m2", -- 443
				x2, -- 443
				by, -- 443
				11, -- 443
				PALETTE.emerald, -- 443
				0.94 * alpha, -- 443
				3 -- 443
			) -- 443
		else -- 443
			uiArt:tryPlace( -- 445
				"ink_enso_fine", -- 445
				"obj_m2", -- 445
				x2, -- 445
				by, -- 445
				11, -- 445
				11, -- 445
				{ -- 445
					color = toColor(PALETTE.silkDim), -- 445
					opacity = 0.62 * alpha, -- 445
					layer = 3 -- 445
				} -- 445
			) -- 445
		end -- 445
		texts:put( -- 447
			"xs", -- 447
			t2, -- 447
			x2 + 13, -- 447
			by, -- 447
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 447
			0, -- 447
			0.5, -- 447
			"Left", -- 447
			1, -- 447
			alpha, -- 447
			0.08 -- 447
		) -- 447
	end -- 447
end -- 254
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 451
	local bob = math.sin(self.time * 3.4) * 2.8 -- 461
	local viewW = cam.viewW / uiScale -- 462
	local viewH = cam.viewH / uiScale -- 463
	local i = 0 -- 464
	do -- 464
		i = 0 -- 465
		while i < #prompts do -- 465
			local pr = prompts[i + 1] -- 466
			local keyW = math.max( -- 467
				24, -- 467
				visualTextWidth(pr.keyTag, 15) + 16 -- 467
			) -- 467
			local labelW = visualTextWidth(pr.label, 15) -- 468
			local pillW = keyW + labelW + 24 -- 469
			local padX = math.max(115, pillW * 0.5 + 24) -- 470
			local sx = math.max( -- 471
				padX, -- 471
				math.min( -- 471
					viewW - padX, -- 471
					cam:sx(pr.x) / uiScale -- 471
				) -- 471
			) -- 471
			local sy = math.max( -- 472
				96, -- 472
				math.min( -- 472
					viewH - 110, -- 472
					cam:sy(pr.y) / uiScale + bob -- 472
				) -- 472
			) -- 472
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 473
			uiInkDraw:drawSegment( -- 476
				Vec2(sx, sy - 14), -- 476
				Vec2(sx, sy - 27), -- 476
				0.8, -- 476
				toColor(accent, 135 * alpha) -- 476
			) -- 476
			drawBlossomDot( -- 477
				uiInkDraw, -- 477
				uiArt, -- 477
				"wp_anchor_" .. tostring(i), -- 477
				sx, -- 477
				sy - 28, -- 477
				7, -- 477
				accent, -- 477
				0.85 * alpha, -- 477
				3 -- 477
			) -- 477
			local px = sx - pillW * 0.5 -- 479
			local py = sy - 12 -- 480
			drawSilkVeil( -- 482
				uiDraw, -- 482
				uiArt, -- 482
				"wp_bg_" .. tostring(i), -- 482
				sx, -- 482
				py + 12, -- 482
				pillW + 40, -- 482
				32, -- 482
				PALETTE.inkWash, -- 482
				0.78 * alpha, -- 482
				0 -- 482
			) -- 482
			drawHairline( -- 483
				uiInkDraw, -- 483
				uiArt, -- 483
				"wp_line_" .. tostring(i), -- 483
				sx, -- 483
				py + 24, -- 483
				pillW + 4, -- 483
				accent, -- 483
				0.45 * alpha, -- 483
				false, -- 483
				2 -- 483
			) -- 483
			drawSilkKeycap( -- 484
				uiInkDraw, -- 484
				texts, -- 484
				px + 2, -- 484
				py + 2, -- 484
				keyW, -- 484
				20, -- 484
				pr.keyTag, -- 484
				accent, -- 484
				alpha, -- 484
				pr.urgent -- 484
			) -- 484
			texts:put( -- 485
				"xs", -- 485
				pr.label, -- 485
				px + keyW + 12, -- 485
				py + 12, -- 485
				toColor(PALETTE.textBright), -- 485
				0, -- 485
				0.5, -- 485
				"Left", -- 485
				0.8, -- 485
				alpha, -- 485
				0.08 -- 485
			) -- 485
			i = i + 1 -- 465
		end -- 465
	end -- 465
end -- 451
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 489
	local mx = p.aimX / uiScale -- 498
	local my = p.aimY / uiScale -- 499
	if mx <= 0 and my <= 0 then -- 499
		return -- 501
	end -- 501
	if p.childMode then -- 501
		local aiming = p.room.key == "village" and p.hasBottle -- 505
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 506
		uiInkDraw:drawDot( -- 507
			Vec2(mx, my), -- 507
			aiming and 2 or 1.6, -- 507
			toColor(col, aiming and 215 or 120) -- 507
		) -- 507
		if aiming then -- 507
			local sz = p.aimHold > 0 and 32 or 24 -- 509
			uiArt:tryPlace( -- 510
				"ink_enso_fine", -- 510
				"reticle_child", -- 510
				mx, -- 510
				my, -- 510
				sz, -- 510
				sz, -- 510
				{ -- 510
					color = toColor(PALETTE.amberCore), -- 511
					opacity = 0.82, -- 511
					angle = self.time * 24, -- 511
					layer = 5 -- 511
				} -- 511
			) -- 511
		end -- 511
		return -- 514
	end -- 514
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 517
	local onEnemy = false -- 518
	local i = 0 -- 519
	do -- 519
		i = 0 -- 520
		while i < #p.enemies do -- 520
			local e = p.enemies[i + 1] -- 521
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 521
				onEnemy = true -- 523
			end -- 523
			i = i + 1 -- 520
		end -- 520
	end -- 520
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 527
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 528
	local arm = onEnemy and 8.5 or 9.5 -- 529
	local bg = Color(10, 12, 18, 160) -- 530
	uiInkDraw:drawSegment( -- 532
		Vec2(mx - gap - arm, my), -- 532
		Vec2(mx - gap, my), -- 532
		2.1, -- 532
		bg -- 532
	) -- 532
	uiInkDraw:drawSegment( -- 533
		Vec2(mx + gap, my), -- 533
		Vec2(mx + gap + arm, my), -- 533
		2.1, -- 533
		bg -- 533
	) -- 533
	uiInkDraw:drawSegment( -- 534
		Vec2(mx, my - gap - arm), -- 534
		Vec2(mx, my - gap), -- 534
		2.1, -- 534
		bg -- 534
	) -- 534
	uiInkDraw:drawSegment( -- 535
		Vec2(mx, my + gap), -- 535
		Vec2(mx, my + gap + arm), -- 535
		2.1, -- 535
		bg -- 535
	) -- 535
	uiInkDraw:drawSegment( -- 537
		Vec2(mx - gap - arm, my), -- 537
		Vec2(mx - gap, my), -- 537
		1.1, -- 537
		toColor(col, 230) -- 537
	) -- 537
	uiInkDraw:drawSegment( -- 538
		Vec2(mx + gap, my), -- 538
		Vec2(mx + gap + arm, my), -- 538
		1.1, -- 538
		toColor(col, 230) -- 538
	) -- 538
	uiInkDraw:drawSegment( -- 539
		Vec2(mx, my - gap - arm), -- 539
		Vec2(mx, my - gap), -- 539
		1.1, -- 539
		toColor(col, 230) -- 539
	) -- 539
	uiInkDraw:drawSegment( -- 540
		Vec2(mx, my + gap), -- 540
		Vec2(mx, my + gap + arm), -- 540
		1.1, -- 540
		toColor(col, 230) -- 540
	) -- 540
	uiInkDraw:drawDot( -- 541
		Vec2(mx, my), -- 541
		1.8, -- 541
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 541
	) -- 541
	if onEnemy then -- 541
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 544
		uiArt:tryPlace( -- 545
			"ink_enso_fine", -- 545
			"reticle_lock", -- 545
			mx, -- 545
			my, -- 545
			sz, -- 545
			sz, -- 545
			{ -- 545
				color = toColor(PALETTE.rouge), -- 546
				opacity = 0.88, -- 546
				angle = self.time * 38, -- 546
				layer = 5 -- 546
			} -- 546
		) -- 546
		fillRadialGlow( -- 548
			uiGlow, -- 548
			mx, -- 548
			my, -- 548
			16, -- 548
			16, -- 548
			toColor(PALETTE.rouge, 30), -- 548
			Color(182, 58, 56, 0), -- 548
			10 -- 548
		) -- 548
	end -- 548
end -- 489
return ____exports -- 489