-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 21
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 21
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
	self.lastCartDocked = false -- 55
	self.lastEscortCalming = false -- 56
	self.lastFlashSeen = "" -- 57
	self.muteCaption = "" -- 59
	self.muteCaptionT = 0 -- 60
end -- 38
function NarrativeRenderer.prototype.onEnterRoom(self, roomKey) -- 62
	self.lastRoomKey = roomKey -- 63
	self.bannerT = self.bannerMax -- 64
	self.wipeT = 1 -- 65
	self.activeLine = nil -- 66
	self.activeLineT = 0 -- 67
	self.queuedLines = {} -- 68
	self.triggeredBeats = {} -- 69
	self.lastS2BoardOpen = false -- 70
	self.lastCartDocked = false -- 71
	self.lastEscortCalming = false -- 72
	self.lastFlashSeen = "" -- 73
	self.muteCaption = "" -- 74
	self.muteCaptionT = 0 -- 75
end -- 62
function NarrativeRenderer.prototype.getActiveDialogue(self) -- 79
	return {id = self.activeLine ~= nil and self.activeLine.id or "", who = self.activeLine ~= nil and self.activeLine.who or "", text = self.activeLine ~= nil and self.activeLine.text or "", muteCaption = self.muteCaptionT > 0 and self.muteCaption or ""} -- 80
end -- 79
function NarrativeRenderer.prototype.triggerOnce(self, beatKey, lineIds, replaceCurrent) -- 88
	if replaceCurrent == nil then -- 88
		replaceCurrent = false -- 88
	end -- 88
	if self.triggeredBeats[beatKey] then -- 88
		return -- 90
	end -- 90
	self.triggeredBeats[beatKey] = true -- 92
	if replaceCurrent then -- 92
		self.activeLine = nil -- 94
		self.activeLineT = 0 -- 95
		self.queuedLines = {} -- 96
	end -- 96
	local i = 0 -- 98
	do -- 98
		i = 0 -- 99
		while i < #lineIds do -- 99
			local d = dialogueById(lineIds[i + 1]) -- 100
			if d ~= nil then -- 100
				if self.activeLine == nil then -- 100
					self.activeLine = d -- 103
					self.activeLineT = d.duration -- 104
				else -- 104
					local ____self_queuedLines_0 = self.queuedLines -- 104
					____self_queuedLines_0[#____self_queuedLines_0 + 1] = d -- 106
				end -- 106
			end -- 106
			i = i + 1 -- 99
		end -- 99
	end -- 99
end -- 88
function NarrativeRenderer.prototype.showMuteCaption(self, key, duration) -- 112
	if duration == nil then -- 112
		duration = 1.9 -- 112
	end -- 112
	local txt = MUTE_SFX_CAPTIONS[key] -- 113
	if txt ~= nil and txt ~= "" then -- 113
		self.muteCaption = txt -- 115
		self.muteCaptionT = duration -- 116
	end -- 116
end -- 112
function NarrativeRenderer.prototype.stepScriptedBeats(self, p, events, interactPressed) -- 120
	if interactPressed == nil then -- 120
		interactPressed = false -- 120
	end -- 120
	local key = p.room.key -- 121
	local ox = p.ox -- 122
	local px = p.player.x -- 123
	if events ~= nil then -- 123
		if events.knockPulse then -- 123
			self:showMuteCaption("knockTwo", 1.8) -- 128
		end -- 128
		if events.cartJustDocked then -- 128
			self:showMuteCaption("cartDock", 2) -- 131
		end -- 131
		if events.bottleLanded then -- 131
			local isBasin = (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 -- 134
			self:showMuteCaption(isBasin and "basinRing" or "brickClink", 2) -- 135
		end -- 135
		local ei = 0 -- 137
		do -- 137
			ei = 0 -- 138
			while ei < #events.rawEvents do -- 138
				local ev = events.rawEvents[ei + 1] -- 139
				if ev.name == "storyBeat" and ev.data.beat == "tower_door" then -- 139
					self:showMuteCaption("knockReply", 2) -- 141
				end -- 141
				ei = ei + 1 -- 138
			end -- 138
		end -- 138
	end -- 138
	if p.flash ~= "" and p.flash ~= self.lastFlashSeen then -- 138
		self.lastFlashSeen = p.flash -- 146
		if (string.find(p.flash, "枯枝", nil, true) or 0) - 1 >= 0 then -- 146
			self:showMuteCaption("twigSnap", 1.8) -- 148
		elseif (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 then -- 148
			self:showMuteCaption("basinRing", 1.8) -- 150
		elseif (string.find(p.flash, "砖", nil, true) or 0) - 1 >= 0 and key == "village" then -- 150
			self:showMuteCaption("brickClink", 1.8) -- 152
		end -- 152
	end -- 152
	local calmingNow = p.escort.state == "calming" -- 157
	if calmingNow and not self.lastEscortCalming then -- 157
		self:showMuteCaption("knockTwo", 2) -- 159
		self.triggeredBeats.calming_d04 = false -- 160
		self:triggerOnce("calming_d04", {"D04"}, true) -- 161
	end -- 161
	self.lastEscortCalming = calmingNow -- 163
	if key == "prologue" then -- 163
		if p.phase == "prologue-wake" then -- 163
			self:triggerOnce("p0_wake", {"D30", "D31", "D32"}, true) -- 168
		elseif p.phase == "prologue-shadow" or p.phase == "prologue-escape" then -- 168
			self:triggerOnce("p0_shadow", {"D33", "D34"}, true) -- 170
		elseif p.phase == "prologue-wait" then -- 170
			self:triggerOnce("p1_call", {"D35", "D36"}, true) -- 172
		elseif p.phase == "prologue-give" then -- 172
			self:triggerOnce("p2_give", { -- 174
				"D01", -- 174
				"D02", -- 174
				"D03", -- 174
				"D37", -- 174
				"D38" -- 174
			}, true) -- 174
		elseif p.phase == "prologue-follow" then -- 174
			if px >= ox + 400 then -- 174
				self:triggerOnce("p3_well", {"D21", "D22", "D39"}) -- 177
			else -- 177
				self:triggerOnce("p2_wall", {"D57", "D58"}) -- 179
			end -- 179
			if interactPressed and px <= ox + 175 and math.abs(p.player.y) < 20 then -- 179
				self:triggerOnce("opt_pinwheel", {"OPT_PINWHEEL"}, true) -- 183
			end -- 183
		end -- 183
		return -- 186
	end -- 186
	if key == "s1-crossroad" then -- 186
		if px < ox + 260 then -- 186
			self:triggerOnce("s1_standoff", {"D23", "D24", "D40", "D41"}) -- 191
		elseif px >= ox + 360 and self.activeLine ~= nil and self.activeLine.id == "D23" then -- 191
			self.activeLine = nil -- 194
			self.activeLineT = 0 -- 195
			self.queuedLines = {} -- 196
		end -- 196
		return -- 198
	end -- 198
	if key == "s2-drygoods" then -- 198
		local boardOpen = false -- 202
		local bi = 0 -- 203
		do -- 203
			bi = 0 -- 204
			while bi < #p.boxes do -- 204
				if p.boxes[bi + 1].id == "s2_board_cover" and not p.boxes[bi + 1].hidden then -- 204
					boardOpen = true -- 206
					break -- 207
				end -- 207
				bi = bi + 1 -- 204
			end -- 204
		end -- 204
		if not boardOpen and px >= ox + 290 and px <= ox + 520 then -- 204
			self:triggerOnce("s2_hint_board", {"D05"}) -- 211
		end -- 211
		if boardOpen and not self.lastS2BoardOpen then -- 211
			self:showMuteCaption("boardDrop", 2) -- 214
			self:triggerOnce("s2_board_drop", {"D42"}, true) -- 215
		end -- 215
		if boardOpen and interactPressed and px >= ox + 470 and px <= ox + 640 and math.abs(p.player.y) < 20 then -- 215
			self:triggerOnce("opt_shadowdisc", {"OPT_SHADOWDISC"}, true) -- 219
		end -- 219
		self.lastS2BoardOpen = boardOpen -- 221
		return -- 222
	end -- 222
	if key == "s3-archway" then -- 222
		if px >= ox + 660 and p.partner.alive and math.abs(p.partner.x - px) <= 150 then -- 222
			self:triggerOnce("s3_rejoin", {"D06"}) -- 227
		end -- 227
		return -- 229
	end -- 229
	if key == "c2-granary" then -- 229
		if not p.cartDocked and px >= ox + 260 then -- 229
			self:triggerOnce("c2_groove", {"D07", "D43"}) -- 234
		end -- 234
		if p.cartDocked and not self.lastCartDocked then -- 234
			self:showMuteCaption("latchOpen", 2) -- 237
			self:triggerOnce("c2_docked", {"D08"}, true) -- 238
		end -- 238
		self.lastCartDocked = p.cartDocked -- 240
		return -- 241
	end -- 241
	if key == "gate" then -- 241
		if p.phase == "gate-idle" then -- 241
			self:triggerOnce("g1_winch", { -- 246
				"D09", -- 246
				"D44", -- 246
				"D45", -- 246
				"D59", -- 246
				"D60" -- 246
			}) -- 246
		elseif p.phase == "gate-hold" then -- 246
			if self.activeLine ~= nil then -- 246
				self.activeLine = nil -- 250
				self.activeLineT = 0 -- 251
				self.queuedLines = {} -- 252
			end -- 252
		elseif p.phase == "gate-send" then -- 252
			self:triggerOnce("g3_farewell", { -- 255
				"D10", -- 255
				"D61", -- 255
				"D62", -- 255
				"D46", -- 255
				"D47", -- 255
				"D12" -- 255
			}, true) -- 255
		elseif p.phase == "gate-wait" then -- 255
			self:triggerOnce("g4_reunion_call", {"D48", "D49", "D50"}, true) -- 257
		end -- 257
		return -- 259
	end -- 259
	if key == "gatepath" then -- 259
		self:triggerOnce("g06_north", {"G06A", "G06B", "D51", "D52"}) -- 263
		return -- 264
	end -- 264
	if key == "escort1" then -- 264
		if px >= ox + 170 and px <= ox + 460 then -- 264
			self:triggerOnce("e1_start", {"E1A", "E1B"}) -- 270
		end -- 270
		return -- 272
	end -- 272
	if key == "escort2" then -- 272
		if px >= ox + 220 and px <= ox + 520 then -- 272
			self:triggerOnce("e2_granary", {"E2A", "E2B"}) -- 277
		end -- 277
		return -- 279
	end -- 279
	if key == "escort3" then -- 279
		if px >= ox + 440 and px <= ox + 710 then -- 279
			self:triggerOnce("e3_bench_rest", {"E3A", "E3B"}) -- 284
		end -- 284
		if events ~= nil and events.benchCrafted then -- 284
			self:triggerOnce("e3_bench_crafted", {"E3C"}, true) -- 287
		end -- 287
		return -- 289
	end -- 289
	if key == "escort4" then -- 289
		if px >= ox + 190 and px <= ox + 460 then -- 289
			self:triggerOnce("e4_cliff", {"E4A", "E4B"}) -- 294
		end -- 294
		return -- 296
	end -- 296
	if key == "escort5" then -- 296
		if px >= ox + 180 and px <= ox + 420 then -- 296
			self:triggerOnce("e5_dawn", {"E5A", "E5B"}) -- 301
		end -- 301
		return -- 303
	end -- 303
	if key == "outside" then -- 303
		if px >= ox + 760 and px <= ox + 1020 then -- 303
			self:triggerOnce("o3_salt_wind", {"O3_WIND"}) -- 309
		end -- 309
		if interactPressed and px >= ox + 830 and px <= ox + 950 and math.abs(p.player.y) < 20 then -- 309
			self:triggerOnce("opt_shell", {"OPT_SHELL"}, true) -- 312
		end -- 312
		return -- 314
	end -- 314
	if key == "village" then -- 314
		if p.passed and px >= ox + 550 and px <= ox + 690 then -- 314
			self:triggerOnce("v3_grate_ask", {"D27"}) -- 320
			if interactPressed and self.triggeredBeats.v3_grate_ask then -- 320
				self:triggerOnce("v3_grate_reply", {"D28", "D29"}, true) -- 322
			end -- 322
		end -- 322
		return -- 325
	end -- 325
	if key == "forest" then -- 325
		local waterBeat = events ~= nil and __TS__ArraySome( -- 330
			events.storyBeats, -- 330
			function(____, b) return b.beat == "water_lantern" end -- 330
		) -- 330
		if waterBeat or px >= ox + 1190 then -- 330
			self:triggerOnce("f4_creek_lamp", {"F4_CREEK"}) -- 332
		end -- 332
		if interactPressed and px >= ox + 300 and px <= ox + 400 and p.player.crouch then -- 332
			self:triggerOnce("opt_hollow", {"OPT_HOLLOW"}, true) -- 335
		end -- 335
		return -- 337
	end -- 337
	if key == "tower" then -- 337
		if p.phase == "tower-wait" and interactPressed and px >= ox + 300 and px <= ox + 385 then -- 337
			self:triggerOnce("opt_lantern", {"OPT_LANTERN"}, true) -- 343
		elseif p.phase == "tower-knock" then -- 343
			self:triggerOnce("t2_knock", {"D14", "D15"}, true) -- 345
		elseif p.phase == "tower-enter" or p.phase == "tower-desk" then -- 345
			if p.storyRoute == "soldier" then -- 345
				self:triggerOnce("t3_soldier_talk", { -- 348
					"D53", -- 348
					"D54", -- 348
					"D16", -- 348
					"D17", -- 348
					"D63", -- 348
					"D64" -- 348
				}, true) -- 348
			else -- 348
				self:triggerOnce("t3_child_talk", { -- 350
					"D16", -- 350
					"D17", -- 350
					"D63", -- 350
					"D64", -- 350
					"D18", -- 350
					"D19" -- 350
				}, true) -- 350
			end -- 350
		elseif p.phase == "tower-end" and p.storyRoute == "soldier" then -- 350
			self:triggerOnce("t3_reunion_end", {"D55", "D56", "D65"}, true) -- 353
		end -- 353
	end -- 353
end -- 120
function NarrativeRenderer.prototype.update(self, dt, p, events, interactPressed) -- 358
	if interactPressed == nil then -- 358
		interactPressed = false -- 358
	end -- 358
	self.time = self.time + dt -- 359
	if self.lastRoomKey ~= p.room.key then -- 359
		self:onEnterRoom(p.room.key) -- 361
	end -- 361
	if self.muteCaptionT > 0 then -- 361
		self.muteCaptionT = math.max(0, self.muteCaptionT - dt) -- 364
	end -- 364
	if self.activeLine ~= nil then -- 364
		self.activeLineT = self.activeLineT - dt -- 367
		if self.activeLineT <= 0 then -- 367
			local next = table.remove(self.queuedLines, 1) -- 369
			self.activeLine = next -- 370
			self.activeLineT = next ~= nil and next.duration or 0 -- 371
		end -- 371
	end -- 371
	self:stepScriptedBeats(p, events, interactPressed) -- 374
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 376
	local target = wantCinema and 1 or 0 -- 381
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 382
	if self.bannerT > 0 then -- 382
		self.bannerT = math.max(0, self.bannerT - dt) -- 385
	end -- 385
	if self.wipeT > 0 then -- 385
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 388
	end -- 388
end -- 358
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 392
	if assistHintsEnabled == nil then -- 392
		assistHintsEnabled = false -- 401
	end -- 401
	if inputMode == nil then -- 401
		inputMode = "kbm" -- 402
	end -- 402
	if gamepadLayout == nil then -- 402
		gamepadLayout = "xbox" -- 403
	end -- 403
	if safe == nil then -- 403
		safe = ZERO_SAFE_INSETS -- 404
	end -- 404
	if self.letterbox > 0.01 then -- 404
		local barH = math.floor(70 * self.letterbox + 0.5) -- 408
		uiDraw:drawRect( -- 409
			Rect(0, h - barH, w, barH), -- 409
			Color(8, 10, 16, 242) -- 409
		) -- 409
		uiDraw:drawRect( -- 410
			Rect(0, 0, w, barH), -- 410
			Color(8, 10, 16, 242) -- 410
		) -- 410
		uiInkDraw:drawSegment( -- 411
			Vec2(0, h - barH), -- 411
			Vec2(w, h - barH), -- 411
			0.7, -- 411
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 411
		) -- 411
		uiInkDraw:drawSegment( -- 412
			Vec2(0, barH), -- 412
			Vec2(w, barH), -- 412
			0.7, -- 412
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 412
		) -- 412
	end -- 412
	if p.room.key == "gate" and p.phase == "gate-count" then -- 412
		self:drawGateCountOverlay( -- 417
			uiDraw, -- 417
			uiInkDraw, -- 417
			art, -- 417
			texts, -- 417
			p, -- 417
			w, -- 417
			h -- 417
		) -- 417
	end -- 417
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 421
	if showRegistry then -- 421
		self:drawTowerRegistryCard( -- 423
			uiDraw, -- 423
			uiInkDraw, -- 423
			uiGlow, -- 423
			art, -- 423
			texts, -- 423
			p, -- 423
			w, -- 423
			h, -- 423
			assistHintsEnabled, -- 423
			inputMode, -- 423
			gamepadLayout -- 423
		) -- 423
	end -- 423
	if not p.paused and not showRegistry then -- 423
		self:drawSubtitleStrip( -- 428
			uiDraw, -- 428
			uiInkDraw, -- 428
			art, -- 428
			texts, -- 428
			p, -- 428
			w, -- 428
			h, -- 428
			assistHintsEnabled, -- 428
			inputMode, -- 428
			gamepadLayout, -- 428
			safe -- 428
		) -- 428
	end -- 428
	if self.bannerT > 0 and not p.paused then -- 428
		self:drawAreaBanner( -- 433
			uiDraw, -- 433
			uiInkDraw, -- 433
			art, -- 433
			texts, -- 433
			p.room.key, -- 433
			w, -- 433
			h -- 433
		) -- 433
	end -- 433
	if self.wipeT > 0.01 then -- 433
		local k = math.min(1, self.wipeT * 1.15) -- 438
		local a = math.floor(255 * k * k + 0.5) -- 439
		uiDraw:drawRect( -- 440
			Rect(0, 0, w, h), -- 440
			Color(9, 11, 17, a) -- 440
		) -- 440
		art:tryPlace( -- 441
			"ink_petal_mist", -- 441
			"wipe_mist", -- 441
			w * 0.5, -- 441
			h * 0.5, -- 441
			w * 0.65, -- 441
			h * 0.65, -- 441
			{ -- 441
				color = toColor(PALETTE.inkMist), -- 442
				opacity = 0.2 * self.wipeT, -- 442
				layer = 5 -- 442
			} -- 442
		) -- 442
	end -- 442
end -- 392
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 447
	local cx = w * 0.5 -- 460
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 461
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 462
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 462
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 466
		local capY = cy + 44 -- 467
		drawSilkVeil( -- 468
			uiDraw, -- 468
			art, -- 468
			"mute_sfx_veil", -- 468
			cx, -- 468
			capY, -- 468
			172, -- 468
			26, -- 468
			PALETTE.inkWarm, -- 468
			0.76 * capAlpha, -- 468
			0 -- 468
		) -- 468
		texts:put( -- 469
			"xs", -- 469
			self.muteCaption, -- 469
			cx, -- 469
			capY, -- 469
			toColor(PALETTE.amberCore), -- 469
			0.5, -- 469
			0.5, -- 469
			"Center", -- 469
			1.4, -- 469
			0.94 * capAlpha, -- 469
			0.08 -- 469
		) -- 469
	end -- 469
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 472
	if rawLine.text == "" then -- 472
		return -- 474
	end -- 474
	local line = { -- 476
		cue = rawLine.cue, -- 477
		text = assistHintsEnabled and adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 478
		urgent = rawLine.urgent -- 479
	} -- 479
	local hasCue = line.cue ~= "" -- 481
	local textW = visualTextWidth(line.text, 18) -- 482
	local contentW = textW + (hasCue and 48 or 0) -- 483
	local stripW = math.min( -- 484
		w - 72 - safe.left - safe.right, -- 484
		math.max(540, contentW + 210) -- 484
	) -- 484
	local stripH = 54 -- 485
	drawSilkVeil( -- 488
		uiDraw, -- 488
		art, -- 488
		"sub_veil", -- 488
		cx, -- 488
		cy, -- 488
		stripW, -- 488
		stripH, -- 488
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 488
		0.84, -- 488
		-1 -- 488
	) -- 488
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 490
	drawHairline( -- 491
		uiInkDraw, -- 491
		art, -- 491
		"sub_top_line", -- 491
		cx, -- 491
		cy + 23, -- 491
		stripW * 0.72, -- 491
		railCol, -- 491
		line.urgent and 0.72 or 0.52, -- 491
		true, -- 491
		2 -- 491
	) -- 491
	if hasCue then -- 491
		local startX = cx - contentW * 0.5 -- 494
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 495
		drawBlossomDot( -- 496
			uiInkDraw, -- 496
			art, -- 496
			"sub_cue_dot", -- 496
			startX + 6, -- 496
			cy - 1, -- 496
			10, -- 496
			cueCol, -- 496
			0.94, -- 496
			4 -- 496
		) -- 496
		texts:put( -- 497
			"xs", -- 497
			line.cue, -- 497
			startX + 24, -- 497
			cy - 1, -- 497
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 497
			0.5, -- 497
			0.5, -- 497
			"Center", -- 497
			0, -- 497
			0.96, -- 497
			0.08 -- 497
		) -- 497
		uiInkDraw:drawSegment( -- 498
			Vec2(startX + 38, cy - 8), -- 498
			Vec2(startX + 38, cy + 6), -- 498
			0.75, -- 498
			toColor(PALETTE.silkDim, 115) -- 498
		) -- 498
		texts:put( -- 499
			"sm", -- 499
			line.text, -- 499
			startX + 48, -- 499
			cy - 1, -- 499
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 499
			0, -- 499
			0.5, -- 499
			"Left", -- 499
			0.9, -- 499
			0.98, -- 499
			0.08 -- 499
		) -- 499
	else -- 499
		texts:put( -- 501
			"sm", -- 501
			line.text, -- 501
			cx, -- 501
			cy - 1, -- 501
			toColor(PALETTE.textBright), -- 501
			0.5, -- 501
			0.5, -- 501
			"Center", -- 501
			1, -- 501
			0.98, -- 501
			0.08 -- 501
		) -- 501
	end -- 501
end -- 447
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 506
	local key = p.room.key -- 507
	local theme = themeOf(key) -- 508
	if key == "gate" and p.phase == "gate-count" then -- 508
		if p.countTick >= GATE_COUNT_END then -- 508
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 512
		end -- 512
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 518
	end -- 518
	if not assistHintsEnabled then -- 518
		if self.activeLine ~= nil then -- 518
			local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 524
			local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 527
			return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 529
		end -- 529
		if key == "prologue" and p.phase == "prologue-give" then -- 529
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 532
		end -- 532
		if key == "checkpoint" and p.escort.state == "calming" then -- 532
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 535
		end -- 535
		if key == "tower" then -- 535
			if p.phase == "tower-knock" then -- 535
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 539
			end -- 539
			if p.phase == "tower-given" then -- 539
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 542
			end -- 542
		end -- 542
		if p.flash ~= "" and p.flashT > 0 then -- 542
			local fl = p.flash -- 547
			local hasKeyHint = (string.find(fl, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(fl, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(fl, "限时", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 1", nil, true) or 0) - 1 >= 0 -- 548
			if not hasKeyHint then -- 548
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 567
				local text = p.flash -- 568
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 569
				if key == "tower" or key == "prologue" then -- 569
					cue = "" -- 571
				end -- 571
				if text == "命中" then -- 571
					text = "倭寇击倒" -- 574
				elseif text == "打空" then -- 574
					text = "铅丸偏离或被掩体阻挡" -- 576
				elseif text == "翻滚" then -- 576
					text = "伏身翻滚回避" -- 578
				end -- 578
				return {cue = cue, text = text, urgent = isDanger} -- 580
			end -- 580
		end -- 580
		return {cue = "", text = "", urgent = false} -- 583
	end -- 583
	if key == "gate" and p.phase == "gate-hold" then -- 583
		local threatened = false -- 587
		local hasAliveEnemy = false -- 588
		local i = 0 -- 589
		do -- 589
			i = 0 -- 590
			while i < #p.enemies do -- 590
				if p.enemies[i + 1].alive then -- 590
					hasAliveEnemy = true -- 592
					if p.enemies[i + 1].warnT > 0 then -- 592
						threatened = true -- 594
					end -- 594
				end -- 594
				i = i + 1 -- 590
			end -- 590
		end -- 590
		if threatened then -- 590
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 599
		end -- 599
		if p.coverHug then -- 599
			if hasAliveEnemy and not p.coverBlocking then -- 599
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 603
			end -- 603
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 605
		end -- 605
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 607
	end -- 607
	if key == "gate" and p.phase == "gate-count" then -- 607
		if p.countTick >= GATE_COUNT_END then -- 607
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 612
		end -- 612
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 618
	end -- 618
	if self.activeLine ~= nil then -- 618
		local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 622
		local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 625
		return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 627
	end -- 627
	if p.flash ~= "" and p.flashT > 0 then -- 627
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 631
		local text = p.flash -- 632
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 633
		if key == "tower" or key == "prologue" then -- 633
			cue = "" -- 635
		end -- 635
		if text == "命中" then -- 635
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 638
		elseif text == "打空" then -- 638
			text = "铅丸偏离或被掩体阻挡" -- 640
		elseif text == "翻滚" then -- 640
			text = "伏身翻滚回避" -- 642
		end -- 642
		return {cue = cue, text = text, urgent = isDanger} -- 644
	end -- 644
	if key == "prologue" then -- 644
		if p.phase == "prologue-wait" then -- 644
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 649
		end -- 649
		if p.phase == "prologue-give" then -- 649
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 652
		end -- 652
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 654
	end -- 654
	if key == "street" then -- 654
		local alive = 0 -- 658
		local i = 0 -- 659
		do -- 659
			i = 0 -- 660
			while i < #p.enemies do -- 660
				if p.enemies[i + 1].alive then -- 660
					alive = alive + 1 -- 661
				end -- 661
				i = i + 1 -- 660
			end -- 660
		end -- 660
		if alive > 0 then -- 660
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 664
		end -- 664
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 666
	end -- 666
	if key == "checkpoint" then -- 666
		if p.escort.state == "frozen" then -- 666
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 671
		end -- 671
		if p.escort.state == "calming" then -- 671
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 674
		end -- 674
		if not p.cartDocked then -- 674
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 677
		end -- 677
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 679
	end -- 679
	if key == "gate" then -- 679
		if p.phase == "gate-idle" then -- 679
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 684
		end -- 684
		if p.phase == "gate-send" then -- 684
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 691
		end -- 691
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 693
	end -- 693
	if key == "outside" then -- 693
		if not p.cartDocked then -- 693
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 698
		end -- 698
		if p.checkpoint < p.room.arch.x1 then -- 698
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 701
		end -- 701
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 703
	end -- 703
	if key == "village" then -- 703
		if p.scavChase then -- 703
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 708
		end -- 708
		if p.passed then -- 708
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 711
		end -- 711
		if p.hasBottle then -- 711
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 714
		end -- 714
		if p.bottleFly ~= nil then -- 714
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 717
		end -- 717
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 717
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 720
		end -- 720
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 722
	end -- 722
	if key == "forest" then -- 722
		if p.dogState == "chase" then -- 722
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 727
		end -- 727
		if p.dogState == "ear" then -- 727
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 730
		end -- 730
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 732
	end -- 732
	if key == "tower" then -- 732
		if p.phase == "tower-wait" then -- 732
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 737
		end -- 737
		if p.phase == "tower-knock" then -- 737
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 740
		end -- 740
		if p.phase == "tower-given" then -- 740
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 743
		end -- 743
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 745
	end -- 745
	return {cue = "", text = theme.introWhisper, urgent = false} -- 748
end -- 506
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 751
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 760
	local countNum = gateCountAtTick(p.countTick) -- 761
	uiDraw:drawRect( -- 762
		Rect(0, 0, w, h), -- 762
		Color( -- 762
			7, -- 762
			9, -- 762
			15, -- 762
			math.floor(78 + frac * 116 + 0.5) -- 762
		) -- 762
	) -- 762
	local cy = h * 0.56 -- 764
	art:tryPlace( -- 765
		"ink_petal_mist", -- 765
		"gate_count_mist", -- 765
		w * 0.5, -- 765
		cy, -- 765
		290, -- 765
		220, -- 765
		{ -- 765
			color = toColor(PALETTE.inkMist), -- 766
			opacity = 0.34 + frac * 0.2, -- 766
			layer = 0 -- 766
		} -- 766
	) -- 766
	drawMistCurve( -- 768
		art, -- 768
		"gate_count_wisp", -- 768
		w * 0.5, -- 768
		cy - 8, -- 768
		420, -- 768
		76, -- 768
		PALETTE.jadeMist, -- 768
		0.22, -- 768
		0 -- 768
	) -- 768
	local numZh = toChineseUpper(countNum) -- 770
	texts:put( -- 771
		"title", -- 771
		numZh, -- 771
		w * 0.5, -- 771
		cy + 8, -- 771
		toColor(PALETTE.textBright), -- 771
		0.5, -- 771
		0.5, -- 771
		"Center", -- 771
		12, -- 771
		0.42 + frac * 0.56, -- 771
		0.1 -- 771
	) -- 771
	drawHairline( -- 772
		uiInkDraw, -- 772
		art, -- 772
		"gate_count_div", -- 772
		w * 0.5, -- 772
		cy - 34, -- 772
		240, -- 772
		PALETTE.silkDim, -- 772
		0.62, -- 772
		true, -- 772
		2 -- 772
	) -- 772
	texts:put( -- 773
		"sm", -- 773
		"城外静候 · 默数至二十", -- 773
		w * 0.5, -- 773
		cy - 58, -- 773
		toColor(PALETTE.textMid), -- 773
		0.5, -- 773
		0.5, -- 773
		"Center", -- 773
		3.4, -- 773
		0.84, -- 773
		0.08 -- 773
	) -- 773
end -- 751
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 783
	local cardW = 588 -- 796
	local cardH = 382 -- 797
	local cx = (w - cardW) * 0.5 -- 798
	local cy = (h - cardH) * 0.5 + 10 -- 799
	local midX = w * 0.5 -- 800
	local midY = cy + cardH * 0.5 -- 801
	uiDraw:drawRect( -- 804
		Rect(0, 0, w, h), -- 804
		Color(7, 9, 15, 174) -- 804
	) -- 804
	art:tryPlace( -- 805
		"ink_frame_mask", -- 805
		"reg_shadow", -- 805
		midX, -- 805
		midY - 6, -- 805
		cardW + 58, -- 805
		cardH + 50, -- 805
		{ -- 805
			color = toColor(PALETTE.voidDark), -- 806
			opacity = 0.82, -- 806
			layer = -1 -- 806
		} -- 806
	) -- 806
	if not art:tryPlace( -- 806
		"ink_song_paper", -- 810
		"registry_song_paper", -- 810
		midX, -- 810
		midY, -- 810
		cardW, -- 810
		cardH, -- 810
		{opacity = 0.98, layer = 1} -- 810
	) then -- 810
		uiDraw:drawRect( -- 811
			Rect(cx, cy, cardW, cardH), -- 811
			toColor(PALETTE.xuanPaper, 246), -- 811
			1, -- 811
			toColor(PALETTE.silkDim, 180) -- 811
		) -- 811
	end -- 811
	fillRadialGlow( -- 813
		uiGlow, -- 813
		midX, -- 813
		midY + 46, -- 813
		240, -- 813
		130, -- 813
		Color(235, 224, 202, 14), -- 813
		Color(235, 224, 202, 0), -- 813
		14 -- 813
	) -- 813
	local padX = 46 -- 816
	local padY = 36 -- 817
	local inX = cx + padX -- 818
	local inY = cy + padY -- 819
	local inW = cardW - padX * 2 -- 820
	local inH = cardH - padY * 2 -- 821
	local redSilk = toColor(PALETTE.rouge, 118) -- 822
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 823
	uiInkDraw:drawRect( -- 825
		Rect(inX, inY, inW, inH), -- 825
		Color(0, 0, 0, 0), -- 825
		0.9, -- 825
		redSilk -- 825
	) -- 825
	uiInkDraw:drawRect( -- 826
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 826
		Color(0, 0, 0, 0), -- 826
		0.55, -- 826
		redSilkFaint -- 826
	) -- 826
	local headY = inY + inH - 28 -- 829
	texts:put( -- 830
		"md", -- 830
		"北塔入塔登记簿 · 末页", -- 830
		inX + 20, -- 830
		headY, -- 830
		toColor(PALETTE.xuanInk), -- 830
		0, -- 830
		0.5, -- 830
		"Left", -- 830
		2.4, -- 830
		0.94, -- 830
		0 -- 830
	) -- 830
	texts:put( -- 831
		"xs", -- 831
		"守望行记", -- 831
		inX + inW - 20, -- 831
		headY, -- 831
		toColor(PALETTE.xuanInkSub), -- 831
		1, -- 831
		0.5, -- 831
		"Right", -- 831
		2, -- 831
		0.78, -- 831
		0 -- 831
	) -- 831
	uiInkDraw:drawSegment( -- 832
		Vec2(inX + 14, headY - 22), -- 832
		Vec2(inX + inW - 14, headY - 22), -- 832
		0.85, -- 832
		redSilk -- 832
	) -- 832
	local reunion = #p.endingLines >= 2 and p.endingLines[2] ~= "" or p.storyRoute == "soldier" -- 835
	local row1Y = headY - 56 -- 836
	texts:put( -- 837
		"sm", -- 837
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 837
		inX + 20, -- 837
		row1Y, -- 837
		toColor(PALETTE.xuanInk), -- 837
		0, -- 837
		0.5, -- 837
		"Left", -- 837
		0.8, -- 837
		0.94, -- 837
		0 -- 837
	) -- 837
	texts:put( -- 838
		"xs", -- 839
		reunion and "附注：兄妹并肩抵塔；怀铜针、手书一纸。" or (("附注：" .. NEEDLE_NOTE_LINES[1]) .. " —— ") .. NEEDLE_NOTE_LINES[2], -- 840
		inX + 20, -- 841
		row1Y - 28, -- 842
		toColor(PALETTE.xuanInkSub), -- 843
		0, -- 844
		0.5, -- 845
		"Left", -- 846
		0.6, -- 847
		0.88, -- 848
		0 -- 849
	) -- 849
	uiInkDraw:drawSegment( -- 851
		Vec2(inX + 16, row1Y - 48), -- 851
		Vec2(inX + inW - 16, row1Y - 48), -- 851
		0.65, -- 851
		redSilkFaint -- 851
	) -- 851
	local blankY = row1Y - 80 -- 854
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 855
	if reunion then -- 855
		texts:put( -- 857
			"sm", -- 857
			"肆拾贰   周戍 · 兄妹同行 · 已入塔", -- 857
			inX + 20, -- 857
			blankY, -- 857
			toColor(PALETTE.xuanInk), -- 857
			0, -- 857
			0.5, -- 857
			"Left", -- 857
			0.8, -- 857
			0.94, -- 857
			0 -- 857
		) -- 857
		texts:put( -- 858
			"xs", -- 858
			"附注：门内断后脱身，同抵北塔值夜室。", -- 858
			inX + 20, -- 858
			blankY - 26, -- 858
			toColor(PALETTE.xuanInkSub), -- 858
			0, -- 858
			0.5, -- 858
			"Left", -- 858
			0.6, -- 858
			0.86, -- 858
			0 -- 858
		) -- 858
	else -- 858
		texts:put( -- 860
			"sm", -- 860
			"肆拾贰", -- 860
			inX + 20, -- 860
			blankY, -- 860
			toColor(PALETTE.rouge), -- 860
			0, -- 860
			0.5, -- 860
			"Left", -- 860
			1, -- 860
			0.92, -- 860
			0 -- 860
		) -- 860
		uiInkDraw:drawSegment( -- 861
			Vec2(inX + 94, blankY - 7), -- 861
			Vec2(inX + inW - 116, blankY - 7), -- 861
			0.95, -- 861
			toColor(PALETTE.xuanInkSub, 155 * pulse) -- 861
		) -- 861
		texts:put( -- 862
			"xs", -- 862
			"（空行留待）", -- 862
			inX + inW - 104, -- 862
			blankY, -- 862
			toColor(PALETTE.xuanInkSub), -- 862
			0, -- 862
			0.5, -- 862
			"Left", -- 862
			1, -- 862
			0.82 * pulse, -- 862
			0 -- 862
		) -- 862
	end -- 862
	if p.phase == "tower-end" then -- 862
		local signY = inY + 46 -- 867
		texts:put( -- 868
			"banner", -- 868
			"向西守望", -- 868
			midX - 18, -- 868
			signY, -- 868
			toColor(PALETTE.xuanInk), -- 868
			0.5, -- 868
			0.5, -- 868
			"Center", -- 868
			6.5, -- 868
			0.92, -- 868
			0 -- 868
		) -- 868
		drawLoneSeal( -- 869
			uiInkDraw, -- 869
			art, -- 869
			texts, -- 869
			"reg_lone_seal", -- 869
			midX + 86, -- 869
			signY, -- 869
			22, -- 869
			42, -- 869
			"守", -- 869
			"望", -- 869
			PALETTE.sealRed, -- 869
			PALETTE.sealText, -- 869
			0.92, -- 869
			4 -- 869
		) -- 869
		drawSilkVeil( -- 871
			uiDraw, -- 871
			art, -- 871
			"reg_hint_veil", -- 871
			midX, -- 871
			cy - 28, -- 871
			360, -- 871
			32, -- 871
			PALETTE.inkWash, -- 871
			0.72, -- 871
			0 -- 871
		) -- 871
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 872
		local endHint = adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 873
		texts:put( -- 874
			"xs", -- 874
			endHint, -- 874
			midX, -- 874
			cy - 28, -- 874
			toColor(PALETTE.textMid), -- 874
			0.5, -- 874
			0.5, -- 874
			"Center", -- 874
			1.6, -- 874
			0.92, -- 874
			0.08 -- 874
		) -- 874
	end -- 874
end -- 783
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 878
	local theme = themeOf(roomKey) -- 887
	local t = self.bannerT / self.bannerMax -- 888
	local alpha = 1 -- 889
	if t > 0.82 then -- 889
		alpha = (1 - t) / 0.18 -- 891
	elseif t < 0.28 then -- 891
		alpha = t / 0.28 -- 893
	end -- 893
	local cx = w * 0.5 -- 895
	local cy = h * 0.77 -- 896
	local spread = math.min(1, alpha * 1.15) -- 897
	drawSilkVeil( -- 900
		uiDraw, -- 900
		art, -- 900
		"banner_veil", -- 900
		cx, -- 900
		cy - 2, -- 900
		480 * spread + 100, -- 900
		92, -- 900
		PALETTE.inkWash, -- 900
		0.76 * alpha, -- 900
		-1 -- 900
	) -- 900
	drawMistCurve( -- 901
		art, -- 901
		"banner_mist", -- 901
		cx, -- 901
		cy + 4, -- 901
		460 * spread, -- 901
		72, -- 901
		theme.accent, -- 901
		0.28 * alpha, -- 901
		0 -- 901
	) -- 901
	drawHairline( -- 902
		uiInkDraw, -- 902
		art, -- 902
		"banner_line", -- 902
		cx, -- 902
		cy - 16, -- 902
		320 * spread, -- 902
		PALETTE.silkLine, -- 902
		0.64 * alpha, -- 902
		false, -- 902
		2 -- 902
	) -- 902
	local sep = " · " -- 905
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 906
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 907
	if theme.backdropKey ~= nil then -- 907
		texts:put( -- 909
			"lg", -- 909
			theme.titleZh, -- 909
			cx, -- 909
			cy + 14, -- 909
			toColor(PALETTE.textBright), -- 909
			0.5, -- 910
			0.5, -- 910
			"Center", -- 910
			1, -- 910
			alpha, -- 910
			0.1 -- 910
		) -- 910
	elseif idx > 0 then -- 910
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 912
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 913
		local lw = visualTextWidth(leftPart, 42) -- 914
		local rw = visualTextWidth(rightPart, 42) -- 915
		local dotGap = 28 -- 916
		local totalW = lw + rw + dotGap -- 917
		local leftEdge = cx - totalW * 0.5 -- 918
		local dotX = leftEdge + lw + dotGap * 0.5 -- 919
		texts:put( -- 921
			"banner", -- 921
			leftPart, -- 921
			leftEdge, -- 921
			cy + 14, -- 921
			toColor(PALETTE.textBright), -- 921
			0, -- 921
			0.5, -- 921
			"Left", -- 921
			2, -- 921
			alpha, -- 921
			0.1 -- 921
		) -- 921
		drawBlossomDot( -- 922
			uiInkDraw, -- 922
			art, -- 922
			"banner_mid_dot", -- 922
			dotX, -- 922
			cy + 12, -- 922
			11, -- 922
			dotCol, -- 922
			0.92 * alpha, -- 922
			4 -- 922
		) -- 922
		texts:put( -- 923
			"banner", -- 923
			rightPart, -- 923
			dotX + dotGap * 0.5, -- 923
			cy + 14, -- 923
			toColor(PALETTE.textBright), -- 923
			0, -- 923
			0.5, -- 923
			"Left", -- 923
			2, -- 923
			alpha, -- 923
			0.1 -- 923
		) -- 923
	else -- 923
		texts:put( -- 925
			"banner", -- 925
			theme.titleZh, -- 925
			cx, -- 925
			cy + 14, -- 925
			toColor(PALETTE.textBright), -- 925
			0.5, -- 925
			0.5, -- 925
			"Center", -- 925
			3, -- 925
			alpha, -- 925
			0.1 -- 925
		) -- 925
	end -- 925
	texts:put( -- 927
		"xs", -- 927
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 927
		cx, -- 927
		cy - 34, -- 927
		toColor(PALETTE.textMid), -- 927
		0.5, -- 927
		0.5, -- 927
		"Center", -- 927
		2.2, -- 927
		0.82 * alpha, -- 927
		0.08 -- 927
	) -- 927
end -- 878
return ____exports -- 878