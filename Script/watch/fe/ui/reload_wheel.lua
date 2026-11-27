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
local ____platform = require("Script.watch.platform") -- 21
local ZERO_SAFE_INSETS = ____platform.ZERO_SAFE_INSETS -- 21
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 23
local keyTagFor = ____control_prompts.keyTagFor -- 23
local ____theme = require("Script.watch.fe.theme") -- 31
local PALETTE = ____theme.PALETTE -- 32
local drawBlossomDot = ____theme.drawBlossomDot -- 34
local drawDiamond = ____theme.drawDiamond -- 35
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 36
local drawHairline = ____theme.drawHairline -- 37
local drawSilkVeil = ____theme.drawSilkVeil -- 38
local fillRadialGlow = ____theme.fillRadialGlow -- 39
local toColor = ____theme.toColor -- 40
____exports.RELOAD_START_NODE = 0 -- 54
____exports.RELOAD_TARGET_NODE = 8 -- 55
--- 3×3 九宫格节点真源表（对齐后端 Script/watch/reload.ts 与 contract.ts）
____exports.RELOAD_GRID = { -- 58
	{id = 0, col = 0, row = 0, kind = "start"}, -- 59
	{id = 1, col = 1, row = 0, kind = "plain"}, -- 60
	{id = 2, col = 2, row = 0, kind = "lamp"}, -- 61
	{id = 3, col = 0, row = 1, kind = "plain"}, -- 62
	{id = 4, col = 1, row = 1, kind = "bell"}, -- 63
	{id = 5, col = 2, row = 1, kind = "plain"}, -- 64
	{id = 6, col = 0, row = 2, kind = "plain"}, -- 65
	{id = 7, col = 1, row = 2, kind = "plain"}, -- 66
	{id = 8, col = 2, row = 2, kind = "target"} -- 67
} -- 67
--- 8 邻域校验（含斜角，不含自身）
function ____exports.isAdjacentNode(a, b) -- 71
	if a == b then -- 71
		return false -- 73
	end -- 73
	local na = ____exports.RELOAD_GRID[a + 1] -- 75
	local nb = ____exports.RELOAD_GRID[b + 1] -- 76
	if na == nil or nb == nil then -- 76
		return false -- 78
	end -- 78
	return math.abs(na.col - nb.col) <= 1 and math.abs(na.row - nb.row) <= 1 -- 80
end -- 71
--- 完整路径合法性校验：起点 0、每步相邻、不重复、终点 8
function ____exports.validateReloadPath(path) -- 84
	if #path < 2 then -- 84
		return false -- 86
	end -- 86
	if path[1] ~= ____exports.RELOAD_START_NODE or path[#path] ~= ____exports.RELOAD_TARGET_NODE then -- 86
		return false -- 89
	end -- 89
	local seen = {} -- 91
	local i = 0 -- 92
	do -- 92
		i = 0 -- 93
		while i < #path do -- 93
			local n = path[i + 1] -- 94
			if n < 0 or n >= #____exports.RELOAD_GRID or seen[n] == true then -- 94
				return false -- 96
			end -- 96
			seen[n] = true -- 98
			if i > 0 and not ____exports.isAdjacentNode(path[i], n) then -- 98
				return false -- 100
			end -- 100
			i = i + 1 -- 93
		end -- 93
	end -- 93
	return true -- 103
end -- 84
--- 按路径经过纹样推导效果（铃纹 4 优先于灯纹 2，其余合法连接为推退 knockback）
function ____exports.deriveEffectFromGrid(path) -- 107
	if #path < 2 then -- 107
		return "normal" -- 109
	end -- 109
	local hasBell = false -- 111
	local hasLamp = false -- 112
	local i = 0 -- 113
	do -- 113
		i = 0 -- 114
		while i < #path do -- 114
			if path[i + 1] == 4 then -- 114
				hasBell = true -- 116
			elseif path[i + 1] == 2 then -- 116
				hasLamp = true -- 118
			end -- 118
			i = i + 1 -- 114
		end -- 114
	end -- 114
	if hasBell then -- 114
		return "echo" -- 122
	end -- 122
	if hasLamp then -- 122
		return "light" -- 125
	end -- 125
	return "knockback" -- 127
end -- 107
function ____exports.reloadEffectShortLabel(effect) -- 130
	if effect == "knockback" then -- 130
		return "推退" -- 132
	end -- 132
	if effect == "echo" then -- 132
		return "回声诱导" -- 135
	end -- 135
	if effect == "light" then -- 135
		return "照亮遮蔽" -- 138
	end -- 138
	return "待起笔" -- 140
end -- 130
--- 绘制静音/灰度可辨的效果几何纹样（供 reload_wheel 与 craft_bench 共享同一符号体系）：
-- - knockback：双尖横冲箭矢（实线）
-- - echo：铜铃轮廓 + 两侧声波弧（虚/双弧）
-- - light：六角提灯轮廓 + 四向破障短芒
-- - normal：素墨空圆
function ____exports.drawReloadPatternGlyph(draw, cx, cy, radius, effect, col, alpha) -- 150
	if alpha == nil then -- 150
		alpha = 1 -- 157
	end -- 157
	local stroke = toColor(col, 235 * alpha) -- 159
	local faint = toColor(col, 130 * alpha) -- 160
	local r = math.max(5, radius) -- 161
	if effect == "echo" then -- 161
		draw:drawPolygon( -- 165
			{ -- 165
				Vec2(cx - r * 0.56, cy - r * 0.36), -- 166
				Vec2(cx + r * 0.56, cy - r * 0.36), -- 167
				Vec2(cx + r * 0.34, cy + r * 0.42), -- 168
				Vec2(cx, cy + r * 0.62), -- 169
				Vec2(cx - r * 0.34, cy + r * 0.42) -- 170
			}, -- 170
			Color(0, 0, 0, 0), -- 171
			1.35, -- 171
			stroke -- 171
		) -- 171
		draw:drawDot( -- 172
			Vec2(cx, cy - r * 0.54), -- 172
			math.max(1.6, r * 0.16), -- 172
			stroke -- 172
		) -- 172
		draw:drawArc( -- 173
			Vec2(cx, cy + r * 0.04), -- 173
			r * 0.92, -- 173
			-32, -- 173
			32, -- 173
			1, -- 173
			faint -- 173
		) -- 173
		draw:drawArc( -- 174
			Vec2(cx, cy + r * 0.04), -- 174
			r * 0.92, -- 174
			148, -- 174
			212, -- 174
			1, -- 174
			faint -- 174
		) -- 174
		return -- 175
	end -- 175
	if effect == "light" then -- 175
		draw:drawPolygon( -- 180
			{ -- 180
				Vec2(cx, cy + r * 0.72), -- 181
				Vec2(cx + r * 0.48, cy + r * 0.28), -- 182
				Vec2(cx + r * 0.42, cy - r * 0.44), -- 183
				Vec2(cx, cy - r * 0.64), -- 184
				Vec2(cx - r * 0.42, cy - r * 0.44), -- 185
				Vec2(cx - r * 0.48, cy + r * 0.28) -- 186
			}, -- 186
			Color(0, 0, 0, 0), -- 187
			1.35, -- 187
			stroke -- 187
		) -- 187
		drawDiamond( -- 188
			draw, -- 188
			cx, -- 188
			cy, -- 188
			r * 0.22, -- 188
			r * 0.3, -- 188
			stroke -- 188
		) -- 188
		draw:drawSegment( -- 190
			Vec2(cx - r * 0.98, cy), -- 190
			Vec2(cx - r * 0.68, cy), -- 190
			1.1, -- 190
			faint -- 190
		) -- 190
		draw:drawSegment( -- 191
			Vec2(cx + r * 0.68, cy), -- 191
			Vec2(cx + r * 0.98, cy), -- 191
			1.1, -- 191
			faint -- 191
		) -- 191
		draw:drawSegment( -- 192
			Vec2(cx, cy + r * 0.8), -- 192
			Vec2(cx, cy + r * 1.04), -- 192
			1.1, -- 192
			faint -- 192
		) -- 192
		draw:drawSegment( -- 193
			Vec2(cx, cy - r * 0.74), -- 193
			Vec2(cx, cy - r * 1), -- 193
			1.1, -- 193
			faint -- 193
		) -- 193
		return -- 194
	end -- 194
	if effect == "knockback" then -- 194
		draw:drawSegment( -- 199
			Vec2(cx - r * 0.85, cy), -- 199
			Vec2(cx + r * 0.85, cy), -- 199
			1.6, -- 199
			stroke -- 199
		) -- 199
		draw:drawSegment( -- 200
			Vec2(cx + r * 0.24, cy + r * 0.54), -- 200
			Vec2(cx + r * 0.85, cy), -- 200
			1.5, -- 200
			stroke -- 200
		) -- 200
		draw:drawSegment( -- 201
			Vec2(cx + r * 0.24, cy - r * 0.54), -- 201
			Vec2(cx + r * 0.85, cy), -- 201
			1.5, -- 201
			stroke -- 201
		) -- 201
		draw:drawSegment( -- 202
			Vec2(cx - r * 0.34, cy + r * 0.36), -- 202
			Vec2(cx + r * 0.14, cy), -- 202
			1.1, -- 202
			faint -- 202
		) -- 202
		draw:drawSegment( -- 203
			Vec2(cx - r * 0.34, cy - r * 0.36), -- 203
			Vec2(cx + r * 0.14, cy), -- 203
			1.1, -- 203
			faint -- 203
		) -- 203
		return -- 204
	end -- 204
	draw:drawRing( -- 208
		Vec2(cx, cy), -- 208
		r * 0.52, -- 208
		r * 0.68, -- 208
		Color(0, 0, 0, 0), -- 208
		1.1, -- 208
		faint -- 208
	) -- 208
end -- 150
local function resolveRuntimeContract(injected) -- 255
	if injected ~= nil then -- 255
		return injected -- 257
	end -- 257
	local g = _G -- 259
	local ____temp_0 -- 260
	if g.package ~= nil then -- 260
		____temp_0 = g.package.loaded -- 260
	else -- 260
		____temp_0 = nil -- 260
	end -- 260
	local loaded = ____temp_0 -- 260
	if loaded == nil then -- 260
		return nil -- 262
	end -- 262
	local feHook = loaded["watch.fe"] -- 264
	if feHook ~= nil and type(feHook) == "table" then -- 264
		local c = feHook.contract -- 266
		if c ~= nil and type(c) == "table" then -- 266
			return c -- 268
		end -- 268
	end -- 268
	return nil -- 271
end -- 255
local function dispatchIntentFallback(p, intent) -- 274
	local rec = p -- 275
	local handler = rec.submitFeIntent -- 276
	if type(handler) == "function" then -- 276
		return handler(p, intent) ~= false -- 278
	end -- 278
	local tap = rec.reloadTapNode -- 280
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 280
		tap(p, intent.node) -- 282
		return true -- 283
	end -- 283
	return false -- 285
end -- 274
local function readOptionalNum(obj, key) -- 288
	if obj ~= nil and type(obj) == "table" then -- 288
		local v = obj[key] -- 290
		if type(v) == "number" then -- 290
			return v -- 292
		end -- 292
	end -- 292
	return nil -- 295
end -- 288
____exports.ReloadWheelPlugin = __TS__Class() -- 298
local ReloadWheelPlugin = ____exports.ReloadWheelPlugin -- 298
ReloadWheelPlugin.name = "ReloadWheelPlugin" -- 298
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 350
	self.id = "fe-02-reload-wheel" -- 299
	self.wasActive = false -- 303
	self.openAnimT = 0 -- 304
	self.openDuration = 0.24 -- 305
	self.retractAnimT = 0 -- 306
	self.retractDuration = 0.28 -- 307
	self.settledPath = {} -- 308
	self.settledEffect = "normal" -- 309
	self.settledTimedOut = false -- 310
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 311
	self.lastKnownNextEffect = "normal" -- 312
	self.kbCursor = ____exports.RELOAD_START_NODE -- 315
	self.dragging = false -- 316
	self.pointerActive = false -- 317
	self.prevLeft = false -- 318
	self.prevRight = false -- 319
	self.prevUp = false -- 320
	self.prevDown = false -- 321
	self.prevLeftKey = false -- 322
	self.prevRightKey = false -- 323
	self.prevConfirm = false -- 324
	self.prevReset = false -- 325
	self.localInvalidFlash = 0 -- 326
	self.animTime = 0 -- 327
	self.nodePulseSeq = 0 -- 328
	self.panelCx = 940 -- 331
	self.panelCy = 374 -- 332
	self.panelW = 286 -- 333
	self.panelH = 316 -- 334
	self.cellStep = 66 -- 335
	self.hitRadius = 25 -- 336
	self.resetBox = Rect(0, 0, 0, 0) -- 337
	self.lastUiPtrX = 0 -- 338
	self.lastUiPtrY = 0 -- 339
	self.answerTicksAccum = 0 -- 342
	self.worldTicksAccum = 0 -- 343
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 344
	self.appliedVfx = {} -- 347
	self.injectedContract = contract -- 351
end -- 350
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 355
	self.pendingSimInput = sim -- 356
end -- 355
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 359
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 360
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 361
end -- 359
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 367
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 368
end -- 367
function ReloadWheelPlugin.prototype.getState(self) -- 376
	return { -- 377
		active = self.wasActive, -- 378
		kbCursor = self.kbCursor, -- 379
		dragging = self.dragging, -- 380
		path = __TS__ArraySlice(self.lastKnownPath), -- 381
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 382
		nextEffect = self.lastKnownNextEffect, -- 383
		retracting = self.retractAnimT > 0, -- 384
		invalidFlash = self.localInvalidFlash, -- 385
		clock = self:getClockReadings(), -- 386
		panelCenterX = self.panelCx, -- 387
		panelCenterY = self.panelCy, -- 388
		cellStep = self.cellStep -- 389
	} -- 389
end -- 376
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 393
	self.wasActive = false -- 394
	self.openAnimT = 0 -- 395
	self.retractAnimT = 0 -- 396
	self.settledPath = {} -- 397
	self.settledEffect = "normal" -- 398
	self.settledTimedOut = false -- 399
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 400
	self.lastKnownNextEffect = "normal" -- 401
	self.kbCursor = ____exports.RELOAD_START_NODE -- 402
	self.dragging = false -- 403
	self.pointerActive = false -- 404
	self.localInvalidFlash = 0 -- 405
	self.animTime = 0 -- 406
	self.answerTicksAccum = 0 -- 407
	self.worldTicksAccum = 0 -- 408
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 409
	self.appliedVfx = {} -- 410
	self.pendingSimInput = nil -- 411
	self:resetInputEdges() -- 412
end -- 393
function ReloadWheelPlugin.prototype.resetInputEdges(self, touchMode) -- 415
	if touchMode == nil then -- 415
		touchMode = false -- 415
	end -- 415
	local ____temp_1 -- 416
	if not touchMode and type(Mouse) ~= "nil" then -- 416
		____temp_1 = Mouse.leftButtonPressed -- 416
	else -- 416
		____temp_1 = false -- 416
	end -- 416
	self.prevLeft = ____temp_1 -- 416
	local ____temp_2 -- 417
	if not touchMode and type(Mouse) ~= "nil" then -- 417
		____temp_2 = Mouse.rightButtonPressed -- 417
	else -- 417
		____temp_2 = false -- 417
	end -- 417
	self.prevRight = ____temp_2 -- 417
	if type(Keyboard) ~= "nil" then -- 417
		self.prevUp = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 419
		self.prevDown = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 420
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 421
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 422
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 423
		self.prevReset = Keyboard:isKeyPressed("BackSpace") -- 424
	end -- 424
end -- 415
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 428
	local contract = resolveRuntimeContract(self.injectedContract) -- 429
	if contract ~= nil then -- 429
		return contract:submitIntent(p, intent) -- 431
	end -- 431
	return dispatchIntentFallback(p, intent) -- 433
end -- 428
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 436
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 437
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 438
	local marginX = self.panelW * 0.5 + 34 -- 439
	local minCx = marginX + safe.left -- 440
	local maxCx = math.max(minCx, ctx.uiW - marginX - safe.right) -- 441
	if soldierUiX < ctx.uiW * 0.56 then -- 441
		self.panelCx = math.min( -- 443
			maxCx, -- 443
			math.max( -- 443
				minCx, -- 443
				math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 443
			) -- 443
		) -- 443
	else -- 443
		self.panelCx = math.max( -- 445
			minCx, -- 445
			math.min( -- 445
				maxCx, -- 445
				math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 445
			) -- 445
		) -- 445
	end -- 445
	local minCy = self.panelH * 0.5 + 78 + safe.bottom -- 447
	local maxCy = math.max(minCy, ctx.uiH - self.panelH * 0.5 - 66 - safe.top) -- 448
	self.panelCy = math.max( -- 449
		minCy, -- 449
		math.min(maxCy, ctx.uiH * 0.52) -- 449
	) -- 449
	self.resetBox = Rect(self.panelCx + 56, self.panelCy + self.panelH * 0.5 - 45, 72, 26) -- 450
end -- 436
function ReloadWheelPlugin.prototype.update(self, ctx) -- 453
	local rs = ctx.view.reloadSession -- 454
	local p = ctx.p -- 455
	self:computePanelPlacement(ctx) -- 458
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 461
		0.25, -- 461
		math.min(1, ctx.view.timeScale) -- 461
	) or 1) -- 461
	if ctx.paused then -- 461
		self:resetInputEdges(ctx.input:isTouchMode()) -- 465
		return -- 466
	end -- 466
	local udt = math.max(0, ctx.uiDt) -- 469
	local wdt = math.max(0, ctx.worldDt) -- 470
	self.animTime = self.animTime + udt -- 471
	if self.localInvalidFlash > 0 then -- 471
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 474
	end -- 474
	if rs.invalidFlash > self.localInvalidFlash then -- 474
		self.localInvalidFlash = rs.invalidFlash -- 477
	end -- 477
	self:ingestAppliedEffects(ctx) -- 481
	self:updateAppliedVfx(wdt) -- 482
	if rs.active and not self.wasActive then -- 482
		self:onSessionOpened(ctx) -- 486
	elseif not rs.active and self.wasActive then -- 486
		self:onSessionClosed(ctx) -- 488
	end -- 488
	self.wasActive = rs.active -- 490
	if not rs.active then -- 490
		self.lastKnownNextEffect = rs.nextEffect -- 493
		self.lastClock.active = false -- 494
		if self.retractAnimT > 0 then -- 494
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 496
		end -- 496
		self.pendingSimInput = nil -- 498
		return -- 499
	end -- 499
	self.openAnimT = math.min( -- 503
		1, -- 503
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 503
	) -- 503
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 506
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 507
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 507
		self.answerTicksAccum = liveAns -- 509
		self.worldTicksAccum = liveWorld -- 510
	else -- 510
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 512
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 513
	end -- 513
	self.lastClock = { -- 515
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 516
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 517
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 518
		active = true -- 519
	} -- 519
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 523
	self.lastKnownPath = activePath -- 524
	self.lastKnownNextEffect = rs.nextEffect -- 525
	self:processInputs(ctx, activePath) -- 528
end -- 453
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 531
	local rs = ctx.view.reloadSession -- 532
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 533
	self.openAnimT = 0 -- 534
	self.retractAnimT = 0 -- 535
	self.kbCursor = ____exports.RELOAD_START_NODE -- 536
	self.dragging = false -- 537
	self.pointerActive = false -- 538
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 539
	self.answerTicksAccum = 0 -- 540
	self.worldTicksAccum = 0 -- 541
	self:resetInputEdges(ctx.input:isTouchMode()) -- 542
	local hasBackendOpen = false -- 544
	local i = 0 -- 545
	do -- 545
		i = 0 -- 546
		while i < #ctx.events.rawEvents do -- 546
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 546
				hasBackendOpen = true -- 548
				break -- 549
			end -- 549
			i = i + 1 -- 546
		end -- 546
	end -- 546
	if not hasBackendOpen then -- 546
		ctx.audio:playOnce( -- 553
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 554
			"sfx", -- 555
			"assets/audio/combat/reload_open.wav", -- 556
			0.8, -- 557
			"reload:open", -- 558
			ctx.p.ticks -- 559
		) -- 559
	end -- 559
end -- 531
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 564
	local rs = ctx.view.reloadSession -- 565
	self.dragging = false -- 566
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 567
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 567
		local ____self_settledPath_3 = self.settledPath -- 567
		____self_settledPath_3[#____self_settledPath_3 + 1] = ____exports.RELOAD_TARGET_NODE -- 570
	end -- 570
	self.settledEffect = rs.nextEffect -- 572
	self.settledTimedOut = rs.nextEffect == "normal" -- 573
	self.retractAnimT = self.retractDuration -- 574
	local hasBackendClose = false -- 577
	local i = 0 -- 578
	do -- 578
		i = 0 -- 579
		while i < #ctx.events.rawEvents do -- 579
			local n = ctx.events.rawEvents[i + 1].name -- 580
			if n == "reloadSolved" or n == "reloadTimeout" then -- 580
				hasBackendClose = true -- 582
				break -- 583
			end -- 583
			i = i + 1 -- 579
		end -- 579
	end -- 579
	if self.settledTimedOut then -- 579
		if not hasBackendClose then -- 579
			ctx.audio:playOnce( -- 589
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 590
				"sfx", -- 591
				"assets/audio/combat/reload_timeout.wav", -- 592
				0.78, -- 593
				"reload:timeout", -- 594
				ctx.p.ticks -- 595
			) -- 595
		end -- 595
	else -- 595
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 599
		ctx.audio:playOnce( -- 604
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 605
			"sfx", -- 606
			effectWav, -- 607
			0.88, -- 608
			"reload:solved:" .. self.settledEffect, -- 609
			ctx.p.ticks -- 610
		) -- 610
	end -- 610
end -- 564
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 615
	local sim = self.pendingSimInput -- 616
	self.pendingSimInput = nil -- 617
	local touchMode = ctx.input:isTouchMode() -- 619
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 620
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 622
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 625
	local ____temp_13 -- 628
	if (sim and sim.pointerX) ~= nil then -- 628
		____temp_13 = true -- 629
	else -- 629
		local ____useUiPtr_12 -- 630
		if useUiPtr then -- 630
			____useUiPtr_12 = ctx.input.uiInside -- 630
		else -- 630
			____useUiPtr_12 = ctx.input.inside -- 630
		end -- 630
		____temp_13 = ____useUiPtr_12 -- 630
	end -- 630
	local inside = ____temp_13 -- 628
	local ____temp_16 -- 631
	if (sim and sim.leftHeld) ~= nil then -- 631
		____temp_16 = sim.leftHeld -- 632
	else -- 632
		____temp_16 = ctx.input.uiHeld or ctx.input.fire.held or not touchMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 633
	end -- 633
	local leftHeld = ____temp_16 -- 631
	local ____temp_19 -- 634
	if (sim and sim.rightHeld) ~= nil then -- 634
		____temp_19 = sim.rightHeld -- 635
	else -- 635
		____temp_19 = ctx.input.uiRightPressed or not touchMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 636
	end -- 636
	local rightHeld = ____temp_19 -- 634
	local ____temp_22 -- 638
	if (sim and sim.leftHeld) ~= nil then -- 638
		____temp_22 = leftHeld and not self.prevLeft -- 639
	else -- 639
		____temp_22 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 640
	end -- 640
	local leftPressed = ____temp_22 -- 638
	local ____temp_25 -- 641
	if (sim and sim.leftHeld) ~= nil then -- 641
		____temp_25 = not leftHeld and self.prevLeft -- 642
	else -- 642
		____temp_25 = ctx.input.uiReleased or not leftHeld and self.prevLeft -- 643
	end -- 643
	local leftReleased = ____temp_25 -- 641
	local ____temp_28 -- 644
	if (sim and sim.rightHeld) ~= nil then -- 644
		____temp_28 = rightHeld and not self.prevRight -- 645
	else -- 645
		____temp_28 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 646
	end -- 646
	local rightPressed = ____temp_28 -- 644
	self.prevLeft = leftHeld -- 647
	self.prevRight = rightHeld -- 648
	self.lastUiPtrX = ptrX -- 649
	self.lastUiPtrY = ptrY -- 650
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 652
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 653
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 654
	if pointerMoved or leftPressed then -- 654
		self.pointerActive = true -- 657
	end -- 657
	local lastNode = activePath[#activePath] -- 660
	local activeHitR = touchMode and 38 or self.hitRadius -- 661
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 662
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 665
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 665
		self.dragging = false -- 667
		self:triggerInvalidReset(ctx, activePath, false) -- 668
		return -- 669
	end -- 669
	if leftPressed then -- 669
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 669
			self.dragging = true -- 675
			self.kbCursor = lastNode -- 676
		elseif hitNode >= 0 then -- 676
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 676
				self.dragging = true -- 679
				self:commitNodeStep(ctx, hitNode, activePath) -- 680
			else -- 680
				self.dragging = false -- 682
				self:triggerInvalidReset(ctx, activePath, true) -- 683
			end -- 683
			return -- 685
		end -- 685
	elseif self.dragging and leftHeld then -- 685
		if hitNode >= 0 and hitNode ~= lastNode then -- 685
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 685
				self:commitNodeStep(ctx, hitNode, activePath) -- 690
			else -- 690
				self.dragging = false -- 693
				self:triggerInvalidReset(ctx, activePath, true) -- 694
			end -- 694
			return -- 696
		end -- 696
	elseif leftReleased and self.dragging then -- 696
		self.dragging = false -- 699
		if lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 699
			self:triggerInvalidReset(ctx, activePath, true) -- 702
			return -- 703
		end -- 703
	end -- 703
	local dCol = 0 -- 708
	local dRow = 0 -- 709
	local confirmPressed = false -- 710
	local resetPressed = false -- 711
	local gpAutoCommit = false -- 712
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 712
		dCol = sim.moveCol or 0 -- 715
		dRow = sim.moveRow or 0 -- 716
		confirmPressed = sim.confirm == true -- 717
		resetPressed = sim.reset == true -- 718
	else -- 718
		if type(Keyboard) ~= "nil" then -- 718
			local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 721
			local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 722
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 723
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 724
			local confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 725
			local reset = Keyboard:isKeyPressed("BackSpace") -- 726
			if up and not self.prevUp then -- 726
				dRow = dRow + 1 -- 728
			end -- 728
			if down and not self.prevDown then -- 728
				dRow = dRow - 1 -- 729
			end -- 729
			if rk and not self.prevRightKey then -- 729
				dCol = dCol + 1 -- 730
			end -- 730
			if lk and not self.prevLeftKey then -- 730
				dCol = dCol - 1 -- 731
			end -- 731
			confirmPressed = confirm and not self.prevConfirm -- 732
			resetPressed = reset and not self.prevReset -- 733
			self.prevUp = up -- 735
			self.prevDown = down -- 736
			self.prevLeftKey = lk -- 737
			self.prevRightKey = rk -- 738
			self.prevConfirm = confirm -- 739
			self.prevReset = reset -- 740
		end -- 740
		if ctx.input.reloadReset then -- 740
			resetPressed = true -- 743
		end -- 743
		if ctx.input.reloadConfirm then -- 743
			confirmPressed = true -- 746
		end -- 746
		if dCol == 0 and dRow == 0 and ctx.input.reloadStepEdge then -- 746
			dCol = ctx.input.reloadDirCol -- 749
			dRow = ctx.input.reloadDirRow -- 750
			gpAutoCommit = ctx.input.reloadAutoStep -- 751
		end -- 751
	end -- 751
	if resetPressed and #activePath > 1 then -- 751
		self:triggerInvalidReset(ctx, activePath, false) -- 756
		return -- 757
	end -- 757
	if dCol ~= 0 or dRow ~= 0 then -- 757
		self.pointerActive = false -- 761
		local baseIdx = gpAutoCommit and lastNode or self.kbCursor -- 762
		local cur = ____exports.RELOAD_GRID[baseIdx + 1] or ____exports.RELOAD_GRID[1] -- 763
		local nextCol = math.max( -- 764
			0, -- 764
			math.min(2, cur.col + dCol) -- 764
		) -- 764
		local nextRow = math.max( -- 765
			0, -- 765
			math.min(2, cur.row + dRow) -- 765
		) -- 765
		local nextIdx = nextRow * 3 + nextCol -- 766
		self.kbCursor = nextIdx -- 767
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 767
			self:commitNodeStep(ctx, nextIdx, activePath) -- 769
			return -- 770
		end -- 770
	end -- 770
	if confirmPressed then -- 770
		self.pointerActive = false -- 775
		if self.kbCursor == lastNode then -- 775
			return -- 777
		end -- 777
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 777
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 780
		else -- 780
			self:triggerInvalidReset(ctx, activePath, true) -- 782
		end -- 782
	end -- 782
end -- 615
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 787
	self.kbCursor = node -- 788
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 789
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 790
	if node == ____exports.RELOAD_TARGET_NODE then -- 790
		self.dragging = false -- 792
		return -- 793
	end -- 793
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 796
	ctx.audio:playOnce( -- 797
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 798
		"sfx", -- 799
		"assets/audio/combat/reload_node.wav", -- 800
		0.78, -- 801
		"reload:node:" .. tostring(node), -- 802
		ctx.p.ticks -- 803
	) -- 803
end -- 787
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 807
	if flashError then -- 807
		self.localInvalidFlash = 0.36 -- 809
	end -- 809
	self.kbCursor = ____exports.RELOAD_START_NODE -- 811
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 812
	if #activePath > 1 then -- 812
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 815
	end -- 815
	if flashError then -- 815
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 818
		ctx.audio:playOnce( -- 819
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 820
			"sfx", -- 821
			"assets/audio/combat/reload_invalid.wav", -- 822
			0.72, -- 823
			"reload:invalid", -- 824
			ctx.p.ticks -- 825
		) -- 825
	end -- 825
end -- 807
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 830
	if hitR == nil then -- 830
		hitR = self.hitRadius -- 830
	end -- 830
	local r2 = hitR * hitR -- 831
	local i = 0 -- 832
	do -- 832
		i = 0 -- 833
		while i < #____exports.RELOAD_GRID do -- 833
			local pos = self:getNodeUiPos(i) -- 834
			local dx = uiX - pos.x -- 835
			local dy = uiY - pos.y -- 836
			if dx * dx + dy * dy <= r2 then -- 836
				return i -- 838
			end -- 838
			i = i + 1 -- 833
		end -- 833
	end -- 833
	return -1 -- 841
end -- 830
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 844
	local p = ctx.p -- 845
	local triggered = false -- 846
	local i = 0 -- 847
	do -- 847
		i = 0 -- 848
		while i < #ctx.events.rawEvents do -- 848
			local e = ctx.events.rawEvents[i + 1] -- 849
			if e.name == "reloadApplied" then -- 849
				local rawEff = e.data.effect -- 851
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 852
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 855
				self:spawnAppliedVfx(eff, p, ex) -- 856
				triggered = true -- 857
			end -- 857
			i = i + 1 -- 848
		end -- 848
	end -- 848
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 848
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 862
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 863
	end -- 863
end -- 844
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 867
	local originX = p.player.x + p.player.facing * 18 -- 868
	local originY = p.player.y + p.player.depth + p.player.h * 0.62 -- 869
	local targetY = p.player.y + p.player.depth + 46 -- 870
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 871
	local ____self_appliedVfx_31 = self.appliedVfx -- 871
	____self_appliedVfx_31[#____self_appliedVfx_31 + 1] = { -- 872
		effect = effect, -- 873
		originX = originX, -- 874
		originY = originY, -- 875
		targetX = targetX, -- 876
		targetY = targetY, -- 877
		facing = p.player.facing >= 0 and 1 or -1, -- 878
		life = maxLife, -- 879
		maxLife = maxLife -- 880
	} -- 880
end -- 867
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 884
	if wdt <= 0 or #self.appliedVfx == 0 then -- 884
		return -- 886
	end -- 886
	local w = 0 -- 888
	local i = 0 -- 889
	do -- 889
		i = 0 -- 890
		while i < #self.appliedVfx do -- 890
			local fx = self.appliedVfx[i + 1] -- 891
			fx.life = fx.life - wdt -- 892
			if fx.life > 0 then -- 892
				self.appliedVfx[w + 1] = fx -- 894
				w = w + 1 -- 895
			end -- 895
			i = i + 1 -- 890
		end -- 890
	end -- 890
	__TS__ArraySetLength(self.appliedVfx, w) -- 890
end -- 884
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 902
	if #self.appliedVfx == 0 then -- 902
		return -- 909
	end -- 909
	local cam = ctx.cam -- 911
	local i = 0 -- 912
	do -- 912
		i = 0 -- 913
		while i < #self.appliedVfx do -- 913
			local fx = self.appliedVfx[i + 1] -- 914
			local k = math.max( -- 915
				0, -- 915
				math.min(1, fx.life / fx.maxLife) -- 915
			) -- 915
			local prog = 1 - k -- 916
			local ox = cam:sx(fx.originX) -- 917
			local oy = cam:sy(fx.originY) -- 918
			local tx = cam:sx(fx.targetX) -- 919
			local ty = cam:sy(fx.targetY) -- 920
			if fx.effect == "knockback" then -- 920
				local r = cam:len(12 + prog * 34) -- 924
				local startA = fx.facing >= 0 and -48 or 132 -- 925
				local endA = fx.facing >= 0 and 48 or 228 -- 926
				fgGlow:drawArc( -- 927
					Vec2(tx, ty), -- 927
					r, -- 927
					startA, -- 927
					endA, -- 927
					2.4 * k, -- 927
					toColor(PALETTE.moonPale, 210 * k) -- 927
				) -- 927
				fgDraw:drawArc( -- 928
					Vec2( -- 928
						tx - fx.facing * cam:len(6), -- 928
						ty -- 928
					), -- 928
					r * 0.72, -- 928
					startA, -- 928
					endA, -- 928
					1.5 * k, -- 928
					toColor(PALETTE.silkLine, 165 * k) -- 928
				) -- 928
			elseif fx.effect == "echo" then -- 928
				local r1 = cam:len(10 + prog * 64) -- 931
				local r2 = cam:len(6 + prog * 40) -- 932
				fgGlow:drawRing( -- 933
					Vec2(tx, ty), -- 933
					math.max(1, r1 - 1.6), -- 933
					r1, -- 933
					Color(0, 0, 0, 0), -- 933
					1.3, -- 933
					toColor(PALETTE.amber, 210 * k) -- 933
				) -- 933
				fgGlow:drawRing( -- 934
					Vec2(tx, ty), -- 934
					math.max(1, r2 - 1.2), -- 934
					r2, -- 934
					Color(0, 0, 0, 0), -- 934
					1, -- 934
					toColor(PALETTE.amberCore, 175 * k) -- 934
				) -- 934
			elseif fx.effect == "light" then -- 934
				fgGlow:drawSegment( -- 937
					Vec2(ox, oy), -- 937
					Vec2(tx, ty), -- 937
					5 * k, -- 937
					toColor(PALETTE.amber, 68 * k) -- 937
				) -- 937
				fgGlow:drawSegment( -- 938
					Vec2(ox, oy), -- 938
					Vec2(tx, ty), -- 938
					1.8 * k, -- 938
					toColor(PALETTE.amberCore, 185 * k) -- 938
				) -- 938
				fillRadialGlow( -- 939
					fgGlow, -- 939
					tx, -- 939
					ty, -- 939
					cam:len(42 * (0.6 + prog * 0.4)), -- 939
					cam:len(34), -- 939
					toColor(PALETTE.amberCore, 118 * k), -- 939
					Color(244, 234, 214, 0), -- 939
					16 -- 939
				) -- 939
			end -- 939
			i = i + 1 -- 913
		end -- 913
	end -- 913
end -- 902
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 945
	local rs = ctx.view.reloadSession -- 952
	local active = rs.active -- 953
	local retracting = not active and self.retractAnimT > 0.01 -- 954
	if not active and not retracting then -- 954
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 954
			self:drawArmedEffectBadge( -- 958
				uiDraw, -- 958
				uiInkDraw, -- 958
				uiArt, -- 958
				ctx, -- 958
				rs.nextEffect -- 958
			) -- 958
		end -- 958
		return false -- 960
	end -- 960
	local cx = self.panelCx -- 963
	local cy = self.panelCy -- 964
	local pw = self.panelW -- 965
	local ph = self.panelH -- 966
	local x0 = cx - pw * 0.5 -- 967
	local y0 = cy - ph * 0.5 -- 968
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 970
		0, -- 972
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 972
	) -- 972
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 973
	local px = cx + shakeX -- 976
	if active then -- 976
		uiDraw:drawRect( -- 980
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 980
			Color( -- 980
				10, -- 980
				13, -- 980
				20, -- 980
				math.floor(54 * appear + 0.5) -- 980
			) -- 980
		) -- 980
	end -- 980
	drawSilkVeil( -- 984
		uiDraw, -- 984
		uiArt, -- 984
		"rw_outer_veil", -- 984
		px, -- 984
		cy, -- 984
		pw + 34, -- 984
		ph + 28, -- 984
		PALETTE.inkWash, -- 984
		0.72 * appear, -- 984
		-2 -- 984
	) -- 984
	if not uiArt:tryPlace( -- 984
		"ink_song_paper", -- 985
		"rw_paper", -- 985
		px, -- 985
		cy, -- 985
		pw, -- 985
		ph, -- 985
		{opacity = 0.94 * appear, layer = 1} -- 985
	) then -- 985
		uiDraw:drawRoundedRect( -- 986
			Rect(x0 + shakeX, y0, pw, ph), -- 987
			6, -- 988
			toColor(PALETTE.xuanPaper, 240 * appear), -- 989
			1.2, -- 990
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 991
		) -- 991
	end -- 991
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 994
	drawFiligreeCorners( -- 995
		uiInkDraw, -- 995
		uiArt, -- 995
		"rw_frame", -- 995
		x0 + shakeX + 8, -- 995
		y0 + 8, -- 995
		pw - 16, -- 995
		ph - 16, -- 995
		frameCol, -- 995
		0.72 * appear, -- 995
		22, -- 995
		true, -- 995
		2 -- 995
	) -- 995
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 998
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1001
	local effAccent = self:effectInkColor(previewEffect) -- 1004
	local headY = y0 + ph - 32 -- 1006
	____exports.drawReloadPatternGlyph( -- 1007
		uiInkDraw, -- 1007
		px - 52, -- 1007
		headY, -- 1007
		11, -- 1007
		previewEffect, -- 1007
		effAccent, -- 1007
		appear -- 1007
	) -- 1007
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1008
	ctx.texts:put( -- 1011
		"sm", -- 1012
		titleText, -- 1013
		px - 32, -- 1014
		headY, -- 1015
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1016
		0, -- 1017
		0.5, -- 1018
		"Left", -- 1019
		1.6, -- 1020
		0.96 * appear, -- 1021
		0 -- 1022
	) -- 1022
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1022
		local canReset = #activePath > 1 -- 1025
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1026
		uiInkDraw:drawRect( -- 1027
			rb, -- 1028
			Color( -- 1029
				32, -- 1029
				30, -- 1029
				32, -- 1029
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1029
			), -- 1029
			0.85, -- 1030
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1031
		) -- 1031
		ctx.texts:put( -- 1033
			"xs", -- 1034
			"重画", -- 1035
			rb.x + rb.width * 0.5, -- 1036
			rb.y + rb.height * 0.5, -- 1037
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1038
			0.5, -- 1039
			0.5, -- 1040
			"Center", -- 1041
			1, -- 1042
			(canReset and 0.94 or 0.52) * appear, -- 1043
			0 -- 1044
		) -- 1044
	end -- 1044
	drawHairline( -- 1047
		uiInkDraw, -- 1047
		uiArt, -- 1047
		"rw_head_line", -- 1047
		px, -- 1047
		headY - 18, -- 1047
		pw - 42, -- 1047
		PALETTE.xuanInkSub, -- 1047
		0.45 * appear, -- 1047
		false, -- 1047
		2 -- 1047
	) -- 1047
	local idx = 0 -- 1050
	do -- 1050
		idx = 0 -- 1051
		while idx < 3 do -- 1051
			local hA = self:getNodeUiPos(idx * 3) -- 1052
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1053
			uiInkDraw:drawSegment( -- 1054
				Vec2(hA.x + shakeX, hA.y), -- 1054
				Vec2(hB.x + shakeX, hB.y), -- 1054
				0.75, -- 1054
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1054
			) -- 1054
			local vA = self:getNodeUiPos(idx) -- 1055
			local vB = self:getNodeUiPos(6 + idx) -- 1056
			uiInkDraw:drawSegment( -- 1057
				Vec2(vA.x + shakeX, vA.y), -- 1057
				Vec2(vB.x + shakeX, vB.y), -- 1057
				0.75, -- 1057
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1057
			) -- 1057
			idx = idx + 1 -- 1051
		end -- 1051
	end -- 1051
	if #activePath >= 2 then -- 1051
		self:drawPathStrokes( -- 1062
			uiInkDraw, -- 1062
			uiGlow, -- 1062
			activePath, -- 1062
			previewEffect, -- 1062
			effAccent, -- 1062
			shakeX, -- 1062
			appear -- 1062
		) -- 1062
	end -- 1062
	if active and self.dragging and #activePath >= 1 then -- 1062
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1067
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1068
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1069
		uiInkDraw:drawSegment( -- 1070
			Vec2(tail.x + shakeX, tail.y), -- 1070
			Vec2(mx, my), -- 1070
			1.4, -- 1070
			toColor(effAccent, 150 * appear) -- 1070
		) -- 1070
		uiInkDraw:drawDot( -- 1071
			Vec2(mx, my), -- 1071
			3, -- 1071
			toColor(effAccent, 210 * appear) -- 1071
		) -- 1071
	end -- 1071
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1075
	do -- 1075
		idx = 0 -- 1076
		while idx < #____exports.RELOAD_GRID do -- 1076
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1077
			local pos = self:getNodeUiPos(idx) -- 1078
			local nx = pos.x + shakeX -- 1079
			local ny = pos.y -- 1080
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1081
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1082
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1083
			self:drawGridNode( -- 1084
				uiInkDraw, -- 1084
				uiGlow, -- 1084
				spec, -- 1084
				nx, -- 1084
				ny, -- 1084
				inPath, -- 1084
				isValidNext, -- 1084
				isKbFocus, -- 1084
				effAccent, -- 1084
				appear -- 1084
			) -- 1084
			idx = idx + 1 -- 1076
		end -- 1076
	end -- 1076
	self:drawChildFinger( -- 1088
		uiInkDraw, -- 1088
		uiGlow, -- 1088
		active, -- 1088
		activePath, -- 1088
		shakeX, -- 1088
		appear -- 1088
	) -- 1088
	local barW = pw - 52 -- 1091
	local barX = px - barW * 0.5 -- 1092
	local barY = y0 + 28 -- 1093
	local remainFrac = active and math.max( -- 1094
		0, -- 1095
		math.min( -- 1095
			1, -- 1095
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1095
		) -- 1095
	) or (self.settledTimedOut and 0 or 1) -- 1095
	local urgent = active and remainFrac < 0.25 -- 1097
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1098
	uiInkDraw:drawSegment( -- 1099
		Vec2(barX, barY), -- 1099
		Vec2(barX + barW, barY), -- 1099
		1.4, -- 1099
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1099
	) -- 1099
	if remainFrac > 0.005 then -- 1099
		uiInkDraw:drawSegment( -- 1101
			Vec2(barX, barY), -- 1101
			Vec2(barX + barW * remainFrac, barY), -- 1101
			3, -- 1101
			toColor(barCol, 225 * appear) -- 1101
		) -- 1101
	end -- 1101
	local tTick = 1 -- 1104
	do -- 1104
		tTick = 1 -- 1105
		while tTick <= 3 do -- 1105
			local tx = barX + barW * (tTick / 4) -- 1106
			uiInkDraw:drawSegment( -- 1107
				Vec2(tx, barY - 3.5), -- 1107
				Vec2(tx, barY + 3.5), -- 1107
				0.9, -- 1107
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1107
			) -- 1107
			tTick = tTick + 1 -- 1105
		end -- 1105
	end -- 1105
	if active and ctx.view.assistHintsEnabled then -- 1105
		local mode = ctx.input.inputMode -- 1112
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1113
		ctx.texts:put( -- 1118
			"xs", -- 1119
			hint, -- 1120
			px, -- 1121
			y0 + 13, -- 1122
			toColor(PALETTE.xuanInkSub), -- 1123
			0.5, -- 1124
			0.5, -- 1125
			"Center", -- 1126
			0.6, -- 1127
			0.82 * appear, -- 1128
			0 -- 1129
		) -- 1129
	end -- 1129
	return active -- 1133
end -- 945
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1136
	if effect == "echo" then -- 1136
		return PALETTE.rouge -- 1138
	end -- 1138
	if effect == "light" then -- 1138
		return PALETTE.amberDim -- 1141
	end -- 1141
	if effect == "knockback" then -- 1141
		return PALETTE.xuanInk -- 1144
	end -- 1144
	return PALETTE.xuanInkSub -- 1146
end -- 1136
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1149
	local i = 0 -- 1158
	do -- 1158
		i = 0 -- 1159
		while i < #path - 1 do -- 1159
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1160
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1161
			local ax = p0.x + shakeX -- 1162
			local ay = p0.y -- 1163
			local bx = p1.x + shakeX -- 1164
			local by = p1.y -- 1165
			if effect == "echo" then -- 1165
				local dx = bx - ax -- 1169
				local dy = by - ay -- 1170
				local len = math.max( -- 1171
					1, -- 1171
					math.sqrt(dx * dx + dy * dy) -- 1171
				) -- 1171
				local nx = -dy / len * 2.2 -- 1172
				local ny = dx / len * 2.2 -- 1173
				uiInkDraw:drawSegment( -- 1174
					Vec2(ax + nx, ay + ny), -- 1174
					Vec2(bx + nx, by + ny), -- 1174
					1.35, -- 1174
					toColor(col, 220 * appear) -- 1174
				) -- 1174
				uiInkDraw:drawSegment( -- 1175
					Vec2(ax - nx, ay - ny), -- 1175
					Vec2(bx - nx, by - ny), -- 1175
					1.35, -- 1175
					toColor(col, 220 * appear) -- 1175
				) -- 1175
			elseif effect == "light" then -- 1175
				uiInkDraw:drawSegment( -- 1178
					Vec2(ax, ay), -- 1178
					Vec2(bx, by), -- 1178
					3.1, -- 1178
					toColor(PALETTE.xuanInk, 195 * appear) -- 1178
				) -- 1178
				uiInkDraw:drawSegment( -- 1179
					Vec2(ax, ay), -- 1179
					Vec2(bx, by), -- 1179
					1.3, -- 1179
					toColor(PALETTE.amberCore, 235 * appear) -- 1179
				) -- 1179
				uiGlow:drawSegment( -- 1180
					Vec2(ax, ay), -- 1180
					Vec2(bx, by), -- 1180
					3.2, -- 1180
					toColor(PALETTE.amber, 55 * appear) -- 1180
				) -- 1180
			else -- 1180
				uiInkDraw:drawSegment( -- 1183
					Vec2(ax, ay), -- 1183
					Vec2(bx, by), -- 1183
					2.8, -- 1183
					toColor(col, 230 * appear) -- 1183
				) -- 1183
			end -- 1183
			i = i + 1 -- 1159
		end -- 1159
	end -- 1159
end -- 1149
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1188
	local baseR = spec.kind == "plain" and 11 or 15 -- 1200
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1201
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1202
	if isKbFocus then -- 1202
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1206
		uiInkDraw:drawRing( -- 1207
			Vec2(nx, ny), -- 1207
			baseR + 4.5, -- 1207
			baseR + 6.2, -- 1207
			Color(0, 0, 0, 0), -- 1207
			1.1, -- 1207
			toColor(focusCol, 215 * appear) -- 1207
		) -- 1207
	end -- 1207
	if spec.kind == "bell" then -- 1207
		if inPath then -- 1207
			uiInkDraw:drawCircle( -- 1213
				Vec2(nx, ny), -- 1213
				baseR + 1, -- 1213
				toColor(PALETTE.rouge, 36 * appear) -- 1213
			) -- 1213
			uiGlow:drawRing( -- 1214
				Vec2(nx, ny), -- 1214
				baseR + 2, -- 1214
				baseR + 5, -- 1214
				Color(0, 0, 0, 0), -- 1214
				1.2, -- 1214
				toColor(PALETTE.rouge, 110 * appear) -- 1214
			) -- 1214
		end -- 1214
		uiInkDraw:drawRing( -- 1216
			Vec2(nx, ny), -- 1216
			baseR - 1.2, -- 1216
			baseR, -- 1216
			Color(0, 0, 0, 0), -- 1216
			1.1, -- 1216
			toColor(strokeCol, strokeAlpha * appear) -- 1216
		) -- 1216
		____exports.drawReloadPatternGlyph( -- 1217
			uiInkDraw, -- 1217
			nx, -- 1217
			ny, -- 1217
			9.5, -- 1217
			"echo", -- 1217
			inPath and PALETTE.rouge or strokeCol, -- 1217
			appear -- 1217
		) -- 1217
		return -- 1218
	end -- 1218
	if spec.kind == "lamp" then -- 1218
		if inPath then -- 1218
			uiInkDraw:drawCircle( -- 1224
				Vec2(nx, ny), -- 1224
				baseR + 1, -- 1224
				toColor(PALETTE.amber, 56 * appear) -- 1224
			) -- 1224
			fillRadialGlow( -- 1225
				uiGlow, -- 1225
				nx, -- 1225
				ny, -- 1225
				22, -- 1225
				22, -- 1225
				toColor(PALETTE.amberCore, 72 * appear), -- 1225
				Color(244, 234, 214, 0), -- 1225
				12 -- 1225
			) -- 1225
		end -- 1225
		uiInkDraw:drawRing( -- 1227
			Vec2(nx, ny), -- 1227
			baseR - 1.2, -- 1227
			baseR, -- 1227
			Color(0, 0, 0, 0), -- 1227
			1.1, -- 1227
			toColor(strokeCol, strokeAlpha * appear) -- 1227
		) -- 1227
		____exports.drawReloadPatternGlyph( -- 1228
			uiInkDraw, -- 1228
			nx, -- 1228
			ny, -- 1228
			9.5, -- 1228
			"light", -- 1228
			inPath and PALETTE.xuanInk or strokeCol, -- 1228
			appear -- 1228
		) -- 1228
		return -- 1229
	end -- 1229
	if spec.kind == "target" then -- 1229
		drawDiamond( -- 1234
			uiInkDraw, -- 1235
			nx, -- 1236
			ny, -- 1237
			baseR, -- 1238
			baseR, -- 1239
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1240
			1.4, -- 1241
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1242
		) -- 1242
		drawDiamond( -- 1244
			uiInkDraw, -- 1245
			nx, -- 1246
			ny, -- 1247
			baseR * 0.56, -- 1248
			baseR * 0.56, -- 1249
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1250
		) -- 1250
		return -- 1252
	end -- 1252
	if spec.kind == "start" then -- 1252
		uiInkDraw:drawRing( -- 1257
			Vec2(nx, ny), -- 1257
			baseR - 2.2, -- 1257
			baseR, -- 1257
			Color(0, 0, 0, 0), -- 1257
			1.2, -- 1257
			toColor(PALETTE.rouge, 220 * appear) -- 1257
		) -- 1257
		uiInkDraw:drawCircle( -- 1258
			Vec2(nx, ny), -- 1258
			4.8, -- 1258
			toColor(PALETTE.xuanInk, 235 * appear) -- 1258
		) -- 1258
		return -- 1259
	end -- 1259
	if inPath then -- 1259
		uiInkDraw:drawCircle( -- 1264
			Vec2(nx, ny), -- 1264
			6.2, -- 1264
			toColor(effAccent, 235 * appear) -- 1264
		) -- 1264
		uiInkDraw:drawRing( -- 1265
			Vec2(nx, ny), -- 1265
			9.5, -- 1265
			10.8, -- 1265
			Color(0, 0, 0, 0), -- 1265
			1, -- 1265
			toColor(effAccent, 165 * appear) -- 1265
		) -- 1265
	else -- 1265
		uiInkDraw:drawRing( -- 1267
			Vec2(nx, ny), -- 1267
			5.6, -- 1267
			7, -- 1267
			Color(0, 0, 0, 0), -- 1267
			1, -- 1267
			toColor(strokeCol, strokeAlpha * appear) -- 1267
		) -- 1267
	end -- 1267
end -- 1188
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1272
	local fx = 0 -- 1280
	local fy = 0 -- 1281
	if active then -- 1281
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1284
		local pos = self:getNodeUiPos(tipNode) -- 1285
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1286
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1287
		fy = pos.y - 6 - tapPulse -- 1288
		if #path <= 1 then -- 1288
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1291
			uiInkDraw:drawRing( -- 1292
				Vec2(pos.x + shakeX, pos.y), -- 1292
				ringR - 1, -- 1292
				ringR, -- 1292
				Color(0, 0, 0, 0), -- 1292
				1, -- 1292
				toColor(PALETTE.rouge, 130 * appear) -- 1292
			) -- 1292
		end -- 1292
	elseif self.retractAnimT > 0 and #path > 0 then -- 1292
		local prog = math.max( -- 1296
			0, -- 1296
			math.min( -- 1296
				1, -- 1296
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1296
			) -- 1296
		) -- 1296
		local revFloat = (1 - prog) * (#path - 1) -- 1297
		local idxA = math.max( -- 1298
			0, -- 1298
			math.min( -- 1298
				#path - 1, -- 1298
				math.floor(revFloat) -- 1298
			) -- 1298
		) -- 1298
		local idxB = math.max( -- 1299
			0, -- 1299
			math.min(#path - 1, idxA + 1) -- 1299
		) -- 1299
		local frac = revFloat - idxA -- 1300
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1301
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1302
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1303
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1304
	else -- 1304
		return -- 1306
	end -- 1306
	local a255 = math.floor(240 * appear + 0.5) -- 1310
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1311
	uiInkDraw:drawPolygon( -- 1312
		{ -- 1312
			Vec2(fx - 30, fy - 20), -- 1313
			Vec2(fx - 22, fy - 28), -- 1314
			Vec2(fx - 11, fy - 14), -- 1315
			Vec2(fx - 17, fy - 9) -- 1316
		}, -- 1316
		Color(164, 78, 54, a255), -- 1317
		1, -- 1317
		inkCol -- 1317
	) -- 1317
	uiInkDraw:drawSegment( -- 1319
		Vec2(fx - 16, fy - 10), -- 1319
		Vec2(fx - 11, fy - 15), -- 1319
		2, -- 1319
		Color(204, 174, 122, a255) -- 1319
	) -- 1319
	uiInkDraw:drawCircle( -- 1321
		Vec2(fx - 9, fy - 8), -- 1321
		4.8, -- 1321
		Color(238, 212, 182, a255) -- 1321
	) -- 1321
	uiInkDraw:drawSegment( -- 1322
		Vec2(fx - 7, fy - 6), -- 1322
		Vec2(fx, fy), -- 1322
		2.5, -- 1322
		Color(244, 222, 196, a255) -- 1322
	) -- 1322
	uiInkDraw:drawRing( -- 1323
		Vec2(fx, fy), -- 1323
		2, -- 1323
		3, -- 1323
		Color(0, 0, 0, 0), -- 1323
		0.9, -- 1323
		inkCol -- 1323
	) -- 1323
	uiGlow:drawDot( -- 1324
		Vec2(fx, fy), -- 1324
		3.4, -- 1324
		toColor(PALETTE.amberCore, 80 * appear) -- 1324
	) -- 1324
end -- 1272
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1328
	local bx = 46 -- 1335
	local by = ctx.uiH - 112 -- 1336
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1337
	drawSilkVeil( -- 1338
		uiDraw, -- 1338
		uiArt, -- 1338
		"rw_armed_veil", -- 1338
		bx + 54, -- 1338
		by, -- 1338
		142, -- 1338
		30, -- 1338
		PALETTE.inkWash, -- 1338
		0.72, -- 1338
		-1 -- 1338
	) -- 1338
	____exports.drawReloadPatternGlyph( -- 1339
		uiInkDraw, -- 1339
		bx + 12, -- 1339
		by, -- 1339
		9, -- 1339
		effect, -- 1339
		col, -- 1339
		0.96 -- 1339
	) -- 1339
	drawBlossomDot( -- 1340
		uiInkDraw, -- 1340
		uiArt, -- 1340
		"rw_armed_dot", -- 1340
		bx + 28, -- 1340
		by, -- 1340
		6, -- 1340
		col, -- 1340
		0.85, -- 1340
		3 -- 1340
	) -- 1340
	ctx.texts:put( -- 1341
		"xs", -- 1341
		____exports.reloadEffectShortLabel(effect), -- 1341
		bx + 38, -- 1341
		by, -- 1341
		toColor(PALETTE.textBright), -- 1341
		0, -- 1341
		0.5, -- 1341
		"Left", -- 1341
		1, -- 1341
		0.94, -- 1341
		0.08 -- 1341
	) -- 1341
end -- 1328
function ____exports.createReloadWheelPlugin(contract) -- 1345
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1346
end -- 1345
return ____exports -- 1345