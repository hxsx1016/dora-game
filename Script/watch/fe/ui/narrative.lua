-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____play = require("Script.watch.play") -- 10
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 10
local gateCountAtTick = ____play.gateCountAtTick -- 10
local ____platform = require("Script.watch.platform") -- 12
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 12
local ____dialogues = require("Script.watch.dialogues") -- 13
local MUTE_SFX_CAPTIONS = ____dialogues.MUTE_SFX_CAPTIONS -- 14
local NEEDLE_NOTE_LINES = ____dialogues.NEEDLE_NOTE_LINES -- 15
local dialogueById = ____dialogues.dialogueById -- 17
local ____target = require("Script.watch.target") -- 21
local getActiveTarget = ____target.getActiveTarget -- 21
local ____theme = require("Script.watch.fe.theme") -- 23
local PALETTE = ____theme.PALETTE -- 24
local drawBlossomDot = ____theme.drawBlossomDot -- 25
local drawHairline = ____theme.drawHairline -- 26
local drawLoneSeal = ____theme.drawLoneSeal -- 27
local drawMistCurve = ____theme.drawMistCurve -- 28
local drawSilkVeil = ____theme.drawSilkVeil -- 30
local fillRadialGlow = ____theme.fillRadialGlow -- 31
local themeOf = ____theme.themeOf -- 32
local toChineseUpper = ____theme.toChineseUpper -- 33
local toColor = ____theme.toColor -- 34
local visualTextWidth = ____theme.visualTextWidth -- 35
____exports.NarrativeRenderer = __TS__Class() -- 38
local NarrativeRenderer = ____exports.NarrativeRenderer -- 38
NarrativeRenderer.name = "NarrativeRenderer" -- 38
function NarrativeRenderer.prototype.____constructor(self) -- 38
	self.letterbox = 0 -- 40
	self.bannerT = 0 -- 42
	self.bannerMax = 2.8 -- 43
	self.wipeT = 0 -- 45
	self.lastRoomKey = "" -- 46
	self.time = 0 -- 47
	self.activeLineT = 0 -- 51
	self.queuedLines = {} -- 52
	self.triggeredBeats = {} -- 53
	self.lastS2BoardOpen = false -- 54
	self.lastC1LatchRaised = false -- 55
	self.lastCartDocked = false -- 56
	self.lastEscortCalming = false -- 57
	self.lastFlashSeen = "" -- 58
	self.muteCaption = "" -- 60
	self.muteCaptionT = 0 -- 61
end -- 38
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 63
	self.lastRoomKey = roomKey -- 64
	self.bannerT = self.bannerMax -- 65
	self.wipeT = 1 -- 66
	self.activeLine = nil -- 67
	self.activeLineT = 0 -- 68
	self.queuedLines = {} -- 69
	self.triggeredBeats = {} -- 70
	self.lastS2BoardOpen = false -- 71
	self.lastC1LatchRaised = false -- 72
	self.lastCartDocked = false -- 73
	self.lastEscortCalming = false -- 74
	self.lastFlashSeen = "" -- 75
	self.muteCaption = "" -- 76
	self.muteCaptionT = 0 -- 77
end -- 63
function NarrativeRenderer.prototype.getActiveDialogue(self) -- 81
	return {id = self.activeLine ~= nil and self.activeLine.id or "", who = self.activeLine ~= nil and self.activeLine.who or "", text = self.activeLine ~= nil and self.activeLine.text or "", muteCaption = self.muteCaptionT > 0 and self.muteCaption or ""} -- 82
end -- 81
function NarrativeRenderer.prototype.triggerOnce(self, beatKey, lineIds, replaceCurrent) -- 90
	if replaceCurrent == nil then -- 90
		replaceCurrent = false -- 90
	end -- 90
	if self.triggeredBeats[beatKey] then -- 90
		return -- 92
	end -- 92
	self.triggeredBeats[beatKey] = true -- 94
	if replaceCurrent then -- 94
		self.activeLine = nil -- 96
		self.activeLineT = 0 -- 97
		self.queuedLines = {} -- 98
	end -- 98
	local i = 0 -- 100
	do -- 100
		i = 0 -- 101
		while i < #lineIds do -- 101
			local d = dialogueById(lineIds[i + 1]) -- 102
			if d ~= nil then -- 102
				if self.activeLine == nil then -- 102
					self.activeLine = d -- 105
					self.activeLineT = d.duration -- 106
				else -- 106
					local ____self_queuedLines_0 = self.queuedLines -- 106
					____self_queuedLines_0[#____self_queuedLines_0 + 1] = d -- 108
				end -- 108
			end -- 108
			i = i + 1 -- 101
		end -- 101
	end -- 101
end -- 90
function NarrativeRenderer.prototype.showMuteCaption(self, key, duration) -- 114
	if duration == nil then -- 114
		duration = 1.9 -- 114
	end -- 114
	local txt = MUTE_SFX_CAPTIONS[key] -- 115
	if txt ~= nil and txt ~= "" then -- 115
		self.muteCaption = txt -- 117
		self.muteCaptionT = duration -- 118
	end -- 118
end -- 114
function NarrativeRenderer.prototype.stepScriptedBeats(self, p, events, interactPressed) -- 122
	if interactPressed == nil then -- 122
		interactPressed = false -- 122
	end -- 122
	local key = p.room.key -- 123
	local ox = p.ox -- 124
	local px = p.player.x -- 125
	if events ~= nil then -- 125
		if events.knockPulse then -- 125
			self:showMuteCaption("knockTwo", 1.8) -- 130
		end -- 130
		if events.cartJustDocked then -- 130
			self:showMuteCaption("cartDock", 2) -- 133
		end -- 133
		if events.bottleLanded then -- 133
			local isBasin = (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 -- 136
			self:showMuteCaption(isBasin and "basinRing" or "brickClink", 2) -- 137
		end -- 137
		local ei = 0 -- 139
		do -- 139
			ei = 0 -- 140
			while ei < #events.rawEvents do -- 140
				local ev = events.rawEvents[ei + 1] -- 141
				if ev.name == "storyBeat" and ev.data.beat == "tower_door" then -- 141
					self:showMuteCaption("knockReply", 2) -- 143
				end -- 143
				ei = ei + 1 -- 140
			end -- 140
		end -- 140
	end -- 140
	if p.flash ~= "" and p.flash ~= self.lastFlashSeen then -- 140
		self.lastFlashSeen = p.flash -- 148
		if (string.find(p.flash, "枯枝", nil, true) or 0) - 1 >= 0 then -- 148
			self:showMuteCaption("twigSnap", 1.8) -- 150
		elseif (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 then -- 150
			self:showMuteCaption("basinRing", 1.8) -- 152
		elseif (string.find(p.flash, "砖", nil, true) or 0) - 1 >= 0 and key == "village" then -- 152
			self:showMuteCaption("brickClink", 1.8) -- 154
		end -- 154
	end -- 154
	local calmingNow = p.escort.state == "calming" -- 159
	if calmingNow and not self.lastEscortCalming then -- 159
		self:showMuteCaption("knockTwo", 2) -- 161
		self.triggeredBeats.calming_d04 = false -- 162
		self:triggerOnce("calming_d04", {"D04"}, true) -- 163
	end -- 163
	self.lastEscortCalming = calmingNow -- 165
	if key == "prologue" then -- 165
		if p.phase == "prologue-wake" then -- 165
			if p.introTick < 120 then -- 165
				self:triggerOnce("p0_wake_mom", {"D30"}, true) -- 171
			else -- 171
				self:triggerOnce("p0_wake_dad", {"D31"}, true) -- 173
			end -- 173
		elseif p.phase == "prologue-shadow" then -- 173
			if p.introTick < 90 then -- 173
				self:triggerOnce("p0_shadow_call", {"D32"}, true) -- 177
			else -- 177
				self:triggerOnce("p0_shadow_raider", {"D33"}, true) -- 179
			end -- 179
		elseif p.phase == "prologue-escape" then -- 179
			self:triggerOnce("p0_shadow_raider", {"D33"}) -- 182
			self:triggerOnce("p0_escape_cry", {"D34"}) -- 183
		elseif p.phase == "prologue-hide" then -- 183
			if self.activeLine ~= nil then -- 183
				self.activeLine = nil -- 187
				self.activeLineT = 0 -- 188
				self.queuedLines = {} -- 189
			end -- 189
		elseif p.phase == "prologue-wait" then -- 189
			self:triggerOnce("p1_call", {"D35", "D36"}, true) -- 192
		elseif p.phase == "prologue-give" then -- 192
			self:triggerOnce("p2_give", { -- 195
				"D01", -- 195
				"D02", -- 195
				"D03", -- 195
				"D37", -- 195
				"D38" -- 195
			}, true) -- 195
		elseif p.phase == "prologue-follow" then -- 195
			if px >= ox + 420 then -- 195
				self:triggerOnce("p3_well", {"D21", "D22", "D39"}) -- 198
			elseif px >= ox + 300 then -- 198
				self:triggerOnce("p2_wall", {"D57", "D58"}) -- 200
			end -- 200
			if interactPressed and px <= ox + 175 and math.abs(p.player.y) < 20 then -- 200
				self:triggerOnce("opt_pinwheel", {"OPT_PINWHEEL"}, true) -- 204
			end -- 204
		end -- 204
		return -- 207
	end -- 207
	if key == "s1-crossroad" then -- 207
		if px < ox + 260 then -- 207
			self:triggerOnce("s1_standoff", {"D23", "D24"}) -- 212
		elseif px >= ox + 380 and self.activeLine ~= nil and self.activeLine.id == "D23" then -- 212
			self.activeLine = nil -- 215
			self.activeLineT = 0 -- 216
			self.queuedLines = {} -- 217
		end -- 217
		if px >= ox + 920 then -- 217
			self:triggerOnce("s1_after_fight", {"D40", "D41"}) -- 220
		end -- 220
		return -- 222
	end -- 222
	if key == "s2-drygoods" then -- 222
		local boardOpen = false -- 226
		local bi = 0 -- 227
		do -- 227
			bi = 0 -- 228
			while bi < #p.boxes do -- 228
				if p.boxes[bi + 1].id == "s2_board_cover" and not p.boxes[bi + 1].hidden then -- 228
					boardOpen = true -- 230
					break -- 231
				end -- 231
				bi = bi + 1 -- 228
			end -- 228
		end -- 228
		if not boardOpen and px >= ox + 290 and px <= ox + 520 then -- 228
			self:triggerOnce("s2_hint_board", {"D05"}) -- 235
		end -- 235
		if boardOpen and not self.lastS2BoardOpen then -- 235
			self:showMuteCaption("boardDrop", 2) -- 238
			self:triggerOnce("s2_board_drop", {"D42"}, true) -- 239
		end -- 239
		if boardOpen and interactPressed and px >= ox + 470 and px <= ox + 640 and math.abs(p.player.y) < 20 then -- 239
			self:triggerOnce("opt_shadowdisc", {"OPT_SHADOWDISC"}, true) -- 243
		end -- 243
		self.lastS2BoardOpen = boardOpen -- 245
		return -- 246
	end -- 246
	if key == "s3-archway" then -- 246
		if px >= ox + 660 and p.partner.alive and math.abs(p.partner.x - px) <= 150 then -- 246
			self:triggerOnce("s3_rejoin", {"D06"}) -- 251
		end -- 251
		return -- 253
	end -- 253
	if key == "c1-yard" then -- 253
		if px >= ox + 220 and px <= ox + 640 then -- 253
			self:triggerOnce("c1_enter", {"C1A", "C1B"}) -- 258
		end -- 258
		local latchRaised = p.run.c1Latch == true -- 260
		if latchRaised and not self.lastC1LatchRaised then -- 260
			self:showMuteCaption("latchOpen", 2) -- 262
			self:triggerOnce("c1_latch", {"C1C"}, true) -- 263
		end -- 263
		self.lastC1LatchRaised = latchRaised -- 265
		return -- 266
	end -- 266
	if key == "c2-granary" then -- 266
		if not p.cartDocked and px >= ox + 260 then -- 266
			self:triggerOnce("c2_groove", {"D07", "D43"}) -- 271
		end -- 271
		if p.cartDocked and not self.lastCartDocked then -- 271
			self:showMuteCaption("latchOpen", 2) -- 274
			self:triggerOnce("c2_docked", {"D08"}, true) -- 275
		end -- 275
		self.lastCartDocked = p.cartDocked -- 277
		return -- 278
	end -- 278
	if key == "gate" then -- 278
		if p.phase == "gate-idle" then -- 278
			self:triggerOnce("g1_winch", { -- 283
				"D09", -- 283
				"D44", -- 283
				"D45", -- 283
				"D59", -- 283
				"D60" -- 283
			}) -- 283
		elseif p.phase == "gate-hold" then -- 283
			if self.activeLine ~= nil then -- 283
				self.activeLine = nil -- 287
				self.activeLineT = 0 -- 288
				self.queuedLines = {} -- 289
			end -- 289
		elseif p.phase == "gate-send" then -- 289
			self:triggerOnce("g3_farewell", { -- 292
				"D10", -- 292
				"D25", -- 292
				"D26", -- 292
				"D61", -- 292
				"D62", -- 292
				"D46", -- 292
				"D47", -- 292
				"D12" -- 292
			}, true) -- 292
		elseif p.phase == "gate-farewell" or p.phase == "gate-count" then -- 292
			if self.activeLine ~= nil then -- 292
				self.activeLine = nil -- 296
				self.activeLineT = 0 -- 297
				self.queuedLines = {} -- 298
			end -- 298
		elseif p.phase == "gate-wait" then -- 298
			self:triggerOnce("g4_reunion_call", {"D48", "D49", "D50"}, true) -- 301
		elseif p.phase == "gate-hand" then -- 301
			if self.activeLine ~= nil then -- 301
				self.activeLine = nil -- 304
				self.activeLineT = 0 -- 305
				self.queuedLines = {} -- 306
			end -- 306
		end -- 306
		return -- 309
	end -- 309
	if key == "gatepath" then -- 309
		self:triggerOnce("g06_north", {"G06A", "G06B", "D51", "D52"}) -- 313
		return -- 314
	end -- 314
	if key == "escort1" then -- 314
		if px >= ox + 170 and px <= ox + 460 then -- 314
			self:triggerOnce("e1_start", {"E1A", "E1B"}) -- 320
		end -- 320
		return -- 322
	end -- 322
	if key == "escort2" then -- 322
		if px >= ox + 220 and px <= ox + 520 then -- 322
			self:triggerOnce("e2_granary", {"E2A", "E2B"}) -- 327
		end -- 327
		return -- 329
	end -- 329
	if key == "escort3" then -- 329
		if px >= ox + 440 and px <= ox + 710 then -- 329
			self:triggerOnce("e3_bench_rest", {"E3A", "E3B"}) -- 334
		end -- 334
		if events ~= nil and events.benchCrafted then -- 334
			self:triggerOnce("e3_bench_crafted", {"E3C"}, true) -- 337
		end -- 337
		return -- 339
	end -- 339
	if key == "escort4" then -- 339
		if px >= ox + 190 and px <= ox + 460 then -- 339
			self:triggerOnce("e4_cliff", {"E4A", "E4B"}) -- 344
		end -- 344
		return -- 346
	end -- 346
	if key == "escort5" then -- 346
		if px >= ox + 180 and px <= ox + 420 then -- 346
			self:triggerOnce("e5_dawn", {"E5A", "E5B"}) -- 351
		end -- 351
		return -- 353
	end -- 353
	if key == "outside" then -- 353
		if px >= ox + 760 and px <= ox + 1020 then -- 353
			self:triggerOnce("o3_salt_wind", {"O3_WIND"}) -- 359
		end -- 359
		if interactPressed and px >= ox + 830 and px <= ox + 950 and math.abs(p.player.y) < 20 then -- 359
			self:triggerOnce("opt_shell", {"OPT_SHELL"}, true) -- 362
		end -- 362
		return -- 364
	end -- 364
	if key == "village" then -- 364
		if p.passed and px >= ox + 550 and px <= ox + 690 then -- 364
			self:triggerOnce("v3_grate_ask", {"D27"}) -- 370
			if interactPressed and self.triggeredBeats.v3_grate_ask then -- 370
				self:triggerOnce("v3_grate_reply", {"D28", "D29"}, true) -- 372
			end -- 372
		end -- 372
		return -- 375
	end -- 375
	if key == "forest" then -- 375
		local waterBeat = events ~= nil and __TS__ArraySome( -- 380
			events.storyBeats, -- 380
			function(____, b) return b.beat == "water_lantern" end -- 380
		) -- 380
		if waterBeat or px >= ox + 1190 then -- 380
			self:triggerOnce("f4_creek_lamp", {"F4_CREEK"}) -- 382
		end -- 382
		if interactPressed and px >= ox + 300 and px <= ox + 400 and p.player.crouch then -- 382
			self:triggerOnce("opt_hollow", {"OPT_HOLLOW"}, true) -- 385
		end -- 385
		return -- 387
	end -- 387
	if key == "tower" then -- 387
		if p.phase == "tower-wait" and interactPressed and px >= ox + 300 and px <= ox + 385 then -- 387
			self:triggerOnce("opt_lantern", {"OPT_LANTERN"}, true) -- 393
		elseif p.phase == "tower-enter" then -- 393
			self:triggerOnce("t2_knock", {"D14", "D15"}, true) -- 396
		elseif p.phase == "tower-desk" then -- 396
			if p.storyRoute == "soldier" then -- 396
				self:triggerOnce("t3_soldier_talk", { -- 399
					"D53", -- 399
					"D54", -- 399
					"D16", -- 399
					"D17", -- 399
					"D63", -- 399
					"D64" -- 399
				}) -- 399
			else -- 399
				self:triggerOnce("t3_child_talk", { -- 401
					"D16", -- 401
					"D17", -- 401
					"D63", -- 401
					"D64", -- 401
					"D18", -- 401
					"D19" -- 401
				}) -- 401
			end -- 401
		elseif p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 then -- 401
			self:triggerOnce("t3_reunion_end", {"D55", "D56", "D65"}, true) -- 405
		end -- 405
	end -- 405
end -- 122
function NarrativeRenderer.prototype.update(self, dt, p, events, interactPressed) -- 410
	if interactPressed == nil then -- 410
		interactPressed = false -- 410
	end -- 410
	self.time = self.time + dt -- 411
	if self.lastRoomKey ~= p.room.key then -- 411
		self:onEnterRoom(p.room.key) -- 413
	end -- 413
	if self.muteCaptionT > 0 then -- 413
		self.muteCaptionT = math.max(0, self.muteCaptionT - dt) -- 416
	end -- 416
	if self.activeLine ~= nil then -- 416
		self.activeLineT = self.activeLineT - dt -- 419
		if self.activeLineT <= 0 then -- 419
			local next = table.remove(self.queuedLines, 1) -- 421
			self.activeLine = next -- 422
			self.activeLineT = next ~= nil and next.duration or 0 -- 423
		end -- 423
	end -- 423
	self:stepScriptedBeats(p, events, interactPressed) -- 426
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-farewell" or p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 428
	local target = wantCinema and 1 or 0 -- 433
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 434
	if p.room.key == "tower" and p.phase ~= "tower-wait" then -- 434
		self.bannerT = 0 -- 438
	end -- 438
	if self.bannerT > 0 then -- 438
		self.bannerT = math.max(0, self.bannerT - dt) -- 441
	end -- 441
	if self.wipeT > 0 then -- 441
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 444
	end -- 444
end -- 410
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 448
	if assistHintsEnabled == nil then -- 448
		assistHintsEnabled = false -- 457
	end -- 457
	if inputMode == nil then -- 457
		inputMode = "kbm" -- 458
	end -- 458
	if gamepadLayout == nil then -- 458
		gamepadLayout = "xbox" -- 459
	end -- 459
	if safe == nil then -- 459
		safe = ZERO_SAFE_INSETS -- 460
	end -- 460
	if self.letterbox > 0.01 then -- 460
		local barH = math.floor(70 * self.letterbox + 0.5) -- 464
		uiDraw:drawRect( -- 465
			Rect(0, h - barH, w, barH), -- 465
			Color(8, 10, 16, 242) -- 465
		) -- 465
		uiDraw:drawRect( -- 466
			Rect(0, 0, w, barH), -- 466
			Color(8, 10, 16, 242) -- 466
		) -- 466
		uiInkDraw:drawSegment( -- 467
			Vec2(0, h - barH), -- 467
			Vec2(w, h - barH), -- 467
			0.7, -- 467
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 467
		) -- 467
		uiInkDraw:drawSegment( -- 468
			Vec2(0, barH), -- 468
			Vec2(w, barH), -- 468
			0.7, -- 468
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 468
		) -- 468
	end -- 468
	if p.room.key == "gate" and p.phase == "gate-count" then -- 468
		self:drawGateCountOverlay( -- 473
			uiDraw, -- 473
			uiInkDraw, -- 473
			art, -- 473
			texts, -- 473
			p, -- 473
			w, -- 473
			h -- 473
		) -- 473
	end -- 473
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 477
	if showRegistry then -- 477
		self:drawTowerRegistryCard( -- 479
			uiDraw, -- 479
			uiInkDraw, -- 479
			uiGlow, -- 479
			art, -- 479
			texts, -- 479
			p, -- 479
			w, -- 479
			h, -- 479
			assistHintsEnabled, -- 479
			inputMode, -- 479
			gamepadLayout -- 479
		) -- 479
	end -- 479
	if not p.paused and not showRegistry then -- 479
		self:drawSubtitleStrip( -- 484
			uiDraw, -- 484
			uiInkDraw, -- 484
			art, -- 484
			texts, -- 484
			p, -- 484
			w, -- 484
			h, -- 484
			assistHintsEnabled, -- 484
			inputMode, -- 484
			gamepadLayout, -- 484
			safe -- 484
		) -- 484
	end -- 484
	if self.bannerT > 0 and not p.paused then -- 484
		self:drawAreaBanner( -- 489
			uiDraw, -- 489
			uiInkDraw, -- 489
			art, -- 489
			texts, -- 489
			p.room.key, -- 489
			w, -- 489
			h -- 489
		) -- 489
	end -- 489
	if self.wipeT > 0.01 then -- 489
		local k = math.min(1, self.wipeT * 1.15) -- 494
		local a = math.floor(255 * k * k + 0.5) -- 495
		uiDraw:drawRect( -- 496
			Rect(0, 0, w, h), -- 496
			Color(9, 11, 17, a) -- 496
		) -- 496
		art:tryPlace( -- 497
			"ink_petal_mist", -- 497
			"wipe_mist", -- 497
			w * 0.5, -- 497
			h * 0.5, -- 497
			w * 0.65, -- 497
			h * 0.65, -- 497
			{ -- 497
				color = toColor(PALETTE.inkMist), -- 498
				opacity = 0.2 * self.wipeT, -- 498
				layer = 5 -- 498
			} -- 498
		) -- 498
	end -- 498
end -- 448
function NarrativeRenderer.prototype.drawCutsceneDialogue(self, uiDraw, uiInkDraw, art, texts, p, w, h, safe) -- 508
	if safe == nil then -- 508
		safe = ZERO_SAFE_INSETS -- 516
	end -- 516
	if p.paused then -- 516
		return -- 519
	end -- 519
	local key = p.room.key -- 521
	local allowDialogue = key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-give") or key == "gate" and p.phase == "gate-wait" or key == "tower" and p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 -- 522
	local cx = w * 0.5 -- 531
	local cy = (key == "gate" and p.phase == "gate-wait" and 68 or 42) + safe.bottom * 0.5 -- 532
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 532
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 535
		local capY = cy + 44 -- 536
		drawSilkVeil( -- 537
			uiDraw, -- 537
			art, -- 537
			"cut_mute_veil", -- 537
			cx, -- 537
			capY, -- 537
			172, -- 537
			26, -- 537
			PALETTE.inkWarm, -- 537
			0.76 * capAlpha, -- 537
			0 -- 537
		) -- 537
		texts:put( -- 538
			"xs", -- 538
			self.muteCaption, -- 538
			cx, -- 538
			capY, -- 538
			toColor(PALETTE.amberCore), -- 538
			0.5, -- 538
			0.5, -- 538
			"Center", -- 538
			1.4, -- 538
			0.94 * capAlpha, -- 538
			0.08 -- 538
		) -- 538
	end -- 538
	if not allowDialogue or self.activeLine == nil then -- 538
		return -- 542
	end -- 542
	local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 544
	local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 547
	local urgent = self.activeLine.urgent == true -- 549
	local hasCue = cue ~= "" -- 550
	local textW = visualTextWidth(spoken, 18) -- 551
	local contentW = textW + (hasCue and 48 or 0) -- 552
	local stripW = math.min( -- 553
		w - 72 - safe.left - safe.right, -- 553
		math.max(500, contentW + 180) -- 553
	) -- 553
	local stripH = 50 -- 554
	drawSilkVeil( -- 556
		uiDraw, -- 556
		art, -- 556
		"cut_sub_veil", -- 556
		cx, -- 556
		cy, -- 556
		stripW, -- 556
		stripH, -- 556
		urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 556
		0.86, -- 556
		2 -- 556
	) -- 556
	drawHairline( -- 557
		uiInkDraw, -- 557
		art, -- 557
		"cut_sub_top", -- 557
		cx, -- 557
		cy + 21, -- 557
		stripW * 0.72, -- 557
		urgent and PALETTE.rouge or PALETTE.silkDim, -- 557
		urgent and 0.72 or 0.52, -- 557
		true, -- 557
		3 -- 557
	) -- 557
	if hasCue then -- 557
		local startX = cx - contentW * 0.5 -- 559
		local cueCol = urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 560
		drawBlossomDot( -- 561
			uiInkDraw, -- 561
			art, -- 561
			"cut_cue_dot", -- 561
			startX + 6, -- 561
			cy - 1, -- 561
			10, -- 561
			cueCol, -- 561
			0.94, -- 561
			4 -- 561
		) -- 561
		texts:put( -- 562
			"xs", -- 562
			cue, -- 562
			startX + 24, -- 562
			cy - 1, -- 562
			toColor(urgent and PALETTE.crimsonCore or cueCol), -- 562
			0.5, -- 562
			0.5, -- 562
			"Center", -- 562
			0, -- 562
			0.96, -- 562
			0.08 -- 562
		) -- 562
		uiInkDraw:drawSegment( -- 563
			Vec2(startX + 38, cy - 8), -- 563
			Vec2(startX + 38, cy + 6), -- 563
			0.75, -- 563
			toColor(PALETTE.silkDim, 115) -- 563
		) -- 563
		texts:put( -- 564
			"sm", -- 564
			spoken, -- 564
			startX + 48, -- 564
			cy - 1, -- 564
			toColor(urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 564
			0, -- 564
			0.5, -- 564
			"Left", -- 564
			0.9, -- 564
			0.98, -- 564
			0.08 -- 564
		) -- 564
	else -- 564
		texts:put( -- 566
			"sm", -- 566
			spoken, -- 566
			cx, -- 566
			cy - 1, -- 566
			toColor(PALETTE.textBright), -- 566
			0.5, -- 566
			0.5, -- 566
			"Center", -- 566
			1, -- 566
			0.98, -- 566
			0.08 -- 566
		) -- 566
	end -- 566
end -- 508
function NarrativeRenderer.prototype.isKeyHintSegment(self, seg) -- 570
	return (string.find(seg, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(seg, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(seg, "限时", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 选", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 1", nil, true) or 0) - 1 >= 0 -- 571
end -- 570
function NarrativeRenderer.prototype.stripKeyHintClause(self, fl) -- 593
	if not self:isKeyHintSegment(fl) then -- 593
		return fl -- 595
	end -- 595
	local parts = __TS__StringSplit(fl, " · ") -- 597
	if #parts <= 1 then -- 597
		return "" -- 599
	end -- 599
	local kept = {} -- 601
	local i = 0 -- 602
	do -- 602
		i = 0 -- 603
		while i < #parts do -- 603
			local seg = __TS__StringTrim(parts[i + 1]) -- 604
			if seg ~= "" and not self:isKeyHintSegment(seg) then -- 604
				kept[#kept + 1] = seg -- 606
			end -- 606
			i = i + 1 -- 603
		end -- 603
	end -- 603
	return table.concat(kept, " · ") -- 609
end -- 593
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 612
	local cx = w * 0.5 -- 625
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 626
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 627
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 627
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 631
		local capY = cy + 44 -- 632
		drawSilkVeil( -- 633
			uiDraw, -- 633
			art, -- 633
			"mute_sfx_veil", -- 633
			cx, -- 633
			capY, -- 633
			172, -- 633
			26, -- 633
			PALETTE.inkWarm, -- 633
			0.76 * capAlpha, -- 633
			0 -- 633
		) -- 633
		texts:put( -- 634
			"xs", -- 634
			self.muteCaption, -- 634
			cx, -- 634
			capY, -- 634
			toColor(PALETTE.amberCore), -- 634
			0.5, -- 634
			0.5, -- 634
			"Center", -- 634
			1.4, -- 634
			0.94 * capAlpha, -- 634
			0.08 -- 634
		) -- 634
	end -- 634
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 637
	if rawLine.text == "" then -- 637
		return -- 639
	end -- 639
	local line = { -- 641
		cue = rawLine.cue, -- 642
		text = assistHintsEnabled and getActiveTarget():adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 643
		urgent = rawLine.urgent -- 644
	} -- 644
	local hasCue = line.cue ~= "" -- 646
	local textW = visualTextWidth(line.text, 18) -- 647
	local contentW = textW + (hasCue and 48 or 0) -- 648
	local stripW = math.min( -- 649
		w - 72 - safe.left - safe.right, -- 649
		math.max(540, contentW + 210) -- 649
	) -- 649
	local stripH = 54 -- 650
	drawSilkVeil( -- 653
		uiDraw, -- 653
		art, -- 653
		"sub_veil", -- 653
		cx, -- 653
		cy, -- 653
		stripW, -- 653
		stripH, -- 653
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 653
		0.84, -- 653
		-1 -- 653
	) -- 653
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 655
	drawHairline( -- 656
		uiInkDraw, -- 656
		art, -- 656
		"sub_top_line", -- 656
		cx, -- 656
		cy + 23, -- 656
		stripW * 0.72, -- 656
		railCol, -- 656
		line.urgent and 0.72 or 0.52, -- 656
		true, -- 656
		2 -- 656
	) -- 656
	if hasCue then -- 656
		local startX = cx - contentW * 0.5 -- 659
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 660
		drawBlossomDot( -- 661
			uiInkDraw, -- 661
			art, -- 661
			"sub_cue_dot", -- 661
			startX + 6, -- 661
			cy - 1, -- 661
			10, -- 661
			cueCol, -- 661
			0.94, -- 661
			4 -- 661
		) -- 661
		texts:put( -- 662
			"xs", -- 662
			line.cue, -- 662
			startX + 24, -- 662
			cy - 1, -- 662
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 662
			0.5, -- 662
			0.5, -- 662
			"Center", -- 662
			0, -- 662
			0.96, -- 662
			0.08 -- 662
		) -- 662
		uiInkDraw:drawSegment( -- 663
			Vec2(startX + 38, cy - 8), -- 663
			Vec2(startX + 38, cy + 6), -- 663
			0.75, -- 663
			toColor(PALETTE.silkDim, 115) -- 663
		) -- 663
		texts:put( -- 664
			"sm", -- 664
			line.text, -- 664
			startX + 48, -- 664
			cy - 1, -- 664
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 664
			0, -- 664
			0.5, -- 664
			"Left", -- 664
			0.9, -- 664
			0.98, -- 664
			0.08 -- 664
		) -- 664
	else -- 664
		texts:put( -- 666
			"sm", -- 666
			line.text, -- 666
			cx, -- 666
			cy - 1, -- 666
			toColor(PALETTE.textBright), -- 666
			0.5, -- 666
			0.5, -- 666
			"Center", -- 666
			1, -- 666
			0.98, -- 666
			0.08 -- 666
		) -- 666
	end -- 666
end -- 612
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 671
	local key = p.room.key -- 672
	local theme = themeOf(key) -- 673
	if key == "gate" and p.phase == "gate-count" then -- 673
		if p.countTick >= GATE_COUNT_END then -- 673
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 677
		end -- 677
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 683
	end -- 683
	if not assistHintsEnabled then -- 683
		if self.activeLine ~= nil then -- 683
			local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 689
			local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 692
			return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 694
		end -- 694
		if key == "prologue" and p.phase == "prologue-give" then -- 694
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 697
		end -- 697
		if key == "checkpoint" and p.escort.state == "calming" then -- 697
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 700
		end -- 700
		if key == "tower" then -- 700
			if p.phase == "tower-knock" then -- 700
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 704
			end -- 704
			if p.phase == "tower-given" then -- 704
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 707
			end -- 707
		end -- 707
		if p.flash ~= "" and p.flashT > 0 and p.flash ~= "翻滚结束" then -- 707
			local cleanFlash = self:stripKeyHintClause(p.flash) -- 712
			if cleanFlash ~= "" then -- 712
				local isDanger = (string.find(cleanFlash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "追", nil, true) or 0) - 1 >= 0 -- 714
				local text = cleanFlash -- 715
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 716
				if key == "tower" or key == "prologue" then -- 716
					cue = "" -- 718
				end -- 718
				if text == "命中" then -- 718
					text = "倭寇击倒" -- 721
				elseif text == "打空" then -- 721
					text = "铅丸偏离或被掩体阻挡" -- 723
				elseif text == "翻滚" then -- 723
					text = "伏身滑铲" -- 725
				end -- 725
				return {cue = cue, text = text, urgent = isDanger} -- 727
			end -- 727
		end -- 727
		return {cue = "", text = "", urgent = false} -- 730
	end -- 730
	if key == "gate" and p.phase == "gate-hold" then -- 730
		local threatened = false -- 734
		local hasAliveEnemy = false -- 735
		local i = 0 -- 736
		do -- 736
			i = 0 -- 737
			while i < #p.enemies do -- 737
				if p.enemies[i + 1].alive then -- 737
					hasAliveEnemy = true -- 739
					if p.enemies[i + 1].warnT > 0 then -- 739
						threatened = true -- 741
					end -- 741
				end -- 741
				i = i + 1 -- 737
			end -- 737
		end -- 737
		if threatened then -- 737
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 746
		end -- 746
		if p.coverHug then -- 746
			if hasAliveEnemy and not p.coverBlocking then -- 746
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 750
			end -- 750
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 752
		end -- 752
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 754
	end -- 754
	if key == "gate" and p.phase == "gate-count" then -- 754
		if p.countTick >= GATE_COUNT_END then -- 754
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 759
		end -- 759
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 765
	end -- 765
	if self.activeLine ~= nil then -- 765
		local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 769
		local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 772
		return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 774
	end -- 774
	if p.flash ~= "" and p.flashT > 0 and p.flash ~= "翻滚结束" then -- 774
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 778
		local text = p.flash -- 779
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 780
		if key == "tower" or key == "prologue" then -- 780
			cue = "" -- 782
		end -- 782
		if text == "命中" then -- 782
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 785
		elseif text == "打空" then -- 785
			text = "铅丸偏离或被掩体阻挡" -- 787
		elseif text == "翻滚" then -- 787
			text = "伏身滑铲" -- 789
		end -- 789
		return {cue = cue, text = text, urgent = isDanger} -- 791
	end -- 791
	if key == "prologue" then -- 791
		if p.phase == "prologue-wait" then -- 791
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 796
		end -- 796
		if p.phase == "prologue-give" then -- 796
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 799
		end -- 799
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 801
	end -- 801
	if key == "street" then -- 801
		local alive = 0 -- 805
		local i = 0 -- 806
		do -- 806
			i = 0 -- 807
			while i < #p.enemies do -- 807
				if p.enemies[i + 1].alive then -- 807
					alive = alive + 1 -- 808
				end -- 808
				i = i + 1 -- 807
			end -- 807
		end -- 807
		if alive > 0 then -- 807
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 811
		end -- 811
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 813
	end -- 813
	if key == "checkpoint" then -- 813
		if p.escort.state == "frozen" then -- 813
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 818
		end -- 818
		if p.escort.state == "calming" then -- 818
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 821
		end -- 821
		if not p.cartDocked then -- 821
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 824
		end -- 824
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 826
	end -- 826
	if key == "gate" then -- 826
		if p.phase == "gate-idle" then -- 826
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 831
		end -- 831
		if p.phase == "gate-send" then -- 831
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 838
		end -- 838
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 840
	end -- 840
	if key == "outside" then -- 840
		if not p.cartDocked then -- 840
			if p.gripping or p:cartHandleInReach() then -- 840
				return {cue = "", text = "按住 [E]+[D]，把红布车拉进右侧车窝", urgent = false} -- 846
			end -- 846
			local text = p.player.y < p.room.cart.baseY - 25 and "沿左侧石阶上台，去找红布车右柄" or "向右走到红布车的右柄" -- 848
			return {cue = "", text = text, urgent = false} -- 851
		end -- 851
		if p.checkpoint < p.room.arch.x1 then -- 851
			local text = p.player.y > p.room.arch.h + 2 and "车轮落窝了。往左返回石阶，下到地面" or "向右走到矮拱，按住 [CTRL] 蹲着穿过" -- 854
			return {cue = "潜", text = text, urgent = false} -- 857
		end -- 857
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 859
	end -- 859
	if key == "village" then -- 859
		if p.scavChase then -- 859
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 864
		end -- 864
		if p.passed then -- 864
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 867
		end -- 867
		if p.hasBottle then -- 867
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 870
		end -- 870
		if p.bottleFly ~= nil then -- 870
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 873
		end -- 873
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 873
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 876
		end -- 876
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 878
	end -- 878
	if key == "forest" then -- 878
		if p.dogState == "chase" then -- 878
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 883
		end -- 883
		if p.dogState == "ear" then -- 883
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 886
		end -- 886
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 888
	end -- 888
	if key == "tower" then -- 888
		if p.phase == "tower-wait" then -- 888
			return {cue = "", text = "走到木门前，按 [E] 叩门", urgent = false} -- 893
		end -- 893
		if p.phase == "tower-knock" then -- 893
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 896
		end -- 896
		if p.phase == "tower-enter" then -- 896
			return {cue = "", text = "门开了。向右跨过门槛，走到值夜桌前", urgent = false} -- 899
		end -- 899
		if p.phase == "tower-desk" then -- 899
			return {cue = "", text = "走到值夜桌前，按住 [E] 交出针套、指南针和纸条", urgent = false} -- 902
		end -- 902
		if p.phase == "tower-given" then -- 902
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 905
		end -- 905
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 907
	end -- 907
	return {cue = "", text = theme.introWhisper, urgent = false} -- 910
end -- 671
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 913
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 922
	local countNum = gateCountAtTick(p.countTick) -- 923
	uiDraw:drawRect( -- 924
		Rect(0, 0, w, h), -- 924
		Color( -- 924
			7, -- 924
			9, -- 924
			15, -- 924
			math.floor(78 + frac * 116 + 0.5) -- 924
		) -- 924
	) -- 924
	local cy = h * 0.56 -- 926
	art:tryPlace( -- 927
		"ink_petal_mist", -- 927
		"gate_count_mist", -- 927
		w * 0.5, -- 927
		cy, -- 927
		290, -- 927
		220, -- 927
		{ -- 927
			color = toColor(PALETTE.inkMist), -- 928
			opacity = 0.34 + frac * 0.2, -- 928
			layer = 0 -- 928
		} -- 928
	) -- 928
	drawMistCurve( -- 930
		art, -- 930
		"gate_count_wisp", -- 930
		w * 0.5, -- 930
		cy - 8, -- 930
		420, -- 930
		76, -- 930
		PALETTE.jadeMist, -- 930
		0.22, -- 930
		0 -- 930
	) -- 930
	local numZh = toChineseUpper(countNum) -- 932
	texts:put( -- 933
		"title", -- 933
		numZh, -- 933
		w * 0.5, -- 933
		cy + 8, -- 933
		toColor(PALETTE.textBright), -- 933
		0.5, -- 933
		0.5, -- 933
		"Center", -- 933
		12, -- 933
		0.42 + frac * 0.56, -- 933
		0.1 -- 933
	) -- 933
	drawHairline( -- 934
		uiInkDraw, -- 934
		art, -- 934
		"gate_count_div", -- 934
		w * 0.5, -- 934
		cy - 34, -- 934
		240, -- 934
		PALETTE.silkDim, -- 934
		0.62, -- 934
		true, -- 934
		2 -- 934
	) -- 934
	texts:put( -- 935
		"sm", -- 935
		"城外静候 · 默数至二十", -- 935
		w * 0.5, -- 935
		cy - 58, -- 935
		toColor(PALETTE.textMid), -- 935
		0.5, -- 935
		0.5, -- 935
		"Center", -- 935
		3.4, -- 935
		0.84, -- 935
		0.08 -- 935
	) -- 935
end -- 913
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 945
	local cardW = 588 -- 958
	local cardH = 382 -- 959
	local cx = (w - cardW) * 0.5 -- 960
	local cy = (h - cardH) * 0.5 + 10 -- 961
	local midX = w * 0.5 -- 962
	local midY = cy + cardH * 0.5 -- 963
	uiDraw:drawRect( -- 966
		Rect(0, 0, w, h), -- 966
		Color(7, 9, 15, 174) -- 966
	) -- 966
	art:tryPlace( -- 967
		"ink_frame_mask", -- 967
		"reg_shadow", -- 967
		midX, -- 967
		midY - 6, -- 967
		cardW + 58, -- 967
		cardH + 50, -- 967
		{ -- 967
			color = toColor(PALETTE.voidDark), -- 968
			opacity = 0.82, -- 968
			layer = -1 -- 968
		} -- 968
	) -- 968
	if not art:tryPlace( -- 968
		"ink_song_paper", -- 972
		"registry_song_paper", -- 972
		midX, -- 972
		midY, -- 972
		cardW, -- 972
		cardH, -- 972
		{opacity = 0.98, layer = 1} -- 972
	) then -- 972
		uiDraw:drawRect( -- 973
			Rect(cx, cy, cardW, cardH), -- 973
			toColor(PALETTE.xuanPaper, 246), -- 973
			1, -- 973
			toColor(PALETTE.silkDim, 180) -- 973
		) -- 973
	end -- 973
	fillRadialGlow( -- 975
		uiGlow, -- 975
		midX, -- 975
		midY + 46, -- 975
		240, -- 975
		130, -- 975
		Color(235, 224, 202, 14), -- 975
		Color(235, 224, 202, 0), -- 975
		14 -- 975
	) -- 975
	local padX = 46 -- 978
	local padY = 36 -- 979
	local inX = cx + padX -- 980
	local inY = cy + padY -- 981
	local inW = cardW - padX * 2 -- 982
	local inH = cardH - padY * 2 -- 983
	local redSilk = toColor(PALETTE.rouge, 118) -- 984
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 985
	uiInkDraw:drawRect( -- 987
		Rect(inX, inY, inW, inH), -- 987
		Color(0, 0, 0, 0), -- 987
		0.9, -- 987
		redSilk -- 987
	) -- 987
	uiInkDraw:drawRect( -- 988
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 988
		Color(0, 0, 0, 0), -- 988
		0.55, -- 988
		redSilkFaint -- 988
	) -- 988
	local headY = inY + inH - 28 -- 991
	texts:put( -- 992
		"md", -- 992
		"北塔入塔登记簿 · 末页", -- 992
		inX + 20, -- 992
		headY, -- 992
		toColor(PALETTE.xuanInk), -- 992
		0, -- 992
		0.5, -- 992
		"Left", -- 992
		2.4, -- 992
		0.94, -- 992
		0 -- 992
	) -- 992
	texts:put( -- 993
		"xs", -- 993
		"守望行记", -- 993
		inX + inW - 20, -- 993
		headY, -- 993
		toColor(PALETTE.xuanInkSub), -- 993
		1, -- 993
		0.5, -- 993
		"Right", -- 993
		2, -- 993
		0.78, -- 993
		0 -- 993
	) -- 993
	uiInkDraw:drawSegment( -- 994
		Vec2(inX + 14, headY - 22), -- 994
		Vec2(inX + inW - 14, headY - 22), -- 994
		0.85, -- 994
		redSilk -- 994
	) -- 994
	local reunion = #p.endingLines >= 2 and p.endingLines[2] ~= "" or p.storyRoute == "soldier" -- 997
	local row1Y = headY - 56 -- 998
	texts:put( -- 999
		"sm", -- 999
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 999
		inX + 20, -- 999
		row1Y, -- 999
		toColor(PALETTE.xuanInk), -- 999
		0, -- 999
		0.5, -- 999
		"Left", -- 999
		0.8, -- 999
		0.94, -- 999
		0 -- 999
	) -- 999
	texts:put( -- 1000
		"xs", -- 1001
		reunion and "附注：兄妹并肩抵塔；怀铜针、手书一纸。" or (("附注：" .. NEEDLE_NOTE_LINES[1]) .. " —— ") .. NEEDLE_NOTE_LINES[2], -- 1002
		inX + 20, -- 1003
		row1Y - 28, -- 1004
		toColor(PALETTE.xuanInkSub), -- 1005
		0, -- 1006
		0.5, -- 1007
		"Left", -- 1008
		0.6, -- 1009
		0.88, -- 1010
		0 -- 1011
	) -- 1011
	uiInkDraw:drawSegment( -- 1013
		Vec2(inX + 16, row1Y - 48), -- 1013
		Vec2(inX + inW - 16, row1Y - 48), -- 1013
		0.65, -- 1013
		redSilkFaint -- 1013
	) -- 1013
	local blankY = row1Y - 80 -- 1016
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 1017
	if reunion then -- 1017
		texts:put( -- 1019
			"sm", -- 1019
			"肆拾贰   周戍 · 兄妹同行 · 已入塔", -- 1019
			inX + 20, -- 1019
			blankY, -- 1019
			toColor(PALETTE.xuanInk), -- 1019
			0, -- 1019
			0.5, -- 1019
			"Left", -- 1019
			0.8, -- 1019
			0.94, -- 1019
			0 -- 1019
		) -- 1019
		texts:put( -- 1020
			"xs", -- 1020
			"附注：门内断后脱身，同抵北塔值夜室。", -- 1020
			inX + 20, -- 1020
			blankY - 26, -- 1020
			toColor(PALETTE.xuanInkSub), -- 1020
			0, -- 1020
			0.5, -- 1020
			"Left", -- 1020
			0.6, -- 1020
			0.86, -- 1020
			0 -- 1020
		) -- 1020
	else -- 1020
		texts:put( -- 1022
			"sm", -- 1022
			"肆拾贰", -- 1022
			inX + 20, -- 1022
			blankY, -- 1022
			toColor(PALETTE.rouge), -- 1022
			0, -- 1022
			0.5, -- 1022
			"Left", -- 1022
			1, -- 1022
			0.92, -- 1022
			0 -- 1022
		) -- 1022
		uiInkDraw:drawSegment( -- 1023
			Vec2(inX + 94, blankY - 7), -- 1023
			Vec2(inX + inW - 116, blankY - 7), -- 1023
			0.95, -- 1023
			toColor(PALETTE.xuanInkSub, 155 * pulse) -- 1023
		) -- 1023
		texts:put( -- 1024
			"xs", -- 1024
			"（空行留待）", -- 1024
			inX + inW - 104, -- 1024
			blankY, -- 1024
			toColor(PALETTE.xuanInkSub), -- 1024
			0, -- 1024
			0.5, -- 1024
			"Left", -- 1024
			1, -- 1024
			0.82 * pulse, -- 1024
			0 -- 1024
		) -- 1024
	end -- 1024
	if p.phase == "tower-end" then -- 1024
		local signY = inY + 46 -- 1029
		texts:put( -- 1030
			"banner", -- 1030
			"向西守望", -- 1030
			midX - 18, -- 1030
			signY, -- 1030
			toColor(PALETTE.xuanInk), -- 1030
			0.5, -- 1030
			0.5, -- 1030
			"Center", -- 1030
			6.5, -- 1030
			0.92, -- 1030
			0 -- 1030
		) -- 1030
		drawLoneSeal( -- 1031
			uiInkDraw, -- 1031
			art, -- 1031
			texts, -- 1031
			"reg_lone_seal", -- 1031
			midX + 86, -- 1031
			signY, -- 1031
			22, -- 1031
			42, -- 1031
			"守", -- 1031
			"望", -- 1031
			PALETTE.sealRed, -- 1031
			PALETTE.sealText, -- 1031
			0.92, -- 1031
			4 -- 1031
		) -- 1031
		drawSilkVeil( -- 1033
			uiDraw, -- 1033
			art, -- 1033
			"reg_hint_veil", -- 1033
			midX, -- 1033
			cy - 28, -- 1033
			360, -- 1033
			32, -- 1033
			PALETTE.inkWash, -- 1033
			0.72, -- 1033
			0 -- 1033
		) -- 1033
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 1034
		local endHint = getActiveTarget():adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 1035
		texts:put( -- 1036
			"xs", -- 1036
			endHint, -- 1036
			midX, -- 1036
			cy - 28, -- 1036
			toColor(PALETTE.textMid), -- 1036
			0.5, -- 1036
			0.5, -- 1036
			"Center", -- 1036
			1.6, -- 1036
			0.92, -- 1036
			0.08 -- 1036
		) -- 1036
	end -- 1036
end -- 945
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 1040
	local theme = themeOf(roomKey) -- 1049
	local t = self.bannerT / self.bannerMax -- 1050
	local alpha = 1 -- 1051
	if t > 0.82 then -- 1051
		alpha = (1 - t) / 0.18 -- 1053
	elseif t < 0.28 then -- 1053
		alpha = t / 0.28 -- 1055
	end -- 1055
	local cx = w * 0.5 -- 1057
	local cy = h * 0.77 -- 1058
	local spread = math.min(1, alpha * 1.15) -- 1059
	drawSilkVeil( -- 1062
		uiDraw, -- 1062
		art, -- 1062
		"banner_veil", -- 1062
		cx, -- 1062
		cy - 2, -- 1062
		480 * spread + 100, -- 1062
		92, -- 1062
		PALETTE.inkWash, -- 1062
		0.76 * alpha, -- 1062
		-1 -- 1062
	) -- 1062
	drawMistCurve( -- 1063
		art, -- 1063
		"banner_mist", -- 1063
		cx, -- 1063
		cy + 4, -- 1063
		460 * spread, -- 1063
		72, -- 1063
		theme.accent, -- 1063
		0.28 * alpha, -- 1063
		0 -- 1063
	) -- 1063
	drawHairline( -- 1064
		uiInkDraw, -- 1064
		art, -- 1064
		"banner_line", -- 1064
		cx, -- 1064
		cy - 16, -- 1064
		320 * spread, -- 1064
		PALETTE.silkLine, -- 1064
		0.64 * alpha, -- 1064
		false, -- 1064
		2 -- 1064
	) -- 1064
	local sep = " · " -- 1067
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 1068
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 1069
	if theme.backdropKey ~= nil then -- 1069
		texts:put( -- 1071
			"lg", -- 1071
			theme.titleZh, -- 1071
			cx, -- 1071
			cy + 14, -- 1071
			toColor(PALETTE.textBright), -- 1071
			0.5, -- 1072
			0.5, -- 1072
			"Center", -- 1072
			1, -- 1072
			alpha, -- 1072
			0.1 -- 1072
		) -- 1072
	elseif idx > 0 then -- 1072
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 1074
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 1075
		local lw = visualTextWidth(leftPart, 42) -- 1076
		local rw = visualTextWidth(rightPart, 42) -- 1077
		local dotGap = 28 -- 1078
		local totalW = lw + rw + dotGap -- 1079
		local leftEdge = cx - totalW * 0.5 -- 1080
		local dotX = leftEdge + lw + dotGap * 0.5 -- 1081
		texts:put( -- 1083
			"banner", -- 1083
			leftPart, -- 1083
			leftEdge, -- 1083
			cy + 14, -- 1083
			toColor(PALETTE.textBright), -- 1083
			0, -- 1083
			0.5, -- 1083
			"Left", -- 1083
			2, -- 1083
			alpha, -- 1083
			0.1 -- 1083
		) -- 1083
		drawBlossomDot( -- 1084
			uiInkDraw, -- 1084
			art, -- 1084
			"banner_mid_dot", -- 1084
			dotX, -- 1084
			cy + 12, -- 1084
			11, -- 1084
			dotCol, -- 1084
			0.92 * alpha, -- 1084
			4 -- 1084
		) -- 1084
		texts:put( -- 1085
			"banner", -- 1085
			rightPart, -- 1085
			dotX + dotGap * 0.5, -- 1085
			cy + 14, -- 1085
			toColor(PALETTE.textBright), -- 1085
			0, -- 1085
			0.5, -- 1085
			"Left", -- 1085
			2, -- 1085
			alpha, -- 1085
			0.1 -- 1085
		) -- 1085
	else -- 1085
		texts:put( -- 1087
			"banner", -- 1087
			theme.titleZh, -- 1087
			cx, -- 1087
			cy + 14, -- 1087
			toColor(PALETTE.textBright), -- 1087
			0.5, -- 1087
			0.5, -- 1087
			"Center", -- 1087
			3, -- 1087
			alpha, -- 1087
			0.1 -- 1087
		) -- 1087
	end -- 1087
	texts:put( -- 1089
		"xs", -- 1089
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 1089
		cx, -- 1089
		cy - 34, -- 1089
		toColor(PALETTE.textMid), -- 1089
		0.5, -- 1089
		0.5, -- 1089
		"Center", -- 1089
		2.2, -- 1089
		0.82 * alpha, -- 1089
		0.08 -- 1089
	) -- 1089
end -- 1040
return ____exports -- 1040