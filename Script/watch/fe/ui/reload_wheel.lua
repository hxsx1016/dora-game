-- [ts]: reload_wheel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Keyboard = ____Dora.Keyboard -- 19
local Mouse = ____Dora.Mouse -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____depth = require("Script.watch.depth") -- 20
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 20
local ____platform = require("Script.watch.platform") -- 22
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 22
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 24
local keyTagFor = ____control_prompts.keyTagFor -- 24
local ____theme = require("Script.watch.fe.theme") -- 32
local PALETTE = ____theme.PALETTE -- 33
local drawBlossomDot = ____theme.drawBlossomDot -- 35
local drawDiamond = ____theme.drawDiamond -- 36
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 37
local drawHairline = ____theme.drawHairline -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 39
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local toColor = ____theme.toColor -- 41
____exports.RELOAD_START_NODE = 0 -- 55
____exports.RELOAD_TARGET_NODE = 8 -- 56
--- 3×3 九宫格节点真源表（对齐后端 Script/watch/reload.ts 与 contract.ts）
____exports.RELOAD_GRID = { -- 59
	{id = 0, col = 0, row = 0, kind = "start"}, -- 60
	{id = 1, col = 1, row = 0, kind = "plain"}, -- 61
	{id = 2, col = 2, row = 0, kind = "lamp"}, -- 62
	{id = 3, col = 0, row = 1, kind = "plain"}, -- 63
	{id = 4, col = 1, row = 1, kind = "bell"}, -- 64
	{id = 5, col = 2, row = 1, kind = "plain"}, -- 65
	{id = 6, col = 0, row = 2, kind = "plain"}, -- 66
	{id = 7, col = 1, row = 2, kind = "plain"}, -- 67
	{id = 8, col = 2, row = 2, kind = "target"} -- 68
} -- 68
--- 8 邻域校验（含斜角，不含自身）
function ____exports.isAdjacentNode(a, b) -- 72
	if a == b then -- 73
		return false -- 74
	end -- 74
	local na = ____exports.RELOAD_GRID[a + 1] -- 76
	local nb = ____exports.RELOAD_GRID[b + 1] -- 77
	if na == nil or nb == nil then -- 78
		return false -- 79
	end -- 79
	return math.abs(na.col - nb.col) <= 1 and math.abs(na.row - nb.row) <= 1 -- 81
end -- 72
--- 完整路径合法性校验：起点 0、每步相邻、不重复、终点 8
function ____exports.validateReloadPath(path) -- 85
	if #path < 2 then -- 86
		return false -- 87
	end -- 87
	if path[1] ~= ____exports.RELOAD_START_NODE or path[#path] ~= ____exports.RELOAD_TARGET_NODE then -- 89
		return false -- 90
	end -- 90
	local seen = {} -- 92
	local i = 0 -- 93
	do -- 93
		i = 0 -- 94
		while i < #path do -- 94
			local n = path[i + 1] -- 95
			if n < 0 or n >= #____exports.RELOAD_GRID or seen[n] == true then -- 96
				return false -- 97
			end -- 97
			seen[n] = true -- 99
			if i > 0 and not ____exports.isAdjacentNode(path[i], n) then -- 100
				return false -- 101
			end -- 101
			i = i + 1 -- 94
		end -- 94
	end -- 94
	return true -- 104
end -- 85
--- 按路径经过纹样推导效果（铃纹 4 优先于灯纹 2，其余合法连接为推退 knockback）
function ____exports.deriveEffectFromGrid(path) -- 108
	if #path < 2 then -- 109
		return "normal" -- 110
	end -- 110
	local hasBell = false -- 112
	local hasLamp = false -- 113
	local i = 0 -- 114
	do -- 114
		i = 0 -- 115
		while i < #path do -- 115
			if path[i + 1] == 4 then -- 116
				hasBell = true -- 117
			elseif path[i + 1] == 2 then -- 118
				hasLamp = true -- 119
			end -- 119
			i = i + 1 -- 115
		end -- 115
	end -- 115
	if hasBell then -- 122
		return "echo" -- 123
	end -- 123
	if hasLamp then -- 125
		return "light" -- 126
	end -- 126
	return "knockback" -- 128
end -- 108
function ____exports.reloadEffectShortLabel(effect) -- 131
	if effect == "knockback" then -- 132
		return "推退" -- 133
	end -- 133
	if effect == "echo" then -- 135
		return "回声诱导" -- 136
	end -- 136
	if effect == "light" then -- 138
		return "照亮遮蔽" -- 139
	end -- 139
	return "待起笔" -- 141
end -- 131
--- 绘制静音/灰度可辨的效果几何纹样（供 reload_wheel 与 craft_bench 共享同一符号体系）：
-- - knockback：双尖横冲箭矢（实线）
-- - echo：铜铃轮廓 + 两侧声波弧（虚/双弧）
-- - light：六角提灯轮廓 + 四向破障短芒
-- - normal：素墨空圆
function ____exports.drawReloadPatternGlyph(draw, cx, cy, radius, effect, col, alpha) -- 151
	if alpha == nil then -- 158
		alpha = 1 -- 158
	end -- 158
	local stroke = toColor(col, 235 * alpha) -- 160
	local faint = toColor(col, 130 * alpha) -- 161
	local r = math.max(5, radius) -- 162
	if effect == "echo" then -- 164
		draw:drawPolygon( -- 166
			{ -- 166
				Vec2(cx - r * 0.56, cy - r * 0.36), -- 167
				Vec2(cx + r * 0.56, cy - r * 0.36), -- 168
				Vec2(cx + r * 0.34, cy + r * 0.42), -- 169
				Vec2(cx, cy + r * 0.62), -- 170
				Vec2(cx - r * 0.34, cy + r * 0.42) -- 171
			}, -- 171
			Color(0, 0, 0, 0), -- 172
			1.35, -- 172
			stroke -- 172
		) -- 172
		draw:drawDot( -- 173
			Vec2(cx, cy - r * 0.54), -- 173
			math.max(1.6, r * 0.16), -- 173
			stroke -- 173
		) -- 173
		draw:drawArc( -- 174
			Vec2(cx, cy + r * 0.04), -- 174
			r * 0.92, -- 174
			-32, -- 174
			32, -- 174
			1, -- 174
			faint -- 174
		) -- 174
		draw:drawArc( -- 175
			Vec2(cx, cy + r * 0.04), -- 175
			r * 0.92, -- 175
			148, -- 175
			212, -- 175
			1, -- 175
			faint -- 175
		) -- 175
		return -- 176
	end -- 176
	if effect == "light" then -- 179
		draw:drawPolygon( -- 181
			{ -- 181
				Vec2(cx, cy + r * 0.72), -- 182
				Vec2(cx + r * 0.48, cy + r * 0.28), -- 183
				Vec2(cx + r * 0.42, cy - r * 0.44), -- 184
				Vec2(cx, cy - r * 0.64), -- 185
				Vec2(cx - r * 0.42, cy - r * 0.44), -- 186
				Vec2(cx - r * 0.48, cy + r * 0.28) -- 187
			}, -- 187
			Color(0, 0, 0, 0), -- 188
			1.35, -- 188
			stroke -- 188
		) -- 188
		drawDiamond( -- 189
			draw, -- 189
			cx, -- 189
			cy, -- 189
			r * 0.22, -- 189
			r * 0.3, -- 189
			stroke -- 189
		) -- 189
		draw:drawSegment( -- 191
			Vec2(cx - r * 0.98, cy), -- 191
			Vec2(cx - r * 0.68, cy), -- 191
			1.1, -- 191
			faint -- 191
		) -- 191
		draw:drawSegment( -- 192
			Vec2(cx + r * 0.68, cy), -- 192
			Vec2(cx + r * 0.98, cy), -- 192
			1.1, -- 192
			faint -- 192
		) -- 192
		draw:drawSegment( -- 193
			Vec2(cx, cy + r * 0.8), -- 193
			Vec2(cx, cy + r * 1.04), -- 193
			1.1, -- 193
			faint -- 193
		) -- 193
		draw:drawSegment( -- 194
			Vec2(cx, cy - r * 0.74), -- 194
			Vec2(cx, cy - r * 1), -- 194
			1.1, -- 194
			faint -- 194
		) -- 194
		return -- 195
	end -- 195
	if effect == "knockback" then -- 198
		draw:drawSegment( -- 200
			Vec2(cx - r * 0.85, cy), -- 200
			Vec2(cx + r * 0.85, cy), -- 200
			1.6, -- 200
			stroke -- 200
		) -- 200
		draw:drawSegment( -- 201
			Vec2(cx + r * 0.24, cy + r * 0.54), -- 201
			Vec2(cx + r * 0.85, cy), -- 201
			1.5, -- 201
			stroke -- 201
		) -- 201
		draw:drawSegment( -- 202
			Vec2(cx + r * 0.24, cy - r * 0.54), -- 202
			Vec2(cx + r * 0.85, cy), -- 202
			1.5, -- 202
			stroke -- 202
		) -- 202
		draw:drawSegment( -- 203
			Vec2(cx - r * 0.34, cy + r * 0.36), -- 203
			Vec2(cx + r * 0.14, cy), -- 203
			1.1, -- 203
			faint -- 203
		) -- 203
		draw:drawSegment( -- 204
			Vec2(cx - r * 0.34, cy - r * 0.36), -- 204
			Vec2(cx + r * 0.14, cy), -- 204
			1.1, -- 204
			faint -- 204
		) -- 204
		return -- 205
	end -- 205
	draw:drawRing( -- 209
		Vec2(cx, cy), -- 209
		r * 0.52, -- 209
		r * 0.68, -- 209
		Color(0, 0, 0, 0), -- 209
		1.1, -- 209
		faint -- 209
	) -- 209
end -- 151
local function resolveRuntimeContract(injected) -- 256
	if injected ~= nil then -- 257
		return injected -- 258
	end -- 258
	local g = _G -- 260
	local ____temp_0 -- 261
	if g.package ~= nil then -- 261
		____temp_0 = g.package.loaded -- 261
	else -- 261
		____temp_0 = nil -- 261
	end -- 261
	local loaded = ____temp_0 -- 261
	if loaded == nil then -- 262
		return nil -- 263
	end -- 263
	local feHook = loaded["watch.fe"] -- 265
	if feHook ~= nil and type(feHook) == "table" then -- 266
		local c = feHook.contract -- 267
		if c ~= nil and type(c) == "table" then -- 268
			return c -- 269
		end -- 269
	end -- 269
	return nil -- 272
end -- 256
local function dispatchIntentFallback(p, intent) -- 275
	local rec = p -- 276
	local handler = rec.submitFeIntent -- 277
	if type(handler) == "function" then -- 278
		return handler(p, intent) ~= false -- 279
	end -- 279
	local tap = rec.reloadTapNode -- 281
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 282
		tap(p, intent.node) -- 283
		return true -- 284
	end -- 284
	return false -- 286
end -- 275
local function readOptionalNum(obj, key) -- 289
	if obj ~= nil and type(obj) == "table" then -- 290
		local v = obj[key] -- 291
		if type(v) == "number" then -- 292
			return v -- 293
		end -- 293
	end -- 293
	return nil -- 296
end -- 289
____exports.ReloadWheelPlugin = __TS__Class() -- 299
local ReloadWheelPlugin = ____exports.ReloadWheelPlugin -- 299
ReloadWheelPlugin.name = "ReloadWheelPlugin" -- 299
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 352
	self.id = "fe-02-reload-wheel" -- 300
	self.wasActive = false -- 304
	self.openAnimT = 0 -- 305
	self.openDuration = 0.24 -- 306
	self.retractAnimT = 0 -- 307
	self.retractDuration = 0.28 -- 308
	self.settledPath = {} -- 309
	self.settledEffect = "normal" -- 310
	self.settledTimedOut = false -- 311
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 312
	self.lastKnownNextEffect = "normal" -- 313
	self.kbCursor = ____exports.RELOAD_START_NODE -- 316
	self.dragging = false -- 317
	self.dragAdvanced = false -- 318
	self.pointerActive = false -- 319
	self.prevLeft = false -- 320
	self.prevRight = false -- 321
	self.prevUp = false -- 322
	self.prevDown = false -- 323
	self.prevLeftKey = false -- 324
	self.prevRightKey = false -- 325
	self.prevConfirm = false -- 326
	self.prevReset = false -- 327
	self.localInvalidFlash = 0 -- 328
	self.animTime = 0 -- 329
	self.nodePulseSeq = 0 -- 330
	self.panelCx = 940 -- 333
	self.panelCy = 374 -- 334
	self.panelW = 286 -- 335
	self.panelH = 316 -- 336
	self.cellStep = 66 -- 337
	self.hitRadius = 25 -- 338
	self.resetBox = Rect(0, 0, 0, 0) -- 339
	self.lastUiPtrX = 0 -- 340
	self.lastUiPtrY = 0 -- 341
	self.answerTicksAccum = 0 -- 344
	self.worldTicksAccum = 0 -- 345
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 346
	self.appliedVfx = {} -- 349
	self.injectedContract = contract -- 353
end -- 352
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 357
	self.pendingSimInput = sim -- 358
end -- 357
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 361
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 362
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 363
end -- 361
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 369
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 370
end -- 369
function ReloadWheelPlugin.prototype.getState(self) -- 378
	return { -- 379
		active = self.wasActive, -- 380
		kbCursor = self.kbCursor, -- 381
		dragging = self.dragging, -- 382
		path = __TS__ArraySlice(self.lastKnownPath), -- 383
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 384
		nextEffect = self.lastKnownNextEffect, -- 385
		retracting = self.retractAnimT > 0, -- 386
		invalidFlash = self.localInvalidFlash, -- 387
		clock = self:getClockReadings(), -- 388
		panelCenterX = self.panelCx, -- 389
		panelCenterY = self.panelCy, -- 390
		cellStep = self.cellStep -- 391
	} -- 391
end -- 378
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 395
	self.wasActive = false -- 396
	self.openAnimT = 0 -- 397
	self.retractAnimT = 0 -- 398
	self.settledPath = {} -- 399
	self.settledEffect = "normal" -- 400
	self.settledTimedOut = false -- 401
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 402
	self.lastKnownNextEffect = "normal" -- 403
	self.kbCursor = ____exports.RELOAD_START_NODE -- 404
	self.dragging = false -- 405
	self.pointerActive = false -- 406
	self.localInvalidFlash = 0 -- 407
	self.animTime = 0 -- 408
	self.answerTicksAccum = 0 -- 409
	self.worldTicksAccum = 0 -- 410
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 411
	self.appliedVfx = {} -- 412
	self.pendingSimInput = nil -- 413
	self:resetInputEdges() -- 414
end -- 395
function ReloadWheelPlugin.prototype.resetInputEdges(self, touchMode) -- 417
	if touchMode == nil then -- 417
		touchMode = false -- 417
	end -- 417
	local ____temp_1 -- 418
	if not touchMode and type(Mouse) ~= "nil" then -- 418
		____temp_1 = Mouse.leftButtonPressed -- 418
	else -- 418
		____temp_1 = false -- 418
	end -- 418
	self.prevLeft = ____temp_1 -- 418
	local ____temp_2 -- 419
	if not touchMode and type(Mouse) ~= "nil" then -- 419
		____temp_2 = Mouse.rightButtonPressed -- 419
	else -- 419
		____temp_2 = false -- 419
	end -- 419
	self.prevRight = ____temp_2 -- 419
	if type(Keyboard) ~= "nil" then -- 420
		self.prevUp = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 421
		self.prevDown = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 422
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 423
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 424
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 425
		self.prevReset = Keyboard:isKeyPressed("BackSpace") -- 426
	end -- 426
end -- 417
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 430
	local contract = resolveRuntimeContract(self.injectedContract) -- 431
	if contract ~= nil then -- 432
		return contract:submitIntent(p, intent) -- 433
	end -- 433
	return dispatchIntentFallback(p, intent) -- 435
end -- 430
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 438
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 439
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 440
	local marginX = self.panelW * 0.5 + 34 -- 441
	local minCx = marginX + safe.left -- 442
	local maxCx = math.max(minCx, ctx.uiW - marginX - safe.right) -- 443
	if soldierUiX < ctx.uiW * 0.56 then -- 444
		self.panelCx = math.min( -- 445
			maxCx, -- 445
			math.max( -- 445
				minCx, -- 445
				math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 445
			) -- 445
		) -- 445
	else -- 445
		self.panelCx = math.max( -- 447
			minCx, -- 447
			math.min( -- 447
				maxCx, -- 447
				math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 447
			) -- 447
		) -- 447
	end -- 447
	local minCy = self.panelH * 0.5 + 78 + safe.bottom -- 449
	local maxCy = math.max(minCy, ctx.uiH - self.panelH * 0.5 - 66 - safe.top) -- 450
	self.panelCy = math.max( -- 451
		minCy, -- 451
		math.min(maxCy, ctx.uiH * 0.52) -- 451
	) -- 451
	self.resetBox = Rect(self.panelCx + 56, self.panelCy + self.panelH * 0.5 - 45, 72, 26) -- 452
end -- 438
function ReloadWheelPlugin.prototype.update(self, ctx) -- 455
	local rs = ctx.view.reloadSession -- 456
	local p = ctx.p -- 457
	self:computePanelPlacement(ctx) -- 460
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 463
		0.25, -- 463
		math.min(1, ctx.view.timeScale) -- 463
	) or 1) -- 463
	if ctx.paused then -- 466
		self:resetInputEdges(ctx.input:isTouchMode()) -- 467
		return -- 468
	end -- 468
	local udt = math.max(0, ctx.uiDt) -- 471
	local wdt = math.max(0, ctx.worldDt) -- 472
	self.animTime = self.animTime + udt -- 473
	if self.localInvalidFlash > 0 then -- 475
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 476
	end -- 476
	if rs.invalidFlash > self.localInvalidFlash then -- 478
		self.localInvalidFlash = rs.invalidFlash -- 479
	end -- 479
	self:ingestAppliedEffects(ctx) -- 483
	self:updateAppliedVfx(wdt) -- 484
	if rs.active and not self.wasActive then -- 487
		self:onSessionOpened(ctx) -- 488
	elseif not rs.active and self.wasActive then -- 489
		self:onSessionClosed(ctx) -- 490
	end -- 490
	self.wasActive = rs.active -- 492
	if not rs.active then -- 494
		self.lastKnownNextEffect = rs.nextEffect -- 495
		self.lastClock.active = false -- 496
		if self.retractAnimT > 0 then -- 497
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 498
		end -- 498
		self.pendingSimInput = nil -- 500
		return -- 501
	end -- 501
	self.openAnimT = math.min( -- 505
		1, -- 505
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 505
	) -- 505
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 508
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 509
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 510
		self.answerTicksAccum = liveAns -- 511
		self.worldTicksAccum = liveWorld -- 512
	else -- 512
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 514
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 515
	end -- 515
	self.lastClock = { -- 517
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 518
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 519
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 520
		active = true -- 521
	} -- 521
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 525
	self.lastKnownPath = activePath -- 526
	self.lastKnownNextEffect = rs.nextEffect -- 527
	self:processInputs(ctx, activePath) -- 530
end -- 455
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 533
	local rs = ctx.view.reloadSession -- 534
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 535
	self.openAnimT = 0 -- 536
	self.retractAnimT = 0 -- 537
	self.kbCursor = ____exports.RELOAD_START_NODE -- 538
	self.dragging = false -- 539
	self.pointerActive = false -- 540
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 541
	self.answerTicksAccum = 0 -- 542
	self.worldTicksAccum = 0 -- 543
	self:resetInputEdges(ctx.input:isTouchMode()) -- 544
	local hasBackendOpen = false -- 546
	local i = 0 -- 547
	do -- 547
		i = 0 -- 548
		while i < #ctx.events.rawEvents do -- 548
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 549
				hasBackendOpen = true -- 550
				break -- 551
			end -- 551
			i = i + 1 -- 548
		end -- 548
	end -- 548
	if not hasBackendOpen then -- 554
		ctx.audio:playOnce( -- 555
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 556
			"sfx", -- 557
			"assets/audio/combat/reload_open.wav", -- 558
			0.8, -- 559
			"reload:open", -- 560
			ctx.p.ticks -- 561
		) -- 561
	end -- 561
end -- 533
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 566
	local rs = ctx.view.reloadSession -- 567
	self.dragging = false -- 568
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 569
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 570
		local ____self_settledPath_3 = self.settledPath -- 572
		____self_settledPath_3[#____self_settledPath_3 + 1] = ____exports.RELOAD_TARGET_NODE -- 572
	end -- 572
	self.settledEffect = rs.nextEffect -- 574
	self.settledTimedOut = rs.nextEffect == "normal" -- 575
	self.retractAnimT = self.retractDuration -- 576
	local hasBackendClose = false -- 579
	local i = 0 -- 580
	do -- 580
		i = 0 -- 581
		while i < #ctx.events.rawEvents do -- 581
			local n = ctx.events.rawEvents[i + 1].name -- 582
			if n == "reloadSolved" or n == "reloadTimeout" then -- 583
				hasBackendClose = true -- 584
				break -- 585
			end -- 585
			i = i + 1 -- 581
		end -- 581
	end -- 581
	if self.settledTimedOut then -- 589
		if not hasBackendClose then -- 590
			ctx.audio:playOnce( -- 591
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 592
				"sfx", -- 593
				"assets/audio/combat/reload_timeout.wav", -- 594
				0.78, -- 595
				"reload:timeout", -- 596
				ctx.p.ticks -- 597
			) -- 597
		end -- 597
	else -- 597
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 601
		ctx.audio:playOnce( -- 606
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 607
			"sfx", -- 608
			effectWav, -- 609
			0.88, -- 610
			"reload:solved:" .. self.settledEffect, -- 611
			ctx.p.ticks -- 612
		) -- 612
	end -- 612
end -- 566
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 617
	local sim = self.pendingSimInput -- 618
	self.pendingSimInput = nil -- 619
	local touchMode = ctx.input:isTouchMode() -- 621
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 622
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 624
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 627
	local ____temp_13 -- 630
	if (sim and sim.pointerX) ~= nil then -- 630
		____temp_13 = true -- 631
	else -- 631
		local ____useUiPtr_12 -- 632
		if useUiPtr then -- 632
			____useUiPtr_12 = ctx.input.uiInside -- 632
		else -- 632
			____useUiPtr_12 = ctx.input.inside -- 632
		end -- 632
		____temp_13 = ____useUiPtr_12 -- 632
	end -- 632
	local inside = ____temp_13 -- 630
	local kbmMode = ctx.input.inputMode == "kbm" -- 633
	local ____temp_16 -- 634
	if (sim and sim.leftHeld) ~= nil then -- 634
		____temp_16 = sim.leftHeld -- 635
	else -- 635
		____temp_16 = ctx.input.uiHeld or ctx.input.fire.held or kbmMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 636
	end -- 636
	local leftHeld = ____temp_16 -- 634
	local ____temp_19 -- 637
	if (sim and sim.rightHeld) ~= nil then -- 637
		____temp_19 = sim.rightHeld -- 638
	else -- 638
		____temp_19 = ctx.input.uiRightPressed or kbmMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 639
	end -- 639
	local rightHeld = ____temp_19 -- 637
	local ____temp_22 -- 641
	if (sim and sim.leftHeld) ~= nil then -- 641
		____temp_22 = leftHeld and not self.prevLeft -- 642
	else -- 642
		____temp_22 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 643
	end -- 643
	local leftPressed = ____temp_22 -- 641
	local ____temp_25 -- 644
	if (sim and sim.leftHeld) ~= nil then -- 644
		____temp_25 = not leftHeld and self.prevLeft -- 645
	else -- 645
		____temp_25 = ctx.input.uiReleased or not leftHeld and self.prevLeft -- 646
	end -- 646
	local leftReleased = ____temp_25 -- 644
	local ____temp_28 -- 647
	if (sim and sim.rightHeld) ~= nil then -- 647
		____temp_28 = rightHeld and not self.prevRight -- 648
	else -- 648
		____temp_28 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 649
	end -- 649
	local rightPressed = ____temp_28 -- 647
	self.prevLeft = leftHeld -- 650
	self.prevRight = rightHeld -- 651
	self.lastUiPtrX = ptrX -- 652
	self.lastUiPtrY = ptrY -- 653
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 655
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 656
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 657
	if pointerMoved or leftPressed then -- 659
		self.pointerActive = true -- 660
	end -- 660
	local lastNode = activePath[#activePath] -- 663
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 664
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 665
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 666
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 669
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 670
		self.dragging = false -- 671
		self.dragAdvanced = false -- 672
		self:triggerInvalidReset(ctx, activePath, false) -- 673
		return -- 674
	end -- 674
	if leftPressed then -- 678
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 679
			self.dragging = true -- 680
			self.dragAdvanced = false -- 681
			self.kbCursor = lastNode -- 682
		elseif hitNode >= 0 then -- 683
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 684
				self.dragging = true -- 685
				self.dragAdvanced = false -- 686
				self:commitNodeStep(ctx, hitNode, activePath) -- 687
			else -- 687
				self.dragging = false -- 689
				self.dragAdvanced = false -- 690
				self:triggerInvalidReset(ctx, activePath, true) -- 691
			end -- 691
			return -- 693
		end -- 693
	elseif self.dragging and leftHeld then -- 695
		if hitNode >= 0 and hitNode ~= lastNode then -- 696
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 697
				self.dragAdvanced = true -- 698
				self:commitNodeStep(ctx, hitNode, activePath) -- 699
			else -- 699
				self.dragging = false -- 702
				self.dragAdvanced = false -- 703
				self:triggerInvalidReset(ctx, activePath, true) -- 704
			end -- 704
			return -- 706
		end -- 706
	elseif leftReleased and self.dragging then -- 708
		local wasDragStroke = self.dragAdvanced -- 709
		self.dragging = false -- 710
		self.dragAdvanced = false -- 711
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 713
			self:triggerInvalidReset(ctx, activePath, true) -- 714
			return -- 715
		end -- 715
	end -- 715
	local dCol = 0 -- 720
	local dRow = 0 -- 721
	local confirmPressed = false -- 722
	local resetPressed = false -- 723
	local gpAutoCommit = false -- 724
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 726
		dCol = sim.moveCol or 0 -- 727
		dRow = sim.moveRow or 0 -- 728
		confirmPressed = sim.confirm == true -- 729
		resetPressed = sim.reset == true -- 730
	else -- 730
		if type(Keyboard) ~= "nil" then -- 732
			local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 733
			local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 734
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 735
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 736
			local confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 737
			local reset = Keyboard:isKeyPressed("BackSpace") -- 738
			if up and not self.prevUp then -- 740
				dRow = dRow + 1 -- 740
			end -- 740
			if down and not self.prevDown then -- 741
				dRow = dRow - 1 -- 741
			end -- 741
			if rk and not self.prevRightKey then -- 742
				dCol = dCol + 1 -- 742
			end -- 742
			if lk and not self.prevLeftKey then -- 743
				dCol = dCol - 1 -- 743
			end -- 743
			confirmPressed = confirm and not self.prevConfirm -- 744
			resetPressed = reset and not self.prevReset -- 745
			self.prevUp = up -- 747
			self.prevDown = down -- 748
			self.prevLeftKey = lk -- 749
			self.prevRightKey = rk -- 750
			self.prevConfirm = confirm -- 751
			self.prevReset = reset -- 752
		end -- 752
		if ctx.input.reloadReset then -- 754
			resetPressed = true -- 755
		end -- 755
		if ctx.input.reloadConfirm then -- 757
			confirmPressed = true -- 758
		end -- 758
		if dCol == 0 and dRow == 0 and ctx.input.reloadStepEdge then -- 760
			dCol = ctx.input.reloadDirCol -- 761
			dRow = ctx.input.reloadDirRow -- 762
			gpAutoCommit = ctx.input.reloadAutoStep -- 763
		end -- 763
	end -- 763
	if resetPressed and #activePath > 1 then -- 767
		self:triggerInvalidReset(ctx, activePath, false) -- 768
		return -- 769
	end -- 769
	if dCol ~= 0 or dRow ~= 0 then -- 772
		self.pointerActive = false -- 773
		local baseIdx = gpAutoCommit and lastNode or self.kbCursor -- 774
		local cur = ____exports.RELOAD_GRID[baseIdx + 1] or ____exports.RELOAD_GRID[1] -- 775
		local nextCol = math.max( -- 776
			0, -- 776
			math.min(2, cur.col + dCol) -- 776
		) -- 776
		local nextRow = math.max( -- 777
			0, -- 777
			math.min(2, cur.row + dRow) -- 777
		) -- 777
		local nextIdx = nextRow * 3 + nextCol -- 778
		self.kbCursor = nextIdx -- 779
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 780
			self:commitNodeStep(ctx, nextIdx, activePath) -- 781
			return -- 782
		end -- 782
	end -- 782
	if confirmPressed then -- 786
		self.pointerActive = false -- 787
		if self.kbCursor == lastNode then -- 788
			return -- 789
		end -- 789
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 791
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 792
		else -- 792
			self:triggerInvalidReset(ctx, activePath, true) -- 794
		end -- 794
	end -- 794
end -- 617
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 799
	self.kbCursor = node -- 800
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 801
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 802
	if node == ____exports.RELOAD_TARGET_NODE then -- 803
		self.dragging = false -- 804
		return -- 805
	end -- 805
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 808
	ctx.audio:playOnce( -- 809
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 810
		"sfx", -- 811
		"assets/audio/combat/reload_node.wav", -- 812
		0.78, -- 813
		"reload:node:" .. tostring(node), -- 814
		ctx.p.ticks -- 815
	) -- 815
end -- 799
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 819
	if flashError then -- 820
		self.localInvalidFlash = 0.36 -- 821
	end -- 821
	self.kbCursor = ____exports.RELOAD_START_NODE -- 823
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 824
	if #activePath > 1 then -- 826
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 827
	end -- 827
	if flashError then -- 829
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 830
		ctx.audio:playOnce( -- 831
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 832
			"sfx", -- 833
			"assets/audio/combat/reload_invalid.wav", -- 834
			0.72, -- 835
			"reload:invalid", -- 836
			ctx.p.ticks -- 837
		) -- 837
	end -- 837
end -- 819
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 842
	if hitR == nil then -- 842
		hitR = self.hitRadius -- 842
	end -- 842
	local r2 = hitR * hitR -- 843
	local i = 0 -- 844
	do -- 844
		i = 0 -- 845
		while i < #____exports.RELOAD_GRID do -- 845
			local pos = self:getNodeUiPos(i) -- 846
			local dx = uiX - pos.x -- 847
			local dy = uiY - pos.y -- 848
			if dx * dx + dy * dy <= r2 then -- 849
				return i -- 850
			end -- 850
			i = i + 1 -- 845
		end -- 845
	end -- 845
	return -1 -- 853
end -- 842
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 856
	local p = ctx.p -- 857
	local triggered = false -- 858
	local i = 0 -- 859
	do -- 859
		i = 0 -- 860
		while i < #ctx.events.rawEvents do -- 860
			local e = ctx.events.rawEvents[i + 1] -- 861
			if e.name == "reloadApplied" then -- 862
				local rawEff = e.data.effect -- 863
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 864
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 867
				self:spawnAppliedVfx(eff, p, ex) -- 868
				triggered = true -- 869
			end -- 869
			i = i + 1 -- 860
		end -- 860
	end -- 860
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 873
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 874
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 875
	end -- 875
end -- 856
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 879
	local originX = p.player.x + p.player.facing * 18 -- 880
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 881
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 882
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 883
	local ____self_appliedVfx_31 = self.appliedVfx -- 884
	____self_appliedVfx_31[#____self_appliedVfx_31 + 1] = { -- 884
		effect = effect, -- 885
		originX = originX, -- 886
		originY = originY, -- 887
		targetX = targetX, -- 888
		targetY = targetY, -- 889
		facing = p.player.facing >= 0 and 1 or -1, -- 890
		life = maxLife, -- 891
		maxLife = maxLife -- 892
	} -- 892
end -- 879
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 896
	if wdt <= 0 or #self.appliedVfx == 0 then -- 897
		return -- 898
	end -- 898
	local w = 0 -- 900
	local i = 0 -- 901
	do -- 901
		i = 0 -- 902
		while i < #self.appliedVfx do -- 902
			local fx = self.appliedVfx[i + 1] -- 903
			fx.life = fx.life - wdt -- 904
			if fx.life > 0 then -- 905
				self.appliedVfx[w + 1] = fx -- 906
				w = w + 1 -- 907
			end -- 907
			i = i + 1 -- 902
		end -- 902
	end -- 902
	__TS__ArraySetLength(self.appliedVfx, w) -- 910
end -- 896
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 914
	if #self.appliedVfx == 0 then -- 920
		return -- 921
	end -- 921
	local cam = ctx.cam -- 923
	local i = 0 -- 924
	do -- 924
		i = 0 -- 925
		while i < #self.appliedVfx do -- 925
			local fx = self.appliedVfx[i + 1] -- 926
			local k = math.max( -- 927
				0, -- 927
				math.min(1, fx.life / fx.maxLife) -- 927
			) -- 927
			local prog = 1 - k -- 928
			local ox = cam:sx(fx.originX) -- 929
			local oy = cam:sy(fx.originY) -- 930
			local tx = cam:sx(fx.targetX) -- 931
			local ty = cam:sy(fx.targetY) -- 932
			if fx.effect == "knockback" then -- 934
				local r = cam:len(12 + prog * 34) -- 936
				local startA = fx.facing >= 0 and -48 or 132 -- 937
				local endA = fx.facing >= 0 and 48 or 228 -- 938
				fgGlow:drawArc( -- 939
					Vec2(tx, ty), -- 939
					r, -- 939
					startA, -- 939
					endA, -- 939
					2.4 * k, -- 939
					toColor(PALETTE.moonPale, 210 * k) -- 939
				) -- 939
				fgDraw:drawArc( -- 940
					Vec2( -- 940
						tx - fx.facing * cam:len(6), -- 940
						ty -- 940
					), -- 940
					r * 0.72, -- 940
					startA, -- 940
					endA, -- 940
					1.5 * k, -- 940
					toColor(PALETTE.silkLine, 165 * k) -- 940
				) -- 940
			elseif fx.effect == "echo" then -- 941
				local r1 = cam:len(10 + prog * 64) -- 943
				local r2 = cam:len(6 + prog * 40) -- 944
				fgGlow:drawRing( -- 945
					Vec2(tx, ty), -- 945
					math.max(1, r1 - 1.6), -- 945
					r1, -- 945
					Color(0, 0, 0, 0), -- 945
					1.3, -- 945
					toColor(PALETTE.amber, 210 * k) -- 945
				) -- 945
				fgGlow:drawRing( -- 946
					Vec2(tx, ty), -- 946
					math.max(1, r2 - 1.2), -- 946
					r2, -- 946
					Color(0, 0, 0, 0), -- 946
					1, -- 946
					toColor(PALETTE.amberCore, 175 * k) -- 946
				) -- 946
			elseif fx.effect == "light" then -- 947
				fgGlow:drawSegment( -- 949
					Vec2(ox, oy), -- 949
					Vec2(tx, ty), -- 949
					5 * k, -- 949
					toColor(PALETTE.amber, 68 * k) -- 949
				) -- 949
				fgGlow:drawSegment( -- 950
					Vec2(ox, oy), -- 950
					Vec2(tx, ty), -- 950
					1.8 * k, -- 950
					toColor(PALETTE.amberCore, 185 * k) -- 950
				) -- 950
				fillRadialGlow( -- 951
					fgGlow, -- 951
					tx, -- 951
					ty, -- 951
					cam:len(42 * (0.6 + prog * 0.4)), -- 951
					cam:len(34), -- 951
					toColor(PALETTE.amberCore, 118 * k), -- 951
					Color(244, 234, 214, 0), -- 951
					16 -- 951
				) -- 951
			end -- 951
			i = i + 1 -- 925
		end -- 925
	end -- 925
end -- 914
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 957
	local rs = ctx.view.reloadSession -- 964
	local active = rs.active -- 965
	local retracting = not active and self.retractAnimT > 0.01 -- 966
	if not active and not retracting then -- 967
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 969
			self:drawArmedEffectBadge( -- 970
				uiDraw, -- 970
				uiInkDraw, -- 970
				uiArt, -- 970
				ctx, -- 970
				rs.nextEffect -- 970
			) -- 970
		end -- 970
		return false -- 972
	end -- 972
	local cx = self.panelCx -- 975
	local cy = self.panelCy -- 976
	local pw = self.panelW -- 977
	local ph = self.panelH -- 978
	local x0 = cx - pw * 0.5 -- 979
	local y0 = cy - ph * 0.5 -- 980
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 982
		0, -- 984
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 984
	) -- 984
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 985
	local px = cx + shakeX -- 988
	if active then -- 991
		uiDraw:drawRect( -- 992
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 992
			Color( -- 992
				10, -- 992
				13, -- 992
				20, -- 992
				math.floor(54 * appear + 0.5) -- 992
			) -- 992
		) -- 992
	end -- 992
	drawSilkVeil( -- 996
		uiDraw, -- 996
		uiArt, -- 996
		"rw_outer_veil", -- 996
		px, -- 996
		cy, -- 996
		pw + 34, -- 996
		ph + 28, -- 996
		PALETTE.inkWash, -- 996
		0.72 * appear, -- 996
		-2 -- 996
	) -- 996
	if not uiArt:tryPlace( -- 997
		"ink_song_paper", -- 997
		"rw_paper", -- 997
		px, -- 997
		cy, -- 997
		pw, -- 997
		ph, -- 997
		{opacity = 0.94 * appear, layer = 1} -- 997
	) then -- 997
		uiDraw:drawRoundedRect( -- 998
			Rect(x0 + shakeX, y0, pw, ph), -- 999
			6, -- 1000
			toColor(PALETTE.xuanPaper, 240 * appear), -- 1001
			1.2, -- 1002
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 1003
		) -- 1003
	end -- 1003
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 1006
	drawFiligreeCorners( -- 1007
		uiInkDraw, -- 1007
		uiArt, -- 1007
		"rw_frame", -- 1007
		x0 + shakeX + 8, -- 1007
		y0 + 8, -- 1007
		pw - 16, -- 1007
		ph - 16, -- 1007
		frameCol, -- 1007
		0.72 * appear, -- 1007
		22, -- 1007
		true, -- 1007
		2 -- 1007
	) -- 1007
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1010
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1013
	local effAccent = self:effectInkColor(previewEffect) -- 1016
	local headY = y0 + ph - 32 -- 1018
	____exports.drawReloadPatternGlyph( -- 1019
		uiInkDraw, -- 1019
		px - 52, -- 1019
		headY, -- 1019
		11, -- 1019
		previewEffect, -- 1019
		effAccent, -- 1019
		appear -- 1019
	) -- 1019
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1020
	ctx.texts:put( -- 1023
		"sm", -- 1024
		titleText, -- 1025
		px - 32, -- 1026
		headY, -- 1027
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1028
		0, -- 1029
		0.5, -- 1030
		"Left", -- 1031
		1.6, -- 1032
		0.96 * appear, -- 1033
		0 -- 1034
	) -- 1034
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1036
		local canReset = #activePath > 1 -- 1037
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1038
		uiInkDraw:drawRect( -- 1039
			rb, -- 1040
			Color( -- 1041
				32, -- 1041
				30, -- 1041
				32, -- 1041
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1041
			), -- 1041
			0.85, -- 1042
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1043
		) -- 1043
		ctx.texts:put( -- 1045
			"xs", -- 1046
			"重画", -- 1047
			rb.x + rb.width * 0.5, -- 1048
			rb.y + rb.height * 0.5, -- 1049
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1050
			0.5, -- 1051
			0.5, -- 1052
			"Center", -- 1053
			1, -- 1054
			(canReset and 0.94 or 0.52) * appear, -- 1055
			0 -- 1056
		) -- 1056
	end -- 1056
	drawHairline( -- 1059
		uiInkDraw, -- 1059
		uiArt, -- 1059
		"rw_head_line", -- 1059
		px, -- 1059
		headY - 18, -- 1059
		pw - 42, -- 1059
		PALETTE.xuanInkSub, -- 1059
		0.45 * appear, -- 1059
		false, -- 1059
		2 -- 1059
	) -- 1059
	local idx = 0 -- 1062
	do -- 1062
		idx = 0 -- 1063
		while idx < 3 do -- 1063
			local hA = self:getNodeUiPos(idx * 3) -- 1064
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1065
			uiInkDraw:drawSegment( -- 1066
				Vec2(hA.x + shakeX, hA.y), -- 1066
				Vec2(hB.x + shakeX, hB.y), -- 1066
				0.75, -- 1066
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1066
			) -- 1066
			local vA = self:getNodeUiPos(idx) -- 1067
			local vB = self:getNodeUiPos(6 + idx) -- 1068
			uiInkDraw:drawSegment( -- 1069
				Vec2(vA.x + shakeX, vA.y), -- 1069
				Vec2(vB.x + shakeX, vB.y), -- 1069
				0.75, -- 1069
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1069
			) -- 1069
			idx = idx + 1 -- 1063
		end -- 1063
	end -- 1063
	if #activePath >= 2 then -- 1073
		self:drawPathStrokes( -- 1074
			uiInkDraw, -- 1074
			uiGlow, -- 1074
			activePath, -- 1074
			previewEffect, -- 1074
			effAccent, -- 1074
			shakeX, -- 1074
			appear -- 1074
		) -- 1074
	end -- 1074
	if active and self.dragging and #activePath >= 1 then -- 1078
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1079
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1080
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1081
		uiInkDraw:drawSegment( -- 1082
			Vec2(tail.x + shakeX, tail.y), -- 1082
			Vec2(mx, my), -- 1082
			1.4, -- 1082
			toColor(effAccent, 150 * appear) -- 1082
		) -- 1082
		uiInkDraw:drawDot( -- 1083
			Vec2(mx, my), -- 1083
			3, -- 1083
			toColor(effAccent, 210 * appear) -- 1083
		) -- 1083
	end -- 1083
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1087
	do -- 1087
		idx = 0 -- 1088
		while idx < #____exports.RELOAD_GRID do -- 1088
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1089
			local pos = self:getNodeUiPos(idx) -- 1090
			local nx = pos.x + shakeX -- 1091
			local ny = pos.y -- 1092
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1093
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1094
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1095
			self:drawGridNode( -- 1096
				uiInkDraw, -- 1096
				uiGlow, -- 1096
				spec, -- 1096
				nx, -- 1096
				ny, -- 1096
				inPath, -- 1096
				isValidNext, -- 1096
				isKbFocus, -- 1096
				effAccent, -- 1096
				appear -- 1096
			) -- 1096
			idx = idx + 1 -- 1088
		end -- 1088
	end -- 1088
	self:drawChildFinger( -- 1100
		uiInkDraw, -- 1100
		uiGlow, -- 1100
		active, -- 1100
		activePath, -- 1100
		shakeX, -- 1100
		appear -- 1100
	) -- 1100
	local barW = pw - 52 -- 1103
	local barX = px - barW * 0.5 -- 1104
	local barY = y0 + 28 -- 1105
	local remainFrac = active and math.max( -- 1106
		0, -- 1107
		math.min( -- 1107
			1, -- 1107
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1107
		) -- 1107
	) or (self.settledTimedOut and 0 or 1) -- 1108
	local urgent = active and remainFrac < 0.25 -- 1109
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1110
	uiInkDraw:drawSegment( -- 1111
		Vec2(barX, barY), -- 1111
		Vec2(barX + barW, barY), -- 1111
		1.4, -- 1111
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1111
	) -- 1111
	if remainFrac > 0.005 then -- 1112
		uiInkDraw:drawSegment( -- 1113
			Vec2(barX, barY), -- 1113
			Vec2(barX + barW * remainFrac, barY), -- 1113
			3, -- 1113
			toColor(barCol, 225 * appear) -- 1113
		) -- 1113
	end -- 1113
	local tTick = 1 -- 1116
	do -- 1116
		tTick = 1 -- 1117
		while tTick <= 3 do -- 1117
			local tx = barX + barW * (tTick / 4) -- 1118
			uiInkDraw:drawSegment( -- 1119
				Vec2(tx, barY - 3.5), -- 1119
				Vec2(tx, barY + 3.5), -- 1119
				0.9, -- 1119
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1119
			) -- 1119
			tTick = tTick + 1 -- 1117
		end -- 1117
	end -- 1117
	if active and ctx.view.assistHintsEnabled then -- 1123
		local mode = ctx.input.inputMode -- 1124
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1125
		ctx.texts:put( -- 1130
			"xs", -- 1131
			hint, -- 1132
			px, -- 1133
			y0 + 13, -- 1134
			toColor(PALETTE.xuanInkSub), -- 1135
			0.5, -- 1136
			0.5, -- 1137
			"Center", -- 1138
			0.6, -- 1139
			0.82 * appear, -- 1140
			0 -- 1141
		) -- 1141
	end -- 1141
	return active -- 1145
end -- 957
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1148
	if effect == "echo" then -- 1149
		return PALETTE.rouge -- 1150
	end -- 1150
	if effect == "light" then -- 1152
		return PALETTE.amberDim -- 1153
	end -- 1153
	if effect == "knockback" then -- 1155
		return PALETTE.xuanInk -- 1156
	end -- 1156
	return PALETTE.xuanInkSub -- 1158
end -- 1148
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1161
	local i = 0 -- 1170
	do -- 1170
		i = 0 -- 1171
		while i < #path - 1 do -- 1171
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1172
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1173
			local ax = p0.x + shakeX -- 1174
			local ay = p0.y -- 1175
			local bx = p1.x + shakeX -- 1176
			local by = p1.y -- 1177
			if effect == "echo" then -- 1179
				local dx = bx - ax -- 1181
				local dy = by - ay -- 1182
				local len = math.max( -- 1183
					1, -- 1183
					math.sqrt(dx * dx + dy * dy) -- 1183
				) -- 1183
				local nx = -dy / len * 2.2 -- 1184
				local ny = dx / len * 2.2 -- 1185
				uiInkDraw:drawSegment( -- 1186
					Vec2(ax + nx, ay + ny), -- 1186
					Vec2(bx + nx, by + ny), -- 1186
					1.35, -- 1186
					toColor(col, 220 * appear) -- 1186
				) -- 1186
				uiInkDraw:drawSegment( -- 1187
					Vec2(ax - nx, ay - ny), -- 1187
					Vec2(bx - nx, by - ny), -- 1187
					1.35, -- 1187
					toColor(col, 220 * appear) -- 1187
				) -- 1187
			elseif effect == "light" then -- 1188
				uiInkDraw:drawSegment( -- 1190
					Vec2(ax, ay), -- 1190
					Vec2(bx, by), -- 1190
					3.1, -- 1190
					toColor(PALETTE.xuanInk, 195 * appear) -- 1190
				) -- 1190
				uiInkDraw:drawSegment( -- 1191
					Vec2(ax, ay), -- 1191
					Vec2(bx, by), -- 1191
					1.3, -- 1191
					toColor(PALETTE.amberCore, 235 * appear) -- 1191
				) -- 1191
				uiGlow:drawSegment( -- 1192
					Vec2(ax, ay), -- 1192
					Vec2(bx, by), -- 1192
					3.2, -- 1192
					toColor(PALETTE.amber, 55 * appear) -- 1192
				) -- 1192
			else -- 1192
				uiInkDraw:drawSegment( -- 1195
					Vec2(ax, ay), -- 1195
					Vec2(bx, by), -- 1195
					2.8, -- 1195
					toColor(col, 230 * appear) -- 1195
				) -- 1195
			end -- 1195
			i = i + 1 -- 1171
		end -- 1171
	end -- 1171
end -- 1161
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1200
	local baseR = spec.kind == "plain" and 11 or 15 -- 1212
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1213
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1214
	if isKbFocus then -- 1217
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1218
		uiInkDraw:drawRing( -- 1219
			Vec2(nx, ny), -- 1219
			baseR + 4.5, -- 1219
			baseR + 6.2, -- 1219
			Color(0, 0, 0, 0), -- 1219
			1.1, -- 1219
			toColor(focusCol, 215 * appear) -- 1219
		) -- 1219
	end -- 1219
	if spec.kind == "bell" then -- 1222
		if inPath then -- 1224
			uiInkDraw:drawCircle( -- 1225
				Vec2(nx, ny), -- 1225
				baseR + 1, -- 1225
				toColor(PALETTE.rouge, 36 * appear) -- 1225
			) -- 1225
			uiGlow:drawRing( -- 1226
				Vec2(nx, ny), -- 1226
				baseR + 2, -- 1226
				baseR + 5, -- 1226
				Color(0, 0, 0, 0), -- 1226
				1.2, -- 1226
				toColor(PALETTE.rouge, 110 * appear) -- 1226
			) -- 1226
		end -- 1226
		uiInkDraw:drawRing( -- 1228
			Vec2(nx, ny), -- 1228
			baseR - 1.2, -- 1228
			baseR, -- 1228
			Color(0, 0, 0, 0), -- 1228
			1.1, -- 1228
			toColor(strokeCol, strokeAlpha * appear) -- 1228
		) -- 1228
		____exports.drawReloadPatternGlyph( -- 1229
			uiInkDraw, -- 1229
			nx, -- 1229
			ny, -- 1229
			9.5, -- 1229
			"echo", -- 1229
			inPath and PALETTE.rouge or strokeCol, -- 1229
			appear -- 1229
		) -- 1229
		return -- 1230
	end -- 1230
	if spec.kind == "lamp" then -- 1233
		if inPath then -- 1235
			uiInkDraw:drawCircle( -- 1236
				Vec2(nx, ny), -- 1236
				baseR + 1, -- 1236
				toColor(PALETTE.amber, 56 * appear) -- 1236
			) -- 1236
			fillRadialGlow( -- 1237
				uiGlow, -- 1237
				nx, -- 1237
				ny, -- 1237
				22, -- 1237
				22, -- 1237
				toColor(PALETTE.amberCore, 72 * appear), -- 1237
				Color(244, 234, 214, 0), -- 1237
				12 -- 1237
			) -- 1237
		end -- 1237
		uiInkDraw:drawRing( -- 1239
			Vec2(nx, ny), -- 1239
			baseR - 1.2, -- 1239
			baseR, -- 1239
			Color(0, 0, 0, 0), -- 1239
			1.1, -- 1239
			toColor(strokeCol, strokeAlpha * appear) -- 1239
		) -- 1239
		____exports.drawReloadPatternGlyph( -- 1240
			uiInkDraw, -- 1240
			nx, -- 1240
			ny, -- 1240
			9.5, -- 1240
			"light", -- 1240
			inPath and PALETTE.xuanInk or strokeCol, -- 1240
			appear -- 1240
		) -- 1240
		return -- 1241
	end -- 1241
	if spec.kind == "target" then -- 1244
		drawDiamond( -- 1246
			uiInkDraw, -- 1247
			nx, -- 1248
			ny, -- 1249
			baseR, -- 1250
			baseR, -- 1251
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1252
			1.4, -- 1253
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1254
		) -- 1254
		drawDiamond( -- 1256
			uiInkDraw, -- 1257
			nx, -- 1258
			ny, -- 1259
			baseR * 0.56, -- 1260
			baseR * 0.56, -- 1261
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1262
		) -- 1262
		return -- 1264
	end -- 1264
	if spec.kind == "start" then -- 1267
		uiInkDraw:drawRing( -- 1269
			Vec2(nx, ny), -- 1269
			baseR - 2.2, -- 1269
			baseR, -- 1269
			Color(0, 0, 0, 0), -- 1269
			1.2, -- 1269
			toColor(PALETTE.rouge, 220 * appear) -- 1269
		) -- 1269
		uiInkDraw:drawCircle( -- 1270
			Vec2(nx, ny), -- 1270
			4.8, -- 1270
			toColor(PALETTE.xuanInk, 235 * appear) -- 1270
		) -- 1270
		return -- 1271
	end -- 1271
	if inPath then -- 1275
		uiInkDraw:drawCircle( -- 1276
			Vec2(nx, ny), -- 1276
			6.2, -- 1276
			toColor(effAccent, 235 * appear) -- 1276
		) -- 1276
		uiInkDraw:drawRing( -- 1277
			Vec2(nx, ny), -- 1277
			9.5, -- 1277
			10.8, -- 1277
			Color(0, 0, 0, 0), -- 1277
			1, -- 1277
			toColor(effAccent, 165 * appear) -- 1277
		) -- 1277
	else -- 1277
		uiInkDraw:drawRing( -- 1279
			Vec2(nx, ny), -- 1279
			5.6, -- 1279
			7, -- 1279
			Color(0, 0, 0, 0), -- 1279
			1, -- 1279
			toColor(strokeCol, strokeAlpha * appear) -- 1279
		) -- 1279
	end -- 1279
end -- 1200
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1284
	local fx = 0 -- 1292
	local fy = 0 -- 1293
	if active then -- 1295
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1296
		local pos = self:getNodeUiPos(tipNode) -- 1297
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1298
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1299
		fy = pos.y - 6 - tapPulse -- 1300
		if #path <= 1 then -- 1301
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1303
			uiInkDraw:drawRing( -- 1304
				Vec2(pos.x + shakeX, pos.y), -- 1304
				ringR - 1, -- 1304
				ringR, -- 1304
				Color(0, 0, 0, 0), -- 1304
				1, -- 1304
				toColor(PALETTE.rouge, 130 * appear) -- 1304
			) -- 1304
		end -- 1304
	elseif self.retractAnimT > 0 and #path > 0 then -- 1306
		local prog = math.max( -- 1308
			0, -- 1308
			math.min( -- 1308
				1, -- 1308
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1308
			) -- 1308
		) -- 1308
		local revFloat = (1 - prog) * (#path - 1) -- 1309
		local idxA = math.max( -- 1310
			0, -- 1310
			math.min( -- 1310
				#path - 1, -- 1310
				math.floor(revFloat) -- 1310
			) -- 1310
		) -- 1310
		local idxB = math.max( -- 1311
			0, -- 1311
			math.min(#path - 1, idxA + 1) -- 1311
		) -- 1311
		local frac = revFloat - idxA -- 1312
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1313
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1314
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1315
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1316
	else -- 1316
		return -- 1318
	end -- 1318
	local a255 = math.floor(240 * appear + 0.5) -- 1322
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1323
	uiInkDraw:drawPolygon( -- 1324
		{ -- 1324
			Vec2(fx - 30, fy - 20), -- 1325
			Vec2(fx - 22, fy - 28), -- 1326
			Vec2(fx - 11, fy - 14), -- 1327
			Vec2(fx - 17, fy - 9) -- 1328
		}, -- 1328
		Color(164, 78, 54, a255), -- 1329
		1, -- 1329
		inkCol -- 1329
	) -- 1329
	uiInkDraw:drawSegment( -- 1331
		Vec2(fx - 16, fy - 10), -- 1331
		Vec2(fx - 11, fy - 15), -- 1331
		2, -- 1331
		Color(204, 174, 122, a255) -- 1331
	) -- 1331
	uiInkDraw:drawCircle( -- 1333
		Vec2(fx - 9, fy - 8), -- 1333
		4.8, -- 1333
		Color(238, 212, 182, a255) -- 1333
	) -- 1333
	uiInkDraw:drawSegment( -- 1334
		Vec2(fx - 7, fy - 6), -- 1334
		Vec2(fx, fy), -- 1334
		2.5, -- 1334
		Color(244, 222, 196, a255) -- 1334
	) -- 1334
	uiInkDraw:drawRing( -- 1335
		Vec2(fx, fy), -- 1335
		2, -- 1335
		3, -- 1335
		Color(0, 0, 0, 0), -- 1335
		0.9, -- 1335
		inkCol -- 1335
	) -- 1335
	uiGlow:drawDot( -- 1336
		Vec2(fx, fy), -- 1336
		3.4, -- 1336
		toColor(PALETTE.amberCore, 80 * appear) -- 1336
	) -- 1336
end -- 1284
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1340
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1347
	local bx = 46 + safe.left -- 1348
	local by = ctx.uiH - 134 - safe.top -- 1349
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1350
	drawSilkVeil( -- 1351
		uiDraw, -- 1351
		uiArt, -- 1351
		"rw_armed_veil", -- 1351
		bx + 54, -- 1351
		by, -- 1351
		142, -- 1351
		30, -- 1351
		PALETTE.inkWash, -- 1351
		0.72, -- 1351
		-1 -- 1351
	) -- 1351
	____exports.drawReloadPatternGlyph( -- 1352
		uiInkDraw, -- 1352
		bx + 12, -- 1352
		by, -- 1352
		9, -- 1352
		effect, -- 1352
		col, -- 1352
		0.96 -- 1352
	) -- 1352
	drawBlossomDot( -- 1353
		uiInkDraw, -- 1353
		uiArt, -- 1353
		"rw_armed_dot", -- 1353
		bx + 28, -- 1353
		by, -- 1353
		6, -- 1353
		col, -- 1353
		0.85, -- 1353
		3 -- 1353
	) -- 1353
	ctx.texts:put( -- 1354
		"xs", -- 1354
		____exports.reloadEffectShortLabel(effect), -- 1354
		bx + 38, -- 1354
		by, -- 1354
		toColor(PALETTE.textBright), -- 1354
		0, -- 1354
		0.5, -- 1354
		"Left", -- 1354
		1, -- 1354
		0.94, -- 1354
		0.08 -- 1354
	) -- 1354
end -- 1340
function ____exports.createReloadWheelPlugin(contract) -- 1358
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1359
end -- 1358
return ____exports -- 1358
