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
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled) -- 65
	if assistHintsEnabled == nil then -- 65
		assistHintsEnabled = false -- 74
	end -- 74
	if self.letterbox > 0.01 then -- 74
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
			h, -- 93
			assistHintsEnabled -- 93
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
			h, -- 98
			assistHintsEnabled -- 98
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
end -- 65
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled) -- 117
	local line = self:composeNarrativeLine(p, assistHintsEnabled) -- 127
	if line.text == "" then -- 127
		return -- 129
	end -- 129
	local hasCue = line.cue ~= "" -- 131
	local textW = visualTextWidth(line.text, 18) -- 132
	local contentW = textW + (hasCue and 48 or 0) -- 133
	local stripW = math.min( -- 134
		w - 72, -- 134
		math.max(540, contentW + 210) -- 134
	) -- 134
	local stripH = 54 -- 135
	local cx = w * 0.5 -- 136
	local cy = self.letterbox > 0.4 and 36 or 42 -- 137
	drawSilkVeil( -- 140
		uiDraw, -- 140
		art, -- 140
		"sub_veil", -- 140
		cx, -- 140
		cy, -- 140
		stripW, -- 140
		stripH, -- 140
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 140
		0.84, -- 140
		-1 -- 140
	) -- 140
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 142
	drawHairline( -- 143
		uiInkDraw, -- 143
		art, -- 143
		"sub_top_line", -- 143
		cx, -- 143
		cy + 23, -- 143
		stripW * 0.72, -- 143
		railCol, -- 143
		line.urgent and 0.72 or 0.52, -- 143
		true, -- 143
		2 -- 143
	) -- 143
	if hasCue then -- 143
		local startX = cx - contentW * 0.5 -- 146
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 147
		drawBlossomDot( -- 148
			uiInkDraw, -- 148
			art, -- 148
			"sub_cue_dot", -- 148
			startX + 6, -- 148
			cy - 1, -- 148
			10, -- 148
			cueCol, -- 148
			0.94, -- 148
			4 -- 148
		) -- 148
		texts:put( -- 149
			"xs", -- 149
			line.cue, -- 149
			startX + 24, -- 149
			cy - 1, -- 149
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 149
			0.5, -- 149
			0.5, -- 149
			"Center", -- 149
			0, -- 149
			0.96, -- 149
			0.08 -- 149
		) -- 149
		uiInkDraw:drawSegment( -- 150
			Vec2(startX + 38, cy - 8), -- 150
			Vec2(startX + 38, cy + 6), -- 150
			0.75, -- 150
			toColor(PALETTE.silkDim, 115) -- 150
		) -- 150
		texts:put( -- 151
			"sm", -- 151
			line.text, -- 151
			startX + 48, -- 151
			cy - 1, -- 151
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 151
			0, -- 151
			0.5, -- 151
			"Left", -- 151
			0.9, -- 151
			0.98, -- 151
			0.08 -- 151
		) -- 151
	else -- 151
		texts:put( -- 153
			"sm", -- 153
			line.text, -- 153
			cx, -- 153
			cy - 1, -- 153
			toColor(PALETTE.textBright), -- 153
			0.5, -- 153
			0.5, -- 153
			"Center", -- 153
			1, -- 153
			0.98, -- 153
			0.08 -- 153
		) -- 153
	end -- 153
end -- 117
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 158
	local key = p.room.key -- 159
	local theme = themeOf(key) -- 160
	if key == "gate" and p.phase == "gate-count" then -- 160
		if p.countTick >= GATE_COUNT_END then -- 160
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 164
		end -- 164
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 170
	end -- 170
	if not assistHintsEnabled then -- 170
		if key == "prologue" and p.phase == "prologue-give" then -- 170
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 176
		end -- 176
		if key == "checkpoint" and p.escort.state == "calming" then -- 176
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 179
		end -- 179
		if key == "tower" then -- 179
			if p.phase == "tower-knock" then -- 179
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 183
			end -- 183
			if p.phase == "tower-given" then -- 183
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 186
			end -- 186
		end -- 186
		if p.flash ~= "" and p.flashT > 0 then -- 186
			local hasKeyHint = (string.find(p.flash, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "E 再玩", nil, true) or 0) - 1 >= 0 -- 191
			if not hasKeyHint then -- 191
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 197
				local text = p.flash -- 198
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 199
				if key == "tower" or key == "prologue" then -- 199
					cue = "" -- 201
				end -- 201
				if text == "命中" then -- 201
					text = "倭寇击倒" -- 204
				elseif text == "打空" then -- 204
					text = "铅丸偏离或被掩体阻挡" -- 206
				elseif text == "翻滚" then -- 206
					text = "伏身翻滚回避" -- 208
				end -- 208
				return {cue = cue, text = text, urgent = isDanger} -- 210
			end -- 210
		end -- 210
		return {cue = "", text = "", urgent = false} -- 213
	end -- 213
	if key == "gate" and p.phase == "gate-hold" then -- 213
		local threatened = false -- 217
		local hasAliveEnemy = false -- 218
		local i = 0 -- 219
		do -- 219
			i = 0 -- 220
			while i < #p.enemies do -- 220
				if p.enemies[i + 1].alive then -- 220
					hasAliveEnemy = true -- 222
					if p.enemies[i + 1].warnT > 0 then -- 222
						threatened = true -- 224
					end -- 224
				end -- 224
				i = i + 1 -- 220
			end -- 220
		end -- 220
		if threatened then -- 220
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 229
		end -- 229
		if p.coverHug then -- 229
			if hasAliveEnemy and not p.coverBlocking then -- 229
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 233
			end -- 233
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 235
		end -- 235
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 237
	end -- 237
	if key == "gate" and p.phase == "gate-count" then -- 237
		if p.countTick >= GATE_COUNT_END then -- 237
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 242
		end -- 242
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 248
	end -- 248
	if p.flash ~= "" and p.flashT > 0 then -- 248
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 252
		local text = p.flash -- 253
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 254
		if key == "tower" or key == "prologue" then -- 254
			cue = "" -- 256
		end -- 256
		if text == "命中" then -- 256
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 259
		elseif text == "打空" then -- 259
			text = "铅丸偏离或被掩体阻挡" -- 261
		elseif text == "翻滚" then -- 261
			text = "伏身翻滚回避" -- 263
		end -- 263
		return {cue = cue, text = text, urgent = isDanger} -- 265
	end -- 265
	if key == "prologue" then -- 265
		if p.phase == "prologue-wait" then -- 265
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 270
		end -- 270
		if p.phase == "prologue-give" then -- 270
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 273
		end -- 273
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 275
	end -- 275
	if key == "street" then -- 275
		local alive = 0 -- 279
		local i = 0 -- 280
		do -- 280
			i = 0 -- 281
			while i < #p.enemies do -- 281
				if p.enemies[i + 1].alive then -- 281
					alive = alive + 1 -- 282
				end -- 282
				i = i + 1 -- 281
			end -- 281
		end -- 281
		if alive > 0 then -- 281
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 285
		end -- 285
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 287
	end -- 287
	if key == "checkpoint" then -- 287
		if p.escort.state == "frozen" then -- 287
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 292
		end -- 292
		if p.escort.state == "calming" then -- 292
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 295
		end -- 295
		if not p.cartDocked then -- 295
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 298
		end -- 298
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 300
	end -- 300
	if key == "gate" then -- 300
		if p.phase == "gate-idle" then -- 300
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 305
		end -- 305
		if p.phase == "gate-send" then -- 305
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 312
		end -- 312
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 314
	end -- 314
	if key == "outside" then -- 314
		if not p.cartDocked then -- 314
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 319
		end -- 319
		if p.checkpoint < p.room.arch.x1 then -- 319
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 322
		end -- 322
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 324
	end -- 324
	if key == "village" then -- 324
		if p.scavChase then -- 324
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 329
		end -- 329
		if p.passed then -- 329
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 332
		end -- 332
		if p.hasBottle then -- 332
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 335
		end -- 335
		if p.bottleFly ~= nil then -- 335
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 338
		end -- 338
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 338
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 341
		end -- 341
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 343
	end -- 343
	if key == "forest" then -- 343
		if p.dogState == "chase" then -- 343
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 348
		end -- 348
		if p.dogState == "ear" then -- 348
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 351
		end -- 351
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 353
	end -- 353
	if key == "tower" then -- 353
		if p.phase == "tower-wait" then -- 353
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 358
		end -- 358
		if p.phase == "tower-knock" then -- 358
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 361
		end -- 361
		if p.phase == "tower-given" then -- 361
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 364
		end -- 364
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 366
	end -- 366
	return {cue = "", text = theme.introWhisper, urgent = false} -- 369
end -- 158
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 372
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 381
	local countNum = gateCountAtTick(p.countTick) -- 382
	uiDraw:drawRect( -- 383
		Rect(0, 0, w, h), -- 383
		Color( -- 383
			7, -- 383
			9, -- 383
			15, -- 383
			math.floor(78 + frac * 116 + 0.5) -- 383
		) -- 383
	) -- 383
	local cy = h * 0.56 -- 385
	art:tryPlace( -- 386
		"ink_petal_mist", -- 386
		"gate_count_mist", -- 386
		w * 0.5, -- 386
		cy, -- 386
		290, -- 386
		220, -- 386
		{ -- 386
			color = toColor(PALETTE.inkMist), -- 387
			opacity = 0.34 + frac * 0.2, -- 387
			layer = 0 -- 387
		} -- 387
	) -- 387
	drawMistCurve( -- 389
		art, -- 389
		"gate_count_wisp", -- 389
		w * 0.5, -- 389
		cy - 8, -- 389
		420, -- 389
		76, -- 389
		PALETTE.jadeMist, -- 389
		0.22, -- 389
		0 -- 389
	) -- 389
	local numZh = toChineseUpper(countNum) -- 391
	texts:put( -- 392
		"title", -- 392
		numZh, -- 392
		w * 0.5, -- 392
		cy + 8, -- 392
		toColor(PALETTE.textBright), -- 392
		0.5, -- 392
		0.5, -- 392
		"Center", -- 392
		12, -- 392
		0.42 + frac * 0.56, -- 392
		0.1 -- 392
	) -- 392
	drawHairline( -- 393
		uiInkDraw, -- 393
		art, -- 393
		"gate_count_div", -- 393
		w * 0.5, -- 393
		cy - 34, -- 393
		240, -- 393
		PALETTE.silkDim, -- 393
		0.62, -- 393
		true, -- 393
		2 -- 393
	) -- 393
	texts:put( -- 394
		"sm", -- 394
		"城外静候 · 默数至二十", -- 394
		w * 0.5, -- 394
		cy - 58, -- 394
		toColor(PALETTE.textMid), -- 394
		0.5, -- 394
		0.5, -- 394
		"Center", -- 394
		3.4, -- 394
		0.84, -- 394
		0.08 -- 394
	) -- 394
end -- 372
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled) -- 404
	local cardW = 588 -- 415
	local cardH = 382 -- 416
	local cx = (w - cardW) * 0.5 -- 417
	local cy = (h - cardH) * 0.5 + 10 -- 418
	local midX = w * 0.5 -- 419
	local midY = cy + cardH * 0.5 -- 420
	uiDraw:drawRect( -- 423
		Rect(0, 0, w, h), -- 423
		Color(7, 9, 15, 174) -- 423
	) -- 423
	art:tryPlace( -- 424
		"ink_frame_mask", -- 424
		"reg_shadow", -- 424
		midX, -- 424
		midY - 6, -- 424
		cardW + 58, -- 424
		cardH + 50, -- 424
		{ -- 424
			color = toColor(PALETTE.voidDark), -- 425
			opacity = 0.82, -- 425
			layer = -1 -- 425
		} -- 425
	) -- 425
	if not art:tryPlace( -- 425
		"ink_song_paper", -- 429
		"registry_song_paper", -- 429
		midX, -- 429
		midY, -- 429
		cardW, -- 429
		cardH, -- 429
		{opacity = 0.98, layer = 1} -- 429
	) then -- 429
		uiDraw:drawRect( -- 430
			Rect(cx, cy, cardW, cardH), -- 430
			toColor(PALETTE.xuanPaper, 246), -- 430
			1, -- 430
			toColor(PALETTE.silkDim, 180) -- 430
		) -- 430
	end -- 430
	fillRadialGlow( -- 432
		uiGlow, -- 432
		midX, -- 432
		midY + 46, -- 432
		240, -- 432
		130, -- 432
		Color(235, 224, 202, 14), -- 432
		Color(235, 224, 202, 0), -- 432
		14 -- 432
	) -- 432
	local padX = 46 -- 435
	local padY = 36 -- 436
	local inX = cx + padX -- 437
	local inY = cy + padY -- 438
	local inW = cardW - padX * 2 -- 439
	local inH = cardH - padY * 2 -- 440
	local redSilk = toColor(PALETTE.rouge, 118) -- 441
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 442
	uiInkDraw:drawRect( -- 444
		Rect(inX, inY, inW, inH), -- 444
		Color(0, 0, 0, 0), -- 444
		0.9, -- 444
		redSilk -- 444
	) -- 444
	uiInkDraw:drawRect( -- 445
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 445
		Color(0, 0, 0, 0), -- 445
		0.55, -- 445
		redSilkFaint -- 445
	) -- 445
	local headY = inY + inH - 28 -- 448
	texts:put( -- 449
		"md", -- 449
		"北塔入塔登记簿 · 末页", -- 449
		inX + 20, -- 449
		headY, -- 449
		toColor(PALETTE.xuanInk), -- 449
		0, -- 449
		0.5, -- 449
		"Left", -- 449
		2.4, -- 449
		0.94, -- 449
		0 -- 449
	) -- 449
	texts:put( -- 450
		"xs", -- 450
		"守望行记", -- 450
		inX + inW - 20, -- 450
		headY, -- 450
		toColor(PALETTE.xuanInkSub), -- 450
		1, -- 450
		0.5, -- 450
		"Right", -- 450
		2, -- 450
		0.78, -- 450
		0 -- 450
	) -- 450
	uiInkDraw:drawSegment( -- 451
		Vec2(inX + 14, headY - 22), -- 451
		Vec2(inX + inW - 14, headY - 22), -- 451
		0.85, -- 451
		redSilk -- 451
	) -- 451
	local row1Y = headY - 56 -- 454
	texts:put( -- 455
		"sm", -- 455
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 455
		inX + 20, -- 455
		row1Y, -- 455
		toColor(PALETTE.xuanInk), -- 455
		0, -- 455
		0.5, -- 455
		"Left", -- 455
		0.8, -- 455
		0.94, -- 455
		0 -- 455
	) -- 455
	texts:put( -- 456
		"xs", -- 456
		"附注：护送者留守南城门，托她独自走完余路。", -- 456
		inX + 20, -- 456
		row1Y - 28, -- 456
		toColor(PALETTE.xuanInkSub), -- 456
		0, -- 456
		0.5, -- 456
		"Left", -- 456
		0.6, -- 456
		0.88, -- 456
		0 -- 456
	) -- 456
	uiInkDraw:drawSegment( -- 457
		Vec2(inX + 16, row1Y - 48), -- 457
		Vec2(inX + inW - 16, row1Y - 48), -- 457
		0.65, -- 457
		redSilkFaint -- 457
	) -- 457
	local blankY = row1Y - 80 -- 460
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 461
	texts:put( -- 462
		"sm", -- 462
		"肆拾贰", -- 462
		inX + 20, -- 462
		blankY, -- 462
		toColor(PALETTE.rouge), -- 462
		0, -- 462
		0.5, -- 462
		"Left", -- 462
		1, -- 462
		0.92, -- 462
		0 -- 462
	) -- 462
	uiInkDraw:drawSegment( -- 463
		Vec2(inX + 94, blankY - 7), -- 463
		Vec2(inX + inW - 116, blankY - 7), -- 463
		0.95, -- 463
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 463
	) -- 463
	texts:put( -- 464
		"xs", -- 464
		"（空行留待）", -- 464
		inX + inW - 104, -- 464
		blankY, -- 464
		toColor(PALETTE.xuanInkSub), -- 464
		0, -- 464
		0.5, -- 464
		"Left", -- 464
		1, -- 464
		0.82 * pulse, -- 464
		0 -- 464
	) -- 464
	if p.phase == "tower-end" then -- 464
		local signY = inY + 46 -- 468
		texts:put( -- 469
			"banner", -- 469
			"向西守望", -- 469
			midX - 18, -- 469
			signY, -- 469
			toColor(PALETTE.xuanInk), -- 469
			0.5, -- 469
			0.5, -- 469
			"Center", -- 469
			6.5, -- 469
			0.92, -- 469
			0 -- 469
		) -- 469
		drawLoneSeal( -- 470
			uiInkDraw, -- 470
			art, -- 470
			texts, -- 470
			"reg_lone_seal", -- 470
			midX + 86, -- 470
			signY, -- 470
			22, -- 470
			42, -- 470
			"守", -- 470
			"望", -- 470
			PALETTE.sealRed, -- 470
			PALETTE.sealText, -- 470
			0.92, -- 470
			4 -- 470
		) -- 470
		drawSilkVeil( -- 472
			uiDraw, -- 472
			art, -- 472
			"reg_hint_veil", -- 472
			midX, -- 472
			cy - 28, -- 472
			360, -- 472
			32, -- 472
			PALETTE.inkWash, -- 472
			0.72, -- 472
			0 -- 472
		) -- 472
		local endHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 473
		texts:put( -- 474
			"xs", -- 474
			endHint, -- 474
			midX, -- 474
			cy - 28, -- 474
			toColor(PALETTE.textMid), -- 474
			0.5, -- 474
			0.5, -- 474
			"Center", -- 474
			1.6, -- 474
			0.92, -- 474
			0.08 -- 474
		) -- 474
	end -- 474
end -- 404
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 478
	local theme = themeOf(roomKey) -- 487
	local t = self.bannerT / self.bannerMax -- 488
	local alpha = 1 -- 489
	if t > 0.82 then -- 489
		alpha = (1 - t) / 0.18 -- 491
	elseif t < 0.28 then -- 491
		alpha = t / 0.28 -- 493
	end -- 493
	local cx = w * 0.5 -- 495
	local cy = h * 0.77 -- 496
	local spread = math.min(1, alpha * 1.15) -- 497
	drawSilkVeil( -- 500
		uiDraw, -- 500
		art, -- 500
		"banner_veil", -- 500
		cx, -- 500
		cy - 2, -- 500
		480 * spread + 100, -- 500
		92, -- 500
		PALETTE.inkWash, -- 500
		0.76 * alpha, -- 500
		-1 -- 500
	) -- 500
	drawMistCurve( -- 501
		art, -- 501
		"banner_mist", -- 501
		cx, -- 501
		cy + 4, -- 501
		460 * spread, -- 501
		72, -- 501
		theme.accent, -- 501
		0.28 * alpha, -- 501
		0 -- 501
	) -- 501
	drawHairline( -- 502
		uiInkDraw, -- 502
		art, -- 502
		"banner_line", -- 502
		cx, -- 502
		cy - 16, -- 502
		320 * spread, -- 502
		PALETTE.silkLine, -- 502
		0.64 * alpha, -- 502
		false, -- 502
		2 -- 502
	) -- 502
	local sep = " · " -- 505
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 506
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 507
	if theme.backdropKey ~= nil then -- 507
		texts:put( -- 509
			"lg", -- 509
			theme.titleZh, -- 509
			cx, -- 509
			cy + 14, -- 509
			toColor(PALETTE.textBright), -- 509
			0.5, -- 510
			0.5, -- 510
			"Center", -- 510
			1, -- 510
			alpha, -- 510
			0.1 -- 510
		) -- 510
	elseif idx > 0 then -- 510
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 512
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 513
		local lw = visualTextWidth(leftPart, 42) -- 514
		local rw = visualTextWidth(rightPart, 42) -- 515
		local dotGap = 28 -- 516
		local totalW = lw + rw + dotGap -- 517
		local leftEdge = cx - totalW * 0.5 -- 518
		local dotX = leftEdge + lw + dotGap * 0.5 -- 519
		texts:put( -- 521
			"banner", -- 521
			leftPart, -- 521
			leftEdge, -- 521
			cy + 14, -- 521
			toColor(PALETTE.textBright), -- 521
			0, -- 521
			0.5, -- 521
			"Left", -- 521
			2, -- 521
			alpha, -- 521
			0.1 -- 521
		) -- 521
		drawBlossomDot( -- 522
			uiInkDraw, -- 522
			art, -- 522
			"banner_mid_dot", -- 522
			dotX, -- 522
			cy + 12, -- 522
			11, -- 522
			dotCol, -- 522
			0.92 * alpha, -- 522
			4 -- 522
		) -- 522
		texts:put( -- 523
			"banner", -- 523
			rightPart, -- 523
			dotX + dotGap * 0.5, -- 523
			cy + 14, -- 523
			toColor(PALETTE.textBright), -- 523
			0, -- 523
			0.5, -- 523
			"Left", -- 523
			2, -- 523
			alpha, -- 523
			0.1 -- 523
		) -- 523
	else -- 523
		texts:put( -- 525
			"banner", -- 525
			theme.titleZh, -- 525
			cx, -- 525
			cy + 14, -- 525
			toColor(PALETTE.textBright), -- 525
			0.5, -- 525
			0.5, -- 525
			"Center", -- 525
			3, -- 525
			alpha, -- 525
			0.1 -- 525
		) -- 525
	end -- 525
	texts:put( -- 527
		"xs", -- 527
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 527
		cx, -- 527
		cy - 34, -- 527
		toColor(PALETTE.textMid), -- 527
		0.5, -- 527
		0.5, -- 527
		"Center", -- 527
		2.2, -- 527
		0.82 * alpha, -- 527
		0.08 -- 527
	) -- 527
end -- 478
return ____exports -- 478