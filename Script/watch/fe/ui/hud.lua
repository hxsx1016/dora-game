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
local ____depth = require("Script.watch.depth") -- 11
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 11
local ____escort = require("Script.watch.escort") -- 12
local FEAR_MAX = ____escort.FEAR_MAX -- 12
local ____adapter = require("Script.watch.fe.adapter") -- 13
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 13
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 19
local drawBlossomDot = ____theme.drawBlossomDot -- 20
local drawHairline = ____theme.drawHairline -- 21
local drawSilkKeycap = ____theme.drawSilkKeycap -- 22
local drawSilkVeil = ____theme.drawSilkVeil -- 23
local fillRadialGlow = ____theme.fillRadialGlow -- 24
local themeOf = ____theme.themeOf -- 25
local toColor = ____theme.toColor -- 26
local visualTextWidth = ____theme.visualTextWidth -- 27
____exports.HudRenderer = __TS__Class() -- 30
local HudRenderer = ____exports.HudRenderer -- 30
HudRenderer.name = "HudRenderer" -- 30
function HudRenderer.prototype.____constructor(self) -- 30
	self.ghostHp = 3 -- 32
	self.time = 0 -- 33
end -- 30
function HudRenderer.prototype.reset(self, p) -- 35
	self.ghostHp = p ~= nil and p.hp or 3 -- 36
end -- 35
function HudRenderer.prototype.update(self, dt, p) -- 39
	self.time = self.time + dt -- 40
	if self.ghostHp > p.hp then -- 40
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 42
	else -- 42
		self.ghostHp = p.hp -- 44
	end -- 44
end -- 39
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle) -- 48
	if assistHintsEnabled == nil then -- 48
		assistHintsEnabled = false -- 59
	end -- 59
	if suppressReticle == nil then -- 59
		suppressReticle = false -- 60
	end -- 60
	local w = cam.viewW / uiScale -- 62
	local h = cam.viewH / uiScale -- 63
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 65
	if hudAlpha > 0.05 then -- 65
		if p.childMode then -- 65
			self:drawChildStatus( -- 69
				uiDraw, -- 69
				uiInkDraw, -- 69
				uiArt, -- 69
				texts, -- 69
				p, -- 69
				h, -- 69
				hudAlpha, -- 69
				assistHintsEnabled -- 69
			) -- 69
		else -- 69
			self:drawSoldierStatus( -- 71
				uiDraw, -- 71
				uiInkDraw, -- 71
				uiArt, -- 71
				texts, -- 71
				p, -- 71
				h, -- 71
				hudAlpha, -- 71
				assistHintsEnabled -- 71
			) -- 71
		end -- 71
		self:drawChapterBadge( -- 74
			uiDraw, -- 74
			uiArt, -- 74
			texts, -- 74
			p, -- 74
			w, -- 74
			h, -- 74
			hudAlpha -- 74
		) -- 74
		self:drawContextualObjective( -- 75
			uiDraw, -- 75
			uiInkDraw, -- 75
			uiArt, -- 75
			texts, -- 75
			p, -- 75
			w, -- 75
			h, -- 75
			hudAlpha, -- 75
			assistHintsEnabled -- 75
		) -- 75
		if assistHintsEnabled then -- 75
			local prompt = deriveWorldPrompt(p) -- 78
			if prompt ~= nil then -- 78
				self:drawWorldPrompts( -- 80
					uiDraw, -- 80
					uiInkDraw, -- 80
					uiArt, -- 80
					texts, -- 80
					{prompt}, -- 80
					cam, -- 80
					hudAlpha, -- 80
					uiScale -- 80
				) -- 80
			end -- 80
		end -- 80
		if vfx.deflectFlash > 0.25 then -- 80
			local dx = cam:sx(vfx.deflectX) / uiScale -- 85
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 86
			texts:put( -- 87
				"sm", -- 87
				"掩体挡下", -- 87
				dx, -- 87
				dy, -- 87
				toColor(PALETTE.textBright), -- 87
				0.5, -- 87
				0.5, -- 87
				"Center", -- 87
				2, -- 87
				vfx.deflectFlash, -- 87
				0.1 -- 87
			) -- 87
		end -- 87
	end -- 87
	if not suppressReticle then -- 87
		self:drawReticleOverlay( -- 92
			uiInkDraw, -- 92
			uiArt, -- 92
			uiGlow, -- 92
			p, -- 92
			cam, -- 92
			vfx, -- 92
			letterboxFrac, -- 92
			uiScale -- 92
		) -- 92
	end -- 92
end -- 48
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale) -- 97
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 97
		self:drawReticle( -- 109
			uiInkDraw, -- 109
			uiArt, -- 109
			uiGlow, -- 109
			p, -- 109
			cam, -- 109
			vfx, -- 109
			uiScale -- 109
		) -- 109
	end -- 109
end -- 97
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 113
	local bx = 28 -- 123
	local by = h - 72 -- 124
	local lowHp = p.hp <= 1 -- 125
	drawSilkVeil( -- 128
		uiDraw, -- 128
		uiArt, -- 128
		"hud_soldier_veil", -- 128
		bx + 150, -- 128
		by + 24, -- 128
		340, -- 128
		56, -- 128
		PALETTE.inkWash, -- 128
		0.62 * alpha, -- 128
		-1 -- 128
	) -- 128
	texts:put( -- 131
		"md", -- 131
		"戍", -- 131
		bx + 16, -- 131
		by + 25, -- 131
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 131
		0.5, -- 131
		0.5, -- 131
		"Center", -- 131
		0, -- 131
		alpha, -- 131
		0.1 -- 131
	) -- 131
	uiInkDraw:drawSegment( -- 132
		Vec2(bx + 32, by + 9), -- 132
		Vec2(bx + 32, by + 40), -- 132
		0.8, -- 132
		toColor(PALETTE.silkDim, 130 * alpha) -- 132
	) -- 132
	texts:put( -- 134
		"xs", -- 134
		"周戍 · 体力", -- 134
		bx + 44, -- 134
		by + 36, -- 134
		toColor(PALETTE.textMid), -- 134
		0, -- 134
		0.5, -- 134
		"Left", -- 134
		1.4, -- 134
		alpha, -- 134
		0.08 -- 134
	) -- 134
	local segCount = math.max(1, p.maxHp) -- 137
	local barX = bx + 44 -- 138
	local barY = by + 16 -- 139
	local segW = 54 -- 140
	local segH = 9 -- 141
	local gap = 8 -- 142
	local i = 0 -- 144
	do -- 144
		i = 0 -- 145
		while i < segCount do -- 145
			local sx = barX + i * (segW + gap) -- 146
			local scx = sx + segW * 0.5 -- 147
			if not uiArt:tryPlace( -- 147
				"ink_bamboo_slot", -- 148
				"hp_slot_" .. tostring(i), -- 148
				scx, -- 148
				barY, -- 148
				segW, -- 148
				segH, -- 148
				{ -- 148
					color = toColor(PALETTE.silkDim), -- 149
					opacity = 0.72 * alpha, -- 149
					layer = 1 -- 149
				} -- 149
			) then -- 149
				uiInkDraw:drawRect( -- 151
					Rect(sx, barY - 3, segW, 6), -- 151
					Color(0, 0, 0, 0), -- 151
					0.8, -- 151
					toColor(PALETTE.silkDim, 145 * alpha) -- 151
				) -- 151
			end -- 151
			if self.ghostHp > i and self.ghostHp > p.hp then -- 151
				local frac = math.min(1, self.ghostHp - i) -- 154
				uiInkDraw:drawRect( -- 155
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 155
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 155
				) -- 155
			end -- 155
			if p.hp > i then -- 155
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 158
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 159
				if not uiArt:tryPlace( -- 159
					"ink_bamboo_slip", -- 160
					"hp_fill_" .. tostring(i), -- 160
					scx, -- 160
					barY, -- 160
					segW, -- 160
					segH, -- 160
					{ -- 160
						color = toColor(fillCol), -- 161
						opacity = 0.94 * alpha * pulse, -- 161
						layer = 2 -- 161
					} -- 161
				) then -- 161
					uiInkDraw:drawRect( -- 163
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 163
						toColor(fillCol, 230 * alpha * pulse) -- 163
					) -- 163
				end -- 163
			end -- 163
			i = i + 1 -- 145
		end -- 145
	end -- 145
	local covX = barX + segCount * (segW + gap) + 6 -- 169
	local hasAliveEnemy = false -- 170
	do -- 170
		i = 0 -- 171
		while i < #p.enemies do -- 171
			if p.enemies[i + 1].alive then -- 171
				hasAliveEnemy = true -- 173
				break -- 174
			end -- 174
			i = i + 1 -- 171
		end -- 171
	end -- 171
	if p.coverHug then -- 171
		if hasAliveEnemy and not p.coverBlocking then -- 171
			uiInkDraw:drawRect( -- 179
				Rect(covX, barY - 9, 72, 18), -- 179
				toColor(PALETTE.inkWarm, 185 * alpha), -- 179
				0.8, -- 179
				toColor(PALETTE.amber, 200 * alpha) -- 179
			) -- 179
			texts:put( -- 180
				"xs", -- 180
				"背向掩体", -- 180
				covX + 36, -- 180
				barY, -- 180
				toColor(PALETTE.amberCore), -- 180
				0.5, -- 180
				0.5, -- 180
				"Center", -- 180
				0.6, -- 180
				alpha, -- 180
				0 -- 180
			) -- 180
		else -- 180
			uiInkDraw:drawRect( -- 182
				Rect(covX, barY - 9, 54, 18), -- 182
				toColor(PALETTE.cyanDim, 165 * alpha), -- 182
				0.8, -- 182
				toColor(PALETTE.cyanCore, 180 * alpha) -- 182
			) -- 182
			texts:put( -- 183
				"xs", -- 183
				"掩体中", -- 183
				covX + 27, -- 183
				barY, -- 183
				toColor(PALETTE.textBright), -- 183
				0.5, -- 183
				0.5, -- 183
				"Center", -- 183
				0.6, -- 183
				alpha, -- 183
				0 -- 183
			) -- 183
		end -- 183
	elseif p.coverNear then -- 183
		uiInkDraw:drawRect( -- 186
			Rect(covX, barY - 9, 54, 18), -- 186
			Color( -- 186
				14, -- 186
				17, -- 186
				25, -- 186
				math.floor(150 * alpha + 0.5) -- 186
			), -- 186
			0.8, -- 186
			toColor(PALETTE.silkLine, 165 * alpha) -- 186
		) -- 186
		texts:put( -- 187
			"xs", -- 187
			"可贴靠", -- 187
			covX + 27, -- 187
			barY, -- 187
			toColor(PALETTE.textMid), -- 187
			0.5, -- 187
			0.5, -- 187
			"Center", -- 187
			0.6, -- 187
			alpha, -- 187
			0.08 -- 187
		) -- 187
	end -- 187
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 187
		local subY = by - 24 -- 192
		local frozen = p.escort.state == "frozen" -- 193
		local calming = p.escort.state == "calming" -- 194
		drawSilkVeil( -- 196
			uiDraw, -- 196
			uiArt, -- 196
			"hud_fear_veil", -- 196
			bx + 126, -- 196
			subY + 6, -- 196
			260, -- 196
			30, -- 196
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 196
			0.64 * alpha, -- 196
			-1 -- 196
		) -- 196
		texts:put( -- 197
			"xs", -- 197
			"小满 · 惊惧", -- 197
			bx + 14, -- 197
			subY + 6, -- 197
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 197
			0, -- 197
			0.5, -- 197
			"Left", -- 197
			1, -- 197
			alpha, -- 197
			0.08 -- 197
		) -- 197
		local k = 0 -- 199
		do -- 199
			k = 0 -- 200
			while k < FEAR_MAX do -- 200
				local dx = bx + 114 + k * 20 -- 201
				local dy = subY + 6 -- 202
				local lit = k < p.escort.fear -- 203
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 204
				uiArt:tryPlace( -- 205
					"ink_enso_fine", -- 205
					"fear_ring_" .. tostring(k), -- 205
					dx, -- 205
					dy, -- 205
					14, -- 205
					14, -- 205
					{ -- 205
						color = toColor(lit and dc or PALETTE.silkLine), -- 206
						opacity = (lit and 0.92 or 0.64) * alpha, -- 206
						layer = 2 -- 206
					} -- 206
				) -- 206
				if lit then -- 206
					drawBlossomDot( -- 209
						uiInkDraw, -- 209
						uiArt, -- 209
						"fear_dot_" .. tostring(k), -- 209
						dx, -- 209
						dy, -- 209
						10, -- 209
						dc, -- 209
						0.96 * alpha, -- 209
						3 -- 209
					) -- 209
				end -- 209
				k = k + 1 -- 200
			end -- 200
		end -- 200
		if frozen then -- 200
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 214
			if assistHintsEnabled then -- 214
				drawSilkKeycap( -- 216
					uiInkDraw, -- 216
					texts, -- 216
					bx + 170, -- 216
					subY - 5, -- 216
					22, -- 216
					22, -- 216
					"E", -- 216
					PALETTE.rouge, -- 216
					alpha * pulse, -- 216
					true -- 216
				) -- 216
				texts:put( -- 217
					"xs", -- 217
					"轻敲安抚", -- 217
					bx + 198, -- 217
					subY + 6, -- 217
					toColor(PALETTE.crimsonCore), -- 217
					0, -- 217
					0.5, -- 217
					"Left", -- 217
					0.8, -- 217
					alpha * pulse, -- 217
					0.08 -- 217
				) -- 217
			else -- 217
				texts:put( -- 219
					"xs", -- 219
					"受惊停步", -- 219
					bx + 172, -- 219
					subY + 6, -- 219
					toColor(PALETTE.crimsonCore), -- 219
					0, -- 219
					0.5, -- 219
					"Left", -- 219
					0.8, -- 219
					alpha * pulse, -- 219
					0.08 -- 219
				) -- 219
			end -- 219
		elseif calming then -- 219
			texts:put( -- 222
				"xs", -- 222
				"轻敲安抚中", -- 222
				bx + 172, -- 222
				subY + 6, -- 222
				toColor(PALETTE.emerald), -- 222
				0, -- 222
				0.5, -- 222
				"Left", -- 222
				0.8, -- 222
				alpha, -- 222
				0.08 -- 222
			) -- 222
		end -- 222
	end -- 222
end -- 113
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 227
	local bx = 28 -- 237
	local by = h - 68 -- 238
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 239
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 240
	drawSilkVeil( -- 242
		uiDraw, -- 242
		uiArt, -- 242
		"hud_child_veil", -- 242
		bx + 144, -- 242
		by + 22, -- 242
		316, -- 242
		48, -- 242
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 242
		0.58 * alpha, -- 242
		-1 -- 242
	) -- 242
	texts:put( -- 243
		"md", -- 243
		alert and "危" or "满", -- 243
		bx + 16, -- 243
		by + 22, -- 243
		toColor(leadCol), -- 243
		0.5, -- 243
		0.5, -- 243
		"Center", -- 243
		0, -- 243
		alpha, -- 243
		0.1 -- 243
	) -- 243
	uiInkDraw:drawSegment( -- 244
		Vec2(bx + 32, by + 7), -- 244
		Vec2(bx + 32, by + 37), -- 244
		0.8, -- 244
		toColor(PALETTE.silkDim, 130 * alpha) -- 244
	) -- 244
	texts:put( -- 246
		"xs", -- 246
		"小满 · 潜行", -- 246
		bx + 44, -- 246
		by + 33, -- 246
		toColor(PALETTE.amberCore), -- 246
		0, -- 246
		0.5, -- 246
		"Left", -- 246
		1.4, -- 246
		alpha, -- 246
		0.08 -- 246
	) -- 246
	local posture = "轻步前行 · 保持隐蔽" -- 248
	local col = PALETTE.textMid -- 249
	if alert then -- 249
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 251
		col = PALETTE.crimsonCore -- 252
	elseif p.player.crouch then -- 252
		posture = "低姿伏行 · 匿迹于影" -- 254
		col = PALETTE.emerald -- 255
	elseif p.hasBottle then -- 255
		posture = assistHintsEnabled and "手持陶瓶 · 按住 [F] 瞄投" or "手持陶瓶" -- 257
		col = PALETTE.amberCore -- 258
	end -- 258
	texts:put( -- 260
		"xs", -- 260
		posture, -- 260
		bx + 44, -- 260
		by + 12, -- 260
		toColor(col), -- 260
		0, -- 260
		0.5, -- 260
		"Left", -- 260
		0.6, -- 260
		alpha, -- 260
		0.08 -- 260
	) -- 260
end -- 227
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 263
	local theme = themeOf(p.room.key) -- 272
	local rx = w - 32 -- 273
	local cy = h - 44 -- 274
	drawSilkVeil( -- 276
		uiDraw, -- 276
		uiArt, -- 276
		"hud_chap_veil", -- 276
		rx - 82, -- 276
		cy, -- 276
		240, -- 276
		44, -- 276
		PALETTE.inkWash, -- 276
		0.44 * alpha, -- 276
		-1 -- 276
	) -- 276
	texts:put( -- 277
		"xs", -- 277
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 277
		rx, -- 277
		cy + 9, -- 277
		toColor(PALETTE.textBright), -- 277
		1, -- 277
		0.5, -- 277
		"Right", -- 277
		1.2, -- 277
		alpha, -- 277
		0.08 -- 277
	) -- 277
	texts:put( -- 278
		"xs", -- 278
		"Esc 暂歇", -- 278
		rx, -- 278
		cy - 11, -- 278
		toColor(PALETTE.textDim), -- 278
		1, -- 278
		0.5, -- 278
		"Right", -- 278
		1, -- 278
		0.78 * alpha, -- 278
		0.08 -- 278
	) -- 278
end -- 263
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled) -- 281
	if p.craftBench.active then -- 281
		local bw = 470 -- 295
		local cx = w * 0.5 -- 296
		local top = h * 0.32 -- 297
		drawSilkVeil( -- 298
			uiDraw, -- 298
			uiArt, -- 298
			"hud_bench_veil", -- 298
			cx, -- 298
			top + 118, -- 298
			bw + 64, -- 298
			208, -- 298
			PALETTE.inkWash, -- 298
			0.86 * alpha, -- 298
			-1 -- 298
		) -- 298
		texts:put( -- 299
			"xs", -- 299
			"工台 · 放她下来做一件", -- 299
			cx, -- 299
			top - 6, -- 299
			toColor(PALETTE.textBright), -- 299
			0.5, -- 299
			0.5, -- 299
			"Center", -- 299
			1.7, -- 299
			alpha, -- 299
			0.08 -- 299
		) -- 299
		local inv = p.craftBench.inventory -- 300
		local wood = inv.wood or 0 -- 301
		local bell = inv.bell or 0 -- 302
		local scrap = inv.scrap or 0 -- 303
		texts:put( -- 304
			"xs", -- 304
			(((("木纹筹 " .. tostring(wood)) .. " · 铃纹筹 ") .. tostring(bell)) .. " · 碎片 ") .. tostring(scrap), -- 304
			cx, -- 304
			top + 24, -- 304
			toColor(PALETTE.silkDim), -- 305
			0.5, -- 305
			0.5, -- 305
			"Center", -- 305
			1.5, -- 305
			alpha, -- 305
			0.08 -- 305
		) -- 305
		local recipes = p.craftBench.recipes -- 306
		do -- 306
			local i = 0 -- 307
			while i < #recipes do -- 307
				local r = recipes[i + 1] -- 308
				local costText = "" -- 309
				local afford = true -- 310
				local costWood = r.cost.wood or 0 -- 311
				local costBell = r.cost.bell or 0 -- 312
				if costWood > 0 then -- 312
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "木 ") .. tostring(costWood) -- 314
					if wood < costWood then -- 314
						afford = false -- 316
					end -- 316
				end -- 316
				if costBell > 0 then -- 316
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "铃 ") .. tostring(costBell) -- 320
					if bell < costBell then -- 320
						afford = false -- 322
					end -- 322
				end -- 322
				local equipped = p.craftBench.equippedWeapon == r.id -- 325
				local state = r.crafted and "已做成" or (afford and "可制作" or "缺料") -- 326
				local mark = equipped and " ◈" or "" -- 327
				texts:put( -- 328
					"xs", -- 328
					((((r.name .. " · ") .. costText) .. " · ") .. state) .. mark, -- 328
					cx, -- 328
					top + 56 + i * 26, -- 328
					toColor(equipped and PALETTE.cyanCore or (r.crafted and PALETTE.silkDim or PALETTE.textBright)), -- 329
					0.5, -- 330
					0.5, -- 330
					"Center", -- 330
					1.6, -- 330
					alpha, -- 330
					0.08 -- 330
				) -- 330
				i = i + 1 -- 307
			end -- 307
		end -- 307
		local firstMade = p.craftBench.firstCraftDone and " · 首制完成" or "" -- 332
		texts:put( -- 333
			"xs", -- 333
			"E 制作 · Q 装备 · Esc 离开" .. firstMade, -- 333
			cx, -- 333
			top + 128, -- 333
			toColor(PALETTE.amber), -- 334
			0.5, -- 334
			0.5, -- 334
			"Center", -- 334
			1.5, -- 334
			alpha, -- 334
			0.06 -- 334
		) -- 334
	end -- 334
	if p.reloadOpen then -- 334
		local bw = 400 -- 338
		local cx = w * 0.5 -- 339
		local by = h - 64 -- 340
		local ratio = math.max( -- 341
			0, -- 341
			math.min(1, p.reloadAnswerTicks / 240) -- 341
		) -- 341
		local effect = p.reloadPendingEffect -- 342
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 343
		drawSilkVeil( -- 346
			uiDraw, -- 346
			uiArt, -- 346
			"hud_reload_veil", -- 346
			cx, -- 346
			by + 18, -- 346
			bw + 90, -- 346
			48, -- 346
			PALETTE.inkWash, -- 346
			0.76 * alpha, -- 346
			-1 -- 346
		) -- 346
		drawHairline( -- 347
			uiInkDraw, -- 347
			uiArt, -- 347
			"hud_reload_top", -- 347
			cx, -- 347
			by + 39, -- 347
			bw - 20, -- 347
			PALETTE.cyan, -- 347
			0.55 * alpha, -- 347
			false, -- 347
			2 -- 347
		) -- 347
		texts:put( -- 348
			"xs", -- 348
			label, -- 348
			cx, -- 348
			by + 26, -- 348
			toColor(PALETTE.textBright), -- 348
			0.5, -- 348
			0.5, -- 348
			"Center", -- 348
			1.8, -- 348
			alpha, -- 348
			0.08 -- 348
		) -- 348
		do -- 348
			local n = 0 -- 351
			while n < 9 do -- 351
				local col = n % 3 -- 352
				local row = math.floor(n / 3) -- 353
				local nx = cx + (col - 1) * 13 -- 354
				local ny = by + 50 + row * 12 -- 355
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 356
				local isEnd = n == 8 -- 357
				uiArt:tryPlace( -- 358
					"ink_enso_fine", -- 358
					"reload_node_" .. tostring(n), -- 358
					nx, -- 358
					ny, -- 358
					isEnd and 10 or 6, -- 358
					isEnd and 10 or 6, -- 358
					{ -- 358
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 359
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 360
						layer = 3 -- 360
					} -- 360
				) -- 360
				n = n + 1 -- 351
			end -- 351
		end -- 351
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
				toColor(PALETTE.cyan, 220 * alpha) -- 369
			) -- 369
			uiInkDraw:drawSegment( -- 370
				Vec2(pbx, pby), -- 370
				Vec2(pbx + pbw * ratio, pby), -- 370
				1, -- 370
				toColor(PALETTE.cyanCore, 160 * alpha) -- 370
			) -- 370
		end -- 370
	end -- 370
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 370
		local g = p.room.story.gate -- 376
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 376
			local bw = 400 -- 379
			local cx = w * 0.5 -- 380
			local by = h - 64 -- 381
			local tied = p.phase == "gate-hand" -- 382
			local ratio = tied and 1 or math.max( -- 383
				0, -- 383
				math.min( -- 383
					1, -- 383
					p.handTicks / math.max(1, p.handNeedTicks) -- 383
				) -- 383
			) -- 383
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 384
			drawSilkVeil( -- 388
				uiDraw, -- 388
				uiArt, -- 388
				"hud_hand_veil", -- 388
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
				"hud_hand_top", -- 389
				cx, -- 389
				by + 39, -- 389
				bw - 20, -- 389
				PALETTE.amber, -- 389
				0.55 * alpha, -- 389
				false, -- 389
				2 -- 389
			) -- 389
			texts:put( -- 390
				"xs", -- 390
				label, -- 390
				cx, -- 390
				by + 26, -- 390
				toColor(PALETTE.textBright), -- 390
				0.5, -- 390
				0.5, -- 390
				"Center", -- 390
				1.8, -- 390
				alpha, -- 390
				0.08 -- 390
			) -- 390
			local pbw = bw - 80 -- 392
			local pbx = cx - pbw * 0.5 -- 393
			local pby = by + 9 -- 394
			uiInkDraw:drawSegment( -- 395
				Vec2(pbx, pby), -- 395
				Vec2(pbx + pbw, pby), -- 395
				1.4, -- 395
				toColor(PALETTE.silkDim, 115 * alpha) -- 395
			) -- 395
			if ratio > 0.002 then -- 395
				uiInkDraw:drawSegment( -- 397
					Vec2(pbx, pby), -- 397
					Vec2(pbx + pbw * ratio, pby), -- 397
					2.8, -- 397
					toColor(PALETTE.amber, 230 * alpha) -- 397
				) -- 397
				uiInkDraw:drawSegment( -- 398
					Vec2(pbx, pby), -- 398
					Vec2(pbx + pbw * ratio, pby), -- 398
					1, -- 398
					toColor(PALETTE.amberCore, 165 * alpha) -- 398
				) -- 398
			end -- 398
			uiArt:tryPlace( -- 401
				"ink_enso_fine", -- 401
				"hand_knock_1", -- 401
				pbx + pbw * 0.62, -- 401
				pby, -- 401
				11, -- 401
				11, -- 401
				{ -- 401
					color = toColor(PALETTE.amber), -- 402
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 402
					layer = 3 -- 402
				} -- 402
			) -- 402
			uiArt:tryPlace( -- 404
				"ink_enso_fine", -- 404
				"hand_knock_2", -- 404
				pbx + pbw * 0.72, -- 404
				pby, -- 404
				11, -- 404
				11, -- 404
				{ -- 404
					color = toColor(PALETTE.amber), -- 405
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 405
					layer = 3 -- 405
				} -- 405
			) -- 405
		end -- 405
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 405
			local bw = 400 -- 409
			local cx = w * 0.5 -- 410
			local by = h - 64 -- 411
			local ratio = math.max( -- 412
				0, -- 412
				math.min( -- 412
					1, -- 412
					p.gateTick / math.max(1, g.holdTicks) -- 412
				) -- 412
			) -- 412
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 413
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 414
			drawSilkVeil( -- 416
				uiDraw, -- 416
				uiArt, -- 416
				"hud_gate_veil", -- 416
				cx, -- 416
				by + 18, -- 416
				bw + 90, -- 416
				48, -- 416
				PALETTE.inkWash, -- 416
				0.76 * alpha, -- 416
				-1 -- 416
			) -- 416
			drawHairline( -- 417
				uiInkDraw, -- 417
				uiArt, -- 417
				"hud_gate_top", -- 417
				cx, -- 417
				by + 39, -- 417
				bw - 20, -- 417
				PALETTE.rougeSoft, -- 417
				0.55 * alpha, -- 417
				false, -- 417
				2 -- 417
			) -- 417
			local idleNeedConfirmLabel = assistHintsEnabled and "绞盘待命 · 按 [E] 重新守门" or "绞盘待命" -- 419
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 420
			texts:put( -- 423
				"xs", -- 423
				label, -- 423
				cx, -- 423
				by + 26, -- 423
				toColor(PALETTE.textBright), -- 423
				0.5, -- 423
				0.5, -- 423
				"Center", -- 423
				1.8, -- 423
				alpha, -- 423
				0.08 -- 423
			) -- 423
			local pbw = bw - 80 -- 426
			local pbx = cx - pbw * 0.5 -- 427
			local pby = by + 9 -- 428
			uiInkDraw:drawSegment( -- 429
				Vec2(pbx, pby), -- 429
				Vec2(pbx + pbw, pby), -- 429
				1.4, -- 429
				toColor(PALETTE.silkDim, 115 * alpha) -- 429
			) -- 429
			if ratio > 0.002 then -- 429
				uiInkDraw:drawSegment( -- 431
					Vec2(pbx, pby), -- 431
					Vec2(pbx + pbw * ratio, pby), -- 431
					2.8, -- 431
					toColor(PALETTE.rouge, 230 * alpha) -- 431
				) -- 431
				uiInkDraw:drawSegment( -- 432
					Vec2(pbx, pby), -- 432
					Vec2(pbx + pbw * ratio, pby), -- 432
					1, -- 432
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 432
				) -- 432
			end -- 432
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 434
			local k = 0 -- 435
			do -- 435
				k = 0 -- 436
				while k < #waves do -- 436
					local wx = pbx + pbw * waves[k + 1] -- 437
					local passed = p.gateSpawned > k -- 438
					if passed then -- 438
						drawBlossomDot( -- 440
							uiInkDraw, -- 440
							uiArt, -- 440
							"gate_wave_" .. tostring(k), -- 440
							wx, -- 440
							pby, -- 440
							10, -- 440
							PALETTE.moonPale, -- 440
							0.92 * alpha, -- 440
							3 -- 440
						) -- 440
					else -- 440
						uiArt:tryPlace( -- 442
							"ink_enso_fine", -- 442
							"gate_wave_" .. tostring(k), -- 442
							wx, -- 442
							pby, -- 442
							11, -- 442
							11, -- 442
							{ -- 442
								color = toColor(PALETTE.rouge), -- 443
								opacity = 0.84 * alpha, -- 443
								layer = 3 -- 443
							} -- 443
						) -- 443
					end -- 443
					k = k + 1 -- 436
				end -- 436
			end -- 436
		end -- 436
		return -- 448
	end -- 448
	if not assistHintsEnabled then -- 448
		return -- 453
	end -- 453
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 453
		local cx = w * 0.5 -- 456
		local by = h - 44 -- 457
		local step1 = p.cartDocked -- 458
		local ____temp_0 -- 459
		if p.room.key == "checkpoint" then -- 459
			____temp_0 = p.gateOpen -- 459
		else -- 459
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 459
		end -- 459
		local step2 = ____temp_0 -- 459
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 460
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 461
		drawSilkVeil( -- 463
			uiDraw, -- 463
			uiArt, -- 463
			"hud_obj_veil", -- 463
			cx, -- 463
			by, -- 463
			380, -- 463
			34, -- 463
			PALETTE.inkWash, -- 463
			0.58 * alpha, -- 463
			-1 -- 463
		) -- 463
		local x1 = cx - 134 -- 465
		if step1 then -- 465
			drawBlossomDot( -- 467
				uiInkDraw, -- 467
				uiArt, -- 467
				"obj_m1", -- 467
				x1, -- 467
				by, -- 467
				11, -- 467
				PALETTE.emerald, -- 467
				0.94 * alpha, -- 467
				3 -- 467
			) -- 467
		else -- 467
			uiArt:tryPlace( -- 469
				"ink_enso_fine", -- 469
				"obj_m1", -- 469
				x1, -- 469
				by, -- 469
				11, -- 469
				11, -- 469
				{ -- 469
					color = toColor(PALETTE.silkLine), -- 469
					opacity = 0.72 * alpha, -- 469
					layer = 3 -- 469
				} -- 469
			) -- 469
		end -- 469
		texts:put( -- 471
			"xs", -- 471
			t1, -- 471
			x1 + 13, -- 471
			by, -- 471
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 471
			0, -- 471
			0.5, -- 471
			"Left", -- 471
			1, -- 471
			alpha, -- 471
			0.08 -- 471
		) -- 471
		local x2 = cx + 18 -- 473
		if step2 then -- 473
			drawBlossomDot( -- 475
				uiInkDraw, -- 475
				uiArt, -- 475
				"obj_m2", -- 475
				x2, -- 475
				by, -- 475
				11, -- 475
				PALETTE.emerald, -- 475
				0.94 * alpha, -- 475
				3 -- 475
			) -- 475
		else -- 475
			uiArt:tryPlace( -- 477
				"ink_enso_fine", -- 477
				"obj_m2", -- 477
				x2, -- 477
				by, -- 477
				11, -- 477
				11, -- 477
				{ -- 477
					color = toColor(PALETTE.silkDim), -- 477
					opacity = 0.62 * alpha, -- 477
					layer = 3 -- 477
				} -- 477
			) -- 477
		end -- 477
		texts:put( -- 479
			"xs", -- 479
			t2, -- 479
			x2 + 13, -- 479
			by, -- 479
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 479
			0, -- 479
			0.5, -- 479
			"Left", -- 479
			1, -- 479
			alpha, -- 479
			0.08 -- 479
		) -- 479
	end -- 479
end -- 281
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 483
	local bob = math.sin(self.time * 3.4) * 2.8 -- 493
	local viewW = cam.viewW / uiScale -- 494
	local viewH = cam.viewH / uiScale -- 495
	local i = 0 -- 496
	do -- 496
		i = 0 -- 497
		while i < #prompts do -- 497
			local pr = prompts[i + 1] -- 498
			local keyW = math.max( -- 499
				24, -- 499
				visualTextWidth(pr.keyTag, 15) + 16 -- 499
			) -- 499
			local labelW = visualTextWidth(pr.label, 15) -- 500
			local pillW = keyW + labelW + 24 -- 501
			local padX = math.max(115, pillW * 0.5 + 24) -- 502
			local sx = math.max( -- 503
				padX, -- 503
				math.min( -- 503
					viewW - padX, -- 503
					cam:sx(pr.x) / uiScale -- 503
				) -- 503
			) -- 503
			local sy = math.max( -- 504
				96, -- 504
				math.min( -- 504
					viewH - 110, -- 504
					cam:sy(pr.y) / uiScale + bob -- 504
				) -- 504
			) -- 504
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 505
			uiInkDraw:drawSegment( -- 508
				Vec2(sx, sy - 14), -- 508
				Vec2(sx, sy - 27), -- 508
				0.8, -- 508
				toColor(accent, 135 * alpha) -- 508
			) -- 508
			drawBlossomDot( -- 509
				uiInkDraw, -- 509
				uiArt, -- 509
				"wp_anchor_" .. tostring(i), -- 509
				sx, -- 509
				sy - 28, -- 509
				7, -- 509
				accent, -- 509
				0.85 * alpha, -- 509
				3 -- 509
			) -- 509
			local px = sx - pillW * 0.5 -- 511
			local py = sy - 12 -- 512
			drawSilkVeil( -- 514
				uiDraw, -- 514
				uiArt, -- 514
				"wp_bg_" .. tostring(i), -- 514
				sx, -- 514
				py + 12, -- 514
				pillW + 40, -- 514
				32, -- 514
				PALETTE.inkWash, -- 514
				0.78 * alpha, -- 514
				0 -- 514
			) -- 514
			drawHairline( -- 515
				uiInkDraw, -- 515
				uiArt, -- 515
				"wp_line_" .. tostring(i), -- 515
				sx, -- 515
				py + 24, -- 515
				pillW + 4, -- 515
				accent, -- 515
				0.45 * alpha, -- 515
				false, -- 515
				2 -- 515
			) -- 515
			drawSilkKeycap( -- 516
				uiInkDraw, -- 516
				texts, -- 516
				px + 2, -- 516
				py + 2, -- 516
				keyW, -- 516
				20, -- 516
				pr.keyTag, -- 516
				accent, -- 516
				alpha, -- 516
				pr.urgent -- 516
			) -- 516
			texts:put( -- 517
				"xs", -- 517
				pr.label, -- 517
				px + keyW + 12, -- 517
				py + 12, -- 517
				toColor(PALETTE.textBright), -- 517
				0, -- 517
				0.5, -- 517
				"Left", -- 517
				0.8, -- 517
				alpha, -- 517
				0.08 -- 517
			) -- 517
			i = i + 1 -- 497
		end -- 497
	end -- 497
end -- 483
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 521
	local mx = p.aimX / uiScale -- 530
	local my = p.aimY / uiScale -- 531
	if mx <= 0 and my <= 0 then -- 531
		return -- 533
	end -- 533
	if p.childMode then -- 533
		local aiming = p.room.key == "village" and p.hasBottle -- 537
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 538
		uiInkDraw:drawDot( -- 539
			Vec2(mx, my), -- 539
			aiming and 2 or 1.6, -- 539
			toColor(col, aiming and 215 or 120) -- 539
		) -- 539
		if aiming then -- 539
			local sz = p.aimHold > 0 and 32 or 24 -- 541
			uiArt:tryPlace( -- 542
				"ink_enso_fine", -- 542
				"reticle_child", -- 542
				mx, -- 542
				my, -- 542
				sz, -- 542
				sz, -- 542
				{ -- 542
					color = toColor(PALETTE.amberCore), -- 543
					opacity = 0.82, -- 543
					angle = self.time * 24, -- 543
					layer = 5 -- 543
				} -- 543
			) -- 543
		end -- 543
		return -- 546
	end -- 546
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 549
	local onEnemy = false -- 550
	local i = 0 -- 551
	do -- 551
		i = 0 -- 552
		while i < #p.enemies do -- 552
			local e = p.enemies[i + 1] -- 553
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 554
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 554
				onEnemy = true -- 556
			end -- 556
			i = i + 1 -- 552
		end -- 552
	end -- 552
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 560
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 561
	local arm = onEnemy and 8.5 or 9.5 -- 562
	local bg = Color(10, 12, 18, 160) -- 563
	uiInkDraw:drawSegment( -- 565
		Vec2(mx - gap - arm, my), -- 565
		Vec2(mx - gap, my), -- 565
		2.1, -- 565
		bg -- 565
	) -- 565
	uiInkDraw:drawSegment( -- 566
		Vec2(mx + gap, my), -- 566
		Vec2(mx + gap + arm, my), -- 566
		2.1, -- 566
		bg -- 566
	) -- 566
	uiInkDraw:drawSegment( -- 567
		Vec2(mx, my - gap - arm), -- 567
		Vec2(mx, my - gap), -- 567
		2.1, -- 567
		bg -- 567
	) -- 567
	uiInkDraw:drawSegment( -- 568
		Vec2(mx, my + gap), -- 568
		Vec2(mx, my + gap + arm), -- 568
		2.1, -- 568
		bg -- 568
	) -- 568
	uiInkDraw:drawSegment( -- 570
		Vec2(mx - gap - arm, my), -- 570
		Vec2(mx - gap, my), -- 570
		1.1, -- 570
		toColor(col, 230) -- 570
	) -- 570
	uiInkDraw:drawSegment( -- 571
		Vec2(mx + gap, my), -- 571
		Vec2(mx + gap + arm, my), -- 571
		1.1, -- 571
		toColor(col, 230) -- 571
	) -- 571
	uiInkDraw:drawSegment( -- 572
		Vec2(mx, my - gap - arm), -- 572
		Vec2(mx, my - gap), -- 572
		1.1, -- 572
		toColor(col, 230) -- 572
	) -- 572
	uiInkDraw:drawSegment( -- 573
		Vec2(mx, my + gap), -- 573
		Vec2(mx, my + gap + arm), -- 573
		1.1, -- 573
		toColor(col, 230) -- 573
	) -- 573
	uiInkDraw:drawDot( -- 574
		Vec2(mx, my), -- 574
		1.8, -- 574
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 574
	) -- 574
	if onEnemy then -- 574
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 577
		uiArt:tryPlace( -- 578
			"ink_enso_fine", -- 578
			"reticle_lock", -- 578
			mx, -- 578
			my, -- 578
			sz, -- 578
			sz, -- 578
			{ -- 578
				color = toColor(PALETTE.rouge), -- 579
				opacity = 0.88, -- 579
				angle = self.time * 38, -- 579
				layer = 5 -- 579
			} -- 579
		) -- 579
		fillRadialGlow( -- 581
			uiGlow, -- 581
			mx, -- 581
			my, -- 581
			16, -- 581
			16, -- 581
			toColor(PALETTE.rouge, 30), -- 581
			Color(182, 58, 56, 0), -- 581
			10 -- 581
		) -- 581
	end -- 581
end -- 521
return ____exports -- 521