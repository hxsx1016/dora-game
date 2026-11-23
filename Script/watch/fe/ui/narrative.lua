-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local uiArtSafe -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____theme = require("Script.watch.fe.theme") -- 13
local PALETTE = ____theme.PALETTE -- 14
local drawBrushDivider = ____theme.drawBrushDivider -- 15
local drawInkWashStrip = ____theme.drawInkWashStrip -- 16
local drawOvalSeal = ____theme.drawOvalSeal -- 17
local drawSealStamp = ____theme.drawSealStamp -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 19
local themeOf = ____theme.themeOf -- 20
local toChineseUpper = ____theme.toChineseUpper -- 21
local toColor = ____theme.toColor -- 22
local visualTextWidth = ____theme.visualTextWidth -- 23
function uiArtSafe(art) -- 494
	return art -- 495
end -- 495
____exports.NarrativeRenderer = __TS__Class() -- 26
local NarrativeRenderer = ____exports.NarrativeRenderer -- 26
NarrativeRenderer.name = "NarrativeRenderer" -- 26
function NarrativeRenderer.prototype.____constructor(self) -- 26
	self.letterbox = 0 -- 28
	self.bannerT = 0 -- 30
	self.bannerMax = 2.8 -- 31
	self.wipeT = 0 -- 33
	self.lastRoomKey = "" -- 34
	self.time = 0 -- 35
end -- 26
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 37
	self.lastRoomKey = roomKey -- 38
	self.bannerT = self.bannerMax -- 39
	self.wipeT = 1 -- 40
end -- 37
function NarrativeRenderer.prototype.update(self, dt, p) -- 43
	self.time = self.time + dt -- 44
	if self.lastRoomKey ~= p.room.key then -- 44
		self:onEnterRoom(p.room.key) -- 46
	end -- 46
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and p.phase == "gate-count" or p.room.key == "tower" and p.phase ~= "tower-wait" -- 48
	local target = wantCinema and 1 or 0 -- 52
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 53
	if self.bannerT > 0 then -- 53
		self.bannerT = math.max(0, self.bannerT - dt) -- 56
	end -- 56
	if self.wipeT > 0 then -- 56
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 59
	end -- 59
end -- 43
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 63
	if self.letterbox > 0.01 then -- 63
		local barH = math.floor(72 * self.letterbox + 0.5) -- 75
		uiDraw:drawRect( -- 76
			Rect(0, h - barH, w, barH), -- 76
			Color(8, 9, 13, 244) -- 76
		) -- 76
		uiDraw:drawRect( -- 77
			Rect(0, 0, w, barH), -- 77
			Color(8, 9, 13, 244) -- 77
		) -- 77
		uiInkDraw:drawSegment( -- 78
			Vec2(0, h - barH), -- 78
			Vec2(w, h - barH), -- 78
			0.9, -- 78
			toColor(PALETTE.bronzeDim, 90 * self.letterbox) -- 78
		) -- 78
		uiInkDraw:drawSegment( -- 79
			Vec2(0, barH), -- 79
			Vec2(w, barH), -- 79
			0.9, -- 79
			toColor(PALETTE.bronzeDim, 90 * self.letterbox) -- 79
		) -- 79
	end -- 79
	if p.room.key == "gate" and p.phase == "gate-count" then -- 79
		self:drawGateCountOverlay( -- 84
			uiDraw, -- 84
			uiInkDraw, -- 84
			uiGlow, -- 84
			art, -- 84
			texts, -- 84
			p, -- 84
			w, -- 84
			h -- 84
		) -- 84
	end -- 84
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 88
	if showRegistry then -- 88
		self:drawTowerRegistryCard( -- 90
			uiDraw, -- 90
			uiInkDraw, -- 90
			uiGlow, -- 90
			art, -- 90
			texts, -- 90
			p, -- 90
			w, -- 90
			h -- 90
		) -- 90
	end -- 90
	if not p.paused and not showRegistry then -- 90
		self:drawSubtitleStrip( -- 95
			uiDraw, -- 95
			uiInkDraw, -- 95
			art, -- 95
			texts, -- 95
			p, -- 95
			w, -- 95
			h -- 95
		) -- 95
	end -- 95
	if self.bannerT > 0 and not p.paused then -- 95
		self:drawAreaBanner( -- 100
			uiDraw, -- 100
			uiInkDraw, -- 100
			art, -- 100
			texts, -- 100
			p.room.key, -- 100
			w, -- 100
			h -- 100
		) -- 100
	end -- 100
	if self.wipeT > 0.01 then -- 100
		local k = math.min(1, self.wipeT * 1.18) -- 105
		local a = math.floor(255 * k * k + 0.5) -- 106
		uiDraw:drawRect( -- 107
			Rect(0, 0, w, h), -- 107
			Color(9, 10, 14, a) -- 107
		) -- 107
		art:tryPlace( -- 108
			"ink_splatter", -- 108
			"wipe_mist", -- 108
			w * 0.5, -- 108
			h * 0.5, -- 108
			w * 0.72, -- 108
			h * 0.72, -- 108
			{ -- 108
				color = toColor(PALETTE.inkMist), -- 109
				opacity = 0.22 * self.wipeT, -- 109
				layer = 5 -- 109
			} -- 109
		) -- 109
	end -- 109
end -- 63
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 114
	local line = self:composeNarrativeLine(p) -- 123
	if line.text == "" then -- 123
		return -- 125
	end -- 125
	local hasSeal = line.seal ~= "" -- 127
	local textW = visualTextWidth(line.text, 18) -- 128
	local contentW = textW + (hasSeal and 42 or 0) -- 129
	local stripW = math.min( -- 130
		w - 84, -- 130
		math.max(480, contentW + 148) -- 130
	) -- 130
	local stripH = 48 -- 131
	local cx = w * 0.5 -- 132
	local cy = self.letterbox > 0.4 and 36 or 42 -- 133
	drawInkWashStrip( -- 136
		uiDraw, -- 137
		art, -- 138
		"sub_ink_strip", -- 139
		cx, -- 140
		cy, -- 141
		stripW, -- 142
		stripH, -- 143
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 144
		0.88, -- 145
		true, -- 146
		-1 -- 146
	) -- 146
	local railCol = line.urgent and PALETTE.sealRedBright or PALETTE.bronzeDim -- 150
	drawBrushDivider( -- 151
		uiInkDraw, -- 151
		art, -- 151
		"sub_rail_top", -- 151
		cx, -- 151
		cy + 20, -- 151
		stripW * 0.74, -- 151
		8, -- 151
		railCol, -- 151
		0.52, -- 151
		2 -- 151
	) -- 151
	drawBrushDivider( -- 152
		uiInkDraw, -- 152
		art, -- 152
		"sub_rail_bot", -- 152
		cx, -- 152
		cy - 20, -- 152
		stripW * 0.74, -- 152
		8, -- 152
		railCol, -- 152
		0.52, -- 152
		2 -- 152
	) -- 152
	if hasSeal then -- 152
		local startX = cx - contentW * 0.5 -- 155
		local sealCol = line.urgent and PALETTE.sealRed or (p.childMode and PALETTE.amberDim or PALETTE.cyanDim) -- 156
		drawSealStamp( -- 157
			uiInkDraw, -- 158
			art, -- 159
			texts, -- 160
			"sub_seal", -- 161
			startX + 13, -- 162
			cy, -- 163
			25, -- 164
			line.seal, -- 165
			sealCol, -- 166
			PALETTE.sealText, -- 167
			0.96, -- 168
			line.urgent, -- 169
			4 -- 170
		) -- 170
		texts:put( -- 172
			"sm", -- 172
			line.text, -- 172
			startX + 36, -- 172
			cy, -- 172
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 172
			0, -- 172
			0.5, -- 172
			"Left", -- 172
			0.6, -- 172
			0.98 -- 172
		) -- 172
	else -- 172
		texts:put( -- 174
			"sm", -- 174
			line.text, -- 174
			cx, -- 174
			cy, -- 174
			toColor(PALETTE.textBright), -- 174
			0.5, -- 174
			0.5, -- 174
			"Center", -- 174
			0.8, -- 174
			0.98 -- 174
		) -- 174
	end -- 174
end -- 114
function NarrativeRenderer.prototype.composeNarrativeLine(self, p) -- 179
	local key = p.room.key -- 180
	local theme = themeOf(key) -- 181
	if key == "gate" and p.phase == "gate-hold" then -- 181
		local threatened = false -- 184
		local i = 0 -- 185
		do -- 185
			i = 0 -- 186
			while i < #p.enemies do -- 186
				if p.enemies[i + 1].alive and p.enemies[i + 1].warnT > 0 then -- 186
					threatened = true -- 188
				end -- 188
				i = i + 1 -- 186
			end -- 186
		end -- 186
		if threatened then -- 186
			return {seal = "警", text = "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 192
		end -- 192
		if p.coverHug then -- 192
			return {seal = "掩", text = "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent = false} -- 195
		end -- 195
		return {seal = "守", text = "前出至街垒左侧贴掩体，左键点射守住城门", urgent = false} -- 197
	end -- 197
	if key == "gate" and p.phase == "gate-count" then -- 197
		if p.countTick >= 1440 then -- 197
			return {seal = "", text = p.countPrevMove > 0 and "先松开方向键，再按下 [D] —— 由她迈出第一步" or "数到一百了，没有人来。按下 [D]，继续向北走", urgent = false} -- 202
		end -- 202
		return {seal = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 208
	end -- 208
	if p.flash ~= "" and p.flashT > 0 then -- 208
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 212
		local text = p.flash -- 213
		local seal = isDanger and "危" or (p.childMode and "潜" or "战") -- 214
		if key == "tower" or key == "prologue" then -- 214
			seal = "" -- 216
		end -- 216
		if text == "命中" then -- 216
			text = "目标击倒 —— 继续推进并留意掩体" -- 219
		elseif text == "打空" then -- 219
			text = "弹道偏离或被掩体阻挡" -- 221
		elseif text == "翻滚" then -- 221
			text = "伏身翻滚回避" -- 223
		end -- 223
		return {seal = seal, text = text, urgent = isDanger} -- 225
	end -- 225
	if key == "prologue" then -- 225
		if p.phase == "prologue-wait" then -- 225
			return {seal = "", text = "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent = false} -- 230
		end -- 230
		if p.phase == "prologue-give" then -- 230
			return {seal = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 233
		end -- 233
		return {seal = "", text = "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent = false} -- 235
	end -- 235
	if key == "street" then -- 235
		local alive = 0 -- 239
		local i = 0 -- 240
		do -- 240
			i = 0 -- 241
			while i < #p.enemies do -- 241
				if p.enemies[i + 1].alive then -- 241
					alive = alive + 1 -- 242
				end -- 242
				i = i + 1 -- 241
			end -- 241
		end -- 241
		if alive > 0 then -- 241
			return {seal = "战", text = "前方街心有封锁敌兵。鼠标瞄准左键点射，空格贴矮台可翻越", urgent = false} -- 245
		end -- 245
		return {seal = "", text = "街心安静了。带她继续向右，前往城邦检查站", urgent = false} -- 247
	end -- 247
	if key == "checkpoint" then -- 247
		if p.escort.state == "frozen" then -- 247
			return {seal = "危", text = "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 252
		end -- 252
		if p.escort.state == "calming" then -- 252
			return {seal = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 255
		end -- 255
		if not p.cartDocked then -- 255
			return {seal = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 258
		end -- 258
		return {seal = "归", text = "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent = false} -- 260
	end -- 260
	if key == "gate" then -- 260
		if p.phase == "gate-idle" then -- 260
			return {seal = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 265
		end -- 265
		if p.phase == "gate-send" then -- 265
			return {seal = "", text = "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent = false} -- 272
		end -- 272
		return {seal = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 274
	end -- 274
	if key == "outside" then -- 274
		if not p.cartDocked then -- 274
			return {seal = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 279
		end -- 279
		if p.checkpoint < 380 then -- 279
			return {seal = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 282
		end -- 282
		return {seal = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 284
	end -- 284
	if key == "village" then -- 284
		if p.scavChase then -- 284
			return {seal = "危", text = "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent = true} -- 289
		end -- 289
		if p.hasBottle then -- 289
			return {seal = "诱", text = "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent = false} -- 292
		end -- 292
		if p.passed then -- 292
			return {seal = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 295
		end -- 295
		return {seal = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 297
	end -- 297
	if key == "forest" then -- 297
		if p.dogState == "chase" or p.dogState == "ear" then -- 297
			return {seal = "警", text = "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent = true} -- 302
		end -- 302
		return {seal = "", text = "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent = false} -- 304
	end -- 304
	if key == "tower" then -- 304
		if p.phase == "tower-wait" then -- 304
			return {seal = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 309
		end -- 309
		if p.phase == "tower-knock" then -- 309
			return {seal = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 312
		end -- 312
		if p.phase == "tower-given" then -- 312
			return {seal = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 315
		end -- 315
		return {seal = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 317
	end -- 317
	return {seal = "", text = theme.introWhisper, urgent = false} -- 320
end -- 179
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 323
	local frac = math.min(1, p.countTick / 1440) -- 333
	local countNum = math.min( -- 334
		100, -- 334
		math.floor(frac * 100) -- 334
	) -- 334
	uiDraw:drawRect( -- 336
		Rect(0, 0, w, h), -- 336
		Color( -- 336
			7, -- 336
			8, -- 336
			12, -- 336
			math.floor(74 + frac * 114 + 0.5) -- 336
		) -- 336
	) -- 336
	local cy = h * 0.56 -- 338
	art:tryPlace( -- 339
		"ink_splatter", -- 339
		"gate_count_mist", -- 339
		w * 0.5, -- 339
		cy, -- 339
		260, -- 339
		220, -- 339
		{ -- 339
			color = toColor(PALETTE.inkMist), -- 340
			opacity = 0.34 + frac * 0.22, -- 340
			layer = 0 -- 340
		} -- 340
	) -- 340
	local numZh = toChineseUpper(countNum) -- 344
	texts:put( -- 345
		"title", -- 345
		numZh, -- 345
		w * 0.5, -- 345
		cy + 4, -- 345
		toColor(PALETTE.amberCore), -- 345
		0.5, -- 345
		0.5, -- 345
		"Center", -- 345
		10, -- 345
		0.38 + frac * 0.6 -- 345
	) -- 345
	drawBrushDivider( -- 346
		uiInkDraw, -- 346
		art, -- 346
		"gate_count_div", -- 346
		w * 0.5, -- 346
		cy - 34, -- 346
		240, -- 346
		10, -- 346
		PALETTE.bronzeDim, -- 346
		0.65, -- 346
		2 -- 346
	) -- 346
	texts:put( -- 347
		"sm", -- 347
		"城外静候 · 默数至百", -- 347
		w * 0.5, -- 347
		cy - 54, -- 347
		toColor(PALETTE.textMid), -- 347
		0.5, -- 347
		0.5, -- 347
		"Center", -- 347
		3, -- 347
		0.8 -- 347
	) -- 347
	if p.countTick >= 1440 then -- 347
		local pulse = 0.72 + 0.28 * math.sin(self.time * 3.8) -- 350
		local py = cy - 108 -- 351
		fillRadialGlow( -- 352
			uiGlow, -- 352
			w * 0.5, -- 352
			py, -- 352
			130, -- 352
			24, -- 352
			toColor(PALETTE.amber, 42 * pulse), -- 352
			Color(212, 164, 102, 0), -- 352
			14 -- 352
		) -- 352
		drawInkWashStrip( -- 353
			uiDraw, -- 353
			uiArtSafe(art), -- 353
			"gate_go_strip", -- 353
			w * 0.5, -- 353
			py, -- 353
			300, -- 353
			42, -- 353
			PALETTE.inkWarm, -- 353
			0.86, -- 353
			true, -- 353
			1 -- 353
		) -- 353
		drawBrushDivider( -- 354
			uiInkDraw, -- 354
			art, -- 354
			"gate_go_top", -- 354
			w * 0.5, -- 354
			py + 17, -- 354
			220, -- 354
			8, -- 354
			PALETTE.amber, -- 354
			0.65 * pulse, -- 354
			2 -- 354
		) -- 354
		drawBrushDivider( -- 355
			uiInkDraw, -- 355
			art, -- 355
			"gate_go_bot", -- 355
			w * 0.5, -- 355
			py - 17, -- 355
			220, -- 355
			8, -- 355
			PALETTE.amber, -- 355
			0.65 * pulse, -- 355
			2 -- 355
		) -- 355
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 独自向北" -- 356
		texts:put( -- 357
			"sm", -- 357
			prompt, -- 357
			w * 0.5, -- 357
			py, -- 357
			toColor(PALETTE.amberCore), -- 357
			0.5, -- 357
			0.5, -- 357
			"Center", -- 357
			1.6, -- 357
			1 -- 357
		) -- 357
	end -- 357
end -- 323
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 365
	local cardW = 548 -- 375
	local cardH = 356 -- 376
	local cx = (w - cardW) * 0.5 -- 377
	local cy = (h - cardH) * 0.5 + 10 -- 378
	local midX = w * 0.5 -- 379
	local midY = cy + cardH * 0.5 -- 380
	uiDraw:drawRect( -- 383
		Rect(0, 0, w, h), -- 383
		Color(7, 8, 12, 168) -- 383
	) -- 383
	art:tryPlace( -- 384
		"ink_wash_panel", -- 384
		"reg_shadow", -- 384
		midX, -- 384
		midY - 6, -- 384
		cardW + 52, -- 384
		cardH + 46, -- 384
		{ -- 384
			color = toColor(PALETTE.voidDark), -- 385
			opacity = 0.85, -- 385
			layer = -1 -- 385
		} -- 385
	) -- 385
	if not art:tryPlace( -- 385
		"ui_paper", -- 389
		"registry_paper_full", -- 389
		midX, -- 389
		midY, -- 389
		cardW, -- 389
		cardH, -- 389
		{opacity = 0.96, layer = 1} -- 389
	) then -- 389
		uiDraw:drawRect( -- 390
			Rect(cx, cy, cardW, cardH), -- 390
			toColor(PALETTE.xuanPaper, 245), -- 390
			1.6, -- 390
			toColor(PALETTE.bronzeDim, 210) -- 390
		) -- 390
	end -- 390
	fillRadialGlow( -- 393
		uiGlow, -- 393
		midX, -- 393
		midY + 40, -- 393
		260, -- 393
		140, -- 393
		Color(235, 196, 130, 18), -- 393
		Color(235, 196, 130, 0), -- 393
		16 -- 393
	) -- 393
	local padX = 60 -- 396
	local padY = 44 -- 397
	local inX = cx + padX -- 398
	local inY = cy + padY -- 399
	local inW = cardW - padX * 2 -- 400
	local inH = cardH - padY * 2 -- 401
	local redLine = toColor(PALETTE.sealRed, 145) -- 402
	local redLineFaint = toColor(PALETTE.sealRed, 82) -- 403
	uiInkDraw:drawRect( -- 405
		Rect(inX, inY, inW, inH), -- 405
		Color(0, 0, 0, 0), -- 405
		1.25, -- 405
		redLine -- 405
	) -- 405
	uiInkDraw:drawRect( -- 406
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 406
		Color(0, 0, 0, 0), -- 406
		0.7, -- 406
		redLineFaint -- 406
	) -- 406
	local headY = inY + inH - 26 -- 409
	texts:put( -- 410
		"md", -- 410
		"北塔入塔登记簿 · 末页", -- 410
		inX + 18, -- 410
		headY, -- 410
		toColor(PALETTE.xuanInk), -- 410
		0, -- 410
		0.5, -- 410
		"Left", -- 410
		1.6, -- 410
		0.96, -- 410
		0 -- 410
	) -- 410
	drawSealStamp( -- 411
		uiInkDraw, -- 411
		art, -- 411
		texts, -- 411
		"reg_top_seal", -- 411
		inX + inW - 28, -- 411
		headY, -- 411
		28, -- 411
		"塔", -- 411
		PALETTE.sealRed, -- 411
		PALETTE.sealText, -- 411
		0.9, -- 411
		true, -- 411
		4 -- 411
	) -- 411
	uiInkDraw:drawSegment( -- 412
		Vec2(inX + 12, headY - 22), -- 412
		Vec2(inX + inW - 12, headY - 22), -- 412
		1.1, -- 412
		redLine -- 412
	) -- 412
	local row1Y = headY - 52 -- 415
	texts:put( -- 416
		"sm", -- 416
		"肆拾壹  小满 · 持黄铜指南针与纸条 · 已入塔", -- 416
		inX + 18, -- 416
		row1Y, -- 416
		toColor(PALETTE.xuanInk), -- 416
		0, -- 416
		0.5, -- 416
		"Left", -- 416
		0.5, -- 416
		0.96, -- 416
		0 -- 416
	) -- 416
	texts:put( -- 417
		"xs", -- 417
		"附注：护送者留守南城门，托她独自走完余路。", -- 417
		inX + 18, -- 417
		row1Y - 27, -- 417
		toColor(PALETTE.xuanInkSub), -- 417
		0, -- 417
		0.5, -- 417
		"Left", -- 417
		0.4, -- 417
		0.92, -- 417
		0 -- 417
	) -- 417
	uiInkDraw:drawSegment( -- 418
		Vec2(inX + 14, row1Y - 46), -- 418
		Vec2(inX + inW - 14, row1Y - 46), -- 418
		0.85, -- 418
		redLineFaint -- 418
	) -- 418
	local blankY = row1Y - 74 -- 421
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.4) -- 422
	texts:put( -- 423
		"sm", -- 423
		"肆拾贰", -- 423
		inX + 18, -- 423
		blankY, -- 423
		toColor(PALETTE.sealRed), -- 423
		0, -- 423
		0.5, -- 423
		"Left", -- 423
		0.6, -- 423
		0.94, -- 423
		0 -- 423
	) -- 423
	uiInkDraw:drawSegment( -- 424
		Vec2(inX + 88, blankY - 7), -- 424
		Vec2(inX + inW - 108, blankY - 7), -- 424
		1.15, -- 424
		toColor(PALETTE.xuanInkSub, 175 * pulse) -- 424
	) -- 424
	texts:put( -- 425
		"xs", -- 425
		"（空行留待）", -- 425
		inX + inW - 98, -- 425
		blankY, -- 425
		toColor(PALETTE.xuanInkSub), -- 425
		0, -- 425
		0.5, -- 425
		"Left", -- 425
		0.6, -- 425
		0.86 * pulse, -- 425
		0 -- 425
	) -- 425
	if p.phase == "tower-end" then -- 425
		local signY = inY + 38 -- 429
		texts:put( -- 430
			"banner", -- 430
			"向西守望", -- 430
			midX - 18, -- 430
			signY, -- 430
			toColor(PALETTE.xuanInk), -- 430
			0.5, -- 430
			0.5, -- 430
			"Center", -- 430
			6, -- 430
			0.94, -- 430
			0 -- 430
		) -- 430
		drawOvalSeal( -- 431
			uiInkDraw, -- 431
			art, -- 431
			texts, -- 431
			"reg_end_seal", -- 431
			midX + 86, -- 431
			signY, -- 431
			24, -- 431
			42, -- 431
			"守", -- 431
			"望", -- 431
			PALETTE.sealRed, -- 431
			PALETTE.sealText, -- 431
			0.92, -- 431
			4 -- 431
		) -- 431
		drawInkWashStrip( -- 434
			uiDraw, -- 434
			art, -- 434
			"reg_hint_bg", -- 434
			midX, -- 434
			cy - 28, -- 434
			340, -- 434
			34, -- 434
			PALETTE.inkWash, -- 434
			0.78, -- 434
			true, -- 434
			0 -- 434
		) -- 434
		texts:put( -- 435
			"xs", -- 435
			"[E] 再次启程     ·     [ESC] 暂歇", -- 435
			midX, -- 435
			cy - 28, -- 435
			toColor(PALETTE.amberCore), -- 435
			0.5, -- 435
			0.5, -- 435
			"Center", -- 435
			1.2, -- 435
			0.95 -- 435
		) -- 435
	end -- 435
end -- 365
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 439
	local theme = themeOf(roomKey) -- 448
	local t = self.bannerT / self.bannerMax -- 449
	local alpha = 1 -- 451
	if t > 0.82 then -- 451
		alpha = (1 - t) / 0.18 -- 453
	elseif t < 0.28 then -- 453
		alpha = t / 0.28 -- 455
	end -- 455
	local cx = w * 0.5 -- 457
	local cy = h * 0.77 -- 458
	local spread = math.min(1, alpha * 1.15) -- 459
	drawInkWashStrip( -- 462
		uiDraw, -- 462
		art, -- 462
		"banner_ink", -- 462
		cx, -- 462
		cy + 4, -- 462
		460 * spread + 60, -- 462
		74, -- 462
		PALETTE.inkWash, -- 462
		0.78 * alpha, -- 462
		true, -- 462
		-1 -- 462
	) -- 462
	drawBrushDivider( -- 463
		uiInkDraw, -- 463
		art, -- 463
		"banner_line", -- 463
		cx, -- 463
		cy - 18, -- 463
		340 * spread, -- 463
		12, -- 463
		theme.accent, -- 463
		0.78 * alpha, -- 463
		2 -- 463
	) -- 463
	local sep = " · " -- 466
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 467
	local sealCol = roomKey == "gate" and PALETTE.sealRed or PALETTE.cinnabarDeep -- 468
	if idx > 0 then -- 468
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 470
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 471
		local lw = visualTextWidth(leftPart, 38) -- 472
		local rw = visualTextWidth(rightPart, 38) -- 473
		local dotGap = 24 -- 474
		local totalW = lw + rw + dotGap -- 475
		local leftEdge = cx + 16 - totalW * 0.5 -- 476
		local dotX = leftEdge + lw + dotGap * 0.5 -- 477
		drawSealStamp( -- 479
			uiInkDraw, -- 479
			art, -- 479
			texts, -- 479
			"banner_seal", -- 479
			leftEdge - 24, -- 479
			cy + 14, -- 479
			32, -- 479
			theme.numeralZh, -- 479
			sealCol, -- 479
			PALETTE.sealText, -- 479
			alpha, -- 479
			true, -- 479
			4 -- 479
		) -- 479
		texts:put( -- 480
			"banner", -- 480
			leftPart, -- 480
			leftEdge, -- 480
			cy + 14, -- 480
			toColor(PALETTE.textBright), -- 480
			0, -- 480
			0.5, -- 480
			"Left", -- 480
			2, -- 480
			alpha -- 480
		) -- 480
		art:tryPlace( -- 481
			"ink_dot", -- 481
			"banner_mid_dot", -- 481
			dotX, -- 481
			cy + 12, -- 481
			9, -- 481
			9, -- 481
			{ -- 481
				color = toColor(roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amber), -- 482
				opacity = 0.92 * alpha, -- 482
				layer = 4 -- 482
			} -- 482
		) -- 482
		texts:put( -- 484
			"banner", -- 484
			rightPart, -- 484
			dotX + dotGap * 0.5, -- 484
			cy + 14, -- 484
			toColor(PALETTE.textBright), -- 484
			0, -- 484
			0.5, -- 484
			"Left", -- 484
			2, -- 484
			alpha -- 484
		) -- 484
	else -- 484
		local titleW = visualTextWidth(theme.titleZh, 38) -- 486
		drawSealStamp( -- 487
			uiInkDraw, -- 487
			art, -- 487
			texts, -- 487
			"banner_seal", -- 487
			cx - titleW * 0.5 - 24, -- 487
			cy + 14, -- 487
			32, -- 487
			theme.numeralZh, -- 487
			sealCol, -- 487
			PALETTE.sealText, -- 487
			alpha, -- 487
			true, -- 487
			4 -- 487
		) -- 487
		texts:put( -- 488
			"banner", -- 488
			theme.titleZh, -- 488
			cx + 10, -- 488
			cy + 14, -- 488
			toColor(PALETTE.textBright), -- 488
			0.5, -- 488
			0.5, -- 488
			"Center", -- 488
			3, -- 488
			alpha -- 488
		) -- 488
	end -- 488
	texts:put( -- 490
		"xs", -- 490
		theme.volumeTagZh, -- 490
		cx, -- 490
		cy - 34, -- 490
		toColor(PALETTE.textMid), -- 490
		0.5, -- 490
		0.5, -- 490
		"Center", -- 490
		2.2, -- 490
		0.86 * alpha -- 490
	) -- 490
end -- 439
return ____exports -- 439