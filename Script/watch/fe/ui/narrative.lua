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
	if self.lastRoomKey ~= p.room.key then -- 50
		self:onEnterRoom(p.room.key) -- 51
	end -- 51
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 53
	local target = wantCinema and 1 or 0 -- 58
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 59
	if self.bannerT > 0 then -- 61
		self.bannerT = math.max(0, self.bannerT - dt) -- 62
	end -- 62
	if self.wipeT > 0 then -- 64
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 65
	end -- 65
end -- 48
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 69
	if assistHintsEnabled == nil then -- 78
		assistHintsEnabled = false -- 78
	end -- 78
	if inputMode == nil then -- 79
		inputMode = "kbm" -- 79
	end -- 79
	if gamepadLayout == nil then -- 80
		gamepadLayout = "xbox" -- 80
	end -- 80
	if safe == nil then -- 81
		safe = ZERO_SAFE_INSETS -- 81
	end -- 81
	if self.letterbox > 0.01 then -- 84
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
	if p.room.key == "gate" and p.phase == "gate-count" then -- 93
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
	if showRegistry then -- 99
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
	if not p.paused and not showRegistry then -- 104
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
	if self.bannerT > 0 and not p.paused then -- 109
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
	if self.wipeT > 0.01 then -- 114
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
	if rawLine.text == "" then -- 138
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
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 152
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 153
	drawSilkVeil( -- 156
		uiDraw, -- 156
		art, -- 156
		"sub_veil", -- 156
		cx, -- 156
		cy, -- 156
		stripW, -- 156
		stripH, -- 156
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 156
		0.84, -- 156
		-1 -- 156
	) -- 156
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 158
	drawHairline( -- 159
		uiInkDraw, -- 159
		art, -- 159
		"sub_top_line", -- 159
		cx, -- 159
		cy + 23, -- 159
		stripW * 0.72, -- 159
		railCol, -- 159
		line.urgent and 0.72 or 0.52, -- 159
		true, -- 159
		2 -- 159
	) -- 159
	if hasCue then -- 161
		local startX = cx - contentW * 0.5 -- 162
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 163
		drawBlossomDot( -- 164
			uiInkDraw, -- 164
			art, -- 164
			"sub_cue_dot", -- 164
			startX + 6, -- 164
			cy - 1, -- 164
			10, -- 164
			cueCol, -- 164
			0.94, -- 164
			4 -- 164
		) -- 164
		texts:put( -- 165
			"xs", -- 165
			line.cue, -- 165
			startX + 24, -- 165
			cy - 1, -- 165
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 165
			0.5, -- 165
			0.5, -- 165
			"Center", -- 165
			0, -- 165
			0.96, -- 165
			0.08 -- 165
		) -- 165
		uiInkDraw:drawSegment( -- 166
			Vec2(startX + 38, cy - 8), -- 166
			Vec2(startX + 38, cy + 6), -- 166
			0.75, -- 166
			toColor(PALETTE.silkDim, 115) -- 166
		) -- 166
		texts:put( -- 167
			"sm", -- 167
			line.text, -- 167
			startX + 48, -- 167
			cy - 1, -- 167
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 167
			0, -- 167
			0.5, -- 167
			"Left", -- 167
			0.9, -- 167
			0.98, -- 167
			0.08 -- 167
		) -- 167
	else -- 167
		texts:put( -- 169
			"sm", -- 169
			line.text, -- 169
			cx, -- 169
			cy - 1, -- 169
			toColor(PALETTE.textBright), -- 169
			0.5, -- 169
			0.5, -- 169
			"Center", -- 169
			1, -- 169
			0.98, -- 169
			0.08 -- 169
		) -- 169
	end -- 169
end -- 124
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 174
	local key = p.room.key -- 175
	local theme = themeOf(key) -- 176
	if key == "gate" and p.phase == "gate-count" then -- 178
		if p.countTick >= GATE_COUNT_END then -- 179
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 180
		end -- 180
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 186
	end -- 186
	if not assistHintsEnabled then -- 189
		if key == "prologue" and p.phase == "prologue-give" then -- 191
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 192
		end -- 192
		if key == "checkpoint" and p.escort.state == "calming" then -- 194
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 195
		end -- 195
		if key == "tower" then -- 197
			if p.phase == "tower-knock" then -- 198
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 199
			end -- 199
			if p.phase == "tower-given" then -- 201
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 202
			end -- 202
		end -- 202
		if p.flash ~= "" and p.flashT > 0 then -- 205
			local fl = p.flash -- 207
			local hasKeyHint = (string.find(fl, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(fl, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(fl, "限时", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 1", nil, true) or 0) - 1 >= 0 -- 208
			if not hasKeyHint then -- 226
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 227
				local text = p.flash -- 228
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 229
				if key == "tower" or key == "prologue" then -- 230
					cue = "" -- 231
				end -- 231
				if text == "命中" then -- 233
					text = "倭寇击倒" -- 234
				elseif text == "打空" then -- 235
					text = "铅丸偏离或被掩体阻挡" -- 236
				elseif text == "翻滚" then -- 237
					text = "伏身翻滚回避" -- 238
				end -- 238
				return {cue = cue, text = text, urgent = isDanger} -- 240
			end -- 240
		end -- 240
		return {cue = "", text = "", urgent = false} -- 243
	end -- 243
	if key == "gate" and p.phase == "gate-hold" then -- 246
		local threatened = false -- 247
		local hasAliveEnemy = false -- 248
		local i = 0 -- 249
		do -- 249
			i = 0 -- 250
			while i < #p.enemies do -- 250
				if p.enemies[i + 1].alive then -- 251
					hasAliveEnemy = true -- 252
					if p.enemies[i + 1].warnT > 0 then -- 253
						threatened = true -- 254
					end -- 254
				end -- 254
				i = i + 1 -- 250
			end -- 250
		end -- 250
		if threatened then -- 258
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 259
		end -- 259
		if p.coverHug then -- 261
			if hasAliveEnemy and not p.coverBlocking then -- 262
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 263
			end -- 263
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 265
		end -- 265
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 267
	end -- 267
	if key == "gate" and p.phase == "gate-count" then -- 270
		if p.countTick >= GATE_COUNT_END then -- 271
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 272
		end -- 272
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 278
	end -- 278
	if p.flash ~= "" and p.flashT > 0 then -- 281
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 282
		local text = p.flash -- 283
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 284
		if key == "tower" or key == "prologue" then -- 285
			cue = "" -- 286
		end -- 286
		if text == "命中" then -- 288
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 289
		elseif text == "打空" then -- 290
			text = "铅丸偏离或被掩体阻挡" -- 291
		elseif text == "翻滚" then -- 292
			text = "伏身翻滚回避" -- 293
		end -- 293
		return {cue = cue, text = text, urgent = isDanger} -- 295
	end -- 295
	if key == "prologue" then -- 298
		if p.phase == "prologue-wait" then -- 299
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 300
		end -- 300
		if p.phase == "prologue-give" then -- 302
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 303
		end -- 303
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 305
	end -- 305
	if key == "street" then -- 308
		local alive = 0 -- 309
		local i = 0 -- 310
		do -- 310
			i = 0 -- 311
			while i < #p.enemies do -- 311
				if p.enemies[i + 1].alive then -- 312
					alive = alive + 1 -- 312
				end -- 312
				i = i + 1 -- 311
			end -- 311
		end -- 311
		if alive > 0 then -- 314
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 315
		end -- 315
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 317
	end -- 317
	if key == "checkpoint" then -- 320
		if p.escort.state == "frozen" then -- 321
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 322
		end -- 322
		if p.escort.state == "calming" then -- 324
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 325
		end -- 325
		if not p.cartDocked then -- 327
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 328
		end -- 328
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 330
	end -- 330
	if key == "gate" then -- 333
		if p.phase == "gate-idle" then -- 334
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 335
		end -- 335
		if p.phase == "gate-send" then -- 341
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 342
		end -- 342
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 344
	end -- 344
	if key == "outside" then -- 347
		if not p.cartDocked then -- 348
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 349
		end -- 349
		if p.checkpoint < p.room.arch.x1 then -- 351
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 352
		end -- 352
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 354
	end -- 354
	if key == "village" then -- 357
		if p.scavChase then -- 358
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 359
		end -- 359
		if p.passed then -- 361
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 362
		end -- 362
		if p.hasBottle then -- 364
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 365
		end -- 365
		if p.bottleFly ~= nil then -- 367
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 368
		end -- 368
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 370
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 371
		end -- 371
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 373
	end -- 373
	if key == "forest" then -- 376
		if p.dogState == "chase" then -- 377
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 378
		end -- 378
		if p.dogState == "ear" then -- 380
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 381
		end -- 381
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 383
	end -- 383
	if key == "tower" then -- 386
		if p.phase == "tower-wait" then -- 387
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 388
		end -- 388
		if p.phase == "tower-knock" then -- 390
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 391
		end -- 391
		if p.phase == "tower-given" then -- 393
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 394
		end -- 394
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 396
	end -- 396
	return {cue = "", text = theme.introWhisper, urgent = false} -- 399
end -- 174
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 402
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 411
	local countNum = gateCountAtTick(p.countTick) -- 412
	uiDraw:drawRect( -- 413
		Rect(0, 0, w, h), -- 413
		Color( -- 413
			7, -- 413
			9, -- 413
			15, -- 413
			math.floor(78 + frac * 116 + 0.5) -- 413
		) -- 413
	) -- 413
	local cy = h * 0.56 -- 415
	art:tryPlace( -- 416
		"ink_petal_mist", -- 416
		"gate_count_mist", -- 416
		w * 0.5, -- 416
		cy, -- 416
		290, -- 416
		220, -- 416
		{ -- 416
			color = toColor(PALETTE.inkMist), -- 417
			opacity = 0.34 + frac * 0.2, -- 417
			layer = 0 -- 417
		} -- 417
	) -- 417
	drawMistCurve( -- 419
		art, -- 419
		"gate_count_wisp", -- 419
		w * 0.5, -- 419
		cy - 8, -- 419
		420, -- 419
		76, -- 419
		PALETTE.jadeMist, -- 419
		0.22, -- 419
		0 -- 419
	) -- 419
	local numZh = toChineseUpper(countNum) -- 421
	texts:put( -- 422
		"title", -- 422
		numZh, -- 422
		w * 0.5, -- 422
		cy + 8, -- 422
		toColor(PALETTE.textBright), -- 422
		0.5, -- 422
		0.5, -- 422
		"Center", -- 422
		12, -- 422
		0.42 + frac * 0.56, -- 422
		0.1 -- 422
	) -- 422
	drawHairline( -- 423
		uiInkDraw, -- 423
		art, -- 423
		"gate_count_div", -- 423
		w * 0.5, -- 423
		cy - 34, -- 423
		240, -- 423
		PALETTE.silkDim, -- 423
		0.62, -- 423
		true, -- 423
		2 -- 423
	) -- 423
	texts:put( -- 424
		"sm", -- 424
		"城外静候 · 默数至二十", -- 424
		w * 0.5, -- 424
		cy - 58, -- 424
		toColor(PALETTE.textMid), -- 424
		0.5, -- 424
		0.5, -- 424
		"Center", -- 424
		3.4, -- 424
		0.84, -- 424
		0.08 -- 424
	) -- 424
end -- 402
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 434
	local cardW = 588 -- 447
	local cardH = 382 -- 448
	local cx = (w - cardW) * 0.5 -- 449
	local cy = (h - cardH) * 0.5 + 10 -- 450
	local midX = w * 0.5 -- 451
	local midY = cy + cardH * 0.5 -- 452
	uiDraw:drawRect( -- 455
		Rect(0, 0, w, h), -- 455
		Color(7, 9, 15, 174) -- 455
	) -- 455
	art:tryPlace( -- 456
		"ink_frame_mask", -- 456
		"reg_shadow", -- 456
		midX, -- 456
		midY - 6, -- 456
		cardW + 58, -- 456
		cardH + 50, -- 456
		{ -- 456
			color = toColor(PALETTE.voidDark), -- 457
			opacity = 0.82, -- 457
			layer = -1 -- 457
		} -- 457
	) -- 457
	if not art:tryPlace( -- 461
		"ink_song_paper", -- 461
		"registry_song_paper", -- 461
		midX, -- 461
		midY, -- 461
		cardW, -- 461
		cardH, -- 461
		{opacity = 0.98, layer = 1} -- 461
	) then -- 461
		uiDraw:drawRect( -- 462
			Rect(cx, cy, cardW, cardH), -- 462
			toColor(PALETTE.xuanPaper, 246), -- 462
			1, -- 462
			toColor(PALETTE.silkDim, 180) -- 462
		) -- 462
	end -- 462
	fillRadialGlow( -- 464
		uiGlow, -- 464
		midX, -- 464
		midY + 46, -- 464
		240, -- 464
		130, -- 464
		Color(235, 224, 202, 14), -- 464
		Color(235, 224, 202, 0), -- 464
		14 -- 464
	) -- 464
	local padX = 46 -- 467
	local padY = 36 -- 468
	local inX = cx + padX -- 469
	local inY = cy + padY -- 470
	local inW = cardW - padX * 2 -- 471
	local inH = cardH - padY * 2 -- 472
	local redSilk = toColor(PALETTE.rouge, 118) -- 473
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 474
	uiInkDraw:drawRect( -- 476
		Rect(inX, inY, inW, inH), -- 476
		Color(0, 0, 0, 0), -- 476
		0.9, -- 476
		redSilk -- 476
	) -- 476
	uiInkDraw:drawRect( -- 477
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 477
		Color(0, 0, 0, 0), -- 477
		0.55, -- 477
		redSilkFaint -- 477
	) -- 477
	local headY = inY + inH - 28 -- 480
	texts:put( -- 481
		"md", -- 481
		"北塔入塔登记簿 · 末页", -- 481
		inX + 20, -- 481
		headY, -- 481
		toColor(PALETTE.xuanInk), -- 481
		0, -- 481
		0.5, -- 481
		"Left", -- 481
		2.4, -- 481
		0.94, -- 481
		0 -- 481
	) -- 481
	texts:put( -- 482
		"xs", -- 482
		"守望行记", -- 482
		inX + inW - 20, -- 482
		headY, -- 482
		toColor(PALETTE.xuanInkSub), -- 482
		1, -- 482
		0.5, -- 482
		"Right", -- 482
		2, -- 482
		0.78, -- 482
		0 -- 482
	) -- 482
	uiInkDraw:drawSegment( -- 483
		Vec2(inX + 14, headY - 22), -- 483
		Vec2(inX + inW - 14, headY - 22), -- 483
		0.85, -- 483
		redSilk -- 483
	) -- 483
	local row1Y = headY - 56 -- 486
	texts:put( -- 487
		"sm", -- 487
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 487
		inX + 20, -- 487
		row1Y, -- 487
		toColor(PALETTE.xuanInk), -- 487
		0, -- 487
		0.5, -- 487
		"Left", -- 487
		0.8, -- 487
		0.94, -- 487
		0 -- 487
	) -- 487
	texts:put( -- 488
		"xs", -- 488
		"附注：护送者留守南城门，托她独自走完余路。", -- 488
		inX + 20, -- 488
		row1Y - 28, -- 488
		toColor(PALETTE.xuanInkSub), -- 488
		0, -- 488
		0.5, -- 488
		"Left", -- 488
		0.6, -- 488
		0.88, -- 488
		0 -- 488
	) -- 488
	uiInkDraw:drawSegment( -- 489
		Vec2(inX + 16, row1Y - 48), -- 489
		Vec2(inX + inW - 16, row1Y - 48), -- 489
		0.65, -- 489
		redSilkFaint -- 489
	) -- 489
	local blankY = row1Y - 80 -- 492
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 493
	texts:put( -- 494
		"sm", -- 494
		"肆拾贰", -- 494
		inX + 20, -- 494
		blankY, -- 494
		toColor(PALETTE.rouge), -- 494
		0, -- 494
		0.5, -- 494
		"Left", -- 494
		1, -- 494
		0.92, -- 494
		0 -- 494
	) -- 494
	uiInkDraw:drawSegment( -- 495
		Vec2(inX + 94, blankY - 7), -- 495
		Vec2(inX + inW - 116, blankY - 7), -- 495
		0.95, -- 495
		toColor(PALETTE.xuanInkSub, 155 * pulse) -- 495
	) -- 495
	texts:put( -- 496
		"xs", -- 496
		"（空行留待）", -- 496
		inX + inW - 104, -- 496
		blankY, -- 496
		toColor(PALETTE.xuanInkSub), -- 496
		0, -- 496
		0.5, -- 496
		"Left", -- 496
		1, -- 496
		0.82 * pulse, -- 496
		0 -- 496
	) -- 496
	if p.phase == "tower-end" then -- 499
		local signY = inY + 46 -- 500
		texts:put( -- 501
			"banner", -- 501
			"向西守望", -- 501
			midX - 18, -- 501
			signY, -- 501
			toColor(PALETTE.xuanInk), -- 501
			0.5, -- 501
			0.5, -- 501
			"Center", -- 501
			6.5, -- 501
			0.92, -- 501
			0 -- 501
		) -- 501
		drawLoneSeal( -- 502
			uiInkDraw, -- 502
			art, -- 502
			texts, -- 502
			"reg_lone_seal", -- 502
			midX + 86, -- 502
			signY, -- 502
			22, -- 502
			42, -- 502
			"守", -- 502
			"望", -- 502
			PALETTE.sealRed, -- 502
			PALETTE.sealText, -- 502
			0.92, -- 502
			4 -- 502
		) -- 502
		drawSilkVeil( -- 504
			uiDraw, -- 504
			art, -- 504
			"reg_hint_veil", -- 504
			midX, -- 504
			cy - 28, -- 504
			360, -- 504
			32, -- 504
			PALETTE.inkWash, -- 504
			0.72, -- 504
			0 -- 504
		) -- 504
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 505
		local endHint = adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 506
		texts:put( -- 507
			"xs", -- 507
			endHint, -- 507
			midX, -- 507
			cy - 28, -- 507
			toColor(PALETTE.textMid), -- 507
			0.5, -- 507
			0.5, -- 507
			"Center", -- 507
			1.6, -- 507
			0.92, -- 507
			0.08 -- 507
		) -- 507
	end -- 507
end -- 434
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 511
	local theme = themeOf(roomKey) -- 520
	local t = self.bannerT / self.bannerMax -- 521
	local alpha = 1 -- 522
	if t > 0.82 then -- 523
		alpha = (1 - t) / 0.18 -- 524
	elseif t < 0.28 then -- 525
		alpha = t / 0.28 -- 526
	end -- 526
	local cx = w * 0.5 -- 528
	local cy = h * 0.77 -- 529
	local spread = math.min(1, alpha * 1.15) -- 530
	drawSilkVeil( -- 533
		uiDraw, -- 533
		art, -- 533
		"banner_veil", -- 533
		cx, -- 533
		cy - 2, -- 533
		480 * spread + 100, -- 533
		92, -- 533
		PALETTE.inkWash, -- 533
		0.76 * alpha, -- 533
		-1 -- 533
	) -- 533
	drawMistCurve( -- 534
		art, -- 534
		"banner_mist", -- 534
		cx, -- 534
		cy + 4, -- 534
		460 * spread, -- 534
		72, -- 534
		theme.accent, -- 534
		0.28 * alpha, -- 534
		0 -- 534
	) -- 534
	drawHairline( -- 535
		uiInkDraw, -- 535
		art, -- 535
		"banner_line", -- 535
		cx, -- 535
		cy - 16, -- 535
		320 * spread, -- 535
		PALETTE.silkLine, -- 535
		0.64 * alpha, -- 535
		false, -- 535
		2 -- 535
	) -- 535
	local sep = " · " -- 538
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 539
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 540
	if theme.backdropKey ~= nil then -- 541
		texts:put( -- 542
			"lg", -- 542
			theme.titleZh, -- 542
			cx, -- 542
			cy + 14, -- 542
			toColor(PALETTE.textBright), -- 542
			0.5, -- 543
			0.5, -- 543
			"Center", -- 543
			1, -- 543
			alpha, -- 543
			0.1 -- 543
		) -- 543
	elseif idx > 0 then -- 544
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 545
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 546
		local lw = visualTextWidth(leftPart, 42) -- 547
		local rw = visualTextWidth(rightPart, 42) -- 548
		local dotGap = 28 -- 549
		local totalW = lw + rw + dotGap -- 550
		local leftEdge = cx - totalW * 0.5 -- 551
		local dotX = leftEdge + lw + dotGap * 0.5 -- 552
		texts:put( -- 554
			"banner", -- 554
			leftPart, -- 554
			leftEdge, -- 554
			cy + 14, -- 554
			toColor(PALETTE.textBright), -- 554
			0, -- 554
			0.5, -- 554
			"Left", -- 554
			2, -- 554
			alpha, -- 554
			0.1 -- 554
		) -- 554
		drawBlossomDot( -- 555
			uiInkDraw, -- 555
			art, -- 555
			"banner_mid_dot", -- 555
			dotX, -- 555
			cy + 12, -- 555
			11, -- 555
			dotCol, -- 555
			0.92 * alpha, -- 555
			4 -- 555
		) -- 555
		texts:put( -- 556
			"banner", -- 556
			rightPart, -- 556
			dotX + dotGap * 0.5, -- 556
			cy + 14, -- 556
			toColor(PALETTE.textBright), -- 556
			0, -- 556
			0.5, -- 556
			"Left", -- 556
			2, -- 556
			alpha, -- 556
			0.1 -- 556
		) -- 556
	else -- 556
		texts:put( -- 558
			"banner", -- 558
			theme.titleZh, -- 558
			cx, -- 558
			cy + 14, -- 558
			toColor(PALETTE.textBright), -- 558
			0.5, -- 558
			0.5, -- 558
			"Center", -- 558
			3, -- 558
			alpha, -- 558
			0.1 -- 558
		) -- 558
	end -- 558
	texts:put( -- 560
		"xs", -- 560
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 560
		cx, -- 560
		cy - 34, -- 560
		toColor(PALETTE.textMid), -- 560
		0.5, -- 560
		0.5, -- 560
		"Center", -- 560
		2.2, -- 560
		0.82 * alpha, -- 560
		0.08 -- 560
	) -- 560
end -- 511
return ____exports -- 511
