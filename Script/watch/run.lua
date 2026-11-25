-- [ts]: run.ts
local ____exports = {} -- 1
function ____exports.createRun(seed) -- 61
	if seed == nil then -- 61
		seed = 20261124 -- 61
	end -- 61
	return { -- 62
		seed = seed, -- 63
		ticks = 0, -- 64
		roomTicks = {}, -- 65
		roomEnterTick = 0, -- 66
		route = "", -- 67
		inventory = { -- 68
			shield = 0, -- 68
			wedge = 0, -- 68
			ammo = 0, -- 68
			pass = 0, -- 68
			quickbelt = 0, -- 68
			scrap = 0 -- 68
		}, -- 68
		props = {}, -- 69
		taken = {}, -- 70
		joined = false, -- 71
		c1Latch = false, -- 72
		c2Latch = false, -- 73
		checkpoint = 0, -- 74
		finished = false, -- 75
		log = {} -- 76
	} -- 76
end -- 61
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 81
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 82
end -- 81
function ____exports.mmss(ticks) -- 85
	local total = math.floor(ticks / 60) -- 86
	local m = math.floor(total / 60) -- 87
	local s = total % 60 -- 88
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 89
end -- 85
return ____exports -- 85