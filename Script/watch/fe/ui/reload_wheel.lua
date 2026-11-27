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
	if a == b then -- 72
		return false -- 74
	end -- 74
	local na = ____exports.RELOAD_GRID[a + 1] -- 76
	local nb = ____exports.RELOAD_GRID[b + 1] -- 77
	if na == nil or nb == nil then -- 77
		return false -- 79
	end -- 79
	return math.abs(na.col - nb.col) <= 1 and math.abs(na.row - nb.row) <= 1 -- 81
end -- 72
--- 完整路径合法性校验：起点 0、每步相邻、不重复、终点 8
function ____exports.validateReloadPath(path) -- 85
	if #path < 2 then -- 85
		return false -- 87
	end -- 87
	if path[1] ~= ____exports.RELOAD_START_NODE or path[#path] ~= ____exports.RELOAD_TARGET_NODE then -- 87
		return false -- 90
	end -- 90
	local seen = {} -- 92
	local i = 0 -- 93
	do -- 93
		i = 0 -- 94
		while i < #path do -- 94
			local n = path[i + 1] -- 95
			if n < 0 or n >= #____exports.RELOAD_GRID or seen[n] == true then -- 95
				return false -- 97
			end -- 97
			seen[n] = true -- 99
			if i > 0 and not ____exports.isAdjacentNode(path[i], n) then -- 99
				return false -- 101
			end -- 101
			i = i + 1 -- 94
		end -- 94
	end -- 94
	return true -- 104
end -- 85
--- 按路径经过纹样推导效果（铃纹 4 优先于灯纹 2，其余合法连接为推退 knockback）
function ____exports.deriveEffectFromGrid(path) -- 108
	if #path < 2 then -- 108
		return "normal" -- 110
	end -- 110
	local hasBell = false -- 112
	local hasLamp = false -- 113
	local i = 0 -- 114
	do -- 114
		i = 0 -- 115
		while i < #path do -- 115
			if path[i + 1] == 4 then -- 115
				hasBell = true -- 117
			elseif path[i + 1] == 2 then -- 117
				hasLamp = true -- 119
			end -- 119
			i = i + 1 -- 115
		end -- 115
	end -- 115
	if hasBell then -- 115
		return "echo" -- 123
	end -- 123
	if hasLamp then -- 123
		return "light" -- 126
	end -- 126
	return "knockback" -- 128
end -- 108
function ____exports.reloadEffectShortLabel(effect) -- 131
	if effect == "knockback" then -- 131
		return "推退" -- 133
	end -- 133
	if effect == "echo" then -- 133
		return "回声诱导" -- 136
	end -- 136
	if effect == "light" then -- 136
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
	if alpha == nil then -- 151
		alpha = 1 -- 158
	end -- 158
	if layer == nil then -- 158
		layer = 4 -- 161
	end -- 161
	local r = math.max(5, radius) -- 163
	if uiArt ~= nil and instanceKey ~= nil and effect ~= "normal" then -- 163
		local slot = effect == "echo" and "fe_glyph_bell" or (effect == "light" and "fe_glyph_lamp" or "fe_glyph_push") -- 165
		local sz = math.floor(r * 2.2 + 0.5) -- 168
		if uiArt:tryPlace( -- 168
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
	if effect == "echo" then -- 178
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
	if effect == "light" then -- 192
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
	if effect == "knockback" then -- 211
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
	if injected ~= nil then -- 272
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
	if loaded == nil then -- 277
		return nil -- 279
	end -- 279
	local feHook = loaded["watch.fe"] -- 281
	if feHook ~= nil and type(feHook) == "table" then -- 281
		local c = feHook.contract -- 283
		if c ~= nil and type(c) == "table" then -- 283
			return c -- 285
		end -- 285
	end -- 285
	return nil -- 288
end -- 272
local function dispatchIntentFallback(p, intent) -- 291
	local rec = p -- 292
	local handler = rec.submitFeIntent -- 293
	if type(handler) == "function" then -- 293
		return handler(p, intent) ~= false -- 295
	end -- 295
	local tap = rec.reloadTapNode -- 297
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 297
		tap(p, intent.node) -- 299
		return true -- 300
	end -- 300
	return false -- 302
end -- 291
local function readOptionalNum(obj, key) -- 305
	if obj ~= nil and type(obj) == "table" then -- 305
		local v = obj[key] -- 307
		if type(v) == "number" then -- 307
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
	if contract ~= nil then -- 433
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
	if soldierUiX < ctx.uiW * 0.56 then -- 445
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
	if ctx.paused then -- 465
		self:resetInputEdges(ctx.input:isTouchMode()) -- 469
		return -- 470
	end -- 470
	local udt = math.max(0, ctx.uiDt) -- 473
	local wdt = math.max(0, ctx.worldDt) -- 474
	self.animTime = self.animTime + udt -- 475
	if self.localInvalidFlash > 0 then -- 475
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 478
	end -- 478
	if rs.invalidFlash > self.localInvalidFlash then -- 478
		self.localInvalidFlash = rs.invalidFlash -- 481
	end -- 481
	self:ingestAppliedEffects(ctx) -- 485
	self:updateAppliedVfx(wdt) -- 486
	if rs.active and not self.wasActive then -- 486
		self:onSessionOpened(ctx) -- 490
	elseif not rs.active and self.wasActive then -- 490
		self:onSessionClosed(ctx) -- 492
	end -- 492
	self.wasActive = rs.active -- 494
	if not rs.active then -- 494
		self.lastKnownNextEffect = rs.nextEffect -- 497
		self.lastClock.active = false -- 498
		if self.retractAnimT > 0 then -- 498
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
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 511
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
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 550
				hasBackendOpen = true -- 552
				break -- 553
			end -- 553
			i = i + 1 -- 550
		end -- 550
	end -- 550
	if not hasBackendOpen then -- 550
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
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 571
		local ____self_settledPath_1 = self.settledPath -- 571
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
			if n == "reloadSolved" or n == "reloadTimeout" then -- 584
				hasBackendClose = true -- 586
				break -- 587
			end -- 587
			i = i + 1 -- 583
		end -- 583
	end -- 583
	if self.settledTimedOut then -- 583
		if not hasBackendClose then -- 583
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
	if pointerMoved or leftPressed then -- 658
		self.pointerActive = true -- 661
	end -- 661
	local lastNode = activePath[#activePath] -- 664
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 665
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 666
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 667
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 670
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 670
		self.dragging = false -- 672
		self.dragAdvanced = false -- 673
		self:triggerInvalidReset(ctx, activePath, false) -- 674
		return -- 675
	end -- 675
	if leftPressed then -- 675
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 675
			self.dragging = true -- 681
			self.dragAdvanced = false -- 682
			self.kbCursor = lastNode -- 683
		elseif hitNode >= 0 then -- 683
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 683
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
	elseif self.dragging and leftHeld then -- 694
		if hitNode >= 0 and hitNode ~= lastNode then -- 694
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 694
				self.dragAdvanced = true -- 699
				self:commitNodeStep(ctx, hitNode, activePath) -- 700
			else -- 700
				self.dragging = false -- 703
				self.dragAdvanced = false -- 704
				self:triggerInvalidReset(ctx, activePath, true) -- 705
			end -- 705
			return -- 707
		end -- 707
	elseif leftReleased and self.dragging then -- 707
		local wasDragStroke = self.dragAdvanced -- 710
		self.dragging = false -- 711
		self.dragAdvanced = false -- 712
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 712
			self:triggerInvalidReset(ctx, activePath, true) -- 715
			return -- 716
		end -- 716
	end -- 716
	local dCol = 0 -- 721
	local dRow = 0 -- 722
	local confirmPressed = false -- 723
	local resetPressed = false -- 724
	local gpAutoCommit = false -- 725
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 725
		dCol = sim.moveCol or 0 -- 728
		dRow = sim.moveRow or 0 -- 729
		confirmPressed = sim.confirm == true -- 730
		resetPressed = sim.reset == true -- 731
	else -- 731
		if ctx.input.reloadReset then -- 731
			resetPressed = true -- 734
		end -- 734
		if ctx.input.reloadConfirm then -- 734
			confirmPressed = true -- 737
		end -- 737
		if ctx.input.reloadStepEdge then -- 737
			dCol = ctx.input.reloadDirCol -- 740
			dRow = ctx.input.reloadDirRow -- 741
			gpAutoCommit = ctx.input.reloadAutoStep -- 742
		end -- 742
	end -- 742
	if resetPressed and #activePath > 1 then -- 742
		self:triggerInvalidReset(ctx, activePath, false) -- 747
		return -- 748
	end -- 748
	if dCol ~= 0 or dRow ~= 0 then -- 748
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
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 758
			self:commitNodeStep(ctx, nextIdx, activePath) -- 760
			return -- 761
		end -- 761
	end -- 761
	if confirmPressed then -- 761
		self.pointerActive = false -- 766
		if self.kbCursor == lastNode then -- 766
			return -- 768
		end -- 768
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 768
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
	if node == ____exports.RELOAD_TARGET_NODE then -- 781
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
	if flashError then -- 801
		self.localInvalidFlash = 0.36 -- 803
	end -- 803
	self.kbCursor = ____exports.RELOAD_START_NODE -- 805
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 806
	if #activePath > 1 then -- 806
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 809
	end -- 809
	if flashError then -- 809
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
			if dx * dx + dy * dy <= r2 then -- 830
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
			if e.name == "reloadApplied" then -- 843
				local rawEff = e.data.effect -- 845
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 846
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 849
				self:spawnAppliedVfx(eff, p, ex) -- 850
				triggered = true -- 851
			end -- 851
			i = i + 1 -- 842
		end -- 842
	end -- 842
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 842
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 856
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 857
	end -- 857
end -- 838
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 861
	local originX = p.player.x + p.player.facing * 18 -- 862
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 863
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 864
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 865
	local ____self_appliedVfx_29 = self.appliedVfx -- 865
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
	if wdt <= 0 or #self.appliedVfx == 0 then -- 878
		return -- 880
	end -- 880
	local w = 0 -- 882
	local i = 0 -- 883
	do -- 883
		i = 0 -- 884
		while i < #self.appliedVfx do -- 884
			local fx = self.appliedVfx[i + 1] -- 885
			fx.life = fx.life - wdt -- 886
			if fx.life > 0 then -- 886
				self.appliedVfx[w + 1] = fx -- 888
				w = w + 1 -- 889
			end -- 889
			i = i + 1 -- 884
		end -- 884
	end -- 884
	__TS__ArraySetLength(self.appliedVfx, w) -- 884
end -- 878
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 896
	if #self.appliedVfx == 0 then -- 896
		return -- 903
	end -- 903
	local cam = ctx.cam -- 905
	local i = 0 -- 906
	do -- 906
		i = 0 -- 907
		while i < #self.appliedVfx do -- 907
			local fx = self.appliedVfx[i + 1] -- 908
			local k = math.max( -- 909
				0, -- 909
				math.min(1, fx.life / fx.maxLife) -- 909
			) -- 909
			local prog = 1 - k -- 910
			local ox = cam:sx(fx.originX) -- 911
			local oy = cam:sy(fx.originY) -- 912
			local tx = cam:sx(fx.targetX) -- 913
			local ty = cam:sy(fx.targetY) -- 914
			if fx.effect == "knockback" then -- 914
				local r = cam:len(12 + prog * 34) -- 918
				local startA = fx.facing >= 0 and -48 or 132 -- 919
				local endA = fx.facing >= 0 and 48 or 228 -- 920
				fgGlow:drawArc( -- 921
					Vec2(tx, ty), -- 921
					r, -- 921
					startA, -- 921
					endA, -- 921
					2.4 * k, -- 921
					toColor(PALETTE.moonPale, 210 * k) -- 921
				) -- 921
				fgDraw:drawArc( -- 922
					Vec2( -- 922
						tx - fx.facing * cam:len(6), -- 922
						ty -- 922
					), -- 922
					r * 0.72, -- 922
					startA, -- 922
					endA, -- 922
					1.5 * k, -- 922
					toColor(PALETTE.silkLine, 165 * k) -- 922
				) -- 922
				local smokeSz = cam:len(22 + prog * 18) -- 923
				worldArt:tryPlace( -- 924
					"fe_vfx_smoke", -- 924
					"rw_kb_smoke_" .. tostring(i), -- 924
					tx - fx.facing * cam:len(4 + prog * 10), -- 924
					ty, -- 924
					smokeSz, -- 924
					smokeSz, -- 924
					{ -- 924
						frame = math.min( -- 925
							3, -- 925
							math.floor(prog * 4) -- 925
						), -- 925
						opacity = 0.78 * k, -- 926
						layer = 8 -- 927
					} -- 927
				) -- 927
			elseif fx.effect == "echo" then -- 927
				local r1 = cam:len(10 + prog * 64) -- 931
				local r2 = cam:len(6 + prog * 40) -- 932
				if not worldArt:tryPlace( -- 932
					"ink_enso_fine", -- 933
					"rw_echo_ring_" .. tostring(i), -- 933
					tx, -- 933
					ty, -- 933
					r1 * 2.2, -- 933
					r1 * 2.2, -- 933
					{ -- 933
						color = toColor(PALETTE.amber), -- 934
						opacity = 0.85 * k, -- 935
						angle = prog * 28, -- 936
						layer = 8 -- 937
					} -- 937
				) then -- 937
					fgGlow:drawRing( -- 939
						Vec2(tx, ty), -- 939
						math.max(1, r1 - 1.6), -- 939
						r1, -- 939
						Color(0, 0, 0, 0), -- 939
						1.3, -- 939
						toColor(PALETTE.amber, 210 * k) -- 939
					) -- 939
				end -- 939
				fgGlow:drawRing( -- 941
					Vec2(tx, ty), -- 941
					math.max(1, r2 - 1.2), -- 941
					r2, -- 941
					Color(0, 0, 0, 0), -- 941
					1, -- 941
					toColor(PALETTE.amberCore, 175 * k) -- 941
				) -- 941
			elseif fx.effect == "light" then -- 941
				fgGlow:drawSegment( -- 944
					Vec2(ox, oy), -- 944
					Vec2(tx, ty), -- 944
					5 * k, -- 944
					toColor(PALETTE.amber, 68 * k) -- 944
				) -- 944
				fgGlow:drawSegment( -- 945
					Vec2(ox, oy), -- 945
					Vec2(tx, ty), -- 945
					1.8 * k, -- 945
					toColor(PALETTE.amberCore, 185 * k) -- 945
				) -- 945
				local flashSz = cam:len(26 + prog * 10) -- 946
				worldArt:tryPlace( -- 947
					"fe_vfx_muzzle", -- 947
					"rw_light_flare_" .. tostring(i), -- 947
					ox, -- 947
					oy, -- 947
					flashSz, -- 947
					flashSz * 0.75, -- 947
					{ -- 947
						frame = math.min( -- 948
							2, -- 948
							math.floor(prog * 3) -- 948
						), -- 948
						facing = fx.facing, -- 949
						opacity = 0.9 * k, -- 950
						layer = 9 -- 951
					} -- 951
				) -- 951
				fillRadialGlow( -- 953
					fgGlow, -- 953
					tx, -- 953
					ty, -- 953
					cam:len(42 * (0.6 + prog * 0.4)), -- 953
					cam:len(34), -- 953
					toColor(PALETTE.amberCore, 118 * k), -- 953
					Color(244, 234, 214, 0), -- 953
					16 -- 953
				) -- 953
			end -- 953
			i = i + 1 -- 907
		end -- 907
	end -- 907
end -- 896
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 959
	local rs = ctx.view.reloadSession -- 966
	local active = rs.active -- 967
	local retracting = not active and self.retractAnimT > 0.01 -- 968
	if not active and not retracting then -- 968
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 968
			self:drawArmedEffectBadge( -- 972
				uiDraw, -- 972
				uiInkDraw, -- 972
				uiArt, -- 972
				ctx, -- 972
				rs.nextEffect -- 972
			) -- 972
		end -- 972
		return false -- 974
	end -- 974
	local cx = self.panelCx -- 977
	local cy = self.panelCy -- 978
	local pw = self.panelW -- 979
	local ph = self.panelH -- 980
	local x0 = cx - pw * 0.5 -- 981
	local y0 = cy - ph * 0.5 -- 982
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 984
		0, -- 986
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 986
	) -- 986
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 987
	local px = cx + shakeX -- 990
	if active then -- 990
		uiDraw:drawRect( -- 994
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 994
			Color( -- 994
				10, -- 994
				13, -- 994
				20, -- 994
				math.floor(54 * appear + 0.5) -- 994
			) -- 994
		) -- 994
	end -- 994
	drawSilkVeil( -- 998
		uiDraw, -- 998
		uiArt, -- 998
		"rw_outer_veil", -- 998
		px, -- 998
		cy, -- 998
		pw + 34, -- 998
		ph + 28, -- 998
		PALETTE.inkWash, -- 998
		0.72 * appear, -- 998
		-2 -- 998
	) -- 998
	if not uiArt:tryPlace( -- 998
		"ink_song_paper", -- 999
		"rw_paper", -- 999
		px, -- 999
		cy, -- 999
		pw, -- 999
		ph, -- 999
		{opacity = 0.94 * appear, layer = 1} -- 999
	) then -- 999
		uiDraw:drawRoundedRect( -- 1000
			Rect(x0 + shakeX, y0, pw, ph), -- 1001
			6, -- 1002
			toColor(PALETTE.xuanPaper, 240 * appear), -- 1003
			1.2, -- 1004
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 1005
		) -- 1005
	end -- 1005
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 1008
	drawFiligreeCorners( -- 1009
		uiInkDraw, -- 1009
		uiArt, -- 1009
		"rw_frame", -- 1009
		x0 + shakeX + 8, -- 1009
		y0 + 8, -- 1009
		pw - 16, -- 1009
		ph - 16, -- 1009
		frameCol, -- 1009
		0.72 * appear, -- 1009
		22, -- 1009
		true, -- 1009
		2 -- 1009
	) -- 1009
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1012
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1015
	local effAccent = self:effectInkColor(previewEffect) -- 1018
	local headY = y0 + ph - 32 -- 1020
	____exports.drawReloadPatternGlyph( -- 1021
		uiInkDraw, -- 1021
		px - 52, -- 1021
		headY, -- 1021
		11, -- 1021
		previewEffect, -- 1021
		effAccent, -- 1021
		appear -- 1021
	) -- 1021
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1022
	ctx.texts:put( -- 1025
		"sm", -- 1026
		titleText, -- 1027
		px - 32, -- 1028
		headY, -- 1029
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1030
		0, -- 1031
		0.5, -- 1032
		"Left", -- 1033
		1.6, -- 1034
		0.96 * appear, -- 1035
		0 -- 1036
	) -- 1036
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1036
		local canReset = #activePath > 1 -- 1039
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1040
		uiInkDraw:drawRect( -- 1041
			rb, -- 1042
			Color( -- 1043
				32, -- 1043
				30, -- 1043
				32, -- 1043
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1043
			), -- 1043
			0.85, -- 1044
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1045
		) -- 1045
		ctx.texts:put( -- 1047
			"xs", -- 1048
			"重画", -- 1049
			rb.x + rb.width * 0.5, -- 1050
			rb.y + rb.height * 0.5, -- 1051
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1052
			0.5, -- 1053
			0.5, -- 1054
			"Center", -- 1055
			1, -- 1056
			(canReset and 0.94 or 0.52) * appear, -- 1057
			0 -- 1058
		) -- 1058
	end -- 1058
	drawHairline( -- 1061
		uiInkDraw, -- 1061
		uiArt, -- 1061
		"rw_head_line", -- 1061
		px, -- 1061
		headY - 18, -- 1061
		pw - 42, -- 1061
		PALETTE.xuanInkSub, -- 1061
		0.45 * appear, -- 1061
		false, -- 1061
		2 -- 1061
	) -- 1061
	local idx = 0 -- 1064
	do -- 1064
		idx = 0 -- 1065
		while idx < 3 do -- 1065
			local hA = self:getNodeUiPos(idx * 3) -- 1066
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1067
			uiInkDraw:drawSegment( -- 1068
				Vec2(hA.x + shakeX, hA.y), -- 1068
				Vec2(hB.x + shakeX, hB.y), -- 1068
				0.75, -- 1068
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1068
			) -- 1068
			local vA = self:getNodeUiPos(idx) -- 1069
			local vB = self:getNodeUiPos(6 + idx) -- 1070
			uiInkDraw:drawSegment( -- 1071
				Vec2(vA.x + shakeX, vA.y), -- 1071
				Vec2(vB.x + shakeX, vB.y), -- 1071
				0.75, -- 1071
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1071
			) -- 1071
			idx = idx + 1 -- 1065
		end -- 1065
	end -- 1065
	if #activePath >= 2 then -- 1065
		self:drawPathStrokes( -- 1076
			uiInkDraw, -- 1076
			uiGlow, -- 1076
			activePath, -- 1076
			previewEffect, -- 1076
			effAccent, -- 1076
			shakeX, -- 1076
			appear -- 1076
		) -- 1076
	end -- 1076
	if active and self.dragging and #activePath >= 1 then -- 1076
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1081
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1082
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1083
		uiInkDraw:drawSegment( -- 1084
			Vec2(tail.x + shakeX, tail.y), -- 1084
			Vec2(mx, my), -- 1084
			1.4, -- 1084
			toColor(effAccent, 150 * appear) -- 1084
		) -- 1084
		uiInkDraw:drawDot( -- 1085
			Vec2(mx, my), -- 1085
			3, -- 1085
			toColor(effAccent, 210 * appear) -- 1085
		) -- 1085
	end -- 1085
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1089
	do -- 1089
		idx = 0 -- 1090
		while idx < #____exports.RELOAD_GRID do -- 1090
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1091
			local pos = self:getNodeUiPos(idx) -- 1092
			local nx = pos.x + shakeX -- 1093
			local ny = pos.y -- 1094
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1095
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1096
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1097
			self:drawGridNode( -- 1098
				uiInkDraw, -- 1098
				uiArt, -- 1098
				uiGlow, -- 1098
				spec, -- 1098
				nx, -- 1098
				ny, -- 1098
				inPath, -- 1098
				isValidNext, -- 1098
				isKbFocus, -- 1098
				effAccent, -- 1098
				appear -- 1098
			) -- 1098
			idx = idx + 1 -- 1090
		end -- 1090
	end -- 1090
	self:drawChildFinger( -- 1102
		uiInkDraw, -- 1102
		uiArt, -- 1102
		uiGlow, -- 1102
		active, -- 1102
		activePath, -- 1102
		shakeX, -- 1102
		appear -- 1102
	) -- 1102
	local barW = pw - 52 -- 1105
	local barX = px - barW * 0.5 -- 1106
	local barY = y0 + 28 -- 1107
	local remainFrac = active and math.max( -- 1108
		0, -- 1109
		math.min( -- 1109
			1, -- 1109
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1109
		) -- 1109
	) or (self.settledTimedOut and 0 or 1) -- 1109
	local urgent = active and remainFrac < 0.25 -- 1111
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1112
	uiInkDraw:drawSegment( -- 1113
		Vec2(barX, barY), -- 1113
		Vec2(barX + barW, barY), -- 1113
		1.4, -- 1113
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1113
	) -- 1113
	if remainFrac > 0.005 then -- 1113
		uiInkDraw:drawSegment( -- 1115
			Vec2(barX, barY), -- 1115
			Vec2(barX + barW * remainFrac, barY), -- 1115
			3, -- 1115
			toColor(barCol, 225 * appear) -- 1115
		) -- 1115
	end -- 1115
	local tTick = 1 -- 1118
	do -- 1118
		tTick = 1 -- 1119
		while tTick <= 3 do -- 1119
			local tx = barX + barW * (tTick / 4) -- 1120
			uiInkDraw:drawSegment( -- 1121
				Vec2(tx, barY - 3.5), -- 1121
				Vec2(tx, barY + 3.5), -- 1121
				0.9, -- 1121
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1121
			) -- 1121
			tTick = tTick + 1 -- 1119
		end -- 1119
	end -- 1119
	if active and ctx.view.assistHintsEnabled then -- 1119
		local mode = ctx.input.inputMode -- 1126
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. getActiveTarget():keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1127
		ctx.texts:put( -- 1132
			"xs", -- 1133
			hint, -- 1134
			px, -- 1135
			y0 + 13, -- 1136
			toColor(PALETTE.xuanInkSub), -- 1137
			0.5, -- 1138
			0.5, -- 1139
			"Center", -- 1140
			0.6, -- 1141
			0.82 * appear, -- 1142
			0 -- 1143
		) -- 1143
	end -- 1143
	return active -- 1147
end -- 959
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1150
	if effect == "echo" then -- 1150
		return PALETTE.rouge -- 1152
	end -- 1152
	if effect == "light" then -- 1152
		return PALETTE.amberDim -- 1155
	end -- 1155
	if effect == "knockback" then -- 1155
		return PALETTE.xuanInk -- 1158
	end -- 1158
	return PALETTE.xuanInkSub -- 1160
end -- 1150
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1163
	local i = 0 -- 1172
	do -- 1172
		i = 0 -- 1173
		while i < #path - 1 do -- 1173
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1174
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1175
			local ax = p0.x + shakeX -- 1176
			local ay = p0.y -- 1177
			local bx = p1.x + shakeX -- 1178
			local by = p1.y -- 1179
			if effect == "echo" then -- 1179
				local dx = bx - ax -- 1183
				local dy = by - ay -- 1184
				local len = math.max( -- 1185
					1, -- 1185
					math.sqrt(dx * dx + dy * dy) -- 1185
				) -- 1185
				local nx = -dy / len * 2.2 -- 1186
				local ny = dx / len * 2.2 -- 1187
				uiInkDraw:drawSegment( -- 1188
					Vec2(ax + nx, ay + ny), -- 1188
					Vec2(bx + nx, by + ny), -- 1188
					1.35, -- 1188
					toColor(col, 220 * appear) -- 1188
				) -- 1188
				uiInkDraw:drawSegment( -- 1189
					Vec2(ax - nx, ay - ny), -- 1189
					Vec2(bx - nx, by - ny), -- 1189
					1.35, -- 1189
					toColor(col, 220 * appear) -- 1189
				) -- 1189
			elseif effect == "light" then -- 1189
				uiInkDraw:drawSegment( -- 1192
					Vec2(ax, ay), -- 1192
					Vec2(bx, by), -- 1192
					3.1, -- 1192
					toColor(PALETTE.xuanInk, 195 * appear) -- 1192
				) -- 1192
				uiInkDraw:drawSegment( -- 1193
					Vec2(ax, ay), -- 1193
					Vec2(bx, by), -- 1193
					1.3, -- 1193
					toColor(PALETTE.amberCore, 235 * appear) -- 1193
				) -- 1193
				uiGlow:drawSegment( -- 1194
					Vec2(ax, ay), -- 1194
					Vec2(bx, by), -- 1194
					3.2, -- 1194
					toColor(PALETTE.amber, 55 * appear) -- 1194
				) -- 1194
			else -- 1194
				uiInkDraw:drawSegment( -- 1197
					Vec2(ax, ay), -- 1197
					Vec2(bx, by), -- 1197
					2.8, -- 1197
					toColor(col, 230 * appear) -- 1197
				) -- 1197
			end -- 1197
			i = i + 1 -- 1173
		end -- 1173
	end -- 1173
end -- 1163
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiArt, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1202
	local baseR = spec.kind == "plain" and 11 or 15 -- 1215
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1216
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1217
	if isKbFocus then -- 1217
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1221
		uiInkDraw:drawRing( -- 1222
			Vec2(nx, ny), -- 1222
			baseR + 4.5, -- 1222
			baseR + 6.2, -- 1222
			Color(0, 0, 0, 0), -- 1222
			1.1, -- 1222
			toColor(focusCol, 215 * appear) -- 1222
		) -- 1222
	end -- 1222
	if spec.kind == "bell" then -- 1222
		if inPath then -- 1222
			uiInkDraw:drawCircle( -- 1228
				Vec2(nx, ny), -- 1228
				baseR + 1, -- 1228
				toColor(PALETTE.rouge, 36 * appear) -- 1228
			) -- 1228
			uiGlow:drawRing( -- 1229
				Vec2(nx, ny), -- 1229
				baseR + 2, -- 1229
				baseR + 5, -- 1229
				Color(0, 0, 0, 0), -- 1229
				1.2, -- 1229
				toColor(PALETTE.rouge, 110 * appear) -- 1229
			) -- 1229
		end -- 1229
		uiInkDraw:drawRing( -- 1231
			Vec2(nx, ny), -- 1231
			baseR - 1.2, -- 1231
			baseR, -- 1231
			Color(0, 0, 0, 0), -- 1231
			1.1, -- 1231
			toColor(strokeCol, strokeAlpha * appear) -- 1231
		) -- 1231
		____exports.drawReloadPatternGlyph( -- 1232
			uiInkDraw, -- 1232
			nx, -- 1232
			ny, -- 1232
			9.5, -- 1232
			"echo", -- 1232
			inPath and PALETTE.rouge or strokeCol, -- 1232
			appear, -- 1232
			uiArt, -- 1232
			"rw_glyph_bell", -- 1232
			4 -- 1232
		) -- 1232
		return -- 1233
	end -- 1233
	if spec.kind == "lamp" then -- 1233
		if inPath then -- 1233
			uiInkDraw:drawCircle( -- 1239
				Vec2(nx, ny), -- 1239
				baseR + 1, -- 1239
				toColor(PALETTE.amber, 56 * appear) -- 1239
			) -- 1239
			fillRadialGlow( -- 1240
				uiGlow, -- 1240
				nx, -- 1240
				ny, -- 1240
				22, -- 1240
				22, -- 1240
				toColor(PALETTE.amberCore, 72 * appear), -- 1240
				Color(244, 234, 214, 0), -- 1240
				12 -- 1240
			) -- 1240
		end -- 1240
		uiInkDraw:drawRing( -- 1242
			Vec2(nx, ny), -- 1242
			baseR - 1.2, -- 1242
			baseR, -- 1242
			Color(0, 0, 0, 0), -- 1242
			1.1, -- 1242
			toColor(strokeCol, strokeAlpha * appear) -- 1242
		) -- 1242
		____exports.drawReloadPatternGlyph( -- 1243
			uiInkDraw, -- 1243
			nx, -- 1243
			ny, -- 1243
			9.5, -- 1243
			"light", -- 1243
			inPath and PALETTE.xuanInk or strokeCol, -- 1243
			appear, -- 1243
			uiArt, -- 1243
			"rw_glyph_lamp", -- 1243
			4 -- 1243
		) -- 1243
		return -- 1244
	end -- 1244
	if spec.kind == "target" then -- 1244
		drawDiamond( -- 1249
			uiInkDraw, -- 1250
			nx, -- 1251
			ny, -- 1252
			baseR, -- 1253
			baseR, -- 1254
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1255
			1.4, -- 1256
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1257
		) -- 1257
		drawDiamond( -- 1259
			uiInkDraw, -- 1260
			nx, -- 1261
			ny, -- 1262
			baseR * 0.56, -- 1263
			baseR * 0.56, -- 1264
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1265
		) -- 1265
		return -- 1267
	end -- 1267
	if spec.kind == "start" then -- 1267
		uiInkDraw:drawRing( -- 1272
			Vec2(nx, ny), -- 1272
			baseR - 2.2, -- 1272
			baseR, -- 1272
			Color(0, 0, 0, 0), -- 1272
			1.2, -- 1272
			toColor(PALETTE.rouge, 220 * appear) -- 1272
		) -- 1272
		uiInkDraw:drawCircle( -- 1273
			Vec2(nx, ny), -- 1273
			4.8, -- 1273
			toColor(PALETTE.xuanInk, 235 * appear) -- 1273
		) -- 1273
		return -- 1274
	end -- 1274
	if inPath then -- 1274
		uiInkDraw:drawCircle( -- 1279
			Vec2(nx, ny), -- 1279
			6.2, -- 1279
			toColor(effAccent, 235 * appear) -- 1279
		) -- 1279
		uiInkDraw:drawRing( -- 1280
			Vec2(nx, ny), -- 1280
			9.5, -- 1280
			10.8, -- 1280
			Color(0, 0, 0, 0), -- 1280
			1, -- 1280
			toColor(effAccent, 165 * appear) -- 1280
		) -- 1280
	else -- 1280
		uiInkDraw:drawRing( -- 1282
			Vec2(nx, ny), -- 1282
			5.6, -- 1282
			7, -- 1282
			Color(0, 0, 0, 0), -- 1282
			1, -- 1282
			toColor(strokeCol, strokeAlpha * appear) -- 1282
		) -- 1282
	end -- 1282
end -- 1202
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiArt, uiGlow, active, path, shakeX, appear) -- 1287
	local fx = 0 -- 1296
	local fy = 0 -- 1297
	if active then -- 1297
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1300
		local pos = self:getNodeUiPos(tipNode) -- 1301
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1302
		fx = pos.x + shakeX + 4 + tapPulse * 0.35 -- 1303
		fy = pos.y - 4 - tapPulse -- 1304
		if #path <= 1 then -- 1304
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1307
			uiInkDraw:drawRing( -- 1308
				Vec2(pos.x + shakeX, pos.y), -- 1308
				ringR - 1, -- 1308
				ringR, -- 1308
				Color(0, 0, 0, 0), -- 1308
				1, -- 1308
				toColor(PALETTE.rouge, 130 * appear) -- 1308
			) -- 1308
		end -- 1308
	elseif self.retractAnimT > 0 and #path > 0 then -- 1308
		local prog = math.max( -- 1312
			0, -- 1312
			math.min( -- 1312
				1, -- 1312
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1312
			) -- 1312
		) -- 1312
		local revFloat = (1 - prog) * (#path - 1) -- 1313
		local idxA = math.max( -- 1314
			0, -- 1314
			math.min( -- 1314
				#path - 1, -- 1314
				math.floor(revFloat) -- 1314
			) -- 1314
		) -- 1314
		local idxB = math.max( -- 1315
			0, -- 1315
			math.min(#path - 1, idxA + 1) -- 1315
		) -- 1315
		local frac = revFloat - idxA -- 1316
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1317
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1318
		fx = pA.x + (pB.x - pA.x) * frac + shakeX + prog * 28 -- 1319
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1320
	else -- 1320
		return -- 1322
	end -- 1322
	uiGlow:drawDot( -- 1325
		Vec2(fx, fy), -- 1325
		3.6, -- 1325
		toColor(PALETTE.amberCore, 88 * appear) -- 1325
	) -- 1325
	if uiArt:tryPlacePath( -- 1325
		"assets/art/vfx_craft_art.clip|reload_child_finger", -- 1326
		"rw_child_finger", -- 1326
		fx, -- 1326
		fy, -- 1326
		64, -- 1326
		56, -- 1326
		{ -- 1326
			anchorX = 0.04, -- 1327
			anchorY = 0.96, -- 1328
			preserveAspect = true, -- 1329
			smooth = true, -- 1330
			opacity = 0.96 * appear, -- 1331
			layer = 6 -- 1332
		} -- 1332
	) then -- 1332
		return -- 1334
	end -- 1334
	local a255 = math.floor(240 * appear + 0.5) -- 1338
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1339
	uiInkDraw:drawPolygon( -- 1340
		{ -- 1340
			Vec2(fx - 30, fy - 20), -- 1341
			Vec2(fx - 22, fy - 28), -- 1342
			Vec2(fx - 11, fy - 14), -- 1343
			Vec2(fx - 17, fy - 9) -- 1344
		}, -- 1344
		Color(164, 78, 54, a255), -- 1345
		1, -- 1345
		inkCol -- 1345
	) -- 1345
	uiInkDraw:drawSegment( -- 1346
		Vec2(fx - 16, fy - 10), -- 1346
		Vec2(fx - 11, fy - 15), -- 1346
		2, -- 1346
		Color(204, 174, 122, a255) -- 1346
	) -- 1346
	uiInkDraw:drawCircle( -- 1347
		Vec2(fx - 9, fy - 8), -- 1347
		4.8, -- 1347
		Color(238, 212, 182, a255) -- 1347
	) -- 1347
	uiInkDraw:drawSegment( -- 1348
		Vec2(fx - 7, fy - 6), -- 1348
		Vec2(fx, fy), -- 1348
		2.5, -- 1348
		Color(244, 222, 196, a255) -- 1348
	) -- 1348
	uiInkDraw:drawRing( -- 1349
		Vec2(fx, fy), -- 1349
		2, -- 1349
		3, -- 1349
		Color(0, 0, 0, 0), -- 1349
		0.9, -- 1349
		inkCol -- 1349
	) -- 1349
end -- 1287
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1353
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1360
	local bx = 46 + safe.left -- 1361
	local by = ctx.uiH - 134 - safe.top -- 1362
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1363
	drawSilkVeil( -- 1364
		uiDraw, -- 1364
		uiArt, -- 1364
		"rw_armed_veil", -- 1364
		bx + 54, -- 1364
		by, -- 1364
		142, -- 1364
		30, -- 1364
		PALETTE.inkWash, -- 1364
		0.72, -- 1364
		-1 -- 1364
	) -- 1364
	____exports.drawReloadPatternGlyph( -- 1365
		uiInkDraw, -- 1365
		bx + 12, -- 1365
		by, -- 1365
		9, -- 1365
		effect, -- 1365
		col, -- 1365
		0.96, -- 1365
		uiArt, -- 1365
		"rw_armed_glyph", -- 1365
		4 -- 1365
	) -- 1365
	drawBlossomDot( -- 1366
		uiInkDraw, -- 1366
		uiArt, -- 1366
		"rw_armed_dot", -- 1366
		bx + 28, -- 1366
		by, -- 1366
		6, -- 1366
		col, -- 1366
		0.85, -- 1366
		3 -- 1366
	) -- 1366
	ctx.texts:put( -- 1367
		"xs", -- 1367
		____exports.reloadEffectShortLabel(effect), -- 1367
		bx + 38, -- 1367
		by, -- 1367
		toColor(PALETTE.textBright), -- 1367
		0, -- 1367
		0.5, -- 1367
		"Left", -- 1367
		1, -- 1367
		0.94, -- 1367
		0.08 -- 1367
	) -- 1367
end -- 1353
function ____exports.createReloadWheelPlugin(contract) -- 1371
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1372
end -- 1371
return ____exports -- 1371