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
function ____exports.createStory(hp, maxHp) -- 133
	if hp == nil then -- 133
		hp = 3 -- 133
	end -- 133
	if maxHp == nil then -- 133
		maxHp = 3 -- 133
	end -- 133
	return { -- 134
		route = "", -- 135
		hp = hp, -- 136
		maxHp = maxHp, -- 137
		hpAtGate = -1, -- 138
		maxHpAtGate = -1, -- 139
		settled = false, -- 140
		phase = "", -- 141
		countTick = 0, -- 142
		phaseTick = 0, -- 143
		handTicks = 0, -- 144
		handDone = false, -- 145
		lineSaid = false, -- 146
		tied = false, -- 147
		carry = false, -- 148
		museumReturn = false, -- 149
		escortDone = false, -- 150
		craftedWeapon = "", -- 151
		ending = "", -- 152
		cp = nil, -- 153
		segments = {} -- 154
	} -- 154
end -- 133
--- 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
-- 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
function ____exports.createRun(seed, source, archive) -- 232
	if seed == nil then -- 232
		seed = 20261124 -- 232
	end -- 232
	if source == nil then -- 232
		source = "debug" -- 232
	end -- 232
	if archive == nil then -- 232
		archive = ____exports.createArchive() -- 233
	end -- 233
	return { -- 234
		source = source, -- 235
		seed = seed, -- 236
		ticks = 0, -- 237
		roomTicks = {}, -- 238
		roomEnterTick = 0, -- 239
		route = "", -- 240
		inventory = { -- 241
			shield = 0, -- 241
			wedge = 0, -- 241
			ammo = 0, -- 241
			pass = 0, -- 241
			quickbelt = 0, -- 241
			scrap = 0, -- 241
			wood = 0, -- 241
			bell = 0 -- 241
		}, -- 241
		props = {}, -- 242
		taken = {}, -- 243
		joined = false, -- 244
		c1Latch = false, -- 245
		c2Latch = false, -- 246
		checkpoint = 0, -- 247
		finished = false, -- 248
		story = ____exports.createStory(), -- 249
		archive = archive, -- 250
		log = {} -- 251
	} -- 251
end -- 232
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
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 159
function ____exports.createTrial(seed) -- 172
	local run = ____exports.createRun(seed, "trial") -- 173
	run.trial = { -- 174
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 174
		hp = 3, -- 174
		lost = false, -- 174
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 175
		offers = {}, -- 175
		room = "" -- 175
	} -- 175
	return run -- 176
end -- 172
function ____exports.draftRoom(trial, room) -- 179
	if trial.room == room then -- 179
		return -- 180
	end -- 180
	trial.room = room -- 181
	local pool = {"vitality", "reload", "guard", "craft"} -- 182
	trial.offers = {} -- 183
	while #trial.offers < 3 do -- 183
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 185
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 186
		local ____trial_offers_0 = trial.offers -- 186
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 187
	end -- 187
end -- 179
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 256
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 257
end -- 256
function ____exports.mmss(ticks) -- 260
	local total = math.floor(ticks / 60) -- 261
	local m = math.floor(total / 60) -- 262
	local s = total % 60 -- 263
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 264
end -- 260
return ____exports -- 260