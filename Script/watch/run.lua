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
function ____exports.createStoryTalents(seed) -- 144
	if seed == nil then -- 144
		seed = 20261124 -- 144
	end -- 144
	return { -- 145
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 146
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 147
		offers = {}, -- 148
		room = "" -- 149
	} -- 149
end -- 144
function ____exports.createStory(hp, maxHp, seed) -- 153
	if hp == nil then -- 153
		hp = 3 -- 153
	end -- 153
	if maxHp == nil then -- 153
		maxHp = 3 -- 153
	end -- 153
	if seed == nil then -- 153
		seed = 20261124 -- 153
	end -- 153
	return { -- 154
		route = "", -- 155
		hp = hp, -- 156
		maxHp = maxHp, -- 157
		hpAtGate = -1, -- 158
		maxHpAtGate = -1, -- 159
		settled = false, -- 160
		phase = "", -- 161
		countTick = 0, -- 162
		phaseTick = 0, -- 163
		handTicks = 0, -- 164
		handDone = false, -- 165
		lineSaid = false, -- 166
		tied = false, -- 167
		carry = false, -- 168
		museumReturn = false, -- 169
		escortDone = false, -- 170
		craftedWeapon = "", -- 171
		equippedWeapon = "", -- 172
		ending = "", -- 173
		cp = nil, -- 174
		segments = {}, -- 175
		talents = ____exports.createStoryTalents(seed) -- 176
	} -- 176
end -- 153
--- 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
-- 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
function ____exports.createRun(seed, source, archive) -- 258
	if seed == nil then -- 258
		seed = 20261124 -- 258
	end -- 258
	if source == nil then -- 258
		source = "debug" -- 258
	end -- 258
	if archive == nil then -- 258
		archive = ____exports.createArchive() -- 259
	end -- 259
	return { -- 260
		source = source, -- 261
		seed = seed, -- 262
		ticks = 0, -- 263
		roomTicks = {}, -- 264
		roomEnterTick = 0, -- 265
		route = "", -- 266
		inventory = { -- 267
			shield = 0, -- 267
			wedge = 0, -- 267
			ammo = 0, -- 267
			pass = 0, -- 267
			quickbelt = 0, -- 267
			scrap = 0, -- 267
			wood = 0, -- 267
			bell = 0 -- 267
		}, -- 267
		props = {}, -- 268
		taken = {}, -- 269
		joined = false, -- 270
		c1Latch = false, -- 271
		c2Latch = false, -- 272
		checkpoint = 0, -- 273
		finished = false, -- 274
		story = ____exports.createStory(3, 3, seed), -- 275
		archive = archive, -- 276
		log = {} -- 277
	} -- 277
end -- 258
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
____exports.talentNames = {vitality = "厚甲·体力+1", reload = "熟铳·装填减6拍", guard = "护身·受击保护加12拍", craft = "巧手·制楔减6拍"} -- 181
function ____exports.createTrial(seed) -- 194
	local run = ____exports.createRun(seed, "trial") -- 195
	run.trial = { -- 196
		randomState = 1 + math.floor(math.abs(seed)) % 2147483646, -- 196
		hp = 3, -- 196
		lost = false, -- 196
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 197
		offers = {}, -- 197
		room = "" -- 197
	} -- 197
	return run -- 198
end -- 194
function ____exports.draftTalentOffers(target, room) -- 201
	if target.room == room then -- 201
		return -- 202
	end -- 202
	target.room = room -- 203
	local pool = {"vitality", "reload", "guard", "craft"} -- 204
	target.offers = {} -- 205
	while #target.offers < 3 do -- 205
		target.randomState = target.randomState * 48271 % 2147483647 -- 207
		local index = math.floor(target.randomState / 2147483647 * #pool) -- 208
		local ____target_offers_0 = target.offers -- 208
		____target_offers_0[#____target_offers_0 + 1] = __TS__ArraySplice(pool, index, 1)[1] -- 209
	end -- 209
end -- 201
function ____exports.draftRoom(trial, room) -- 213
	____exports.draftTalentOffers(trial, room) -- 214
end -- 213
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 282
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 283
end -- 282
function ____exports.mmss(ticks) -- 286
	local total = math.floor(ticks / 60) -- 287
	local m = math.floor(total / 60) -- 288
	local s = total % 60 -- 289
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 290
end -- 286
return ____exports -- 286