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
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 18
local isArtifactWeaponId = ____afterimage_artifact.isArtifactWeaponId -- 18
local ALL_TRACKS = { -- 76
	"voice", -- 76
	"wind", -- 76
	"water", -- 76
	"ambience", -- 76
	"sfx" -- 76
} -- 76
local MAX_PLAY_LOG = 256 -- 77
local MAX_BGM_LOG = 64 -- 78
--- 空村铁盆段内 X（与 village_undertable.ts VILLAGE_BASIN_OFFSET_X = 548 保持单一真源对齐）
local VILLAGE_BASIN_OFFSET_X = 548 -- 80
local VILLAGE_BASIN_HIT_RADIUS = 24 -- 81
local VILLAGE_SOFT_HIT_RADIUS = 34 -- 82
local function clamp01(v) -- 84
	return math.max( -- 85
		0, -- 85
		math.min(1, v) -- 85
	) -- 85
end -- 84
local function clampPan(v) -- 88
	return math.max( -- 89
		-0.85, -- 89
		math.min(0.85, v) -- 89
	) -- 89
end -- 88
--- Dora SSR Lua 运行时中，AudioBus / AudioSource 为带 __call 元表的可调用表（type 为 "table" 而非 "function"）。
-- 统一以 isCallableCtor 判定，避免音轨总线与循环声源在实机下退化失效。
local function isCallableCtor(ctor) -- 96
	return ctor ~= nil and (type(ctor) == "function" or type(ctor) == "table") -- 97
end -- 96
local function safeCreateBus() -- 100
	if not isCallableCtor(AudioBus) then -- 100
		return nil -- 102
	end -- 102
	do -- 102
		local function ____catch() -- 102
			return true, nil -- 107
		end -- 107
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 107
			return true, AudioBus() -- 105
		end) -- 105
		if not ____try then -- 105
			____hasReturned, ____returnValue = ____catch() -- 105
		end -- 105
		if ____hasReturned then -- 105
			return ____returnValue -- 104
		end -- 104
	end -- 104
end -- 100
local function safeCreateSource(path, autoRemove, bus) -- 111
	if not isCallableCtor(AudioSource) then -- 111
		return nil -- 117
	end -- 117
	do -- 117
		local function ____catch() -- 117
			return true, nil -- 122
		end -- 122
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 122
			return true, AudioSource(path, autoRemove, bus) -- 120
		end) -- 120
		if not ____try then -- 120
			____hasReturned, ____returnValue = ____catch() -- 120
		end -- 120
		if ____hasReturned then -- 120
			return ____returnValue -- 119
		end -- 119
	end -- 119
end -- 111
local function safeAudioPlay(path, loop) -- 126
	if type(Audio) == "nil" or type(Audio.play) ~= "function" then -- 126
		return 0 -- 128
	end -- 128
	do -- 128
		local function ____catch() -- 128
			return true, 0 -- 133
		end -- 133
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 133
			return true, Audio:play(path, loop) -- 131
		end) -- 131
		if not ____try then -- 131
			____hasReturned, ____returnValue = ____catch() -- 131
		end -- 131
		if ____hasReturned then -- 131
			return ____returnValue -- 130
		end -- 130
	end -- 130
end -- 126
local function safeSetLowpass(bus, active, cutoffHz, fadeSec) -- 137
	if bus == nil then -- 137
		return -- 139
	end -- 139
	do -- 139
		pcall(function() -- 139
			if active then -- 139
				bus:setFilter(0, "BiquadResonant") -- 143
				bus:setFilterParameter(0, 0, 1) -- 144
				bus:setFilterParameter(0, 1, 0) -- 145
				bus:setFilterParameter(0, 3, 1.2) -- 146
				bus:fadeFilterParameter( -- 147
					0, -- 147
					2, -- 147
					cutoffHz, -- 147
					math.max(0.02, fadeSec) -- 147
				) -- 147
			else -- 147
				bus:fadeFilterParameter( -- 149
					0, -- 149
					2, -- 149
					7900, -- 149
					math.max(0.02, fadeSec) -- 149
				) -- 149
				bus:fadeFilterParameter( -- 150
					0, -- 150
					0, -- 150
					0, -- 150
					math.max(0.02, fadeSec) -- 150
				) -- 150
			end -- 150
		end) -- 150
	end -- 150
end -- 137
local function resolveExisting(preferred, fallback) -- 157
	if preferred ~= "" and Content:exist(preferred) then -- 157
		return preferred -- 159
	end -- 159
	return fallback -- 161
end -- 157
____exports.AudioDirector = __TS__Class() -- 164
local AudioDirector = ____exports.AudioDirector -- 164
AudioDirector.name = "AudioDirector" -- 164
function AudioDirector.prototype.____constructor(self) -- 208
	self.bgmVolume = 1 -- 170
	self.bgmMuted = false -- 171
	self.userMasterVol = 1 -- 174
	self.userBgmVol = 0.8 -- 175
	self.userSfxVol = 0.9 -- 176
	self.userVoiceVol = 1 -- 177
	self.activeSources = {} -- 179
	self.activeHandlers = {} -- 180
	self.activeLoops = {} -- 181
	self.sceneAmbSlots = {} -- 182
	self.bgmFadeTimer = 0 -- 187
	self.bgmFadeDuration = 0 -- 188
	self.bgmTargetDuck = 1 -- 189
	self.bgmDuckGain = 1 -- 190
	self.bgmVoiceDuckHold = 0 -- 191
	self.bgmManualDuck = 1 -- 192
	self.bgmMuffled = false -- 193
	self.spaceMuffled = false -- 194
	self.bgmLog = {} -- 195
	self.dedupeSet = {} -- 197
	self.playLog = {} -- 198
	self.uiCooldowns = {} -- 199
	self.foleyCooldowns = {} -- 200
	self.clockSec = 0 -- 201
	self.jitterSeq = 0 -- 202
	self.camCenterX = 0 -- 203
	self.camSpanX = 1000 -- 204
	self.paused = false -- 205
	self.worldPlaySpeed = 1 -- 206
	self.buses = { -- 209
		voice = safeCreateBus(), -- 210
		wind = safeCreateBus(), -- 211
		water = safeCreateBus(), -- 212
		ambience = safeCreateBus(), -- 213
		sfx = safeCreateBus() -- 214
	} -- 214
	self.bgmBus = safeCreateBus() -- 216
	self.trackVolumes = { -- 217
		voice = 1, -- 218
		wind = 1, -- 219
		water = 1, -- 220
		ambience = 1, -- 221
		sfx = 1 -- 222
	} -- 222
	self.trackMuted = { -- 224
		voice = false, -- 225
		wind = false, -- 226
		water = false, -- 227
		ambience = false, -- 228
		sfx = false -- 229
	} -- 229
	self:syncAllBusGains() -- 231
end -- 208
function AudioDirector.prototype.attachHost(self, parent) -- 235
	if self.hostNode ~= nil then -- 235
		return -- 237
	end -- 237
	local n = Node() -- 239
	n.order = -1 -- 240
	n:addTo(parent) -- 241
	self.hostNode = n -- 242
end -- 235
function AudioDirector.prototype.setCameraRef(self, centerX, worldSpanX) -- 246
	self.camCenterX = centerX -- 247
	self.camSpanX = math.max(240, worldSpanX) -- 248
end -- 246
function AudioDirector.prototype.panForWorldX(self, worldX) -- 252
	return clampPan((worldX - self.camCenterX) / (self.camSpanX * 0.48)) -- 253
end -- 252
function AudioDirector.prototype.applyUserVolumes(self, s) -- 257
	self.userMasterVol = clamp01(s.masterVol) -- 258
	self.userBgmVol = clamp01(s.bgmVol) -- 259
	self.userSfxVol = clamp01(s.sfxVol) -- 260
	self.userVoiceVol = clamp01(s.voiceVol) -- 261
	self:syncAllBusGains() -- 262
end -- 257
function AudioDirector.prototype.getUserVolumes(self) -- 265
	return {masterVol = self.userMasterVol, bgmVol = self.userBgmVol, sfxVol = self.userSfxVol, voiceVol = self.userVoiceVol} -- 266
end -- 265
function AudioDirector.prototype.isPaused(self) -- 274
	return self.paused -- 275
end -- 274
function AudioDirector.prototype.getTrackVolume(self, track) -- 278
	return self.trackVolumes[track] -- 279
end -- 278
function AudioDirector.prototype.setTrackVolume(self, track, volume) -- 282
	local clamped = clamp01(volume) -- 283
	self.trackVolumes[track] = clamped -- 284
	self:syncBusGain(track) -- 285
end -- 282
function AudioDirector.prototype.getBgmVolume(self) -- 288
	return self.bgmVolume -- 289
end -- 288
function AudioDirector.prototype.setBgmVolume(self, volume) -- 292
	self.bgmVolume = clamp01(volume) -- 293
	self:syncBgmBusGain() -- 294
end -- 292
function AudioDirector.prototype.isTrackMuted(self, track) -- 297
	return self.trackMuted[track] -- 298
end -- 297
function AudioDirector.prototype.setTrackMuted(self, track, muted) -- 301
	self.trackMuted[track] = muted -- 302
	self:syncBusGain(track) -- 303
end -- 301
function AudioDirector.prototype.isAllMuted(self) -- 307
	local i = 0 -- 308
	do -- 308
		i = 0 -- 309
		while i < #ALL_TRACKS do -- 309
			if not self.trackMuted[ALL_TRACKS[i + 1]] then -- 309
				return false -- 311
			end -- 311
			i = i + 1 -- 309
		end -- 309
	end -- 309
	return true -- 314
end -- 307
function AudioDirector.prototype.toggleAllMuted(self) -- 318
	local next = not self:isAllMuted() -- 319
	local i = 0 -- 320
	do -- 320
		i = 0 -- 321
		while i < #ALL_TRACKS do -- 321
			self:setTrackMuted(ALL_TRACKS[i + 1], next) -- 322
			i = i + 1 -- 321
		end -- 321
	end -- 321
	self.bgmMuted = next -- 324
	self:syncBgmBusGain() -- 325
	return next -- 326
end -- 318
function AudioDirector.prototype.unlockAndResyncAfterGesture(self) -- 333
	self:syncAllBusGains() -- 334
	if self.paused then -- 334
		return -- 336
	end -- 336
	self:resyncLoopMap(self.activeLoops) -- 338
	self:resyncLoopMap(self.sceneAmbSlots) -- 339
	if self.menuAmbSlot ~= nil then -- 339
		self:resyncSingleLoop(self.menuAmbSlot) -- 341
	end -- 341
	if self.bgmCurrent ~= nil then -- 341
		local slot = self.bgmCurrent -- 344
		local stillPlaying = slot.source ~= nil and slot.source.playing -- 345
		if not stillPlaying and slot.handler == nil and slot.path ~= "" and Content:exist(slot.path) then -- 345
			self:startBgmSlotSource(slot) -- 347
		else -- 347
			self:applyBgmSlotGain(slot) -- 349
		end -- 349
	end -- 349
end -- 333
function AudioDirector.prototype.resyncLoopMap(self, map) -- 354
	for loopId in pairs(map) do -- 355
		self:resyncSingleLoop(map[loopId]) -- 356
	end -- 356
end -- 354
function AudioDirector.prototype.resyncSingleLoop(self, entry) -- 360
	local bus = self.buses[entry.track] -- 361
	local trackGain = self:effectiveTrackGain(entry.track) -- 362
	local stillPlaying = entry.source ~= nil and entry.source.playing -- 363
	if stillPlaying or entry.handler ~= nil then -- 363
		if entry.source ~= nil then -- 363
			entry.source.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 366
		end -- 366
		return -- 368
	end -- 368
	if entry.path ~= "" and Content:exist(entry.path) then -- 368
		local created = safeCreateSource(entry.path, false, bus) -- 371
		if created ~= nil then -- 371
			created.looping = true -- 373
			created.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 374
			if self.hostNode ~= nil then -- 374
				created:addTo(self.hostNode) -- 376
			end -- 376
			if created:play() then -- 376
				entry.source = created -- 379
			else -- 379
				created:removeFromParent(true) -- 381
			end -- 381
		else -- 381
			local h = safeAudioPlay(entry.path, true) -- 384
			if h > 0 then -- 384
				entry.handler = h -- 386
			end -- 386
		end -- 386
	end -- 386
end -- 360
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 393
	local next = math.max( -- 394
		0.25, -- 394
		math.min(2, speed) -- 394
	) -- 394
	local wantMuffle = next < 0.85 -- 395
	if wantMuffle ~= self.bgmMuffled then -- 395
		self.bgmMuffled = wantMuffle -- 397
		safeSetLowpass(self.bgmBus, wantMuffle, 950, wantMuffle and 0.18 or 0.24) -- 398
	end -- 398
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 398
		return -- 401
	end -- 401
	self.worldPlaySpeed = next -- 403
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 404
	local i = 0 -- 405
	do -- 405
		i = 0 -- 406
		while i < #worldTracks do -- 406
			local bus = self.buses[worldTracks[i + 1]] -- 407
			if bus ~= nil then -- 407
				bus.playSpeed = next -- 409
			end -- 409
			i = i + 1 -- 406
		end -- 406
	end -- 406
end -- 393
function AudioDirector.prototype.setSpaceMuffled(self, muffled) -- 415
	if self.spaceMuffled == muffled then -- 415
		return -- 417
	end -- 417
	self.spaceMuffled = muffled -- 419
	safeSetLowpass(self.buses.wind, muffled, 1100, 0.25) -- 420
	safeSetLowpass(self.buses.ambience, muffled, 1450, 0.25) -- 421
end -- 415
function AudioDirector.prototype.effectiveTrackGain(self, track) -- 424
	if self.trackMuted[track] then -- 424
		return 0 -- 426
	end -- 426
	local userCat = track == "voice" and self.userVoiceVol or self.userSfxVol -- 428
	return clamp01(self.trackVolumes[track] * self.userMasterVol * userCat) -- 429
end -- 424
function AudioDirector.prototype.effectiveBgmGain(self) -- 432
	if self.bgmMuted then -- 432
		return 0 -- 434
	end -- 434
	return clamp01(self.bgmVolume * self.bgmDuckGain * self.userMasterVol * self.userBgmVol) -- 436
end -- 432
function AudioDirector.prototype.syncBusGain(self, track) -- 439
	local bus = self.buses[track] -- 440
	local gain = self:effectiveTrackGain(track) -- 441
	if bus ~= nil then -- 441
		bus.volume = gain -- 443
	end -- 443
	if bus == nil then -- 443
		for id in pairs(self.activeLoops) do -- 447
			local e = self.activeLoops[id] -- 448
			if e.track == track and e.source ~= nil then -- 448
				e.source.volume = e.volume * gain -- 450
			end -- 450
		end -- 450
		for id in pairs(self.sceneAmbSlots) do -- 453
			local e = self.sceneAmbSlots[id] -- 454
			if e.track == track and e.source ~= nil then -- 454
				e.source.volume = e.volume * gain -- 456
			end -- 456
		end -- 456
		if self.menuAmbSlot ~= nil and self.menuAmbSlot.track == track and self.menuAmbSlot.source ~= nil then -- 456
			self.menuAmbSlot.source.volume = self.menuAmbSlot.volume * gain -- 460
		end -- 460
	end -- 460
end -- 439
function AudioDirector.prototype.syncBgmBusGain(self) -- 465
	local gain = self:effectiveBgmGain() -- 466
	if self.bgmBus ~= nil then -- 466
		self.bgmBus.volume = gain -- 468
	end -- 468
	if self.bgmCurrent ~= nil then -- 468
		self:applyBgmSlotGain(self.bgmCurrent) -- 471
	end -- 471
	if self.bgmFading ~= nil then -- 471
		self:applyBgmSlotGain(self.bgmFading) -- 474
	end -- 474
end -- 465
function AudioDirector.prototype.syncAllBusGains(self) -- 478
	local i = 0 -- 479
	do -- 479
		i = 0 -- 480
		while i < #ALL_TRACKS do -- 480
			self:syncBusGain(ALL_TRACKS[i + 1]) -- 481
			i = i + 1 -- 480
		end -- 480
	end -- 480
	self:syncBgmBusGain() -- 483
end -- 478
function AudioDirector.prototype.applyBgmSlotGain(self, slot) -- 486
	if slot.source == nil then -- 486
		return -- 488
	end -- 488
	local cueVol = clamp01(slot.baseVolume * slot.currentFade) -- 490
	slot.source.volume = self.bgmBus ~= nil and cueVol or cueVol * self:effectiveBgmGain() -- 491
end -- 486
function AudioDirector.prototype.startBgmSlotSource(self, slot) -- 494
	if slot.path == "" or not Content:exist(slot.path) then -- 494
		return false -- 496
	end -- 496
	local src = safeCreateSource(slot.path, false, self.bgmBus) -- 498
	if src ~= nil then -- 498
		src.looping = slot.looping -- 500
		if slot.looping and slot.loopPoint > 0.01 then -- 500
			do -- 500
				pcall(function() -- 500
					src:setLoopPoint(slot.loopPoint) -- 503
				end) -- 503
			end -- 503
		end -- 503
		do -- 503
			pcall(function() -- 503
				src:setProtected(true) -- 509
			end) -- 509
		end -- 509
		slot.source = src -- 513
		self:applyBgmSlotGain(slot) -- 514
		if self.hostNode ~= nil then -- 514
			src:addTo(self.hostNode) -- 516
		end -- 516
		local ok = src:play() -- 518
		if ok then -- 518
			return true -- 520
		end -- 520
		src:removeFromParent(true) -- 522
		slot.source = nil -- 523
	end -- 523
	local h = safeAudioPlay(slot.path, slot.looping) -- 525
	if h > 0 then -- 525
		slot.handler = h -- 527
		return true -- 528
	end -- 528
	return false -- 530
end -- 494
function AudioDirector.prototype.disposeBgmSlot(self, slot, fadeSec) -- 533
	if fadeSec == nil then -- 533
		fadeSec = 0 -- 533
	end -- 533
	if slot == nil then -- 533
		return -- 535
	end -- 535
	if slot.source ~= nil then -- 535
		do -- 535
			pcall(function() -- 535
				slot.source:stop(fadeSec) -- 539
			end) -- 539
		end -- 539
		slot.source:removeFromParent(true) -- 543
		slot.source = nil -- 544
	end -- 544
	if slot.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 544
		Audio:stop(slot.handler) -- 547
		slot.handler = nil -- 548
	end -- 548
end -- 533
function AudioDirector.prototype.playBgm(self, id, path, opts) -- 557
	local vol = clamp01(opts and opts.volume or 0.85) -- 558
	local fadeIn = math.max(0, opts and opts.fadeIn or 1.4) -- 559
	local ____temp_6 = opts and opts.looping -- 560
	if ____temp_6 == nil then -- 560
		____temp_6 = true -- 560
	end -- 560
	local looping = ____temp_6 -- 560
	local loopPoint = math.max(0, opts and opts.loopPoint or 0) -- 561
	local restart = (opts and opts.restart) == true -- 562
	if not restart and self.bgmCurrent ~= nil and self.bgmCurrent.id == id and self.bgmCurrent.path == path then -- 562
		self.bgmCurrent.baseVolume = vol -- 565
		self:applyBgmSlotGain(self.bgmCurrent) -- 566
		return false -- 567
	end -- 567
	if self.bgmFading ~= nil then -- 567
		self:disposeBgmSlot(self.bgmFading, 0) -- 572
		self.bgmFading = nil -- 573
	end -- 573
	if self.bgmCurrent ~= nil then -- 573
		if fadeIn > 0.05 then -- 573
			self.bgmFading = self.bgmCurrent -- 577
		else -- 577
			self:disposeBgmSlot(self.bgmCurrent, opts and opts.fadeOut or 0) -- 579
		end -- 579
		self.bgmCurrent = nil -- 581
	end -- 581
	local nextSlot = { -- 584
		id = id, -- 585
		path = path, -- 586
		baseVolume = vol, -- 587
		currentFade = fadeIn > 0.05 and 0 or 1, -- 588
		looping = looping, -- 589
		loopPoint = loopPoint, -- 590
		source = nil, -- 591
		handler = nil -- 592
	} -- 592
	local playedBackend = self:startBgmSlotSource(nextSlot) -- 594
	self.bgmCurrent = nextSlot -- 595
	self.bgmFadeDuration = fadeIn -- 596
	self.bgmFadeTimer = 0 -- 597
	local ____self_bgmLog_13 = self.bgmLog -- 597
	____self_bgmLog_13[#____self_bgmLog_13 + 1] = { -- 599
		id = id, -- 599
		path = path, -- 599
		looping = looping, -- 599
		loopPoint = loopPoint, -- 599
		playedBackend = playedBackend -- 599
	} -- 599
	if #self.bgmLog > MAX_BGM_LOG then -- 599
		table.remove(self.bgmLog, 1) -- 601
	end -- 601
	return true -- 603
end -- 557
function AudioDirector.prototype.stopBgm(self, fadeSec) -- 606
	if fadeSec == nil then -- 606
		fadeSec = 1 -- 606
	end -- 606
	if self.bgmFading ~= nil then -- 606
		self:disposeBgmSlot(self.bgmFading, 0) -- 608
		self.bgmFading = nil -- 609
	end -- 609
	if self.bgmCurrent == nil then -- 609
		return -- 612
	end -- 612
	if fadeSec > 0.05 then -- 612
		self.bgmFading = self.bgmCurrent -- 615
		self.bgmCurrent = nil -- 616
		self.bgmFadeDuration = fadeSec -- 617
		self.bgmFadeTimer = 0 -- 618
	else -- 618
		self:disposeBgmSlot(self.bgmCurrent, 0) -- 620
		self.bgmCurrent = nil -- 621
		self.bgmFadeDuration = 0 -- 622
		self.bgmFadeTimer = 0 -- 623
	end -- 623
end -- 606
function AudioDirector.prototype.setBgmManualDuck(self, gain) -- 628
	self.bgmManualDuck = clamp01(gain) -- 629
end -- 628
function AudioDirector.prototype.triggerVoiceDuck(self, holdSec) -- 633
	if holdSec == nil then -- 633
		holdSec = 1.6 -- 633
	end -- 633
	if holdSec > self.bgmVoiceDuckHold then -- 633
		self.bgmVoiceDuckHold = holdSec -- 635
	end -- 635
end -- 633
function AudioDirector.prototype.getCurrentBgmId(self) -- 639
	return self.bgmCurrent ~= nil and self.bgmCurrent.id or "" -- 640
end -- 639
function AudioDirector.prototype.getBgmLog(self) -- 643
	return self.bgmLog -- 644
end -- 643
function AudioDirector.prototype.update(self, dt) -- 648
	local safeDt = math.min( -- 649
		0.1, -- 649
		math.max(0, dt) -- 649
	) -- 649
	self.clockSec = self.clockSec + safeDt -- 650
	if self.paused then -- 650
		return -- 652
	end -- 652
	if self.bgmFadeDuration > 0.01 and (self.bgmCurrent ~= nil or self.bgmFading ~= nil) then -- 652
		self.bgmFadeTimer = math.min(self.bgmFadeDuration, self.bgmFadeTimer + safeDt) -- 657
		local u = clamp01(self.bgmFadeTimer / self.bgmFadeDuration) -- 658
		local inGain = math.sin(u * math.pi * 0.5) -- 659
		local outGain = math.cos(u * math.pi * 0.5) -- 660
		if self.bgmCurrent ~= nil then -- 660
			self.bgmCurrent.currentFade = inGain -- 662
			self:applyBgmSlotGain(self.bgmCurrent) -- 663
		end -- 663
		if self.bgmFading ~= nil then -- 663
			self.bgmFading.currentFade = outGain -- 666
			self:applyBgmSlotGain(self.bgmFading) -- 667
			if u >= 0.999 then -- 667
				self:disposeBgmSlot(self.bgmFading, 0) -- 669
				self.bgmFading = nil -- 670
			end -- 670
		end -- 670
		if u >= 0.999 then -- 670
			self.bgmFadeDuration = 0 -- 674
		end -- 674
	end -- 674
	if self.bgmVoiceDuckHold > 0 then -- 674
		self.bgmVoiceDuckHold = math.max(0, self.bgmVoiceDuckHold - safeDt) -- 680
	end -- 680
	local voiceDuck = self.bgmVoiceDuckHold > 0 and 0.48 or 1 -- 682
	self.bgmTargetDuck = math.min(voiceDuck, self.bgmManualDuck) -- 683
	if math.abs(self.bgmTargetDuck - self.bgmDuckGain) > 0.002 then -- 683
		local speed = self.bgmTargetDuck < self.bgmDuckGain and 7.5 or 2.2 -- 685
		self.bgmDuckGain = self.bgmDuckGain + (self.bgmTargetDuck - self.bgmDuckGain) * math.min(1, safeDt * speed) -- 686
		self:syncBgmBusGain() -- 687
	end -- 687
end -- 648
function AudioDirector.prototype.playUi(self, cueId, path, volume, cooldownSec) -- 694
	if volume == nil then -- 694
		volume = 0.72 -- 694
	end -- 694
	if cooldownSec == nil then -- 694
		cooldownSec = 0.045 -- 694
	end -- 694
	local prevAt = self.uiCooldowns[cueId] or -99 -- 695
	if self.clockSec - prevAt < cooldownSec then -- 695
		return false -- 697
	end -- 697
	self.uiCooldowns[cueId] = self.clockSec -- 699
	return self:playFireAndForget( -- 700
		"sfx", -- 700
		path, -- 700
		volume, -- 700
		0, -- 700
		false -- 700
	) -- 700
end -- 694
function AudioDirector.prototype.playFoley(self, cueId, path, volume, pan, cooldownMs) -- 706
	if volume == nil then -- 706
		volume = 0.65 -- 709
	end -- 709
	if pan == nil then -- 709
		pan = 0 -- 710
	end -- 710
	if cooldownMs == nil then -- 710
		cooldownMs = 60 -- 711
	end -- 711
	if self.paused then -- 711
		return false -- 714
	end -- 714
	local prevAt = self.foleyCooldowns[cueId] or -99 -- 716
	if (self.clockSec - prevAt) * 1000 < cooldownMs then -- 716
		return false -- 718
	end -- 718
	self.foleyCooldowns[cueId] = self.clockSec -- 720
	self.jitterSeq = (self.jitterSeq + 1) % 7 -- 721
	local jitter = 0.94 + self.jitterSeq * 0.02 -- 722
	return self:playFireAndForget( -- 723
		"sfx", -- 723
		path, -- 723
		clamp01(volume * jitter), -- 723
		pan, -- 723
		false -- 723
	) -- 723
end -- 706
function AudioDirector.prototype.playFireAndForget(self, track, path, volume, pan, isProtected) -- 726
	if path == "" or not Content:exist(path) then -- 726
		return false -- 734
	end -- 734
	self:pruneStoppedSources() -- 736
	local cueVol = clamp01(volume) -- 737
	local bus = self.buses[track] -- 738
	local src = safeCreateSource(path, false, bus) -- 739
	if src ~= nil then -- 739
		src.volume = bus ~= nil and cueVol or cueVol * self:effectiveTrackGain(track) -- 741
		src.looping = false -- 742
		if math.abs(pan) > 0.01 then -- 742
			src.pan = clampPan(pan) -- 744
		end -- 744
		if isProtected then -- 744
			do -- 744
				pcall(function() -- 744
					src:setProtected(true) -- 748
				end) -- 748
			end -- 748
		end -- 748
		if self.hostNode ~= nil then -- 748
			src:addTo(self.hostNode) -- 754
		end -- 754
		if src:play() then -- 754
			local ____self_activeSources_14 = self.activeSources -- 754
			____self_activeSources_14[#____self_activeSources_14 + 1] = src -- 757
			return true -- 758
		end -- 758
		src:removeFromParent(true) -- 760
		return false -- 761
	end -- 761
	local h = safeAudioPlay(path, false) -- 763
	if h > 0 then -- 763
		local ____self_activeHandlers_15 = self.activeHandlers -- 763
		____self_activeHandlers_15[#____self_activeHandlers_15 + 1] = h -- 765
		return true -- 766
	end -- 766
	return false -- 768
end -- 726
function AudioDirector.prototype.setSceneAmbience(self, slotId, track, path, volume) -- 774
	local prev = self.sceneAmbSlots[slotId] -- 775
	local clampedVol = clamp01(volume) -- 776
	local bus = self.buses[track] -- 777
	local trackGain = self:effectiveTrackGain(track) -- 778
	if prev ~= nil and prev.path == path and prev.track == track then -- 778
		prev.volume = clampedVol -- 780
		if prev.source ~= nil then -- 780
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 782
		end -- 782
		return -- 784
	end -- 784
	if prev ~= nil then -- 784
		self:stopSceneAmbience(slotId, 0.25) -- 787
	end -- 787
	local source -- 789
	local handler -- 790
	if path ~= "" and Content:exist(path) then -- 790
		local created = safeCreateSource(path, false, bus) -- 792
		if created ~= nil then -- 792
			created.looping = true -- 794
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 795
			if self.hostNode ~= nil then -- 795
				created:addTo(self.hostNode) -- 797
			end -- 797
			if created:play() then -- 797
				source = created -- 800
			else -- 800
				created:removeFromParent(true) -- 802
			end -- 802
		else -- 802
			local h = safeAudioPlay(path, true) -- 805
			if h > 0 then -- 805
				handler = h -- 807
			end -- 807
		end -- 807
	end -- 807
	self.sceneAmbSlots[slotId] = { -- 811
		track = track, -- 811
		path = path, -- 811
		volume = clampedVol, -- 811
		source = source, -- 811
		handler = handler -- 811
	} -- 811
end -- 774
function AudioDirector.prototype.stopSceneAmbience(self, slotId, fadeTime) -- 814
	if fadeTime == nil then -- 814
		fadeTime = 0.2 -- 814
	end -- 814
	local entry = self.sceneAmbSlots[slotId] -- 815
	if entry == nil then -- 815
		return -- 817
	end -- 817
	if entry.source ~= nil then -- 817
		entry.source:stop(fadeTime) -- 820
		entry.source:removeFromParent(true) -- 821
	end -- 821
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 821
		Audio:stop(entry.handler) -- 824
	end -- 824
	__TS__Delete(self.sceneAmbSlots, slotId) -- 826
end -- 814
function AudioDirector.prototype.setMenuAmbience(self, path, volume) -- 830
	local clampedVol = clamp01(volume) -- 831
	local bus = self.buses.ambience -- 832
	local trackGain = self:effectiveTrackGain("ambience") -- 833
	if self.menuAmbSlot ~= nil and self.menuAmbSlot.path == path then -- 833
		self.menuAmbSlot.volume = clampedVol -- 835
		if self.menuAmbSlot.source ~= nil then -- 835
			self.menuAmbSlot.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 837
		end -- 837
		return -- 839
	end -- 839
	self:stopMenuAmbience(0.2) -- 841
	local source -- 842
	local handler -- 843
	if path ~= "" and Content:exist(path) then -- 843
		local created = safeCreateSource(path, false, bus) -- 845
		if created ~= nil then -- 845
			created.looping = true -- 847
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 848
			if self.hostNode ~= nil then -- 848
				created:addTo(self.hostNode) -- 850
			end -- 850
			if created:play() then -- 850
				source = created -- 853
			else -- 853
				created:removeFromParent(true) -- 855
			end -- 855
		else -- 855
			local h = safeAudioPlay(path, true) -- 858
			if h > 0 then -- 858
				handler = h -- 860
			end -- 860
		end -- 860
	end -- 860
	self.menuAmbSlot = { -- 864
		track = "ambience", -- 864
		path = path, -- 864
		volume = clampedVol, -- 864
		source = source, -- 864
		handler = handler -- 864
	} -- 864
end -- 830
function AudioDirector.prototype.stopMenuAmbience(self, fadeTime) -- 867
	if fadeTime == nil then -- 867
		fadeTime = 0.25 -- 867
	end -- 867
	local entry = self.menuAmbSlot -- 868
	if entry == nil then -- 868
		return -- 870
	end -- 870
	if entry.source ~= nil then -- 870
		entry.source:stop(fadeTime) -- 873
		entry.source:removeFromParent(true) -- 874
	end -- 874
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 874
		Audio:stop(entry.handler) -- 877
	end -- 877
	self.menuAmbSlot = nil -- 879
end -- 867
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq, opts) -- 888
	if volume == nil then -- 888
		volume = 1 -- 892
	end -- 892
	if cueId == nil then -- 892
		cueId = "" -- 893
	end -- 893
	if tick == nil then -- 893
		tick = 0 -- 894
	end -- 894
	if seq == nil then -- 894
		seq = -1 -- 895
	end -- 895
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 895
		return false -- 899
	end -- 899
	if dedupeKey ~= "" then -- 899
		self.dedupeSet[dedupeKey] = true -- 902
	end -- 902
	local cueVol = clamp01(volume) -- 905
	local trackGain = self:effectiveTrackGain(track) -- 906
	local effectiveVol = cueVol * trackGain -- 907
	local playedBackend = false -- 908
	if track == "voice" then -- 908
		self:triggerVoiceDuck(1.8) -- 911
	end -- 911
	if path ~= "" and Content:exist(path) then -- 911
		self:pruneStoppedSources() -- 915
		local bus = self.buses[track] -- 916
		local src = safeCreateSource(path, false, bus) -- 917
		if src ~= nil then -- 917
			src.volume = bus ~= nil and cueVol or effectiveVol -- 919
			src.looping = false -- 920
			if (opts and opts.pan) ~= nil and math.abs(opts.pan) > 0.01 then -- 920
				src.pan = clampPan(opts.pan) -- 922
			end -- 922
			if track == "voice" or (opts and opts.protected) == true then -- 922
				do -- 922
					pcall(function() -- 922
						src:setProtected(true) -- 926
					end) -- 926
				end -- 926
			end -- 926
			if self.hostNode ~= nil then -- 926
				src:addTo(self.hostNode) -- 932
			end -- 932
			playedBackend = src:play() -- 934
			if playedBackend then -- 934
				local ____self_activeSources_20 = self.activeSources -- 934
				____self_activeSources_20[#____self_activeSources_20 + 1] = src -- 936
			else -- 936
				src:removeFromParent(true) -- 938
			end -- 938
		else -- 938
			local handler = safeAudioPlay(path, false) -- 941
			if handler > 0 then -- 941
				local ____self_activeHandlers_21 = self.activeHandlers -- 941
				____self_activeHandlers_21[#____self_activeHandlers_21 + 1] = handler -- 943
				playedBackend = true -- 944
			end -- 944
		end -- 944
	end -- 944
	self:recordLog({ -- 949
		tick = tick, -- 950
		seq = seq, -- 951
		track = track, -- 952
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 953
		dedupeKey = dedupeKey, -- 954
		path = path, -- 955
		volume = clamp01(volume), -- 956
		looped = false, -- 957
		playedBackend = playedBackend -- 958
	}) -- 958
	return true -- 960
end -- 888
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 964
	if volume == nil then -- 964
		volume = 1 -- 968
	end -- 968
	if tick == nil then -- 968
		tick = 0 -- 969
	end -- 969
	local prev = self.activeLoops[loopId] -- 971
	local clampedVol = clamp01(volume) -- 972
	local bus = self.buses[track] -- 973
	local trackGain = self:effectiveTrackGain(track) -- 974
	if prev ~= nil and prev.path == path and prev.track == track then -- 974
		prev.volume = clampedVol -- 976
		if prev.source ~= nil then -- 976
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 978
		end -- 978
		return false -- 980
	end -- 980
	if prev ~= nil then -- 980
		self:stopLoop(loopId, 0) -- 983
	end -- 983
	local source -- 986
	local handler -- 987
	local playedBackend = false -- 988
	if path ~= "" and Content:exist(path) then -- 988
		local created = safeCreateSource(path, false, bus) -- 990
		if created ~= nil then -- 990
			created.looping = true -- 992
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 993
			if self.hostNode ~= nil then -- 993
				created:addTo(self.hostNode) -- 995
			end -- 995
			playedBackend = created:play() -- 997
			if playedBackend then -- 997
				source = created -- 999
			else -- 999
				created:removeFromParent(true) -- 1001
			end -- 1001
		end -- 1001
		if not playedBackend then -- 1001
			local h = safeAudioPlay(path, true) -- 1005
			if h > 0 then -- 1005
				handler = h -- 1007
				playedBackend = true -- 1008
			end -- 1008
		end -- 1008
	end -- 1008
	self.activeLoops[loopId] = { -- 1013
		track = track, -- 1014
		path = path, -- 1015
		volume = clampedVol, -- 1016
		source = source, -- 1017
		handler = handler -- 1018
	} -- 1018
	self:recordLog({ -- 1020
		tick = tick, -- 1021
		seq = -1, -- 1022
		track = track, -- 1023
		cueId = "loop:" .. loopId, -- 1024
		dedupeKey = "loop:" .. loopId, -- 1025
		path = path, -- 1026
		volume = clampedVol, -- 1027
		looped = true, -- 1028
		playedBackend = playedBackend -- 1029
	}) -- 1029
	return true -- 1031
end -- 964
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 1034
	if fadeTime == nil then -- 1034
		fadeTime = 0 -- 1034
	end -- 1034
	local entry = self.activeLoops[loopId] -- 1035
	if entry == nil then -- 1035
		return -- 1037
	end -- 1037
	if entry.source ~= nil then -- 1037
		entry.source:stop(fadeTime) -- 1040
		entry.source:removeFromParent(true) -- 1041
	end -- 1041
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 1041
		Audio:stop(entry.handler) -- 1044
	end -- 1044
	__TS__Delete(self.activeLoops, loopId) -- 1046
end -- 1034
function AudioDirector.prototype.setPaused(self, paused) -- 1050
	if self.paused == paused then -- 1050
		return -- 1052
	end -- 1052
	self.paused = paused -- 1054
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 1054
		do -- 1054
			pcall(function() -- 1054
				Audio:setPauseAllCurrent(paused) -- 1057
			end) -- 1057
		end -- 1057
	end -- 1057
end -- 1050
function AudioDirector.prototype.stopRoomTransient(self) -- 1065
	local i = 0 -- 1066
	do -- 1066
		i = 0 -- 1067
		while i < #self.activeSources do -- 1067
			local src = self.activeSources[i + 1] -- 1068
			if src.playing then -- 1068
				src:stop(0) -- 1070
			end -- 1070
			src:removeFromParent(true) -- 1072
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	self.activeSources = {} -- 1074
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 1074
		do -- 1074
			i = 0 -- 1077
			while i < #self.activeHandlers do -- 1077
				Audio:stop(self.activeHandlers[i + 1]) -- 1078
				i = i + 1 -- 1077
			end -- 1077
		end -- 1077
	end -- 1077
	self.activeHandlers = {} -- 1081
	local loopIds = {} -- 1083
	for id in pairs(self.activeLoops) do -- 1084
		loopIds[#loopIds + 1] = id -- 1085
	end -- 1085
	do -- 1085
		i = 0 -- 1087
		while i < #loopIds do -- 1087
			self:stopLoop(loopIds[i + 1], 0) -- 1088
			i = i + 1 -- 1087
		end -- 1087
	end -- 1087
	local ambIds = {} -- 1091
	for id in pairs(self.sceneAmbSlots) do -- 1092
		ambIds[#ambIds + 1] = id -- 1093
	end -- 1093
	do -- 1093
		i = 0 -- 1095
		while i < #ambIds do -- 1095
			self:stopSceneAmbience(ambIds[i + 1], 0) -- 1096
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	self.dedupeSet = {} -- 1099
	if self.paused then -- 1099
		self:setPaused(false) -- 1101
	end -- 1101
	self:setWorldPlaySpeed(1) -- 1103
	self:setSpaceMuffled(false) -- 1104
	self.bgmManualDuck = 1 -- 1105
	self.bgmVoiceDuckHold = 0 -- 1106
end -- 1065
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 1114
	if self.paused or #ev.rawEvents == 0 then -- 1114
		return -- 1116
	end -- 1116
	local i = 0 -- 1118
	do -- 1118
		i = 0 -- 1119
		while i < #ev.rawEvents do -- 1119
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 1120
			i = i + 1 -- 1119
		end -- 1119
	end -- 1119
end -- 1114
function AudioDirector.prototype.panFromData(self, e, fallbackX) -- 1124
	local x = type(e.data.x) == "number" and e.data.x or (type(e.data.enemyX) == "number" and e.data.enemyX or (type(e.data.impactX) == "number" and e.data.impactX or fallbackX)) -- 1125
	return x ~= nil and x >= 0 and self:panForWorldX(x) or 0 -- 1130
end -- 1124
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 1133
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 1139
	local name = e.name -- 1140
	if name == "knock" then -- 1140
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 1143
		local countNum = type(e.data.count) == "number" and e.data.count or 1 -- 1144
		local vol = countNum >= 2 and 0.94 or 0.86 -- 1145
		self:playOnce( -- 1146
			key, -- 1147
			"sfx", -- 1148
			"assets/audio/sfx/knock.wav", -- 1149
			vol, -- 1150
			(("knock:" .. roomTag) .. ":") .. tostring(countNum), -- 1151
			e.tick, -- 1152
			e.seq, -- 1153
			{pan = self:panFromData(e, p.player.x)} -- 1154
		) -- 1154
		return -- 1156
	end -- 1156
	if name == "shotResolved" then -- 1156
		local hit = e.data.hit == true -- 1159
		local weapon = p.equippedWeapon -- 1160
		local shotPath = "assets/audio/combat/shot.wav" -- 1161
		if weapon == "guide_lantern_gun" then -- 1161
			shotPath = resolveExisting("assets/audio/combat/shot_lantern_gun.wav", shotPath) -- 1163
		elseif weapon == "echo_gun" then -- 1163
			shotPath = resolveExisting("assets/audio/combat/shot_echo_gun.wav", shotPath) -- 1165
		elseif isArtifactWeaponId(weapon) then -- 1165
			shotPath = resolveExisting("assets/audio/combat/shot_time_shuttler.wav", shotPath) -- 1167
		end -- 1167
		self:playOnce( -- 1169
			key, -- 1170
			"sfx", -- 1171
			shotPath, -- 1172
			0.86, -- 1173
			hit and "shot:hit" or "shot:fire", -- 1174
			e.tick, -- 1175
			e.seq, -- 1176
			{pan = self:panForWorldX(p.player.x) * 0.4} -- 1177
		) -- 1177
		if hit then -- 1177
			local enemyPan = self:panFromData(e) -- 1180
			if e.data.shield == true then -- 1180
				local shieldPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", "assets/audio/combat/cover_block.wav") -- 1182
				self:playOnce( -- 1183
					key .. ":shield", -- 1183
					"sfx", -- 1183
					shieldPath, -- 1183
					0.84, -- 1183
					"cover:shield", -- 1183
					e.tick, -- 1183
					e.seq, -- 1183
					{pan = enemyPan} -- 1183
				) -- 1183
			else -- 1183
				local downPath = "assets/audio/combat/enemy_down.wav" -- 1185
				if Content:exist(downPath) then -- 1185
					self:playOnce( -- 1187
						key .. ":down", -- 1187
						"sfx", -- 1187
						downPath, -- 1187
						0.78, -- 1187
						"combat:enemy_down", -- 1187
						e.tick, -- 1187
						e.seq, -- 1187
						{pan = enemyPan} -- 1187
					) -- 1187
				end -- 1187
			end -- 1187
		end -- 1187
		return -- 1191
	end -- 1191
	if name == "trialShot" then -- 1191
		self:playOnce( -- 1194
			key, -- 1194
			"sfx", -- 1194
			"assets/audio/combat/shot.wav", -- 1194
			0.85, -- 1194
			"trial:shot", -- 1194
			e.tick, -- 1194
			e.seq -- 1194
		) -- 1194
		return -- 1195
	end -- 1195
	if name == "coverBlocked" then -- 1195
		local ent = type(e.data.entity) == "string" and e.data.entity or "" -- 1198
		local blockPath = "assets/audio/combat/cover_block.wav" -- 1199
		if (string.find(ent, "盾", nil, true) or 0) - 1 >= 0 then -- 1199
			blockPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", blockPath) -- 1201
		elseif (string.find(ent, "木", nil, true) or 0) - 1 >= 0 or (string.find(ent, "柜", nil, true) or 0) - 1 >= 0 or (string.find(ent, "帘", nil, true) or 0) - 1 >= 0 or (string.find(ent, "板", nil, true) or 0) - 1 >= 0 then -- 1201
			blockPath = resolveExisting("assets/audio/combat/cover_block_wood.wav", blockPath) -- 1203
		elseif ent ~= "" then -- 1203
			blockPath = resolveExisting("assets/audio/combat/cover_block_stone.wav", blockPath) -- 1205
		end -- 1205
		local pan = self:panFromData(e) -- 1207
		self:playOnce( -- 1208
			key, -- 1208
			"sfx", -- 1208
			blockPath, -- 1208
			0.85, -- 1208
			"cover:blocked", -- 1208
			e.tick, -- 1208
			e.seq, -- 1208
			{pan = pan} -- 1208
		) -- 1208
		if type(e.data.enemyX) == "number" and Content:exist("assets/audio/combat/shot_enemy.wav") then -- 1208
			self:playOnce( -- 1210
				key .. ":eshot", -- 1210
				"sfx", -- 1210
				"assets/audio/combat/shot_enemy.wav", -- 1210
				0.56, -- 1210
				"combat:shot_enemy", -- 1210
				e.tick, -- 1210
				e.seq, -- 1210
				{pan = pan} -- 1210
			) -- 1210
		end -- 1210
		return -- 1212
	end -- 1212
	if name == "actorHit" or name == "gateFailed" then -- 1212
		local pan = self:panFromData(e) -- 1215
		self:playOnce( -- 1216
			key, -- 1216
			"sfx", -- 1216
			"assets/audio/combat/actor_hit.wav", -- 1216
			0.9, -- 1216
			"actor:hit", -- 1216
			e.tick, -- 1216
			e.seq, -- 1216
			{pan = pan * 0.4} -- 1216
		) -- 1216
		if name == "actorHit" and type(e.data.enemyX) == "number" and Content:exist("assets/audio/combat/shot_enemy.wav") then -- 1216
			self:playOnce( -- 1218
				key .. ":eshot", -- 1218
				"sfx", -- 1218
				"assets/audio/combat/shot_enemy.wav", -- 1218
				0.62, -- 1218
				"combat:shot_enemy", -- 1218
				e.tick, -- 1218
				e.seq, -- 1218
				{pan = pan} -- 1218
			) -- 1218
		end -- 1218
		if name == "gateFailed" and Content:exist("assets/audio/combat/campaign_failed.wav") then -- 1218
			self:playOnce( -- 1221
				key .. ":fail", -- 1221
				"sfx", -- 1221
				"assets/audio/combat/campaign_failed.wav", -- 1221
				0.86, -- 1221
				"combat:gate_failed", -- 1221
				e.tick, -- 1221
				e.seq -- 1221
			) -- 1221
		end -- 1221
		return -- 1223
	end -- 1223
	if name == "campaignFailed" then -- 1223
		self:playOnce( -- 1226
			key, -- 1226
			"sfx", -- 1226
			resolveExisting("assets/audio/combat/campaign_failed.wav", "assets/audio/combat/actor_hit.wav"), -- 1226
			0.88, -- 1226
			"combat:campaign_failed", -- 1226
			e.tick, -- 1226
			e.seq -- 1226
		) -- 1226
		return -- 1227
	end -- 1227
	if name == "gateRestart" then -- 1227
		self:playOnce( -- 1230
			key, -- 1230
			"sfx", -- 1230
			"assets/audio/combat/gate_winch_start.wav", -- 1230
			0.82, -- 1230
			"gate:winch_restart", -- 1230
			e.tick, -- 1230
			e.seq -- 1230
		) -- 1230
		return -- 1231
	end -- 1231
	if name == "bottleThrown" then -- 1231
		self:playOnce( -- 1234
			key, -- 1234
			"sfx", -- 1234
			"assets/audio/foley/bottle_throw.wav", -- 1234
			0.78, -- 1234
			"bottle:thrown", -- 1234
			e.tick, -- 1234
			e.seq, -- 1234
			{pan = self:panForWorldX(p.player.x)} -- 1234
		) -- 1234
		return -- 1235
	end -- 1235
	if name == "bottleLanded" then -- 1235
		local surface = "brick" -- 1238
		local landX = type(e.data.x) == "number" and e.data.x or p.bottleLandX -- 1239
		if type(e.data.surface) == "string" then -- 1239
			surface = e.data.surface -- 1241
		elseif p.room.key == "village" then -- 1241
			if math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS then -- 1241
				surface = "iron" -- 1244
			elseif p.room.softX ~= nil and math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS then -- 1244
				surface = "soft" -- 1246
			end -- 1246
		end -- 1246
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 1249
		self:playOnce( -- 1252
			key, -- 1252
			"sfx", -- 1252
			path, -- 1252
			0.9, -- 1252
			"bottle:" .. surface, -- 1252
			e.tick, -- 1252
			e.seq, -- 1252
			{pan = self:panForWorldX(landX)} -- 1252
		) -- 1252
		return -- 1253
	end -- 1253
	if name == "cartDocked" then -- 1253
		self:playOnce( -- 1256
			key, -- 1256
			"sfx", -- 1256
			"assets/audio/child/cart_dock.wav", -- 1256
			0.88, -- 1256
			"cart:docked", -- 1256
			e.tick, -- 1256
			e.seq, -- 1256
			{pan = self:panFromData(e, p.cartAxle)} -- 1256
		) -- 1256
		return -- 1257
	end -- 1257
	if name == "fearChanged" then -- 1257
		local fear = type(e.data.fear) == "number" and e.data.fear or 0 -- 1260
		if fear >= 3 then -- 1260
			self:playOnce( -- 1262
				key, -- 1262
				"sfx", -- 1262
				"assets/audio/foley/fear_freeze.wav", -- 1262
				0.84, -- 1262
				"escort:fear_freeze", -- 1262
				e.tick, -- 1262
				e.seq -- 1262
			) -- 1262
		elseif e.data.exposed == true then -- 1262
			self:playOnce( -- 1264
				key, -- 1264
				"sfx", -- 1264
				"assets/audio/foley/fear_gasp.wav", -- 1264
				0.78, -- 1264
				"escort:fear_gasp", -- 1264
				e.tick, -- 1264
				e.seq -- 1264
			) -- 1264
		end -- 1264
		return -- 1266
	end -- 1266
	if name == "pickup" then -- 1266
		local kind = type(e.data.kind) == "string" and e.data.kind or "gear" -- 1269
		local pickPath = "assets/audio/interact/pickup_gear.wav" -- 1270
		if kind == "bell" then -- 1270
			pickPath = "assets/audio/interact/pickup_bell.wav" -- 1272
		elseif kind == "wood" or kind == "scrap" or kind == "wedge" then -- 1272
			pickPath = "assets/audio/interact/pickup_wood.wav" -- 1274
		end -- 1274
		self:playOnce( -- 1276
			key, -- 1276
			"sfx", -- 1276
			pickPath, -- 1276
			0.8, -- 1276
			"interact:pickup:" .. kind, -- 1276
			e.tick, -- 1276
			e.seq, -- 1276
			{pan = self:panFromData(e)} -- 1276
		) -- 1276
		return -- 1277
	end -- 1277
	if name == "pickupRejected" then -- 1277
		self:playOnce( -- 1280
			key, -- 1280
			"sfx", -- 1280
			"assets/audio/interact/pickup_rejected.wav", -- 1280
			0.68, -- 1280
			"interact:pickup_rejected", -- 1280
			e.tick, -- 1280
			e.seq -- 1280
		) -- 1280
		return -- 1281
	end -- 1281
	if name == "craftStart" then -- 1281
		self:playOnce( -- 1284
			key, -- 1284
			"sfx", -- 1284
			"assets/audio/interact/wedge_craft_loop.wav", -- 1284
			0.72, -- 1284
			"craft:start", -- 1284
			e.tick, -- 1284
			e.seq -- 1284
		) -- 1284
		return -- 1285
	end -- 1285
	if name == "craftDone" or name == "benchCraft" then -- 1285
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 1288
		self:playOnce( -- 1291
			key, -- 1291
			"sfx", -- 1291
			"assets/audio/combat/craft_done.wav", -- 1291
			0.88, -- 1291
			"craft:done" .. recipeTag, -- 1291
			e.tick, -- 1291
			e.seq -- 1291
		) -- 1291
		return -- 1292
	end -- 1292
	if name == "benchOpen" then -- 1292
		self:playOnce( -- 1295
			key, -- 1295
			"sfx", -- 1295
			"assets/audio/interact/bench_open.wav", -- 1295
			0.76, -- 1295
			"bench:open", -- 1295
			e.tick, -- 1295
			e.seq -- 1295
		) -- 1295
		return -- 1296
	end -- 1296
	if name == "benchClose" then -- 1296
		self:playOnce( -- 1299
			key, -- 1299
			"sfx", -- 1299
			"assets/audio/interact/bench_close.wav", -- 1299
			0.7, -- 1299
			"bench:close", -- 1299
			e.tick, -- 1299
			e.seq -- 1299
		) -- 1299
		return -- 1300
	end -- 1300
	if name == "benchEquip" then -- 1300
		self:playOnce( -- 1303
			key, -- 1303
			"sfx", -- 1303
			"assets/audio/interact/bench_equip.wav", -- 1303
			0.8, -- 1303
			"bench:equip", -- 1303
			e.tick, -- 1303
			e.seq -- 1303
		) -- 1303
		return -- 1304
	end -- 1304
	if name == "benchRejected" then -- 1304
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 1307
		self:playOnce( -- 1308
			key, -- 1308
			"sfx", -- 1308
			"assets/audio/combat/craft_insufficient.wav", -- 1308
			0.76, -- 1308
			"craft:insufficient" .. recipeTag, -- 1308
			e.tick, -- 1308
			e.seq -- 1308
		) -- 1308
		return -- 1309
	end -- 1309
	if name == "propBroken" then -- 1309
		local phase = type(e.data.phase) == "string" and e.data.phase or "broken" -- 1312
		local propPath = phase == "crack" and "assets/audio/combat/prop_crack.wav" or "assets/audio/combat/prop_break.wav" -- 1313
		self:playOnce( -- 1314
			key, -- 1314
			"sfx", -- 1314
			propPath, -- 1314
			0.84, -- 1314
			"combat:prop_" .. phase, -- 1314
			e.tick, -- 1314
			e.seq, -- 1314
			{pan = self:panFromData(e)} -- 1314
		) -- 1314
		return -- 1315
	end -- 1315
	if name == "interactUsed" then -- 1315
		local kind = type(e.data.kind) == "string" and e.data.kind or "" -- 1318
		local path = "" -- 1319
		if kind == "wedge" then -- 1319
			path = "assets/audio/interact/wedge_place.wav" -- 1320
		elseif kind == "ammo" then -- 1320
			path = "assets/audio/interact/ammo_quickload.wav" -- 1321
		elseif kind == "shield" then -- 1321
			path = "assets/audio/interact/shield_deploy.wav" -- 1322
		elseif kind == "pass" then -- 1322
			path = "assets/audio/interact/pass_signal.wav" -- 1323
		elseif kind == "open_board" then -- 1323
			path = "assets/audio/interact/window_board_drop.wav" -- 1324
		elseif kind == "lower_curtain" then -- 1324
			path = "assets/audio/interact/curtain_lower.wav" -- 1325
		elseif kind == "raise_latch" then -- 1325
			path = "assets/audio/interact/latch_raise.wav" -- 1326
		end -- 1326
		if path ~= "" then -- 1326
			self:playOnce( -- 1328
				key, -- 1328
				"sfx", -- 1328
				path, -- 1328
				0.86, -- 1328
				"interact:" .. kind, -- 1328
				e.tick, -- 1328
				e.seq, -- 1328
				{pan = self:panFromData(e)} -- 1328
			) -- 1328
		end -- 1328
		return -- 1330
	end -- 1330
	if name == "roomChange" then -- 1330
		self:playOnce( -- 1333
			key, -- 1333
			"sfx", -- 1333
			"assets/audio/ui/chapter_banner.wav", -- 1333
			0.62, -- 1333
			"ui:room_change", -- 1333
			e.tick, -- 1333
			e.seq -- 1333
		) -- 1333
		return -- 1334
	end -- 1334
	if name == "objectiveDone" or name == "segmentDone" then -- 1334
		self:playOnce( -- 1337
			key, -- 1337
			"sfx", -- 1337
			"assets/audio/ui/segment_clear.wav", -- 1337
			0.74, -- 1337
			"ui:" .. name, -- 1337
			e.tick, -- 1337
			e.seq -- 1337
		) -- 1337
		return -- 1338
	end -- 1338
	if name == "handHeld" then -- 1338
		self:playOnce( -- 1341
			key, -- 1341
			"sfx", -- 1341
			"assets/audio/gate/reunion_hold.wav", -- 1341
			0.9, -- 1341
			"gate:hand_held", -- 1341
			e.tick, -- 1341
			e.seq -- 1341
		) -- 1341
		return -- 1342
	end -- 1342
	if name == "handRelease" then -- 1342
		self:playOnce( -- 1345
			key, -- 1345
			"sfx", -- 1345
			"assets/audio/gate/reunion_release.wav", -- 1345
			0.7, -- 1345
			"gate:hand_release", -- 1345
			e.tick, -- 1345
			e.seq -- 1345
		) -- 1345
		return -- 1346
	end -- 1346
	if name == "carryStart" then -- 1346
		self:playOnce( -- 1349
			key, -- 1349
			"sfx", -- 1349
			"assets/audio/combat/carry_start.wav", -- 1349
			0.82, -- 1349
			"combat:carry_start", -- 1349
			e.tick, -- 1349
			e.seq -- 1349
		) -- 1349
		return -- 1350
	end -- 1350
	if name == "reloadOpen" then -- 1350
		self:playOnce( -- 1353
			key, -- 1353
			"sfx", -- 1353
			"assets/audio/combat/reload_open.wav", -- 1353
			0.8, -- 1353
			"reload:open", -- 1353
			e.tick, -- 1353
			e.seq -- 1353
		) -- 1353
		return -- 1354
	end -- 1354
	if name == "reloadNode" then -- 1354
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 1357
		local plen = type(e.data.pathLength) == "number" and math.max( -- 1358
			1, -- 1358
			math.min( -- 1358
				6, -- 1358
				math.floor(e.data.pathLength) -- 1358
			) -- 1358
		) or 1 -- 1358
		local nodePath = resolveExisting( -- 1359
			("assets/audio/combat/reload_node_" .. tostring(plen)) .. ".wav", -- 1359
			"assets/audio/combat/reload_node.wav" -- 1359
		) -- 1359
		self:playOnce( -- 1360
			key, -- 1360
			"sfx", -- 1360
			nodePath, -- 1360
			0.78, -- 1360
			"reload:node:" .. nodeTag, -- 1360
			e.tick, -- 1360
			e.seq -- 1360
		) -- 1360
		return -- 1361
	end -- 1361
	if name == "reloadInvalid" then -- 1361
		self:playOnce( -- 1364
			key, -- 1364
			"sfx", -- 1364
			"assets/audio/combat/reload_invalid.wav", -- 1364
			0.72, -- 1364
			"reload:invalid", -- 1364
			e.tick, -- 1364
			e.seq -- 1364
		) -- 1364
		return -- 1365
	end -- 1365
	if name == "reloadSolved" then -- 1365
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 1368
		self:playOnce( -- 1369
			key, -- 1369
			"sfx", -- 1369
			"assets/audio/combat/reload_solved.wav", -- 1369
			0.9, -- 1369
			"reload:solved:" .. eff, -- 1369
			e.tick, -- 1369
			e.seq -- 1369
		) -- 1369
		return -- 1370
	end -- 1370
	if name == "reloadTimeout" then -- 1370
		self:playOnce( -- 1373
			key, -- 1373
			"sfx", -- 1373
			"assets/audio/combat/reload_timeout.wav", -- 1373
			0.78, -- 1373
			"reload:timeout", -- 1373
			e.tick, -- 1373
			e.seq -- 1373
		) -- 1373
		return -- 1374
	end -- 1374
	if name == "reloadApplied" then -- 1374
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 1377
		local fxPath = eff == "echo" and "assets/audio/combat/reload_fx_echo.wav" or (eff == "light" and "assets/audio/combat/reload_fx_light.wav" or "assets/audio/combat/reload_fx_push.wav") -- 1378
		self:playOnce( -- 1381
			key, -- 1381
			"sfx", -- 1381
			fxPath, -- 1381
			0.84, -- 1381
			"reload:applied:" .. eff, -- 1381
			e.tick, -- 1381
			e.seq, -- 1381
			{pan = self:panFromData(e)} -- 1381
		) -- 1381
		return -- 1382
	end -- 1382
	if name == "artifactFound" then -- 1382
		self:playOnce( -- 1385
			key, -- 1385
			"sfx", -- 1385
			"assets/audio/museum/artifact_pickup.wav", -- 1385
			0.88, -- 1385
			"museum:artifact_found", -- 1385
			e.tick, -- 1385
			e.seq -- 1385
		) -- 1385
		return -- 1386
	end -- 1386
	if name == "museumStep" then -- 1386
		local step = type(e.data.step) == "string" and e.data.step or "" -- 1389
		local cnt = type(e.data.count) == "number" and e.data.count or 1 -- 1390
		if step == "cabinet" then -- 1390
			self:playOnce( -- 1392
				key, -- 1392
				"sfx", -- 1392
				"assets/audio/museum/weapon_holster.wav", -- 1392
				0.78, -- 1392
				"museum:step:cabinet", -- 1392
				e.tick, -- 1392
				e.seq -- 1392
			) -- 1392
		elseif step == "hall" then -- 1392
			self:playOnce( -- 1394
				key, -- 1394
				"sfx", -- 1394
				"assets/audio/museum/child_steps_echo.wav", -- 1394
				0.76, -- 1394
				"museum:step:hall", -- 1394
				e.tick, -- 1394
				e.seq -- 1394
			) -- 1394
		elseif step == "lamp" then -- 1394
			self:playOnce( -- 1396
				key, -- 1396
				"sfx", -- 1396
				"assets/audio/museum/lamp_turn.wav", -- 1396
				0.82, -- 1396
				"museum:step:lamp", -- 1396
				e.tick, -- 1396
				e.seq -- 1396
			) -- 1396
		elseif step == "knock" then -- 1396
			local knockPath = cnt >= 2 and "assets/audio/museum/knock_cabinet_second.wav" or "assets/audio/museum/knock_hall_first.wav" -- 1398
			self:playOnce( -- 1401
				key, -- 1401
				"sfx", -- 1401
				knockPath, -- 1401
				0.9, -- 1401
				"museum:step:knock:" .. tostring(cnt), -- 1401
				e.tick, -- 1401
				e.seq -- 1401
			) -- 1401
		end -- 1401
		return -- 1403
	end -- 1403
	if name == "museumDone" then -- 1403
		self:playOnce( -- 1406
			key, -- 1406
			"voice", -- 1406
			"assets/audio/museum/line_dawn.wav", -- 1406
			0.88, -- 1406
			"museum:done", -- 1406
			e.tick, -- 1406
			e.seq -- 1406
		) -- 1406
		return -- 1407
	end -- 1407
	if name == "storyBeat" then -- 1407
		local beat = type(e.data.beat) == "string" and e.data.beat or "" -- 1410
		local pan = self:panFromData(e) -- 1411
		if beat == "red_cart" then -- 1411
			self:playOnce( -- 1413
				key, -- 1413
				"sfx", -- 1413
				"assets/audio/child/cart_dock.wav", -- 1413
				0.84, -- 1413
				"story:red_cart", -- 1413
				e.tick, -- 1413
				e.seq, -- 1413
				{pan = pan} -- 1413
			) -- 1413
		elseif beat == "red_cart_memory" then -- 1413
			self:playOnce( -- 1415
				key, -- 1415
				"sfx", -- 1415
				"assets/audio/child/sewing_memory.wav", -- 1415
				0.86, -- 1415
				"story:red_cart_memory", -- 1415
				e.tick, -- 1415
				e.seq -- 1415
			) -- 1415
		elseif beat == "footstep_near" then -- 1415
			local pNear = resolveExisting("assets/audio/foley/step_scavenger_1.wav", "assets/audio/museum/hall_footstep.wav") -- 1417
			self:playOnce( -- 1418
				key, -- 1418
				"sfx", -- 1418
				pNear, -- 1418
				0.76, -- 1418
				"story:footstep_near", -- 1418
				e.tick, -- 1418
				e.seq, -- 1418
				{pan = pan} -- 1418
			) -- 1418
		elseif beat == "footstep_far" then -- 1418
			local pFar = resolveExisting("assets/audio/foley/step_scavenger_2.wav", "assets/audio/museum/hall_footstep.wav") -- 1420
			self:playOnce( -- 1421
				key, -- 1421
				"sfx", -- 1421
				pFar, -- 1421
				0.36, -- 1421
				"story:footstep_far", -- 1421
				e.tick, -- 1421
				e.seq, -- 1421
				{pan = pan} -- 1421
			) -- 1421
		elseif beat == "ditch" or beat == "path_burrow" then -- 1421
			self:playOnce( -- 1423
				key, -- 1423
				"sfx", -- 1423
				"assets/audio/child/twig_snap.wav", -- 1423
				0.76, -- 1423
				"story:" .. beat, -- 1423
				e.tick, -- 1423
				e.seq, -- 1423
				{pan = pan} -- 1423
			) -- 1423
		elseif beat == "path_ditch" then -- 1423
			self:playOnce( -- 1425
				key, -- 1425
				"sfx", -- 1425
				"assets/audio/child/dog_step.wav", -- 1425
				0.78, -- 1425
				"story:path_ditch", -- 1425
				e.tick, -- 1425
				e.seq, -- 1425
				{pan = pan} -- 1425
			) -- 1425
		elseif beat == "water_lantern" then -- 1425
			self:playOnce( -- 1427
				key, -- 1427
				"sfx", -- 1427
				"assets/audio/tower/lamp_move.wav", -- 1427
				0.74, -- 1427
				"story:water_lantern", -- 1427
				e.tick, -- 1427
				e.seq -- 1427
			) -- 1427
		elseif beat == "tower_door" then -- 1427
			self:playOnce( -- 1429
				key, -- 1429
				"sfx", -- 1429
				"assets/audio/tower/door_open.wav", -- 1429
				0.78, -- 1429
				"story:tower_door", -- 1429
				e.tick, -- 1429
				e.seq -- 1429
			) -- 1429
		elseif beat == "tower_threshold" then -- 1429
			local pStep = resolveExisting("assets/audio/foley/step_child_stone_1.wav", "assets/audio/museum/hall_footstep.wav") -- 1431
			self:playOnce( -- 1432
				key, -- 1432
				"sfx", -- 1432
				pStep, -- 1432
				0.68, -- 1432
				"story:tower_threshold", -- 1432
				e.tick, -- 1432
				e.seq -- 1432
			) -- 1432
		elseif beat == "tower_handover" then -- 1432
			self:playOnce( -- 1434
				key, -- 1434
				"sfx", -- 1434
				"assets/audio/tower/needle_case_place.wav", -- 1434
				0.86, -- 1434
				"story:tower_handover", -- 1434
				e.tick, -- 1434
				e.seq -- 1434
			) -- 1434
		elseif beat == "talent_picked" then -- 1434
			local pTal = resolveExisting("assets/audio/ui/talent_pick.wav", "assets/audio/combat/reload_solved.wav") -- 1436
			self:playOnce( -- 1437
				key, -- 1437
				"sfx", -- 1437
				pTal, -- 1437
				0.82, -- 1437
				"story:talent_picked", -- 1437
				e.tick, -- 1437
				e.seq -- 1437
			) -- 1437
		end -- 1437
	end -- 1437
end -- 1133
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 1442
	return self.dedupeSet[dedupeKey] == true -- 1443
end -- 1442
function AudioDirector.prototype.getPlayLog(self) -- 1446
	return self.playLog -- 1447
end -- 1446
function AudioDirector.prototype.getLastEntry(self) -- 1450
	if #self.playLog == 0 then -- 1450
		return nil -- 1452
	end -- 1452
	return self.playLog[#self.playLog] -- 1454
end -- 1450
function AudioDirector.prototype.clearPlayLog(self) -- 1457
	self.playLog = {} -- 1458
end -- 1457
function AudioDirector.prototype.getTrackList(self) -- 1461
	return ALL_TRACKS -- 1462
end -- 1461
function AudioDirector.prototype.pruneStoppedSources(self) -- 1465
	local w = 0 -- 1466
	local i = 0 -- 1467
	do -- 1467
		i = 0 -- 1468
		while i < #self.activeSources do -- 1468
			local src = self.activeSources[i + 1] -- 1469
			if src.playing then -- 1469
				self.activeSources[w + 1] = src -- 1471
				w = w + 1 -- 1472
			else -- 1472
				src:removeFromParent(true) -- 1474
			end -- 1474
			i = i + 1 -- 1468
		end -- 1468
	end -- 1468
	__TS__ArraySetLength(self.activeSources, w) -- 1468
end -- 1465
function AudioDirector.prototype.recordLog(self, entry) -- 1480
	local ____self_playLog_22 = self.playLog -- 1480
	____self_playLog_22[#____self_playLog_22 + 1] = entry -- 1481
	if #self.playLog > MAX_PLAY_LOG then -- 1481
		table.remove(self.playLog, 1) -- 1483
	end -- 1483
end -- 1480
return ____exports -- 1480