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
local Content = ____Dora.Content -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____depth = require("Script.watch.depth") -- 20
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 20
local ____platform = require("Script.watch.platform") -- 22
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 22
local ____target = require("Script.watch.target") -- 23
local getActiveTarget = ____target.getActiveTarget -- 23
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
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 346
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
	self.localInvalidFlash = 0 -- 322
	self.animTime = 0 -- 323
	self.nodePulseSeq = 0 -- 324
	self.panelCx = 940 -- 327
	self.panelCy = 374 -- 328
	self.panelW = 286 -- 329
	self.panelH = 316 -- 330
	self.cellStep = 66 -- 331
	self.hitRadius = 25 -- 332
	self.resetBox = Rect(0, 0, 0, 0) -- 333
	self.lastUiPtrX = 0 -- 334
	self.lastUiPtrY = 0 -- 335
	self.answerTicksAccum = 0 -- 338
	self.worldTicksAccum = 0 -- 339
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 340
	self.appliedVfx = {} -- 343
	self.injectedContract = contract -- 347
end -- 346
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 351
	self.pendingSimInput = sim -- 352
end -- 351
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 355
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 356
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 357
end -- 355
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 363
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 364
end -- 363
function ReloadWheelPlugin.prototype.getState(self) -- 372
	return { -- 373
		active = self.wasActive, -- 374
		kbCursor = self.kbCursor, -- 375
		dragging = self.dragging, -- 376
		path = __TS__ArraySlice(self.lastKnownPath), -- 377
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 378
		nextEffect = self.lastKnownNextEffect, -- 379
		retracting = self.retractAnimT > 0, -- 380
		invalidFlash = self.localInvalidFlash, -- 381
		clock = self:getClockReadings(), -- 382
		panelCenterX = self.panelCx, -- 383
		panelCenterY = self.panelCy, -- 384
		cellStep = self.cellStep -- 385
	} -- 385
end -- 372
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 389
	self.wasActive = false -- 390
	self.openAnimT = 0 -- 391
	self.retractAnimT = 0 -- 392
	self.settledPath = {} -- 393
	self.settledEffect = "normal" -- 394
	self.settledTimedOut = false -- 395
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 396
	self.lastKnownNextEffect = "normal" -- 397
	self.kbCursor = ____exports.RELOAD_START_NODE -- 398
	self.dragging = false -- 399
	self.pointerActive = false -- 400
	self.localInvalidFlash = 0 -- 401
	self.animTime = 0 -- 402
	self.answerTicksAccum = 0 -- 403
	self.worldTicksAccum = 0 -- 404
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 405
	self.appliedVfx = {} -- 406
	self.pendingSimInput = nil -- 407
	self:resetInputEdges() -- 408
end -- 389
function ReloadWheelPlugin.prototype.resetInputEdges(self, _touchMode) -- 411
	if _touchMode == nil then -- 411
		_touchMode = false -- 411
	end -- 411
	self.prevLeft = false -- 412
	self.prevRight = false -- 413
end -- 411
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 416
	local contract = resolveRuntimeContract(self.injectedContract) -- 417
	if contract ~= nil then -- 418
		return contract:submitIntent(p, intent) -- 419
	end -- 419
	return dispatchIntentFallback(p, intent) -- 421
end -- 416
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 424
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 425
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 426
	local marginX = self.panelW * 0.5 + 34 -- 427
	local minCx = marginX + safe.left -- 428
	local maxCx = math.max(minCx, ctx.uiW - marginX - safe.right) -- 429
	if soldierUiX < ctx.uiW * 0.56 then -- 430
		self.panelCx = math.min( -- 431
			maxCx, -- 431
			math.max( -- 431
				minCx, -- 431
				math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 431
			) -- 431
		) -- 431
	else -- 431
		self.panelCx = math.max( -- 433
			minCx, -- 433
			math.min( -- 433
				maxCx, -- 433
				math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 433
			) -- 433
		) -- 433
	end -- 433
	local minCy = self.panelH * 0.5 + 78 + safe.bottom -- 435
	local maxCy = math.max(minCy, ctx.uiH - self.panelH * 0.5 - 66 - safe.top) -- 436
	self.panelCy = math.max( -- 437
		minCy, -- 437
		math.min(maxCy, ctx.uiH * 0.52) -- 437
	) -- 437
	self.resetBox = Rect(self.panelCx + 56, self.panelCy + self.panelH * 0.5 - 45, 72, 26) -- 438
end -- 424
function ReloadWheelPlugin.prototype.update(self, ctx) -- 441
	local rs = ctx.view.reloadSession -- 442
	local p = ctx.p -- 443
	self:computePanelPlacement(ctx) -- 446
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 449
		0.25, -- 449
		math.min(1, ctx.view.timeScale) -- 449
	) or 1) -- 449
	if ctx.paused then -- 452
		self:resetInputEdges(ctx.input:isTouchMode()) -- 453
		return -- 454
	end -- 454
	local udt = math.max(0, ctx.uiDt) -- 457
	local wdt = math.max(0, ctx.worldDt) -- 458
	self.animTime = self.animTime + udt -- 459
	if self.localInvalidFlash > 0 then -- 461
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 462
	end -- 462
	if rs.invalidFlash > self.localInvalidFlash then -- 464
		self.localInvalidFlash = rs.invalidFlash -- 465
	end -- 465
	self:ingestAppliedEffects(ctx) -- 469
	self:updateAppliedVfx(wdt) -- 470
	if rs.active and not self.wasActive then -- 473
		self:onSessionOpened(ctx) -- 474
	elseif not rs.active and self.wasActive then -- 475
		self:onSessionClosed(ctx) -- 476
	end -- 476
	self.wasActive = rs.active -- 478
	if not rs.active then -- 480
		self.lastKnownNextEffect = rs.nextEffect -- 481
		self.lastClock.active = false -- 482
		if self.retractAnimT > 0 then -- 483
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 484
		end -- 484
		self.pendingSimInput = nil -- 486
		return -- 487
	end -- 487
	self.openAnimT = math.min( -- 491
		1, -- 491
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 491
	) -- 491
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 494
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 495
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 496
		self.answerTicksAccum = liveAns -- 497
		self.worldTicksAccum = liveWorld -- 498
	else -- 498
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 500
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 501
	end -- 501
	self.lastClock = { -- 503
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 504
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 505
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 506
		active = true -- 507
	} -- 507
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 511
	self.lastKnownPath = activePath -- 512
	self.lastKnownNextEffect = rs.nextEffect -- 513
	self:processInputs(ctx, activePath) -- 516
end -- 441
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 519
	local rs = ctx.view.reloadSession -- 520
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 521
	self.openAnimT = 0 -- 522
	self.retractAnimT = 0 -- 523
	self.kbCursor = ____exports.RELOAD_START_NODE -- 524
	self.dragging = false -- 525
	self.pointerActive = false -- 526
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 527
	self.answerTicksAccum = 0 -- 528
	self.worldTicksAccum = 0 -- 529
	self:resetInputEdges(ctx.input:isTouchMode()) -- 530
	local hasBackendOpen = false -- 532
	local i = 0 -- 533
	do -- 533
		i = 0 -- 534
		while i < #ctx.events.rawEvents do -- 534
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 535
				hasBackendOpen = true -- 536
				break -- 537
			end -- 537
			i = i + 1 -- 534
		end -- 534
	end -- 534
	if not hasBackendOpen then -- 540
		ctx.audio:playOnce( -- 541
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 542
			"sfx", -- 543
			"assets/audio/combat/reload_open.wav", -- 544
			0.8, -- 545
			"reload:open", -- 546
			ctx.p.ticks -- 547
		) -- 547
	end -- 547
end -- 519
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 552
	local rs = ctx.view.reloadSession -- 553
	self.dragging = false -- 554
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 555
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 556
		local ____self_settledPath_1 = self.settledPath -- 558
		____self_settledPath_1[#____self_settledPath_1 + 1] = ____exports.RELOAD_TARGET_NODE -- 558
	end -- 558
	self.settledEffect = rs.nextEffect -- 560
	self.settledTimedOut = rs.nextEffect == "normal" -- 561
	self.retractAnimT = self.retractDuration -- 562
	local hasBackendClose = false -- 565
	local i = 0 -- 566
	do -- 566
		i = 0 -- 567
		while i < #ctx.events.rawEvents do -- 567
			local n = ctx.events.rawEvents[i + 1].name -- 568
			if n == "reloadSolved" or n == "reloadTimeout" then -- 569
				hasBackendClose = true -- 570
				break -- 571
			end -- 571
			i = i + 1 -- 567
		end -- 567
	end -- 567
	if self.settledTimedOut then -- 575
		if not hasBackendClose then -- 576
			ctx.audio:playOnce( -- 577
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 578
				"sfx", -- 579
				"assets/audio/combat/reload_timeout.wav", -- 580
				0.78, -- 581
				"reload:timeout", -- 582
				ctx.p.ticks -- 583
			) -- 583
		end -- 583
	else -- 583
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 587
		ctx.audio:playOnce( -- 592
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 593
			"sfx", -- 594
			effectWav, -- 595
			0.88, -- 596
			"reload:solved:" .. self.settledEffect, -- 597
			ctx.p.ticks -- 598
		) -- 598
	end -- 598
end -- 552
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 603
	local sim = self.pendingSimInput -- 604
	self.pendingSimInput = nil -- 605
	local touchMode = ctx.input:isTouchMode() -- 607
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 608
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 610
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 613
	local ____temp_11 -- 616
	if (sim and sim.pointerX) ~= nil then -- 616
		____temp_11 = true -- 617
	else -- 617
		local ____useUiPtr_10 -- 618
		if useUiPtr then -- 618
			____useUiPtr_10 = ctx.input.uiInside -- 618
		else -- 618
			____useUiPtr_10 = ctx.input.inside -- 618
		end -- 618
		____temp_11 = ____useUiPtr_10 -- 618
	end -- 618
	local inside = ____temp_11 -- 616
	local ____temp_14 -- 619
	if (sim and sim.leftHeld) ~= nil then -- 619
		____temp_14 = sim.leftHeld -- 620
	else -- 620
		____temp_14 = ctx.input.uiHeld or ctx.input.fire.held -- 621
	end -- 621
	local leftHeld = ____temp_14 -- 619
	local ____temp_17 -- 622
	if (sim and sim.rightHeld) ~= nil then -- 622
		____temp_17 = sim.rightHeld -- 623
	else -- 623
		____temp_17 = ctx.input.uiRightPressed -- 624
	end -- 624
	local rightHeld = ____temp_17 -- 622
	local ____temp_20 -- 626
	if (sim and sim.leftHeld) ~= nil then -- 626
		____temp_20 = leftHeld and not self.prevLeft -- 627
	else -- 627
		____temp_20 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 628
	end -- 628
	local leftPressed = ____temp_20 -- 626
	local ____temp_23 -- 629
	if (sim and sim.leftHeld) ~= nil then -- 629
		____temp_23 = not leftHeld and self.prevLeft -- 630
	else -- 630
		____temp_23 = ctx.input.uiReleased or not leftHeld and self.prevLeft -- 631
	end -- 631
	local leftReleased = ____temp_23 -- 629
	local ____temp_26 -- 632
	if (sim and sim.rightHeld) ~= nil then -- 632
		____temp_26 = rightHeld and not self.prevRight -- 633
	else -- 633
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 634
	end -- 634
	local rightPressed = ____temp_26 -- 632
	self.prevLeft = leftHeld -- 635
	self.prevRight = rightHeld -- 636
	self.lastUiPtrX = ptrX -- 637
	self.lastUiPtrY = ptrY -- 638
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 640
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 641
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 642
	if pointerMoved or leftPressed then -- 644
		self.pointerActive = true -- 645
	end -- 645
	local lastNode = activePath[#activePath] -- 648
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 649
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 650
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 651
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 654
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 655
		self.dragging = false -- 656
		self.dragAdvanced = false -- 657
		self:triggerInvalidReset(ctx, activePath, false) -- 658
		return -- 659
	end -- 659
	if leftPressed then -- 663
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 664
			self.dragging = true -- 665
			self.dragAdvanced = false -- 666
			self.kbCursor = lastNode -- 667
		elseif hitNode >= 0 then -- 668
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 669
				self.dragging = true -- 670
				self.dragAdvanced = false -- 671
				self:commitNodeStep(ctx, hitNode, activePath) -- 672
			else -- 672
				self.dragging = false -- 674
				self.dragAdvanced = false -- 675
				self:triggerInvalidReset(ctx, activePath, true) -- 676
			end -- 676
			return -- 678
		end -- 678
	elseif self.dragging and leftHeld then -- 680
		if hitNode >= 0 and hitNode ~= lastNode then -- 681
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 682
				self.dragAdvanced = true -- 683
				self:commitNodeStep(ctx, hitNode, activePath) -- 684
			else -- 684
				self.dragging = false -- 687
				self.dragAdvanced = false -- 688
				self:triggerInvalidReset(ctx, activePath, true) -- 689
			end -- 689
			return -- 691
		end -- 691
	elseif leftReleased and self.dragging then -- 693
		local wasDragStroke = self.dragAdvanced -- 694
		self.dragging = false -- 695
		self.dragAdvanced = false -- 696
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 698
			self:triggerInvalidReset(ctx, activePath, true) -- 699
			return -- 700
		end -- 700
	end -- 700
	local dCol = 0 -- 705
	local dRow = 0 -- 706
	local confirmPressed = false -- 707
	local resetPressed = false -- 708
	local gpAutoCommit = false -- 709
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 711
		dCol = sim.moveCol or 0 -- 712
		dRow = sim.moveRow or 0 -- 713
		confirmPressed = sim.confirm == true -- 714
		resetPressed = sim.reset == true -- 715
	else -- 715
		if ctx.input.reloadReset then -- 717
			resetPressed = true -- 718
		end -- 718
		if ctx.input.reloadConfirm then -- 720
			confirmPressed = true -- 721
		end -- 721
		if ctx.input.reloadStepEdge then -- 723
			dCol = ctx.input.reloadDirCol -- 724
			dRow = ctx.input.reloadDirRow -- 725
			gpAutoCommit = ctx.input.reloadAutoStep -- 726
		end -- 726
	end -- 726
	if resetPressed and #activePath > 1 then -- 730
		self:triggerInvalidReset(ctx, activePath, false) -- 731
		return -- 732
	end -- 732
	if dCol ~= 0 or dRow ~= 0 then -- 735
		self.pointerActive = false -- 736
		local baseIdx = gpAutoCommit and lastNode or self.kbCursor -- 737
		local cur = ____exports.RELOAD_GRID[baseIdx + 1] or ____exports.RELOAD_GRID[1] -- 738
		local nextCol = math.max( -- 739
			0, -- 739
			math.min(2, cur.col + dCol) -- 739
		) -- 739
		local nextRow = math.max( -- 740
			0, -- 740
			math.min(2, cur.row + dRow) -- 740
		) -- 740
		local nextIdx = nextRow * 3 + nextCol -- 741
		self.kbCursor = nextIdx -- 742
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 743
			self:commitNodeStep(ctx, nextIdx, activePath) -- 744
			return -- 745
		end -- 745
	end -- 745
	if confirmPressed then -- 749
		self.pointerActive = false -- 750
		if self.kbCursor == lastNode then -- 751
			return -- 752
		end -- 752
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 754
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 755
		else -- 755
			self:triggerInvalidReset(ctx, activePath, true) -- 757
		end -- 757
	end -- 757
end -- 603
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 762
	self.kbCursor = node -- 763
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 764
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 765
	if node == ____exports.RELOAD_TARGET_NODE then -- 766
		self.dragging = false -- 767
		return -- 768
	end -- 768
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 771
	local stepIdx = math.max( -- 772
		1, -- 772
		math.min(6, #self.lastKnownPath) -- 772
	) -- 772
	local pitched = ("assets/audio/combat/reload_node_" .. tostring(stepIdx)) .. ".wav" -- 773
	local nodePath = Content:exist(pitched) and pitched or "assets/audio/combat/reload_node.wav" -- 774
	ctx.audio:playOnce( -- 775
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 776
		"sfx", -- 777
		nodePath, -- 778
		0.78, -- 779
		"reload:node:" .. tostring(node), -- 780
		ctx.p.ticks -- 781
	) -- 781
end -- 762
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 785
	if flashError then -- 786
		self.localInvalidFlash = 0.36 -- 787
	end -- 787
	self.kbCursor = ____exports.RELOAD_START_NODE -- 789
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 790
	if #activePath > 1 then -- 792
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 793
	end -- 793
	if flashError then -- 795
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 796
		ctx.audio:playOnce( -- 797
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 798
			"sfx", -- 799
			"assets/audio/combat/reload_invalid.wav", -- 800
			0.72, -- 801
			"reload:invalid", -- 802
			ctx.p.ticks -- 803
		) -- 803
	end -- 803
end -- 785
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 808
	if hitR == nil then -- 808
		hitR = self.hitRadius -- 808
	end -- 808
	local r2 = hitR * hitR -- 809
	local i = 0 -- 810
	do -- 810
		i = 0 -- 811
		while i < #____exports.RELOAD_GRID do -- 811
			local pos = self:getNodeUiPos(i) -- 812
			local dx = uiX - pos.x -- 813
			local dy = uiY - pos.y -- 814
			if dx * dx + dy * dy <= r2 then -- 815
				return i -- 816
			end -- 816
			i = i + 1 -- 811
		end -- 811
	end -- 811
	return -1 -- 819
end -- 808
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 822
	local p = ctx.p -- 823
	local triggered = false -- 824
	local i = 0 -- 825
	do -- 825
		i = 0 -- 826
		while i < #ctx.events.rawEvents do -- 826
			local e = ctx.events.rawEvents[i + 1] -- 827
			if e.name == "reloadApplied" then -- 828
				local rawEff = e.data.effect -- 829
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 830
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 833
				self:spawnAppliedVfx(eff, p, ex) -- 834
				triggered = true -- 835
			end -- 835
			i = i + 1 -- 826
		end -- 826
	end -- 826
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 839
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 840
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 841
	end -- 841
end -- 822
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 845
	local originX = p.player.x + p.player.facing * 18 -- 846
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 847
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 848
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 849
	local ____self_appliedVfx_29 = self.appliedVfx -- 850
	____self_appliedVfx_29[#____self_appliedVfx_29 + 1] = { -- 850
		effect = effect, -- 851
		originX = originX, -- 852
		originY = originY, -- 853
		targetX = targetX, -- 854
		targetY = targetY, -- 855
		facing = p.player.facing >= 0 and 1 or -1, -- 856
		life = maxLife, -- 857
		maxLife = maxLife -- 858
	} -- 858
end -- 845
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 862
	if wdt <= 0 or #self.appliedVfx == 0 then -- 863
		return -- 864
	end -- 864
	local w = 0 -- 866
	local i = 0 -- 867
	do -- 867
		i = 0 -- 868
		while i < #self.appliedVfx do -- 868
			local fx = self.appliedVfx[i + 1] -- 869
			fx.life = fx.life - wdt -- 870
			if fx.life > 0 then -- 871
				self.appliedVfx[w + 1] = fx -- 872
				w = w + 1 -- 873
			end -- 873
			i = i + 1 -- 868
		end -- 868
	end -- 868
	__TS__ArraySetLength(self.appliedVfx, w) -- 876
end -- 862
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 880
	if #self.appliedVfx == 0 then -- 886
		return -- 887
	end -- 887
	local cam = ctx.cam -- 889
	local i = 0 -- 890
	do -- 890
		i = 0 -- 891
		while i < #self.appliedVfx do -- 891
			local fx = self.appliedVfx[i + 1] -- 892
			local k = math.max( -- 893
				0, -- 893
				math.min(1, fx.life / fx.maxLife) -- 893
			) -- 893
			local prog = 1 - k -- 894
			local ox = cam:sx(fx.originX) -- 895
			local oy = cam:sy(fx.originY) -- 896
			local tx = cam:sx(fx.targetX) -- 897
			local ty = cam:sy(fx.targetY) -- 898
			if fx.effect == "knockback" then -- 900
				local r = cam:len(12 + prog * 34) -- 902
				local startA = fx.facing >= 0 and -48 or 132 -- 903
				local endA = fx.facing >= 0 and 48 or 228 -- 904
				fgGlow:drawArc( -- 905
					Vec2(tx, ty), -- 905
					r, -- 905
					startA, -- 905
					endA, -- 905
					2.4 * k, -- 905
					toColor(PALETTE.moonPale, 210 * k) -- 905
				) -- 905
				fgDraw:drawArc( -- 906
					Vec2( -- 906
						tx - fx.facing * cam:len(6), -- 906
						ty -- 906
					), -- 906
					r * 0.72, -- 906
					startA, -- 906
					endA, -- 906
					1.5 * k, -- 906
					toColor(PALETTE.silkLine, 165 * k) -- 906
				) -- 906
			elseif fx.effect == "echo" then -- 907
				local r1 = cam:len(10 + prog * 64) -- 909
				local r2 = cam:len(6 + prog * 40) -- 910
				fgGlow:drawRing( -- 911
					Vec2(tx, ty), -- 911
					math.max(1, r1 - 1.6), -- 911
					r1, -- 911
					Color(0, 0, 0, 0), -- 911
					1.3, -- 911
					toColor(PALETTE.amber, 210 * k) -- 911
				) -- 911
				fgGlow:drawRing( -- 912
					Vec2(tx, ty), -- 912
					math.max(1, r2 - 1.2), -- 912
					r2, -- 912
					Color(0, 0, 0, 0), -- 912
					1, -- 912
					toColor(PALETTE.amberCore, 175 * k) -- 912
				) -- 912
			elseif fx.effect == "light" then -- 913
				fgGlow:drawSegment( -- 915
					Vec2(ox, oy), -- 915
					Vec2(tx, ty), -- 915
					5 * k, -- 915
					toColor(PALETTE.amber, 68 * k) -- 915
				) -- 915
				fgGlow:drawSegment( -- 916
					Vec2(ox, oy), -- 916
					Vec2(tx, ty), -- 916
					1.8 * k, -- 916
					toColor(PALETTE.amberCore, 185 * k) -- 916
				) -- 916
				fillRadialGlow( -- 917
					fgGlow, -- 917
					tx, -- 917
					ty, -- 917
					cam:len(42 * (0.6 + prog * 0.4)), -- 917
					cam:len(34), -- 917
					toColor(PALETTE.amberCore, 118 * k), -- 917
					Color(244, 234, 214, 0), -- 917
					16 -- 917
				) -- 917
			end -- 917
			i = i + 1 -- 891
		end -- 891
	end -- 891
end -- 880
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 923
	local rs = ctx.view.reloadSession -- 930
	local active = rs.active -- 931
	local retracting = not active and self.retractAnimT > 0.01 -- 932
	if not active and not retracting then -- 933
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 935
			self:drawArmedEffectBadge( -- 936
				uiDraw, -- 936
				uiInkDraw, -- 936
				uiArt, -- 936
				ctx, -- 936
				rs.nextEffect -- 936
			) -- 936
		end -- 936
		return false -- 938
	end -- 938
	local cx = self.panelCx -- 941
	local cy = self.panelCy -- 942
	local pw = self.panelW -- 943
	local ph = self.panelH -- 944
	local x0 = cx - pw * 0.5 -- 945
	local y0 = cy - ph * 0.5 -- 946
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 948
		0, -- 950
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 950
	) -- 950
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 951
	local px = cx + shakeX -- 954
	if active then -- 957
		uiDraw:drawRect( -- 958
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 958
			Color( -- 958
				10, -- 958
				13, -- 958
				20, -- 958
				math.floor(54 * appear + 0.5) -- 958
			) -- 958
		) -- 958
	end -- 958
	drawSilkVeil( -- 962
		uiDraw, -- 962
		uiArt, -- 962
		"rw_outer_veil", -- 962
		px, -- 962
		cy, -- 962
		pw + 34, -- 962
		ph + 28, -- 962
		PALETTE.inkWash, -- 962
		0.72 * appear, -- 962
		-2 -- 962
	) -- 962
	if not uiArt:tryPlace( -- 963
		"ink_song_paper", -- 963
		"rw_paper", -- 963
		px, -- 963
		cy, -- 963
		pw, -- 963
		ph, -- 963
		{opacity = 0.94 * appear, layer = 1} -- 963
	) then -- 963
		uiDraw:drawRoundedRect( -- 964
			Rect(x0 + shakeX, y0, pw, ph), -- 965
			6, -- 966
			toColor(PALETTE.xuanPaper, 240 * appear), -- 967
			1.2, -- 968
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 969
		) -- 969
	end -- 969
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 972
	drawFiligreeCorners( -- 973
		uiInkDraw, -- 973
		uiArt, -- 973
		"rw_frame", -- 973
		x0 + shakeX + 8, -- 973
		y0 + 8, -- 973
		pw - 16, -- 973
		ph - 16, -- 973
		frameCol, -- 973
		0.72 * appear, -- 973
		22, -- 973
		true, -- 973
		2 -- 973
	) -- 973
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 976
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 979
	local effAccent = self:effectInkColor(previewEffect) -- 982
	local headY = y0 + ph - 32 -- 984
	____exports.drawReloadPatternGlyph( -- 985
		uiInkDraw, -- 985
		px - 52, -- 985
		headY, -- 985
		11, -- 985
		previewEffect, -- 985
		effAccent, -- 985
		appear -- 985
	) -- 985
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 986
	ctx.texts:put( -- 989
		"sm", -- 990
		titleText, -- 991
		px - 32, -- 992
		headY, -- 993
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 994
		0, -- 995
		0.5, -- 996
		"Left", -- 997
		1.6, -- 998
		0.96 * appear, -- 999
		0 -- 1000
	) -- 1000
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1002
		local canReset = #activePath > 1 -- 1003
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1004
		uiInkDraw:drawRect( -- 1005
			rb, -- 1006
			Color( -- 1007
				32, -- 1007
				30, -- 1007
				32, -- 1007
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1007
			), -- 1007
			0.85, -- 1008
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1009
		) -- 1009
		ctx.texts:put( -- 1011
			"xs", -- 1012
			"重画", -- 1013
			rb.x + rb.width * 0.5, -- 1014
			rb.y + rb.height * 0.5, -- 1015
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1016
			0.5, -- 1017
			0.5, -- 1018
			"Center", -- 1019
			1, -- 1020
			(canReset and 0.94 or 0.52) * appear, -- 1021
			0 -- 1022
		) -- 1022
	end -- 1022
	drawHairline( -- 1025
		uiInkDraw, -- 1025
		uiArt, -- 1025
		"rw_head_line", -- 1025
		px, -- 1025
		headY - 18, -- 1025
		pw - 42, -- 1025
		PALETTE.xuanInkSub, -- 1025
		0.45 * appear, -- 1025
		false, -- 1025
		2 -- 1025
	) -- 1025
	local idx = 0 -- 1028
	do -- 1028
		idx = 0 -- 1029
		while idx < 3 do -- 1029
			local hA = self:getNodeUiPos(idx * 3) -- 1030
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1031
			uiInkDraw:drawSegment( -- 1032
				Vec2(hA.x + shakeX, hA.y), -- 1032
				Vec2(hB.x + shakeX, hB.y), -- 1032
				0.75, -- 1032
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1032
			) -- 1032
			local vA = self:getNodeUiPos(idx) -- 1033
			local vB = self:getNodeUiPos(6 + idx) -- 1034
			uiInkDraw:drawSegment( -- 1035
				Vec2(vA.x + shakeX, vA.y), -- 1035
				Vec2(vB.x + shakeX, vB.y), -- 1035
				0.75, -- 1035
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1035
			) -- 1035
			idx = idx + 1 -- 1029
		end -- 1029
	end -- 1029
	if #activePath >= 2 then -- 1039
		self:drawPathStrokes( -- 1040
			uiInkDraw, -- 1040
			uiGlow, -- 1040
			activePath, -- 1040
			previewEffect, -- 1040
			effAccent, -- 1040
			shakeX, -- 1040
			appear -- 1040
		) -- 1040
	end -- 1040
	if active and self.dragging and #activePath >= 1 then -- 1044
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1045
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1046
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1047
		uiInkDraw:drawSegment( -- 1048
			Vec2(tail.x + shakeX, tail.y), -- 1048
			Vec2(mx, my), -- 1048
			1.4, -- 1048
			toColor(effAccent, 150 * appear) -- 1048
		) -- 1048
		uiInkDraw:drawDot( -- 1049
			Vec2(mx, my), -- 1049
			3, -- 1049
			toColor(effAccent, 210 * appear) -- 1049
		) -- 1049
	end -- 1049
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1053
	do -- 1053
		idx = 0 -- 1054
		while idx < #____exports.RELOAD_GRID do -- 1054
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1055
			local pos = self:getNodeUiPos(idx) -- 1056
			local nx = pos.x + shakeX -- 1057
			local ny = pos.y -- 1058
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1059
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1060
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1061
			self:drawGridNode( -- 1062
				uiInkDraw, -- 1062
				uiGlow, -- 1062
				spec, -- 1062
				nx, -- 1062
				ny, -- 1062
				inPath, -- 1062
				isValidNext, -- 1062
				isKbFocus, -- 1062
				effAccent, -- 1062
				appear -- 1062
			) -- 1062
			idx = idx + 1 -- 1054
		end -- 1054
	end -- 1054
	self:drawChildFinger( -- 1066
		uiInkDraw, -- 1066
		uiGlow, -- 1066
		active, -- 1066
		activePath, -- 1066
		shakeX, -- 1066
		appear -- 1066
	) -- 1066
	local barW = pw - 52 -- 1069
	local barX = px - barW * 0.5 -- 1070
	local barY = y0 + 28 -- 1071
	local remainFrac = active and math.max( -- 1072
		0, -- 1073
		math.min( -- 1073
			1, -- 1073
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1073
		) -- 1073
	) or (self.settledTimedOut and 0 or 1) -- 1074
	local urgent = active and remainFrac < 0.25 -- 1075
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1076
	uiInkDraw:drawSegment( -- 1077
		Vec2(barX, barY), -- 1077
		Vec2(barX + barW, barY), -- 1077
		1.4, -- 1077
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1077
	) -- 1077
	if remainFrac > 0.005 then -- 1078
		uiInkDraw:drawSegment( -- 1079
			Vec2(barX, barY), -- 1079
			Vec2(barX + barW * remainFrac, barY), -- 1079
			3, -- 1079
			toColor(barCol, 225 * appear) -- 1079
		) -- 1079
	end -- 1079
	local tTick = 1 -- 1082
	do -- 1082
		tTick = 1 -- 1083
		while tTick <= 3 do -- 1083
			local tx = barX + barW * (tTick / 4) -- 1084
			uiInkDraw:drawSegment( -- 1085
				Vec2(tx, barY - 3.5), -- 1085
				Vec2(tx, barY + 3.5), -- 1085
				0.9, -- 1085
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1085
			) -- 1085
			tTick = tTick + 1 -- 1083
		end -- 1083
	end -- 1083
	if active and ctx.view.assistHintsEnabled then -- 1089
		local mode = ctx.input.inputMode -- 1090
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. getActiveTarget():keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1091
		ctx.texts:put( -- 1096
			"xs", -- 1097
			hint, -- 1098
			px, -- 1099
			y0 + 13, -- 1100
			toColor(PALETTE.xuanInkSub), -- 1101
			0.5, -- 1102
			0.5, -- 1103
			"Center", -- 1104
			0.6, -- 1105
			0.82 * appear, -- 1106
			0 -- 1107
		) -- 1107
	end -- 1107
	return active -- 1111
end -- 923
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1114
	if effect == "echo" then -- 1115
		return PALETTE.rouge -- 1116
	end -- 1116
	if effect == "light" then -- 1118
		return PALETTE.amberDim -- 1119
	end -- 1119
	if effect == "knockback" then -- 1121
		return PALETTE.xuanInk -- 1122
	end -- 1122
	return PALETTE.xuanInkSub -- 1124
end -- 1114
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1127
	local i = 0 -- 1136
	do -- 1136
		i = 0 -- 1137
		while i < #path - 1 do -- 1137
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1138
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1139
			local ax = p0.x + shakeX -- 1140
			local ay = p0.y -- 1141
			local bx = p1.x + shakeX -- 1142
			local by = p1.y -- 1143
			if effect == "echo" then -- 1145
				local dx = bx - ax -- 1147
				local dy = by - ay -- 1148
				local len = math.max( -- 1149
					1, -- 1149
					math.sqrt(dx * dx + dy * dy) -- 1149
				) -- 1149
				local nx = -dy / len * 2.2 -- 1150
				local ny = dx / len * 2.2 -- 1151
				uiInkDraw:drawSegment( -- 1152
					Vec2(ax + nx, ay + ny), -- 1152
					Vec2(bx + nx, by + ny), -- 1152
					1.35, -- 1152
					toColor(col, 220 * appear) -- 1152
				) -- 1152
				uiInkDraw:drawSegment( -- 1153
					Vec2(ax - nx, ay - ny), -- 1153
					Vec2(bx - nx, by - ny), -- 1153
					1.35, -- 1153
					toColor(col, 220 * appear) -- 1153
				) -- 1153
			elseif effect == "light" then -- 1154
				uiInkDraw:drawSegment( -- 1156
					Vec2(ax, ay), -- 1156
					Vec2(bx, by), -- 1156
					3.1, -- 1156
					toColor(PALETTE.xuanInk, 195 * appear) -- 1156
				) -- 1156
				uiInkDraw:drawSegment( -- 1157
					Vec2(ax, ay), -- 1157
					Vec2(bx, by), -- 1157
					1.3, -- 1157
					toColor(PALETTE.amberCore, 235 * appear) -- 1157
				) -- 1157
				uiGlow:drawSegment( -- 1158
					Vec2(ax, ay), -- 1158
					Vec2(bx, by), -- 1158
					3.2, -- 1158
					toColor(PALETTE.amber, 55 * appear) -- 1158
				) -- 1158
			else -- 1158
				uiInkDraw:drawSegment( -- 1161
					Vec2(ax, ay), -- 1161
					Vec2(bx, by), -- 1161
					2.8, -- 1161
					toColor(col, 230 * appear) -- 1161
				) -- 1161
			end -- 1161
			i = i + 1 -- 1137
		end -- 1137
	end -- 1137
end -- 1127
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1166
	local baseR = spec.kind == "plain" and 11 or 15 -- 1178
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1179
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1180
	if isKbFocus then -- 1183
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1184
		uiInkDraw:drawRing( -- 1185
			Vec2(nx, ny), -- 1185
			baseR + 4.5, -- 1185
			baseR + 6.2, -- 1185
			Color(0, 0, 0, 0), -- 1185
			1.1, -- 1185
			toColor(focusCol, 215 * appear) -- 1185
		) -- 1185
	end -- 1185
	if spec.kind == "bell" then -- 1188
		if inPath then -- 1190
			uiInkDraw:drawCircle( -- 1191
				Vec2(nx, ny), -- 1191
				baseR + 1, -- 1191
				toColor(PALETTE.rouge, 36 * appear) -- 1191
			) -- 1191
			uiGlow:drawRing( -- 1192
				Vec2(nx, ny), -- 1192
				baseR + 2, -- 1192
				baseR + 5, -- 1192
				Color(0, 0, 0, 0), -- 1192
				1.2, -- 1192
				toColor(PALETTE.rouge, 110 * appear) -- 1192
			) -- 1192
		end -- 1192
		uiInkDraw:drawRing( -- 1194
			Vec2(nx, ny), -- 1194
			baseR - 1.2, -- 1194
			baseR, -- 1194
			Color(0, 0, 0, 0), -- 1194
			1.1, -- 1194
			toColor(strokeCol, strokeAlpha * appear) -- 1194
		) -- 1194
		____exports.drawReloadPatternGlyph( -- 1195
			uiInkDraw, -- 1195
			nx, -- 1195
			ny, -- 1195
			9.5, -- 1195
			"echo", -- 1195
			inPath and PALETTE.rouge or strokeCol, -- 1195
			appear -- 1195
		) -- 1195
		return -- 1196
	end -- 1196
	if spec.kind == "lamp" then -- 1199
		if inPath then -- 1201
			uiInkDraw:drawCircle( -- 1202
				Vec2(nx, ny), -- 1202
				baseR + 1, -- 1202
				toColor(PALETTE.amber, 56 * appear) -- 1202
			) -- 1202
			fillRadialGlow( -- 1203
				uiGlow, -- 1203
				nx, -- 1203
				ny, -- 1203
				22, -- 1203
				22, -- 1203
				toColor(PALETTE.amberCore, 72 * appear), -- 1203
				Color(244, 234, 214, 0), -- 1203
				12 -- 1203
			) -- 1203
		end -- 1203
		uiInkDraw:drawRing( -- 1205
			Vec2(nx, ny), -- 1205
			baseR - 1.2, -- 1205
			baseR, -- 1205
			Color(0, 0, 0, 0), -- 1205
			1.1, -- 1205
			toColor(strokeCol, strokeAlpha * appear) -- 1205
		) -- 1205
		____exports.drawReloadPatternGlyph( -- 1206
			uiInkDraw, -- 1206
			nx, -- 1206
			ny, -- 1206
			9.5, -- 1206
			"light", -- 1206
			inPath and PALETTE.xuanInk or strokeCol, -- 1206
			appear -- 1206
		) -- 1206
		return -- 1207
	end -- 1207
	if spec.kind == "target" then -- 1210
		drawDiamond( -- 1212
			uiInkDraw, -- 1213
			nx, -- 1214
			ny, -- 1215
			baseR, -- 1216
			baseR, -- 1217
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1218
			1.4, -- 1219
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1220
		) -- 1220
		drawDiamond( -- 1222
			uiInkDraw, -- 1223
			nx, -- 1224
			ny, -- 1225
			baseR * 0.56, -- 1226
			baseR * 0.56, -- 1227
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1228
		) -- 1228
		return -- 1230
	end -- 1230
	if spec.kind == "start" then -- 1233
		uiInkDraw:drawRing( -- 1235
			Vec2(nx, ny), -- 1235
			baseR - 2.2, -- 1235
			baseR, -- 1235
			Color(0, 0, 0, 0), -- 1235
			1.2, -- 1235
			toColor(PALETTE.rouge, 220 * appear) -- 1235
		) -- 1235
		uiInkDraw:drawCircle( -- 1236
			Vec2(nx, ny), -- 1236
			4.8, -- 1236
			toColor(PALETTE.xuanInk, 235 * appear) -- 1236
		) -- 1236
		return -- 1237
	end -- 1237
	if inPath then -- 1241
		uiInkDraw:drawCircle( -- 1242
			Vec2(nx, ny), -- 1242
			6.2, -- 1242
			toColor(effAccent, 235 * appear) -- 1242
		) -- 1242
		uiInkDraw:drawRing( -- 1243
			Vec2(nx, ny), -- 1243
			9.5, -- 1243
			10.8, -- 1243
			Color(0, 0, 0, 0), -- 1243
			1, -- 1243
			toColor(effAccent, 165 * appear) -- 1243
		) -- 1243
	else -- 1243
		uiInkDraw:drawRing( -- 1245
			Vec2(nx, ny), -- 1245
			5.6, -- 1245
			7, -- 1245
			Color(0, 0, 0, 0), -- 1245
			1, -- 1245
			toColor(strokeCol, strokeAlpha * appear) -- 1245
		) -- 1245
	end -- 1245
end -- 1166
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1250
	local fx = 0 -- 1258
	local fy = 0 -- 1259
	if active then -- 1261
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1262
		local pos = self:getNodeUiPos(tipNode) -- 1263
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1264
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1265
		fy = pos.y - 6 - tapPulse -- 1266
		if #path <= 1 then -- 1267
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1269
			uiInkDraw:drawRing( -- 1270
				Vec2(pos.x + shakeX, pos.y), -- 1270
				ringR - 1, -- 1270
				ringR, -- 1270
				Color(0, 0, 0, 0), -- 1270
				1, -- 1270
				toColor(PALETTE.rouge, 130 * appear) -- 1270
			) -- 1270
		end -- 1270
	elseif self.retractAnimT > 0 and #path > 0 then -- 1272
		local prog = math.max( -- 1274
			0, -- 1274
			math.min( -- 1274
				1, -- 1274
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1274
			) -- 1274
		) -- 1274
		local revFloat = (1 - prog) * (#path - 1) -- 1275
		local idxA = math.max( -- 1276
			0, -- 1276
			math.min( -- 1276
				#path - 1, -- 1276
				math.floor(revFloat) -- 1276
			) -- 1276
		) -- 1276
		local idxB = math.max( -- 1277
			0, -- 1277
			math.min(#path - 1, idxA + 1) -- 1277
		) -- 1277
		local frac = revFloat - idxA -- 1278
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1279
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1280
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1281
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1282
	else -- 1282
		return -- 1284
	end -- 1284
	local a255 = math.floor(240 * appear + 0.5) -- 1288
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1289
	uiInkDraw:drawPolygon( -- 1290
		{ -- 1290
			Vec2(fx - 30, fy - 20), -- 1291
			Vec2(fx - 22, fy - 28), -- 1292
			Vec2(fx - 11, fy - 14), -- 1293
			Vec2(fx - 17, fy - 9) -- 1294
		}, -- 1294
		Color(164, 78, 54, a255), -- 1295
		1, -- 1295
		inkCol -- 1295
	) -- 1295
	uiInkDraw:drawSegment( -- 1297
		Vec2(fx - 16, fy - 10), -- 1297
		Vec2(fx - 11, fy - 15), -- 1297
		2, -- 1297
		Color(204, 174, 122, a255) -- 1297
	) -- 1297
	uiInkDraw:drawCircle( -- 1299
		Vec2(fx - 9, fy - 8), -- 1299
		4.8, -- 1299
		Color(238, 212, 182, a255) -- 1299
	) -- 1299
	uiInkDraw:drawSegment( -- 1300
		Vec2(fx - 7, fy - 6), -- 1300
		Vec2(fx, fy), -- 1300
		2.5, -- 1300
		Color(244, 222, 196, a255) -- 1300
	) -- 1300
	uiInkDraw:drawRing( -- 1301
		Vec2(fx, fy), -- 1301
		2, -- 1301
		3, -- 1301
		Color(0, 0, 0, 0), -- 1301
		0.9, -- 1301
		inkCol -- 1301
	) -- 1301
	uiGlow:drawDot( -- 1302
		Vec2(fx, fy), -- 1302
		3.4, -- 1302
		toColor(PALETTE.amberCore, 80 * appear) -- 1302
	) -- 1302
end -- 1250
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1306
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1313
	local bx = 46 + safe.left -- 1314
	local by = ctx.uiH - 134 - safe.top -- 1315
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1316
	drawSilkVeil( -- 1317
		uiDraw, -- 1317
		uiArt, -- 1317
		"rw_armed_veil", -- 1317
		bx + 54, -- 1317
		by, -- 1317
		142, -- 1317
		30, -- 1317
		PALETTE.inkWash, -- 1317
		0.72, -- 1317
		-1 -- 1317
	) -- 1317
	____exports.drawReloadPatternGlyph( -- 1318
		uiInkDraw, -- 1318
		bx + 12, -- 1318
		by, -- 1318
		9, -- 1318
		effect, -- 1318
		col, -- 1318
		0.96 -- 1318
	) -- 1318
	drawBlossomDot( -- 1319
		uiInkDraw, -- 1319
		uiArt, -- 1319
		"rw_armed_dot", -- 1319
		bx + 28, -- 1319
		by, -- 1319
		6, -- 1319
		col, -- 1319
		0.85, -- 1319
		3 -- 1319
	) -- 1319
	ctx.texts:put( -- 1320
		"xs", -- 1320
		____exports.reloadEffectShortLabel(effect), -- 1320
		bx + 38, -- 1320
		by, -- 1320
		toColor(PALETTE.textBright), -- 1320
		0, -- 1320
		0.5, -- 1320
		"Left", -- 1320
		1, -- 1320
		0.94, -- 1320
		0.08 -- 1320
	) -- 1320
end -- 1306
function ____exports.createReloadWheelPlugin(contract) -- 1324
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1325
end -- 1324
return ____exports -- 1324
