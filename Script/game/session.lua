-- [ts]: session.ts
local ____exports = {} -- 1
local ____turn = require("Script.game.turn") -- 10
local advance = ____turn.advance -- 10
local start = ____turn.start -- 10
function ____exports.createSession(level) -- 21
	local state = start(level) -- 22
	return {level = level, state = state, seq = 0, last = {state = state, outcome = "ok"}} -- 23
end -- 21
--- 派发一个命令。若 expectedSeq 与当前 seq 不一致，说明是重复/过期的输入，
-- 直接返回上一次结果，不再推进局面（防止长按把第六步确认触发两次）。
function ____exports.dispatch(session, command, expectedSeq) -- 30
	if expectedSeq ~= nil and expectedSeq ~= session.seq then -- 30
		return session.last -- 32
	end -- 32
	local result = advance(session.level, session.state, command) -- 34
	session.state = result.state -- 35
	session.seq = session.seq + 1 -- 36
	session.last = result -- 37
	return result -- 38
end -- 30
--- 重新载入当前关卡（换关或整局重开）。
function ____exports.resetSession(session) -- 42
	return ____exports.createSession(session.level) -- 43
end -- 42
return ____exports -- 42