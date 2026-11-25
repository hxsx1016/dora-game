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
function ____exports.createStory(hp, maxHp) -- 131
	if hp == nil then -- 131
		hp = 3 -- 131
	end -- 131
	if maxHp == nil then -- 131
		maxHp = 3 -- 131
	end -- 131
	return { -- 132
		route = "", -- 133
		hp = hp, -- 134
		maxHp = maxHp, -- 135
		hpAtGate = -1, -- 136
		maxHpAtGate = -1, -- 137
		settled = false, -- 138
		phase = "", -- 139
		countTick = 0, -- 140
		phaseTick = 0, -- 141
		handTicks = 0, -- 142
		handDone = false, -- 143
		lineSaid = false, -- 144
		tied = false, -- 145
		carry = false, -- 146
		escortDone = false, -- 147
		craftedWeapon = "", -- 148
		ending = "", -- 149
		cp = nil, -- 150
		segments = {} -- 151
	} -- 151
end -- 131
--- 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
-- 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
function ____exports.createRun(seed, source, archive) -- 229
	if seed == nil then -- 229
		seed = 20261124 -- 229
	end -- 229
	if source == nil then -- 229
		source = "debug" -- 229
	end -- 229
	if archive == nil then -- 229
		archive = ____exports.createArchive() -- 230
	end -- 230
	return { -- 231
		source = source, -- 232
		seed = seed, -- 233
		ticks = 0, -- 234
		roomTicks = {}, -- 235
		roomEnterTick = 0, -- 236
		route = "", -- 237
		inventory = { -- 238
			shield = 0, -- 238
			wedge = 0, -- 238
			ammo = 0, -- 238
			pass = 0, -- 238
			quickbelt = 0, -- 238
			scrap = 0, -- 238
			wood = 0, -- 238
			bell = 0 -- 238
		}, -- 238
		props = {}, -- 239
		taken = {}, -- 240
		joined = false, -- 241
		c1Latch = false, -- 242
		c2Latch = false, -- 243
		checkpoint = 0, -- 244
		finished = false, -- 245
		story = ____exports.createStory(), -- 246
		archive = archive, -- 247
		log = {} -- 248
	} -- 248
end -- 229
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
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 156
function ____exports.createTrial(seed) -- 169
	local run = ____exports.createRun(seed, "trial") -- 170
	run.trial = { -- 171
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 171
		hp = 3, -- 171
		lost = false, -- 171
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 172
		offers = {}, -- 172
		room = "" -- 172
	} -- 172
	return run -- 173
end -- 169
function ____exports.draftRoom(trial, room) -- 176
	if trial.room == room then -- 176
		return -- 177
	end -- 177
	trial.room = room -- 178
	local pool = {"vitality", "reload", "guard", "craft"} -- 179
	trial.offers = {} -- 180
	while #trial.offers < 3 do -- 180
		trial.randomState = trial.randomState * 48271 % 2147483647 -- 182
		local index = math.floor(trial.randomState / 2147483647 * #pool) -- 183
		local ____trial_offers_0 = trial.offers -- 183
		____trial_offers_0[#____trial_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 184
	end -- 184
end -- 176
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 253
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 254
end -- 253
function ____exports.mmss(ticks) -- 257
	local total = math.floor(ticks / 60) -- 258
	local m = math.floor(total / 60) -- 259
	local s = total % 60 -- 260
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 261
end -- 257
return ____exports -- 257