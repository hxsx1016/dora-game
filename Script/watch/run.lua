-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
function ____exports.createArchive() -- 61
	return { -- 62
		childCleared = false, -- 62
		soldierCleared = false, -- 62
		artifactOwned = false, -- 62
		museumPhase = "locked", -- 62
		museumSeen = false -- 62
	} -- 62
end -- 61
function ____exports.createStory(hp, maxHp) -- 135
	if hp == nil then -- 135
		hp = 3 -- 135
	end -- 135
	if maxHp == nil then -- 135
		maxHp = 3 -- 135
	end -- 135
	return { -- 136
		route = "", -- 137
		hp = hp, -- 138
		maxHp = maxHp, -- 139
		hpAtGate = -1, -- 140
		maxHpAtGate = -1, -- 141
		settled = false, -- 142
		phase = "", -- 143
		countTick = 0, -- 144
		phaseTick = 0, -- 145
		handTicks = 0, -- 146
		handDone = false, -- 147
		lineSaid = false, -- 148
		tied = false, -- 149
		carry = false, -- 150
		museumReturn = false, -- 151
		escortDone = false, -- 152
		craftedWeapon = "", -- 153
		equippedWeapon = "", -- 154
		ending = "", -- 155
		cp = nil, -- 156
		segments = {} -- 157
	} -- 157
end -- 135
--- 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
-- 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
function ____exports.createRun(seed, source, archive) -- 235
	if seed == nil then -- 235
		seed = 20261124 -- 235
	end -- 235
	if source == nil then -- 235
		source = "debug" -- 235
	end -- 235
	if archive == nil then -- 235
		archive = ____exports.createArchive() -- 236
	end -- 236
	return { -- 237
		source = source, -- 238
		seed = seed, -- 239
		ticks = 0, -- 240
		roomTicks = {}, -- 241
		roomEnterTick = 0, -- 242
		route = "", -- 243
		inventory = { -- 244
			shield = 0, -- 244
			wedge = 0, -- 244
			ammo = 0, -- 244
			pass = 0, -- 244
			quickbelt = 0, -- 244
			scrap = 0, -- 244
			wood = 0, -- 244
			bell = 0 -- 244
		}, -- 244
		props = {}, -- 245
		taken = {}, -- 246
		joined = false, -- 247
		c1Latch = false, -- 248
		c2Latch = false, -- 249
		checkpoint = 0, -- 250
		finished = false, -- 251
		story = ____exports.createStory(), -- 252
		archive = archive, -- 253
		log = {} -- 254
	} -- 254
end -- 235
____exports.MUSEUM_PHASES = { -- 40
	"locked", -- 40
	"well_open", -- 40
	"well_reflect", -- 40
	"hall_walk", -- 40
	"lamp_turn", -- 40
	"return_cabinet", -- 40
	"done" -- 40
} -- 40
function ____exports.isMuseumPhase(value) -- 42
	local i = 0 -- 43
	do -- 43
		i = 0 -- 44
		while i < #____exports.MUSEUM_PHASES do -- 44
			if ____exports.MUSEUM_PHASES[i + 1] == value then -- 44
				return true -- 46
			end -- 46
			i = i + 1 -- 44
		end -- 44
	end -- 44
	return false -- 49
end -- 42
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 162
function ____exports.createTrial(seed) -- 175
	local run = ____exports.createRun(seed, "trial") -- 176
	run.trial = { -- 177
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 177
		hp = 3, -- 177
		lost = false, -- 177
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 178
		offers = {}, -- 178
		room = "" -- 178
	} -- 178
	return run -- 179
end -- 175
function ____exports.draftRoom(trial, room) -- 182
	if trial.room == room then -- 182
		return -- 183
	end -- 183
	trial.room = room -- 184
	local pool = {"vitality", "reload", "guard", "craft"} -- 185
	trial.offers = {} -- 186
	while #trial.offers < 3 do -- 186
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 188
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 189
		local ____trial_offers_0 = trial.offers -- 189
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 190
	end -- 190
end -- 182
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 259
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 260
end -- 259
function ____exports.mmss(ticks) -- 263
	local total = math.floor(ticks / 60) -- 264
	local m = math.floor(total / 60) -- 265
	local s = total % 60 -- 266
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 267
end -- 263
return ____exports -- 263