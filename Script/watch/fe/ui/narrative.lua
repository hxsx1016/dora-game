-- [ts]: narrative.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
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
	if self.triggeredBeats[beatKey] then -- 89
		return -- 90
	end -- 90
	self.triggeredBeats[beatKey] = true -- 92
	if replaceCurrent then -- 93
		self.activeLine = nil -- 94
		self.activeLineT = 0 -- 95
		self.queuedLines = {} -- 96
	end -- 96
	local i = 0 -- 98
	do -- 98
		i = 0 -- 99
		while i < #lineIds do -- 99
			local d = dialogueById(lineIds[i + 1]) -- 100
			if d ~= nil then -- 101
				if self.activeLine == nil then -- 102
					self.activeLine = d -- 103
					self.activeLineT = d.duration -- 104
				else -- 104
					local ____self_queuedLines_0 = self.queuedLines -- 106
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
	if txt ~= nil and txt ~= "" then -- 114
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
	if events ~= nil then -- 126
		if events.knockPulse then -- 127
			self:showMuteCaption("knockTwo", 1.8) -- 128
		end -- 128
		if events.cartJustDocked then -- 130
			self:showMuteCaption("cartDock", 2) -- 131
		end -- 131
		if events.bottleLanded then -- 133
			local isBasin = (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 -- 134
			self:showMuteCaption(isBasin and "basinRing" or "brickClink", 2) -- 135
		end -- 135
		local ei = 0 -- 137
		do -- 137
			ei = 0 -- 138
			while ei < #events.rawEvents do -- 138
				local ev = events.rawEvents[ei + 1] -- 139
				if ev.name == "storyBeat" and ev.data.beat == "tower_door" then -- 140
					self:showMuteCaption("knockReply", 2) -- 141
				end -- 141
				ei = ei + 1 -- 138
			end -- 138
		end -- 138
	end -- 138
	if p.flash ~= "" and p.flash ~= self.lastFlashSeen then -- 145
		self.lastFlashSeen = p.flash -- 146
		if (string.find(p.flash, "枯枝", nil, true) or 0) - 1 >= 0 then -- 147
			self:showMuteCaption("twigSnap", 1.8) -- 148
		elseif (string.find(p.flash, "铁盆", nil, true) or 0) - 1 >= 0 then -- 149
			self:showMuteCaption("basinRing", 1.8) -- 150
		elseif (string.find(p.flash, "砖", nil, true) or 0) - 1 >= 0 and key == "village" then -- 151
			self:showMuteCaption("brickClink", 1.8) -- 152
		end -- 152
	end -- 152
	local calmingNow = p.escort.state == "calming" -- 157
	if calmingNow and not self.lastEscortCalming then -- 158
		self:showMuteCaption("knockTwo", 2) -- 159
		self.triggeredBeats.calming_d04 = false -- 160
		self:triggerOnce("calming_d04", {"D04"}, true) -- 161
	end -- 161
	self.lastEscortCalming = calmingNow -- 163
	if key == "prologue" then -- 166
		if p.phase == "prologue-wake" then -- 167
			self:triggerOnce("p0_wake", {"D30", "D31", "D32"}, true) -- 168
		elseif p.phase == "prologue-shadow" or p.phase == "prologue-escape" then -- 169
			self:triggerOnce("p0_shadow", {"D33", "D34"}, true) -- 170
		elseif p.phase == "prologue-wait" then -- 171
			self:triggerOnce("p1_call", {"D35", "D36"}, true) -- 172
		elseif p.phase == "prologue-give" then -- 173
			self:triggerOnce("p2_give", { -- 174
				"D01", -- 174
				"D02", -- 174
				"D03", -- 174
				"D37", -- 174
				"D38" -- 174
			}, true) -- 174
		elseif p.phase == "prologue-follow" then -- 175
			if px >= ox + 400 then -- 176
				self:triggerOnce("p3_well", {"D21", "D22", "D39"}) -- 177
			else -- 177
				self:triggerOnce("p2_wall", {"D57", "D58"}) -- 179
			end -- 179
			if interactPressed and px <= ox + 175 and math.abs(p.player.y) < 20 then -- 182
				self:triggerOnce("opt_pinwheel", {"OPT_PINWHEEL"}, true) -- 183
			end -- 183
		end -- 183
		return -- 186
	end -- 186
	if key == "s1-crossroad" then -- 189
		if px < ox + 260 then -- 190
			self:triggerOnce("s1_standoff", {"D23", "D24", "D40", "D41"}) -- 191
		elseif px >= ox + 360 and self.activeLine ~= nil and self.activeLine.id == "D23" then -- 192
			self.activeLine = nil -- 194
			self.activeLineT = 0 -- 195
			self.queuedLines = {} -- 196
		end -- 196
		return -- 198
	end -- 198
	if key == "s2-drygoods" then -- 201
		local boardOpen = false -- 202
		local bi = 0 -- 203
		do -- 203
			bi = 0 -- 204
			while bi < #p.boxes do -- 204
				if p.boxes[bi + 1].id == "s2_board_cover" and not p.boxes[bi + 1].hidden then -- 205
					boardOpen = true -- 206
					break -- 207
				end -- 207
				bi = bi + 1 -- 204
			end -- 204
		end -- 204
		if not boardOpen and px >= ox + 290 and px <= ox + 520 then -- 210
			self:triggerOnce("s2_hint_board", {"D05"}) -- 211
		end -- 211
		if boardOpen and not self.lastS2BoardOpen then -- 213
			self:showMuteCaption("boardDrop", 2) -- 214
			self:triggerOnce("s2_board_drop", {"D42"}, true) -- 215
		end -- 215
		if boardOpen and interactPressed and px >= ox + 470 and px <= ox + 640 and math.abs(p.player.y) < 20 then -- 218
			self:triggerOnce("opt_shadowdisc", {"OPT_SHADOWDISC"}, true) -- 219
		end -- 219
		self.lastS2BoardOpen = boardOpen -- 221
		return -- 222
	end -- 222
	if key == "s3-archway" then -- 225
		if px >= ox + 660 and p.partner.alive and math.abs(p.partner.x - px) <= 150 then -- 226
			self:triggerOnce("s3_rejoin", {"D06"}) -- 227
		end -- 227
		return -- 229
	end -- 229
	if key == "c2-granary" then -- 232
		if not p.cartDocked and px >= ox + 260 then -- 233
			self:triggerOnce("c2_groove", {"D07", "D43"}) -- 234
		end -- 234
		if p.cartDocked and not self.lastCartDocked then -- 236
			self:showMuteCaption("latchOpen", 2) -- 237
			self:triggerOnce("c2_docked", {"D08"}, true) -- 238
		end -- 238
		self.lastCartDocked = p.cartDocked -- 240
		return -- 241
	end -- 241
	if key == "gate" then -- 244
		if p.phase == "gate-idle" then -- 245
			self:triggerOnce("g1_winch", { -- 246
				"D09", -- 246
				"D44", -- 246
				"D45", -- 246
				"D59", -- 246
				"D60" -- 246
			}) -- 246
		elseif p.phase == "gate-hold" then -- 247
			if self.activeLine ~= nil then -- 249
				self.activeLine = nil -- 250
				self.activeLineT = 0 -- 251
				self.queuedLines = {} -- 252
			end -- 252
		elseif p.phase == "gate-send" then -- 254
			self:triggerOnce("g3_farewell", { -- 255
				"D10", -- 255
				"D61", -- 255
				"D62", -- 255
				"D46", -- 255
				"D47", -- 255
				"D12" -- 255
			}, true) -- 255
		elseif p.phase == "gate-wait" then -- 256
			self:triggerOnce("g4_reunion_call", {"D48", "D49", "D50"}, true) -- 257
		end -- 257
		return -- 259
	end -- 259
	if key == "gatepath" then -- 262
		self:triggerOnce("g06_north", {"G06A", "G06B", "D51", "D52"}) -- 263
		return -- 264
	end -- 264
	if key == "village" then -- 267
		if p.passed and px >= ox + 550 and px <= ox + 690 then -- 269
			self:triggerOnce("v3_grate_ask", {"D27"}) -- 270
			if interactPressed and self.triggeredBeats.v3_grate_ask then -- 271
				self:triggerOnce("v3_grate_reply", {"D28", "D29"}, true) -- 272
			end -- 272
		end -- 272
		return -- 275
	end -- 275
	if key == "tower" then -- 278
		if p.phase == "tower-wait" and interactPressed and px >= ox + 300 and px <= ox + 385 then -- 280
			self:triggerOnce("opt_lantern", {"OPT_LANTERN"}, true) -- 281
		elseif p.phase == "tower-knock" then -- 282
			self:triggerOnce("t2_knock", {"D14", "D15"}, true) -- 283
		elseif p.phase == "tower-enter" or p.phase == "tower-desk" then -- 284
			if p.storyRoute == "soldier" then -- 285
				self:triggerOnce("t3_soldier_talk", { -- 286
					"D53", -- 286
					"D54", -- 286
					"D16", -- 286
					"D17", -- 286
					"D63", -- 286
					"D64" -- 286
				}, true) -- 286
			else -- 286
				self:triggerOnce("t3_child_talk", { -- 288
					"D16", -- 288
					"D17", -- 288
					"D63", -- 288
					"D64", -- 288
					"D18", -- 288
					"D19" -- 288
				}, true) -- 288
			end -- 288
		elseif p.phase == "tower-end" and p.storyRoute == "soldier" then -- 290
			self:triggerOnce("t3_reunion_end", {"D55", "D56", "D65"}, true) -- 291
		end -- 291
	end -- 291
end -- 120
function NarrativeRenderer.prototype.update(self, dt, p, events, interactPressed) -- 296
	if interactPressed == nil then -- 296
		interactPressed = false -- 296
	end -- 296
	self.time = self.time + dt -- 297
	if self.lastRoomKey ~= p.room.key then -- 298
		self:onEnterRoom(p.room.key) -- 299
	end -- 299
	if self.muteCaptionT > 0 then -- 301
		self.muteCaptionT = math.max(0, self.muteCaptionT - dt) -- 302
	end -- 302
	if self.activeLine ~= nil then -- 304
		self.activeLineT = self.activeLineT - dt -- 305
		if self.activeLineT <= 0 then -- 306
			local next = table.remove(self.queuedLines, 1) -- 307
			self.activeLine = next -- 308
			self.activeLineT = next ~= nil and next.duration or 0 -- 309
		end -- 309
	end -- 309
	self:stepScriptedBeats(p, events, interactPressed) -- 312
	local wantCinema = p.room.key == "prologue" and p.phase == "prologue-give" or p.room.key == "gate" and (p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand") or p.reloadOpen or (p.room.key == "tower" or p.room.key == "museum") and p.phase ~= "tower-wait" -- 314
	local target = wantCinema and 1 or 0 -- 319
	self.letterbox = self.letterbox + (target - self.letterbox) * math.min(1, dt * 4.5) -- 320
	if self.bannerT > 0 then -- 322
		self.bannerT = math.max(0, self.bannerT - dt) -- 323
	end -- 323
	if self.wipeT > 0 then -- 325
		self.wipeT = math.max(0, self.wipeT - dt * 2.4) -- 326
	end -- 326
end -- 296
function NarrativeRenderer.prototype.draw(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 330
	if assistHintsEnabled == nil then -- 339
		assistHintsEnabled = false -- 339
	end -- 339
	if inputMode == nil then -- 340
		inputMode = "kbm" -- 340
	end -- 340
	if gamepadLayout == nil then -- 341
		gamepadLayout = "xbox" -- 341
	end -- 341
	if safe == nil then -- 342
		safe = ZERO_SAFE_INSETS -- 342
	end -- 342
	if self.letterbox > 0.01 then -- 345
		local barH = math.floor(70 * self.letterbox + 0.5) -- 346
		uiDraw:drawRect( -- 347
			Rect(0, h - barH, w, barH), -- 347
			Color(8, 10, 16, 242) -- 347
		) -- 347
		uiDraw:drawRect( -- 348
			Rect(0, 0, w, barH), -- 348
			Color(8, 10, 16, 242) -- 348
		) -- 348
		uiInkDraw:drawSegment( -- 349
			Vec2(0, h - barH), -- 349
			Vec2(w, h - barH), -- 349
			0.7, -- 349
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 349
		) -- 349
		uiInkDraw:drawSegment( -- 350
			Vec2(0, barH), -- 350
			Vec2(w, barH), -- 350
			0.7, -- 350
			toColor(PALETTE.silkDim, 70 * self.letterbox) -- 350
		) -- 350
	end -- 350
	if p.room.key == "gate" and p.phase == "gate-count" then -- 354
		self:drawGateCountOverlay( -- 355
			uiDraw, -- 355
			uiInkDraw, -- 355
			art, -- 355
			texts, -- 355
			p, -- 355
			w, -- 355
			h -- 355
		) -- 355
	end -- 355
	local showRegistry = p.room.key == "tower" and (p.phase == "tower-end" or p.phase == "tower-given" and p.phaseTick >= 120) -- 359
	if showRegistry then -- 360
		self:drawTowerRegistryCard( -- 361
			uiDraw, -- 361
			uiInkDraw, -- 361
			uiGlow, -- 361
			art, -- 361
			texts, -- 361
			p, -- 361
			w, -- 361
			h, -- 361
			assistHintsEnabled, -- 361
			inputMode, -- 361
			gamepadLayout -- 361
		) -- 361
	end -- 361
	if not p.paused and not showRegistry then -- 365
		self:drawSubtitleStrip( -- 366
			uiDraw, -- 366
			uiInkDraw, -- 366
			art, -- 366
			texts, -- 366
			p, -- 366
			w, -- 366
			h, -- 366
			assistHintsEnabled, -- 366
			inputMode, -- 366
			gamepadLayout, -- 366
			safe -- 366
		) -- 366
	end -- 366
	if self.bannerT > 0 and not p.paused then -- 370
		self:drawAreaBanner( -- 371
			uiDraw, -- 371
			uiInkDraw, -- 371
			art, -- 371
			texts, -- 371
			p.room.key, -- 371
			w, -- 371
			h -- 371
		) -- 371
	end -- 371
	if self.wipeT > 0.01 then -- 375
		local k = math.min(1, self.wipeT * 1.15) -- 376
		local a = math.floor(255 * k * k + 0.5) -- 377
		uiDraw:drawRect( -- 378
			Rect(0, 0, w, h), -- 378
			Color(9, 11, 17, a) -- 378
		) -- 378
		art:tryPlace( -- 379
			"ink_petal_mist", -- 379
			"wipe_mist", -- 379
			w * 0.5, -- 379
			h * 0.5, -- 379
			w * 0.65, -- 379
			h * 0.65, -- 379
			{ -- 379
				color = toColor(PALETTE.inkMist), -- 380
				opacity = 0.2 * self.wipeT, -- 380
				layer = 5 -- 380
			} -- 380
		) -- 380
	end -- 380
end -- 330
function NarrativeRenderer.prototype.drawSubtitleStrip(self, uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe) -- 385
	local cx = w * 0.5 -- 398
	local touchLift = inputMode == "touch" and self.letterbox <= 0.4 and 22 or 0 -- 399
	local cy = (self.letterbox > 0.4 and 36 or 42) + touchLift + safe.bottom * 0.5 -- 400
	if self.muteCaptionT > 0 and self.muteCaption ~= "" then -- 403
		local capAlpha = math.min(1, self.muteCaptionT * 2.5) -- 404
		local capY = cy + 44 -- 405
		drawSilkVeil( -- 406
			uiDraw, -- 406
			art, -- 406
			"mute_sfx_veil", -- 406
			cx, -- 406
			capY, -- 406
			172, -- 406
			26, -- 406
			PALETTE.inkWarm, -- 406
			0.76 * capAlpha, -- 406
			0 -- 406
		) -- 406
		texts:put( -- 407
			"xs", -- 407
			self.muteCaption, -- 407
			cx, -- 407
			capY, -- 407
			toColor(PALETTE.amberCore), -- 407
			0.5, -- 407
			0.5, -- 407
			"Center", -- 407
			1.4, -- 407
			0.94 * capAlpha, -- 407
			0.08 -- 407
		) -- 407
	end -- 407
	local rawLine = self:composeNarrativeLine(p, assistHintsEnabled) -- 410
	if rawLine.text == "" then -- 411
		return -- 412
	end -- 412
	local line = { -- 414
		cue = rawLine.cue, -- 415
		text = assistHintsEnabled and adaptHintSentence(rawLine.text, inputMode, gamepadLayout) or rawLine.text, -- 416
		urgent = rawLine.urgent -- 417
	} -- 417
	local hasCue = line.cue ~= "" -- 419
	local textW = visualTextWidth(line.text, 18) -- 420
	local contentW = textW + (hasCue and 48 or 0) -- 421
	local stripW = math.min( -- 422
		w - 72 - safe.left - safe.right, -- 422
		math.max(540, contentW + 210) -- 422
	) -- 422
	local stripH = 54 -- 423
	drawSilkVeil( -- 426
		uiDraw, -- 426
		art, -- 426
		"sub_veil", -- 426
		cx, -- 426
		cy, -- 426
		stripW, -- 426
		stripH, -- 426
		line.urgent and PALETTE.inkWarm or PALETTE.inkWash, -- 426
		0.84, -- 426
		-1 -- 426
	) -- 426
	local railCol = line.urgent and PALETTE.rouge or PALETTE.silkDim -- 428
	drawHairline( -- 429
		uiInkDraw, -- 429
		art, -- 429
		"sub_top_line", -- 429
		cx, -- 429
		cy + 23, -- 429
		stripW * 0.72, -- 429
		railCol, -- 429
		line.urgent and 0.72 or 0.52, -- 429
		true, -- 429
		2 -- 429
	) -- 429
	if hasCue then -- 431
		local startX = cx - contentW * 0.5 -- 432
		local cueCol = line.urgent and PALETTE.rouge or (p.childMode and PALETTE.amber or PALETTE.cyan) -- 433
		drawBlossomDot( -- 434
			uiInkDraw, -- 434
			art, -- 434
			"sub_cue_dot", -- 434
			startX + 6, -- 434
			cy - 1, -- 434
			10, -- 434
			cueCol, -- 434
			0.94, -- 434
			4 -- 434
		) -- 434
		texts:put( -- 435
			"xs", -- 435
			line.cue, -- 435
			startX + 24, -- 435
			cy - 1, -- 435
			toColor(line.urgent and PALETTE.crimsonCore or cueCol), -- 435
			0.5, -- 435
			0.5, -- 435
			"Center", -- 435
			0, -- 435
			0.96, -- 435
			0.08 -- 435
		) -- 435
		uiInkDraw:drawSegment( -- 436
			Vec2(startX + 38, cy - 8), -- 436
			Vec2(startX + 38, cy + 6), -- 436
			0.75, -- 436
			toColor(PALETTE.silkDim, 115) -- 436
		) -- 436
		texts:put( -- 437
			"sm", -- 437
			line.text, -- 437
			startX + 48, -- 437
			cy - 1, -- 437
			toColor(line.urgent and PALETTE.crimsonCore or PALETTE.textBright), -- 437
			0, -- 437
			0.5, -- 437
			"Left", -- 437
			0.9, -- 437
			0.98, -- 437
			0.08 -- 437
		) -- 437
	else -- 437
		texts:put( -- 439
			"sm", -- 439
			line.text, -- 439
			cx, -- 439
			cy - 1, -- 439
			toColor(PALETTE.textBright), -- 439
			0.5, -- 439
			0.5, -- 439
			"Center", -- 439
			1, -- 439
			0.98, -- 439
			0.08 -- 439
		) -- 439
	end -- 439
end -- 385
function NarrativeRenderer.prototype.composeNarrativeLine(self, p, assistHintsEnabled) -- 444
	local key = p.room.key -- 445
	local theme = themeOf(key) -- 446
	if key == "gate" and p.phase == "gate-count" then -- 448
		if p.countTick >= GATE_COUNT_END then -- 449
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 450
		end -- 450
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 456
	end -- 456
	if not assistHintsEnabled then -- 459
		if self.activeLine ~= nil then -- 461
			local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 462
			local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 465
			return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 467
		end -- 467
		if key == "prologue" and p.phase == "prologue-give" then -- 469
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 470
		end -- 470
		if key == "checkpoint" and p.escort.state == "calming" then -- 472
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 473
		end -- 473
		if key == "tower" then -- 475
			if p.phase == "tower-knock" then -- 476
				return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 477
			end -- 477
			if p.phase == "tower-given" then -- 479
				return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 480
			end -- 480
		end -- 480
		if p.flash ~= "" and p.flashT > 0 then -- 483
			local fl = p.flash -- 485
			local hasKeyHint = (string.find(fl, "按 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "点 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 E", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按住 F", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Shift", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 Ctrl", nil, true) or 0) - 1 >= 0 or (string.find(fl, "A/D", nil, true) or 0) - 1 >= 0 or (string.find(fl, "限时", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 再玩", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拉开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 敲", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 递", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 送", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 交", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 拿", nil, true) or 0) - 1 >= 0 or (string.find(fl, "E 开", nil, true) or 0) - 1 >= 0 or (string.find(fl, "按 1", nil, true) or 0) - 1 >= 0 -- 486
			if not hasKeyHint then -- 504
				local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 505
				local text = p.flash -- 506
				local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 507
				if key == "tower" or key == "prologue" then -- 508
					cue = "" -- 509
				end -- 509
				if text == "命中" then -- 511
					text = "倭寇击倒" -- 512
				elseif text == "打空" then -- 513
					text = "铅丸偏离或被掩体阻挡" -- 514
				elseif text == "翻滚" then -- 515
					text = "伏身翻滚回避" -- 516
				end -- 516
				return {cue = cue, text = text, urgent = isDanger} -- 518
			end -- 518
		end -- 518
		return {cue = "", text = "", urgent = false} -- 521
	end -- 521
	if key == "gate" and p.phase == "gate-hold" then -- 524
		local threatened = false -- 525
		local hasAliveEnemy = false -- 526
		local i = 0 -- 527
		do -- 527
			i = 0 -- 528
			while i < #p.enemies do -- 528
				if p.enemies[i + 1].alive then -- 529
					hasAliveEnemy = true -- 530
					if p.enemies[i + 1].warnT > 0 then -- 531
						threatened = true -- 532
					end -- 532
				end -- 532
				i = i + 1 -- 528
			end -- 528
		end -- 528
		if threatened then -- 536
			return {cue = "警", text = "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent = true} -- 537
		end -- 537
		if p.coverHug then -- 539
			if hasAliveEnemy and not p.coverBlocking then -- 540
				return {cue = "警", text = "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent = true} -- 541
			end -- 541
			return {cue = "掩", text = "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent = false} -- 543
		end -- 543
		return {cue = "守", text = "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent = false} -- 545
	end -- 545
	if key == "gate" and p.phase == "gate-count" then -- 548
		if p.countTick >= GATE_COUNT_END then -- 549
			return {cue = "", text = "……二十了。我往北去了。", urgent = false} -- 550
		end -- 550
		return {cue = "", text = "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent = false} -- 556
	end -- 556
	if self.activeLine ~= nil then -- 559
		local spoken = self.activeLine.who ~= "" and ((self.activeLine.who .. "：「") .. self.activeLine.text) .. "」" or self.activeLine.text -- 560
		local cue = self.activeLine.who == "周戍" and "兄" or (self.activeLine.who == "小满" and "妹" or "") -- 563
		return {cue = cue, text = spoken, urgent = self.activeLine.urgent == true} -- 565
	end -- 565
	if p.flash ~= "" and p.flashT > 0 then -- 568
		local isDanger = (string.find(p.flash, "中弹", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "被抓", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "击倒", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "看见", nil, true) or 0) - 1 >= 0 or (string.find(p.flash, "追", nil, true) or 0) - 1 >= 0 -- 569
		local text = p.flash -- 570
		local cue = isDanger and "危" or (p.childMode and "潜" or "战") -- 571
		if key == "tower" or key == "prologue" then -- 572
			cue = "" -- 573
		end -- 573
		if text == "命中" then -- 575
			text = "倭寇击倒 —— 继续推进并留意掩体" -- 576
		elseif text == "打空" then -- 577
			text = "铅丸偏离或被掩体阻挡" -- 578
		elseif text == "翻滚" then -- 579
			text = "伏身翻滚回避" -- 580
		end -- 580
		return {cue = cue, text = text, urgent = isDanger} -- 582
	end -- 582
	if key == "prologue" then -- 585
		if p.phase == "prologue-wait" then -- 586
			return {cue = "", text = "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent = false} -- 587
		end -- 587
		if p.phase == "prologue-give" then -- 589
			return {cue = "", text = "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent = false} -- 590
		end -- 590
		return {cue = "", text = "带小满往右，从两根门柱之间穿过", urgent = false} -- 592
	end -- 592
	if key == "street" then -- 595
		local alive = 0 -- 596
		local i = 0 -- 597
		do -- 597
			i = 0 -- 598
			while i < #p.enemies do -- 598
				if p.enemies[i + 1].alive then -- 599
					alive = alive + 1 -- 599
				end -- 599
				i = i + 1 -- 598
			end -- 598
		end -- 598
		if alive > 0 then -- 601
			return {cue = "战", text = "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent = false} -- 602
		end -- 602
		return {cue = "", text = "带小满穿过右侧门洞，进入检查站", urgent = false} -- 604
	end -- 604
	if key == "checkpoint" then -- 607
		if p.escort.state == "frozen" then -- 608
			return {cue = "危", text = "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent = true} -- 609
		end -- 609
		if p.escort.state == "calming" then -- 611
			return {cue = "", text = "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent = false} -- 612
		end -- 612
		if not p.cartDocked then -- 614
			return {cue = "机", text = "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent = false} -- 615
		end -- 615
		return {cue = "归", text = "车轮落窝了。带小满从右侧门洞出去", urgent = false} -- 617
	end -- 617
	if key == "gate" then -- 620
		if p.phase == "gate-idle" then -- 621
			return {cue = p.gateNeedConfirm and "警" or "", text = p.gateNeedConfirm and "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" or "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒", urgent = p.gateNeedConfirm} -- 622
		end -- 622
		if p.phase == "gate-send" then -- 628
			return {cue = "", text = "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent = false} -- 629
		end -- 629
		return {cue = "", text = "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent = false} -- 631
	end -- 631
	if key == "outside" then -- 634
		if not p.cartDocked then -- 635
			return {cue = "", text = "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent = false} -- 636
		end -- 636
		if p.checkpoint < p.room.arch.x1 then -- 638
			return {cue = "潜", text = "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent = false} -- 639
		end -- 639
		return {cue = "", text = "穿过矮拱，沿墙根小路向北塔灯火前行", urgent = false} -- 641
	end -- 641
	if key == "village" then -- 644
		if p.scavChase then -- 645
			return {cue = "危", text = "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent = true} -- 646
		end -- 646
		if p.passed then -- 648
			return {cue = "", text = "越过了第一院。继续向右，走进通往北塔的森林", urgent = false} -- 649
		end -- 649
		if p.hasBottle then -- 651
			return {cue = "诱", text = "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent = false} -- 652
		end -- 652
		if p.bottleFly ~= nil then -- 654
			return {cue = "潜", text = "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent = false} -- 655
		end -- 655
		if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 657
			return {cue = "潜", text = "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent = false} -- 658
		end -- 658
		return {cue = "", text = "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent = false} -- 660
	end -- 660
	if key == "forest" then -- 663
		if p.dogState == "chase" then -- 664
			return {cue = "危", text = "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent = true} -- 665
		end -- 665
		if p.dogState == "ear" then -- 667
			return {cue = "警", text = "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent = true} -- 668
		end -- 668
		return {cue = "", text = "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent = false} -- 670
	end -- 670
	if key == "tower" then -- 673
		if p.phase == "tower-wait" then -- 674
			return {cue = "", text = "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent = false} -- 675
		end -- 675
		if p.phase == "tower-knock" then -- 677
			return {cue = "", text = "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent = false} -- 678
		end -- 678
		if p.phase == "tower-given" then -- 680
			return {cue = "", text = "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent = false} -- 681
		end -- 681
		return {cue = "", text = "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent = false} -- 683
	end -- 683
	return {cue = "", text = theme.introWhisper, urgent = false} -- 686
end -- 444
function NarrativeRenderer.prototype.drawGateCountOverlay(self, uiDraw, uiInkDraw, art, texts, p, w, h) -- 689
	local frac = math.min(1, p.countTick / GATE_COUNT_END) -- 698
	local countNum = gateCountAtTick(p.countTick) -- 699
	uiDraw:drawRect( -- 700
		Rect(0, 0, w, h), -- 700
		Color( -- 700
			7, -- 700
			9, -- 700
			15, -- 700
			math.floor(78 + frac * 116 + 0.5) -- 700
		) -- 700
	) -- 700
	local cy = h * 0.56 -- 702
	art:tryPlace( -- 703
		"ink_petal_mist", -- 703
		"gate_count_mist", -- 703
		w * 0.5, -- 703
		cy, -- 703
		290, -- 703
		220, -- 703
		{ -- 703
			color = toColor(PALETTE.inkMist), -- 704
			opacity = 0.34 + frac * 0.2, -- 704
			layer = 0 -- 704
		} -- 704
	) -- 704
	drawMistCurve( -- 706
		art, -- 706
		"gate_count_wisp", -- 706
		w * 0.5, -- 706
		cy - 8, -- 706
		420, -- 706
		76, -- 706
		PALETTE.jadeMist, -- 706
		0.22, -- 706
		0 -- 706
	) -- 706
	local numZh = toChineseUpper(countNum) -- 708
	texts:put( -- 709
		"title", -- 709
		numZh, -- 709
		w * 0.5, -- 709
		cy + 8, -- 709
		toColor(PALETTE.textBright), -- 709
		0.5, -- 709
		0.5, -- 709
		"Center", -- 709
		12, -- 709
		0.42 + frac * 0.56, -- 709
		0.1 -- 709
	) -- 709
	drawHairline( -- 710
		uiInkDraw, -- 710
		art, -- 710
		"gate_count_div", -- 710
		w * 0.5, -- 710
		cy - 34, -- 710
		240, -- 710
		PALETTE.silkDim, -- 710
		0.62, -- 710
		true, -- 710
		2 -- 710
	) -- 710
	texts:put( -- 711
		"sm", -- 711
		"城外静候 · 默数至二十", -- 711
		w * 0.5, -- 711
		cy - 58, -- 711
		toColor(PALETTE.textMid), -- 711
		0.5, -- 711
		0.5, -- 711
		"Center", -- 711
		3.4, -- 711
		0.84, -- 711
		0.08 -- 711
	) -- 711
end -- 689
function NarrativeRenderer.prototype.drawTowerRegistryCard(self, uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout) -- 721
	local cardW = 588 -- 734
	local cardH = 382 -- 735
	local cx = (w - cardW) * 0.5 -- 736
	local cy = (h - cardH) * 0.5 + 10 -- 737
	local midX = w * 0.5 -- 738
	local midY = cy + cardH * 0.5 -- 739
	uiDraw:drawRect( -- 742
		Rect(0, 0, w, h), -- 742
		Color(7, 9, 15, 174) -- 742
	) -- 742
	art:tryPlace( -- 743
		"ink_frame_mask", -- 743
		"reg_shadow", -- 743
		midX, -- 743
		midY - 6, -- 743
		cardW + 58, -- 743
		cardH + 50, -- 743
		{ -- 743
			color = toColor(PALETTE.voidDark), -- 744
			opacity = 0.82, -- 744
			layer = -1 -- 744
		} -- 744
	) -- 744
	if not art:tryPlace( -- 748
		"ink_song_paper", -- 748
		"registry_song_paper", -- 748
		midX, -- 748
		midY, -- 748
		cardW, -- 748
		cardH, -- 748
		{opacity = 0.98, layer = 1} -- 748
	) then -- 748
		uiDraw:drawRect( -- 749
			Rect(cx, cy, cardW, cardH), -- 749
			toColor(PALETTE.xuanPaper, 246), -- 749
			1, -- 749
			toColor(PALETTE.silkDim, 180) -- 749
		) -- 749
	end -- 749
	fillRadialGlow( -- 751
		uiGlow, -- 751
		midX, -- 751
		midY + 46, -- 751
		240, -- 751
		130, -- 751
		Color(235, 224, 202, 14), -- 751
		Color(235, 224, 202, 0), -- 751
		14 -- 751
	) -- 751
	local padX = 46 -- 754
	local padY = 36 -- 755
	local inX = cx + padX -- 756
	local inY = cy + padY -- 757
	local inW = cardW - padX * 2 -- 758
	local inH = cardH - padY * 2 -- 759
	local redSilk = toColor(PALETTE.rouge, 118) -- 760
	local redSilkFaint = toColor(PALETTE.rouge, 64) -- 761
	uiInkDraw:drawRect( -- 763
		Rect(inX, inY, inW, inH), -- 763
		Color(0, 0, 0, 0), -- 763
		0.9, -- 763
		redSilk -- 763
	) -- 763
	uiInkDraw:drawRect( -- 764
		Rect(inX + 4, inY + 4, inW - 8, inH - 8), -- 764
		Color(0, 0, 0, 0), -- 764
		0.55, -- 764
		redSilkFaint -- 764
	) -- 764
	local headY = inY + inH - 28 -- 767
	texts:put( -- 768
		"md", -- 768
		"北塔入塔登记簿 · 末页", -- 768
		inX + 20, -- 768
		headY, -- 768
		toColor(PALETTE.xuanInk), -- 768
		0, -- 768
		0.5, -- 768
		"Left", -- 768
		2.4, -- 768
		0.94, -- 768
		0 -- 768
	) -- 768
	texts:put( -- 769
		"xs", -- 769
		"守望行记", -- 769
		inX + inW - 20, -- 769
		headY, -- 769
		toColor(PALETTE.xuanInkSub), -- 769
		1, -- 769
		0.5, -- 769
		"Right", -- 769
		2, -- 769
		0.78, -- 769
		0 -- 769
	) -- 769
	uiInkDraw:drawSegment( -- 770
		Vec2(inX + 14, headY - 22), -- 770
		Vec2(inX + inW - 14, headY - 22), -- 770
		0.85, -- 770
		redSilk -- 770
	) -- 770
	local reunion = #p.endingLines >= 2 and p.endingLines[2] ~= "" or p.storyRoute == "soldier" -- 773
	local row1Y = headY - 56 -- 774
	texts:put( -- 775
		"sm", -- 775
		"肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", -- 775
		inX + 20, -- 775
		row1Y, -- 775
		toColor(PALETTE.xuanInk), -- 775
		0, -- 775
		0.5, -- 775
		"Left", -- 775
		0.8, -- 775
		0.94, -- 775
		0 -- 775
	) -- 775
	texts:put( -- 776
		"xs", -- 777
		reunion and "附注：兄妹并肩抵塔；怀铜针、手书一纸。" or (("附注：" .. NEEDLE_NOTE_LINES[1]) .. " —— ") .. NEEDLE_NOTE_LINES[2], -- 778
		inX + 20, -- 779
		row1Y - 28, -- 780
		toColor(PALETTE.xuanInkSub), -- 781
		0, -- 782
		0.5, -- 783
		"Left", -- 784
		0.6, -- 785
		0.88, -- 786
		0 -- 787
	) -- 787
	uiInkDraw:drawSegment( -- 789
		Vec2(inX + 16, row1Y - 48), -- 789
		Vec2(inX + inW - 16, row1Y - 48), -- 789
		0.65, -- 789
		redSilkFaint -- 789
	) -- 789
	local blankY = row1Y - 80 -- 792
	local pulse = 0.66 + 0.34 * math.sin(self.time * 2.2) -- 793
	if reunion then -- 794
		texts:put( -- 795
			"sm", -- 795
			"肆拾贰   周戍 · 兄妹同行 · 已入塔", -- 795
			inX + 20, -- 795
			blankY, -- 795
			toColor(PALETTE.xuanInk), -- 795
			0, -- 795
			0.5, -- 795
			"Left", -- 795
			0.8, -- 795
			0.94, -- 795
			0 -- 795
		) -- 795
		texts:put( -- 796
			"xs", -- 796
			"附注：门内断后脱身，同抵北塔值夜室。", -- 796
			inX + 20, -- 796
			blankY - 26, -- 796
			toColor(PALETTE.xuanInkSub), -- 796
			0, -- 796
			0.5, -- 796
			"Left", -- 796
			0.6, -- 796
			0.86, -- 796
			0 -- 796
		) -- 796
	else -- 796
		texts:put( -- 798
			"sm", -- 798
			"肆拾贰", -- 798
			inX + 20, -- 798
			blankY, -- 798
			toColor(PALETTE.rouge), -- 798
			0, -- 798
			0.5, -- 798
			"Left", -- 798
			1, -- 798
			0.92, -- 798
			0 -- 798
		) -- 798
		uiInkDraw:drawSegment( -- 799
			Vec2(inX + 94, blankY - 7), -- 799
			Vec2(inX + inW - 116, blankY - 7), -- 799
			0.95, -- 799
			toColor(PALETTE.xuanInkSub, 155 * pulse) -- 799
		) -- 799
		texts:put( -- 800
			"xs", -- 800
			"（空行留待）", -- 800
			inX + inW - 104, -- 800
			blankY, -- 800
			toColor(PALETTE.xuanInkSub), -- 800
			0, -- 800
			0.5, -- 800
			"Left", -- 800
			1, -- 800
			0.82 * pulse, -- 800
			0 -- 800
		) -- 800
	end -- 800
	if p.phase == "tower-end" then -- 804
		local signY = inY + 46 -- 805
		texts:put( -- 806
			"banner", -- 806
			"向西守望", -- 806
			midX - 18, -- 806
			signY, -- 806
			toColor(PALETTE.xuanInk), -- 806
			0.5, -- 806
			0.5, -- 806
			"Center", -- 806
			6.5, -- 806
			0.92, -- 806
			0 -- 806
		) -- 806
		drawLoneSeal( -- 807
			uiInkDraw, -- 807
			art, -- 807
			texts, -- 807
			"reg_lone_seal", -- 807
			midX + 86, -- 807
			signY, -- 807
			22, -- 807
			42, -- 807
			"守", -- 807
			"望", -- 807
			PALETTE.sealRed, -- 807
			PALETTE.sealText, -- 807
			0.92, -- 807
			4 -- 807
		) -- 807
		drawSilkVeil( -- 809
			uiDraw, -- 809
			art, -- 809
			"reg_hint_veil", -- 809
			midX, -- 809
			cy - 28, -- 809
			360, -- 809
			32, -- 809
			PALETTE.inkWash, -- 809
			0.72, -- 809
			0 -- 809
		) -- 809
		local rawEndHint = assistHintsEnabled and "按 E 再次启程     ·     Esc 暂歇" or "Esc 暂歇" -- 810
		local endHint = adaptHintSentence(rawEndHint, inputMode, gamepadLayout) -- 811
		texts:put( -- 812
			"xs", -- 812
			endHint, -- 812
			midX, -- 812
			cy - 28, -- 812
			toColor(PALETTE.textMid), -- 812
			0.5, -- 812
			0.5, -- 812
			"Center", -- 812
			1.6, -- 812
			0.92, -- 812
			0.08 -- 812
		) -- 812
	end -- 812
end -- 721
function NarrativeRenderer.prototype.drawAreaBanner(self, uiDraw, uiInkDraw, art, texts, roomKey, w, h) -- 816
	local theme = themeOf(roomKey) -- 825
	local t = self.bannerT / self.bannerMax -- 826
	local alpha = 1 -- 827
	if t > 0.82 then -- 828
		alpha = (1 - t) / 0.18 -- 829
	elseif t < 0.28 then -- 830
		alpha = t / 0.28 -- 831
	end -- 831
	local cx = w * 0.5 -- 833
	local cy = h * 0.77 -- 834
	local spread = math.min(1, alpha * 1.15) -- 835
	drawSilkVeil( -- 838
		uiDraw, -- 838
		art, -- 838
		"banner_veil", -- 838
		cx, -- 838
		cy - 2, -- 838
		480 * spread + 100, -- 838
		92, -- 838
		PALETTE.inkWash, -- 838
		0.76 * alpha, -- 838
		-1 -- 838
	) -- 838
	drawMistCurve( -- 839
		art, -- 839
		"banner_mist", -- 839
		cx, -- 839
		cy + 4, -- 839
		460 * spread, -- 839
		72, -- 839
		theme.accent, -- 839
		0.28 * alpha, -- 839
		0 -- 839
	) -- 839
	drawHairline( -- 840
		uiInkDraw, -- 840
		art, -- 840
		"banner_line", -- 840
		cx, -- 840
		cy - 16, -- 840
		320 * spread, -- 840
		PALETTE.silkLine, -- 840
		0.64 * alpha, -- 840
		false, -- 840
		2 -- 840
	) -- 840
	local sep = " · " -- 843
	local idx = (string.find(theme.titleZh, sep, nil, true) or 0) - 1 -- 844
	local dotCol = roomKey == "gate" and PALETTE.rouge or PALETTE.silkLine -- 845
	if theme.backdropKey ~= nil then -- 846
		texts:put( -- 847
			"lg", -- 847
			theme.titleZh, -- 847
			cx, -- 847
			cy + 14, -- 847
			toColor(PALETTE.textBright), -- 847
			0.5, -- 848
			0.5, -- 848
			"Center", -- 848
			1, -- 848
			alpha, -- 848
			0.1 -- 848
		) -- 848
	elseif idx > 0 then -- 849
		local leftPart = __TS__StringSlice(theme.titleZh, 0, idx) -- 850
		local rightPart = __TS__StringSlice(theme.titleZh, idx + #sep) -- 851
		local lw = visualTextWidth(leftPart, 42) -- 852
		local rw = visualTextWidth(rightPart, 42) -- 853
		local dotGap = 28 -- 854
		local totalW = lw + rw + dotGap -- 855
		local leftEdge = cx - totalW * 0.5 -- 856
		local dotX = leftEdge + lw + dotGap * 0.5 -- 857
		texts:put( -- 859
			"banner", -- 859
			leftPart, -- 859
			leftEdge, -- 859
			cy + 14, -- 859
			toColor(PALETTE.textBright), -- 859
			0, -- 859
			0.5, -- 859
			"Left", -- 859
			2, -- 859
			alpha, -- 859
			0.1 -- 859
		) -- 859
		drawBlossomDot( -- 860
			uiInkDraw, -- 860
			art, -- 860
			"banner_mid_dot", -- 860
			dotX, -- 860
			cy + 12, -- 860
			11, -- 860
			dotCol, -- 860
			0.92 * alpha, -- 860
			4 -- 860
		) -- 860
		texts:put( -- 861
			"banner", -- 861
			rightPart, -- 861
			dotX + dotGap * 0.5, -- 861
			cy + 14, -- 861
			toColor(PALETTE.textBright), -- 861
			0, -- 861
			0.5, -- 861
			"Left", -- 861
			2, -- 861
			alpha, -- 861
			0.1 -- 861
		) -- 861
	else -- 861
		texts:put( -- 863
			"banner", -- 863
			theme.titleZh, -- 863
			cx, -- 863
			cy + 14, -- 863
			toColor(PALETTE.textBright), -- 863
			0.5, -- 863
			0.5, -- 863
			"Center", -- 863
			3, -- 863
			alpha, -- 863
			0.1 -- 863
		) -- 863
	end -- 863
	texts:put( -- 865
		"xs", -- 865
		(theme.actCode .. "  ·  ") .. theme.volumeTagZh, -- 865
		cx, -- 865
		cy - 34, -- 865
		toColor(PALETTE.textMid), -- 865
		0.5, -- 865
		0.5, -- 865
		"Center", -- 865
		2.2, -- 865
		0.82 * alpha, -- 865
		0.08 -- 865
	) -- 865
end -- 816
return ____exports -- 816
