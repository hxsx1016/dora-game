-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____theme = require("Script.watch.fe.theme") -- 7
local PALETTE = ____theme.PALETTE -- 7
local themeOf = ____theme.themeOf -- 7
local toColor = ____theme.toColor -- 7
local visualTextWidth = ____theme.visualTextWidth -- 7
____exports.NarrativeRenderer = __TS__Class() -- 9
local NarrativeRenderer = ____exports.NarrativeRenderer -- 9
NarrativeRenderer.name = "NarrativeRenderer" -- 9
function NarrativeRenderer.prototype.____constructor(self) -- 9
	self.letterbox = 0 -- 10
	self.wipeT = 0 -- 11
	self.roomKey = "" -- 12
end -- 9
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 14
	self.roomKey = roomKey -- 15
	self.letterbox = 0 -- 16
	self.wipeT = 1 -- 17
end -- 14
function NarrativeRenderer.prototype.update(self, dt, p) -- 20
	if self.roomKey ~= p.room.key then -- 20
		self:onEnterRoom(p.room.key) -- 22
	end -- 22
	local cinema = p.phase == "prologue-give" or p.phase == "gate-count" or p.room.key == "tower" and p.phase ~= "tower-wait" -- 24
	self.letterbox = self.letterbox + ((cinema and 1 or 0) - self.letterbox) * math.min(1, dt * 4.5) -- 26
	self.wipeT = math.max(0, self.wipeT - dt * 3.5) -- 27
end -- 20
function NarrativeRenderer.prototype.draw(self, draw, art, texts, p, w, h) -- 30
	local barH = math.floor(64 * self.letterbox + 0.5) -- 31
	if barH > 0 then -- 31
		draw:drawRect( -- 33
			Rect(0, h - barH, w, barH), -- 33
			Color(8, 8, 13, 245) -- 33
		) -- 33
		draw:drawRect( -- 34
			Rect(0, 0, w, barH), -- 34
			Color(8, 8, 13, 245) -- 34
		) -- 34
	end -- 34
	if self.wipeT > 0 then -- 34
		draw:drawRect( -- 37
			Rect(0, 0, w, h), -- 37
			Color( -- 37
				8, -- 37
				8, -- 37
				13, -- 37
				math.floor(200 * self.wipeT + 0.5) -- 37
			) -- 37
		) -- 37
	end -- 37
	if p.phase == "gate-count" then -- 37
		self:drawGateWait( -- 41
			draw, -- 41
			texts, -- 41
			p, -- 41
			w, -- 41
			h -- 41
		) -- 41
	elseif p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120 then -- 41
		self:drawRegistry( -- 43
			draw, -- 43
			art, -- 43
			texts, -- 43
			p.phase == "tower-end", -- 43
			w, -- 43
			h -- 43
		) -- 43
	else -- 43
		local line = self:goalText(p) -- 45
		if line ~= "" then -- 45
			self:drawSubtitle(draw, texts, line, w) -- 47
		end -- 47
	end -- 47
end -- 30
function NarrativeRenderer.prototype.drawSubtitle(self, draw, texts, text, w) -- 52
	local width = math.min( -- 53
		w - 44, -- 53
		visualTextWidth(text, 17) + 44 -- 53
	) -- 53
	draw:drawRect( -- 54
		Rect((w - width) / 2, 22, width, 40), -- 54
		toColor(PALETTE.panelBgDeep, 235) -- 54
	) -- 54
	texts:put( -- 55
		"sm", -- 55
		text, -- 55
		w * 0.5, -- 55
		42, -- 55
		toColor(PALETTE.textBright), -- 55
		0.5, -- 55
		0.5, -- 55
		"Center" -- 55
	) -- 55
end -- 52
function NarrativeRenderer.prototype.goalText(self, p) -- 58
	if p.caughtT > 0 then -- 58
		return "被发现了，正在返回检查点。" -- 60
	end -- 60
	local room = p.room.key -- 62
	if room == "prologue" then -- 62
		if p.phase == "prologue-wait" then -- 62
			return "用 A / D 向右走近小满，把指南针交给她。" -- 65
		end -- 65
		if p.phase == "prologue-give" then -- 65
			return "周戍把纸条塞进针套，递到她手里。" -- 68
		end -- 68
		return "带小满向右走出大门。" -- 70
	end -- 70
	if room == "street" or room == "checkpoint" then -- 70
		if p.escort.state == "frozen" then -- 70
			return "小满受惊停下了。走近她，按 E 安抚。" -- 75
		end -- 75
		if p.escort.state == "calming" then -- 75
			return "咚、咚。小满慢慢抬起了头。" -- 78
		end -- 78
		if __TS__ArraySome( -- 78
			p.enemies, -- 80
			function(____, enemy) return enemy.alive end -- 80
		) then -- 80
			return "鼠标瞄准，左键开枪。靠近矮柜时按空格翻越。" -- 81
		end -- 81
		if room == "street" then -- 81
			return "带小满向右，前往检查站。" -- 84
		end -- 84
		return p.cartDocked and "和小满一起走到右侧出口。" or "把红布板车推到右边的车窝。" -- 86
	end -- 86
	if room == "gate" then -- 86
		if p.phase == "gate-hold" then -- 86
			if p.coverHug then -- 86
				return "已贴靠掩体。用鼠标瞄准，左键开枪。" -- 92
			end -- 92
			return __TS__ArraySome( -- 94
				p.enemies, -- 94
				function(____, enemy) return enemy.alive and enemy.warnT > 0 end -- 94
			) and "敌兵举枪了。靠近街垒，按住 Shift 挡枪。" or "靠近街垒，按住 Shift 贴掩体，守住城门。" -- 94
		end -- 94
		if p.phase == "gate-idle" then -- 94
			return p.gateNeedConfirm and "回到绞盘，按 E 重新守门。" or "走到左侧绞盘，等小满到门边。" -- 99
		end -- 99
		return p.phase == "gate-send" and "走到右边城门，把小满送出城。" or "用 D 沿小路向右走。" -- 101
	end -- 101
	if room == "outside" then -- 101
		if not p.cartDocked then -- 101
			return "把上层的红布板车向右拉开。" -- 106
		end -- 106
		return p.checkpoint < p.room.arch.x1 and "沿左侧石阶下去，按住 Ctrl 穿过低拱。" or "沿墙根小路向右走。" -- 108
	end -- 108
	if room == "village" then -- 108
		if p.scavChase then -- 108
			return "拾荒者追来了。按住 Ctrl 钻到桌下。" -- 115
		end -- 115
		if p.passed then -- 115
			return "继续向右，进入森林。" -- 118
		end -- 118
		if p.hasBottle then -- 118
			return "按住 F 瞄准砖地，松开投瓶。" -- 121
		end -- 121
		if p.bottleFly ~= nil then -- 121
			return "等瓶子落地，把拾荒者引开。" -- 124
		end -- 124
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 124
			return "趁拾荒者走开，按住 Ctrl 钻过桌下。" -- 127
		end -- 127
		return "到瓶架旁，按 E 拾起瓶子。" -- 129
	end -- 129
	if room == "forest" then -- 129
		if p.dogState == "chase" then -- 129
			return "猎犬追来了。蹲进草丛躲开它。" -- 134
		end -- 134
		return p.dogState == "ear" and "猎犬听到了。按住 Ctrl 蹲下。" or "按住 Shift 慢走，绕开猎犬。" -- 136
	end -- 136
	if room == "tower" then -- 136
		if p.phase == "tower-wait" then -- 136
			return "走到北塔门前，按 E 敲门。" -- 141
		end -- 141
		if p.phase == "tower-knock" then -- 141
			return "咚、咚。她敲响了北塔的门。" -- 144
		end -- 144
		return p.phaseTick < 60 and "门开了，灯光落在小满身上。" or "她把指南针和纸条交给守卫。" -- 146
	end -- 146
	return themeOf(room).introWhisper -- 149
end -- 58
function NarrativeRenderer.prototype.drawGateWait(self, draw, texts, p, w, h) -- 152
	local count = math.min( -- 153
		100, -- 153
		math.floor(p.countTick * 100 / 1440) -- 153
	) -- 153
	draw:drawRect( -- 154
		Rect(0, 0, w, h), -- 154
		Color(8, 8, 13, 137) -- 154
	) -- 154
	texts:put( -- 155
		"xl", -- 155
		"" .. tostring(count), -- 155
		w * 0.5, -- 155
		h * 0.57, -- 155
		toColor(PALETTE.amberCore), -- 156
		0.5, -- 156
		0.5, -- 156
		"Center" -- 156
	) -- 156
	local hint = count < 100 and "小满在城外等着。" or (p.countPrevMove > 0 and "先松开方向键，再按 D 向前走。" or "按 D 继续向前走。") -- 157
	texts:put( -- 159
		"md", -- 159
		hint, -- 159
		w * 0.5, -- 159
		h * 0.46, -- 159
		toColor(PALETTE.textBright), -- 159
		0.5, -- 159
		0.5, -- 159
		"Center" -- 159
	) -- 159
end -- 152
function NarrativeRenderer.prototype.drawRegistry(self, draw, art, texts, ending, w, h) -- 162
	draw:drawRect( -- 165
		Rect(0, 0, w, h), -- 165
		Color(8, 8, 13, 145) -- 165
	) -- 165
	local box = Rect((w - 472) / 2, (h - 244) / 2, 472, 244) -- 166
	draw:drawRect( -- 167
		box, -- 167
		toColor(PALETTE.panelBgDeep, 250), -- 167
		1, -- 167
		toColor(PALETTE.steelLight) -- 167
	) -- 167
	art:tryPlace( -- 168
		"ui_paper", -- 168
		"registry_paper", -- 168
		box.centerX, -- 168
		box.centerY, -- 168
		box.width - 14, -- 168
		box.height - 14, -- 168
		{opacity = 0.14} -- 169
	) -- 169
	texts:put( -- 171
		"lg", -- 171
		"北塔登记簿", -- 171
		box.x + 26, -- 171
		box.top - 38, -- 171
		toColor(PALETTE.textBright) -- 171
	) -- 171
	texts:put( -- 172
		"md", -- 172
		"小满　已入塔", -- 172
		box.x + 26, -- 172
		box.top - 86, -- 172
		toColor(PALETTE.textBright) -- 172
	) -- 172
	texts:put( -- 173
		"sm", -- 173
		"她带来了指南针和纸条。", -- 173
		box.x + 26, -- 173
		box.top - 120, -- 173
		toColor(PALETTE.textMid) -- 173
	) -- 173
	texts:put( -- 174
		"sm", -- 174
		"护送者", -- 174
		box.x + 26, -- 174
		box.y + 82, -- 174
		toColor(PALETTE.textMid) -- 174
	) -- 174
	draw:drawSegment( -- 175
		Vec2(box.x + 101, box.y + 80), -- 175
		Vec2(box.right - 26, box.y + 80), -- 175
		1, -- 176
		toColor(PALETTE.amberDim) -- 176
	) -- 176
	if ending then -- 176
		texts:put( -- 178
			"sm", -- 178
			"E 再玩一次　　Esc 暂停菜单", -- 178
			box.x + 26, -- 178
			box.y + 35, -- 178
			toColor(PALETTE.textBright) -- 178
		) -- 178
	end -- 178
end -- 162
return ____exports -- 162