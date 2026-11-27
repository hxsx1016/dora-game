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
function ____exports.drawReloadPatternGlyph(draw, cx, cy, radius, effect, col, alpha, uiArt, instanceKey, layer) -- 151
	if alpha == nil then -- 158
		alpha = 1 -- 158
	end -- 158
	if layer == nil then -- 161
		layer = 4 -- 161
	end -- 161
	local r = math.max(5, radius) -- 163
	if uiArt ~= nil and instanceKey ~= nil and effect ~= "normal" then -- 164
		local slot = effect == "echo" and "fe_glyph_bell" or (effect == "light" and "fe_glyph_lamp" or "fe_glyph_push") -- 165
		local sz = math.floor(r * 2.2 + 0.5) -- 168
		if uiArt:tryPlace( -- 169
			slot, -- 169
			instanceKey, -- 169
			math.floor(cx + 0.5), -- 169
			math.floor(cy + 0.5), -- 169
			sz, -- 169
			sz, -- 169
			{ -- 169
				color = toColor(col, 255), -- 170
				opacity = alpha, -- 171
				layer = layer -- 172
			} -- 172
		) then -- 172
			return -- 174
		end -- 174
	end -- 174
	local stroke = toColor(col, 235 * alpha) -- 177
	local faint = toColor(col, 130 * alpha) -- 178
	if effect == "echo" then -- 180
		draw:drawPolygon( -- 182
			{ -- 182
				Vec2(cx - r * 0.56, cy - r * 0.36), -- 183
				Vec2(cx + r * 0.56, cy - r * 0.36), -- 184
				Vec2(cx + r * 0.34, cy + r * 0.42), -- 185
				Vec2(cx, cy + r * 0.62), -- 186
				Vec2(cx - r * 0.34, cy + r * 0.42) -- 187
			}, -- 187
			Color(0, 0, 0, 0), -- 188
			1.35, -- 188
			stroke -- 188
		) -- 188
		draw:drawDot( -- 189
			Vec2(cx, cy - r * 0.54), -- 189
			math.max(1.6, r * 0.16), -- 189
			stroke -- 189
		) -- 189
		draw:drawArc( -- 190
			Vec2(cx, cy + r * 0.04), -- 190
			r * 0.92, -- 190
			-32, -- 190
			32, -- 190
			1, -- 190
			faint -- 190
		) -- 190
		draw:drawArc( -- 191
			Vec2(cx, cy + r * 0.04), -- 191
			r * 0.92, -- 191
			148, -- 191
			212, -- 191
			1, -- 191
			faint -- 191
		) -- 191
		return -- 192
	end -- 192
	if effect == "light" then -- 195
		draw:drawPolygon( -- 197
			{ -- 197
				Vec2(cx, cy + r * 0.72), -- 198
				Vec2(cx + r * 0.48, cy + r * 0.28), -- 199
				Vec2(cx + r * 0.42, cy - r * 0.44), -- 200
				Vec2(cx, cy - r * 0.64), -- 201
				Vec2(cx - r * 0.42, cy - r * 0.44), -- 202
				Vec2(cx - r * 0.48, cy + r * 0.28) -- 203
			}, -- 203
			Color(0, 0, 0, 0), -- 204
			1.35, -- 204
			stroke -- 204
		) -- 204
		drawDiamond( -- 205
			draw, -- 205
			cx, -- 205
			cy, -- 205
			r * 0.22, -- 205
			r * 0.3, -- 205
			stroke -- 205
		) -- 205
		draw:drawSegment( -- 207
			Vec2(cx - r * 0.98, cy), -- 207
			Vec2(cx - r * 0.68, cy), -- 207
			1.1, -- 207
			faint -- 207
		) -- 207
		draw:drawSegment( -- 208
			Vec2(cx + r * 0.68, cy), -- 208
			Vec2(cx + r * 0.98, cy), -- 208
			1.1, -- 208
			faint -- 208
		) -- 208
		draw:drawSegment( -- 209
			Vec2(cx, cy + r * 0.8), -- 209
			Vec2(cx, cy + r * 1.04), -- 209
			1.1, -- 209
			faint -- 209
		) -- 209
		draw:drawSegment( -- 210
			Vec2(cx, cy - r * 0.74), -- 210
			Vec2(cx, cy - r * 1), -- 210
			1.1, -- 210
			faint -- 210
		) -- 210
		return -- 211
	end -- 211
	if effect == "knockback" then -- 214
		draw:drawSegment( -- 216
			Vec2(cx - r * 0.85, cy), -- 216
			Vec2(cx + r * 0.85, cy), -- 216
			1.6, -- 216
			stroke -- 216
		) -- 216
		draw:drawSegment( -- 217
			Vec2(cx + r * 0.24, cy + r * 0.54), -- 217
			Vec2(cx + r * 0.85, cy), -- 217
			1.5, -- 217
			stroke -- 217
		) -- 217
		draw:drawSegment( -- 218
			Vec2(cx + r * 0.24, cy - r * 0.54), -- 218
			Vec2(cx + r * 0.85, cy), -- 218
			1.5, -- 218
			stroke -- 218
		) -- 218
		draw:drawSegment( -- 219
			Vec2(cx - r * 0.34, cy + r * 0.36), -- 219
			Vec2(cx + r * 0.14, cy), -- 219
			1.1, -- 219
			faint -- 219
		) -- 219
		draw:drawSegment( -- 220
			Vec2(cx - r * 0.34, cy - r * 0.36), -- 220
			Vec2(cx + r * 0.14, cy), -- 220
			1.1, -- 220
			faint -- 220
		) -- 220
		return -- 221
	end -- 221
	draw:drawRing( -- 225
		Vec2(cx, cy), -- 225
		r * 0.52, -- 225
		r * 0.68, -- 225
		Color(0, 0, 0, 0), -- 225
		1.1, -- 225
		faint -- 225
	) -- 225
end -- 151
local function resolveRuntimeContract(injected) -- 272
	if injected ~= nil then -- 273
		return injected -- 274
	end -- 274
	local g = _G -- 276
	local ____temp_0 -- 277
	if g.package ~= nil then -- 277
		____temp_0 = g.package.loaded -- 277
	else -- 277
		____temp_0 = nil -- 277
	end -- 277
	local loaded = ____temp_0 -- 277
	if loaded == nil then -- 278
		return nil -- 279
	end -- 279
	local feHook = loaded["watch.fe"] -- 281
	if feHook ~= nil and type(feHook) == "table" then -- 282
		local c = feHook.contract -- 283
		if c ~= nil and type(c) == "table" then -- 284
			return c -- 285
		end -- 285
	end -- 285
	return nil -- 288
end -- 272
local function dispatchIntentFallback(p, intent) -- 291
	local rec = p -- 292
	local handler = rec.submitFeIntent -- 293
	if type(handler) == "function" then -- 294
		return handler(p, intent) ~= false -- 295
	end -- 295
	local tap = rec.reloadTapNode -- 297
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 298
		tap(p, intent.node) -- 299
		return true -- 300
	end -- 300
	return false -- 302
end -- 291
local function readOptionalNum(obj, key) -- 305
	if obj ~= nil and type(obj) == "table" then -- 306
		local v = obj[key] -- 307
		if type(v) == "number" then -- 308
			return v -- 309
		end -- 309
	end -- 309
	return nil -- 312
end -- 305
____exports.ReloadWheelPlugin = __TS__Class() -- 315
local ReloadWheelPlugin = ____exports.ReloadWheelPlugin -- 315
ReloadWheelPlugin.name = "ReloadWheelPlugin" -- 315
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 362
	self.id = "fe-02-reload-wheel" -- 316
	self.wasActive = false -- 320
	self.openAnimT = 0 -- 321
	self.openDuration = 0.24 -- 322
	self.retractAnimT = 0 -- 323
	self.retractDuration = 0.28 -- 324
	self.settledPath = {} -- 325
	self.settledEffect = "normal" -- 326
	self.settledTimedOut = false -- 327
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 328
	self.lastKnownNextEffect = "normal" -- 329
	self.kbCursor = ____exports.RELOAD_START_NODE -- 332
	self.dragging = false -- 333
	self.dragAdvanced = false -- 334
	self.pointerActive = false -- 335
	self.prevLeft = false -- 336
	self.prevRight = false -- 337
	self.localInvalidFlash = 0 -- 338
	self.animTime = 0 -- 339
	self.nodePulseSeq = 0 -- 340
	self.panelCx = 940 -- 343
	self.panelCy = 374 -- 344
	self.panelW = 286 -- 345
	self.panelH = 316 -- 346
	self.cellStep = 66 -- 347
	self.hitRadius = 25 -- 348
	self.resetBox = Rect(0, 0, 0, 0) -- 349
	self.lastUiPtrX = 0 -- 350
	self.lastUiPtrY = 0 -- 351
	self.answerTicksAccum = 0 -- 354
	self.worldTicksAccum = 0 -- 355
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 356
	self.appliedVfx = {} -- 359
	self.injectedContract = contract -- 363
end -- 362
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 367
	self.pendingSimInput = sim -- 368
end -- 367
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 371
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 372
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 373
end -- 371
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 379
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 380
end -- 379
function ReloadWheelPlugin.prototype.getState(self) -- 388
	return { -- 389
		active = self.wasActive, -- 390
		kbCursor = self.kbCursor, -- 391
		dragging = self.dragging, -- 392
		path = __TS__ArraySlice(self.lastKnownPath), -- 393
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 394
		nextEffect = self.lastKnownNextEffect, -- 395
		retracting = self.retractAnimT > 0, -- 396
		invalidFlash = self.localInvalidFlash, -- 397
		clock = self:getClockReadings(), -- 398
		panelCenterX = self.panelCx, -- 399
		panelCenterY = self.panelCy, -- 400
		cellStep = self.cellStep -- 401
	} -- 401
end -- 388
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 405
	self.wasActive = false -- 406
	self.openAnimT = 0 -- 407
	self.retractAnimT = 0 -- 408
	self.settledPath = {} -- 409
	self.settledEffect = "normal" -- 410
	self.settledTimedOut = false -- 411
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 412
	self.lastKnownNextEffect = "normal" -- 413
	self.kbCursor = ____exports.RELOAD_START_NODE -- 414
	self.dragging = false -- 415
	self.pointerActive = false -- 416
	self.localInvalidFlash = 0 -- 417
	self.animTime = 0 -- 418
	self.answerTicksAccum = 0 -- 419
	self.worldTicksAccum = 0 -- 420
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 421
	self.appliedVfx = {} -- 422
	self.pendingSimInput = nil -- 423
	self:resetInputEdges() -- 424
end -- 405
function ReloadWheelPlugin.prototype.resetInputEdges(self, _touchMode) -- 427
	if _touchMode == nil then -- 427
		_touchMode = false -- 427
	end -- 427
	self.prevLeft = false -- 428
	self.prevRight = false -- 429
end -- 427
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 432
	local contract = resolveRuntimeContract(self.injectedContract) -- 433
	if contract ~= nil then -- 434
		return contract:submitIntent(p, intent) -- 435
	end -- 435
	return dispatchIntentFallback(p, intent) -- 437
end -- 432
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 440
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 441
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 442
	local marginX = self.panelW * 0.5 + 34 -- 443
	local minCx = marginX + safe.left -- 444
	local maxCx = math.max(minCx, ctx.uiW - marginX - safe.right) -- 445
	if soldierUiX < ctx.uiW * 0.56 then -- 446
		self.panelCx = math.min( -- 447
			maxCx, -- 447
			math.max( -- 447
				minCx, -- 447
				math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 447
			) -- 447
		) -- 447
	else -- 447
		self.panelCx = math.max( -- 449
			minCx, -- 449
			math.min( -- 449
				maxCx, -- 449
				math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 449
			) -- 449
		) -- 449
	end -- 449
	local minCy = self.panelH * 0.5 + 78 + safe.bottom -- 451
	local maxCy = math.max(minCy, ctx.uiH - self.panelH * 0.5 - 66 - safe.top) -- 452
	self.panelCy = math.max( -- 453
		minCy, -- 453
		math.min(maxCy, ctx.uiH * 0.52) -- 453
	) -- 453
	self.resetBox = Rect(self.panelCx + 56, self.panelCy + self.panelH * 0.5 - 45, 72, 26) -- 454
end -- 440
function ReloadWheelPlugin.prototype.update(self, ctx) -- 457
	local rs = ctx.view.reloadSession -- 458
	local p = ctx.p -- 459
	self:computePanelPlacement(ctx) -- 462
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 465
		0.25, -- 465
		math.min(1, ctx.view.timeScale) -- 465
	) or 1) -- 465
	if ctx.paused then -- 468
		self:resetInputEdges(ctx.input:isTouchMode()) -- 469
		return -- 470
	end -- 470
	local udt = math.max(0, ctx.uiDt) -- 473
	local wdt = math.max(0, ctx.worldDt) -- 474
	self.animTime = self.animTime + udt -- 475
	if self.localInvalidFlash > 0 then -- 477
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 478
	end -- 478
	if rs.invalidFlash > self.localInvalidFlash then -- 480
		self.localInvalidFlash = rs.invalidFlash -- 481
	end -- 481
	self:ingestAppliedEffects(ctx) -- 485
	self:updateAppliedVfx(wdt) -- 486
	if rs.active and not self.wasActive then -- 489
		self:onSessionOpened(ctx) -- 490
	elseif not rs.active and self.wasActive then -- 491
		self:onSessionClosed(ctx) -- 492
	end -- 492
	self.wasActive = rs.active -- 494
	if not rs.active then -- 496
		self.lastKnownNextEffect = rs.nextEffect -- 497
		self.lastClock.active = false -- 498
		if self.retractAnimT > 0 then -- 499
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 500
		end -- 500
		self.pendingSimInput = nil -- 502
		return -- 503
	end -- 503
	self.openAnimT = math.min( -- 507
		1, -- 507
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 507
	) -- 507
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 510
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 511
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 512
		self.answerTicksAccum = liveAns -- 513
		self.worldTicksAccum = liveWorld -- 514
	else -- 514
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 516
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 517
	end -- 517
	self.lastClock = { -- 519
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 520
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 521
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 522
		active = true -- 523
	} -- 523
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 527
	self.lastKnownPath = activePath -- 528
	self.lastKnownNextEffect = rs.nextEffect -- 529
	self:processInputs(ctx, activePath) -- 532
end -- 457
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 535
	local rs = ctx.view.reloadSession -- 536
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 537
	self.openAnimT = 0 -- 538
	self.retractAnimT = 0 -- 539
	self.kbCursor = ____exports.RELOAD_START_NODE -- 540
	self.dragging = false -- 541
	self.pointerActive = false -- 542
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 543
	self.answerTicksAccum = 0 -- 544
	self.worldTicksAccum = 0 -- 545
	self:resetInputEdges(ctx.input:isTouchMode()) -- 546
	local hasBackendOpen = false -- 548
	local i = 0 -- 549
	do -- 549
		i = 0 -- 550
		while i < #ctx.events.rawEvents do -- 550
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 551
				hasBackendOpen = true -- 552
				break -- 553
			end -- 553
			i = i + 1 -- 550
		end -- 550
	end -- 550
	if not hasBackendOpen then -- 556
		ctx.audio:playOnce( -- 557
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 558
			"sfx", -- 559
			"assets/audio/combat/reload_open.wav", -- 560
			0.8, -- 561
			"reload:open", -- 562
			ctx.p.ticks -- 563
		) -- 563
	end -- 563
end -- 535
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 568
	local rs = ctx.view.reloadSession -- 569
	self.dragging = false -- 570
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 571
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 572
		local ____self_settledPath_1 = self.settledPath -- 574
		____self_settledPath_1[#____self_settledPath_1 + 1] = ____exports.RELOAD_TARGET_NODE -- 574
	end -- 574
	self.settledEffect = rs.nextEffect -- 576
	self.settledTimedOut = rs.nextEffect == "normal" -- 577
	self.retractAnimT = self.retractDuration -- 578
	local hasBackendClose = false -- 581
	local i = 0 -- 582
	do -- 582
		i = 0 -- 583
		while i < #ctx.events.rawEvents do -- 583
			local n = ctx.events.rawEvents[i + 1].name -- 584
			if n == "reloadSolved" or n == "reloadTimeout" then -- 585
				hasBackendClose = true -- 586
				break -- 587
			end -- 587
			i = i + 1 -- 583
		end -- 583
	end -- 583
	if self.settledTimedOut then -- 591
		if not hasBackendClose then -- 592
			ctx.audio:playOnce( -- 593
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 594
				"sfx", -- 595
				"assets/audio/combat/reload_timeout.wav", -- 596
				0.78, -- 597
				"reload:timeout", -- 598
				ctx.p.ticks -- 599
			) -- 599
		end -- 599
	else -- 599
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 603
		ctx.audio:playOnce( -- 608
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 609
			"sfx", -- 610
			effectWav, -- 611
			0.88, -- 612
			"reload:solved:" .. self.settledEffect, -- 613
			ctx.p.ticks -- 614
		) -- 614
	end -- 614
end -- 568
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 619
	local sim = self.pendingSimInput -- 620
	self.pendingSimInput = nil -- 621
	local touchMode = ctx.input:isTouchMode() -- 623
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 624
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 626
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 629
	local ____temp_11 -- 632
	if (sim and sim.pointerX) ~= nil then -- 632
		____temp_11 = true -- 633
	else -- 633
		local ____useUiPtr_10 -- 634
		if useUiPtr then -- 634
			____useUiPtr_10 = ctx.input.uiInside -- 634
		else -- 634
			____useUiPtr_10 = ctx.input.inside -- 634
		end -- 634
		____temp_11 = ____useUiPtr_10 -- 634
	end -- 634
	local inside = ____temp_11 -- 632
	local ____temp_14 -- 635
	if (sim and sim.leftHeld) ~= nil then -- 635
		____temp_14 = sim.leftHeld -- 636
	else -- 636
		____temp_14 = ctx.input.uiHeld or ctx.input.fire.held -- 637
	end -- 637
	local leftHeld = ____temp_14 -- 635
	local ____temp_17 -- 638
	if (sim and sim.rightHeld) ~= nil then -- 638
		____temp_17 = sim.rightHeld -- 639
	else -- 639
		____temp_17 = ctx.input.uiRightPressed -- 640
	end -- 640
	local rightHeld = ____temp_17 -- 638
	local ____temp_20 -- 642
	if (sim and sim.leftHeld) ~= nil then -- 642
		____temp_20 = leftHeld and not self.prevLeft -- 643
	else -- 643
		____temp_20 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 644
	end -- 644
	local leftPressed = ____temp_20 -- 642
	local ____temp_23 -- 645
	if (sim and sim.leftHeld) ~= nil then -- 645
		____temp_23 = not leftHeld and self.prevLeft -- 646
	else -- 646
		____temp_23 = ctx.input.uiReleased or not leftHeld and self.prevLeft -- 647
	end -- 647
	local leftReleased = ____temp_23 -- 645
	local ____temp_26 -- 648
	if (sim and sim.rightHeld) ~= nil then -- 648
		____temp_26 = rightHeld and not self.prevRight -- 649
	else -- 649
		____temp_26 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 650
	end -- 650
	local rightPressed = ____temp_26 -- 648
	self.prevLeft = leftHeld -- 651
	self.prevRight = rightHeld -- 652
	self.lastUiPtrX = ptrX -- 653
	self.lastUiPtrY = ptrY -- 654
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 656
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 657
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 658
	if pointerMoved or leftPressed then -- 660
		self.pointerActive = true -- 661
	end -- 661
	local lastNode = activePath[#activePath] -- 664
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 665
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 666
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 667
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 670
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 671
		self.dragging = false -- 672
		self.dragAdvanced = false -- 673
		self:triggerInvalidReset(ctx, activePath, false) -- 674
		return -- 675
	end -- 675
	if leftPressed then -- 679
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 680
			self.dragging = true -- 681
			self.dragAdvanced = false -- 682
			self.kbCursor = lastNode -- 683
		elseif hitNode >= 0 then -- 684
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 685
				self.dragging = true -- 686
				self.dragAdvanced = false -- 687
				self:commitNodeStep(ctx, hitNode, activePath) -- 688
			else -- 688
				self.dragging = false -- 690
				self.dragAdvanced = false -- 691
				self:triggerInvalidReset(ctx, activePath, true) -- 692
			end -- 692
			return -- 694
		end -- 694
	elseif self.dragging and leftHeld then -- 696
		if hitNode >= 0 and hitNode ~= lastNode then -- 697
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 698
				self.dragAdvanced = true -- 699
				self:commitNodeStep(ctx, hitNode, activePath) -- 700
			else -- 700
				self.dragging = false -- 703
				self.dragAdvanced = false -- 704
				self:triggerInvalidReset(ctx, activePath, true) -- 705
			end -- 705
			return -- 707
		end -- 707
	elseif leftReleased and self.dragging then -- 709
		local wasDragStroke = self.dragAdvanced -- 710
		self.dragging = false -- 711
		self.dragAdvanced = false -- 712
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 714
			self:triggerInvalidReset(ctx, activePath, true) -- 715
			return -- 716
		end -- 716
	end -- 716
	local dCol = 0 -- 721
	local dRow = 0 -- 722
	local confirmPressed = false -- 723
	local resetPressed = false -- 724
	local gpAutoCommit = false -- 725
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 727
		dCol = sim.moveCol or 0 -- 728
		dRow = sim.moveRow or 0 -- 729
		confirmPressed = sim.confirm == true -- 730
		resetPressed = sim.reset == true -- 731
	else -- 731
		if ctx.input.reloadReset then -- 733
			resetPressed = true -- 734
		end -- 734
		if ctx.input.reloadConfirm then -- 736
			confirmPressed = true -- 737
		end -- 737
		if ctx.input.reloadStepEdge then -- 739
			dCol = ctx.input.reloadDirCol -- 740
			dRow = ctx.input.reloadDirRow -- 741
			gpAutoCommit = ctx.input.reloadAutoStep -- 742
		end -- 742
	end -- 742
	if resetPressed and #activePath > 1 then -- 746
		self:triggerInvalidReset(ctx, activePath, false) -- 747
		return -- 748
	end -- 748
	if dCol ~= 0 or dRow ~= 0 then -- 751
		self.pointerActive = false -- 752
		local baseIdx = gpAutoCommit and lastNode or self.kbCursor -- 753
		local cur = ____exports.RELOAD_GRID[baseIdx + 1] or ____exports.RELOAD_GRID[1] -- 754
		local nextCol = math.max( -- 755
			0, -- 755
			math.min(2, cur.col + dCol) -- 755
		) -- 755
		local nextRow = math.max( -- 756
			0, -- 756
			math.min(2, cur.row + dRow) -- 756
		) -- 756
		local nextIdx = nextRow * 3 + nextCol -- 757
		self.kbCursor = nextIdx -- 758
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 759
			self:commitNodeStep(ctx, nextIdx, activePath) -- 760
			return -- 761
		end -- 761
	end -- 761
	if confirmPressed then -- 765
		self.pointerActive = false -- 766
		if self.kbCursor == lastNode then -- 767
			return -- 768
		end -- 768
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 770
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 771
		else -- 771
			self:triggerInvalidReset(ctx, activePath, true) -- 773
		end -- 773
	end -- 773
end -- 619
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 778
	self.kbCursor = node -- 779
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 780
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 781
	if node == ____exports.RELOAD_TARGET_NODE then -- 782
		self.dragging = false -- 783
		return -- 784
	end -- 784
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 787
	local stepIdx = math.max( -- 788
		1, -- 788
		math.min(6, #self.lastKnownPath) -- 788
	) -- 788
	local pitched = ("assets/audio/combat/reload_node_" .. tostring(stepIdx)) .. ".wav" -- 789
	local nodePath = Content:exist(pitched) and pitched or "assets/audio/combat/reload_node.wav" -- 790
	ctx.audio:playOnce( -- 791
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 792
		"sfx", -- 793
		nodePath, -- 794
		0.78, -- 795
		"reload:node:" .. tostring(node), -- 796
		ctx.p.ticks -- 797
	) -- 797
end -- 778
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 801
	if flashError then -- 802
		self.localInvalidFlash = 0.36 -- 803
	end -- 803
	self.kbCursor = ____exports.RELOAD_START_NODE -- 805
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 806
	if #activePath > 1 then -- 808
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 809
	end -- 809
	if flashError then -- 811
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 812
		ctx.audio:playOnce( -- 813
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 814
			"sfx", -- 815
			"assets/audio/combat/reload_invalid.wav", -- 816
			0.72, -- 817
			"reload:invalid", -- 818
			ctx.p.ticks -- 819
		) -- 819
	end -- 819
end -- 801
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 824
	if hitR == nil then -- 824
		hitR = self.hitRadius -- 824
	end -- 824
	local r2 = hitR * hitR -- 825
	local i = 0 -- 826
	do -- 826
		i = 0 -- 827
		while i < #____exports.RELOAD_GRID do -- 827
			local pos = self:getNodeUiPos(i) -- 828
			local dx = uiX - pos.x -- 829
			local dy = uiY - pos.y -- 830
			if dx * dx + dy * dy <= r2 then -- 831
				return i -- 832
			end -- 832
			i = i + 1 -- 827
		end -- 827
	end -- 827
	return -1 -- 835
end -- 824
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 838
	local p = ctx.p -- 839
	local triggered = false -- 840
	local i = 0 -- 841
	do -- 841
		i = 0 -- 842
		while i < #ctx.events.rawEvents do -- 842
			local e = ctx.events.rawEvents[i + 1] -- 843
			if e.name == "reloadApplied" then -- 844
				local rawEff = e.data.effect -- 845
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 846
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 849
				self:spawnAppliedVfx(eff, p, ex) -- 850
				triggered = true -- 851
			end -- 851
			i = i + 1 -- 842
		end -- 842
	end -- 842
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 855
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 856
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 857
	end -- 857
end -- 838
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 861
	local originX = p.player.x + p.player.facing * 18 -- 862
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 863
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 864
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 865
	local ____self_appliedVfx_29 = self.appliedVfx -- 866
	____self_appliedVfx_29[#____self_appliedVfx_29 + 1] = { -- 866
		effect = effect, -- 867
		originX = originX, -- 868
		originY = originY, -- 869
		targetX = targetX, -- 870
		targetY = targetY, -- 871
		facing = p.player.facing >= 0 and 1 or -1, -- 872
		life = maxLife, -- 873
		maxLife = maxLife -- 874
	} -- 874
end -- 861
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 878
	if wdt <= 0 or #self.appliedVfx == 0 then -- 879
		return -- 880
	end -- 880
	local w = 0 -- 882
	local i = 0 -- 883
	do -- 883
		i = 0 -- 884
		while i < #self.appliedVfx do -- 884
			local fx = self.appliedVfx[i + 1] -- 885
			fx.life = fx.life - wdt -- 886
			if fx.life > 0 then -- 887
				self.appliedVfx[w + 1] = fx -- 888
				w = w + 1 -- 889
			end -- 889
			i = i + 1 -- 884
		end -- 884
	end -- 884
	__TS__ArraySetLength(self.appliedVfx, w) -- 892
end -- 878
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 896
	if #self.appliedVfx == 0 then -- 902
		return -- 903
	end -- 903
	local cam = ctx.cam -- 905
	local depthEnabled = ctx.p.room.depth ~= nil -- 906
	local vfxSmokeLayer = depthEnabled and 5090 or 8 -- 907
	local vfxFlareLayer = depthEnabled and 5100 or 9 -- 908
	local i = 0 -- 909
	do -- 909
		i = 0 -- 910
		while i < #self.appliedVfx do -- 910
			local fx = self.appliedVfx[i + 1] -- 911
			local k = math.max( -- 912
				0, -- 912
				math.min(1, fx.life / fx.maxLife) -- 912
			) -- 912
			local prog = 1 - k -- 913
			local ox = cam:sx(fx.originX) -- 914
			local oy = cam:sy(fx.originY) -- 915
			local tx = cam:sx(fx.targetX) -- 916
			local ty = cam:sy(fx.targetY) -- 917
			if fx.effect == "knockback" then -- 919
				local r = cam:len(12 + prog * 34) -- 921
				local startA = fx.facing >= 0 and -48 or 132 -- 922
				local endA = fx.facing >= 0 and 48 or 228 -- 923
				fgGlow:drawArc( -- 924
					Vec2(tx, ty), -- 924
					r, -- 924
					startA, -- 924
					endA, -- 924
					2.4 * k, -- 924
					toColor(PALETTE.moonPale, 210 * k) -- 924
				) -- 924
				fgDraw:drawArc( -- 925
					Vec2( -- 925
						tx - fx.facing * cam:len(6), -- 925
						ty -- 925
					), -- 925
					r * 0.72, -- 925
					startA, -- 925
					endA, -- 925
					1.5 * k, -- 925
					toColor(PALETTE.silkLine, 165 * k) -- 925
				) -- 925
				local smokeSz = cam:len(22 + prog * 18) -- 926
				worldArt:tryPlace( -- 927
					"fe_vfx_smoke", -- 927
					"rw_kb_smoke_" .. tostring(i), -- 927
					tx - fx.facing * cam:len(4 + prog * 10), -- 927
					ty, -- 927
					smokeSz, -- 927
					smokeSz, -- 927
					{ -- 927
						frame = math.min( -- 928
							3, -- 928
							math.floor(prog * 4) -- 928
						), -- 928
						opacity = 0.78 * k, -- 929
						layer = vfxSmokeLayer -- 930
					} -- 930
				) -- 930
			elseif fx.effect == "echo" then -- 932
				local r1 = cam:len(10 + prog * 64) -- 934
				local r2 = cam:len(6 + prog * 40) -- 935
				if not worldArt:tryPlace( -- 936
					"ink_enso_fine", -- 936
					"rw_echo_ring_" .. tostring(i), -- 936
					tx, -- 936
					ty, -- 936
					r1 * 2.2, -- 936
					r1 * 2.2, -- 936
					{ -- 936
						color = toColor(PALETTE.amber), -- 937
						opacity = 0.85 * k, -- 938
						angle = prog * 28, -- 939
						layer = vfxSmokeLayer -- 940
					} -- 940
				) then -- 940
					fgGlow:drawRing( -- 942
						Vec2(tx, ty), -- 942
						math.max(1, r1 - 1.6), -- 942
						r1, -- 942
						Color(0, 0, 0, 0), -- 942
						1.3, -- 942
						toColor(PALETTE.amber, 210 * k) -- 942
					) -- 942
				end -- 942
				fgGlow:drawRing( -- 944
					Vec2(tx, ty), -- 944
					math.max(1, r2 - 1.2), -- 944
					r2, -- 944
					Color(0, 0, 0, 0), -- 944
					1, -- 944
					toColor(PALETTE.amberCore, 175 * k) -- 944
				) -- 944
			elseif fx.effect == "light" then -- 945
				fgGlow:drawSegment( -- 947
					Vec2(ox, oy), -- 947
					Vec2(tx, ty), -- 947
					5 * k, -- 947
					toColor(PALETTE.amber, 68 * k) -- 947
				) -- 947
				fgGlow:drawSegment( -- 948
					Vec2(ox, oy), -- 948
					Vec2(tx, ty), -- 948
					1.8 * k, -- 948
					toColor(PALETTE.amberCore, 185 * k) -- 948
				) -- 948
				local flashSz = cam:len(26 + prog * 10) -- 949
				worldArt:tryPlace( -- 950
					"fe_vfx_muzzle", -- 950
					"rw_light_flare_" .. tostring(i), -- 950
					ox, -- 950
					oy, -- 950
					flashSz, -- 950
					flashSz * 0.75, -- 950
					{ -- 950
						frame = math.min( -- 951
							2, -- 951
							math.floor(prog * 3) -- 951
						), -- 951
						facing = fx.facing, -- 952
						opacity = 0.9 * k, -- 953
						layer = vfxFlareLayer -- 954
					} -- 954
				) -- 954
				fillRadialGlow( -- 956
					fgGlow, -- 956
					tx, -- 956
					ty, -- 956
					cam:len(42 * (0.6 + prog * 0.4)), -- 956
					cam:len(34), -- 956
					toColor(PALETTE.amberCore, 118 * k), -- 956
					Color(244, 234, 214, 0), -- 956
					16 -- 956
				) -- 956
			end -- 956
			i = i + 1 -- 910
		end -- 910
	end -- 910
end -- 896
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 962
	local rs = ctx.view.reloadSession -- 969
	local active = rs.active -- 970
	local retracting = not active and self.retractAnimT > 0.01 -- 971
	if not active and not retracting then -- 972
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 974
			self:drawArmedEffectBadge( -- 975
				uiDraw, -- 975
				uiInkDraw, -- 975
				uiArt, -- 975
				ctx, -- 975
				rs.nextEffect -- 975
			) -- 975
		end -- 975
		return false -- 977
	end -- 977
	local cx = self.panelCx -- 980
	local cy = self.panelCy -- 981
	local pw = self.panelW -- 982
	local ph = self.panelH -- 983
	local x0 = cx - pw * 0.5 -- 984
	local y0 = cy - ph * 0.5 -- 985
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 987
		0, -- 989
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 989
	) -- 989
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 990
	local px = cx + shakeX -- 993
	if active then -- 996
		uiDraw:drawRect( -- 997
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 997
			Color( -- 997
				10, -- 997
				13, -- 997
				20, -- 997
				math.floor(54 * appear + 0.5) -- 997
			) -- 997
		) -- 997
	end -- 997
	drawSilkVeil( -- 1001
		uiDraw, -- 1001
		uiArt, -- 1001
		"rw_outer_veil", -- 1001
		px, -- 1001
		cy, -- 1001
		pw + 34, -- 1001
		ph + 28, -- 1001
		PALETTE.inkWash, -- 1001
		0.72 * appear, -- 1001
		-2 -- 1001
	) -- 1001
	if not uiArt:tryPlace( -- 1002
		"ink_song_paper", -- 1002
		"rw_paper", -- 1002
		px, -- 1002
		cy, -- 1002
		pw, -- 1002
		ph, -- 1002
		{opacity = 0.94 * appear, layer = 1} -- 1002
	) then -- 1002
		uiDraw:drawRoundedRect( -- 1003
			Rect(x0 + shakeX, y0, pw, ph), -- 1004
			6, -- 1005
			toColor(PALETTE.xuanPaper, 240 * appear), -- 1006
			1.2, -- 1007
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 1008
		) -- 1008
	end -- 1008
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 1011
	drawFiligreeCorners( -- 1012
		uiInkDraw, -- 1012
		uiArt, -- 1012
		"rw_frame", -- 1012
		x0 + shakeX + 8, -- 1012
		y0 + 8, -- 1012
		pw - 16, -- 1012
		ph - 16, -- 1012
		frameCol, -- 1012
		0.72 * appear, -- 1012
		22, -- 1012
		true, -- 1012
		2 -- 1012
	) -- 1012
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1015
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1018
	local effAccent = self:effectInkColor(previewEffect) -- 1021
	local headY = y0 + ph - 32 -- 1023
	____exports.drawReloadPatternGlyph( -- 1024
		uiInkDraw, -- 1024
		px - 52, -- 1024
		headY, -- 1024
		11, -- 1024
		previewEffect, -- 1024
		effAccent, -- 1024
		appear -- 1024
	) -- 1024
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1025
	ctx.texts:put( -- 1028
		"sm", -- 1029
		titleText, -- 1030
		px - 32, -- 1031
		headY, -- 1032
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1033
		0, -- 1034
		0.5, -- 1035
		"Left", -- 1036
		1.6, -- 1037
		0.96 * appear, -- 1038
		0 -- 1039
	) -- 1039
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1041
		local canReset = #activePath > 1 -- 1042
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1043
		uiInkDraw:drawRect( -- 1044
			rb, -- 1045
			Color( -- 1046
				32, -- 1046
				30, -- 1046
				32, -- 1046
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1046
			), -- 1046
			0.85, -- 1047
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1048
		) -- 1048
		ctx.texts:put( -- 1050
			"xs", -- 1051
			"重画", -- 1052
			rb.x + rb.width * 0.5, -- 1053
			rb.y + rb.height * 0.5, -- 1054
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1055
			0.5, -- 1056
			0.5, -- 1057
			"Center", -- 1058
			1, -- 1059
			(canReset and 0.94 or 0.52) * appear, -- 1060
			0 -- 1061
		) -- 1061
	end -- 1061
	drawHairline( -- 1064
		uiInkDraw, -- 1064
		uiArt, -- 1064
		"rw_head_line", -- 1064
		px, -- 1064
		headY - 18, -- 1064
		pw - 42, -- 1064
		PALETTE.xuanInkSub, -- 1064
		0.45 * appear, -- 1064
		false, -- 1064
		2 -- 1064
	) -- 1064
	local idx = 0 -- 1067
	do -- 1067
		idx = 0 -- 1068
		while idx < 3 do -- 1068
			local hA = self:getNodeUiPos(idx * 3) -- 1069
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1070
			uiInkDraw:drawSegment( -- 1071
				Vec2(hA.x + shakeX, hA.y), -- 1071
				Vec2(hB.x + shakeX, hB.y), -- 1071
				0.75, -- 1071
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1071
			) -- 1071
			local vA = self:getNodeUiPos(idx) -- 1072
			local vB = self:getNodeUiPos(6 + idx) -- 1073
			uiInkDraw:drawSegment( -- 1074
				Vec2(vA.x + shakeX, vA.y), -- 1074
				Vec2(vB.x + shakeX, vB.y), -- 1074
				0.75, -- 1074
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1074
			) -- 1074
			idx = idx + 1 -- 1068
		end -- 1068
	end -- 1068
	if #activePath >= 2 then -- 1078
		self:drawPathStrokes( -- 1079
			uiInkDraw, -- 1079
			uiGlow, -- 1079
			activePath, -- 1079
			previewEffect, -- 1079
			effAccent, -- 1079
			shakeX, -- 1079
			appear -- 1079
		) -- 1079
	end -- 1079
	if active and self.dragging and #activePath >= 1 then -- 1083
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1084
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1085
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1086
		uiInkDraw:drawSegment( -- 1087
			Vec2(tail.x + shakeX, tail.y), -- 1087
			Vec2(mx, my), -- 1087
			1.4, -- 1087
			toColor(effAccent, 150 * appear) -- 1087
		) -- 1087
		uiInkDraw:drawDot( -- 1088
			Vec2(mx, my), -- 1088
			3, -- 1088
			toColor(effAccent, 210 * appear) -- 1088
		) -- 1088
	end -- 1088
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1092
	do -- 1092
		idx = 0 -- 1093
		while idx < #____exports.RELOAD_GRID do -- 1093
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1094
			local pos = self:getNodeUiPos(idx) -- 1095
			local nx = pos.x + shakeX -- 1096
			local ny = pos.y -- 1097
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1098
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1099
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1100
			self:drawGridNode( -- 1101
				uiInkDraw, -- 1101
				uiArt, -- 1101
				uiGlow, -- 1101
				spec, -- 1101
				nx, -- 1101
				ny, -- 1101
				inPath, -- 1101
				isValidNext, -- 1101
				isKbFocus, -- 1101
				effAccent, -- 1101
				appear -- 1101
			) -- 1101
			idx = idx + 1 -- 1093
		end -- 1093
	end -- 1093
	self:drawChildFinger( -- 1105
		uiInkDraw, -- 1105
		uiArt, -- 1105
		uiGlow, -- 1105
		active, -- 1105
		activePath, -- 1105
		shakeX, -- 1105
		appear -- 1105
	) -- 1105
	local barW = pw - 52 -- 1108
	local barX = px - barW * 0.5 -- 1109
	local barY = y0 + 28 -- 1110
	local remainFrac = active and math.max( -- 1111
		0, -- 1112
		math.min( -- 1112
			1, -- 1112
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1112
		) -- 1112
	) or (self.settledTimedOut and 0 or 1) -- 1113
	local urgent = active and remainFrac < 0.25 -- 1114
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1115
	uiInkDraw:drawSegment( -- 1116
		Vec2(barX, barY), -- 1116
		Vec2(barX + barW, barY), -- 1116
		1.4, -- 1116
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1116
	) -- 1116
	if remainFrac > 0.005 then -- 1117
		uiInkDraw:drawSegment( -- 1118
			Vec2(barX, barY), -- 1118
			Vec2(barX + barW * remainFrac, barY), -- 1118
			3, -- 1118
			toColor(barCol, 225 * appear) -- 1118
		) -- 1118
	end -- 1118
	local tTick = 1 -- 1121
	do -- 1121
		tTick = 1 -- 1122
		while tTick <= 3 do -- 1122
			local tx = barX + barW * (tTick / 4) -- 1123
			uiInkDraw:drawSegment( -- 1124
				Vec2(tx, barY - 3.5), -- 1124
				Vec2(tx, barY + 3.5), -- 1124
				0.9, -- 1124
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1124
			) -- 1124
			tTick = tTick + 1 -- 1122
		end -- 1122
	end -- 1122
	if active and ctx.view.assistHintsEnabled then -- 1128
		local mode = ctx.input.inputMode -- 1129
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. getActiveTarget():keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1130
		ctx.texts:put( -- 1135
			"xs", -- 1136
			hint, -- 1137
			px, -- 1138
			y0 + 13, -- 1139
			toColor(PALETTE.xuanInkSub), -- 1140
			0.5, -- 1141
			0.5, -- 1142
			"Center", -- 1143
			0.6, -- 1144
			0.82 * appear, -- 1145
			0 -- 1146
		) -- 1146
	end -- 1146
	return active -- 1150
end -- 962
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1153
	if effect == "echo" then -- 1154
		return PALETTE.rouge -- 1155
	end -- 1155
	if effect == "light" then -- 1157
		return PALETTE.amberDim -- 1158
	end -- 1158
	if effect == "knockback" then -- 1160
		return PALETTE.xuanInk -- 1161
	end -- 1161
	return PALETTE.xuanInkSub -- 1163
end -- 1153
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1166
	local i = 0 -- 1175
	do -- 1175
		i = 0 -- 1176
		while i < #path - 1 do -- 1176
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1177
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1178
			local ax = p0.x + shakeX -- 1179
			local ay = p0.y -- 1180
			local bx = p1.x + shakeX -- 1181
			local by = p1.y -- 1182
			if effect == "echo" then -- 1184
				local dx = bx - ax -- 1186
				local dy = by - ay -- 1187
				local len = math.max( -- 1188
					1, -- 1188
					math.sqrt(dx * dx + dy * dy) -- 1188
				) -- 1188
				local nx = -dy / len * 2.2 -- 1189
				local ny = dx / len * 2.2 -- 1190
				uiInkDraw:drawSegment( -- 1191
					Vec2(ax + nx, ay + ny), -- 1191
					Vec2(bx + nx, by + ny), -- 1191
					1.35, -- 1191
					toColor(col, 220 * appear) -- 1191
				) -- 1191
				uiInkDraw:drawSegment( -- 1192
					Vec2(ax - nx, ay - ny), -- 1192
					Vec2(bx - nx, by - ny), -- 1192
					1.35, -- 1192
					toColor(col, 220 * appear) -- 1192
				) -- 1192
			elseif effect == "light" then -- 1193
				uiInkDraw:drawSegment( -- 1195
					Vec2(ax, ay), -- 1195
					Vec2(bx, by), -- 1195
					3.1, -- 1195
					toColor(PALETTE.xuanInk, 195 * appear) -- 1195
				) -- 1195
				uiInkDraw:drawSegment( -- 1196
					Vec2(ax, ay), -- 1196
					Vec2(bx, by), -- 1196
					1.3, -- 1196
					toColor(PALETTE.amberCore, 235 * appear) -- 1196
				) -- 1196
				uiGlow:drawSegment( -- 1197
					Vec2(ax, ay), -- 1197
					Vec2(bx, by), -- 1197
					3.2, -- 1197
					toColor(PALETTE.amber, 55 * appear) -- 1197
				) -- 1197
			else -- 1197
				uiInkDraw:drawSegment( -- 1200
					Vec2(ax, ay), -- 1200
					Vec2(bx, by), -- 1200
					2.8, -- 1200
					toColor(col, 230 * appear) -- 1200
				) -- 1200
			end -- 1200
			i = i + 1 -- 1176
		end -- 1176
	end -- 1176
end -- 1166
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiArt, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1205
	local baseR = spec.kind == "plain" and 11 or 15 -- 1218
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1219
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1220
	if isKbFocus then -- 1223
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1224
		uiInkDraw:drawRing( -- 1225
			Vec2(nx, ny), -- 1225
			baseR + 4.5, -- 1225
			baseR + 6.2, -- 1225
			Color(0, 0, 0, 0), -- 1225
			1.1, -- 1225
			toColor(focusCol, 215 * appear) -- 1225
		) -- 1225
	end -- 1225
	if spec.kind == "bell" then -- 1228
		if inPath then -- 1230
			uiInkDraw:drawCircle( -- 1231
				Vec2(nx, ny), -- 1231
				baseR + 1, -- 1231
				toColor(PALETTE.rouge, 36 * appear) -- 1231
			) -- 1231
			uiGlow:drawRing( -- 1232
				Vec2(nx, ny), -- 1232
				baseR + 2, -- 1232
				baseR + 5, -- 1232
				Color(0, 0, 0, 0), -- 1232
				1.2, -- 1232
				toColor(PALETTE.rouge, 110 * appear) -- 1232
			) -- 1232
		end -- 1232
		uiInkDraw:drawRing( -- 1234
			Vec2(nx, ny), -- 1234
			baseR - 1.2, -- 1234
			baseR, -- 1234
			Color(0, 0, 0, 0), -- 1234
			1.1, -- 1234
			toColor(strokeCol, strokeAlpha * appear) -- 1234
		) -- 1234
		____exports.drawReloadPatternGlyph( -- 1235
			uiInkDraw, -- 1235
			nx, -- 1235
			ny, -- 1235
			9.5, -- 1235
			"echo", -- 1235
			inPath and PALETTE.rouge or strokeCol, -- 1235
			appear, -- 1235
			uiArt, -- 1235
			"rw_glyph_bell", -- 1235
			4 -- 1235
		) -- 1235
		return -- 1236
	end -- 1236
	if spec.kind == "lamp" then -- 1239
		if inPath then -- 1241
			uiInkDraw:drawCircle( -- 1242
				Vec2(nx, ny), -- 1242
				baseR + 1, -- 1242
				toColor(PALETTE.amber, 56 * appear) -- 1242
			) -- 1242
			fillRadialGlow( -- 1243
				uiGlow, -- 1243
				nx, -- 1243
				ny, -- 1243
				22, -- 1243
				22, -- 1243
				toColor(PALETTE.amberCore, 72 * appear), -- 1243
				Color(244, 234, 214, 0), -- 1243
				12 -- 1243
			) -- 1243
		end -- 1243
		uiInkDraw:drawRing( -- 1245
			Vec2(nx, ny), -- 1245
			baseR - 1.2, -- 1245
			baseR, -- 1245
			Color(0, 0, 0, 0), -- 1245
			1.1, -- 1245
			toColor(strokeCol, strokeAlpha * appear) -- 1245
		) -- 1245
		____exports.drawReloadPatternGlyph( -- 1246
			uiInkDraw, -- 1246
			nx, -- 1246
			ny, -- 1246
			9.5, -- 1246
			"light", -- 1246
			inPath and PALETTE.xuanInk or strokeCol, -- 1246
			appear, -- 1246
			uiArt, -- 1246
			"rw_glyph_lamp", -- 1246
			4 -- 1246
		) -- 1246
		return -- 1247
	end -- 1247
	if spec.kind == "target" then -- 1250
		drawDiamond( -- 1252
			uiInkDraw, -- 1253
			nx, -- 1254
			ny, -- 1255
			baseR, -- 1256
			baseR, -- 1257
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1258
			1.4, -- 1259
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1260
		) -- 1260
		drawDiamond( -- 1262
			uiInkDraw, -- 1263
			nx, -- 1264
			ny, -- 1265
			baseR * 0.56, -- 1266
			baseR * 0.56, -- 1267
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1268
		) -- 1268
		return -- 1270
	end -- 1270
	if spec.kind == "start" then -- 1273
		uiInkDraw:drawRing( -- 1275
			Vec2(nx, ny), -- 1275
			baseR - 2.2, -- 1275
			baseR, -- 1275
			Color(0, 0, 0, 0), -- 1275
			1.2, -- 1275
			toColor(PALETTE.rouge, 220 * appear) -- 1275
		) -- 1275
		uiInkDraw:drawCircle( -- 1276
			Vec2(nx, ny), -- 1276
			4.8, -- 1276
			toColor(PALETTE.xuanInk, 235 * appear) -- 1276
		) -- 1276
		return -- 1277
	end -- 1277
	if inPath then -- 1281
		uiInkDraw:drawCircle( -- 1282
			Vec2(nx, ny), -- 1282
			6.2, -- 1282
			toColor(effAccent, 235 * appear) -- 1282
		) -- 1282
		uiInkDraw:drawRing( -- 1283
			Vec2(nx, ny), -- 1283
			9.5, -- 1283
			10.8, -- 1283
			Color(0, 0, 0, 0), -- 1283
			1, -- 1283
			toColor(effAccent, 165 * appear) -- 1283
		) -- 1283
	else -- 1283
		uiInkDraw:drawRing( -- 1285
			Vec2(nx, ny), -- 1285
			5.6, -- 1285
			7, -- 1285
			Color(0, 0, 0, 0), -- 1285
			1, -- 1285
			toColor(strokeCol, strokeAlpha * appear) -- 1285
		) -- 1285
	end -- 1285
end -- 1205
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiArt, uiGlow, active, path, shakeX, appear) -- 1290
	local fx = 0 -- 1299
	local fy = 0 -- 1300
	if active then -- 1302
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1303
		local pos = self:getNodeUiPos(tipNode) -- 1304
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1305
		fx = pos.x + shakeX + 4 + tapPulse * 0.35 -- 1306
		fy = pos.y - 4 - tapPulse -- 1307
		if #path <= 1 then -- 1308
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1310
			uiInkDraw:drawRing( -- 1311
				Vec2(pos.x + shakeX, pos.y), -- 1311
				ringR - 1, -- 1311
				ringR, -- 1311
				Color(0, 0, 0, 0), -- 1311
				1, -- 1311
				toColor(PALETTE.rouge, 130 * appear) -- 1311
			) -- 1311
		end -- 1311
	elseif self.retractAnimT > 0 and #path > 0 then -- 1313
		local prog = math.max( -- 1315
			0, -- 1315
			math.min( -- 1315
				1, -- 1315
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1315
			) -- 1315
		) -- 1315
		local revFloat = (1 - prog) * (#path - 1) -- 1316
		local idxA = math.max( -- 1317
			0, -- 1317
			math.min( -- 1317
				#path - 1, -- 1317
				math.floor(revFloat) -- 1317
			) -- 1317
		) -- 1317
		local idxB = math.max( -- 1318
			0, -- 1318
			math.min(#path - 1, idxA + 1) -- 1318
		) -- 1318
		local frac = revFloat - idxA -- 1319
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1320
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1321
		fx = pA.x + (pB.x - pA.x) * frac + shakeX + prog * 28 -- 1322
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1323
	else -- 1323
		return -- 1325
	end -- 1325
	uiGlow:drawDot( -- 1328
		Vec2(fx, fy), -- 1328
		3.6, -- 1328
		toColor(PALETTE.amberCore, 88 * appear) -- 1328
	) -- 1328
	if uiArt:tryPlacePath( -- 1329
		"assets/art/vfx_craft_art.clip|reload_child_finger", -- 1329
		"rw_child_finger", -- 1329
		fx, -- 1329
		fy, -- 1329
		64, -- 1329
		56, -- 1329
		{ -- 1329
			anchorX = 0.04, -- 1330
			anchorY = 0.96, -- 1331
			preserveAspect = true, -- 1332
			smooth = true, -- 1333
			opacity = 0.96 * appear, -- 1334
			layer = 6 -- 1335
		} -- 1335
	) then -- 1335
		return -- 1337
	end -- 1337
	local a255 = math.floor(240 * appear + 0.5) -- 1341
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1342
	uiInkDraw:drawPolygon( -- 1343
		{ -- 1343
			Vec2(fx - 30, fy - 20), -- 1344
			Vec2(fx - 22, fy - 28), -- 1345
			Vec2(fx - 11, fy - 14), -- 1346
			Vec2(fx - 17, fy - 9) -- 1347
		}, -- 1347
		Color(164, 78, 54, a255), -- 1348
		1, -- 1348
		inkCol -- 1348
	) -- 1348
	uiInkDraw:drawSegment( -- 1349
		Vec2(fx - 16, fy - 10), -- 1349
		Vec2(fx - 11, fy - 15), -- 1349
		2, -- 1349
		Color(204, 174, 122, a255) -- 1349
	) -- 1349
	uiInkDraw:drawCircle( -- 1350
		Vec2(fx - 9, fy - 8), -- 1350
		4.8, -- 1350
		Color(238, 212, 182, a255) -- 1350
	) -- 1350
	uiInkDraw:drawSegment( -- 1351
		Vec2(fx - 7, fy - 6), -- 1351
		Vec2(fx, fy), -- 1351
		2.5, -- 1351
		Color(244, 222, 196, a255) -- 1351
	) -- 1351
	uiInkDraw:drawRing( -- 1352
		Vec2(fx, fy), -- 1352
		2, -- 1352
		3, -- 1352
		Color(0, 0, 0, 0), -- 1352
		0.9, -- 1352
		inkCol -- 1352
	) -- 1352
end -- 1290
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1356
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1363
	local bx = 46 + safe.left -- 1364
	local by = ctx.uiH - 134 - safe.top -- 1365
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1366
	drawSilkVeil( -- 1367
		uiDraw, -- 1367
		uiArt, -- 1367
		"rw_armed_veil", -- 1367
		bx + 54, -- 1367
		by, -- 1367
		142, -- 1367
		30, -- 1367
		PALETTE.inkWash, -- 1367
		0.72, -- 1367
		-1 -- 1367
	) -- 1367
	____exports.drawReloadPatternGlyph( -- 1368
		uiInkDraw, -- 1368
		bx + 12, -- 1368
		by, -- 1368
		9, -- 1368
		effect, -- 1368
		col, -- 1368
		0.96, -- 1368
		uiArt, -- 1368
		"rw_armed_glyph", -- 1368
		4 -- 1368
	) -- 1368
	drawBlossomDot( -- 1369
		uiInkDraw, -- 1369
		uiArt, -- 1369
		"rw_armed_dot", -- 1369
		bx + 28, -- 1369
		by, -- 1369
		6, -- 1369
		col, -- 1369
		0.85, -- 1369
		3 -- 1369
	) -- 1369
	ctx.texts:put( -- 1370
		"xs", -- 1370
		____exports.reloadEffectShortLabel(effect), -- 1370
		bx + 38, -- 1370
		by, -- 1370
		toColor(PALETTE.textBright), -- 1370
		0, -- 1370
		0.5, -- 1370
		"Left", -- 1370
		1, -- 1370
		0.94, -- 1370
		0.08 -- 1370
	) -- 1370
end -- 1356
function ____exports.createReloadWheelPlugin(contract) -- 1374
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1375
end -- 1374
return ____exports -- 1374
