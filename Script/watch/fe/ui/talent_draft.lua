-- [ts]: talent_draft.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local Color = ____Dora.Color -- 13
local Rect = ____Dora.Rect -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____run = require("Script.watch.run") -- 15
local ALL_TALENTS = ____run.ALL_TALENTS -- 15
local TALENT_CATALOG = ____run.TALENT_CATALOG -- 15
local ____craft = require("Script.watch.craft") -- 16
local weaponNameOf = ____craft.weaponNameOf -- 16
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 18
local keyTagFor = ____control_prompts.keyTagFor -- 18
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 21
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 21
local ____theme = require("Script.watch.fe.theme") -- 22
local PALETTE = ____theme.PALETTE -- 23
local drawBlossomDot = ____theme.drawBlossomDot -- 25
local drawDiamond = ____theme.drawDiamond -- 26
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 27
local drawHairline = ____theme.drawHairline -- 28
local drawSilkKeycap = ____theme.drawSilkKeycap -- 29
local drawSilkRibbon = ____theme.drawSilkRibbon -- 30
local drawSilkVeil = ____theme.drawSilkVeil -- 31
local fillRadialGlow = ____theme.fillRadialGlow -- 32
local themeOf = ____theme.themeOf -- 33
local toColor = ____theme.toColor -- 34
--- 单一几何真源：计算三张居中宋明折笺本领卡的 UI 逻辑矩形（渲染、点击、触屏热区共用）。
function ____exports.computeTalentSlipRects(uiW, uiH, count, touchMode, safeTop) -- 38
	if touchMode == nil then -- 42
		touchMode = false -- 42
	end -- 42
	if safeTop == nil then -- 43
		safeTop = 0 -- 43
	end -- 43
	local out = {} -- 45
	if count <= 0 then -- 46
		return out -- 47
	end -- 47
	local maxTotalW = math.max(360, uiW - 96) -- 49
	local gap = touchMode and 20 or 24 -- 50
	local baseW = touchMode and 252 or 246 -- 51
	local cardW = math.min( -- 52
		baseW, -- 52
		math.floor((maxTotalW - gap * (count - 1)) / count) -- 52
	) -- 52
	local cardH = math.min( -- 53
		touchMode and 270 or 262, -- 53
		math.max(210, uiH - 220 - safeTop) -- 53
	) -- 53
	local totalW = count * cardW + (count - 1) * gap -- 54
	local startX = (uiW - totalW) * 0.5 -- 55
	local y = math.max(82, (uiH - cardH) * 0.5 - 12 - safeTop * 0.25) -- 56
	local i = 0 -- 57
	do -- 57
		i = 0 -- 58
		while i < count do -- 58
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 59
			i = i + 1 -- 58
		end -- 58
	end -- 58
	return out -- 61
end -- 38
--- 单一几何真源：计算男主线「折戟重整」轮回小结页的两个按钮 UI 逻辑矩形。
function ____exports.computeEscortDeathButtons(uiW, uiH) -- 65
	local cx = uiW * 0.5 -- 69
	local panelH = math.min( -- 70
		390, -- 70
		math.max(320, uiH - 170) -- 70
	) -- 70
	local py = (uiH - panelH) * 0.5 -- 71
	local btnW = 216 -- 72
	local btnH = 44 -- 73
	local btnY = py + 34 -- 74
	local gap = 28 -- 75
	return { -- 76
		retry = Rect(cx - btnW - gap * 0.5, btnY, btnW, btnH), -- 77
		title = Rect(cx + gap * 0.5, btnY, btnW, btnH) -- 78
	} -- 78
end -- 65
local function branchAccent(branch) -- 82
	if branch == "body" then -- 83
		return PALETTE.cyan -- 83
	end -- 83
	if branch == "wheel" then -- 84
		return PALETTE.amber -- 84
	end -- 84
	return PALETTE.rouge -- 85
end -- 82
local function branchCore(branch) -- 88
	if branch == "body" then -- 89
		return PALETTE.cyanCore -- 89
	end -- 89
	if branch == "wheel" then -- 90
		return PALETTE.amberCore -- 90
	end -- 90
	return PALETTE.crimsonCore -- 91
end -- 88
--- 静音/灰度可辨的护身流派几何纹样（厚甲=八角盾印、护身=双环交错、疾步=破风双翼）。
local function drawTalentGlyph(draw, cx, cy, radius, meta, col, alpha) -- 95
	if meta.branch ~= "body" then -- 104
		drawReloadPatternGlyph( -- 105
			draw, -- 105
			cx, -- 105
			cy, -- 105
			radius, -- 105
			meta.glyphEffect, -- 105
			col, -- 105
			alpha -- 105
		) -- 105
		return -- 106
	end -- 106
	local stroke = toColor(col, 235 * alpha) -- 108
	local faint = toColor(col, 130 * alpha) -- 109
	local r = math.max(6, radius) -- 110
	if meta.id == "vitality" then -- 111
		draw:drawPolygon( -- 113
			{ -- 113
				Vec2(cx, cy + r * 0.78), -- 114
				Vec2(cx + r * 0.64, cy + r * 0.42), -- 115
				Vec2(cx + r * 0.52, cy - r * 0.28), -- 116
				Vec2(cx, cy - r * 0.78), -- 117
				Vec2(cx - r * 0.52, cy - r * 0.28), -- 118
				Vec2(cx - r * 0.64, cy + r * 0.42) -- 119
			}, -- 119
			Color(0, 0, 0, 0), -- 120
			1.45, -- 120
			stroke -- 120
		) -- 120
		drawDiamond( -- 121
			draw, -- 121
			cx, -- 121
			cy, -- 121
			r * 0.26, -- 121
			r * 0.34, -- 121
			stroke -- 121
		) -- 121
		return -- 122
	end -- 122
	if meta.id == "guard" then -- 124
		draw:drawRing( -- 126
			Vec2(cx, cy), -- 126
			r * 0.66, -- 126
			r * 0.76, -- 126
			Color(0, 0, 0, 0), -- 126
			1.25, -- 126
			stroke -- 126
		) -- 126
		draw:drawRing( -- 127
			Vec2(cx, cy), -- 127
			r * 0.34, -- 127
			r * 0.42, -- 127
			Color(0, 0, 0, 0), -- 127
			1, -- 127
			faint -- 127
		) -- 127
		draw:drawDot( -- 128
			Vec2(cx, cy + r * 0.92), -- 128
			1.8, -- 128
			stroke -- 128
		) -- 128
		draw:drawDot( -- 129
			Vec2(cx, cy - r * 0.92), -- 129
			1.8, -- 129
			stroke -- 129
		) -- 129
		draw:drawDot( -- 130
			Vec2(cx - r * 0.92, cy), -- 130
			1.8, -- 130
			stroke -- 130
		) -- 130
		draw:drawDot( -- 131
			Vec2(cx + r * 0.92, cy), -- 131
			1.8, -- 131
			stroke -- 131
		) -- 131
		return -- 132
	end -- 132
	draw:drawSegment( -- 135
		Vec2(cx - r * 0.76, cy + r * 0.38), -- 135
		Vec2(cx + r * 0.16, cy + r * 0.38), -- 135
		1.5, -- 135
		stroke -- 135
	) -- 135
	draw:drawSegment( -- 136
		Vec2(cx - r * 0.22, cy + r * 0.68), -- 136
		Vec2(cx + r * 0.24, cy + r * 0.38), -- 136
		1.4, -- 136
		stroke -- 136
	) -- 136
	draw:drawSegment( -- 137
		Vec2(cx - r * 0.44, cy - r * 0.18), -- 137
		Vec2(cx + r * 0.74, cy - r * 0.18), -- 137
		1.6, -- 137
		stroke -- 137
	) -- 137
	draw:drawSegment( -- 138
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 138
		Vec2(cx + r * 0.76, cy - r * 0.18), -- 138
		1.5, -- 138
		stroke -- 138
	) -- 138
	draw:drawSegment( -- 139
		Vec2(cx + r * 0.22, cy - r * 0.5), -- 139
		Vec2(cx + r * 0.76, cy - r * 0.18), -- 139
		1.5, -- 139
		stroke -- 139
	) -- 139
	draw:drawSegment( -- 140
		Vec2(cx - r * 0.74, cy - r * 0.46), -- 140
		Vec2(cx - r * 0.14, cy - r * 0.46), -- 140
		1, -- 140
		faint -- 140
	) -- 140
end -- 95
--- 按 UTF-8 字符边界折行（TSTL Lua 字节索引安全，绝不截断汉字）。
local function wrapTextZh(src, maxUnits) -- 144
	local out = {} -- 145
	local buf = "" -- 146
	local units = 0 -- 147
	local ci = 0 -- 148
	while ci < #src do -- 149
		local b = __TS__StringCharCodeAt(src, ci) -- 150
		local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 151
		local ch = __TS__StringSlice(src, ci, ci + step) -- 152
		local u = b < 128 and 0.56 or 1.02 -- 153
		if units + u > maxUnits and buf ~= "" then -- 154
			out[#out + 1] = buf -- 155
			buf = ch -- 156
			units = u -- 157
		else -- 157
			buf = buf .. ch -- 159
			units = units + u -- 160
		end -- 160
		ci = ci + step -- 162
	end -- 162
	if buf ~= "" then -- 164
		out[#out + 1] = buf -- 165
	end -- 165
	return out -- 167
end -- 144
____exports.TalentDraftPlugin = __TS__Class() -- 170
local TalentDraftPlugin = ____exports.TalentDraftPlugin -- 170
TalentDraftPlugin.name = "TalentDraftPlugin" -- 170
function TalentDraftPlugin.prototype.____constructor(self) -- 170
	self.id = "fe-07-talent-draft" -- 171
	self.selected = 0 -- 173
	self.deathSelected = 0 -- 174
	self.animTime = 0 -- 175
	self.openFade = 0 -- 176
	self.deathFade = 0 -- 177
end -- 170
function TalentDraftPlugin.prototype.onBindPlay(self, _p) -- 179
	self.selected = 0 -- 180
	self.deathSelected = 0 -- 181
	self.openFade = 0 -- 182
	self.deathFade = 0 -- 183
end -- 179
function TalentDraftPlugin.prototype.update(self, ctx) -- 186
	if ctx.paused then -- 187
		return -- 188
	end -- 188
	local dt = math.max(0, ctx.uiDt) -- 190
	self.animTime = self.animTime + dt -- 191
	local p = ctx.p -- 193
	local showDraft = #p:getStoryTalentOffers() > 0 and not p.craftBench.active and not p.reloadOpen and not p.escortFailed -- 194
	if showDraft then -- 196
		self.openFade = math.min(1, self.openFade + dt * 5.2) -- 197
		local count = #p:getStoryTalentOffers() -- 198
		if self.selected >= count then -- 199
			self.selected = 0 -- 200
		end -- 200
		if ctx.input.inputMode == "kbm" and ctx.input.inside then -- 203
			local ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale) -- 204
			local safeTop = ctx.safeUi ~= nil and ctx.safeUi.top or 0 -- 205
			local boxes = ____exports.computeTalentSlipRects( -- 206
				ctx.uiW, -- 206
				ctx.uiH, -- 206
				count, -- 206
				false, -- 206
				safeTop -- 206
			) -- 206
			local i = 0 -- 207
			do -- 207
				i = 0 -- 208
				while i < #boxes do -- 208
					if boxes[i + 1]:containsPoint(ptr) then -- 209
						self.selected = i -- 210
						break -- 211
					end -- 211
					i = i + 1 -- 208
				end -- 208
			end -- 208
		end -- 208
	else -- 208
		self.openFade = 0 -- 216
	end -- 216
	if p.escortFailed then -- 219
		self.deathFade = math.min(1, self.deathFade + dt * 3.8) -- 220
		if ctx.input.inputMode == "kbm" and ctx.input.inside then -- 221
			local ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale) -- 222
			local btns = ____exports.computeEscortDeathButtons(ctx.uiW, ctx.uiH) -- 223
			if btns.retry:containsPoint(ptr) then -- 224
				self.deathSelected = 0 -- 225
			elseif btns.title:containsPoint(ptr) then -- 226
				self.deathSelected = 1 -- 227
			end -- 227
		end -- 227
	else -- 227
		self.deathFade = 0 -- 231
	end -- 231
end -- 186
function TalentDraftPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 235
	local p = ctx.p -- 242
	if p.paused then -- 243
		return false -- 244
	end -- 244
	if p.escortFailed then -- 246
		self:drawDeathSummary( -- 247
			uiDraw, -- 247
			uiInkDraw, -- 247
			uiArt, -- 247
			uiGlow, -- 247
			ctx -- 247
		) -- 247
		return true -- 248
	end -- 248
	local offers = p:getStoryTalentOffers() -- 250
	if #offers > 0 and not p.craftBench.active and not p.reloadOpen then -- 251
		self:drawFoldedSlipDraft( -- 252
			uiDraw, -- 252
			uiInkDraw, -- 252
			uiArt, -- 252
			uiGlow, -- 252
			ctx, -- 252
			offers -- 252
		) -- 252
		return p.talentModalActive -- 253
	end -- 253
	return false -- 255
end -- 235
function TalentDraftPlugin.prototype.drawFoldedSlipDraft(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, offers) -- 258
	local p = ctx.p -- 266
	local w = ctx.uiW -- 267
	local h = ctx.uiH -- 268
	local alpha = math.max(0.25, self.openFade) -- 269
	local touchMode = ctx.input:isTouchMode() -- 270
	local mode = ctx.input.inputMode -- 271
	local safeTop = ctx.safeUi ~= nil and ctx.safeUi.top or 0 -- 272
	local safeBottom = ctx.safeUi ~= nil and ctx.safeUi.bottom or 0 -- 273
	local boxes = ____exports.computeTalentSlipRects( -- 274
		w, -- 274
		h, -- 274
		#offers, -- 274
		touchMode, -- 274
		safeTop -- 274
	) -- 274
	local cx = w * 0.5 -- 275
	if p.talentModalActive then -- 278
		uiDraw:drawRect( -- 279
			Rect(0, 0, w, h), -- 279
			Color( -- 279
				8, -- 279
				10, -- 279
				16, -- 279
				math.floor(142 * alpha + 0.5) -- 279
			) -- 279
		) -- 279
	end -- 279
	local topBox = boxes[1] -- 282
	local headY = math.min(h - 62 - safeTop, topBox.y + topBox.height + 56) -- 283
	local theme = themeOf(p.room.key) -- 284
	local attempt = p:getEscortAttempt() -- 285
	local headTitle = "护送本领 · 三择其一" -- 286
	local subLine = attempt > 1 and ((("第" .. tostring(attempt)) .. "轮 · ") .. theme.shortNameZh) .. " · 择一护身之技" or theme.shortNameZh .. " · 择一护身之技" -- 287
	drawSilkVeil( -- 291
		uiDraw, -- 291
		uiArt, -- 291
		"td_head_veil", -- 291
		cx, -- 291
		headY - 4, -- 291
		420, -- 291
		56, -- 291
		PALETTE.inkWash, -- 291
		0.8 * alpha, -- 291
		0 -- 291
	) -- 291
	drawHairline( -- 292
		uiInkDraw, -- 292
		uiArt, -- 292
		"td_head_line", -- 292
		cx, -- 292
		headY - 30, -- 292
		320, -- 292
		PALETTE.amber, -- 292
		0.56 * alpha, -- 292
		true, -- 292
		2 -- 292
	) -- 292
	ctx.texts:put( -- 293
		"md", -- 293
		headTitle, -- 293
		cx, -- 293
		headY + 6, -- 293
		toColor(PALETTE.textBright), -- 293
		0.5, -- 293
		0.5, -- 293
		"Center", -- 293
		3.2, -- 293
		alpha, -- 293
		0.1 -- 293
	) -- 293
	ctx.texts:put( -- 294
		"xs", -- 294
		subLine, -- 294
		cx, -- 294
		headY - 16, -- 294
		toColor(PALETTE.amberCore), -- 294
		0.5, -- 294
		0.5, -- 294
		"Center", -- 294
		1.4, -- 294
		0.9 * alpha, -- 294
		0.08 -- 294
	) -- 294
	local ranks = p:getStoryTalentRanks() -- 296
	local eq = p.equippedWeapon -- 297
	local breathe = 0.86 + 0.14 * math.sin(self.animTime * 2.8) -- 298
	local i = 0 -- 300
	do -- 300
		i = 0 -- 301
		while i < #offers do -- 301
			local tid = offers[i + 1] -- 302
			local meta = TALENT_CATALOG[tid] -- 303
			local box = boxes[i + 1] -- 304
			local active = i == self.selected -- 305
			local bx = box.x -- 306
			local by = box.y + (active and 6 or 0) -- 307
			local bw = box.width -- 308
			local bh = box.height -- 309
			local mcx = bx + bw * 0.5 -- 310
			local accent = branchAccent(meta.branch) -- 311
			local core = branchCore(meta.branch) -- 312
			local borderCol = active and PALETTE.rouge or accent -- 313
			local curRank = ranks ~= nil and (ranks[tid] or 0) or 0 -- 314
			local hasSynergy = meta.synergyWeapon ~= nil and (eq == meta.synergyWeapon or meta.synergyWeapon == "guide_lantern_gun" and eq == "time_shuttler") -- 315
			uiArt:tryPlace( -- 319
				"ink_frame_mask", -- 319
				"td_shadow_" .. tostring(i), -- 319
				mcx, -- 319
				by + bh * 0.5 - 4, -- 319
				bw + 26, -- 319
				bh + 24, -- 319
				{ -- 319
					color = toColor(PALETTE.inkVoid), -- 320
					opacity = (active and 0.84 or 0.64) * alpha, -- 320
					layer = -1 -- 320
				} -- 320
			) -- 320
			uiDraw:drawRect( -- 322
				Rect(bx, by, bw, bh), -- 323
				toColor( -- 324
					active and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 324
					math.floor((active and 242 or 224) * alpha + 0.5) -- 324
				), -- 324
				active and 1.5 or 0.95, -- 325
				toColor( -- 326
					borderCol, -- 326
					math.floor((active and 242 or 178) * alpha + 0.5) -- 326
				) -- 326
			) -- 326
			uiInkDraw:drawRect( -- 329
				Rect(bx + 6, by + 6, bw - 12, bh - 12), -- 330
				Color(0, 0, 0, 0), -- 331
				0.65, -- 332
				toColor( -- 333
					active and PALETTE.silkLine or PALETTE.silkDim, -- 333
					math.floor((active and 150 or 88) * alpha + 0.5) -- 333
				) -- 333
			) -- 333
			drawFiligreeCorners( -- 335
				uiInkDraw, -- 335
				uiArt, -- 335
				"td_cor_" .. tostring(i), -- 335
				bx, -- 335
				by, -- 335
				bw, -- 335
				bh, -- 335
				borderCol, -- 335
				(active and 0.94 or 0.56) * alpha, -- 335
				22, -- 335
				active, -- 335
				3 -- 335
			) -- 335
			if active then -- 336
				fillRadialGlow( -- 337
					uiGlow, -- 337
					mcx, -- 337
					by + bh - 62, -- 337
					68, -- 337
					52, -- 337
					toColor(accent, 34 * breathe * alpha), -- 337
					Color(0, 0, 0, 0), -- 337
					12 -- 337
				) -- 337
			end -- 337
			if mode == "kbm" then -- 341
				drawSilkKeycap( -- 342
					uiInkDraw, -- 342
					ctx.texts, -- 342
					bx + 14, -- 342
					by + bh - 34, -- 342
					24, -- 342
					22, -- 342
					"" .. tostring(i + 1), -- 342
					borderCol, -- 342
					alpha, -- 342
					active -- 342
				) -- 342
			else -- 342
				drawBlossomDot( -- 344
					uiInkDraw, -- 344
					uiArt, -- 344
					"td_dot_" .. tostring(i), -- 344
					bx + 24, -- 344
					by + bh - 23, -- 344
					active and 13 or 9, -- 344
					borderCol, -- 344
					alpha, -- 344
					4 -- 344
				) -- 344
			end -- 344
			ctx.texts:put( -- 346
				"xs", -- 346
				meta.branchZh, -- 346
				bx + bw - 16, -- 346
				by + bh - 23, -- 346
				toColor(core), -- 346
				1, -- 346
				0.5, -- 346
				"Right", -- 346
				1.4, -- 346
				0.9 * alpha, -- 346
				0.08 -- 346
			) -- 346
			local glyphY = by + bh - 68 -- 349
			uiArt:tryPlace( -- 350
				"ink_enso_fine", -- 350
				"td_ring_" .. tostring(i), -- 350
				mcx, -- 350
				glyphY, -- 350
				56, -- 350
				56, -- 350
				{ -- 350
					color = toColor(active and PALETTE.silkLine or accent), -- 351
					opacity = (active and 0.78 or 0.45) * alpha, -- 351
					layer = 2 -- 351
				} -- 351
			) -- 351
			drawTalentGlyph( -- 353
				uiInkDraw, -- 353
				mcx, -- 353
				glyphY, -- 353
				18, -- 353
				meta, -- 353
				active and PALETTE.textBright or core, -- 353
				alpha -- 353
			) -- 353
			local titleY = glyphY - 46 -- 356
			ctx.texts:put( -- 357
				"md", -- 357
				meta.title, -- 357
				mcx, -- 357
				titleY, -- 357
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 357
				0.5, -- 357
				0.5, -- 357
				"Center", -- 357
				3.6, -- 357
				alpha, -- 357
				0.1 -- 357
			) -- 357
			local rankText = curRank > 0 and ((("已习 " .. tostring(curRank)) .. " 重 → ") .. tostring(curRank + 1)) .. " 重" or "初习" -- 358
			ctx.texts:put( -- 359
				"xs", -- 359
				rankText, -- 359
				mcx, -- 359
				titleY - 22, -- 359
				toColor(curRank > 0 and PALETTE.amberCore or PALETTE.textDim), -- 359
				0.5, -- 359
				0.5, -- 359
				"Center", -- 359
				1, -- 359
				0.9 * alpha, -- 359
				0.08 -- 359
			) -- 359
			drawHairline( -- 360
				uiInkDraw, -- 360
				uiArt, -- 360
				"td_div_" .. tostring(i), -- 360
				mcx, -- 360
				titleY - 36, -- 360
				bw - 40, -- 360
				accent, -- 360
				0.44 * alpha, -- 360
				false, -- 360
				2 -- 360
			) -- 360
			local lines = wrapTextZh( -- 363
				meta.detailDesc, -- 363
				math.max( -- 363
					10, -- 363
					math.floor((bw - 34) / 16) -- 363
				) -- 363
			) -- 363
			local li = 0 -- 364
			do -- 364
				li = 0 -- 365
				while li < math.min(3, #lines) do -- 365
					ctx.texts:put( -- 366
						"xs", -- 367
						lines[li + 1], -- 368
						mcx, -- 369
						titleY - 56 - li * 21, -- 370
						toColor(active and PALETTE.textBright or PALETTE.textMid), -- 371
						0.5, -- 372
						0.5, -- 373
						"Center", -- 374
						0.4, -- 375
						0.94 * alpha, -- 376
						0.06 -- 377
					) -- 377
					li = li + 1 -- 365
				end -- 365
			end -- 365
			if meta.synergyLabel ~= nil then -- 382
				local synY = by + 24 -- 383
				if hasSynergy then -- 384
					drawSilkRibbon( -- 385
						uiDraw, -- 385
						uiArt, -- 385
						"td_syn_" .. tostring(i), -- 385
						mcx, -- 385
						synY, -- 385
						bw - 28, -- 385
						24, -- 385
						PALETTE.rougeSoft, -- 385
						0.62 * alpha, -- 385
						0 -- 385
					) -- 385
				end -- 385
				ctx.texts:put( -- 387
					"xs", -- 388
					hasSynergy and ("· " .. meta.synergyLabel) .. " ·" or meta.synergyLabel, -- 389
					mcx, -- 390
					synY, -- 391
					toColor(hasSynergy and PALETTE.amberCore or PALETTE.textDim), -- 392
					0.5, -- 393
					0.5, -- 394
					"Center", -- 395
					0.8, -- 396
					(hasSynergy and 0.98 or 0.72) * alpha, -- 397
					0.06 -- 398
				) -- 398
			end -- 398
			i = i + 1 -- 301
		end -- 301
	end -- 301
	if ctx.view.assistHintsEnabled or touchMode then -- 404
		local footY = math.max(38 + safeBottom * 0.4, topBox.y - 34) -- 405
		local hint = mode == "gamepad" and ("左摇杆 / LB·RB 择笺   ·   " .. keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " 习得" or (touchMode and "轻触折笺习得此技" or "按 1 / 2 / 3 · ←/→ 与回车或点击折笺习得") -- 406
		ctx.texts:put( -- 411
			"xs", -- 411
			hint, -- 411
			cx, -- 411
			footY, -- 411
			toColor(PALETTE.textDim), -- 411
			0.5, -- 411
			0.5, -- 411
			"Center", -- 411
			1.2, -- 411
			0.88 * alpha, -- 411
			0.08 -- 411
		) -- 411
	end -- 411
end -- 258
function TalentDraftPlugin.prototype.drawDeathSummary(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 415
	local p = ctx.p -- 422
	local summary = p.escortSummary -- 423
	local w = ctx.uiW -- 424
	local h = ctx.uiH -- 425
	local alpha = math.max(0.2, self.deathFade) -- 426
	local cx = w * 0.5 -- 427
	local panelW = math.min(620, w - 84) -- 428
	local panelH = math.min( -- 429
		390, -- 429
		math.max(320, h - 170) -- 429
	) -- 429
	local px = cx - panelW * 0.5 -- 430
	local py = (h - panelH) * 0.5 -- 431
	local midY = py + panelH * 0.5 -- 432
	uiDraw:drawRect( -- 434
		Rect(0, 0, w, h), -- 434
		Color( -- 434
			7, -- 434
			9, -- 434
			14, -- 434
			math.floor(188 * alpha + 0.5) -- 434
		) -- 434
	) -- 434
	uiArt:tryPlace( -- 435
		"ink_frame_mask", -- 435
		"ds_shadow", -- 435
		cx, -- 435
		midY - 6, -- 435
		panelW + 46, -- 435
		panelH + 40, -- 435
		{ -- 435
			color = toColor(PALETTE.inkVoid), -- 436
			opacity = 0.88 * alpha, -- 436
			layer = -1 -- 436
		} -- 436
	) -- 436
	uiDraw:drawRect( -- 438
		Rect(px, py, panelW, panelH), -- 439
		toColor( -- 440
			PALETTE.panelBgDeep, -- 440
			math.floor(244 * alpha + 0.5) -- 440
		), -- 440
		1.2, -- 441
		toColor( -- 442
			PALETTE.rouge, -- 442
			math.floor(200 * alpha + 0.5) -- 442
		) -- 442
	) -- 442
	uiInkDraw:drawRect( -- 444
		Rect(px + 8, py + 8, panelW - 16, panelH - 16), -- 445
		Color(0, 0, 0, 0), -- 446
		0.7, -- 447
		toColor( -- 448
			PALETTE.silkDim, -- 448
			math.floor(115 * alpha + 0.5) -- 448
		) -- 448
	) -- 448
	drawFiligreeCorners( -- 450
		uiInkDraw, -- 450
		uiArt, -- 450
		"ds_cor", -- 450
		px, -- 450
		py, -- 450
		panelW, -- 450
		panelH, -- 450
		PALETTE.rouge, -- 450
		0.88 * alpha, -- 450
		28, -- 450
		true, -- 450
		3 -- 450
	) -- 450
	fillRadialGlow( -- 451
		uiGlow, -- 451
		cx, -- 451
		py + panelH - 68, -- 451
		160, -- 451
		74, -- 451
		toColor(PALETTE.rouge, 26 * alpha), -- 451
		Color(0, 0, 0, 0), -- 451
		14 -- 451
	) -- 451
	local headY = py + panelH - 52 -- 453
	ctx.texts:put( -- 454
		"lg", -- 454
		"折返山道", -- 454
		cx, -- 454
		headY, -- 454
		toColor(PALETTE.crimsonCore), -- 454
		0.5, -- 454
		0.5, -- 454
		"Center", -- 454
		6, -- 454
		alpha, -- 454
		0.1 -- 454
	) -- 454
	ctx.texts:put( -- 455
		"xs", -- 455
		"肩上的人还在，换一条路重头再护。", -- 455
		cx, -- 455
		headY - 34, -- 455
		toColor(PALETTE.textMid), -- 455
		0.5, -- 455
		0.5, -- 455
		"Center", -- 455
		1.4, -- 455
		0.9 * alpha, -- 455
		0.08 -- 455
	) -- 455
	drawHairline( -- 456
		uiInkDraw, -- 456
		uiArt, -- 456
		"ds_div", -- 456
		cx, -- 456
		headY - 54, -- 456
		panelW - 96, -- 456
		PALETTE.silkDim, -- 456
		0.56 * alpha, -- 456
		true, -- 456
		2 -- 456
	) -- 456
	local reachedKey = summary ~= nil and summary.roomKey or p.room.key -- 458
	local reachedTheme = themeOf(reachedKey) -- 459
	local attempt = summary ~= nil and summary.attempt or p:getEscortAttempt() -- 460
	local weapon = weaponNameOf(summary ~= nil and summary.equippedWeapon or p.equippedWeapon) -- 461
	local infoTop = headY - 82 -- 463
	ctx.texts:put( -- 464
		"sm", -- 465
		((("第 " .. tostring(attempt)) .. " 轮护送   ·   止步于「") .. reachedTheme.titleZh) .. "」", -- 466
		cx, -- 467
		infoTop, -- 468
		toColor(PALETTE.textBright), -- 469
		0.5, -- 470
		0.5, -- 471
		"Center", -- 472
		1.2, -- 473
		0.96 * alpha, -- 474
		0.08 -- 475
	) -- 475
	ctx.texts:put( -- 477
		"xs", -- 478
		("执持火器：" .. weapon) .. "   ·   重整后将以新路数自第一段再赴北塔", -- 479
		cx, -- 480
		infoTop - 30, -- 481
		toColor(PALETTE.amberCore), -- 482
		0.5, -- 483
		0.5, -- 484
		"Center", -- 485
		1, -- 486
		0.9 * alpha, -- 487
		0.08 -- 488
	) -- 488
	local rankParts = {} -- 491
	if summary ~= nil then -- 492
		local ti = 0 -- 493
		do -- 493
			ti = 0 -- 494
			while ti < #ALL_TALENTS do -- 494
				local tid = ALL_TALENTS[ti + 1] -- 495
				local rk = summary.ranks[tid] or 0 -- 496
				if rk > 0 then -- 497
					rankParts[#rankParts + 1] = (TALENT_CATALOG[tid].title .. "×") .. tostring(rk) -- 498
				end -- 498
				ti = ti + 1 -- 494
			end -- 494
		end -- 494
	end -- 494
	local talentSummary = #rankParts > 0 and "本轮已习本领：" .. table.concat(rankParts, " · ") or "本轮尚未习得新本领" -- 502
	ctx.texts:put( -- 503
		"xs", -- 503
		talentSummary, -- 503
		cx, -- 503
		infoTop - 60, -- 503
		toColor(PALETTE.textMid), -- 503
		0.5, -- 503
		0.5, -- 503
		"Center", -- 503
		0.8, -- 503
		0.88 * alpha, -- 503
		0.08 -- 503
	) -- 503
	local btns = ____exports.computeEscortDeathButtons(w, h) -- 506
	local ready = p.escortFailedTicks >= 24 -- 507
	local btnAlpha = ready and alpha or alpha * 0.55 -- 508
	local breathe = 0.86 + 0.14 * math.sin(self.animTime * 2.6) -- 509
	local function drawBtn(box, idx, tag, label) -- 511
		local active = self.deathSelected == idx -- 512
		local bcx = box.x + box.width * 0.5 -- 513
		local bcy = box.y + box.height * 0.5 -- 514
		if active then -- 515
			drawSilkRibbon( -- 516
				uiDraw, -- 516
				uiArt, -- 516
				"ds_btn_rib_" .. tag, -- 516
				bcx, -- 516
				bcy, -- 516
				box.width + 18, -- 516
				box.height, -- 516
				PALETTE.rougeSoft, -- 516
				0.64 * breathe * btnAlpha, -- 516
				0 -- 516
			) -- 516
			drawHairline( -- 517
				uiInkDraw, -- 517
				uiArt, -- 517
				"ds_btn_line_" .. tag, -- 517
				bcx, -- 517
				box.y + 3, -- 517
				box.width - 26, -- 517
				PALETTE.silkLine, -- 517
				0.52 * btnAlpha, -- 517
				false, -- 517
				2 -- 517
			) -- 517
			drawBlossomDot( -- 518
				uiInkDraw, -- 518
				uiArt, -- 518
				"ds_btn_dot_" .. tag, -- 518
				box.x + 18, -- 518
				bcy, -- 518
				12, -- 518
				PALETTE.rouge, -- 518
				0.96 * btnAlpha, -- 518
				4 -- 518
			) -- 518
		else -- 518
			drawSilkVeil( -- 520
				uiDraw, -- 520
				uiArt, -- 520
				"ds_btn_idle_" .. tag, -- 520
				bcx, -- 520
				bcy, -- 520
				box.width, -- 520
				box.height - 2, -- 520
				PALETTE.inkWash, -- 520
				0.68 * btnAlpha, -- 520
				0 -- 520
			) -- 520
			drawBlossomDot( -- 521
				uiInkDraw, -- 521
				uiArt, -- 521
				"ds_btn_dot_" .. tag, -- 521
				box.x + 18, -- 521
				bcy, -- 521
				7, -- 521
				PALETTE.silkDim, -- 521
				0.48 * btnAlpha, -- 521
				3 -- 521
			) -- 521
		end -- 521
		ctx.texts:put( -- 523
			"sm", -- 524
			label, -- 525
			bcx + 6, -- 526
			bcy, -- 527
			toColor(active and PALETTE.textBright or PALETTE.textMid), -- 528
			0.5, -- 529
			0.5, -- 530
			"Center", -- 531
			active and 2.4 or 1.4, -- 532
			btnAlpha, -- 533
			0.08 -- 534
		) -- 534
	end -- 511
	drawBtn(btns.retry, 0, "retry", "重整再赴") -- 538
	drawBtn(btns.title, 1, "title", "返回标题") -- 539
end -- 415
return ____exports -- 415
