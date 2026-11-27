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
function AudioDirector.prototype.isAllMuted(self) -- 169
	local i = 0 -- 170
	do -- 170
		i = 0 -- 171
		while i < #ALL_TRACKS do -- 171
			if not self.trackMuted[ALL_TRACKS[i + 1]] then -- 171
				return false -- 173
			end -- 173
			i = i + 1 -- 171
		end -- 171
	end -- 171
	return true -- 176
end -- 169
function AudioDirector.prototype.toggleAllMuted(self) -- 180
	local next = not self:isAllMuted() -- 181
	local i = 0 -- 182
	do -- 182
		i = 0 -- 183
		while i < #ALL_TRACKS do -- 183
			self:setTrackMuted(ALL_TRACKS[i + 1], next) -- 184
			i = i + 1 -- 183
		end -- 183
	end -- 183
	return next -- 186
end -- 180
function AudioDirector.prototype.unlockAndResyncAfterGesture(self) -- 194
	local i = 0 -- 195
	do -- 195
		i = 0 -- 196
		while i < #ALL_TRACKS do -- 196
			self:syncBusGain(ALL_TRACKS[i + 1]) -- 197
			i = i + 1 -- 196
		end -- 196
	end -- 196
	if self.paused then -- 196
		return -- 200
	end -- 200
	for loopId in pairs(self.activeLoops) do -- 202
		do -- 202
			local entry = self.activeLoops[loopId] -- 203
			local bus = self.buses[entry.track] -- 204
			local trackGain = self.trackMuted[entry.track] and 0 or self.trackVolumes[entry.track] -- 205
			local stillPlaying = entry.source ~= nil and entry.source.playing -- 206
			if stillPlaying or entry.handler ~= nil then -- 206
				if entry.source ~= nil then -- 206
					entry.source.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 209
				end -- 209
				goto __continue35 -- 211
			end -- 211
			if entry.path ~= "" and Content:exist(entry.path) then -- 211
				local created = safeCreateSource(entry.path, false, bus) -- 214
				if created ~= nil then -- 214
					created.looping = true -- 216
					created.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 217
					if self.hostNode ~= nil then -- 217
						created:addTo(self.hostNode) -- 219
					end -- 219
					if created:play() then -- 219
						entry.source = created -- 222
					else -- 222
						created:removeFromParent(true) -- 224
					end -- 224
				else -- 224
					local h = safeAudioPlay(entry.path, true) -- 227
					if h > 0 then -- 227
						entry.handler = h -- 229
					end -- 229
				end -- 229
			end -- 229
		end -- 229
		::__continue35:: -- 229
	end -- 229
end -- 194
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 237
	local next = math.max( -- 238
		0.25, -- 238
		math.min(2, speed) -- 238
	) -- 238
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 238
		return -- 240
	end -- 240
	self.worldPlaySpeed = next -- 242
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 243
	local i = 0 -- 244
	do -- 244
		i = 0 -- 245
		while i < #worldTracks do -- 245
			local bus = self.buses[worldTracks[i + 1]] -- 246
			if bus ~= nil then -- 246
				bus.playSpeed = next -- 248
			end -- 248
			i = i + 1 -- 245
		end -- 245
	end -- 245
end -- 237
function AudioDirector.prototype.syncBusGain(self, track) -- 253
	local bus = self.buses[track] -- 254
	if bus ~= nil then -- 254
		bus.volume = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 256
	end -- 256
end -- 253
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq) -- 265
	if volume == nil then -- 265
		volume = 1 -- 269
	end -- 269
	if cueId == nil then -- 269
		cueId = "" -- 270
	end -- 270
	if tick == nil then -- 270
		tick = 0 -- 271
	end -- 271
	if seq == nil then -- 271
		seq = -1 -- 272
	end -- 272
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 272
		return false -- 275
	end -- 275
	if dedupeKey ~= "" then -- 275
		self.dedupeSet[dedupeKey] = true -- 278
	end -- 278
	local cueVol = clamp01(volume) -- 281
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 282
	local effectiveVol = cueVol * trackGain -- 283
	local playedBackend = false -- 284
	if path ~= "" and Content:exist(path) then -- 284
		self:pruneStoppedSources() -- 287
		local bus = self.buses[track] -- 288
		local src = safeCreateSource(path, false, bus) -- 289
		if src ~= nil then -- 289
			src.volume = bus ~= nil and cueVol or effectiveVol -- 292
			src.looping = false -- 293
			if self.hostNode ~= nil then -- 293
				src:addTo(self.hostNode) -- 295
			end -- 295
			playedBackend = src:play() -- 297
			if playedBackend then -- 297
				local ____self_activeSources_0 = self.activeSources -- 297
				____self_activeSources_0[#____self_activeSources_0 + 1] = src -- 299
			else -- 299
				src:removeFromParent(true) -- 301
			end -- 301
		else -- 301
			local handler = safeAudioPlay(path, false) -- 304
			if handler > 0 then -- 304
				local ____self_activeHandlers_1 = self.activeHandlers -- 304
				____self_activeHandlers_1[#____self_activeHandlers_1 + 1] = handler -- 306
				playedBackend = true -- 307
			end -- 307
		end -- 307
	end -- 307
	self:recordLog({ -- 312
		tick = tick, -- 313
		seq = seq, -- 314
		track = track, -- 315
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 316
		dedupeKey = dedupeKey, -- 317
		path = path, -- 318
		volume = clamp01(volume), -- 319
		looped = false, -- 320
		playedBackend = playedBackend -- 321
	}) -- 321
	return true -- 323
end -- 265
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 327
	if volume == nil then -- 327
		volume = 1 -- 331
	end -- 331
	if tick == nil then -- 331
		tick = 0 -- 332
	end -- 332
	local prev = self.activeLoops[loopId] -- 334
	local clampedVol = clamp01(volume) -- 335
	local bus = self.buses[track] -- 336
	local trackGain = self.trackMuted[track] and 0 or self.trackVolumes[track] -- 337
	if prev ~= nil and prev.path == path and prev.track == track then -- 337
		prev.volume = clampedVol -- 339
		if prev.source ~= nil then -- 339
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 341
		end -- 341
		return false -- 343
	end -- 343
	if prev ~= nil then -- 343
		self:stopLoop(loopId, 0) -- 346
	end -- 346
	local source -- 349
	local handler -- 350
	local playedBackend = false -- 351
	if path ~= "" and Content:exist(path) then -- 351
		local created = safeCreateSource(path, false, bus) -- 353
		if created ~= nil then -- 353
			created.looping = true -- 355
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 356
			if self.hostNode ~= nil then -- 356
				created:addTo(self.hostNode) -- 358
			end -- 358
			playedBackend = created:play() -- 360
			if playedBackend then -- 360
				source = created -- 362
			else -- 362
				created:removeFromParent(true) -- 364
			end -- 364
		end -- 364
		if not playedBackend then -- 364
			local h = safeAudioPlay(path, true) -- 368
			if h > 0 then -- 368
				handler = h -- 370
				playedBackend = true -- 371
			end -- 371
		end -- 371
	end -- 371
	self.activeLoops[loopId] = { -- 376
		track = track, -- 377
		path = path, -- 378
		volume = clampedVol, -- 379
		source = source, -- 380
		handler = handler -- 381
	} -- 381
	self:recordLog({ -- 383
		tick = tick, -- 384
		seq = -1, -- 385
		track = track, -- 386
		cueId = "loop:" .. loopId, -- 387
		dedupeKey = "loop:" .. loopId, -- 388
		path = path, -- 389
		volume = clampedVol, -- 390
		looped = true, -- 391
		playedBackend = playedBackend -- 392
	}) -- 392
	return true -- 394
end -- 327
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 397
	if fadeTime == nil then -- 397
		fadeTime = 0 -- 397
	end -- 397
	local entry = self.activeLoops[loopId] -- 398
	if entry == nil then -- 398
		return -- 400
	end -- 400
	if entry.source ~= nil then -- 400
		entry.source:stop(fadeTime) -- 403
		entry.source:removeFromParent(true) -- 404
	end -- 404
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 404
		Audio:stop(entry.handler) -- 407
	end -- 407
	__TS__Delete(self.activeLoops, loopId) -- 409
end -- 397
function AudioDirector.prototype.setPaused(self, paused) -- 413
	if self.paused == paused then -- 413
		return -- 415
	end -- 415
	self.paused = paused -- 417
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 417
		do -- 417
			pcall(function() -- 417
				Audio:setPauseAllCurrent(paused) -- 420
			end) -- 420
		end -- 420
	end -- 420
end -- 413
function AudioDirector.prototype.stopRoomTransient(self) -- 428
	local i = 0 -- 429
	do -- 429
		i = 0 -- 430
		while i < #self.activeSources do -- 430
			local src = self.activeSources[i + 1] -- 431
			if src.playing then -- 431
				src:stop(0) -- 433
			end -- 433
			src:removeFromParent(true) -- 435
			i = i + 1 -- 430
		end -- 430
	end -- 430
	self.activeSources = {} -- 437
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 437
		do -- 437
			i = 0 -- 440
			while i < #self.activeHandlers do -- 440
				Audio:stop(self.activeHandlers[i + 1]) -- 441
				i = i + 1 -- 440
			end -- 440
		end -- 440
	end -- 440
	self.activeHandlers = {} -- 444
	local loopIds = {} -- 446
	for id in pairs(self.activeLoops) do -- 447
		loopIds[#loopIds + 1] = id -- 448
	end -- 448
	do -- 448
		i = 0 -- 450
		while i < #loopIds do -- 450
			self:stopLoop(loopIds[i + 1], 0) -- 451
			i = i + 1 -- 450
		end -- 450
	end -- 450
	self.dedupeSet = {} -- 454
	if self.paused then -- 454
		self:setPaused(false) -- 456
	end -- 456
	self:setWorldPlaySpeed(1) -- 458
end -- 428
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 466
	if self.paused or #ev.rawEvents == 0 then -- 466
		return -- 468
	end -- 468
	local i = 0 -- 470
	do -- 470
		i = 0 -- 471
		while i < #ev.rawEvents do -- 471
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 472
			i = i + 1 -- 471
		end -- 471
	end -- 471
end -- 466
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 476
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 482
	if e.name == "knock" then -- 482
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 484
		local countTag = type(e.data.count) == "number" and "" .. tostring(e.data.count) or "1" -- 485
		self:playOnce( -- 486
			key, -- 486
			"sfx", -- 486
			"assets/audio/sfx/knock.wav", -- 486
			0.9, -- 486
			(("knock:" .. roomTag) .. ":") .. countTag, -- 486
			e.tick, -- 486
			e.seq -- 486
		) -- 486
		return -- 487
	end -- 487
	if e.name == "shotResolved" then -- 487
		local hit = e.data.hit == true -- 490
		self:playOnce( -- 491
			key, -- 491
			"sfx", -- 491
			"assets/audio/combat/shot.wav", -- 491
			0.85, -- 491
			hit and "shot:hit" or "shot:fire", -- 491
			e.tick, -- 491
			e.seq -- 491
		) -- 491
		return -- 492
	end -- 492
	if e.name == "coverBlocked" then -- 492
		self:playOnce( -- 495
			key, -- 495
			"sfx", -- 495
			"assets/audio/combat/cover_block.wav", -- 495
			0.85, -- 495
			"cover:blocked", -- 495
			e.tick, -- 495
			e.seq -- 495
		) -- 495
		return -- 496
	end -- 496
	if e.name == "actorHit" or e.name == "gateFailed" then -- 496
		self:playOnce( -- 499
			key, -- 499
			"sfx", -- 499
			"assets/audio/combat/actor_hit.wav", -- 499
			0.9, -- 499
			"actor:hit", -- 499
			e.tick, -- 499
			e.seq -- 499
		) -- 499
		return -- 500
	end -- 500
	if e.name == "bottleLanded" then -- 500
		local surface = "brick" -- 503
		if type(e.data.surface) == "string" then -- 503
			surface = e.data.surface -- 505
		elseif p.room.key == "village" then -- 505
			local landX = type(e.data.x) == "number" and e.data.x or p.bottleLandX -- 507
			if math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS then -- 507
				surface = "iron" -- 509
			elseif p.room.softX ~= nil and math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS then -- 509
				surface = "soft" -- 511
			end -- 511
		end -- 511
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 514
		self:playOnce( -- 517
			key, -- 517
			"sfx", -- 517
			path, -- 517
			0.9, -- 517
			"bottle:" .. surface, -- 517
			e.tick, -- 517
			e.seq -- 517
		) -- 517
		return -- 518
	end -- 518
	if e.name == "cartDocked" then -- 518
		self:playOnce( -- 521
			key, -- 521
			"sfx", -- 521
			"assets/audio/child/cart_dock.wav", -- 521
			0.88, -- 521
			"cart:docked", -- 521
			e.tick, -- 521
			e.seq -- 521
		) -- 521
		return -- 522
	end -- 522
	if e.name == "craftDone" or e.name == "benchCraft" then -- 522
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 525
		self:playOnce( -- 528
			key, -- 528
			"sfx", -- 528
			"assets/audio/combat/craft_done.wav", -- 528
			0.88, -- 528
			"craft:done" .. recipeTag, -- 528
			e.tick, -- 528
			e.seq -- 528
		) -- 528
		return -- 529
	end -- 529
	local name = e.name -- 532
	if name == "benchRejected" then -- 532
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 534
		self:playOnce( -- 535
			key, -- 535
			"sfx", -- 535
			"assets/audio/combat/craft_insufficient.wav", -- 535
			0.76, -- 535
			"craft:insufficient" .. recipeTag, -- 535
			e.tick, -- 535
			e.seq -- 535
		) -- 535
	elseif name == "handHeld" then -- 535
		self:playOnce( -- 537
			key, -- 537
			"sfx", -- 537
			"assets/audio/gate/reunion_hold.wav", -- 537
			0.9, -- 537
			"gate:hand_held", -- 537
			e.tick, -- 537
			e.seq -- 537
		) -- 537
	elseif name == "handRelease" then -- 537
		self:playOnce( -- 539
			key, -- 539
			"sfx", -- 539
			"assets/audio/gate/reunion_release.wav", -- 539
			0.7, -- 539
			"gate:hand_release", -- 539
			e.tick, -- 539
			e.seq -- 539
		) -- 539
	elseif name == "carryStart" then -- 539
		self:playOnce( -- 541
			key, -- 541
			"sfx", -- 541
			"assets/audio/combat/carry_start.wav", -- 541
			0.82, -- 541
			"combat:carry_start", -- 541
			e.tick, -- 541
			e.seq -- 541
		) -- 541
	elseif name == "reloadOpen" then -- 541
		self:playOnce( -- 543
			key, -- 543
			"sfx", -- 543
			"assets/audio/combat/reload_open.wav", -- 543
			0.8, -- 543
			"reload:open", -- 543
			e.tick, -- 543
			e.seq -- 543
		) -- 543
	elseif name == "reloadNode" then -- 543
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 545
		self:playOnce( -- 546
			key, -- 546
			"sfx", -- 546
			"assets/audio/combat/reload_node.wav", -- 546
			0.78, -- 546
			"reload:node:" .. nodeTag, -- 546
			e.tick, -- 546
			e.seq -- 546
		) -- 546
	elseif name == "reloadInvalid" then -- 546
		self:playOnce( -- 548
			key, -- 548
			"sfx", -- 548
			"assets/audio/combat/reload_invalid.wav", -- 548
			0.72, -- 548
			"reload:invalid", -- 548
			e.tick, -- 548
			e.seq -- 548
		) -- 548
	elseif name == "reloadSolved" then -- 548
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 550
		self:playOnce( -- 551
			key, -- 551
			"sfx", -- 551
			"assets/audio/combat/reload_solved.wav", -- 551
			0.9, -- 551
			"reload:solved:" .. eff, -- 551
			e.tick, -- 551
			e.seq -- 551
		) -- 551
	elseif name == "reloadTimeout" then -- 551
		self:playOnce( -- 553
			key, -- 553
			"sfx", -- 553
			"assets/audio/combat/reload_timeout.wav", -- 553
			0.78, -- 553
			"reload:timeout", -- 553
			e.tick, -- 553
			e.seq -- 553
		) -- 553
	elseif name == "artifactFound" then -- 553
		self:playOnce( -- 555
			key, -- 555
			"sfx", -- 555
			"assets/audio/museum/artifact_pickup.wav", -- 555
			0.88, -- 555
			"museum:artifact_found", -- 555
			e.tick, -- 555
			e.seq -- 555
		) -- 555
	elseif name == "museumStep" then -- 555
		local step = type(e.data.step) == "string" and e.data.step or "" -- 557
		local cnt = type(e.data.count) == "number" and e.data.count or 1 -- 558
		if step == "cabinet" then -- 558
			self:playOnce( -- 560
				key, -- 560
				"sfx", -- 560
				"assets/audio/museum/weapon_holster.wav", -- 560
				0.78, -- 560
				"museum:step:cabinet", -- 560
				e.tick, -- 560
				e.seq -- 560
			) -- 560
		elseif step == "hall" then -- 560
			self:playOnce( -- 562
				key, -- 562
				"sfx", -- 562
				"assets/audio/museum/child_steps_echo.wav", -- 562
				0.76, -- 562
				"museum:step:hall", -- 562
				e.tick, -- 562
				e.seq -- 562
			) -- 562
		elseif step == "lamp" then -- 562
			self:playOnce( -- 564
				key, -- 564
				"sfx", -- 564
				"assets/audio/museum/lamp_turn.wav", -- 564
				0.82, -- 564
				"museum:step:lamp", -- 564
				e.tick, -- 564
				e.seq -- 564
			) -- 564
		elseif step == "knock" then -- 564
			local knockPath = cnt >= 2 and "assets/audio/museum/knock_cabinet_second.wav" or "assets/audio/museum/knock_hall_first.wav" -- 566
			self:playOnce( -- 569
				key, -- 569
				"sfx", -- 569
				knockPath, -- 569
				0.9, -- 569
				"museum:step:knock:" .. tostring(cnt), -- 569
				e.tick, -- 569
				e.seq -- 569
			) -- 569
		end -- 569
	elseif name == "museumDone" then -- 569
		self:playOnce( -- 572
			key, -- 572
			"voice", -- 572
			"assets/audio/museum/line_dawn.wav", -- 572
			0.88, -- 572
			"museum:done", -- 572
			e.tick, -- 572
			e.seq -- 572
		) -- 572
	elseif name == "storyBeat" then -- 572
		local beat = type(e.data.beat) == "string" and e.data.beat or "" -- 574
		if beat == "red_cart" then -- 574
			self:playOnce( -- 576
				key, -- 576
				"sfx", -- 576
				"assets/audio/child/cart_dock.wav", -- 576
				0.84, -- 576
				"story:red_cart", -- 576
				e.tick, -- 576
				e.seq -- 576
			) -- 576
		elseif beat == "red_cart_memory" then -- 576
			self:playOnce( -- 578
				key, -- 578
				"sfx", -- 578
				"assets/audio/child/sewing_memory.wav", -- 578
				0.86, -- 578
				"story:red_cart_memory", -- 578
				e.tick, -- 578
				e.seq -- 578
			) -- 578
		elseif beat == "footstep_near" then -- 578
			self:playOnce( -- 580
				key, -- 580
				"sfx", -- 580
				"assets/audio/museum/hall_footstep.wav", -- 580
				0.72, -- 580
				"story:footstep_near", -- 580
				e.tick, -- 580
				e.seq -- 580
			) -- 580
		elseif beat == "footstep_far" then -- 580
			self:playOnce( -- 582
				key, -- 582
				"sfx", -- 582
				"assets/audio/museum/hall_footstep.wav", -- 582
				0.34, -- 582
				"story:footstep_far", -- 582
				e.tick, -- 582
				e.seq -- 582
			) -- 582
		elseif beat == "ditch" or beat == "path_burrow" then -- 582
			self:playOnce( -- 584
				key, -- 584
				"sfx", -- 584
				"assets/audio/child/twig_snap.wav", -- 584
				0.76, -- 584
				"story:" .. beat, -- 584
				e.tick, -- 584
				e.seq -- 584
			) -- 584
		elseif beat == "path_ditch" then -- 584
			self:playOnce( -- 586
				key, -- 586
				"sfx", -- 586
				"assets/audio/child/dog_step.wav", -- 586
				0.78, -- 586
				"story:path_ditch", -- 586
				e.tick, -- 586
				e.seq -- 586
			) -- 586
		elseif beat == "water_lantern" then -- 586
			self:playOnce( -- 588
				key, -- 588
				"sfx", -- 588
				"assets/audio/tower/lamp_move.wav", -- 588
				0.74, -- 588
				"story:water_lantern", -- 588
				e.tick, -- 588
				e.seq -- 588
			) -- 588
		elseif beat == "tower_door" then -- 588
			self:playOnce( -- 590
				key, -- 590
				"sfx", -- 590
				"assets/audio/tower/door_open.wav", -- 590
				0.78, -- 590
				"story:tower_door", -- 590
				e.tick, -- 590
				e.seq -- 590
			) -- 590
		elseif beat == "tower_threshold" then -- 590
			self:playOnce( -- 592
				key, -- 592
				"sfx", -- 592
				"assets/audio/museum/hall_footstep.wav", -- 592
				0.68, -- 592
				"story:tower_threshold", -- 592
				e.tick, -- 592
				e.seq -- 592
			) -- 592
		elseif beat == "tower_handover" then -- 592
			self:playOnce( -- 594
				key, -- 594
				"sfx", -- 594
				"assets/audio/tower/needle_case_place.wav", -- 594
				0.86, -- 594
				"story:tower_handover", -- 594
				e.tick, -- 594
				e.seq -- 594
			) -- 594
		elseif beat == "talent_picked" then -- 594
			self:playOnce( -- 596
				key, -- 596
				"sfx", -- 596
				"assets/audio/combat/reload_solved.wav", -- 596
				0.8, -- 596
				"story:talent_picked", -- 596
				e.tick, -- 596
				e.seq -- 596
			) -- 596
		end -- 596
	end -- 596
end -- 476
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 601
	return self.dedupeSet[dedupeKey] == true -- 602
end -- 601
function AudioDirector.prototype.getPlayLog(self) -- 605
	return self.playLog -- 606
end -- 605
function AudioDirector.prototype.getLastEntry(self) -- 609
	if #self.playLog == 0 then -- 609
		return nil -- 611
	end -- 611
	return self.playLog[#self.playLog] -- 613
end -- 609
function AudioDirector.prototype.clearPlayLog(self) -- 616
	self.playLog = {} -- 617
end -- 616
function AudioDirector.prototype.getTrackList(self) -- 620
	return ALL_TRACKS -- 621
end -- 620
function AudioDirector.prototype.pruneStoppedSources(self) -- 624
	local w = 0 -- 625
	local i = 0 -- 626
	do -- 626
		i = 0 -- 627
		while i < #self.activeSources do -- 627
			local src = self.activeSources[i + 1] -- 628
			if src.playing then -- 628
				self.activeSources[w + 1] = src -- 630
				w = w + 1 -- 631
			else -- 631
				src:removeFromParent(true) -- 633
			end -- 633
			i = i + 1 -- 627
		end -- 627
	end -- 627
	__TS__ArraySetLength(self.activeSources, w) -- 627
end -- 624
function AudioDirector.prototype.recordLog(self, entry) -- 639
	local ____self_playLog_2 = self.playLog -- 639
	____self_playLog_2[#____self_playLog_2 + 1] = entry -- 640
	if #self.playLog > MAX_PLAY_LOG then -- 640
		table.remove(self.playLog, 1) -- 642
	end -- 642
end -- 639
return ____exports -- 639