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
local ____platform = require("Script.watch.platform") -- 12
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 12
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 14
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 14
local ____theme = require("Script.watch.fe.theme") -- 16
local PALETTE = ____theme.PALETTE -- 17
local drawBlossomDot = ____theme.drawBlossomDot -- 18
local drawHairline = ____theme.drawHairline -- 19
local drawLoneSeal = ____theme.drawLoneSeal -- 20
local drawMistCurve = ____theme.drawMistCurve -- 21
local drawSilkVeil = ____theme.drawSilkVeil -- 23
local fillRadialGlow = ____theme.fillRadialGlow -- 24
local themeOf = ____theme.themeOf -- 25
local toChineseUpper = ____theme.toChineseUpper -- 26
local toColor = ____theme.toColor -- 27
local visualTextWidth = ____theme.visualTextWidth -- 28
____exports.NarrativeRenderer = __TS__Class() -- 31
local NarrativeRenderer = ____exports.NarrativeRenderer -- 31
NarrativeRenderer.name = "NarrativeRenderer" -- 31
function NarrativeRenderer.prototype.____constructor(self) -- 31
	self.letterbox = 0 -- 33
	self.bannerT = 0 -- 35
	self.bannerMax = 2.8 -- 36
	self.wipeT = 0 -- 38
	self.lastRoomKey = "" -- 39
	self.time = 0 -- 40
end -- 31
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 42
	self.lastRoomKey = roomKey -- 43
	self.bannerT = self.bannerMax -- 44
	self.wipeT = 1 -- 45
end -- 42
function NarrativeRenderer.prototype.update(self, dt, p) -- 48
	self.time = self.time + dt -- 49
	if self.lastRoomKey ~= p.room.key then -- 49
		self:onEnterRoom(p.room.key) -- 51
	end -- 51
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 53
	local target = wantCinema and 1 or 0 -- 58
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 59
	if self.bannerT > 0 then -- 59
		self.bannerT = math.max(0, self.bannerT - dt) -- 62
	end -- 62
	if self.wipeT > 0 then -- 62
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 65
	end -- 65
end -- 48
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 69
	if assistHintsEnabled == nil then -- 69
		assistHintsEnabled = false -- 78
	end -- 78
	if inputMode == nil then -- 78
		inputMode = "kbm" -- 79
	end -- 79
	if gamepadLayout == nil then -- 79
		gamepadLayout = "xbox" -- 80
	end -- 80
	if safe == nil then -- 80
		safe = ZERO_SAFE_INSETS -- 81
	end -- 81
	if self.letterbox > 0.01 then -- 81
		local barH = math.floor(70 * self.letterbox + 0.5) -- 85
		uiDraw:drawRect( -- 86
			Rect(0, h - barH, w, barH), -- 86
			Color(8, 10, 16, 242) -- 86
		) -- 86
		uiDraw:drawRect( -- 87
			Rect(0, 0, w, barH), -- 87
			Color(8, 10, 16, 242) -- 87
		) -- 87
		uiInkDraw:drawSegment( -- 88
			Vec2(0, h - barH), -- 88
			Vec2(w, h - barH), -- 88
			0.7, -- 88
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 88
		) -- 88
		uiInkDraw:drawSegment( -- 89
			Vec2(0, barH), -- 89
			Vec2(w, barH), -- 89
			0.7, -- 89
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 89
		) -- 89
	end -- 89
	if p.room.key == "gate" and p.phase == "gate-count" then -- 89
		self:drawGateCountOverlay( -- 94
			uiDraw, -- 94
			uiInkDraw, -- 94
			art, -- 94
			texts, -- 94
			p, -- 94
			w, -- 94
			h -- 94
		) -- 94
	end -- 94
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 98
	if showRegistry then -- 98
		self:drawTowerRegistryCard( -- 100
			uiDraw, -- 100
			uiInkDraw, -- 100
			uiGlow, -- 100
			art, -- 100
			texts, -- 100
			p, -- 100
			w, -- 100
			h, -- 100
			assistHintsEnabled, -- 100
			inputMode, -- 100
			gamepadLayout -- 100
		) -- 100
	end -- 100
	if not p.paused and not showRegistry then -- 100
		self:drawSubtitleStrip( -- 105
			uiDraw, -- 105
			uiInkDraw, -- 105
			art, -- 105
			texts, -- 105
			p, -- 105
			w, -- 105
			h, -- 105
			assistHintsEnabled, -- 105
			inputMode, -- 105
			gamepadLayout, -- 105
			safe -- 105
		) -- 105
	end -- 105
	if self.bannerT > 0 and not p.paused then -- 105
		self:drawAreaBanner( -- 110
			uiDraw, -- 110
			uiInkDraw, -- 110
			art, -- 110
			texts, -- 110
			p.room.key, -- 110
			w, -- 110
			h -- 110
		) -- 110
	end -- 110
	if self.wipeT > 0.01 then -- 110
		local k = math.min(1, self.wipeT * 1.15) -- 115
		local a = math.floor(255 * k * k + 0.5) -- 116
		uiDraw:drawRect( -- 117
			Rect(0, 0, w, h), -- 117
			Color(9, 11, 17, a) -- 117
		) -- 117
		art:tryPlace( -- 118
			"ink_petal_mist", -- 118
			"wipe_mist", -- 118
			w * 0.5, -- 118
			h * 0.5, -- 118
			w * 0.65, -- 118
			h * 0.65, -- 118
			{ -- 118
				color = toColor(PALETTE.inkMist), -- 119
				opacity = 0.2 * self.wipeT, -- 119
				layer = 5 -- 119
			} -- 119
		) -- 119
	end -- 119
end -- 69
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 124
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 137
	if rawLine.text == "" then -- 137
		return -- 139
	end -- 139
	local line = { -- 141
		cue = rawLine.cue, -- 142
		text = assistHintsEnabled and adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 143
		urgent = rawLine.urgent -- 144
	} -- 144
	local hasCue = line.cue ~= "" -- 146
	local textW = visualTextWidth(line.text, 18) -- 147
	local contentW = textW + (hasCue and 48 or 0) -- 148
	local stripW = math.min( -- 149
		w - 72 - safe.left - safe.right, -- 149
		math.max(540, contentW + 210) -- 149
	) -- 149
	local stripH = 54 -- 150
	local cx = w * 0.5 -- 151
	local cy = (self.letterbox > 0.4 and 36 or 42) + safe.bottom * 0.5 -- 152
	drawSilkVeil( -- 155
		uiDraw, -- 155
		art, -- 155
		"sub_veil", -- 155
		cx, -- 155
		cy, -- 155
		stripW, -- 155
		stripH, -- 155
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 155
		0.84, -- 155
		-1 -- 155
	) -- 155
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 157
	drawHairline( -- 158
		uiInkDraw, -- 158
		art, -- 158
		"sub_top_line", -- 158
		cx, -- 158
		cy + 23, -- 158
		stripW * 0.72, -- 158
		railCol, -- 158
		line.urgent and 0.72 or 0.52, -- 158
		true, -- 158
		2 -- 158
	) -- 158
	if hasCue then -- 158
		local startX = cx - contentW * 0.5 -- 161
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 162
		drawBlossomDot( -- 163
			uiInkDraw, -- 163
			art, -- 163
			"sub_cue_dot", -- 163
			startX + 6, -- 163
			cy - 1, -- 163
			10, -- 163
			cueCol, -- 163
			0.94, -- 163
			4 -- 163
		) -- 163
		texts:put( -- 164
			"xs", -- 164
			line.cue, -- 164
			startX + 24, -- 164
			cy - 1, -- 164
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 164
			0.5, -- 164
			0.5, -- 164
			"Center", -- 164
			0, -- 164
			0.96, -- 164
			0.08 -- 164
		) -- 164
		uiInkDraw:drawSegment( -- 165
			Vec2(startX + 38, cy - 8), -- 165
			Vec2(startX + 38, cy + 6), -- 165
			0.75, -- 165
			toColor(PALETTE.silkDim, 115) -- 165
		) -- 165
		texts:put( -- 166
			"sm", -- 166
			line.text, -- 166
			startX + 48, -- 166
			cy - 1, -- 166
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 166
			0, -- 166
			0.5, -- 166
			"Left", -- 166
			0.9, -- 166
			0.98, -- 166
			0.08 -- 166
		) -- 166
	else -- 166
		texts:put( -- 168
			"sm", -- 168
			line.text, -- 168
			cx, -- 168
			cy - 1, -- 168
			toColor(PALETTE.textBright), -- 168
			0.5, -- 168
			0.5, -- 168
			"Center", -- 168
			1, -- 168
			0.98, -- 168
			0.08 -- 168
		) -- 168
	end -- 168
end -- 124
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 173
	local key = p.room.key -- 174
	local theme = themeOf(key) -- 175
	if key == "gate" and p.phase == "gate-count" then -- 175
		if p.countTick >= GATE_COUNT_END then -- 175
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 179
		end -- 179
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 185
	end -- 185
	if not assistHintsEnabled then -- 185
		if key == "prologue" and p.phase == "prologue-give" then -- 185
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 191
		end -- 191
		if key == "checkpoint" and p.escort.state == "calming" then -- 191
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 194
		end -- 194
		if key == "tower" then -- 194
			if p.phase == "tower-knock" then -- 194
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 198
			end -- 198
			if p.phase == "tower-given" then -- 198
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 201
			end -- 201
		end -- 201
		if p.flash ~= "" and p.flashT > 0 then -- 201
			local hasKeyHint = (string.find(p.flash, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "E 再玩", nil, true) or 0) - 1 >= 0 -- 206
			if not hasKeyHint then -- 206
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 212
				local text = p.flash -- 213
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 214
				if key == "tower" or key == "prologue" then -- 214
					cue = "" -- 216
				end -- 216
				if text == "命中" then -- 216
					text = "倭寇击倒" -- 219
				elseif text == "打空" then -- 219
					text = "铅丸偏离或被掩体阻挡" -- 221
				elseif text == "翻滚" then -- 221
					text = "伏身翻滚回避" -- 223
				end -- 223
				return {cue = cue, text = text, urgent = isDanger} -- 225
			end -- 225
		end -- 225
		return {cue = "", text = "", urgent = false} -- 228
	end -- 228
	if key == "gate" and p.phase == "gate-hold" then -- 228
		local threatened = false -- 232
		local hasAliveEnemy = false -- 233
		local i = 0 -- 234
		do -- 234
			i = 0 -- 235
			while i < #p.enemies do -- 235
				if p.enemies[i + 1].alive then -- 235
					hasAliveEnemy = true -- 237
					if p.enemies[i + 1].warnT > 0 then -- 237
						threatened = true -- 239
					end -- 239
				end -- 239
				i = i + 1 -- 235
			end -- 235
		end -- 235
		if threatened then -- 235
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 244
		end -- 244
		if p.coverHug then -- 244
			if hasAliveEnemy and not p.coverBlocking then -- 244
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 248
			end -- 248
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 250
		end -- 250
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 252
	end -- 252
	if key == "gate" and p.phase == "gate-count" then -- 252
		if p.countTick >= GATE_COUNT_END then -- 252
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 257
		end -- 257
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 263
	end -- 263
	if p.flash ~= "" and p.flashT > 0 then -- 263
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 267
		local text = p.flash -- 268
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 269
		if key == "tower" or key == "prologue" then -- 269
			cue = "" -- 271
		end -- 271
		if text == "命中" then -- 271
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 274
		elseif text == "打空" then -- 274
			text = "铅丸偏离或被掩体阻挡" -- 276
		elseif text == "翻滚" then -- 276
			text = "伏身翻滚回避" -- 278
		end -- 278
		return {cue = cue, text = text, urgent = isDanger} -- 280
	end -- 280
	if key == "prologue" then -- 280
		if p.phase == "prologue-wait" then -- 280
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 285
		end -- 285
		if p.phase == "prologue-give" then -- 285
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 288
		end -- 288
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 290
	end -- 290
	if key == "street" then -- 290
		local alive = 0 -- 294
		local i = 0 -- 295
		do -- 295
			i = 0 -- 296
			while i < #p.enemies do -- 296
				if p.enemies[i + 1].alive then -- 296
					alive = alive + 1 -- 297
				end -- 297
				i = i + 1 -- 296
			end -- 296
		end -- 296
		if alive > 0 then -- 296
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 300
		end -- 300
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 302
	end -- 302
	if key == "checkpoint" then -- 302
		if p.escort.state == "frozen" then -- 302
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 307
		end -- 307
		if p.escort.state == "calming" then -- 307
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 310
		end -- 310
		if not p.cartDocked then -- 310
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 313
		end -- 313
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 315
	end -- 315
	if key == "gate" then -- 315
		if p.phase == "gate-idle" then -- 315
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 320
		end -- 320
		if p.phase == "gate-send" then -- 320
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 327
		end -- 327
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 329
	end -- 329
	if key == "outside" then -- 329
		if not p.cartDocked then -- 329
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 334
		end -- 334
		if p.checkpoint < p.room.arch.x1 then -- 334
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 337
		end -- 337
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 339
	end -- 339
	if key == "village" then -- 339
		if p.scavChase then -- 339
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 344
		end -- 344
		if p.passed then -- 344
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 347
		end -- 347
		if p.hasBottle then -- 347
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 350
		end -- 350
		if p.bottleFly ~= nil then -- 350
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 353
		end -- 353
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 353
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 356
		end -- 356
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 358
	end -- 358
	if key == "forest" then -- 358
		if p.dogState == "chase" then -- 358
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 363
		end -- 363
		if p.dogState == "ear" then -- 363
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 366
		end -- 366
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 368
	end -- 368
	if key == "tower" then -- 368
		if p.phase == "tower-wait" then -- 368
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 373
		end -- 373
		if p.phase == "tower-knock" then -- 373
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 376
		end -- 376
		if p.phase == "tower-given" then -- 376
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 379
		end -- 379
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 381
	end -- 381
	return {cue = "", text = theme.introWhisper, urgent = false} -- 384
end -- 173
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 387
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 396
	local countNum = gateCountAtTick(p.countTick) -- 397
	uiDraw:drawRect( -- 398
		Rect(0, 0, w, h), -- 398
		Color( -- 398
			7, -- 398
			9, -- 398
			15, -- 398
			math.floor(78 + frac * 116 + 0.5) -- 398
		) -- 398
	) -- 398
	local cy = h * 0.56 -- 400
	art:tryPlace( -- 401
		"ink_petal_mist", -- 401
		"gate_count_mist", -- 401
		w * 0.5, -- 401
		cy, -- 401
		290, -- 401
		220, -- 401
		{ -- 401
			color = toColor(PALETTE.inkMist), -- 402
			opacity = 0.34 + frac * 0.2, -- 402
			layer = 0 -- 402
		} -- 402
	) -- 402
	drawMistCurve( -- 404
		art, -- 404
		"gate_count_wisp", -- 404
		w * 0.5, -- 404
		cy - 8, -- 404
		420, -- 404
		76, -- 404
		PALETTE.jadeMist, -- 404
		0.22, -- 404
		0 -- 404
	) -- 404
	local numZh = toChineseUpper(countNum) -- 406
	texts:put( -- 407
		"title", -- 407
		numZh, -- 407
		w * 0.5, -- 407
		cy + 8, -- 407
		toColor(PALETTE.textBright), -- 407
		0.5, -- 407
		0.5, -- 407
		"Center", -- 407
		12, -- 407
		0.42 + frac * 0.56, -- 407
		0.1 -- 407
	) -- 407
	drawHairline( -- 408
		uiInkDraw, -- 408
		art, -- 408
		"gate_count_div", -- 408
		w * 0.5, -- 408
		cy - 34, -- 408
		240, -- 408
		PALETTE.silkDim, -- 408
		0.62, -- 408
		true, -- 408
		2 -- 408
	) -- 408
	texts:put( -- 409
		"sm", -- 409
		"城外静候 · 默数至二十", -- 409
		w * 0.5, -- 409
		cy - 58, -- 409
		toColor(PALETTE.textMid), -- 409
		0.5, -- 409
		0.5, -- 409
		"Center", -- 409
		3.4, -- 409
		0.84, -- 409
		0.08 -- 409
	) -- 409
end -- 387
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 419
	local cardW = 588 -- 432
	local cardH = 382 -- 433
	local cx = (w - cardW) * 0.5 -- 434
	local cy = (h - cardH) * 0.5 + 10 -- 435
	local midX = w * 0.5 -- 436
	local midY = cy + cardH * 0.5 -- 437
	uiDraw:drawRect( -- 440
		Rect(0, 0, w, h), -- 440
		Color(7, 9, 15, 174) -- 440
	) -- 440
	art:tryPlace( -- 441
		"ink_frame_mask", -- 441
		"reg_shadow", -- 441
		midX, -- 441
		midY - 6, -- 441
		cardW + 58, -- 441
		cardH + 50, -- 441
		{ -- 441
			color = toColor(PALETTE.voidDark), -- 442
			opacity = 0.82, -- 442
			layer = -1 -- 442
		} -- 442
	) -- 442
	if not art:tryPlace( -- 442
		"ink_song_paper", -- 446
		"registry_song_paper", -- 446
		midX, -- 446
		midY, -- 446
		cardW, -- 446
		cardH, -- 446
		{opacity = 0.98, layer = 1} -- 446
	) then -- 446
		uiDraw:drawRect( -- 447
			Rect(cx, cy, cardW, cardH), -- 447
			toColor(PALETTE.xuanPaper, 246), -- 447
			1, -- 447
			toColor(PALETTE.silkDim, 180) -- 447
		) -- 447
	end -- 447
	fillRadialGlow( -- 449
		uiGlow, -- 449
		midX, -- 449
		midY + 46, -- 449
		240, -- 449
		130, -- 449
		Color(235, 224, 202, 14), -- 449
		Color(235, 224, 202, 0), -- 449
		14 -- 449
	) -- 449
	local padX = 46 -- 452
	local padY = 36 -- 453
	local inX = cx + padX -- 454
	local inY = cy + padY -- 455
	local inW = cardW - padX * 2 -- 456
	local inH = cardH - padY * 2 -- 457
	local redSilk = toColor(PALETTE.rouge, 118) -- 458
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 459
	uiInkDraw:drawRect( -- 461
		Rect(inX, inY, inW, inH), -- 461
		Color(0, 0, 0, 0), -- 461
		0.9, -- 461
		redSilk -- 461
	) -- 461
	uiInkDraw:drawRect( -- 462
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 462
		Color(0, 0, 0, 0), -- 462
		0.55, -- 462
		redSilkFaint -- 462
	) -- 462
	local headY = inY + inH - 28 -- 465
	texts:put( -- 466
		"md", -- 466
		"北塔入塔登记簿 · 末页", -- 466
		inX + 20, -- 466
		headY, -- 466
		toColor(PALETTE.xuanInk), -- 466
		0, -- 466
		0.5, -- 466
		"Left", -- 466
		2.4, -- 466
		0.94, -- 466
		0 -- 466
	) -- 466
	texts:put( -- 467
		"xs", -- 467
		"守望行记", -- 467
		inX + inW - 20, -- 467
		headY, -- 467
		toColor(PALETTE.xuanInkSub), -- 467
		1, -- 467
		0.5, -- 467
		"Right", -- 467
		2, -- 467
		0.78, -- 467
		0 -- 467
	) -- 467
	uiInkDraw:drawSegment( -- 468
		Vec2(inX + 14, headY - 22), -- 468
		Vec2(inX + inW - 14, headY - 22), -- 468
		0.85, -- 468
		redSilk -- 468
	) -- 468
	local row1Y = headY - 56 -- 471
	texts:put( -- 472
		"sm", -- 472
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 472
		inX + 20, -- 472
		row1Y, -- 472
		toColor(PALETTE.xuanInk), -- 472
		0, -- 472
		0.5, -- 472
		"Left", -- 472
		0.8, -- 472
		0.94, -- 472
		0 -- 472
	) -- 472
	texts:put( -- 473
		"xs", -- 473
		"附注：护送者留守南城门，托她独自走完余路。", -- 473
		inX + 20, -- 473
		row1Y - 28, -- 473
		toColor(PALETTE.xuanInkSub), -- 473
		0, -- 473
		0.5, -- 473
		"Left", -- 473
		0.6, -- 473
		0.88, -- 473
		0 -- 473
	) -- 473
	uiInkDraw:drawSegment( -- 474
		Vec2(inX + 16, row1Y - 48), -- 474
		Vec2(inX + inW - 16, row1Y - 48), -- 474
		0.65, -- 474
		redSilkFaint -- 474
	) -- 474
	local blankY = row1Y - 80 -- 477
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 478
	texts:put( -- 479
		"sm", -- 479
		"肆拾贰", -- 479
		inX + 20, -- 479
		blankY, -- 479
		toColor(PALETTE.rouge), -- 479
		0, -- 479
		0.5, -- 479
		"Left", -- 479
		1, -- 479
		0.92, -- 479
		0 -- 479
	) -- 479
	uiInkDraw:drawSegment( -- 480
		Vec2(inX + 94, blankY - 7), -- 480
		Vec2(inX + inW - 116, blankY - 7), -- 480
		0.95, -- 480
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 480
	) -- 480
	texts:put( -- 481
		"xs", -- 481
		"（空行留待）", -- 481
		inX + inW - 104, -- 481
		blankY, -- 481
		toColor(PALETTE.xuanInkSub), -- 481
		0, -- 481
		0.5, -- 481
		"Left", -- 481
		1, -- 481
		0.82 * pulse, -- 481
		0 -- 481
	) -- 481
	if p.phase == "tower-end" then -- 481
		local signY = inY + 46 -- 485
		texts:put( -- 486
			"banner", -- 486
			"向西守望", -- 486
			midX - 18, -- 486
			signY, -- 486
			toColor(PALETTE.xuanInk), -- 486
			0.5, -- 486
			0.5, -- 486
			"Center", -- 486
			6.5, -- 486
			0.92, -- 486
			0 -- 486
		) -- 486
		drawLoneSeal( -- 487
			uiInkDraw, -- 487
			art, -- 487
			texts, -- 487
			"reg_lone_seal", -- 487
			midX + 86, -- 487
			signY, -- 487
			22, -- 487
			42, -- 487
			"守", -- 487
			"望", -- 487
			PALETTE.sealRed, -- 487
			PALETTE.sealText, -- 487
			0.92, -- 487
			4 -- 487
		) -- 487
		drawSilkVeil( -- 489
			uiDraw, -- 489
			art, -- 489
			"reg_hint_veil", -- 489
			midX, -- 489
			cy - 28, -- 489
			360, -- 489
			32, -- 489
			PALETTE.inkWash, -- 489
			0.72, -- 489
			0 -- 489
		) -- 489
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 490
		local endHint = adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 491
		texts:put( -- 492
			"xs", -- 492
			endHint, -- 492
			midX, -- 492
			cy - 28, -- 492
			toColor(PALETTE.textMid), -- 492
			0.5, -- 492
			0.5, -- 492
			"Center", -- 492
			1.6, -- 492
			0.92, -- 492
			0.08 -- 492
		) -- 492
	end -- 492
end -- 419
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 496
	local theme = themeOf(roomKey) -- 505
	local t = self.bannerT / self.bannerMax -- 506
	local alpha = 1 -- 507
	if t > 0.82 then -- 507
		alpha = (1 - t) / 0.18 -- 509
	elseif t < 0.28 then -- 509
		alpha = t / 0.28 -- 511
	end -- 511
	local cx = w * 0.5 -- 513
	local cy = h * 0.77 -- 514
	local spread = math.min(1, alpha * 1.15) -- 515
	drawSilkVeil( -- 518
		uiDraw, -- 518
		art, -- 518
		"banner_veil", -- 518
		cx, -- 518
		cy - 2, -- 518
		480 * spread + 100, -- 518
		92, -- 518
		PALETTE.inkWash, -- 518
		0.76 * alpha, -- 518
		-1 -- 518
	) -- 518
	drawMistCurve( -- 519
		art, -- 519
		"banner_mist", -- 519
		cx, -- 519
		cy + 4, -- 519
		460 * spread, -- 519
		72, -- 519
		theme.accent, -- 519
		0.28 * alpha, -- 519
		0 -- 519
	) -- 519
	drawHairline( -- 520
		uiInkDraw, -- 520
		art, -- 520
		"banner_line", -- 520
		cx, -- 520
		cy - 16, -- 520
		320 * spread, -- 520
		PALETTE.silkLine, -- 520
		0.64 * alpha, -- 520
		false, -- 520
		2 -- 520
	) -- 520
	local sep = " · " -- 523
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 524
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 525
	if theme.backdropKey ~= nil then -- 525
		texts:put( -- 527
			"lg", -- 527
			theme.titleZh, -- 527
			cx, -- 527
			cy + 14, -- 527
			toColor(PALETTE.textBright), -- 527
			0.5, -- 528
			0.5, -- 528
			"Center", -- 528
			1, -- 528
			alpha, -- 528
			0.1 -- 528
		) -- 528
	elseif idx > 0 then -- 528
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 530
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 531
		local lw = visualTextWidth(leftPart, 42) -- 532
		local rw = visualTextWidth(rightPart, 42) -- 533
		local dotGap = 28 -- 534
		local totalW = lw + rw + dotGap -- 535
		local leftEdge = cx - totalW * 0.5 -- 536
		local dotX = leftEdge + lw + dotGap * 0.5 -- 537
		texts:put( -- 539
			"banner", -- 539
			leftPart, -- 539
			leftEdge, -- 539
			cy + 14, -- 539
			toColor(PALETTE.textBright), -- 539
			0, -- 539
			0.5, -- 539
			"Left", -- 539
			2, -- 539
			alpha, -- 539
			0.1 -- 539
		) -- 539
		drawBlossomDot( -- 540
			uiInkDraw, -- 540
			art, -- 540
			"banner_mid_dot", -- 540
			dotX, -- 540
			cy + 12, -- 540
			11, -- 540
			dotCol, -- 540
			0.92 * alpha, -- 540
			4 -- 540
		) -- 540
		texts:put( -- 541
			"banner", -- 541
			rightPart, -- 541
			dotX + dotGap * 0.5, -- 541
			cy + 14, -- 541
			toColor(PALETTE.textBright), -- 541
			0, -- 541
			0.5, -- 541
			"Left", -- 541
			2, -- 541
			alpha, -- 541
			0.1 -- 541
		) -- 541
	else -- 541
		texts:put( -- 543
			"banner", -- 543
			theme.titleZh, -- 543
			cx, -- 543
			cy + 14, -- 543
			toColor(PALETTE.textBright), -- 543
			0.5, -- 543
			0.5, -- 543
			"Center", -- 543
			3, -- 543
			alpha, -- 543
			0.1 -- 543
		) -- 543
	end -- 543
	texts:put( -- 545
		"xs", -- 545
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 545
		cx, -- 545
		cy - 34, -- 545
		toColor(PALETTE.textMid), -- 545
		0.5, -- 545
		0.5, -- 545
		"Center", -- 545
		2.2, -- 545
		0.82 * alpha, -- 545
		0.08 -- 545
	) -- 545
end -- 496
return ____exports -- 496