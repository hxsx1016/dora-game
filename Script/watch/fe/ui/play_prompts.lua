-- [ts]: play_prompts.ts
local ____exports = {} -- 1
local ____play = require("Script.watch.play") -- 5
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 5
--- 判断当前房间阶段是否处于电影过场阻塞期（需隐藏战斗虚拟按钮或禁止射瞄）。
function ____exports.isCutsceneBlockingPlay(p) -- 8
	local rk = p.room.key -- 9
	local ph = p.phase -- 10
	if rk == "prologue" and (ph == "prologue-wake" or ph == "prologue-shadow" or ph == "prologue-hide" or ph == "prologue-give" or ph == "prologue-well") then -- 11
		return true -- 14
	end -- 14
	if rk == "gate" then -- 16
		if ph == "gate-hand" then -- 17
			return true -- 17
		end -- 17
		if ph == "gate-count" and p.countTick < GATE_COUNT_END then -- 18
			return true -- 18
		end -- 18
	end -- 18
	if rk == "tower" and (ph == "tower-knock" or ph == "tower-given" or ph == "tower-end") then -- 20
		return true -- 21
	end -- 21
	if rk == "museum" and ph == "museum-knock" then -- 23
		return true -- 24
	end -- 24
	return false -- 26
end -- 8
return ____exports -- 8
