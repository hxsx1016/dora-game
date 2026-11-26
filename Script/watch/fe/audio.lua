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
	if isCallableCtor(AudioBus) then -- 59
		return AudioBus() -- 61
	end -- 61
	return nil -- 63
end -- 59
____exports.AudioDirector = __TS__Class() -- 66
local AudioDirector = ____exports.AudioDirector -- 66
AudioDirector.name = "AudioDirector" -- 66
function AudioDirector.prototype.____constructor(self) -- 79
	self.activeSources = {} -- 71
	self.activeHandlers = {} -- 72
	self.activeLoops = {} -- 73
	self.dedupeSet = {} -- 74
	self.playLog = {} -- 75
	self.paused = false -- 76
	self.worldPlaySpeed = 1 -- 77
	self.buses = { -- 80
		voice = safeCreateBus(), -- 81
		wind = safeCreateBus(), -- 82
		water = safeCreateBus(), -- 83
		ambience = safeCreateBus(), -- 84
		sfx = safeCreateBus() -- 85
	} -- 85
	self.trackVolumes = { -- 87
		voice = 1, -- 88
		wind = 1, -- 89
		water = 1, -- 90
		ambience = 1, -- 91
		sfx = 1 -- 92
	} -- 92
	self.trackMuted = { -- 94
		voice = false, -- 95
		wind = false, -- 96
		water = false, -- 97
		ambience = false, -- 98
		sfx = false -- 99
	} -- 99
end -- 79
function AudioDirector.prototype.attachHost(self, parent) -- 104
	if self.hostNode ~= nil then -- 104
		return -- 106
	end -- 106
	local n = Node() -- 108
	n.order = -1 -- 109
	n:addTo(parent) -- 110
	self.hostNode = n -- 111
end -- 104
function AudioDirector.prototype.isPaused(self) -- 114
	return self.paused -- 115
end -- 114
function AudioDirector.prototype.getTrackVolume(self, track) -- 118
	return self.trackVolumes[track] -- 119
end -- 118
function AudioDirector.prototype.setTrackVolume(self, track, volume) -- 122
	local clamped = clamp01(volume) -- 123
	self.trackVolumes[track] = clamped -- 124
	self:syncBusGain(track) -- 125
end -- 122
function AudioDirector.prototype.isTrackMuted(self, track) -- 128
	return self.trackMuted[track] -- 129
end -- 128
function AudioDirector.prototype.setTrackMuted(self, track, muted) -- 132
	self.trackMuted[track] = muted -- 133
	self:syncBusGain(track) -- 134
end -- 132
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 138
	local next = math.max( -- 139
		0.25, -- 139
		math.min(2, speed) -- 139
	) -- 139
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 139
		return -- 141
	end -- 141
	self.worldPlaySpeed = next -- 143
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 144
	local i = 0 -- 145
	do -- 145
		i = 0 -- 146
		while i < #worldTracks do -- 146
			local bus = self.buses[worldTracks[i + 1]] -- 147
			if bus ~= nil then -- 147
				bus.playSpeed = next -- 149
			end -- 149
			i = i + 1 -- 146
		end -- 146
	end -- 146
end -- 138
function AudioDirector.prototype.syncBusGain(self, track) -- 154
	local bus = self.buses[track] -- 155
	if bus ~= nil then -- 155
		bus.volume = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 157
	end -- 157
end -- 154
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq) -- 166
	if volume == nil then -- 166
		volume = 1 -- 170
	end -- 170
	if cueId == nil then -- 170
		cueId = "" -- 171
	end -- 171
	if tick == nil then -- 171
		tick = 0 -- 172
	end -- 172
	if seq == nil then -- 172
		seq = -1 -- 173
	end -- 173
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 173
		return false -- 176
	end -- 176
	if dedupeKey ~= "" then -- 176
		self.dedupeSet[dedupeKey] = true -- 179
	end -- 179
	local cueVol = clamp01(volume) -- 182
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 183
	local effectiveVol = cueVol * trackGain -- 184
	local playedBackend = false -- 185
	if path ~= "" and Content:exist(path) then -- 185
		self:pruneStoppedSources() -- 188
		local bus = self.buses[track] -- 189
		local ____isCallableCtor_result_0 -- 190
		if isCallableCtor(AudioSource) then -- 190
			____isCallableCtor_result_0 = AudioSource(path, false, bus) -- 190
		else -- 190
			____isCallableCtor_result_0 = nil -- 190
		end -- 190
		local src = ____isCallableCtor_result_0 -- 190
		if src ~= nil then -- 190
			src.volume = bus ~= nil and cueVol or effectiveVol -- 193
			src.looping = false -- 194
			if self.hostNode ~= nil then -- 194
				src:addTo(self.hostNode) -- 196
			end -- 196
			playedBackend = src:play() -- 198
			if playedBackend then -- 198
				local ____self_activeSources_1 = self.activeSources -- 198
				____self_activeSources_1[#____self_activeSources_1 + 1] = src -- 200
			else -- 200
				src:removeFromParent(true) -- 202
			end -- 202
		elseif type(Audio) ~= "nil" and type(Audio.play) == "function" then -- 202
			local handler = Audio:play(path, false) -- 205
			if handler > 0 then -- 205
				local ____self_activeHandlers_2 = self.activeHandlers -- 205
				____self_activeHandlers_2[#____self_activeHandlers_2 + 1] = handler -- 207
				playedBackend = true -- 208
			end -- 208
		end -- 208
	end -- 208
	self:recordLog({ -- 213
		tick = tick, -- 214
		seq = seq, -- 215
		track = track, -- 216
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 217
		dedupeKey = dedupeKey, -- 218
		path = path, -- 219
		volume = clamp01(volume), -- 220
		looped = false, -- 221
		playedBackend = playedBackend -- 222
	}) -- 222
	return true -- 224
end -- 166
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 228
	if volume == nil then -- 228
		volume = 1 -- 232
	end -- 232
	if tick == nil then -- 232
		tick = 0 -- 233
	end -- 233
	local prev = self.activeLoops[loopId] -- 235
	local clampedVol = clamp01(volume) -- 236
	local bus = self.buses[track] -- 237
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 238
	if prev ~= nil and prev.path == path and prev.track == track then -- 238
		prev.volume = clampedVol -- 240
		if prev.source ~= nil then -- 240
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 242
		end -- 242
		return false -- 244
	end -- 244
	if prev ~= nil then -- 244
		self:stopLoop(loopId, 0) -- 247
	end -- 247
	local source -- 250
	local handler -- 251
	local playedBackend = false -- 252
	if path ~= "" and Content:exist(path) then -- 252
		local ____isCallableCtor_result_3 -- 254
		if isCallableCtor(AudioSource) then -- 254
			____isCallableCtor_result_3 = AudioSource(path, false, bus) -- 254
		else -- 254
			____isCallableCtor_result_3 = nil -- 254
		end -- 254
		local created = ____isCallableCtor_result_3 -- 254
		if created ~= nil then -- 254
			created.looping = true -- 256
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 257
			if self.hostNode ~= nil then -- 257
				created:addTo(self.hostNode) -- 259
			end -- 259
			playedBackend = created:play() -- 261
			if playedBackend then -- 261
				source = created -- 263
			else -- 263
				created:removeFromParent(true) -- 265
			end -- 265
		end -- 265
		if not playedBackend and type(Audio) ~= "nil" and type(Audio.play) == "function" then -- 265
			local h = Audio:play(path, true) -- 269
			if h > 0 then -- 269
				handler = h -- 271
				playedBackend = true -- 272
			end -- 272
		end -- 272
	end -- 272
	self.activeLoops[loopId] = { -- 277
		track = track, -- 278
		path = path, -- 279
		volume = clampedVol, -- 280
		source = source, -- 281
		handler = handler -- 282
	} -- 282
	self:recordLog({ -- 284
		tick = tick, -- 285
		seq = -1, -- 286
		track = track, -- 287
		cueId = "loop:" .. loopId, -- 288
		dedupeKey = "loop:" .. loopId, -- 289
		path = path, -- 290
		volume = clampedVol, -- 291
		looped = true, -- 292
		playedBackend = playedBackend -- 293
	}) -- 293
	return true -- 295
end -- 228
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 298
	if fadeTime == nil then -- 298
		fadeTime = 0 -- 298
	end -- 298
	local entry = self.activeLoops[loopId] -- 299
	if entry == nil then -- 299
		return -- 301
	end -- 301
	if entry.source ~= nil then -- 301
		entry.source:stop(fadeTime) -- 304
		entry.source:removeFromParent(true) -- 305
	end -- 305
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 305
		Audio:stop(entry.handler) -- 308
	end -- 308
	__TS__Delete(self.activeLoops, loopId) -- 310
end -- 298
function AudioDirector.prototype.setPaused(self, paused) -- 314
	if self.paused == paused then -- 314
		return -- 316
	end -- 316
	self.paused = paused -- 318
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 318
		Audio:setPauseAllCurrent(paused) -- 320
	end -- 320
end -- 314
function AudioDirector.prototype.stopRoomTransient(self) -- 325
	local i = 0 -- 326
	do -- 326
		i = 0 -- 327
		while i < #self.activeSources do -- 327
			local src = self.activeSources[i + 1] -- 328
			if src.playing then -- 328
				src:stop(0) -- 330
			end -- 330
			src:removeFromParent(true) -- 332
			i = i + 1 -- 327
		end -- 327
	end -- 327
	self.activeSources = {} -- 334
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 334
		do -- 334
			i = 0 -- 337
			while i < #self.activeHandlers do -- 337
				Audio:stop(self.activeHandlers[i + 1]) -- 338
				i = i + 1 -- 337
			end -- 337
		end -- 337
	end -- 337
	self.activeHandlers = {} -- 341
	local loopIds = {} -- 343
	for id in pairs(self.activeLoops) do -- 344
		loopIds[#loopIds + 1] = id -- 345
	end -- 345
	do -- 345
		i = 0 -- 347
		while i < #loopIds do -- 347
			self:stopLoop(loopIds[i + 1], 0) -- 348
			i = i + 1 -- 347
		end -- 347
	end -- 347
	self.dedupeSet = {} -- 351
	if self.paused then -- 351
		self:setPaused(false) -- 353
	end -- 353
	self:setWorldPlaySpeed(1) -- 355
end -- 325
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 363
	if self.paused or #ev.rawEvents == 0 then -- 363
		return -- 365
	end -- 365
	local i = 0 -- 367
	do -- 367
		i = 0 -- 368
		while i < #ev.rawEvents do -- 368
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 369
			i = i + 1 -- 368
		end -- 368
	end -- 368
end -- 363
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 373
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 379
	if e.name == "knock" then -- 379
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 381
		local countTag = type(e.data.count) == "number" and "" .. tostring(e.data.count) or "1" -- 382
		self:playOnce( -- 383
			key, -- 383
			"sfx", -- 383
			"assets/audio/sfx/knock.wav", -- 383
			0.9, -- 383
			(("knock:" .. roomTag) .. ":") .. countTag, -- 383
			e.tick, -- 383
			e.seq -- 383
		) -- 383
		return -- 384
	end -- 384
	if e.name == "shotResolved" then -- 384
		local hit = e.data.hit == true -- 387
		self:playOnce( -- 388
			key, -- 388
			"sfx", -- 388
			"assets/audio/combat/shot.wav", -- 388
			0.85, -- 388
			hit and "shot:hit" or "shot:fire", -- 388
			e.tick, -- 388
			e.seq -- 388
		) -- 388
		return -- 389
	end -- 389
	if e.name == "coverBlocked" then -- 389
		self:playOnce( -- 392
			key, -- 392
			"sfx", -- 392
			"assets/audio/combat/cover_block.wav", -- 392
			0.85, -- 392
			"cover:blocked", -- 392
			e.tick, -- 392
			e.seq -- 392
		) -- 392
		return -- 393
	end -- 393
	if e.name == "actorHit" or e.name == "gateFailed" then -- 393
		self:playOnce( -- 396
			key, -- 396
			"sfx", -- 396
			"assets/audio/combat/actor_hit.wav", -- 396
			0.9, -- 396
			"actor:hit", -- 396
			e.tick, -- 396
			e.seq -- 396
		) -- 396
		return -- 397
	end -- 397
	if e.name == "bottleLanded" then -- 397
		local surface = "brick" -- 400
		if type(e.data.surface) == "string" then -- 400
			surface = e.data.surface -- 402
		elseif p.room.key == "village" then -- 402
			local landX = type(e.data.x) == "number" and e.data.x or p.bottleLandX -- 404
			if math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS then -- 404
				surface = "iron" -- 406
			elseif p.room.softX ~= nil and math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS then -- 406
				surface = "soft" -- 408
			end -- 408
		end -- 408
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 411
		self:playOnce( -- 414
			key, -- 414
			"sfx", -- 414
			path, -- 414
			0.9, -- 414
			"bottle:" .. surface, -- 414
			e.tick, -- 414
			e.seq -- 414
		) -- 414
		return -- 415
	end -- 415
	if e.name == "cartDocked" then -- 415
		self:playOnce( -- 418
			key, -- 418
			"sfx", -- 418
			"assets/audio/child/cart_dock.wav", -- 418
			0.88, -- 418
			"cart:docked", -- 418
			e.tick, -- 418
			e.seq -- 418
		) -- 418
		return -- 419
	end -- 419
	if e.name == "craftDone" or e.name == "benchCraft" then -- 419
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 422
		self:playOnce( -- 425
			key, -- 425
			"sfx", -- 425
			"assets/audio/combat/craft_done.wav", -- 425
			0.88, -- 425
			"craft:done" .. recipeTag, -- 425
			e.tick, -- 425
			e.seq -- 425
		) -- 425
		return -- 426
	end -- 426
	local name = e.name -- 429
	if name == "benchRejected" then -- 429
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 431
		self:playOnce( -- 432
			key, -- 432
			"sfx", -- 432
			"assets/audio/combat/craft_insufficient.wav", -- 432
			0.76, -- 432
			"craft:insufficient" .. recipeTag, -- 432
			e.tick, -- 432
			e.seq -- 432
		) -- 432
	elseif name == "handHeld" then -- 432
		self:playOnce( -- 434
			key, -- 434
			"sfx", -- 434
			"assets/audio/gate/reunion_hold.wav", -- 434
			0.9, -- 434
			"gate:hand_held", -- 434
			e.tick, -- 434
			e.seq -- 434
		) -- 434
	elseif name == "handRelease" then -- 434
		self:playOnce( -- 436
			key, -- 436
			"sfx", -- 436
			"assets/audio/gate/reunion_release.wav", -- 436
			0.7, -- 436
			"gate:hand_release", -- 436
			e.tick, -- 436
			e.seq -- 436
		) -- 436
	elseif name == "carryStart" then -- 436
		self:playOnce( -- 438
			key, -- 438
			"sfx", -- 438
			"assets/audio/combat/carry_start.wav", -- 438
			0.82, -- 438
			"combat:carry_start", -- 438
			e.tick, -- 438
			e.seq -- 438
		) -- 438
	elseif name == "reloadOpen" then -- 438
		self:playOnce( -- 440
			key, -- 440
			"sfx", -- 440
			"assets/audio/combat/reload_open.wav", -- 440
			0.8, -- 440
			"reload:open", -- 440
			e.tick, -- 440
			e.seq -- 440
		) -- 440
	elseif name == "reloadNode" then -- 440
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 442
		self:playOnce( -- 443
			key, -- 443
			"sfx", -- 443
			"assets/audio/combat/reload_node.wav", -- 443
			0.78, -- 443
			"reload:node:" .. nodeTag, -- 443
			e.tick, -- 443
			e.seq -- 443
		) -- 443
	elseif name == "reloadInvalid" then -- 443
		self:playOnce( -- 445
			key, -- 445
			"sfx", -- 445
			"assets/audio/combat/reload_invalid.wav", -- 445
			0.72, -- 445
			"reload:invalid", -- 445
			e.tick, -- 445
			e.seq -- 445
		) -- 445
	elseif name == "reloadSolved" then -- 445
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 447
		self:playOnce( -- 448
			key, -- 448
			"sfx", -- 448
			"assets/audio/combat/reload_solved.wav", -- 448
			0.9, -- 448
			"reload:solved:" .. eff, -- 448
			e.tick, -- 448
			e.seq -- 448
		) -- 448
	elseif name == "reloadTimeout" then -- 448
		self:playOnce( -- 450
			key, -- 450
			"sfx", -- 450
			"assets/audio/combat/reload_timeout.wav", -- 450
			0.78, -- 450
			"reload:timeout", -- 450
			e.tick, -- 450
			e.seq -- 450
		) -- 450
	elseif name == "artifactFound" then -- 450
		self:playOnce( -- 452
			key, -- 452
			"sfx", -- 452
			"assets/audio/museum/artifact_pickup.wav", -- 452
			0.88, -- 452
			"museum:artifact_found", -- 452
			e.tick, -- 452
			e.seq -- 452
		) -- 452
	elseif name == "museumStep" then -- 452
		local step = type(e.data.step) == "string" and e.data.step or "" -- 454
		local cnt = type(e.data.count) == "number" and e.data.count or 1 -- 455
		if step == "cabinet" then -- 455
			self:playOnce( -- 457
				key, -- 457
				"sfx", -- 457
				"assets/audio/museum/weapon_holster.wav", -- 457
				0.78, -- 457
				"museum:step:cabinet", -- 457
				e.tick, -- 457
				e.seq -- 457
			) -- 457
		elseif step == "hall" then -- 457
			self:playOnce( -- 459
				key, -- 459
				"sfx", -- 459
				"assets/audio/museum/child_steps_echo.wav", -- 459
				0.76, -- 459
				"museum:step:hall", -- 459
				e.tick, -- 459
				e.seq -- 459
			) -- 459
		elseif step == "lamp" then -- 459
			self:playOnce( -- 461
				key, -- 461
				"sfx", -- 461
				"assets/audio/museum/lamp_turn.wav", -- 461
				0.82, -- 461
				"museum:step:lamp", -- 461
				e.tick, -- 461
				e.seq -- 461
			) -- 461
		elseif step == "knock" then -- 461
			local knockPath = cnt >= 2 and "assets/audio/museum/knock_cabinet_second.wav" or "assets/audio/museum/knock_hall_first.wav" -- 463
			self:playOnce( -- 466
				key, -- 466
				"sfx", -- 466
				knockPath, -- 466
				0.9, -- 466
				"museum:step:knock:" .. tostring(cnt), -- 466
				e.tick, -- 466
				e.seq -- 466
			) -- 466
		end -- 466
	elseif name == "museumDone" then -- 466
		self:playOnce( -- 469
			key, -- 469
			"voice", -- 469
			"assets/audio/museum/line_dawn.wav", -- 469
			0.88, -- 469
			"museum:done", -- 469
			e.tick, -- 469
			e.seq -- 469
		) -- 469
	end -- 469
end -- 373
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 473
	return self.dedupeSet[dedupeKey] == true -- 474
end -- 473
function AudioDirector.prototype.getPlayLog(self) -- 477
	return self.playLog -- 478
end -- 477
function AudioDirector.prototype.getLastEntry(self) -- 481
	if #self.playLog == 0 then -- 481
		return nil -- 483
	end -- 483
	return self.playLog[#self.playLog] -- 485
end -- 481
function AudioDirector.prototype.clearPlayLog(self) -- 488
	self.playLog = {} -- 489
end -- 488
function AudioDirector.prototype.getTrackList(self) -- 492
	return ALL_TRACKS -- 493
end -- 492
function AudioDirector.prototype.pruneStoppedSources(self) -- 496
	local w = 0 -- 497
	local i = 0 -- 498
	do -- 498
		i = 0 -- 499
		while i < #self.activeSources do -- 499
			local src = self.activeSources[i + 1] -- 500
			if src.playing then -- 500
				self.activeSources[w + 1] = src -- 502
				w = w + 1 -- 503
			else -- 503
				src:removeFromParent(true) -- 505
			end -- 505
			i = i + 1 -- 499
		end -- 499
	end -- 499
	__TS__ArraySetLength(self.activeSources, w) -- 499
end -- 496
function AudioDirector.prototype.recordLog(self, entry) -- 511
	local ____self_playLog_4 = self.playLog -- 511
	____self_playLog_4[#____self_playLog_4 + 1] = entry -- 512
	if #self.playLog > MAX_PLAY_LOG then -- 512
		table.remove(self.playLog, 1) -- 514
	end -- 514
end -- 511
return ____exports -- 511