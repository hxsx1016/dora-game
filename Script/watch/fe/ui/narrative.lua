-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____play = require("Script.watch.play") -- 10
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 10
local gateCountAtTick = ____play.gateCountAtTick -- 10
local ____theme = require("Script.watch.fe.theme") -- 13
local PALETTE = ____theme.PALETTE -- 14
local drawBlossomDot = ____theme.drawBlossomDot -- 15
local drawHairline = ____theme.drawHairline -- 16
local drawLoneSeal = ____theme.drawLoneSeal -- 17
local drawMistCurve = ____theme.drawMistCurve -- 18
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
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.room.key == "tower" and p.phase ~= "tower-wait" -- 50
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
		local hasAliveEnemy = false -- 162
		local i = 0 -- 163
		do -- 163
			i = 0 -- 164
			while i < #p.enemies do -- 164
				if p.enemies[i + 1].alive then -- 164
					hasAliveEnemy = true -- 166
					if p.enemies[i + 1].warnT > 0 then -- 166
						threatened = true -- 168
					end -- 168
				end -- 168
				i = i + 1 -- 164
			end -- 164
		end -- 164
		if threatened then -- 164
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 173
		end -- 173
		if p.coverHug then -- 173
			if hasAliveEnemy and not p.coverBlocking then -- 173
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 177
			end -- 177
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 179
		end -- 179
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 181
	end -- 181
	if key == "gate" and p.phase == "gate-count" then -- 181
		if p.countTick >= GATE_COUNT_END then -- 181
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 186
		end -- 186
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 192
	end -- 192
	if p.flash ~= "" and p.flashT > 0 then -- 192
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 196
		local text = p.flash -- 197
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 198
		if key == "tower" or key == "prologue" then -- 198
			cue = "" -- 200
		end -- 200
		if text == "命中" then -- 200
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 203
		elseif text == "打空" then -- 203
			text = "铅丸偏离或被掩体阻挡" -- 205
		elseif text == "翻滚" then -- 205
			text = "伏身翻滚回避" -- 207
		end -- 207
		return {cue = cue, text = text, urgent = isDanger} -- 209
	end -- 209
	if key == "prologue" then -- 209
		if p.phase == "prologue-wait" then -- 209
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 214
		end -- 214
		if p.phase == "prologue-give" then -- 214
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 217
		end -- 217
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 219
	end -- 219
	if key == "street" then -- 219
		local alive = 0 -- 223
		local i = 0 -- 224
		do -- 224
			i = 0 -- 225
			while i < #p.enemies do -- 225
				if p.enemies[i + 1].alive then -- 225
					alive = alive + 1 -- 226
				end -- 226
				i = i + 1 -- 225
			end -- 225
		end -- 225
		if alive > 0 then -- 225
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 229
		end -- 229
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 231
	end -- 231
	if key == "checkpoint" then -- 231
		if p.escort.state == "frozen" then -- 231
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 236
		end -- 236
		if p.escort.state == "calming" then -- 236
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 239
		end -- 239
		if not p.cartDocked then -- 239
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 242
		end -- 242
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 244
	end -- 244
	if key == "gate" then -- 244
		if p.phase == "gate-idle" then -- 244
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 249
		end -- 249
		if p.phase == "gate-send" then -- 249
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 256
		end -- 256
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 258
	end -- 258
	if key == "outside" then -- 258
		if not p.cartDocked then -- 258
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 263
		end -- 263
		if p.checkpoint < p.room.arch.x1 then -- 263
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 266
		end -- 266
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 268
	end -- 268
	if key == "village" then -- 268
		if p.scavChase then -- 268
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 273
		end -- 273
		if p.passed then -- 273
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 276
		end -- 276
		if p.hasBottle then -- 276
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 279
		end -- 279
		if p.bottleFly ~= nil then -- 279
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 282
		end -- 282
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 282
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 285
		end -- 285
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 287
	end -- 287
	if key == "forest" then -- 287
		if p.dogState == "chase" then -- 287
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 292
		end -- 292
		if p.dogState == "ear" then -- 292
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 295
		end -- 295
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 297
	end -- 297
	if key == "tower" then -- 297
		if p.phase == "tower-wait" then -- 297
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 302
		end -- 302
		if p.phase == "tower-knock" then -- 302
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 305
		end -- 305
		if p.phase == "tower-given" then -- 305
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 308
		end -- 308
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 310
	end -- 310
	return {cue = "", text = theme.introWhisper, urgent = false} -- 313
end -- 156
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 316
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 325
	local countNum = gateCountAtTick(p.countTick) -- 326
	uiDraw:drawRect( -- 327
		Rect(0, 0, w, h), -- 327
		Color( -- 327
			7, -- 327
			9, -- 327
			15, -- 327
			math.floor(78 + frac * 116 + 0.5) -- 327
		) -- 327
	) -- 327
	local cy = h * 0.56 -- 329
	art:tryPlace( -- 330
		"ink_petal_mist", -- 330
		"gate_count_mist", -- 330
		w * 0.5, -- 330
		cy, -- 330
		290, -- 330
		220, -- 330
		{ -- 330
			color = toColor(PALETTE.inkMist), -- 331
			opacity = 0.34 + frac * 0.2, -- 331
			layer = 0 -- 331
		} -- 331
	) -- 331
	drawMistCurve( -- 333
		art, -- 333
		"gate_count_wisp", -- 333
		w * 0.5, -- 333
		cy - 8, -- 333
		420, -- 333
		76, -- 333
		PALETTE.jadeMist, -- 333
		0.22, -- 333
		0 -- 333
	) -- 333
	local numZh = toChineseUpper(countNum) -- 335
	texts:put( -- 336
		"title", -- 336
		numZh, -- 336
		w * 0.5, -- 336
		cy + 8, -- 336
		toColor(PALETTE.textBright), -- 336
		0.5, -- 336
		0.5, -- 336
		"Center", -- 336
		12, -- 336
		0.42 + frac * 0.56, -- 336
		0.1 -- 336
	) -- 336
	drawHairline( -- 337
		uiInkDraw, -- 337
		art, -- 337
		"gate_count_div", -- 337
		w * 0.5, -- 337
		cy - 34, -- 337
		240, -- 337
		PALETTE.silkDim, -- 337
		0.62, -- 337
		true, -- 337
		2 -- 337
	) -- 337
	texts:put( -- 338
		"sm", -- 338
		"城外静候 · 默数至二十", -- 338
		w * 0.5, -- 338
		cy - 58, -- 338
		toColor(PALETTE.textMid), -- 338
		0.5, -- 338
		0.5, -- 338
		"Center", -- 338
		3.4, -- 338
		0.84, -- 338
		0.08 -- 338
	) -- 338
end -- 316
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 348
	local cardW = 588 -- 358
	local cardH = 382 -- 359
	local cx = (w - cardW) * 0.5 -- 360
	local cy = (h - cardH) * 0.5 + 10 -- 361
	local midX = w * 0.5 -- 362
	local midY = cy + cardH * 0.5 -- 363
	uiDraw:drawRect( -- 366
		Rect(0, 0, w, h), -- 366
		Color(7, 9, 15, 174) -- 366
	) -- 366
	art:tryPlace( -- 367
		"ink_frame_mask", -- 367
		"reg_shadow", -- 367
		midX, -- 367
		midY - 6, -- 367
		cardW + 58, -- 367
		cardH + 50, -- 367
		{ -- 367
			color = toColor(PALETTE.voidDark), -- 368
			opacity = 0.82, -- 368
			layer = -1 -- 368
		} -- 368
	) -- 368
	if not art:tryPlace( -- 368
		"ink_song_paper", -- 372
		"registry_song_paper", -- 372
		midX, -- 372
		midY, -- 372
		cardW, -- 372
		cardH, -- 372
		{opacity = 0.98, layer = 1} -- 372
	) then -- 372
		uiDraw:drawRect( -- 373
			Rect(cx, cy, cardW, cardH), -- 373
			toColor(PALETTE.xuanPaper, 246), -- 373
			1, -- 373
			toColor(PALETTE.silkDim, 180) -- 373
		) -- 373
	end -- 373
	fillRadialGlow( -- 375
		uiGlow, -- 375
		midX, -- 375
		midY + 46, -- 375
		240, -- 375
		130, -- 375
		Color(235, 224, 202, 14), -- 375
		Color(235, 224, 202, 0), -- 375
		14 -- 375
	) -- 375
	local padX = 46 -- 378
	local padY = 36 -- 379
	local inX = cx + padX -- 380
	local inY = cy + padY -- 381
	local inW = cardW - padX * 2 -- 382
	local inH = cardH - padY * 2 -- 383
	local redSilk = toColor(PALETTE.rouge, 118) -- 384
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 385
	uiInkDraw:drawRect( -- 387
		Rect(inX, inY, inW, inH), -- 387
		Color(0, 0, 0, 0), -- 387
		0.9, -- 387
		redSilk -- 387
	) -- 387
	uiInkDraw:drawRect( -- 388
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 388
		Color(0, 0, 0, 0), -- 388
		0.55, -- 388
		redSilkFaint -- 388
	) -- 388
	local headY = inY + inH - 28 -- 391
	texts:put( -- 392
		"md", -- 392
		"北塔入塔登记簿 · 末页", -- 392
		inX + 20, -- 392
		headY, -- 392
		toColor(PALETTE.xuanInk), -- 392
		0, -- 392
		0.5, -- 392
		"Left", -- 392
		2.4, -- 392
		0.94, -- 392
		0 -- 392
	) -- 392
	texts:put( -- 393
		"xs", -- 393
		"守望行记", -- 393
		inX + inW - 20, -- 393
		headY, -- 393
		toColor(PALETTE.xuanInkSub), -- 393
		1, -- 393
		0.5, -- 393
		"Right", -- 393
		2, -- 393
		0.78, -- 393
		0 -- 393
	) -- 393
	uiInkDraw:drawSegment( -- 394
		Vec2(inX + 14, headY - 22), -- 394
		Vec2(inX + inW - 14, headY - 22), -- 394
		0.85, -- 394
		redSilk -- 394
	) -- 394
	local row1Y = headY - 56 -- 397
	texts:put( -- 398
		"sm", -- 398
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 398
		inX + 20, -- 398
		row1Y, -- 398
		toColor(PALETTE.xuanInk), -- 398
		0, -- 398
		0.5, -- 398
		"Left", -- 398
		0.8, -- 398
		0.94, -- 398
		0 -- 398
	) -- 398
	texts:put( -- 399
		"xs", -- 399
		"附注：护送者留守南城门，托她独自走完余路。", -- 399
		inX + 20, -- 399
		row1Y - 28, -- 399
		toColor(PALETTE.xuanInkSub), -- 399
		0, -- 399
		0.5, -- 399
		"Left", -- 399
		0.6, -- 399
		0.88, -- 399
		0 -- 399
	) -- 399
	uiInkDraw:drawSegment( -- 400
		Vec2(inX + 16, row1Y - 48), -- 400
		Vec2(inX + inW - 16, row1Y - 48), -- 400
		0.65, -- 400
		redSilkFaint -- 400
	) -- 400
	local blankY = row1Y - 80 -- 403
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 404
	texts:put( -- 405
		"sm", -- 405
		"肆拾贰", -- 405
		inX + 20, -- 405
		blankY, -- 405
		toColor(PALETTE.rouge), -- 405
		0, -- 405
		0.5, -- 405
		"Left", -- 405
		1, -- 405
		0.92, -- 405
		0 -- 405
	) -- 405
	uiInkDraw:drawSegment( -- 406
		Vec2(inX + 94, blankY - 7), -- 406
		Vec2(inX + inW - 116, blankY - 7), -- 406
		0.95, -- 406
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 406
	) -- 406
	texts:put( -- 407
		"xs", -- 407
		"（空行留待）", -- 407
		inX + inW - 104, -- 407
		blankY, -- 407
		toColor(PALETTE.xuanInkSub), -- 407
		0, -- 407
		0.5, -- 407
		"Left", -- 407
		1, -- 407
		0.82 * pulse, -- 407
		0 -- 407
	) -- 407
	if p.phase == "tower-end" then -- 407
		local signY = inY + 46 -- 411
		texts:put( -- 412
			"banner", -- 412
			"向西守望", -- 412
			midX - 18, -- 412
			signY, -- 412
			toColor(PALETTE.xuanInk), -- 412
			0.5, -- 412
			0.5, -- 412
			"Center", -- 412
			6.5, -- 412
			0.92, -- 412
			0 -- 412
		) -- 412
		drawLoneSeal( -- 413
			uiInkDraw, -- 413
			art, -- 413
			texts, -- 413
			"reg_lone_seal", -- 413
			midX + 86, -- 413
			signY, -- 413
			22, -- 413
			42, -- 413
			"守", -- 413
			"望", -- 413
			PALETTE.sealRed, -- 413
			PALETTE.sealText, -- 413
			0.92, -- 413
			4 -- 413
		) -- 413
		drawSilkVeil( -- 415
			uiDraw, -- 415
			art, -- 415
			"reg_hint_veil", -- 415
			midX, -- 415
			cy - 28, -- 415
			360, -- 415
			32, -- 415
			PALETTE.inkWash, -- 415
			0.72, -- 415
			0 -- 415
		) -- 415
		texts:put( -- 416
			"xs", -- 416
			"按 E 再次启程     ·     Esc 暂歇", -- 416
			midX, -- 416
			cy - 28, -- 416
			toColor(PALETTE.textMid), -- 416
			0.5, -- 416
			0.5, -- 416
			"Center", -- 416
			1.6, -- 416
			0.92, -- 416
			0.08 -- 416
		) -- 416
	end -- 416
end -- 348
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 420
	local theme = themeOf(roomKey) -- 429
	local t = self.bannerT / self.bannerMax -- 430
	local alpha = 1 -- 431
	if t > 0.82 then -- 431
		alpha = (1 - t) / 0.18 -- 433
	elseif t < 0.28 then -- 433
		alpha = t / 0.28 -- 435
	end -- 435
	local cx = w * 0.5 -- 437
	local cy = h * 0.77 -- 438
	local spread = math.min(1, alpha * 1.15) -- 439
	drawSilkVeil( -- 442
		uiDraw, -- 442
		art, -- 442
		"banner_veil", -- 442
		cx, -- 442
		cy - 2, -- 442
		480 * spread + 100, -- 442
		92, -- 442
		PALETTE.inkWash, -- 442
		0.76 * alpha, -- 442
		-1 -- 442
	) -- 442
	drawMistCurve( -- 443
		art, -- 443
		"banner_mist", -- 443
		cx, -- 443
		cy + 4, -- 443
		460 * spread, -- 443
		72, -- 443
		theme.accent, -- 443
		0.28 * alpha, -- 443
		0 -- 443
	) -- 443
	drawHairline( -- 444
		uiInkDraw, -- 444
		art, -- 444
		"banner_line", -- 444
		cx, -- 444
		cy - 16, -- 444
		320 * spread, -- 444
		PALETTE.silkLine, -- 444
		0.64 * alpha, -- 444
		false, -- 444
		2 -- 444
	) -- 444
	local sep = " · " -- 447
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 448
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 449
	if idx > 0 then -- 449
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 451
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 452
		local lw = visualTextWidth(leftPart, 42) -- 453
		local rw = visualTextWidth(rightPart, 42) -- 454
		local dotGap = 28 -- 455
		local totalW = lw + rw + dotGap -- 456
		local leftEdge = cx - totalW * 0.5 -- 457
		local dotX = leftEdge + lw + dotGap * 0.5 -- 458
		texts:put( -- 460
			"banner", -- 460
			leftPart, -- 460
			leftEdge, -- 460
			cy + 14, -- 460
			toColor(PALETTE.textBright), -- 460
			0, -- 460
			0.5, -- 460
			"Left", -- 460
			2, -- 460
			alpha, -- 460
			0.1 -- 460
		) -- 460
		drawBlossomDot( -- 461
			uiInkDraw, -- 461
			art, -- 461
			"banner_mid_dot", -- 461
			dotX, -- 461
			cy + 12, -- 461
			11, -- 461
			dotCol, -- 461
			0.92 * alpha, -- 461
			4 -- 461
		) -- 461
		texts:put( -- 462
			"banner", -- 462
			rightPart, -- 462
			dotX + dotGap * 0.5, -- 462
			cy + 14, -- 462
			toColor(PALETTE.textBright), -- 462
			0, -- 462
			0.5, -- 462
			"Left", -- 462
			2, -- 462
			alpha, -- 462
			0.1 -- 462
		) -- 462
	else -- 462
		texts:put( -- 464
			"banner", -- 464
			theme.titleZh, -- 464
			cx, -- 464
			cy + 14, -- 464
			toColor(PALETTE.textBright), -- 464
			0.5, -- 464
			0.5, -- 464
			"Center", -- 464
			3, -- 464
			alpha, -- 464
			0.1 -- 464
		) -- 464
	end -- 464
	texts:put( -- 466
		"xs", -- 466
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 466
		cx, -- 466
		cy - 34, -- 466
		toColor(PALETTE.textMid), -- 466
		0.5, -- 466
		0.5, -- 466
		"Center", -- 466
		2.2, -- 466
		0.82 * alpha, -- 466
		0.08 -- 466
	) -- 466
end -- 420
return ____exports -- 420