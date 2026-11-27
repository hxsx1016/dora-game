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
local ____run = require("Script.watch.run") -- 11
local talentNames = ____run.talentNames -- 11
local ____depth = require("Script.watch.depth") -- 12
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 12
local ____escort = require("Script.watch.escort") -- 13
local FEAR_MAX = ____escort.FEAR_MAX -- 13
local ____adapter = require("Script.watch.fe.adapter") -- 14
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 14
local ____theme = require("Script.watch.fe.theme") -- 19
local PALETTE = ____theme.PALETTE -- 20
local drawBlossomDot = ____theme.drawBlossomDot -- 21
local drawHairline = ____theme.drawHairline -- 22
local drawSilkKeycap = ____theme.drawSilkKeycap -- 23
local drawSilkVeil = ____theme.drawSilkVeil -- 24
local fillRadialGlow = ____theme.fillRadialGlow -- 25
local themeOf = ____theme.themeOf -- 26
local toColor = ____theme.toColor -- 27
local visualTextWidth = ____theme.visualTextWidth -- 28
____exports.HudRenderer = __TS__Class() -- 31
local HudRenderer = ____exports.HudRenderer -- 31
HudRenderer.name = "HudRenderer" -- 31
function HudRenderer.prototype.____constructor(self) -- 31
	self.ghostHp = 3 -- 33
	self.time = 0 -- 34
end -- 31
function HudRenderer.prototype.reset(self, p) -- 36
	self.ghostHp = p ~= nil and p.hp or 3 -- 37
end -- 36
function HudRenderer.prototype.update(self, dt, p) -- 40
	self.time = self.time + dt -- 41
	if self.ghostHp > p.hp then -- 41
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 43
	else -- 43
		self.ghostHp = p.hp -- 45
	end -- 45
end -- 40
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale, assistHintsEnabled, suppressReticle) -- 49
	if assistHintsEnabled == nil then -- 49
		assistHintsEnabled = false -- 60
	end -- 60
	if suppressReticle == nil then -- 60
		suppressReticle = false -- 61
	end -- 61
	local w = cam.viewW / uiScale -- 63
	local h = cam.viewH / uiScale -- 64
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 66
	if hudAlpha > 0.05 then -- 66
		if p.childMode then -- 66
			self:drawChildStatus( -- 70
				uiDraw, -- 70
				uiInkDraw, -- 70
				uiArt, -- 70
				texts, -- 70
				p, -- 70
				h, -- 70
				hudAlpha, -- 70
				assistHintsEnabled -- 70
			) -- 70
		else -- 70
			self:drawSoldierStatus( -- 72
				uiDraw, -- 72
				uiInkDraw, -- 72
				uiArt, -- 72
				texts, -- 72
				p, -- 72
				h, -- 72
				hudAlpha, -- 72
				assistHintsEnabled -- 72
			) -- 72
		end -- 72
		self:drawChapterBadge( -- 75
			uiDraw, -- 75
			uiArt, -- 75
			texts, -- 75
			p, -- 75
			w, -- 75
			h, -- 75
			hudAlpha -- 75
		) -- 75
		self:drawContextualObjective( -- 76
			uiDraw, -- 76
			uiInkDraw, -- 76
			uiArt, -- 76
			texts, -- 76
			p, -- 76
			w, -- 76
			h, -- 76
			hudAlpha, -- 76
			assistHintsEnabled -- 76
		) -- 76
		if assistHintsEnabled then -- 76
			local prompt = deriveWorldPrompt(p) -- 79
			if prompt ~= nil then -- 79
				self:drawWorldPrompts( -- 81
					uiDraw, -- 81
					uiInkDraw, -- 81
					uiArt, -- 81
					texts, -- 81
					{prompt}, -- 81
					cam, -- 81
					hudAlpha, -- 81
					uiScale -- 81
				) -- 81
			end -- 81
		end -- 81
		if vfx.deflectFlash > 0.25 then -- 81
			local dx = cam:sx(vfx.deflectX) / uiScale -- 86
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 87
			texts:put( -- 88
				"sm", -- 88
				"掩体挡下", -- 88
				dx, -- 88
				dy, -- 88
				toColor(PALETTE.textBright), -- 88
				0.5, -- 88
				0.5, -- 88
				"Center", -- 88
				2, -- 88
				vfx.deflectFlash, -- 88
				0.1 -- 88
			) -- 88
		end -- 88
	end -- 88
	if not suppressReticle then -- 88
		self:drawReticleOverlay( -- 93
			uiInkDraw, -- 93
			uiArt, -- 93
			uiGlow, -- 93
			p, -- 93
			cam, -- 93
			vfx, -- 93
			letterboxFrac, -- 93
			uiScale -- 93
		) -- 93
	end -- 93
end -- 49
function HudRenderer.prototype.talentCardRects(self, w, h, count) -- 98
	local out = {} -- 99
	if count <= 0 then -- 99
		return out -- 101
	end -- 101
	local cardW = 204 -- 103
	local cardH = 38 -- 104
	local gap = 14 -- 105
	local totalW = count * cardW + (count - 1) * gap -- 106
	local startX = (w - totalW) * 0.5 -- 107
	local y = h - 108 -- 108
	local i = 0 -- 109
	do -- 109
		i = 0 -- 110
		while i < count do -- 110
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 111
			i = i + 1 -- 110
		end -- 110
	end -- 110
	return out -- 113
end -- 98
function HudRenderer.prototype.drawReticleOverlay(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale) -- 117
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 117
		self:drawReticle( -- 129
			uiInkDraw, -- 129
			uiArt, -- 129
			uiGlow, -- 129
			p, -- 129
			cam, -- 129
			vfx, -- 129
			uiScale -- 129
		) -- 129
	end -- 129
end -- 117
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 133
	local bx = 28 -- 143
	local by = h - 72 -- 144
	local lowHp = p.hp <= 1 -- 145
	drawSilkVeil( -- 148
		uiDraw, -- 148
		uiArt, -- 148
		"hud_soldier_veil", -- 148
		bx + 150, -- 148
		by + 24, -- 148
		340, -- 148
		56, -- 148
		PALETTE.inkWash, -- 148
		0.62 * alpha, -- 148
		-1 -- 148
	) -- 148
	texts:put( -- 151
		"md", -- 151
		"戍", -- 151
		bx + 16, -- 151
		by + 25, -- 151
		toColor(lowHp and PALETTE.rouge or PALETTE.cyanCore), -- 151
		0.5, -- 151
		0.5, -- 151
		"Center", -- 151
		0, -- 151
		alpha, -- 151
		0.1 -- 151
	) -- 151
	uiInkDraw:drawSegment( -- 152
		Vec2(bx + 32, by + 9), -- 152
		Vec2(bx + 32, by + 40), -- 152
		0.8, -- 152
		toColor(PALETTE.silkDim, 130 * alpha) -- 152
	) -- 152
	texts:put( -- 154
		"xs", -- 154
		"周戍 · 体力", -- 154
		bx + 44, -- 154
		by + 36, -- 154
		toColor(PALETTE.textMid), -- 154
		0, -- 154
		0.5, -- 154
		"Left", -- 154
		1.4, -- 154
		alpha, -- 154
		0.08 -- 154
	) -- 154
	local segCount = math.max(1, p.maxHp) -- 157
	local barX = bx + 44 -- 158
	local barY = by + 16 -- 159
	local segW = 54 -- 160
	local segH = 9 -- 161
	local gap = 8 -- 162
	local i = 0 -- 164
	do -- 164
		i = 0 -- 165
		while i < segCount do -- 165
			local sx = barX + i * (segW + gap) -- 166
			local scx = sx + segW * 0.5 -- 167
			if not uiArt:tryPlace( -- 167
				"ink_bamboo_slot", -- 168
				"hp_slot_" .. tostring(i), -- 168
				scx, -- 168
				barY, -- 168
				segW, -- 168
				segH, -- 168
				{ -- 168
					color = toColor(PALETTE.silkDim), -- 169
					opacity = 0.72 * alpha, -- 169
					layer = 1 -- 169
				} -- 169
			) then -- 169
				uiInkDraw:drawRect( -- 171
					Rect(sx, barY - 3, segW, 6), -- 171
					Color(0, 0, 0, 0), -- 171
					0.8, -- 171
					toColor(PALETTE.silkDim, 145 * alpha) -- 171
				) -- 171
			end -- 171
			if self.ghostHp > i and self.ghostHp > p.hp then -- 171
				local frac = math.min(1, self.ghostHp - i) -- 174
				uiInkDraw:drawRect( -- 175
					Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), -- 175
					toColor(PALETTE.crimsonCore, 150 * alpha) -- 175
				) -- 175
			end -- 175
			if p.hp > i then -- 175
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7) or 1 -- 178
				local fillCol = lowHp and PALETTE.rouge or PALETTE.moonPale -- 179
				if not uiArt:tryPlace( -- 179
					"ink_bamboo_slip", -- 180
					"hp_fill_" .. tostring(i), -- 180
					scx, -- 180
					barY, -- 180
					segW, -- 180
					segH, -- 180
					{ -- 180
						color = toColor(fillCol), -- 181
						opacity = 0.94 * alpha * pulse, -- 181
						layer = 2 -- 181
					} -- 181
				) then -- 181
					uiInkDraw:drawRect( -- 183
						Rect(sx + 2, barY - 2.5, segW - 4, 5), -- 183
						toColor(fillCol, 230 * alpha * pulse) -- 183
					) -- 183
				end -- 183
			end -- 183
			i = i + 1 -- 165
		end -- 165
	end -- 165
	local covX = barX + segCount * (segW + gap) + 6 -- 189
	local hasAliveEnemy = false -- 190
	do -- 190
		i = 0 -- 191
		while i < #p.enemies do -- 191
			if p.enemies[i + 1].alive then -- 191
				hasAliveEnemy = true -- 193
				break -- 194
			end -- 194
			i = i + 1 -- 191
		end -- 191
	end -- 191
	if p.coverHug then -- 191
		if hasAliveEnemy and not p.coverBlocking then -- 191
			uiInkDraw:drawRect( -- 199
				Rect(covX, barY - 9, 72, 18), -- 199
				toColor(PALETTE.inkWarm, 185 * alpha), -- 199
				0.8, -- 199
				toColor(PALETTE.amber, 200 * alpha) -- 199
			) -- 199
			texts:put( -- 200
				"xs", -- 200
				"背向掩体", -- 200
				covX + 36, -- 200
				barY, -- 200
				toColor(PALETTE.amberCore), -- 200
				0.5, -- 200
				0.5, -- 200
				"Center", -- 200
				0.6, -- 200
				alpha, -- 200
				0 -- 200
			) -- 200
		else -- 200
			uiInkDraw:drawRect( -- 202
				Rect(covX, barY - 9, 54, 18), -- 202
				toColor(PALETTE.cyanDim, 165 * alpha), -- 202
				0.8, -- 202
				toColor(PALETTE.cyanCore, 180 * alpha) -- 202
			) -- 202
			texts:put( -- 203
				"xs", -- 203
				"掩体中", -- 203
				covX + 27, -- 203
				barY, -- 203
				toColor(PALETTE.textBright), -- 203
				0.5, -- 203
				0.5, -- 203
				"Center", -- 203
				0.6, -- 203
				alpha, -- 203
				0 -- 203
			) -- 203
		end -- 203
	elseif p.coverNear then -- 203
		uiInkDraw:drawRect( -- 206
			Rect(covX, barY - 9, 54, 18), -- 206
			Color( -- 206
				14, -- 206
				17, -- 206
				25, -- 206
				math.floor(150 * alpha + 0.5) -- 206
			), -- 206
			0.8, -- 206
			toColor(PALETTE.silkLine, 165 * alpha) -- 206
		) -- 206
		texts:put( -- 207
			"xs", -- 207
			"可贴靠", -- 207
			covX + 27, -- 207
			barY, -- 207
			toColor(PALETTE.textMid), -- 207
			0.5, -- 207
			0.5, -- 207
			"Center", -- 207
			0.6, -- 207
			alpha, -- 207
			0.08 -- 207
		) -- 207
	end -- 207
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 207
		local subY = by - 24 -- 212
		local frozen = p.escort.state == "frozen" -- 213
		local calming = p.escort.state == "calming" -- 214
		drawSilkVeil( -- 216
			uiDraw, -- 216
			uiArt, -- 216
			"hud_fear_veil", -- 216
			bx + 126, -- 216
			subY + 6, -- 216
			260, -- 216
			30, -- 216
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 216
			0.64 * alpha, -- 216
			-1 -- 216
		) -- 216
		texts:put( -- 217
			"xs", -- 217
			"小满 · 惊惧", -- 217
			bx + 14, -- 217
			subY + 6, -- 217
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 217
			0, -- 217
			0.5, -- 217
			"Left", -- 217
			1, -- 217
			alpha, -- 217
			0.08 -- 217
		) -- 217
		local k = 0 -- 219
		do -- 219
			k = 0 -- 220
			while k < FEAR_MAX do -- 220
				local dx = bx + 114 + k * 20 -- 221
				local dy = subY + 6 -- 222
				local lit = k < p.escort.fear -- 223
				local dc = frozen and PALETTE.rouge or PALETTE.amber -- 224
				uiArt:tryPlace( -- 225
					"ink_enso_fine", -- 225
					"fear_ring_" .. tostring(k), -- 225
					dx, -- 225
					dy, -- 225
					14, -- 225
					14, -- 225
					{ -- 225
						color = toColor(lit and dc or PALETTE.silkLine), -- 226
						opacity = (lit and 0.92 or 0.64) * alpha, -- 226
						layer = 2 -- 226
					} -- 226
				) -- 226
				if lit then -- 226
					drawBlossomDot( -- 229
						uiInkDraw, -- 229
						uiArt, -- 229
						"fear_dot_" .. tostring(k), -- 229
						dx, -- 229
						dy, -- 229
						10, -- 229
						dc, -- 229
						0.96 * alpha, -- 229
						3 -- 229
					) -- 229
				end -- 229
				k = k + 1 -- 220
			end -- 220
		end -- 220
		if frozen then -- 220
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7) -- 234
			if assistHintsEnabled then -- 234
				drawSilkKeycap( -- 236
					uiInkDraw, -- 236
					texts, -- 236
					bx + 170, -- 236
					subY - 5, -- 236
					22, -- 236
					22, -- 236
					"E", -- 236
					PALETTE.rouge, -- 236
					alpha * pulse, -- 236
					true -- 236
				) -- 236
				texts:put( -- 237
					"xs", -- 237
					"轻敲安抚", -- 237
					bx + 198, -- 237
					subY + 6, -- 237
					toColor(PALETTE.crimsonCore), -- 237
					0, -- 237
					0.5, -- 237
					"Left", -- 237
					0.8, -- 237
					alpha * pulse, -- 237
					0.08 -- 237
				) -- 237
			else -- 237
				texts:put( -- 239
					"xs", -- 239
					"受惊停步", -- 239
					bx + 172, -- 239
					subY + 6, -- 239
					toColor(PALETTE.crimsonCore), -- 239
					0, -- 239
					0.5, -- 239
					"Left", -- 239
					0.8, -- 239
					alpha * pulse, -- 239
					0.08 -- 239
				) -- 239
			end -- 239
		elseif calming then -- 239
			texts:put( -- 242
				"xs", -- 242
				"轻敲安抚中", -- 242
				bx + 172, -- 242
				subY + 6, -- 242
				toColor(PALETTE.emerald), -- 242
				0, -- 242
				0.5, -- 242
				"Left", -- 242
				0.8, -- 242
				alpha, -- 242
				0.08 -- 242
			) -- 242
		end -- 242
	end -- 242
	local ranks = p:getStoryTalentRanks() -- 247
	if ranks ~= nil then -- 247
		local parts = {} -- 249
		if ranks.vitality > 0 then -- 249
			parts[#parts + 1] = "厚甲" .. tostring(ranks.vitality) -- 250
		end -- 250
		if ranks.reload > 0 then -- 250
			parts[#parts + 1] = "熟铳" .. tostring(ranks.reload) -- 251
		end -- 251
		if ranks.guard > 0 then -- 251
			parts[#parts + 1] = "护身" .. tostring(ranks.guard) -- 252
		end -- 252
		if ranks.craft > 0 then -- 252
			parts[#parts + 1] = "巧手" .. tostring(ranks.craft) -- 253
		end -- 253
		if #parts > 0 then -- 253
			local subY = by - 22 -- 255
			local txt = "本领 · " .. table.concat(parts, " · ") -- 256
			drawSilkVeil( -- 257
				uiDraw, -- 257
				uiArt, -- 257
				"hud_talent_ranks_veil", -- 257
				bx + 126, -- 257
				subY + 6, -- 257
				260, -- 257
				26, -- 257
				PALETTE.inkWash, -- 257
				0.56 * alpha, -- 257
				-1 -- 257
			) -- 257
			texts:put( -- 258
				"xs", -- 258
				txt, -- 258
				bx + 14, -- 258
				subY + 6, -- 258
				toColor(PALETTE.amberCore), -- 258
				0, -- 258
				0.5, -- 258
				"Left", -- 258
				0.8, -- 258
				alpha, -- 258
				0.08 -- 258
			) -- 258
		end -- 258
	elseif p.isCampaign and p.room.campaign ~= nil and (p.room.campaign.chapter == "S" or p.room.campaign.chapter == "C") then -- 258
		local inv = p.run.inventory -- 262
		local items = {} -- 263
		if inv.shield > 0 then -- 263
			items[#items + 1] = "残盾" .. tostring(inv.shield) -- 264
		end -- 264
		if inv.wedge > 0 then -- 264
			items[#items + 1] = "木楔" .. tostring(inv.wedge) -- 265
		end -- 265
		if inv.ammo > 0 then -- 265
			items[#items + 1] = "弹包" .. tostring(inv.ammo) -- 266
		end -- 266
		if inv.scrap > 0 then -- 266
			items[#items + 1] = "木料" .. tostring(inv.scrap) -- 267
		end -- 267
		local companionText = p.run.joined and "小满同行" or "小满等待" -- 268
		local summary = #items > 0 and (companionText .. " · ") .. table.concat(items, " ") or companionText -- 269
		local subY = by - 22 -- 270
		drawSilkVeil( -- 271
			uiDraw, -- 271
			uiArt, -- 271
			"hud_camp_veil", -- 271
			bx + 126, -- 271
			subY + 6, -- 271
			260, -- 271
			26, -- 271
			PALETTE.inkWash, -- 271
			0.54 * alpha, -- 271
			-1 -- 271
		) -- 271
		texts:put( -- 272
			"xs", -- 272
			summary, -- 272
			bx + 14, -- 272
			subY + 6, -- 272
			toColor(p.run.joined and PALETTE.cyanCore or PALETTE.amberCore), -- 272
			0, -- 272
			0.5, -- 272
			"Left", -- 272
			0.8, -- 272
			alpha, -- 272
			0.08 -- 272
		) -- 272
	end -- 272
end -- 133
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha, assistHintsEnabled) -- 276
	local bx = 28 -- 286
	local by = h - 68 -- 287
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 288
	local leadCol = alert and PALETTE.rouge or (p.player.crouch and PALETTE.emerald or PALETTE.amberCore) -- 289
	drawSilkVeil( -- 291
		uiDraw, -- 291
		uiArt, -- 291
		"hud_child_veil", -- 291
		bx + 144, -- 291
		by + 22, -- 291
		316, -- 291
		48, -- 291
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 291
		0.58 * alpha, -- 291
		-1 -- 291
	) -- 291
	texts:put( -- 292
		"md", -- 292
		alert and "危" or "满", -- 292
		bx + 16, -- 292
		by + 22, -- 292
		toColor(leadCol), -- 292
		0.5, -- 292
		0.5, -- 292
		"Center", -- 292
		0, -- 292
		alpha, -- 292
		0.1 -- 292
	) -- 292
	uiInkDraw:drawSegment( -- 293
		Vec2(bx + 32, by + 7), -- 293
		Vec2(bx + 32, by + 37), -- 293
		0.8, -- 293
		toColor(PALETTE.silkDim, 130 * alpha) -- 293
	) -- 293
	texts:put( -- 295
		"xs", -- 295
		"小满 · 潜行", -- 295
		bx + 44, -- 295
		by + 33, -- 295
		toColor(PALETTE.amberCore), -- 295
		0, -- 295
		0.5, -- 295
		"Left", -- 295
		1.4, -- 295
		alpha, -- 295
		0.08 -- 295
	) -- 295
	local posture = "轻步前行 · 保持隐蔽" -- 297
	local col = PALETTE.textMid -- 298
	if alert then -- 298
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 300
		col = PALETTE.crimsonCore -- 301
	elseif p.player.crouch then -- 301
		posture = "低姿伏行 · 匿迹于影" -- 303
		col = PALETTE.emerald -- 304
	elseif p.hasBottle then -- 304
		posture = assistHintsEnabled and "手持陶瓶 · 按住 [F] 瞄投" or "手持陶瓶" -- 306
		col = PALETTE.amberCore -- 307
	end -- 307
	texts:put( -- 309
		"xs", -- 309
		posture, -- 309
		bx + 44, -- 309
		by + 12, -- 309
		toColor(col), -- 309
		0, -- 309
		0.5, -- 309
		"Left", -- 309
		0.6, -- 309
		alpha, -- 309
		0.08 -- 309
	) -- 309
end -- 276
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiArt, texts, p, w, h, alpha) -- 312
	local theme = themeOf(p.room.key) -- 321
	local rx = w - 32 -- 322
	local cy = h - 44 -- 323
	drawSilkVeil( -- 325
		uiDraw, -- 325
		uiArt, -- 325
		"hud_chap_veil", -- 325
		rx - 82, -- 325
		cy, -- 325
		240, -- 325
		44, -- 325
		PALETTE.inkWash, -- 325
		0.44 * alpha, -- 325
		-1 -- 325
	) -- 325
	texts:put( -- 326
		"xs", -- 326
		(theme.numeralZh .. " · ") .. theme.titleZh, -- 326
		rx, -- 326
		cy + 9, -- 326
		toColor(PALETTE.textBright), -- 326
		1, -- 326
		0.5, -- 326
		"Right", -- 326
		1.2, -- 326
		alpha, -- 326
		0.08 -- 326
	) -- 326
	texts:put( -- 327
		"xs", -- 327
		"Esc 暂歇", -- 327
		rx, -- 327
		cy - 11, -- 327
		toColor(PALETTE.textDim), -- 327
		1, -- 327
		0.5, -- 327
		"Right", -- 327
		1, -- 327
		0.78 * alpha, -- 327
		0.08 -- 327
	) -- 327
end -- 312
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha, assistHintsEnabled) -- 330
	local talentOffers = p:getStoryTalentOffers() -- 342
	if #talentOffers > 0 and not p.craftBench.active and not p.reloadOpen then -- 342
		local boxes = self:talentCardRects(w, h, #talentOffers) -- 344
		local cx = w * 0.5 -- 345
		local titleY = h - 54 -- 346
		drawSilkVeil( -- 347
			uiDraw, -- 347
			uiArt, -- 347
			"hud_talent_head_veil", -- 347
			cx, -- 347
			titleY, -- 347
			360, -- 347
			26, -- 347
			PALETTE.inkWash, -- 347
			0.72 * alpha, -- 347
			-1 -- 347
		) -- 347
		drawHairline( -- 348
			uiInkDraw, -- 348
			uiArt, -- 348
			"hud_talent_head_line", -- 348
			cx, -- 348
			titleY + 13, -- 348
			300, -- 348
			PALETTE.amber, -- 348
			0.52 * alpha, -- 348
			true, -- 348
			2 -- 348
		) -- 348
		texts:put( -- 349
			"xs", -- 349
			"护送本领三选一 · 按 1 / 2 / 3 或点击习得", -- 349
			cx, -- 349
			titleY, -- 349
			toColor(PALETTE.amberCore), -- 349
			0.5, -- 349
			0.5, -- 349
			"Center", -- 349
			1.2, -- 349
			alpha, -- 349
			0.08 -- 349
		) -- 349
		local ti = 0 -- 351
		do -- 351
			ti = 0 -- 352
			while ti < #talentOffers do -- 352
				local box = boxes[ti + 1] -- 353
				local bx = box.x -- 354
				local by = box.y -- 355
				local bw = box.width -- 356
				local bh = box.height -- 357
				local cy = by + bh * 0.5 -- 358
				uiDraw:drawRect( -- 359
					box, -- 359
					toColor( -- 359
						PALETTE.panelBgDeep, -- 359
						math.floor(215 * alpha + 0.5) -- 359
					), -- 359
					0.9, -- 359
					toColor( -- 359
						PALETTE.amber, -- 359
						math.floor(185 * alpha + 0.5) -- 359
					) -- 359
				) -- 359
				drawSilkKeycap( -- 360
					uiInkDraw, -- 360
					texts, -- 360
					bx + 8, -- 360
					cy - 11, -- 360
					22, -- 360
					22, -- 360
					"" .. tostring(ti + 1), -- 360
					PALETTE.amber, -- 360
					alpha, -- 360
					true -- 360
				) -- 360
				texts:put( -- 361
					"xs", -- 361
					talentNames[talentOffers[ti + 1]], -- 361
					bx + 38, -- 361
					cy, -- 361
					toColor(PALETTE.textBright), -- 361
					0, -- 361
					0.5, -- 361
					"Left", -- 361
					0.6, -- 361
					alpha, -- 361
					0.08 -- 361
				) -- 361
				ti = ti + 1 -- 352
			end -- 352
		end -- 352
	end -- 352
	if p.craftBench.active then -- 352
		local bw = 470 -- 368
		local cx = w * 0.5 -- 369
		local top = h * 0.32 -- 370
		drawSilkVeil( -- 371
			uiDraw, -- 371
			uiArt, -- 371
			"hud_bench_veil", -- 371
			cx, -- 371
			top + 118, -- 371
			bw + 64, -- 371
			208, -- 371
			PALETTE.inkWash, -- 371
			0.86 * alpha, -- 371
			-1 -- 371
		) -- 371
		texts:put( -- 372
			"xs", -- 372
			"工台 · 放她下来做一件", -- 372
			cx, -- 372
			top - 6, -- 372
			toColor(PALETTE.textBright), -- 372
			0.5, -- 372
			0.5, -- 372
			"Center", -- 372
			1.7, -- 372
			alpha, -- 372
			0.08 -- 372
		) -- 372
		local inv = p.craftBench.inventory -- 373
		local wood = inv.wood or 0 -- 374
		local bell = inv.bell or 0 -- 375
		local scrap = inv.scrap or 0 -- 376
		texts:put( -- 377
			"xs", -- 377
			(((("木纹筹 " .. tostring(wood)) .. " · 铃纹筹 ") .. tostring(bell)) .. " · 碎片 ") .. tostring(scrap), -- 377
			cx, -- 377
			top + 24, -- 377
			toColor(PALETTE.silkDim), -- 378
			0.5, -- 378
			0.5, -- 378
			"Center", -- 378
			1.5, -- 378
			alpha, -- 378
			0.08 -- 378
		) -- 378
		local recipes = p.craftBench.recipes -- 379
		do -- 379
			local i = 0 -- 380
			while i < #recipes do -- 380
				local r = recipes[i + 1] -- 381
				local costText = "" -- 382
				local afford = true -- 383
				local costWood = r.cost.wood or 0 -- 384
				local costBell = r.cost.bell or 0 -- 385
				if costWood > 0 then -- 385
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "木 ") .. tostring(costWood) -- 387
					if wood < costWood then -- 387
						afford = false -- 389
					end -- 389
				end -- 389
				if costBell > 0 then -- 389
					costText = ((costText .. (costText ~= "" and " + " or "")) .. "铃 ") .. tostring(costBell) -- 393
					if bell < costBell then -- 393
						afford = false -- 395
					end -- 395
				end -- 395
				local equipped = p.craftBench.equippedWeapon == r.id -- 398
				local state = r.crafted and "已做成" or (afford and "可制作" or "缺料") -- 399
				local mark = equipped and " ◈" or "" -- 400
				texts:put( -- 401
					"xs", -- 401
					((((r.name .. " · ") .. costText) .. " · ") .. state) .. mark, -- 401
					cx, -- 401
					top + 56 + i * 26, -- 401
					toColor(equipped and PALETTE.cyanCore or (r.crafted and PALETTE.silkDim or PALETTE.textBright)), -- 402
					0.5, -- 403
					0.5, -- 403
					"Center", -- 403
					1.6, -- 403
					alpha, -- 403
					0.08 -- 403
				) -- 403
				i = i + 1 -- 380
			end -- 380
		end -- 380
		local firstMade = p.craftBench.firstCraftDone and " · 首制完成" or "" -- 405
		texts:put( -- 406
			"xs", -- 406
			"E 制作 · Q 装备 · Esc 离开" .. firstMade, -- 406
			cx, -- 406
			top + 128, -- 406
			toColor(PALETTE.amber), -- 407
			0.5, -- 407
			0.5, -- 407
			"Center", -- 407
			1.5, -- 407
			alpha, -- 407
			0.06 -- 407
		) -- 407
	end -- 407
	if p.reloadOpen then -- 407
		local bw = 400 -- 411
		local cx = w * 0.5 -- 412
		local by = h - 64 -- 413
		local ratio = math.max( -- 414
			0, -- 414
			math.min(1, p.reloadAnswerTicks / 240) -- 414
		) -- 414
		local effect = p.reloadPendingEffect -- 415
		local label = effect ~= "" and "枪机复位 · " .. (effect == "push" and "推退" or (effect == "echo" and "回声引声源" or "照明照遮蔽")) or ("连线换弹 · " .. tostring(math.min(9, #p.reloadPath))) .. " / 9" -- 416
		drawSilkVeil( -- 419
			uiDraw, -- 419
			uiArt, -- 419
			"hud_reload_veil", -- 419
			cx, -- 419
			by + 18, -- 419
			bw + 90, -- 419
			48, -- 419
			PALETTE.inkWash, -- 419
			0.76 * alpha, -- 419
			-1 -- 419
		) -- 419
		drawHairline( -- 420
			uiInkDraw, -- 420
			uiArt, -- 420
			"hud_reload_top", -- 420
			cx, -- 420
			by + 39, -- 420
			bw - 20, -- 420
			PALETTE.cyan, -- 420
			0.55 * alpha, -- 420
			false, -- 420
			2 -- 420
		) -- 420
		texts:put( -- 421
			"xs", -- 421
			label, -- 421
			cx, -- 421
			by + 26, -- 421
			toColor(PALETTE.textBright), -- 421
			0.5, -- 421
			0.5, -- 421
			"Center", -- 421
			1.8, -- 421
			alpha, -- 421
			0.08 -- 421
		) -- 421
		do -- 421
			local n = 0 -- 424
			while n < 9 do -- 424
				local col = n % 3 -- 425
				local row = math.floor(n / 3) -- 426
				local nx = cx + (col - 1) * 13 -- 427
				local ny = by + 50 + row * 12 -- 428
				local inPath = __TS__ArrayIndexOf(p.reloadPath, n) >= 0 -- 429
				local isEnd = n == 8 -- 430
				uiArt:tryPlace( -- 431
					"ink_enso_fine", -- 431
					"reload_node_" .. tostring(n), -- 431
					nx, -- 431
					ny, -- 431
					isEnd and 10 or 6, -- 431
					isEnd and 10 or 6, -- 431
					{ -- 431
						color = toColor(isEnd and PALETTE.cyanCore or (inPath and PALETTE.amber or PALETTE.silkDim)), -- 432
						opacity = ((isEnd or inPath) and 0.92 or 0.4) * alpha, -- 433
						layer = 3 -- 433
					} -- 433
				) -- 433
				n = n + 1 -- 424
			end -- 424
		end -- 424
		local pbw = bw - 80 -- 437
		local pbx = cx - pbw * 0.5 -- 438
		local pby = by + 9 -- 439
		uiInkDraw:drawSegment( -- 440
			Vec2(pbx, pby), -- 440
			Vec2(pbx + pbw, pby), -- 440
			1.4, -- 440
			toColor(PALETTE.silkDim, 115 * alpha) -- 440
		) -- 440
		if ratio > 0.002 then -- 440
			uiInkDraw:drawSegment( -- 442
				Vec2(pbx, pby), -- 442
				Vec2(pbx + pbw * ratio, pby), -- 442
				2.8, -- 442
				toColor(PALETTE.cyan, 220 * alpha) -- 442
			) -- 442
			uiInkDraw:drawSegment( -- 443
				Vec2(pbx, pby), -- 443
				Vec2(pbx + pbw * ratio, pby), -- 443
				1, -- 443
				toColor(PALETTE.cyanCore, 160 * alpha) -- 443
			) -- 443
		end -- 443
	end -- 443
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 443
		local g = p.room.story.gate -- 449
		if p.phase == "gate-wait" or p.phase == "gate-hand" then -- 449
			local bw = 400 -- 452
			local cx = w * 0.5 -- 453
			local by = h - 64 -- 454
			local tied = p.phase == "gate-hand" -- 455
			local ratio = tied and 1 or math.max( -- 456
				0, -- 456
				math.min( -- 456
					1, -- 456
					p.handTicks / math.max(1, p.handNeedTicks) -- 456
				) -- 456
			) -- 456
			local label = tied and "我们走吧。" or (p.handTicks > 0 and (("牵起小满 · " .. tostring(p.handTicks)) .. " / ") .. tostring(p.handNeedTicks) or (p.handArmed and "按住 E · 把手伸给她" or "松开 E 再按住 · 把手伸给她")) -- 457
			drawSilkVeil( -- 461
				uiDraw, -- 461
				uiArt, -- 461
				"hud_hand_veil", -- 461
				cx, -- 461
				by + 18, -- 461
				bw + 90, -- 461
				48, -- 461
				PALETTE.inkWash, -- 461
				0.76 * alpha, -- 461
				-1 -- 461
			) -- 461
			drawHairline( -- 462
				uiInkDraw, -- 462
				uiArt, -- 462
				"hud_hand_top", -- 462
				cx, -- 462
				by + 39, -- 462
				bw - 20, -- 462
				PALETTE.amber, -- 462
				0.55 * alpha, -- 462
				false, -- 462
				2 -- 462
			) -- 462
			texts:put( -- 463
				"xs", -- 463
				label, -- 463
				cx, -- 463
				by + 26, -- 463
				toColor(PALETTE.textBright), -- 463
				0.5, -- 463
				0.5, -- 463
				"Center", -- 463
				1.8, -- 463
				alpha, -- 463
				0.08 -- 463
			) -- 463
			local pbw = bw - 80 -- 465
			local pbx = cx - pbw * 0.5 -- 466
			local pby = by + 9 -- 467
			uiInkDraw:drawSegment( -- 468
				Vec2(pbx, pby), -- 468
				Vec2(pbx + pbw, pby), -- 468
				1.4, -- 468
				toColor(PALETTE.silkDim, 115 * alpha) -- 468
			) -- 468
			if ratio > 0.002 then -- 468
				uiInkDraw:drawSegment( -- 470
					Vec2(pbx, pby), -- 470
					Vec2(pbx + pbw * ratio, pby), -- 470
					2.8, -- 470
					toColor(PALETTE.amber, 230 * alpha) -- 470
				) -- 470
				uiInkDraw:drawSegment( -- 471
					Vec2(pbx, pby), -- 471
					Vec2(pbx + pbw * ratio, pby), -- 471
					1, -- 471
					toColor(PALETTE.amberCore, 165 * alpha) -- 471
				) -- 471
			end -- 471
			uiArt:tryPlace( -- 474
				"ink_enso_fine", -- 474
				"hand_knock_1", -- 474
				pbx + pbw * 0.62, -- 474
				pby, -- 474
				11, -- 474
				11, -- 474
				{ -- 474
					color = toColor(PALETTE.amber), -- 475
					opacity = (p.knocks >= 1 and 0.9 or 0.45) * alpha, -- 475
					layer = 3 -- 475
				} -- 475
			) -- 475
			uiArt:tryPlace( -- 477
				"ink_enso_fine", -- 477
				"hand_knock_2", -- 477
				pbx + pbw * 0.72, -- 477
				pby, -- 477
				11, -- 477
				11, -- 477
				{ -- 477
					color = toColor(PALETTE.amber), -- 478
					opacity = (p.knocks >= 2 and 0.9 or 0.45) * alpha, -- 478
					layer = 3 -- 478
				} -- 478
			) -- 478
		end -- 478
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 478
			local bw = 400 -- 482
			local cx = w * 0.5 -- 483
			local by = h - 64 -- 484
			local ratio = math.max( -- 485
				0, -- 485
				math.min( -- 485
					1, -- 485
					p.gateTick / math.max(1, g.holdTicks) -- 485
				) -- 485
			) -- 485
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 486
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 487
			drawSilkVeil( -- 489
				uiDraw, -- 489
				uiArt, -- 489
				"hud_gate_veil", -- 489
				cx, -- 489
				by + 18, -- 489
				bw + 90, -- 489
				48, -- 489
				PALETTE.inkWash, -- 489
				0.76 * alpha, -- 489
				-1 -- 489
			) -- 489
			drawHairline( -- 490
				uiInkDraw, -- 490
				uiArt, -- 490
				"hud_gate_top", -- 490
				cx, -- 490
				by + 39, -- 490
				bw - 20, -- 490
				PALETTE.rougeSoft, -- 490
				0.55 * alpha, -- 490
				false, -- 490
				2 -- 490
			) -- 490
			local idleNeedConfirmLabel = assistHintsEnabled and "绞盘待命 · 按 [E] 重新守门" or "绞盘待命" -- 492
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and idleNeedConfirmLabel or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 493
			texts:put( -- 496
				"xs", -- 496
				label, -- 496
				cx, -- 496
				by + 26, -- 496
				toColor(PALETTE.textBright), -- 496
				0.5, -- 496
				0.5, -- 496
				"Center", -- 496
				1.8, -- 496
				alpha, -- 496
				0.08 -- 496
			) -- 496
			local pbw = bw - 80 -- 499
			local pbx = cx - pbw * 0.5 -- 500
			local pby = by + 9 -- 501
			uiInkDraw:drawSegment( -- 502
				Vec2(pbx, pby), -- 502
				Vec2(pbx + pbw, pby), -- 502
				1.4, -- 502
				toColor(PALETTE.silkDim, 115 * alpha) -- 502
			) -- 502
			if ratio > 0.002 then -- 502
				uiInkDraw:drawSegment( -- 504
					Vec2(pbx, pby), -- 504
					Vec2(pbx + pbw * ratio, pby), -- 504
					2.8, -- 504
					toColor(PALETTE.rouge, 230 * alpha) -- 504
				) -- 504
				uiInkDraw:drawSegment( -- 505
					Vec2(pbx, pby), -- 505
					Vec2(pbx + pbw * ratio, pby), -- 505
					1, -- 505
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 505
				) -- 505
			end -- 505
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 507
			local k = 0 -- 508
			do -- 508
				k = 0 -- 509
				while k < #waves do -- 509
					local wx = pbx + pbw * waves[k + 1] -- 510
					local passed = p.gateSpawned > k -- 511
					if passed then -- 511
						drawBlossomDot( -- 513
							uiInkDraw, -- 513
							uiArt, -- 513
							"gate_wave_" .. tostring(k), -- 513
							wx, -- 513
							pby, -- 513
							10, -- 513
							PALETTE.moonPale, -- 513
							0.92 * alpha, -- 513
							3 -- 513
						) -- 513
					else -- 513
						uiArt:tryPlace( -- 515
							"ink_enso_fine", -- 515
							"gate_wave_" .. tostring(k), -- 515
							wx, -- 515
							pby, -- 515
							11, -- 515
							11, -- 515
							{ -- 515
								color = toColor(PALETTE.rouge), -- 516
								opacity = 0.84 * alpha, -- 516
								layer = 3 -- 516
							} -- 516
						) -- 516
					end -- 516
					k = k + 1 -- 509
				end -- 509
			end -- 509
		end -- 509
		return -- 521
	end -- 521
	if not assistHintsEnabled then -- 521
		return -- 526
	end -- 526
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 526
		local cx = w * 0.5 -- 529
		local by = h - 44 -- 530
		local step1 = p.cartDocked -- 531
		local ____temp_0 -- 532
		if p.room.key == "checkpoint" then -- 532
			____temp_0 = p.gateOpen -- 532
		else -- 532
			____temp_0 = p.checkpoint >= p.room.arch.x1 -- 532
		end -- 532
		local step2 = ____temp_0 -- 532
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 533
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 534
		drawSilkVeil( -- 536
			uiDraw, -- 536
			uiArt, -- 536
			"hud_obj_veil", -- 536
			cx, -- 536
			by, -- 536
			380, -- 536
			34, -- 536
			PALETTE.inkWash, -- 536
			0.58 * alpha, -- 536
			-1 -- 536
		) -- 536
		local x1 = cx - 134 -- 538
		if step1 then -- 538
			drawBlossomDot( -- 540
				uiInkDraw, -- 540
				uiArt, -- 540
				"obj_m1", -- 540
				x1, -- 540
				by, -- 540
				11, -- 540
				PALETTE.emerald, -- 540
				0.94 * alpha, -- 540
				3 -- 540
			) -- 540
		else -- 540
			uiArt:tryPlace( -- 542
				"ink_enso_fine", -- 542
				"obj_m1", -- 542
				x1, -- 542
				by, -- 542
				11, -- 542
				11, -- 542
				{ -- 542
					color = toColor(PALETTE.silkLine), -- 542
					opacity = 0.72 * alpha, -- 542
					layer = 3 -- 542
				} -- 542
			) -- 542
		end -- 542
		texts:put( -- 544
			"xs", -- 544
			t1, -- 544
			x1 + 13, -- 544
			by, -- 544
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 544
			0, -- 544
			0.5, -- 544
			"Left", -- 544
			1, -- 544
			alpha, -- 544
			0.08 -- 544
		) -- 544
		local x2 = cx + 18 -- 546
		if step2 then -- 546
			drawBlossomDot( -- 548
				uiInkDraw, -- 548
				uiArt, -- 548
				"obj_m2", -- 548
				x2, -- 548
				by, -- 548
				11, -- 548
				PALETTE.emerald, -- 548
				0.94 * alpha, -- 548
				3 -- 548
			) -- 548
		else -- 548
			uiArt:tryPlace( -- 550
				"ink_enso_fine", -- 550
				"obj_m2", -- 550
				x2, -- 550
				by, -- 550
				11, -- 550
				11, -- 550
				{ -- 550
					color = toColor(PALETTE.silkDim), -- 550
					opacity = 0.62 * alpha, -- 550
					layer = 3 -- 550
				} -- 550
			) -- 550
		end -- 550
		texts:put( -- 552
			"xs", -- 552
			t2, -- 552
			x2 + 13, -- 552
			by, -- 552
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 552
			0, -- 552
			0.5, -- 552
			"Left", -- 552
			1, -- 552
			alpha, -- 552
			0.08 -- 552
		) -- 552
	end -- 552
end -- 330
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 556
	local bob = math.sin(self.time * 3.4) * 2.8 -- 566
	local viewW = cam.viewW / uiScale -- 567
	local viewH = cam.viewH / uiScale -- 568
	local i = 0 -- 569
	do -- 569
		i = 0 -- 570
		while i < #prompts do -- 570
			local pr = prompts[i + 1] -- 571
			local keyW = math.max( -- 572
				24, -- 572
				visualTextWidth(pr.keyTag, 15) + 16 -- 572
			) -- 572
			local labelW = visualTextWidth(pr.label, 15) -- 573
			local pillW = keyW + labelW + 24 -- 574
			local padX = math.max(115, pillW * 0.5 + 24) -- 575
			local sx = math.max( -- 576
				padX, -- 576
				math.min( -- 576
					viewW - padX, -- 576
					cam:sx(pr.x) / uiScale -- 576
				) -- 576
			) -- 576
			local sy = math.max( -- 577
				96, -- 577
				math.min( -- 577
					viewH - 110, -- 577
					cam:sy(pr.y) / uiScale + bob -- 577
				) -- 577
			) -- 577
			local accent = pr.urgent and PALETTE.rouge or PALETTE.silkLine -- 578
			uiInkDraw:drawSegment( -- 581
				Vec2(sx, sy - 14), -- 581
				Vec2(sx, sy - 27), -- 581
				0.8, -- 581
				toColor(accent, 135 * alpha) -- 581
			) -- 581
			drawBlossomDot( -- 582
				uiInkDraw, -- 582
				uiArt, -- 582
				"wp_anchor_" .. tostring(i), -- 582
				sx, -- 582
				sy - 28, -- 582
				7, -- 582
				accent, -- 582
				0.85 * alpha, -- 582
				3 -- 582
			) -- 582
			local px = sx - pillW * 0.5 -- 584
			local py = sy - 12 -- 585
			drawSilkVeil( -- 587
				uiDraw, -- 587
				uiArt, -- 587
				"wp_bg_" .. tostring(i), -- 587
				sx, -- 587
				py + 12, -- 587
				pillW + 40, -- 587
				32, -- 587
				PALETTE.inkWash, -- 587
				0.78 * alpha, -- 587
				0 -- 587
			) -- 587
			drawHairline( -- 588
				uiInkDraw, -- 588
				uiArt, -- 588
				"wp_line_" .. tostring(i), -- 588
				sx, -- 588
				py + 24, -- 588
				pillW + 4, -- 588
				accent, -- 588
				0.45 * alpha, -- 588
				false, -- 588
				2 -- 588
			) -- 588
			drawSilkKeycap( -- 589
				uiInkDraw, -- 589
				texts, -- 589
				px + 2, -- 589
				py + 2, -- 589
				keyW, -- 589
				20, -- 589
				pr.keyTag, -- 589
				accent, -- 589
				alpha, -- 589
				pr.urgent -- 589
			) -- 589
			texts:put( -- 590
				"xs", -- 590
				pr.label, -- 590
				px + keyW + 12, -- 590
				py + 12, -- 590
				toColor(PALETTE.textBright), -- 590
				0, -- 590
				0.5, -- 590
				"Left", -- 590
				0.8, -- 590
				alpha, -- 590
				0.08 -- 590
			) -- 590
			i = i + 1 -- 570
		end -- 570
	end -- 570
end -- 556
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 594
	local mx = p.aimX / uiScale -- 603
	local my = p.aimY / uiScale -- 604
	if mx <= 0 and my <= 0 then -- 604
		return -- 606
	end -- 606
	if p.childMode then -- 606
		local aiming = p.room.key == "village" and p.hasBottle -- 610
		local col = aiming and PALETTE.amberCore or PALETTE.silkDim -- 611
		uiInkDraw:drawDot( -- 612
			Vec2(mx, my), -- 612
			aiming and 2 or 1.6, -- 612
			toColor(col, aiming and 215 or 120) -- 612
		) -- 612
		if aiming then -- 612
			local sz = p.aimHold > 0 and 32 or 24 -- 614
			uiArt:tryPlace( -- 615
				"ink_enso_fine", -- 615
				"reticle_child", -- 615
				mx, -- 615
				my, -- 615
				sz, -- 615
				sz, -- 615
				{ -- 615
					color = toColor(PALETTE.amberCore), -- 616
					opacity = 0.82, -- 616
					angle = self.time * 24, -- 616
					layer = 5 -- 616
				} -- 616
			) -- 616
		end -- 616
		return -- 619
	end -- 619
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 622
	local onEnemy = false -- 623
	local i = 0 -- 624
	do -- 624
		i = 0 -- 625
		while i < #p.enemies do -- 625
			local e = p.enemies[i + 1] -- 626
			local ey = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 627
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= ey - 6 and wAim.y <= ey + e.h + 6 then -- 627
				onEnemy = true -- 629
			end -- 629
			i = i + 1 -- 625
		end -- 625
	end -- 625
	local col = onEnemy and PALETTE.rouge or PALETTE.textBright -- 633
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.72 -- 634
	local arm = onEnemy and 8.5 or 9.5 -- 635
	local bg = Color(10, 12, 18, 160) -- 636
	uiInkDraw:drawSegment( -- 638
		Vec2(mx - gap - arm, my), -- 638
		Vec2(mx - gap, my), -- 638
		2.1, -- 638
		bg -- 638
	) -- 638
	uiInkDraw:drawSegment( -- 639
		Vec2(mx + gap, my), -- 639
		Vec2(mx + gap + arm, my), -- 639
		2.1, -- 639
		bg -- 639
	) -- 639
	uiInkDraw:drawSegment( -- 640
		Vec2(mx, my - gap - arm), -- 640
		Vec2(mx, my - gap), -- 640
		2.1, -- 640
		bg -- 640
	) -- 640
	uiInkDraw:drawSegment( -- 641
		Vec2(mx, my + gap), -- 641
		Vec2(mx, my + gap + arm), -- 641
		2.1, -- 641
		bg -- 641
	) -- 641
	uiInkDraw:drawSegment( -- 643
		Vec2(mx - gap - arm, my), -- 643
		Vec2(mx - gap, my), -- 643
		1.1, -- 643
		toColor(col, 230) -- 643
	) -- 643
	uiInkDraw:drawSegment( -- 644
		Vec2(mx + gap, my), -- 644
		Vec2(mx + gap + arm, my), -- 644
		1.1, -- 644
		toColor(col, 230) -- 644
	) -- 644
	uiInkDraw:drawSegment( -- 645
		Vec2(mx, my - gap - arm), -- 645
		Vec2(mx, my - gap), -- 645
		1.1, -- 645
		toColor(col, 230) -- 645
	) -- 645
	uiInkDraw:drawSegment( -- 646
		Vec2(mx, my + gap), -- 646
		Vec2(mx, my + gap + arm), -- 646
		1.1, -- 646
		toColor(col, 230) -- 646
	) -- 646
	uiInkDraw:drawDot( -- 647
		Vec2(mx, my), -- 647
		1.8, -- 647
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.textBright, 240) -- 647
	) -- 647
	if onEnemy then -- 647
		local sz = 30 + math.sin(self.time * 11) * 1.8 -- 650
		uiArt:tryPlace( -- 651
			"ink_enso_fine", -- 651
			"reticle_lock", -- 651
			mx, -- 651
			my, -- 651
			sz, -- 651
			sz, -- 651
			{ -- 651
				color = toColor(PALETTE.rouge), -- 652
				opacity = 0.88, -- 652
				angle = self.time * 38, -- 652
				layer = 5 -- 652
			} -- 652
		) -- 652
		fillRadialGlow( -- 654
			uiGlow, -- 654
			mx, -- 654
			my, -- 654
			16, -- 654
			16, -- 654
			toColor(PALETTE.rouge, 30), -- 654
			Color(182, 58, 56, 0), -- 654
			10 -- 654
		) -- 654
	end -- 654
end -- 594
return ____exports -- 594