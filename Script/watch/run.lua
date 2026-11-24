-- [ts]: run.ts
local ____exports = {} -- 1
function ____exports.createRun(seed) -- 58
	if seed == nil then -- 58
		seed = 20261124 -- 58
	end -- 58
	return { -- 59
		seed = seed, -- 60
		ticks = 0, -- 61
		roomTicks = {}, -- 62
		roomEnterTick = 0, -- 63
		route = "", -- 64
		inventory = { -- 65
			shield = 0, -- 65
			wedge = 0, -- 65
			ammo = 0, -- 65
			pass = 0, -- 65
			quickbelt = 0 -- 65
		}, -- 65
		props = {}, -- 66
		taken = {}, -- 67
		joined = false, -- 68
		latchOpen = false, -- 69
		checkpoint = 0, -- 70
		finished = false, -- 71
		log = {} -- 72
	} -- 72
end -- 58
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 77
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 78
end -- 77
function ____exports.mmss(ticks) -- 81
	local total = math.floor(ticks / 60) -- 82
	local m = math.floor(total / 60) -- 83
	local s = total % 60 -- 84
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 85
end -- 81
return ____exports -- 81