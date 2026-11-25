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
local ALL_TRACKS = { -- 39
	"voice", -- 39
	"wind", -- 39
	"water", -- 39
	"ambience", -- 39
	"sfx" -- 39
} -- 39
local MAX_PLAY_LOG = 256 -- 40
local function clamp01(v) -- 42
	return math.max( -- 43
		0, -- 43
		math.min(1, v) -- 43
	) -- 43
end -- 42
local function safeCreateBus() -- 46
	if type(AudioBus) == "function" then -- 46
		return AudioBus() -- 48
	end -- 48
	return nil -- 50
end -- 46
____exports.AudioDirector = __TS__Class() -- 53
local AudioDirector = ____exports.AudioDirector -- 53
AudioDirector.name = "AudioDirector" -- 53
function AudioDirector.prototype.____constructor(self) -- 66
	self.activeSources = {} -- 58
	self.activeHandlers = {} -- 59
	self.activeLoops = {} -- 60
	self.dedupeSet = {} -- 61
	self.playLog = {} -- 62
	self.paused = false -- 63
	self.worldPlaySpeed = 1 -- 64
	self.buses = { -- 67
		voice = safeCreateBus(), -- 68
		wind = safeCreateBus(), -- 69
		water = safeCreateBus(), -- 70
		ambience = safeCreateBus(), -- 71
		sfx = safeCreateBus() -- 72
	} -- 72
	self.trackVolumes = { -- 74
		voice = 1, -- 75
		wind = 1, -- 76
		water = 1, -- 77
		ambience = 1, -- 78
		sfx = 1 -- 79
	} -- 79
	self.trackMuted = { -- 81
		voice = false, -- 82
		wind = false, -- 83
		water = false, -- 84
		ambience = false, -- 85
		sfx = false -- 86
	} -- 86
end -- 66
function AudioDirector.prototype.attachHost(self, parent) -- 91
	if self.hostNode ~= nil then -- 91
		return -- 93
	end -- 93
	local n = Node() -- 95
	n.order = -1 -- 96
	n:addTo(parent) -- 97
	self.hostNode = n -- 98
end -- 91
function AudioDirector.prototype.isPaused(self) -- 101
	return self.paused -- 102
end -- 101
function AudioDirector.prototype.getTrackVolume(self, track) -- 105
	return self.trackVolumes[track] -- 106
end -- 105
function AudioDirector.prototype.setTrackVolume(self, track, volume) -- 109
	local clamped = clamp01(volume) -- 110
	self.trackVolumes[track] = clamped -- 111
	self:syncBusGain(track) -- 112
end -- 109
function AudioDirector.prototype.isTrackMuted(self, track) -- 115
	return self.trackMuted[track] -- 116
end -- 115
function AudioDirector.prototype.setTrackMuted(self, track, muted) -- 119
	self.trackMuted[track] = muted -- 120
	self:syncBusGain(track) -- 121
end -- 119
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 125
	local next = math.max( -- 126
		0.25, -- 126
		math.min(2, speed) -- 126
	) -- 126
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 126
		return -- 128
	end -- 128
	self.worldPlaySpeed = next -- 130
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 131
	local i = 0 -- 132
	do -- 132
		i = 0 -- 133
		while i < #worldTracks do -- 133
			local bus = self.buses[worldTracks[i + 1]] -- 134
			if bus ~= nil then -- 134
				bus.playSpeed = next -- 136
			end -- 136
			i = i + 1 -- 133
		end -- 133
	end -- 133
end -- 125
function AudioDirector.prototype.syncBusGain(self, track) -- 141
	local bus = self.buses[track] -- 142
	if bus ~= nil then -- 142
		bus.volume = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 144
	end -- 144
end -- 141
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq) -- 153
	if volume == nil then -- 153
		volume = 1 -- 157
	end -- 157
	if cueId == nil then -- 157
		cueId = "" -- 158
	end -- 158
	if tick == nil then -- 158
		tick = 0 -- 159
	end -- 159
	if seq == nil then -- 159
		seq = -1 -- 160
	end -- 160
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 160
		return false -- 163
	end -- 163
	if dedupeKey ~= "" then -- 163
		self.dedupeSet[dedupeKey] = true -- 166
	end -- 166
	local effectiveVol = clamp01(volume) * (self.trackMuted[track] and 0 or self.trackVolumes[track]) -- 169
	local playedBackend = false -- 170
	if path ~= "" and Content:exist(path) then -- 170
		self:pruneStoppedSources() -- 173
		local bus = self.buses[track] -- 174
		local ____temp_0 -- 175
		if type(AudioSource) == "function" then -- 175
			____temp_0 = AudioSource(path, false, bus) -- 175
		else -- 175
			____temp_0 = nil -- 175
		end -- 175
		local src = ____temp_0 -- 175
		if src ~= nil then -- 175
			src.volume = effectiveVol -- 177
			src.looping = false -- 178
			if self.hostNode ~= nil then -- 178
				src:addTo(self.hostNode) -- 180
			end -- 180
			playedBackend = src:play() -- 182
			if playedBackend then -- 182
				local ____self_activeSources_1 = self.activeSources -- 182
				____self_activeSources_1[#____self_activeSources_1 + 1] = src -- 184
			else -- 184
				src:removeFromParent(true) -- 186
			end -- 186
		elseif type(Audio) ~= "nil" and type(Audio.play) == "function" then -- 186
			local handler = Audio:play(path, false) -- 189
			if handler > 0 then -- 189
				local ____self_activeHandlers_2 = self.activeHandlers -- 189
				____self_activeHandlers_2[#____self_activeHandlers_2 + 1] = handler -- 191
				playedBackend = true -- 192
			end -- 192
		end -- 192
	end -- 192
	self:recordLog({ -- 197
		tick = tick, -- 198
		seq = seq, -- 199
		track = track, -- 200
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 201
		dedupeKey = dedupeKey, -- 202
		path = path, -- 203
		volume = clamp01(volume), -- 204
		looped = false, -- 205
		playedBackend = playedBackend -- 206
	}) -- 206
	return true -- 208
end -- 153
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 212
	if volume == nil then -- 212
		volume = 1 -- 216
	end -- 216
	if tick == nil then -- 216
		tick = 0 -- 217
	end -- 217
	local prev = self.activeLoops[loopId] -- 219
	local clampedVol = clamp01(volume) -- 220
	if prev ~= nil and prev.path == path and prev.track == track then -- 220
		prev.volume = clampedVol -- 222
		if prev.source ~= nil then -- 222
			prev.source.volume = clampedVol * (self.trackMuted[track] and 0 or self.trackVolumes[track]) -- 224
		end -- 224
		return false -- 226
	end -- 226
	if prev ~= nil then -- 226
		self:stopLoop(loopId, 0) -- 229
	end -- 229
	local source -- 232
	local playedBackend = false -- 233
	if path ~= "" and Content:exist(path) then -- 233
		local bus = self.buses[track] -- 235
		local ____temp_3 -- 236
		if type(AudioSource) == "function" then -- 236
			____temp_3 = AudioSource(path, false, bus) -- 236
		else -- 236
			____temp_3 = nil -- 236
		end -- 236
		local created = ____temp_3 -- 236
		if created ~= nil then -- 236
			created.looping = true -- 238
			created.volume = clampedVol * (self.trackMuted[track] and 0 or self.trackVolumes[track]) -- 239
			if self.hostNode ~= nil then -- 239
				created:addTo(self.hostNode) -- 241
			end -- 241
			playedBackend = created:play() -- 243
			source = created -- 244
		end -- 244
	end -- 244
	self.activeLoops[loopId] = {track = track, path = path, volume = clampedVol, source = source} -- 248
	self:recordLog({ -- 254
		tick = tick, -- 255
		seq = -1, -- 256
		track = track, -- 257
		cueId = "loop:" .. loopId, -- 258
		dedupeKey = "loop:" .. loopId, -- 259
		path = path, -- 260
		volume = clampedVol, -- 261
		looped = true, -- 262
		playedBackend = playedBackend -- 263
	}) -- 263
	return true -- 265
end -- 212
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 268
	if fadeTime == nil then -- 268
		fadeTime = 0 -- 268
	end -- 268
	local entry = self.activeLoops[loopId] -- 269
	if entry == nil then -- 269
		return -- 271
	end -- 271
	if entry.source ~= nil then -- 271
		entry.source:stop(fadeTime) -- 274
		entry.source:removeFromParent(true) -- 275
	end -- 275
	__TS__Delete(self.activeLoops, loopId) -- 277
end -- 268
function AudioDirector.prototype.setPaused(self, paused) -- 281
	if self.paused == paused then -- 281
		return -- 283
	end -- 283
	self.paused = paused -- 285
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 285
		Audio:setPauseAllCurrent(paused) -- 287
	end -- 287
end -- 281
function AudioDirector.prototype.stopRoomTransient(self) -- 292
	local i = 0 -- 293
	do -- 293
		i = 0 -- 294
		while i < #self.activeSources do -- 294
			local src = self.activeSources[i + 1] -- 295
			if src.playing then -- 295
				src:stop(0) -- 297
			end -- 297
			src:removeFromParent(true) -- 299
			i = i + 1 -- 294
		end -- 294
	end -- 294
	self.activeSources = {} -- 301
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 301
		do -- 301
			i = 0 -- 304
			while i < #self.activeHandlers do -- 304
				Audio:stop(self.activeHandlers[i + 1]) -- 305
				i = i + 1 -- 304
			end -- 304
		end -- 304
	end -- 304
	self.activeHandlers = {} -- 308
	local loopIds = {} -- 310
	for id in pairs(self.activeLoops) do -- 311
		loopIds[#loopIds + 1] = id -- 312
	end -- 312
	do -- 312
		i = 0 -- 314
		while i < #loopIds do -- 314
			self:stopLoop(loopIds[i + 1], 0) -- 315
			i = i + 1 -- 314
		end -- 314
	end -- 314
	self.dedupeSet = {} -- 318
	if self.paused then -- 318
		self:setPaused(false) -- 320
	end -- 320
	self:setWorldPlaySpeed(1) -- 322
end -- 292
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 330
	if self.paused or #ev.rawEvents == 0 then -- 330
		return -- 332
	end -- 332
	local i = 0 -- 334
	do -- 334
		i = 0 -- 335
		while i < #ev.rawEvents do -- 335
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 336
			i = i + 1 -- 335
		end -- 335
	end -- 335
end -- 330
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 340
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 346
	if e.name == "knock" then -- 346
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 348
		local countTag = type(e.data.count) == "number" and "" .. tostring(e.data.count) or "1" -- 349
		self:playOnce( -- 350
			key, -- 350
			"sfx", -- 350
			"assets/audio/sfx/knock.wav", -- 350
			0.9, -- 350
			(("knock:" .. roomTag) .. ":") .. countTag, -- 350
			e.tick, -- 350
			e.seq -- 350
		) -- 350
		return -- 351
	end -- 351
	if e.name == "shotResolved" then -- 351
		local hit = e.data.hit == true -- 354
		self:playOnce( -- 355
			key, -- 355
			"sfx", -- 355
			"assets/audio/combat/shot.wav", -- 355
			0.85, -- 355
			hit and "shot:hit" or "shot:fire", -- 355
			e.tick, -- 355
			e.seq -- 355
		) -- 355
		return -- 356
	end -- 356
	if e.name == "coverBlocked" then -- 356
		self:playOnce( -- 359
			key, -- 359
			"sfx", -- 359
			"assets/audio/combat/cover_block.wav", -- 359
			0.85, -- 359
			"cover:blocked", -- 359
			e.tick, -- 359
			e.seq -- 359
		) -- 359
		return -- 360
	end -- 360
	if e.name == "actorHit" or e.name == "gateFailed" then -- 360
		self:playOnce( -- 363
			key, -- 363
			"sfx", -- 363
			"assets/audio/combat/actor_hit.wav", -- 363
			0.9, -- 363
			"actor:hit", -- 363
			e.tick, -- 363
			e.seq -- 363
		) -- 363
		return -- 364
	end -- 364
	if e.name == "bottleLanded" then -- 364
		local surface = type(e.data.surface) == "string" and e.data.surface or "brick" -- 367
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 368
		self:playOnce( -- 371
			key, -- 371
			"sfx", -- 371
			path, -- 371
			0.9, -- 371
			"bottle:" .. surface, -- 371
			e.tick, -- 371
			e.seq -- 371
		) -- 371
		return -- 372
	end -- 372
	if e.name == "cartDocked" then -- 372
		self:playOnce( -- 375
			key, -- 375
			"sfx", -- 375
			"assets/audio/child/cart_dock.wav", -- 375
			0.88, -- 375
			"cart:docked", -- 375
			e.tick, -- 375
			e.seq -- 375
		) -- 375
		return -- 376
	end -- 376
	if e.name == "craftDone" or e.name == "benchCraft" then -- 376
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 379
		self:playOnce( -- 382
			key, -- 382
			"sfx", -- 382
			"assets/audio/combat/craft_done.wav", -- 382
			0.88, -- 382
			"craft:done" .. recipeTag, -- 382
			e.tick, -- 382
			e.seq -- 382
		) -- 382
		return -- 383
	end -- 383
	local name = e.name -- 386
	if name == "benchRejected" then -- 386
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 388
		self:playOnce( -- 389
			key, -- 389
			"sfx", -- 389
			"assets/audio/combat/craft_insufficient.wav", -- 389
			0.76, -- 389
			"craft:insufficient" .. recipeTag, -- 389
			e.tick, -- 389
			e.seq -- 389
		) -- 389
	elseif name == "handHeld" then -- 389
		self:playOnce( -- 391
			key, -- 391
			"sfx", -- 391
			"assets/audio/gate/reunion_hold.wav", -- 391
			0.9, -- 391
			"gate:hand_held", -- 391
			e.tick, -- 391
			e.seq -- 391
		) -- 391
	elseif name == "handRelease" then -- 391
		self:playOnce( -- 393
			key, -- 393
			"sfx", -- 393
			"assets/audio/gate/reunion_release.wav", -- 393
			0.7, -- 393
			"gate:hand_release", -- 393
			e.tick, -- 393
			e.seq -- 393
		) -- 393
	elseif name == "carryStart" then -- 393
		self:playOnce( -- 395
			key, -- 395
			"sfx", -- 395
			"assets/audio/combat/carry_start.wav", -- 395
			0.82, -- 395
			"combat:carry_start", -- 395
			e.tick, -- 395
			e.seq -- 395
		) -- 395
	elseif name == "reloadOpen" then -- 395
		self:playOnce( -- 397
			key, -- 397
			"sfx", -- 397
			"assets/audio/combat/reload_open.wav", -- 397
			0.8, -- 397
			"reload:open", -- 397
			e.tick, -- 397
			e.seq -- 397
		) -- 397
	elseif name == "reloadNode" then -- 397
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 399
		self:playOnce( -- 400
			key, -- 400
			"sfx", -- 400
			"assets/audio/combat/reload_node.wav", -- 400
			0.78, -- 400
			"reload:node:" .. nodeTag, -- 400
			e.tick, -- 400
			e.seq -- 400
		) -- 400
	elseif name == "reloadInvalid" then -- 400
		self:playOnce( -- 402
			key, -- 402
			"sfx", -- 402
			"assets/audio/combat/reload_invalid.wav", -- 402
			0.72, -- 402
			"reload:invalid", -- 402
			e.tick, -- 402
			e.seq -- 402
		) -- 402
	elseif name == "reloadSolved" then -- 402
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 404
		self:playOnce( -- 405
			key, -- 405
			"sfx", -- 405
			"assets/audio/combat/reload_solved.wav", -- 405
			0.9, -- 405
			"reload:solved:" .. eff, -- 405
			e.tick, -- 405
			e.seq -- 405
		) -- 405
	elseif name == "reloadTimeout" then -- 405
		self:playOnce( -- 407
			key, -- 407
			"sfx", -- 407
			"assets/audio/combat/reload_timeout.wav", -- 407
			0.78, -- 407
			"reload:timeout", -- 407
			e.tick, -- 407
			e.seq -- 407
		) -- 407
	end -- 407
end -- 340
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 411
	return self.dedupeSet[dedupeKey] == true -- 412
end -- 411
function AudioDirector.prototype.getPlayLog(self) -- 415
	return self.playLog -- 416
end -- 415
function AudioDirector.prototype.getLastEntry(self) -- 419
	if #self.playLog == 0 then -- 419
		return nil -- 421
	end -- 421
	return self.playLog[#self.playLog] -- 423
end -- 419
function AudioDirector.prototype.clearPlayLog(self) -- 426
	self.playLog = {} -- 427
end -- 426
function AudioDirector.prototype.getTrackList(self) -- 430
	return ALL_TRACKS -- 431
end -- 430
function AudioDirector.prototype.pruneStoppedSources(self) -- 434
	local w = 0 -- 435
	local i = 0 -- 436
	do -- 436
		i = 0 -- 437
		while i < #self.activeSources do -- 437
			local src = self.activeSources[i + 1] -- 438
			if src.playing then -- 438
				self.activeSources[w + 1] = src -- 440
				w = w + 1 -- 441
			else -- 441
				src:removeFromParent(true) -- 443
			end -- 443
			i = i + 1 -- 437
		end -- 437
	end -- 437
	__TS__ArraySetLength(self.activeSources, w) -- 437
end -- 434
function AudioDirector.prototype.recordLog(self, entry) -- 449
	local ____self_playLog_4 = self.playLog -- 449
	____self_playLog_4[#____self_playLog_4 + 1] = entry -- 450
	if #self.playLog > MAX_PLAY_LOG then -- 450
		table.remove(self.playLog, 1) -- 452
	end -- 452
end -- 449
return ____exports -- 449