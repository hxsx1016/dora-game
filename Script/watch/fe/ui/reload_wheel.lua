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
	local stepIdx = math.max( -- 797
		1, -- 797
		math.min(6, #self.lastKnownPath) -- 797
	) -- 797
	local pitched = ("assets/audio/combat/reload_node_" .. tostring(stepIdx)) .. ".wav" -- 798
	local nodePath = Content:exist(pitched) and pitched or "assets/audio/combat/reload_node.wav" -- 799
	ctx.audio:playOnce( -- 800
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 801
		"sfx", -- 802
		nodePath, -- 803
		0.78, -- 804
		"reload:node:" .. tostring(node), -- 805
		ctx.p.ticks -- 806
	) -- 806
end -- 787
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 810
	if flashError then -- 810
		self.localInvalidFlash = 0.36 -- 812
	end -- 812
	self.kbCursor = ____exports.RELOAD_START_NODE -- 814
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 815
	if #activePath > 1 then -- 815
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 818
	end -- 818
	if flashError then -- 818
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 821
		ctx.audio:playOnce( -- 822
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 823
			"sfx", -- 824
			"assets/audio/combat/reload_invalid.wav", -- 825
			0.72, -- 826
			"reload:invalid", -- 827
			ctx.p.ticks -- 828
		) -- 828
	end -- 828
end -- 810
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 833
	if hitR == nil then -- 833
		hitR = self.hitRadius -- 833
	end -- 833
	local r2 = hitR * hitR -- 834
	local i = 0 -- 835
	do -- 835
		i = 0 -- 836
		while i < #____exports.RELOAD_GRID do -- 836
			local pos = self:getNodeUiPos(i) -- 837
			local dx = uiX - pos.x -- 838
			local dy = uiY - pos.y -- 839
			if dx * dx + dy * dy <= r2 then -- 839
				return i -- 841
			end -- 841
			i = i + 1 -- 836
		end -- 836
	end -- 836
	return -1 -- 844
end -- 833
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 847
	local p = ctx.p -- 848
	local triggered = false -- 849
	local i = 0 -- 850
	do -- 850
		i = 0 -- 851
		while i < #ctx.events.rawEvents do -- 851
			local e = ctx.events.rawEvents[i + 1] -- 852
			if e.name == "reloadApplied" then -- 852
				local rawEff = e.data.effect -- 854
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 855
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 858
				self:spawnAppliedVfx(eff, p, ex) -- 859
				triggered = true -- 860
			end -- 860
			i = i + 1 -- 851
		end -- 851
	end -- 851
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 851
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 865
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 866
	end -- 866
end -- 847
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 870
	local originX = p.player.x + p.player.facing * 18 -- 871
	local originY = p.player.y + p.player.depth + p.player.h * 0.62 -- 872
	local targetY = p.player.y + p.player.depth + 46 -- 873
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 874
	local ____self_appliedVfx_31 = self.appliedVfx -- 874
	____self_appliedVfx_31[#____self_appliedVfx_31 + 1] = { -- 875
		effect = effect, -- 876
		originX = originX, -- 877
		originY = originY, -- 878
		targetX = targetX, -- 879
		targetY = targetY, -- 880
		facing = p.player.facing >= 0 and 1 or -1, -- 881
		life = maxLife, -- 882
		maxLife = maxLife -- 883
	} -- 883
end -- 870
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 887
	if wdt <= 0 or #self.appliedVfx == 0 then -- 887
		return -- 889
	end -- 889
	local w = 0 -- 891
	local i = 0 -- 892
	do -- 892
		i = 0 -- 893
		while i < #self.appliedVfx do -- 893
			local fx = self.appliedVfx[i + 1] -- 894
			fx.life = fx.life - wdt -- 895
			if fx.life > 0 then -- 895
				self.appliedVfx[w + 1] = fx -- 897
				w = w + 1 -- 898
			end -- 898
			i = i + 1 -- 893
		end -- 893
	end -- 893
	__TS__ArraySetLength(self.appliedVfx, w) -- 893
end -- 887
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 905
	if #self.appliedVfx == 0 then -- 905
		return -- 912
	end -- 912
	local cam = ctx.cam -- 914
	local i = 0 -- 915
	do -- 915
		i = 0 -- 916
		while i < #self.appliedVfx do -- 916
			local fx = self.appliedVfx[i + 1] -- 917
			local k = math.max( -- 918
				0, -- 918
				math.min(1, fx.life / fx.maxLife) -- 918
			) -- 918
			local prog = 1 - k -- 919
			local ox = cam:sx(fx.originX) -- 920
			local oy = cam:sy(fx.originY) -- 921
			local tx = cam:sx(fx.targetX) -- 922
			local ty = cam:sy(fx.targetY) -- 923
			if fx.effect == "knockback" then -- 923
				local r = cam:len(12 + prog * 34) -- 927
				local startA = fx.facing >= 0 and -48 or 132 -- 928
				local endA = fx.facing >= 0 and 48 or 228 -- 929
				fgGlow:drawArc( -- 930
					Vec2(tx, ty), -- 930
					r, -- 930
					startA, -- 930
					endA, -- 930
					2.4 * k, -- 930
					toColor(PALETTE.moonPale, 210 * k) -- 930
				) -- 930
				fgDraw:drawArc( -- 931
					Vec2( -- 931
						tx - fx.facing * cam:len(6), -- 931
						ty -- 931
					), -- 931
					r * 0.72, -- 931
					startA, -- 931
					endA, -- 931
					1.5 * k, -- 931
					toColor(PALETTE.silkLine, 165 * k) -- 931
				) -- 931
			elseif fx.effect == "echo" then -- 931
				local r1 = cam:len(10 + prog * 64) -- 934
				local r2 = cam:len(6 + prog * 40) -- 935
				fgGlow:drawRing( -- 936
					Vec2(tx, ty), -- 936
					math.max(1, r1 - 1.6), -- 936
					r1, -- 936
					Color(0, 0, 0, 0), -- 936
					1.3, -- 936
					toColor(PALETTE.amber, 210 * k) -- 936
				) -- 936
				fgGlow:drawRing( -- 937
					Vec2(tx, ty), -- 937
					math.max(1, r2 - 1.2), -- 937
					r2, -- 937
					Color(0, 0, 0, 0), -- 937
					1, -- 937
					toColor(PALETTE.amberCore, 175 * k) -- 937
				) -- 937
			elseif fx.effect == "light" then -- 937
				fgGlow:drawSegment( -- 940
					Vec2(ox, oy), -- 940
					Vec2(tx, ty), -- 940
					5 * k, -- 940
					toColor(PALETTE.amber, 68 * k) -- 940
				) -- 940
				fgGlow:drawSegment( -- 941
					Vec2(ox, oy), -- 941
					Vec2(tx, ty), -- 941
					1.8 * k, -- 941
					toColor(PALETTE.amberCore, 185 * k) -- 941
				) -- 941
				fillRadialGlow( -- 942
					fgGlow, -- 942
					tx, -- 942
					ty, -- 942
					cam:len(42 * (0.6 + prog * 0.4)), -- 942
					cam:len(34), -- 942
					toColor(PALETTE.amberCore, 118 * k), -- 942
					Color(244, 234, 214, 0), -- 942
					16 -- 942
				) -- 942
			end -- 942
			i = i + 1 -- 916
		end -- 916
	end -- 916
end -- 905
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 948
	local rs = ctx.view.reloadSession -- 955
	local active = rs.active -- 956
	local retracting = not active and self.retractAnimT > 0.01 -- 957
	if not active and not retracting then -- 957
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 957
			self:drawArmedEffectBadge( -- 961
				uiDraw, -- 961
				uiInkDraw, -- 961
				uiArt, -- 961
				ctx, -- 961
				rs.nextEffect -- 961
			) -- 961
		end -- 961
		return false -- 963
	end -- 963
	local cx = self.panelCx -- 966
	local cy = self.panelCy -- 967
	local pw = self.panelW -- 968
	local ph = self.panelH -- 969
	local x0 = cx - pw * 0.5 -- 970
	local y0 = cy - ph * 0.5 -- 971
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 973
		0, -- 975
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 975
	) -- 975
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 976
	local px = cx + shakeX -- 979
	if active then -- 979
		uiDraw:drawRect( -- 983
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 983
			Color( -- 983
				10, -- 983
				13, -- 983
				20, -- 983
				math.floor(54 * appear + 0.5) -- 983
			) -- 983
		) -- 983
	end -- 983
	drawSilkVeil( -- 987
		uiDraw, -- 987
		uiArt, -- 987
		"rw_outer_veil", -- 987
		px, -- 987
		cy, -- 987
		pw + 34, -- 987
		ph + 28, -- 987
		PALETTE.inkWash, -- 987
		0.72 * appear, -- 987
		-2 -- 987
	) -- 987
	if not uiArt:tryPlace( -- 987
		"ink_song_paper", -- 988
		"rw_paper", -- 988
		px, -- 988
		cy, -- 988
		pw, -- 988
		ph, -- 988
		{opacity = 0.94 * appear, layer = 1} -- 988
	) then -- 988
		uiDraw:drawRoundedRect( -- 989
			Rect(x0 + shakeX, y0, pw, ph), -- 990
			6, -- 991
			toColor(PALETTE.xuanPaper, 240 * appear), -- 992
			1.2, -- 993
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 994
		) -- 994
	end -- 994
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 997
	drawFiligreeCorners( -- 998
		uiInkDraw, -- 998
		uiArt, -- 998
		"rw_frame", -- 998
		x0 + shakeX + 8, -- 998
		y0 + 8, -- 998
		pw - 16, -- 998
		ph - 16, -- 998
		frameCol, -- 998
		0.72 * appear, -- 998
		22, -- 998
		true, -- 998
		2 -- 998
	) -- 998
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1001
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1004
	local effAccent = self:effectInkColor(previewEffect) -- 1007
	local headY = y0 + ph - 32 -- 1009
	____exports.drawReloadPatternGlyph( -- 1010
		uiInkDraw, -- 1010
		px - 52, -- 1010
		headY, -- 1010
		11, -- 1010
		previewEffect, -- 1010
		effAccent, -- 1010
		appear -- 1010
	) -- 1010
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1011
	ctx.texts:put( -- 1014
		"sm", -- 1015
		titleText, -- 1016
		px - 32, -- 1017
		headY, -- 1018
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1019
		0, -- 1020
		0.5, -- 1021
		"Left", -- 1022
		1.6, -- 1023
		0.96 * appear, -- 1024
		0 -- 1025
	) -- 1025
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1025
		local canReset = #activePath > 1 -- 1028
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1029
		uiInkDraw:drawRect( -- 1030
			rb, -- 1031
			Color( -- 1032
				32, -- 1032
				30, -- 1032
				32, -- 1032
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1032
			), -- 1032
			0.85, -- 1033
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1034
		) -- 1034
		ctx.texts:put( -- 1036
			"xs", -- 1037
			"重画", -- 1038
			rb.x + rb.width * 0.5, -- 1039
			rb.y + rb.height * 0.5, -- 1040
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1041
			0.5, -- 1042
			0.5, -- 1043
			"Center", -- 1044
			1, -- 1045
			(canReset and 0.94 or 0.52) * appear, -- 1046
			0 -- 1047
		) -- 1047
	end -- 1047
	drawHairline( -- 1050
		uiInkDraw, -- 1050
		uiArt, -- 1050
		"rw_head_line", -- 1050
		px, -- 1050
		headY - 18, -- 1050
		pw - 42, -- 1050
		PALETTE.xuanInkSub, -- 1050
		0.45 * appear, -- 1050
		false, -- 1050
		2 -- 1050
	) -- 1050
	local idx = 0 -- 1053
	do -- 1053
		idx = 0 -- 1054
		while idx < 3 do -- 1054
			local hA = self:getNodeUiPos(idx * 3) -- 1055
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1056
			uiInkDraw:drawSegment( -- 1057
				Vec2(hA.x + shakeX, hA.y), -- 1057
				Vec2(hB.x + shakeX, hB.y), -- 1057
				0.75, -- 1057
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1057
			) -- 1057
			local vA = self:getNodeUiPos(idx) -- 1058
			local vB = self:getNodeUiPos(6 + idx) -- 1059
			uiInkDraw:drawSegment( -- 1060
				Vec2(vA.x + shakeX, vA.y), -- 1060
				Vec2(vB.x + shakeX, vB.y), -- 1060
				0.75, -- 1060
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1060
			) -- 1060
			idx = idx + 1 -- 1054
		end -- 1054
	end -- 1054
	if #activePath >= 2 then -- 1054
		self:drawPathStrokes( -- 1065
			uiInkDraw, -- 1065
			uiGlow, -- 1065
			activePath, -- 1065
			previewEffect, -- 1065
			effAccent, -- 1065
			shakeX, -- 1065
			appear -- 1065
		) -- 1065
	end -- 1065
	if active and self.dragging and #activePath >= 1 then -- 1065
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1070
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1071
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1072
		uiInkDraw:drawSegment( -- 1073
			Vec2(tail.x + shakeX, tail.y), -- 1073
			Vec2(mx, my), -- 1073
			1.4, -- 1073
			toColor(effAccent, 150 * appear) -- 1073
		) -- 1073
		uiInkDraw:drawDot( -- 1074
			Vec2(mx, my), -- 1074
			3, -- 1074
			toColor(effAccent, 210 * appear) -- 1074
		) -- 1074
	end -- 1074
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1078
	do -- 1078
		idx = 0 -- 1079
		while idx < #____exports.RELOAD_GRID do -- 1079
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1080
			local pos = self:getNodeUiPos(idx) -- 1081
			local nx = pos.x + shakeX -- 1082
			local ny = pos.y -- 1083
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1084
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1085
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1086
			self:drawGridNode( -- 1087
				uiInkDraw, -- 1087
				uiGlow, -- 1087
				spec, -- 1087
				nx, -- 1087
				ny, -- 1087
				inPath, -- 1087
				isValidNext, -- 1087
				isKbFocus, -- 1087
				effAccent, -- 1087
				appear -- 1087
			) -- 1087
			idx = idx + 1 -- 1079
		end -- 1079
	end -- 1079
	self:drawChildFinger( -- 1091
		uiInkDraw, -- 1091
		uiGlow, -- 1091
		active, -- 1091
		activePath, -- 1091
		shakeX, -- 1091
		appear -- 1091
	) -- 1091
	local barW = pw - 52 -- 1094
	local barX = px - barW * 0.5 -- 1095
	local barY = y0 + 28 -- 1096
	local remainFrac = active and math.max( -- 1097
		0, -- 1098
		math.min( -- 1098
			1, -- 1098
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1098
		) -- 1098
	) or (self.settledTimedOut and 0 or 1) -- 1098
	local urgent = active and remainFrac < 0.25 -- 1100
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1101
	uiInkDraw:drawSegment( -- 1102
		Vec2(barX, barY), -- 1102
		Vec2(barX + barW, barY), -- 1102
		1.4, -- 1102
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1102
	) -- 1102
	if remainFrac > 0.005 then -- 1102
		uiInkDraw:drawSegment( -- 1104
			Vec2(barX, barY), -- 1104
			Vec2(barX + barW * remainFrac, barY), -- 1104
			3, -- 1104
			toColor(barCol, 225 * appear) -- 1104
		) -- 1104
	end -- 1104
	local tTick = 1 -- 1107
	do -- 1107
		tTick = 1 -- 1108
		while tTick <= 3 do -- 1108
			local tx = barX + barW * (tTick / 4) -- 1109
			uiInkDraw:drawSegment( -- 1110
				Vec2(tx, barY - 3.5), -- 1110
				Vec2(tx, barY + 3.5), -- 1110
				0.9, -- 1110
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1110
			) -- 1110
			tTick = tTick + 1 -- 1108
		end -- 1108
	end -- 1108
	if active and ctx.view.assistHintsEnabled then -- 1108
		local mode = ctx.input.inputMode -- 1115
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1116
		ctx.texts:put( -- 1121
			"xs", -- 1122
			hint, -- 1123
			px, -- 1124
			y0 + 13, -- 1125
			toColor(PALETTE.xuanInkSub), -- 1126
			0.5, -- 1127
			0.5, -- 1128
			"Center", -- 1129
			0.6, -- 1130
			0.82 * appear, -- 1131
			0 -- 1132
		) -- 1132
	end -- 1132
	return active -- 1136
end -- 948
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1139
	if effect == "echo" then -- 1139
		return PALETTE.rouge -- 1141
	end -- 1141
	if effect == "light" then -- 1141
		return PALETTE.amberDim -- 1144
	end -- 1144
	if effect == "knockback" then -- 1144
		return PALETTE.xuanInk -- 1147
	end -- 1147
	return PALETTE.xuanInkSub -- 1149
end -- 1139
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1152
	local i = 0 -- 1161
	do -- 1161
		i = 0 -- 1162
		while i < #path - 1 do -- 1162
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1163
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1164
			local ax = p0.x + shakeX -- 1165
			local ay = p0.y -- 1166
			local bx = p1.x + shakeX -- 1167
			local by = p1.y -- 1168
			if effect == "echo" then -- 1168
				local dx = bx - ax -- 1172
				local dy = by - ay -- 1173
				local len = math.max( -- 1174
					1, -- 1174
					math.sqrt(dx * dx + dy * dy) -- 1174
				) -- 1174
				local nx = -dy / len * 2.2 -- 1175
				local ny = dx / len * 2.2 -- 1176
				uiInkDraw:drawSegment( -- 1177
					Vec2(ax + nx, ay + ny), -- 1177
					Vec2(bx + nx, by + ny), -- 1177
					1.35, -- 1177
					toColor(col, 220 * appear) -- 1177
				) -- 1177
				uiInkDraw:drawSegment( -- 1178
					Vec2(ax - nx, ay - ny), -- 1178
					Vec2(bx - nx, by - ny), -- 1178
					1.35, -- 1178
					toColor(col, 220 * appear) -- 1178
				) -- 1178
			elseif effect == "light" then -- 1178
				uiInkDraw:drawSegment( -- 1181
					Vec2(ax, ay), -- 1181
					Vec2(bx, by), -- 1181
					3.1, -- 1181
					toColor(PALETTE.xuanInk, 195 * appear) -- 1181
				) -- 1181
				uiInkDraw:drawSegment( -- 1182
					Vec2(ax, ay), -- 1182
					Vec2(bx, by), -- 1182
					1.3, -- 1182
					toColor(PALETTE.amberCore, 235 * appear) -- 1182
				) -- 1182
				uiGlow:drawSegment( -- 1183
					Vec2(ax, ay), -- 1183
					Vec2(bx, by), -- 1183
					3.2, -- 1183
					toColor(PALETTE.amber, 55 * appear) -- 1183
				) -- 1183
			else -- 1183
				uiInkDraw:drawSegment( -- 1186
					Vec2(ax, ay), -- 1186
					Vec2(bx, by), -- 1186
					2.8, -- 1186
					toColor(col, 230 * appear) -- 1186
				) -- 1186
			end -- 1186
			i = i + 1 -- 1162
		end -- 1162
	end -- 1162
end -- 1152
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1191
	local baseR = spec.kind == "plain" and 11 or 15 -- 1203
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1204
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1205
	if isKbFocus then -- 1205
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1209
		uiInkDraw:drawRing( -- 1210
			Vec2(nx, ny), -- 1210
			baseR + 4.5, -- 1210
			baseR + 6.2, -- 1210
			Color(0, 0, 0, 0), -- 1210
			1.1, -- 1210
			toColor(focusCol, 215 * appear) -- 1210
		) -- 1210
	end -- 1210
	if spec.kind == "bell" then -- 1210
		if inPath then -- 1210
			uiInkDraw:drawCircle( -- 1216
				Vec2(nx, ny), -- 1216
				baseR + 1, -- 1216
				toColor(PALETTE.rouge, 36 * appear) -- 1216
			) -- 1216
			uiGlow:drawRing( -- 1217
				Vec2(nx, ny), -- 1217
				baseR + 2, -- 1217
				baseR + 5, -- 1217
				Color(0, 0, 0, 0), -- 1217
				1.2, -- 1217
				toColor(PALETTE.rouge, 110 * appear) -- 1217
			) -- 1217
		end -- 1217
		uiInkDraw:drawRing( -- 1219
			Vec2(nx, ny), -- 1219
			baseR - 1.2, -- 1219
			baseR, -- 1219
			Color(0, 0, 0, 0), -- 1219
			1.1, -- 1219
			toColor(strokeCol, strokeAlpha * appear) -- 1219
		) -- 1219
		____exports.drawReloadPatternGlyph( -- 1220
			uiInkDraw, -- 1220
			nx, -- 1220
			ny, -- 1220
			9.5, -- 1220
			"echo", -- 1220
			inPath and PALETTE.rouge or strokeCol, -- 1220
			appear -- 1220
		) -- 1220
		return -- 1221
	end -- 1221
	if spec.kind == "lamp" then -- 1221
		if inPath then -- 1221
			uiInkDraw:drawCircle( -- 1227
				Vec2(nx, ny), -- 1227
				baseR + 1, -- 1227
				toColor(PALETTE.amber, 56 * appear) -- 1227
			) -- 1227
			fillRadialGlow( -- 1228
				uiGlow, -- 1228
				nx, -- 1228
				ny, -- 1228
				22, -- 1228
				22, -- 1228
				toColor(PALETTE.amberCore, 72 * appear), -- 1228
				Color(244, 234, 214, 0), -- 1228
				12 -- 1228
			) -- 1228
		end -- 1228
		uiInkDraw:drawRing( -- 1230
			Vec2(nx, ny), -- 1230
			baseR - 1.2, -- 1230
			baseR, -- 1230
			Color(0, 0, 0, 0), -- 1230
			1.1, -- 1230
			toColor(strokeCol, strokeAlpha * appear) -- 1230
		) -- 1230
		____exports.drawReloadPatternGlyph( -- 1231
			uiInkDraw, -- 1231
			nx, -- 1231
			ny, -- 1231
			9.5, -- 1231
			"light", -- 1231
			inPath and PALETTE.xuanInk or strokeCol, -- 1231
			appear -- 1231
		) -- 1231
		return -- 1232
	end -- 1232
	if spec.kind == "target" then -- 1232
		drawDiamond( -- 1237
			uiInkDraw, -- 1238
			nx, -- 1239
			ny, -- 1240
			baseR, -- 1241
			baseR, -- 1242
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1243
			1.4, -- 1244
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1245
		) -- 1245
		drawDiamond( -- 1247
			uiInkDraw, -- 1248
			nx, -- 1249
			ny, -- 1250
			baseR * 0.56, -- 1251
			baseR * 0.56, -- 1252
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1253
		) -- 1253
		return -- 1255
	end -- 1255
	if spec.kind == "start" then -- 1255
		uiInkDraw:drawRing( -- 1260
			Vec2(nx, ny), -- 1260
			baseR - 2.2, -- 1260
			baseR, -- 1260
			Color(0, 0, 0, 0), -- 1260
			1.2, -- 1260
			toColor(PALETTE.rouge, 220 * appear) -- 1260
		) -- 1260
		uiInkDraw:drawCircle( -- 1261
			Vec2(nx, ny), -- 1261
			4.8, -- 1261
			toColor(PALETTE.xuanInk, 235 * appear) -- 1261
		) -- 1261
		return -- 1262
	end -- 1262
	if inPath then -- 1262
		uiInkDraw:drawCircle( -- 1267
			Vec2(nx, ny), -- 1267
			6.2, -- 1267
			toColor(effAccent, 235 * appear) -- 1267
		) -- 1267
		uiInkDraw:drawRing( -- 1268
			Vec2(nx, ny), -- 1268
			9.5, -- 1268
			10.8, -- 1268
			Color(0, 0, 0, 0), -- 1268
			1, -- 1268
			toColor(effAccent, 165 * appear) -- 1268
		) -- 1268
	else -- 1268
		uiInkDraw:drawRing( -- 1270
			Vec2(nx, ny), -- 1270
			5.6, -- 1270
			7, -- 1270
			Color(0, 0, 0, 0), -- 1270
			1, -- 1270
			toColor(strokeCol, strokeAlpha * appear) -- 1270
		) -- 1270
	end -- 1270
end -- 1191
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1275
	local fx = 0 -- 1283
	local fy = 0 -- 1284
	if active then -- 1284
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1287
		local pos = self:getNodeUiPos(tipNode) -- 1288
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1289
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1290
		fy = pos.y - 6 - tapPulse -- 1291
		if #path <= 1 then -- 1291
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1294
			uiInkDraw:drawRing( -- 1295
				Vec2(pos.x + shakeX, pos.y), -- 1295
				ringR - 1, -- 1295
				ringR, -- 1295
				Color(0, 0, 0, 0), -- 1295
				1, -- 1295
				toColor(PALETTE.rouge, 130 * appear) -- 1295
			) -- 1295
		end -- 1295
	elseif self.retractAnimT > 0 and #path > 0 then -- 1295
		local prog = math.max( -- 1299
			0, -- 1299
			math.min( -- 1299
				1, -- 1299
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1299
			) -- 1299
		) -- 1299
		local revFloat = (1 - prog) * (#path - 1) -- 1300
		local idxA = math.max( -- 1301
			0, -- 1301
			math.min( -- 1301
				#path - 1, -- 1301
				math.floor(revFloat) -- 1301
			) -- 1301
		) -- 1301
		local idxB = math.max( -- 1302
			0, -- 1302
			math.min(#path - 1, idxA + 1) -- 1302
		) -- 1302
		local frac = revFloat - idxA -- 1303
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1304
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1305
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1306
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1307
	else -- 1307
		return -- 1309
	end -- 1309
	local a255 = math.floor(240 * appear + 0.5) -- 1313
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1314
	uiInkDraw:drawPolygon( -- 1315
		{ -- 1315
			Vec2(fx - 30, fy - 20), -- 1316
			Vec2(fx - 22, fy - 28), -- 1317
			Vec2(fx - 11, fy - 14), -- 1318
			Vec2(fx - 17, fy - 9) -- 1319
		}, -- 1319
		Color(164, 78, 54, a255), -- 1320
		1, -- 1320
		inkCol -- 1320
	) -- 1320
	uiInkDraw:drawSegment( -- 1322
		Vec2(fx - 16, fy - 10), -- 1322
		Vec2(fx - 11, fy - 15), -- 1322
		2, -- 1322
		Color(204, 174, 122, a255) -- 1322
	) -- 1322
	uiInkDraw:drawCircle( -- 1324
		Vec2(fx - 9, fy - 8), -- 1324
		4.8, -- 1324
		Color(238, 212, 182, a255) -- 1324
	) -- 1324
	uiInkDraw:drawSegment( -- 1325
		Vec2(fx - 7, fy - 6), -- 1325
		Vec2(fx, fy), -- 1325
		2.5, -- 1325
		Color(244, 222, 196, a255) -- 1325
	) -- 1325
	uiInkDraw:drawRing( -- 1326
		Vec2(fx, fy), -- 1326
		2, -- 1326
		3, -- 1326
		Color(0, 0, 0, 0), -- 1326
		0.9, -- 1326
		inkCol -- 1326
	) -- 1326
	uiGlow:drawDot( -- 1327
		Vec2(fx, fy), -- 1327
		3.4, -- 1327
		toColor(PALETTE.amberCore, 80 * appear) -- 1327
	) -- 1327
end -- 1275
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1331
	local bx = 46 -- 1338
	local by = ctx.uiH - 112 -- 1339
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1340
	drawSilkVeil( -- 1341
		uiDraw, -- 1341
		uiArt, -- 1341
		"rw_armed_veil", -- 1341
		bx + 54, -- 1341
		by, -- 1341
		142, -- 1341
		30, -- 1341
		PALETTE.inkWash, -- 1341
		0.72, -- 1341
		-1 -- 1341
	) -- 1341
	____exports.drawReloadPatternGlyph( -- 1342
		uiInkDraw, -- 1342
		bx + 12, -- 1342
		by, -- 1342
		9, -- 1342
		effect, -- 1342
		col, -- 1342
		0.96 -- 1342
	) -- 1342
	drawBlossomDot( -- 1343
		uiInkDraw, -- 1343
		uiArt, -- 1343
		"rw_armed_dot", -- 1343
		bx + 28, -- 1343
		by, -- 1343
		6, -- 1343
		col, -- 1343
		0.85, -- 1343
		3 -- 1343
	) -- 1343
	ctx.texts:put( -- 1344
		"xs", -- 1344
		____exports.reloadEffectShortLabel(effect), -- 1344
		bx + 38, -- 1344
		by, -- 1344
		toColor(PALETTE.textBright), -- 1344
		0, -- 1344
		0.5, -- 1344
		"Left", -- 1344
		1, -- 1344
		0.94, -- 1344
		0.08 -- 1344
	) -- 1344
end -- 1331
function ____exports.createReloadWheelPlugin(contract) -- 1348
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1349
end -- 1348
return ____exports -- 1348