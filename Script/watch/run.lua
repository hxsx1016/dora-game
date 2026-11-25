-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
function ____exports.createArchive() -- 47
	return { -- 48
		childCleared = false, -- 48
		soldierCleared = false, -- 48
		artifactOwned = false, -- 48
		museumPhase = "locked", -- 48
		museumSeen = false -- 48
	} -- 48
end -- 47
function ____exports.createStory(hp, maxHp) -- 117
	if hp == nil then -- 117
		hp = 3 -- 117
	end -- 117
	if maxHp == nil then -- 117
		maxHp = 3 -- 117
	end -- 117
	return { -- 118
		route = "", -- 119
		hp = hp, -- 120
		maxHp = maxHp, -- 121
		hpAtGate = -1, -- 122
		maxHpAtGate = -1, -- 123
		settled = false, -- 124
		phase = "", -- 125
		countTick = 0, -- 126
		phaseTick = 0, -- 127
		handTicks = 0, -- 128
		handDone = false, -- 129
		lineSaid = false, -- 130
		tied = false, -- 131
		carry = false, -- 132
		escortDone = false, -- 133
		craftedWeapon = "", -- 134
		ending = "", -- 135
		cp = nil, -- 136
		segments = {} -- 137
	} -- 137
end -- 117
function ____exports.createRun(seed) -- 206
	if seed == nil then -- 206
		seed = 20261124 -- 206
	end -- 206
	return { -- 207
		seed = seed, -- 208
		ticks = 0, -- 209
		roomTicks = {}, -- 210
		roomEnterTick = 0, -- 211
		route = "", -- 212
		inventory = { -- 213
			shield = 0, -- 213
			wedge = 0, -- 213
			ammo = 0, -- 213
			pass = 0, -- 213
			quickbelt = 0, -- 213
			scrap = 0, -- 213
			wood = 0, -- 213
			bell = 0 -- 213
		}, -- 213
		props = {}, -- 214
		taken = {}, -- 215
		joined = false, -- 216
		c1Latch = false, -- 217
		c2Latch = false, -- 218
		checkpoint = 0, -- 219
		finished = false, -- 220
		story = ____exports.createStory(), -- 221
		archive = ____exports.createArchive(), -- 222
		log = {} -- 223
	} -- 223
end -- 206
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 142
function ____exports.createTrial(seed) -- 155
	local run = ____exports.createRun(seed) -- 156
	run.trial = { -- 157
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 157
		hp = 3, -- 157
		lost = false, -- 157
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 158
		offers = {}, -- 158
		room = "" -- 158
	} -- 158
	return run -- 159
end -- 155
function ____exports.draftRoom(trial, room) -- 162
	if trial.room == room then -- 162
		return -- 163
	end -- 163
	trial.room = room -- 164
	local pool = {"vitality", "reload", "guard", "craft"} -- 165
	trial.offers = {} -- 166
	while #trial.offers < 3 do -- 166
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 168
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 169
		local ____trial_offers_0 = trial.offers -- 169
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 170
	end -- 170
end -- 162
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 228
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 229
end -- 228
function ____exports.mmss(ticks) -- 232
	local total = math.floor(ticks / 60) -- 233
	local m = math.floor(total / 60) -- 234
	local s = total % 60 -- 235
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 236
end -- 232
return ____exports -- 232