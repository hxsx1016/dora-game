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
function uiArtSafe(art) -- 500
	return art -- 501
end -- 501
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
			return {seal = "战", text = "前方街心有倭寇封锁。鼠标瞄准，左键发射火铳，空格贴矮台可翻越", urgent = false} -- 245
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
		if p.bottleFly ~= nil then -- 295
			return {seal = "诱", text = "等瓶子落地，把拾荒者引开。", urgent = false} -- 298
		end -- 298
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 298
			return {seal = "潜", text = "趁拾荒者走开，按住 [CTRL] 钻过桌下。", urgent = false} -- 301
		end -- 301
		return {seal = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 303
	end -- 303
	if key == "forest" then -- 303
		if p.dogState == "chase" or p.dogState == "ear" then -- 303
			return {seal = "警", text = "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent = true} -- 308
		end -- 308
		return {seal = "", text = "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent = false} -- 310
	end -- 310
	if key == "tower" then -- 310
		if p.phase == "tower-wait" then -- 310
			return {seal = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 315
		end -- 315
		if p.phase == "tower-knock" then -- 315
			return {seal = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 318
		end -- 318
		if p.phase == "tower-given" then -- 318
			return {seal = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 321
		end -- 321
		return {seal = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 323
	end -- 323
	return {seal = "", text = theme.introWhisper, urgent = false} -- 326
end -- 179
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 329
	local frac = math.min(1, p.countTick / 1440) -- 339
	local countNum = math.min( -- 340
		100, -- 340
		math.floor(frac * 100) -- 340
	) -- 340
	uiDraw:drawRect( -- 342
		Rect(0, 0, w, h), -- 342
		Color( -- 342
			7, -- 342
			8, -- 342
			12, -- 342
			math.floor(74 + frac * 114 + 0.5) -- 342
		) -- 342
	) -- 342
	local cy = h * 0.56 -- 344
	art:tryPlace( -- 345
		"ink_splatter", -- 345
		"gate_count_mist", -- 345
		w * 0.5, -- 345
		cy, -- 345
		260, -- 345
		220, -- 345
		{ -- 345
			color = toColor(PALETTE.inkMist), -- 346
			opacity = 0.34 + frac * 0.22, -- 346
			layer = 0 -- 346
		} -- 346
	) -- 346
	local numZh = toChineseUpper(countNum) -- 350
	texts:put( -- 351
		"title", -- 351
		numZh, -- 351
		w * 0.5, -- 351
		cy + 4, -- 351
		toColor(PALETTE.amberCore), -- 351
		0.5, -- 351
		0.5, -- 351
		"Center", -- 351
		10, -- 351
		0.38 + frac * 0.6 -- 351
	) -- 351
	drawBrushDivider( -- 352
		uiInkDraw, -- 352
		art, -- 352
		"gate_count_div", -- 352
		w * 0.5, -- 352
		cy - 34, -- 352
		240, -- 352
		10, -- 352
		PALETTE.bronzeDim, -- 352
		0.65, -- 352
		2 -- 352
	) -- 352
	texts:put( -- 353
		"sm", -- 353
		"城外静候 · 默数至百", -- 353
		w * 0.5, -- 353
		cy - 54, -- 353
		toColor(PALETTE.textMid), -- 353
		0.5, -- 353
		0.5, -- 353
		"Center", -- 353
		3, -- 353
		0.8 -- 353
	) -- 353
	if p.countTick >= 1440 then -- 353
		local pulse = 0.72 + 0.28 * math.sin(self.time * 3.8) -- 356
		local py = cy - 108 -- 357
		fillRadialGlow( -- 358
			uiGlow, -- 358
			w * 0.5, -- 358
			py, -- 358
			130, -- 358
			24, -- 358
			toColor(PALETTE.amber, 42 * pulse), -- 358
			Color(212, 164, 102, 0), -- 358
			14 -- 358
		) -- 358
		drawInkWashStrip( -- 359
			uiDraw, -- 359
			uiArtSafe(art), -- 359
			"gate_go_strip", -- 359
			w * 0.5, -- 359
			py, -- 359
			300, -- 359
			42, -- 359
			PALETTE.inkWarm, -- 359
			0.86, -- 359
			true, -- 359
			1 -- 359
		) -- 359
		drawBrushDivider( -- 360
			uiInkDraw, -- 360
			art, -- 360
			"gate_go_top", -- 360
			w * 0.5, -- 360
			py + 17, -- 360
			220, -- 360
			8, -- 360
			PALETTE.amber, -- 360
			0.65 * pulse, -- 360
			2 -- 360
		) -- 360
		drawBrushDivider( -- 361
			uiInkDraw, -- 361
			art, -- 361
			"gate_go_bot", -- 361
			w * 0.5, -- 361
			py - 17, -- 361
			220, -- 361
			8, -- 361
			PALETTE.amber, -- 361
			0.65 * pulse, -- 361
			2 -- 361
		) -- 361
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 独自向北" -- 362
		texts:put( -- 363
			"sm", -- 363
			prompt, -- 363
			w * 0.5, -- 363
			py, -- 363
			toColor(PALETTE.amberCore), -- 363
			0.5, -- 363
			0.5, -- 363
			"Center", -- 363
			1.6, -- 363
			1 -- 363
		) -- 363
	end -- 363
end -- 329
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 371
	local cardW = 548 -- 381
	local cardH = 356 -- 382
	local cx = (w - cardW) * 0.5 -- 383
	local cy = (h - cardH) * 0.5 + 10 -- 384
	local midX = w * 0.5 -- 385
	local midY = cy + cardH * 0.5 -- 386
	uiDraw:drawRect( -- 389
		Rect(0, 0, w, h), -- 389
		Color(7, 8, 12, 168) -- 389
	) -- 389
	art:tryPlace( -- 390
		"ink_wash_panel", -- 390
		"reg_shadow", -- 390
		midX, -- 390
		midY - 6, -- 390
		cardW + 52, -- 390
		cardH + 46, -- 390
		{ -- 390
			color = toColor(PALETTE.voidDark), -- 391
			opacity = 0.85, -- 391
			layer = -1 -- 391
		} -- 391
	) -- 391
	if not art:tryPlace( -- 391
		"ui_paper", -- 395
		"registry_paper_full", -- 395
		midX, -- 395
		midY, -- 395
		cardW, -- 395
		cardH, -- 395
		{opacity = 0.96, layer = 1} -- 395
	) then -- 395
		uiDraw:drawRect( -- 396
			Rect(cx, cy, cardW, cardH), -- 396
			toColor(PALETTE.xuanPaper, 245), -- 396
			1.6, -- 396
			toColor(PALETTE.bronzeDim, 210) -- 396
		) -- 396
	end -- 396
	fillRadialGlow( -- 399
		uiGlow, -- 399
		midX, -- 399
		midY + 40, -- 399
		260, -- 399
		140, -- 399
		Color(235, 196, 130, 18), -- 399
		Color(235, 196, 130, 0), -- 399
		16 -- 399
	) -- 399
	local padX = 60 -- 402
	local padY = 44 -- 403
	local inX = cx + padX -- 404
	local inY = cy + padY -- 405
	local inW = cardW - padX * 2 -- 406
	local inH = cardH - padY * 2 -- 407
	local redLine = toColor(PALETTE.sealRed, 145) -- 408
	local redLineFaint = toColor(PALETTE.sealRed, 82) -- 409
	uiInkDraw:drawRect( -- 411
		Rect(inX, inY, inW, inH), -- 411
		Color(0, 0, 0, 0), -- 411
		1.25, -- 411
		redLine -- 411
	) -- 411
	uiInkDraw:drawRect( -- 412
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 412
		Color(0, 0, 0, 0), -- 412
		0.7, -- 412
		redLineFaint -- 412
	) -- 412
	local headY = inY + inH - 26 -- 415
	texts:put( -- 416
		"md", -- 416
		"北塔入塔登记簿 · 末页", -- 416
		inX + 18, -- 416
		headY, -- 416
		toColor(PALETTE.xuanInk), -- 416
		0, -- 416
		0.5, -- 416
		"Left", -- 416
		1.6, -- 416
		0.96, -- 416
		0 -- 416
	) -- 416
	drawSealStamp( -- 417
		uiInkDraw, -- 417
		art, -- 417
		texts, -- 417
		"reg_top_seal", -- 417
		inX + inW - 28, -- 417
		headY, -- 417
		28, -- 417
		"塔", -- 417
		PALETTE.sealRed, -- 417
		PALETTE.sealText, -- 417
		0.9, -- 417
		true, -- 417
		4 -- 417
	) -- 417
	uiInkDraw:drawSegment( -- 418
		Vec2(inX + 12, headY - 22), -- 418
		Vec2(inX + inW - 12, headY - 22), -- 418
		1.1, -- 418
		redLine -- 418
	) -- 418
	local row1Y = headY - 52 -- 421
	texts:put( -- 422
		"sm", -- 422
		"肆拾壹  小满 · 持黄铜指南针与纸条 · 已入塔", -- 422
		inX + 18, -- 422
		row1Y, -- 422
		toColor(PALETTE.xuanInk), -- 422
		0, -- 422
		0.5, -- 422
		"Left", -- 422
		0.5, -- 422
		0.96, -- 422
		0 -- 422
	) -- 422
	texts:put( -- 423
		"xs", -- 423
		"附注：护送者留守南城门，托她独自走完余路。", -- 423
		inX + 18, -- 423
		row1Y - 27, -- 423
		toColor(PALETTE.xuanInkSub), -- 423
		0, -- 423
		0.5, -- 423
		"Left", -- 423
		0.4, -- 423
		0.92, -- 423
		0 -- 423
	) -- 423
	uiInkDraw:drawSegment( -- 424
		Vec2(inX + 14, row1Y - 46), -- 424
		Vec2(inX + inW - 14, row1Y - 46), -- 424
		0.85, -- 424
		redLineFaint -- 424
	) -- 424
	local blankY = row1Y - 74 -- 427
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.4) -- 428
	texts:put( -- 429
		"sm", -- 429
		"肆拾贰", -- 429
		inX + 18, -- 429
		blankY, -- 429
		toColor(PALETTE.sealRed), -- 429
		0, -- 429
		0.5, -- 429
		"Left", -- 429
		0.6, -- 429
		0.94, -- 429
		0 -- 429
	) -- 429
	uiInkDraw:drawSegment( -- 430
		Vec2(inX + 88, blankY - 7), -- 430
		Vec2(inX + inW - 108, blankY - 7), -- 430
		1.15, -- 430
		toColor(PALETTE.xuanInkSub, 175 * pulse) -- 430
	) -- 430
	texts:put( -- 431
		"xs", -- 431
		"（空行留待）", -- 431
		inX + inW - 98, -- 431
		blankY, -- 431
		toColor(PALETTE.xuanInkSub), -- 431
		0, -- 431
		0.5, -- 431
		"Left", -- 431
		0.6, -- 431
		0.86 * pulse, -- 431
		0 -- 431
	) -- 431
	if p.phase == "tower-end" then -- 431
		local signY = inY + 38 -- 435
		texts:put( -- 436
			"banner", -- 436
			"向西守望", -- 436
			midX - 18, -- 436
			signY, -- 436
			toColor(PALETTE.xuanInk), -- 436
			0.5, -- 436
			0.5, -- 436
			"Center", -- 436
			6, -- 436
			0.94, -- 436
			0 -- 436
		) -- 436
		drawOvalSeal( -- 437
			uiInkDraw, -- 437
			art, -- 437
			texts, -- 437
			"reg_end_seal", -- 437
			midX + 86, -- 437
			signY, -- 437
			24, -- 437
			42, -- 437
			"守", -- 437
			"望", -- 437
			PALETTE.sealRed, -- 437
			PALETTE.sealText, -- 437
			0.92, -- 437
			4 -- 437
		) -- 437
		drawInkWashStrip( -- 440
			uiDraw, -- 440
			art, -- 440
			"reg_hint_bg", -- 440
			midX, -- 440
			cy - 28, -- 440
			340, -- 440
			34, -- 440
			PALETTE.inkWash, -- 440
			0.78, -- 440
			true, -- 440
			0 -- 440
		) -- 440
		texts:put( -- 441
			"xs", -- 441
			"[E] 再次启程     ·     [ESC] 暂歇", -- 441
			midX, -- 441
			cy - 28, -- 441
			toColor(PALETTE.amberCore), -- 441
			0.5, -- 441
			0.5, -- 441
			"Center", -- 441
			1.2, -- 441
			0.95 -- 441
		) -- 441
	end -- 441
end -- 371
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 445
	local theme = themeOf(roomKey) -- 454
	local t = self.bannerT / self.bannerMax -- 455
	local alpha = 1 -- 457
	if t > 0.82 then -- 457
		alpha = (1 - t) / 0.18 -- 459
	elseif t < 0.28 then -- 459
		alpha = t / 0.28 -- 461
	end -- 461
	local cx = w * 0.5 -- 463
	local cy = h * 0.77 -- 464
	local spread = math.min(1, alpha * 1.15) -- 465
	drawInkWashStrip( -- 468
		uiDraw, -- 468
		art, -- 468
		"banner_ink", -- 468
		cx, -- 468
		cy + 4, -- 468
		460 * spread + 60, -- 468
		74, -- 468
		PALETTE.inkWash, -- 468
		0.78 * alpha, -- 468
		true, -- 468
		-1 -- 468
	) -- 468
	drawBrushDivider( -- 469
		uiInkDraw, -- 469
		art, -- 469
		"banner_line", -- 469
		cx, -- 469
		cy - 18, -- 469
		340 * spread, -- 469
		12, -- 469
		theme.accent, -- 469
		0.78 * alpha, -- 469
		2 -- 469
	) -- 469
	local sep = " · " -- 472
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 473
	local sealCol = roomKey == "gate" and PALETTE.sealRed or PALETTE.cinnabarDeep -- 474
	if idx > 0 then -- 474
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 476
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 477
		local lw = visualTextWidth(leftPart, 38) -- 478
		local rw = visualTextWidth(rightPart, 38) -- 479
		local dotGap = 24 -- 480
		local totalW = lw + rw + dotGap -- 481
		local leftEdge = cx + 16 - totalW * 0.5 -- 482
		local dotX = leftEdge + lw + dotGap * 0.5 -- 483
		drawSealStamp( -- 485
			uiInkDraw, -- 485
			art, -- 485
			texts, -- 485
			"banner_seal", -- 485
			leftEdge - 24, -- 485
			cy + 14, -- 485
			32, -- 485
			theme.numeralZh, -- 485
			sealCol, -- 485
			PALETTE.sealText, -- 485
			alpha, -- 485
			true, -- 485
			4 -- 485
		) -- 485
		texts:put( -- 486
			"banner", -- 486
			leftPart, -- 486
			leftEdge, -- 486
			cy + 14, -- 486
			toColor(PALETTE.textBright), -- 486
			0, -- 486
			0.5, -- 486
			"Left", -- 486
			2, -- 486
			alpha -- 486
		) -- 486
		art:tryPlace( -- 487
			"ink_dot", -- 487
			"banner_mid_dot", -- 487
			dotX, -- 487
			cy + 12, -- 487
			9, -- 487
			9, -- 487
			{ -- 487
				color = toColor(roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amber), -- 488
				opacity = 0.92 * alpha, -- 488
				layer = 4 -- 488
			} -- 488
		) -- 488
		texts:put( -- 490
			"banner", -- 490
			rightPart, -- 490
			dotX + dotGap * 0.5, -- 490
			cy + 14, -- 490
			toColor(PALETTE.textBright), -- 490
			0, -- 490
			0.5, -- 490
			"Left", -- 490
			2, -- 490
			alpha -- 490
		) -- 490
	else -- 490
		local titleW = visualTextWidth(theme.titleZh, 38) -- 492
		drawSealStamp( -- 493
			uiInkDraw, -- 493
			art, -- 493
			texts, -- 493
			"banner_seal", -- 493
			cx - titleW * 0.5 - 24, -- 493
			cy + 14, -- 493
			32, -- 493
			theme.numeralZh, -- 493
			sealCol, -- 493
			PALETTE.sealText, -- 493
			alpha, -- 493
			true, -- 493
			4 -- 493
		) -- 493
		texts:put( -- 494
			"banner", -- 494
			theme.titleZh, -- 494
			cx + 10, -- 494
			cy + 14, -- 494
			toColor(PALETTE.textBright), -- 494
			0.5, -- 494
			0.5, -- 494
			"Center", -- 494
			3, -- 494
			alpha -- 494
		) -- 494
	end -- 494
	texts:put( -- 496
		"xs", -- 496
		theme.volumeTagZh, -- 496
		cx, -- 496
		cy - 34, -- 496
		toColor(PALETTE.textMid), -- 496
		0.5, -- 496
		0.5, -- 496
		"Center", -- 496
		2.2, -- 496
		0.86 * alpha -- 496
	) -- 496
end -- 445
return ____exports -- 445