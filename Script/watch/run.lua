-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
function ____exports.createStory(hp, maxHp) -- 72
	if hp == nil then -- 72
		hp = 3 -- 72
	end -- 72
	if maxHp == nil then -- 72
		maxHp = 3 -- 72
	end -- 72
	return { -- 73
		route = "", -- 74
		hp = hp, -- 75
		maxHp = maxHp, -- 76
		hpAtGate = -1, -- 77
		maxHpAtGate = -1, -- 78
		settled = false, -- 79
		phase = "", -- 80
		countTick = 0, -- 81
		phaseTick = 0, -- 82
		handTicks = 0, -- 83
		handDone = false, -- 84
		lineSaid = false, -- 85
		tied = false -- 86
	} -- 86
end -- 72
function ____exports.createRun(seed) -- 153
	if seed == nil then -- 153
		seed = 20261124 -- 153
	end -- 153
	return { -- 154
		seed = seed, -- 155
		ticks = 0, -- 156
		roomTicks = {}, -- 157
		roomEnterTick = 0, -- 158
		route = "", -- 159
		inventory = { -- 160
			shield = 0, -- 160
			wedge = 0, -- 160
			ammo = 0, -- 160
			pass = 0, -- 160
			quickbelt = 0, -- 160
			scrap = 0 -- 160
		}, -- 160
		props = {}, -- 161
		taken = {}, -- 162
		joined = false, -- 163
		c1Latch = false, -- 164
		c2Latch = false, -- 165
		checkpoint = 0, -- 166
		finished = false, -- 167
		story = ____exports.createStory(), -- 168
		log = {} -- 169
	} -- 169
end -- 153
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 91
function ____exports.createTrial(seed) -- 104
	local run = ____exports.createRun(seed) -- 105
	run.trial = { -- 106
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 106
		hp = 3, -- 106
		lost = false, -- 106
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 107
		offers = {}, -- 107
		room = "" -- 107
	} -- 107
	return run -- 108
end -- 104
function ____exports.draftRoom(trial, room) -- 111
	if trial.room == room then -- 111
		return -- 112
	end -- 112
	trial.room = room -- 113
	local pool = {"vitality", "reload", "guard", "craft"} -- 114
	trial.offers = {} -- 115
	while #trial.offers < 3 do -- 115
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 117
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 118
		local ____trial_offers_0 = trial.offers -- 118
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 119
	end -- 119
end -- 111
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 174
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 175
end -- 174
function ____exports.mmss(ticks) -- 178
	local total = math.floor(ticks / 60) -- 179
	local m = math.floor(total / 60) -- 180
	local s = total % 60 -- 181
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 182
end -- 178
return ____exports -- 178