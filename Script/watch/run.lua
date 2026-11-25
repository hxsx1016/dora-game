-- [ts]: run.ts
local ____exports = {} -- 1
function ____exports.createRun(seed) -- 59
	if seed == nil then -- 59
		seed = 20261124 -- 59
	end -- 59
	return { -- 60
		seed = seed, -- 61
		ticks = 0, -- 62
		roomTicks = {}, -- 63
		roomEnterTick = 0, -- 64
		route = "", -- 65
		inventory = { -- 66
			shield = 0, -- 66
			wedge = 0, -- 66
			ammo = 0, -- 66
			pass = 0, -- 66
			quickbelt = 0 -- 66
		}, -- 66
		props = {}, -- 67
		taken = {}, -- 68
		joined = false, -- 69
		c1Latch = false, -- 70
		c2Latch = false, -- 71
		checkpoint = 0, -- 72
		finished = false, -- 73
		log = {} -- 74
	} -- 74
end -- 59
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 79
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 80
end -- 79
function ____exports.mmss(ticks) -- 83
	local total = math.floor(ticks / 60) -- 84
	local m = math.floor(total / 60) -- 85
	local s = total % 60 -- 86
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 87
end -- 83
return ____exports -- 83