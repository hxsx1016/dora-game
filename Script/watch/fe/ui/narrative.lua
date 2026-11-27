-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
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
	if key == "village" then -- 314
		if p.passed and px >= ox + 550 and px <= ox + 690 then -- 314
			self:triggerOnce("v3_grate_ask", {"D27"}) -- 320
			if interactPressed and self.triggeredBeats.v3_grate_ask then -- 320
				self:triggerOnce("v3_grate_reply", {"D28", "D29"}, true) -- 322
			end -- 322
		end -- 322
		return -- 325
	end -- 325
	if key == "tower" then -- 325
		if p.phase == "tower-wait" and interactPressed and px >= ox + 300 and px <= ox + 385 then -- 325
			self:triggerOnce("opt_lantern", {"OPT_LANTERN"}, true) -- 331
		elseif p.phase == "tower-enter" then -- 331
			self:triggerOnce("t2_knock", {"D14", "D15"}, true) -- 334
		elseif p.phase == "tower-desk" then -- 334
			if p.storyRoute == "soldier" then -- 334
				self:triggerOnce("t3_soldier_talk", { -- 337
					"D53", -- 337
					"D54", -- 337
					"D16", -- 337
					"D17", -- 337
					"D63", -- 337
					"D64" -- 337
				}) -- 337
			else -- 337
				self:triggerOnce("t3_child_talk", { -- 339
					"D16", -- 339
					"D17", -- 339
					"D63", -- 339
					"D64", -- 339
					"D18", -- 339
					"D19" -- 339
				}) -- 339
			end -- 339
		elseif p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 then -- 339
			self:triggerOnce("t3_reunion_end", {"D55", "D56", "D65"}, true) -- 343
		end -- 343
	end -- 343
end -- 122
function NarrativeRenderer.prototype.update(self, dt, p, events, interactPressed) -- 348
	if interactPressed == nil then -- 348
		interactPressed = false -- 348
	end -- 348
	self.time = self.time + dt -- 349
	if self.lastRoomKey ~= p.room.key then -- 349
		self:onEnterRoom(p.room.key) -- 351
	end -- 351
	if self.muteCaptionT > 0 then -- 351
		self.muteCaptionT = math.max(0, self.muteCaptionT - dt) -- 354
	end -- 354
	if self.activeLine ~= nil then -- 354
		self.activeLineT = self.activeLineT - dt -- 357
		if self.activeLineT <= 0 then -- 357
			local next = table.remove(self.queuedLines, 1) -- 359
			self.activeLine = next -- 360
			self.activeLineT = next ~= nil and next.duration or 0 -- 361
		end -- 361
	end -- 361
	self:stepScriptedBeats(p, events, interactPressed) -- 364
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-farewell" or p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 366
	local target = wantCinema and 1 or 0 -- 371
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 372
	if p.room.key == "tower" and p.phase ~= "tower-wait" then -- 372
		self.bannerT = 0 -- 376
	end -- 376
	if self.bannerT > 0 then -- 376
		self.bannerT = math.max(0, self.bannerT - dt) -- 379
	end -- 379
	if self.wipeT > 0 then -- 379
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 382
	end -- 382
end -- 348
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 386
	if assistHintsEnabled == nil then -- 386
		assistHintsEnabled = false -- 395
	end -- 395
	if inputMode == nil then -- 395
		inputMode = "kbm" -- 396
	end -- 396
	if gamepadLayout == nil then -- 396
		gamepadLayout = "xbox" -- 397
	end -- 397
	if safe == nil then -- 397
		safe = ZERO_SAFE_INSETS -- 398
	end -- 398
	if self.letterbox > 0.01 then -- 398
		local barH = math.floor(70 * self.letterbox + 0.5) -- 402
		uiDraw:drawRect( -- 403
			Rect(0, h - barH, w, barH), -- 403
			Color(8, 10, 16, 242) -- 403
		) -- 403
		uiDraw:drawRect( -- 404
			Rect(0, 0, w, barH), -- 404
			Color(8, 10, 16, 242) -- 404
		) -- 404
		uiInkDraw:drawSegment( -- 405
			Vec2(0, h - barH), -- 405
			Vec2(w, h - barH), -- 405
			0.7, -- 405
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 405
		) -- 405
		uiInkDraw:drawSegment( -- 406
			Vec2(0, barH), -- 406
			Vec2(w, barH), -- 406
			0.7, -- 406
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 406
		) -- 406
	end -- 406
	if p.room.key == "gate" and p.phase == "gate-count" then -- 406
		self:drawGateCountOverlay( -- 411
			uiDraw, -- 411
			uiInkDraw, -- 411
			art, -- 411
			texts, -- 411
			p, -- 411
			w, -- 411
			h -- 411
		) -- 411
	end -- 411
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 415
	if showRegistry then -- 415
		self:drawTowerRegistryCard( -- 417
			uiDraw, -- 417
			uiInkDraw, -- 417
			uiGlow, -- 417
			art, -- 417
			texts, -- 417
			p, -- 417
			w, -- 417
			h, -- 417
			assistHintsEnabled, -- 417
			inputMode, -- 417
			gamepadLayout -- 417
		) -- 417
	end -- 417
	if not p.paused and not showRegistry then -- 417
		self:drawSubtitleStrip( -- 422
			uiDraw, -- 422
			uiInkDraw, -- 422
			art, -- 422
			texts, -- 422
			p, -- 422
			w, -- 422
			h, -- 422
			assistHintsEnabled, -- 422
			inputMode, -- 422
			gamepadLayout, -- 422
			safe -- 422
		) -- 422
	end -- 422
	if self.bannerT > 0 and not p.paused then -- 422
		self:drawAreaBanner( -- 427
			uiDraw, -- 427
			uiInkDraw, -- 427
			art, -- 427
			texts, -- 427
			p.room.key, -- 427
			w, -- 427
			h -- 427
		) -- 427
	end -- 427
	if self.wipeT > 0.01 then -- 427
		local k = math.min(1, self.wipeT * 1.15) -- 432
		local a = math.floor(255 * k * k + 0.5) -- 433
		uiDraw:drawRect( -- 434
			Rect(0, 0, w, h), -- 434
			Color(9, 11, 17, a) -- 434
		) -- 434
		art:tryPlace( -- 435
			"ink_petal_mist", -- 435
			"wipe_mist", -- 435
			w * 0.5, -- 435
			h * 0.5, -- 435
			w * 0.65, -- 435
			h * 0.65, -- 435
			{ -- 435
				color = toColor(PALETTE.inkMist), -- 436
				opacity = 0.2 * self.wipeT, -- 436
				layer = 5 -- 436
			} -- 436
		) -- 436
	end -- 436
end -- 386
function NarrativeRenderer.prototype.drawCutsceneDialogue(self, uiDraw, uiInkDraw, art, texts, p, w, h, safe) -- 446
	if safe == nil then -- 446
		safe = ZERO_SAFE_INSETS -- 454
	end -- 454
	if p.paused then -- 454
		return -- 457
	end -- 457
	local key = p.room.key -- 459
	local allowDialogue = key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-give") or key == "gate" and p.phase == "gate-wait" or key == "tower" and p.phase == "tower-end" and p.storyRoute == "soldier" and p.phaseTick >= 200 -- 460
	local cx = w * 0.5 -- 469
	local cy = (key == "gate" and p.phase == "gate-wait" and 68 or 42) + safe.bottom * 0.5 -- 470
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 470
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 473
		local capY = cy + 44 -- 474
		drawSilkVeil( -- 475
			uiDraw, -- 475
			art, -- 475
			"cut_mute_veil", -- 475
			cx, -- 475
			capY, -- 475
			172, -- 475
			26, -- 475
			PALETTE.inkWarm, -- 475
			0.76 * capAlpha, -- 475
			0 -- 475
		) -- 475
		texts:put( -- 476
			"xs", -- 476
			self.muteCaption, -- 476
			cx, -- 476
			capY, -- 476
			toColor(PALETTE.amberCore), -- 476
			0.5, -- 476
			0.5, -- 476
			"Center", -- 476
			1.4, -- 476
			0.94 * capAlpha, -- 476
			0.08 -- 476
		) -- 476
	end -- 476
	if not allowDialogue or self.activeLine == nil then -- 476
		return -- 480
	end -- 480
	local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 482
	local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 485
	local urgent = self.activeLine.urgent == true -- 487
	local hasCue = cue ~= "" -- 488
	local textW = visualTextWidth(spoken, 18) -- 489
	local contentW = textW + (hasCue and 48 or 0) -- 490
	local stripW = math.min( -- 491
		w - 72 - safe.left - safe.right, -- 491
		math.max(500, contentW + 180) -- 491
	) -- 491
	local stripH = 50 -- 492
	drawSilkVeil( -- 494
		uiDraw, -- 494
		art, -- 494
		"cut_sub_veil", -- 494
		cx, -- 494
		cy, -- 494
		stripW, -- 494
		stripH, -- 494
		urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 494
		0.86, -- 494
		2 -- 494
	) -- 494
	drawHairline( -- 495
		uiInkDraw, -- 495
		art, -- 495
		"cut_sub_top", -- 495
		cx, -- 495
		cy + 21, -- 495
		stripW * 0.72, -- 495
		urgent and PALETTE.rouge or PALETTE.silkDim, -- 495
		urgent and 0.72 or 0.52, -- 495
		true, -- 495
		3 -- 495
	) -- 495
	if hasCue then -- 495
		local startX = cx - contentW * 0.5 -- 497
		local cueCol = urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 498
		drawBlossomDot( -- 499
			uiInkDraw, -- 499
			art, -- 499
			"cut_cue_dot", -- 499
			startX + 6, -- 499
			cy - 1, -- 499
			10, -- 499
			cueCol, -- 499
			0.94, -- 499
			4 -- 499
		) -- 499
		texts:put( -- 500
			"xs", -- 500
			cue, -- 500
			startX + 24, -- 500
			cy - 1, -- 500
			toColor(urgent and PALETTE.crimsonCore or cueCol), -- 500
			0.5, -- 500
			0.5, -- 500
			"Center", -- 500
			0, -- 500
			0.96, -- 500
			0.08 -- 500
		) -- 500
		uiInkDraw:drawSegment( -- 501
			Vec2(startX + 38, cy - 8), -- 501
			Vec2(startX + 38, cy + 6), -- 501
			0.75, -- 501
			toColor(PALETTE.silkDim, 115) -- 501
		) -- 501
		texts:put( -- 502
			"sm", -- 502
			spoken, -- 502
			startX + 48, -- 502
			cy - 1, -- 502
			toColor(urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 502
			0, -- 502
			0.5, -- 502
			"Left", -- 502
			0.9, -- 502
			0.98, -- 502
			0.08 -- 502
		) -- 502
	else -- 502
		texts:put( -- 504
			"sm", -- 504
			spoken, -- 504
			cx, -- 504
			cy - 1, -- 504
			toColor(PALETTE.textBright), -- 504
			0.5, -- 504
			0.5, -- 504
			"Center", -- 504
			1, -- 504
			0.98, -- 504
			0.08 -- 504
		) -- 504
	end -- 504
end -- 446
function NarrativeRenderer.prototype.isKeyHintSegment(self, seg) -- 508
	return (string.find(seg, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(seg, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(seg, "限时", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(seg, "E 选", nil, true) or 0) - 1 >= 0 or (string.find(seg, "按 1", nil, true) or 0) - 1 >= 0 -- 509
end -- 508
function NarrativeRenderer.prototype.stripKeyHintClause(self, fl) -- 531
	if not self:isKeyHintSegment(fl) then -- 531
		return fl -- 533
	end -- 533
	local parts = __TS__StringSplit(fl, " · ") -- 535
	if #parts <= 1 then -- 535
		return "" -- 537
	end -- 537
	local kept = {} -- 539
	local i = 0 -- 540
	do -- 540
		i = 0 -- 541
		while i < #parts do -- 541
			local seg = __TS__StringTrim(parts[i + 1]) -- 542
			if seg ~= "" and not self:isKeyHintSegment(seg) then -- 542
				kept[#kept + 1] = seg -- 544
			end -- 544
			i = i + 1 -- 541
		end -- 541
	end -- 541
	return table.concat(kept, " · ") -- 547
end -- 531
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 550
	local cx = w * 0.5 -- 563
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 564
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 565
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 565
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 569
		local capY = cy + 44 -- 570
		drawSilkVeil( -- 571
			uiDraw, -- 571
			art, -- 571
			"mute_sfx_veil", -- 571
			cx, -- 571
			capY, -- 571
			172, -- 571
			26, -- 571
			PALETTE.inkWarm, -- 571
			0.76 * capAlpha, -- 571
			0 -- 571
		) -- 571
		texts:put( -- 572
			"xs", -- 572
			self.muteCaption, -- 572
			cx, -- 572
			capY, -- 572
			toColor(PALETTE.amberCore), -- 572
			0.5, -- 572
			0.5, -- 572
			"Center", -- 572
			1.4, -- 572
			0.94 * capAlpha, -- 572
			0.08 -- 572
		) -- 572
	end -- 572
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 575
	if rawLine.text == "" then -- 575
		return -- 577
	end -- 577
	local line = { -- 579
		cue = rawLine.cue, -- 580
		text = assistHintsEnabled and adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 581
		urgent = rawLine.urgent -- 582
	} -- 582
	local hasCue = line.cue ~= "" -- 584
	local textW = visualTextWidth(line.text, 18) -- 585
	local contentW = textW + (hasCue and 48 or 0) -- 586
	local stripW = math.min( -- 587
		w - 72 - safe.left - safe.right, -- 587
		math.max(540, contentW + 210) -- 587
	) -- 587
	local stripH = 54 -- 588
	drawSilkVeil( -- 591
		uiDraw, -- 591
		art, -- 591
		"sub_veil", -- 591
		cx, -- 591
		cy, -- 591
		stripW, -- 591
		stripH, -- 591
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 591
		0.84, -- 591
		-1 -- 591
	) -- 591
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 593
	drawHairline( -- 594
		uiInkDraw, -- 594
		art, -- 594
		"sub_top_line", -- 594
		cx, -- 594
		cy + 23, -- 594
		stripW * 0.72, -- 594
		railCol, -- 594
		line.urgent and 0.72 or 0.52, -- 594
		true, -- 594
		2 -- 594
	) -- 594
	if hasCue then -- 594
		local startX = cx - contentW * 0.5 -- 597
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 598
		drawBlossomDot( -- 599
			uiInkDraw, -- 599
			art, -- 599
			"sub_cue_dot", -- 599
			startX + 6, -- 599
			cy - 1, -- 599
			10, -- 599
			cueCol, -- 599
			0.94, -- 599
			4 -- 599
		) -- 599
		texts:put( -- 600
			"xs", -- 600
			line.cue, -- 600
			startX + 24, -- 600
			cy - 1, -- 600
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 600
			0.5, -- 600
			0.5, -- 600
			"Center", -- 600
			0, -- 600
			0.96, -- 600
			0.08 -- 600
		) -- 600
		uiInkDraw:drawSegment( -- 601
			Vec2(startX + 38, cy - 8), -- 601
			Vec2(startX + 38, cy + 6), -- 601
			0.75, -- 601
			toColor(PALETTE.silkDim, 115) -- 601
		) -- 601
		texts:put( -- 602
			"sm", -- 602
			line.text, -- 602
			startX + 48, -- 602
			cy - 1, -- 602
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 602
			0, -- 602
			0.5, -- 602
			"Left", -- 602
			0.9, -- 602
			0.98, -- 602
			0.08 -- 602
		) -- 602
	else -- 602
		texts:put( -- 604
			"sm", -- 604
			line.text, -- 604
			cx, -- 604
			cy - 1, -- 604
			toColor(PALETTE.textBright), -- 604
			0.5, -- 604
			0.5, -- 604
			"Center", -- 604
			1, -- 604
			0.98, -- 604
			0.08 -- 604
		) -- 604
	end -- 604
end -- 550
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 609
	local key = p.room.key -- 610
	local theme = themeOf(key) -- 611
	if key == "gate" and p.phase == "gate-count" then -- 611
		if p.countTick >= GATE_COUNT_END then -- 611
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 615
		end -- 615
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 621
	end -- 621
	if not assistHintsEnabled then -- 621
		if self.activeLine ~= nil then -- 621
			local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 627
			local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 630
			return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 632
		end -- 632
		if key == "prologue" and p.phase == "prologue-give" then -- 632
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 635
		end -- 635
		if key == "checkpoint" and p.escort.state == "calming" then -- 635
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 638
		end -- 638
		if key == "tower" then -- 638
			if p.phase == "tower-knock" then -- 638
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 642
			end -- 642
			if p.phase == "tower-given" then -- 642
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 645
			end -- 645
		end -- 645
		if p.flash ~= "" and p.flashT > 0 then -- 645
			local cleanFlash = self:stripKeyHintClause(p.flash) -- 650
			if cleanFlash ~= "" then -- 650
				local isDanger = (string.find(cleanFlash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(cleanFlash, "追", nil, true) or 0) - 1 >= 0 -- 652
				local text = cleanFlash -- 653
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 654
				if key == "tower" or key == "prologue" then -- 654
					cue = "" -- 656
				end -- 656
				if text == "命中" then -- 656
					text = "倭寇击倒" -- 659
				elseif text == "打空" then -- 659
					text = "铅丸偏离或被掩体阻挡" -- 661
				elseif text == "翻滚" then -- 661
					text = "伏身翻滚回避" -- 663
				end -- 663
				return {cue = cue, text = text, urgent = isDanger} -- 665
			end -- 665
		end -- 665
		return {cue = "", text = "", urgent = false} -- 668
	end -- 668
	if key == "gate" and p.phase == "gate-hold" then -- 668
		local threatened = false -- 672
		local hasAliveEnemy = false -- 673
		local i = 0 -- 674
		do -- 674
			i = 0 -- 675
			while i < #p.enemies do -- 675
				if p.enemies[i + 1].alive then -- 675
					hasAliveEnemy = true -- 677
					if p.enemies[i + 1].warnT > 0 then -- 677
						threatened = true -- 679
					end -- 679
				end -- 679
				i = i + 1 -- 675
			end -- 675
		end -- 675
		if threatened then -- 675
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 684
		end -- 684
		if p.coverHug then -- 684
			if hasAliveEnemy and not p.coverBlocking then -- 684
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 688
			end -- 688
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 690
		end -- 690
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 692
	end -- 692
	if key == "gate" and p.phase == "gate-count" then -- 692
		if p.countTick >= GATE_COUNT_END then -- 692
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 697
		end -- 697
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 703
	end -- 703
	if self.activeLine ~= nil then -- 703
		local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 707
		local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 710
		return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 712
	end -- 712
	if p.flash ~= "" and p.flashT > 0 then -- 712
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 716
		local text = p.flash -- 717
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 718
		if key == "tower" or key == "prologue" then -- 718
			cue = "" -- 720
		end -- 720
		if text == "命中" then -- 720
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 723
		elseif text == "打空" then -- 723
			text = "铅丸偏离或被掩体阻挡" -- 725
		elseif text == "翻滚" then -- 725
			text = "伏身翻滚回避" -- 727
		end -- 727
		return {cue = cue, text = text, urgent = isDanger} -- 729
	end -- 729
	if key == "prologue" then -- 729
		if p.phase == "prologue-wait" then -- 729
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 734
		end -- 734
		if p.phase == "prologue-give" then -- 734
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 737
		end -- 737
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 739
	end -- 739
	if key == "street" then -- 739
		local alive = 0 -- 743
		local i = 0 -- 744
		do -- 744
			i = 0 -- 745
			while i < #p.enemies do -- 745
				if p.enemies[i + 1].alive then -- 745
					alive = alive + 1 -- 746
				end -- 746
				i = i + 1 -- 745
			end -- 745
		end -- 745
		if alive > 0 then -- 745
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 749
		end -- 749
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 751
	end -- 751
	if key == "checkpoint" then -- 751
		if p.escort.state == "frozen" then -- 751
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 756
		end -- 756
		if p.escort.state == "calming" then -- 756
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 759
		end -- 759
		if not p.cartDocked then -- 759
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 762
		end -- 762
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 764
	end -- 764
	if key == "gate" then -- 764
		if p.phase == "gate-idle" then -- 764
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 769
		end -- 769
		if p.phase == "gate-send" then -- 769
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 776
		end -- 776
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 778
	end -- 778
	if key == "outside" then -- 778
		if not p.cartDocked then -- 778
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 783
		end -- 783
		if p.checkpoint < p.room.arch.x1 then -- 783
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 786
		end -- 786
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 788
	end -- 788
	if key == "village" then -- 788
		if p.scavChase then -- 788
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 793
		end -- 793
		if p.passed then -- 793
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 796
		end -- 796
		if p.hasBottle then -- 796
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 799
		end -- 799
		if p.bottleFly ~= nil then -- 799
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 802
		end -- 802
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 802
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 805
		end -- 805
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 807
	end -- 807
	if key == "forest" then -- 807
		if p.dogState == "chase" then -- 807
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 812
		end -- 812
		if p.dogState == "ear" then -- 812
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 815
		end -- 815
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 817
	end -- 817
	if key == "tower" then -- 817
		if p.phase == "tower-wait" then -- 817
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 822
		end -- 822
		if p.phase == "tower-knock" then -- 822
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 825
		end -- 825
		if p.phase == "tower-given" then -- 825
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 828
		end -- 828
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 830
	end -- 830
	return {cue = "", text = theme.introWhisper, urgent = false} -- 833
end -- 609
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 836
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 845
	local countNum = gateCountAtTick(p.countTick) -- 846
	uiDraw:drawRect( -- 847
		Rect(0, 0, w, h), -- 847
		Color( -- 847
			7, -- 847
			9, -- 847
			15, -- 847
			math.floor(78 + frac * 116 + 0.5) -- 847
		) -- 847
	) -- 847
	local cy = h * 0.56 -- 849
	art:tryPlace( -- 850
		"ink_petal_mist", -- 850
		"gate_count_mist", -- 850
		w * 0.5, -- 850
		cy, -- 850
		290, -- 850
		220, -- 850
		{ -- 850
			color = toColor(PALETTE.inkMist), -- 851
			opacity = 0.34 + frac * 0.2, -- 851
			layer = 0 -- 851
		} -- 851
	) -- 851
	drawMistCurve( -- 853
		art, -- 853
		"gate_count_wisp", -- 853
		w * 0.5, -- 853
		cy - 8, -- 853
		420, -- 853
		76, -- 853
		PALETTE.jadeMist, -- 853
		0.22, -- 853
		0 -- 853
	) -- 853
	local numZh = toChineseUpper(countNum) -- 855
	texts:put( -- 856
		"title", -- 856
		numZh, -- 856
		w * 0.5, -- 856
		cy + 8, -- 856
		toColor(PALETTE.textBright), -- 856
		0.5, -- 856
		0.5, -- 856
		"Center", -- 856
		12, -- 856
		0.42 + frac * 0.56, -- 856
		0.1 -- 856
	) -- 856
	drawHairline( -- 857
		uiInkDraw, -- 857
		art, -- 857
		"gate_count_div", -- 857
		w * 0.5, -- 857
		cy - 34, -- 857
		240, -- 857
		PALETTE.silkDim, -- 857
		0.62, -- 857
		true, -- 857
		2 -- 857
	) -- 857
	texts:put( -- 858
		"sm", -- 858
		"城外静候 · 默数至二十", -- 858
		w * 0.5, -- 858
		cy - 58, -- 858
		toColor(PALETTE.textMid), -- 858
		0.5, -- 858
		0.5, -- 858
		"Center", -- 858
		3.4, -- 858
		0.84, -- 858
		0.08 -- 858
	) -- 858
end -- 836
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 868
	local cardW = 588 -- 881
	local cardH = 382 -- 882
	local cx = (w - cardW) * 0.5 -- 883
	local cy = (h - cardH) * 0.5 + 10 -- 884
	local midX = w * 0.5 -- 885
	local midY = cy + cardH * 0.5 -- 886
	uiDraw:drawRect( -- 889
		Rect(0, 0, w, h), -- 889
		Color(7, 9, 15, 174) -- 889
	) -- 889
	art:tryPlace( -- 890
		"ink_frame_mask", -- 890
		"reg_shadow", -- 890
		midX, -- 890
		midY - 6, -- 890
		cardW + 58, -- 890
		cardH + 50, -- 890
		{ -- 890
			color = toColor(PALETTE.voidDark), -- 891
			opacity = 0.82, -- 891
			layer = -1 -- 891
		} -- 891
	) -- 891
	if not art:tryPlace( -- 891
		"ink_song_paper", -- 895
		"registry_song_paper", -- 895
		midX, -- 895
		midY, -- 895
		cardW, -- 895
		cardH, -- 895
		{opacity = 0.98, layer = 1} -- 895
	) then -- 895
		uiDraw:drawRect( -- 896
			Rect(cx, cy, cardW, cardH), -- 896
			toColor(PALETTE.xuanPaper, 246), -- 896
			1, -- 896
			toColor(PALETTE.silkDim, 180) -- 896
		) -- 896
	end -- 896
	fillRadialGlow( -- 898
		uiGlow, -- 898
		midX, -- 898
		midY + 46, -- 898
		240, -- 898
		130, -- 898
		Color(235, 224, 202, 14), -- 898
		Color(235, 224, 202, 0), -- 898
		14 -- 898
	) -- 898
	local padX = 46 -- 901
	local padY = 36 -- 902
	local inX = cx + padX -- 903
	local inY = cy + padY -- 904
	local inW = cardW - padX * 2 -- 905
	local inH = cardH - padY * 2 -- 906
	local redSilk = toColor(PALETTE.rouge, 118) -- 907
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 908
	uiInkDraw:drawRect( -- 910
		Rect(inX, inY, inW, inH), -- 910
		Color(0, 0, 0, 0), -- 910
		0.9, -- 910
		redSilk -- 910
	) -- 910
	uiInkDraw:drawRect( -- 911
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 911
		Color(0, 0, 0, 0), -- 911
		0.55, -- 911
		redSilkFaint -- 911
	) -- 911
	local headY = inY + inH - 28 -- 914
	texts:put( -- 915
		"md", -- 915
		"北塔入塔登记簿 · 末页", -- 915
		inX + 20, -- 915
		headY, -- 915
		toColor(PALETTE.xuanInk), -- 915
		0, -- 915
		0.5, -- 915
		"Left", -- 915
		2.4, -- 915
		0.94, -- 915
		0 -- 915
	) -- 915
	texts:put( -- 916
		"xs", -- 916
		"守望行记", -- 916
		inX + inW - 20, -- 916
		headY, -- 916
		toColor(PALETTE.xuanInkSub), -- 916
		1, -- 916
		0.5, -- 916
		"Right", -- 916
		2, -- 916
		0.78, -- 916
		0 -- 916
	) -- 916
	uiInkDraw:drawSegment( -- 917
		Vec2(inX + 14, headY - 22), -- 917
		Vec2(inX + inW - 14, headY - 22), -- 917
		0.85, -- 917
		redSilk -- 917
	) -- 917
	local reunion = #p.endingLines >= 2 and p.endingLines[2] ~= "" or p.storyRoute == "soldier" -- 920
	local row1Y = headY - 56 -- 921
	texts:put( -- 922
		"sm", -- 922
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 922
		inX + 20, -- 922
		row1Y, -- 922
		toColor(PALETTE.xuanInk), -- 922
		0, -- 922
		0.5, -- 922
		"Left", -- 922
		0.8, -- 922
		0.94, -- 922
		0 -- 922
	) -- 922
	texts:put( -- 923
		"xs", -- 924
		reunion and "附注：兄妹并肩抵塔；怀铜针、手书一纸。" or (("附注：" .. NEEDLE_NOTE_LINES[1]) .. " —— ") .. NEEDLE_NOTE_LINES[2], -- 925
		inX + 20, -- 926
		row1Y - 28, -- 927
		toColor(PALETTE.xuanInkSub), -- 928
		0, -- 929
		0.5, -- 930
		"Left", -- 931
		0.6, -- 932
		0.88, -- 933
		0 -- 934
	) -- 934
	uiInkDraw:drawSegment( -- 936
		Vec2(inX + 16, row1Y - 48), -- 936
		Vec2(inX + inW - 16, row1Y - 48), -- 936
		0.65, -- 936
		redSilkFaint -- 936
	) -- 936
	local blankY = row1Y - 80 -- 939
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 940
	if reunion then -- 940
		texts:put( -- 942
			"sm", -- 942
			"肆拾贰   周戍 · 兄妹同行 · 已入塔", -- 942
			inX + 20, -- 942
			blankY, -- 942
			toColor(PALETTE.xuanInk), -- 942
			0, -- 942
			0.5, -- 942
			"Left", -- 942
			0.8, -- 942
			0.94, -- 942
			0 -- 942
		) -- 942
		texts:put( -- 943
			"xs", -- 943
			"附注：门内断后脱身，同抵北塔值夜室。", -- 943
			inX + 20, -- 943
			blankY - 26, -- 943
			toColor(PALETTE.xuanInkSub), -- 943
			0, -- 943
			0.5, -- 943
			"Left", -- 943
			0.6, -- 943
			0.86, -- 943
			0 -- 943
		) -- 943
	else -- 943
		texts:put( -- 945
			"sm", -- 945
			"肆拾贰", -- 945
			inX + 20, -- 945
			blankY, -- 945
			toColor(PALETTE.rouge), -- 945
			0, -- 945
			0.5, -- 945
			"Left", -- 945
			1, -- 945
			0.92, -- 945
			0 -- 945
		) -- 945
		uiInkDraw:drawSegment( -- 946
			Vec2(inX + 94, blankY - 7), -- 946
			Vec2(inX + inW - 116, blankY - 7), -- 946
			0.95, -- 946
			toColor(PALETTE.xuanInkSub, 155 * pulse) -- 946
		) -- 946
		texts:put( -- 947
			"xs", -- 947
			"（空行留待）", -- 947
			inX + inW - 104, -- 947
			blankY, -- 947
			toColor(PALETTE.xuanInkSub), -- 947
			0, -- 947
			0.5, -- 947
			"Left", -- 947
			1, -- 947
			0.82 * pulse, -- 947
			0 -- 947
		) -- 947
	end -- 947
	if p.phase == "tower-end" then -- 947
		local signY = inY + 46 -- 952
		texts:put( -- 953
			"banner", -- 953
			"向西守望", -- 953
			midX - 18, -- 953
			signY, -- 953
			toColor(PALETTE.xuanInk), -- 953
			0.5, -- 953
			0.5, -- 953
			"Center", -- 953
			6.5, -- 953
			0.92, -- 953
			0 -- 953
		) -- 953
		drawLoneSeal( -- 954
			uiInkDraw, -- 954
			art, -- 954
			texts, -- 954
			"reg_lone_seal", -- 954
			midX + 86, -- 954
			signY, -- 954
			22, -- 954
			42, -- 954
			"守", -- 954
			"望", -- 954
			PALETTE.sealRed, -- 954
			PALETTE.sealText, -- 954
			0.92, -- 954
			4 -- 954
		) -- 954
		drawSilkVeil( -- 956
			uiDraw, -- 956
			art, -- 956
			"reg_hint_veil", -- 956
			midX, -- 956
			cy - 28, -- 956
			360, -- 956
			32, -- 956
			PALETTE.inkWash, -- 956
			0.72, -- 956
			0 -- 956
		) -- 956
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 957
		local endHint = adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 958
		texts:put( -- 959
			"xs", -- 959
			endHint, -- 959
			midX, -- 959
			cy - 28, -- 959
			toColor(PALETTE.textMid), -- 959
			0.5, -- 959
			0.5, -- 959
			"Center", -- 959
			1.6, -- 959
			0.92, -- 959
			0.08 -- 959
		) -- 959
	end -- 959
end -- 868
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 963
	local theme = themeOf(roomKey) -- 972
	local t = self.bannerT / self.bannerMax -- 973
	local alpha = 1 -- 974
	if t > 0.82 then -- 974
		alpha = (1 - t) / 0.18 -- 976
	elseif t < 0.28 then -- 976
		alpha = t / 0.28 -- 978
	end -- 978
	local cx = w * 0.5 -- 980
	local cy = h * 0.77 -- 981
	local spread = math.min(1, alpha * 1.15) -- 982
	drawSilkVeil( -- 985
		uiDraw, -- 985
		art, -- 985
		"banner_veil", -- 985
		cx, -- 985
		cy - 2, -- 985
		480 * spread + 100, -- 985
		92, -- 985
		PALETTE.inkWash, -- 985
		0.76 * alpha, -- 985
		-1 -- 985
	) -- 985
	drawMistCurve( -- 986
		art, -- 986
		"banner_mist", -- 986
		cx, -- 986
		cy + 4, -- 986
		460 * spread, -- 986
		72, -- 986
		theme.accent, -- 986
		0.28 * alpha, -- 986
		0 -- 986
	) -- 986
	drawHairline( -- 987
		uiInkDraw, -- 987
		art, -- 987
		"banner_line", -- 987
		cx, -- 987
		cy - 16, -- 987
		320 * spread, -- 987
		PALETTE.silkLine, -- 987
		0.64 * alpha, -- 987
		false, -- 987
		2 -- 987
	) -- 987
	local sep = " · " -- 990
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 991
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 992
	if theme.backdropKey ~= nil then -- 992
		texts:put( -- 994
			"lg", -- 994
			theme.titleZh, -- 994
			cx, -- 994
			cy + 14, -- 994
			toColor(PALETTE.textBright), -- 994
			0.5, -- 995
			0.5, -- 995
			"Center", -- 995
			1, -- 995
			alpha, -- 995
			0.1 -- 995
		) -- 995
	elseif idx > 0 then -- 995
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 997
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 998
		local lw = visualTextWidth(leftPart, 42) -- 999
		local rw = visualTextWidth(rightPart, 42) -- 1000
		local dotGap = 28 -- 1001
		local totalW = lw + rw + dotGap -- 1002
		local leftEdge = cx - totalW * 0.5 -- 1003
		local dotX = leftEdge + lw + dotGap * 0.5 -- 1004
		texts:put( -- 1006
			"banner", -- 1006
			leftPart, -- 1006
			leftEdge, -- 1006
			cy + 14, -- 1006
			toColor(PALETTE.textBright), -- 1006
			0, -- 1006
			0.5, -- 1006
			"Left", -- 1006
			2, -- 1006
			alpha, -- 1006
			0.1 -- 1006
		) -- 1006
		drawBlossomDot( -- 1007
			uiInkDraw, -- 1007
			art, -- 1007
			"banner_mid_dot", -- 1007
			dotX, -- 1007
			cy + 12, -- 1007
			11, -- 1007
			dotCol, -- 1007
			0.92 * alpha, -- 1007
			4 -- 1007
		) -- 1007
		texts:put( -- 1008
			"banner", -- 1008
			rightPart, -- 1008
			dotX + dotGap * 0.5, -- 1008
			cy + 14, -- 1008
			toColor(PALETTE.textBright), -- 1008
			0, -- 1008
			0.5, -- 1008
			"Left", -- 1008
			2, -- 1008
			alpha, -- 1008
			0.1 -- 1008
		) -- 1008
	else -- 1008
		texts:put( -- 1010
			"banner", -- 1010
			theme.titleZh, -- 1010
			cx, -- 1010
			cy + 14, -- 1010
			toColor(PALETTE.textBright), -- 1010
			0.5, -- 1010
			0.5, -- 1010
			"Center", -- 1010
			3, -- 1010
			alpha, -- 1010
			0.1 -- 1010
		) -- 1010
	end -- 1010
	texts:put( -- 1012
		"xs", -- 1012
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 1012
		cx, -- 1012
		cy - 34, -- 1012
		toColor(PALETTE.textMid), -- 1012
		0.5, -- 1012
		0.5, -- 1012
		"Center", -- 1012
		2.2, -- 1012
		0.82 * alpha, -- 1012
		0.08 -- 1012
	) -- 1012
end -- 963
return ____exports -- 963