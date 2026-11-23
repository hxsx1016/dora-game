-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Color = ____Dora.Color -- 7
local Rect = ____Dora.Rect -- 7
local Vec2 = ____Dora.Vec2 -- 7
local ____theme = require("Script.watch.fe.theme") -- 11
local PALETTE = ____theme.PALETTE -- 12
local drawDiamond = ____theme.drawDiamond -- 13
local fillChamferBox = ____theme.fillChamferBox -- 14
local fillRadialGlow = ____theme.fillRadialGlow -- 15
local fillSkewRect = ____theme.fillSkewRect -- 16
local fillVGradRect = ____theme.fillVGradRect -- 17
local themeOf = ____theme.themeOf -- 18
local toColor = ____theme.toColor -- 19
local visualTextWidth = ____theme.visualTextWidth -- 20
____exports.NarrativeRenderer = __TS__Class() -- 23
local NarrativeRenderer = ____exports.NarrativeRenderer -- 23
NarrativeRenderer.name = "NarrativeRenderer" -- 23
function NarrativeRenderer.prototype.____constructor(self) -- 23
	self.letterbox = 0 -- 25
	self.bannerT = 0 -- 27
	self.bannerMax = 2.8 -- 28
	self.wipeT = 0 -- 30
	self.lastRoomKey = "" -- 31
	self.time = 0 -- 32
end -- 23
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 34
	self.lastRoomKey = roomKey -- 35
	self.bannerT = self.bannerMax -- 36
	self.wipeT = 1 -- 37
end -- 34
function NarrativeRenderer.prototype.update(self, dt, p) -- 40
	self.time = self.time + dt -- 41
	if self.lastRoomKey ~= p.room.key then -- 41
		self:onEnterRoom(p.room.key) -- 43
	end -- 43
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and p.phase == "gate-count" or p.room.key == "tower" and p.phase ~= "tower-wait" -- 45
	local target = wantCinema and 1 or 0 -- 49
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 50
	if self.bannerT > 0 then -- 50
		self.bannerT = math.max(0, self.bannerT - dt) -- 53
	end -- 53
	if self.wipeT > 0 then -- 53
		self.wipeT = math.max(0, self.wipeT - dt * 2.8) -- 56
	end -- 56
end -- 40
function NarrativeRenderer.prototype.draw(self, uiDraw, uiGlow, art, texts, p, w, h) -- 60
	if self.letterbox > 0.01 then -- 60
		local barH = math.floor(74 * self.letterbox + 0.5) -- 71
		uiDraw:drawRect( -- 72
			Rect(0, h - barH, w, barH), -- 72
			Color(4, 6, 11, 245) -- 72
		) -- 72
		uiDraw:drawRect( -- 73
			Rect(0, 0, w, barH), -- 73
			Color(4, 6, 11, 245) -- 73
		) -- 73
		uiGlow:drawSegment( -- 74
			Vec2(0, h - barH), -- 74
			Vec2(w, h - barH), -- 74
			1.1, -- 74
			toColor(PALETTE.cyanDim, 110 * self.letterbox) -- 74
		) -- 74
		uiGlow:drawSegment( -- 75
			Vec2(0, barH), -- 75
			Vec2(w, barH), -- 75
			1.1, -- 75
			toColor(PALETTE.cyanDim, 110 * self.letterbox) -- 75
		) -- 75
	end -- 75
	if p.room.key == "gate" and p.phase == "gate-count" then -- 75
		self:drawGateCountOverlay( -- 80
			uiDraw, -- 80
			uiGlow, -- 80
			texts, -- 80
			p, -- 80
			w, -- 80
			h -- 80
		) -- 80
	end -- 80
	if p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) then -- 80
		self:drawTowerRegistryCard( -- 85
			uiDraw, -- 85
			uiGlow, -- 85
			art, -- 85
			texts, -- 85
			p, -- 85
			w, -- 85
			h -- 85
		) -- 85
	end -- 85
	if not p.paused then -- 85
		self:drawSubtitleStrip( -- 90
			uiDraw, -- 90
			uiGlow, -- 90
			texts, -- 90
			p, -- 90
			w, -- 90
			h -- 90
		) -- 90
	end -- 90
	if self.bannerT > 0 and not p.paused then -- 90
		self:drawAreaBanner( -- 95
			uiDraw, -- 95
			uiGlow, -- 95
			texts, -- 95
			p.room.key, -- 95
			w, -- 95
			h -- 95
		) -- 95
	end -- 95
	if self.wipeT > 0.01 then -- 95
		local a = math.floor(255 * math.min(1, self.wipeT * 1.15) + 0.5) -- 100
		uiDraw:drawRect( -- 101
			Rect(0, 0, w, h), -- 101
			Color(4, 6, 11, a) -- 101
		) -- 101
		local slashX = w * (1 - self.wipeT) -- 102
		uiGlow:drawSegment( -- 103
			Vec2(slashX - 60, 0), -- 103
			Vec2(slashX + 60, h), -- 103
			3, -- 103
			toColor(PALETTE.cyan, 190 * self.wipeT) -- 103
		) -- 103
	end -- 103
end -- 60
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiGlow, texts, p, w, h) -- 107
	local line = self:composeNarrativeLine(p) -- 115
	if line.text == "" then -- 115
		return -- 117
	end -- 117
	local textW = visualTextWidth(line.text, 17) -- 119
	local speakerW = visualTextWidth(line.speaker, 14) -- 120
	local stripW = math.min( -- 121
		w - 100, -- 121
		math.max(420, textW + speakerW + 96) -- 121
	) -- 121
	local stripH = 42 -- 122
	local sx = (w - stripW) * 0.5 -- 123
	local sy = self.letterbox > 0.4 and 16 or 22 -- 124
	local accent = line.urgent and PALETTE.crimson or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 125
	fillSkewRect( -- 127
		uiDraw, -- 127
		sx, -- 127
		sy, -- 127
		stripW, -- 127
		stripH, -- 127
		10, -- 127
		toColor(PALETTE.panelBgDeep, 218), -- 127
		1, -- 127
		toColor(accent, 150) -- 127
	) -- 127
	fillSkewRect( -- 128
		uiGlow, -- 128
		sx - 3, -- 128
		sy, -- 128
		4, -- 128
		stripH, -- 128
		10, -- 128
		toColor(accent, 235) -- 128
	) -- 128
	texts:put( -- 129
		"xs", -- 129
		line.speaker, -- 129
		sx + 18, -- 129
		sy + stripH * 0.5, -- 129
		toColor(accent), -- 129
		0, -- 129
		0.5, -- 129
		"Left", -- 129
		0.9, -- 129
		0.94 -- 129
	) -- 129
	uiDraw:drawSegment( -- 130
		Vec2(sx + speakerW + 30, sy + 10), -- 130
		Vec2(sx + speakerW + 30, sy + stripH - 10), -- 130
		1, -- 130
		toColor(accent, 95) -- 130
	) -- 130
	texts:put( -- 131
		"sm", -- 131
		line.text, -- 131
		sx + speakerW + 46, -- 131
		sy + stripH * 0.5, -- 131
		toColor(PALETTE.textBright), -- 131
		0, -- 131
		0.5, -- 131
		"Left", -- 131
		0.4, -- 131
		0.98 -- 131
	) -- 131
end -- 107
function NarrativeRenderer.prototype.composeNarrativeLine(self, p) -- 135
	local key = p.room.key -- 136
	local theme = themeOf(key) -- 137
	if key == "gate" and p.phase == "gate-hold" then -- 137
		local threatened = false -- 140
		local i = 0 -- 141
		do -- 141
			i = 0 -- 142
			while i < #p.enemies do -- 142
				if p.enemies[i + 1].alive and p.enemies[i + 1].warnT > 0 then -- 142
					threatened = true -- 144
				end -- 144
				i = i + 1 -- 142
			end -- 142
		end -- 142
		if threatened then -- 142
			return {speaker = "WARN // 锁敌", text = "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 格挡，或左键先手击倒", urgent = true} -- 148
		end -- 148
		if p.coverHug then -- 148
			return {speaker = "掩体", text = "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent = false} -- 151
		end -- 151
		return {speaker = "守点", text = "前出至街垒左侧贴掩体，左键点射守住城门", urgent = false} -- 153
	end -- 153
	if key == "gate" and p.phase == "gate-count" then -- 153
		if p.countTick >= 1440 then -- 153
			return {speaker = "WATCH // 交权", text = p.countPrevMove > 0 and "先松开方向键，再按下 [D] —— 由她迈出第一步" or "数到一百了，没有人来。按下 [D]，继续向北走", urgent = false} -- 158
		end -- 158
		return {speaker = "NARRATOR", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 164
	end -- 164
	if p.flash ~= "" and p.flashT > 0 then -- 164
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 168
		local text = p.flash -- 169
		local speaker = isDanger and "ALERT" or (p.childMode and "STEALTH" or "COMBAT") -- 170
		if key == "tower" or key == "prologue" then -- 170
			speaker = "NARRATOR" -- 172
		end -- 172
		if text == "命中" then -- 172
			text = "目标击倒 —— 继续推进并留意掩体" -- 175
		elseif text == "打空" then -- 175
			text = "弹道偏离或被掩体阻挡" -- 177
		elseif text == "翻滚" then -- 177
			text = "战术翻滚回避" -- 179
		end -- 179
		return {speaker = speaker, text = text, urgent = isDanger} -- 181
	end -- 181
	if key == "prologue" then -- 181
		if p.phase == "prologue-wait" then -- 181
			return {speaker = "NARRATOR", text = "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent = false} -- 186
		end -- 186
		if p.phase == "prologue-give" then -- 186
			return {speaker = "NARRATOR", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 189
		end -- 189
		return {speaker = "NARRATOR", text = "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent = false} -- 191
	end -- 191
	if key == "street" then -- 191
		local alive = 0 -- 195
		local i = 0 -- 196
		do -- 196
			i = 0 -- 197
			while i < #p.enemies do -- 197
				if p.enemies[i + 1].alive then -- 197
					alive = alive + 1 -- 198
				end -- 198
				i = i + 1 -- 197
			end -- 197
		end -- 197
		if alive > 0 then -- 197
			return {speaker = "交火", text = "前方街心有封锁敌兵。鼠标瞄准左键点射，空格贴矮台可翻越", urgent = false} -- 201
		end -- 201
		return {speaker = "NARRATOR", text = "街心安静了。带她继续向右，前往城邦检查站", urgent = false} -- 203
	end -- 203
	if key == "checkpoint" then -- 203
		if p.escort.state == "frozen" then -- 203
			return {speaker = "ALERT // 护送", text = "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 208
		end -- 208
		if p.escort.state == "calming" then -- 208
			return {speaker = "NARRATOR", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 211
		end -- 211
		if not p.cartDocked then -- 211
			return {speaker = "机关", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 214
		end -- 214
		return {speaker = "出口", text = "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent = false} -- 216
	end -- 216
	if key == "gate" then -- 216
		if p.phase == "gate-idle" then -- 216
			return {speaker = "NARRATOR", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 221
		end -- 221
		if p.phase == "gate-send" then -- 221
			return {speaker = "NARRATOR", text = "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent = false} -- 228
		end -- 228
		return {speaker = "NARRATOR", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 230
	end -- 230
	if key == "outside" then -- 230
		if not p.cartDocked then -- 230
			return {speaker = "NARRATOR", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 235
		end -- 235
		if p.checkpoint < 380 then -- 235
			return {speaker = "潜行", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 238
		end -- 238
		return {speaker = "NARRATOR", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 240
	end -- 240
	if key == "village" then -- 240
		if p.scavChase then -- 240
			return {speaker = "ALERT // 暴露", text = "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent = true} -- 245
		end -- 245
		if p.hasBottle then -- 245
			return {speaker = "诱敌", text = "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent = false} -- 248
		end -- 248
		if p.passed then -- 248
			return {speaker = "NARRATOR", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 251
		end -- 251
		return {speaker = "NARRATOR", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 253
	end -- 253
	if key == "forest" then -- 253
		if p.dogState == "chase" or p.dogState == "ear" then -- 253
			return {speaker = "ALERT // 猎犬", text = "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent = true} -- 258
		end -- 258
		return {speaker = "NARRATOR", text = "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent = false} -- 260
	end -- 260
	if key == "tower" then -- 260
		if p.phase == "tower-wait" then -- 260
			return {speaker = "NARRATOR", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 265
		end -- 265
		if p.phase == "tower-knock" then -- 265
			return {speaker = "NARRATOR", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 268
		end -- 268
		if p.phase == "tower-given" then -- 268
			return {speaker = "NARRATOR", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 271
		end -- 271
		return {speaker = "EPILOGUE // 守望", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 273
	end -- 273
	return {speaker = "NARRATOR", text = theme.introWhisper, urgent = false} -- 276
end -- 135
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiGlow, texts, p, w, h) -- 279
	local frac = math.min(1, p.countTick / 1440) -- 287
	local countNum = math.min( -- 288
		100, -- 288
		math.floor(frac * 100) -- 288
	) -- 288
	uiDraw:drawRect( -- 290
		Rect(0, 0, w, h), -- 290
		Color( -- 290
			4, -- 290
			6, -- 290
			12, -- 290
			math.floor(70 + frac * 105 + 0.5) -- 290
		) -- 290
	) -- 290
	local cy = h * 0.56 -- 292
	local numStr = countNum < 10 and "00" .. tostring(countNum) or (countNum < 100 and "0" .. tostring(countNum) or "100") -- 293
	texts:put( -- 294
		"xl", -- 294
		numStr, -- 294
		w * 0.5, -- 294
		cy, -- 294
		toColor(PALETTE.amberCore), -- 294
		0.5, -- 294
		0.5, -- 294
		"Center", -- 294
		8, -- 294
		0.28 + frac * 0.65 -- 294
	) -- 294
	texts:put( -- 295
		"sm", -- 295
		"COUNTING OUTSIDE THE GATE  //  城外等待", -- 295
		w * 0.5, -- 295
		cy - 42, -- 295
		toColor(PALETTE.textDim), -- 295
		0.5, -- 295
		0.5, -- 295
		"Center", -- 295
		2.5, -- 295
		0.72 -- 295
	) -- 295
	if p.countTick >= 1440 then -- 295
		local pulse = 0.65 + 0.35 * math.sin(self.time * 4.5) -- 298
		fillRadialGlow( -- 299
			uiGlow, -- 299
			w * 0.5, -- 299
			cy - 88, -- 299
			130, -- 299
			26, -- 299
			toColor(PALETTE.amber, 75 * pulse), -- 299
			Color(242, 188, 96, 0), -- 299
			16 -- 299
		) -- 299
		fillSkewRect( -- 300
			uiDraw, -- 300
			w * 0.5 - 120, -- 300
			cy - 106, -- 300
			240, -- 300
			34, -- 300
			9, -- 300
			toColor(PALETTE.panelBgDeep, 235), -- 300
			1.4, -- 300
			toColor(PALETTE.amber, 230 * pulse) -- 300
		) -- 300
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 迈出第一步" -- 301
		texts:put( -- 302
			"sm", -- 302
			prompt, -- 302
			w * 0.5, -- 302
			cy - 89, -- 302
			toColor(PALETTE.amberCore), -- 302
			0.5, -- 302
			0.5, -- 302
			"Center", -- 302
			1, -- 302
			1 -- 302
		) -- 302
	end -- 302
end -- 279
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiGlow, art, texts, p, w, h) -- 306
	local cardW = 480 -- 315
	local cardH = 264 -- 316
	local cx = (w - cardW) * 0.5 -- 317
	local cy = (h - cardH) * 0.5 + 14 -- 318
	uiDraw:drawRect( -- 320
		Rect(0, 0, w, h), -- 320
		Color(4, 6, 12, 145) -- 320
	) -- 320
	fillChamferBox( -- 321
		uiDraw, -- 321
		cx, -- 321
		cy, -- 321
		cardW, -- 321
		cardH, -- 321
		18, -- 321
		toColor(PALETTE.panelBgDeep, 242), -- 321
		1.5, -- 321
		toColor(PALETTE.amber, 210) -- 321
	) -- 321
	fillVGradRect( -- 322
		uiGlow, -- 322
		cx, -- 322
		cy + cardH - 52, -- 322
		cardW, -- 322
		52, -- 322
		Color(242, 188, 96, 0), -- 322
		Color(242, 188, 96, 48) -- 322
	) -- 322
	art:tryPlace( -- 324
		"ui_paper", -- 324
		"registry_paper", -- 324
		cx + cardW * 0.5, -- 324
		cy + cardH * 0.5, -- 324
		cardW - 20, -- 324
		cardH - 16, -- 324
		{opacity = 0.14} -- 325
	) -- 325
	texts:put( -- 326
		"xs", -- 326
		"北塔登记簿 · 末页", -- 326
		cx + 26, -- 326
		cy + cardH - 22, -- 326
		toColor(PALETTE.amber), -- 326
		0, -- 326
		0.5, -- 326
		"Left", -- 326
		1.2, -- 326
		1 -- 326
	) -- 326
	uiDraw:drawSegment( -- 327
		Vec2(cx + 22, cy + cardH - 40), -- 327
		Vec2(cx + cardW - 22, cy + cardH - 40), -- 327
		1.1, -- 327
		toColor(PALETTE.amberDim, 180) -- 327
	) -- 327
	texts:put( -- 330
		"sm", -- 330
		"#041   小满  ·  持黄铜指南针与纸条  ·  已入塔", -- 330
		cx + 28, -- 330
		cy + cardH - 72, -- 330
		toColor(PALETTE.textBright), -- 330
		0, -- 330
		0.5, -- 330
		"Left", -- 330
		0.4, -- 330
		1 -- 330
	) -- 330
	texts:put( -- 331
		"xs", -- 331
		"附注：\"护送者留守南城门，托她独自走完余路。\"", -- 331
		cx + 28, -- 331
		cy + cardH - 102, -- 331
		toColor(PALETTE.textMid), -- 331
		0, -- 331
		0.5, -- 331
		"Left", -- 331
		0.3, -- 331
		0.92 -- 331
	) -- 331
	local blankY = cy + 102 -- 334
	local pulse = 0.72 + 0.28 * math.sin(self.time * 2.6) -- 335
	uiDraw:drawSegment( -- 336
		Vec2(cx + 28, blankY - 12), -- 336
		Vec2(cx + cardW - 28, blankY - 12), -- 336
		1.2, -- 336
		toColor(PALETTE.amber, 165 * pulse) -- 336
	) -- 336
	texts:put( -- 337
		"sm", -- 337
		"#042   ____________________________  （空行留待）", -- 337
		cx + 28, -- 337
		blankY + 4, -- 337
		toColor(PALETTE.amberCore), -- 337
		0, -- 337
		0.5, -- 337
		"Left", -- 337
		0.5, -- 337
		0.88 * pulse -- 337
	) -- 337
	if p.phase == "tower-end" then -- 337
		texts:put( -- 340
			"md", -- 340
			"向西守望", -- 340
			w * 0.5, -- 340
			cy + 52, -- 340
			toColor(PALETTE.textBright), -- 340
			0.5, -- 340
			0.5, -- 340
			"Center", -- 340
			3, -- 340
			1 -- 340
		) -- 340
		texts:put( -- 341
			"xs", -- 341
			"[E] 再次启程     ·     [ESC] 暂停菜单", -- 341
			w * 0.5, -- 341
			cy + 24, -- 341
			toColor(PALETTE.cyan), -- 341
			0.5, -- 341
			0.5, -- 341
			"Center", -- 341
			1.2, -- 341
			0.95 -- 341
		) -- 341
	end -- 341
end -- 306
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiGlow, texts, roomKey, w, h) -- 345
	local theme = themeOf(roomKey) -- 353
	local t = self.bannerT / self.bannerMax -- 354
	local alpha = 1 -- 356
	if t > 0.82 then -- 356
		alpha = (1 - t) / 0.18 -- 358
	elseif t < 0.25 then -- 358
		alpha = t / 0.25 -- 360
	end -- 360
	local cy = h * 0.79 -- 362
	local lineW = 360 * math.min(1, alpha * 1.2) -- 363
	uiGlow:drawSegment( -- 364
		Vec2(w * 0.5 - lineW * 0.5, cy - 2), -- 364
		Vec2(w * 0.5 + lineW * 0.5, cy - 2), -- 364
		1.6, -- 364
		toColor(theme.accent, 210 * alpha) -- 364
	) -- 364
	drawDiamond( -- 365
		uiGlow, -- 365
		w * 0.5, -- 365
		cy - 2, -- 365
		5, -- 365
		5, -- 365
		toColor(PALETTE.cyanCore, 230 * alpha) -- 365
	) -- 365
	texts:put( -- 367
		"lg", -- 367
		theme.titleZh, -- 367
		w * 0.5, -- 367
		cy + 26, -- 367
		toColor(PALETTE.textBright), -- 367
		0.5, -- 367
		0.5, -- 367
		"Center", -- 367
		2.2, -- 367
		alpha -- 367
	) -- 367
end -- 345
return ____exports -- 345