-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____theme = require("Script.watch.fe.theme") -- 13
local PALETTE = ____theme.PALETTE -- 14
local drawBlossomDot = ____theme.drawBlossomDot -- 15
local drawHairline = ____theme.drawHairline -- 16
local drawLoneSeal = ____theme.drawLoneSeal -- 17
local drawMistCurve = ____theme.drawMistCurve -- 18
local drawSilkRibbon = ____theme.drawSilkRibbon -- 19
local drawSilkVeil = ____theme.drawSilkVeil -- 20
local fillRadialGlow = ____theme.fillRadialGlow -- 21
local themeOf = ____theme.themeOf -- 22
local toChineseUpper = ____theme.toChineseUpper -- 23
local toColor = ____theme.toColor -- 24
local visualTextWidth = ____theme.visualTextWidth -- 25
____exports.NarrativeRenderer = __TS__Class() -- 28
local NarrativeRenderer = ____exports.NarrativeRenderer -- 28
NarrativeRenderer.name = "NarrativeRenderer" -- 28
function NarrativeRenderer.prototype.____constructor(self) -- 28
	self.letterbox = 0 -- 30
	self.bannerT = 0 -- 32
	self.bannerMax = 2.8 -- 33
	self.wipeT = 0 -- 35
	self.lastRoomKey = "" -- 36
	self.time = 0 -- 37
end -- 28
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 39
	self.lastRoomKey = roomKey -- 40
	self.bannerT = self.bannerMax -- 41
	self.wipeT = 1 -- 42
end -- 39
function NarrativeRenderer.prototype.update(self, dt, p) -- 45
	self.time = self.time + dt -- 46
	if self.lastRoomKey ~= p.room.key then -- 46
		self:onEnterRoom(p.room.key) -- 48
	end -- 48
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and p.phase == "gate-count" or p.room.key == "tower" and p.phase ~= "tower-wait" -- 50
	local target = wantCinema and 1 or 0 -- 54
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 55
	if self.bannerT > 0 then -- 55
		self.bannerT = math.max(0, self.bannerT - dt) -- 58
	end -- 58
	if self.wipeT > 0 then -- 58
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 61
	end -- 61
end -- 45
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 65
	if self.letterbox > 0.01 then -- 65
		local barH = math.floor(70 * self.letterbox + 0.5) -- 77
		uiDraw:drawRect( -- 78
			Rect(0, h - barH, w, barH), -- 78
			Color(8, 10, 16, 242) -- 78
		) -- 78
		uiDraw:drawRect( -- 79
			Rect(0, 0, w, barH), -- 79
			Color(8, 10, 16, 242) -- 79
		) -- 79
		uiInkDraw:drawSegment( -- 80
			Vec2(0, h - barH), -- 80
			Vec2(w, h - barH), -- 80
			0.7, -- 80
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 80
		) -- 80
		uiInkDraw:drawSegment( -- 81
			Vec2(0, barH), -- 81
			Vec2(w, barH), -- 81
			0.7, -- 81
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 81
		) -- 81
	end -- 81
	if p.room.key == "gate" and p.phase == "gate-count" then -- 81
		self:drawGateCountOverlay( -- 86
			uiDraw, -- 86
			uiInkDraw, -- 86
			uiGlow, -- 86
			art, -- 86
			texts, -- 86
			p, -- 86
			w, -- 86
			h -- 86
		) -- 86
	end -- 86
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 90
	if showRegistry then -- 90
		self:drawTowerRegistryCard( -- 92
			uiDraw, -- 92
			uiInkDraw, -- 92
			uiGlow, -- 92
			art, -- 92
			texts, -- 92
			p, -- 92
			w, -- 92
			h -- 92
		) -- 92
	end -- 92
	if not p.paused and not showRegistry then -- 92
		self:drawSubtitleStrip( -- 97
			uiDraw, -- 97
			uiInkDraw, -- 97
			art, -- 97
			texts, -- 97
			p, -- 97
			w, -- 97
			h -- 97
		) -- 97
	end -- 97
	if self.bannerT > 0 and not p.paused then -- 97
		self:drawAreaBanner( -- 102
			uiDraw, -- 102
			uiInkDraw, -- 102
			art, -- 102
			texts, -- 102
			p.room.key, -- 102
			w, -- 102
			h -- 102
		) -- 102
	end -- 102
	if self.wipeT > 0.01 then -- 102
		local k = math.min(1, self.wipeT * 1.15) -- 107
		local a = math.floor(255 * k * k + 0.5) -- 108
		uiDraw:drawRect( -- 109
			Rect(0, 0, w, h), -- 109
			Color(9, 11, 17, a) -- 109
		) -- 109
		art:tryPlace( -- 110
			"ink_petal_mist", -- 110
			"wipe_mist", -- 110
			w * 0.5, -- 110
			h * 0.5, -- 110
			w * 0.65, -- 110
			h * 0.65, -- 110
			{ -- 110
				color = toColor(PALETTE.inkMist), -- 111
				opacity = 0.2 * self.wipeT, -- 111
				layer = 5 -- 111
			} -- 111
		) -- 111
	end -- 111
end -- 65
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 116
	local line = self:composeNarrativeLine(p) -- 125
	if line.text == "" then -- 125
		return -- 127
	end -- 127
	local hasCue = line.cue ~= "" -- 129
	local textW = visualTextWidth(line.text, 18) -- 130
	local contentW = textW + (hasCue and 48 or 0) -- 131
	local stripW = math.min( -- 132
		w - 72, -- 132
		math.max(540, contentW + 210) -- 132
	) -- 132
	local stripH = 54 -- 133
	local cx = w * 0.5 -- 134
	local cy = self.letterbox > 0.4 and 36 or 42 -- 135
	drawSilkVeil( -- 138
		uiDraw, -- 138
		art, -- 138
		"sub_veil", -- 138
		cx, -- 138
		cy, -- 138
		stripW, -- 138
		stripH, -- 138
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 138
		0.84, -- 138
		-1 -- 138
	) -- 138
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 140
	drawHairline( -- 141
		uiInkDraw, -- 141
		art, -- 141
		"sub_top_line", -- 141
		cx, -- 141
		cy + 23, -- 141
		stripW * 0.72, -- 141
		railCol, -- 141
		line.urgent and 0.72 or 0.52, -- 141
		true, -- 141
		2 -- 141
	) -- 141
	if hasCue then -- 141
		local startX = cx - contentW * 0.5 -- 144
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 145
		drawBlossomDot( -- 146
			uiInkDraw, -- 146
			art, -- 146
			"sub_cue_dot", -- 146
			startX + 6, -- 146
			cy - 1, -- 146
			10, -- 146
			cueCol, -- 146
			0.94, -- 146
			4 -- 146
		) -- 146
		texts:put( -- 147
			"xs", -- 147
			line.cue, -- 147
			startX + 24, -- 147
			cy - 1, -- 147
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 147
			0.5, -- 147
			0.5, -- 147
			"Center", -- 147
			0, -- 147
			0.96, -- 147
			0.08 -- 147
		) -- 147
		uiInkDraw:drawSegment( -- 148
			Vec2(startX + 38, cy - 8), -- 148
			Vec2(startX + 38, cy + 6), -- 148
			0.75, -- 148
			toColor(PALETTE.silkDim, 115) -- 148
		) -- 148
		texts:put( -- 149
			"sm", -- 149
			line.text, -- 149
			startX + 48, -- 149
			cy - 1, -- 149
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 149
			0, -- 149
			0.5, -- 149
			"Left", -- 149
			0.9, -- 149
			0.98, -- 149
			0.08 -- 149
		) -- 149
	else -- 149
		texts:put( -- 151
			"sm", -- 151
			line.text, -- 151
			cx, -- 151
			cy - 1, -- 151
			toColor(PALETTE.textBright), -- 151
			0.5, -- 151
			0.5, -- 151
			"Center", -- 151
			1, -- 151
			0.98, -- 151
			0.08 -- 151
		) -- 151
	end -- 151
end -- 116
function NarrativeRenderer.prototype.composeNarrativeLine(self, p) -- 156
	local key = p.room.key -- 157
	local theme = themeOf(key) -- 158
	if key == "gate" and p.phase == "gate-hold" then -- 158
		local threatened = false -- 161
		local i = 0 -- 162
		do -- 162
			i = 0 -- 163
			while i < #p.enemies do -- 163
				if p.enemies[i + 1].alive and p.enemies[i + 1].warnT > 0 then -- 163
					threatened = true -- 165
				end -- 165
				i = i + 1 -- 163
			end -- 163
		end -- 163
		if threatened then -- 163
			return {cue = "警", text = "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 169
		end -- 169
		if p.coverHug then -- 169
			return {cue = "掩", text = "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent = false} -- 172
		end -- 172
		return {cue = "守", text = "前出至街垒左侧贴掩体，左键点射守住城门", urgent = false} -- 174
	end -- 174
	if key == "gate" and p.phase == "gate-count" then -- 174
		if p.countTick >= 1440 then -- 174
			return {cue = "", text = p.countPrevMove > 0 and "先松开方向键，再按下 [D] —— 由她迈出第一步" or "数到一百了，没有人来。按下 [D]，继续向北走", urgent = false} -- 179
		end -- 179
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 185
	end -- 185
	if p.flash ~= "" and p.flashT > 0 then -- 185
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 189
		local text = p.flash -- 190
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 191
		if key == "tower" or key == "prologue" then -- 191
			cue = "" -- 193
		end -- 193
		if text == "命中" then -- 193
			text = "目标击倒 —— 继续推进并留意掩体" -- 196
		elseif text == "打空" then -- 196
			text = "弹道偏离或被掩体阻挡" -- 198
		elseif text == "翻滚" then -- 198
			text = "伏身翻滚回避" -- 200
		end -- 200
		return {cue = cue, text = text, urgent = isDanger} -- 202
	end -- 202
	if key == "prologue" then -- 202
		if p.phase == "prologue-wait" then -- 202
			return {cue = "", text = "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent = false} -- 207
		end -- 207
		if p.phase == "prologue-give" then -- 207
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 210
		end -- 210
		return {cue = "", text = "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent = false} -- 212
	end -- 212
	if key == "street" then -- 212
		local alive = 0 -- 216
		local i = 0 -- 217
		do -- 217
			i = 0 -- 218
			while i < #p.enemies do -- 218
				if p.enemies[i + 1].alive then -- 218
					alive = alive + 1 -- 219
				end -- 219
				i = i + 1 -- 218
			end -- 218
		end -- 218
		if alive > 0 then -- 218
			return {cue = "战", text = "前方街心有封锁敌兵。鼠标瞄准左键点射，空格贴矮台可翻越", urgent = false} -- 222
		end -- 222
		return {cue = "", text = "街心安静了。带她继续向右，前往城邦检查站", urgent = false} -- 224
	end -- 224
	if key == "checkpoint" then -- 224
		if p.escort.state == "frozen" then -- 224
			return {cue = "危", text = "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 229
		end -- 229
		if p.escort.state == "calming" then -- 229
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 232
		end -- 232
		if not p.cartDocked then -- 232
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 235
		end -- 235
		return {cue = "归", text = "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent = false} -- 237
	end -- 237
	if key == "gate" then -- 237
		if p.phase == "gate-idle" then -- 237
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 242
		end -- 242
		if p.phase == "gate-send" then -- 242
			return {cue = "", text = "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent = false} -- 249
		end -- 249
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 251
	end -- 251
	if key == "outside" then -- 251
		if not p.cartDocked then -- 251
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 256
		end -- 256
		if p.checkpoint < 380 then -- 256
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 259
		end -- 259
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 261
	end -- 261
	if key == "village" then -- 261
		if p.scavChase then -- 261
			return {cue = "危", text = "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent = true} -- 266
		end -- 266
		if p.hasBottle then -- 266
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent = false} -- 269
		end -- 269
		if p.passed then -- 269
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 272
		end -- 272
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 274
	end -- 274
	if key == "forest" then -- 274
		if p.dogState == "chase" or p.dogState == "ear" then -- 274
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent = true} -- 279
		end -- 279
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent = false} -- 281
	end -- 281
	if key == "tower" then -- 281
		if p.phase == "tower-wait" then -- 281
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 286
		end -- 286
		if p.phase == "tower-knock" then -- 286
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 289
		end -- 289
		if p.phase == "tower-given" then -- 289
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 292
		end -- 292
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 294
	end -- 294
	return {cue = "", text = theme.introWhisper, urgent = false} -- 297
end -- 156
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 300
	local frac = math.min(1, p.countTick / 1440) -- 310
	local countNum = math.min( -- 311
		100, -- 311
		math.floor(frac * 100) -- 311
	) -- 311
	uiDraw:drawRect( -- 312
		Rect(0, 0, w, h), -- 312
		Color( -- 312
			7, -- 312
			9, -- 312
			15, -- 312
			math.floor(78 + frac * 116 + 0.5) -- 312
		) -- 312
	) -- 312
	local cy = h * 0.56 -- 314
	art:tryPlace( -- 315
		"ink_petal_mist", -- 315
		"gate_count_mist", -- 315
		w * 0.5, -- 315
		cy, -- 315
		290, -- 315
		220, -- 315
		{ -- 315
			color = toColor(PALETTE.inkMist), -- 316
			opacity = 0.34 + frac * 0.2, -- 316
			layer = 0 -- 316
		} -- 316
	) -- 316
	drawMistCurve( -- 318
		art, -- 318
		"gate_count_wisp", -- 318
		w * 0.5, -- 318
		cy - 8, -- 318
		420, -- 318
		76, -- 318
		PALETTE.jadeMist, -- 318
		0.22, -- 318
		0 -- 318
	) -- 318
	local numZh = toChineseUpper(countNum) -- 320
	texts:put( -- 321
		"title", -- 321
		numZh, -- 321
		w * 0.5, -- 321
		cy + 8, -- 321
		toColor(PALETTE.textBright), -- 321
		0.5, -- 321
		0.5, -- 321
		"Center", -- 321
		12, -- 321
		0.42 + frac * 0.56, -- 321
		0.1 -- 321
	) -- 321
	drawHairline( -- 322
		uiInkDraw, -- 322
		art, -- 322
		"gate_count_div", -- 322
		w * 0.5, -- 322
		cy - 34, -- 322
		240, -- 322
		PALETTE.silkDim, -- 322
		0.62, -- 322
		true, -- 322
		2 -- 322
	) -- 322
	texts:put( -- 323
		"sm", -- 323
		"城外静候 · 默数至百", -- 323
		w * 0.5, -- 323
		cy - 58, -- 323
		toColor(PALETTE.textMid), -- 323
		0.5, -- 323
		0.5, -- 323
		"Center", -- 323
		3.4, -- 323
		0.84, -- 323
		0.08 -- 323
	) -- 323
	if p.countTick >= 1440 then -- 323
		local pulse = 0.72 + 0.28 * math.sin(self.time * 3.4) -- 326
		local py = cy - 114 -- 327
		fillRadialGlow( -- 328
			uiGlow, -- 328
			w * 0.5, -- 328
			py, -- 328
			120, -- 328
			22, -- 328
			toColor(PALETTE.amber, 30 * pulse), -- 328
			Color(214, 186, 146, 0), -- 328
			14 -- 328
		) -- 328
		drawSilkRibbon( -- 329
			uiDraw, -- 329
			art, -- 329
			"gate_go_rib", -- 329
			w * 0.5, -- 329
			py, -- 329
			300, -- 329
			38, -- 329
			PALETTE.rougeSoft, -- 329
			0.46 * pulse, -- 329
			1 -- 329
		) -- 329
		drawHairline( -- 330
			uiInkDraw, -- 330
			art, -- 330
			"gate_go_line", -- 330
			w * 0.5, -- 330
			py - 16, -- 330
			210, -- 330
			PALETTE.silkLine, -- 330
			0.48 * pulse, -- 330
			false, -- 330
			2 -- 330
		) -- 330
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 独自向北" -- 331
		texts:put( -- 332
			"sm", -- 332
			prompt, -- 332
			w * 0.5, -- 332
			py, -- 332
			toColor(PALETTE.textBright), -- 332
			0.5, -- 332
			0.5, -- 332
			"Center", -- 332
			2.2, -- 332
			1, -- 332
			0.08 -- 332
		) -- 332
	end -- 332
end -- 300
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 341
	local cardW = 588 -- 351
	local cardH = 382 -- 352
	local cx = (w - cardW) * 0.5 -- 353
	local cy = (h - cardH) * 0.5 + 10 -- 354
	local midX = w * 0.5 -- 355
	local midY = cy + cardH * 0.5 -- 356
	uiDraw:drawRect( -- 359
		Rect(0, 0, w, h), -- 359
		Color(7, 9, 15, 174) -- 359
	) -- 359
	art:tryPlace( -- 360
		"ink_frame_mask", -- 360
		"reg_shadow", -- 360
		midX, -- 360
		midY - 6, -- 360
		cardW + 58, -- 360
		cardH + 50, -- 360
		{ -- 360
			color = toColor(PALETTE.voidDark), -- 361
			opacity = 0.82, -- 361
			layer = -1 -- 361
		} -- 361
	) -- 361
	if not art:tryPlace( -- 361
		"ink_song_paper", -- 365
		"registry_song_paper", -- 365
		midX, -- 365
		midY, -- 365
		cardW, -- 365
		cardH, -- 365
		{opacity = 0.98, layer = 1} -- 365
	) then -- 365
		uiDraw:drawRect( -- 366
			Rect(cx, cy, cardW, cardH), -- 366
			toColor(PALETTE.xuanPaper, 246), -- 366
			1, -- 366
			toColor(PALETTE.silkDim, 180) -- 366
		) -- 366
	end -- 366
	fillRadialGlow( -- 368
		uiGlow, -- 368
		midX, -- 368
		midY + 46, -- 368
		240, -- 368
		130, -- 368
		Color(235, 224, 202, 14), -- 368
		Color(235, 224, 202, 0), -- 368
		14 -- 368
	) -- 368
	local padX = 46 -- 371
	local padY = 36 -- 372
	local inX = cx + padX -- 373
	local inY = cy + padY -- 374
	local inW = cardW - padX * 2 -- 375
	local inH = cardH - padY * 2 -- 376
	local redSilk = toColor(PALETTE.rouge, 118) -- 377
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 378
	uiInkDraw:drawRect( -- 380
		Rect(inX, inY, inW, inH), -- 380
		Color(0, 0, 0, 0), -- 380
		0.9, -- 380
		redSilk -- 380
	) -- 380
	uiInkDraw:drawRect( -- 381
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 381
		Color(0, 0, 0, 0), -- 381
		0.55, -- 381
		redSilkFaint -- 381
	) -- 381
	local headY = inY + inH - 28 -- 384
	texts:put( -- 385
		"md", -- 385
		"北塔入塔登记簿 · 末页", -- 385
		inX + 20, -- 385
		headY, -- 385
		toColor(PALETTE.xuanInk), -- 385
		0, -- 385
		0.5, -- 385
		"Left", -- 385
		2.4, -- 385
		0.94, -- 385
		0 -- 385
	) -- 385
	texts:put( -- 386
		"xs", -- 386
		"守望行记", -- 386
		inX + inW - 20, -- 386
		headY, -- 386
		toColor(PALETTE.xuanInkSub), -- 386
		1, -- 386
		0.5, -- 386
		"Right", -- 386
		2, -- 386
		0.78, -- 386
		0 -- 386
	) -- 386
	uiInkDraw:drawSegment( -- 387
		Vec2(inX + 14, headY - 22), -- 387
		Vec2(inX + inW - 14, headY - 22), -- 387
		0.85, -- 387
		redSilk -- 387
	) -- 387
	local row1Y = headY - 56 -- 390
	texts:put( -- 391
		"sm", -- 391
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 391
		inX + 20, -- 391
		row1Y, -- 391
		toColor(PALETTE.xuanInk), -- 391
		0, -- 391
		0.5, -- 391
		"Left", -- 391
		0.8, -- 391
		0.94, -- 391
		0 -- 391
	) -- 391
	texts:put( -- 392
		"xs", -- 392
		"附注：护送者留守南城门，托她独自走完余路。", -- 392
		inX + 20, -- 392
		row1Y - 28, -- 392
		toColor(PALETTE.xuanInkSub), -- 392
		0, -- 392
		0.5, -- 392
		"Left", -- 392
		0.6, -- 392
		0.88, -- 392
		0 -- 392
	) -- 392
	uiInkDraw:drawSegment( -- 393
		Vec2(inX + 16, row1Y - 48), -- 393
		Vec2(inX + inW - 16, row1Y - 48), -- 393
		0.65, -- 393
		redSilkFaint -- 393
	) -- 393
	local blankY = row1Y - 80 -- 396
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 397
	texts:put( -- 398
		"sm", -- 398
		"肆拾贰", -- 398
		inX + 20, -- 398
		blankY, -- 398
		toColor(PALETTE.rouge), -- 398
		0, -- 398
		0.5, -- 398
		"Left", -- 398
		1, -- 398
		0.92, -- 398
		0 -- 398
	) -- 398
	uiInkDraw:drawSegment( -- 399
		Vec2(inX + 94, blankY - 7), -- 399
		Vec2(inX + inW - 116, blankY - 7), -- 399
		0.95, -- 399
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 399
	) -- 399
	texts:put( -- 400
		"xs", -- 400
		"（空行留待）", -- 400
		inX + inW - 104, -- 400
		blankY, -- 400
		toColor(PALETTE.xuanInkSub), -- 400
		0, -- 400
		0.5, -- 400
		"Left", -- 400
		1, -- 400
		0.82 * pulse, -- 400
		0 -- 400
	) -- 400
	if p.phase == "tower-end" then -- 400
		local signY = inY + 46 -- 404
		texts:put( -- 405
			"banner", -- 405
			"向西守望", -- 405
			midX - 18, -- 405
			signY, -- 405
			toColor(PALETTE.xuanInk), -- 405
			0.5, -- 405
			0.5, -- 405
			"Center", -- 405
			6.5, -- 405
			0.92, -- 405
			0 -- 405
		) -- 405
		drawLoneSeal( -- 406
			uiInkDraw, -- 406
			art, -- 406
			texts, -- 406
			"reg_lone_seal", -- 406
			midX + 86, -- 406
			signY, -- 406
			22, -- 406
			42, -- 406
			"守", -- 406
			"望", -- 406
			PALETTE.sealRed, -- 406
			PALETTE.sealText, -- 406
			0.92, -- 406
			4 -- 406
		) -- 406
		drawSilkVeil( -- 408
			uiDraw, -- 408
			art, -- 408
			"reg_hint_veil", -- 408
			midX, -- 408
			cy - 28, -- 408
			360, -- 408
			32, -- 408
			PALETTE.inkWash, -- 408
			0.72, -- 408
			0 -- 408
		) -- 408
		texts:put( -- 409
			"xs", -- 409
			"按 E 再次启程     ·     Esc 暂歇", -- 409
			midX, -- 409
			cy - 28, -- 409
			toColor(PALETTE.textMid), -- 409
			0.5, -- 409
			0.5, -- 409
			"Center", -- 409
			1.6, -- 409
			0.92, -- 409
			0.08 -- 409
		) -- 409
	end -- 409
end -- 341
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 413
	local theme = themeOf(roomKey) -- 422
	local t = self.bannerT / self.bannerMax -- 423
	local alpha = 1 -- 424
	if t > 0.82 then -- 424
		alpha = (1 - t) / 0.18 -- 426
	elseif t < 0.28 then -- 426
		alpha = t / 0.28 -- 428
	end -- 428
	local cx = w * 0.5 -- 430
	local cy = h * 0.77 -- 431
	local spread = math.min(1, alpha * 1.15) -- 432
	drawSilkVeil( -- 435
		uiDraw, -- 435
		art, -- 435
		"banner_veil", -- 435
		cx, -- 435
		cy - 2, -- 435
		480 * spread + 100, -- 435
		92, -- 435
		PALETTE.inkWash, -- 435
		0.76 * alpha, -- 435
		-1 -- 435
	) -- 435
	drawMistCurve( -- 436
		art, -- 436
		"banner_mist", -- 436
		cx, -- 436
		cy + 4, -- 436
		460 * spread, -- 436
		72, -- 436
		theme.accent, -- 436
		0.28 * alpha, -- 436
		0 -- 436
	) -- 436
	drawHairline( -- 437
		uiInkDraw, -- 437
		art, -- 437
		"banner_line", -- 437
		cx, -- 437
		cy - 16, -- 437
		320 * spread, -- 437
		PALETTE.silkLine, -- 437
		0.64 * alpha, -- 437
		false, -- 437
		2 -- 437
	) -- 437
	local sep = " · " -- 440
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 441
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 442
	if idx > 0 then -- 442
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 444
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 445
		local lw = visualTextWidth(leftPart, 42) -- 446
		local rw = visualTextWidth(rightPart, 42) -- 447
		local dotGap = 28 -- 448
		local totalW = lw + rw + dotGap -- 449
		local leftEdge = cx - totalW * 0.5 -- 450
		local dotX = leftEdge + lw + dotGap * 0.5 -- 451
		texts:put( -- 453
			"banner", -- 453
			leftPart, -- 453
			leftEdge, -- 453
			cy + 14, -- 453
			toColor(PALETTE.textBright), -- 453
			0, -- 453
			0.5, -- 453
			"Left", -- 453
			2, -- 453
			alpha, -- 453
			0.1 -- 453
		) -- 453
		drawBlossomDot( -- 454
			uiInkDraw, -- 454
			art, -- 454
			"banner_mid_dot", -- 454
			dotX, -- 454
			cy + 12, -- 454
			11, -- 454
			dotCol, -- 454
			0.92 * alpha, -- 454
			4 -- 454
		) -- 454
		texts:put( -- 455
			"banner", -- 455
			rightPart, -- 455
			dotX + dotGap * 0.5, -- 455
			cy + 14, -- 455
			toColor(PALETTE.textBright), -- 455
			0, -- 455
			0.5, -- 455
			"Left", -- 455
			2, -- 455
			alpha, -- 455
			0.1 -- 455
		) -- 455
	else -- 455
		texts:put( -- 457
			"banner", -- 457
			theme.titleZh, -- 457
			cx, -- 457
			cy + 14, -- 457
			toColor(PALETTE.textBright), -- 457
			0.5, -- 457
			0.5, -- 457
			"Center", -- 457
			3, -- 457
			alpha, -- 457
			0.1 -- 457
		) -- 457
	end -- 457
	texts:put( -- 459
		"xs", -- 459
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 459
		cx, -- 459
		cy - 34, -- 459
		toColor(PALETTE.textMid), -- 459
		0.5, -- 459
		0.5, -- 459
		"Center", -- 459
		2.2, -- 459
		0.82 * alpha, -- 459
		0.08 -- 459
	) -- 459
end -- 413
return ____exports -- 413