-- [ts]: audio.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 14
local Audio = ____Dora.Audio -- 14
local AudioBus = ____Dora.AudioBus -- 14
local AudioSource = ____Dora.AudioSource -- 14
local Content = ____Dora.Content -- 14
local Node = ____Dora.Node -- 14
local ALL_TRACKS = { -- 40
	"voice", -- 40
	"wind", -- 40
	"water", -- 40
	"ambience", -- 40
	"sfx" -- 40
} -- 40
local MAX_PLAY_LOG = 256 -- 41
--- 空村铁盆段内 X（与 village_undertable.ts VILLAGE_BASIN_OFFSET_X = 548 保持单一真源对齐）
local VILLAGE_BASIN_OFFSET_X = 548 -- 43
local VILLAGE_BASIN_HIT_RADIUS = 24 -- 44
local VILLAGE_SOFT_HIT_RADIUS = 34 -- 45
local function clamp01(v) -- 47
	return math.max( -- 48
		0, -- 48
		math.min(1, v) -- 48
	) -- 48
end -- 47
--- Dora SSR Lua 运行时中，AudioBus / AudioSource 为带 __call 元表的可调用表（type 为 "table" 而非 "function"）。
-- 统一以 isCallableCtor 判定，避免 5 条逻辑音轨总线与循环声源在实机下退化失效。
local function isCallableCtor(ctor) -- 55
	return ctor ~= nil and (type(ctor) == "function" or type(ctor) == "table") -- 56
end -- 55
local function safeCreateBus() -- 59
	if not isCallableCtor(AudioBus) then -- 59
		return nil -- 61
	end -- 61
	do -- 61
		local function ____catch() -- 61
			return true, nil -- 67
		end -- 67
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 67
			return true, AudioBus() -- 64
		end) -- 64
		if not ____try then -- 64
			____hasReturned, ____returnValue = ____catch() -- 64
		end -- 64
		if ____hasReturned then -- 64
			return ____returnValue -- 63
		end -- 63
	end -- 63
end -- 59
local function safeCreateSource(path, autoRemove, bus) -- 71
	if not isCallableCtor(AudioSource) then -- 71
		return nil -- 77
	end -- 77
	do -- 77
		local function ____catch() -- 77
			return true, nil -- 82
		end -- 82
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 82
			return true, AudioSource(path, autoRemove, bus) -- 80
		end) -- 80
		if not ____try then -- 80
			____hasReturned, ____returnValue = ____catch() -- 80
		end -- 80
		if ____hasReturned then -- 80
			return ____returnValue -- 79
		end -- 79
	end -- 79
end -- 71
local function safeAudioPlay(path, loop) -- 86
	if type(Audio) == "nil" or type(Audio.play) ~= "function" then -- 86
		return 0 -- 88
	end -- 88
	do -- 88
		local function ____catch() -- 88
			return true, 0 -- 93
		end -- 93
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 93
			return true, Audio:play(path, loop) -- 91
		end) -- 91
		if not ____try then -- 91
			____hasReturned, ____returnValue = ____catch() -- 91
		end -- 91
		if ____hasReturned then -- 91
			return ____returnValue -- 90
		end -- 90
	end -- 90
end -- 86
____exports.AudioDirector = __TS__Class() -- 97
local AudioDirector = ____exports.AudioDirector -- 97
AudioDirector.name = "AudioDirector" -- 97
function AudioDirector.prototype.____constructor(self) -- 110
	self.activeSources = {} -- 102
	self.activeHandlers = {} -- 103
	self.activeLoops = {} -- 104
	self.dedupeSet = {} -- 105
	self.playLog = {} -- 106
	self.paused = false -- 107
	self.worldPlaySpeed = 1 -- 108
	self.buses = { -- 111
		voice = safeCreateBus(), -- 112
		wind = safeCreateBus(), -- 113
		water = safeCreateBus(), -- 114
		ambience = safeCreateBus(), -- 115
		sfx = safeCreateBus() -- 116
	} -- 116
	self.trackVolumes = { -- 118
		voice = 1, -- 119
		wind = 1, -- 120
		water = 1, -- 121
		ambience = 1, -- 122
		sfx = 1 -- 123
	} -- 123
	self.trackMuted = { -- 125
		voice = false, -- 126
		wind = false, -- 127
		water = false, -- 128
		ambience = false, -- 129
		sfx = false -- 130
	} -- 130
end -- 110
function AudioDirector.prototype.attachHost(self, parent) -- 135
	if self.hostNode ~= nil then -- 135
		return -- 137
	end -- 137
	local n = Node() -- 139
	n.order = -1 -- 140
	n:addTo(parent) -- 141
	self.hostNode = n -- 142
end -- 135
function AudioDirector.prototype.isPaused(self) -- 145
	return self.paused -- 146
end -- 145
function AudioDirector.prototype.getTrackVolume(self, track) -- 149
	return self.trackVolumes[track] -- 150
end -- 149
function AudioDirector.prototype.setTrackVolume(self, track, volume) -- 153
	local clamped = clamp01(volume) -- 154
	self.trackVolumes[track] = clamped -- 155
	self:syncBusGain(track) -- 156
end -- 153
function AudioDirector.prototype.isTrackMuted(self, track) -- 159
	return self.trackMuted[track] -- 160
end -- 159
function AudioDirector.prototype.setTrackMuted(self, track, muted) -- 163
	self.trackMuted[track] = muted -- 164
	self:syncBusGain(track) -- 165
end -- 163
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 169
	local next = math.max( -- 170
		0.25, -- 170
		math.min(2, speed) -- 170
	) -- 170
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 170
		return -- 172
	end -- 172
	self.worldPlaySpeed = next -- 174
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 175
	local i = 0 -- 176
	do -- 176
		i = 0 -- 177
		while i < #worldTracks do -- 177
			local bus = self.buses[worldTracks[i + 1]] -- 178
			if bus ~= nil then -- 178
				bus.playSpeed = next -- 180
			end -- 180
			i = i + 1 -- 177
		end -- 177
	end -- 177
end -- 169
function AudioDirector.prototype.syncBusGain(self, track) -- 185
	local bus = self.buses[track] -- 186
	if bus ~= nil then -- 186
		bus.volume = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 188
	end -- 188
end -- 185
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq) -- 197
	if volume == nil then -- 197
		volume = 1 -- 201
	end -- 201
	if cueId == nil then -- 201
		cueId = "" -- 202
	end -- 202
	if tick == nil then -- 202
		tick = 0 -- 203
	end -- 203
	if seq == nil then -- 203
		seq = -1 -- 204
	end -- 204
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 204
		return false -- 207
	end -- 207
	if dedupeKey ~= "" then -- 207
		self.dedupeSet[dedupeKey] = true -- 210
	end -- 210
	local cueVol = clamp01(volume) -- 213
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 214
	local effectiveVol = cueVol * trackGain -- 215
	local playedBackend = false -- 216
	if path ~= "" and Content:exist(path) then -- 216
		self:pruneStoppedSources() -- 219
		local bus = self.buses[track] -- 220
		local src = safeCreateSource(path, false, bus) -- 221
		if src ~= nil then -- 221
			src.volume = bus ~= nil and cueVol or effectiveVol -- 224
			src.looping = false -- 225
			if self.hostNode ~= nil then -- 225
				src:addTo(self.hostNode) -- 227
			end -- 227
			playedBackend = src:play() -- 229
			if playedBackend then -- 229
				local ____self_activeSources_0 = self.activeSources -- 229
				____self_activeSources_0[#____self_activeSources_0 + 1] = src -- 231
			else -- 231
				src:removeFromParent(true) -- 233
			end -- 233
		else -- 233
			local handler = safeAudioPlay(path, false) -- 236
			if handler > 0 then -- 236
				local ____self_activeHandlers_1 = self.activeHandlers -- 236
				____self_activeHandlers_1[#____self_activeHandlers_1 + 1] = handler -- 238
				playedBackend = true -- 239
			end -- 239
		end -- 239
	end -- 239
	self:recordLog({ -- 244
		tick = tick, -- 245
		seq = seq, -- 246
		track = track, -- 247
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 248
		dedupeKey = dedupeKey, -- 249
		path = path, -- 250
		volume = clamp01(volume), -- 251
		looped = false, -- 252
		playedBackend = playedBackend -- 253
	}) -- 253
	return true -- 255
end -- 197
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 259
	if volume == nil then -- 259
		volume = 1 -- 263
	end -- 263
	if tick == nil then -- 263
		tick = 0 -- 264
	end -- 264
	local prev = self.activeLoops[loopId] -- 266
	local clampedVol = clamp01(volume) -- 267
	local bus = self.buses[track] -- 268
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 269
	if prev ~= nil and prev.path == path and prev.track == track then -- 269
		prev.volume = clampedVol -- 271
		if prev.source ~= nil then -- 271
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 273
		end -- 273
		return false -- 275
	end -- 275
	if prev ~= nil then -- 275
		self:stopLoop(loopId, 0) -- 278
	end -- 278
	local source -- 281
	local handler -- 282
	local playedBackend = false -- 283
	if path ~= "" and Content:exist(path) then -- 283
		local created = safeCreateSource(path, false, bus) -- 285
		if created ~= nil then -- 285
			created.looping = true -- 287
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 288
			if self.hostNode ~= nil then -- 288
				created:addTo(self.hostNode) -- 290
			end -- 290
			playedBackend = created:play() -- 292
			if playedBackend then -- 292
				source = created -- 294
			else -- 294
				created:removeFromParent(true) -- 296
			end -- 296
		end -- 296
		if not playedBackend then -- 296
			local h = safeAudioPlay(path, true) -- 300
			if h > 0 then -- 300
				handler = h -- 302
				playedBackend = true -- 303
			end -- 303
		end -- 303
	end -- 303
	self.activeLoops[loopId] = { -- 308
		track = track, -- 309
		path = path, -- 310
		volume = clampedVol, -- 311
		source = source, -- 312
		handler = handler -- 313
	} -- 313
	self:recordLog({ -- 315
		tick = tick, -- 316
		seq = -1, -- 317
		track = track, -- 318
		cueId = "loop:" .. loopId, -- 319
		dedupeKey = "loop:" .. loopId, -- 320
		path = path, -- 321
		volume = clampedVol, -- 322
		looped = true, -- 323
		playedBackend = playedBackend -- 324
	}) -- 324
	return true -- 326
end -- 259
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 329
	if fadeTime == nil then -- 329
		fadeTime = 0 -- 329
	end -- 329
	local entry = self.activeLoops[loopId] -- 330
	if entry == nil then -- 330
		return -- 332
	end -- 332
	if entry.source ~= nil then -- 332
		entry.source:stop(fadeTime) -- 335
		entry.source:removeFromParent(true) -- 336
	end -- 336
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 336
		Audio:stop(entry.handler) -- 339
	end -- 339
	__TS__Delete(self.activeLoops, loopId) -- 341
end -- 329
function AudioDirector.prototype.setPaused(self, paused) -- 345
	if self.paused == paused then -- 345
		return -- 347
	end -- 347
	self.paused = paused -- 349
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 349
		do -- 349
			pcall(function() -- 349
				Audio:setPauseAllCurrent(paused) -- 352
			end) -- 352
		end -- 352
	end -- 352
end -- 345
function AudioDirector.prototype.stopRoomTransient(self) -- 360
	local i = 0 -- 361
	do -- 361
		i = 0 -- 362
		while i < #self.activeSources do -- 362
			local src = self.activeSources[i + 1] -- 363
			if src.playing then -- 363
				src:stop(0) -- 365
			end -- 365
			src:removeFromParent(true) -- 367
			i = i + 1 -- 362
		end -- 362
	end -- 362
	self.activeSources = {} -- 369
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 369
		do -- 369
			i = 0 -- 372
			while i < #self.activeHandlers do -- 372
				Audio:stop(self.activeHandlers[i + 1]) -- 373
				i = i + 1 -- 372
			end -- 372
		end -- 372
	end -- 372
	self.activeHandlers = {} -- 376
	local loopIds = {} -- 378
	for id in pairs(self.activeLoops) do -- 379
		loopIds[#loopIds + 1] = id -- 380
	end -- 380
	do -- 380
		i = 0 -- 382
		while i < #loopIds do -- 382
			self:stopLoop(loopIds[i + 1], 0) -- 383
			i = i + 1 -- 382
		end -- 382
	end -- 382
	self.dedupeSet = {} -- 386
	if self.paused then -- 386
		self:setPaused(false) -- 388
	end -- 388
	self:setWorldPlaySpeed(1) -- 390
end -- 360
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 398
	if self.paused or #ev.rawEvents == 0 then -- 398
		return -- 400
	end -- 400
	local i = 0 -- 402
	do -- 402
		i = 0 -- 403
		while i < #ev.rawEvents do -- 403
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 404
			i = i + 1 -- 403
		end -- 403
	end -- 403
end -- 398
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 408
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 414
	if e.name == "knock" then -- 414
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 416
		local countTag = type(e.data.count) == "number" and "" .. tostring(e.data.count) or "1" -- 417
		self:playOnce( -- 418
			key, -- 418
			"sfx", -- 418
			"assets/audio/sfx/knock.wav", -- 418
			0.9, -- 418
			(("knock:" .. roomTag) .. ":") .. countTag, -- 418
			e.tick, -- 418
			e.seq -- 418
		) -- 418
		return -- 419
	end -- 419
	if e.name == "shotResolved" then -- 419
		local hit = e.data.hit == true -- 422
		self:playOnce( -- 423
			key, -- 423
			"sfx", -- 423
			"assets/audio/combat/shot.wav", -- 423
			0.85, -- 423
			hit and "shot:hit" or "shot:fire", -- 423
			e.tick, -- 423
			e.seq -- 423
		) -- 423
		return -- 424
	end -- 424
	if e.name == "coverBlocked" then -- 424
		self:playOnce( -- 427
			key, -- 427
			"sfx", -- 427
			"assets/audio/combat/cover_block.wav", -- 427
			0.85, -- 427
			"cover:blocked", -- 427
			e.tick, -- 427
			e.seq -- 427
		) -- 427
		return -- 428
	end -- 428
	if e.name == "actorHit" or e.name == "gateFailed" then -- 428
		self:playOnce( -- 431
			key, -- 431
			"sfx", -- 431
			"assets/audio/combat/actor_hit.wav", -- 431
			0.9, -- 431
			"actor:hit", -- 431
			e.tick, -- 431
			e.seq -- 431
		) -- 431
		return -- 432
	end -- 432
	if e.name == "bottleLanded" then -- 432
		local surface = "brick" -- 435
		if type(e.data.surface) == "string" then -- 435
			surface = e.data.surface -- 437
		elseif p.room.key == "village" then -- 437
			local landX = type(e.data.x) == "number" and e.data.x or p.bottleLandX -- 439
			if math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS then -- 439
				surface = "iron" -- 441
			elseif p.room.softX ~= nil and math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS then -- 441
				surface = "soft" -- 443
			end -- 443
		end -- 443
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 446
		self:playOnce( -- 449
			key, -- 449
			"sfx", -- 449
			path, -- 449
			0.9, -- 449
			"bottle:" .. surface, -- 449
			e.tick, -- 449
			e.seq -- 449
		) -- 449
		return -- 450
	end -- 450
	if e.name == "cartDocked" then -- 450
		self:playOnce( -- 453
			key, -- 453
			"sfx", -- 453
			"assets/audio/child/cart_dock.wav", -- 453
			0.88, -- 453
			"cart:docked", -- 453
			e.tick, -- 453
			e.seq -- 453
		) -- 453
		return -- 454
	end -- 454
	if e.name == "craftDone" or e.name == "benchCraft" then -- 454
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 457
		self:playOnce( -- 460
			key, -- 460
			"sfx", -- 460
			"assets/audio/combat/craft_done.wav", -- 460
			0.88, -- 460
			"craft:done" .. recipeTag, -- 460
			e.tick, -- 460
			e.seq -- 460
		) -- 460
		return -- 461
	end -- 461
	local name = e.name -- 464
	if name == "benchRejected" then -- 464
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 466
		self:playOnce( -- 467
			key, -- 467
			"sfx", -- 467
			"assets/audio/combat/craft_insufficient.wav", -- 467
			0.76, -- 467
			"craft:insufficient" .. recipeTag, -- 467
			e.tick, -- 467
			e.seq -- 467
		) -- 467
	elseif name == "handHeld" then -- 467
		self:playOnce( -- 469
			key, -- 469
			"sfx", -- 469
			"assets/audio/gate/reunion_hold.wav", -- 469
			0.9, -- 469
			"gate:hand_held", -- 469
			e.tick, -- 469
			e.seq -- 469
		) -- 469
	elseif name == "handRelease" then -- 469
		self:playOnce( -- 471
			key, -- 471
			"sfx", -- 471
			"assets/audio/gate/reunion_release.wav", -- 471
			0.7, -- 471
			"gate:hand_release", -- 471
			e.tick, -- 471
			e.seq -- 471
		) -- 471
	elseif name == "carryStart" then -- 471
		self:playOnce( -- 473
			key, -- 473
			"sfx", -- 473
			"assets/audio/combat/carry_start.wav", -- 473
			0.82, -- 473
			"combat:carry_start", -- 473
			e.tick, -- 473
			e.seq -- 473
		) -- 473
	elseif name == "reloadOpen" then -- 473
		self:playOnce( -- 475
			key, -- 475
			"sfx", -- 475
			"assets/audio/combat/reload_open.wav", -- 475
			0.8, -- 475
			"reload:open", -- 475
			e.tick, -- 475
			e.seq -- 475
		) -- 475
	elseif name == "reloadNode" then -- 475
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 477
		self:playOnce( -- 478
			key, -- 478
			"sfx", -- 478
			"assets/audio/combat/reload_node.wav", -- 478
			0.78, -- 478
			"reload:node:" .. nodeTag, -- 478
			e.tick, -- 478
			e.seq -- 478
		) -- 478
	elseif name == "reloadInvalid" then -- 478
		self:playOnce( -- 480
			key, -- 480
			"sfx", -- 480
			"assets/audio/combat/reload_invalid.wav", -- 480
			0.72, -- 480
			"reload:invalid", -- 480
			e.tick, -- 480
			e.seq -- 480
		) -- 480
	elseif name == "reloadSolved" then -- 480
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 482
		self:playOnce( -- 483
			key, -- 483
			"sfx", -- 483
			"assets/audio/combat/reload_solved.wav", -- 483
			0.9, -- 483
			"reload:solved:" .. eff, -- 483
			e.tick, -- 483
			e.seq -- 483
		) -- 483
	elseif name == "reloadTimeout" then -- 483
		self:playOnce( -- 485
			key, -- 485
			"sfx", -- 485
			"assets/audio/combat/reload_timeout.wav", -- 485
			0.78, -- 485
			"reload:timeout", -- 485
			e.tick, -- 485
			e.seq -- 485
		) -- 485
	elseif name == "artifactFound" then -- 485
		self:playOnce( -- 487
			key, -- 487
			"sfx", -- 487
			"assets/audio/museum/artifact_pickup.wav", -- 487
			0.88, -- 487
			"museum:artifact_found", -- 487
			e.tick, -- 487
			e.seq -- 487
		) -- 487
	elseif name == "museumStep" then -- 487
		local step = type(e.data.step) == "string" and e.data.step or "" -- 489
		local cnt = type(e.data.count) == "number" and e.data.count or 1 -- 490
		if step == "cabinet" then -- 490
			self:playOnce( -- 492
				key, -- 492
				"sfx", -- 492
				"assets/audio/museum/weapon_holster.wav", -- 492
				0.78, -- 492
				"museum:step:cabinet", -- 492
				e.tick, -- 492
				e.seq -- 492
			) -- 492
		elseif step == "hall" then -- 492
			self:playOnce( -- 494
				key, -- 494
				"sfx", -- 494
				"assets/audio/museum/child_steps_echo.wav", -- 494
				0.76, -- 494
				"museum:step:hall", -- 494
				e.tick, -- 494
				e.seq -- 494
			) -- 494
		elseif step == "lamp" then -- 494
			self:playOnce( -- 496
				key, -- 496
				"sfx", -- 496
				"assets/audio/museum/lamp_turn.wav", -- 496
				0.82, -- 496
				"museum:step:lamp", -- 496
				e.tick, -- 496
				e.seq -- 496
			) -- 496
		elseif step == "knock" then -- 496
			local knockPath = cnt >= 2 and "assets/audio/museum/knock_cabinet_second.wav" or "assets/audio/museum/knock_hall_first.wav" -- 498
			self:playOnce( -- 501
				key, -- 501
				"sfx", -- 501
				knockPath, -- 501
				0.9, -- 501
				"museum:step:knock:" .. tostring(cnt), -- 501
				e.tick, -- 501
				e.seq -- 501
			) -- 501
		end -- 501
	elseif name == "museumDone" then -- 501
		self:playOnce( -- 504
			key, -- 504
			"voice", -- 504
			"assets/audio/museum/line_dawn.wav", -- 504
			0.88, -- 504
			"museum:done", -- 504
			e.tick, -- 504
			e.seq -- 504
		) -- 504
	end -- 504
end -- 408
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 508
	return self.dedupeSet[dedupeKey] == true -- 509
end -- 508
function AudioDirector.prototype.getPlayLog(self) -- 512
	return self.playLog -- 513
end -- 512
function AudioDirector.prototype.getLastEntry(self) -- 516
	if #self.playLog == 0 then -- 516
		return nil -- 518
	end -- 518
	return self.playLog[#self.playLog] -- 520
end -- 516
function AudioDirector.prototype.clearPlayLog(self) -- 523
	self.playLog = {} -- 524
end -- 523
function AudioDirector.prototype.getTrackList(self) -- 527
	return ALL_TRACKS -- 528
end -- 527
function AudioDirector.prototype.pruneStoppedSources(self) -- 531
	local w = 0 -- 532
	local i = 0 -- 533
	do -- 533
		i = 0 -- 534
		while i < #self.activeSources do -- 534
			local src = self.activeSources[i + 1] -- 535
			if src.playing then -- 535
				self.activeSources[w + 1] = src -- 537
				w = w + 1 -- 538
			else -- 538
				src:removeFromParent(true) -- 540
			end -- 540
			i = i + 1 -- 534
		end -- 534
	end -- 534
	__TS__ArraySetLength(self.activeSources, w) -- 534
end -- 531
function AudioDirector.prototype.recordLog(self, entry) -- 546
	local ____self_playLog_2 = self.playLog -- 546
	____self_playLog_2[#____self_playLog_2 + 1] = entry -- 547
	if #self.playLog > MAX_PLAY_LOG then -- 547
		table.remove(self.playLog, 1) -- 549
	end -- 549
end -- 546
return ____exports -- 546