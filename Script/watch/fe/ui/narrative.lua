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
		if p.countTick >= 1440 then -- 181
			return {cue = "", text = p.countPrevMove > 0 and "先松开方向键，再按下 [D] —— 由她迈出第一步" or "数到一百了，没有人来。按下 [D]，继续向北走", urgent = false} -- 186
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
			return {cue = "", text = "按 [W/S] 前后绕过倒柜，走近小满后按 [E] 递出指南针", urgent = false} -- 214
		end -- 214
		if p.phase == "prologue-give" then -- 214
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 217
		end -- 217
		return {cue = "", text = "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent = false} -- 219
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
			return {cue = "战", text = "前方街心有倭寇封锁。鼠标瞄准左键发射火铳，空格贴矮柜可翻越", urgent = false} -- 229
		end -- 229
		return {cue = "", text = "街心安静了。带她继续向右，前往检查站", urgent = false} -- 231
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
		return {cue = "归", text = "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent = false} -- 244
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
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 316
	local frac = math.min(1, p.countTick / 1440) -- 326
	local countNum = math.min( -- 327
		100, -- 327
		math.floor(frac * 100) -- 327
	) -- 327
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
		"城外静候 · 默数至百", -- 339
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
	if p.countTick >= 1440 then -- 339
		local pulse = 0.72 + 0.28 * math.sin(self.time * 3.4) -- 342
		local py = cy - 114 -- 343
		fillRadialGlow( -- 344
			uiGlow, -- 344
			w * 0.5, -- 344
			py, -- 344
			120, -- 344
			22, -- 344
			toColor(PALETTE.amber, 30 * pulse), -- 344
			Color(214, 186, 146, 0), -- 344
			14 -- 344
		) -- 344
		drawSilkRibbon( -- 345
			uiDraw, -- 345
			art, -- 345
			"gate_go_rib", -- 345
			w * 0.5, -- 345
			py, -- 345
			300, -- 345
			38, -- 345
			PALETTE.rougeSoft, -- 345
			0.46 * pulse, -- 345
			1 -- 345
		) -- 345
		drawHairline( -- 346
			uiInkDraw, -- 346
			art, -- 346
			"gate_go_line", -- 346
			w * 0.5, -- 346
			py - 16, -- 346
			210, -- 346
			PALETTE.silkLine, -- 346
			0.48 * pulse, -- 346
			false, -- 346
			2 -- 346
		) -- 346
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 独自向北" -- 347
		texts:put( -- 348
			"sm", -- 348
			prompt, -- 348
			w * 0.5, -- 348
			py, -- 348
			toColor(PALETTE.textBright), -- 348
			0.5, -- 348
			0.5, -- 348
			"Center", -- 348
			2.2, -- 348
			1, -- 348
			0.08 -- 348
		) -- 348
	end -- 348
end -- 316
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h) -- 357
	local cardW = 588 -- 367
	local cardH = 382 -- 368
	local cx = (w - cardW) * 0.5 -- 369
	local cy = (h - cardH) * 0.5 + 10 -- 370
	local midX = w * 0.5 -- 371
	local midY = cy + cardH * 0.5 -- 372
	uiDraw:drawRect( -- 375
		Rect(0, 0, w, h), -- 375
		Color(7, 9, 15, 174) -- 375
	) -- 375
	art:tryPlace( -- 376
		"ink_frame_mask", -- 376
		"reg_shadow", -- 376
		midX, -- 376
		midY - 6, -- 376
		cardW + 58, -- 376
		cardH + 50, -- 376
		{ -- 376
			color = toColor(PALETTE.voidDark), -- 377
			opacity = 0.82, -- 377
			layer = -1 -- 377
		} -- 377
	) -- 377
	if not art:tryPlace( -- 377
		"ink_song_paper", -- 381
		"registry_song_paper", -- 381
		midX, -- 381
		midY, -- 381
		cardW, -- 381
		cardH, -- 381
		{opacity = 0.98, layer = 1} -- 381
	) then -- 381
		uiDraw:drawRect( -- 382
			Rect(cx, cy, cardW, cardH), -- 382
			toColor(PALETTE.xuanPaper, 246), -- 382
			1, -- 382
			toColor(PALETTE.silkDim, 180) -- 382
		) -- 382
	end -- 382
	fillRadialGlow( -- 384
		uiGlow, -- 384
		midX, -- 384
		midY + 46, -- 384
		240, -- 384
		130, -- 384
		Color(235, 224, 202, 14), -- 384
		Color(235, 224, 202, 0), -- 384
		14 -- 384
	) -- 384
	local padX = 46 -- 387
	local padY = 36 -- 388
	local inX = cx + padX -- 389
	local inY = cy + padY -- 390
	local inW = cardW - padX * 2 -- 391
	local inH = cardH - padY * 2 -- 392
	local redSilk = toColor(PALETTE.rouge, 118) -- 393
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 394
	uiInkDraw:drawRect( -- 396
		Rect(inX, inY, inW, inH), -- 396
		Color(0, 0, 0, 0), -- 396
		0.9, -- 396
		redSilk -- 396
	) -- 396
	uiInkDraw:drawRect( -- 397
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 397
		Color(0, 0, 0, 0), -- 397
		0.55, -- 397
		redSilkFaint -- 397
	) -- 397
	local headY = inY + inH - 28 -- 400
	texts:put( -- 401
		"md", -- 401
		"北塔入塔登记簿 · 末页", -- 401
		inX + 20, -- 401
		headY, -- 401
		toColor(PALETTE.xuanInk), -- 401
		0, -- 401
		0.5, -- 401
		"Left", -- 401
		2.4, -- 401
		0.94, -- 401
		0 -- 401
	) -- 401
	texts:put( -- 402
		"xs", -- 402
		"守望行记", -- 402
		inX + inW - 20, -- 402
		headY, -- 402
		toColor(PALETTE.xuanInkSub), -- 402
		1, -- 402
		0.5, -- 402
		"Right", -- 402
		2, -- 402
		0.78, -- 402
		0 -- 402
	) -- 402
	uiInkDraw:drawSegment( -- 403
		Vec2(inX + 14, headY - 22), -- 403
		Vec2(inX + inW - 14, headY - 22), -- 403
		0.85, -- 403
		redSilk -- 403
	) -- 403
	local row1Y = headY - 56 -- 406
	texts:put( -- 407
		"sm", -- 407
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 407
		inX + 20, -- 407
		row1Y, -- 407
		toColor(PALETTE.xuanInk), -- 407
		0, -- 407
		0.5, -- 407
		"Left", -- 407
		0.8, -- 407
		0.94, -- 407
		0 -- 407
	) -- 407
	texts:put( -- 408
		"xs", -- 408
		"附注：护送者留守南城门，托她独自走完余路。", -- 408
		inX + 20, -- 408
		row1Y - 28, -- 408
		toColor(PALETTE.xuanInkSub), -- 408
		0, -- 408
		0.5, -- 408
		"Left", -- 408
		0.6, -- 408
		0.88, -- 408
		0 -- 408
	) -- 408
	uiInkDraw:drawSegment( -- 409
		Vec2(inX + 16, row1Y - 48), -- 409
		Vec2(inX + inW - 16, row1Y - 48), -- 409
		0.65, -- 409
		redSilkFaint -- 409
	) -- 409
	local blankY = row1Y - 80 -- 412
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 413
	texts:put( -- 414
		"sm", -- 414
		"肆拾贰", -- 414
		inX + 20, -- 414
		blankY, -- 414
		toColor(PALETTE.rouge), -- 414
		0, -- 414
		0.5, -- 414
		"Left", -- 414
		1, -- 414
		0.92, -- 414
		0 -- 414
	) -- 414
	uiInkDraw:drawSegment( -- 415
		Vec2(inX + 94, blankY - 7), -- 415
		Vec2(inX + inW - 116, blankY - 7), -- 415
		0.95, -- 415
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 415
	) -- 415
	texts:put( -- 416
		"xs", -- 416
		"（空行留待）", -- 416
		inX + inW - 104, -- 416
		blankY, -- 416
		toColor(PALETTE.xuanInkSub), -- 416
		0, -- 416
		0.5, -- 416
		"Left", -- 416
		1, -- 416
		0.82 * pulse, -- 416
		0 -- 416
	) -- 416
	if p.phase == "tower-end" then -- 416
		local signY = inY + 46 -- 420
		texts:put( -- 421
			"banner", -- 421
			"向西守望", -- 421
			midX - 18, -- 421
			signY, -- 421
			toColor(PALETTE.xuanInk), -- 421
			0.5, -- 421
			0.5, -- 421
			"Center", -- 421
			6.5, -- 421
			0.92, -- 421
			0 -- 421
		) -- 421
		drawLoneSeal( -- 422
			uiInkDraw, -- 422
			art, -- 422
			texts, -- 422
			"reg_lone_seal", -- 422
			midX + 86, -- 422
			signY, -- 422
			22, -- 422
			42, -- 422
			"守", -- 422
			"望", -- 422
			PALETTE.sealRed, -- 422
			PALETTE.sealText, -- 422
			0.92, -- 422
			4 -- 422
		) -- 422
		drawSilkVeil( -- 424
			uiDraw, -- 424
			art, -- 424
			"reg_hint_veil", -- 424
			midX, -- 424
			cy - 28, -- 424
			360, -- 424
			32, -- 424
			PALETTE.inkWash, -- 424
			0.72, -- 424
			0 -- 424
		) -- 424
		texts:put( -- 425
			"xs", -- 425
			"按 E 再次启程     ·     Esc 暂歇", -- 425
			midX, -- 425
			cy - 28, -- 425
			toColor(PALETTE.textMid), -- 425
			0.5, -- 425
			0.5, -- 425
			"Center", -- 425
			1.6, -- 425
			0.92, -- 425
			0.08 -- 425
		) -- 425
	end -- 425
end -- 357
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 429
	local theme = themeOf(roomKey) -- 438
	local t = self.bannerT / self.bannerMax -- 439
	local alpha = 1 -- 440
	if t > 0.82 then -- 440
		alpha = (1 - t) / 0.18 -- 442
	elseif t < 0.28 then -- 442
		alpha = t / 0.28 -- 444
	end -- 444
	local cx = w * 0.5 -- 446
	local cy = h * 0.77 -- 447
	local spread = math.min(1, alpha * 1.15) -- 448
	drawSilkVeil( -- 451
		uiDraw, -- 451
		art, -- 451
		"banner_veil", -- 451
		cx, -- 451
		cy - 2, -- 451
		480 * spread + 100, -- 451
		92, -- 451
		PALETTE.inkWash, -- 451
		0.76 * alpha, -- 451
		-1 -- 451
	) -- 451
	drawMistCurve( -- 452
		art, -- 452
		"banner_mist", -- 452
		cx, -- 452
		cy + 4, -- 452
		460 * spread, -- 452
		72, -- 452
		theme.accent, -- 452
		0.28 * alpha, -- 452
		0 -- 452
	) -- 452
	drawHairline( -- 453
		uiInkDraw, -- 453
		art, -- 453
		"banner_line", -- 453
		cx, -- 453
		cy - 16, -- 453
		320 * spread, -- 453
		PALETTE.silkLine, -- 453
		0.64 * alpha, -- 453
		false, -- 453
		2 -- 453
	) -- 453
	local sep = " · " -- 456
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 457
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 458
	if idx > 0 then -- 458
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 460
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 461
		local lw = visualTextWidth(leftPart, 42) -- 462
		local rw = visualTextWidth(rightPart, 42) -- 463
		local dotGap = 28 -- 464
		local totalW = lw + rw + dotGap -- 465
		local leftEdge = cx - totalW * 0.5 -- 466
		local dotX = leftEdge + lw + dotGap * 0.5 -- 467
		texts:put( -- 469
			"banner", -- 469
			leftPart, -- 469
			leftEdge, -- 469
			cy + 14, -- 469
			toColor(PALETTE.textBright), -- 469
			0, -- 469
			0.5, -- 469
			"Left", -- 469
			2, -- 469
			alpha, -- 469
			0.1 -- 469
		) -- 469
		drawBlossomDot( -- 470
			uiInkDraw, -- 470
			art, -- 470
			"banner_mid_dot", -- 470
			dotX, -- 470
			cy + 12, -- 470
			11, -- 470
			dotCol, -- 470
			0.92 * alpha, -- 470
			4 -- 470
		) -- 470
		texts:put( -- 471
			"banner", -- 471
			rightPart, -- 471
			dotX + dotGap * 0.5, -- 471
			cy + 14, -- 471
			toColor(PALETTE.textBright), -- 471
			0, -- 471
			0.5, -- 471
			"Left", -- 471
			2, -- 471
			alpha, -- 471
			0.1 -- 471
		) -- 471
	else -- 471
		texts:put( -- 473
			"banner", -- 473
			theme.titleZh, -- 473
			cx, -- 473
			cy + 14, -- 473
			toColor(PALETTE.textBright), -- 473
			0.5, -- 473
			0.5, -- 473
			"Center", -- 473
			3, -- 473
			alpha, -- 473
			0.1 -- 473
		) -- 473
	end -- 473
	texts:put( -- 475
		"xs", -- 475
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 475
		cx, -- 475
		cy - 34, -- 475
		toColor(PALETTE.textMid), -- 475
		0.5, -- 475
		0.5, -- 475
		"Center", -- 475
		2.2, -- 475
		0.82 * alpha, -- 475
		0.08 -- 475
	) -- 475
end -- 429
return ____exports -- 429