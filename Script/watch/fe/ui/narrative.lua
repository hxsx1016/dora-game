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
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 50
	local target = wantCinema and 1 or 0 -- 55
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 56
	if self.bannerT > 0 then -- 56
		self.bannerT = math.max(0, self.bannerT - dt) -- 59
	end -- 59
	if self.wipeT > 0 then -- 59
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 62
	end -- 62
end -- 45
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled) -- 66
	if assistHintsEnabled == nil then -- 66
		assistHintsEnabled = false -- 75
	end -- 75
	if self.letterbox > 0.01 then -- 75
		local barH = math.floor(70 * self.letterbox + 0.5) -- 79
		uiDraw:drawRect( -- 80
			Rect(0, h - barH, w, barH), -- 80
			Color(8, 10, 16, 242) -- 80
		) -- 80
		uiDraw:drawRect( -- 81
			Rect(0, 0, w, barH), -- 81
			Color(8, 10, 16, 242) -- 81
		) -- 81
		uiInkDraw:drawSegment( -- 82
			Vec2(0, h - barH), -- 82
			Vec2(w, h - barH), -- 82
			0.7, -- 82
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 82
		) -- 82
		uiInkDraw:drawSegment( -- 83
			Vec2(0, barH), -- 83
			Vec2(w, barH), -- 83
			0.7, -- 83
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 83
		) -- 83
	end -- 83
	if p.room.key == "gate" and p.phase == "gate-count" then -- 83
		self:drawGateCountOverlay( -- 88
			uiDraw, -- 88
			uiInkDraw, -- 88
			art, -- 88
			texts, -- 88
			p, -- 88
			w, -- 88
			h -- 88
		) -- 88
	end -- 88
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 92
	if showRegistry then -- 92
		self:drawTowerRegistryCard( -- 94
			uiDraw, -- 94
			uiInkDraw, -- 94
			uiGlow, -- 94
			art, -- 94
			texts, -- 94
			p, -- 94
			w, -- 94
			h, -- 94
			assistHintsEnabled -- 94
		) -- 94
	end -- 94
	if not p.paused and not showRegistry then -- 94
		self:drawSubtitleStrip( -- 99
			uiDraw, -- 99
			uiInkDraw, -- 99
			art, -- 99
			texts, -- 99
			p, -- 99
			w, -- 99
			h, -- 99
			assistHintsEnabled -- 99
		) -- 99
	end -- 99
	if self.bannerT > 0 and not p.paused then -- 99
		self:drawAreaBanner( -- 104
			uiDraw, -- 104
			uiInkDraw, -- 104
			art, -- 104
			texts, -- 104
			p.room.key, -- 104
			w, -- 104
			h -- 104
		) -- 104
	end -- 104
	if self.wipeT > 0.01 then -- 104
		local k = math.min(1, self.wipeT * 1.15) -- 109
		local a = math.floor(255 * k * k + 0.5) -- 110
		uiDraw:drawRect( -- 111
			Rect(0, 0, w, h), -- 111
			Color(9, 11, 17, a) -- 111
		) -- 111
		art:tryPlace( -- 112
			"ink_petal_mist", -- 112
			"wipe_mist", -- 112
			w * 0.5, -- 112
			h * 0.5, -- 112
			w * 0.65, -- 112
			h * 0.65, -- 112
			{ -- 112
				color = toColor(PALETTE.inkMist), -- 113
				opacity = 0.2 * self.wipeT, -- 113
				layer = 5 -- 113
			} -- 113
		) -- 113
	end -- 113
end -- 66
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled) -- 118
	local line = self:composeNarrativeLine(p, assistHintsEnabled) -- 128
	if line.text == "" then -- 128
		return -- 130
	end -- 130
	local hasCue = line.cue ~= "" -- 132
	local textW = visualTextWidth(line.text, 18) -- 133
	local contentW = textW + (hasCue and 48 or 0) -- 134
	local stripW = math.min( -- 135
		w - 72, -- 135
		math.max(540, contentW + 210) -- 135
	) -- 135
	local stripH = 54 -- 136
	local cx = w * 0.5 -- 137
	local cy = self.letterbox > 0.4 and 36 or 42 -- 138
	drawSilkVeil( -- 141
		uiDraw, -- 141
		art, -- 141
		"sub_veil", -- 141
		cx, -- 141
		cy, -- 141
		stripW, -- 141
		stripH, -- 141
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 141
		0.84, -- 141
		-1 -- 141
	) -- 141
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 143
	drawHairline( -- 144
		uiInkDraw, -- 144
		art, -- 144
		"sub_top_line", -- 144
		cx, -- 144
		cy + 23, -- 144
		stripW * 0.72, -- 144
		railCol, -- 144
		line.urgent and 0.72 or 0.52, -- 144
		true, -- 144
		2 -- 144
	) -- 144
	if hasCue then -- 144
		local startX = cx - contentW * 0.5 -- 147
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 148
		drawBlossomDot( -- 149
			uiInkDraw, -- 149
			art, -- 149
			"sub_cue_dot", -- 149
			startX + 6, -- 149
			cy - 1, -- 149
			10, -- 149
			cueCol, -- 149
			0.94, -- 149
			4 -- 149
		) -- 149
		texts:put( -- 150
			"xs", -- 150
			line.cue, -- 150
			startX + 24, -- 150
			cy - 1, -- 150
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 150
			0.5, -- 150
			0.5, -- 150
			"Center", -- 150
			0, -- 150
			0.96, -- 150
			0.08 -- 150
		) -- 150
		uiInkDraw:drawSegment( -- 151
			Vec2(startX + 38, cy - 8), -- 151
			Vec2(startX + 38, cy + 6), -- 151
			0.75, -- 151
			toColor(PALETTE.silkDim, 115) -- 151
		) -- 151
		texts:put( -- 152
			"sm", -- 152
			line.text, -- 152
			startX + 48, -- 152
			cy - 1, -- 152
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 152
			0, -- 152
			0.5, -- 152
			"Left", -- 152
			0.9, -- 152
			0.98, -- 152
			0.08 -- 152
		) -- 152
	else -- 152
		texts:put( -- 154
			"sm", -- 154
			line.text, -- 154
			cx, -- 154
			cy - 1, -- 154
			toColor(PALETTE.textBright), -- 154
			0.5, -- 154
			0.5, -- 154
			"Center", -- 154
			1, -- 154
			0.98, -- 154
			0.08 -- 154
		) -- 154
	end -- 154
end -- 118
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 159
	local key = p.room.key -- 160
	local theme = themeOf(key) -- 161
	if key == "gate" and p.phase == "gate-count" then -- 161
		if p.countTick >= GATE_COUNT_END then -- 161
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 165
		end -- 165
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 171
	end -- 171
	if not assistHintsEnabled then -- 171
		if key == "prologue" and p.phase == "prologue-give" then -- 171
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 177
		end -- 177
		if key == "checkpoint" and p.escort.state == "calming" then -- 177
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 180
		end -- 180
		if key == "tower" then -- 180
			if p.phase == "tower-knock" then -- 180
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 184
			end -- 184
			if p.phase == "tower-given" then -- 184
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 187
			end -- 187
		end -- 187
		if p.flash ~= "" and p.flashT > 0 then -- 187
			local hasKeyHint = (string.find(p.flash, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "E 再玩", nil, true) or 0) - 1 >= 0 -- 192
			if not hasKeyHint then -- 192
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 198
				local text = p.flash -- 199
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 200
				if key == "tower" or key == "prologue" then -- 200
					cue = "" -- 202
				end -- 202
				if text == "命中" then -- 202
					text = "倭寇击倒" -- 205
				elseif text == "打空" then -- 205
					text = "铅丸偏离或被掩体阻挡" -- 207
				elseif text == "翻滚" then -- 207
					text = "伏身翻滚回避" -- 209
				end -- 209
				return {cue = cue, text = text, urgent = isDanger} -- 211
			end -- 211
		end -- 211
		return {cue = "", text = "", urgent = false} -- 214
	end -- 214
	if key == "gate" and p.phase == "gate-hold" then -- 214
		local threatened = false -- 218
		local hasAliveEnemy = false -- 219
		local i = 0 -- 220
		do -- 220
			i = 0 -- 221
			while i < #p.enemies do -- 221
				if p.enemies[i + 1].alive then -- 221
					hasAliveEnemy = true -- 223
					if p.enemies[i + 1].warnT > 0 then -- 223
						threatened = true -- 225
					end -- 225
				end -- 225
				i = i + 1 -- 221
			end -- 221
		end -- 221
		if threatened then -- 221
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 230
		end -- 230
		if p.coverHug then -- 230
			if hasAliveEnemy and not p.coverBlocking then -- 230
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 234
			end -- 234
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 236
		end -- 236
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 238
	end -- 238
	if key == "gate" and p.phase == "gate-count" then -- 238
		if p.countTick >= GATE_COUNT_END then -- 238
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 243
		end -- 243
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 249
	end -- 249
	if p.flash ~= "" and p.flashT > 0 then -- 249
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 253
		local text = p.flash -- 254
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 255
		if key == "tower" or key == "prologue" then -- 255
			cue = "" -- 257
		end -- 257
		if text == "命中" then -- 257
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 260
		elseif text == "打空" then -- 260
			text = "铅丸偏离或被掩体阻挡" -- 262
		elseif text == "翻滚" then -- 262
			text = "伏身翻滚回避" -- 264
		end -- 264
		return {cue = cue, text = text, urgent = isDanger} -- 266
	end -- 266
	if key == "prologue" then -- 266
		if p.phase == "prologue-wait" then -- 266
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 271
		end -- 271
		if p.phase == "prologue-give" then -- 271
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 274
		end -- 274
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 276
	end -- 276
	if key == "street" then -- 276
		local alive = 0 -- 280
		local i = 0 -- 281
		do -- 281
			i = 0 -- 282
			while i < #p.enemies do -- 282
				if p.enemies[i + 1].alive then -- 282
					alive = alive + 1 -- 283
				end -- 283
				i = i + 1 -- 282
			end -- 282
		end -- 282
		if alive > 0 then -- 282
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 286
		end -- 286
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 288
	end -- 288
	if key == "checkpoint" then -- 288
		if p.escort.state == "frozen" then -- 288
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 293
		end -- 293
		if p.escort.state == "calming" then -- 293
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 296
		end -- 296
		if not p.cartDocked then -- 296
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 299
		end -- 299
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 301
	end -- 301
	if key == "gate" then -- 301
		if p.phase == "gate-idle" then -- 301
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 306
		end -- 306
		if p.phase == "gate-send" then -- 306
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 313
		end -- 313
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 315
	end -- 315
	if key == "outside" then -- 315
		if not p.cartDocked then -- 315
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 320
		end -- 320
		if p.checkpoint < p.room.arch.x1 then -- 320
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 323
		end -- 323
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 325
	end -- 325
	if key == "village" then -- 325
		if p.scavChase then -- 325
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 330
		end -- 330
		if p.passed then -- 330
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 333
		end -- 333
		if p.hasBottle then -- 333
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 336
		end -- 336
		if p.bottleFly ~= nil then -- 336
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 339
		end -- 339
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 339
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 342
		end -- 342
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 344
	end -- 344
	if key == "forest" then -- 344
		if p.dogState == "chase" then -- 344
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 349
		end -- 349
		if p.dogState == "ear" then -- 349
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 352
		end -- 352
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 354
	end -- 354
	if key == "tower" then -- 354
		if p.phase == "tower-wait" then -- 354
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 359
		end -- 359
		if p.phase == "tower-knock" then -- 359
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 362
		end -- 362
		if p.phase == "tower-given" then -- 362
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 365
		end -- 365
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 367
	end -- 367
	return {cue = "", text = theme.introWhisper, urgent = false} -- 370
end -- 159
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 373
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 382
	local countNum = gateCountAtTick(p.countTick) -- 383
	uiDraw:drawRect( -- 384
		Rect(0, 0, w, h), -- 384
		Color( -- 384
			7, -- 384
			9, -- 384
			15, -- 384
			math.floor(78 + frac * 116 + 0.5) -- 384
		) -- 384
	) -- 384
	local cy = h * 0.56 -- 386
	art:tryPlace( -- 387
		"ink_petal_mist", -- 387
		"gate_count_mist", -- 387
		w * 0.5, -- 387
		cy, -- 387
		290, -- 387
		220, -- 387
		{ -- 387
			color = toColor(PALETTE.inkMist), -- 388
			opacity = 0.34 + frac * 0.2, -- 388
			layer = 0 -- 388
		} -- 388
	) -- 388
	drawMistCurve( -- 390
		art, -- 390
		"gate_count_wisp", -- 390
		w * 0.5, -- 390
		cy - 8, -- 390
		420, -- 390
		76, -- 390
		PALETTE.jadeMist, -- 390
		0.22, -- 390
		0 -- 390
	) -- 390
	local numZh = toChineseUpper(countNum) -- 392
	texts:put( -- 393
		"title", -- 393
		numZh, -- 393
		w * 0.5, -- 393
		cy + 8, -- 393
		toColor(PALETTE.textBright), -- 393
		0.5, -- 393
		0.5, -- 393
		"Center", -- 393
		12, -- 393
		0.42 + frac * 0.56, -- 393
		0.1 -- 393
	) -- 393
	drawHairline( -- 394
		uiInkDraw, -- 394
		art, -- 394
		"gate_count_div", -- 394
		w * 0.5, -- 394
		cy - 34, -- 394
		240, -- 394
		PALETTE.silkDim, -- 394
		0.62, -- 394
		true, -- 394
		2 -- 394
	) -- 394
	texts:put( -- 395
		"sm", -- 395
		"城外静候 · 默数至二十", -- 395
		w * 0.5, -- 395
		cy - 58, -- 395
		toColor(PALETTE.textMid), -- 395
		0.5, -- 395
		0.5, -- 395
		"Center", -- 395
		3.4, -- 395
		0.84, -- 395
		0.08 -- 395
	) -- 395
end -- 373
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled) -- 405
	local cardW = 588 -- 416
	local cardH = 382 -- 417
	local cx = (w - cardW) * 0.5 -- 418
	local cy = (h - cardH) * 0.5 + 10 -- 419
	local midX = w * 0.5 -- 420
	local midY = cy + cardH * 0.5 -- 421
	uiDraw:drawRect( -- 424
		Rect(0, 0, w, h), -- 424
		Color(7, 9, 15, 174) -- 424
	) -- 424
	art:tryPlace( -- 425
		"ink_frame_mask", -- 425
		"reg_shadow", -- 425
		midX, -- 425
		midY - 6, -- 425
		cardW + 58, -- 425
		cardH + 50, -- 425
		{ -- 425
			color = toColor(PALETTE.voidDark), -- 426
			opacity = 0.82, -- 426
			layer = -1 -- 426
		} -- 426
	) -- 426
	if not art:tryPlace( -- 426
		"ink_song_paper", -- 430
		"registry_song_paper", -- 430
		midX, -- 430
		midY, -- 430
		cardW, -- 430
		cardH, -- 430
		{opacity = 0.98, layer = 1} -- 430
	) then -- 430
		uiDraw:drawRect( -- 431
			Rect(cx, cy, cardW, cardH), -- 431
			toColor(PALETTE.xuanPaper, 246), -- 431
			1, -- 431
			toColor(PALETTE.silkDim, 180) -- 431
		) -- 431
	end -- 431
	fillRadialGlow( -- 433
		uiGlow, -- 433
		midX, -- 433
		midY + 46, -- 433
		240, -- 433
		130, -- 433
		Color(235, 224, 202, 14), -- 433
		Color(235, 224, 202, 0), -- 433
		14 -- 433
	) -- 433
	local padX = 46 -- 436
	local padY = 36 -- 437
	local inX = cx + padX -- 438
	local inY = cy + padY -- 439
	local inW = cardW - padX * 2 -- 440
	local inH = cardH - padY * 2 -- 441
	local redSilk = toColor(PALETTE.rouge, 118) -- 442
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 443
	uiInkDraw:drawRect( -- 445
		Rect(inX, inY, inW, inH), -- 445
		Color(0, 0, 0, 0), -- 445
		0.9, -- 445
		redSilk -- 445
	) -- 445
	uiInkDraw:drawRect( -- 446
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 446
		Color(0, 0, 0, 0), -- 446
		0.55, -- 446
		redSilkFaint -- 446
	) -- 446
	local headY = inY + inH - 28 -- 449
	texts:put( -- 450
		"md", -- 450
		"北塔入塔登记簿 · 末页", -- 450
		inX + 20, -- 450
		headY, -- 450
		toColor(PALETTE.xuanInk), -- 450
		0, -- 450
		0.5, -- 450
		"Left", -- 450
		2.4, -- 450
		0.94, -- 450
		0 -- 450
	) -- 450
	texts:put( -- 451
		"xs", -- 451
		"守望行记", -- 451
		inX + inW - 20, -- 451
		headY, -- 451
		toColor(PALETTE.xuanInkSub), -- 451
		1, -- 451
		0.5, -- 451
		"Right", -- 451
		2, -- 451
		0.78, -- 451
		0 -- 451
	) -- 451
	uiInkDraw:drawSegment( -- 452
		Vec2(inX + 14, headY - 22), -- 452
		Vec2(inX + inW - 14, headY - 22), -- 452
		0.85, -- 452
		redSilk -- 452
	) -- 452
	local row1Y = headY - 56 -- 455
	texts:put( -- 456
		"sm", -- 456
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 456
		inX + 20, -- 456
		row1Y, -- 456
		toColor(PALETTE.xuanInk), -- 456
		0, -- 456
		0.5, -- 456
		"Left", -- 456
		0.8, -- 456
		0.94, -- 456
		0 -- 456
	) -- 456
	texts:put( -- 457
		"xs", -- 457
		"附注：护送者留守南城门，托她独自走完余路。", -- 457
		inX + 20, -- 457
		row1Y - 28, -- 457
		toColor(PALETTE.xuanInkSub), -- 457
		0, -- 457
		0.5, -- 457
		"Left", -- 457
		0.6, -- 457
		0.88, -- 457
		0 -- 457
	) -- 457
	uiInkDraw:drawSegment( -- 458
		Vec2(inX + 16, row1Y - 48), -- 458
		Vec2(inX + inW - 16, row1Y - 48), -- 458
		0.65, -- 458
		redSilkFaint -- 458
	) -- 458
	local blankY = row1Y - 80 -- 461
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 462
	texts:put( -- 463
		"sm", -- 463
		"肆拾贰", -- 463
		inX + 20, -- 463
		blankY, -- 463
		toColor(PALETTE.rouge), -- 463
		0, -- 463
		0.5, -- 463
		"Left", -- 463
		1, -- 463
		0.92, -- 463
		0 -- 463
	) -- 463
	uiInkDraw:drawSegment( -- 464
		Vec2(inX + 94, blankY - 7), -- 464
		Vec2(inX + inW - 116, blankY - 7), -- 464
		0.95, -- 464
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 464
	) -- 464
	texts:put( -- 465
		"xs", -- 465
		"（空行留待）", -- 465
		inX + inW - 104, -- 465
		blankY, -- 465
		toColor(PALETTE.xuanInkSub), -- 465
		0, -- 465
		0.5, -- 465
		"Left", -- 465
		1, -- 465
		0.82 * pulse, -- 465
		0 -- 465
	) -- 465
	if p.phase == "tower-end" then -- 465
		local signY = inY + 46 -- 469
		texts:put( -- 470
			"banner", -- 470
			"向西守望", -- 470
			midX - 18, -- 470
			signY, -- 470
			toColor(PALETTE.xuanInk), -- 470
			0.5, -- 470
			0.5, -- 470
			"Center", -- 470
			6.5, -- 470
			0.92, -- 470
			0 -- 470
		) -- 470
		drawLoneSeal( -- 471
			uiInkDraw, -- 471
			art, -- 471
			texts, -- 471
			"reg_lone_seal", -- 471
			midX + 86, -- 471
			signY, -- 471
			22, -- 471
			42, -- 471
			"守", -- 471
			"望", -- 471
			PALETTE.sealRed, -- 471
			PALETTE.sealText, -- 471
			0.92, -- 471
			4 -- 471
		) -- 471
		drawSilkVeil( -- 473
			uiDraw, -- 473
			art, -- 473
			"reg_hint_veil", -- 473
			midX, -- 473
			cy - 28, -- 473
			360, -- 473
			32, -- 473
			PALETTE.inkWash, -- 473
			0.72, -- 473
			0 -- 473
		) -- 473
		local endHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 474
		texts:put( -- 475
			"xs", -- 475
			endHint, -- 475
			midX, -- 475
			cy - 28, -- 475
			toColor(PALETTE.textMid), -- 475
			0.5, -- 475
			0.5, -- 475
			"Center", -- 475
			1.6, -- 475
			0.92, -- 475
			0.08 -- 475
		) -- 475
	end -- 475
end -- 405
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 479
	local theme = themeOf(roomKey) -- 488
	local t = self.bannerT / self.bannerMax -- 489
	local alpha = 1 -- 490
	if t > 0.82 then -- 490
		alpha = (1 - t) / 0.18 -- 492
	elseif t < 0.28 then -- 492
		alpha = t / 0.28 -- 494
	end -- 494
	local cx = w * 0.5 -- 496
	local cy = h * 0.77 -- 497
	local spread = math.min(1, alpha * 1.15) -- 498
	drawSilkVeil( -- 501
		uiDraw, -- 501
		art, -- 501
		"banner_veil", -- 501
		cx, -- 501
		cy - 2, -- 501
		480 * spread + 100, -- 501
		92, -- 501
		PALETTE.inkWash, -- 501
		0.76 * alpha, -- 501
		-1 -- 501
	) -- 501
	drawMistCurve( -- 502
		art, -- 502
		"banner_mist", -- 502
		cx, -- 502
		cy + 4, -- 502
		460 * spread, -- 502
		72, -- 502
		theme.accent, -- 502
		0.28 * alpha, -- 502
		0 -- 502
	) -- 502
	drawHairline( -- 503
		uiInkDraw, -- 503
		art, -- 503
		"banner_line", -- 503
		cx, -- 503
		cy - 16, -- 503
		320 * spread, -- 503
		PALETTE.silkLine, -- 503
		0.64 * alpha, -- 503
		false, -- 503
		2 -- 503
	) -- 503
	local sep = " · " -- 506
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 507
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 508
	if theme.backdropKey ~= nil then -- 508
		texts:put( -- 510
			"lg", -- 510
			theme.titleZh, -- 510
			cx, -- 510
			cy + 14, -- 510
			toColor(PALETTE.textBright), -- 510
			0.5, -- 511
			0.5, -- 511
			"Center", -- 511
			1, -- 511
			alpha, -- 511
			0.1 -- 511
		) -- 511
	elseif idx > 0 then -- 511
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 513
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 514
		local lw = visualTextWidth(leftPart, 42) -- 515
		local rw = visualTextWidth(rightPart, 42) -- 516
		local dotGap = 28 -- 517
		local totalW = lw + rw + dotGap -- 518
		local leftEdge = cx - totalW * 0.5 -- 519
		local dotX = leftEdge + lw + dotGap * 0.5 -- 520
		texts:put( -- 522
			"banner", -- 522
			leftPart, -- 522
			leftEdge, -- 522
			cy + 14, -- 522
			toColor(PALETTE.textBright), -- 522
			0, -- 522
			0.5, -- 522
			"Left", -- 522
			2, -- 522
			alpha, -- 522
			0.1 -- 522
		) -- 522
		drawBlossomDot( -- 523
			uiInkDraw, -- 523
			art, -- 523
			"banner_mid_dot", -- 523
			dotX, -- 523
			cy + 12, -- 523
			11, -- 523
			dotCol, -- 523
			0.92 * alpha, -- 523
			4 -- 523
		) -- 523
		texts:put( -- 524
			"banner", -- 524
			rightPart, -- 524
			dotX + dotGap * 0.5, -- 524
			cy + 14, -- 524
			toColor(PALETTE.textBright), -- 524
			0, -- 524
			0.5, -- 524
			"Left", -- 524
			2, -- 524
			alpha, -- 524
			0.1 -- 524
		) -- 524
	else -- 524
		texts:put( -- 526
			"banner", -- 526
			theme.titleZh, -- 526
			cx, -- 526
			cy + 14, -- 526
			toColor(PALETTE.textBright), -- 526
			0.5, -- 526
			0.5, -- 526
			"Center", -- 526
			3, -- 526
			alpha, -- 526
			0.1 -- 526
		) -- 526
	end -- 526
	texts:put( -- 528
		"xs", -- 528
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 528
		cx, -- 528
		cy - 34, -- 528
		toColor(PALETTE.textMid), -- 528
		0.5, -- 528
		0.5, -- 528
		"Center", -- 528
		2.2, -- 528
		0.82 * alpha, -- 528
		0.08 -- 528
	) -- 528
end -- 479
return ____exports -- 479