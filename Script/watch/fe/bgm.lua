-- [ts]: bgm.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local BGM_ROOT = "assets/audio/bgm/" -- 19
local AMB_ROOT = "assets/audio/ambience/" -- 20
local FOL_ROOT = "assets/audio/foley/" -- 21
local CMB_ROOT = "assets/audio/combat/" -- 22
local UI_ROOT = "assets/audio/ui/" -- 23
local BGM_CATALOG = { -- 34
	splash = { -- 35
		id = "splash", -- 35
		path = BGM_ROOT .. "splash_brand.ogg", -- 35
		volume = 0.86, -- 35
		looping = false, -- 35
		loopPoint = 0, -- 35
		fadeIn = 0.05 -- 35
	}, -- 35
	title = { -- 36
		id = "title", -- 36
		path = BGM_ROOT .. "title_westward_watch.ogg", -- 36
		volume = 0.8, -- 36
		looping = true, -- 36
		loopPoint = 8, -- 36
		fadeIn = 1.4 -- 36
	}, -- 36
	prologue = { -- 37
		id = "prologue", -- 37
		path = BGM_ROOT .. "prologue_ember_night.ogg", -- 37
		volume = 0.72, -- 37
		looping = true, -- 37
		loopPoint = 0, -- 37
		fadeIn = 1.8 -- 37
	}, -- 37
	street = { -- 38
		id = "street", -- 38
		path = BGM_ROOT .. "street_alley_tension.ogg", -- 38
		volume = 0.76, -- 38
		looping = true, -- 38
		loopPoint = 0, -- 38
		fadeIn = 1.5 -- 38
	}, -- 38
	checkpoint = { -- 39
		id = "checkpoint", -- 39
		path = BGM_ROOT .. "checkpoint_granary.ogg", -- 39
		volume = 0.74, -- 39
		looping = true, -- 39
		loopPoint = 0, -- 39
		fadeIn = 1.6 -- 39
	}, -- 39
	gate_siege = { -- 40
		id = "gate_siege", -- 40
		path = BGM_ROOT .. "gate_siege_45s.ogg", -- 40
		volume = 0.84, -- 40
		looping = true, -- 40
		loopPoint = 48, -- 40
		fadeIn = 0.8 -- 40
	}, -- 40
	gate_count = { -- 41
		id = "gate_count", -- 41
		path = BGM_ROOT .. "gate_count_drone.ogg", -- 41
		volume = 0.48, -- 41
		looping = true, -- 41
		loopPoint = 0, -- 41
		fadeIn = 1.8 -- 41
	}, -- 41
	reunion = { -- 42
		id = "reunion", -- 42
		path = BGM_ROOT .. "reunion_hand_in_hand.ogg", -- 42
		volume = 0.78, -- 42
		looping = true, -- 42
		loopPoint = 0, -- 42
		fadeIn = 1.6 -- 42
	}, -- 42
	escort_combat = { -- 43
		id = "escort_combat", -- 43
		path = BGM_ROOT .. "escort_combat.ogg", -- 43
		volume = 0.8, -- 43
		looping = true, -- 43
		loopPoint = 4, -- 43
		fadeIn = 1.2 -- 43
	}, -- 43
	escort_bench = { -- 44
		id = "escort_bench", -- 44
		path = BGM_ROOT .. "escort_craft_bench.ogg", -- 44
		volume = 0.72, -- 44
		looping = true, -- 44
		loopPoint = 0, -- 44
		fadeIn = 1.8 -- 44
	}, -- 44
	child_lone = { -- 45
		id = "child_lone", -- 45
		path = BGM_ROOT .. "child_lone_journey.ogg", -- 45
		volume = 0.68, -- 45
		looping = true, -- 45
		loopPoint = 0, -- 45
		fadeIn = 2 -- 45
	}, -- 45
	forest_stalk = { -- 46
		id = "forest_stalk", -- 46
		path = BGM_ROOT .. "forest_stalk_and_creek.ogg", -- 46
		volume = 0.7, -- 46
		looping = true, -- 46
		loopPoint = 0, -- 46
		fadeIn = 1.8 -- 46
	}, -- 46
	creek_dawn = { -- 47
		id = "creek_dawn", -- 47
		path = BGM_ROOT .. "creek_dawn_reflection.ogg", -- 47
		volume = 0.76, -- 47
		looping = true, -- 47
		loopPoint = 0, -- 47
		fadeIn = 2.2 -- 47
	}, -- 47
	ending_f03 = { -- 48
		id = "ending_f03", -- 48
		path = BGM_ROOT .. "ending_f03_lamp.ogg", -- 48
		volume = 0.84, -- 48
		looping = true, -- 48
		loopPoint = 32, -- 48
		fadeIn = 0.35 -- 48
	}, -- 48
	ending_m03 = { -- 49
		id = "ending_m03", -- 49
		path = BGM_ROOT .. "ending_m03_reunion.ogg", -- 49
		volume = 0.84, -- 49
		looping = true, -- 49
		loopPoint = 32, -- 49
		fadeIn = 0.35 -- 49
	}, -- 49
	museum = { -- 50
		id = "museum", -- 50
		path = BGM_ROOT .. "museum_dawn_peace.ogg", -- 50
		volume = 0.8, -- 50
		looping = true, -- 50
		loopPoint = 6, -- 50
		fadeIn = 2 -- 50
	} -- 50
} -- 50
local SOLDIER_STONE_STEPS = {FOL_ROOT .. "step_soldier_stone_1.wav", FOL_ROOT .. "step_soldier_stone_2.wav", FOL_ROOT .. "step_soldier_stone_3.wav"} -- 53
local CHILD_STONE_STEPS = {FOL_ROOT .. "step_child_stone_1.wav", FOL_ROOT .. "step_child_stone_2.wav", FOL_ROOT .. "step_child_stone_3.wav"} -- 58
local CHILD_MOSS_STEPS = {FOL_ROOT .. "step_child_moss_1.wav", FOL_ROOT .. "step_child_moss_2.wav"} -- 63
local CHILD_WATER_STEPS = {FOL_ROOT .. "step_child_water_1.wav", FOL_ROOT .. "step_child_water_2.wav"} -- 67
local function clamp01(v) -- 72
	return math.max( -- 73
		0, -- 73
		math.min(1, v) -- 73
	) -- 73
end -- 72
____exports.SoundscapeDirector = __TS__Class() -- 76
local SoundscapeDirector = ____exports.SoundscapeDirector -- 76
SoundscapeDirector.name = "SoundscapeDirector" -- 76
function SoundscapeDirector.prototype.____constructor(self) -- 76
	self.boundRoomKey = "" -- 77
	self.stepAccum = 0 -- 78
	self.partnerStepAccum = 0 -- 79
	self.stepIdx = 0 -- 80
	self.partnerStepIdx = 0 -- 81
	self.prevOnGround = true -- 82
	self.prevVy = 0 -- 83
	self.prevRollT = 0 -- 84
	self.prevCrouch = false -- 85
	self.prevHasBottle = false -- 86
	self.prevCartAxle = 0 -- 87
	self.prevPhase = "" -- 88
	self.prevWeapon = "" -- 89
	self.prevOfferCount = 0 -- 90
	self.enemyWarnPrev = {} -- 91
	self.gateTarpPlayed = false -- 92
	self.lastSplashActive = false -- 93
end -- 76
function SoundscapeDirector.prototype.resetForRoom(self, p) -- 95
	self.boundRoomKey = p.room.key -- 96
	self.stepAccum = 0 -- 97
	self.partnerStepAccum = 0 -- 98
	self.prevOnGround = p.player.onGround -- 99
	self.prevVy = p.player.vy -- 100
	self.prevRollT = p.player.rollT -- 101
	self.prevCrouch = p.player.crouch -- 102
	self.prevHasBottle = p.hasBottle -- 103
	self.prevCartAxle = p.cartAxle -- 104
	self.prevPhase = p.phase -- 105
	self.prevWeapon = p.equippedWeapon -- 106
	self.prevOfferCount = #p:getStoryTalentOffers() -- 107
	self.enemyWarnPrev = {} -- 108
	self.gateTarpPlayed = false -- 109
end -- 95
function SoundscapeDirector.prototype.updateMenu(self, screen, audio) -- 113
	if screen == "splash" then -- 114
		local spec = BGM_CATALOG.splash -- 115
		audio:stopMenuAmbience(0.2) -- 116
		audio:playBgm(spec.id, spec.path, { -- 117
			volume = spec.volume, -- 118
			looping = false, -- 119
			loopPoint = 0, -- 120
			fadeIn = spec.fadeIn, -- 121
			restart = not self.lastSplashActive -- 122
		}) -- 122
		self.lastSplashActive = true -- 124
		return -- 125
	end -- 125
	self.lastSplashActive = false -- 127
	local titleSpec = BGM_CATALOG.title -- 128
	audio:setBgmManualDuck(1) -- 129
	audio:playBgm(titleSpec.id, titleSpec.path, {volume = titleSpec.volume, looping = titleSpec.looping, loopPoint = titleSpec.loopPoint, fadeIn = titleSpec.fadeIn}) -- 130
	audio:setMenuAmbience(AMB_ROOT .. "title_coastal_night_loop.ogg", 0.34) -- 136
end -- 113
function SoundscapeDirector.prototype.updatePlay(self, dt, p, view, audio) -- 140
	audio:stopMenuAmbience(0.4) -- 141
	self.lastSplashActive = false -- 142
	if self.boundRoomKey ~= p.room.key then -- 144
		self:resetForRoom(p) -- 145
	end -- 145
	if p.paused then -- 148
		return -- 149
	end -- 149
	self:syncPlayBgm(p, view, audio) -- 153
	self:syncPlayAmbience(dt, p, view, audio) -- 156
	local inArch = p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 8 and p.player.x <= p.room.arch.x1 + 8 and p.player.y <= p.room.arch.y + p.room.arch.h -- 159
	local inCabinet = p.room.key == "prologue" and (p.phase == "prologue-wait" or p.phase == "prologue-hide") -- 163
	local inDitch = p.room.key == "village" and p.player.crouch and p.player.x >= p.ox + 540 -- 164
	audio:setSpaceMuffled(inArch or inCabinet or inDitch) -- 165
	self:syncFoley(dt, p, view, audio) -- 168
end -- 140
function SoundscapeDirector.prototype.updateTrial(self, dt, p, audio, offerCount) -- 172
	audio:stopMenuAmbience(0.3) -- 173
	self.lastSplashActive = false -- 174
	if self.boundRoomKey ~= p.room.key then -- 175
		self:resetForRoom(p) -- 176
		self.prevOfferCount = offerCount -- 177
	end -- 177
	if p.paused then -- 179
		return -- 180
	end -- 180
	local spec = BGM_CATALOG.escort_combat -- 182
	audio:setBgmManualDuck(1) -- 183
	audio:playBgm(spec.id, spec.path, {volume = spec.volume, looping = spec.looping, loopPoint = spec.loopPoint, fadeIn = spec.fadeIn}) -- 184
	audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "escort_mountain_night_loop.ogg", 0.36) -- 190
	if offerCount > 0 and self.prevOfferCount == 0 then -- 192
		audio:playUi("ui:talent_appear", UI_ROOT .. "talent_appear.wav", 0.72, 0.2) -- 193
	end -- 193
	self.prevOfferCount = offerCount -- 195
	self:syncLocomotionAndCombatFoley(dt, p, audio, false) -- 197
end -- 172
function SoundscapeDirector.prototype.syncPlayBgm(self, p, view, audio) -- 200
	local key = p.room.key -- 201
	local phase = p.phase -- 202
	local desired -- 203
	local manualDuck = 1 -- 204
	if view.visualMode == "museum" or key == "museum" then -- 206
		local mp = view.archive.museumPhase -- 207
		if mp == "well_reflect" or mp == "return_cabinet" then -- 208
			desired = nil -- 209
		else -- 209
			desired = BGM_CATALOG.museum -- 211
		end -- 211
	elseif key == "prologue" then -- 213
		if phase == "prologue-wake" or phase == "prologue-shadow" or phase == "prologue-escape" or phase == "prologue-hide" then -- 214
			desired = nil -- 215
		else -- 215
			desired = BGM_CATALOG.prologue -- 217
		end -- 217
	elseif key == "street" or key == "s1-crossroad" or key == "s2-drygoods" or key == "s3-archway" then -- 219
		desired = BGM_CATALOG.street -- 220
	elseif key == "checkpoint" or key == "c1-yard" or key == "c2-granary" then -- 221
		desired = BGM_CATALOG.checkpoint -- 222
	elseif key == "gate" then -- 223
		if phase == "gate-hold" then -- 224
			desired = BGM_CATALOG.gate_siege -- 225
		elseif phase == "gate-idle" then -- 226
			desired = BGM_CATALOG.checkpoint -- 227
			manualDuck = 0.65 -- 228
		elseif phase == "gate-send" or phase == "gate-farewell" then -- 229
			desired = nil -- 230
		elseif phase == "gate-count" then -- 231
			desired = BGM_CATALOG.gate_count -- 232
			if view.countNumber >= 18 then -- 233
				manualDuck = 0 -- 234
			elseif view.countNumber >= 15 then -- 235
				manualDuck = 0.35 -- 236
			end -- 236
		elseif phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed then -- 238
			desired = BGM_CATALOG.reunion -- 239
		elseif phase == "gate-walk" then -- 240
			desired = view.storyRoute == "soldier" and BGM_CATALOG.reunion or BGM_CATALOG.child_lone -- 241
		else -- 241
			desired = BGM_CATALOG.gate_count -- 243
			manualDuck = 0.35 -- 244
		end -- 244
	elseif key == "gatepath" then -- 246
		desired = BGM_CATALOG.reunion -- 247
	elseif key == "escort3" then -- 248
		desired = BGM_CATALOG.escort_bench -- 249
	elseif key == "escort1" or key == "escort2" or key == "escort4" or key == "escort5" then -- 250
		desired = BGM_CATALOG.escort_combat -- 251
	elseif key == "outside" or key == "village" then -- 252
		desired = BGM_CATALOG.child_lone -- 253
	elseif key == "forest" then -- 254
		desired = p.player.x >= p.ox + 1140 and BGM_CATALOG.creek_dawn or BGM_CATALOG.forest_stalk -- 255
	elseif key == "tower" then -- 256
		local endingActive = phase == "tower-knock" or phase == "tower-given" or phase == "tower-end" -- 257
		if endingActive then -- 258
			desired = view.storyRoute == "soldier" and BGM_CATALOG.ending_m03 or BGM_CATALOG.ending_f03 -- 259
		else -- 259
			desired = BGM_CATALOG.creek_dawn -- 261
			manualDuck = 0.72 -- 262
		end -- 262
	end -- 262
	audio:setBgmManualDuck(manualDuck) -- 266
	if desired == nil then -- 267
		if audio:getCurrentBgmId() ~= "" then -- 268
			audio:stopBgm(1.2) -- 269
		end -- 269
		return -- 271
	end -- 271
	local ____temp_0 -- 273
	if desired.id == "ending_f03" or desired.id == "ending_m03" then -- 273
		____temp_0 = self.prevPhase ~= "tower-knock" and self.prevPhase ~= "tower-given" and self.prevPhase ~= "tower-end" -- 274
	else -- 274
		____temp_0 = desired.id == "gate_siege" and self.prevPhase ~= "gate-hold" -- 275
	end -- 275
	local forceRestart = ____temp_0 -- 273
	audio:playBgm(desired.id, desired.path, { -- 277
		volume = desired.volume, -- 278
		looping = desired.looping, -- 279
		loopPoint = desired.loopPoint, -- 280
		fadeIn = desired.fadeIn, -- 281
		restart = forceRestart -- 282
	}) -- 282
end -- 200
function SoundscapeDirector.prototype.syncPlayAmbience(self, dt, p, view, audio) -- 286
	local key = p.room.key -- 287
	local phase = p.phase -- 288
	if key == "prologue" and phase ~= "prologue-wake" and view.visualMode ~= "museum" then -- 291
		audio:setSceneAmbience("scene_main_amb", "ambience", "assets/audio/prologue/night_distant_fire.wav", 0.24) -- 292
	elseif key == "street" or key == "s1-crossroad" or key == "s2-drygoods" or key == "s3-archway" then -- 293
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "street_fire_ember_loop.ogg", 0.34) -- 294
	elseif key == "checkpoint" or key == "c1-yard" or key == "c2-granary" then -- 295
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "checkpoint_wind_chains_loop.ogg", 0.36) -- 296
	elseif key == "gate" and (phase == "gate-idle" or phase == "gate-hold" or phase == "gate-send") then -- 297
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "gate_siege_ambience_loop.ogg", phase == "gate-hold" and 0.42 or 0.28) -- 298
	elseif key == "gatepath" or key == "escort1" or key == "escort2" or key == "escort4" or key == "escort5" then -- 299
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "escort_mountain_night_loop.ogg", 0.34) -- 300
	elseif key == "escort3" then -- 301
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "escort_bench_lantern_loop.ogg", 0.38) -- 302
	else -- 302
		audio:stopSceneAmbience("scene_main_amb", 0.3) -- 304
	end -- 304
	if key == "gate" and phase == "gate-hold" then -- 308
		if self.prevPhase ~= "gate-hold" then -- 309
			audio:playFoley( -- 310
				"gate:winch_start", -- 310
				CMB_ROOT .. "gate_winch_start.wav", -- 310
				0.8, -- 310
				-0.25, -- 310
				250 -- 310
			) -- 310
			self.gateTarpPlayed = false -- 311
		end -- 311
		local progress = clamp01(p.gateTick / 2700) -- 313
		audio:setSceneAmbience("scene_winch_chain", "ambience", AMB_ROOT .. "gate_winch_chain_loop.ogg", 0.26 + progress * 0.16) -- 314
		if not self.gateTarpPlayed and p.gateTick >= 720 then -- 315
			self.gateTarpPlayed = true -- 316
			audio:playFoley( -- 317
				"gate:tarp_fall", -- 317
				CMB_ROOT .. "gate_tarp_fall.wav", -- 317
				0.72, -- 317
				0.18, -- 317
				500 -- 317
			) -- 317
		end -- 317
	else -- 317
		if key == "gate" and self.prevPhase == "gate-hold" and phase == "gate-send" then -- 320
			audio:playFoley( -- 321
				"gate:winch_lock", -- 321
				CMB_ROOT .. "gate_winch_lock.wav", -- 321
				0.88, -- 321
				-0.1, -- 321
				250 -- 321
			) -- 321
		end -- 321
		audio:stopSceneAmbience("scene_winch_chain", 0.25) -- 323
	end -- 323
	local nearCulvert = p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 40 and p.player.x <= p.room.arch.x1 + 40 or key == "village" and p.player.x >= p.ox + 520 or key == "forest" and p.player.x >= p.ox + 830 and p.player.x <= p.ox + 1230 -- 327
	if nearCulvert and view.visualMode ~= "museum" then -- 330
		audio:setSceneAmbience("scene_culvert_drip", "water", AMB_ROOT .. "culvert_drip_echo_loop.ogg", 0.3) -- 331
	else -- 331
		audio:stopSceneAmbience("scene_culvert_drip", 0.35) -- 333
	end -- 333
	if key ~= "outside" and p.room.cart.bodyW > 0 and dt > 0.0001 then -- 337
		local speed = math.abs(p.cartAxle - self.prevCartAxle) / dt -- 338
		if speed > 4 then -- 339
			local vol = math.min(0.46, 0.18 + speed / 64 * 0.28) -- 340
			audio:setSceneAmbience("scene_cart_wheel", "ambience", "assets/audio/child/cart_wheel_loop.wav", vol) -- 341
		else -- 341
			audio:stopSceneAmbience("scene_cart_wheel", 0.12) -- 343
		end -- 343
	else -- 343
		audio:stopSceneAmbience("scene_cart_wheel", 0.12) -- 346
	end -- 346
	self.prevCartAxle = p.cartAxle -- 348
end -- 286
function SoundscapeDirector.prototype.syncFoley(self, dt, p, view, audio) -- 351
	local key = p.room.key -- 352
	local inCutscene = view.visualMode == "museum" or key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-give") or key == "gate" and (p.phase == "gate-farewell" or p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or key == "tower" and (p.phase == "tower-knock" or p.phase == "tower-given" or p.phase == "tower-end") -- 353
	local offerCount = #p:getStoryTalentOffers() -- 359
	if offerCount > 0 and self.prevOfferCount == 0 then -- 360
		audio:playUi("ui:talent_appear", UI_ROOT .. "talent_appear.wav", 0.72, 0.2) -- 361
	end -- 361
	self.prevOfferCount = offerCount -- 363
	if not p.craftBench.active and self.prevWeapon ~= "" and p.equippedWeapon ~= self.prevWeapon then -- 366
		audio:playFoley( -- 367
			"weapon:switch", -- 367
			CMB_ROOT .. "weapon_switch_artifact.wav", -- 367
			0.78, -- 367
			0, -- 367
			140 -- 367
		) -- 367
	end -- 367
	self.prevWeapon = p.equippedWeapon -- 369
	if key == "village" and p.hasBottle and not self.prevHasBottle then -- 372
		audio:playFoley( -- 373
			"village:bottle_pickup", -- 373
			FOL_ROOT .. "bottle_pickup.wav", -- 373
			0.76, -- 373
			audio:panForWorldX(p.player.x), -- 373
			180 -- 373
		) -- 373
	end -- 373
	self.prevHasBottle = p.hasBottle -- 375
	self:syncLocomotionAndCombatFoley(dt, p, audio, inCutscene) -- 377
	self.prevPhase = p.phase -- 378
end -- 351
function SoundscapeDirector.prototype.syncLocomotionAndCombatFoley(self, dt, p, audio, suppressLocomotion) -- 381
	local a = p.player -- 382
	local pan = audio:panForWorldX(a.x) -- 383
	if not suppressLocomotion and dt > 0 then -- 385
		if a.rollT > 0 and self.prevRollT <= 0 then -- 387
			audio:playFoley( -- 388
				"foley:roll", -- 388
				FOL_ROOT .. "soldier_roll.wav", -- 388
				0.74, -- 388
				pan, -- 388
				220 -- 388
			) -- 388
		end -- 388
		if not a.onGround and self.prevOnGround and a.vy > 80 then -- 392
			local jPath = p.childMode and FOL_ROOT .. "jump_child.wav" or FOL_ROOT .. "jump_soldier.wav" -- 393
			audio:playFoley( -- 394
				"foley:jump", -- 394
				jPath, -- 394
				0.56, -- 394
				pan, -- 394
				160 -- 394
			) -- 394
		elseif a.onGround and not self.prevOnGround and self.prevVy < -60 then -- 395
			local lPath = p.childMode and FOL_ROOT .. "land_child.wav" or FOL_ROOT .. "land_soldier.wav" -- 396
			local impactVol = clamp01(0.36 + math.min( -- 397
				1, -- 397
				math.abs(self.prevVy) / 420 -- 397
			) * 0.42) -- 397
			audio:playFoley( -- 398
				"foley:land", -- 398
				lPath, -- 398
				impactVol, -- 398
				pan, -- 398
				120 -- 398
			) -- 398
		end -- 398
		if a.crouch and not self.prevCrouch and a.onGround then -- 402
			audio:playFoley( -- 403
				"foley:crouch", -- 403
				FOL_ROOT .. "crouch_rustle.wav", -- 403
				0.34, -- 403
				pan, -- 403
				180 -- 403
			) -- 403
		end -- 403
		local speedX = math.abs(a.vx) -- 407
		if a.onGround and a.rollT <= 0 and speedX > 12 then -- 408
			self.stepAccum = self.stepAccum + speedX * dt -- 409
			local stride = p.childMode and (a.crouch and 26 or 34) or 48 -- 410
			if self.stepAccum >= stride then -- 411
				self.stepAccum = self.stepAccum - stride -- 412
				self.stepIdx = self.stepIdx + 1 -- 413
				local stepInfo = self:pickPlayerFootstep(p, self.stepIdx) -- 414
				audio:playFoley( -- 415
					"foley:step", -- 415
					stepInfo.path, -- 415
					stepInfo.vol, -- 415
					pan, -- 415
					140 -- 415
				) -- 415
			end -- 415
		elseif speedX <= 4 then -- 417
			self.stepAccum = math.min(self.stepAccum, 16) -- 418
		end -- 418
		if p.room.key == "gatepath" and not p.childMode and p.partner.alive and math.abs(p.partner.vx) > 8 then -- 422
			self.partnerStepAccum = self.partnerStepAccum + math.abs(p.partner.vx) * dt -- 423
			if self.partnerStepAccum >= 32 then -- 424
				self.partnerStepAccum = self.partnerStepAccum - 32 -- 425
				self.partnerStepIdx = self.partnerStepIdx + 1 -- 426
				local cPath = CHILD_STONE_STEPS[self.partnerStepIdx % #CHILD_STONE_STEPS + 1] -- 427
				audio:playFoley( -- 428
					"foley:partner_step", -- 428
					cPath, -- 428
					0.44, -- 428
					audio:panForWorldX(p.partner.x), -- 428
					140 -- 428
				) -- 428
			end -- 428
		end -- 428
	end -- 428
	local i = 0 -- 434
	do -- 434
		i = 0 -- 435
		while i < #p.enemies do -- 435
			local en = p.enemies[i + 1] -- 436
			local warnNow = en.alive and en.warnT > 0 -- 437
			local warnWas = self.enemyWarnPrev[i] == true -- 438
			if warnNow and not warnWas then -- 439
				audio:playFoley( -- 440
					"combat:enemy_warn:" .. tostring(i), -- 440
					CMB_ROOT .. "enemy_warn.wav", -- 440
					0.68, -- 440
					audio:panForWorldX(en.x), -- 440
					300 -- 440
				) -- 440
			end -- 440
			self.enemyWarnPrev[i] = warnNow -- 442
			i = i + 1 -- 435
		end -- 435
	end -- 435
	self.prevOnGround = a.onGround -- 445
	self.prevVy = a.vy -- 446
	self.prevRollT = a.rollT -- 447
	self.prevCrouch = a.crouch -- 448
end -- 381
function SoundscapeDirector.prototype.pickPlayerFootstep(self, p, idx) -- 451
	if not p.childMode then -- 452
		return {path = SOLDIER_STONE_STEPS[idx % #SOLDIER_STONE_STEPS + 1], vol = p.player.crouch and 0.34 or 0.54} -- 453
	end -- 453
	local key = p.room.key -- 458
	local slowFactor = p.player.crouch and 0.52 or (math.abs(p.player.vx) <= 95 and 0.68 or 1) -- 459
	if key == "forest" then -- 460
		if p.player.x >= p.ox + 1310 then -- 461
			return {path = CHILD_WATER_STEPS[idx % #CHILD_WATER_STEPS + 1], vol = 0.46 * slowFactor} -- 462
		end -- 462
		return {path = CHILD_MOSS_STEPS[idx % #CHILD_MOSS_STEPS + 1], vol = 0.36 * slowFactor} -- 464
	end -- 464
	if key == "village" and p.player.x >= p.ox + 540 then -- 466
		return {path = CHILD_WATER_STEPS[idx % #CHILD_WATER_STEPS + 1], vol = 0.42 * slowFactor} -- 467
	end -- 467
	return {path = CHILD_STONE_STEPS[idx % #CHILD_STONE_STEPS + 1], vol = 0.48 * slowFactor} -- 469
end -- 451
return ____exports -- 451
