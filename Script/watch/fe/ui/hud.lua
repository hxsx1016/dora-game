-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____escort = require("Script.watch.escort") -- 14
local FEAR_MAX = ____escort.FEAR_MAX -- 14
local ____adapter = require("Script.watch.fe.adapter") -- 15
local deriveWorldPrompts = ____adapter.deriveWorldPrompts -- 15
local ____theme = require("Script.watch.fe.theme") -- 19
local PALETTE = ____theme.PALETTE -- 20
local drawDiamond = ____theme.drawDiamond -- 21
local fillRadialGlow = ____theme.fillRadialGlow -- 22
local fillSkewRect = ____theme.fillSkewRect -- 23
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
function HudRenderer.prototype.draw(self, uiDraw, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale) -- 47
	local w = cam.viewW / uiScale -- 57
	local h = cam.viewH / uiScale -- 58
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 61
	if hudAlpha > 0.05 then -- 61
		if p.childMode then -- 61
			self:drawChildStatus( -- 66
				uiDraw, -- 66
				uiGlow, -- 66
				texts, -- 66
				p, -- 66
				h, -- 66
				hudAlpha -- 66
			) -- 66
		else -- 66
			self:drawSoldierStatus( -- 68
				uiDraw, -- 68
				uiGlow, -- 68
				texts, -- 68
				p, -- 68
				h, -- 68
				hudAlpha -- 68
			) -- 68
		end -- 68
		self:drawChapterBadge( -- 72
			uiDraw, -- 72
			uiGlow, -- 72
			texts, -- 72
			p, -- 72
			w, -- 72
			h, -- 72
			hudAlpha -- 72
		) -- 72
		self:drawContextualObjective( -- 75
			uiDraw, -- 75
			uiGlow, -- 75
			texts, -- 75
			p, -- 75
			w, -- 75
			h, -- 75
			hudAlpha -- 75
		) -- 75
		local prompts = deriveWorldPrompts(p) -- 78
		self:drawWorldPrompts( -- 79
			uiDraw, -- 79
			uiGlow, -- 79
			texts, -- 79
			prompts, -- 79
			cam, -- 79
			hudAlpha, -- 79
			uiScale -- 79
		) -- 79
		if vfx.deflectFlash > 0.25 then -- 79
			local dx = cam:sx(vfx.deflectX) / uiScale -- 83
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 18 -- 84
			texts:put( -- 85
				"sm", -- 86
				"掩体挡下", -- 87
				dx, -- 88
				dy, -- 89
				toColor(PALETTE.cyanCore), -- 90
				0.5, -- 91
				0.5, -- 92
				"Center", -- 93
				1.2, -- 94
				vfx.deflectFlash -- 95
			) -- 95
		end -- 95
	end -- 95
	if not p.paused and letterboxFrac < 0.5 then -- 95
		self:drawReticle( -- 102
			uiDraw, -- 102
			uiGlow, -- 102
			p, -- 102
			cam, -- 102
			vfx, -- 102
			uiScale -- 102
		) -- 102
	end -- 102
end -- 47
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiGlow, texts, p, h, alpha) -- 106
	local bx = 34 -- 114
	local by = h - 78 -- 115
	local panelW = 286 -- 116
	local panelH = 50 -- 117
	fillSkewRect( -- 120
		uiDraw, -- 120
		bx, -- 120
		by, -- 120
		panelW, -- 120
		panelH, -- 120
		14, -- 120
		toColor(PALETTE.panelBg, 210 * alpha), -- 120
		1.1, -- 120
		toColor(PALETTE.cyanDim, 165 * alpha) -- 120
	) -- 120
	fillSkewRect( -- 121
		uiGlow, -- 121
		bx - 4, -- 121
		by, -- 121
		5, -- 121
		panelH, -- 121
		14, -- 121
		toColor(PALETTE.cyan, 235 * alpha) -- 121
	) -- 121
	texts:put( -- 123
		"xs", -- 123
		"周戍 · 体力", -- 123
		bx + 18, -- 123
		by + panelH - 12, -- 123
		toColor(PALETTE.cyanCore), -- 123
		0, -- 123
		0.5, -- 123
		"Left", -- 123
		1, -- 123
		alpha -- 123
	) -- 123
	local segCount = math.max(1, p.maxHp) -- 126
	local barX = bx + 16 -- 127
	local barY = by + 11 -- 128
	local barW = 192 -- 129
	local barH = 12 -- 130
	local gap = 6 -- 131
	local segW = (barW - gap * (segCount - 1)) / segCount -- 132
	local i = 0 -- 134
	do -- 134
		i = 0 -- 135
		while i < segCount do -- 135
			local sx = barX + i * (segW + gap) -- 136
			fillSkewRect( -- 138
				uiDraw, -- 138
				sx, -- 138
				barY, -- 138
				segW, -- 138
				barH, -- 138
				6, -- 138
				Color( -- 138
					16, -- 138
					26, -- 138
					40, -- 138
					math.floor(220 * alpha + 0.5) -- 138
				), -- 138
				1, -- 138
				toColor(PALETTE.steelLight, 140 * alpha) -- 138
			) -- 138
			if self.ghostHp > i then -- 138
				local gw = segW * math.min(1, self.ghostHp - i) -- 141
				fillSkewRect( -- 142
					uiDraw, -- 142
					sx, -- 142
					barY, -- 142
					gw, -- 142
					barH, -- 142
					6, -- 142
					Color( -- 142
						235, -- 142
						244, -- 142
						255, -- 142
						math.floor(180 * alpha + 0.5) -- 142
					) -- 142
				) -- 142
			end -- 142
			if p.hp > i then -- 142
				local hpCol = p.hp == 1 and PALETTE.crimson or PALETTE.cyan -- 146
				fillSkewRect( -- 147
					uiDraw, -- 147
					sx, -- 147
					barY, -- 147
					segW, -- 147
					barH, -- 147
					6, -- 147
					toColor(hpCol, 240 * alpha) -- 147
				) -- 147
				fillSkewRect( -- 148
					uiGlow, -- 148
					sx, -- 148
					barY + barH - 3, -- 148
					segW, -- 148
					3, -- 148
					2, -- 148
					toColor(PALETTE.cyanCore, 150 * alpha) -- 148
				) -- 148
			end -- 148
			i = i + 1 -- 135
		end -- 135
	end -- 135
	local covX = barX + barW + 16 -- 153
	if p.coverHug then -- 153
		fillSkewRect( -- 155
			uiGlow, -- 155
			covX, -- 155
			barY - 2, -- 155
			58, -- 155
			16, -- 155
			6, -- 155
			toColor(PALETTE.cyan, 195 * alpha) -- 155
		) -- 155
		texts:put( -- 156
			"xs", -- 156
			"掩体中", -- 156
			covX + 31, -- 156
			barY + 6, -- 156
			Color(6, 12, 20, 255), -- 156
			0.5, -- 156
			0.5, -- 156
			"Center", -- 156
			0, -- 156
			alpha -- 156
		) -- 156
	elseif p.coverNear then -- 156
		fillSkewRect( -- 158
			uiDraw, -- 158
			covX, -- 158
			barY - 2, -- 158
			58, -- 158
			16, -- 158
			6, -- 158
			Color( -- 158
				42, -- 158
				34, -- 158
				18, -- 158
				math.floor(200 * alpha + 0.5) -- 158
			), -- 158
			1.1, -- 158
			toColor(PALETTE.amber, 215 * alpha) -- 158
		) -- 158
		texts:put( -- 159
			"xs", -- 159
			"可贴靠", -- 159
			covX + 31, -- 159
			barY + 6, -- 159
			toColor(PALETTE.amberCore), -- 159
			0.5, -- 159
			0.5, -- 159
			"Center", -- 159
			0, -- 159
			alpha -- 159
		) -- 159
	end -- 159
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 159
		local subY = by - 36 -- 164
		local frozen = p.escort.state == "frozen" -- 165
		local calming = p.escort.state == "calming" -- 166
		local borderCol = frozen and PALETTE.crimson or PALETTE.amberDim -- 167
		fillSkewRect( -- 168
			uiDraw, -- 168
			bx + 6, -- 168
			subY, -- 168
			212, -- 168
			28, -- 168
			9, -- 168
			toColor(PALETTE.panelBg, 195 * alpha), -- 168
			1, -- 168
			toColor(borderCol, 180 * alpha) -- 168
		) -- 168
		fillSkewRect( -- 169
			uiGlow, -- 169
			bx + 3, -- 169
			subY, -- 169
			3, -- 169
			28, -- 169
			9, -- 169
			toColor(frozen and PALETTE.crimson or PALETTE.amber, 220 * alpha) -- 169
		) -- 169
		texts:put( -- 170
			"xs", -- 170
			"小满 · 恐惧", -- 170
			bx + 18, -- 170
			subY + 14, -- 170
			toColor(PALETTE.amberCore), -- 170
			0, -- 170
			0.5, -- 170
			"Left", -- 170
			0.5, -- 170
			alpha -- 170
		) -- 170
		local k = 0 -- 172
		do -- 172
			k = 0 -- 173
			while k < FEAR_MAX do -- 173
				local dx = bx + 116 + k * 20 -- 174
				local dy = subY + 14 -- 175
				local lit = k < p.escort.fear -- 176
				local dc = frozen and PALETTE.crimson or PALETTE.amber -- 177
				drawDiamond( -- 178
					lit and uiGlow or uiDraw, -- 179
					dx, -- 180
					dy, -- 181
					6.5, -- 182
					7.5, -- 183
					lit and toColor(dc, 235 * alpha) or Color( -- 184
						24, -- 184
						34, -- 184
						48, -- 184
						math.floor(180 * alpha + 0.5) -- 184
					), -- 184
					1.1, -- 185
					toColor(dc, (lit and 255 or 120) * alpha) -- 186
				) -- 186
				k = k + 1 -- 173
			end -- 173
		end -- 173
		if frozen then -- 173
			local pulse = 0.65 + 0.35 * math.sin(self.time * 9) -- 190
			texts:put( -- 191
				"xs", -- 191
				"[E]安抚", -- 191
				bx + 172, -- 191
				subY + 14, -- 191
				toColor(PALETTE.crimsonCore), -- 191
				0, -- 191
				0.5, -- 191
				"Left", -- 191
				0, -- 191
				alpha * pulse -- 191
			) -- 191
		elseif calming then -- 191
			texts:put( -- 193
				"xs", -- 193
				"安抚中", -- 193
				bx + 172, -- 193
				subY + 14, -- 193
				toColor(PALETTE.cyanCore), -- 193
				0, -- 193
				0.5, -- 193
				"Left", -- 193
				0, -- 193
				alpha -- 193
			) -- 193
		end -- 193
	end -- 193
end -- 106
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiGlow, texts, p, h, alpha) -- 198
	local bx = 34 -- 206
	local by = h - 72 -- 207
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 208
	local accent = alert and PALETTE.crimson or (p.player.crouch and PALETTE.emerald or PALETTE.amber) -- 209
	fillSkewRect( -- 211
		uiDraw, -- 211
		bx, -- 211
		by, -- 211
		246, -- 211
		44, -- 211
		12, -- 211
		toColor(PALETTE.panelBg, 205 * alpha), -- 211
		1.1, -- 211
		toColor(accent, 175 * alpha) -- 211
	) -- 211
	fillSkewRect( -- 212
		uiGlow, -- 212
		bx - 4, -- 212
		by, -- 212
		5, -- 212
		44, -- 212
		12, -- 212
		toColor(accent, 235 * alpha) -- 212
	) -- 212
	texts:put( -- 214
		"xs", -- 214
		"小满 · 潜行", -- 214
		bx + 18, -- 214
		by + 31, -- 214
		toColor(PALETTE.amberCore), -- 214
		0, -- 214
		0.5, -- 214
		"Left", -- 214
		1, -- 214
		alpha -- 214
	) -- 214
	local posture = "轻步前行 · 保持隐蔽" -- 216
	if alert then -- 216
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速隐蔽！" or "引起警觉 · 停步蹲伏" -- 218
	elseif p.player.crouch then -- 218
		posture = "低姿潜行 · 隐蔽中" -- 220
	elseif p.hasBottle then -- 220
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 222
	end -- 222
	texts:put( -- 224
		"xs", -- 224
		posture, -- 224
		bx + 18, -- 224
		by + 12, -- 224
		toColor(alert and PALETTE.crimsonCore or PALETTE.textMid), -- 224
		0, -- 224
		0.5, -- 224
		"Left", -- 224
		0.3, -- 224
		alpha -- 224
	) -- 224
end -- 198
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiGlow, texts, p, w, h, alpha) -- 227
	local theme = themeOf(p.room.key) -- 236
	local bw = 248 -- 237
	local bh = 44 -- 238
	local bx = w - bw - 34 -- 239
	local by = h - 72 -- 240
	fillSkewRect( -- 242
		uiDraw, -- 242
		bx, -- 242
		by, -- 242
		bw, -- 242
		bh, -- 242
		-12, -- 242
		toColor(PALETTE.panelBg, 195 * alpha), -- 242
		1, -- 242
		toColor(PALETTE.steelLight, 140 * alpha) -- 242
	) -- 242
	fillSkewRect( -- 243
		uiGlow, -- 243
		bx + bw - 2, -- 243
		by, -- 243
		4, -- 243
		bh, -- 243
		-12, -- 243
		toColor(theme.accent, 220 * alpha) -- 243
	) -- 243
	texts:put( -- 245
		"xs", -- 245
		theme.titleZh, -- 245
		bx + bw - 18, -- 245
		by + 30, -- 245
		toColor(PALETTE.textBright), -- 245
		1, -- 245
		0.5, -- 245
		"Right", -- 245
		0.6, -- 245
		alpha -- 245
	) -- 245
	texts:put( -- 246
		"xs", -- 246
		"[Esc] 暂停", -- 246
		bx + bw - 18, -- 246
		by + 12, -- 246
		toColor(PALETTE.textDim), -- 246
		1, -- 246
		0.5, -- 246
		"Right", -- 246
		0.4, -- 246
		alpha -- 246
	) -- 246
end -- 227
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiGlow, texts, p, w, h, alpha) -- 249
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 249
		local g = p.room.story.gate -- 260
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 260
			local bw = 420 -- 262
			local bx = (w - bw) * 0.5 -- 263
			local by = h - 66 -- 264
			local ratio = math.max( -- 265
				0, -- 265
				math.min( -- 265
					1, -- 265
					p.gateTick / math.max(1, g.holdTicks) -- 265
				) -- 265
			) -- 265
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 266
			local secStr = __TS__NumberToFixed(secLeft, 1) .. "s" -- 267
			fillSkewRect( -- 269
				uiDraw, -- 269
				bx, -- 269
				by, -- 269
				bw, -- 269
				36, -- 269
				10, -- 269
				toColor(PALETTE.panelBgDeep, 220 * alpha), -- 269
				1.1, -- 269
				toColor(PALETTE.crimson, 185 * alpha) -- 269
			) -- 269
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守点" or "等待两人就位 · 绞盘启动") or "城门守点  //  GATE HOLD    " .. secStr -- 270
			texts:put( -- 273
				"xs", -- 273
				label, -- 273
				w * 0.5, -- 273
				by + 26, -- 273
				toColor(PALETTE.textBright), -- 273
				0.5, -- 273
				0.5, -- 273
				"Center", -- 273
				1, -- 273
				alpha -- 273
			) -- 273
			local pbx = bx + 20 -- 276
			local pbw = bw - 40 -- 277
			local pby = by + 7 -- 278
			fillSkewRect( -- 279
				uiDraw, -- 279
				pbx, -- 279
				pby, -- 279
				pbw, -- 279
				7, -- 279
				4, -- 279
				Color( -- 279
					24, -- 279
					18, -- 279
					28, -- 279
					math.floor(220 * alpha + 0.5) -- 279
				) -- 279
			) -- 279
			if ratio > 0.002 then -- 279
				fillSkewRect( -- 281
					uiGlow, -- 281
					pbx, -- 281
					pby, -- 281
					pbw * ratio, -- 281
					7, -- 281
					4, -- 281
					toColor(PALETTE.crimson, 235 * alpha) -- 281
				) -- 281
				fillSkewRect( -- 282
					uiGlow, -- 282
					pbx, -- 282
					pby + 4, -- 282
					pbw * ratio, -- 282
					3, -- 282
					2, -- 282
					toColor(PALETTE.crimsonCore, 160 * alpha) -- 282
				) -- 282
			end -- 282
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 285
			local k = 0 -- 286
			do -- 286
				k = 0 -- 287
				while k < #waves do -- 287
					local wx = pbx + pbw * waves[k + 1] -- 288
					local passed = p.gateSpawned > k -- 289
					drawDiamond( -- 290
						uiGlow, -- 290
						wx, -- 290
						pby + 3.5, -- 290
						4, -- 290
						5, -- 290
						toColor(passed and PALETTE.cyanCore or PALETTE.crimson, 230 * alpha) -- 290
					) -- 290
					k = k + 1 -- 287
				end -- 287
			end -- 287
		end -- 287
		return -- 293
	end -- 293
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 293
		local bw = 320 -- 298
		local bx = (w - bw) * 0.5 -- 299
		local by = h - 56 -- 300
		local step1 = p.cartDocked -- 301
		local ____temp_0 -- 302
		if p.room.key == "checkpoint" then -- 302
			____temp_0 = p.gateOpen -- 302
		else -- 302
			____temp_0 = p.checkpoint >= 380 -- 302
		end -- 302
		local step2 = ____temp_0 -- 302
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 303
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 304
		fillSkewRect( -- 306
			uiDraw, -- 306
			bx, -- 306
			by, -- 306
			bw, -- 306
			28, -- 306
			8, -- 306
			toColor(PALETTE.panelBg, 185 * alpha), -- 306
			1, -- 306
			toColor(PALETTE.steelLight, 130 * alpha) -- 306
		) -- 306
		drawDiamond( -- 307
			uiGlow, -- 307
			bx + 24, -- 307
			by + 14, -- 307
			5, -- 307
			5, -- 307
			toColor(step1 and PALETTE.emerald or PALETTE.amber, 230 * alpha) -- 307
		) -- 307
		texts:put( -- 308
			"xs", -- 308
			t1, -- 308
			bx + 36, -- 308
			by + 14, -- 308
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 308
			0, -- 308
			0.5, -- 308
			"Left", -- 308
			0.4, -- 308
			alpha -- 308
		) -- 308
		drawDiamond( -- 310
			uiGlow, -- 310
			bx + 178, -- 310
			by + 14, -- 310
			5, -- 310
			5, -- 310
			toColor(step2 and PALETTE.emerald or PALETTE.textDim, 230 * alpha) -- 310
		) -- 310
		texts:put( -- 311
			"xs", -- 311
			t2, -- 311
			bx + 190, -- 311
			by + 14, -- 311
			toColor(step2 and PALETTE.emerald or PALETTE.textMid), -- 311
			0, -- 311
			0.5, -- 311
			"Left", -- 311
			0.4, -- 311
			alpha -- 311
		) -- 311
	end -- 311
end -- 249
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiGlow, texts, prompts, cam, alpha, uiScale) -- 315
	local bob = math.sin(self.time * 4.5) * 3.5 -- 324
	local i = 0 -- 325
	do -- 325
		i = 0 -- 326
		while i < #prompts do -- 326
			local pr = prompts[i + 1] -- 327
			local sx = math.max( -- 328
				110, -- 328
				math.min( -- 328
					cam.viewW / uiScale - 110, -- 328
					cam:sx(pr.x) / uiScale -- 328
				) -- 328
			) -- 328
			local sy = math.max( -- 329
				96, -- 329
				math.min( -- 329
					cam.viewH / uiScale - 110, -- 329
					cam:sy(pr.y) / uiScale + bob -- 329
				) -- 329
			) -- 329
			local col = pr.urgent and PALETTE.cyan or PALETTE.amber -- 330
			uiGlow:drawSegment( -- 333
				Vec2(sx, sy - 16), -- 333
				Vec2(sx, sy - 30), -- 333
				1.2, -- 333
				toColor(col, 165 * alpha) -- 333
			) -- 333
			uiGlow:drawDot( -- 334
				Vec2(sx, sy - 30), -- 334
				2.5, -- 334
				toColor(col, 220 * alpha) -- 334
			) -- 334
			local keyW = math.max( -- 337
				26, -- 337
				visualTextWidth(pr.keyTag, 14) + 16 -- 337
			) -- 337
			local labelW = visualTextWidth(pr.label, 14) -- 338
			local pillW = keyW + labelW + 26 -- 339
			local px = sx - pillW * 0.5 -- 340
			local py = sy - 14 -- 341
			fillSkewRect( -- 343
				uiDraw, -- 343
				px, -- 343
				py, -- 343
				pillW, -- 343
				26, -- 343
				7, -- 343
				toColor(PALETTE.panelBgDeep, 228 * alpha), -- 343
				1.1, -- 343
				toColor(col, 215 * alpha) -- 343
			) -- 343
			fillSkewRect( -- 344
				uiGlow, -- 344
				px + 2, -- 344
				py + 2, -- 344
				keyW, -- 344
				22, -- 344
				6, -- 344
				toColor(col, 232 * alpha) -- 344
			) -- 344
			texts:put( -- 345
				"xs", -- 345
				pr.keyTag, -- 345
				px + 2 + keyW * 0.5 + 3, -- 345
				py + 13, -- 345
				Color(6, 11, 18, 255), -- 345
				0.5, -- 345
				0.5, -- 345
				"Center", -- 345
				0.4, -- 345
				alpha -- 345
			) -- 345
			texts:put( -- 346
				"xs", -- 346
				pr.label, -- 346
				px + keyW + 14, -- 346
				py + 13, -- 346
				toColor(PALETTE.textBright), -- 346
				0, -- 346
				0.5, -- 346
				"Left", -- 346
				0.4, -- 346
				alpha -- 346
			) -- 346
			i = i + 1 -- 326
		end -- 326
	end -- 326
end -- 315
function HudRenderer.prototype.drawReticle(self, uiDraw, uiGlow, p, cam, vfx, uiScale) -- 350
	local mx = p.aimX / uiScale -- 358
	local my = p.aimY / uiScale -- 359
	if mx <= 0 and my <= 0 then -- 359
		return -- 361
	end -- 361
	if p.childMode then -- 361
		local aiming = p.room.key == "village" and p.hasBottle -- 366
		local r = aiming and (p.aimHold > 0 and 15 or 11) or 4 -- 367
		local col = aiming and PALETTE.emerald or PALETTE.amber -- 368
		uiGlow:drawDot( -- 369
			Vec2(mx, my), -- 369
			2.2, -- 369
			toColor(col, 220) -- 369
		) -- 369
		if aiming then -- 369
			uiGlow:drawRing( -- 371
				Vec2(mx, my), -- 371
				r - 1.5, -- 371
				r, -- 371
				Color(0, 0, 0, 0), -- 371
				1.4, -- 371
				toColor(col, 210) -- 371
			) -- 371
		end -- 371
		return -- 373
	end -- 373
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 377
	local onEnemy = false -- 378
	local i = 0 -- 379
	do -- 379
		i = 0 -- 380
		while i < #p.enemies do -- 380
			local e = p.enemies[i + 1] -- 381
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 381
				onEnemy = true -- 383
			end -- 383
			i = i + 1 -- 380
		end -- 380
	end -- 380
	local col = onEnemy and PALETTE.crimson or PALETTE.cyan -- 387
	local gap = 7 + vfx.crosshairKick -- 388
	local arm = 10 -- 389
	local rot = onEnemy and self.time * 2.5 or 0 -- 390
	uiGlow:drawSegment( -- 393
		Vec2(mx - gap - arm, my), -- 393
		Vec2(mx - gap, my), -- 393
		1.6, -- 393
		toColor(col, 240) -- 393
	) -- 393
	uiGlow:drawSegment( -- 394
		Vec2(mx + gap, my), -- 394
		Vec2(mx + gap + arm, my), -- 394
		1.6, -- 394
		toColor(col, 240) -- 394
	) -- 394
	uiGlow:drawSegment( -- 395
		Vec2(mx, my - gap - arm), -- 395
		Vec2(mx, my - gap), -- 395
		1.6, -- 395
		toColor(col, 240) -- 395
	) -- 395
	uiGlow:drawSegment( -- 396
		Vec2(mx, my + gap), -- 396
		Vec2(mx, my + gap + arm), -- 396
		1.6, -- 396
		toColor(col, 240) -- 396
	) -- 396
	uiGlow:drawDot( -- 397
		Vec2(mx, my), -- 397
		2.2, -- 397
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.cyanCore, 255) -- 397
	) -- 397
	if onEnemy then -- 397
		local dr = 17 + math.sin(self.time * 16) * 1.5 -- 401
		drawDiamond( -- 402
			uiGlow, -- 402
			mx, -- 402
			my, -- 402
			dr, -- 402
			dr, -- 402
			Color(255, 48, 82, 24), -- 402
			1.5, -- 402
			toColor(PALETTE.crimson, 230) -- 402
		) -- 402
		fillRadialGlow( -- 403
			uiGlow, -- 403
			mx, -- 403
			my, -- 403
			24, -- 403
			24, -- 403
			toColor(PALETTE.crimson, 75), -- 403
			Color(255, 48, 82, 0), -- 403
			12 -- 403
		) -- 403
	else -- 403
		local cr = gap + 4 -- 405
		uiDraw:drawArc( -- 406
			Vec2(mx, my), -- 406
			cr, -- 406
			25 + rot * 20, -- 406
			65 + rot * 20, -- 406
			1.1, -- 406
			toColor(PALETTE.cyanDim, 180) -- 406
		) -- 406
		uiDraw:drawArc( -- 407
			Vec2(mx, my), -- 407
			cr, -- 407
			205 + rot * 20, -- 407
			245 + rot * 20, -- 407
			1.1, -- 407
			toColor(PALETTE.cyanDim, 180) -- 407
		) -- 407
	end -- 407
end -- 350
return ____exports -- 350