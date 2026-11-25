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
	if p.craftBench.active then -- 280
		local bw = 470 -- 294
		local cx = w * 0.5 -- 295
		local top = h * 0.32 -- 296
		drawSilkVeil( -- 297
			uiDraw, -- 297
			uiArt, -- 297
			"hud_bench_veil", -- 297
			cx, -- 297
			top + 118, -- 297
			bw + 64, -- 297
			208, -- 297
			PALETTE.inkWash, -- 297
			0.86 * alpha, -- 297
			-1 -- 297
		) -- 297
		texts:put( -- 298
			"xs", -- 298
			"工台 · 放她下来做一件", -- 298
			cx, -- 298
			top - 6, -- 298
			toColor(PALETTE.textBright), -- 298
			0.5, -- 298
			0.5, -- 298
			"Center", -- 298
			1.7, -- 298
			alpha, -- 298
			0.08 -- 298
		) -- 298
		local inv = p.craftBench.inventory -- 299
		local wood = inv.wood or 0 -- 300
		local bell = inv.bell or 0 -- 301
		local scrap = inv.scrap or 0 -- 302
		texts:put( -- 303
			"xs", -- 303
			(((("木纹筹 " .. tostring(wood)) .. " · 铃纹筹 ") .. tostring(bell)) .. " · 碎片 ") .. tostring(scrap), -- 303
			cx, -- 303
			top + 24, -- 303
			toColor(PALETTE.silkDim), -- 304
			0.5, -- 304
			0.5, -- 304
			"Center", -- 304
			1.5, -- 304
			alpha, -- 304
			0.08 -- 304
		) -- 304
		local recipes = p.craftBench.recipes -- 305
		do -- 305
			local i = 0 -- 306
			while i < #recipes do -- 306
				local r = recipes[i + 1] -- 307
				local costText = "" -- 308
				local afford = true -- 309
				local costWood = r.cost.wood or 0 -- 310
				local costBell = r.cost.bell or 0 -- 311
				if costWood > 0 then -- 311
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "木 ") .. tostring(costWood) -- 313
					if wood < costWood then -- 313
						afford = false -- 315
					end -- 315
				end -- 315
				if costBell > 0 then -- 315
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "铃 ") .. tostring(costBell) -- 319
					if bell < costBell then -- 319
						afford = false -- 321
					end -- 321
				end -- 321
				local equipped = p.craftBench.equippedWeapon == r.id -- 324
				local state = r.crafted and "已做成" or (afford and "可制作" or "缺料") -- 325
				local mark = equipped and " ◈" or "" -- 326
				texts:put( -- 327
					"xs", -- 327
					((((r.name .. " · ") .. costText) .. " · ") .. state) .. mark, -- 327
					cx, -- 327
					top + 56 + i * 26, -- 327
					toColor(equipped and PALETTE.cyanCore or (r.crafted and PALETTE.silkDim or PALETTE.textBright)), -- 328
					0.5, -- 329
					0.5, -- 329
					"Center", -- 329
					1.6, -- 329
					alpha, -- 329
					0.08 -- 329
				) -- 329
				i = i + 1 -- 306
			end -- 306
		end -- 306
		local firstMade = p.craftBench.firstCraftDone and " · 首制完成" or "" -- 331
		texts:put( -- 332
			"xs", -- 332
			"E 制作 · Q 装备 · Esc 离开" .. firstMade, -- 332
			cx, -- 332
			top + 128, -- 332
			toColor(PALETTE.amber), -- 333
			0.5, -- 333
			0.5, -- 333
			"Center", -- 333
			1.5, -- 333
			alpha, -- 333
			0.06 -- 333
		) -- 333
	end -- 333
	if p.reloadOpen then -- 333
		local bw = 400 -- 337
		local cx = w * 0.5 -- 338
		local by = h - 64 -- 339
		local ratio = math.max( -- 340
			0, -- 340
			math.min(1, p.reloadAnswerTicks / 240) -- 340
		) -- 340
		local effect = p.reloadPendingEffect -- 341
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 342
		drawSilkVeil( -- 345
			uiDraw, -- 345
			uiArt, -- 345
			"hud_reload_veil", -- 345
			cx, -- 345
			by + 18, -- 345
			bw + 90, -- 345
			48, -- 345
			PALETTE.inkWash, -- 345
			0.76 * alpha, -- 345
			-1 -- 345
		) -- 345
		drawHairline( -- 346
			uiInkDraw, -- 346
			uiArt, -- 346
			"hud_reload_top", -- 346
			cx, -- 346
			by + 39, -- 346
			bw - 20, -- 346
			PALETTE.cyan, -- 346
			0.55 * alpha, -- 346
			false, -- 346
			2 -- 346
		) -- 346
		texts:put( -- 347
			"xs", -- 347
			label, -- 347
			cx, -- 347
			by + 26, -- 347
			toColor(PALETTE.textBright), -- 347
			0.5, -- 347
			0.5, -- 347
			"Center", -- 347
			1.8, -- 347
			alpha, -- 347
			0.08 -- 347
		) -- 347
		do -- 347
			local n = 0 -- 350
			while n < 9 do -- 350
				local col = n % 3 -- 351
				local row = math.floor(n / 3) -- 352
				local nx = cx + (col - 1) * 13 -- 353
				local ny = by + 50 + row * 12 -- 354
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 355
				local isEnd = n == 8 -- 356
				uiArt:tryPlace( -- 357
					"ink_enso_fine", -- 357
					"reload_node_" .. tostring(n), -- 357
					nx, -- 357
					ny, -- 357
					isEnd and 10 or 6, -- 357
					isEnd and 10 or 6, -- 357
					{ -- 357
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 358
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 359
						layer = 3 -- 359
					} -- 359
				) -- 359
				n = n + 1 -- 350
			end -- 350
		end -- 350
		local pbw = bw - 80 -- 363
		local pbx = cx - pbw * 0.5 -- 364
		local pby = by + 9 -- 365
		uiInkDraw:drawSegment( -- 366
			Vec2(pbx, pby), -- 366
			Vec2(pbx + pbw, pby), -- 366
			1.4, -- 366
			toColor(PALETTE.silkDim, 115 * alpha) -- 366
		) -- 366
		if ratio > 0.002 then -- 366
			uiInkDraw:drawSegment( -- 368
				Vec2(pbx, pby), -- 368
				Vec2(pbx + pbw * ratio, pby), -- 368
				2.8, -- 368
				toColor(PALETTE.cyan, 220 * alpha) -- 368
			) -- 368
			uiInkDraw:drawSegment( -- 369
				Vec2(pbx, pby), -- 369
				Vec2(pbx + pbw * ratio, pby), -- 369
				1, -- 369
				toColor(PALETTE.cyanCore, 160 * alpha) -- 369
			) -- 369
		end -- 369
	end -- 369
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 369
		local g = p.room.story.gate -- 375
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 375
			local bw = 400 -- 378
			local cx = w * 0.5 -- 379
			local by = h - 64 -- 380
			local tied = p.phase == "gate-hand" -- 381
			local ratio = tied and 1 or math.max( -- 382
				0, -- 382
				math.min( -- 382
					1, -- 382
					p.handTicks / math.max(1, p.handNeedTicks) -- 382
				) -- 382
			) -- 382
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 383
			drawSilkVeil( -- 387
				uiDraw, -- 387
				uiArt, -- 387
				"hud_hand_veil", -- 387
				cx, -- 387
				by + 18, -- 387
				bw + 90, -- 387
				48, -- 387
				PALETTE.inkWash, -- 387
				0.76 * alpha, -- 387
				-1 -- 387
			) -- 387
			drawHairline( -- 388
				uiInkDraw, -- 388
				uiArt, -- 388
				"hud_hand_top", -- 388
				cx, -- 388
				by + 39, -- 388
				bw - 20, -- 388
				PALETTE.amber, -- 388
				0.55 * alpha, -- 388
				false, -- 388
				2 -- 388
			) -- 388
			texts:put( -- 389
				"xs", -- 389
				label, -- 389
				cx, -- 389
				by + 26, -- 389
				toColor(PALETTE.textBright), -- 389
				0.5, -- 389
				0.5, -- 389
				"Center", -- 389
				1.8, -- 389
				alpha, -- 389
				0.08 -- 389
			) -- 389
			local pbw = bw - 80 -- 391
			local pbx = cx - pbw * 0.5 -- 392
			local pby = by + 9 -- 393
			uiInkDraw:drawSegment( -- 394
				Vec2(pbx, pby), -- 394
				Vec2(pbx + pbw, pby), -- 394
				1.4, -- 394
				toColor(PALETTE.silkDim, 115 * alpha) -- 394
			) -- 394
			if ratio > 0.002 then -- 394
				uiInkDraw:drawSegment( -- 396
					Vec2(pbx, pby), -- 396
					Vec2(pbx + pbw * ratio, pby), -- 396
					2.8, -- 396
					toColor(PALETTE.amber, 230 * alpha) -- 396
				) -- 396
				uiInkDraw:drawSegment( -- 397
					Vec2(pbx, pby), -- 397
					Vec2(pbx + pbw * ratio, pby), -- 397
					1, -- 397
					toColor(PALETTE.amberCore, 165 * alpha) -- 397
				) -- 397
			end -- 397
			uiArt:tryPlace( -- 400
				"ink_enso_fine", -- 400
				"hand_knock_1", -- 400
				pbx + pbw * 0.62, -- 400
				pby, -- 400
				11, -- 400
				11, -- 400
				{ -- 400
					color = toColor(PALETTE.amber), -- 401
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 401
					layer = 3 -- 401
				} -- 401
			) -- 401
			uiArt:tryPlace( -- 403
				"ink_enso_fine", -- 403
				"hand_knock_2", -- 403
				pbx + pbw * 0.72, -- 403
				pby, -- 403
				11, -- 403
				11, -- 403
				{ -- 403
					color = toColor(PALETTE.amber), -- 404
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 404
					layer = 3 -- 404
				} -- 404
			) -- 404
		end -- 404
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 404
			local bw = 400 -- 408
			local cx = w * 0.5 -- 409
			local by = h - 64 -- 410
			local ratio = math.max( -- 411
				0, -- 411
				math.min( -- 411
					1, -- 411
					p.gateTick / math.max(1, g.holdTicks) -- 411
				) -- 411
			) -- 411
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 412
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 413
			drawSilkVeil( -- 415
				uiDraw, -- 415
				uiArt, -- 415
				"hud_gate_veil", -- 415
				cx, -- 415
				by + 18, -- 415
				bw + 90, -- 415
				48, -- 415
				PALETTE.inkWash, -- 415
				0.76 * alpha, -- 415
				-1 -- 415
			) -- 415
			drawHairline( -- 416
				uiInkDraw, -- 416
				uiArt, -- 416
				"hud_gate_top", -- 416
				cx, -- 416
				by + 39, -- 416
				bw - 20, -- 416
				PALETTE.rougeSoft, -- 416
				0.55 * alpha, -- 416
				false, -- 416
				2 -- 416
			) -- 416
			local idleNeedConfirmLabel = assistHintsEnabled and "绞盘待命 · 按 [E] 重新守门" or "绞盘待命" -- 418
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 419
			texts:put( -- 422
				"xs", -- 422
				label, -- 422
				cx, -- 422
				by + 26, -- 422
				toColor(PALETTE.textBright), -- 422
				0.5, -- 422
				0.5, -- 422
				"Center", -- 422
				1.8, -- 422
				alpha, -- 422
				0.08 -- 422
			) -- 422
			local pbw = bw - 80 -- 425
			local pbx = cx - pbw * 0.5 -- 426
			local pby = by + 9 -- 427
			uiInkDraw:drawSegment( -- 428
				Vec2(pbx, pby), -- 428
				Vec2(pbx + pbw, pby), -- 428
				1.4, -- 428
				toColor(PALETTE.silkDim, 115 * alpha) -- 428
			) -- 428
			if ratio > 0.002 then -- 428
				uiInkDraw:drawSegment( -- 430
					Vec2(pbx, pby), -- 430
					Vec2(pbx + pbw * ratio, pby), -- 430
					2.8, -- 430
					toColor(PALETTE.rouge, 230 * alpha) -- 430
				) -- 430
				uiInkDraw:drawSegment( -- 431
					Vec2(pbx, pby), -- 431
					Vec2(pbx + pbw * ratio, pby), -- 431
					1, -- 431
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 431
				) -- 431
			end -- 431
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 433
			local k = 0 -- 434
			do -- 434
				k = 0 -- 435
				while k < #waves do -- 435
					local wx = pbx + pbw * waves[k + 1] -- 436
					local passed = p.gateSpawned > k -- 437
					if passed then -- 437
						drawBlossomDot( -- 439
							uiInkDraw, -- 439
							uiArt, -- 439
							"gate_wave_" .. tostring(k), -- 439
							wx, -- 439
							pby, -- 439
							10, -- 439
							PALETTE.moonPale, -- 439
							0.92 * alpha, -- 439
							3 -- 439
						) -- 439
					else -- 439
						uiArt:tryPlace( -- 441
							"ink_enso_fine", -- 441
							"gate_wave_" .. tostring(k), -- 441
							wx, -- 441
							pby, -- 441
							11, -- 441
							11, -- 441
							{ -- 441
								color = toColor(PALETTE.rouge), -- 442
								opacity = 0.84 * alpha, -- 442
								layer = 3 -- 442
							} -- 442
						) -- 442
					end -- 442
					k = k + 1 -- 435
				end -- 435
			end -- 435
		end -- 435
		return -- 447
	end -- 447
	if not assistHintsEnabled then -- 447
		return -- 452
	end -- 452
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 452
		local cx = w * 0.5 -- 455
		local by = h - 44 -- 456
		local step1 = p.cartDocked -- 457
		local ____temp_0 -- 458
		if p.room.key == "checkpoint" then -- 458
			____temp_0 = p.gateOpen -- 458
		else -- 458
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 458
		end -- 458
		local step2 = ____temp_0 -- 458
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 459
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 460
		drawSilkVeil( -- 462
			uiDraw, -- 462
			uiArt, -- 462
			"hud_obj_veil", -- 462
			cx, -- 462
			by, -- 462
			380, -- 462
			34, -- 462
			PALETTE.inkWash, -- 462
			0.58 * alpha, -- 462
			-1 -- 462
		) -- 462
		local x1 = cx - 134 -- 464
		if step1 then -- 464
			drawBlossomDot( -- 466
				uiInkDraw, -- 466
				uiArt, -- 466
				"obj_m1", -- 466
				x1, -- 466
				by, -- 466
				11, -- 466
				PALETTE.emerald, -- 466
				0.94 * alpha, -- 466
				3 -- 466
			) -- 466
		else -- 466
			uiArt:tryPlace( -- 468
				"ink_enso_fine", -- 468
				"obj_m1", -- 468
				x1, -- 468
				by, -- 468
				11, -- 468
				11, -- 468
				{ -- 468
					color = toColor(PALETTE.silkLine), -- 468
					opacity = 0.72 * alpha, -- 468
					layer = 3 -- 468
				} -- 468
			) -- 468
		end -- 468
		texts:put( -- 470
			"xs", -- 470
			t1, -- 470
			x1 + 13, -- 470
			by, -- 470
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 470
			0, -- 470
			0.5, -- 470
			"Left", -- 470
			1, -- 470
			alpha, -- 470
			0.08 -- 470
		) -- 470
		local x2 = cx + 18 -- 472
		if step2 then -- 472
			drawBlossomDot( -- 474
				uiInkDraw, -- 474
				uiArt, -- 474
				"obj_m2", -- 474
				x2, -- 474
				by, -- 474
				11, -- 474
				PALETTE.emerald, -- 474
				0.94 * alpha, -- 474
				3 -- 474
			) -- 474
		else -- 474
			uiArt:tryPlace( -- 476
				"ink_enso_fine", -- 476
				"obj_m2", -- 476
				x2, -- 476
				by, -- 476
				11, -- 476
				11, -- 476
				{ -- 476
					color = toColor(PALETTE.silkDim), -- 476
					opacity = 0.62 * alpha, -- 476
					layer = 3 -- 476
				} -- 476
			) -- 476
		end -- 476
		texts:put( -- 478
			"xs", -- 478
			t2, -- 478
			x2 + 13, -- 478
			by, -- 478
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 478
			0, -- 478
			0.5, -- 478
			"Left", -- 478
			1, -- 478
			alpha, -- 478
			0.08 -- 478
		) -- 478
	end -- 478
end -- 280
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 482
	local bob = math.sin(self.time * 3.4) * 2.8 -- 492
	local viewW = cam.viewW / uiScale -- 493
	local viewH = cam.viewH / uiScale -- 494
	local i = 0 -- 495
	do -- 495
		i = 0 -- 496
		while i < #prompts do -- 496
			local pr = prompts[i + 1] -- 497
			local keyW = math.max( -- 498
				24, -- 498
				visualTextWidth(pr.keyTag, 15) + 16 -- 498
			) -- 498
			local labelW = visualTextWidth(pr.label, 15) -- 499
			local pillW = keyW + labelW + 24 -- 500
			local padX = math.max(115, pillW * 0.5 + 24) -- 501
			local sx = math.max( -- 502
				padX, -- 502
				math.min( -- 502
					viewW - padX, -- 502
					cam:sx(pr.x) / uiScale -- 502
				) -- 502
			) -- 502
			local sy = math.max( -- 503
				96, -- 503
				math.min( -- 503
					viewH - 110, -- 503
					cam:sy(pr.y) / uiScale + bob -- 503
				) -- 503
			) -- 503
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 504
			uiInkDraw:drawSegment( -- 507
				Vec2(sx, sy - 14), -- 507
				Vec2(sx, sy - 27), -- 507
				0.8, -- 507
				toColor(accent, 135 * alpha) -- 507
			) -- 507
			drawBlossomDot( -- 508
				uiInkDraw, -- 508
				uiArt, -- 508
				"wp_anchor_" .. tostring(i), -- 508
				sx, -- 508
				sy - 28, -- 508
				7, -- 508
				accent, -- 508
				0.85 * alpha, -- 508
				3 -- 508
			) -- 508
			local px = sx - pillW * 0.5 -- 510
			local py = sy - 12 -- 511
			drawSilkVeil( -- 513
				uiDraw, -- 513
				uiArt, -- 513
				"wp_bg_" .. tostring(i), -- 513
				sx, -- 513
				py + 12, -- 513
				pillW + 40, -- 513
				32, -- 513
				PALETTE.inkWash, -- 513
				0.78 * alpha, -- 513
				0 -- 513
			) -- 513
			drawHairline( -- 514
				uiInkDraw, -- 514
				uiArt, -- 514
				"wp_line_" .. tostring(i), -- 514
				sx, -- 514
				py + 24, -- 514
				pillW + 4, -- 514
				accent, -- 514
				0.45 * alpha, -- 514
				false, -- 514
				2 -- 514
			) -- 514
			drawSilkKeycap( -- 515
				uiInkDraw, -- 515
				texts, -- 515
				px + 2, -- 515
				py + 2, -- 515
				keyW, -- 515
				20, -- 515
				pr.keyTag, -- 515
				accent, -- 515
				alpha, -- 515
				pr.urgent -- 515
			) -- 515
			texts:put( -- 516
				"xs", -- 516
				pr.label, -- 516
				px + keyW + 12, -- 516
				py + 12, -- 516
				toColor(PALETTE.textBright), -- 516
				0, -- 516
				0.5, -- 516
				"Left", -- 516
				0.8, -- 516
				alpha, -- 516
				0.08 -- 516
			) -- 516
			i = i + 1 -- 496
		end -- 496
	end -- 496
end -- 482
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 520
	local mx = p.aimX / uiScale -- 529
	local my = p.aimY / uiScale -- 530
	if mx <= 0 and my <= 0 then -- 530
		return -- 532
	end -- 532
	if p.childMode then -- 532
		local aiming = p.room.key == "village" and p.hasBottle -- 536
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 537
		uiInkDraw:drawDot( -- 538
			Vec2(mx, my), -- 538
			aiming and 2 or 1.6, -- 538
			toColor(col, aiming and 215 or 120) -- 538
		) -- 538
		if aiming then -- 538
			local sz = p.aimHold > 0 and 32 or 24 -- 540
			uiArt:tryPlace( -- 541
				"ink_enso_fine", -- 541
				"reticle_child", -- 541
				mx, -- 541
				my, -- 541
				sz, -- 541
				sz, -- 541
				{ -- 541
					color = toColor(PALETTE.amberCore), -- 542
					opacity = 0.82, -- 542
					angle = self.time * 24, -- 542
					layer = 5 -- 542
				} -- 542
			) -- 542
		end -- 542
		return -- 545
	end -- 545
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 548
	local onEnemy = false -- 549
	local i = 0 -- 550
	do -- 550
		i = 0 -- 551
		while i < #p.enemies do -- 551
			local e = p.enemies[i + 1] -- 552
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 552
				onEnemy = true -- 554
			end -- 554
			i = i + 1 -- 551
		end -- 551
	end -- 551
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 558
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 559
	local arm = onEnemy and 8.5 or 9.5 -- 560
	local bg = Color(10, 12, 18, 160) -- 561
	uiInkDraw:drawSegment( -- 563
		Vec2(mx - gap - arm, my), -- 563
		Vec2(mx - gap, my), -- 563
		2.1, -- 563
		bg -- 563
	) -- 563
	uiInkDraw:drawSegment( -- 564
		Vec2(mx + gap, my), -- 564
		Vec2(mx + gap + arm, my), -- 564
		2.1, -- 564
		bg -- 564
	) -- 564
	uiInkDraw:drawSegment( -- 565
		Vec2(mx, my - gap - arm), -- 565
		Vec2(mx, my - gap), -- 565
		2.1, -- 565
		bg -- 565
	) -- 565
	uiInkDraw:drawSegment( -- 566
		Vec2(mx, my + gap), -- 566
		Vec2(mx, my + gap + arm), -- 566
		2.1, -- 566
		bg -- 566
	) -- 566
	uiInkDraw:drawSegment( -- 568
		Vec2(mx - gap - arm, my), -- 568
		Vec2(mx - gap, my), -- 568
		1.1, -- 568
		toColor(col, 230) -- 568
	) -- 568
	uiInkDraw:drawSegment( -- 569
		Vec2(mx + gap, my), -- 569
		Vec2(mx + gap + arm, my), -- 569
		1.1, -- 569
		toColor(col, 230) -- 569
	) -- 569
	uiInkDraw:drawSegment( -- 570
		Vec2(mx, my - gap - arm), -- 570
		Vec2(mx, my - gap), -- 570
		1.1, -- 570
		toColor(col, 230) -- 570
	) -- 570
	uiInkDraw:drawSegment( -- 571
		Vec2(mx, my + gap), -- 571
		Vec2(mx, my + gap + arm), -- 571
		1.1, -- 571
		toColor(col, 230) -- 571
	) -- 571
	uiInkDraw:drawDot( -- 572
		Vec2(mx, my), -- 572
		1.8, -- 572
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 572
	) -- 572
	if onEnemy then -- 572
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 575
		uiArt:tryPlace( -- 576
			"ink_enso_fine", -- 576
			"reticle_lock", -- 576
			mx, -- 576
			my, -- 576
			sz, -- 576
			sz, -- 576
			{ -- 576
				color = toColor(PALETTE.rouge), -- 577
				opacity = 0.88, -- 577
				angle = self.time * 38, -- 577
				layer = 5 -- 577
			} -- 577
		) -- 577
		fillRadialGlow( -- 579
			uiGlow, -- 579
			mx, -- 579
			my, -- 579
			16, -- 579
			16, -- 579
			toColor(PALETTE.rouge, 30), -- 579
			Color(182, 58, 56, 0), -- 579
			10 -- 579
		) -- 579
	end -- 579
end -- 520
return ____exports -- 520