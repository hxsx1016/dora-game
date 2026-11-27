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
local ____target = require("Script.watch.target") -- 18
local getActiveTarget = ____target.getActiveTarget -- 18
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 21
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 21
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 22
local drawCatalogTalentGlyph = ____talent_catalog.drawTalentGlyph -- 22
local ____theme = require("Script.watch.fe.theme") -- 23
local PALETTE = ____theme.PALETTE -- 24
local drawBlossomDot = ____theme.drawBlossomDot -- 26
local drawDiamond = ____theme.drawDiamond -- 27
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 28
local drawHairline = ____theme.drawHairline -- 29
local drawSilkKeycap = ____theme.drawSilkKeycap -- 30
local drawSilkRibbon = ____theme.drawSilkRibbon -- 31
local drawSilkVeil = ____theme.drawSilkVeil -- 32
local fillRadialGlow = ____theme.fillRadialGlow -- 33
local themeOf = ____theme.themeOf -- 34
local toColor = ____theme.toColor -- 35
--- 单一几何真源：计算三张居中宋明折笺本领卡的 UI 逻辑矩形（渲染、点击、触屏热区共用）。
function ____exports.computeTalentSlipRects(uiW, uiH, count, touchMode, safeTop) -- 39
	if touchMode == nil then -- 43
		touchMode = false -- 43
	end -- 43
	if safeTop == nil then -- 44
		safeTop = 0 -- 44
	end -- 44
	local out = {} -- 46
	if count <= 0 then -- 47
		return out -- 48
	end -- 48
	local maxTotalW = math.max(360, uiW - 96) -- 50
	local gap = touchMode and 20 or 24 -- 51
	local baseW = touchMode and 252 or 246 -- 52
	local cardW = math.min( -- 53
		baseW, -- 53
		math.floor((maxTotalW - gap * (count - 1)) / count) -- 53
	) -- 53
	local cardH = math.min( -- 54
		touchMode and 270 or 262, -- 54
		math.max(210, uiH - 220 - safeTop) -- 54
	) -- 54
	local totalW = count * cardW + (count - 1) * gap -- 55
	local startX = (uiW - totalW) * 0.5 -- 56
	local y = math.max(82, (uiH - cardH) * 0.5 - 12 - safeTop * 0.25) -- 57
	local i = 0 -- 58
	do -- 58
		i = 0 -- 59
		while i < count do -- 59
			out[#out + 1] = Rect(startX + i * (cardW + gap), y, cardW, cardH) -- 60
			i = i + 1 -- 59
		end -- 59
	end -- 59
	return out -- 62
end -- 39
--- 单一几何真源：计算男主线「折戟重整」轮回小结页的两个按钮 UI 逻辑矩形。
function ____exports.computeEscortDeathButtons(uiW, uiH) -- 66
	local cx = uiW * 0.5 -- 70
	local panelH = math.min( -- 71
		390, -- 71
		math.max(320, uiH - 170) -- 71
	) -- 71
	local py = (uiH - panelH) * 0.5 -- 72
	local btnW = 216 -- 73
	local btnH = 44 -- 74
	local btnY = py + 34 -- 75
	local gap = 28 -- 76
	return { -- 77
		retry = Rect(cx - btnW - gap * 0.5, btnY, btnW, btnH), -- 78
		title = Rect(cx + gap * 0.5, btnY, btnW, btnH) -- 79
	} -- 79
end -- 66
local function branchAccent(branch) -- 83
	if branch == "body" then -- 84
		return PALETTE.cyan -- 84
	end -- 84
	if branch == "wheel" then -- 85
		return PALETTE.amber -- 85
	end -- 85
	return PALETTE.rouge -- 86
end -- 83
local function branchCore(branch) -- 89
	if branch == "body" then -- 90
		return PALETTE.cyanCore -- 90
	end -- 90
	if branch == "wheel" then -- 91
		return PALETTE.amberCore -- 91
	end -- 91
	return PALETTE.crimsonCore -- 92
end -- 89
--- 静音/灰度可辨的护身流派几何纹样（厚甲=八角盾印、护身=双环交错、疾步=破风双翼）。
local function drawTalentGlyph(draw, cx, cy, radius, meta, col, alpha) -- 96
	if meta.branch ~= "body" then -- 105
		drawReloadPatternGlyph( -- 106
			draw, -- 106
			cx, -- 106
			cy, -- 106
			radius, -- 106
			meta.glyphEffect, -- 106
			col, -- 106
			alpha -- 106
		) -- 106
		return -- 107
	end -- 107
	local stroke = toColor(col, 235 * alpha) -- 109
	local faint = toColor(col, 130 * alpha) -- 110
	local r = math.max(6, radius) -- 111
	if meta.id == "vitality" then -- 112
		draw:drawPolygon( -- 114
			{ -- 114
				Vec2(cx, cy + r * 0.78), -- 115
				Vec2(cx + r * 0.64, cy + r * 0.42), -- 116
				Vec2(cx + r * 0.52, cy - r * 0.28), -- 117
				Vec2(cx, cy - r * 0.78), -- 118
				Vec2(cx - r * 0.52, cy - r * 0.28), -- 119
				Vec2(cx - r * 0.64, cy + r * 0.42) -- 120
			}, -- 120
			Color(0, 0, 0, 0), -- 121
			1.45, -- 121
			stroke -- 121
		) -- 121
		drawDiamond( -- 122
			draw, -- 122
			cx, -- 122
			cy, -- 122
			r * 0.26, -- 122
			r * 0.34, -- 122
			stroke -- 122
		) -- 122
		return -- 123
	end -- 123
	if meta.id == "guard" then -- 125
		draw:drawRing( -- 127
			Vec2(cx, cy), -- 127
			r * 0.66, -- 127
			r * 0.76, -- 127
			Color(0, 0, 0, 0), -- 127
			1.25, -- 127
			stroke -- 127
		) -- 127
		draw:drawRing( -- 128
			Vec2(cx, cy), -- 128
			r * 0.34, -- 128
			r * 0.42, -- 128
			Color(0, 0, 0, 0), -- 128
			1, -- 128
			faint -- 128
		) -- 128
		draw:drawDot( -- 129
			Vec2(cx, cy + r * 0.92), -- 129
			1.8, -- 129
			stroke -- 129
		) -- 129
		draw:drawDot( -- 130
			Vec2(cx, cy - r * 0.92), -- 130
			1.8, -- 130
			stroke -- 130
		) -- 130
		draw:drawDot( -- 131
			Vec2(cx - r * 0.92, cy), -- 131
			1.8, -- 131
			stroke -- 131
		) -- 131
		draw:drawDot( -- 132
			Vec2(cx + r * 0.92, cy), -- 132
			1.8, -- 132
			stroke -- 132
		) -- 132
		return -- 133
	end -- 133
	draw:drawSegment( -- 136
		Vec2(cx - r * 0.76, cy + r * 0.38), -- 136
		Vec2(cx + r * 0.16, cy + r * 0.38), -- 136
		1.5, -- 136
		stroke -- 136
	) -- 136
	draw:drawSegment( -- 137
		Vec2(cx - r * 0.22, cy + r * 0.68), -- 137
		Vec2(cx + r * 0.24, cy + r * 0.38), -- 137
		1.4, -- 137
		stroke -- 137
	) -- 137
	draw:drawSegment( -- 138
		Vec2(cx - r * 0.44, cy - r * 0.18), -- 138
		Vec2(cx + r * 0.74, cy - r * 0.18), -- 138
		1.6, -- 138
		stroke -- 138
	) -- 138
	draw:drawSegment( -- 139
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 139
		Vec2(cx + r * 0.76, cy - r * 0.18), -- 139
		1.5, -- 139
		stroke -- 139
	) -- 139
	draw:drawSegment( -- 140
		Vec2(cx + r * 0.22, cy - r * 0.5), -- 140
		Vec2(cx + r * 0.76, cy - r * 0.18), -- 140
		1.5, -- 140
		stroke -- 140
	) -- 140
	draw:drawSegment( -- 141
		Vec2(cx - r * 0.74, cy - r * 0.46), -- 141
		Vec2(cx - r * 0.14, cy - r * 0.46), -- 141
		1, -- 141
		faint -- 141
	) -- 141
end -- 96
--- 按 UTF-8 字符边界折行（TSTL Lua 字节索引安全，绝不截断汉字）。
local function wrapTextZh(src, maxUnits) -- 145
	local out = {} -- 146
	local buf = "" -- 147
	local units = 0 -- 148
	local ci = 0 -- 149
	while ci < #src do -- 150
		local b = __TS__StringCharCodeAt(src, ci) -- 151
		local step = b < 128 and 1 or (b < 224 and 2 or (b < 240 and 3 or 4)) -- 152
		local ch = __TS__StringSlice(src, ci, ci + step) -- 153
		local u = b < 128 and 0.56 or 1.02 -- 154
		if units + u > maxUnits and buf ~= "" then -- 155
			out[#out + 1] = buf -- 156
			buf = ch -- 157
			units = u -- 158
		else -- 158
			buf = buf .. ch -- 160
			units = units + u -- 161
		end -- 161
		ci = ci + step -- 163
	end -- 163
	if buf ~= "" then -- 165
		out[#out + 1] = buf -- 166
	end -- 166
	return out -- 168
end -- 145
____exports.TalentDraftPlugin = __TS__Class() -- 171
local TalentDraftPlugin = ____exports.TalentDraftPlugin -- 171
TalentDraftPlugin.name = "TalentDraftPlugin" -- 171
function TalentDraftPlugin.prototype.____constructor(self) -- 171
	self.id = "fe-07-talent-draft" -- 172
	self.selected = 0 -- 174
	self.deathSelected = 0 -- 175
	self.animTime = 0 -- 176
	self.openFade = 0 -- 177
	self.deathFade = 0 -- 178
end -- 171
function TalentDraftPlugin.prototype.onBindPlay(self, _p) -- 180
	self.selected = 0 -- 181
	self.deathSelected = 0 -- 182
	self.openFade = 0 -- 183
	self.deathFade = 0 -- 184
end -- 180
function TalentDraftPlugin.prototype.update(self, ctx) -- 187
	if ctx.paused then -- 188
		return -- 189
	end -- 189
	local dt = math.max(0, ctx.uiDt) -- 191
	self.animTime = self.animTime + dt -- 192
	local p = ctx.p -- 194
	local showDraft = #p:getStoryTalentOffers() > 0 and not p.craftBench.active and not p.reloadOpen and not p.escortFailed -- 195
	if showDraft then -- 197
		self.openFade = math.min(1, self.openFade + dt * 5.2) -- 198
		local count = #p:getStoryTalentOffers() -- 199
		if self.selected >= count then -- 200
			self.selected = 0 -- 201
		end -- 201
		if ctx.input.inputMode == "kbm" and ctx.input.inside then -- 204
			local ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale) -- 205
			local safeTop = ctx.safeUi ~= nil and ctx.safeUi.top or 0 -- 206
			local boxes = ____exports.computeTalentSlipRects( -- 207
				ctx.uiW, -- 207
				ctx.uiH, -- 207
				count, -- 207
				false, -- 207
				safeTop -- 207
			) -- 207
			local i = 0 -- 208
			do -- 208
				i = 0 -- 209
				while i < #boxes do -- 209
					if boxes[i + 1]:containsPoint(ptr) then -- 210
						self.selected = i -- 211
						break -- 212
					end -- 212
					i = i + 1 -- 209
				end -- 209
			end -- 209
		end -- 209
	else -- 209
		self.openFade = 0 -- 217
	end -- 217
	if p.escortFailed then -- 220
		self.deathFade = math.min(1, self.deathFade + dt * 3.8) -- 221
		if ctx.input.inputMode == "kbm" and ctx.input.inside then -- 222
			local ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale) -- 223
			local btns = ____exports.computeEscortDeathButtons(ctx.uiW, ctx.uiH) -- 224
			if btns.retry:containsPoint(ptr) then -- 225
				self.deathSelected = 0 -- 226
			elseif btns.title:containsPoint(ptr) then -- 227
				self.deathSelected = 1 -- 228
			end -- 228
		end -- 228
	else -- 228
		self.deathFade = 0 -- 232
	end -- 232
end -- 187
function TalentDraftPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 236
	local p = ctx.p -- 243
	if p.paused then -- 244
		return false -- 245
	end -- 245
	if p.escortFailed then -- 247
		self:drawDeathSummary( -- 248
			uiDraw, -- 248
			uiInkDraw, -- 248
			uiArt, -- 248
			uiGlow, -- 248
			ctx -- 248
		) -- 248
		return true -- 249
	end -- 249
	local offers = p:getStoryTalentOffers() -- 251
	if p.talentModalActive and #offers > 0 and not p.craftBench.active and not p.reloadOpen then -- 252
		self:drawFoldedSlipDraft( -- 253
			uiDraw, -- 253
			uiInkDraw, -- 253
			uiArt, -- 253
			uiGlow, -- 253
			ctx, -- 253
			offers -- 253
		) -- 253
		return true -- 254
	end -- 254
	return false -- 256
end -- 236
function TalentDraftPlugin.prototype.drawFoldedSlipDraft(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, offers) -- 259
	local p = ctx.p -- 267
	local w = ctx.uiW -- 268
	local h = ctx.uiH -- 269
	local alpha = math.max(0.25, self.openFade) -- 270
	local touchMode = ctx.input:isTouchMode() -- 271
	local mode = ctx.input.inputMode -- 272
	local safeTop = ctx.safeUi ~= nil and ctx.safeUi.top or 0 -- 273
	local safeBottom = ctx.safeUi ~= nil and ctx.safeUi.bottom or 0 -- 274
	local boxes = ____exports.computeTalentSlipRects( -- 275
		w, -- 275
		h, -- 275
		#offers, -- 275
		touchMode, -- 275
		safeTop -- 275
	) -- 275
	local cx = w * 0.5 -- 276
	if p.talentModalActive then -- 279
		uiDraw:drawRect( -- 280
			Rect(0, 0, w, h), -- 280
			Color( -- 280
				8, -- 280
				10, -- 280
				16, -- 280
				math.floor(142 * alpha + 0.5) -- 280
			) -- 280
		) -- 280
	end -- 280
	local topBox = boxes[1] -- 283
	local headY = math.min(h - 62 - safeTop, topBox.y + topBox.height + 56) -- 284
	local theme = themeOf(p.room.key) -- 285
	local attempt = p:getEscortAttempt() -- 286
	local headTitle = "护送本领 · 三择其一" -- 287
	local subLine = attempt > 1 and ((("第" .. tostring(attempt)) .. "轮 · ") .. theme.shortNameZh) .. " · 择一护身之技" or theme.shortNameZh .. " · 择一护身之技" -- 288
	drawSilkVeil( -- 292
		uiDraw, -- 292
		uiArt, -- 292
		"td_head_veil", -- 292
		cx, -- 292
		headY - 4, -- 292
		420, -- 292
		56, -- 292
		PALETTE.inkWash, -- 292
		0.8 * alpha, -- 292
		0 -- 292
	) -- 292
	drawHairline( -- 293
		uiInkDraw, -- 293
		uiArt, -- 293
		"td_head_line", -- 293
		cx, -- 293
		headY - 30, -- 293
		320, -- 293
		PALETTE.amber, -- 293
		0.56 * alpha, -- 293
		true, -- 293
		2 -- 293
	) -- 293
	ctx.texts:put( -- 294
		"md", -- 294
		headTitle, -- 294
		cx, -- 294
		headY + 6, -- 294
		toColor(PALETTE.textBright), -- 294
		0.5, -- 294
		0.5, -- 294
		"Center", -- 294
		3.2, -- 294
		alpha, -- 294
		0.1 -- 294
	) -- 294
	ctx.texts:put( -- 295
		"xs", -- 295
		subLine, -- 295
		cx, -- 295
		headY - 16, -- 295
		toColor(PALETTE.amberCore), -- 295
		0.5, -- 295
		0.5, -- 295
		"Center", -- 295
		1.4, -- 295
		0.9 * alpha, -- 295
		0.08 -- 295
	) -- 295
	local ranks = p:getStoryTalentRanks() -- 297
	local eq = p.equippedWeapon -- 298
	local breathe = 0.86 + 0.14 * math.sin(self.animTime * 2.8) -- 299
	local i = 0 -- 301
	do -- 301
		i = 0 -- 302
		while i < #offers do -- 302
			local tid = offers[i + 1] -- 303
			local meta = TALENT_CATALOG[tid] -- 304
			local box = boxes[i + 1] -- 305
			local active = i == self.selected -- 306
			local bx = box.x -- 307
			local by = box.y + (active and 6 or 0) -- 308
			local bw = box.width -- 309
			local bh = box.height -- 310
			local mcx = bx + bw * 0.5 -- 311
			local accent = branchAccent(meta.branch) -- 312
			local core = branchCore(meta.branch) -- 313
			local borderCol = active and PALETTE.rouge or accent -- 314
			local curRank = ranks ~= nil and (ranks[tid] or 0) or 0 -- 315
			local hasSynergy = meta.synergyWeapon ~= nil and (eq == meta.synergyWeapon or meta.synergyWeapon == "guide_lantern_gun" and eq == "time_shuttler") -- 316
			uiArt:tryPlace( -- 320
				"ink_frame_mask", -- 320
				"td_shadow_" .. tostring(i), -- 320
				mcx, -- 320
				by + bh * 0.5 - 4, -- 320
				bw + 26, -- 320
				bh + 24, -- 320
				{ -- 320
					color = toColor(PALETTE.inkVoid), -- 321
					opacity = (active and 0.84 or 0.64) * alpha, -- 321
					layer = -1 -- 321
				} -- 321
			) -- 321
			uiDraw:drawRect( -- 323
				Rect(bx, by, bw, bh), -- 324
				toColor( -- 325
					active and PALETTE.inkWarm or PALETTE.panelBgDeep, -- 325
					math.floor((active and 242 or 224) * alpha + 0.5) -- 325
				), -- 325
				active and 1.5 or 0.95, -- 326
				toColor( -- 327
					borderCol, -- 327
					math.floor((active and 242 or 178) * alpha + 0.5) -- 327
				) -- 327
			) -- 327
			uiInkDraw:drawRect( -- 330
				Rect(bx + 6, by + 6, bw - 12, bh - 12), -- 331
				Color(0, 0, 0, 0), -- 332
				0.65, -- 333
				toColor( -- 334
					active and PALETTE.silkLine or PALETTE.silkDim, -- 334
					math.floor((active and 150 or 88) * alpha + 0.5) -- 334
				) -- 334
			) -- 334
			drawFiligreeCorners( -- 336
				uiInkDraw, -- 336
				uiArt, -- 336
				"td_cor_" .. tostring(i), -- 336
				bx, -- 336
				by, -- 336
				bw, -- 336
				bh, -- 336
				borderCol, -- 336
				(active and 0.94 or 0.56) * alpha, -- 336
				22, -- 336
				active, -- 336
				3 -- 336
			) -- 336
			if active then -- 337
				fillRadialGlow( -- 338
					uiGlow, -- 338
					mcx, -- 338
					by + bh - 62, -- 338
					68, -- 338
					52, -- 338
					toColor(accent, 34 * breathe * alpha), -- 338
					Color(0, 0, 0, 0), -- 338
					12 -- 338
				) -- 338
			end -- 338
			if mode == "kbm" then -- 342
				drawSilkKeycap( -- 343
					uiInkDraw, -- 343
					ctx.texts, -- 343
					bx + 14, -- 343
					by + bh - 34, -- 343
					24, -- 343
					22, -- 343
					"" .. tostring(i + 1), -- 343
					borderCol, -- 343
					alpha, -- 343
					active -- 343
				) -- 343
			else -- 343
				drawBlossomDot( -- 345
					uiInkDraw, -- 345
					uiArt, -- 345
					"td_dot_" .. tostring(i), -- 345
					bx + 24, -- 345
					by + bh - 23, -- 345
					active and 13 or 9, -- 345
					borderCol, -- 345
					alpha, -- 345
					4 -- 345
				) -- 345
			end -- 345
			ctx.texts:put( -- 347
				"xs", -- 347
				meta.branchZh, -- 347
				bx + bw - 16, -- 347
				by + bh - 23, -- 347
				toColor(core), -- 347
				1, -- 347
				0.5, -- 347
				"Right", -- 347
				1.4, -- 347
				0.9 * alpha, -- 347
				0.08 -- 347
			) -- 347
			local glyphY = by + bh - 68 -- 350
			uiArt:tryPlace( -- 351
				"ink_enso_fine", -- 351
				"td_ring_" .. tostring(i), -- 351
				mcx, -- 351
				glyphY, -- 351
				56, -- 351
				56, -- 351
				{ -- 351
					color = toColor(active and PALETTE.silkLine or accent), -- 352
					opacity = (active and 0.78 or 0.45) * alpha, -- 352
					layer = 2 -- 352
				} -- 352
			) -- 352
			drawCatalogTalentGlyph( -- 354
				uiInkDraw, -- 354
				mcx, -- 354
				glyphY, -- 354
				18, -- 354
				tid, -- 354
				active and PALETTE.textBright or core, -- 354
				alpha, -- 354
				accent -- 354
			) -- 354
			local titleY = glyphY - 46 -- 357
			ctx.texts:put( -- 358
				"md", -- 358
				meta.title, -- 358
				mcx, -- 358
				titleY, -- 358
				toColor(active and PALETTE.textBright or PALETTE.textMid), -- 358
				0.5, -- 358
				0.5, -- 358
				"Center", -- 358
				3.6, -- 358
				alpha, -- 358
				0.1 -- 358
			) -- 358
			local rankText = curRank > 0 and ((("已习 " .. tostring(curRank)) .. " 重 → ") .. tostring(curRank + 1)) .. " 重" or "初习" -- 359
			ctx.texts:put( -- 360
				"xs", -- 360
				rankText, -- 360
				mcx, -- 360
				titleY - 22, -- 360
				toColor(curRank > 0 and PALETTE.amberCore or PALETTE.textDim), -- 360
				0.5, -- 360
				0.5, -- 360
				"Center", -- 360
				1, -- 360
				0.9 * alpha, -- 360
				0.08 -- 360
			) -- 360
			drawHairline( -- 361
				uiInkDraw, -- 361
				uiArt, -- 361
				"td_div_" .. tostring(i), -- 361
				mcx, -- 361
				titleY - 36, -- 361
				bw - 40, -- 361
				accent, -- 361
				0.44 * alpha, -- 361
				false, -- 361
				2 -- 361
			) -- 361
			local lines = wrapTextZh( -- 364
				meta.detailDesc, -- 364
				math.max( -- 364
					10, -- 364
					math.floor((bw - 34) / 16) -- 364
				) -- 364
			) -- 364
			local li = 0 -- 365
			do -- 365
				li = 0 -- 366
				while li < math.min(3, #lines) do -- 366
					ctx.texts:put( -- 367
						"xs", -- 368
						lines[li + 1], -- 369
						mcx, -- 370
						titleY - 56 - li * 21, -- 371
						toColor(active and PALETTE.textBright or PALETTE.textMid), -- 372
						0.5, -- 373
						0.5, -- 374
						"Center", -- 375
						0.4, -- 376
						0.94 * alpha, -- 377
						0.06 -- 378
					) -- 378
					li = li + 1 -- 366
				end -- 366
			end -- 366
			if meta.synergyLabel ~= nil then -- 383
				local synY = by + 24 -- 384
				if hasSynergy then -- 385
					drawSilkRibbon( -- 386
						uiDraw, -- 386
						uiArt, -- 386
						"td_syn_" .. tostring(i), -- 386
						mcx, -- 386
						synY, -- 386
						bw - 28, -- 386
						24, -- 386
						PALETTE.rougeSoft, -- 386
						0.62 * alpha, -- 386
						0 -- 386
					) -- 386
				end -- 386
				ctx.texts:put( -- 388
					"xs", -- 389
					hasSynergy and ("· " .. meta.synergyLabel) .. " ·" or meta.synergyLabel, -- 390
					mcx, -- 391
					synY, -- 392
					toColor(hasSynergy and PALETTE.amberCore or PALETTE.textDim), -- 393
					0.5, -- 394
					0.5, -- 395
					"Center", -- 396
					0.8, -- 397
					(hasSynergy and 0.98 or 0.72) * alpha, -- 398
					0.06 -- 399
				) -- 399
			end -- 399
			i = i + 1 -- 302
		end -- 302
	end -- 302
	if ctx.view.assistHintsEnabled or touchMode then -- 405
		local footY = math.max(38 + safeBottom * 0.4, topBox.y - 34) -- 406
		local hint = mode == "gamepad" and ("左摇杆 / LB·RB 择笺   ·   " .. getActiveTarget():keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout)) .. " 习得" or (touchMode and "轻触折笺习得此技" or "按 1 / 2 / 3 · ←/→ 与回车或点击折笺习得") -- 407
		ctx.texts:put( -- 412
			"xs", -- 412
			hint, -- 412
			cx, -- 412
			footY, -- 412
			toColor(PALETTE.textDim), -- 412
			0.5, -- 412
			0.5, -- 412
			"Center", -- 412
			1.2, -- 412
			0.88 * alpha, -- 412
			0.08 -- 412
		) -- 412
	end -- 412
end -- 259
function TalentDraftPlugin.prototype.drawDeathSummary(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 416
	local p = ctx.p -- 423
	local summary = p.escortSummary -- 424
	local w = ctx.uiW -- 425
	local h = ctx.uiH -- 426
	local alpha = math.max(0.2, self.deathFade) -- 427
	local cx = w * 0.5 -- 428
	local panelW = math.min(620, w - 84) -- 429
	local panelH = math.min( -- 430
		390, -- 430
		math.max(320, h - 170) -- 430
	) -- 430
	local px = cx - panelW * 0.5 -- 431
	local py = (h - panelH) * 0.5 -- 432
	local midY = py + panelH * 0.5 -- 433
	uiDraw:drawRect( -- 435
		Rect(0, 0, w, h), -- 435
		Color( -- 435
			7, -- 435
			9, -- 435
			14, -- 435
			math.floor(188 * alpha + 0.5) -- 435
		) -- 435
	) -- 435
	uiArt:tryPlace( -- 436
		"ink_frame_mask", -- 436
		"ds_shadow", -- 436
		cx, -- 436
		midY - 6, -- 436
		panelW + 46, -- 436
		panelH + 40, -- 436
		{ -- 436
			color = toColor(PALETTE.inkVoid), -- 437
			opacity = 0.88 * alpha, -- 437
			layer = -1 -- 437
		} -- 437
	) -- 437
	uiDraw:drawRect( -- 439
		Rect(px, py, panelW, panelH), -- 440
		toColor( -- 441
			PALETTE.panelBgDeep, -- 441
			math.floor(244 * alpha + 0.5) -- 441
		), -- 441
		1.2, -- 442
		toColor( -- 443
			PALETTE.rouge, -- 443
			math.floor(200 * alpha + 0.5) -- 443
		) -- 443
	) -- 443
	uiInkDraw:drawRect( -- 445
		Rect(px + 8, py + 8, panelW - 16, panelH - 16), -- 446
		Color(0, 0, 0, 0), -- 447
		0.7, -- 448
		toColor( -- 449
			PALETTE.silkDim, -- 449
			math.floor(115 * alpha + 0.5) -- 449
		) -- 449
	) -- 449
	drawFiligreeCorners( -- 451
		uiInkDraw, -- 451
		uiArt, -- 451
		"ds_cor", -- 451
		px, -- 451
		py, -- 451
		panelW, -- 451
		panelH, -- 451
		PALETTE.rouge, -- 451
		0.88 * alpha, -- 451
		28, -- 451
		true, -- 451
		3 -- 451
	) -- 451
	fillRadialGlow( -- 452
		uiGlow, -- 452
		cx, -- 452
		py + panelH - 68, -- 452
		160, -- 452
		74, -- 452
		toColor(PALETTE.rouge, 26 * alpha), -- 452
		Color(0, 0, 0, 0), -- 452
		14 -- 452
	) -- 452
	local headY = py + panelH - 52 -- 454
	ctx.texts:put( -- 455
		"lg", -- 455
		"折返山道", -- 455
		cx, -- 455
		headY, -- 455
		toColor(PALETTE.crimsonCore), -- 455
		0.5, -- 455
		0.5, -- 455
		"Center", -- 455
		6, -- 455
		alpha, -- 455
		0.1 -- 455
	) -- 455
	ctx.texts:put( -- 456
		"xs", -- 456
		"肩上的人还在，换一条路重头再护。", -- 456
		cx, -- 456
		headY - 34, -- 456
		toColor(PALETTE.textMid), -- 456
		0.5, -- 456
		0.5, -- 456
		"Center", -- 456
		1.4, -- 456
		0.9 * alpha, -- 456
		0.08 -- 456
	) -- 456
	drawHairline( -- 457
		uiInkDraw, -- 457
		uiArt, -- 457
		"ds_div", -- 457
		cx, -- 457
		headY - 54, -- 457
		panelW - 96, -- 457
		PALETTE.silkDim, -- 457
		0.56 * alpha, -- 457
		true, -- 457
		2 -- 457
	) -- 457
	local reachedKey = summary ~= nil and summary.roomKey or p.room.key -- 459
	local reachedTheme = themeOf(reachedKey) -- 460
	local attempt = summary ~= nil and summary.attempt or p:getEscortAttempt() -- 461
	local weapon = weaponNameOf(summary ~= nil and summary.equippedWeapon or p.equippedWeapon) -- 462
	local infoTop = headY - 82 -- 464
	ctx.texts:put( -- 465
		"sm", -- 466
		((("第 " .. tostring(attempt)) .. " 轮护送   ·   止步于「") .. reachedTheme.titleZh) .. "」", -- 467
		cx, -- 468
		infoTop, -- 469
		toColor(PALETTE.textBright), -- 470
		0.5, -- 471
		0.5, -- 472
		"Center", -- 473
		1.2, -- 474
		0.96 * alpha, -- 475
		0.08 -- 476
	) -- 476
	ctx.texts:put( -- 478
		"xs", -- 479
		("执持火器：" .. weapon) .. "   ·   重整后将以新路数自第一段再赴北塔", -- 480
		cx, -- 481
		infoTop - 30, -- 482
		toColor(PALETTE.amberCore), -- 483
		0.5, -- 484
		0.5, -- 485
		"Center", -- 486
		1, -- 487
		0.9 * alpha, -- 488
		0.08 -- 489
	) -- 489
	local rankParts = {} -- 492
	if summary ~= nil then -- 493
		local ti = 0 -- 494
		do -- 494
			ti = 0 -- 495
			while ti < #ALL_TALENTS do -- 495
				local tid = ALL_TALENTS[ti + 1] -- 496
				local rk = summary.ranks[tid] or 0 -- 497
				if rk > 0 then -- 498
					rankParts[#rankParts + 1] = (TALENT_CATALOG[tid].title .. "×") .. tostring(rk) -- 499
				end -- 499
				ti = ti + 1 -- 495
			end -- 495
		end -- 495
	end -- 495
	local talentSummary = #rankParts > 0 and "本轮已习本领：" .. table.concat(rankParts, " · ") or "本轮尚未习得新本领" -- 503
	ctx.texts:put( -- 504
		"xs", -- 504
		talentSummary, -- 504
		cx, -- 504
		infoTop - 60, -- 504
		toColor(PALETTE.textMid), -- 504
		0.5, -- 504
		0.5, -- 504
		"Center", -- 504
		0.8, -- 504
		0.88 * alpha, -- 504
		0.08 -- 504
	) -- 504
	local btns = ____exports.computeEscortDeathButtons(w, h) -- 507
	local ready = p.escortFailedTicks >= 24 -- 508
	local btnAlpha = ready and alpha or alpha * 0.55 -- 509
	local breathe = 0.86 + 0.14 * math.sin(self.animTime * 2.6) -- 510
	local function drawBtn(box, idx, tag, label) -- 512
		local active = self.deathSelected == idx -- 513
		local bcx = box.x + box.width * 0.5 -- 514
		local bcy = box.y + box.height * 0.5 -- 515
		if active then -- 516
			drawSilkRibbon( -- 517
				uiDraw, -- 517
				uiArt, -- 517
				"ds_btn_rib_" .. tag, -- 517
				bcx, -- 517
				bcy, -- 517
				box.width + 18, -- 517
				box.height, -- 517
				PALETTE.rougeSoft, -- 517
				0.64 * breathe * btnAlpha, -- 517
				0 -- 517
			) -- 517
			drawHairline( -- 518
				uiInkDraw, -- 518
				uiArt, -- 518
				"ds_btn_line_" .. tag, -- 518
				bcx, -- 518
				box.y + 3, -- 518
				box.width - 26, -- 518
				PALETTE.silkLine, -- 518
				0.52 * btnAlpha, -- 518
				false, -- 518
				2 -- 518
			) -- 518
			drawBlossomDot( -- 519
				uiInkDraw, -- 519
				uiArt, -- 519
				"ds_btn_dot_" .. tag, -- 519
				box.x + 18, -- 519
				bcy, -- 519
				12, -- 519
				PALETTE.rouge, -- 519
				0.96 * btnAlpha, -- 519
				4 -- 519
			) -- 519
		else -- 519
			drawSilkVeil( -- 521
				uiDraw, -- 521
				uiArt, -- 521
				"ds_btn_idle_" .. tag, -- 521
				bcx, -- 521
				bcy, -- 521
				box.width, -- 521
				box.height - 2, -- 521
				PALETTE.inkWash, -- 521
				0.68 * btnAlpha, -- 521
				0 -- 521
			) -- 521
			drawBlossomDot( -- 522
				uiInkDraw, -- 522
				uiArt, -- 522
				"ds_btn_dot_" .. tag, -- 522
				box.x + 18, -- 522
				bcy, -- 522
				7, -- 522
				PALETTE.silkDim, -- 522
				0.48 * btnAlpha, -- 522
				3 -- 522
			) -- 522
		end -- 522
		ctx.texts:put( -- 524
			"sm", -- 525
			label, -- 526
			bcx + 6, -- 527
			bcy, -- 528
			toColor(active and PALETTE.textBright or PALETTE.textMid), -- 529
			0.5, -- 530
			0.5, -- 531
			"Center", -- 532
			active and 2.4 or 1.4, -- 533
			btnAlpha, -- 534
			0.08 -- 535
		) -- 535
	end -- 512
	drawBtn(btns.retry, 0, "retry", "重整再赴") -- 539
	drawBtn(btns.title, 1, "title", "返回标题") -- 540
end -- 416
return ____exports -- 416
