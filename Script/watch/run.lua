-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
function ____exports.createRun(seed) -- 95
	if seed == nil then -- 95
		seed = 20261124 -- 95
	end -- 95
	return { -- 96
		seed = seed, -- 97
		ticks = 0, -- 98
		roomTicks = {}, -- 99
		roomEnterTick = 0, -- 100
		route = "", -- 101
		inventory = { -- 102
			shield = 0, -- 102
			wedge = 0, -- 102
			ammo = 0, -- 102
			pass = 0, -- 102
			quickbelt = 0, -- 102
			scrap = 0 -- 102
		}, -- 102
		props = {}, -- 103
		taken = {}, -- 104
		joined = false, -- 105
		c1Latch = false, -- 106
		c2Latch = false, -- 107
		checkpoint = 0, -- 108
		finished = false, -- 109
		log = {} -- 110
	} -- 110
end -- 95
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 35
function ____exports.createTrial(seed) -- 48
	local run = ____exports.createRun(seed) -- 49
	run.trial = { -- 50
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 50
		hp = 3, -- 50
		lost = false, -- 50
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 51
		offers = {}, -- 51
		room = "" -- 51
	} -- 51
	return run -- 52
end -- 48
function ____exports.draftRoom(trial, room) -- 55
	if trial.room == room then -- 55
		return -- 56
	end -- 56
	trial.room = room -- 57
	local pool = {"vitality", "reload", "guard", "craft"} -- 58
	trial.offers = {} -- 59
	while #trial.offers < 3 do -- 59
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 61
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 62
		local ____trial_offers_0 = trial.offers -- 62
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 63
	end -- 63
end -- 55
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 115
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 116
end -- 115
function ____exports.mmss(ticks) -- 119
	local total = math.floor(ticks / 60) -- 120
	local m = math.floor(total / 60) -- 121
	local s = total % 60 -- 122
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 123
end -- 119
return ____exports -- 119