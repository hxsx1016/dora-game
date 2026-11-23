-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____escort = require("Script.watch.escort") -- 14
local FEAR_MAX = ____escort.FEAR_MAX -- 14
local ____adapter = require("Script.watch.fe.adapter") -- 15
local deriveWorldPrompts = ____adapter.deriveWorldPrompts -- 15
local ____theme = require("Script.watch.fe.theme") -- 20
local PALETTE = ____theme.PALETTE -- 21
local drawBrushDivider = ____theme.drawBrushDivider -- 22
local drawInkKeycap = ____theme.drawInkKeycap -- 23
local drawInkWashStrip = ____theme.drawInkWashStrip -- 24
local drawSealStamp = ____theme.drawSealStamp -- 25
local fillRadialGlow = ____theme.fillRadialGlow -- 26
local themeOf = ____theme.themeOf -- 27
local toColor = ____theme.toColor -- 28
local visualTextWidth = ____theme.visualTextWidth -- 29
____exports.HudRenderer = __TS__Class() -- 32
local HudRenderer = ____exports.HudRenderer -- 32
HudRenderer.name = "HudRenderer" -- 32
function HudRenderer.prototype.____constructor(self) -- 32
	self.ghostHp = 3 -- 34
	self.time = 0 -- 35
end -- 32
function HudRenderer.prototype.reset(self, p) -- 37
	self.ghostHp = p ~= nil and p.hp or 3 -- 38
end -- 37
function HudRenderer.prototype.update(self, dt, p) -- 41
	self.time = self.time + dt -- 42
	if self.ghostHp > p.hp then -- 42
		self.ghostHp = math.max(p.hp, self.ghostHp - dt * 1.45) -- 44
	else -- 44
		self.ghostHp = p.hp -- 46
	end -- 46
end -- 41
function HudRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiArt, uiGlow, texts, p, cam, vfx, letterboxFrac, uiScale) -- 50
	local w = cam.viewW / uiScale -- 62
	local h = cam.viewH / uiScale -- 63
	local hudAlpha = math.max(0, 1 - letterboxFrac * 1.15) -- 66
	if hudAlpha > 0.05 then -- 66
		if p.childMode then -- 66
			self:drawChildStatus( -- 71
				uiDraw, -- 71
				uiInkDraw, -- 71
				uiArt, -- 71
				texts, -- 71
				p, -- 71
				h, -- 71
				hudAlpha -- 71
			) -- 71
		else -- 71
			self:drawSoldierStatus( -- 73
				uiDraw, -- 73
				uiInkDraw, -- 73
				uiArt, -- 73
				texts, -- 73
				p, -- 73
				h, -- 73
				hudAlpha -- 73
			) -- 73
		end -- 73
		self:drawChapterBadge( -- 77
			uiDraw, -- 77
			uiInkDraw, -- 77
			uiArt, -- 77
			texts, -- 77
			p, -- 77
			w, -- 77
			h, -- 77
			hudAlpha -- 77
		) -- 77
		self:drawContextualObjective( -- 80
			uiDraw, -- 80
			uiInkDraw, -- 80
			uiArt, -- 80
			texts, -- 80
			p, -- 80
			w, -- 80
			h, -- 80
			hudAlpha -- 80
		) -- 80
		local prompts = deriveWorldPrompts(p) -- 83
		self:drawWorldPrompts( -- 84
			uiDraw, -- 84
			uiInkDraw, -- 84
			uiArt, -- 84
			texts, -- 84
			prompts, -- 84
			cam, -- 84
			hudAlpha, -- 84
			uiScale -- 84
		) -- 84
		if vfx.deflectFlash > 0.25 then -- 84
			local dx = cam:sx(vfx.deflectX) / uiScale -- 88
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 89
			texts:put( -- 90
				"sm", -- 91
				"掩体挡下", -- 92
				dx, -- 93
				dy, -- 94
				toColor(PALETTE.xuanPaper), -- 95
				0.5, -- 96
				0.5, -- 97
				"Center", -- 98
				1.6, -- 99
				vfx.deflectFlash -- 100
			) -- 100
		end -- 100
	end -- 100
	if not p.paused and letterboxFrac < 0.5 then -- 100
		self:drawReticle( -- 107
			uiInkDraw, -- 107
			uiArt, -- 107
			uiGlow, -- 107
			p, -- 107
			cam, -- 107
			vfx, -- 107
			uiScale -- 107
		) -- 107
	end -- 107
end -- 50
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 111
	local bx = 28 -- 120
	local by = h - 76 -- 121
	local lowHp = p.hp <= 1 -- 122
	drawInkWashStrip( -- 125
		uiDraw, -- 125
		uiArt, -- 125
		"hud_soldier_bg", -- 125
		bx + 158, -- 125
		by + 26, -- 125
		336, -- 125
		58, -- 125
		PALETTE.inkWash, -- 125
		0.78 * alpha, -- 125
		false, -- 125
		-1 -- 125
	) -- 125
	drawSealStamp( -- 128
		uiInkDraw, -- 129
		uiArt, -- 130
		texts, -- 131
		"hud_soldier_seal", -- 132
		bx + 22, -- 133
		by + 27, -- 134
		30, -- 135
		"戍", -- 136
		lowHp and PALETTE.sealRed or PALETTE.cyanDim, -- 137
		lowHp and PALETTE.sealText or PALETTE.moonPale, -- 138
		alpha, -- 139
		true, -- 140
		4 -- 141
	) -- 141
	texts:put( -- 144
		"xs", -- 144
		"周戍 · 体力", -- 144
		bx + 46, -- 144
		by + 39, -- 144
		toColor(PALETTE.xuanWarm), -- 144
		0, -- 144
		0.5, -- 144
		"Left", -- 144
		1, -- 144
		alpha -- 144
	) -- 144
	local segCount = math.max(1, p.maxHp) -- 147
	local barX = bx + 46 -- 148
	local barY = by + 16 -- 149
	local segW = 54 -- 150
	local segH = 11 -- 151
	local gap = 8 -- 152
	local i = 0 -- 154
	do -- 154
		i = 0 -- 155
		while i < segCount do -- 155
			local sx = barX + i * (segW + gap) -- 156
			local scx = sx + segW * 0.5 -- 157
			if not uiArt:tryPlace( -- 157
				"ink_hp_slot", -- 159
				"hp_slot_" .. tostring(i), -- 159
				scx, -- 159
				barY, -- 159
				segW + 4, -- 159
				segH + 6, -- 159
				{ -- 159
					color = toColor(PALETTE.bronzeDim), -- 160
					opacity = 0.85 * alpha, -- 160
					layer = 1 -- 160
				} -- 160
			) then -- 160
				uiInkDraw:drawRect( -- 162
					Rect(sx, barY - segH * 0.5, segW, segH), -- 162
					Color( -- 162
						16, -- 162
						17, -- 162
						22, -- 162
						math.floor(180 * alpha + 0.5) -- 162
					), -- 162
					1, -- 162
					toColor(PALETTE.bronzeDim, 180 * alpha) -- 162
				) -- 162
			end -- 162
			if self.ghostHp > i and self.ghostHp > p.hp then -- 162
				local frac = math.min(1, self.ghostHp - i) -- 166
				uiInkDraw:drawRect( -- 167
					Rect(sx + 1, barY - segH * 0.42, (segW - 2) * frac, segH * 0.84), -- 167
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 167
				) -- 167
			end -- 167
			if p.hp > i then -- 167
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7.5) or 1 -- 171
				local fillCol = lowHp and PALETTE.sealRedBright or PALETTE.cyanCore -- 172
				if not uiArt:tryPlace( -- 172
					"ink_hp_bar", -- 173
					"hp_fill_" .. tostring(i), -- 173
					scx, -- 173
					barY, -- 173
					segW + 2, -- 173
					segH + 4, -- 173
					{ -- 173
						color = toColor(fillCol), -- 174
						opacity = 0.94 * alpha * pulse, -- 174
						layer = 2 -- 174
					} -- 174
				) then -- 174
					uiInkDraw:drawRect( -- 176
						Rect(sx + 1, barY - segH * 0.42, segW - 2, segH * 0.84), -- 176
						toColor(fillCol, 235 * alpha * pulse) -- 176
					) -- 176
				end -- 176
			end -- 176
			i = i + 1 -- 155
		end -- 155
	end -- 155
	local covX = barX + segCount * (segW + gap) + 6 -- 182
	if p.coverHug then -- 182
		uiInkDraw:drawRect( -- 184
			Rect(covX, barY - 9, 56, 18), -- 184
			toColor(PALETTE.cyanDim, 215 * alpha), -- 184
			1, -- 184
			toColor(PALETTE.cyanCore, 180 * alpha) -- 184
		) -- 184
		texts:put( -- 185
			"xs", -- 185
			"掩体中", -- 185
			covX + 28, -- 185
			barY, -- 185
			toColor(PALETTE.textBright), -- 185
			0.5, -- 185
			0.5, -- 185
			"Center", -- 185
			0.4, -- 185
			alpha, -- 185
			0 -- 185
		) -- 185
	elseif p.coverNear then -- 185
		uiInkDraw:drawRect( -- 187
			Rect(covX, barY - 9, 56, 18), -- 187
			Color( -- 187
				22, -- 187
				19, -- 187
				17, -- 187
				math.floor(195 * alpha + 0.5) -- 187
			), -- 187
			1, -- 187
			toColor(PALETTE.amber, 210 * alpha) -- 187
		) -- 187
		texts:put( -- 188
			"xs", -- 188
			"可贴靠", -- 188
			covX + 28, -- 188
			barY, -- 188
			toColor(PALETTE.amberCore), -- 188
			0.5, -- 188
			0.5, -- 188
			"Center", -- 188
			0.4, -- 188
			alpha -- 188
		) -- 188
	end -- 188
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 188
		local subY = by - 28 -- 193
		local frozen = p.escort.state == "frozen" -- 194
		local calming = p.escort.state == "calming" -- 195
		drawInkWashStrip( -- 197
			uiDraw, -- 198
			uiArt, -- 199
			"hud_fear_bg", -- 200
			bx + 132, -- 201
			subY + 8, -- 202
			258, -- 203
			32, -- 204
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 205
			0.72 * alpha, -- 206
			false, -- 207
			-1 -- 207
		) -- 207
		texts:put( -- 210
			"xs", -- 210
			"小满 · 惊惧", -- 210
			bx + 16, -- 210
			subY + 8, -- 210
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 210
			0, -- 210
			0.5, -- 210
			"Left", -- 210
			0.8, -- 210
			alpha -- 210
		) -- 210
		local k = 0 -- 212
		do -- 212
			k = 0 -- 213
			while k < FEAR_MAX do -- 213
				local dx = bx + 114 + k * 21 -- 214
				local dy = subY + 8 -- 215
				local lit = k < p.escort.fear -- 216
				local dc = frozen and PALETTE.sealRedBright or PALETTE.amber -- 217
				if not uiArt:tryPlace( -- 217
					"ink_ring", -- 219
					"fear_ring_" .. tostring(k), -- 219
					dx, -- 219
					dy, -- 219
					16, -- 219
					16, -- 219
					{ -- 219
						color = toColor(lit and dc or PALETTE.bronzeDim), -- 220
						opacity = (lit and 0.92 or 0.65) * alpha, -- 220
						layer = 2 -- 220
					} -- 220
				) then -- 220
					uiInkDraw:drawRing( -- 222
						Vec2(dx, dy), -- 222
						5.5, -- 222
						6.8, -- 222
						Color(0, 0, 0, 0), -- 222
						1.1, -- 222
						toColor(dc, 180 * alpha) -- 222
					) -- 222
				end -- 222
				if lit then -- 222
					if not uiArt:tryPlace( -- 222
						"ink_dot", -- 226
						"fear_dot_" .. tostring(k), -- 226
						dx, -- 226
						dy, -- 226
						10, -- 226
						10, -- 226
						{ -- 226
							color = toColor(dc), -- 227
							opacity = 0.96 * alpha, -- 227
							layer = 3 -- 227
						} -- 227
					) then -- 227
						uiInkDraw:drawDot( -- 229
							Vec2(dx, dy), -- 229
							4.2, -- 229
							toColor(dc, 235 * alpha) -- 229
						) -- 229
					end -- 229
				end -- 229
				k = k + 1 -- 213
			end -- 213
		end -- 213
		if frozen then -- 213
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7.5) -- 235
			drawInkKeycap( -- 236
				uiInkDraw, -- 236
				texts, -- 236
				bx + 172, -- 236
				subY - 3, -- 236
				22, -- 236
				22, -- 236
				"E", -- 236
				PALETTE.sealRedBright, -- 236
				alpha * pulse, -- 236
				true -- 236
			) -- 236
			texts:put( -- 237
				"xs", -- 237
				"轻敲安抚", -- 237
				bx + 199, -- 237
				subY + 8, -- 237
				toColor(PALETTE.crimsonCore), -- 237
				0, -- 237
				0.5, -- 237
				"Left", -- 237
				0.5, -- 237
				alpha * pulse -- 237
			) -- 237
		elseif calming then -- 237
			texts:put( -- 239
				"xs", -- 239
				"轻敲安抚中", -- 239
				bx + 174, -- 239
				subY + 8, -- 239
				toColor(PALETTE.emerald), -- 239
				0, -- 239
				0.5, -- 239
				"Left", -- 239
				0.5, -- 239
				alpha -- 239
			) -- 239
		end -- 239
	end -- 239
end -- 111
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 244
	local bx = 28 -- 253
	local by = h - 72 -- 254
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 255
	local sealCol = alert and PALETTE.sealRed or (p.player.crouch and PALETTE.emeraldDim or PALETTE.amberDim) -- 256
	local sealChar = alert and "危" or "满" -- 257
	drawInkWashStrip( -- 259
		uiDraw, -- 259
		uiArt, -- 259
		"hud_child_bg", -- 259
		bx + 148, -- 259
		by + 24, -- 259
		308, -- 259
		52, -- 259
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 259
		0.76 * alpha, -- 259
		false, -- 259
		-1 -- 259
	) -- 259
	drawSealStamp( -- 260
		uiInkDraw, -- 260
		uiArt, -- 260
		texts, -- 260
		"hud_child_seal", -- 260
		bx + 22, -- 260
		by + 24, -- 260
		30, -- 260
		sealChar, -- 260
		sealCol, -- 260
		PALETTE.sealText, -- 260
		alpha, -- 260
		true, -- 260
		4 -- 260
	) -- 260
	texts:put( -- 262
		"xs", -- 262
		"小满 · 潜行", -- 262
		bx + 46, -- 262
		by + 35, -- 262
		toColor(PALETTE.amberCore), -- 262
		0, -- 262
		0.5, -- 262
		"Left", -- 262
		1, -- 262
		alpha -- 262
	) -- 262
	local posture = "轻步前行 · 保持隐蔽" -- 264
	local col = PALETTE.textMid -- 265
	if alert then -- 265
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 267
		col = PALETTE.crimsonCore -- 268
	elseif p.player.crouch then -- 268
		posture = "低姿伏行 · 匿迹于影" -- 270
		col = PALETTE.emerald -- 271
	elseif p.hasBottle then -- 271
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 273
		col = PALETTE.amberCore -- 274
	end -- 274
	texts:put( -- 276
		"xs", -- 276
		posture, -- 276
		bx + 46, -- 276
		by + 13, -- 276
		toColor(col), -- 276
		0, -- 276
		0.5, -- 276
		"Left", -- 276
		0.4, -- 276
		alpha -- 276
	) -- 276
end -- 244
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 279
	local theme = themeOf(p.room.key) -- 289
	local rx = w - 30 -- 290
	local cy = h - 46 -- 291
	drawInkWashStrip( -- 294
		uiDraw, -- 294
		uiArt, -- 294
		"hud_chap_bg", -- 294
		rx - 94, -- 294
		cy, -- 294
		246, -- 294
		48, -- 294
		PALETTE.inkWash, -- 294
		0.58 * alpha, -- 294
		true, -- 294
		-1 -- 294
	) -- 294
	drawSealStamp( -- 295
		uiInkDraw, -- 296
		uiArt, -- 297
		texts, -- 298
		"hud_chap_seal", -- 299
		rx - 14, -- 300
		cy + 2, -- 301
		26, -- 302
		theme.numeralZh, -- 303
		p.room.key == "gate" and PALETTE.sealRed or PALETTE.bronzeDim, -- 304
		PALETTE.sealText, -- 305
		0.9 * alpha, -- 306
		true, -- 307
		4 -- 308
	) -- 308
	texts:put( -- 310
		"xs", -- 310
		theme.titleZh, -- 310
		rx - 34, -- 310
		cy + 9, -- 310
		toColor(PALETTE.textBright), -- 310
		1, -- 310
		0.5, -- 310
		"Right", -- 310
		0.8, -- 310
		alpha -- 310
	) -- 310
	texts:put( -- 311
		"xs", -- 311
		"Esc 暂歇", -- 311
		rx - 34, -- 311
		cy - 11, -- 311
		toColor(PALETTE.textDim), -- 311
		1, -- 311
		0.5, -- 311
		"Right", -- 311
		0.6, -- 311
		0.86 * alpha -- 311
	) -- 311
end -- 279
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 314
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 314
		local g = p.room.story.gate -- 326
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 326
			local bw = 420 -- 328
			local cx = w * 0.5 -- 329
			local by = h - 66 -- 330
			local ratio = math.max( -- 331
				0, -- 331
				math.min( -- 331
					1, -- 331
					p.gateTick / math.max(1, g.holdTicks) -- 331
				) -- 331
			) -- 331
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 332
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 333
			drawInkWashStrip( -- 335
				uiDraw, -- 335
				uiArt, -- 335
				"hud_gate_bg", -- 335
				cx, -- 335
				by + 18, -- 335
				bw + 60, -- 335
				50, -- 335
				PALETTE.inkWash, -- 335
				0.84 * alpha, -- 335
				true, -- 335
				-1 -- 335
			) -- 335
			drawBrushDivider( -- 336
				uiInkDraw, -- 336
				uiArt, -- 336
				"hud_gate_top", -- 336
				cx, -- 336
				by + 39, -- 336
				bw - 30, -- 336
				8, -- 336
				PALETTE.crimsonDeep, -- 336
				0.58 * alpha, -- 336
				2 -- 336
			) -- 336
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 338
			texts:put( -- 341
				"xs", -- 341
				label, -- 341
				cx, -- 341
				by + 27, -- 341
				toColor(PALETTE.textBright), -- 341
				0.5, -- 341
				0.5, -- 341
				"Center", -- 341
				1.4, -- 341
				alpha -- 341
			) -- 341
			local pbx = cx - (bw - 72) * 0.5 -- 344
			local pbw = bw - 72 -- 345
			local pby = by + 9 -- 346
			uiInkDraw:drawRect( -- 347
				Rect(pbx, pby - 2.5, pbw, 5), -- 347
				Color( -- 347
					28, -- 347
					22, -- 347
					24, -- 347
					math.floor(210 * alpha + 0.5) -- 347
				), -- 347
				0.7, -- 347
				toColor(PALETTE.bronzeDim, 130 * alpha) -- 347
			) -- 347
			if ratio > 0.002 then -- 347
				uiInkDraw:drawRect( -- 349
					Rect(pbx, pby - 2.5, pbw * ratio, 5), -- 349
					toColor(PALETTE.sealRedBright, 235 * alpha) -- 349
				) -- 349
				uiInkDraw:drawRect( -- 350
					Rect(pbx, pby + 0.5, pbw * ratio, 1.5), -- 350
					toColor(PALETTE.crimsonCore, 160 * alpha) -- 350
				) -- 350
			end -- 350
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 353
			local k = 0 -- 354
			do -- 354
				k = 0 -- 355
				while k < #waves do -- 355
					local wx = pbx + pbw * waves[k + 1] -- 356
					local passed = p.gateSpawned > k -- 357
					uiArt:tryPlace( -- 358
						passed and "ink_dot" or "ink_ring", -- 358
						"gate_wave_" .. tostring(k), -- 358
						wx, -- 358
						pby, -- 358
						passed and 9 or 11, -- 358
						passed and 9 or 11, -- 358
						{ -- 358
							color = toColor(passed and PALETTE.amberCore or PALETTE.sealRedBright), -- 359
							opacity = 0.92 * alpha, -- 359
							layer = 3 -- 359
						} -- 359
					) -- 359
					k = k + 1 -- 355
				end -- 355
			end -- 355
		end -- 355
		return -- 363
	end -- 363
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 363
		local cx = w * 0.5 -- 368
		local by = h - 46 -- 369
		local step1 = p.cartDocked -- 370
		local ____temp_0 -- 371
		if p.room.key == "checkpoint" then -- 371
			____temp_0 = p.gateOpen -- 371
		else -- 371
			____temp_0 = p.checkpoint >= 380 -- 371
		end -- 371
		local step2 = ____temp_0 -- 371
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 372
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 373
		drawInkWashStrip( -- 375
			uiDraw, -- 375
			uiArt, -- 375
			"hud_obj_bg", -- 375
			cx, -- 375
			by, -- 375
			356, -- 375
			36, -- 375
			PALETTE.inkWash, -- 375
			0.7 * alpha, -- 375
			true, -- 375
			-1 -- 375
		) -- 375
		local x1 = cx - 134 -- 377
		uiArt:tryPlace( -- 378
			step1 and "ink_dot" or "ink_ring", -- 378
			"obj_m1", -- 378
			x1, -- 378
			by, -- 378
			12, -- 378
			12, -- 378
			{ -- 378
				color = toColor(step1 and PALETTE.emerald or PALETTE.amber), -- 379
				opacity = 0.92 * alpha, -- 379
				layer = 3 -- 379
			} -- 379
		) -- 379
		texts:put( -- 381
			"xs", -- 381
			t1, -- 381
			x1 + 13, -- 381
			by, -- 381
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 381
			0, -- 381
			0.5, -- 381
			"Left", -- 381
			0.6, -- 381
			alpha -- 381
		) -- 381
		local x2 = cx + 18 -- 383
		uiArt:tryPlace( -- 384
			step2 and "ink_dot" or "ink_ring", -- 384
			"obj_m2", -- 384
			x2, -- 384
			by, -- 384
			12, -- 384
			12, -- 384
			{ -- 384
				color = toColor(step2 and PALETTE.emerald or PALETTE.bronzeDim), -- 385
				opacity = 0.92 * alpha, -- 385
				layer = 3 -- 385
			} -- 385
		) -- 385
		texts:put( -- 387
			"xs", -- 387
			t2, -- 387
			x2 + 13, -- 387
			by, -- 387
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 387
			0, -- 387
			0.5, -- 387
			"Left", -- 387
			0.6, -- 387
			alpha -- 387
		) -- 387
	end -- 387
end -- 314
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 391
	local bob = math.sin(self.time * 3.8) * 3 -- 401
	local i = 0 -- 402
	do -- 402
		i = 0 -- 403
		while i < #prompts do -- 403
			local pr = prompts[i + 1] -- 404
			local sx = math.max( -- 405
				115, -- 405
				math.min( -- 405
					cam.viewW / uiScale - 115, -- 405
					cam:sx(pr.x) / uiScale -- 405
				) -- 405
			) -- 405
			local sy = math.max( -- 406
				96, -- 406
				math.min( -- 406
					cam.viewH / uiScale - 110, -- 406
					cam:sy(pr.y) / uiScale + bob -- 406
				) -- 406
			) -- 406
			local accent = pr.urgent and PALETTE.sealRedBright or PALETTE.amber -- 407
			uiInkDraw:drawSegment( -- 410
				Vec2(sx, sy - 15), -- 410
				Vec2(sx, sy - 29), -- 410
				1, -- 410
				toColor(accent, 160 * alpha) -- 410
			) -- 410
			uiInkDraw:drawDot( -- 411
				Vec2(sx, sy - 29), -- 411
				2.2, -- 411
				toColor(accent, 210 * alpha) -- 411
			) -- 411
			local keyW = math.max( -- 414
				24, -- 414
				visualTextWidth(pr.keyTag, 14) + 14 -- 414
			) -- 414
			local labelW = visualTextWidth(pr.label, 15) -- 415
			local pillW = keyW + labelW + 26 -- 416
			local px = sx - pillW * 0.5 -- 417
			local py = sy - 13 -- 418
			drawInkWashStrip( -- 420
				uiDraw, -- 420
				uiArt, -- 420
				"wp_bg_" .. tostring(i), -- 420
				sx, -- 420
				py + 13, -- 420
				pillW + 24, -- 420
				34, -- 420
				PALETTE.inkWash, -- 420
				0.86 * alpha, -- 420
				true, -- 420
				0 -- 420
			) -- 420
			uiInkDraw:drawSegment( -- 421
				Vec2(px + 2, py + 26), -- 421
				Vec2(px + pillW - 2, py + 26), -- 421
				0.8, -- 421
				toColor(accent, 115 * alpha) -- 421
			) -- 421
			uiInkDraw:drawSegment( -- 422
				Vec2(px + 2, py), -- 422
				Vec2(px + pillW - 2, py), -- 422
				0.8, -- 422
				toColor(accent, 115 * alpha) -- 422
			) -- 422
			drawInkKeycap( -- 423
				uiInkDraw, -- 423
				texts, -- 423
				px + 3, -- 423
				py + 2, -- 423
				keyW, -- 423
				22, -- 423
				pr.keyTag, -- 423
				accent, -- 423
				alpha, -- 423
				pr.urgent -- 423
			) -- 423
			texts:put( -- 424
				"xs", -- 424
				pr.label, -- 424
				px + keyW + 12, -- 424
				py + 13, -- 424
				toColor(PALETTE.textBright), -- 424
				0, -- 424
				0.5, -- 424
				"Left", -- 424
				0.5, -- 424
				alpha -- 424
			) -- 424
			i = i + 1 -- 403
		end -- 403
	end -- 403
end -- 391
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 428
	local mx = p.aimX / uiScale -- 437
	local my = p.aimY / uiScale -- 438
	if mx <= 0 and my <= 0 then -- 438
		return -- 440
	end -- 440
	if p.childMode then -- 440
		local aiming = p.room.key == "village" and p.hasBottle -- 445
		local col = aiming and PALETTE.amber or PALETTE.bronzeDim -- 446
		uiInkDraw:drawDot( -- 447
			Vec2(mx, my), -- 447
			aiming and 2.2 or 1.8, -- 447
			toColor(col, aiming and 225 or 135) -- 447
		) -- 447
		if aiming then -- 447
			local sz = p.aimHold > 0 and 34 or 26 -- 449
			if not uiArt:tryPlace( -- 449
				"ink_ring", -- 450
				"reticle_child", -- 450
				mx, -- 450
				my, -- 450
				sz, -- 450
				sz, -- 450
				{ -- 450
					color = toColor(PALETTE.amberCore), -- 451
					opacity = 0.86, -- 451
					angle = self.time * 28, -- 451
					layer = 5 -- 451
				} -- 451
			) then -- 451
				uiInkDraw:drawRing( -- 453
					Vec2(mx, my), -- 453
					sz * 0.44, -- 453
					sz * 0.5, -- 453
					Color(0, 0, 0, 0), -- 453
					1.2, -- 453
					toColor(PALETTE.amber, 200) -- 453
				) -- 453
			end -- 453
		end -- 453
		return -- 456
	end -- 456
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 460
	local onEnemy = false -- 461
	local i = 0 -- 462
	do -- 462
		i = 0 -- 463
		while i < #p.enemies do -- 463
			local e = p.enemies[i + 1] -- 464
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 464
				onEnemy = true -- 466
			end -- 466
			i = i + 1 -- 463
		end -- 463
	end -- 463
	local col = onEnemy and PALETTE.sealRedBright or PALETTE.xuanPaper -- 470
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.75 -- 471
	local arm = onEnemy and 8.5 or 9.5 -- 472
	local bg = Color(12, 13, 18, 170) -- 475
	uiInkDraw:drawSegment( -- 476
		Vec2(mx - gap - arm, my), -- 476
		Vec2(mx - gap, my), -- 476
		2.4, -- 476
		bg -- 476
	) -- 476
	uiInkDraw:drawSegment( -- 477
		Vec2(mx + gap, my), -- 477
		Vec2(mx + gap + arm, my), -- 477
		2.4, -- 477
		bg -- 477
	) -- 477
	uiInkDraw:drawSegment( -- 478
		Vec2(mx, my - gap - arm), -- 478
		Vec2(mx, my - gap), -- 478
		2.4, -- 478
		bg -- 478
	) -- 478
	uiInkDraw:drawSegment( -- 479
		Vec2(mx, my + gap), -- 479
		Vec2(mx, my + gap + arm), -- 479
		2.4, -- 479
		bg -- 479
	) -- 479
	uiInkDraw:drawSegment( -- 481
		Vec2(mx - gap - arm, my), -- 481
		Vec2(mx - gap, my), -- 481
		1.3, -- 481
		toColor(col, 235) -- 481
	) -- 481
	uiInkDraw:drawSegment( -- 482
		Vec2(mx + gap, my), -- 482
		Vec2(mx + gap + arm, my), -- 482
		1.3, -- 482
		toColor(col, 235) -- 482
	) -- 482
	uiInkDraw:drawSegment( -- 483
		Vec2(mx, my - gap - arm), -- 483
		Vec2(mx, my - gap), -- 483
		1.3, -- 483
		toColor(col, 235) -- 483
	) -- 483
	uiInkDraw:drawSegment( -- 484
		Vec2(mx, my + gap), -- 484
		Vec2(mx, my + gap + arm), -- 484
		1.3, -- 484
		toColor(col, 235) -- 484
	) -- 484
	uiInkDraw:drawDot( -- 485
		Vec2(mx, my), -- 485
		2, -- 485
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.xuanPaper, 245) -- 485
	) -- 485
	if onEnemy then -- 485
		local sz = 32 + math.sin(self.time * 12) * 2 -- 488
		uiArt:tryPlace( -- 489
			"ink_ring", -- 489
			"reticle_lock", -- 489
			mx, -- 489
			my, -- 489
			sz, -- 489
			sz, -- 489
			{ -- 489
				color = toColor(PALETTE.sealRedBright), -- 490
				opacity = 0.9, -- 490
				angle = self.time * 42, -- 490
				layer = 5 -- 490
			} -- 490
		) -- 490
		fillRadialGlow( -- 492
			uiGlow, -- 492
			mx, -- 492
			my, -- 492
			18, -- 492
			18, -- 492
			toColor(PALETTE.cinnabar, 36), -- 492
			Color(168, 46, 40, 0), -- 492
			10 -- 492
		) -- 492
	end -- 492
end -- 428
return ____exports -- 428