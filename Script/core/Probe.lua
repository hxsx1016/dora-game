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
local Size = ____Dora.Size -- 10
local Vec2 = ____Dora.Vec2 -- 10
local View = ____Dora.View -- 10
local ____levels = require("Script.game.levels") -- 11
local describeLevel = ____levels.describeLevel -- 11
local loadLevel = ____levels.loadLevel -- 11
local parseLevel = ____levels.parseLevel -- 11
local ____turn = require("Script.game.turn") -- 12
local advance = ____turn.advance -- 12
local echoAt = ____turn.echoAt -- 12
local shownGroups = ____turn.shownGroups -- 12
local start = ____turn.start -- 12
local ____session = require("Script.game.session") -- 13
local createSession = ____session.createSession -- 13
local dispatch = ____session.dispatch -- 13
local FONT = "sarasa-mono-sc-regular" -- 15
local MARKER = "d1-probe.result" -- 16
local LOG = "probe.log" -- 17
local STEP = 32 -- 18
local logs = {} -- 20
local marker = "" -- 21
local function log(text) -- 23
	logs[#logs + 1] = text -- 24
	Content:save( -- 25
		LOG, -- 25
		table.concat(logs, "\n") -- 25
	) -- 25
end -- 23
local function writeMarker(text) -- 28
	marker = text -- 29
	Content:save(MARKER, marker) -- 30
end -- 28
--- 依次送命令，返回最后一个结果；每一步写日志。
local function runSeq(level, commands) -- 34
	local state = start(level) -- 35
	local result = {state = state, outcome = "ok"} -- 36
	do -- 36
		local i = 0 -- 37
		while i < #commands do -- 37
			local command = commands[i + 1] -- 38
			result = advance(level, state, command) -- 39
			state = result.state -- 40
			log((((((((((("d2 step " .. tostring(i + 1)) .. " ") .. command) .. " -> ") .. result.outcome) .. " body=") .. tostring(state.body.x)) .. ",") .. tostring(state.body.y)) .. " ticks=") .. tostring(state.ticks)) -- 41
			i = i + 1 -- 37
		end -- 37
	end -- 37
	return result -- 44
end -- 34
--- T12：录 LL、确认、走 RR，第二个右移应被 A 门挡住并返回原状态对象。
local function checkT12() -- 48
	local level = loadLevel("level2") -- 49
	local before = runSeq(level, {"L", "L", "Confirm", "R"}) -- 50
	local after = advance(level, before.state, "R") -- 51
	local echo = echoAt(level, after.state, after.state.ticks) -- 52
	local sameObject = after.state == before.state -- 53
	local ok = after.outcome == "closed_A" and sameObject and after.state.body.x == 3 and after.state.body.y == 0 and echo ~= nil and echo.x == 1 and echo.y == 0 and after.state.ticks == 1 and shownGroups(level, after.state) == "A" -- 54
	log((((((((((("d2 T12 outcome=" .. after.outcome) .. " same=") .. tostring(sameObject)) .. " body=") .. tostring(after.state.body.x)) .. ",") .. tostring(after.state.body.y)) .. " ticks=") .. tostring(after.state.ticks)) .. " open=") .. shownGroups(level, after.state)) -- 59
	return (((((ok and "ok" or "fail") .. "(closed_A,same=") .. tostring(sameObject)) .. ",open=") .. shownGroups(level, after.state)) .. ")" -- 62
end -- 48
--- T15：录 WLL、确认、走 RRRR，第四拍通关，只有 B 门开启。
local function checkT15() -- 66
	local level = loadLevel("level2") -- 67
	local result = runSeq(level, { -- 68
		"W", -- 68
		"L", -- 68
		"L", -- 68
		"Confirm", -- 68
		"R", -- 68
		"R", -- 68
		"R", -- 68
		"R" -- 68
	}) -- 68
	local echo = echoAt(level, result.state, result.state.ticks) -- 69
	local ok = result.outcome == "won" and result.state.body.x == 6 and result.state.body.y == 0 and echo ~= nil and echo.x == 0 and echo.y == 0 and result.state.ticks == 4 and shownGroups(level, result.state) == "B" -- 70
	log((((((((("d2 T15 outcome=" .. result.outcome) .. " body=") .. tostring(result.state.body.x)) .. ",") .. tostring(result.state.body.y)) .. " ticks=") .. tostring(result.state.ticks)) .. " open=") .. shownGroups(level, result.state)) -- 75
	return (((ok and "ok" or "fail") .. "(won,open=") .. shownGroups(level, result.state)) .. ")" -- 77
end -- 66
--- 用会话层跑一串命令，返回最后一个结果。
local function runSession(session, commands) -- 81
	local result = session.last -- 82
	do -- 82
		local i = 0 -- 83
		while i < #commands do -- 83
			result = dispatch(session, commands[i + 1]) -- 84
			log((((((((((((((("d2 session step " .. tostring(i + 1)) .. " ") .. commands[i + 1]) .. " -> ") .. result.outcome) .. " phase=") .. session.state.phase) .. " body=") .. tostring(session.state.body.x)) .. ",") .. tostring(session.state.body.y)) .. " path=") .. tostring(#session.state.path)) .. " ticks=") .. tostring(session.state.ticks)) -- 85
			i = i + 1 -- 83
		end -- 83
	end -- 83
	return result -- 89
end -- 81
--- T04：第一关连续 W×6，第六步应只自动确认一次，落点取路径末项。
local function checkT04() -- 93
	local session = createSession(loadLevel("level1")) -- 94
	local result = runSession(session, { -- 95
		"W", -- 95
		"W", -- 95
		"W", -- 95
		"W", -- 95
		"W", -- 95
		"W" -- 95
	}) -- 95
	local echo = echoAt( -- 96
		loadLevel("level1"), -- 96
		result.state, -- 96
		0 -- 96
	) -- 96
	local ok = result.outcome == "auto_confirmed" and result.state.phase == "PLAY" and #result.state.path == 6 and result.state.ticks == 0 and result.state.body.x == 1 and result.state.body.y == 0 and echo ~= nil and echo.x == 1 and echo.y == 0 -- 97
	return (((((ok and "ok" or "fail") .. "(auto_confirmed,path=") .. tostring(#result.state.path)) .. ",phase=") .. result.state.phase) .. ")" -- 103
end -- 93
--- T19 + T20：重走保留路径，第二次四拍通关。
local function checkT19T20() -- 107
	local session = createSession(loadLevel("level2")) -- 108
	runSession(session, { -- 109
		"W", -- 109
		"L", -- 109
		"L", -- 109
		"Confirm", -- 109
		"W", -- 109
		"R", -- 109
		"R" -- 109
	}) -- 109
	local retried = runSession(session, {"Retry"}) -- 110
	local retryOk = retried.outcome == "retried" and retried.state.phase == "PLAY" and #retried.state.path == 3 and retried.state.ticks == 0 and retried.state.body.x == 2 and retried.state.body.y == 0 -- 111
	local won = runSession(session, {"R", "R", "R", "R"}) -- 116
	local echo = echoAt(session.level, won.state, won.state.ticks) -- 117
	local wonOk = won.outcome == "won" and won.state.body.x == 6 and won.state.body.y == 0 and echo ~= nil and echo.x == 0 and echo.y == 0 and won.state.ticks == 4 and shownGroups(session.level, won.state) == "B" -- 118
	local ok = retryOk and wonOk -- 123
	return (((((ok and "ok" or "fail") .. "(retried=") .. tostring(retryOk)) .. ",won=") .. tostring(wonOk)) .. ")" -- 124
end -- 107
--- T21 + T22：重录清空路径，回起点，之后从 REC 重新记录。
local function checkT21T22() -- 128
	local session = createSession(loadLevel("level2")) -- 129
	runSession(session, { -- 130
		"W", -- 130
		"L", -- 130
		"L", -- 130
		"Confirm", -- 130
		"R", -- 130
		"R" -- 130
	}) -- 130
	local rerecorded = runSession(session, {"Rerecord"}) -- 131
	local reOk = rerecorded.outcome == "rerecorded" and rerecorded.state.phase == "REC" and #rerecorded.state.path == 0 and rerecorded.state.body.x == 2 and rerecorded.state.body.y == 0 -- 132
	local after = runSession(session, {"L"}) -- 136
	local ok = after.outcome == "ok" and after.state.phase == "REC" and #after.state.path == 1 and after.state.body.x == 1 and after.state.body.y == 0 -- 137
	return (((((reOk and ok and "ok" or "fail") .. "(rerecorded=") .. tostring(reOk)) .. ",rel=") .. tostring(ok)) .. ")" -- 141
end -- 128
--- 一次自检：跑好/坏输入，返回 "ok" 或错误摘要。
local function checkParse(name, input, shouldPass) -- 145
	local detail = "" -- 146
	local passed = false -- 147
	do -- 147
		local function ____catch(____error) -- 147
			detail = "error:" .. tostring(____error) -- 153
			passed = shouldPass == false -- 154
		end -- 154
		local ____try, ____hasReturned = pcall(function() -- 154
			local level = parseLevel(name, input) -- 149
			detail = describeLevel(level) -- 150
			passed = shouldPass -- 151
		end) -- 151
		if not ____try then -- 151
			____catch(____hasReturned) -- 151
		end -- 151
	end -- 151
	log((("selftest " .. name) .. (passed == true and " PASS " or " FAIL ")) .. detail) -- 156
	return passed == true and "ok" or ("fail(" .. detail) .. ")" -- 157
end -- 145
____exports.Probe = __TS__Class() -- 160
local Probe = ____exports.Probe -- 160
Probe.name = "Probe" -- 160
function Probe.prototype.____constructor(self) -- 160
end -- 160
function Probe.mount(self, root) -- 161
	local w = View.size.width -- 162
	local h = View.size.height -- 163
	local r1 = checkParse("level1", "aS.AE", true) -- 166
	local r2 = checkParse("level2", "baS.ABE", true) -- 167
	local r3 = checkParse("bad-width", "aS.AE\nS...", false) -- 168
	local r4 = checkParse("bad-char", "aX.AE", false) -- 169
	local r5 = checkParse("bad-start", "a.AE", false) -- 170
	local t12 = checkT12() -- 172
	local t15 = checkT15() -- 173
	local t04 = checkT04() -- 174
	local t19 = checkT19T20() -- 175
	local t21 = checkT21T22() -- 176
	local level1Text = "" -- 179
	do -- 179
		local function ____catch(____error) -- 179
			level1Text = "error:" .. tostring(____error) -- 183
		end -- 183
		local ____try, ____hasReturned = pcall(function() -- 183
			level1Text = describeLevel(parseLevel("level1", "aS.AE")) -- 181
		end) -- 181
		if not ____try then -- 181
			____catch(____hasReturned) -- 181
		end -- 181
	end -- 181
	local title = Label(FONT, 44, false) -- 186
	if title ~= nil then -- 186
		title.text = "借我六步 · D2 回合规则" -- 188
		title.color = Color(244, 239, 230, 255) -- 189
		title.alignment = "Center" -- 190
		title.anchor = Vec2(0.5, 1) -- 191
		root:addChild(title) -- 192
	end -- 192
	local hint = Label(FONT, 18, false) -- 195
	if hint ~= nil then -- 195
		hint.text = "方向键移动方块 · 每次一格 32px · 随窗口重排" -- 197
		hint.color = Color(158, 150, 140, 255) -- 198
		hint.alignment = "Center" -- 199
		hint.anchor = Vec2(0.5, 1) -- 200
		root:addChild(hint) -- 201
	end -- 201
	local levelLine = Label(FONT, 18, false) -- 204
	if levelLine ~= nil then -- 204
		levelLine.text = "首关 aS.AE · " .. level1Text -- 206
		levelLine.color = Color(196, 186, 172, 255) -- 207
		levelLine.alignment = "Center" -- 208
		levelLine.anchor = Vec2(0.5, 0) -- 209
		root:addChild(levelLine) -- 210
	end -- 210
	local status = Label(FONT, 18, false) -- 213
	if status ~= nil then -- 213
		status.color = Color(232, 197, 138, 255) -- 215
		status.alignment = "Center" -- 216
		status.anchor = Vec2(0.5, 0) -- 217
		root:addChild(status) -- 218
	end -- 218
	local box = DrawNode() -- 221
	root:addChild(box) -- 222
	local vw = w -- 225
	local vh = h -- 226
	local bx = w / 2 -- 227
	local by = h / 2 -- 228
	local count = 0 -- 229
	local function draw() -- 231
		box:clear() -- 232
		box:drawRect( -- 233
			Rect(bx - 24, by - 24, 48, 48), -- 233
			Color(232, 197, 138, 255) -- 233
		) -- 233
		box:drawRect( -- 234
			Rect(bx - 24, by - 24, 48, 48), -- 234
			Color(14, 12, 20, 120), -- 234
			2, -- 234
			Color(244, 239, 230, 255) -- 234
		) -- 234
	end -- 231
	local function refresh() -- 237
		if status ~= nil then -- 237
			status.text = (((((((("按键 " .. tostring(count)) .. " 次 · 方块 (") .. tostring(bx)) .. ", ") .. tostring(by)) .. ") · view ") .. tostring(vw)) .. "x") .. tostring(vh) -- 239
		end -- 239
		writeMarker((((((((((((((((((((((((((((((("d1-probe|v3|title=借我六步·D2回合规则|level1=" .. r1) .. "|level2=") .. r2) .. "|bad-width=") .. r3) .. "|bad-char=") .. r4) .. "|bad-start=") .. r5) .. "|keys=") .. tostring(count)) .. "|box=") .. tostring(bx)) .. ",") .. tostring(by)) .. "|view=") .. tostring(vw)) .. "x") .. tostring(vh)) .. "|level1=") .. level1Text) .. "|t12=") .. t12) .. "|t15=") .. t15) .. "|t04=") .. t04) .. "|t19=") .. t19) .. "|t21=") .. t21) -- 241
	end -- 237
	local function layout(nw, nh) -- 250
		vw = nw -- 251
		vh = nh -- 252
		root.size = Size(nw, nh) -- 253
		root.position = Vec2(-nw / 2, -nh / 2) -- 254
		if title ~= nil then -- 254
			title.position = Vec2(nw / 2, nh - 200) -- 256
		end -- 256
		if hint ~= nil then -- 256
			hint.position = Vec2(nw / 2, nh - 260) -- 259
		end -- 259
		if levelLine ~= nil then -- 259
			levelLine.position = Vec2(nw / 2, 244) -- 262
		end -- 262
		if status ~= nil then -- 262
			status.position = Vec2(nw / 2, 200) -- 265
		end -- 265
		bx = nw / 2 -- 267
		by = nh / 2 -- 268
		draw() -- 269
		refresh() -- 270
	end -- 250
	layout(w, h) -- 273
	log((("boot: probe v3 mounted, view=" .. tostring(w)) .. "x") .. tostring(h)) -- 274
	log((((((((((((((((((("selftest summary level1=" .. r1) .. " level2=") .. r2) .. " bad-width=") .. r3) .. " bad-char=") .. r4) .. " bad-start=") .. r5) .. " t12=") .. t12) .. " t15=") .. t15) .. " t04=") .. t04) .. " t19=") .. t19) .. " t21=") .. t21) -- 275
	root:schedule(function(dt) -- 279
		local nw = View.size.width -- 280
		local nh = View.size.height -- 281
		if nw ~= vw or nh ~= vh then -- 281
			log((((((("resize " .. tostring(vw)) .. "x") .. tostring(vh)) .. " -> ") .. tostring(nw)) .. "x") .. tostring(nh)) -- 283
			layout(nw, nh) -- 284
		end -- 284
		return false -- 286
	end) -- 279
	local function move(key) -- 289
		count = count + 1 -- 290
		if key == "Left" then -- 290
			bx = bx - STEP -- 292
		elseif key == "Right" then -- 292
			bx = bx + STEP -- 294
		elseif key == "Up" then -- 294
			by = by + STEP -- 296
		elseif key == "Down" then -- 296
			by = by - STEP -- 298
		end -- 298
		log((((((((("key " .. key) .. " -> box (") .. tostring(bx)) .. ",") .. tostring(by)) .. ") step=") .. tostring(STEP)) .. " count=") .. tostring(count)) -- 300
		draw() -- 301
		refresh() -- 302
	end -- 289
	root:onKeyDown(function(key) -- 305
		move(key) -- 306
	end) -- 305
	log("input hooked on root") -- 309
end -- 161
return ____exports -- 161