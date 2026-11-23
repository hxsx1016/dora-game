-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____escort = require("Script.watch.escort") -- 5
local FEAR_MAX = ____escort.FEAR_MAX -- 5
local ____adapter = require("Script.watch.fe.adapter") -- 6
local deriveWorldPrompt = ____adapter.deriveWorldPrompt -- 6
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 10
local themeOf = ____theme.themeOf -- 10
local toColor = ____theme.toColor -- 10
local visualTextWidth = ____theme.visualTextWidth -- 10
____exports.HudRenderer = __TS__Class() -- 12
local HudRenderer = ____exports.HudRenderer -- 12
HudRenderer.name = "HudRenderer" -- 12
function HudRenderer.prototype.____constructor(self) -- 12
end -- 12
function HudRenderer.prototype.draw(self, uiDraw, uiGlow, texts, p, cam, vfx, letterbox, uiScale) -- 13
	local w = cam.viewW / uiScale -- 17
	local h = cam.viewH / uiScale -- 18
	local opacity = math.max(0, 1 - letterbox * 1.15) -- 19
	if opacity > 0.05 then -- 19
		self:drawStatus( -- 21
			uiDraw, -- 21
			texts, -- 21
			p, -- 21
			w, -- 21
			h, -- 21
			opacity -- 21
		) -- 21
		local ____opt_0 = p.room.story -- 21
		local gate = ____opt_0 and ____opt_0.gate -- 23
		if gate ~= nil and p.phase == "gate-hold" then -- 23
			local left = math.max( -- 25
				0, -- 25
				math.ceil((gate.holdTicks - p.gateTick) / 60) -- 25
			) -- 25
			local box = Rect(w * 0.5 - 101, h - 67, 202, 40) -- 26
			self:panel(uiDraw, box, opacity) -- 27
			texts:put( -- 28
				"md", -- 28
				("守门 · 剩余 " .. tostring(left)) .. " 秒", -- 28
				box.centerX, -- 28
				box.centerY, -- 28
				toColor(PALETTE.textBright), -- 29
				0.5, -- 29
				0.5, -- 29
				"Center", -- 29
				0, -- 29
				opacity -- 29
			) -- 29
		end -- 29
		local prompt = deriveWorldPrompt(p) -- 32
		if prompt ~= nil then -- 32
			self:drawPrompt( -- 34
				uiDraw, -- 34
				texts, -- 34
				prompt, -- 34
				cam, -- 34
				w, -- 34
				h, -- 34
				uiScale, -- 34
				opacity -- 34
			) -- 34
		end -- 34
	end -- 34
	if letterbox < 0.5 and not p.childMode and p.phase ~= "prologue-give" and p.escort.state ~= "calming" and not p.gateNeedConfirm then -- 34
		self:drawReticle(uiGlow, p, vfx, uiScale) -- 40
	end -- 40
end -- 13
function HudRenderer.prototype.panel(self, draw, box, opacity) -- 44
	draw:drawRect( -- 45
		box, -- 45
		toColor(PALETTE.panelBgDeep, 232 * opacity), -- 45
		1, -- 46
		toColor(PALETTE.steelLight, 165 * opacity) -- 46
	) -- 46
end -- 44
function HudRenderer.prototype.drawStatus(self, draw, texts, p, w, h, opacity) -- 49
	local left = 28 -- 52
	local top = h - 28 -- 53
	local showFear = not p.childMode and p.partner.alive and (p.room.key == "street" or p.room.key == "checkpoint") -- 54
	local height = showFear and 70 or 44 -- 56
	self:panel( -- 57
		draw, -- 57
		Rect(left, top - height, 238, height), -- 57
		opacity -- 57
	) -- 57
	if p.childMode then -- 57
		local status = p.player.crouch and "蹲下" or "小心前进" -- 60
		if p.dogState == "chase" or p.scavChase then -- 60
			status = "被发现了" -- 62
		end -- 62
		texts:put( -- 64
			"sm", -- 64
			"小满 · " .. status, -- 64
			left + 14, -- 64
			top - 22, -- 64
			toColor(PALETTE.textBright), -- 64
			0, -- 65
			0.5, -- 65
			"Left", -- 65
			0, -- 65
			opacity -- 65
		) -- 65
	elseif p.room.key == "gate" then -- 65
		self:drawMeter( -- 67
			draw, -- 67
			texts, -- 67
			"周戍体力", -- 67
			p.hp, -- 67
			p.maxHp, -- 67
			left, -- 67
			top - 22, -- 67
			p.hp == 1 and PALETTE.crimson or PALETTE.cyanCore, -- 68
			opacity -- 68
		) -- 68
	else -- 68
		texts:put( -- 70
			"sm", -- 70
			"周戍 · 护送", -- 70
			left + 14, -- 70
			top - 22, -- 70
			toColor(PALETTE.textBright), -- 70
			0, -- 71
			0.5, -- 71
			"Left", -- 71
			0, -- 71
			opacity -- 71
		) -- 71
		if showFear then -- 71
			self:drawMeter( -- 73
				draw, -- 73
				texts, -- 73
				"小满恐惧", -- 73
				p.escort.fear, -- 73
				FEAR_MAX, -- 73
				left, -- 73
				top - 48, -- 73
				p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber, -- 74
				opacity -- 74
			) -- 74
		end -- 74
	end -- 74
	local box = Rect(w - 268, h - 72, 240, 44) -- 78
	self:panel(draw, box, opacity) -- 79
	texts:put( -- 80
		"sm", -- 80
		themeOf(p.room.key).titleZh, -- 80
		box.x + 12, -- 80
		box.centerY, -- 80
		toColor(PALETTE.textBright), -- 81
		0, -- 81
		0.5, -- 81
		"Left", -- 81
		0, -- 81
		opacity -- 81
	) -- 81
	texts:put( -- 82
		"xs", -- 82
		"Esc 暂停", -- 82
		box.right - 11, -- 82
		box.centerY, -- 82
		toColor(PALETTE.textMid), -- 83
		1, -- 83
		0.5, -- 83
		"Right", -- 83
		0, -- 83
		opacity -- 83
	) -- 83
end -- 49
function HudRenderer.prototype.drawMeter(self, draw, texts, label, filled, total, x, y, tint, opacity) -- 86
	texts:put( -- 90
		"sm", -- 90
		label, -- 90
		x + 14, -- 90
		y, -- 90
		toColor(PALETTE.textBright), -- 90
		0, -- 90
		0.5, -- 90
		"Left", -- 90
		0, -- 90
		opacity -- 90
	) -- 90
	local cellW = math.min( -- 91
		19, -- 91
		86 / math.max(1, total) - 5 -- 91
	) -- 91
	do -- 91
		local i = 0 -- 92
		while i < total do -- 92
			local active = i < filled -- 93
			draw:drawRect( -- 94
				Rect(x + 95 + i * (cellW + 5), y - 5, cellW, 10), -- 94
				toColor(active and tint or PALETTE.voidDark, 220 * opacity), -- 95
				1, -- 96
				toColor(PALETTE.steelLight, 200 * opacity) -- 96
			) -- 96
			i = i + 1 -- 92
		end -- 92
	end -- 92
	texts:put( -- 98
		"sm", -- 98
		(tostring(filled) .. "/") .. tostring(total), -- 98
		x + 222, -- 98
		y, -- 98
		toColor(PALETTE.textBright), -- 98
		1, -- 99
		0.5, -- 99
		"Right", -- 99
		0, -- 99
		opacity -- 99
	) -- 99
end -- 86
function HudRenderer.prototype.drawPrompt(self, draw, texts, prompt, cam, w, h, scale, opacity) -- 102
	local screenX = cam:sx(prompt.x) / scale -- 106
	if screenX < 4 or screenX > w - 4 then -- 106
		return -- 108
	end -- 108
	local label = (prompt.keyTag .. "  ") .. prompt.label -- 110
	local width = math.min( -- 111
		w - 32, -- 111
		visualTextWidth(label, 17) + 30 -- 111
	) -- 111
	local x = math.min( -- 112
		w - width - 16, -- 112
		math.max(16, screenX - width * 0.5) -- 112
	) -- 112
	local y = math.max( -- 113
		83, -- 113
		math.min( -- 113
			h - 140, -- 113
			cam:sy(prompt.y) / scale -- 113
		) -- 113
	) -- 113
	local rect = Rect(x, y, width, 32) -- 114
	self:panel(draw, rect, opacity) -- 115
	texts:put( -- 116
		"sm", -- 116
		label, -- 116
		rect.centerX, -- 116
		rect.centerY, -- 116
		toColor(prompt.urgent and PALETTE.amberCore or PALETTE.textBright), -- 117
		0.5, -- 118
		0.5, -- 118
		"Center", -- 118
		0, -- 118
		opacity -- 118
	) -- 118
end -- 102
function HudRenderer.prototype.drawReticle(self, draw, p, vfx, scale) -- 121
	local x = p.aimX / scale -- 124
	local y = p.aimY / scale -- 125
	if x <= 0 and y <= 0 then -- 125
		return -- 127
	end -- 127
	local gap = 5 + vfx.crosshairKick * 0.45 -- 130
	local arm = 6 -- 131
	local color = toColor(PALETTE.cyanCore) -- 132
	draw:drawSegment( -- 133
		Vec2(x - gap - arm, y), -- 133
		Vec2(x - gap, y), -- 133
		1.6, -- 133
		color -- 133
	) -- 133
	draw:drawSegment( -- 134
		Vec2(x + gap, y), -- 134
		Vec2(x + gap + arm, y), -- 134
		1.6, -- 134
		color -- 134
	) -- 134
	draw:drawSegment( -- 135
		Vec2(x, y - gap - arm), -- 135
		Vec2(x, y - gap), -- 135
		1.6, -- 135
		color -- 135
	) -- 135
	draw:drawSegment( -- 136
		Vec2(x, y + gap), -- 136
		Vec2(x, y + gap + arm), -- 136
		1.6, -- 136
		color -- 136
	) -- 136
	draw:drawDot( -- 137
		Vec2(x, y), -- 137
		1.8, -- 137
		color -- 137
	) -- 137
end -- 121
return ____exports -- 121