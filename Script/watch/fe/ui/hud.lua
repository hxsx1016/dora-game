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
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 15
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
		local prompt = deriveWorldPrompt(p) -- 83
		local prompts = prompt ~= nil and ({prompt}) or ({}) -- 84
		self:drawWorldPrompts( -- 85
			uiDraw, -- 85
			uiInkDraw, -- 85
			uiArt, -- 85
			texts, -- 85
			prompts, -- 85
			cam, -- 85
			hudAlpha, -- 85
			uiScale -- 85
		) -- 85
		if vfx.deflectFlash > 0.25 then -- 85
			local dx = cam:sx(vfx.deflectX) / uiScale -- 89
			local dy = cam:sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16 -- 90
			texts:put( -- 91
				"sm", -- 92
				"掩体挡下", -- 93
				dx, -- 94
				dy, -- 95
				toColor(PALETTE.xuanPaper), -- 96
				0.5, -- 97
				0.5, -- 98
				"Center", -- 99
				1.6, -- 100
				vfx.deflectFlash -- 101
			) -- 101
		end -- 101
	end -- 101
	if not p.paused and letterboxFrac < 0.5 and not p.gripping and p.escort.state ~= "calming" and not p.gateNeedConfirm and p.phase ~= "prologue-give" then -- 101
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
end -- 50
function HudRenderer.prototype.drawSoldierStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 113
	local bx = 28 -- 122
	local by = h - 76 -- 123
	local lowHp = p.hp <= 1 -- 124
	drawInkWashStrip( -- 127
		uiDraw, -- 127
		uiArt, -- 127
		"hud_soldier_bg", -- 127
		bx + 158, -- 127
		by + 26, -- 127
		336, -- 127
		58, -- 127
		PALETTE.inkWash, -- 127
		0.78 * alpha, -- 127
		false, -- 127
		-1 -- 127
	) -- 127
	drawSealStamp( -- 130
		uiInkDraw, -- 131
		uiArt, -- 132
		texts, -- 133
		"hud_soldier_seal", -- 134
		bx + 22, -- 135
		by + 27, -- 136
		30, -- 137
		"戍", -- 138
		lowHp and PALETTE.sealRed or PALETTE.cyanDim, -- 139
		lowHp and PALETTE.sealText or PALETTE.moonPale, -- 140
		alpha, -- 141
		true, -- 142
		4 -- 143
	) -- 143
	texts:put( -- 146
		"xs", -- 146
		"周戍 · 体力", -- 146
		bx + 46, -- 146
		by + 39, -- 146
		toColor(PALETTE.xuanWarm), -- 146
		0, -- 146
		0.5, -- 146
		"Left", -- 146
		1, -- 146
		alpha -- 146
	) -- 146
	local segCount = math.max(1, p.maxHp) -- 149
	local barX = bx + 46 -- 150
	local barY = by + 16 -- 151
	local segW = 54 -- 152
	local segH = 11 -- 153
	local gap = 8 -- 154
	local i = 0 -- 156
	do -- 156
		i = 0 -- 157
		while i < segCount do -- 157
			local sx = barX + i * (segW + gap) -- 158
			local scx = sx + segW * 0.5 -- 159
			if not uiArt:tryPlace( -- 159
				"ink_hp_slot", -- 161
				"hp_slot_" .. tostring(i), -- 161
				scx, -- 161
				barY, -- 161
				segW + 4, -- 161
				segH + 6, -- 161
				{ -- 161
					color = toColor(PALETTE.bronzeDim), -- 162
					opacity = 0.85 * alpha, -- 162
					layer = 1 -- 162
				} -- 162
			) then -- 162
				uiInkDraw:drawRect( -- 164
					Rect(sx, barY - segH * 0.5, segW, segH), -- 164
					Color( -- 164
						16, -- 164
						17, -- 164
						22, -- 164
						math.floor(180 * alpha + 0.5) -- 164
					), -- 164
					1, -- 164
					toColor(PALETTE.bronzeDim, 180 * alpha) -- 164
				) -- 164
			end -- 164
			if self.ghostHp > i and self.ghostHp > p.hp then -- 164
				local frac = math.min(1, self.ghostHp - i) -- 168
				uiInkDraw:drawRect( -- 169
					Rect(sx + 1, barY - segH * 0.42, (segW - 2) * frac, segH * 0.84), -- 169
					toColor(PALETTE.crimsonCore, 165 * alpha) -- 169
				) -- 169
			end -- 169
			if p.hp > i then -- 169
				local pulse = lowHp and 0.72 + 0.28 * math.sin(self.time * 7.5) or 1 -- 173
				local fillCol = lowHp and PALETTE.sealRedBright or PALETTE.cyanCore -- 174
				if not uiArt:tryPlace( -- 174
					"ink_hp_bar", -- 175
					"hp_fill_" .. tostring(i), -- 175
					scx, -- 175
					barY, -- 175
					segW + 2, -- 175
					segH + 4, -- 175
					{ -- 175
						color = toColor(fillCol), -- 176
						opacity = 0.94 * alpha * pulse, -- 176
						layer = 2 -- 176
					} -- 176
				) then -- 176
					uiInkDraw:drawRect( -- 178
						Rect(sx + 1, barY - segH * 0.42, segW - 2, segH * 0.84), -- 178
						toColor(fillCol, 235 * alpha * pulse) -- 178
					) -- 178
				end -- 178
			end -- 178
			i = i + 1 -- 157
		end -- 157
	end -- 157
	local covX = barX + segCount * (segW + gap) + 6 -- 184
	if p.coverHug then -- 184
		uiInkDraw:drawRect( -- 186
			Rect(covX, barY - 9, 56, 18), -- 186
			toColor(PALETTE.cyanDim, 215 * alpha), -- 186
			1, -- 186
			toColor(PALETTE.cyanCore, 180 * alpha) -- 186
		) -- 186
		texts:put( -- 187
			"xs", -- 187
			"掩体中", -- 187
			covX + 28, -- 187
			barY, -- 187
			toColor(PALETTE.textBright), -- 187
			0.5, -- 187
			0.5, -- 187
			"Center", -- 187
			0.4, -- 187
			alpha, -- 187
			0 -- 187
		) -- 187
	elseif p.coverNear then -- 187
		uiInkDraw:drawRect( -- 189
			Rect(covX, barY - 9, 56, 18), -- 189
			Color( -- 189
				22, -- 189
				19, -- 189
				17, -- 189
				math.floor(195 * alpha + 0.5) -- 189
			), -- 189
			1, -- 189
			toColor(PALETTE.amber, 210 * alpha) -- 189
		) -- 189
		texts:put( -- 190
			"xs", -- 190
			"可贴靠", -- 190
			covX + 28, -- 190
			barY, -- 190
			toColor(PALETTE.amberCore), -- 190
			0.5, -- 190
			0.5, -- 190
			"Center", -- 190
			0.4, -- 190
			alpha -- 190
		) -- 190
	end -- 190
	if p.room.key == "prologue" or p.room.key == "street" or p.room.key == "checkpoint" then -- 190
		local subY = by - 28 -- 195
		local frozen = p.escort.state == "frozen" -- 196
		local calming = p.escort.state == "calming" -- 197
		drawInkWashStrip( -- 199
			uiDraw, -- 200
			uiArt, -- 201
			"hud_fear_bg", -- 202
			bx + 132, -- 203
			subY + 8, -- 204
			258, -- 205
			32, -- 206
			frozen and PALETTE.inkWarm or PALETTE.inkWash, -- 207
			0.72 * alpha, -- 208
			false, -- 209
			-1 -- 209
		) -- 209
		texts:put( -- 212
			"xs", -- 212
			"小满 · 惊惧", -- 212
			bx + 16, -- 212
			subY + 8, -- 212
			toColor(frozen and PALETTE.crimsonCore or PALETTE.textMid), -- 212
			0, -- 212
			0.5, -- 212
			"Left", -- 212
			0.8, -- 212
			alpha -- 212
		) -- 212
		local k = 0 -- 214
		do -- 214
			k = 0 -- 215
			while k < FEAR_MAX do -- 215
				local dx = bx + 114 + k * 21 -- 216
				local dy = subY + 8 -- 217
				local lit = k < p.escort.fear -- 218
				local dc = frozen and PALETTE.sealRedBright or PALETTE.amber -- 219
				if not uiArt:tryPlace( -- 219
					"ink_ring", -- 221
					"fear_ring_" .. tostring(k), -- 221
					dx, -- 221
					dy, -- 221
					16, -- 221
					16, -- 221
					{ -- 221
						color = toColor(lit and dc or PALETTE.bronzeDim), -- 222
						opacity = (lit and 0.92 or 0.65) * alpha, -- 222
						layer = 2 -- 222
					} -- 222
				) then -- 222
					uiInkDraw:drawRing( -- 224
						Vec2(dx, dy), -- 224
						5.5, -- 224
						6.8, -- 224
						Color(0, 0, 0, 0), -- 224
						1.1, -- 224
						toColor(dc, 180 * alpha) -- 224
					) -- 224
				end -- 224
				if lit then -- 224
					if not uiArt:tryPlace( -- 224
						"ink_dot", -- 228
						"fear_dot_" .. tostring(k), -- 228
						dx, -- 228
						dy, -- 228
						10, -- 228
						10, -- 228
						{ -- 228
							color = toColor(dc), -- 229
							opacity = 0.96 * alpha, -- 229
							layer = 3 -- 229
						} -- 229
					) then -- 229
						uiInkDraw:drawDot( -- 231
							Vec2(dx, dy), -- 231
							4.2, -- 231
							toColor(dc, 235 * alpha) -- 231
						) -- 231
					end -- 231
				end -- 231
				k = k + 1 -- 215
			end -- 215
		end -- 215
		if frozen then -- 215
			local pulse = 0.65 + 0.35 * math.sin(self.time * 7.5) -- 237
			drawInkKeycap( -- 238
				uiInkDraw, -- 238
				texts, -- 238
				bx + 172, -- 238
				subY - 3, -- 238
				22, -- 238
				22, -- 238
				"E", -- 238
				PALETTE.sealRedBright, -- 238
				alpha * pulse, -- 238
				true -- 238
			) -- 238
			texts:put( -- 239
				"xs", -- 239
				"轻敲安抚", -- 239
				bx + 199, -- 239
				subY + 8, -- 239
				toColor(PALETTE.crimsonCore), -- 239
				0, -- 239
				0.5, -- 239
				"Left", -- 239
				0.5, -- 239
				alpha * pulse -- 239
			) -- 239
		elseif calming then -- 239
			texts:put( -- 241
				"xs", -- 241
				"轻敲安抚中", -- 241
				bx + 174, -- 241
				subY + 8, -- 241
				toColor(PALETTE.emerald), -- 241
				0, -- 241
				0.5, -- 241
				"Left", -- 241
				0.5, -- 241
				alpha -- 241
			) -- 241
		end -- 241
	end -- 241
end -- 113
function HudRenderer.prototype.drawChildStatus(self, uiDraw, uiInkDraw, uiArt, texts, p, h, alpha) -- 246
	local bx = 28 -- 255
	local by = h - 72 -- 256
	local alert = p.scavChase or p.dogState == "chase" or p.dogState == "ear" or p.scavSee > 0 -- 257
	local sealCol = alert and PALETTE.sealRed or (p.player.crouch and PALETTE.emeraldDim or PALETTE.amberDim) -- 258
	local sealChar = alert and "危" or "满" -- 259
	drawInkWashStrip( -- 261
		uiDraw, -- 261
		uiArt, -- 261
		"hud_child_bg", -- 261
		bx + 148, -- 261
		by + 24, -- 261
		308, -- 261
		52, -- 261
		alert and PALETTE.inkWarm or PALETTE.inkWash, -- 261
		0.76 * alpha, -- 261
		false, -- 261
		-1 -- 261
	) -- 261
	drawSealStamp( -- 262
		uiInkDraw, -- 262
		uiArt, -- 262
		texts, -- 262
		"hud_child_seal", -- 262
		bx + 22, -- 262
		by + 24, -- 262
		30, -- 262
		sealChar, -- 262
		sealCol, -- 262
		PALETTE.sealText, -- 262
		alpha, -- 262
		true, -- 262
		4 -- 262
	) -- 262
	texts:put( -- 264
		"xs", -- 264
		"小满 · 潜行", -- 264
		bx + 46, -- 264
		by + 35, -- 264
		toColor(PALETTE.amberCore), -- 264
		0, -- 264
		0.5, -- 264
		"Left", -- 264
		1, -- 264
		alpha -- 264
	) -- 264
	local posture = "轻步前行 · 保持隐蔽" -- 266
	local col = PALETTE.textMid -- 267
	if alert then -- 267
		posture = (p.scavChase or p.dogState == "chase") and "已被发现 · 速寻隐蔽" or "引起警觉 · 停步蹲伏" -- 269
		col = PALETTE.crimsonCore -- 270
	elseif p.player.crouch then -- 270
		posture = "低姿伏行 · 匿迹于影" -- 272
		col = PALETTE.emerald -- 273
	elseif p.hasBottle then -- 273
		posture = "手持玻璃瓶 · 按住 [F] 瞄投" -- 275
		col = PALETTE.amberCore -- 276
	end -- 276
	texts:put( -- 278
		"xs", -- 278
		posture, -- 278
		bx + 46, -- 278
		by + 13, -- 278
		toColor(col), -- 278
		0, -- 278
		0.5, -- 278
		"Left", -- 278
		0.4, -- 278
		alpha -- 278
	) -- 278
end -- 246
function HudRenderer.prototype.drawChapterBadge(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 281
	local theme = themeOf(p.room.key) -- 291
	local rx = w - 30 -- 292
	local cy = h - 46 -- 293
	drawInkWashStrip( -- 296
		uiDraw, -- 296
		uiArt, -- 296
		"hud_chap_bg", -- 296
		rx - 94, -- 296
		cy, -- 296
		246, -- 296
		48, -- 296
		PALETTE.inkWash, -- 296
		0.58 * alpha, -- 296
		true, -- 296
		-1 -- 296
	) -- 296
	drawSealStamp( -- 297
		uiInkDraw, -- 298
		uiArt, -- 299
		texts, -- 300
		"hud_chap_seal", -- 301
		rx - 14, -- 302
		cy + 2, -- 303
		26, -- 304
		theme.numeralZh, -- 305
		p.room.key == "gate" and PALETTE.sealRed or PALETTE.bronzeDim, -- 306
		PALETTE.sealText, -- 307
		0.9 * alpha, -- 308
		true, -- 309
		4 -- 310
	) -- 310
	texts:put( -- 312
		"xs", -- 312
		theme.titleZh, -- 312
		rx - 34, -- 312
		cy + 9, -- 312
		toColor(PALETTE.textBright), -- 312
		1, -- 312
		0.5, -- 312
		"Right", -- 312
		0.8, -- 312
		alpha -- 312
	) -- 312
	texts:put( -- 313
		"xs", -- 313
		"Esc 暂歇", -- 313
		rx - 34, -- 313
		cy - 11, -- 313
		toColor(PALETTE.textDim), -- 313
		1, -- 313
		0.5, -- 313
		"Right", -- 313
		0.6, -- 313
		0.86 * alpha -- 313
	) -- 313
end -- 281
function HudRenderer.prototype.drawContextualObjective(self, uiDraw, uiInkDraw, uiArt, texts, p, w, h, alpha) -- 316
	if p.room.key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 316
		local g = p.room.story.gate -- 328
		if p.phase == "gate-hold" or p.phase == "gate-idle" then -- 328
			local bw = 420 -- 330
			local cx = w * 0.5 -- 331
			local by = h - 66 -- 332
			local ratio = math.max( -- 333
				0, -- 333
				math.min( -- 333
					1, -- 333
					p.gateTick / math.max(1, g.holdTicks) -- 333
				) -- 333
			) -- 333
			local secLeft = math.max(0, (g.holdTicks - p.gateTick) / 60) -- 334
			local secStr = __TS__NumberToFixed(secLeft, 1) -- 335
			drawInkWashStrip( -- 337
				uiDraw, -- 337
				uiArt, -- 337
				"hud_gate_bg", -- 337
				cx, -- 337
				by + 18, -- 337
				bw + 60, -- 337
				50, -- 337
				PALETTE.inkWash, -- 337
				0.84 * alpha, -- 337
				true, -- 337
				-1 -- 337
			) -- 337
			drawBrushDivider( -- 338
				uiInkDraw, -- 338
				uiArt, -- 338
				"hud_gate_top", -- 338
				cx, -- 338
				by + 39, -- 338
				bw - 30, -- 338
				8, -- 338
				PALETTE.crimsonDeep, -- 338
				0.58 * alpha, -- 338
				2 -- 338
			) -- 338
			local label = p.phase == "gate-idle" and (p.gateNeedConfirm and "绞盘待命 · 按 [E] 重新守门" or "待小满就位 · 绞盘启") or ("城门死守 · 余 " .. secStr) .. " 秒" -- 340
			texts:put( -- 343
				"xs", -- 343
				label, -- 343
				cx, -- 343
				by + 27, -- 343
				toColor(PALETTE.textBright), -- 343
				0.5, -- 343
				0.5, -- 343
				"Center", -- 343
				1.4, -- 343
				alpha -- 343
			) -- 343
			local pbx = cx - (bw - 72) * 0.5 -- 346
			local pbw = bw - 72 -- 347
			local pby = by + 9 -- 348
			uiInkDraw:drawRect( -- 349
				Rect(pbx, pby - 2.5, pbw, 5), -- 349
				Color( -- 349
					28, -- 349
					22, -- 349
					24, -- 349
					math.floor(210 * alpha + 0.5) -- 349
				), -- 349
				0.7, -- 349
				toColor(PALETTE.bronzeDim, 130 * alpha) -- 349
			) -- 349
			if ratio > 0.002 then -- 349
				uiInkDraw:drawRect( -- 351
					Rect(pbx, pby - 2.5, pbw * ratio, 5), -- 351
					toColor(PALETTE.sealRedBright, 235 * alpha) -- 351
				) -- 351
				uiInkDraw:drawRect( -- 352
					Rect(pbx, pby + 0.5, pbw * ratio, 1.5), -- 352
					toColor(PALETTE.crimsonCore, 160 * alpha) -- 352
				) -- 352
			end -- 352
			local waves = {0, 540 / 2700, 900 / 2700, 1500 / 2700} -- 355
			local k = 0 -- 356
			do -- 356
				k = 0 -- 357
				while k < #waves do -- 357
					local wx = pbx + pbw * waves[k + 1] -- 358
					local passed = p.gateSpawned > k -- 359
					uiArt:tryPlace( -- 360
						passed and "ink_dot" or "ink_ring", -- 360
						"gate_wave_" .. tostring(k), -- 360
						wx, -- 360
						pby, -- 360
						passed and 9 or 11, -- 360
						passed and 9 or 11, -- 360
						{ -- 360
							color = toColor(passed and PALETTE.amberCore or PALETTE.sealRedBright), -- 361
							opacity = 0.92 * alpha, -- 361
							layer = 3 -- 361
						} -- 361
					) -- 361
					k = k + 1 -- 357
				end -- 357
			end -- 357
		end -- 357
		return -- 365
	end -- 365
	if p.room.key == "checkpoint" or p.room.key == "outside" then -- 365
		local cx = w * 0.5 -- 370
		local by = h - 46 -- 371
		local step1 = p.cartDocked -- 372
		local ____temp_0 -- 373
		if p.room.key == "checkpoint" then -- 373
			____temp_0 = p.gateOpen -- 373
		else -- 373
			____temp_0 = p.checkpoint >= 380 -- 373
		end -- 373
		local step2 = ____temp_0 -- 373
		local t1 = p.room.key == "checkpoint" and "红布板车入窝" or "上层拉车让拱" -- 374
		local t2 = p.room.key == "checkpoint" and "双人汇合出口" or "蹲伏穿拱赴塔" -- 375
		drawInkWashStrip( -- 377
			uiDraw, -- 377
			uiArt, -- 377
			"hud_obj_bg", -- 377
			cx, -- 377
			by, -- 377
			356, -- 377
			36, -- 377
			PALETTE.inkWash, -- 377
			0.7 * alpha, -- 377
			true, -- 377
			-1 -- 377
		) -- 377
		local x1 = cx - 134 -- 379
		uiArt:tryPlace( -- 380
			step1 and "ink_dot" or "ink_ring", -- 380
			"obj_m1", -- 380
			x1, -- 380
			by, -- 380
			12, -- 380
			12, -- 380
			{ -- 380
				color = toColor(step1 and PALETTE.emerald or PALETTE.amber), -- 381
				opacity = 0.92 * alpha, -- 381
				layer = 3 -- 381
			} -- 381
		) -- 381
		texts:put( -- 383
			"xs", -- 383
			t1, -- 383
			x1 + 13, -- 383
			by, -- 383
			toColor(step1 and PALETTE.emerald or PALETTE.textMid), -- 383
			0, -- 383
			0.5, -- 383
			"Left", -- 383
			0.6, -- 383
			alpha -- 383
		) -- 383
		local x2 = cx + 18 -- 385
		uiArt:tryPlace( -- 386
			step2 and "ink_dot" or "ink_ring", -- 386
			"obj_m2", -- 386
			x2, -- 386
			by, -- 386
			12, -- 386
			12, -- 386
			{ -- 386
				color = toColor(step2 and PALETTE.emerald or PALETTE.bronzeDim), -- 387
				opacity = 0.92 * alpha, -- 387
				layer = 3 -- 387
			} -- 387
		) -- 387
		texts:put( -- 389
			"xs", -- 389
			t2, -- 389
			x2 + 13, -- 389
			by, -- 389
			toColor(step2 and PALETTE.emerald or PALETTE.textDim), -- 389
			0, -- 389
			0.5, -- 389
			"Left", -- 389
			0.6, -- 389
			alpha -- 389
		) -- 389
	end -- 389
end -- 316
function HudRenderer.prototype.drawWorldPrompts(self, uiDraw, uiInkDraw, uiArt, texts, prompts, cam, alpha, uiScale) -- 393
	local bob = math.sin(self.time * 3.8) * 3 -- 403
	local i = 0 -- 404
	do -- 404
		i = 0 -- 405
		while i < #prompts do -- 405
			local pr = prompts[i + 1] -- 406
			local sx = math.max( -- 407
				115, -- 407
				math.min( -- 407
					cam.viewW / uiScale - 115, -- 407
					cam:sx(pr.x) / uiScale -- 407
				) -- 407
			) -- 407
			local sy = math.max( -- 408
				96, -- 408
				math.min( -- 408
					cam.viewH / uiScale - 110, -- 408
					cam:sy(pr.y) / uiScale + bob -- 408
				) -- 408
			) -- 408
			local accent = pr.urgent and PALETTE.sealRedBright or PALETTE.amber -- 409
			uiInkDraw:drawSegment( -- 412
				Vec2(sx, sy - 15), -- 412
				Vec2(sx, sy - 29), -- 412
				1, -- 412
				toColor(accent, 160 * alpha) -- 412
			) -- 412
			uiInkDraw:drawDot( -- 413
				Vec2(sx, sy - 29), -- 413
				2.2, -- 413
				toColor(accent, 210 * alpha) -- 413
			) -- 413
			local keyW = math.max( -- 416
				24, -- 416
				visualTextWidth(pr.keyTag, 14) + 14 -- 416
			) -- 416
			local labelW = visualTextWidth(pr.label, 15) -- 417
			local pillW = keyW + labelW + 26 -- 418
			local px = sx - pillW * 0.5 -- 419
			local py = sy - 13 -- 420
			drawInkWashStrip( -- 422
				uiDraw, -- 422
				uiArt, -- 422
				"wp_bg_" .. tostring(i), -- 422
				sx, -- 422
				py + 13, -- 422
				pillW + 24, -- 422
				34, -- 422
				PALETTE.inkWash, -- 422
				0.86 * alpha, -- 422
				true, -- 422
				0 -- 422
			) -- 422
			uiInkDraw:drawSegment( -- 423
				Vec2(px + 2, py + 26), -- 423
				Vec2(px + pillW - 2, py + 26), -- 423
				0.8, -- 423
				toColor(accent, 115 * alpha) -- 423
			) -- 423
			uiInkDraw:drawSegment( -- 424
				Vec2(px + 2, py), -- 424
				Vec2(px + pillW - 2, py), -- 424
				0.8, -- 424
				toColor(accent, 115 * alpha) -- 424
			) -- 424
			drawInkKeycap( -- 425
				uiInkDraw, -- 425
				texts, -- 425
				px + 3, -- 425
				py + 2, -- 425
				keyW, -- 425
				22, -- 425
				pr.keyTag, -- 425
				accent, -- 425
				alpha, -- 425
				pr.urgent -- 425
			) -- 425
			texts:put( -- 426
				"xs", -- 426
				pr.label, -- 426
				px + keyW + 12, -- 426
				py + 13, -- 426
				toColor(PALETTE.textBright), -- 426
				0, -- 426
				0.5, -- 426
				"Left", -- 426
				0.5, -- 426
				alpha -- 426
			) -- 426
			i = i + 1 -- 405
		end -- 405
	end -- 405
end -- 393
function HudRenderer.prototype.drawReticle(self, uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale) -- 430
	local mx = p.aimX / uiScale -- 439
	local my = p.aimY / uiScale -- 440
	if mx <= 0 and my <= 0 then -- 440
		return -- 442
	end -- 442
	if p.childMode then -- 442
		local aiming = p.room.key == "village" and p.hasBottle -- 447
		local col = aiming and PALETTE.amber or PALETTE.bronzeDim -- 448
		uiInkDraw:drawDot( -- 449
			Vec2(mx, my), -- 449
			aiming and 2.2 or 1.8, -- 449
			toColor(col, aiming and 225 or 135) -- 449
		) -- 449
		if aiming then -- 449
			local sz = p.aimHold > 0 and 34 or 26 -- 451
			if not uiArt:tryPlace( -- 451
				"ink_ring", -- 452
				"reticle_child", -- 452
				mx, -- 452
				my, -- 452
				sz, -- 452
				sz, -- 452
				{ -- 452
					color = toColor(PALETTE.amberCore), -- 453
					opacity = 0.86, -- 453
					angle = self.time * 28, -- 453
					layer = 5 -- 453
				} -- 453
			) then -- 453
				uiInkDraw:drawRing( -- 455
					Vec2(mx, my), -- 455
					sz * 0.44, -- 455
					sz * 0.5, -- 455
					Color(0, 0, 0, 0), -- 455
					1.2, -- 455
					toColor(PALETTE.amber, 200) -- 455
				) -- 455
			end -- 455
		end -- 455
		return -- 458
	end -- 458
	local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 462
	local onEnemy = false -- 463
	local i = 0 -- 464
	do -- 464
		i = 0 -- 465
		while i < #p.enemies do -- 465
			local e = p.enemies[i + 1] -- 466
			if e.alive and math.abs(wAim.x - e.x) <= e.w * 0.85 and wAim.y >= e.y - 6 and wAim.y <= e.y + e.h + 6 then -- 466
				onEnemy = true -- 468
			end -- 468
			i = i + 1 -- 465
		end -- 465
	end -- 465
	local col = onEnemy and PALETTE.sealRedBright or PALETTE.xuanPaper -- 472
	local gap = (onEnemy and 5.5 or 7) + vfx.crosshairKick * 0.75 -- 473
	local arm = onEnemy and 8.5 or 9.5 -- 474
	local bg = Color(12, 13, 18, 170) -- 477
	uiInkDraw:drawSegment( -- 478
		Vec2(mx - gap - arm, my), -- 478
		Vec2(mx - gap, my), -- 478
		2.4, -- 478
		bg -- 478
	) -- 478
	uiInkDraw:drawSegment( -- 479
		Vec2(mx + gap, my), -- 479
		Vec2(mx + gap + arm, my), -- 479
		2.4, -- 479
		bg -- 479
	) -- 479
	uiInkDraw:drawSegment( -- 480
		Vec2(mx, my - gap - arm), -- 480
		Vec2(mx, my - gap), -- 480
		2.4, -- 480
		bg -- 480
	) -- 480
	uiInkDraw:drawSegment( -- 481
		Vec2(mx, my + gap), -- 481
		Vec2(mx, my + gap + arm), -- 481
		2.4, -- 481
		bg -- 481
	) -- 481
	uiInkDraw:drawSegment( -- 483
		Vec2(mx - gap - arm, my), -- 483
		Vec2(mx - gap, my), -- 483
		1.3, -- 483
		toColor(col, 235) -- 483
	) -- 483
	uiInkDraw:drawSegment( -- 484
		Vec2(mx + gap, my), -- 484
		Vec2(mx + gap + arm, my), -- 484
		1.3, -- 484
		toColor(col, 235) -- 484
	) -- 484
	uiInkDraw:drawSegment( -- 485
		Vec2(mx, my - gap - arm), -- 485
		Vec2(mx, my - gap), -- 485
		1.3, -- 485
		toColor(col, 235) -- 485
	) -- 485
	uiInkDraw:drawSegment( -- 486
		Vec2(mx, my + gap), -- 486
		Vec2(mx, my + gap + arm), -- 486
		1.3, -- 486
		toColor(col, 235) -- 486
	) -- 486
	uiInkDraw:drawDot( -- 487
		Vec2(mx, my), -- 487
		2, -- 487
		toColor(onEnemy and PALETTE.crimsonCore or PALETTE.xuanPaper, 245) -- 487
	) -- 487
	if onEnemy then -- 487
		local sz = 32 + math.sin(self.time * 12) * 2 -- 490
		uiArt:tryPlace( -- 491
			"ink_ring", -- 491
			"reticle_lock", -- 491
			mx, -- 491
			my, -- 491
			sz, -- 491
			sz, -- 491
			{ -- 491
				color = toColor(PALETTE.sealRedBright), -- 492
				opacity = 0.9, -- 492
				angle = self.time * 42, -- 492
				layer = 5 -- 492
			} -- 492
		) -- 492
		fillRadialGlow( -- 494
			uiGlow, -- 494
			mx, -- 494
			my, -- 494
			18, -- 494
			18, -- 494
			toColor(PALETTE.cinnabar, 36), -- 494
			Color(168, 46, 40, 0), -- 494
			10 -- 494
		) -- 494
	end -- 494
end -- 430
return ____exports -- 430