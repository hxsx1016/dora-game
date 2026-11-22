-- [ts]: Probe.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Content = ____Dora.Content -- 10
local DrawNode = ____Dora.DrawNode -- 10
local Label = ____Dora.Label -- 10
local Rect = ____Dora.Rect -- 10
local Vec2 = ____Dora.Vec2 -- 10
local View = ____Dora.View -- 10
local ____levels = require("Script.game.levels") -- 11
local describeLevel = ____levels.describeLevel -- 11
local parseLevel = ____levels.parseLevel -- 11
local FONT = "sarasa-mono-sc-regular" -- 13
local MARKER = "d1-probe.result" -- 14
local LOG = "probe.log" -- 15
local STEP = 32 -- 16
local logs = {} -- 18
local marker = "" -- 19
local function log(text) -- 21
	logs[#logs + 1] = text -- 22
	Content:save( -- 23
		LOG, -- 23
		table.concat(logs, "\n") -- 23
	) -- 23
end -- 21
local function writeMarker(text) -- 26
	marker = text -- 27
	Content:save(MARKER, marker) -- 28
end -- 26
--- 一次自检：跑好/坏输入，返回 "ok" 或错误摘要。
local function checkParse(name, input, shouldPass) -- 32
	local detail = "" -- 33
	local passed = false -- 34
	do -- 34
		local function ____catch(____error) -- 34
			detail = "error:" .. tostring(____error) -- 40
			passed = shouldPass == false -- 41
		end -- 41
		local ____try, ____hasReturned = pcall(function() -- 41
			local level = parseLevel(name, input) -- 36
			detail = describeLevel(level) -- 37
			passed = shouldPass -- 38
		end) -- 38
		if not ____try then -- 38
			____catch(____hasReturned) -- 38
		end -- 38
	end -- 38
	log((("selftest " .. name) .. (passed == true and " PASS " or " FAIL ")) .. detail) -- 43
	return passed == true and "ok" or ("fail(" .. detail) .. ")" -- 44
end -- 32
____exports.Probe = __TS__Class() -- 47
local Probe = ____exports.Probe -- 47
Probe.name = "Probe" -- 47
function Probe.prototype.____constructor(self) -- 47
end -- 47
function Probe.mount(self, root) -- 48
	local w = View.size.width -- 49
	local h = View.size.height -- 50
	local r1 = checkParse("level1", "aS.AE", true) -- 53
	local r2 = checkParse("level2", "baS.ABE", true) -- 54
	local r3 = checkParse("bad-width", "aS.AE\nS...", false) -- 55
	local r4 = checkParse("bad-char", "aX.AE", false) -- 56
	local r5 = checkParse("bad-start", "a.AE", false) -- 57
	local level1Text = "" -- 60
	do -- 60
		local function ____catch(____error) -- 60
			level1Text = "error:" .. tostring(____error) -- 64
		end -- 64
		local ____try, ____hasReturned = pcall(function() -- 64
			level1Text = describeLevel(parseLevel("level1", "aS.AE")) -- 62
		end) -- 62
		if not ____try then -- 62
			____catch(____hasReturned) -- 62
		end -- 62
	end -- 62
	local title = Label(FONT, 44, false) -- 67
	if title ~= nil then -- 67
		title.text = "借我六步 · D1 探针" -- 69
		title.color = Color(244, 239, 230, 255) -- 70
		title.alignment = "Center" -- 71
		title.anchor = Vec2(0.5, 1) -- 72
		title.position = Vec2(w / 2, h - 48) -- 73
		root:addChild(title) -- 74
	end -- 74
	local hint = Label(FONT, 18, false) -- 77
	if hint ~= nil then -- 77
		hint.text = "方向键移动方块 · 每次一格 32px" -- 79
		hint.color = Color(158, 150, 140, 255) -- 80
		hint.alignment = "Center" -- 81
		hint.anchor = Vec2(0.5, 1) -- 82
		hint.position = Vec2(w / 2, h - 108) -- 83
		root:addChild(hint) -- 84
	end -- 84
	local levelLine = Label(FONT, 18, false) -- 87
	if levelLine ~= nil then -- 87
		levelLine.text = "首关 aS.AE · " .. level1Text -- 89
		levelLine.color = Color(196, 186, 172, 255) -- 90
		levelLine.alignment = "Center" -- 91
		levelLine.anchor = Vec2(0.5, 0) -- 92
		levelLine.position = Vec2(w / 2, 84) -- 93
		root:addChild(levelLine) -- 94
	end -- 94
	local status = Label(FONT, 18, false) -- 97
	if status ~= nil then -- 97
		status.color = Color(232, 197, 138, 255) -- 99
		status.alignment = "Center" -- 100
		status.anchor = Vec2(0.5, 0) -- 101
		status.position = Vec2(w / 2, 40) -- 102
		root:addChild(status) -- 103
	end -- 103
	local box = DrawNode() -- 106
	root:addChild(box) -- 107
	local bx = w / 2 -- 109
	local by = h / 2 -- 110
	local count = 0 -- 111
	local function draw() -- 113
		box:clear() -- 114
		box:drawRect( -- 115
			Rect(bx - 24, by - 24, 48, 48), -- 115
			Color(232, 197, 138, 255) -- 115
		) -- 115
		box:drawRect( -- 116
			Rect(bx - 24, by - 24, 48, 48), -- 116
			Color(14, 12, 20, 120), -- 116
			2, -- 116
			Color(244, 239, 230, 255) -- 116
		) -- 116
	end -- 113
	local function refresh() -- 119
		if status ~= nil then -- 119
			status.text = (((((((("按键 " .. tostring(count)) .. " 次 · 方块 (") .. tostring(bx)) .. ", ") .. tostring(by)) .. ") · view ") .. tostring(w)) .. "x") .. tostring(h) -- 121
		end -- 121
		writeMarker((((((((((((((((((((("d1-probe|v2|title=借我六步·D1探针|level1=" .. r1) .. "|level2=") .. r2) .. "|bad-width=") .. r3) .. "|bad-char=") .. r4) .. "|bad-start=") .. r5) .. "|keys=") .. tostring(count)) .. "|box=") .. tostring(bx)) .. ",") .. tostring(by)) .. "|view=") .. tostring(w)) .. "x") .. tostring(h)) .. "|level1=") .. level1Text) -- 123
	end -- 119
	draw() -- 129
	log((("boot: probe v2 mounted, view=" .. tostring(w)) .. "x") .. tostring(h)) -- 130
	log((((((((("selftest summary level1=" .. r1) .. " level2=") .. r2) .. " bad-width=") .. r3) .. " bad-char=") .. r4) .. " bad-start=") .. r5) -- 131
	refresh() -- 133
	local function move(key) -- 135
		count = count + 1 -- 136
		if key == "Left" then -- 136
			bx = bx - STEP -- 138
		elseif key == "Right" then -- 138
			bx = bx + STEP -- 140
		elseif key == "Up" then -- 140
			by = by + STEP -- 142
		elseif key == "Down" then -- 142
			by = by - STEP -- 144
		end -- 144
		log((((((((("key " .. key) .. " -> box (") .. tostring(bx)) .. ",") .. tostring(by)) .. ") step=") .. tostring(STEP)) .. " count=") .. tostring(count)) -- 146
		draw() -- 147
		refresh() -- 148
	end -- 135
	root:onKeyDown(function(key) -- 151
		move(key) -- 152
	end) -- 151
	log("input hooked on root") -- 155
end -- 48
return ____exports -- 48