-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
function ____exports.createStory(hp, maxHp) -- 76
	if hp == nil then -- 76
		hp = 3 -- 76
	end -- 76
	if maxHp == nil then -- 76
		maxHp = 3 -- 76
	end -- 76
	return { -- 77
		route = "", -- 78
		hp = hp, -- 79
		maxHp = maxHp, -- 80
		hpAtGate = -1, -- 81
		maxHpAtGate = -1, -- 82
		settled = false, -- 83
		phase = "", -- 84
		countTick = 0, -- 85
		phaseTick = 0, -- 86
		handTicks = 0, -- 87
		handDone = false, -- 88
		lineSaid = false, -- 89
		tied = false, -- 90
		carry = false, -- 91
		escortDone = false -- 92
	} -- 92
end -- 76
function ____exports.createRun(seed) -- 159
	if seed == nil then -- 159
		seed = 20261124 -- 159
	end -- 159
	return { -- 160
		seed = seed, -- 161
		ticks = 0, -- 162
		roomTicks = {}, -- 163
		roomEnterTick = 0, -- 164
		route = "", -- 165
		inventory = { -- 166
			shield = 0, -- 166
			wedge = 0, -- 166
			ammo = 0, -- 166
			pass = 0, -- 166
			quickbelt = 0, -- 166
			scrap = 0 -- 166
		}, -- 166
		props = {}, -- 167
		taken = {}, -- 168
		joined = false, -- 169
		c1Latch = false, -- 170
		c2Latch = false, -- 171
		checkpoint = 0, -- 172
		finished = false, -- 173
		story = ____exports.createStory(), -- 174
		log = {} -- 175
	} -- 175
end -- 159
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 97
function ____exports.createTrial(seed) -- 110
	local run = ____exports.createRun(seed) -- 111
	run.trial = { -- 112
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 112
		hp = 3, -- 112
		lost = false, -- 112
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 113
		offers = {}, -- 113
		room = "" -- 113
	} -- 113
	return run -- 114
end -- 110
function ____exports.draftRoom(trial, room) -- 117
	if trial.room == room then -- 117
		return -- 118
	end -- 118
	trial.room = room -- 119
	local pool = {"vitality", "reload", "guard", "craft"} -- 120
	trial.offers = {} -- 121
	while #trial.offers < 3 do -- 121
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 123
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 124
		local ____trial_offers_0 = trial.offers -- 124
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 125
	end -- 125
end -- 117
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 180
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 181
end -- 180
function ____exports.mmss(ticks) -- 184
	local total = math.floor(ticks / 60) -- 185
	local m = math.floor(total / 60) -- 186
	local s = total % 60 -- 187
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 188
end -- 184
return ____exports -- 184