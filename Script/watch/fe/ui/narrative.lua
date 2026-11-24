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
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 169
		end -- 169
		if p.coverHug then -- 169
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 172
		end -- 172
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 174
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
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 196
		elseif text == "打空" then -- 196
			text = "铅丸偏离或被掩体阻挡" -- 198
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
			return {cue = "战", text = "前方街心有倭寇封锁。鼠标瞄准左键发射火铳，空格贴矮柜可翻越", urgent = false} -- 222
		end -- 222
		return {cue = "", text = "街心安静了。带她继续向右，前往检查站", urgent = false} -- 224
	end -- 224
	if key == "checkpoint" then -- 224
		if p.escort.state == "frozen" then -- 224
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 229
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
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 242
		end -- 242
		if p.phase == "gate-send" then -- 242
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 249
		end -- 249
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 251
	end -- 251
	if key == "outside" then -- 251
		if not p.cartDocked then -- 251
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 256
		end -- 256
		if p.checkpoint < p.room.arch.x1 then -- 256
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 259
		end -- 259
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 261
	end -- 261
	if key == "village" then -- 261
		if p.scavChase then -- 261
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 266
		end -- 266
		if p.passed then -- 266
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 269
		end -- 269
		if p.hasBottle then -- 269
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 272
		end -- 272
		if p.bottleFly ~= nil then -- 272
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 275
		end -- 275
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 275
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 278
		end -- 278
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 280
	end -- 280
	if key == "forest" then -- 280
		if p.dogState == "chase" then -- 280
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 285
		end -- 285
		if p.dogState == "ear" then -- 285
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 288
		end -- 288
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 290
	end -- 290
	if key == "tower" then -- 290
		if p.phase == "tower-wait" then -- 290
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 295
		end -- 295
		if p.phase == "tower-knock" then -- 295
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 298
		end -- 298
		if p.phase == "tower-given" then -- 298
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 301
		end -- 301
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 303
	end -- 303
	return {cue = "", text = theme.introWhisper, urgent = false} -- 306
end -- 156
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 309
	local frac = math.min(1, p.countTick / 1440) -- 319
	local countNum = math.min( -- 320
		100, -- 320
		math.floor(frac * 100) -- 320
	) -- 320
	uiDraw:drawRect( -- 321
		Rect(0, 0, w, h), -- 321
		Color( -- 321
			7, -- 321
			9, -- 321
			15, -- 321
			math.floor(78 + frac * 116 + 0.5) -- 321
		) -- 321
	) -- 321
	local cy = h * 0.56 -- 323
	art:tryPlace( -- 324
		"ink_petal_mist", -- 324
		"gate_count_mist", -- 324
		w * 0.5, -- 324
		cy, -- 324
		290, -- 324
		220, -- 324
		{ -- 324
			color = toColor(PALETTE.inkMist), -- 325
			opacity = 0.34 + frac * 0.2, -- 325
			layer = 0 -- 325
		} -- 325
	) -- 325
	drawMistCurve( -- 327
		art, -- 327
		"gate_count_wisp", -- 327
		w * 0.5, -- 327
		cy - 8, -- 327
		420, -- 327
		76, -- 327
		PALETTE.jadeMist, -- 327
		0.22, -- 327
		0 -- 327
	) -- 327
	local numZh = toChineseUpper(countNum) -- 329
	texts:put( -- 330
		"title", -- 330
		numZh, -- 330
		w * 0.5, -- 330
		cy + 8, -- 330
		toColor(PALETTE.textBright), -- 330
		0.5, -- 330
		0.5, -- 330
		"Center", -- 330
		12, -- 330
		0.42 + frac * 0.56, -- 330
		0.1 -- 330
	) -- 330
	drawHairline( -- 331
		uiInkDraw, -- 331
		art, -- 331
		"gate_count_div", -- 331
		w * 0.5, -- 331
		cy - 34, -- 331
		240, -- 331
		PALETTE.silkDim, -- 331
		0.62, -- 331
		true, -- 331
		2 -- 331
	) -- 331
	texts:put( -- 332
		"sm", -- 332
		"城外静候 · 默数至百", -- 332
		w * 0.5, -- 332
		cy - 58, -- 332
		toColor(PALETTE.textMid), -- 332
		0.5, -- 332
		0.5, -- 332
		"Center", -- 332
		3.4, -- 332
		0.84, -- 332
		0.08 -- 332
	) -- 332
	if p.countTick >= 1440 then -- 332
		local pulse = 0.72 + 0.28 * math.sin(self.time * 3.4) -- 335
		local py = cy - 114 -- 336
		fillRadialGlow( -- 337
			uiGlow, -- 337
			w * 0.5, -- 337
			py, -- 337
			120, -- 337
			22, -- 337
			toColor(PALETTE.amber, 30 * pulse), -- 337
			Color(214, 186, 146, 0), -- 337
			14 -- 337
		) -- 337
		drawSilkRibbon( -- 338
			uiDraw, -- 338
			art, -- 338
			"gate_go_rib", -- 338
			w * 0.5, -- 338
			py, -- 338
			300, -- 338
			38, -- 338
			PALETTE.rougeSoft, -- 338
			0.46 * pulse, -- 338
			1 -- 338
		) -- 338
		drawHairline( -- 339
			uiInkDraw, -- 339
			art, -- 339
			"gate_go_line", -- 339
			w * 0.5, -- 339
			py - 16, -- 339
			210, -- 339
			PALETTE.silkLine, -- 339
			0.48 * pulse, -- 339
			false, -- 339
			2 -- 339
		) -- 339
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 独自向北" -- 340
		texts:put( -- 341
			"sm", -- 341
			prompt, -- 341
			w * 0.5, -- 341
			py, -- 341
			toColor(PALETTE.textBright), -- 341
			0.5, -- 341
			0.5, -- 341
			"Center", -- 341
			2.2, -- 341
			1, -- 341
			0.08 -- 341
		) -- 341
	end -- 341
end -- 309
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 350
	local cardW = 588 -- 360
	local cardH = 382 -- 361
	local cx = (w - cardW) * 0.5 -- 362
	local cy = (h - cardH) * 0.5 + 10 -- 363
	local midX = w * 0.5 -- 364
	local midY = cy + cardH * 0.5 -- 365
	uiDraw:drawRect( -- 368
		Rect(0, 0, w, h), -- 368
		Color(7, 9, 15, 174) -- 368
	) -- 368
	art:tryPlace( -- 369
		"ink_frame_mask", -- 369
		"reg_shadow", -- 369
		midX, -- 369
		midY - 6, -- 369
		cardW + 58, -- 369
		cardH + 50, -- 369
		{ -- 369
			color = toColor(PALETTE.voidDark), -- 370
			opacity = 0.82, -- 370
			layer = -1 -- 370
		} -- 370
	) -- 370
	if not art:tryPlace( -- 370
		"ink_song_paper", -- 374
		"registry_song_paper", -- 374
		midX, -- 374
		midY, -- 374
		cardW, -- 374
		cardH, -- 374
		{opacity = 0.98, layer = 1} -- 374
	) then -- 374
		uiDraw:drawRect( -- 375
			Rect(cx, cy, cardW, cardH), -- 375
			toColor(PALETTE.xuanPaper, 246), -- 375
			1, -- 375
			toColor(PALETTE.silkDim, 180) -- 375
		) -- 375
	end -- 375
	fillRadialGlow( -- 377
		uiGlow, -- 377
		midX, -- 377
		midY + 46, -- 377
		240, -- 377
		130, -- 377
		Color(235, 224, 202, 14), -- 377
		Color(235, 224, 202, 0), -- 377
		14 -- 377
	) -- 377
	local padX = 46 -- 380
	local padY = 36 -- 381
	local inX = cx + padX -- 382
	local inY = cy + padY -- 383
	local inW = cardW - padX * 2 -- 384
	local inH = cardH - padY * 2 -- 385
	local redSilk = toColor(PALETTE.rouge, 118) -- 386
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 387
	uiInkDraw:drawRect( -- 389
		Rect(inX, inY, inW, inH), -- 389
		Color(0, 0, 0, 0), -- 389
		0.9, -- 389
		redSilk -- 389
	) -- 389
	uiInkDraw:drawRect( -- 390
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 390
		Color(0, 0, 0, 0), -- 390
		0.55, -- 390
		redSilkFaint -- 390
	) -- 390
	local headY = inY + inH - 28 -- 393
	texts:put( -- 394
		"md", -- 394
		"北塔入塔登记簿 · 末页", -- 394
		inX + 20, -- 394
		headY, -- 394
		toColor(PALETTE.xuanInk), -- 394
		0, -- 394
		0.5, -- 394
		"Left", -- 394
		2.4, -- 394
		0.94, -- 394
		0 -- 394
	) -- 394
	texts:put( -- 395
		"xs", -- 395
		"守望行记", -- 395
		inX + inW - 20, -- 395
		headY, -- 395
		toColor(PALETTE.xuanInkSub), -- 395
		1, -- 395
		0.5, -- 395
		"Right", -- 395
		2, -- 395
		0.78, -- 395
		0 -- 395
	) -- 395
	uiInkDraw:drawSegment( -- 396
		Vec2(inX + 14, headY - 22), -- 396
		Vec2(inX + inW - 14, headY - 22), -- 396
		0.85, -- 396
		redSilk -- 396
	) -- 396
	local row1Y = headY - 56 -- 399
	texts:put( -- 400
		"sm", -- 400
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 400
		inX + 20, -- 400
		row1Y, -- 400
		toColor(PALETTE.xuanInk), -- 400
		0, -- 400
		0.5, -- 400
		"Left", -- 400
		0.8, -- 400
		0.94, -- 400
		0 -- 400
	) -- 400
	texts:put( -- 401
		"xs", -- 401
		"附注：护送者留守南城门，托她独自走完余路。", -- 401
		inX + 20, -- 401
		row1Y - 28, -- 401
		toColor(PALETTE.xuanInkSub), -- 401
		0, -- 401
		0.5, -- 401
		"Left", -- 401
		0.6, -- 401
		0.88, -- 401
		0 -- 401
	) -- 401
	uiInkDraw:drawSegment( -- 402
		Vec2(inX + 16, row1Y - 48), -- 402
		Vec2(inX + inW - 16, row1Y - 48), -- 402
		0.65, -- 402
		redSilkFaint -- 402
	) -- 402
	local blankY = row1Y - 80 -- 405
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 406
	texts:put( -- 407
		"sm", -- 407
		"肆拾贰", -- 407
		inX + 20, -- 407
		blankY, -- 407
		toColor(PALETTE.rouge), -- 407
		0, -- 407
		0.5, -- 407
		"Left", -- 407
		1, -- 407
		0.92, -- 407
		0 -- 407
	) -- 407
	uiInkDraw:drawSegment( -- 408
		Vec2(inX + 94, blankY - 7), -- 408
		Vec2(inX + inW - 116, blankY - 7), -- 408
		0.95, -- 408
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 408
	) -- 408
	texts:put( -- 409
		"xs", -- 409
		"（空行留待）", -- 409
		inX + inW - 104, -- 409
		blankY, -- 409
		toColor(PALETTE.xuanInkSub), -- 409
		0, -- 409
		0.5, -- 409
		"Left", -- 409
		1, -- 409
		0.82 * pulse, -- 409
		0 -- 409
	) -- 409
	if p.phase == "tower-end" then -- 409
		local signY = inY + 46 -- 413
		texts:put( -- 414
			"banner", -- 414
			"向西守望", -- 414
			midX - 18, -- 414
			signY, -- 414
			toColor(PALETTE.xuanInk), -- 414
			0.5, -- 414
			0.5, -- 414
			"Center", -- 414
			6.5, -- 414
			0.92, -- 414
			0 -- 414
		) -- 414
		drawLoneSeal( -- 415
			uiInkDraw, -- 415
			art, -- 415
			texts, -- 415
			"reg_lone_seal", -- 415
			midX + 86, -- 415
			signY, -- 415
			22, -- 415
			42, -- 415
			"守", -- 415
			"望", -- 415
			PALETTE.sealRed, -- 415
			PALETTE.sealText, -- 415
			0.92, -- 415
			4 -- 415
		) -- 415
		drawSilkVeil( -- 417
			uiDraw, -- 417
			art, -- 417
			"reg_hint_veil", -- 417
			midX, -- 417
			cy - 28, -- 417
			360, -- 417
			32, -- 417
			PALETTE.inkWash, -- 417
			0.72, -- 417
			0 -- 417
		) -- 417
		texts:put( -- 418
			"xs", -- 418
			"按 E 再次启程     ·     Esc 暂歇", -- 418
			midX, -- 418
			cy - 28, -- 418
			toColor(PALETTE.textMid), -- 418
			0.5, -- 418
			0.5, -- 418
			"Center", -- 418
			1.6, -- 418
			0.92, -- 418
			0.08 -- 418
		) -- 418
	end -- 418
end -- 350
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 422
	local theme = themeOf(roomKey) -- 431
	local t = self.bannerT / self.bannerMax -- 432
	local alpha = 1 -- 433
	if t > 0.82 then -- 433
		alpha = (1 - t) / 0.18 -- 435
	elseif t < 0.28 then -- 435
		alpha = t / 0.28 -- 437
	end -- 437
	local cx = w * 0.5 -- 439
	local cy = h * 0.77 -- 440
	local spread = math.min(1, alpha * 1.15) -- 441
	drawSilkVeil( -- 444
		uiDraw, -- 444
		art, -- 444
		"banner_veil", -- 444
		cx, -- 444
		cy - 2, -- 444
		480 * spread + 100, -- 444
		92, -- 444
		PALETTE.inkWash, -- 444
		0.76 * alpha, -- 444
		-1 -- 444
	) -- 444
	drawMistCurve( -- 445
		art, -- 445
		"banner_mist", -- 445
		cx, -- 445
		cy + 4, -- 445
		460 * spread, -- 445
		72, -- 445
		theme.accent, -- 445
		0.28 * alpha, -- 445
		0 -- 445
	) -- 445
	drawHairline( -- 446
		uiInkDraw, -- 446
		art, -- 446
		"banner_line", -- 446
		cx, -- 446
		cy - 16, -- 446
		320 * spread, -- 446
		PALETTE.silkLine, -- 446
		0.64 * alpha, -- 446
		false, -- 446
		2 -- 446
	) -- 446
	local sep = " · " -- 449
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 450
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 451
	if idx > 0 then -- 451
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 453
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 454
		local lw = visualTextWidth(leftPart, 42) -- 455
		local rw = visualTextWidth(rightPart, 42) -- 456
		local dotGap = 28 -- 457
		local totalW = lw + rw + dotGap -- 458
		local leftEdge = cx - totalW * 0.5 -- 459
		local dotX = leftEdge + lw + dotGap * 0.5 -- 460
		texts:put( -- 462
			"banner", -- 462
			leftPart, -- 462
			leftEdge, -- 462
			cy + 14, -- 462
			toColor(PALETTE.textBright), -- 462
			0, -- 462
			0.5, -- 462
			"Left", -- 462
			2, -- 462
			alpha, -- 462
			0.1 -- 462
		) -- 462
		drawBlossomDot( -- 463
			uiInkDraw, -- 463
			art, -- 463
			"banner_mid_dot", -- 463
			dotX, -- 463
			cy + 12, -- 463
			11, -- 463
			dotCol, -- 463
			0.92 * alpha, -- 463
			4 -- 463
		) -- 463
		texts:put( -- 464
			"banner", -- 464
			rightPart, -- 464
			dotX + dotGap * 0.5, -- 464
			cy + 14, -- 464
			toColor(PALETTE.textBright), -- 464
			0, -- 464
			0.5, -- 464
			"Left", -- 464
			2, -- 464
			alpha, -- 464
			0.1 -- 464
		) -- 464
	else -- 464
		texts:put( -- 466
			"banner", -- 466
			theme.titleZh, -- 466
			cx, -- 466
			cy + 14, -- 466
			toColor(PALETTE.textBright), -- 466
			0.5, -- 466
			0.5, -- 466
			"Center", -- 466
			3, -- 466
			alpha, -- 466
			0.1 -- 466
		) -- 466
	end -- 466
	texts:put( -- 468
		"xs", -- 468
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 468
		cx, -- 468
		cy - 34, -- 468
		toColor(PALETTE.textMid), -- 468
		0.5, -- 468
		0.5, -- 468
		"Center", -- 468
		2.2, -- 468
		0.82 * alpha, -- 468
		0.08 -- 468
	) -- 468
end -- 422
return ____exports -- 422