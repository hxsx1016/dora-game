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
function AudioDirector.prototype.setAllMuted(self, muted) -- 318
	local i = 0 -- 319
	do -- 319
		i = 0 -- 320
		while i < #ALL_TRACKS do -- 320
			self:setTrackMuted(ALL_TRACKS[i + 1], muted) -- 321
			i = i + 1 -- 320
		end -- 320
	end -- 320
	self.bgmMuted = muted -- 323
	self:syncBgmBusGain() -- 324
end -- 318
function AudioDirector.prototype.toggleAllMuted(self) -- 328
	local next = not self:isAllMuted() -- 329
	self:setAllMuted(next) -- 330
	return next -- 331
end -- 328
function AudioDirector.prototype.unlockAndResyncAfterGesture(self) -- 338
	self:syncAllBusGains() -- 339
	if self.paused then -- 339
		return -- 341
	end -- 341
	self:resyncLoopMap(self.activeLoops) -- 343
	self:resyncLoopMap(self.sceneAmbSlots) -- 344
	if self.menuAmbSlot ~= nil then -- 344
		self:resyncSingleLoop(self.menuAmbSlot) -- 346
	end -- 346
	if self.bgmCurrent ~= nil then -- 346
		local slot = self.bgmCurrent -- 349
		local stillPlaying = slot.source ~= nil and slot.source.playing -- 350
		if not stillPlaying and slot.handler == nil and slot.path ~= "" and Content:exist(slot.path) then -- 350
			self:startBgmSlotSource(slot) -- 352
		else -- 352
			self:applyBgmSlotGain(slot) -- 354
		end -- 354
	end -- 354
end -- 338
function AudioDirector.prototype.resyncLoopMap(self, map) -- 359
	for loopId in pairs(map) do -- 360
		self:resyncSingleLoop(map[loopId]) -- 361
	end -- 361
end -- 359
function AudioDirector.prototype.resyncSingleLoop(self, entry) -- 365
	local bus = self.buses[entry.track] -- 366
	local trackGain = self:effectiveTrackGain(entry.track) -- 367
	local stillPlaying = entry.source ~= nil and entry.source.playing -- 368
	if stillPlaying or entry.handler ~= nil then -- 368
		if entry.source ~= nil then -- 368
			entry.source.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 371
		end -- 371
		return -- 373
	end -- 373
	if entry.path ~= "" and Content:exist(entry.path) then -- 373
		local created = safeCreateSource(entry.path, false, bus) -- 376
		if created ~= nil then -- 376
			created.looping = true -- 378
			created.volume = bus ~= nil and entry.volume or entry.volume * trackGain -- 379
			if self.hostNode ~= nil then -- 379
				created:addTo(self.hostNode) -- 381
			end -- 381
			if created:play() then -- 381
				entry.source = created -- 384
			else -- 384
				created:removeFromParent(true) -- 386
			end -- 386
		else -- 386
			local h = safeAudioPlay(entry.path, true) -- 389
			if h > 0 then -- 389
				entry.handler = h -- 391
			end -- 391
		end -- 391
	end -- 391
end -- 365
function AudioDirector.prototype.setWorldPlaySpeed(self, speed) -- 398
	local next = math.max( -- 399
		0.25, -- 399
		math.min(2, speed) -- 399
	) -- 399
	local wantMuffle = next < 0.85 -- 400
	if wantMuffle ~= self.bgmMuffled then -- 400
		self.bgmMuffled = wantMuffle -- 402
		safeSetLowpass(self.bgmBus, wantMuffle, 950, wantMuffle and 0.18 or 0.24) -- 403
	end -- 403
	if math.abs(next - self.worldPlaySpeed) < 0.001 then -- 403
		return -- 406
	end -- 406
	self.worldPlaySpeed = next -- 408
	local worldTracks = {"wind", "water", "ambience", "sfx"} -- 409
	local i = 0 -- 410
	do -- 410
		i = 0 -- 411
		while i < #worldTracks do -- 411
			local bus = self.buses[worldTracks[i + 1]] -- 412
			if bus ~= nil then -- 412
				bus.playSpeed = next -- 414
			end -- 414
			i = i + 1 -- 411
		end -- 411
	end -- 411
end -- 398
function AudioDirector.prototype.setSpaceMuffled(self, muffled) -- 420
	if self.spaceMuffled == muffled then -- 420
		return -- 422
	end -- 422
	self.spaceMuffled = muffled -- 424
	safeSetLowpass(self.buses.wind, muffled, 1100, 0.25) -- 425
	safeSetLowpass(self.buses.ambience, muffled, 1450, 0.25) -- 426
end -- 420
function AudioDirector.prototype.effectiveTrackGain(self, track) -- 429
	if self.trackMuted[track] then -- 429
		return 0 -- 431
	end -- 431
	local userCat = track == "voice" and self.userVoiceVol or self.userSfxVol -- 433
	return clamp01(self.trackVolumes[track] * self.userMasterVol * userCat) -- 434
end -- 429
function AudioDirector.prototype.effectiveBgmGain(self) -- 437
	if self.bgmMuted then -- 437
		return 0 -- 439
	end -- 439
	return clamp01(self.bgmVolume * self.bgmDuckGain * self.userMasterVol * self.userBgmVol) -- 441
end -- 437
function AudioDirector.prototype.syncBusGain(self, track) -- 444
	local bus = self.buses[track] -- 445
	local gain = self:effectiveTrackGain(track) -- 446
	if bus ~= nil then -- 446
		bus.volume = gain -- 448
	end -- 448
	if bus == nil then -- 448
		for id in pairs(self.activeLoops) do -- 452
			local e = self.activeLoops[id] -- 453
			if e.track == track and e.source ~= nil then -- 453
				e.source.volume = e.volume * gain -- 455
			end -- 455
		end -- 455
		for id in pairs(self.sceneAmbSlots) do -- 458
			local e = self.sceneAmbSlots[id] -- 459
			if e.track == track and e.source ~= nil then -- 459
				e.source.volume = e.volume * gain -- 461
			end -- 461
		end -- 461
		if self.menuAmbSlot ~= nil and self.menuAmbSlot.track == track and self.menuAmbSlot.source ~= nil then -- 461
			self.menuAmbSlot.source.volume = self.menuAmbSlot.volume * gain -- 465
		end -- 465
	end -- 465
end -- 444
function AudioDirector.prototype.syncBgmBusGain(self) -- 470
	local gain = self:effectiveBgmGain() -- 471
	if self.bgmBus ~= nil then -- 471
		self.bgmBus.volume = gain -- 473
	end -- 473
	if self.bgmCurrent ~= nil then -- 473
		self:applyBgmSlotGain(self.bgmCurrent) -- 476
	end -- 476
	if self.bgmFading ~= nil then -- 476
		self:applyBgmSlotGain(self.bgmFading) -- 479
	end -- 479
end -- 470
function AudioDirector.prototype.syncAllBusGains(self) -- 483
	local i = 0 -- 484
	do -- 484
		i = 0 -- 485
		while i < #ALL_TRACKS do -- 485
			self:syncBusGain(ALL_TRACKS[i + 1]) -- 486
			i = i + 1 -- 485
		end -- 485
	end -- 485
	self:syncBgmBusGain() -- 488
end -- 483
function AudioDirector.prototype.applyBgmSlotGain(self, slot) -- 491
	if slot.source == nil then -- 491
		return -- 493
	end -- 493
	local cueVol = clamp01(slot.baseVolume * slot.currentFade) -- 495
	slot.source.volume = self.bgmBus ~= nil and cueVol or cueVol * self:effectiveBgmGain() -- 496
end -- 491
function AudioDirector.prototype.startBgmSlotSource(self, slot) -- 499
	if slot.path == "" or not Content:exist(slot.path) then -- 499
		return false -- 501
	end -- 501
	local src = safeCreateSource(slot.path, false, self.bgmBus) -- 503
	if src ~= nil then -- 503
		src.looping = slot.looping -- 505
		if slot.looping and slot.loopPoint > 0.01 then -- 505
			do -- 505
				pcall(function() -- 505
					src:setLoopPoint(slot.loopPoint) -- 508
				end) -- 508
			end -- 508
		end -- 508
		do -- 508
			pcall(function() -- 508
				src:setProtected(true) -- 514
			end) -- 514
		end -- 514
		slot.source = src -- 518
		self:applyBgmSlotGain(slot) -- 519
		if self.hostNode ~= nil then -- 519
			src:addTo(self.hostNode) -- 521
		end -- 521
		local ok = src:play() -- 523
		if ok then -- 523
			return true -- 525
		end -- 525
		src:removeFromParent(true) -- 527
		slot.source = nil -- 528
	end -- 528
	local h = safeAudioPlay(slot.path, slot.looping) -- 530
	if h > 0 then -- 530
		slot.handler = h -- 532
		return true -- 533
	end -- 533
	return false -- 535
end -- 499
function AudioDirector.prototype.disposeBgmSlot(self, slot, fadeSec) -- 538
	if fadeSec == nil then -- 538
		fadeSec = 0 -- 538
	end -- 538
	if slot == nil then -- 538
		return -- 540
	end -- 540
	if slot.source ~= nil then -- 540
		do -- 540
			pcall(function() -- 540
				slot.source:stop(fadeSec) -- 544
			end) -- 544
		end -- 544
		slot.source:removeFromParent(true) -- 548
		slot.source = nil -- 549
	end -- 549
	if slot.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 549
		Audio:stop(slot.handler) -- 552
		slot.handler = nil -- 553
	end -- 553
end -- 538
function AudioDirector.prototype.playBgm(self, id, path, opts) -- 562
	local vol = clamp01(opts and opts.volume or 0.85) -- 563
	local fadeIn = math.max(0, opts and opts.fadeIn or 1.4) -- 564
	local ____temp_6 = opts and opts.looping -- 565
	if ____temp_6 == nil then -- 565
		____temp_6 = true -- 565
	end -- 565
	local looping = ____temp_6 -- 565
	local loopPoint = math.max(0, opts and opts.loopPoint or 0) -- 566
	local restart = (opts and opts.restart) == true -- 567
	if not restart and self.bgmCurrent ~= nil and self.bgmCurrent.id == id and self.bgmCurrent.path == path then -- 567
		self.bgmCurrent.baseVolume = vol -- 570
		self:applyBgmSlotGain(self.bgmCurrent) -- 571
		return false -- 572
	end -- 572
	if self.bgmFading ~= nil then -- 572
		self:disposeBgmSlot(self.bgmFading, 0) -- 577
		self.bgmFading = nil -- 578
	end -- 578
	if self.bgmCurrent ~= nil then -- 578
		if fadeIn > 0.05 then -- 578
			self.bgmFading = self.bgmCurrent -- 582
		else -- 582
			self:disposeBgmSlot(self.bgmCurrent, opts and opts.fadeOut or 0) -- 584
		end -- 584
		self.bgmCurrent = nil -- 586
	end -- 586
	local nextSlot = { -- 589
		id = id, -- 590
		path = path, -- 591
		baseVolume = vol, -- 592
		currentFade = fadeIn > 0.05 and 0 or 1, -- 593
		looping = looping, -- 594
		loopPoint = loopPoint, -- 595
		source = nil, -- 596
		handler = nil -- 597
	} -- 597
	local playedBackend = self:startBgmSlotSource(nextSlot) -- 599
	self.bgmCurrent = nextSlot -- 600
	self.bgmFadeDuration = fadeIn -- 601
	self.bgmFadeTimer = 0 -- 602
	local ____self_bgmLog_13 = self.bgmLog -- 602
	____self_bgmLog_13[#____self_bgmLog_13 + 1] = { -- 604
		id = id, -- 604
		path = path, -- 604
		looping = looping, -- 604
		loopPoint = loopPoint, -- 604
		playedBackend = playedBackend -- 604
	} -- 604
	if #self.bgmLog > MAX_BGM_LOG then -- 604
		table.remove(self.bgmLog, 1) -- 606
	end -- 606
	return true -- 608
end -- 562
function AudioDirector.prototype.stopBgm(self, fadeSec) -- 611
	if fadeSec == nil then -- 611
		fadeSec = 1 -- 611
	end -- 611
	if self.bgmFading ~= nil then -- 611
		self:disposeBgmSlot(self.bgmFading, 0) -- 613
		self.bgmFading = nil -- 614
	end -- 614
	if self.bgmCurrent == nil then -- 614
		return -- 617
	end -- 617
	if fadeSec > 0.05 then -- 617
		self.bgmFading = self.bgmCurrent -- 620
		self.bgmCurrent = nil -- 621
		self.bgmFadeDuration = fadeSec -- 622
		self.bgmFadeTimer = 0 -- 623
	else -- 623
		self:disposeBgmSlot(self.bgmCurrent, 0) -- 625
		self.bgmCurrent = nil -- 626
		self.bgmFadeDuration = 0 -- 627
		self.bgmFadeTimer = 0 -- 628
	end -- 628
end -- 611
function AudioDirector.prototype.setBgmManualDuck(self, gain) -- 633
	self.bgmManualDuck = clamp01(gain) -- 634
end -- 633
function AudioDirector.prototype.triggerVoiceDuck(self, holdSec) -- 638
	if holdSec == nil then -- 638
		holdSec = 1.6 -- 638
	end -- 638
	if holdSec > self.bgmVoiceDuckHold then -- 638
		self.bgmVoiceDuckHold = holdSec -- 640
	end -- 640
end -- 638
function AudioDirector.prototype.getCurrentBgmId(self) -- 644
	return self.bgmCurrent ~= nil and self.bgmCurrent.id or "" -- 645
end -- 644
function AudioDirector.prototype.getBgmLog(self) -- 648
	return self.bgmLog -- 649
end -- 648
function AudioDirector.prototype.update(self, dt) -- 653
	local safeDt = math.min( -- 654
		0.1, -- 654
		math.max(0, dt) -- 654
	) -- 654
	self.clockSec = self.clockSec + safeDt -- 655
	if self.paused then -- 655
		return -- 657
	end -- 657
	if self.bgmFadeDuration > 0.01 and (self.bgmCurrent ~= nil or self.bgmFading ~= nil) then -- 657
		self.bgmFadeTimer = math.min(self.bgmFadeDuration, self.bgmFadeTimer + safeDt) -- 662
		local u = clamp01(self.bgmFadeTimer / self.bgmFadeDuration) -- 663
		local inGain = math.sin(u * math.pi * 0.5) -- 664
		local outGain = math.cos(u * math.pi * 0.5) -- 665
		if self.bgmCurrent ~= nil then -- 665
			self.bgmCurrent.currentFade = inGain -- 667
			self:applyBgmSlotGain(self.bgmCurrent) -- 668
		end -- 668
		if self.bgmFading ~= nil then -- 668
			self.bgmFading.currentFade = outGain -- 671
			self:applyBgmSlotGain(self.bgmFading) -- 672
			if u >= 0.999 then -- 672
				self:disposeBgmSlot(self.bgmFading, 0) -- 674
				self.bgmFading = nil -- 675
			end -- 675
		end -- 675
		if u >= 0.999 then -- 675
			self.bgmFadeDuration = 0 -- 679
		end -- 679
	end -- 679
	if self.bgmVoiceDuckHold > 0 then -- 679
		self.bgmVoiceDuckHold = math.max(0, self.bgmVoiceDuckHold - safeDt) -- 685
	end -- 685
	local voiceDuck = self.bgmVoiceDuckHold > 0 and 0.48 or 1 -- 687
	self.bgmTargetDuck = math.min(voiceDuck, self.bgmManualDuck) -- 688
	if math.abs(self.bgmTargetDuck - self.bgmDuckGain) > 0.002 then -- 688
		local speed = self.bgmTargetDuck < self.bgmDuckGain and 7.5 or 2.2 -- 690
		self.bgmDuckGain = self.bgmDuckGain + (self.bgmTargetDuck - self.bgmDuckGain) * math.min(1, safeDt * speed) -- 691
		self:syncBgmBusGain() -- 692
	end -- 692
end -- 653
function AudioDirector.prototype.playUi(self, cueId, path, volume, cooldownSec) -- 699
	if volume == nil then -- 699
		volume = 0.72 -- 699
	end -- 699
	if cooldownSec == nil then -- 699
		cooldownSec = 0.045 -- 699
	end -- 699
	local prevAt = self.uiCooldowns[cueId] or -99 -- 700
	if self.clockSec - prevAt < cooldownSec then -- 700
		return false -- 702
	end -- 702
	self.uiCooldowns[cueId] = self.clockSec -- 704
	return self:playFireAndForget( -- 705
		"sfx", -- 705
		path, -- 705
		volume, -- 705
		0, -- 705
		false -- 705
	) -- 705
end -- 699
function AudioDirector.prototype.playFoley(self, cueId, path, volume, pan, cooldownMs) -- 711
	if volume == nil then -- 711
		volume = 0.65 -- 714
	end -- 714
	if pan == nil then -- 714
		pan = 0 -- 715
	end -- 715
	if cooldownMs == nil then -- 715
		cooldownMs = 60 -- 716
	end -- 716
	if self.paused then -- 716
		return false -- 719
	end -- 719
	local prevAt = self.foleyCooldowns[cueId] or -99 -- 721
	if (self.clockSec - prevAt) * 1000 < cooldownMs then -- 721
		return false -- 723
	end -- 723
	self.foleyCooldowns[cueId] = self.clockSec -- 725
	self.jitterSeq = (self.jitterSeq + 1) % 7 -- 726
	local jitter = 0.94 + self.jitterSeq * 0.02 -- 727
	return self:playFireAndForget( -- 728
		"sfx", -- 728
		path, -- 728
		clamp01(volume * jitter), -- 728
		pan, -- 728
		false -- 728
	) -- 728
end -- 711
function AudioDirector.prototype.playFireAndForget(self, track, path, volume, pan, isProtected) -- 731
	if path == "" or not Content:exist(path) then -- 731
		return false -- 739
	end -- 739
	self:pruneStoppedSources() -- 741
	local cueVol = clamp01(volume) -- 742
	local bus = self.buses[track] -- 743
	local src = safeCreateSource(path, false, bus) -- 744
	if src ~= nil then -- 744
		src.volume = bus ~= nil and cueVol or cueVol * self:effectiveTrackGain(track) -- 746
		src.looping = false -- 747
		if math.abs(pan) > 0.01 then -- 747
			src.pan = clampPan(pan) -- 749
		end -- 749
		if isProtected then -- 749
			do -- 749
				pcall(function() -- 749
					src:setProtected(true) -- 753
				end) -- 753
			end -- 753
		end -- 753
		if self.hostNode ~= nil then -- 753
			src:addTo(self.hostNode) -- 759
		end -- 759
		if src:play() then -- 759
			local ____self_activeSources_14 = self.activeSources -- 759
			____self_activeSources_14[#____self_activeSources_14 + 1] = src -- 762
			return true -- 763
		end -- 763
		src:removeFromParent(true) -- 765
		return false -- 766
	end -- 766
	local h = safeAudioPlay(path, false) -- 768
	if h > 0 then -- 768
		local ____self_activeHandlers_15 = self.activeHandlers -- 768
		____self_activeHandlers_15[#____self_activeHandlers_15 + 1] = h -- 770
		return true -- 771
	end -- 771
	return false -- 773
end -- 731
function AudioDirector.prototype.setSceneAmbience(self, slotId, track, path, volume) -- 779
	local prev = self.sceneAmbSlots[slotId] -- 780
	local clampedVol = clamp01(volume) -- 781
	local bus = self.buses[track] -- 782
	local trackGain = self:effectiveTrackGain(track) -- 783
	if prev ~= nil and prev.path == path and prev.track == track then -- 783
		prev.volume = clampedVol -- 785
		if prev.source ~= nil then -- 785
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 787
		end -- 787
		return -- 789
	end -- 789
	if prev ~= nil then -- 789
		self:stopSceneAmbience(slotId, 0.25) -- 792
	end -- 792
	local source -- 794
	local handler -- 795
	if path ~= "" and Content:exist(path) then -- 795
		local created = safeCreateSource(path, false, bus) -- 797
		if created ~= nil then -- 797
			created.looping = true -- 799
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 800
			if self.hostNode ~= nil then -- 800
				created:addTo(self.hostNode) -- 802
			end -- 802
			if created:play() then -- 802
				source = created -- 805
			else -- 805
				created:removeFromParent(true) -- 807
			end -- 807
		else -- 807
			local h = safeAudioPlay(path, true) -- 810
			if h > 0 then -- 810
				handler = h -- 812
			end -- 812
		end -- 812
	end -- 812
	self.sceneAmbSlots[slotId] = { -- 816
		track = track, -- 816
		path = path, -- 816
		volume = clampedVol, -- 816
		source = source, -- 816
		handler = handler -- 816
	} -- 816
end -- 779
function AudioDirector.prototype.stopSceneAmbience(self, slotId, fadeTime) -- 819
	if fadeTime == nil then -- 819
		fadeTime = 0.2 -- 819
	end -- 819
	local entry = self.sceneAmbSlots[slotId] -- 820
	if entry == nil then -- 820
		return -- 822
	end -- 822
	if entry.source ~= nil then -- 822
		entry.source:stop(fadeTime) -- 825
		entry.source:removeFromParent(true) -- 826
	end -- 826
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 826
		Audio:stop(entry.handler) -- 829
	end -- 829
	__TS__Delete(self.sceneAmbSlots, slotId) -- 831
end -- 819
function AudioDirector.prototype.setMenuAmbience(self, path, volume) -- 835
	local clampedVol = clamp01(volume) -- 836
	local bus = self.buses.ambience -- 837
	local trackGain = self:effectiveTrackGain("ambience") -- 838
	if self.menuAmbSlot ~= nil and self.menuAmbSlot.path == path then -- 838
		self.menuAmbSlot.volume = clampedVol -- 840
		if self.menuAmbSlot.source ~= nil then -- 840
			self.menuAmbSlot.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 842
		end -- 842
		return -- 844
	end -- 844
	self:stopMenuAmbience(0.2) -- 846
	local source -- 847
	local handler -- 848
	if path ~= "" and Content:exist(path) then -- 848
		local created = safeCreateSource(path, false, bus) -- 850
		if created ~= nil then -- 850
			created.looping = true -- 852
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 853
			if self.hostNode ~= nil then -- 853
				created:addTo(self.hostNode) -- 855
			end -- 855
			if created:play() then -- 855
				source = created -- 858
			else -- 858
				created:removeFromParent(true) -- 860
			end -- 860
		else -- 860
			local h = safeAudioPlay(path, true) -- 863
			if h > 0 then -- 863
				handler = h -- 865
			end -- 865
		end -- 865
	end -- 865
	self.menuAmbSlot = { -- 869
		track = "ambience", -- 869
		path = path, -- 869
		volume = clampedVol, -- 869
		source = source, -- 869
		handler = handler -- 869
	} -- 869
end -- 835
function AudioDirector.prototype.stopMenuAmbience(self, fadeTime) -- 872
	if fadeTime == nil then -- 872
		fadeTime = 0.25 -- 872
	end -- 872
	local entry = self.menuAmbSlot -- 873
	if entry == nil then -- 873
		return -- 875
	end -- 875
	if entry.source ~= nil then -- 875
		entry.source:stop(fadeTime) -- 878
		entry.source:removeFromParent(true) -- 879
	end -- 879
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 879
		Audio:stop(entry.handler) -- 882
	end -- 882
	self.menuAmbSlot = nil -- 884
end -- 872
function AudioDirector.prototype.playOnce(self, dedupeKey, track, path, volume, cueId, tick, seq, opts) -- 893
	if volume == nil then -- 893
		volume = 1 -- 897
	end -- 897
	if cueId == nil then -- 897
		cueId = "" -- 898
	end -- 898
	if tick == nil then -- 898
		tick = 0 -- 899
	end -- 899
	if seq == nil then -- 899
		seq = -1 -- 900
	end -- 900
	if dedupeKey ~= "" and self.dedupeSet[dedupeKey] == true then -- 900
		return false -- 904
	end -- 904
	if dedupeKey ~= "" then -- 904
		self.dedupeSet[dedupeKey] = true -- 907
	end -- 907
	local cueVol = clamp01(volume) -- 910
	local trackGain = self:effectiveTrackGain(track) -- 911
	local effectiveVol = cueVol * trackGain -- 912
	local playedBackend = false -- 913
	if track == "voice" then -- 913
		self:triggerVoiceDuck(1.8) -- 916
	end -- 916
	if path ~= "" and Content:exist(path) then -- 916
		self:pruneStoppedSources() -- 920
		local bus = self.buses[track] -- 921
		local src = safeCreateSource(path, false, bus) -- 922
		if src ~= nil then -- 922
			src.volume = bus ~= nil and cueVol or effectiveVol -- 924
			src.looping = false -- 925
			if (opts and opts.pan) ~= nil and math.abs(opts.pan) > 0.01 then -- 925
				src.pan = clampPan(opts.pan) -- 927
			end -- 927
			if track == "voice" or (opts and opts.protected) == true then -- 927
				do -- 927
					pcall(function() -- 927
						src:setProtected(true) -- 931
					end) -- 931
				end -- 931
			end -- 931
			if self.hostNode ~= nil then -- 931
				src:addTo(self.hostNode) -- 937
			end -- 937
			playedBackend = src:play() -- 939
			if playedBackend then -- 939
				local ____self_activeSources_20 = self.activeSources -- 939
				____self_activeSources_20[#____self_activeSources_20 + 1] = src -- 941
			else -- 941
				src:removeFromParent(true) -- 943
			end -- 943
		else -- 943
			local handler = safeAudioPlay(path, false) -- 946
			if handler > 0 then -- 946
				local ____self_activeHandlers_21 = self.activeHandlers -- 946
				____self_activeHandlers_21[#____self_activeHandlers_21 + 1] = handler -- 948
				playedBackend = true -- 949
			end -- 949
		end -- 949
	end -- 949
	self:recordLog({ -- 954
		tick = tick, -- 955
		seq = seq, -- 956
		track = track, -- 957
		cueId = cueId ~= "" and cueId or (dedupeKey ~= "" and dedupeKey or path), -- 958
		dedupeKey = dedupeKey, -- 959
		path = path, -- 960
		volume = clamp01(volume), -- 961
		looped = false, -- 962
		playedBackend = playedBackend -- 963
	}) -- 963
	return true -- 965
end -- 893
function AudioDirector.prototype.playLoop(self, loopId, track, path, volume, tick) -- 969
	if volume == nil then -- 969
		volume = 1 -- 973
	end -- 973
	if tick == nil then -- 973
		tick = 0 -- 974
	end -- 974
	local prev = self.activeLoops[loopId] -- 976
	local clampedVol = clamp01(volume) -- 977
	local bus = self.buses[track] -- 978
	local trackGain = self:effectiveTrackGain(track) -- 979
	if prev ~= nil and prev.path == path and prev.track == track then -- 979
		prev.volume = clampedVol -- 981
		if prev.source ~= nil then -- 981
			prev.source.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 983
		end -- 983
		return false -- 985
	end -- 985
	if prev ~= nil then -- 985
		self:stopLoop(loopId, 0) -- 988
	end -- 988
	local source -- 991
	local handler -- 992
	local playedBackend = false -- 993
	if path ~= "" and Content:exist(path) then -- 993
		local created = safeCreateSource(path, false, bus) -- 995
		if created ~= nil then -- 995
			created.looping = true -- 997
			created.volume = bus ~= nil and clampedVol or clampedVol * trackGain -- 998
			if self.hostNode ~= nil then -- 998
				created:addTo(self.hostNode) -- 1000
			end -- 1000
			playedBackend = created:play() -- 1002
			if playedBackend then -- 1002
				source = created -- 1004
			else -- 1004
				created:removeFromParent(true) -- 1006
			end -- 1006
		end -- 1006
		if not playedBackend then -- 1006
			local h = safeAudioPlay(path, true) -- 1010
			if h > 0 then -- 1010
				handler = h -- 1012
				playedBackend = true -- 1013
			end -- 1013
		end -- 1013
	end -- 1013
	self.activeLoops[loopId] = { -- 1018
		track = track, -- 1019
		path = path, -- 1020
		volume = clampedVol, -- 1021
		source = source, -- 1022
		handler = handler -- 1023
	} -- 1023
	self:recordLog({ -- 1025
		tick = tick, -- 1026
		seq = -1, -- 1027
		track = track, -- 1028
		cueId = "loop:" .. loopId, -- 1029
		dedupeKey = "loop:" .. loopId, -- 1030
		path = path, -- 1031
		volume = clampedVol, -- 1032
		looped = true, -- 1033
		playedBackend = playedBackend -- 1034
	}) -- 1034
	return true -- 1036
end -- 969
function AudioDirector.prototype.stopLoop(self, loopId, fadeTime) -- 1039
	if fadeTime == nil then -- 1039
		fadeTime = 0 -- 1039
	end -- 1039
	local entry = self.activeLoops[loopId] -- 1040
	if entry == nil then -- 1040
		return -- 1042
	end -- 1042
	if entry.source ~= nil then -- 1042
		entry.source:stop(fadeTime) -- 1045
		entry.source:removeFromParent(true) -- 1046
	end -- 1046
	if entry.handler ~= nil and type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 1046
		Audio:stop(entry.handler) -- 1049
	end -- 1049
	__TS__Delete(self.activeLoops, loopId) -- 1051
end -- 1039
function AudioDirector.prototype.setPaused(self, paused) -- 1055
	if self.paused == paused then -- 1055
		return -- 1057
	end -- 1057
	self.paused = paused -- 1059
	if type(Audio) ~= "nil" and type(Audio.setPauseAllCurrent) == "function" then -- 1059
		do -- 1059
			pcall(function() -- 1059
				Audio:setPauseAllCurrent(paused) -- 1062
			end) -- 1062
		end -- 1062
	end -- 1062
end -- 1055
function AudioDirector.prototype.stopRoomTransient(self) -- 1070
	local i = 0 -- 1071
	do -- 1071
		i = 0 -- 1072
		while i < #self.activeSources do -- 1072
			local src = self.activeSources[i + 1] -- 1073
			if src.playing then -- 1073
				src:stop(0) -- 1075
			end -- 1075
			src:removeFromParent(true) -- 1077
			i = i + 1 -- 1072
		end -- 1072
	end -- 1072
	self.activeSources = {} -- 1079
	if type(Audio) ~= "nil" and type(Audio.stop) == "function" then -- 1079
		do -- 1079
			i = 0 -- 1082
			while i < #self.activeHandlers do -- 1082
				Audio:stop(self.activeHandlers[i + 1]) -- 1083
				i = i + 1 -- 1082
			end -- 1082
		end -- 1082
	end -- 1082
	self.activeHandlers = {} -- 1086
	local loopIds = {} -- 1088
	for id in pairs(self.activeLoops) do -- 1089
		loopIds[#loopIds + 1] = id -- 1090
	end -- 1090
	do -- 1090
		i = 0 -- 1092
		while i < #loopIds do -- 1092
			self:stopLoop(loopIds[i + 1], 0) -- 1093
			i = i + 1 -- 1092
		end -- 1092
	end -- 1092
	local ambIds = {} -- 1096
	for id in pairs(self.sceneAmbSlots) do -- 1097
		ambIds[#ambIds + 1] = id -- 1098
	end -- 1098
	do -- 1098
		i = 0 -- 1100
		while i < #ambIds do -- 1100
			self:stopSceneAmbience(ambIds[i + 1], 0) -- 1101
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
	self.dedupeSet = {} -- 1104
	if self.paused then -- 1104
		self:setPaused(false) -- 1106
	end -- 1106
	self:setWorldPlaySpeed(1) -- 1108
	self:setSpaceMuffled(false) -- 1109
	self.bgmManualDuck = 1 -- 1110
	self.bgmVoiceDuckHold = 0 -- 1111
end -- 1070
function AudioDirector.prototype.ingestEvents(self, ev, p) -- 1119
	if self.paused or #ev.rawEvents == 0 then -- 1119
		return -- 1121
	end -- 1121
	local i = 0 -- 1123
	do -- 1123
		i = 0 -- 1124
		while i < #ev.rawEvents do -- 1124
			self:dispatchSingleEvent(ev.rawEvents[i + 1], ev.roomSessionId, ev.checkpoint, p) -- 1125
			i = i + 1 -- 1124
		end -- 1124
	end -- 1124
end -- 1119
function AudioDirector.prototype.panFromData(self, e, fallbackX) -- 1129
	local x = type(e.data.x) == "number" and e.data.x or (type(e.data.enemyX) == "number" and e.data.enemyX or (type(e.data.impactX) == "number" and e.data.impactX or fallbackX)) -- 1130
	return x ~= nil and x >= 0 and self:panForWorldX(x) or 0 -- 1135
end -- 1129
function AudioDirector.prototype.dispatchSingleEvent(self, e, roomSessionId, checkpoint, p) -- 1138
	local key = (((((((("r" .. tostring(roomSessionId)) .. ":cp") .. tostring(checkpoint)) .. ":t") .. tostring(e.tick)) .. ":s") .. tostring(e.seq)) .. ":") .. e.name -- 1144
	local name = e.name -- 1145
	if name == "knock" then -- 1145
		local roomTag = type(e.data.room) == "string" and e.data.room or p.room.key -- 1148
		local countNum = type(e.data.count) == "number" and e.data.count or 1 -- 1149
		local vol = countNum >= 2 and 0.94 or 0.86 -- 1150
		self:playOnce( -- 1151
			key, -- 1152
			"sfx", -- 1153
			"assets/audio/sfx/knock.wav", -- 1154
			vol, -- 1155
			(("knock:" .. roomTag) .. ":") .. tostring(countNum), -- 1156
			e.tick, -- 1157
			e.seq, -- 1158
			{pan = self:panFromData(e, p.player.x)} -- 1159
		) -- 1159
		return -- 1161
	end -- 1161
	if name == "shotResolved" then -- 1161
		local hit = e.data.hit == true -- 1164
		local weapon = p.equippedWeapon -- 1165
		local shotPath = "assets/audio/combat/shot.wav" -- 1166
		if weapon == "guide_lantern_gun" then -- 1166
			shotPath = resolveExisting("assets/audio/combat/shot_lantern_gun.wav", shotPath) -- 1168
		elseif weapon == "echo_gun" then -- 1168
			shotPath = resolveExisting("assets/audio/combat/shot_echo_gun.wav", shotPath) -- 1170
		elseif isArtifactWeaponId(weapon) then -- 1170
			shotPath = resolveExisting("assets/audio/combat/shot_time_shuttler.wav", shotPath) -- 1172
		end -- 1172
		self:playOnce( -- 1174
			key, -- 1175
			"sfx", -- 1176
			shotPath, -- 1177
			0.86, -- 1178
			hit and "shot:hit" or "shot:fire", -- 1179
			e.tick, -- 1180
			e.seq, -- 1181
			{pan = self:panForWorldX(p.player.x) * 0.4} -- 1182
		) -- 1182
		if hit then -- 1182
			local enemyPan = self:panFromData(e) -- 1185
			if e.data.shield == true then -- 1185
				local shieldPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", "assets/audio/combat/cover_block.wav") -- 1187
				self:playOnce( -- 1188
					key .. ":shield", -- 1188
					"sfx", -- 1188
					shieldPath, -- 1188
					0.84, -- 1188
					"cover:shield", -- 1188
					e.tick, -- 1188
					e.seq, -- 1188
					{pan = enemyPan} -- 1188
				) -- 1188
			else -- 1188
				local downPath = "assets/audio/combat/enemy_down.wav" -- 1190
				if Content:exist(downPath) then -- 1190
					self:playOnce( -- 1192
						key .. ":down", -- 1192
						"sfx", -- 1192
						downPath, -- 1192
						0.78, -- 1192
						"combat:enemy_down", -- 1192
						e.tick, -- 1192
						e.seq, -- 1192
						{pan = enemyPan} -- 1192
					) -- 1192
				end -- 1192
			end -- 1192
		end -- 1192
		return -- 1196
	end -- 1196
	if name == "trialShot" then -- 1196
		self:playOnce( -- 1199
			key, -- 1199
			"sfx", -- 1199
			"assets/audio/combat/shot.wav", -- 1199
			0.85, -- 1199
			"trial:shot", -- 1199
			e.tick, -- 1199
			e.seq -- 1199
		) -- 1199
		return -- 1200
	end -- 1200
	if name == "coverBlocked" then -- 1200
		local ent = type(e.data.entity) == "string" and e.data.entity or "" -- 1203
		local blockPath = "assets/audio/combat/cover_block.wav" -- 1204
		if (string.find(ent, "盾", nil, true) or 0) - 1 >= 0 then -- 1204
			blockPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", blockPath) -- 1206
		elseif (string.find(ent, "木", nil, true) or 0) - 1 >= 0 or (string.find(ent, "柜", nil, true) or 0) - 1 >= 0 or (string.find(ent, "帘", nil, true) or 0) - 1 >= 0 or (string.find(ent, "板", nil, true) or 0) - 1 >= 0 then -- 1206
			blockPath = resolveExisting("assets/audio/combat/cover_block_wood.wav", blockPath) -- 1208
		elseif ent ~= "" then -- 1208
			blockPath = resolveExisting("assets/audio/combat/cover_block_stone.wav", blockPath) -- 1210
		end -- 1210
		local pan = self:panFromData(e) -- 1212
		self:playOnce( -- 1213
			key, -- 1213
			"sfx", -- 1213
			blockPath, -- 1213
			0.85, -- 1213
			"cover:blocked", -- 1213
			e.tick, -- 1213
			e.seq, -- 1213
			{pan = pan} -- 1213
		) -- 1213
		if type(e.data.enemyX) == "number" and Content:exist("assets/audio/combat/shot_enemy.wav") then -- 1213
			self:playOnce( -- 1215
				key .. ":eshot", -- 1215
				"sfx", -- 1215
				"assets/audio/combat/shot_enemy.wav", -- 1215
				0.56, -- 1215
				"combat:shot_enemy", -- 1215
				e.tick, -- 1215
				e.seq, -- 1215
				{pan = pan} -- 1215
			) -- 1215
		end -- 1215
		return -- 1217
	end -- 1217
	if name == "actorHit" or name == "gateFailed" then -- 1217
		local pan = self:panFromData(e) -- 1220
		self:playOnce( -- 1221
			key, -- 1221
			"sfx", -- 1221
			"assets/audio/combat/actor_hit.wav", -- 1221
			0.9, -- 1221
			"actor:hit", -- 1221
			e.tick, -- 1221
			e.seq, -- 1221
			{pan = pan * 0.4} -- 1221
		) -- 1221
		if name == "actorHit" and type(e.data.enemyX) == "number" and Content:exist("assets/audio/combat/shot_enemy.wav") then -- 1221
			self:playOnce( -- 1223
				key .. ":eshot", -- 1223
				"sfx", -- 1223
				"assets/audio/combat/shot_enemy.wav", -- 1223
				0.62, -- 1223
				"combat:shot_enemy", -- 1223
				e.tick, -- 1223
				e.seq, -- 1223
				{pan = pan} -- 1223
			) -- 1223
		end -- 1223
		if name == "gateFailed" and Content:exist("assets/audio/combat/campaign_failed.wav") then -- 1223
			self:playOnce( -- 1226
				key .. ":fail", -- 1226
				"sfx", -- 1226
				"assets/audio/combat/campaign_failed.wav", -- 1226
				0.86, -- 1226
				"combat:gate_failed", -- 1226
				e.tick, -- 1226
				e.seq -- 1226
			) -- 1226
		end -- 1226
		return -- 1228
	end -- 1228
	if name == "campaignFailed" then -- 1228
		self:playOnce( -- 1231
			key, -- 1231
			"sfx", -- 1231
			resolveExisting("assets/audio/combat/campaign_failed.wav", "assets/audio/combat/actor_hit.wav"), -- 1231
			0.88, -- 1231
			"combat:campaign_failed", -- 1231
			e.tick, -- 1231
			e.seq -- 1231
		) -- 1231
		return -- 1232
	end -- 1232
	if name == "gateRestart" then -- 1232
		self:playOnce( -- 1235
			key, -- 1235
			"sfx", -- 1235
			"assets/audio/combat/gate_winch_start.wav", -- 1235
			0.82, -- 1235
			"gate:winch_restart", -- 1235
			e.tick, -- 1235
			e.seq -- 1235
		) -- 1235
		return -- 1236
	end -- 1236
	if name == "bottleThrown" then -- 1236
		self:playOnce( -- 1239
			key, -- 1239
			"sfx", -- 1239
			"assets/audio/foley/bottle_throw.wav", -- 1239
			0.78, -- 1239
			"bottle:thrown", -- 1239
			e.tick, -- 1239
			e.seq, -- 1239
			{pan = self:panForWorldX(p.player.x)} -- 1239
		) -- 1239
		return -- 1240
	end -- 1240
	if name == "bottleLanded" then -- 1240
		local surface = "brick" -- 1243
		local landX = type(e.data.x) == "number" and e.data.x or p.bottleLandX -- 1244
		if type(e.data.surface) == "string" then -- 1244
			surface = e.data.surface -- 1246
		elseif p.room.key == "village" then -- 1246
			if math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS then -- 1246
				surface = "iron" -- 1249
			elseif p.room.softX ~= nil and math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS then -- 1249
				surface = "soft" -- 1251
			end -- 1251
		end -- 1251
		local path = surface == "iron" and "assets/audio/child/bottle_iron.wav" or (surface == "soft" and "assets/audio/child/bottle_soft.wav" or "assets/audio/child/bottle_brick.wav") -- 1254
		self:playOnce( -- 1257
			key, -- 1257
			"sfx", -- 1257
			path, -- 1257
			0.9, -- 1257
			"bottle:" .. surface, -- 1257
			e.tick, -- 1257
			e.seq, -- 1257
			{pan = self:panForWorldX(landX)} -- 1257
		) -- 1257
		return -- 1258
	end -- 1258
	if name == "cartDocked" then -- 1258
		self:playOnce( -- 1261
			key, -- 1261
			"sfx", -- 1261
			"assets/audio/child/cart_dock.wav", -- 1261
			0.88, -- 1261
			"cart:docked", -- 1261
			e.tick, -- 1261
			e.seq, -- 1261
			{pan = self:panFromData(e, p.cartAxle)} -- 1261
		) -- 1261
		return -- 1262
	end -- 1262
	if name == "fearChanged" then -- 1262
		local fear = type(e.data.fear) == "number" and e.data.fear or 0 -- 1265
		if fear >= 3 then -- 1265
			self:playOnce( -- 1267
				key, -- 1267
				"sfx", -- 1267
				"assets/audio/foley/fear_freeze.wav", -- 1267
				0.84, -- 1267
				"escort:fear_freeze", -- 1267
				e.tick, -- 1267
				e.seq -- 1267
			) -- 1267
		elseif e.data.exposed == true then -- 1267
			self:playOnce( -- 1269
				key, -- 1269
				"sfx", -- 1269
				"assets/audio/foley/fear_gasp.wav", -- 1269
				0.78, -- 1269
				"escort:fear_gasp", -- 1269
				e.tick, -- 1269
				e.seq -- 1269
			) -- 1269
		end -- 1269
		return -- 1271
	end -- 1271
	if name == "pickup" then -- 1271
		local kind = type(e.data.kind) == "string" and e.data.kind or "gear" -- 1274
		local pickPath = "assets/audio/interact/pickup_gear.wav" -- 1275
		if kind == "bell" then -- 1275
			pickPath = "assets/audio/interact/pickup_bell.wav" -- 1277
		elseif kind == "wood" or kind == "scrap" or kind == "wedge" then -- 1277
			pickPath = "assets/audio/interact/pickup_wood.wav" -- 1279
		end -- 1279
		self:playOnce( -- 1281
			key, -- 1281
			"sfx", -- 1281
			pickPath, -- 1281
			0.8, -- 1281
			"interact:pickup:" .. kind, -- 1281
			e.tick, -- 1281
			e.seq, -- 1281
			{pan = self:panFromData(e)} -- 1281
		) -- 1281
		return -- 1282
	end -- 1282
	if name == "pickupRejected" then -- 1282
		self:playOnce( -- 1285
			key, -- 1285
			"sfx", -- 1285
			"assets/audio/interact/pickup_rejected.wav", -- 1285
			0.68, -- 1285
			"interact:pickup_rejected", -- 1285
			e.tick, -- 1285
			e.seq -- 1285
		) -- 1285
		return -- 1286
	end -- 1286
	if name == "craftStart" then -- 1286
		self:playOnce( -- 1289
			key, -- 1289
			"sfx", -- 1289
			"assets/audio/interact/wedge_craft_loop.wav", -- 1289
			0.72, -- 1289
			"craft:start", -- 1289
			e.tick, -- 1289
			e.seq -- 1289
		) -- 1289
		return -- 1290
	end -- 1290
	if name == "craftDone" or name == "benchCraft" then -- 1290
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or (type(e.data.weapon) == "string" and ":" .. e.data.weapon or "") -- 1293
		self:playOnce( -- 1296
			key, -- 1296
			"sfx", -- 1296
			"assets/audio/combat/craft_done.wav", -- 1296
			0.88, -- 1296
			"craft:done" .. recipeTag, -- 1296
			e.tick, -- 1296
			e.seq -- 1296
		) -- 1296
		return -- 1297
	end -- 1297
	if name == "benchOpen" then -- 1297
		self:playOnce( -- 1300
			key, -- 1300
			"sfx", -- 1300
			"assets/audio/interact/bench_open.wav", -- 1300
			0.76, -- 1300
			"bench:open", -- 1300
			e.tick, -- 1300
			e.seq -- 1300
		) -- 1300
		return -- 1301
	end -- 1301
	if name == "benchClose" then -- 1301
		self:playOnce( -- 1304
			key, -- 1304
			"sfx", -- 1304
			"assets/audio/interact/bench_close.wav", -- 1304
			0.7, -- 1304
			"bench:close", -- 1304
			e.tick, -- 1304
			e.seq -- 1304
		) -- 1304
		return -- 1305
	end -- 1305
	if name == "benchEquip" then -- 1305
		self:playOnce( -- 1308
			key, -- 1308
			"sfx", -- 1308
			"assets/audio/interact/bench_equip.wav", -- 1308
			0.8, -- 1308
			"bench:equip", -- 1308
			e.tick, -- 1308
			e.seq -- 1308
		) -- 1308
		return -- 1309
	end -- 1309
	if name == "benchRejected" then -- 1309
		local recipeTag = type(e.data.recipeId) == "string" and ":" .. e.data.recipeId or "" -- 1312
		self:playOnce( -- 1313
			key, -- 1313
			"sfx", -- 1313
			"assets/audio/combat/craft_insufficient.wav", -- 1313
			0.76, -- 1313
			"craft:insufficient" .. recipeTag, -- 1313
			e.tick, -- 1313
			e.seq -- 1313
		) -- 1313
		return -- 1314
	end -- 1314
	if name == "propBroken" then -- 1314
		local phase = type(e.data.phase) == "string" and e.data.phase or "broken" -- 1317
		local propPath = phase == "crack" and "assets/audio/combat/prop_crack.wav" or "assets/audio/combat/prop_break.wav" -- 1318
		self:playOnce( -- 1319
			key, -- 1319
			"sfx", -- 1319
			propPath, -- 1319
			0.84, -- 1319
			"combat:prop_" .. phase, -- 1319
			e.tick, -- 1319
			e.seq, -- 1319
			{pan = self:panFromData(e)} -- 1319
		) -- 1319
		return -- 1320
	end -- 1320
	if name == "interactUsed" then -- 1320
		local kind = type(e.data.kind) == "string" and e.data.kind or "" -- 1323
		local path = "" -- 1324
		if kind == "wedge" then -- 1324
			path = "assets/audio/interact/wedge_place.wav" -- 1325
		elseif kind == "ammo" then -- 1325
			path = "assets/audio/interact/ammo_quickload.wav" -- 1326
		elseif kind == "shield" then -- 1326
			path = "assets/audio/interact/shield_deploy.wav" -- 1327
		elseif kind == "pass" then -- 1327
			path = "assets/audio/interact/pass_signal.wav" -- 1328
		elseif kind == "open_board" then -- 1328
			path = "assets/audio/interact/window_board_drop.wav" -- 1329
		elseif kind == "lower_curtain" then -- 1329
			path = "assets/audio/interact/curtain_lower.wav" -- 1330
		elseif kind == "raise_latch" then -- 1330
			path = "assets/audio/interact/latch_raise.wav" -- 1331
		end -- 1331
		if path ~= "" then -- 1331
			self:playOnce( -- 1333
				key, -- 1333
				"sfx", -- 1333
				path, -- 1333
				0.86, -- 1333
				"interact:" .. kind, -- 1333
				e.tick, -- 1333
				e.seq, -- 1333
				{pan = self:panFromData(e)} -- 1333
			) -- 1333
		end -- 1333
		return -- 1335
	end -- 1335
	if name == "roomChange" then -- 1335
		self:playOnce( -- 1338
			key, -- 1338
			"sfx", -- 1338
			"assets/audio/ui/chapter_banner.wav", -- 1338
			0.62, -- 1338
			"ui:room_change", -- 1338
			e.tick, -- 1338
			e.seq -- 1338
		) -- 1338
		return -- 1339
	end -- 1339
	if name == "objectiveDone" or name == "segmentDone" then -- 1339
		self:playOnce( -- 1342
			key, -- 1342
			"sfx", -- 1342
			"assets/audio/ui/segment_clear.wav", -- 1342
			0.74, -- 1342
			"ui:" .. name, -- 1342
			e.tick, -- 1342
			e.seq -- 1342
		) -- 1342
		return -- 1343
	end -- 1343
	if name == "handHeld" then -- 1343
		self:playOnce( -- 1346
			key, -- 1346
			"sfx", -- 1346
			"assets/audio/gate/reunion_hold.wav", -- 1346
			0.9, -- 1346
			"gate:hand_held", -- 1346
			e.tick, -- 1346
			e.seq -- 1346
		) -- 1346
		return -- 1347
	end -- 1347
	if name == "handRelease" then -- 1347
		self:playOnce( -- 1350
			key, -- 1350
			"sfx", -- 1350
			"assets/audio/gate/reunion_release.wav", -- 1350
			0.7, -- 1350
			"gate:hand_release", -- 1350
			e.tick, -- 1350
			e.seq -- 1350
		) -- 1350
		return -- 1351
	end -- 1351
	if name == "carryStart" then -- 1351
		self:playOnce( -- 1354
			key, -- 1354
			"sfx", -- 1354
			"assets/audio/combat/carry_start.wav", -- 1354
			0.82, -- 1354
			"combat:carry_start", -- 1354
			e.tick, -- 1354
			e.seq -- 1354
		) -- 1354
		return -- 1355
	end -- 1355
	if name == "reloadOpen" then -- 1355
		self:playOnce( -- 1358
			key, -- 1358
			"sfx", -- 1358
			"assets/audio/combat/reload_open.wav", -- 1358
			0.8, -- 1358
			"reload:open", -- 1358
			e.tick, -- 1358
			e.seq -- 1358
		) -- 1358
		return -- 1359
	end -- 1359
	if name == "reloadNode" then -- 1359
		local nodeTag = type(e.data.node) == "number" and "" .. tostring(e.data.node) or "0" -- 1362
		local plen = type(e.data.pathLength) == "number" and math.max( -- 1363
			1, -- 1363
			math.min( -- 1363
				6, -- 1363
				math.floor(e.data.pathLength) -- 1363
			) -- 1363
		) or 1 -- 1363
		local nodePath = resolveExisting( -- 1364
			("assets/audio/combat/reload_node_" .. tostring(plen)) .. ".wav", -- 1364
			"assets/audio/combat/reload_node.wav" -- 1364
		) -- 1364
		self:playOnce( -- 1365
			key, -- 1365
			"sfx", -- 1365
			nodePath, -- 1365
			0.78, -- 1365
			"reload:node:" .. nodeTag, -- 1365
			e.tick, -- 1365
			e.seq -- 1365
		) -- 1365
		return -- 1366
	end -- 1366
	if name == "reloadInvalid" then -- 1366
		self:playOnce( -- 1369
			key, -- 1369
			"sfx", -- 1369
			"assets/audio/combat/reload_invalid.wav", -- 1369
			0.72, -- 1369
			"reload:invalid", -- 1369
			e.tick, -- 1369
			e.seq -- 1369
		) -- 1369
		return -- 1370
	end -- 1370
	if name == "reloadSolved" then -- 1370
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 1373
		self:playOnce( -- 1374
			key, -- 1374
			"sfx", -- 1374
			"assets/audio/combat/reload_solved.wav", -- 1374
			0.9, -- 1374
			"reload:solved:" .. eff, -- 1374
			e.tick, -- 1374
			e.seq -- 1374
		) -- 1374
		return -- 1375
	end -- 1375
	if name == "reloadTimeout" then -- 1375
		self:playOnce( -- 1378
			key, -- 1378
			"sfx", -- 1378
			"assets/audio/combat/reload_timeout.wav", -- 1378
			0.78, -- 1378
			"reload:timeout", -- 1378
			e.tick, -- 1378
			e.seq -- 1378
		) -- 1378
		return -- 1379
	end -- 1379
	if name == "reloadApplied" then -- 1379
		local eff = type(e.data.effect) == "string" and e.data.effect or "push" -- 1382
		local fxPath = eff == "echo" and "assets/audio/combat/reload_fx_echo.wav" or (eff == "light" and "assets/audio/combat/reload_fx_light.wav" or "assets/audio/combat/reload_fx_push.wav") -- 1383
		self:playOnce( -- 1386
			key, -- 1386
			"sfx", -- 1386
			fxPath, -- 1386
			0.84, -- 1386
			"reload:applied:" .. eff, -- 1386
			e.tick, -- 1386
			e.seq, -- 1386
			{pan = self:panFromData(e)} -- 1386
		) -- 1386
		return -- 1387
	end -- 1387
	if name == "artifactFound" then -- 1387
		self:playOnce( -- 1390
			key, -- 1390
			"sfx", -- 1390
			"assets/audio/museum/artifact_pickup.wav", -- 1390
			0.88, -- 1390
			"museum:artifact_found", -- 1390
			e.tick, -- 1390
			e.seq -- 1390
		) -- 1390
		return -- 1391
	end -- 1391
	if name == "museumStep" then -- 1391
		local step = type(e.data.step) == "string" and e.data.step or "" -- 1394
		local cnt = type(e.data.count) == "number" and e.data.count or 1 -- 1395
		if step == "cabinet" then -- 1395
			self:playOnce( -- 1397
				key, -- 1397
				"sfx", -- 1397
				"assets/audio/museum/weapon_holster.wav", -- 1397
				0.78, -- 1397
				"museum:step:cabinet", -- 1397
				e.tick, -- 1397
				e.seq -- 1397
			) -- 1397
		elseif step == "hall" then -- 1397
			self:playOnce( -- 1399
				key, -- 1399
				"sfx", -- 1399
				"assets/audio/museum/child_steps_echo.wav", -- 1399
				0.76, -- 1399
				"museum:step:hall", -- 1399
				e.tick, -- 1399
				e.seq -- 1399
			) -- 1399
		elseif step == "lamp" then -- 1399
			self:playOnce( -- 1401
				key, -- 1401
				"sfx", -- 1401
				"assets/audio/museum/lamp_turn.wav", -- 1401
				0.82, -- 1401
				"museum:step:lamp", -- 1401
				e.tick, -- 1401
				e.seq -- 1401
			) -- 1401
		elseif step == "knock" then -- 1401
			local knockPath = cnt >= 2 and "assets/audio/museum/knock_cabinet_second.wav" or "assets/audio/museum/knock_hall_first.wav" -- 1403
			self:playOnce( -- 1406
				key, -- 1406
				"sfx", -- 1406
				knockPath, -- 1406
				0.9, -- 1406
				"museum:step:knock:" .. tostring(cnt), -- 1406
				e.tick, -- 1406
				e.seq -- 1406
			) -- 1406
		end -- 1406
		return -- 1408
	end -- 1408
	if name == "museumDone" then -- 1408
		self:playOnce( -- 1411
			key, -- 1411
			"voice", -- 1411
			"assets/audio/museum/line_dawn.wav", -- 1411
			0.88, -- 1411
			"museum:done", -- 1411
			e.tick, -- 1411
			e.seq -- 1411
		) -- 1411
		return -- 1412
	end -- 1412
	if name == "storyBeat" then -- 1412
		local beat = type(e.data.beat) == "string" and e.data.beat or "" -- 1415
		local pan = self:panFromData(e) -- 1416
		if beat == "red_cart" then -- 1416
			self:playOnce( -- 1418
				key, -- 1418
				"sfx", -- 1418
				"assets/audio/child/cart_dock.wav", -- 1418
				0.84, -- 1418
				"story:red_cart", -- 1418
				e.tick, -- 1418
				e.seq, -- 1418
				{pan = pan} -- 1418
			) -- 1418
		elseif beat == "red_cart_memory" then -- 1418
			self:playOnce( -- 1420
				key, -- 1420
				"sfx", -- 1420
				"assets/audio/child/sewing_memory.wav", -- 1420
				0.86, -- 1420
				"story:red_cart_memory", -- 1420
				e.tick, -- 1420
				e.seq -- 1420
			) -- 1420
		elseif beat == "footstep_near" then -- 1420
			local pNear = resolveExisting("assets/audio/foley/step_scavenger_1.wav", "assets/audio/museum/hall_footstep.wav") -- 1422
			self:playOnce( -- 1423
				key, -- 1423
				"sfx", -- 1423
				pNear, -- 1423
				0.76, -- 1423
				"story:footstep_near", -- 1423
				e.tick, -- 1423
				e.seq, -- 1423
				{pan = pan} -- 1423
			) -- 1423
		elseif beat == "footstep_far" then -- 1423
			local pFar = resolveExisting("assets/audio/foley/step_scavenger_2.wav", "assets/audio/museum/hall_footstep.wav") -- 1425
			self:playOnce( -- 1426
				key, -- 1426
				"sfx", -- 1426
				pFar, -- 1426
				0.36, -- 1426
				"story:footstep_far", -- 1426
				e.tick, -- 1426
				e.seq, -- 1426
				{pan = pan} -- 1426
			) -- 1426
		elseif beat == "ditch" or beat == "path_burrow" then -- 1426
			self:playOnce( -- 1428
				key, -- 1428
				"sfx", -- 1428
				"assets/audio/child/twig_snap.wav", -- 1428
				0.76, -- 1428
				"story:" .. beat, -- 1428
				e.tick, -- 1428
				e.seq, -- 1428
				{pan = pan} -- 1428
			) -- 1428
		elseif beat == "path_ditch" then -- 1428
			self:playOnce( -- 1430
				key, -- 1430
				"sfx", -- 1430
				"assets/audio/child/dog_step.wav", -- 1430
				0.78, -- 1430
				"story:path_ditch", -- 1430
				e.tick, -- 1430
				e.seq, -- 1430
				{pan = pan} -- 1430
			) -- 1430
		elseif beat == "water_lantern" then -- 1430
			self:playOnce( -- 1432
				key, -- 1432
				"sfx", -- 1432
				"assets/audio/tower/lamp_move.wav", -- 1432
				0.74, -- 1432
				"story:water_lantern", -- 1432
				e.tick, -- 1432
				e.seq -- 1432
			) -- 1432
		elseif beat == "tower_door" then -- 1432
			self:playOnce( -- 1434
				key, -- 1434
				"sfx", -- 1434
				"assets/audio/tower/door_open.wav", -- 1434
				0.78, -- 1434
				"story:tower_door", -- 1434
				e.tick, -- 1434
				e.seq -- 1434
			) -- 1434
		elseif beat == "tower_threshold" then -- 1434
			local pStep = resolveExisting("assets/audio/foley/step_child_stone_1.wav", "assets/audio/museum/hall_footstep.wav") -- 1436
			self:playOnce( -- 1437
				key, -- 1437
				"sfx", -- 1437
				pStep, -- 1437
				0.68, -- 1437
				"story:tower_threshold", -- 1437
				e.tick, -- 1437
				e.seq -- 1437
			) -- 1437
		elseif beat == "tower_handover" then -- 1437
			self:playOnce( -- 1439
				key, -- 1439
				"sfx", -- 1439
				"assets/audio/tower/needle_case_place.wav", -- 1439
				0.86, -- 1439
				"story:tower_handover", -- 1439
				e.tick, -- 1439
				e.seq -- 1439
			) -- 1439
		elseif beat == "talent_picked" then -- 1439
			local pTal = resolveExisting("assets/audio/ui/talent_pick.wav", "assets/audio/combat/reload_solved.wav") -- 1441
			self:playOnce( -- 1442
				key, -- 1442
				"sfx", -- 1442
				pTal, -- 1442
				0.82, -- 1442
				"story:talent_picked", -- 1442
				e.tick, -- 1442
				e.seq -- 1442
			) -- 1442
		end -- 1442
	end -- 1442
end -- 1138
function AudioDirector.prototype.hasPlayed(self, dedupeKey) -- 1447
	return self.dedupeSet[dedupeKey] == true -- 1448
end -- 1447
function AudioDirector.prototype.getPlayLog(self) -- 1451
	return self.playLog -- 1452
end -- 1451
function AudioDirector.prototype.getLastEntry(self) -- 1455
	if #self.playLog == 0 then -- 1455
		return nil -- 1457
	end -- 1457
	return self.playLog[#self.playLog] -- 1459
end -- 1455
function AudioDirector.prototype.clearPlayLog(self) -- 1462
	self.playLog = {} -- 1463
end -- 1462
function AudioDirector.prototype.getTrackList(self) -- 1466
	return ALL_TRACKS -- 1467
end -- 1466
function AudioDirector.prototype.pruneStoppedSources(self) -- 1470
	local w = 0 -- 1471
	local i = 0 -- 1472
	do -- 1472
		i = 0 -- 1473
		while i < #self.activeSources do -- 1473
			local src = self.activeSources[i + 1] -- 1474
			if src.playing then -- 1474
				self.activeSources[w + 1] = src -- 1476
				w = w + 1 -- 1477
			else -- 1477
				src:removeFromParent(true) -- 1479
			end -- 1479
			i = i + 1 -- 1473
		end -- 1473
	end -- 1473
	__TS__ArraySetLength(self.activeSources, w) -- 1473
end -- 1470
function AudioDirector.prototype.recordLog(self, entry) -- 1485
	local ____self_playLog_22 = self.playLog -- 1485
	____self_playLog_22[#____self_playLog_22 + 1] = entry -- 1486
	if #self.playLog > MAX_PLAY_LOG then -- 1486
		table.remove(self.playLog, 1) -- 1488
	end -- 1488
end -- 1485
return ____exports -- 1485