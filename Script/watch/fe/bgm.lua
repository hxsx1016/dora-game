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
function SoundscapeDirector.prototype.syncPlayBgm(self, p, view, audio) -- 171
	local key = p.room.key -- 172
	local phase = p.phase -- 173
	local desired -- 174
	local manualDuck = 1 -- 175
	if view.visualMode == "museum" or key == "museum" then -- 177
		local mp = view.archive.museumPhase -- 178
		if mp == "well_reflect" or mp == "return_cabinet" then -- 179
			desired = nil -- 180
		else -- 180
			desired = BGM_CATALOG.museum -- 182
		end -- 182
	elseif key == "prologue" then -- 184
		if phase == "prologue-wake" or phase == "prologue-shadow" or phase == "prologue-escape" or phase == "prologue-hide" then -- 185
			desired = nil -- 186
		else -- 186
			desired = BGM_CATALOG.prologue -- 188
		end -- 188
	elseif key == "street" or key == "s1-crossroad" or key == "s2-drygoods" or key == "s3-archway" then -- 190
		desired = BGM_CATALOG.street -- 191
	elseif key == "checkpoint" or key == "c1-yard" or key == "c2-granary" then -- 192
		desired = BGM_CATALOG.checkpoint -- 193
	elseif key == "gate" then -- 194
		if phase == "gate-hold" then -- 195
			desired = BGM_CATALOG.gate_siege -- 196
		elseif phase == "gate-idle" then -- 197
			desired = BGM_CATALOG.checkpoint -- 198
			manualDuck = 0.65 -- 199
		elseif phase == "gate-send" then -- 200
			desired = nil -- 201
		elseif phase == "gate-count" then -- 202
			desired = BGM_CATALOG.gate_count -- 203
			if view.countNumber >= 18 then -- 204
				manualDuck = 0 -- 205
			elseif view.countNumber >= 15 then -- 206
				manualDuck = 0.35 -- 207
			end -- 207
		elseif phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed then -- 209
			desired = BGM_CATALOG.reunion -- 210
		elseif phase == "gate-walk" then -- 211
			desired = view.storyRoute == "soldier" and BGM_CATALOG.reunion or BGM_CATALOG.child_lone -- 212
		else -- 212
			desired = BGM_CATALOG.gate_count -- 214
			manualDuck = 0.35 -- 215
		end -- 215
	elseif key == "gatepath" then -- 217
		desired = BGM_CATALOG.reunion -- 218
	elseif key == "escort3" then -- 219
		desired = BGM_CATALOG.escort_bench -- 220
	elseif key == "escort1" or key == "escort2" or key == "escort4" or key == "escort5" then -- 221
		desired = BGM_CATALOG.escort_combat -- 222
	elseif key == "outside" or key == "village" then -- 223
		desired = BGM_CATALOG.child_lone -- 224
	elseif key == "forest" then -- 225
		desired = p.player.x >= p.ox + 1140 and BGM_CATALOG.creek_dawn or BGM_CATALOG.forest_stalk -- 226
	elseif key == "tower" then -- 227
		local endingActive = phase == "tower-knock" or phase == "tower-given" or phase == "tower-end" -- 228
		if endingActive then -- 229
			desired = view.storyRoute == "soldier" and BGM_CATALOG.ending_m03 or BGM_CATALOG.ending_f03 -- 230
		else -- 230
			desired = BGM_CATALOG.creek_dawn -- 232
			manualDuck = 0.72 -- 233
		end -- 233
	end -- 233
	audio:setBgmManualDuck(manualDuck) -- 237
	if desired == nil then -- 238
		if audio:getCurrentBgmId() ~= "" then -- 239
			audio:stopBgm(1.2) -- 240
		end -- 240
		return -- 242
	end -- 242
	local ____temp_0 -- 244
	if desired.id == "ending_f03" or desired.id == "ending_m03" then -- 244
		____temp_0 = self.prevPhase ~= "tower-knock" and self.prevPhase ~= "tower-given" and self.prevPhase ~= "tower-end" -- 245
	else -- 245
		____temp_0 = desired.id == "gate_siege" and self.prevPhase ~= "gate-hold" -- 246
	end -- 246
	local forceRestart = ____temp_0 -- 244
	audio:playBgm(desired.id, desired.path, { -- 248
		volume = desired.volume, -- 249
		looping = desired.looping, -- 250
		loopPoint = desired.loopPoint, -- 251
		fadeIn = desired.fadeIn, -- 252
		restart = forceRestart -- 253
	}) -- 253
end -- 171
function SoundscapeDirector.prototype.syncPlayAmbience(self, dt, p, view, audio) -- 257
	local key = p.room.key -- 258
	local phase = p.phase -- 259
	if key == "prologue" and phase ~= "prologue-wake" and view.visualMode ~= "museum" then -- 262
		audio:setSceneAmbience("scene_main_amb", "ambience", "assets/audio/prologue/night_distant_fire.wav", 0.24) -- 263
	elseif key == "street" or key == "s1-crossroad" or key == "s2-drygoods" or key == "s3-archway" then -- 264
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "street_fire_ember_loop.ogg", 0.34) -- 265
	elseif key == "checkpoint" or key == "c1-yard" or key == "c2-granary" then -- 266
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "checkpoint_wind_chains_loop.ogg", 0.36) -- 267
	elseif key == "gate" and (phase == "gate-idle" or phase == "gate-hold" or phase == "gate-send") then -- 268
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "gate_siege_ambience_loop.ogg", phase == "gate-hold" and 0.42 or 0.28) -- 269
	elseif key == "gatepath" or key == "escort1" or key == "escort2" or key == "escort4" or key == "escort5" then -- 270
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "escort_mountain_night_loop.ogg", 0.34) -- 271
	elseif key == "escort3" then -- 272
		audio:setSceneAmbience("scene_main_amb", "ambience", AMB_ROOT .. "escort_bench_lantern_loop.ogg", 0.38) -- 273
	else -- 273
		audio:stopSceneAmbience("scene_main_amb", 0.3) -- 275
	end -- 275
	if key == "gate" and phase == "gate-hold" then -- 279
		if self.prevPhase ~= "gate-hold" then -- 280
			audio:playFoley( -- 281
				"gate:winch_start", -- 281
				CMB_ROOT .. "gate_winch_start.wav", -- 281
				0.8, -- 281
				-0.25, -- 281
				250 -- 281
			) -- 281
			self.gateTarpPlayed = false -- 282
		end -- 282
		local progress = clamp01(p.gateTick / 2700) -- 284
		audio:setSceneAmbience("scene_winch_chain", "ambience", AMB_ROOT .. "gate_winch_chain_loop.ogg", 0.26 + progress * 0.16) -- 285
		if not self.gateTarpPlayed and p.gateTick >= 720 then -- 286
			self.gateTarpPlayed = true -- 287
			audio:playFoley( -- 288
				"gate:tarp_fall", -- 288
				CMB_ROOT .. "gate_tarp_fall.wav", -- 288
				0.72, -- 288
				0.18, -- 288
				500 -- 288
			) -- 288
		end -- 288
	else -- 288
		if key == "gate" and self.prevPhase == "gate-hold" and phase == "gate-send" then -- 291
			audio:playFoley( -- 292
				"gate:winch_lock", -- 292
				CMB_ROOT .. "gate_winch_lock.wav", -- 292
				0.88, -- 292
				-0.1, -- 292
				250 -- 292
			) -- 292
		end -- 292
		audio:stopSceneAmbience("scene_winch_chain", 0.25) -- 294
	end -- 294
	local nearCulvert = p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 40 and p.player.x <= p.room.arch.x1 + 40 or key == "village" and p.player.x >= p.ox + 520 or key == "forest" and p.player.x >= p.ox + 830 and p.player.x <= p.ox + 1230 -- 298
	if nearCulvert and view.visualMode ~= "museum" then -- 301
		audio:setSceneAmbience("scene_culvert_drip", "water", AMB_ROOT .. "culvert_drip_echo_loop.ogg", 0.3) -- 302
	else -- 302
		audio:stopSceneAmbience("scene_culvert_drip", 0.35) -- 304
	end -- 304
	if key ~= "outside" and p.room.cart.bodyW > 0 and dt > 0.0001 then -- 308
		local speed = math.abs(p.cartAxle - self.prevCartAxle) / dt -- 309
		if speed > 4 then -- 310
			local vol = math.min(0.46, 0.18 + speed / 64 * 0.28) -- 311
			audio:setSceneAmbience("scene_cart_wheel", "ambience", "assets/audio/child/cart_wheel_loop.wav", vol) -- 312
		else -- 312
			audio:stopSceneAmbience("scene_cart_wheel", 0.12) -- 314
		end -- 314
	else -- 314
		audio:stopSceneAmbience("scene_cart_wheel", 0.12) -- 317
	end -- 317
	self.prevCartAxle = p.cartAxle -- 319
end -- 257
function SoundscapeDirector.prototype.syncFoley(self, dt, p, view, audio) -- 322
	local key = p.room.key -- 323
	local inCutscene = view.visualMode == "museum" or key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-give") or key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or key == "tower" and (p.phase == "tower-knock" or p.phase == "tower-given" or p.phase == "tower-end") -- 324
	local offerCount = #p:getStoryTalentOffers() -- 330
	if offerCount > 0 and self.prevOfferCount == 0 then -- 331
		audio:playUi("ui:talent_appear", UI_ROOT .. "talent_appear.wav", 0.72, 0.2) -- 332
	end -- 332
	self.prevOfferCount = offerCount -- 334
	if not p.craftBench.active and self.prevWeapon ~= "" and p.equippedWeapon ~= self.prevWeapon then -- 337
		audio:playFoley( -- 338
			"weapon:switch", -- 338
			CMB_ROOT .. "weapon_switch_artifact.wav", -- 338
			0.78, -- 338
			0, -- 338
			140 -- 338
		) -- 338
	end -- 338
	self.prevWeapon = p.equippedWeapon -- 340
	if key == "village" and p.hasBottle and not self.prevHasBottle then -- 343
		audio:playFoley( -- 344
			"village:bottle_pickup", -- 344
			FOL_ROOT .. "bottle_pickup.wav", -- 344
			0.76, -- 344
			audio:panForWorldX(p.player.x), -- 344
			180 -- 344
		) -- 344
	end -- 344
	self.prevHasBottle = p.hasBottle -- 346
	self:syncLocomotionAndCombatFoley(dt, p, audio, inCutscene) -- 348
	self.prevPhase = p.phase -- 349
end -- 322
function SoundscapeDirector.prototype.syncLocomotionAndCombatFoley(self, dt, p, audio, suppressLocomotion) -- 352
	local a = p.player -- 353
	local pan = audio:panForWorldX(a.x) -- 354
	if not suppressLocomotion and dt > 0 then -- 356
		if a.rollT > 0 and self.prevRollT <= 0 then -- 358
			audio:playFoley( -- 359
				"foley:roll", -- 359
				FOL_ROOT .. "soldier_roll.wav", -- 359
				0.74, -- 359
				pan, -- 359
				220 -- 359
			) -- 359
		end -- 359
		if not a.onGround and self.prevOnGround and a.vy > 80 then -- 363
			local jPath = p.childMode and FOL_ROOT .. "jump_child.wav" or FOL_ROOT .. "jump_soldier.wav" -- 364
			audio:playFoley( -- 365
				"foley:jump", -- 365
				jPath, -- 365
				0.56, -- 365
				pan, -- 365
				160 -- 365
			) -- 365
		elseif a.onGround and not self.prevOnGround and self.prevVy < -60 then -- 366
			local lPath = p.childMode and FOL_ROOT .. "land_child.wav" or FOL_ROOT .. "land_soldier.wav" -- 367
			local impactVol = clamp01(0.36 + math.min( -- 368
				1, -- 368
				math.abs(self.prevVy) / 420 -- 368
			) * 0.42) -- 368
			audio:playFoley( -- 369
				"foley:land", -- 369
				lPath, -- 369
				impactVol, -- 369
				pan, -- 369
				120 -- 369
			) -- 369
		end -- 369
		if a.crouch and not self.prevCrouch and a.onGround then -- 373
			audio:playFoley( -- 374
				"foley:crouch", -- 374
				FOL_ROOT .. "crouch_rustle.wav", -- 374
				0.34, -- 374
				pan, -- 374
				180 -- 374
			) -- 374
		end -- 374
		local speedX = math.abs(a.vx) -- 378
		if a.onGround and a.rollT <= 0 and speedX > 12 then -- 379
			self.stepAccum = self.stepAccum + speedX * dt -- 380
			local stride = p.childMode and (a.crouch and 26 or 34) or 48 -- 381
			if self.stepAccum >= stride then -- 382
				self.stepAccum = self.stepAccum - stride -- 383
				self.stepIdx = self.stepIdx + 1 -- 384
				local stepInfo = self:pickPlayerFootstep(p, self.stepIdx) -- 385
				audio:playFoley( -- 386
					"foley:step", -- 386
					stepInfo.path, -- 386
					stepInfo.vol, -- 386
					pan, -- 386
					140 -- 386
				) -- 386
			end -- 386
		elseif speedX <= 4 then -- 388
			self.stepAccum = math.min(self.stepAccum, 16) -- 389
		end -- 389
		if p.room.key == "gatepath" and not p.childMode and p.partner.alive and math.abs(p.partner.vx) > 8 then -- 393
			self.partnerStepAccum = self.partnerStepAccum + math.abs(p.partner.vx) * dt -- 394
			if self.partnerStepAccum >= 32 then -- 395
				self.partnerStepAccum = self.partnerStepAccum - 32 -- 396
				self.partnerStepIdx = self.partnerStepIdx + 1 -- 397
				local cPath = CHILD_STONE_STEPS[self.partnerStepIdx % #CHILD_STONE_STEPS + 1] -- 398
				audio:playFoley( -- 399
					"foley:partner_step", -- 399
					cPath, -- 399
					0.44, -- 399
					audio:panForWorldX(p.partner.x), -- 399
					140 -- 399
				) -- 399
			end -- 399
		end -- 399
	end -- 399
	local i = 0 -- 405
	do -- 405
		i = 0 -- 406
		while i < #p.enemies do -- 406
			local en = p.enemies[i + 1] -- 407
			local warnNow = en.alive and en.warnT > 0 -- 408
			local warnWas = self.enemyWarnPrev[i] == true -- 409
			if warnNow and not warnWas then -- 410
				audio:playFoley( -- 411
					"combat:enemy_warn:" .. tostring(i), -- 411
					CMB_ROOT .. "enemy_warn.wav", -- 411
					0.68, -- 411
					audio:panForWorldX(en.x), -- 411
					300 -- 411
				) -- 411
			end -- 411
			self.enemyWarnPrev[i] = warnNow -- 413
			i = i + 1 -- 406
		end -- 406
	end -- 406
	self.prevOnGround = a.onGround -- 416
	self.prevVy = a.vy -- 417
	self.prevRollT = a.rollT -- 418
	self.prevCrouch = a.crouch -- 419
end -- 352
function SoundscapeDirector.prototype.pickPlayerFootstep(self, p, idx) -- 422
	if not p.childMode then -- 423
		return {path = SOLDIER_STONE_STEPS[idx % #SOLDIER_STONE_STEPS + 1], vol = p.player.crouch and 0.34 or 0.54} -- 424
	end -- 424
	local key = p.room.key -- 429
	local slowFactor = p.player.crouch and 0.52 or (math.abs(p.player.vx) <= 95 and 0.68 or 1) -- 430
	if key == "forest" then -- 431
		if p.player.x >= p.ox + 1310 then -- 432
			return {path = CHILD_WATER_STEPS[idx % #CHILD_WATER_STEPS + 1], vol = 0.46 * slowFactor} -- 433
		end -- 433
		return {path = CHILD_MOSS_STEPS[idx % #CHILD_MOSS_STEPS + 1], vol = 0.36 * slowFactor} -- 435
	end -- 435
	if key == "village" and p.player.x >= p.ox + 540 then -- 437
		return {path = CHILD_WATER_STEPS[idx % #CHILD_WATER_STEPS + 1], vol = 0.42 * slowFactor} -- 438
	end -- 438
	return {path = CHILD_STONE_STEPS[idx % #CHILD_STONE_STEPS + 1], vol = 0.48 * slowFactor} -- 440
end -- 422
return ____exports -- 422
