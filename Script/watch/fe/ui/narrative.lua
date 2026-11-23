-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Color = ____Dora.Color -- 7
local Rect = ____Dora.Rect -- 7
local Vec2 = ____Dora.Vec2 -- 7
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 11
local drawDiamond = ____theme.drawDiamond -- 12
local fillChamferBox = ____theme.fillChamferBox -- 13
local fillRadialGlow = ____theme.fillRadialGlow -- 14
local fillSkewRect = ____theme.fillSkewRect -- 15
local fillVGradRect = ____theme.fillVGradRect -- 16
local themeOf = ____theme.themeOf -- 17
local toColor = ____theme.toColor -- 18
local visualTextWidth = ____theme.visualTextWidth -- 19
____exports.NarrativeRenderer = __TS__Class() -- 22
local NarrativeRenderer = ____exports.NarrativeRenderer -- 22
NarrativeRenderer.name = "NarrativeRenderer" -- 22
function NarrativeRenderer.prototype.____constructor(self) -- 22
	self.letterbox = 0 -- 24
	self.bannerT = 0 -- 26
	self.bannerMax = 2.8 -- 27
	self.wipeT = 0 -- 29
	self.lastRoomKey = "" -- 30
	self.time = 0 -- 31
end -- 22
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 33
	self.lastRoomKey = roomKey -- 34
	self.bannerT = self.bannerMax -- 35
	self.wipeT = 1 -- 36
end -- 33
function NarrativeRenderer.prototype.update(self, dt, p) -- 39
	self.time = self.time + dt -- 40
	if self.lastRoomKey ~= p.room.key then -- 40
		self:onEnterRoom(p.room.key) -- 42
	end -- 42
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and p.phase == "gate-count" or p.room.key == "tower" and p.phase ~= "tower-wait" -- 44
	local target = wantCinema and 1 or 0 -- 48
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 49
	if self.bannerT > 0 then -- 49
		self.bannerT = math.max(0, self.bannerT - dt) -- 52
	end -- 52
	if self.wipeT > 0 then -- 52
		self.wipeT = math.max(0, self.wipeT - dt * 2.8) -- 55
	end -- 55
end -- 39
function NarrativeRenderer.prototype.draw(self, uiDraw, uiGlow, texts, p, w, h) -- 59
	if self.letterbox > 0.01 then -- 59
		local barH = math.floor(74 * self.letterbox + 0.5) -- 69
		uiDraw:drawRect( -- 70
			Rect(0, h - barH, w, barH), -- 70
			Color(4, 6, 11, 245) -- 70
		) -- 70
		uiDraw:drawRect( -- 71
			Rect(0, 0, w, barH), -- 71
			Color(4, 6, 11, 245) -- 71
		) -- 71
		uiGlow:drawSegment( -- 72
			Vec2(0, h - barH), -- 72
			Vec2(w, h - barH), -- 72
			1.1, -- 72
			toColor(PALETTE.cyanDim, 110 * self.letterbox) -- 72
		) -- 72
		uiGlow:drawSegment( -- 73
			Vec2(0, barH), -- 73
			Vec2(w, barH), -- 73
			1.1, -- 73
			toColor(PALETTE.cyanDim, 110 * self.letterbox) -- 73
		) -- 73
	end -- 73
	if p.room.key == "gate" and p.phase == "gate-count" then -- 73
		self:drawGateCountOverlay( -- 78
			uiDraw, -- 78
			uiGlow, -- 78
			texts, -- 78
			p, -- 78
			w, -- 78
			h -- 78
		) -- 78
	end -- 78
	if p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 96) then -- 78
		self:drawTowerRegistryCard( -- 83
			uiDraw, -- 83
			uiGlow, -- 83
			texts, -- 83
			p, -- 83
			w, -- 83
			h -- 83
		) -- 83
	end -- 83
	if not p.paused then -- 83
		self:drawSubtitleStrip( -- 88
			uiDraw, -- 88
			uiGlow, -- 88
			texts, -- 88
			p, -- 88
			w, -- 88
			h -- 88
		) -- 88
	end -- 88
	if self.bannerT > 0 and not p.paused then -- 88
		self:drawAreaBanner( -- 93
			uiDraw, -- 93
			uiGlow, -- 93
			texts, -- 93
			p.room.key, -- 93
			w, -- 93
			h -- 93
		) -- 93
	end -- 93
	if self.wipeT > 0.01 then -- 93
		local a = math.floor(255 * math.min(1, self.wipeT * 1.15) + 0.5) -- 98
		uiDraw:drawRect( -- 99
			Rect(0, 0, w, h), -- 99
			Color(4, 6, 11, a) -- 99
		) -- 99
		local slashX = w * (1 - self.wipeT) -- 100
		uiGlow:drawSegment( -- 101
			Vec2(slashX - 60, 0), -- 101
			Vec2(slashX + 60, h), -- 101
			3, -- 101
			toColor(PALETTE.cyan, 190 * self.wipeT) -- 101
		) -- 101
	end -- 101
end -- 59
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiGlow, texts, p, w, h) -- 105
	local line = self:composeNarrativeLine(p) -- 113
	if line.text == "" then -- 113
		return -- 115
	end -- 115
	local textW = visualTextWidth(line.text, 17) -- 117
	local speakerW = visualTextWidth(line.speaker, 14) -- 118
	local stripW = math.min( -- 119
		w - 100, -- 119
		math.max(420, textW + speakerW + 96) -- 119
	) -- 119
	local stripH = 42 -- 120
	local sx = (w - stripW) * 0.5 -- 121
	local sy = self.letterbox > 0.4 and 16 or 22 -- 122
	local accent = line.urgent and PALETTE.crimson or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 123
	fillSkewRect( -- 125
		uiDraw, -- 125
		sx, -- 125
		sy, -- 125
		stripW, -- 125
		stripH, -- 125
		10, -- 125
		toColor(PALETTE.panelBgDeep, 218), -- 125
		1, -- 125
		toColor(accent, 150) -- 125
	) -- 125
	fillSkewRect( -- 126
		uiGlow, -- 126
		sx - 3, -- 126
		sy, -- 126
		4, -- 126
		stripH, -- 126
		10, -- 126
		toColor(accent, 235) -- 126
	) -- 126
	texts:put( -- 127
		"xs", -- 127
		line.speaker, -- 127
		sx + 18, -- 127
		sy + stripH * 0.5, -- 127
		toColor(accent), -- 127
		0, -- 127
		0.5, -- 127
		"Left", -- 127
		0.9, -- 127
		0.94 -- 127
	) -- 127
	uiDraw:drawSegment( -- 128
		Vec2(sx + speakerW + 30, sy + 10), -- 128
		Vec2(sx + speakerW + 30, sy + stripH - 10), -- 128
		1, -- 128
		toColor(accent, 95) -- 128
	) -- 128
	texts:put( -- 129
		"sm", -- 129
		line.text, -- 129
		sx + speakerW + 46, -- 129
		sy + stripH * 0.5, -- 129
		toColor(PALETTE.textBright), -- 129
		0, -- 129
		0.5, -- 129
		"Left", -- 129
		0.4, -- 129
		0.98 -- 129
	) -- 129
end -- 105
function NarrativeRenderer.prototype.composeNarrativeLine(self, p) -- 133
	local key = p.room.key -- 134
	local theme = themeOf(key) -- 135
	if key == "gate" and p.phase == "gate-hold" then -- 135
		local threatened = false -- 138
		local i = 0 -- 139
		do -- 139
			i = 0 -- 140
			while i < #p.enemies do -- 140
				if p.enemies[i + 1].alive and p.enemies[i + 1].warnT > 0 then -- 140
					threatened = true -- 142
				end -- 142
				i = i + 1 -- 140
			end -- 140
		end -- 140
		if threatened then -- 140
			return {speaker = "WARN // 锁敌", text = "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 格挡，或左键先手击倒", urgent = true} -- 146
		end -- 146
		if p.coverHug then -- 146
			return {speaker = "SYS // 掩体", text = "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent = false} -- 149
		end -- 149
		return {speaker = "SYS // 守点", text = "前出至街垒左侧贴掩体，左键点射守住城门", urgent = false} -- 151
	end -- 151
	if key == "gate" and p.phase == "gate-count" then -- 151
		if p.countTick >= 1440 then -- 151
			return {speaker = "WATCH // 交权", text = p.countPrevMove > 0 and "先松开方向键，再按下 [D] —— 由她迈出第一步" or "数到一百了，没有人来。按下 [D]，继续向北走", urgent = false} -- 156
		end -- 156
		return {speaker = "NARRATOR", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 162
	end -- 162
	if p.flash ~= "" and p.flashT > 0 then -- 162
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 166
		local text = p.flash -- 167
		local speaker = isDanger and "ALERT" or (p.childMode and "STEALTH" or "COMBAT") -- 168
		if key == "tower" or key == "prologue" then -- 168
			speaker = "NARRATOR" -- 170
		end -- 170
		if text == "命中" then -- 170
			text = "目标击倒 —— 继续推进并留意掩体" -- 173
		elseif text == "打空" then -- 173
			text = "弹道偏离或被掩体阻挡" -- 175
		elseif text == "翻滚" then -- 175
			text = "战术翻滚回避" -- 177
		end -- 177
		return {speaker = speaker, text = text, urgent = isDanger} -- 179
	end -- 179
	if key == "prologue" then -- 179
		if p.phase == "prologue-wait" then -- 179
			return {speaker = "NARRATOR", text = "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent = false} -- 184
		end -- 184
		if p.phase == "prologue-give" then -- 184
			return {speaker = "NARRATOR", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 187
		end -- 187
		return {speaker = "NARRATOR", text = "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent = false} -- 189
	end -- 189
	if key == "street" then -- 189
		local alive = 0 -- 193
		local i = 0 -- 194
		do -- 194
			i = 0 -- 195
			while i < #p.enemies do -- 195
				if p.enemies[i + 1].alive then -- 195
					alive = alive + 1 -- 196
				end -- 196
				i = i + 1 -- 195
			end -- 195
		end -- 195
		if alive > 0 then -- 195
			return {speaker = "SYS // 交火", text = "前方街心有封锁敌兵。鼠标瞄准左键点射，空格贴矮台可翻越", urgent = false} -- 199
		end -- 199
		return {speaker = "NARRATOR", text = "街心安静了。带她继续向右，前往城邦检查站", urgent = false} -- 201
	end -- 201
	if key == "checkpoint" then -- 201
		if p.escort.state == "frozen" then -- 201
			return {speaker = "ALERT // 护送", text = "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 206
		end -- 206
		if p.escort.state == "calming" then -- 206
			return {speaker = "NARRATOR", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 209
		end -- 209
		if not p.cartDocked then -- 209
			return {speaker = "SYS // 机关", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 212
		end -- 212
		return {speaker = "SYS // 出口", text = "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent = false} -- 214
	end -- 214
	if key == "gate" then -- 214
		if p.phase == "gate-idle" then -- 214
			return {speaker = "NARRATOR", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 219
		end -- 219
		if p.phase == "gate-send" then -- 219
			return {speaker = "NARRATOR", text = "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent = false} -- 226
		end -- 226
		return {speaker = "NARRATOR", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 228
	end -- 228
	if key == "outside" then -- 228
		if not p.cartDocked then -- 228
			return {speaker = "NARRATOR", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 233
		end -- 233
		if p.checkpoint < 380 then -- 233
			return {speaker = "SYS // 潜行", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 236
		end -- 236
		return {speaker = "NARRATOR", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 238
	end -- 238
	if key == "village" then -- 238
		if p.scavChase then -- 238
			return {speaker = "ALERT // 暴露", text = "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent = true} -- 243
		end -- 243
		if p.hasBottle then -- 243
			return {speaker = "SYS // 诱敌", text = "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent = false} -- 246
		end -- 246
		if p.passed then -- 246
			return {speaker = "NARRATOR", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 249
		end -- 249
		return {speaker = "NARRATOR", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 251
	end -- 251
	if key == "forest" then -- 251
		if p.dogState == "chase" or p.dogState == "ear" then -- 251
			return {speaker = "ALERT // 猎犬", text = "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent = true} -- 256
		end -- 256
		return {speaker = "NARRATOR", text = "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent = false} -- 258
	end -- 258
	if key == "tower" then -- 258
		if p.phase == "tower-wait" then -- 258
			return {speaker = "NARRATOR", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 263
		end -- 263
		if p.phase == "tower-knock" then -- 263
			return {speaker = "NARRATOR", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 266
		end -- 266
		if p.phase == "tower-given" then -- 266
			return {speaker = "NARRATOR", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 269
		end -- 269
		return {speaker = "EPILOGUE // 守望", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 271
	end -- 271
	return {speaker = "NARRATOR", text = theme.introWhisper, urgent = false} -- 274
end -- 133
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiGlow, texts, p, w, h) -- 277
	local frac = math.min(1, p.countTick / 1440) -- 285
	local countNum = math.min( -- 286
		100, -- 286
		math.floor(frac * 100) -- 286
	) -- 286
	uiDraw:drawRect( -- 288
		Rect(0, 0, w, h), -- 288
		Color( -- 288
			4, -- 288
			6, -- 288
			12, -- 288
			math.floor(70 + frac * 105 + 0.5) -- 288
		) -- 288
	) -- 288
	local cy = h * 0.56 -- 290
	local numStr = countNum < 10 and "00" .. tostring(countNum) or (countNum < 100 and "0" .. tostring(countNum) or "100") -- 291
	texts:put( -- 292
		"xl", -- 292
		numStr, -- 292
		w * 0.5, -- 292
		cy, -- 292
		toColor(PALETTE.amberCore), -- 292
		0.5, -- 292
		0.5, -- 292
		"Center", -- 292
		8, -- 292
		0.28 + frac * 0.65 -- 292
	) -- 292
	texts:put( -- 293
		"sm", -- 293
		"COUNTING OUTSIDE THE GATE  //  城外等待", -- 293
		w * 0.5, -- 293
		cy - 42, -- 293
		toColor(PALETTE.textDim), -- 293
		0.5, -- 293
		0.5, -- 293
		"Center", -- 293
		2.5, -- 293
		0.72 -- 293
	) -- 293
	if p.countTick >= 1440 then -- 293
		local pulse = 0.65 + 0.35 * math.sin(self.time * 4.5) -- 296
		fillRadialGlow( -- 297
			uiGlow, -- 297
			w * 0.5, -- 297
			cy - 88, -- 297
			130, -- 297
			26, -- 297
			toColor(PALETTE.amber, 75 * pulse), -- 297
			Color(242, 188, 96, 0), -- 297
			16 -- 297
		) -- 297
		fillSkewRect( -- 298
			uiDraw, -- 298
			w * 0.5 - 120, -- 298
			cy - 106, -- 298
			240, -- 298
			34, -- 298
			9, -- 298
			toColor(PALETTE.panelBgDeep, 235), -- 298
			1.4, -- 298
			toColor(PALETTE.amber, 230 * pulse) -- 298
		) -- 298
		local prompt = p.countPrevMove > 0 and "先松开方向键，再按 [D]" or "按 [D] · 迈出第一步" -- 299
		texts:put( -- 300
			"sm", -- 300
			prompt, -- 300
			w * 0.5, -- 300
			cy - 89, -- 300
			toColor(PALETTE.amberCore), -- 300
			0.5, -- 300
			0.5, -- 300
			"Center", -- 300
			1, -- 300
			1 -- 300
		) -- 300
	end -- 300
end -- 277
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiGlow, texts, p, w, h) -- 304
	local cardW = 480 -- 312
	local cardH = 264 -- 313
	local cx = (w - cardW) * 0.5 -- 314
	local cy = (h - cardH) * 0.5 + 14 -- 315
	uiDraw:drawRect( -- 317
		Rect(0, 0, w, h), -- 317
		Color(4, 6, 12, 145) -- 317
	) -- 317
	fillChamferBox( -- 318
		uiDraw, -- 318
		cx, -- 318
		cy, -- 318
		cardW, -- 318
		cardH, -- 318
		18, -- 318
		toColor(PALETTE.panelBgDeep, 242), -- 318
		1.5, -- 318
		toColor(PALETTE.amber, 210) -- 318
	) -- 318
	fillVGradRect( -- 319
		uiGlow, -- 319
		cx, -- 319
		cy + cardH - 52, -- 319
		cardW, -- 319
		52, -- 319
		Color(242, 188, 96, 0), -- 319
		Color(242, 188, 96, 48) -- 319
	) -- 319
	texts:put( -- 321
		"xs", -- 321
		"NORTH TOWER ARCHIVE  //  北塔入塔登记簿 · 末页", -- 321
		cx + 26, -- 321
		cy + cardH - 22, -- 321
		toColor(PALETTE.amber), -- 321
		0, -- 321
		0.5, -- 321
		"Left", -- 321
		1.2, -- 321
		1 -- 321
	) -- 321
	uiDraw:drawSegment( -- 322
		Vec2(cx + 22, cy + cardH - 40), -- 322
		Vec2(cx + cardW - 22, cy + cardH - 40), -- 322
		1.1, -- 322
		toColor(PALETTE.amberDim, 180) -- 322
	) -- 322
	texts:put( -- 325
		"sm", -- 325
		"#041   小满  ·  持黄铜指南针与纸条  ·  已入塔", -- 325
		cx + 28, -- 325
		cy + cardH - 72, -- 325
		toColor(PALETTE.textBright), -- 325
		0, -- 325
		0.5, -- 325
		"Left", -- 325
		0.4, -- 325
		1 -- 325
	) -- 325
	texts:put( -- 326
		"xs", -- 326
		"附注：\"护送者留守南城门，托她独自走完余路。\"", -- 326
		cx + 28, -- 326
		cy + cardH - 102, -- 326
		toColor(PALETTE.textMid), -- 326
		0, -- 326
		0.5, -- 326
		"Left", -- 326
		0.3, -- 326
		0.92 -- 326
	) -- 326
	local blankY = cy + 102 -- 329
	local pulse = 0.72 + 0.28 * math.sin(self.time * 2.6) -- 330
	uiDraw:drawSegment( -- 331
		Vec2(cx + 28, blankY - 12), -- 331
		Vec2(cx + cardW - 28, blankY - 12), -- 331
		1.2, -- 331
		toColor(PALETTE.amber, 165 * pulse) -- 331
	) -- 331
	texts:put( -- 332
		"sm", -- 332
		"#042   ____________________________  （空行留待）", -- 332
		cx + 28, -- 332
		blankY + 4, -- 332
		toColor(PALETTE.amberCore), -- 332
		0, -- 332
		0.5, -- 332
		"Left", -- 332
		0.5, -- 332
		0.88 * pulse -- 332
	) -- 332
	if p.phase == "tower-end" then -- 332
		texts:put( -- 335
			"md", -- 335
			"月下山谷 · 守望", -- 335
			w * 0.5, -- 335
			cy + 52, -- 335
			toColor(PALETTE.textBright), -- 335
			0.5, -- 335
			0.5, -- 335
			"Center", -- 335
			3, -- 335
			1 -- 335
		) -- 335
		texts:put( -- 336
			"xs", -- 336
			"[E] 再次启程     ·     [ESC] 系统菜单", -- 336
			w * 0.5, -- 336
			cy + 24, -- 336
			toColor(PALETTE.cyan), -- 336
			0.5, -- 336
			0.5, -- 336
			"Center", -- 336
			1.2, -- 336
			0.95 -- 336
		) -- 336
	end -- 336
end -- 304
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiGlow, texts, roomKey, w, h) -- 340
	local theme = themeOf(roomKey) -- 348
	local t = self.bannerT / self.bannerMax -- 349
	local alpha = 1 -- 351
	if t > 0.82 then -- 351
		alpha = (1 - t) / 0.18 -- 353
	elseif t < 0.25 then -- 353
		alpha = t / 0.25 -- 355
	end -- 355
	local cy = h * 0.79 -- 357
	local lineW = 360 * math.min(1, alpha * 1.2) -- 358
	uiGlow:drawSegment( -- 359
		Vec2(w * 0.5 - lineW * 0.5, cy - 2), -- 359
		Vec2(w * 0.5 + lineW * 0.5, cy - 2), -- 359
		1.6, -- 359
		toColor(theme.accent, 210 * alpha) -- 359
	) -- 359
	drawDiamond( -- 360
		uiGlow, -- 360
		w * 0.5, -- 360
		cy - 2, -- 360
		5, -- 360
		5, -- 360
		toColor(PALETTE.cyanCore, 230 * alpha) -- 360
	) -- 360
	texts:put( -- 362
		"lg", -- 362
		(theme.actCode .. "  ·  ") .. theme.titleZh, -- 362
		w * 0.5, -- 362
		cy + 26, -- 362
		toColor(PALETTE.textBright), -- 362
		0.5, -- 362
		0.5, -- 362
		"Center", -- 362
		2.2, -- 362
		alpha -- 362
	) -- 362
	texts:put( -- 363
		"xs", -- 363
		theme.titleEn, -- 363
		w * 0.5, -- 363
		cy - 20, -- 363
		toColor(theme.accent), -- 363
		0.5, -- 363
		0.5, -- 363
		"Center", -- 363
		2, -- 363
		alpha * 0.9 -- 363
	) -- 363
end -- 340
return ____exports -- 340