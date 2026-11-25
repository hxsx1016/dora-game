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
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or p.room.key == "tower" and p.phase ~= "tower-wait" -- 50
	local target = wantCinema and 1 or 0 -- 55
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 56
	if self.bannerT > 0 then -- 56
		self.bannerT = math.max(0, self.bannerT - dt) -- 59
	end -- 59
	if self.wipeT > 0 then -- 59
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 62
	end -- 62
end -- 45
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 66
	if self.letterbox > 0.01 then -- 66
		local barH = math.floor(70 * self.letterbox + 0.5) -- 78
		uiDraw:drawRect( -- 79
			Rect(0, h - barH, w, barH), -- 79
			Color(8, 10, 16, 242) -- 79
		) -- 79
		uiDraw:drawRect( -- 80
			Rect(0, 0, w, barH), -- 80
			Color(8, 10, 16, 242) -- 80
		) -- 80
		uiInkDraw:drawSegment( -- 81
			Vec2(0, h - barH), -- 81
			Vec2(w, h - barH), -- 81
			0.7, -- 81
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 81
		) -- 81
		uiInkDraw:drawSegment( -- 82
			Vec2(0, barH), -- 82
			Vec2(w, barH), -- 82
			0.7, -- 82
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 82
		) -- 82
	end -- 82
	if p.room.key == "gate" and p.phase == "gate-count" then -- 82
		self:drawGateCountOverlay( -- 87
			uiDraw, -- 87
			uiInkDraw, -- 87
			art, -- 87
			texts, -- 87
			p, -- 87
			w, -- 87
			h -- 87
		) -- 87
	end -- 87
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 91
	if showRegistry then -- 91
		self:drawTowerRegistryCard( -- 93
			uiDraw, -- 93
			uiInkDraw, -- 93
			uiGlow, -- 93
			art, -- 93
			texts, -- 93
			p, -- 93
			w, -- 93
			h -- 93
		) -- 93
	end -- 93
	if not p.paused and not showRegistry then -- 93
		self:drawSubtitleStrip( -- 98
			uiDraw, -- 98
			uiInkDraw, -- 98
			art, -- 98
			texts, -- 98
			p, -- 98
			w, -- 98
			h -- 98
		) -- 98
	end -- 98
	if self.bannerT > 0 and not p.paused then -- 98
		self:drawAreaBanner( -- 103
			uiDraw, -- 103
			uiInkDraw, -- 103
			art, -- 103
			texts, -- 103
			p.room.key, -- 103
			w, -- 103
			h -- 103
		) -- 103
	end -- 103
	if self.wipeT > 0.01 then -- 103
		local k = math.min(1, self.wipeT * 1.15) -- 108
		local a = math.floor(255 * k * k + 0.5) -- 109
		uiDraw:drawRect( -- 110
			Rect(0, 0, w, h), -- 110
			Color(9, 11, 17, a) -- 110
		) -- 110
		art:tryPlace( -- 111
			"ink_petal_mist", -- 111
			"wipe_mist", -- 111
			w * 0.5, -- 111
			h * 0.5, -- 111
			w * 0.65, -- 111
			h * 0.65, -- 111
			{ -- 111
				color = toColor(PALETTE.inkMist), -- 112
				opacity = 0.2 * self.wipeT, -- 112
				layer = 5 -- 112
			} -- 112
		) -- 112
	end -- 112
end -- 66
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 117
	local line = self:composeNarrativeLine(p) -- 126
	if line.text == "" then -- 126
		return -- 128
	end -- 128
	local hasCue = line.cue ~= "" -- 130
	local textW = visualTextWidth(line.text, 18) -- 131
	local contentW = textW + (hasCue and 48 or 0) -- 132
	local stripW = math.min( -- 133
		w - 72, -- 133
		math.max(540, contentW + 210) -- 133
	) -- 133
	local stripH = 54 -- 134
	local cx = w * 0.5 -- 135
	local cy = self.letterbox > 0.4 and 36 or 42 -- 136
	drawSilkVeil( -- 139
		uiDraw, -- 139
		art, -- 139
		"sub_veil", -- 139
		cx, -- 139
		cy, -- 139
		stripW, -- 139
		stripH, -- 139
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 139
		0.84, -- 139
		-1 -- 139
	) -- 139
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 141
	drawHairline( -- 142
		uiInkDraw, -- 142
		art, -- 142
		"sub_top_line", -- 142
		cx, -- 142
		cy + 23, -- 142
		stripW * 0.72, -- 142
		railCol, -- 142
		line.urgent and 0.72 or 0.52, -- 142
		true, -- 142
		2 -- 142
	) -- 142
	if hasCue then -- 142
		local startX = cx - contentW * 0.5 -- 145
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 146
		drawBlossomDot( -- 147
			uiInkDraw, -- 147
			art, -- 147
			"sub_cue_dot", -- 147
			startX + 6, -- 147
			cy - 1, -- 147
			10, -- 147
			cueCol, -- 147
			0.94, -- 147
			4 -- 147
		) -- 147
		texts:put( -- 148
			"xs", -- 148
			line.cue, -- 148
			startX + 24, -- 148
			cy - 1, -- 148
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 148
			0.5, -- 148
			0.5, -- 148
			"Center", -- 148
			0, -- 148
			0.96, -- 148
			0.08 -- 148
		) -- 148
		uiInkDraw:drawSegment( -- 149
			Vec2(startX + 38, cy - 8), -- 149
			Vec2(startX + 38, cy + 6), -- 149
			0.75, -- 149
			toColor(PALETTE.silkDim, 115) -- 149
		) -- 149
		texts:put( -- 150
			"sm", -- 150
			line.text, -- 150
			startX + 48, -- 150
			cy - 1, -- 150
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 150
			0, -- 150
			0.5, -- 150
			"Left", -- 150
			0.9, -- 150
			0.98, -- 150
			0.08 -- 150
		) -- 150
	else -- 150
		texts:put( -- 152
			"sm", -- 152
			line.text, -- 152
			cx, -- 152
			cy - 1, -- 152
			toColor(PALETTE.textBright), -- 152
			0.5, -- 152
			0.5, -- 152
			"Center", -- 152
			1, -- 152
			0.98, -- 152
			0.08 -- 152
		) -- 152
	end -- 152
end -- 117
function NarrativeRenderer.prototype.composeNarrativeLine(self, p) -- 157
	local key = p.room.key -- 158
	local theme = themeOf(key) -- 159
	if key == "gate" and p.phase == "gate-hold" then -- 159
		local threatened = false -- 162
		local hasAliveEnemy = false -- 163
		local i = 0 -- 164
		do -- 164
			i = 0 -- 165
			while i < #p.enemies do -- 165
				if p.enemies[i + 1].alive then -- 165
					hasAliveEnemy = true -- 167
					if p.enemies[i + 1].warnT > 0 then -- 167
						threatened = true -- 169
					end -- 169
				end -- 169
				i = i + 1 -- 165
			end -- 165
		end -- 165
		if threatened then -- 165
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 174
		end -- 174
		if p.coverHug then -- 174
			if hasAliveEnemy and not p.coverBlocking then -- 174
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 178
			end -- 178
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 180
		end -- 180
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 182
	end -- 182
	if key == "gate" and p.phase == "gate-count" then -- 182
		if p.countTick >= GATE_COUNT_END then -- 182
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 187
		end -- 187
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 193
	end -- 193
	if p.flash ~= "" and p.flashT > 0 then -- 193
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 197
		local text = p.flash -- 198
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 199
		if key == "tower" or key == "prologue" then -- 199
			cue = "" -- 201
		end -- 201
		if text == "命中" then -- 201
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 204
		elseif text == "打空" then -- 204
			text = "铅丸偏离或被掩体阻挡" -- 206
		elseif text == "翻滚" then -- 206
			text = "伏身翻滚回避" -- 208
		end -- 208
		return {cue = cue, text = text, urgent = isDanger} -- 210
	end -- 210
	if key == "prologue" then -- 210
		if p.phase == "prologue-wait" then -- 210
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 215
		end -- 215
		if p.phase == "prologue-give" then -- 215
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 218
		end -- 218
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 220
	end -- 220
	if key == "street" then -- 220
		local alive = 0 -- 224
		local i = 0 -- 225
		do -- 225
			i = 0 -- 226
			while i < #p.enemies do -- 226
				if p.enemies[i + 1].alive then -- 226
					alive = alive + 1 -- 227
				end -- 227
				i = i + 1 -- 226
			end -- 226
		end -- 226
		if alive > 0 then -- 226
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 230
		end -- 230
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 232
	end -- 232
	if key == "checkpoint" then -- 232
		if p.escort.state == "frozen" then -- 232
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 237
		end -- 237
		if p.escort.state == "calming" then -- 237
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 240
		end -- 240
		if not p.cartDocked then -- 240
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 243
		end -- 243
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 245
	end -- 245
	if key == "gate" then -- 245
		if p.phase == "gate-idle" then -- 245
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 250
		end -- 250
		if p.phase == "gate-send" then -- 250
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 257
		end -- 257
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 259
	end -- 259
	if key == "outside" then -- 259
		if not p.cartDocked then -- 259
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 264
		end -- 264
		if p.checkpoint < p.room.arch.x1 then -- 264
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 267
		end -- 267
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 269
	end -- 269
	if key == "village" then -- 269
		if p.scavChase then -- 269
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 274
		end -- 274
		if p.passed then -- 274
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 277
		end -- 277
		if p.hasBottle then -- 277
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 280
		end -- 280
		if p.bottleFly ~= nil then -- 280
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 283
		end -- 283
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 283
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 286
		end -- 286
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 288
	end -- 288
	if key == "forest" then -- 288
		if p.dogState == "chase" then -- 288
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 293
		end -- 293
		if p.dogState == "ear" then -- 293
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 296
		end -- 296
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 298
	end -- 298
	if key == "tower" then -- 298
		if p.phase == "tower-wait" then -- 298
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 303
		end -- 303
		if p.phase == "tower-knock" then -- 303
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 306
		end -- 306
		if p.phase == "tower-given" then -- 306
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 309
		end -- 309
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 311
	end -- 311
	return {cue = "", text = theme.introWhisper, urgent = false} -- 314
end -- 157
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 317
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 326
	local countNum = gateCountAtTick(p.countTick) -- 327
	uiDraw:drawRect( -- 328
		Rect(0, 0, w, h), -- 328
		Color( -- 328
			7, -- 328
			9, -- 328
			15, -- 328
			math.floor(78 + frac * 116 + 0.5) -- 328
		) -- 328
	) -- 328
	local cy = h * 0.56 -- 330
	art:tryPlace( -- 331
		"ink_petal_mist", -- 331
		"gate_count_mist", -- 331
		w * 0.5, -- 331
		cy, -- 331
		290, -- 331
		220, -- 331
		{ -- 331
			color = toColor(PALETTE.inkMist), -- 332
			opacity = 0.34 + frac * 0.2, -- 332
			layer = 0 -- 332
		} -- 332
	) -- 332
	drawMistCurve( -- 334
		art, -- 334
		"gate_count_wisp", -- 334
		w * 0.5, -- 334
		cy - 8, -- 334
		420, -- 334
		76, -- 334
		PALETTE.jadeMist, -- 334
		0.22, -- 334
		0 -- 334
	) -- 334
	local numZh = toChineseUpper(countNum) -- 336
	texts:put( -- 337
		"title", -- 337
		numZh, -- 337
		w * 0.5, -- 337
		cy + 8, -- 337
		toColor(PALETTE.textBright), -- 337
		0.5, -- 337
		0.5, -- 337
		"Center", -- 337
		12, -- 337
		0.42 + frac * 0.56, -- 337
		0.1 -- 337
	) -- 337
	drawHairline( -- 338
		uiInkDraw, -- 338
		art, -- 338
		"gate_count_div", -- 338
		w * 0.5, -- 338
		cy - 34, -- 338
		240, -- 338
		PALETTE.silkDim, -- 338
		0.62, -- 338
		true, -- 338
		2 -- 338
	) -- 338
	texts:put( -- 339
		"sm", -- 339
		"城外静候 · 默数至二十", -- 339
		w * 0.5, -- 339
		cy - 58, -- 339
		toColor(PALETTE.textMid), -- 339
		0.5, -- 339
		0.5, -- 339
		"Center", -- 339
		3.4, -- 339
		0.84, -- 339
		0.08 -- 339
	) -- 339
end -- 317
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 349
	local cardW = 588 -- 359
	local cardH = 382 -- 360
	local cx = (w - cardW) * 0.5 -- 361
	local cy = (h - cardH) * 0.5 + 10 -- 362
	local midX = w * 0.5 -- 363
	local midY = cy + cardH * 0.5 -- 364
	uiDraw:drawRect( -- 367
		Rect(0, 0, w, h), -- 367
		Color(7, 9, 15, 174) -- 367
	) -- 367
	art:tryPlace( -- 368
		"ink_frame_mask", -- 368
		"reg_shadow", -- 368
		midX, -- 368
		midY - 6, -- 368
		cardW + 58, -- 368
		cardH + 50, -- 368
		{ -- 368
			color = toColor(PALETTE.voidDark), -- 369
			opacity = 0.82, -- 369
			layer = -1 -- 369
		} -- 369
	) -- 369
	if not art:tryPlace( -- 369
		"ink_song_paper", -- 373
		"registry_song_paper", -- 373
		midX, -- 373
		midY, -- 373
		cardW, -- 373
		cardH, -- 373
		{opacity = 0.98, layer = 1} -- 373
	) then -- 373
		uiDraw:drawRect( -- 374
			Rect(cx, cy, cardW, cardH), -- 374
			toColor(PALETTE.xuanPaper, 246), -- 374
			1, -- 374
			toColor(PALETTE.silkDim, 180) -- 374
		) -- 374
	end -- 374
	fillRadialGlow( -- 376
		uiGlow, -- 376
		midX, -- 376
		midY + 46, -- 376
		240, -- 376
		130, -- 376
		Color(235, 224, 202, 14), -- 376
		Color(235, 224, 202, 0), -- 376
		14 -- 376
	) -- 376
	local padX = 46 -- 379
	local padY = 36 -- 380
	local inX = cx + padX -- 381
	local inY = cy + padY -- 382
	local inW = cardW - padX * 2 -- 383
	local inH = cardH - padY * 2 -- 384
	local redSilk = toColor(PALETTE.rouge, 118) -- 385
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 386
	uiInkDraw:drawRect( -- 388
		Rect(inX, inY, inW, inH), -- 388
		Color(0, 0, 0, 0), -- 388
		0.9, -- 388
		redSilk -- 388
	) -- 388
	uiInkDraw:drawRect( -- 389
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 389
		Color(0, 0, 0, 0), -- 389
		0.55, -- 389
		redSilkFaint -- 389
	) -- 389
	local headY = inY + inH - 28 -- 392
	texts:put( -- 393
		"md", -- 393
		"北塔入塔登记簿 · 末页", -- 393
		inX + 20, -- 393
		headY, -- 393
		toColor(PALETTE.xuanInk), -- 393
		0, -- 393
		0.5, -- 393
		"Left", -- 393
		2.4, -- 393
		0.94, -- 393
		0 -- 393
	) -- 393
	texts:put( -- 394
		"xs", -- 394
		"守望行记", -- 394
		inX + inW - 20, -- 394
		headY, -- 394
		toColor(PALETTE.xuanInkSub), -- 394
		1, -- 394
		0.5, -- 394
		"Right", -- 394
		2, -- 394
		0.78, -- 394
		0 -- 394
	) -- 394
	uiInkDraw:drawSegment( -- 395
		Vec2(inX + 14, headY - 22), -- 395
		Vec2(inX + inW - 14, headY - 22), -- 395
		0.85, -- 395
		redSilk -- 395
	) -- 395
	local row1Y = headY - 56 -- 398
	texts:put( -- 399
		"sm", -- 399
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 399
		inX + 20, -- 399
		row1Y, -- 399
		toColor(PALETTE.xuanInk), -- 399
		0, -- 399
		0.5, -- 399
		"Left", -- 399
		0.8, -- 399
		0.94, -- 399
		0 -- 399
	) -- 399
	texts:put( -- 400
		"xs", -- 400
		"附注：护送者留守南城门，托她独自走完余路。", -- 400
		inX + 20, -- 400
		row1Y - 28, -- 400
		toColor(PALETTE.xuanInkSub), -- 400
		0, -- 400
		0.5, -- 400
		"Left", -- 400
		0.6, -- 400
		0.88, -- 400
		0 -- 400
	) -- 400
	uiInkDraw:drawSegment( -- 401
		Vec2(inX + 16, row1Y - 48), -- 401
		Vec2(inX + inW - 16, row1Y - 48), -- 401
		0.65, -- 401
		redSilkFaint -- 401
	) -- 401
	local blankY = row1Y - 80 -- 404
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 405
	texts:put( -- 406
		"sm", -- 406
		"肆拾贰", -- 406
		inX + 20, -- 406
		blankY, -- 406
		toColor(PALETTE.rouge), -- 406
		0, -- 406
		0.5, -- 406
		"Left", -- 406
		1, -- 406
		0.92, -- 406
		0 -- 406
	) -- 406
	uiInkDraw:drawSegment( -- 407
		Vec2(inX + 94, blankY - 7), -- 407
		Vec2(inX + inW - 116, blankY - 7), -- 407
		0.95, -- 407
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 407
	) -- 407
	texts:put( -- 408
		"xs", -- 408
		"（空行留待）", -- 408
		inX + inW - 104, -- 408
		blankY, -- 408
		toColor(PALETTE.xuanInkSub), -- 408
		0, -- 408
		0.5, -- 408
		"Left", -- 408
		1, -- 408
		0.82 * pulse, -- 408
		0 -- 408
	) -- 408
	if p.phase == "tower-end" then -- 408
		local signY = inY + 46 -- 412
		texts:put( -- 413
			"banner", -- 413
			"向西守望", -- 413
			midX - 18, -- 413
			signY, -- 413
			toColor(PALETTE.xuanInk), -- 413
			0.5, -- 413
			0.5, -- 413
			"Center", -- 413
			6.5, -- 413
			0.92, -- 413
			0 -- 413
		) -- 413
		drawLoneSeal( -- 414
			uiInkDraw, -- 414
			art, -- 414
			texts, -- 414
			"reg_lone_seal", -- 414
			midX + 86, -- 414
			signY, -- 414
			22, -- 414
			42, -- 414
			"守", -- 414
			"望", -- 414
			PALETTE.sealRed, -- 414
			PALETTE.sealText, -- 414
			0.92, -- 414
			4 -- 414
		) -- 414
		drawSilkVeil( -- 416
			uiDraw, -- 416
			art, -- 416
			"reg_hint_veil", -- 416
			midX, -- 416
			cy - 28, -- 416
			360, -- 416
			32, -- 416
			PALETTE.inkWash, -- 416
			0.72, -- 416
			0 -- 416
		) -- 416
		texts:put( -- 417
			"xs", -- 417
			"按 E 再次启程     ·     Esc 暂歇", -- 417
			midX, -- 417
			cy - 28, -- 417
			toColor(PALETTE.textMid), -- 417
			0.5, -- 417
			0.5, -- 417
			"Center", -- 417
			1.6, -- 417
			0.92, -- 417
			0.08 -- 417
		) -- 417
	end -- 417
end -- 349
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 421
	local theme = themeOf(roomKey) -- 430
	local t = self.bannerT / self.bannerMax -- 431
	local alpha = 1 -- 432
	if t > 0.82 then -- 432
		alpha = (1 - t) / 0.18 -- 434
	elseif t < 0.28 then -- 434
		alpha = t / 0.28 -- 436
	end -- 436
	local cx = w * 0.5 -- 438
	local cy = h * 0.77 -- 439
	local spread = math.min(1, alpha * 1.15) -- 440
	drawSilkVeil( -- 443
		uiDraw, -- 443
		art, -- 443
		"banner_veil", -- 443
		cx, -- 443
		cy - 2, -- 443
		480 * spread + 100, -- 443
		92, -- 443
		PALETTE.inkWash, -- 443
		0.76 * alpha, -- 443
		-1 -- 443
	) -- 443
	drawMistCurve( -- 444
		art, -- 444
		"banner_mist", -- 444
		cx, -- 444
		cy + 4, -- 444
		460 * spread, -- 444
		72, -- 444
		theme.accent, -- 444
		0.28 * alpha, -- 444
		0 -- 444
	) -- 444
	drawHairline( -- 445
		uiInkDraw, -- 445
		art, -- 445
		"banner_line", -- 445
		cx, -- 445
		cy - 16, -- 445
		320 * spread, -- 445
		PALETTE.silkLine, -- 445
		0.64 * alpha, -- 445
		false, -- 445
		2 -- 445
	) -- 445
	local sep = " · " -- 448
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 449
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 450
	if idx > 0 then -- 450
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 452
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 453
		local lw = visualTextWidth(leftPart, 42) -- 454
		local rw = visualTextWidth(rightPart, 42) -- 455
		local dotGap = 28 -- 456
		local totalW = lw + rw + dotGap -- 457
		local leftEdge = cx - totalW * 0.5 -- 458
		local dotX = leftEdge + lw + dotGap * 0.5 -- 459
		texts:put( -- 461
			"banner", -- 461
			leftPart, -- 461
			leftEdge, -- 461
			cy + 14, -- 461
			toColor(PALETTE.textBright), -- 461
			0, -- 461
			0.5, -- 461
			"Left", -- 461
			2, -- 461
			alpha, -- 461
			0.1 -- 461
		) -- 461
		drawBlossomDot( -- 462
			uiInkDraw, -- 462
			art, -- 462
			"banner_mid_dot", -- 462
			dotX, -- 462
			cy + 12, -- 462
			11, -- 462
			dotCol, -- 462
			0.92 * alpha, -- 462
			4 -- 462
		) -- 462
		texts:put( -- 463
			"banner", -- 463
			rightPart, -- 463
			dotX + dotGap * 0.5, -- 463
			cy + 14, -- 463
			toColor(PALETTE.textBright), -- 463
			0, -- 463
			0.5, -- 463
			"Left", -- 463
			2, -- 463
			alpha, -- 463
			0.1 -- 463
		) -- 463
	else -- 463
		texts:put( -- 465
			"banner", -- 465
			theme.titleZh, -- 465
			cx, -- 465
			cy + 14, -- 465
			toColor(PALETTE.textBright), -- 465
			0.5, -- 465
			0.5, -- 465
			"Center", -- 465
			3, -- 465
			alpha, -- 465
			0.1 -- 465
		) -- 465
	end -- 465
	texts:put( -- 467
		"xs", -- 467
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 467
		cx, -- 467
		cy - 34, -- 467
		toColor(PALETTE.textMid), -- 467
		0.5, -- 467
		0.5, -- 467
		"Center", -- 467
		2.2, -- 467
		0.82 * alpha, -- 467
		0.08 -- 467
	) -- 467
end -- 421
return ____exports -- 421