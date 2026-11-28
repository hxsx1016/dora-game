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
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
local ____play = require("Script.watch.play") -- 11
local CART_REACH = ____play.CART_REACH -- 11
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 11
local gateCountAtTick = ____play.gateCountAtTick -- 11
local ____platform = require("Script.watch.platform") -- 13
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 13
local ____dialogues = require("Script.watch.dialogues") -- 14
local MUTE_SFX_CAPTIONS = ____dialogues.MUTE_SFX_CAPTIONS -- 15
local NEEDLE_NOTE_LINES = ____dialogues.NEEDLE_NOTE_LINES -- 16
local dialogueById = ____dialogues.dialogueById -- 18
local ____target = require("Script.watch.target") -- 22
local getActiveTarget = ____target.getActiveTarget -- 22
local ____theme = require("Script.watch.fe.theme") -- 24
local PALETTE = ____theme.PALETTE -- 25
local drawBlossomDot = ____theme.drawBlossomDot -- 26
local drawHairline = ____theme.drawHairline -- 27
local drawLoneSeal = ____theme.drawLoneSeal -- 28
local drawMistCurve = ____theme.drawMistCurve -- 29
local drawSilkVeil = ____theme.drawSilkVeil -- 31
local fillRadialGlow = ____theme.fillRadialGlow -- 32
local themeOf = ____theme.themeOf -- 33
local toChineseUpper = ____theme.toChineseUpper -- 34
local toColor = ____theme.toColor -- 35
local visualTextWidth = ____theme.visualTextWidth -- 36
____exports.NarrativeRenderer = __TS__Class() -- 39
local NarrativeRenderer = ____exports.NarrativeRenderer -- 39
NarrativeRenderer.name = "NarrativeRenderer" -- 39
function NarrativeRenderer.prototype.____constructor(self) -- 39
	self.letterbox = 0 -- 41
	self.bannerT = 0 -- 43
	self.bannerMax = 2.8 -- 44
	self.wipeT = 0 -- 46
	self.lastRoomKey = "" -- 47
	self.time = 0 -- 48
	self.activeLineT = 0 -- 52
	self.queuedLines = {} -- 53
	self.triggeredBeats = {} -- 54
	self.lastS2BoardOpen = false -- 55
	self.lastC1LatchRaised = false -- 56
	self.lastCartDocked = false -- 57
	self.lastEscortCalming = false -- 58
	self.lastFlashSeen = "" -- 59
	self.muteCaption = "" -- 61
	self.muteCaptionT = 0 -- 62
end -- 39
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 64
	self.lastRoomKey = roomKey -- 65
	self.bannerT = self.bannerMax -- 66
	self.wipeT = 1 -- 67
	self.activeLine = nil -- 68
	self.activeLineT = 0 -- 69
	self.queuedLines = {} -- 70
	self.triggeredBeats = {} -- 71
	self.lastS2BoardOpen = false -- 72
	self.lastC1LatchRaised = false -- 73
	self.lastCartDocked = false -- 74
	self.lastEscortCalming = false -- 75
	self.lastFlashSeen = "" -- 76
	self.muteCaption = "" -- 77
	self.muteCaptionT = 0 -- 78
end -- 64
function NarrativeRenderer.prototype.getActiveDialogue(self) -- 82
	return {id = self.activeLine ~= nil and self.activeLine.id or "", who = self.activeLine ~= nil and self.activeLine.who or "", text = self.activeLine ~= nil and self.activeLine.text or "", muteCaption = self.muteCaptionT > 0 and self.muteCaption or ""} -- 83
end -- 82
function NarrativeRenderer.prototype.triggerOnce(self, beatKey, lineIds, replaceCurrent) -- 91
	if replaceCurrent == nil then -- 91
		replaceCurrent = false -- 91
	end -- 91
	if self.triggeredBeats[beatKey] then -- 91
		return -- 93
	end -- 93
	self.triggeredBeats[beatKey] = true -- 95
	if replaceCurrent then -- 95
		self.activeLine = nil -- 97
		self.activeLineT = 0 -- 98
		self.queuedLines = {} -- 99
	end -- 99
	local i = 0 -- 101
	do -- 101
		i = 0 -- 102
		while i < #lineIds do -- 102
			local d = dialogueById(lineIds[i + 1]) -- 103
			if d ~= nil then -- 103
				if self.activeLine == nil then -- 103
					self.activeLine = d -- 106
					self.activeLineT = d.duration -- 107
				else -- 107
					local ____self_queuedLines_0 = self.queuedLines -- 107
					____self_queuedLines_0[#____self_queuedLines_0 + 1] = d -- 109
				end -- 109
			end -- 109
			i = i + 1 -- 102
		end -- 102
	end -- 102
end -- 91
function NarrativeRenderer.prototype.showMuteCaption(self, key, duration) -- 115
	if duration == nil then -- 115
		duration = 1.9 -- 115
	end -- 115
	local txt = MUTE_SFX_CAPTIONS[key] -- 116
	if txt ~= nil and txt ~= "" then -- 116
		self.muteCaption = txt -- 118
		self.muteCaptionT = duration -- 119
	end -- 119
end -- 115
function NarrativeRenderer.prototype.stepScriptedBeats(self, p, events, interactPressed) -- 123
	if interactPressed == nil then -- 123
		interactPressed = false -- 123
	end -- 123
	local key = p.room.key -- 124
	local ox = p.ox -- 125
	local px = p.player.x -- 126
	if events ~= nil then -- 126
		if events.knockPulse then -- 126
			self:showMuteCaption("knockTwo", 1.8) -- 131
		end -- 131
		if events.cartJustDocked then -- 131
			self:showMuteCaption("cartDock", 2) -- 134
		end -- 134
		if events.bottleLanded then -- 134
			local isBasin = (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 -- 137
			self:showMuteCaption(isBasin and "basinRing" or "brickClink", 2) -- 138
		end -- 138
		local ei = 0 -- 140
		do -- 140
			ei = 0 -- 141
			while ei < #events.rawEvents do -- 141
				local ev = events.rawEvents[ei + 1] -- 142
				if ev.name == "storyBeat" and ev.data.beat == "tower_door" then -- 142
					self:showMuteCaption("knockReply", 2) -- 144
				end -- 144
				ei = ei + 1 -- 141
			end -- 141
		end -- 141
	end -- 141
	if p.flash ~= "" and p.flash ~= self.lastFlashSeen then -- 141
		self.lastFlashSeen = p.flash -- 149
		if (string.find(p.flash, "枯枝", nil, true) or 0) - 1 >= 0 then -- 149
			self:showMuteCaption("twigSnap", 1.8) -- 151
		elseif (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 then -- 151
			self:showMuteCaption("basinRing", 1.8) -- 153
		elseif (string.find(p.flash, "砖", nil, true) or 0) - 1 >= 0 and key == "village" then -- 153
			self:showMuteCaption("brickClink", 1.8) -- 155
		end -- 155
	end -- 155
	local calmingNow = p.escort.state == "calming" -- 160
	if calmingNow and not self.lastEscortCalming then -- 160
		self:showMuteCaption("knockTwo", 2) -- 162
		self.triggeredBeats.calming_d04 = false -- 163
		self:triggerOnce("calming_d04", {"D04"}, true) -- 164
	end -- 164
	self.lastEscortCalming = calmingNow -- 166
	if key == "prologue" then -- 166
		if p.phase == "prologue-wake" then -- 166
			if p.introTick < 120 then -- 166
				self:triggerOnce("p0_wake_mom", {"D30"}, true) -- 172
			else -- 172
				self:triggerOnce("p0_wake_dad", {"D31"}, true) -- 174
			end -- 174
		elseif p.phase == "prologue-shadow" then -- 174
			if p.introTick < 90 then -- 174
				self:triggerOnce("p0_shadow_call", {"D32"}, true) -- 178
			else -- 178
				self:triggerOnce("p0_shadow_raider", {"D33"}, true) -- 180
			end -- 180
		elseif p.phase == "prologue-escape" then -- 180
			self:triggerOnce("p0_shadow_raider", {"D33"}) -- 183
			self:triggerOnce("p0_escape_cry", {"D34"}) -- 184
		elseif p.phase == "prologue-hide" then -- 184
			if self.activeLine ~= nil then -- 184
				self.activeLine = nil -- 188
				self.activeLineT = 0 -- 189
				self.queuedLines = {} -- 190
			end -- 190
		elseif p.phase == "prologue-wait" then -- 190
			self:triggerOnce("p1_call", {"D35", "D36"}, true) -- 193
		elseif p.phase == "prologue-give" then -- 193
			self:triggerOnce("p2_give", { -- 196
				"D01", -- 196
				"D02", -- 196
				"D03", -- 196
				"D37", -- 196
				"D38" -- 196
			}, true) -- 196
		elseif p.phase == "prologue-follow" then -- 196
			if px >= ox + 420 then -- 196
				self:triggerOnce("p3_well", {"D21", "D22", "D39"}) -- 199
			elseif px >= ox + 300 then -- 199
				self:triggerOnce("p2_wall", {"D57", "D58"}) -- 201
			end -- 201
			if interactPressed and px <= ox + 175 and math.abs(p.player.y) < 20 then -- 201
				self:triggerOnce("opt_pinwheel", {"OPT_PINWHEEL"}, true) -- 205
			end -- 205
		end -- 205
		return -- 208
	end -- 208
	if key == "s1-crossroad" then -- 208
		if px < ox + 260 then -- 208
			self:triggerOnce("s1_standoff", {"D23", "D24"}) -- 213
		elseif px >= ox + 380 and self.activeLine ~= nil and self.activeLine.id == "D23" then -- 213
			self.activeLine = nil -- 216
			self.activeLineT = 0 -- 217
			self.queuedLines = {} -- 218
		end -- 218
		if px >= ox + 920 then -- 218
			self:triggerOnce("s1_after_fight", {"D40", "D41"}) -- 221
		end -- 221
		return -- 223
	end -- 223
	if key == "s2-drygoods" then -- 223
		local boardOpen = false -- 227
		local bi = 0 -- 228
		do -- 228
			bi = 0 -- 229
			while bi < #p.boxes do -- 229
				if p.boxes[bi + 1].id == "s2_board_cover" and not p.boxes[bi + 1].hidden then -- 229
					boardOpen = true -- 231
					break -- 232
				end -- 232
				bi = bi + 1 -- 229
			end -- 229
		end -- 229
		if not boardOpen and px >= ox + 290 and px <= ox + 520 then -- 229
			self:triggerOnce("s2_hint_board", {"D05"}) -- 236
		end -- 236
		if boardOpen and not self.lastS2BoardOpen then -- 236
			self:showMuteCaption("boardDrop", 2) -- 239
			self:triggerOnce("s2_board_drop", {"D42"}, true) -- 240
		end -- 240
		if boardOpen and interactPressed and px >= ox + 470 and px <= ox + 640 and math.abs(p.player.y) < 20 then -- 240
			self:triggerOnce("opt_shadowdisc", {"OPT_SHADOWDISC"}, true) -- 244
		end -- 244
		self.lastS2BoardOpen = boardOpen -- 246
		return -- 247
	end -- 247
	if key == "s3-archway" then -- 247
		if px >= ox + 660 and p.partner.alive and math.abs(p.partner.x - px) <= 150 then -- 247
			self:triggerOnce("s3_rejoin", {"D06"}) -- 252
		end -- 252
		return -- 254
	end -- 254
	if key == "c1-yard" then -- 254
		if px >= ox + 220 and px <= ox + 640 then -- 254
			self:triggerOnce("c1_enter", {"C1A", "C1B"}) -- 259
		end -- 259
		local latchRaised = p.run.c1Latch == true -- 261
		if latchRaised and not self.lastC1LatchRaised then -- 261
			self:showMuteCaption("latchOpen", 2) -- 263
			self:triggerOnce("c1_latch", {"C1C"}, true) -- 264
		end -- 264
		self.lastC1LatchRaised = latchRaised -- 266
		return -- 267
	end -- 267
	if key == "c2-granary" then -- 267
		if not p.cartDocked and px >= ox + 260 then -- 267
			self:triggerOnce("c2_groove", {"D07", "D43"}) -- 272
		end -- 272
		if p.cartDocked and not self.lastCartDocked then -- 272
			self:showMuteCaption("latchOpen", 2) -- 275
			self:triggerOnce("c2_docked", {"D08"}, true) -- 276
		end -- 276
		self.lastCartDocked = p.cartDocked -- 278
		return -- 279
	end -- 279
	if key == "gate" then -- 279
		if p.phase == "gate-idle" then -- 279
			self:triggerOnce("g1_winch", { -- 284
				"D09", -- 284
				"D44", -- 284
				"D45", -- 284
				"D59", -- 284
				"D60" -- 284
			}) -- 284
		elseif p.phase == "gate-hold" then -- 284
			if self.activeLine ~= nil then -- 284
				self.activeLine = nil -- 288
				self.activeLineT = 0 -- 289
				self.queuedLines = {} -- 290
			end -- 290
		elseif p.phase == "gate-send" then -- 290
			self:triggerOnce("g3_farewell", { -- 293
				"D10", -- 293
				"D25", -- 293
				"D26", -- 293
				"D61", -- 293
				"D62", -- 293
				"D46", -- 293
				"D47", -- 293
				"D12" -- 293
			}, true) -- 293
		elseif p.phase == "gate-farewell" or p.phase == "gate-count" then -- 293
			if self.activeLine ~= nil then -- 293
				self.activeLine = nil -- 297
				self.activeLineT = 0 -- 298
				self.queuedLines = {} -- 299
			end -- 299
		elseif p.phase == "gate-wait" then -- 299
			self:triggerOnce("g4_reunion_call", {"D48", "D49", "D50"}, true) -- 302
		elseif p.phase == "gate-hand" then -- 302
			if self.activeLine ~= nil then -- 302
				self.activeLine = nil -- 305
				self.activeLineT = 0 -- 306
				self.queuedLines = {} -- 307
			end -- 307
		end -- 307
		return -- 310
	end -- 310
	if key == "gatepath" then -- 310
		self:triggerOnce("g06_north", {"G06A", "G06B", "D51", "D52"}) -- 314
		return -- 315
	end -- 315
	if key == "escort1" then -- 315
		if px >= ox + 170 and px <= ox + 460 then -- 315
			self:triggerOnce("e1_start", {"E1A", "E1B"}) -- 321
		end -- 321
		return -- 323
	end -- 323
	if key == "escort2" then -- 323
		if px >= ox + 220 and px <= ox + 520 then -- 323
			self:triggerOnce("e2_granary", {"E2A", "E2B"}) -- 328
		end -- 328
		return -- 330
	end -- 330
	if key == "escort3" then -- 330
		if px >= ox + 440 and px <= ox + 710 then -- 330
			self:triggerOnce("e3_bench_rest", {"E3A", "E3B"}) -- 335
		end -- 335
		if events ~= nil and events.benchCrafted then -- 335
			self:triggerOnce("e3_bench_crafted", {"E3C"}, true) -- 338
		end -- 338
		return -- 340
	end -- 340
	if key == "escort4" then -- 340
		if px >= ox + 190 and px <= ox + 460 then -- 340
			self:triggerOnce("e4_cliff", {"E4A", "E4B"}) -- 345
		end -- 345
		return -- 347
	end -- 347
	if key == "escort5" then -- 347
		if px >= ox + 180 and px <= ox + 420 then -- 347
			self:triggerOnce("e5_dawn", {"E5A", "E5B"}) -- 352
		end -- 352
		return -- 354
	end -- 354
	if key == "outside" then -- 354
		if px >= ox + 760 and px <= ox + 1020 then -- 354
			self:triggerOnce("o3_salt_wind", {"O3_WIND"}) -- 360
		end -- 360
		if interactPressed and px >= ox + 830 and px <= ox + 950 and math.abs(p.player.y) < 20 then -- 360
			self:triggerOnce("opt_shell", {"OPT_SHELL"}, true) -- 363
		end -- 363
		return -- 365
	end -- 365
	if key == "village" then -- 365
		if p.passed and px >= ox + 550 and px <= ox + 690 then -- 365
			self:triggerOnce("v3_grate_ask", {"D27"}) -- 371
			if interactPressed and self.triggeredBeats.v3_grate_ask then -- 371
				self:triggerOnce("v3_grate_reply", {"D28", "D29"}, true) -- 373
			end -- 373
		end -- 373
		return -- 376
	end -- 376
	if key == "forest" then -- 376
		local waterBeat = events ~= nil and __TS__ArraySome( -- 381
			events.storyBeats, -- 381
			function(____, b) return b.beat == "water_lantern" end -- 381
		) -- 381
		if waterBeat or px >= ox + 1190 then -- 381
			self:triggerOnce("f4_creek_lamp", {"F4_CREEK"}) -- 383
		end -- 383
		if interactPressed and px >= ox + 300 and px <= ox + 400 and p.player.crouch then -- 383
			self:triggerOnce("opt_hollow", {"OPT_HOLLOW"}, true) -- 386
		end -- 386
		return -- 388
	end -- 388
	if key == "tower" then -- 388
		if p.phase == "tower-wait" and interactPressed and px >= ox + 300 and px <= ox + 385 then -- 388
			self:triggerOnce("opt_lantern", {"OPT_LANTERN"}, true) -- 394
		elseif p.phase == "tower-enter" then -- 394
			self:triggerOnce("t2_knock", {"D14", "D15"}, true) -- 397
		elseif p.phase == "tower-desk" then -- 397
			if p.storyRoute == "soldier" then -- 397
				self:triggerOnce("t3_soldier_talk", { -- 400
					"D53", -- 400
					"D54", -- 400
					"D16", -- 400
					"D17", -- 400
					"D63", -- 400
					"D64" -- 400
				}) -- 400
			else -- 400
				self:triggerOnce("t3_child_talk", { -- 402
					"D16", -- 402
					"D17", -- 402
					"D63", -- 402
					"D64", -- 402
					"D18", -- 402
					"D19" -- 402
				}) -- 402
			end -- 402
		elseif p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 then -- 402
			self:triggerOnce("t3_reunion_end", {"D55", "D56", "D65"}, true) -- 406
		end -- 406
	end -- 406
end -- 123
function NarrativeRenderer.prototype.update(self, dt, p, events, interactPressed) -- 411
	if interactPressed == nil then -- 411
		interactPressed = false -- 411
	end -- 411
	self.time = self.time + dt -- 412
	if self.lastRoomKey ~= p.room.key then -- 412
		self:onEnterRoom(p.room.key) -- 414
	end -- 414
	if self.muteCaptionT > 0 then -- 414
		self.muteCaptionT = math.max(0, self.muteCaptionT - dt) -- 417
	end -- 417
	if self.activeLine ~= nil then -- 417
		self.activeLineT = self.activeLineT - dt -- 420
		if self.activeLineT <= 0 then -- 420
			local next = table.remove(self.queuedLines, 1) -- 422
			self.activeLine = next -- 423
			self.activeLineT = next ~= nil and next.duration or 0 -- 424
		end -- 424
	end -- 424
	self:stepScriptedBeats(p, events, interactPressed) -- 427
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-farewell" or p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 429
	local target = wantCinema and 1 or 0 -- 434
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 435
	if p.room.key == "tower" and p.phase ~= "tower-wait" then -- 435
		self.bannerT = 0 -- 439
	end -- 439
	if self.bannerT > 0 then -- 439
		self.bannerT = math.max(0, self.bannerT - dt) -- 442
	end -- 442
	if self.wipeT > 0 then -- 442
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 445
	end -- 445
end -- 411
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 449
	if assistHintsEnabled == nil then -- 449
		assistHintsEnabled = true -- 458
	end -- 458
	if inputMode == nil then -- 458
		inputMode = "kbm" -- 459
	end -- 459
	if gamepadLayout == nil then -- 459
		gamepadLayout = "xbox" -- 460
	end -- 460
	if safe == nil then -- 460
		safe = ZERO_SAFE_INSETS -- 461
	end -- 461
	if self.letterbox > 0.01 then -- 461
		local barH = math.floor(70 * self.letterbox + 0.5) -- 465
		uiDraw:drawRect( -- 466
			Rect(0, h - barH, w, barH), -- 466
			Color(8, 10, 16, 242) -- 466
		) -- 466
		uiDraw:drawRect( -- 467
			Rect(0, 0, w, barH), -- 467
			Color(8, 10, 16, 242) -- 467
		) -- 467
		uiInkDraw:drawSegment( -- 468
			Vec2(0, h - barH), -- 468
			Vec2(w, h - barH), -- 468
			0.7, -- 468
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 468
		) -- 468
		uiInkDraw:drawSegment( -- 469
			Vec2(0, barH), -- 469
			Vec2(w, barH), -- 469
			0.7, -- 469
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 469
		) -- 469
	end -- 469
	if p.room.key == "gate" and p.phase == "gate-count" then -- 469
		self:drawGateCountOverlay( -- 474
			uiDraw, -- 474
			uiInkDraw, -- 474
			art, -- 474
			texts, -- 474
			p, -- 474
			w, -- 474
			h -- 474
		) -- 474
	end -- 474
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 478
	if showRegistry then -- 478
		self:drawTowerRegistryCard( -- 480
			uiDraw, -- 480
			uiInkDraw, -- 480
			uiGlow, -- 480
			art, -- 480
			texts, -- 480
			p, -- 480
			w, -- 480
			h, -- 480
			assistHintsEnabled, -- 480
			inputMode, -- 480
			gamepadLayout -- 480
		) -- 480
	end -- 480
	if not p.paused and not showRegistry then -- 480
		self:drawSubtitleStrip( -- 485
			uiDraw, -- 485
			uiInkDraw, -- 485
			art, -- 485
			texts, -- 485
			p, -- 485
			w, -- 485
			h, -- 485
			assistHintsEnabled, -- 485
			inputMode, -- 485
			gamepadLayout, -- 485
			safe -- 485
		) -- 485
	end -- 485
	if self.bannerT > 0 and not p.paused then -- 485
		self:drawAreaBanner( -- 490
			uiDraw, -- 490
			uiInkDraw, -- 490
			art, -- 490
			texts, -- 490
			p.room.key, -- 490
			w, -- 490
			h -- 490
		) -- 490
	end -- 490
	if self.wipeT > 0.01 then -- 490
		local k = math.min(1, self.wipeT * 1.15) -- 495
		local a = math.floor(255 * k * k + 0.5) -- 496
		uiDraw:drawRect( -- 497
			Rect(0, 0, w, h), -- 497
			Color(9, 11, 17, a) -- 497
		) -- 497
		art:tryPlace( -- 498
			"ink_petal_mist", -- 498
			"wipe_mist", -- 498
			w * 0.5, -- 498
			h * 0.5, -- 498
			w * 0.65, -- 498
			h * 0.65, -- 498
			{ -- 498
				color = toColor(PALETTE.inkMist), -- 499
				opacity = 0.2 * self.wipeT, -- 499
				layer = 5 -- 499
			} -- 499
		) -- 499
	end -- 499
end -- 449
function NarrativeRenderer.prototype.drawCutsceneDialogue(self, uiDraw, uiInkDraw, art, texts, p, w, h, safe) -- 509
	if safe == nil then -- 509
		safe = ZERO_SAFE_INSETS -- 517
	end -- 517
	if p.paused then -- 517
		return -- 520
	end -- 520
	local key = p.room.key -- 522
	local allowDialogue = key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-give") or key == "gate" and p.phase == "gate-wait" or key == "tower" and p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 -- 523
	local cx = w * 0.5 -- 532
	local cy = (key == "gate" and p.phase == "gate-wait" and 68 or 42) + safe.bottom * 0.5 -- 533
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 533
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 536
		local capY = cy + 44 -- 537
		drawSilkVeil( -- 538
			uiDraw, -- 538
			art, -- 538
			"cut_mute_veil", -- 538
			cx, -- 538
			capY, -- 538
			172, -- 538
			26, -- 538
			PALETTE.inkWarm, -- 538
			0.76 * capAlpha, -- 538
			0 -- 538
		) -- 538
		texts:put( -- 539
			"xs", -- 539
			self.muteCaption, -- 539
			cx, -- 539
			capY, -- 539
			toColor(PALETTE.amberCore), -- 539
			0.5, -- 539
			0.5, -- 539
			"Center", -- 539
			1.4, -- 539
			0.94 * capAlpha, -- 539
			0.08 -- 539
		) -- 539
	end -- 539
	if not allowDialogue or self.activeLine == nil then -- 539
		return -- 543
	end -- 543
	local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 545
	local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 548
	local urgent = self.activeLine.urgent == true -- 550
	local hasCue = cue ~= "" -- 551
	local textW = visualTextWidth(spoken, 18) -- 552
	local contentW = textW + (hasCue and 48 or 0) -- 553
	local stripW = math.min( -- 554
		w - 72 - safe.left - safe.right, -- 554
		math.max(500, contentW + 180) -- 554
	) -- 554
	local stripH = 50 -- 555
	drawSilkVeil( -- 557
		uiDraw, -- 557
		art, -- 557
		"cut_sub_veil", -- 557
		cx, -- 557
		cy, -- 557
		stripW, -- 557
		stripH, -- 557
		urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 557
		0.86, -- 557
		2 -- 557
	) -- 557
	drawHairline( -- 558
		uiInkDraw, -- 558
		art, -- 558
		"cut_sub_top", -- 558
		cx, -- 558
		cy + 21, -- 558
		stripW * 0.72, -- 558
		urgent and PALETTE.rouge or PALETTE.silkDim, -- 558
		urgent and 0.72 or 0.52, -- 558
		true, -- 558
		3 -- 558
	) -- 558
	if hasCue then -- 558
		local startX = cx - contentW * 0.5 -- 560
		local cueCol = urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 561
		drawBlossomDot( -- 562
			uiInkDraw, -- 562
			art, -- 562
			"cut_cue_dot", -- 562
			startX + 6, -- 562
			cy - 1, -- 562
			10, -- 562
			cueCol, -- 562
			0.94, -- 562
			4 -- 562
		) -- 562
		texts:put( -- 563
			"xs", -- 563
			cue, -- 563
			startX + 24, -- 563
			cy - 1, -- 563
			toColor(urgent and PALETTE.crimsonCore or cueCol), -- 563
			0.5, -- 563
			0.5, -- 563
			"Center", -- 563
			0, -- 563
			0.96, -- 563
			0.08 -- 563
		) -- 563
		uiInkDraw:drawSegment( -- 564
			Vec2(startX + 38, cy - 8), -- 564
			Vec2(startX + 38, cy + 6), -- 564
			0.75, -- 564
			toColor(PALETTE.silkDim, 115) -- 564
		) -- 564
		texts:put( -- 565
			"sm", -- 565
			spoken, -- 565
			startX + 48, -- 565
			cy - 1, -- 565
			toColor(urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 565
			0, -- 565
			0.5, -- 565
			"Left", -- 565
			0.9, -- 565
			0.98, -- 565
			0.08 -- 565
		) -- 565
	else -- 565
		texts:put( -- 567
			"sm", -- 567
			spoken, -- 567
			cx, -- 567
			cy - 1, -- 567
			toColor(PALETTE.textBright), -- 567
			0.5, -- 567
			0.5, -- 567
			"Center", -- 567
			1, -- 567
			0.98, -- 567
			0.08 -- 567
		) -- 567
	end -- 567
end -- 509
function NarrativeRenderer.prototype.isKeyHintSegment(self, seg) -- 571
	return (string.find(seg, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(seg, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(seg, "限时", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 选", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 1", nil, true) or 0) - 1 >= 0 -- 572
end -- 571
function NarrativeRenderer.prototype.stripKeyHintClause(self, fl) -- 594
	if not self:isKeyHintSegment(fl) then -- 594
		return fl -- 596
	end -- 596
	local parts = __TS__StringSplit(fl, " · ") -- 598
	if #parts <= 1 then -- 598
		return "" -- 600
	end -- 600
	local kept = {} -- 602
	local i = 0 -- 603
	do -- 603
		i = 0 -- 604
		while i < #parts do -- 604
			local seg = __TS__StringTrim(parts[i + 1]) -- 605
			if seg ~= "" and not self:isKeyHintSegment(seg) then -- 605
				kept[#kept + 1] = seg -- 607
			end -- 607
			i = i + 1 -- 604
		end -- 604
	end -- 604
	return table.concat(kept, " · ") -- 610
end -- 594
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 613
	local cx = w * 0.5 -- 626
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 627
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 628
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 628
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 632
		local capY = cy + 44 -- 633
		drawSilkVeil( -- 634
			uiDraw, -- 634
			art, -- 634
			"mute_sfx_veil", -- 634
			cx, -- 634
			capY, -- 634
			172, -- 634
			26, -- 634
			PALETTE.inkWarm, -- 634
			0.76 * capAlpha, -- 634
			0 -- 634
		) -- 634
		texts:put( -- 635
			"xs", -- 635
			self.muteCaption, -- 635
			cx, -- 635
			capY, -- 635
			toColor(PALETTE.amberCore), -- 635
			0.5, -- 635
			0.5, -- 635
			"Center", -- 635
			1.4, -- 635
			0.94 * capAlpha, -- 635
			0.08 -- 635
		) -- 635
	end -- 635
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 638
	if rawLine.text == "" then -- 638
		return -- 640
	end -- 640
	local line = { -- 642
		cue = rawLine.cue, -- 643
		text = assistHintsEnabled and getActiveTarget():adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 644
		urgent = rawLine.urgent -- 645
	} -- 645
	local hasCue = line.cue ~= "" -- 647
	local textW = visualTextWidth(line.text, 18) -- 648
	local contentW = textW + (hasCue and 48 or 0) -- 649
	local stripW = math.min( -- 650
		w - 72 - safe.left - safe.right, -- 650
		math.max(540, contentW + 210) -- 650
	) -- 650
	local stripH = 54 -- 651
	drawSilkVeil( -- 654
		uiDraw, -- 654
		art, -- 654
		"sub_veil", -- 654
		cx, -- 654
		cy, -- 654
		stripW, -- 654
		stripH, -- 654
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 654
		0.84, -- 654
		-1 -- 654
	) -- 654
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 656
	drawHairline( -- 657
		uiInkDraw, -- 657
		art, -- 657
		"sub_top_line", -- 657
		cx, -- 657
		cy + 23, -- 657
		stripW * 0.72, -- 657
		railCol, -- 657
		line.urgent and 0.72 or 0.52, -- 657
		true, -- 657
		2 -- 657
	) -- 657
	if hasCue then -- 657
		local startX = cx - contentW * 0.5 -- 660
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 661
		drawBlossomDot( -- 662
			uiInkDraw, -- 662
			art, -- 662
			"sub_cue_dot", -- 662
			startX + 6, -- 662
			cy - 1, -- 662
			10, -- 662
			cueCol, -- 662
			0.94, -- 662
			4 -- 662
		) -- 662
		texts:put( -- 663
			"xs", -- 663
			line.cue, -- 663
			startX + 24, -- 663
			cy - 1, -- 663
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 663
			0.5, -- 663
			0.5, -- 663
			"Center", -- 663
			0, -- 663
			0.96, -- 663
			0.08 -- 663
		) -- 663
		uiInkDraw:drawSegment( -- 664
			Vec2(startX + 38, cy - 8), -- 664
			Vec2(startX + 38, cy + 6), -- 664
			0.75, -- 664
			toColor(PALETTE.silkDim, 115) -- 664
		) -- 664
		texts:put( -- 665
			"sm", -- 665
			line.text, -- 665
			startX + 48, -- 665
			cy - 1, -- 665
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 665
			0, -- 665
			0.5, -- 665
			"Left", -- 665
			0.9, -- 665
			0.98, -- 665
			0.08 -- 665
		) -- 665
	else -- 665
		texts:put( -- 667
			"sm", -- 667
			line.text, -- 667
			cx, -- 667
			cy - 1, -- 667
			toColor(PALETTE.textBright), -- 667
			0.5, -- 667
			0.5, -- 667
			"Center", -- 667
			1, -- 667
			0.98, -- 667
			0.08 -- 667
		) -- 667
	end -- 667
end -- 613
function NarrativeRenderer.prototype.granaryCue(self, p, showKeys) -- 672
	local ____p_1 = p -- 673
	local player = ____p_1.player -- 673
	local room = ____p_1.room -- 673
	if p.cartDocked then -- 673
		if p.run.c2Latch then -- 673
			local ____opt_2 = room.campaign -- 673
			local exit = ____opt_2 and ____opt_2.exitX -- 676
			if exit ~= nil and player.x >= exit then -- 676
				return "在棚口等小满跟上" -- 677
			end -- 677
			return "带小满沿中道往右出棚" -- 678
		end -- 678
		return showKeys and "到轮窝右边的中道，靠近连杆按 [E] 抬闩" or "到轮窝右边的中道，靠近连杆抬闩" -- 680
	end -- 680
	if p.gripping then -- 680
		return "往右把车推入轮窝" -- 682
	end -- 682
	if p:cartHandleInReach() then -- 682
		return showKeys and "按 [E] 握车柄，再往右推车" or "握住车柄，往右推车" -- 683
	end -- 683
	local ____opt_4 = room.companion -- 683
	local bypass = ____opt_4 and ____opt_4.groundBypass -- 685
	if bypass ~= nil and player.x - player.w / 2 < bypass.x1 then -- 685
		if player.x + player.w / 2 <= bypass.x0 then -- 685
			return "从远处绕到粮袋后面，再往右走" -- 687
		end -- 687
		return "沿粮袋后面往右走，过了矮台再回到中道" -- 688
	end -- 688
	local track = room.cart.depth or 0 -- 690
	if not inReachDepth(player.depth, track) then -- 690
		return player.depth > track and "往近处回到中道，找板车左侧的车柄" or "往远处回到中道，找板车左侧的车柄" -- 692
	end -- 692
	local handleX = p.cartAxle + room.cart.handleOffset -- 694
	if math.abs(player.x - handleX) <= CART_REACH then -- 694
		return "落到地面，靠近车柄" -- 695
	end -- 695
	return player.x < handleX and "往右走到车柄旁" or "往左回到车柄旁" -- 696
end -- 672
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 700
	local key = p.room.key -- 701
	local theme = themeOf(key) -- 702
	if key == "gate" and p.phase == "gate-count" then -- 702
		if p.countTick >= GATE_COUNT_END then -- 702
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 706
		end -- 706
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 712
	end -- 712
	if not assistHintsEnabled then -- 712
		if self.activeLine ~= nil then -- 712
			local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 718
			local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 721
			return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 723
		end -- 723
		if key == "prologue" and p.phase == "prologue-give" then -- 723
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 726
		end -- 726
		if key == "checkpoint" and p.escort.state == "calming" then -- 726
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 729
		end -- 729
		if key == "tower" then -- 729
			if p.phase == "tower-knock" then -- 729
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 733
			end -- 733
			if p.phase == "tower-given" then -- 733
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 736
			end -- 736
		end -- 736
		if p.flash ~= "" and p.flashT > 0 and p.flash ~= "翻滚结束" then -- 736
			local cleanFlash = self:stripKeyHintClause(p.flash) -- 741
			if cleanFlash ~= "" then -- 741
				local isDanger = (string.find(cleanFlash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "追", nil, true) or 0) - 1 >= 0 -- 743
				local text = cleanFlash -- 744
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 745
				if key == "tower" or key == "prologue" then -- 745
					cue = "" -- 747
				end -- 747
				if text == "命中" then -- 747
					text = "倭寇击倒" -- 750
				elseif text == "打空" then -- 750
					text = "铅丸偏离或被掩体阻挡" -- 752
				elseif text == "翻滚" then -- 752
					text = "伏身滑铲" -- 754
				end -- 754
				return {cue = cue, text = text, urgent = isDanger} -- 756
			end -- 756
		end -- 756
		if key == "c2-granary" then -- 756
			return { -- 760
				cue = "", -- 760
				text = self:granaryCue(p, false), -- 760
				urgent = false -- 760
			} -- 760
		end -- 760
		if p.childMode and key == "outside" and p.checkpoint < p.room.arch.x1 then -- 760
			local text = not p.cartDocked and "红布车右边伸着车柄，前面是个空车窝。" or (p.player.y > p.room.arch.y + 1 and "车轮落进窝里，左边的石阶通向拱下。" or "拱下的铁栓收起来了，伏低身子就能过去。") -- 763
			return {cue = "", text = text, urgent = false} -- 766
		end -- 766
		if p.childMode and key == "tower" then -- 766
			if p.phase == "tower-wait" then -- 766
				return {cue = "", text = "木门里透出灯光。她还记得那两声叩门。", urgent = false} -- 769
			end -- 769
			if p.phase == "tower-enter" then -- 769
				return {cue = "", text = "守卒让开门槛，值夜桌上摊着登记簿。", urgent = false} -- 770
			end -- 770
			if p.phase == "tower-desk" then -- 770
				return {cue = "", text = "守卒伸过手来，等她放下针套、指南针和纸条。", urgent = false} -- 771
			end -- 771
		end -- 771
		return {cue = "", text = "", urgent = false} -- 773
	end -- 773
	if key == "gate" and p.phase == "gate-hold" then -- 773
		local threatened = false -- 777
		local hasAliveEnemy = false -- 778
		local i = 0 -- 779
		do -- 779
			i = 0 -- 780
			while i < #p.enemies do -- 780
				if p.enemies[i + 1].alive then -- 780
					hasAliveEnemy = true -- 782
					if p.enemies[i + 1].warnT > 0 then -- 782
						threatened = true -- 784
					end -- 784
				end -- 784
				i = i + 1 -- 780
			end -- 780
		end -- 780
		if threatened then -- 780
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 789
		end -- 789
		if p.coverHug then -- 789
			if hasAliveEnemy and not p.coverBlocking then -- 789
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 793
			end -- 793
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 795
		end -- 795
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 797
	end -- 797
	if key == "gate" and p.phase == "gate-count" then -- 797
		if p.countTick >= GATE_COUNT_END then -- 797
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 802
		end -- 802
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 808
	end -- 808
	if self.activeLine ~= nil then -- 808
		local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 812
		local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 815
		return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 817
	end -- 817
	if p.flash ~= "" and p.flashT > 0 and p.flash ~= "翻滚结束" then -- 817
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 821
		local text = p.flash -- 822
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 823
		if key == "tower" or key == "prologue" then -- 823
			cue = "" -- 825
		end -- 825
		if text == "命中" then -- 825
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 828
		elseif text == "打空" then -- 828
			text = "铅丸偏离或被掩体阻挡" -- 830
		elseif text == "翻滚" then -- 830
			text = "伏身滑铲" -- 832
		end -- 832
		return {cue = cue, text = text, urgent = isDanger} -- 834
	end -- 834
	if key == "prologue" then -- 834
		if p.phase == "prologue-wait" then -- 834
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 839
		end -- 839
		if p.phase == "prologue-give" then -- 839
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 842
		end -- 842
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 844
	end -- 844
	if key == "street" then -- 844
		local alive = 0 -- 848
		local i = 0 -- 849
		do -- 849
			i = 0 -- 850
			while i < #p.enemies do -- 850
				if p.enemies[i + 1].alive then -- 850
					alive = alive + 1 -- 851
				end -- 851
				i = i + 1 -- 850
			end -- 850
		end -- 850
		if alive > 0 then -- 850
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 854
		end -- 854
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 856
	end -- 856
	if key == "c2-granary" then -- 856
		return { -- 860
			cue = "", -- 860
			text = self:granaryCue(p, true), -- 860
			urgent = false -- 860
		} -- 860
	end -- 860
	if key == "checkpoint" then -- 860
		if p.escort.state == "frozen" then -- 860
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 865
		end -- 865
		if p.escort.state == "calming" then -- 865
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 868
		end -- 868
		if not p.cartDocked then -- 868
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 871
		end -- 871
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 873
	end -- 873
	if key == "gate" then -- 873
		if p.phase == "gate-idle" then -- 873
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 878
		end -- 878
		if p.phase == "gate-send" then -- 878
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 885
		end -- 885
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 887
	end -- 887
	if key == "outside" then -- 887
		if not p.cartDocked then -- 887
			if p.gripping or p:cartHandleInReach() then -- 887
				return {cue = "", text = "按住 [E]+[D]，把红布车拉进右侧车窝", urgent = false} -- 893
			end -- 893
			local text = p.player.y < p.room.cart.baseY - 25 and "沿左侧石阶上台，去找红布车右柄" or (p.player.x > p.cartAxle + p.room.cart.handleOffset and "向左走回红布车右柄" or "向右走到红布车的右柄") -- 895
			return {cue = "", text = text, urgent = false} -- 898
		end -- 898
		if p.checkpoint < p.room.arch.x1 then -- 898
			local text = p.player.y > p.room.arch.y + 1 and "车轮落窝了。往左返回石阶，下到地面" or "在石阶底按住 [CTRL]，蹲着向右穿过矮拱" -- 901
			return {cue = "潜", text = text, urgent = false} -- 904
		end -- 904
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 906
	end -- 906
	if key == "village" then -- 906
		if p.scavChase then -- 906
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 911
		end -- 911
		if p.passed then -- 911
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 914
		end -- 914
		if p.hasBottle then -- 914
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 917
		end -- 917
		if p.bottleFly ~= nil then -- 917
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 920
		end -- 920
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 920
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 923
		end -- 923
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 925
	end -- 925
	if key == "forest" then -- 925
		if p.dogState == "chase" then -- 925
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 930
		end -- 930
		if p.dogState == "ear" then -- 930
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 933
		end -- 933
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 935
	end -- 935
	if key == "tower" then -- 935
		if p.phase == "tower-wait" then -- 935
			return {cue = "", text = "走到木门前，按 [E] 叩门", urgent = false} -- 940
		end -- 940
		if p.phase == "tower-knock" then -- 940
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 943
		end -- 943
		if p.phase == "tower-enter" then -- 943
			return {cue = "", text = "门开了。向右跨过门槛，走到值夜桌前", urgent = false} -- 946
		end -- 946
		if p.phase == "tower-desk" then -- 946
			return {cue = "", text = "走到值夜桌前，按住 [E] 交出针套、指南针和纸条", urgent = false} -- 949
		end -- 949
		if p.phase == "tower-given" then -- 949
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 952
		end -- 952
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 954
	end -- 954
	return {cue = "", text = theme.introWhisper, urgent = false} -- 957
end -- 700
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 960
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 969
	local countNum = gateCountAtTick(p.countTick) -- 970
	uiDraw:drawRect( -- 971
		Rect(0, 0, w, h), -- 971
		Color( -- 971
			7, -- 971
			9, -- 971
			15, -- 971
			math.floor(78 + frac * 116 + 0.5) -- 971
		) -- 971
	) -- 971
	local cy = h * 0.56 -- 973
	art:tryPlace( -- 974
		"ink_petal_mist", -- 974
		"gate_count_mist", -- 974
		w * 0.5, -- 974
		cy, -- 974
		290, -- 974
		220, -- 974
		{ -- 974
			color = toColor(PALETTE.inkMist), -- 975
			opacity = 0.34 + frac * 0.2, -- 975
			layer = 0 -- 975
		} -- 975
	) -- 975
	drawMistCurve( -- 977
		art, -- 977
		"gate_count_wisp", -- 977
		w * 0.5, -- 977
		cy - 8, -- 977
		420, -- 977
		76, -- 977
		PALETTE.jadeMist, -- 977
		0.22, -- 977
		0 -- 977
	) -- 977
	local numZh = toChineseUpper(countNum) -- 979
	texts:put( -- 980
		"title", -- 980
		numZh, -- 980
		w * 0.5, -- 980
		cy + 8, -- 980
		toColor(PALETTE.textBright), -- 980
		0.5, -- 980
		0.5, -- 980
		"Center", -- 980
		12, -- 980
		0.42 + frac * 0.56, -- 980
		0.1 -- 980
	) -- 980
	drawHairline( -- 981
		uiInkDraw, -- 981
		art, -- 981
		"gate_count_div", -- 981
		w * 0.5, -- 981
		cy - 34, -- 981
		240, -- 981
		PALETTE.silkDim, -- 981
		0.62, -- 981
		true, -- 981
		2 -- 981
	) -- 981
	texts:put( -- 982
		"sm", -- 982
		"城外静候 · 默数至二十", -- 982
		w * 0.5, -- 982
		cy - 58, -- 982
		toColor(PALETTE.textMid), -- 982
		0.5, -- 982
		0.5, -- 982
		"Center", -- 982
		3.4, -- 982
		0.84, -- 982
		0.08 -- 982
	) -- 982
end -- 960
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 992
	local cardW = 588 -- 1005
	local cardH = 382 -- 1006
	local cx = (w - cardW) * 0.5 -- 1007
	local cy = (h - cardH) * 0.5 + 10 -- 1008
	local midX = w * 0.5 -- 1009
	local midY = cy + cardH * 0.5 -- 1010
	uiDraw:drawRect( -- 1013
		Rect(0, 0, w, h), -- 1013
		Color(7, 9, 15, 174) -- 1013
	) -- 1013
	art:tryPlace( -- 1014
		"ink_frame_mask", -- 1014
		"reg_shadow", -- 1014
		midX, -- 1014
		midY - 6, -- 1014
		cardW + 58, -- 1014
		cardH + 50, -- 1014
		{ -- 1014
			color = toColor(PALETTE.voidDark), -- 1015
			opacity = 0.82, -- 1015
			layer = -1 -- 1015
		} -- 1015
	) -- 1015
	if not art:tryPlace( -- 1015
		"ink_song_paper", -- 1019
		"registry_song_paper", -- 1019
		midX, -- 1019
		midY, -- 1019
		cardW, -- 1019
		cardH, -- 1019
		{opacity = 0.98, layer = 1} -- 1019
	) then -- 1019
		uiDraw:drawRect( -- 1020
			Rect(cx, cy, cardW, cardH), -- 1020
			toColor(PALETTE.xuanPaper, 246), -- 1020
			1, -- 1020
			toColor(PALETTE.silkDim, 180) -- 1020
		) -- 1020
	end -- 1020
	fillRadialGlow( -- 1022
		uiGlow, -- 1022
		midX, -- 1022
		midY + 46, -- 1022
		240, -- 1022
		130, -- 1022
		Color(235, 224, 202, 14), -- 1022
		Color(235, 224, 202, 0), -- 1022
		14 -- 1022
	) -- 1022
	local padX = 46 -- 1025
	local padY = 36 -- 1026
	local inX = cx + padX -- 1027
	local inY = cy + padY -- 1028
	local inW = cardW - padX * 2 -- 1029
	local inH = cardH - padY * 2 -- 1030
	local redSilk = toColor(PALETTE.rouge, 118) -- 1031
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 1032
	uiInkDraw:drawRect( -- 1034
		Rect(inX, inY, inW, inH), -- 1034
		Color(0, 0, 0, 0), -- 1034
		0.9, -- 1034
		redSilk -- 1034
	) -- 1034
	uiInkDraw:drawRect( -- 1035
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 1035
		Color(0, 0, 0, 0), -- 1035
		0.55, -- 1035
		redSilkFaint -- 1035
	) -- 1035
	local headY = inY + inH - 28 -- 1038
	texts:put( -- 1039
		"md", -- 1039
		"北塔入塔登记簿 · 末页", -- 1039
		inX + 20, -- 1039
		headY, -- 1039
		toColor(PALETTE.xuanInk), -- 1039
		0, -- 1039
		0.5, -- 1039
		"Left", -- 1039
		2.4, -- 1039
		0.94, -- 1039
		0 -- 1039
	) -- 1039
	texts:put( -- 1040
		"xs", -- 1040
		"守望行记", -- 1040
		inX + inW - 20, -- 1040
		headY, -- 1040
		toColor(PALETTE.xuanInkSub), -- 1040
		1, -- 1040
		0.5, -- 1040
		"Right", -- 1040
		2, -- 1040
		0.78, -- 1040
		0 -- 1040
	) -- 1040
	uiInkDraw:drawSegment( -- 1041
		Vec2(inX + 14, headY - 22), -- 1041
		Vec2(inX + inW - 14, headY - 22), -- 1041
		0.85, -- 1041
		redSilk -- 1041
	) -- 1041
	local reunion = #p.endingLines >= 2 and p.endingLines[2] ~= "" or p.storyRoute == "soldier" -- 1044
	local row1Y = headY - 56 -- 1045
	texts:put( -- 1046
		"sm", -- 1046
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 1046
		inX + 20, -- 1046
		row1Y, -- 1046
		toColor(PALETTE.xuanInk), -- 1046
		0, -- 1046
		0.5, -- 1046
		"Left", -- 1046
		0.8, -- 1046
		0.94, -- 1046
		0 -- 1046
	) -- 1046
	texts:put( -- 1047
		"xs", -- 1048
		reunion and "附注：兄妹并肩抵塔；怀铜针、手书一纸。" or (("附注：" .. NEEDLE_NOTE_LINES[1]) .. " —— ") .. NEEDLE_NOTE_LINES[2], -- 1049
		inX + 20, -- 1050
		row1Y - 28, -- 1051
		toColor(PALETTE.xuanInkSub), -- 1052
		0, -- 1053
		0.5, -- 1054
		"Left", -- 1055
		0.6, -- 1056
		0.88, -- 1057
		0 -- 1058
	) -- 1058
	uiInkDraw:drawSegment( -- 1060
		Vec2(inX + 16, row1Y - 48), -- 1060
		Vec2(inX + inW - 16, row1Y - 48), -- 1060
		0.65, -- 1060
		redSilkFaint -- 1060
	) -- 1060
	local blankY = row1Y - 80 -- 1063
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 1064
	if reunion then -- 1064
		texts:put( -- 1066
			"sm", -- 1066
			"肆拾贰   周戍 · 兄妹同行 · 已入塔", -- 1066
			inX + 20, -- 1066
			blankY, -- 1066
			toColor(PALETTE.xuanInk), -- 1066
			0, -- 1066
			0.5, -- 1066
			"Left", -- 1066
			0.8, -- 1066
			0.94, -- 1066
			0 -- 1066
		) -- 1066
		texts:put( -- 1067
			"xs", -- 1067
			"附注：门内断后脱身，同抵北塔值夜室。", -- 1067
			inX + 20, -- 1067
			blankY - 26, -- 1067
			toColor(PALETTE.xuanInkSub), -- 1067
			0, -- 1067
			0.5, -- 1067
			"Left", -- 1067
			0.6, -- 1067
			0.86, -- 1067
			0 -- 1067
		) -- 1067
	else -- 1067
		texts:put( -- 1069
			"sm", -- 1069
			"肆拾贰", -- 1069
			inX + 20, -- 1069
			blankY, -- 1069
			toColor(PALETTE.rouge), -- 1069
			0, -- 1069
			0.5, -- 1069
			"Left", -- 1069
			1, -- 1069
			0.92, -- 1069
			0 -- 1069
		) -- 1069
		uiInkDraw:drawSegment( -- 1070
			Vec2(inX + 94, blankY - 7), -- 1070
			Vec2(inX + inW - 116, blankY - 7), -- 1070
			0.95, -- 1070
			toColor(PALETTE.xuanInkSub, 155 * pulse) -- 1070
		) -- 1070
		texts:put( -- 1071
			"xs", -- 1071
			"（空行留待）", -- 1071
			inX + inW - 104, -- 1071
			blankY, -- 1071
			toColor(PALETTE.xuanInkSub), -- 1071
			0, -- 1071
			0.5, -- 1071
			"Left", -- 1071
			1, -- 1071
			0.82 * pulse, -- 1071
			0 -- 1071
		) -- 1071
	end -- 1071
	if p.phase == "tower-end" then -- 1071
		local signY = inY + 46 -- 1076
		texts:put( -- 1077
			"banner", -- 1077
			"向西守望", -- 1077
			midX - 18, -- 1077
			signY, -- 1077
			toColor(PALETTE.xuanInk), -- 1077
			0.5, -- 1077
			0.5, -- 1077
			"Center", -- 1077
			6.5, -- 1077
			0.92, -- 1077
			0 -- 1077
		) -- 1077
		drawLoneSeal( -- 1078
			uiInkDraw, -- 1078
			art, -- 1078
			texts, -- 1078
			"reg_lone_seal", -- 1078
			midX + 86, -- 1078
			signY, -- 1078
			22, -- 1078
			42, -- 1078
			"守", -- 1078
			"望", -- 1078
			PALETTE.sealRed, -- 1078
			PALETTE.sealText, -- 1078
			0.92, -- 1078
			4 -- 1078
		) -- 1078
		drawSilkVeil( -- 1080
			uiDraw, -- 1080
			art, -- 1080
			"reg_hint_veil", -- 1080
			midX, -- 1080
			cy - 28, -- 1080
			390, -- 1080
			32, -- 1080
			PALETTE.inkWash, -- 1080
			0.72, -- 1080
			0 -- 1080
		) -- 1080
		local rawEndHint = assistHintsEnabled and (inputMode == "kbm" and "按 E / 左键继续     ·     Esc 暂歇" or "按 E 再次启程     ·     Esc 暂歇") or "Esc 暂歇" -- 1081
		local endHint = getActiveTarget():adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 1084
		texts:put( -- 1085
			"xs", -- 1085
			endHint, -- 1085
			midX, -- 1085
			cy - 28, -- 1085
			toColor(PALETTE.textMid), -- 1085
			0.5, -- 1085
			0.5, -- 1085
			"Center", -- 1085
			1.6, -- 1085
			0.92, -- 1085
			0.08 -- 1085
		) -- 1085
	end -- 1085
end -- 992
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 1089
	local theme = themeOf(roomKey) -- 1098
	local t = self.bannerT / self.bannerMax -- 1099
	local alpha = 1 -- 1100
	if t > 0.82 then -- 1100
		alpha = (1 - t) / 0.18 -- 1102
	elseif t < 0.28 then -- 1102
		alpha = t / 0.28 -- 1104
	end -- 1104
	local cx = w * 0.5 -- 1106
	local cy = h * 0.77 -- 1107
	local spread = math.min(1, alpha * 1.15) -- 1108
	drawSilkVeil( -- 1111
		uiDraw, -- 1111
		art, -- 1111
		"banner_veil", -- 1111
		cx, -- 1111
		cy - 2, -- 1111
		480 * spread + 100, -- 1111
		92, -- 1111
		PALETTE.inkWash, -- 1111
		0.76 * alpha, -- 1111
		-1 -- 1111
	) -- 1111
	drawMistCurve( -- 1112
		art, -- 1112
		"banner_mist", -- 1112
		cx, -- 1112
		cy + 4, -- 1112
		460 * spread, -- 1112
		72, -- 1112
		theme.accent, -- 1112
		0.28 * alpha, -- 1112
		0 -- 1112
	) -- 1112
	drawHairline( -- 1113
		uiInkDraw, -- 1113
		art, -- 1113
		"banner_line", -- 1113
		cx, -- 1113
		cy - 16, -- 1113
		320 * spread, -- 1113
		PALETTE.silkLine, -- 1113
		0.64 * alpha, -- 1113
		false, -- 1113
		2 -- 1113
	) -- 1113
	local sep = " · " -- 1116
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 1117
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 1118
	if theme.backdropKey ~= nil then -- 1118
		texts:put( -- 1120
			"lg", -- 1120
			theme.titleZh, -- 1120
			cx, -- 1120
			cy + 14, -- 1120
			toColor(PALETTE.textBright), -- 1120
			0.5, -- 1121
			0.5, -- 1121
			"Center", -- 1121
			1, -- 1121
			alpha, -- 1121
			0.1 -- 1121
		) -- 1121
	elseif idx > 0 then -- 1121
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 1123
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 1124
		local lw = visualTextWidth(leftPart, 42) -- 1125
		local rw = visualTextWidth(rightPart, 42) -- 1126
		local dotGap = 28 -- 1127
		local totalW = lw + rw + dotGap -- 1128
		local leftEdge = cx - totalW * 0.5 -- 1129
		local dotX = leftEdge + lw + dotGap * 0.5 -- 1130
		texts:put( -- 1132
			"banner", -- 1132
			leftPart, -- 1132
			leftEdge, -- 1132
			cy + 14, -- 1132
			toColor(PALETTE.textBright), -- 1132
			0, -- 1132
			0.5, -- 1132
			"Left", -- 1132
			2, -- 1132
			alpha, -- 1132
			0.1 -- 1132
		) -- 1132
		drawBlossomDot( -- 1133
			uiInkDraw, -- 1133
			art, -- 1133
			"banner_mid_dot", -- 1133
			dotX, -- 1133
			cy + 12, -- 1133
			11, -- 1133
			dotCol, -- 1133
			0.92 * alpha, -- 1133
			4 -- 1133
		) -- 1133
		texts:put( -- 1134
			"banner", -- 1134
			rightPart, -- 1134
			dotX + dotGap * 0.5, -- 1134
			cy + 14, -- 1134
			toColor(PALETTE.textBright), -- 1134
			0, -- 1134
			0.5, -- 1134
			"Left", -- 1134
			2, -- 1134
			alpha, -- 1134
			0.1 -- 1134
		) -- 1134
	else -- 1134
		texts:put( -- 1136
			"banner", -- 1136
			theme.titleZh, -- 1136
			cx, -- 1136
			cy + 14, -- 1136
			toColor(PALETTE.textBright), -- 1136
			0.5, -- 1136
			0.5, -- 1136
			"Center", -- 1136
			3, -- 1136
			alpha, -- 1136
			0.1 -- 1136
		) -- 1136
	end -- 1136
	texts:put( -- 1138
		"xs", -- 1138
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 1138
		cx, -- 1138
		cy - 34, -- 1138
		toColor(PALETTE.textMid), -- 1138
		0.5, -- 1138
		0.5, -- 1138
		"Center", -- 1138
		2.2, -- 1138
		0.82 * alpha, -- 1138
		0.08 -- 1138
	) -- 1138
end -- 1089
return ____exports -- 1089