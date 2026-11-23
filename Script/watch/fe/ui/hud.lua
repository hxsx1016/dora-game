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
function HudRenderer.prototype.draw(self, uiDraw, uiGlow, texts, p, cam, vfx, letterboxFrac) -- 47
	local w = cam.viewW -- 56
	local h = cam.viewH -- 57
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 60
	if hudAlpha > 0.05 then -- 60
		if p.childMode then -- 60
			self:drawChildStatus( -- 65
				uiDraw, -- 65
				uiGlow, -- 65
				texts, -- 65
				p, -- 65
				h, -- 65
				hudAlpha -- 65
			) -- 65
		else -- 65
			self:drawSoldierStatus( -- 67
				uiDraw, -- 67
				uiGlow, -- 67
				texts, -- 67
				p, -- 67
				h, -- 67
				hudAlpha -- 67
			) -- 67
		end -- 67
		self:drawChapterBadge( -- 71
			uiDraw, -- 71
			uiGlow, -- 71
			texts, -- 71
			p, -- 71
			w, -- 71
			h, -- 71
			hudAlpha -- 71
		) -- 71
		self:drawContextualObjective( -- 74
			uiDraw, -- 74
			uiGlow, -- 74
			texts, -- 74
			p, -- 74
			w, -- 74
			h, -- 74
			hudAlpha -- 74
		) -- 74
		local prompts = deriveWorldPrompts(p) -- 77
		self:drawWorldPrompts( -- 78
			uiDraw, -- 78
			uiGlow, -- 78
			texts, -- 78
			prompts, -- 78
			cam, -- 78
			hudAlpha -- 78
		) -- 78
		if vfx.deflectFlash > 0.25 then -- 78
			local dx = cam:sx(vfx.deflectX) -- 82
			local dy = cam:sy(vfx.deflectY) + 34 + (1 - vfx.deflectFlash) * 18 -- 83
			texts:put( -- 84
				"sm", -- 85
				"DEFLECT // 掩体挡下", -- 86
				dx, -- 87
				dy, -- 88
				toColor(PALETTE.cyanCore), -- 89
				0.5, -- 90
				0.5, -- 91
				"Center", -- 92
				1.2, -- 93
				vfx.deflectFlash -- 94
			) -- 94
		end -- 94
	end -- 94
	if not p.paused and letterboxFrac < 0.5 then -- 94
		self:drawReticle( -- 101
			uiDraw, -- 101
			uiGlow, -- 101
			p, -- 101
			cam, -- 101
			vfx -- 101
		) -- 101
	end -- 101
end -- 47
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiGlow, texts, p, h, alpha) -- 105
	local bx = 34 -- 113
	local by = h - 78 -- 114
	local panelW = 286 -- 115
	local panelH = 50 -- 116
	fillSkewRect( -- 119
		uiDraw, -- 119
		bx, -- 119
		by, -- 119
		panelW, -- 119
		panelH, -- 119
		14, -- 119
		toColor(PALETTE.panelBg, 210 * alpha), -- 119
		1.1, -- 119
		toColor(PALETTE.cyanDim, 165 * alpha) -- 119
	) -- 119
	fillSkewRect( -- 120
		uiGlow, -- 120
		bx - 4, -- 120
		by, -- 120
		5, -- 120
		panelH, -- 120
		14, -- 120
		toColor(PALETTE.cyan, 235 * alpha) -- 120
	) -- 120
	texts:put( -- 122
		"xs", -- 122
		"周戍  //  SOLDIER UNIT", -- 122
		bx + 18, -- 122
		by + panelH - 12, -- 122
		toColor(PALETTE.cyanCore), -- 122
		0, -- 122
		0.5, -- 122
		"Left", -- 122
		1, -- 122
		alpha -- 122
	) -- 122
	local segCount = math.max(1, p.maxHp) -- 125
	local barX = bx + 16 -- 126
	local barY = by + 11 -- 127
	local barW = 192 -- 128
	local barH = 12 -- 129
	local gap = 6 -- 130
	local segW = (barW - gap * (segCount - 1)) / segCount -- 131
	local i = 0 -- 133
	do -- 133
		i = 0 -- 134
		while i < segCount do -- 134
			local sx = barX + i * (segW + gap) -- 135
			fillSkewRect( -- 137
				uiDraw, -- 137
				sx, -- 137
				barY, -- 137
				segW, -- 137
				barH, -- 137
				6, -- 137
				Color( -- 137
					16, -- 137
					26, -- 137
					40, -- 137
					math.floor(220 * alpha + 0.5) -- 137
				), -- 137
				1, -- 137
				toColor(PALETTE.steelLight, 140 * alpha) -- 137
			) -- 137
			if self.ghostHp > i then -- 137
				local gw = segW * math.min(1, self.ghostHp - i) -- 140
				fillSkewRect( -- 141
					uiDraw, -- 141
					sx, -- 141
					barY, -- 141
					gw, -- 141
					barH, -- 141
					6, -- 141
					Color( -- 141
						235, -- 141
						244, -- 141
						255, -- 141
						math.floor(180 * alpha + 0.5) -- 141
					) -- 141
				) -- 141
			end -- 141
			if p.hp > i then -- 141
				local hpCol = p.hp == 1 and PALETTE.crimson or PALETTE.cyan -- 145
				fillSkewRect( -- 146
					uiDraw, -- 146
					sx, -- 146
					barY, -- 146
					segW, -- 146
					barH, -- 146
					6, -- 146
					toColor(hpCol, 240 * alpha) -- 146
				) -- 146
				fillSkewRect( -- 147
					uiGlow, -- 147
					sx, -- 147
					barY + barH - 3, -- 147
					segW, -- 147
					3, -- 147
					2, -- 147
					toColor(PALETTE.cyanCore, 150 * alpha) -- 147
				) -- 147
			end -- 147
			i = i + 1 -- 134
		end -- 134
	end -- 134
	local covX = barX + barW + 16 -- 152
	if p.coverHug then -- 152
		fillSkewRect( -- 154
			uiGlow, -- 154
			covX, -- 154
			barY - 2, -- 154
			58, -- 154
			16, -- 154
			6, -- 154
			toColor(PALETTE.cyan, 195 * alpha) -- 154
		) -- 154
		texts:put( -- 155
			"xs", -- 155
			"掩体中", -- 155
			covX + 31, -- 155
			barY + 6, -- 155
			Color(6, 12, 20, 255), -- 155
			0.5, -- 155
			0.5, -- 155
			"Center", -- 155
			0, -- 155
			alpha -- 155
		) -- 155
	elseif p.coverNear then -- 155
		fillSkewRect( -- 157
			uiDraw, -- 157
			covX, -- 157
			barY - 2, -- 157
			58, -- 157
			16, -- 157
			6, -- 157
			Color( -- 157
				42, -- 157
				34, -- 157
				18, -- 157
				math.floor(200 * alpha + 0.5) -- 157
			), -- 157
			1.1, -- 157
			toColor(PALETTE.amber, 215 * alpha) -- 157
		) -- 157
		texts:put( -- 158
			"xs", -- 158
			"可贴靠", -- 158
			covX + 31, -- 158
			barY + 6, -- 158
			toColor(PALETTE.amberCore), -- 158
			0.5, -- 158
			0.5, -- 158
			"Center", -- 158
			0, -- 158
			alpha -- 158
		) -- 158
	end -- 158
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 158
		local subY = by - 36 -- 163
		local frozen = p.escort.state == "frozen" -- 164
		local calming = p.escort.state == "calming" -- 165
		local borderCol = frozen and PALETTE.crimson or PALETTE.amberDim -- 166
		fillSkewRect( -- 167
			uiDraw, -- 167
			bx + 6, -- 167
			subY, -- 167
			212, -- 167
			28, -- 167
			9, -- 167
			toColor(PALETTE.panelBg, 195 * alpha), -- 167
			1, -- 167
			toColor(borderCol, 180 * alpha) -- 167
		) -- 167
		fillSkewRect( -- 168
			uiGlow, -- 168
			bx + 3, -- 168
			subY, -- 168
			3, -- 168
			28, -- 168
			9, -- 168
			toColor(frozen and PALETTE.crimson or PALETTE.amber, 220 * alpha) -- 168
		) -- 168
		texts:put( -- 169
			"xs", -- 169
			"小满 · 恐惧", -- 169
			bx + 18, -- 169
			subY + 14, -- 169
			toColor(PALETTE.amberCore), -- 169
			0, -- 169
			0.5, -- 169
			"Left", -- 169
			0.5, -- 169
			alpha -- 169
		) -- 169
		local k = 0 -- 171
		do -- 171
			k = 0 -- 172
			while k < FEAR_MAX do -- 172
				local dx = bx + 116 + k * 20 -- 173
				local dy = subY + 14 -- 174
				local lit = k < p.escort.fear -- 175
				local dc = frozen and PALETTE.crimson or PALETTE.amber -- 176
				drawDiamond( -- 177
					lit and uiGlow or uiDraw, -- 178
					dx, -- 179
					dy, -- 180
					6.5, -- 181
					7.5, -- 182
					lit and toColor(dc, 235 * alpha) or Color( -- 183
						24, -- 183
						34, -- 183
						48, -- 183
						math.floor(180 * alpha + 0.5) -- 183
					), -- 183
					1.1, -- 184
					toColor(dc, (lit and 255 or 120) * alpha) -- 185
				) -- 185
				k = k + 1 -- 172
			end -- 172
		end -- 172
		if frozen then -- 172
			local pulse = 0.65 + 0.35 * math.sin(self.time * 9) -- 189
			texts:put( -- 190
				"xs", -- 190
				"[E]安抚", -- 190
				bx + 172, -- 190
				subY + 14, -- 190
				toColor(PALETTE.crimsonCore), -- 190
				0, -- 190
				0.5, -- 190
				"Left", -- 190
				0, -- 190
				alpha * pulse -- 190
			) -- 190
		elseif calming then -- 190
			texts:put( -- 192
				"xs", -- 192
				"安抚中", -- 192
				bx + 172, -- 192
				subY + 14, -- 192
				toColor(PALETTE.cyanCore), -- 192
				0, -- 192
				0.5, -- 192
				"Left", -- 192
				0, -- 192
				alpha -- 192
			) -- 192
		end -- 192
	end -- 192
end -- 105
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiGlow, texts, p, h, alpha) -- 197
	local bx = 34 -- 205
	local by = h - 72 -- 206
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 207
	local accent = alert and PALETTE.crimson or (p.player.crouch and PALETTE.emerald or PALETTE.amber) -- 208
	fillSkewRect( -- 210
		uiDraw, -- 210
		bx, -- 210
		by, -- 210
		246, -- 210
		44, -- 210
		12, -- 210
		toColor(PALETTE.panelBg, 205 * alpha), -- 210
		1.1, -- 210
		toColor(accent, 175 * alpha) -- 210
	) -- 210
	fillSkewRect( -- 211
		uiGlow, -- 211
		bx - 4, -- 211
		by, -- 211
		5, -- 211
		44, -- 211
		12, -- 211
		toColor(accent, 235 * alpha) -- 211
	) -- 211
	texts:put( -- 213
		"xs", -- 213
		"小满  //  STEALTH", -- 213
		bx + 18, -- 213
		by + 31, -- 213
		toColor(PALETTE.amberCore), -- 213
		0, -- 213
		0.5, -- 213
		"Left", -- 213
		1, -- 213
		alpha -- 213
	) -- 213
	local posture = "轻步前行 · 保持隐蔽" -- 215
	if alert then -- 215
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速隐蔽！" or "引起警觉 · 停步蹲伏" -- 217
	elseif p.player.crouch then -- 217
		posture = "低姿潜行 · 隐蔽中" -- 219
	elseif p.hasBottle then -- 219
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 221
	end -- 221
	texts:put( -- 223
		"xs", -- 223
		posture, -- 223
		bx + 18, -- 223
		by + 12, -- 223
		toColor(alert and PALETTE.crimsonCore or PALETTE.textMid), -- 223
		0, -- 223
		0.5, -- 223
		"Left", -- 223
		0.3, -- 223
		alpha -- 223
	) -- 223
end -- 197
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiGlow, texts, p, w, h, alpha) -- 226
	local theme = themeOf(p.room.key) -- 235
	local bw = 248 -- 236
	local bh = 44 -- 237
	local bx = w - bw - 34 -- 238
	local by = h - 72 -- 239
	fillSkewRect( -- 241
		uiDraw, -- 241
		bx, -- 241
		by, -- 241
		bw, -- 241
		bh, -- 241
		-12, -- 241
		toColor(PALETTE.panelBg, 195 * alpha), -- 241
		1, -- 241
		toColor(PALETTE.steelLight, 140 * alpha) -- 241
	) -- 241
	fillSkewRect( -- 242
		uiGlow, -- 242
		bx + bw - 2, -- 242
		by, -- 242
		4, -- 242
		bh, -- 242
		-12, -- 242
		toColor(theme.accent, 220 * alpha) -- 242
	) -- 242
	texts:put( -- 244
		"xs", -- 244
		(theme.actCode .. " // ") .. theme.titleZh, -- 244
		bx + bw - 18, -- 244
		by + 30, -- 244
		toColor(PALETTE.textBright), -- 244
		1, -- 244
		0.5, -- 244
		"Right", -- 244
		0.6, -- 244
		alpha -- 244
	) -- 244
	texts:put( -- 245
		"xs", -- 245
		"[ESC] 系统   [G] 灰盒调试", -- 245
		bx + bw - 18, -- 245
		by + 12, -- 245
		toColor(PALETTE.textDim), -- 245
		1, -- 245
		0.5, -- 245
		"Right", -- 245
		0.4, -- 245
		alpha -- 245
	) -- 245
end -- 226
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiGlow, texts, p, w, h, alpha) -- 248
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 248
		local g = p.room.story.gate -- 259
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 259
			local bw = 420 -- 261
			local bx = (w - bw) * 0.5 -- 262
			local by = h - 66 -- 263
			local ratio = math.max( -- 264
				0, -- 264
				math.min( -- 264
					1, -- 264
					p.gateTick / math.max(1, g.holdTicks) -- 264
				) -- 264
			) -- 264
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 265
			local secStr = __TS__NumberToFixed(secLeft, 1) .. "s" -- 266
			fillSkewRect( -- 268
				uiDraw, -- 268
				bx, -- 268
				by, -- 268
				bw, -- 268
				36, -- 268
				10, -- 268
				toColor(PALETTE.panelBgDeep, 220 * alpha), -- 268
				1.1, -- 268
				toColor(PALETTE.crimson, 185 * alpha) -- 268
			) -- 268
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守点" or "等待两人就位 · 绞盘启动") or "城门守点  //  GATE HOLD    " .. secStr -- 269
			texts:put( -- 272
				"xs", -- 272
				label, -- 272
				w * 0.5, -- 272
				by + 26, -- 272
				toColor(PALETTE.textBright), -- 272
				0.5, -- 272
				0.5, -- 272
				"Center", -- 272
				1, -- 272
				alpha -- 272
			) -- 272
			local pbx = bx + 20 -- 275
			local pbw = bw - 40 -- 276
			local pby = by + 7 -- 277
			fillSkewRect( -- 278
				uiDraw, -- 278
				pbx, -- 278
				pby, -- 278
				pbw, -- 278
				7, -- 278
				4, -- 278
				Color( -- 278
					24, -- 278
					18, -- 278
					28, -- 278
					math.floor(220 * alpha + 0.5) -- 278
				) -- 278
			) -- 278
			if ratio > 0.002 then -- 278
				fillSkewRect( -- 280
					uiGlow, -- 280
					pbx, -- 280
					pby, -- 280
					pbw * ratio, -- 280
					7, -- 280
					4, -- 280
					toColor(PALETTE.crimson, 235 * alpha) -- 280
				) -- 280
				fillSkewRect( -- 281
					uiGlow, -- 281
					pbx, -- 281
					pby + 4, -- 281
					pbw * ratio, -- 281
					3, -- 281
					2, -- 281
					toColor(PALETTE.crimsonCore, 160 * alpha) -- 281
				) -- 281
			end -- 281
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 284
			local k = 0 -- 285
			do -- 285
				k = 0 -- 286
				while k < #waves do -- 286
					local wx = pbx + pbw * waves[k + 1] -- 287
					local passed = p.gateSpawned > k -- 288
					drawDiamond( -- 289
						uiGlow, -- 289
						wx, -- 289
						pby + 3.5, -- 289
						4, -- 289
						5, -- 289
						toColor(passed and PALETTE.cyanCore or PALETTE.crimson, 230 * alpha) -- 289
					) -- 289
					k = k + 1 -- 286
				end -- 286
			end -- 286
		end -- 286
		return -- 292
	end -- 292
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 292
		local bw = 320 -- 297
		local bx = (w - bw) * 0.5 -- 298
		local by = h - 56 -- 299
		local step1 = p.cartDocked -- 300
		local ____temp_0 -- 301
		if p.room.key == "checkpoint" then -- 301
			____temp_0 = p.gateOpen -- 301
		else -- 301
			____temp_0 = p.checkpoint >= 380 -- 301
		end -- 301
		local step2 = ____temp_0 -- 301
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 302
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 303
		fillSkewRect( -- 305
			uiDraw, -- 305
			bx, -- 305
			by, -- 305
			bw, -- 305
			28, -- 305
			8, -- 305
			toColor(PALETTE.panelBg, 185 * alpha), -- 305
			1, -- 305
			toColor(PALETTE.steelLight, 130 * alpha) -- 305
		) -- 305
		drawDiamond( -- 306
			uiGlow, -- 306
			bx + 24, -- 306
			by + 14, -- 306
			5, -- 306
			5, -- 306
			toColor(step1 and PALETTE.emerald or PALETTE.amber, 230 * alpha) -- 306
		) -- 306
		texts:put( -- 307
			"xs", -- 307
			t1, -- 307
			bx + 36, -- 307
			by + 14, -- 307
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 307
			0, -- 307
			0.5, -- 307
			"Left", -- 307
			0.4, -- 307
			alpha -- 307
		) -- 307
		drawDiamond( -- 309
			uiGlow, -- 309
			bx + 178, -- 309
			by + 14, -- 309
			5, -- 309
			5, -- 309
			toColor(step2 and PALETTE.emerald or PALETTE.textDim, 230 * alpha) -- 309
		) -- 309
		texts:put( -- 310
			"xs", -- 310
			t2, -- 310
			bx + 190, -- 310
			by + 14, -- 310
			toColor(step2 and PALETTE.emerald or PALETTE.textMid), -- 310
			0, -- 310
			0.5, -- 310
			"Left", -- 310
			0.4, -- 310
			alpha -- 310
		) -- 310
	end -- 310
end -- 248
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiGlow, texts, prompts, cam, alpha) -- 314
	local bob = math.sin(self.time * 4.5) * 3.5 -- 322
	local i = 0 -- 323
	do -- 323
		i = 0 -- 324
		while i < #prompts do -- 324
			local pr = prompts[i + 1] -- 325
			local sx = math.max( -- 326
				110, -- 326
				math.min( -- 326
					cam.viewW - 110, -- 326
					cam:sx(pr.x) -- 326
				) -- 326
			) -- 326
			local sy = math.max( -- 327
				96, -- 327
				math.min( -- 327
					cam.viewH - 110, -- 327
					cam:sy(pr.y) + bob -- 327
				) -- 327
			) -- 327
			local col = pr.urgent and PALETTE.cyan or PALETTE.amber -- 328
			uiGlow:drawSegment( -- 331
				Vec2(sx, sy - 16), -- 331
				Vec2(sx, sy - 30), -- 331
				1.2, -- 331
				toColor(col, 165 * alpha) -- 331
			) -- 331
			uiGlow:drawDot( -- 332
				Vec2(sx, sy - 30), -- 332
				2.5, -- 332
				toColor(col, 220 * alpha) -- 332
			) -- 332
			local keyW = math.max( -- 335
				26, -- 335
				visualTextWidth(pr.keyTag, 14) + 16 -- 335
			) -- 335
			local labelW = visualTextWidth(pr.label, 14) -- 336
			local pillW = keyW + labelW + 26 -- 337
			local px = sx - pillW * 0.5 -- 338
			local py = sy - 14 -- 339
			fillSkewRect( -- 341
				uiDraw, -- 341
				px, -- 341
				py, -- 341
				pillW, -- 341
				26, -- 341
				7, -- 341
				toColor(PALETTE.panelBgDeep, 228 * alpha), -- 341
				1.1, -- 341
				toColor(col, 215 * alpha) -- 341
			) -- 341
			fillSkewRect( -- 342
				uiGlow, -- 342
				px + 2, -- 342
				py + 2, -- 342
				keyW, -- 342
				22, -- 342
				6, -- 342
				toColor(col, 232 * alpha) -- 342
			) -- 342
			texts:put( -- 343
				"xs", -- 343
				pr.keyTag, -- 343
				px + 2 + keyW * 0.5 + 3, -- 343
				py + 13, -- 343
				Color(6, 11, 18, 255), -- 343
				0.5, -- 343
				0.5, -- 343
				"Center", -- 343
				0.4, -- 343
				alpha -- 343
			) -- 343
			texts:put( -- 344
				"xs", -- 344
				pr.label, -- 344
				px + keyW + 14, -- 344
				py + 13, -- 344
				toColor(PALETTE.textBright), -- 344
				0, -- 344
				0.5, -- 344
				"Left", -- 344
				0.4, -- 344
				alpha -- 344
			) -- 344
			i = i + 1 -- 324
		end -- 324
	end -- 324
end -- 314
function HudRenderer.prototype.drawReticle(self, uiDraw, uiGlow, p, cam, vfx) -- 348
	local mx = p.aimX -- 355
	local my = p.aimY -- 356
	if mx <= 0 and my <= 0 then -- 356
		return -- 358
	end -- 358
	if p.childMode then -- 358
		local aiming = p.room.key == "village" and p.hasBottle -- 363
		local r = aiming and (p.aimHold > 0 and 15 or 11) or 4 -- 364
		local col = aiming and PALETTE.emerald or PALETTE.amber -- 365
		uiGlow:drawDot( -- 366
			Vec2(mx, my), -- 366
			2.2, -- 366
			toColor(col, 220) -- 366
		) -- 366
		if aiming then -- 366
			uiGlow:drawRing( -- 368
				Vec2(mx, my), -- 368
				r - 1.5, -- 368
				r, -- 368
				Color(0, 0, 0, 0), -- 368
				1.4, -- 368
				toColor(col, 210) -- 368
			) -- 368
		end -- 368
		return -- 370
	end -- 370
	local wAim = cam:screenToWorld(mx, my) -- 374
	local onEnemy = false -- 375
	local i = 0 -- 376
	do -- 376
		i = 0 -- 377
		while i < #p.enemies do -- 377
			local e = p.enemies[i + 1] -- 378
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 378
				onEnemy = true -- 380
			end -- 380
			i = i + 1 -- 377
		end -- 377
	end -- 377
	local col = onEnemy and PALETTE.crimson or PALETTE.cyan -- 384
	local gap = 7 + vfx.crosshairKick -- 385
	local arm = 10 -- 386
	local rot = onEnemy and self.time * 2.5 or 0 -- 387
	uiGlow:drawSegment( -- 390
		Vec2(mx - gap - arm, my), -- 390
		Vec2(mx - gap, my), -- 390
		1.6, -- 390
		toColor(col, 240) -- 390
	) -- 390
	uiGlow:drawSegment( -- 391
		Vec2(mx + gap, my), -- 391
		Vec2(mx + gap + arm, my), -- 391
		1.6, -- 391
		toColor(col, 240) -- 391
	) -- 391
	uiGlow:drawSegment( -- 392
		Vec2(mx, my - gap - arm), -- 392
		Vec2(mx, my - gap), -- 392
		1.6, -- 392
		toColor(col, 240) -- 392
	) -- 392
	uiGlow:drawSegment( -- 393
		Vec2(mx, my + gap), -- 393
		Vec2(mx, my + gap + arm), -- 393
		1.6, -- 393
		toColor(col, 240) -- 393
	) -- 393
	uiGlow:drawDot( -- 394
		Vec2(mx, my), -- 394
		2.2, -- 394
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.cyanCore, 255) -- 394
	) -- 394
	if onEnemy then -- 394
		local dr = 17 + math.sin(self.time * 16) * 1.5 -- 398
		drawDiamond( -- 399
			uiGlow, -- 399
			mx, -- 399
			my, -- 399
			dr, -- 399
			dr, -- 399
			Color(255, 48, 82, 24), -- 399
			1.5, -- 399
			toColor(PALETTE.crimson, 230) -- 399
		) -- 399
		fillRadialGlow( -- 400
			uiGlow, -- 400
			mx, -- 400
			my, -- 400
			24, -- 400
			24, -- 400
			toColor(PALETTE.crimson, 75), -- 400
			Color(255, 48, 82, 0), -- 400
			12 -- 400
		) -- 400
	else -- 400
		local cr = gap + 4 -- 402
		uiDraw:drawArc( -- 403
			Vec2(mx, my), -- 403
			cr, -- 403
			25 + rot * 20, -- 403
			65 + rot * 20, -- 403
			1.1, -- 403
			toColor(PALETTE.cyanDim, 180) -- 403
		) -- 403
		uiDraw:drawArc( -- 404
			Vec2(mx, my), -- 404
			cr, -- 404
			205 + rot * 20, -- 404
			245 + rot * 20, -- 404
			1.1, -- 404
			toColor(PALETTE.cyanDim, 180) -- 404
		) -- 404
	end -- 404
end -- 348
return ____exports -- 348